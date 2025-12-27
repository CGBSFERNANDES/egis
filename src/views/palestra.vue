<template>
  <div>
    

    <div id="data-grid-demo">
    <!--Adicionar participantes------------------------------------------------->
      <q-card style="width: 60vw;">
        <q-card-section>
           <div class="text-h6">Participante</div>
        </q-card-section>

        <q-separator/>

        <q-input item-aligned v-model="novo_nm_usuario" type="text" label="Nome Completo">
            <template v-slot:prepend>
              <q-icon name="corporate_fare" />
            </template>
        </q-input>

        <q-input item-aligned v-model="novo_nm_fantasia" type="text" label="Nome Fantasia">
            <template v-slot:prepend>
              <q-icon name="corporate_fare" />
            </template>
        </q-input>

        <q-input item-aligned v-model="novo_email" type="email" label="E-Mail">
            <template v-slot:prepend>
              <q-icon name="mail" />
            </template>
        </q-input>

        <div class="row">
            <q-input class="col" item-aligned mask="(##)#####-####" v-model="celular" label="Celular" type="text" >
                <template v-slot:prepend>
                  <q-icon name="phone_iphone" />
                </template>
            </q-input>
            <q-input class="col-4" item-aligned mask="##/##/####" label="Nascimento" v-model="dt_nascimento_usuario" type="text" >
                <template v-slot:prepend>
                  <q-icon name="cake" />
                </template>
            </q-input>
        </div>

        <q-card-actions align="right" class="bg-white text-teal">
          <q-btn flat label="Salvar" @click="InsertUsuario"/>
        </q-card-actions>
      </q-card>

  </div>
  </div>
</template>

<script>
import DxButton from 'devextreme-vue/button';
import {
  DxDataGrid,
  DxColumn,
  DxPaging,
  DxEditing,
  DxSelection,
  DxLookup
} from 'devextreme-vue/data-grid';


import {
  DxFilterRow,
  DxPager,
  DxExport,
  DxGroupPanel,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxStateStoring,
  DxSearchPanel,
  DxPosition,
  DxMasterDetail
 
  
} from "devextreme-vue/data-grid";


import { DxForm,
         DxItem
 } from 'devextreme-vue/form';

import DxTabPanel from 'devextreme-vue/tab-panel';
import { DxPopup } from 'devextreme-vue/popup';
import selecaoData from '../views/selecao-periodo.vue';
import Menu from '../http/menu';
import componente from '../views/display-componente';
import 'whatwg-fetch';
import DxSelectBox  from 'devextreme-vue/select-box';
import Incluir from '../http/incluir_registro';
import notify from 'devextreme/ui/notify';
import formataData from '../http/formataData'

var dados = [];
var sParametroApi = '';

