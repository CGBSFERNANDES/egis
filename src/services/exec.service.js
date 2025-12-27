// src/services/exec.service.js
import { api } from './http'

/**
 * Executa uma procedure via /exec/:procedure
 * Aceita payload em modo JSON (primeiro item com { ic_json_parametro: 'S' }) ou em pares nome/valor.
 * @param {string} procedure
 * @param {object|array} payload
 * @param {{ banco?: string }} opt
 * Qualquer procedure do SQL SERVER 
  
*/

export async function execProcedure(procedure, payload, { banco, ...cfg } = {}) {
  const url = `/exec/${(procedure || '').trim()}`
  const headers = banco ? { 'x-banco': banco, ...(cfg.headers || {}) } : cfg.headers
  const { data } = await api.post(url, payload, { ...cfg, headers });
  console.log(`Banco/ExecProcedure: ${procedure}`, payload, data, cfg);
  return data
}

/**
 * Execução por menu: /exec/menu/:cd_menu { parametros: { ... } }
 */
export async function execPorMenu(cd_menu, parametros, cfg = {}) {
  const { data } = await api.post(`/exec/menu/${cd_menu}`, { parametros }, cfg)
  return data
}
