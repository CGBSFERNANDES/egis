<template>
  <div class="dashboard-dinamico q-gutter-md">

<div class="row items-center justify-between q-mb-sm">
  <div class="row items-center q-gutter-sm">

    <!-- Botão voltar -->
    <q-btn
      dense
      round
      flat
      icon="arrow_back"
      @click="onVoltar"
    />

    <!-- Título + chip, igual ao únicoForm -->
    <div class="column">
      <div class="row items-center q-gutter-sm">
        <h5 class="q-my-none">{{ titulo }}</h5>

      </div>

      <div 
        class="text-caption text-grey-7" style="margin-left: 5px">
        {{ (rows || []).length }} registros • {{ (columns || []).length }} colunas
      </div>
    </div>
  </div>

  <!-- Controles de Dimensão / Métrica / Agregação -->
  <div class="col-auto row items-center q-gutter-sm">
    <q-select
      dense outlined
      v-model="dim"
      :options="dimOptions"
      label="Dimensão (categoria/data)"
      style="min-width:220px"
    />
    <q-select
      dense outlined
      v-model="metrica"
      :options="metricaOptions"
      label="Métrica (numérica)"
      style="min-width:220px"
    />
    <q-select
      dense outlined
      v-model="agregacao"
      :options="['sum','avg','count','min','max']"
      label="Agregação"
      style="min-width:140px"
    />
    <q-btn dense color="primary" icon="refresh" @click="desenharTodos" label="APLICAR" />
  </div>
</div>


    <!-- KPIs -->
    <div class="row q-col-gutter-md">
      <div class="col-12 col-sm-6 col-md-3" v-for="(kpi, i) in kpis" :key="i">
        <q-card flat bordered class="q-pa-md">
          <div class="text-caption text-grey-7">{{ kpi.label }}</div>
          <div class="text-h6">{{ kpi.value }}</div>
        </q-card>
      </div>
    </div>

    <!-- Gráficos -->
    <div class="row q-col-gutter-md q-mt-md">
      <div class="col-12 col-md-6">
        <q-card flat bordered class="q-pa-sm">
          <div class="text-subtitle1 q-mb-xs">Barras por Dimensão</div>
          <canvas ref="chartBar"></canvas>
        </q-card>
      </div>
      <div class="col-12 col-md-6">
        <q-card flat bordered class="q-pa-sm">
          <div class="text-subtitle1 q-mb-xs">(Top 5)</div>
          <canvas ref="chartPie"></canvas>
        </q-card>
      </div>
      <div class="col-12 col-md-6">
        <q-card flat bordered class="q-pa-sm">
          <div class="text-subtitle1 q-mb-xs">Série Temporal</div>
          <canvas ref="chartLine"></canvas>
        </q-card>
      </div>
      <div class="col-12 col-md-6">
        <q-card flat bordered class="q-pa-sm">
          <div class="text-subtitle1 q-mb-xs">Dispersão (2 métricas)</div>
          <div class="row q-gutter-sm q-mb-sm">
            <q-select dense outlined v-model="metricaX" :options="metricaOptions" label="Eixo X" style="min-width:160px"/>
            <q-select dense outlined v-model="metricaY" :options="metricaOptions" label="Eixo Y" style="min-width:160px"/>
          </div>
          <canvas ref="chartScatter"></canvas>
        </q-card>
      </div>
    </div>
  </div>
</template>

<script>
const CDN_CHART = 'https://cdn.jsdelivr.net/npm/chart.js' // Chart.js v3+


