<template>
  <div>
    <div v-if="1 == 2" class="q-pa-md">
      <q-toolbar class="bg-primary glossy text-white">
        <q-btn flat round dense icon="menu" class="q-mr-sm" />
        <q-avatar>
          <img src="https://cdn.quasar.dev/logo-v2/svg/logo-mono-white.svg" />
        </q-avatar>

        <q-toolbar-title>Dados</q-toolbar-title>

        <q-btn flat round dense icon="whatshot" />
      </q-toolbar>
    </div>

    <div
      v-if="
        this.cd_api == 641 &&
        this.dataSourceConfig &&
        this.dataSourceConfig.length > 0
      "
      class="row"
    >
      <div
        class="margin1 col"
        v-if="
          !!this.dataSourceConfig[0].nm_titulo != false && this.cd_modulo != 260
        "
      >
        <q-field :label="dataSourceConfig[0].nm_titulo" stack-label>
          <template v-slot:control>
            <div class="self-center full-width no-outline" tabindex="0">
              {{ dataSourceConfig[0].Documento }}
            </div>
          </template>
        </q-field>
      </div>

      <div class="margin1 col" v-if="this.cd_modulo != 260">
        <q-field label="Data" stack-label>
          <template v-slot:control>
            <div class="self-center full-width no-outline" tabindex="0">
              {{ dataSourceConfig[0].Data }}
            </div>
          </template>
        </q-field>
      </div>
    </div>
    <!-- Campos mostrados individualmente -->
    <div class="item-grid" v-if="list_atributos && list_atributos.length > 0">
      <div v-for="(i, index) in list_atributos" :key="index">
        <q-field
          class="margin1"
          :color="i.cor.vl_cor"
          :label="i.caption"
          rounded
          outlined
          stack-label
        >
          <template v-slot:prepend>
            <q-icon :name="i.icone.nm_icone_atributo" />
          </template>
          <template v-slot:control>
            <div class="self-center full-width no-outline" tabindex="0">
              {{ `${i.valor[i.dataField]}` }}
            </div>
          </template>
        </q-field>
      </div>
    </div>
    <div v-show="loadingDataSourceConfig == true" class="row">
      <q-spinner-facebook class="col margin1" color="orange-9" size="6em" />
      <q-tooltip :offset="[0, 8]">Carregando...</q-tooltip>
    </div>
    <div v-show="loadingDataSourceConfig == false">
      <dx-data-grid
        id="grid-padrao"
        ref="grid-padrao"
        class="dx-card wide-card-gc"
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
        :row-alternation-enabled="false"
        :repaint-changes-only="true"
        :autoNavigateToFocusedRow="true"
        :cacheEnable="false"
        noDataText="Sem dados"
        @focused-row-changed="onFocusedRowChanged"
        @selection-Changed="TrocaLinha"
        @row-dbl-click="DBClick($event.data)"
        @contentReady="onDataSource"
        @selectionChanged="LinhasSelecionadas"
      >
        <DxGroupPanel
          v-if="filterGrid == true"
          :visible="true"
          empty-panel-text="agrupar..."
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

        <DxPaging :enable="true" :page-size="20" />

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
  DxMasterDetail,
  DxSearchPanel,
} from "devextreme-vue/data-grid";

import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";

import Lookup from "../http/lookup";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import formataData from "../http/formataData";
import Incluir from "../http/incluir_registro";

let sParametroApi = "";

var data_selecionada = {};

