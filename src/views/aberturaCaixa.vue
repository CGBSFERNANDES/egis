<template>
  <div>
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />
    <h2 v-if="ic_mostra_titulo" class="content-block">
      {{ tituloMenu }}
      <q-badge v-if="qt_registro > 0" align="middle" rounded color="red" :label="qt_registro" />

      <q-btn
        v-if="menu_relatorio"
        style="float: right"
        round
        flat
        color="black"
        @click="TogglePopupAltera()"
        icon="task"
      >
        <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
          Relatório
        </q-tooltip>
      </q-btn>
    </h2>

    <q-btn
      class="margin1"
      rounded
      color="green"
      icon="open_in_browser"
      label="Abrir Caixa"
      :loading="loading"
      :disabled="row_data.dt_abertura_caixa"
      @click="onAbrirCaixa()"
    >
      <q-tooltip> Abrir caixa </q-tooltip>
    </q-btn>

    <q-btn
      class="margin1"
      rounded
      color="primary"
      icon="attach_money"
      label="Retirada do caixa"
      :loading="loading"
      @click="onRetiradaCaixa()"
    >
      <q-tooltip> Retirada do caixa </q-tooltip>
    </q-btn>

    <Transition name="fade">
      <q-btn
        v-if="row_data.dt_abertura_caixa"
        class="margin1"
        rounded
        color="red"
        icon="close"
        label="Fechar caixa"
        :loading="loading"
        @click="onFecharCaixa()"
      >
        <q-tooltip> Fechar caixa </q-tooltip>
      </q-btn>
    </Transition>
    <!-- CRUD Form -->
    <Transition name="fade">
      <div v-if="show_grid_item" class="margin1 borda-bloco shadow-2">
        <div class="row">
          <div class="col-3" v-show="i.visible" v-for="i in column_item" :key="i.dataField">
            <q-input
              dense
              v-if="!i.lookup && i.dataType !== 'boolean'"
              class="margin1"
              :label="`${i.caption} ${i.ic_atributo_obrigatorio === 'S' ? '*' : ''}`"
              :type="i.dataType === 'string' ? 'text' : i.dataType"
              :stack-label="i.dataType === 'date'"
              clearable
              min="0"
              :readonly="i.readonly"
              :maxlength="String(i.qt_tamanho_atributo) > '0' ? Number(i.qt_tamanho_atributo) : 20"
              v-model="grid_item[i.dataField]"
              @input="Digitou($event, grid_item[i.dataField])"
              :hint="
                String(i.qt_tamanho_atributo) > '0'
                  ? `${grid_item[i.dataField] ? String(grid_item[i.dataField]).length : 0}/${
                      i.qt_tamanho_atributo
                    }`
                  : ''
              "
            />
            <q-toggle
              v-if="!i.lookup && i.dataType === 'boolean'"
              class="margin1"
              :label="`${i.caption} ${i.ic_atributo_obrigatorio === 'S' ? '*' : ''}`"
              v-model="grid_item[i.dataField]"
              color="primary"
              true-value="S"
              false-value="N"
              checked-icon="check"
              unchecked-icon="clear"
              :readonly="i.readonly"
              @input="onToggle(grid_item[i.dataField], 5)"
            />
            <q-select
              dense
              class="margin1"
              v-if="i.lookup"
              v-model="grid_item[`${i.dataField}`]"
              :readonly="i.readonly"
              :options="i.lookup.dataSource"
              :label="`${i.caption} ${i.ic_atributo_obrigatorio === 'S' ? '*' : ''}`"
              :option-value="i.lookup.valueExpr"
              :option-label="i.lookup.displayExpr"
              @input="onSelect(grid_item[`${i.dataField}`])"
            />
          </div>
        </div>
        <!-- Buttons -->
        <div class="margin1">
          <q-btn
            rounded
            class="margin1"
            color="green"
            icon="check"
            label="Gravar"
            :loading="loading"
            @click="onSave()"
          />

          <q-btn
            rounded
            class="margin1"
            color="grey"
            icon="cancel"
            label="Fechar"
            :loading="loading"
            @click="onFechar()"
          />
        </div>
      </div>
    </Transition>
    <!-- CRUD Form -->

    <dx-data-grid
      class="dx-card wide-card"
      :data-source="dataSourceConfig"
      :columns="columns"
      :summary="total"
      :key-expr="sChave"
      :show-borders="true"
      :focused-row-enabled="focogrid"
      :column-auto-width="true"
      :column-hiding-enabled="false"
      :remote-operations="false"
      :word-wrap-enabled="false"
      :allow-column-reordering="true"
      :allow-column-resizing="true"
      :row-alternation-enabled="true"
      :repaint-changes-only="true"
      :autoNavigateToFocusedRow="true"
      :focused-row-index="0"
      :cacheEnable="false"
      :column-min-width="50"
      :show-column-lines="false"
      @row-dbl-click="onFocusedRowChanged"
      @row-click="onFocusedRowChanged"
      @focused-row-changed="onFocusedRowChanged"
    >
      <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

      <DxGrouping :auto-expand-all="true" />

      <DxExport :enabled="true" />

      <DxPaging :enable="true" :page-size="10" />

      <DxStateStoring :enabled="true" type="localStorage" :storage-key="menu" />

      <DxSelection mode="single" />
      <DxPager :show-page-size-selector="true" :allowed-page-sizes="pageSizes" :show-info="true" />
      <DxFilterRow :visible="false" />
      <DxHeaderFilter :visible="true" :allow-search="true" />
      <DxSearchPanel :visible="temPanel" :width="300" placeholder="Procurar..." />

      <DxFilterPanel :visible="true" />
      <DxColumnFixing :enabled="true" />

      <DxColumnChooser :enabled="true" mode="select" />

      <DxEditing
        :refresh-mode="refreshMode"
        :allow-adding="false"
        :allow-updating="false"
        :allow-deleting="false"
        mode="popup"
      >
      </DxEditing>
    </dx-data-grid>
    <q-dialog v-model="load_grid" maximized persistent>
      <carregando :mensagemID="'Carregando...'" :corID="'orange-9'"></carregando>
    </q-dialog>

    <!-- relatório Modulo -->
    <q-dialog
      v-model="ic_relatorio_menu"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-9 text-white">
          {{ `Relatórios - ${tituloMenu}` }}
          <q-space />
          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white">Minimizar</q-tooltip>
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white">Maximizar</q-tooltip>
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section class="q-pt-none">
          <relatorio-modulo
            @FechaPopup="TogglePopupAltera()"
            :ic_perda="true"
            :cd_menuID="parseInt(cd_menu)"
          />
        </q-card-section>
      </q-card>
    </q-dialog>
    <!-- Valores Divergentes -->
    <q-dialog v-model="ic_popup_valores_divergentes" content-class="dialog--fit">
      <q-card class="q-pa-md row items-start q-gutter-md">
        <q-card-section>
          <div class="text-h4">Valores Divergentes</div>
        </q-card-section>
        <div class="row items-stretch q-gutter-md q-pt-sm">
          <q-card-section class="col">
            <p class="text-h6">Atual</p>
            <q-input v-model="vl_caixa_atual.vl_caixa_dinheiro" readonly label="Dinheiro" />
            <!-- <q-input v-model="vl_caixa_atual.vl_cartao_credito" label="Cartão de Crédito" />
            <q-input v-model="vl_caixa_atual.vl_cartao_debito" label="Cartão de Débito" /> -->
            <q-input v-model="vl_caixa_atual.vl_pix" readonly label="PIX" />
            <q-input v-model="vl_caixa_atual.vl_voucher" readonly label="Voucher" />
          </q-card-section>

          <q-separator vertical />

          <q-card-section class="col">
            <p class="text-h6">Informados</p>
            <q-input v-model="grid_item.vl_ultimo_fechamento" label="Dinheiro" />
            <!-- <q-input v-model="grid_item.vl_cartao_credito" label="Cartão de Crédito" />
            <q-input v-model="grid_item.vl_cartao_debito" label="Cartão de Débito" /> -->
            <q-input v-model="grid_item.vl_pix" label="PIX" />
            <q-input v-model="grid_item.vl_voucher" label="Voucher" />
          </q-card-section>
        </div>
        <q-card-section>
          <q-input
            v-model="grid_item.nm_obs_fechamento_caixa"
            label="Justificativa"
            :rules="[(val) => !!val || 'Campo obrigatório']"
          />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn rounded label="Confirmar" @click="confirmarValoresDivergentes" color="primary" />
          <q-btn rounded label="Fechar" color="red" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!-- Valores Divergentes -->
  </div>
