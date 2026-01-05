<template>
  <MonitorEmpresaNFe v-bind="$props" v-on="$listeners" />
</template>

<script>
import MonitorEmpresaNFe from "./monitorEmpresaNFe.vue"

export default {
  name: "my_8842",
  components: { MonitorEmpresaNFe },
  props: MonitorEmpresaNFe.props,
}
</script>
