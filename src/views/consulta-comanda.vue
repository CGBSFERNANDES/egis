<template>
  <div>
    <div>
      <h2 class="content-block h2">{{ tituloMenu }}</h2>
    </div>

    <div class="tela-toda">
      <q-input
        class="meia-tela margin1"
        type="number"
        @blur="PesquisaComanda()"
        v-model="cd_comanda"
        label="Comanda"
      >
        <template v-slot:prepend>
          <q-icon name="assignment" />
        </template>
      </q-input>

      <q-input
        class="meia-tela margin1"
        v-model="cd_cliente_selecionado"
        label="Cliente"
        readonly
      >
        <template v-slot:prepend>
          <q-icon name="person" />
        </template>
      </q-input>
    </div>

    <div v-if="mostra_grid == true">
      <dx-data-grid
        id="grid-padrao"
        class="dx-card wide-card"
        style="border-radius: 10px"
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
        :focused-row-index="0"
        :cacheEnable="false"
        :selectedrow-keys="selectedRowKeys"
      >
        <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
        <DxStateStoring
          :enabled="true"
          type="localStorage"
          storage-key="storage"
        />
        <DxGrouping :auto-expand-all="true" />
        <DxPaging :page-size="10" />
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
        <DxForm :form-data="formData" :items="items">
          <DxItem :col-count="2" :col-span="2" item-type="group" />
        </DxForm>
      </dx-data-grid>
    </div>

    <div class="row" v-else>
      <b class="col text-center text-h6">{{ dataSourceConfig[0].Msg }}</b>
    </div>
  </div>
</template>

<script>
import {
  DxDataGrid,
  DxColumn,
  DxPaging,
  DxSelection,
  DxLookup,
} from "devextreme-vue/data-grid";

import {
  DxFilterRow,
  DxPager,
  DxGroupPanel,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxStateStoring,
  DxSearchPanel,
} from "devextreme-vue/data-grid";

import { DxForm, DxItem } from "devextreme-vue/form";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import notify from "devextreme/ui/notify";

var sParametroApi = "";

export default {
  props: {
    cd_comandaID: { type: Number, default: 0 },
  },
  data() {
    return {
      dados: [],
      dataSourceConfig: [],
      columns: [],
      selectedRowKeys: [],
      total: {},
      items: [],
      formData: {},
      refreshMode: "reshape",
      allMode: "allPages",
      checkBoxesMode: "onClick",
      temPanel: false,
      sorteado: "",
      pageSizes: [10, 20, 50, 100],
      sApis: "",
      nm_json: {},
      row: {},
      mostra_grid: true,
      cd_empresa: 0,
      cd_cliente: 0,
      cd_api: "",
      cd_cliente_selecionado: "",
      tituloMenu: "",
      cd_comanda: "",
      ativa_grid: false,
      sParametroApi: "",
      iConsumo: 0,
    };
  },

  async created() {
    this.cd_comanda = "";
    if (!this.cd_comandaID == 0) {
      this.cd_comanda = this.cd_comandaID;
    }

    await this.showMenu();
  },

  components: {
    DxDataGrid,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxGroupPanel,
    DxGrouping,
    DxColumnChooser,
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxSelection,
    DxStateStoring,
    DxSearchPanel,
    DxForm,
    DxItem,
  },

  methods: {
    async showMenu() {
      var dados = await Menu.montarMenu(
        localStorage.cd_empresa,
        localStorage.cd_menu,
        localStorage.cd_api
      );
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      sParametroApi = dados.nm_api_parametro;
      this.tituloMenu = dados.nm_menu_titulo;
    },

    async carregaDados() {
      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_api = localStorage.nm_identificacao_api; //pr_consulta_registro_venda

      let sApis = sParametroApi;
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        localStorage.nm_identificacao_api,
        sApis
      );
      if (this.dataSourceConfig[0].Cod == 0) {
        this.cd_cliente_selecionado = "";
        this.mostra_grid = false;
        notify(this.dataSourceConfig[0].Msg);
        return;
      } else {
        this.mostra_grid = true;
      }
      this.dataSourceConfig.length == 0
        ? notify("A Comanda selecionada não está em aberto!")
        : (this.cd_cliente_selecionado =
            this.dataSourceConfig[0].nm_fantasia_cliente);
      this.iConsumo = 0;
      if (!this.cd_cliente_selecionado == "") {
        iConsumo = 1;
      }
    },

    async PesquisaComanda() {
      localStorage.cd_parametro = this.cd_comanda;
      await this.carregaDados();
    },
  },
};
</script>

<style scoped>
.tela-toda {
  width: 100%;
}

.margin1 {
  margin: 0.7vw 1vw;
}
.meia-tela {
  width: 47%;
  display: inline-flex;
}
.no-wrap {
  flex-wrap: wrap !important;
}
#grid-padrao {
  max-height: 600px !important;
}
@media (max-width: 580px) {
  .meia-tela {
    width: 100% !important;
  }
}
</style>