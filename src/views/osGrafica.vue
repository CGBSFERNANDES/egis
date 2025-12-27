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
    <div class="row">
      <div class="margin1 col-1">
        <q-btn
          rounded
          color="primary"
          icon="add"
          label="Inserir"
          @click="onNovaOS()"
        />
      </div>
      <div class="margin1 col-1">
        <q-btn
          rounded
          color="primary"
          icon="print"
          label="Imprimir"
          @click="onImprimir()"
        />
      </div>
      <transition name="slide-fade">
        <div
          v-if="OSSelecionada.cd_ordem_servico"
          class="margin1 col-2 OrdemServico"
        >
          <div class="borda-bloco shadow-2 bg-primary">
            {{ `Ordem de Serviço - ${OSSelecionada.cd_ordem_servico}` }}
          </div>
        </div>
      </transition>
    </div>
    <q-tabs
      v-model="index"
      inline-label
      mobile-arrows
      align="left"
      style="border-radius: 20px"
      :class="'bg-primary text-white shadow-2 margin1'"
    >
      <q-tab :name="-1" icon="description" label="Dados" />
      <q-tab :name="0" icon="description" label="Cadastro" />
      <q-tab :name="1" icon="list" label="Produtos" />
      <q-tab :name="2" icon="person" label="Ficha Técnica" />
      <q-tab :name="3" icon="receipt_long" label="Alteração" />
      <q-tab :name="4" icon="history" label="Histórico" />
      <q-tab :name="5" icon="money_off" label="Estorno" />
      <q-tab :name="6" icon="feed" label="Protocolo" />
      <q-tab :name="7" icon="task" label="Aprovação" />
    </q-tabs>
    <transition name="slide-fade">
      <div class="margin1" v-if="index == -1">
        <grid
          ref="gridOS"
          :cd_menuID="7713"
          :cd_apiID="866"
          :cd_parametroID="0"
          :nm_json="{
            cd_modulo: this.cd_modulo,
            cd_parametro: 5,
            cd_usuario: this.cd_usuario,
            dt_inicial: this.dt_inicial,
            dt_final: this.dt_final,
          }"
          @emit-click="SelecionaOS()"
        />
      </div>
      <div v-if="index == 0">
        <OSLancamento
          :ic_mostra_titulo="false"
          :ic_mostra_produtos="false"
          :cd_cliente_param="OSSelecionada.cd_cliente"
          :cd_ordem_servico_param="OSSelecionada.cd_ordem_servico"
          @SalvaCapaOS="onSalvaCapa($event)"
        />
      </div>
    </transition>
    <!-- Grid -->
    <transition name="slide-fade">
      <div v-if="index == 1">
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
              @row-removed="OnRemoveProduto($event)"
              @row-updated="OnAlteraProduto($event)"
            >
              <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

              <DxEditing
                :allow-updating="true"
                :allow-adding="false"
                :allow-deleting="true"
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
        <div class="row margin1">
          <q-field
            rounded
            outlined
            class="col-4 margin1"
            label="Valor da Ordem de Serviço"
            stack-label
          >
            <template v-slot:prepend>
              <q-icon name="attach_money" />
            </template>
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{
                  `${
                    vl_total_produto_formatado
                      ? vl_total_produto_formatado
                      : "R$ 0,00"
                  }`
                }}
              </div>
            </template>
          </q-field>
          <q-btn
            class="margin1"
            rounded
            color="primary"
            icon="lock"
            label="Liberar"
            @click="onLiberar()"
          />
        </div>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="index == 2">
        <!-- Perfil -->
        <div class="row">
          <q-field
            class="col margin1"
            dense
            rounded
            standout
            label="Cliente"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline">
                {{
                  `${
                    OSSelecionada.ficha_tecnica[0].nm_fantasia_cliente
                      ? OSSelecionada.ficha_tecnica[0].nm_fantasia_cliente
                      : ""
                  }`
                }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            dense
            rounded
            standout
            label="Produto"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline">
                {{
                  `${
                    OSSelecionada.ficha_tecnica[0].nm_fantasia_produto
                      ? OSSelecionada.ficha_tecnica[0].nm_fantasia_produto
                      : ""
                  }`
                }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            dense
            rounded
            standout
            label="Descritivo"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline">
                {{
                  `${
                    OSSelecionada.ficha_tecnica[0].ds_cliente_grafica
                      ? OSSelecionada.ficha_tecnica[0].ds_cliente_grafica
                      : ""
                  }`
                }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            dense
            rounded
            standout
            label="Pinça"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline">
                {{
                  `${
                    OSSelecionada.ficha_tecnica[0].qt_pinca_cliente
                      ? OSSelecionada.ficha_tecnica[0].qt_pinca_cliente
                      : ""
                  }`
                }}
              </div>
            </template>
          </q-field>
        </div>
        <div class="row">
          <q-toggle
            v-model="ic_chapa_forneada"
            label="Chapa Forneada"
            color="orange"
          />
          <q-toggle label="Portaria 24h" v-model="ic_portaria" color="orange" />
        </div>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="index == 3">
        <!-- Alteração -->
        <div class="row">
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            stack-label
            type="date"
            v-model="dt_entrega"
            label="Data"
          >
            <template v-slot:prepend>
              <q-icon name="event"></q-icon>
            </template>
          </q-input>
          <q-select
            rounded
            outlined
            bottom-slots
            class="margin1 opcoes col"
            v-model="tipo_alteracao"
            :options="lookup_tipo_alteracao"
            option-value="cd_tipo_alteracao"
            option-label="nm_tipo_alteracao"
            label="Tipo de Alteração/Motivo"
          >
            <template v-slot:prepend>
              <q-icon name="published_with_changes"></q-icon>
            </template>
          </q-select>
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            stack-label
            type="textarea"
            v-model="ds_complemento"
            label="Complemento"
          >
            <template v-slot:prepend>
              <q-icon name="event"></q-icon>
            </template>
          </q-input>
        </div>
        <q-btn
          rounded
          class="margin1"
          text-color="white"
          color="primary"
          icon="check"
          label="Atualizar"
        >
        </q-btn>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="index == 4">
        <!-- Histórico -->
        <grid
          ref="gridHistorico"
          class="margin1"
          :cd_menuID="7715"
          :cd_apiID="866"
          :cd_parametroID="0"
          :nm_json="{
            cd_modulo: this.cd_modulo,
            cd_parametro: 8,
            cd_usuario: this.cd_usuario,
            cd_documento: this.OSSelecionada.cd_ordem_servico,
          }"
        />
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="index == 5">
        <!-- Estorno -->
        <div class="row">
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            stack-label
            v-model="OSSelecionada.cd_ordem_servico"
            label="Ordem"
          >
            <template v-slot:prepend>
              <q-icon name="description"></q-icon>
            </template>
          </q-input>
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            stack-label
            type="date"
            v-model="dt_estorno"
            label="Data"
          >
            <template v-slot:prepend>
              <q-icon name="event"></q-icon>
            </template>
          </q-input>
        </div>
        <q-btn
          rounded
          class="margin1"
          text-color="white"
          color="primary"
          icon="keyboard_return"
          label="Estornar"
          @click="onEstornar()"
        >
        </q-btn>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="index == 6">
        <!-- Protocolo -->
        <div class="row">
          <q-input
            class="margin1 opcoes"
            rounded
            outlined
            stack-label
            v-model="nm_ponto_referencia"
            label="Ponto de Referência"
          >
            <template v-slot:prepend>
              <q-icon name="event"></q-icon>
            </template>
          </q-input>
        </div>
        <div class="row margin1 shadow-2 borda-bloco">
          <div class="margin1" style="font-weight: bold">SAIDA</div>
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            stack-label
            type="data"
            mask="date"
            v-model="dt_saida"
            label="Data"
          >
            <template v-slot:prepend>
              <q-icon name="event"></q-icon>
            </template>
          </q-input>
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            mask="time"
            stack-label
            v-model="hr_saida"
            label="Hora de Saída"
          >
            <template v-slot:prepend>
              <q-icon name="schedule"></q-icon>
            </template>
          </q-input>
          <q-select
            rounded
            outlined
            bottom-slots
            class="margin1 opcoes col"
            v-model="Motorista"
            :options="lookup_motorista"
            option-value="cd_motorista"
            option-label="nm_motorista"
            label="Entregador/Motorista"
          >
            <template v-slot:prepend>
              <q-icon name="local_shipping"></q-icon>
            </template>
          </q-select>
        </div>
        <div class="row margin1 shadow-2 borda-bloco">
          <div class="margin1" style="font-weight: bold">ENTREGA</div>
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            stack-label
            type="data"
            v-model="dt_entrega"
            label="Data"
          >
            <template v-slot:prepend>
              <q-icon name="event"></q-icon>
            </template>
          </q-input>
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            stack-label
            type="time"
            v-model="hr_entrega"
            label="Hora do Recebimento"
          >
            <template v-slot:prepend>
              <q-icon name="schedule"></q-icon>
            </template>
          </q-input>
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            stack-label
            v-model="nm_responsavel"
            label="Responsável"
          >
            <template v-slot:prepend>
              <q-icon name="person"></q-icon>
            </template>
          </q-input>
        </div>
        <q-btn
          rounded
          class="margin1"
          text-color="white"
          color="primary"
          icon="check"
          label="Confirmação"
        >
        </q-btn>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="index == 7">
        <div class="row">
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            stack-label
            v-model="dt_aprovacao"
            label="Data"
          >
            <template v-slot:prepend>
              <q-icon name="event"></q-icon>
            </template>
          </q-input>
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            stack-label
            v-model="nm_contato_responsavel"
            label="Contato/Responsável"
          >
            <template v-slot:prepend>
              <q-icon name="person"></q-icon>
            </template>
          </q-input>
          <q-input
            class="margin1 opcoes col"
            rounded
            outlined
            stack-label
            type="textarea"
            v-model="ds_observacao"
            label="Observação"
          >
            <template v-slot:prepend>
              <q-icon name="description"></q-icon>
            </template>
          </q-input>
        </div>
        <q-btn
          rounded
          class="margin1"
          text-color="white"
          color="primary"
          icon="check"
          label="Aprovar"
        >
        </q-btn>
      </div>
    </transition>
    <q-dialog v-if="!complemento_impressao" maximized persistent>
      <carregando :corID="'orange-9'" mensagemID="Aguarde..."></carregando>
    </q-dialog>
    <q-dialog
      v-model="printOs"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card class="bg-white">
        <q-bar class="bg-orange-9 text-white">
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-white text-primary"
              >Minimizar</q-tooltip
            >
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-white text-primary"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-white text-primary">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <reportPrint
          :cd_ordem_servico="OSSelecionada.cd_ordem_servico"
          cd_api="889/1366"
        />
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
      cd_modulo: localStorage.cd_modulo,
      cd_cliente: localStorage.cd_cliente,
      cd_menu: localStorage.cd_menu,
      cd_api: localStorage.cd_api,
      api: "",
      saveItem: 0,
      index: -1,
      OSSelecionada: {},
      ic_chapa_forneada: false,
      ic_portaria: false,
      dt_inicial: localStorage.dt_inicial,
      dt_final: localStorage.dt_final,
      //Somas
      vl_total_produto: 0,
      vl_total_produto_formatado: 0,
      produtos: 0,
      parametro_grafica: [],
      printOs: false,
      //////////////////////
      maximizedToggle: true,
      loadingPDF: false,
      loadingDataSourceConfig: false,
      masterDetail: false,
      filterGrid: true,
      multipleSelection: false,
      complemento_impressao: false,
      pageSizes: [10, 20, 50, 100],
      data_hoje: new Date(),
      dataSourceConfig: [],
      qt_registro: "",
      columns: [],
      total: {},
      tituloMenu: "",
      tipo_prioridade: "",
      lookup_prioridade: [],
      dt_entrega: "",
      vl_total_ordem: "0",
      nm_referencia: "",
      ds_descricao: "",
      //////////////////
      lookup_tipo_alteracao: "",
      ds_complemento: "",
      cd_ordem: "",
      dt_estorno: "",
      nm_ponto_referencia: "",
      dt_saida: "",
      hr_saida: "",
      Motorista: "",
      lookup_motorista: "",
      hr_entrega: "",
      nm_responsavel: "",
      nm_contato_responsavel: "",
      ds_observacao: "",
      dt_aprovacao: "",
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
    OSLancamento: () => import("../views/ordemServicoLancamento.vue"),
    produtoComprado: () => import("../views/produto-comprado.vue"),
    grid: () => import("../views/grid.vue"),
    reportPrint: () => import("../components/reportPrint.vue"),
  },

  async created() {
    let lookup_prioridade = await Lookup.montarSelect(this.cd_empresa, 576);
    this.lookup_prioridade = JSON.parse(
      JSON.parse(JSON.stringify(lookup_prioridade.dataset))
    );
    //////////////////
    let lookup_tipo_alteracao = await Lookup.montarSelect(
      this.cd_empresa,
      3231
    );
    this.lookup_tipo_alteracao = JSON.parse(
      JSON.parse(JSON.stringify(lookup_tipo_alteracao.dataset))
    );
    //////////////////
    let lookup_motorista = await Lookup.montarSelect(this.cd_empresa, 494);
    this.lookup_motorista = JSON.parse(
      JSON.parse(JSON.stringify(lookup_motorista.dataset))
    );
    this.dt_entrega = formataData.AnoMesDia(this.data_hoje);
    this.dt_estorno = formataData.AnoMesDia(this.data_hoje);
    this.cd_menu = "7714"; //1724 - pr_modulo_processo_egisnet
    await this.showMenu();
  },

  computed: {
    gridPadrao() {
      return this.$refs["gridPadrao"].instance;
    },
  },

  methods: {
    async carregaDados(showNotify) {
      localStorage.cd_identificacao = 0;
      this.cd_menu = "7714"; //1724 - pr_modulo_processo_egisnet
      await this.showMenu();
      if (!showNotify) {
        notify("Aguarde... estamos montando a consulta para você!");
      }
      let sApis = sParametroApi;
      if (!sApis == "") {
        try {
          this.loadingDataSourceConfig = true;
          let json_os_produtos = {
            cd_modulo: this.cd_modulo,
            cd_parametro: 10,
            cd_usuario: this.cd_usuario,
            cd_documento: this.OSSelecionada.cd_ordem_servico,
          };
          this.dataSourceConfig = await Incluir.incluirRegistro(
            this.api, //pr_modulo_processo_egisnet API - 866
            json_os_produtos
          );
          this.loadingDataSourceConfig = false;
        } catch (error) {
          this.loadingDataSourceConfig = false;
          console.error(error);
        }
        this.dataSourceConfig.map((e) => {
          e.ic_forneada = e.ic_forneada === "S" ? true : false;
          e.ic_plotter = e.ic_plotter === "S" ? true : false;
        });
        this.qt_registro = this.dataSourceConfig.length;
      }
    },
    async showMenu() {
      this.cd_api = "866"; //localStorage.cd_api; //pr_modulo_processo_egisnet
      this.api = "866/1343"; //localStorage.nm_identificacao_api;
      localStorage.cd_parametro = 0;
      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';
      sParametroApi = dados.nm_api_parametro;

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }
      if (this.cd_menu != "7714") {
        this.tituloMenu = dados.nm_menu_titulo;
      }
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
          e.dataField == "nm_produto_ordem" ||
          e.dataField == "nm_obs_item_produto" ||
          e.dataField == "qt_formato_1" ||
          e.dataField == "qt_formato_2"
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

    async onCesta() {
      try {
        await this.$refs.gridPadrao.instance.saveEditData();
        await funcao.sleep(1);
      } catch {
        notify("Aguarde...");
      }
    },

    async attProdutos() {
      var json_OS_item = {
        cd_parametro: "10",
        cd_modulo: this.cd_modulo,
        cd_cliente: this.cd_cliente,
        cd_usuario: this.cd_usuario,
        cd_documento: this.OSSelecionada.cd_ordem_servico,
      };
      this.dataSourceConfig = await Incluir.incluirRegistro(
        "866/1343", //this.api,
        json_OS_item
      ); //pr_modulo_processo_egisnet
      this.dataSourceConfig.map((e) => {
        e.ic_forneada = e.ic_forneada === "S" ? true : false;
        e.ic_plotter = e.ic_plotter === "S" ? true : false;
      });
    },

    onSalvaCapa(e) {
      this.OSSelecionada = e;
      this.vl_total_produto_formatado =
        this.OSSelecionada.vl_ordem_servico.toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
    },

    async SelecionaProduto(e) {
      if (!e.length) {
        var json_insert_produto = {
          cd_parametro: 1,
          cd_ordem_servico: this.OSSelecionada.cd_ordem_servico,
          cd_produto: e.cd_produto,
        };
        let [result_pedido] = await Incluir.incluirRegistro(
          "875/1352", //this.api,
          json_insert_produto
        ); //pr_gera_ordem_servico_grafica
        if (result_pedido.Msg) {
          notify(`${result_pedido.Msg}`);
        } else {
          notify("Não foi possível adicionar o produto a ordem de serviço");
        }
        /////////////////////////////
        this.attProdutos();
      }
    },

    ParamGrafica(e) {
      this.parametro_grafica = e;
    },

    SelecionaCliente(e) {
      this.cd_cliente = e.cd_cliente;
    },
    async SelecionaOS() {
      this.OSSelecionada = await this.$refs.gridOS.linha;
      this.index = 0; //Aba Cadastro
      this.vl_total_ordem = await funcao.FormataValor(
        this.OSSelecionada.vl_ordem_servico
      );
      await this.carregaDados();
      await this.FichaTecnica();
    },
    async onEstornar() {
      let json_estornar = {
        cd_modulo: this.cd_modulo,
        cd_parametro: 9,
        cd_usuario: this.cd_usuario,
        cd_documento: this.OSSelecionada.cd_ordem_servico,
      };
      this.OSSelecionada.ficha_tecnica = await Incluir.incluirRegistro(
        this.api,
        json_estornar
      );
      if (this.OSSelecionada.ficha_tecnica[0].Msg) {
        this.columns.map((e) => {
          e.encodeHtml = false;
          if (
            e.dataField == "qt_digitacao" ||
            e.dataField == "ic_forneada" ||
            e.dataField == "ic_plotter" ||
            e.dataField == "vl_produto_unitario" ||
            e.dataField == "nm_obs_item_produto" ||
            e.dataField == "qt_formato_1" ||
            e.dataField == "qt_formato_2"
          ) {
            e.allowEditing = true;
          } else {
            e.allowEditing = false;
          }
        });
        notify(`${this.OSSelecionada.ficha_tecnica[0].Msg}`);
      } else {
        notify("Não foi possível estornar a ordem de serviço");
      }
    },
    async OnRemoveProduto(e) {
      var json_remove_produto = {
        cd_parametro: 2,
        cd_ordem_servico: this.OSSelecionada.cd_ordem_servico,
        cd_item_ordem_servico: e.data.cd_item_ordem_servico,
      };
      let [result_pedido] = await Incluir.incluirRegistro(
        "875/1352", //this.api,
        json_remove_produto
      ); //pr_gera_ordem_servico_grafica
      if (result_pedido.Msg) {
        notify(`${result_pedido.Msg}`);
      } else {
        notify("Não foi possível excluir o produto a ordem de serviço");
      }
      await this.attProdutos();
    },

    async OnAlteraProduto() {
      this.saveItem++;
      if (this.saveItem == 1) {
        var json_att_produto = {
          cd_parametro: 5,
          cd_ordem_servico: this.OSSelecionada.cd_ordem_servico,
          vl_total_produto: this.vl_total_produto,
          grid: this.dataSourceConfig,
        };
        let [result_pedido] = await Incluir.incluirRegistro(
          "875/1352", //this.api,
          json_att_produto
        ); //pr_gera_ordem_servico_grafica
        if (result_pedido.Msg) {
          notify(`${result_pedido.Msg}`);
        } else {
          notify("Não foi possível atualizar os produtos da ordem de serviço");
        }
        await this.attProdutos();
      }
      if (this.saveItem === this.dataSourceConfig.length) {
        this.saveItem = 0;
      }
    },

    async onLiberar() {
      var json_libera_OS = {
        cd_parametro: 3,
        cd_ordem_servico: this.OSSelecionada.cd_ordem_servico,
      };
      let [result_pedido] = await Incluir.incluirRegistro(
        "875/1352", //this.api,
        json_libera_OS
      ); //pr_gera_ordem_servico_grafica
      if (result_pedido.Msg) {
        this.columns.map((e) => {
          e.encodeHtml = false;
          e.allowEditing = false;
        });
        notify(`${result_pedido.Msg}`);
      } else {
        notify("Não foi possível liberar a ordem de serviço");
      }
    },

    async onImprimir() {
      this.printOs = true;
    },

    async FichaTecnica() {
      let json_ficha_tecnica = {
        cd_modulo: this.cd_modulo,
        cd_parametro: 7,
        cd_usuario: this.cd_usuario,
        cd_cliente: this.OSSelecionada.cd_cliente,
      };
      this.OSSelecionada.ficha_tecnica = await Incluir.incluirRegistro(
        this.api,
        json_ficha_tecnica
      );
      this.ic_chapa_forneada =
        this.OSSelecionada.ficha_tecnica[0].ic_forno_chapa.trim()
          ? true
          : false;
      this.ic_portaria =
        this.OSSelecionada.ficha_tecnica[0].ic_portaria_cliente.trim()
          ? true
          : false;
    },
    async onPDF() {
      await this.onCesta();
      await funcao.sleep(1);
    },
    attDataCesta() {
      this.limpaTotais();
      this.dataSourceConfig.map((c) => {
        c.vl_total_item =
          parseFloat(c.vl_produto_unitario) * parseFloat(c.qt_digitacao);
        c.vl_produto_formatado = c.vl_produto_unitario.toLocaleString("pt-BR", {
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
        this.vl_total_produto += c.vl_total_item;
      });
      this.vl_total_produto_formatado = this.vl_total_produto.toLocaleString(
        "pt-BR",
        {
          style: "currency",
          currency: "BRL",
        }
      );
    },
    async attQtd(e) {
      await funcao.sleep(1);
      e.rows.map((i) => {
        var index = this.dataSourceConfig.findIndex(
          (e) => e.cd_controle === i.data.cd_controle
        );
        if (e.prevColumnIndex === 4) {
          //Hover em Comprimento
          this.dataSourceConfig[index].qt_formato_1 = i.data.qt_formato_1;
          this.dataSourceConfig[index].qt_formato_2 = i.data.qt_formato_2;
          if (
            i.data.cd_grupo_produto == this.parametro_grafica.cd_grupo_prova
          ) {
            //Prova 8
            if (i.data.qt_formato_1 > 0 && i.data.qt_formato_2 > 0) {
              let vl_prova =
                i.data.qt_formato_1 *
                i.data.qt_formato_2 *
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
            if (i.data.qt_formato_1 > 0 && i.data.qt_formato_2 > 0) {
              let vl_chapa =
                i.data.qt_formato_2 *
                100 *
                (i.data.qt_formato_1 * 100) *
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
            if (i.data.qt_formato_2 > 0) {
              let vl_filme = i.data.qt_formato_2 * i.data.vl_produto_lista;
              this.$refs.gridPadrao.instance.cellValue(
                i.rowIndex,
                "vl_produto_unitario",
                vl_filme
              );
            }
          }
        }
        this.$refs.gridPadrao.instance.cellValue(
          i.rowIndex,
          "vl_produto_unitario",
          i.data.vl_produto_unitario
        );
        if (
          this.dataSourceConfig.find(
            (e) => e.cd_controle === i.data.cd_controle
          )
        ) {
          let index = this.dataSourceConfig.findIndex(
            (e) => e.cd_controle === i.data.cd_controle
          );
          this.dataSourceConfig[index].ic_forneada = i.data.ic_forneada;
          this.dataSourceConfig[index].ic_plotter = i.data.ic_plotter;
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
            "vl_total_produto",
            0.0
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
        if (i.data.qt_digitacao > 0) {
          let alterouQtd = this.dataSourceConfig.find(
            (e) => e.cd_controle === i.data.cd_controle
          );
          alterouQtd.index = this.dataSourceConfig.findIndex(
            (e) => e.cd_controle === i.data.cd_controle
          );
          this.attDataCesta();
          if (alterouQtd.qt_digitacao != i.data.qt_digitacao) {
            this.dataSourceConfig[alterouQtd.index].qt_digitacao =
              i.data.qt_digitacao;
          }
          if (alterouQtd.vl_produto_unitario != i.data.vl_produto_unitario) {
            this.dataSourceConfig[alterouQtd.index].vl_produto_unitario =
              i.data.vl_produto_unitario;
          }

          let vl_total_item =
            i.data.qt_digitacao.toFixed(2) *
            i.data.vl_produto_unitario.toFixed(2);
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_produto",
            vl_total_item
          );
        }
      });
      this.produtos = this.dataSourceConfig.length;
    },
    async onNovaOS() {
      this.index = 1;
      this.OSSelecionada = {};
      this.vl_total_ordem = 0;
      this.qt_registro = "";
      this.dataSourceConfig = [];
      await funcao.sleep(1000);
      this.index = 0;
    },
    limpaTotais() {
      this.vl_total_produto = 0;
      this.vl_total_produto_formatado = 0;
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

.OrdemServico {
  font-weight: bold;
  font-size: 18px;
  color: #fff;
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
