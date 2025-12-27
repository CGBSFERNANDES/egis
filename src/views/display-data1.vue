<template>
  <div>
    <h2 class="content-block">{{ tituloMenu }}</h2>

    <div class="content-block dx-card responsive-paddings">
      <DxForm
        id="form"
        label-location="top"
        :colCountByScreen="colCountByScreen"
      >
      </DxForm>

      <div class="row">
        <div class="data-base col">
          Data
          <div class="data-base">
            <DxDateBox
              :value="now"
              :show-clear-button="true"
              :use-mask-behavior="false"
              type="date"
              apply-value-mode="useButtons"
              @value-changed="onValueChanged($event)"
            />
          </div>
        </div>

        <div class="col items-end" v-if="cd_modulo == 319">
          <q-btn
            style="float: right"
            round
            color="orange-10"
            icon="print"
            @click="Imprimir()"
          />
        </div>
      </div>

      <div class="button-pesquisa-data">
        <DxButton
          :width="170"
          icon="find"
          text="Pesquisar"
          type="default"
          styling-mode="contained"
          horizontal-alignment="left"
          @click="onClick($event)"
        />
      </div>
      <transition name="slide-fade">
        <div v-if="carregaGrid == true" class="row">
          <q-spinner-facebook class="col margin1" color="orange-9" size="6em" />
          <q-tooltip :offset="[0, 8]">Carregando...</q-tooltip>
        </div>
        <dx-data-grid
          v-else
          id="grid-padrao"
          class="dx-card wide-card-d"
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
          :selectedrow-keys="selectedRowKeys"
          @selection-Changed="PegaLinha"
        >
          <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
          <DxGrouping :auto-expand-all="true" />
          <DxExport :enabled="true" :formats="['pdf', 'xlsx']" />

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
            :visible="true"
            :width="300"
            placeholder="Procurar..."
          />
          <DxFilterPanel :visible="true" />
          <DxColumnFixing :enabled="true" />
          <DxColumnChooser :enabled="true" mode="select" />
        </dx-data-grid>
      </transition>
    </div>
    <!--------------------------------------------------->
    <q-dialog v-if="ic_impressao == true" v-model="ic_impressao">
      <q-card style="width: 300px; padding: 0">
        <div class="row items-center" style="margin: 0.7vw">
          <div class="text-bold text-subtitle2 col items-center">
            {{ tituloPop }}
          </div>

          <div class="col-1">
            <q-btn
              style="float: right"
              flat
              round
              icon="close"
              v-close-popup
              size="sm"
            />
          </div>
        </div>

        <div
          class="row items-center self-center justify-center"
          style="margin: 0.7vw"
        >
          <relatorio
            v-if="ic_impressao == true"
            :cd_relatorioID="this.cd_relatorio"
            :cd_documentoID="this.cd_documento"
            :cd_item_documentoID="this.cd_item_documento"
            :nm_jsonID="[]"
          ></relatorio>
        </div>
      </q-card>
    </q-dialog>
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
import relatorio from "../views/relatorio.vue";

import DxButton from "devextreme-vue/button";
import DxDateBox from "devextreme-vue/date-box";

import { DxForm } from "devextreme-vue/form";
import notify from "devextreme/ui/notify";

import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import formataData from "../http/formataData";

let cd_empresa = 0;
let cd_menu = 0;
let cd_cliente = 0;
let cd_api = 0;
let api = "";

let filename = "DataGrid.xlsx";
let dados = [];

