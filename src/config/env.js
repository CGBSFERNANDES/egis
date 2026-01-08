require('dotenv').config();

function must(name) {
  const v = process.env[name];
  if (!v) throw new Error(`Variável obrigatória ausente: ${name}`);
  return v;
}

module.exports = {
  sql: {
    user: must('SQL_USER'),
    password: must('SQL_PASSWORD'),
    database: must('SQL_DATABASE'),
    server: must('SQL_SERVER'),
    port: Number(process.env.SQL_PORT || 1433),
  },
  nfse: {
    endpointUrl: must('NFSE_ENDPOINT_URL'),
    versao: process.env.NFSE_VERSAO || '2.04',
  },
  cert: {
    pfxPath: must('PFX_PATH'),
    pfxPassword: must('PFX_PASSWORD'),
  },
};
