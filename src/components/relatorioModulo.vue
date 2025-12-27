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
        label="Relatórios"
      />
    </div>
    <div class="text-h5 text-bold margin1">
      <q-badge v-if="prop_form.cd_movimento" align="top" color="blue">
        {{ prop_form.cd_movimento }}
      </q-badge>
    </div>
    <div v-if="dados_lookup_relatorio.length > 0">
      <div v-for="(rel, ind) in dados_lookup_relatorio" :key="ind">
        <q-card class="margin1 shadow-2 borda-bloco">
          <q-card-section class="bg-white text-blue-grey-5">
            <div class="row quadro" align="left">
              <div class="col-1">
                <q-icon name="task" size="xl" />
              </div>
              <div class="col-8">
                <div class="text-h6 text-blue-grey-8">
                  {{ `${rel.nm_relatorio}` }}
                </div>
                <div class="text-subtitle2">
                  {{ `${rel.ds_relatorio}` }}
                </div>
              </div>
            </div>
          </q-card-section>

          <q-separator />

          <q-card-actions class="buttonRel">
            <div class="buttonRelSemParam">
              <q-btn
                v-if="rel.cd_form"
                @click="onParametros(rel)"
                class="text-blue-grey-5"
                size="sm"
                :loading="
                  load_rel &&
                  relatorio.cd_relatorio == rel.cd_relatorio &&
                  load_only === 'parametro'
                "
                style="margin-left: auto"
                flat
                label="Parâmetros"
              ></q-btn>
            </div>
            <div>
              <q-btn
                v-if="rel.ic_grafico == 'S'"
                @click="geraGrafico(rel)"
                class="q-ml-sm text-blue-grey-5"
                style="margin-right: 18px"
                flat
                label="Gráfico"
                size="sm"
                :loading="
                  load_rel &&
                  relatorio.cd_relatorio == rel.cd_relatorio &&
                  load_only === 'dashboard'
                "
              ></q-btn>
              <q-btn
                v-if="rel.ic_grid_relatorio == 'S'"
                @click="geraGrid(rel)"
                class="q-ml-sm text-blue-grey-5"
                style="margin-right: 18px"
                flat
                label="Tabela"
                size="sm"
                :loading="
                  load_rel &&
                  relatorio.cd_relatorio == rel.cd_relatorio &&
                  load_only === 'grid'
                "
              ></q-btn>
              <q-btn
                v-if="false"
                @click="geraPDF(rel)"
                class="q-ml-sm"
                style="margin-right: 18px"
                round
                color="red"
                icon="picture_as_pdf"
                size="sm"
                :loading="
                  load_rel &&
                  relatorio.cd_relatorio == rel.cd_relatorio &&
                  load_only === 'pdf'
                "
              ></q-btn>
              <q-btn
                @click="geraRelatorio(rel)"
                class="text-blue-grey-5"
                flat
                size="sm"
                :loading="
                  load_rel &&
                  relatorio.cd_relatorio == rel.cd_relatorio &&
                  load_only === 'relatorio'
                "
                label="Relatório"
              ></q-btn>
            </div>
          </q-card-actions>
        </q-card>
      </div>
    </div>
    <div v-else>
      <div class="margin1 semRel text-bold">
        <q-chip class="margin1" color="red-4" text-color="white">
          {{ `Sem definição de relatório para o módulo.` }}
        </q-chip>
      </div>
    </div>
    <q-dialog
      v-model="pop_params"
      persistent
      maximized
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-9 text-white">
          {{ `Parâmetros - ${nm_relatorio}` }}
          <q-space />
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section class="q-pt-none">
          <formEspecial
            @click="saveParams($event)"
            :cd_formID="this.relatorio.cd_form"
            :cd_documentoID="parseInt(this.relatorio.cd_parametro_relatorio)"
            :cd_relatorioID="parseInt(this.relatorio.cd_relatorio)"
            :cd_item_documentoID="0"
            :prop_form="this.relatorio"
          />
        </q-card-section>
      </q-card>
    </q-dialog>
    <q-dialog
      v-model="pop_grid"
      persistent
      maximized
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-9 text-white">
          {{ `Tabela - ${relatorio.nm_relatorio}` }}
          <q-space />
          <q-btn dense flat icon="close" @click="closeGrid()">
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section class="q-pt-none">
          <div v-if="dados_lookup_grid && dados_lookup_grid.length > 0">
            <div
              class="margin1"
              style="
                display: flex;
                align-items: center;
                justify-content: center;
              "
            >
              <q-btn
                rounded
                color="orange-9"
                text-color="white"
                size="lg"
                :label="relatorio.nm_relatorio"
              />
            </div>
            <dx-data-grid
              id="grid-padrao"
              style="border-radius: 5px"
              :data-source="dados_lookup_grid"
              class="dx-card wide-card-gc"
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
            >
              <DxColumn
                v-for="(v, index) in grid_colunas"
                :key="index"
                :caption="v.nm_cab_atributo"
                :dataField="v.nm_atributo_relatorio"
                :visible="true"
              />
              <DxGroupPanel
                :visible="true"
                :allow-column-dragging="true"
                empty-panel-text="agrupar..."
              />
              <DxGrouping :auto-expand-all="true" />
              <DxExport :enabled="true" />

              <DxPaging :enable="true" :page-size="10" />

              <DxPager
                :show-page-size-selector="true"
                :allowed-page-sizes="[10, 20, 50, 100]"
                :show-info="true"
              />
              <DxFilterRow :visible="false" />
              <DxHeaderFilter
                :visible="true"
                :allow-search="true"
                :width="400"
                :height="400"
              />
              <DxSearchPanel
                :visible="true"
                :width="300"
                placeholder="Procurar..."
              />
            </dx-data-grid>
          </div>
          <div v-else>
            <div class="margin1 semRel text-bold">
              <q-chip class="margin1" color="red-4" text-color="white">
                {{ `Sem dados para esse relatório.` }}
              </q-chip>
            </div>
          </div>
        </q-card-section>
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
  DxColumn,
  DxGroupPanel,
  DxGrouping,
  DxExport,
  DxPaging,
  DxPager,
  DxFilterRow,
  DxHeaderFilter,
  DxSearchPanel,
} from "devextreme-vue/data-grid";
import "devextreme-vue/text-area";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import formEspecial from "../views/cadastroFormEspecial";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import carregando from "./carregando.vue";
import ExcelJS from "exceljs";
import html2pdf from "html2pdf.js";

