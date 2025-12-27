<!-- eslint-disable no-console -->
<template>
  <div class="margin1">
    <div
      class="margin1"
      style="display: flex; align-items: center; justify-content: center"
    >
      <q-btn
        rounded
        color="orange-9"
        text-color="white"
        size="lg"
        label="Cópia de Tabela de Preço"
      />
    </div>
    <div class="row">
      <q-select
        dense
        use-input
        hide-selected
        fill-input
        class="metadeTela margin1"
        label="Tabela Origem"
        v-model="tabela_preco_origem"
        input-debounce="0"
        :loading="load_grid"
        :options="dados_lookup_tabela_preco"
        option-value="cd_tabela_preco"
        option-label="nm_tabela_preco"
        @input="consultarTabelaOrigem()"
      >
        <template v-slot:prepend>
          <q-icon name="table_view" />
        </template>
      </q-select>
      <q-select
        v-if="tabela_preco_origem"
        dense
        use-input
        hide-selected
        fill-input
        class="metadeTela margin1"
        label="Tabela Destino"
        v-model="tabela_preco_destino"
        input-debounce="0"
        :loading="load_grid"
        :options="dados_lookup_tabela_preco"
        option-value="cd_tabela_preco"
        option-label="nm_tabela_preco"
      >
        <template v-slot:prepend>
          <q-icon name="table_view" />
        </template>
      </q-select>
    </div>
    <!--  -->
    <div>
      <q-btn
        rounded
        label="Transferir"
        type="submit"
        color="orange-9"
        icon="save"
        :loading="load_copiar"
        @click="onSalvarRegistro"
      />
      <q-btn
        rounded
        label="Limpar"
        type="reset"
        color="orange-9"
        flat
        class="q-ml-sm"
        icon="cleaning_services"
        @click="onLimparRegistro"
      />
      <q-btn
        rounded
        label="Fechar"
        type="reset"
        color="orange-9"
        flat
        class="q-ml-sm"
        icon="close"
        @click="onFechar"
      />
    </div>
    <div v-if="jsonData.length > 0">
      <div class="tabOrigem margin1">Tabela Origem</div>
      <dx-data-grid
        id="grid-padrao"
        ref="grid-padrao"
        class="margin1 dx-card wide-card-gc"
        key-expr="cd_controle"
        :focused-row-key="0"
        :data-source="jsonData"
        :columns="columns"
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
        @contentReady="onDataSource"
      >
        <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

        <DxGrouping :auto-expand-all="true" />
        <DxExport :enabled="true" />

        <DxPaging :enable="true" :page-size="10" />

        <DxStateStoring
          :enabled="true"
          type="localStorage"
          storage-key="storage"
        />
        <DxPager
          :show-page-size-selector="true"
          :allowed-page-sizes="[10, 20, 50, 100]"
          :show-info="true"
        />
        <DxHeaderFilter
          :visible="true"
          :allow-search="true"
          :width="400"
          :height="400"
        />
        <DxSearchPanel :visible="true" :width="300" placeholder="Procurar..." />
        <DxColumnChooser :enabled="true" mode="select" />
      </dx-data-grid>
    </div>
    <!--------CARREGANDO---------------------------------------------------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando mensagemID="carregando..."></carregando>
    </q-dialog>
    <!------------------------------------------------------------------------------------>
  </div>
</template>
  
  <script>
import {
  DxDataGrid,
  DxPager,
  DxPaging,
  DxExport,
  DxGroupPanel,
  DxGrouping,
  DxColumnChooser,
  DxHeaderFilter,
  DxStateStoring,
  DxSearchPanel,
} from "devextreme-vue/data-grid";

import "devextreme-vue/text-area";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import carregando from "@/components/carregando.vue";
import ExcelJS from "exceljs";

