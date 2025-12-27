<template>
  <div class="page">

    <!-- 1) TOP BAR (toolbar + botão atualizar) -->
    <div class="toolbar-wrap q-pa-md">
      <q-toolbar class="q-gutter-sm bg-grey-2 q-pa-sm rounded-borders">
        <q-select
          v-model="selectedMetodo"
          :options="metodos"
          option-value="cd_metodo"
          option-label="nm_metodo"
          emit-value
          map-options
          label="Pipeline/Kanban"
          dense filled clearable
          style="min-width: 280px"
          :loading="carregandoMetodos"
          @input="onMetodoChange"
        >
          <template v-slot:prepend><q-icon name="view_kanban"/></template>
        </q-select>

        <q-separator vertical spaced />

        <q-input
          dense filled type="date" label="De" style="width: 160px"
          v-model="filtro.dt_inicial" @input="onFiltroData"
        />
        <q-input
          dense filled type="date" label="Até" style="width: 160px"
          v-model="filtro.dt_final" @input="onFiltroData"
        />

        <q-space />

        <q-btn dense color="primary" icon="refresh" label="ATUALIZAR"
               :loading="carregandoKambanProc" @click="refresh"/>
      </q-toolbar>
    </div>

    <!-- 2) KANBAN (faixa independente do grid do Quasar) -->

  <div class="board-wrap">
  <!-- setas do carrossel -->
  <div class="board-arrows" v-if="dataSourceConfigSorted.length">
    <q-btn round dense color="deep-orange-6" icon="chevron_left"
           @click="scrollByCols(-1)" :disable="!canScrollLeft"/>
    <q-space/>
    <q-btn round dense color="deep-orange-6" icon="chevron_right"
           @click="scrollByCols(1)" :disable="!canScrollRight"/>
  </div>

  <q-inner-loading :showing="carregandoMetodos || carregandoKambanProc">
    <q-spinner size="42px" />
  </q-inner-loading>

  <div v-if="dataSourceConfigSorted.length"
       class="board-scroll"
       ref="boardScroll"
       @scroll="checkScrollState">

    <div class="board-track">
      <!-- … (resto das colunas igual está) … -->
        <!-- SETAS DE ROLAGEM -->
          <!-- COLUNA -->
          <div
            v-for="col in dataSourceConfigSorted"
            :key="col.cd_etapa"
            class="board-col"
          >
            <q-card class="column full-height">

              <!-- Cabeçalho da coluna -->

              <q-card-section class="q-pa-sm bg-grey-3">
                <div class="row items-center no-wrap">
                  <div class="col">
                    <div class="text-weight-bold">
                      {{ col.nm_etapa }}
                      <q-badge color="primary" outline class="q-ml-xs"
                               :label="(cardsByEtapa[col.cd_etapa] || []).length"/>
                    </div>
                    <div class="text-caption text-grey-7">
                      {{ formatCurrency(totalPorEtapa[col.cd_etapa] || 0, col.sg_moeda || 'BRL') }}
                    </div>
                  </div>
                
                  <!-- botões à direita: menu + lixeira -->
    <q-btn dense flat round icon="more_vert" />
    <q-btn dense flat round color="negative" icon="delete"
           :title="`Remover ${col.nm_etapa}`"
           @click="removerEtapa(col)"/>
  </div>
              </q-card-section>

              <q-separator />

              <!-- Cards -->
              <q-card-section class="q-pa-sm board-col-scroll">
                <draggable
                  :list="cardsByEtapa[col.cd_etapa]"
                  group="kamban"
                  handle=".drag"
                  @end="evt => onCardMoved(evt, col)"
                >
                  <transition-group type="transition" name="flip-list">
                    <q-card
                      v-for="card in cardsByEtapa[col.cd_etapa]"
                      :key="card._id"
                      flat bordered class="q-mb-sm"
                    >
                      <q-card-section class="q-pa-sm">
                        <div class="row no-wrap items-start">
                          <div class="q-mr-sm q-mt-xs"
                               style="width:4px; background:#a64de3; border-radius:2px; height:44px;"></div>
                          <div class="col">
                            <div class="text-subtitle2 text-weight-bold ellipsis">
                              {{ card.nm_titulo || card.nm_destinatario || '—' }}
                            </div>
                            <div class="text-caption text-grey-8">
                              {{ formatCurrency(card.vl_card || 0, card.sg_moeda || 'BRL') }}
                            </div>
                            <div class="text-caption text-grey-7">
                              {{ card.nm_subtitulo || '' }}
                            </div>
                            <div class="text-caption text-grey-7">
                              {{ card.dt_movimento || '' }}
                            </div>
                          </div>
                          <q-badge v-if="card.qt_badge" color="amber-8" text-color="black" :label="card.qt_badge"/>
                        </div>

                        <div class="row q-gutter-sm q-mt-sm">
                          <q-btn dense round color="pink-5"   icon="menu" />
                          <q-btn dense round color="indigo-6" icon="edit" />
                          <q-btn dense round color="orange-6" icon="task" />
                          <q-space />
                          <q-btn dense flat round icon="chevron_right" @click="onAbrirCard(card)"/>
                        </div>
                      </q-card-section>
                    </q-card>
                  </transition-group>
                </draggable>
              </q-card-section>
            </q-card>
          </div>
        </div>
      </div>

      <div v-else class="q-pa-lg text-grey-7">
        Nenhuma etapa para exibir.
      </div>
    </div>

  </div>