</template>

<script>
import {
  DxDataGrid,
  DxFilterRow,
  DxPager,
  DxPaging,
  DxExport,
  DxGroupPanel,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxSelection,
  DxStateStoring,
  DxSearchPanel,
  DxEditing,
} from 'devextreme-vue/data-grid'

import ExcelJS from 'exceljs'
import saveAs from 'file-saver'
import ptMessages from 'devextreme/localization/messages/pt.json'
import { locale, loadMessages } from 'devextreme/localization'
import config from 'devextreme/core/config'
import notify from 'devextreme/ui/notify'
import Menu from '../http/menu'
import Incluir from '../http/incluir_registro'
import 'whatwg-fetch'
import funcao from '../http/funcoes-padroes.js'
import { jsPDF } from 'jspdf'
import 'jspdf-autotable'
import { exportDataGrid } from 'devextreme/excel_exporter'
import lookup from '../http/lookup'
import axios from 'axios'
var cd_empresa = 0
var cd_menu = 0
var cd_api = 0

var filename = 'DataGrid.xlsx'
var filenamepdf = 'pdf'

var dados = []

export default {
  props: {
    cd_apiID: { type: Number, default: 0 },
    cd_menuID: { type: Number, default: 0 },
    ic_mostra_titulo: { type: Boolean, default: true },
  },
  data() {
    return {
      tituloMenu: '',
      menu: '',
      loading: false,
      cd_menu: localStorage.cd_menu,
      show_grid_item: false,
      load_grid: false,
      menu_relatorio: false,
      ic_relatorio_menu: false,
      maximizedToggle: true,
      ic_popup_valores_divergentes: false,
      ic_confirma_valores_divergentes: false,
      grid_item: new Object(),
      ic_tipo_operacao_caixa: '',
      lookup_operador: [],
      lookup_Tipo_Despesa: [],
      lookup_Motivo_Retirada_Caixa: [],
      column_item: [],
      columns: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      total: {},
      api: 0,
      row_data: {},
      vl_caixa_atual: {},
      taskDetails: '',
      temPanel: false,
      refreshMode: 'full',
      sChave: '',
      tituloColuna: [],
      focogrid: false,
      qt_registro: 0,
      cd_api_autoform: 0,
      cd_menu_autoform: 0,
      cd_tipo_email: 0,
      cd_relatorio: 0,
      nm_template: '',
    }
  },

  async created() {
    config({ defaultCurrency: 'BRL' })
    loadMessages(ptMessages)
    locale(navigator.language)
  },

  async mounted() {
    this.cd_api_autoform = this.cd_apiID
    this.cd_menu_autoform = this.cd_menuID
    await this.carregaDados()
  },

  components: {
    DxDataGrid,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxGrouping,
    DxColumnChooser,
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxSelection,
    DxStateStoring,
    DxSearchPanel,
    DxEditing,
    carregando: () => import('../components/carregando.vue'),
    relatorioModulo: () => import('../components/relatorioModulo.vue'),
  },

  methods: {
    exportGrid() {
      const doc = new jsPDF()

      doc.autoTable({ html: '#my-table' })
      // Or use javascript directly:

      var t = ['Desenvolvimento - Aguardar Liberação nova Versão !']

      doc.autoTable({
        head: [[t]],

        body: [
          ['< Previsão: Fevereiro/2021 >'],
          // ...
        ],
      })
      doc.save(filenamepdf)
    },

    onFocusedRowChanged: function (e) {
      this.row_data = e.row.data
      this.grid_item = e.row.data
    },

    async carregaDados() {
      this.temPanel = true

      if (this.lookup_operador.length === 0) {
        let dados_lookup_operador = await lookup.montarSelect(localStorage.cd_empresa, 2092)
        this.lookup_operador = JSON.parse(JSON.parse(JSON.stringify(dados_lookup_operador.dataset)))
      }
      // Motivo Retirada Caixa
      if (this.lookup_Motivo_Retirada_Caixa.length === 0) {
        let dados_lookup_Motivo_Retirada_Caixa = await lookup.montarSelect(
          localStorage.cd_empresa,
          1448
        )
        this.lookup_Motivo_Retirada_Caixa = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_Motivo_Retirada_Caixa.dataset))
        )
      }
      // Tipo Despesa
      if (this.lookup_Tipo_Despesa.length === 0) {
        let dados_lookup_Tipo_Despesa = await lookup.montarSelect(localStorage.cd_empresa, 438)
        this.lookup_Tipo_Despesa = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_Tipo_Despesa.dataset))
        )
      }

      cd_empresa = localStorage.cd_empresa
      if (this.cd_menu_autoform) {
        cd_menu = String(this.cd_menu_autoform)
      } else {
        cd_menu = localStorage.cd_menu
      }
      ////////////////////////////////////
      if (this.cd_api_autoform) {
        cd_api = String(this.cd_api_autoform)
      } else {
        cd_api = localStorage.cd_api
      }

      localStorage.nm_identificacao_api

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api) //'titulo';

      this.menu_relatorio = true //dados.menu_relatorio;

      if (!dados.nm_identificacao_api == '') {
        dados.nm_identificacao_api
      }

      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta

      //API do Crud
      this.tituloColuna = dados.tituloColuna

      this.tituloMenu = dados.nm_menu_titulo
      this.menu = dados.nm_menu
      this.cd_tipo_email = dados.cd_tipo_email
      this.cd_relatorio = dados.cd_relatorio
      this.nm_template = dados.nm_template
      if (!dados.chave == '') {
        this.sChave = dados.chave
        this.focogrid = true
      }
      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)))
      this.columns.map((c) => {
        if (c.dataType === 'date') {
          c.calculateCellValue = (row) => {
            if (!row[c.dataField]) return ''
            if (row[c.dataField].length < 10) return row[c.dataField]

            const [datePart] = row[c.dataField].split(' ')
            const [year, month, day] = datePart.split('-')
            return day && month && year
              ? `${day.substring(0, 2)}/${month}/${year}`
              : row[c.dataField]
          }
        }
      })
      this.column_item = this.columns.filter((e) => {
        return e.caption !== 'cd_controle'
      })
      this.limpaCampos()
      this.total = {}

      if (dados.coluna_total) {
        this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)))
      }
      //Gera os Dados para Montagem da Grid
      //exec da procedure

      this.api = localStorage.nm_identificacao_api || dados.nm_identificacao_api
      const jsonData = {
        cd_parametro: 0,
      }
      this.dataSourceConfig = await Incluir.incluirRegistro(this.api, jsonData)

      this.qt_registro = this.dataSourceConfig.length

      filename = this.tituloMenu + '.xlsx'
      filenamepdf = this.tituloMenu + '.pdf'
    },

    Digitou() {},

    confirmarValoresDivergentes() {
      if (
        this.grid_item.nm_obs_fechamento_caixa === '' ||
        !this.grid_item.nm_obs_fechamento_caixa
      ) {
        notify('Justifique a divergência!')
        return
      }
      this.ic_popup_valores_divergentes = false
      this.ic_confirma_valores_divergentes = true
      this.onSave()
    },

    async onFechar() {
      this.show_grid_item = false
      try {
        this.load_grid = true
        await this.carregaDados()
        this.load_grid = false
      } catch (error) {
        this.load_grid = false
      }
    },

    limpaCampos() {
      this.grid_item = this.row_data
      this.column_item.map((i) => {
        if (i.dataType === 'boolean') {
          this.grid_item[i.dataField] = 'N'
        }
        if (i.lookup) {
          this.grid_item[i.dataField] = null
        }
        if (!i.lookup && i.dataType !== 'boolean') {
          this.grid_item[i.dataField] = ''
        }
      })
    },

    onToggle() {},

    onSelect(selected) {
      this.grid_item = { ...this.grid_item, ...selected }
    },

    async onSave() {
      try {
        this.loading = true
        const parametroSave =
          this.ic_tipo_operacao_caixa === 'A' ? 1 : this.ic_tipo_operacao_caixa === 'F' ? 2 : 3
        const salvar_operacao_caixa = {
          cd_parametro: parametroSave,
          cd_usuario: localStorage.cd_usuario,
          vl_caixa_dinheiro: this.vl_caixa_atual.vl_caixa_dinheiro,
          ...this.grid_item,
        }
        //Validação
        if (!salvar_operacao_caixa.cd_operador_caixa) {
          notify('Operador do caixa é obrigatório!', 'error')
          return
        }
        if (!salvar_operacao_caixa.cd_terminal_caixa) {
          notify('Termina de caixa é obrigatório!', 'error')
          return
        }
        if (
          parametroSave === 3 &&
          !salvar_operacao_caixa.vl_dinheiro &&
          !salvar_operacao_caixa.vl_cheque
        ) {
          notify('Informe o valor da retirada!', 'error')
          return
        }
        if (this.ic_tipo_operacao_caixa === 'F' && !this.ic_confirma_valores_divergentes) {
          const valoresValidados = this.validaValores()
          if (!valoresValidados) {
            return
          }
        }
        let result_update = await Incluir.incluirRegistro(
          this.api, //pr_egisnet_controle_caixa
          salvar_operacao_caixa
        )
        // Gera o Boleto Itau
        if (salvar_operacao_caixa.ic_geracao_boleto === 'S') {
          const [config_itau] = JSON.parse(this.$store._mutations.SET_Usuario.config_itau)
          const today = new Date()
          // Hoje
          const todayFormatted = today.toISOString().split('T')[0]
          // D+1
          const tomorrow = new Date(today)
          tomorrow.setDate(today.getDate() + 1)

          const tomorrowFormatted = tomorrow.toISOString().split('T')[0]
          const options = {
            method: 'POST',
            url: 'https://egis-store.com.br/servico-itau/api/boletos',
            headers: {
              'Content-Type': 'application/json',
            },
            data: {
              cd_empresa: '360',
              cd_usuario: localStorage.cd_usuario,
              cd_movimento_caixa: result_update[0].cd_movimento_caixa,
              cd_documento_receber: result_update[0].cd_documento_receber,
              ic_ambiente_prod_hml: config_itau.ic_ambiente_prod_hml, //efetivacao ou validacao
              id_beneficiario: config_itau.id_beneficiario,
              assunto_email: config_itau.assunto_email,
              mensagem_email: config_itau.mensagem_email,
              valor_titulo: funcao.FormataValorParaAPIItau(salvar_operacao_caixa.vl_dinheiro),
              data_emissao: todayFormatted,
              email_pagador: config_itau.email_pagador,
              nome_pagador: this.$store._mutations.SET_Usuario.nm_fantasia_empresa,
              cd_cpf_cnpj_pagador: this.$store._mutations.SET_Usuario.cd_cgc_empresa,
              logradouro_pagador: this.$store._mutations.SET_Usuario.nm_endereco_empresa,
              bairro_pagador: this.$store._mutations.SET_Usuario.nm_bairro_empresa,
              cidade_pagador: this.$store._mutations.SET_Usuario.nm_cidade_empresa,
              sigla_uf_pagador: this.$store._mutations.SET_Usuario.sg_estado_empresa,
              cep_pagador: this.$store._mutations.SET_Usuario.cd_cep_empresa,
              nosso_numero: result_update[0].cd_nosso_numero, //Não pode repetir
              data_vencimento: tomorrowFormatted,
            },
          }
          const axiosInstance = axios.create()
          await axiosInstance(options)
            .then(async (res) => {
              notify(res.Msg)
            })
            .catch((error) => {
              console.error('Erro:', error)
              notify('Não foi possível gerar o boleto!', 'error')
            })
        }
        /////////////////////
        notify(result_update[0].Msg)
        await this.carregaDados()
        this.show_grid_item = false
      } catch (error) {
        console.error(error)
        notify('Não foi possível gerar o boleto!', 'error')
      } finally {
        this.loading = false
        this.ic_confirma_valores_divergentes = false
      }
    },

    validaValores() {
      if (
        this.grid_item.vl_ultimo_fechamento && this.vl_caixa_atual.vl_ultimo_fechamento != 0
          ? this.grid_item.vl_ultimo_fechamento != this.vl_caixa_atual.vl_caixa_dinheiro
          : false ||
            // this.grid_item.vl_cartao_credito != this.vl_caixa_atual.vl_cartao_credito ||
            // this.grid_item.vl_cartao_debito != this.vl_caixa_atual.vl_cartao_debito ||
            (this.grid_item.vl_pix && this.vl_caixa_atual.vl_pix != 0)
          ? this.grid_item.vl_pix != this.vl_caixa_atual.vl_pix
          : false || (this.grid_item.vl_voucher && this.vl_caixa_atual.vl_voucher != 0)
          ? this.grid_item.vl_voucher != this.vl_caixa_atual.vl_voucher
          : false
      ) {
        this.ic_popup_valores_divergentes = !this.ic_popup_valores_divergentes
        return false
      } else {
        return true
      }
    },

    TogglePopupAltera() {
      this.ic_relatorio_menu = !this.ic_relatorio_menu
    },

    async onAbrirCaixa() {
      this.column_item.forEach((i) => {
        if (
          i.dataField === 'cd_terminal_caixa' ||
          i.dataField === 'nm_terminal_caixa' ||
          i.dataField === 'vl_dinheiro_fechamento' ||
          i.dataField === 'vl_ultimo_fechamento'
        ) {
          i.readonly = true
        }
        if (
          i.dataField === 'sg_terminal_caixa' ||
          i.dataField === 'cd_numero_terminal_caixa' ||
          i.dataField === 'dt_ultimo_fechamento' ||
          i.dataField === 'dt_abertura_caixa' ||
          i.dataField === 'hr_abertura_caixa' ||
          i.dataField === 'Status' ||
          i.dataField === 'vl_pix' ||
          i.dataField === 'vl_cartao_credito' ||
          i.dataField === 'vl_cartao_debito' ||
          i.dataField === 'vl_voucher' ||
          i.dataField === 'nm_obs_fechamento_caixa' ||
          i.dataField === 'cd_controle'
        ) {
          i.visible = false
        }
        if (i.dataField === 'vl_abertura_caixa') {
          this.grid_item[i.dataField] = this.vl_caixa_atual.vl_caixa_dinheiro
        }
        if (i.dataField === 'nm_operador_caixa') {
          i.lookup = {
            dataSource: this.lookup_operador,
            valueExpr: 'cd_operador_caixa',
            displayExpr: 'nm_operador_caixa',
          }
        }
      })
      this.ic_tipo_operacao_caixa = 'A'
      this.show_grid_item = true
    },

    async onFecharCaixa() {
      try {
        this.loading = true
        await this.onValorAtualCaixa()
        this.column_item.forEach((i) => {
          if (
            i.dataField === 'cd_terminal_caixa' ||
            i.dataField === 'nm_terminal_caixa' ||
            i.dataField === 'vl_abertura_caixa' ||
            i.dataField === 'nm_operador_caixa'
          ) {
            i.readonly = true
          }
          if (
            i.dataField === 'sg_terminal_caixa' ||
            i.dataField === 'dt_ultimo_fechamento' ||
            i.dataField === 'vl_dinheiro_fechamento' ||
            i.dataField === 'cd_numero_terminal_caixa' ||
            i.dataField === 'dt_abertura_caixa' ||
            i.dataField === 'hr_abertura_caixa' ||
            i.dataField === 'Status' ||
            i.dataField === 'cd_controle'
          ) {
            i.visible = false
          }
        })
        this.ic_tipo_operacao_caixa = 'F'
        this.show_grid_item = true
      } catch (error) {
        console.error(error)
      } finally {
        this.loading = false
      }
    },

    async onRetiradaCaixa() {
      this.column_item.forEach((i) => {
        if (
          i.dataField === 'cd_terminal_caixa' ||
          i.dataField === 'nm_terminal_caixa' ||
          i.dataField === 'dt_ultimo_fechamento'
        ) {
          i.readonly = true
        }
        if (
          i.dataField === 'sg_terminal_caixa' ||
          i.dataField === 'cd_numero_terminal_caixa' ||
          i.dataField === 'dt_abertura_caixa' ||
          i.dataField === 'hr_abertura_caixa' ||
          i.dataField === 'Status' ||
          i.dataField === 'vl_pix' ||
          i.dataField === 'vl_cartao_credito' ||
          i.dataField === 'vl_cartao_debito' ||
          i.dataField === 'vl_voucher' ||
          i.dataField === 'vl_dinheiro_fechamento' ||
          i.dataField === 'vl_ultimo_fechamento' ||
          i.dataField === 'vl_abertura_caixa' ||
          i.dataField === 'cd_controle'
        ) {
          i.visible = false
        }
        if (i.dataField === 'nm_operador_caixa') {
          i.lookup = {
            dataSource: this.lookup_operador,
            valueExpr: 'cd_operador_caixa',
            displayExpr: 'nm_operador_caixa',
          }
        }
        if (i.dataField === 'nm_motivo_retirada_caixa') {
          i.visible = true
          i.lookup = {
            dataSource: this.lookup_Motivo_Retirada_Caixa,
            valueExpr: 'cd_motivo_retirada_caixa',
            displayExpr: 'nm_motivo_retirada_caixa',
          }
        }
        if (i.dataField === 'nm_tipo_despesa') {
          i.visible = true
          i.lookup = {
            dataSource: this.lookup_Tipo_Despesa,
            valueExpr: 'cd_tipo_despesa',
            displayExpr: 'nm_tipo_despesa',
          }
        }
        if (i.dataField === 'vl_dinheiro' || i.dataField === 'vl_cheque') {
          i.visible = true
          i.readonly = false
        }
      })
      this.ic_tipo_operacao_caixa = 'R'
      this.show_grid_item = true
    },

    async onValorAtualCaixa() {
      const check_valor_caixa = {
        cd_parametro: 4,
        cd_usuario: localStorage.cd_usuario,
        cd_terminal_caixa: this.row_data.cd_terminal_caixa,
      }
      ;[this.vl_caixa_atual] = await Incluir.incluirRegistro(
        this.api, //pr_egisnet_controle_caixa
        check_valor_caixa
      )
    },

    onExporting(e) {
      const workbook = new ExcelJS.Workbook()
      const worksheet = workbook.addWorksheet('Employees')

      exportDataGrid({
        component: e.component,
        worksheet: worksheet,
        autoFilterEnabled: true,
      }).then(function () {
        // https://github.com/exceljs/exceljs#writing-xlsx
        workbook.xlsx.writeBuffer().then(function (buffer) {
          saveAs(new Blob([buffer], { type: 'application/octet-stream' }), filename)
        })
      })
      e.cancel = true
    },
    destroyed() {
      this.$destroy()
    },
  },
}
</script>

