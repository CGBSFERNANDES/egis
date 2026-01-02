<template>
  <div class="egis-form-shell-lite">
    <unico-form-especial
      ref="engine"
      class="engine-lite"
      v-bind="$attrs"
      v-on="$listeners"
      :overrides="mergedOverrides"
      uiPreset="lite"
    >
    <template #toolbar-right="{ engine }">
    <div class="egis-lite-right row items-center no-wrap">
      <q-btn dense round color="deep-purple-7" icon="info" @click="onInfo(engine)" />
      <q-chip dense rounded color="deep-purple-7" text-color="white" clickable @click="onInfo(engine)">
        {{ getCdMenu(engine) }}
      </q-chip>
    </div>
  </template>

    </unico-form-especial>
  </div>
</template>

<script>
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue"

export default {
  name: "EgisFormShellLite",
  components: { UnicoFormEspecial },
  inheritAttrs: false,

  props: {
    overrides: { type: Object, default: () => ({}) },
  },

  computed: {

      mergedOverrides() {
    return { ...(this.overrides || {}), ui_lite: true }
  },
    engineOverrides() {
      const base = this.overrides || {}
      return {
        ...base,
        hideButtons: {
          ...(base.hideButtons || {}),
          novo: false,
          filtro: true,
          refresh: true,
          excel: true,
          pdf: true,
          acoes: true,
          modal: true,
          relatorio: true,
          dash: true,
          mapaAtributos: true,
          info: true,
          processos: true,
        },
      }
    },
  },

  methods: {
    onInfo(engine) {
      if (engine && typeof engine.onInfoClick === "function") engine.onInfoClick()
    },
    getCdMenu(engine) {
      const v =
        (engine && (engine.cdMenu || engine.cd_menu)) ||
        (this.$attrs && this.$attrs.cd_menu_entrada) ||
        ""
      return String(v)
    },
  },
}
</script>

<style scoped>
/* compatível Vue2/Quasar: use >>> e /deep/ (evita erro de build) */
.engine-lite >>> h2.fo-margin,
.engine-lite /deep/ h2.fo-margin {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
}

.engine-lite >>> .lite-toolbar-right,
.engine-lite /deep/ .lite-toolbar-right {
  margin-left: auto;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

/* remove chip original do engine */
.engine-lite >>> .margin-menu,
.engine-lite /deep/ .margin-menu {
  display: none !important;
}

/* remove botões do header do engine (mantém os do shell via .lite-keep) */
.engine-lite >>> h2.fo-margin .q-btn:not(.lite-keep),
.engine-lite /deep/ h2.fo-margin .q-btn:not(.lite-keep) {
  display: none !important;
}

/* remove toggles do header */
.engine-lite >>> h2.fo-margin .q-toggle,
.engine-lite /deep/ h2.fo-margin .q-toggle {
  display: none !important;
}

.egis-lite-right {
  margin-left: auto;
  gap: 8px;
}

</style>
