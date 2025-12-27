<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <h2 class="content-block margin1">
      {{ tituloMenu }}
      <q-badge
        v-if="qt_registro > 0"
        align="middle"
        rounded
        color="red"
        :label="qt_registro + ' Contratos'"
      />
    </h2>
    <q-btn
      class="margin1"
      color="orange-10"
      icon="assignment"
      label="Aprovar/Declinar"
      @click="onContratoSelect"
    />

    <dx-data-grid
      v-if="GridFlag"
      class="dx-card wide-card margin1"
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
      :cacheEnable="false"
      @exporting="onExporting"
      @initialized="saveGridInstance"
      @focused-row-changed="onFocusedRowChanged"
      :selectedrow-keys="selectedRowKeys"
      @selection-Changed="Linha"
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
    <div v-if="dados_contrato == true">
      <q-dialog v-model="dados_contrato" full-width>
        <q-card>
          <q-card-section class="row items-center">
            <div class="text-h6 col">DADOS DO CONSÓRCIO</div>
            <div class="text-h6 col items-end">
              <q-icon style="float: right" name="close" v-close-popup />
            </div>
          </q-card-section>
          <q-separator />
          <q-card-section align="center">
            <DxTabs
              class="dx-card wide-card tab"
              :data-source="longtabs"
              :v-model="selectedIndex"
              :selected-index.sync="selectedIndex"
            />
          </q-card-section>

          <q-card-section v-if="longtabs[selectedIndex].id == 0">
            <q-item-label class="text-h6" overline
              >Ficha de Venda: {{ data.cd_contrato }}</q-item-label
            >
            <q-item style="height: 50%">
              <q-item-section class="bordas">
                <q-item-label>Contrato</q-item-label>
                <q-item-label caption>
                  <b class="b" overline>Data: </b> {{ dt_contrato }} <br />
                  <b class="b" overline>Administradora: </b>
                  {{ data.nm_administradora }} <br />
                  <b class="b" overline>Equipe: </b> {{ data.nm_equipe }} <br />
                  <b class="b" overline>Seguro: </b>
                  {{ data.ic_seguro_contrato }} <br />
                </q-item-label>
              </q-item-section>
              <q-item-section class="bordas">
                <q-item-label>Cliente</q-item-label>
                <q-item-label caption>
                  <b class="b" overline>Nome: </b>
                  {{ data.nm_fantasia_cliente }} <br />
                  <b class="b" overline>CNPJ/CPF: </b>
                  {{ data.cd_cnpj_cliente }}
                </q-item-label>
              </q-item-section>
            </q-item>
          </q-card-section>

          <q-card-section v-if="longtabs[selectedIndex].id == 0">
            <q-input
              placeholder="Observação"
              v-model="justificativa"
              filled
              type="textarea"
            />
          </q-card-section>

          <q-card-section v-if="longtabs[selectedIndex].id == 1">
            <div v-if="lista_documentos.length > 0">
              <div
                v-for="(d, index) in lista_documentos"
                class="row"
                v-bind:key="index"
              >
                <div class="row col">{{ d.nm_contrato_documento }}</div>
                <div class="row col">{{ d.nm_tipo_documento }}</div>
                <div>
                  <a :href="d.vb_documento"
                    ><q-icon
                      color="orange-10"
                      size="md"
                      name="cloud_download"
                      href
                  /></a>
                </div>
              </div>
            </div>
            <div v-else class="text-h6 text-center">Sem documentos</div>
          </q-card-section>

          <q-card-section
            v-if="longtabs[selectedIndex].id == 2"
            class="text-subtitle2"
          >
            <div v-for="(a, index) in cotas" :key="index" class="row">
              <div class="col">Cota: {{ a.nm_ref_cota }}</div>
              <div class="col">Valor: {{ a.vl_contrato }}</div>
              <div class="col">Prazo: {{ a.qt_prazo_cota }}</div>
              <div class="col">Grupo: {{ a.cd_grupo_cota }}</div>
              <div class="col">Tabela: {{ a.nm_tabela }}</div>

              <q-separator />
            </div>
          </q-card-section>

          <q-separator />

          <q-card-actions align="center">
            <div>
              <q-btn
                class="margin1"
                color="positive"
                icon="check"
                label="Aprovar"
                @click="onClickAprovar($event)"
                v-close-popup
              />

              <!--<DxButton
                        :width="120"
                        text="APROVAR"
                        type="success"
                        styling-mode="contained"
                        horizontal-alignment="left"
                        @click="onClickAprovar($event)"
                         v-close-popup
                      />-->
            </div>
            <div>
              <q-btn
                class="margin1"
                color="negative"
                icon="close"
                label="Declinar"
                @click="onClickDeclinar($event)"
                v-close-popup
              />
              <!--<DxButton
                        :width="120"
                        text="DECLINAR"
                        type="danger"
                        styling-mode="contained"
                        horizontal-alignment="left"
                         v-close-popup
                        @click="onClickDeclinar($event)"
                      />   -->
            </div>
          </q-card-actions>
        </q-card>
      </q-dialog>
    </div>

    <!---------------------------------------------------------------->
    <q-dialog v-model="confirma_obs">
      <q-card>
        <div>teste</div>
      </q-card>
    </q-dialog>
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
import Incluir from "../http/incluir_registro";
import formataData from "../http/formataData";
import DxTabs from "devextreme-vue/tabs";
import grid from "../views/grid";

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
      confirma_obs: false,
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
      GridFlag: true,
      cd_api_detalhe: 0,
      selectedRowKeys: [],
      api_ficha: "706/1073", //1539 -  pr_egisnet_cadastra_ficha_venda
      api_c: "",
      justificativa: "",
      data: {},
      lista_documentos: [],
      cotas: [],

      dados_contrato: false,
      contrato_selecionado: {},

      cont: 0,
      longtabs: [
        { text: "Dados", id: 0 },
        { text: "Documentos", id: 1 },
        { text: "Contratos / Cotas", id: 2 },
      ],
      selectedIndex: 0,
      documentos_pos_venda: [],
      dados_ficha_venda: [],
      dt_contrato: "",
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
    DxTabs,
    //DxLoadPanel
  },

  methods: {
    async ConsultaCotas() {
      let c = {
        cd_parametro: 12,
        cd_contrato: this.data.cd_contrato,
      };
      this.cotas = await Incluir.incluirRegistro(this.api_ficha, c);
    },

    Linha({ selectedRowsData }) {
      this.contrato_selecionado = selectedRowsData[0];
    },

    onFocusedRowChanged: function (e) {
      this.data = e.row && e.row.data;
    },

    async onContratoSelect() {
      await this.ConsultaDadosContrato();
      await this.Consultadoc();
      this.dados_contrato = true;
      await this.ConsultaCotas();
    },
    async Consultadoc() {
      let d = {
        cd_parametro: 9,
        cd_contrato: this.data.cd_contrato,
      };
      this.lista_documentos = await Incluir.incluirRegistro("606/844", d);
    },

    async carregaDados() {
      this.GridFlag = false;

      localStorage.cd_parametro = 0;
      localStorage.cd_tipo_consulta = 0;
      localStorage.nm_documento = "null";

      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      cd_menu = localStorage.cd_menu;
      cd_api = localStorage.cd_api;
      api = localStorage.nm_identificacao_api;

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';
      let sParametroApi = dados.nm_api_parametro;

      //localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      this.cd_detalhe = dados.cd_detalhe;
      this.cd_menu_detalhe = dados.cd_menu_detalhe;
      this.cd_api_detalhe = dados.cd_api_detalhe;
      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';

      //462/638 - 1339 - pr_aprova_contrato_consorcio
      this.api_c = api;
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        api,
        sParametroApi
      );
      this.qt_registro = this.dataSourceConfig.length;

      filename = this.tituloMenu + ".xlsx";
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      await this.sleep(500);
      this.GridFlag = true;
    },

    customizeColumns(columns) {
      columns[0].width = 120;
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    async ConsultaDadosContrato() {
      localStorage.cd_parametro = this.data.cd_contrato;

      var api_consulta_dados = "492/695";
      var parametrosApi = "/${cd_empresa}/${cd_parametro}";

      this.dados_ficha_venda = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        api_consulta_dados,
        parametrosApi
      );
      this.dt_contrato = formataData.formataDataJS(this.data.dt_contrato);
    },

    async onClickAprovar() {
      if (this.justificativa == "") {
        this.justificativa = "null";
      }
      localStorage.cd_tipo_consulta = 0;
      localStorage.cd_parametro = this.data.cd_contrato;

      localStorage.nm_documento = this.justificativa;
      this.GridFlag = false;
      var api_aprovar = "462/638"; //1339 - pr_aprova_contrato_consorcio
      var param_api =
        "/${cd_empresa}/${cd_parametro}/${nm_documento}/${cd_usuario}/${cd_tipo_consulta}";
      var aprovado = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        api_aprovar,
        param_api
      );

      notify(`Registro atualizado com sucesso!`);
      localStorage.cd_parametro = 0;
      localStorage.nm_documento = "";
      this.justificativa = "";
      this.contrato_selecionado = {};
      this.carregaDados();
      await this.sleep(500);
      this.GridFlag = true;
    },

    async onClickDeclinar() {
      let jus;
      if (this.justificativa == "") {
        jus = "null";
      } else {
        jus = this.justificativa;
      }

      localStorage.cd_parametro = this.data.cd_contrato;
      localStorage.nm_documento = jus;
      var api_aprovar = "462/638";
      var param_api =
        "/${cd_empresa}/${cd_parametro}/${nm_documento}/${cd_usuario}/${cd_tipo_consulta}";
      this.GridFlag = false;
      localStorage.cd_tipo_consulta = 1;
      var declinio = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        api_aprovar,
        param_api
      );

      notify(declinio[0].Msg);
      localStorage.cd_parametro = 0;
      localStorage.nm_documento = "";
      this.justificativa = "";
      this.contrato_selecionado = {};
      await this.sleep(500);
      this.carregaDados();
      this.GridFlag = true;

      //  notify('Contrato Declinado')
    },
    async sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
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

.bordas {
  border-left: 6px solid rgb(255, 148, 148);
  background-color: rgb(255, 255, 255);
  height: 100%;
}

.b {
  margin-left: 10px;
}
.margin1 {
  margin: 0.4vw 0.7vw;
  padding: 0;
}
.tab {
  width: 96%;
}
</style>
