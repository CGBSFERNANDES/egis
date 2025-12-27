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
          <q-tab icon="edit" name="CONSULTA" label="Consulta"></q-tab>
        </q-tabs>

        <q-separator></q-separator>

        <q-tab-panels v-model="tab" animated>
          <q-tab-panel name="DADOS">
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
              @row-dbl-click="DBClick($event.data)"
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
                :allow-deleting="false"
                mode="batch"
              >
                <DxPopup :show-title="true" title="menu">
                  <DxPosition my="top" at="top" of="window" />
                </DxPopup>
                <DxForm :form-data="formData" :items="items">
                  <DxItem :col-count="2" :col-span="2" item-type="group" />
                </DxForm>
              </DxEditing>
            </dx-data-grid>
          </q-tab-panel>
          <q-tab-panel name="CONSULTA">
            <!--<div style="display:flex; justify-content:right; align-items:right;">
                              <q-btn
                              round
                              color="primary"
                              icon="print"
                              text-color="white"
                              @click="popup_impressao"                            
                              >
                                <q-tooltip class="bg-indigo" :offset="[10, 10]" transition-show="flip-right" transition-hide="flip-left" anchor="center left" self="center right">
                                      <strong>Baixar Formulário</strong>
                                </q-tooltip>
                              </q-btn>
                    </div>-->

            <div id="form">
              <div class="margin1 borda-bloco shadow-2">
                <div class="row">
                  <q-field class="margin1 col" label="Candidato" stack-label>
                    <template v-slot:control>
                      <div class="self-center full-width no-outline text-bold">
                        {{ dataSourceConfigItem[0].nm_candidato }}
                      </div>
                    </template>
                  </q-field>

                  <q-field class="margin1 col" label="E-mail" stack-label>
                    <template v-slot:control>
                      <div class="self-center full-width no-outline text-bold">
                        {{ dataSourceConfigItem[0].nm_email_candidato }}
                      </div>
                    </template>
                  </q-field>

                  <q-field class="margin1 col" label="Formulário" stack-label>
                    <template v-slot:control>
                      <div class="self-center full-width no-outline text-bold">
                        {{ dataSourceConfigItem[0].nm_avaliacao }}
                      </div>
                    </template>
                  </q-field>
                </div>

                <div class="row">
                  <q-field class="margin1 col" label="Cliente" stack-label>
                    <template v-slot:control>
                      <div class="self-center full-width no-outline text-bold">
                        {{ dataSourceConfigItem[0].nm_fantasia_cliente }}
                      </div>
                    </template>
                  </q-field>

                  <q-field class="margin1 col" label="Cargo" stack-label>
                    <template v-slot:control>
                      <div class="self-center full-width no-outline text-bold">
                        {{ dataSourceConfigItem[0].nm_cargo_funcionario }}
                      </div>
                    </template>
                  </q-field>
                </div>
              </div>

              <div v-for="(n, index) in vaga_separada" :key="index">
                <q-expansion-item
                  class="margin1 shadow-1 overflow-hidden"
                  style="border-radius: 30px"
                  header-class="bg-orange text-white"
                  expand-icon-class="text-white"
                  icon="task"
                  default-opened
                  :label="`${n[index].nm_avaliacao} | ${n[index].nm_fantasia_cliente}`"
                >
                  <div
                    v-for="(v, i) in n"
                    :key="i"
                    class="margin1 borda-bloco shadow-2"
                    color="orange"
                  >
                    <q-badge class="margin1" color="orange">
                      {{ i + 1 }}
                    </q-badge>
                    <q-field class="margin1">
                      <template v-slot:control>
                        <div
                          class="self-center full-width no-outline text-bold"
                          :tabindex="v"
                        >
                          {{ v.nm_questao }}
                        </div>
                      </template>
                    </q-field>
                    <q-input
                      v-if="v.cd_tipo_pergunta == 1"
                      class="margin1"
                      v-model="v.nm_resultado_resposta"
                      label="Resposta"
                      outlined
                      readonly
                    />
                    <div v-if="v.cd_tipo_pergunta == 4" class="margin1">
                      {{ "Não"
                      }}<q-toggle
                        class="margin1"
                        v-model="v.nm_resultado_resposta"
                        :false-value="'Não'"
                        :true-value="'Sim'"
                        color="orange-9"
                        disable
                      />{{ "Sim" }}
                    </div>
                    <q-rating
                      v-if="v.cd_tipo_pergunta == 6"
                      class="margin1"
                      v-model="v.nm_resultado_resposta"
                      size="2em"
                      max="4"
                      color="orange-9"
                      readonly
                    />
                  </div>
                </q-expansion-item>
              </div>
            </div>
            <br />
          </q-tab-panel>
        </q-tab-panels>
      </q-card>
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

