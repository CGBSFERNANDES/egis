<template>
    <div style="width:100vw;">
        <div class="row justify-center">
            <q-img
            class="wrap"
              :src="'http://www.egisnet.com.br/img/' + logoEmpresa"
              style="width: 160px; height: 80px;border-radius: 100%; margin:5px"
              spinner-color="white"
              round
            />
            <br>
            <div class="col wrap items-center">
                <div class="text-h4 text-center text-bold justify-center items-center">Registro de Entrada {{hoje}}</div>
            </div>
          </div>

        <br>

        <q-input class="padding1" @blur="PesquisaCliente()" item-aligned v-model="celular" type="text" mask="(##) #####-####" label="Fone/Celular">
            <template v-slot:prepend>
                <q-icon name="phone_iphone" />
            </template>
        </q-input>

        <q-input class="padding1" item-aligned v-model="nome" type="text" label="Nome" :disable="ready">
            <template v-slot:prepend>
                <q-icon name="face" />
            </template>
        </q-input>

        <q-input class="padding1" item-aligned v-model="email" type="email" label="E-Mail" :disable="ready">
            <template v-slot:prepend>
                <q-icon name="email" />
            </template>
        </q-input>

        <q-input class="padding1" item-aligned v-model="qt_pessoa" type="number" label="Pessoas" @input="onPessoas()">
            <template v-slot:prepend>
                <q-icon name="groups" />
            </template>
        </q-input>

         <q-input class="padding1" item-aligned v-model="comanda" type="text" label="Comanda" readonly>
            <template v-slot:prepend>
                <q-icon name="bookmark" />
            </template>
        </q-input>

        <div class="text-body2 text-center" style="margin:0">Aniversário</div>
        <div class="row margin1">
            <q-input @input="InputDia()" class="col padding1" item-aligned v-model="dia" type="number" label="Dia">
                <template v-slot:prepend>
                    <q-icon name="today" />
                </template>
            </q-input>
            <q-input @input="InputMes()" class="col padding1" item-aligned v-model="mes" type="number" label="Mês" >
                <template v-slot:prepend>
                    <q-icon name="insert_invitation" />
                </template>
            </q-input>
            <q-input @input="InputAno()" class="col padding1" item-aligned v-model="ano" maxlength="4" type="number" label="Ano">
                <template v-slot:prepend>
                    <q-icon name="date_range" />
                </template>
            </q-input>
        </div>
        <div class="row" style="margin-top:0.5%">
            <div class="col text-left">
                <q-btn style="margin:1%" color="positive" size="90%" label="Registrar" @click="Registrar()">
                    <q-tooltip transition-show="scale" transition-hide="scale">
                        Registrar entrada
                    </q-tooltip>
                </q-btn>
            </div>

            <div class="col text-right">
                <q-btn color="primary"  style="margin:1%;" size="90%" label="Limpar" @click="Limpar()">
                    <q-tooltip transition-show="scale" transition-hide="scale">
                        Limpar locais de digitação
                    </q-tooltip>
                </q-btn>
                <q-btn color="orange-8" style="margin:1%;" size="90%" label="Finalizar">
                    <q-tooltip transition-show="scale" transition-hide="scale">
                        Finalizar cadastro
                    </q-tooltip>
                </q-btn>
            </div>
            
        </div>
        

     </div>
</template>

<script>
import Incluir from '../http/incluir_registro';
import notify from 'devextreme/ui/notify';
import { LocalStorage } from 'quasar';

