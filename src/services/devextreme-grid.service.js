import { api } from './http'
import { mapColumnsFromDB, applyMapaToColumns, fetchMapaAtributo } from '@/services/mapaAtributo' // já existe

/** Busca colunas do menu e aplica metadados do mapa (largura, caption, formato, visibilidade) */
export async function getColumnsForMenu(cd_menu, { cd_tabela, columns = [], cd_parametro = 1 } = {}) {
  let cols = columns
  if (!cols.length) {
    const { data } = await api.get(`/colunas/menu/${cd_menu}`)
    cols = (data || []).map(r => ({
      dataField: r.nm_atributo || r.NM_ATRIBUTO,
      caption: r.nm_titulo || r.nm_atributo,
      width: Number(r.cd_tamanho_coluna || 0) || undefined,
      visible: String(r.ic_mostra_grid || 'S').toUpperCase() === 'S'
    }))
  }
  if (cd_tabela) return mapColumnsFromDB(cd_tabela, cols, { cd_parametro })
  // sem tabela, aplica apenas o que tiver no retorno do menu
  const { byAtrib } = await fetchMapaAtributo(cd_tabela || 0, cols.map(c=>c.dataField), { cd_parametro })
  return applyMapaToColumns(cols, byAtrib)
}

/** Data (array) para o grid via /menu-pesquisa (usa pr_egis_pesquisa_dados) */
export async function getRowsFromPesquisa(body) {
  const { data } = await api.post('/menu-pesquisa', body)
  return data
}

/** Execução direta de procedure já mapeada por cd_menu */
export async function getRowsExecPorMenu(cd_menu, parametros) {
  const { data } = await api.post(`/exec/menu/${cd_menu}`, { parametros })
  return data
}
