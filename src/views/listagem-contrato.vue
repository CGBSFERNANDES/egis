<template>
  <div>
    <div class="row">
      <div class="col">
        <div class="text-h6 text-bold margin1">
          Ficha de Venda: {{ cd_ficha_venda }}
          <b v-if="nm_fantasia_empresa != ''">{{
            "| " + nm_fantasia_empresa
          }}</b>
          <b v-if="nm_status_contrato != ''">{{
            " | " + nm_status_contrato
          }}</b>
        </div>
      </div>
    </div>

    <!------GERAR AUTOMATICAMENTE COM V-FOR---------------------------------------------------------->

    <!----------------------------------------------------------------------------------------------->

    <q-expansion-item
      class="overflow-hidden margin1 bg-white shadow-1"
      style="border-radius: 20px; height:auto"
      header-class="bg-orange-9 text-white items-center text-h6"
      expand-icon-class="text-white"
      default-opened
      expand-separator
      icon="article"
      label="Ficha de Venda"
    >
      <div class="row justify-around">
        <q-input
          class="padding1 metadeTela response"
          :class="{ 'bg-red-2 borda': !!this.vl_total_contrato == false }"
          item-aligned
          v-model="vl_total_contrato"
          type="text"
          label="Valor Total"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="paid" />
          </template>
        </q-input>
        <q-input
          class="padding1 metadeTela response"
          :class="{ 'bg-red-2 borda': !!this.nm_administradora == false }"
          item-aligned
          v-model="nm_administradora"
          type="text"
          label="Administradora"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="business" />
          </template>
        </q-input>
      </div>
      <div class="row justify-around">
        <q-input
          class="padding1 metadeTela response"
          :class="{ 'bg-red-2 borda': !!this.nm_vendedor == false }"
          item-aligned
          v-model="nm_vendedor"
          type="text"
          label="Vendedor"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="sell" />
          </template>
        </q-input>
        <q-input
          class="padding1 metadeTela response"
          :class="{ 'bg-red-2 borda': !!this.dt_contrato == false }"
          item-aligned
          v-model="dt_contrato"
          type="text"
          label="Data da Venda"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="event" />
          </template>
        </q-input>
        <q-input
          class="padding1 metadeTela response"
          :class="{ 'bg-red-2 borda': !!this.nm_indicador == false }"
          item-aligned
          v-model="nm_indicador"
          type="text"
          label="Captação"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="person" />
          </template>
        </q-input>
        <q-input
          class="'padding1 metadeTela response'"
          :class="{ 'bg-red-2 borda': !!this.cd_id_contrato == false }"
          item-aligned
          v-model="cd_id_contrato"
          type="text"
          label="ID"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="fingerprint" />
          </template>
        </q-input>
      </div>
    </q-expansion-item>
    <!----------------------------------------------------------------------------------------------->
    <q-expansion-item
      class="overflow-hidden margin1 bg-white shadow-1"
      style="border-radius: 20px; height:auto"
      header-class="bg-orange-9 text-white items-center text-h6"
      expand-icon-class="text-white"
      expand-separator
      v-if="dataSourceConfig.length > 0"
      default-opened
      icon="supervisor_account"
      label="Dados do Cliente"
    >
      <div class="row justify-around">
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.nm_razao_contrato == false }"
          item-aligned
          v-model="nm_razao_contrato"
          type="text"
          label="Nome Completo"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="person" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.cd_cnpj_cpf_contrato == false }"
          item-aligned
          v-model="cd_cnpj_cpf_contrato"
          type="text"
          label="CPF/CNPJ"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="description" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.cd_ie_rg_contrato == false }"
          item-aligned
          v-model="cd_ie_rg_contrato"
          v-if="cd_tipo_pessoa == 2"
          type="text"
          label="RG/IE"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="article" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.cd_cep == false }"
          item-aligned
          v-model="cd_cep"
          type="text"
          label="CEP"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="location_on" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.nm_endereco == false }"
          item-aligned
          v-model="nm_endereco"
          type="text"
          label="Endereço"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="home_work" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.cd_numero == false }"
          item-aligned
          v-model="cd_numero"
          type="text"
          label="Nº"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="pin" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.nm_complemento == false }"
          item-aligned
          v-model="nm_complemento"
          type="text"
          label="Complemento"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="article" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.nm_bairro == false }"
          item-aligned
          v-model="nm_bairro"
          type="text"
          label="Bairro"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="area_chart" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.nm_cidade == false }"
          item-aligned
          v-model="nm_cidade"
          type="text"
          label="Cidade"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="location_city" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.sg_estado == false }"
          item-aligned
          v-model="sg_estado"
          type="text"
          label="UF"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="map" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.cd_telefone == false }"
          item-aligned
          v-model="cd_telefone"
          type="text"
          label="Telefone Fixo"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="call" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.cd_celular == false }"
          item-aligned
          v-model="cd_celular"
          type="text"
          label="Celular"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="smartphone" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.nm_email == false }"
          item-aligned
          v-model="nm_email"
          type="text"
          label="E-mail"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="email" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.nm_mae == false }"
          item-aligned
          v-model="nm_mae"
          type="text"
          label="Nome da Mãe"
          v-if="cd_tipo_pessoa == 2"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="female" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.natural_estado == false }"
          item-aligned
          v-model="natural_estado"
          type="text"
          v-if="cd_tipo_pessoa == 2"
          label="Naturalidade - Estado"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="map" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.natural_cidade == false }"
          item-aligned
          v-model="natural_cidade"
          type="text"
          v-if="cd_tipo_pessoa == 2"
          label="Naturalidade - Cidade"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="my_location" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.vl_renda_mensal == false }"
          item-aligned
          v-model="vl_renda_mensal"
          type="text"
          label="Renda Mensal"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="paid" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          :class="{ 'bg-red-2 borda': !!this.vl_renda_anual == false }"
          item-aligned
          v-model="vl_renda_anual"
          type="text"
          label="Renda Anual"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="attach_money" />
          </template>
        </q-input>
      </div>
    </q-expansion-item>
    <!----------------------------------------------------------------------------------------------->
    <!----------------------------------------------------------------------------------------------->
    <q-expansion-item
      class="overflow-hidden margin1 bg-white shadow-1"
      style="border-radius: 20px; height:auto"
      header-class="bg-orange-9 text-white items-center text-h6"
      expand-icon-class="text-white"
      v-if="cd_tipo_pessoa == 1 && dataSourceConfig.length > 0"
      expand-separator
      default-opened
      icon="work"
      label="Sócio Majoritário"
    >
      <div class="row">
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="nm_razao_contrato_socio"
          type="text"
          label="Razão Social"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="person" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="cd_cnpj_cpf_contrato_socio"
          type="text"
          label="CNPJ"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="app_registration" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="dt_fundacao"
          type="text"
          label="Data de Fundação"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="event" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="cd_cep_socio"
          type="text"
          label="CEP"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="location_on" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="nm_endereco_socio"
          type="text"
          label="Endereço"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="location_on" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="cd_numero_socio"
          type="text"
          label="Nº"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="pin" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="nm_bairro_socio"
          type="text"
          label="Bairro"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="maps_home_work" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="nm_cidade_socio"
          type="text"
          label="Cidade"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="maps_home_work" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="sg_estado_socio"
          type="text"
          label="UF"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="map" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="nm_complemento_socio"
          type="text"
          label="Complemento"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="assignment" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="cd_telefone_socio"
          type="text"
          label="Telefone"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="call" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="cd_celular_socio"
          type="text"
          label="Celular"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="smartphone" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="nm_email_socio"
          type="text"
          label="E-mail"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="email" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="vl_capital_mensal"
          type="text"
          label="Renda Mensal"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="attach_money" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="vl_capital_anual"
          type="text"
          label="Renda Anual"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="monetization_on" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="pc_empresa"
          type="text"
          label="% da Empresa"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="trending_up" />
          </template>
        </q-input>
      </div>
    </q-expansion-item>
    <!--<q-expansion-item
      class="overflow-hidden metade-tela margin1 bg-white shadow-1"
      style="border-radius: 20px; height:auto"
      header-class="bg-orange-9 text-white items-center text-h6"
      expand-icon-class="text-white"
      v-if="cd_tipo_pessoa == 1 && dataSourceConfig.length > 0"
      expand-separator
      default-opened
      icon="work"
      label="Dados do Sócio Administrador"
    >
      <div class="row">
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="nm_socio_administrador"
          type="text"
          label="Nome Completo"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="engineering" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="dt_nascimento_socio"
          type="text"
          label="Data de Nascimento"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="engineering" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="cd_cpf_socio"
          type="text"
          label="CPF"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="engineering" />
          </template>
        </q-input>
        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="cd_rg_socio"
          type="text"
          label="RG"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="engineering" />
          </template>
        </q-input>

        <q-input
          class="padding1 umTercoTela response"
          item-aligned
          v-model="pc_empresa"
          type="text"
          label="% da Empresa"
          readonly
        >
          <template v-slot:prepend>
            <q-icon name="trending_up" />
          </template>
        </q-input>
      </div>
    </q-expansion-item>-->
    <!----------------------------------------------------------------------------------------------->
    <q-expansion-item
      class="overflow-hidden margin1 bg-white shadow-1"
      style="border-radius: 20px; height:auto"
      header-class="bg-orange-9 text-white items-center text-h6"
      expand-icon-class="text-white"
      expand-separator
      default-opened
      icon="description"
      label="Cotas"
    >
      <q-btn
        class="margin1"
        flat
        round
        color="orange-10"
        icon="refresh"
        @click="carregaGrids(1)"
      >
        <q-tooltip>Recarregar Cotas</q-tooltip>
      </q-btn>
      <grid
        style="border-radius: 20px; height:auto"
        v-if="mostraCota == true"
        :cd_menuID="7093"
        :cd_apiID="492"
        :filterGrid="false"
        :cd_parametroID="this.cd_ficha_venda"
        ref="grid_cota"
        :nm_json="{}"
      />
    </q-expansion-item>
    <!----------------------------------------------------------------------------------------------->
    <q-expansion-item
      class="overflow-hidden margin1 bg-white shadow-1"
      style="border-radius: 20px; height:auto"
      header-class="bg-orange-9 text-white items-center text-h6"
      expand-icon-class="text-white"
      expand-separator
      default-opened
      icon="group"
      label="Divisão de Venda"
    >
      <q-btn
        class="margin1"
        flat
        round
        color="orange-10"
        icon="refresh"
        @click="carregaGrids(2)"
      >
        <q-tooltip>Recarregar Divisão de venda</q-tooltip>
      </q-btn>
      <grid
        style="border-radius: 20px; height:auto"
        :cd_menuID="7054"
        :cd_apiID="463"
        :filterGrid="false"
        :cd_parametroID="this.cd_ficha_venda"
        ref="divisaovenda"
        :nm_json="{}"
      />
    </q-expansion-item>
    <!----------------------------------------------------------------------------------------------->
    <q-expansion-item
      class="overflow-hidden margin1 bg-white shadow-1"
      style="border-radius: 20px; height:auto"
      header-class="bg-orange-9 text-white items-center text-h6"
      expand-icon-class="text-white"
      expand-separator
      default-opened
      icon="folder"
      label="Documentos"
    >
      <div
        class="row items-center"
        v-for="(b, index) in lista_documentos"
        :key="index"
      >
        <div class="col margin1 text-subtitle2">
          {{ b.nm_contrato_documento }}
        </div>
        <div class="margin1">
          <q-icon
            color="orange-10"
            size="md"
            class="margin1"
            name="cloud_download"
            @click="Download(b)"
          />
        </div>
      </div>
    </q-expansion-item>
    <!----------------------------------------------------------------------------------------------->

    <div class="row items-center margin1">
      <q-input
        class="col margin1"
        v-model="justificativa"
        label="Observações"
        autogrow
      >
        <template v-slot:prepend>
          <q-icon name="article" />
        </template>
      </q-input>
      <div class="col items-end">
        <q-btn
          class="margin1"
          style="float:right"
          color="positive"
          icon="check"
          rounded
          label="Aprovar"
          @click="onClickAprovar($event)"
          v-close-popup
        />
        <q-btn
          class="margin1"
          style="float:right"
          color="negative"
          icon="close"
          rounded
          label="Declinar"
          @click="onClickDeclinar($event)"
          v-close-popup
        />
        <q-btn
          class="margin1"
          style="float:right"
          rounded
          color="primary"
          icon="live_help"
          label="Aprovado com pendência"
          @click="onClickPendencia($event)"
          v-close-popup
        />
      </div>
    </div>
    <!----------------------------------------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando :mensagemID="'Carregando Ficha de venda'"></carregando>
    </q-dialog>
  </div>
