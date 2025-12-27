<template>
  <div>
    <h2 class="content-block">{{tituloMenu}}</h2>
    <div>
      <div class="row margem">
        <q-input class="col dig_dim" @blur="carregaProduto()" v-model="nm_fantasia_produto" label="Código produto" />
        <q-input class="col dig_dim" v-model="ds_produto" :loading="carrega_produo" label="Descrição" />
        <q-input class="col dig_dim" v-model="qt_orcamento" type="number" label="Quantidade" />
      </div>

      <div class="row margem">
        <label class="col label_medidas"> Diâmetros </label>
        <label class="col label_medidas"> Interno   </label>
        <label class="col label_medidas"> Externo   </label>
        <label class="col label_medidas"> Espessura </label>
        <label class="col label_medidas"> Altura    </label>
      </div>

       <q-separator class="separacao"/>

      <div class="row margem">
        <label class="col label_medidas" >Mínimo</label>
        <q-input type="text" v-model="qt_minimo_interno"    class="col dig_dim contraliza_texto" />
        <q-input type="text" v-model="qt_minimo_externo"    class="col dig_dim contraliza_texto" />
        <q-input type="text" v-model="qt_minimo_espessura"  class="col dig_dim contraliza_texto" />
        <q-input type="text" v-model="qt_minimo_altura"     class="col dig_dim contraliza_texto" />
      </div>

      <q-separator class="separacao"/>

      <div class="row margem">
        <label class="col label_medidas"> Máximo </label>
        <q-input type="number" v-model="qt_maximo_interno"    class="col dig_dim" />
        <q-input type="number" v-model="qt_maximo_externo"    class="col dig_dim" />
        <q-input type="number" v-model="qt_maximo_espessura"  class="col dig_dim" />
        <q-input type="number" v-model="qt_maximo_altura"     class="col dig_dim" />
      </div>

       <q-separator class="separacao"/>

      <div class="row margem">
        <select class="content-block col select" v-model="cd_mat_prima">
          <option value="" disabled selected>Materia Prima</option>
          <option v-for="(lookup_dataset_materia_prima) in lookup_dataset_materia_prima" v-bind:key="lookup_dataset_materia_prima.cd_mat_prima"
            v-bind:value="lookup_dataset_materia_prima.cd_mat_prima">
            {{ lookup_dataset_materia_prima.nm_mat_prima.toUpperCase() }}
          </option>    
        </select>

        <select class="content-block col select" v-model="cd_tratamento_produto">
          <option value="" disabled selected>Tratamento</option>
          <option v-for="(lookup_dataset_tratamento_produto) in lookup_dataset_tratamento_produto" v-bind:key="lookup_dataset_tratamento_produto.cd_tratamento_produto"
            v-bind:value="lookup_dataset_tratamento_produto.cd_tratamento_produto">
            {{ lookup_dataset_tratamento_produto.nm_tratamento_produto.toUpperCase() }}
          </option>    
        </select>

        <select class="content-block col select" v-model="cd_acabamento_produto">
          <option value="" disabled selected>Acabamento</option>
          <option v-for="(lookup_dataset_acabamento_produto) in lookup_dataset_acabamento_produto" v-bind:key="lookup_dataset_acabamento_produto.cd_acabamento_produto"
            v-bind:value="lookup_dataset_acabamento_produto.cd_acabamento_produto">
            {{ lookup_dataset_acabamento_produto.nm_acabamento_produto.toUpperCase() }}
          </option>    
        </select>
      </div>

      <div class="row margem">
        <q-input type="textarea" class="col" v-model="nm_especificacoes" label="Especificações técnicas" />
        <DxFileUploader
          class="col"
          select-button-text="Desenho"
          :multiple=true
          label-text="Ou arraste aqui"
          accept="image/*"
          upload-mode="useForm"
      />    
      </div>
    </div>

      <div class="buttons-column">
          <div>
            <DxButton
              :width="120"
              text="Enviar"
              type="default"
              styling-mode="contained"
               @click="onGravar()"
            />
          </div>
      </div>     

       <div v-if="cod_invalido == true" class="q-pa-md q-gutter-sm">
       <q-dialog
        v-model="cod_invalido"
        persistent
        :maximized="maximizedToggle"
        transition-show="slide-up"
        transition-hide="slide-down"
       >
       <q-card class="bg-primary text-white">
        <q-bar>
          <q-space />

          <q-btn dense flat icon="minimize" @click="maximizedToggle = false" :disable="!maximizedToggle">
            <q-tooltip v-if="maximizedToggle" content-class="bg-white text-primary">Minimizar</q-tooltip>
          </q-btn>
          <q-btn dense flat icon="crop_square" @click="maximizedToggle = true" :disable="maximizedToggle">
            <q-tooltip v-if="!maximizedToggle" content-class="bg-white text-primary">Maximizar</q-tooltip>
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip content-class="bg-white text-primary">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section>
          <div class="text-h6">ATENÇÃO...</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          Código do Produto Inválido
        </q-card-section>
      </q-card>       
      </q-dialog>
    </div> 

  </div>

