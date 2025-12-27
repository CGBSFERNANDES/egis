<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center">
      <btnVoltarHome />
      <transition name="slide-fade">
        <h2 class="content-block col-8" v-show="!!tituloMenu != false">
          {{ tituloMenu }}
          <q-badge
            v-if="qt_registro > 0"
            align="middle"
            rounded
            color="red"
            :label="qt_registro"
          />
        </h2>
      </transition>
    </div>
    <q-tabs
      v-model="tab"
      class="text-orange margin1"
      no-caps
      align="left"
      switch-indicator
      active-color="blue"
      active-bg-color="blue-2"
      indicator-color="blue"
    >
      <q-tab name="cadastro" label="Cadastro"></q-tab>
      <q-tab name="categoria" label="Categoria"></q-tab>
      <q-tab name="produto" label="Produto"></q-tab>
      <q-tab name="lista" label="Lista"></q-tab>
      <q-tab name="cesta" label="Cesta"></q-tab>
    </q-tabs>
    <q-tab-panels
      v-model="tab"
      animated
      swipeable
      vertical
      transition-prev="jump-up"
      transition-next="jump-up"
    >
      <q-tab-panel name="cadastro">
        <!-- Select Cliente -->
        <cliente :ic_pesquisa="true" />
      </q-tab-panel>

      <q-tab-panel name="categoria">
        <h2 class="content-block col-8">Categoria</h2>
        <grid :cd_menuID="this.cd_menu" :cd_apiID="this.cd_api" ref="grid_c">
        </grid>
      </q-tab-panel>

      <q-tab-panel name="produto">
        <div class="text-h4 q-mb-md">Produto</div>
        <produto />
      </q-tab-panel>

      <q-tab-panel name="lista">
        <div class="text-h4 q-mb-md">Lista</div>
        <div class="row">
          <q-select
            rounded
            outlined
            bottom-slots
            class="margin1 col-2 opcoes"
            v-model="forma_pagamento"
            :options="lookup_forma_pagamento"
            option-value="cd_forma_pagamento"
            option-label="nm_forma_pagamento"
            label="Pagamento"
          >
            <template v-slot:prepend>
              <q-icon name="attach_money"></q-icon>
            </template>
            <template v-slot:hint>
              <transition name="slide-fade">
                <div
                  style="font-weight: bold"
                  v-if="forma_pagamento.pc_desconto_pedido > 0"
                >
                  {{ `${forma_pagamento.pc_desconto_pedido}% de Desconto` }}
                </div>
              </transition>
            </template>
          </q-select>

          <q-input
            class="margin1 col-2 opcoes"
            rounded
            outlined
            stack-label
            type="date"
            v-model="dt_entrega"
            label="Data de Entrega"
          >
            <template v-slot:prepend>
              <q-icon name="event"></q-icon>
            </template>
          </q-input>
          <q-input
            class="margin1 col-2 opcoes"
            rounded
            outlined
            stack-label
            type="time"
            v-model="hr_entrega"
            label="Horário"
          >
            <template v-slot:prepend>
              <q-icon name="event"></q-icon>
            </template>
          </q-input>
          <q-input
            class="margin1 col-2 opcoes"
            rounded
            outlined
            v-model="ds_descricao"
            label="Descrição"
          >
            <template v-slot:prepend>
              <q-icon name="folder"></q-icon>
            </template>
          </q-input>
          <div
            class="margin1 col-2 opcoes"
            style="font-weight: bold; font-size: 16px"
          >
            <!-- <q-icon name="inventory_2"></q-icon>{{ `Quantidade: ${this.qtd}`
        }}<br /> -->
            <q-icon name="inventory_2"></q-icon
            >{{ `Produtos: ${this.produtos} ` }}<br />
            <q-icon name="gavel"></q-icon>{{ `Imposto: ${this.vl_imposto} `
            }}<br />
            <q-icon name="attach_money"></q-icon
            >{{ `Valor líq: ${this.vl_liquido} ` }}<br />
            <q-icon name="attach_money"></q-icon>{{ `Total: ${this.valor} `
            }}<br />
            <transition name="slide-fade">
              <div v-if="vl_desconto_pedido" style="color: red">
                <q-icon name="money_off"></q-icon
                >{{ `Desconto: ${this.vl_desconto_pedido} ` }}<br />
              </div>
            </transition>
            <transition name="slide-fade">
              <div v-if="valor_liquido">
                <q-icon name="attach_money"></q-icon
                >{{ `Líquido: ${this.valor_liquido} ` }}<br />
              </div>
            </transition>
          </div>
          <div>
            <q-btn
              round
              class="margin1"
              text-color="white"
              color="primary"
              icon="shopping_bag"
              @click="onCesta()"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                Cesta de Pedido
              </q-tooltip>
            </q-btn>
            <q-btn
              round
              class="margin1"
              color="red"
              text-color="white"
              icon="delete"
              @click="onCancelar()"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                Cancelar
              </q-tooltip>
            </q-btn>
            <q-btn
              round
              class="margin1"
              color="orange-9"
              text-color="white"
              icon="print"
              :loading="loadingPDF"
              @click="onPDF()"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                Gerar PDF
              </q-tooltip>
            </q-btn>
            <q-btn
              round
              class="margin1"
              color="green"
              text-color="white"
              icon="save"
              @click="onEnviarPedido()"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                Enviar Pedido
              </q-tooltip>
            </q-btn>
          </div>
        </div>
        <!-- Grid -->
        <div v-if="loadingDataSourceConfig == true" class="row">
          <q-spinner-facebook class="col margin1" color="orange-9" size="6em" />
          <q-tooltip :offset="[0, 8]">Carregando...</q-tooltip>
        </div>
        <div v-else>
          <transition name="slide-fade">
            <dx-data-grid
              id="gridPadrao"
              ref="gridPadrao"
              v-if="!ic_grid_cesta"
              class="margin1 dx-card wide-card-gc"
              :data-source="dataSourceConfig"
              :columns="columns"
              :summary="total"
              key-expr="cd_controle"
              :selection="{ mode: 'single' }"
              :show-borders="true"
              :focused-row-enabled="true"
              :column-auto-width="true"
              :column-hiding-enabled="false"
              :remote-operations="false"
              :word-wrap-enabled="false"
              :allow-column-reordering="true"
              :allow-column-resizing="true"
              :row-alternation-enabled="false"
              :repaint-changes-only="true"
              :autoNavigateToFocusedRow="true"
              :cacheEnable="false"
              @initialized="onInitializedGrid"
              @exporting="onExporting"
              @focused-cell-Changing="attQtd($event)"
            >
              <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

              <DxEditing
                :allow-updating="true"
                :allow-adding="false"
                :allow-deleting="false"
                :select-text-on-edit-start="true"
                mode="batch"
              />

              <DxMasterDetail
                v-if="masterDetail == true"
                :enabled="true"
                template="masterDetailTemplate"
              />

              <template #masterDetailTemplate="{ data: dataSourceConfig }">
                {{ dataSourceConfig.data }}
              </template>

              <DxGrouping :auto-expand-all="true" v-if="filterGrid == true" />
              <DxExport :enabled="true" v-if="filterGrid == true" />

              <DxPaging :enable="true" :page-size="10" />

              <DxStateStoring
                :enabled="true"
                type="localStorage"
                storage-key="storage"
              />
              <DxSelection mode="multiple" v-if="multipleSelection == true" />
              <DxSelection mode="single" v-else />
              <DxPager
                :show-page-size-selector="true"
                :allowed-page-sizes="pageSizes"
                :show-info="true"
              />
              <DxFilterRow :visible="false" v-if="filterGrid == true" />
              <DxHeaderFilter
                :visible="true"
                :allow-search="true"
                :width="400"
                v-if="filterGrid == true"
                :height="400"
              />
              <DxSearchPanel
                :visible="true"
                :width="300"
                placeholder="Procurar..."
                v-if="filterGrid == true"
              />
              <DxFilterPanel :visible="true" v-if="filterGrid == true" />
              <DxColumnFixing :enabled="false" v-if="filterGrid == true" />
              <DxColumnChooser
                :enabled="true"
                mode="select"
                v-if="filterGrid == true"
              />
            </dx-data-grid>
          </transition>
        </div>
        <!-- aqui -->
        <transition name="slide-fade">
          <div
            id="cesta"
            class="margin1 borda-bloco shadow-2"
            v-show="ic_grid_cesta"
          >
            <div v-if="complemento_impressao">
              <h2 class="content-block" style="display: block">
                {{ tituloMenu }}
                <div
                  class="margin1 row"
                  style="
                    font-weight: bold;
                    font-size: 14px;
                    display: flex;
                    flex-wrap: wrap;
                  "
                >
                  <div class="margin1 borda-bloco col-2">
                    {{ `Quantidade: ${this.qtd ? this.qtd : ""}` }}
                  </div>
                  <div class="margin1 borda-bloco col-2">
                    {{ `Produtos: ${this.produtos ? this.produtos : ""}` }}
                  </div>
                  <div class="margin1 borda-bloco col-2">
                    {{ `Total Bruto: ${this.valor ? this.valor : ""}` }}
                  </div>
                  <div class="margin1 borda-bloco col-2">
                    {{ `Imposto: ${this.vl_imposto ? this.vl_imposto : ""}` }}
                  </div>
                  <div class="margin1 borda-bloco col-2">
                    {{ `Total Líq: ${this.vl_liquido ? this.vl_liquido : ""}` }}
                  </div>
                  <div class="margin1 borda-bloco col-2">
                    {{
                      `Pagamento: ${
                        this.forma_pagamento.nm_forma_pagamento
                          ? this.forma_pagamento.nm_forma_pagamento
                          : ""
                      }`
                    }}
                  </div>
                  <div class="margin1 borda-bloco col-2">
                    {{ `Entrega: ${this.dt_entrega ? this.dt_entrega : ""}` }}
                  </div>
                  <div class="margin1 borda-bloco col-2">
                    {{ `Horário: ${this.hr_entrega ? this.hr_entrega : ""}` }}
                  </div>
                  <br />
                  <div
                    v-if="vl_desconto_pedido"
                    style="color: red"
                    class="margin1 borda-bloco col"
                  >
                    {{ `Desconto: ${this.vl_desconto_pedido}` }}<br />
                  </div>
                  <div v-if="valor_liquido" class="margin1 borda-bloco col">
                    {{ `Líquido: ${this.valor_liquido}` }}<br />
                  </div>
                </div>
              </h2>
              <div class="margin1" style="font-weight: bold; font-size: 18px">
                {{ `Descrição: ${this.ds_descricao}` }}
              </div>
            </div>
            <div class="card-cesta row">
              <q-card
                class="margin1 borda-bloco shadow-2 col-3"
                v-for="(i, index) in dataCesta"
                :key="index"
              >
                <q-card-section>
                  {{ `Código: ${i.CODIGO}` }} <br />
                  {{ `Produto: ${i.DESCRICAO}` }} <br />
                  {{ `Un: ${i.sg_unidade_medida}` }} <br />
                  {{ `Qtd: ${i.qt_digitacao}` }} <br />
                  {{ `Total Bruto: ${i.vl_total_item}` }} <br />
                  {{ `Imposto: ${i.vl_total_icms}` }} <br />
                  {{ `Total Liq: ${i.vl_unitario_liq}` }} <br />
                </q-card-section>
              </q-card>
            </div>
          </div>
        </transition>
      </q-tab-panel>

      <q-tab-panel name="cesta">
        <div class="text-h4 q-mb-md">Cesta</div>
        <p>
          Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis
          praesentium cumque magnam odio iure quidem, quod illum numquam
          possimus obcaecati commodi minima assumenda consectetur culpa fuga
          nulla ullam. In, libero.
        </p>
        <p>
          Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis
          praesentium cumque magnam odio iure quidem, quod illum numquam
          possimus obcaecati commodi minima assumenda consectetur culpa fuga
          nulla ullam. In, libero.
        </p>
        <p>
          Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis
          praesentium cumque magnam odio iure quidem, quod illum numquam
          possimus obcaecati commodi minima assumenda consectetur culpa fuga
          nulla ullam. In, libero.
        </p>
      </q-tab-panel>
    </q-tab-panels>
    <q-dialog v-if="!complemento_impressao" maximized persistent>
      <carregando :corID="'orange-9'" mensagemID="Aguarde..."></carregando>
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
  DxEditing,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxSelection,
  DxStateStoring,
  DxMasterDetail,
  DxSearchPanel,
} from "devextreme-vue/data-grid";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import funcao from "../http/funcoes-padroes";
import Incluir from "../http/incluir_registro";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import Lookup from "../http/lookup";
import formataData from "../http/formataData";
import notify from "devextreme/ui/notify";

