<template>
  <div>
    <div class="row">
      <h2 class="col text-h4">Sorteio de convidados {{ descricao_evento }}</h2>
      <q-space />
      <!-- <q-btn align="right" rounded class="botao-titulo" size="12px" color="green-7" icon="add" label="Novo" @click="Decisao"/>
        <q-btn align="right" rounded class="botao-titulo" size="12px" color="red-7" icon="close" label="Excluir" @click="AbrePop"/> 
        -->
    </div>

    <q-toolbar class="bg-white q-my-md shadow-2 toolbar ">
      <div class="botao-altera col but">
        <q-btn
          size="12px"
          rounded
          color="orange-9"
          icon="settings"
          label="Sortear"
          @click="clickRandom()"
        />
        <q-btn
          size="12px"
          rounded
          class="tet"
          color="primary"
          icon="query_stats"
          label="Sorteados"
          @click="popup_consulta_sorteado = true"
        />
        <q-space />
      </div>
      <q-select
        v-if="1 == 2"
        style="width:300px"
        v-model="evento"
        label="Evento"
        :options="dataset_lookup_evento"
        option-value="cd_evento_sorteio"
        option-label="nm_evento_sorteio"
        item-aligned
      >
        <template v-slot:prepend>
          <q-icon name="emoji_events" />
        </template>
      </q-select>

      <q-select
        style="width:300px"
        v-model="premio"
        label="Prêmio"
        :options="dataset_lookup_premio"
        option-value="cd_premio"
        option-label="nm_premio"
        item-aligned
      >
        <template v-slot:prepend>
          <q-icon name="emoji_events" />
        </template>
      </q-select>
    </q-toolbar>

    <div class="header row tit">
      <h2 class="col tit text-h4">Participantes</h2>
      <h2 class="col tit text-h4">
        Quantidade de participantes: {{ this.grid_sorteio.length }}
      </h2>
    </div>

    <div id="data-grid-demo" v-if="mostra_grid == true">
      <dx-data-grid
        id="grid_p"
        class="dx-card wide-card"
        :data-source="grid_sorteio"
        :columns="grid_sorteio.Codigo"
        :summary="total"
        key-expr="Codigo"
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
        :focused-row-index="0"
        :cacheEnable="false"
        ref="grid_p"
        :selectedrow-keys="selectedRowKeys"
        @selection-Changed="teste"
      >
        <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

        <DxGrouping :auto-expand-all="true" />

        <DxSelection :select-all-mode="allMode" mode="multiple" />
        <DxPaging :page-size="10" />

        <DxSelectBox
          id="select-all-mode"
          :data-source="['allPages', 'page']"
          :disabled="checkBoxesMode === 'none'"
          :v-model:value="allMode"
        />

        <DxStateStoring
          :enabled="true"
          type="localStorage"
          storage-key="storage"
        />

        <DxPager
          :show-page-size-selector="true"
          :allowed-page-sizes="pageSizes"
          :show-info="true"
        />
        <DxFilterRow :visible="false" />
        <DxHeaderFilter :visible="true" :allow-search="true" />
        <DxSearchPanel
          :visible="temPanel"
          :width="100"
          placeholder="Procurar..."
        />
        <DxFilterPanel :visible="true" />
        dx
        <DxSelection mode="multiple" />

        <DxColumnFixing :enabled="true" />
        <DxColumnChooser :enabled="true" mode="select" />

        <DxForm :form-data="formData" :items="items">
          <DxItem :col-count="2" :col-span="2" item-type="group" />
        </DxForm>
      </dx-data-grid>
      <!------------------------------------------------------------------->

      <!--PopUp do sorteado-->
      <q-dialog v-model="popup_sorteio" style="width: auto; ">
        <q-card class="my-card aniversariante">
          <!--<img class="img-user" v-bind:src="pegaImg()" alt="">-->
          <q-card-section>
            <h3 class="text-h3">
              <b>O sorteado é: {{ sorteado }}</b>
            </h3>
            <h4>
              <b>Participantes deste sorteio: {{ this.final.length + 1 }}</b>
            </h4>
            <h4 v-show="this.premio != []">
              <b>Prêmio: {{ premio.nm_premio }}</b>
            </h4>
          </q-card-section>
        </q-card>
      </q-dialog>
      <!--------------------------------------------------------------------->

      <!--PopUp Imagem-->
      <q-dialog v-model="popup_aguardando" full-width persistent>
        <q-card>
          <div
            style="width: 100%; text-align: center; margin-top: 1.2em margin-bottom:0;"
          >
            <h6 style="margin: 0;">{{ nm_empresa }}</h6>
          </div>
          <div style="width: 100%; text-align: center; margin: 0">
            <h2 class="text-h5">
              <q-spinner-puff color="blue" size="1.0em" />
              <b class="text-h4"> Sorteando </b>
              <q-spinner-puff color="blue" size="1.0em" />
            </h2>
          </div>

          <div style="width: 100%; text-align: center; margin-top: 0;">
            <q-knob
              disable
              :max="tempo_correr"
              :min="0"
              v-model="timer"
              show-value
              size="9.5em"
              :thickness="1.0"
              color="blue-7"
              track-color="blue-3"
              class="text-white"
            >
              {{ timer }}
            </q-knob>
          </div>
          <div style="text-align: center">
            <h4>{{ usuario_rand }}</h4>
          </div>
        </q-card>
      </q-dialog>

      <!------------------------------------------------------>
      <q-dialog v-model="popup_consulta_sorteado" full-width>
        <q-card>
          <q-card-section class="row items-center q-pb-none">
            <div class="text-h6">Vencedores</div>
            <q-space />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>
          <br />
          <q-separator />
          <br />
          <div style="margin:0px 5px 5px 15px">
            <q-btn
              size="12px"
              rounded
              color="red"
              icon="delete"
              label="Excluir"
              @click="ExcluirSorteado"
            />
          </div>
          <grid
            :cd_menuID="7218"
            :cd_apiID="518"
            :cd_parametroID="0"
            :nm_json="{}"
            ref="grid_c"
          >
          </grid>
        </q-card>
      </q-dialog>
    </div>
  </div>