export default {
  name: 'DashboardDinamico',
  props: {
    rows: { type: Array, default: () => [] },
    columns: { type: Array, default: () => [] },
    titulo: { type: String, default: 'Dashboard' },
    cdMenu:  { type: [Number, String], default: null },
    returnTo: { type: String, default: '' }
  },
  data () {
    return {
      dim: null,             // coluna categórica/data
      metrica: null,         // coluna numérica
      agregacao: 'sum',      // sum | avg | count | min | max
      metricaX: null,        // scatter
      metricaY: null,
      charts: { bar:null, pie:null, line:null, scatter:null },
      kpis: []
    }
  },
  computed: {
    dimOptions () {
      const cols = this.columns || []
      const exemplo = this.rows[0] || {}
      return cols.filter(c => {
        const k = String(c)
        const v = exemplo[k]
        if (v == null) return false
        // heurística: string/data vira dimensão
        if (typeof v === 'string') return true
        if (v instanceof Date) return true
        // data em string
        if (/^\d{4}-\d{2}-\d{2}/.test(String(v)) || /^\d{2}[\/-]\d{2}[\/-]\d{4}$/.test(String(v))) return true
        return false
      })
    },
    metricaOptions () {
      const cols = this.columns || []
      const exemplo = this.rows[0] || {}
      return cols.filter(c => {
        const v = exemplo[String(c)]
        return typeof v === 'number' || /^\d+[.,]?\d*$/.test(String(v || ''))
      })
    }
  },
  async mounted () {
      
      console.log('[dashboardDinamico] mounted - rows recebidas:', (this.rows || []).length)
      console.log('[dashboardDinamico] primeiros rows:', (this.rows || []).slice(0, 3))
      console.log('[dashboardDinamico] columns recebidas:', this.columns)

    await this.ensureChartJs()

    this.sugerirDimensaoMetrica()
    this.calcularKPIs()
    this.desenharTodos()
  },
  beforeDestroy () { this.destroyCharts() },
  watch: {
    rows () {
      console.log('[dashboardDinamico] rows mudou, novo length:', (this.rows || []).length)

      this.sugerirDimensaoMetrica()
      this.calcularKPIs()
      this.desenharTodos()
    }
  },
  methods: {
    onVoltar () {
      // 1) Se o pai estiver ouvindo o evento "voltar" (caso do QDialog no unicoFormEspecial)
      if (this.$listeners && this.$listeners.voltar) {
        this.$emit('voltar')
        return
      }

       // se tiver return explícito, volta pra ele
       if (this.returnTo) {
         this.$router.push(this.returnTo)
         return
        }

        // 2) Se NÃO tiver listener (tela aberta como rota), usa o histórico do router
        if (this.$router && window.history.length > 1) {
          this.$router.back()
          return
        }

        // fallback
        if (this.$router && window.history.length > 1) {
           this.$router.back()
           return
        }

        // 3) Fallback: vai pra rota do form (ajuste o name se for diferente)
        this.$router.push({ name: 'unicoFormEspecial' })
        //

    },

     formatDimensaoLabel (valor) {
        
       if (valor == null || valor === '') return ''

       // se já vier como Date
       if (valor instanceof Date && !isNaN(valor.getTime())) {
         return valor.toLocaleDateString('pt-BR')
       }

    if (typeof valor === 'string') {
      // pega só a parte da data se vier no padrão 2025-12-11T00:00:00.000Z
      const isoMatch = /^(\d{4})-(\d{2})-(\d{2})/.exec(valor)
      if (isoMatch) {
        const [, yyyy, mm, dd] = isoMatch
        return `${dd}/${mm}/${yyyy}` // 11/12/2025
      }

      // tenta converter qualquer outra string de data
      const d = new Date(valor)
      if (!isNaN(d.getTime())) {
        return d.toLocaleDateString('pt-BR')
      }

      // não parece data, devolve como está
      return valor
    }

    // número ou outra coisa: tenta converter
    const d = new Date(valor)
    if (!isNaN(d.getTime())) {
      return d.toLocaleDateString('pt-BR')
    }

    return String(valor)
  },

    async ensureChartJs () {
      if (window.Chart) return
      await new Promise((resolve, reject) => {
        const s = document.createElement('script')
        s.src = CDN_CHART
        s.onload = resolve
        s.onerror = reject
        document.head.appendChild(s)
      })
    },
    destroyCharts () {
      Object.keys(this.charts).forEach(k => { const c = this.charts[k]; if (c && c.destroy) c.destroy() })
      this.charts = { bar:null, pie:null, line:null, scatter:null }
    },
    sugerirDimensaoMetrica () {
      // dimensão: 1ª string/data; métrica: 1º número
      if (!this.dim)     this.dim     = this.dimOptions[0] || null
      if (!this.metrica) this.metrica = this.metricaOptions[0] || null
      if (!this.metricaX) this.metricaX = this.metricaOptions[0] || null
      if (!this.metricaY) this.metricaY = this.metricaOptions[1] || this.metricaOptions[0] || null
    },
    calcularKPIs () {
      const totalLinhas = (this.rows || []).length
      const m = this.metrica
      let soma = 0
      if (m) {
        for (const r of this.rows) {
          const v = Number((r[m] + '').replace(',', '.'))
          soma += (isFinite(v) ? v : 0)
        }
      }
      this.kpis = [
        { label: 'Registros', value: totalLinhas.toLocaleString('pt-BR') },
        { label: `Soma de ${m || '-'}`, value: soma.toLocaleString('pt-BR') }
      ]
    },
    agregador (vals, modo) {
      if (modo === 'count') return vals.length
      if (modo === 'sum' || !modo) return vals.reduce((a,b)=>a+b,0)
      if (modo === 'avg') return vals.reduce((a,b)=>a+b,0) / (vals.length || 1)
      if (modo === 'min') return Math.min.apply(null, vals)
      if (modo === 'max') return Math.max.apply(null, vals)
      return 0
    },
    groupBy (rows, keyField, valueField) {
      const map = {}
      rows.forEach(r => {
        const k = String(r[keyField])
        const v = Number((r[valueField] + '').replace(',', '.'))
        if (!map[k]) map[k] = []
        if (isFinite(v)) map[k].push(v)
      })
      return map
    },
    parseDate (v) {
      if (v instanceof Date) return v
      const s = String(v)
      if (/^\d{4}-\d{2}-\d{2}/.test(s)) return new Date(s.substring(0,10))
      const m = s.match(/^(\d{2})[\/-](\d{2})[\/-](\d{4})/)
      if (m) {
        const [_, d, mm, y] = m
        return new Date(`${y}-${mm}-${d}`)
      }
      return null
    },
    
    desenharTodos () {
  this.destroyCharts()
  if (!this.rows || !this.rows.length) return

  // 1) Barras por dimensão
  if (this.dim && this.metrica) {
    const map = this.groupBy(this.rows, this.dim, this.metrica)

    // chaves cruas
    const rawLabels = Object.keys(map)

    // dados calculados com as chaves cruas
    const data = rawLabels.map(k => this.agregador(map[k], this.agregacao))

    // labels formatados (datas bonitinhas, etc.)
    const labels = rawLabels.map(k => this.formatDimensaoLabel(k))

    const ctx = this.$refs.chartBar.getContext('2d')
    this.charts.bar = new window.Chart(ctx, {
      type: 'bar',
      data: {
        labels,
        datasets: [{
          label: `${this.agregacao}(${this.metrica}) por ${this.dim}`,
          data
        }]
      },
      options: {
        responsive: true,
        plugins: { legend:{ display: true } },
        scales: { y: { beginAtZero: true } }
      }
    })

    // 2) Pizza Top 5
    const pares = rawLabels
      .map((k,i) => ({ k, v: data[i] }))
      .sort((a,b)=>b.v-a.v)
      .slice(0,5)

    const ctxP = this.$refs.chartPie.getContext('2d')
    this.charts.pie = new window.Chart(ctxP, {
      type: 'pie',
      data: {
        labels: pares.map(p => this.formatDimensaoLabel(p.k)), // formatado aqui
        datasets: [{ data: pares.map(p=>p.v) }]
      },
      options: { responsive: true }
    })
  }

  // 3) Série temporal (se a dimensão for data)
  if (this.dim) {
    const isDate = (r) => !!this.parseDate(r[this.dim])
    const rowsDate = this.rows.filter(isDate)
    if (rowsDate.length && this.metrica) {
      const byDay = {}
      rowsDate.forEach(r => {
        const d = this.parseDate(r[this.dim])
        if (!d) return
        const key = d.toISOString().substring(0,10) // yyyy-mm-dd (cru)
        const v = Number((r[this.metrica] + '').replace(',', '.'))
        if (!byDay[key]) byDay[key] = []
        if (isFinite(v)) byDay[key].push(v)
      })

      // chaves cruas
      const rawLabels = Object.keys(byDay).sort()

      // dados
      const data = rawLabels.map(k => this.agregador(byDay[k], this.agregacao))

      // labels formatados para o gráfico
      const labels = rawLabels.map(k => this.formatDimensaoLabel(k))

      const ctxL = this.$refs.chartLine.getContext('2d')
      this.charts.line = new window.Chart(ctxL, {
        type: 'line',
        data: {
          labels,
          datasets: [{
            label: `${this.agregacao}(${this.metrica})`,
            data,
            fill:false
          }]
        },
        options: { responsive: true, scales: { y: { beginAtZero: true } } }
      })
    }
  }

  // 4) Dispersão (metricaX x metricaY)
  if (this.metricaX && this.metricaY) {
    const pontos = this.rows.map(r => {
      const x = Number((r[this.metricaX] + '').replace(',', '.'))
      const y = Number((r[this.metricaY] + '').replace(',', '.'))
      return (isFinite(x) && isFinite(y)) ? { x, y } : null
    }).filter(Boolean)
    const ctxS = this.$refs.chartScatter.getContext('2d')
    this.charts.scatter = new window.Chart(ctxS, {
      type: 'scatter',
      data: { datasets: [{ label: `${this.metricaX} x ${this.metricaY}`, data: pontos }] },
      options: { responsive: true }
    })
  }

  // KPIs
  this.calcularKPIs()
},

    desenharTodosold () {
      this.destroyCharts()
      if (!this.rows || !this.rows.length) return

      // 1) Barras por dimensão
      if (this.dim && this.metrica) {
        const map = this.groupBy(this.rows, this.dim, this.metrica)
        const labels = Object.keys(map)
        const data = labels.map(k => this.agregador(map[k], this.agregacao))
        const ctx = this.$refs.chartBar.getContext('2d')
        this.charts.bar = new window.Chart(ctx, {
          type: 'bar',
          data: { labels, datasets: [{ label: `${this.agregacao}(${this.metrica}) por ${this.dim}`, data }] },
          options: { responsive: true, plugins: { legend:{ display: true } }, scales: { y: { beginAtZero: true } } }
        })

        // 2) Pizza Top 5
        const pares = labels.map((k,i) => ({ k, v: data[i] })).sort((a,b)=>b.v-a.v).slice(0,5)
        const ctxP = this.$refs.chartPie.getContext('2d')
        this.charts.pie = new window.Chart(ctxP, {
          type: 'pie',
          data: { labels: pares.map(p=>p.k), datasets: [{ data: pares.map(p=>p.v) }] },
          options: { responsive: true }
        })
      }

      // 3) Série temporal (se a dimensão for data)
      if (this.dim) {
        const isDate = (r) => !!this.parseDate(r[this.dim])
        const rowsDate = this.rows.filter(isDate)
        if (rowsDate.length && this.metrica) {
          const byDay = {}
          rowsDate.forEach(r => {
            const d = this.parseDate(r[this.dim])
            if (!d) return
            const key = d.toISOString().substring(0,10)
            const v = Number((r[this.metrica] + '').replace(',', '.'))
            if (!byDay[key]) byDay[key] = []
            if (isFinite(v)) byDay[key].push(v)
          })
          const labels = Object.keys(byDay).sort()
          const data = labels.map(k => this.agregador(byDay[k], this.agregacao))
          const ctxL = this.$refs.chartLine.getContext('2d')
          this.charts.line = new window.Chart(ctxL, {
            type: 'line',
            data: { labels, datasets: [{ label: `${this.agregacao}(${this.metrica})`, data, fill:false }] },
            options: { responsive: true, scales: { y: { beginAtZero: true } } }
          })
        }
      }

      // 4) Dispersão (metricaX x metricaY)
      if (this.metricaX && this.metricaY) {
        const pontos = this.rows.map(r => {
          const x = Number((r[this.metricaX] + '').replace(',', '.'))
          const y = Number((r[this.metricaY] + '').replace(',', '.'))
          return (isFinite(x) && isFinite(y)) ? { x, y } : null
        }).filter(Boolean)
        const ctxS = this.$refs.chartScatter.getContext('2d')
        this.charts.scatter = new window.Chart(ctxS, {
          type: 'scatter',
          data: { datasets: [{ label: `${this.metricaX} x ${this.metricaY}`, data: pontos }] },
          options: { responsive: true }
        })
      }

      // KPIs
      this.calcularKPIs()
    }
  }
}
</script>

<style scoped>
.dashboard-dinamico canvas { width:100% !important; height: 300px !important; }
</style>
