<template>
    <div>  
     <DxForm
       :form-data="formData"
       label-location="top"
       :read-only="true"
       :show-colon-after-label="true"  
     >

        <template #avatar-template="{}">
          <div class="form-avatar"/>
        </template>

      <DxGroupItem
         :col-count="4"
         css-class="first-group"
      >
        <DxSimpleItem 
          template="avatar-template"
          :visible="false"
        />
        
        <DxGroupItem
           caption="Dados"
           item-type="group"
           :col-span="5">
           <DxSimpleItem  
            name="Data"    
            data-field="Data"
            :is-required="true"
            :visible="true"
            
           >
           <DxLabel text="Data" />

           </DxSimpleItem >
           <DxSimpleItem  
            name="Dia_Uteis"    
            data-field="Dia_Uteis"
            :is-required="false"
            :visible="true"            
           >
           <DxLabel text="Dias Úteis" />
           </DxSimpleItem>
           <DxEmptyItem :col-span="2" />
           <DxSimpleItem                      
            data-field="Dia_Transcorridos"
           >
           <DxLabel text="Dias Transcorridos" />                
          </DxSimpleItem>  
          <DxSimpleItem                      
            data-field="Dias_Restante"
           >
           <DxLabel text="Dias Restante" />                
          </DxSimpleItem>  
          <DxSimpleItem                      
            data-field="Tempo_Decorrido"
           >
           <DxLabel text="Tempo" />                
          </DxSimpleItem>  

        </DxGroupItem>     
     </DxGroupItem>  
    </DxForm>

</div>
      
 </template>
   
  <script>
    
   
   import DxForm, {
     DxGroupItem,  
     DxSimpleItem,
     DxLabel
   } from 'devextreme-vue/form';
   
   import DxButton from 'devextreme-vue/button';
   import ptMessages from "devextreme/localization/messages/pt.json";
   import { locale, loadMessages } from "devextreme/localization";
   import config from 'devextreme/core/config';
   
   import Procedimento from '../http/procedimento';
   import Menu from '../http/menu';
    

   var cd_empresa  = 0
   var cd_menu     = 0;
   var cd_cliente  = 0;
   var cd_api      = 0;
   var api         = '';
   
   var dados = [];
   
     
   export default {
     data() {
       return {
         tituloMenu         : '',
         dt_inicial         : '',
         dt_final           : '',      
         columns            : [],
         dataSourceConfig   : [],
         formData           : {}             
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
       DxForm,
       DxGroupItem,
       DxButton,
       DxSimpleItem,
       DxLabel
       
     },
     
     methods: {
      
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
        
         dados = await Menu.montarMenu(cd_empresa, cd_menu, cd_api); //'titulo';
   
         let sParametroApi       = dados.nm_api_parametro;
   
         localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;   
  
         this.dataSourceConfig = await Procedimento.montarProcedimento(cd_empresa, cd_cliente, api, sParametroApi ); 
            
         //dados da coluna
         this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));  
         
         //console.log( this.dataSourceConfig[0]);
         //console.log( this.dataSourceConfig);
         //console.log( typeof(this.dataSourceConfig[0]));
         //console.log( typeof(this.dataSourceConfig));

         this.formData = this.dataSourceConfig[0];

         //console.log(typeof(this.formData));
         //console.log(this.formData);

         //alert(this.formData.Dia_Uteis);

       },
   
       destroyed() {
         this.$destroy();
       }

     }

   };
   </script>

   <style>
   
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
 
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
}
   </style>