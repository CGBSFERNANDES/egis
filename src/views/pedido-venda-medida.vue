<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center">
      <btnVoltarHome />
      <transition name="slide-fade">
        <h2 class="content-block col-8" v-show="!!tituloMenu != false">
          {{ tituloMenu }}
          <q-badge
            v-if="qt_registro > 0"
            align="middle"
            rounded
            color="red"
            :label="qt_registro"
          />
        </h2>
      </transition>
    </div>
    <!-- Cliente -->
    <div v-if="cd_modulo != 220" class="margin1">
      <cliente
        :cd_usuario="cd_usuario"
        @SelectCliente="SelecionaCliente($event)"
        @limpaCliente="cleanCliente($event)"
        :ic_pesquisa="true"
        :ic_pesquisa_contato="false"
      />
    </div>
    <!-- Cliente -->
    <div class="row">
      <q-input
        class="margin1 col-2 opcoes"
        rounded
        outlined
        stack-label
        mask="##/##/####"
        v-model="dt_inicial"
        label="Data Inicial"
        @blur="carregaDados()"
      >
        <template v-slot:prepend>
          <q-icon name="event"></q-icon>
        </template>
      </q-input>
      <q-input
        class="margin1 col-2 opcoes"
        rounded
        outlined
        stack-label
        mask="##/##/####"
        v-model="dt_final"
        label="Data Final"
        @blur="carregaDados()"
      >
        <template v-slot:prepend>
          <q-icon name="event"></q-icon>
        </template>
      </q-input>
      <div class="margin1">
        <q-btn-dropdown
          rounded
          color="primary"
          :label="`Total ${this.vl_liquido_formatado}`"
        >
          <q-list class="text-weight-bold">
            <q-item clickable v-close-popup>
              <q-item-section>
                <q-item-label>{{ `Produtos` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{ `${this.dataCesta.length}` }}</q-item-label>
              </q-item-section>
            </q-item>

            <q-item clickable v-close-popup>
              <q-item-section>
                <q-item-label>{{ `Total Produto` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{
                  `${this.vl_total_produto_formatado.toLocaleString("pt-BR", {
                    style: "currency",
                    currency: "BRL",
                  })}`
                }}</q-item-label>
              </q-item-section>
            </q-item>

            <q-item clickable v-close-popup>
              <q-item-section>
                <q-item-label>{{ `Imposto` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{
                  `${this.vl_imposto.toLocaleString("pt-BR", {
                    style: "currency",
                    currency: "BRL",
                  })}`
                }}</q-item-label>
              </q-item-section>
            </q-item>

            <q-item clickable v-close-popup>
              <q-item-section>
                <q-item-label>{{ `Total` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{
                  `${this.valor_formatado.toLocaleString("pt-BR", {
                    style: "currency",
                    currency: "BRL",
                  })}`
                }}</q-item-label>
              </q-item-section>
            </q-item>

            <q-item
              v-if="vl_desconto_pedido"
              style="color: red"
              clickable
              v-close-popup
            >
              <q-item-section>
                <q-item-label>{{ `Desconto` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{
                  `${this.vl_desconto_pedido.toLocaleString("pt-BR", {
                    style: "currency",
                    currency: "BRL",
                  })}`
                }}</q-item-label>
              </q-item-section>
            </q-item>

            <q-item
              v-if="valor_liquido"
              style="color: red"
              clickable
              v-close-popup
            >
              <q-item-section>
                <q-item-label>{{ `Líquido` }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label>{{
                  `${this.valor_liquido.toLocaleString("pt-BR", {
                    style: "currency",
                    currency: "BRL",
                  })}`
                }}</q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
        </q-btn-dropdown>
      </div>

      <div>
        <q-btn
          round
          class="margin1"
          color="red"
          text-color="white"
          icon="delete"
          @click="onCancelar()"
        >
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            Cancelar
          </q-tooltip>
        </q-btn>
        <q-btn
          round
          class="margin1"
          color="orange-9"
          text-color="white"
          icon="print"
          :loading="loadingPDF"
          @click="onPDF()"
        >
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            Gerar PDF
          </q-tooltip>
        </q-btn>
        <transition name="slide-fade">
          <q-btn
            v-if="dataCesta.length > 0"
            round
            class="margin1"
            color="pink-5"
            text-color="white"
            icon="view_list"
            @click="ic_detalhe_medida = true"
          >
            <q-tooltip
              anchor="bottom middle"
              self="top middle"
              :offset="[10, 10]"
            >
              Detalhes
            </q-tooltip>
          </q-btn>
        </transition>
        <q-btn
          round
          class="margin1"
          color="green"
          text-color="white"
          icon="description"
          @click="onEnviarPedido()"
        >
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            Enviar Pedido
          </q-tooltip>
        </q-btn>
      </div>
    </div>
    <!-- Grid -->
    <div v-if="loadingDataSourceConfig == true" class="row">
      <q-spinner-facebook class="col margin1" color="orange-9" size="6em" />
      <q-tooltip :offset="[0, 8]">Carregando...</q-tooltip>
    </div>
    <div v-else>
      <transition name="slide-fade">
        <dx-data-grid
          id="gridPadrao"
          ref="gridPadrao"
          class="margin1 dx-card wide-card-gc"
          :data-source="dataSourceConfig"
          :columns="columns"
          :summary="total"
          key-expr="cd_controle"
          :selection="{ mode: 'single' }"
          :show-borders="true"
          :focused-row-enabled="true"
          :column-auto-width="true"
          :column-hiding-enabled="false"
          :remote-operations="false"
          :word-wrap-enabled="false"
          :allow-column-reordering="true"
          :allow-column-resizing="true"
          :row-alternation-enabled="false"
          :repaint-changes-only="true"
          :autoNavigateToFocusedRow="true"
          :cacheEnable="false"
          @initialized="onInitializedGrid"
          @exporting="onExporting"
          @selection-changed="onSelectionChanged"
        >
          <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

          <DxEditing
            :allow-updating="true"
            :allow-adding="false"
            :allow-deleting="false"
            :select-text-on-edit-start="true"
            mode="batch"
          />

          <DxMasterDetail
            v-if="masterDetail == true"
            :enabled="true"
            template="masterDetailTemplate"
          />

          <template #masterDetailTemplate="{ data: dataSourceConfig }">
            {{ dataSourceConfig.data }}
          </template>

          <DxGrouping :auto-expand-all="true" v-if="filterGrid == true" />
          <DxExport :enabled="true" v-if="filterGrid == true" />

          <DxPaging :enable="true" :page-size="10" />

          <DxStateStoring
            :enabled="true"
            type="localStorage"
            storage-key="storage"
          />
          <DxSelection mode="multiple" />
          <DxPager
            :show-page-size-selector="true"
            :allowed-page-sizes="pageSizes"
            :show-info="true"
          />
          <DxFilterRow :visible="false" v-if="filterGrid == true" />
          <DxHeaderFilter
            :visible="true"
            :allow-search="true"
            :width="400"
            v-if="filterGrid == true"
            :height="400"
          />
          <DxSearchPanel
            :visible="true"
            :width="300"
            placeholder="Procurar..."
            v-if="filterGrid == true"
          />
          <DxFilterPanel :visible="true" v-if="filterGrid == true" />
          <DxColumnFixing :enabled="false" v-if="filterGrid == true" />
          <DxColumnChooser
            :enabled="true"
            mode="select"
            v-if="filterGrid == true"
          />
        </dx-data-grid>
      </transition>
    </div>
    <q-dialog v-if="!complemento_impressao" maximized persistent>
      <carregando :corID="'orange-9'" mensagemID="Aguarde..."></carregando>
    </q-dialog>
    <q-dialog
      v-model="ic_detalhe_medida"
      persistent
      maximized
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card v-for="(item, index) in dataCesta" :key="index">
        <q-bar class="bg-deep-orange-9 text-white">
          <q-space />
          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-white text-primary"
              >Minimizar</q-tooltip
            >
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-white text-primary"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-white text-primary">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section>
          <div class="text-h6">
            {{
              `Dados Técnicos - Pedido de Venda ${item.cd_pedido_venda} - Cliente: ${item.nm_fantasia_cliente}`
            }}
          </div>
        </q-card-section>

        <q-card-section class="margin1 row">
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Pedido"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.cd_pedido_venda}` }}
              </div>
            </template>
          </q-field>

          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Item"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.cd_item_pedido_venda}` }}
              </div>
            </template>
          </q-field>

          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Cliente"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.nm_fantasia_cliente}` }}
              </div>
            </template>
          </q-field>

          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Cód Cliente"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.cd_cliente}` }}
              </div>
            </template>
          </q-field>

          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Condição de Pagamento"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.nm_condicao_pagamento}` }}
              </div>
            </template>
          </q-field>

          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Tabela de Preço"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.sg_tabela_preco}` }}
              </div>
            </template>
          </q-field>

          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Vendedor"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.nm_fantasia_vendedor}` }}
              </div>
            </template>
          </q-field>

          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Tipo"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.nm_tipo_pedido}` }}
              </div>
            </template>
          </q-field>
        </q-card-section>
        <q-separator />
        <q-card-section class="row margin1">
          <div class="title-description col-12">Produto</div>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Produto"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.nm_produto}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Un."
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.nm_unidade_medida}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Código"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.cd_produto}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Família"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.nm_familia_produto}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Categoria"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.nm_categoria_produto}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Item"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.cd_item_pedido_venda}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Qtd. p/ Cx"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.qt_peso_bruto_total}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Preço Tabela"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.vl_lista_item_pedido}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Volumes"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.qt_item_pedido_venda}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Quantidade"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.qt_item_pedido_venda}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Preço"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.vl_unitario_item_pedido}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Produto Un."
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.qt_item_pedido_venda}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col-2 margin1"
            rounded
            standout
            label="Vol. Prod"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.qt_item_pedido_venda}` }}
              </div>
            </template>
          </q-field>
        </q-card-section>
        <q-separator />
        <q-card-section class="row margin1">
          <div class="title-description col-12">Medidas para Cálculo</div>
          <q-field
            class="col margin1"
            rounded
            standout
            label="LARGURA"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.qt_largura}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="ESPESSURA"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.qt_espessura}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="COMPRIMENTO"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.qt_comprimento}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="Peso Unitário"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.qt_peso_liquido_total}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="Preço por KG"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.vl_fator_quilo}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="Observações Ordem de Produção"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.nm_observacao_fabrica1}` }}
              </div>
            </template>
          </q-field>
        </q-card-section>
        <q-separator />
        <q-card-section class="row margin1">
          <div class="title-description col-12">Pesos e Totais</div>
          <q-field
            class="col margin1"
            rounded
            standout
            label="Densidade"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${0}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="PESO LÍQUIDO"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.qt_peso_liquido_total}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="PESO BRUTO"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.qt_peso_bruto_total}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="TOTAL ITEM"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.vl_total_geral_liquido}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="TOTAL ITEM C/ IPI"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.vl_total_geral}` }}
              </div>
            </template>
          </q-field>
        </q-card-section>
        <q-separator />
        <q-card-section class="row margin1">
          <q-field
            class="col margin1"
            rounded
            standout
            label="IPI (%)"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.pc_ipi}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="IPI (Valor)"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.vl_item_ipi}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="Vendedor"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.nm_fantasia_vendedor}` }}
              </div>
            </template>
          </q-field>
          <q-field
            class="col margin1"
            rounded
            standout
            label="Comissão"
            stack-label
          >
            <template v-slot:control>
              <div class="self-center full-width no-outline" tabindex="0">
                {{ `${item.pc_comissao_item_pedido}` }}
              </div>
            </template>
          </q-field>
        </q-card-section>
        <q-separator />
        <q-card-actions align="right">
          <q-btn
            flat
            label="Fechar"
            icon="close"
            color="primary"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>
  
  <script>
