<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <DxButton
      v-if="!cd_tipo_email == 0"
      class="botao-info"
      icon="email"
      text=""
      @click="renderDoc"
    />
    <DxButton
      v-if="!cd_relatorio == 0"
      class="botao-info"
      icon="print"
      text=""
      @click="renderDoc"
    />

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
      :column-min-width="50"
      :show-column-lines="false"
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

      <DxPaging :enable="true" :page-size="50" />

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
        <DxPopup
          :show-title="true"
          :title="menu"
          :close-on-outside-click="false"
        >
          <DxPosition
            v-if="this.cd_api_autoform == 0 && 1 == 2"
            my="top"
            at="top"
            of="window"
          />
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

import Docxtemplater from "docxtemplater";

import PizZip from "pizzip";
import PizZipUtils from "pizzip/utils/index.js";

//mport { exportDataGrid as exportDataGridToPdf } from 'devextreme/pdf_exporter';

//import CustomStore from 'devextreme/data/custom_store';

function loadFile(url, callback) {
  PizZipUtils.getBinaryContent(url, callback);
}

var cd_empresa = 0;
var cd_menu = 0;
var cd_cliente = 0;
var cd_api = 0;
var api = "";
var apiCrud = "";

var filename = "DataGrid.xlsx";
var filenamepdf = "pdf";
var filenamedoc = "MontarNomeArquivo.docx";

var dados = [];

//const dataGridRef = 'dataGrid';

export default {
  props: {
    cd_apiID: { type: Number, default: 0 },
    cd_menuID: { type: Number, default: 0 },
  },
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
      cd_api_autoform: 0,
      cd_menu_autoform: 0,
      cd_tipo_email: 0,
      cd_relatorio: 0,
      nm_template: "",
    };
  },

  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    // locale('pt-BR');

    this.cd_api_autoform = this.cd_apiID;
    this.cd_menu_autoform = this.cd_menuID;
  },

  async mounted() {
    this.cd_api_autoform = this.cd_apiID;
    this.cd_menu_autoform = this.cd_menuID;

    //
    this.carregaDados();
    //
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

      dados = data;

      // this.taskSubject = data && data.ds_informativo;

      this.taskDetails = data && data.ds_informativo;

      //this.cd_controle   = data && data.cd_controle;
      //this.cd_controle = e.data[this.sChave];

      if (!data.ds_informativo == "") {
        this.temD = true;
      }

      //this.focusedRowKey = e.component.option('focusedRowKey');
    },

    eventoRegistro: async function (tipo) {
      let xtipo = tipo + " Informação !";
      tipo = xtipo;
    },

    inclusao: async function (e) {
      e.data.cd_usuario = localStorage.cd_usuario;
      e.data.cd_modulo = localStorage.cd_modulo;
      e.data.cd_menu = localStorage.cd_menu;
      let dataSend = e.data;
      Object.values(e.data).map((item, index) => {
        if (item === true) {
          dataSend[Object.keys(e.data)[index]] = "S";
        } else if (item === false) {
          dataSend[Object.keys(e.data)[index]] = "N";
        }
      });
      dados = await Incluir.incluirRegistro(apiCrud, dataSend);
      notify(dados[0].Msg);
      //Carrega novamente os Dados Da grid
      await this.carregaDados();
    },

    alteracao: async function (e) {
      e.data.cd_usuario = localStorage.cd_usuario;

      let dataAlter = e.data;
      Object.values(e.data).map((item, index) => {
        if (item === true) {
          dataAlter[Object.keys(e.data)[index]] = "S";
        } else if (item === false) {
          dataAlter[Object.keys(e.data)[index]] = "N";
        }
      });
      dados = await Alterar.alterarRegistro(apiCrud, dataAlter);
      notify(dados[0].Msg);
    },

    exclusao: async function (e) {
      //Pegar o Valor do e.data.sChave

      this.cd_controle = e.data[this.sChave];

      if (this.cd_controle != 0) {
        dados = await Deletar.excluirRegistro(apiCrud, this.cd_controle);
      }
      this.carregaDados();
      notify(dados[0].Msg);
    },

    async carregaDados() {
      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      cd_menu = localStorage.cd_menu;
      cd_api = localStorage.cd_api;

      if (this.cd_api_autoform > 0) {
        cd_api = this.cd_api_autoform;
      }

      if (this.cd_menu_autoform > 0) {
        cd_menu = this.cd_menu_autoform;
      }

      api = localStorage.nm_identificacao_api;

      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';
      let sParametroApi = dados.nm_api_parametro;

      if (!dados.nm_identificacao_api == "") {
        api = dados.nm_identificacao_api;
      }

      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      //API do Crud
      apiCrud = dados.nm_sql_procedimento;
      this.tituloColuna = dados.tituloColuna;

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.menu = dados.nm_menu;
      this.cd_tipo_email = dados.cd_tipo_email;
      this.cd_relatorio = dados.cd_relatorio;
      this.nm_template = dados.nm_template;

      if (!dados.chave == "") {
        this.sChave = dados.chave;
        this.focogrid = true;
      }
      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      this.total = {};

      if (dados.coluna_total) {
        this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      }
      //Gera os Dados para Montagem da Grid
      //exec da procedure
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        api,
        sParametroApi
      );
      this.dataSourceConfig.map((i, ind) => {
        Object.values(i).map((item, index) => {
          if (item === "S") {
            i[Object.keys(i)[index]] = true;
            this.dataSourceConfig[ind] = i;
          } else if (item === "N") {
            i[Object.keys(i)[index]] = false;
            this.dataSourceConfig[ind] = i;
          }
        });
      });
      this.qt_registro = this.dataSourceConfig.length;

      filename = this.tituloMenu + ".xlsx";
      filenamepdf = this.tituloMenu + ".pdf";
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

    renderDoc() {
      loadFile(
        `/${this.nm_template}`,
        function (
          //loadFile("https://docxtemplater.com/tag-example.docx", function(
          error,
          content
        ) {
          if (error) {
            alert("não encontrei o template.docx");
            throw error;
          }

          var zip = new PizZip(content);
          var doc = new Docxtemplater(zip);

          doc.setData(dados);

          try {
            // render the document (replace all occurences of {first_name} by John, {last_name} by Doe, ...)
            doc.render();
          } catch (error) {
            // The error thrown here contains additional information when logged with JSON.stringify (it contains a properties object containing all suberrors).
            if (error.properties && error.properties.errors instanceof Array) {
              error.properties.errors
                .map(function (error) {
                  return error.properties.explanation;
                })
                .join("\n");
              // errorMessages is a humanly readable message looking like this :
              // 'The tag beginning with "foobar" is unopened'
            }
            throw error;
          }
          var out = doc.getZip().generate({
            type: "blob",
            mimeType:
              "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
          });

          //Output the document using Data-URI
          saveAs(out, filenamedoc);
        }
      );
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
