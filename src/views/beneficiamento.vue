<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center">
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
    <!-- Produto -->
    <div>
      <produtoComprado
        :ic_cadastro="false"
        :ic_mostra_titulo="false"
        :ic_comprado="true"
        @SelectProduto="SelecionaProduto($event)"
      />
    </div>
    <!-- Produto -->
    <div class="row">
      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-2 opcoes"
        :disable="
          $store._mutations.SET_Usuario.ic_tipo_usuario === 'S' ? false : true
        "
        v-model="departamento"
        :options="lookup_forma_departamento"
        option-value="cd_departamento"
        option-label="nm_departamento"
        label="Departamento"
      >
        <template v-slot:prepend>
          <q-icon name="article"></q-icon>
        </template>
      </q-select>

      <q-input
        class="margin1 col-2 opcoes"
        rounded
        outlined
        stack-label
        type="date"
        v-model="dt_necessidade"
        label="Necessidade"
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
        v-if="1 == 2"
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
        v-if="1 == 2"
        rounded
        outlined
        bottom-slots
        class="margin1 col-2 opcoes"
        v-model="condicao_pagamento"
        :options="lookup_condicao_pagamento"
        option-value="cd_condicao_pagamento"
        option-label="nm_condicao_pagamento"
        label="Condição Pag"
      >
        <template v-slot:prepend>
          <q-icon name="attach_money"></q-icon>
        </template>
      </q-select>
      <q-select
        v-if="1 == 2"
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
      <div class="margin1">
        <q-btn-dropdown
          rounded
          color="primary"
          :label="`Total ${this.vl_total_produto_formatado}`"
        >
          <!-- <q-btn-dropdown rounded color="primary" :label="`Total ${this.vl_liquido}`"> -->
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

            <!-- <q-item clickable v-close-popup>
          <q-item-section>
            <q-item-label>{{`Imposto`}}</q-item-label>
          </q-item-section>
          <q-item-section side>
            <q-item-label>{{`${this.vl_imposto}`}}</q-item-label>
          </q-item-section>
        </q-item> -->

            <!-- <q-item clickable v-close-popup>
          <q-item-section>
            <q-item-label>{{`Total`}}</q-item-label>
          </q-item-section>
          <q-item-section side>
            <q-item-label>{{`${this.valor_formatado}`}}</q-item-label>
          </q-item-section>
        </q-item> -->

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
            Solicitação de Compras
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
          @click="onEnviarSolicitacao()"
        >
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            Enviar Solicitação
          </q-tooltip>
        </q-btn>
        <q-btn
          v-if="1 == 2"
          round
          class="margin1"
          color="green"
          text-color="white"
          icon="receipt_long"
        >
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            Enviar Proposta
          </q-tooltip>
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
              <!-- <div class="margin1 borda-bloco col-2">{{ `Quantidade: ${this.qtd ? this.qtd : ""}`}}</div> -->
              <div class="margin1 borda-bloco col-2">
                {{ `Qtd de Produtos: ${this.produtos ? this.produtos : ""}` }}
              </div>
              <!-- <div class="margin1 borda-bloco col-2">{{ `Total Bruto: ${this.valor_formatado ? this.valor_formatado : ""}` }}</div> -->
              <!-- <div class="margin1 borda-bloco col-2">{{ `Imposto: ${this.vl_imposto ? this.vl_imposto : ""}` }}</div> -->
              <div class="margin1 borda-bloco col-2">
                {{ `Total: ${this.vl_liquido ? this.vl_liquido : ""}` }}
              </div>
              <div class="margin1 borda-bloco col-2">
                {{
                  `Departamento: ${
                    this.departamento.cd_departamento
                      ? this.departamento.nm_departamento
                      : ""
                  }`
                }}
              </div>
              <div class="margin1 borda-bloco col-2">
                {{
                  `Necessidade: ${
                    this.dt_necessidade ? this.dt_necessidade : ""
                  }`
                }}
              </div>
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
            v-for="(i, index) in dataSourceConfig"
            :key="index"
          >
            <q-card-section>
              {{ `Qtd: ${i.qt_digitacao}` }} <br />
              {{ `Código: ${i.cd_mascara_produto}` }} <br />
              {{ `Produto: ${i.nm_produto}` }} <br />
              {{ `Un: ${i.sg_unidade_medida}` }} <br />
              {{
                `Total: ${
                  i.vl_total_item_formatado ? i.vl_total_item_formatado : "0"
                }`
              }}
              <br />
              <!-- {{ `Total Bruto: ${i.vl_total_item_formatado}` }} </br>
            {{ `Imposto: ${i.vl_total_icms_formatado}` }} </br>
            {{ `Total Liq: ${i.vl_unitario_liq_formatado}` }} </br> -->
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
      //Somas
      valor: 0,
      valor_formatado: 0,
      vl_imposto: 0,
      vl_liquido: 0,
      vl_total_produto: 0,
      vl_total_produto_formatado: 0,
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
      departamento: "",
      lookup_forma_departamento: [],
      frete: "",
      lookup_forma_frete: [],
      condicao_pagamento: "",
      lookup_forma_condicao_pagamento: [],
      transportadora: "",
      lookup_forma_transportadora: [],
      dt_necessidade: "",
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
    produtoComprado: () => import("../views/produto-comprado.vue"),
  },

  async created() {
    let lookup_forma_departamento = await Lookup.montarSelect(
      this.cd_empresa,
      726
    );
    this.lookup_forma_departamento = JSON.parse(
      JSON.parse(JSON.stringify(lookup_forma_departamento.dataset))
    );
    ////////////////////////
    let lookup_forma_frete = await Lookup.montarSelect(this.cd_empresa, 200);
    this.lookup_forma_frete = JSON.parse(
      JSON.parse(JSON.stringify(lookup_forma_frete.dataset))
    );
    ////////////////////////
    let lookup_condicao_pagamento = await Lookup.montarSelect(
      this.cd_empresa,
      308
    );
    this.lookup_condicao_pagamento = JSON.parse(
      JSON.parse(JSON.stringify(lookup_condicao_pagamento.dataset))
    );
    ////////////////////////
    let lookup_transportadora = await Lookup.montarSelect(this.cd_empresa, 297);
    this.lookup_transportadora = JSON.parse(
      JSON.parse(JSON.stringify(lookup_transportadora.dataset))
    );

    this.dt_necessidade = formataData.AnoMesDia(this.data_hoje);
    this.carregaDados();
    [this.departamento] = this.lookup_forma_departamento.filter(
      (d) =>
        d.cd_departamento == this.$store._mutations.SET_Usuario.cd_departamento
    );
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
      if (!showNotify) {
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
        this.dataSourceConfig = this.dataSourceConfig
          ? this.dataSourceConfig
          : [];
        this.qt_registro = this.dataSourceConfig.length;
      }
    },

    async showMenu() {
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
    async onEnviarSolicitacao() {
      try {
        await this.$refs.gridPadrao.instance.saveEditData();
        await funcao.sleep(1);
      } catch {
        notify("Salvando solicitação");
      }
      if (!this.departamento.cd_departamento) {
        notify("Selecione o Departamento");
        return;
      }
      var json_envia_pedido = {
        cd_departamento: this.departamento.cd_departamento
          ? this.departamento.cd_departamento
          : null,
        dt_necessidade: this.dt_necessidade,
        ds_descricao: this.ds_descricao,
        cd_cliente: this.cd_cliente,
        cd_usuario: this.cd_usuario,
        cd_contato: localStorage.cd_contato,
        grid: this.dataSourceConfig,
        ic_beneficiamento: "S",
      };
      let [result_pedido] = await Incluir.incluirRegistro(
        "870/1347", //this.api,
        json_envia_pedido
      ); //pr_egisnet_pedido_fabrica
      if (result_pedido != undefined && result_pedido.cd_requisicao_compra) {
        notify(
          `Solicitação ${result_pedido.cd_requisicao_compra} enviada com sucesso`
        );
      } else if (result_pedido.Msg) {
        notify(`${result_pedido.Msg}`);
      } else {
        notify("Não foi possível enviar a solicitação");
      }
      await this.onCancelar();
      this.carregaDados(true);
    },
    async onFaturar() {
      console.log("Faturar");
    },
    async onCancelar() {
      this.ic_grid_cesta = true;
      await funcao.sleep(1000);
      await this.carregaDados();
      //await this.gridPadrao.cancelEditData();
      await funcao.sleep(1000);
      this.dataCesta = [];
      this.dataSourceConfig = [];
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
    SelecionaProduto(e) {
      //Adiciona mais de um item
      if (e.length > 0) {
        e.forEach((item) => {
          if (
            this.dataSourceConfig.length == 0 ||
            !this.dataSourceConfig.find((i) => i.cd_produto === item.cd_produto)
          ) {
            this.dataSourceConfig.push(item);
          }
        });
      } else {
        //Adiciona um item
        if (
          this.dataSourceConfig.length == 0 ||
          !this.dataSourceConfig.find((i) => i.cd_produto === e.cd_produto)
        ) {
          this.dataSourceConfig.push(e);
        }
      }
    },
    async onPDF() {
      await this.onCesta();
      await funcao.sleep(1);
      if (this.dataSourceConfig.length > 0) {
        try {
          this.complemento_impressao = true;
          this.dt_necessidade = formataData.DiaMesAno(
            String(this.dt_necessidade + "T12:00")
          );
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
        this.dt_necessidade = formataData.AnoMesDia(this.data_hoje);
      } else {
        notify("Insira pelo menos um item para gerar o relatório");
      }
    },
    attDataCesta() {
      this.limpaTotais();
      this.produtos = this.dataSourceConfig.length;
      this.dataSourceConfig.map((c) => {
        c.vl_total_icms = parseFloat(c.vl_icms_st) * parseFloat(c.qt_digitacao);
        c.vl_unitario_icms =
          parseFloat(c.vl_produto) + parseFloat(c.vl_icms_st);
        c.vl_unitario_liq =
          parseFloat(c.vl_produto) * parseFloat(c.qt_digitacao);
        c.vl_total_item = parseFloat(c.qt_digitacao) * parseFloat(c.vl_produto);
        //+ parseFloat(c.qt_digitacao) * parseFloat(c.vl_icms_st);
        c.VL_PRODUTO_formatado = c.vl_produto.toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
        c.vl_total_item_formatado = c.vl_total_item
          ? parseFloat(c.vl_total_item).toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            })
          : 0;
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
        this.vl_total_produto += c.vl_unitario_liq;
        this.valor += c.vl_total_item; //+ c.vl_total_icms;
        this.vl_imposto += c.vl_total_icms;
        this.vl_liquido += c.vl_total_item;
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
          //this.$refs.gridPadrao.instance.cellValue(i.rowIndex, "vl_total_liquido", 0.00);
          //this.$refs.gridPadrao.instance.cellValue(i.rowIndex, "vl_total_icms", 0.00);
          //this.dataSourceConfig = this.dataSourceConfig.filter((dropItem) => dropItem.cd_controle === i.data.cd_controle);
          i.data.qt_digitacao = 0;
        }
        if (typeof i.data.qt_digitacao === "string") {
          i.data.qt_digitacao = funcao.RealParaInt(i.data.qt_digitacao);
        }
        if (typeof i.data.vl_produto === "string") {
          i.data.vl_produto = funcao.RealParaInt(i.data.vl_produto);
        }
        // if(typeof i.data.vl_icms_st === 'string'){
        //   i.data.vl_icms_st = funcao.RealParaInt(i.data.vl_icms_st)
        // }
        if (
          i.data.qt_digitacao == 0 &&
          this.dataSourceConfig.find(
            (e) => e.cd_controle === i.data.cd_controle
          )
        ) {
          //this.dataSourceConfig = this.dataSourceConfig.filter((dropItem) => dropItem.cd_controle !== i.data.cd_controle);
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
          //this.$refs.gridPadrao.instance.cellValue(i.rowIndex, "vl_total_liquido", 0.00);
          //this.$refs.gridPadrao.instance.cellValue(i.rowIndex, "vl_total_icms", 0.00);
        }
        if (i.data.qt_digitacao > 0) {
          ////Verifica se a qtdade digitada é maior que o disponível
          if (
            i.data.qt_digitacao > i.data.Disponivel &&
            i.data.Disponivel > 0
          ) {
            this.$refs.gridPadrao.instance.cellValue(
              i.rowIndex,
              "qt_digitacao",
              i.data.Disponivel
            );
            i.data.qt_digitacao = i.data.Disponivel;
          }
          if (
            this.dataSourceConfig.length == 0 ||
            !this.dataSourceConfig.find(
              (e) => e.cd_controle === i.data.cd_controle
            )
          ) {
            this.dataSourceConfig.push(i.data);
          } else {
            let alterouQtd = this.dataSourceConfig.find(
              (e) => e.cd_controle === i.data.cd_controle
            );
            alterouQtd.index = this.dataSourceConfig.findIndex(
              (e) => e.cd_controle === i.data.cd_controle
            );
            if (alterouQtd.qt_digitacao != i.data.qt_digitacao) {
              this.dataSourceConfig[alterouQtd.index].qt_digitacao =
                i.data.qt_digitacao;
              this.attDataCesta();
            }
          }
          let vl_total_item =
            i.data.qt_digitacao.toFixed(2) * i.data.vl_produto.toFixed(2);
          //+ i.data.qt_digitacao.toFixed(2) * i.data.vl_icms_st;
          //let vl_total_liquido = i.data.qt_digitacao.toFixed(2) * i.data.vl_produto.toFixed(2)
          //let vl_total_icms = i.data.qt_digitacao.toFixed(2) * i.data.vl_icms_st;
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_item",
            vl_total_item
          );
          //this.$refs.gridPadrao.instance.cellValue(i.rowIndex, "vl_total_liquido", vl_total_liquido);
          //this.$refs.gridPadrao.instance.cellValue(i.rowIndex, "vl_total_icms", vl_total_icms);
        }
      });
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
/* table, th, td {
  border: 1px solid #6F6F6F; 
  border-collapse: collapse;
} */

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
