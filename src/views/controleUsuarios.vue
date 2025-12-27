<template>
  <div>
    <h2 class="content-block">{{ `Controle de Usuários` }}</h2>
    <q-tabs
      v-model="index"
      inline-label
      mobile-arrows
      align="justify"
      style="border-radius: 20px"
      :class="'bg-primary text-white shadow-2 margin1'"
    >
      <q-tab
        v-for="tabs in tabsheets"
        :key="tabs.cd_tabsheet"
        :name="tabs.cd_tabsheet"
        :icon="tabs.ic_icone === 'S' ? tabs.nm_icone_tabsheet : ''"
        :label="tabs.nm_tabsheet"
      />
    </q-tabs>
    <q-tab-panels
      v-model="index"
      animated
      swipeable
      vertical
      transition-prev="jump-up"
      transition-next="jump-up"
    >
      <q-tab-panel
        v-for="tabs in tabsheets"
        :key="tabs.cd_tabsheet"
        :name="tabs.cd_tabsheet"
      >
        <div>
          <div class="row q-gutter-sm items-center">
            <div v-for="subTabs in tabs.subTabsheet" :key="subTabs.cd_tabsheet">
              <q-btn
                class="q-mb-md"
                rounded
                color="orange-9"
                text-color="white"
                :label="subTabs.nm_tabsheet"
                :icon="
                  subTabs.ic_icone === 'S' ? subTabs.nm_icone_tabsheet : ''
                "
                @click="changeSubTab(subTabs)"
              />
            </div>
          </div>
          <div v-if="subIndex.cd_tabsheet === 0">
            <dx-data-grid
              id="grid-padrao"
              ref="grid-padrao"
              class="dx-card wide-card-gc"
              :data-source="dataSourceGrid"
              :columns="columns"
              :key-expr="table.chave || 'cd_controle'"
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
              noDataText="Sem dados"
              @focused-row-changed="onFocusedRowChanged"
            >
              <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

              <DxGrouping :auto-expand-all="true" />
              <DxExport :enabled="true" />

              <DxPaging :enable="true" :page-size="20" />

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
          </div>
          <div v-if="subIndex.cd_tabsheet === 1">
            <div class="row">
              <div
                class="col-3"
                v-for="(item, ind) in subIndex.dataset.campos"
                :key="ind"
              >
                <q-input
                  v-if="item.nm_tipo_atributo === 'input'"
                  filled
                  class="margin1"
                  v-model="item.nm_valor"
                  :label="item.nm_label"
                  :type="item.nm_datatype"
                  :readonly="item.read_only"
                  :name="item.nm_chave"
                />
                <q-select
                  v-else-if="item.nm_tipo_atributo === 'select'"
                  filled
                  class="margin1"
                  v-model="item.nm_valor"
                  :label="item.nm_label"
                  :options="lookups[item.options]"
                  :option-value="item['option-value']"
                  :option-label="item['option-label']"
                  :readonly="item.read_only"
                  :name="item.nm_chave"
                  @input="onSelect(item)"
                >
                  <template v-if="item.ic_info" v-slot:append>
                    <q-btn
                      class="margin1"
                      round
                      icon="info"
                      color="orange-9"
                      @click.stop="infoList(item)"
                    />
                  </template>
                </q-select>
                <div
                  class="text-center full-width"
                  v-else-if="item.nm_tipo_atributo === 'toggle'"
                >
                  <div>
                    {{ item.nm_label }}
                  </div>
                  <span class="q-mr-sm">Não</span>
                  <q-toggle
                    v-model="item.nm_valor"
                    :false-value="item.falseValue"
                    :true-value="item.trueValue"
                    :label="''"
                  />
                  <span class="q-ml-sm">Sim</span>
                </div>
              </div>
            </div>
            <q-btn
              class="q-mt-md margin1"
              rounded
              color="orange-9"
              text-color="white"
              label="Novo"
              @click="novoUsuario"
            />
            <q-btn
              class="q-mt-md margin1"
              rounded
              color="orange-9"
              text-color="white"
              label="Salvar"
              @click="salvarUsuario"
            />
            <q-btn
              class="q-mt-md margin1"
              rounded
              flat
              color="orange-9"
              label="Cancelar"
            />
            <div v-if="infoSelect">
              <q-option-group
                v-model="group[lookupSelected.options]"
                :options="optionGroupList"
                color="orange-9"
                type="checkbox"
              />
            </div>
          </div>
          <div v-if="subIndex.cd_tabsheet === 2">
            <div class="row">
              <div
                class="col-3"
                v-for="(item, ind) in subIndex.dataset.campos"
                :key="ind"
              >
                <q-input
                  v-if="item.nm_tipo_atributo === 'input'"
                  filled
                  class="margin1"
                  v-model="item.nm_valor"
                  :label="item.nm_label"
                  :type="item.nm_datatype"
                  :readonly="item.read_only"
                  :name="item.nm_chave"
                />
                <q-select
                  v-else-if="item.nm_tipo_atributo === 'select'"
                  filled
                  class="margin1"
                  v-model="item.nm_valor"
                  :label="item.nm_label"
                  :options="lookups[item.options]"
                  :option-value="item['option-value']"
                  :option-label="item['option-label']"
                  :readonly="item.read_only"
                  :name="item.nm_chave"
                />
                <q-toggle
                  v-else-if="item.nm_tipo_atributo === 'toggle'"
                  v-model="item.nm_valor"
                  :label="item.nm_label"
                />
              </div>
            </div>
            <q-btn
              class="q-mt-md margin1"
              rounded
              color="orange-9"
              text-color="white"
              label="Salvar"
            />
            <q-btn
              class="q-mt-md margin1"
              rounded
              flat
              color="orange-9"
              label="Cancelar"
            />
          </div>
        </div>
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
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxSelection,
  DxStateStoring,
  DxSearchPanel,
} from "devextreme-vue/data-grid";
import select from "../http/select";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";