var dados = [];
let filename = "DataGrid.xlsx";
var sParametroApi = "";

export default {
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_cliente: localStorage.cd_cliente,
      cd_menu: localStorage.cd_menu,
      cd_api: localStorage.cd_api,
      api: "",
      tab: "cadastro",
      //Somas
      valor: 0,
      vl_imposto: 0,
      vl_liquido: 0,
      valor_liquido: 0,
      qtd: 0,
      produtos: 0,
      vl_desconto_pedido: 0,
      //////////////////////
      loadingPDF: false,
      loadingDataSourceConfig: false,
      masterDetail: false,
      filterGrid: true,
      multipleSelection: false,
      ic_grid_cesta: false,
      complemento_impressao: false,
      pageSizes: [10, 20, 50, 100],
      data_hoje: new Date(),
      dataSourceConfig: [],
      dataCesta: [],
      qt_registro: "",
      columns: [],
      total: {},
      tituloMenu: "",
      forma_pagamento: "",
      lookup_forma_pagamento: [],
      dt_entrega: "",
      hr_entrega: "",
      ds_descricao: "",
    };
  },

  components: {
    DxDataGrid,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxEditing,
    DxGrouping,
    DxColumnChooser,
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxSelection,
    DxStateStoring,
    DxMasterDetail,
    DxSearchPanel,
    carregando: () => import("../components/carregando.vue"),
    cliente: () => import("../views/cliente.vue"),
    grid: () => import("../views/grid"),
    produto: () => import("../views/produto"),
    btnVoltarHome: () => import("../components/btnVoltarHome.vue"),
  },

  async created() {
    let lookup_forma_pagamento = await Lookup.montarSelect(
      this.cd_empresa,
      2774
    );
    this.lookup_forma_pagamento = JSON.parse(
      JSON.parse(JSON.stringify(lookup_forma_pagamento.dataset))
    );
    this.lookup_forma_pagamento = this.lookup_forma_pagamento.filter((e) => {
      return e.ic_selecao_pedido === "S";
    });
    this.dt_entrega = formataData.AnoMesDia(this.data_hoje);
    this.carregaDados();
  },

  async beforeRouteLeave(to, from, next) {
    if (this.$refs.gridPadrao) {
      setTimeout(async () => {
        await this.$refs.gridPadrao.instance.clearSelection();
        await this.$refs.gridPadrao.instance.clearFilter();
      }, 1);
    }
    next();
  },

  computed: {
    gridPadrao() {
      return this.$refs["gridPadrao"].instance;
    },
  },

  methods: {
    async carregaDados() {
      localStorage.cd_identificacao = 0;
      await this.showMenu();

      notify("Aguarde... estamos montando a consulta para você!");
      let sApis = sParametroApi;
      if (!sApis == "") {
        try {
          this.loadingDataSourceConfig = true;
          this.dataSourceConfig = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            this.api,
            sApis
          );
          this.loadingDataSourceConfig = false;
        } catch (error) {
          this.loadingDataSourceConfig = false;
          console.error(error);
        }

        this.qt_registro = this.dataSourceConfig.length;
      }
    },
    async showMenu() {
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      localStorage.cd_parametro = 0;

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';

      sParametroApi = dados.nm_api_parametro;

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      //this.menu = dados.nm_menu;
      filename = this.tituloMenu + ".xlsx";
      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      this.columns.map((e) => {
        e.encodeHtml = false;
        if (e.dataField == "qt_digitacao") {
          e.allowEditing = true;
        } else {
          e.allowEditing = false;
        }
      });
      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //
    },
    async onEnviarPedido() {
      try {
        await this.$refs.gridPadrao.instance.saveEditData();
        await funcao.sleep(1);
      } catch {
        notify("Salvando pedido");
      }
      this.limpaTotais();
      this.dataSourceConfig.forEach((i) => {
        this.valor +=
          i.qt_digitacao.toFixed(2) * i.VL_PRODUTO.toFixed(2) + i.vl_icms_st;
        this.qtd += i.qt_digitacao;
        i.qt_digitacao > 0 ? this.produtos++ : 0;
      });
      if (this.forma_pagamento.pc_desconto_pedido) {
        this.vl_desconto_pedido =
          (this.valor / 100) *
          parseFloat(this.forma_pagamento.pc_desconto_pedido);
        this.valor_liquido =
          this.valor -
          this.valor *
            (parseFloat(this.forma_pagamento.pc_desconto_pedido) / 100);

        this.valor_liquido = this.valor_liquido.toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
        this.vl_desconto_pedido = this.vl_desconto_pedido.toLocaleString(
          "pt-BR",
          {
            style: "currency",
            currency: "BRL",
          }
        );
      } else {
        this.vl_desconto_pedido = 0;
        this.valor_liquido = 0;
      }
      this.valor = this.valor.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
      var json_envia_pedido = {
        cd_forma_pagamento: this.forma_pagamento.cd_forma_pagamento,
        dt_entrega: this.dt_entrega,
        hr_entrega: this.hr_entrega,
        ds_descricao: this.ds_descricao,
        cd_cliente: this.cd_cliente,
        cd_usuario: this.cd_usuario,
        cd_contato: localStorage.cd_contato,
        grid: this.dataSourceConfig,
      };
      let [result_pedido] = await Incluir.incluirRegistro(
        "842/1319", //this.api,
        json_envia_pedido
      ); //pr_egisnet_pedido_fabrica
      notify(result_pedido.Msg);
      this.limpaTotais();
      this.carregaDados();
    },
    async onCancelar() {
      this.ic_grid_cesta = true;
      await funcao.sleep(1000);
      await this.carregaDados();
      //await this.gridPadrao.cancelEditData();
      await funcao.sleep(1000);
      this.dataCesta = [];
      this.ic_grid_cesta = false;
      this.complemento_impressao = false;
      this.limpaTotais();
    },
    async GeraCesta() {
      try {
        let verificador = this.dataSourceConfig.filter(
          (i) => i.qt_digitacao > 0
        );
        await this.$refs.gridPadrao.instance.saveEditData();
        await funcao.sleep(1);
        this.dataCesta = this.dataSourceConfig.filter(
          (i) => i.qt_digitacao > 0
        );
        if (this.dataCesta.length !== verificador.length) {
          this.dataCesta.map((i) => {
            i.vl_total_icms = i.vl_icms_st * i.qt_digitacao;
            i.vl_unitario_icms = i.VL_PRODUTO + i.vl_icms_st;
            i.vl_unitario_liq = i.VL_PRODUTO * i.qt_digitacao;
            i.VL_PRODUTO = i.VL_PRODUTO.toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            });
            i.vl_total_item = i.vl_total_item.toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            });
            i.vl_icms_st = i.vl_icms_st.toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            });
            i.vl_total_icms = i.vl_total_icms.toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            });
            i.vl_unitario_icms = i.vl_unitario_icms.toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            });
            i.vl_unitario_liq = i.vl_unitario_liq.toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            });
          });
        }
      } catch {
        notify("Aguarde...");
      }
    },
    async onCesta() {
      this.ic_grid_cesta = !this.ic_grid_cesta;
      this.GeraCesta();
    },
    async onPDF() {
      await this.GeraCesta();
      await funcao.sleep(10);
      if (this.dataCesta.length > 0) {
        try {
          this.complemento_impressao = true;
          this.dt_entrega = formataData.DiaMesAno(this.dt_entrega);
          this.ic_grid_cesta = true;
          // await this.onCesta();
          await funcao.sleep(1000);
          this.loadingPDF = true;
          let html = document.getElementById("cesta");
          //Configura o PDF que será baixado.
          let config = {
            orientation: "p",
            unit: "mm",
            format: [1280, 1880], //y 1480
            putOnlyUsedFonts: false,
            nm_pdf: this.tituloMenu,
          };
          //Cria o documento PDF
          await funcao.ExportHTML(html, "A", config);
          this.loadingPDF = false;
          await funcao.sleep(10);
          this.complemento_impressao = false;
        } catch {
          this.complemento_impressao = false;
        }
      } else {
        notify("Insira pelo menos um item para gerar o relatório");
      }
    },
    async attQtd(e) {
      await funcao.sleep(1);
      this.limpaTotais();
      e.rows.map((i) => {
        if (typeof i.data.qt_digitacao === "string") {
          i.data.qt_digitacao = funcao.RealParaInt(i.data.qt_digitacao);
        }
        if (typeof i.data.VL_PRODUTO === "string") {
          i.data.VL_PRODUTO = funcao.RealParaInt(i.data.VL_PRODUTO);
        }
        if (typeof i.data.vl_icms_st === "string") {
          i.data.vl_icms_st = funcao.RealParaInt(i.data.vl_icms_st);
        }
        if (i.data.qt_digitacao > 0) {
          let vl_total_item =
            i.data.qt_digitacao.toFixed(2) * i.data.VL_PRODUTO.toFixed(2) +
            i.data.qt_digitacao.toFixed(2) * i.data.vl_icms_st;
          let vl_total_liquido =
            i.data.qt_digitacao.toFixed(2) * i.data.VL_PRODUTO.toFixed(2);
          let vl_total_icms =
            i.data.qt_digitacao.toFixed(2) * i.data.vl_icms_st;
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_item",
            vl_total_item
          );
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_liquido",
            vl_total_liquido
          );
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_icms",
            vl_total_icms
          );
          this.valor +=
            i.data.qt_digitacao.toFixed(2) * i.data.VL_PRODUTO.toFixed(2) +
            i.data.qt_digitacao.toFixed(2) * i.data.vl_icms_st;
        }
        this.vl_imposto += i.data.qt_digitacao.toFixed(2) * i.data.vl_icms_st;
        this.vl_liquido +=
          i.data.qt_digitacao.toFixed(2) * i.data.VL_PRODUTO.toFixed(2);

        this.qtd += i.data.qt_digitacao;
        i.data.qt_digitacao > 0 ? this.produtos++ : 0;
      });
      if (this.forma_pagamento.pc_desconto_pedido) {
        this.vl_desconto_pedido =
          (this.valor / 100) *
          parseFloat(this.forma_pagamento.pc_desconto_pedido);
        this.valor_liquido =
          this.valor -
          this.valor *
            (parseFloat(this.forma_pagamento.pc_desconto_pedido) / 100);
        this.valor_liquido = this.valor_liquido.toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
        this.vl_desconto_pedido = this.vl_desconto_pedido.toLocaleString(
          "pt-BR",
          {
            style: "currency",
            currency: "BRL",
          }
        );
      } else {
        this.vl_desconto_pedido = 0;
        this.valor_liquido = 0;
      }
      this.valor = this.valor.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
      this.vl_imposto = this.vl_imposto.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
      this.vl_liquido = this.vl_liquido.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
    },
    limpaTotais() {
      this.valor = 0;
      this.qtd = 0;
      this.produtos = 0;
      this.valor_liquido = 0;
      this.vl_imposto = 0;
      this.vl_liquido = 0;
      this.vl_desconto_pedido = 0;
    },
    async onInitializedGrid() {
      setTimeout(async () => {
        await this.$refs.gridPadrao.instance.clearSelection();
        await this.$refs.gridPadrao.instance.clearFilter();
      }, 1);
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

<style scoped>
@import url("./views.css");
.card-cesta {
  display: flex;
  flex-wrap: wrap;
  font-weight: bold;
}

.opcoes {
  display: flex;
  flex-wrap: wrap;
  width: calc(100% / 8);
}

@media (max-width: 800px) {
  .opcoes {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
  }
}
</style>
