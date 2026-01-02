/**
 * Robo Sync Alpha <-> Nuvem (Egissql_334)
 * - Roda no Windows do cliente (Alpha)
 * - Origem: SQL Server local (Egissql)
 * - Destino: SQL Server nuvem (Egissql_334)
 *
 * Requisitos:
 *   npm i mssql dotenv
 */

const sql = require("mssql");
require("dotenv").config();

const LOOP_PUSH_MS = Number(process.env.ROBO_LOOP_PUSH_MS || 8000);
const LOOP_PULL_MS = Number(process.env.ROBO_LOOP_PULL_MS || 12000);
const LOTE = Number(process.env.ROBO_LOTE || 20);

function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

function buildServerName(server, instance) {
  if (!instance) return server;
  // SQL Server instance format: host\instance
  return `${server}\\${instance}`;
}

function cfgFromEnv(prefix) {
  const server = process.env[`${prefix}_SERVER`];
  const instance = process.env[`${prefix}_INSTANCE`];
  const portRaw = process.env[`${prefix}_PORT`];
  const port = portRaw ? Number(portRaw) : undefined;

  return {
    user: process.env[`${prefix}_USER`],
    password: process.env[`${prefix}_PASSWORD`],
    server: buildServerName(server, instance),
    port, // <-- suporte a porta
    database: process.env[`${prefix}_DB`],
    options: {
      trustServerCertificate: true,
      encrypt: false,
    },
    requestTimeout: 120000,
    connectionTimeout: 30000,
    pool: { max: 10, min: 0, idleTimeoutMillis: 30000 },
  };
}

const cfgAlpha = cfgFromEnv("ALPHA");
const cfgCloud = cfgFromEnv("CLOUD");

let poolAlpha = null;
let poolCloud = null;

async function connectPool(cfg, label) {
  // cria um pool novo, com reconexão simples
  const pool = new sql.ConnectionPool(cfg);
  pool.on("error", err => {
    console.log(`[${label}] Pool error:`, err?.message || err);
  });
  await pool.connect();
  return pool;
}

async function getPool(which) {
  if (which === "alpha") {
    if (poolAlpha?.connected) return poolAlpha;
    if (poolAlpha) {
      try {
        await poolAlpha.close();
      } catch {}
    }
    poolAlpha = await connectPool(cfgAlpha, "ALPHA");
    return poolAlpha;
  }

  if (poolCloud?.connected) return poolCloud;
  if (poolCloud) {
    try {
      await poolCloud.close();
    } catch {}
  }
  poolCloud = await connectPool(cfgCloud, "CLOUD");
  return poolCloud;
}

async function testConnections() {
  console.log("🔎 Testando conexões...");
  const a = await getPool("alpha");
  const c = await getPool("cloud");

  const ra = await a
    .request()
    .query("SELECT DB_NAME() AS db, @@SERVERNAME AS server");
  const rc = await c
    .request()
    .query("SELECT DB_NAME() AS db, @@SERVERNAME AS server");

  console.log(
    `✅ ALPHA conectado: server=${ra.recordset[0].server} db=${ra.recordset[0].db}`
  );
  console.log(
    `✅ CLOUD conectado: server=${rc.recordset[0].server} db=${rc.recordset[0].db}`
  );
}

/**
 * Tabela auxiliar de controle (recomendado)
 * Crie em ambos bancos: Alpha e Cloud
 */
async function ensureSyncTable(pool) {
  const ddl = `
IF OBJECT_ID('dbo.Nota_Validacao_Sync','U') IS NULL
BEGIN
  CREATE TABLE dbo.Nota_Validacao_Sync (
    cd_nota_saida INT NOT NULL PRIMARY KEY,
    ic_envio CHAR(1) NOT NULL DEFAULT 'N',     -- N novo | P processando | S enviado | E erro
    ic_retorno CHAR(1) NOT NULL DEFAULT 'N',   -- N pendente | P processando | S ok | E erro
    tentativas INT NOT NULL DEFAULT 0,
    dt_ult_envio DATETIME NULL,
    dt_ult_retorno DATETIME NULL,
    ds_erro VARCHAR(4000) NULL
  );
END
`;
  await pool.request().query(ddl);
}

/**
 * Seleciona pendências no Alpha com lock e marca ic_envio='P'
 */