import funcao from "../http/funcoes-padroes";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";

import Lookup from "../http/lookup";

import "whatwg-fetch";

import DxSelectBox from "devextreme-vue/select-box";

DxSelectBox == true;

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
      vaga_separada: [],
      //Respostas/////////////////////////////////////
      nm_resposta: "",
      qt_estrela: 4,
      ic_resposta: false,
      qt_alternativa: 0,
      nm_alternativa: "",
      json_alternativas: [],
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
      tituloData: "Seleção de Perí­odo",
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
      exportar: false,
      arquivo_abrir: false,
      ativaPDF: false,
      cd_empresa: 0,
      cd_menu: 0,
      cd_cliente: 0,
      cd_api: 0,
      api: 0,
      nm_documento: "",
      ic_tipo_data_menu: "0",
      hoje: "",
      hora: "",
      formData: {},
      items: [],
      qt_registro: 0,
      cd_detalhe: 0,
      cd_candidato: 0,
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
  },

  async mounted() {
    localStorage.cd_parametro = 0;
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
  },

  methods: {
    async TrocaTab(e) {
      this.grid_item = true;
      if (e == "DADOS") {
        await this.carregaDados(true);
      } else {
        await this.carregaDadosItem(true);
      }
      this.cd_avaliacao = this.dataSourceConfigItem[0].cd_avaliacao;
      this.nm_avaliacao = this.dataSourceConfigItem[0].nm_avaliacao;
      this.ds_avaliacao = this.dataSourceConfigItem[0].ds_avaliacao;
    },

    Soma() {
      this.qt_alternativa = this.qt_alternativa + 1;
    },

    Subtrai() {
      this.qt_alternativa = this.qt_alternativa - 1;
    },

    onTipoPergunta() {
      this.cd_tipo_pergunta = this.tipo_pergunta.cd_tipo_pergunta;
    },

    async popup_impressao() {
      let pegaHTML = document.getElementById("form");
      let configuracoes = {
        cd_parametro: 0,
        cd_documento: this.cd_candidato,
        cd_item_documento: 0,
        cd_relatorio: 14,
        abre_baixa: "A",
      };
      await funcao.Export2PDF(pegaHTML, configuracoes);
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
      dados_item = await Menu.montarMenu(
        this.cd_empresa,
        this.cd_menu,
        this.cd_api
      ); //'titulo';
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

    //
    onFocusedRowChanged: function (e) {
      this.linha = e.row && e.row.data;
      this.taskDetails = this.linha && this.linha.ds_informativo;
      this.nm_documento = this.linha && this.linha.nm_documento;
      this.cd_avaliacao = this.linha.cd_avaliacao;
      this.cd_candidato = this.linha.cd_candidato;
    },

    onFocusedRowChangedItem: function (e) {
      this.linha_item = e.row && e.row.data;
      this.nm_questao = this.linha_item.nm_questao;
      this.cd_tipo_pergunta = this.linha_item.cd_tipo_pergunta;
      this.cd_questao = this.linha_item.cd_questao;
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
      } catch {
        notify("Não possui documento!");
      }
    },

    async carregaDadosItem(carregamenu) {
      if (carregamenu == true) {
        await this.showMenu_Item();
      }

      this.temPanel = true;

      notify(`Aguarde... estamos montando a consulta para você!`);

      let sApis_item = sParametroApi_item;
      localStorage.cd_tipo_consulta = this.cd_candidato;
      if (!sApis_item == "") {
        this.dataSourceConfigItem = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          this.api,
          sApis_item
        );
      }
      ////Separa as vagas
      let vagas_diferentes = [];
      this.vaga_separada = [];
      this.dataSourceConfigItem.map((d) => {
        if (!vagas_diferentes.includes(d.cd_avaliacao)) {
          vagas_diferentes.push(d.cd_avaliacao);
        }
      });
      vagas_diferentes.forEach((e) => {
        let cada_vaga = this.dataSourceConfigItem.filter(
          (w) => w.cd_avaliacao == e
        );
        this.vaga_separada.push(cada_vaga);
      });
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    async DBClick() {
      this.tab = "CONSULTA";
      await this.carregaDadosItem(true);
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
