<template>
  <div>
    <etapa></etapa>
  </div>
</template>

<script>

import etapa from '../views/moduloEtapaProcesso';

export default {
     components: {
        etapa
     },
     data() {
        
         return {
            tituloMenu : '.'
         }
     }    
}  
</script>

<style>

</style>