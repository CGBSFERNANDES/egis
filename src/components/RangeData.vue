<template>
  <div>
    <div>
      <div
        class="text-weight-medium dt-storage"
        @click="popupData = true"
        v-if="data_tela_inicial != '' && data_tela_final != ''"
      >
        <q-badge color="orange-9" rounded>
          {{ data_tela_inicial }}
        </q-badge>
        até
        <q-badge color="orange-9" rounded>
          {{ data_tela_final }}
        </q-badge>
      </div>
      <div class="text-weight-medium " @click="popupData = true" v-else>
        <q-badge color="orange-9" rounded>
          Selecione a Data
        </q-badge>
      </div>
    </div>
    <q-dialog v-model="popupData">
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Seleção de Data</div>
          <q-space />
          <q-btn
            icon="close"
            @click="selecaoPeriodoData()"
            flat
            round
            dense
            v-close-popup
          />
        </q-card-section>
        <selecaoData @click="fechaPopup()" :cd_volta_home="1"></selecaoData>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
export default {
  components: {
    selecaoData: () => import("../views/selecao-periodo"),
  },
  data() {
    return {
      popupData: false,
      data_tela_inicial: new Date(localStorage.dt_inicial).toLocaleDateString(),
      data_tela_final: new Date(localStorage.dt_final).toLocaleDateString(),
    };
  },
  methods: {
    fechaPopup() {
      this.popupData = false;
      setTimeout(() => {
        this.$emit("trocouData");
        this.data_tela_inicial = new Date(
          localStorage.dt_inicial
        ).toLocaleDateString();
        this.data_tela_final = new Date(
          localStorage.dt_final
        ).toLocaleDateString();
      }, 500);
    },
    selecaoPeriodoData() {
      if (this.popupData == true) {
        this.popupData = false;
      } else if (this.popupData == false) {
        this.popupData = true;
      }
    },
  },
};
</script>

<style scoped></style>
