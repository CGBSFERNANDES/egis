<template>
  <div>
    <DxForm
      v-if="ic_form_tabsheet == 'S'"
      class="dx-card wide-card-g"
      id="form"
      label-location="left"
      :form-data="formData"
      :items="items"
    >
    </DxForm>

    <dx-data-grid
      v-if="ic_form_tabsheet == 'N'"
      class="dx-card-componente"
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
      :focused-row-index="0"
      :cacheEnable="false"
      @exporting="onExporting"
      @initialized="saveGridInstance"
      @focused-row-changed="onFocusedRowChanged"
    >
      <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

      <DxGrouping :auto-expand-all="true" />
      <DxExport :enabled="true" />
      <DxEditing :allow-updating="false" mode="cell" />
      <DxPaging :enable="true" :page-size="10" />

      <DxStateStoring
        :enabled="false"
        type="localStorage"
        storage-key="storage"
      />
      <DxSelection mode="single" />
      <DxPager
        :show-page-size-selector="true"
        :allowed-page-sizes="pageSizes"
        :show-info="true"
      />
      <DxFilterRow :visible="false" />
      <DxHeaderFilter :visible="true" :allow-search="true" />
      <DxSearchPanel
        :visible="temPanel"
        :width="300"
        placeholder="Procurar..."
      />
      <DxFilterPanel :visible="true" />
      <DxColumnFixing :enabled="true" />
      <DxColumnChooser :enabled="true" mode="select" />
    </dx-data-grid>

    <div class="task-info" v-if="temD === true">
      <div class="info">
        <div id="taskSubject">{{ taskSubject }}</div>
        <p id="taskDetails" v-html="taskDetails" />
      </div>
    </div>
  </div>
</template>

<script>
//import { DxLoadPanel } from 'devextreme-vue/load-panel';

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
} from "devextreme-vue/data-grid";

import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
//import SelectBoxData from './select-data.vue'

//import { DxForm,
//  DxGroupItem,
//  DxSimpleItem,
//  DxLabel
//DxLabel, DxItem
//        } from 'devextreme-vue/form';

var cd_empresa = 0;
var cd_menu = 0;
var cd_cliente = 0;
var cd_api = 0;
var api = "";

var filename = "DataGrid.xlsx";
var dados = [];

