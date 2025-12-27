<template>
  <div>
    <div>
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
    <div class="margin1">
      <q-card>
        <q-tabs
          dense
          v-model="tab"
          class="text-grey"
          active-color="orange-9"
          indicator-color="orange-9"
          align="justify"
          @input="TrocaTab(tab)"
        >
          <q-tab icon="analytics" name="DADOS" label="Dados"></q-tab>
          <q-tab icon="edit" name="CADASTRO" label="Cadastro"></q-tab>
        </q-tabs>

        <q-separator></q-separator>

        <q-tab-panels v-model="tab" animated>
          <q-tab-panel name="DADOS">
            <div class="borda-bloco margin1 shadow-2">
              <q-btn
                class="margin1"
                color="orange-9"
                icon="add"
                label="Novo"
                @click="onNovo()"
              />
              <dx-data-grid
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
                :focused-row-index="0"
                :cacheEnable="false"
                @exporting="onExporting"
                @initialized="saveGridInstance"
                @focused-row-changed="onFocusedRowChanged"
                @row-removed="removed"
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
                  :allow-update="true"
                  :allow-deleting="true"
                  mode="row"
                >
                  <DxPopup :show-title="true" title="menu">
                    <DxPosition my="top" at="top" of="window" />
                  </DxPopup>
                  <DxForm :form-data="formData" :items="items">
                    <DxItem :col-count="2" :col-span="2" item-type="group" />
                  </DxForm>
                </DxEditing>
              </dx-data-grid>
            </div>
          </q-tab-panel>
          <q-tab-panel name="CADASTRO">
            <div class="borda-bloco margin1 shadow-2">
              <div class="row">
                <q-input
                  class="margin1 col"
                  v-model="nm_avaliacao"
                  label="Avaliação"
                >
                  <template v-slot:prepend>
                    <q-icon name="quiz" />
                  </template>
                </q-input>

                <q-input
                  class="margin1 col"
                  v-model="ds_avaliacao"
                  label="Descrição da Avaliação"
                >
                  <template v-slot:prepend>
                    <q-icon name="description" />
                  </template>
                </q-input>
              </div>

              <q-input
                class="margin1"
                v-model="nm_questao"
                counter
                maxlength="80"
                label="Pergunta"
                :rules="[(val) => !!val || 'Campo obrigatório']"
              >
                <template v-slot:prepend>
                  <q-badge
                    color="orange-9"
                    text-color="white"
                    :label="cd_questao"
                  />
                  <q-icon name="help" />
                </template>
                <template v-slot:hint> Máximo de caracteres </template>
              </q-input>

              <div class="row">
                <q-select
                  class="margin1 col"
                  v-model="tipo_pergunta"
                  :options="dataset_tipo_pergunta"
                  option-value="cd_tipo_pergunta"
                  option-label="nm_tipo_pergunta"
                  label="Tipo de Pergunta"
                  @input="onTipoPergunta()"
                >
                  <template v-slot:prepend>
                    <q-icon name="format_list_numbered" />
                  </template>
                </q-select>
              </div>

              <div v-if="cd_tipo_pergunta == 1" class="margin1">
                <q-input
                  outlined
                  v-model="nm_resposta"
                  readonly
                  :label="'Resposta'"
                />
              </div>

              <div v-if="cd_tipo_pergunta == 4" class="margin1">
                {{ "Sim" }}
                <q-toggle disable v-model="ic_resposta" color="orange-9" />
                {{ "Não" }}
              </div>

              <div v-if="cd_tipo_pergunta == 6" class="margin1">
                <div class="row margin1">
                  <q-input
                    v-if="cd_empresa != 153"
                    class="col margin1"
                    type="number"
                    outlined
                    v-model="qt_estrela"
                    label="Quantidade"
                  />
                </div>
                <q-rating
                  readonly
                  class="margin1"
                  v-model="nm_resposta"
                  size="2em"
                  :max="qt_estrela"
                  color="primary"
                />
              </div>
              <q-btn
                flat
                class="margin1"
                color="orange-9"
                icon="add"
                label="Novo"
                @click="novaPergunta()"
              />
              <q-btn
                flat
                class="margin1"
                color="positive"
                icon="check"
                label="Confirmar"
                @click="OnSalvar()"
              />
            </div>

            <br />

            <div class="borda-bloco margin1 shadow-2" style="display: block">
              <dx-data-grid
                v-show="grid_item"
                class="dx-card wide-card margin1"
                :data-source="dataSourceConfigItem"
                :columns="columns_item"
                :summary="total_item"
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
                @focused-row-changed="onFocusedRowChangedItem"
                @row-removed="removed_Item"
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
                  :allow-update="false"
                  :allow-deleting="true"
                  mode="row"
                >
                  <DxPopup :show-title="true" title="menu">
                    <DxPosition my="top" at="top" of="window" />
                  </DxPopup>
                  <DxForm :form-data="formData" :items="items">
                    <DxItem :col-count="2" :col-span="2" item-type="group" />
                  </DxForm>
                </DxEditing>
              </dx-data-grid>
            </div>
          </q-tab-panel>
        </q-tab-panels>
      </q-card>
    </div>

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
  DxEditing,
  DxPosition,
  DxMasterDetail,
} from "devextreme-vue/data-grid";