</template>

<script>
import axios from 'axios'
import draggable from 'vuedraggable'

/* === API no mesmo padrão do seu projeto === */
const bancoLS = localStorage.nm_banco_empresa || ''
const api = axios.create({
  baseURL: '/api',
  withCredentials: true,
  timeout: 60000,
  headers: { 'Content-Type': 'application/json', 'x-banco': bancoLS }
})
api.interceptors.request.use(cfg => {
  const banco = localStorage.nm_banco_empresa || ''
  if (banco) cfg.headers['x-banco'] = banco
  cfg.headers['Authorization'] = 'Bearer superchave123'
  if (!cfg.headers['Content-Type']) cfg.headers['Content-Type'] = 'application/json'
  console.log('[REQ]', banco || '—', (cfg.method || 'get').toUpperCase(),
              (cfg.baseURL || '') + cfg.url, '| CT=', cfg.headers['Content-Type'])
  return cfg
})

export default {
  name: 'dinamicoKambanProcesso',
  components: { draggable },

  data () {
    return {
      nome_procedure: 'pr_egis_kamban_processo',

      // parâmetros vindos do LS
      cdModulo:  Number(localStorage.cd_modulo  || 0),
      cdEmpresa: Number(localStorage.cd_empresa || 0),
      cdUsuario: Number(localStorage.cd_usuario || 0),
      cdModelo:  Number(localStorage.cd_modelo  || 1),

      filtro: {
        dt_inicial: this.isoPrimeiroDiaMes(),
        dt_final:   this.isoUltimoDiaMes()
      },

      metodos: [],
      selectedMetodo: null,

      dataSourceConfig: [],  // colunas
      dados_pipeline: [],    // cards

      carregandoMetodos: false,
      carregandoKambanProc: false,
      canScrollLeft: false,
      canScrollRight: false,
      colWidth: 340,      // mesma largura definida no CSS .board-col
      gapWidth: 12,
      removedEtapas: new Set(),

    }
  },

  computed: {
    dataSourceConfigSorted () {
      return (this.dataSourceConfig || []).slice()
        .sort((a, b) => (a.qt_ordem_etapa || 0) - (b.qt_ordem_etapa || 0))
    },
    cardsByEtapa () {
      const map = {}
      for (const col of this.dataSourceConfig) map[col.cd_etapa] = []
      for (const c of this.dados_pipeline) {
        if (c.cd_etapa != null) {
          if (!map[c.cd_etapa]) map[c.cd_etapa] = []
          map[c.cd_etapa].push(c)
        }
      }
      return map
    },
    totalPorEtapa () {
      const out = {}
      for (const col of this.dataSourceConfig) {
        const arr = this.cardsByEtapa[col.cd_etapa] || []
        out[col.cd_etapa] = arr.reduce((acc, c) => acc + (Number(c.vl_card) || 0), 0)
      }
      return out
    }
  },

  mounted () {
    // revalida LS
    this.cdModulo  = Number(localStorage.cd_modulo  || this.cdModulo  || 0)
    this.cdEmpresa = Number(localStorage.cd_empresa || this.cdEmpresa || 0)
    this.cdUsuario = Number(localStorage.cd_usuario || this.cdUsuario || 0)
    this.cdModelo  = Number(localStorage.cd_modelo  || this.cdModelo  || 1)
    this.loadMetodos()
    this.$nextTick(() => {
    this.checkScrollState()
    window.addEventListener('resize', this.checkScrollState, { passive: true })
})

  },

  methods: {

    checkScrollState () {
  const el = this.$refs.boardScroll
  if (!el) { this.canScrollLeft = this.canScrollRight = false; return }
  const max = el.scrollWidth - el.clientWidth - 1
  this.canScrollLeft = el.scrollLeft > 0
  this.canScrollRight = el.scrollLeft < max
},
scrollByCols (dir = 1) {
  const el = this.$refs.boardScroll
  if (!el) return
  const delta = dir * (this.colWidth + this.gapWidth)
  el.scrollBy({ left: delta, behavior: 'smooth' })
},

removerEtapa (col) {
  if (!col || col.cd_etapa == null) return
  // remove coluna
  this.dataSourceConfig = this.dataSourceConfig.filter(c => c.cd_etapa !== col.cd_etapa)
  // remove os cards daquela etapa
  this.dados_pipeline = this.dados_pipeline.filter(c => c.cd_etapa !== col.cd_etapa)
  // atualiza totais e setas
  this.$nextTick(() => this.checkScrollState())
},

    /* ===== UTIL ===== */
    isoPrimeiroDiaMes () {
      const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1).toISOString().slice(0,10)
    },
    isoUltimoDiaMes () {
      const d = new Date(); return new Date(d.getFullYear(), d.getMonth()+1, 0).toISOString().slice(0,10)
    },
    formatCurrency (v, moeda = 'BRL') {
      try { return new Intl.NumberFormat('pt-BR', { style:'currency', currency:moeda }).format(Number(v||0)) }
      catch { return `R$ ${Number(v||0).toLocaleString('pt-BR')}` }
    },

    /* ===== API (envia OBJETO, como seu index.js espera) ===== */
    async callProc (cd_parametro, extra = {}) {
      const payload = [{
        cd_parametro,
        ic_json_parametro : 'S',
        cd_empresa : this.cdEmpresa,
        cd_usuario : this.cdUsuario,
        cd_modulo  : this.cdModulo,
        cd_modelo  : this.cdModelo,
        dt_inicial : this.filtro?.dt_inicial || this.isoPrimeiroDiaMes(),
        dt_final   : this.filtro?.dt_final   || this.isoUltimoDiaMes(),
        cd_metodo  : this.selectedMetodo ? Number(this.selectedMetodo) : 0,
        ...extra
      }];
      console.log('>>> exec', this.nome_procedure, payload)
      const { data } = await api.post(`/exec/${this.nome_procedure}`, payload)
      return Array.isArray(data) ? data : []
    },

    /* ===== FLUXO ===== */
    async loadMetodos () {
      try {
        this.carregandoMetodos = true
        this.metodos = await this.callProc(1)
     
        if (!this.metodos.length) {
          this.$q?.notify?.({ type:'warning', message:'Nenhum Pipeline/Kanban (param=1).' })
        }
        else     // auto-seleciona e carrega kanban se houver só 1
           if (this.metodos.length === 1) {
           this.selectedMetodo = this.metodos[0].cd_metodo
          await this.loadEtapasECards()   // carrega etapas (2) e cards (3)
        }

       } catch (e) {
         this.$q?.notify?.({ type:'negative', message:'Falha ao carregar pipelines.' })
       } finally {
        this.carregandoMetodos = false
        this.$nextTick(() => this.checkScrollState())
      }
    },

    async loadEtapasECards () {
      if (!this.selectedMetodo) {
        this.dataSourceConfig = []
        this.dados_pipeline = []
        return
      }
      try {
        this.carregandoKambanProc = true
        const etapas = await this.callProc(2)
        this.aplicarEtapas(etapas)

        const cards = await this.callProc(3)
        this.aplicarCards(cards)

        console.log('param=2 etapas:', etapas.length, etapas.slice(0,3))
        console.log('param=3 cards:',  cards.length,  cards.slice(0,3))
      } catch (e) {
        this.$q?.notify?.({ type:'negative', message:'Falha ao carregar etapas/cards.' })
      } finally {
        this.carregandoKambanProc = false
      }
    },

    /* ===== MAPEAMENTOS ===== */
    aplicarEtapas (rows) {
      const etapasMap = new Map()

      // 1) etapas vindas do param=2
      for (const r of rows) {
        const cd_etapa = r.cd_etapa ?? r.cd_auxiliar ?? r.cd_controle ?? null
        if (cd_etapa == null) continue
        if (!etapasMap.has(cd_etapa)) {
          etapasMap.set(cd_etapa, {
            cd_etapa,
            nm_etapa: r.nm_etapa ?? r.nm_metodo ?? 'Etapa',
            qt_ordem_etapa: r.qt_ordem_etapa ?? r.qt_ordem ?? 0,
            sg_moeda: r.sg_moeda || 'BRL',
            nm_status: r.nm_status || null,
            ic_grafico_etapa: r.ic_grafico_etapa || 'N',
            nm_valor_etapa: 0,
            qt_etapa: 0
          })
        }
      }

      // 2) se não veio nada, derive etapas dos cards já existentes
      if (etapasMap.size === 0 && this.dados_pipeline.length) {
        for (const c of this.dados_pipeline) {
          const cd_etapa = c.cd_etapa
          if (cd_etapa == null) continue
          if (!etapasMap.has(cd_etapa)) {
            etapasMap.set(cd_etapa, {
              cd_etapa,
              nm_etapa: c.nm_etapa || 'Etapa',
              qt_ordem_etapa: c.qt_ordem_etapa || 0,
              sg_moeda: c.sg_moeda || 'BRL',
              nm_status: c.nm_status || null,
              ic_grafico_etapa: c.ic_grafico_etapa || 'N',
              nm_valor_etapa: 0,
              qt_etapa: 0
            })
          }
        }
      }

      this.dataSourceConfig = Array.from(etapasMap.values())
        .sort((a, b) => (a.qt_ordem_etapa || 0) - (b.qt_ordem_etapa || 0))
    },

    aplicarCards (rows) {
      const cards = []
      for (const r of rows) {
        const cd_etapa = r.cd_etapa ?? r.cd_auxiliar ?? r.cd_controle ?? null
        if (cd_etapa == null) continue

        // id estável pro v-for
        const id = r.cd_movimento ?? r.cd_controle ??
                   `${cd_etapa}-${(r.dt_movimento || '')}-${(r.nm_destinatario || r.nm_etapa || '')}`

        cards.push({
          _id: id,
          cd_etapa,
          nm_titulo: r.nm_titulo_pagina_etapa || r.nm_destinatario || r.nm_etapa || '',
          nm_subtitulo: r.nm_ocorrencia || r.nm_contato || r.nm_responsavel || r.nm_executor || '',
          dt_movimento: r.dt_movimento || '',
          vl_card: Number(r.vl_card ?? r.vl_etapa ?? 0),
          sg_moeda: r.sg_moeda || 'BRL',
          qt_badge: r.qt_etapa || null,
          cd_menu: r.cd_menu || 0,
          cd_api: r.cd_api || 0,
          cd_documento: r.cd_documento || 0,
          cd_item_documento: r.cd_item_documento || 0
        })
      }

      // agrega nas colunas
      const somas = {}
      const conts = {}
      for (const c of cards) {
        conts[c.cd_etapa] = (conts[c.cd_etapa] || 0) + 1
        somas[c.cd_etapa] = (somas[c.cd_etapa] || 0) + (Number(c.vl_card) || 0)
      }

      this.dataSourceConfig = (this.dataSourceConfig || []).map(col => ({
        ...col,
        qt_etapa: conts[col.cd_etapa] || 0,
        nm_valor_etapa: somas[col.cd_etapa] || 0
      }))

      this.dados_pipeline = cards
    },

    /* ===== UI ===== */
    onMetodoChange () { this.loadEtapasECards() },
    onFiltroData () { if (this.selectedMetodo) this.loadEtapasECards() },
    refresh ()
     { 
      if (this.selectedMetodo) this.loadEtapasECards(); else this.loadMetodos() },
    onAbrirCard (card) {
      const info = [
        card.cd_menu ? `Menu: ${card.cd_menu}` : null,
        card.cd_api ? `API: ${card.cd_api}` : null,
        card.cd_documento ? `Doc: ${card.cd_documento}` : null
      ].filter(Boolean).join(' | ')
      this.$q?.notify?.({ type:'info', message:`Abrir card: ${card.nm_titulo || card._id}`, caption: info })
    },
    async onCardMoved (evt, targetCol) {
      // opcional: persistir movimentação com outro parâmetro da SP
      // const moved = (this.cardsByEtapa[targetCol.cd_etapa] || [])[evt.newIndex]
      // if (moved) await this.callProc(4, { cd_movimento: moved.cd_movimento, cd_etapa_destino: targetCol.cd_etapa })
    }
  }
}
</script>

