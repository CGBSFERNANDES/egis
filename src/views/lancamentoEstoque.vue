<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center">
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
    <div class="row">
      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-3"
        v-model="grupo_produto"
        :options="lookup_grupo_produto"
        option-value="cd_grupo_produto"
        option-label="nm_grupo_produto"
        label="Grupo de Produtos"
        @input="selecionaFiltro(grupo_produto, 'grupo_produto')"
      >
        <template v-slot:prepend>
          <q-icon name="group"></q-icon>
        </template>
      </q-select>

      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-3"
        v-model="categoria_produto"
        :options="lookup_categoria_produto"
        option-value="cd_categoria_produto"
        option-label="nm_categoria_produto"
        label="Categoria de Produtos"
        @input="selecionaFiltro(categoria_produto, 'categoria_produto')"
      >
        <template v-slot:prepend>
          <q-icon name="category"></q-icon>
        </template>
      </q-select>

      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-3"
        v-model="familia_produto"
        :options="lookup_familia_produto"
        option-value="cd_familia_produto"
        option-label="nm_familia_produto"
        label="Família de Produtos"
        @input="selecionaFiltro(familia_produto, 'familia_produto')"
      >
        <template v-slot:prepend>
          <q-icon name="family_restroom"></q-icon>
        </template>
      </q-select>
    </div>
    <div class="row">
      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-3"
        v-model="tipo_lancamento"
        :options="lookup_tipo_lancamento"
        option-value="cd_tipo_lancamento"
        option-label="nm_tipo_lancamento"
        label="Tipo de Lançamento"
      >
        <template v-slot:prepend>
          <q-icon name="inventory"></q-icon>
        </template>
      </q-select>

      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-3"
        v-model="fase_produto"
        :options="lookup_fase_produto"
        option-value="cd_fase_produto"
        option-label="nm_fase_produto"
        label="Fase do Produto"
      >
        <template v-slot:prepend>
          <q-icon name="inventory"></q-icon>
        </template>
      </q-select>

      <q-input
        class="margin1 col-2"
        rounded
        outlined
        stack-label
        type="date"
        v-model="dt_lancamento"
        label="Data do Lançamento"
      >
        <template v-slot:prepend>
          <q-icon name="event"></q-icon>
        </template>
      </q-input>
      <q-input
        class="margin1 col-2"
        rounded
        outlined
        v-model="ds_descricao"
        label="Observação"
      >
        <template v-slot:prepend>
          <q-icon name="folder"></q-icon>
        </template>
      </q-input>
      <div class="margin1 col-11">
        <Produto
          :ic_cadastro="false"
          :ic_mostra_titulo="false"
          :ic_mostra_selecao_data="false"
          @SelectProduto="SelecionaProduto($event)"
        />
      </div>
      <div class="margin1">
        <q-btn rounded color="primary" :label="`Produtos (${this.produtos})`">
        </q-btn>
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
          @click="onEnviarLancamento()"
        >
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            Enviar Lançamento
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
              <div class="margin1 borda-bloco col-2">
                {{ `Produtos: ${this.produtos ? this.produtos : ""}` }}
              </div>
              <div class="margin1 borda-bloco col-2">
                {{
                  `Grupo de Produto: ${
                    this.grupo_produto.nm_grupo_produto
                      ? this.grupo_produto.nm_grupo_produto
                      : ""
                  }`
                }}
              </div>
              <div class="margin1 borda-bloco col-2">
                {{
                  `Categoria de Produto: ${
                    this.categoria_produto.nm_categoria_produto
                      ? this.categoria_produto.nm_categoria_produto
                      : ""
                  }`
                }}
              </div>
              <div class="margin1 borda-bloco col-2">
                {{
                  `Família de Produto: ${
                    this.familia_produto.nm_familia_produto
                      ? this.familia_produto.nm_familia_produto
                      : ""
                  }`
                }}
              </div>
              <div class="margin1 borda-bloco col-2">
                {{
                  `Tipo de Lançamento: ${
                    this.tipo_lancamento.nm_tipo_lancamento
                      ? this.tipo_lancamento.nm_tipo_lancamento
                      : ""
                  }`
                }}
              </div>
              <div class="margin1 borda-bloco col-2">
                {{ `Data: ${this.dt_lancamento ? this.dt_lancamento : ""}` }}
              </div>
              <br />
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
      mostraGrid: true,
      //Somas
      produtos: 0,
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
      tipo_lancamento: "",
      lookup_tipo_lancamento: [],
      fase_produto: "",
      lookup_fase_produto: [],
      grupo_produto: "",
      lookup_grupo_produto: [],
      categoria_produto: "",
      lookup_categoria_produto: [],
      familia_produto: "",
      lookup_familia_produto: [],
      dt_lancamento: "",
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
    Produto: () => import("./produto.vue"),
  },

  async created() {
    let lookup_tipo_lancamento = await Lookup.montarSelect(
      this.cd_empresa,
      5902
    );
    this.lookup_tipo_lancamento = JSON.parse(
      JSON.parse(JSON.stringify(lookup_tipo_lancamento.dataset))
    );
    ////////////////////////
    let lookup_fase_produto = await Lookup.montarSelect(this.cd_empresa, 163);
    this.lookup_fase_produto = JSON.parse(
      JSON.parse(JSON.stringify(lookup_fase_produto.dataset))
    );
    ////////////////////////
    let lookup_grupo_produto = await Lookup.montarSelect(this.cd_empresa, 159);
    this.lookup_grupo_produto = JSON.parse(
      JSON.parse(JSON.stringify(lookup_grupo_produto.dataset))
    );
    ////////////////////////
    let lookup_categoria_produto = await Lookup.montarSelect(
      this.cd_empresa,
      261
    );
    this.lookup_categoria_produto = JSON.parse(
      JSON.parse(JSON.stringify(lookup_categoria_produto.dataset))
    );
    ////////////////////////
    let lookup_familia_produto = await Lookup.montarSelect(
      this.cd_empresa,
      3020
    );
    this.lookup_familia_produto = JSON.parse(
      JSON.parse(JSON.stringify(lookup_familia_produto.dataset))
    );
    ////////////////////////
    this.dt_lancamento = formataData.AnoMesDia(this.data_hoje);
    this.carregaDados();
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
    grupo_produto(val) {
      if (val) {
        this.categoria_produto = "";
        this.familia_produto = "";
      }
    },
    categoria_produto(val) {
      if (val) {
        this.grupo_produto = "";
        this.familia_produto = "";
      }
    },
    familia_produto(val) {
      if (val) {
        this.grupo_produto = "";
        this.categoria_produto = "";
      }
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

        this.qt_registro = this.dataSourceConfig
          ? this.dataSourceConfig.length
          : 0;
        this.dataSourceConfig = this.dataSourceConfig || [];
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
        if (e.dataField == "qt_digitacao" || e.dataField == "nm_lote") {
          e.allowEditing = true;
        } else {
          e.allowEditing = false;
        }
      });
      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //
    },

    async selecionaFiltro(value, param) {
      if (
        this.grupo_produto == "" &&
        this.categoria_produto == "" &&
        this.familia_produto == ""
      ) {
        this.dataSourceConfig = [];
        return;
      }
      if (param == "grupo_produto") {
        this.categoria_produto = "";
        this.familia_produto = "";
      }
      if (param == "categoria_produto") {
        this.grupo_produto = "";
        this.familia_produto = "";
      }
      if (param == "familia_produto") {
        this.grupo_produto = "";
        this.categoria_produto = "";
      }
      const json_filtra_produto = {
        cd_parametro: 0,
        cd_grupo_produto:
          this.grupo_produto && typeof this.grupo_produto === "object"
            ? this.grupo_produto.cd_grupo_produto
            : null,
        cd_categoria_produto:
          this.categoria_produto && typeof this.categoria_produto === "object"
            ? this.categoria_produto.cd_categoria_produto
            : null,
        cd_familia_produto:
          this.familia_produto && typeof this.familia_produto === "object"
            ? this.familia_produto.cd_familia_produto
            : null,
        cd_usuario: this.cd_usuario,
      };
      this.dataSourceConfig = await Incluir.incluirRegistro(
        localStorage.nm_identificacao_api,
        json_filtra_produto
      ); //pr_egisnet_lancamento_estoque
    },

    SelecionaProduto(e) {
      if (this.dataSourceConfig.length == 0) {
        this.dataSourceConfig.push({
          qt_digitacao: 0.0,
          sg_unidade_medida: e.Un,
          Disponivel: e.Disponivel,
          cd_produto: e.Cod_Produto,
          FANTASIA: e.Fantasia,
          DESCRICAO: e["Descrição"],
          CODIGO: e.Codigo,
          vl_custo: 0.0,
          nm_lote: "",
          cd_controle: e.cd_controle,
        });
        return;
      }
      if (
        !this.dataSourceConfig.find(
          (item) => item.cd_controle === e.cd_controle
        )
      ) {
        this.dataSourceConfig.push({
          qt_digitacao: 0.0,
          sg_unidade_medida: e.Un,
          Disponivel: e.Disponivel,
          cd_produto: e.Cod_Produto,
          FANTASIA: e.Fantasia,
          DESCRICAO: e["Descrição"],
          CODIGO: e.Codigo,
          vl_custo: 0.0,
          nm_lote: "",
          cd_controle: e.cd_controle,
        });
      } else {
        notify("Produto já adicionado!");
      }
    },

    async onEnviarLancamento() {
      try {
        await this.$refs.gridPadrao.instance.saveEditData();
        await funcao.sleep(1);
      } catch {
        notify("Salvando...");
      }
      if (!this.tipo_lancamento.cd_tipo_lancamento) {
        notify("Selecione um tipo de lançamento");
        return;
      }
      var json_envia_pedido = {
        cd_parametro: 1,
        dt_lancamento: this.dt_lancamento,
        ds_descricao: this.ds_descricao,
        cd_tipo_lancamento: this.tipo_lancamento
          ? this.tipo_lancamento.cd_tipo_lancamento
          : null,
        cd_fase_produto: this.fase_produto
          ? this.fase_produto.cd_fase_produto
          : null,
        cd_grupo_produto: this.grupo_produto
          ? this.grupo_produto.cd_grupo_produto
          : null,
        cd_categoria_produto: this.categoria_produto
          ? this.categoria_produto.cd_categoria_produto
          : null,
        cd_familia_produto: this.familia_produto
          ? this.familia_produto.cd_familia_produto
          : null,
        cd_usuario: this.cd_usuario,
        grid: this.dataCesta,
      };
      let [result_pedido] = await Incluir.incluirRegistro(
        localStorage.nm_identificacao_api,
        json_envia_pedido
      ); //pr_egisnet_lancamento_estoque
      if (result_pedido.Msg) {
        notify(`${result_pedido.Msg}`);
      } else {
        notify("Não foi possível enviar o lançamento");
      }
      await this.onCancelar();
      await this.selecionaFiltro();
    },
    async onCancelar() {
      this.ic_grid_cesta = true;
      await funcao.sleep(100);
      await this.carregaDados(true);
      await funcao.sleep(100);
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
    async onPDF() {
      await this.onCesta();
      await funcao.sleep(1);
      if (this.dataCesta.length > 0) {
        try {
          this.complemento_impressao = true;
          this.dt_lancamento = formataData.DiaMesAno(this.dt_lancamento);
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
        this.dt_lancamento = formataData.AnoMesDia(this.data_hoje);
      } else {
        notify("Insira pelo menos um item para gerar o relatório");
      }
    },
    attDataCesta() {
      this.produtos = this.dataCesta ? this.dataCesta.length : 0;
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
          this.dataCesta = this.dataCesta
            ? this.dataCesta.filter(
                (dropItem) => dropItem.cd_controle === i.data.cd_controle
              )
            : [];
          i.data.qt_digitacao = 0;
        }
        if (typeof i.data.qt_digitacao === "string") {
          i.data.qt_digitacao = funcao.RealParaInt(i.data.qt_digitacao);
        }
        if (
          i.data.qt_digitacao == 0 &&
          this.dataCesta.find((e) => e.cd_controle === i.data.cd_controle)
        ) {
          this.dataCesta = this.dataCesta
            ? this.dataCesta.filter(
                (dropItem) => dropItem.cd_controle !== i.data.cd_controle
              )
            : [];
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "qt_digitacao",
            0.0
          );
        }
        if (i.data.qt_digitacao > 0) {
          ////Verifica se a qtdade digitada é maior que o disponível
          // if (
          //   i.data.qt_digitacao > i.data.Disponivel &&
          //   i.data.Disponivel > 0
          // ) {
          //   this.$refs.gridPadrao.instance.cellValue(
          //     i.rowIndex,
          //     "qt_digitacao",
          //     i.data.Disponivel
          //   );
          //   i.data.qt_digitacao = i.data.Disponivel;
          // }
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
            if (
              alterouQtd.qt_digitacao != i.data.qt_digitacao ||
              alterouQtd.nm_lote != i.data.nm_lote
            ) {
              this.dataCesta[alterouQtd.index].qt_digitacao =
                i.data.qt_digitacao;
              this.dataCesta[alterouQtd.index].nm_lote = i.data.nm_lote;
              this.attDataCesta();
            }
          }
        }
      });
    },
    limpaTotais() {
      this.grupo_produto = "";
      this.categoria_produto = "";
      this.familia_produto = "";
      this.tipo_lancamento = "";
      this.fase_produto = "";
      this.dt_lancamento = formataData.AnoMesDia(this.data_hoje);
      this.ds_descricao = "";
      this.produtos = 0;
    },
    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Employees");

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
