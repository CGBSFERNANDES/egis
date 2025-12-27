<template>
  <div style="padding:10px">
    <!---CARREGANDO----------------------------------->
    <transition name="slide-fade">
      <q-spinner
        class="margin1"
        v-if="dataSourceConfig.length <= 0"
        color="primary"
        size="5em"
      />
    </transition>
    <!---CARREGANDO----------------------------------->
    <transition name="slide-fade">
      <q-timeline
        class="margin1"
        color="secondary"
        v-if="dataSourceConfig.length > 0"
      >
        <!--<q-timeline-entry heading v-if="dataSourceConfig[0].nm_heading != ''">
        {{ dataSourceConfig[0].nm_heading }}
      </q-timeline-entry>-->
        <div class="text-h6 margin1 text-bold">
          {{ dataSourceConfig[0].nm_heading }}
        </div>

        <q-input
          dense
          class="margin1 row"
          v-show="inputID == true"
          v-model="ds_historico"
          autogrow
          :color="corID"
          label="Nova anotação"
        >
          <template v-slot:prepend>
            <q-icon name="add" />
          </template>
          <template v-slot:append>
            <q-btn
              round
              flat
              :color="corID"
              icon="check"
              :loading="ic_salva_anotacao"
              @click="EnviaDescritivo()"
            />
          </template>
        </q-input>

        <div v-if="dataSourceConfig.length > 0">
          <q-timeline-entry
            class="time"
            v-for="(n, index) in dataSourceConfig"
            v-bind:key="index"
            v-show="!!n.dt_base"
            :subtitle="n.dt_base + ' | ' + n.nm_acao"
            :color="n.color"
            :icon="n.icon"
          >
            <div
              style="font-weight: normal; text-decoration: black;"
              v-if="!!n.nm_acontecimento"
            >
              {{ n.nm_acontecimento }}
            </div>
            <q-separator />
          </q-timeline-entry>
        </div>
      </q-timeline>
    </transition>
    <div
      v-if="dataSourceConfig.length > 0 && dataSourceConfig[0].Cod == 0"
      class="text-center"
    >
      {{ dataSourceConfig[0].Msg }}
    </div>
  </div>
</template>

<script>
import Procedimento from "../http/procedimento";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
export default {
  props: {
    cd_apiID: { type: String, default: "" }, //api para consulta
    cd_consulta: { type: Number, default: 0 }, //define qual o tipo de get/post
    cd_parametroID: { type: Number, default: 0 }, //Parametro usado para o MontarProcedimento
    cd_tipo_consultaID: { type: Number, default: 0 }, //Parametro usado para o MontarProcedimento
    nm_json: {
      type: Object,
      default: () => {
        return {};
      },
    }, //Json para uso geral (Get na Api ou passagem de dados do componente pai)
    inputID: { type: Boolean, default: false }, //campo de input
    cd_apiInput: { type: String, default: "" }, //api input
    corID: { type: String, default: "orange-9" },
  },

  components: {
  },

  data() {
    return {
      cd_empresa: 0,
      cd_cliente: 0,
      cd_api: 0,
      dataSourceConfig: [],
      cd_cliente_recebido: 0,
      cd_organizacao_recebido: 0,
      ds_historico: "",
      ic_salva_anotacao: false,
      cd_usuario: localStorage.cd_usuario,
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
  },
  async mounted() {
    await this.carregaDados();
  },
  methods: {
    async PesquisaDestino() {
      this.nm_json.cd_movimento = this.cd_parametroID;
      const d = await Incluir.incluirRegistro(this.cd_apiInput, this.nm_json);
      this.cd_cliente_recebido = d[0].cd_cliente;
      this.cd_organizacao_recebido = d[0].cd_organizacao;
    },
    async EnviaDescritivo() {
      try {
      this.ic_salva_anotacao = true;
      await this.PesquisaDestino();
      const i = {
        cd_parametro: 1,
        cd_organizacao: this.cd_organizacao_recebido,
        cd_cliente: this.cd_cliente_recebido,
        ds_historico: this.ds_historico,
        cd_usuario: this.cd_usuario,
      };
      const envio = await Incluir.incluirRegistro(this.cd_apiInput, i);
      if (envio[0].Cod == 0) {
        notify(envio[0].Msg);
        return;
      }
      
      this.ds_historico = "";
      await this.carregaDados();
      this.ic_salva_anotacao = false;     
    } catch (error) {
        console.error(error)
      } finally {
        this.ic_salva_anotacao = false;
      }
    },

    async carregaDados() {
      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      if (this.cd_consulta == 1) {
        localStorage.cd_parametro = this.cd_parametroID;
        localStorage.cd_tipo_consulta = this.cd_tipo_consultaID;
        const parametro = "/${cd_empresa}/${cd_parametro}/${cd_tipo_consulta}";

        this.dataSourceConfig = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          this.cd_apiID,
          parametro,
        );
      } else if (this.cd_consulta == 2) {
        if (this.cd_apiID == "") {
          return;
        } else if (this.nm_json == {}) {
          return;
        }
        this.dataSourceConfig = await Incluir.incluirRegistro(
          this.cd_apiID,
          this.nm_json,
        );
        if (this.dataSourceConfig[0].Cod == 0) {
          notify(this.dataSourceConfig[0].Msg);
        }
      }
    },
  },
};
</script>

<style scoped>
@import url("./views.css");
</style>
