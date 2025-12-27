<template>
  <div>
    <div>
      <h2 class="content-block">{{ tituloMenu }}</h2>
    </div>
    <div>
      <form
        class="dx-card wide-card"
        v-if="ic_filtro_pesquisa == 'S'"
        action="your-action"
        @submit="handleSubmit"
      >
        <b> Período: {{ dt_inicial }} até {{ dt_final }}</b>
        <DxForm
          :form-data="filtro"
          :read-only="false"
          :show-colon-after-label="true"
          :show-validation-summary="true"
        >
          <DxGroupItem caption="Parâmetros"> </DxGroupItem>
          <DxSimpleItem
            :editor-options="dateBoxOptions"
            data-field="nm_campo"
            editor-type="dxDateBox"
          >
            <DxLabel text="Data Base" />
          </DxSimpleItem>
        </DxForm>
        <div>
          <DxButton
            class="buttons-column"
            :width="120"
            text="Pesquisar"
            type="default"
            styling-mode="contained"
            horizontal-alignment="left"
            @click="onClick($event)"
          />
        </div>
      </form>
    </div>
    <DxTabPanel
      class="dx-card wide-card tabPanel"
      v-if="qt_tabsheet > 0 && ic_filtro_pesquisa == 'N'"
      :data-source="tabs"
      :visible="true"
      :show-nav-buttons="true"
      :repaint-changes-only="true"
      :selected-index.sync="selectedIndex"
      :on-title-click="tabPanelTitleClick"
      item-title-template="title"
      item-template="itemTemplate"
    >
      <template #title="{ data: tab }">
        <div>
          <span>{{ tab.nm_label_tabsheet }}</span>
        </div>
      </template>

      <template v-if="!cd_menu_destino == 0" #itemTemplate="{ data: tab }">
        <componente
          v-if="qt_tabsheet > 0"
          :cd_menuID="cd_menu_destino"
          :cd_apiID="cd_api_destino"
          :cd_parametroID="0"
          slot="{tab.nm_label_tabsheet}"
        />
      </template>
    </DxTabPanel>

    <dx-data-grid
      v-if="qt_tabsheet == 0"
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
      <DxEditing
        :refresh-mode="refreshMode"
        :allow-adding="false"
        :allow-updating="true"
        :allow-deleting="false"
        mode="popup"
      >
        <DxPopup :show-title="true" :width="700" :height="625" :title="menu">
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
    <div>
      <ordem
        v-if="ic_ordem == 'xS'"
        :cd_ordemID="cd_ordem"
        :o_ordem="oProcesso"
      ></ordem>
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

import DxForm, {
  DxGroupItem,
  DxSimpleItem,
  DxLabel,
  DxItem,
} from "devextreme-vue/form";

import DxButton from "devextreme-vue/button";
import DxTabPanel from "devextreme-vue/tab-panel";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import componente from "../views/display-componente";
import ordem from "../views/ordem-producao";
import "whatwg-fetch";

var cd_empresa = 0;
var cd_menu = 0;
var cd_cliente = 0;
var cd_api = 0;
var api = "";

var filename = "DataGrid.xlsx";

var dados = [];

const dataGridRef = "dataGrid";

