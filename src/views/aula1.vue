<template>
  <div>  
     <div> 
        <DxButton v-if="!ds_menu_descritivo == ''" 
          class="botao-info" 
          icon='info'      
          text=""  
          @click="popClick()"
        />

        <div class="info-periodo" v-if="periodoVisible == true"> De: {{dt_inicial}} até {{dt_final}}</div> 
        <div >
               <DxButton class="button buttons-column"
                 text="INÍCIO"
                 type="default"
                 styling-mode="contained"
                 horizontal-alignment="left"
                 @click="onClickApontamento($event)"
               />
               <DxButton class="button buttons-column"
                 text="PARADAS"
                 type="default"
                 styling-mode="contained"
                 horizontal-alignment="left"
                 @click="onClickApontamento($event)"
               />
               <DxButton class="buttons-column button"
                 text="APARAS"
                 type="default"
                 styling-mode="contained"
                 horizontal-alignment="left"
                 @click="onClickApontamento($event)"
               />
               <DxButton class="buttons-column button"
                 text="PROXIMA"
                 type="default"
                 styling-mode="contained"
                 horizontal-alignment="left"
                 @click="onClickApontamento($event)"
               />  
                <DxButton class="buttons-column button"
                 text="OPERADOR"
                 type="default"
                 styling-mode="contained"
                 horizontal-alignment="left"
                 @click="onClickApontamento($event)"
               />  
                <DxButton class="buttons-column button"
                 text="OPERAÇÃO"
                 type="default"
                 styling-mode="contained"
                 horizontal-alignment="left"
                 @click="onClickApontamento($event)"
               />  
              </div>        
     </div> 
 <div v-if="ic_form_menu == 'S'">
        
    <div id="form-container">
      <div class="linha">
      <div class="coluna-60">  
        <div class="info" >
        <label> {{  turno   }} - {{ funcionario }}</label> | 
        <label style="font-size: 20px">{{hoje}} {{hora}}</label>
        </div>
        <div class="info">     
        <strong>  OP       </strong> {{  ordem  }}    
        <strong> | Pedido  </strong> {{  pedido }}     
        <strong> | Data    </strong> {{  data   }}     
        <strong> | Entrega </strong> {{ entrega }} 
        <strong> | Cliente </strong> {{ cliente }} 
      </div>
      <div class="info">
      <strong>   Produto  </strong>  {{ produto }}  
       <strong> | Qtd     </strong>  {{   qtd   }}      
       <strong> | Larg    </strong>  {{   larg  }}     
       <strong> | Esp     </strong>  {{   esp   }}          
       <strong> | Comp    </strong>  {{   comp  }}    
       <strong> | Vol     </strong>  {{   vol   }}      
       <strong> | Peso    </strong>  {{   peso  }}  
    </div>
    <div class="">
      <strong style="color: red">Componentes </strong>
    </div>
    <div class="info">
      {{ composicao }}
      <strong>Tubete           </strong>  {{ peso_un  }} <br>
      <strong>Caixa Individual </strong>  {{ peso_esp }} <br>
      <strong>Caixa Master     </strong>  {{ peso_emb }}  
    </div>
    <div class="info">
      <strong>Peso Material           </strong>   {{ peso_un }}<!-- os pesos abaixo estão setados para teste -->
      <strong> |Peso Mat + Tubete       </strong> {{ peso_un + peso_esp }}
      <strong> |Peso Mat + Tub + Caixa  </strong> {{ peso_un + peso_esp + peso_emb }}
    </div>
      </div>
      
    <!--<div class="info">
      <strong style="color: red">Observações </strong> 
    </div> 
    <div class="info">
      {{ obs }} 
    </div>-->
    <div class="coluna-40">
      <DxForm
        id="form"
        :col-count="1"
        :form-data="formData"
        :read-only="false"        
        :show-colon-after-label="false"
        :min-col-width="500"      
      >
        <DxSimpleItem
               css-class="label-info-red"
               :col-span="1"
               :editor-options="{disabled: false, height: 185}"
               data-field="ds_processo"
               editor-type="dxTextArea"
               >
              <DxLabel class="label-info-red" style="color: red" text="OBSERVAÇÕES" />
            </DxSimpleItem>
