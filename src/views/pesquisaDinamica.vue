<template>
  <div>
    <transition name="slide-fade">
      <div class="text-h6 text-bold margin1 row" v-show="!!tituloMenu == true">
        <div class="col-8">
          {{ tituloMenu }}
        </div>
        <div class="col">
          <q-btn
            style="float:right;"
            round
            flat
            v-show="!!ds_menu_descritivo == true"
            color="black"
            @click="popupVisible = true"
            icon="info"
          />
        </div>
      </div>
    </transition>
    <!--Card header-->
    <q-card style="width: auto; border-radius: 20px; " class="margin1">
      <div
        v-for="(e, index) in objectInput"
        :key="index"
        class="row justify-around items-center"
        style="display:inline-flex"
      >
        <q-select
          v-if="e.typeVar == 'select'"
          v-model="e.modelValue"
          :options="e.modelOptions"
          :option-value="e.modelOptionValue"
          :option-label="e.modelOptionName"
          :style="e.style"
          class="margin1 pesquisa"
          :label="e.nm_campo"
        >
          <template v-slot:prepend>
            <q-icon :name="e.icon" />
          </template>
        </q-select>

        <q-input
          v-else
          @keyup.enter="carregaDados()"
          v-model="e.modelValue"
          :type="e.typeVar"
          class="margin1 pesquisa "
          :label="e.nm_campo"
        >
          <template v-slot:prepend>
            <q-icon :name="e.icon" />
          </template>
        </q-input>
      </div>

      <div class="row">
        <q-btn
          color="orange-9"
          rounded
          icon="search"
          class="margin1"
          label="Pesquisar"
          @click="carregaDados()"
        />
      </div>
    </q-card>

    <div>
      <transition name="slide-fade">
        <DxDataGrid
          class="margin1"
          :show-borders="true"
          :data-source="dataSourceConfig"
          :columns="columns"
          :summary="total"
          key-expr="cd_controle"
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
          ><!--
 <DxColumnChooser :enabled="true" />
             <DxColumnFixing :enabled="true" />

        <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

        <DxGrouping :auto-expand-all="true" />

        <DxExport :enabled="true" />

        <DxPaging :page-size="10" />
        <DxStateStoring
          :enabled="true"
          type="localStorage"
          storage-key="storageGrid"
        />
        <DxPager
          :show-page-size-selector="true"
          :allowed-page-sizes="pageSizes"
          :show-info="true"
        />
        <DxFilterRow :visible="false" />
        <DxHeaderFilter :visible="true" :allow-search="true" />
        <DxFilterPanel :visible="true" />
      

    -->
        </DxDataGrid>
      </transition>
    </div>

    <!--Informativo cadastrado no MENU-->
    <q-dialog v-model="popupVisible">
      <q-card style="width: 700px; max-width: 80vw;">
        <q-card-section>
          <div class="text-h6">Informativo - {{ tituloMenu }}</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          {{ ds_menu_descritivo }}
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="OK" rounded color="primary" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!--A loading screen.-->
    <q-dialog maximized v-model="load" persistent>
      <carregando
        v-if="load == true"
        :corID="'orange-9'"
        :mensagemID="msg"
      ></carregando>
    </q-dialog>
  </div>
</template>

<script>
import Menu from "../http/menu";
import funcao from "../http/funcoes-padroes";
import Incluir from "../http/incluir_registro";

import {
  DxDataGrid,
  DxColumn,
  //DxFilterRow,
  //DxPager,
  //DxPaging,
  //DxExport,
  //DxGroupPanel,
  //DxGrouping,
  //DxColumnChooser,
  //DxColumnFixing,
  //DxHeaderFilter,
  //DxFilterPanel,
  //DxSelection,
  //DxStateStoring,
  //DxSearchPanel,
} from "devextreme-vue/data-grid";

