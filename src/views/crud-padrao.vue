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

    <q-btn class="margin1" round color="green" icon="add" @click="onAdd()">
      <q-tooltip> Adicionar </q-tooltip>
    </q-btn>

    <q-btn class="margin1" round color="orange" icon="edit" @click="onUpdate()">
      <q-tooltip> Alterar </q-tooltip>
    </q-btn>

    <q-btn
      class="margin1"
      round
      color="red"
      icon="delete"
      @click="confirm_del = true"
    >
      <q-tooltip> Deletar </q-tooltip>
    </q-btn>

    <!-- CRUD Form -->
    <Transition name="fade">
      <div class="margin1 borda-bloco shadow-2" v-if="show_grid_item">
        <div class="row">
          <div
            v-show="i.formItem.visible"
            class="col-3"
            v-for="(i, index) in column_item"
            :key="index"
          >
            <q-input
              dense
              v-if="!i.lookup && i.dataType !== 'boolean'"
              class="margin1"
              :label="`${i.caption} ${
                i.ic_atributo_obrigatorio === 'S' ? '*' : ''
              }`"
              :type="i.dataType === 'string' ? 'text' : i.dataType"
              :stack-label="i.dataType === 'date'"
              clearable
              min="0"
              :maxlength="
                String(i.qt_tamanho_atributo) > '0'
                  ? Number(i.qt_tamanho_atributo)
                  : 20
              "
              v-model="grid_item[i.dataField]"
              @input="Digitou($event, grid_item[i.dataField])"
              :hint="
                String(i.qt_tamanho_atributo) > '0'
                  ? `${
                      grid_item[i.dataField]
                        ? String(grid_item[i.dataField]).length
                        : 0
                    }/${i.qt_tamanho_atributo}`
                  : ''
              "
            />
            <q-toggle
              v-if="!i.lookup && i.dataType === 'boolean'"
              class="margin1"
              :label="`${i.caption} ${
                i.ic_atributo_obrigatorio === 'S' ? '*' : ''
              }`"
              v-model="grid_item[i.dataField]"
              color="primary"
              true-value="S"
              false-value="N"
              checked-icon="check"
              unchecked-icon="clear"
              @input="onToggle(grid_item[i.dataField], 5)"
            />
            <q-select
              dense
              class="margin1"
              v-if="i.lookup"
              v-model="grid_item[`${i.dataField}${index}`]"
              :options="i.lookup.dataSource"
              :label="`${i.caption} ${
                i.ic_atributo_obrigatorio === 'S' ? '*' : ''
              }`"
              :option-value="i.lookup.valueExpr"
              :option-label="i.lookup.displayExpr"
              @input="
                onSelect(
                  grid_item[`${i.dataField}${index}`],
                  i.lookup.valueExpr,
                  i.dataField,
                  i.lookup.displayExpr
                )
              "
            />
          </div>
        </div>
        <!-- Buttons -->
        <div class="margin1">
          <q-btn
            rounded
            class="margin1"
            color="green"
            icon="check"
            label="Gravar"
            @click="onSave()"
          />
          <!-- <q-btn
            rounded
            class="margin1"
            color="red"
            icon="close"
            label="Cancelar"
            @click="limpaCampos()"
          /> -->

          <q-btn
            rounded
            class="margin1"
            color="grey"
            icon="cancel"
            label="Fechar"
            @click="onFechar()"
          />
        </div>
      </div>
    </Transition>
    <!-- CRUD Form -->

    <dx-data-grid
      class="dx-card wide-card"
      :data-source="dataSourceConfig"
      :columns="columns"
      :summary="total"
      :key-expr="sChave"
      :show-borders="true"
      :focused-row-enabled="focogrid"
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
      :column-min-width="50"
      :show-column-lines="false"
      @focused-row-changed="onFocusedRowChanged"
    >
      <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

      <DxGrouping :auto-expand-all="true" />

      <DxExport :enabled="true" />

      <DxPaging :enable="true" :page-size="10" />

      <DxStateStoring :enabled="true" type="localStorage" :storage-key="menu" />

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
        :allow-adding="false"
        :allow-updating="false"
        :allow-deleting="false"
        mode="popup"
      >
      </DxEditing>
    </dx-data-grid>
    <q-dialog v-model="load_grid" maximized persistent>
      <carregando
        :mensagemID="'Carregando...'"
        :corID="'orange-9'"
      ></carregando>
    </q-dialog>

    <q-dialog v-model="confirm_del" persistent>
      <q-card>
        <q-card-section class="row items-center">
          <q-avatar icon="warning" color="red" text-color="white"></q-avatar>
          <span class="q-ml-sm"
            >Deseja realmente deletar esse registro ?
            <b>Essa ação é irreversível</b></span
          >
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            rounded
            label="Confirmar"
            color="green"
            v-close-popup
            @click="onDelete()"
          ></q-btn>
          <q-btn rounded label="Cancelar" color="red" v-close-popup></q-btn>
        </q-card-actions>
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
  DxEditing,
} from "devextreme-vue/data-grid";

import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import funcoesPadroes from "../http/funcoes-padroes";
import Menu from "../http/menu";
import Incluir from "../http/incluir_registro";
import Deletar from "../http/excluir_registro";
import Alterar from "../http/alterar_registro";
import Procedimento from "../http/procedimento";
import "whatwg-fetch";

import { jsPDF } from "jspdf";
import "jspdf-autotable";
import { exportDataGrid } from "devextreme/excel_exporter";

var cd_empresa = 0;
var cd_menu = 0;
var cd_cliente = 0;
var cd_api = 0;
var apiCrud = "";

var filename = "DataGrid.xlsx";
var filenamepdf = "pdf";

var dados = [];

//const dataGridRef = 'dataGrid';

export default {
  props: {
    cd_apiID: { type: Number, default: 0 },
    cd_menuID: { type: Number, default: 0 },
    ic_mostra_titulo: { type: Boolean, default: true },
  },
  data() {
    return {
      tituloMenu: "",
      menu: "",
      show_grid_item: false,
      load_grid: false,
      confirm_del: false,
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
      cd_api_autoform: 0,
      cd_menu_autoform: 0,
      cd_tipo_email: 0,
      cd_relatorio: 0,
      nm_template: "",
    };
  },

  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    // locale('pt-BR');
  },

  async mounted() {
    this.cd_api_autoform = this.cd_apiID;
    this.cd_menu_autoform = this.cd_menuID;

    //
    this.carregaDados();
    //
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
    DxEditing,
    carregando: () => import("../components/carregando.vue"),
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
      if (this.cd_api_autoform) {
        cd_api = String(this.cd_api_autoform);
      } else {
        cd_api = localStorage.cd_api;
      }

      localStorage.nm_identificacao_api;

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';

      if (!dados.nm_identificacao_api == "") {
        dados.nm_identificacao_api;
      }

      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      //API do Crud
      apiCrud = dados.nm_sql_procedimento;
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

    Digitou() {},

    async onFechar() {
      this.show_grid_item = false;
      try {
        this.load_grid = true;
        await this.carregaDados();
        this.load_grid = false;
      } catch (error) {
        this.load_grid = false;
      }
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

    validaCampos() {
      Object.values(this.grid_item).map((i, ind) => {
        if (typeof i === "string") {
          this.grid_item[Object.keys(this.grid_item)[ind]] =
            funcoesPadroes.ValidaStringSimples(i);
        }
      });
    },

    onToggle() {},

    onSelect(e, value, key, nm_campo) {
      this.grid_item[key] = e[value];
      this.grid_item[nm_campo] = e[nm_campo];
    },

    async onSave() {
      let primary_key = this.column_item.filter(
        (i) => i.ic_atributo_obrigatorio === "S" && i.formItem.visible === false
      );
      this.validaCampos();
      await funcoesPadroes.sleep(1);
      try {
        this.load_grid = true;
        this.grid_item.cd_usuario = localStorage.cd_usuario;
        if (this.grid_item[primary_key[0].dataField] > 0) {
          //Tem PK então é Update/Alteração
          let result_update = await Alterar.alterarRegistro(
            apiCrud,
            this.grid_item
          );
          notify(result_update[0].Msg);
          await this.carregaDados();
        } else {
          //Não tem PK então é Insert
          let result_insert = await Incluir.incluirRegistro(
            apiCrud,
            this.grid_item
          );
          notify(result_insert[0].Msg);
          await this.carregaDados();
        }
        this.show_grid_item = false;
        this.load_grid = false;
      } catch {
        this.load_grid = false;
        notify("Não foi possível inserir o registro!");
      }
    },

    onAdd() {
      this.show_grid_item = true;
      this.limpaCampos();
    },

    onUpdate() {
      this.show_grid_item = true;
      this.grid_item = this.row_data;
      let items_filtrados = this.column_item.filter((i) => i.formItem.visible);
      items_filtrados.map((e, i) => {
        if (e.lookup) {
          var lookup_index = Object.keys(this.grid_item).findIndex(
            (b) => b === e.lookup.displayExpr || b === e.lookup.valueExpr
          );
          var lookup_value = Object.keys(this.grid_item).find(
            (b) => b === e.lookup.displayExpr || b === e.lookup.valueExpr
          );
          [this.grid_item[`${e.dataField}${i + 1}`]] =
            e.lookup.dataSource.filter((c) => {
              return (
                Object.keys(c).find((x) => x === lookup_value) &&
                Object.values(c).find(
                  (y) => y == Object.values(this.grid_item)[lookup_index]
                )
              );
            });
        }
      });
    },

    async onDelete() {
      let cd_controle = this.row_data[this.sChave];
      if (this.cd_controle != 0) {
        dados = await Deletar.excluirRegistro(apiCrud, cd_controle);
        this.carregaDados();
        notify(dados[0].Msg);
      } else {
        notify("Selecione um item para excluir");
      }
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
