<template>
<div>
<div class="sidebar">
  <div class="q-pa-md">
    <q-list bordered class="rounded-borders">
      <q-expansion-item>
        <template v-slot:header>
          <q-item-section avatar>
            <q-avatar icon="perm_identity" color="primary" text-color="white" />
          </q-item-section>

          <q-item-section>
            Pessoas
          </q-item-section>

        </template>
        <q-card class="my-card" flat bordered>
          <q-card-section horizontal>
            <q-card-section class="q-pt-xs">
              <div class="text-h5 q-mt-sm q-mb-xs">Ranking</div>
              <div class="text-caption text-grey">
                <div> Carlos C. F.</div>
                <div> Alexandre</div>
                <div> Mateus D. D.</div>
              </div>
            </q-card-section>
            <q-btn @click="onAdicionarCliente()" class="botao_adiciona" color="primary" icon="add"/>
          </q-card-section>
        </q-card>
      </q-expansion-item>

      <q-separator />

      <q-expansion-item>
        <template v-slot:header>
          <q-item-section avatar>
            <q-avatar icon="drafts" color="primary" text-color="white" />  
          </q-item-section>

          <q-item-section>
            Contratos
          </q-item-section>
        </template>

        <q-card class="my-card" flat bordered>
          <q-card-section horizontal>
            <q-card-section class="q-pt-xs">
              <div class="text-h5 q-mt-sm q-mb-xs">Ranking</div>
              <div class="text-caption text-grey">
                  <div> Contrato 1 </div>
                  <div> Contrato 2 </div>
                  <div> Contrato 3 </div>
              </div>
            </q-card-section>
            <q-btn @click="onCadastroProposta()" class="botao_adiciona" color="primary" icon="add"/>
          </q-card-section>
        </q-card>
      </q-expansion-item>
    </q-list>
  </div>
</div>


<div v-if="mostra_cadastro_cliente == true" class="cadastro">
  <cadastro/>      
</div>


<div v-if="mostra_cadastro_proposta == true" class="cadastro">
  <consorcio/>
</div>


</div>

</template>

<script>
import Procedimento from '../http/procedimento';
import Menu from '../http/menu'
import config from 'devextreme/core/config';
import { loadMessages, locale } from 'devextreme/localization';
import notify from 'devextreme/ui/notify';
import ptMessages from "devextreme/localization/messages/pt.json";
import DxButton from 'devextreme-vue/button';

import cadastro from '../views/cliente.vue';
import consorcio from '../views/cadastro-contrato-consorcio.vue';


import { ref } from 'vue'

import Incluir from '../http/incluir_registro';
import Lookup from '../http/lookup';

var dados = [];
var sParametroApi = '';
var api = '';

export default {
  setup(){ return{ red: ref(true) }},
  data() {
    return {
      meta: [ {charset: 'uft-8' },
              { equiv: 'Content-Type', content: 'text/html' },
              { name: 'viewport', content: 'width=device-width, initial-scale=1' }
            ],
      dataSourceConfig: [],
      tituloMenu         : '',
      dt_inicial         : '',
      dt_final           : '',       
      columns            : [],
      pageSizes          : [10, 20, 50, 100],         
      dataSourceConfig   : [],
      total              : {},       
      dataGridInstance   : null,
      showIndicator      : true,
      showPane           : true,
      taskSubject        : 'Descritivo',
      taskDetails        : '',
      temD               : false,
      temPanel           : false,
      cd_menu_destino    : 0,
      cd_api_destino     : 0,
      qt_tempo           : 0,
      polling            : 60000,
      exportar           : false,
      buttonOptions      : {
        text: 'Confirmar',
        type: 'success',
        useSubmitBehavior: true
      },
      dateBoxOptions     : {
        invalidDateMessage:
          'Data tem estar no formato: dd/mm/yyyy'
      },
      cd_empresa          : 0,
      cd_menu             : 0,     
      cd_cliente          : 0,
      cd_api              : 0,
      api                 : 0,
      cd_menu_origem      : 0,
      cd_api_origem       : 0,
      ds_arquivo          : '',
      ds_menu_descritivo  : '',
      popupVisible        : false,
      periodoVisible      : false,
      ic_form_menu        : 'N',
      ic_form_menu_prox   : 'N',
      formData            : {},

      mostra_cadastro_cliente: false,
      mostra_cadastro_proposta: '',

     red: false,
      
    };
  },

  computed:{
  },

    async created(){
        config({ defaultCurrency: 'BRL' });
        loadMessages(ptMessages);
        locale(navigator.language); 
    },

  components: {
      cadastro,
      DxButton,
      consorcio
  },
  methods:{
    onAdicionarCliente(){
      if(this.mostra_cadastro_cliente == false){
        this.mostra_cadastro_cliente = true;
      }
      else{
        this.mostra_cadastro_cliente = false
      }
    },
    onCadastroProposta(){
      if(this.mostra_cadastro_proposta == false){
        this.mostra_cadastro_proposta = true;
      }
      else{
        this.mostra_cadastro_proposta = false
      }
    }
  }
}

</script>

<style>
.sidebar {
  width: 25%;
  margin-left: 15px;
  margin-top: 10px;
  height: 100%;
  float: left;
}
.cadastro{
    width: 70%;
    float: right;
    margin-right: 25px;
}

.input_endereco{
  width: 22%;
}

.input{
  width: 100%;
  margin-left: 15px;
}
.btn{
  margin-left: 25px;
  margin-top: 15px;
}

.botao_adiciona{
  width: 30px;
  height: 30px;
  position: absolute;
  right: 0;
  margin-right: 10px;
  margin-top: 10px;
}


</style>