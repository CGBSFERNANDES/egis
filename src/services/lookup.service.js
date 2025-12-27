// src/services/lookup.service.js
import { api } from './http'

/**
 * Executa SQL direto via /lookup
 * @param {string} query - SELECT ...
 * @param {{ banco?: string }} opt
 */
export async function lookup(query, { banco, ...cfg } = {}) {
  const body = banco ? { query, banco } : { query }
  const { data } = await api.post('/lookup', body, cfg)
  return data
}
