<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <!-- ------------------------------------TOPO--------------------------- -->
    <div class="margin1">
      <q-toolbar class="bg-orange-9 shadow-1" style="border-radius:20px">
        <q-toolbar-title
          class="bg-orange-9"
          style="text-align:center;border-radius: 20px;color:white;"
        >
          Gerenciamento de Usuario
        </q-toolbar-title>
      </q-toolbar>
    </div>
    <!-- -------------------------------------------------------------------------   -->
    <div class="margin1">
      <grid_usuario
        :cd_menuID="7496"
        :cd_apiID="772"
        :cd_parametroID="0"
        :cd_consulta="1"
        :nm_json="{ cd_parametro: 0, cd_usuario: this.cd_usuario }"
        @Linha="PegaLinha($event)"
        ref="grid_usuario"
      />
    </div>
    <!-- -----------------------------------BTN----------------------------------- -->
    <div class="row margin1">
      <q-btn
        rounded
        color="orange-9 margin1"
        :label="alteracao == true ? 'Alteração' : 'Inserir'"
        @click="popupEmail = true"
        icon="add"
      />
      <q-btn
        rounded
        v-show="!!linha.cd_usuario"
        color="orange-9 margin1"
        label="Alterar"
        icon="refresh"
        @click="AlterUser()"
      />
      <q-space />
      <q-btn
        flat
        color="orange-9"
        label="E-mail com Login"
        icon="login"
        rounded
        @click="EmailLogin"
      />
    </div>
    <q-dialog full-width v-model="popupEmail">
      <q-expansion-item
        v-model="expansor"
        class="overflow-hidden "
        style="border-radius: 20px; height:auto;margin:0"
        icon="person"
        label="Inserir"
        default-opened
        header-class="bg-orange-9 text-white items-center text-h6"
        expand-icon-class="text-white "
      >
        <q-card>
          <div class="row item-center justify-around">
            <q-input
              class="margin1 tresTela"
              label="Código"
              color="orange-9"
              v-show="alteracao == true"
              v-model="cd_usuario"
              readonly
            >
              <template v-slot:prepend>
                <q-icon name="pin" />
              </template>
            </q-input>

            <q-input
              class="margin1 tresTela"
              label="Último Acesso"
              color="orange-9"
              v-show="alteracao == true"
              v-model="dt_ultimo_acesso"
              readonly
            >
              <template v-slot:prepend>
                <q-icon name="sync" />
              </template>
            </q-input>

            <q-input
              class="margin1 tresTela"
              label="Data de Cadastro"
              color="orange-9"
              v-show="alteracao == true"
              v-model="dt_cadastro_usuario"
              readonly
            >
              <template v-slot:prepend>
                <q-icon name="assignment" />
              </template>
            </q-input>
          </div>
          <div class="row ">
            <q-input
              class="margin1"
              style="width:100%"
              v-model="nm_usuario"
              label="Nome"
              color="orange-9"
            >
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
            </q-input>
          </div>
          <div class="row ">
            <q-select
              label="Cliente"
              class="margin1 meiaTela"
              v-model="cliente"
              input-debounce="0"
              color="orange-9"
              :options="this.lokup_cliente"
              option-value="cd_cliente"
              option-label="nm_fantasia_cliente"
            >
              <template v-slot:prepend>
                <q-icon name="face" />
              </template>
            </q-select>
            <q-input
              class="margin1 meiaTela"
              v-model="nm_fantasia_usuario"
              label="Login"
              color="orange-9"
            >
              <template v-slot:prepend>
                <q-icon name="login" />
              </template>
            </q-input>
          </div>
          <div class="row "></div>
          <div class="row ">
            <q-input
              class="margin1 meiaTela"
              v-model="nm_email_usuario"
              label="E-mail"
              color="orange-9"
            >
              <template v-slot:prepend>
                <q-icon name="mail" />
              </template>
            </q-input>
            <q-input
              class="margin1 meiaTela"
              label="Telefone"
              v-model="cd_telefone"
              color="orange-9"
              mask="(##) ####-####"
            >
              <template v-slot:prepend>
                <q-icon name="call" />
              </template>
            </q-input>
          </div>
          <div class="row ">
            <q-toggle
              v-model="ic_ativo"
              class="tresTela"
              label="Ativo"
              color="orange-9"
            />
          </div>
          <br />
          <div class="row">
            <q-btn
              rounded
              color="orange-9 margin1 "
              label="confirmar"
              icon="add"
              @click="saveUser()"
            />

            <q-space />
            <q-btn
              flat
              color="orange-9 margin1"
              label="Fechar"
              icon="close"
              rounded
              v-close-popup
            />
          </div>
        </q-card>
      </q-expansion-item>
    </q-dialog>
    <!------------------------------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando colorID="orange-9" />
    </q-dialog>
  </div>
</template>

