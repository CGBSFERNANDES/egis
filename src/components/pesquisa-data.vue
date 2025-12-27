<template>
<div class="tudo ">
      
    <div class="linha-toda margin1" v-if="ano !== '' &&  mes !== '' ">
        <div class="col text-subtitle2" v-if="ano !== '' &&  mes !== ''  ">
            {{mes.nm_mes}} de {{ano.cd_ano}}
        </div>
    </div>
    <div class="linha-toda margin1">

        <q-select
            label="Mês"
            class="margin1 meia-linha"
            v-model="mes"
            input-debounce="0"
            :options="this.dataset_mes"
            option-value="cd_mes"
            option-label="nm_mes"
        >
            <template v-slot:prepend>
                <q-icon name="today" />
            </template>

             <template v-slot:append>
                <q-icon name="close" @click.stop="mes = ''" class="cursor-pointer" />
            </template>
        </q-select>

        <q-select
            label="Ano"
            class="margin1 meia-linha"
            v-model="ano"
            input-debounce="0"
            :options="this.dataset_ano"
            option-value="cd_ano"
            option-label="nm_ano"
        >
            <template v-slot:prepend>
                <q-icon name="date_range" />
            </template>

            <template v-slot:append>
                <q-icon name="close" @click.stop="ano = ''" class="cursor-pointer" />
            </template>
        </q-select>

        
    </div>

    <div class="row items-end">
        <q-btn class="margin1" style="float:right" color="positive" icon="check" label="Confirmar" @click="ConfirmaData()" />
    </div>
    
</div>
</template>

<script>
import Lookup from '../http/lookup';
import notify from 'devextreme/ui/notify';
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from 'devextreme/core/config';


export default {
    name:'pesquisa-data',

    data(){
        return{
            dados_ano   : [],
            dataset_ano : [],
            dados_mes   : [],
            dataset_mes : [],
            cd_empresa  : 0,
            ano         : '',
            anof        : '',
            mes         : '',
            mesf        : '',
            titulo_data : ''
        }
    }, 

    async created(){
        this.cd_empresa  = localStorage.cd_empresa;
        this.dados_mes   = await Lookup.montarSelect(this.cd_empresa,313) 
        this.dataset_mes = JSON.parse(JSON.parse(JSON.stringify(this.dados_mes.dataset)))
        this.dataset_mes = this.dataset_mes.sort(function (a,b){
            if(a.cd_mes < b.cd_mes) return -1;
            return 1;
        })
        config({ defaultCurrency: 'BRL' });  
        loadMessages(ptMessages);
        locale(navigator.language);

       

        this.dados_ano   = await Lookup.montarSelect(this.cd_empresa,383) 
        this.dataset_ano = JSON.parse(JSON.parse(JSON.stringify(this.dados_ano.dataset)))
        
       
    },

    methods:{
        diasNoMes(mes, ano) {
            var data = new Date(ano, mes, 0);
            return data.getDate();
        },

        ConfirmaData(){
            if(this.ano == '' && this.mes == '') return;
            let dt_i
            let dt_f
            let day
            var data = new Date();
            var ano = data.getFullYear();
            if(this.ano.cd_ano != undefined){
                day = this.diasNoMes(this.mes.cd_mes,this.ano.cd_ano)
            }else{
                 day = this.diasNoMes(this.mes.cd_mes,2022)
            }
            if(this.ano.cd_ano == NaN ||this.ano.cd_ano == undefined){
                this.ano = ''
            }
            if(this.mes.cd_mes == NaN || this.mes.cd_mes == undefined){
                this.mes = ''
            }

            if(this.mes != '' && this.ano != ''){
               
                dt_i = this.ano.cd_ano + '-'+ this.mes.cd_mes +'-1';
                dt_f = this.ano.cd_ano + '-'+ this.mes.cd_mes +'-'+ day;

            }else if (this.ano == '' && this.mes != ''){
                dt_i = ano + '-'+ this.mes.cd_mes + '-1';
                dt_f = ano + '-'+this.mes.cd_mes + '-'+ day; 

            }else if(this.ano != '' && this.mes == ''){
                if(!day){
                    day = this.diasNoMes(12,this.ano.cd_ano)
                }
                dt_i = this.ano.cd_ano+ '-'+ '1-1';
                dt_f = this.ano.cd_ano+'-12'+ '-' + day;
            }

            localStorage.dt_inicial = dt_i;
            localStorage.dt_final   = dt_f;
            notify('Data Selecionada com Sucesso!');
        }

    }

}
</script>

<style scoped>
.margin1{
    margin: 2% 1%;
}
.tudo{

    width: auto;
    height: auto;
    min-width: 320px;
    min-height: 100px;
}
.linha-toda{
    width: 95%;
}
.meia-linha{
    width: auto;
}

@media (max-width: 545px){
    .meia-linha{
        width: 50%;
    }
}
</style>