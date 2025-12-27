<template>
<div>
    <div class="text-h5 text-bold">Elaboração de Proposta <b>- {{proposta}}</b></div>
    <div class="row text-bold text-center text-h6 items-center self-center">
        <div class="col text-bold text-center items-center self-center">           
            Nós somos a Ino9ve Consultoria Empresarial
        </div>
    </div>
    
    <div class="row bg-primary"  style="border-radius:10px">
        <!--<div v- class="col text-bold text-center text-white text-h6 items-center self-center">
            N° Proposta: {{cd_consulta}}
        </div>-->
        <div class="col text-center text-bold text-white text-h6 items-center self-center" style="border-radius:10px">
            {{hoje}}
        </div>
        <!--<div v-show="this.nm_cliente != ''" class="col text-center text-bold text-white text-h6 items-center self-center">
          {{nm_cliente}}
        </div>-->
    </div>
    <div>
      <!--<div >
        <q-btn style="margin:1%" round color="primary" icon="person" class="col" @click="pop_cli = true"> 
          <q-tooltip anchor="center right" self="center left" :offset="[10, 10]">
            Cliente
          </q-tooltip>
        </q-btn>
      </div>-->
      <div class="borda-bloco shadow-2">

        <div class="row">
          <!--<q-input class="padding1 col" item-aligned @blur="PesquisaProposta()" v-model="proposta" label="N° Proposta" type="text">
              <template v-slot:prepend>
                <q-icon name="pin" />
              </template>
          </q-input>-->
           <q-input class="padding1 col" item-aligned @blur="PesquisaCliente()"  v-model="nm_fantasia_cliente" label="Cliente" type="text">
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
              <!--<template v-slot:append>
                <q-btn style="margin:1%" round color="primary" icon="search" class="col" @click="PesquisaCliente()"> 
                  <q-tooltip anchor="center right" self="center left" :offset="[10, 10]">
                    Cliente
                  </q-tooltip>
                </q-btn>
              </template>-->
          </q-input>
          <q-select
            label="Administradora"
            v-model="cd_administradora"
            input-debounce="0"
            class="col padding1"
            :options="dataset_administradora"
            option-value="cd_administradora"
            option-label="nm_administradora"
            item-aligned
            
          >
            <template v-slot:prepend>
               <q-icon name="account_balance"  />
            </template>
          </q-select>
          <!--<div class="col-2 text-center items-center self-center margin1" v-show="img_consultoria != '' ">
              <q-img
                  class="img-logo "
                  :src="img_consultoria"
                  spinner-color="white"
                  :ratio="16/9"
              />
          </div>-->
        </div>
     
      <div class="row">
        <q-select
          label="Tipo Pedido"
          v-model="tipo_pedido"
          input-debounce="0"
          class="col padding1"
          :options="dataset_tipo_pedido"
          option-value="cd_tipo_pedido"
          option-label="nm_tipo_pedido"
          item-aligned
        >
          <template v-slot:prepend>
             <q-icon name="account_balance"  />
          </template>
        </q-select>


        <q-select
          class="col padding1"
          label="Origem"
          v-model="empresa_faturamento"
          input-debounce="0"
          :options="dataset_faturamento"
          option-value="cd_empresa"
          option-label="nm_empresa"
          item-aligned
        >
          <template v-slot:prepend>
             <q-icon name="account_balance" />
          </template>
        </q-select> 

        <!--<q-select
          class="col padding1"
          label="Banco"
          v-model="cd_banco"
          input-debounce="0"
          :options="dataset_banco"
          option-value="cd_banco"
          option-label="nm_fantasia_banco"
          item-aligned
          @input="MudaBanco() "
        >
          <template v-slot:prepend>
             <q-icon name="account_balance" />
          </template>
        </q-select> -->


         <div class=" text-center items-center self-center margin1 col-2" v-show="img_banco != '' ">
            <q-img
                class="img-logo"
                :src="img_banco"
                spinner-color="white"
                :ratio="16/9"
            />
        </div>
      </div>
       
      </div>
      <div class="borda-bloco shadow-2">

        <div class="row">
          <q-input class="padding1 col" item-aligned v-model="vl_proposta" prefix="R$ " reverse-fill-mask @blur="formatarMoeda(vl_proposta,1)" label="Valor da Proposta" type="text">
              <template v-slot:prepend>
                <q-icon name="account_balance" />
              </template>
          </q-input>
          <q-input class="padding1 col" item-aligned v-model="vl_credito" prefix="R$ " reverse-fill-mask @blur="formatarMoeda(vl_credito,2)" label="Valor do Crédito" type="text">
            <template v-slot:prepend>
              <q-icon name="account_balance_wallet" />
            </template>
          </q-input>
          <q-input class="padding1 col" item-aligned v-model="cd_prazo" label="Prazo" type="number">
            <template v-slot:prepend>
              <q-icon name="gavel" />
            </template>
          </q-input>
        </div>

        <div class="row">
          <q-input class="padding1 col" item-aligned v-model="cd_primeira_parcela" prefix="R$ " reverse-fill-mask @blur="formatarMoeda(cd_primeira_parcela,3)" label="1° Parcela" type="text">
            <template v-slot:prepend>
              <q-icon name="sell" />
            </template>
          </q-input>

          <q-input class="padding1 col" item-aligned v-model="cd_ultima_parcela" prefix="R$ " reverse-fill-mask @blur="formatarMoeda(cd_ultima_parcela,4)" label="Última Parcela" type="text">
            <template v-slot:prepend>
              <q-icon name="shopping_bag" />
            </template>
          </q-input>
        </div>

        <div class="row">
          <q-input class="padding1 col" item-aligned v-model="cd_taxa" suffix="%" reverse-fill-mask label="Taxa a.m" type="text">
            <template v-slot:prepend>
              <q-icon name="rate_review" />
            </template>
          </q-input>
          <q-input class="padding1 col" item-aligned v-model="cd_cet_anual" @blur="CalculaCET" suffix="%" reverse-fill-mask :label="'CET Anual / ' + 'Mensal: '+cd_cet_mensal + '%'" type="text">
            <template v-slot:prepend>
              <q-icon name="date_range" />
            </template>
          </q-input>
        </div>
      </div>

      <div class="borda-bloco shadow-2">
        <div class="row">
          <q-select
            label="Taxa"
            v-model="cd_tipo_taxa"
            input-debounce="0"
            class="col padding1"
            :options="dataset_taxa"
            option-value="cd_tipo_taxa"
            option-label="nm_tipo_taxa"
            item-aligned
          >
            <template v-slot:prepend>
               <q-icon name="account_balance"  />
            </template>
          </q-select>

          <q-select
            label="Amortização"
            v-model="cd_tipo_amortizacao"
            input-debounce="0"
            class="col padding1"
            :options="dataset_amortizacao"
            option-value="cd_tipo_amortizacao"
            option-label="nm_tipo_amortizacao"
            item-aligned
          >
            <template v-slot:prepend>
               <q-icon name="account_balance"  />
            </template>
          </q-select>
        </div>
        
        <q-input class="padding1" item-aligned v-model="vl_devedor_final" prefix="R$ " reverse-fill-mask @blur="formatarMoeda(vl_devedor_final,5)" label="Valor Devedor Final" type="text">
          <template v-slot:prepend>
            <q-icon name="format_align_left" />
          </template>
        </q-input> 
        <div style="margin:1%"> 
          <q-btn class="margin1" color="primary" label="Confirmar" @click="InsertProposta()" /> 
        </div>
      </div>
    </div>
    <q-expansion-item class="text-bold shadow-1" expand-separator icon="description" label="Histórico" default-opened >
      <div v-show="timelineI.cd_movimento > 0">
        <timeline
          class="margin1" 
          :cd_apiInput="'737/1119'" 
          ref="timeline_intermedium" 
          :inputID="true" 
          :nm_json="timelineI" 
          :cd_consulta="2" 
          :cd_parametroID="0" 
          cd_apiID='728/1101'
        />
      </div>
    </q-expansion-item>
    <!---------------------------------------------------->
     
     <q-dialog v-model="pop_cli" persistent :maximized="maximizedToggle" transition-show="slide-up" transition-hide="slide-down">
      <q-card >
        <q-bar class="bg-deep-orange-3">
          <q-space />

          <q-btn dense flat icon="minimize" @click="maximizedToggle = false" :disable="!maximizedToggle">
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white">Minimizar</q-tooltip>
          </q-btn>
          <q-btn dense flat icon="crop_square" @click="maximizedToggle = true" :disable="maximizedToggle">
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white">Maximizar</q-tooltip>
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section class="q-pt-none">
            <div class="row">
                <div class="text-h6 margin1 text-bold col items-start justify-center">
                    Clientes
                </div>
                <div class="margin1 col justify-center" >
                    <q-btn color="orange-8" icon-right="east" label="Selecionar" style="float:right" @click="pop_cli = false"/>
                </div>
            </div>
            <DxDataGrid
                id="grid-padrao"
                class="margin1"
                key-expr="cd_controle"
                :data-source="grid_cliente"
                :columns="coluna_cli"
                :show-borders="true"
                :column-auto-width="true"
                :column-hiding-enabled="false"
                :selection="{ mode: 'single' }"
                :auto-navigate-to-focused-row="true"
                :hover-state-enabled="true"
                :focused-row-enabled="true"
                :remote-operations="false"
                :word-wrap-enabled="false"
                :allow-column-reordering="true"
                :allow-column-resizing="true"
                :row-alternation-enabled="true"   
                :repaint-changes-only="true"    
                :autoNavigateToFocusedRow="true"                 
                :cacheEnable="false" 
                :leftPosition="true"
                @selection-changed="SelecionaCliente"
            >
            <DxColumnChooser :enabled="true"/>
              <DxColumnFixing :enabled="true"/>
              <DxPaging :page-size="100"/>
            </DxDataGrid>
        </q-card-section>
      </q-card>
    </q-dialog>
    <!-------------------------------------->
    <q-dialog maximized v-model="carregando" persistent>
      <div class="fixed-center carregando">
        <div class="text-white fixed-center">Aguarde...</div>
        <q-circular-progress
          indeterminate
          size="10vw"
          color="primary"
          class="your_div_class fixed-center fullscreen retira-scroll"
        />  
      </div>
    </q-dialog>
