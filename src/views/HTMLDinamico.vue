<template>
  <div class="HTMLDinamicoClass">
    <iframe
      ref="meuIframe"
      v-if="safeUrl"
      :src="safeUrl"
      width="100%"
      height="100%"
      frameborder="0"
      style="border: none"
    ></iframe>
    <div v-else>
      <div class="text-h6 metadeTela">URL inválida.</div>
    </div>
  </div>
</template>

<script>
import funcao from "../http/funcoes-padroes.js";

export default {
  name: "HTMLDinamico",
  props: {
    cd_pagina_modulo: {
      type: Number,
      default: 0,
    },
    url_pagina: {
      type: String,
      default: "",
    },
    nm_caminho_pagina: {
      type: String,
      default: "",
    },
    nm_endereco_pagina: {
      type: String,
      default: "",
    },
    ic_abre_outra_pagina: {
      type: String,
      default: "N",
    },
  },
  data() {
    return {
      safeUrl: "",
    };
  },
  created() {
    this.gerarUrl();
  },
  methods: {
    async gerarUrl() {
      this.safeUrl = "";
      let parsed;
      let jsonOriginal;
      let params;
      jsonOriginal = JSON.stringify({
        cd_modulo: localStorage.cd_modulo,
        cd_usuario: localStorage.cd_usuario,
        cd_empresa: parseInt(localStorage.cd_empresa),
        cd_relatorio: 361,
        dt_inicial: funcao.DataBRtoUSA(localStorage.dt_inicial),
        dt_final: funcao.DataBRtoUSA(localStorage.dt_final),
      });
      let jsonBase64 = btoa(jsonOriginal);
      try {
        if (this.url_pagina) {
          // URL direta
          parsed = new URL(this.url_pagina);
          params = parsed.searchParams;
          params.set("banco", localStorage.nm_banco_empresa);
          params.set("nm_banco_empresa", localStorage.nm_banco_empresa);
          params.set("dados_b64", jsonBase64);
          if (this.ic_abre_outra_pagina === "S") {
            window.open(parsed.href, "_blank");
            this.$emit("semIframe");
          } else {
            this.safeUrl = parsed.href;
          }
          return;
        }
        // Valida a URL antes de usar
        if (this.cd_pagina_modulo) {
          //Dashboard do módulo (Home)
          parsed = new URL(
            this.$store._mutations.SET_Usuario.nm_caminho_pagina
          );
          params = parsed.searchParams;
          params.set("banco", localStorage.nm_banco_empresa);
          params.set("dados_b64", jsonBase64);
        } else {
          // Menu
          if (
            this.nm_caminho_pagina &&
            this.nm_caminho_pagina.includes("http")
          ) {
            parsed = new URL(this.nm_caminho_pagina);
          } else if (
            this.nm_endereco_pagina &&
            this.nm_endereco_pagina.includes("http")
          ) {
            parsed = new URL(this.nm_endereco_pagina);
          } else if (
            this.$store._mutations.SET_Rotas.nm_caminho_pagina &&
            this.$store._mutations.SET_Rotas.nm_caminho_pagina.includes("http")
          ) {
            parsed = new URL(
              this.$store._mutations.SET_Rotas.nm_caminho_pagina
            );
          } else if (
            this.$store._mutations.SET_Rotas.nm_endereco_pagina &&
            this.$store._mutations.SET_Rotas.nm_endereco_pagina.includes("http")
          ) {
            parsed = new URL(
              this.$store._mutations.SET_Rotas.nm_endereco_pagina
            );
          }
          params = parsed.searchParams;
          params.set("cd_usuario", localStorage.cd_usuario);
          params.set("cd_empresa", localStorage.cd_empresa);
          params.set("cd_relatorio", localStorage.cd_relatorio);
          params.set("dt_inicial", localStorage.dt_inicial);
          params.set("dt_final", localStorage.dt_final);
          params.set("banco", localStorage.nm_banco_empresa);
          params.set("dados_b64", jsonBase64);
        }
        this.safeUrl = parsed.href; // Atualiza a propriedade reativa
      } catch (e) {
        this.$emit("semIframe");
        return null;
      }
    },
  },
};
</script>

<style scoped>
html,
body,
div {
  height: 100%;
  margin: 0;
  padding: 0;
}

.HTMLDinamicoClass {
  height: 100vh;
  width: 97.5vw;
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

iframe {
  display: block;
  height: 100%;
  width: 100%;
  border: none;
}
</style>
