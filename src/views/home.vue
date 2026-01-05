<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div v-if="ic_pagina_modulo === 'S'">
      <div v-show="!load_pagina">
        <div class="margin1 row justify-end">
          <q-btn
            class="margin1"
            round
            color="primary"
            icon="restart_alt"
            @click="recarregarHTML()"
          >
            <q-tooltip> Recarregar </q-tooltip>
          </q-btn>

          <q-btn
            round
            class="margin1"
            color="primary"
            icon="close"
            @click="ic_pagina_modulo = 'N'"
          >
            <q-tooltip> Fechar </q-tooltip>
          </q-btn>
        </div>

        <HTMLDinamico
          @semIframe="ic_pagina_modulo = 'N'"
          :cd_pagina_modulo="cd_pagina_modulo"
        />
      </div>
      <div v-show="load_pagina" class="flex flex-center" style="height: 100vh">
        <q-spinner color="primary" size="10rem" />
      </div>
    </div>
    <div v-else>
      <transition name="slide-fade">
        <div v-if="ic_etapa == 'N'">
          <section class="margin1 row items-center justify-around">
            <!-- <div class=""> -->
            <div class="flex items-center" style="margin-right: auto;">
              <transition name="slide-fade">
                <q-btn
                  round
                  color="primary"
                  class="margin1"
                  v-if="cd_modulo != 220 || cd_empresa != 240"
                  @click="ic_etapa = 'S'"
                  icon="calendar_view_week"
                >
                  <q-tooltip> Kanban </q-tooltip>
                </q-btn>
              </transition>
              <transition name="slide-fade">
                <q-btn
                  class="margin1 btn-dash"
                  round
                  color="deep-orange-6"
                  v-if="cd_pagina_modulo > 0 && ic_pagina_modulo === 'N'"
                  @click="abrirDashboard"
                  icon="dashboard"
                >
                  <q-tooltip> Dashboard </q-tooltip>
                </q-btn>
              </transition>
              <p class="text-h6" style="margin-bottom: 0 !important;">
                {{ nomeTitulo }}
              </p>
            </div>
            <b class="periodo">Período: {{ dt_inicial }} até {{ dt_final }} </b>
            <!-- <q-dialog v-model="showDashboard" maximized persistent> -->
            <!-- <q-card v-if="showDashboard" flat class="dashboard q-pa-sm" style="height:100vh; width:100vw; z-index: 99;"> -->

            <transition name="slide-fade">
              <q-card
                v-if="showDashboard"
                flat
                class="dashboard q-pa-sm"
                style="width:100%; z-index: 99;"
              >
                <!-- Fechar -->

                <q-btn
                  flat
                  dense
                  round
                  icon="close"
                  class="absolute-top-right q-ma-sm"
                  @click="abrirDashboard()"
                  aria-label="Fechar"
                />

                <!-- Seu novo dashboard -->

                <dashBoard_Componente
                  :cd-modulo="cdModuloDash"
                  :cd-usuario="cdUsuarioDash"
                  :dt-inicial="dtInicialDash"
                  :dt-final="dtFinalDash"
                />
              </q-card>
            </transition>

            <!-- </q-dialog> -->

            <!-- <transition name="slide-fade">
                <q-btn
                  round
                  color="primary"
                  class="margin1"
                  v-if="cd_modulo != 220 || cd_empresa != 240"
                  @click="ic_etapa = 'S'"
                  icon="calendar_view_week"
                >
                  <q-tooltip> Kanban </q-tooltip>
                </q-btn>
              </transition>
              <transition name="slide-fade">
                <q-btn
                  class="margin1 btn-dash"
                  round
                  color="deep-orange-6"
                  v-if="cd_pagina_modulo > 0 && ic_pagina_modulo === 'N'"
                  @click="abrirDashboard"
                  icon="dashboard"
                >
                  <q-tooltip> Dashboard </q-tooltip>
                </q-btn>
              </transition> -->
            <!-- </div> -->

            <!-- <q-space /> -->
            <!-- <div class="metadeTela">
              <b class="periodo"
                >Período: {{ dt_inicial }} até {{ dt_final }}</b
              >
            </div> -->
          </section>
          <q-card class="margin1 borda">
            <div class="row items-center">
              <div class="col margin1">
                <b>{{ nomeUsuario }}</b>
                <br />
                <transition name="slide-fade">
                  <div class="justify-text" v-if="!!nomeModulo">
                    Bem-vindo ao {{ nomeModulo }}!
                  </div>

                  <div class="justify-text" v-else>Bem-vindo ao Egisnet!</div>
                </transition>
              </div>
              <transition name="slide-fade">
                <div
                  v-if="vl_acumulado == 0"
                  class="col margin1"
                  style="text-align: right"
                >
                  <transition name="slide-fade">
                    <img
                      v-if="this.celular == 0"
                      src="http://www.egisnet.com.br/img/logo_gbstec_sistema.png"
                      width="150px"
                      height="50px"
                    />
                  </transition>
                </div>
              </transition>
              <transition name="slide-fade">
                <div
                  v-if="vl_acumulado != 0"
                  class="col"
                  style="text-align: center"
                >
                  <transition name="slide-fade">
                    <img
                      v-if="this.celular == 0"
                      src="http://www.egisnet.com.br/img/logo_gbstec_sistema.png"
                      width="150px"
                      height="50px"
                    />
                  </transition>
                </div>
              </transition>
              <transition name="slide-fade">
                <div
                  v-if="vl_acumulado != 0"
                  class="col"
                  style="text-align: right"
                >
                  <b class="text-overline lb-acumulado" style="font-size: 100%"
                    >Acumulado Ano</b
                  >
                  <q-item-label class="text-blue lb-acumulado"
                    ><b> {{ vl_acumulado }} </b>
                  </q-item-label>
                </div>
              </transition>
              <transition name="slide-fade">
                <div v-if="vl_acumulado != 0"></div>
              </transition>
            </div>
          </q-card>

          <div v-if="vl_acumulado != 0">
            <section v-if="this.celular == 0" class="cards">
              <q-card
                class="my-card"
                v-for="dados_home in dados_home"
                :key="dados_home.vl_card"
              >
                <q-card-section class="bgRadial">
                  <label class="label_cima">
                    {{ dados_home.nm_card }}
                    <q-badge :color="cor" align="top">
                      {{ dados_home.lb_card }}
                    </q-badge>
                  </label>
                </q-card-section>

                <q-separator></q-separator>

                <q-card-section class="label_baixo">
                  <b>{{ dados_home.vl_card }}</b>
                </q-card-section>
              </q-card>
            </section>
          </div>

          <!--cards para celular-->
          <div v-if="vl_acumulado != 0">
            <div v-if="this.celular == 1">
              <section
                class="cards_celular"
                v-for="dados_home in dados_home"
                :key="dados_home.vl_card"
              >
                <q-card class="my-card">
                  <q-card-section class="bgRadial">
                    <label class="label_cima">
                      {{ dados_home.nm_card }}
                      <q-badge color="#2D4C71" align="top">
                        {{ dados_home.lb_card }}
                      </q-badge>
                    </label>
                  </q-card-section>

                  <q-separator></q-separator>

                  <q-card-section class="label_baixo">
                    <b>{{ dados_home.vl_card }}</b>
                  </q-card-section>
                </q-card>
              </section>
            </div>
          </div>
          <div v-if="dataSourceConfig.length > 0">
            <DxPieChart
              v-if="g == 0"
              id="pie"
              :data-source="dataSourceConfig"
              :title="tituloGrafico"
              type="doughnut"
              palette="Soft Pastel"
              @point-click="pointClickHandler"
            >
              <DxSeries :argument-field="legenda" :value-field="valor">
                <DxLabel :visible="true">
                  <DxConnector :visible="true" />
                </DxLabel>
                <DxHoverStyle color="#ffd700" />
              </DxSeries>

              <DxExport
                :enabled="true"
                :margin-left="0"
                horizontal-alignment="left"
              />
              <!-- :margin="-50"-->
              <DxLegend horizontal-alignment="left" vertical-alignment="bottom">
              </DxLegend>
              <DxAdaptiveLayout :height="300" :width="400" />

              <DxTooltip :enabled="true" :customize-tooltip="customizeTooltip">
              </DxTooltip>
            </DxPieChart>
          </div>
        </div>
      </transition>

      <!-- Indicadores -->
      <div
        v-if="ic_etapa == 'N' && dados_indicador"
        style="display: flex; justify-content: flex-end"
      >
        <q-fab
          align="right"
          class="margin1"
          color="orange-9"
          text-color="white"
          icon="keyboard_arrow_left"
          direction="left"
        >
          <q-fab-action
            flat
            v-for="(indicador, index) in dados_indicador"
            :key="index"
            text-color="black"
            :label="`${indicador.nm_aviso_sistema} (${indicador.nm_resultado})`"
          />
        </q-fab>
      </div>
      <transition name="slide-fade">
        <Etapa
          @GraficoKanban="VoltaGrafico"
          v-if="ic_etapa == 'S'"
          @indicadores="dataIndicadores"
        />
      </transition>
    </div>
    <!------------------------>
    <q-dialog v-model="aniversariante">
      <q-card>
        <div class="aniversariante">
          <q-card-section>
            <div class="text-h6">Feliz Aniversário!</div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <p>
              Parabéns pelo seu dia! Essa é a mensagem da equipe GBS, em
              comemoração ao seu dia especial.
            </p>
            Tenha um feliz aniversário, cheio de sorrisos e gargalhadas, repleto
            de paz, amor e muita alegria. Parabéns por mais um ano de vida!
          </q-card-section>
          <q-card-actions align="right">
            <q-btn flat label="OK" color="primary" v-close-popup></q-btn>
          </q-card-actions>
        </div>
      </q-card>
    </q-dialog>
    <!-------------------------->
    <q-dialog v-model="notifyCard">
      <alertCard
        :cd_tipo_layout="infoCard.cd_tipo_layout"
        :nm_texto_titulo="infoCard.nm_texto_titulo"
        :nm_descritivo="infoCard.nm_descritivo"
        :nm_icon="infoCard.nm_icon"
        :nm_cor_icon="infoCard.nm_cor_icon"
      />
    </q-dialog>
  </div>