async function pegarPendentesAlpha() {
  const pool = await getPool("alpha");
  await ensureSyncTable(pool);

  const q = `
BEGIN TRAN;

;WITH cte AS (
  SELECT TOP (@lote) nv.cd_nota_saida
  FROM Nota_Validacao nv WITH (READPAST, UPDLOCK, ROWLOCK)
  LEFT JOIN Nota_Validacao_Sync s WITH (UPDLOCK, ROWLOCK)
    ON s.cd_nota_saida = nv.cd_nota_saida
  WHERE ISNULL(nv.ic_validada,'N')='N'
    AND ISNULL(s.ic_envio,'N') IN ('N','E')
  ORDER BY ISNULL(nv.dt_usuario_inclusao, GETDATE()) DESC
)
MERGE Nota_Validacao_Sync AS T
USING cte AS S
ON T.cd_nota_saida = S.cd_nota_saida
WHEN MATCHED THEN
  UPDATE SET ic_envio='P',
             tentativas = tentativas + 1,
             dt_ult_envio = GETDATE(),
             ds_erro=NULL
WHEN NOT MATCHED THEN
  INSERT (cd_nota_saida, ic_envio, tentativas, dt_ult_envio)
  VALUES (S.cd_nota_saida, 'P', 1, GETDATE());

SELECT TOP (@lote) cd_nota_saida
FROM Nota_Validacao_Sync WITH (READPAST)
WHERE ic_envio='P'
ORDER BY dt_ult_envio DESC;

COMMIT;
`;

  const r = await pool
    .request()
    .input("lote", sql.Int, LOTE)
    .query(q);
  return r.recordset.map(x => x.cd_nota_saida);
}

/**
 * Carrega Nota_Saida + itens do Alpha
 */
async function carregarNotaAlpha(cd_nota_saida) {
  const pool = await getPool("alpha");

  const nota = await pool
    .request()
    .input("id", sql.Int, cd_nota_saida)
    .query(`SELECT * FROM Nota_Saida WITH(NOLOCK) WHERE cd_nota_saida=@id`);

  const itens = await pool
    .request()
    .input("id", sql.Int, cd_nota_saida)
    .query(
      `SELECT * FROM Nota_Saida_Item WITH(NOLOCK) WHERE cd_nota_saida=@id`
    );

  if (!nota.recordset.length)
    throw new Error(`Nota_Saida não encontrada no Alpha: ${cd_nota_saida}`);

  return { nota: nota.recordset[0], itens: itens.recordset };
}

/**
 * UPSERT na nuvem (versão mínima para iniciar)
 * - A gente amplia conforme a pr_processo_validacao_api_nota_fiscal exigir mais colunas.
 */
async function upsertNotaCloud(payload) {
  const pool = await getPool("cloud");
  await ensureSyncTable(pool);

  const cd = payload.nota.cd_nota_saida;

  // 1) Nota_Saida mínimo (evita depender de 200 colunas agora)
  await pool.request().input("id", sql.Int, cd).query(`
IF NOT EXISTS (SELECT 1 FROM Nota_Saida WHERE cd_nota_saida=@id)
BEGIN
  INSERT INTO Nota_Saida (cd_nota_saida, dt_nota_saida, cd_operacao_fiscal, cd_cliente, cd_chave_acesso)
  SELECT @id, NULL, NULL, NULL, NULL;
END
`);

  // 2) Itens: recria (simples e previsível)
  await pool.request().input("id", sql.Int, cd).query(`
DELETE FROM Nota_Saida_Item WHERE cd_nota_saida=@id
`);

  for (const it of payload.itens) {
    await pool
      .request()
      .input("cd_nota_saida", sql.Int, it.cd_nota_saida)
      .input("cd_item_nota_saida", sql.Int, it.cd_item_nota_saida)
      .input(
        "nm_produto_item_nota",
        sql.VarChar(120),
        it.nm_produto_item_nota ?? null
      )
      .input("qt_item_nota_saida", sql.Float, it.qt_item_nota_saida ?? null)
      .input(
        "vl_unitario_item_nota",
        sql.Float,
        it.vl_unitario_item_nota ?? null
      ).query(`
INSERT INTO Nota_Saida_Item (cd_nota_saida, cd_item_nota_saida, nm_produto_item_nota, qt_item_nota_saida, vl_unitario_item_nota)
VALUES (@cd_nota_saida, @cd_item_nota_saida, @nm_produto_item_nota, @qt_item_nota_saida, @vl_unitario_item_nota)
`);
  }

  // 3) Nota_Validacao na nuvem (gatilho do ServicoNFCe.js)
  await pool.request().input("id", sql.Int, cd).query(`
IF NOT EXISTS (SELECT 1 FROM Nota_Validacao WHERE cd_nota_saida=@id)
BEGIN
  INSERT INTO Nota_Validacao (cd_nota_saida, dt_usuario_inclusao, ic_validada)
  VALUES (@id, GETDATE(), 'N');
END
ELSE
BEGIN
  UPDATE Nota_Validacao
    SET ic_validada = ISNULL(ic_validada,'N'),
        dt_usuario_inclusao = GETDATE()
  WHERE cd_nota_saida=@id;
END
`);

  // marca envio OK na nuvem (controle)
  await pool.request().input("id", sql.Int, cd).query(`
MERGE Nota_Validacao_Sync AS T
USING (SELECT @id AS cd_nota_saida) S
ON T.cd_nota_saida=S.cd_nota_saida
WHEN MATCHED THEN UPDATE SET ic_envio='S'
WHEN NOT MATCHED THEN INSERT (cd_nota_saida, ic_envio) VALUES (@id,'S');
`);
}

