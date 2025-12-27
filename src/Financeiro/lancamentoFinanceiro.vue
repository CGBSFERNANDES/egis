<template>
<div>
  <div v-if="this.cd_movimento > 0" class="text-h6 text-bold margin1 row items-center">
    <div class="col margin1">
      {{titulo_menu}} - {{cd_movimento}}
    </div> 
    <div class="col margin1">
      <q-btn class="margin1" style="float:right" size="sm"  round color="black" icon="event"  @click="popClickData()"> 
        <q-tooltip>
          Alterar Data de pesquisa
        </q-tooltip>
      </q-btn>
      <q-btn  class="margin1" style="float:right" size="sm" round color="negative" icon="delete"  @click="ExcluirMovimento()"> 
        <q-tooltip>
          Excluir movimento
        </q-tooltip>
      </q-btn>
      <q-btn  class="margin1" style="float:right" size="sm" round color="amber-9" icon="autorenew"  @click="AlterarMovimento()"> 
        <q-tooltip>
          Alterar movimento
        </q-tooltip>
      </q-btn>

    </div>  
    
  </div>

  <div v-else class="text-h6 text-bold margin1 row">
    <div class="col margin1">
      {{titulo_menu}}
    </div> 
    <div class="col">
      <q-btn class="margin1" style="float:right" size="sm"  round color="black" icon="event"  @click="popClickData()"> 
        <q-tooltip>
          Alterar Data de pesquisa
        </q-tooltip>
      </q-btn>
      <q-btn  class="margin1" style="float:right" size="sm" round color="negative" icon="delete"  @click="ExcluirMovimento()"> 
        <q-tooltip>
          Excluir movimento
        </q-tooltip>
      </q-btn>
      <q-btn  class="margin1" style="float:right" size="sm" round color="amber-9" icon="autorenew"  @click="AlterarMovimento()"> 
        <q-tooltip>
          Alterar movimento
        </q-tooltip>
      </q-btn>
    </div>  
  </div>

  <div class="">
    <div class="margin1">
       <q-tabs v-model="tab" dense no-caps inline-label class="bg-red-2 text-black" style="border-radius:10px">
        <q-tab name="consulta" icon="query_stats" label="Consulta" />
        <q-tab name="lancamento" icon="app_registration" label="Lançamento" />
        <q-tab name="documento" icon="folder" label="Documento" />
        <q-tab name="historico" icon="schedule" label="Histórico" />
      </q-tabs>
    </div>

    <q-tab-panels class="" style="background: #F2F2F2" v-model="tab" animated swipeable vertical transition-prev="jump-up" transition-next="jump-up">
      <!------------------------------------------------->
      <q-tab-panel name="consulta">
        <grid
          :cd_menuID="7386"
          :cd_apiID="718"
          :cd_parametroID="0"
          :cd_consulta="1"
          :nm_json="this.dataSourceConfig"
          ref="grid_c">
        </grid>
      </q-tab-panel>
      <!------------------------------------------------->
      <q-tab-panel name="lancamento">

          <div class="row borda-bloco shadow-2">
            <q-select
              label="Tipo de Lançamento"
              class="tres-tela margin1"
              v-model="lancamento"
              input-debounce="0"
              @input="InputLancamento()"
              :options="this.lookup_lancamento"
              option-value="cd_tipo_lancamento"
              option-label="nm_tipo_lancamento"
            >
              <template v-slot:prepend>
                <q-icon name="format_list_bulleted" />
              </template>
            </q-select>

            <q-select
              label="Tipo de Documento"
              class="tres-tela margin1"
              v-model="tipo_doc"
              input-debounce="0"
              :options="this.dataset_doc"
              option-value="cd_tipo_documento"
              option-label="nm_tipo_documento"
            >
              <template v-slot:prepend>
                <q-icon name="receipt_long" />
              </template>
            </q-select>

            <q-input class="tres-tela margin1" v-model="nm_identificacao_documento" type="text" label="Identificação Documento">
              <template v-slot:prepend>
                <q-icon name="format_italic" />
              </template>
            </q-input>

            <q-select
              label="Conta"
              class="tres-tela margin1"
              v-model="conta"
              input-debounce="0"
              :options="this.lookup_conta"
              option-value="Codigo"
              option-label="ContaCorrente"
            >
              <template v-slot:prepend>
                <q-icon name="receipt_long" />
              </template>
            </q-select>



            <q-select
              label="Portador"
              v-show="flag_portador == true"
              class="tres-tela margin1"
              v-model="portador"
              input-debounce="0"
              :options="this.lookup_portador"
              option-value="cd_portador"
              option-label="nm_portador"
            >
              <template v-slot:prepend>
                <q-icon name="receipt_long" />
              </template>
            </q-select>


            <!--<q-select
              label="Caixa"
              class="tres-tela margin1"
              v-model="caixa"
              input-debounce="0"
              :options="this.lookup_caixa"
              option-value="cd_tipo_caixa"
              option-label="nm_tipo_caixa"
            >
              <template v-slot:prepend>
                <q-icon name="receipt_long" />
              </template>
            </q-select>-->

            <q-input v-model="dt_emissao" class="tres-tela margin1"  mask="##/##/####" label="Emissão">
              <template v-slot:prepend>
                <q-icon name="today" />
              </template>

              <template v-slot:append>
                <q-btn icon="event" color="orange-10" round size="sm" class="cursor-pointer">
                  <q-popup-proxy ref="qDateProxy" cover transition-show="scale" transition-hide="scale">
                    <q-date color="orange-10" id="data-pop" v-model="dt_emissao"  mask="DD/MM/YYYY" class="qdate" >
                      <div class="row items-center justify-end">
                        <q-btn v-close-popup round color="orange-10" icon="close" size="sm" />
                      </div>
                    </q-date>
                  </q-popup-proxy>
                </q-btn>
              </template>
            </q-input>

            <q-input v-model="dt_vencimento" class="tres-tela margin1"  mask="##/##/####" label="Vencimento">
              <template v-slot:prepend>
                <q-icon name="event_available" />
              </template>

              <template v-slot:append>
                <q-btn icon="event" color="orange-10" round size="sm" class="cursor-pointer">
                  <q-popup-proxy ref="qDateProxy" cover transition-show="scale" transition-hide="scale">
                    <q-date color="orange-10" id="data-pop"  mask="DD/MM/YYYY"  v-model="dt_vencimento" class="qdate" >
                      <div class="row items-center justify-end">
                        <q-btn v-close-popup round color="orange-10" icon="close" size="sm" />
                      </div>
                    </q-date>
                  </q-popup-proxy>
                </q-btn>
              </template>
            </q-input>
          </div>
          <br>
          <div class="row borda-bloco shadow-2">

            <q-file v-model="getUrl" multiple label="Comprovantes" use-chips class="tres-tela margin1" @blur="CriaVarBinary(1)">
              <template v-slot:prepend>
                <q-icon name="upload_file" />
              </template>
            </q-file>

            <q-input class="tres-tela margin1" v-model="vl_movimento" type="text" label="Valor" @blur="FormatarVL()">
              <template v-slot:prepend>
                <q-icon name="paid" />
              </template>
            </q-input>

            <q-input class="tres-tela margin1" v-model="parcelas" type="number" label="Parcelas">
              <template v-slot:prepend>
                <q-icon name="format_list_numbered" />
              </template>
            </q-input>
         

            <q-select
              label="Plano Financeiro"
              class="tres-tela margin1"
              v-model="plano"
              input-debounce="0"
              :options="this.dataset_plano"
              option-value="cd_plano_financeiro"
              option-label="nm_conta_plano_financeiro"
            >
              <template v-slot:prepend>
                <q-icon name="receipt_long" />
              </template>
            </q-select>

            <q-select
              label="Centro Custo"
              class="tres-tela margin1"
              v-model="centro"
              input-debounce="0"
              :options="this.lookup_centro"
              option-value="cd_centro_custo"
              option-label="nm_centro_custo"
            >
              <template v-slot:prepend>
                <q-icon name="request_quote" />
              </template>
            </q-select>

            <q-select
              label="Tipo Operação"
              class="tres-tela margin1"
              v-model="operacao"
              input-debounce="0"
              :options="this.lookup_operacao"
              option-value="cd_tipo_operacao"
              option-label="nm_tipo_operacao"
            >
              <template v-slot:prepend>
                <q-icon name="checklist_rtl" />
              </template>
            </q-select>
          </div>
          <br>

          <div class="row borda-bloco shadow-2">

          <q-select
            label="Histórico"
            class="tres-tela margin1"
            v-model="historico"
            input-debounce="0"
            :options="this.lookup_historico"
            option-value="cd_historico_financeiro"
            option-label="nm_historico_financeiro"
          >
            <template v-slot:prepend>
              <q-icon name="timeline" />
            </template>
          </q-select>

          <q-input class="tres-tela margin1" v-model="nm_obs_movimento" type="text" label="Observação" autogrow>
            <template v-slot:prepend>
              <q-icon name="description" />
            </template>
          </q-input>

          <q-file v-model="getUrlFoto" multiple label="Foto" use-chips class="tres-tela margin1" @blur="CriaVarBinary(2)">
            <template v-slot:prepend>
              <q-icon name="add_a_photo" />
            </template>
          </q-file>

          <q-input class="tres-tela margin1" v-model="nm_codigo_barra" type="text" label="Código de Barra">
            <template v-slot:prepend>
              <q-icon name="qr_code" />
            </template>
          </q-input>

          <q-select
            label="Situação do Documento"
            class="tres-tela margin1"
            v-model="situacao"
            input-debounce="0"
            :options="this.lookup_situacao"
            option-value="cd_situacao_documento"
            option-label="nm_situacao_documento"
          >
            <template v-slot:prepend>
              <q-icon name="post_add" />
            </template>
          </q-select>

           <q-input class="tres-tela margin1" v-model="nm_complemento" type="text" autogrow label="Complemento">
              <template v-slot:prepend>
                <q-icon name="edit_note" />
              </template>
            </q-input>
        </div>
        <br>

        <div class="row borda-bloco shadow-2">
          <q-input class="col margin1" v-model="ds_movimento" type="text" autogrow label="Descritivo">
            <template v-slot:prepend>
              <q-icon name="edit_note" />
            </template>
          </q-input>
        </div>


        <div class="col margin1 items-end">
          <q-btn class="margin1" rounded style="float:right" flat color="positive" icon="check" label="Gravar" @click="GravaLancamento()"/>
          <q-btn class="margin1" rounded style="float:right" flat color="amber-8" icon="delete" label="Limpar" @click="Limpar()"/>
        </div>


       
        
      </q-tab-panel>
      <!------------------------------------------------->
      <q-tab-panel name="documento">
        DOCUMENTO
      </q-tab-panel>
      <!------------------------------------------------->
      <q-tab-panel name="historico">
        HISTÓRICO
      </q-tab-panel>
    </q-tab-panels>
    


    
    
  </div>
  <!--------------------------------------------------------------------------------->
  <div v-if="popupData == true">
      <q-dialog v-model="popupData" persistent>
        <q-card>
          <q-card-section class="row items-center q-pb-none">
            <div class="text-h6">Seleção de Data</div>
            <q-space />
            <q-btn icon="close" @click="popClickData()" flat round dense v-close-popup />
          </q-card-section>

          <selecaoData :cd_volta_home="1" />

        </q-card>
      </q-dialog>
    </div> 
