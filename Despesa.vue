<template>
<div>
    <div class="tela-celular borda-bloco shadow-2 bg-white margin1">
         <!--=====================================================CONSULTA=========================================================-->
        <div v-if="ic_consulta == true" style="margin:0;padding:0">
            <div class="row items-center">
                <div class="text-h6 text-bold margin1 col-8">
                    {{titulo_menu}}
                </div>

                <div class="col-3 margin1 items-end">

                    <q-btn round color="orange-10" icon="add" size="sm" style="float:right; margin:2px" @click="NovaDespesa()">
                        <q-tooltip transition-show="scale" transition-hide="scale">
                            Nova Despesa
                        </q-tooltip>
                    </q-btn>
                    <!--<selecaoData  :cd_volta_home="1" />-->
                    <q-btn @click="popupData = true" icon="event" color="orange-10" round size="sm" class="cursor-pointer" style="float:right; margin:2px">
                        <q-tooltip transition-show="scale" transition-hide="scale">
                            Alterar Período
                        </q-tooltip>
                    </q-btn>

                </div>
            </div>

            <div class="margin1" v-show="hoje.to != ''">
                {{hoje.from}} até {{hoje.to}}
            </div>

            <!--<q-input class="margin1" v-model="hoje" type="text" label="Data">
                <template v-slot:prepend>
                    <q-icon name="event" />
                </template>
                <template v-slot:append>

                </template>
            </q-input>-->

            <div v-if="dataSourceConfig.length > 0">
                <div class="text-h6 margin1">
                    Prestações em aberto
                </div>
                <div class="margin1 tela-celular">
                
                        <div v-for="(e, index) in dataSourceConfig" :key="index" class="margin1 text-subtitle2">    
                            <div class="row items-center">
                                <div class="col-2">
                                    <q-avatar :color="e.nm_cor_badge" class="text-white" size="md">
                                       {{e.nm_status}}<!--{{index+1}}{{e.sg_tipo_prestacao}}-->
                                        <q-tooltip v-if="e.nm_status == 'A'" transition-show="scale" transition-hide="scale">
                                            Aprovado
                                        </q-tooltip>
                                        <q-tooltip v-else transition-show="scale" transition-hide="scale">
                                            Negado
                                        </q-tooltip>
                                    </q-avatar>
                                </div>
                                <div class="col-8">
                                    {{e.nm_fantasia_funcionario}}
                                    <!--<q-badge :color="e.nm_cor_badge" rounded align="top">
                                       {{e.sg_tipo_prestacao}}
                                    </q-badge>-->
                                    <br>
                                    {{e.vl_prestacao}} - {{e.dt_pagamento_prestacao}}
                                </div>
                                <div class="col-2">
                                    <q-btn round color="orange-10" icon="east" flat size="md">
                                        <q-tooltip transition-show="scale" transition-hide="scale">
                                            Solicitar aprovação
                                        </q-tooltip>
                                    </q-btn>
                                </div>

                            </div>  
                            <!--<div class="col-4">
                                teste
                            </div>       -->


                            <q-separator spaced/>
                        </div>

                </div>



            </div>

             <div v-else class="text-h6 margin1">
                Período sem Despesas!
            </div>
        </div>
        <!--=====================================================CADASTRO=========================================================-->
        <div v-if="ic_cadastro == true">
            <div class="row items-center">
                <q-btn round color="orange-10" icon="reply" flat size="md" @click="VoltaConsulta()">
                    <q-tooltip transition-show="scale" transition-hide="scale" >
                        Voltar
                    </q-tooltip>
                </q-btn>
                <div class="text-h6 text-bold margin1 ">
                    {{titulo_cadastro}}
                </div>
            </div>

                <q-select
                    label="Despesa"
                    class="margin1"
                    v-model="tipo_despesa"
                    input-debounce="0"
                    :options="this.dataset_despesa"
                    option-value="cd_tipo_despesa"
                    option-label="nm_tipo_despesa"
                >
                    <template v-slot:prepend>
                        <q-icon name="store" />
                    </template>
                </q-select>

                <q-input v-model="ds_despesa" type="text" class="margin1" autogrow label="Descrição">
                    <template v-slot:prepend>
                        <q-icon name="description"/>                    
                    </template>
                </q-input>
                
                 <q-input v-model="vl_item_despesa" type="text" @blur="onCalculaTotal()" class="margin1" label="Valor">
                    <template v-slot:prepend>
                        <q-icon name="monetization_on"/>                    
                    </template>
                </q-input>

                <q-input v-model="qt_item_despesa" type="number" class="margin1" label="Quantidade">
                    <template v-slot:prepend>
                        <q-icon name="shopping_cart"/>                    
                    </template>
                </q-input>

                <q-file v-model="arquivos" label="Comprovante" class="margin1">
                    <template v-slot:prepend>
                        <q-icon name="attach_file" />
                    </template>
                </q-file>
                <div class="row margin1">
                    <q-btn rounded color="positive" icon="check" class="margin1" size="md" style="float:right" label="Confirmar"/>
                </div>
            
            
        </div>


        <!--=====================================================LOADING=========================================================-->

        <q-dialog v-model="load" maximized persistent >
            <carregando :mensagemID="mensagem"></carregando>
        </q-dialog>

        <!--=====================================================DATA=========================================================-->
        <q-dialog v-model="popupData" persistent>
            <q-card style="margin:0;padding:0">
                <q-card-section class="row items-center q-pb-none">
                    <div class="text-h6">Seleção de Data</div>
                    <q-space />
                    <q-btn icon="close" @click="carregaDados()" flat round dense v-close-popup />
                </q-card-section>
                <selecaoData :cd_volta_home="1" />
            </q-card>
      </q-dialog>
   </div>