async function marcarEnvioAlpha(cd_nota_saida, ok, erroMsg) {
  const pool = await getPool("alpha");
  await pool
    .request()
    .input("id", sql.Int, cd_nota_saida)
    .input("erro", sql.VarChar(4000), erroMsg || null).query(`
UPDATE Nota_Validacao_Sync
SET ic_envio = ${ok ? "'S'" : "'E'"},
    ds_erro = @erro
WHERE cd_nota_saida=@id
`);
}

/**
 * Busca resultados finalizados na nuvem para devolver ao Alpha
 * Critério "finalizado" aqui:
 * - ic_validada diferente de 'N' (ajustaremos se seu fluxo usa outro padrão)
 */
async function buscarResultadosCloud() {
  const pool = await getPool("cloud");
  await ensureSyncTable(pool);

  const q = `
SELECT TOP (@lote)
  nv.cd_nota_saida,
  nv.ic_validada,
  nv.cd_status_validacao,
  nv.dt_validacao,
  nv.ds_retorno,
  nv.dt_autorizacao,
  nv.cd_protocolo_nfe,
  nv.ds_xml_nota,
  nv.cd_chave_acesso,
  nv.ic_cancelar,
  nv.ic_cancelada,
  nv.dt_cancelamento,
  nv.cd_protocolo_canc,
  nv.ds_xml_evento
FROM Nota_Validacao nv WITH (NOLOCK)
JOIN Nota_Validacao_Sync s WITH (NOLOCK)
  ON s.cd_nota_saida = nv.cd_nota_saida
WHERE ISNULL(s.ic_retorno,'N') IN ('N','E')
  AND ISNULL(nv.ic_validada,'N') <> 'N'
ORDER BY ISNULL(nv.dt_usuario, nv.dt_usuario_inclusao) DESC
`;

  const r = await pool
    .request()
    .input("lote", sql.Int, LOTE)
    .query(q);
  return r.recordset;
}

async function aplicarResultadoNoAlpha(row) {
  const pool = await getPool("alpha");

  await pool
    .request()
    .input("cd_nota_saida", sql.Int, row.cd_nota_saida)
    .input("ic_validada", sql.Char(1), row.ic_validada ?? null)
    .input("cd_status_validacao", sql.Int, row.cd_status_validacao ?? null)
    .input("dt_validacao", sql.DateTime, row.dt_validacao ?? null)
    .input("ds_retorno", sql.NVarChar(sql.MAX), row.ds_retorno ?? null)
    .input("dt_autorizacao", sql.DateTime, row.dt_autorizacao ?? null)
    .input("cd_protocolo_nfe", sql.VarChar(40), row.cd_protocolo_nfe ?? null)
    .input("ds_xml_nota", sql.NVarChar(sql.MAX), row.ds_xml_nota ?? null)
    .input("cd_chave_acesso", sql.VarChar(60), row.cd_chave_acesso ?? null)
    .input("ic_cancelar", sql.Char(1), row.ic_cancelar ?? null)
    .input("ic_cancelada", sql.Char(1), row.ic_cancelada ?? null)
    .input("dt_cancelamento", sql.DateTime, row.dt_cancelamento ?? null)
    .input("cd_protocolo_canc", sql.VarChar(40), row.cd_protocolo_canc ?? null)
    .input("ds_xml_evento", sql.NVarChar(sql.MAX), row.ds_xml_evento ?? null)
    .query(`
UPDATE Nota_Validacao
SET
  ic_validada = ISNULL(@ic_validada, ic_validada),
  cd_status_validacao = ISNULL(@cd_status_validacao, cd_status_validacao),
  dt_validacao = ISNULL(@dt_validacao, dt_validacao),
  ds_retorno = ISNULL(@ds_retorno, ds_retorno),
  dt_autorizacao = ISNULL(@dt_autorizacao, dt_autorizacao),
  cd_protocolo_nfe = ISNULL(@cd_protocolo_nfe, cd_protocolo_nfe),
  ds_xml_nota = ISNULL(@ds_xml_nota, ds_xml_nota),
  cd_chave_acesso = ISNULL(@cd_chave_acesso, cd_chave_acesso),
  ic_cancelar = ISNULL(@ic_cancelar, ic_cancelar),
  ic_cancelada = ISNULL(@ic_cancelada, ic_cancelada),
  dt_cancelamento = ISNULL(@dt_cancelamento, dt_cancelamento),
  cd_protocolo_canc = ISNULL(@cd_protocolo_canc, cd_protocolo_canc),
  ds_xml_evento = ISNULL(@ds_xml_evento, ds_xml_evento),
  dt_usuario = GETDATE()
WHERE cd_nota_saida=@cd_nota_saida
`);

  // marca retorno OK no Alpha
  await pool.request().input("id", sql.Int, row.cd_nota_saida).query(`
UPDATE Nota_Validacao_Sync
SET ic_retorno='S', dt_ult_retorno=GETDATE()
WHERE cd_nota_saida=@id
`);
}

