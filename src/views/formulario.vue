<template>
  <div>
    <h2>{{ this.tituloMenu }}</h2>
    <q-stepper v-model="step" vertical color="primary" animated>
      <q-step
        :name="1"
        title="Ordem de Serviço (OS)"
        icon="folder"
        :done="step > 1"
      >
        <div class="grid">
          <grid :cd_menuID="6595" :cd_apiID="131" ref="gridPrincipal" />
        </div>
        <q-stepper-navigation>
          <DxButton
            class="botoes"
            :width="120"
            text="Próximo"
            type="normal"
            styling-mode="outlined"
            @click="TrocaInformacoes()"
          />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="2"
        title="Lista de Materiais"
        :caption="'Ordem de Serviço (OS) ' + this.ordem_servico"
        icon="list"
        :done="step > 2"
      >
        <div class="grid">
          <grid
            :cd_menuID="7092"
            :cd_apiID="491"
            :cd_parametroID="1"
            :cd_identificacaoID="this.ordem_servico"
            :qt_apontamentoID="0"
            :cd_processoID="0"
          />
        </div>

        <div class="div_material row items-start">
          <ul>
            <li v-for="x in parseInt(dados.length)" v-bind:key="x">
              <div class="col">
                <DxTextBox
                  class="col"
                  :disabled="true"
                  width="250px"
                  styling-mode="filled"
                  :value="dados[x - 1].nm_servico_produto_item"
                  :name="'qt1' + x"
                  :placeholder="'Item'"
                />
              </div>
              <div class="col">
                <DxTextBox
                  class=""
                  width="100px"
                  styling-mode="filled"
                  :value="dados[x - 1].qt_item_ordem_servico"
                  :name="'qt2' + x"
                  :placeholder="'Qtd'"
                />
              </div>
              <q-btn
                @click="deletarItem(x)"
                class="botao_add"
                flat
                round
                color="orange"
                icon="delete"
              />
            </li>
          </ul>
        </div>
        <div class="div_cadastro_cliente q-gutter-md row items-start">
          <q-input
            class="input_cliente"
            :loading="loadingState"
            @blur="consultaProduto()"
            v-model="Produto"
            :rules="[(val) => !!val || 'Nome do Produto']"
            label="Produto"
          />
          <q-input
            class="input_cliente"
            :loading="loadingState"
            type="number"
            v-model="Qtd"
            label="Qtd"
          />
          <q-input
            class="input_cliente"
            :loading="loadingState"
            v-model="Descricao"
            label="Descrição"
            readonly
          />
          <q-input
            class="input_cliente"
            :loading="loadingState"
            v-model="UnidadeMedida"
            label="Unidade de Medida"
            readonly
          />

          <q-btn
            @click="gravar()"
            class="botao_add"
            flat
            round
            color="orange"
            icon="check"
          />
          <q-btn
            @click="add()"
            class="botao_add"
            flat
            round
            color="orange"
            icon="add"
          />
        </div>

        <div
          v-if="GravarProdutoInexistente == true"
          class="q-pa-md q-gutter-sm"
        >
          <q-dialog
            v-model="GravarProdutoInexistente"
            persistent
            :maximized="maximizedToggle"
            transition-show="slide-up"
            transition-hide="slide-down"
          >
            <q-card class="bg-primary text-white">
              <q-bar>
                <q-space />

                <q-btn dense flat icon="close" v-close-popup>
                  <q-tooltip content-class="bg-white text-primary"
                    >Fechar</q-tooltip
                  >
                </q-btn>
              </q-bar>

              <q-card-section>
                <div class="text-h6">ATENÇÃO...</div>
              </q-card-section>

              <q-card-section class="q-pt-none">
                O produto digitado não existe
              </q-card-section>

              <q-card-section>
                <grid :cd_menuID="7104" :cd_apiID="502" :cd_parametroID="0" />
              </q-card-section>
            </q-card>
          </q-dialog>
        </div>

        <div v-if="AtivaPopUp == true" class="q-pa-md q-gutter-sm">
          <q-dialog
            v-model="AtivaPopUp"
            persistent
            :maximized="maximizedToggle"
            transition-show="slide-up"
            transition-hide="slide-down"
          >
            <q-card class="bg-primary text-white">
              <q-bar>
                <q-space />

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
                    >Minimizar</q-tooltip
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
                    >Maximizar</q-tooltip
                  >
                </q-btn>
                <q-btn dense flat icon="close" v-close-popup>
                  <q-tooltip content-class="bg-white text-primary"
                    >Fechar</q-tooltip
                  >
                </q-btn>
              </q-bar>

              <q-card-section>
                <div class="text-h6">ATENÇÃO...</div>
              </q-card-section>

              <q-card-section class="q-pt-none">
                Código do Produto Inválido
              </q-card-section>

              <q-card-section>
                <grid :cd_menuID="7104" :cd_apiID="502" :cd_parametroID="0" />
              </q-card-section>
            </q-card>
          </q-dialog>
        </div>

        <q-stepper-navigation>
          <DxButton
            class="botoes"
            :width="120"
            text="Próximo"
            type="normal"
            styling-mode="outlined"
            @click="ListaMateriais()"
          />

          <DxButton
            class="botoes-voltar"
            :width="120"
            text="Voltar"
            type="normal"
            styling-mode="text"
            @click="step = 1"
          />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="3"
        title="Fechamento"
        :caption="'Ordem de Serviço (OS) ' + this.ordem_servico"
        icon="check"
      >
        <grid
          :cd_menuID="7092"
          :cd_apiID="491"
          :cd_parametroID="1"
          :cd_identificacaoID="this.ordem_servico"
          :qt_apontamentoID="0"
          :cd_processoID="0"
        />

        <div class="line1">
          <q-input
            class="div_observacoes"
            v-model="observacoes"
            label="Observações"
          />
          <q-input class="div_datas" v-model="dt_base" label="Data " />
        </div>
        <div class="row">
          <q-input
            class="col div_nome"
            v-model="nm_fantasia_cliente"
            label="Nome do Responsável "
          />
          <q-input class="col" v-model="Documento" label="Documento " />
        </div>
        <div class="Assinatura">
          <label>Assinatura</label>
        </div>
        <div style="margin-left:15px">
          <canvas
            ref="canvas"
            id="drawing-pad"
            width="650"
            height="150"
          ></canvas>
        </div>
        <div class="buttons-ass">
          <DxButton
            class="buttonrefaz"
            id="gerarButton"
            icon="refresh"
            styling-mode="contained"
            horizontal-alignment="left"
            type="default"
            text="Refazer"
            :visible="true"
            @click="resetCanvas"
          />
          <DxButton
            id="gerarButton"
            icon="save"
            styling-mode="contained"
            horizontal-alignment="left"
            type="default"
            text="Salvar"
            :visible="true"
          />
          <img :visible="false" ref="img" src="" alt="" />
        </div>

        <q-stepper-navigation>
          <DxButton
            class="botoes"
            :width="120"
            text="Finalizar"
            type="normal"
            styling-mode="outlined"
            @click="FecharOS()"
          />

          <DxButton
            class="botoes-voltar"
            :width="120"
            text="Voltar"
            type="normal"
            styling-mode="text"
            @click="step = 2"
          />
        </q-stepper-navigation>
      </q-step>
    </q-stepper>
  </div>
