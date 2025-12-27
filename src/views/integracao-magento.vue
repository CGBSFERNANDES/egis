<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
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

    <!-- <q-input
      class="margin1"
      autofocus
      v-model="nm_proposta_magento"
      color="orange-9"
      mask="#########"
      label="Proposta"
      @keyup.enter="onPropostaMagento()"
      hint="Digite o ID da proposta da Bis2Bis"
    >
      <template v-slot:prepend>
        <q-icon name="description" />
      </template>
      <template v-slot:append>
        <q-btn
          round
          color="green"
          :loading="loadProposta"
          icon="check"
          size="sm"
          @click="onPropostaMagento()"
        >
          <q-tooltip>
            Confirmar
          </q-tooltip>
        </q-btn>
      </template>
    </q-input> -->
    <div class="margin1">
      <q-btn
        rounded
        color="primary"
        icon="description"
        label="Importar Pedidos"
        @click="onGeraMigracao()"
        :loading="load_migracao"
      />
    </div>

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
        :allow-adding="false"
        :allow-updating="false"
        :allow-deleting="false"
        mode="popup"
      >
      </DxEditing>
    </dx-data-grid>

    <q-dialog v-model="loadProposta" maximized persistent>
      <carregando
        :mensagemID="'Carregando...'"
        :corID="'orange-9'"
      ></carregando>
    </q-dialog>
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
} from "devextreme-vue/data-grid";

import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import Menu from "../http/menu";
import Incluir from "../http/incluir_registro";
import "whatwg-fetch";

import { jsPDF } from "jspdf";
import "jspdf-autotable";
import { exportDataGrid } from "devextreme/excel_exporter";
import axios from "axios";

//mport { exportDataGrid as exportDataGridToPdf } from 'devextreme/pdf_exporter';

//import CustomStore from 'devextreme/data/custom_store';

var cd_empresa = 0;
var cd_menu = 0;
var api = "";

var filename = "DataGrid.xlsx";
var filenamepdf = "pdf";

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
      api: 0,
      taskDetails: "",
      loadProposta: false,
      temD: false,
      temPanel: false,
      nm_proposta_magento: "",
      refreshMode: "full",
      sChave: "",
      tituloColuna: [],
      focogrid: false,
      load_migracao: false,
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
    carregando: () => import("../components/carregando.vue"),
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
    },

    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;

      dados = data;

      this.taskDetails = data && data.ds_informativo;

      if (!data.ds_informativo == "") {
        this.temD = true;
      }
    },

    async carregaDados() {
      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_menu = localStorage.cd_menu;
      var cd_api = localStorage.cd_api;

      if (this.cd_api_autoform > 0) {
        cd_api = this.cd_api_autoform;
      }

      if (this.cd_menu_autoform > 0) {
        cd_menu = this.cd_menu_autoform;
      }

      api = localStorage.nm_identificacao_api;

      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);

      dados = await Menu.montarMenu(cd_empresa, cd_menu, 0); //'titulo';

      if (!dados.nm_identificacao_api == "") {
        api = dados.nm_identificacao_api;
      }

      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      this.tituloColuna = dados.tituloColuna;

      this.tituloMenu = dados.nm_menu_titulo;
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
      let consulta = {
        cd_parametro: 0,
      };
      this.api = localStorage.nm_identificacao_api;
      this.dataSourceConfig = await Incluir.incluirRegistro(this.api, consulta);

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

    async onGeraMigracao() {
      try {
        this.load_migracao = true;
        let { data } = await axios.get(
          "https://egis-store.com.br/palasAthena/migra"
        );
        notify(data.Msg);
        this.carregaDados();
      } catch (error) {
        notify("Não foi possível realizar a migração");
        console.error(error, "error");
      } finally {
        this.load_migracao = false;
      }
    },

    async onPropostaMagento() {
      this.loadProposta = true;
      if (this.nm_proposta_magento.length === 9) {
        fetch(`http://51.79.20.72:3003/${this.nm_proposta_magento}`)
          .then((response) => {
            if (!response.ok) {
              throw new Error("Erro na requisição a API");
            }
            this.loadProposta = false;
            return response.json();
          })
          .then((data) => {
            notify(data[0].Msg);
            //
            this.carregaDados();
            //
            this.loadProposta = false;
            //console.log(data, "data1");
          })
          .catch(() => {
            notify(`Não foi possível inserir a proposta!`);
            this.loadProposta = false;
            //console.error("Error:", error);
          });
      } else {
        notify(`Número da proposta inválido!`);
        this.loadProposta = false;
      }
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
