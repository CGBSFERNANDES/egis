<template>
    <div>  
     <div>
       <h2 class="content-block">{{tituloMenu}}</h2>       
     </div>  
     <div>
      <div v-if="1==2"
         class="dx-card wide-card">
    <q-card class="my-card">
      
      <q-list>
        <q-item>
          <q-item-section avatar>
            <q-icon color="primary" name="date_range" />
            <q-item-label>Dias Úteis
              <q-badge  
                rounded color="red" :label="qt_dia_util" />            
            </q-item-label>
            
          </q-item-section>
        </q-item>

        <q-item clickable>
          <q-item-section avatar>
            <q-icon color="red" name="update" />
          </q-item-section>

          <q-item-section>
            <q-item-label>Transcorridos
              <q-badge  
                rounded color="red" :label="qt_dia_transcorrido" />            
            </q-item-label>
            
          </q-item-section>
        </q-item>

        <q-item clickable>
          <q-item-section avatar>
            <q-icon color="amber" name="hourglass_empty" />
          </q-item-section>

          <q-item-section>
            <q-item-label>Tempo
              <q-badge  
                rounded color="red" :label="pc_tempo" />            
            </q-item-label>
            
          </q-item-section>
        </q-item>
      </q-list>
    </q-card>
  </div>         

      <DxChart class="dx-card wide-card"
       id="chart"
       :data-source="dataSourceConfig"
       :sticky-hovering="false"      
       title="Análise Diária da Quantidade"
       palette="Harmony Light"
       >
       <DxSize :height="420"/>
       <DxValueAxis
        title="Tonelada (TN)"
        :grid="{ opacity: 0.2 }"
        value-type="numeric"
       >      
       </DxValueAxis> 
      <DxCommonSeriesSettings          
          argument-field="cd_dia"
          hover-mode="includePoints"
       >
       <DxBorder
            :visible="false"
            :width="2"
            :top="false"
            :right="false"
          />

       <DxPoint hover-mode="allArgumentPoints"/>
       </DxCommonSeriesSettings>
       <DxSeries
          type="spline"
          v-for="i in dataLegenda"
          :key="i.value"
          :value-field="i.value"
          :name="i.name"
       />
       <DxMargin :bottom="10"/>
       <DxArgumentAxis       
        title="Dias"
        :value-margins-enabled="true"
        discrete-axis-division-mode="crossLabels"
        :visual-range="range"
       >
       <DxGrid 
          :visible="false"
          :opacity="0.5"/>
       </DxArgumentAxis>
       <DxCrosshair
        :enabled="true"
        :width="2"
        color="#949494"
        dash-style="dot"
       >
       <DxLabel
        :visible="true"
        background-color="#949494"
       >
       <DxFormat type="decimal"/>
        <DxFont
          :size="12"
          color="#fff"
        />
       </DxLabel>
      </DxCrosshair>

       <DxLegend
         vertical-alignment="bottom"
         horizontal-alignment="center"
         hover-mode="excludePoints"
         :equal-column-width="true"
         item-text-position="bottom"
         :visible="true"        
       />
       <DxTitle text=" Faturamento">
       <DxSubtitle text=" (valores em R$)"/>
       </DxTitle>
       <DxExport :enabled="true"/>
       <DxLoadingIndicator :enabled="true"/>
       <DxTooltip
         :enabled="true"
         :customize-tooltip="customizeTooltip"
       />       
      </DxChart>
      <DxRangeSelector
      v-if="1==2"
      :data-source="dataSourceConfig"
      :v-model="range"
    >
      <DxSize :height="120"/>
      <DxMargin :left="10"/>
      <DxScale :minor-tick-count="1"/>
      <DxRsChart
        :series="series"
        palette="Harmony Light"
      />
      <DxBehavior call-value-changed="onMoving"/>
    </DxRangeSelector>


      <DxPieChart v-if="1==2"
        class="dx-card wide-card pie"
        id="pie"
        :data-source="dataSourceConfig"
        type="doughnut"
        title="Contas a Pagar"
        palette="Soft Pastel"          
        @point-click="pointClickHandler($event)"
        @legend-click="legendClickHandler($event)"
      >
     <DxSeries
        argument-field="cd_ano"
        value-field="vl_total"
      >
      <DxLabel :visible="true">
        <DxConnector
          :visible="true"
          :width="1"
        />
      </DxLabel>
     </DxSeries>
    <DxLegend
        :row-count="1"
        vertical-alignment="bottom"
        horizontal-alignment="center"
        item-text-position="right"
      />
    
    <DxSize :width="500"/>
    <DxExport :enabled="true"/>
    <DxTooltip
      :enabled="true"
      :customize-tooltip="customizeTooltip"
    >
      <DxFormat
        type="millions"
      />
    </DxTooltip>    
  </DxPieChart>

  <DxChart 
    v-if="1==2"
    class="dx-card wide-card pie"
    id="chart"
    :data-source="dataSourceConfig"
    title="Anual"
  >
    <DxSeries
      argument-field="nm_ano"
      value-field="vl_total"
      name="Valores R$"
      type="bar"
      color="#ffaa66"
    />
    <DxExport :enabled="true"/>
  </DxChart>


    </div>  
    <div>
       <h2 class="content-block">Dados</h2>      
     </div>  

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
    
     </div>
   </template>
   
   <script>
   
   
   import {
     DxDataGrid,
     DxFilterRow,
     DxPager,
     DxPaging,     
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
   
  
   import { exportDataGrid } from 'devextreme/excel_exporter';
   import ExcelJS from 'exceljs';
   import saveAs from 'file-saver';
   import ptMessages from "devextreme/localization/messages/pt.json";
   import { locale, loadMessages } from "devextreme/localization";
   import config from 'devextreme/core/config';
   import notify from 'devextreme/ui/notify';
   
   import Procedimento from '../http/procedimento';
   import Menu from '../http/menu';
   
   import {
  DxChart,
  DxCommonSeriesSettings,
  DxSeries,
  DxArgumentAxis,
  DxGrid,
  DxCrosshair,
  DxExport,
  DxLegend,
  DxPoint,
  DxLabel,
  DxFont,
  DxTitle,
  DxSubtitle,
  DxTooltip,
  DxLoadingIndicator,
  DxBorder,
  DxValueAxis
} from 'devextreme-vue/chart';

import {
  DxRangeSelector,
  DxMargin,
  DxScale,
  DxChart as DxRsChart,
  DxBehavior
} from 'devextreme-vue/range-selector';

import DxPieChart, {
  DxSize,
  DxConnector 
} from 'devextreme-vue/pie-chart';

   var cd_empresa  = 0
   var cd_menu     = 0;
   var cd_cliente  = 0;
   var cd_api      = 0;
   var api         = '';
   
   var filename    = 'DataGrid.xlsx';
   
   var dados = [];
   
   const dataGridRef = 'dataGrid';
     

   export default {
     data() {
       return {
         tituloMenu         : '',
         dt_inicial         : '',
         dt_final           : '',      
         columns            : [],
         pageSizes          : [10, 20, 50, 100],
         autoNavigateToFocusedRow: true,
         isReady            : false,
         dataSourceConfig   : [],
         total              : {},       
         dataGridInstance   : null,
         showIndicator      : true,
         showPane           : true,
         taskSubject        : 'Descritivo',
         taskDetails        : '',
         temD               : false,
         temPanel           : false,
         dataLegenda        : [{ value: 'qt_meta', name: 'Meta'},
                               { value: 'qt_venda', name: 'Vendas'},
                               { value: 'qt_liberado', name: 'Liberado'},                               
                               { value: 'qt_baixado', name: 'Produção'},
                               { value: 'qt_faturado', name: 'Faturamento'}
                              ],
          qt_dia_util         : 0,
          qt_dia_restante     : 0,
          qt_dia_transcorrido : 0,
          pc_tempo            : 0,
          range: [],
          series: [{
        valueField: 'qt_meta'
      }, {
        valueField: 'qt_venda'
      }, {
        valueField: 'qt_liberado'
      },
      {
        valueField: 'qt_baixado'
      },
      {
        valueField: 'qt_faturado'
      },
      ]
         
       };
     },
     computed: {
       dataGrid: function() {
         return this.$refs[dataGridRef].instance;
       }
     },  
     created() {
       config({ defaultCurrency: 'BRL' });  
       loadMessages(ptMessages);
       locale(navigator.language);     
       this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();      
       this.dt_final   = new Date(localStorage.dt_final).toLocaleDateString();      
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
       DxChart,
       DxCommonSeriesSettings,
       DxSeries,
       DxArgumentAxis,
       DxGrid,
       DxCrosshair,    
       DxLegend,
       DxPoint,
       DxLabel,
       DxFont,
       DxTitle,
       DxSubtitle,
       DxTooltip,
       DxPieChart,
       DxSize,
       DxConnector,
       DxLoadingIndicator,
       DxBorder,
       DxValueAxis,       
       DxRangeSelector,    
       DxScale,
       DxRsChart,
       DxBehavior,
       DxMargin       
     },
     
     methods: {
      customizeTooltip({ valueText }) {
      return {
        text: `${valueText}${' TN'}`
      };
      },      
       pointClickHandler(e) {
          this.toggleVisibility(e.target);
       },
       legendClickHandler(e) {
         let arg = e.target,
         item = e.component.getAllSeries()[0].getPointsByArg(arg)[0];

         this.toggleVisibility(item);
       },
       toggleVisibility(item) {
          item.isVisible() ? item.hide() : item.show();
       },

        onFocusedRowChanged: function(e) {
         var data = e.row && e.row.data;
         this.taskDetails   = data && data.ds_informativo;
      
         if ( !data.ds_informativo == '') {
            this.temD = true;
         }
   
       },
   
       async carregaDados() {
         
         this.temPanel = true;
   
         cd_empresa = localStorage.cd_empresa;
         cd_cliente = localStorage.cd_cliente;
         cd_menu    = localStorage.cd_menu;
         cd_api     = localStorage.cd_api;
         api        = localStorage.nm_identificacao_api;
   
         var data = new Date(),
             dia  = data.getDate().toString(),
             diaF = (dia.length == 1) ? '0'+dia : dia,
             mes  = (data.getMonth()+1).toString(), //+1 pois no getMonth Janeiro começa com zero.
             mesF = (mes.length == 1) ? '0'+mes : mes,
             anoF = data.getFullYear();
             
             localStorage.dt_inicial        =  mes+"-"+dia+"-"+anoF;
             localStorage.dt_final          =  mesF+"-"+diaF+"-"+anoF;
   
  
         notify(`Aguarde... estamos montando a consulta para você, aguarde !`);
   
   
         dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';
   
         let sParametroApi       = dados.nm_api_parametro;
   
         localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;
   
   
         this.tituloMenu       = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
   
         this.dataSourceConfig = await Procedimento.montarProcedimento(cd_empresa, cd_cliente, api, sParametroApi ); 
   
         filename    = this.tituloMenu+'.xlsx';

         //dados da coluna
           this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));  
           
        //console.log(this.dataSourceConfig[0]) ;

         //dados do total
           this.total   = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
         //
          
         //Dados para mostrar
         this.qt_dia_util         = this.dataSourceConfig[0].qt_dia_util;
         this.qt_dia_restante     = this.dataSourceConfig[0].qt_dia_restante;
         this.qt_dia_transcorrido = this.dataSourceConfig[0].qt_dia_transcorrido;
         this.pc_tempo            = this.dataSourceConfig[0].pc_tempo;
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
       },
   
       destroyed() {
         this.$destroy();
       }
     }
   };
   </script>
   <style>  
   
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
   
   .info {
       margin-right: 40px;
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
    
  #chart {
    height: 440px;
  } 

  .pies-container {
    margin: auto;
    width: 800px;
}

.pies-container > .pie {
    width: 400px;
    float: left;
}


.my-card {
  width: 100%; 
  height: 100px;
  
}  
</style>
   