export default {
    name: 'registro-entrada',
    data(){
        
        return{
            dia        : '',
            mes        : '',
            ano        : '',
            nome       : '',
            celular    : '',
            email      : '',
            qt_pessoa  : '1',
            comanda    : '',
            hoje       : '',
            api        : '591/820',//pr_registro_entrada
            cd_usuario : '',
            ready      : false,
            logoEmpresa: ''
        }
    },
    async created(){
        var url_atual = window.location.href;
        var corte = url_atual.indexOf("_") + 1
        let e = url_atual.substr(corte)
        localStorage.cd_empresa = e;

        let c = {
            "cd_parametro" : 3,
            "cd_empresa"   : e
        } 
        var local = await Incluir.incluirRegistro(this.api,c);
        this.logoEmpresa = local[0].nm_caminho_logo_empresa;
        
        //localStorage.nm_caminho_logo_empresa = local[0].nm_caminho_logo_empresa;

        //if(localStorage.cd_empresa == undefined){
        //    localStorage.cd_empresa == 188
        //    this.logoEmpresa = 'logo_takamoris.jpg'
        //}else{
        //    this.logoEmpresa = localStorage.nm_caminho_logo_empresa
        //}
        //localStorage.cd_empresa = 188
        var data_hoje = new Date();
        var dia_hoje = data_hoje.getDate();
        var mes_hoje = (data_hoje.getMonth()) + 1
        var ano_hoje = data_hoje.getFullYear();
        if(dia_hoje <10){
            this.hoje = '0'+ dia_hoje + '/' + mes_hoje + '/' + ano_hoje;
        }else{
            this.hoje     = dia_hoje + '/' + mes_hoje + '/' + ano_hoje;
        }
        this.cd_usuario = localStorage.cd_usuario;
        this.Limpar();
        this.comanda = local[0].cd_comanda_livre;
        notify('Próxima Comanda Livre: ' + local[0].cd_comanda_livre)
    },
    methods:{
        InputDia(){
            if(this.dia > 31){
                this.dia = 31;
            }
            else if(this.dia < 0){
                this.dia = 1;
            }
        },
        InputMes(){
            if(this.mes > 12){
                this.mes = 12;
            }else if(this.mes < 0){
                this.mes = 1;
            }
        },
        InputAno(){
            if(this.ano < 0){
                this.ano = 1900
            }
            var data = new Date();
            var anohoje = data.getFullYear();
            if(this.ano > anohoje){
                this.ano = anohoje;
            }
        },
        Limpar(){
            this.dia       = '';
            this.mes       = '';
            this.ano       = '';
            this.nome      = '';
            this.celular   = '';
            this.email     = '';
            this.qt_pessoa = '1';
            this.comanda   = '';
        },
        onPessoas(){
            if(this.qt_pessoa < 1){
                this.qt_pessoa = 1;
            }
        },

        async Registrar(){
            //if(this.dia == ''){
            //    notify('Digite o dia do aniversário!')
            //    return;
            //}else if(this.mes == ''){
            //    notify('Digite o mês do aniversário!')
            //    return;
            //}
            var aniversario = this.ano + '-'+ this.mes + '-' + this.dia

            
            var registro = {
                "cd_parametro"       : 1,
                "nm_pessoa_registro" : this.nome,
                "cd_celular"         : this.celular,
                "nm_email_registro"  : this.email,
                "dd_aniversario"     : this.dia,
                "mm_aniversario"     : this.mes,
                "cd_comanda"         : this.comanda,
                "qt_pessoa_registro" : this.qt_pessoa,
                "aa_aniversario"     : this.ano,
                "dt_aniversario"     : aniversario
            }
            var incluido = await Incluir.incluirRegistro(this.api,registro);
            if(incluido[0].Cod == 0){
                notify(incluido[0].Msg);
                return;
            }
            notify(incluido[0].Msg)
            this.Limpar();
            this.comanda = incluido[0].livre;
        },

        async PesquisaCliente(){
            if(this.celular == ''){
                return;
            }
            this.nome = '';
            this.email = '';
            this.ready = true;
            var pesquisa = {
                "cd_parametro" : 2,
                "cd_celular"   : this.celular
            }
            var pesquisa_tel = await Incluir.incluirRegistro(this.api,pesquisa);
            if(pesquisa_tel[0].Cod == 0){
                notify('Pesquisa concluída')
                notify(pesquisa_tel[0].Msg)
            }else{
                this.nome = pesquisa_tel[0].nm_pessoa_registro;
                this.email = pesquisa_tel[0].nm_email_registro;
                notify('Pesquisa concluída')
                if(this.email == ''){
                    notify('Email não encontrado...')
                }
            }            
            this.ready = false;
        }

    }
}
</script>

<style>
.padding1{
    padding: 0.3%;
}
.margin1{
    margin: 0.5%;
    margin-top: 0.2%;
}
</style>