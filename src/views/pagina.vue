<template>
  <div>
    <!-- <div class="text-h6 text-bold margin1 ">
      {{ tituloMenu }}
    </div> -->
    <div>
      <transition name="slide-fade">
        <iframe
          v-if="this.dados.length > 0"
          title="DashBoard"
          :allowfullscreen="true"
          :src="dados[0].nm_endereco_pagina"
        ></iframe>
      </transition>
    </div>
    <q-dialog v-model="load_tela" maximized persistent>
      <carregando
        :mensagemID="'Carregando...'"
        :corID="'orange-9'"
      ></carregando>
    </q-dialog>
  </div>
</template>

<script>
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Menu from "../http/menu";
import Procedimento from "../http/procedimento";
import Lookup from "../http/lookup";

export default {
  name: "pagina",
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_modulo: localStorage.cd_modulo,
      tituloMenu: "",
      icon: "receipt_long",
      dataset_lookup_pagina: [],
      dados: [],
      load_tela: false,
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    this.load_tela = true;
    let dados_lookup_pagina = await Lookup.montarSelect(
      localStorage.cd_empresa,
      2076
    );
    this.dataset_lookup_pagina = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_pagina.dataset))
    );
    let menu = await Menu.montarMenu(
      localStorage.cd_empresa,
      localStorage.cd_menu,
      localStorage.cd_api
    );
    this.tituloMenu = menu.nm_menu_titulo;
    let sApi = menu.nm_api_parametro;
    localStorage.cd_parametro = localStorage.cd_menu;
    this.dados = await Procedimento.montarProcedimento(
      localStorage.cd_empresa,
      0,
      "793/1237",
      sApi
    );
    this.load_tela = false;
    await this.CarregaDados();
  },
  components: {
    carregando: () => import("../components/carregando.vue"),
  },
  methods: {
    async CarregaDados() {
      let loadedResolve,
        reportLoaded = new Promise((res, rej) => {
          loadedResolve = res;
        });
      let renderedResolve,
        reportRendered = new Promise((res, rej) => {
          renderedResolve = res;
        });
      // Get models. models contains enums that can be used.
      let models = window["powerbi-client"].models;
      // Embed a Power BI report in the given HTML element with the given configurations
      // Read more about how to embed a Power BI report in your application here: https://go.microsoft.com/fwlink/?linkid=2153590
      //function embedPowerBIReport() {
      /*-----------------------------------------------------------------------------------+
    |    Don't change these values here: access token, embed URL and report ID.          |
    |    To make changes to these values:                                                |
    |    1. Save any other code changes to a text editor, as these will be lost.         |
    |    2. Select 'Start over' from the ribbon.                                         |
    |    3. Select a report or use an embed token.                                       |
    +-----------------------------------------------------------------------------------*/
      // Read embed application token
      let accessToken =
        "eyJrIjoiYzJiYzM3ZTktNTMyNC00ODA1LWI3NzktNDc3ODk1YzllZTBmIiwidCI6Ijk2NzFmMzQ0LTAzYzItNDRiZS1hODg0LTRiYTRjMzQwNWViYyJ9";

      // Read embed URL
      let embedUrl = "https://app.powerbi.com/"; //EMBED_URL;

      // Read report Id
      let embedReportId = "7c851a05-b1fe-457d-80bd-1ef9de0ef372";

      // Read embed type from radio
      let tokenType = 1; //TOKEN_TYPE; 0 Add 1 Embed

      // We give All permissions to demonstrate switching between View and Edit mode and saving report.
      let permissions = models.Permissions.All;

      // Create the embed configuration object for the report
      // For more information see https://go.microsoft.com/fwlink/?linkid=2153590
      let config = {
        type: "report",
        tokenType:
          tokenType == "0" ? models.TokenType.Aad : models.TokenType.Embed,
        accessToken: accessToken,
        embedUrl: embedUrl,
        id: embedReportId,
        permissions: permissions,
        settings: {
          panes: {
            filters: {
              visible: true,
            },
            pageNavigation: {
              visible: true,
            },
          },
        },
      };
      // Get a reference to the embedded report HTML element
      let embedContainer = $("#embedContainer")[0];

      // Embed the report and display it within the div container.
      varreport = powerbi.embed(embedContainer, config);

      // report.off removes all event handlers for a specific event
      report.off("loaded");

      // report.on will add an event handler
      report.on("loaded", function() {
        loadedResolve();
        report.off("loaded");
      });

      // report.off removes all event handlers for a specific event
      report.off("error");

      report.on("error", function(event) {
        console.log(event.detail);
      });

      // report.off removes all event handlers for a specific event
      report.off("rendered");

      // report.on will add an event handler
      report.on("rendered", function() {
        renderedResolve();
        report.off("rendered");
      });
      //}
      //embedPowerBIReport();
      // Refresh the displayed report
      try {
        await report.refresh();
        // Reload the displayed report
        try {
          await report.reload();
        } catch (errors) {
          console.log(errors);
        }
        console.log("Refreshed");
      } catch (errors) {
        console.log(errors);
      }
      await reportLoaded;

      // Insert here the code you want to run after the report is loaded

      await reportRendered;

      // Insert here the code you want to run after the report is rendered
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}

iframe {
  width: 95vw;
  height: 90vh;
}
</style>