</DxForm>
    </div>
      </div>


    <div style="text-align: center; font-size: 20px; margin-top: 15px">
       PRÓXIMAS ORDENS 
    </div>
    <div>
      
             <dx-data-grid
      class="dx-card wide-card"
      :data-source="dataSourceConfig"
      :columns="columns"     
      :summary="total"     
      key-expr="cd_controle"      
      :show-borders="true"
      :focused-row-enabled="true"
      :column-auto-width="true"
      :column-hiding-enabled="false"
      :remote-operations="false"
      :word-wrap-enabled="false"
      :allow-column-reordering="true"
      :allow-column-resizing="true"
      :row-alternation-enabled="true"   
      :repaint-changes-only="true"    
      :autoNavigateToFocusedRow="true"
      :focused-row-index="0"      
      :cacheEnable="false"      
      @exporting="onExporting"  
      @initialized="saveGridInstance"
      @focused-row-changed="onFocusedRowChanged"    
      >
      <DxGroupPanel :visible="false"
      empty-panel-text=""/>
      <DxGrouping :auto-expand-all="false"/>
      <DxExport
        :enabled="false"
      />

      <DxPaging 
        :enable="false"
        :page-size="10" />

      <DxStateStoring
         :enabled="false"
         type="localStorage"
         storage-key="storage"
      />
      <DxSelection mode="single"/>        
      <DxPager 
          :show-page-size-selector="false"
          :allowed-page-sizes="pageSizes"
          :show-info="false"/>
      <DxFilterRow :visible="false" />
      <DxHeaderFilter 
        :visible="false"
        :allow-search="false"
      />
      <DxSearchPanel
      
        :visible="false"        
        :width="100"
        placeholder="Procurar..."
      />
      <DxFilterPanel :visible="false"/>      
      <DxColumnFixing :enabled="false"/>      
      <DxColumnChooser
        :enabled="false"
        mode="select"
      />          
    </dx-data-grid>

    </div>
  </div> 
  <div>
    <DxTabPanel 
      class="dx-card wide-card"
      v-if="tabPanel == true"
      :visible="true"
      :show-nav-buttons="true"
      :repaint-changes-only="true"
    >
    <DxItem
      title="Operador"
      template="operador-tab"
    />
    <template #operador-tab>
      <grid 
        :cd_menuID="6852"
        :cd_apiID="207"  
        :cd_parametroID="0"                             
      />           

    </template>
    <DxItem
      title="Parada"
      template="parada-tab"
    />
    <template #parada-tab>
      <componente 
               :cd_menuID="6852"
               :cd_apiID="207"  
               :cd_parametroID="ordem"
               
             />           

    </template>
  </DxTabPanel>
  <DxButton v-if="tabPanel == true"
     class="buttons-column"
                 :width="120"
                 text="FECHAR"
                 type="default"
                 styling-mode="contained"
                 horizontal-alignment="left"
                 @click="onClickFecharTab($event)"
               />          

  </div>   
  <dx-data-grid v-if="(ic_form_menu=='N')"
         class="dx-card wide-card"
         :data-source="dataSourceConfig"
         :columns="columns"     
         :summary="total"     
         key-expr="cd_controle"      
         :show-borders="true"
         :focused-row-enabled="true"
         :column-auto-width="true"
         :column-hiding-enabled="false"
         :remote-operations="false"
         :word-wrap-enabled="false"
         :allow-column-reordering="true"
         :allow-column-resizing="true"
         :row-alternation-enabled="true"   
         :repaint-changes-only="true"    
         :autoNavigateToFocusedRow="true"
         :focused-row-index="0"      
         :cacheEnable="false"      
         @exporting="onExporting"  
         @initialized="saveGridInstance"
         @focused-row-changed="onFocusedRowChanged" 
       
         >
         <DxGroupPanel :visible="true"
         empty-panel-text="agrupar..."/>
   
         <DxGrouping :auto-expand-all="true"/>
         <DxExport
           :enabled="true"
         />
   
         <DxPaging 
           :enable="true"
           :page-size="10" />
   
         <DxStateStoring
            :enabled="false"
            type="localStorage"
            storage-key="storage"
         />
         <DxSelection mode="single"/>        
         <DxPager 
             :show-page-size-selector="true"
             :allowed-page-sizes="pageSizes"
             :show-info="true"/>
         <DxFilterRow :visible="false" />
         <DxHeaderFilter 
           :visible="true"
           :allow-search="true"
         />
         <DxSearchPanel
           :visible="temPanel"        
           :width="100"
           placeholder="Procurar..."
         />
         <DxFilterPanel :visible="true"/>      
         <DxColumnFixing :enabled="true"/>      
         <DxColumnChooser
           :enabled="true"
           mode="select"
         />          
       </dx-data-grid>
   
         <div class="task-info" v-if="temD === true">
            <div class="info">
              <div id="taskSubject">{{ taskSubject }}</div>
              <p
               id="taskDetails"
               v-html="taskDetails"
              />
            </div>   
          </div>
        <div>
        </div>
    
         <DxPopup 
           :visible="popupVisible"
           :title="tituloMenu"
           :height="250"             
           :show-title="true"
           :close-on-outside-click="true"
           :drag-enabled="false"
           @hiding="onHiding"
         >
         <div>
           <b class="info-cor">{{ ds_menu_descritivo }}</b>
         </div>
       </DxPopup>
 </div>
  </div>
      
   </template>
   