</div>
</template>

<script>
import Lookup from '../http/lookup';
import Incluir from '../http/incluir_registro';
import config from 'devextreme/core/config';
import notify from 'devextreme/ui/notify';
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization"
import cliente from "../views/pesquisa-cliente.vue"
import { DxDataGrid, DxPager, DxPaging,DxEditing, DxColumn,DxSummary,DxTotalItem,
  DxColumnChooser,
  DxColumnFixing,
         DxGroupItem
} from 'devextreme-vue/data-grid';


export default {
  
name:'intermedium-proposta',
    props:{
      cd_consultaID: { type:Object, default: () => { return {}} }
    },
    data(){
        return{
            img_consultoria     : '',
            img_banco           : '',
            cd_empresa          : localStorage.cd_empresa,
            dados_banco         : {},
            dataset_banco       : {},
            banco               : '',
            hoje                : '',
            proposta            : '' ,
            dataset_tipo_pedido : {},
            cd_proposta         : '',
            cd_banco            : '',
            vl_proposta         : 0.0,
            vl_credito          : 0.0,
            cd_prazo            : 1,
            cd_primeira_parcela : 0.0,
            cd_ultima_parcela   : 0.0,
            cd_taxa             : '0,1',
            cd_cet_anual        : 0.0,
            cd_cet_mensal       : '',
            cd_tipo_taxa        : '',
            cd_tipo_amortizacao : '',
            vl_devedor_final    : '',
            api                 : '610/854', //pr_egisnet_elabora_proposta_intermedium
            cd_consulta         : '',
            cd_usuario          : 0,
            pop_cli             : false,
            maximizedToggle     : true,
            cd_cliente          : 0,
            nm_cliente          : '',
            nm_fantasia_cliente : '',
            grid_cliente        : [],
            timelineI               : {
              "ic_parametro" : 2,
              "cd_form"      : 2, //Intermedium-Proposta.vue
              "cd_movimento" : 0,
              "cd_empresa"   : 0,
              "dt_inicial"   : '',
              "dt_final"     : '',
              "cd_usuario"   : localStorage.cd_usuario,
            },
            dataset_faturamento : [],
            carregando          : false,
            cd_administradora : '',
            dataset_administradora : [],
            dataset_taxa           : [],
            dataset_amortizacao    : [],
            empresa_faturamento    : [],
            tipo_pedido            : '',
            alteracao              : false,
            nameRules: [val => (val && val.length < 0) || 'Campo obrigatório!'],
            coluna_cli             : ['Fantasia','Razão_Social','CPF/CNPJ','CEP','E-mail',
                'Endereço','N°','Bairro','Cidade','Estado','País','Região','Telefone',
                'Data Cadastro','Tipo Pessoa','Ramo Atividade',
                'Fonte informação','Status','Transportadora','Comunicação','Tipo Mercado',
                'Idioma','Tipo Cliente','Inscestadual','cd_controle'],

        }
    },
    async created(){
      this.cd_usuario = localStorage.cd_usuario
      if(this.cd_consultaID != {}){
        this.proposta = this.cd_consultaID.cd_movimento;
        this.PesquisaProposta();
        this.alteracao = true;
      }
      this.AcertaData();
      config({ defaultCurrency: 'BRL' });  
      loadMessages(ptMessages);
      locale(navigator.language); 

      var dados_administradora      = await Lookup.montarSelect(localStorage.cd_empresa,5238)
      this.dataset_administradora    = JSON.parse(JSON.parse(JSON.stringify(dados_administradora.dataset)))

      var dados_tipo_pedido   = await Lookup.montarSelect(localStorage.cd_empresa,202)
      this.dataset_tipo_pedido = JSON.parse(JSON.parse(JSON.stringify(dados_tipo_pedido.dataset)))

      var dados_faturamento   = await Lookup.montarSelect(localStorage.cd_empresa,5137)
      this.dataset_faturamento = JSON.parse(JSON.parse(JSON.stringify(dados_faturamento.dataset)))

      var dados_taxa   = await Lookup.montarSelect(localStorage.cd_empresa,5388)
      this.dataset_taxa = JSON.parse(JSON.parse(JSON.stringify(dados_taxa.dataset)))

      var dados_amortizacao   = await Lookup.montarSelect(localStorage.cd_empresa,5389)
      this.dataset_amortizacao = JSON.parse(JSON.parse(JSON.stringify(dados_amortizacao.dataset)))


      for(let e=0; e < this.dataset_faturamento.length; e++){
        if(this.dataset_faturamento[e].ic_padrao_empresa == 'S'){
          this.empresa_faturamento = {
            cd_empresa : this.dataset_faturamento[e].cd_empresa,
            nm_empresa : this.dataset_faturamento[e].nm_empresa,
          }
          return;
        }
      }

      if(this.dataset_taxa.length == 1){
        this.cd_tipo_taxa = {
          cd_tipo_taxa : this.dataset_taxa[0].cd_tipo_taxa,
          nm_tipo_taxa : this.dataset_taxa[0].nm_tipo_taxa
        }
      }
       if(this.dataset_amortizacao.length == 1){
        this.cd_tipo_amortizacao = {
          cd_tipo_amortizacao : this.dataset_amortizacao[0].cd_tipo_amortizacao,
          nm_tipo_amortizacao : this.dataset_amortizacao[0].nm_tipo_amortizacao
        }
      }

     
      //this.carregaDados();
     

    },
    mounted(){
      this.timelineI.cd_empresa = this.cd_empresa
      this.timelineI.dt_inicial = localStorage.dt_inicial
      this.timelineI.dt_final = localStorage.dt_final
      this.timelineI.cd_movimento = this.proposta
    },
    components:{
      cliente,
      DxDataGrid, 
      DxPager, 
      DxPaging,
      DxEditing, 
      DxColumn,
      DxSummary,
      DxTotalItem,  
      DxColumnChooser,
      DxColumnFixing,
      DxGroupItem,
      timeline : () => import('../views/timeline.vue')
    },
    methods:{
        async carregaDados(){
          var c = {
            "cd_parametro" : 1
          }
          var consulta = await Incluir.incluirRegistro(this.api,c);
          notify(consulta[0].Msg);
          this.cd_consulta = consulta[0].Cod
        },
        MudaBanco(){

            if(this.cd_banco.cd_banco == 707){ 
              this.img_banco = 'http://www.egisnet.com.br/img/logo_banco_daycoval.jpg'
            }else if(this.cd_banco.cd_banco == 341){
              this.img_banco = 'https://jardimdasamericas.com.br/uploads/2018/02/itau-logo.jpg'
            }
            else if(this.cd_banco.cd_banco == 1){
              this.img_banco = 'https://dividasefinancas.com.br/wp-content/uploads/2018/04/logo-BB.png'
            }
            else if(this.cd_banco.cd_banco == 33 ){
              this.img_banco = 'https://www.meioemensagem.com.br/wp-content/uploads/2018/03/Santander_NovaMarca_575.png'
            }
            else{
              this.img_banco = ''
            }
        },

        CalculaCET(){
          
            let cet = this.cd_cet_anual + ''
            if(cet.includes(",") == true){
              cet = cet.replace(',','.')
            }
            this.cd_cet_mensal = (cet/12)
           
        },
        AcertaData(){
          var data  = new Date();
          var dia   = data.getDate(); 
          var mes   = data.getMonth();
          var ano4  = data.getFullYear();
          if(dia < 10){
            dia = '0'+dia;
          }
          mes = mes+1
          if (mes <10){
            mes = '0'+mes;
          }
          this.hoje = dia + '/' + mes + '/' + ano4;
        },
        LimpaCampos(){
          this.nm_cliente          = ''
          this.nm_fantasia_cliente = ''
          this.cd_proposta         = ''
          this.cd_banco            = ''
          this.vl_proposta         = 0.0
          this.vl_credito          = 0.0
          this.cd_prazo            = 
          this.cd_primeira_parcela = 0.0
          this.cd_ultima_parcela   = 0.0
          this.cd_taxa             = '0,1'
          this.cd_cet_anual        = 0.0
          this.cd_cet_mensal       = ''
          this.cd_tipo_taxa        = ''
          this.cd_tipo_amortizacao = ''
          this.vl_devedor_final    = ''
          
        },
        async InsertProposta(){
          if(this.cd_cliente == 0){
            notify('Pesquise e selecione o cliente!')
            return;
          }else if(this.cd_administradora.cd_administradora == undefined){
            notify('Selecione a administradora');
            return;
          }else if(this.vl_proposta == 0){
            notify('Digite um valor para o imóvel!')
            return;
          }else if(this.vl_credito == 0){
            notify('Digite o valor do crédito!')
            return;
          }else if(this.cd_prazo == '' || this.cd_prazo == 0){
            notify("Digite um valor de prazo válido")
            return;
          }else if (this.cd_primeira_parcela == 0  || this.cd_primeira_parcela == ''){
            notify("Digite o valor de primeira parcela")
            return;
          }else if(this.cd_ultima_parcela == 0 || this.cd_ultima_parcela == ''){
            notify('Digite o valor da última parcela!')
            return;
          }
         
          this.carregando = true;
          let i = {};
          
           i = {
            "cd_parametro"        : 2,
            "vl_proposta"         : this.vl_proposta,
            "vl_credito"          : this.vl_credito,
            "qt_prazo"            : this.cd_prazo,
            "cd_primeira_parcela" : this.cd_primeira_parcela,
            "cd_ultima_parcela"   : this.cd_ultima_parcela,
            "cd_taxa"             : this.cd_taxa,
            "cd_cet_anual"        : this.cd_cet_anual,
            "cd_tipo_taxa"        : this.cd_tipo_taxa.cd_tipo_taxa,
            "cd_tipo_amortizacao" : this.cd_tipo_amortizacao.cd_tipo_amortizacao,
            "vl_devedor_final"    : this.vl_devedor_final,
            "cd_usuario"          : this.cd_usuario,
            "cd_cliente"          : this.cd_cliente,
            "cd_tipo_pedido"      : this.tipo_pedido.cd_tipo_pedido,
            "cd_empresa_faturamento" : this.empresa_faturamento.cd_empresa,
            "cd_administradora"   : this.cd_administradora.cd_administradora,
            "cd_consulta"         : this.proposta,
          }
          if(this.alteracao == true){
            i.cd_parametro = 200
          }
          var incluido = await Incluir.incluirRegistro(this.api,i);
          notify(incluido[0].Msg)
          //this.LimpaCampos();
          this.carregando = false;
        },
        SelecionaCliente({selectedRowsData}){
          let selecionado = selectedRowsData[0]
          this.nm_fantasia_cliente = selecionado.Fantasia;
          this.cd_cliente = selecionado.cd_cliente;
         
          
        },
        async PesquisaCliente(){
          if(this.nm_fantasia_cliente == ''|| this.nm_fantasia_cliente === ' " '){
            return;
          }
          this.carregando = true;
          let nm = {
            "cd_parametro" : 3,
            "nm_fantasia_cliente" : this.nm_fantasia_cliente 
          }
          
          this.grid_cliente = await Incluir.incluirRegistro(this.api,nm);
          if(this.grid_cliente[0].Cod == 0){
            notify(this.grid_cliente[0].Msg)
            this.carregando = false;
            return;
          }
          if(this.grid_cliente.length == 1){
            this.carregando = false;
            this.nm_fantasia_cliente = this.grid_cliente[0].Fantasia;
            this.cd_cliente          = this.grid_cliente[0].cd_cliente;
            this.pop_cli = false;
            return;
          }
          this.carregando = false;

          this.pop_cli = true
          //this.cliente.onClick()
        },

        formatarMoeda(vl,tipo) {
         
            var valor = vl;
            valor = valor + '';
            
            if(valor.includes(",")==true){
                valor = valor.replace(",",".")
            }
            if(valor.includes("R$") == true){
                valor = valor.replace("R$","")
            }

               
                valor = parseFloat(valor)
            valor = valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
            if(tipo == 1){
              this.vl_proposta = valor.replace("R$","")
            }else if(tipo == 2){
              this.vl_credito = valor.replace("R$","")
            }else if(tipo == 3){
              this.cd_primeira_parcela = valor.replace("R$","")
            }else if(tipo == 4){
              this.cd_ultima_parcela = valor.replace("R$","")
            }else if(tipo == 5){
              this.vl_devedor_final = valor.replace("R$","")
            }
            
        },
       
        
        MudaOrigem(){
          //if(this.cd_administradora.cd_empresa == 2){ 
          //    this.img_consultoria = 'http://www.egisnet.com.br/img/logo_inove_intermedium.jpg'
          //  }else if(this.cd_administradora.cd_empresa == 1){
          //    this.img_consultoria = 'data:image/jpeg;base64,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VK9JQSQGDKRtqaxFjvxnrD5bTplSgICIaSi9xpJUm99ybqNye2b8QLEQckp6EQFwqU6lFbNuEq6bqDbqCKAeoD1mwmWU1qLVRRTZVZOiAAwcqSGAG9ioI7N+0zfiBYjKmWXdqiVq1Ivp1BdFjpFgekhI2nnE5LSqElwxvVWtxt0lRadvKVWxHWCe2SkQLI0P/S01K3SutVq43/nZHQ+ml22n3rYVXZHN70yWXfa7Kym/oxmxEEkXUyZCAFaommqa66SvQZgwbSCpFjrc2IO7Gemy4mx5+vrW9mul7Na6ldGhh0Qd1JG9jJOIIsRVLJaSkFgahGskvZrlyCzEWtc6VGwsALACesJlKUmVk1dEVVUX6IFZ1qMAOwMgsOobSTiBYiRktMKqBnUIKiJZgCi1eKrtsFFgvYAJmtklE2KqKdlen0AFulQBSpsN+Ckd6iSkQLI08FgzT252rUAAADc3YW7NCqfnN2IgkREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAP/Z'
          //  }else if(this.cd_administradora.cd_empresa == 3){
          //    this.img_consultoria = 'data:image/png;base64,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'
          //  }else if(this.cd_empresa_faturamento.cd_empresa == 4){ 
          //    this.img_consultoria = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6GYFuZ7-rVZegvjoauXBWm1JLyLsQrmuk-npJuo9jw5szU5wICxmWwBzmmkxMofLuamM&usqp=CAU'
          //  }else if(this.cd_empresa_faturamento.cd_empresa == 5){ 
          //    this.img_consultoria = 'https://portalrsassessoria.com.br/wp-content/uploads/2021/07/logotipo-RS-assessoria-hor-1024x331.png'
          //  }else if(this.cd_empresa_faturamento.cd_empresa == 8){ 
          //    this.img_consultoria = 'https://portalellos.com.br/wp-content/uploads/2019/11/logotipo-ellos1x.png'
          //  }else{
          //    this.img_consultoria = 'http://www.egisnet.com.br/img/logotipo-investe.png'
          //  }
        },
        async PesquisaProposta(){
          //aqui
          if(this.proposta == ''){
            return;
          }
          let p = {
            "cd_parametro" : 100,
            "cd_consulta"  : this.proposta
          }
          
          let consulta = await Incluir.incluirRegistro(this.api,p);
          if(consulta[0].Cod == 0){
            notify(consulta[0].Msg);
            this.alteracao = false;
            return;
          }

          this.hoje = 'Data de Emissão: ' + consulta[0].dt_consulta + ' - Emissor: ' + consulta[0].nm_usuario;

          this.nm_fantasia_cliente = consulta[0].nm_razao_social_cliente;
          this.cd_cliente          = consulta[0].cd_cliente;

          if(consulta[0].cd_administradora > 0){
            this.cd_administradora = {
              cd_administradora : consulta[0].cd_administradora,
              nm_administradora : consulta[0].nm_administradora
            }
          }
          if(consulta[0].cd_tipo_pedido >0){
            this.tipo_pedido = {
              cd_tipo_pedido : consulta[0].cd_tipo_pedido,
              nm_tipo_pedido : consulta[0].nm_tipo_pedido
            }
          }
          if(consulta[0].cd_empresa > 0){
            this.empresa_faturamento = {
              cd_empresa : consulta[0].cd_empresa,
              nm_empresa : consulta[0].nm_empresa
            }
          }
          this.cd_primeira_parcela = consulta[0].vl_parcela;
          this.cd_ultima_parcela   = consulta[0].vl_parcela_final;

          if(consulta[0].vl_total_consulta != '0'){
            this.vl_proposta = consulta[0].vl_total_consulta;
          }
          if(consulta[0].vl_credito != '0'){
            this.vl_credito = consulta[0].vl_credito;
          }

          this.cd_prazo = consulta[0].qt_prazo;

          if(consulta[0].vl_parcela != '0'){
            this.vl_parcela = consulta[0].vl_parcela;
          }
          if(consulta[0].vl_parcela != '0'){
            this.vl_parcela_final = consulta[0].vl_parcela_final;
          }

          this.cd_taxa = consulta[0].pc_taxa_mensal;
          this.cd_cet_anual = consulta[0].pc_cet_anual;
          
          
          if(consulta[0].cd_tipo_taxa > 0){
            this.cd_tipo_taxa = {
              cd_tipo_taxa : consulta[0].cd_tipo_taxa,
              nm_tipo_taxa : consulta[0].nm_tipo_taxa
            }
          }
          if(consulta[0].cd_tipo_amortizacao > 0){
            this.cd_tipo_amortizacao = {
              cd_tipo_amortizacao : consulta[0].cd_tipo_amortizacao,
              nm_tipo_amortizacao : consulta[0].nm_tipo_amortizacao
            }
          }
          if(consulta[0].vl_saldo_devedor != '0'){
            this.vl_devedor_final = consulta[0].vl_saldo_devedor;
          }
          this.CalculaCET();
          //this.formatarMoeda(consulta[0].vl_consorcio,1)
          //this.formatarMoeda(consulta[0].vl_credito,2)
          //this.formatarMoeda(consulta[0].vl_parcela,3)
          //this.formatarMoeda(consulta[0].vl_parcela_final,4)
          
        
          


        }

        
    }
}
</script>

<style scoped>
.img-logo{
    width: 100%;
    height: 100%;
    background-size: 100%;
    max-height: 70px;
}
#grid-padrao{
  max-height: 750px !important;
}
.retira-scroll{
  width: 400px;
	height: 280px;
	border: none;
	overflow: hidden;
}
.padding1{
  padding: 0.5vw 0.7vw;
}
.borda-bloco{
    border: solid 1px rgb(170, 170, 170) ;
    border-radius: 10px;
    margin: 10px;
}
</style>