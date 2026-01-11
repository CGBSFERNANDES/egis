<template>
  <div>
    <div class="row items-center">  
    <h2 class="content-block">
      {{ tituloMenu }}
      <q-badge align="middle" rounded color="red" :label="qt_registro" />
    </h2>
   <!-- TOGGLE: GRID x CARDS -->
  <q-toggle
    v-model="exibirComoCards"
    color="deep-purple-7"
    checked-icon="view_module"
    unchecked-icon="view_list"
    :label="exibirComoCards ? 'grid' : 'cards'"
    keep-color
  />

    <div v-if="exibirComoCards" class="q-ml-md text-grey-6">
     {{ qtdFiltrados }} de {{ qtdTotal }}
    </div>
    </div>
    <dx-data-grid
      v-if="!exibirComoCards"
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
      @row-dbl-click="onClickAprovar($event)"
      @exporting="onExporting"
      @initialized="saveGridInstance"
      @focused-row-changed="onFocusedRowChanged"
    >
      <DxGroupPanel
        :visible="true"
        empty-panel-text="Colunas para agrupar..."
      />

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
    </dx-data-grid>

     <div
      v-else class="q-mt-lg q-ml-lg"
      >
     
    <div class="q-mb-md filtros-empresas">
    <div class="row q-col-gutter-md q-mt-sm items-center">
      <div class="col-12 col-md-4">
        <q-input
          dense
          outlined
          v-model="filtroTexto"
          placeholder="Buscar empresa..."
          clearable
        />
      </div>
    </div>
  </div>
   
  <div class="cards-wrapper">
  <div
    v-for="empresa in empresasFiltradas"
    :key="empresa.cd_empresa"
    class="empresa-card cursor-pointer"
    @click="selecionarEmpresa(empresa)"
  >
   

  <!-- logo -->

  <div class="text-center q-mb-md">
    <img
      :src="getLogoUrl(empresa)"
      alt="Logo Empresa"
      class="logo-empresa"
    >
  </div>
   <div class="codigo-empresa">
      <!-- nome fantasia -->
      <div class="text-center text-weight-bold text-h6 q-mb-xs">
       {{ empresa.cd_empresa }}
      </div>    
    </div>
    <!-- nome fantasia -->
    <div class="nome-fantasia">
          {{ empresa.nm_fantasia_empresa }}
    </div>

    <!-- razão social -->
    <div class="tdescricao-empresa q-mt-xs">
      {{ empresa.nm_empresa }}<br>   
    </div>

    <!-- cidade - estado -->
    <div class="text-center text-subtitle2">
      {{ empresa.nm_cidade }} - {{ empresa.sg_estado }}
    </div>

    <div class="text-center text-subtitle2">
      {{ empresa.cd_telefone_empresa }} 
    </div>
      
  </div>
  </div>
</div>

    <div class="margin1">
      <q-btn
        rounded
        class="margin1"
        color="orange-9"
        icon="done"
        label="Acessar"
        @click="onClickAprovar($event)"
      />
      <q-btn
        rounded
        flat
        class="margin1"
        color="orange-9"
        icon="close"
        label="Cancelar"
        @click="onClickDeclinar($event)"
      />
    </div>

    <div class="task-info" v-if="temD === true">
      <div class="info">
        <div id="taskSubject">{{ taskSubject }}</div>
        <p id="taskDetails" v-html="taskDetails" />
      </div>
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
} from "devextreme-vue/data-grid";

import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import notify from "devextreme/ui/notify";

import validaUsuario from "../http/validaUsuario";
//import auth from "../auth";

