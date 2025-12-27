<template class="ativos-bg">
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div>
      <div class="row items-center margin1">
        <transition name="slide-fade">
          <h2 class="col-6">{{ tituloMenu }} {{ ` - ${cd_freezer}` }}</h2>
        </transition>
        <!-- Logo -->
        <div v-if="cd_empresa == 274">
          <img
            src="https://www.egisnet.com.br/img/Logo_gustaoficial-sem-fundo.png"
            alt="Logo Gusta+"
          />
        </div>
        <!-- Logo logo_pimpinella-->
        <div v-if="cd_empresa == 317">
          <img
            src="https://www.egisnet.com.br/img/logo_pimpinella.jpg"
            alt="Logo Pimpinella"
          />
        </div>
      </div>
      <div class="margin1">
        <div class="row margin1">
          <q-input
            class="margin1 umQuartoTela"
            outlined
            v-model="ativo.cd_patrimonio_bem"
            label="Patrimônio"
            disable
            readonly
          />
          <q-input
            class="margin1 umQuartoTela"
            outlined
            v-model="ativo.nm_mascara_bem"
            label="Máscara"
            disable
            readonly
          />
          <q-input
            class="margin1 umQuartoTela"
            outlined
            v-model="ativo.nm_bem"
            label="Bem"
            disable
            readonly
          />
          <q-input
            class="margin1 umQuartoTela"
            outlined
            v-model="ativo.ds_bem"
            label="Descrição"
            disable
            readonly
          />
        </div>
        <div class="row margin1">
          <q-select
            class="umTercoTela margin1"
            outlined
            v-model="marca"
            :options="lookup_dataset_marca"
            label="Marca"
            option-value="cd_marca_produto"
            option-label="nm_marca_produto"
            disable
            readonly
          />
          <q-select
            class="umTercoTela margin1"
            outlined
            v-model="modelo"
            :options="lookup_dataset_modelo"
            label="Modelo"
            option-value="cd_modelo"
            option-label="nm_modelo"
            disable
            readonly
          />
          <q-input
            class="umTercoTela margin1"
            outlined
            v-model="ativo.qt_capacidade_bem"
            label="Cap."
            disable
            readonly
          />
          <q-input
            class="umTercoTela margin1"
            outlined
            v-model="ativo.qt_voltagem_bem"
            label="Volt."
            disable
            readonly
          />
          <q-input
            class="umTercoTela margin1"
            outlined
            v-model="ativo.nm_serie_bem"
            label="Série"
            disable
            readonly
          />
          <q-input
            class="umTercoTela margin1"
            outlined
            v-model="ativo.nm_registro_bem"
            label="Registro"
            disable
            readonly
          />
          <q-input
            class="umTercoTela margin1"
            outlined
            v-model="ativo.nm_fantasia_cliente"
            label="Cliente"
            disable
            readonly
          />
          <q-input
            class="umTercoTela margin1"
            outlined
            v-model="ativo.cd_pedido_compra_bem"
            label="Pedido"
            disable
            readonly
          />
          <q-input
            class="umTercoTela margin1"
            outlined
            v-model="ativo.cd_nota_entrada"
            label="Nota"
            disable
            readonly
          />
        </div>
        <div class="row margin1">
          <q-input
            class="metadeTela margin1"
            outlined
            v-model="text"
            label="Última manutenção"
            disable
            readonly
          />
          <q-input
            class="metadeTela margin1"
            outlined
            v-model="text"
            label="Última visita"
            disable
            readonly
          />
        </div>
        <div class="margin1">
        <q-btn
             class="esquerda"
             icon="description"
             round
             @click="onRelatorio()"
             color="orange-9"
          >
            <q-tooltip> Relatório </q-tooltip>
         </q-btn>
        </div>
        <div>
          <div>
            Para maiores informaçoes baixe o nosso aplicativo Egismob
            <!-- Icone iOS e Android -->
            <div>
              <q-btn
                class="margin1"
                icon="img:/android.jpg"
                round
                color="white"
                size="1.2em"
                @click="
                  AbreLink(
                    'https://play.google.com/store/apps/details?id=com.carlos.c.fernandes.EgisMob&hl=pt_BR',
                  )
                "
              />
              <q-btn
                class="margin1"
                icon="img:/ios.png"
                round
                color="white"
                size="1.2em"
                @click="
                  AbreLink('https://apps.apple.com/nz/app/egismob/id6470312463')
                "
              />
            </div>
          </div>
          <q-btn
            v-if="1 == 2"
            color="primary"
            icon="description"
            label="Pedido de Venda"
            rounded
            size="md"
            class="margin1"
            @click="ic_pedido_venda = true"
          />
          <q-btn
            v-if="1 == 2"
            color="green"
            icon="article"
            label="Ordem de Serviço"
            rounded
            size="md"
            class="margin1"
          />
        </div>
      </div>
    </div>
    <!-- Develop by -->
    <div class="margin1 text-bold">
      Desenvolvido por
      <a href="https://egisnet.com.br/">GBS - Global Business Solution</a>
    </div>
    <!-- pedidoVenda -->
    <!---CARREGANDO----------------------------------->
    <q-dialog v-model="ic_pedido_venda" maximized persistent>
      <q-card class="bg-white text-black">
        <q-bar>
          <q-space />
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-white text-black">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section>
          <pedidoVenda></pedidoVenda>
        </q-card-section>
      </q-card>
    </q-dialog>
    <!------------------------------------------------->
  </div>