export default {
  data() {
    return {
      tituloMenu: "",
      menu: "",
      dt_inicial: "",
      dt_final: "",
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
      qt_tabsheet: 0,
      tabs: [],
      selectedIndex: 0,
      cd_menu_destino: 0,
      cd_api_destino: 0,
      ic_filtro_pesquisa: "N",
      ic_ordem: "N",
      cd_ordem: 0,
      oProcesso: "",
      filtro: [],
      buttonOptions: {
        text: "Confirmar",
        type: "success",
        useSubmitBehavior: true,
      },
      dateBoxOptions: {
        invalidDateMessage: "Data tem estar no formato: dd/mm/yyyy",
      },
      cd_controle: null,
      refreshMode: "reshape",
      sChave: "",
      tituloColuna: [],
      focogrid: false,
    };
  },
  computed: {
    dataGrid: function () {
      return this.$refs[dataGridRef].instance;
    },
  },
  created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();
    this.dt_final = new Date(localStorage.dt_final).toLocaleDateString();
    this.cd_ordem = 0;
    this.ic_ordem = "N";
    this.qt_tabsheet = 0;
  },

  async mounted() {
    this.carregaDados();
  },

  async beforeupdate() {
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
    DxTabPanel,
    componente,
    DxForm,
    DxGroupItem,
    DxButton,
    DxSimpleItem,
    DxLabel,
    DxEditing,
    DxPosition,
    DxPopup,
    DxItem,
    ordem,
  },

  methods: {
    handleSubmit: function (e) {
      notify(
        {
          message: "Você precisa confirmar os Dados para pesquisa !",
          position: {
            my: "center top",
            at: "center top",
          },
        },
        "success",
        3000
      );
      e.preventDefault();
    },

    tabPanelTitleClick: function (e) {
      // ...
      //alert(e);
      // console.log(e);
      this.selectedIndex = e.itemIndex;

      this.cd_menu_destino = this.tabs[this.selectedIndex].cd_menu_composicao;
      this.cd_api_destino = this.tabs[this.selectedIndex].cd_api;

      //parseInt(this.tabs[this.selectedIndex].cd_menu_composicao, this.cd_menu_destino);
      //parseInt(this.tabs[this.selectedIndex].cd_api_destino,this.cd_api_destino);
      //console.log(e.itemIndex);
      //console.log(this.cd_menu_destino);
      // console.log(this.cd_api_destino);
      //
    },
    //

    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;
      this.taskDetails = data && data.ds_informativo;

      if (!data.ds_informativo == "") {
        this.temD = true;
      }

      //console.log(data.cd_processo);

      this.ic_ordem = "N";

      if (!data.cd_processo == 0) {
        this.cd_ordem = data.cd_processo;
        this.oProcesso = data;
        this.ic_ordem = "S";
      }
    },

    async carregaDados() {
      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      cd_menu = localStorage.cd_menu;
      cd_api = localStorage.cd_api;
      api = localStorage.nm_identificacao_api;

      var data = new Date(),
        dia = data.getDate().toString(),
        diaF = dia.length == 1 ? "0" + dia : dia,
        mes = (data.getMonth() + 1).toString(), //+1 pois no getMonth Janeiro começa com zero.
        mesF = mes.length == 1 ? "0" + mes : mes,
        anoF = data.getFullYear();

      localStorage.dt_inicial = mes + "-" + dia + "-" + anoF;
      localStorage.dt_final = mesF + "-" + diaF + "-" + anoF;

      //alert(api);

      //if (api=='') {
      //  alert('erro de processamento - verifique com suporte !');
      // }

      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';

      let sParametroApi = dados.nm_api_parametro;

      this.qt_tabsheet = dados.qt_tabsheet;
      this.cd_menu_destino = cd_menu;
      this.cd_api_destino = cd_api;
      this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa;

      //parseInt(cd_menu, this.cd_menu_destino);
      //parseInt(cd_api,this.cd_api_destino);

      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      //alert( dados.cd_tipo_consulta);

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.menu = dados.nm_menu;
      this.tituloColuna = dados.tituloColuna;

      if (this.qt_tabsheet == 0) {
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
        //filenamepdf = this.tituloMenu+'.pdf';

        //dados da coluna
        this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

        //dados do total
        this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
        //
      }

      //TabSheet
      this.tabs = [];

      if (!this.qt_tabsheet == 0) {
        this.tabs = JSON.parse(JSON.parse(JSON.stringify(dados.TabSheet)));
        //console.log(this.tabs);
        //console.log(this.tabs[0].nm_label_tabsheet);
      }

      //Filtros
      //console.log(this.ic_filtro_pesquisa);
      //console.log(dados.Filtro);

      this.filtro = [];

      if (this.ic_filtro_pesquisa == "S") {
        this.filtro = JSON.parse(JSON.parse(JSON.stringify(dados.Filtro)));
      }

      this.ic_ordem = "N";
      this.cd_ordem = 0;

      if (!dados.chave == "") {
        this.sChave = dados.chave;
        this.focogrid = true;
      }
    },

    onClick(e) {
      this.ic_filtro_pesquisa = "N";
      //this.carregaDados();
      //this.cd_ordem = 900;
    },

    customizeColumns(columns) {
      columns[0].width = 120;
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Consulta");

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

    exportGrid() {
      //    const doc = new jsPDF();
      //    exportDataGridToPdf({
      //      jsPDFDocument: doc,
      //      component: this.dataGrid
      //    }).then(() => {
      //      doc.save(filenamepdf);
      //    });
    },

    destroyed() {
      this.$destroy();
    },
  },
};
</script>
<style>
#parametro {
  margin-top: 5px;
  padding-top: 5px;
}

form {
  margin-left: 10px;
  margin-right: 10px;
  padding-left: 10px;
  padding-right: 10px;
  margin-top: 5px;
}

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

#exportButton {
  margin-bottom: 10px;
}
</style>