export default {
  props: {
    cd_formID: { type: Number, default: 0 },
    cd_documentoID: { type: Number, default: 0 },
    cd_item_documentoID: { type: Number, default: 0 },
    cd_menuID: { type: Number, default: undefined },
    prop_form: {
      type: Object,
      default() {
        return {};
      },
    },
  },
  components: {
    DxDataGrid,
    DxColumn,
    DxGroupPanel,
    DxGrouping,
    DxExport,
    DxPaging,
    DxPager,
    DxFilterRow,
    DxHeaderFilter,
    DxSearchPanel,
    carregando,
    formEspecial,
  },
  name: "relatorioModulo",
  data() {
    return {
      cd_modulo: localStorage.cd_modulo,
      dados: [],
      dados_menu: [],
      dados_form: {},
      dataSourceConfig: [],
      tabsheets: [],
      jsonData: [],
      firstTabsheet: "",
      dados_lookup_relatorio: [],
      relatorio: "",
      nm_relatorio: "",
      arq_upload: [],
      processos: "",
      pop_params: false,
      pop_grid: false,
      dados_lookup_grid: [],
      grid_colunas: [],
      load_rel: false,
      load_only: "",
      form_params: {},
      api: "923/1433",
      load: false,
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
  },

  async mounted() {
    await this.carregaRelatorios();
  },

  methods: {
    async carregaRelatorios() {
      try {
        let json_relatorio = {
          cd_empresa: localStorage.cd_empresa,
          cd_modulo: localStorage.cd_modulo,
          cd_menu: this.cd_menuID,
          cd_parametro: 10,
          cd_usuario: localStorage.cd_usuario,
        };
        this.dados_lookup_relatorio = await Incluir.incluirRegistro(
          this.api,
          json_relatorio
        ); //pr_egis_relatorio_padrao
        
        await this.$nextTick();
        if(this.dados_lookup_relatorio.length===1){
          const rel = this.dados_lookup_relatorio[0];
          if (rel) {
            this.geraRelatorio(rel);
          } 
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
      }
    },
    onParametros(rel) {
      this.pop_params = true;
      this.relatorio = rel;
      this.nm_relatorio = rel.nm_relatorio;
      this.relatorio.cd_documento = rel.cd_parametro_relatorio;
      this.load_only = "parametro";
    },
    async geraGrafico(rel) {
      try {
        this.load_only = "dashboard";
        this.relatorio = rel;
        this.relatorio.cd_documento = rel.cd_parametro_relatorio;
        this.load_rel = true;
        let json_relatorio = {
          cd_empresa: localStorage.cd_empresa,
          cd_modulo: localStorage.cd_modulo,
          cd_menu: localStorage.cd_menu,
          cd_parametro: 3,
          cd_relatorio_form: this.relatorio.cd_relatorio,
          cd_processo: "",
          ...this.form_params,
          cd_usuario: localStorage.cd_usuario,
        };
        let [relatorio] = await Incluir.incluirRegistro(
          this.api, //"923/1433",
          json_relatorio
        ); //pr_egis_relatorio_padrao
        const htmlContent = relatorio.RelatorioHTML;
        const blob = new Blob([htmlContent], {
          type: "text/html",
        });
        const url = URL.createObjectURL(blob);
        window.open(url, "_blank");
        // Opcional: liberar o objeto URL depois que não for mais necessário
        URL.revokeObjectURL(url);
        notify("Dashboard gerado com sucesso");
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
        notify("Não foi possivel gerar o dashboard");
      } finally {
        this.load_rel = false;
      }
    },
    async geraRelatorio(rel) {
      try {
        this.load_only = "relatorio";
        this.relatorio = rel;
        this.relatorio.cd_documento = rel.cd_parametro_relatorio;
        this.load_rel = true;
        let json_relatorio = {
          cd_empresa: localStorage.cd_empresa,
          cd_modulo: localStorage.cd_modulo,
          cd_menu: localStorage.cd_menu,
          cd_relatorio_form: this.relatorio.cd_relatorio,
          cd_processo: "",
          ...this.form_params,
          cd_usuario: localStorage.cd_usuario,
        };
        let [relatorio] = await Incluir.incluirRegistro(
          this.api, //"923/1433",
          json_relatorio
        ); //pr_egis_relatorio_padrao
        const htmlContent = relatorio.RelatorioHTML;
        const blob = new Blob([htmlContent], {
          type: "text/html",
        });
        const url = URL.createObjectURL(blob);
        window.open(url, "_blank");
        // Opcional: liberar o objeto URL depois que não for mais necessário
        URL.revokeObjectURL(url);
        notify("Relatório gerado com sucesso");
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
        notify("Não foi possivel gerar o relatório");
      } finally {
        this.load_rel = false;
      }
    },
    async geraGrid(rel) {
      try {
        this.pop_grid = true;
        this.load_only = "grid";
        this.relatorio = rel;
        let json_relatorio = {
          cd_parametro: 1,
          cd_empresa: localStorage.cd_empresa,
          cd_modulo: localStorage.cd_modulo,
          cd_menu: localStorage.cd_menu,
          cd_relatorio_form: this.relatorio.cd_relatorio,
          cd_processo: "",
          cd_usuario: localStorage.cd_usuario,
        };
        this.dados_lookup_grid = await Incluir.incluirRegistro(
          this.api,
          json_relatorio
        ); //pr_egis_relatorio_padrao
        ///////////////////////////////////////////////////
        let json_colunas = {
          cd_parametro: 2,
          cd_empresa: localStorage.cd_empresa,
          cd_modulo: localStorage.cd_modulo,
          cd_menu: localStorage.cd_menu,
          cd_relatorio_form: this.relatorio.cd_relatorio,
          cd_processo: "",
          cd_usuario: localStorage.cd_usuario,
        };
        this.grid_colunas = await Incluir.incluirRegistro(
          this.api,
          json_colunas
        ); //pr_egis_relatorio_padrao
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
        notify("Não foi possivel gerar a tabela");
      } finally {
        this.load_rel = false;
      }
    },
    async geraPDF(rel) {
      try {
        this.load_only = "pdf";
        this.relatorio = rel;
        this.relatorio.cd_documento = rel.cd_parametro_relatorio;
        this.load_rel = true;
        let json_relatorio = {
          cd_empresa: localStorage.cd_empresa,
          cd_modulo: localStorage.cd_modulo,
          cd_menu: localStorage.cd_menu,
          cd_relatorio_form: this.relatorio.cd_relatorio,
          cd_processo: "",
          ...this.form_params,
          cd_usuario: localStorage.cd_usuario,
        };
        let [relatorio] = await Incluir.incluirRegistro(
          this.api, //"923/1433",
          json_relatorio
        ); //pr_egis_relatorio_padrao
        const htmlContent = relatorio.RelatorioHTML;
        html2pdf()
          .from(htmlContent)
          .toPdf()
          .get("pdf")
          .then((pdf) => {
            window.open(pdf.output("bloburl"));
          });
        notify("PDF gerado com sucesso");
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
        notify("Não foi possivel gerar o PDF");
      } finally {
        this.load_rel = false;
      }
    },
    async saveParams(evt) {
      if (!(evt instanceof PointerEvent)) {
        this.form_params = evt;
        if (this.relatorio.ic_grafico == "S") {
          await this.geraGrafico(this.form_params);
        } else {
          await this.geraRelatorio(this.form_params);
        }
        await this.carregaRelatorios();
      }
      this.pop_params = false;
    },
    onLimparRegistro() {
      this.importacao = "";
    },
    onFechar() {
      this.onLimparRegistro();
      this.$emit("click");
    },
    closeGrid() {
      this.pop_grid = false;
    },
    async onFile(file) {
      const reader = new FileReader();
      reader.onload = async (e) => {
        const arrayBuffer = e.target.result;
        const workbook = new ExcelJS.Workbook();
        await workbook.xlsx.load(arrayBuffer);
        workbook._worksheets.forEach((element) => {
          //Lista de tabsheets
          if (this.firstTabsheet === "") {
            this.firstTabsheet = element.name;
          }
        });
        const worksheet = workbook.getWorksheet(this.firstTabsheet); // Pegue a primeira planilha
        var columns = [];
        //Se a tabela for muito grande tentar o método abaixo
        // worksheet.eachRow((row, rowNumber) =>
        //   rowNumber === 1
        //     ? (columns = row.values.slice(1))
        //     : this.jsonData.push(
        //         new Map(
        //           columns.map((header, index) => [
        //             header,
        //             row.getCell(index + 1).value,
        //           ]),
        //         ),
        //       ),
        // );
        //   const jsonObjects = this.jsonData.map((rowMap) =>
        //   Object.fromEntries(rowMap),
        // );
        //////////////////////////////////////////////
        worksheet.eachRow((row, rowNumber) => {
          if (rowNumber === 1) {
            columns = row.values.slice(1);
          } else {
            this.jsonData.push(
              columns.reduce(
                (acc, header, index) => (
                  (acc[header] = row.getCell(index + 1).value), acc
                ),
                {}
              )
            );
          }
        });
      };

      reader.readAsArrayBuffer(file);
    },
  },
};
</script>

<style scoped>
@import url("../views/views.css");

.semRel {
  display: flex;
  justify-content: center;
  align-items: center;
  align-content: center;
}

.buttonRel {
  display: flex;
  justify-content: space-between;
  align-items: center;
  align-content: center;
}

.buttonRelSemParam {
  flex-direction: row-reverse;
}

@media (max-width: 900px) {
  .quadro {
    display: block;
  }
}
</style>
