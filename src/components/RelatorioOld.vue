<template>
  <div class="rel-wrapper q-pa-md">
    <!-- Barra de ações -->
    <div class="rel-toolbar q-mb-md" v-if="showToolbar">
      <q-btn dense color="primary" icon="picture_as_pdf" label="PDF" @click="exportarPDF"/>
      <q-btn dense flat  color="primary" icon="grid_on" label="Excel" class="q-ml-sm" @click="exportarExcel"/>
    </div>

    <div id="relatorio-completo">
      <header class="cabecalho row no-wrap items-center q-mb-md">
        <img :src="logoEmpresa" alt="Logo" class="logo q-mr-md" />
        <div class="col">
          <div class="text-h6">{{ tituloRelatorio }}</div>
          <div class="row q-col-gutter-md q-mt-xs">
            <div class="col-auto"><b>Empresa:</b> {{ nomeEmpresa }} ({{ empresa }})</div>
            <div class="col-auto"><b>Menu:</b> {{ cdMenu }}</div>
            <div class="col-auto"><b>Usuário:</b> {{ usuario }}</div>
            <div class="col-auto"><b>Data/Hora:</b> {{ dataHora }}</div>
          </div>
        </div>
      </header>

      <section id="conteudo-relatorio">
        <table class="rel-table">
          <thead>
            <tr>
              <th v-for="col in colunas" :key="col">{{ titulos[col] || col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row,ri) in dadosFmt" :key="ri">
              <td v-for="col in colunas" :key="col">
                {{ formatarCelula(row[col], col) }}
              </td>
            </tr>
          </tbody>
        </table>
      </section>
    </div>
  </div>
</template>

<script>
// Vue 2
import * as XLSX from 'xlsx'
import html2pdf from 'html2pdf.js'

/**
 * Utilidades de formatação (espelhando relatorio.js)
 */
function isIsoDateTimeStr(v) {
  return typeof v === 'string' && /^\d{4}-\d{2}-\d{2}T/.test(v)
}

export default {
  name: 'Relatorio',
  props: {
    // dados da tabela (se não vier, tenta sessionStorage)
    dados: { type: Array, default: null },
    // meta dos campos (para títulos/formatos). Se não vier, tenta sessionStorage pelo cdMenu
    meta:  { type: Array, default: null },
    // parâmetros do cabeçalho
    cdMenu:     { type: [String, Number], default: null },
    empresa:    { type: [String, Number], default: null },
    usuario:    { type: String, default: null },
    nomeEmpresa:{ type: String, default: null },
    logoEmpresa:{ type: String, default: null },
    titulo:     { type: String, default: null },
    showToolbar:{ type: Boolean, default: true }
  },

  data() {
    return {
      dadosFmt: [],
      colunas: [],
      titulos: {},
      camposCurrency: new Set(),
      dataHora: new Date().toLocaleString('pt-BR')
    }
  },

  computed: {
    tituloRelatorio() {
      if (this.titulo) return this.titulo
      const tMeta = this.metaEfetiva?.[0]?.nm_titulo
      const tSess = sessionStorage.getItem('menu_titulo')
      return tMeta || tSess || 'Relatório de Dados'
    },

    metaEfetiva() {
      if (Array.isArray(this.meta) && this.meta.length) return this.meta
      const key = `campos_grid_meta_${this.cdMenuEfetivo}`
      const s = sessionStorage.getItem(key)
      return s ? JSON.parse(s) : []
    },

    cdMenuEfetivo() {
      if (this.cdMenu) return this.cdMenu
      return sessionStorage.getItem('cd_menu_relatorio') ||
             sessionStorage.getItem('cd_menu') || ''
    },

    empresaEfetiva() {
      return this.empresa || sessionStorage.getItem('cd_empresa') || ''
    },

    usuarioEfetivo() {
      if (this.usuario) return this.usuario
      const u = sessionStorage.getItem('cd_usuario')
      const n = sessionStorage.getItem('usuario')
      return (u && n) ? `${u} - ${n}` : (n || '')
    },

    nomeEmpresaEfetiva() {
      return this.nomeEmpresa ||
             sessionStorage.getItem('nm_fantasia_empresa') ||
             sessionStorage.getItem('nm_empresa') ||
             'Empresa'
    },

    logoEmpresaEfetiva() {
      return this.logoEmpresa || sessionStorage.getItem('imageUrl') || '/img/logo.png'
    }
  },

  created() {
    // 1) dados
    const dadosIn = Array.isArray(this.dados)
      ? this.dados
      : JSON.parse(sessionStorage.getItem('dados_resultado_consulta') || '[]')

    // 2) meta p/ títulos e currency
    const meta = this.metaEfetiva

    const titulos = {}
    const currencyCols = []
    meta.forEach(c => {
      const key = c.nm_atributo_consulta || c.nm_atributo
      titulos[key] = c.nm_titulo_menu_atributo || c.nm_edit_label || key
      if ((c.nm_datatype || '').toLowerCase() === 'currency') currencyCols.push(key)
    })
    this.titulos = titulos
    this.camposCurrency = new Set(currencyCols)

    // 3) colunas (do primeiro item)
    this.colunas = dadosIn.length ? Object.keys(dadosIn[0]) : []

    // 4) formatação mínima (datas ISO → locale)
    this.dadosFmt = dadosIn.map(r => ({ ...r }))
  },

  methods: {
    formatarCelula(valor, coluna) {
      if (valor == null) return ''
      if (isIsoDateTimeStr(valor)) {
        return new Date(valor).toLocaleDateString('pt-BR')
      }
      if (this.camposCurrency.has(coluna) && typeof valor === 'number') {
        return valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
      }
      return valor
    },

    async exportarPDF() {
      const el = document.getElementById('relatorio-completo')
      const opt = {
        margin: 0.5,
        filename: 'relatorio.pdf',
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: { scale: 2 },
        jsPDF: { unit: 'in', format: 'a4', orientation: 'portrait' }
      }
      await html2pdf().set(opt).from(el).save()
    },

    exportarExcel() {
      const dados = this.dadosFmt
      if (!Array.isArray(dados) || dados.length === 0) {
        this.$q?.notify?.({ type: 'warning', message: 'Nenhum dado para exportar.', position: 'top-right' })
        return
      }
      const ws = XLSX.utils.json_to_sheet(dados)
      const wb = XLSX.utils.book_new()
      XLSX.utils.book_append_sheet(wb, ws, 'Relatório')
      XLSX.writeFile(wb, 'relatorio.xlsx')
    }
  },

  // “getters” simples para o template (evita computed no HTML)
  // (deixei assim para clareza & compatibilidade)
  mounted() {
    this.empresa = this.empresaEfetiva
    this.usuario = this.usuarioEfetivo
    this.nomeEmpresa = this.nomeEmpresaEfetiva
    this.logoEmpresa = this.logoEmpresaEfetiva
    this.cdMenu = this.cdMenuEfetivo
  }
}
</script>

<style scoped>
.rel-wrapper { background: #fff; }
.logo { width: 80px; height: auto; }
.rel-table { width: 100%; border-collapse: collapse; }
.rel-table th, .rel-table td { border: 1px solid #ddd; padding: 6px 8px; font-size: 12px; }
.rel-table thead th { background: #f5f5f5; text-align: left; }
</style>
