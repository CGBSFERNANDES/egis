<template>
  <div>
    <div class="row">
      <div
        class="margin1 col-3"
        v-for="(item, indx) in filtros_campos"
        :key="indx"
      >
        <q-input v-model="item.nm_valor" :label="item.nm_atributo_consulta" />
      </div>
    </div>
    <div class="row" style="justify-content: center">
      <q-btn
        class="col-8 margin1"
        rounded
        color="orange-9"
        text-color="white"
        size="lg"
        label="Buscar"
        icon="search"
        :loading="load_grid"
        @click="pesquisaTabela()"
      />

      <q-btn
        class="col-2 margin1"
        rounded
        color="orange-9"
        text-color="white"
        icon="add"
        size="lg"
        label="Novo"
        :loading="load_grid"
        @click="onNovoForm()"
      />
    </div>
    <!-- Grid -->
    <div v-if="dataSourceConfig.length > 0">
      <div class="row q-gutter-x-sm items-center">
        <div class="col-auto" style="font-size: 25px">
          Resultado da Pesquisa
        </div>
        <q-btn
          class="col-auto"
          rounded
          color="orange-9"
          text-color="white"
          style="text-transform: none; margin: 5px"
          label="Selecionar"
          :loading="load_grid"
          @click="DBClick($event.data)"
        />
      </div>

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
        @row-dbl-click="DBClick($event.data)"
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
    </div>
    <!-- Chamando Form Especial no Atributo -->
    <q-dialog
      v-model="pop_atributo"
      persistent
      maximized
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-9 text-white">
          {{ `${dataSourcePesquisa.nm_apresenta_atributo}` }}
          <q-space />
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section class="q-pt-none">
          <auto-form
            v-if="this.dataSourcePesquisa.cd_form_especial"
            :cd_formID="this.dataSourcePesquisa.cd_form_especial"
            :cd_apiID="parseInt(this.dataSourcePesquisa.cd_api)"
            :cd_menuID="parseInt(this.dataSourcePesquisa.cd_menu)"
            :cd_documentoID="this.dataSourcePesquisa.cd_documento"
            @click="fechaPopup($event)"
          />
        </q-card-section>
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
  DxMasterDetail,
  DxSearchPanel,
} from "devextreme-vue/data-grid";
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import select from "../http/select";

export default {
  name: "pesquisa-padrao",
  props: {
    dataSourcePesquisa: {
      type: Object,
      default() {
        return {};
      },
    },
  },

  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      filtros_campos: {},
      dataSourceConfig: [],
      columns: [],
      total: {},
      pageSizes: [10, 20, 50, 100],
      linha_selecionada: {},
      load_grid: false,
      filterGrid: true,
      masterDetail: false,
      multipleSelection: false,
      pop_atributo: false,
    };
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
    autoForm: () => import("../views/autoForm.vue"),
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    let filtro_json = {
      cd_empresa: null,
      cd_tabela: 719,
      order: "D",
      where: [
        {
          cd_tabela: this.dataSourcePesquisa.cd_tabela_pesquisa,
          ic_edita_pesquisa_atributo: "S",
          ic_resultado_pesquisa_atributo: "S",
        },
      ],
    };
    let [filter_campos] = await select.montarSelect("0", filtro_json);
    this.filtros_campos = JSON.parse(filter_campos.dataset);
  },

  methods: {
    onFocusedRowChanged: function (e) {
      this.linha_selecionada = {};
      this.linha_selecionada = e.row && e.row.data;
    },
    DBClick() {
      if (this.linha_selecionada.cd_controle) {
        this.$emit("dadosSelecionados", this.linha_selecionada);
      } else {
        notify("Selecione um Registro");
      }
    },
    onNovoForm() {
      this.pop_atributo = !this.pop_atributo;
    },
    async pesquisaTabela() {
      try {
        this.load_grid = true;
        let obj_pesquisa = {};
        this.filtros_campos.forEach((item) => {
          obj_pesquisa[item.nm_atributo] = item.nm_valor || null;
        });
        if (this.columns.length == 0) {
          let json_pesquisa_tabela_colunas = {
            cd_parametro: 1,
            cd_tabela: this.dataSourcePesquisa.cd_tabela_pesquisa,
            cd_usuario: localStorage.cd_usuario,
            ...obj_pesquisa,
          };
          let [colunas] = await Incluir.incluirRegistro(
            "937/1450",
            json_pesquisa_tabela_colunas
          );
          this.columns = JSON.parse(colunas.colunas);
        }
        let json_pesquisa_tabela = {
          cd_parametro: 2,
          cd_tabela: this.dataSourcePesquisa.cd_tabela_pesquisa,
          cd_usuario: localStorage.cd_usuario,
          ...obj_pesquisa,
        };
        this.dataSourceConfig = await Incluir.incluirRegistro(
          "937/1450",
          json_pesquisa_tabela
        );
        if (this.dataSourceConfig.length == 0) {
          notify("Nenhum registro encontrado");
        }
      } catch (error) {
        console.error(error);
      } finally {
        this.load_grid = false;
      }
    },
  },
};
</script>

<style scoped>
@import url("../views/views.css");
</style>
