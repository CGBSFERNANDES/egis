<template>
  <div style="margin: 0; padding: 0">
    <transition name="slide-fade">
      <h2 v-if="!!tituloMenu != false" class="content-block h2">
        {{ tituloMenu }}
      </h2>
    </transition>
    <q-expansion-item
      icon="description"
      :label="'Dados'"
      default-opened
      class="shadow-1 overflow-hidden bg-white margin1"
      style="border-radius: 20px; height: auto"
      header-class="bg-primary text-white row items-center text-h6"
      expand-icon-class="text-white"
    >
      <div class="row items-center">
        <q-input
          class="col margin1"
          type="number"
          v-model="cd_ordem_producao"
          label="Ordem de Produção"
          :loading="loadingConsulta"
          min="0"
          @keyup.enter="PesquisaOP()"
        >
          <template v-slot:prepend>
            <q-icon name="assignment"></q-icon>
          </template>
          <template v-slot:append>
            <q-btn
              size="md"
              round
              flat
              color="orange-9"
              icon="search"
              @click="PesquisaOP"
            />
          </template>
        </q-input>

        <q-input
          class="col margin1"
          type="number"
          v-model="cd_pedido_venda"
          label="Pedido de Venda"
          readonly
          :loading="loadingConsulta"
        >
          <template v-slot:prepend>
            <q-icon name="assignment"></q-icon>
          </template>
        </q-input>

        <q-input
          class="col margin1"
          v-model="nm_fantasia_cliente"
          autogrow
          readonly
          label="Cliente"
          :loading="loadingConsulta"
        >
          <template v-slot:prepend>
            <q-icon name="person"></q-icon>
          </template>
        </q-input>
      </div>
      <!--</div>
    <div class="row borda-bloco shadow-2 margin1 ">-->
      <div class="row items-center">
        <q-input
          class="margin1 col"
          v-model="nm_produto"
          autogrow
          readonly
          label="Produto"
          :loading="loadingConsulta"
        >
          <template v-slot:prepend>
            <q-icon name="build"></q-icon>
          </template>
        </q-input>
        <q-input
          class="margin1 col-3"
          v-model="nm_operador"
          readonly
          label="Máquina"
          :loading="loadingConsulta"
        >
          <template v-slot:prepend>
            <q-icon name="engineering"></q-icon>
          </template>
        </q-input>
      </div>

      <!--<table style="width:100%" class="maring1" v-show="ativa_grid">
      <tr>
        <th class="" v-for="(a, index_col) in columns.length" :key="index_col">{{columns[index_col].caption}}</th>
      </tr>
      <tr>
        <td v-for="(b, index_row) in dataSourceConfig.length" :key="index_row" >{{dataSourceConfig[index_row].caption}}</td>
  
      </tr>
    </table>
          <div class="row col items-center" v-for="(a, index_col) in columns.length" :key="index_col">
        {{columns[index_col].caption}}
        <div class="row items-center" v-for="(b, index_row) in dataSourceConfig.length" :key="index_row">
          

        </div>
       
      </div>

    <div class="row">
      <div class="text-body text-bold" style="margin: 20px">Turno
      <q-radio v-model="cd_turno" val="1" label="Manhã"></q-radio>
      <q-radio v-model="cd_turno" val="2" label="Tarde"></q-radio>
      <q-radio v-model="cd_turno" val="3" label="Noite"></q-radio>
      </div>
      
      </div>
      
       :columns="columns" 
      -->
      <transition name="slide-fade">
        <div v-if="ativa_grid" style="margin: 0; padding: 0">
          <dx-data-grid
            id="grid-padrao"
            class="dx-card wide-card margin1"
            :data-source="dataSourceConfig"
            key-expr="cd_controle"
            :show-borders="true"
            :focused-row-enabled="true"
            :column-hiding-enabled="false"
            :remote-operations="false"
            :word-wrap-enabled="false"
            :allow-column-reordering="false"
            :allow-column-resizing="true"
            :row-alternation-enabled="true"
            :repaint-changes-only="true"
            :autoNavigateToFocusedRow="true"
            :columnAutoWidth="true"
            :focused-row-index="0"
            :column-min-width="120"
            :cacheEnable="false"
            ref="grid_p"
            :selectedrow-keys="selectedRowKeys"
            @row-updated="onSalvarOP"
            @row-validating="onRowValidating"
          >
            <!--<DxColumn
            data-field="Unidade medida">
            <DxLookup
                :data-source="dataset_um"
                value-expr="cd_unidade_medida"
                display-expr="nm_unidade_medida"
            />
        </DxColumn>-->

            <DxColumn
              v-for="(a, index) in columns"
              :key="index"
              :allow-editing="a.editing"
              :column-auto-width="true"
              :data-field="a.dataField"
              :dataType="a.dataType"
              :column-min-width="120"
              :caption="a.caption"
              :alignment="a.alignment"
              :visible="a.visible"
            >
              <DxLookup
                v-if="a.dataField == 'nm_unidade_medida'"
                :data-source="dataset_um"
                value-expr="cd_unidade_medida"
                display-expr="nm_unidade_medida"
              />
            </DxColumn>
            <DxSorting mode="none" />
            <DxGroupPanel :visible="false" empty-panel-text="agrupar..." />
            <DxStateStoring
              :enabled="true"
              type="localStorage"
              storage-key="storage"
            />
            <DxGrouping :auto-expand-all="true" />
            <DxPaging :page-size="100" />
            <DxEditing :allow-updating="true" mode="batch" />
            <DxPager
              :show-page-size-selector="true"
              :allowed-page-sizes="pageSizes"
              :show-info="true"
            />
            <DxColumnFixing :enabled="true" />
            <DxForm :form-data="formData" :items="items">
              <DxItem :col-count="2" :col-span="2" item-type="group" />
            </DxForm>
          </dx-data-grid>
        </div>
      </transition>
    </q-expansion-item>
    <transition name="slide-fade">
      <q-expansion-item
        icon="description"
        :label="'Resultado'"
        default-opened
        v-show="ativa_grid"
        class="shadow-1 overflow-hidden margin1 bg-white"
        style="border-radius: 20px; height: auto"
        header-class="bg-primary text-white row items-center text-h6"
        expand-icon-class="text-white"
      >
        <div class="row items-center" v-show="ativa_grid">
          <q-input
            class="col margin1"
            type="text"
            v-model="nm_inspetor1"
            label="Inspetor"
            readonly
          >
            <template v-slot:prepend>
              <q-icon name="person"></q-icon>
            </template>
          </q-input>

          <q-input
            class="col margin1"
            type="text"
            v-model="dt_inspecao1"
            label="Data"
            readonly
          >
            <template v-slot:prepend>
              <q-icon name="task_alt"></q-icon>
            </template>
          </q-input>

          <q-select
            label="1° Inspeção"
            class="margin1 col"
            v-model="cd_tipo_resposta1"
            input-debounce="0"
            :options="this.dataset_resposta_laudo"
            option-value="cd_tipo_resposta"
            option-label="sg_tipo_resposta"
            @input="AtualizaInspecao(1)"
          >
            <template v-slot:prepend>
              <q-icon name="looks_one" />
            </template>
          </q-select>
        </div>
        <!-------------------------------------------------------------------------------------------------->
        <div class="row items-center" v-show="ativa_grid">
          <q-input
            class="col margin1"
            type="text"
            v-model="nm_inspetor2"
            label="Inspetor"
            readonly
          >
            <template v-slot:prepend>
              <q-icon name="person"></q-icon>
            </template>
          </q-input>

          <q-input
            class="col margin1"
            type="text"
            v-model="dt_inspecao2"
            label="Data"
            readonly
          >
            <template v-slot:prepend>
              <q-icon name="task_alt"></q-icon>
            </template>
          </q-input>

          <q-select
            label="2° Inspeção"
            class="margin1 col"
            v-model="cd_tipo_resposta2"
            input-debounce="0"
            :options="this.dataset_resposta_laudo"
            option-value="cd_tipo_resposta"
            option-label="sg_tipo_resposta"
            @input="AtualizaInspecao(2)"
          >
            <template v-slot:prepend>
              <q-icon name="looks_two" />
            </template>
          </q-select>
        </div>
        <!-------------------------------------------------------------------------------------------------->
        <div class="row items-center" v-show="ativa_grid">
          <q-input
            class="col margin1"
            type="text"
            v-model="nm_inspetor3"
            label="Inspetor"
            readonly
          >
            <template v-slot:prepend>
              <q-icon name="person"></q-icon>
            </template>
          </q-input>

          <q-input
            class="col margin1"
            type="text"
            v-model="dt_inspecao3"
            label="Data"
            readonly
          >
            <template v-slot:prepend>
              <q-icon name="task_alt"></q-icon>
            </template>
          </q-input>

          <q-select
            label="3° Inspeção"
            class="margin1 col"
            v-model="cd_tipo_resposta3"
            input-debounce="0"
            :options="this.dataset_resposta_laudo"
            option-value="cd_tipo_resposta"
            option-label="sg_tipo_resposta"
            @input="AtualizaInspecao(3)"
          >
            <template v-slot:prepend>
              <q-icon name="looks_3" />
            </template>
          </q-select>
        </div>
        <!-------------------------------------------------------------------------------------------------->
        <div class="row items-center" v-show="ativa_grid">
          <q-input
            class="col margin1"
            type="text"
            v-model="nm_inspetor4"
            label="Inspetor"
            readonly
          >
            <template v-slot:prepend>
              <q-icon name="person"></q-icon>
            </template>
          </q-input>

          <q-input
            class="col margin1"
            type="text"
            v-model="dt_inspecao4"
            label="Data"
            readonly
          >
            <template v-slot:prepend>
              <q-icon name="task_alt"></q-icon>
            </template>
          </q-input>

          <q-select
            label="4° Inspeção"
            class="margin1 col"
            v-model="cd_tipo_resposta4"
            input-debounce="0"
            :options="this.dataset_resposta_laudo"
            option-value="cd_tipo_resposta"
            option-label="sg_tipo_resposta"
            @input="AtualizaInspecao(4)"
          >
            <template v-slot:prepend>
              <q-icon name="looks_4" />
            </template>
          </q-select>
        </div>
        <!-------------------------------------------------------------------------------------------------->
        <div class="row items-center" v-show="ativa_grid">
          <q-input
            class="col margin1"
            type="text"
            v-model="nm_inspetor5"
            label="Inspetor"
            readonly
          >
            <template v-slot:prepend>
              <q-icon name="person"></q-icon>
            </template>
          </q-input>

          <q-input
            class="col margin1"
            type="text"
            v-model="dt_inspecao5"
            label="Data"
            readonly
          >
            <template v-slot:prepend>
              <q-icon name="task_alt"></q-icon>
            </template>
          </q-input>

          <q-select
            label="5° Inspeção"
            class="margin1 col"
            v-model="cd_tipo_resposta5"
            input-debounce="0"
            :options="this.dataset_resposta_laudo"
            option-value="cd_tipo_resposta"
            option-label="sg_tipo_resposta"
            @input="AtualizaInspecao(5)"
          >
            <template v-slot:prepend>
              <q-icon name="looks_5" />
            </template>
          </q-select>
        </div>

        <q-input
          class="margin1 col"
          type="text"
          autogrow
          v-model="ds_descricao"
          label="Observações"
        >
          <template v-slot:prepend>
            <q-icon name="article"></q-icon>
          </template>
          <template v-slot:append>
            <q-btn round color="orange-10" icon="check" @click="onDescricao()">
              <q-tooltip transition-show="scale" transition-hide="scale">
                Salvar Observação
              </q-tooltip>
            </q-btn>
          </template>
        </q-input>
      </q-expansion-item>
    </transition>
    <transition name="slide-fade">
      <q-expansion-item
        v-show="ativa_grid"
        icon="description"
        :label="'Documentação'"
        default-opened
        class="shadow-1 overflow-hidden margin1 bg-white"
        style="border-radius: 20px; height: auto"
        header-class="bg-primary text-white row items-center text-h6"
        expand-icon-class="text-white"
      >
        <div class="row items-center">
          <q-file
            v-model="documento"
            class="margin1 col"
            label="Documentos"
            multiple
            use-chips
            :filter="checkFileSize"
            @rejected="onRejected"
          >
            <template v-slot:prepend>
              <q-icon name="upload_file" />
            </template>
          </q-file>

          <div class="col items-end">
            <q-btn
              color="orange-9"
              rounded
              style="float: right"
              class="margin1"
              @click="EnviaDocumento"
              icon-right="arrow_right_alt"
              label="Enviar"
            />
          </div>
        </div>

        <div class="row" v-for="(b, index) in lista_documento" :key="index">
          <q-list bordered separator class="col">
            <q-item clickable v-ripple class="row">
              <q-item-section class="col text-subtitle2"
                >{{ b.nm_documento_laudo }} -
                {{ b.dt_documento }}</q-item-section
              >
              <q-item-section avatar>
                <a
                  @click="AbreVB(b.vb_laudo_documento)"
                  download
                  :href="b.vb_laudo_documento"
                  ><q-icon
                    color="orange-10"
                    size="md"
                    name="cloud_download"
                    href
                /></a>
              </q-item-section>
              <q-item-section avatar>
                <q-icon color="red" name="delete" @click="DeleteDoc(b)" />
              </q-item-section>
            </q-item>
          </q-list>
        </div>
        <div
          class="row text-subtitle2 justify-center items-center self-center margin1"
          v-if="lista_documento.length == 0"
        >
          Nenhum documento encontrato
        </div>
      </q-expansion-item>
    </transition>

    <!--
    <div class="borda-bloco margin1 shadow-2">
      <div class="row text-bold text-h6 justify-center items-center self-center">
        Definições do Laudo
      </div>
      <div class="row">
        <q-select
          label="Status"
          class="margin1 col-3"
          v-model="cd_status_laudo"
          input-debounce="0"
          :options="this.dataset_aprovacao"
          option-value="cd_status_laudo"
          option-label="nm_status_laudo"
        >
        <template v-slot:prepend>
          <q-icon name="store" />
        </template>
       </q-select>

        
      </div>
      
      <q-separator inset/>

      <div class="row justify-center items-center self-center">
        <div class=" margin1 text-subtitle2 "> A - APROVADO </div>
        <q-separator vertical/>
        <div class=" margin1 text-subtitle2 "> N/C - NÃO CONFORME </div>
        <q-separator vertical/>
        <div class=" margin1 text-subtitle2 "> N/A - NÃO APLICADO </div>
      </div>

        
    </div>-->
    <q-dialog v-model="load" maximized persistent>
      <carregando :mensagemID="mensagem"></carregando>
    </q-dialog>
  </div>
