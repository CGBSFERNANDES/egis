// src/utils/pdfExport.js
// Requer: npm i jspdf jspdf-autotable
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'

// -- helpers bem simples (não alteram suas funções existentes) --
const toBR = (d) => {
  if (!d) return ''
  // aceita Date, 'YYYY-MM-DD', 'YYYY-MM-DDTHH:mm:ssZ', 'DD/MM/YYYY'
  if (d instanceof Date) {
    const dd = String(d.getDate()).padStart(2, '0')
    const mm = String(d.getMonth() + 1).padStart(2, '0')
    const yyyy = d.getFullYear()
    return `${dd}/${mm}/${yyyy}`
  }
  if (/^\d{2}\/\d{2}\/\d{4}$/.test(d)) return d
  try {
    const dt = new Date(d)
    if (!isNaN(dt)) return toBR(dt)
  } catch (_) {}
  return String(d)
}

const moneyBR = v => {
  const n = Number(String(v).replace(',', '.'))
  if (Number.isFinite(n)) {
    return n.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
  }
  return v ?? ''
}

async function fetchAsBase64(url) {
  try {
    const res = await fetch(url, { cache: 'no-store' })
    const blob = await res.blob()
    return await new Promise((resolve) => {
      const reader = new FileReader()
      reader.onload = () => resolve(reader.result)
      reader.readAsDataURL(blob)
    })
  } catch {
    return null
  }
}

/**
 * Exporta PDF com cabeçalho + período + tabela + totais + rodapé.
 *
 * @param {{
 *  title: string,
 *  empresa: string,
 *  menu?: string|number,
 *  usuario?: string,
 *  dataInicial?: string|Date,
 *  dataFinal?: string|Date,
 *  columns: Array<{label:string, field:string, isCurrency?:boolean, width?:number}>,
 *  rows: Array<object>,
 *  summary?: Array<{label:string, value:any, isCurrency?:boolean}>,
 *  logoUrl?: string,               // opcional
 *  fileName?: string               // 'relatorio.pdf' default
 * }} cfg
 */
export async function exportGridToPDF(cfg) {
  const {
    title,
    empresa,
    menu,
    usuario,
    dataInicial,
    dataFinal,
    columns = [],
    rows = [],
    summary = [],
    logoUrl,
    fileName = 'relatorio.pdf'
  } = cfg

  if (!rows.length) throw new Error('Sem dados para exportar.')

  const doc = new jsPDF({ orientation: 'landscape', unit: 'pt', format: 'a4' })
  const pageW = doc.internal.pageSize.getWidth()

  // ========== Cabeçalho ==========
  const margin = 28
  let y = margin

  // Logo (quando houver)
  if (logoUrl) {
    const b64 = await fetchAsBase64(logoUrl)
    if (b64) {
      const h = 32
      const w = h * 3.1 // logo retangular
      doc.addImage(b64, 'PNG', margin, y, w, h)
    }
  }

  doc.setFont('helvetica', 'bold')
  doc.setFontSize(20)
  doc.text(title || 'Relatório', margin + 120, y + 22)

  // linha de metadados
  doc.setFont('helvetica', 'normal')
  doc.setFontSize(11)
  y += 45
  const meta = [
    `Empresa: ${empresa || '-'}`,
    menu != null ? `Menu: ${menu}` : null,
    usuario ? `Usuário: ${usuario}` : null,
    `Data/Hora: ${toBR(new Date())} ${new Date().toLocaleTimeString('pt-BR')}`
  ].filter(Boolean).join('  •  ')
  doc.text(meta, margin, y)

  // linha do período
  y += 18
  if (dataInicial || dataFinal) {
    const periodo = `Data Inicial: ${toBR(dataInicial)}   |   Data Final: ${toBR(dataFinal)}`
    doc.text(periodo, margin, y)
  }

  // ========== Tabela ==========
  const head = [columns.map(c => c.label || c.field)]
  const body = rows.map(r =>
    columns.map(c => {
      const raw = r[c.field]
      if (c.isCurrency) return moneyBR(raw)
      // data detectada por nome (Opcional)
      if (/^dt_|_data|emissao|entrega/i.test(c.field)) return toBR(raw)
      return raw == null ? '' : String(raw)
    })
  )

  const colStyles = {}
  columns.forEach((c, idx) => {
    if (c.width) colStyles[idx] = { cellWidth: c.width }
    if (c.isCurrency) {
      colStyles[idx] = { ...(colStyles[idx] || {}), halign: 'right' }
    }
  })

  autoTable(doc, {
    head,
    body,
    startY: y + 12,
    styles: { fontSize: 9, cellPadding: 4, overflow: 'linebreak' },
    headStyles: { fillColor: [245, 245, 245] },
    columnStyles: colStyles,
    theme: 'striped',
    didDrawPage: (data) => {
      // rodapé: numeração
      const str = `Página ${doc.internal.getNumberOfPages()}`
      doc.setFontSize(9)
      doc.text(str, pageW - margin - doc.getTextWidth(str), doc.internal.pageSize.getHeight() - 10)
    }
  })

  // ========== Totais / Resumo ==========
  const lastY = doc.lastAutoTable.finalY || (y + 50)
  if (summary && summary.length) {
    const sumHead = [['Resumo', 'Valor']]
    const sumBody = summary.map(s => [
      s.label,
      s.isCurrency ? moneyBR(s.value) : (s.value ?? '')
    ])
    autoTable(doc, {
      head: sumHead,
      body: sumBody,
      startY: lastY + 12,
      styles: { fontSize: 10, cellPadding: 4 },
      headStyles: { fillColor: [235, 235, 235] },
      columnStyles: { 1: { halign: 'right' } },
      theme: 'grid'
    })
  }

  doc.save(fileName)
}