</template>

<script>
import DxPieChart, {
  DxLegend,
  DxSeries,
  DxExport,
  DxHoverStyle,
  DxTooltip,
  DxLabel,
  DxConnector,
} from "devextreme-vue/pie-chart";
import { DxAdaptiveLayout } from "devextreme-vue/pie-chart";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import notify from "devextreme/ui/notify";
import Etapa from "../views/moduloEtapaProcesso";
import alertCard from "../components/alertCard.vue";
import dashBoard_Componente from "@/views/dashboard-componente.vue"; // ajuste o caminho

//import selecionarModulo from '@/components/selecionarModulo.vue'

var cd_api = 0;
var api = "";

var grafico = [];

export default {
  components: {
    DxAdaptiveLayout,
    DxPieChart,
    DxLegend,
    DxSeries,
    DxExport,
    DxHoverStyle,
    DxTooltip,
    DxLabel,
    DxConnector,
    Etapa,
    alertCard,
    dashBoard_Componente,
    //  selecionarModulo,
    HTMLDinamico: () => import("./HTMLDinamico.vue"),
    //
  },
  computed: {
    // pegue de onde fizer sentido no seu app; aqui um fallback no sessionStorage
    // pegue de onde fizer sentido no seu app; aqui um fallback no sessionStorage
    cdModuloDash() {
      return Number(
        this.cd_modulo ||
          localStoragecd_modulo ||
          sessionStorage.getItem("cd_dashboard") ||
          sessionStorage.getItem("cd_modulo") ||
          0
      );
    },
    cdUsuarioDash() {
      return Number(
        this.cd_usuario ||
          localStorage.cd_usuario ||
          sessionStorage.getItem("cd_usuario") ||
          0
      );
    },
    dtInicialDash() {
      return (
        this.dt_inicial ||
        localStorage.dt_inicial ||
        sessionStorage.getItem("dt_inicial_padrao") ||
        ""
      );
    },
    dtFinalDash() {
      return (
        this.dt_final ||
        localStorage.dt_final ||
        sessionStorage.getItem("dt_final_padrao") ||
        ""
      );
    },
  },

  data() {
    return {
      showDashboard: false, // controla o QDialog
      fila: [],
      nomeTitulo: "Painel Informativo",
      cd_pagina_modulo: this.$store._mutations.SET_Usuario.cd_pagina || 0,
      ic_pagina_modulo: "N",
      //ic_pagina_modulo: this.$store._mutations.SET_Usuario.cd_pagina
      //  ? "S"
      //  : "N",
      load_pagina: false,
      dataSourceConfig: [],
      dados_indicador: undefined,
      atendimentoEncontrado: false,
      cd_modulo: localStorage.cd_modulo,
      nomeUsuario: localStorage.usuario,
      polling: null,
      call: false,
      maximizedToggle: true,
      //load_tela: true,
      localFila: 0,
      infoCard: {
        nm_icon: "",
        nm_texto_titulo: "",
        nm_descritivo: "",
        cd_tipo_layout: 0,
        nm_cor_icon: "negative",
      },
      notifyCard: false,
      //destinatario: "",
      tituloGrafico: "",
      legenda: "",
      cd_menu: "0", //localStorage.cd_menu,
      cd_cliente: localStorage.cd_cliente,
      valor: "",
      nomeModulo: localStorage.nm_modulo,
      dt_inicial: "",
      expansionModel: true,
      dt_final: "",
      dt_base: "",
      cor: "#2D4C71",
      aniversariante: false,
      g: 0,
      dados_home: [],
      cd_usuario: localStorage.cd_usuario,
      cd_empresa: localStorage.cd_empresa,
      celular: 0,
      vl_acumulado: 0,
      ic_etapa: "N",
      showSelecionarModulo: false,
    };
  },

  created() {
    if (
      localStorage.nm_identificacao_rota != undefined &&
      localStorage.nm_identificacao_rota != "undefined" &&
      localStorage.nm_identificacao_rota != null &&
      localStorage.nm_identificacao_rota != "null"
    ) {
      this.$router.push({ name: localStorage.nm_identificacao_rota });
    }
  },

  async mounted() {
    //this.load_tela = true;
    this.load_pagina = true;
    this.detectar();

    //  this.$router.push('/home');
    //this.$router.push(this.$route.query.redirect || "/home",  { clearHistory: true });

    this.dt_nascimento_usuario = localStorage.dt_nascimento_usuario;
    this.dt_base               = localStorage.dt_base;

    if (this.cd_modulo == 220 && this.cd_empresa == 240) {
      //Educalibras
      this.ic_etapa == "N";
    } else {
      //this.ic_etapa = localStorage.ic_etapa_processo;
      this.ic_etapa = "S";
    }

    //if (!localStorage.nm_destinatario == "") {
    //  this.destinatario = localStorage.nm_destinatario + ", ";
    //}

    this.dt_nascimento_usuario = new Date(localStorage.dt_nascimento_usuario);
    var dataAniv = this.dt_nascimento_usuario;
    var diaAniv = dataAniv.getDate().toString();
    var mesAniv = dataAniv.getMonth() + 1;
    var hoje = localStorage.dt_base;
    if (!hoje) {
      // padrão dd/mm/yyyy
      const d = new Date()
      const dd = String(d.getDate()).padStart(2, '0')
      const mm = String(d.getMonth() + 1).padStart(2, '0')
      const yyyy = d.getFullYear()
      hoje = `${dd}/${mm}/${yyyy}`
      localStorage.dt_base = hoje
    }


    var diaHoje = hoje.slice(0, 2);
    var mesHoje = hoje.slice(3, 5);

    if (
      diaAniv == diaHoje &&
      mesAniv == mesHoje &&
      localStorage.cd_usuario != 0
    ) {
      this.aniversariante = true;
    }

    //
    await this.carregaDados();
    //

    this.load_pagina = false;

    // Carrega o HTML Dinâmico automaticamente no reload
    //if (this.$store._mutations.SET_Usuario.cd_pagina > 0) {
    //  this.recarregarHTML();
    //}
  },

  watch: {
    //showDashboard (val) { this.ic_pagina_modulo = val ? 'S' : 'N' },

    expansionModel() {
      if (this.expansionModel == false) {
        this.expansionModel = true;
      }
    },
  },

  methods: {
    abrirDashboard() {
      this.showDashboard = !this.showDashboard;

      // debug: veja no console se foi chamado
      console.log("[moduloEtapa] showDashboard:", this.showDashboard, {
        cdModulo: this.cdModuloDash,
        cdUsuario: this.cdUsuarioDash,
        dtInicial: this.dtInicialDash,
        dtFinal: this.dtFinalDash,
      });
    },

    detectar() {
      if (
        navigator.userAgent.match(/Android/i) ||
        navigator.userAgent.match(/webOS/i) ||
        navigator.userAgent.match(/iPhone/i) ||
        navigator.userAgent.match(/iPad/i) ||
        navigator.userAgent.match(/iPod/i) ||
        navigator.userAgent.match(/BlackBerry/i) ||
        navigator.userAgent.match(/Windows Phone/i)
      ) {
        this.celular = 1;
      } else {
        this.celular = 0;
      }
    },

    VoltaGrafico() {
      this.ic_etapa = "N";
    },

    pointClickHandler({ target }) {
      target.select();
    },

    customizeTooltip({ valueText, percent }) {
      return {
        text: `${valueText} - ${(percent * 100).toFixed(2)}%`,
      };
    },

    dataIndicadores(e) {
      this.dados_indicador = e;
    },

    async carregaDados() {
      try {
        this.dt_inicial = new Date(
          localStorage.dt_inicial
        ).toLocaleDateString();
        this.dt_final = new Date(localStorage.dt_final).toLocaleDateString();
        this.dt_base = new Date(localStorage.dt_base).toLocaleDateString();

        cd_api = "61"; //localStorage.cd_home;
        grafico = await Menu.montarMenu(this.cd_empresa, this.cd_menu, cd_api);
        api = grafico.nm_identificacao_api;

        if (grafico.cd_menu > 0) {
          let sParametroApi = grafico.nm_api_parametro;
          api = grafico.nm_identificacao_api;

          this.g = 1;

          if (grafico.ic_grafico_empresa == "S") {
            this.g = 0;
            notify(
              "Aguarde... estamos montando o gráfico para você, aguarde !"
            );
          }

          localStorage.cd_tipo_consulta = grafico.cd_tipo_consulta;

          this.tituloGrafico = grafico.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';

          //Gera os Dados para Montagem da Grid
          //exec da procedure

          if (!api == "") {
            this.dataSourceConfig = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_cliente,
              api,
              sParametroApi
            );
          }
          const arr = Array.isArray(this.dataSourceConfig)
            ? this.dataSourceConfig
            : [];
          const first = arr[0] || {};
          const total = arr.length || 0;

          if (total === 0) {
            // zere datasets/series para o chart e retorne
            this.seriesGrafico = []; // ou o nome do seu array de séries
            this.categorias = []; // se usar categorias/eixo

            /*
            this.$q.notify({
              type: "warning",
              position: 'center',
              message: "Sem dados para o período.",
            });
            */
            
            return;

          }

          //console.log('Dados do Gráfico:', { total, first, arr });

          // Se vier erro, exibe e sai
          if (first.hasOwnProperty("erro")) {
            notify(first.erro, "error", 5000);
            this.dataSourceConfig = [];
            return;
          }
          if (this.dataSourceConfig.length == 0) {
            notify("Nenhum dado encontrado!", "warning", 2000);
            return;
          }

          if (first.vl_acumulado != null) {
            this.vl_acumulado = Number(first.vl_acumulado).toLocaleString(
              "pt-br",
              {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
              }
            );
          } else {
            this.vl_acumulado = 0;
          }

          this.legenda = "nm_mes";
          this.valor = "vl_total";

          if (this.dataSourceConfig[0].vl_acumulado) {
            this.vl_acumulado = this.dataSourceConfig[0].vl_acumulado.toLocaleString(
              "pt-br",
              {
                style: "currency",
                currency: "BRL",
              }
            );
          } else {
            this.vl_acumulado = 0;
          }

          this.vl_card1 = this.dataSourceConfig[0].vl_card1 || 0;
          this.vl_card2 = this.dataSourceConfig[0].vl_card2 || 0;
          this.vl_card3 = this.dataSourceConfig[0].vl_card3 || 0;
          this.vl_card4 = this.dataSourceConfig[0].vl_card4 || 0;
          this.vl_card5 = this.dataSourceConfig[0].vl_card5 || 0;
          this.vl_card6 = this.dataSourceConfig[0].vl_card6 || 0;
          this.nm_card1 = this.dataSourceConfig[0].nm_card1 || "";
          this.nm_card2 = this.dataSourceConfig[0].nm_card2 || "";
          this.nm_card3 = this.dataSourceConfig[0].nm_card3 || "";
          this.nm_card4 = this.dataSourceConfig[0].nm_card4 || "";
          this.nm_card5 = this.dataSourceConfig[0].nm_card5 || "";
          this.nm_card6 = this.dataSourceConfig[0].nm_card6 || "";

          this.dados_home = [
            {
              vl_card: this.dataSourceConfig[0].vl_card1,
              nm_card: this.dataSourceConfig[0].nm_card1,
              lb_card: "1",
            },
            {
              vl_card: this.dataSourceConfig[0].vl_card2,
              nm_card: this.dataSourceConfig[0].nm_card2,
              lb_card: "2",
            },
            {
              vl_card: this.dataSourceConfig[0].vl_card3,
              nm_card: this.dataSourceConfig[0].nm_card3,
              lb_card: "3",
            },
            {
              vl_card: this.dataSourceConfig[0].vl_card4,
              nm_card: this.dataSourceConfig[0].nm_card4,
              lb_card: "4",
            },
            {
              vl_card: this.dataSourceConfig[0].vl_card5,
              nm_card: this.dataSourceConfig[0].nm_card5,
              lb_card: "5",
            },
            {
              vl_card: this.dataSourceConfig[0].vl_card6,
              nm_card: this.dataSourceConfig[0].nm_card6,
              lb_card: "6",
            },
          ];
        }
      } catch (error) {
        console.error("Erro ao carregar dados:", error);
      }
    },

    recarregarHTML() {
      this.ic_pagina_modulo = "N";
      setTimeout(() => {
        this.ic_pagina_modulo = "S";
      }, 1);
    },
  },

  /*
  abrirSeletorModulo () { this.showSelecionarModulo = true },

  onModuloSelecionado (modulo) {
      // aqui você decide: navegar, trocar de layout, etc.
      // exemplo simples: guardar e ir para a página do módulo/kanban
      sessionStorage.setItem('cd_modulo', modulo.cd_modulo)
      sessionStorage.setItem('nm_modulo', modulo.nm_modulo)
      this.$q.notify({ type:'positive', message:`${modulo.nm_modulo} selecionado`, position:'top-right' })
      this.showSelecionarModulo = false
      // se existir rota/visão específica, navegue:
      // this.$router.push({ name: 'kanban', params: { moduloId: modulo.cd_modulo } })
    },
    onMenuLateralAtualizado (menu) {
      // se você tiver um store/vuex/pinia, poderia salvar o menu aqui
      // this.$store.commit('SET_MENU_LATERAL', menu)
    },
  */

  // Limpa o polling se sair da página
  // eslint-disable-next-line vue/no-unused-properties
  //

  //
  destroyed() {
    clearInterval(this.polling);
  },
};
</script>

