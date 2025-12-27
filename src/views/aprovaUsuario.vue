<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <transition name="slide-fade">
      <div class="row" v-if="cd_usuario_aprovado > 0">
        <div class=" col text-h6 text-bold row text-center items-center">
          {{ tituloMenu }}
        </div>
        <q-space />

        <q-btn
          class="margin1"
          rounded
          color="positive"
          label="Aprovar"
          @click="popupAprova = true"
        />
        <q-btn
          class="margin1 "
          rounded
          @click="popupDecline = true"
          outline
          color="negative"
          label="Declinar"
        />
      </div>

      <div v-else>
        <div class="text-h6 text-bold margin1 ">
          Usuário não encontrado!
        </div>
      </div>
    </transition>
    <!---------------------------------------------------------->
    <q-dialog v-model="popupDecline" persistent>
      <q-card style="width: 350px">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Reprovar acesso</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <div class="row">
          <q-input
            class="margin1 col"
            autogrow
            v-model="nm_motivo_recusado"
            label="Motivo"
          >
            <template v-slot:prepend>
              <q-icon name="description" />
            </template>
          </q-input>
        </div>

        <div class="row">
          <q-btn
            rounded
            flat
            color="negative"
            label="Envio e-mail de Reprovação"
            icon="check"
            class="margin1 col"
            v-close-popup
            @click="DeclineUser"
          />
        </div>
      </q-card>
    </q-dialog>
    <!---------------------------------------------------------->
    <q-dialog v-model="popupAprova" persistent>
      <q-card style="width: 350px">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Selecione o cliente</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <div class="q-pt-none">
          <q-select
            label="Cliente"
            class="margin1 col "
            v-model="cliente"
            color="primary"
            :options="this.dataset_cliente"
            option-value="cd_cliente"
            option-label="nm_fantasia_cliente"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-select>
        </div>

        <div class="row">
          <q-btn
            rounded
            flat
            color="primary"
            label="Envio e-mail de Aprovação"
            icon="check"
            class="margin1 col"
            v-close-popup
            @click="AcceptUser"
          />
        </div>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import notify from "devextreme/ui/notify";
import Incluir from "../http/incluir_registro";
import Lookup from "../http/lookup";

export default {
  name: "aprovaUsuario",

  props: {
    propObject: { type: Object, default: () => {} },
  },
  data() {
    return {
      cd_usuario: localStorage.cd_usuario,
      cd_empresa: localStorage.cd_empresa,
      cd_modulo: localStorage.cd_modulo,
      tituloMenu: "Autorização de Acesso",
      cd_usuario_aprovado: 0,
      cliente: "",
      api: "762/1161",
      popupDecline: false,
      popupAprova: false,
      nm_motivo_recusado: "",
      dataset_cliente: [],
    };
  },
  async created() {
    this.cd_usuario_aprovado = this.propObject.cd_documento;
    let dados_cliente = await Lookup.montarSelect(this.cd_empresa, 93);
    this.dataset_cliente = JSON.parse(
      JSON.parse(JSON.stringify(dados_cliente.dataset))
    );
  },
  mounted() {},
  watch: {},
  methods: {
    async AcceptUser() {
      if (!!this.cliente.cd_cliente == false) {
        notify("Selecione o cliente!");

        return;
      }
      try {
        let c = {
          cd_parametro: 1,
          cd_usuario: this.cd_usuario,
          cd_usuario_aprovado: this.cd_usuario_aprovado,
          cd_cliente: this.cliente.cd_cliente,
        };

        let acept = await Incluir.incluirRegistro(this.api, c);
        notify(acept[0].Msg);
        if (acept[0].Msg) {
          this.$emit("click");
        }
      } catch (error) {}
    },
    async DeclineUser() {
      if (!!this.nm_motivo_recusado == false) {
        notify("Informe o motivo!");
        return;
      }
      try {
        const c = {
          cd_parametro: 2,
          cd_usuario: this.cd_usuario,
          cd_usuario_aprovado: this.cd_usuario_aprovado,
          nm_motivo_recusado: this.nm_motivo_recusado,
        };
        const acept = await Incluir.incluirRegistro(this.api, c);
        notify(acept[0].Msg);
        if (acept[0].Msg) {
          this.$emit("click");
        }
      } catch (error) {}
    },
  },
};
</script>

<style scoped>
.margin1 {
  padding: 0;
  margin: 0.5vh 0.5vw;
}
/* Enter and leave animations can use different */
/* durations and timing functions.              */
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
</style>
