//const executarProcedure = require("../utils/exec-procedure");

async function autenticarViaBase64({ banco, login, senha }) {
  const sql = `
    SELECT cd_usuario, nm_usuario 
    FROM tb_usuario 
    WHERE nm_login = @login AND ds_senha = HASHBYTES('MD5', @senha) AND ic_ativo = 'S'
  `;
  const result = await executarProcedure({ banco, sql, params: { login, senha } });

  return result?.recordset?.[0] || null;
}

module.exports = { autenticarViaBase64 };
