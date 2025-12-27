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
    <DxButton
      id="exportButton"
      icon="exportpdf"
      text="PDF"
      :visible="false"
      @click="exportGrid()"
    />

    <dx-data-grid
      class="dx-card wide-card"
      :data-source="dataSourceConfig"
      :columns="columns"
      :summary="total"
      :key-expr="sChave"
      :show-borders="true"
      :focused-row-enabled="focogrid"
      :column-auto-width="true"
      :column-hiding-enabled="true"
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
      @editing-start="eventoRegistro('Digitação')"
      @init-new-row="eventoRegistro('Novo Registro')"
      @row-inserting="eventoRegistro('Inserindo Registro')"
      @row-inserted="inclusao"
      @row-updated="alteracao"
      @row-removing="eventoRegistro('Excluindo Registro')"
      @row-removed="exclusao"
      @saving="eventoRegistro('Salvando...')"
      @saved="eventoRegistro('Gravado !')"
      @edit-canceling="eventoRegistro('Cancelando a Edição !')"
      @edit-canceled="eventoRegistro('Edição Cancelada !')"
    >
      <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

      <DxGrouping :auto-expand-all="true" />
      <DxExport :enabled="true" />

      <DxPaging :enable="true" :page-size="10" />

      <DxStateStoring :enabled="true" type="localStorage" :storage-key="menu" />

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
      <DxEditing
        :refresh-mode="refreshMode"
        :allow-adding="true"
        :allow-updating="true"
        :allow-deleting="true"
        mode="popup"
      >
        <DxPopup :show-title="true" :title="menu">
          <DxPosition my="top" at="top" of="window" />
        </DxPopup>
        <DxForm>
          <DxItem :col-count="2" :col-span="2" item-type="group" />
        </DxForm>
      </DxEditing>
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
  DxPosition,
  DxPopup,
} from "devextreme-vue/data-grid";

import { DxForm, DxItem } from "devextreme-vue/form";

import DxButton from "devextreme-vue/button";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import Incluir from "../http/incluir_registro";
import Deletar from "../http/excluir_registro";
import Alterar from "../http/alterar_registro";
import "whatwg-fetch";

import { jsPDF } from "jspdf";
import "jspdf-autotable";
import { exportDataGrid } from "devextreme/excel_exporter";

//mport { exportDataGrid as exportDataGridToPdf } from 'devextreme/pdf_exporter';

//import CustomStore from 'devextreme/data/custom_store';

var cd_empresa = 0;
var cd_menu = 0;
var cd_cliente = 0;
var cd_api = 0;
var api = "";
var apiCrud = "";

var filename = "DataGrid.xlsx";
var filenamepdf = "pdf";

var dados = [];

//const dataGridRef = 'dataGrid';

export default {
  data() {
    return {
      tituloMenu: "",
      menu: "",
      columns: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      total: {},
      dataGridInstance: null,
      taskSubject: "Descritivo",
      taskDetails: "",
      temD: false,
      temPanel: false,
      cd_controle: null,
      refreshMode: "full",
      sChave: "",
      tituloColuna: [],
      focogrid: false,
      qt_registro: 0,
    };
  },

  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    // locale('pt-BR');
  },

  async mounted() {
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
    DxEditing,
    DxPopup,
    DxPosition,
    DxForm,
    DxButton,
    DxItem,
    //  DxLoadPanel
  },

  methods: {
    exportGrid() {
      const doc = new jsPDF();

      doc.autoTable({ html: "#my-table" });

      //  console.log(this.dataSourceConfig);
      //  console.log(this.tituloColuna);

      // Or use javascript directly:

      var t = ["Desenvolvimento - Aguardar Liberação nova Versão !"];

      doc.autoTable({
        head: [[t]],

        body: [
          ["< Previsão: Fevereiro/2021 >"],
          // ...
        ],
      });
      doc.save(filenamepdf);
      //exportDataGridToPdf({
      //  jsPDFDocument: doc,
      //  component: this.dataGrid
      //}).then(() => {
      //  doc.save(filenamepdf);
      //});
    },

    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;
      //alert('1');
      // this.taskSubject = data && data.ds_informativo;
      this.taskDetails = data && data.ds_informativo;
      //this.cd_controle   = data && data.cd_controle;
      //this.cd_controle = e.data[this.sChave];

      if (!data.ds_informativo == "") {
        this.temD = true;
      }

      //alert(this.temD);

      //this.focusedRowKey = e.component.option('focusedRowKey');
    },

    eventoRegistro: async function (tipo) {
      //alert(tipo);
      let xtipo = tipo + " Informação !";
      tipo = xtipo;
      //alert(xtipo);
    },

    inclusao: async function (e) {
      e.data.cd_usuario = localStorage.cd_usuario;
      e.data.cd_modulo = localStorage.cd_modulo;
      e.data.cd_menu = localStorage.cd_menu;

      //alert(apiCrud);
      //alert(e.data);
      console.log(e.data);
      dados = await Incluir.incluirRegistro(apiCrud, e.data);

      //Carrega novamente os Dados Da grid
      this.carregaDados();
      //
    },

    alteracao: async function (e) {
      e.data.cd_usuario = localStorage.cd_usuario;

      dados = await Alterar.alterarRegistro(apiCrud, e.data);
    },

    exclusao: async function (e) {
      //Pegar o Valor do e.data.sChave

      this.cd_controle = e.data[this.sChave];

      //alert(this.cd_controle);

      if (this.cd_controle != 0) {
        dados = await Deletar.excluirRegistro(apiCrud, this.cd_controle);
      }
    },

    async carregaDados() {
      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      cd_menu = localStorage.cd_menu;
      cd_api = localStorage.cd_api;
      api = localStorage.nm_identificacao_api;

      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';

      let sParametroApi = dados.nm_api_parametro;

      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      //API do Crud
      apiCrud = dados.nm_sql_procedimento;
      //
      this.tituloColuna = dados.tituloColuna;
      //

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.menu = dados.nm_menu;
      //
      //alert(dados.chave);

      if (!dados.chave == "") {
        this.sChave = dados.chave;
        // alert(this.sChave);
        this.focogrid = true;
      }

      //var chave = dados.chave;
      //
      //alert(this.sChave);

      //alert(dados.chave);
      //alert(dados.nm_sql_procedimento);
      //alert(dados.chave);
      //alert(this.sChave);

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
      filenamepdf = this.tituloMenu + ".pdf";

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //
      //chave = dados.chave;
      //this.sChave = chave;
      //alert(this.dataSourceConfig[0]);
      //
      //console.log(this.dataSourceConfig);
      //
    },

    customizeColumns(columns) {
      columns[0].width = 120;
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    //onOptionChanged(e) {
    //alert(e.data[this.sChave]);
    //},

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
</style>
