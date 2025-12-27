<template>
  <div>
    <div>
      <h2 class="text-h4">Sorteio de palestrantes {{ this.nome_empresa }}</h2>
    </div>
    <div style="margin:1% 2%" align="right">
      <q-btn
        style="margin:0px 5px;"
        rounded
        size="12px"
        color="green-7"
        icon="add"
        label="Novo"
        @click="Decisao"
      />
      <q-btn
        style="margin:0px 5px;"
        rounded
        size="12px"
        color="red-7"
        icon="close"
        label="Excluir"
        @click="AbrePop"
      />
      <q-btn
        style="margin:0px 5px;"
        rounded
        size="12px"
        color="primary"
        icon="restart_alt"
        label="Limpar"
        @click="LimpaLista"
      />
    </div>
    <q-toolbar class="bg-white q-my-md shadow-2 toolbar row ">
      <div class="col">
        <q-btn
          size="12px"
          rounded
          color="orange-9"
          icon="settings"
          label="Sortear"
          @click="clickRandom()"
        />
      </div>

      <div class="col ">
        <b class="text-subtitle2"> 1° {{ lista_participante[0] }}</b>
      </div>

      <div class="col">
        <b class="text-subtitle2">2° {{ lista_participante[1] }}</b>
      </div>

      <div class="col">
        <b class="text-subtitle2">3° {{ lista_participante[2] }}</b>
      </div>
      <q-space />
    </q-toolbar>

    <div class="margin1 header row tit">
      <h2 class="col tit text-h4 ">Lista de participantes</h2>
      <h2 class="col tit text-h4">
        Participantes: {{ this.dataSourceConfig.length }}
      </h2>
    </div>

    <div id="data-grid-demo">
      <dx-data-grid
        class="dx-card wide-card"
        :data-source="dataSourceConfig"
        :columns="columns"
        :summary="total"
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
          </q-card-section>
        </q-card>
      </q-dialog>
      <!--------------------------------------------------------------------->

      <!--PopUp Imagem-->
      <q-dialog v-model="popup_aguardando" full-height full-width persistent>
        <q-card>
          <div
            style="width: 100%; text-align: center; margin-top: 1.2em margin-bottom:0;"
          >
            <img
              :src="nm_imagem"
              id="img-logo-sorteio"
              style="margin: 15px 0px; max-width: 200px; max-height:200px;"
            />
            <h6 style="margin: 0;">
              {{ nm_empresa }} <br />
              {{ dt_extenso }}
            </h6>
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

      <!--Excluir Participante---------------------------------------------------------------->
      <q-dialog v-model="popup_excluir_participante" style="max-heigth:90vw;">
        <q-card>
          <q-card-section
            class="row items-center q-pb-none"
            style="margin-bottom:5px;"
          >
            <div class="text-h6">Participantes</div>
            <q-space />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>

          <q-separator />
          <q-item
            v-for="dataSourceConfig in dataSourceConfig"
            :key="dataSourceConfig.cd_controle"
            clickable
            v-ripple
          >
            <q-item-section>
              <q-item-label class="text-h6">{{
                dataSourceConfig.nm_usuario
              }}</q-item-label>
              <q-item-label caption lines="1">{{
                dataSourceConfig.nm_fantasia_empresa
              }}</q-item-label>
            </q-item-section>

            <q-item-section side>
              <q-btn
                round
                v-model="btn_send"
                icon="close"
                color="deep-orange-6"
                @click="ParticipanteSelecionado(dataSourceConfig)"
                clickable
              />
            </q-item-section>
          </q-item>
          <q-card-actions align="right">
            <separator />
            <q-btn flat label="fechar" color="primary" v-close-popup />
          </q-card-actions>
        </q-card>
      </q-dialog>

      <!--Adicionar participantes------------------------------------------------->
      <q-dialog v-model="popup_adicionar_participante" style="width: 60vw;">
        <q-card style="width: 60vw;">
          <q-card-section
            class="row items-center q-pb-none"
            style="margin-bottom:10px;"
          >
            <div class="text-h6">Novo Participante</div>
            <q-space />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>

          <q-separator />

          <q-input
            item-aligned
            v-model="novo_nm_usuario"
            type="text"
            label="Nome Completo"
          >
            <template v-slot:prepend>
              <q-icon name="corporate_fare" />
            </template>
          </q-input>

          <q-input
            item-aligned
            v-model="novo_nm_fantasia"
            type="text"
            label="Nome Fantasia"
          >
            <template v-slot:prepend>
              <q-icon name="corporate_fare" />
            </template>
          </q-input>

          <q-input
            item-aligned
            v-model="novo_email"
            type="email"
            label="E-Mail"
          >
            <template v-slot:prepend>
              <q-icon name="mail" />
            </template>
          </q-input>

          <q-card-actions align="right">
            <q-btn
              rounded
              color="primary"
              label="Salvar"
              @click="InsertUsuario"
            />
            <q-btn rounded color="red" label="Cancelar" v-close-popup />
          </q-card-actions>
        </q-card>
      </q-dialog>
      <!---------------------------------------------->
      <q-dialog v-model="pop_updecisao" style="width: 60vw;">
        <q-card style="width: 60vw; margin: 5px;">
          <q-card-section
            class="row items-center q-pb-none"
            style="margin-bottom:10px;"
          >
            <div class="text-h6">Cadastrar ou reativar?</div>
            <q-space />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>
          <q-separator />
          <div class="row">
            <q-btn
              rounded
              class="botao-decisao col"
              item-align
              align="center"
              color="primary"
              icon="add"
              label="Novo"
              @click="NovoParticipante"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                <strong>Novo Cadastro</strong>
              </q-tooltip>
            </q-btn>

            <q-btn
              rounded
              class="botao-decisao col"
              item-align
              align="center"
              color="primary"
              icon="refresh"
              label="Reativar"
              @click="ReativarUsuario"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                <strong>Reativar usuário já existente</strong>
              </q-tooltip>
            </q-btn>
            <q-space />
          </div>
        </q-card>
      </q-dialog>
      <!------------------------------------------------------>
      <q-dialog v-model="pop_reativar_usuario" style="width: 60vw;">
        <q-card style="width: 60vw;">
          <q-card-section
            class="row items-center q-pb-none"
            style="margin-bottom:10px;"
          >
            <div class="text-h6">Selecione o usuário</div>
            <q-space />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>

          <q-separator />
          <q-item
            v-for="reativar_usuario in reativar_usuario"
            :key="reativar_usuario.cd_usuario"
            class="q-my-sm"
            clickable
            v-ripple
          >
            <q-item-section>
              <q-item-label>{{ reativar_usuario.nm_usuario }}</q-item-label>
              <q-item-label caption lines="1">{{
                reativar_usuario.nm_fantasia_usuario
              }}</q-item-label>
              <q-item-label caption lines="2">{{
                reativar_usuario.nm_email_usuario
              }}</q-item-label>
            </q-item-section>

            <q-item-section side>
              <q-btn
                round
                v-model="btn_send"
                icon="refresh"
                color="deep-orange-6"
                @click="Confirma_reativar(reativar_usuario)"
                clickable
              />
            </q-item-section>
          </q-item>
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
      timer: 0,
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
      cd_usuario_vencedor: 0,
      nm_imagem: "",
      dt_extenso: "",
      popup_excluir_participante: false,
      empresa: 0,
      participante_excluido: 0,
      btn_send: "",
      popup_adicionar_participante: false,
      novo_nm_usuario: "",
      novo_nm_fantasia: "",
      novo_email: "",
      excluir_participante: {},
      lista_participante: [],
      pop_updecisao: false,
      pop_reativar_usuario: false,
      reativar_usuario: [],
      excluido: 0,
      cd_controle: 0,
      lista_sorteados: [],
    };
  },

  async created() {
    this.cd_empresa_sorteio = localStorage.cd_empresa;
    this.nm_json = {
      cd_parametro: 0,
      cd_empresa: this.cd_empresa_sorteio,
    };
    this.nome_empresa = localStorage.fantasia;
    this.nm_empresa = localStorage.empresa;
    //this.nm_imagem    = 'http://www.egisnet.com.br/img/logo_endeavour.jpg';
    this.nm_imagem =
      "http://www.egisnet.com.br/img/" + localStorage.nm_caminho_logo_empresa;

    this.grid_sorteio = await Incluir.incluirRegistro("523/730", this.nm_json);
    this.ConsultaSorteados();
    this.quant = this.grid_sorteio.length;

    this.showMenu();
    this.carregaDados();
  },

  methods: {
    async ConsultaSorteados() {
      this.lista_sorteados = [];
      let c = {
        cd_parametro: 2,
      };
      let lista = await Incluir.incluirRegistro("523/730", c);
      if (lista[0].Cod == 0) return;
      for (let a = 0; a < lista.length; a++) {
        this.lista_sorteados.push(lista[a].cd_usuario_sorteio);
      }
    },
    async random() {
      this.onLimpaSorteio();
      await this.ConsultaSorteados();
      this.indice = Math.floor(Math.random() * this.final.length);
      this.cd_usuario_vencedor = this.grid_sorteio[this.indice].cd_usuario;
      if (
        this.lista_sorteados.length < this.grid_sorteio.length &&
        this.lista_sorteados.length > 0
      ) {
        let found = this.lista_sorteados.find(
          (element) => element == this.cd_usuario_vencedor
        );
        while (found == this.cd_usuario_vencedor) {
          this.indice = Math.floor(Math.random() * this.final.length);
          this.cd_usuario_vencedor = this.grid_sorteio[this.indice].cd_usuario;
          found = this.lista_sorteados.find(
            (element) => element == this.cd_usuario_vencedor
          );
        }
      }

      this.sorteado = this.final[this.indice].nm_usuario;
      this.foto = this.grid_sorteio[this.indice].vb_imagem;
      this.cd_controle = this.final[this.indice].cd_controle;

      let u = {
        cd_parametro: 1,
        cd_usuario_sorteio: this.cd_usuario_vencedor,
        cd_usuario: localStorage.cd_usuario,
      };
      var salva_cd_usuario = await Incluir.incluirRegistro("523/730", u);

      this.imagem_usuario = "";
      this.imagem_usuario = this.grid_sorteio[this.indice].vb_imagem;
      this.popup_aguardando = true;
      this.timer = this.tempo_correr;
      this.tempo = setInterval(this.random_vendedor, 150);
      this.intervalo = setInterval(this.AguardandoResultado, 1000);
    },
    async clickRandom() {
      if (this.participantes_d.length <= 1) {
        notify("Selecione pelo menos duas pessoas");
        return;
      }
      await this.random();
      this.time();
    },

    time() {
      setTimeout(() => {
        this.clearSelection();
      }, 6000);
      setTimeout(() => {
        this.lista_participante.push(this.sorteado);
      }, 5000);
      this.excluido = this.participantes_d.shift();
    },

    random_vendedor() {
      this.indice = Math.floor(Math.random() * this.final.length);
      this.usuario_rand = this.final[this.indice].nm_usuario;
    },
    //FUNÇÃO QUE MOSTRA O MENU-------------------

    async showMenu() {
      dados = await Menu.montarMenu(
        localStorage.cd_empresa,
        localStorage.cd_menu,
        localStorage.cd_api
      ); //'titulo';
      sParametroApi = dados.nm_api_parametro;
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));

      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
    },

    async carregaDados() {
      let sApis = sParametroApi;
      this.dataSourceConfig = await Incluir.incluirRegistro(
        "523/730",
        this.nm_json
      );
      console.log(this.dataSourceConfig, "DATA RESULT");
      this.dt_extenso =
        this.dataSourceConfig[0].dia_semana +
        " - " +
        this.dataSourceConfig[0].data_extenso;
      this.tempo_correr = this.dataSourceConfig[0].qt_tempo;
    },
    teste({ selectedRowKeys, selectedRowsData }) {
      this.participantes_d = selectedRowKeys;
      this.final = selectedRowsData;
    },
    Decisao() {
      this.pop_updecisao = true;
    },
    async ReativarUsuario() {
      this.nm_json = {
        cd_parametro: 3,
        cd_empresa: this.cd_empresa_sorteio,
      };
      this.reativar_usuario = await Incluir.incluirRegistro(
        "560/779",
        this.nm_json
      );
      notify(this.reativar_usuario[0].Msg);
      this.pop_reativar_usuario = true;
    },
    onLimpaSorteio() {
      this.intervalo = 0;
      this.sorteado = "";
      this.timer = 0;
      this.cd_controle = 0;
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

    NovoParticipante() {
      this.pop_updecisao = false;
      this.novo_nm_usuario = "";
      this.novo_nm_fantasia = "";
      this.novo_email = "";
      this.popup_adicionar_participante = true;
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
        this.nm_json
      );
      notify(this.excluir_participante[0].Msg);

      //recarrega menu
      this.nm_json = {
        cd_parametro: 0,
        cd_empresa: this.cd_empresa_sorteio,
      };
      this.dataSourceConfig = [];
      this.dataSourceConfig = await Incluir.incluirRegistro(
        "523/730",
        this.nm_json
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
        "560/779",
        this.nm_json
      );
      notify(Confirma_reativar[0].Msg);

      this.nm_json = {
        cd_parametro: 0,
        cd_empresa: this.cd_empresa_sorteio,
      };
      this.dataSourceConfig = [];
      this.dataSourceConfig = await Incluir.incluirRegistro(
        "523/730",
        this.nm_json
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
    async InsertUsuario() {
      if (this.novo_nm_usuario == "") {
        notify("Digite o nome completo");
        return;
      } else if (this.novo_nm_fantasia == "") {
        notify("Digite o nome fantasia!");
        return;
      } else if (this.novo_email == "") {
        notify("Digite o e-mail!");
        return;
      }
      let api_exclusao = "560/779";

      this.nm_json = {
        cd_parametro: 2,
        nm_usuario: this.novo_nm_usuario,
        nm_fantasia: this.novo_nm_fantasia,
        nm_email: this.novo_email,
        cd_empresa: this.cd_empresa_sorteio,
      };
      this.insert_usuario = await Incluir.incluirRegistro(
        api_exclusao,
        this.nm_json
      );
      notify(this.insert_usuario[0].Msg);

      this.cd_empresa_sorteio = localStorage.cd_empresa;
      this.nm_json = {
        cd_parametro: 0,
        cd_empresa: this.cd_empresa_sorteio,
      };
      this.nome_empresa = localStorage.fantasia;
      this.nm_empresa = localStorage.empresa;
      this.nm_imagem =
        "http://www.egisnet.com.br/img/" + localStorage.nm_caminho_logo_empresa;

      this.grid_sorteio = await Incluir.incluirRegistro(
        "523/730",
        this.nm_json
      );
      this.quant = this.grid_sorteio.length;

      this.showMenu();
      this.carregaDados();
      this.popup_adicionar_participante = false;
    },
    clearSelection() {
      const datagrid = this.$refs["grid_p"].instance;
      datagrid.deselectRows(this.cd_controle);
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
  },
};
</script>

<style scoped>
@import url("./views.css");
#img-logo-sorteio {
  margin: 15px 0px !important;
  max-width: 200px !important;
  max-height: 200px !important;
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
.botao-decisao {
  margin: 20px;
}
.tit {
  margin: 0;
  padding: 0;
}
</style>
