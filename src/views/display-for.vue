<!--Tipo de Campo
--    1 - Label com input somente leitura
--    2 - Label com input para digitação
--    3 - Label com Lookup (tem que passar a tabela para Lookup)
             Chamar o tipo_campo3() para retornar o Json
--    4 - 
-->
<template>
<div>
    <div v-if="tipo_campo == 1">
        <div class="valores" v-for="n in parseInt(repeticoes)" v-bind:key="n" >
            <label> {{ n }} {{ labels }} </label>
            <q-input class="col" :v-model="n" readonly label="Data" />
        </div>
    </div>

    <div v-if="tipo_campo == 2">
        <div class="valores" v-for="n in parseInt(repeticoes)" v-bind:key="n" >
            <label> {{ n }} {{ labels }} </label>
            <DxTextBox styling-mode="filled" :name="'r'+n"/>
          <!--<input class="dx-field col" type="text" :name="'p'+n" :placeholder="'Valor da '+ n +'ª Parcela'"/>-->
        </div>
    </div>

    <div v-if="tipo_campo == 3">
        <div class="valores" v-for="n in parseInt(repeticoes)" v-bind:key="n" >
            <select :name="'l'+n" :v-model="teste">
                <option v-for="(dataset_lookup) in dataset_lookup" v-bind:key="dataset_lookup.cd_empresa">
                    {{ dataset_lookup[display] }}
                </option>
            </select>
        </div>
    </div>


    <input v-if="testando == true" type="button" @click="tipo_campo2()" value="ENVIA" />
</div>
</template>

<script>
import DxTextBox from 'devextreme-vue/text-box';
import lookup    from '../http/lookup';

export default {
    props:{
        repeticoes    : { type: Number  },
        labels        : { type: String  },
        campo         : { type: String  },
        tipo_campo    : { type: Number  },
        tabela_lookup : { type: Number,  default: 0     },
        testando      : { type: Boolean, default: false }
    },
    components:{
        DxTextBox,
    },
    data(){
        return{
            cd_empresa: localStorage.cd_empresa,

            dataset_lookup : [],
            dados_lookup   : [],

            id: 0,
            display: '',
            teste  : '',
        };
        
    },
    async created(){
        //--> Monta o LOOKUP caso a tabela de lookup seja informada
        if(!this.tabela_lookup == 0){
            this.dados_lookup = await 
                lookup.montarSelect(
                    this.cd_empresa,
                    this.tabela_lookup
                )
            this.dataset_lookup =  JSON.parse(JSON.parse(JSON.stringify(this.dados_lookup.dataset)));
            console.log(this.dados_lookup);

            this.display = this.dados_lookup.display;
            this.chave   = this.dados_lookup.chave  ;
 
        }
    },

    methods:{
        tipo_campo2(){
            var i = 0;
            var dados = [];
            for(i = 1 ; i <= this.repeticoes; i ++){
                var a = document.getElementsByName('r'+i)[0].value;
                console.log(a);
                dados[i] = {
                 [this.campo] : a,
                }
            }
        console.log(dados)
        return dados;
        },

        tipo_campo3(){
            var i = 0;
            var dados = [];
            
            for(i = 1 ; i <= this.repeticoes; i++){
                var a = document.getElementsByName('l'+i)[0].value;
                var cd = this.dataset_lookup.findIndex(obj => obj[this.display] == a);
                var selecionada = this.dataset_lookup[cd][this.chave];
                
                dados = {
                    [this.display] : a,
                    [this.chave]   : selecionada,
                }
            }
            console.log(dados);

            return i;
        },


    }
}
</script>

<style>

</style>