import {
  DxDataGrid,
  DxFilterRow,
  DxPager,
  DxPaging,
  DxExport,
  DxGroupPanel,
  DxEditing,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxSelection,
  DxStateStoring,
  DxMasterDetail,
  DxSearchPanel,
} from "devextreme-vue/data-grid";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import funcao from "../http/funcoes-padroes";
import Incluir from "../http/incluir_registro";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import formataData from "../http/formataData";
import notify from "devextreme/ui/notify";

var dados = [];
let filename = "DataGrid.xlsx";
var sParametroApi = "";

export default {
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_cliente: localStorage.cd_cliente,
      cd_modulo: localStorage.cd_modulo,
      cd_menu: localStorage.cd_menu,
      cd_api: localStorage.cd_api,
      api: "",
      maximizedToggle: true,
      //Somas
      valor: 0,
      valor_formatado: 0,
      vl_imposto: 0,
      vl_liquido: 0,
      vl_liquido_formatado: 0,
      vl_total_produto: 0,
      vl_total_produto_formatado: 0,
      valor_liquido: 0,
      qtd: 0,
      vl_desconto_pedido: 0,
      //////////////////////
      ic_detalhe_medida: false,
      loadingPDF: false,
      loadingDataSourceConfig: false,
      masterDetail: false,
      filterGrid: true,
      complemento_impressao: false,
      pageSizes: [10, 20, 50, 100],
      data_hoje: new Date(),
      dataSourceConfig: [],
      dataCesta: [],
      qt_registro: "",
      columns: [],
      total: {},
      tituloMenu: "",
      dt_inicial: "",
      dt_final: "",
    };
  },

  components: {
    DxDataGrid,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxEditing,
    DxGrouping,
    DxColumnChooser,
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxSelection,
    DxStateStoring,
    DxMasterDetail,
    DxSearchPanel,
    carregando: () => import("../components/carregando.vue"),
    cliente: () => import("../views/cliente.vue"),
    btnVoltarHome: () => import("../components/btnVoltarHome.vue"),
  },

  async created() {
    this.dt_inicial = formataData.formataDataSQL(localStorage.dt_inicial);
    this.dt_final = formataData.formataDataSQL(localStorage.dt_final);
    this.carregaDados();
  },

  async beforeRouteLeave(to, from, next) {
    if (this.$refs.gridPadrao) {
      setTimeout(async () => {
        await this.$refs.gridPadrao.instance.clearSelection();
        await this.$refs.gridPadrao.instance.clearFilter();
      }, 1);
    }
    next();
  },

  computed: {
    gridPadrao() {
      return this.$refs["gridPadrao"].instance;
    },
  },

  watch: {
    dataCesta() {
      this.vl_liquido = this.dataCesta.reduce(
        (acc, curr) => (
          (acc += curr.qt_item_pedido_venda * curr.vl_total), acc
        ),
        0
      );
      this.vl_total_produto_formatado = this.dataCesta.reduce(
        (acc, curr) => (
          (acc += curr.qt_item_pedido_venda * curr.vl_total), acc
        ),
        0
      );
      this.vl_imposto = this.dataCesta.reduce(
        (acc, curr) => (
          (acc +=
            ((curr.qt_item_pedido_venda * curr.vl_total) / 100) * curr.pc_icms +
            ((curr.qt_item_pedido_venda * curr.vl_total) / 100) * curr.pc_ipi),
          acc
        ),
        0
      );
      this.valor_formatado = this.vl_liquido + this.vl_imposto;
      this.vl_desconto_pedido = this.dataCesta.reduce(
        (acc, curr) => (
          (acc +=
            ((curr.qt_item_pedido_venda * curr.vl_total) / 100) *
            curr.pc_desconto_item_pedido),
          acc
        ),
        0
      );
      this.valor_liquido =
        this.vl_liquido - this.vl_imposto - this.vl_desconto_pedido;
      this.vl_liquido_formatado = this.vl_liquido.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
    },
  },

  methods: {
    async carregaDados(showNotify) {
      localStorage.cd_identificacao = 0;
      await this.showMenu();
      if (!showNotify) {
        notify("Aguarde... estamos montando a consulta para você!");
      }
      //Busca dt_inicial de 2 anos atrás (Guarufilme)
      var PegaData = new Date();
      //var dia = String(PegaData.getDate()).padStart(2, "0");
      var mes = String(PegaData.getMonth() + 1).padStart(2, "0");
      var ano = PegaData.getFullYear() - 2;
      const atual = `${mes}-01-${ano}`;
      localStorage.dt_inicial = atual;
      let sApis = sParametroApi;
      if (!sApis == "") {
        try {
          this.loadingDataSourceConfig = true;
          this.dataSourceConfig = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            this.api,
            sApis
          );
          this.loadingDataSourceConfig = false;
        } catch (error) {
          this.loadingDataSourceConfig = false;
          // eslint-disable-next-line no-console
          console.error(error);
        }

        this.qt_registro = this.dataSourceConfig.length;
      }
    },
    async showMenu() {
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      localStorage.cd_parametro = 0;

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';

      sParametroApi = dados.nm_api_parametro;

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      //this.menu = dados.nm_menu;
      filename = this.tituloMenu + ".xlsx";
      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      this.columns.map((e) => {
        e.encodeHtml = false;
        if (e.dataField == "qt_digitacao") {
          e.allowEditing = true;
        } else {
          e.allowEditing = false;
        }
      });
      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //
    },
    async onEnviarPedido() {
      if (this.dataCesta.length > 0) {
        var json_envia_pedido = {
          dt_inicial: this.dt_inicial,
          dt_final: this.dt_final,
          cd_cliente: this.cd_cliente,
          cd_usuario: this.cd_usuario,
          cd_contato: localStorage.cd_contato,
          grid: this.dataCesta,
        };
        let [result_pedido] = await Incluir.incluirRegistro(
          "927/1437", //this.api,
          json_envia_pedido
        ); //pr_geracao_pedido_venda_medida
        if (result_pedido != undefined && result_pedido.cd_consulta) {
          notify(`Proposta ${result_pedido.cd_consulta} enviada com sucesso`);
        } else if (result_pedido.Msg) {
          notify(`${result_pedido.Msg}`);
        } else {
          notify("Não foi possível enviar a proposta");
        }
        await this.onCancelar();
        this.carregaDados(true);
      } else {
        notify("Selecione pelo menos um item");
      }
    },
    async onCancelar() {
      await this.carregaDados();
      this.dataCesta = [];
      this.complemento_impressao = false;
      this.limpaTotais();
    },
    async SelecionaCliente(e) {
      this.cd_cliente = e.cd_cliente;
      localStorage.cd_cliente = e.cd_cliente;
      await this.carregaDados();
    },
    cleanCliente() {
      this.forma_pagamento = "";
      this.condicao_pagamento = "";
      this.transportadora = "";
      this.dataSourceConfig = [];
      this.dataCesta = [];
      this.qt_registro = 0;
      this.limpaTotais();
    },
    async onPDF() {
      await funcao.sleep(1);
      if (this.dataCesta.length > 0) {
        try {
          this.complemento_impressao = true;
          //this.dt_inicial = formataData.DiaMesAno(this.dt_inicial)
          //this.dt_final = formataData.DiaMesAno(this.dt_final)
          await funcao.sleep(1000);
          this.loadingPDF = true;
          let html = document.getElementById("cesta");
          //Configura o PDF que será baixado.
          let config = {
            orientation: "p",
            unit: "mm",
            format: [1480, 1880], //y 1480
            putOnlyUsedFonts: false,
            nm_pdf: this.tituloMenu,
          };
          //Cria o documento PDF
          await funcao.ExportHTML(html, "A", config);
          this.loadingPDF = false;
          await funcao.sleep(10);
          this.complemento_impressao = false;
        } catch {
          this.complemento_impressao = false;
        }
        //this.dt_inicial = formataData.AnoMesDia(localStorage.dt_inicial);
        //this.dt_final = formataData.AnoMesDia(localStorage.dt_final);
      } else {
        notify("Insira pelo menos um item para gerar o relatório");
      }
    },
    onSelectionChanged(e) {
      this.dataCesta = e.selectedRowsData;
    },
    limpaTotais() {
      this.valor = 0;
      this.qtd = 0;
      this.valor_liquido = 0;
      this.valor_formatado = 0;
      this.vl_total_produto = 0;
      this.vl_total_produto_formatado = 0;
      this.vl_imposto = 0;
      this.vl_liquido = 0;
      this.vl_liquido_formatado = 0;
      this.vl_desconto_pedido = 0;
    },
    async onInitializedGrid() {
      setTimeout(async () => {
        await this.$refs.gridPadrao.instance.clearSelection();
        await this.$refs.gridPadrao.instance.clearFilter();
      }, 1);
    },
    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Employees");

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
  },
};
</script>
  
  <style scoped>
@import url("./views.css");
.card-cesta {
  display: flex;
  flex-wrap: wrap;
  font-weight: bold;
}

.title-description {
  display: block;
  font-weight: bold;
  font-size: large;
}

.opcoes {
  display: flex;
  flex-wrap: wrap;
  width: calc(100% / 8);
}

@media (max-width: 800px) {
  .opcoes {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
  }
}
</style>
  