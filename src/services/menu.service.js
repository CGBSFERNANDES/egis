import { api } from './http'

export async function getProcedurePorMenu(cd_menu) {
  const { data } = await api.get(`/procedure/menu/${cd_menu}`)
  return data?.procedure
}

export async function getParametrosPorMenu(cd_menu) {
  const { data } = await api.get(`/parametros/menu/${cd_menu}`)
  return data
}

export async function getColunasPorMenu(cd_menu) {
  const { data } = await api.get(`/colunas/menu/${cd_menu}`)
  return data
}

export async function getMenuPesquisa(body) {
  const { data } = await api.post('/menu-pesquisa', body)
  return data
}

export async function getMenuFiltro({ cd_menu, cd_usuario }) {
  const { data } = await api.post('/menu-filtro', { cd_menu, cd_usuario })
  return data
}

/**
 * Monta um objeto de “informação do menu” para exibir no pop-up (i).
 * Heurística: título do menu (se vier no body) + 1a linha de descrição obtida em parâmetros/colunas.
 * Ajuste conforme seu banco (ex.: usar um param “descricao_menu” se existir).
 */
export async function getInfoDoMenu(cd_menu, { tituloFallback } = {}) {
  const [params, cols] = await Promise.all([
    getParametrosPorMenu(cd_menu).catch(()=>[]),
    getColunasPorMenu(cd_menu).catch(()=>[])
  ])

  // procura um param com título/descrição
  const paramDesc = (params || []).find(p =>
    /descri|descricao|sobre|help/i.test(p.nome_parametro || p.titulo_parametro || '')
  )
  const descricao = (paramDesc?.valor_padrao || paramDesc?.titulo_parametro || '')
    || (cols?.[0]?.ds_menu || cols?.[0]?.nm_titulo || '')

  const titulo = tituloFallback || (cols?.[0]?.nm_menu || cols?.[0]?.nm_titulo || 'Informações')

  return {
    titulo,
    descricao: descricao || 'Sem descrição cadastrada para este menu.'
  }
}
