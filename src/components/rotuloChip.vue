<template>
  <div class="q-pa-md items-center">
    <div v-for="(b, index) in dataSourceConfig" :key="index" class="top10">
      <q-btn
        v-if="b.ic_selecao == 0"
        rounded
        :color="b.nm_cor_status"
        :icon="b.icon_button"
        :label="b.nm_status"
        @click="onClick(b)"
      />
    </div>
  </div>
</template>

<script>
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import Incluir from "../http/incluir_registro";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";

export default {
  props: {
    cd_etapaID: { type: Number, default: 0 },
    cd_movimentoID: { type: Number, default: 0 },
    cd_documentoID: { type: Number, default: 0 },
    cd_item_documentoID: { type: Number, default: 0 },
    ic_valida_status: { type: String, default: "" },
  },

  data() {
    return {
      cd_etapa: 0,
      cd_status: 0,
      dados: [],
      dataSourceConfig: [],
      cd_api: 0,
      nm_json: {},
      resultado: [],
      dt_inicial: "",
      dt_final: "",
      dt_base: "",
      cd_movimento: 0,
      cd_documento: 0,
      cd_item_documento: 0,
      validado: "",
      temporario: [],
    };
  },
  async created() {
    this.validado = this.ic_valida_status;
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    //var h           = new Date().toLocaleTimeString();
    //this.hora       = h.substring(0,5);
  },

  async mounted() {
    this.cd_etapa = this.cd_etapaID;
    this.cd_movimento = this.cd_movimentoID;
    this.cd_documento = this.cd_documentoID;
    this.cd_item_documento = this.cd_item_documentoID;

    this.cd_api = 663; //pr_consulta_status_etapa_modulo

    //Carrega os status da Etapa
    this.dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 663); //;
    //

    //let sParametroApi = dados.nm_api_parametro;
    localStorage.cd_parametro = this.cd_etapa;
    localStorage.cd_tipo_parametro = this.cd_movimento;

    if (!this.dados.nm_api_parametro == "") {
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        this.dados.nm_identificacao_api,
        this.dados.nm_api_parametro
      );
    }
  },
  // watch:{
  //
  // },

  methods: {
    EnviaTemporario() {
      var Status = this.temporario;
      return Status;
    },

    async onClick(b) {
      this.cd_status = b.cd_status;
      if (b.icon_button == "close") {
        b.icon_button = "check";
      } else {
        b.icon_button = "close";
        var temp2 = {
          cd_movimento: this.cd_movimento,
          cd_etapa: this.cd_etapa,
          cd_status: b.cd_status,
          nm_status: b.nm_status,
          nm_cor_texto: b.nm_cor_texto,
          nm_cor_status: b.nm_cor_status,
          ic_adiciona: false,
        };
        this.temporario.push(temp2);
      }

      let api = "664/962"; //1519 -

      this.nm_json = {
        cd_parametro: 0,
        cd_movimento_status: 0,
        cd_modulo: localStorage.cd_modulo,
        cd_etapa: this.cd_etapa,
        cd_status: this.cd_status,
        cd_movimento: this.cd_movimento,
        cd_documento: this.cd_documento,
        cd_item_documento: this.cd_item_documento,
        cd_usuario: localStorage.cd_usuario,
        ic_valida_status: this.validado,
      };
      this.resultado = await Incluir.incluirRegistro(api, this.nm_json);

      let i = 0;
      if (this.validado == "S") {
        for (i = 0; i < this.dataSourceConfig.length; i++) {
          if (this.dataSourceConfig[i].cd_status != b.cd_status) {
            this.dataSourceConfig[i].icon_button = "close";
          }
        }
      }

      //this.nm_json = '['+this.nm_json+']';

      //Carrega os status da Etapa
      //this.cd_api   = 664;

      this.dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 664); //'titulo';
      //

      //let sParametroApi = dados.nm_api_parametro;

      localStorage.cd_parametro = 0;
      localStorage.nm_json = this.nm_json;
      localStorage.cd_documento = this.cd_documento;
      localStorage.cd_item_documento = this.cd_item_documento;
      localStorage.cd_tipo_parametro = 0;
      localStorage.cd_tipo_email = 0;
      localStorage.cd_relatorio = 0;

      //
      //
    },
  },
};
</script>
<style scoped>
.top10 {
  margin: 5px;
  display: inline-block;
}
</style>
