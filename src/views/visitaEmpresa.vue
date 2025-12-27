<template>
<div class="margin1">
  <div class="margin1">
    <q-btn round color="primary" icon="fullscreen" @click="ClickButton()"/>
  </div>
  <q-dialog v-model="popup" persistent :maximized="maximizedToggle" transition-show="jump-up" transition-hide="jump-down">
    <q-card class="bg-indigo-9 text-black" >
      <q-bar class="bg-indigo-9 text-white">
        <q-space />

        <q-btn dense flat icon="minimize" @click="maximizedToggle = false" :disable="!maximizedToggle">
          <q-tooltip v-if="maximizedToggle" class="bg-white text-white">Minimizar</q-tooltip>
        </q-btn>
        <q-btn dense flat icon="crop_square" @click="maximizedToggle = true" :disable="maximizedToggle">
          <q-tooltip v-if="!maximizedToggle" class="bg-white text-primary">Maximizar</q-tooltip>
        </q-btn>
        <q-btn dense flat icon="close" v-close-popup>
          <q-tooltip class="bg-indigo-9 text-primary">Fechar</q-tooltip>
        </q-btn>
      </q-bar>

      <div class="text-h6 text-bold row margin1">
       <!-- <div class="margin1" >
          {{dt_visita}}
        </div>
        <q-space/>-->
        <div class="margin1 text-white">
          {{data_escrita}}
        </div>
      </div>  
      
      <div class="borda-bloco  margin1 padding1 bg-white fixed-center">

        <div class="text-h3 text-bold justify-center items-center self-center text-center text-italic" style="margin:10px 5px"  v-if="this.nm_fantasia_empresa != ''">
          {{nm_fantasia_empresa}}
        </div> 

        <div class="row justify-center items-center self-center bg-white" style="border-radius:10px">

          <img v-if="this.url != ''" :src="url" class="margin1 imagem-logo "/>
          <img v-if="this.url2 != ''" :src="url2" class="margin1 imagem-logo "/>

        </div>

        <div class="text-h3 text-bold row justify-center items-center self-center margin1">
          <div class="col justify-center items-center self-center text-center text-italic margin1 padding1">
            {{apresenta}}
          </div>
        </div>  

        <br>
       
        <div class="row  justify-center items-center self-center text-bold" style="width:100vw">
          <q-card class="card-name esquerda">
             <div class="text-h2 esquerda cor-fundo">
               <h3>{{ds_visitante}}</h3>
             </div>
             
          </q-card>    
                
        </div>    
         
      </div>
    
    </q-card>
  </q-dialog>



</div>
</template>

<script>
import notify from 'devextreme/ui/notify';
import formataData from '../http/formataData'
import Incluir from '../http/incluir_registro';
import Data from '../http/dataEscrita';

export default {

  data(){
    return{
      dt_visita               : '',
      date                    : '',
      nm_caminho_logo_empresa : '',
      nm_visitante            : '',
      ds_visitante            : '',
      url                     : '',
      url2                    : '',
      nm_fantasia_empresa     : '',
      popup                   : true,
      maximizedToggle         : true,
      api                     : '687/1027',
      data_escrita            : '',
      apresenta               : ''

    }
  },

  created(){
    let log = localStorage.nm_caminho_logo_empresa;
    var data = new Date();
    var dia = String(data.getDate()).padStart(2, '0');
    var mes = String(data.getMonth() + 1).padStart(2, '0');
    var ano = data.getFullYear();
    let dataAtual = dia + '/' + mes + '/' + ano;

    let dayName = new Array ("Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado")
    let monName = new Array ("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Agosto", "Outubro", "Novembro", "Dezembro")
    let now = new Date
    this.data_escrita = dayName[now.getDay()] + ', ' + now.getDate() +' de ' + monName[now.getMonth()] + ' de ' + now.getFullYear() 
    this.dt_visita = dataAtual;
    this.carregaDados()
  },

  mounted(){
    this.$q.fullscreen.toggle();
  },

  methods:{
    
    async carregaDados(){
      let dt = formataData.formataDataSQL(this.dt_visita); 
      let d ={
        "cd_parametro" : 1,
        "dt_visita"    : dt
      }
      var up = await Incluir.incluirRegistro(this.api,d);
      let teste = up[0].ds_visitante;
      let t = teste.includes("\r\n")
      let l = teste.includes(",")
      if(t == true || l == true){
        this.apresenta = 'Sejam bem vindo!'
      }else{
        this.apresenta = 'Seja bem vindo!'
      }
      if(up[0].Cod == 0){
        notify(up[0].Msg);
        return
      } 

      this.url = up[0].nm_caminho_logo_empresa;
      //this.url2 = 'http://www.egisnet.com.br/img/logo_gbstec_sistema.jpg'
      this.url2 = up[0].nm_local_imagem2;
      this.ds_visitante = up[0].ds_visitante.trim()
      //this.ds_visitante = this.ds_visitante.split(',').sort();

      this.nm_fantasia_empresa = up[0].nm_fantasia_empresa;
     
    },
    ClickButton(){
      this.carregaDados();
      this.popup = true;      
    },
    
  }

}
</script>

<style scoped>



.margin1{
  margin: 0.6vw 0.7vw ;
}
.padding1{
  padding: 1vw 0.5vw;
}
.qdate{
  width: 310px;
  overflow-x: hidden;
}

.borda-bloco{
    box-shadow: 1px 2px 2px rgb(197, 197, 197) !important;
    border: solid 1px rgb(170, 170, 170) ;
    border-radius: 10px !important;
    height: auto;
    max-height: 80%;
}
.campo-largura{
  /*width: auto;
  margin-left: 40vw;
  margin-right: 40vw;
  display: block;*/
}
li {
  list-style-type: none;
}
.visita{
  height: 250px;
  width: 600px;
  font-size: 34px;
  line-height: 40px !important;
  border: 1px solid white;
  border-radius: 5px;
  
}
.card-name{
  height: auto;
  width:auto;
  padding: 5px;
  max-width: 85vw;
}
.esquerda {
    float: left;   
    right: 10px;
    text-align: left;
    margin-left: 1px;
    margin-right: 1px;
    padding-left: 1px;
    padding-right: 1px;
    text-align: left;
    color: black;  
}
.cor-fundo {
  background-color: rgb(104, 187, 241);  
}
.imagem-logo{
  margin-top: 15px;
  height: 12vw; 
  width: 20vw;
  border-radius: 20px;
  
}
.card-tudo{
  max-height: 80vw;
}
</style>