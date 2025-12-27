<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div>
      <!-- Tabela -->
      <transition name="slide-fade">
        <DxButton
          v-if="!cd_tipo_email == 0"
          class="botao-info"
          icon="email"
          text=""
          @click="renderDoc"
        />
      </transition>

      <transition name="slide-fade">
        <div class="info-periodo" v-if="periodoVisible == true">
          De: {{ dt_inicial }} até {{ dt_final }}
        </div>
      </transition>

      <div class="row items-center tituloHeader">
        <transition name="slide-fade">
          <h2 class="col-8 tituloTexto" v-show="!!tituloMenu != false">
            {{ tituloMenu }} {{ hoje }} {{ hora }}
            <q-badge
              v-if="qt_registro > 0"
              align="middle"
              rounded
              color="red"
              :label="qt_registro"
            />
          </h2>
        </transition>

        <div class="col">
          <q-btn
            style="float: right"
            round
            flat
            color="black"
            @click="carregaDados()"
            icon="refresh"
          >
            <q-tooltip content-class="bg-white text-primary"
              >Recarregar</q-tooltip
            >
          </q-btn>
          <q-btn
            style="float: right"
            round
            flat
            color="black"
            @click="popClickData()"
            icon="event"
          />
        </div>
      </div>
    </div>
    <!-- Componentes do Menu -->
    <transition-group
      name="slide-fade"
      tag="div"
      style="display: flex; flex-wrap: wrap"
    >
      <div v-for="(c, index) in this.componentesMenu" :key="index">
        <div class="col-8">
          <q-input
            v-if="c.cd_componente == 1"
            :prefix="c.nm_prefixo"
            :suffix="c.nm_sufixo"
            :color="c.vl_cor"
            :filled="c.cd_estilo_componente === 2 ? true : false"
            :outlined="
              c.cd_estilo_componente === 3 || c.cd_estilo_componente === 6
                ? true
                : false
            "
            :standout="
              c.cd_estilo_componente === 4 || c.cd_estilo_componente === 6
                ? true
                : false
            "
            :borderless="c.cd_estilo_componente === 5 ? true : false"
            :rounded="c.cd_estilo_componente === 6 ? true : false"
            :type="c.vl_natureza_atributo ? c.vl_natureza_atributo : 'text'"
            :dense="c.ic_dense === 't' ? true : false"
            :dark="false"
            class="col margin1"
            v-model="c.nm_valor"
            :label="c.nm_campo_texto"
            @input="onValor(c)"
          >
            <template v-slot:prepend>
              <q-icon :name="c.nm_icone_atributo"></q-icon>
            </template>
            <q-tooltip v-if="c.ds_descritivo">
              {{ `${c.ds_descritivo}` }}
            </q-tooltip>
          </q-input>

          <div v-if="c.cd_componente == 2">
            <q-select
              :filled="c.cd_estilo_componente === 2 ? true : false"
              :outlined="
                c.cd_estilo_componente === 3 || c.cd_estilo_componente === 6
                  ? true
                  : false
              "
              :standout="
                c.cd_estilo_componente === 4 || c.cd_estilo_componente === 6
                  ? true
                  : false
              "
              :borderless="c.cd_estilo_componente === 5 ? true : false"
              :rounded="c.cd_estilo_componente === 6 ? true : false"
              class="col margin1"
              v-model="c.nm_valor"
              :options="c.options"
              :color="c.vl_cor"
              :dense="c.ic_dense === 'f' ? false : true"
              :option-value="c.chave_tabela"
              :option-label="c.valor_tabela"
              :label="c.nm_campo_texto"
              @input="onValor(c)"
            >
              <template v-slot:prepend>
                <q-icon :name="c.nm_icone_atributo"></q-icon>
              </template>
              <q-tooltip v-if="c.ds_descritivo">
                {{ `${c.ds_descritivo}` }}
              </q-tooltip>
            </q-select>
          </div>
          <div v-if="c.cd_componente == 3">
            {{ `${c.nm_campo_texto}` }}
            <q-toggle
              class="col margin1"
              v-model="c.nm_valor"
              :color="c.vl_cor"
              @input="onValor(c)"
            >
              <q-tooltip v-if="c.ds_descritivo">
                {{ `${c.ds_descritivo}` }}
              </q-tooltip>
            </q-toggle>
            {{ `${c.nm_campo_texto_direita}` }}
          </div>
          <div v-if="c.cd_componente == 4">
            <!-- GRID -->
            <dx-data-grid
              id="grid-padrao"
              class="dx-card wide-card"
              :data-source="
                c.procedure_parametro ? c.procedure_parametro : c.procedure_json
              "
              :columns="c.colunas_web"
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
              @focused-row-changed="onTableRowChange"
            >
              <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

              <DxGrouping :auto-expand-all="true" />

              <DxExport :enabled="true" />

              <DxPaging :page-size="10" />

              <DxSelection
                :select-all-mode="allMode"
                :show-check-boxes-mode="checkBoxesMode"
                mode="multiple"
              />

              <DxSelectBox
                id="select-all-mode"
                :data-source="['allPages', 'page']"
                :disabled="checkBoxesMode === 'none'"
                :v-model:value="allMode"
              />

              <DxStateStoring
                :enabled="true"
                type="localStorage"
                storage-key="storageGrid"
              />
              <DxSelection mode="single" />
              <DxPager
                :show-page-size-selector="true"
                :allowed-page-sizes="[10, 20, 50, 100]"
                :show-info="true"
              />
              <DxFilterRow :visible="false" />
              <DxHeaderFilter :visible="true" :allow-search="true" />
              <DxSearchPanel
                :visible="true"
                :width="300"
                placeholder="Procurar..."
              />
              <DxFilterPanel :visible="true" />
              <DxColumnFixing :enabled="true" />
              <DxColumnChooser :enabled="true" mode="select" />
              <DxEditing
                refresh-mode="reshape"
                :allow-adding="false"
                :allow-update="true"
                mode="popup"
              >
                <DxPopup :show-title="true" title="menu">
                  <DxPosition my="top" at="top" of="window" />
                </DxPopup>
              </DxEditing>

              <DxMasterDetail
                v-if="!cd_detalhe == 0"
                :enabled="true"
                template="master-detail"
              />

              <template #master-detail="{ data }">
                <MasterDetail
                  :cd_menuID="cd_menu_detalhe"
                  :cd_apiID="cd_api_detalhe"
                  :master-detail-data="data"
                />
              </template>
            </dx-data-grid>
          </div>
          <div v-if="c.cd_componente == 5">
            <q-card class="my-card">
              <q-card-section
                style="margin: 0.2vw; padding: 0px; text-align: center"
                class="margin1"
              >
                {{ `${c.nm_campo_texto}` }}
              </q-card-section>
              <q-card-section
                class="borda-bloco"
                style="margin: 0.4vw; padding: 0px"
              >
                {{ `Texto do Card` }}<br />
              </q-card-section>
              <q-tooltip v-if="c.ds_descritivo">
                {{ `${c.ds_descritivo}` }}
              </q-tooltip>
            </q-card>
          </div>
          <div v-if="c.cd_componente == 6">
            <q-btn
              class="margin1"
              :color="c.vl_cor"
              :icon="c.nm_icone_atributo"
              :label="c.nm_campo_texto"
              text-color="black"
              :rounded="c.cd_estilo_componente === 6 ? true : false"
              @click="onValor('button', c)"
            >
              <q-tooltip v-if="c.ds_descritivo">
                {{ `${c.ds_descritivo}` }}
              </q-tooltip>
            </q-btn>
          </div>
        </div>
      </div>
    </transition-group>
    <!-- Fim Componentes do Menu -->
    <!-- Informações -->
    <div
      v-if="cd_empresa == 136 && dataSourceHeader[0]"
      class="row margin1 shadow-2 borda-bloco bg-white"
    >
      <q-field dense class="col margin1" label="Meta mensal" stack-label>
        <template v-slot:control>
          <div
            v-if="dataSourceHeader[0].Qt_Meta_Mes"
            class="self-center full-width no-outline"
            tabindex="0"
          >
            {{ dataSourceHeader[0].Qt_Meta_Mes }}
          </div>
        </template>
        <template v-slot:prepend>
          <q-icon name="my_location" />
        </template>
      </q-field>

      <q-field dense class="col margin1" label="Dias Transcorridos" stack-label>
        <template v-slot:control>
          <div
            v-if="dataSourceHeader[0].DiaTransc"
            class="self-center full-width no-outline"
            tabindex="0"
          >
            {{ dataSourceHeader[0].DiaTransc }}
          </div>
        </template>
        <template v-slot:prepend>
          <q-icon name="event" />
        </template>
      </q-field>

      <q-field dense class="col margin1" label="Dias úteis" stack-label>
        <template v-slot:control>
          <div
            v-if="dataSourceHeader[0].DiaUtil"
            class="self-center full-width no-outline"
            tabindex="0"
          >
            {{ dataSourceHeader[0].DiaUtil }}
          </div>
        </template>
        <template v-slot:prepend>
          <q-icon name="event" />
        </template>
      </q-field>

      <q-field dense class="col margin1" label="Meta diária" stack-label>
        <template v-slot:control>
          <div
            v-if="dataSourceHeader[0].QTMetaDia"
            class="self-center full-width no-outline"
            tabindex="0"
          >
            {{ dataSourceHeader[0].QTMetaDia }}
          </div>
        </template>
        <template v-slot:prepend>
          <q-icon name="my_location" />
        </template>
      </q-field>

      <q-field dense class="col margin1" label="Qtd Vendida" stack-label>
        <template v-slot:control>
          <div
            v-if="dataSourceHeader[0].Qt_Vendas"
            class="self-center full-width no-outline"
            tabindex="0"
          >
            {{ dataSourceHeader[0].Qt_Vendas }}
          </div>
        </template>
        <template v-slot:prepend>
          <q-icon name="sell" />
        </template>
      </q-field>

      <q-field dense class="col margin1" label="(%) Atingido" stack-label>
        <template v-slot:control>
          <div
            v-if="dataSourceHeader[0].Qt_perc_venda"
            class="self-center full-width no-outline"
            tabindex="0"
          >
            {{ dataSourceHeader[0].Qt_perc_venda.toFixed(2) }}
          </div>
        </template>
        <template v-slot:prepend>
          <q-icon name="my_location" />
        </template>
      </q-field>
    </div>

    <div>
      <form
        class="dx-card wide-card"
        v-if="ic_filtro_pesquisa == 'S'"
        action="your-action"
        @submit="handleSubmit"
      >
        <!--Caso expecifico para Guarufilme, busca ordem de produção pelo número digitado. Confira o localStorage.cd_identificacao-->
        <q-input
          color="orange-9"
          class="margin1"
          v-model="cd_identificacao"
          label="Ordem"
          v-if="cd_menu == 6753"
          @blur="carregaDados()"
        >
          <template v-slot:prepend>
            <q-icon name="search" />
          </template>
        </q-input>
        <!--Select dinamico do admin-->
        <q-select
          v-else
          filled
          clearable
          :option-value="value_lookup"
          :option-label="label_lookup"
          v-model="selecionada_lookup"
          :options="dataset_lookup"
          :label="placeholder_lookup"
          class="margin1"
        />

        <div class="row">
          <q-btn
            class="margin1"
            color="orange-9"
            rounded
            label="Pesquisar"
            @click="onClick($event)"
          />
        </div>
      </form>
    </div>
    <DxTabPanel
      class="dx-card wide-card tabPanel"
      v-if="qt_tabsheet > 0 && ic_filtro_pesquisa == 'N'"
      :data-source="tabs"
      :visible="true"
      :show-nav-buttons="true"
      :repaint-changes-only="true"
      :selected-index.sync="selectedIndex"
      :on-title-click="tabPanelTitleClick"
      item-title-template="title"
      item-template="itemTemplate"
    >
      <template #title="{ data: tab }">
        <div>
          <span>{{ tab.nm_label_tabsheet }}</span>
        </div>
      </template>

      <template v-if="!cd_menu_destino == 0" #itemTemplate="{ data: tab }">
        <componente
          v-if="qt_tabsheet > 0 && !cd_menu_destino == 0"
          :cd_menuID="cd_menu_destino"
          :cd_apiID="cd_api_destino"
          :tab-data="tab"
          slot="tab.nm_label_tabsheet"
          ref="componentetabsheet"
        />
      </template>
    </DxTabPanel>
    <transition name="slide-fade">
      <div
        v-if="
          dataSourceConfig !== undefined &&
          dataSourceConfig.length == 0 &&
          cd_empresa == 136
        "
        class="row"
      >
        <q-spinner-facebook class="col margin1" color="orange-9" size="6em" />
        <q-tooltip :offset="[0, 8]">Carregando...</q-tooltip>
      </div>
      <dx-data-grid
        v-if="
          dataSourceConfig !== undefined &&
          dataSourceConfig.length !== 0 &&
          ic_grid_card == 'G' &&
          cd_empresa == 136
        "
        class="dx-card wide-card"
        :data-source="dataSourceConfig"
        :columns="columns"
        :summary="total"
        key-expr="cd_controle"
        :show-borders="true"
        :focused-row-enabled="true"
        :column-auto-width="true"
        :column-hiding-enabled="true"
        :remote-operations="false"
        :word-wrap-enabled="false"
        :allow-column-reordering="true"
        :allow-column-resizing="false"
        :row-alternation-enabled="true"
        :repaint-changes-only="true"
        :autoNavigateToFocusedRow="true"
        :focused-row-index="0"
        :cacheEnable="false"
        @exporting="onExporting"
        @focused-row-changed="onFocusedRowChanged"
      >
        <template #master-detail="{ data }">
          <MasterDetail
            :cd_menuID="cd_menu_detalhe"
            :cd_apiID="cd_api_detalhe"
            :master-detail-data="data"
          />
        </template>
      </dx-data-grid>
      <div
        v-if="
          dataSourceConfig !== undefined &&
          dataSourceConfig.length !== 0 &&
          ic_grid_card == 'C' &&
          cd_empresa == 136
        "
      >
        <!-- Guarufilme -->
        <div v-if="cd_empresa == 136" style="display: flex; flex-wrap: wrap">
          <div
            class="margin1 umDecimoTela"
            v-for="(d, index) in dataSourceConfig"
            :key="index"
          >
            <q-card class="my-card">
              <q-card-section
                style="
                  margin: 0.2vw;
                  padding: 0px;
                  font-size: 1vw;
                  text-align: center;
                "
              >
                {{ `${d[0].nm_fantasia_vendedor}` }}
              </q-card-section>
              <q-card-section
                v-for="(c, index) in d"
                :key="index"
                class="borda-bloco"
                style="margin: 0.4vw; padding: 0px"
              >
                {{ `Família: ${c.nm_familia_produto}` }}<br />
                {{ `Qtd: ${c.qt_item_pedido.toFixed(2)} ` }}<br />
                {{ `Peso Líq: ${c.qt_peso_liquido_total.toFixed(2)}` }}<br />
                {{ `Peso Bruto: ${c.qt_peso_bruto_total.toFixed(2)}` }}<br />
              </q-card-section>
            </q-card>
          </div>
        </div>
      </div>
    </transition>

    <!-- Rodapé -->
    <div
      v-if="cd_empresa == 136"
      style="
        position: fixed;
        bottom: 0;
        width: 94%;
        height: auto;
        background-color: #fff;
      "
      class="margin1 shadow-2 borda-bloco"
    >
      <div class="row" v-for="(r, index) in dataSourceFooter" :key="index">
        <q-field dense class="col margin1" label="Família" stack-label>
          <template v-slot:control>
            <div class="self-center full-width no-outline" tabindex="0">
              {{ `${r.nm_familia_produto}` }}
            </div>
          </template>
          <template v-slot:prepend>
            <q-icon name="workspaces" />
          </template>
        </q-field>

        <q-field dense class="col margin1" label="Peso Líquido" stack-label>
          <template v-slot:control>
            <div class="self-center full-width no-outline" tabindex="0">
              {{ `${r.qt_peso_liquido_total}` }}
            </div>
          </template>
          <template v-slot:prepend>
            <q-icon name="table_rows" />
          </template>
        </q-field>

        <q-field dense class="col margin1" label="Peso Bruto" stack-label>
          <template v-slot:control>
            <div class="self-center full-width no-outline" tabindex="0">
              {{ `${r.qt_peso_bruto_total}` }}
            </div>
          </template>
          <template v-slot:prepend>
            <q-icon name="table_rows" />
          </template>
        </q-field>
      </div>
    </div>
    <!-- PopUp -->
    <div v-if="ativaPDF" class="q-pa-md q-gutter-sm">
      <q-btn label="Maximized" color="primary" @click="dialog = true" />

      <q-dialog
        v-model="ativaPDF"
        persistent
        :maximized="true"
        transition-show="slide-up"
        transition-hide="slide-down"
      >
        <q-card class="bg-primary text-white">
          <q-bar>
            <div class="div50">
              <label> DOCUMENTO </label>
            </div>
            <div class="div48">
              <q-btn
                dense
                flat
                icon="minimize"
                @click="maximizedToggle = false"
                :disable="!maximizedToggle"
              >
                <q-tooltip
                  v-if="maximizedToggle"
                  content-class="bg-white text-primary"
                  >Minimize</q-tooltip
                >
              </q-btn>
              <q-btn
                dense
                flat
                icon="crop_square"
                @click="maximizedToggle = true"
                :disable="maximizedToggle"
              >
                <q-tooltip
                  v-if="!maximizedToggle"
                  content-class="bg-white text-primary"
                  >Maximize</q-tooltip
                >
              </q-btn>
              <q-btn dense flat icon="close" v-close-popup>
                <q-tooltip content-class="bg-white text-primary"
                  >Close</q-tooltip
                >
              </q-btn>
            </div>
          </q-bar>
          <q-space />
        </q-card>
      </q-dialog>
    </div>

    <div v-if="popupData == true">
      <q-dialog v-model="popupData">
        <q-card>
          <q-card-section class="row items-center q-pb-none">
            <div class="text-h6">Seleção de Data</div>
            <q-space />
            <q-btn
              icon="close"
              @click="popClickData()"
              flat
              round
              dense
              v-close-popup
            />
          </q-card-section>

          <selecaoData :cd_volta_home="1"> </selecaoData>
        </q-card>
      </q-dialog>
    </div>
  </div>
