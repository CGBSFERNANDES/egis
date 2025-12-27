<template>
  <div>
    <div>
    <DxButton v-if="!cd_tipo_email == 0" 
       class="botao-info" 
       icon='email'      
       text=""  
       @click="renderDoc"
     />
     <DxButton  
       class="botao-info" 
       icon='detailslayout'      
       text=""  
       @click="onClickFiltro($event)"
     />
     <DxButton v-if="!cd_relatorio == 0" 
       class="botao-info" 
       icon='print'      
       text=""  
       @click="renderDoc"
     />

    <DxButton v-if="!ds_menu_descritivo == ''" 
       class="botao-info" 
       icon='info'      
       text=""  
       @click="popClick()"
     />
     <DxButton  
       class="botao-info" 
       icon='event'      
       text=""  
       @click="popClick()"
     />
     <DxButton v-if="1==2" 
       class="botao-info" 
       icon='plus'      
       text=""  
       @click="popClick()"
     />
    </div>  
     <h2 class="content-block">{{tituloMenu}} {{hoje}} {{hora}}
     <q-badge v-if="qt_registro > 0"
        align="middle" rounded color="red" :label="qt_registro" />
     </h2>
     <div 
        class="dx-card wide-card-t q-pa-md q-gutter-y-sm">
        <q-toolbar 
           class="orange">        
        <q-toolbar-title>
        </q-toolbar-title>
        <q-toolbar-title>
            <b>{{nm_toolbar}}</b>
        </q-toolbar-title>
    </q-toolbar>
    </div>  
    <form  class="dx-card wide-card"
    
      v-if="ic_filtro_pesquisa == '9'"
        action="your-action"
        @submit="handleSubmit"
      >
      
      <DxForm 
        
        :read-only="false"
        :show-colon-after-label="true"
        :show-validation-summary="true"
        :form-data="formDataFiltro"
        :items="itemsFiltro"
      >

    </DxForm>
  </form> 

    <DxTabPanel class="dx-card wide-card tabPanel"
      v-if="(qt_tabsheet>0) && (ic_filtro_pesquisa == 'N')"    
      :data-source="tabs"
      :visible="true"
      :show-nav-buttons="true"
      :repaint-changes-only="true"
      :selected-index.sync="selectedIndex"
      :on-title-click="tabPanelTitleClick"
      item-title-template="title"
      item-template="itemTemplate"   
    >

    <template #title="{ data: tab }">
            <div>
              <span>{{ tab.nm_label_tabsheet }}</span>
              <i
               v-show="ShowDestino()"   
              />
            </div>
          </template>
  
       <template 
         v-if="! cd_menu_destino == 0"
         #itemTemplate="{ data: tab }">
             <componente 
               v-if="(qt_tabsheet>0) && (!cd_menu_destino == 0)"
               :cd_menuID="cd_menu_destino"
               :cd_apiID="cd_api_destino"  
               :cd_parametroID="cd_parametro"      
               :tab-data="tab"                       
               slot="tab.nm_label_tabsheet"
             />           
       </template>

    </DxTabPanel>
    <DxPopup 
        :visible="popupVisible"
        :title="tituloMenu"
        :height="250"        
        :show-title="true"
        :close-on-outside-click="true"
        :drag-enabled="false"
        @hiding="onHiding"
      >
      <DxForm>

      </DxForm>
      <div>
        <b class="info-cor">{{ ds_menu_descritivo }}</b>
      </div>
    </DxPopup>    

    <dx-data-grid v-if="(ic_filtro_pesquisa=='S')"
      class="dx-card wide-card"
      :data-source="formDataFiltro"
      :columns="colunaFiltro"           
      key-expr="cd_controle"      
      :show-borders="true"
      :focused-row-enabled="true"    
      >
            
      <DxPaging 
        :enable="false"
        :page-size="10" />

      <DxSelection mode="single"/>        

      <DxPager 
          :show-page-size-selector="true"
          :allowed-page-sizes="pageSizes"
          :show-info="true"/>

      <DxEditing 
        :refresh-mode="refreshMode"
        :allow-update="true"  
        mode="cell"
      >           
      </DxEditing>
     
      
    </dx-data-grid>
    <div>
    <DxButton class="buttons-column"
              :width="120"
              text="Pesquisar"
              type="default"
              styling-mode="contained"
              horizontal-alignment="left"
              @click="onClick($event)"
            />
    </div>

  </div>     
 
