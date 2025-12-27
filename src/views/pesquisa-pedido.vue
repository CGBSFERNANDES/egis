<template>
 <div>
    <h2 class="content-block">Pesquisa de Pedido</h2>

    <div class="content-block dx-card responsive-paddings">

      <dx-form
        id="form"
        label-location="top"
        :form-data="formData"
        :colCountByScreen="colCountByScreen"        

      />  
      <div class="buttons-column botao-pesquisa">
          <div>
            <DxButton
              :width="140"
              icon="find"
              text="Pesquisar"
              type="default"
              styling-mode="contained"
              @click="onClick($event)"
            />
          </div>
      </div>      

    <dx-data-grid
      class="dx-card wide-card-d"
      :ref="dataGridRefName"      
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
      :repaint-changes-only="false"    
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

</div>
</template>

<script>

import DxForm from "devextreme-vue/form";
import DxButton from 'devextreme-vue/button';
import notify from 'devextreme/ui/notify';

//import DxSelectBox from 'devextreme-vue/select-box';
import 'devextreme/data/odata/store';

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
  
       } from 'devextreme-vue/data-grid';

import { exportDataGrid } from 'devextreme/excel_exporter';
import ExcelJS from 'exceljs';
import saveAs from 'file-saver';
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from 'devextreme/core/config';

import Procedimento from '../http/procedimento';
import Menu from '../http/menu';

var cd_empresa = 0
var cd_menu    = 0;
var cd_cliente = 0;
var cd_api     = 0;
var api        = '';

var filename   = 'DataGrid.xlsx';
var dados = [];

export default {
  data() {
    
    return {     
      formData: {        
        PedidoCliente: ""   
           
      },
     colCountByScreen: {
        xs: 1,
        sm: 2,
        md: 3,
        lg: 4
      },  
      dataGridRefName: 'dataGrid',    
      statuses: ['Não Habilitado'],      
      tituloMenu: '',
      columns: [],
      pageSizes: [10, 20, 50, 100],
      autoNavigateToFocusedRow: true,
      isReady: false,
      dataSourceConfig : [],
      total : {},       
      dataGridInstance: null,
      showIndicator: true,
      showPane: true
    }
  },
  created() {
     // locale(navigator.language);
    config({ defaultCurrency: 'BRL' });  
    loadMessages(ptMessages);
    locale(navigator.language);     
  },

  async mounted() {

      localStorage.cd_familia_produto = 0;
      localStorage.nm_produto          = 'null';
      localStorage.nm_fantasia_produto = 'null';
      localStorage.nm_fantasia         = '';
      localStorage.nm_razao_social     = '';
          
    //this.carregaDados();
  },

  components: {
    DxForm,
    DxButton,
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
  //  DxSelectBox
  },  


  methods: {

    async carregaDados() {
      
      cd_empresa = localStorage.cd_empresa;
      cd_cliente = localStorage.cd_cliente;
      cd_menu    = localStorage.cd_menu;
      api        = localStorage.nm_identificacao_api;
      cd_api     = localStorage.cd_api;

      dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api);
       //'titulo';
      let sParametroApi = dados.nm_api_parametro;
  
      //alert(sParametroApi);

      this.tituloMenu       = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';

      //Gera os Dados para Montagem da Grid
      //exec da procedure
      this.dataSourceConfig = await Procedimento.montarProcedimento(cd_empresa, cd_cliente, api, sParametroApi ); 
      //

      filename   = this.tituloMenu+'.xlsx';

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));  
      //alert(this.columns);        
      //dados do total
      this.total   = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //

       const dataGrid = this.$refs[this.dataGridRefName].instance;
       dataGrid.clearFilter();

    },
    onValueChanged({ value }) {
      alert(value);
     },   

    onClick(e) {
 
      const buttonText = e.component.option('text');
      notify(`Aguarde... vamos ${this.capitalize(buttonText)} os pedidos !`);
            
      localStorage.nm_documento = '';
      //alert(this.formData.Fantasia);

      if (!this.formData.PedidoCliente == '') {
        localStorage.nm_documento = this.formData.PedidoCliente;
      }
     

      this.carregaDados();

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

.buttons-demo {
    width: 600px;
    align-self: center;
}

.buttons-column > .column-header {
    flex-grow: 0;
    width: 150px;
    height: 35px;
    font-size: 130%;
    opacity: 0.6;
    text-align: left;
    padding-left: 10px;
}

.buttons {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
}

.buttons > div {
    width: 300px;
    flex-wrap: nowrap;
    display: flex;
}

.buttons-column > div {
    width: 150px;
    height: 50px;
    text-align: center;
    padding-left: 5px;
    margin-top: 15px;    
    margin-left: -20px;
}

.buttons-column {
    width: 150px;
    justify-content: center;
}

.task-info {
    font-family: Segoe UI;
    min-height: 200px;
    display: flex;
    flex-wrap: nowrap;
    border: 2px solid rgba(0, 0, 0, 0.1);
    padding: 16px;
    box-sizing: border-box;
    align-items: baseline;
    justify-content: space-between;
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
}
.progress {
    display: flex;
    flex-direction: column;
    white-space: pre;
    min-width: 105px;
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
    padding: 10px;
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

.right-side {
  position: absolute;
  right: 350px;
  top: 142px;
}
.botao-pesquisa{
  margin: -5px 0 15px 15px;
}
</style>