//Busca o Código do Módulo
//import Modulo from '../http/modulo';

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
      filtroTexto: '',
      tituloMenu: "",
      columns: [],
      qt_registro: 0,
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      total: {},
      dataGridInstance: null,
      taskSubject: "Descritivo",
      taskDetails: "",
      temD: false,
      temPanel: false,
      exibirComoCards: true, // ou false, conforme desejar padrão
      data: {},
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
  },

  computed: {
    qtdTotal () {
      return Array.isArray(this.dataSourceConfig) ? this.dataSourceConfig.length : 0
    },

    empresasFiltradas () {
      const lista = Array.isArray(this.dataSourceConfig) ? this.dataSourceConfig : []
      const texto = (this.filtroTexto || '').toLowerCase().trim()
      if (!texto) return lista

      return lista.filter((empresa) => {
        const codigo = String(empresa.cd_empresa || '').toLowerCase()
        const fantasia = String(empresa.nm_fantasia_empresa || '').toLowerCase()
        const razao = String(empresa.nm_empresa || '').toLowerCase()
        const cidade = String(empresa.nm_cidade || '').toLowerCase()
        const uf = String(empresa.sg_estado || '').toLowerCase()
        const tel = String(empresa.cd_telefone_empresa || '').toLowerCase()

        return (
          codigo.includes(texto) ||
          fantasia.includes(texto) ||
          razao.includes(texto) ||
          cidade.includes(texto) ||
          uf.includes(texto) ||
          tel.includes(texto)
        )
      })
    },

    qtdFiltrados () {
      return this.empresasFiltradas.length
    },
  },
 
  methods: {
    onFocusedRowChanged: function (e) {
      this.data = e.row && e.row.data;
    },

    async carregaDados() {
      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      cd_menu = 6542;
      cd_api = 51; //Procedimento 896 -- pr_consulta_usuario_empresa
      api = localStorage.nm_identificacao_api;
      //console.log(api);

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';

      //console.log(dados);

      let sParametroApi = dados.nm_api_parametro;
      //console.log(cd_menu, cd_api);
      localStorage.cd_parametro = 0;
      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      //alert( dados.cd_tipo_consulta);
      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';

      //Gera os Dados para Montagem da Grid
      //exec da procedure
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        api,
        sParametroApi
      );
      console.log('dados da empresa: ', this.dataSourceConfig);
      filename = this.tituloMenu + ".xlsx";
      this.qt_registro = this.dataSourceConfig.length;

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //
    },

    customizeColumns(columns) {
      columns[0].width = 120;
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    async onClickAprovar() {
      notify(`Aguarde... vamos acessar a empresa para você !`);
      //  localStorage.cd_empresa            = localStorage.cd_empresa_selecao;
      localStorage.nm_caminho_logo_empresa =
        this.data && this.data.nm_caminho_logo_empresa;
      localStorage.nm_empresa_selecao =
        this.data && this.data.nm_fantasia_empresa;
      localStorage.cd_empresa_selecao = this.data && this.data.cd_empresa;
      localStorage.nm_ftp_empresa = this.data.nm_ftp_empresa;
      localStorage.nm_banco_empresa = this.data.nm_banco_empresa;
      localStorage.cd_empresa = localStorage.cd_empresa_selecao;
      localStorage.empresa = this.data.nm_empresa;
      localStorage.fantasia = localStorage.nm_empresa_selecao;
      localStorage.nm_novo_logo = localStorage.nm_caminho_logo_empresa;
      localStorage.cd_menu = 0;

      //Atualização do Módulo
      localStorage.cd_cliente = 0;
      localStorage.cd_parametro = 0;

      api = "";
      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';

      api = dados.nm_identificacao_api;

      let sParametroApi = dados.nm_api_parametro;

      dados = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        api,
        sParametroApi
      );

      await validaUsuario.validar(localStorage.login, localStorage.password);

      this.$router.push({ name: "home" });

      //localStorage.nm_modulo = localStorage.nm_modulo_selecao;
    },

     getLogoUrl (empresa) {
    // se o backend já mandar @logo pronto, você pode só: return empresa.logo
    if (empresa.nm_caminho_logo_empresa) {
      return 'https://egisnet.com.br/img/' + empresa.nm_caminho_logo_empresa
    }
    return 'https://egisnet.com.br/img/logo_gbstec_sistema.jpg'
  },
    selecionarEmpresa(empresa) {
      this.data = empresa;
      this.onClickAprovar();
    },

    onClickDeclinar() {
      notify(`Aguarde... vamos cancelar a empresa para você !`);
      //
      this.$router.push({ name: "home" });
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

.cards-wrapper {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  grid-auto-rows: 1fr;
  gap: 10px;                 /* espaçamento ~10px entre os cards */
  margin-right: 20px; 
}

.empresa-card {
  background: #ffffff;                 /* fundo branco */
  border-radius: 24px;
  padding: 24px 32px;
  min-width: 280px;
  max-width: 320px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.16);
  color: #512da8;                      /* deep-purple-7 */
  display: flex;
  flex-direction: column;
  align-items: center;
   height: 100%;              /* <- iguala a altura dentro da linha */
  box-sizing: border-box;
}

.empresa-card:hover {
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.25);
  transform: translateY(-2px);
  transition: all 0.15s ease;
}

/* código da empresa em cima (274 / 282 etc) */
.empresa-card .codigo-empresa {
  font-weight: 700;
  font-size: 18px;
  margin-bottom: 12px;
  color: #e65100;                      /* deep-orange-9 */
}

/* nome fantasia (GUSTAMAIS / MEG...) */
.empresa-card .nome-fantasia {
  font-weight: 700;
  font-size: 18px;
  text-align: center;
  margin-top: 12px;
  margin-bottom: 4px;
  color: #512da8;                      /* deep-purple-7 */
}

/* razão social e cidade/estado/telefone */
.empresa-card .descricao-empresa {
  text-align: center;
  font-size: 13px;
  line-height: 1.4;
  color: #555;
}

/* se quiser destacar telefone, pode usar esta classe no span dele */
.empresa-card .telefone {
  margin-top: 4px;
  color: #e65100;                      /* deep-orange-9 */
}

/* logo */

.logo-empresa {
  max-height: 70px;
  max-width: 200px;
  object-fit: contain;
  /* removemos “contorno” e fundo */
  border-radius: 0;
  padding: 0;
  background: transparent;
  box-shadow: none;
}

</style>
