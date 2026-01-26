<template>
  <unico-form-especial
    :cd_menu_entrada="MENU_ID"
    :cd_acesso_entrada="cdAcesso"
    :modo_inicial="modoInicial"
    :embedMode="embedMode"
    :registro_pai="registroPai"
    :cd_chave_registro="cdChaveRegistro"
    :overrides="overrides"
    :hooks="hooks"
    @selecionou="onSelecionou"
    @voltar="onVoltar"
    @fechar="onFechar"
  />
</template>

<script>
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue"

const MENU_ID = 8912

export default {
  name: "my_8912",
  components: { UnicoFormEspecial },

  props: {
    embedMode: { type: Boolean, default: false },
    registroPai: { type: Object, default: null },
    cdChaveRegistro: { type: Number, default: 0 },
  },

  data() {
    return {
      MENU_ID,
      cdAcesso: Number(localStorage.cd_chave_pesquisa || 0),
      modoInicial: "GRID",

      overrides: {
        title: "Teste",
        gridPageSize: 200,
      },

      hooks: {},
    }
  },

  methods: {
    onSelecionou(registro) {
      // afterRowSelect (ou equivalente)
    },
    onVoltar() {
      this.$router.back()
    },
    onFechar() {
      this.$router.back()
    },
  },
}
</script>
