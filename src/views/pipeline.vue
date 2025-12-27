<template>
  <div class="kanban">
    <div class="row">
      <h2 class="col">Pipeline - Administração de Oportunidade de Negócios</h2>
      <q-btn class="botao-historico" color="primary" outline rounded label="Finalizar" @click="onFinaliza"/>
      <q-btn class="botao-historico" color="primary" outline rounded label="Histórico" @click="onHistorico"/>

    </div>
    <div>
      <q-toolbar class="bg-white q-my-md shadow-2 toolbar etp" >
        <q-btn color="primary" label="Novo" icon="add" @click="onNewLead()">
        </q-btn>
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
      <q-dialog 
        v-model="popup"
        transition-show="slide-up"
        transition-hide="slide-down"
        full-width
      >
      <q-card>
        <q-card-section>
          <div class="text-h6">Oportunidade</div>
        </q-card-section>
        <div class="separador-horizontal">-</div>
        <q-card-section class="q-pt-none cadastro-contato">
            <q-input item-aligned class="espaco-interno" v-model="contact_pesq"  type="text"  label="Contato" >
              <template v-slot:prepend>
                <q-icon name="person_add_alt_1" />
              </template>

              <template v-slot:append>
                <q-btn round color="primary" icon="search" @click="onPesquisaContato" @blur="onPesquisaContato">
                  <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                     <strong>Pesquisar</strong>
                  </q-tooltip>
                </q-btn>
                <q-btn round color="primary" icon="add" @click="onAddContato">
                  <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                     <strong>Novo Cadastro</strong>
                  </q-tooltip>
                </q-btn>
              </template>
            </q-input>
          <q-input item-aligned class="espaco-interno" v-model="business" type="text" label="Organização">
            <template v-slot:prepend>
              <q-icon name="work" />
            </template>
            <template v-slot:append>
                <q-btn round color="primary" icon="search" @click="onPesquisaEmpresa" @blur="onPesquisaEmpresa">
                  <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                     <strong>Pesquisar</strong>
                  </q-tooltip>
                </q-btn>
                <q-btn round color="primary" icon="add" @click="onAddEmpresa">
                  <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                     <strong>Novo Cadastro</strong>
                  </q-tooltip>
                </q-btn>
            </template>
          </q-input>

          <template v-slot:append>
              <q-btn round color="grey-6" icon="add" />
            </template>   


          <q-input item-aligned class="espaco-interno" v-model="title" type="text"   label="Oportunidade">
            <template v-slot:prepend>
              <q-icon name="drive_file_rename_outline" />
            </template>
          </q-input>

          <q-input item-aligned class="espaco-interno" v-model="valor" type="text" label="Valor" reverse-fill-mask mask="###.###.###.###,##">
            <template v-slot:prepend>
              <q-icon name="attach_money" />
            </template>
          </q-input>

          <q-select
            class="select-funil"
            label="Escolha a Etapa"
            v-model="etapa"
            input-debounce="0"
            :options="dataset_lookup_etapa"
            option-value="cd_etapa"
            option-label="nm_etapa"
            item-aligned
          >
            <template v-slot:prepend>
              <q-icon name="sell" />
            </template>
          </q-select>

          <q-input item-aligned class="espaco-interno" mask="##/##/####" v-model="dt_previsto_fechamento" type="text" label="Data prevista de Fechamento"           >
            <template v-slot:prepend>
              <q-icon name="event" />
            </template>
          </q-input>

         <!--CLASSIFICAÇÃO AQUI-->
          <template>
              <div class="q-pa-md">
                <div class="q-gutter-y-md ">
                  <p class="classificacao"><b>Classificação</b></p>
                  <q-rating
                    v-model="ratingModel"                
                    size="2.5em"
                    color="primary" 
                  />
                </div>
              </div>
          </template>
        </q-card-section>
        <q-card-actions align="right" class="bg-white text-teal">
          <q-btn flat label="Salvar"  @click="onInsertOportunidade" />
          <q-btn flat label="Cancelar" v-close-popup />  
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!----------------------------------------------------------------------------------->
    <q-dialog v-model="popup_pesquisa_cliente" style="max-width: 80vw;">
      <q-card>
        <q-card-section>
           <div class="text-h6">Selecione um Cliente</div>
        </q-card-section>

        <q-separator/>

        <q-item v-for="pesquisa_contato in pesquisa_contato" :key="pesquisa_contato.cd_controle" class="q-my-sm" clickable v-ripple>
            <q-item-section avatar>
              <q-avatar color="deep-orange-6" text-color="white">
                {{ pesquisa_contato.letra}}
              </q-avatar>
            </q-item-section>
            
            <q-item-section>
              <q-item-label>{{ dados_cliente.nm_fantasia }}</q-item-label>
              <q-item-label caption lines="1">{{ pesquisa_contato.nm_contato_crm }}</q-item-label>
              <q-item-label caption lines="2">{{ pesquisa_contato.cd_celular }}</q-item-label>
              <q-item-label caption lines="3">{{ pesquisa_contato.nm_email_contato_crm }}</q-item-label>
            </q-item-section>

            <q-item-section side>
              <q-btn round v-model="btn_send" icon="send" color="deep-orange-6" @click="ClienteSelecionado(pesquisa_contato)" clickable />
            </q-item-section>
        </q-item>

      </q-card>
    </q-dialog>
    <!---------------------------------------------------------------->
    <!--PopUp Cadastro Contato-->
    <q-dialog 
      v-model="popup_cadastro_contato"
      transition-show="slide-up"
      transition-hide="slide-down"    
    >
       <q-card style="width: 700px; max-width: 80vw;">
        <q-card-section>
          <div class="text-h6">Novo Contato</div>
        </q-card-section>

        <div class="separador-horizontal">-</div>

        <q-input item-aligned class="espaco-interno" v-model="novo_contato" type="text" label="Nome Completo">
          <template v-slot:prepend>
            <q-icon name="person_add_alt_1" />
          </template>
        </q-input>

        <q-input item-aligned class="espaco-interno" v-model="novo_celular" mask="(##)#####-####" type="text" label="Celular">
          <template v-slot:prepend>
            <q-icon name="phone_iphone" />
          </template>
        </q-input>

        <q-input item-aligned class="espaco-interno" v-model="novo_telefone" mask="(##)####-####" type="text" label="Telefone">
          <template v-slot:prepend>
            <q-icon name="phone" />
          </template>
        </q-input>

        <q-input item-aligned class="espaco-interno" v-model="novo_email" type="email" label="E-Mail">
          <template v-slot:prepend>
            <q-icon name="email" />
          </template>
        </q-input>

         <template>
              <div class="q-pa-md espaco-interno">
               
                  <p class="classificacao"><b>Risco</b></p>
                  <q-rating
                    
                    class="espaco-interno"
                    v-model="ratingContato"
                    size="2.5em"
                    :max="3"
                    icon="dangerous"
                    color="orange-7"
                    item-aligned
                  />
               
              </div>
         </template>
        
       <q-card-actions align="right" class="bg-white text-teal">
         <q-btn flat label="Salvar"  @click="onInsereContato" />
          <q-btn flat label="Cancelar" v-close-popup />
          
       </q-card-actions>

       </q-card>
    </q-dialog>

     <q-dialog v-model="popup_empresa" style="max-width: 80vw;">
      <q-card>
        <q-card-section>
           <div class="text-h6">Selecione uma Organização</div>
        </q-card-section>

        <q-separator/>

        <q-item v-for="pesquisa_business in pesquisa_business" :key="pesquisa_business.cd_controle" class="q-my-sm" clickable v-ripple>
            <q-item-section avatar>
              <q-avatar color="deep-orange-6" text-color="white">
                {{ pesquisa_business.letra}}
              </q-avatar>
            </q-item-section>
            
            <q-item-section>
              <q-item-label>{{ dados_cliente.nm_fantasia }}</q-item-label>
              <q-item-label caption lines="1">{{ pesquisa_business.nm_organizacao }}</q-item-label>
              <q-item-label caption lines="2">{{ pesquisa_business.nm_fantasia }}</q-item-label>
              <q-item-label caption lines="3">{{ pesquisa_business.nm_segmento_mercado}}</q-item-label>
            </q-item-section>

            <q-item-section side>
              <q-btn round v-model="btn_send_business" icon="send" color="deep-orange-6" @click="EmpresaSelecionada(pesquisa_business)" clickable />
            </q-item-section>
        </q-item>

      </q-card>
    </q-dialog>

    <q-dialog v-model="popup_insere_empresa" style="max-width: 80vw;">
        <q-card style="width: 700px; max-width: 80vw;">
          <q-card-section>
            <div class="text-h6">Nova Organização</div>
          </q-card-section>
          <div class="separador-horizontal">-</div>

          <q-input item-aligned class="espaco-interno" v-model="nova_organizacao" type="text" label="Nome">
            <template v-slot:prepend>
              <q-icon name="corporate_fare" />
            </template>
          </q-input>

          <q-input item-aligned class="espaco-interno" v-model="nova_organizacao_fantasia" type="text" :rules="[ val => val.length > 0 || 'Obrigatório' ]" label="Nome Fantasia">
            <template v-slot:prepend>
              <q-icon name="badge" />
            </template>
          </q-input>

          <q-select
              class="select-funil"
              label="Tipo de Destinatário"
              v-model="tipo_destinatario"
              input-debounce="0"
              :options="dataset_lookup_destinatario"
              option-value="cd_tipo_destinatario"
              option-label="nm_tipo_destinatario"
              item-aligned
          >
            <template v-slot:prepend>
               <q-icon name="format_list_bulleted" />
            </template>
          </q-select>

          <q-select
            class="select-funil"
            label="Tipo Pessoa"
            v-model="tipo_pessoa"
            input-debounce="0"
            :options="dataset_lookup_tipo_pessoa"
            option-value="cd_tipo_pessoa"
            option-label="nm_tipo_pessoa"
            item-aligned
          >
            <template v-slot:prepend>
               <q-icon name="format_list_numbered" />
            </template>
          </q-select>

          <q-select
              class="select-funil"
              label="Segmento de Mercado"
              v-model="segmento_organizacao"
              input-debounce="0"
              :options="dataset_lookup_segmento"
              option-value="cd_segmento_mercado"
              option-label="nm_segmento_mercado"
              item-aligned
          >
            <template v-slot:prepend>
               <q-icon name="segment" />
            </template>
            
          </q-select>

          <q-card-actions align="right" class="bg-white text-teal">
              <q-btn flat label="Cancelar" v-close-popup />
              <q-btn flat label="Salvar" @click="oninsertOrganizacao"/>
          </q-card-actions>
        </q-card>
    </q-dialog>
