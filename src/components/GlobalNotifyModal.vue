<template>
  <q-dialog v-model="internalVisible" :persistent="persistent">
    <q-card class="alert-card q-pa-md">
      <div class="row no-wrap">
        <div class="col-auto icon-column column items-center q-pr-md">
          <q-avatar size="64px" :color="palette.color" text-color="white">
            <q-icon :name="palette.icon" size="32px" />
          </q-avatar>

          <div class="text-caption text-grey-8 q-mt-sm text-center">
            {{ menu || "Mensagem do sistema" }}
          </div>
        </div>

        <div class="col">
          <div class="row items-start q-mb-sm">
            <div class="col">
              <div class="text-subtitle1 text-weight-bold">
                {{ resolvedTitle }}
              </div>
              <div v-if="task" class="text-caption text-grey-8">
                {{ task }}
              </div>
            </div>

            <q-btn dense flat round icon="close" color="grey-7" @click="close" />
          </div>

          <div class="text-body2 q-mb-sm">{{ message }}</div>

          <q-banner
            v-if="solution"
            dense
            class="bg-grey-1 text-grey-9 q-pa-sm rounded-borders q-mt-sm"
          >
            <div class="row no-wrap items-start">
              <q-icon name="lightbulb" color="amber-7" class="q-mr-sm" />
              <div>
                <div class="text-weight-medium">Solução sugerida</div>
                <div class="text-caption text-grey-8">{{ solution }}</div>
              </div>
            </div>
          </q-banner>

          <div class="row q-gutter-sm justify-end q-mt-md">
            <q-btn
              v-for="(btn, idx) in resolvedActions"
              :key="idx"
              :label="btn.label"
              :color="btn.color || palette.color"
              :icon="btn.icon"
              :flat="btn.flat !== false"
              :unelevated="btn.unelevated === true"
              :outline="btn.outline === true"
              no-caps
              @click="emitAction(btn)"
            />
          </div>
        </div>
      </div>
    </q-card>
  </q-dialog>
</template>

<script>
const TYPE_META = {
  positive: {
    icon: "check_circle",
    color: "positive",
    title: "Tudo certo",
  },
  negative: {
    icon: "error",
    color: "negative",
    title: "Algo deu errado",
  },
  warning: {
    icon: "warning",
    color: "warning",
    title: "Atenção",
  },
  info: {
    icon: "info",
    color: "primary",
    title: "Informação",
  },
};

export default {
  name: "GlobalNotifyModal",
  props: {
    modelValue: { type: Boolean, default: false },
    type: { type: String, default: "info" },
    title: { type: String, default: "" },
    message: { type: String, default: "" },
    solution: { type: String, default: "" },
    menu: { type: String, default: "" },
    task: { type: String, default: "" },
    actions: { type: Array, default: () => [] },
    persistent: { type: Boolean, default: false },
  },

  data() {
    return {
      internalVisible: this.modelValue,
    };
  },

  computed: {
    palette() {
      return TYPE_META[this.type] || TYPE_META.info;
    },

    resolvedTitle() {
      return this.title || this.palette.title || "Mensagem";
    },

    resolvedActions() {
      if (this.actions && this.actions.length) return this.actions;
      return [
        {
          label: "Fechar",
          color: this.palette.color,
          icon: "close",
          action: "close",
          flat: false,
          unelevated: true,
        },
      ];
    },
  },

  watch: {
    modelValue(val) {
      this.internalVisible = val;
    },

    internalVisible(val) {
      this.$emit("update:modelValue", val);
    },
  },

  methods: {
    close() {
      this.internalVisible = false;
    },

    emitAction(action) {
      this.$emit("action", action);
      if (action?.action === "close" || action?.closeOnClick !== false) {
        this.close();
      }
    },
  },
};
</script>

<style scoped>
.alert-card {
  width: 100%;
  max-width: 820px;
}

.icon-column {
  min-width: 132px;
}
</style>
