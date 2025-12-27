import { api } from './http'

export async function lookup(query, opt = {}) {
  const { banco, ...cfg } = opt || {}
  const body = banco ? { query, banco } : { query }
  const { data } = await api.post('/lookup', body, cfg)
  return data
}

/** Executa qualquer procedure (payload array com ic_json_parametro = 'S' também é aceito) */
export async function execProcedure(nome_procedure, payload, opt = {}) {
  const { headers, ...cfg } = opt || {}
  const { data } = await api.post(`/exec/${(nome_procedure || '').trim()}`, payload, {
    headers,
    ...cfg
  })
  return data
}
