<template>
  <MonitorEmpresaNFe v-bind="$props" v-on="$listeners" />
</template>

<script>
import MonitorEmpresaNFe from "@/views/monitorEmpresaNFe.vue"

export default {
  name: "menu_8842",
  components: { MonitorEmpresaNFe },
  props: MonitorEmpresaNFe.props,
}
</script>
