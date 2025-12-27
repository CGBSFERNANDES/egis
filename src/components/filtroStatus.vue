<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="text-subtitle2 text-center">Filtro</div>
    <q-separator />
    <div>
      <q-input v-model="buscaIndicador" label="Indicador">
        <template v-slot:append>
          <q-btn
            @click="FilterKanBan(etapa, true)"
            round
            flat
            color="orange-9"
            icon="search"
          />
          <q-btn
            @click="FilterKanBan(etapa, false)"
            round
            flat
            color="orange-9"
            icon="cleaning_services"
          />
        </template>
      </q-input>
    </div>
    <div v-show="carregaFiltro">
      <q-circular-progress
        indeterminate
        size="50px"
        color="primary"
        class="q-ma-md "
      />
    </div>

    <div v-if="filtro_status.length > 0">
      <div
        class="row justify-center"
        style="margin: 5px"
        v-for="(n, index2) in filtro_status"
        :key="index2"
      >
        <q-btn
          :flat="true"
          rounded
          :color="n.nm_cor_status"
          :label="n.nm_status"
          @click="FiltrarEtapa(n, 1)"
        />
      </div>
    </div>

    <div
      v-if="filtro_status.length == 0 && carregaFiltro == false"
      class="row justify-center"
      style="margin: 5px"
    >
      Nenhum Filtro por Status encontrado!
    </div>

    <q-dialog v-model="load" maximized persistent>
      <carregando
        :mensagemID="'Carregando...'"
        :corID="'orange-9'"
      ></carregando>
    </q-dialog>
  </div>
</template>

<script>
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Procedimento from "../http/procedimento";
import "whatwg-fetch";

export default {
  props: {
    etapa: { type: Object, default: undefined },
    pipeline_dados: { type: Array, default: undefined },
  },
  data() {
    return {
      buscaIndicador: "",
      filtro_status: [],
      carregaFiltro: false,
      load: false,
      api: 0,
      cd_api: 0,
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
  },

  async mounted() {
    if(this.etapa.cd_etapa){
      this.filtro_status = [];
      this.carregaFiltro = true;
      localStorage.cd_parametro = this.etapa.cd_etapa;
      localStorage.cd_tipo_parametro = 0;
      this.filtro_status = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        0, //cd_cliente,
        "663/961",
        "/${cd_empresa}/${cd_modulo}/${cd_parametro}/${cd_usuario}/${cd_tipo_parametro}",
      );
      this.carregaFiltro = false;
    }
  },

  components: {
    carregando: () => import("../components/carregando.vue"),
  },

  methods: {
    async FilterKanBan(e, limpar) {
      if(e){
      let itemFiltrar = this.pipeline_dados.find(item => item.cd_etapa == e.cd_etapa);
      if(!this.buscaIndicador){
        this.$emit("EtapaFiltrar", {...itemFiltrar});
        return
      }
      this.load = true;
      this.pipeline_dados.map((item) => {
        if (item.cd_etapa == e.cd_etapa) {
          item.mostraFiltro = limpar ? "N" : "S";
        }
        if (limpar) {
          if(item.cd_etapa === e.cd_etapa) {
            if (
              item.cd_movimento === parseInt(this.buscaIndicador)
            ) {
              item.mostraFiltro = "S";
              this.$emit("AchouCard", {...item, filtroGeral: false});
            } else if (
              (item.nm_destinatario ? item.nm_destinatario.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()) : false) ||
              (item.sg_modulo ? item.sg_modulo.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_contato ? item.nm_contato.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_ocorrencia ? item.nm_ocorrencia.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_responsavel ? item.nm_responsavel.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_executor ? item.nm_executor.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_atendimento ? item.nm_atendimento.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_campo1 ? item.nm_campo1.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_campo2 ? item.nm_campo2.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) 
            ){
              item.mostraFiltro = "S";
              this.$emit("AchouCard", {...item, filtroGeral: false});
            } 
            this.$emit("closePopup");
        }
      }
      });
      if (!limpar) {
        this.$emit("EtapaFiltrar", {...itemFiltrar});
      }
      this.load = false;        
    } else {
      this.pipeline_dados.map((item) => {
        item.mostraFiltro = limpar ? "N" : "S";
        if (limpar) {
            if (
              item.cd_movimento === parseInt(this.buscaIndicador)
            ) {
              item.mostraFiltro = "S";
              this.$emit("AchouCard", {...item, filtroGeral: true});
            } else if (
              (item.nm_destinatario ? item.nm_destinatario.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()) : false) ||
              (item.sg_modulo ? item.sg_modulo.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_contato ? item.nm_contato.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_ocorrencia ? item.nm_ocorrencia.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_responsavel ? item.nm_responsavel.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_executor ? item.nm_executor.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_atendimento ? item.nm_atendimento.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_campo1 ? item.nm_campo1.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) ||
              (item.nm_campo2 ? item.nm_campo2.toLocaleLowerCase().includes(this.buscaIndicador.toLocaleLowerCase()): false) 
            ){
              item.mostraFiltro = "S";
              this.$emit("AchouCard", {...item, filtroGeral: true});
            } 
            this.$emit("closePopup");
      }
      });
    }
    },

    destroyed() {
      this.$destroy();
    },
  },
};
</script>

<style scoped>
@import url("../views/views.css");
</style>