<!-------------------------------------------------------------------------------------------->
 <q-dialog v-model="popup_finaliza" style="max-width: 80vw;" >
      <q-card>
        <q-card-section>
           <div class="text-h6">Finalizar Oportunidade?</div>
           <div><p>Ao Finalizar a Oportunidade ela não aparecerá novamente no seu Pipeline</p></div>
           <q-separator/>
        </q-card-section>
        
         <q-item v-for="dados_pipeline in dados_pipeline" :key="dados_pipeline.cd_controle" class="q-my-sm" clickable v-ripple>
            <q-item-section avatar>
              <q-avatar color="deep-orange-6" text-color="white">
                {{ dados_pipeline.cd_oportunidade}}
              </q-avatar>
            </q-item-section>
            
            <q-item-section>
              <q-item-label>{{ dados_pipeline.nm_titulo_movimento }}</q-item-label>
              
              <q-item-label caption lines="1">{{ dados_pipeline.nm_contato_crm }}</q-item-label>
              <q-item-label caption lines="2"><b>Etapa: {{ dados_pipeline.nm_etapa }}</b></q-item-label>
            </q-item-section>

            <q-item-section side>
              <div class="row">
                  <q-btn round class="col" v-model="btn_finaliza" icon="thumb_up" color="positive" @click="onGanho(dados_pipeline)" clickable >
                      <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                        <strong>Ganho</strong>
                      </q-tooltip>
                  </q-btn>

                  <q-btn round class="col" v-model="btn_finaliza" icon="thumb_down_alt" color="negative" @click="onPerda(dados_pipeline)" clickable>
                   <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                        <strong>Perda</strong>
                      </q-tooltip>
                  </q-btn>

                  <q-btn round class="col" v-model="btn_finaliza" icon="delete" color="primary" @click="onOportunidadeDeletada(dados_pipeline)" clickable >
                      <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                        <strong>Deletar</strong>
                      </q-tooltip>
                  </q-btn>
              </div>
            </q-item-section>
        </q-item>
       <q-card-actions align="right" class="bg-white text-teal">
          <q-btn flat label="Cancelar" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------------------------------->
    <q-dialog v-model="popup_confirma_ganho" style="width: 80vw;" persistent >
      <q-card style="width: 80vw;">
        <q-card-section>
           <div class="text-h6">Alguma Observação?</div>
           <q-separator/>
        </q-card-section>
        
         <q-input item-aligned class="espaco-interno" v-model="nm_motivo_cancelamento" type="text" label="Observação">
            <template v-slot:prepend>
              <q-icon name="corporate_fare" />
            </template>
          </q-input>
    
       <q-card-actions align="right" class="bg-white text-teal">
          <q-btn flat label="Cancelar" v-close-popup />
          <q-btn flat label="Salvar Ganho" @click="EnviaGanho"/>
        </q-card-actions>
      </q-card>
    </q-dialog>
