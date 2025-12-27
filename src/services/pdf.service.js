import { api } from './http'

/** Gera um PDF no servidor a partir de dados tabulares e abre em nova aba */
export async function gerarPdfRelatorio({ cd_menu, cd_usuario, dados }) {
  const resp = await api.post('/relatorio', { cd_menu, cd_usuario, dados }, { responseType: 'blob' })
  const blob = new Blob([resp.data], { type: 'application/pdf' })
  const url = URL.createObjectURL(blob)
  window.open(url, '_blank')
  return url // caso você queira gerenciar o revoke depois
}
