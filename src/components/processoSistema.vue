<template>
  <div>
    <div
      class="margin1"
      style="display: flex; align-items: center; justify-content: center"
    >
      <q-btn
        rounded
        color="orange-9"
        text-color="white"
        size="lg"
        label="Processos"
      />
    </div>
    <div class="text-h5 text-bold margin1">
      {{ tituloForm }}
      <q-badge v-if="prop_form.cd_movimento" align="top" color="blue">
        {{ prop_form.cd_movimento }}
      </q-badge>
    </div>

    <!-- Selects do Processo_Sistema -->
    <div class="row">
      <q-select
        dense
        use-input
        hide-selected
        fill-input
        class="metadeTela margin1"
        label="Processos"
        v-model="processos"
        input-debounce="0"
        :options="dados_lookup_processos"
        option-value="cd_processo"
        option-label="nm_processo"
        @input="onProcessos()"
      >
        <template v-slot:prepend>
          <q-icon name="account_tree" />
        </template>
      </q-select>
      <q-select
        v-if="processos.cd_processo"
        dense
        use-input
        hide-selected
        fill-input
        class="metadeTela margin1"
        label="Composição dos Processos"
        v-model="processos_composicao"
        input-debounce="0"
        :loading="load_composicao"
        :options="dados_lookup_processos_composicao"
        option-value="cd_processo"
        option-label="nm_processo_composicao"
        @input="onComposicao()"
      >
        <template v-slot:prepend>
          <q-icon name="engineering" />
        </template>
      </q-select>
    </div>
    <div>
      <q-btn
        rounded
        label="Executar"
        type="submit"
        color="orange-9"
        icon="work"
        @click="onSalvarRegistro"
      />
      <q-btn
        rounded
        label="Limpar"
        type="reset"
        color="orange-9"
        flat
        class="q-ml-sm"
        icon="cleaning_services"
        @click="onLimparRegistro"
      />
      <q-btn
        rounded
        label="Fechar"
        type="reset"
        color="orange-9"
        flat
        class="q-ml-sm"
        icon="close"
        @click="onFechar"
      />
    </div>
    <div v-if="pop_formEspecial">
      <formEspecial
            @click="saveParams($event)"
            :cd_formID="this.processos_composicao.cd_form"
            :cd_documentoID="0"
            :cd_relatorioID="0"
            :cd_item_documentoID="0"
          />
    </div>
    <!--------CARREGANDO---------------------------------------------------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando mensagemID="carregando..."></carregando>
    </q-dialog>
    <!------------------------------------------------------------------------------------>
  </div>
</template>

<script>

import "devextreme-vue/text-area";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import formataData from "../http/formataData";
import carregando from "./carregando.vue";
import Menu from "../http/menu";
import Lookup from "../http/lookup";
import select from "../http/select";
import formEspecial from "../views/cadastroFormEspecial";

