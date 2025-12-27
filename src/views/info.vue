<template>
  <div>
    <div class="row items-center margin1">
      <div class="text-h6 ">
        Atendimento - {{ this.cd_movimento }}
        <transition name="slide-fade">
          <q-badge
            align="top"
            color="positive"
            rounded
            v-if="ic_agendado == 'S'"
            >Agendado</q-badge
          >
        </transition>
        <transition name="slide-fade">
          <q-badge
            align="top"
            color="negative"
            rounded
            v-if="!!atendimento.dt_ocorrencia_atendimento"
            >Cancelado</q-badge
          >
        </transition>
      </div>

      <q-space />
      <div>
        <transition name="slide-fade">
          <q-btn
            v-if="
              !!atendimento.dt_ocorrencia_atendimento == false &&
                atendimento.dt_final_atendimento == ' - 00:00:00'
            "
            icon="close"
            size="sm"
            round
            color="negative"
            @click="popupCancelamento = true"
            class="margin1"
          >
            <q-tooltip>
              Cancelar Atendimento
            </q-tooltip>
          </q-btn>
        </transition>

        <q-btn
          round
          color="primary"
          size="sm"
          icon="refresh"
          @click="carregaDados()"
        >
          <q-tooltip>
            Recarregar dados
          </q-tooltip>
        </q-btn>
      </div>
    </div>
    <transition name="slide-fade">
      <transition name="slide-fade">
        <div class="text-center text-subtitle2" v-if="atendimento.Cod == 0">
          Atendimento não encontrado
        </div>
        <div v-else>
          <q-bar class="bg-primary text-white" style="border-radius:5px">
            Dados da Solicitação
          </q-bar>

          <div class="row items-center" style="margin:0; padding: 0">
            <q-input
              class="margin1 telaInteira"
              v-model="atendimento.dt_atendimento_movimento"
              label="Data de Solicitação"
              readonly
              dense
            >
              <template v-slot:prepend>
                <q-icon name="today" />
              </template>
            </q-input>
          </div>

          <div class="row items-center" style="margin:0; padding: 0">
            <q-input
              class="margin1 telaInteira"
              v-model="atendimento.nm_fantasia_cliente"
              label="Cliente"
              readonly
              dense
            >
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
            </q-input>
          </div>

          <div class="row items-center" style="margin:0; padding: 0">
            <q-input
              class=" margin1 telaInteira"
              v-model="atendimento.nm_usuario"
              label="Solicitante"
              readonly
              dense
            >
              <template v-slot:prepend>
                <q-icon name="badge" />
              </template>
            </q-input>
          </div>

          <q-bar class="bg-primary text-white" style="border-radius:5px">
            Dados do Atendimento
          </q-bar>
          <div class="row items-center justify-around">
            <q-input
              class="margin1 telaInteira"
              v-model="atendimento.nm_usuario_operador"
              label="Atendente"
              readonly
              dense
            >
              <template v-slot:prepend>
                <q-icon name="badge" />
              </template>
            </q-input>
          </div>
          <div class="row items-center justify-around">
            <q-input
              class="margin1 telaInteira"
              v-model="atendimento.ds_atendimento_movimento"
              v-show="!!atendimento.ds_atendimento_movimento"
              label="Descritivo"
              readonly
              autogrow
              dense
            >
              <template v-slot:prepend>
                <q-icon name="badge" />
              </template>
            </q-input>
          </div>
          <div class="row items-center justify-around">
            <q-input
              class="margin1 telaInteira"
              v-model="atendimento.dt_ocorrencia_atendimento"
              v-show="!!atendimento.dt_ocorrencia_atendimento"
              label="Data de Ocorrência"
              readonly
              autogrow
              dense
            >
              <template v-slot:prepend>
                <q-icon name="date_range" />
              </template>
            </q-input>
          </div>
          <div class="row items-center justify-around">
            <q-input
              class="margin1 telaInteira"
              v-model="atendimento.nm_motivo_ocorrencia"
              v-show="!!atendimento.nm_motivo_ocorrencia"
              label="Ocorrência"
              readonly
              autogrow
              dense
            >
              <template v-slot:prepend>
                <q-icon name="description" />
              </template>
            </q-input>
          </div>
          <div class="row items-center justify-around">
            <q-input
              class="margin1 telaInteira"
              v-model="atendimento.dt_inicio_atendimento"
              label="Início do atendimento"
              readonly
              dense
            >
              <template v-slot:prepend>
                <q-icon name="today" />
              </template>
            </q-input>
          </div>
          <div class="row items-center justify-around">
            <q-input
              class="margin1 telaInteira"
              v-model="atendimento.dt_final_atendimento"
              label="Final do atendimento"
              readonly
              dense
            >
              <template v-slot:prepend>
                <q-icon name="today" />
              </template>
            </q-input>
          </div>
          <div class="row items-center justify-around">
            <transition name="slide-fade">
              <q-input
                class="margin1 telaInteira"
                v-model="atendimento.nm_link_atendimento"
                label="Link"
                v-if="
                  !!atendimento.nm_link_atendimento &&
                    !!atendimento.dt_final == false
                "
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

              <div class="row margin1 items-center text-center" v-else>
                Link de Acesso vazio!
              </div>
            </transition>
          </div>
          <!-- <div class="row items-center justify-around">
          <q-checkbox v-model="ic_agendado" label="Agendado" disable />
        </div>-->

          <div class="row items-center justify-around">
            <transition name="slide-fade">
              <q-btn
                color="primary"
                rounded
                class="margin1"
                icon="login"
                label="Atendimento"
                v-if="
                  !!atendimento.nm_link_atendimento &&
                    !!atendimento.dt_final == false
                "
                @click="AbreAtendimento()"
                :disable="!!atendimento.nm_link_atendimento == false"
              />
            </transition>
            <!--<a :href="atendimento.nm_link_atendimento" target="_blank" v-if="atendimento.nm_link_atendimento"></a>-->
          </div>
        </div>
      </transition>
    </transition>
    <!------------------------------------------------------------------->
    <q-dialog v-model="popupAtendimento" full-height full-width>
      <q-card class="column full-height">
        <div class="text-h6 margin1">Atendimento</div>

        <q-card-section class="col margin1">
          <iframe
            style="width:100%; height:100%"
            :src="atendimento.nm_link_atendimento"
            title="Atendimento"
            allow="geolocation; microphone;camera"
          ></iframe>
        </q-card-section>

        <q-card-actions class="bg-white text-primary">
          <!-- <q-btn
            icon="close"
            rounded
            label="Cancelar Atendimento"
            color="negative"
            @click="popupCancelamento = true"
            v-close-popup
            class="margin1"
          /> -->
          <q-space />
          <q-btn
            icon="check"
            color="primary"
            rounded
            class="margin1"
            label="Finalizar atendimento"
            v-close-popup
            @click="FinalizarAtendimento()"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------------->
    <q-dialog v-model="popupCancelamento" persistent>
      <q-card style="width: 700px; max-width: 80vw;">
        <q-card-section>
          <div class="text-h6">Ocorrência</div>
        </q-card-section>

        <div>
          <q-input
            class="margin1 "
            v-model="atendimento.nm_motivo_ocorrencia"
            label="Motivo"
            autogrow
            dense
            maxlength="499"
          >
            <template v-slot:prepend>
              <q-icon name="description" />
            </template>
          </q-input>
        </div>

        <div class="row items-center">
          <q-btn
            rounded
            flat
            color="primary"
            class="margin1"
            label="Voltar"
            v-close-popup
            icon="undo"
          />
          <q-space />
          <q-btn
            rounded
            icon="check"
            label="Confirmar"
            color="primary"
            class="margin1"
            @click="CloseCall()"
            v-close-popup
          />
        </div>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando />
    </q-dialog>
  </div>