<!--------------------------------------------------------------------------------------------------->
    <q-dialog v-model="popup_confirma_perda" style="width: 80vw;" persistent >
      <q-card style="width: 80vw;">
        <q-card-section>
           <div class="text-h6">Alguma Observação?</div>
           <q-separator/>
        </q-card-section>
        
         <q-input item-aligned class="espaco-interno" v-model="nm_motivo_cancelamento" type="text" label="Observação">
            <template v-slot:prepend>
              <q-icon name="corporate_fare" />
            </template>
          </q-input>
    
       <q-card-actions align="right" class="bg-white text-teal">
          <q-btn flat label="Cancelar" v-close-popup />
          <q-btn flat label="Salvar Perda" @click="EnviaPerda"/>
        </q-card-actions>
      </q-card>
    </q-dialog>

<!---------------------------------------------------------------------------->
<!--Historico--> 
  
    <q-dialog v-model="historico_pop" full-width>
      <q-card>
        <q-card-section>
          <div class="text-h5 row">
            <div class="col"><b>Timeline</b></div>
              <q-btn round color="primary" style="margin-bottom: 8px;" icon="close" v-close-popup />
          </div>
          <q-separator/>
        </q-card-section>
        
        <div class="q-px-lg q-pb-md">
            <q-timeline v-for="consulta_historico in consulta_historico" 
                v-bind:key="consulta_historico.cd_controle"
              >
              <q-timeline-entry
                :title="consulta_historico.nm_acao"
                :subtitle="consulta_historico.dt_base"
                :icon="consulta_historico.icon"
                :color="consulta_historico.color"
                :body="consulta_historico.body"
              >
              </q-timeline-entry>
              <div class="separator-invisivel"></div><!--aqui-->
             </q-timeline>
        </div>
      </q-card>
     
    </q-dialog>
    
  
  </div>
