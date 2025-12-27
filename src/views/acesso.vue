<template>
  <div>
    <h2 class="content-block">{{ tituloMenu }}</h2>
    <div class="content-block">
      <div class="dx-card responsive-paddings">
        <div class="form-empresa" />
        <div class="acesso">
          <p>Acesso Automático...</p>
          <br />
          Versão 2021
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";

import acessoUsuario from "../http/acessoUsuario";

var dlogin = {};
var ivalidado = 0;
var userLogin = "";
var userPassword = "";

export default {
  data() {
    return {
      tituloMenu: "EGIS",
      cd_empresa: 0,
      cd_menu: 0,
      cd_usuario: 0,
      login: "",
      password: "",
      rememberUser: false,
      usuario: "",
      temD: false,
    };
  },
  created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    this.cd_empresa = this.$route.params.cd_empresa;
    this.cd_menu = this.$route.params.cd_menu;
    this.cd_usuario = this.$route.params.cd_usuario;

    //Limpeza do LocalStorage
    localStorage.clear();
    //
    //clearInterval(localStorage.polling);
    //

    this.logar();
  },

  methods: {
    async logar() {
      ivalidado = 0;
      localStorage.usuario = "";
      localStorage.cd_empresa = 0;
      localStorage.cd_tipo_destinatario = 0;
      localStorage.cd_destinatario = 0;
      localStorage.nm_destinatario = "";
      localStorage.empresa = "";
      localStorage.fantasia = "";
      localStorage.email = "";
      localStorage.cd_modulo = 0;
      localStorage.cd_menu = 0;
      localStorage.cd_usuario = 0;
      localStorage.cd_cliente = 0;
      localStorage.cd_fornecedor = 0;
      localStorage.cd_api = 0;
      localStorage.cd_tipo_consulta = 0;
      localStorage.dt_base = new Date().toLocaleDateString();
      localStorage.cd_identificacao = 0;
      localStorage.nm_documento = "";
      localStorage.cd_modulo_selecao = 0;
      localStorage.nm_modulo = "";
      localStorage.password = "";
      localStorage.nm_pesquisa = "";
      localStorage.polling = 0;

      dlogin = await acessoUsuario.validar(
        this.cd_empresa,
        this.cd_usuario,
        this.cd_menu
      );
    },
  },
};
</script>

<style lang="scss">
.logos-container {
  margin: 20px 0 30px 0;
  text-align: center;
}

.form-empresa {
  height: 70px;
  width: 200px;
  margin-top: -20px;
  margin-left: 0px;
  background-image: url("http://www.egisnet.com.br/img/logo_gbstec_sistema.png");
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;

  .acesso {
    margin-left: 10px;
    padding-left: 10px;
  }
}
</style>
