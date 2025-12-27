<template>
    <div>
      <DxSelectBox
         class="dx-card wide-card"
         :data-source="dataset"
         :value-expr="id"
         :display-expr="display"
         placeholder=" Selecionar"
         :show-clear-button="true"
      >
      </DxSelectBox>
  
    </div>  
  </template>

  <script>

  import DxSelectBox from 'devextreme-vue/select-box';
  import Lookup from '../http/lookup'; 
  
  export default {
     components: { DxSelectBox
    },
    props: {
      cd_empresaID      : { type: Number, default: 0 },
      cd_tabelaID       : { type: Number, default: 0 }      
    },
    data() {
      return {
         dados   : [],
         dataset : [],
         id      : '',
         display : '',
         cd_empresa: 0,
         cd_tabela : 0  
      }
    },
  
    async created() { 
      this.dados = '';
      this.dataset = [];
      this.cd_empresa = this.cd_empresaID;  
      this.cd_tabela  = this.cd_tabelaID;
      //alert(this.cd_empresa);
      //alert(this.cd_tabela);
      if ( !cd_empresa == 0 && !cd_tabela == 0 ) {
         this.dados   = await Lookup.montarSelect(this.cd_empresa, this.cd_tabela);
         this.dataset =   JSON.parse(JSON.parse(JSON.stringify(this.dados.dataset))); 
         this.id      = this.dados.chave;
         this.display = this.dados.display;
      }
  
    }  
  }
  </script>
  <style scoped>
  
  </style>