</template>

<script>
//import { DxLoadPanel } from 'devextreme-vue/load-panel';

import {
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
  DxStateStoring,
  DxSearchPanel,
  DxEditing,
  DxPosition,
  DxMasterDetail,
  DxPopup,
} from "devextreme-vue/data-grid";

import DxButton from "devextreme-vue/button";
import DxTabPanel from "devextreme-vue/tab-panel";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";

import selecaoData from "../views/selecao-periodo.vue";
import funcao from "../http/funcoes-padroes";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import componente from "../views/display-componente";
import Incluir from "../http/incluir_registro";
import MasterDetail from "../views/MasterDetail";

import Lookup from "../http/lookup";
import formataData from "../http/formataData";

//import lookup from '../views/lookup';

//import periodo from '../views/selecao-periodo';

import "whatwg-fetch";

import Docxtemplater from "docxtemplater";

import PizZip from "pizzip";
import PizZipUtils from "pizzip/utils/index.js";
import DxSelectBox from "devextreme-vue/select-box";
import select from "../http/select";

function loadFile(url, callback) {
  PizZipUtils.getBinaryContent(url, callback);
}

DxSelectBox == true;

var dados = [];
var sParametroApi = "";

const dataGridRef = "dataGrid";

export default {
  data() {
    return {
      tituloMenu: "",
      menu: "",
      dt_inicial: "",
      dt_final: "",
      dt_base: "",
      columns: [],
      pageSizes: [10, 20, 50, 100],
      Parametro_JSON: [
        {
          cd_parametro: 0,
          cd_usuario: localStorage.cd_usuario,
        },
      ],
      dataSourceConfig: [],
      dataSourceHeader: [],
      dataSourceFooter: [],
      total: {},
      componentesMenu: {},
      refreshMode: "reshape",
      taskSubject: "Descritivo",
      taskDetails: "",
      temPanel: false,
      qt_tabsheet: 0,
      tabs: [],
      selectedIndex: 0,
      cd_menu_destino: 0,
      cd_api_destino: 0,
      cd_tipo_consulta: 0,
      allMode: "allPages",
      checkBoxesMode: "onClick",
      ic_filtro_pesquisa: "N",
      qt_tempo: 0,
      filtro: [],
      polling: null,
      arquivo_abrir: false,
      ativaPDF: false,
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_vendedor: 0,
      cd_menu: localStorage.cd_menu,
      cd_cliente: 0,
      cd_api: 0,
      api: 0,
      ds_arquivo: "",
      nm_documento: "",
      ds_menu_descritivo: "",
      popupData: false,
      periodoVisible: false,
      ic_grid_card: "C", //G - Grid | C - Card
      ic_form_menu: "N",
      ic_tipo_data_menu: "0",
      hoje: "",
      hora: "",
      formData: {},
      items: [],
      cd_tipo_email: 0,
      cd_relatorio: 1,
      qt_registro: 0,
      cd_detalhe: 0,
      cd_menu_detalhe: 0,
      cd_api_detalhe: 0,
      cd_identificacao: "",
      grid_linha_componente: "",
      dados_lookup: [],
      dados_lookup_natureza: [
        {
          cd_natureza_atributo: 1,
          nm_natureza_atributo: "Texto",
          vl_natureza_atributo: "text",
        },
        {
          cd_natureza_atributo: 2,
          nm_natureza_atributo: "Número",
          vl_natureza_atributo: "number",
        },
        {
          cd_natureza_atributo: 3,
          nm_natureza_atributo: "Senha",
          vl_natureza_atributo: "password",
        },
        {
          cd_natureza_atributo: 4,
          nm_natureza_atributo: "Hora",
          vl_natureza_atributo: "time",
        },
        {
          cd_natureza_atributo: 5,
          nm_natureza_atributo: "Data",
          vl_natureza_atributo: "date",
        },
      ],
      dataset_lookup: [],
      value_lookup: "",
      label_lookup: "",
      placeholder_lookup: "",
      selecionada_lookup: [],
      periodo: "",
    };
  },
  computed: {
    dataGrid: function () {
      return this.$refs[dataGridRef].instance;
    },
  },

  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;

    this.dt_inicial = localStorage.dt_inicial;
    this.dt_final = localStorage.dt_final;
    this.dt_base = localStorage.dt_base;
    this.periodoVisible = false;

    this.cd_vendedor = await funcao.buscaVendedor(this.cd_usuario);
    this.cd_vendedor.Cod == 0 ? (this.cd_vendedor = 0) : "";
    localStorage.cd_vendedor = this.cd_vendedor;

    this.hoje = "";
    this.hora = "";

    if (!this.qt_tempo == 0) {
      this.pollData();
      localStorage.polling = 1;
    }
  },

  async mounted() {
    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;
    this.carregaDados();
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
    DxButton,
    DxEditing,
    DxPosition,
    DxMasterDetail,
    DxPopup,
    MasterDetail,
    selecaoData,

    //  DxLoadPanel
  },

  methods: {
    popClickData() {
      if (this.popupData == false) {
        this.popupData = true;
      } else {
        this.popupData = false;
        if (this.qt_tabsheet == 0) {
          this.carregaDados();
        } else {
          this.$refs.componentetabsheet.carregaDados();
        }
      }
    },

    async showMenu() {
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      this.cd_menu_destino = 0;
      this.cd_api_destino = 0;
      localStorage.cd_parametro = 0;

      var dataI = new Date(localStorage.dt_inicial);
      var diaI = dataI.getDate().toString();
      var mesI = (dataI.getMonth() + 1).toString();
      var anoI = dataI.getFullYear();
      localStorage.dt_inicial = mesI + "-" + diaI + "-" + anoI;

      var dataF = new Date(localStorage.dt_final);
      var diaF = dataF.getDate().toString();
      var mesF = (dataF.getMonth() + 1).toString();
      var anoF = dataF.getFullYear();
      localStorage.dt_final = mesF + "-" + diaF + "-" + anoF;

      var dataB = new Date();
      var diaB = dataB.getDate().toString();
      var mesB = (dataB.getMonth() + 1).toString();
      var anoB = dataB.getFullYear();

      localStorage.dt_base = mesB + "-" + diaB + "-" + anoB;

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';
      //this.sParametroApi       = dados.nm_api_parametro;
      sParametroApi = dados.nm_api_parametro;
      let parametro_valor = JSON.parse(dados.nm_api_parametro_valor);
      if (this.cd_empresa === 136) {
        Object.keys(parametro_valor).map((e, index) => {
          if (!!parametro_valor[Object.keys(parametro_valor)[index]]) {
            if (e.startsWith("dt_")) {
              //Verifica as datas e formata
              let novaData = formataData.formataDataSQL(
                parametro_valor[Object.keys(parametro_valor)[index]]
              );
              let regexData = /([0-9]{2})\-([0-9]{2})\-([0-9]{4})/;
              regexData.test(novaData)
                ? (localStorage[e] =
                    parametro_valor[Object.keys(parametro_valor)[index]])
                : "";
            } else {
              localStorage[e] =
                parametro_valor[Object.keys(parametro_valor)[index]];
            }
          }
        });
      }
      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      this.qt_tabsheet = dados.qt_tabsheet;
      this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa;
      this.arquivo_abrir = false;
      this.ativaPDF = false;
      this.qt_tempo = dados.qt_tempo_menu;
      this.ds_menu_descritivo = dados.ds_menu_descritivo;
      this.ic_form_menu = dados.ic_form_menu;
      this.ic_tipo_data_menu = dados.ic_tipo_data_menu;
      this.cd_tipo_email = dados.cd_tipo_email;
      this.cd_detalhe = dados.cd_detalhe;
      this.cd_menu_detalhe = dados.cd_menu_detalhe;
      this.cd_api_detalhe = dados.cd_api_detalhe;

      //this.cd_relatorio       = dados.cd_relatorio;

      if (this.ic_tipo_data_menu == "1") {
        this.hoje = " - " + new Date().toLocaleDateString();
      }
      if (this.ic_tipo_data_menu == "2" || this.ic_tipo_data_menu == "3") {
        this.hora = new Date().toLocaleTimeString().substring(0, 5);
      }

      localStorage.cd_tipo_consulta = 0;

      if (!dados.cd_tipo_consulta == 0) {
        localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.menu = dados.nm_menu;

      //dados da coluna
      if (funcao.isJSON(dados.coluna)) {
        this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      }

      //dados do total
      if (funcao.isJSON(dados.coluna_total)) {
        this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      }
      //
      //dados dos componentes do menu
      if (funcao.isJSON(dados.componente)) {
        this.componentesMenu = JSON.parse(
          JSON.parse(JSON.stringify(dados.componente))
        );
      }
      //

      if (this.cd_empresa != 136) {
        await this.MontaComponente();
      }

      //TabSheet
      this.tabs = [];
      //

      if (!this.qt_tabsheet == 0) {
        if (funcao.isJSON(dados.TabSheet)) {
          this.tabs = JSON.parse(JSON.parse(JSON.stringify(dados.TabSheet)));
        }
        this.cd_menu_destino = parseInt(this.cd_menu);
        this.cd_api_destino = parseInt(this.cd_api);
      }
      //Filtros

      this.filtro = [];
      if (this.ic_filtro_pesquisa == "S") {
        if (funcao.isJSON(dados.Filtro)) {
          this.filtro = await JSON.parse(
            JSON.parse(JSON.stringify(dados.Filtro))
          );
        }

        if (!!this.filtro[0].cd_tabela == false) {
          this.dados_lookup = await Lookup.montarSelect(
            this.cd_empresa,
            dados.cd_tabela
          );
        } else {
          this.dados_lookup = await Lookup.montarSelect(
            this.cd_empresa,
            this.filtro[0].cd_tabela
          );
        }
        if (!!this.dados_lookup != false) {
          if (funcao.isJSON(this.dados_lookup.dataset)) {
            this.dataset_lookup = JSON.parse(
              JSON.parse(JSON.stringify(this.dados_lookup.dataset))
            );
          }

          this.value_lookup = this.filtro[0].nm_campo_chave_lookup;
          this.label_lookup = this.filtro[0].nm_campo;
          this.placeholder_lookup = this.filtro[0].nm_campo_descricao_lookup;
        }
      }
    },

    async MontaComponente() {
      this.componentesMenu.map(async (e, index) => {
        let [natureza] = this.dados_lookup_natureza.filter(
          (i) => i.cd_natureza_atributo === e.cd_natureza_atributo
        );
        if (funcao.isJSON(e.dataset_tabela)) {
          e.dataset_tabela = JSON.parse(
            JSON.parse(JSON.stringify(e.dataset_tabela))
          );
        }
        if (e.cd_api && e.cd_componente !== 6 && !e.cd_tabela) {
          //Se não for tabela é Procedure e pode ser de JSON ou de parâmetro
          if (e.ic_procedimento_crud == "S") {
            //Recebe um JSON de parametro
            try {
              var [result_pr_json] = await Incluir.incluirRegistro(
                e.cd_api,
                this.Parametro_JSON
              );
            } catch {
              console.error("Erro no componente procedure");
            }
          } else {
            //Recebe parametros individuais
            e.colunas_web = JSON.parse(
              JSON.parse(JSON.stringify(e.colunas_web))
            );
            e.colunas_web.map((e) => {
              e.isBand = e.isBand === "true" ? true : false;
              e.visible = e.visible === "true" ? true : false;
              e.formItem = e.formItem ? JSON.parse(e.formItem) : "";
            });
            try {
              var result_pr = await Procedimento.montarProcedimento(
                this.cd_empresa,
                this.cd_cliente,
                e.nm_api_busca,
                e.nm_api_parametro
              );
            } catch {
              console.error("Erro no componente parametro");
            }
          }
        }

        this.componentesMenu[index] = {
          ...e,
          ...natureza,
          nm_valor: e.cd_componente == 3 ? false : "",
          options: e.dataset_tabela ? e.dataset_tabela : null,
          procedure_json: result_pr_json ? result_pr_json : null,
          procedure_parametro: result_pr ? result_pr : null,
        };
        this.$mount();
      });
    },

    async onValor(e, item) {
      this.$mount();
      if (e === "button") {
        if (item.ic_grid_componente === "t") {
          //Componente
          let componentes = this.componentesMenu.map((o) => ({
            cd_menu_web: o.cd_menu_web,
            cd_menu: o.cd_menu,
            ic_procedimento_crud: o.ic_procedimento_crud,
            nm_api_parametro: o.nm_api_parametro,
            nm_natureza_atributo: o.nm_natureza_atributo,
            vl_natureza_atributo: o.vl_natureza_atributo,
            nm_valor: o.nm_valor,
          }));
          var [result_pr_componente] = await Incluir.incluirRegistro(
            "839/1316", //item.cd_api, pr_api_egisnet_funcoes
            {
              cd_usuario: this.cd_usuario,
              cd_empresa: this.cd_empresa,
              cd_parametro: 0,
              cd_api: item.cd_api,
              cd_menu_web: item.cd_menu_web,
              JSON_parametros: componentes,
            }
          );
          notify(result_pr_componente.Msg);
          await this.carregaDados();
        } else {
          //Tabela
          var [result_pr_tabela] = await Incluir.incluirRegistro(
            "839/1316", //item.cd_api, pr_api_egisnet_funcoes
            {
              cd_usuario: this.cd_usuario,
              cd_empresa: this.cd_empresa,
              cd_parametro: 0,
              cd_api: item.cd_api,
              cd_menu_web: item.cd_menu_web,
              JSON_parametros: [this.grid_linha_componente],
            }
          );
          notify(result_pr_tabela.Msg);
          await this.carregaDados();
        }
      }
    },

    pollData: function () {
      if (this.qt_tempo > 0) {
        this.polling = setInterval(() => {
          this.carregaDados();
        }, this.qt_tempo);
      }
    },

    handleSubmit: function (e) {
      notify(
        {
          message: "Você precisa confirmar os Dados para pesquisa !",
          position: {
            my: "center top",
            at: "center top",
          },
        },
        "success",
        1000
      );
      e.preventDefault();
    },

    tabPanelTitleClick: function (e) {
      this.selectedIndex = e.itemIndex;

      //if(this.selectedIndex == 0){
      //this.$refs.componentetabsheet.limpaDados();
      //}

      this.cd_menu_destino = this.tabs[this.selectedIndex].cd_menu_composicao;
      this.cd_api_destino = this.tabs[this.selectedIndex].cd_api;
      this.cd_parametro = localStorage.cd_parametro;

      this.cd_tipo_consulta = dados.cd_tipo_consulta;

      this.$refs.componentetabsheet.carregaDados();
    },

    onTableRowChange: function (e) {
      this.grid_linha_componente = e.row && e.row.data;
    },
    //
    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;

      // this.taskSubject = data && data.ds_informativo;
      this.taskDetails = data && data.ds_informativo;
      this.ds_arquivo = data && data.ds_arquivo;
      this.nm_documento = data && data.nm_documento;

      //this.focusedRowKey = e.component.option('focusedRowKey');
    },

    async carregaDados() {
      localStorage.cd_identificacao = 0;
      await this.showMenu();

      this.temPanel = true;

      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);

      localStorage.dt_base == "NaN-NaN-NaN"
        ? (localStorage.dt_base = localStorage.dt_inicial)
        : "";

      if (!this.qt_tabsheet == 0 && this.cd_empresa == 136) {
        let sApis = sParametroApi;

        if (!sApis == "") {
          try {
            this.dataSourceConfig = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_cliente,
              this.api,
              sApis
            );

            this.dataSourceConfig.map((i) => {
              i.columns = { ...this.columns };
            });
            if (this.dataSourceConfig !== undefined) {
              this.qt_registro = this.dataSourceConfig.length;
              this.formData = this.dataSourceConfig[0];
              if (funcao.isJSON(dados.labelForm)) {
                this.items = JSON.parse(dados.labelForm);
              }
            }
          } catch (error) {
            console.error(error);
          }
        }
      }

      if (this.qt_tabsheet == 0 && this.cd_empresa == 136) {
        //Gera os Dados para Montagem da Grid
        //exec da procedure
        let sApi = sParametroApi;
        if (!sApi == "") {
          !!this.cd_identificacao == true
            ? (localStorage.cd_identificacao = this.cd_identificacao)
            : "";
          try {
            this.dataSourceConfig = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_cliente,
              this.api,
              sApi
            );
            if (this.dataSourceConfig !== undefined) {
              this.dataSourceConfig.map((i) => {
                i.columns = this.columns;
              });

              //Agrupa por PARAMETRO (cd_vendedor)
              this.dataSourceConfig = this.dataSourceConfig.reduce(
                (acc, item) => {
                  if (item["cd_vendedor"] !== 0) {
                    if (!acc[item["cd_vendedor"]])
                      acc[item["cd_vendedor"]] = [];
                    acc[item["cd_vendedor"]].push(item);
                  }
                  return acc;
                },
                {}
              );

              this.qt_registro = this.dataSourceConfig.length;

              this.formData = this.dataSourceConfig[0];

              if (funcao.isJSON(dados.labelForm)) {
                this.items = JSON.parse(dados.labelForm);
              }
            }
          } catch (error) {
            console.error(error);
          }
        }
      }

      if (this.cd_empresa == 136) {
        let sApi = sParametroApi;
        try {
          ////Montar Header
          this.dataSourceHeader = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            "833/1310", //this.api,
            "/${dt_base}"
          );
        } catch {
          console.error("Não gerou Header");
        }
        if (this.dataSourceHeader.length !== 0) {
          this.dataSourceHeader.map(async (f) => {
            f.Qt_Meta_Mes = f.Qt_Meta_Mes.toFixed(2);
            f.QTMetaDia = f.QTMetaDia.toFixed(2);
          });
        }

        try {
          ////Montar Footer
          localStorage.cd_parametro = 1;
          this.dataSourceFooter = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            this.api,
            sApi
          );
          if (this.dataSourceFooter.length !== 0) {
            this.dataSourceFooter.map(async (f) => {
              f.qt_peso_liquido_total = f.qt_peso_liquido_total.toFixed(2);
              f.qt_peso_bruto_total = f.qt_peso_bruto_total.toFixed(2);
            });
          }
        } catch {
          console.error("Não gerou Footer");
        }
      }
    },

    async onClick() {
      this.dataSourceConfig = [];
      if (this.selecionada_lookup != null) {
        localStorage.cd_filtro =
          this.selecionada_lookup[this.filtro[0].nm_campo_chave_lookup];
        await this.carregaDados();
      } else {
        localStorage.cd_filtro = 0;
        await this.carregaDados();
      }
    },

    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Consulta");

      exportDataGrid({
        component: e.component,
        worksheet: worksheet,
        autoFilterEnabled: true,
      }).then(function () {
        // https://github.com/exceljs/exceljs#writing-xlsx
        workbook.xlsx.writeBuffer().then(function (buffer) {
          saveAs(
            new Blob([buffer], { type: "application/octet-stream" }),
            filename
          );
        });
      });
      e.cancel = true;
    },

    beforeDestroy() {
      clearInterval(this.polling);
    },

    destroyed() {
      this.$destroy();
    },

    renderDoc() {
      //loadFile("http://egisnet.com.br/template/template_GBS.docx", function(
      loadFile(
        "/Template_GBS.docx",
        function (
          //loadFile("https://docxtemplater.com/tag-example.docx", function(
          error,
          content
        ) {
          if (error) {
            alert("não encontrei o template.docx");
            throw error;
          }
          var zip = new PizZip(content);
          var doc = new Docxtemplater(zip);

          doc.setData(
            dados

            //{
            //  dt_hoje: '26/04/2021',
            //  nm_menu_titulo: 'tÃ­tulo do menu',
            //  nm_identificacao_api: 'endereÃ§o da api'
            //
            // }
          );

          try {
            // render the document (replace all occurences of {first_name} by John, {last_name} by Doe, ...)
            doc.render();
          } catch (error) {
            // The error thrown here contains additional information when logged with JSON.stringify (it contains a properties object containing all suberrors).

            if (error.properties && error.properties.errors instanceof Array) {
              const errorMessages = error.properties.errors
                .map(function (error) {
                  return error.properties.explanation;
                })
                .join("\n");
              // errorMessages is a humanly readable message looking like this :
              // 'The tag beginning with "foobar" is unopened'
            }
            throw error;
          }
          var out = doc.getZip().generate({
            type: "blob",
            mimeType:
              "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
          });
          //Output the document using Data-URI
          saveAs(out, filenamedoc);
        }
      );
    },
  },
};
</script>
<style scoped>
@import url("./views.css");

