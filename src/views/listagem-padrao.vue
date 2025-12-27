<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <h2 v-if="ic_mostra_titulo" class="content-block">
      {{ tituloMenu }}
      <q-badge
        v-if="qt_registro > 0"
        align="middle"
        rounded
        color="red"
        :label="qt_registro"
      />
    </h2>

    <div>
      <div v-if="ic_tipo_pesquisa" class="row">
        <div class="margin1" style="font-weight: bold">
          {{ "Simples" }}
          <q-toggle
            v-model="tipo_pesquisa"
            :false-value="'N'"
            :true-value="'S'"
            color="primary"
          />{{ "Completa" }}
        </div>
      </div>

      <div class="margin1 text-black">
        <transition name="slide-fade">
          <div v-if="tipo_pesquisa == 'S'" class="col">
            <!-- Regra para ter multiplos filtros para pesquisa -->
          </div>
        </transition>

        <q-input
          v-if="tipo_pesquisa == 'N'"
          class="margin1"
          color="primary"
          v-model="atributo.nm_atributo"
          autofocus
          :label="nm_atributo"
          debounce="1000"
          @input="InputAtributo(1)"
        >
          <template v-slot:prepend>
            <q-icon name="inventory_2" />
          </template>
          <template v-slot:append>
            <q-btn
              size="sm"
              round
              color="primary"
              icon="search"
              @click="InputAtributo()"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                Pesquisar
              </q-tooltip>
            </q-btn>
            <q-btn
              v-if="1 == 2"
              size="sm"
              round
              color="primary"
              icon="add"
              @click="ic_crud = !ic_crud"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                Adicionar
              </q-tooltip>
            </q-btn>
          </template>
        </q-input>
      </div>
      <transition name="slide-fade">
        <div
          v-show="resultado_pesquisa.length > 0"
          class="borda-bloco shadow-2"
        >
          <div class="row items-center">
            <q-space />
            <q-btn
              rounded
              class="margin1"
              color="primary"
              label="Inserir"
              icon="input"
              @click="ListaCarrinho(linha_selecionada)"
            />
          </div>

          <DxDataGrid
            v-if="resultado_pesquisa"
            class="margin1"
            id="grid"
            ref="gridRefName"
            key-expr="cd_controle"
            :data-source="resultado_pesquisa"
            :columns="columns"
            :show-borders="true"
            :selection="{ mode: 'single' }"
            :focused-row-enabled="true"
            :column-hiding-enabled="false"
            :remote-operations="false"
            :word-wrap-enabled="false"
            :allow-column-reordering="false"
            :allow-column-resizing="true"
            :row-alternation-enabled="true"
            :repaint-changes-only="true"
            :autoNavigateToFocusedRow="true"
            :focused-row-index="0"
            :cacheEnable="false"
            @focused-row-changed="linhaSelecionada($event)"
            @row-dbl-click="ListaCarrinho($event.data)"
          >
            <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
            <DxExport :enabled="true" />
            <DxPager
              :show-page-size-selector="true"
              :allowed-page-sizes="[10, 20, 50, 100]"
              :show-info="true"
            />

            <DxPaging :enable="true" :page-size="10" />
            <DxSearchPanel
              :visible="true"
              :width="300"
              placeholder="Procurar..."
            />
          </DxDataGrid>
        </div>
      </transition>

      <transition name="slide-fade">
        <div v-if="ic_crud" class="borda-bloco shadow-2">
          <crudPadrao
            :cd_apiID="parseInt(this.cd_api)"
            :cd_menuID="parseInt(this.cd_menu_autoform)"
            :ic_mostra_titulo="false"
          />
        </div>
      </transition>
      <!---CARRINHO DE PRODUTOS--->
      <div style="margin: 0; padding: 0" class="row">
        <div v-show="ic_mostra_grid">
          <div class="row margin1 text-h6">Itens</div>
          <DxDataGrid
            v-if="carrinho"
            class="margin1 shadow-2"
            ref="grid_lista"
            key-expr="cd_controle"
            :columns="columns"
            :data-source="carrinho"
            :show-borders="true"
            :selection="{ mode: 'single' }"
            :focused-row-enabled="true"
            :column-hiding-enabled="false"
            :remote-operations="false"
            :word-wrap-enabled="false"
            :allow-column-reordering="false"
            :allow-column-resizing="true"
            :row-alternation-enabled="true"
            :repaint-changes-only="true"
            :autoNavigateToFocusedRow="true"
            :focused-row-index="0"
            @row-removed="ExcluirAtributo($event)"
            :cacheEnable="false"
            @focused-cell-Changing="attQtd($event)"
            @focused-row-changed="onFocusedRowChangedCarrinho($event)"
          >
            <DxEditing
              :allow-updating="edita_lista.allowUpdating"
              :allow-adding="edita_lista.allowAdding"
              :allow-deleting="edita_lista.allowDeleting"
              :select-text-on-edit-start="true"
              :mode="edita_lista.mode"
            />

            <DxPaging :enable="true" :page-size="10" />
          </DxDataGrid>
        </div>
      </div>
    </div>

    <q-dialog v-model="load_grid" maximized persistent>
      <carregando
        :mensagemID="'Carregando...'"
        :corID="'orange-9'"
      ></carregando>
    </q-dialog>
  </div>