<style scoped>
.rounded-borders { border-radius: 10px; }
.flip-list-move { transition: transform .25s; }
.drag { cursor: grab; }
.scroll { overflow: auto; }

.kanban-viewport {
  width: 100%;
  overflow-x: auto;      /* permite rolar na horizontal se precisar */
  overflow-y: hidden;
}

/* trilho das colunas: sempre à ESQUERDA */
.kanban-track {
  display: flex;
  flex-wrap: nowrap;                 /* não quebra linha */
  justify-content: flex-start !important;
  align-items: flex-start;
  gap: 12px;
  width: max-content;                /* se tiver poucas colunas, fica colado à esquerda */
  padding: 0 8px 8px;
}


/* garante que a faixa de colunas fique à esquerda e não quebre linha */
.kanban-row {
  flex-wrap: nowrap !important;           /* todas as colunas em uma linha */
  justify-content: flex-start !important; /* SEMPRE alinhar à esquerda   */
  align-items: flex-start !important;
  overflow-x: auto;                        /* rolagem horizontal se passar */
  overflow-y: hidden;
  padding-bottom: 8px;
}

/* força largura fixa nas colunas do Quasar grid */
.kanban-row > [class*="col-"] {
  flex: 0 0 340px !important; /* ajuste pra 300/320/360 se quiser */
  max-width: 340px !important;
}

