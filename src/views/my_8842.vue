<template>
<div>
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
      :services="services"
      @voltar="onVoltar"
      @fechar="onFechar"
    >
      <template #toolbar-right="{ engine }">
        <q-btn
          dense
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="download"
          size="lg"
          :disable="visao !== 'analitico' || !temXmlDisponivel"
          @click="baixarZipXml()"
        >
          <q-tooltip>Download XML (parâmetro 20)</q-tooltip>
        </q-btn>

        <q-btn
          dense
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="article"
          size="lg"
          :disable="visao !== 'analitico'"
          @click="visualizarXml(engine)"
        >
          <q-tooltip>Visualizar XML</q-tooltip>
        </q-btn>
      </template>
    </unico-form-especial>

  <div class="monitor-nfe q-pa-sm">
    <q-card flat bordered class="q-mb-md">
      <q-card-section>
        <div class="row q-col-gutter-md">
          <div class="col-12 col-md-3">
            <q-select
              v-model="filtros.modelo"
              :options="modelos"
              option-label="label"
              map-options
              dense
              outlined
              clearable
              :loading="loadingCombos"
              label="Modelo"
            />
          </div>

          <div class="col-12 col-md-3">
            <q-select
              v-model="filtros.tipo"
              :options="tiposOperacao"
              option-label="label"
              map-options
              dense
              outlined
              clearable
              :loading="loadingCombos"
              label="Tipo de Operação"
            />
          </div>

          <div class="col-12 col-md-3">
            <q-select
              v-model="filtros.serie"
              :options="seriesFiltradas"
              :option-label="serieLabel"
              map-options
              dense
              outlined
              clearable
              :loading="loadingCombos"
              label="Série"
            />
          </div>

          <div class="col-12 col-md-3">
            <q-select
              v-model="filtros.empresa"
              :options="empresas"
              option-value="cd_empresa"
              option-label="nm_fantasia_empresa"
              map-options
              dense
              outlined
              clearable
              :loading="loadingCombos"
              label="Empresa"
            />
          </div>

          <div class="col-12 col-md-3">
            <q-input
              v-model="filtros.dt_inicial"
              dense
              outlined
              type="date"
              label="Data inicial"
            />
          </div>
          <div class="col-12 col-md-3">
            <q-input
              v-model="filtros.dt_final"
              dense
              outlined
              type="date"
              label="Data final"
            />
          </div>

          <div class="col-12 col-md-6">
            <div class="row items-center q-col-gutter-sm">
              <div class="col-12 col-md-6">
                <q-btn-toggle
                  v-model="visao"
                  dense
                  rounded
                  toggle-color="deep-purple-7"
                  unelevated
                  :options="[
                    { label: 'Resumo', value: 'resumo' },
                    { label: 'Analítico', value: 'analitico' },
                  ]"
                />
              </div>
              <div class="col-12 col-md-6">
                <q-select
                  v-model="periodoParametro"
                  :options="periodos"
                  emit-value
                  map-options
                  dense
                  outlined
                  label="Período"
                  :disable="visao === 'analitico'"
                />
              </div>
            </div>
          </div>
        </div>

        <div class="row items-center q-col-gutter-sm q-mt-md">
          <q-btn
            color="deep-purple-7"
            rounded
            icon="refresh"
            label="Atualizar"
            :loading="loadingConsulta"
            @click="atualizarConsulta"
          />
          <q-btn
            flat
            rounded
            color="grey-8"
            icon="restart_alt"
            label="Limpar"
            class="q-ml-sm"
            @click="resetarFiltros"
          />
          <q-space />
          <div class="text-caption text-grey-7">
            Fonte: pr_egis_nfe_monitor_processo (parâmetro {{ parametroAtual }})
          </div>
        </div>
      </q-card-section>
    </q-card>

    <div v-if="cards.length" class="row q-col-gutter-md q-mb-md">
      <div
        v-for="card in cards"
        :key="card.key"
        class="col-12 col-sm-6 col-md-3"
      >
        <q-card flat bordered class="bg-grey-1">
          <q-card-section>
            <div class="text-caption text-grey-7">{{ card.titulo }}</div>
            <div class="text-h6 text-weight-bold">{{ card.valor }}</div>
            <div class="text-caption text-grey-6" v-if="card.subtitulo">
              {{ card.subtitulo }}
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    
    <q-dialog v-model="dialogoXml" maximized content-class="dlg-form-branco">
      <q-card class="q-pa-md" style="min-height: 60vh">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">{{ xmlTitulo }}</div>
          <q-space />
          <q-btn dense flat icon="close" v-close-popup />
        </q-card-section>

        <q-separator />

        <q-card-section>
          <pre class="xml-viewer">{{ xmlConteudo }}</pre>
        </q-card-section>
      </q-card>
    </q-dialog>
  </div>
