<!-- eslint-disable no-console -->
<template>
  <div>
    <div
      class="margin1"
      style="display: flex; align-items: center; justify-content: center"
    >
      <q-btn
        rounded
        color="orange-9"
        text-color="white"
        size="lg"
        label="Importação"
      />
    </div>
    <div class="text-h5 text-bold margin1">
      <q-badge v-if="prop_form.cd_movimento" align="top" color="blue">
        {{ prop_form.cd_movimento }}
      </q-badge>
    </div>

    <!-- Selects do Processo_Sistema -->
    <div class="row">
      <q-select
        dense
        use-input
        hide-selected
        fill-input
        class="metadeTela margin1"
        label="Modelo de Carga"
        v-model="importacao"
        input-debounce="0"
        :loading="load_grid"
        :options="dados_lookup_importacao"
        option-value="cd_modelo"
        option-label="nm_modelo"
      >
        <template v-slot:prepend>
          <q-icon name="publish" />
        </template>
      </q-select>
      <q-file
        v-if="importacao"
        dense
        use-input
        hide-selected
        fill-input
        class="metadeTela margin1 col-5"
        v-model="arq_upload"
        :loading="load_grid"
        label="Selecionar Arquivo"
        accept=".xls, .xlsx"
        @input="onFile($event)"
      >
        <template v-slot:prepend>
          <q-icon name="description" />
        </template>
      </q-file>
    </div>
    <!--  -->
    <div>
      <q-btn
        rounded
        label="Importar"
        type="submit"
        color="orange-9"
        icon="save"
        :loading="load_importar"
        @click="onSalvarRegistro"
      />
      <q-btn
        v-if="importacao.nm_local_modelo_planilha"
        rounded
        :label="`${importacao.nm_modelo_planilha || 'Modelo de planilha'}`"
        type="reset"
        color="orange-9"
        class="q-ml-sm"
        icon="description"
        @click="onBaixarModelo"
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
    <!--------SOLICITAÇÃO DE SENHA---------------------------------------------------------------------------->
    <q-dialog v-model="pop_senha" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Insira a senha</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            label="Senha"
            dense
            v-model="nm_senha"
            :type="isPwd ? 'password' : 'text'"
            autofocus
            @keyup.enter="confirmaSenha()"
          >
            <template v-slot:append>
              <q-icon
                :name="isPwd ? 'visibility_off' : 'visibility'"
                class="cursor-pointer"
                @click="isPwd = !isPwd"
              />
            </template>
          </q-input>
        </q-card-section>

        <q-card-actions align="right" class="text-white">
          <q-btn
            rounded
            color="orange-9"
            class="q-ml-sm"
            icon="check"
            label="Confirmar"
            @click="confirmaSenha()"
          />
          <q-btn
            rounded
            color="orange-9"
            flat
            class="q-ml-sm"
            icon="close"
            label="Fechar"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!--------VALIDAÇÃO IMPORTAÇÃO PROCEDURE---------------------------------------------------------------------------->
    <q-dialog v-model="ic_alerta" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <q-avatar icon="warning" color="warning" text-color="white" />
          <div class="text-h6">Alerta</div>
        </q-card-section>
        <q-card-section class="q-pt-none listNotImport">
          <p>{{ `${msg_alerta}` }}</p>
        </q-card-section>

        <q-card-actions align="right" class="text-white">
          <q-btn
            rounded
            color="orange-9"
            flat
            class="q-ml-sm"
            icon="close"
            label="Fechar"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
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
import carregando from "./carregando.vue";
import ExcelJS from "exceljs";
import funcao from "../http/funcoes-padroes.js";

