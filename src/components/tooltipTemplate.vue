<template>
  <div class="margin1">
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center " style="margin:10px">
      <b> Cliente: </b>{{ ` ${ObjectRender.nm_fantasia_cliente}` }}
      <q-space />
      <q-btn
        round
        color="negative"
        size="sm"
        flat
        icon="delete"
        @click="Delete(ObjectRender)"
      />
    </div>
    <div class="row items-center" style="margin:10px">
      <b>Solicitante: </b> {{ `${ObjectRender.nm_fantasia_usuario}` }}
    </div>
    <div
      class="row items-center"
      style="margin:10px"
      v-show="!!ObjectRender.dt_atendimento_movimentoPtBr"
    >
      <b>Data:</b> {{ ` ${ObjectRender.dt_atendimento_movimentoPtBr}` }}
    </div>
  </div>
</template>
<script>
export default {
  props: {
    templateTooltipModel: {
      type: Object,
      default: () => {},
    },
  },

  emits: ["deleteAtendimento"],
  data() {
    return {
      ObjectRender: {},
    };
  },
  created() {
    this.ObjectRender = this.templateTooltipModel.appointmentData;
  },
  methods: {
    Delete(e) {
      this.$emit("click", e);
    },
  },
};
</script>
<style scoped>
.margin1 {
  margin: 1vh 1vw;
}
</style>
