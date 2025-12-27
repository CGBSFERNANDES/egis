<template>
  <div>
    <h2 class="content-block">{{tituloMenu}}</h2>
    <div>
    <DxForm :form-data="formData">
    <template #avatar-template="{}">
      <div class="form-avatar"/>
    </template>
    <DxGroupItem
      :col-count="4"
      css-class="first-group"
    >
      <DxSimpleItem template="avatar-template"/>
      <DxGroupItem :col-span="3">
        <DxSimpleItem data-field="FirstName"/>
        <DxSimpleItem data-field="LastName"/>
        <DxSimpleItem          
          data-field="dt_hoje"
          editor-type="dxDateBox"
        />
      </DxGroupItem>
    </DxGroupItem>
    <DxGroupItem
      :col-count="2"
      css-class="second-group"
    >
    </DxGroupItem>

    </DxForm>
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
      @initialized="saveGridInstance">     
      >
      <DxGroupPanel :visible="true"
       empty-panel-text="Colunas para agrupar..."/>
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
        :visible="true"
        :width="240"
        placeholder="Procurar..."
      />
      <DxFilterPanel :visible="true"/>      
      <DxColumnFixing :enabled="true"/>      
      <DxColumnChooser
        :enabled="true"
        mode="select"
      />          
    </dx-data-grid>
    
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
  DxForm,
  DxSimpleItem,
  DxGroupItem,
  DxSearchPanel

 // DxLoadPanel
  
  //DxSortByGroupSummaryInfo
} from "devextreme-vue/data-grid";

import { exportDataGrid } from 'devextreme/excel_exporter';
import ExcelJS from 'exceljs';
import saveAs from 'file-saver';
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from 'devextreme/core/config';

import Procedimento from '../http/procedimento';
import Menu from '../http/menu';
import notify from 'devextreme/ui/notify';

var cd_empresa    = 0
var cd_menu       = 0;
var cd_fornecedor = 0;
var cd_api        = 0;
var api           = '';

var filename      = 'DataGrid.xlsx';
var dados         = [];

export default {
  data() {
    return {
      tituloMenu: '',
      columns: [],
      pageSizes: [10, 20, 50, 100],
      autoNavigateToFocusedRow: true,
      isReady: false,
      dataSourceConfig : [],
      total : {},       
      dataGridInstance: null,
      showIndicator: true,
      showPane: true,
      formData: []
      

    };
  },
  created() {
     // locale(navigator.language);
    config({ defaultCurrency: 'BRL' });  
    loadMessages(ptMessages);
    locale(navigator.language);     
  },   

async mounted() {
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
    DxForm,
    DxSimpleItem,
    DxGroupItem,
    DxSearchPanel


    //DxLoadPanel
  },
  
  methods: {
            
    async carregaDados() {
      
      cd_empresa    = localStorage.cd_empresa;
      cd_fornecedor = localStorage.cd_fornecedor;
      cd_menu       = localStorage.cd_menu;
      cd_api        = localStorage.cd_api;
      api           = localStorage.nm_identificacao_api;

      //alert(api);
      
      //if (api=='') {
      //  alert('erro de processamento - verifique com suporte !');
     // }

      //alert(cd_menu);
      //cd_menu = 6515;
      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';

      this.tituloMenu   = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      let sParametroApi = dados.nm_api_parametro;
  
      //Gera os Dados para Montagem da Grid
      //exec da procedure
      this.dataSourceConfig = await Procedimento.montarProcedimento(cd_empresa, cd_fornecedor, api, sParametroApi ); 
      //

      //alert(typeof(this.dataSourceConfig));
      
      this.formData = JSON.parse(JSON.stringify( this.dataSourceConfig ));  
      //alert(typeof( this.formData));              

      //Nome do Arquivo para Exportação Excell
      filename      = this.tituloMenu+'.xlsx';

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));  
        
      //dados do total
      this.total   = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //

    },

    customizeColumns(columns) {      
      columns[0].width = 120;
      
    },

    saveGridInstance(e) {
        this.dataGridInstance = e.component;
    },

    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet('Employees');

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
    destroyed() {
      this.$destroy();
    }
  }
};
</script>



<style>
.first-group,
.second-group {
  padding: 20px;
}
.second-group {
  background-color: rgba(191, 191, 191, 0.15);
}
.form-avatar {
  height: 128px;
  width: 128px;
  margin-right: 10px;
  border: 1px solid #d2d3d5;
  border-radius: 50%;
  background-image: url("/img/evento.png");
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
}
</style>
