<template>
<div>
    <div class="titulo-btn">
        <h2 class="content-block titulo-btn">{{tituloMenu}} </h2>
     <DxButton  
       v-if="!longtabs[selectedIndex].id == 1"
       class="botao-info" 
       icon='event'      
       text=""  
       @click="popClickData()"
     />
    </div>

  <DxTabs class="dx-card wide-card tabPanel select-menu-tab" 
        :data-source="longtabs"
        :v-model="selectedIndex"
        :selected-index.sync="selectedIndex"
        @item-click="tabPanelTitleClick"
  />

  <grid
    v-if="longtabs[selectedIndex].id == 0"
    :cd_menuID="7089"
    :cd_apiID="487"
    ref="gridDados"
  />

  <div v-if="longtabs[selectedIndex].id == 1" class="input_dados_parcelas">
        <q-card class="card-parcela">
            <q-item-label @click="dados_contrato = true" class="text-h6" overline><b> CONTRATO: {{ parcelas[0].cd_contrato }} | FICHA DE VENDA: {{parcelas[0].cd_ficha_contrato}} </b>  <q-tooltip>Clique para mais informações do Contrato</q-tooltip></q-item-label>
            <q-item-label class="text-h6" overline><b style="text-transform: uppercase;" > STATUS: {{ parcelas[0].nm_status_contrato }}</b></q-item-label>
            <q-item>
              <q-item-section>
                <!--<q-item-label>CLIENTE:        {{ parcelas[0].nm_fantasia_cliente }}   </q-item-label> 
                <q-item-label>ADMINISTRADORA: {{ parcelas[0].nm_administradora }}     </q-item-label> 
                <q-item-label>VALOR: R$       {{ vl_contrato }}                       </q-item-label> 
                <q-item-label>VENDEDOR:       
                    <q-item-label v-for="i in parseInt(vendedores.length)" v-bind:key="i">
                        {{vendedores[i-1].nm_fantasia_vendedor }} 
                    </q-item-label>
                </q-item-label>-->
                <q-item> <q-input class="col cd_grupo_cota" v-model="cd_grupo_contrato" label="Grupo"/>          </q-item>
                <q-item> <q-input class="col cd_grupo_cota" v-model="cd_cota_contrato"  label="Cota"/>           </q-item>
                <q-item> <q-input class="col cd_grupo_cota" v-model="nm_ref_contrato"  label="Nº do Contrato"/>  </q-item>
              </q-item-section>
            </q-item>
                <DxButton
                v-if="parcelas[0].cd_status_contrato != 10"
                  class="buttons-column save-button"
                  :width="300"
                  text="Efetivar Contrato"
                  type="default"
                  styling-mode="contained"
                  horizontal-alignment="left"
                  @click="onSalvarDados()"
                />
        </q-card>
        <div v-if="parcelas[0].cd_status_contrato == 10">
          <div class="button-parcela row" v-for="n in parseInt(parcelas.length)" v-bind:key="n">
            <q-btn color="green" v-if="parcelas[n-1].dt_pagamento_parcela != null" disable :label="n+ 'ª Parcela'" />
            <q-btn color="red" v-if="parcelas[n-1].dt_pagamento_parcela == null" disable :label="n+ 'ª Parcela'" />

            <DxTextBox v-if="parcelas[n-1].dt_parc_contrato != null" :name="'data'+n" :value="parcelas[n-1].dt_parc_contrato" class="col input_dados_parcelas" :placeholder="'Vencimento da ' + n + 'ª Parcela'"/>
            <DxTextBox v-if="parcelas[n-1].dt_parc_contrato == null" :name="'data'+n" class="col input_dados_parcelas" :placeholder="'Vencimento da ' + n + 'ª Parcela'"/>

            <DxTextBox v-if="parcelas[n-1].dt_pagamento_parcela != null" :name="'data_pag'+n" :value="parcelas[n-1].dt_pagamento_parcela" fill-mask mask="##/##/####" class="col input_dados_parcelas" :placeholder="'Pagamento da ' + n + 'ª Parcela'" />
            <DxTextBox v-if="parcelas[n-1].dt_pagamento_parcela == null" :name="'data_pag'+n"  class="col input_dados_parcelas" :placeholder="'Pagamento da ' + n + 'ª Parcela'" />  


          </div>
           <DxButton
            class="buttons-column save-button"
            :width="120"
            icon="save"
            text="Salvar"
            type="default"
            styling-mode="contained"
            horizontal-alignment="left"
            @click="onSalvarDados()"
          />
        </div>
      </div>
       
     
    <div v-if="popupData == true">
      <q-dialog v-model="popupData">
        <q-card>
          <q-card-section class="row items-center q-pb-none">
            <div class="text-h6">Seleção de Data</div>
            <q-space />
            <q-btn icon="close" @click="popClickData()" flat round dense v-close-popup />
          </q-card-section>

          <selecaoData
          :cd_volta_home="1">
          </selecaoData>

        </q-card>
      </q-dialog>
    </div>  

  <div v-if="dados_contrato == true">
    <q-dialog v-model="dados_contrato" full-width >
      <q-card>
        <q-card-section>
          <div class="text-h6">DADOS DO CONSÓRCIO</div>
        </q-card-section>      
        <q-separator />
        <q-card-section>
          <q-item-label class="text-h6" overline>NÚMERO DO  CONTRATO: {{ parcelas[0].cd_contrato }}</q-item-label>
          <q-item style="height: 50%">
            <q-item-section class="bordas">
              <q-item-label>Contrato</q-item-label>
              <q-item-label caption>
                <b class="b" overline>Data:           </b> {{dt_contrato}}                             <br>
                <b class="b" overline>Valor:          </b> R$ {{dados_ficha_venda[0].vl_contrato}}     <br>
                <b class="b" overline>Administradora: </b> {{dados_ficha_venda[0].nm_administradora}}  <br>
                <b class="b" overline>Tabela:         </b> {{dados_ficha_venda[0].nm_tabela}}          <br>
                <b class="b" overline>Equipe:         </b> {{dados_ficha_venda[0].nm_fantasia_equipe}} <br>
                <b class="b" overline>Seguro:         </b> {{dados_ficha_venda[0].ic_seguro_contrato}} <br>
              </q-item-label>
            </q-item-section>
            <q-item-section class="bordas">
              <q-item-label>Cliente</q-item-label>
              <q-item-label caption>
                <b class="b" overline>Nome: </b> {{dados_ficha_venda[0].nm_razao_contrato}}  <br>
                <b class="b" overline>CNPJ/CPF: </b> {{dados_ficha_venda[0].cd_cnpj_cpf_contrato}} 
              </q-item-label>
            </q-item-section>
            <q-item-section v-if="parseInt(dados_ficha_venda.length) == 2" class="bordas">
              <q-item-label>Dados Sócio</q-item-label>
              <q-item-label caption>
                <b class="b" overline>Nome: </b> {{dados_ficha_venda[1].nm_razao_contrato}} <br>
                <b class="b" overline>CPF:  </b> {{dados_ficha_venda[1].cd_cnpj_cpf_contrato}}
              </q-item-label>
            </q-item-section>
            <q-item-section class="bordas">
            <q-item-label>Vendedores</q-item-label>
            <q-item-label caption>
              <label overline class="b" v-for="i in parseInt(vendedores.length)" v-bind:key="i">
                {{vendedores[i-1].nm_fantasia_vendedor }} <br>
              </label> 
            </q-item-label>
            </q-item-section>
          </q-item>
        </q-card-section>    
      </q-card>
    </q-dialog>
  </div>
