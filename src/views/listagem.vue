<template>
  <div> 
    <div class="row">
      <div class="col">
      <div class="text-h6 text-bold margin1">
        Ficha de Venda: {{cd_ficha_venda}}
      </div> 
    </div>
    </div>

<!------GERAR AUTOMATICAMENTE COM V-FOR---------------------------------------------------------->
    
<!----------------------------------------------------------------------------------------------->
      <q-expansion-item
        class="borda-bloco shadow-2 padding1 margin1"
        default-opened
        expand-separator
        icon="article"
        label="Ficha de Venda"
      >
     <div class="row">
         <q-input class="padding1 col-4 response" item-aligned v-model="vl_total_contrato" type="text" label="Valor Total" readonly>
             <template v-slot:prepend>
                 <q-icon name="paid" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="nm_administradora" type="text" label="Administradora" readonly>
             <template v-slot:prepend>
                 <q-icon name="business" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="nm_vendedor" type="text" label="Vendedor" readonly>
             <template v-slot:prepend>
                 <q-icon name="sell" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="dt_contrato" type="text" label="Data da Venda" readonly>
             <template v-slot:prepend>
                 <q-icon name="event" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="nm_indicador" type="text" label="Captação" readonly>
             <template v-slot:prepend>
                 <q-icon name="person" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="nm_ref_contrato" type="text" label="ID" readonly>
             <template v-slot:prepend>
                 <q-icon name="fingerprint" />
             </template>
         </q-input>
        </div>
         </q-expansion-item>
<!----------------------------------------------------------------------------------------------->
     <q-expansion-item
        class="borda-bloco shadow-2 padding1 margin1"
        expand-separator
        default-opened
        icon="supervisor_account"
        label="Dados do Cliente"
      >
    <div class="row">
         <q-input class="padding1 col-4 response" item-aligned v-model="nm_razao_contrato" type="text" label="Nome Completo / Razão Social" readonly>
             <template v-slot:prepend>
                 <q-icon name="person" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="cd_cnpj_cpf_contrato" type="text" label="CPF/CNPJ" readonly>
             <template v-slot:prepend>
                 <q-icon name="description" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="cd_ie_rg_contrato" type="text" label="RG/IE" readonly>
             <template v-slot:prepend>
                 <q-icon name="article" />
             </template>
         </q-input>
         <q-input class="padding1 col-4 response" item-aligned v-model="cd_cep" type="text" label="CEP" readonly>
             <template v-slot:prepend>
                 <q-icon name="location_on" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="nm_endereco" type="text" label="Endereço" readonly>
             <template v-slot:prepend>
                 <q-icon name="home_work" />
             </template>
         </q-input>
          <q-input class="padding1 col-4 response" item-aligned v-model="cd_numero" type="text" label="Nº" readonly>
             <template v-slot:prepend>
                 <q-icon name="pin" />
             </template>
          </q-input>
         <q-input class="padding1 col-4 response" item-aligned v-model="nm_complemento" type="text" label="Complemento" readonly>
             <template v-slot:prepend>
                 <q-icon name="article" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="nm_bairro" type="text" label="Bairro" readonly>
             <template v-slot:prepend>
                 <q-icon name="area_chart" />
             </template>
         </q-input>
         <q-input class="padding1 col-4 response" item-aligned v-model="nm_cidade" type="text" label="Cidade" readonly>
             <template v-slot:prepend>
                 <q-icon name="location_city" />
             </template>
         </q-input>
         <q-input class="padding1 col-4 response" item-aligned v-model="sg_estado" type="text" label="UF" readonly>
             <template v-slot:prepend>
                 <q-icon name="map" />
             </template>
         </q-input>
         <q-input class="padding1 col-4 response" item-aligned v-model="cd_telefone" type="text" label="Telefone Fixo" readonly>
             <template v-slot:prepend>
                 <q-icon name="call" />
             </template>
         </q-input>
         <q-input class="padding1 col-4 response" item-aligned v-model="cd_celular" type="text" label="Celular" readonly>
             <template v-slot:prepend>
                 <q-icon name="smartphone" />
             </template>
         </q-input>
         <q-input class="padding1 col-4 response" item-aligned v-model="nm_email" type="text" label="E-mail" readonly>
             <template v-slot:prepend>
                 <q-icon name="email" />
             </template>
         </q-input>
        </div>
        </q-expansion-item>
