const express = require('express');
const sql = require('mssql');
const path = require('path');
const dbConfig = require('./dbold');
const app = express();
const PORT = 3000;

app.use(express.static(path.join(__dirname, '../public')));

app.get('/modulos', async (req, res) => {
  try {
    await sql.connect(dbConfig);
    const result = await sql.query(`
      SELECT cd_modulo, nm_modulo, cd_ordem_modulo, sg_modulo,
      ic_vincular_cadeia_valor, cadeia_valor.nm_cadeia_valor,
      ic_liberado, qt_hora_implantacao_modulo, ic_fluxo_modulo, ic_web_modulo
      FROM Modulo
      LEFT JOIN Cadeia_Valor ON Modulo.cd_cadeia_valor = Cadeia_valor.cd_cadeia_valor
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Erro ao buscar módulos:', err);
    res.status(500).send('Erro ao buscar módulos');
  }
});

app.listen(PORT, () => console.log(`Servidor rodando em http://localhost:${PORT}`));