<script>
1;
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import ptMessages from "devextreme/localization/messages/pt.json";
import Lookup from "../http/lookup";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import formataData from "../http/formataData";
import carregando from "../components/carregando.vue";
import funcao from "../http/funcoes-padroes";
export default {
  name: "GereciamentoUsuario",
  data() {
    return {
      cd_usuario: localStorage.cd_usuario,
      cd_menu: localStorage.cd_menu,
      cd_modulo: localStorage.cd_modulo,
      cd_empresa: localStorage.cd_empresa,
      cd_api: localStorage.cd_api,
      nm_menu_titulo: "",
      popupEmail: false,
      expansor: true,
      alteracao: false,
      load: false,
      dt_ultimo_acesso: "",
      nm_usuario: "",
      api: "772/1174",
      nm_fantasia_usuario: "",
      nm_email_usuario: "",
      cd_telefone: "",
      cliente: "",
      ic_ativo: true,
      nm_cliente: "",
      lokup_cliente: [],
      dt_cadastro_usuario: "",
      linha: {},
    };
  },
  async created() {
    let d = await Lookup.montarSelect(this.cd_empresa, 93);
    this.lokup_cliente = JSON.parse(JSON.parse(JSON.stringify(d.dataset)));

    // var dados = await Menu.montarMenu(
    //   this.cd_empresa,
    //   this.cd_menu,
    //   this.cd_api
    // );
    // this.api = dados.nm_identificacao_api;
    // this.nm_menu_titulo = dados.nm_menu_titulo;
  },
  components: {
    carregando,
    grid_usuario: () => import("../views/grid.vue"),
  },
  watch: {
    async expansor() {
      if (this.expansor == false) {
        this.expansor = true;
      }
    },
    async popupEmail() {
      if (this.popupEmail == false) {
        this.alteracao = false;
        await this.Clear();
        this.$refs.grid_usuario.carregaDados();
      }
    },
  },
  methods: {
    async EmailLogin() {
      let JSONEmailcLogin = {
        cd_parametro: 5,
        nm_email_usuario: this.linha.nm_email_usuario,
      };
      let exc = await Incluir.incluirRegistro("772/1174", JSONEmailcLogin);
      notify(exc[0].msg);
    },

    async AlterUser() {
      this.alteracao = true;
      this.cd_usuario = this.linha.cd_usuario;
      this.dt_ultimo_acesso = this.linha.dt_ultimo_acesso;
      this.nm_usuario = this.linha.nm_usuario;
      this.cliente = {
        cd_cliente: this.linha.cd_cliente,
        nm_fantasia_cliente: this.linha.nm_fantasia_cliente,
      };
      this.dt_cadastro_usuario = this.linha.dt_cadastro_usuario;
      this.nm_fantasia_usuario = this.linha.nm_fantasia_usuario.trim();
      this.cd_telefone = await funcao.FormataTelefone(this.linha.cd_telefone);
      this.nm_email_usuario = this.linha.nm_email_usuario;
      if (this.linha.ic_ativo == "A") {
        this.ic_ativo = true;
      } else {
        this.ic_ativo = false;
      }
      this.popupEmail = true;
    },
    async PegaLinha(linha) {
      if (linha.cd_usuario == false) return;
      this.linha = linha;
    },

    async Clear() {
      this.cd_usuario = "";
      this.dt_ultimo_acesso = "";
      this.nm_usuario = "";
      this.nm_fantasia_usuario = "";
      this.nm_email_usuario = "";
      this.cd_telefone = "";
      this.cliente = "";
      this.ic_ativo = true;
      this.nm_cliente = "";
      this.linha = {};
    },
    async saveUser() {
      let ativo = "N";
      if (this.ic_ativo == true) {
        ativo = "A";
      } else {
        ativo = "I";
      }
      let c = {
        //cd_parametro: 1,
        nm_usuario: this.nm_usuario.trim(),
        cd_cliente: this.cliente.cd_cliente,
        ic_ativo: ativo,
        cd_usuario_aprovado: this.cd_usuario,
        nm_fantasia_usuario: this.nm_fantasia_usuario.trim(),
        nm_email_usuario: this.nm_email_usuario.trim(),
        cd_telefone: this.cd_telefone,
      };
      if (this.alteracao == true) {
        c.cd_parametro = 4;
      } else {
        c.cd_parametro = 3;
      }

      this.load = true;
      let exc = await Incluir.incluirRegistro(this.api, c);
      this.load = false;
      notify(exc[0].Msg);
      if (exc[0].Cod != 0) {
        this.popupEmail = false;
      }
    },
    onHiding() {
      this.popupEmail = false; // Handler of the 'hiding' event
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: none;
}
.meiaTela {
  width: 48%;
}
.tresTela {
  width: 31.5%;
}
@media (max-width: 920px) {
  .meiaTela {
    width: 100% !important;
  }
}
</style>