export default {
  props: {
    cd_formID: { type: Number, default: 0 },
    cd_documentoID: { type: Number, default: 0 },
    cd_item_documentoID: { type: Number, default: 0 },
    prop_form: {
      type: Object,
      default() {
        return {};
      },
    },
  },
  components: {
    carregando,
    formEspecial,
  },
  name: "processoSistema",
  data() {
    return {
      tituloForm: "",
      cd_modulo: localStorage.cd_modulo,
      dados: [],
      dataSourceConfig: [],
      tabsheets: [],
      dados_lookup_processos: [],
      processos: "",
      dados_lookup_processos_composicao: [],
      processos_composicao: "",
      load_composicao: false,
      index: 0,
      load: false,
      pop_formEspecial: false,
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
  },

  async mounted() {
    try {
      this.load = true;
      let dados_lookup_processos_sistema = await Lookup.montarSelect(
        "0", //this.cd_empresa,
        1758,
      );
      this.dados_lookup_processos = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_processos_sistema.dataset)),
      );
      this.dados_lookup_processos = this.dados_lookup_processos.filter(
        (processo) => {
          return processo.ic_atividade_processo === "S";
        },
      );

      let processos_json = {
        cd_empresa: "0",
        cd_tabela: 5538,
        order: "D",
        where: [{ cd_modulo: this.cd_modulo }],
      };

      let [processo_modulo] = await select.montarSelect(
        "0", //this.cd_empresa,
        processos_json,
      );

      this.dados_lookup_processos = this.dados_lookup_processos.filter(
        (proc) => {
          if (
            JSON.parse(processo_modulo.dataset).some(
              (element) => element.cd_processo == proc.cd_processo,
            )
          ) {
            return proc;
          }
        },
      );
      ////////////////////////////////////////////////////////////////////////////
      //await this.carregaDados();
      this.load = false;
    } catch (error) {
      this.load = false;
    }
  },

  methods: {
    async carregaDados() {
      localStorage.cd_menu = 0;
      localStorage.cd_api = 585;
      localStorage.api = "585/811";
      ///////////////////////////////////////////////////////
      await Menu.montarMenu(
        localStorage.cd_empresa,
        localStorage.cd_menu,
        localStorage.cd_api,
      );
      localStorage.cd_parametro = this.cd_formID;
      localStorage.cd_documento = this.prop_form.cd_documento;
      localStorage.cd_item_documento = this.prop_form.cd_item_documento;
      let carregaDataSouce = {
        cd_empresa: localStorage.cd_empresa,
        cd_parametro: this.cd_formID,
        cd_documento: this.prop_form.cd_documento,
        cd_item_documento: this.prop_form.cd_item_documento,
        cd_cliente: this.prop_form.nm_campo2,
      };
      this.dataSourceConfig = await Incluir.incluirRegistro(
        localStorage.api,
        carregaDataSouce,
        "admin",
      ); //pr_formulario_atributo (ADMIN)
      this.dataSourceConfig = this.dataSourceConfig.filter((item) => {
        return item.ic_habilitado_atributo === "S";
      });
      this.tituloForm = this.dataSourceConfig[0].nm_titulo_form;
      ///////////////////////////////////////////////////////
      const tabsheetsItems = this.dataSourceConfig.reduce((acc, item) => {
        if (!acc[item.cd_tabsheet]) {
          acc[item.cd_tabsheet] = [];
        }
        acc[item.cd_tabsheet].nm_tabsheet = item.nm_tabsheet;
        acc[item.cd_tabsheet].ic_icone = item.ic_icone;
        acc[item.cd_tabsheet].nm_icone_tabsheet = item.nm_icone_tabsheet;
        acc[item.cd_tabsheet].push(item);
        return acc;
      }, {});
      this.tabsheets = Object.entries(tabsheetsItems).map(
        ([cd_tabsheet, itens]) => {
          return {
            cd_tabsheet,
            itens,
            nm_tabsheet: itens.nm_tabsheet,
            ic_icone: itens.ic_icone,
            nm_icone_tabsheet: itens.nm_icone_tabsheet,
          };
        },
      );
      this.index = this.tabsheets[0].cd_tabsheet;
    },

    async onSalvarRegistro() {
      if (this.processos.cd_processo) {
        let json_salvar_processo = {
          cd_empresa: localStorage.cd_empresa,
          cd_modulo: localStorage.cd_modulo,
          cd_menu: localStorage.cd_menu,
          cd_processo: this.processos.cd_processo,
          cd_item_processo: this.processos_composicao.cd_item_processo,
          cd_documento_form: 0,
          cd_item_documento_form: 0,
          cd_parametro: 0, //this.prop_form.cd_documento ? "2" : "1", //2 - Update | 1 - Insert
          cd_usuario: localStorage.cd_usuario,
          dt_usuario: formataData.AnoMesDia(new Date()),
        };
        try {
          let [result] = await Incluir.incluirRegistro(
            "921/1431",
            json_salvar_processo,
          ); //pr_api_geracao_processo_sistema
          
          //Exibir os Dados do Retorno da API se houver dados
          //02.10.2025

          


          //Fechar o Formulário
          this.onFechar();
          //

          if (result.Msg !== "") {
            notify(result.Msg);
          } else {
            notify("Processo salvo com sucesso");
          }
        } catch (error) {
          this.onFechar();
          notify("Não foi possivel salvar o processo");
        }
      } else {
        notify("Selecione um processo para executar");
      }
      return;
    },
    onLimparRegistro() {
      this.processos_composicao = "";
      this.processos = "";
    },
    onFechar() {
      this.onLimparRegistro();
      this.$emit("click");
    },
    async onExcluir() {
      let json_excluir_registro = {
        cd_empresa: localStorage.cd_empresa,
        cd_modulo: localStorage.cd_modulo,
        cd_menu: localStorage.cd_menu,
        cd_form: this.tabsheets[0].itens[0].cd_form,
        cd_documento_form: this.prop_form.cd_documento,
        cd_item_documento_form: this.prop_form.cd_item_documento,
        cd_parametro_form: "3", //2 - Update | 1 - Insert
        cd_usuario: localStorage.cd_usuario,
        dt_usuario: formataData.AnoMesDia(new Date()),
        detalhe: [],
        lote: [],
      };
      try {
        await Incluir.incluirRegistro(
          "920/1430",
          json_excluir_registro,
        ); //pr_api_dados_form_especial
        notify("Registro excluído com sucesso");
      } catch (error) {
        notify("Não foi possivel excluir o registro");
      }
    },
    async onProcessos() {
      try {
      this.load_composicao = true;
      let processos_json = {
        cd_empresa: "0",
        cd_tabela: 5721,
        order: "D",
        where: [{ cd_processo: this.processos.cd_processo }],
      };
      let [result_processos] = await select.montarSelect(
        "0", //this.cd_empresa,
        processos_json,
      );
      this.dados_lookup_processos_composicao = JSON.parse(
        JSON.parse(JSON.stringify(result_processos.dataset)),
      );         
    } catch (error) {
        console.error(error)
      } finally {
        this.load_composicao = false;
      }
    },
    onComposicao(){
      if(this.processos_composicao.cd_form){
        this.pop_formEspecial = true;
      }
    },
  },
};
</script>

<style scoped>
@import url("../views/views.css");
</style>
