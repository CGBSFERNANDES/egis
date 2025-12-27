<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <!-- ----------------------------------------------------------------- -->
    <div class="margin1">
      <q-toolbar-title
        style="text-align: center; color: white; border-radius: 30px"
        HEAD
        class="bg-orange-9 margin1 shadow-2 text-bold"
        >Agenda de Atendimento</q-toolbar-title
      >
      <!-- <DxScheduler
        class="dx-card wide-card"
        time-zone="America/Sao_Paulo"
=======
        class="bg-orange-9 margin1 shadow-2"
        >Agenda de Atendimento</q-toolbar-title
      >
      <DxScheduler
        class="dx-card wide-card"
        time-zone="America/Los_Angeles"
>>>>>>> 6c912b8c81f2af8b141de6c0081e417a50abfbcf
        :data-source="dataSourceConfig"
        :current-date="currentDate"
        :views="views"
        :height="600"
        current-view="month"
      >
        <DxResource
          v-if="ic_filtro_pesquisa == 'S'"
          :data-source="cores"
          field-expr="cd_motivo_visita"
          label="Motivo Visita"
        />
      </DxScheduler> -->
      <div style="display: flex; justify-content: space-around">
        <div>
          <q-field borderless stack-label>
            <template v-slot:control>
              <div
                class="margin1 self-center full-width no-outline text-bold"
                tabindex="0"
                style="font-size: 18px"
              >
                Escolha uma data e horário para agendar seu atendimento
              </div>
            </template>
          </q-field>
          <q-card class="margin1 card-opcoes shadow-2">
            <RangeData class="margin1 card-column" @trocouData="trocouData()" />
            <q-card-section class="card-column q-pt-none">
              <div class="text-h6">Data</div>
              <div class="text-h6">Hora</div>
            </q-card-section>
            <q-separator inset />

            <q-card-section class="q-pt-none">
              <q-scroll-area style="height: 400px; width: 100%">
                <div v-for="(n, index) in options" :key="index">
                  <q-radio
                    v-model="horario_selecionado"
                    :val="n"
                    :label="n.label"
                  />
                </div>
                <!-- <q-option-group
                  :options="options"
                  type="radio"
                  v-model="horario_selecionado"
                >
                </q-option-group> -->
              </q-scroll-area>
            </q-card-section>
            <q-card-actions style="justify-content: center">
              <q-btn rounded color="green" size="lg" @click="onAgendar"
                >Agendar</q-btn
              >
            </q-card-actions>
          </q-card>
        </div>
        <div>
          <q-field borderless stack-label>
            <template v-slot:control>
              <div
                class="margin1 self-center full-width no-outline text-bold"
                tabindex="0"
                style="font-size: 18px"
              >
                Seus Agendamentos
              </div>
            </template>
          </q-field>
          <q-field
            borderless
            stack-label
            rounded
            outlined
            color="orange-9"
            class="margin1"
            v-for="(n, index) in this.agendamentos"
            v-bind:key="index"
          >
            <template v-slot:control>
              <div
                class="margin1 self-center full-width"
                style="font-weight: 500"
                tabindex="0"
              >
                {{
                  ` ${n.dt_atendimento_movimento} as ${n.hr_inicio_horario} `
                }}
                <q-btn rounded color="red" size="sm" @click="onCancelar(n)"
                  >Cancelar</q-btn
                >
                <q-btn
                  v-if="n.ic_acessa_sala"
                  rounded
                  class="margin1"
                  color="primary"
                  size="sm"
                  @click="initCall(n)"
                  >Iniciar</q-btn
                >
              </div>
            </template>
          </q-field>
        </div>
      </div>
    </div>

    <q-dialog
      v-if="call"
      v-model="call"
      persistent
      :maximized="maximizedToggle"
      transition-show="jump-up"
      transition-hide="jump-down"
    >
      <q-card class="fundo-painel text-black">
        <q-bar class="bg-orange-9 text-white">
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
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="fundo-painel text-primary" @click="call = false"
              >Fechar</q-tooltip
            >
          </q-btn>
        </q-bar>
        <transition name="slide-fade">
          <jitsi
            :nm_titulo_atendimento="agenda_selecionado.nm_sala"
            :nm_link_atendimento="agenda_selecionado.nm_link"
          />
        </transition>
        <div class="row items-center justify-center">
          <transition name="slide-fade">
            <q-input
              class="margin1 col"
              v-model="agenda_selecionado.nm_link"
              label="Link"
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
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
//import DxScheduler, { DxResource } from "devextreme-vue/scheduler";
import Menu from "../http/menu";
//import Procedimento from "../http/procedimento";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";