</template>

<script>
   import ptMessages from "devextreme/localization/messages/pt.json";
   import { locale, loadMessages } from "devextreme/localization";
   import config from 'devextreme/core/config';
   import notify from 'devextreme/ui/notify';
   import Procedimento from '../http/procedimento';
   import Menu from '../http/menu';

   import {
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
     DxStateStoring,
     DxSearchPanel,
     DxEditing, 
     DxPosition,
     DxMasterDetail
  
} from "devextreme-vue/data-grid";


import { DxForm,
         DxItem
 } from 'devextreme-vue/form';

import DxButton from 'devextreme-vue/button';
import DxTabPanel from 'devextreme-vue/tab-panel';
import { DxPopup } from 'devextreme-vue/popup';
import { exportDataGrid } from 'devextreme/excel_exporter';
import ExcelJS from 'exceljs';
import saveAs from 'file-saver';

import componente from '../views/display-componente';

import MasterDetail from '../views/MasterDetail';

import 'whatwg-fetch';
import Docxtemplater from "docxtemplater";
import PizZip from "pizzip";
import PizZipUtils from "pizzip/utils/index.js";

function loadFile(url, callback) {
  PizZipUtils.getBinaryContent(url, callback);
}

   var filename    = 'DataGrid.xlsx';
   var filenametxt = 'Arquivo.txt';
   var filenamedoc = 'Arquivo.docx';

   var dados = [];
   var sParametroApi = '';

   export default {
     components: {
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
        MasterDetail
     },

    data() {
    return {
      tituloMenu         : '',
      menu               : '',
      dt_inicial         : '',
      dt_final           : '',       
      cd_empresa         : 0,
      cd_menu            : 0,     
      cd_cliente         : 0,
      cd_api             : 0,
      api                : 0,
      qt_registro        : 0,
      cd_toolbar         : 0,
      nm_toolbar         : '',
      qt_tabsheet        : 0,
      tabs               : [],
      selectedIndex      : 0,
      cd_menu_destino    : 0,
      cd_api_destino     : 0,
      ic_filtro_pesquisa : 'N',
      formData           : {},
      items              : [],
      formDataFiltro     : [],
      itemsFiltro        : [],
      cd_tipo_email      : 0,
      cd_relatorio       : 1,
      ds_menu_descritivo : '',
      popupVisible       : false,
      cd_parametro       : 0,
      columns            : [],
      pageSizes          : [10, 20, 50, 100],   
      dataSourceConfig   : [],
      total              : {},
      colunaFiltro       : [],
      refreshMode        : 'reshape'
      }

    },

    async created() {
      //locale(navigator.language);
      config({ defaultCurrency: 'BRL' });  
      loadMessages(ptMessages);
      locale(navigator.language);     

      // locale('pt-BR'); 
      this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();      
      this.dt_final   = new Date(localStorage.dt_final).toLocaleDateString();    
      this.hoje       = '';
      this.hora       = '';
    },

    async mounted() {
      this.carregaDados(0);
    },

    methods: {

        ShowDestino() {
      
        },  
        popClick() {
          this.popupVisible = true;
        },

        onHiding() {
          this.popupVisible = false;        // Handler of the 'hiding' event
        },

        handleSubmit: function (e) {
           notify({
            message: 'Você precisa confirmar os Dados para pesquisa !',
            position: {
              my: 'center top',
              at: 'center top'
            }
           }, 'success', 1000);
            e.preventDefault();
        },    


        tabPanelTitleClick: function(e) {

           this.selectedIndex   = e.itemIndex;


          this.cd_menu_destino = 0;
          this.cd_api_destino  = 0; 

          this.cd_menu_destino = this.tabs[this.selectedIndex].cd_menu_composicao;
          this.cd_api_destino  = this.tabs[this.selectedIndex].cd_api;

       },


      async showMenu() {

        this.cd_empresa      = localStorage.cd_empresa;
        this.cd_cliente      = localStorage.cd_cliente;
        this.cd_menu         = localStorage.cd_menu;
        this.cd_api          = localStorage.cd_api;
        this.api             = localStorage.nm_identificacao_api;
        this.cd_menu_destino = 0;
        this.cd_api_destino  = 0;
        this.cd_toolbar      = 0;
        this.nm_toolbar      = '';

        var data = new Date(),
            dia  = data.getDate().toString(),
            diaF = (dia.length == 1) ? '0'+dia : dia,
            mes  = (data.getMonth()+1).toString(), //+1 pois no getMonth Janeiro começa com zero.
            mesF = (mes.length == 1) ? '0'+mes : mes,
            anoF = data.getFullYear();
          
            localStorage.dt_inicial        =  mes +"-"+dia+"-"+anoF;
            localStorage.dt_final          =  mesF+"-"+diaF+"-"+anoF;
            localStorage.dt_base           =  mesF+"-"+diaF+"-"+anoF;
            localStorage.cd_identificacao  = 0;

            //console.log(this.cd_empresa, this.cd_menu, this.cd_api);

            dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';

            //this.sParametroApi       = dados.nm_api_parametro;
            sParametroApi = dados.nm_api_parametro;
            //
            //console.log(sParametroApi);
   
            if ((!dados.nm_identificacao_api == '') && (!dados.nm_identificacao_api == this.api)) {
                this.api = dados.nm_identificacao_api;
             }  

            this.qt_tabsheet        = dados.qt_tabsheet;
            this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa;                 
            this.ds_menu_descritivo = dados.ds_menu_descritivo;
            this.ic_form_menu       = dados.ic_form_menu;
            this.ic_tipo_data_menu  = dados.ic_tipo_data_menu;
            this.cd_tipo_email      = dados.cd_tipo_email;
            this.cd_detalhe         = dados.cd_detalhe;
            this.cd_menu_detalhe    = dados.cd_menu_detalhe;
            this.cd_api_detalhe     = dados.cd_api_detalhe;
            this.cd_toolbar         = dados.cd_toolbar;
            this.nm_toolbar         = dados.nm_toolbar;
            
            //console.log(dados);

            //alert(dados.cd_toolbar);

            if (this.ic_tipo_data_menu == '1') { 
              this.hoje       = ' - ' + new Date().toLocaleDateString();       
            }

            if (this.ic_tipo_data_menu == '2' || this.ic_tipo_data_menu == '3') {
               this.hora       = new Date().toLocaleTimeString().substring(0,5);
            }          
  
            localStorage.cd_tipo_consulta = 0;

            if (!dados.cd_tipo_consulta == 0) {
              dados.cd_tipo_consulta;
            }

            this.tituloMenu               = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
            this.menu                     = dados.nm_menu;          
          
            //filenamepdf = this.tituloMenu+'.pdf';
            //dados da coluna
            this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));  
        
            //dados do total
            this.total   = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
            //
            this.itemsFiltro    = [];
            this.formDataFiltro = [];
            //console.log(this.ic_filtro_pesquisa);

           if ( this.ic_filtro_pesquisa == 'S') {

             //this.filtro      = JSON.parse(JSON.parse(JSON.stringify(dados.Filtro))); 
             this.formDataFiltro = dados.valoreFiltro;
             this.itemsFiltro    = JSON.parse(dados.labelFormFiltro);
             this.colunaFiltro   = JSON.parse(dados.colunaFiltro);
             //alert(dados.valoresFiltro);
             //console.log(dados.valoresFiltro);

             //console.log(this.itemsFiltro);
             console.log(this.formDataFiltro);
             //console.log(this.itemsFiltro);
             //console.log(this.colunaFiltro);

            //
            //alert(this.itemsFiltro);
            //console.log(this.itemsFiltro);

             //console.log(this.itemsFitro);
           }
           //TabSheet
           this.tabs = [];
           //
           if (! this.qt_tabsheet == 0 ) {
              this.tabs               = JSON.parse(JSON.parse(JSON.stringify(dados.TabSheet))); 
              this.cd_menu_destino    = this.cd_menu;
              this.cd_api_destino     = this.cd_api;
           }  
        },

        async carregaDados(tipo) {
      

          if ( tipo == 0) {
            await this.showMenu();
            return;
          }  

          notify(`Aguarde... estamos montando a consulta para você, aguarde !`);
       
          //console.log(dados.nm_api_parametro);
          let sApi = sParametroApi;
          //        
          //alert(sApi);
          //alert(this.cd_empresa);
          //alert(this.api);

          if (!sApi=='') {
             this.dataSourceConfig = await Procedimento.montarProcedimento(
             this.cd_empresa, 
             this.cd_cliente, 
             this.api, 
             sApi  ); 

            this.qt_registro = this.dataSourceConfig.length;

            //console.log(dataSourceConfig);
             
            this.formData = this.dataSourceConfig[0];
        
            //console.log(this.formData);

            this.items = JSON.parse(dados.labelForm);

            //console.log(this.items);

            }
                        
        
        },
        onClickFiltro() {
         
         if (this.ic_filtro_pesquisa == 'S')   {
           this.ic_filtro_pesquisa = 'N';
         }
         else { 
             this.ic_filtro_pesquisa = 'S';
         }  

        },

        onClick() {

          console.log(this.formDataFiltro );

          localStorage.cd_parametro = 0;

          if (!localStorage.cd_parametro == 0) {
             this.cd_parametro =  localStorage.cd_parametro;
             this.carregaDados(1);
             this.ic_filtro_pesquisa = 'N';
          }   

          },
          renderDoc() {
      //loadFile("http://egisnet.com.br/template/template_GBS.docx", function(
        loadFile("/Template_GBS.docx", function(
        //loadFile("https://docxtemplater.com/tag-example.docx", function(
        error,
        content
      ) {
        if (error) {
          alert('não encontrei o template.docx');
          throw error;
        }
        var zip = new PizZip(content);
        var doc = new Docxtemplater(zip);
        
        doc.setData( 
          
          dados
          
        //{
        //  dt_hoje: '26/04/2021',
        //  nm_menu_titulo: 'título do menu',
        //  nm_identificacao_api: 'endereço da api'
        //  
       // }
        
        );

        try {
          // render the document (replace all occurences of {first_name} by John, {last_name} by Doe, ...)
          doc.render();
        } catch (error) {
          // The error thrown here contains additional information when logged with JSON.stringify (it contains a properties object containing all suberrors).
          function replaceErrors(key, value) {
            if (value instanceof Error) {
              return Object.getOwnPropertyNames(value).reduce(function(
                error,
                key
              ) {
                error[key] = value[key];
                return error;
              },
              {});
            }
            return value;
          }
          //console.log(JSON.stringify({ error: error }, replaceErrors));

          if (error.properties && error.properties.errors instanceof Array) {
            const errorMessages = error.properties.errors
              .map(function(error) {
                return error.properties.explanation;
              })
              .join("\n");
            //console.log("errorMessages", errorMessages);
            // errorMessages is a humanly readable message looking like this :
            // 'The tag beginning with "foobar" is unopened'
          }
          throw error;
        }
        var out = doc.getZip().generate({
          type: "blob",
          mimeType:
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        });
         //Output the document using Data-URI
        saveAs(out, filenamedoc);

      });
    }    
             

    }  
  
}

</script>

<style>

.form {
  margin-left: 10px;
  margin-right: 10px;
  padding-left: 10px;
  padding-right: 10px;
  margin-top: 5px;

}

.info {
    margin-right: 40px;
}

.orange {
    color: #ff5722;
}
.info-cor {
  color: #506ad4;
  font-size: 20px;

}

.botao-exportar {
  margin-top: 10px;
  margin-left: 10px;
}
.botao-info {
  float: right;   
  right:10px;  
}


</style>