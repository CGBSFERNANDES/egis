<template>
  <transition name="slide-fade">
    <div
      class="indicador borda-bloco shadow-2 margin1"
      v-if="dataSourceConfig.length > 0"
    >
      <div
        class="margin1"
        v-for="(i, index) in Object.keys(dataSourceConfig[0])"
        :key="index"
      >
        {{ `${i} ${Object.values(dataSourceConfig[0])[index]}` }}
      </div>
    </div>
  </transition>
</template>

<script>
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import formatadata from "../http/formataData.js";

export default {
  data() {
    return {
      painelModulo: "",
      dataSourceConfig: [],
      cd_empresa: localStorage.cd_empresa,
      cd_cliente: localStorage.cd_cliente,
      cd_parametro: 0,
      cd_menu: localStorage.cd_menu,
      cd_api: localStorage.cd_api,
      api: localStorage.nm_identificacao_api,
      cd_modulo: localStorage.cd_modulo,
      sParametroApi: "",
    };
  },
  async created() {
    await this.carregaDados();
  },
  methods: {
    async carregaDados() {
      //await this.showMenu();
      localStorage.cd_fornecedor = 0;
      this.sParametroApi =
        "/cd_modulo/cd_cliente/cd_fornecedor/cd_parametro/cd_usuario/dt_inicial/dt_final";
      this.api = "844/1321";
      if (!this.sParametroApi == "") {
        this.dataSourceConfig = [];

        this.dataSourceConfig = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          this.api,
          this.sParametroApi
        );
      }
      this.dataSourceConfig.map((e) => {
        if (!!e.Hoje) {
          e.Hoje = formatadata.formataDataJS(e.Hoje);
        }
        if (!!e["Data Inicial"]) {
          e["Data Inicial"] = formatadata.formataDataJS(e["Data Inicial"]);
        }
        if (!!e["Data Final"]) {
          e["Data Final"] = formatadata.formataDataJS(e["Data Final"]);
        }
      });
    },
    async showMenu() {
      this.cd_empresa = this.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_parametro = 1;
      this.cd_menu = 7221; //localStorage.cd_menu;
      this.cd_api = 581; //localStorage.cd_api;
      this.api = "581/801"; //localStorage.nm_identificacao_api;
      this.cd_modulo = localStorage.cd_modulo;

      this.dados = await Menu.montarMenu(
        this.cd_empresa,
        this.cd_menu,
        this.cd_api
      ); //'titulo';

      this.sParametroApi = this.dados.nm_api_parametro;
      //

      if (
        !this.dados.nm_identificacao_api == "" &&
        !this.dados.nm_identificacao_api == this.api
      ) {
        this.api = this.dados.nm_identificacao_api;
      }

      localStorage.cd_tipo_consulta = 0;

      if (!this.dados.cd_tipo_consulta == 0) {
        this.dados.cd_tipo_consulta;
      }

      if (this.dados.nm_menu_titulo != undefined) {
        this.tituloMenu = this.dados.nm_menu_titulo;
      }
    },
  },
};
</script>

<style scoped>
@import url("./views.css");

.indicador {
  display: flex;
  font-weight: bold;
  flex-wrap: wrap;
}
</style>