<style>
.task-info {
  font-family: Segoe UI;
  min-height: 200px;
  display: flex;
  flex-wrap: nowrap;
  border: 2px solid rgba(0, 0, 0, 0.1);
  padding: 5px;
  box-sizing: border-box;
  align-items: baseline;
  justify-content: space-between;
  margin-left: 10px;
  margin-right: 10px;
}
#taskDetails {
  line-height: 22px;
  font-size: 14px;
  margin-top: 0;
  margin-bottom: 0;
  padding-left: 10px;
}
.info {
  margin-right: 40px;
}

.itemCrud {
  display: flex;
  box-sizing: border-box;
}

#taskProgress {
  line-height: 42px;
  font-size: 40px;
  font-weight: bold;
}

.options {
  margin-top: 20px;
  padding: 20px;
  background-color: rgba(191, 191, 191, 0.15);
  position: relative;
}

.caption {
  font-size: 18px;
  font-weight: 500;
}

.option {
  margin-top: 10px;
  margin-right: 40px;
  display: inline-block;
}

.option:last-child {
  margin-right: 0;
}

.option > .dx-numberbox {
  width: 200px;
  display: inline-block;
  vertical-align: middle;
}

.option > span {
  margin-right: 10px;
}
.buttons-column {
  display: inline-block;
  text-decoration: none;
  width: 150px;
  justify-content: center;
  padding-left: 5px;
  margin-top: 5px;
  margin-left: 10px;
}

#exportButton {
  display: inline-block;
  margin-bottom: 10px;
  margin-left: 10px;
}

.dialog--fit {
  display: flex;
  align-items: center;
  justify-content: center;
}
.dialog--fit .q-card {
  display: inline-block;
  width: auto;
  max-width: 90vw; /* responsivo */
  max-height: 90vh; /* controla altura */
  overflow: auto; /* permite rolagem interna se necessário */
}
</style>
