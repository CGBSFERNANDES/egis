<template>
  <div style="background: white">
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center">
      <transition name="slide-fade">
        <h2 class="content-block col-8" v-show="!!tituloMenu != false">
          {{ tituloMenu }}
        </h2>
      </transition>
    </div>

    <div>
      <q-tabs
        v-model="abas"
        class="bg-orange-9 text-white margin1"
        style="border-radius: 20px"
        inline-label
      >
        <q-tab class="margin1" name="0" icon="receipt_long" label="Consulta">
          <q-badge v-if="qt_registro > 0" color="red">{{
            `${qt_registro}`
          }}</q-badge>
        </q-tab>
        <q-tab class="margin1" name="1" icon="account_tree" label="Cadastro">
        </q-tab>
        <q-tab class="margin1" name="2" icon="settings" label="Configurações">
        </q-tab>
      </q-tabs>
    </div>

    <q-tab-panels v-model="abas" animated>
      <q-tab-panel name="0">
        <div class="row">
          <q-btn
            color="orange-9"
            icon="add"
            style="float: left"
            class="margin1"
            rounded
            label="Novo"
            @click="NovaAtividade()"
          >
            <q-tooltip> Nova Atividade </q-tooltip>
          </q-btn>
        </div>
        <dx-data-grid
          id="grid-padrao"
          class="dx-card wide-card-gc margin1"
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
          :row-alternation-enabled="false"
          :repaint-changes-only="true"
          :autoNavigateToFocusedRow="true"
          :cacheEnable="false"
          @focused-row-changed="onFocusedRowChanged"
          @selection-Changed="TrocaLinha"
          @row-dbl-click="DBClick($event.data)"
          @row-removed="RemoveAtividade"
        >
          <DxEditing
            style="margin: 0; padding: 0"
            :allow-updating="false"
            :allow-adding="false"
            :allow-deleting="true"
            mode="cell"
          />
          <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

          <DxMasterDetail
            v-if="masterDetail == true"
            :enabled="true"
            template="masterDetailTemplate"
          />

          <template #masterDetailTemplate="{ data: dataSourceConfig }">
            {{ dataSourceConfig.data }}
          </template>

          <DxGrouping :auto-expand-all="true" />
          <DxExport :enabled="true" />

          <DxPaging :enable="true" :page-size="10" />

          <DxStateStoring
            :enabled="true"
            type="localStorage"
            storage-key="storage"
          />
          <DxSelection mode="single" />
          <DxPager
            :show-page-size-selector="true"
            :allowed-page-sizes="[10, 20, 50, 100]"
            :show-info="true"
          />
          <DxFilterRow :visible="false" />
          <DxHeaderFilter
            :visible="true"
            :allow-search="true"
            :width="400"
            :height="400"
          />
          <DxSearchPanel
            :visible="true"
            :width="300"
            placeholder="Procurar..."
          />
          <DxFilterPanel :visible="true" />
          <DxColumnFixing :enabled="false" />
          <DxColumnChooser :enabled="true" mode="select" />
        </dx-data-grid>
      </q-tab-panel>

      <q-tab-panel name="1">
        <q-btn
          color="orange-9"
          icon="add"
          style="float: left"
          class="margin1"
          rounded
          label="Novo"
          @click="NovaAtividade()"
        >
          <q-tooltip> Nova Atividade </q-tooltip>
        </q-btn>
        <q-btn
          class="col margin1"
          disable
          round
          :color="
            !!atividade.nm_valor_cor == false
              ? 'primary'
              : atividade.nm_valor_cor
          "
          :icon="
            !!atividade.nm_icone_atributo == false
              ? 'primary'
              : atividade.nm_icone_atributo
          "
        />
        {{
          `Atividade - ${
            atividade.cd_atividade == undefined ? 0 : atividade.cd_atividade
          }`
        }}

        <q-input
          dense
          class="col margin1"
          v-model="atividade.nm_atividade"
          label="Título da Atividade"
        >
          <template v-slot:prepend>
            <q-icon name="list_alt"></q-icon>
          </template>
        </q-input>

        <div class="row">
          <q-select
            dense
            class="col margin1"
            v-model="tipo_atividade"
            :options="dataset_lookup_tipo_atividade"
            label="Tipo de Atividade"
            option-value="cd_tipo_atividade"
            option-label="nm_tipo_atividade"
            @input="Select(1)"
          >
            <template v-slot:prepend>
              <q-icon name="how_to_reg" />
            </template>
            <template v-slot:append>
              <q-btn
                round
                color="orange-9"
                icon="add"
                size="sm"
                :loading="load_tipo_atividade"
                @click="onAddTipoAtividade()"
              />
            </template>
          </q-select>

          <q-select
            dense
            class="col margin1"
            v-model="status_atividade"
            :options="dataset_lookup_status"
            label="Status"
            option-value="cd_status_atividade"
            option-label="nm_status_atividade"
            @input="Select(2)"
          >
            <template v-slot:prepend>
              <q-icon name="filter_list" />
            </template>
          </q-select>

          <q-select
            dense
            class="col margin1"
            v-model="cor"
            :options="dataset_lookup_cor"
            label="Cor"
            option-value="cd_cor"
            option-label="nm_cor"
            @input="Select(3)"
          >
            <template v-slot:prepend>
              <q-icon name="palette" />
            </template>
          </q-select>

          <q-select
            dense
            class="col margin1"
            v-model="tipo_destinatario"
            :options="dataset_lookup_destinatario"
            label="Destinatário"
            option-value="cd_tipo_destinatario"
            option-label="nm_tipo_destinatario"
            @input="Select(4)"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-select>
        </div>

        <transition name="slide-fade">
          <div
            class="borda-bloco shadow-2 margin1"
            v-show="ic_cad_tipo_atividade"
          >
            <div class="row">
              <q-input
                dense
                class="col margin1"
                v-model="nm_tipo_atividade.nm_tipo_atividade"
                label="Tipo de Atividade"
              >
                <template v-slot:prepend>
                  <q-icon name="badge" />
                </template>
              </q-input>

              <q-select
                dense
                class="col margin1"
                v-model="icone"
                :options="dataset_lookup_icone"
                label="Ícone"
                option-value="cd_icone"
                option-label="nm_icone"
                @input="Select(2)"
              >
                <template v-slot:prepend>
                  <q-icon name="grading" />
                </template>
              </q-select>
            </div>
            <q-btn
              rounded
              class="margin1"
              color="orange-9"
              text-color="white"
              icon="add"
              label="Novo"
              @click="onLimpaTipoAtividade()"
            />
            <q-btn
              rounded
              class="margin1"
              color="orange-9"
              text-color="white"
              icon="check"
              label="Salvar"
              @click="onSaveTipoAtividade()"
            />
            <dx-data-grid
              id="grid-padrao"
              class="dx-card wide-card-gc margin1"
              :data-source="dataSourceTipoAtividade"
              :columns="colunaTipoAtividade"
              :summary="totalTipoAtividade"
              key-expr="cd_controle"
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
              @focused-row-changed="onFocusedRowTipoAtividade"
              @row-removed="RemoveTipoAtividade"
            >
              <DxEditing
                style="margin: 0; padding: 0"
                :allow-updating="false"
                :allow-adding="false"
                :allow-deleting="true"
                mode="cell"
              />
              <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
              <DxGrouping :auto-expand-all="true" />

              <DxPaging :enable="true" :page-size="10" />
              <DxSelection mode="single" />
              <DxPager
                :show-page-size-selector="true"
                :allowed-page-sizes="[10, 20, 50, 100]"
                :show-info="true"
              />
              <DxFilterRow :visible="false" />
              <DxHeaderFilter
                :visible="true"
                :allow-search="true"
                :width="400"
                :height="400"
              />
              <DxSearchPanel
                :visible="true"
                :width="300"
                placeholder="Procurar..."
              />
              <DxFilterPanel :visible="true" />
              <DxColumnFixing :enabled="false" />
              <DxColumnChooser :enabled="true" mode="select" />
            </dx-data-grid>
          </div>
        </transition>

        <div class="row">
          <q-toggle
            dense
            class="col margin1"
            v-model="ic_kanban"
            color="orange"
            label="Vincula ao Kanban"
          />
          <transition name="slide-fade">
            <div v-show="this.ic_kanban">
              <q-select
                dense
                class="col margin1"
                v-model="etapa"
                :options="dataset_lookup_etapa"
                label="Etapa"
                option-value="cd_etapa"
                option-label="nm_etapa"
                @input="Select(8)"
              >
                <template v-slot:prepend>
                  <q-icon name="grading" />
                </template>
              </q-select>
            </div>
          </transition>

          <q-select
            dense
            class="col margin1"
            v-model="prioridade"
            :options="dataset_lookup_prioridade"
            label="Prioridade"
            option-value="cd_tipo_prioridade"
            option-label="nm_tipo_prioridade"
            @input="Select(5)"
          >
            <template v-slot:prepend>
              <q-icon name="priority_high" />
            </template>
          </q-select>

          <q-select
            dense
            class="col margin1"
            v-model="organizacao"
            :options="dataset_lookup_organizacao"
            label="Organização"
            option-value="cd_organizacao"
            option-label="nm_organizacao"
            @input="Select(6)"
          >
            <template v-slot:prepend>
              <q-icon name="apartment" />
            </template>
          </q-select>

          <q-select
            dense
            class="col margin1"
            v-model="cliente"
            :options="dataset_lookup_cliente"
            label="Cliente"
            option-value="cd_cliente"
            option-label="nm_fantasia_cliente"
            @input="Select(7)"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-select>
        </div>

        <div class="row">
          <q-select
            dense
            class="col margin1"
            v-model="tipo_documento"
            :options="dataset_lookup_tipo_documento"
            label="Tipo de Documento"
            option-value="cd_documento"
            option-label="nm_documento"
            @input="Select(9)"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-select>

          <q-select
            dense
            class="col margin1"
            v-model="motivo_atividade"
            :options="dataset_lookup_motivo_atividade"
            label="Motivo"
            option-value="cd_motivo_atividade"
            option-label="nm_motivo_atividade"
            @input="Select(10)"
          >
            <template v-slot:prepend>
              <q-icon name="format_list_bulleted" />
            </template>
          </q-select>

          <q-input
            dense
            class="col margin1"
            v-model="atividade.cd_documento_atividade"
            label="Documento"
          >
            <template v-slot:prepend>
              <q-icon name="description"></q-icon>
            </template>
          </q-input>

          <q-input
            dense
            class="col margin1"
            v-model="atividade.pc_atividade"
            label="(%) Atividade"
            mask="##.##"
            suffix="%"
          >
            <template v-slot:prepend>
              <q-icon name="filter_list"></q-icon>
            </template>
          </q-input>
        </div>

        <div class="row">
          <q-input
            dense
            class="col margin1"
            v-model="vl_atividade"
            label="Valor"
            @blur="onValor(vl_atividade)"
          >
            <template v-slot:prepend>
              <q-icon name="attach_money"></q-icon>
            </template>
          </q-input>

          <q-input
            dense
            class="col margin1"
            v-model="atividade.hr_atividade"
            label="Hora da Atividade"
            mask="##:##"
          >
            <template v-slot:prepend>
              <q-icon name="timer"></q-icon>
            </template>
            <template v-slot:append>
              <q-btn
                icon="history"
                color="orange-9"
                round
                class="cursor-pointer"
                size="sm"
              >
                <q-popup-proxy
                  ref="qDateProxy"
                  cover
                  transition-show="scale"
                  transition-hide="scale"
                >
                  <q-time
                    v-model="atividade.hr_atividade"
                    mask="HH:mm"
                    color="primary"
                    class="qdate"
                  >
                    <div class="row items-center justify-end">
                      <q-btn v-close-popup round flat icon="close" size="sm" />
                    </div>
                  </q-time>
                </q-popup-proxy>
              </q-btn>
            </template>
          </q-input>

          <q-input
            dense
            class="col margin1"
            v-model="dt_retorno"
            label="Data de Retorno"
            mask="##/##/####"
            @blur="FormataData(dt_retorno)"
          >
            <template v-slot:prepend>
              <q-icon name="date_range"></q-icon>
            </template>
            <template v-slot:append>
              <q-btn round color="orange-9" icon="event" size="sm">
                <q-popup-proxy
                  ref="qDateProxy"
                  cover
                  transition-show="scale"
                  transition-hide="scale"
                >
                  <q-date
                    v-model="dt_retorno_picker"
                    @input="FormataDataPicker(dt_retorno_picker)"
                    class="qdate"
                  >
                    <div class="row items-center justify-end">
                      <q-btn v-close-popup round flat icon="close" size="sm" />
                    </div>
                  </q-date>
                </q-popup-proxy>
              </q-btn>
            </template>
          </q-input>

          <q-input
            dense
            class="col margin1"
            v-model="atividade.hr_retorno"
            label="Horário de Retorno"
            mask="##:##"
          >
            <template v-slot:prepend>
              <q-icon name="timer"></q-icon>
            </template>
            <template v-slot:append>
              <q-btn
                icon="history"
                color="orange-9"
                round
                class="cursor-pointer"
                size="sm"
              >
                <q-popup-proxy
                  ref="qDateProxy"
                  cover
                  transition-show="scale"
                  transition-hide="scale"
                >
                  <q-time
                    v-model="atividade.hr_retorno"
                    mask="HH:mm"
                    color="primary"
                    class="qdate"
                  >
                    <div class="row items-center justify-end">
                      <q-btn v-close-popup round flat icon="close" size="sm" />
                    </div>
                  </q-time>
                </q-popup-proxy>
              </q-btn>
            </template>
          </q-input>
        </div>

        <q-input
          dense
          class="margin1"
          v-model="atividade.ds_atividade"
          label="Descritivo"
          type="textarea"
        >
          <template v-slot:prepend>
            <q-icon name="description"></q-icon>
          </template>
        </q-input>

        <div class="row items-center">
          <q-btn
            rounded
            class="margin1"
            color="orange-9"
            text-color="white"
            icon="check"
            label="Salvar"
            @click="onSaveAtividade()"
          />
          <q-space />
          <q-btn
            rounded
            flat
            color="orange-9"
            text-color="orange-9"
            icon="arrow_back"
            label="Voltar"
            @click="Voltar0()"
          />
          <q-btn
            rounded
            flat
            color="orange-9"
            text-color="orange-9"
            icon="close"
            label="Cancelar"
          />
        </div>
      </q-tab-panel>
      <q-tab-panel name="2">
        <q-toggle
          class="col margin1"
          v-model="ic_faturamento"
          color="orange"
          label="Gera Faturamento"
        />
        <q-toggle
          class="col margin1"
          v-model="ic_email"
          color="orange"
          label="Gera E-mail"
        />
        <q-toggle
          class="col margin1"
          v-model="ic_despesa"
          color="orange"
          label="Gera Despesa"
        />
        <q-toggle
          class="col margin1"
          v-model="ic_autorizacao"
          color="orange"
          label="Necessita Autorização"
        />

        <q-toggle
          class="col margin1"
          v-model="ic_relatorio"
          color="orange"
          label="Gera Relatório"
        />
      </q-tab-panel>
    </q-tab-panels>
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

