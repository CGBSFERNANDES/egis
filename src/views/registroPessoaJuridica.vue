<template>
  <div>
     <h2 class="content-block">{{tituloMenu}}
      <q-badge v-if="qt_registro > 0"
        align="middle" rounded color="red" :label="qt_registro" />
     </h2> 
     <cliente></cliente>
  </div>
</template>

<script>
import Procedimento from '../http/procedimento';
import Menu from '../http/menu';
import cliente from '../views/cliente.vue'
export default {
 components: {
    cliente
 },
 data() {
    return {
      tituloMenu         : '',
      qt_registro        : 0
    }
 },
 async created() {
    this.tituloMenu = 'Registro de Pessoa Jurídica';
 },
 async mounted() {
 }        
}
</script>

<style>

</style>