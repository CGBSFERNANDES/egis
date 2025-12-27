<template>
  <div>
    <q-dialog maximized v-model="carregando" persistent>
      <div class="carregando text-center">
        <q-circular-progress
          indeterminate
          show-value
          font-size="14px"
          size="60px"
          :color="cor_circulo"
          class="your_div_class fixed-center fullscreen retira-scroll text-white"
        >
          <div class="mensagem-meio text-center">{{ mensagem }}</div>
        </q-circular-progress>
      </div>
    </q-dialog>
  </div>
</template>

<script>
export default {
  props: {
    mensagemID: { type: String, default: "" },
    corID: { type: String, default: "" },
  },
  data() {
    return {
      carregando: true,
      url: "https://www.egisnet.com.br/img/logo_gbs_logotipo.png",
      mensagem: "",
      cor_circulo: "primary",
    };
  },
  created() {
    this.mensagemID != ""
      ? (this.mensagem = this.mensagemID)
      : (this.mensagem = "Aguarde...");

    this.corID == ""
      ? (this.cor_circulo = "primary")
      : (this.cor_circulo = this.corID);
  },
};
</script>

<style scoped>
.carregando {
  width: 100vw;
  margin: auto;
  overflow: hidden;
}
.retira-scroll {
  width: 300px;
  height: 200px;
  border: none;
  overflow: hidden;
}
.img_gbs {
  border: white 3px solid;
  border-radius: 50%;
}
.mensagem-meio {
  width: 120px;
}
</style>
