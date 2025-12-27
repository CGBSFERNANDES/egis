<template>
  <div class="kanban">
    <div class="row">
      <h2 class="col">{{tituloMenu}}</h2>
    </div>
    <div>
      <q-toolbar class="bg-white q-my-md shadow-2 toolbar etp" >
        <q-space/>
        <q-toolbar-title>
          <b>Etapas</b>
        </q-toolbar-title>
        <q-space/>
      </q-toolbar>

  <!------------------------------------------KANBAN--------------------------------------------------->  
    </div>
     <DxScrollView
      class="scrollable-board"
      direction="horizontal"
      show-scrollbar="always"
    >
      <DxSortable
        class="sortable-lists"
        item-orientation="horizontal"
        handle="dataSourceConfig.cd_etapa"
        
      >
        <div
          v-for="dataSourceConfig in dataSourceConfig"
          :key="dataSourceConfig.cd_etapa"
          class="list"
        >
          <div class="list-title dx-theme-text-color">{{ dataSourceConfig.nm_etapa }}</div>
          <DxScrollView
            class="scrollable-list"
            show-scrollbar="always"
          >
            <DxSortable
              :data="dataSourceConfig"
              class="sortable-cards"
              group="dataSourceConfig.cd_etapa"
              @drag-start="onTaskDragStart($event)"
              @reorder="onTaskDrop($event)"
              @add="onTaskDrop($event)"
              
            >
            
              <div
                v-for="dados_pipeline in dados_pipeline "
                :key="dados_pipeline.cd_etapa"
           
              > 
                <div
                 class="card dx-card dx-theme-text-color dx-theme-background-color"
                 v-if="dataSourceConfig.cd_etapa == dados_pipeline.cd_etapa ">
                  <div class="card-subject titulo"> <b> {{ dados_pipeline.nm_titulo_movimento }}</b></div>
                  <div class="card-assignee sub-titulo"> <b> {{ dados_pipeline.nm_fantasia }} - {{ dados_pipeline.nm_contato_crm }}</b></div>
                  <div class="card-assignee sub-titulo"> <b> R$ {{dados_pipeline.vl_oportunidade}} - {{dados_pipeline.dt_previsto_fechamento}}</b></div>

                  <q-rating
                    v-model="dados_pipeline.cd_classificacao"
                    size="1.5em"
                    color="blue-9"
                    readonly
                  />
                </div>
              </div>
            </DxSortable>
          </DxScrollView>
        </div>
      </DxSortable>
    </DxScrollView>
    <!------------------------------------------------------------------------>
  
  </div>
</template>

<script>
   import notify from 'devextreme/ui/notify';
   import ptMessages from "devextreme/localization/messages/pt.json";
   import { locale, loadMessages } from "devextreme/localization";
   import config from 'devextreme/core/config';
   import { DxScrollView } from 'devextreme-vue/scroll-view';
   import { DxSortable } from 'devextreme-vue/sortable';
   import Procedimento from '../http/procedimento';
   import Menu from '../http/menu';
   import Incluir from '../http/incluir_registro';
    
var sParametroApi = '';
var dados = [];