<!----------------------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------------------->
      <q-expansion-item
        class="borda-bloco shadow-2 padding1 margin1"
        expand-separator
        default-opened
        icon="work"
        label="Dados do Sócio Majoritário"
      >
    <div class="row">
         <q-input class="padding1 col-4 response" item-aligned v-model="nm_razao_contrato_socio" type="text" label="Nome Completo" readonly>
             <template v-slot:prepend>
                 <q-icon name="person" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="cd_ie_rg_contrato_socio" type="text" label="RG" readonly>
             <template v-slot:prepend>
                 <q-icon name="app_registration" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="cd_cnpj_cpf_contrato_socio" type="text" label="CPF" readonly>
             <template v-slot:prepend>
                 <q-icon name="app_registration" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="dt_nascimento" type="text" label="Data de Nascimento" readonly>
             <template v-slot:prepend>
                 <q-icon name="event" />
             </template>
         </q-input>
         <q-input class="padding1 col-4 response" item-aligned v-model="cd_cep_socio" type="text" label="CEP" readonly>
           <template v-slot:prepend>
               <q-icon name="location_on" />
           </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="nm_endereco_socio" type="text" label="Endereço" readonly>
             <template v-slot:prepend>
                 <q-icon name="location_on" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="cd_numero_socio" type="text" label="Nº" readonly>
             <template v-slot:prepend>
                 <q-icon name="pin" />
             </template>
         </q-input>
          <q-input class="padding1 col-4 response" item-aligned v-model="nm_bairro_socio" type="text" label="Bairro" readonly>
             <template v-slot:prepend>
                 <q-icon name="maps_home_work" />
             </template>
         </q-input>
          <q-input class="padding1 col-4 response" item-aligned v-model="nm_cidade_socio" type="text" label="Cidade" readonly>
             <template v-slot:prepend>
                 <q-icon name="maps_home_work" />
             </template>
         </q-input>
          <q-input class="padding1 col-4 response" item-aligned v-model="nm_complemento_socio" type="text" label="Complemento" readonly>
             <template v-slot:prepend>
                 <q-icon name="assignment" />
             </template>
         </q-input>
          <q-input class="padding1 col-4 response" item-aligned v-model="sg_estado_socio" type="text" label="UF" readonly>
             <template v-slot:prepend>
                 <q-icon name="map" />
             </template>
         </q-input>
          <q-input class="padding1 col-4 response" item-aligned v-model="pc_empresa" type="text" label="% da Empresa" readonly>
             <template v-slot:prepend>
                 <q-icon name="trending_up" />
             </template>
         </q-input>
          <q-input class="padding1 col-4 response" item-aligned v-model="cd_telefone_socio" type="text" label="Telefone" readonly>
             <template v-slot:prepend>
                 <q-icon name="call" />
             </template>
         </q-input>
          <q-input class="padding1 col-4 response" item-aligned v-model="cd_celular_socio" type="text" label="Celular" readonly>
             <template v-slot:prepend>
                 <q-icon name="smartphone" />
             </template>
         </q-input>
          <q-input class="padding1 col-4 response" item-aligned v-model="nm_estado_civil" type="text" label="Estado Civil" readonly>
             <template v-slot:prepend>
                 <q-icon name="supervisor_account" />
             </template>
         </q-input>
         <q-input class="padding1 col-4 response" item-aligned v-model="nm_email_socio" type="text" label="E-mail" readonly>
             <template v-slot:prepend>
                 <q-icon name="email" />
             </template>
         </q-input>
          <q-input class="padding1 col-4 response" item-aligned v-model="nm_cargo" type="text" label="Cargo" readonly>
             <template v-slot:prepend>
                 <q-icon name="work" />
             </template>
         </q-input>
         <q-input class="padding1 col-4 response" item-aligned v-model="nm_profissao" type="text" label="Profissão" readonly>
             <template v-slot:prepend>
                 <q-icon name="engineering" />
             </template>
         </q-input>
        </div>
        </q-expansion-item>
