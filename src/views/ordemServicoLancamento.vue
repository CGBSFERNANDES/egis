<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center">
      <transition name="slide-fade">
        <h2
          class="content-block col-8"
          v-show="!!tituloMenu != false && ic_mostra_titulo"
        >
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
        :cd_cliente_c="cd_cliente_param"
        :cd_consulta="true"
        :att_endereco="cep_encontrado"
        @SelectCliente="SelecionaCliente($event)"
        :ic_pesquisa="true"
        @LocalEntrega="SelecionaLocalEntrega($event)"
        @ClienteContato="OnContato($event)"
      />
    </div>
    <!-- Cliente -->
    <div class="row">
      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-2 opcoes"
        v-model="prioridade"
        :options="lookup_prioridade"
        option-value="cd_tipo_prioridade"
        option-label="nm_tipo_prioridade"
        label="Prioridade"
      >
        <template v-slot:prepend>
          <q-icon name="list"></q-icon>
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
          <q-icon name="schedule"></q-icon>
        </template>
      </q-input>
      <q-input
        class="margin1 col-2 opcoes"
        rounded
        outlined
        v-model="ds_ordem_servico"
        label="Observação"
      >
        <template v-slot:prepend>
          <q-icon name="description"></q-icon>
        </template>
      </q-input>

      <q-input
        class="margin1 col-2 opcoes"
        rounded
        outlined
        v-model="ds_complemento"
        label="Complemento"
      >
        <template v-slot:prepend>
          <q-icon name="article"></q-icon>
        </template>
      </q-input>

      <q-select
        rounded
        outlined
        bottom-slots
        class="margin1 col-2 opcoes"
        v-model="tipo_endereco"
        :options="lookup_tipo_endereco"
        option-value="cd_tipo_endereco"
        option-label="nm_tipo_endereco"
        label="Tipo de Endereço"
      >
        <template v-slot:prepend>
          <q-icon name="filter_list"></q-icon>
        </template>
      </q-select>

      <q-input
        class="margin1 col-2 opcoes"
        rounded
        outlined
        v-model="nm_ponto_referencia"
        label="Ponto de Referência"
      >
        <template v-slot:prepend>
          <q-icon name="location_city"></q-icon>
        </template>
      </q-input>

      <q-input
        class="margin1 col-2 opcoes"
        rounded
        outlined
        v-model="ds_endereco_entrega_os"
        label="CEP de Entrega para Ordem de Serviço"
        debounce="1000"
        @input="onCEP()"
      >
        <template v-slot:prepend>
          <q-icon name="location_on"></q-icon>
        </template>
      </q-input>

      <div class="margin1">
        <!-- <q-btn-dropdown rounded color="primary" :label="`Total ${this.vl_liquido}`"> -->
        <q-btn-dropdown
          rounded
          color="primary"
          :label="`Total ${this.vl_total_produto_formatado}`"
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
          v-if="ic_mostra_produtos"
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
            Cesta da Ordem de Serviço
          </q-tooltip>
        </q-btn>
        <q-btn
          rounded
          class="margin1"
          color="red"
          text-color="white"
          icon="undo"
          label="Cancelar"
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
          rounded
          class="margin1"
          color="green"
          text-color="white"
          icon="save"
          label="Salvar"
          @click="onEnviarPedido()"
        >
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            Enviar Ordem de Serviço
          </q-tooltip>
        </q-btn>

        <q-toggle
          v-model="ic_libera_producao"
          label="Liberar Produção"
          color="orange-9"
        />
      </div>
    </div>
    <transition name="slide-fade">
      <q-expansion-item
        v-if="cep_encontrado.cep"
        class="margin1 shadow-1 overflow-hidden"
        style="border-radius: 30px"
        header-class="bg-primary text-white"
        expand-icon-class="text-white"
        icon="local_shipping"
        label="Endereço de Entrega"
      >
        <q-card>
          <q-card-section class="row">
            <q-input
              class="margin1 col"
              dense
              rounded
              standout
              readonly
              v-model="cep_encontrado.cep"
              label="CEP"
            />
            <q-input
              class="margin1 col"
              dense
              rounded
              standout
              readonly
              v-model="cep_encontrado.logradouro"
              label="Endereço"
            />
            <q-input
              class="margin1 col"
              dense
              rounded
              standout
              v-model="cep_encontrado.numero"
              label="Número"
            />
            <q-input
              class="margin1 col"
              dense
              rounded
              standout
              v-model="cep_encontrado.complemento"
              label="Complemento"
            />
            <q-input
              class="margin1 col"
              dense
              rounded
              standout
              readonly
              v-model="cep_encontrado.bairro"
              label="Bairro"
            />
            <q-input
              class="margin1 col"
              dense
              rounded
              standout
              readonly
              v-model="cep_encontrado.nm_cidade"
              label="Cidade"
            />
            <q-input
              class="margin1 col"
              dense
              rounded
              standout
              readonly
              v-model="cep_encontrado.nm_estado"
              label="Estado"
            />
          </q-card-section>
        </q-card>
      </q-expansion-item>
    </transition>
    <div v-if="ic_mostra_produtos">
      <div v-if="mostraGrid">
        <!-- Produto -->
        <produtoComprado
          :ic_cadastro="false"
          :ic_mostra_titulo="false"
          :ic_comprado="true"
          @SelectProduto="SelecionaProduto($event)"
          @ParametroGrafica="ParamGrafica($event)"
        />
        <!-- Produto -->
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
    </div>
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
                {{ `Total Líq: ${this.vl_liquido ? this.vl_liquido : ""}` }}
              </div>
              <div class="margin1 borda-bloco col-2">
                {{
                  `Prioridade: ${
                    this.prioridade.cd_tipo_prioridade
                      ? this.prioridade.nm_tipo_prioridade
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
            {{ `Observação: ${this.ds_ordem_servico}` }}
          </div>
        </div>
        <div class="card-cesta row">
          <q-card
            class="margin1 borda-bloco shadow-2 col-3 bg-grey-4"
            v-for="(i, index) in dataCesta"
            :key="index"
          >
            <q-card-section>
              {{ `Código: ${i.cd_mascara_produto}` }} <br />
              {{ `Produto: ${i.nm_fantasia_produto}` }} <br />
              {{ `Un: ${i.sg_unidade_medida}` }} <br />
              {{ `Qtd: ${i.qt_digitacao}` }} <br />
              <!-- {{ `Total Bruto: ${i.vl_total_item_formatado}` }} <br> -->
              <!-- {{ `Imposto: ${i.vl_total_icms_formatado}` }} <br> -->
              {{ `Total: ${i.vl_unitario_liq_formatado}` }} <br />
            </q-card-section>
          </q-card>
        </div>
      </div>
    </transition>
    <q-dialog v-if="!complemento_impressao" maximized persistent>
      <carregando :corID="'orange-9'" mensagemID="Aguarde..."></carregando>
    </q-dialog>

    <div class="row borda-bloco shadow-2 margin1">
      <q-field
        class="col margin1"
        rounded
        outlined
        label-color="white"
        bg-color="yellow"
        label="Liberação"
        stack-label
      >
        <template v-slot:control>
          <div class="self-center full-width no-outline">
            {{
              `${
                result_os.dt_liberacao_producao
                  ? result_os.dt_liberacao_producao.toString()
                  : ""
              }`
            }}
          </div>
        </template>
      </q-field>
      <q-field
        class="col margin1"
        rounded
        outlined
        label-color="white"
        bg-color="primary"
        label="Produção"
        stack-label
      >
        <template v-slot:control>
          <div class="self-center full-width no-outline">
            {{
              `${
                result_os.dt_producao_ordem ? result_os.dt_producao_ordem : ""
              }`
            }}
          </div>
        </template>
      </q-field>
      <q-field
        class="col margin1"
        rounded
        outlined
        label-color="white"
        bg-color="orange"
        label="Logística"
        stack-label
      >
        <template v-slot:control>
          <div class="self-center full-width no-outline">
            {{
              `${
                result_os.dt_logistica_ordem ? result_os.dt_logistica_ordem : ""
              }`
            }}
          </div>
        </template>
      </q-field>
      <q-field
        class="col margin1"
        rounded
        outlined
        label-color="white"
        bg-color="green"
        label="Entrega"
        stack-label
      >
        <template v-slot:control>
          <div class="self-center full-width no-outline">
            {{
              `${result_os.dt_entrega_ordem ? result_os.dt_entrega_ordem : ""}`
            }}
          </div>
        </template>
      </q-field>
      <q-field
        class="col margin1"
        rounded
        outlined
        label-color="white"
        bg-color="red"
        label="Cancelada"
        stack-label
      >
        <template v-slot:control>
          <div class="self-center full-width no-outline">
            {{
              `${
                result_os.dt_cancelamento_ordem
                  ? result_os.dt_cancelamento_ordem
                  : ""
              }`
            }}
          </div>
        </template>
      </q-field>
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
  props: {
    ic_mostra_titulo: { type: Boolean, default: true },
    ic_mostra_produtos: { type: Boolean, default: true },
    cd_cliente_param: { type: Number, default: 0 },
    cd_ordem_servico_param: { type: Number, default: 0 },
  },
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
      result_os: {},
      cep_encontrado: {},
      //Somas
      valor: 0,
      vl_total_produto: 0,
      vl_total_produto_formatado: 0,
      vl_liquido: 0,
      valor_liquido: 0,
      qtd: 0,
      produtos: 0,
      vl_desconto_pedido: 0,
      //////////////////////
      parametro_grafica: "",
      contato: "",
      ic_libera_producao: false,
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
      ds_complemento: "",
      nm_ponto_referencia: "",
      ds_endereco_entrega_os: "",
      local_entrega: "",
      tipo_endereco: "",
      lookup_tipo_endereco: [],
      prioridade: "",
      lookup_prioridade: [],
      dt_entrega: "",
      hr_entrega: "",
      ds_ordem_servico: "",
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
    produtoComprado: () => import("../views/produto-comprado.vue"),
  },

  async created() {
    let lookup_prioridade = await Lookup.montarSelect(this.cd_empresa, 576);
    this.lookup_prioridade = JSON.parse(
      JSON.parse(JSON.stringify(lookup_prioridade.dataset))
    );
    ////////////////////////
    this.lookup_tipo_endereco = await Lookup.montarSelect(this.cd_empresa, 117);
    this.lookup_tipo_endereco = JSON.parse(
      JSON.parse(JSON.stringify(this.lookup_tipo_endereco.dataset))
    );
    ////////////////////////
    this.dt_entrega = formataData.AnoMesDia(this.data_hoje);
    this.mostraGrid = this.cd_cliente_param ? true : false;
    this.cd_cliente = this.cd_cliente_param ? this.cd_cliente_param : 0;
    this.carregaDados();
    //Carrega OS
    await this.ConsultaOS();
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
            "0", //this.cd_cliente,
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
        if (
          e.dataField == "qt_digitacao" ||
          e.dataField == "ic_forneada" ||
          e.dataField == "ic_plotter" ||
          e.dataField == "vl_produto_unitario" ||
          e.dataField == "nm_item_observacao" ||
          e.dataField == "qt_largura" ||
          e.dataField == "qt_comprimento"
        ) {
          e.allowEditing = true;
        } else {
          e.allowEditing = false;
        }
      });

      this.columns.map((e) => {
        e.encodeHtml = false;
        if (e.dataField == "ic_forneada" || e.dataField == "ic_plotter") {
          e.dataType = "boolean";
        }
      });
      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //
    },
    async onEnviarPedido() {
      if (this.cd_ordem_servico_param > 0) {
        var json_OS = {
          cd_parametro: "4",
          cd_modulo: this.cd_modulo,
          cd_usuario: this.cd_usuario,
          cd_ordem_servico: this.cd_ordem_servico_param,
          cd_cliente: this.cd_cliente,
          cd_tipo_prioridade: this.prioridade.cd_tipo_prioridade
            ? this.prioridade.cd_tipo_prioridade
            : null,
          dt_entrega_ordem: this.dt_entrega,
          hr_entrega_ordem: this.hr_entrega,
          ds_ordem_servico: this.ds_ordem_servico,
          nm_local_entrega: this.ds_complemento,
          cd_tipo_endereco: this.tipo_endereco.cd_tipo_endereco,
          ds_ponto_referencia: this.nm_ponto_referencia,
          nm_endereco_entrega: this.cep_encontrado.cep
            ? `${this.cep_encontrado.logradouro} ${
                this.cep_encontrado.numero ? this.cep_encontrado.numero : ""
              } ${this.cep_encontrado.complemento} ${
                this.cep_encontrado.bairro
              } ${this.ds_endereco_entrega_os}`
            : this.ds_endereco_entrega_os,
          ic_libera_producao: this.ic_libera_producao ? "S" : "N",
        };
        let [resultado_edita] = await Incluir.incluirRegistro(
          "875/1352", //this.api,
          json_OS
        ); //pr_gera_ordem_servico_grafica
        notify(`${resultado_edita.Msg}`);
      } else {
        try {
          await this.$refs.gridPadrao.instance.saveEditData();
          await funcao.sleep(1);
        } catch {
          notify("Salvando ordem de serviço");
        }
        if (!this.prioridade.cd_tipo_prioridade) {
          return notify("Selecione a prioridade!");
        }
        if (!this.contato) {
          return notify("Selecione um contato!");
        }
        if (!this.contato.cd_email_contato_cliente) {
          return notify("Contato selecionado não possui E-mail!");
        }
        if (!this.contato.cd_telefone_contato) {
          return notify("Contato selecionado não possui telefone!");
        }
        if (this.dataCesta.length == 0 && this.ic_mostra_produtos) {
          return notify("Nenhum item selecionado!");
        }
        this.dataCesta.map((e) => {
          e.ic_forneada = e.ic_forneada ? "S" : "N";
          e.ic_plotter = e.ic_plotter ? "S" : "N";
        });

        var json_envia_pedido = {
          cd_parametro: 0,
          cd_tipo_prioridade: this.prioridade.cd_tipo_prioridade
            ? this.prioridade.cd_tipo_prioridade
            : null,
          dt_entrega: this.dt_entrega,
          hr_entrega_ordem: this.hr_entrega,
          ds_descricao: this.ds_ordem_servico,
          cd_cliente: this.cd_cliente,
          cd_usuario: this.cd_usuario,
          cd_contato: localStorage.cd_contato, //Contato
          vl_total_ordem: this.vl_total_produto,
          cd_tipo_endereco: this.tipo_endereco.cd_tipo_endereco,
          cd_local_entrega: this.local_entrega.cd_tipo_endereco,
          nm_local_entrega: this.ds_complemento,
          ds_ponto_referencia: this.nm_ponto_referencia,
          nm_endereco_entrega: this.cep_encontrado.cep
            ? `${this.cep_encontrado.logradouro} ${
                this.cep_encontrado.numero ? this.cep_encontrado.numero : ""
              } ${this.cep_encontrado.complemento} ${
                this.cep_encontrado.bairro
              } ${this.ds_endereco_entrega_os}`
            : this.ds_endereco_entrega_os,
          ic_libera_producao: this.ic_libera_producao ? "S" : "N",
          grid: this.dataCesta,
        };
        let [result_pedido] = await Incluir.incluirRegistro(
          "875/1352", //this.api,
          json_envia_pedido
        ); //pr_gera_ordem_servico_grafica
        if (result_pedido != undefined && result_pedido.cd_ordem_servico) {
          notify(
            `Ordem de Serviço ${result_pedido.cd_ordem_servico} enviada com sucesso`
          );
        } else if (result_pedido.Msg) {
          notify(`${result_pedido.Msg}`);
        } else {
          notify("Não foi possível enviar a ordem de serviço");
        }
        if (this.ic_mostra_produtos) {
          await this.onCancelar();
          this.carregaDados(true);
        } else {
          this.cd_ordem_servico_param = result_pedido.cd_ordem_servico;
          await this.ConsultaOS();
        }
      }
    },

    async ConsultaOS() {
      if (this.cd_ordem_servico_param > 0) {
        var json_OS = {
          cd_parametro: "5",
          cd_modulo: this.cd_modulo,
          cd_cliente: this.cd_cliente,
          cd_usuario: this.cd_usuario,
          cd_documento: this.cd_ordem_servico_param,
        };
        [this.result_os] = await Incluir.incluirRegistro(
          "866/1343", //this.api,
          json_OS
        ); //pr_modulo_processo_egisnet
        this.$emit("SalvaCapaOS", this.result_os);
        this.result_os.dt_liberacao_producao = this.result_os
          .dt_liberacao_producao
          ? `${formataData.formataDataJS(
              this.result_os.dt_liberacao_producao
            )} ${this.result_os.hr_liberacao_producao}`
          : "";
        this.result_os.dt_producao_ordem = this.result_os.dt_producao_ordem
          ? `${formataData.formataDataJS(this.result_os.dt_producao_ordem)} ${
              this.result_os.hr_producao_ordem
            }`
          : "";
        this.result_os.dt_logistica_ordem = this.result_os.dt_logistica_ordem
          ? `${formataData.formataDataJS(this.result_os.dt_logistica_ordem)} ${
              this.result_os.hr_logistica_ordem
            }`
          : "";
        this.result_os.dt_entrega_ordem = this.result_os.dt_entrega_ordem
          ? `${formataData.formataDataJS(this.result_os.dt_entrega_ordem)} ${
              this.result_os.hr_entrega_ordem
            }`
          : "";
        this.result_os.dt_cancelamento_ordem = this.result_os
          .dt_cancelamento_ordem
          ? formataData.formataDataJS(this.result_os.dt_cancelamento_ordem)
          : "";
        [this.prioridade] = this.lookup_prioridade.filter(
          (p) => p.cd_tipo_prioridade == this.result_os.cd_tipo_prioridade
        );
        this.hr_entrega = this.result_os.hr_entrega_ordem;
        this.ds_ordem_servico = this.result_os.ds_ordem_servico;
        this.ds_complemento = this.result_os.nm_local_entrega;
        this.ic_libera_producao = this.result_os.dt_liberacao_producao
          ? true
          : false;
        [this.tipo_endereco] = this.lookup_tipo_endereco.filter(
          (p) => p.cd_tipo_endereco == this.result_os.cd_tipo_endereco
        );
        this.nm_ponto_referencia = this.result_os.ds_ponto_referencia;
        this.ds_endereco_entrega_os = this.result_os.nm_endereco_entrega;
        this.vl_total_produto_formatado =
          this.result_os.vl_ordem_servico.toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL",
          });
        ////////////////////////////////////
        var json_OS_item = {
          cd_parametro: "10",
          cd_modulo: this.cd_modulo,
          cd_cliente: this.cd_cliente,
          cd_usuario: this.cd_usuario,
          cd_documento: this.cd_ordem_servico_param,
        };
        this.dataSourceConfig = await Incluir.incluirRegistro(
          "866/1343", //this.api,
          json_OS_item
        ); //pr_modulo_processo_egisnet
        this.produtos = this.dataSourceConfig.length;
        this.dataSourceConfig.map((e) => {
          e.ic_forneada = e.ic_forneada === "S" ? true : false;
          e.ic_plotter = e.ic_plotter === "S" ? true : false;
        });
      }
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
      localStorage.cd_tabela_preco = e.cd_tabela_preco;
      this.cd_cliente = e.cd_cliente;
      this.mostraGrid = true;
      await this.carregaDados();
    },

    SelecionaLocalEntrega(e) {
      this.local_entrega = e;
    },

    OnContato(e) {
      this.contato = e;
    },

    async onCEP() {
      if (this.ds_endereco_entrega_os.length === 8) {
        [this.cep_encontrado] = await funcao.buscaCep(
          this.ds_endereco_entrega_os
        );
        this.cep_encontrado.cd_cep
          ? notify("CEP Encontrado")
          : notify("CEP não encontrado");
      } else {
        notify("CEP Inválido");
      }
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

    ParamGrafica(e) {
      this.parametro_grafica = e;
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
        c.vl_unitario_liq =
          parseFloat(c.vl_produto_unitario) * parseFloat(c.qt_digitacao);
        c.vl_total_item =
          parseFloat(c.vl_produto_unitario) * parseFloat(c.qt_digitacao);
        //+parseFloat(c.qt_digitacao) * parseFloat(c.vl_icms_st);
        c.VL_PRODUTO_formatado = c.vl_produto_unitario.toLocaleString("pt-BR", {
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
        this.vl_liquido += c.vl_total_item;
      });
      this.vl_total_produto_formatado = this.vl_total_produto.toLocaleString(
        "pt-BR",
        {
          style: "currency",
          currency: "BRL",
        }
      );
      this.vl_liquido = this.vl_liquido.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
    },
    async attQtd(e) {
      await funcao.sleep(1);
      e.rows.map((i) => {
        var index = this.dataCesta.findIndex(
          (e) => e.cd_controle === i.data.cd_controle
        );
        if (i.data.nm_item_observacao != "") {
          this.dataCesta[index].nm_item_observacao = i.data.nm_item_observacao;
        }
        if (e.prevColumnIndex === 3) {
          //Hover em Comprimento
          this.dataCesta[index].qt_comprimento = i.data.qt_comprimento;
          this.dataCesta[index].qt_largura = i.data.qt_largura;
          if (
            i.data.cd_grupo_produto == this.parametro_grafica.cd_grupo_prova
          ) {
            //Prova 8
            if (i.data.qt_comprimento > 0 && i.data.qt_largura > 0) {
              let vl_prova =
                i.data.qt_comprimento *
                i.data.qt_largura *
                i.data.vl_produto_lista;
              this.$refs.gridPadrao.instance.cellValue(
                i.rowIndex,
                "vl_produto_unitario",
                vl_prova
              );
            }
          } else if (
            i.data.cd_grupo_produto == this.parametro_grafica.cd_grupo_produto
          ) {
            //CHAPAS 15
            if (i.data.qt_comprimento > 0 && i.data.qt_largura > 0) {
              let vl_chapa =
                i.data.qt_comprimento *
                100 *
                (i.data.qt_largura * 100) *
                i.data.vl_produto_lista;
              this.$refs.gridPadrao.instance.cellValue(
                i.rowIndex,
                "vl_produto_unitario",
                vl_chapa
              );
            }
          } else if (
            i.data.cd_grupo_produto == this.parametro_grafica.cd_grupo_filme
          ) {
            //FILMES 30
            if (i.data.qt_comprimento > 0) {
              let vl_filme = i.data.qt_comprimento * i.data.vl_produto_lista;
              this.$refs.gridPadrao.instance.cellValue(
                i.rowIndex,
                "vl_produto_unitario",
                vl_filme
              );
            }
          } else {
            this.$refs.gridPadrao.instance.cellValue(
              i.rowIndex,
              "vl_produto_unitario",
              i.data.vl_produto_unitario
            );
          }
        }
        this.$refs.gridPadrao.instance.cellValue(
          i.rowIndex,
          "vl_produto_unitario",
          i.data.vl_produto_unitario
        );
        if (this.dataCesta.find((e) => e.cd_controle === i.data.cd_controle)) {
          let index = this.dataCesta.findIndex(
            (e) => e.cd_controle === i.data.cd_controle
          );
          this.dataCesta[index].ic_forneada = i.data.ic_forneada;
          this.dataCesta[index].ic_plotter = i.data.ic_plotter;
        }
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
          this.dataCesta = this.dataCesta.filter(
            (dropItem) => dropItem.cd_controle === i.data.cd_controle
          );
          i.data.qt_digitacao = 0;
        }
        if (typeof i.data.qt_digitacao === "string") {
          i.data.qt_digitacao = funcao.RealParaInt(i.data.qt_digitacao);
        }
        if (typeof i.data.vl_produto_unitario === "string") {
          i.data.vl_produto_unitario = funcao.RealParaInt(
            i.data.vl_produto_unitario
          );
        }
        if (typeof i.data.vl_icms_st === "string") {
          i.data.vl_icms_st = funcao.RealParaInt(i.data.vl_icms_st);
        }
        if (
          i.data.qt_digitacao == 0 &&
          this.dataCesta.find((e) => e.cd_controle === i.data.cd_controle)
        ) {
          this.dataCesta = this.dataCesta.filter(
            (dropItem) => dropItem.cd_controle !== i.data.cd_controle
          );
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
            if (alterouQtd.qt_digitacao != i.data.qt_digitacao) {
              this.dataCesta[alterouQtd.index].qt_digitacao =
                i.data.qt_digitacao;
              this.attDataCesta();
            }
            if (alterouQtd.vl_produto_unitario != i.data.vl_produto_unitario) {
              this.dataCesta[alterouQtd.index].vl_produto_unitario =
                i.data.vl_produto_unitario;
              this.attDataCesta();
            }
          }
          let vl_total_item =
            i.data.qt_digitacao.toFixed(2) *
            i.data.vl_produto_unitario.toFixed(2);
          //+ i.data.qt_digitacao.toFixed(2) * i.data.vl_icms_st;
          let vl_total_liquido =
            i.data.qt_digitacao.toFixed(2) *
            i.data.vl_produto_unitario.toFixed(2);
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
        }
      });
    },
    limpaTotais() {
      this.valor = 0;
      this.qtd = 0;
      this.produtos = 0;
      this.valor_liquido = 0;
      this.vl_total_produto = 0;
      this.vl_total_produto_formatado = 0;
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
