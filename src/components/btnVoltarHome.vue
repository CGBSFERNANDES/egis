<template>
  <div style="padding: 0.5vh 0.5vw">
    <q-btn flat round icon="arrow_back" @click="$router.push({ name: 'home' })">
      <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
        Home
      </q-tooltip>
    </q-btn>
  </div>
</template>

<script>
export default {
  name: "btnVoltarHome",
  data() {
    return {
      tituloCard: "",
    };
  },
};
</script>

<style>
@import url("../views/views.css");
</style>
