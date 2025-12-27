<template>
  <div>
    <h2 class="content-block">{{ tituloMenu }}</h2>

    <div class="content-block dx-card responsive-paddings">
      <div>
        <div class="data-base">Data</div>
        <div class="data-base">
          <DxDateBox
            :value="now"
            :show-clear-button="true"
            :use-mask-behavior="true"
            type="date"
            apply-value-mode="useButtons"
            @value-changed="onValueChanged($event)"
          />
        </div>
      </div>
      <div class="buttons-column">
        <div>
          <DxButton
            :width="120"
            text="Pesquisar"
            type="default"
            styling-mode="contained"
            horizontal-alignment="left"
            @click="onClick($event)"
          />
        </div>
      </div>

      <dx-data-grid
        class="dx-card wide-card-d"
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
        @selection-changed="selectionChanged"
        @focused-row-changed="onFocusedRowChanged"
      >
        <DxGroupPanel
          :visible="true"
          empty-panel-text="Colunas para agrupar..."
        />

        <DxGrouping :auto-expand-all="true" />
        <DxExport :enabled="true" />

        <DxPaging :enable="true" :page-size="10" />

        <DxMasterDetail :enabled="true" template="master-detail" />
        <template #master-detail="{ data }">
          <MasterDetail :master-detail-data="data" />
        </template>
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
        <DxSearchPanel :visible="true" :width="300" placeholder="Procurar..." />
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
  </div>
</template>
<script>
//import DxCheckBox from 'devextreme-vue/check-box';
import DxButton from "devextreme-vue/button";
//import { DxForm, DxLabel } from 'devextreme-vue/form';
import notify from "devextreme/ui/notify";
import DxDateBox from "devextreme-vue/date-box";

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
} from "devextreme-vue/data-grid";

import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import MasterDetail from "./MasterDetail.vue";

var cd_empresa = 0;
var cd_menu = 0;
var cd_cliente = 0;
var cd_api = 0;
var api = "";

var filename = "DataGrid.xlsx";
var dados = [];

export default {
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
    DxDateBox,
  },

  data() {
    return {
      now: Date(),
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
      colCountByScreen: {
        xs: 1,
        sm: 2,
        md: 3,
        lg: 4,
      },
      dataGridRefName: "dataGrid",
      taskSubject: "Descritivo",
      taskDetails: "",
      temD: false,
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
    localStorage.dt_base = "";

    var data = new Date(),
      dia = data.getDate().toString(),
      diaF = dia.length == 1 ? "0" + dia : dia,
      mes = (data.getMonth() + 1).toString(), //+1 pois no getMonth Janeiro começa com zero.
      mesF = mes.length == 1 ? "0" + mes : mes,
      anoF = data.getFullYear();

    localStorage.dt_base = mesF + "-" + diaF + "-" + anoF;

    this.carregaDados();
  },

  methods: {
    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;
      // this.taskSubject = data && data.ds_informativo;
      this.taskDetails = data && data.ds_informativo;

      //alert(this.taskDetais);

      if (!data.ds_informativo == "") {
        this.temD = true;
      }

      //alert(this.temD);

      //this.focusedRowKey = e.component.option('focusedRowKey');
    },

    onValueChanged(e) {
      var data = e.value,
        dia = data.getDate().toString(),
        diaF = dia.length == 1 ? "0" + dia : dia,
        mes = (data.getMonth() + 1).toString(), //+1 pois no getMonth Janeiro começa com zero.
        mesF = mes.length == 1 ? "0" + mes : mes,
        anoF = data.getFullYear();

      localStorage.dt_base = mesF + "-" + diaF + "-" + anoF;
      this.carregaDados();
    },

    async carregaDados() {
      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      cd_menu = localStorage.cd_menu;
      cd_api = localStorage.cd_api;
      api = localStorage.nm_identificacao_api;

      //alert(api);

      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';

      let sParametroApi = dados.nm_api_parametro;

      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      localStorage.cd_procedimento = 0;
      localStorage.cd_parametro = 0;

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';

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

      //this.FormData.Data =  new Date().toLocaleDateString();
    },

    customizeColumns(columns) {
      columns[0].width = 120;
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    onClick(e) {
      const buttonText = e.component.option("text");
      notify(`Aguarde... vamos ${this.capitalize(buttonText)} novamente !`);

      this.carregaDados();
    },

    capitalize(text) {
      return text.charAt(0).toUpperCase() + text.slice(1);
    },

    selectionChanged(e) {
      localStorage.cd_parametro = 0;

      e.component.collapseAll(-1);
      e.component.expandRow(e.currentSelectedRowKeys[0]);

      localStorage.cd_parametro = e.currentSelectedRowKeys[0];
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
  },
};
</script>


<style>
.data-base {
  width: 135px;
}

.tabpanel-item {
  height: 200px;
  user-select: none;
  padding-left: 25px;
  padding-top: 55px;
}

.mobile .tabpanel-item {
  padding-top: 10px;
}

.tabpanel-item > div {
  float: left;
  padding: 0 85px 10px 10px;
}

.tabpanel-item p {
  font-size: 16px;
  margin: 0;
}

.item-box {
  font-size: 16px;
  margin: 15px 0 45px 10px;
}

.options {
  padding: 20px;
  background-color: rgba(191, 191, 191, 0.15);
  margin-top: 20px;
}

.caption {
  font-size: 18px;
  font-weight: 500;
}

.option {
  margin-top: 10px;
}

.buttons-demo {
  width: 600px;
  align-self: center;
}

.buttons-column > .column-header {
  flex-grow: 0;
  width: 150px;
  height: 35px;
  font-size: 130%;
  opacity: 0.6;
  text-align: left;
  padding-left: 15px;
}

.buttons {
  margin-left: 30px;
  width: 100px;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
}

.buttons-column > div {
  width: 150px;
  height: 30px;
  text-align: center;
  justify-content: center;
}

.form-container {
  padding: 0px;
}

.address-form label {
  font-weight: bold;
}

.toolbar-label,
.toolbar-label > b {
  font-size: 16px;
}
</style>