export default {
  components: {
    DxScrollView,
    DxSortable,
  },
  data() {

    return {
        tituloMenu                  : '',
        hoje                        : '',
        business                    : '',
        title                       : '',
        segmento                    : '',
        valor                       : '',
        hora                        : '',
        tel_contact                 : '',
        nm_cliente                  : '', 
        contact_pesq                : '',                                            
        ratingModel                 : 0,                                                                                                        
        dataset_lookup_segmento     : [],
        dados_lookup_segmento       : [],
        dataSourceConfig            : [],
        cd_empresa                  : 0,
        cd_menu                     : 0,     
        cd_cliente                  : 0,
        tipo_pessoa                 : '',
        popup                       : false,
        popup_pesquisa_cliente      : false,
        popup_empresa               : false,
        popup_cadastro_contato      : false,
        cd_api                      : 0,
        api                         : 0,
        funil                       : '',
        inotifica                   : 0,
        nm_json                     : [],
        dados_pipeline              : [],
        dados_lookuup_etapa         : [],
        dataset_lookup_etapa        : [],
        etapa                       : [],
        result                      : 0,
        dados_cliente               : [],
        novo_contato                : '',             
        novo_celular                : '',                 
        novo_telefone               : '',                
        novo_email                  : '',               
        cd_user                     : '',
        popup_insere_empresa        : false, 
        nova_organizacao            : '',
        nova_organizacao_fantasia   : '',
        dados_lookup_destinatario   : [],
        dataset_lookup_destinatario : [],
        tipo_destinatario           : '',
        dados_lookup_tipo_pessoa    : [],
        dataset_lookup_tipo_pessoa  : [],
        segmento_organizacao        : '',
        pesquisa_contato            : {},
        btn_send                    : [],
        pesquisa_business           : {},
        btn_send_business           : [],
        cd_organizacao              : 0,
        cd_contato_crm              : 0,
        usuario                     : 0,
        popup_finaliza              : false,
        etapaHistorico              : 0,
        proxima_etapa               : 0,
        oportunidade                : 0,
        historico_pop               : false,
        cd_controle                 : 0,
        consulta_historico          : {},
        btn_finaliza                : [],
        oportunidade_finaliza       : 0,
        ratingContato               : 0,
        popup_confirma_ganho        : false,
        nm_motivo_cancelamento      : '',
        popup_confirma_perda        : false,
        dt_previsto_fechamento      : '',
        exclusao_oportunidade       : []
    }
  },
  async created() {
         config({ defaultCurrency: 'BRL' });  
         loadMessages(ptMessages);
         locale(navigator.language);     
        
         this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();      
         this.dt_final   = new Date(localStorage.dt_final).toLocaleDateString();    
         this.hoje       = new Date().toLocaleDateString();  
         var h           = new Date().toLocaleTimeString();  
         this.hora       = h.substring(0,5);   
         this.usuario    = localStorage.cd_usuario;
     
      await this.carregaDados();     
       
      await this.showMenu();
      this.cd_user = localStorage.cd_usuario;
  },

  methods: { 

  async showMenu() {
   this.cd_empresa = localStorage.cd_empresa;
   this.cd_cliente = localStorage.cd_cliente;
   this.cd_menu    = localStorage.cd_menu;
   this.cd_api     = localStorage.cd_api;
   this.api        = localStorage.nm_identificacao_api;

   var data = new Date(),
       dia  = data.getDate().toString(),
       diaF = (dia.length == 1) ? '0'+dia : dia,
       mes  = (data.getMonth()+1).toString(), //+1 pois no getMonth Janeiro começa com zero.
       mesF = (mes.length == 1) ? '0'+mes : mes,
       anoF = data.getFullYear();
       
       localStorage.dt_inicial        =  mes+"-"+dia+"-"+anoF;
       localStorage.dt_final          =  mesF+"-"+diaF+"-"+anoF;
       localStorage.cd_parametro      = 0;

       dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';


       sParametroApi = dados.nm_api_parametro;

    if ((!dados.nm_identificacao_api == '') && (!dados.nm_identificacao_api == this.api)) {
      this.api = dados.nm_identificacao_api;
    }


    localStorage.cd_tipo_consulta = 0;

    if (!dados.cd_tipo_consulta == 0) {
       dados.cd_tipo_consulta;
    }

    this.tituloMenu               = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';

    this.tituloMenu+'.xlsx';

    this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));  
    //this.total   = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));


 },
 async carregaDados() {
         
         await this.showMenu();
           
  
         if (this.inotifica == 0 ) {
            notify(`Aguarde... estamos montando a consulta para você, aguarde !`);
            this.inotifica = 1;
         }   
          
           let sApi = sParametroApi;

           this.dataSourceConfig = await Procedimento.montarProcedimento(
                this.cd_empresa, 
                this.cd_cliente, 
                this.api, 
                sApi  ); 

                //console.log(this.dataSourceConfig, 'datasource')

  //        for (let i = 0, max=this.dataSourceConfig.length; i<max; i += 1) {
  //
  //          this.statuses.push(this.dataSourceConfig[i].nm_etapa);
  //        }
  //        statuses.forEach(status => {
  //            this.lists.push(tasks.filter(task => task.Task_Status === status));
  //  });

          //  
    },

    onTaskDragStart(e) {
      e.itemData = e.fromData.cd_etapa;
      this.etapaHistorico = e.itemData
      //console.log(e)
    }, 

    async onTaskDrop(e) {
      
      this.oportunidade  = 0
      this.proxima_etapa =  e.toData.cd_etapa
      
      this.oportunidade  =  this.dados_pipeline[e.fromIndex].cd_oportunidade;
      
      
      this.nm_json = {
        "cd_parametro"        : 3,
        "proxima_etapa"       : this.proxima_etapa,
        "update_oportunidade" : this.oportunidade,
        "cd_usuario"          : this.cd_user
      }
      var api_update = '538/745';
      var update_etapa =  await Incluir.incluirRegistro(api_update,this.nm_json);
      
    //Recarregar o menu
      var api_consulta = '539/746'
      this.nm_json = {
         "cd_parametro"         : 0,
         "cd_usuario"           : this.usuario
      }
      //console.log(this.nm_json, 'json inicial')
      
      this.dados_pipeline = await Incluir.incluirRegistro(api_consulta,this.nm_json);
      notify(update_etapa[0].Msg)
      //console.log(this.dados_pipeline, 'dados iniciais')
      
    }

  }

}  

