<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <info
      v-if="this.cd_rota == 137"
      :prop_form="this.xprop_form"
      @click="fechaPopup()"
    />
    <crudpadrao
      @click="fechaPopup()"
      v-if="this.cd_rota == 7"
      :cd_menuID="this.cd_menu"
      :cd_apiID="this.cd_api"
    />
    <!-- display-datav2 -->
    <displayV2
      @click="fechaPopup()"
      v-if="false"
      :cd_menuID="this.cd_menu"
      :cd_apiID="this.cd_api"
    />
    <e-proposta
      @click="fechaPopup()"
      v-if="this.cd_rota == 14"
      :kanban="true"
      :consulta_up="prop_form"
    />
    <cliente
      @click="fechaPopup()"
      v-if="this.cd_rota == 48 && this.cd_form == 0"
    />
    <contrato
      @click="fechaPopup()"
      v-if="this.cd_rota == 51 && this.cd_form == 0"
      :prop_form="this.xprop_form"
    />
    <oportunidade
      @click="fechaPopup()"
      v-if="this.cd_rota == 82"
      :oportunidade_up="this.xprop_form"
    />
    <proposta
      @click="fechaPopup()"
      v-if="this.cd_rota == 83"
      :cd_consultaID="this.xprop_form"
    />
    <mapagoogle @click="fechaPopup()" v-if="this.cd_rota == 85" />
    <listagem
      @click="fechaPopup()"
      v-if="this.cd_rota == 93"
      :prop_listagem="this.xprop_form"
    />
    <campanha
      @click="fechaPopup()"
      v-if="this.cd_rota == 103"
      :info="this.xprop_form"
    />
    <ficha-venda
      @click="fechaPopup()"
      v-if="this.cd_rota == 107"
      :prop_form="this.xprop_form"
    />
    <pedidoVenda
      @click="fechaPopup()"
      v-if="this.cd_rota == 115"
      :propPedido="this.xprop_form"
    />
    <fechamento
      @click="fechaPopup()"
      v-if="this.cd_rota == 121"
      :cd_movimento="this.cd_documentoID"
    />
    <infoAdm
      v-if="this.cd_rota == 122"
      :cd_movimento="this.cd_documentoID"
      @click="fechaPopup()"
    />
    <aprovaUsuario
      @click="fechaPopup()"
      v-if="this.cd_rota == 125"
      :kanban="true"
      :propObject="prop_form"
    />

    <atividadeModulo
      v-if="this.cd_rota == 126"
      :cd_consultaID="this.cd_documentoID"
      @click="fechaPopup()"
    />

    <produto v-if="this.cd_rota == 129" @click="fechaPopup()" />

    <negociacaoProposta
      v-if="this.cd_rota == 131"
      :cd_consultaID="this.cd_documentoID"
      :cd_menuID="7506"
      :cd_apiID="776"
    />

    <documentosCRUD
      v-if="this.cd_rota == 159"
      :cd_documentoID="this.cd_documentoID"
    />

    <digitacao-proposta-cliente
      v-if="this.cd_rota == 178"
      @click="fechaPopup()"
    />

    <pedidoVendaFabrica v-if="this.cd_rota == 145" @click="fechaPopup()" />

    <HTMLDinamico
      v-if="this.cd_rota == 171"
      :nm_caminho_pagina="this.xprop_form.nm_caminho_pagina"
      :nm_endereco_pagina="this.xprop_form.nm_endereco_pagina"
      @click="fechaPopup()"
    />

    <UnicoFormEspecial
      v-if="this.cd_rota == 187 && this.cd_form == 0"
      @click="fechaPopup()"
    />

    <modal-composicao
      v-if="this.cd_modal > 0 && this.ic_grid_modal !== 'S'"
      v-model="dialogModalComposicao"
      :cd-modal="this.cd_modal"
      @sucesso="fechaPopup()"
    />

    <modal-grid-composicao
      v-if="this.cd_modal > 0 && this.ic_grid_modal === 'S'"
      v-model="dialogModalGridComposicao"
      :cd-modal="this.cd_modal"
      @sucesso="fechaPopup()"
    />

    <div
      v-if="
        this.cd_documento > 0 &&
          this.cd_form == 0 &&
          this.cd_rota == 0 &&
          this.cd_menu !== 7303
      "
    >
      <!--<div class="row" style="float:right; display:block; width:100vw">
        <q-btn
          round
          style="float:right;display:block"
          color="orange-9"
          icon="event"
          @click="popData = true"
        />
      </div>-->

      <div class="row" style="display: block" v-if="mostra_grid">
        <grid
          v-if="
            this.cd_documento > 0 &&
              this.cd_form == 0 &&
              this.cd_rota == 0 &&
              this.cd_menu !== 7303
          "
          :cd_menuID="this.cd_menu"
          :cd_apiID="this.cd_api"
          :cd_identificacaoID="0"
          :cd_parametroID="this.cd_parametro"
          :cd_tipo_consultaID="this.cd_tipo_consultaID"
          :cd_usuarioID="0"
          :cd_consulta="0"
          :nm_json="this.nm_jsonp"
          @dadosgrid="onDataSource($event)"
          ref="grid_c"
        >
        </grid>
      </div>
    </div>

    <!-- 
          kelvin, continuar aqui o desenvolvimento de gravar e gerar qualquer
          crud e form aqui conforme a pr do ccf ( que já está pronta)
         -->
    <formEspecial
      v-if="cd_form !== 0"
      @click="fechaPopup($event)"
      :cd_formID="this.cd_form"
      :cd_documentoID="this.cd_documento"
      :cd_item_documentoID="this.cd_item_documento"
      :prop_form="this.xprop_form"
    />

    <q-dialog v-model="popData" persistent>
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Seleção de Data</div>
          <q-space />
          <q-btn
            icon="close"
            @click="CarregaGrids()"
            flat
            round
            dense
            v-close-popup
          />
        </q-card-section>
        <date
          v-if="
            this.cd_menu == 6981 ||
              cd_menu == 6986 ||
              cd_menu == 6993 ||
              cd_menu == 6994 ||
              cd_menu == 7108 ||
              cd_menu == 7112 ||
              cd_menu == 7116
          "
          style="margin: 0.7vw 1vw"
        />
      </q-card>
    </q-dialog>
  </div>
