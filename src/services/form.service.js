// src/services/form.service.js
import { api } from './http'

/** POST /api-dados-form → pr_egis_api_crud_dados_especial */
export async function salvarDadosForm(payload, opt = {}) {
  const { data } = await api.post('/api-dados-form', payload, {
    headers: { 'Content-Type': 'application/json' }, // reforça seu caso
    ...opt
  })
  return data
}

/** POST /formulario-atributo → pr_egis_formulario_atributo */
export async function formularioAtributo(payload, opt = {}) {
  const { data } = await api.post('/formulario-atributo', payload, opt)
  return data
}
