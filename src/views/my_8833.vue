<template>
  <div class="q-pa-sm">

    <!-- TABS -->
    <q-tabs
      v-model="aba"
      dense
      active-color="primary"
      indicator-color="primary"
      align="left"
      class="text-grey-8"
    >
      <q-tab name="dados" label="DADOS" />
      <q-tab
        name="lancamentos"
        label="LANÇAMENTOS"
        :disable="!loteSelecionado"
       
      />
    </q-tabs>

    <q-separator />

    <!-- PANELS -->
    <q-tab-panels v-model="aba" animated keep-alive>

      <!-- ABA DADOS: engine normal -->
      <q-tab-panel name="dados" class="q-pa-none">
        <!-- ⚠️ aqui fica o engine como sempre foi -->
             <unico-form-especial
    ref="engine"
    :cd_menu_entrada="MENU_ID"
    :cd_acesso_entrada="cdAcesso"
    :modo_inicial="modoInicial"
    :embedMode="embedMode"
    :registro_pai="registroPai"
    :cd_chave_registro="cdChaveRegistro"
    :overrides="overrides"
    :hooks="engineHooks"
     />
      </q-tab-panel>

      <!-- ABA LANÇAMENTOS: grid DevExtreme -->
      <q-tab-panel name="lancamentos" class="q-pa-none">

        <div class="q-pa-sm">
          <div class="row items-center q-gutter-sm">
            <q-input
              dense
              outlined
              v-model="filtroLanc"
              label="Pesquisar itens..."
              style="max-width: 320px"
            />
            <q-btn
              color="primary"
              icon="refresh"
              label="Recarregar"
              :disable="!loteSelecionado || carregandoLancamentos"
              @click="recarregarLancamentos()"
            />
            <q-space />
            <div class="text-grey-7">
              Lote: <b>{{ loteSelecionado || '-' }}</b>
            </div>
          </div>
        </div>

        <div class="q-pa-sm">
          <dx-data-grid
            ref="gridLanc"
            :key="gridLancVersion"
            :data-source="lancamentos"
            :key-expr="keyExprLanc"
            :show-borders="true"
            :column-auto-width="true"
            :word-wrap-enabled="true"
            :hover-state-enabled="true"
            height="calc(100vh - 260px)"
          >
            <dx-load-panel :enabled="true" />
            <dx-paging :page-size="50" />
            <dx-pager :show-page-size-selector="true" :allowed-page-sizes="[20, 50, 100, 200]" />
            <dx-filter-row :visible="true" />
            <dx-header-filter :visible="true" />
            <dx-search-panel :visible="true" />
            <dx-export :enabled="true" />
            <dx-column-chooser :enabled="true" />

            <dx-column
              v-for="c in lancamentoColumns"
              :key="c.dataField"
              v-bind="c"
            />
          </dx-data-grid>

          <div v-if="!carregandoLancamentos && loteSelecionado && lancamentos.length === 0" class="q-pa-md text-grey-7">
            Sem dados.
          </div>
        </div>

      </q-tab-panel>
    </q-tab-panels>

  </div>
</template>


<script>
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue"
import api from "@/boot/axios"

// DevExtreme (ajuste paths conforme seu projeto)
import DxDataGrid, {
  DxPaging, DxPager, DxFilterRow, DxHeaderFilter, DxSearchPanel,
  DxExport, DxColumnChooser, DxColumn, DxLoadPanel
} from "devextreme-vue/data-grid"

const MENU_ID = 8833
const LANCAMENTO_MENU_ID = 883300
const LANCAMENTO_TAB_KEY = `det_${LANCAMENTO_MENU_ID}`

