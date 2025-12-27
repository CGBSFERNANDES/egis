<template>
  <div>
    <q-btn
      label="Imprimir"
      color="primary"
      icon="print"
      @click="renderDoc()"
      :loading="carregaDoc"
      :disable="carregaDoc"
    />
    <div v-if="!tituloMenu == ''">
      <h2 class="content-block">{{ tituloMenu }}</h2>
    </div>
    <div v-if="qt_registro > 0">
      <q-badge align="middle" rounded color="red" :label="qt_registro" />
    </div>
  </div>
</template>

<script>
import Docxtemplater from "docxtemplater";
import config from "devextreme/core/config";
import PizZip from "pizzip";
import PizZipUtils from "pizzip/utils/index.js";
import { saveAs } from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import "whatwg-fetch";
import notify from "devextreme/ui/notify";

function loadFile(url, callback) {
  PizZipUtils.getBinaryContent(url, callback);
}

var filenamedoc = "MontarNomeArquivo.docx";

var dados = [];

export default {
  props: {
    cd_relatorioID: { type: Number, default: 0 },
    cd_documentoID: { type: Number, default: 0 },
    cd_item_documentoID: { type: Number, default: 0 },
    // nm_jsonID: {
    //   type: Array,
    //   default() {
    //     return {};
    //   },
    // },
  },
  components: {},
  data() {
    return {
      tituloMenu: "",
      menu: "",
      dataSourceConfig: [],
      qt_registro: 0,
      cd_relatorio: 1,
      nm_template: "",
      dados_menu: [],
      dados_relatorio: [],
      nm_arquivo: "",
      carregaDoc: false,
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
  },

  async mounted() {
    await this.carregaDados();
  },

  destroyed() {
    this.$destroy();
  },
  methods: {
    async carregaDados() {
      this.carregaDoc = true;
      this.dados_menu = await Menu.montarMenu(localStorage.cd_empresa, 0, 666);
      this.dados_relatorio = [];

      localStorage.cd_parametro = 0;
      localStorage.cd_documento = this.cd_documentoID;
      localStorage.cd_item_documento = this.cd_item_documentoID;
      localStorage.cd_relatorio = this.cd_relatorioID;

      this.dados_relatorio = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        this.cd_cliente,
        this.dados_menu.nm_identificacao_api,
        this.dados_menu.nm_api_parametro,
      );
      if (!this.dados_relatorio) {
        this.$emit("NaoGerouRelatorio");
      }
      if (this.dados_relatorio.length == 0) {
        notify("Dados não encontrados!");
        this.carregaDoc = false;
        return;
      }
      this.nm_template = this.dados_relatorio[0].nm_template;

      this.nm_arquivo = this.dados_relatorio[0].nm_arquivo_relatorio;

      if (!this.nm_arquivo == "") {
        filenamedoc = this.nm_arquivo;
      }
      dados = this.dados_relatorio[0];
      this.carregaDoc = false;
    },

    renderDoc() {
      loadFile(`/${this.nm_template}`, (error, content) => {
        if (error) {
          alert("Template template.docx não foi encontrado");
          throw error;
        }

        var zip = new PizZip(content);
        var doc = new Docxtemplater(zip, {
          paragraphLoop: true,
          linebreaks: true,
        });
        doc.setData(dados);

        try {
          doc.render();
        } catch (error) {
          // The error thrown here contains additional information when logged with JSON.stringify (it contains a properties object containing all suberrors).
          function replaceErrors(key, value) {
            if (value instanceof Error) {
              return Object.getOwnPropertyNames(value).reduce(function(
                error,
                key,
              ) {
                error[key] = value[key];
                return error;
              },
              {});
            }
            return value;
          }

          if (error.properties && error.properties.errors instanceof Array) {
            const errorMessages = error.properties.errors
              .map(function(error) {
                return error.properties.explanation;
              })
              .join("\n");
            // errorMessages is a humanly readable message looking like this :
            // 'The tag beginning with "foobar" is unopened'
          }
          throw error;
        }
        var out = doc.getZip().generate({
          type: "blob",
          mimeType:
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        });

        //Output the document using Data-URI
        //saveAs(out, filenamedoc);
        saveAs(out, filenamedoc);
        //
      });
    },
  },
};
</script>

<style></style>