</template>

<script>
import DxButton from "devextreme-vue/button";
import {
  DxDataGrid,
  DxColumn,
  DxPaging,
  DxEditing,
  DxSelection,
  DxLookup,
} from "devextreme-vue/data-grid";

import {
  DxFilterRow,
  DxPager,
  DxExport,
  DxGroupPanel,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxStateStoring,
  DxSearchPanel,
  DxPosition,
  DxMasterDetail,
} from "devextreme-vue/data-grid";

import { DxForm, DxItem } from "devextreme-vue/form";

import DxTabPanel from "devextreme-vue/tab-panel";
import { DxPopup } from "devextreme-vue/popup";
import selecaoData from "../views/selecao-periodo.vue";
import Menu from "../http/menu";
import componente from "../views/display-componente";
import "whatwg-fetch";
import DxSelectBox from "devextreme-vue/select-box";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import formataData from "../http/formataData";
import grid from "../views/grid.vue";
import Lookup from "../http/lookup";

var dados = [];
var sParametroApi = "";

export default {
  data() {
    return {
      columns: [],
      dataSourceConfig: [],
      selectedRowKeys: [],
      items: [],
      formData: {},
      refreshMode: "reshape",
      allMode: "allPages",
      checkBoxesMode: "onClick",
      temPanel: false,
      sorteado: "",
      pageSizes: [10, 20, 50, 100],
      sApis: "",
      nm_json: {},
      row: {},
      cd_empresa_sorteio: 0,
      grid_sorteio: {},
      total: {},
      participantes_d: [],
      final: [],
      popup_sorteio: false,
      popup_aguardando: false,
      timer: 5,
      intervalo: "",
      img_foto: "",
      total: {},
      imagem_usuario: "",
      nome_empresa: "",
      vb_imagem: "",
      indice: 0,
      foto: "",
      quant: 0,
      tempo_correr: 0,
      usuario_rand: "",
      tempo: 0,
      nm_empresa: "",
      nm_imagem: "",
      dt_extenso: "",
      velocidade_count: 0,
      popup_excluir_participante: false,
      nm_participante: "",
      empresa: 0,
      participante_excluido: 0,
      btn_send: "",
      popup_adicionar_participante: false,
      excluir_participante: {},
      lista_participante: [],
      pop_updecisao: false,
      pop_reativar_usuario: false,
      reativar_usuario: [],
      excluido: 0,
      consulta_sorteados: {},
      popup_consulta_sorteado: false,
      cd_convidado: 0,
      grid_p: "grid_p",
      mostra_grid: false,
      dataset_lookup_premio: [],
      dados_lookup_premio: [],
      premio: "",
      dataset_lookup_evento: [],
      dados_lookup_evento: [],
      evento: "",
      descricao_evento: "",
    };
  },
  async created() {
    this.dados_lookup_evento = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5358,
    );
    this.dataset_lookup_evento = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_lookup_evento.dataset)),
    );

    this.dados_lookup_premio = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5311,
    );
    this.dataset_lookup_premio = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_lookup_premio.dataset)),
    );

    this.nm_json = {
      cd_parametro: 2,
    };

    this.nome_empresa = localStorage.fantasia;
    this.nm_empresa = localStorage.empresa;
    this.nm_imagem = "http://www.egisnet.com.br/img/" + localStorage.cd_empresa;

    this.grid_sorteio = await Incluir.incluirRegistro("574/794", this.nm_json);
    this.quant = this.grid_sorteio.length;

    this.showMenu();
    this.carregaDados();
    this.mostra_grid = true;
    setTimeout(() => {
      this.LimpaGrids();
    }, 1000);
  },

  methods: {
    //FUNÇÃO QUE FAZ O SORTEIO

    async random() {
      this.onLimpaSorteio();
      this.indice = Math.floor(Math.random() * this.final.length);
      this.sorteado = this.final[this.indice].Nome;
      this.foto = this.grid_sorteio[this.indice].vb_imagem;
      this.cd_convidado = this.final[this.indice].Codigo;

      this.imagem_usuario = "";
      this.imagem_usuario = this.grid_sorteio[this.indice].vb_imagem;
      this.popup_aguardando = true;
      this.timer = this.tempo_correr;
      this.tempo = setInterval(this.random_vendedor, 150);
      this.intervalo = setInterval(this.AguardandoResultado, 1000);
      var j = {
        cd_parametro: 4,
        cd_evento: 1,
        cd_convidado_sorteio: this.cd_convidado,
        cd_premio: this.premio.cd_premio,
      };
      var inseriu = await Incluir.incluirRegistro("574/794", j);
      if (inseriu[0].Cod == 0) {
        notify(inseriu[0].Msg);
        return;
      } else {
        notify(inseriu[0].Msg);
      }
    },
    clickRandom() {
      if (this.participantes_d.length <= 1) {
        notify("Selecione pelo menos duas pessoas");
        return;
      }
      this.random();
      this.time();
    },

    time() {
      setTimeout(() => {
        this.lista_participante.push(this.sorteado);
      }, 5000);
      this.excluido = this.participantes_d.shift();
      setTimeout(() => {
        this.clearSelection();
      }, 6000);
    },

    random_vendedor() {
      this.indice = Math.floor(Math.random() * this.final.length);
      this.usuario_rand = this.final[this.indice].Nome;
    },
    //FUNÇÃO QUE MOSTRA O MENU-------------------

    async showMenu() {
      dados = await Menu.montarMenu(
        localStorage.cd_empresa,
        localStorage.cd_menu,
        localStorage.cd_api,
      ); //'titulo';
      sParametroApi = dados.nm_api_parametro;
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));

      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
    },

    async carregaDados() {
      let sApis = sParametroApi;
      this.dataSourceConfig = await Incluir.incluirRegistro(
        "574/794",
        this.nm_json,
      );
      this.dt_extenso =
        this.dataSourceConfig[0].dia_semana +
        " - " +
        this.dataSourceConfig[0].data_extenso;
      this.tempo_correr = 5;
      this.descricao_evento = "- " + this.dataSourceConfig[0].Evento;
      console.log(this.dataSourceConfig);
    },

    teste({ selectedRowKeys, selectedRowsData }) {
      this.participantes_d = selectedRowKeys;
      this.final = selectedRowsData;
    },

    onLimpaSorteio() {
      this.intervalo = 0;
      this.sorteado = "";
      this.timer = 0;
      this.cd_convidado = 0;
    },

    AguardandoResultado() {
      if (this.timer == 0) {
        this.popup_aguardando = false;
        this.popup_sorteio = true;
        clearInterval(this.intervalo);
        clearInterval(this.tempo);
      } else {
        this.timer = this.timer - 1;
      }
    },
    AbrePop() {
      this.popup_excluir_participante = true;
    },

    async ParticipanteSelecionado(e) {
      this.participante_excluido = e.cd_usuario;
      let api_exclusao = "560/779";

      this.nm_json = {
        cd_parametro: 1,
        cd_usuario: this.participante_excluido,
      };

      this.excluir_participante = await Incluir.incluirRegistro(
        api_exclusao,
        this.nm_json,
      );
      notify(this.excluir_participante[0].Msg);

      //recarrega menu
      this.nm_json = {
        cd_parametro: 0,
        cd_empresa: this.cd_empresa_sorteio,
      };
      this.dataSourceConfig = [];
      this.dataSourceConfig = await Incluir.incluirRegistro(
        "574/794",
        this.nm_json,
      );
      this.dt_extenso =
        this.dataSourceConfig[0].dia_semana +
        " - " +
        this.dataSourceConfig[0].data_extenso;
      this.tempo_correr = this.dataSourceConfig[0].qt_tempo;
      this.popup_excluir_participante = false;
    },
    LimpaLista() {
      this.lista_participante = [];
    },
    async Confirma_reativar(e) {
      var react = e.cd_usuario;
      this.nm_json = {
        cd_parametro: 4,
        cd_usuario_reativar: react,
      };
      var Confirma_reativar = await Incluir.incluirRegistro(
        "574/794",
        this.nm_json,
      );
      notify(Confirma_reativar[0].Msg);

      this.nm_json = {
        cd_parametro: 0,
        cd_empresa: this.cd_empresa_sorteio,
      };
      this.dataSourceConfig = [];
      this.dataSourceConfig = await Incluir.incluirRegistro(
        "523/730",
        this.nm_json,
      );
      this.dt_extenso =
        this.dataSourceConfig[0].dia_semana +
        " - " +
        this.dataSourceConfig[0].data_extenso;
      this.tempo_correr = this.dataSourceConfig[0].qt_tempo;
      this.popup_excluir_participante = false;
      this.pop_reativar_usuario = false;
      this.pop_updecisao = false;
    },

    clearSelection() {
      const datagrid = this.$refs["grid_p"].instance;
      datagrid.deselectRows(this.cd_convidado);
    },

    LimpaGrids() {
      const dataGrid = this.$refs[this.grid_p].instance;

      dataGrid.clearSelection();
    },
    async ExcluirSorteado() {
      var a = grid.Selecionada();
      var g = {
        cd_parametro: 6,
        cd_evento: a.cd_evento,
        cd_convidado_sorteio: a.cd_convidado_sorteio,
      };
      var e = await Incluir.incluirRegistro("574/794", g);
      notify(e[0].Msg);
      this.popup_consulta_sorteado = false;
    },
  },

  components: {
    DxDataGrid,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxGrouping,
    DxColumnChooser,
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxSelection,
    DxSelectBox,
    DxStateStoring,
    DxSearchPanel,
    DxTabPanel,
    componente,
    DxForm,
    DxButton,
    DxPopup,
    DxEditing,
    DxPosition,
    DxItem,
    DxMasterDetail,
    selecaoData,
    grid,
  },
};
</script>