export default {
  name: "my_8833",
  components: { UnicoFormEspecial,
      DxDataGrid,
    DxPaging,
    DxPager,
    DxFilterRow,
    DxHeaderFilter,
    DxSearchPanel,
    DxExport,
    DxColumnChooser,
    DxColumn,
    DxLoadPanel,
   },

  props: {
    embedMode: { type: Boolean, default: false },
    registroPai: { type: Object, default: null },
    cdChaveRegistro: { type: Number, default: 0 },
  },

  data() {
    return {
      MENU_ID,
      cdAcesso: Number(localStorage.cd_chave_pesquisa || 0),
      modoInicial: "GRID",
      aba: "dados",
      loteSelecionado: null,
      lancamentos: [],
      lancamentoColumns: [],
      carregandoLancamentos: false,
      keyExprLanc: "id",
      filtroLanc: "",
      ultimoRegistroPai: null,

      overrides: {
        title: (localStorage.nm_menu_titulo + ' * ') || "Lote Contábeis *",
        gridPageSize: 200,
      },

      mapaCaptionLanc: {},
      loteLancamentosCarregado: null,   // ✅ qual lote está no grid de lançamentos
      _reqLancToken: 0,                // ✅ anti-race
      gridLancVersion: 0,


    }
  },

watch: {

  async aba(val) {
    console.log('watch--> ', val, this.loteSelecionado, this.loteLancamentosCarregado)

    if (val !== "lancamentos") return
    if (!this.loteSelecionado) return

    if (this.loteLancamentosCarregado !== this.loteSelecionado) {
      console.log("[my_8833] chamando carregarLancamentosPorLote com", this.loteSelecionado)
      try {
        await this.carregarLancamentosPorLote(this.loteSelecionado)
  
  this.$nextTick(() => {
  const g = this.$refs.gridLanc
  const inst = g && g.instance
  if (inst) inst.updateDimensions()
})

  
        console.log("[my_8833] voltou do carregarLancamentosPorLote")
      } catch (err) {
        console.error("[my_8833] ERRO no carregarLancamentosPorLote:", err)
      }
    }
  }
},

  computed: {
    engineHooks() {
      return {
        beforeFetchRows: this.beforeFetchRowsHook,
        mapPayload: this.mapPayloadHook,
      }
    },

     lancamentosFiltrados() {
      const term = (this.filtroLanc || "").trim().toLowerCase()

      //console.log(this.lancamentos);

      if (!term) return this.lancamentos

      //console.log('Lançamentos Filtrados: ', lancamentosFiltrados);

      return (this.lancamentos || []).filter(r => {
        // filtro simples “contains em qualquer coluna”
        return Object.keys(r || {}).some(k => String(r[k] ?? "").toLowerCase().includes(term))
      })

    },
  },

  methods: {
    onVoltar() {
      this.$router.back()
    },
    onFechar() {
      this.$router.back()
    },

    async onSelecionou(registro) {
      await this.carregarLancamentos(registro)
    },



async carregarLancamentosPorLote(cdLote) {
  if (!cdLote) return

  this.carregandoLancamentos = true
  //this.loteLancamentosCarregado = cdLote
  const myToken = ++this._reqLancToken

  try {
    const payload = [{
      ic_json_parametro: "S",
      cd_parametro: 2,
      cd_lote: cdLote,
      cd_empresa: Number(localStorage.cd_empresa || 0),
    }]

    console.log('payload parametro 2 ', payload);

    //const { data } = await api.post("/exec/pr_egis_contabilidade_processo_modulo", payload)
    
    const resp = await api.post("/exec/pr_egis_contabilidade_processo_modulo", payload)
    const data = resp?.data ?? resp
    
    console.log("[my_8833] retorno bruto api:", data)

    //if (myToken !== this._reqLancToken) return

    const rowsRaw = Array.isArray(data) ? data : (data?.recordset || data?.rows || [])
    const rows = this.stripStatusRows(rowsRaw).map((r, i) => ({ ...r, id: r.id ?? i + 1 }))

    console.log('registros do lanc ', rows);

    this.lancamentos = rows

    const atributos = this.getLancamentoAtributos(rows)
    const mapa = await this.getMapaCaptionLanc(atributos)

    this.lancamentoColumns =
      this.buildLancamentoColumnsComMapa(rows, mapa)

    console.log('mapa',mapa, atributos, rows)
         //this.keyExprLanc = "id"

    //this.keyExprLanc = this.resolveKeyExpr(rows)
    
    //console.log('keyExprLanc', this.keyExprLanc);
    
    if (!this.lancamentoColumns || this.lancamentoColumns.length === 0) {
       this.lancamentoColumns = this.buildLancamentoColumns(rows)
    }

    //this.keyExprLanc = "id"
    
    this.keyExprLanc = this.resolveKeyExpr(rows)
    console.log('keyExprLanc', this.keyExprLanc);
    
    //
    this.loteLancamentosCarregado = cdLote
    //

    this.$nextTick(() => {
  this.gridLancVersion++   // ✅ força recriar o grid com colunas novas

  this.$nextTick(() => {
    const inst = this.$refs.gridLanc && this.$refs.gridLanc.instance
    if (inst) {
      inst.refresh()
      inst.updateDimensions()
    }
  })
})

    

  } finally {
    this.carregandoLancamentos = false
  }
},


     async recarregarLancamentos() {
     if (this.ultimoRegistroPai) {
        await this.carregarLancamentos(this.ultimoRegistroPai)
     }
    },

    async beforeFetchRowsHook({ filtros }) {
      if (filtros && filtros.cd_empresa == null) {
        filtros.cd_empresa = Number(localStorage.cd_empresa || 0)
      }
    },

    async mapPayloadHook({ payload = {}, engine }) {
      const cdEmpresa = Number(localStorage.cd_empresa || 0)
      const cdLote =
        this.loteSelecionado ||
        payload?.cd_lote ||
        engine?.paiSelecionadoId ||
        null

      return {
        ...payload,
        cd_empresa: cdEmpresa,
        ...(cdLote ? { cd_lote: cdLote } : {}),
      }
    },

    buildConsultaToAtributoMap(meta = []) {
  const map = {}
  ;(meta || []).forEach(m => {
    const k = (m?.nm_atributo_consulta || "").trim()
    const v = (m?.nm_atributo || "").trim()
    if (k && v) map[k] = v
  })
  return map
},


mapRegistroConsultaParaAtributo(registro, consultaToAttr) {
  const out = { ...(registro || {}) }

  // copia valores: "Lote" -> "cd_lote" (por exemplo)
  Object.keys(registro || {}).forEach(k => {
    const target = consultaToAttr?.[k]
    if (target && out[target] == null) {
      out[target] = registro[k]
    }
  })

  return out
},

 async carregarLancamentos(registro) {
  const engine = this.$refs.engine
  if (!engine) return

  // 1) normaliza via meta (se tiver)
  const reg = this.normalizaRegistroComMeta(registro, engine)

  // 2) pega cdLote com fallback (Lote / id array / etc)
  const cdLote = this.getCdLoteFromRegistro(reg)

  console.log("[my_8833] cdLote calculado =", cdLote, "reg normalizado=", reg)

  if (!cdLote) return



      this.ultimoRegistroPai = registro
      this.loteSelecionado = cdLote || null
      this.carregandoLancamentos = false
      this.loteLancamentosCarregado = null // força reload na aba

      if (this.aba === "lancamentos" && this.loteSelecionado) {
       await this.carregarLancamentosPorLote(this.loteSelecionado)
      }

    },

async getMapaCaptionLanc(atributos = []) {
  // se não tem colunas, não chama nada
  if (!Array.isArray(atributos) || atributos.length === 0) return {}

  // cache por chave (lista de atributos)
  const key = JSON.stringify(atributos.map(a => a.nm_atributo).sort())
  if (!this._cacheMapaLanc) this._cacheMapaLanc = {}

  if (this._cacheMapaLanc[key]) return this._cacheMapaLanc[key]

  const mapa = await this.carregarMapaAtributos(atributos)
  this._cacheMapaLanc[key] = mapa || {}
  return this._cacheMapaLanc[key]
},


 getCdLoteFromRegistro(reg) {
  if (!reg) return null

  // 1) padrão do sistema
  let v = reg.cd_lote ?? reg.cd_chave_pesquisa

  // 2) quando veio com label "Lote"
  if (v == null) v = reg.Lote ?? reg["Lote"]

  // 3) quando vem em chave composta (id array) -> último número
  if (v == null && Array.isArray(reg.id)) {
    const lastNum = [...reg.id].reverse().find(x => Number(x) > 0)
    v = lastNum
  }

  const n = Number(v || 0)
  return n > 0 ? n : null
},

normalizaRegistroComMeta(registro, engine) {
  const meta =
    engine?.meta ||
    engine?.atributos ||
    engine?.menuAtributos ||
    engine?.metaAtributos ||
    []

  const consultaToAttr = this.buildConsultaToAtributoMap(meta)
  return this.mapRegistroConsultaParaAtributo(registro, consultaToAttr)
},
 
getCdLoteFromRegistro(reg) {
  if (!reg) return null

  // 1) padrão do sistema
  let v = reg.cd_lote ?? reg.cd_chave_pesquisa

  // 2) quando veio com label "Lote"
  if (v == null) v = reg.Lote ?? reg["Lote"]

  // 3) quando vem em chave composta (id array) -> último número
  if (v == null && Array.isArray(reg.id)) {
    const lastNum = [...reg.id].reverse().find(x => Number(x) > 0)
    v = lastNum
  }

  const n = Number(v || 0)
  return n > 0 ? n : null
},

normalizaRegistroComMeta(registro, engine) {
  const meta =
    engine?.meta ||
    engine?.atributos ||
    engine?.menuAtributos ||
    engine?.metaAtributos ||
    []

  const consultaToAttr = this.buildConsultaToAtributoMap(meta)
  return this.mapRegistroConsultaParaAtributo(registro, consultaToAttr)
},

ensureLancamentoTab(engine) {
  const cdMenuFilho = LANCAMENTO_MENU_ID
  const key = `det_${cdMenuFilho}`

  const tabs = Array.isArray(engine.tabsDetalhe) ? engine.tabsDetalhe : []
  let tab = tabs.find(t => t && (t.key === key || Number(t.cd_menu) === cdMenuFilho))

  if (tab) return tab

  tab = { key, cd_menu: cdMenuFilho, label: "Lançamentos", disabled: false }
  // Vue2: garantir reatividade
  engine.tabsDetalhe = tabs.concat([tab])
  return tab

},


    populateLancamentosFilho({ engine, tab, rows, columns, cdLote, registro }) {
  const cdMenuFilho = Number(tab.cd_menu || LANCAMENTO_MENU_ID)
  const keyExpr = this.resolveKeyExpr(rows)

  if (!engine.filhos) engine.filhos = {}

  // ✅ Vue2: use $set no objeto inteiro do filho
  engine.$set(engine.filhos, cdMenuFilho, {
    ...(engine.filhos[cdMenuFilho] || {}),
    rows,
    columns,
    keyExpr,
    keyName: keyExpr,
    filtro: "",
    meta: (engine.filhos[cdMenuFilho] && engine.filhos[cdMenuFilho].meta) || [],
  })

  engine.paiSelecionadoId = cdLote
  engine.idPaiDetalhe = cdLote

  engine.paiSelecionadoTexto =
    registro?.nm_lote ||
    registro?.ds_lote ||
    registro?.ds_historico_contabil ||
    ""

  // ✅ ativa a aba no padrão do engine
  engine.abaAtiva = `det_${cdMenuFilho}`
},

    buildLancamentoColumns(rows) {
      const exemplo = Array.isArray(rows) && rows.length ? rows[0] : {}
      const chavesIgnorar = ["sucesso", "codigo", "mensagem"]

      return Object.keys(exemplo)
        .filter((key) => !chavesIgnorar.includes(key))
        .map((key) => ({
          dataField: key,
          caption: this.formatCaption(key),
          alignment: this.isNumber(exemplo[key]) ? "right" : "left",
          visible: key !== "linhaGridColor",
        }))
    },

    formatCaption(key) {
      return String(key || "")
        .replace(/_/g, " ")
        .replace(/\b\w/g, (c) => c.toUpperCase())
    },

    isNumber(value) {
      if (typeof value === "number") return true
      if (value === null || value === undefined || value === "") return false
      const parsed = Number(value)
      return !Number.isNaN(parsed)
    },

    resolveKeyExpr(rows) {
      const exemplo = Array.isArray(rows) && rows.length ? rows[0] : {}
      const candidatos = [
        "cd_lancamento_contabil",
        "cd_lote",
        "id",
      ]

      const encontrado = candidatos.find((k) => Object.prototype.hasOwnProperty.call(exemplo, k))
      return encontrado || "id"
  
    },

    stripStatusRows(rows) {
      if (!Array.isArray(rows)) return []
      const clone = rows.slice()
      const last = clone[clone.length - 1]
      const statusKeys = ["sucesso", "codigo", "mensagem"]
      const isOnlyStatus =
        last &&
        Object.keys(last).length &&
        Object.keys(last).every((k) => statusKeys.includes(k.toLowerCase()))

      if (isOnlyStatus) clone.pop()
      return clone
    },


    getLancamentoAtributos(rows) {
  const exemplo = rows?.[0] || {}
  return Object.keys(exemplo)
    .filter(k => !["sucesso", "codigo", "mensagem", "linhaGridColor", "id"].includes(k))
    .map(nm_atributo => ({ nm_atributo }))
},

async carregarMapaAtributos(atributos) {
  const payload = [
    { ic_json_parametro: 'S', cd_parametro: 1, cd_tabela: 0 },
    { dados: atributos }
  ]

  //const { data } = await api.post("/exec/pr_egis_pesquisa_mapa_atributo", payload)
  const resp = await api.post("/exec/pr_egis_pesquisa_mapa_atributo", payload)
  const data = resp?.data ?? resp
    
  const rowsRaw = Array.isArray(data) ? data : (data?.recordset || data?.rows || [])
  const map = {}

  // ⚠️ aqui depende do retorno real.
  // A ideia é: map["vl_debito"] = "Débito"
  rowsRaw.forEach(r => {
    const attr = (r?.nm_atributo || "").trim()
    const cap  = (r?.nm_atributo_consulta || r?.nm_titulo || r?.ds_atributo || "").trim()
    if (attr) map[attr] = cap || attr
  })

  return map
},

buildLancamentoColumnsComMapa(rows, mapaCaption) {
  const exemplo = rows?.[0] || {}
  const keys = Object.keys(exemplo).filter(k => !["sucesso","codigo","mensagem"].includes(k))

  return keys.map((k) => ({
    dataField: k,
    caption: mapaCaption?.[k] || this.formatCaption(k),
    alignment: this.isNumber(exemplo[k]) ? "right" : "left",
    visible: k !== "linhaGridColor",
  }))
}



  },

  //

  mounted() {

  let tentativas = 0

  const t = setInterval(() => {
    tentativas++
    const engine = this.$refs.engine
    if (!engine) return

    // espera o engine ficar pronto
   // espera o engine ficar pronto
if (typeof engine.onRowClickPrincipal !== "function") {
  if (tentativas > 80) clearInterval(t)
  return
}


    clearInterval(t)

    // 1) RowClick: NÃO carrega lançamentos, só sincroniza seleção e libera a tab
    const originalRowClick = engine.onRowClickPrincipal.bind(engine)
    engine.onRowClickPrincipal = async (evt) => {
      await originalRowClick(evt)

      const registro = evt?.data || evt?.row?.data
      this.ultimoRegistroPai = registro

      const regNorm = this.normalizaRegistroComMeta(registro, engine)
      const cdLote = this.getCdLoteFromRegistro(regNorm)

      this.loteSelecionado = cdLote || null
      this.loteLancamentosCarregado = null
      this.lancamentos = []
      this.lancamentoColumns = []
      

      //if (regNorm) await this.carregarLancamentos(regNorm) // só set lote, não carrega

    }

    // 2) Checkbox / seleção: aqui entra o teu IF de "deselecionou"
    // 2) Checkbox / seleção: aqui entra o teu IF de "deselecionou"
if (typeof engine.onSelectionChangedGrid === "function") {
  const originalSel = engine.onSelectionChangedGrid.bind(engine)
  engine.onSelectionChangedGrid = async (e) => {
    await originalSel(e)

    if (!e?.selectedRowKeys?.length) {
      this.loteSelecionado = null
      this.loteLancamentosCarregado = null
      this.lancamentos = []
      this.lancamentoColumns = []
      this.ultimoRegistroPai = null
    } else {
      const reg = e?.selectedRowsData?.[0]
      if (reg) await this.carregarLancamentos(reg) // só set lote, não carrega
    }
  }
}


  }, 50)
}

  //



}
</script>