</template>

<script>
import funcao from "../http/funcoes-padroes";
import { DxSorting } from "devextreme-vue/data-grid";

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
import Lookup from "../http/lookup";
import carregando from "../components/carregando.vue";

export default {
  data() {
    return {
      dados: [],
      dataSourceConfig: [],
      total: {},
      columns: [],
      selectedRowKeys: [],
      mensagem: "",
      items: [],
      nm_inspetor1: "",
      dt_inspecao1: "",
      nm_inspetor2: "",
      dt_inspecao2: "",
      nm_inspetor3: "",
      dt_inspecao3: "",
      nm_inspetor4: "",
      dt_inspecao4: "",
      nm_inspetor5: "",
      dt_inspecao5: "",
      formData: {},
      pageSizes: "100",
      nm_json: {},
      row: {},
      load: false,
      tituloMenu: "",
      cd_ordem_producao: "",
      nm_fantasia_cliente: "",
      nm_produto: "",
      lista_documento: [],
      nm_operador: "",
      documento: [],
      ds_descricao: "",
      cd_processo: 0,
      ativa_grid: false,
      op_true: false,
      cd_pedido_venda: "",
      loadingConsulta: false,
      dados_aprovacao: [],
      dataset_aprovacao: [],
      cd_status_laudo: "",
      cd_usuario: localStorage.cd_usuario,
      dados_um: [],
      dataset_um: [],
      lookupDataSourceConfig: {},
      dados_resposta_laudo: [],
      dataset_resposta_laudo: [],
      cd_tipo_resposta1: "",
      cd_tipo_resposta2: "",
      cd_tipo_resposta3: "",
      cd_tipo_resposta4: "",
      cd_tipo_resposta5: "",
      cd_menu: localStorage.cd_menu,
      cd_empresa: localStorage.cd_empresa,
      cd_api: localStorage.cd_api,
    };
  },

  async created() {
    document.removeEventListener("keyup", this.onEnterLoginUsuarioEgisnet);
    //document.removeEventListener("keyup", this.onEnterOP);

    var menu = await Menu.montarMenu(
      this.cd_empresa,
      this.cd_menu,
      this.cd_api
    );
    this.tituloMenu = menu.nm_menu_titulo;
    this.dados_um = await Lookup.montarSelect(this.cd_empresa, 138);
    this.dataset_um = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_um.dataset))
    );
    //document.addEventListener("keyup", this.onEnterOP);
    this.showMenu();
    this.dados_aprovacao = await Lookup.montarSelect(this.cd_empresa, 4393);
    this.dataset_aprovacao = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_aprovacao.dataset))
    );
    this.dados_resposta_laudo = await Lookup.montarSelect(
      this.cd_empresa,
      4929
    );
    this.dataset_resposta_laudo = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_resposta_laudo.dataset))
    );

    //this.carregaDados();
  },

  methods: {
    async PesquisaResultado() {
      let d = {
        cd_parametro: 9,
        cd_processo: this.cd_ordem_producao,
      };
      let a = await Incluir.incluirRegistro("590/819", d);

      if (a[0].Cod == 0) {
        return;
      }
      this.nm_inspetor1 = a[0].nm_inspetor1;
      this.nm_inspetor2 = a[0].nm_inspetor2;
      this.nm_inspetor3 = a[0].nm_inspetor3;
      this.nm_inspetor4 = a[0].nm_inspetor4;
      this.nm_inspetor5 = a[0].nm_inspetor5;

      this.dt_inspecao1 = a[0].dt_inspecao1;
      this.dt_inspecao2 = a[0].dt_inspecao2;
      this.dt_inspecao3 = a[0].dt_inspecao3;
      this.dt_inspecao4 = a[0].dt_inspecao4;
      this.dt_inspecao5 = a[0].dt_inspecao5;

      //if (a[0].cd_status_laudo !== 0) {
      //  this.cd_status_laudo = {
      //    cd_status_laudo: a[0].cd_status_laudo,
      //    nm_status_laudo: a[0].nm_status_laudo,
      //  };
      //}
      if (a[0].cd_tipo_resposta1 != 0) {
        this.cd_tipo_resposta1 = {
          sg_tipo_resposta: a[0].sg_tipo_resposta1,
          cd_tipo_resposta: a[0].cd_tipo_resposta1,
        };
        this.nm_inspetor1 = a[0].nm_inspetor1;
      }
      if (a[0].cd_tipo_resposta2 != 0) {
        this.cd_tipo_resposta2 = {
          sg_tipo_resposta: a[0].sg_tipo_resposta2,
          cd_tipo_resposta: a[0].cd_tipo_resposta2,
        };
        this.nm_inspetor2 = a[0].nm_inspetor2;
      }
      if (a[0].cd_tipo_resposta3 != 0) {
        this.cd_tipo_resposta3 = {
          sg_tipo_resposta: a[0].sg_tipo_resposta3,
          cd_tipo_resposta: a[0].cd_tipo_resposta3,
        };
        this.nm_inspetor3 = a[0].nm_inspetor3;
      }
      if (a[0].cd_tipo_resposta4 != 0) {
        this.cd_tipo_resposta4 = {
          sg_tipo_resposta: a[0].sg_tipo_resposta4,
          cd_tipo_resposta: a[0].cd_tipo_resposta4,
        };
        this.nm_inspetor4 = a[0].nm_inspetor4;
      }
      if (a[0].cd_tipo_resposta5 != 0) {
        this.cd_tipo_resposta5 = {
          sg_tipo_resposta: a[0].sg_tipo_resposta5,
          cd_tipo_resposta: a[0].cd_tipo_resposta5,
        };
        this.nm_inspetor5 = a[0].nm_inspetor5;
      }
    },
    async ClearCampo() {
      this.cd_pedido_venda = "";
      this.nm_fantasia_cliente = "";
      this.nm_produto = "";
      this.nm_operador = "";
      this.nm_inspetor1 = "";
      this.dt_inspecao1 = "";
      this.cd_tipo_resposta1 = "";
      this.nm_inspetor2 = "";
      this.dt_inspecao2 = "";
      this.cd_tipo_resposta2 = "";
      this.nm_inspetor3 = "";
      this.dt_inspecao3 = "";
      this.cd_tipo_resposta3 = "";
      this.nm_inspetor4 = "";
      this.dt_inspecao4 = "";
      this.cd_tipo_resposta4 = "";
      this.nm_inspetor5 = "";
      this.dt_inspecao5 = "";
      this.cd_tipo_resposta5 = "";
    },
    async CorrigeColunas() {
      this.ativa_grid = false;
      if (!!this.cd_tipo_resposta1.cd_tipo_resposta == false) {
        this.columns[5].visible = false; //2° Inspeção
      } else {
        this.columns[5].visible = true; //2° Inspeção
      }

      if (!!this.cd_tipo_resposta2.cd_tipo_resposta == false) {
        this.columns[6].visible = false; //3° Inspeção
      } else {
        this.columns[6].visible = true; //2° Inspeção
      }

      if (!!this.cd_tipo_resposta3.cd_tipo_resposta == false) {
        this.columns[7].visible = false; //4° Inspeção
      } else {
        this.columns[7].visible = true; //2° Inspeção
      }

      if (!!this.cd_tipo_resposta4.cd_tipo_resposta == false) {
        this.columns[8].visible = false; //5° Inspeção
      } else {
        this.columns[8].visible = true; //2° Inspeção
      }

      this.ativa_grid = true;
    },
    async DeleteDoc(documento) {
      let e = {
        cd_parametro: 8,
        cd_processo: this.cd_ordem_producao,
        cd_item_laudo: documento.cd_item_laudo,
      };
      let del = await Incluir.incluirRegistro("590/819", e);
      notify(del[0].Msg);
      let found = this.lista_documento.find(
        (element) =>
          element.cd_laudo == documento.cd_item_laudo &&
          element.cd_laudo == documento.cd_laudo
      );
      this.lista_documento.splice(this.lista_documento.indexOf(found), 1);
    },

    async AbreVB(vb) {
      await funcao.AbreVB(vb);
    },

    async ConsultaDoc() {
      notify("Buscando Documentos...");
      this.lista_documento = [];
      let c = {
        cd_parametro: 7,
        cd_processo: this.cd_ordem_producao,
      };
      this.lista_documento = await Incluir.incluirRegistro("590/819", c);
    },
    async EnviaDocumento() {
      this.mensagem = "Reunindo documentos...";
      this.load = true;
      for (let c = 0; c < this.documento.length; c++) {
        await funcao.CriaVb(this.documento[c]);
        this.mensagem = "Salvando documentos:" + this.documento[c].name;
        let vb = localStorage.vb_document;
        let json = {
          cd_processo: this.cd_ordem_producao,
          vb_documento: vb,
          nm_documento: this.documento[c].name,
          cd_parametro: 6,
          cd_usuario: localStorage.cd_usuario,
        };
        var doc = await Incluir.incluirRegistro("590/819", json);
        notify(doc[0].Msg);
      }
      this.ConsultaDoc();
      this.mensagem = "";
      this.load = false;
      this.documento = [];
    },

    onRejected(rejectedEntries) {
      notify(`${rejectedEntries.length} arquivo(s) muito grande(s)!`);
    },

    checkFileSize(files) {
      return files.filter((file) => file.size < 321834);
    },

    async showMenu() {
      var dados = await Menu.montarMenu(
        this.cd_empresa,
        this.cd_menu,
        this.cd_api
      );
      if (!!dados.coluna_total !== false) {
        this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      }
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      this.columns[2].store = {
        type: "array",
        data: this.dataset_um,
        key: "id",
      };
      for (let g = 0; g < this.columns.length; g++) {
        if (
          this.columns[g].dataField == "nm_caracteristica_laudo" ||
          this.columns[g].dataField == "nm_resultado_obtido"
        ) {
          this.columns[g].editing = false;
        } else {
          this.columns[g].editing = true;
        }
      }
    },

    async carregaDados() {
      if (this.cd_ordem_producao == "") {
        return;
      }

      var api = "590/819"; //1464 - pr_controle_qualidade_produto_net
      var dados_json = {
        cd_parametro: 0,
        cd_processo: this.cd_ordem_producao,
      };
      this.dataSourceConfig = await Incluir.incluirRegistro(api, dados_json);
      await this.PesquisaResultado();
      await this.CorrigeColunas();
    },

    async onSalvarOP(e) {
      var api_d = "590/819";
      var dados = {
        cd_parametro: 2,
        cd_processo: this.cd_ordem_producao,
        cd_caracteristica_laudo: e.data.cd_caracteristica_laudo,
        nm_especificacao: e.data.nm_resultado_obtido,
        nm_tolerancia_produto: e.data.nm_tolerancia_produto,
        nm_unidade_medida: e.data.nm_unidade_medida,
        cd_laudo: e.data.cd_laudo,
        nm_inspecao1: e.data.nm_inspecao1,
        nm_inspecao2: e.data.nm_inspecao2,
        nm_inspecao3: e.data.nm_inspecao3,
        nm_inspecao4: e.data.nm_inspecao4,
        nm_inspecao5: e.data.nm_inspecao5,
        cd_usuario: this.cd_usuario,
      };
      var a = await Incluir.incluirRegistro(api_d, dados);
      notify(a[0].Msg);
    },

    async PesquisaOP() {
      if (this.cd_ordem_producao < 0) {
        notify("Digite o número da OP corretamente!");
        return;
      }
      this.loadingConsulta = true;
      await this.ClearCampo();
      var api_d = "590/819";
      var dados = {
        cd_parametro: 1,
        cd_processo: this.cd_ordem_producao,
      };
      var a = await Incluir.incluirRegistro(api_d, dados);

      if (a[0].Cod == 0) {
        notify(a[0].Msg);
        this.loadingConsulta = false;
        return;
      } else {
        this.nm_fantasia_cliente = a[0].nm_razao_social_cliente;
        this.nm_produto = a[0].nm_produto;

        this.cd_pedido_venda = a[0].cd_pedido_venda;
        this.nm_operador = a[0].nm_fantasia_usuario;

        this.ds_descricao = a[0].ds_laudo;

        this.op_true = true;
        await this.carregaDados();
        this.ativa_grid = true;
        await this.ConsultaDoc();
        this.loadingConsulta = false;
      }
    },

    onEnterOP(e) {
      if (e.keyCode != 13) {
      } else {
        this.PesquisaOP();
      }
    },
    async AtualizaInspecao(campo) {
      var api_d = "590/819";
      if (this.cd_ordem_producao == "") {
        return;
      }

      var h = {
        cd_parametro: 5,
        cd_tipo_resposta1: this.cd_tipo_resposta1.cd_tipo_resposta,
        cd_tipo_resposta2: this.cd_tipo_resposta2.cd_tipo_resposta,
        cd_tipo_resposta3: this.cd_tipo_resposta3.cd_tipo_resposta,
        cd_tipo_resposta4: this.cd_tipo_resposta4.cd_tipo_resposta,
        cd_tipo_resposta5: this.cd_tipo_resposta5.cd_tipo_resposta,
        cd_processo: this.cd_ordem_producao,
        cd_usuario: this.cd_usuario,
        cd_inspecao: campo,
      };
      var inspecao = await Incluir.incluirRegistro(api_d, h);
      notify(inspecao[0].Msg);

      await this.CorrigeColunas();
      this.PesquisaResultado();
    },

    async onRowValidating(e) {
      var api_d = "590/819";

      if (e.newData.nm_inspecao1 !== undefined) {
        var h = {
          cd_parametro: 4,
          cd_inspetor1: this.cd_usuario,
          cd_processo: this.cd_ordem_producao,
        };
        var inspetor = await Incluir.incluirRegistro(api_d, h);
        notify(inspetor[0].Msg);
        return;
      } else if (e.newData.nm_inspecao2 !== undefined) {
        var h = {
          cd_parametro: 4,
          cd_inspetor2: this.cd_usuario,
          cd_processo: this.cd_ordem_producao,
        };
        var inspetor = await Incluir.incluirRegistro(api_d, h);
        notify(inspetor[0].Msg);
        return;
      } else if (e.newData.nm_inspecao3 !== undefined) {
        var h = {
          cd_parametro: 4,
          cd_inspetor3: this.cd_usuario,
          cd_processo: this.cd_ordem_producao,
        };
        var inspetor = await Incluir.incluirRegistro(api_d, h);
        notify(inspetor[0].Msg);
        return;
      } else if (e.newData.nm_inspecao4 !== undefined) {
        var h = {
          cd_parametro: 4,
          cd_inspetor4: this.cd_usuario,
          cd_processo: this.cd_ordem_producao,
        };
        var inspetor = await Incluir.incluirRegistro(api_d, h);
        notify(inspetor[0].Msg);
        return;
      } else if (e.newData.nm_inspecao5 !== undefined) {
        var h = {
          cd_parametro: 4,
          cd_inspetor5: this.cd_usuario,
          cd_processo: this.cd_ordem_producao,
        };
        var inspetor = await Incluir.incluirRegistro(api_d, h);
        notify(inspetor[0].Msg);
        return;
      }
    },

    async onDescricao() {
      if (this.op_true == true) {
        var api_d = "590/819";
        var dados = {
          cd_parametro: 3,
          cd_processo: this.cd_ordem_producao,
          ds_laudo: this.ds_descricao,
          cd_usuario: this.cd_usuario,
          cd_status_laudo: this.cd_status_laudo.cd_status_laudo,
        };
        var a = await Incluir.incluirRegistro(api_d, dados);
        notify(a[0].Msg);
        return;
      }
      //notify('Selecione uma Ordem de Produção para salvar a Observação!');
    },
  },
  components: {
    DxDataGrid,
    DxFilterRow,
    DxSorting,
    DxPager,
    DxPaging,
    DxExport,
    carregando,
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
    DxLookup,
    componente,
    DxForm,
    DxButton,
    DxPopup,
    DxEditing,
    DxPosition,
    DxItem,
    DxColumn,
    DxMasterDetail,
    selecaoData,
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw !important;
  padding: 0;
}

.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}
#grid-padrao {
  max-height: 600px !important;
}
table,
th,
td {
  border: 1px solid black;
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

@media (max-width: 1200px) {
  .margin1 {
    margin: 2.5px 2.5px !important;
    padding: 0;
  }
}
</style>