</template>
<script>
import oportunidade from "../views/oportunidade";
import mapagoogle from "../views/roteiroEntrega";
import contrato from "../views/cadastro-contrato-consorcio";
import proposta from "../views/intermedium-proposta";
import eProposta from "../views/egis-proposta.vue";
import cliente from "../views/cliente";
import crudpadrao from "../views/display-data5";
import displayV2 from "../views/display-datav2";
import grid from "../views/grid";
import listagem from "../views/listagem-contrato";
import campanha from "../views/campanha.vue";
import date from "../components/pesquisa-data.vue";
import FichaVenda from "../views/contratoFichaVenda.vue";
import ModalComposicao from "@/components/ModalComposicao.vue";
import ModalGridComposicao from "@/components/ModalGridComposicao.vue";

export default {
  props: {
    cd_parametroID: { type: Number, default: 0 },
    cd_rotaID: { type: Number, default: 0 },
    cd_formID: { type: Number, default: 0 },
    cd_apiID: { type: Number, default: 0 },
    cd_menuID: { type: Number, default: 0 },
    cd_documentoID: { type: Number, default: 0 },
    cd_item_documentoID: { type: Number, default: 0 },
    cd_tipo_consultaID: { type: Number, default: 0 },
    prop_form: {
      type: Object,
      default() {
        return {};
      },
    },
    cd_modalID: { type: Number, default: 0 },

    // titulo_menu    : { type: String, default: ''}
  },
  components: {
    //componente,
    contrato,
    FichaVenda,
    oportunidade,
    mapagoogle,
    proposta,
    eProposta,
    //Oportunidade,
    cliente,
    date,
    crudpadrao,
    displayV2,
    grid,
    listagem,
    infoAdm: () => import("../components/infoAdm.vue"),
    formEspecial: () => import("../views/cadastroFormEspecial"),
    campanha,
    pedidoVenda: () => import("../views/pedido-venda.vue"),
    fechamento: () => import("../components/fechamentoParcial.vue"),
    documentosCRUD: () => import("../components/documentosCRUD.vue"),
    UnicoFormEspecial: () => import("./unicoFormEspecialBackup.vue"),
    ModalComposicao,
    ModalGridComposicao,
    aprovaUsuario: () => import("../views/aprovaUsuario.vue"),
    produto: () => import("../views/produto.vue"),
    atividadeModulo: () => import("../views/atividadeModulo.vue"),
    negociacaoProposta: () => import("./negociacaoProposta.vue"),
    info: () => import("../views/info"),
    PedidoVendaFabrica: () => import("../views/pedido-venda-fabrica.vue"),
    HTMLDinamico: () => import("../views/HTMLDinamico.vue"),
  },
  name: "autoform",
  title: "",
  data() {
    return {
      cd_parametro: 0,
      cd_rota: 0,
      cd_form: 0,
      hoje: "",
      maximizedToggle: true,
      cd_api: 0,
      cd_menu: 0,
      cd_documento: 0,
      cd_item_documento: 0,
      nm_jsonp: {},
      xprop_form: {},
      mostra_grid: false,
      popData: false,
      dialogModalComposicao: false,
      dialogModalGridComposicao: false,
      ic_grid_modal: "N",
    };
  },
  methods: {
    abrirModalComposicao() {
      this.dialogModalComposicao = false;
      this.dialogModalGridComposicao = false;
      if (this.ic_grid_modal === "S") {
        this.dialogModalGridComposicao = true;
        return;
      }
      this.dialogModalComposicao = true;
    },
    async CarregaGrids() {
      this.mostra_grid = false;
      await this.sleep(1000);
      this.mostra_grid = true;
    },

    fechaPopup(evt) {
      this.$emit("click", evt);
    },

    sleep(ms) {
      return new Promise(resolve => setTimeout(resolve, ms));
    },

    onDataSource(e) {
      this.$emit("dadosgrid", e);
    },
  },

  async created() {
    this.hoje = new Date().toLocaleDateString();
    this.cd_parametro = this.cd_parametroID;
    this.cd_rota = this.cd_rotaID;
    this.cd_form = this.cd_formID;
    this.cd_modal = this.cd_modalID;
    this.cd_api = this.cd_apiID;
    this.cd_menu = this.cd_menuID;
    this.cd_documento = this.cd_documentoID;
    this.cd_item_documento = this.cd_item_documentoID;
    localStorage.cd_tipo_consulta = this.cd_tipo_consultaID;
    this.mostra_grid = true;
    if (this.prop_form != {}) {
      this.xprop_form = this.prop_form;
    }
    this.ic_grid_modal = this.xprop_form.ic_grid_modal || "N";
    if (this.cd_modal > 0) {
      this.abrirModalComposicao();
    }
    if (this.cd_form > 0) {
      //localStorage.cd_menu = 0;
      localStorage.cd_api = 585;
      localStorage.api = "585/811";
      localStorage.cd_parametro = this.cd_form;

      this.$store.dispatch("getDados");
    }
  },
  mounted() {
    this.cd_parametro = this.cd_parametroID;
    this.cd_rota = this.cd_rotaID;
    this.cd_form = this.cd_formID;
    this.cd_api = this.cd_apiID;
    this.cd_menu = this.cd_menuID;
    this.cd_documento = this.cd_documentoID;
    this.cd_item_documento = this.cd_item_documentoID;
    this.cd_modal = this.cd_modalID;
    this.ic_grid_modal = this.xprop_form.ic_grid_modal || "N";
    if (this.cd_modal > 0) {
      this.abrirModalComposicao();
    }

    if (this.cd_form > 0) {
      localStorage.cd_parametro = this.cd_form;
    }

    localStorage.cd_documento = this.cd_documento;
    localStorage.cd_item_documento = this.cd_item_documento;
    localStorage.cd_form = this.cd_form;

    if (localStorage.cd_item_documento == undefined) {
      localStorage.cd_item_documento = 0;
    }
  },
};
</script>
<style scoped>
.first-group,
.second-group {
  padding: 20px;
}

.second-group {
  background-color: rgba(191, 191, 191, 0.15);
}

.form-avatar {
  height: 128px;
  width: 128px;
  margin-right: 10px;
  border: 1px solid #d2d3d5;
  border-radius: 50%;
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
}
</style>