export default {
  props: {
    cd_menuID: { type: Number, default: 0 },
    cd_apiID: { type: Number, default: 0 },
    cd_identificacaoID: { type: Number, default: 0 },
    cd_parametroID: { type: Number, default: 0 },
    tabData: { type: Object, default: () => {} },
  },
  data() {
    return {
      tituloMenu: "",
      columns: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      total: {},
      dataGridInstance: null,
      taskSubject: "Descritivo",
      taskDetails: "",
      temD: false,
      temPanel: false,
      ic_form_tabsheet: "N",
      formData: {},
      items: [],
      cd_parametro_prox: "",
      cd_identificacao_prox: "",
      cd_tipo_filtro_prox: "",
      cd_documento_prox: "",
    };
  },

  computed: {
    dataGrid: function () {
      return "teste";
    },
  },

  created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    // locale('pt-BR');
    //
    this.ic_form_tabsheet = this.tabData.ic_form_tabsheet;
    //
  },

  async mounted() {
    await this.carregaDados();
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
    //DxForm
    // DxGroupItem,
    // DxSimpleItem,
    // DxLabel
  },

  methods: {
    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;

      // this.taskSubject = data && data.ds_informativo;
      this.taskDetails = data && data.ds_informativo;

      let a = data[this.cd_parametro_prox];
      localStorage.cd_parametro = a;

      //  localStorage.cd_parametro = data && data.cd_controle;
      //this.cd_parametroID       = data.cd_controle;

      let b = data[this.cd_identificacao_prox];
      localStorage.cd_identificacao = b;
      //localStorage.cd_parametro = data && data.cd_controle;
      //this.cd_parametroID       = data.cd_controle;

      let c = data[this.cd_tipo_filtro_prox];
      localStorage.cd_tipo_filtro = c;

      let d = data[this.cd_documento_prox];
      localStorage.cd_documento = d;

      //localStorage.cd_parametro = data && data.cd_controle;

      if (!data.ds_informativo == "") {
        this.temD = true;
      }
    },

    limpaDados() {
      dados = {};
      this.dataSourceConfig = [];
      this.cd_parametro_prox = "";
      this.cd_identificacao_prox = "";
      this.cd_tipo_filtro_prox = "";
      this.cd_documento_prox = "";
      localStorage.cd_parametro = 0;
      localStorage.cd_identificacao = 0;
      localStorage.cd_tipo_filtro = 0;
      localStorage.cd_documento = 0;
    },

    async carregaDados() {
      if (this.tabData.cd_ordem_tabsheet == 1) {
        this.limpaDados();
      }

      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;

      //cd_menu    = this.cd_menuID;
      //cd_api     = this.cd_apiID;

      localStorage.cd_tipo_consulta = this.tabData.cd_ordem_tabsheet;

      api = "";
      cd_menu = this.tabData.cd_menu_composicao;
      cd_api = this.tabData.cd_api;

      if (!this.cd_parametroID == 0) {
        localStorage.cd_parametro = this.cd_parametroID;
      }

      if (!this.cd_identifidacaoID == 0) {
        localStorage.cd_identificacaoID = this.cd_identifidacaoID;
      }

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';
      api = dados.nm_identificacao_api;

      let sParametroApi = dados.nm_api_parametro;

      this.tituloMenu = dados.nm_menu_titulo;

      filename = this.tituloMenu + ".xlsx";

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //

      //Gera os Dados para Montagem da Grid
      //exec da procedure

      if (localStorage.cd_identificacao == "undefined") {
        localStorage.cd_identificacao = 0;
      }

      if (localStorage.cd_parametro == undefined) {
        localStorage.cd_parametro = 0;
      }

      if (localStorage.cd_parametro_filtro == "undefined") {
        localStorage.cd_parametro_filtro = 0;
      }

      if (localStorage.cd_identificacao_filtro == undefined) {
        localStorage.cd_identificacao_filtro = 0;
      }

      if (localStorage.cd_tipo_filtro == "undefined") {
        localStorage.cd_tipo_filtro = 0;
      }

      if (localStorage.cd_documento == "undefined") {
        localStorage.cd_documento = 0;
      }

      if (this.tabData.cd_ordem_tabsheet == 1) {
        localStorage.cd_parametro = 0;
        localStorage.cd_identificacao = 0;
        localStorage.cd_tipo_filtro = 0;
        localStorage.cd_documento = 0;
      }

      if (!api == "") {
        this.dataSourceConfig = await Procedimento.montarProcedimento(
          cd_empresa,
          cd_cliente,
          api,
          sParametroApi
        );
        this.formData = this.dataSourceConfig[0];
        this.items = JSON.parse(dados.labelForm);
      }

      this.cd_parametro_prox = this.dataSourceConfig[0].cd_parametro_filtro;
      localStorage.cd_parametro =
        this.dataSourceConfig[0][this.cd_parametro_prox];

      this.cd_identificacao_prox =
        this.dataSourceConfig[0].cd_identificacao_filtro;
      localStorage.cd_identificacao =
        this.dataSourceConfig[0][this.cd_identificacao_prox];

      this.cd_tipo_filtro_prox = this.dataSourceConfig[0].cd_tipo_filtro;
      localStorage.cd_tipo_filtro =
        this.dataSourceConfig[0][this.cd_tipo_filtro_prox];

      this.cd_documento_prox = this.dataSourceConfig[0].cd_documento;
      localStorage.cd_documento =
        this.dataSourceConfig[0][this.cd_documento_prox];
    },

    customizeColumns(columns) {
      columns[0].width = 120;
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Employees");

      exportDataGrid({
        component: e.component,
        worksheet: worksheet,
        autoFilterEnabled: true,
      }).then(function () {
        // https://github.com/exceljs/exceljs#writing-xlsx
        workbook.xlsx.writeBuffer().then(function (buffer) {
          saveAs(
            new Blob([buffer], { type: "application/octet-stream" }),
            filename
          );
        });
      });
      e.cancel = true;
    },
    destroyed() {
      this.$destroy();
    },
  },
};
</script>
<style>
.task-info {
  font-family: Segoe UI;
  min-height: 200px;
  display: flex;
  flex-wrap: nowrap;
  border: 2px solid rgba(0, 0, 0, 0.1);
  padding: 16px;
  box-sizing: border-box;
  align-items: baseline;
  justify-content: space-between;
  margin-left: 20px;
  margin-right: 20px;
}
#taskSubject {
  line-height: 29px;
  font-size: 18px;
  font-weight: bold;
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
</style>
