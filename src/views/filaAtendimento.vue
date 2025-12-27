<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center justify-center">
      <q-expansion-item
        class="overflow-hidden borda margin1 shadow-2 metadeTela"
        icon="timer"
        v-model="expansionModel"
        label="Fila de Atendimento"
        default-opened
        header-class="bg-primary text-white items-center text-h5"
        expand-icon-class="text-white "
      >
        <q-card style="padding:10px">
          <div class="row items-center justify-center">
            <transition name="slide-fade">
              <q-circular-progress
                v-if="atendimentoEncontrado"
                show-value
                class="text-blue-8 margin1"
                :value="localFila"
                size="300px"
                :min="0"
                :max="localFila + 1"
                animation-speed="180"
                color="blue-6"
              />
            </transition>
          </div>
          <transition name="slide-fade">
            <div
              v-if="atendimentoEncontrado && localFila > 1"
              class="row text-h6 items-center justify-center margin1"
            >
              Aguarde, sua posição na fila é {{ localFila }} | Protocolo:
              {{ resultado_insere[0].cd_atendimento_movimento }}
              <!-- {{ resultado_insere[0].nm_sala_atendimento }} -->
              {{ fila[0].nm_link_atendimento }}
            </div>
          </transition>
          <transition name="slide-fade">
            <div
              v-if="atendimentoEncontrado && localFila == 1"
              class="row text-h6 items-center justify-center margin1"
            >
              Você é o próximo a ser atendido!
            </div>
          </transition>
          <transition name="slide-fade">
            <div
              v-if="atendimentoEncontrado == false"
              class="row text-h6 items-center justify-center margin1"
            >
              Aguardando Atendimento!
            </div>
          </transition>
          <!-- <div class="row text-subtitle2 items-center justify-center">
            <transition name="slide-fade">
              <q-btn
                class="margin1"
                color="primary"
                icon-right="login"
                v-if="localFila == 1 && atendimentoEncontrado"
                label="Iniciar atendimento"
                @click="initCall()"
                rounded
              />
            </transition>
          </div> -->
        </q-card>
      </q-expansion-item>
    </div>

    <q-dialog
      v-model="call"
      persistent
      :maximized="maximizedToggle"
      transition-show="jump-up"
      transition-hide="jump-down"
    >
      <q-card class="fundo-painel text-black">
        <q-bar class="bg-orange-9 text-white">
          <!--
            <p style="margin:0" v-if="localFila > 0">
              {{ fila[0].nm_usuario_operador }}
            </p>
          -->

          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-white text-white"
              >Minimizar</q-tooltip
            >
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-white text-primary"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup @click="fechaTela()">
            <q-tooltip class="fundo-painel text-primary">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <transition name="slide-fade">
          {{ fila[localFila] }}
          <jitsi
            v-if="atendimentoEncontrado"
            :nm_link_atendimento="fila[0].nm_link_atendimento"
            :nm_titulo_atendimento="resultado_insere[0].nm_sala_atendimento"
          />
        </transition>
        <div class="row items-center justify-center">
          <transition name="slide-fade">
            <q-input
              class="margin1 col"
              v-model="fila[0].nm_link_atendimento"
              label="Link"
              v-if="atendimentoEncontrado"
              readonly
              dense
            >
              <template v-slot:prepend>
                <q-icon name="link" />
              </template>
              <template v-slot:append>
                <q-btn
                  flat
                  color="primary"
                  round
                  icon="content_copy"
                  @click="Copy()"
                />
              </template>
            </q-input>
          </transition>
        </div>
      </q-card>
    </q-dialog>

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

