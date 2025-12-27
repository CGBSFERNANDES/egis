import { api } from './http'

/** Importa um array de objetos para uma tabela física no SQL (DROP/CREATE/INSERT) */
export async function importarExcelParaTabela({ nome_tabela, dados }) {
  const { data } = await api.post('/importar-excel-para-tabela', { nome_tabela, dados })
  return data
}

/** (cliente) Gera um .xlsx simples a partir de rows e salva pelo browser */
export async function exportarParaExcel({ rows, nomeArquivo = 'dados.xlsx' }) {
  const XLSX = (await import('xlsx')).default
  const ws = XLSX.utils.json_to_sheet(rows || [])
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Dados')
  XLSX.writeFile(wb, nomeArquivo)
}
