<template>
  <div>
    <transition name="slide-fade">
      <div v-if="empresa" class="row items-center">
        <q-btn
          color="primary"
          icon="arrow_back"
          class="margin1"
          text-color="black"
          round
          @click="onClickDeclinar($event)"
        >
          <q-tooltip>
            Ir para Home
          </q-tooltip>
        </q-btn>

        <div class="margin1 umQuartoTela title-modulo">
          {{ `EGIS - ${empresa}` }}
        </div>
        <img class="margin1" v-if="!caminho == ''" :src="pegaImg()" alt="" />
        <div class="margin1 umQuartoTela title-modulo">{{ tituloMenu }}</div>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="dataSourceConfig" class="row">
        <div
          class="my-card"
          v-for="(e, index) in dataSourceConfig"
          :key="index"
        >
          <q-card
            :class="
              `margin1 on-card bg-${e.card_color} text-black borda-bloco shadow-2`
            "
            @mouseenter="e.card_color = 'blue-6'"
            @mouseleave="e.card_color = 'white'"
          >
            <q-card-section @click="onClickAprovar(e)" class="align-esquerda">
              <q-icon
                v-if="e.nm_logo_web_modulo"
                :name="`${e.nm_logo_web_modulo}`"
                size="sm"
              />
              <div class="text-h6">{{ `${e.nm_fantasia_modulo}` }}</div>
            </q-card-section>

            <q-card-section
              @click="onClickAprovar(e)"
              class="align-data"
              style="font-weight: 500;"
            >
              {{ `${e.nm_modulo}` }}
            </q-card-section>

            <q-separator class="margin1" color="black" />

            <q-card-actions class="align-around">
              <q-btn
                rounded
                @click="onClickInfo(e)"
                icon="info"
                color="blue-6"
                text-color="black"
              >
                <q-tooltip>
                  Informações
                </q-tooltip></q-btn
              >
              <q-btn
                rounded
                @click="onClickAprovar(e)"
                icon="arrow_forward"
                color="blue-6"
                text-color="black"
              >
                <q-tooltip>
                  Entrar
                </q-tooltip></q-btn
              >
            </q-card-actions>
          </q-card>
        </div>
      </div>
    </transition>
    <q-dialog
      v-model="pop_info"
      transition-show="scale"
      transition-hide="scale"
    >
      <q-card>
        <q-card-section>
          <div class="text-h6">{{ `${info_data.nm_modulo}` }}</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          {{ `${info_data.ds_modulo}` }}
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            rounded
            text-color="black"
            label="OK"
            color="blue-6"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import validaUsuario from "../http/validaUsuario";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import notify from "devextreme/ui/notify";

var cd_cliente = 0;
var api = "";
var dados = [];

export default {
  data() {
    return {
      caminho: "",
      tituloMenu: "",
      dataSourceConfig: [],
      empresa: localStorage.fantasia,
      cd_empresa: localStorage.cd_empresa,
      cd_modulo: localStorage.cd_modulo,
      cd_api: localStorage.cd_api,
      cd_menu: localStorage.cd_menu,
      cd_usuario: localStorage.cd_usuario,
      cd_cliente: localStorage.cd_cliente,
      pop_info: false,
      info_data: {},
      card_color: "white",
    };
  },

  created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
  },

  async mounted() {
    this.pegaImg();
    await this.carregaDados();
  },

  methods: {
    pegaImg() {
      this.caminho = localStorage.nm_caminho_logo_empresa;
      var imagem = "https://www.egisnet.com.br/img/" + this.caminho;
      return imagem;
    },
    async carregaDados() {
      try {
        cd_cliente = localStorage.cd_cliente;
        api = "Empresa/Modulo"; //localStorage.nm_identificacao_api;
        dados = await Menu.montarMenu(
          this.cd_empresa,
          6543, //this.cd_menu,
          52, //this.cd_api,
        ); //'titulo';
        let sParametroApi = dados.nm_api_parametro;
        localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

        this.tituloMenu = dados.nm_menu_titulo;

        this.dataSourceConfig = await Procedimento.montarProcedimento(
          this.cd_empresa,
          cd_cliente,
          api,
          sParametroApi,
        );
      } catch (error) {
        console.error(error);
      }
    },

    async onClickAprovar(e) {
      notify("Aguarde... vamos acessar o módulo para você !");

      localStorage.cd_modulo = e.cd_modulo;
      localStorage.nm_modulo = e.nm_modulo;

      localStorage.cd_modulo_selecao = 0;
      localStorage.cd_menu = 0;

      //Atualização do Módulo
      localStorage.cd_cliente = 0;
      localStorage.cd_parametro = 0;

      api = "";
      dados = await Menu.montarMenu(this.cd_empresa, 0, 99); //'titulo'; Procedimento 938 -- pr_atualiza_modulo_acesso_usuario_empresa
      api = dados.nm_identificacao_api;

      let sParametroApi = dados.nm_api_parametro;

      dados = await Procedimento.montarProcedimento(
        this.cd_empresa,
        cd_cliente,
        api,
        sParametroApi,
      );
      var dados_u;
      dados_u = await validaUsuario.validar(
        localStorage.login,
        localStorage.password,
      );

      localStorage.cd_home = dados_u.cd_api;

      this.$router.push({ name: "home" });
    },

    onClickDeclinar(e) {
      notify(`Aguarde...`);
      this.$router.push({ name: "home" });
    },

    onClickInfo(e) {
      this.info_data = e;
      this.pop_info = true;
    },
  },
};
</script>
<style scoped>
@import url("./views.css");

.my-card {
  display: flex;
  width: 25%;
}

.on-card {
  width: 100%;
  border-radius: 20px;
}

.align-data {
  display: flex;
  justify-content: center;
  cursor: pointer;
}

.align-esquerda {
  display: flex;
  justify-content: left;
  cursor: pointer;
}

.align-direita {
  display: flex;
  justify-content: right;
}

.align-around {
  display: flex;
  justify-content: space-around;
}

.title-modulo {
  font-weight: 600;
  font-size: x-large;
}

.img {
  width: 20%;
  height: 22%;
}
</style>
