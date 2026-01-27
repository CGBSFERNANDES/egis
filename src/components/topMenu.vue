<template>
  <transition name="slide-fade">
    <!-- título + seta + badge -->
    <h2
      class="content-block col-12 row items-center no-wrap toolbar-scroll"
      v-show="displayTitle"
    >
      <!-- seta voltar -->
      <q-btn
        flat
        round
        dense
        icon="arrow_back"
        class="q-mr-sm seta-form"
        aria-label="Voltar"
        @click="$emit('voltar')"
      />
      <span
        v-if="displayTitle"
        :class="ic_modal_pesquisa === 'S' ? 'titulo-modal' : ''"
      >
        {{ displayTitle }}
      </span>

      <!-- badge com total de registros -->
      <div style="display: flex; align-items: center;">
        <q-badge
          v-if="(qt_registro || recordCount) >= 0"
          align="middle"
          rounded
          color="red"
          :label="qt_registro || recordCount"
          class="q-ml-sm bg-form"
        />
      </div>

      <template v-if="mostrarToolbar">
        <slot name="toolbar-left" :engine="engine" />
      </template>

      <template v-if="!uiLite && mostrarToolbar">
        <q-btn
          v-if="cd_tabela > 0 && !isHidden('novo')"
          dense
          rounded
          color="deep-purple-7"
          :class="['q-mt-sm', 'q-ml-sm', cd_tabela != 0 ? 'fo-margin' : '']"
          icon="add"
          @click="$emit('novo')"
        >
          <q-tooltip>Novo Registro</q-tooltip>
        </q-btn>

        <q-btn
          v-if="cd_tabela > 0 && !isHidden('novo')"
          dense
          rounded
          color="deep-purple-7"
          :class="['q-mt-sm', 'q-ml-sm']"
          icon="filter_alt"
          @click="$emit('filtros')"
        >
          <q-tooltip>Filtros</q-tooltip>
        </q-btn>

        <q-btn
          v-if="!isHidden('refresh')"
          dense
          rounded
          icon="refresh"
          color="deep-purple-7"
          :class="['q-mt-sm', 'q-ml-sm', cd_tabela === 0 ? 'fo-margin' : '']"
          @click="$emit('refresh')"
        >
          <q-tooltip>Atualizar os Dados</q-tooltip>
        </q-btn>

        <q-btn
          v-if="cd_form_modal > 0"
          rounded
          dense
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="tune"
          :disable="cd_form_modal <= 0"
          @click="$emit('detalhe')"
        >
          <q-tooltip>Detalhe</q-tooltip>
        </q-btn>

        <q-btn
          v-if="!isHidden('excel')"
          rounded
          dense
          color="deep-purple-7"
          icon="far fa-file-excel"
          class="q-mt-sm q-ml-sm"
          @click="$emit('excel')"
        >
          <q-tooltip>Exportar Excel</q-tooltip>
        </q-btn>

        <q-btn
          v-if="!isHidden('pdf')"
          rounded
          dense
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="picture_as_pdf"
          @click="$emit('pdf')"
        >
          <q-tooltip>Exportar PDF</q-tooltip>
        </q-btn>
        <q-btn
          v-if="!isHidden('relatorio')"
          rounded
          dense
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="description"
          @click="$emit('relatorio')"
        >
          <q-tooltip>Abrir Relatório</q-tooltip>
        </q-btn>

        <q-btn
          v-if="!isHidden('dash')"
          dense
          rounded
          color="deep-purple-7"
          icon="dashboard"
          class="q-mt-sm q-ml-sm"
          @click="$emit('dash')"
        >
          <q-tooltip>Dashboard dos dados</q-tooltip>
        </q-btn>

        <!-- Botão de processos (3 pontinhos) -->
        <q-btn
          v-if="cd_menu_processo > 0"
          dense
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="more_horiz"
          @click="$emit('processos')"
        >
          <q-tooltip>Processos</q-tooltip>
        </q-btn>
        <q-btn
          v-if="!isHidden('mapaAtributos')"
          rounded
          dense
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="view_list"
          @click="$emit('mapa-atributos')"
        >
          <q-tooltip>Mapa de Atributos</q-tooltip>
        </q-btn>

        <q-btn
          v-if="false && !isHidden('info')"
          dense
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="info"
          @click.stop.prevent="$emit('info')"
        >
          <q-tooltip>Informações</q-tooltip>
        </q-btn>

        <q-btn
          v-if="filtros && filtros.length"
          dense
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="filter_alt_off"
          @click="$emit('drawer-filtros')"
        >
          <q-tooltip>Seleção de Filtros</q-tooltip>
        </q-btn>

        <!-- TOGGLE: GRID x CARDS (só aparece quando meta permite) -->
        <q-toggle
          v-if="String(ic_card_menu || 'N').toUpperCase() === 'S'"
          :value="exibirComoCards"
          color="deep-purple-7"
          checked-icon="view_module"
          unchecked-icon="view_list"
          :label="exibirComoCards ? 'cards' : 'grid'"
          keep-color
          class="q-mt-sm q-ml-sm"
          @input="onToggleCards"
        />

        <!-- TOGGLE TreeView x Grid -->
        <q-toggle
          v-if="String(ic_treeview_menu || 'N').toUpperCase() === 'S'"
          :value="exibirComoTree"
          color="deep-purple-7"
          checked-icon="account_tree"
          unchecked-icon="view_list"
          :label="exibirComoTree ? 'tree' : 'grid'"
          keep-color
          class="q-mt-sm q-ml-sm"
          @input="onToggleTree"
        />

        <template v-if="mostrarToolbar">
          <slot name="toolbar-right" :engine="engine" />
        </template>

        <q-chip
          v-if="cdMenu || cd_menu"
          dense
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm menu-chip-right"
          size="12px"
          text-color="white"
          :label="`${cdMenu || cd_menu}`"
          @click.native.stop.prevent="$emit('menu-chip')"
        >
          <q-tooltip>identificação</q-tooltip>
        </q-chip>
      </template>
    </h2>
  </transition>
</template>

<script>
export default {
  name: "topMenu",
  props: {
    displayTitle: { type: [String, Number], default: "" },
    ic_modal_pesquisa: { type: String, default: "" },
    qt_registro: { type: [String, Number], default: null },
    recordCount: { type: [String, Number], default: null },
    mostrarToolbar: { type: Boolean, default: true },
    uiLite: { type: Boolean, default: false },
    cd_tabela: { type: Number, default: 0 },
    cd_form_modal: { type: Number, default: 0 },
    cd_menu_processo: { type: Number, default: 0 },
    filtros: { type: Array, default: () => [] },
    ic_card_menu: { type: String, default: "N" },
    exibirComoCards: { type: Boolean, default: false },
    ic_treeview_menu: { type: String, default: "N" },
    exibirComoTree: { type: Boolean, default: false },
    cdMenu: { type: [String, Number], default: null },
    cd_menu: { type: [String, Number], default: null },
    isHidden: { type: Function, default: () => false },
    engine: { type: Object, default: null },
  },
  methods: {
    onToggleCards(valor) {
      this.$emit("update:exibirComoCards", valor);
    },
    onToggleTree(valor) {
      this.$emit("update:exibirComoTree", valor);
    },
  },
};
</script>

<style scoped>
.no-wrap {
  flex-wrap: nowrap;
}

.toolbar-scroll {
  overflow-x: auto;
  white-space: nowrap;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.toolbar-scroll::-webkit-scrollbar {
  display: none;
}

.seta-form {
  margin-left: 10px;
  color: #512da8;
}

.menu-chip-right {
  margin-left: auto;
  margin-right: 30px;
}
</style>
