<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="text-h4 text-bold margin1">
      {{ tituloMenu }} <b v-if="!nm_cliente == ''">- {{ nm_cliente }}</b>
      <transition name="slide-fade">
        <div v-if="!ic_card">
          <q-btn
            round
            color="primary"
            icon="arrow_back"
            @click="ic_card = true"
          >
            <q-tooltip>Voltar</q-tooltip>
          </q-btn>
        </div>
      </transition>
    </div>
    <transition name="slide-fade">
      <div v-if="ic_card">
        <div class="card-geral">
          <q-card class="card-opcao bg-secondary text-white margin1">
            <q-card-section>
              <div class="text-h6">Fila de Atendimento</div>
              <div class="text-subtitle2">Entrar na Fila</div>
            </q-card-section>
            <q-separator dark></q-separator>
            <q-card-actions>
              <q-btn flat @click="EntrarFila">Entrar</q-btn>
            </q-card-actions>
          </q-card>
          <q-card class="card-opcao bg-positive text-white margin1">
            <q-card-section>
              <div class="text-h6">Agenda</div>
              <div class="text-subtitle2">Agendar Atendimento</div>
            </q-card-section>
            <q-separator dark></q-separator>
            <q-card-actions>
              <q-btn flat @click="AgendarAtendimento">Agendar</q-btn>
            </q-card-actions>
          </q-card>
        </div>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="!ic_card">
        <transition name="slide-fade">
          <div v-if="ic_fila">
            <filaAtendimento></filaAtendimento>
          </div>
        </transition>
        <transition name="slide-fade">
          <div v-if="ic_agenda">
            <agendaAtendimento></agendaAtendimento>
          </div>
        </transition>
      </div>
    </transition>
    <!-- <transition name="slide-fade">
      <div
        class="margin1"
        v-if="ic_card && dataSourceConfig[0].Msg == undefined"
      >
        <q-btn-dropdown
          color="primary"
          :label="`Atendimentos em aberto (${dataSourceConfig.length})`"
        >
          <q-list v-for="(n, index) in dataSourceConfig" :key="index">
            <q-item clickable v-close-popup>
              <q-item-section>
                <q-item-label>{{ n.nm_link_atendimento }}</q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
        </q-btn-dropdown>
      </div>
    </transition> -->
    <q-dialog maximized v-model="load_tela" persistent>
      <carregando
        v-if="load_tela == true"
        :corID="'orange-9'"
        :mensagemID="'Aguarde...'"
      ></carregando>
    </q-dialog>
  </div>
</template>

<script>
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";

var dados = [];
var sParametroApi = "";

export default {
  async mounted() {
    await this.carregaDados();
  },
  components: {
    carregando: () => import("../components/carregando.vue"),
    filaAtendimento: () => import("../views/filaAtendimento.vue"),
    agendaAtendimento: () => import("../views/AgendaAtendimento.vue"),
  },

  data() {
    return {
      polling: null,
      load_tela: false,
      qt_tabsheet: 0,
      dataSourceConfig: [],
      api: "",
      cd_api: "",
      cd_identificacao: 0,
      tituloMenu: "",
      columns: [],
      total: 0,
      nm_cliente: "",
      ic_card: true,
      ic_fila: false,
      ic_agenda: false,
      cd_cliente: localStorage.cd_cliente,
      cd_usuario: localStorage.cd_usuario,
      cd_menu: localStorage.cd_menu,
      cd_empresa: localStorage.cd_empresa,
    };
  },
  methods: {
    async carregaDados() {
      await this.showMenu();

      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);
      if (!this.qt_tabsheet == 0) {
        let sApis = sParametroApi;

        if (!sApis == "") {
          try {
            this.dataSourceConfig = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_cliente,
              this.api,
              sApis,
            );
          } catch (error) {
            console.log(error);
          }
        }
      }

      if (this.qt_tabsheet == 0) {
        //Gera os Dados para Montagem da Grid
        //exec da procedure

        let sApi = sParametroApi;
        if (!sApi == "") {
          localStorage.cd_parametro = this.cd_usuario;
          this.dataSourceConfig = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            this.api,
            sApi,
          );
          if (this.dataSourceConfig[0].Msg == undefined) {
            this.nm_cliente = this.dataSourceConfig[0].nm_fantasia_cliente;
            this.cd_cliente,
              (localStorage.cd_cliente = this.dataSourceConfig[0].cd_cliente);
          }
        }
      }
    },
    async showMenu() {
      //Consulta as informações do Usuário
      this.cd_api = 829; //localStorage.cd_api;
      this.api = "829/1306"; //localStorage.nm_identificacao_api;
      this.cd_cliente = localStorage.cd_cliente;
      //this.cd_api = localStorage.cd_api;
      //this.api = localStorage.nm_identificacao_api;
      localStorage.cd_parametro = 0;

      var dataI = new Date(localStorage.dt_inicial);
      var diaI = dataI.getDate().toString();
      var mesI = (dataI.getMonth() + 1).toString();
      var anoI = dataI.getFullYear();
      localStorage.dt_inicial = mesI + "-" + diaI + "-" + anoI;

      var dataF = new Date(localStorage.dt_final);
      var diaF = dataF.getDate().toString();
      var mesF = (dataF.getMonth() + 1).toString();
      var anoF = dataF.getFullYear();
      localStorage.dt_final = mesF + "-" + diaF + "-" + anoF;

      var dataB = new Date(localStorage.dt_base);
      var diaB = dataB.getDate().toString();
      var mesB = (dataB.getMonth() + 1).toString();
      var anoB = dataB.getFullYear();

      localStorage.dt_base = mesB + "-" + diaB + "-" + anoB;

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';

      sParametroApi = dados.nm_api_parametro;

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      this.qt_tabsheet = dados.qt_tabsheet;

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.menu = dados.nm_menu;

      //dados da coluna   avada
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //
    },
    EntrarFila() {
      this.ic_card = false;
      this.ic_agenda = false;
      this.ic_fila = true;
    },
    AgendarAtendimento() {
      this.ic_card = false;
      this.ic_fila = false;
      this.ic_agenda = true;
    },
  },
};
</script>

<style scoped>
@import url("./views.css");

.card-geral {
  display: flex;
  flex-direction: row;
}

.card-opcao {
  width: 100%;
  max-width: 250px;
}
</style>