</template>

<script>
import {
  DxDataGrid,
  DxPager,
  DxPaging,
  DxExport,
  DxGroupPanel,
  DxSearchPanel,
  DxEditing,
} from "devextreme-vue/data-grid";

import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import Menu from "../http/menu";
import Incluir from "../http/incluir_registro";
import Procedimento from "../http/procedimento";
import funcao from "../http/funcoes-padroes";
import "whatwg-fetch";
import { EventBus } from "../EventBus";

import { jsPDF } from "jspdf";
import "jspdf-autotable";
import { exportDataGrid } from "devextreme/excel_exporter";

var cd_empresa = 0;
var cd_menu = 0;
var cd_cliente = 0;
var cd_api = 0;
var filename = "DataGrid.xlsx";
var filenamepdf = "pdf";

var dados = [];

export default {
  props: {
    cd_apiID: { type: String, default: "" },
    cd_menuID: { type: Number, default: 0 },
    nm_atributo: { type: String, default: "" },
    ic_mostra_titulo: { type: Boolean, default: true },
    ic_mostra_grid: { type: Boolean, default: true },
    ic_tipo_pesquisa: { type: Boolean, default: true },
    lista: { type: Array, default: undefined },
    edita_lista: {
      type: Object,
      // eslint-disable-next-line vue/require-valid-default-prop
      default: {
        mode: "batch",
        allowUpdating: false,
        allowAdding: false,
        allowDeleting: false,
        colunas: [],
      },
    },
  },
  data() {
    return {
      tituloMenu: "",
      menu: "",
      ic_crud: false,
      show_grid_item: false,
      load_grid: false,
      confirm_del: false,
      tipo_pesquisa: "N",
      atributo: {},
      resultado_pesquisa: [],
      carrinho: [],
      linha_selecionada: "",
      grid_item: new Object(),
      column_item: [],
      columns: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      total: {},
      api: 0,
      row_data: {},
      taskDetails: "",
      temPanel: false,
      refreshMode: "full",
      sChave: "",
      tituloColuna: [],
      focogrid: false,
      qt_registro: 0,
      cd_api: 0,
      cd_api_parametro: 0,
      cd_menu_autoform: 0,
      cd_tipo_email: 0,
      cd_relatorio: 0,
      nm_template: "",
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
  },

  async mounted() {
    this.cd_api_parametro = this.cd_apiID;
    this.cd_menu_autoform = this.cd_menuID;
    [this.cd_api] = this.cd_api_parametro.split("/");
    //
    this.carregaDados();
    //
    EventBus.$on("parent-event", this.handleParentEvent);
  },

  components: {
    DxDataGrid,
    DxPager,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxSearchPanel,
    DxEditing,
    crudPadrao: () => import("../views/crud-padrao.vue"),
    carregando: () => import("../components/carregando.vue"),
  },

  computed: {
    gridLista() {
      return this.$refs["grid_lista"].instance;
    },
  },

  watch: {
    lista(antigo) {
      this.carrinho = antigo;
    },
  },

  methods: {
    exportGrid() {
      const doc = new jsPDF();

      doc.autoTable({ html: "#my-table" });
      // Or use javascript directly:

      var t = ["Desenvolvimento - Aguardar Liberação nova Versão !"];

      doc.autoTable({
        head: [[t]],

        body: [
          ["< Previsão: Fevereiro/2021 >"],
          // ...
        ],
      });
      doc.save(filenamepdf);
    },

    onFocusedRowChanged: function (e) {
      this.row_data = e.row.data;
    },

    async handleParentEvent() {
      await this.$refs["grid_lista"].instance.saveEditData();
      this.$emit("attLista", this.carrinho);
    },

    async carregaDados() {
      this.temPanel = true;

      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      if (this.cd_menu_autoform) {
        cd_menu = String(this.cd_menu_autoform);
      } else {
        cd_menu = localStorage.cd_menu;
      }
      ////////////////////////////////////
      if (this.cd_api) {
        cd_api = String(this.cd_api);
      } else {
        cd_api = localStorage.cd_api;
      }

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api);

      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      //API do Crud
      this.tituloColuna = dados.tituloColuna;

      this.tituloMenu = dados.nm_menu_titulo;
      this.menu = dados.nm_menu;
      this.cd_tipo_email = dados.cd_tipo_email;
      this.cd_relatorio = dados.cd_relatorio;
      this.nm_template = dados.nm_template;

      if (!dados.chave == "") {
        this.sChave = dados.chave;
        this.focogrid = true;
      }
      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      this.columns.map((e) => {
        e.encodeHtml = false;
        if (this.edita_lista.colunas.includes(e.dataField)) {
          e.allowEditing = true;
        } else {
          e.allowEditing = false;
        }
      });
      this.column_item = this.columns.filter((e) => {
        return e.caption !== "cd_controle";
      });
      this.limpaCampos();
      this.total = {};

      if (dados.coluna_total) {
        this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      }
      //Gera os Dados para Montagem da Grid
      //exec da procedure

      this.api =
        localStorage.nm_identificacao_api || dados.nm_identificacao_api;
      let sParametroApi = dados.nm_api_parametro;
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        cd_empresa,
        cd_cliente,
        this.api,
        sParametroApi
      );

      this.qt_registro = this.dataSourceConfig.length;

      filename = this.tituloMenu + ".xlsx";
      filenamepdf = this.tituloMenu + ".pdf";
    },

    async InputAtributo() {
      let obj_pesquisa = {
        cd_parametro: 0,
        nm_servico: this.atributo.nm_atributo,
      };
      let res_pesquisa = await Incluir.incluirRegistro(
        this.cd_api_parametro,
        obj_pesquisa
      );
      if (res_pesquisa[0].Msg) {
        notify(res_pesquisa[0].Msg);
      } else {
        this.resultado_pesquisa = res_pesquisa;
      }
    },

    ExcluirAtributo() {
      this.$emit("attLista", this.carrinho);
    },

    async attQtd(e) {
      await funcao.sleep(1);
      e.rows.map((i) => {
        if (
          i.data.qt_servico == null ||
          i.data.qt_servico == undefined ||
          i.data.qt_servico < 0
        ) {
          this.$refs["grid_lista"].instance.cellValue(
            i.rowIndex,
            "qt_servico",
            1
          );
          i.data.qt_servico = 1;
        }
        if (
          i.data.vl_servico == null ||
          i.data.vl_servico == undefined ||
          i.data.vl_servico < 0
        ) {
          this.$refs["grid_lista"].instance.cellValue(
            i.rowIndex,
            "vl_servico",
            0.0
          );
          i.data.vl_servico = 0;
        }
        let vl_total_servico_formatado = i.data.qt_servico * i.data.vl_servico;
        this.$refs["grid_lista"].instance.cellValue(
          i.rowIndex,
          "vl_total_servico",
          vl_total_servico_formatado
        );
      });
      await this.$refs["grid_lista"].instance.saveEditData();
      this.$emit("attLista", this.carrinho);
    },

    onFocusedRowChangedCarrinho() {
      //console.log("onFocusedRowChangedCarrinho");
    },

    linhaSelecionada: function (e) {
      this.linha_selecionada = e.row && e.row.data;
    },
    ListaCarrinho(e) {
      if (this.carrinho.length === 0) {
        this.carrinho.push(e);
      } else {
        e.cd_controle = parseFloat(
          this.carrinho[this.carrinho.length - 1].cd_controle + 1
        );
        this.carrinho.push(e);
      }
      this.$emit("attLista", this.carrinho);
      this.$emit("itemSelecionado", e);
      this.resultado_pesquisa = [];
      this.atributo.nm_atributo = "";
    },

    limpaCampos() {
      this.grid_item = this.row_data;
      this.column_item.map((i) => {
        if (i.dataType === "boolean") {
          this.grid_item[i.dataField] = "N";
        }
        if (i.lookup) {
          this.grid_item[i.dataField] = null;
        }
        if (!i.lookup && i.dataType !== "boolean") {
          this.grid_item[i.dataField] = "";
        }
      });
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
  beforeDestroy() {
    // Remove o listener quando o componente for destruído
    EventBus.$off("parent-event", this.handleParentEvent);
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

.itemCrud {
  display: flex;
  box-sizing: border-box;
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

#exportButton {
  display: inline-block;
  margin-bottom: 10px;
  margin-left: 10px;
}
</style>