/* estrutura da página: toolbar fixa em cima, board ocupa o restante */
.page {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0; /* importante para permitir o overflow da faixa */
}
.toolbar-wrap {
  flex: 0 0 auto;
}
.board-wrap {
  flex: 1 1 auto;
  min-height: 0;
  position: relative;
}

/* faixa horizontal do kanban */
.board-scroll {
  height: 100%;
  overflow-x: auto;
  overflow-y: hidden;
  scroll-behavior: smooth;         /* animação no scrollBy */
}
.board-track {
  display: flex;
  flex-wrap: nowrap;                 /* não quebra linha */
  justify-content: flex-start;       /* sempre colado à ESQUERDA */
  align-items: flex-start;
  gap: 12px;
  width: max-content;                /* largura = soma das colunas */
  padding: 8px;
}

/* coluna */
.board-col {
  flex: 0 0 340px;                   /* ajuste: 320/360 se preferir */
  max-width: 340px;
}
.board-col-scroll {
  min-height: 420px;
  max-height: 70vh;
  overflow-y: auto;
}

/* setas sobre o board */
.board-arrows{
  position: absolute;
  top: 4px;
  left: 8px;
  right: 8px;
  display: flex;
  align-items: center;
  pointer-events: none;           /* passa cliques pro board */
}
.board-arrows .q-btn{
  pointer-events: auto;           /* mas as setas recebem clique */
}

/* neutraliza paddings herdados do layout principal, se houver */
:deep(.q-page),
:deep(.q-page-container) {
  padding-left: 0 !important;
}

/* animação suave nos reorders */
.flip-list-move { transition: transform .2s; }

</style>