export default {
  async mounted() {
    await this.buscaFila();
  },
  beforeDestroy() {
    clearInterval(this.polling);
  },
  watch: {
    async notifyCard() {
      if (this.notifyCard == false) {
        await this.buscaFila();
      } else {
        clearInterval(this.polling);
      }
    },
    // async call() {
    //   if (this.call == false) {
    //     await this.buscaFila();
    //   }
    // },
    atendimentoEncontrado(novo, antigo) {
      if (antigo == true && novo == false) {
        this.call = false;
        this.$router.push({ name: "home" });
      }
    },
  },
  components: {
    jitsi: () => import("../components/callJitsi.vue"),
    carregando: () => import("../components/carregando.vue"),
  },

  data() {
    return {
      fila: [],
      polling: null,
      maximizedToggle: true,
      expansionModel: true,
      atendimentoEncontrado: false,
      api: "772/1174", //pr_egisnet_controle_usuario
      localFila: 0,
      atendente_logado: {},
      call: false,
      load_tela: false,
      resultado_insere: [],
      cd_cliente: localStorage.cd_cliente,
      cd_usuario: localStorage.cd_usuario,
      cd_empresa: localStorage.cd_empresa,
      cd_atendimento_movimento: 0,
    };
  },
  methods: {
    async Copy() {
      if (!!this.fila[0].nm_link_atendimento) {
        const text = this.fila[0].nm_link_atendimento;
        await navigator.clipboard.writeText(text);
        notify("Texto copiado");
      } else {
        notify("Texto não encontrado!");
      }
    },

    async initCall() {
      let inicia_atendimento = {
        cd_atendimento_movimento: this.resultado_insere[0]
          .cd_atendimento_movimento,
        cd_parametro: 8,
        cd_usuario: this.cd_usuario,
      };
      let result_api = await Incluir.incluirRegistro(
        this.api, //pr_egisnet_controle_usuario
        inicia_atendimento,
      );
      notify(result_api[0].msg);
      clearInterval(this.polling);
      this.call = true;
    },

    async insereFila() {
      let solicita_atendimento = {
        cd_cliente: this.cd_cliente,
        cd_parametro: 11,
        cd_empresa: this.cd_empresa,
        cd_usuario: this.cd_usuario,
      };
      this.resultado_insere = await Incluir.incluirRegistro(
        this.api, //pr_egisnet_controle_usuario
        solicita_atendimento,
      );
      this.cd_atendimento_movimento = this.resultado_insere[0].cd_atendimento_movimento;
    },

    async fechaTela() {
      try {
        let finalizaAtendimento = {
          cd_parametro: 7,
          cd_movimento_atendimento: this.resultado_insere[0]
            .cd_atendimento_movimento,
          cd_usuario_operador: this.cd_usuario,
          cd_usuario: this.cd_usuario,
        };
        const fim = await Incluir.incluirRegistro(
          "772/1174", //this.api,
          finalizaAtendimento,
        );
        notify(fim[0].Msg);
        this.$router.push({ name: "home" });
      } catch (error) {
        this.$router.push({ name: "home" });
      }
    },

    async buscaFila() {
      await this.insereFila();
      this.polling = setInterval(async () => {
        const busca = {
          cd_cliente: this.cd_cliente,
          cd_parametro: 10,
          cd_empresa: this.cd_empresa,
          cd_usuario: this.cd_usuario,
          cd_atendimento_movimento: this.cd_atendimento_movimento,
        };
        if (
          this.cd_cliente == undefined ||
          this.cd_empresa == undefined ||
          localStorage.cd_empresa == undefined ||
          localStorage.cd_empresa == 0 ||
          this.cd_usuario == undefined
        ) {
          return;
        }

        try {
          this.fila = await Incluir.incluirRegistro(this.api, busca); //pr_egisnet_controle_usuario
          // let usuario_verificacao = this.fila.some((e) => {
          //   if (e.cd_usuario_atendimento == this.cd_usuario) {
          //     return true;
          //   }
          // });
          if (this.fila[0].Cod == 0) {
            notify(this.fila[0].Msg);
            this.fila = [];
            this.atendimentoEncontrado = false;
            this.localFila = 0;
            this.infoCard = {
              nm_icon: "close",
              nm_texto_titulo: "Atendimento não encontrado",
              nm_descritivo: "Seu atendimento não foi encontrado!",
              cd_tipo_layout: 0,
              nm_cor_icon: "warning",
            };
            this.notifyCard = true;
            await this.insereFila();
          } else {
            this.notifyCard = false;
            this.localFila = 0;
            //// Pega o primeiro lugar na lista de atendimento em aberto
            //// (Filtra a fila por usuário logado na PR)
            this.localFila = this.fila[0].posicao;
            // this.fila.forEach((e) => { ////Pega o último lugar da fila (se tiver mais de um lugar)
            //   if (e.cd_usuario_atendimento == this.cd_usuario) {
            //     this.atendente_logado = e;
            //     this.localFila = e.posicao;
            //   }
            // });
            if (this.localFila == -1) {
              this.atendimentoEncontrado = false;

              notify("Atendimento não agendado!", "error", 3000);
            } else {
              this.atendimentoEncontrado = true;
            }
          }
          if (this.fila[0].dt_inicio_atendimento != "") {
            this.call = true;
          }
        } catch (error) {
          this.atendimentoEncontrado = false;
          console.log(error);
        }
      }, 1500);
    },
  },
};
</script>

<style scoped></style>
