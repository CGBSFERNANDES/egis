<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div v-if="urlEmbed" style="width: 100%; height: 85vh">
      <iframe
        class="responsive-iframe"
        :src="urlEmbed"
        frameborder="0"
        style="border: none"
      ></iframe>
    </div>
    <div v-else>
      <div>Não foi possível carregar o Auto Atendimento</div>
    </div>
  </div>
</template>

<script>
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";

export default {
  data() {
    return {
      cd_empresa: 0,
      cd_menu: 0,
      cd_usuario: 0,
      usuario: "",
      urlEmbed: `https://egisnet.com.br/gca/?ic_auto_atendimento=true&cd_empresa=${
        localStorage.cd_empresa
      }&cd_usuario=${
        this.$store._mutations.SET_Usuario.cd_usuario
      }&caixa_aberto=${
        this.$store._mutations.SET_Usuario.dt_ultimo_fechamento || "false"
      }`,
    };
  },
  created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    console.log(
      this.$store._mutations.SET_Usuario,
      " this.$store._mutations.SET_Usuario"
    );
    console.log(
      `https://egisnet.com.br/gca/?ic_auto_atendimento=true&cd_empresa=${
        localStorage.cd_empresa
      }&cd_usuario=${
        this.$store._mutations.SET_Usuario.cd_usuario
      }&caixa_aberto=${
        this.$store._mutations.SET_Usuario.dt_ultimo_fechamento || "false"
      }`
    );
  },

  methods: {},
};
</script>

<style lang="scss">
.responsive-iframe {
  width: 100%;
  height: 100%;
  //min-height: 35rem; /* ajuste conforme necessário */
  border: none;
  display: block;
}
</style>
