const sql = require('mssql');
const { PortElement } = require('soap/lib/wsdl/elements');

require('dotenv').config(); // ← caso não esteja já incluso

//const environment = process.env.NODE_ENV || 'development';

const server = process.env.NODE_ENV === 'production'
  ? process.env.DB_SERVER_PROD
  : process.env.DB_SERVER_DEV;

/////////////////////////////////////////////////////////////

let pools = {};

const baseConfig = {
  user: 'sa',
  password: 'sql@127',
  server: server || '181.191.209.84',

  //server: environment === 'production' ? '181.191.209.84' : '192.168.100.50',
  // server,
  //server: '181.191.209.84',
  //192.168.100.50
  //server: '192.168.100.50',
  ////////////////////////////////////////////////////////////////////

  port: 1433,
  options: {
    trustServerCertificate: true
  },
  requestTimeout: 60000, // 60 segundos
};

async function getPool(databaseName) {
  if (pools[databaseName] && pools[databaseName].connected) {
    return pools[databaseName];
  }

  if (pools[databaseName]) await pools[databaseName].close();

  const pool = await new sql.ConnectionPool({
    ...baseConfig,
    database: databaseName
  }).connect();

  pools[databaseName] = pool;
  return pool;
}

async function closeAllPools() {
  for (const db in pools) {
    if (pools[db] && pools[db].connected) {
      await pools[db].close();
      pools[db] = null;
    }
  }
}

module.exports = { getPool, closeAllPools };