import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import Lookup from "../http/lookup";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import Incluir from "../http/incluir_registro";
import funcao from "../http/funcoes-padroes";
import { LocalStorage } from "quasar";

let dados = [];
let sParametroApi = "";

var data_selecionada = {};

export default {
  props: {
    //cd_menuID: { type: Number, default: 0 },
    //cd_apiID: { type: Number, default: 0 },
    cd_identificacaoID: { type: Number, default: 0 },
    cd_parametroID: { type: Number, default: 0 },
    cd_tipo_consultaID: { type: Number, default: 0 },
    masterDetail: { type: Boolean, default: false },
  },

  Selecionada() {
    return data_selecionada;
    data_selecionada = {};
  },

  data() {
    return {
      tituloMenu: "",
      nm_json: "",
      abas: "0",
      ic_kanban: false,
      ic_faturamento: false,
      ic_email: false,
      ic_despesa: false,
      ic_autorizacao: false,
      ic_relatorio: false,
      ic_cad_tipo_atividade: false,
      load_tipo_atividade: false,
      qt_registro: 0,
      vl_atividade: "",
      pc_atividade: "",
      dt_retorno: "",
      dt_retorno_picker: "",
      etapa: "",
      linha: {},
      dt_inicial: "",
      dt_final: "",
      nm_tipo_atividade: {
        nm_tipo_atividade: "",
      },
      columns: [],
      dataSourceConfig: [],
      total: {},
      dataSourceTipoAtividade: [],
      colunaTipoAtividade: [],
      totalTipoAtividade: {},
      cd_empresa: localStorage.cd_empresa,
      cd_menu: 0,
      cd_cliente: 0,
      cd_api: 0,
      cd_modulo: localStorage.cd_modulo,
      api: 0,
      atividade: {},
      tipo_atividade: [],
      tipo_documento: [],
      motivo_atividade: [],
      status_atividade: [],
      cor: [],
      icone: [],
      tipo_destinatario: [],
      prioridade: [],
      organizacao: [],
      cliente: [],
      dataset_lookup_motivo_atividade: [],
      dataset_lookup_tipo_documento: [],
      dataset_lookup_etapa: [],
      dataset_lookup_tipo_atividade: [],
      dataset_lookup_status: [],
      dataset_lookup_cor: [],
      dataset_lookup_icone: [],
      dataset_lookup_motivo: [],
      dataset_lookup_destinatario: [],
      dataset_lookup_prioridade: [],
      dataset_lookup_organizacao: [],
      dataset_lookup_cliente: [],
    };
  },

  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    await this.carregaDados();
    this.linha = this.dataSourceConfig[0];
    data_selecionada = {};
    this.cd_modulo = localStorage.cd_modulo;

    let dados_lookup_tipo_atividade = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5368
    );
    this.dataset_lookup_tipo_atividade = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_tipo_atividade.dataset))
    );

    let dados_lookup_status = await Lookup.montarSelect(
      localStorage.cd_empresa,
      1853
    );
    this.dataset_lookup_status = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_status.dataset))
    );

    let dados_lookup_cor = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5425
    );
    this.dataset_lookup_cor = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_cor.dataset))
    );

    let dados_lookup_icone = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5405
    );
    this.dataset_lookup_icone = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_icone.dataset))
    );

    let dados_lookup_motivo = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5369
    );
    this.dataset_lookup_motivo = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_motivo.dataset))
    );

    let dados_lookup_organizacao = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5215
    );
    this.dataset_lookup_organizacao = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_organizacao.dataset))
    );

    let dados_lookup_destinatario = await Lookup.montarSelect(
      localStorage.cd_empresa,
      660
    );
    this.dataset_lookup_destinatario = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_destinatario.dataset))
    );

    let dados_lookup_prioridade = await Lookup.montarSelect(
      localStorage.cd_empresa,
      576
    );
    this.dataset_lookup_prioridade = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_prioridade.dataset))
    );

    let dados_lookup_cliente = await Lookup.montarSelect(
      localStorage.cd_empresa,
      93
    );
    this.dataset_lookup_cliente = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_cliente.dataset))
    );

    let dados_lookup_tipo_documento = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5397
    );
    this.dataset_lookup_tipo_documento = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_tipo_documento.dataset))
    );

    let dados_lookup_motivo_atividade = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5369
    );
    this.dataset_lookup_motivo_atividade = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_motivo_atividade.dataset))
    );

    let JSON_etapas_modulo = {
      cd_parametro: 8,
      cd_modulo: this.cd_modulo,
    };
    this.dataset_lookup_etapa = await Incluir.incluirRegistro(
      this.api,
      JSON_etapas_modulo
    );
  },

  components: {
    DxDataGrid,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxEditing,
    DxMasterDetail,
    DxGrouping,
    DxColumnChooser,
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxSelection,
    DxStateStoring,
    DxSearchPanel,
  },

  watch: {
    async abas(a, b) {
      if (a == "0") {
        await this.carregaDados();
      }
      if (a == "1") {
        await this.onValor();
      }
    },
  },

  methods: {
    selectionChanged(e) {
      e.component.collapseAll(-1);
      e.component.expandRow(e.currentSelectedRowKeys[0]);
    },

    TrocaLinha({ selectedRowKeys, selectedRowsData }) {
      this.linha = selectedRowsData[0];
    },

    DBClick(e) {
      this.linha = e;
      this.$emit("emit-click", e);
    },

    async FormataDataPicker(dt_picker) {
      var ano = dt_picker.substring(0, 4);
      var mes = dt_picker.substring(5, 7);
      var dia = dt_picker.substring(8, 10);
      let verificaData = dia + "/" + mes + "/" + ano;
      let validaData = await funcao.checarData(verificaData);
      verificaData
        ? ((this.atividade.dt_retorno = verificaData),
          (this.dt_retorno = verificaData))
        : ((this.dt_retorno = ""),
          (this.atividade.dt_retorno = ""),
          (this.dt_retorno_picker = ""));
    },

    async FormataData(dt_picker) {
      //Inserido no input
      let verificaData1 = await funcao.checarData(dt_picker);
      verificaData1
        ? (this.atividade.dt_retorno = this.dt_retorno)
        : (this.dt_retorno = "");
    },

    async onValor() {
      this.atividade.vl_atividade = await funcao.FormataValor(
        this.vl_atividade
      );
      this.vl_atividade = this.atividade.vl_atividade;
    },

    async AttTipoAtividade() {
      let dados_lookup_tipo_atividade = await Lookup.montarSelect(
        localStorage.cd_empresa,
        5368
      );
      this.dataset_lookup_tipo_atividade = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_tipo_atividade.dataset))
      );

      let dados = await Menu.montarMenu(this.cd_empresa, 7494, this.cd_api);
      this.colunaTipoAtividade = JSON.parse(
        JSON.parse(JSON.stringify(dados.coluna))
      );
      if (dados.coluna_total != "") {
        this.totalTipoAtividade = JSON.parse(
          JSON.parse(JSON.stringify(dados.coluna_total))
        );
      }
      let consulta_tipo_atividade = {
        cd_parametro: 4,
      };
      try {
        this.dataSourceTipoAtividade = await Incluir.incluirRegistro(
          this.api,
          consulta_tipo_atividade
        );
      } catch (error) {
        console.log(error);
      }
    },

    async onAddTipoAtividade() {
      if (this.ic_cad_tipo_atividade) {
        this.ic_cad_tipo_atividade = false;
        return;
      }
      this.load_tipo_atividade = true;
      await this.AttTipoAtividade();
      this.load_tipo_atividade = false;
      this.ic_cad_tipo_atividade = !this.ic_cad_tipo_atividade;
    },

    async onSaveTipoAtividade() {
      /*
      Consulta - 4
      Insert   - 5
      Update   - 6
      Delete   - 7
      */
      if (this.nm_tipo_atividade.nm_tipo_atividade == "") {
        return notify("Insira o Nome do Tipo de Atividade");
      }
      let tipo_atividade = {};
      if (this.nm_tipo_atividade.cd_tipo_atividade == undefined) {
        tipo_atividade = {
          cd_parametro: 5,
          nm_tipo_atividade: this.nm_tipo_atividade.nm_tipo_atividade,
          cd_icone: this.icone.cd_icone,
          nm_icone: this.icone.nm_icone,
          nm_icone_atributo: this.icone.nm_icone_atributo,
        };
      } else {
        tipo_atividade = {
          cd_parametro: 6,
          cd_tipo_atividade: this.nm_tipo_atividade.cd_tipo_atividade,
          nm_tipo_atividade: this.nm_tipo_atividade.nm_tipo_atividade,
          cd_icone: this.icone.cd_icone,
          nm_icone: this.icone.nm_icone,
          nm_icone_atributo: this.icone.nm_icone_atributo,
        };
      }

      try {
        let resultado_tipo_atividade = await Incluir.incluirRegistro(
          this.api,
          tipo_atividade
        );
        notify(resultado_tipo_atividade[0].Msg);
        await this.AttTipoAtividade();
      } catch (error) {
        console.log(error);
      }
    },

    async onSaveAtividade() {
      /*
      Consulta - 0
      Insert   - 1
      Update   - 2
      Delete   - 3
      */
      let formata = this.atividade.dt_retorno;
      var diaF = formata.substring(0, 2);
      var mesF = formata.substring(3, 5);
      var anoF = formata.substring(6, 10);
      let formatada = mesF + "-" + diaF + "-" + anoF;

      let JSON_atividade = {};
      if (this.atividade.cd_atividade == undefined) {
        //Insert
        JSON_atividade = {
          cd_parametro: 1,
          cd_modulo: this.cd_modulo,
          cd_cliente: this.atividade.cd_cliente,
          cd_cor: this.atividade.cd_cor,
          cd_icone: this.atividade.cd_icone,
          cd_etapa: this.atividade.cd_etapa,
          cd_organizacao: this.atividade.cd_organizacao,
          cd_status_atividade: this.atividade.cd_status_atividade,
          cd_tipo_destinatario: this.atividade.cd_tipo_destinatario,
          cd_tipo_prioridade: this.atividade.cd_tipo_prioridade,
          cd_tipo_atividade: this.atividade.cd_tipo_atividade,
          ds_atividade: this.atividade.ds_atividade,
          dt_retorno: formatada,
          hr_atividade: this.atividade.hr_atividade,
          hr_retorno: this.atividade.hr_retorno,
          nm_atividade: this.atividade.nm_atividade,
          nm_cor: this.atividade.nm_cor,
          nm_icone: this.atividade.nm_icone,
          nm_icone_atributo: this.atividade.nm_icone_atributo,
          nm_etapa: this.atividade.nm_etapa,
          nm_fantasia_cliente: this.atividade.nm_fantasia_cliente,
          nm_organizacao: this.atividade.nm_organizacao,
          nm_status_atividade: this.atividade.nm_status_atividade,
          nm_tipo_destinatario: this.atividade.nm_tipo_destinatario,
          nm_tipo_prioridade: this.atividade.nm_tipo_prioridade,
          nm_tipo_atividade: this.atividade.nm_tipo_atividade,
          nm_valor_cor: this.atividade.nm_valor_cor,
          pc_atividade: this.atividade.pc_atividade,
          cd_documento: this.atividade.cd_documento,
          cd_motivo_atividade: this.atividade.cd_motivo_atividade,
          cd_documento_atividade: this.atividade.cd_documento_atividade,
          vl_atividade: this.atividade.vl_atividade.replace("R$", ""),
        };
      } else {
        //Update
        JSON_atividade = {
          cd_parametro: 2,
          cd_atividade: this.atividade.cd_atividade,
          cd_modulo: this.cd_modulo,
          cd_cliente: this.atividade.cd_cliente,
          cd_cor: this.atividade.cd_cor,
          cd_icone: this.atividade.cd_icone,
          cd_etapa: this.atividade.cd_etapa,
          cd_organizacao: this.atividade.cd_organizacao,
          cd_status_atividade: this.atividade.cd_status_atividade,
          cd_tipo_destinatario: this.atividade.cd_tipo_destinatario,
          cd_tipo_prioridade: this.atividade.cd_tipo_prioridade,
          cd_tipo_atividade: this.atividade.cd_tipo_atividade,
          ds_atividade: this.atividade.ds_atividade,
          dt_retorno: formatada,
          hr_atividade: this.atividade.hr_atividade,
          hr_retorno: this.atividade.hr_retorno,
          nm_atividade: this.atividade.nm_atividade,
          nm_cor: this.atividade.nm_cor,
          nm_icone: this.atividade.nm_icone,
          nm_icone_atributo: this.atividade.nm_icone_atributo,
          nm_etapa: this.atividade.nm_etapa,
          nm_fantasia_cliente: this.atividade.nm_fantasia_cliente,
          nm_organizacao: this.atividade.nm_organizacao,
          nm_status_atividade: this.atividade.nm_status_atividade,
          nm_tipo_destinatario: this.atividade.nm_tipo_destinatario,
          nm_tipo_prioridade: this.atividade.nm_tipo_prioridade,
          nm_tipo_atividade: this.atividade.nm_tipo_atividade,
          nm_valor_cor: this.atividade.nm_valor_cor,
          pc_atividade: this.atividade.pc_atividade,
          cd_documento: this.atividade.cd_documento,
          cd_motivo_atividade: this.atividade.cd_motivo_atividade,
          cd_documento_atividade: this.atividade.cd_documento_atividade,
          vl_atividade: this.atividade.vl_atividade.replace("R$", ""),
        };
      }
      try {
        let resultado_atividade = await Incluir.incluirRegistro(
          this.api,
          JSON_atividade
        );
        notify(resultado_atividade[0].Msg);
      } catch (error) {
        console.log(error);
      }
    },

    Select(e) {
      switch (e) {
        case 1:
          this.atividade.cd_tipo_atividade =
            this.tipo_atividade.cd_tipo_atividade;
          this.atividade.nm_tipo_atividade =
            this.tipo_atividade.nm_tipo_atividade;
          let icone_encontrado = this.dataset_lookup_icone.find((x) => {
            return x.cd_icone == this.tipo_atividade.cd_icone;
          });
          this.atividade.cd_icone = icone_encontrado.cd_icone;
          this.atividade.nm_icone = icone_encontrado.nm_icone;
          this.atividade.nm_icone_atributo = icone_encontrado.nm_icone_atributo;
          break;
        case 2:
          this.atividade.cd_status_atividade =
            this.status_atividade.cd_status_atividade;
          this.atividade.nm_status_atividade =
            this.status_atividade.nm_status_atividade;
          break;
        case 3:
          this.atividade.cd_cor = this.cor.cd_cor;
          this.atividade.nm_cor = this.cor.nm_cor;
          this.atividade.nm_valor_cor = this.cor.nm_valor_cor;
          break;
        case 4:
          this.atividade.cd_tipo_destinatario =
            this.tipo_destinatario.cd_tipo_destinatario;
          this.atividade.nm_tipo_destinatario =
            this.tipo_destinatario.nm_tipo_destinatario;
          break;
        case 5:
          this.atividade.cd_tipo_prioridade =
            this.prioridade.cd_tipo_prioridade;
          this.atividade.nm_tipo_prioridade =
            this.prioridade.nm_tipo_prioridade;
          break;
        case 6:
          this.atividade.cd_organizacao = this.organizacao.cd_organizacao;
          this.atividade.nm_organizacao = this.organizacao.nm_organizacao;
          break;
        case 7:
          this.atividade.cd_cliente = this.cliente.cd_cliente;
          this.atividade.nm_fantasia_cliente = this.cliente.nm_fantasia_cliente;
          break;
        case 8:
          this.atividade.cd_etapa = this.etapa.cd_etapa;
          this.atividade.nm_etapa = this.etapa.nm_etapa;
          break;
        case 9:
          this.atividade.cd_documento = this.tipo_documento.cd_documento;
          this.atividade.nm_documento = this.tipo_documento.nm_documento;
          break;
        case 10:
          this.atividade.cd_motivo_atividade =
            this.motivo_atividade.cd_motivo_atividade;
          this.atividade.nm_motivo_atividade =
            this.motivo_atividade.nm_motivo_atividade;
          break;
      }
    },

    NovaAtividade() {
      this.abas = "1";
      this.atividade = {};
      this.tipo_atividade = "";
      this.status_atividade = "";
      this.cor = "";
      this.tipo_destinatario = "";
      this.prioridade = "";
      this.organizacao = "";
      this.cliente = "";
      this.nm_tipo_atividade = "";
      this.etapa = "";
    },

    onLimpaTipoAtividade() {
      this.nm_tipo_atividade = {
        nm_tipo_atividade: "",
      };
      this.icone = "";
    },

    Voltar0() {
      this.abas = "0";
    },

    async showMenu() {
      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_menu = 7490;
      this.cd_api = 768;
      //this.cd_menu =
      //  this.cd_menuID == 0 ? localStorage.cd_menu : this.cd_menuID;
      //this.cd_api = this.cd_apiID == 0 ? localStorage.cd_api : this.cd_apiID; //API - 768
      this.api = "";

      //parametro de Pesquisa

      localStorage.cd_identificacao = 0;
      localStorage.cd_parametro = 0;

      if (!this.cd_parametroID == 0) {
        localStorage.cd_parametro = this.cd_parametroID;
      }

      if (!this.cd_identificacaoID == 0) {
        localStorage.cd_identificacao = this.cd_identificacaoID;
      }
      if (!this.cd_tipo_consultaID == 0) {
        localStorage.cd_tipo_consulta = this.cd_tipo_consultaID;
      }

      let dados = await Menu.montarMenu(
        this.cd_empresa,
        this.cd_menu,
        this.cd_api
      );

      sParametroApi = dados.nm_api_parametro;

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      if (!dados.cd_tipo_consulta == 0) {
        dados.cd_tipo_consulta;
      }

      this.tituloMenu = dados.nm_menu_titulo; //'titulo';

      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      //dados do total - Kelvin... Coluna estava gerando erro quando não há total - 19.07
      if (dados.coluna_total != "") {
        this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      }
    },

    //
    //mágica - carrego o Json com o Resulta do Stored procedure
    //

    async carregaDados() {
      await this.showMenu();

      localStorage.cd_parametro = 0;
      localStorage.cd_identificacao = 0;

      this.nm_json = {
        cd_parametro: 0,
      };
      try {
        this.dataSourceConfig = await Incluir.incluirRegistro(
          this.api,
          this.nm_json
        );
        this.qt_registro = this.dataSourceConfig.length;
      } catch (error) {
        console.log(error);
      }

      return this.nm_json;
    },

    async RemoveAtividade(e) {
      let linha_tipo_atividade_removida = e.data;
      let Remove_Atividade = {
        cd_parametro: 3,
        cd_atividade: linha_tipo_atividade_removida.cd_atividade,
      };
      try {
        let Resultado_delete_atividade = await Incluir.incluirRegistro(
          this.api,
          Remove_Atividade
        );
        notify(Resultado_delete_atividade[0].Msg);
      } catch (error) {
        console.log(error);
      }
      await this.carregaDados();
    },

    async RemoveTipoAtividade(e) {
      let linha_tipo_atividade_removida = e.data;
      let Remove_Tipo_Atividade = {
        cd_parametro: 7,
        cd_tipo_atividade: linha_tipo_atividade_removida.cd_tipo_atividade,
      };
      try {
        let Resultado_delete_tipo_atividade = await Incluir.incluirRegistro(
          this.api,
          Remove_Tipo_Atividade
        );
        notify(Resultado_delete_tipo_atividade[0].Msg);
      } catch (error) {
        console.log(error);
      }
      await this.AttTipoAtividade();
    },

    onFocusedRowTipoAtividade: function (e) {
      let tipo_atividade_selecionada = e.row && e.row.data;
      this.nm_tipo_atividade = {
        nm_tipo_atividade: tipo_atividade_selecionada.nm_tipo_atividade,
        cd_tipo_atividade: tipo_atividade_selecionada.cd_tipo_atividade,
      };
      this.icone = {
        cd_icone: tipo_atividade_selecionada.cd_icone,
        nm_icone: tipo_atividade_selecionada.nm_icone,
        nm_icone_atributo: tipo_atividade_selecionada.nm_icone_atributo,
      };
    },

    onFocusedRowChanged: async function (e) {
      data_selecionada = {};
      data_selecionada = e.row && e.row.data;
      this.atividade = data_selecionada;

      this.dt_retorno = data_selecionada.dt_retorno;
      this.vl_atividade = await funcao.FormataValor(
        this.atividade.vl_atividade
      );

      this.tipo_atividade = {
        cd_tipo_atividade: data_selecionada.cd_tipo_atividade,
        nm_tipo_atividade: data_selecionada.nm_tipo_atividade,
      };
      this.status_atividade = {
        cd_status_atividade: data_selecionada.cd_status_atividade,
        nm_status_atividade: data_selecionada.nm_status_atividade,
      };
      this.cor = {
        cd_cor: data_selecionada.cd_cor,
        nm_cor: data_selecionada.nm_cor,
      };
      this.tipo_destinatario = {
        cd_tipo_destinatario: data_selecionada.cd_tipo_destinatario,
        nm_tipo_destinatario: data_selecionada.nm_tipo_destinatario,
      };
      this.prioridade = {
        cd_tipo_prioridade: data_selecionada.cd_tipo_prioridade,
        nm_tipo_prioridade: data_selecionada.nm_tipo_prioridade,
      };
      this.organizacao = {
        cd_organizacao: data_selecionada.cd_organizacao,
        nm_organizacao: data_selecionada.nm_organizacao,
      };
      this.cliente = {
        cd_cliente: data_selecionada.cd_cliente,
        nm_fantasia_cliente: data_selecionada.nm_fantasia_cliente,
      };
      this.motivo_atividade = {
        cd_motivo_atividade: data_selecionada.cd_motivo_atividade,
        nm_motivo_atividade: data_selecionada.nm_motivo_atividade,
      };
      this.tipo_documento = {
        cd_documento: data_selecionada.cd_tipo_documento,
        nm_documento: data_selecionada.nm_documento,
      };
      this.atividade.cd_documento = data_selecionada.cd_documento;
    },
  },
};
</script>

<style>
#grid-padrao {
  max-height: 600px !important;
}

.margin1 {
  margin: 0.5vh 0.5vw;
}

.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}

.qdate {
  width: 310px;
  height: 480px;
  overflow-x: hidden;
}
</style>
