<template>
  <div class="kamban-wrapper">
    <div class="toolbar">
      <select v-model="selectedMetodo" @change="buildColumns()">
        <option :value="0">Todos os métodos</option>
        <option v-for="m in metodos" :key="m.cd_metodo" :value="m.cd_metodo">
          {{ m.nm_metodo }}
        </option>
      </select>

      <div class="dates">
        <input type="date" v-model="filtro.dt_inicial" @change="loadEtapasECards()" />
        <input type="date" v-model="filtro.dt_final" @change="loadEtapasECards()" />
      </div>
    </div>

    <div class="board" v-if="columns.length">
      <div
        class="column"
        v-for="col in columns"
        :key="col.cd_etapa"
      >
        <div class="column-header">
          <h3>{{ col.nm_etapa }}</h3>
          <small>{{ (cardsByEtapa[col.cd_etapa] || []).length }} cards</small>
        </div>

        <draggable
          class="cards"
          :list="cardsByEtapa[col.cd_etapa]"
          group="kamban"
          @end="evt => onCardMoved(evt, col)"
        >
          <div class="card" v-for="card in cardsByEtapa[col.cd_etapa]" :key="card.cd_movimento">
            <div class="card-title">
              <strong>#{{ card.cd_movimento }}</strong> — {{ card.nm_destinatario || '—' }}
            </div>
            <div class="card-sub">
              <span>{{ card.dt_movimento }}</span>
              <span v-if="card.sg_modulo"> · {{ card.sg_modulo }}</span>
            </div>
            <div class="card-meta">
              <span v-if="card.nm_contato">{{ card.nm_contato }}</span>
              <span v-if="card.vl_etapa"> · R$ {{ Number(card.vl_etapa).toLocaleString() }}</span>
            </div>
          </div>
        </draggable>
      </div>
    </div>

    <div v-else class="empty">Sem etapas para exibir.</div>

    <div v-if="loading" class="loading">Carregando...</div>
    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
import axios from 'axios'
import draggable from 'vuedraggable'