export default {
  data() {
    return {
      now: "",
      tituloMenu: "",
      columns: [],
      ic_impressao: false,
      pageSizes: [10, 20, 50, 100],
      autoNavigateToFocusedRow: true,
      isReady: false,
      cd_item_documento: 0,
      carregaGrid: false,
      dataSourceConfig: [],
      total: {},
      cd_modulo: 0,
      selectedRowKeys: [],
      linha: {},
      cd_relatorio: 0,
      cd_documento: 0,
      tituloPop: "Relatório de Romaneios",
      dataGridInstance: null,
      colCountByScreen: {
        xs: 1,
        sm: 2,
        md: 3,
        lg: 4,
      },
      dataGridRefName: "dataGrid",
    };
  },
  created() {
    //locale(navigator.language);

    //if(this.cd_modulo == )
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    // locale('pt-BR');
  },

  async mounted() {
    this.cd_modulo = localStorage.cd_modulo;
    if (this.cd_modulo == 319) {
      this.cd_relatorio = 10;
    }
    localStorage.dt_base = "";

    let data = new Date(),
      dia = data.getDate().toString(),
      diaF = dia.length == 1 ? "0" + dia : dia,
      mes = (data.getMonth() + 1).toString(), //+1 pois no getMonth Janeiro começa com zero.
      mesF = mes.length == 1 ? "0" + mes : mes,
      anoF = data.getFullYear();

    localStorage.dt_base = mesF + "-" + diaF + "-" + anoF;

    this.carregaDados();
  },

  components: {
    relatorio,
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
    DxButton,
    DxForm,
    DxSearchPanel,
    DxDateBox,
  },

  methods: {
    Imprimir() {
      this.ic_impressao = true;
    },

    onValueChanged(e) {
      this.now = formataData.MesDiaAno(e.value);
      this.carregaDados();
    },

    async carregaDados() {
      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      cd_menu = localStorage.cd_menu;
      cd_api = localStorage.cd_api;
      api = localStorage.nm_identificacao_api;
      localStorage.cd_tipo_consulta = 0;
      if (this.now == "") {
        this.now = new Date();
      }
      this.now = formataData.MesDiaAno(this.now);
      localStorage.dt_base = this.now;
      notify("Aguarde... estamos montando a consulta para você, aguarde !");
      this.carregaGrid = true;
      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';
      let sParametroApi = dados.nm_api_parametro;

      //localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.tituloPop = `Relatório de ${dados.nm_menu_titulo}`;
      //Gera os Dados para Montagem da Grid
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        api,
        sParametroApi
      );
      this.carregaGrid = false;
      filename = this.tituloMenu + ".xlsx";

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      this.columns.map((c) => {
        if (c.ic_botao === "S") {
          c.cellTemplate = (cellElement, cellInfo) => {
            const buttonEdit = document.createElement("button");
            buttonEdit.textContent = c.nm_botao_texto;
            buttonEdit.style.padding = "8px 12px";
            buttonEdit.style.marginRight = "5px";
            buttonEdit.style.border = "none";
            buttonEdit.style.borderRadius = "4px";
            buttonEdit.style.fontSize = "14px";
            buttonEdit.style.cursor = "pointer";
            buttonEdit.style.backgroundColor = "#1976D2";
            buttonEdit.style.color = "white";
            buttonEdit.style.transition =
              "background-color 0.3s ease, transform 0.2s ease";

            // Adicionando efeito de hover
            buttonEdit.onmouseover = () => {
              buttonEdit.style.backgroundColor = "#1565C0"; // Cor mais escura ao passar o mouse
              buttonEdit.style.transform = "scale(1.05)"; // Leve aumento no tamanho
            };
            buttonEdit.onmouseout = () => {
              buttonEdit.style.backgroundColor = "#1976D2"; // Volta à cor original
              buttonEdit.style.transform = "scale(1)"; // Retorna ao tamanho normal
            };
            buttonEdit.onclick = () =>
              this.handleButton({
                data: cellInfo.data,
                ic_procedimento_crud: c.ic_procedimento_crud,
                nm_api_busca: c.nm_api_busca,
              });

            cellElement.appendChild(buttonEdit);
          };
        }
        if (c.dataType === "date") {
          c.calculateCellValue = (row) => {
            if (!row[c.dataField]) return "";
            if (row[c.dataField].length < 10) return row[c.dataField];

            const [datePart] = row[c.dataField].split(" ");
            const [year, month, day] = datePart.split("-");

            return `${day.substring(0, 2)}/${month}/${year}`;
          };
        }
      });
      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //

      //this.FormData.Data =  new Date().toLocaleDateString();
    },

    PegaLinha({ selectedRowsData }) {
      this.linha = selectedRowsData[0];
      this.cd_documento = this.linha.cd_entregador;
    },

    customizeColumns(columns) {
      columns[0].width = 120;
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    onClick(e) {
      const buttonText = e.component.option("text");
      notify(`Aguarde... vamos ${this.capitalize(buttonText)} novamente !`);

      this.carregaDados();
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
  },
};
</script>

<style>
.data-base {
  width: 170px;
  margin: 5px;
  margin-bottom: 15px;
}
.button-pesquisa-data {
  margin: 5px;
  margin-bottom: 15px;

  padding: 0;
}
#grid-padrao {
  max-height: 750px !important;
}
</style>
