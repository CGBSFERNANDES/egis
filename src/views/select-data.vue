<template>
  <DxSelectBox
    class='select-box'
    :defer-rendering="false"
    :data-source="dataSourceConfig"
    :value="value"
    :value-expr="controleID"
    :display-expr="descricaoID"
    @valueChanged="$emit('controle-changed', $event.value)"
  />
</template>

<script>

import DxSelectBox from 'devextreme-vue/select-box';
import Lookup from '../http/select.js';

var cd_empresa    = 0
var api           = '';

export default {
  components: { DxSelectBox },
  props: {
    chaveId: {
      type: Number,
      default: null
    }
  },
  data() {
    return {
      dataSource: [],
      value: null,
      controleID : null,
      descricaoID : null
    };
  },

  async mounted() {
     this.carregaDados();
  },

  methods: {

    async carregaDados() {
     
      cd_empresa = localStorage.cd_empresa;
     //api        = localStorage.nm_identificacao_api;

      //api = 'CondicaoPagamento/Consulta';
      api = 'CategoriaProduto/Get';

      this.dataSourceConfig = await Lookup.montarSelect(cd_empresa, api); 

      
      //this.controleID  = 'cd_condicao_pagamento';
     // this.descricaoID = 'nm_condicao_pagamento';
      this.controleID  = Object.keys( this.dataSourceConfig[0])[0]; //'cd_destinacao_produto'; //[0]
      this.descricaoID = Object.keys( this.dataSourceConfig[0])[1];

     //this.value = 1;

     // setDefaultValue(this.dataSourceConfig);
      let firstItem = Object.values(this.dataSourceConfig[0])[0];
      

      if(firstItem && this.value === null) {
        this.value = firstItem;
      }

     // alert(this.dataSourceConfig[0].nm_condicao_pagamento);

    }

  }
};
</script>

<style scoped>
.select-box {
  margin-left: 0px;
  width: 200px;
} 
</style>