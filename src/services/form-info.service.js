import { api } from './http'

/** Carrega metadados/atributos de formulário */
export async function getFormularioAtributo(payload) {
  const { data } = await api.post('/formulario-atributo', payload)
  return data
}

/** Salva/atualiza dados do formulário especial (pr_egis_api_crud_dados_especial) */
export async function salvarDadosForm(payload, cfg = {}) {
  const { data } = await api.post('/api-dados-form', payload, {
    headers: { 'Content-Type': 'application/json' },
    ...cfg
  })
  return data
}

/** Busca um registro único via pr_egis_pesquisa_tabela_registro */
export async function getRegistroDados(payload) {
  const { data } = await api.post('/tabela-registro-dados', payload)
  return data
}

/** Payload “genérico” de tabela (pr_egis_payload_tabela) */
export async function getPayloadTabela(payload) {
  const { data } = await api.post('/payload-tabela', payload)
  return data
}