</template>

<script>
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";
import Incluir from "../http/incluir_registro";

export default {
  name: "info",
  props: {
    prop_form: {
      type: Object,
      default() {
        return {};
      },
    },
    cd_info: {
      type: Number,
      default() {
        return 0;
      },
    },
    kanban: { type: Boolean, default: false },
  },
  data() {
    return {
      popupAtendimento: false,
      popupCancelamento: false,
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_movimento: 0,
      api: "772/1174", //pr_egisnet_controle_usuario
      atendimento: {
        cd_atendimento_movimento: 0,
        cd_cliente: 0,
        cd_contato_cliente: 0,
        cd_horario_composicao: 0,
        cd_usuario_atendimento: 0,
        cd_usuario_operador: 0,
        ds_atendimento_movimento: "",
        dt_atendimento_movimento: "",
        dt_final_atendimento: "",
        dt_inicio_atendimento: "",
        dt_ocorrencia_atendimento: "",
        dt_final: "",
        dt_inicio: "",
        hr_inicio_horario: "",
        hr_fim_horario: "",
        ic_agendado: "",
        nm_contato_cliente: "",
        nm_fantasia_cliente: "",
        nm_usuario_operador: "",
        nm_tipo_horario: "",
        nm_link_atendimento: "",
        nm_motivo_ocorrencia: "",
        nm_usuario: "",
        dt_cancelamento_movimento: "",
      },
      load: true,
      ic_agendado: false,
      nm_link_atendimento: "",
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    this.cd_movimento = this.prop_form.cd_movimento;
    if (!!this.cd_movimento == false) {
      notify("Atendimento não encontrado!");
      return;
    } else {
      await this.carregaDados();
    }
  },
  components: {
    carregando: () => import("../components/carregando.vue"),
  },
  watch: {
    popupCancelamento() {
      if (this.popupCancelamento == true) {
        this.atendimento.nm_motivo_ocorrencia = "";
      }
    },
  },
  methods: {
    async CloseCall() {
      if (!!this.atendimento.nm_motivo_ocorrencia == false) {
        notify("Digite o motivo do Cancelamento!");
        return;
      }
      const c = {
        cd_parametro: 9,
        nm_motivo_ocorrencia: this.atendimento.nm_motivo_ocorrencia,
        cd_atendimento_movimento: this.cd_movimento,
        cd_usuario: this.cd_usuario,
      };

      const fim = await Incluir.incluirRegistro(this.api, c);
      this.$emit("click");
    },
    async Copy() {
      if (!!this.atendimento.nm_link_atendimento) {
        let text = this.atendimento.nm_link_atendimento;
        await navigator.clipboard.writeText(text);
        notify("Texto copiado");
      } else {
        notify("Texto não encontrado!");
      }
    },
    async FinalizarAtendimento() {
      let f = {
        cd_parametro: 7,
        cd_movimento_atendimento: this.cd_movimento,
        cd_usuario_operador: this.cd_usuario,
        cd_usuario: this.cd_usuario,
      };

      const fim = await Incluir.incluirRegistro(this.api, f);
      notify(fim[0].Msg);
      this.$emit("click");
    },
    async AbreAtendimento() {
      if (!!this.atendimento.nm_link_atendimento) {
        this.popupAtendimento = true;
        let i = {
          cd_parametro: 8,
          cd_atendimento_movimento: this.cd_movimento,
          cd_usuario: this.cd_usuario,
        };
        const inicio = await Incluir.incluirRegistro(this.api, i);
        notify(inicio[0].Msg);
      } else {
        notify("Link não encontrado!");
        return;
      }
    },
    async carregaDados() {
      if (!!this.cd_movimento == false) return;

      try {
        this.load = true;
        let c = {
          cd_parametro: 6,
          cd_atendimento_movimento: this.cd_movimento,
        };
        const consulta = await Incluir.incluirRegistro(this.api, c);
        if (consulta[0].Cod == 0) {
          notify(consulta[0].Msg);
          this.load = false;
          return;
        } else {
          this.atendimento = {
            cd_atendimento_movimento: consulta[0].cd_atendimento_movimento,
            cd_cliente: consulta[0].cd_cliente,
            cd_contato_cliente: consulta[0].cd_contato_cliente,
            cd_controle: consulta[0].cd_controle,
            cd_horario_composicao: consulta[0].cd_horario_composicao,
            cd_usuario_atendimento: consulta[0].cd_usuario_atendimento,
            cd_usuario_operador: consulta[0].cd_usuario_operador,
            ds_atendimento_movimento: consulta[0].ds_atendimento_movimento,
            dt_atendimento_movimento: consulta[0].dt_atendimento_movimento,
            dt_final_atendimento: consulta[0].dt_final_atendimento,
            dt_inicio_atendimento: consulta[0].dt_inicio_atendimento,
            dt_ocorrencia_atendimento: consulta[0].dt_ocorrencia_atendimento,
            ic_agendado: consulta[0].ic_agendado,
            nm_contato_cliente: consulta[0].nm_contato_cliente,
            nm_fantasia_cliente: consulta[0].nm_fantasia_cliente,
            nm_usuario_operador: consulta[0].nm_usuario_operador,
            nm_tipo_horario: consulta[0].nm_tipo_horario,
            nm_link_atendimento: consulta[0].nm_link_atendimento,
            nm_motivo_ocorrencia: consulta[0].nm_motivo_ocorrencia,
            nm_usuario: consulta[0].nm_usuario,
            dt_final: consulta[0].dt_final,
            dt_inicio: consulta[0].dt_inicio,
            hr_fim_horario: consulta[0].hr_fim_horario,
            hr_inicio_horario: consulta[0].hr_inicio_horario,
            dt_cancelamento_movimento: consulta[0].dt_cancelamento_movimento,
          };
          if (this.atendimento.ic_agendado == "S") {
            this.ic_agendado = true;
          }
          this.nm_link_atendimento = this.atendimento.nm_link_atendimento;
        }
        this.load = false;
      } catch (error) {
        this.load = false;
      }
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}

.metadeTela {
  width: 47.5%;
}

.umTercoTela {
  width: 31%;
}

.umQuartoTela {
  width: 22.5%;
}
.telaInteira {
  width: 100%;
}
@media (max-width: 900px) {
  .metadeTela {
    width: 100%;
  }

  .umTercoTela {
    width: 100%;
  }

  .umQuartoTela {
    width: 100%;
  }
  .margin1 {
    margin: 1vh 1vw;
  }
}
.slide-fade-enter-active {
  transition: all 0.3s ease;
}
.slide-fade-leave-active {
  transition: all 0.4s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter, .slide-fade-leave-to
/* .slide-fade-leave-active below version 2.1.8 */ {
  transform: translateX(10px);
  opacity: 0;
}
a {
  text-decoration: none;
}
</style>
