<template>
  <div>
    <h2 class="content-block">
      {{ tituloMenu }}
      <q-badge
        v-if="qt_registro > 0"
        align="middle"
        rounded
        color="red"
        :label="qt_registro"
      />
    </h2>

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
      <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

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
      <DxMasterDetail
        v-if="cd_detalhe == 0"
        :enabled="true"
        template="master-detail"
      />

      <template #master-detail="{ data }">
        <div>
          <MasterDetail
            :cd_menuID="7095"
            :cd_apiID="493"
            :cd_botao="1"
            :master-detail-data="data"
          />
          <div class="buttons-column">
            <DxButton
              :width="120"
              text="APROVAR"
              type="success"
              styling-mode="contained"
              horizontal-alignment="left"
              @click="onClickAprovar()"
            />
            <DxButton
              :width="120"
              text="DECLINAR"
              type="danger"
              styling-mode="contained"
              horizontal-alignment="left"
              v-close-popup
              @click="onClickDeclinar($event)"
            />
          </div>
        </div>
      </template>

      <template #cellTemplate="{ data }">
        <img :src="data.imagem" />
      </template>
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
import DxButton from "devextreme-vue/button";
import notify from "devextreme/ui/notify";
import MasterDetail from "../views/MasterDetail";

import formataData from "../http/formataData";

var cd_empresa = 0;
var cd_menu = 0;
var cd_cliente = 0;
var cd_api = 0;
var api = "";

var filename = "DataGrid.xlsx";
var dados = [];

export default {
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
      qt_registro: 0,
      cd_detalhe: 0,
      cd_menu_detalhe: 0,
      cd_api_detalhe: 0,
      justificativa: "",

      dados_contrato: false,
      contrato_selecionado: {},

      cont: 0,
      cd_parametro: 0,

      paramApi: "",
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
    localStorage.cd_parametro = 0;
    this.carregaDados();
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
    //DxLoadPanel
  },

  methods: {
    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;
      localStorage.cd_identificacao = 2;
      this.cd_parametro = data.Numero;
      localStorage.cd_documento = data.Numero;
    },

    async carregaDados() {
      localStorage.cd_documento = 0;
      localStorage.cd_identificacao = 1;
      localStorage.cd_parametro = 0;

      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      cd_menu = localStorage.cd_menu;
      cd_api = localStorage.cd_api;
      api = localStorage.nm_identificacao_api;

      //localStorage.dt_inicial = formataData.formataDataSQL('01/08/2021')
      //localStorage.dt_final   = formataData.formataDataSQL('31/08/2021')

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';

      let sParametroApi = dados.nm_api_parametro;
      this.paramApi = sParametroApi;

      console.log(dados);

      //localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      this.cd_detalhe = dados.cd_detalhe;
      this.cd_menu_detalhe = dados.cd_menu_detalhe;
      this.cd_api_detalhe = dados.cd_api_detalhe;

      //alert( dados.cd_tipo_consulta);

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
      this.qt_registro = this.dataSourceConfig.length;

      filename = this.tituloMenu + ".xlsx";

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //
    },

    customizeColumns(columns) {
      columns[0].width = 120;
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    async onClickAprovar() {
      var dado = await MasterDetail.Selecionada();
      console.log(dado);

      var aprovado = [];
      localStorage.cd_parametro = localStorage.cd_usuario;
      localStorage.cd_identificacao = 5;
      localStorage.cd_documento = dado.cd_ap;

      console.log(this.paramApi);

      aprovado = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        api,
        this.paramApi
      );

      notify(aprovado[0].Msg);
      localStorage.cd_parametro = 0;
      localStorage.nm_documento = "";
      //this.carregaDados()
    },

    onClickDeclinar() {
      notify("Contrato Declinado");
    },

    capitalize(text) {
      return text.charAt(0).toUpperCase() + text.slice(1);
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
      //  localStorage.cd_identificacao = 0;
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
  padding: 5px;
  box-sizing: border-box;
  align-items: baseline;
  justify-content: space-between;
  margin-left: 10px;
  margin-right: 10px;
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
  margin-right: 10px;
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
</style>