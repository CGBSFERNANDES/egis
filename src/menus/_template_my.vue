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
  >
    <!-- Exemplo: botões extras -->
    <template #toolbar-right="{ engine }">
      <!-- coloque ações específicas do menu aqui -->
      <!-- <q-btn dense rounded icon="bolt" @click="acaoEspecial(engine)" /> -->
    </template>

    <!-- área custom no form (opcional) -->
    <template #form-custom="{ engine }">
      <!-- conteúdo extra do form -->
    </template>

    <!-- rodapé do form (opcional) -->
    <template #form-footer="{ engine }">
      <!-- botões/ações extra no rodapé -->
    </template>
  </unico-form-especial>
</template>

<script>
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue"

export default {
  name: "my_MENU_ID",
  components: { UnicoFormEspecial },

  props: {
    // opcional: se o menu for usado “embutido”
    embedMode: { type: Boolean, default: false },
    registroPai: { type: Object, default: null },
    cdChaveRegistro: { type: Number, default: 0 },
  },

  data() {
    return {
      cdAcesso: Number(localStorage.cd_chave_pesquisa || 0),
      modoInicial: "GRID",

      overrides: {
        title: "MENU_TITLE",
        gridPageSize: 200,
        defaultFilters: {
          // status: "ATIVO",
        },
        hideButtons: {
          // novo: false,
          // filtro: false,
          // excel: false,
          // pdf: true,
          // relatorio: false,
        },
      },

      hooks: {
        // beforeFetchRows: async ({ filtros }) => {},
        // mapPayload: async ({ payload }) => payload,
        // onError: async ({ err, hook }) => console.error(hook, err),
      },
    }
  },

  methods: {
    onSelecionou(registro) {},
    onVoltar() {
      this.$router.back()
    },
    onFechar() {
      this.$router.back()
    },
    // acaoEspecial(engine) {},
  },
}
</script>
