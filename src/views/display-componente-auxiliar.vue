<template>
  <div>
    <h2 class="content-block">{{ tituloMenu }}</h2>

    <dx-data-grid
      class="dx-card wide-card"
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
      <DxGroupPanel
        :visible="true"
        empty-panel-text="Colunas para agrupar..."
      />

      <DxGrouping :auto-expand-all="true" />
      <DxExport :enabled="true" />

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
} from "devextreme-vue/data-grid";

import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";

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
    cd_parametroID: { type: Number, default: 0 },
  },
  computed: {
    Retorno() {
      return this.carregaDados();
    },
  },
  data() {
    return {
      tituloMenu: "",
      columns: [],
      pageSizes: [10, 20, 50, 100],
      autoNavigateToFocusedRow: true,
      isReady: false,
      dataSourceConfig: [],
      total: {},
      dataGridInstance: null,
      showIndicator: true,
      showPane: true,
      taskSubject: "Descritivo",
      taskDetails: "",
      temD: false,
      temPanel: false,
    };
  },
  created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    // locale('pt-BR');
  },

  async mounted() {
    this.carregaDados();
    //  alert(this.cd_parametroID);
  },

  async beforeupdated() {
    // this.carregaDados();
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
    //  DxLoadPanel
  },

  methods: {
    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;
      // this.taskSubject = data && data.ds_informativo;
      this.taskDetails = data && data.ds_informativo;

      this.carregaDados();

      //alert(this.taskDetais);

      if (!data.ds_informativo == "") {
        this.temD = true;
      }

      //alert(this.temD);

      //this.focusedRowKey = e.component.option('focusedRowKey');
    },

    async carregaDados() {
      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;

      cd_menu = this.cd_menuID;
      cd_api = this.cd_apiID;

      if (!cd_menu == 0 && !cd_api == 0) {
        dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';

        api = dados.nm_identificacao_api;
        let sParametroApi = dados.nm_api_parametro;

        //alert(localStorage.cd_parametro);

        //alert(sParametroApi);

        localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

        //alert( dados.cd_tipo_consulta);

        this.tituloMenu = dados.nm_menu_titulo;

        //Gera os Dados para Montagem da Grid
        //exec da procedure
        this.dataSourceConfig = await Procedimento.montarProcedimento(
          cd_empresa,
          cd_cliente,
          api,
          sParametroApi
        );
        //

        filename = this.tituloMenu + ".xlsx";

        //dados da coluna
        this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

        //dados do total
        this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
        //
      }
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