export default {
  name: "controleUsuarios",
  components: {
    grid: () => import("../views/grid"),
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
  },
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_api: "943/1456",
      linha_selecionada: [],
      dataSourceGrid: [],
      columns: [],
      index: 0,
      subTabIndex: 0,
      infoSelect: false,
      lookupSelected: {},
      group: {
        lookup_departamento: [],
        lookup_grupo_usuario_usuario: [],
        lookup_usuario_empresa: [],
        lookup_grupo_usuario_empresa: [],
      },
      lookupsOriginal: {},
      lookups: {
        cd_departamento: [],
        cd_grupo_usuario: [],
      },
      subIndex: {
        cd_tabsheet: 0,
        nm_tabsheet: "Dados",
        ic_icone: "S",
        nm_icone_tabsheet: "domain",
        cd_tabela: 5112,
      },
      table: {},
      tabsheets: [
        {
          cd_tabsheet: 0,
          nm_tabsheet: "Usuários",
          ic_icone: "S",
          nm_icone_tabsheet: "person",
          cd_tabela: 44,
          subTabsheet: [
            {
              cd_tabsheet: 0,
              nm_tabsheet: "Dados",
              ic_icone: "S",
              nm_icone_tabsheet: "domain",
              dataset: "grid",
            },
            {
              cd_tabsheet: 1,
              nm_tabsheet: "Cadastro",
              ic_icone: "S",
              nm_icone_tabsheet: "functions",
              dataset: {
                campos: [
                  {
                    nm_chave: "cd_usuario",
                    nm_valor: "",
                    nm_label: "Código do Usuário",
                    nm_datatype: "string",
                    read_only: true,
                    cd_atributo: 1,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "nm_usuario",
                    nm_valor: "",
                    nm_label: "Nome do Usuário",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 2,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "ic_ativo",
                    nm_valor: "",
                    nm_label: "Ativo",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 3,
                    nm_tipo_atributo: "toggle",
                    falseValue: "I",
                    trueValue: "A",
                  },
                  {
                    nm_chave: "nm_fantasia_usuario",
                    nm_valor: "",
                    nm_label: "Login",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 4,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "dt_nascimento_usuario",
                    nm_valor: "",
                    nm_label: "Data de nascimento",
                    nm_datatype: "date",
                    read_only: false,
                    cd_atributo: 5,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "nm_identificacao_usuario",
                    nm_valor: "",
                    nm_label: "Identificação Login Banco",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 6,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "",
                    nm_valor: "",
                    nm_label: "Senha Desktop",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 7,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "cd_senha_repnet_usuario",
                    nm_valor: "",
                    nm_label: "Senha Web/Mobile",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 8,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "cd_departamento",
                    nm_valor: "",
                    nm_label: "Departamento",
                    nm_datatype: "string",
                    options: "lookup_departamento",
                    ["option-value"]: "cd_departamento",
                    ["option-label"]: "nm_departamento",
                    read_only: false,
                    cd_atributo: 9,
                    nm_tipo_atributo: "select",
                    ic_info: false,
                  },
                  {
                    nm_chave: "nm_email_usuario",
                    nm_valor: "",
                    nm_label: "Email",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 10,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "cd_telefone_usuario",
                    nm_valor: "",
                    nm_label: "Telefone",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 11,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "cd_celular_usuario",
                    nm_valor: "",
                    nm_label: "Celular",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 12,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "",
                    nm_valor: "",
                    nm_label: "Empresas",
                    nm_datatype: "object",
                    options: "lookup_usuario_empresa",
                    ["option-value"]: "cd_empresa",
                    ["option-label"]: "nm_empresa",
                    read_only: false,
                    cd_atributo: 13,
                    nm_tipo_atributo: "select",
                    multiple: true,
                    mapOptions: true,
                    ic_info: true,
                    nm_referencia_info: "cd_empresa_usuario",
                  },
                  {
                    nm_chave: "",
                    nm_valor: "",
                    nm_label: "Grupo de Usuário (Empresa)",
                    nm_datatype: "object",
                    options: "lookup_grupo_usuario_empresa",
                    ["option-value"]: "cd_grupo_usuario",
                    ["option-label"]: "nm_grupo_usuario",
                    read_only: false,
                    cd_atributo: 14,
                    nm_tipo_atributo: "select",
                    ic_info: true,
                    nm_referencia_info: "cd_usuario_empresa_grupo_usuario",
                  },
                  {
                    nm_chave: "",
                    nm_valor: "",
                    nm_label: "Grupo de Usuário",
                    nm_datatype: "object",
                    options: "lookup_grupo_usuario_usuario",
                    ["option-value"]: "cd_grupo_usuario",
                    ["option-label"]: "nm_grupo_usuario",
                    read_only: false,
                    cd_atributo: 15,
                    nm_tipo_atributo: "select",
                    ic_info: false,
                    nm_referencia_info: "cd_grupo_usuario_usuario",
                  },
                ],
              },
            },
            {
              cd_tabsheet: 2,
              nm_tabsheet: "Parametros",
              ic_icone: "S",
              nm_icone_tabsheet: "list_alt",
              dataset: {
                campos: [
                  {
                    nm_chave: "ic_controle_aniversario",
                    nm_valor: "",
                    nm_label: "Controle Aniversário",
                    nm_datatype: "boolean",
                    read_only: false,
                    cd_atributo: 1,
                    nm_tipo_atributo: "toggle",
                    falseValue: "N",
                    trueValue: "S",
                  },
                  {
                    nm_chave: "ic_dica_dia",
                    nm_valor: "",
                    nm_label: "Dica do Dia",
                    nm_datatype: "boolean",
                    read_only: false,
                    cd_atributo: 2,
                    nm_tipo_atributo: "toggle",
                    falseValue: "N",
                    trueValue: "S",
                  },
                  {
                    nm_chave: "nm_assinatura_usuario",
                    nm_valor: "",
                    nm_label: "Assinatura Eletrônica",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 3,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "nm_token",
                    nm_valor: "",
                    nm_label: "Token para API",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 4,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "",
                    nm_valor: "",
                    nm_label: "Alterar senha no próximo login",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 5,
                  },
                  {
                    nm_chave: "ic_ocorrencia_usuario",
                    nm_valor: "",
                    nm_label: "Opera controle de ocorrências",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 6,
                  },
                  {
                    nm_chave: "ic_lembrete_usuario",
                    nm_valor: "",
                    nm_label: "Lembrete",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 7,
                  },
                  {
                    nm_chave: "ic_multi_idioma_usuario",
                    nm_valor: "",
                    nm_label: "Multi - Lingual",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 8,
                  },
                  {
                    nm_chave: "ic_autoriza_pagamento",
                    nm_valor: "",
                    nm_label: "Autoriza Pagamentos",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 9,
                  },
                  {
                    nm_chave: "ic_instrucao_usuario",
                    nm_valor: "",
                    nm_label: "Emitente Instrução Interna",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 10,
                  },
                  {
                    nm_chave: "ic_exportacao_usuario",
                    nm_valor: "",
                    nm_label: "Exportação de Dados",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 11,
                  },
                  {
                    nm_chave: "ic_email_usuario",
                    nm_valor: "",
                    nm_label: "Envio Email",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 12,
                  },
                  {
                    nm_chave: "ic_acesso_padrao_usuario",
                    nm_valor: "",
                    nm_label: "Acesso padrão automático",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 13,
                  },
                  {
                    nm_chave: "ic_bloqueio_vendedor",
                    nm_valor: "",
                    nm_label: "Bloqueia a Alteração de Vendedor",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 14,
                  },
                  {
                    nm_chave: "ic_aprovacao_orcamento",
                    nm_valor: "",
                    nm_label: "Aprovação de Orçamentos",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 15,
                  },
                  {
                    nm_chave: "cd_cargo_empresa",
                    nm_valor: "",
                    nm_label: "Cargo",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 16,
                  },
                  {
                    nm_chave: "cd_centro_custo",
                    nm_valor: "",
                    nm_label: "Centro de Custo",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 17,
                  },
                  {
                    nm_chave: "cd_vendedor",
                    nm_valor: "",
                    nm_label: "Vendedor",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 18,
                  },
                  {
                    nm_chave: "cd_vendedor",
                    nm_valor: "",
                    nm_label: "Comprador",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 19,
                  },
                  {
                    nm_chave: "cd_projetista",
                    nm_valor: "",
                    nm_label: "Projetista",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 20,
                  },
                  {
                    nm_chave: "cd_tipo_aprovacao",
                    nm_valor: "",
                    nm_label: "Tipo de Aprovação",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 21,
                  },
                  {
                    nm_chave: "cd_idioma",
                    nm_valor: "",
                    nm_label: "Idioma Padrão",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 22,
                  },
                  {
                    nm_chave: "cd_funcionario",
                    nm_valor: "",
                    nm_label: "Funcionário",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 23,
                  },
                  {
                    nm_chave: "cd_maquina",
                    nm_valor: "",
                    nm_label: "Máquina",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 24,
                  },
                  {
                    nm_chave: "cd_portaria",
                    nm_valor: "",
                    nm_label: "Portaria",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 25,
                  },
                  {
                    nm_chave: "ic_sorteio_usuario",
                    nm_valor: "",
                    nm_label: "Usuário para Sorteio",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 26,
                  },
                  {
                    nm_chave: "ic_chat_usuario",
                    nm_valor: "",
                    nm_label: "Operador de Atendimento/Chat",
                    nm_datatype: "string",
                    read_only: false,
                    cd_atributo: 27,
                  },
                ],
              },
            },
          ],
        },
        {
          cd_tabsheet: 1,
          nm_tabsheet: "Grupo de Usuários",
          ic_icone: "S",
          nm_icone_tabsheet: "group",
          cd_tabela: 736,
          subTabsheet: [
            {
              cd_tabsheet: 0,
              nm_tabsheet: "Dados",
              ic_icone: "S",
              nm_icone_tabsheet: "domain",
              dataset: "grid",
            },
            {
              cd_tabsheet: 1,
              nm_tabsheet: "Cadastro",
              ic_icone: "S",
              nm_icone_tabsheet: "functions",
              dataset: {
                campos: [
                  {
                    nm_chave: "cd_grupo_usuario",
                    nm_valor: "",
                    nm_label: "Código do Grupo de Usuário",
                    nm_datatype: "string",
                    cd_atributo: 1,
                    read_only: true,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "nm_grupo_usuario",
                    nm_valor: "",
                    nm_label: "Nome do Grupo de Usuário",
                    nm_datatype: "string",
                    cd_atributo: 2,
                    read_only: false,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "sg_grupo_usuario",
                    nm_valor: "",
                    nm_label: "Sigla do Grupo de Usuário",
                    nm_datatype: "string",
                    cd_atributo: 3,
                    read_only: false,
                    nm_tipo_atributo: "input",
                  },
                  {
                    nm_chave: "ic_tipo_grupo_usuario",
                    nm_valor: "",
                    nm_label: "Tipo de Grupo de Usuário",
                    nm_datatype: "string",
                    cd_atributo: 4,
                    read_only: false,
                    nm_tipo_atributo: "toggle",
                    falseValue: "P",
                    trueValue: "S",
                  },
                  {
                    nm_chave: "ic_usuario_internet",
                    nm_valor: "",
                    nm_label: "Usuário Internet",
                    nm_datatype: "string",
                    cd_atributo: 5,
                    read_only: false,
                    nm_tipo_atributo: "toggle",
                    falseValue: "N",
                    trueValue: "S",
                  },
                  {
                    nm_chave: "ic_periodo_internet",
                    nm_valor: "",
                    nm_label: "Período Internet",
                    nm_datatype: "string",
                    cd_atributo: 6,
                    read_only: false,
                    nm_tipo_atributo: "toggle",
                    falseValue: "N",
                    trueValue: "S",
                  },
                  {
                    nm_chave: "ic_modulo_internet",
                    nm_valor: "",
                    nm_label: "Módulo Internet",
                    nm_datatype: "string",
                    cd_atributo: 7,
                    read_only: false,
                    nm_tipo_atributo: "toggle",
                    falseValue: "N",
                    trueValue: "S",
                  },
                  {
                    nm_chave: "ic_empresa_internet",
                    nm_valor: "",
                    nm_label: "Empresa Internet",
                    nm_datatype: "string",
                    cd_atributo: 8,
                    read_only: false,
                    nm_tipo_atributo: "toggle",
                    falseValue: "N",
                    trueValue: "S",
                  },
                  {
                    nm_chave: "ic_contato_internet",
                    nm_valor: "",
                    nm_label: "Contato Internet",
                    nm_datatype: "string",
                    cd_atributo: 9,
                    read_only: false,
                    nm_tipo_atributo: "toggle",
                    falseValue: "N",
                    trueValue: "S",
                  },
                  {
                    nm_chave: "",
                    nm_valor: "",
                    nm_label: "Modulo x Grupo de Usuário",
                    nm_datatype: "object",
                    options: "lookup_modulo_grupo_usuario",
                    ["option-value"]: "cd_modulo",
                    ["option-label"]: "nm_modulo",
                    read_only: false,
                    cd_atributo: 10,
                    nm_tipo_atributo: "select",
                    ic_info: true,
                    nm_referencia_info: "cd_modulo_grupo_usuario",
                  },
                  {
                    nm_chave: "",
                    nm_valor: "",
                    nm_label: "Empresa x Grupo de Usuário",
                    nm_datatype: "object",
                    options: "lookup_empresa_grupo_usuario",
                    ["option-value"]: "cd_empresa",
                    ["option-label"]: "nm_empresa",
                    read_only: false,
                    cd_atributo: 11,
                    nm_tipo_atributo: "select",
                    ic_info: true,
                    nm_referencia_info: "cd_empresa_grupo_usuario",
                  },
                  {
                    nm_chave: "",
                    nm_valor: "",
                    nm_label: "Etapa x Grupo de Usuário",
                    nm_datatype: "object",
                    options: "lookup_Grupo_Usuario_Etapa",
                    ["option-value"]: "cd_etapa",
                    ["option-label"]: "nm_etapa",
                    read_only: false,
                    cd_atributo: 12,
                    nm_tipo_atributo: "select",
                    ic_info: true,
                    nm_referencia_info: "cd_etapa_grupo_usuario",
                  },
                  {
                    nm_chave: "",
                    nm_valor: "",
                    nm_label: "Função x Grupo de Usuário",
                    nm_datatype: "object",
                    options: "lookup_Grupo_Usuario_Funcao",
                    ["option-value"]: "cd_funcao",
                    ["option-label"]: "nm_funcao",
                    read_only: false,
                    cd_atributo: 13,
                    nm_tipo_atributo: "select",
                    ic_info: true,
                    nm_referencia_info: "cd_funcao_grupo_usuario",
                  },
                  {
                    nm_chave: "",
                    nm_valor: "",
                    nm_label: "Menu x Grupo de Usuário",
                    nm_datatype: "object",
                    options: "lookup_Grupo_Usuario_Menu",
                    ["option-value"]: "cd_menu",
                    ["option-label"]: "nm_menu",
                    read_only: false,
                    cd_atributo: 14,
                    nm_tipo_atributo: "select",
                    ic_info: true,
                    nm_referencia_info: "cd_menu_grupo_usuario",
                  },
                  {
                    nm_chave: "",
                    nm_valor: "",
                    nm_label: "Relatório x Grupo de Usuário",
                    nm_datatype: "object",
                    options: "lookup_Grupo_Usuario_Relatorio",
                    ["option-value"]: "cd_relatorio",
                    ["option-label"]: "nm_relatorio",
                    read_only: false,
                    cd_atributo: 15,
                    nm_tipo_atributo: "select",
                    ic_info: true,
                    nm_referencia_info: "cd_relatorio_grupo_usuario",
                  },
                ],
              },
            },
            {
              cd_tabsheet: 2,
              nm_tabsheet: "Parametros",
              ic_icone: "S",
              nm_icone_tabsheet: "list_alt",
              dataset: {
                campos: [
                  {
                    nm_chave: "ic_controle_aniversario",
                    nm_valor: "",
                    nm_label: "Descritivo",
                    nm_datatype: "string",
                    cd_atributo: 1,
                  },
                  {
                    nm_chave: "ic_dica_dia",
                    nm_valor: "",
                    nm_label: "Tipo de Horário",
                    nm_datatype: "string",
                    cd_atributo: 1,
                  },
                  {
                    nm_chave: "ic_assinatura_eletronica",
                    nm_valor: "",
                    nm_label: "Horário de Acesso",
                    nm_datatype: "string",
                    cd_atributo: 1,
                  },
                  {
                    nm_chave: "ic_assinatura_eletronica",
                    nm_valor: "",
                    nm_label: "Exibe acesso usuário",
                    nm_datatype: "string",
                    cd_atributo: 1,
                  },
                  {
                    nm_chave: "ic_assinatura_eletronica",
                    nm_valor: "",
                    nm_label: "Exibe acesso período",
                    nm_datatype: "string",
                    cd_atributo: 1,
                  },
                  {
                    nm_chave: "ic_assinatura_eletronica",
                    nm_valor: "",
                    nm_label: "Exibe acesso modulos",
                    nm_datatype: "string",
                    cd_atributo: 1,
                  },
                  {
                    nm_chave: "ic_assinatura_eletronica",
                    nm_valor: "",
                    nm_label: "Exibe acesso empresas",
                    nm_datatype: "string",
                    cd_atributo: 1,
                  },
                  {
                    nm_chave: "ic_assinatura_eletronica",
                    nm_valor: "",
                    nm_label: "Exibe acesso contato",
                    nm_datatype: "string",
                    cd_atributo: 1,
                  },
                ],
              },
            },
          ],
        },
      ],
    };
  },

  computed: {
    optionGroupList() {
      return this.lookups[this.lookupSelected.options].map((opt) => ({
        label: opt[this.lookupSelected["option-label"]],
        value: opt[this.lookupSelected["option-value"]],
        ic_ativo_group: this.lookupSelected.nm_referencia_info,
      }));
    },
  },
  watch: {
    index(Novo) {
      this.changeTab(this.tabsheets[Novo]);
    },
  },
  created() {
    this.atualizaGrid();
    this.changeTab(this.tabsheets[0]);
  },
  methods: {
    async changeTab(tab) {
      await this.atualizaGrid();
      const select_table = {
        cd_empresa: 0,
        cd_tabela: tab.cd_tabela,
        order: "D",
      };
      [this.table] = await select.montarSelect("0", select_table);
      this.columns = this.table.campos.split(",").map((item) => {
        let caption = item
          .replace("tab.", "")
          .replaceAll(/_/g, " ")
          .trim()
          .slice(2);
        return {
          dataField: item.trim().replace("tab.", ""),
          caption: caption.trim().charAt(0).toUpperCase() + caption.slice(2),
          allowEditing: true,
          allowFiltering: true,
          allowSorting: true,
        };
      });
      this.subIndex = {
        cd_tabsheet: 0,
        nm_tabsheet: "Dados",
        ic_icone: "S",
        nm_icone_tabsheet: "domain",
        cd_tabela: 5112,
      };
    },
    onFocusedRowChanged: function (e) {
      this.linha_selecionada = {};
      this.linha_selecionada = e.row && e.row.data;
      this.tabsheets[this.index].subTabsheet[1].dataset.campos.map((item) => {
        if (this.linha_selecionada[item.nm_chave]) {
          if (item.nm_datatype === "date") {
            item.nm_valor = this.linha_selecionada[item.nm_chave].slice(0, 10);
          } else {
            item.nm_valor = this.linha_selecionada[item.nm_chave];
          }
        } else {
          item.nm_valor = "";
        }
        return item;
      });
    },
    async changeSubTab(subTab) {
      if (!subTab) {
        this.subIndex = 0;
        return;
      }
      this.subIndex = subTab;
      if (subTab.dataset === "grid") {
        this.dataSourceGrid = this.table.dados;
      } else {
        this.dataSourceGrid = subTab.dataset.campos;
      }

      if (subTab.cd_tabsheet === 0) {
        await this.atualizaGrid();
      } else if (subTab.cd_tabsheet === 1 || subTab.cd_tabsheet === 2) {
        await this.atualizaLookups(subTab);
      }
    },

    async atualizaGrid() {
      var tabela_json = {
        cd_parametro: 0,
        cd_usuario: localStorage.cd_usuario,
      };
      if (this.index === 0) {
        tabela_json.cd_parametro = 0;
      } else if (this.index === 1) {
        tabela_json.cd_parametro = 3;
      }
      this.dataSourceGrid = await Incluir.incluirRegistro(
        this.cd_api, //pr_egisnet_admin_controle_usuario
        tabela_json
      );
    },

    async atualizaLookups(subTab) {
      var lookup_json = {
        cd_parametro: 1,
        cd_usuario: this.linha_selecionada.cd_usuario,
      };
      if (this.index === 0) {
        lookup_json.cd_parametro = 1;
      } else if (this.index === 1) {
        lookup_json.cd_parametro = 4;
        lookup_json.cd_grupo_usuario = this.linha_selecionada.cd_grupo_usuario;
      }
      const result_cadastro = await Incluir.incluirRegistro(
        this.cd_api, //pr_egisnet_admin_controle_usuario
        lookup_json
      );

      if (this.index === 0) {
        this.lookups = {
          lookup_departamento: result_cadastro[0].lookup_departamento
            ? JSON.parse(result_cadastro[0].lookup_departamento)
            : [],
          lookup_grupo_usuario_usuario: result_cadastro[0]
            .lookup_grupo_usuario_usuario
            ? JSON.parse(result_cadastro[0].lookup_grupo_usuario_usuario)
            : [],
          lookup_usuario_empresa: result_cadastro[0].lookup_usuario_empresa
            ? JSON.parse(result_cadastro[0].lookup_usuario_empresa)
            : [],
          lookup_grupo_usuario_empresa: result_cadastro[0]
            .lookup_grupo_usuario_empresa
            ? JSON.parse(result_cadastro[0].lookup_grupo_usuario_empresa)
            : [],
        };
        this.lookupsOriginal = this.lookups["lookup_grupo_usuario_empresa"];
      } else if (this.index === 1) {
        this.lookups = {
          lookup_modulo_grupo_usuario: result_cadastro[0]
            .lookup_modulo_grupo_usuario
            ? JSON.parse(result_cadastro[0].lookup_modulo_grupo_usuario)
            : [],
          lookup_empresa_grupo_usuario: result_cadastro[0]
            .lookup_empresa_grupo_usuario
            ? JSON.parse(result_cadastro[0].lookup_empresa_grupo_usuario)
            : [],
          lookup_Grupo_Usuario_Etapa: result_cadastro[0]
            .lookup_Grupo_Usuario_Etapa
            ? JSON.parse(result_cadastro[0].lookup_Grupo_Usuario_Etapa)
            : [],
          lookup_Grupo_Usuario_Funcao: result_cadastro[0]
            .lookup_Grupo_Usuario_Funcao
            ? JSON.parse(result_cadastro[0].lookup_Grupo_Usuario_Funcao)
            : [],
          lookup_Grupo_Usuario_Menu: result_cadastro[0]
            .lookup_Grupo_Usuario_Menu
            ? JSON.parse(result_cadastro[0].lookup_Grupo_Usuario_Menu)
            : [],
          lookup_Grupo_Usuario_Relatorio: result_cadastro[0]
            .lookup_Grupo_Usuario_Relatorio
            ? JSON.parse(result_cadastro[0].lookup_Grupo_Usuario_Relatorio)
            : [],
        };
      }

      subTab.dataset.campos.forEach((campo) => {
        if (campo.nm_tipo_atributo === "select" && campo.nm_referencia_info) {
          const lista = this.lookups[campo.options];

          if (Array.isArray(lista)) {
            // Usando Set para garantir valores únicos
            const selecionados = Array.from(
              new Set(
                lista
                  .filter((lkp) => lkp[campo.nm_referencia_info] === "S")
                  .map((lkp) => lkp[campo["option-value"]])
              )
            );
            this.$set(this.group, campo.options, selecionados);
          }
        }
      });

      this.tabsheets[this.index].subTabsheet[1].dataset.campos.forEach(
        (item) => {
          if (item.nm_tipo_atributo === "select" && item.nm_valor) {
            [item.nm_valor] = this.lookups[item.options].filter((opt) => {
              if (opt[item["option-value"]] === item.nm_valor) {
                return opt;
              }
            });
          }
        }
      );
    },

    novoUsuario() {
      this.tabsheets[this.index].subTabsheet[1].dataset.campos.map((item) => {
        item.nm_valor = "";
      });
    },

    async salvarUsuario() {
      if (
        this.tabsheets[this.index].subTabsheet[1].dataset.campos.every(
          (obj) => obj.nm_valor === ""
        )
      ) {
        return notify("Preencha todos os campos antes de salvar!");
      }
      const obj_tabela = this.tabsheets[
        this.index
      ].subTabsheet[1].dataset.campos.reduce((acc, data) => {
        if (data.nm_chave && data.nm_valor) {
          acc[data.nm_chave] = data.nm_valor;
        }
        return acc;
      }, {});
      const save_json = {
        cd_parametro: this.index === 0 ? 2 : 5,
        json_usuario: obj_tabela,
        tabelas_aux: this.group,
      };
      console.log(save_json, "save_json");
      this.dataSourceGrid = await Incluir.incluirRegistro(
        this.cd_api, //pr_egisnet_admin_controle_usuario
        save_json
      );
      notify(this.dataSourceGrid[0].Msg);
    },
    infoList(item) {
      this.lookupSelected = item;
      this.infoSelect = !this.infoSelect;
    },
    onSelect(select) {
      if (select.cd_atributo === 13) {
        this.lookups["lookup_grupo_usuario_empresa"] =
          this.lookupsOriginal.filter((lkp) => {
            if (lkp.cd_empresa === select.nm_valor.cd_empresa) {
              return lkp;
            }
          });
      }
    },
  },
};
</script>

<style scoped>
@import url("../views/views.css");
</style>