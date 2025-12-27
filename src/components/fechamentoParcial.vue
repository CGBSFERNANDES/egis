<template>
  <div>
    <q-expansion-item
      class="overflow-hidden "
      style="border-radius: 20px; height:auto;margin:0"
      :icon="icon"
      :label="tituloComponent"
      v-model="Expansion"
      default-opened
      header-class="bg-orange-9 text-white items-center text-h6"
      expand-icon-class="text-white "
    >
      <div class="margin1" >
        <div
          v-if="grid_produto_perda.length > 0"
          class="row justify-around text-subtitle1 margin1"
        >
          <div style="width:auto">
            <q-icon name="filter_list" color="orange-9" size="md" />
            Proposta:
            {{ grid_produto_perda[0].cd_consulta }}
          </div>

          <div style="width:auto">
            <q-icon name="person" color="orange-9" size="md" /> Cliente:
            {{ grid_produto_perda[0].nm_fantasia_cliente }}
          </div>

          <div style="width:auto">
            <q-icon name="emoji_people" color="orange-9" size="md" />
            Razão Social:
            {{ grid_produto_perda[0].nm_razao_social_cliente }}
          </div>
         
          </div>

          <div class="margin1">
          <div
            v-if="grid_produto_perda.length > 0 || grid_produto_perda.length == null"
            class="row justify-around text-subtitle1 margin1"
            style="display: flex; flex-wrap: wrap; gap: 10px;"
          >
            <div style="width: auto; display: flex; align-items: center;">
              <q-icon name="wifi_tethering" color="orange-9" size="md" />
              DDD: {{ grid_produto_perda[0].cd_ddd}}
            </div>

            <div style="width: auto; display: flex; align-items: center;">
              <q-icon name="call" color="orange-9" size="md" />
              Telefone: {{ grid_produto_perda[0].WhatsApp }}
            </div>

            <div style="width: auto; display: flex; align-items: center;">
              <q-icon name="hail" color="orange-9" size="md" />
              Vendedor Interno: {{ grid_produto_perda[0].nm_vendedor }}
            </div>

            <div style="width: auto; display: flex; align-items: center;">
              <q-icon name="directions_run" color="orange-9" size="md" />
              Vendedor Externo: {{ grid_produto_perda[0].nm_vendedor_externo }}
            </div>
          </div>
        </div>



        <q-card-section v-if="ic_perda == true">
          <q-select
            class="row margin1"
            v-model="concorrente"
            label="Concorrente"
            color="orange-9"
            :options="dataset_concorrente"
            option-value="cd_concorrente"
            option-label="nm_concorrente"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-select>

          <q-select
            class="row margin1"
            v-model="motivo_perda"
            label="Motivo ?"
            :options="dataset_motivo_perda"
            option-value="cd_motivo_perda"
            option-label="nm_motivo_perda"
            color="orange-9"
          >
            <template v-slot:prepend>
              <q-icon name="edit_note" />
            </template>
          </q-select>

          <q-input
            class="row margin1"
            v-model="ds_perda_consulta"
            type="text"
            autogrow
            label="Descritivo"
            color="orange-9"
          >
            <template v-slot:prepend>
              <q-icon name="article" />
            </template>
          </q-input>
          <div class="margin1">
            <dx-data-grid
              v-if="grid_produto_perda.length > 0"
              id="grid-padrao"
              style="border-radius: 5px"
              :data-source="grid_produto_perda"
              class="dx-card wide-card-gc"
              key-expr="cd_controle"
              :show-borders="true"
              :focused-row-enabled="true"
              :column-auto-width="true"
              :column-hiding-enabled="false"
              :remote-operations="false"
              :word-wrap-enabled="false"
              :allow-column-reordering="true"
              :allow-column-resizing="true"
              :row-alternation-enabled="true"
              :repaint-changes-only="true"
              :autoNavigateToFocusedRow="true"
              @focused-row-changed="PegaLinha"
              @cell-prepared="onCellPrepared"
            >
              <DxColumn
                v-for="(v, index) in coluna_perda"
                :key="index"
                :alignment="v.alignment"
                :caption="v.caption"
                :dataField="v.dataField"
                :dataType="v.dataType"
                :formItem="v.formItem"
                :isBand="v.isBand"
                :visible="v.visible"
              />
            </dx-data-grid>
          </div>
        </q-card-section>

        <q-card-actions class="margin1" v-if="ic_perda == true">
          <q-btn label="Enviar" rounded color="orange-9" @click="SendFail()" />
          <q-btn
            label="Perda Total"
            rounded
            class="margin1"
            color="orange-9"
            v-close-popup
            @click="AllFail()"
          />
          <transition name="slide-fade">
            <q-btn
              v-show="!!this.linha_perda.dt_perda_consulta_itens == true"
              class="margin1"
              label="Cancelar Perda"
              rounded
              flat
              color="orange-9"
              @click="CancelFail()"
            />
          </transition>

          <q-space />
          <q-btn flat label="Fechar" rounded color="orange-9" v-close-popup />
        </q-card-actions>

        <q-card-section v-if="ic_perda == false">
          <div class="text-bold">
            {{ `Deseja realmente fechar a proposta ${cd_movimento} ?` }}
          </div>
        </q-card-section>

        <q-card-actions class="margin1" v-if="ic_perda == false">
          <q-btn
            label="Enviar"
            rounded
            color="orange-9"
            v-close-popup
            @click="SendGain()"
          />
          <div class="col">
            <q-btn
              flat
              label="Cancelar"
              rounded
              color="orange-9"
              style="float: right;"
              v-close-popup
              @click="SendCancel()"
            />
          </div>
        </q-card-actions>
      </div>
    </q-expansion-item>
    <q-dialog maximized v-model="load_tela" persistent>
      <carregando
        v-if="load_tela == true"
        :corID="'orange-9'"
        :mensagemID="mensagemTela"
      ></carregando>
    </q-dialog>
  </div>
