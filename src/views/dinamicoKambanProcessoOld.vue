<template>
  <div class="column q-pa-md">

    <!-- TOOLBAR -->
    <q-toolbar class="q-gutter-sm bg-grey-2 q-pa-sm rounded-borders">
      <q-select
        class="q-ml-none"
        v-model="selectedMetodo"
        :options="metodos"
        option-value="cd_metodo"
        option-label="nm_metodo"
        emit-value
        map-options
        label="Pipeline/Kanban"
        dense filled clearable
        style="min-width: 260px"
        :loading="carregandoMetodos"
        @input="onMetodoChange"
      >
        <template v-slot:prepend>
          <q-icon name="view_kanban"/>
        </template>
      </q-select>

      <q-separator vertical spaced />

      <q-input
        dense filled
        v-model="filtro.dt_inicial"
        type="date"
        label="De"
        style="width: 160px"
        @input="onFiltroData"
      />
      <q-input
        dense filled
        v-model="filtro.dt_final"
        type="date"
        label="Até"
        style="width: 160px"
        @input="onFiltroData"
      />

      <q-space/>

      <q-btn
        dense icon="refresh"
        label="Atualizar"
        color="primary"
        @click="refresh"
        :loading="carregandoKambanProc"
      />
    </q-toolbar>

    <!-- BOARD -->
    <div class="q-mt-md">
      <div
        class="row items-start q-col-gutter-md"
        v-if="dataSourceConfigSorted.length"
      >
        <div
          v-for="col in dataSourceConfigSorted"
          :key="col.cd_etapa"
          class="col-12 col-sm-6 col-md-4 col-lg-3"
        >
          <q-card class="column full-height">
            <q-card-section class="q-pa-sm bg-grey-3">
              <div class="row items-center no-wrap">
                <div class="col">
                  <div class="text-weight-medium">{{ col.nm_etapa }}</div>
                  <div class="text-caption text-grey-7">
                    {{ (cardsByEtapa[col.cd_etapa] || []).length }} cards
                    <span v-if="totalPorEtapa[col.cd_etapa] !== undefined">
                      · {{ formatCurrency(totalPorEtapa[col.cd_etapa], col.sg_moeda || 'BRL') }}
                    </span>
                  </div>
                </div>
                <q-badge v-if="col.nm_status" :label="col.nm_status" outline class="q-ml-sm"/>
              </div>
            </q-card-section>

            <q-separator />

            <q-card-section class="q-pa-sm scroll" style="min-height: 380px; max-height: 70vh">
              <draggable
                :list="cardsByEtapa[col.cd_etapa]"
                group="kamban"
                handle=".drag"
                @end="evt => onCardMoved(evt, col)"
              >
                <transition-group type="transition" name="flip-list">
                  <q-card
                    v-for="card in cardsByEtapa[col.cd_etapa]"
                    :key="card.cd_movimento"
                    flat bordered class="q-mb-sm q-pa-sm"
                  >
                    <div class="row items-center no-wrap">
                      <q-icon name="drag_indicator" class="drag q-mr-xs" />
                      <div class="col">
                        <div class="text-caption text-grey">
                          #{{ card.cd_movimento }}
                          <span v-if="card.sg_modulo">· {{ card.sg_modulo }}</span>
                        </div>
                        <div class="text-body2 ellipsis">
                          {{ card.nm_destinatario || card.nm_pessoa || '—' }}
                        </div>
                        <div class="text-caption text-grey">
                          <span v-if="card.nm_contato">{{ card.nm_contato }}</span>
                          <span v-if="card.dt_movimento"> · {{ card.dt_movimento }}</span>
                          <span v-if="valorCard(card) > 0">
                            · {{ formatCurrency(valorCard(card), col.sg_moeda || 'BRL') }}
                          </span>
                        </div>
                      </div>
                      <q-btn
                        flat round dense icon="chevron_right"
                        @click="onAbrirCard(card)"
                      />
                    </div>
                  </q-card>
                </transition-group>
              </draggable>
            </q-card-section>
          </q-card>
        </div>
      </div>

      <div v-else class="q-pa-lg text-grey-7">
        Nenhuma etapa para exibir.
      </div>
    </div>

    <!-- LOADING & ERROR -->
    <q-inner-loading :showing="carregandoMetodos || carregandoKambanProc">
      <q-spinner size="42px" />
    </q-inner-loading>

  </div>
