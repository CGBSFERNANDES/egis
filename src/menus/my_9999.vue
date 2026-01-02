<template>
  <unico-form-especial
    :cd_menu_entrada="9999"
    :cd_acesso_entrada="cdAcesso"
    modo_inicial="GRID"
    :overrides="overrides"
    :hooks="hooks"
    @selecionou="onSelecionou"
  >
    <!-- Exemplo: botão extra na direita da toolbar -->
    <template #toolbar-right="{ engine }">
      <q-btn
        dense
        rounded
        color="deep-purple-7"
        class="q-mt-sm q-ml-sm"
        icon="bolt"
        size="lg"
        @click="acaoEspecial(engine)"
      >
        <q-tooltip>Ação Especial</q-tooltip>
      </q-btn>
    </template>
  </unico-form-especial>
</template>

<script>
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue"

export default {
  name: "my_9999",
  components: { UnicoFormEspecial },
  data() {
    return {
      cdAcesso: Number(localStorage.cd_chave_pesquisa || 0),

      overrides: {
        title: "Meu menu 9999",
        gridPageSize: 200,
        // esconder botões padrão se quiser:
        hideButtons: {
          relatorio: false,
          pdf: false,
          excel: false,
          dashboard: false,
          mapaAtributos: false,
          info: false,
          processos: false,
          filtro: false,
          novo: false,
          refresh: false,
          composicao: false,
        },
        // filtros default (opcional)
        defaultFilters: {
          // status: "ATIVO"
        },
      },

      hooks: {
        // chamado antes de consultar
        beforeFetchRows: async ({ filtros }) => {
          // aplica filtro default se não veio nada
          if (filtros && filtros.status == null) filtros.status = "ATIVO"
        },

        // transforma payload antes de salvar
        mapPayload: async ({ payload }) => {
          return { ...payload, cd_empresa: Number(localStorage.cd_empresa || 0) }
        },

        onError: async ({ err, hook }) => {
          console.error("Erro no hook:", hook, err)
        },
      },
    }
  },
  methods: {
    onVoltar() {
      this.$router.back()
    },
    onFechar() {
      this.$router.back()
    },
    onSelecionou(registro) {
      // se você quiser reagir quando seleciona uma linha
      // console.log("selecionou", registro)
    },
    acaoEspecial(engine) {
      // acesso ao engine: engine.rows, engine.registrosSelecionados, etc.
      console.log("Rows:", engine.rows?.length || 0)
    },
  },
}
</script>
