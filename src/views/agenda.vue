<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />

    <div
      class="row items-center margin1 text-h6 text-bold "
      v-show="!!menu.nm_menu_titulo"
    >
      {{ menu.nm_menu_titulo }}
      <q-space />
      <q-btn
        round
        :color="colorID"
        icon="refresh"
        @click="carregaDados()"
        size="sm"
      />
    </div>
    <div class="margin1">
      <DxScheduler
        time-zone="America/Sao_Paulo"
        :data-source="dataSourceConfig"
        :current-date="new Date()"
        :views="views"
        :show-all-day-panel="true"
        :ref="agendaComponete"
        :height="600"
        current-view="month"
        :cell-duration="30"
        :editing="editing"
        appointment-tooltip-template="tooltip"
        :groups="groups"
        :form-data="false"
      >
        <DxResource
          :data-source="dataSourceConfig"
          :use-color-as-default="true"
          :allow-multiple="true"
          field-expr="dataSourceConfig"
        />

        <template #tooltip="{ data }">
          <tooltip :template-tooltip-model="data" @click="fechaPopup(data)" />
        </template>
      </DxScheduler>
    </div>
    <q-dialog v-model="PopupDate">
      <q-expansion-item
        class="overflow-hidden bg-white"
        v-show="!!DateClick.text"
        style="border-radius: 20px; height:auto;margin:0;width: 700px; max-width: 80vw"
        icon="event"
        :label="DateClick.text"
        v-model="Expansor"
        default-opened
        :header-class="
          'bg-' + this.colorID + ' text-white items-center text-h6'
        "
        expand-icon-class="text-white "
      >
        <q-card style="width: 700px; max-width: 80vw; margin:0; padding:0">
          <div class="row ">
            <q-space />
            <q-btn
              icon="close"
              class="margin1"
              flat
              round
              dense
              v-close-popup
            />
          </div>
          <q-input
            readonly
            class="row margin1"
            v-show="DateClick.nm_fantasia_cliente"
            v-model="DateClick.nm_fantasia_cliente"
            type="text"
            label="Cliente"
          >
            <template v-slot:prepend>
              <q-icon name="face" />
            </template>
          </q-input>
          <q-input
            readonly
            class="row margin1"
            v-show="DateClick.nm_fantasia_usuario"
            v-model="DateClick.nm_fantasia_usuario"
            type="text"
            label="Contato"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-input>
          <q-input
            readonly
            class="row margin1"
            v-show="DateClick.nm_email_cliente"
            v-model="DateClick.nm_email_cliente"
            type="text"
            label="E-mail do Cliente"
          >
            <template v-slot:prepend>
              <q-icon name="mail" />
            </template>
          </q-input>

          <q-input
            readonly
            class="row margin1"
            v-show="DateClick.dt_inicial"
            v-model="DateClick.dt_inicial"
            type="text"
            label="Data do Agendamento"
          >
            <template v-slot:prepend>
              <q-icon name="today" />
            </template>
          </q-input>
        </q-card>
      </q-expansion-item>
    </q-dialog>
    <!------------------------------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando :colorID="colorID" />
    </q-dialog>
  </div>
</template>

<script>
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import DxScheduler, { DxResource } from "devextreme-vue/scheduler";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";

export default {
  components: {
    DxScheduler,
    DxResource,
    tooltip: () => import("../components/tooltipTemplate.vue"),
    carregando: () => import("../components/carregando.vue"),
  },
  props: {
    cd_menuID: { type: Number, default: 0 },
    cd_apiID: { type: Number, default: 0 },
    colorID: { type: String, default: "orange-9" },
    editID: { type: Boolean, default: true },
    insertID: { type: Boolean, default: true },
  },

  data() {
    return {
      views: ["day", "week", "workWeek", "month"],
      groups: ["theatreId"],
      dataSourceConfig: [],
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_modulo: localStorage.cd_modulo,
      cd_menu: localStorage.cd_menu,
      cd_api: localStorage.cd_api,
      menu: {},
      load: false,
      agendaComponete: "agendaComponete",
      api: "",
      Expansor: true,
      editing: {
        allowAdding: false,
        allowDeleting: true,
        allowUpdating: false,
        allowTimeZoneEditing: false,
      },
      PopupDate: false,
      DateClick: {},
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    await this.MontaMenu();
    await this.carregaDados();
  },
  async mounted() {},
  watch: {
    async Expansor() {
      this.Expansor == false ? (this.Expansor = true) : (this.Expansor = true);
    },
  },

  methods: {
    showToast(event, value, type) {
      notify(`${event} "${value}" task`, type, 800);
    },

    async fechaPopup(e) {
      this.PopupDate = false;
      if (!!e.appointmentData.cd_atendimento_movimento == false) {
        this.load = false;
        notify("Atendimento não encontrado!");

        return;
      }

      try {
        const ex = {
          cd_parametro: 1,
          cd_atendimento_movimento: e.appointmentData.cd_atendimento_movimento,
        };

        const exclusao = await Incluir.incluirRegistro(this.api, ex);
        notify(exclusao[0].Msg);

        this.$refs["agendaComponete"].instance.hideAppointmentPopup(false);
        this.dataSourceConfig = this.dataSourceConfig.filter((el) => {
          return (
            el.cd_atendimento_movimento !=
            e.appointmentData.cd_atendimento_movimento
          );
        });
        this.load = false;
      } catch (error) {
        this.load = false;
      }
    },
    async CloseCell() {
      this.load = true;
      this.$refs["agendaComponete"].instance.hideAppointmentPopup(false);
      this.load = false;
      return;
    },
    async MontaMenu() {
      if (!!this.cd_menuID && !!this.cd_apiID) {
        this.menu = await Menu.montarMenu(
          this.cd_empresa,
          this.cd_menuID,
          this.cd_apiID
        );
      } else {
        this.menu = await Menu.montarMenu(
          this.cd_empresa,
          this.cd_menu,
          this.cd_api
        );
      }
      this.api = this.menu.nm_identificacao_api;
    },
    async carregaDados() {
      this.load = true;
      try {
        //----------Usar convert(varchar, campo, 20) as startDate e endDate-----------------------------------
        this.dataSourceConfig = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_cliente,
              this.api,
              this.menu.nm_api_parametro,
            );
        //this.dataSourceConfig = await Incluir.incluirRegistro(this.api, {
        //  cd_parametro: 0,
        //}); 
        //----------Usar convert(varchar, campo, 20) as startDate e endDate-----------------------------------
        //text -> titulo
        //description -> descrição
        this.load = false;
      } catch (error) {
        this.load = false;
      }
    },
  },
};
</script>

<style scoped>
.dx-scheduler-date-table-other-month.dx-scheduler-date-table-cell {
  opacity: 1;
  color: rgba(0, 0, 0, 0.3);
}
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}
</style>