</template>

<script>
import axios from "axios";
import Relatorio from '@/components/Relatorio.vue'
import draggable from 'vuedraggable'

const banco = localStorage.nm_banco_empresa;

const api = axios.create({ 
  baseURL: '/api',
  withCredentials: true,   // ⬅️ mantém cookies da sessão
  timeout: 60000,
  headers: { 'Content-Type': 'application/json', 'x-banco': banco }
  // headers: { 'Content-Type': 'application/json', 'x-banco': banco }  
 }); // cai no proxy acima

// injeta headers a cada request (x-banco + bearer fixo)
api.interceptors.request.use(cfg => {
  const banco = localStorage.nm_banco_empresa || '';
  if (banco) cfg.headers['x-banco'] = banco;
  cfg.headers['Authorization'] = 'Bearer superchave123';
  if (!cfg.headers['Content-Type']) cfg.headers['Content-Type'] = 'application/json';
  // DEBUG: veja a URL real que está indo
  console.log('[REQ]', cfg.method?.toUpperCase(), (cfg.baseURL || '') + cfg.url);
  return cfg;
});

export default {
  name: 'dinamicoKambanProcesso',
  components: { draggable, Relatorio },

  /*
  props: {
    // mantenha os mesmos nomes que você usa no projeto
    cdModulo: { type: Number, required: true },
    cdEmpresa: { type: Number, default: 0 },
    cdUsuario: { type: Number, default: 0 },
    cdModelo:  { type: Number, default: 0 }
  },
  */

  data () {
    return {
          // Lê automaticamente do localStorage (ou define padrão se não existir)
      cdModulo: Number(localStorage.cd_modulo || 0),
      cdEmpresa: Number(localStorage.cd_empresa || 0),
      cdUsuario: Number(localStorage.cd_usuario || 0),
      cdModelo: Number(localStorage.cd_modelo || 0),
      nome_procedure: 'pr_egis_kamban_processo',
      // SELECT de pipelines
      metodos: [],
      selectedMetodo: null,

      // Estruturas que o board usa (colunas e cards)
      dataSourceConfig: [], // colunas/etapas
      dados_pipeline: [],   // cards (dataset “achatado”)

      // Estados
      carregandoMetodos: false,
      carregandoKambanProc: false,
      erro: '',

      // Filtros de período
      filtro: {
        dt_inicial: this.isoPrimeiroDiaMes(),
        dt_final:   this.isoUltimoDiaMes()
      }
    }
  },

  computed: {
    dataSourceConfigSorted () {
      return (this.dataSourceConfig || []).slice().sort((a, b) => {
        return (a.qt_ordem_etapa || 0) - (b.qt_ordem_etapa || 0)
      })
    },

    // Mapa: cd_etapa -> [cards...]
    cardsByEtapa () {
      const map = {}
      for (const col of this.dataSourceConfig) {
        map[col.cd_etapa] = []
      }
      for (const c of this.dados_pipeline) {
        const etapa = c.cd_etapa
        if (etapa !== undefined && map.hasOwnProperty(etapa)) {
          map[etapa].push(c)
        }
      }
      return map
    },

    // Somatório por etapa (vl_card ou vl_etapa)
    totalPorEtapa () {
      const res = {}
      for (const col of this.dataSourceConfig) {
        const etapa = col.cd_etapa
        const cards = this.cardsByEtapa[etapa] || []
        const total = cards.reduce((acc, c) => {
          const v = this.valorCard(c)
          return acc + (Number(v) || 0)
        }, 0)
        res[etapa] = total
      }
      return res
    }
  },

  mounted () {
    // garante que pegou os valores atualizados
    this.cdModulo  = Number(localStorage.cd_modulo  || this.cdModulo  || 0)
    this.cdEmpresa = Number(localStorage.cd_empresa || this.cdEmpresa || 0)
    this.cdUsuario = Number(localStorage.cd_usuario || this.cdUsuario || 0)
    this.cdModelo  = Number(localStorage.cd_modelo  || this.cdModelo  || 1)

    // fluxo inicial
    this.loadMetodos().then(() => {
      // opcional: selecionar o primeiro método automaticamente
      // this.selectedMetodo = this.metodos[0]?.cd_metodo || null
      // if (this.selectedMetodo) this.loadEtapasECards()
    })
  },

  methods: {
       // -------------------------
    // Utils
    // -------------------------
    http () {
      // usa o mesmo client que você mostrou (api.post). Fallback para this.$api, se existir.
      return api || this.$api
    },

    // =======================
    // Helpers de Data & Valor
    // =======================
    isoPrimeiroDiaMes () {
      const d = new Date()
      const x = new Date(d.getFullYear(), d.getMonth(), 1)
      return x.toISOString().slice(0, 10)
    },
    isoUltimoDiaMes () {
      const d = new Date()
      const x = new Date(d.getFullYear(), d.getMonth() + 1, 0)
      return x.toISOString().slice(0, 10)
    },
    formatCurrency (value, moeda = 'BRL') {
      try {
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: moeda }).format(Number(value || 0))
      } catch (e) {
        return `R$ ${Number(value || 0).toLocaleString('pt-BR')}`
      }
    },
    valorCard (c) {
      // aceita tanto vl_card quanto vl_etapa (ajuste sua SP conforme preferir)
      return Number(c.vl_card ?? c.vl_etapa ?? 0)
    },

    // ===================
    // Backend - Procedures
    // ===================

    /* ===== API (IGUAL AO UNICOFORMSPECIAL) ===== */

   async callProc (cd_parametro, extra = {}) {

      // datas sempre válidas
      const dtIni = this.filtro?.dt_inicial || this.isoPrimeiroDiaMes();
      const dtFim = this.filtro?.dt_final   || this.isoUltimoDiaMes();
   
      // monta payload ENXUTO conforme o parâmetro
      let base
      base = {
      cd_parametro,
      cd_empresa : Number(localStorage.cd_empresa || this.cdEmpresa || 0),
      cd_usuario : Number(localStorage.cd_usuario || this.cdUsuario || 0),
      cd_modulo  : Number(localStorage.cd_modulo  || this.cdModulo  || 0),
      cd_modelo  : Number(localStorage.cd_modelo  || this.cdModelo  || 1),
      dt_inicial : this.filtro.dt_inicial,
      dt_final   : this.filtro.dt_final,
      cd_metodo  : this.selectedMetodo || 0,
      ic_json_parametro : 'S', 
      ...extra
    
     }

  const payloadExec = [base]; //JSON.stringify([ base ])
 //const payloadExec = JSON.stringify([ base ]);

  // **EXATAMENTE** como no unicoFormEspecial.vue:
  console.log('>>> exec', this.nome_procedure, payloadExec, base)

  const { data } = await api.post(`/exec/${this.nome_procedure}`, payloadExec,
   
  )
  console.log('banco no callProc:', banco, data);
  // ajuda no diagnóstico quando der 500 (server traz msg)

  if (!Array.isArray(data)) {
    console.warn('retorno inesperado da procedure:', data)
    //return []
  }

  console.log('<<< resp', data);

  //return data
   return Array.isArray(data) ? data : []
    //

    },

    async loadMetodos () {

  try {
    this.carregandoMetodos = true
    this.metodos = await this.callProc(1)
    if (!this.metodos.length) {
      this.$q?.notify?.({ type: 'warning',    position: 'center', message: 'Nenhum Pipeline/Kanban (param=1).' })
    }
  } catch (e) {
    const status = e?.response?.status
    const body = e?.response?.data
    console.error('Erro param=1', status, body)
    this.$q?.notify?.({
      type: 'negative',
         position: 'center',
      message: 'Falha ao carregar pipelines.',
      caption: (typeof body === 'string') ? body : JSON.stringify(body || {})
    })
    this.metodos = []
  } finally {
    this.carregandoMetodos = false
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
    await this.loadEtapas() // param=2
    await this.loadCards()  // param=3
  } catch (e) {
    this.$q?.notify?.({ type: 'negative', message: 'Falha ao carregar etapas/cards.' })
  } finally {
    this.carregandoKambanProc = false
  }
},