</template>

<script>
   import DxToolbar, { DxItem } from 'devextreme-vue/toolbar';
   import DxButton from 'devextreme-vue/button';
   import notify from 'devextreme/ui/notify';
   import ptMessages from "devextreme/localization/messages/pt.json";
   import { locale, loadMessages } from "devextreme/localization";
   import config from 'devextreme/core/config';
   import { DxScrollView } from 'devextreme-vue/scroll-view';
   import { DxSortable } from 'devextreme-vue/sortable';
   import Procedimento from '../http/procedimento';
   import Menu from '../http/menu';
   import DxTabs from 'devextreme-vue/tabs';
   import Lookup from '../http/lookup';
   import formataData from '../http/formataData'
   import Incluir from '../http/incluir_registro';
   import cliente from '../views/cliente'
   import DxTabPanel from 'devextreme-vue/tab-panel';
   import Cliente from './cliente.vue';

//
     
var sParametroApi = '';
var dados = [];
var filename = '';
var dataset_lookup_Funil = [];


export default {
  components: {
    DxToolbar,    
    DxItem,
    DxScrollView,
    DxSortable,
    DxButton,
    cliente,
    Cliente

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
      this.dados_lookup_segmento       = await Lookup.montarSelect(localStorage.cd_empresa,4860)
      this.dataset_lookup_segmento     = JSON.parse(JSON.parse(JSON.stringify(this.dados_lookup_segmento.dataset)))
      this.dados_lookuup_etapa         = await Lookup.montarSelect(localStorage.cd_empresa,5213)
      this.dataset_lookup_etapa        = JSON.parse(JSON.parse(JSON.stringify(this.dados_lookuup_etapa.dataset)))
      this.dados_lookup_destinatario   = await Lookup.montarSelect(localStorage.cd_empresa,660)
      this.dataset_lookup_destinatario = JSON.parse(JSON.parse(JSON.stringify(this.dados_lookup_destinatario.dataset)))
      this.dados_lookup_tipo_pessoa    = await Lookup.montarSelect(localStorage.cd_empresa,116)
      this.dataset_lookup_tipo_pessoa  = JSON.parse(JSON.parse(JSON.stringify(this.dados_lookup_tipo_pessoa.dataset)))
      
      var api = '539/746'
      var user = localStorage.cd_usuario
      this.nm_json = {
         "cd_parametro"         : 0,
         "cd_usuario"           : this.usuario
      }
     
      this.dados_pipeline = await Incluir.incluirRegistro(api,this.nm_json);
      console.log(this.dados_pipeline,'dados_pipeline')
      for(this.cont = 0; parseInt(this.result.length) > this.cont ; this.cont++ ){
      }
       
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

    filename    = this.tituloMenu+'.xlsx';

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
    onNewLead(){
        this.contact_pesq           = ''
        this.business               = ''
        this.title                  = ''
        this.valor                  = ''
        this.dt_previsto_fechamento = ''
        this.ratingModel            = 0
        this.cd_organizacao         = null
        this.cd_contato_crm         = null
        this.popup                  = true;
      },
    onNovoNegocio(){
      this.popup = true;
    },
    onSalvarCadastro(){
      alert('click')
    },
    async onInsertOportunidade(){
      //console.log(this.contact_pesq)
      //console.log(this.contact_pesq.cd_contato_crm)
      if(this.contact_pesq == '' && this.business == '' ){
        notify('Selecione um contato ou organização!')
        return;
      }
      if (this.dt_previsto_fechamento == ''){
        notify('Digite uma data de Fechamento!')
        return;
      }
      if(this.valor == ''){ 
        notify('Digite um valor!')
        return;
      }
      this.cd_etapa        = this.etapa.cd_etapa;
      if(this.cd_etapa === undefined){ 
        notify('Selecione uma Etapa!')
      return;
      }
      if(this.title == ''){
        notify('Digite o nome da Oportunidade!')
        return;
      }
      if(this.ratingModel == 0){
        notify('Digite a classificação!')
        return;
      }
      

      var data = formataData.formataDataSQL(this.dt_previsto_fechamento); 

    
      var api = '538/745';
      this.nm_json = {
         "cd_parametro"           : 2,
         "cd_usuario"             : this.usuario,
         "cd_organizacao"         : this.cd_organizacao,
         "cd_contato"             : this.cd_contato_crm,
         "nm_titulo_movimento"    : this.title,
         "cd_classificacao"       : this.ratingModel,
         "vl_movimento"           : this.valor,
         "cd_etapa"               : this.cd_etapa,
         "dt_previsto_fechamento" : data
       }
       console.log(this.nm_json,'oportunidade')
       //console.log(this.segmento)
      var incluir = await Incluir.incluirRegistro(api,this.nm_json);
      notify(incluir[0].Msg);
      this.popup = false;

      //Recarrega Menu
      var api_consulta = '539/746'
   
      this.nm_json = {
         "cd_parametro"         : 0,
         "cd_usuario"           : this.usuario
      }
      //console.log(this.nm_json, 'json inicial')  
      this.dados_pipeline = await Incluir.incluirRegistro(api_consulta,this.nm_json);
    
      this.cd_organizacao = null
      this.cd_contato_crm = null
      this.title          = ''
      this.ratingModel    = 0
      this.valor          = '';


    },

    onPesquisaCliente(){
    if (this.contact_pesq == ''){
      notify('Digite parte do nome do Cliente...')
    }else{ 
        this.popup_pesquisa_cliente = true;
    }
    //this.contact_pesq
     
    },

    onInsertNewClient(){
      this.nm_json = {
        "nm_cliente"              : this.nm_cliente
      }
    
    },
    onAddEmpresa(){
      this.nova_organizacao = ''
      this.nova_organizacao_fantasia = ''
      this.popup_insere_empresa = true;
    },

    
    onAddContato(){
      this.novo_contato  = ''
      this.novo_celular  = ''
      this.novo_telefone = ''
      this.novo_email    = ''
      this.ratingContato = 0 
      this.popup_cadastro_contato = true;
      
    },
    
    async onInsereContato(){
      if(this.novo_contato == ''){
        notify('Digite o nome do contato...');
        this.popup_cadastro_contato = true;
        return;
      }
      if(this.novo_email == ''){
        notify('Digite um E-mail válido!')
        this.popup_cadastro_contato = true;
        return;
      }
      var api_contato = '538/745';
      this.cd_user = localStorage.cd_usuario;
      this.nm_json = {
        "cd_parametro"            : 0,
        "cd_usuario"              : this.cd_user,
        "nm_contato"              : this.novo_contato,              
        "cd_telefone"             : this.novo_telefone, 
        "cd_celular"              : this.novo_celular,                
        "nm_email"                : this.novo_email,
        "cd_grau_risco"           : this.ratingContato
      };
      console.log(this.nm_json,'json contato')
      var insert_contato =  await Incluir.incluirRegistro(api_contato,this.nm_json);
      if(insert_contato[0].Cod == 0){
        notify(insert_contato[0].Msg);  
        this.popup_cadastro_contato = true;
      }else{
        notify(insert_contato[0].Msg);  
        this.popup_cadastro_contato = false;
      }
      

    },
    async oninsertOrganizacao(){
      if(this.nova_organizacao == ''){
        notify('Digite o nome da Organização...')
        this.popup_insere_empresa = true;
        return;
      }
      if(this.nova_organizacao_fantasia == ''){
        notify('Digite o nome Fantasia...')
        this.popup_insere_empresa = true;
        return;
      }
      var segmento_empresa    = this.segmento_organizacao.cd_segmento_mercado;
      var tipo_pessoa_empresa = this.tipo_pessoa.cd_tipo_pessoa;
      var destinatario        = this.tipo_destinatario.cd_tipo_destinatario;

      this.nm_json = {
        "cd_parametro"            : 1,
        "cd_usuario"              : this.cd_user,
        "nm_organizacao"          : this.nova_organizacao,
        "nm_fantasia"             : this.nova_organizacao_fantasia,
        "cd_tipo_destinatario"    : destinatario,
        "cd_tipo_pessoa"          : tipo_pessoa_empresa,
        "cd_segmento_mercado"     : segmento_empresa
      };
      //console.log(this.nm_json)
      var api_contato = '538/745';
      var insert_organizacao =  await Incluir.incluirRegistro(api_contato,this.nm_json);
      //console.log(insert_organizacao)
      if(insert_organizacao[0].Cod == 0){
        notify(insert_organizacao[0].Msg)
        this.popup_insere_empresa = true;
        return;
      }else{
        notify(insert_organizacao[0].Msg)
        this.popup_insere_empresa = false;
      }
    
     

    
      this.nova_organizacao = ''
      this.nova_organizacao_fantasia = ''
      

    },
    async onPesquisaContato(){
      var api_pesquisa_contato = '542/749';
      if(this.contact_pesq == ''){
        notify('Digite pelo menos uma letra!');
        this.popup_pesquisa_cliente = false;
        return;
      }

      this.nm_json = {
        "cd_parametro"   : 0,
        "nm_contato_crm" : this.contact_pesq,
      }
      //console.log(this.nm_json,'pesquisa contato')
      this.pesquisa_contato = await Incluir.incluirRegistro(api_pesquisa_contato,this.nm_json);
      if(this.pesquisa_contato[0].Cod == 0){
        notify(this.pesquisa_contato[0].Msg)
        this.onAddContato();
        return;
      }
      this.popup_pesquisa_cliente = true;
      notify(this.pesquisa_contato[0].Msg);
      //console.log(this.pesquisa_contato)
    },

    async onPesquisaEmpresa(){

      var api_empresa = '542/749';
      if(this.business == ''){
          notify('Digite pelo menos uma letra!');
          this.popup_empresa = false;
          return;
      }
    
      this.nm_json = {
        "cd_parametro" : 1,
        "nm_fantasia"  : this.business
      }
      this.pesquisa_business =  await Incluir.incluirRegistro(api_empresa,this.nm_json);
      if(this.pesquisa_business[0].Cod == 0){
        notify(this.pesquisa_business[0].Msg)
        this.onAddEmpresa();
        this.popup_empresa = false;
        return;
      }else{
        notify(this.pesquisa_business[0].Msg);
        this.popup_empresa = true;
      }

    },

    ClienteSelecionado(e){
      this.contact_pesq   = e.nm_contato_crm;
      this.cd_contato_crm = e.cd_contato_crm;
      this.popup_pesquisa_cliente = false;
    },

    EmpresaSelecionada(e){
      this.business       = e.nm_fantasia;
      this.cd_organizacao = e.cd_organizacao;
      this.popup_empresa = false;
    },
    async onFinaliza(){
      notify('Aguarde...')
      var api_consulta = '539/746'
   
      this.nm_json = {
         "cd_parametro"         : 0,
         "cd_usuario"           : this.usuario
      }
      
      //console.log(this.nm_json, 'json inicial')  
      this.dados_pipeline = await Incluir.incluirRegistro(api_consulta,this.nm_json);
      if (this.dados_pipeline[0].Cod == 0){
        notify(this.dados_pipeline[0].Msg)
        this.popup_finaliza = false;
        return;
      }else{
        this.popup_finaliza = true;
      }
    },

    async onFinaliza2(e){
    
      this.oportunidade_finaliza = e.cd_oportunidade;
      //console.log(this.oportunidade_finaliza)
      this.nm_json = {
        
      }
    },
    
    async onGanho(e){
      this.oportunidade_finaliza = e.cd_oportunidade;
      console.log(this.oportunidade_finaliza, 'ganho')
      this.nm_motivo_cancelamento = ''
      this.popup_confirma_ganho = true;
    },

    async EnviaGanho(){
        this.nm_json = {
        "cd_parametro"           : 4,
        "status"                 : 1,
        "oportunidade"           : this.oportunidade_finaliza,
        "cd_usuario"             : this.cd_user,
        "nm_motivo_cancelamento" : this.nm_motivo_cancelamento
      }
      console.log(this.nm_json,'json ganho')
      var api_update   = '538/745';
      var status_ganho =  await Incluir.incluirRegistro(api_update,this.nm_json);
      notify(status_ganho[0].Msg)
      
      var api = '539/746'
      var user = localStorage.cd_usuario
      this.nm_json = {
         "cd_parametro"         : 0,
         "cd_usuario"           : this.usuario
      }
      //console.log(this.nm_json, 'json inicial')  
      this.dados_pipeline = await Incluir.incluirRegistro(api,this.nm_json);
      this.popup_confirma_ganho = false;
      this.popup_finaliza = false;
    },

    async onPerda(e){
      this.oportunidade_finaliza = e.cd_oportunidade;
      console.log(this.oportunidade_finaliza,'perda')
      this.popup_confirma_perda = true;
      
    },
    async EnviaPerda(){
      this.nm_json = {
        "cd_parametro"           : 5,
        "status"                 : 3,
        "oportunidade"           : this.oportunidade_finaliza,
        "cd_usuario"             : this.cd_user,
        "nm_motivo_cancelamento" : this.nm_motivo_cancelamento
      }
      //console.log(this.nm_json,'json Perda')
      var api_update   = '538/745';
      var status_perda =  await Incluir.incluirRegistro(api_update,this.nm_json);
      notify(status_perda[0].Msg)

      this.popup_finaliza = false;

      var api = '539/746'
      var user = localStorage.cd_usuario
      this.nm_json = {
         "cd_parametro"         : 0,
         "cd_usuario"           : this.usuario
      }
      //console.log(this.nm_json, 'json inicial')  
      this.dados_pipeline = await Incluir.incluirRegistro(api,this.nm_json);
      this.popup_confirma_perda = false;
      this.popup_finaliza = false;
    },
    onOportunidadeDeletada(e){
       this.oportunidade_finaliza = e.cd_oportunidade;
       //console.log('entrou')
       this.onDeleta();
    },

    async onDeleta(e){
     
      console.log(this.oportunidade_finaliza)
      this.nm_json = {
         "cd_parametro"         : 6,
         "cd_oportunidade"      : this.oportunidade_finaliza
      }
      console.log(this.nm_json,'json deleta')
        var api_deleta = '538/745'
        this.exclusao_oportunidade = await Incluir.incluirRegistro(api_deleta,this.nm_json);
        notify(this.exclusao_oportunidade[0].Msg);

        var api = '539/746'
        var user = localStorage.cd_usuario
        this.nm_json = {
         "cd_parametro"         : 0,
         "cd_usuario"           : this.usuario
        }
        //console.log(this.nm_json, 'json inicial')  
        this.dados_pipeline = await Incluir.incluirRegistro(api,this.nm_json);
        this.popup_finaliza = false;

      
    },
//----------------------------------------------------------------

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
      
    },
    async onHistorico(){
      var api_timeline = '552/759'
      this.nm_json = {
        "cd_parametro" : 1,
        "cd_usuario"   : this.usuario
      }
      //console.log(this.nm_json, 'historico')
      this.consulta_historico = await Incluir.incluirRegistro(api_timeline,this.nm_json)
      notify(this.consulta_historico[0].Msg)
      //console.log(this.consulta_historico)
      this.historico_pop = true;
    },
    
  
    //getPriorityClass(task) {
    //  return `priority-${task.Task_Priority}`;
    //}

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