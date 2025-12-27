<template>
  <q-card class="relatorio-card">
    <!-- Cabeçalho -->
    <q-card-section class="row items-center no-wrap q-gutter-sm">
      <img
        :src="resolvedLogoUrl"
        alt="logo"
        class="empresa-logo"
      />
      <div class="col">
        <div class="text-h6">{{ titulo || 'Relatório' }}</div>
        <div class="text-caption">
          Empresa: {{ resolvedEmpresaNome }}
          &nbsp;•&nbsp; Menu: {{ menuCodigo }}
          &nbsp;•&nbsp; Usuário: {{ usuarioNomeOuId }}
          &nbsp;•&nbsp; Data/Hora: {{ agoraBR }}
        </div>
      </div>
    </q-card-section>

    <!-- Tabela -->
    <q-separator/>
    <q-card-section class="q-pa-none">
      <div class="table-wrapper">
        <table class="rel-table">
          <thead>
            <tr>
              <th v-for="(c, i) in columns" :key="i">{{ c.caption || c.dataField }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(r, idx) in rows" :key="r.id || idx">
              <td v-for="(c, i) in columns" :key="i">
                {{ formatCell(r[c.dataField], c) }}
              </td>
            </tr>
          </tbody>
          <tfoot v-if="totais && totais.length">
            <tr>
              <td :colspan="totalColSpan" class="text-right">Totais:</td>
              <td v-for="(t, i) in totais" :key="i" class="text-right">
                {{ formatTotal(t) }}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </q-card-section>

    <!-- Rodapé com botões e paginação -->
    <q-separator/>
    <q-card-actions align="between" class="footer-actions no-print">
      <div class="text-caption text-grey-7">
        {{ resolvedEmpresaNome }}
      </div>
      <div class="q-gutter-sm">
        <q-btn dense color="negative" icon="picture_as_pdf" label="PDF" @click="emitirPDF"/>
        <q-btn dense color="primary"  icon="grid_on"        label="EXCEL" @click="emitirExcel"/>
      </div>
    </q-card-actions>

    <!-- Rodapé “print” -->
    <div class="print-footer only-print">
      <span>{{ resolvedEmpresaNome }}</span>
      <span class="page">Página </span>
    </div>
  </q-card>
</template>

<script>
export default {
  name: 'Relatorio',

  /* 1) NÃO use os mesmos nomes em props e computed.  */
  props: {
    titulo: { type: String, default: '' },

    /* renomeadas */
    empresaNomeProp: { type: String, default: '' },
    logoUrlProp:     { type: String, default: '' },

    /* dados do relatório */
    columns: { type: Array,  default: () => [] },
    rows:    { type: Array,  default: () => [] },
    totais:  { type: Array,  default: () => [] }, // ex.: [{ label:'Total R$', value: 123.45 }]

    // metadados opcionais
    menuCodigo:      { type: [String, Number], default: '' },
    usuarioNomeOuId: { type: String, default: '' },
  },

  computed: {
    /* 2) Computed “resolved” usando as props ou storages (fallback) */
    resolvedEmpresaNome() {
      return (
        this.empresaNomeProp ||
        localStorage.fantasia ||
        localStorage.empresa || 'Empresa'
      );
    },

    resolvedLogoUrl() {
        const xlogo =   'https://egisnet.com.br/img/'+(this.logoUrlProp ||
        localStorage.nm_caminho_logo_empresa);
        
        console.log(xlogo);
      return ( xlogo );
    },

    agoraBR() {
      const d = new Date();
      const pad = n => String(n).padStart(2, '0');
      return `${pad(d.getDate())}/${pad(d.getMonth() + 1)}/${d.getFullYear()} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
    },

    totalColSpan() {
      // ocupa as colunas da tabela menos a quantidade de totais exibidos
      const qTotais = this.totais?.length || 0;
      const qCols   = this.columns?.length || 0;
      return Math.max(qCols - qTotais, 1);
    },
  },

  methods: {
    
    formatCell(value, col) {
  if (value == null || value === '') return ''

  // 1) detectar formato vindo do DevExtreme (pode ser objeto)
  const fmt = col?.format
  const fmtType = typeof fmt === 'object' ? String(fmt.type || '').toLowerCase() : String(fmt || '').toLowerCase()
  const dataType = String(col?.dataType || '').toLowerCase()

  // 2) helper: data sem shift de timezone
  const parseDateNoTZ = (v) => {
    if (!v) return v

    if (v instanceof Date) return v

    if (typeof v === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(v)) {
      return new Date(v + 'T00:00:00')
    }

    if (typeof v === 'string' && /^\d{4}-\d{2}-\d{2}t/i.test(v)) {
      const d = new Date(v)
      return new Date(d.getTime() + d.getTimezoneOffset() * 60000)
    }

    const d = new Date(v)
    return isNaN(d) ? v : d
  }

  // 3) currency
  if (fmtType === 'currency' || fmtType.includes('currency')) {
    const n = Number(value)
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' })
      .format(isNaN(n) ? 0 : n)
  }

  // 4) number
  if (dataType === 'number' || fmtType.includes('fixedpoint') || fmtType.includes('number')) {
    const n = Number(value)
    return new Intl.NumberFormat('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
      .format(isNaN(n) ? 0 : n)
  }

  // 5) date
  if (dataType === 'date' || fmtType.includes('date') || fmtType.includes('dd/mm')) {
    const d = parseDateNoTZ(value)
    if (!(d instanceof Date) || isNaN(d)) return value
    const pad = n => String(n).padStart(2, '0')
    return `${pad(d.getDate())}/${pad(d.getMonth() + 1)}/${d.getFullYear()}`
  }

  return value
},
formatTotal(t) {
  const v = t?.value ?? 0

  const fmt = t?.format
  const fmtType =
    fmt && typeof fmt === 'object'
      ? String(fmt.type || '').toLowerCase()
      : String(fmt || '').toLowerCase()

  const n = Number(v)
  const num = isNaN(n) ? 0 : n

  if (fmtType.includes('currency')) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(num)
  }

  // count geralmente é inteiro
  if (String(t?.tipo || '').toLowerCase() === 'count') {
    return String(Math.trunc(num))
  }

  return new Intl.NumberFormat('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(num)
},

  
    emitirPDF()   { this.$emit('pdf');   },
    emitirExcel() { this.$emit('excel'); },
    
  },
};
</script>

<style scoped>
.relatorio-card { min-width: 980px; }
.empresa-logo   { height: 42px; width: auto; object-fit: contain; margin-right: 8px; }
.table-wrapper  { overflow: auto; }
.rel-table      { width: 100%; border-collapse: collapse; font-size: 12px; }
.rel-table th,
.rel-table td    { border: 1px solid #e0e0e0; padding: 6px 8px; }
.rel-table thead th { background: #fafafa; font-weight: 600; }
.text-right     { text-align: right; }
.footer-actions { padding: 8px 12px; }

.only-print { display: none; }
.no-print   { display: block; }

@media print {
  .no-print   { display: none !important; }
  .only-print { display: flex !important; }

  /* Rodapé fixo com numeração de páginas (Chrome/Edge) */
  .print-footer{
    position: fixed;
    bottom: 0;
    left: 0; right: 0;
    padding: 6px 12px;
    border-top: 1px solid #ccc;
    font-size: 11px;
    display: flex; justify-content: space-between;
  }
  .print-footer .page:after { content: counter(page); }
}
</style>
