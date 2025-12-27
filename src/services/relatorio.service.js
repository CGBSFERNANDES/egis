import { api } from './http'

/** Catálogo de relatórios por módulo/menu/usuário */
export async function getCatalogoRelatorio(payload) {
  const { data } = await api.post('/catalogo-relatorio', payload)
  return data
}

/** Gera dados de relatório padrão (pr_egis_relatorio_padrao) */
export async function gerarRelatorioPadrao(payload) {
  const { data } = await api.post('/menu-relatorio', payload)
  //return data
  // ✅ backend pode retornar [ { RelatorioHTML } ] ou { RelatorioHTML }
  if (Array.isArray(data)) return data[0] || null
  return data || null
}

export async function gerarRelatorioHTMLPadrao(payload) {
  try {
    this.load = true

    // chamada padrão do seu backend
    const [resp] = await Incluir.incluirRegistro(
      'menu-relatorio', // ou o endpoint correto que você já usa
      payload
    )

    if (!resp || !resp.RelatorioHTML) {
      throw new Error('RelatórioHTML não retornado')
    }

    // cria documento isolado
    const html = resp.RelatorioHTML

    const win = window.open('', '_blank')
    win.document.open()
    win.document.write(html)
    win.document.close()

    this.$q?.notify?.({
      type: 'positive',
      message: 'Relatório gerado com sucesso',
    })
  } catch (err) {
    console.error('Erro relatório HTML:', err)
    this.$q?.notify?.({
      type: 'negative',
      message: 'Não foi possível gerar o relatório',
    })
  } finally {
    this.load = false
  }
}
