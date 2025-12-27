<template>
  <div>
    <h2 class="content-block">{{ tituloMenu }}</h2>

    <div class="row" v-if="(this.cd_local_usuario = 0)">
      <q-select
        label="Local Comanda"
        v-model="local_comanda"
        input-debounce="0"
        class="col-3 margin1"
        :options="this.dataset_dados_local_comanda"
        option-value="cd_local"
        option-label="nm_local"
      >
        <template v-slot:prepend>
          <q-icon name="description" />
        </template>
      </q-select>
    </div>

    <q-btn
      align="left"
      class="btn-fixed-width margin1"
      color="positive"
      label="Finalizar"
      icon="check"
      @click="onFinalizar()"
    />

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
      @selection-Changed="itemSelecionado"
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
      <DxSelection :select-all-mode="allMode" mode="multiple" />

      <DxSelectBox
        id="select-all-mode"
        :data-source="['allPages', 'page']"
        :disabled="'onClick' === 'none'"
        :v-model:value="allMode"
      />

      <DxPager
        :show-page-size-selector="true"
        :allowed-page-sizes="pageSizes"
        :show-info="true"
      />
      <DxHeaderFilter :visible="true" :allow-search="true" />
      <DxSearchPanel
        :visible="temPanel"
        :width="100"
        placeholder="Procurar..."
      />
      <DxFilterPanel :visible="true" />
      <DxColumnFixing :enabled="true" />
      <DxColumnChooser :enabled="true" mode="select" />
      <DxMasterDetail
        v-if="!cd_detalhe == 0"
        :enabled="true"
        template="master-detail"
      />

      <template #master-detail="{ data }">
        <MasterDetail
          :cd_menuID="cd_menu_detalhe"
          :cd_apiID="cd_api_detalhe"
          :master-detail-data="data"
        />
      </template>
    </dx-data-grid>

    <!---CARREGANDO----------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando></carregando>
    </q-dialog>
    <!------------------------------------------------->
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
} from "devextreme-vue/data-grid";

import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import DxButton from "devextreme-vue/button";
import notify from "devextreme/ui/notify";
import MasterDetail from "../views/MasterDetail";
import Lookup from "../http/lookup";
import DxSelectBox from "devextreme-vue/select-box";
import carregando from "../components/carregando.vue";

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
    DxSelectBox,
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
    carregando,
  },

  data() {
    return {
      tituloMenu: "",
      load: false,
      dataSourceConfig: [],
      pageSizes: [10, 20, 50, 100],
      allMode: "allPages",
      polling: null,
      local_comanda: [],
      dados_local_comanda: [],
      dataset_dados_local_comanda: [],
      columns: [],
      lista_finaliza: [],
      total: {},
      cd_local_usuario: 0,
      cd_usuario: 0,
      temPanel: false,
      qt_registro: 0,
      cd_detalhe: 0,
      cd_menu_detalhe: 0,
      cd_api_detalhe: 0,
      cd_api_finaliza: "699/1054",
    };
  },
  async mounted() {
    this.cd_usuario = localStorage.cd_usuario;
    /*----------------------------------------------------------------------------------------------------*/
    this.dados_local_comanda = await Lookup.montarSelect(
      localStorage.cd_empresa,
      4676
    );
    this.dataset_dados_local_comanda = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_local_comanda.dataset))
    );
    /*----------------------------------------------------------------------------------------------------*/

    this.$q.fullscreen.toggle();
    this.carregaDados();
    this.pollData();
  },
  beforeDestroy() {
    clearInterval(this.polling);
  },

  methods: {
    pollData() {
      this.polling = setInterval(() => {
        this.carregaDados();
      }, 36000);
    },

    async carregaDados() {
      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      cd_menu = localStorage.cd_menu;
      cd_api = localStorage.cd_api;
      api = localStorage.nm_identificacao_api;

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';

      let sParametroApi = dados.nm_api_parametro;

      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      this.cd_detalhe = dados.cd_detalhe;
      this.cd_menu_detalhe = dados.cd_menu_detalhe;
      this.cd_api_detalhe = dados.cd_api_detalhe;

      this.tituloMenu = dados.nm_menu_titulo;

      //Gera os Dados para Montagem da Grid
      //exec da procedure
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        api,
        sParametroApi
      );

      if (this.dataSourceConfig.length > 0) {
        this.cd_local_usuario = this.dataSourceConfig[0].cd_local_usuario;
      }
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

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    itemSelecionado({ selectedRowKeys, selectedRowsData }) {
      this.lista_finaliza = selectedRowsData;
    },

    onFinalizar() {
      if (this.lista_finaliza.length > 0) {
        this.load = true;
        this.lista_finaliza.forEach(async (item, i) => {
          var dadosFinaliza = {
            cd_parametro: 2,
            cd_usuario: localStorage.cd_usuario,
            cd_registro_venda: item.cd_registro_venda,
            cd_item_registro_venda: item.cd_item_registro_venda,
          };
          var finalizou = await Incluir.incluirRegistro(
            this.cd_api_finaliza,
            dadosFinaliza
          );
          notify(finalizou[0].Msg);
        });
        this.carregaDados();
        this.load = false;
      } else {
        notify("Nenhum item foi selecionado!");
      }
    },

    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;
      // this.taskSubject = data && data.ds_informativo;
      this.taskDetails = data && data.ds_informativo;

      //alert(this.taskDetais);

      localStorage.cd_identificacao = data && data.cd_pedido_compra;

      //
      if (!data.ds_informativo == "") {
        this.temD = true;
      }

      //alert(this.temD);

      //this.focusedRowKey = e.component.option('focusedRowKey');
    },
  },
};
</script>

<style scoped>
.direita {
  float: right;
  right: 10px;
  text-align: right;
}
.margin1 {
  margin: 0.5% 0.4%;
  padding: 0;
}
</style>