export default {
  components: {
    DxDataGrid,
    carregando,
    DxPager,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxGrouping,
    DxColumnChooser,
    DxHeaderFilter,
    DxStateStoring,
    DxSearchPanel,
  },
  name: "copiaTabelaPreco",
  data() {
    return {
      cd_modulo: localStorage.cd_modulo,
      cd_usuario: localStorage.cd_usuario,
      dados: [],
      jsonData: [],
      columns: [
        {
          dataField: "nm_tabela_preco",
          caption: "Tabela Preço",
          dataType: "string",
          alignment: "center",
        },
        {
          dataField: "sg_tabela_preco",
          caption: "Sigla",
          dataType: "string",
          alignment: "center",
        },
        {
          dataField: "vl_tabela_produto",
          caption: "Valor",
          dataType: "string",
          alignment: "center",
        },
        {
          dataField: "cd_produto",
          caption: "Cod. Produto",
          dataType: "number",
          alignment: "center",
        },
        {
          dataField: "cd_mascara_produto",
          caption: "Máscara",
          dataType: "string",
          alignment: "center",
        },
        {
          dataField: "nm_produto",
          caption: "Produto",
          dataType: "string",
          alignment: "center",
        },
        {
          dataField: "nm_fantasia_produto",
          caption: "Fantasia",
          dataType: "string",
          alignment: "center",
        },
        {
          dataField: "cd_controle",
          caption: "Controle",
          dataType: "number",
          alignment: "center",
        },
      ],
      firstTabsheet: "",
      dados_lookup_tabela_preco: [],
      tabela_preco_origem: "",
      tabela_preco_destino: "",
      ic_alerta: false,
      msg_alerta: "",
      api: "930/1440",
      load: false,
      load_grid: false,
      load_copiar: false,
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
  },

  async mounted() {
    try {
      this.load = true;
      let carregaDataSouce = {
        cd_parametro: 0,
        cd_usuario: this.cd_usuario,
      };
      this.dados_lookup_tabela_preco = await Incluir.incluirRegistro(
        this.api,
        carregaDataSouce
      ); //pr_copia_tabela_preco_produto
      this.load = false;
    } catch (error) {
      this.load = false;
    }
  },
  computed: {
    grid() {
      return this.$refs["grid-padrao"].instance;
    },
  },
  methods: {
    onDataSource() {
      this.grid.selectRows([this.jsonData[0]]);
    },
    async onSalvarRegistro() {
      try {
        if (
          this.tabela_preco_origem.cd_tabela_preco &&
          this.tabela_preco_destino.cd_tabela_preco
        ) {
          let json_copia_tabela = {
            cd_parametro: 2,
            cd_tabela_preco_origem: this.tabela_preco_origem.cd_tabela_preco,
            cd_tabela_preco_destino: this.tabela_preco_destino.cd_tabela_preco,
            cd_usuario: this.cd_usuario,
          };
          try {
            let [result] = await Incluir.incluirRegistro(
              this.api,
              json_copia_tabela
            ); //pr_copia_tabela_preco_produto
            if (result.cd_movimento != 0) {
              this.onFechar();
            }
            if (result.ic_alerta == "S") {
              this.ic_alerta = true;
              this.msg_alerta = result.Msg;
              return;
            }
            if (result.Msg !== "") {
              notify(result.Msg);
            } else {
              notify("Tabela de Preço copiada com sucesso");
            }
          } catch (error) {
            notify("Não foi possivel copiar a tabela de preço");
          }
        } else {
          notify("Selecione uma tabela de origem e de destino para copiar");
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
      } finally {
        this.load_copiar = false;
      }
      return;
    },
    onLimparRegistro() {
      this.dados_lookup_tabela_preco.map((tab) => {
        tab.disable = false;
      });
      this.tabela_preco_origem = "";
      this.tabela_preco_destino = "";
      this.jsonData = [];
    },
    onFechar() {
      this.onLimparRegistro();
      this.$emit("click");
    },
    async consultarTabelaOrigem() {
      try {
        this.load = true;
        let carregaDataSouce = {
          cd_parametro: 1,
          cd_tabela_preco: this.tabela_preco_origem.cd_tabela_preco,
          cd_usuario: this.cd_usuario,
        };
        this.jsonData = await Incluir.incluirRegistro(
          this.api,
          carregaDataSouce
        ); //pr_copia_tabela_preco_produto
        this.dados_lookup_tabela_preco.map((tab) => {
          if (
            tab.cd_tabela_preco === this.tabela_preco_origem.cd_tabela_preco
          ) {
            tab.disable = true;
          } else {
            tab.disable = false;
          }
        });
        this.load = false;
      } catch (error) {
        this.load = false;
      }
    },
  },
};
</script>
  
  <style scoped>
@import url("../views/views.css");

.tabOrigem {
  font-weight: bold;
  font-size: 20px;
}
</style>
  