export default {
    data(){
        return{
            columns                      : [],
            dataSourceConfig             : [],
            selectedRowKeys              : [],
            items                        : [],
            formData                     : {},
            refreshMode                  : 'reshape',
            allMode                      : 'allPages',
            checkBoxesMode               : 'onClick', 
            temPanel                     : false,
            sorteado                     :'',
            pageSizes                    : [10, 20, 50, 100], 
            sApis                        : '',
            nm_json                      : {},
            row                          : {},
            cd_empresa_sorteio           : 0,
            grid_sorteio                 : {},
            total                        : {}, 
            participantes_d              : [],
            final                        : [],
            popup_sorteio                : false,
            popup_aguardando             : false,
            timer                        : 0,
            intervalo                    : '',
            img_foto                     : '',
            imagem_usuario               : '' ,
            nome_empresa                 : '',
            vb_imagem                    : '',
            indice                       : 0,
            foto                         : '',
            quant                        : 0,
            tempo_correr                 : 0,
            usuario_rand                 : '',
            tempo                        : 0,
            nm_empresa                   : '',
            nm_imagem                    : '',
            dt_extenso                   : '',
            velocidade_count             : 0,
            popup_excluir_participante   : false,
            nm_participante              : '',
            empresa                      : 0,
            participante_excluido        : 0,
            btn_send                     : '',
            popup_adicionar_participante : true,
            novo_nm_usuario              : '',
            novo_nm_fantasia             : '',
            nova_dt_nascimento           : '',
            novo_email                   : '',
            excluir_participante         : {},
            lista_participante           : [],
            pop_updecisao                : false,
            pop_reativar_usuario         : false,
            reativar_usuario             : [],
            excluido                     : 0 ,
            celular                      : '',
            dt_nascimento_usuario        : '',

        }
    },

     async created(){
      localStorage.cd_empresa = 171;
      localStorage.cd_menu    = 7185;
      localStorage.cd_api     = 563;
      this.cd_empresa_sorteio = localStorage.cd_empresa
      this.nm_json = {
             "cd_parametro" : 0,
             "cd_empresa"   : this.cd_empresa_sorteio
      }
      this.nome_empresa = localStorage.fantasia;
      this.nm_empresa   = localStorage.empresa;
      this.nm_imagem    = 'http://www.egisnet.com.br/img/' + localStorage.nm_caminho_logo_empresa;

      this.grid_sorteio = await Incluir.incluirRegistro('523/730',this.nm_json);
      this.quant = this.grid_sorteio.length;
      
       this.showMenu();
       this.carregaDados(); 
     },

    
    methods:{
     //FUNÇÃO QUE FAZ O SORTEIO

        random(){
          this.onLimpaSorteio();
          var participantes = [];
          
          for(var count = 0;count < parseInt(this.grid_sorteio.length);count++){
       
              if(this.participantes_d.indexOf(this.grid_sorteio[count].cd_controle) != -1 ){
                this.final[this.final.length] = this.grid_sorteio[count].nm_usuario
              }
          }

          this.indice = Math.floor(Math.random() * this.final.length)
          this.sorteado = this.final[this.indice]
          this.foto     = this.grid_sorteio[this.indice].vb_imagem
          //console.log(this.foto, 'fotoooooooo')
        
          this.imagem_usuario = ''
          this.imagem_usuario = this.grid_sorteio[this.indice].vb_imagem
          this.popup_aguardando = true;
          this.timer = this.tempo_correr;
          this.tempo     = setInterval(this.random_vendedor,150);
          this.intervalo =  setInterval(this.AguardandoResultado, 1000);
        },
        clickRandom(){
          if(this.participantes_d.length <= 1){
            notify('Selecione pelo menos duas pessoas')
            return;
          }
          this.random();
          this.time();
        },

        time(){
          setTimeout(() => {this.lista_participante.push(this.sorteado)}, 5000);
          this.excluido = this.participantes_d.shift()
        },

        random_vendedor(){
            this.indice       = Math.floor(Math.random() * this.final.length)
            this.usuario_rand = this.final[this.indice]
        },
        //FUNÇÃO QUE MOSTRA O MENU-------------------

        async showMenu() {
          dados = await Menu.montarMenu(localStorage.cd_empresa, localStorage.cd_menu, localStorage.cd_api); //'titulo';
          sParametroApi = dados.nm_api_parametro;
          this.total   = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));  
          this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));  
        },

        async carregaDados(){
          let sApis = sParametroApi; 
          this.dataSourceConfig = await Incluir.incluirRegistro('523/730',this.nm_json);
          this.dt_extenso   = this.dataSourceConfig[0].dia_semana + ' - ' + this.dataSourceConfig[0].data_extenso;
          this.tempo_correr = this.dataSourceConfig[0].qt_tempo;
        },
       
        teste({selectedRowKeys,selectedRowsData}){
          this.participantes_d = selectedRowKeys;
        },
        Decisao(){
          this.novo_nm_usuario = ''
          this.novo_nm_fantasia = ''
          this.novo_email = ''
          this.dt_nascimento_usuario = ''
          this.celular = ''
          this.popup_adicionar_participante = true;





        },
        async ReativarUsuario(){
          this.nm_json = {
            "cd_parametro" : 3,
            "cd_empresa"   : this.cd_empresa_sorteio
          }

          this.reativar_usuario = await Incluir.incluirRegistro('560/779',this.nm_json);
          notify(this.reativar_usuario[0].Msg)
          this.pop_reativar_usuario = true;
        },

        onInitialized(e){
        },
        onLimpaSorteio(){
            this.intervalo      = 0;
            this.final          = []
            this.sorteado       = '';
            this.timer          = 0;
         
        },

        AguardandoResultado() {             
          if(this.timer == 0){
              this.popup_aguardando = false;
              this.popup_sorteio   = true;
              clearInterval(this.intervalo);
              clearInterval(this.tempo);
          }
          else{
              this.timer = this.timer - 1;
          }
        },
        AbrePop(){
          this.popup_excluir_participante = true
        },
       
        NovoParticipante(){
          this.pop_updecisao                = false;
          this.novo_nm_usuario              = '';
          this.novo_nm_fantasia             = '';
          this.novo_email                   = '';
          this.popup_adicionar_participante = true;
          this.celular                      = ''
          this.dt_nascimento_usuario        = ''
        },


        async ParticipanteSelecionado(e){
          this.participante_excluido = e.cd_usuario;
          let api_exclusao = '560/779'

           this.nm_json = {
            "cd_parametro"     : 1,
            "cd_usuario"       : this.participante_excluido
          }         
          this.excluir_participante = await Incluir.incluirRegistro(api_exclusao,this.nm_json);
          notify(this.excluir_participante[0].Msg)

          //recarrega menu
          this.nm_json={
             "cd_parametro" : 0,
             "cd_empresa"   : this.cd_empresa_sorteio
          }
          this.dataSourceConfig = []
          this.dataSourceConfig = await Incluir.incluirRegistro('523/730',this.nm_json);
          this.dt_extenso   = this.dataSourceConfig[0].dia_semana + ' - ' + this.dataSourceConfig[0].data_extenso;
          this.tempo_correr = this.dataSourceConfig[0].qt_tempo;
          this.popup_excluir_participante = false;
          
        },
        LimpaLista(){
          this.lista_participante = []
        },
       

        async InsertUsuario(){
          if(this.novo_nm_usuario == ''){
            notify('Digite o nome completo')
            return;
          }else if(this.novo_nm_fantasia == ''){
            notify('Digite o nome fantasia!')
            return;
          }else if(this.novo_email == ''){
            notify('Digite o e-mail!')
            return;
          }else if(this.celular == ''){
            notify('Digite o celular');
            return;
          }else if(this.dt_nascimento_usuario == ''){
            notify('Digite a data de nascimento!');
            return;
          }
          let api_exclusao = '560/779'
          this.dt_nascimento_usuario = formataData.formataDataSQL(this.dt_nascimento_usuario); 
          this.nm_json = {
            "cd_parametro"          : 2,
            "nm_usuario"            : this.novo_nm_usuario,
            "nm_fantasia"           : this.novo_nm_fantasia,
            "nm_email"              : this.novo_email,
            "cd_empresa"            : this.cd_empresa_sorteio,
            "dt_nascimento_usuario" : this.dt_nascimento_usuario,
            "cd_celular"            : this.celular
          }
          this.insert_usuario = await Incluir.incluirRegistro(api_exclusao,this.nm_json);
          notify(this.insert_usuario[0].Msg)
          //console.log(this.nm_json)
          
          this.cd_empresa_sorteio = localStorage.cd_empresa
          this.nm_json = {
            "cd_parametro" : 0,
            "cd_empresa"   : this.cd_empresa_sorteio
          }
         this.nome_empresa = localStorage.fantasia;
         this.nm_empresa   = localStorage.empresa;
         this.nm_imagem    = 'http://www.egisnet.com.br/img/' + localStorage.nm_caminho_logo_empresa;

         this.grid_sorteio = await Incluir.incluirRegistro('523/730',this.nm_json);
         //console.log(this.grid_sorteio,'grid')
         this.quant = this.grid_sorteio.length;

          this.showMenu();
          this.carregaDados();
          this.novo_nm_usuario = ''
          this.novo_nm_fantasia = ''
          this.novo_email = ''
          this.dt_nascimento_usuario = ''
          this.celular = ''
          this.popup_adicionar_participante = true;
        }
    },
    components:{
      DxDataGrid,
      DxFilterRow,
      DxPager,
      DxPaging,
      DxExport,
      DxGroupPanel,
      DxGrouping,
      DxColumnChooser, 
      DxColumnFixing,
      DxHeaderFilter,
      DxFilterPanel,
      DxSelection,
      DxSelectBox,
      DxStateStoring,
      DxSearchPanel,
      DxTabPanel,
      componente,
      DxForm,
      DxButton,
      DxPopup,
      DxEditing, 
      DxPosition,
      DxItem,
      DxMasterDetail,
      selecaoData
    }
}
</script>