export default {
  props: {
    cd_tipo_pesquisaID: { type: Number, default: 0 },
    apiID: { type: String, default: "" },
    cd_parametroID: { type: Number, default: 0 },
    objectInput: {
      type: Array,
      default: [
        //{
        //  nm_campo: "Tipo Pesquisa",
        //  typeVar: "select",
        //  modelValue: "",
        //  icon: "format_list_bulleted",
        //  modelOptionValue: "",
        //  modelOptionName: "",
        //  style: "float:left",
        //  modelOptions: [],
        //},
        {
          nm_campo: "Processo",
          typeVar: "Number",
          modelValue: "",
          icon: "search",
        },
      ],
    },
  },
  name: "pesquisaDinamica",
  // A dynamic import.

  components: {
    carregando: () => import("../components/carregando.vue"),
    grid: () => import("../views/grid.vue"),
    DxDataGrid,
    DxColumn,
    //DxFilterRow,
    //DxPager,
    //DxPaging,
    //DxExport,
    //DxGroupPanel,
    //DxGrouping,
    //DxColumnChooser,
    //DxColumnFixing,
    //DxHeaderFilter,
    //DxFilterPanel,
    //DxSelection,
    //DxStateStoring,
    //DxSearchPanel,
  },
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_menu: localStorage.cd_menu,
      cd_usuario: localStorage.cd_usuario,
      cd_api: localStorage.cd_api,
      api: "",
      tituloMenu: "",
      ds_menu_descritivo: "",
      pageSizes: [10, 20, 50, 100],
      nm_campo_pesquisa: "",
      popupVisible: false,
      load: false,
      msg: "Aguarde...",
      columns: [],
      total: [],
      dataSourceConfig: [],
    };
  },
  // An asynchronous function that is called when the component is created.
  async created() {
    //Verifica se existe a api via props, se não existir ele busca o montar menu
    if (!!this.apiID == false) {
      try {
        this.msg = "Carregando menu...";
        this.load = true;
        var dados = await Menu.montarMenu(
          this.cd_empresa,
          this.cd_menu,
          this.cd_api
        );
        // Setting the data properties to the values returned from the API.
        this.tituloMenu = dados.nm_menu_titulo;
        this.api = dados.nm_identificacao_api;
        this.ds_menu_descritivo = dados.ds_menu_descritivo;

        this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
        this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      } catch (error) {
        this.load = false;
      }
      this.load = false;
    }
    this.msg = "Carregando...";
    await this.CorrigeProps();
  },
  methods: {
    async CorrigeProps() {
      if (this.cd_menu == 6762) {
        for (let y = 0; y < this.objectInput.length; y++) {
          if (this.objectInput[y].typeVar == "select") {
            if (!!this.objectInput[y].modelOptionValue == false) {
              this.objectInput[y].modelOptionValue = "cd_pesquisa";
            }
            if (!!this.objectInput[y].modelOptionName == false) {
              this.objectInput[y].modelOptionName = "nm_pesquisa";
            }
            if (this.objectInput[y].modelOptions.length == 0) {
              this.objectInput[y].modelOptions = [
                {
                  cd_pesquisa: 1,
                  nm_pesquisa: "Código Interno",
                },
                {
                  cd_pesquisa: 2,
                  nm_pesquisa: "Identificação",
                },
                {
                  cd_pesquisa: 3,
                  nm_pesquisa: "Descrição",
                },
                {
                  cd_pesquisa: 4,
                  nm_pesquisa: "Produto",
                },
                {
                  cd_pesquisa: 5,
                  nm_pesquisa: "No.Desenho",
                },
              ];
            }
          }
        }
      }
    },

    async carregaDados() {
      this.msg = "Buscando informações";
      this.load = true;
      this.dataSourceConfig = [];

      try {
        // Creating an object with the properties of the objectInput array.
        var linha = {
          cd_usuario: this.cd_usuario,
          cd_empresa: this.cd_empresa,
          cd_parametro: this.cd_parametroID,
        };
        for (let a = 0; a < this.objectInput.length; a++) {
          let value;
          if (this.objectInput[a].typeVar == "select") {
            let campoValor = this.objectInput[a].modelOptionValue;

            linha["nm_campo" + a] = this.objectInput[a].modelValue[campoValor];
          } else {
            value = this.objectInput[a].modelValue;
            linha["nm_campo" + a] = value;
          }
        }
        // Calling a function that returns a promise.

        this.dataSourceConfig = await Incluir.incluirRegistro(this.api, linha);
        this.load = false;
      } catch (error) {
        this.load = false;
      }
      this.load = false;
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
}
/* Enter and leave animations can use different */
/* durations and timing functions.              */
.slide-fade-enter-active {
  transition: all 0.3s ease;
}
.slide-fade-leave-active {
  transition: all 0.4s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter, .slide-fade-leave-to
/* .slide-fade-leave-active below version 2.1.8 */ {
  transform: translateX(10px);
  opacity: 0;
}
.pesquisa {
  width: 45vw !important;
}
</style>