</template>

<script>
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

import Lookup from "../http/lookup";
import formataData from "../http/formataData";

import "whatwg-fetch";

import Docxtemplater from "docxtemplater";
import Incluir from "../http/incluir_registro";

import PizZip from "pizzip";
import PizZipUtils from "pizzip/utils/index.js";

function loadFile(url, callback) {
  PizZipUtils.getBinaryContent(url, callback);
}

var filename = "DataGrid.xlsx";
var filenametxt = "Arquivo.txt";
var filenamedoc = "Arquivo.docx";
var filenamexml = "Arquivo.xml";

var dados = [];
var sParametroApi = "";

const dataGridRef = "dataGrid";

export default {
  data() {
    return {
      tituloMenu: "Controle de Ativos",
      cd_freezer: "",
      menu: "",
      dt_inicial: "",
      dt_final: "",
      dt_base: "",
      columns: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      total: {},
      text: "",
      options: [],
      model: "",
      value: "",
      ativo: "",
      dataGridInstance: null,
      ic_pedido_venda: false,
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
      cd_menu: localStorage.cd_menu,
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
      cd_identificacao: "",

      filtro_data: false,
      marca: "",
      lookup_dataset_marca: [],
      modelo: "",
      lookup_dataset_modelo: [],
      dados_lookup: [],
      dataset_lookup: [],
      value_lookup: "",
      label_lookup: "",
      placeholder_lookup: "",
      selecionada_lookup: [],

      periodo: "",
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
    this.cd_freezer = this.$route.params.freezer;
    this.cd_empresa = this.$route.params.empresa;
    // if (this.cd_empresa != 274) {
    //   this.$router.push({ name: "NotFound" });
    // }
    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;
    localStorage.cd_empresa = this.cd_empresa;

    this.dt_inicial = localStorage.dt_inicial;
    this.dt_final = localStorage.dt_final;
    this.dt_base = localStorage.dt_base;
    this.periodoVisible = false;

    this.hoje = "";
    this.hora = "";

    if (this.lookup_dataset_marca.length == 0) {
      let lokup_motivo_marca = await Lookup.montarSelect(this.cd_empresa, 2406);
      this.lookup_dataset_marca = JSON.parse(
        JSON.parse(JSON.stringify(lokup_motivo_marca.dataset)),
      );
    }
    if (this.lookup_dataset_modelo.length == 0) {
      let lokup_motivo_modelo = await Lookup.montarSelect(
        this.cd_empresa,
        5629,
      );
      this.lookup_dataset_modelo = JSON.parse(
        JSON.parse(JSON.stringify(lokup_motivo_modelo.dataset)),
      );
    }

    if (!this.qt_tempo == 0) {
      this.pollData();
      localStorage.polling = 1;
    }
    let json_pesquisa_ativo = {
      cd_parametro: 0,
      cd_ativo: this.cd_freezer,
      cd_usuario: localStorage.cd_usuario,
    };
    [this.ativo] = await Incluir.incluirRegistro(
      "917/1424",
      json_pesquisa_ativo,
    ); //pr_egismob_consulta_bem
    if (this.ativo.Msg) {
      notify(this.ativo.Msg);
    } else {
      [this.marca] = this.lookup_dataset_marca.filter(
        (m) => m.cd_marca_produto == this.ativo.cd_marca_produto,
      );
      [this.modelo] = this.lookup_dataset_modelo.filter(
        (m) => m.cd_modelo == this.ativo.cd_modelo,
      );
    }
  },

  async mounted() {
    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;

    this.carregaDados();
  },

  components: {
    pedidoVenda: () => import("../views/pedido-venda-fabrica.vue"),
  },

  methods: {
    async onRelatorio() {
        try {
          this.load_tela = true;
          let json_relatorio = {
            cd_empresa: localStorage.cd_empresa,
            cd_modulo: localStorage.cd_modulo,
            cd_menu: localStorage.cd_menu,
            cd_relatorio: 182, //Contrato de Comodato
            cd_processo: "",
            cd_item_processo: "",
            cd_documento_form: this.ativo.cd_bem,
            cd_item_documento_form: "0",
            cd_parametro: "0",
            cd_usuario: localStorage.cd_usuario,
          };
          let [relatorio] = await Incluir.incluirRegistro(
            "923/1433",
            json_relatorio,
          ); //pr_egis_relatorio_padrao
          const htmlContent = relatorio.RelatorioHTML; // Armazene o conteúdo HTML retornado
          // Crie um blob com o conteúdo HTML
          const blob = new Blob([htmlContent], { type: "text/html" });
          // Gere uma URL temporária para o blob
          const url = URL.createObjectURL(blob);
          // Abra a URL em uma nova aba
          window.open(url, "_blank");
          // Opcional: liberar o objeto URL depois que não for mais necessário
          URL.revokeObjectURL(url);
          notify("Relatório gerado com sucesso");
          this.load_tela = false;
        } catch (error) {
          this.load_tela = false;
          notify("Não foi possivel gerar o relatório");
        }
    },

    AbreLink(urlOpen) {
      window.open(urlOpen, "_blank");
    },

    popClick() {
      this.popupVisible = true;
    },

    popClickData() {
      if (this.popupData == false) {
        this.popupData = true;
      } else {
        this.popupData = false;
        if (this.qt_tabsheet == 0) {
          this.carregaDados();
        } else {
          this.$refs.componentetabsheet.carregaDados();
        }
      }
    },

    onHiding() {
      this.popupVisible = false; // Handler of the 'hiding' event
    },

    async showMenu() {
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      this.cd_menu_destino = 0;
      this.cd_api_destino = 0;
      localStorage.cd_parametro = 0;

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
      let parametro_valor = JSON.parse(dados.nm_api_parametro_valor);
      Object.keys(parametro_valor).map((e, index) => {
        if (parametro_valor[Object.keys(parametro_valor)[index]]) {
          if (e.startsWith("dt_")) {
            //Verifica as datas e formata
            let novaData = formataData.formataDataSQL(
              parametro_valor[Object.keys(parametro_valor)[index]],
            );
            // eslint-disable-next-line no-useless-escape
            let regexData = /([0-9]{2})\-([0-9]{2})\-([0-9]{4})/;
            regexData.test(novaData)
              ? (localStorage[e] =
                  parametro_valor[Object.keys(parametro_valor)[index]])
              : "";
          } else {
            localStorage[e] =
              parametro_valor[Object.keys(parametro_valor)[index]];
          }
        }
      });

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

      //this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.menu = dados.nm_menu;

      filename = this.tituloMenu + ".xlsx";
      filenametxt = this.tituloMenu + ".txt";
      filenamedoc = this.tituloMenu + ".docx";
      filenamexml = this.tituloMenu + ".xml";

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
        this.filtro = await JSON.parse(
          JSON.parse(JSON.stringify(dados.Filtro)),
        );

        if (!!this.filtro[0].cd_tabela == false) {
          this.dados_lookup = await Lookup.montarSelect(
            this.cd_empresa,
            dados.cd_tabela,
          );
        } else {
          this.dados_lookup = await Lookup.montarSelect(
            this.cd_empresa,
            this.filtro[0].cd_tabela,
          );
        }
        if (!!this.dados_lookup != false) {
          this.dataset_lookup = JSON.parse(
            JSON.parse(JSON.stringify(this.dados_lookup.dataset)),
          );
          this.value_lookup = this.filtro[0].nm_campo_chave_lookup;
          this.label_lookup = this.filtro[0].nm_campo;
          this.placeholder_lookup = this.filtro[0].nm_campo_descricao_lookup;
        }
      }
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
        1000,
      );
      e.preventDefault();
    },

    troca: function() {
      componente.chamaCarrega();
    },

    tabPanelTitleClick: function(e) {
      // this.troca();

      this.selectedIndex = e.itemIndex;

      //if(this.selectedIndex == 0){
      //this.$refs.componentetabsheet.limpaDados();
      //}

      this.cd_menu_destino = this.tabs[this.selectedIndex].cd_menu_composicao;
      this.cd_api_destino = this.tabs[this.selectedIndex].cd_api;
      this.cd_parametro = localStorage.cd_parametro;

      this.cd_tipo_consulta = dados.cd_tipo_consulta;

      this.$refs.componentetabsheet.carregaDados();
    },

    //
    onFocusedRowChanged: function(e) {
      var data = e.row && e.row.data;

      // this.taskSubject = data && data.ds_informativo;
      this.taskDetails = data && data.ds_informativo;
      this.ds_arquivo = data && data.ds_arquivo;
      this.nm_documento = data && data.nm_documento;

      if (!data.ds_informativo == "") {
        this.temD = true;
      }

      //this.focusedRowKey = e.component.option('focusedRowKey');
    },

    async carregaDados() {
      localStorage.cd_identificacao = 0;
      await this.showMenu();

      this.temPanel = true;

      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);
      if (!this.qt_tabsheet == 0) {
        let sApis = sParametroApi;
        if (!sApis == "") {
          try {
            this.dataSourceConfig = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_cliente,
              this.api,
              sApis,
            );
          } catch (error) {
            // eslint-disable-next-line no-console
            console.error(error);
          }

          this.qt_registro = this.dataSourceConfig.length;
          this.formData = this.dataSourceConfig[0];
          this.items = JSON.parse(dados.labelForm);
        }
      }

      if (this.qt_tabsheet == 0) {
        //Gera os Dados para Montagem da Grid
        //exec da procedure

        let sApi = sParametroApi;
        if (!sApi == "") {
          !!this.cd_identificacao == true
            ? (localStorage.cd_identificacao = this.cd_identificacao)
            : "";
          this.dataSourceConfig = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            this.api,
            sApi,
          );
          this.qt_registro = this.dataSourceConfig.length;

          this.formData = this.dataSourceConfig[0];

          this.items = JSON.parse(dados.labelForm);
        }
      }

      try {
        var TemDocumento = this.dataSourceConfig[0].nm_documento_pdf;
        if (TemDocumento != undefined) {
          this.arquivo_abrir = true;
        } else {
          this.arquivo_abrir = false;
        }
      } catch (err){
        // eslint-disable-next-line no-console
        console.error(err)
      }
    },

    async onClick() {
      this.dataSourceConfig = [];
      if (this.selecionada_lookup != null) {
        localStorage.cd_filtro = this.selecionada_lookup[
          this.filtro[0].nm_campo_chave_lookup
        ];
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
          null,
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
          null,
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
      }).then(function() {
        // https://github.com/exceljs/exceljs#writing-xlsx
        workbook.xlsx.writeBuffer().then(function(buffer) {
          saveAs(
            new Blob([buffer], { type: "application/octet-stream" }),
            filename,
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

    renderDoc() {
      //loadFile("http://egisnet.com.br/template/template_GBS.docx", function(
      loadFile("/Template_GBS.docx", function(
        //loadFile("https://docxtemplater.com/tag-example.docx", function(
        error,
        content,
      ) {
        if (error) {
          alert("não encontrei o template.docx");
          throw error;
        }
        var zip = new PizZip(content);
        var doc = new Docxtemplater(zip);

        doc.setData(
          dados,

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
          // eslint-disable-next-line no-console
          console.error(error)
        }
        var out = doc.getZip().generate({
          type: "blob",
          mimeType:
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        });
        //Output the document using Data-URI
        saveAs(out, filenamedoc);
      });
    },
  },
};
</script>
<style>
@import url("../views/views.css");
.ativos-bg {
  background: #fff !important;
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
.margin1 {
  margin: 0.5vh 0.5vw;
}
.slide-fade-enter-active {
  transition: all 0.3s ease;
}
.slide-fade-leave-active {
  transition: all 0.4s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter, .slide-fade-leave-to
/* .slide-fade-leave-active below version 2.1.8 */ {
  transform: translateX(10px);
  opacity: 0;
}
</style>