</script>

<style>

.toolbar-label,
.toolbar-label > b {
    font-size: 16px;
}
#products {
    margin-top: 10px;
}

#kanban {
    white-space: nowrap;
}

.list {
    border-radius: 8px;
    margin: 5px;
    background-color: rgba(192, 192, 192, 0.4);
    display: inline-block;
    vertical-align: top;
    white-space: normal;
}

.list-title {
    font-size: 16px;
    padding: 10px;
    padding-left: 30px;
    margin-bottom: -10px;
    font-weight: bold;
    cursor: pointer;
}

.scrollable-list {
    height: 400px;
    width: 260px;
}

.sortable-cards {
    min-height: 380px
}

.card {
    position: relative;
    background-color: white;
    box-sizing: border-box;
    width: 230px;
    padding: 10px 20px;
    margin: 10px;
    cursor: pointer;
}

.card-subject {
    padding-bottom: 10px;
}

.card-assignee {
    opacity: 0.6;
}

.card-priority {
    position: absolute;
    top: 10px;
    bottom: 10px;
    left: 5px;
    width: 5px;
    border-radius: 2px;
    background: #86C285;
}

.priority-1 {
    background: #ADADAD;
}

.priority-2 {
    background: #86C285;
}

.priority-3 {
    background: #EDC578;
}

.priority-4 {
    background: #EF7D59;
}

.dx-sortable {
    display: block;
}
.orange {
  color: #ff5722;
}
.cadastro-contato{
  width: 100%;
}
.espaco-interno{
  margin-top: 2px;
  margin-bottom: 2px;
}
.separador-horizontal{
  width: 100%;
  height: 1px;
  background-color: rgb(164, 164, 255);
  color: white; 
  
}
.separator-invisivel{
  width: 100%;
  height: 1px;
  background-color: white;
  color: white;  
}
.titulo-cadastro{
  margin-bottom: 0;
}
.classificacao{
  margin-bottom: 0;
  font-size: 16px;
}
.titulo{
  padding: 0;
  color: whitesmoke;
  background-color: rgb(231, 132, 18);
  border-radius: 5px;
  margin-bottom: 10px;
}
.sub-titulo{
  color: rgb(7, 7, 7);
}
.button-card{
  display: flexbox;
  float: right;
  
}
.botao-historico{
  margin: 20px 20px 0 0;
  width: 100px;
  height: 40px;
}
.rating{
  margin-left: 20px;
}
.etp{
  margin-right: 100px;
  margin-left: 5px;
}
</style>