async function marcarRetornoCloud(cd_nota_saida, ok, erroMsg) {
  const pool = await getPool("cloud");
  await pool
    .request()
    .input("id", sql.Int, cd_nota_saida)
    .input("erro", sql.VarChar(4000), erroMsg || null).query(`
UPDATE Nota_Validacao_Sync
SET ic_retorno = ${ok ? "'S'" : "'E'"},
    dt_ult_retorno = GETDATE(),
    ds_erro = @erro
WHERE cd_nota_saida=@id
`);
}

async function loopPush() {
  while (true) {
    try {
      const pendentes = await pegarPendentesAlpha();
      if (pendentes.length)
        console.log(`[PUSH] Pendentes Alpha: ${pendentes.length}`);

      for (const cd of pendentes) {
        try {
          const payload = await carregarNotaAlpha(cd);
          await upsertNotaCloud(payload);
          await marcarEnvioAlpha(cd, true);
          console.log(`[PUSH] OK cd_nota_saida=${cd}`);
        } catch (e) {
          await marcarEnvioAlpha(cd, false, e.message);
          console.log(`[PUSH] ERRO cd_nota_saida=${cd} -> ${e.message}`);
        }
      }
    } catch (e) {
      console.log(`[PUSH] Falha no loop: ${e.message}`);
      // tentativa de reconexão
      try {
        if (poolAlpha) await poolAlpha.close();
      } catch {}
      poolAlpha = null;
      await sleep(2000);
    }

    await sleep(LOOP_PUSH_MS);
  }
}

async function loopPull() {
  while (true) {
    try {
      const resultados = await buscarResultadosCloud();
      if (resultados.length)
        console.log(`[PULL] Resultados nuvem: ${resultados.length}`);

      for (const row of resultados) {
        try {
          await aplicarResultadoNoAlpha(row);
          await marcarRetornoCloud(row.cd_nota_saida, true);
          console.log(`[PULL] OK cd_nota_saida=${row.cd_nota_saida}`);
        } catch (e) {
          await marcarRetornoCloud(row.cd_nota_saida, false, e.message);
          console.log(
            `[PULL] ERRO cd_nota_saida=${row.cd_nota_saida} -> ${e.message}`
          );
        }
      }
    } catch (e) {
      console.log(`[PULL] Falha no loop: ${e.message}`);
      try {
        if (poolCloud) await poolCloud.close();
      } catch {}
      poolCloud = null;
      await sleep(2000);
    }

    await sleep(LOOP_PULL_MS);
  }
}

async function main() {
  console.log("🟢 RoboSyncAlpha iniciado");
  console.log(
    `ALPHA -> server=${cfgAlpha.server} port=${cfgAlpha.port ??
      "(default)"} db=${cfgAlpha.database}`
  );
  console.log(
    `CLOUD -> server=${cfgCloud.server} port=${cfgCloud.port ??
      "(default)"} db=${cfgCloud.database}`
  );

  try {
    await testConnections();
  } catch (err) {
    console.error("❌ ERRO DE AMBIENTE");
    console.error("Não foi possível conectar aos bancos de dados.");
    console.error("Verifique se:");
    console.error(" - O SQL Server local (Alpha) está instalado e rodando");
    console.error(" - A instância/porta estão corretas");
    console.error(" - Usuário e senha estão corretos no arquivo .env");
    console.error("Detalhe técnico:", err.message);
    process.exit(2);
  }

  await Promise.all([loopPush(), loopPull()]);
}

main().catch(e => {
  console.error("❌ Falha fatal:", e);
  process.exit(1);
});
