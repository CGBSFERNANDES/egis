<template>
<div>
    <h2 class="content-block">{{tituloMenu}}</h2>
   <div class="q-pa-md">
    <q-stepper
      v-model="step"
      vertical
      color="primary"
      animated
    >
      <q-step
        :name="1"
        title="1-"
        icon="search"
        :done="step > 1"
        active-icon="search"
      >
        <q-banner class="bg-primary text-white q-px-lg">
          <h2>Em relação ao atendimento nesta unidade hoje</h2>
        </q-banner>
        <q-rating
          v-model="resposta1"
          :max="4"
          size="7em"
          color="green-5"
          :icon="icons"
          :color-selected="cores"
        />

        <q-stepper-navigation>
          <q-btn @click="step = 2" color="primary" label="Próxima" />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="2"
        title="2-"
        icon="search"
        :done="step > 2"
        active-icon="search"
      >
        <q-banner class="bg-primary text-white q-px-lg">
          <h2>Quando ao atendimento de maneira Geral nesta unidade ?</h2>
        </q-banner>
        <q-rating
          v-model="resposta2"
          :max="4"
          size="7em"
          color="green-5"
          :icon="icons"
          :color-selected="cores"
        />

        <q-stepper-navigation>
          <q-btn @click="step = 3" color="primary" label="Próxima" />
          <q-btn @click="step = 1" color="primary" label="Anterior" />
        </q-stepper-navigation>
      </q-step>

      <q-step
        :name="3"
        title="3-"
        icon="search"
        :done="step > 3"
        active-icon="search"
      >
        <q-banner class="bg-primary text-white q-px-lg">
          <h2>Quando ao atendimento de maneira Geral nesta unidade ?</h2>
        </q-banner>
        <q-rating
          v-model="resposta3"
          :max="4"
          size="7em"
          color="green-5"
          :icon="icons"
          :color-selected="cores"
        />
        <q-stepper-navigation>
          <q-btn @click="OnChange()" color="primary" label="Finalizar" />
        </q-stepper-navigation>
      </q-step>        
    </q-stepper>
  </div>
  <div v-if="this.cd_carrega == true">
    <q-dialog v-model="cd_carrega">
      <q-card>

          <q-card-section>
            <h6>Obrigado por responder o questionário...</h6>
          </q-card-section>
          <q-card-section style="text-align: center">
            <q-spinner-ios color="primary" size="5em"></q-spinner-ios>
          </q-card-section>
          
      </q-card>
    </q-dialog>
  </div>
</div>
</template>

<script>

var dados = [];
var sParametroApi = '';

import Menu from '../http/menu'
import Procedimento from '../http/procedimento'

import Incluir from '../http/incluir_registro'

export default {
    data(){
        return{
            step:1,
            resposta1: 0,
            
            tituloMenu : '',
            menu       : '',
            cd_empresa :  0,
            cd_menu    :  0,     
            cd_cliente :  0,
            cd_api     :  0,
            api        :  0,

            dataSourceConfig: [],

            questao1: [],
            questao2: [],
            questao3: [],


            resposta1 :0,
            resposta2 :0,          
            resposta3 :0,

            cores: [ 'positive', 'warning', 'orange-7', 'negative' ],
            
            icons: [
                'sentiment_very_satisfied',
                'sentiment_satisfied',
                'sentiment_dissatisfied',
                'sentiment_very_dissatisfied'
            ],

            qt_questoes: 0,

            cd_carrega: false,

        }
    },
    created(){
       
    },
    mounted(){
        this.carregaDados();
    },
    methods:{
        async carregaDados(){
            this.cd_empresa      = localStorage.cd_empresa;
            this.cd_cliente      = localStorage.cd_cliente;
            this.cd_menu         = localStorage.cd_menu;
            this.cd_api          = localStorage.cd_api;
            this.api             = localStorage.nm_identificacao_api;
            dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); 
            //console.log(dados)

            this.tituloMenu = dados.nm_menu_titulo; 
            sParametroApi   = dados.nm_api_parametro;
            let sApi        = sParametroApi;

            localStorage.cd_parametro = 1;
            //this.dataSourceConfig = await Procedimento.montarProcedimento(this.cd_empresa,this.cd_cliente,this.api,sApi)
            //this.qt_questoes = this.dataSourceConfig.length;
            //this.alternativas = JSON.parse(JSON.parse(JSON.stringify(this.dataSourceConfig[0].alternativas)));
            //console.log(this.alternativas);

            //this.montarObjetos();
        },
        async OnChange(){
            this.cd_carrega = true;
            let api = '470/659'
            console.log('RESPOSTA 1',this.resposta1)
            let dados1 = {
                "cd_pesquisa": 1,
                "cd_item_pesquisa": 1,
                "cd_alternativa_pesquisa": this.resposta1
            }

            console.log(dados1);

            let includ1 = await Incluir.incluirRegistro(api,dados1);
            console.log(includ1);

            let dados2 = {
                "cd_pesquisa": 1,
                "cd_item_pesquisa": 2,
                "cd_alternativa_pesquisa": this.resposta2
            }
            console.log(dados2);
            let includ2 = await Incluir.incluirRegistro(api,dados2);
            console.log(includ2);
            

            let dados3 = {
                "cd_pesquisa": 1,
                "cd_item_pesquisa": 3,
                "cd_alternativa_pesquisa": this.resposta3
            }
            console.log(dados3);
            let includ3 = await Incluir.incluirRegistro(api,dados3);
            console.log(includ3);

            this.resposta1 = 0;
            this.resposta2 = 0;
            this.resposta3 = 0;

            this.cd_carrega = false;
            this.step = 1;
        },

        montarObjetos(){
            let i = 0;
            let dado    = JSON.parse(this.dataSourceConfig[0].nm_alternativas);
            console.log(dado)
            let tamanho = dado.length;

            for(i = 0; i != tamanho; i++ ){
                if(dado[i].cd_item_questao_pesquisa == 1){
                    var a = this.questao1.length;
                    this.questao1[a] = dado[i];
                }
                if(dado[i].cd_item_questao_pesquisa == 2){
                    var a = this.questao2.length;
                    this.questao2[a] = dado[i];
                }
                if(dado[i].cd_item_questao_pesquisa == 3){
                    var a = this.questao3.length;
                    this.questao3[a] = dado[i];
                }
            }
            console.log(this.questao1)
            console.log(this.questao2)
            console.log(this.questao3)
        }

    }
}
</script>

<style>

</style>