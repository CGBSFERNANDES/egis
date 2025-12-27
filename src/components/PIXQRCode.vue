<template>
  <div>
    <QRCodeGenerator v-if="PIXData" :value="PIXData" :showContent="true" />
    <div v-if="!chave" class="text-center">
      <p class="text-h6">Chave PIX não encontrada</p>
    </div>
  </div>
</template>

<script>
import QRCodeGenerator from "./QRCode.vue";
import { QrCodePix } from "qrcode-pix";

export default {
  name: "PixQrCode",
  components: {
    QRCodeGenerator,
  },
  props: {
    chave: { type: String, required: true },
    nome: { type: String, required: false, default: "" },
    cidade: { type: String, required: false, default: "SAO PAULO" },
    valor: { type: [Number, String], default: null },
    txid: { type: String, default: "***" },
    message: { type: String, default: "" },
  },
  data() {
    return {
      PIXData: "",
    };
  },
  watch: {
    propsInput: {
      handler() {
        this.gerarPayload();
      },
      deep: true,
      immediate: true,
    },
  },
  computed: {
    propsInput() {
      return {
        chave: this.chave,
        nome: this.nome,
        cidade: this.cidade,
        valor: this.valor,
        txid: this.txid,
        message: this.message,
      };
    },
  },
  methods: {
    async gerarPayload() {
      const qrCodePix = QrCodePix({
        version: "01",
        key: this.chave, //or any PIX key
        name: this.nome,
        city: this.cidade,
        transactionId: this.txid, //max 25 characters
        message: this.message,
        value: this.valor,
      });

      //console.log(qrCodePix.payload()); // '00020101021126510014BR.GOV.BCB.PIX...'
      //console.log(await qrCodePix.base64()); // 'data:image/png;base64,iVBORw0...'
      this.PIXData = qrCodePix.payload();
    },
  },
};
</script>
