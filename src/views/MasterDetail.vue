<template>
  <div class="fundo">
    <h6 class="content-block">
      {{ tituloMenu }}
      <q-badge
        v-if="qt_registro > 0"
        align="middle"
        rounded
        color="blue"
        :label="qt_registro"
      />
      <q-btn
        v-if="botao.ic_ativo"
        class="margin1"
        @click="onButton()"
        :round="!!botao.label == false"
        :rounded="!!botao.label"
        :label="botao.label"
        :color="botao.cor"
        :icon="botao.icone"
      >
        <q-tooltip
          v-if="botao.tooltip"
          anchor="bottom middle"
          self="top middle"
          :offset="[10, 10]"
        >
          {{ botao.tooltip }}
        </q-tooltip>
      </q-btn>
    </h6>

    <dx-data-grid
      class="dx-card wide-card-d jj"
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
      @focused-row-changed="onFocusedRowChanged"
    >
      <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
      <DxGrouping :auto-expand-all="true" />
      <DxExport :enabled="true" />

      <DxPaging :enable="true" :page-size="10" />

      <DxStateStoring
        :enabled="true"
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
var cd_cliente = 0;

var filename = "DataGrid.xlsx";
var dados = [];

var selecionada = [];

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
    //  DxLoadPanel
  },
  props: {
    cd_menuID: { type: Number, default: 0 },
    cd_apiID: { type: Number, default: 0 },
    cd_procedimentoID: { type: Number, default: 0 },
    cd_parametroID: { type: Number, default: 0 },
    //A linha selecionada tem que ter cd_documento = chave
    linha: { type: Object, default: () => ({}) },
    masterDetailData: {
      type: Object,
      default: () => ({}),
    },
    botao: {
      type: Object,
      default: () => ({}),
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
      Numero: 0,
      api: 0,
      cd_parametro: 0,
      cd_menu: 0,
      cd_api: 0,
      cd_procedimento: 0,
      qt_registro: 0,
    };
  },
  created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    // locale('pt-BR');

    //Vamos ter que colocar um atributo padrao...
    //ccf-11.05.2201
    //this.cd_documento  = data && data.cd_pedido_compra;
    //
    this.cd_parametro = this.masterDetailData.data.cd_cab_padrao;
    if (this.cd_parametroID != 0) {
      this.cd_parametro = this.cd_parametroID;
    }
    this.cd_menu = this.cd_menuID;
    this.cd_api = this.cd_apiID;
    this.cd_procedimento = this.cd_procedimentoID;
  },

  async mounted() {
    this.carregaDados();
  },

  Selecionada() {
    return selecionada;
  },

  methods: {
    onFocusedRowChanged: function (e) {
      //e.rowElement.bgColor = 'yellow';
      var data = e.row && e.row.data;
      selecionada = data;
      // this.taskSubject = data && data.ds_informativo;
      this.taskDetails = data && data.ds_informativo;

      if (!data.ds_informativo == "") {
        this.temD = true;
      }

      //this.focusedRowKey = e.component.option('focusedRowKey');
    },

    onButton() {
      this.$emit("ClickButton", this.botao.funcao);
    },

    async carregaDados() {
      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;

      //localStorage.cd_parametro = 0;

      if (!this.cd_parametro == 0) {
        localStorage.cd_parametro = this.cd_parametro;
      }

      //localStorage.cd_parametro = this.Numero.Numero;

      dados = await Menu.montarMenu(cd_empresa, this.cd_menu, this.cd_api); //'titulo';

      let sParametroApi = dados.nm_api_parametro;

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }
      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;
      if (dados.cd_parametro) {
        localStorage.cd_parametro = dados.cd_parametro;
      }
      if (this.linha.cd_documento) {
        localStorage.cd_documento = this.linha.cd_documento;
      }

      this.tituloMenu = dados.nm_menu_titulo;

      //

      //Gera os Dados para Montagem da Grid
      //exec da procedure
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        this.api,
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
<style scoped>
.jj {
  color: #333;
}

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
