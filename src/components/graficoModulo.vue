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
        label="Gráficos"
      />
    </div>
    <div class="text-h5 text-bold margin1">
      <q-badge v-if="prop_form.cd_movimento" align="top" color="blue">
        {{ prop_form.cd_movimento }}
      </q-badge>
    </div>

    <!-- Selects do Modulo_Relatorio -->
    <div v-if="dados_lookup_relatorio.length > 0">
      <div v-for="(rel, ind) in dados_lookup_relatorio" :key="ind">
        <q-card class="margin1 shadow-2 borda-bloco">
          <q-card-section class="bg-white text-blue-grey-5">
            <div class="row quadro" align="left">
              <div class="col-1">
                <q-icon name="dashboard" size="xl" />
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
                  load_rel && relatorio.cd_relatorio == rel.cd_relatorio
                "
                style="margin-left: auto;"
                flat
                label="Parâmetros"
              ></q-btn>
            </div>
            <div>
              <!-- <q-btn
                @click="geraPDF(rel)"
                class="text-blue-grey-5"
                flat
                icon="picture_as_pdf"
                size="sm"
                :loading="
                  load_rel && relatorio.cd_relatorio == rel.cd_relatorio
                "
              ></q-btn> -->
              <q-btn
                @click="geraGrafico(rel)"
                class="text-blue-grey-5"
                flat
                size="sm"
                :loading="
                  load_rel && relatorio.cd_relatorio == rel.cd_relatorio
                "
                label="Gráfico"
              ></q-btn>
            </div>
          </q-card-actions>
        </q-card>
      </div>
    </div>
    <div v-else>
      <div class="margin1 semRel text-bold">
        <q-chip class="margin1" color="red-4" text-color="white">
          {{ `Sem definição de gráfico para o módulo.` }}
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
          {{ `Parâmetros - ${relatorio.nm_relatorio}` }}
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
    <!--------CARREGANDO---------------------------------------------------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando mensagemID="carregando..."></carregando>
    </q-dialog>
    <!------------------------------------------------------------------------------------>
  </div>
</template>

<script>

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
    prop_form: {
      type: Object,
      default() {
        return {};
      },
    },
  },
  components: {
    carregando,
    formEspecial,
  },
  name: "graficoModulo",
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
      arq_upload: [],
      processos: "",
      pop_params: false,
      load_rel: false,
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
    try {
      let json_relatorio = {
        cd_empresa: localStorage.cd_empresa,
        cd_modulo: localStorage.cd_modulo,
        cd_menu: localStorage.cd_menu,
        cd_parametro: 10,
        cd_usuario: localStorage.cd_usuario,
      };
      let resultado_lookup_relatorio = await Incluir.incluirRegistro(
        this.api,
        json_relatorio,
      ); //pr_egis_relatorio_padrao
      this.dados_lookup_relatorio = resultado_lookup_relatorio.filter(
        (graf) => {
          if (graf.ic_grafico == "S" && graf.ic_ativo_grafico_modulo == "S") {
            return graf;
          }
        },
      );
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(error);
    }
  },

  methods: {
    onParametros(rel) {
      this.pop_params = true;
      this.relatorio = rel;
      this.relatorio.cd_documento = rel.cd_parametro_relatorio;
      this.load_only = "parametro";
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
          json_relatorio,
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
    async geraGrafico(rel) {
      try {
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
          json_relatorio,
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
    async geraPDF(rel) {
      try {
        this.relatorio = rel;
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
          "923/1433",
          json_relatorio,
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
      if (evt.cd_empresa != undefined) {
        this.form_params = evt;
        if (this.relatorio.ic_grafico) {
          await this.geraGrafico(this.form_params);
        } else {
          await this.geraRelatorio(this.form_params);
        }
        await this.carregaRelatorios();
      }
      this.pop_params = false;
    },
    async onSalvarRegistro() {
      const json_Data = {};
      json_Data[this.firstTabsheet] = this.jsonData;
      if (this.importacao.cd_modelo) {
        let json_importacao = {
          cd_parametro: 1,
          cd_menu: 4,
          nm_planilha: this.firstTabsheet,
          nm_arquivo: this.importacao.nm_modelo,
          jsonMig: json_Data,
          cd_modelo: this.importacao.cd_modelo,
          cd_modulo: localStorage.cd_modulo,
          cd_usuario: localStorage.cd_usuario,
        };
        try {
          let [result] = await Incluir.incluirRegistro(
            this.api,
            json_importacao,
          ); //pr_egis_relatorio_padrao
          this.onFechar();
          if (result.Msg !== "") {
            notify(result.Msg);
          } else {
            notify("Relatório gerado com sucesso");
          }
        } catch (error) {
          this.onFechar();
          notify("Não foi possivel gerar o relatório");
        }
      } else {
        notify("Selecione um relatório para gerar");
      }
      return;
    },
    onLimparRegistro() {
      this.importacao = "";
    },
    onFechar() {
      this.onLimparRegistro();
      this.$emit("click");
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
                {},
              ),
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
