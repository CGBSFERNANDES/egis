<template>
  <div class="qr-code-generator">
    <canvas ref="canvas"></canvas>
    <p v-if="showContent" class="content">{{ value }}</p>
  </div>
</template>

<script>
import QRCode from "qrcode";

export default {
  name: "QrCode",
  props: {
    value: {
      type: String,
      required: true,
    },
    showContent: {
      type: Boolean,
      default: false,
    },
    options: {
      type: Object,
      default: function () {
        return {
          width: 200,
          margin: 2,
          color: {
            dark: "#000000",
            light: "#ffffff",
          },
        };
      },
    },
  },
  watch: {
    value: {
      immediate: true,
      handler(val) {
        this.generateQrCode(val);
      },
    },
  },
  mounted() {
    this.generateQrCode(this.value);
  },
  methods: {
    generateQrCode(text) {
      const canvas = this.$refs.canvas;
      if (!canvas) return;

      QRCode.toCanvas(canvas, text, this.options, function (error) {
        if (error) {
          console.error("Erro ao gerar QR Code:", error);
        }
      });
    },
  },
};
</script>

<style scoped>
.qr-code-generator {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.content {
  margin-top: 10px;
  font-family: monospace;
  word-break: break-word;
  text-align: center;
}
</style>