</template>

<script>
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import Lookup from "../http/lookup";
import Menu from "../http/menu";
import {
  DxDataGrid,
  DxColumn,
} from "devextreme-vue/data-grid";

export default {
  name: "fechamentoParcial",
  props: {
    ic_perda: { type: Boolean, default: true },
    colorID: { type: String, default: "orange-9" },
    cd_movimento: { type: Number, default: 0 },
  },
  emits: ["FechaPopup"],
  components: {
    DxDataGrid,
    DxColumn,
    carregando: () => import("../components/carregando.vue"),
  },
  data() {
    return {
      icon: "",
      tituloComponent: "",
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      Expansion: true,
      api: "562/781", //pr_egisnet_elabora_proposta
      dataset_concorrente: [],
      concorrente: "",
      dataset_motivo_perda: [],
      grid_produto_perda: [],
      motivo_perda: "",
      linha_perda: [],
      ds_perda_consulta: "",
      coluna_perda: [],
      consulta_item: {},
      mensagemTela: "Aguarde...",
      load_tela: false,
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    this.load_tela = true;
    if (this.ic_perda == true) {
      this.icon = "money_off";
      this.tituloComponent = "Registro de Perda";
    } else {
      this.icon = "attach_money";
      this.tituloComponent = "Registro de Ganho";
    }
    let dados_perda = await Lookup.montarSelect(localStorage.cd_empresa, 462);
    this.dataset_motivo_perda = JSON.parse(
      JSON.parse(JSON.stringify(dados_perda.dataset)),
    );
    let dados_concorrente = await Lookup.montarSelect(
      localStorage.cd_empresa,
      108,
    );
    this.dataset_concorrente = JSON.parse(
      JSON.parse(JSON.stringify(dados_concorrente.dataset)),
    );

    await this.carregaDados();
    this.load_tela = false;
  },
  watch: {
    Expansion() {
      if (this.Expansion == false) {
        this.Expansion = true;
      }
    },
  },
  methods: {
    async CancelFail() {
      //Cancela a perda de um item da grid
      let c = {
        cd_parametro: 3,
        cd_consulta: this.linha_perda.cd_consulta,
        cd_item_consulta: this.linha_perda.cd_item_consulta,
      };
      let cancelamento = await Incluir.incluirRegistro(this.api, c); //pr_egisnet_elabora_proposta
      notify(cancelamento[0].Msg);
      await this.carregaDados();
    },
    async AllFail() {
      //Cancela a Proposta inteira.
      this.grid_produto_perda.map(async (e) => {
        let p = {
          cd_parametro: 13,
          cd_consulta: this.cd_movimento,
          cd_item_consulta: e.cd_item_consulta,
          cd_motivo_perda: this.motivo_perda.cd_motivo_perda,
          cd_concorrente: this.concorrente.cd_concorrente,
          ds_perda_consulta: this.ds_perda_consulta,
          cd_usuario: this.cd_usuario,  
        };
        let envio = await Incluir.incluirRegistro(this.api, p); //pr_egisnet_elabora_proposta
        notify(envio[0].Msg);
      });
      this.$emit("FechaPopup");
    },
    async SendCancel() {
      //Caso o usuário queria cancelar a operação.
    },

    async SendGain() {
      this.mensagemTela = "Enviando o registro de ganho...";
      this.load_tela = true;
      let ganho = {
        cd_parametro: 17,
        cd_usuario: localStorage.cd_usuario,
        cd_consulta: this.cd_movimento,
      };
      let envio = [];
      try {
        envio = await Incluir.incluirRegistro(this.api, ganho);
        this.load_tela = false;
      } catch (error) {
        this.load_tela = false;
      }
      if (envio[0].Cod == 0) {
        notify(envio[0].Msg);
        return;
      }
      await this.carregaDados();
    },

    async SendFail() {
      if (this.motivo_perda == "") {
        notify("Informe o motivo da perda!");
        return;
      }
      if (this.ds_perda_consulta.length < 5) {
        notify("Digite o descritivo completo");
        return;
      }
      this.mensagemTela = "Enviando o registro de perda...";
      let perda = {
        cd_parametro: 16,
        cd_usuario: localStorage.cd_usuario,
        cd_consulta: this.cd_movimento,
        cd_motivo_perda: this.motivo_perda.cd_motivo_perda,
        cd_concorrente: this.concorrente.cd_concorrente,
        cd_item_consulta: this.linha_perda.cd_item_consulta,
        cd_produto: this.linha_perda.Cod_Produto,
        ds_perda_consulta: this.ds_perda_consulta,
      };
      let envio = [];
      if (!perda.cd_item_consulta && !perda.cd_produto) {
        notify("Selecione o item para cancelamento!");
        return;
      }
      this.load_tela = true;
      try {
        envio = await Incluir.incluirRegistro(this.api, perda);
        this.load_tela = false;
      } catch (error) {
        this.load_tela = false;
      } finally {
        this.load_tela = false;
      }
      if (envio[0].Cod == 0) {
        notify(envio[0].Msg);
        return;
      }
      this.carregaDados();

      ///this.grid_produto_perda = [];
      ///var d = await Menu.montarMenu(localStorage.cd_empresa, 0, 562); //"pr_consulta_status_etapa_modulo";
      ///this.coluna_perda = JSON.parse(JSON.parse(JSON.stringify(d.coluna)));
      ///this.grid_produto_perda = await Incluir.incluirRegistro(
      ///  "562/781",
      ///  this.consulta_item
      ///); //pr_egisnet_elabora_proposta
    },
    async onCellPrepared(e) {
      //Verifica o type de inicialização da célula.
      if (e.rowType == "header") {
        return;
      }
      //Caso seja uma célula de valor e a data de perda for preenchida a linha é pintada de vermelho.
      if (!!e.data.dt_perda_consulta_itens != false && e.rowType == "data") {
        e.cellElement.style.color = "red";
      }
    },
    async PegaLinha(e) {
      this.linha_perda = e.row.data;
    },
    async carregaDados() {
      this.mensagemTela = "Buscando informações...";
      this.load_tela = true;
      this.consulta_item = {
        cd_parametro: 6,
        cd_consulta: this.cd_movimento,
      };
      this.grid_produto_perda = [];
      var d = await Menu.montarMenu(localStorage.cd_empresa, 0, 562);
      this.coluna_perda = JSON.parse(JSON.parse(JSON.stringify(d.coluna)));
      this.grid_produto_perda = await Incluir.incluirRegistro(
        this.api,
        this.consulta_item,
      ); //pr_egisnet_elabora_proposta
      this.load_tela = false;
    },
   
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
}
.slide-fade-enter-active {
  transition: all 0.3s ease;
}
.slide-fade-leave-active {
  transition: all 0.4s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter, .slide-fade-leave-to
/* .slide-fade-leave-active below version 2.1.8 */ {
  transform: translateX(10px);
  opacity: 0;
}
</style>
