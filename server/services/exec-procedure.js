// utils/exec-procedure.js
const { poolPromise } = require("../db");

async function executarProcedure(nomeProcedure, parametrosJson) {
    try {
        const pool = await poolPromise;
        const result = await pool
            .request()
            .input("json", parametrosJson)
            .execute(nomeProcedure);
        return result.recordset;
    } catch (error) {
        console.error(`Erro ao executar procedure ${nomeProcedure}:`, error);
        throw error;
    }
}

module.exports = executarProcedure;