#parametro {
  margin-top: 5px;
  padding-top: 5px;
}

form {
  margin-left: 10px;
  margin-right: 10px;
  padding-left: 10px;
  padding-right: 10px;
  margin-top: 5px;
}

.info {
  margin-right: 40px;
}

.option {
  margin-top: 10px;
  margin-right: 40px;
  display: inline-block;
}

.option:last-child {
  margin-right: 0;
}

.option > .dx-numberbox {
  width: 200px;
  display: inline-block;
  vertical-align: middle;
}

.option > span {
  margin-right: 10px;
}

.botao-info {
  float: right;
  right: 10px;
}
.info-periodo {
  margin-top: 10px;
  float: right;
  margin-right: 25px;
  right: 10px;
  font-size: 16px;
}

#grid-padrao {
  max-height: 600px !important;
}
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

.tituloHeader {
  height: 6vh;
  margin: 0px;
  padding: 0px;
}

.tituloTexto {
  display: flex;
  justify-content: flex-start;
  align-items: center;
  height: 2vh;
}

.my-card {
  display: block;
  border: 2px solid orange;
  font-weight: 600;
  font-size: 0.9vw;
  margin: 0px;
  padding: 0px;
  width: 100%;
  height: 100%;
}
.umDecimoTela {
  width: calc(100% / 10);
  height: 41vh;
}

@media (max-width: 900px) {
  .umDecimoTela {
    width: calc(100% / 5);
  }
}

@media (max-width: 500px) {
  .umDecimoTela {
    width: 100%;
  }
}
</style>