import { DxForm, DxItem } from "devextreme-vue/form";

import { DxPopup } from "devextreme-vue/popup";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import Incluir from "../http/incluir_registro";
import carregando from "../components/carregando.vue";
import selecaoData from "../views/selecao-periodo.vue";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";

import MasterDetail from "../views/MasterDetail";

import Lookup from "../http/lookup";

import "whatwg-fetch";

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
var dados_item = [];
var sParametroApi = "";
var sParametroApi_item = "";

const dataGridRef = "dataGrid";

export default {
  data() {
    return {
      dados_tipo_pergunta: [],
      dataset_tipo_pergunta: [],
      load: false,
      //Respostas/////////////////////////////////////
      nm_resposta: "",
      qt_estrela: 4,
      ic_resposta: false,
      qt_alternativa: 0,
      //Respostas/////////////////////////////////////
      linha: "",
      linha_item: "",
      cd_tipo_pergunta: 0,
      cd_questao: 0,
      tipo_pergunta: [],
      cd_avaliacao: 0,
      nm_avaliacao: "",
      ds_avaliacao: "",
      nm_questao: "",
      tituloMenu: "",
      menu: "",
      dt_inicial: "",
      dt_final: "",
      dt_base: "",
      tab: "DADOS",
      columns: [],
      columns_item: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      dataSourceConfigItem: [],
      grid_item: false,
      total: {},
      total_item: {},
      dataGridInstance: null,
      panel: "",
      refreshMode: "reshape",
      taskDetails: "",
      temPanel: false,
      qt_tabsheet: 0,
      tabs: [],
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
      cd_empresa: 0,
      cd_menu: 0,
      cd_cliente: 0,
      cd_api: 0,
      api: 0,
      ds_arquivo: "",
      nm_documento: "",
      ic_tipo_data_menu: "0",
      hoje: "",
      hora: "",
      formData: {},
      items: [],
      qt_registro: 0,
      cd_detalhe: 0,

      dados_lookup: [],
      dataset_lookup: [],
      value_lookup: "",
      label_lookup: "",
      placeholder_lookup: "",
      selecionada_lookup: [],
    };
  },
  computed: {
    dataGrid: function () {
      return this.$refs[dataGridRef].instance;
    },
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;

    this.dados_tipo_pergunta = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5454
    );
    this.dataset_tipo_pergunta = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_tipo_pergunta.dataset))
    );
    var filtro_tipo_pergunta = this.dataset_tipo_pergunta.filter((e) => {
      return e.cd_tipo_pergunta != 2 && e.cd_tipo_pergunta != 3;
    });
    this.dataset_tipo_pergunta = filtro_tipo_pergunta;

    this.dt_inicial = localStorage.dt_inicial;
    this.dt_final = localStorage.dt_final;
    this.dt_base = localStorage.dt_base;

    this.hoje = "";
    this.hora = "";

    if (!this.qt_tempo == 0) {
      this.pollData();
      localStorage.polling = 1;
    }
  },

  async mounted() {
    localStorage.cd_parametro = 0;
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
    DxForm,
    DxPopup,
    DxEditing,
    DxPosition,
    DxItem,
    DxMasterDetail,
    MasterDetail,
    carregando,
    selecaoData,
  },

  methods: {
    onNovo() {
      this.tab = "CADASTRO";
      this.grid_item = false;
      this.cd_avaliacao = 0;
      this.dataSourceConfigItem = [];
      this.nm_avaliacao = "";
      this.ds_avaliacao = "";
      this.limpaTudo();
    },

    async TrocaTab(e) {
      this.grid_item = true;
      try {
        this.load = true;
        await this.carregaDados(true);
        await this.carregaDadosItem(true);
        this.limpaTudo();
        this.load = false;
      } catch {
        this.load = false;
      }
    },

    novaPergunta() {
      this.limpaTudo();
      this.cd_questao = this.dataSourceConfigItem.length + 1;
    },

    limpaTudo() {
      this.cd_questao = 0;
      this.nm_questao = "";
      this.cd_tipo_pergunta = 0;
      this.tipo_pergunta = [];
      this.nm_resposta = "";
    },

    async OnSalvar() {
      if (this.nm_questao == "") {
        notify("Por favor digite a Pergunta!");
        return;
      }
      if (this.tipo_pergunta.cd_tipo_pergunta == undefined) {
        notify("Por favor selecione o Tipo de Pergunta!");
        return;
      }
      if (this.nm_avaliacao.trim() == "") {
        notify("Digite o nome da avaliação!");
        return;
      } else {
        try {
          this.load = true;
          if (this.cd_avaliacao == 0) {
            //Insere
            var gera_formulario = {
              cd_parametro: 6,
              nm_avaliacao: this.nm_avaliacao,
              ds_avaliacao: this.ds_avaliacao,
              nm_questao: this.nm_questao,
              cd_tipo_pergunta: this.cd_tipo_pergunta,
              nm_resposta: this.nm_resposta,
              qt_resultado: this.qt_estrela,
              cd_usuario: localStorage.cd_usuario,
            };
            var resultado_insert = await Incluir.incluirRegistro(
              "598/827",
              gera_formulario
            );
            notify(resultado_insert[0].Msg);
            resultado_insert[0].cd_avaliacao > 0
              ? (this.cd_avaliacao = resultado_insert[0].cd_avaliacao)
              : (this.cd_avaliacao = 0);
            this.tipo_pergunta = "";
            this.cd_tipo_pergunta = 0;
            this.nm_questao = "";
            this.grid_item = true;
            await this.carregaDadosItem(true);
            await this.novaPergunta();
            this.load = false;
            return;
          } else if (this.cd_avaliacao != 0) {
            //Altera
            var altera_formulario = {
              cd_parametro: 7,
              cd_avaliacao: this.cd_avaliacao,
              nm_avaliacao: this.nm_avaliacao.replaceAll(/'/g, "´"),
              ds_avaliacao: this.ds_avaliacao.replaceAll(/'/g, "´"),
              nm_questao: this.nm_questao.replaceAll(/'/g, "´"),
              cd_questao: this.cd_questao,
              cd_tipo_pergunta: this.cd_tipo_pergunta,
              qt_resultado: this.qt_estrela,
              cd_usuario: localStorage.cd_usuario,
            };
            var resultado_alteracao = await Incluir.incluirRegistro(
              "598/827",
              altera_formulario
            );
            notify(resultado_alteracao[0].Msg);
            this.tipo_pergunta = "";
            this.cd_tipo_pergunta = 0;
            this.nm_questao = "";
            this.grid_item = true;
            await this.carregaDadosItem(true);
            await this.novaPergunta();
            this.load = false;
            return;
          }
        } catch {
          this.load = false;
        }
      }
    },

    onTipoPergunta() {
      this.cd_tipo_pergunta = this.tipo_pergunta.cd_tipo_pergunta;
    },

    async showMenu() {
      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_menu = localStorage.cd_menu;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      localStorage.cd_parametro = 0;

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';

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
      this.ic_tipo_data_menu = dados.ic_tipo_data_menu;
      this.cd_detalhe = dados.cd_detalhe;

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

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));

      //TabSheet
      this.tabs = [];
      //

      if (!this.qt_tabsheet == 0) {
        this.tabs = JSON.parse(JSON.parse(JSON.stringify(dados.TabSheet)));
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
    },

    async showMenu_Item() {
      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_menu = localStorage.cd_menu;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      localStorage.cd_parametro = 0;
      //
      dados_item = await Menu.montarMenu(this.cd_empresa, "7395", "727"); //'titulo';

      sParametroApi_item = dados_item.nm_api_parametro;
      //
      if (
        !dados_item.nm_identificacao_api == "" &&
        !dados_item.nm_identificacao_api == this.api
      ) {
        this.api = dados_item.nm_identificacao_api;
      }

      this.qt_tabsheet = dados_item.qt_tabsheet;
      this.ic_filtro_pesquisa = dados_item.ic_filtro_pesquisa;
      this.exportar = false;
      this.arquivo_abrir = false;
      this.ativaPDF = false;
      this.qt_tempo = dados_item.qt_tempo_menu;
      this.ic_tipo_data_menu = dados_item.ic_tipo_data_menu;
      this.cd_detalhe = dados_item.cd_detalhe;

      if (this.ic_tipo_data_menu == "1") {
        this.hoje = " - " + new Date().toLocaleDateString();
      }
      if (this.ic_tipo_data_menu == "2" || this.ic_tipo_data_menu == "3") {
        this.hora = new Date().toLocaleTimeString().substring(0, 5);
      }

      if (dados_item.ic_exportacao == "S") {
        this.exportar = true;
      }

      filename = this.tituloMenu + ".xlsx";
      filenametxt = this.tituloMenu + ".txt";
      filenamedoc = this.tituloMenu + ".docx";
      filenamexml = this.tituloMenu + ".xml";
      filenamepdf = this.tituloMenu + ".pdf";

      this.columns_item = JSON.parse(
        JSON.parse(JSON.stringify(dados_item.coluna))
      );

      this.total_item = JSON.parse(
        JSON.parse(JSON.stringify(dados_item.coluna_total))
      );

      //TabSheet
      this.tabs = [];
      //

      if (!this.qt_tabsheet == 0) {
        this.tabs = JSON.parse(JSON.parse(JSON.stringify(dados_item.TabSheet)));
      }
      //Filtros

      this.filtro = [];

      if (this.ic_filtro_pesquisa == "S") {
        this.filtro = JSON.parse(JSON.parse(JSON.stringify(dados_item.Filtro)));

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
    },

    pollData: function () {
      if (this.qt_tempo > 0) {
        this.polling = setInterval(() => {
          this.carregaDados(true);
        }, this.qt_tempo);
      }
    },

    //
    onFocusedRowChanged: function (e) {
      this.linha = e.row && e.row.data;

      this.taskDetails = this.linha && this.linha.ds_informativo;
      this.ds_arquivo = this.linha && this.linha.ds_arquivo;
      this.nm_documento = this.linha && this.linha.nm_documento;
      this.cd_avaliacao = this.linha.cd_avaliacao;
      this.nm_avaliacao = this.linha.nm_avaliacao;
      this.ds_avaliacao = this.linha.ds_avaliacao;
    },

    onFocusedRowChangedItem: function (e) {
      this.linha_item = e.row && e.row.data;
      this.nm_questao = this.linha_item.nm_questao;
      this.cd_tipo_pergunta = this.linha_item.cd_tipo_pergunta;
      this.cd_questao = this.linha_item.cd_controle;
      localStorage.cd_empresa == 153
        ? (this.qt_estrela = 5)
        : (this.qt_estrela = this.linha_item.qt_resultado);
      this.tipo_pergunta = {
        cd_tipo_pergunta: this.linha_item.cd_tipo_pergunta,
        nm_tipo_pergunta: this.linha_item.nm_tipo_pergunta,
      };
    },

    removed_Item: async function (e) {
      var exclui_questao = {
        cd_parametro: 8,
        cd_avaliacao: e.data.cd_avaliacao,
        cd_questao_resposta: e.data.cd_questao_resposta,
        cd_questao: e.data.cd_questao,
        cd_usuario: localStorage.cd_usuario,
      };
      var resultado_exclui_questao = await Incluir.incluirRegistro(
        "598/827",
        exclui_questao
      );
      await this.carregaDadosItem();
      notify(resultado_exclui_questao[0].Msg);
    },

    removed: async function (e) {
      var exclui_questao = {
        cd_parametro: 9,
        cd_avaliacao: e.data.cd_avaliacao,
        cd_usuario: localStorage.cd_usuario,
      };
      var resultado_exclui_questao = await Incluir.incluirRegistro(
        "598/827",
        exclui_questao
      );
      await this.carregaDados();
      notify(resultado_exclui_questao[0].Msg);
    },

    async carregaDados(carregamenu) {
      if (carregamenu == true) {
        await this.showMenu();
      }

      this.temPanel = true;

      notify(`Aguarde... estamos montando a consulta para você !`);
      if (!this.qt_tabsheet == 0) {
        let sApis = sParametroApi;

        //
        localStorage.cd_tipo_consulta = 0;
        localStorage.cd_parametro = 0;
        localStorage.cd_documento = 0;

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

    async carregaDadosItem(carregamenu) {
      if (carregamenu == true) {
        await this.showMenu_Item();
      }
      this.temPanel = true;

      notify(`Aguarde... estamos montando a consulta para você!`);

      let sApis_item = sParametroApi_item;

      if (!sApis_item == "") {
        localStorage.cd_tipo_consulta = 1;
        localStorage.cd_documento = this.cd_avaliacao;

        this.dataSourceConfigItem = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          this.api,
          sApis_item
        );
      }
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
        workbook.xlsx.writeBuffer().then(function (buffer) {
          saveAs(
            new Blob([buffer], { type: "application/octet-stream" }),
            filename
          );
        });
      });
      e.cancel = true;
    },

    beforeDestroy() {
      clearInterval(this.polling);
    },

    destroyed() {
      this.$destroy();
    },
  },
};
</script>
<style scoped>
#taskDetails {
  line-height: 22px;
  font-size: 14px;
  margin-top: 0;
  margin-bottom: 0;
  padding-left: 10px;
}

.borda-bloco {
  flex: auto;
}
</style>
