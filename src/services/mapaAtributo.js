// src/services/mapaAtributo.js
//import { api } from 'src/boot/axios' // usa sua instância configurada  :contentReference[oaicite:1]{index=1}
import api from "@/boot/axios";
/**
 * Cache simples (memória + localStorage)
 */
const memCache = new Map()  // chave: `${cd_tabela}|${chaveHash}` → valor: { byAtrib: { nm_atributo: meta } }

function lsGet (k) {
  try { return JSON.parse(localStorage.getItem(k) || 'null') } catch { return null }
}
function lsSet (k, v) {
  try { localStorage.setItem(k, JSON.stringify(v)) } catch {}
}
function hash (s='') {
  // hash leve para chave de cache
  let h = 0; for (let i=0;i<s.length;i++) { h = (h<<5)-h + s.charCodeAt(i); h|=0 }
  return String(h >>> 0)
}

/**
 * Monta o payload que a sua PR espera
 */
function buildPayload (cd_tabela, nomes = [], cd_parametro = 1) {
  const lista = nomes.map(n => ({ nm_atributo: String(n) }))
  return [
    { ic_json_parametro: 'S', cd_parametro, cd_tabela },
    { dados: lista }
  ]
}

/**
 * Mapeia natureza → tipo/format padrão (heurística)
 * natureza (exemplos que você mostrou):
 * 1=inteiro, 2=string, 4=data, 5=flag, 6=numérico/valor (moeda), 7=texto
 */

function naturezaToType (cd_natureza_atributo, qt_decimal = 0) {
  switch (Number(cd_natureza_atributo)) {
    case 1: return { dataType: 'number', format: { type: 'fixedPoint', precision: 0 } }
    case 4: return { dataType: 'date',   format: 'dd/MM/yyyy' }
    case 5: return { dataType: 'boolean' }
    case 6: // valor
      return { dataType: 'number', format: { type: 'fixedPoint', precision: Number(qt_decimal) || 2 } }
    default:
      return { dataType: 'string' }
  }
}

/**
 * Busca metadados dos atributos de uma tabela via procedure
 * @returns { byAtrib: { [nm_atributo]: meta } }
 */

export async function fetchMapaAtributo (cd_tabela = 0, nomes = [], {
  useCache = true,
  cd_parametro = 2,          // <<< novo
} = {}) {
  const keyBase = `MapaAtrib:${cd_tabela}:${cd_parametro}:${hash(nomes.join('|'))}` // <<< inclui param
  if (useCache) {
    const mem = memCache.get(keyBase)
    if (mem) return mem
    const ls = lsGet(keyBase)
    if (ls) { memCache.set(keyBase, ls); return ls }
  }

  const payload = buildPayload(cd_tabela, nomes, cd_parametro);   // <<< usa param
  //console.log('dados de envio : ', payload);

  const { data } = await api.post('/exec/pr_egis_pesquisa_mapa_atributo', payload)

  const rows = Array.isArray(data) ? data : (data?.recordset || data?.rows || [])

  //console.log('Retorno: ', rows);

  const byAtrib = {}

  for (const r of rows) {
    const nome = r.nm_atributo || r.NM_ATRIBUTO;
    const titulo = r.nm_titulo || r.nm_atributo;
    
    if (!nome) continue

    const natureza = r.cd_natureza_atributo ?? r.CD_NATUREZA_ATRIBUTO
    const dec = r.qt_decimal_atributo ?? r.QT_DECIMAL_ATRIBUTO
    const tipoFmt = naturezaToType(natureza, dec)
    
    //console.log('nome = ', nome, titulo);

    byAtrib[nome] = {
      caption: titulo || r.ds_atributo_consulta,  
      label: titulo || r.nm_atributo_consulta || r.ds_atributo || r.nm_atributo_relatorio || nome,
      showInGrid: String(r.ic_mostra_grid || r.IC_MOSTRA_GRID || 'S').toUpperCase() === 'S',
      width: Number(r.cd_tamanho_coluna || r.CD_TAMANHO_COLUNA || 0) || undefined,
      natureza, dec,
      ...tipoFmt,
      __raw: r
    }
  }

  const out = { byAtrib }
  memCache.set(keyBase, out)
  lsSet(keyBase, out)
  return out
}


/**
 * Aplica o mapa nas colunas do seu grid (DevExtreme/Quasar)
 * columns: [{ dataField, caption, dataType, format, width, visible, ... }]
 */

export function applyMapaToColumns (columns=[], byAtrib={}) {
  //console.log(byAtrib);  
  return columns.map(col => {
    const field = col.dataField || col.field || col.name
    const meta = field ? byAtrib[field] : null
    const caption = col.caption || col.dataField;

    if (!meta) return col
    console.log('caption : ', caption);

    //console.log('aplicacao', meta, meta.caption, meta.label);
    //console.log(next);
    
    const next = { ...col }
    //console.log('next: ', next);

    // caption (prioriza label ou caption do meta)
    next.caption = meta.label || meta.caption || next.caption;

    // caption (prioriza label da PR)
    //if (!next.caption && meta.label) next.caption = meta.label

    // tipo/formato
    if (!next.dataType && meta.dataType) next.dataType = meta.dataType
    if (!next.format   && meta.format)   next.format   = meta.format

    // largura sugerida
    if (!next.width && meta.width) next.width = meta.width

    // visibilidade
    if (typeof next.visible === 'undefined') next.visible = meta.showInGrid
      return next
  })

}

/**
 * Utilitário completo: dado cd_tabela + colunas, busca metadados e devolve colunas enriquecidas
 */

export async function mapColumnsFromDB (cd_tabela, columns = [], {
  useCache = true,
  cd_parametro = 1,        // <<< novo
} = {}) {
  const nomes = columns
    .map(c => c.dataField || c.field || c.name)
    .filter(Boolean)

  const { byAtrib } = await fetchMapaAtributo(cd_tabela, nomes, { useCache, cd_parametro })

  //console.log(columns, byAtrib);

  return applyMapaToColumns(columns, byAtrib)

}