</div>
</template>

<script>
import Menu from '../http/menu';
import config from 'devextreme/core/config';
import notify from 'devextreme/ui/notify';
import Lookup from '../http/lookup'
import { locale, loadMessages } from "devextreme/localization";
import ptMessages from "devextreme/localization/messages/pt.json";
import Incluir from '../http/incluir_registro';
import Hoje from '../http/dataEscrita'
import Funcoes from '../http/funcoes-padroes'
import FormataData from '../http/formataData'
import selecaoData from '../views/selecao-periodo.vue';
import grid from '../views/grid.vue'

export default {
  name: 'lancamentoFinanceiro',
  data(){
    return{
      cd_empresa                 : localStorage.cd_empresa,
      cd_api                     : localStorage.cd_api,
      cd_menu                    : localStorage.cd_menu,
      cd_usuario                 : localStorage.cd_usuario,
      titulo_menu                : '',
      api_financeiro             : '',
      lancamento                 : '',
      lookup_lancamento          : [],
      tab                        : 'consulta',
      cd_tipo_lancamento         : 0,
      cd_movimento               : 0,
      flag_campo                 : false,
      parcelas                   : 1,
      tipo_doc                   : '',
      dataset_doc                : [],
      lookup_conta               : [],
      nm_identificacao_documento : '', 
      conta                      : '',
      dt_emissao                 : '',
      lookup_caixa               : [],
      caixa                      : '',
      dt_vencimento              : '',
      flag_portador              : false,
      lookup_portador            : [],
      portador                   : '',
      getUrl                     : [],
      list_doc                   : [],
      vl_movimento               : '',
      dataset_plano              : [],
      plano                      : '',
      lookup_centro              : [],
      centro                     : '',
      lookup_operacao            : [],
      operacao                   : '',
      lookup_historico           : [],
      historico                  : '',
      nm_obs_movimento           : '',
      linha                      : {},
      getUrlFoto                 : [],
      fotos                      : [],
      popupData                  : false,
      nm_codigo_barra            : '',
      lookup_situacao            : [],
      situacao                   : '',
      alteracao                  : false,
      nm_complemento             : '',
      ds_movimento               : '',
      dataSourceConfig           : {
        "cd_parametro"  : 5,
        "cd_usuario"    : localStorage.cd_usuario,
        "dt_inicial"    : localStorage.dt_inicial,
        "dt_final"      : localStorage.dt_final
      }

    }
  },
  async created(){
    config({ defaultCurrency: 'BRL' });  
    loadMessages(ptMessages);
    locale(navigator.language); 
    this.dt_emissao = Hoje.DataAtual();
    this.dt_vencimento = Hoje.DataAtual();

    var dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';
    this.titulo_menu = dados.nm_menu_titulo;
    this.api_financeiro = dados.nm_identificacao_api;

    var dados_doc   = await Lookup.montarSelect(this.cd_empresa,187) 
    this.dataset_doc = JSON.parse(JSON.parse(JSON.stringify(dados_doc.dataset)));

    var dados_caixa   = await Lookup.montarSelect(this.cd_empresa,409) 
    this.lookup_caixa = JSON.parse(JSON.parse(JSON.stringify(dados_caixa.dataset)))
    if(this.lookup_caixa.length == 1){
      this.caixa = {
        "cd_tipo_caixa" : this.lookup_caixa[0].cd_tipo_caixa,
        "nm_tipo_caixa" : this.lookup_caixa[0].nm_tipo_caixa
      }
    }else{
      this.lookup_caixa = this.lookup_caixa.sort(function (a,b){
        if(a.nm_tipo_caixa < b.nm_tipo_caixa) return -1;   
        return 1;
      });
    }

    this.dataset_doc = this.dataset_doc.sort(function (a,b){
      if(a.nm_tipo_documento < b.nm_tipo_documento) return -1;   
      return 1;
    });

    this.CarregaLancamento();
    this.CarregaConta();
    this.ConsultaPortador();
    var dados_plano    = await Lookup.montarSelect(this.cd_empresa,414) 
    this.dataset_plano = JSON.parse(JSON.parse(JSON.stringify(dados_plano.dataset)));
    this.dataset_plano = this.dataset_plano.sort(function (a,b){
      if(a.nm_conta_plano_financeiro < b.nm_conta_plano_financeiro) return -1;   
      return 1;
    });
    this.CarregaCentro();
    var dados_operacao   = await Lookup.montarSelect(this.cd_empresa,198) 
    this.lookup_operacao = JSON.parse(JSON.parse(JSON.stringify(dados_operacao.dataset)))
    this.lookup_operacao = this.lookup_operacao.sort(function (a,b){
      if(a.nm_tipo_operacao < b.nm_tipo_operacao) return -1;   
      return 1;
    });

    var dados_historico   = await Lookup.montarSelect(this.cd_empresa,411) 
    this.lookup_historico = JSON.parse(JSON.parse(JSON.stringify(dados_historico.dataset)))

    this.lookup_historico = this.lookup_historico.sort(function (a,b){
      if(a.nm_historico_financeiro < b.nm_historico_financeiro) return -1;   
      return 1;
    });

    var dados_situacao   = await Lookup.montarSelect(this.cd_empresa,5444) 
    this.lookup_situacao = JSON.parse(JSON.parse(JSON.stringify(dados_situacao.dataset)))

    this.lookup_situacao = this.lookup_situacao.sort(function (a,b){
      if(a.nm_situacao_documento < b.nm_situacao_documento) return -1;   
      return 1;
    });


  },
  watch:{
    tab(A,B){
      if(this.tab == 'lancamento'){
        this.flag_campo = true;
      }else if(this.tab == 'consulta'){
        this.alteracao = false;
        this.cd_movimento = 0
        this.linha = {};
        this.Limpar();
      }else{
        this.flag_campo = false;
      }
    },
    getUrl(A,B){
      this.list_doc = [];
      this.CriaVarBinary(1);
    },
    getUrlFoto(A,B){
      this.fotos = [];
      this.CriaVarBinary(2);
    }

  },
  components:{
    selecaoData,
    grid
  },
  methods:{
    async AlterarMovimento(){
            //aqui

      this.linha = grid.Selecionada();
      this.cd_movimento = this.linha.cd_movimento;
      this.lancamento = {
        cd_tipo_lancamento : this.linha.cd_tipo_lancamento,
        nm_tipo_lancamento : this.linha.nm_tipo_lancamento
      }
      this.tipo_doc = {
        "cd_tipo_documento" : this.linha.cd_tipo_documento,
        "nm_tipo_documento" : this.linha.nm_tipo_documento
      }
      //this.nm_identificacao_documento = this.linha.nm

      console.log(this.linha)
      this.tab = 'lancamento'

    },
    async ExcluirMovimento(){
      this.linha = grid.Selecionada();
      let e = {
        "cd_parametro" : 6,
        "cd_movimento" : this.linha.cd_movimento
      }
      console.log(e)
      var exclusao = await Incluir.incluirRegistro(this.api_financeiro,e);
      notify(exclusao[0].Msg);
      this.$refs.grid_c.carregaDados();
    },
    popClickData(){
      if(this.popupData == true){
        this.popupData = false;
      }else{
        this.popupData = true;
      }
    },
    Limpar(){
      this.lancamento                 = '';
      this.tipo_doc                   = '';
      this.nm_identificacao_documento = '';
      this.conta                      = '';
      this.dt_emissao                 = Hoje.DataAtual();
      this.dt_vencimento              = Hoje.DataAtual();
      this.getUrl                     = [];
      this.vl_movimento               = '';
      this.parcelas                   = 1;
      this.plano                      = '';
      this.centro                     = '';
      this.operacao                   = '';
      this.historico                  = '';
      this.nm_obs_movimento           = '';
      this.getUrlFoto                 = [];
      this.nm_codigo_barra            = '';
      this.situacao                   = '';
      this.portador                   = '';
      this.nm_complemento             = '';
      this.ds_movimento               = '';

    },

    async CarregaLancamento(){
      let c = {
        "cd_parametro" : 0,
      }
      console.log(c)
      this.lookup_lancamento = await Incluir.incluirRegistro(this.api_financeiro,c);

    },

    async GravaLancamento(){
      if(this.lancamento == ''){
        notify('Selecione o tipo de Lançamento!');
        return
      }

      let c = {
        "cd_parametro" : 1,
        "cd_tipo_lancamento"         : this.lancamento.cd_tipo_lancamento,
        "cd_tipo_documento"          : this.tipo_doc.cd_tipo_documento,
        "nm_identificacao_documento" : this.nm_identificacao_documento,
        "cd_conta"                   : this.conta.Codigo,
        "cd_tipo_lancamento"         : this.lancamento.cd_tipo_lancamento,
        "cd_tipo_caixa"              : this.caixa.cd_tipo_caixa,
        "dt_emissao"                 : FormataData.formataDataSQL(this.dt_emissao),
        "dt_vencimento"              : FormataData.formataDataSQL(this.dt_vencimento),
        "vl_movimento"               : this.vl_movimento,
        "qt_parcela"                 : this.parcelas,
        "cd_plano_financeiro"        : this.plano.cd_plano_financeiro,
        "cd_centro_custo"            : this.centro.cd_centro_custo,
        "cd_tipo_operacao"           : this.operacao.cd_tipo_operacao,
        "cd_historico_financeiro"    : this.historico.cd_historico_financeiro,
        "nm_obs_movimento"           : this.nm_obs_movimento,
        "nm_codigo_barra"            : this.nm_codigo_barra,
        "cd_situacao_documento"      : this.situacao.cd_situacao_documento,
        "cd_portador"                : this.portador.cd_portador,
        "cd_usuario"                 : this.cd_usuario,
        "nm_complemento"             : this.nm_complemento,
        "ds_movimento"               : this.ds_movimento,
      }
      console.log(c)
      
      var re = await Incluir.incluirRegistro(this.api_financeiro,c);
      notify(re[0].Msg);
      //gravar o list_doc com for e fotos tbm
      this.alteracao = true;
      this.cd_tipo_lancamento = re[0].cd_tipo_lancamento;
      this.cd_movimento       = re[0].cd_movimento;
      this.flag_campo         = true;
      this.tab = 'consulta'
    },

    async CarregaConta(){
      let c = {
        "cd_parametro" : 2
      }
      console.log(c)
      this.lookup_conta = await Incluir.incluirRegistro(this.api_financeiro,c);
      if(this.lookup_conta.length == 1){
        this.conta = {
          "Codigo"        : this.lookup_conta[0].Codigo,
          "ContaCorrente" : this.lookup_conta[0].ContaCorrente
        }
      }
    },

    async InputLancamento(){
      if(this.lancamento.cd_tipo_lancamento == 1){
        this.flag_portador = true;
      }else{
        this.flag_portador = false;
      }
    },

    async ConsultaPortador(){
      let c = {
        "cd_parametro" : 3
      }
      console.log(c)
      this.lookup_portador = await Incluir.incluirRegistro(this.api_financeiro,c);
      this.lookup_portador = this.lookup_portador.sort(function (a,b){
        if(a.nm_portador < b.nm_portador) return -1;   
        return 1;
      });
    },
    async CriaVarBinary(index){
      if(index == 1){
        this.list_doc = [];
      }else if(index == 2){
        this.fotos = [];
      }
      if(this.getUrl.length > 0 && index == 1){
        for(let a=0; a<this.getUrl.length; a++){
          await Funcoes.CriaVb(this.getUrl[a])
          var documento = localStorage.vb_document;
          if(documento.length > 10){
            this.list_doc.push(documento)
            localStorage.vb_document = '';
            
          }
          await Funcoes.sleep(500)
        }
      }else if(this.getUrlFoto.length > 0 && index == 2){
        for(let g=0;g<this.getUrlFoto.length;g++){
          await Funcoes.CriaVb(this.getUrlFoto[g])
          var documento = localStorage.vb_document;
          if(documento.length > 10){
            this.fotos.push(documento)
            localStorage.vb_document = '';
          }
          await Funcoes.sleep(500)
        }
      }
      
    },
    async FormatarVL(){
      this.vl_movimento = await Funcoes.FormataValor(this.vl_movimento)
    },
    async CarregaCentro(){
      let c = {
        "cd_parametro" : 4
      }
      console.log(c)
      this.lookup_centro = await Incluir.incluirRegistro(this.api_financeiro,c);
    }

    


  }
}
</script>

<style scoped>
.margin1{
  margin: 0.4vw 0.7vw;
  padding:0;
}
.meia-tela{
  width: 47.5%;
}
.tres-tela{
  width: 31%;
}
.borda-bloco{
  border: solid 1px rgb(170, 170, 170) ;
  border-radius: 10px;
}
.bg-padrao {
  background: #F42436  !important;
}
#data-pop{
  flex-direction: none !important;
}
.qdate{
  width: 310px;
  overflow-x: hidden;
}
.borda{
  border: solid 1px rgb(170, 170, 170) ;
}
@media (max-width: 870px){
  .tres-tela{
      width: 100% !important;
  }
}
</style>