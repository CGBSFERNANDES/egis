require('dotenv').config();
const sql = require('mssql');

(async () => {
  console.log(
    'Conectando em:',
    process.env.SQL_SERVER,
    process.env.SQL_PORT,
    process.env.SQL_DATABASE,
  );

  const pool = await sql.connect({
    user: process.env.SQL_USER,
    password: process.env.SQL_PASSWORD,
    database: process.env.SQL_DATABASE,
    server: process.env.SQL_SERVER,
    port: Number(process.env.SQL_PORT || 1433),
    options: { encrypt: false, trustServerCertificate: true },
    connectionTimeout: 15000,
    requestTimeout: 15000,
  });

  console.log('✅ Conectou!');
  const r = await pool.request().query('SELECT TOP 1 GETDATE() as agora');
  console.log('✅ Query OK:', r.recordset);

  await pool.close();
  process.exit(0);
})().catch((e) => {
  console.error('❌ DB erro:', e?.message || e);
  process.exit(1);
});
