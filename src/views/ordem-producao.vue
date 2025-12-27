<template>
    <div id="form-demo">
        <div>
          <h2 class="content-block">{{tituloMenu}} - {{numero}}</h2>
    
        </div>   
      <div class="dx-card wide-card">
        <form
          action="your-action"
          @submit="handleSubmit"
        >
          <DxForm
            v-model:form-data="customer"
            :read-only="false"
            :show-colon-after-label="true"
            :show-validation-summary="true"
            
          >
            <DxGroupItem caption="CLIENTE">
            </DxGroupItem>
            <DxGroupItem caption="PRODUTO">
              <DxSimpleItem 
              caption='Produto'
              data-field="nm_fantasia_produto">
              </DxSimpleItem>
            </DxGroupItem>
            <DxGroupItem caption="COMPOSIÇÃO">
              
            </DxGroupItem>
            <DxButtonItem class="buttons-column"
              :button-options="buttonOptions"
              horizontal-alignment="left"
            />
          </DxForm>
        </form>
      </div>
    </div>
  </template>
  <script>
  import DxForm, {
    DxGroupItem,
    DxSimpleItem,
    DxButtonItem,
    DxLabel,
    DxRequiredRule,
    DxCompareRule,
    DxRangeRule,
    DxStringLengthRule,
    DxPatternRule,
    DxEmailRule,
    DxAsyncRule
  } from 'devextreme-vue/form';
  import DxAutocomplete from 'devextreme-vue/autocomplete';
  
  import notify from 'devextreme/ui/notify';
  
  
  
  export default {
    components: {
      DxGroupItem,
      DxSimpleItem,
      DxButtonItem,
      DxLabel,
      DxRequiredRule,
      DxCompareRule,
      DxPatternRule,
      DxRangeRule,
      DxEmailRule,
      DxStringLengthRule,
      DxForm,
      DxAutocomplete,
      DxAsyncRule,
      notify
    },
    props: {
      cd_ordemID      : { type: Number, default: 0 },
      o_ordem         : { type: Object}
  },    
    data() {
      return {
        tituloMenu: 'Ordem de Produção', 
        numero: '',
        customer: [],
        buttonOptions: {
          text: 'INÍCIO',
          type: 'success',
          useSubmitBehavior: true
        },
      };
    },
    created() {
      //this.numero = this.cd_ordemID;
    },  
    mounted() {
      this.numero = this.cd_ordemID;
      this.customer = this.o_ordem;
    },
    methods: {
      handleSubmit(e) {
        notify({
          message: 'You have submitted the form',
          position: {
            my: 'center top',
            at: 'center top'
          }
        }, 'success', 3000);
        e.preventDefault();
      }
    }
  };
  </script>
  <style scoped>
  form {
    margin: 10px;
  }
  </style>
  