export default {
  name: 'dinamicoKambanProcesso',
  components: { draggable },
  props: {
    cdModulo: { type: Number, required: true }, // módulo alvo
    cdUsuario: { type: Number, required: true },
    cdModelo: { type: Number, default: 0 },     // se quiser variar “modelos” de funil
    cdEmpresa: { type: Number, default: 0 },
    dtInicial: { type: String, default: '' },
    dtFinal: { type: String, default: '' }
  },
  data () {
    return {
      loading: false,
      error: '',
      metodos: [],
      etapas: [], // [{cd_metodo, nm_metodo, cd_etapa, nm_etapa, ...}]
      cardsRaw: [], // linhas com cd_etapa, nm_etapa, cd_movimento, etc.
      columns: [],
      cardsByEtapa: {},
      selectedMetodo: 0,
      filtro: {
        dt_inicial: this.dtInicial || this.isoTodayFirst(),
        dt_final: this.dtFinal || this.isoTodayLast()
      }
    }
  },
  mounted () {
    this.init()
  },
  methods: {
    isoTodayFirst () {
      const d = new Date()
      return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().substr(0, 10)
    },
    isoTodayLast () {
      const d = new Date()
      return new Date(d.getFullYear(), d.getMonth() + 1, 0).toISOString().substr(0, 10)
    },
    async init () {
      await this.loadMetodos()
      await this.loadEtapasECards()
    },
    async callProc (cd_parametro) {
      const payload = [{
        cd_empresa: this.cdEmpresa,
        cd_parametro,
        cd_usuario: this.cdUsuario,
        dt_inicial: this.filtro.dt_inicial,
        dt_final: this.filtro.dt_final,
        cd_modelo: this.cdModelo,
        cd_modulo: this.cdModulo
      }]
      const { data } = await axios.post(`/api/exec/pr_egis_kamban_processo`, payload)
      // A rota backend é a genérica /api/exec/:procedure
      return data
    },
    async loadMetodos () {
      try {
        this.loading = true
        const rows = await this.callProc(1)
        // Esperado: [{cd_metodo, nm_metodo, qt_ordem, nm_segmento, nm_modulo}]
        this.metodos = Array.isArray(rows) ? rows : []
        if (this.metodos.length) this.selectedMetodo = 0
      } catch (e) {
        this.error = 'Falha ao carregar métodos.'
      } finally {
        this.loading = false
      }
    },
    async loadEtapasECards () {
      try {
        this.loading = true
        const rows = await this.callProc(2)
        // Esperado (mínimo): [{cd_metodo, nm_metodo, nm_etapa, cd_etapa? opcional}]
        // Se a proc também retornar cards (estilo faturamento), devem vir colunas:
        // cd_etapa, nm_etapa, cd_movimento, dt_movimento, nm_destinatario, nm_contato, sg_modulo, vl_etapa...
        this.splitEtapasECards(rows)
        this.buildColumns()
      } catch (e) {
        this.error = 'Falha ao carregar etapas/cards.'
      } finally {
        this.loading = false
      }
    },
    splitEtapasECards (rows) {
      const isCard = r => r.cd_movimento !== undefined || r.dt_movimento !== undefined
      this.etapas = []
      this.cardsRaw = []

      for (const r of (rows || [])) {
        if (isCard(r)) this.cardsRaw.push(r)
        // Etapa pode vir repetida, vamos normalizar:
        const cd_etapa = r.cd_etapa || r.etapa || null
        if (r.nm_etapa && cd_etapa) {
          if (!this.etapas.find(e => e.cd_etapa === cd_etapa)) {
            this.etapas.push({
              cd_etapa,
              nm_etapa: r.nm_etapa,
              cd_metodo: r.cd_metodo || 0,
              nm_metodo: r.nm_metodo || ''
            })
          }
        }
      }
      // Caso a proc ainda não retorne cards, garante estrutura vazia:
      if (!this.cardsRaw.length) this.cardsRaw = []
    },
    buildColumns () {
      // Filtra etapas pelo método selecionado (0=Todos)
      const etapasFiltradas = this.selectedMetodo
        ? this.etapas.filter(e => e.cd_metodo === this.selectedMetodo)
        : this.etapas.slice().sort((a, b) => (a.qt_ordem || 0) - (b.qt_ordem || 0))

      this.columns = etapasFiltradas
      // Agrupa cards por etapa:
      const map = {}
      for (const e of etapasFiltradas) map[e.cd_etapa] = []

      for (const c of this.cardsRaw) {
        const etapaId = c.cd_etapa || null
        if (etapaId && map.hasOwnProperty(etapaId)) {
          map[etapaId].push(c)
        }
      }
      this.cardsByEtapa = map
    },
    async onCardMoved (evt, targetCol) {
      // evt.item: DOM do card movido
      // targetCol: coluna destino (etapa) com { cd_etapa, nm_etapa, ... }
      // Aqui você pode: chamar a mesma proc com cd_parametro=3 (sugestão),
      // passando { cd_movimento, cd_etapa_origem, cd_etapa_destino } para persistir.
      // Mantive só o “hook”:
      const moved = (this.cardsByEtapa[targetCol.cd_etapa] || [])[evt.newIndex]
      console.debug('moveu', moved && moved.cd_movimento, '=> etapa', targetCol.cd_etapa)
      // TODO: axios.post('/api/exec/pr_egis_kamban_processo', [{ cd_parametro: 3, ... }])
    }
  }
}
</script>

<style scoped>
.kamban-wrapper { display: flex; flex-direction: column; gap: 12px; }
.toolbar { display: flex; gap: 12px; align-items: center; }
.board { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 12px; }
.column { background: #f8f9fb; border: 1px solid #e6e8ef; border-radius: 10px; display: flex; flex-direction: column; min-height: 420px; }
.column-header { padding: 10px 12px; border-bottom: 1px solid #e6e8ef; display: flex; justify-content: space-between; align-items: baseline; }
.cards { padding: 10px; display: flex; flex-direction: column; gap: 8px; min-height: 380px; }
.card { background: white; border: 1px solid #e6e8ef; border-radius: 8px; padding: 8px 10px; }
.card-title { font-size: 13px; margin-bottom: 2px; }
.card-sub, .card-meta { font-size: 12px; color: #68708a; }
.loading { opacity: 0.8; }
.error { color: #b00020; }
.empty { color: #68708a; }
</style>