export default {
  props: {
    cd_formID: { type: Number, default: 0 },
    cd_documentoID: { type: Number, default: 0 },
    cd_item_documentoID: { type: Number, default: 0 },
    prop_form: {
      type: Object,
      default() {
        return {};
      },
    },
  },
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
  name: "importacaoSistema",
  data() {
    return {
      cd_modulo: localStorage.cd_modulo,
      dados: [],
      dados_menu: [],
      dados_form: {},
      dataSourceConfig: [],
      tabsheets: [],
      jsonData: [],
      columns: [],
      firstTabsheet: "",
      dados_lookup_importacao: [],
      importacao: "",
      arq_upload: [],
      processos: "",
      isPwd: false,
      ic_alerta: false,
      msg_alerta: "",
      pop_senha: false,
      nm_senha: "",
      senhaAutorizada: false,
      api: "944/1457",
      load: false,
      load_grid: false,
      load_importar: false,
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
        cd_modulo: this.cd_modulo,
        cd_menu: 4,
      };
      this.dados_lookup_importacao = await Incluir.incluirRegistro(
        this.api,
        carregaDataSouce
      ); //pr_egismob_importacao_dados
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
        if (this.importacao.cd_senha_acesso && this.senhaAutorizada == false) {
          this.pop_senha = true;
          return;
        }
        this.load_importar = true;
        const json_Data = {};
        //json_Data[this.firstTabsheet] = this.jsonData;
        json_Data["Cadastro"] = JSON.parse(
          JSON.stringify(this.jsonData, (key, value) => {
            if (typeof value === "string") {
              return value.replace(/'/g, "''''");
            }
            return value;
          })
        );
        if (this.importacao.cd_modelo) {
          let json_importacao = {
            cd_parametro: 1,
            cd_menu: 4,
            nm_planilha: "Cadastro", //this.firstTabsheet,
            nm_arquivo: this.importacao.nm_modelo,
            jsonMig: json_Data,
            cd_modelo: this.importacao.cd_modelo,
            cd_modulo: localStorage.cd_modulo,
            cd_usuario: localStorage.cd_usuario,
          };
          try {
            let [result] = await Incluir.incluirRegistro(
              this.api,
              json_importacao
            ); //pr_egismob_importacao_dados
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
              notify("Importação gerada com sucesso");
            }
          } catch (error) {
            //this.onFechar();
            notify("Não foi possivel gerar a importação");
          }
        } else {
          notify("Selecione um modelo de carga para importar");
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
      } finally {
        this.load_importar = false;
      }
      return;
    },
    onBaixarModelo() {
      funcao.downloadFile(this.importacao.nm_local_modelo_planilha);
    },

    onLimparRegistro() {
      this.importacao = "";
      this.jsonData = [];
      this.arq_upload = [];
    },
    onFechar() {
      this.onLimparRegistro();
      this.$emit("click");
    },
    async onFile(file) {
      try {
        this.columns = [];
        this.jsonData = [];
        this.load_grid = true;
        const reader = new FileReader();
        reader.onload = async (e) => {
          const arrayBuffer = e.target.result;
          const workbook = new ExcelJS.Workbook();
          await workbook.xlsx.load(arrayBuffer);
          workbook._worksheets.forEach((element) => {
            this.firstTabsheet = element.name;
          });
          const worksheet = workbook.getWorksheet(this.firstTabsheet); // Pegue a primeira planilha
          worksheet.eachRow((row, rowNumber) => {
            if (rowNumber === 1) {
              this.columns = row.values.slice(1);
            } else {
              let itemAdd = this.columns.reduce(
                (acc, header, index) => (
                  (acc.cd_controle = rowNumber),
                  (acc[header] = row.getCell(index + 1).value),
                  acc
                ),
                {}
              );
              this.jsonData.push(itemAdd);
            }
          });
        };

        reader.readAsArrayBuffer(file);
        this.load_grid = false;
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
        this.load_grid = false;
      }
    },
    async confirmaSenha() {
      if (this.nm_senha === this.importacao.cd_senha_acesso) {
        this.pop_senha = false;
        this.senhaAutorizada = true;
        await this.onSalvarRegistro();
      } else {
        notify("Senha incorreta!");
      }
    },
  },
};
</script>

<style scoped>
@import url("../views/views.css");

.listNotImport {
  font-weight: bold;
}
</style>