export default {
  props: {
    cd_menuID: { type: Number, default: 0 },
    cd_apiID: { type: Number, default: 0 },
    cd_identificacaoID: { type: Number, default: 0 },
    cd_parametroID: { type: Number, default: 0 },
    cd_tipo_consultaID: { type: Number, default: 0 },
    cd_consulta: { type: Number, default: 0 },
    // eslint-disable-next-line vue/require-valid-default-prop
    nm_json: { type: Object, default: {} },
    att_json: { type: Boolean, default: false },
    filterGrid: { type: Boolean, default: true },
    masterDetail: { type: Boolean, default: false },
    multipleSelection: { type: Boolean, default: false },
    selectAll: { type: Boolean, default: false },
  },
  emits: ["Linha", "dadosgrid", "emit-click"],

  Selecionada() {
    return data_selecionada;
  },

  data() {
    return {
      tituloMenu: "",
      linha: {},
      dt_inicial: "",
      dt_final: "",
      columns: [],
      list_atributos: [],
      Icone: [],
      Cor: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      total: {},
      cd_empresa: localStorage.cd_empresa,
      cd_menu: 0,
      dados_menu: {},
      cd_cliente: 0,
      cd_api: 0,
      cd_modulo: localStorage.cd_modulo,
      api: 0,
      tituloColuna: [],
      loadingDataSourceConfig: false,
    };
  },

  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    this.Icone = await Lookup.montarSelect(this.cd_empresa, 5405);
    this.Icone = JSON.parse(JSON.parse(JSON.stringify(this.Icone.dataset)));

    this.Cor = await Lookup.montarSelect(this.cd_empresa, 5641);
    this.Cor = JSON.parse(JSON.parse(JSON.stringify(this.Cor.dataset)));

    await this.carregaDados();
    this.linha = this.dataSourceConfig || this.dataSourceConfig[0];
    data_selecionada = {};
    this.cd_modulo = localStorage.cd_modulo;
  },
  async beforeDestroy() {
    this.linha = this.dataSourceConfig || this.dataSourceConfig[0];
  },

  components: {
    DxDataGrid,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxMasterDetail,
    DxGrouping,
    DxColumnChooser,
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxSelection,
    DxStateStoring,
    DxSearchPanel,
  },
  watch: {
    selectAll(novo) {
      if (novo) {
        this.grid.selectAll();
      } else {
        this.grid.deselectAll();
      }
    },
    att_json() {
      this.gridPost();
    },
  },
  computed: {
    grid() {
      return this.$refs["grid-padrao"].instance;
    },
  },
  methods: {
    async FiltraGrid(prop) {
      if (prop == "") {
        await this.carregaDados();
      } else {
        this.dataSourceConfig = this.dataSourceConfig.filter((el) => {
          return (
            el.cd_consulta
              .toString()
              .toLowerCase()
              .indexOf(prop.toLowerCase()) > -1
          );
        });
      }

      return this.dataSourceConfig;
    },
    selectionChanged(e) {
      e.component.collapseAll(-1);
      e.component.expandRow(e.currentSelectedRowKeys[0]);
    },

    TrocaLinha({ selectedRowKeys, selectedRowsData }) {
      if (this.multipleSelection == false) {
        this.linha = selectedRowsData[0] || selectedRowKeys;
        this.$emit("linha", this.linha);
      } else {
        this.linha = selectedRowsData;
        this.$emit("linha", this.linha);
      }
    },

    onDataSource() {
      this.$emit("dadosgrid", this.dataSourceConfig);
    },

    LinhasSelecionadas() {
      this.$emit("LinhasSelecionadas", this.grid.getSelectedRowsData());
    },

    DBClick(e) {
      this.linha = e;
      this.$emit("emit-click", e);
    },

    DataSource() {
      return this.dataSourceConfig.length;
    },

    async showMenu() {
      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_menu = this.cd_menuID;
      this.cd_api = this.cd_apiID;
      this.api = "";
      //parametro de Pesquisa

      localStorage.cd_identificacao = 0;
      localStorage.cd_parametro = 0;

      if (!this.cd_parametroID == 0) {
        localStorage.cd_parametro = this.cd_parametroID;
      }

      if (!this.cd_identificacaoID == 0) {
        localStorage.cd_identificacao = this.cd_identificacaoID;
      }
      if (!this.cd_tipo_consultaID == 0) {
        localStorage.cd_tipo_consulta = this.cd_tipo_consultaID;
      }

      let dados = await Menu.montarMenu(
        this.cd_empresa,
        this.cd_menu,
        this.cd_api
      );
      this.dados_menu = dados;
      sParametroApi = dados.nm_api_parametro;

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.api_param;
      }
      //localStorage.cd_tipo_consulta = 0;

      if (!dados.cd_tipo_consulta == 0) {
        dados.cd_tipo_consulta;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      if (dados.tituloColunaF != "") {
        this.tituloColuna = JSON.parse(dados.tituloColunaF);
      }
      //this.tituloColuna = ["Título", "Documento"];
      if (dados.coluna != "") {
        this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
        this.list_atributos = this.columns.filter(
          (e) => e.ic_cab_etapa_atributo === "S"
        );
      }
      this.list_atributos.map((i) => {
        [i.icone] = this.Icone.filter(
          (e) => e.cd_icone === parseInt(i.cd_icone)
        );
        [i.cor] = this.Cor.filter((c) => c.cd_cor === parseInt(i.cd_cor));
      });
      //dados do total - Kelvin... Coluna estava gerando erro quando não há total - 19.07
      if (dados.coluna_total != "") {
        this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      }
    },

    retorno() {
      return this.dataSourceConfig;
    },

    //
    //mágica - carrego o Json com o Resulta do Stored procedure
    //
    async gridPost() {
      this.loadingDataSourceConfig = true;
      let copy = this.dataSourceConfig;
      this.dataSourceConfig = [];
      try {
        this.dataSourceConfig = await Incluir.incluirRegistro(
          this.api,
          this.nm_json
        );
        this.loadingDataSourceConfig = false;
      } catch (error) {
        this.loadingDataSourceConfig = false;
        this.dataSourceConfig = copy;
      }
    },

    async carregaDados() {
      if (this.cd_consulta === 0) {
        //localStorage.cd_parametro = 0;
        await this.showMenu();

        notify("Aguarde... estamos montando a consulta para você, aguarde !");

        let sApi = sParametroApi;
        //
        //
        if (!sApi == "" && this.dados_menu.ic_procedimento_crud != "S") {
          try {
            this.loadingDataSourceConfig = true;
            this.dataSourceConfig = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_cliente,
              this.api,
              sApi
            );
            if (this.dataSourceConfig) {
              this.list_atributos.map((i) => {
                i.valor = this.dataSourceConfig.find((d) => {
                  return Object.keys(d).find((k) => {
                    if (k.trim() === i.dataField) {
                      return d;
                    }
                  });
                });
              });
              if (this.dataSourceConfig && this.dataSourceConfig[0].Data) {
                this.dataSourceConfig[0].Data = await formataData.formataDataJS(
                  this.dataSourceConfig[0].Data
                );
              }
              if (this.dataSourceConfig && this.dataSourceConfig.length == 0) {
                this.linha = this.dataSourceConfig[0];
              }
            }
          } catch (error) {
            await this.gridPost();
          }
          this.loadingDataSourceConfig = false;

          localStorage.cd_parametro = 0;
          localStorage.cd_identificacao = 0;
        } else {
          await this.gridPost();
        }
      } else if (this.cd_consulta != 0) {
        await this.showMenu();
        await this.gridPost();
      }
    },

    TrocaInfo(a) {
      a = this.grid.Selecionada();
      return a;
    },

    onFocusedRowChanged: function (e) {
      data_selecionada = {};
      data_selecionada = e.row && e.row.data;
    },

    destroyed() {
      this.$destroy();
    },
  },
};
</script>

<style scoped>
@import url("./views.css");
form {
  margin-left: 10px;
  margin-right: 10px;
  padding-left: 10px;
  padding-right: 10px;
  margin-top: 5px;
}

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
  margin-right: 40px;
}

#taskProgress {
  line-height: 42px;
  font-size: 40px;
  font-weight: bold;
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

.info-periodo {
  margin-top: 10px;
  float: right;
  margin-right: 25px;
  right: 10px;
  font-size: 16px;
}
#grid-padrao {
  height: 90vh !important;
  width: 98vw !important;
  max-height: 90vh !important;
  max-width: 98vw !important;
  min-height: 0;
  min-width: 0;
}
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}

.item-grid {
  display: flex;
  flex-wrap: wrap;
}
</style>