</div>
</template>
<script>
import grid from '../views/grid.vue'
import Menu from '../http/menu'
import config from 'devextreme/core/config'
import { formatNumber, loadMessages, locale } from 'devextreme/localization'
import ptMessages from "devextreme/localization/messages/pt.json";

import DxTabs from 'devextreme-vue/tabs';
import DxSelectBox from 'devextreme-vue/select-box';
import DxTextBox from 'devextreme-vue/text-box';
import DxButton from 'devextreme-vue/button';

import Procedimento from '../http/procedimento'
import Incluir from '../http/incluir_registro'
import formataData from '../http/formataData'
import notify from 'devextreme/ui/notify'
import selecaoData from '../views/selecao-periodo.vue'
import alterar_registro from '../http/alterar_registro'

var dados = [];
var sParametroApi = '';

export default {

data() {
      return {
          longtabs: [
                       { text: 'Contratos', id:  0},
                       { text: 'Dados', id:  1 }
                    ],
            selectedIndex: 0,
            tituloMenu: 'Menu Efetivação e Pagamentos',
            parcela_selecionada: '',
            parcelas: [],

            cd_empresa: 0,
            cd_cliente: 0,
            cd_menu: 0,
            cd_api: 0,
            api: '',
            cd_contrato: 0,
            vendedores: [],
            cd_grupo_contrato: '',
            cd_cota_contrato : '',
            popupData: false,
            nm_ref_contrato: '',
            cd_status_contrato: 0,
            nm_status_contrato: '',
            vl_contrato: '',
            dados_contrato: false,
            dados_ficha_venda: [],
            dt_contrato: ''
      }
    },
    computed:{
  },

    async created(){
        config({ defaultCurrency: 'BRL' });
        loadMessages(ptMessages);
        locale(navigator.language); 

        this.cd_empresa = localStorage.cd_empresa;
        this.carregaDados();
    },

  components: {
      grid,
      DxTabs,
      DxSelectBox,
      DxTextBox,
      DxButton,
      selecaoData
  },

  methods:{
    async carregaDados(){

        this.cd_empresa           = localStorage.cd_empresa;
        this.cd_cliente           = localStorage.cd_cliente;
        this.cd_menu              = localStorage.cd_menu;
        this.cd_api               = localStorage.cd_api;
        this.api                  = localStorage.nm_identificacao_api;

        dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api)
        sParametroApi = dados.nm_api_parametro;
        console.log('DADOS:',dados)
    },

    async carregaDatas(){
        var contrato = this.parcela_selecionada.cd_contrato 
        console.log(contrato)
        localStorage.cd_parametro = contrato
            this.cd_contrato = contrato
            
            this.parcelas = await Procedimento.montarProcedimento(
                this.cd_empresa,
                this.cd_cliente,
                this.api,
                sParametroApi
            )

            console.log(this.parcelas)
            try{
              this.vendedores = this.parcelas[0].nm_vendedores;
              this.vendedores = JSON.parse(this.vendedores);
              console.log(this.vendedores)
            }
            catch{
                //alert('tentei')
            }

            this.cd_grupo_contrato = this.parcelas[0].cd_grupo_contrato;
            this.cd_cota_contrato  = this.parcelas[0].cd_cota_contrato;
            this.nm_ref_contrato   = this.parcelas[0].nm_ref_contrato;

            this.vl_contrato = this.parcelas[0].vl_contrato.replace('.','').replace(',','')
            this.formatarMoeda();

    
            var a = 0
            for(a = 0; a < this.parcelas.length; a++){ 
                var data_venc = this.formataDataJS(this.parcelas[a].dt_parc_contrato)
                this.parcelas[a].dt_parc_contrato = data_venc
    
                console.log(this.parcelas[a].dt_pagamento_parcela)
                if(this.parcelas[a].dt_pagamento_parcela != null){
                    var data_pag = this.formataDataJS(this.parcelas[a].dt_pagamento_parcela)
                    this.parcelas[a].dt_pagamento_parcela = data_pag
                }
            }
    },

    formatarMoeda() {
      
      // var elemento = vl.toString();
      var valor = this.vl_contrato;

      valor = valor + '';
      valor = parseInt(valor.replace(/[\D]+/g, ''));
      valor = valor + '';
      valor = valor.replace(/([0-9]{2})$/g, ",$1");

      if (valor.length > 6) {
          valor = valor.replace(/([0-9]{3}),([0-9]{2}$)/g, ".$1,$2");
      }

      this.vl_contrato = valor;
    },

    async ConsultaDadosContrato(){
      localStorage.cd_parametro = 1
      localStorage.cd_identificacao = this.parcela_selecionada.cd_ficha_contrato;
      var api_consulta_dados = '442/597'
      var parametrosApi      =  '/${cd_empresa}/${cd_parametro}/${cd_usuario}/${cd_identificacao}'

      this.dados_ficha_venda = await Procedimento.montarProcedimento(this.cd_empresa,this.cd_cliente,api_consulta_dados,parametrosApi)
      this.dt_contrato = formataData.formataDataJS(this.dados_ficha_venda[0].dt_contrato)
      //alert(this.dt_contrato)
      console.log('DADOS CONTRATO ',this.dados_ficha_venda)
    },

    async tabPanelTitleClick(){

        this.parcela_selecionada = grid.Selecionada();
        var contrato = this.parcela_selecionada.cd_contrato 

        if(this.selectedIndex == 1){
            await this.carregaDatas();
            await this.ConsultaDadosContrato()
        } 
        else{
            this.parcela_selecionada = [];
            this.parcelas            = [];
            this.vendedores          = [];
            this.cd_grupo_contrato   = [];
            this.cd_cota_contrato    = [];
        }

    },
    formataDataJS(datas){
        let formatada = datas.toString().replaceAll('-','')
        console.log(formatada)
        var ano  = formatada.substring(0,4)
        var mes  = formatada.substring(4,6)
        var dia  = formatada.substring(6,8)
        //console.log(dia + '/' + mes + '/' + ano)
        return dia + '/' + mes + '/' + ano    
    },
    popClickData(){
      if(this.popupData == false){
        this.popupData = true;
   
       
      }
      else{
        this.popupData = false;
        this.$refs.gridDados.carregaDados()
      }
    },

    formataDataSQL(datas){
        let formatada = datas.toString()
        var ano  = formatada.substring(4,8)
        var mes  = formatada.substring(2,4)
        var dia  = formatada.substring(0,2)
        console.log(mes + '-' + dia + '-' + ano)
        return mes + '-' + dia + '-' + ano    
    },

    async onSalvarDados(){
        var api_incluir = '490/693'
        
        if(this.parcelas[0].cd_status_contrato != 10){
          var dados = {
              "cd_item_contrato"  : 1,
              "cd_contrato"       : this.parcela_selecionada.cd_contrato,
              "cd_cota_contrato"  : parseInt(this.cd_cota_contrato),
              "cd_grupo_contrato" : parseInt(this.cd_grupo_contrato),
              "nm_ref_contrato"   : this.nm_ref_contrato
            } 

            console.log(dados);

            var s = await Incluir.incluirRegistro(api_incluir, dados);
            console.log(s)
            await this.carregaDatas();
        }
        else{
          var a = 0
          for(a = 0; a < this.parcelas.length; a++){ 
              var dt_base          = this.formataDataSQL(document.getElementsByName('data_pag'+(a+1))[0].value.replaceAll('/',''));
              var dt_processo      = this.formataDataSQL(document.getElementsByName('data'+(a+1))[0].value.replaceAll('/',''));
  
              if(dt_base == '--'){
                  dt_base = null
              }
  
              var dados = {
                "cd_contrato"       : this.parcela_selecionada.cd_contrato,
                "cd_item_contrato"  : (a + 1),
                "dt_pagamento"      : dt_base,
                "cd_cota_contrato"  : parseInt(this.cd_cota_contrato),
                "cd_grupo_contrato" : parseInt(this.cd_grupo_contrato),
                "dt_parc_contrato"  : dt_processo
              } 
  
              console.log(dados);
  
              var s = await Incluir.incluirRegistro(api_incluir, dados);
              console.log(s)
          }
          notify('Pagamento Confirmado com sucesso!')
  
          await this.carregaDatas();
        }
    },

  }
}
</script>

<style>
.input_dados_parcelas{
    margin: 10px;

}

.card-parcela{
    padding-top: 15px;
    margin-bottom: 15px;
    text-align: center;
    font-size: 16px;
}

.text-h6{
    font-size: 15px;
}

.button-parcela{
    margin: 5px;
}
.select-menu-tab{
    width: 98%;
}

.cd_grupo_cota{
    padding: 10px;
}
.titulo-btn{
    display: inline;
}
.botao-info{
    margin-top: 15px;
}
.save-button{
    margin-left: 15px;
}

.bordas{
  border-left: 6px solid rgb(255, 148, 148);
  background-color: rgb(255, 255, 255);
  height: 100%;
}

.b{
  margin-left: 15px;
}

</style>