<!----------------------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------------------->
         <q-expansion-item
        class="borda-bloco shadow-2 padding1 margin1"
        expand-separator
        default-opened
        icon="description"
        label="Dados da Venda"
        > 
        <div class="row">
         <q-input class="padding1 col-4 response" item-aligned v-model="nm_tabela" type="text" label="Tabela" readonly>
             <template v-slot:prepend>
                 <q-icon name="analytics" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="cd_tabela" type="text" label="Código da Tabela" readonly>
             <template v-slot:prepend>
                 <q-icon name="vpn_key" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="cd_grupo_contrato" type="text" label="Grupo" readonly>
             <template v-slot:prepend>
                 <q-icon name="groups" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="dt_contrato" type="text" label="Vencimento do Boleto" readonly>
             <template v-slot:prepend>
                 <q-icon name="receipt_long" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="qt_parcela_contrato" type="text" label="Prazo" readonly>
             <template v-slot:prepend>
                 <q-icon name="schedule" />
             </template>
         </q-input>
           <q-input class="padding1 col-4 response" item-aligned v-model="ic_seguro_contrato" type="text" label="Seguro" readonly>
             <template v-slot:prepend>
                 <q-icon name="lock" />
             </template>
         </q-input>


           <!--GRID COM COTAS(R$)/VALOR DA 1º PARCELA(R$)-->


           <q-input class="padding1 col-4 response" item-aligned v-model="vl_faturamento_anual" type="text" label="Faturamento Anual" readonly>
             <template v-slot:prepend>
                 <q-icon name="request_quote" />
             </template>
         </q-input>

           <q-input class="padding1 col-4 response" item-aligned v-model="vl_faturamento_mensal" type="text" label="Faturamento Mensal" readonly>
             <template v-slot:prepend>
                 <q-icon name="request_quote" />
             </template>
         </q-input>
        </div>
        </q-expansion-item>
<!----------------------------------------------------------------------------------------------->
    <div class="text-h7 text-bold margin1">
     <q-checkbox v-model="aceite" label="Aceite" class="text-bold check-box-style response" color="blue"/>: {{msg}}
    </div> 
  </div>
</template>

<script>
import Incluir from '../http/incluir_registro';
import Procedimento from '../http/procedimento';
import Menu from '../http/menu';
import ExcelJS from 'exceljs';
import Lookup from '../http/lookup';

import {
  DxSummary,
  DxDataGrid,
  DxFilterRow,
  DxPager,
  DxPaging,
  DxExport,
  DxGroupPanel,
  DxTotalItem,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxSelection,
  DxStateStoring,
  DxSearchPanel,
  DxEditing, 
  DxPosition,
  DxMasterDetail
//  DxPopup
  
} from "devextreme-vue/data-grid";

let dados         = [];
let sParametroApi = '';

