<template>
  <div class="q-pa-md">
    <q-layout view="lHh lpr lFf" container style="height: 600px" class="orange">
      <q-header reveal elevated>
        <q-toolbar class="bg-grey-3 text-black">
          <q-btn flat round dense icon="menu" class="q-mr-sm" />
          <q-avatar>
            <img src="http://www.egisnet.com.br/img/gbsfavicon.ico" />
          </q-avatar>

          <q-toolbar-title>Atendimento e Suporte</q-toolbar-title>

          <q-btn flat round dense icon="more_vert" @click="onClickOperador()" />
        </q-toolbar>
      </q-header>

      <q-footer reveal elevated style="height: 60px">
        <q-toolbar>
          <q-form @submit="sendMessage" class="full-width">
            <q-input
              v-model="newMessage"
              bg-color="white"
              outlined
              rounded
              label="Mensagem"
              dense
            >
              <template v-slot:after>
                <q-btn
                  round
                  dense
                  flat
                  type="submit"
                  color="white"
                  icon="send"
                />
              </template>
            </q-input>
          </q-form>
        </q-toolbar>
      </q-footer>

      <q-page-container>
        <q-page class="q-pa-md">
          <q-banner v-if="qt_operador == 0" class="bg-grey-4 text-center">
            Operadores estão offline.
          </q-banner>
          <q-banner v-if="qt_operador !== 0" class="bg-grey-4 text-center">
            Operadores Disponíveis : {{ qt_operador }}
          </q-banner>
          <div v-if="showCard == true" class="q-pa-md" style="max-width: 550px">
            <q-toolbar class="bg-primary text-white shadow-2">
              <q-toolbar-title>Operadores</q-toolbar-title>
            </q-toolbar>

            <q-list bordered separator>
              <q-item
                v-for="operador in operadores"
                :key="operador.cd_controle"
                class="q-my-sm"
                clickable
                v-ripple
              >
                <q-item-section avatar>
                  <q-avatar color="primary" text-color="white">
                    {{ operador.nm_usuario.charAt(0) }}
                  </q-avatar>
                </q-item-section>

                <q-item-section>
                  <q-item-label>{{ operador.nm_usuario }}</q-item-label>
                  <q-item-label caption lines="1">{{
                    operador.nm_email_usuario
                  }}</q-item-label>
                </q-item-section>
                <q-item-section>
                  <q-item-label></q-item-label>
                  <q-item-label caption lines="1"
                    >Fone: {{ operador.cd_telefone_usuario }}</q-item-label
                  >
                </q-item-section>

                <q-item-section side>
                  <q-badge
                    :color="
                      operador.ic_disponivel == 'Sim' ? 'light-green-5' : 'red'
                    "
                  >
                    {{
                      operador.ic_disponivel == "Sim"
                        ? "OnLine"
                        : "Indisponível"
                    }}
                  </q-badge>
                </q-item-section>
              </q-item>
            </q-list>
          </div>

          <q-chat-message
            v-for="message in mensagem"
            :key="message.cd_chat"
            :name="
              message.cd_tipo_chat == '1'
                ? message.nm_fantasia_usuario
                : message.nm_fantasia_usuario_operador
            "
            :text="[message.ds_mensagem]"
            :sent="message.cd_tipo_chat == '1' ? true : false"
          />
        </q-page>
      </q-page-container>
    </q-layout>
  </div>
</template>

<script>
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";

var dados = [];
var sParametroApi = "";

export default {
  components: {},
  data() {
    return {
      dataSourceConfig: [],
      cd_empresa: 0,
      cd_menu: 0,
      cd_cliente: 0,
      cd_api: 0,
      api: "",
      dt_inicial: "",
      dt_final: "",
      qt_operador: 0,
      newMessage: "",
      mensagem: [],
      showCard: false,
    };
  },

  computed: {
    operadores() {
      return this.$store.state.operadores;
    },
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();
    this.dt_final = new Date(localStorage.dt_final).toLocaleDateString();
    var h = new Date().toLocaleTimeString();
    this.hora = h.substring(0, 5);

    //this.showMenu();
    //await this.showMenu();
    //
    await this.showMensagem();
    //
  },

  async mounted() {
    //this.carregaDados();
    this.$store.dispatch("loadOperador");
  },

  methods: {
    onClickOperador() {
      this.showCard = !this.showCard;
      this.$store.dispatch("loadOperador");
      this.$store.dispatch("getOperadorDisponivel");
      this.qt_operador = this.$store.state.disponivel.length;
    },
    sendMessage() {
      //this.messages.push({
      //		text: this.newMessage,
      //			from: 'me'
      //});
    },

    async showMensagem() {
      localStorage.cd_parametro = 0;

      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;

      let api = "";
      //
      dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 571);
      //

      api = dados.nm_identificacao_api;

      let sParametroApi = dados.nm_api_parametro;

      this.mensagem = [];

      this.mensagem = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        sParametroApi
      );
    },
  },

  async showMenu() {
    this.cd_empresa = localStorage.cd_empresa;
    this.cd_cliente = localStorage.cd_cliente;
    this.cd_menu = 7164; //localStorage.cd_menu;
    this.cd_api = 543; //localStorage.cd_api;
    this.api = "543/750"; //localStorage.nm_identificacao_api;
    this.cd_modulo = localStorage.cd_modulo;

    var data = new Date(),
      dia = data.getDate().toString(),
      diaF = dia.length == 1 ? "0" + dia : dia,
      mes = (data.getMonth() + 1).toString(), //+1 pois no getMonth Janeiro começa com zero.
      mesF = mes.length == 1 ? "0" + mes : mes,
      anoF = data.getFullYear();

    localStorage.dt_inicial = mes + "-" + dia + "-" + anoF;
    localStorage.dt_final = mesF + "-" + diaF + "-" + anoF;
    localStorage.cd_parametro = 0;

    dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';

    sParametroApi = dados.nm_api_parametro;

    if (
      !dados.nm_identificacao_api == "" &&
      !dados.nm_identificacao_api == this.api
    ) {
      this.api = dados.nm_identificacao_api;
    }

    localStorage.cd_tipo_consulta = 0;

    if (!dados.cd_tipo_consulta == 0) {
      dados.cd_tipo_consulta;
    }

    if (dados.nm_menu_titulo != undefined) {
      this.tituloMenu = dados.nm_menu_titulo;
    }

    filename = this.tituloMenu + ".xlsx";

    this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

    this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
  },

  async carregaDados() {
    await this.showMenu();

    let sApi = sParametroApi;

    this.dataSourceConfig = await Procedimento.montarProcedimento(
      this.cd_empresa,
      this.cd_cliente,
      this.api,
      sApi
    );
  },
};
</script>  

<style>
.pagina {
  height: 100%;
  width: 100%;
}
.orange {
  color: rgb(255, 87, 34);
}
.preto {
  color: black;
}
</style>