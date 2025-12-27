<template>
  <div>
    <h2 class="content-block">{{tituloMenu}}</h2>

    <div class="content-block dx-card responsive-paddings">
          <DxForm
          class="form-container"
          id="form"
          label-location="top"
          :colCountByScreen="colCountByScreen"  
         >   
        <DxItem>
          <DxLabel text="Cliente"/>
        </DxItem>
        <DxItem>
          <DxLabel text="Contato"/>
        </DxItem>
        <DxItem template="select-box">
          <DxLabel text="Condição de Pagamento"/>
        </DxItem>
        <SelectBoxData
         slot="select-box"
         :chaveId="controleID"
         @controle-changed="chosenChaveID = $event"
        />
        <DxItem>
          <DxLabel text="Tipo de Pedido"/>
        </DxItem>
        <DxItem>
          <DxLabel text="Pedido Cliente"/>
        </DxItem>
        <DxItem>
          <DxLabel text="Observações"/>
        </DxItem>

         </DxForm>
    </div>

  </div>
</template>

<script>
import { DxForm, DxLabel, DxItem } from 'devextreme-vue/form';
import SelectBoxData from './select-data.vue';

export default {
     components: {
         DxForm,
         DxItem,
         DxLabel,
         SelectBoxData
     },
 data() {
    return { 

    }
 }            
}

</script>
<style scoped>

</style>