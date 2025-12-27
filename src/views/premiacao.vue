<template>
  <div>
     <h2>{{tituloMenu}} {{qt_ponto}}</h2>
  </div>
</template>

<script>



export default {
     
     components: {

     },
     props: {
         qt_pontoID: { type: Number, default: 0 }
     },
     data() {
        
         return {
            qt_ponto   : 0,
            tituloMenu : ' parabéns'
         }
     },

     created() {
       this.qt_ponto = this.qt_pontoID;
     }
}  
</script>

<style>

</style>