<script>

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
     DxSearchPanel
     
   } from "devextreme-vue/data-grid";
   
   import DxForm, {
     DxGroupItem,  
     DxSimpleItem,
     DxLabel
   } from 'devextreme-vue/form';
   
   import 'devextreme-vue/text-area';
   import DxButton from 'devextreme-vue/button';
   import { DxTabPanel, DxItem } from 'devextreme-vue/tab-panel';
   import { DxPopup } from 'devextreme-vue/popup';
   import { exportDataGrid } from 'devextreme/excel_exporter';
   import ExcelJS from 'exceljs';
   import saveAs from 'file-saver';
   import ptMessages from "devextreme/localization/messages/pt.json";
   import { locale, loadMessages } from "devextreme/localization";
   import config from 'devextreme/core/config';
   import notify from 'devextreme/ui/notify';
   
   import Procedimento from '../http/procedimento';
   import Menu from '../http/menu';
   import grid from '../views/grid';
   import componente from '../views/display-componente';
   
   var filename    = 'DataGrid.xlsx';
     
   var dados = [];
   var sParametroApi = '';
   
   const dataGridRef = 'dataGrid';
     

   export default {
     data() {
       return {
         tituloMenu         : '',
         dt_inicial         : '',
         dt_final           : '',       
         columns            : [],
         pageSizes          : [10, 20, 50, 100],         
         dataSourceConfig   : [],
         total              : {},       
         dataGridInstance   : null,
         showIndicator      : true,
         showPane           : true,
         taskSubject        : 'Descritivo',
         taskDetails        : '',
         temD               : false,
         temPanel           : false,
         cd_menu_destino    : 0,
         cd_api_destino     : 0,
         qt_tempo           : 0,
         polling: 60000,
         exportar: false,
         buttonOptions: {
           text: 'Confirmar',
           type: 'success',
           useSubmitBehavior: true
         },
         dateBoxOptions: {
           invalidDateMessage:
             'Data tem estar no formato: dd/mm/yyyy'
         },
         cd_empresa  : 0,
         cd_menu     : 0,     
         cd_cliente  : 0,
         cd_api      : 0,
         api         : 0,
         ds_arquivo  : '',
         ds_menu_descritivo: '',
         popupVisible: false,
         periodoVisible: false,
         ic_form_menu: 'N',
         formData    : {},
         turno       : 'turno',
         entrega     : 'entrega',
         vol         : 'vol',
         comp        : 'comp',
         esp         : 'esp',
         larg        : 'larg',
         qtd         : 'qtd',
         data        : 'data',
         operador    : 'operador',
         cliente     : 'cliente',
         produto     : 'produto',
         peso        : 'peso',
         composicao  : 'composicao',
         peso_un     : 'peso_un',
         peso_esp    : 'peso_esp',
         peso_emb    : 'peso_emb',
         obs         : 'obs',
         funcionario : '',
         hoje        : '',
         hora        : '',
         inotifica   : 0,
         tabPanel    : false,
         ordem       : 0
       }  
     },
     computed: {
       dataGrid: function() {
         return this.$refs[dataGridRef].instance;
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
                        
              
       //this.showMenu();
       await this.showMenu();

      // alert(this.qt_tempo);

       if (!this.qt_tempo == 0) {
         this.pollData();   
         localStorage.polling = 1;
       }
   
     },   
   
     async mounted() {     
       
       this.carregaDados();
     },
   
     async beforeupdate() {
       this.carregaDados();
     },
   
   
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
       DxItem,
       DxForm,
       DxGroupItem,
       DxButton,
       DxSimpleItem,
       DxLabel,
       DxPopup,
       grid,
       componente
     
     },
     
     methods: { 
      
       popClick() {
         this.popupVisible = true;
       },
   
       onHiding() {
         this.popupVisible = false;        // Handler of the 'hiding' event
       },
   
       async showMenu() {
   
         this.cd_empresa = localStorage.cd_empresa;
         this.cd_cliente = localStorage.cd_cliente;
         this.cd_menu    = localStorage.cd_menu;
         this.cd_api     = localStorage.cd_api;
         this.api        = localStorage.nm_identificacao_api;
         
         //alert('a' + this.api);

         var data = new Date(),
             dia  = data.getDate().toString(),
             diaF = (dia.length == 1) ? '0'+dia : dia,
             mes  = (data.getMonth()+1).toString(), //+1 pois no getMonth Janeiro começa com zero.
             mesF = (mes.length == 1) ? '0'+mes : mes,
             anoF = data.getFullYear();
             
             localStorage.dt_inicial        =  mes+"-"+dia+"-"+anoF;
             localStorage.dt_final          =  mesF+"-"+diaF+"-"+anoF;
   
             dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';
   
             //this.sParametroApi       = dados.nm_api_parametro;
             sParametroApi = dados.nm_api_parametro;
             //
             //console.log(sParametroApi);
   
          //let sParametroApi = dados.nm_api_parametro;
          //console.log(dados.nm_api_parametro);
          //console.log(this.sParametroApi);
   
          this.qt_tabsheet        = dados.qt_tabsheet;
          this.cd_menu_destino    = this.cd_menu;
          this.cd_api_destino     = this.cd_api;
          this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa;
          this.exportar           = false;
          this.qt_tempo           = dados.qt_tempo_menu;
          this.ds_menu_descritivo = dados.ds_menu_descritivo;
          this.ic_form_menu       = dados.ic_form_menu;
   
          if ((!dados.nm_identificacao_api == '') && (!dados.nm_identificacao_api == this.api)) {
            this.api = dados.nm_identificacao_api;
          }

          //alert(this.ds_menu_descritivo);
   
          if (dados.ic_exportacao == 'S') {
            this.exportar = true;
          }
     
          localStorage.cd_tipo_consulta = 0;
   
          if (!dados.cd_tipo_consulta == 0) {
             dados.cd_tipo_consulta;
          }
   
          this.tituloMenu               = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
   
          filename    = this.tituloMenu+'.xlsx';
   
           //dados da coluna
          this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));  
           
          // console.log(this.columns);
   
           //dados do total
          this.total   = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
   
   
       },
   
       pollData: function () {
         if ( this.qt_tempo>0) {
           this.polling = setInterval(() => {
            var s           = new Date().toLocaleTimeString();  
            this.hora       = s.substring(0,5);             
            this.carregaDados();
           }, this.qt_tempo);
   
      } 
     },
           
     onFocusedRowChanged: function(e) {
         var data = e.row && e.row.data;
   
        // this.taskSubject = data && data.ds_informativo;
         this.taskDetails   = data && data.ds_informativo;
         this.ds_arquivo    = data && data.ds_arquivo; 
  
         if ( !data.ds_informativo == '') {
            this.temD = true;
         }
   
       },
   
       async carregaDados() {
         
         await this.showMenu();
            
         this.temPanel = true;
   
         if (this.inotifica == 0 ) {
            notify(`Aguarde... estamos montando a consulta para você, aguarde !`);
            this.inotifica = 1;
         }   
   
         if (this.qt_tabsheet==0) {
           //Gera os Dados para Montagem da Grid
           //exec da procedure
           
           //console.log(dados.nm_api_parametro);
           let sApi = sParametroApi;
           //
           //console.log(sApi);
           //        
   
           this.dataSourceConfig = await Procedimento.montarProcedimento(
                this.cd_empresa, 
                this.cd_cliente, 
                this.api, 
                sApi  ); 
           //

           this.formData = this.dataSourceConfig[0];

           //turno && operador
           this.turno       = this.dataSourceConfig[0].sg_turno;
           this.operador    = this.dataSourceConfig[0].nm_fantasia_operador;
           this.funcionario = this.dataSourceConfig[0].nm_funcionario;
           this.ordem       = this.dataSourceConfig[0].cd_processo;
           this.data        = new Date(this.dataSourceConfig[0].dt_programacao).toLocaleDateString();
           this.entrega     = new Date(this.dataSourceConfig[0].dt_entrega_processo).toLocaleDateString();
           this.cliente     = this.dataSourceConfig[0].nm_fantasia_cliente;
           this.produto     = this.dataSourceConfig[0].nm_produto_pedido;
           this.qtd         = this.dataSourceConfig[0].qt_planejada_processo;
           this.larg        = this.dataSourceConfig[0].qt_largura;
           this.esp         = this.dataSourceConfig[0].qt_espessura;
           this.comp        = this.dataSourceConfig[0].qt_comprimento;
           this.vol         = this.dataSourceConfig[0].qt_volume;
           this.peso        = this.dataSourceConfig[0].qt_peso_bruto_total;
           this.composicao  = this.dataSourceConfig[0].nm_projeto_composicao;
           this.peso_un     = this.dataSourceConfig[0].qt_peso_unitario;
           this.peso_esp    = this.dataSourceConfig[0].qt_peso_especifico;
           this.peso_emb    = this.dataSourceConfig[0].qt_embalagem;
           this.obs         = this.dataSourceConfig[0].nm_obs_operacao;
          
           
           //
           //alert(this.ordem);
           //
         }
         
   
       },
   
       onClickFecharTab(e) {
         this.tabPanel = false;  
         this.ic_form_menu = 'S';
       },
       onClickApontamento(e) {
         const buttonText = e.component.option('text');
           notify(` ${this.capitalize(buttonText)} !`);
         this.tabPanel = true;  
         this.ic_form_menu = 'G';
       },
       capitalize(text) {
          return text.charAt(0).toUpperCase() + text.slice(1);
       },
       
       customizeColumns(columns) {      
         columns[0].width = 120;
         
       },
   
       saveGridInstance(e) {
           this.dataGridInstance = e.component;
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
   
       exportGrid() {
     //    const doc = new jsPDF();
     //    exportDataGridToPdf({
     //      jsPDFDocument: doc,
     //      component: this.dataGrid
     //    }).then(() => {
     //      doc.save(filenamepdf);
     //    });    
       },
   
       beforeDestroy() {
          //alert('aqui');
          clearInterval(this.polling);
         // console.log('oi');
       },
   
       destroyed() {
         this.$destroy();
       }
   
     }
   };
   </script>

   <style>
   body{
     display: flex;
     flex-direction: column;
   }

   #parametro {
     margin-top: 5px;
     padding-top: 5px;
   }
   
   form {
     margin-left: 10px;
     margin-right: 10px;
     padding-left: 10px;
     padding-right: 10px;
     margin-top: 5px;
   
   }
   
   .task-info {
       font-family: Segoe UI;
       min-height: 200px;
       display: flex;
       flex-wrap: nowrap;
       border: 2px solid rgba(0, 0, 0, 0.1);
       padding: 5px;
       box-sizing: border-box;
       align-items: baseline;
       justify-content: space-between;
       margin-left: 10px;
       margin-right: 10px;
   }
   
   #taskSubject {
       line-height: 29px;
       font-size: 18px;
       font-weight: bold;
   }
   
   #taskDetails {
       line-height: 22px;
       font-size: 14px;
       margin-top: 0;
       margin-bottom: 0;
       padding-left: 10px;
   }
   
   #taskProgress {
       line-height: 42px;
       font-size: 40px;
       font-weight: bold;
   }
   
   .options {
       margin-top: 20px;
       padding: 20px;
       background-color: rgba(191, 191, 191, 0.15);
       position: relative;
   }
   
   .caption {
       font-size: 18px;
       font-weight: 500;
   }
   
   .option {
       margin-top: 10px;
       margin-right: 40px;
       display: inline-block;
    }
   
    .option:last-child {
        margin-right: 0;
    }
   
   .option > .dx-numberbox {
       width: 200px;
       display: inline-block;
       vertical-align: middle;
   }
   
   .option > span {
       margin-right: 10px;
   }
   
   #exportButton {
     margin-bottom: 10px;
   }
   
   .botao-exportar {
     margin-top: 10px;
     margin-left: 10px;
   }

   .botao-info {
     float: right;   
     right:10px;  
   }

   .info-periodo {
     margin-top: 10px;
     float: right;    
     margin-right: 25px;
     right: 10px;  
     font-size: 16px;
   }
   
   .info-cor {
     color: #506ad4;
     font-size: 20px;
   
   }
   
   #form-container {
    margin: 10px 10px 30px;
    font-size: 20px;
  }

  .label-info {
     float: left;   
  }
 
  #label-info-red {
     float: left;   
     color: red;
     font-size: 20px;
  }
   
.button {
  margin-right: 2px;
  width: 120px;
  height: 40px;
}

.info{
  margin-top: 7px;
  font-size: 17px;
  border-bottom: 1px solid black;
  border-left: 1px solid black;
  border-right: 1px solid black;
}

.coluna-40 {
    width: 40%;
    height: 100%;
}

.coluna-60 {
    width: 60%;
}

.linha{
display: flex;
flex-flow: row wrap;
}

</style>