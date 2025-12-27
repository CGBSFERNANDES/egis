<template>
  <div>
    <q-expansion-item
      class="overflow-hidden shadow-1"
      style="border-radius: 20px; height:auto;margin:0"
      :icon="icon"
      :label="tituloComponent + ' - Contrato: ' + cd_movimento"
      default-opened
      header-class="bg-orange-9 text-white items-center text-h6"
      expand-icon-class="text-white "
    >
      <div class="margin1" v-show="cd_movimento > 0">
        <div class="row items-center">
          <q-select
            class="margin1 col"
            option-value="cd_usuario"
            option-label="nm_fantasia_usuario"
            :options="lookup_usuario"
            :loading="load"
            v-model="usuario"
            color="orange-9"
            label="Usuário Administrador"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-select>
          <q-space />
          <q-checkbox
            class="text-subtitle2 margin1 col"
            left-label
            v-model="liberacao"
            color="orange-9"
            label="Liberar para vendedor?"
            checked-icon="task_alt"
            unchecked-icon="highlight_off"
          />
        </div>

        <div class="row">
          <q-space />
          <transition name="slide-fade">
            <q-btn
              class="margin1"
              color="orange-9"
              rounded
              v-close-popup
              icon-right="check"
              label="Gravar"
              v-if="load == false"
              @click="SendAdm"
            />
          </transition>
        </div>
      </div>
    </q-expansion-item>
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
import Incluir from "../http/incluir_registro";

export default {
  name: "infoAdm",
  props: {
    cd_movimento: { type: Number, default: 0 },
  },
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_modulo: localStorage.cd_modulo,
      tituloComponent: "Gestão do Administrativo",
      icon: "receipt_long",
      lookup_usuario: [],
      usuario: "",
      load_tela: false,
      load: true,
      liberacao: false,
    };
  },
  async created() {
    let pesquisa = [];
    let c = {
      cd_parametro: 13,
      cd_empresa: this.cd_empresa,
      cd_usuario: this.cd_usuario,
      cd_movimento: this.cd_movimento,
    };
    try {
      pesquisa = await Incluir.incluirRegistro("706/1073", c);
    } catch (error) {
      this.load = false;
    }
    if (pesquisa[0].Cod > 0) {
      this.lookup_usuario = pesquisa;
      if (this.lookup_usuario.length == 1) {
        this.usuario = {
          cd_usuario: this.lookup_usuario[0].cd_usuario,
          nm_fantasia_usuario: this.lookup_usuario[0].nm_fantasia_usuario,
        };
      }
      this.load = false;
    }
    this.load = false;
    await this.CarregaDados();
  },
  components: {
    carregando: () => import("../components/carregando.vue"),
  },
  methods: {
    async CarregaDados() {
      let pesquisa = [];
      let c = {
        cd_parametro: 15,
        cd_contrato: this.cd_movimento,
      };
      try {
        pesquisa = await Incluir.incluirRegistro("706/1073", c);
        this.usuario = {
          cd_usuario: pesquisa[0].cd_usuario_administrativo,
          nm_fantasia_usuario: pesquisa[0].nm_fantasia_usuario,
        };
        if (!!pesquisa[0].dt_liberacao_administrativo == true) {
          this.liberacao = true;
        } else {
          this.liberacao = false;
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error)
      }
    },
    async SendAdm() {
      if (!!this.usuario.cd_usuario == false) {
        notify("Selecione o Usuário Administrador!");
        return;
      }
      this.load_tela = true;

      let envio = [];
      let liberacao = "N";
      this.liberacao == true ? (liberacao = "S") : (liberacao = "N");
      let e = {
        cd_parametro: 14,
        cd_usuario_adm: this.usuario.cd_usuario,
        cd_contrato: this.cd_movimento,
        ic_liberacao_administrativo: liberacao,
      };
      try {
        envio = await Incluir.incluirRegistro("706/1073", e);
        notify(envio[0].Msg);
      } catch (error) {
        this.load_tela = false;
      }
      this.load_tela = false;
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
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
</style>
