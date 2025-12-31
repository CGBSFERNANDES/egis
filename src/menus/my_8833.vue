<template>
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
    @selecionou="onSelecionou"
    @voltar="onVoltar"
    @fechar="onFechar"
  />
</template>

<script>
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue"
import api from "@/boot/axios"

const MENU_ID = 8833
const LANCAMENTO_MENU_ID = 883300
const LANCAMENTO_TAB_KEY = "det_lancamentos"

export default {
  name: "my_8833",
  components: { UnicoFormEspecial },

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
      loteSelecionado: null,
      lancamentos: [],
      lancamentoColumns: [],
      carregandoLancamentos: false,

      overrides: {
        title: "Lote Contábeis",
        gridPageSize: 200,
      },
    }
  },

  computed: {
    engineHooks() {
      return {
        beforeFetchRows: this.beforeFetchRowsHook,
        mapPayload: this.mapPayloadHook,
      }
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

    async carregarLancamentos(registro) {
      const engine = this.$refs.engine
      const cdLote =
        Number(registro?.cd_lote || registro?.cd_chave_pesquisa || 0) || null

      if (!engine || !cdLote) return

      this.loteSelecionado = cdLote
      this.carregandoLancamentos = true

      try {
        const payload = [
          {
            ic_json_parametro: "S",
            cd_parametro: 2,
            cd_lote: cdLote,
            cd_empresa: Number(localStorage.cd_empresa || 0),
          },
        ]

        const { data } = await api.post(
          "/exec/pr_egis_contabilidade_processo_modulo",
          payload
        )

        const rows = this.stripStatusRows(
          Array.isArray(data) ? data : data?.recordset || data?.rows || []
        )
        const columns = this.buildLancamentoColumns(rows)

        this.lancamentos = rows
        this.lancamentoColumns = columns

        const tab = this.ensureLancamentoTab(engine)
        this.populateLancamentosFilho({ engine, tab, rows, columns, cdLote, registro })
      } catch (err) {
        // mantém o fluxo do engine sem quebrar
        console.error("Falha ao carregar lançamentos do lote", err)
      } finally {
        this.carregandoLancamentos = false
      }
    },

    ensureLancamentoTab(engine) {
      const tabs = Array.isArray(engine.tabsDetalhe)
        ? engine.tabsDetalhe.slice()
        : []

      let tab =
        tabs.find(
          (t) =>
            t.key === LANCAMENTO_TAB_KEY ||
            (t.label &&
              (t.label.toLowerCase().includes("lançamento") ||
                t.label.toLowerCase().includes("lancamento")))
        ) || null

      if (tab) {
        tab = {
          ...tab,
          key: tab.key || LANCAMENTO_TAB_KEY,
          cd_menu: tab.cd_menu || LANCAMENTO_MENU_ID,
          label: tab.label || "Lançamentos",
          disabled: false,
        }
        const idx = tabs.findIndex((t) => t.key === tab.key || t === tab)
        tabs.splice(idx, 1, tab)
      } else {
        tab = {
          key: LANCAMENTO_TAB_KEY,
          cd_menu: LANCAMENTO_MENU_ID,
          label: "Lançamentos",
          disabled: false,
        }
        tabs.push(tab)
      }

      engine.tabsDetalhe = tabs
      return tab
    },

    populateLancamentosFilho({ engine, tab, rows, columns, cdLote, registro }) {
      const cdMenuFilho = tab.cd_menu || LANCAMENTO_MENU_ID
      const keyExpr = this.resolveKeyExpr(rows)

      if (!engine.filhos) engine.filhos = {}
      engine.$set(engine.filhos, cdMenuFilho, {
        ...(engine.filhos[cdMenuFilho] || {}),
        rows,
        columns,
        keyExpr,
        keyName: keyExpr,
        filtro: "",
      })

      engine.paiSelecionadoId = cdLote
      engine.idPaiDetalhe = cdLote
      engine.paiSelecionadoTexto =
        registro?.nm_lote ||
        registro?.ds_lote ||
        registro?.ds_historico_contabil ||
        registro?.nm_conta ||
        ""
      engine.abaAtiva = tab.key
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
  },

  mounted() {
    this.$nextTick(() => {
      const engine = this.$refs.engine

      if (engine && typeof engine.onRowClickPrincipal === "function") {
        const original = engine.onRowClickPrincipal.bind(engine)
        engine.onRowClickPrincipal = async (evt) => {
          await original(evt)
          await this.carregarLancamentos(evt?.data || evt?.row?.data)
        }
      }
    })
  },
}
</script>