</div>
</template>

<script>
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue"
import api from "@/boot/axios"
import { saveAs } from "file-saver"
import PizZip from "pizzip"

const MENU_ID = 8842
const PROC = "/exec/pr_egis_nfe_monitor_processo"
const MAPA_PROC = "/exec/pr_egis_pesquisa_mapa_atributo"

export default {
  name: "monitorNFe",
  components: { UnicoFormEspecial },

  props: {
    embedMode: { type: Boolean, default: false },
    registroPai: { type: Object, default: null },
    cdChaveRegistro: { type: Number, default: 0 },
  },

  data() {
    const hoje = new Date()
    const inicioMes = new Date(hoje.getFullYear(), hoje.getMonth(), 1)

    return {
      MENU_ID,
      cdAcesso: Number(localStorage.cd_chave_pesquisa || 0),
      modoInicial: "GRID",
      visao: "resumo",
      periodoParametro: 5,
      filtros: {
        modelo: null,
        tipo: null,
        serie: null,
        empresa: null,
        dt_inicial: this.formatarData(inicioMes),
        dt_final: this.formatarData(hoje),
      },
      modelos: [],
      tiposOperacao: [],
      series: [],
      empresas: [],
      loadingCombos: false,
      loadingConsulta: false,
      cards: [],
      resumoRows: [],
      analiticoRows: [],
      mapaCaption: {},
      dialogoXml: false,
      xmlTitulo: "",
      xmlConteudo: "",
      overrides: {
        title: "Monitor de Notas Fiscais",
        gridPageSize: 200,
        hideButtons: {
          novo: true,
        },
      },
      services: {
        api,
      },
    }
  },

  computed: {
    engineHooks() {
      return {
        beforeFetchRows: this.beforeFetchRowsHook,
        mapPayload: this.mapPayloadHook,
        afterFetchRows: this.afterFetchRowsHook,
        onError: this.onHookError,
      }
    },

    periodos() {
      return [
        { label: "Resumo por Série", value: 5 },
        { label: "Hoje", value: 6 },
        { label: "Diário", value: 7 },
        { label: "Semanal", value: 8 },
        { label: "Mensal", value: 9 },
        { label: "Trimestral", value: 10 },
        { label: "Semestral", value: 11 },
        { label: "Anual", value: 12 },
      ]
    },

    parametroAtual() {
      return this.visao === "analitico" ? 20 : this.periodoParametro
    },

    seriesFiltradas() {
      const modelo = this.filtros.modelo?.cd_modelo
      if (!modelo) return this.series
      return this.series.filter((s) => {
        const cdModelo = s.cd_modelo_serie_nota || s.cd_modelo
        return !cdModelo || cdModelo === modelo
      })
    },

    temXmlDisponivel() {
      return this.analiticoRows.some((r) => r?.ds_xml_nota || r?.ds_nota_xml_retorno)
    },
  },

  methods: {
    onVoltar() {
      this.$router.back()
    },
    onFechar() {
      this.$router.back()
    },

    serieLabel(serie) {
      if (!serie) return ""
      const sigla = serie.sg_serie_nota_fiscal || serie.nm_serie_nota_fiscal
      const empresa = serie.nm_fantasia_empresa
      return [sigla, empresa].filter(Boolean).join(" – ")
    },

    formatarData(dateObj) {
      if (!(dateObj instanceof Date)) return ""
      const ano = dateObj.getFullYear()
      const mes = String(dateObj.getMonth() + 1).padStart(2, "0")
      const dia = String(dateObj.getDate()).padStart(2, "0")
      return `${ano}-${mes}-${dia}`
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

    async mountedFetch() {
      await this.carregarCombos()
      await this.atualizarConsulta()
    },

    async carregarCombos() {
      this.loadingCombos = true
      try {
        const [modelos, tipos, series, empresas] = await Promise.all([
          this.executarParametro(1),
          this.executarParametro(2),
          this.executarParametro(3),
          this.executarParametro(4),
        ])

        this.modelos = modelos
        this.tiposOperacao = tipos
        this.series = series
        this.empresas = empresas
      } catch (err) {
        console.error("Falha ao carregar listas do monitor NFe", err)
        this.$q?.notify?.({
          type: "negative",
          message: "Erro ao carregar listas iniciais",
        })
      } finally {
        this.loadingCombos = false
      }
    },

    async executarParametro(cd_parametro) {
      const payload = [
        {
          ic_json_parametro: "S",
          cd_parametro,
          cd_usuario: Number(localStorage.cd_usuario || 0),
          cd_empresa: Number(localStorage.cd_empresa || 0),
        },
      ]

      const resp = await api.post(PROC, payload)
      const data = resp?.data ?? resp
      console.log('dados : ', resp, data, cd_parametro)
      return this.stripStatusRows(Array.isArray(data) ? data : data?.recordset || data?.rows || [])
    },

    async atualizarConsulta() {
      const engine = this.$refs.engine
      if (!engine || typeof engine.onRefreshConsulta !== "function") return

      this.loadingConsulta = true

      await this.$nextTick()
      engine.onRefreshConsulta()
      
    },

    resetarFiltros() {
      const hoje = new Date()
      const inicioMes = new Date(hoje.getFullYear(), hoje.getMonth(), 1)

      this.filtros = {
        modelo: null,
        tipo: null,
        serie: null,
        empresa: null,
        dt_inicial: this.formatarData(inicioMes),
        dt_final: this.formatarData(hoje),
      }
      this.periodoParametro = 5
      this.visao = "resumo"
      this.atualizarConsulta()
    },

    beforeFetchRowsHook({ filtros }) {
      if (filtros && filtros.cd_empresa == null) {
        filtros.cd_empresa = Number(localStorage.cd_empresa || 0)
      }
      this.loadingConsulta = true
    },

    mapPayloadHook({ payload = {} }) {
      const cdEmpresa = Number(localStorage.cd_empresa || 0)
      const cdUsuario = Number(localStorage.cd_usuario || 0)

      return {
        ...payload,
        ic_json_parametro: "S",
        cd_parametro: this.parametroAtual,
        cd_empresa: cdEmpresa,
        cd_usuario: cdUsuario,
        cd_modelo: this.filtros.modelo?.cd_modelo || null,
        cd_serie_nota: this.filtros.serie?.cd_serie_nota_fiscal || null,
        cd_empresa_faturamento: this.filtros.empresa?.cd_empresa || null,
        dt_inicial: this.filtros.dt_inicial,
        dt_final: this.filtros.dt_final,
      }
    },

    async afterFetchRowsHook({ rows = [], engine }) {
      const limpos = this.stripStatusRows(rows)

      if (this.visao === "analitico") {
        this.analiticoRows = limpos
        this.cards = []
      } else {
        this.resumoRows = limpos
        this.cards = this.montarCards(limpos)
      }

      await this.aplicarMapaAtributos(engine, limpos)
      this.loadingConsulta = false
    },

    async aplicarMapaAtributos(engine, rows) {
      const atributos = this.extrairAtributos(rows)
      if (!atributos.length) return

      try {
        const mapa = await this.carregarMapaAtributos(atributos)
        this.mapaCaption = mapa

        if (engine && Array.isArray(engine.columns) && engine.columns.length) {
          engine.columns = engine.columns.map((c) => ({
            ...c,
            caption: mapa[c.dataField] || c.caption || c.name || c.dataField,
          }))
        }
      } catch (err) {
        console.warn("Mapa de atributos indisponível", err)
      }
    },

    extrairAtributos(rows) {
      const exemplo = Array.isArray(rows) && rows.length ? rows[0] : {}
      return Object.keys(exemplo)
        .filter((k) => !["sucesso", "codigo", "mensagem", "linhaGridColor"].includes(k))
        .map((nm_atributo) => ({ nm_atributo }))
    },

    async carregarMapaAtributos(atributos = []) {
      if (!atributos.length) return {}

      const payload = [
        { ic_json_parametro: "S", cd_parametro: 1, cd_tabela: 0 },
        { dados: atributos },
      ]

      const resp = await api.post(MAPA_PROC, payload)
      const data = resp?.data ?? resp
      const linhas = this.stripStatusRows(Array.isArray(data) ? data : data?.recordset || data?.rows || [])
      const mapa = {}

      linhas.forEach((r) => {
        const attr = (r?.nm_atributo || "").trim()
        const titulo = (r?.nm_atributo_consulta || r?.nm_titulo || r?.ds_atributo || "").trim()
        if (attr) mapa[attr] = titulo || attr
      })

      return mapa
    },

    montarCards(rows) {
      if (!Array.isArray(rows) || !rows.length) return []

      const totalNotas = rows.reduce((acc, r) => acc + Number(r.qt_nota_saida || 0), 0)
      const totalValor = rows.reduce((acc, r) => acc + Number(r.vl_total || 0), 0)
      const totalAnterior = rows.reduce((acc, r) => acc + Number(r.vl_total_ant || 0), 0)
      const ticketMedio = rows.reduce((acc, r) => acc + Number(r.ticket_medio || 0), 0) / rows.length

      return [
        {
          key: "notas",
          titulo: "Notas no período",
          valor: this.formatarNumero(totalNotas, "int"),
          subtitulo: this.filtros.dt_inicial && this.filtros.dt_final
            ? `${this.filtros.dt_inicial} até ${this.filtros.dt_final}`
            : "",
        },
        {
          key: "valor",
          titulo: "Valor total",
          valor: this.formatarNumero(totalValor, "moeda"),
          subtitulo: totalAnterior
            ? `Variação: ${this.formatarNumero(totalValor - totalAnterior, "moeda")}`
            : "",
        },
        {
          key: "ticket",
          titulo: "Ticket médio",
          valor: this.formatarNumero(ticketMedio, "moeda"),
          subtitulo: "Média ponderada pelo período",
        },
        {
          key: "participacao",
          titulo: "Participação média",
          valor: this.formatarNumero(
            rows.reduce((acc, r) => acc + Number(r.perc_participacao || 0), 0) / rows.length,
            "percentual"
          ),
          subtitulo: "Participação por série",
        },
      ]
    },

    formatarNumero(valor, tipo) {
      const num = Number(valor || 0)
      if (tipo === "moeda") return num.toLocaleString("pt-BR", { style: "currency", currency: "BRL" })
      if (tipo === "percentual") return `${num.toFixed(2)}%`
      if (tipo === "int") return num.toLocaleString("pt-BR")
      return num
    },

    primeiroRegistroSelecionado(engine) {
      const ctx = engine || this.$refs.engine
      if (!ctx) return null
      const selecionados = ctx.registrosSelecionados || []
      if (selecionados.length) return selecionados[0]
      return ctx.registroSelecionadoPrincipal || null
    },

    visualizarXml(engine) {
      if (this.visao !== "analitico") return
      const row = this.primeiroRegistroSelecionado(engine)
      if (!row) {
        this.$q?.notify?.({ type: "warning", message: "Selecione uma nota para visualizar" })
        return
      }

      const xml = row.ds_xml_nota || row.ds_nota_xml_retorno
      if (!xml) {
        this.$q?.notify?.({ type: "warning", message: "Registro sem XML disponível" })
        return
      }

      const numero = row.cd_nota_saida || row.cd_chave_acesso || "XML"
      this.xmlTitulo = `XML da Nota ${numero}`
      this.xmlConteudo = xml
      this.dialogoXml = true
    },

    baixarZipXml() {
      if (this.visao !== "analitico") return

      const registros = this.analiticoRows.filter((r) => r?.ds_xml_nota || r?.ds_nota_xml_retorno)
      if (!registros.length) {
        this.$q?.notify?.({
          type: "warning",
          message: "Nenhum XML disponível para download",
        })
        return
      }

      const zip = new PizZip()
      registros.forEach((r, idx) => {
        const xml = r.ds_xml_nota || r.ds_nota_xml_retorno
        const chave = (r.cd_chave_acesso || r.cd_nota_saida || idx + 1).toString().replace(/\s+/g, "")
        const nome = `nfe_${chave || idx + 1}.xml`
        zip.file(nome, xml)
      })

      const blob = zip.generate({ type: "blob" })
      saveAs(blob, `monitor-nfe-xmls-${Date.now()}.zip`)
      this.$q?.notify?.({ type: "positive", message: "Download gerado com sucesso" })
    },

    onHookError({ err, hook }) {
      console.error("Erro no hook", hook, err)
      this.loadingConsulta = false
      this.$q?.notify?.({ type: "negative", message: "Falha ao carregar dados" })
    },
  },

  mounted() {
    this.mountedFetch()
  },
}
</script>

<style scoped>
.monitor-nfe .xml-viewer {
  max-height: 70vh;
  overflow: auto;
  background: #0b1021;
  color: #e0e0e0;
  padding: 16px;
  border-radius: 8px;
  white-space: pre-wrap;
}
</style>