var dados = [];

export default {
  components: {
    //DxScheduler,
    //DxResource,
    jitsi: () => import("../components/callJitsi.vue"),
    carregando: () => import("../components/carregando.vue"),
    RangeData: () => import("../components/RangeData.vue"),
  },
  data() {
    return {
      tituloMenu: "",
      views: ["day", "week", "workWeek", "month"],
      currentDate: new Date(),
      dataSourceConfig: [],
      cores: [],
      call: false,
      maximizedToggle: true,
      ic_filtro_pesquisa: "N",
      cd_usuario: localStorage.cd_usuario,
      cd_menu: localStorage.cd_menu,
      cd_modulo: localStorage.cd_modulo,
      cd_empresa: localStorage.cd_empresa,
      cd_api: localStorage.cd_api,
      nm_usuario: "",
      api: "772/1174", //pr_egisnet_controle_usuario
      nm_fantasia_usuario: "",
      nm_email_usuario: "",
      cd_telefone: "",
      cd_cliente: localStorage.cd_cliente,
      dataset_cliente: [],
      load_tela: false,
      horario_selecionado: [],
      agenda_selecionado: "",
      agendamentos: [],
      options: [],
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
  },
  async mounted() {
    await this.carregaDados();
    setInterval(function () {
      ////Libera acesso a Sala 5 minutos antes do Horário de início
      ////Fecha acesso a Sala 1h depois do Horário de início
      var DataHoje = new Date();
      var dia = String(DataHoje.getDate()).padStart(2, "0");
      var mes = String(DataHoje.getMonth() + 1).padStart(2, "0");
      var ano = DataHoje.getFullYear();
      let data_hoje = `${dia}/${mes}/${ano}`;
      var hora_agora = String(DataHoje.getHours()).padStart(2, "0");
      var minutos_agora = String(DataHoje.getMinutes()).padStart(2, "0");
      let horas_agora = `${hora_agora}:${minutos_agora}`;
      if (this.agendamentos) {
        this.agendamentos.map((item) => {
          ////Libera
          let uma_hora_depois = String(
            Math.abs(parseInt(item.hr_inicio_horario.substring(0, 2)) + 1)
          ).padStart(2, "0");
          let quinze_min_depois = String(
            parseInt(Math.abs(item.hr_inicio_horario.substring(3, 5)))
          ).padStart(2, "0");
          let daqui_1_hora = `${uma_hora_depois}:${quinze_min_depois}`;
          ///////////////////////////
          let uma_hora_antes = String(
            Math.abs(parseInt(item.hr_inicio_horario.substring(0, 2)) - 1)
          ).padStart(2, "0");
          let cinco_min_antes = String(
            parseInt(Math.abs(item.hr_inicio_horario.substring(3, 5) - 55))
          ).padStart(2, "0");
          let faltam_5_min = `${uma_hora_antes}:${cinco_min_antes}`;

          if (
            item.dt_atendimento_movimento.trim() === data_hoje.trim() &&
            horas_agora >= faltam_5_min &&
            horas_agora <= daqui_1_hora
          ) {
            item.ic_acessa_sala = true;
          } else {
            ////Fecha
            item.ic_acessa_sala = false;
          }
        });
      }
    }, 3000);
  },

  methods: {
    async carregaDados() {
      this.load_tela = true;
      this.cd_empresa, this.cd_menu, this.cd_api;

      //this.currentDate = new Date();

      notify("Aguarde... estamos montando a Agenda para você, aguarde !");

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api);

      dados.nm_api_parametro;

      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;
      localStorage.cd_parametro = 15;
      this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa;

      this.tituloMenu = dados.nm_menu_titulo;
      ////////// Horários Disponíveis
      try {
        let consulta_agenda = {
          cd_parametro: 15,
          cd_usuario: this.cd_usuario,
          dt_inicial: localStorage.dt_inicial,
          dt_final: localStorage.dt_final,
        };
        this.options = await Incluir.incluirRegistro(this.api, consulta_agenda);
        this.load_tela = false;
        if (this.options[0].Msg) {
          notify(this.options[0].Msg);
        } else {
          this.dataSourceConfig = this.options;
        }
      } catch (error) {
        this.load_tela = false;
        console.log(error);
      }
      /////// Agendamentos
      try {
        let consulta_agendamento = {
          cd_parametro: 13,
          cd_usuario: this.cd_usuario,
        };
        this.agendamentos = await Incluir.incluirRegistro(
          this.api,
          consulta_agendamento
        );
        ////Libera acesso a Sala 5 minutos antes do Horário de início
        ////Fecha acesso a Sala 1h depois do Horário de início
        var DataHoje = new Date();
        var dia = String(DataHoje.getDate()).padStart(2, "0");
        var mes = String(DataHoje.getMonth() + 1).padStart(2, "0");
        var ano = DataHoje.getFullYear();
        let data_hoje = `${dia}/${mes}/${ano}`;
        var hora_agora = String(DataHoje.getHours()).padStart(2, "0");
        var minutos_agora = String(DataHoje.getMinutes()).padStart(2, "0");
        let horas_agora = `${hora_agora}:${minutos_agora}`;
        this.agendamentos.map((item) => {
          ////Libera
          let uma_hora_depois = String(
            Math.abs(parseInt(item.hr_inicio_horario.substring(0, 2)) + 1)
          ).padStart(2, "0");
          let quinze_min_depois = String(
            parseInt(Math.abs(item.hr_inicio_horario.substring(3, 5)))
          ).padStart(2, "0");
          let daqui_1_hora = `${uma_hora_depois}:${quinze_min_depois}`;
          ///////////////////////////
          let uma_hora_antes = String(
            Math.abs(parseInt(item.hr_inicio_horario.substring(0, 2)) - 1)
          ).padStart(2, "0");
          let cinco_min_antes = String(
            parseInt(Math.abs(item.hr_inicio_horario.substring(3, 5) - 55))
          ).padStart(2, "0");
          let faltam_5_min = `${uma_hora_antes}:${cinco_min_antes}`;

          if (
            item.dt_atendimento_movimento.trim() === data_hoje.trim() &&
            horas_agora >= faltam_5_min &&
            horas_agora <= daqui_1_hora
          ) {
            item.ic_acessa_sala = true;
          } else {
            ////Fecha
            item.ic_acessa_sala = false;
          }
        });
        this.load_tela = false;
        if (this.agendamentos[0].Msg) {
          notify(this.agendamentos[0].Msg);
        }
      } catch (error) {
        this.load_tela = false;
        console.log(error);
      }
    },
    trocouData() {
      this.carregaDados();
    },
    async Copy() {
      if (this.agenda_selecionado.nm_link) {
        const text = this.agenda_selecionado.nm_link;
        await navigator.clipboard.writeText(text);
        notify("Texto copiado");
      } else {
        notify("Texto não encontrado!");
      }
    },
    async onAgendar() {
      if (
        this.horario_selecionado.cd_horario_composicao !== undefined &&
        this.horario_selecionado.cd_atendimento_movimento !== undefined
      ) {
        let agendar = {
          cd_parametro: 14,
          cd_usuario: this.cd_usuario,
          cd_cliente: this.cd_cliente,
          cd_horario_composicao: this.horario_selecionado.cd_horario_composicao,
          cd_atendimento_movimento:
            this.horario_selecionado.cd_atendimento_movimento,
        };
        let [result_agendar] = await Incluir.incluirRegistro(this.api, agendar);
        notify(result_agendar.Msg);
        this.horario_selecionado = [];
        this.carregaDados();
      } else {
        notify("Selecione um horário para agendar!");
      }
    },
    async onCancelar(item) {
      let cancelar = {
        cd_parametro: 16,
        cd_usuario: this.cd_usuario,
        cd_atendimento_movimento: item.cd_atendimento_movimento,
      };
      let result_cancelar = await Incluir.incluirRegistro(this.api, cancelar);
      notify(result_cancelar[0].Msg);
      this.carregaDados();
    },
    async initCall(item) {
      this.agenda_selecionado = item;
      let inicia_atendimento = {
        cd_atendimento_movimento: item.cd_atendimento_movimento,
        cd_parametro: 8,
        cd_usuario: this.cd_usuario,
      };
      let result_api = await Incluir.incluirRegistro(
        this.api,
        inicia_atendimento
      );
      notify(result_api[0].msg);
      this.call = true;
    },
  },
};
</script>

<style scoped>
.dx-scheduler-date-table-other-month.dx-scheduler-date-table-cell {
  opacity: 1;
  color: rgba(0, 0, 0, 0.3);
}
.card-opcoes {
  width: 92%;
  border: 0.5px solid rgba(19, 4, 4, 0.247);
}
.card-column {
  display: flex;
  justify-content: space-around;
}
</style>