</div>
</template>

<script>
import formataData from '../http/formataData'
import selecaoData from '../views/selecao-periodo.vue';
import Incluir from '../http/incluir_registro';
import Menu from '../http/menu';
import notify from 'devextreme/ui/notify';
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from 'devextreme/core/config';
import carregando from '../components/carregando.vue';
import Lookup from '../http/lookup';



export default {
    name: 'despesa',
    data(){
        return{
            hoje             :{from: '', to: '' },
            cd_menu          : 0,
            cd_empresa       : 0,
            cd_api           : 0,
            titulo_menu      : '',
            vl_item_despesa  : '',
            api              : '',
            data_SQL         : '',
            qt_item_despesa  : '',
            cd_usuario       : 0,
            popupData        : false,
            dataSourceConfig : [],
            ic_consulta      : true,
            ic_cadastro      : false,
            carregando       : false,
            load             : false,
            mensagem         : '',
            titulo_cadastro  : 'Nova Despesa' ,
            dataset_despesa  : [],
            dados_despesa    : [],
            tipo_despesa     : '',
            ds_despesa       : '',
            arquivos         : [],



        }
    },
    async created(){
        config({ defaultCurrency: 'BRL' });  
        loadMessages(ptMessages);
        locale(navigator.language); 
        this.cd_empresa = localStorage.cd_empresa;
        this.cd_menu    = localStorage.cd_menu;
        this.cd_api     = localStorage.cd_api;
        this.cd_usuario = localStorage.cd_usuario;
      
        if(localStorage.dt_inicial.length < 10){
            localStorage.dt_inicial = '0'+localStorage.dt_inicial
        }

        this.hoje = {
            from : this.ArrumaData(localStorage.dt_inicial),
            to   : this.ArrumaData(localStorage.dt_final)
        }
    },
    async mounted(){
        this.mensagem = 'Carregando menu...'
        this.load = true;
        var dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api);
        this.titulo_menu = dados.nm_menu_titulo;
        this.api = dados.nm_identificacao_api
        this.load = false;
        this.carregaDados();

        this.dados_despesa   = await Lookup.montarSelect(this.cd_empresa,438);
        this.dataset_despesa = JSON.parse(JSON.parse(JSON.stringify(this.dados_despesa.dataset)))
        
       
    },
    components:{
        selecaoData,
        carregando
    },
    watch:{

    },
    methods:{
        async carregaDados(){
            this.mensagem = 'Buscando informações...'
            this.load = true;
            let inicial =  formataData.formataDataSQL(this.hoje.from)
       
            let consulta = {
                "cd_parametro" : 0,
                "dt_inicial"   : inicial,
                "dt_final"     : formataData.formataDataSQL(this.hoje.to),
                "cd_usuario"   : this.cd_usuario
            }
            let cons = await Incluir.incluirRegistro(this.api,consulta);
            if(cons[0].Cod == 0){
                this.load = false;
                notify(cons[0].Msg);
                this.dataSourceConfig = [];
            }else{
                this.load = false;
                this.dataSourceConfig = cons
            }
        },

        onCalculaTotal(){
                var valor = this.vl_item_despesa + '';
                if(valor.includes(",")){
                    valor = valor.replace(",",".")
                }
                if(valor.includes("R$")){
                    valor = valor.replace("R$","")
                }
                this.vl_item_despesa = valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
        },

        VoltaConsulta(){
            this.ic_cadastro = false;
            this.ic_consulta = true;
            this.carregaDados();
        },

        NovaDespesa(){
            this.ic_consulta = false;
            this.ic_cadastro = true;
        },

        ArrumaData(date){
            date = date +'';
            var diaF = date.substr(3,2)
            var mesF = date.substr(0,2)
            var anoF = date.substr(6,4)
            return diaF+'/'+mesF+'/'+anoF

        }

    }
}
</script>

<style scoped>
.tela-celular{
    max-width: 550px;
}
.borda-bloco{
    border: solid 1px rgb(170, 170, 170) ;
    border-radius: 5px;
}
.margin1{
    margin: 1vw 0.7vw
}

.q-date{
  width: 310px;
  overflow-x: hidden;
}
.dois-tela{
    widows: 60%;
}
.um-tela{
  width: 40%;
}
</style>