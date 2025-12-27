<template>
  <div>
    <div>
      <DxButton
        v-if="!cd_tipo_email == 0"
        class="botao-info"
        icon="email"
        text=""
        @click="renderDoc"
      />
      <DxButton
        v-if="1 == 2"
        class="botao-info"
        icon="print"
        text=""
        @click="renderDoc"
      />

      <DxButton
        v-if="!ds_menu_descritivo == ''"
        class="botao-info"
        icon="info"
        text=""
        @click="popClick()"
      />
      <DxButton
        class="botao-info"
        icon="event"
        text=""
        @click="popClickData()"
      />
      <DxButton
        v-if="1 == 2"
        class="botao-info"
        icon="plus"
        text=""
        @click="popClick()"
      />
      <div class="info-periodo" v-if="periodoVisible == true">
        De: {{ dt_inicial }} até {{ dt_final }}
      </div>
      <h2 class="content-block">
        {{ tituloMenu }} {{ hoje }} {{ hora }}

        <q-badge
          v-if="qt_registro > 0"
          align="middle"
          rounded
          color="red"
          :label="qt_registro"
        />
      </h2>
    </div>
    <div>
      <form
        class="dx-card wide-card"
        v-if="ic_filtro_pesquisa == 'S'"
        action="your-action"
        @submit="handleSubmit"
      >
        <q-select
          filled
          clearable
          :option-value="value_lookup"
          :option-label="label_lookup"
          v-model="selecionada_lookup"
          :options="dataset_lookup"
          :label="placeholder_lookup"
        />

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
          <i v-show="ShowDestino()" />
        </div>
      </template>

      <template v-if="!cd_menu_destino == 0" #itemTemplate="{ data: tab }">
        <componente
          v-if="qt_tabsheet > 0 && !cd_menu_destino == 0"
          :cd_menuID="cd_menu_destino"
          :cd_apiID="cd_api_destino"
          :tab-data="tab"
          slot="tab.nm_label_tabsheet"
          ref="componentetabsheet"
        />
      </template>
    </DxTabPanel>

    <dx-data-grid
      v-if="qt_tabsheet == 0"
      id="grid-padrao"
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

      <DxPaging :page-size="10" />

      <DxSelection
        :select-all-mode="allMode"
        :show-check-boxes-mode="checkBoxesMode"
        mode="multiple"
      />

      <DxSelectBox
        id="select-all-mode"
        :data-source="['allPages', 'page']"
        :disabled="checkBoxesMode === 'none'"
        :v-model:value="allMode"
      />

      <DxStateStoring
        :enabled="true"
        type="localStorage"
        storage-key="storageGrid"
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
        :allow-updating="true"
        :allow-adding="false"
        :allow-update="true"
        mode="cell"
      >
        <DxPopup :show-title="true" title="menu">
          <DxPosition my="top" at="top" of="window" />
        </DxPopup>
        <DxForm :form-data="formData" :items="items">
          <DxItem :col-count="2" :col-span="2" item-type="group" />
        </DxForm>
      </DxEditing>

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

    <div class="task-info" v-if="temD === true">
      <div class="info">
        <div id="taskSubject">{{ taskSubject }}</div>
        <p id="taskDetails" v-html="taskDetails" />
      </div>
    </div>
    <div></div>

    <div class="botao-exportar">
      <div>
        <DxButton
          v-if="exportar == true"
          :width="120"
          text="DOWNLOAD"
          type="default"
          styling-mode="contained"
          horizontal-alignment="left"
          @click="onClickExportar()"
        />
      </div>
    </div>

    <div class="botao-arquivo_abrir">
      <div>
        <DxButton
          v-if="arquivo_abrir == true"
          :width="120"
          text="ABRIR"
          type="default"
          styling-mode="contained"
          horizontal-alignment="left"
          @click="onClickArquivo()"
        />
      </div>
    </div>

    <DxPopup
      :visible="popupVisible"
      :title="tituloMenu"
      :height="250"
      :show-title="true"
      :close-on-outside-click="true"
      :drag-enabled="false"
      @hiding="onHiding"
    >
      <DxForm> </DxForm>
      <div>
        <b class="info-cor">{{ ds_menu_descritivo }}</b>
      </div>
    </DxPopup>

    <div v-if="ativaPDF" class="q-pa-md q-gutter-sm">
      <q-btn label="Maximized" color="primary" @click="dialog = true" />

      <q-dialog
        v-model="ativaPDF"
        persistent
        :maximized="true"
        transition-show="slide-up"
        transition-hide="slide-down"
      >
        <q-card class="bg-primary text-white">
          <q-bar>
            <div class="div50">
              <label> DOCUMENTO </label>
            </div>
            <div class="div48">
              <q-btn
                dense
                flat
                icon="minimize"
                @click="maximizedToggle = false"
                :disable="!maximizedToggle"
              >
                <q-tooltip
                  v-if="maximizedToggle"
                  content-class="bg-white text-primary"
                  >Minimize</q-tooltip
                >
              </q-btn>
              <q-btn
                dense
                flat
                icon="crop_square"
                @click="maximizedToggle = true"
                :disable="maximizedToggle"
              >
                <q-tooltip
                  v-if="!maximizedToggle"
                  content-class="bg-white text-primary"
                  >Maximize</q-tooltip
                >
              </q-btn>
              <q-btn dense flat icon="close" v-close-popup>
                <q-tooltip content-class="bg-white text-primary"
                  >Close</q-tooltip
                >
              </q-btn>
            </div>
          </q-bar>
          <q-space />

          <embed
            v-bind:src="onClickArquivo()"
            v-if="ativaPDF"
            width="100%"
            height="100%"
          />
        </q-card>
      </q-dialog>
    </div>

    <div v-if="popupData == true">
      <q-dialog v-model="popupData" persistent>
        <q-card>
          <q-card-section class="row items-center q-pb-none">
            <div class="text-h6">Seleção de Data</div>
            <q-space />
            <q-btn
              icon="close"
              @click="popClickData()"
              flat
              round
              dense
              v-close-popup
            />
          </q-card-section>

          <datad
            v-if="
              cd_menu_c == 6981 ||
              cd_menu_c == 6986 ||
              cd_menu_c == 6993 ||
              cd_menu_c == 6994 ||
              cd_menu_c == 7108 ||
              cd_menu_c == 7112 ||
              cd_menu_c == 7116
            "
            style="margin: 0.7vw 1vw"
          />

          <selecaoData v-else :cd_volta_home="1" />
        </q-card>
      </q-dialog>
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
  DxPosition,
  DxMasterDetail,
  //  DxPopup
} from "devextreme-vue/data-grid";

