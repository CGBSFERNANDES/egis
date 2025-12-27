<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center">
      <btnVoltarHome />
      <transition name="slide-fade">
        <h2 class="content-block col-8" v-show="tituloMenu">
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
    <!-- Cliente -->
    <div class="margin1">
      <cliente
        :cd_usuario="cd_usuario"
        @SelectCliente="SelecionaCliente($event)"
        @limpaCliente="cleanCliente($event)"
        :ic_pesquisa="true"
        :ic_pesquisa_contato="false"
      />
    </div>
    <!-- Cliente -->
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
        @input="CalculaDesconto()"
      >
        <template v-slot:prepend>
          <q-icon name="attach_money"></q-icon>
        </template>
        <template v-slot:hint>
          <transition name="slide-fade">
            <div
              style="font-weight: bold"
              v-if="forma_pagamento && forma_pagamento.pc_desconto_pedido > 0"
            >
              {{
                `${
                  forma_pagamento && forma_pagamento.pc_desconto_pedido
                }% de Desconto`
              }}
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
        label="Observação"
      >
        <template v-slot:prepend>
          <q-icon name="folder"></q-icon>
        </template>
      </q-input>
      <q-select
        v-if="false"
        rounded
        outlined
        bottom-slots
        class="margin1 col-2 opcoes"
        v-model="frete"
        :options="lookup_forma_frete"
        option-value="cd_tipo_frete"
        option-label="nm_tipo_frete"
        label="Tipo de Frete"
      >
        <template v-slot:prepend>
          <q-icon name="local_shipping"></q-icon>
        </template>
        <template v-slot:hint> </template>
      </q-select>
      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-2 opcoes"
        v-model="condicao_pagamento"
        :options="lookup_condicao_pagamento"
        option-value="cd_condicao_pagamento"
        option-label="nm_condicao_pagamento"
        :readonly="ic_edita_condicao_pagamento"
        label="Condição Pag"
      >
        <template v-slot:prepend>
          <q-icon name="attach_money"></q-icon>
        </template>
      </q-select>
      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-2 opcoes"
        v-model="transportadora"
        :options="lookup_transportadora"
        option-value="cd_transportadora"
        option-label="nm_transportadora"
        label="Transportadora"
      >
        <template v-slot:prepend>
          <q-icon name="local_shipping"></q-icon>
        </template>
      </q-select>

      <q-input
        class="margin1 col-2 opcoes"
        rounded
        outlined
        v-model="vl_sinal"
        label="Valor Adiantamento"
        type="number"
        min="0"
        prefix="R$ "
      >
        <template v-slot:prepend>
          <q-icon name="attach_money"></q-icon>
        </template>
      </q-input>

      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-2 opcoes"
        v-model="tipo_pedido"
        :options="lookup_tipo_pedido"
        option-value="cd_tipo_pedido"
        option-label="nm_tipo_pedido"
        label="Tipo de Pedido"
      >
        <template v-slot:prepend>
          <q-icon name="bookmark"></q-icon>
        </template>
        <template v-slot:no-option>
          <q-item>
            <q-item-section class="text-grey"> Sem Opções </q-item-section>
          </q-item>
        </template>
      </q-select>

      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-2 opcoes"
        v-model="destinacao_produto"
        :options="lookup_destinacao_produto"
        option-value="cd_destinacao_produto"
        option-label="nm_destinacao_produto"
        label="Destinação"
      >
        <template v-slot:prepend>
          <q-icon name="bookmark"></q-icon>
        </template>
        <template v-slot:no-option>
          <q-item>
            <q-item-section class="text-grey"> Sem Opções </q-item-section>
          </q-item>
        </template>
      </q-select>

      <q-toggle
        class="margin1 col-2 opcoes"
        v-model="ic_gera_pedido_venda"
        true-value="S"
        false-value="N"
        color="primary"
        label="Gera Pedido de Venda"
      />
      <div class="margin1">
        <q-btn-dropdown
          rounded
          color="primary"
          :label="`Total ${this.vl_liquido}`"
        >
          <q-list class="text-weight-bold">
            <q-item clickable v-close-popup>
              <q-item-section>
                <q-item-label>{{ `Produtos` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{ `${this.produtos}` }}</q-item-label>
              </q-item-section>
            </q-item>

            <q-item clickable v-close-popup>
              <q-item-section>
                <q-item-label>{{ `Total Produto` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{
                  `${this.vl_total_produto_formatado}`
                }}</q-item-label>
              </q-item-section>
            </q-item>

            <q-item clickable v-close-popup>
              <q-item-section>
                <q-item-label>{{ `Imposto` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{ `${this.vl_imposto}` }}</q-item-label>
              </q-item-section>
            </q-item>

            <q-item clickable v-close-popup>
              <q-item-section>
                <q-item-label>{{ `Total` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{ `${this.valor_formatado}` }}</q-item-label>
              </q-item-section>
            </q-item>

            <q-item
              v-if="vl_desconto_pedido"
              style="color: red"
              clickable
              v-close-popup
            >
              <q-item-section>
                <q-item-label>{{ `Desconto` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{ `${this.vl_desconto_pedido}` }}</q-item-label>
              </q-item-section>
            </q-item>

            <q-item
              v-if="valor_liquido"
              style="color: red"
              clickable
              v-close-popup
            >
              <q-item-section>
                <q-item-label>{{ `Líquido` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{ `${this.valor_liquido}` }}</q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
        </q-btn-dropdown>
      </div>

      <div style="display: block">
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
          icon="description"
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
        <q-btn
          class="margin1"
          icon="img:/whatsapp.svg"
          round
          @click="onEnviarWhatsApp(d)"
          color="green"
        >
          <q-tooltip> Enviar WhatsApp </q-tooltip>
        </q-btn>
        <q-btn
          v-if="1 == 2"
          round
          class="margin1"
          color="black"
          text-color="white"
          icon="request_page"
          @click="onFaturar()"
        >
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            Faturar
          </q-tooltip>
        </q-btn>
      </div>
    </div>
    <div v-if="mostraGrid">
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
            @cell-prepared="onCellPrepared"
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
              <!-- <div class="margin1 borda-bloco col-2">{{ `Quantidade: ${this.qtd ? this.qtd : ""}`}}</div> -->
              <div class="margin1 borda-bloco col-2">
                {{ `Produtos: ${this.produtos ? this.produtos : ""}` }}
              </div>
              <div class="margin1 borda-bloco col-2">
                {{
                  `Total Bruto: ${
                    this.valor_formatado ? this.valor_formatado : ""
                  }`
                }}
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
            {{ `Observação: ${this.ds_descricao}` }}
          </div>
        </div>
        <div class="card-cesta row">
          <q-card
            class="margin1 borda-bloco shadow-2 col-3 bg-grey-4"
            v-for="(i, index) in dataCesta"
            :key="index"
          >
            <q-card-section>
              {{ `Código: ${i.CODIGO}` }} <br />
              {{ `Produto: ${i.DESCRICAO}` }} <br />
              {{ `Un: ${i.sg_unidade_medida}` }} <br />
              {{ `Qtd: ${i.qt_digitacao}` }} <br />
              {{ `Total Bruto: ${i.vl_total_item_formatado}` }} <br />
              {{ `Imposto: ${i.vl_total_icms_formatado}` }} <br />
              {{ `Total Liq: ${i.vl_unitario_liq_formatado}` }} <br />
            </q-card-section>
          </q-card>
        </div>
      </div>
    </transition>
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
import select from "../http/select";

var dados = [];
let filename = "DataGrid.xlsx";
var sParametroApi = "";

export default {
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_cliente: localStorage.cd_cliente,
      cd_modulo: localStorage.cd_modulo,
      cd_menu: localStorage.cd_menu,
      cd_api: localStorage.cd_api,
      api: "",
      mostraGrid: false,
      ic_gera_pedido_venda: "N",
      ic_edita_condicao_pagamento:
        this.$store._mutations.SET_Usuario.ic_edita_condicao_pagamento === "S"
          ? true
          : false,
      //Somas
      valor: 0,
      valor_formatado: 0,
      vl_total_produto: 0,
      vl_total_produto_formatado: 0,
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
      frete: "",
      lookup_forma_frete: [],
      condicao_pagamento: "",
      lookup_condicao_pagamento: [],
      transportadora: "",
      lookup_transportadora: [],
      tipo_pedido: "",
      lookup_tipo_pedido: [],
      destinacao_produto: "",
      lookup_destinacao_produto: [],
      vl_sinal: "0",
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
    if (this.lookup_forma_pagamento && this.lookup_forma_pagamento.length > 0) {
      this.lookup_forma_pagamento = this.lookup_forma_pagamento.filter((e) => {
        return e.ic_selecao_pedido === "S" && !!e.nm_forma_pagamento;
      });
    }
    ////////////////////////
    let lookup_forma_frete = await Lookup.montarSelect(this.cd_empresa, 200);
    this.lookup_forma_frete = JSON.parse(
      JSON.parse(JSON.stringify(lookup_forma_frete.dataset))
    );
    if (this.lookup_forma_frete && this.lookup_forma_frete.length > 0) {
      this.lookup_forma_frete = this.lookup_forma_frete.filter((t) => {
        return !!t.nm_tipo_frete;
      });
    }
    ////////////////////////
    let lookup_condicao_pagamento = await Lookup.montarSelect(
      this.cd_empresa,
      308
    );
    this.lookup_condicao_pagamento = JSON.parse(
      JSON.parse(JSON.stringify(lookup_condicao_pagamento.dataset))
    );
    if (
      this.lookup_condicao_pagamento &&
      this.lookup_condicao_pagamento.length > 0
    ) {
      this.lookup_condicao_pagamento = this.lookup_condicao_pagamento.filter(
        (e) => {
          return (
            (e.ic_ativo === "S" && e.ic_tipo_cond_pagamento === "T") ||
            (e.ic_tipo_cond_pagamento === "V" &&
              e.ic_ecommerce === "S" &&
              !!e.nm_condicao_pagamento)
          );
        }
      );
    }
    ////////////////////////
    let lookup_transportadora = await Lookup.montarSelect(this.cd_empresa, 297);
    if (lookup_transportadora.dataset) {
      this.lookup_transportadora = JSON.parse(
        JSON.parse(JSON.stringify(lookup_transportadora.dataset))
      );
      if (this.lookup_transportadora && this.lookup_transportadora.length > 0) {
        this.lookup_transportadora = this.lookup_transportadora.filter((t) => {
          return !!t.nm_transportadora;
        });
      }
    }
    ////////////////////////
    let lookup_tipo_pedido = await Lookup.montarSelect(this.cd_empresa, 202);
    if (lookup_tipo_pedido.dataset) {
      this.lookup_tipo_pedido = JSON.parse(
        JSON.parse(JSON.stringify(lookup_tipo_pedido.dataset))
      );
      if (this.lookup_tipo_pedido && this.lookup_tipo_pedido.length > 0) {
        this.lookup_tipo_pedido = this.lookup_tipo_pedido.filter((t) => {
          return !!t.nm_tipo_pedido;
        });
      }
    }
    ////////////////////////
    let lookup_destinacao_produto = await Lookup.montarSelect(
      this.cd_empresa,
      227
    );
    if (lookup_destinacao_produto.dataset) {
      this.lookup_destinacao_produto = JSON.parse(
        JSON.parse(JSON.stringify(lookup_destinacao_produto.dataset))
      );
      if (
        this.lookup_destinacao_produto &&
        this.lookup_destinacao_produto.length > 0
      ) {
        this.lookup_destinacao_produto = this.lookup_destinacao_produto.filter(
          (t) => {
            return !!t.nm_destinacao_produto;
          }
        );
      }
    }
    ////////////////////////
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

  watch: {
    dataCesta() {
      this.attDataCesta();
    },
  },

  methods: {
    async carregaDados(showNotify) {
      localStorage.cd_identificacao = 0;
      await this.showMenu();
      if (showNotify !== true) {
        notify("Aguarde... estamos montando a consulta para você!");
      }
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
          // eslint-disable-next-line no-console
          console.error(error);
        }

        this.qt_registro = this.dataSourceConfig.length;
      }
    },
    async showMenu() {
      this.cd_api = localStorage.cd_api || "0";
      this.api = localStorage.nm_identificacao_api || "0";
      localStorage.cd_parametro = 0;
      this.cd_menu = this.cd_menu == "0" ? 7718 : this.cd_menu;
      this.cd_api = this.cd_api == "0" ? 868 : this.cd_api;
      this.api = this.api == "0" ? "868/1345" : this.api;
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
        if (
          e.dataField == "qt_digitacao" ||
          e.dataField == "VL_PRODUTO" ||
          e.dataField == "sg_unidade_medida"
        ) {
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
      //Validação para NÃO salvar item com VL_PRODUTO = 0
      this.dataCesta.map((item) => {
        if (item.VL_PRODUTO == 0) {
          return notify("Existem produto(s) com valores zerados!");
        }
      });
      var json_envia_pedido = {
        cd_forma_pagamento: this.forma_pagamento
          ? this.forma_pagamento.cd_forma_pagamento
          : null,
        cd_tipo_frete: this.frete ? this.frete.cd_tipo_frete : null,
        cd_condicao_pagamento: this.condicao_pagamento
          ? this.condicao_pagamento.cd_condicao_pagamento
          : null,
        cd_transportadora: this.transportadora
          ? this.transportadora.cd_transportadora
          : null,
        cd_tipo_pedido: this.tipo_pedido
          ? this.tipo_pedido.cd_tipo_pedido
          : null,
        cd_destinacao_produto: this.destinacao_produto
          ? this.destinacao_produto.cd_destinacao_produto
          : null,
        vl_sinal: this.vl_sinal ? parseFloat(this.vl_sinal) : 0,
        ic_gera_pedido_venda: this.ic_gera_pedido_venda,
        dt_entrega: this.dt_entrega,
        hr_entrega: this.hr_entrega,
        ds_descricao: this.ds_descricao,
        cd_cliente: this.cd_cliente,
        cd_usuario: this.cd_usuario,
        cd_contato: localStorage.cd_contato,
        ic_limite_credito: this.$store._mutations.SET_Usuario.ic_limite_credito,
        grid: this.dataCesta,
      };
      let [result_pedido] = await Incluir.incluirRegistro(
        "842/1319", //this.api,
        json_envia_pedido
      ); //pr_egisnet_pedido_fabrica
      if (result_pedido != undefined && result_pedido.cd_consulta) {
        notify(`Proposta ${result_pedido.cd_consulta} enviada com sucesso`);
      } else if (result_pedido.Msg) {
        notify(`${result_pedido.Msg}`);
      } else {
        notify("Não foi possível enviar a proposta");
      }
      this.cleanCliente();
      await this.onCancelar();
      this.carregaDados(true);
    },
    async onEnviarWhatsApp() {
      //console.log('Funcionalidade WhatsApp em desenvolvimento...')
    },
    async onFaturar() {
      //console.log('Faturar')
    },
    async onCancelar() {
      this.ic_grid_cesta = true;
      await funcao.sleep(1000);
      await this.carregaDados(true);
      //await this.gridPadrao.cancelEditData();
      await funcao.sleep(1000);
      this.dataCesta = [];
      this.ic_grid_cesta = false;
      this.complemento_impressao = false;
      this.limpaTotais();
    },
    async onCesta() {
      try {
        await this.$refs.gridPadrao.instance.saveEditData();
        await funcao.sleep(1);
      } catch {
        notify("Aguarde...");
      }
      this.ic_grid_cesta = !this.ic_grid_cesta;
    },
    async SelecionaCliente(e) {
      let forma_pag_json = {
        cd_empresa: this.cd_empresa,
        cd_tabela: 120,
        order: "D",
        where: [{ cd_cliente: e.cd_cliente }],
      };
      let [forma_pagamento_cliente] = await select.montarSelect(
        this.cd_empresa,
        forma_pag_json
      );
      if (forma_pagamento_cliente.dataset) {
        [forma_pagamento_cliente] = JSON.parse(
          JSON.parse(JSON.stringify(forma_pagamento_cliente.dataset))
        );
      }
      if (
        this.lookup_forma_pagamento &&
        this.lookup_forma_pagamento.length > 0
      ) {
        let [form_pag] = this.lookup_forma_pagamento.filter(
          (fp) =>
            fp.cd_forma_pagamento == forma_pagamento_cliente.cd_forma_pagamento
        );
        this.forma_pagamento = form_pag;
      }
      if (
        this.lookup_condicao_pagamento &&
        this.lookup_condicao_pagamento.length > 0
      ) {
        let [cond_pag] = this.lookup_condicao_pagamento.filter(
          (cp) => cp.cd_condicao_pagamento == e.cd_condicao_pagamento
        );
        this.condicao_pagamento = cond_pag;
      }
      if (this.lookup_transportadora && this.lookup_transportadora.length > 0) {
        let [transp] = this.lookup_transportadora.filter(
          (tr) => tr.cd_transportadora == e.cd_transportadora
        );
        this.transportadora = transp;
      }
      if (this.lookup_tipo_pedido && this.lookup_tipo_pedido.length > 0) {
        let [tipo_ped] = this.lookup_tipo_pedido.filter(
          (tr) => tr.cd_tipo_pedido == e.cd_tipo_pedido
        );
        this.tipo_pedido = tipo_ped;
      }
      if (
        this.lookup_destinacao_produto &&
        this.lookup_destinacao_produto.length > 0
      ) {
        let [destinacao_prod] = this.lookup_destinacao_produto.filter(
          (tr) => tr.cd_destinacao_produto == e.cd_destinacao_produto
        );
        this.destinacao_produto = destinacao_prod;
      }
      //this.forma_pagamento = this.lookup_forma_pagamento.filter((p) => p.cd_forma_pagamento == e.cd_forma_pagamento)
      localStorage.cd_tabela_preco = e.cd_tabela_preco;
      this.cd_cliente = e.cd_cliente;
      await this.carregaDados();
      this.mostraGrid = true;
    },
    cleanCliente() {
      this.forma_pagamento = "";
      this.condicao_pagamento = "";
      this.transportadora = "";
      this.tipo_pedido = "";
      this.destinacao_produto = "";
      this.vl_sinal = "0";
      this.ic_gera_pedido_venda = "N";
      this.dataSourceConfig = [];
      this.qt_registro = 0;
    },
    CalculaDesconto() {
      if (this.forma_pagamento && this.forma_pagamento.pc_desconto_pedido) {
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
    },
    async onPDF() {
      await this.onCesta();
      await funcao.sleep(1);
      if (this.dataCesta.length > 0) {
        try {
          this.complemento_impressao = true;
          this.dt_entrega = formataData.DiaMesAno(this.dt_entrega);
          this.ic_grid_cesta = true;
          await funcao.sleep(1000);
          this.loadingPDF = true;
          let html = document.getElementById("cesta");
          //Configura o PDF que será baixado.
          let config = {
            orientation: "p",
            unit: "mm",
            format: [1480, 1880], //y 1480
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
        this.dt_entrega = formataData.AnoMesDia(this.data_hoje);
      } else {
        notify("Insira pelo menos um item para gerar o relatório");
      }
    },
    attDataCesta() {
      this.limpaTotais();
      this.produtos = this.dataCesta.length;
      this.dataCesta.map((c) => {
        c.vl_total_icms = parseFloat(c.vl_icms_st) * parseFloat(c.qt_digitacao);
        c.vl_unitario_icms =
          parseFloat(c.VL_PRODUTO) + parseFloat(c.vl_icms_st);
        c.vl_unitario_liq =
          parseFloat(c.VL_PRODUTO) * parseFloat(c.qt_digitacao);
        c.qt_peso_bruto = isNaN(c.qt_peso_bruto_fixo)
          ? 0
          : c.qt_peso_bruto_fixo * c.qt_digitacao;
        c.vl_total_kg = c.qt_peso_bruto * c.VL_PRODUTO;
        c.vl_total_item =
          c.ic_peso_produto == "S" && parseFloat(c.qt_digitacao) > 0
            ? c.vl_total_kg
            : parseFloat(c.qt_digitacao) * parseFloat(c.VL_PRODUTO) +
              parseFloat(c.qt_digitacao) * parseFloat(c.vl_icms_st);
        c.VL_PRODUTO_formatado = c.VL_PRODUTO.toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
        c.vl_total_item_formatado = parseFloat(c.vl_total_item).toLocaleString(
          "pt-BR",
          {
            style: "currency",
            currency: "BRL",
          }
        );
        c.vl_icms_st_formatado = parseFloat(c.vl_icms_st).toLocaleString(
          "pt-BR",
          {
            style: "currency",
            currency: "BRL",
          }
        );
        c.vl_total_icms_formatado = parseFloat(c.vl_total_icms).toLocaleString(
          "pt-BR",
          {
            style: "currency",
            currency: "BRL",
          }
        );
        c.vl_unitario_icms_formatado = parseFloat(
          c.vl_unitario_icms
        ).toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
        c.vl_unitario_liq_formatado = parseFloat(
          c.vl_unitario_liq
        ).toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
        this.vl_total_produto +=
          c.ic_peso_produto == "S" ? c.vl_total_item : c.vl_unitario_liq;
        this.valor += c.vl_total_item; //+ c.vl_total_icms;
        this.vl_imposto += c.vl_total_icms;
        this.vl_liquido += c.vl_total_kg;
      });
      this.vl_total_produto_formatado = this.vl_total_produto.toLocaleString(
        "pt-BR",
        {
          style: "currency",
          currency: "BRL",
        }
      );
      this.valor_formatado = this.valor.toLocaleString("pt-BR", {
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
    async attQtd(e) {
      await funcao.sleep(1);
      e.rows.map((i) => {
        if (
          i.data.qt_digitacao == null ||
          i.data.qt_digitacao == undefined ||
          i.data.qt_digitacao < 0
        ) {
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "qt_digitacao",
            0.0
          );
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_item",
            0.0
          );
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_liquido",
            0.0
          );
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_icms",
            0.0
          );
          this.dataCesta = this.dataCesta.filter(
            (dropItem) => dropItem.cd_controle === i.data.cd_controle
          );
          i.data.qt_digitacao = 0;
        }
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
          ////Verifica se a qtdade digitada é maior que o disponível
          if (
            i.data.qt_digitacao > i.data.Disponivel &&
            i.data.Disponivel > 0 &&
            i.data.ic_libera_estoque !== "S"
          ) {
            this.$refs.gridPadrao.instance.cellValue(
              i.rowIndex,
              "qt_digitacao",
              i.data.Disponivel
            );
            i.data.qt_digitacao = i.data.Disponivel;
          }
          if (
            this.dataCesta.length == 0 ||
            !this.dataCesta.find((e) => e.cd_controle === i.data.cd_controle)
          ) {
            this.dataCesta.push(i.data);
          } else {
            let alterouQtd = this.dataCesta.find(
              (e) => e.cd_controle === i.data.cd_controle
            );
            alterouQtd.index = this.dataCesta.findIndex(
              (e) => e.cd_controle === i.data.cd_controle
            );
            let peso_calculado = isNaN(i.data.qt_peso_bruto_fixo)
              ? 0
              : i.data.qt_peso_bruto_fixo * i.data.qt_digitacao;
            let vl_total_em_kg = peso_calculado * i.data.VL_PRODUTO;
            this.$refs.gridPadrao.instance.cellValue(
              i.rowIndex,
              "qt_peso_bruto",
              peso_calculado
            );
            this.$refs.gridPadrao.instance.cellValue(
              i.rowIndex,
              "vl_total_kg",
              vl_total_em_kg
            );
            if (alterouQtd.qt_digitacao != i.data.qt_digitacao) {
              this.dataCesta[alterouQtd.index].qt_digitacao =
                i.data.qt_digitacao;
              this.attDataCesta();
            }
            if (alterouQtd.VL_PRODUTO != i.data.VL_PRODUTO) {
              this.dataCesta[alterouQtd.index].VL_PRODUTO = i.data.VL_PRODUTO;
              this.attDataCesta();
            }
          }
          //Regra Unidade de Medida (Calculo de conversao) --Alinhar com o Fabiano
          var vl_total_item = 0;
          var vl_total_liquido = 0;
          var vl_total_icms = 0;
          if (typeof i.data.qt_multiplo_embalagem > 1) {
            vl_total_item =
              i.data.qt_digitacao.toFixed(2) * i.data.VL_PRODUTO.toFixed(2) +
              i.data.qt_digitacao.toFixed(2) *
                i.data.vl_icms_st *
                i.data.qt_multiplo_embalagem;
            vl_total_liquido =
              i.data.qt_digitacao.toFixed(2) *
              i.data.VL_PRODUTO.toFixed(2) *
              i.data.qt_multiplo_embalagem;
            vl_total_icms =
              i.data.qt_digitacao.toFixed(2) *
              i.data.vl_icms_st *
              i.data.qt_multiplo_embalagem;
          } else {
            vl_total_item =
              i.data.qt_digitacao.toFixed(2) * i.data.VL_PRODUTO.toFixed(2) +
              i.data.qt_digitacao.toFixed(2) * i.data.vl_icms_st;
            vl_total_liquido =
              i.data.qt_digitacao.toFixed(2) * i.data.VL_PRODUTO.toFixed(2);
            vl_total_icms = i.data.qt_digitacao.toFixed(2) * i.data.vl_icms_st;
          }
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
        }
      });
      this.CalculaDesconto();
    },
    limpaTotais() {
      this.valor = 0;
      this.qtd = 0;
      this.produtos = 0;
      this.valor_liquido = 0;
      this.valor_formatado = 0;
      this.vl_total_produto = 0;
      this.vl_total_produto_formatado = 0;
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
    onCellPrepared(e) {
      let paintRow = this.dataSourceConfig.slice(0, 10);
      if (e.rowType === "data" && e.rowIndex <= 10) {
        if (paintRow.find((el) => el.cd_controle === e.data.cd_controle)) {
          e.cellElement.style.cssText = "background-color: #73ADEB";
        }
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
