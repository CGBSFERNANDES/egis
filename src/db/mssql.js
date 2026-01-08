const sql = require('mssql');
const { sql: cfg } = require('../config/env');

let poolPromise;

function getPool() {
  if (!poolPromise) {
    poolPromise = sql.connect({
      user: cfg.user,
      password: cfg.password,
      database: cfg.database,
      server: cfg.server,
      port: cfg.port,
      options: {
        encrypt: false, // muitos SQLServer “externos” não usam encrypt
        trustServerCertificate: true,
      },
      pool: {
        max: 5,
        min: 0,
        idleTimeoutMillis: 30000,
      },
    });
  }
  return poolPromise;
}

async function query(q, params = {}) {
  const pool = await getPool();
  const req = pool.request();
  for (const [k, v] of Object.entries(params)) req.input(k, v);
  return req.query(q);
}

module.exports = { query };
