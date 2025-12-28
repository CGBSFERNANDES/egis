
/* =====================================================================================
   pr_egis_gera_roteiro_vendedor – Gera roteiro PADRÃO (sem datas) por SEG..SEX
   Regras:
     - Lê tabela CLIENTE (cd_cliente, cd_vendedor, cd_cep, cd_criterio_visita, cd_semana?, vl_faturamento?)
     - Parâmetro @ic_distribuicao_semana:
         'S' → a proc DISTRIBUI clientes nos dias SEG..SEX (balanceado por cluster de CEP)
         <> 'S' → mantém o dia vindo do cadastro (cliente.cd_semana); se nulo, assume 'SEG'
     - Respeita @qt_visita_diaria por dia
     - Critério: 'valor' | 'distancia' | 'mix'
     - Insere em vendedor_roteiro SEM data (padrão). Não usa CTE; apenas tabelas temporárias.
   ------------------------------------------------------------------------------------- */

IF OBJECT_ID('dbo.pr_egis_gera_roteiro_vendedor','P') IS NOT NULL
  DROP PROCEDURE dbo.pr_egis_gera_roteiro_vendedor;
GO
CREATE PROCEDURE dbo.pr_egis_gera_roteiro_vendedor
  @json NVARCHAR(MAX) = N''
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    -----------------------------------------------------------------------------------
    -- 1) Normalização básica do JSON e leitura dos parâmetros
    -----------------------------------------------------------------------------------
    SET @json = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
               REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
               @json, CHAR(13),' '), CHAR(10),' '),' ',' '),':\\\"',':\\"'),
               '\\\";','\\";'),':\\"',':\\\"'),'\\";','\\\";'),'\\"','\"'),
               '\"','"'),'',''),'["','['),'"[','['),']"',']'),'"]',']');

    DECLARE @cd_empresa           INT         = 0,
            @cd_parametro         INT         = 0,
            @cd_usuario           INT         = NULL,
            @cd_vendedor          INT         = NULL,
            @qt_visita_diaria     INT         = NULL,
            @criterio             VARCHAR(10) = NULL,   -- 'valor'|'distancia'|'mix'
            @hora_inicio          TIME(0)     = '09:00',
            @hora_fim             TIME(0)     = '17:00',
            @ic_distribuicao_semana CHAR(1)   = 'S';    -- 'S' distribui SEG..SEX; senão mantém do cadastro

    IF OBJECT_ID('tempdb..#json') IS NOT NULL DROP TABLE #json;
    -- Tenta ler como objeto simples
    SELECT j.[key]  AS campo,
           j.[value] AS valor
    INTO #json
    FROM OPENJSON(@json) j;

    -- Se não veio nada, tenta ler como array de um objeto
    IF NOT EXISTS (SELECT 1 FROM #json)
    BEGIN
      TRUNCATE TABLE #json;
      INSERT INTO #json(campo, valor)
      SELECT j2.[key], j2.[value]
      FROM OPENJSON(@json) root
      CROSS APPLY OPENJSON(root.value) j2;
    END

    SELECT @cd_empresa           = TRY_CONVERT(INT, valor)       FROM #json WHERE campo='cd_empresa';
    SELECT @cd_parametro         = TRY_CONVERT(INT, valor)       FROM #json WHERE campo='cd_parametro';
    SELECT @cd_usuario           = TRY_CONVERT(INT, valor)       FROM #json WHERE campo='cd_usuario';
    SELECT @cd_vendedor          = TRY_CONVERT(INT, valor)       FROM #json WHERE campo='cd_vendedor';
    SELECT @qt_visita_diaria     = TRY_CONVERT(INT, valor)       FROM #json WHERE campo='qt_visita_diaria';
    SELECT @criterio             = TRY_CONVERT(VARCHAR(10),valor)FROM #json WHERE campo='criterio';
    SELECT @hora_inicio          = TRY_CONVERT(TIME(0), valor)   FROM #json WHERE campo='hora_inicio';
    SELECT @hora_fim             = TRY_CONVERT(TIME(0),  valor)  FROM #json WHERE campo='hora_fim';
    SELECT @ic_distribuicao_semana = TRY_CONVERT(CHAR(1), valor) FROM #json WHERE campo='ic_distribuicao_semana';

    SET @criterio = ISNULL(@criterio,'mix');
    SET @qt_visita_diaria = ISNULL(@qt_visita_diaria, 8);
    SET @ic_distribuicao_semana = ISNULL(@ic_distribuicao_semana, 'S');

    -----------------------------------------------------------------------------------
    -- 2) Base de clientes necessária para o roteiro
    --    Esperado: cliente(cd_cliente, cd_vendedor, cd_cep, cd_criterio_visita, cd_semana?, vl_faturamento?)
    -----------------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#cli') IS NOT NULL DROP TABLE #cli;
    SELECT
      c.cd_cliente,
      c.cd_vendedor,
      c.cd_cep,
      c.cd_criterio_visita,
      -- Normaliza eventual cd_semana do cadastro (numérico 2..7 ou 'SEG'..'SAB').
      CASE
        WHEN TRY_CONVERT(INT, c.cd_semana) IN (2,3,4,5,6,7) THEN
          CASE TRY_CONVERT(INT, c.cd_semana)
            WHEN 2 THEN 'SEG' WHEN 3 THEN 'TER' WHEN 4 THEN 'QUA'
            WHEN 5 THEN 'QUI' WHEN 6 THEN 'SEX' WHEN 7 THEN 'SAB' END
        WHEN UPPER(ISNULL(c.cd_semana,'')) IN ('SEG','TER','QUA','QUI','SEX','SAB') THEN UPPER(c.cd_semana)
        ELSE NULL
      END                                         AS sg_semana,           -- pode vir NULL
      TRY_CONVERT(INT, LEFT(NULLIF(c.cd_cep,''),5)) AS cep_prefix5,
      TRY_CONVERT(INT, LEFT(NULLIF(c.cd_cep,''),3)) AS cep_prefix3,
      ISNULL(TRY_CONVERT(DECIMAL(18,2), c.vl_faturamento), 0) AS vl_faturamento
    INTO #cli
    FROM dbo.cliente c WITH (NOLOCK)
    WHERE (@cd_vendedor IS NULL OR c.cd_vendedor = @cd_vendedor);

    IF NOT EXISTS (SELECT 1 FROM #cli)
    BEGIN
      SELECT 'Sem clientes para os parâmetros informados.' AS Msg, 0 AS RegistrosGerados;
      RETURN;
    END

    -----------------------------------------------------------------------------------
    -- 3) Decide o cd_semana: gera (SEG..SEX) ou mantém o do cadastro
    -----------------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#cli_semana') IS NOT NULL DROP TABLE #cli_semana;

    IF (@ic_distribuicao_semana = 'S')
    BEGIN
      -- 3a) Agrupa por cluster de CEP (prefixo 3) e balanceia em 5 buckets (SEG..SEX)
      IF OBJECT_ID('tempdb..#cl') IS NOT NULL DROP TABLE #cl;
      SELECT
        cd_vendedor,
        cep_cluster = ISNULL(cep_prefix3, 0),
        cnt         = COUNT(*),
        soma_valor  = SUM(vl_faturamento),
        min_cep5    = MIN(ISNULL(cep_prefix5, 99999))
      INTO #cl
      FROM #cli
      GROUP BY cd_vendedor, ISNULL(cep_prefix3, 0);

      IF OBJECT_ID('tempdb..#cl_ord') IS NOT NULL DROP TABLE #cl_ord;
      SELECT
        c.*,
        rn_cluster = ROW_NUMBER() OVER (
                       PARTITION BY cd_vendedor
                       ORDER BY
                         CASE WHEN @criterio='distancia' THEN min_cep5 END ASC,
                         CASE WHEN @criterio IN ('valor','mix') THEN soma_valor END DESC,
                         cep_cluster
                     ),
        bucket_dia = NTILE(5) OVER (
                       PARTITION BY cd_vendedor
                       ORDER BY
                         CASE WHEN @criterio='distancia' THEN min_cep5 END ASC,
                         CASE WHEN @criterio IN ('valor','mix') THEN soma_valor END DESC,
                         cep_cluster
                     )
      INTO #cl_ord
      FROM #cl c;

      -- Junta clientes ao cluster e atribui cd_semana calculado
      SELECT
        a.cd_cliente,
        a.cd_vendedor,
        a.cd_criterio_visita,
        a.cd_cep,
        a.vl_faturamento,
        cd_semana = CASE o.bucket_dia
                      WHEN 1 THEN 'SEG' WHEN 2 THEN 'TER' WHEN 3 THEN 'QUA'
                      WHEN 4 THEN 'QUI' ELSE 'SEX'
                    END
      INTO #cli_semana
      FROM #cli a
      JOIN #cl_ord o
        ON o.cd_vendedor = a.cd_vendedor
       AND o.cep_cluster = ISNULL(a.cep_prefix3, 0);
    END
    ELSE
    BEGIN
      -- 3b) Mantém o dia vindo do cadastro; se NULL, assume 'SEG'
      SELECT
        cd_cliente,
        cd_vendedor,
        cd_criterio_visita,
        cd_cep,
        vl_faturamento,
        cd_semana = ISNULL(sg_semana, 'SEG')
      INTO #cli_semana
      FROM #cli;
    END

    -----------------------------------------------------------------------------------
    -- 4) Ordena dentro do dia conforme critério e aplica o limite diário
    -----------------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#base') IS NOT NULL DROP TABLE #base;
    SELECT
      cd_vendedor,
      cd_cliente,
      cd_criterio_visita,
      cd_semana,
      cd_cep,
      vl_faturamento,
      rn = ROW_NUMBER() OVER (
            PARTITION BY cd_vendedor, cd_semana
            ORDER BY
              CASE WHEN @criterio='distancia' THEN TRY_CONVERT(INT, LEFT(NULLIF(cd_cep,''),5)) END ASC,
              CASE WHEN @criterio IN ('valor','mix') THEN vl_faturamento END DESC,
              cd_cliente
          )
    INTO #base
    FROM #cli_semana;

    IF OBJECT_ID('tempdb..#selec') IS NOT NULL DROP TABLE #selec;
    SELECT
      cd_vendedor,
      cd_cliente,
      cd_criterio_visita,
      cd_semana,
      qt_ordem_visita = rn,
      cd_cep
    INTO #selec
    FROM #base
    WHERE rn <= @qt_visita_diaria;

    -----------------------------------------------------------------------------------
    -- 5) Limpa e grava em vendedor_roteiro (sem datas)
    -----------------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#vend') IS NOT NULL DROP TABLE #vend;
    SELECT DISTINCT cd_vendedor INTO #vend FROM #selec;

    DELETE vr
      FROM dbo.vendedor_roteiro vr
      WHERE EXISTS (SELECT 1 FROM #vend v WHERE v.cd_vendedor = vr.cd_vendedor);

    -- Gera horário sugerido (opcional). Linear entre hora_inicio e hora_fim.
    DECLARE @minutos_totais INT = DATEDIFF(MINUTE, @hora_inicio, @hora_fim);
    DECLARE @slot INT = CASE WHEN @qt_visita_diaria > 0
                             THEN NULLIF(@minutos_totais / @qt_visita_diaria,0)
                             ELSE 0 END;
    SET @slot = ISNULL(@slot, 30); -- fallback 30min

    INSERT INTO dbo.vendedor_roteiro
      (cd_vendedor, cd_cliente, cd_criterio_visita, cd_semana,
       qt_ordem_visita, cd_cep, hr_visita_roteiro,
       cd_usuario_inclusao, dt_usuario_inclusao, cd_usuario, dt_usuario)
    SELECT
      s.cd_vendedor,
      s.cd_cliente,
      s.cd_criterio_visita,
      s.cd_semana,
      s.qt_ordem_visita,
      s.cd_cep,
      CAST(DATEADD(MINUTE, (@slot * (s.qt_ordem_visita - 1)), CAST(@hora_inicio AS DATETIME)) AS TIME(0)) AS hr_visita_roteiro,
      @cd_usuario, GETDATE(), @cd_usuario, GETDATE()
    FROM #selec s
    ORDER BY s.cd_vendedor,
             CASE s.cd_semana WHEN 'SEG' THEN 1 WHEN 'TER' THEN 2 WHEN 'QUA' THEN 3
                              WHEN 'QUI' THEN 4 WHEN 'SEX' THEN 5 WHEN 'SAB' THEN 6 ELSE 7 END,
             s.qt_ordem_visita;

    SELECT 'Roteiro padrão gerado com sucesso.' AS Msg,
           COUNT(*) AS RegistrosGerados
    FROM #selec;
  END TRY
  BEGIN CATCH
    DECLARE @err NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('pr_egis_gera_roteiro_vendedor falhou: %s', 16, 1, @err);
  END CATCH
END
GO

/* ----------------------
   EXEMPLOS DE EXECUÇÃO
   ----------------------
-- Distribuindo SEG..SEX automaticamente (clusters de CEP)
EXEC dbo.pr_egis_gera_roteiro_vendedor
  @json = N'{
    "cd_empresa": 1,
    "cd_usuario": 99,
    "cd_vendedor": 8,            -- opcional: remova para todos os vendedores
    "qt_visita_diaria": 8,
    "criterio": "mix",
    "hora_inicio": "09:00",
    "hora_fim": "17:00",
    "ic_distribuicao_semana": "S"
  }';

-- Mantendo o dia do cadastro (cliente.cd_semana), se NULL assume SEG
EXEC dbo.pr_egis_gera_roteiro_vendedor
  @json = N'{
    "cd_empresa": 1,
    "cd_usuario": 99,
    "cd_vendedor": 8,
    "qt_visita_diaria": 8,
    "criterio": "valor",
    "ic_distribuicao_semana": "N"
  }';
*/