<style>

.div-conteudo{
  width: 80vw;
  align-items: center;
}
.botao-sorteio{
    margin-left: 15%;
}
#data-grid-demo {
    min-height: 700px;
    margin: 10px;
}
.aniversariante {
 margin: 0 auto;
 padding: 0;
 background: url("https://acegif.com/wp-content/gif/confetti-17.gif") fixed center;
}

.sorteado {
 margin:  0 auto;
 padding: 0;
 background: url("https://i.makeagif.com/media/3-09-2017/bPSsed.gif") fixed center;
}
.img-user{
  max-height: 250px;
  width: 150px !important;
  margin-left: 38%;
  margin-top: 20px;
  align-items: center;
}
.botao-altera{
   margin: 0 5px 0 5px;
   max-width: 12px;
}
.titulo-lista{
  align-items: center;
  text-align: center;
}
.botao-titulo{
  margin: 2% 2% 0 0;
  height: 10%;
}
.botao-decisao{
  margin: 20px;
}
.tit{
margin: 0;
padding: 0;
}
.text-subtitle1{
  margin: 2%;
}
.but{
  padding-left: 0;
  margin-left: 0;
  margin-right: 0;
  padding-right: 0;
}
.tet{
  margin-left: 5%;
}
.dir{
  text-align: right;
}
</style>