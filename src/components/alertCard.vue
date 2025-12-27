<template>
  <div style="padding:0.5vh 0.5vw">
    <q-card
      class="fixed-center borda"
      style="width:auto"
      v-if="cd_tipo_layout == 0"
    >
      <div class="row justify-center items-center">
        <div class="text-h6 margin1">{{ tituloCard }}</div>
        <q-space />
        <q-btn class="margin1" icon="close" flat round dense v-close-popup />
      </div>

      <div class="row justify-center items-center margin1">
        <q-avatar
          v-if="!!nm_icon"
          class="margin1"
          :color="nm_cor_icon"
          text-color="white"
          :icon="nm_icon"
        />
        <div
          style="font-size:18px"
          v-show="!!nm_descritivo"
          class="margin1 text-justify"
        >
          {{ nm_descritivo }}
        </div>
      </div>
    </q-card>
  </div>
</template>

<script>
export default {
  props: {
    cd_tipo_layout: { type: Number, default: 0 },
    nm_texto_titulo: { type: String, default: "" },
    nm_descritivo: { type: String, default: "" },
    nm_icon: { type: String, default: "" },
    nm_cor_icon: { type: String, default: "negative" },
  },
  name: "alertCard",
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_modulo: localStorage.cd_modulo,
      cd_usuario: localStorage.cd_usuario,
      tituloCard: "",
    };
  },
  created() {
    if (!!this.nm_texto_titulo == false) {
      this.tituloCard = "Alerta!";
    } else {
      this.tituloCard = this.nm_texto_titulo;
    }
  },
};
</script>

<style>
@import url("../views/views.css");
</style>