</template>

<script>

import DxForm from "devextreme-vue/form";
import DxButton from 'devextreme-vue/button';
import notify from 'devextreme/ui/notify';
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from 'devextreme/core/config';
import Procedimento from '../http/procedimento';
import Menu from '../http/menu';
import Salvar from '../http/incluir_registro';
import { DxChart, DxSeries, DxCommonSeriesSettings, DxLabel, DxArgumentAxis } from 'devextreme-vue/chart';
import { DxFileUploader } from 'devextreme-vue/file-uploader';

import Lookup from '../http/lookup';
import Incluir from '../http/incluir_registro';


var cd_empresa = 0
var cd_menu    = 0;
var cd_api     = 0;
var cd_cliente = 0;
var api        = '';

var dados = [];

export default {
  props: {
    picture: String
  },
  data() {
    
    return {
      tituloMenu: '',
      menu      : '',
      formData: {},
      tituloColuna: [],
      text        :'',
      colCountByScreen: {
        xs: 1,
        sm: 2,
        md: 3,
        lg: 4
      },

      // VARIAVEIS DO ORÇAMENTO
      cd_produto      : '',
      cd_grupo_produto: 0,
      ds_produto: '',
      nm_produto: '',
      nm_fantasia_produto: '',

      nm_descricao    : '',
      qt_orcamento    : '',

      // DIÂMETROS
      qt_minimo_interno  : 0,
      qt_minimo_externo  : 0,
      qt_minimo_espessura: 0,
      qt_minimo_altura   : 0,

      qt_maximo_interno  : 0,
      qt_maximo_externo  : 0,
      qt_maximo_espessura: 0,
      qt_maximo_altura   : 0,

      nm_mat_prima   : '',
      cd_mat_prima   : '',

      nm_tratamento_produto: '',
      cd_tratamento_produto: '',

      nm_acabamento_produto: '',
      cd_acabamento_produto: '',

      nm_especificacoes  : '',

      nm_arquivo         : '',

      lookup_dados_materia_prima: [],
      lookup_dataset_materia_prima: [],

      lookup_dados_tratamento_produto: [],
      lookup_dataset_tratamento_produto: [],

      lookup_dados_acabamento_produto: [],
      lookup_dataset_acabamento_produto: [],

      dataSourceConfig: [],

      carrega_produo: false,

      cod_invalido: false,

      dados_orcamento_composicao : {},

      dados_orcamento : {},

    };
  },
  components: {
    DxForm,
    DxButton,
    DxLabel, 
    DxFileUploader
  },
  created() {
      //locale(navigator.language);
    config({ defaultCurrency: 'BRL' });  
    loadMessages(ptMessages);
    locale(navigator.language);     
   // locale('pt-BR');     
  },   

  async mounted() {
    this.showMenu();
    //this.carregaDados();
  },

  methods: {

     async showMenu() {
      
      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      cd_menu    = localStorage.cd_menu;
      api        = localStorage.nm_identificacao_api;
      cd_api     = localStorage.cd_api;


      dados = await Menu.montarMenu(cd_empresa, cd_menu,cd_api);
      this.tituloMenu = dados.nm_menu_titulo;
      this.menu       = dados.nm_menu;
      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);


      //MATERIA PRIMA
        this.lookup_dados_materia_prima = await Lookup.montarSelect(cd_empresa,56);
        this.lookup_dataset_materia_prima = JSON.parse(JSON.parse(JSON.stringify(this.lookup_dados_materia_prima.dataset)));
        console.log(this.lookup_dataset_materia_prima);
      //
      
      //TRATAMENTO PRODUTO
        this.lookup_dados_tratamento_produto = await Lookup.montarSelect(cd_empresa,2542);
        this.lookup_dataset_tratamento_produto = JSON.parse(JSON.parse(JSON.stringify(this.lookup_dados_tratamento_produto.dataset)));
        console.log(this.lookup_dataset_tratamento_produto);
      //
      
      //ACABAMENTO PRODUTO
        this.lookup_dados_acabamento_produto = await Lookup.montarSelect(cd_empresa,2539);
        this.lookup_dataset_acabamento_produto = JSON.parse(JSON.parse(JSON.stringify(this.lookup_dados_acabamento_produto.dataset)));
        console.log(this.lookup_dataset_acabamento_produto);
      //

     },

    async carregaDados() {
      console.log('carregou os dados')
    },

    async carregaProduto(){
      this.carrega_produo = true;

      console.log(this.nm_fantasia_produto);

      if(this.nm_fantasia_produto == ''){
        this.nm_fantasia_produto = 'Código inválido'
        this.nm_fantasia_produto = ''
      }
      else{

      }
      localStorage.nm_fantasia = this.nm_fantasia_produto;
      console.log(localStorage.cd_empresa);
      try{
        this.dataSourceConfig = await Procedimento.montarProcedimento(
        cd_empresa,
        this.cd_cliente,
        '422/559',
        '/${cd_empresa}/${nm_fantasia}'
      );
        this.ds_produto       = this.dataSourceConfig[0].ds_produto;
        this.cd_produto       = this.dataSourceConfig[0].cd_produto;
        this.cd_grupo_produto = this.dataSourceConfig[0].cd_grupo_produto;
        this.nm_produto       = this.dataSourceConfig[0].nm_produto;
      }
      catch{
        this.cod_invalido = true;
        this.cd_produto = '';
      }
      this.carrega_produo = false;
    },

    async onGravar(){

      console.log(localStorage.cd_usuario);


      var api_orcamento_composicao = '423/561';
      this.dados_orcamento_composicao = {
        "cd_usuario":localStorage.cd_usuario,
        "cd_usuario_inclusao":localStorage.cd_usuario,
        "cd_produto":this.cd_produto,
        "cd_servico":"",
        "cd_grupo_produto":this.cd_grupo_produto,
        "nm_produto_orcamento":this.nm_produto,
        "ds_produto_orcamento":this.ds_produto,
        "qt_orcamento": this.qt_orcamento,
        "cd_identificacao_produto":"",
        "cd_materia_prima":this.cd_mat_prima,
        "cd_acabamento_produto":this.cd_acabamento_produto,
        "cd_tratamento_produto":this.cd_tratamento_produto,
        "nm_fantasia_produto":this.cd_fantasia_produto,
        "qt_diametro_externo":this.qt_minimo_externo,
        "qt_diametro_interno":this.qt_minimo_interno,
        "qt_espessura":this.qt_minimo_espessura,
        "qt_altura":this.qt_minimo_altura,
        "qt_tol_diametro_interno":this.qt_maximo_interno,
        "qt_tol_diametro_externo":this.qt_maximo_externo,
        "qt_tol_espessura":this.qt_maximo_espessura,
        "qt_tol_altura":this.qt_maximo_altura,
        "ds_especificacao_produto":this.ds_produto,
      }

      var date = new Date;

      var api_orcamento = '424/565'
      this.dados_orcamento = {
        "dt_orcamento":date,
        "cd_cliente": localStorage.cd_cliente,
      }

      var c = await Incluir.incluirRegistro(api_orcamento, this.dados_orcamento);
      console.log(c);

      var s = await Incluir.incluirRegistro(api_orcamento_composicao, this.dados_orcamento_composicao);
      console.log(s);

      notify('Orçamento realizado com sucesso!');
    },


    async onClick(e) {

    },
    capitalize(text) {
      return text.charAt(0).toUpperCase() + text.slice(1);
    }
  }

};
</script>

<style lang="scss">
.form-avatar {
  float: left;
  height: 120px;
  width: 120px;
  margin-right: 20px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
  background-color: #fff;
  overflow: hidden;

  img {
    height: 120px;
    display: block;
    margin: 0 auto;
  }
}

  .label_medidas{
    text-align: center;
    font-size: 20px;
    margin-top: 15px;
  }

  .separacao{
    margin-top: 15px;
  }

  .select{
    height: 40px;
  }

  .margem{
    padding-left:  20px;
    padding-right: 20px;
  }

  .dig_dim{
    padding: 0 10px;
  }

  .contraliza_texto{
    text-align: center;
  }

</style>