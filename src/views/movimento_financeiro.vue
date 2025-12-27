<template>
 <div>

   <h2>Movimento Financeiro</h2>
    <br>
  <div class="row">
     <div class="col">
       <label><b>Data:  {{data_f}}</b></label>
     </div>
     <div class="col">
      <label><b>Código:</b></label>
     </div>
  </div>
        <br>
    <q-separator></q-separator>
        <br>
    <section class="container flex">
      <div class="lista col">
       <q-select
          filled
          label="Tipo de Lançamento"
          v-model="tipo_documento"
          :options="documento"
          option-value="cd_documento"
          option-label="nm_documento"
          option-disable="inactive"
          emit-value
          map-options
          style="min-width: 250px; max-width: 300px;"
          @input="limpar()"
        /> 
        </div>
        <div class="lista col">
          <q-select
                filled
                label="Destinatário"
                v-model="tipo_documento"
                :options="documento"
                option-value="cd_documento"
                option-label="nm_documento"
                option-disable="inactive"
                emit-value
                map-options
                style="min-width: 250px; max-width: 300px;"
                @input="limpar()"
              /> 
              </div>
            </section>


    <div class="row">
      <q-input outlined class="inp" type="number" v-model="num_documento" label="Nº Documento" />
    </div>

    <section class="container flex">
    <div class="col">
      <q-input class="inp" type="date" v-model="data_f" label="Emissão"/>
    </div>

    <div class="col">
      <q-input class="inp" type="date" v-model="data_f" label="Vencimento"/>
    </div>
    </section>

    <div class="inp row">
      <q-input outlined class="inp" type="number" reverse-fill-mask v-model="valor" prefix="R$ "/>
    </div>

    <q-input class="inp" label="Histórico"/>

    <div class="inp col">
    <q-select
          filled
          label="Histórico Financeiro"
          v-model="historico_financeiro"
          :options="financeiro"
          option-value="cd_financeiro"
          option-label="nm_financeiro"
          option-disable="inactive"
          emit-value
          map-options
          style="min-width: 250px; max-width: 300px;"
          @input="limpar()"
        /> 
      </div>

    <q-input class="inp" label="Observações"/>
    <br>
    <q-separator></q-separator> 
    <br>

    <div class="row">
      <q-input outlined class="inp" v-model="tipo_documento" label="Plano Financeiro"/>
    </div>
    <div class="row">
      <q-input outlined class="inp" v-model="tipo_documento" label="Centro de Custo"/>
    </div>


    <section class="container flex"> 
    <div class="but col">
      <DxButton
       :width="200"
       id="gerarButton"
       icon="check"
       styling-mode="contained"
       horizontal-alignment="left"
       type="default"
       text="Gerar"  
       :visible="true"      
     />
     </div>
     <div class="but col">
      <DxButton
      :width="200"
      id="gerarButton"
      icon="remove"
      styling-mode="contained"
      horizontal-alignment="left"
      type="default"
      text="Limpar"  
      :visible="true"
      @click="limpar()"   
    />
     </div>
     </section>
    
  </div>
</template>

<script>

import grid from './grid.vue';
import DxButton from 'devextreme-vue/button';
import dxButton from 'devextreme/ui/button';

export default {
  components: { grid, DxButton },
  
  data() {
    return {
        DxButton,
        tipo_documento: '',
        num_documento: '',
        emissao: '',
        vencimento: '',
        valor: '',
        data_f: '',
        financeiro: [
                {"cd_financeiro": 1,
                 "nm_financeiro": "TED"},
                {"cd_financeiro": 2,
                 "nm_financeiro": "DOC"},
                {"cd_financeiro": 3,
                 "nm_financeiro": "Tarifa Conta Certa"},
                 {"cd_financeiro": 4,
                 "nm_financeiro": "Rend Smart Account"},
                 {"cd_financeiro": 5,
                 "nm_financeiro": "Liquid. Prazo Fixo"},
                 {"cd_financeiro": 6,
                 "nm_financeiro": "Mensagem Swift"},
                 {"cd_financeiro": 7,
                 "nm_financeiro": "Edição Contrato"},
                 {"cd_financeiro": 8,
                 "nm_financeiro": "Contrato de Câmbio"},
                 {"cd_financeiro": 9,
                 "nm_financeiro": "Estorno Tribut e Contas"},
                 {"cd_financeiro": 10,
                 "nm_financeiro": "Resgate de Aplicação"},
                 {"cd_financeiro": 11,
                 "nm_financeiro": "Tarifa Bancária"},
                 {"cd_financeiro": 12,
                 "nm_financeiro": "Siscomex"},
                 {"cd_financeiro": 13,
                 "nm_financeiro": "Seguro"}
                ],
                documento: [
               {"cd_documento": 1,
                 "nm_documento": "ENTRADA"},
                {"cd_documento": 2,
                 "nm_documento": "SAIDA"},
                ]
    }
  },
 
  created(){

   this.ExemploTeste()
 },


methods: {

limpar(){
  this.tipo_documento = ''
  this.num_documento = ''
  this.emissao = ''
  this.vencimento = ''
  this.valor = ''

},

ExemploTeste(){
  this.tipo_documento =  grid.Selecionada().ic_tipo_movimento
  this.num_documento  =  grid.Selecionada().Documento
  this.emissao        =  grid.Selecionada().dt_movimento
  this.vencimento     =  grid.Selecionada().dt_movimento
  this.valor          =  grid.Selecionada().vl_movimento
  let dataI = new Date();
  let Hoje = dataI.getDate().toString()
  let Mes  = (dataI.getMonth()+1).toString(); 
  let Ano  = dataI.getFullYear();
  let data_formatada = (Hoje+'/'+Mes+'/'+Ano)
  this.data_f = data_formatada

},

}

}
</script>
<style>
.row{
  margin: 10px;
}
.mgl{
  margin-left: 10px;
}
.but{
  margin: 10px;
  display: inline;
}
.inp{
  width: 60%;
  text-align: center;
}

.lista {
	margin: 5px;
	text-align: center;
	font-size: 1.5em;
}
</style>