export default {
  props:{
    cd_ficha_venda: { type: Number,  default: 0   },
    cd_parametro:   { type: Number,  default: 0   },
  },
  name:'listagem',
  components:{
    DxDataGrid,
    DxPager,
    DxPaging,
    DxEditing,
    DxFilterRow,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxGrouping,
    DxColumnChooser, 
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxSelection,
    DxStateStoring,
    DxSearchPanel,
    DxTotalItem,
    DxEditing, 
    DxPosition,
    DxSummary,
  },
  
  data(){
    return{
      cd_empresa      : localStorage.cd_empresa,
      cd_usuario      : localStorage.cd_usuario,
      cd_cliente      : localStorage.cd_cliente,
      cd_api          : '442',
      api             : '442/597', //Procedimento - 1323 - pr_consulta_ficha_venda
      cd_menu         : localStorage.cd_menu,
      dataSourceConfig: [],
      msg             : '',
      aceite          : false,
      cd_administradora: '',
      cd_administradora: '',
      cd_cep: '',
      cd_cliente: '',
      cd_cnpj_cpf_contrato: '',
      cd_contrato: '',
      cd_controle: '',
      cd_cota_contrato: '',
      cd_empresa: '',
      cd_ficha_contrato: '',
      cd_id_contrato: '',
      cd_ie_rg_contrato: '',
      cd_indicador: '',
      cd_item_cadastro: '',
      cd_numero: '',
      cd_status_contrato: '',
      cd_tabela: '',
      cd_grupo_contrato: '',
      cd_telefone: '',
      cd_celular: '',
      nm_email :'',
      nm_profissao :'',
      nm_estado_civil :'',
      cd_tipo_pessoa: '',
      cd_tipo_venda: '',
      cd_vendedor: '',
      dt_contrato: '',
      dt_nascimento: '',
      dt_venda_consorcio: '',
      ic_seguro_contrato: '',
      nm_administradora: '',
      nm_bairro: '',
      nm_cidade: '',
      sg_estado: '',
      nm_cargo: '',
      nm_endereco: '',
      nm_complemento: '',
      nm_fantasia_empresa: '',
      nm_razao_contrato: '',

      nm_razao_contrato_socio: '',
      cd_ie_rg_contrato_socio: '',
      cd_cnpj_cpf_contrato_socio: '',
      cd_cep_socio: '',
      nm_endereco_socio: '',
      cd_numero_socio: '',
      nm_bairro_socio: '',
      nm_cidade_socio: '',
      nm_complemento_socio: '',
      sg_estado_socio: '',
      cd_telefone_socio: '',
      cd_celular_socio: '',
      nm_email_socio: '',

      nm_ref_contrato: '',
      nm_status_contrato: '',
      nm_tabela: '',
      nm_tipo_pedido: '',
      nm_vendedor: '',
      pc_empresa: '',
      qt_cota_contrato: '',
      qt_parcela_contrato: '',
      qt_prazo_contrato: '',
      qt_vendedor_contrato: '',
      vl_contrato: '',
      vl_faturamento_anual: '',
      vl_faturamento_mensal: '',
      vl_parcela_contrat: '',
      vl_total_contrato: '',
      nm_indicador      : '',
      dados_vendedor    : [],
      dataset_vendedor  : [],
      dados_indicador   : [],
    }
  },
    async created(){
    this.msg = 'Em caso de o cliente colocar reclamação no Reclame Aqui, será estornado 100% das comissões pagas da primeira venda e da venda repique.Em caso de ajuizamento de ações pelo cliente, o vendedor será responsável pelas custas processuais.'
    if (this.cd_ficha_venda != 0 ){
      this.showMenu();
    }
  },
  methods:{
    async showMenu(){
     dados = await Menu.montarMenu(localStorage.cd_empresa, 0, this.cd_api); //'titulo';
     localStorage.cd_parametro     = this.cd_parametro
     localStorage.cd_identificacao = this.cd_ficha_venda
     sParametroApi = dados.nm_api_parametro;
     this.carregadados();
    },

    async carregadados(){

    /*---VENDEDOR-------------------------------------------------------------------------------------------------*/  
     this.dados_vendedor   = await Lookup.montarSelect(localStorage.cd_empresa,141) 
     this.dataset_vendedor = JSON.parse(JSON.parse(JSON.stringify(this.dados_vendedor.dataset)))
     this.dataset_vendedor = this.dataset_vendedor.sort(function (a,b){
         if(a.nm_vendedor < b.nm_vendedor) return -1;
         return 1;
     })
     this.dados_indicador = this.dataset_vendedor.filter((value) => {
         return value.cd_tipo_vendedor == 4
      });
   /*------------------------------------------------------------------------------------------------------------*/

    this.dataSourceConfig = await Procedimento.montarProcedimento(
      localStorage.cd_empresa, 
      this.cd_cliente, 
      this.api, 
      sParametroApi);
      var filtered = this.dataSourceConfig.filter((value) => {
         return value.cd_ficha_contrato == this.cd_ficha_venda
      });
      var filtra_indicador = this.dados_indicador.filter((value) => {
         return value.cd_vendedor == filtered[0].cd_indicador
      });

      var ano = filtered[0].dt_contrato.substring(0,4)
      var mes = filtered[0].dt_contrato.substring(5,7)
      var dia = filtered[0].dt_contrato.substring(8,10)
       var dataFormatada = dia+'/'+mes+'/'+ano
      this.cd_administradora=     filtered[0].cd_administradora
      this.cd_cep=                filtered[0].cd_cep
      this.cd_cliente=            filtered[0].cd_cliente
      this.cd_cnpj_cpf_contrato=  filtered[0].cd_cnpj_cpf_contrato
      this.cd_contrato=           filtered[0].cd_contrato
      this.cd_controle=           filtered[0].cd_controle
      this.cd_cota_contrato=      filtered[0].cd_cota_contrato
      this.cd_empresa=            filtered[0].cd_empresa
      this.cd_ficha_contrato=     filtered[0].cd_ficha_contrato
      this.cd_id_contrato=        filtered[0].cd_id_contrato
      this.cd_ie_rg_contrato=     filtered[0].cd_ie_rg_contrato
      this.cd_indicador=          filtered[0].cd_indicador
      this.cd_item_cadastro=      filtered[0].cd_item_cadastro
      this.cd_numero=             filtered[0].cd_numero
      this.cd_status_contrato=    filtered[0].cd_status_contrato
      this.cd_tabela=             filtered[0].cd_tabela
      this.cd_grupo_contrato=     filtered[0].cd_grupo_contrato
      this.cd_telefone=           filtered[0].cd_telefone
      this.cd_celular=            filtered[0].cd_celular
      this.nm_email=              filtered[0].nm_email
      this.nm_profissao=          filtered[0].nm_profissao
      this.nm_estado_civil=       filtered[0].nm_estado_civil
      this.cd_tipo_pessoa=        filtered[0].cd_tipo_pessoa
      this.cd_tipo_venda=         filtered[0].cd_tipo_venda
      this.cd_vendedor=           filtered[0].cd_vendedor
      this.dt_contrato=           dataFormatada
      this.dt_nascimento=         filtered[0].dt_nascimento
      this.dt_venda_consorcio=    filtered[0].dt_venda_consorcio
      this.ic_seguro_contrato=    filtered[0].ic_seguro_contrato
      this.nm_administradora=     filtered[0].nm_administradora
      this.nm_bairro=             filtered[0].nm_bairro
      this.nm_cidade=             filtered[0].nm_cidade
      this.sg_estado=             filtered[0].sg_estado
      this.nm_cargo=              filtered[0].nm_cargo
      this.nm_endereco=           filtered[0].nm_endereco
      this.nm_complemento=        filtered[0].nm_complemento
      this.nm_fantasia_empresa=   filtered[0].nm_fantasia_empresa
      this.nm_razao_contrato=     filtered[0].nm_razao_contrato
//DADOS DO SÓCIO MAJORITÁRIO
      this.nm_razao_contrato_socio=    filtered[0].nm_razao_contrato_socio
      this.cd_ie_rg_contrato_socio =   filtered[0].cd_ie_rg_contrato_socio
      this.cd_cnpj_cpf_contrato_socio= filtered[0].cd_cnpj_cpf_contrato_socio
      this.cd_cep_socio=               filtered[0].cd_cep_socio
      this.nm_endereco_socio=          filtered[0].nm_endereco_socio
      this.cd_numero_socio=            filtered[0].cd_numero_socio
      this.nm_bairro_socio=            filtered[0].nm_bairro_socio
      this.nm_cidade_socio=            filtered[0].nm_cidade_socio
      this.nm_complemento_socio=       filtered[0].nm_complemento_socio
      this.sg_estado_socio=            filtered[0].sg_estado_socio
      this.cd_telefone_socio=          filtered[0].cd_telefone_socio
      this.cd_celular_socio=           filtered[0].cd_celular_socio
      this.nm_email_socio=             filtered[0].nm_email_socio
      
      this.nm_ref_contrato=       filtered[0].nm_ref_contrato
      this.nm_status_contrato=    filtered[0].nm_status_contrato
      this.nm_tabela=             filtered[0].nm_tabela
      this.nm_tipo_pedido=        filtered[0].nm_tipo_pedido
      this.nm_vendedor=           filtered[0].nm_vendedor
      this.nm_indicador=          filtra_indicador[0].nm_vendedor
      this.pc_empresa=            filtered[0].pc_empresa
      this.qt_cota_contrato=      filtered[0].qt_cota_contrato
      this.qt_parcela_contrato=   filtered[0].qt_parcela_contrato
      this.qt_prazo_contrato=     filtered[0].qt_prazo_contrato
      this.qt_vendedor_contrato=  filtered[0].qt_vendedor_contrato
      this.vl_contrato=           filtered[0].vl_contrato
      this.vl_faturamento_anual=  filtered[0].vl_faturamento_anual
      this.vl_faturamento_mensal= filtered[0].vl_faturamento_mensal

      this.vl_parcela_contrat=    filtered[0].vl_parcela_contrat
      this.vl_total_contrato=     filtered[0].vl_total_contrato
 /*      
      var c = {
        "cd_parametro" : this.cd_parametro,
        "cd_usuario"   : this.cd_usuario,
        "cd_identificacao" : this.cd_romaneio,
        "dt_inicial"       : localStorage.dt_inicial,
        "dt_final"         : localStorage.dt_final
      }
      this.dataSourceConfig = await Incluir.incluirRegistro(this.api,c);
      if(this.dataSourceConfig.length > 0){
        this.nm_entregador = this.dataSourceConfig[0].Entregador;
        this.nm_veiculo = this.dataSourceConfig[0].Veiculo;
        this.pc_bateria = this.dataSourceConfig[0].Bateria;
      } */
    },
    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet('Consulta');

      exportDataGrid({
        component: e.component,
        worksheet: worksheet,
        autoFilterEnabled: true
      }).then(function() {
        // https://github.com/exceljs/exceljs#writing-xlsx
        workbook.xlsx.writeBuffer().then(function(buffer) {
          saveAs(new Blob([buffer], { type: 'application/octet-stream' }), filename);
        });
      });
      e.cancel = true;
    },
  }
}
</script>

<style scoped>
.padding1{
    padding: 0.3% 0.8%;
}
.margin1{
    margin: 0.5%;
}
.borda-bloco{
    border: solid 1px rgb(170, 170, 170) ;
    border-radius: 10px;
}
</style>