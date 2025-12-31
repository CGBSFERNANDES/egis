<template>
  <unico-form-especial
    :cd_menu_entrada="8832"
    :cd_acesso_entrada="cdAcesso"
    modo_inicial="GRID"
    :overrides="overrides"
    :hooks="hooks"
    @voltar="onVoltar"
    @fechar="onFechar"
  />
</template>

<script>
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue"

export default {
  name: "my_8832",
  components: { UnicoFormEspecial },
  data() {
    return {
      cdAcesso: Number(localStorage.cd_chave_pesquisa || 0),

      overrides: {
        title: "Objetivo",
        gridPageSize: 200
      },

      hooks: {
        // pode ficar vazio se não precisar regra extra
      }
    }
  },
  methods: {
    onVoltar() { this.$router.back() },
    onFechar() { this.$router.back() }
  }
}
</script>