</template>

<script>
import Incluir from "../http/incluir_registro";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import ExcelJS from "exceljs";
import grid from "../views/grid.vue";
import funcao from "../http/funcoes-padroes";
import notify from "devextreme/ui/notify";
import ftp from "../http/ftp.js";

let dados = [];
let sParametroApi = "";

export default {
  props: {
    prop_listagem: { type: Object, default: {} },
  },
  name: "listagem",
  components: {
    grid,
    carregando: () => import("../components/carregando.vue"),
  },

  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_cliente: localStorage.cd_cliente,
      api: "442/597", //Procedimento - 1323 - pr_consulta_ficha_venda
      cd_menu: localStorage.cd_menu,
      dataSourceConfig: [],
      cd_cep: " ",
      cd_cliente: "",
      cd_cnpj_cpf_contrato: " ",
      lista_documentos: [],
      load: false,
      cd_contrato: "",
      mostraCota: false,
      cd_id_contrato: " ",
      cd_ie_rg_contrato: " ",
      cd_numero: " ",
      cd_tabela: "",
      cd_grupo_contrato: "",
      cd_rg_socio: " ",
      cd_cpf_socio: " ",
      nm_socio_administrador: " ",
      dt_nascimento_socio: " ",
      cd_telefone: " ",
      vl_capital_mensal: " ",
      vl_capital_anual: " ",
      cd_celular: " ",
      nm_email: " ",
      nm_profissao: " ",
      nm_estado_civil: " ",
      cd_tipo_pessoa: 0,
      dt_contrato: " ",
      dt_nascimento: " ",
      ic_seguro_contrato: "",
      nm_administradora: " ",
      nm_bairro: " ",
      nm_cidade: " ",
      sg_estado: " ",
      nm_cargo: " ",
      nm_endereco: " ",
      nm_complemento: " ",
      nm_fantasia_empresa: "",
      nm_razao_contrato: " ",
      nm_razao_contrato_socio: " ",
      cd_cnpj_cpf_contrato_socio: " ",
      cd_cep_socio: " ",
      nm_endereco_socio: " ",
      cd_numero_socio: " ",
      nm_bairro_socio: " ",
      nm_cidade_socio: " ",
      nm_complemento_socio: " ",
      sg_estado_socio: " ",
      cd_telefone_socio: " ",
      cd_celular_socio: " ",
      nm_email_socio: " ",
      nm_ref_contrato: "",
      nm_status_contrato: "",
      dt_fundacao: "",
      nm_tabela: "",
      nm_tipo_pedido: "",
      justificativa: "",
      nm_vendedor: " ",
      pc_empresa: " ",
      nm_mae: " ",
      natural_estado: " ",
      natural_cidade: " ",
      vl_renda_mensal: " ",
      vl_renda_anual: " ",
      qt_prazo_contrato: "",
      vl_contrato: "",
      vl_total_contrato: " ",
      nm_indicador: " ",
      cd_ficha_venda: 0,
    };
  },
  async created() {
    this.cd_ficha_venda = this.prop_listagem.cd_documento;

    if (this.cd_ficha_venda != 0) {
      await this.showMenu();
      this.mostraCota = true;
      await funcao.sleep(3000);
      var tamanho = this.$refs.grid_cota.DataSource();

      if (tamanho == 0) {
        await this.$refs.grid_cota.carregaDados();
      }
    }
  },

  methods: {
    async Download(b) {
      notify("Baixando...");
      this.carregando = true;
      try {
        let blob = await ftp.Download(this.cd_empresa, b.nm_obs_documento);
        const link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.download = b.nm_contrato_documento;
        link.click();
        URL.revokeObjectURL(link.href);
        this.carregando = false;
      } catch (error) {
        this.carregando = false;
      }
    },
    async ConsultaDoc() {
      notify("Carregando documentos...");
      this.lista_documentos = [];
      let c = {
        cd_parametro: 9,
        cd_contrato: this.cd_ficha_venda,
      };
      this.lista_documentos = await Incluir.incluirRegistro("606/844", c);
      notify("Documentos Carregados");
    },

    async onClickPendencia() {
      let jus;
      if (this.justificativa == "") {
        jus = "null";
      } else {
        jus = this.justificativa;
      }

      localStorage.cd_parametro = this.cd_ficha_venda;
      localStorage.nm_documento = jus;
      var api_aprovar = "462/638"; //1339 -
      var param_api =
        "/${cd_empresa}/${cd_parametro}/${nm_documento}/${cd_usuario}/${cd_tipo_consulta}";
      this.GridFlag = false;
      localStorage.cd_tipo_consulta = 3;

      var pendencia = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        api_aprovar,
        param_api
      );

      notify(pendencia[0].Msg);
      localStorage.cd_parametro = 0;
      localStorage.nm_documento = "";
      this.justificativa = "";
      this.contrato_selecionado = {};
    },

    async onClickDeclinar() {
      let jus;
      if (this.justificativa == "") {
        jus = "null";
      } else {
        jus = this.justificativa;
      }

      localStorage.cd_parametro = this.cd_ficha_venda;
      localStorage.nm_documento = jus;
      var api_aprovar = "462/638";
      var param_api =
        "/${cd_empresa}/${cd_parametro}/${nm_documento}/${cd_usuario}/${cd_tipo_consulta}";
      this.GridFlag = false;
      localStorage.cd_tipo_consulta = 1;
      var declinio = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        api_aprovar,
        param_api
      );

      notify(declinio[0].Msg);
      localStorage.cd_parametro = 0;
      localStorage.nm_documento = "";
      this.justificativa = "";
      this.contrato_selecionado = {};

      //  notify('Contrato Declinado')
    },
    async onClickAprovar() {
      if (this.justificativa == "") {
        this.justificativa = "null";
      }
      localStorage.cd_tipo_consulta = 0;
      localStorage.cd_parametro = this.cd_ficha_venda;

      localStorage.nm_documento = this.justificativa;
      this.GridFlag = false;
      var api_aprovar = "462/638"; //1339 - pr_aprova_contrato_consorcio
      var param_api =
        "/${cd_empresa}/${cd_parametro}/${nm_documento}/${cd_usuario}/${cd_tipo_consulta}";
      var aprovado = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        api_aprovar,
        param_api
      );

      notify(`Registro atualizado com sucesso!`);
      localStorage.cd_parametro = 0;
      localStorage.nm_documento = "";
      this.justificativa = "";
    },

    async carregaGrids(index) {
      if (index == 1) {
        notify("Aguarde...");
        await this.$refs.grid_cota.carregaDados();
      } else if (index == 2) {
        await this.$refs.divisaovenda.carregaDados();
      }
    },
    async showMenu() {
      dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 442); //'titulo';

      sParametroApi = dados.nm_api_parametro;
      this.carregadados();
    },

    async carregadados() {
      this.load = true;
      localStorage.cd_parametro = 1;
      localStorage.cd_identificacao = this.cd_ficha_venda;

      this.dataSourceConfig = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        this.cd_cliente,
        this.api,
        sParametroApi
      );
      this.load = false;
      this.cd_tipo_pessoa = this.dataSourceConfig[0].cd_tipo_pessoa;
      this.vl_total_contrato = this.dataSourceConfig[0].vl_total_contrato;
      this.nm_administradora = this.dataSourceConfig[0].nm_administradora;
      this.nm_vendedor = this.dataSourceConfig[0].nm_vendedor;
      this.dt_contrato = this.dataSourceConfig[0].dt_contrato;
      this.cd_id_contrato = this.dataSourceConfig[0].cd_id_contrato;
      this.nm_indicador = this.dataSourceConfig[0].nm_indicador;
      this.nm_ref_contrato = this.dataSourceConfig[0].nm_ref_contrato;
      this.nm_razao_contrato = this.dataSourceConfig[0].nm_razao_social_cliente;
      if (this.cd_tipo_pessoa == 1 && !!this.cd_cnpj_cpf_contrato != false) {
        this.cd_cnpj_cpf_contrato = await funcao.FormataCNPJ(
          this.dataSourceConfig[0].cd_cnpj_cliente
        );
      } else {
        this.cd_cnpj_cpf_contrato = await funcao.FormataCPF(
          this.dataSourceConfig[0].cd_cnpj_cliente
        );
      }

      this.cd_ie_rg_contrato = this.dataSourceConfig[0].cd_inscestadual;
      this.cd_cep = this.dataSourceConfig[0].cd_cep_cliente;
      this.nm_endereco = this.dataSourceConfig[0].nm_endereco_cliente;
      this.cd_numero = this.dataSourceConfig[0].cd_numero_endereco;
      this.nm_complemento = this.dataSourceConfig[0].nm_complemento_endereco;
      this.nm_bairro = this.dataSourceConfig[0].nm_bairro_cliente;
      this.nm_cidade = this.dataSourceConfig[0].nm_cidade_cliente;
      this.sg_estado = this.dataSourceConfig[0].nm_estado_cliente;
      this.cd_telefone = this.dataSourceConfig[0].cd_telefone_cliente;
      this.cd_celular = this.dataSourceConfig[0].cd_celular_cliente;
      this.nm_email = this.dataSourceConfig[0].nm_email_cliente;
      this.nm_mae = this.dataSourceConfig[0].nm_mae;
      this.natural_estado = this.dataSourceConfig[0].nm_estado_nascimento;
      this.natural_cidade = this.dataSourceConfig[0].nm_cidade_nascimento;
      this.vl_renda_mensal = this.dataSourceConfig[0].vl_renda_mensal;
      this.vl_renda_anual = this.dataSourceConfig[0].vl_renda_anual;

      this.nm_razao_contrato_socio = this.dataSourceConfig[0].nm_razao_contrato;

      //if (this.cd_tipo_pessoa == 1) {
      //  this.cd_cnpj_cpf_contrato_socio = await funcao.FormataCNPJ(
      //    this.dataSourceConfig[0].cd_cnpj_cpf_contrato
      //      .replaceAll(".", "")
      //      .replaceAll("-", "")
      //  );
      //}

      this.dt_nascimento = this.dataSourceConfig[0].dt_nascimento_socio;
      this.cd_cep_socio = this.dataSourceConfig[0].cd_cep_socio;
      this.nm_endereco_socio = this.dataSourceConfig[0].nm_endereco_socio;
      this.cd_numero_socio = this.dataSourceConfig[0].cd_numero_socio;
      this.nm_bairro_socio = this.dataSourceConfig[0].nm_bairro_socio;
      this.nm_cidade_socio = this.dataSourceConfig[0].nm_cidade_socio;
      this.nm_complemento_socio = this.dataSourceConfig[0].nm_complemento_socio;
      this.sg_estado_socio = this.dataSourceConfig[0].cd_estado;
      this.pc_empresa = this.dataSourceConfig[0].pc_empresa;
      this.cd_telefone_socio = this.dataSourceConfig[0].cd_telefone_socio;
      this.cd_celular_socio = this.dataSourceConfig[0].cd_celular_socio;
      this.nm_estado_civil = this.dataSourceConfig[0].nm_estado_civil_socio;
      this.nm_email_socio = this.dataSourceConfig[0].nm_email_socio;
      this.nm_cargo = this.dataSourceConfig[0].nm_cargo_socio;
      this.nm_profissao = this.dataSourceConfig[0].nm_profissao_socio;
      this.cd_numero_socio = this.dataSourceConfig[0].cd_numero_socio;
      this.nm_tabela = this.dataSourceConfig[0].nm_tabela;
      this.cd_tabela = this.dataSourceConfig[0].cd_tabela;
      this.cd_grupo_contrato = this.dataSourceConfig[0].cd_grupo_contrato;
      //this.dt_contrato                = this.dataSourceConfig[0].dt_parc_contrato
      this.qt_prazo_contrato = this.dataSourceConfig[0].qt_prazo_contrato;
      this.ic_seguro_contrato = this.dataSourceConfig[0].ic_seguro_contrato;
      this.dt_fundacao = this.dataSourceConfig[0].dt_nascimento_socio;
      this.vl_capital_mensal = this.dataSourceConfig[0].vl_renda_mensal;
      this.vl_capital_anual = this.dataSourceConfig[0].vl_renda_anual;

      await this.carregaGrids(1);
      await this.carregaGrids(2);
      await this.ConsultaDoc();
    },

    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Consulta");

      exportDataGrid({
        component: e.component,
        worksheet: worksheet,
        autoFilterEnabled: true,
      }).then(function() {
        // https://github.com/exceljs/exceljs#writing-xlsx
        workbook.xlsx.writeBuffer().then(function(buffer) {
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
.padding1 {
  padding: 0.3% 0.8%;
}

#data-pop {
  flex-direction: none !important;
  width: 310px;
  overflow-x: hidden;
}
</style>
