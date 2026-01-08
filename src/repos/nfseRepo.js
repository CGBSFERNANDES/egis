// src/repos/nfseRepo.js
const { query } = require('../db/mssql');

/**
 * Usa a view vw_nfs_dados_nfseV2_item:
 * - retorna várias linhas (itens)
 * - headerRow = primeira linha (campos “fixos” da nota)
 * - itemRows  = todas as linhas (um item por linha)
 */
async function getNotaByCdNotaSaida(cd_nota_saida) {
  const cd = Number(cd_nota_saida);
  if (!Number.isFinite(cd)) throw new Error('cd_nota_saida inválido');

  const sqlText = `
    SELECT *
    FROM vw_nfs_dados_nfseV2_item
    WHERE cd_nota_saida = @cd
    ORDER BY cd_item_nota_saida
  `;

  const r = await query(sqlText, { cd });
  const rows = r.recordset || [];

  if (!rows.length) {
    throw new Error(
      `Nenhum registro encontrado em vw_nfs_dados_nfseV2_item para cd_nota_saida=${cd}`,
    );
  }

  return {
    headerRow: rows[0],
    itemRows: rows,
  };
}

module.exports = { getNotaByCdNotaSaida };