import { DxForm, DxItem } from "devextreme-vue/form";

import DxButton from "devextreme-vue/button";
import DxTabPanel from "devextreme-vue/tab-panel";
import { DxPopup } from "devextreme-vue/popup";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import datad from "../components/pesquisa-data.vue";

import selecaoData from "../views/selecao-periodo.vue";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import componente from "../views/display-componente";

import MasterDetail from "../views/MasterDetail";

import Lookup from "../http/lookup";

//import lookup from '../views/lookup';

//import periodo from '../views/selecao-periodo';

import "whatwg-fetch";

import Docxtemplater from "docxtemplater";

import PizZip from "pizzip";
import PizZipUtils from "pizzip/utils/index.js";
import DxSelectBox from "devextreme-vue/select-box";

function loadFile(url, callback) {
  PizZipUtils.getBinaryContent(url, callback);
}

if (1 == 1) {
  DxSelectBox == true;
}

var filename = "DataGrid.xlsx";
var filenametxt = "Arquivo.txt";
var filenamedoc = "Arquivo.docx";
var filenamexml = "Arquivo.xml";
var filenamepdf = "Arquivo.pdf";
//var filenamepdf = 'DataGrid.pdf';

var dados = [];
var sParametroApi = "";

const dataGridRef = "dataGrid";