</template>

<script>
import { DxForm, DxItem } from "devextreme-vue/form";

import DxButton from "devextreme-vue/button";
import DxTabPanel from "devextreme-vue/tab-panel";
import { DxPopup } from "devextreme-vue/popup";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages, parseNumber } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import DxTextBox from "devextreme-vue/text-box";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import componente from "../views/display-componente";
import grid from "../views/grid";
import MasterDetail from "../views/MasterDetail";
import pesquisa from "../views/pesquisa";
import "whatwg-fetch";
import Docxtemplater from "docxtemplater";
import PizZip from "pizzip";
import PizZipUtils from "pizzip/utils/index.js";

function loadFile(url, callback) {
  PizZipUtils.getBinaryContent(url, callback);
}

var filename = "DataGrid.xlsx";
var filenametxt = "Arquivo.txt";
var filenamedoc = "Arquivo.docx";
var filenamexml = "Arquivo.xml";

//var filenamepdf = 'DataGrid.pdf';

var sParametroApi = "";

const dataGridRef = "dataGrid";

export default {
  data() {
    return {
      x: 0,
      y: 0,
      apontamento: 0,
      processo: "",
      step: 1,
      ordem_servico: 0,
      Produto: "",
      Descricao: "",
      UnidadeMedida: "",
      loadingState: false,
      Qtd: 0,
      dados: [],
      dadosLista: [],
      observacoes: "",
      maximizedToggle: "",
      tituloMenu: "",
      menu: "",
      dt_inicial: "",
      dt_final: "",
      dt_base: "",
      nm_fantasia_cliente: "",
      Documento: "",
      columns: [],
      dataSourceConfig: [],
      total: {},
      taskDetails: "",
      temD: false,
      qt_tabsheet: 0,
      tabs: [],
      selectedIndex: 0,
      cd_menu_destino: 0,
      cd_api_destino: 0,
      cd_tipo_consulta: 0,
      ic_filtro_pesquisa: "N",
      qt_tempo: 0,
      filtro: [],
      polling: null,
      exportar: false,
      cd_empresa: 0,
      cd_menu: 0,
      cd_cliente: 0,
      cd_api: 0,
      api: 0,
      ds_arquivo: "",
      ds_menu_descritivo: "",
      popupVisible: false,
      ic_form_menu: "N",
      ic_tipo_data_menu: "0",
      hoje: "",
      hora: "",
      formData: {},
      items: [],
      cd_tipo_email: 0,
      qt_registro: 0,
      cd_detalhe: 0,
      cd_menu_detalhe: 0,
      canvas: null,
      context: null,
      isDrawing: false,
      startX: 0,
      startY: 0,
      points: [],
      AtivaPopUp: false,
      GravarProdutoInexistente: false,
      cd_api_detalhe: 0,
    };
  },
  computed: {
    dataGrid: function() {
      return this.$refs[dataGridRef].instance;
    },
  },

  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    // locale('pt-BR');
    //this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();
    //this.dt_final   = new Date(localStorage.dt_final).toLocaleDateString();

    this.dt_inicial = localStorage.dt_inicial;
    this.dt_final = localStorage.dt_final;
    this.dt_base = localStorage.dt_base;
    this.hoje = "";
    this.hora = "";

    //localStorage.cd_identificacao = 0;
    //this.showMenu();
    //await this.showMenu();

    if (!this.qt_tempo == 0) {
      this.pollData();
      localStorage.polling = 1;
    }
    this.showMenu();
    await this.carregaDados();
  },

  async mounted() {
    localStorage.qt_apontamento = 0;
    localStorage.cd_processo = 0;
    localStorage.nm_fantasia_produto = "null";
    this.dados = [];
    var vm = this;
    vm.canvas = vm.$refs.canvas;
    vm.context = vm.canvas.getContext("2d");
    vm.canvas.addEventListener("mousedown", vm.mousedown);
    vm.canvas.addEventListener("mousemove", vm.mousemove);
    document.addEventListener("mouseup", vm.mouseup);
  },

  components: {
    DxTabPanel,
    componente,
    DxForm,
    DxButton,
    DxPopup,
    DxItem,
    MasterDetail,
    grid,
    pesquisa,
    DxTextBox,
  },

  methods: {
    mousedown(e) {
      var vm = this;
      var rect = vm.canvas.getBoundingClientRect();
      let x = e.clientX - rect.left;
      var y = e.clientY - rect.top;

      vm.isDrawing = true;
      vm.startX = x;
      vm.startY = y;
      vm.points.push({
        x: x,
        y: y,
      });
    },

    mousemove(e) {
      var vm = this;
      var rect = vm.canvas.getBoundingClientRect();
      let x = e.clientX - rect.left;
      var y = e.clientY - rect.top;

      if (vm.isDrawing) {
        vm.context.beginPath();
        vm.context.moveTo(vm.startX, vm.startY);
        vm.context.lineTo(x, y);
        vm.context.lineWidth = 1;
        vm.context.lineCap = "round";
        vm.context.strokeStyle = "rgba(0,0,0,1)";
        vm.context.stroke();

        vm.startX = x;
        vm.startY = y;

        vm.points.push({
          x: x,
          y: y,
        });
      }
    },

    mouseup(e) {
      var vm = this;
      vm.isDrawing = false;
      if (vm.points.length > 0) {
        localStorage["points"] = JSON.stringify(vm.points);
      }
    },

    resetCanvas() {
      var vm = this;
      vm.canvas.width = vm.canvas.width;
      vm.points.length = 0; //reseta os pontos do array
    },

    async TrocaInformacoes() {
      localStorage.cd_parametro = 1;
      this.ordem_servico = grid.Selecionada().codigo_os;
      localStorage.cd_identificacao = this.ordem_servico;
      localStorage.qt_apontamento = 0;
      localStorage.cd_processo = 0;
      localStorage.nm_fantasia_produto = "null";
      let api = "491/694";
      let paramAPI =
        "/${cd_empresa}/${cd_parametro}/${cd_usuario}/${nm_fantasia_produto}/${cd_identificacao}/${qt_apontamento}/${cd_processo}/";
      this.dadosLista = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        paramAPI
      );
      this.step = 2;
    },

    async ListaMateriais() {
      //this.ordem_servico = grid.Selecionada().codigo_os
      //localStorage.cd_identificacao = this.ordem_servico
      if (this.dados.length > 0) {
        for (this.x = 0; this.x < this.dados.length; this.x++) {
          this.processo = document.getElementsByName("qt1" + (this.x + 1))[
            this.y
          ].value;
          this.apontamento = document.getElementsByName("qt2" + (this.x + 1))[
            this.y
          ].value;
          //this.ordem_servico               = grid.Selecionada().codigo_os

          localStorage.cd_parametro = 3;
          localStorage.cd_identificacao = this.ordem_servico;
          localStorage.nm_fantasia_produto = this.dados[
            this.x
          ].cd_servico_produto;
          localStorage.qt_apontamento = this.apontamento;
          localStorage.cd_processo = 0;

          let api = "491/694";
          let paramAPI =
            "/${cd_empresa}/${cd_parametro}/${cd_usuario}/${nm_fantasia_produto}/${cd_identificacao}/${qt_apontamento}/${cd_processo}/";
          this.dadosLista = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            api,
            paramAPI
          );
          notify(this.dados[0].Msg);
        }
      } else {
        this.step = 3;
      }

      this.step = 3;
    },

    add() {
      this.Produto = "";
      this.Descricao = "";
      this.UnidadeMedida = "";
      this.Qtd = 0;
    },

    deletarItem(x) {
      this.dados.splice(x - 1, 1);
    },

    async consultaProduto() {
      this.loadingState = true;
      //this.ordem_servico               = grid.Selecionada().codigo_os
      localStorage.cd_parametro = 2;
      localStorage.cd_identificacao = this.ordem_servico;
      localStorage.nm_fantasia_produto = this.Produto.trim();
      localStorage.qt_apontamento = 0;
      localStorage.cd_processo = 0;

      if (localStorage.nm_fantasia_produto == "") {
        localStorage.nm_fantasia_produto = "0";
      }

      let api = "491/694";
      let paramAPI =
        "/${cd_empresa}/${cd_parametro}/${cd_usuario}/${nm_fantasia_produto}/${cd_identificacao}/${qt_apontamento}/${cd_processo}/";
      this.dadosLista = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        paramAPI
      );
      this.Descricao = this.dadosLista[0].nm_produto;
      this.UnidadeMedida = this.dadosLista[0].nm_unidade_medida;
      if (this.Descricao == undefined) {
        this.AtivaPopUp = true;
      }
      this.loadingState = false;
    },

    gravar() {
      let itemDaOS = this.dados.length;
      if (this.Descricao == undefined || this.Produto.trim() == "") {
        this.GravarProdutoInexistente = true;
      } else {
        this.dados[itemDaOS] = {
          cd_ordem_servico: this.ordem_servico,
          cd_usuario: localStorage.cd_usuario,
          cd_item_ordem_servico: itemDaOS + 1,
          ic_item_ordem_Servico: "P",
          cd_servico_produto: this.Produto,
          nm_servico_produto_item: this.Descricao,
          qt_item_ordem_servico: this.Qtd,
        };
      }

      this.Produto = "";
      this.Descricao = "";
      this.UnidadeMedida = "";
      this.Qtd = 0;
    },

    async FecharOS() {
      //this.ordem_servico               = grid.Selecionada().codigo_os
      localStorage.cd_parametro = 4;
      localStorage.cd_identificacao = this.ordem_servico;
      localStorage.nm_fantasia_produto = this.observacoes;
      localStorage.qt_apontamento = 0;
      localStorage.cd_processo = 0;

      let api = "491/694";
      let paramAPI =
        "/${cd_empresa}/${cd_parametro}/${cd_usuario}/${nm_fantasia_produto}/${cd_identificacao}/${qt_apontamento}/${cd_processo}/";
      this.dadosLista = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        paramAPI
      );
      this.step = 1;
      this.ordem_servico = "";
    },

    async showMenu() {
      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_menu = localStorage.cd_menu;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      this.cd_menu_destino = 0;
      this.cd_api_destino = 0;
      this.cd_parametro = localStorage.cd_parametro;
      var data = new Date(localStorage.dt_inicial);

      var dia = data.getDate().toString();
      var mes = (data.getMonth() + 1).toString();
      var anoI = data.getFullYear();

      var dataF = new Date(localStorage.dt_final);
      var diaF = dataF.getDate().toString();
      var mesF = (dataF.getMonth() + 1).toString();
      var anoF = dataF.getFullYear();

      localStorage.dt_inicial = mes + "-" + dia + "-" + anoI;
      localStorage.dt_final = mesF + "-" + diaF + "-" + anoF;

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
      this.qt_tempo = dados.qt_tempo_menu;
      this.ds_menu_descritivo = dados.ds_menu_descritivo;
      this.ic_form_menu = dados.ic_form_menu;
      this.ic_tipo_data_menu = dados.ic_tipo_data_menu;
      this.cd_tipo_email = dados.cd_tipo_email;
      this.cd_detalhe = dados.cd_detalhe;
      this.cd_menu_detalhe = dados.cd_menu_detalhe;
      this.cd_api_detalhe = dados.cd_api_detalhe;

      if (this.ic_tipo_data_menu == "1") {
        this.hoje = " - " + new Date().toLocaleDateString();
      }
      if (this.ic_tipo_data_menu == "2" || this.ic_tipo_data_menu == "3") {
        this.hora = new Date().toLocaleTimeString().substring(0, 5);
      }
      //alert(this.ds_menu_descritivo);

      if (dados.ic_exportacao == "S") {
        this.exportar = true;
      }

      localStorage.cd_tipo_consulta = 0;

      if (!dados.cd_tipo_consulta == 0) {
        dados.cd_tipo_consulta;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.menu = dados.nm_menu;

      filename = this.tituloMenu + ".xlsx";
      filenametxt = this.tituloMenu + ".txt";
      filenamedoc = this.tituloMenu + ".docx";
      filenamexml = this.tituloMenu + ".xml";
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
      }

      //trocar para dados.laberFormFiltro
      //
    },

    pollData: function() {
      if (this.qt_tempo > 0) {
        this.polling = setInterval(() => {
          this.carregaDados();
        }, this.qt_tempo);
      }
    },

    handleSubmit: function(e) {
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

    troca: function() {
      componente.chamaCarrega();
    },

    tabPanelTitleClick: function(e) {
      // ...
      //alert(e);
      this.troca();
      this.selectedIndex = e.itemIndex;

      //alert(e.itemIndex);

      //alert(this.tabs[this.selectedIndex].cd_menu_composicao);
      //alert(this.tabs[this.selectedIndex].cd_api);

      this.cd_menu_destino = this.tabs[this.selectedIndex].cd_menu_composicao;
      this.cd_api_destino = this.tabs[this.selectedIndex].cd_api;
      this.cd_parametro = localStorage.cd_parametro;
      this.cd_tipo_consulta = dados.cd_tipo_consulta;
      //this.carregaDados();
    },

    //
    onFocusedRowChanged: function(e) {
      var data = e.row && e.row.data;

      this.taskDetails = data && data.ds_informativo;
      this.ds_arquivo = data && data.ds_arquivo;
      //alert(this.taskDetais);

      if (!data.ds_informativo == "") {
        this.temD = true;
      }
    },

    async carregaDados() {
      await this.showMenu();


      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);
      if (!this.qt_tabsheet == 0) {
        let sApis = sParametroApi;
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

          this.nm_fantasia_cliente = this.dataSourceConfig[0].nm_fantasia_cliente;
          this.Documento = this.dataSourceConfig[0].CNPJ;
        }
      }
      if (this.qt_tabsheet == 0) {
        //Gera os Dados para Montagem da Grid
        //exec da procedure

        let sApi = sParametroApi;
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
    },
  },
};
</script>
<style scoped>
.input_cliente {
  width: 18%;
  margin: 0 5px 0 0;
}

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

.div_observacoes {
  width: 80%;
  display: inline-block;
  margin-right: 40px;
}

.Assinatura {
  font-weight: bold;
  font-size: 16px;
  margin-left: 15px;
  margin-bottom: 5px;
}
canvas {
  border: 1px solid black;
  cursor: crosshair;
}

.div_material {
  width: 100%;
  margin: 10px;
}

.div_datas {
  text-align: right;
  width: max-content;
  display: inline-block;
}
.div_nome {
  margin-right: 40px;
  display: inline-block;
}
.row {
  margin: 0px 5px 5px 5px;
}
.buttons-ass {
  margin-left: 15px;
  margin-top: 10px;
}
.buttonrefaz {
  margin-right: 10px;
}
.botoes {
  background-color: #1976d2;
  color: white;
}
.botoes :hover {
  background-color: #3988d6;
}

.botoes-voltar {
  color: #1976d2;
}
.botoes-voltar :hover {
  transform-style: "text";
}
</style>
