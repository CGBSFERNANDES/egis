<template>
  <div>
   <h2 class="content-block">{{tituloMenu}}</h2>

   <div class="content-block" style="max-width: 600px">
   <q-input v-model="text" label="Cliente" placeholder="Fantasia" hint="pesquisa do cliente" :dense="dense" />
   </div>
   <div class="content-block dx-card responsive-paddings">

   <div class="q-pa-md q-gutter-y-sm">
    <q-toolbar class="text-primary">
      <q-btn flat round dense icon="assignment_ind" />
      <q-toolbar-title>
        {{tituloCliente}}
      </q-toolbar-title>
      <q-btn flat round dense icon="more_vert" />
    </q-toolbar>

  </div>
  
  </div>
  <div class="content-block" style="max-width: 550px">
    <q-list bordered>
      <q-expansion-item icon="mail" label="Inbox" caption="5 unread emails">
        <q-separator />
        <q-card>
          <q-card-section>
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quidem, eius reprehenderit eos corrupti
            commodi magni quaerat ex numquam, dolorum officiis modi facere maiores architecto suscipit iste
            eveniet doloribus ullam aliquid.
          </q-card-section>
        </q-card>
      </q-expansion-item>
      <q-separator />
      <q-expansion-item icon="send" label="Outbox" caption="Empty">
        <q-separator />
        <q-card>
          <q-card-section>
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quidem, eius reprehenderit eos corrupti
            commodi magni quaerat ex numquam, dolorum officiis modi facere maiores architecto suscipit iste
            eveniet doloribus ullam aliquid.
          </q-card-section>
        </q-card>
      </q-expansion-item>
      <q-separator />
      <q-expansion-item icon="drafts" label="Draft" caption="Draft a new email">
        <q-separator />
        <q-card>
          <q-card-section>
            Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quidem, eius reprehenderit eos corrupti
            commodi magni quaerat ex numquam, dolorum officiis modi facere maiores architecto suscipit iste
            eveniet doloribus ullam aliquid.
          </q-card-section>
        </q-card>
      </q-expansion-item>
    </q-list>
  </div>
</div>  
</template>

<script>
import { ref } from 'vue';

export default {
  setup() {
      return {
        dense: ref(false) 
      }  
  },  
  data() {
    return {
      tituloMenu: 'Informação de Crédito',
      tituloCliente: 'GBS Tecnologia'
      
    };
  }
}
</script>

<style>

</style>