export default {
  data() {
    return {
      tituloMenu: "",
      menu: "",
      dt_inicial: "",
      dt_final: "",
      dt_base: "",
      columns: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      total: {},
      dataGridInstance: null,
      refreshMode: "reshape",
      taskSubject: "Descritivo",
      tituloData: "Seleção de Perí­odo",
      taskDetails: "",
      temD: false,
      temPanel: false,
      qt_tabsheet: 0,
      tabs: [],
      selectedIndex: 0,
      cd_menu_destino: 0,
      cd_api_destino: 0,
      cd_tipo_consulta: 0,
      allMode: "allPages",
      checkBoxesMode: "onClick",
      ic_filtro_pesquisa: "N",
      qt_tempo: 0,
      filtro: [],
      polling: null,
      exportar: false,
      arquivo_abrir: false,
      ativaPDF: false,
      buttonOptions: {
        text: "Confirmar",
        type: "success",
        useSubmitBehavior: true,
      },
      dateBoxOptions: {
        invalidDateMessage: "Data tem estar no formato: dd/mm/yyyy",
      },
      cd_empresa: 0,
      cd_menu: 0,
      cd_cliente: 0,
      cd_api: 0,
      api: 0,
      ds_arquivo: "",
      nm_documento: "",
      ds_menu_descritivo: "",
      popupVisible: false,
      popupData: false,
      periodoVisible: false,
      ic_form_menu: "N",
      ic_tipo_data_menu: "0",
      hoje: "",
      hora: "",
      formData: {},
      items: [],
      formDataFiltro: {},
      itemsFiltro: [],
      cd_tipo_email: 0,
      cd_relatorio: 1,
      qt_registro: 0,
      cd_detalhe: 0,
      cd_menu_detalhe: 0,
      cd_api_detalhe: 0,

      filtro_data: false,

      dados_lookup: [],
      dataset_lookup: [],
      value_lookup: "",
      label_lookup: "",
      placeholder_lookup: "",
      selecionada_lookup: [],
      cd_menu_c: 0,

      periodo: "",
    };
  },
  computed: {
    dataGrid: function () {
      return this.$refs[dataGridRef].instance;
    },
  },

  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    this.cd_menu_c = localStorage.cd_menu;

    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;

    // locale('pt-BR');

    this.dt_inicial = localStorage.dt_inicial;
    this.dt_final = localStorage.dt_final;
    this.dt_base = localStorage.dt_base;
    this.periodoVisible = false;

    //this.dt_inicial = new Date(this.dt_inicial).toLocaleDateString();
    //this.dt_final   = new Date(this.dt_final).toLocaleDateString();

    this.hoje = "";
    this.hora = "";

    //localStorage.cd_identificacao = 0;
    //this.showMenu();
    //await this.showMenu();

    if (!this.qt_tempo == 0) {
      this.pollData();
      localStorage.polling = 1;
    }
  },

  async mounted() {
    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;

    this.carregaDados(true);
  },

  async beforeupdate() {
    this.carregaDados(true);
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
    DxSelectBox,
    DxStateStoring,
    DxSearchPanel,
    DxTabPanel,
    componente,
    DxForm,
    DxButton,
    DxPopup,
    DxEditing,
    DxPosition,
    DxItem,
    DxMasterDetail,
    MasterDetail,
    selecaoData,
    datad,

    //  DxLoadPanel
  },

  methods: {
    ShowDestino() {},

    popClick() {
      this.popupVisible = true;
    },

    popClickData() {
      if (this.popupData == false) {
        this.popupData = true;
      } else {
        this.popupData = false;
        if (this.qt_tabsheet == 0) {
          this.carregaDados(true);
        } else {
          //this.carregaDados();
          this.$refs.componentetabsheet.carregaDados();
        }
      }
    },

    onHiding() {
      this.popupVisible = false; // Handler of the 'hiding' event
    },

    async showMenu() {
      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_menu = localStorage.cd_menu;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      this.cd_menu_destino = 0;
      this.cd_api_destino = 0;
      localStorage.cd_parametro = 0;
      //

      var dataI = new Date(localStorage.dt_inicial);
      var diaI = dataI.getDate().toString();
      var mesI = (dataI.getMonth() + 1).toString();
      var anoI = dataI.getFullYear();
      localStorage.dt_inicial = mesI + "-" + diaI + "-" + anoI;

      var dataF = new Date(localStorage.dt_final);
      var diaF = dataF.getDate().toString();
      var mesF = (dataF.getMonth() + 1).toString();
      var anoF = dataF.getFullYear();
      localStorage.dt_final = mesF + "-" + diaF + "-" + anoF;

      var dataB = new Date(localStorage.dt_base);
      var diaB = dataB.getDate().toString();
      var mesB = (dataB.getMonth() + 1).toString();
      var anoB = dataB.getFullYear();

      localStorage.dt_base = mesB + "-" + diaB + "-" + anoB;

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';
      //this.sParametroApi       = dados.nm_api_parametro;
      sParametroApi = dados.nm_api_parametro;
      //

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      this.qt_tabsheet = dados.qt_tabsheet;
      this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa;
      this.exportar = false;
      this.arquivo_abrir = false;
      this.ativaPDF = false;
      this.qt_tempo = dados.qt_tempo_menu;
      this.ds_menu_descritivo = dados.ds_menu_descritivo;
      this.ic_form_menu = dados.ic_form_menu;
      this.ic_tipo_data_menu = dados.ic_tipo_data_menu;
      this.cd_tipo_email = dados.cd_tipo_email;
      this.cd_detalhe = dados.cd_detalhe;
      this.cd_menu_detalhe = dados.cd_menu_detalhe;
      this.cd_api_detalhe = dados.cd_api_detalhe;

      //this.cd_relatorio       = dados.cd_relatorio;

      if (this.ic_tipo_data_menu == "1") {
        this.hoje = " - " + new Date().toLocaleDateString();
      }
      if (this.ic_tipo_data_menu == "2" || this.ic_tipo_data_menu == "3") {
        this.hora = new Date().toLocaleTimeString().substring(0, 5);
      }

      if (dados.ic_exportacao == "S") {
        this.exportar = true;
      }

      localStorage.cd_tipo_consulta = 0;

      if (!dados.cd_tipo_consulta == 0) {
        localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.menu = dados.nm_menu;

      filename = this.tituloMenu + ".xlsx";
      filenametxt = this.tituloMenu + ".txt";
      filenamedoc = this.tituloMenu + ".docx";
      filenamexml = this.tituloMenu + ".xml";
      filenamepdf = this.tituloMenu + ".pdf";
      //filenamepdf = this.tituloMenu+'.pdf';

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //

      //TabSheet
      this.tabs = [];
      //

      if (!this.qt_tabsheet == 0) {
        this.tabs = JSON.parse(JSON.parse(JSON.stringify(dados.TabSheet)));
        this.cd_menu_destino = parseInt(this.cd_menu);
        this.cd_api_destino = parseInt(this.cd_api);
      }
      //Filtros

      this.filtro = [];

      if (this.ic_filtro_pesquisa == "S") {
        this.filtro = JSON.parse(JSON.parse(JSON.stringify(dados.Filtro)));

        this.dados_lookup = await Lookup.montarSelect(
          localStorage.cd_empresa,
          this.filtro[0].cd_tabela
        );
        this.dataset_lookup = JSON.parse(
          JSON.parse(JSON.stringify(this.dados_lookup.dataset))
        );
        this.value_lookup = this.filtro[0].nm_campo_chave_lookup;
        this.label_lookup = this.filtro[0].nm_campo;
        this.placeholder_lookup = this.filtro[0].nm_campo_descricao_lookup;
      }

      //trocar para dados.laberFormFiltro
      //this.formDataFiltro = JSON.parse(dados.Filtro);
      //this.itemsFiltro = JSON.parse(dados.labelForm);
      //
    },

    pollData: function () {
      if (this.qt_tempo > 0) {
        this.polling = setInterval(() => {
          this.carregaDados(true);
        }, this.qt_tempo);
      }
    },

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
        1000
      );
      e.preventDefault();
    },

    troca: function () {
      componente.chamaCarrega();
    },

    tabPanelTitleClick: function (e) {
      // ...
      // this.troca();

      this.selectedIndex = e.itemIndex;

      //if(this.selectedIndex == 0){
      //this.$refs.componentetabsheet.limpaDados();
      //}

      this.cd_menu_destino = this.tabs[this.selectedIndex].cd_menu_composicao;
      this.cd_api_destino = this.tabs[this.selectedIndex].cd_api;
      this.cd_parametro = localStorage.cd_parametro;

      this.cd_tipo_consulta = dados.cd_tipo_consulta;

      this.$refs.componentetabsheet.carregaDados(true);
    },

    //
    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;

      // this.taskSubject = data && data.ds_informativo;
      this.taskDetails = data && data.ds_informativo;
      this.ds_arquivo = data && data.ds_arquivo;
      this.nm_documento = data && data.nm_documento;

      if (!data.ds_informativo == "") {
        this.temD = true;
      }
      //this.cd_ordem = 900;

      //this.focusedRowKey = e.component.option('focusedRowKey');
    },

    async carregaDados(carregamenu) {
      if (carregamenu == true) {
        await this.showMenu();
      }

      this.temPanel = true;

      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);
      if (!this.qt_tabsheet == 0) {
        let sApis = sParametroApi;

        //

        //

        if (!sApis == "") {
          this.dataSourceConfig = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            this.api,
            sApis
          );

          this.qt_registro = this.dataSourceConfig.length;
          this.formData = this.dataSourceConfig[0];
          this.items = JSON.parse(dados.labelForm);
        }
      }

      if (this.qt_tabsheet == 0) {
        //Gera os Dados para Montagem da Grid
        //exec da procedure

        let sApi = sParametroApi;
        //
        //

        if (!sApi == "") {
          this.dataSourceConfig = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            this.api,
            sApi
          );

          this.qt_registro = this.dataSourceConfig.length;

          //onsole.log(this.dataSourceConfig);

          this.formData = this.dataSourceConfig[0];

          this.items = JSON.parse(dados.labelForm);
        }

        //
      }

      try {
        var TemDocumento = this.dataSourceConfig[0].nm_documento_pdf;
        if (TemDocumento != undefined) {
          this.arquivo_abrir = true;
        } else {
          this.arquivo_abrir = false;
        }
      } catch {}
    },

    async onClick() {
      this.dataSourceConfig = [];
      if (this.selecionada_lookup != null) {
        localStorage.cd_filtro =
          this.selecionada_lookup[this.filtro[0].nm_campo_chave_lookup];
        await this.carregaDados();
      } else {
        localStorage.cd_filtro = 0;
        await this.carregaDados();
      }
    },

    onClickArquivo() {
      if (this.nm_documento == "") {
        notify("Não existe documento para a Palestra. Obrigado !");
      } else {
        var caminhoPDF =
          "http://www.egisnet.com.br/documentos/Palestras/" + this.nm_documento;
        this.ativaPDF = true;
        return caminhoPDF;
      }
    },

    onClickExportar() {
      //   this.ic_filtro_pesquisa = 'N';
      //this.carregaDados();
      //this.cd_ordem = 900;
      //this.ds_arquivo = '';
      const data = this.ds_arquivo;

      if (this.ds_arquivo == null) {
        notify("Arquivo não encontrado ou sem informações!");
        //this.ds_arquivo = 'Arquivo Texto sem informações !'
        //const data = this.ds_arquivo;
        //const blob = new Blob([data], {type: 'text/plain'});
        //const em = document.createEvent('MouseEvents'),
        //a = document.createElement('a');
        //a.download = filenametxt;
        //a.href = window.URL.createObjectURL(blob);
        //a.dataset.downloadurl = ['text/json', a.download, a.href].join(':');
        //em.initEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
        //a.dispatchEvent(em);
      }
      //const data = JSON.stringify(this.arr);
      else if (this.ds_arquivo.includes("<NFe") == true) {
        const blob = new Blob([data], { type: "text/plain" });
        const em = document.createEvent("MouseEvents"),
          a = document.createElement("a");
        a.download = filenamexml;
        a.href = window.URL.createObjectURL(blob);
        a.dataset.downloadurl = ["text/json", a.download, a.href].join(":");
        em.initEvent(
          "click",
          true,
          false,
          window,
          0,
          0,
          0,
          0,
          0,
          false,
          false,
          false,
          false,
          0,
          null
        );
        a.dispatchEvent(em);
      } else {
        const blob = new Blob([data], { type: "text/plain" });
        const em = document.createEvent("MouseEvents"),
          a = document.createElement("a");
        a.download = filenametxt;
        a.href = window.URL.createObjectURL(blob);
        a.dataset.downloadurl = ["text/json", a.download, a.href].join(":");
        em.initEvent(
          "click",
          true,
          false,
          window,
          0,
          0,
          0,
          0,
          0,
          false,
          false,
          false,
          false,
          0,
          null
        );
        a.dispatchEvent(em);
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

    beforeDestroy() {
      clearInterval(this.polling);
    },

    destroyed() {
      this.$destroy();
    },

    renderDoc() {
      //loadFile("http://egisnet.com.br/template/template_GBS.docx", function(
      loadFile(
        "/Template_GBS.docx",
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

          doc.setData(
            dados

            //{
            //  dt_hoje: '26/04/2021',
            //  nm_menu_titulo: 'tÃ­tulo do menu',
            //  nm_identificacao_api: 'endereÃ§o da api'
            //
            // }
          );

          try {
            // render the document (replace all occurences of {first_name} by John, {last_name} by Doe, ...)
            doc.render();
          } catch (error) {
            // The error thrown here contains additional information when logged with JSON.stringify (it contains a properties object containing all suberrors).
            function replaceErrors(key, value) {
              if (value instanceof Error) {
                return Object.getOwnPropertyNames(value).reduce(function (
                  error,
                  key
                ) {
                  error[key] = value[key];
                  return error;
                },
                {});
              }
              return value;
            }

            if (error.properties && error.properties.errors instanceof Array) {
              const errorMessages = error.properties.errors
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

.botao-exportar {
  margin-top: 10px;
  margin-left: 10px;
}

.botao-arquivo_abrir {
  margin-top: 10px;
  margin-left: 10px;
}

.botao-info {
  float: right;
  right: 10px;
}
.info-periodo {
  margin-top: 10px;
  float: right;
  margin-right: 25px;
  right: 10px;
  font-size: 16px;
}

.info-cor {
  color: #506ad4;
  font-size: 20px;
}
#grid-padrao {
  max-height: 600px !important;
}
</style>