<style>
.div-conteudo {
  width: 80vw;
  align-items: center;
}
.botao-sorteio {
  margin-left: 15%;
}
#data-grid-demo {
  min-height: 700px;
  margin: 10px;
}
.aniversariante {
  margin: 0 auto;
  padding: 0;
  background: url("https://acegif.com/wp-content/gif/confetti-17.gif") fixed
    center;
}
.sorteado {
  margin: 0 auto;
  padding: 0;
  background: url("https://i.makeagif.com/media/3-09-2017/bPSsed.gif") fixed
    center;
}
.img-user {
  max-height: 250px;
  width: 150px !important;
  margin-left: 38%;
  margin-top: 20px;
  align-items: center;
}
.botao-altera {
  margin: 0 5px 0 5px;
  max-width: 12px;
}
.titulo-lista {
  align-items: center;
  text-align: center;
}
.botao-titulo {
  margin: 2% 2% 0 0;
  height: 10%;
}
.botao-decisao {
  margin: 20px;
}
.tit {
  margin: 0;
  padding: 0;
}
.text-subtitle1 {
  margin: 2%;
}
.but {
  padding-left: 0;
  margin-left: 0;
  margin-right: 0;
  padding-right: 0;
}
.tet {
  margin-left: 5px;
}
.dir {
  text-align: right;
}
.titulo-popup {
  margin: 20px 0px 10px 10px;
}
</style>