<style lang="scss" scoped>
@import url("./views.css");

.borda {
  border-radius: 20px;
}

.aniversariante {
  margin: 0 auto;
  padding: 0;
  background: url("https://acegif.com/wp-content/gif/confetti-17.gif") no-repeat
    fixed center;
}

.label_cima {
  width: 100%;
  margin-left: -5px;
  text-align: left;
}

.lb-acumulado {
  font-size: 90%;
}

.column {
  float: center;
  width: 16.6%;
  height: 100px;
  padding: 0 5px;
  margin-top: 5px;
}

.row {
  margin: 0 0;
}

/* Clear floats after the columns */
.row:after {
  content: "";
  display: inline-flex;
  clear: both;
}

.cards {
  max-width: 100%;
  margin: 10px 5px;
  display: grid;
  grid-template-columns: repeat(6, minmax(calc(96% / 6), 0fr));
  grid-gap: 10px;
}

.label_baixo {
  margin-top: 5px;
  font-size: 100%;
  color: #2d4c71;
}

.my-card {
  background-color: white;
}

.bgRadial {
  background: radial-gradient(circle, #fff 0%, #bccbf6 80%);
  color: black;
}

.cards_celular {
  margin-top: 15px;
  text-align: center;
}
.btn-dash {
  margin-left: -10px;
}
</style>
