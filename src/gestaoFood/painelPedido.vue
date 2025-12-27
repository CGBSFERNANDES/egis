<template>
<div>
  <div class="margin1">
    <q-btn round color="primary" icon="fullscreen" @click="PopUpFull()"/>
  </div>
  <q-dialog v-model="popup" persistent :maximized="maximizedToggle" transition-show="jump-up" transition-hide="jump-down">
    <q-card class="fundo-painel text-black" >
      <q-bar class="fundo-painel text-white">
        <q-space />

        <q-btn dense flat icon="minimize" @click="maximizedToggle = false" :disable="!maximizedToggle">
          <q-tooltip v-if="maximizedToggle" class="bg-white text-white">Minimizar</q-tooltip>
        </q-btn>
        <q-btn dense flat icon="crop_square" @click="maximizedToggle = true" :disable="maximizedToggle">
          <q-tooltip v-if="!maximizedToggle" class="bg-white text-primary">Maximizar</q-tooltip>
        </q-btn>
        <q-btn dense flat icon="close" v-close-popup>
          <q-tooltip class="fundo-painel text-primary" @click="fechaTela()">Fechar</q-tooltip>
        </q-btn>
      </q-bar>
      
      <q-card class="borda-bloco margin1">
        <div class=" text-h2 text-bold justify-center items-center self-center text-center text-italic margin1">
          Painel de Pedidos 
        </div>
        <hr>
        <div class="row margin1">
          
          <div class="col justify-center text-center text-italic margin1">
            <div class="text-h3 preparando text-white" style="margin:0;padding:0">
               PREPARANDO
            </div>
            
           

            <div class="pedidos">
              <div class="" v-for="(i, index) in dataSourceConfig" :key="index">   
                <span class="texto-0 text-bold text-amber-8 " v-if="i.cd_pedido_aberto > 0 && index == 0">{{i.cd_pedido_aberto}}</span> 
                <span class="texto-1" v-if="i.cd_pedido_aberto > 0 && index > 0">{{i.cd_pedido_aberto}}</span> 
                
              </div>
            </div>
           
          </div>
          
          <div class="col justify-center text-center text-italic margin1">
            <div class="text-h3 pronto text-white" style="margin:0;padding:0">
               PRONTO
            </div>
            
            <div class="pedidos">
              <div v-for="(i, index) in dataSourceConfig" :key="index">  
                <span class="texto-0 text-bold text-green-7 " v-if="i.cd_pedido_pronto > 0 && index == 0">{{i.cd_pedido_aberto}}</span> 
                <span class="texto-1" v-if="i.cd_pedido_pronto> 0 && index > 0">{{i.cd_pedido_aberto}}</span> 

              </div>
            </div>
          </div>
        </div>
       

     <br>
                                      
  
      </q-card>
      
    
    </q-card>
  </q-dialog>
    

  </div>
</template>

<script>
  import Procedimento from '../http/procedimento';
  import Menu from '../http/menu';

export default {
 components: {
 },

 data() {
    return {
      tituloMenu         : '',
      dataSourceConfig   : [],
      popup                   : true,
      maximizedToggle         : true,
      polling            : null,
      tamanho              : 0
    }
 },
 async mounted() {
   this.$q.fullscreen.toggle();
   this.carregaDados();
   this.pollData();
 },
 beforeDestroy () {
    clearInterval(this.polling);
 },

 methods: {
   PopUpFull(){
     this.popup = true;
      this.$q.fullscreen.request();
   },
   fechaTela(){
      this.$q.fullscreen.exit();
   },

     pollData () {
      this.polling = setInterval(() => {
         this.carregaDados();
      }, 36000);
          
    },

    async carregaDados() {

       let dados_menu = await Menu.montarMenu(localStorage.cd_empresa, localStorage.cd_menu, localStorage.cd_api);  
       
       localStorage.cd_parametro = 0;

       this.dataSourceConfig = await Procedimento.montarProcedimento(
                 localStorage.cd_empresa, 
                 this.cd_cliente, 
                 dados_menu.nm_identificacao_api,
                 dados_menu.nm_api_parametro
            );
            this.tamanho = this.dataSourceConfig.length -1
        


    }  
 }        
}
</script>

<style scoped>

.direita {
  float: right;   
  right: 10px;
  text-align: right;
 
}
.margin1{
  margin: 0.8vw 1vw;
}
.borda-bloco{
    box-shadow: 1px 2px 2px rgb(197, 197, 197) !important;
    border: solid 1px rgb(170, 170, 170) ;
    border-radius: 10px !important;
    height: 85vw;
    max-height: 80%;
}
.pedidos{
  max-height: 80vw;
}
.principal{
  text-decoration: underline;
}
.texto-0{
  font-size: 80px;
}
.texto-1{
  font-size: 45px;
}
.fundo-painel{
  background:#000000 ;
}
.preparando{
  background: rgb(53, 53, 53);
  border-radius: 10px;
}
.pronto{
  background: rgb(2, 182, 17);
  border-radius: 10px;
}
</style>