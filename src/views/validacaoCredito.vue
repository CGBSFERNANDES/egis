<template>
  <div>
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />
    <h2 v-if="ic_mostra_titulo" class="content-block margin1">
      {{ tituloMenu }}
      <q-badge
        v-if="qt_registro > 0"
        align="middle"
        rounded
        color="red"
        :label="qt_registro + ' Contratos'"
      />
    </h2>
    <q-btn
      class="margin1"
      rounded
      color="positive"
      icon="check"
      label="Aprovar"
      @click="onAprovar"
    />
    <q-btn
      class="margin1"
      rounded
      color="negative"
      icon="close"
      label="Declinar"
      @click="onDeclinar"
    />

    <dx-data-grid
      class="dx-card wide-card margin1"
      :data-source="dataSourceConfig"
      :columns="columns"
      :summary="total"
      key-expr="cd_controle"
      :show-borders="true"
      :focused-row-enabled="true"
      :column-auto-width="true"
      :column-hiding-enabled="false"
      :remote-operations="false"
      :word-wrap-enabled="false"
      :allow-column-reordering="true"
      :allow-column-resizing="true"
      :row-alternation-enabled="true"
      :repaint-changes-only="true"
      :autoNavigateToFocusedRow="true"
      :cacheEnable="false"
      @exporting="onExporting"
      @initialized="saveGridInstance"
      @focused-row-changed="onFocusedRowChanged"
      :selectedrow-keys="selectedRowKeys"
      @selection-Changed="Linha"
    >
      <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
      <DxGrouping :auto-expand-all="true" />
      <DxExport :enabled="true" />
      <DxPaging :enable="true" :page-size="10" />
      <DxStateStoring :enabled="false" type="localStorage" storage-key="storage" />
      <DxSelection mode="single" />
      <DxPager :show-page-size-selector="true" :allowed-page-sizes="pageSizes" :show-info="true" />
      <DxFilterRow :visible="false" />
      <DxHeaderFilter :visible="true" :allow-search="true" />
      <DxSearchPanel :visible="temPanel" :width="100" placeholder="Procurar..." />
      <DxFilterPanel :visible="true" />
      <DxColumnFixing :enabled="true" />
      <DxColumnChooser :enabled="true" mode="select" />
      <DxMasterDetail v-if="!cd_detalhe == 0" :enabled="true" template="master-detail" />
      <template #master-detail="{ data }">
        <MasterDetail
          :cd_menuID="cd_menu_detalhe"
          :cd_apiID="cd_api_detalhe"
          :master-detail-data="data"
        />
      </template>
      <template #cellTemplate="{ data }">
        <img :src="data.imagem" />
      </template>
    </dx-data-grid>
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
  DxMasterDetail,
} from 'devextreme-vue/data-grid'

import { exportDataGrid } from 'devextreme/excel_exporter'
import ExcelJS from 'exceljs'
import saveAs from 'file-saver'
import ptMessages from 'devextreme/localization/messages/pt.json'
import { locale, loadMessages } from 'devextreme/localization'
import config from 'devextreme/core/config'

import Procedimento from '../http/procedimento'
import Menu from '../http/menu'
import DxButton from 'devextreme-vue/button'
import notify from 'devextreme/ui/notify'
import MasterDetail from '../views/MasterDetail'
import DxTabs from 'devextreme-vue/tabs'

var cd_empresa = 0
var cd_menu = 0
var cd_cliente = 0
var cd_api = 0
var api = ''

var filename = 'DataGrid.xlsx'
var dados = []

export default {
  data() {
    return {
      tituloMenu: '',
      columns: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      total: {},
      dataGridInstance: null,
      temPanel: false,
      qt_registro: 0,
      cd_detalhe: 0,
      cd_menu_detalhe: 0,
      cd_api_detalhe: 0,
      selectedRowKeys: [],
      data: {},
      linha_selecionada: {},
    }
  },
  created() {
    //locale(navigator.language);
    config({ defaultCurrency: 'BRL' })
    loadMessages(ptMessages)
    locale(navigator.language)
    // locale('pt-BR');
  },

  async mounted() {
    this.carregaDados()
  },

  props: {
    ic_mostra_titulo: {
      type: Boolean,
      required: false,
    },
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
    DxButton,
    DxMasterDetail,
    MasterDetail,
    DxTabs,
  },

  methods: {
    Linha({ selectedRowsData }) {
      this.linha_selecionada = selectedRowsData[0]
    },

    onFocusedRowChanged: function (e) {
      this.data = e.row && e.row.data
    },

    async carregaDados() {
      this.temPanel = true

      cd_empresa = localStorage.cd_empresa
      cd_cliente = localStorage.cd_cliente
      cd_menu = localStorage.cd_menu
      cd_api = localStorage.cd_api
      api = localStorage.nm_identificacao_api

      dados = await Menu.montarMenu(cd_empresa, '8817', '969') //'titulo';
      let sParametroApi = dados.nm_api_parametro

      this.cd_detalhe = dados.cd_detalhe
      this.cd_menu_detalhe = dados.cd_menu_detalhe
      this.cd_api_detalhe = dados.cd_api_detalhe
      this.tituloMenu = dados.nm_menu_titulo

      localStorage.cd_usuario_menu = localStorage.cd_usuario
      localStorage.cd_usuario = 0
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        '969/1485', //api, pr_consulta_movimento_aprovacao
        sParametroApi
      )
      this.qt_registro = this.dataSourceConfig.length
      localStorage.cd_usuario = localStorage.cd_usuario_menu

      filename = this.tituloMenu + '.xlsx'
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)))
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)))
    },

    customizeColumns(columns) {
      columns[0].width = 120
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component
    },

    async onAprovar() {
      try {
        if (!this.linha_selecionada.cd_controle) {
          notify('Selecione um registro para aprovar!')
          return
        }

        notify(`Registro atualizado com sucesso!`)
        this.linha_selecionada = {}
        this.carregaDados()
      } catch (error) {
        console.error(error)
      }
    },

    async onDeclinar() {
      try {
        if (!this.linha_selecionada.cd_controle) {
          notify('Selecione um registro para declinar!')
          return
        }
        this.linha_selecionada = {}
        this.carregaDados()
      } catch (error) {
        console.error(error)
      }
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
@import url('./views.css');
</style>