async loadEtapas () {
  const rows = await this.callProc(2)
  console.log('param=2 etapas:', rows.length, rows.slice(0,3))
  this.aplicarEtapas(rows)
},

async loadCards () {
  const rows = await this.callProc(3)
  console.log('param=3 cards:', rows.length, rows.slice(0,3))
  this.aplicarCards(rows)
},

aplicarEtapas (rows) {
  const etapasMap = new Map()
  for (const r of rows) {
    // tenta vários ids possíveis
    const cd_etapa = r.cd_etapa ?? r.cd_auxiliar ?? r.cd_controle ?? null
    if (cd_etapa == null) continue

    const nm_etapa = r.nm_etapa ?? r.nm_metodo ?? 'Etapa'
    if (!etapasMap.has(cd_etapa)) {
      etapasMap.set(cd_etapa, {
        cd_etapa,
        nm_etapa,
        qt_ordem_etapa: r.qt_ordem_etapa ?? r.qt_ordem ?? 0,
        sg_moeda: r.sg_moeda || 'BRL',
        nm_status: r.nm_status || null,
        ic_grafico_etapa: r.ic_grafico_etapa || 'N',
        nm_valor_etapa: 0,
        qt_etapa: 0
      })
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

    cards.push({
      cd_movimento: r.cd_movimento ?? r.cd_controle ?? `${cd_etapa}-${Math.random().toString(36).slice(2,8)}`,
      cd_etapa,
      dt_movimento : r.dt_movimento,
      nm_destinatario: r.nm_destinatario || r.nm_pessoa || r.nm_titulo_pagina_etapa || r.nm_etapa,
      nm_contato   : r.nm_contato || r.nm_responsavel || r.nm_executor || '',
      sg_modulo    : r.sg_modulo || '',
      vl_card      : Number(r.vl_card ?? r.vl_etapa ?? 0),
      cd_menu      : r.cd_menu || 0,
      cd_api       : r.cd_api || 0,
      cd_documento : r.cd_documento || 0,
      cd_item_documento : r.cd_item_documento || 0
    })
  }

  // agrega nas colunas já carregadas
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
    
    // ======================
    // Eventos UI
    // ======================
    onMetodoChange () {
      this.loadEtapasECards()
    },
    onFiltroData () {
      // ao mudar o período, recarrega se houver método selecionado
      if (this.selectedMetodo) this.loadEtapasECards()
    },
    refresh () {
      if (this.selectedMetodo) this.loadEtapasECards()
      else this.loadMetodos()
    },

    onAbrirCard (card) {
      // adapte para seu fluxo padrão de abrir card/documento
      // exemplo: navegar para menu/relatório/api que veio no dataset
      const info = [
        card.cd_menu ? `Menu: ${card.cd_menu}` : null,
        card.cd_api ? `API: ${card.cd_api}` : null,
        card.cd_documento ? `Doc: ${card.cd_documento}` : null
      ].filter(Boolean).join(' | ')
      this.$q?.notify?.({
        type: 'info',
        message: `Abrir card #${card.cd_movimento}`,
        caption: info || 'Defina a ação no método onAbrirCard'
      })
    },

    async onCardMoved (evt, targetCol) {

      // Persistência opcional do movimento (param=3)
      // const moved = (this.cardsByEtapa[targetCol.cd_etapa] || [])[evt.newIndex]
      // if (moved) {
      //   await this.callProc(3, {
      //     cd_movimento: moved.cd_movimento,
      //     cd_etapa_destino: targetCol.cd_etapa,
      //     cd_etapa_origem: evt.from?.dataset?.etapa ? Number(evt.from.dataset.etapa) : null
      //   })
      // }
    }
  }
}
</script>

<style scoped>
.rounded-borders { border-radius: 10px; }
.flip-list-move { transition: transform .25s; }
.drag { cursor: grab; }
.scroll { overflow: auto; }
</style>
