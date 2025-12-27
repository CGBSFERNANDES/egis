<template>
  
  <div class="pj-wrap">
    <div class="row items-center no-wrap toolbar-scroll">
  <h2 class="content-block col-12 row items-center no-wrap">

    <q-btn
      flat round dense icon="arrow_back"
      class="q-mr-sm seta-form"
      aria-label="Voltar"
      @click="onVoltar"
    />

    <span class="pj-ico">🏢</span>
    <span class="text-weight-bold" style="margin-left: 5px">Cadastro</span>
        <div class="pj-title">
          <div class="pj-h2" style="margin-left: 5px">Pessoa Jurídica (CNPJ)</div>
      </div>  
    <q-space />

    <q-btn dense rounded color="deep-purple-7" icon="search" class="q-ml-sm" size="lg"
      @click="acaoConsultar" >
      <q-tooltip>Consultar</q-tooltip>
    </q-btn>

    <q-btn dense rounded color="deep-purple-7" icon="save" class="q-ml-sm" size="lg" :loading="loadingPJ" @click="salvarPessoaJuridica">
      <q-tooltip>Salvar</q-tooltip>
    </q-btn>
    
<q-btn
  dense
  rounded
  color="deep-purple-7"
  icon="people"
  class="q-ml-sm" size="lg"
  :loading="loadingPessoas"
  @click="abrirPessoas()"
>
  <q-tooltip>Pessoas para validar</q-tooltip>
</q-btn>


<q-btn
  dense
  rounded
  color="deep-purple-7"
  icon="playlist_add_check"
 class="q-ml-sm" size="lg"
  :loading="loadingValidar"
  :disable="loadingPessoas || !pessoasValidar || pessoasValidar.length === 0"
  @click="validar5ParaFila()"
/>
  <q-tooltip>Pessoas para validar</q-tooltip>
  <q-chip
        v-if="cdMenu"
        dense
        rounded
        color="deep-purple-7"
        class="q-mt-sm q-ml-sm margin-menu"
        size="16px"
        text-color="white"
        :label="`${cdMenu || cd_menu}`"
      />
      


  </h2>
</div>

    <!-- Abas (igual pesquisaCNPJ.html) -->
    <nav
      v-if="false" 
      class="pj-nav">
      <span class="pj-tab" :class="{active: aba==='individual'}" @click="aba='individual'">🔍 Individual</span>
      <span class="pj-tab" :class="{active: aba==='lote'}" @click="aba='lote'">📂 Lote</span>
      <span class="pj-tab" :class="{active: aba==='fila'}" @click="abrirFila()">🗂️ Fila</span>
    </nav>

    <!-- INDIVIDUAL -->
    <section v-show="aba==='individual'" class="pj-section">
      <div >
        <input
          v-model="cnpjInput"
          class="pj-input"
          style="margin-right: 10px"
          placeholder="Digite o CNPJ ..."
          @keyup.enter="consultarCNPJ()"
        />
        <button class="btn primary" @click="acaoConsultar()">Consultar</button>
        <button class="btn" @click="limparConsulta(true)">Limpar</button>
        <button class="btn" @click="salvarDados()" :disabled="!dadosEmpresa">Salvar Dados</button>
        <button class="btn" @click="gerarComprovante()" :disabled="!dadosEmpresa">📄 Comprovante</button>

      </div>

<div class="pj-split">

  <!-- ESQUERDA: Cards (consulta antiga) -->
  <div 
     class="pj-left"
     v-if="false && resultadoHtml">
    <div v-html="resultadoHtml"></div>
  </div>

<q-card
  v-if="formBasico.cd_CNPJ !=''" 
   class="q-pa-md" style="margin-top: 10px">
  <q-card-section class="row no-wrap items-start q-gutter-md">

    <!-- Ícone (igual modal/nota) -->
    <div class="col-auto flex flex-center bg-deep-purple-1 q-pa-lg" style="border-radius: 80px;">
      <q-icon name="badge" size="56px" color="deep-purple-7" />
    </div>

    <div class="col">

      <!-- Campo CNPJ (mesmo input feel) -->
      <div class="row q-col-gutter-sm items-center">
       
        <!-- Só aparece quando NÃO existe cadastro (param2 vazio) -->
       
        <div class="col-12 col-md-5" v-if="!existeCadastro">
          <q-select
            v-model="tipoDestinatarioSelecionado"
            :options="tiposDestinatarioOptions"
            dense outlined
            label="Tipo de Destinatário"
            emit-value map-options
          />
        </div>
      </div>

      <q-separator spaced class="" color="deep-purple-7" style="margin-top: 5px" />

        <q-banner
  v-if="analiseResumo"
  rounded
  class="bg-orange-2 text-grey-10 q-mb-md"
>
  <div class="text-weight-bold">⚠️ Divergências encontradas</div>
  <div style="white-space: pre-line;" class="q-mt-xs">{{ analiseResumo }}</div>
</q-banner>


      <!-- Tabs por TipoDestinatario -->

      <q-tabs v-model="tabPJ" dense active-color="deep-purple-7"
              style="margin-top: 15px" 
              indicator-color="deep-purple-7" align="left">

        <q-tab name="receita" label="Receita" />
        <q-tab name="cliente" label="Cliente" v-if="tabsAtivas.cliente" :class="{ 'tab-alerta': difCliente }" />
        <q-tab name="fornecedor" label="Fornecedor" v-if="tabsAtivas.fornecedor" :class="{ 'tab-alerta': difFornecedor }" />
        <q-tab name="transportadora" label="Transportadora" v-if="tabsAtivas.transportadora" :class="{ 'tab-alerta': difTransportadora }" />
        <q-tab name="pessoas" :label="`Pessoas (${pessoasCount})`" @click="carregarPessoasValidar" />

      </q-tabs>

      <q-separator class="" style="margin-bottom: 5px"/>

      <q-tab-panels v-model="tabPJ" animated>
        <q-tab-panel name="receita">
          <div class="row q-col-gutter-sm">
            <div class="col-12 col-md-6"><q-input v-model="pjTabs.receita.cd_CNPJ" dense outlined label="CNPJ" /></div>
            <div class="col-12 col-md-6"><q-input v-model="pjTabs.receita.nm_razao_social" dense outlined label="Razão Social" /></div>
            <div class="col-12 col-md-6"><q-input v-model="pjTabs.receita.nm_fantasia" dense outlined label="Nome Fantasia" /></div>
            <div class="col-12 col-md-6"><q-input v-model="pjTabs.receita.cd_inscestual" dense outlined label="Inscrição Estadual" /></div>

            <div class="col-12 col-md-3"><q-input v-model="pjTabs.receita.nm_cep_api" dense outlined label="CEP" /></div>
            <div class="col-12 col-md-6"><q-input v-model="pjTabs.receita.nm_endereco" dense outlined label="Endereço" /></div>
            <div class="col-12 col-md-3"><q-input v-model="pjTabs.receita.cd_numero" dense outlined label="Número" /></div>

            <div class="col-12 col-md-4"><q-input v-model="pjTabs.receita.nm_bairro" dense outlined label="Bairro" /></div>
            <div class="col-12 col-md-4"><q-input v-model="pjTabs.receita.nm_complemento" dense outlined label="Complemento" /></div>
            <div class="col-12 col-md-4"><q-input v-model="pjTabs.receita.nm_cidade" dense outlined label="Cidade" /></div>
            <div class="col-12 col-md-2"><q-input v-model="pjTabs.receita.ic_estado" dense outlined label="UF" /></div>
            <div class="col-12 col-md-6"><q-input v-model="pjTabs.receita.nm_telefone" dense outlined label="Telefone" /></div> 
            <div class="col-12 col-md-6"><q-input v-model="pjTabs.receita.nm_email" dense outlined label="E-mail" /></div> 
             <!-- Demais atributos da Receita (adicione conforme retorno da procedure) -->
            <div class="col-12 col-md-6"><q-input v-model="pjTabs.receita.nm_situacao" dense outlined label="Situação" /></div>
            <div class="col-12 col-md-6"><q-input v-model="pjTabs.receita.nm_porte" dense outlined label="Porte" /></div>
            <div class="col-12 col-md-6"><q-input v-model="pjTabs.receita.nm_natureza_j" dense outlined label="Natureza Jurídica" />
</div>

<div class="col-12 col-md-6">
 <q-input
  v-model="dtAberturaBR"
  dense
  outlined
  label="Data Abertura"
  placeholder="dd/mm/aaaa"
/>

</div>

<div class="col-12 col-md-6">
  <q-input v-model="pjTabs.receita.nm_status_insc" dense outlined label="Status IE" />
</div>

<div class="col-12 col-md-6">
 <q-input
  v-model="capitalSocialBR"
  dense
  outlined
  label="Capital Social"
  placeholder="R$ 0,00"
/>

 </div>

<div class="col-12">
  <q-input v-model="pjTabs.receita.nm_atividade" dense outlined label="Atividade Principal" />
</div>

<div class="col-12">
  <q-input v-model="pjTabs.receita.nm_atividades_s" dense outlined label="Atividades Secundárias" />
</div>

<div class="col-12">
  <q-input v-model="pjTabs.receita.nm_qsa" type="textarea" autogrow dense outlined label="QSA" />
</div>

          </div>
        </q-tab-panel>

      <q-tab-panel name="cliente" v-if="tabsAtivas.cliente">
  <div class="row q-col-gutter-sm">
    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.cliente.Cliente_RazaoSocial" dense outlined label="Razão Social" />
    </div>
    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.cliente.Cliente_Fantasia" dense outlined label="Nome Fantasia" />
    </div>

    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.cliente.Cliente_IE" dense outlined label="Inscrição Estadual" />
    </div>
     
    <div class="col-12 col-md-3">
      <q-input
        v-model="pjTabs.cliente.Cliente_CEP"
        dense outlined
        label="CEP"
      />
    </div>
    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.cliente.Cliente_Telefone" dense outlined label="Telefone" />
    </div>

    <div class="col-12 col-md-6">
<q-input
  v-model="pjTabs.cliente.Cliente_Endereco"
  dense outlined
  label="Endereço"
  :class="{ 'campo-dif': recalcularDifClienteEndereco() }"
/>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="pjTabs.cliente.Cliente_Numero" dense outlined label="Número" />
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="pjTabs.cliente.Cliente_Complemento" dense outlined label="Complemento" />
    </div>

    <div class="col-12 col-md-4">
      <q-input v-model="pjTabs.cliente.Cliente_Bairro" dense outlined label="Bairro" />
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="pjTabs.cliente.Cliente_CEP" dense outlined label="CEP" />
    </div>
  </div>
</q-tab-panel>

       <q-tab-panel name="fornecedor" v-if="tabsAtivas.fornecedor">
  <div class="row q-col-gutter-sm">
    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.fornecedor.Fornecedor_RazaoSocial" dense outlined label="Razão Social" />
    </div>
    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.fornecedor.Fornecedor_Fantasia" dense outlined label="Nome Fantasia" />
    </div>

    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.fornecedor.Fornecedor_IE" dense outlined label="Inscrição Estadual" />
    </div>
    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.fornecedor.Fornecedor_Telefone" dense outlined label="Telefone" />
    </div>
      <div class="col-12 col-md-3">
      <q-input
        v-model="pjTabs.fornecedor.Fornecedor_CEP"
        dense outlined
        label="CEP"
      />
    </div>
    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.fornecedor.Fornecedor_Endereco" dense outlined label="Endereço" />
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="pjTabs.fornecedor.Fornecedor_Numero" dense outlined label="Número" />
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="pjTabs.fornecedor.Fornecedor_Complemento" dense outlined label="Complemento" />
    </div>

    <div class="col-12 col-md-4">
      <q-input v-model="pjTabs.fornecedor.Fornecedor_Bairro" dense outlined label="Bairro" />
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="pjTabs.fornecedor.Fornecedor_CEP" dense outlined label="CEP" />
    </div>
  </div>
</q-tab-panel>

        <q-tab-panel name="transportadora" v-if="tabsAtivas.transportadora">
  <div class="row q-col-gutter-sm">
    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.transportadora.Transportadora_RazaoSocial" dense outlined label="Razão Social" />
    </div>
    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.transportadora.Transportadora_Fantasia" dense outlined label="Nome Fantasia" />
    </div>

    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.transportadora.Transportadora_IE" dense outlined label="Inscrição Estadual" />
    </div>
    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.transportadora.Transportadora_Telefone" dense outlined label="Telefone" />
    </div>

    <div class="col-12 col-md-6">
      <q-input v-model="pjTabs.transportadora.Transportadora_Endereco" dense outlined label="Endereço" />
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="pjTabs.transportadora.Transportadora_Numero" dense outlined label="Número" />
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="pjTabs.transportadora.Transportadora_Complemento" dense outlined label="Complemento" />
    </div>

    <div class="col-12 col-md-4">
      <q-input v-model="pjTabs.transportadora.Transportadora_Bairro" dense outlined label="Bairro" />
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="pjTabs.transportadora.Transportadora_CEP" dense outlined label="CEP" />
    </div>
  </div>
</q-tab-panel>


<q-tab-panel name="pessoas">
  <div class="row items-center q-mb-sm">
    <div class="text-subtitle2">
      Pessoas para validar: <b>{{ pessoasCount }}</b>
    </div>
    <q-space />
    <q-btn
      dense
      color="primary"
      icon="refresh"
      label="Atualizar"
      :loading="loadingPessoas"
      @click="carregarPessoasValidar(true)"
    />
  </div>

  <dx-data-grid
    ref="gridPessoas"
    :data-source="pessoasValidar"
    key-expr="cd_cliente"
    :show-borders="true"
    :row-alternation-enabled="true"
    :hover-state-enabled="true"
    height="420"
   selection-mode="single"
  :selected-row-keys="selectedPessoaKeys"
  @selection-changed="onPessoaSelectionChanged"
  @row-dbl-click="onValidarPessoaGrid"
  >
    <dx-load-panel :enabled="loadingPessoas" />

    <dx-paging :page-size="10" />
    <dx-pager
      :show-page-size-selector="true"
      :allowed-page-sizes="[10, 20, 50, 100]"
      :show-info="true"
    />

    <dx-column data-field="cd_cliente" caption="Código" width="90" />
    <dx-column data-field="cd_cnpj_cliente" caption="CNPJ" width="160" />
    <dx-column data-field="nm_razao_social_cliente" caption="Razão Social" />
    <dx-column
      data-field="dt_cadastro_cliente"
      caption="Cadastro"
      data-type="date"
      format="dd/MM/yyyy"
      width="130"
    />
  </dx-data-grid>
</q-tab-panel>

      </q-tab-panels>

    </div>
  </q-card-section>
</q-card>



  <!-- DIREITA: Tabs (destinatários) -->

  <div class="pj-right"
   v-if="false && formBasico.cd_CNPJ !=''"
  >
    <q-card flat bordered class="q-pa-sm">
      <q-tabs
        v-model="tabPJ"
        dense
        active-color="deep-purple-7"
        indicator-color="deep-purple-7"
        align="left"
        class="text-deep-purple-7"
      >
        <q-tab
          v-for="t in tabsDestinatario"
          :key="t.name"
          :name="t.name"
          :label="t.label"
        />
      </q-tabs>

      <q-separator />

      <q-tab-panels v-model="tabPJ" animated>
        <q-tab-panel
          v-for="t in tabsDestinatario"
          :key="t.name"
          :name="t.name"
        >
          <!-- por enquanto mostramos dados da consulta antiga -->
          <div class="text-subtitle2 q-mb-sm">{{ t.label }}</div>

          <div class="row q-col-gutter-sm">
            <div class="col-12 col-md-6">
              <q-input dense outlined label="CNPJ" v-model="formBasico.cd_CNPJ" />
            </div>
            <div class="col-12 col-md-6">
              <q-input dense outlined label="Razão Social" v-model="formBasico.nm_razao_social" />
            </div>
            <div class="col-12 col-md-6">
              <q-input dense outlined label="Nome Fantasia" v-model="formBasico.nm_fantasia" />
            </div>
            <div class="col-12 col-md-6">
              <q-input dense outlined label="IE" v-model="formBasico.cd_inscestual" />
            </div>
            <div class="col-12 col-md-4">
              <q-input dense outlined label="CEP" v-model="formBasico.nm_cep_api" />
            </div>
            <div class="col-12 col-md-8">
              <q-input dense outlined label="Endereço" v-model="formBasico.nm_endereco" />
            </div>
            <div class="col-12 col-md-3">
              <q-input dense outlined label="Número" v-model="formBasico.cd_numero" />
            </div>
            <div class="col-12 col-md-5">
              <q-input dense outlined label="Bairro" v-model="formBasico.nm_bairro" />
            </div>
            <div class="col-12 col-md-4">
              <q-input dense outlined label="Cidade" v-model="formBasico.nm_cidade" />
            </div>
            <div class="col-12 col-md-2">
              <q-input dense outlined label="UF" v-model="formBasico.ic_estado" />
            </div>
          </div>
        </q-tab-panel>
      </q-tab-panels>
    </q-card>
  </div>

</div>

      <h2>Log de Execução</h2>
      <textarea class="pj-log" rows="8" readonly :value="logs.individual"></textarea>
    </section>

    <!-- LOTE -->
    <section v-show="aba==='lote'" class="pj-section">
      <h3>Validação em Lote</h3>

      <textarea
        v-model="listaCNPJs"
        rows="6"
        class="pj-textarea"
        placeholder="Digite um CNPJ por linha"
      ></textarea>

      <div class="pj-row" style="margin-top:10px;">
        <button class="btn primary" @click="validarListaCNPJs()">Validar Lista de CNPJs</button>
        <div class="pj-status">{{ statusValidacao }}</div>
      </div>

      <div class="pj-progress">
        <label>Progresso:</label>
        <progress :value="progresso" max="100" style="width:100%;"></progress>
        <div class="pj-progress-txt">{{ progresso }}%</div>
      </div>

      <div v-html="resultadoHtml" />

      <h4>Log de Execução</h4>
      <textarea class="pj-log" rows="8" readonly :value="logs.lote"></textarea>
    </section>

    <!-- FILA -->
    <section v-show="aba==='fila'" class="pj-section">
      <h3>Fila de Validação (Automático)</h3>

      <div class="pj-row">
        <button class="btn" @click="carregarFila()">🔄 Atualizar Fila</button>
        <button class="btn primary" @click="executarFila()">▶️ Processar Fila</button>
      </div>

      <table class="pj-table">
        <thead>
          <tr>
            <th>Código</th>
            <th>CNPJ</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="f in fila" :key="f.cd_fila">
            <td>{{ f.cd_fila }}</td>
            <td>{{ f.cd_cnpj }}</td>
            <td>{{ f.nm_status_validacao }}</td>
          </tr>
        </tbody>
      </table>

      <h4>Log da Fila</h4>
      <textarea class="pj-log" rows="8" readonly :value="logs.fila"></textarea>
    </section>

    <!-- Se você quiser abrir o ModalGridComposicao para “identidade visual de pessoas”, encaixa aqui:
         <ModalGridComposicao v-if="mostrarModal" ... />
    -->
  </div>
</template>

<script>

import axios from 'axios'
import DxDataGrid, {
  DxColumn,
  DxPaging,
  DxPager,
  DxLoadPanel
} from 'devextreme-vue/data-grid'


// Se você já tem um `api` global, pode importar de lá.
// Aqui deixo um exemplo simples, igual ao estilo do UnicoFormEspecial.
const api = axios.create({
  baseURL: 'https://egiserp.com.br/api',
  withCredentials: true,
  timeout: 60000,
})

api.interceptors.request.use(cfg => {
  const banco = localStorage.nm_banco_empresa || ''
  if (banco) cfg.headers['x-banco'] = banco
  cfg.headers['Authorization'] = 'Bearer superchave123'
  if (!cfg.headers['Content-Type']) cfg.headers['Content-Type'] = 'application/json'
  return cfg
})

export default {
  name: "cadastroPessoaJuridica",
  components: {
  DxDataGrid,
  DxColumn,
  DxPaging,
  DxPager,
  DxLoadPanel
},

  data() {
    return {
      cdMenu: localStorage.cd_menu,
      aba: "individual",
      cnpjInput: "",
      listaCNPJs: "",
      statusValidacao: "",
      progresso: 0,

      // dados
      dadosEmpresa: null,
      resultadoHtml: "",

      // fila
      fila: [],

      // logs por aba
      logs: {
        individual: "",
        lote: "",
        fila: ""
      },

      // config
      bancoPadrao: "EGISCNPJ",
      chaveAPI: "08c0650c-d184-4ad8-a1ab-cedaea97345e-3bbddd92-112e-451b-b088-353eb8553493",
      headerBanco: localStorage.nm_banco_empresa,
      cdUsuario: Number(localStorage.cd_usuario || 0),

      nm_procedimento_pj: 'pr_egis_valida_cadastro_pessoa_juridica',

      cnpjInput: '',
      tabPJ: 'receita',

      tiposDestinatarioOptions: [],  // vem do cd_parametro=1
      tipoDestinatarioSelecionado: null,

    // dados por aba
    pjTabs: {
      receita: {},
      cliente: {},
      fornecedor: {},
      transportadora: {}
    },

    // flags
    existeCadastro: false,
    loadingPJ: false,
    tabPJ: 'Receita',
    tabsAtivas: {
      Receita: false,
      Cliente: false,
      Fornecedor: false,
      Transportadora: false,
    },
     pjTabs: {
      receita: {
        // deixa as chaves já criadas pra Vue não reclamar
        cd_CNPJ: '',
        nm_razao_social: '',
        nm_fantasia: '',
        cd_inscestual: '',
        nm_cep_api: '',
        nm_endereco: '',
        cd_numero: '',
        nm_bairro: '',
        nm_complemento: '',
        nm_cidade: '',
        ic_estado: '',
        nm_situacao: '',
        nm_porte: ''
      },
      cliente: {
        Cliente_Fantasia: '',
        Cliente_RazaoSocial: '',
        Cliente_IE: '',
        Cliente_Endereco: '',
        Cliente_Numero: '',
        Cliente_Complemento: '',
        Cliente_Bairro: '',
        Cliente_CEP: '',
        Cliente_Telefone: ''
      },
      fornecedor: {
        Fornecedor_Fantasia: '',
        Fornecedor_RazaoSocial: '',
        Fornecedor_IE: '',
        Fornecedor_Endereco: '',
        Fornecedor_Numero: '',
        Fornecedor_Complemento: '',
        Fornecedor_Bairro: '',
        Fornecedor_CEP: '',
        Fornecedor_Telefone: ''
      },
      transportadora: {
  Transportadora_Fantasia: '',
  Transportadora_RazaoSocial: '',
  Transportadora_IE: '',
  Transportadora_Endereco: '',
  Transportadora_Numero: '',
  Transportadora_Complemento: '',
  Transportadora_Bairro: '',
  Transportadora_CEP: '',
  Transportadora_Telefone: ''
},

    },

    rowValidacao: null,
    consultou: false,
    loadingConsulta: false,
    tabsDestinatario: [
  { name: 'receita', label: 'Receita' },
  
],

//tabPJ: 'receita',

formBasico: {
  cd_CNPJ: '',
  nm_razao_social: '',
  nm_fantasia: '',
  cd_inscestual: '',
  nm_cep_api: '',
  nm_endereco: '',
  cd_numero: '',
  nm_bairro: '',
  nm_cidade: '',
  ic_estado: ''
},
    pessoasValidar: [],
    pessoasCount: 0,
    loadingPessoas: false,
    pessoasCarregadas: false,

    paginacaoPessoas: { page: 1, rowsPerPage: 10 },

    colsPessoasValidar: [
  { name: 'cd_cliente', label: 'Código', field: 'cd_cliente', align: 'left', sortable: true },
  { name: 'cd_cnpj_cliente', label: 'CNPJ', field: 'cd_cnpj_cliente', align: 'left', sortable: true },
  { name: 'nm_razao_social_cliente', label: 'Razão Social', field: 'nm_razao_social_cliente', align: 'left', sortable: true },
  { name: 'dt_cadastro_cliente', label: 'Cadastro', field: 'dt_cadastro_cliente', align: 'left', sortable: true }
],
  loadingValidar: false,
  selectedPessoaKeys: [],
  selectedPessoaRow: null,
  //difClienteEndereco: false,
   };
  },

  created () {
  this.http = axios.create({
    baseURL: 'https://egiserp.com.br/api', // ✅ API real (não o host do front)
    withCredentials: true,
    timeout: 60000
  })

  this.http.interceptors.request.use(cfg => {
    const banco = localStorage.nm_banco_empresa || ''
    if (banco) cfg.headers['x-banco'] = banco

    // se você usa token real, pegue do localStorage/session. Exemplo:
    const token = localStorage.token || ''
    if (token) cfg.headers['Authorization'] = `Bearer ${token}`

    cfg.headers['Content-Type'] = 'application/json'
    return cfg
  })
},

  watch: {
  tabPJ (v) {
    if (v === 'pessoas') this.carregarPessoasValidar()
  }
},


  computed: {

   capitalSocialBR: {
   get () {
    const v = this.pjTabs?.receita?.vl_capital_social
    const n = Number(v)
    if (isNaN(n)) return ''
    return n.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
  },

  set (val) {
    // aceita "R$ 50.000,00", "50000", "50.000,00" etc e transforma em number
    const s = String(val || '')
      .replace(/\s/g, '')
      .replace('R$', '')
      .replace(/\./g, '')
      .replace(',', '.')
      .replace(/[^\d.]/g, '')

    const n = Number(s)
    this.pjTabs.receita.vl_capital_social = isNaN(n) ? 0 : n
  }
},

   dtAberturaBR: {
  get () {
    const v = this.pjTabs?.receita?.dt_abertura
    return this.fmtDataBR(v) // usa sua função já criada
  },
  set (val) {
    // aceita dd/mm/yyyy e converte para yyyy-mm-dd (mantém padrão do banco)
    const s = String(val || '').trim()
    const m = s.match(/^(\d{2})\/(\d{2})\/(\d{4})$/)
    if (m) {
      const iso = `${m[3]}-${m[2]}-${m[1]}`
      this.pjTabs.receita.dt_abertura = iso
    } else {
      // se o usuário apagar ou digitar diferente, guarda como está (ou vazio)
      this.pjTabs.receita.dt_abertura = s
    }
  }
},

   analiseResumo() {
    const r = this.rowValidacao || {}
    const msg = String(r.Analise_Telefone || '').trim()
    const cep = String(r.Analise_CEP || '').trim()
    const ie = String(r.Analise_IE || '').trim()
    const fan = String(r.Analise_Fantasia || '').trim()
    const ender = String(r.Analise_Endereco || '').trim()
    
    const itens = [fan, ie, cep, msg, ender].filter(Boolean)
    
    return itens.join('; ')

  },

  difCliente () {
  const r = this.rowValidacao || {}
  const t = `${r.Analise_Telefone || ''} ${r.Analise_Endereco || ''} ${r.Analise_Fantasia || ''} ${r.Analise_IE || ''}`

  // cobre "Cliente diferente" e também mensagens que contenham "Cliente"
  return t.includes('Cliente diferente') || t.includes('Cliente diferente;') || t.includes('Cliente')
  
},

  difFornecedor () {
    return String(this.rowValidacao?.Analise_Fantasia || this.rowValidacao?.Analise_IE || '').includes('Fornecedor')
      || String(this.rowValidacao?.Analise_Telefone || '').includes('Fornecedor diferente')
  },

  difTransportadora () {
    return String(this.rowValidacao?.Analise_CEP || this.rowValidacao?.Analise_Telefone || '').includes('Transportadora')
      || String(this.rowValidacao?.Analise_CEP || '').includes('Transportadora ausente')
  },
  
  difClienteEndereco () {
    const r = this.rowValidacao || {}
    const s = String(r.Analise_Endereco || '').toLowerCase()
    return s.includes('cliente diferente')
  }

},

  methods: {

    async verificarExistenciaCNPJ (cnpj) {
  const clean = String(cnpj || '').replace(/\D/g, '')
  // se você tem um parâmetro específico pra "verificar", use ele.
  // exemplos comuns: 10/11/12... (depende da sua PR)
  // vou usar 2 como exemplo (você ajusta para o seu correto)
  const ret = await this.execPJ(2, { cd_CNPJ: clean })
  return ret

},

  recalcularDifClienteEndereco() {
  const r = this.rowValidacao || {}
  const s = String(r.Analise_Endereco || '').toLowerCase()
  return s.includes('cliente diferente')
},

    async abrirPessoas () {
  this.tabPJ = 'pessoas'           // abre a tab
  await this.carregarPessoasValidar(true)  // carrega sem depender de CNPJ
},

async onAbrirPessoas () {
  this.tabPJ = 'pessoas'
  await this.carregarPessoasPendentes()
},


async carregarPessoasPendentes () {
  try {
    // param 50 não precisa cd_cnpj
    const data = await this.execPJ(50, {})
    // seu execPJ retorna resp.data ou resp -> então normaliza:
    const arr = Array.isArray(data) ? data : (data?.data || [])
    this.pessoasValidar = arr
    this.qtdPessoas = arr.length
  } catch (err) {
    console.error(err)
    this.pessoasValidar = []
    this.qtdPessoas = 0
  }
},

async onValidarPessoaGrid (e) {
  if (!e || !e.data) return

  const cnpj = String(e.data.cd_cnpj_cliente || '').replace(/\D/g, '')
  if (cnpj.length !== 14) {
    alert('CNPJ inválido na linha selecionada')
    return
  }

  // confirma
  const razao = String(e.data.nm_razao_social_cliente || '').trim()
  const ok = window.confirm(`Deseja validar o CNPJ ${cnpj}${razao ? ' - ' + razao : ''}?`)
  if (!ok) return

  // limpa e seta
  if (typeof this.limparConsulta === 'function') this.limparConsulta()

  this.cnpjInput = cnpj
  this.tabPJ = 'receita'

  // garante que o v-model “assentou”
  await this.$nextTick()

  // ✅ chama o MESMO fluxo do botão
  await this.acaoConsultar()
},

resetarPjTabs () {
  this.$set(this, 'pjTabs', {
    receita: {
      cd_CNPJ: '',
      nm_razao_social: '',
      nm_fantasia: '',
      nm_cep_api: '',
      nm_endereco: '',
      cd_numero: '',
      nm_complemento: '',
      nm_bairro: '',
      nm_cidade: '',
      ic_estado: '',
      nm_atividade: '',
      nm_atividades_s: '',
      nm_situacao: '',
      nm_porte: '',
      nm_natureza_j: '',
      nm_telefone: '',
      nm_email: '',
      dt_abertura: '',
      vl_capital_social: 0,
      nm_qsa: '',
      cd_inscestual: '',
      cd_estado_insc: '',
      nm_status_insc: ''
    },
    cliente: {
      Cliente_Fantasia: '',
      Cliente_RazaoSocial: '',
      Cliente_IE: '',
      Cliente_Endereco: '',
      Cliente_Numero: '',
      Cliente_Complemento: '',
      Cliente_Bairro: '',
      Cliente_CEP: '',
      Cliente_Telefone: ''
    },
    fornecedor: {
      Fornecedor_Fantasia: '',
      Fornecedor_RazaoSocial: '',
      Fornecedor_IE: '',
      Fornecedor_Endereco: '',
      Fornecedor_Numero: '',
      Fornecedor_Complemento: '',
      Fornecedor_Bairro: '',
      Fornecedor_CEP: '',
      Fornecedor_Telefone: ''
    },
    transportadora: {
      Transportadora_Fantasia: '',
      Transportadora_RazaoSocial: '',
      Transportadora_IE: '',
      Transportadora_Endereco: '',
      Transportadora_Numero: '',
      Transportadora_Complemento: '',
      Transportadora_Bairro: '',
      Transportadora_CEP: '',
      Transportadora_Telefone: ''
    }
  })
},

//

async acaoConsultar () {
  // use AQUI exatamente a mesma função do botão consultar
  // se no seu botão é @click="consultarCNPJ" então chame consultarCNPJ()
  // se é @click="carregarPessoaJuridica" então chame carregarPessoaJuridica()

  if (typeof this.consultarCNPJ === 'function') {
    return await this.consultarCNPJ()
  }

  if (typeof this.carregarPessoaJuridica === 'function') {
    return await this.carregarPessoaJuridica()
  }

  console.error('Nenhum método de consulta encontrado (consultarCNPJ/carregarPessoaJuridica)')
},

//

async onSelecionarPessoa (e) {
  if (!e || !e.data) return

  const cnpj = String(e.data.cd_cnpj_cliente || '').replace(/\D/g, '')
  if (cnpj.length !== 14) {
    this.$q?.notify?.({ type: 'warning', message: 'CNPJ inválido na linha selecionada.' })
    return
  }

  // highlight
  this.selectedPessoaKeys = [e.data.cd_cliente]
  this.selectedPessoaRow = e.data

  //const cnpj = String(e.data.cd_cnpj_cliente || '').replace(/\D/g, '')
  const razao = String(e.data.nm_razao_social_cliente || '').trim()

  const msg = `Deseja validar o CNPJ ${cnpj}${razao ? ' - ' + razao : ''}?`
  const ok = window.confirm(msg)
  if (!ok) return

  // limpa tudo antes de validar (evita “sobra” de outro CNPJ)
  if (this.limparConsulta) this.limparConsulta()

  this.cnpjInput = cnpj
  this.tabPJ = 'receita'

 // espera o Vue atualizar o v-model antes de consultar
  await this.$nextTick()

  // chama o MESMO método do botão Consultar
  if (typeof this.carregarPessoaJuridica === 'function') {
    await this.carregarPessoaJuridica()
  } else if (typeof this.consultarCNPJ === 'function') {
    await this.consultarCNPJ()
  } else {
    // fallback: dispara clique no botão "Consultar" se existir ref
    const btn = this.$refs.btnConsultar
    if (btn && btn.$el) btn.$el.click()
  }

},

onPessoaSelectionChanged (e) {
  // mantém o highlight sempre coerente
  const keys = (e && e.selectedRowKeys) ? e.selectedRowKeys : []
  this.selectedPessoaKeys = keys
  this.selectedPessoaRow = (e && e.selectedRowsData && e.selectedRowsData[0]) ? e.selectedRowsData[0] : null
},

onSelecionarPessoa2 (e) {
  if (!e || !e.data) return

  // marca seleção (highlight)
  this.selectedPessoaKeys = [e.data.cd_cliente]
  this.selectedPessoaRow = e.data

  const cnpj = String(e.data.cd_cnpj_cliente || '').replace(/\D/g, '')
  const razao = String(e.data.nm_razao_social_cliente || '').trim()

  if (cnpj.length !== 14) {
    this.$q?.notify?.({ type: 'warning', message: 'CNPJ inválido na linha selecionada.' })
    return
  }

  // Confirmação
  this.$q.dialog({
    title: 'Validar CNPJ?',
    message: `Deseja validar o CNPJ ${cnpj}${razao ? ' - ' + razao : ''}?`,
    ok: { label: 'Validar', color: 'primary' },
    cancel: { label: 'Cancelar', flat: true }
  }).onOk(() => {
    // joga no input e valida no fluxo normal
    this.cnpjInput = cnpj
    this.tabPJ = 'receita'

    if (this.carregarPessoaJuridica) this.carregarPessoaJuridica()
    else if (this.consultarCNPJ) this.consultarCNPJ()
  })
},

getGridPessoasVisiveis () {
  const grid = this.$refs.gridPessoas
  const inst = grid && grid.instance
  if (!inst) return []

  // DevExtreme: retorna as linhas visíveis (página atual, após filtros/ordenação)
  const visiveis = inst.getVisibleRows ? inst.getVisibleRows() : []
  // cada item tem { data, rowType, ... }
  return visiveis
    .filter(r => r && r.rowType === 'data' && r.data)
    .map(r => r.data)
},

async validar5ParaFila () {
  const visiveis = this.getGridPessoasVisiveis()
  if (!visiveis.length) {
    this.$q?.notify?.({ type: 'warning', position: 'center', message: 'Nenhuma linha visível para validar.' })
    return
  }

  const lote = visiveis.slice(0, 5)

  this.loadingValidar = true
  try {
    let ok = 0
    let falha = 0

    for (const item of lote) {
      const cnpj = String(item.cd_cnpj_cliente || '').replace(/\D/g, '')
      if (cnpj.length !== 14) {
        falha++
        continue
      }

      // param 15: envia para fila
      await this.execPJ(15, { cd_CNPJ: cnpj })
      ok++
    }

    this.$q?.notify?.({
      type: ok ? 'positive' : 'warning',
      position: 'center',
      message: `Enviado para fila: ${ok} | Falhas: ${falha}`
    })

    // recarrega lista (param 50)
    await this.carregarPessoasValidar(true)

  } catch (e) {
    console.error(e)
    this.$q?.notify?.({ type: 'negative', position: 'center', message: e?.message || 'Erro ao enviar validação (param 15)' })
  } finally {
    this.loadingValidar = false
  }
},

//

async carregarPessoasValidar (force = false) {
  this.loadingPessoas = true
  try {
    const resp = await this.execPJ(50, {})

    // 🔴 AQUI está o erro que te travava
    const lista = Array.isArray(resp?.data) ? resp.data : []

    this.pessoasValidar = lista
    this.pessoasCount = lista.length

    console.log('Pessoas (param 50) total:', this.pessoasCount)
    console.log('Primeira linha:', lista[0])

  } catch (e) {
    console.error(e)
    this.pessoasValidar = []
    this.pessoasCount = 0
    this.$q?.notify?.({
      type: 'negative',
      position: 'center',
      message: e?.message || 'Erro ao carregar pessoas (param 50)'
    })
  } finally {
    this.loadingPessoas = false
  }
},



    onVoltar () {
      if (this.$router) this.$router.back()
    },

    async carregarPessoasValidar (force = false) {
  if (this.pessoasCarregadas && !force) return

  this.loadingPessoas = true

  try {
    const resp = await this.execPJ(50, {}) // aqui já retorna resp?.data no seu execPJ

    // 🔥 normaliza: pode vir array, pode vir objeto, pode vir {rows:[]}
    
    let lista = []
    
    if (Array.isArray(resp)) lista = resp
    else if (resp?.rows && Array.isArray(resp.rows)) lista = resp.rows
    else if (resp?.data && Array.isArray(resp.data)) lista = resp.data
    else if (resp && typeof resp === 'object') lista = [resp]

    this.pessoasValidar = lista
    this.pessoasCount = lista.length
    this.pessoasCarregadas = true

    console.log('Pessoas (param 50):', lista[0]) // ajuda a validar campos

  } catch (e) {
    console.error(e)
    this.pessoasValidar = []
    this.pessoasCount = 0
    this.$q?.notify?.({ type: 'negative', position: 'center', message: e?.message || 'Erro ao carregar pessoas (param 50)' })
  } finally {
    this.loadingPessoas = false
  }
},


    abaHabilitada (nome) {
  // se veio do banco, habilita quando tiver dados
  if (this.existeCadastro) return !!(this.pjTabs[nome] && Object.keys(this.pjTabs[nome]).length)

  // se não existe cadastro, habilita baseado no select (param 1)
  if (!this.tipoDestinatarioSelecionado) return nome === 'receita'
  const t = String(this.tipoDestinatarioSelecionado).toLowerCase()
  if (t.includes('cliente')) return nome === 'cliente'
  if (t.includes('fornecedor')) return nome === 'fornecedor'
  return nome === 'receita'
},

async carregarTabsDestinatario() {
  const cnpj = String(this.cnpjInput || '').replace(/\D/g, '')
  if (cnpj.length !== 14) return

  const payload = [{
    ic_json_parametro: 'S',
    cd_parametro: 1,
    cd_usuario: Number(localStorage.cd_usuario || 1),
    cd_cnpj: cnpj
  }]

  const resp = await api.post(
    '/exec/pr_egis_valida_cadastro_pessoa_juridica',
    payload,
    { headers: { 'x-banco': localStorage.nm_banco_empresa } }
  )

  const rows = resp.data || []

  // ✅ aqui depende do que a PR devolve no param 1
  // vou assumir que vem algo como:
  // [{ TipoDestinatario:'Receita' }, { TipoDestinatario:'Cliente' } ...]
  const tipos = rows.map(r => String(r.TipoDestinatario || r.tipo || r.nm_tipo || '').trim()).filter(Boolean)

  // fallback se vier vazio
  const final = tipos.length ? tipos : ['Receita']

  this.tabsDestinatario = final.map(t => ({
    name: t.toLowerCase(),
    label: t
  }))

  // seleciona a primeira
  this.tabPJ = this.tabsDestinatario[0].name
},



montarPayloadTipo(tipo) {
  // tipo: 'Receita' | 'Cliente' | 'Fornecedor' | 'Transportadora'
  const base = {
    TipoDestinatarioUnico: this.rowValidacao?.TipoDestinatarioUnico || tipo
  }

  //
  if (tipo === 'Receita') {
  const r = this.pjTabs.receita || {}
  return {
    TipoDestinatario: 'Receita',
    TipoDestinatarioUnico: this.rowValidacao?.TipoDestinatarioUnico || 'Receita',

    // ✅ campos principais SEM prefixo (Cadastro Receita)
    cd_CNPJ: r.cd_CNPJ || '',
    nm_razao_social: r.nm_razao_social || '',
    nm_fantasia: r.nm_fantasia || '',
    nm_cep_api: r.nm_cep_api || '',
    nm_endereco: r.nm_endereco || '',
    cd_numero: r.cd_numero || '',
    nm_complemento: r.nm_complemento || '',
    nm_bairro: r.nm_bairro || '',
    nm_cidade: r.nm_cidade || '',
    ic_estado: r.ic_estado || '',

    nm_atividade: r.nm_atividade || '',
    nm_atividades_s: r.nm_atividades_s || '',
    nm_situacao: r.nm_situacao || '',
    nm_porte: r.nm_porte || '',
    nm_natureza_j: r.nm_natureza_j || '',

    nm_telefone: r.nm_telefone || '',
    nm_email: r.nm_email || '',

    dt_abertura: r.dt_abertura || '',
    vl_capital_social: r.vl_capital_social || 0,
    nm_qsa: r.nm_qsa || '',

    cd_inscestual: r.cd_inscestual || '',
    cd_estado_insc: r.cd_estado_insc || '',
    nm_status_insc: r.nm_status_insc || ''
  }
}

  if (tipo === 'Cliente') {
    const c = this.pjTabs.cliente || {}
    return {
      ...base,
      TipoDestinatario: 'Cliente',
      Cliente_Fantasia: c.Cliente_Fantasia || '',
      Cliente_RazaoSocial: c.Cliente_RazaoSocial || '',
      Cliente_IE: c.Cliente_IE || '',
      Cliente_Endereco: c.Cliente_Endereco || '',
      Cliente_Numero: c.Cliente_Numero || '',
      Cliente_Complemento: c.Cliente_Complemento || '',
      Cliente_Bairro: c.Cliente_Bairro || '',
      Cliente_CEP: c.Cliente_CEP || '',
      Cliente_Telefone: c.Cliente_Telefone || ''
    }
  }

  if (tipo === 'Fornecedor') {
    const f = this.pjTabs.fornecedor || {}
    return {
      ...base,
      TipoDestinatario: 'Fornecedor',
      Fornecedor_Fantasia: f.Fornecedor_Fantasia || '',
      Fornecedor_RazaoSocial: f.Fornecedor_RazaoSocial || '',
      Fornecedor_IE: f.Fornecedor_IE || '',
      Fornecedor_Endereco: f.Fornecedor_Endereco || '',
      Fornecedor_Numero: f.Fornecedor_Numero || '',
      Fornecedor_Complemento: f.Fornecedor_Complemento || '',
      Fornecedor_Bairro: f.Fornecedor_Bairro || '',
      Fornecedor_CEP: f.Fornecedor_CEP || '',
      Fornecedor_Telefone: f.Fornecedor_Telefone || ''
    }
  }

  if (tipo === 'Transportadora') {
    const t = this.pjTabs.transportadora || {}
    return {
      ...base,
      TipoDestinatario: 'Transportadora',
      Transportadora_Fantasia: t.Transportadora_Fantasia || '',
      Transportadora_RazaoSocial: t.Transportadora_RazaoSocial || '',
      Transportadora_IE: t.Transportadora_IE || '',
      Transportadora_Endereco: t.Transportadora_Endereco || '',
      Transportadora_Numero: t.Transportadora_Numero || '',
      Transportadora_Complemento: t.Transportadora_Complemento || '',
      Transportadora_Bairro: t.Transportadora_Bairro || '',
      Transportadora_CEP: t.Transportadora_CEP || '',
      Transportadora_Telefone: t.Transportadora_Telefone || ''
    }
  }

  return base
},

//
 async execProcNew(nomeProc, payloadArray) {
    // payloadArray precisa ser um array de objetos, igual você já faz no exec
        console.log('payload->execproc: ', payloadArray);
    const  data  = await api.post(`/exec/${nomeProc}`, payloadArray)
    console.log('retorno do banco: ', data);
    return data
 },
 //
async execProc(nmProc, payload) {
  try {
    const resp = await api.post(`/exec/${nmProc}`, payload)
    return resp?.data ?? []
  } catch (e) {
    const status = e?.response?.status
    const url = e?.config?.url
    const resp = e?.response?.data

    console.warn('execProc status:', status, nmProc, resp)

    // NUNCA quebra a UI: devolve array vazio
    return []
    //

  }
},

async carregarPessoaJuridica () {

  const cnpj = String(this.cnpjInput || '').replace(/\D/g, '')
  
  if (cnpj.length !== 14) {
    this.$q?.notify?.({ type: 'negative', position: 'center', message: 'CNPJ inválido' })
    return
  }

  this.loadingPJ = true
  try {

    const data = await this.execPJ(2, { cd_CNPJ: cnpj })

    // Se não veio nada: buscar tipos param 1 e mostrar select

    if (!Array.isArray(data) || data.length === 0) {
      this.existeCadastro = false
      await this.carregarTiposDestinatario()
      this.tabPJ = 'receita'
      // pré-preenche receita com o CNPJ digitado
      this.pjTabs.receita = { cd_cnpj: cnpj }
      this.pjTabs.cliente = {}
      this.pjTabs.fornecedor = {}
      this.pjTabs.transportadora = {}
      return
    }

    this.rowValidacao = row

    // Veio cadastro: monta tabs por TipoDestinatario
    this.existeCadastro = true

    // limpa
    this.pjTabs.receita = {}
    this.pjTabs.cliente = {}
    this.pjTabs.fornecedor = {}
    this.pjTabs.transportadora = {}

    data.forEach(row => {
      const tipo = String(row.TipoDestinatario || row.tipoDestinatario || '').toLowerCase()

      if (tipo.includes('cliente')) this.pjTabs.cliente = { ...row }
      else if (tipo.includes('fornecedor')) this.pjTabs.fornecedor = { ...row }
      else if (tipo.includes('transportadora')) this.pjTabs.transportadora = { ...row }
      else this.pjTabs.receita = { ...row } // default: Receita
    })

    // se não veio alguma tab, deixa vazia
    if (!this.pjTabs.receita.cd_CNPJ) this.pjTabs.receita.cd_CNPJ = cnpj

    // escolhe tab inicial
    this.tabPJ = 'receita'
    //

  } finally {
    this.loadingPJ = false
  }
},


mapearRetornoValidacao(row) {
  const tipos = String(row.TipoDestinatario || '').split('|');

  this.tabsAtivas = {
    Receita: tipos.includes('Receita'),
    Cliente: tipos.includes('Cliente'),
    Fornecedor: tipos.includes('Fornecedor'),
    Transportadora: tipos.includes('Transportadora'),
  };

  // Receita
  /*
  if (this.tabsAtivas.Receita) {
    this.pjTabs.receita = {
      Fantasia: row.Receita_Fantasia,
      RazaoSocial: row.Receita_RazaoSocial,
      IE: row.Receita_IE,
      Endereco: row.Receita_Endereco,
      Numero: row.Receita_Numero,
      Complemento: row.Receita_Complemento,
      Bairro: row.Receita_Bairro,
      Cidade: row.Receita_Cidade,
      Estado: row.Receita_Estado,
      CEP: row.Receita_CEP,
      Telefone: row.Receita_Telefone
    };
  }
  */

// ✅ RECEITA = campos SEM prefixo (nm_*, dt_*, vl_*)
this.pjTabs.receita = {
  ...this.pjTabs.receita,

  cd_CNPJ: row.cd_CNPJ || row.cd_cnpj || '',

  nm_razao_social: row.nm_razao_social || '',
  nm_fantasia: row.nm_fantasia || '',

  cd_inscestual: row.cd_inscestual || '',
  cd_estado_insc: row.cd_estado_insc || '',
  nm_status_insc: row.nm_status_insc || '',

  nm_cep_api: row.nm_cep_api || row.nm_cep || '',
  nm_endereco: row.nm_endereco || '',
  cd_numero: (row.cd_numero || '').trim(),
  nm_complemento: row.nm_complemento || '',
  nm_bairro: row.nm_bairro || '',
  nm_cidade: row.nm_cidade || '',
  ic_estado: row.ic_estado || '',

  nm_telefone: row.nm_telefone || '',
  nm_email: row.nm_email || '',

  nm_situacao: row.nm_situacao || '',
  nm_porte: row.nm_porte || '',
  nm_natureza_j: row.nm_natureza_j || '',

  dt_abertura: row.dt_abertura || '',
  vl_capital_social: row.vl_capital_social ?? '',
  nm_qsa: row.nm_qsa || '',

  nm_atividade: row.nm_atividade || '',
  nm_atividades_s: row.nm_atividades_s || ''
}


  // Cliente
  if (this.tabsAtivas.Cliente) {
    this.pjTabs.cliente = {
      Fantasia: row.Cliente_Fantasia,
      RazaoSocial: row.Cliente_RazaoSocial,
      IE: row.Cliente_IE,
      Endereco: row.Cliente_Endereco,
      Numero: row.Cliente_Numero,
      Complemento: row.Cliente_Complemento,
      Bairro: row.Cliente_Bairro,
      CEP: row.Cliente_CEP,
      Telefone: row.Cliente_Telefone
    };
  }

  // Fornecedor

  if (this.tabsAtivas.Fornecedor) {
    this.pjTabs.fornecedor = {
      Fantasia: row.Fornecedor_Fantasia,
      RazaoSocial: row.Fornecedor_RazaoSocial,
      IE: row.Fornecedor_IE,
      Endereco: row.Fornecedor_Endereco,
      Numero: row.Fornecedor_Numero,
      Complemento: row.Fornecedor_Complemento,
      Bairro: row.Fornecedor_Bairro,
      CEP: row.Fornecedor_CEP,
      Telefone: row.Fornecedor_Telefone
    };
  }

  this.tabPJ = tipos[0]; // abre a primeira aba automaticamente

},

applyRowValidacao(row) {

  // guarda a linha para o banner/alertas
  this.rowValidacao = row || {}

  // ---------- Ativar tabs ----------
  const tipos = String(row?.TipoDestinatario || '').split('|').map(s => s.trim())

  
  this.$set(this.tabsAtivas, 'receita', tipos.includes('Receita'))
  this.$set(this.tabsAtivas, 'cliente', tipos.includes('Cliente'))
  this.$set(this.tabsAtivas, 'fornecedor', tipos.includes('Fornecedor'))
  this.$set(this.tabsAtivas, 'transportadora', tipos.includes('Transportadora'))

  // ---------- Receita (campos sem prefixo) ----------
  const receita = {
    cd_CNPJ: row.cd_CNPJ || row.cd_cnpj || '',
    nm_razao_social: row.nm_razao_social || '',
    nm_fantasia: row.nm_fantasia || '',
    nm_cep_api: row.nm_cep_api || row.nm_cep || '',
    nm_endereco: row.nm_endereco || '',
    cd_numero: String(row.cd_numero || '').trim(),
    nm_complemento: row.nm_complemento || '',
    nm_bairro: row.nm_bairro || '',
    nm_cidade: row.nm_cidade || '',
    ic_estado: row.ic_estado || '',
    nm_telefone: row.nm_telefone || '',
    nm_email: row.nm_email || '',
    nm_situacao: row.nm_situacao || '',
    nm_porte: row.nm_porte || '',
    nm_natureza_j: row.nm_natureza_j || '',
    dt_abertura: row.dt_abertura || '',
    vl_capital_social: row.vl_capital_social ?? '',
    nm_qsa: row.nm_qsa || '',
    nm_atividade: row.nm_atividade || '',
    nm_atividades_s: row.nm_atividades_s || '',
    cd_inscestual: row.cd_inscestual || '',
    cd_estado_insc: row.cd_estado_insc || '',
    nm_status_insc: row.nm_status_insc || ''
  }

  this.$set(this.pjTabs, 'receita', { ...(this.pjTabs.receita || {}), ...receita })

  // ---------- Cliente (Cliente_*) ----------
  const cliente = {
    Cliente_Fantasia: row.Cliente_Fantasia || '',
    Cliente_RazaoSocial: row.Cliente_RazaoSocial || '',
    Cliente_IE: row.Cliente_IE || '',
    Cliente_Endereco: row.Cliente_Endereco || '',
    Cliente_Numero: String(row.Cliente_Numero || '').trim(),
    Cliente_Complemento: row.Cliente_Complemento || '',
    Cliente_Bairro: row.Cliente_Bairro || '',
    Cliente_CEP: row.Cliente_CEP || '',
    Cliente_Telefone: row.Cliente_Telefone || ''
  }
  this.$set(this.pjTabs, 'cliente', { ...(this.pjTabs.cliente || {}), ...cliente })

  // ---------- Fornecedor (Fornecedor_*) ----------
  const fornecedor = {
    Fornecedor_Fantasia: row.Fornecedor_Fantasia || '',
    Fornecedor_RazaoSocial: row.Fornecedor_RazaoSocial || '',
    Fornecedor_IE: row.Fornecedor_IE || '',
    Fornecedor_Endereco: row.Fornecedor_Endereco || '',
    Fornecedor_Numero: String(row.Fornecedor_Numero || '').trim(),
    Fornecedor_Complemento: row.Fornecedor_Complemento || '',
    Fornecedor_Bairro: row.Fornecedor_Bairro || '',
    Fornecedor_CEP: row.Fornecedor_CEP || '',
    Fornecedor_Telefone: row.Fornecedor_Telefone || ''
  }
  this.$set(this.pjTabs, 'fornecedor', { ...(this.pjTabs.fornecedor || {}), ...fornecedor })

  // ---------- Transportadora (Transportadora_*) ----------
  const transportadora = {
    Transportadora_Fantasia: row.Transportadora_Fantasia || '',
    Transportadora_RazaoSocial: row.Transportadora_RazaoSocial || '',
    Transportadora_IE: row.Transportadora_IE || '',
    Transportadora_Endereco: row.Transportadora_Endereco || '',
    Transportadora_Numero: String(row.Transportadora_Numero || '').trim(),
    Transportadora_Complemento: row.Transportadora_Complemento || '',
    Transportadora_Bairro: row.Transportadora_Bairro || '',
    Transportadora_CEP: row.Transportadora_CEP || '',
    Transportadora_Telefone: row.Transportadora_Telefone || ''
  }
  this.$set(this.pjTabs, 'transportadora', { ...(this.pjTabs.transportadora || {}), ...transportadora })

  // aba default
  this.tabPJ = 'receita'

  // (opcional) mostrar o bloco de tabs
  this.existeCadastro = tipos.length > 0
  //
},

async carregarTiposDestinatario() {
  const cnpj = this.cnpjInput.replace(/\D/g, '');

  const tipos = await this.execPJ(1, { cd_CNPJ : cnpj });

  console.log('destinatários:', tipos);

  this.tiposDestinatarioOptions = tipos.map(t => ({
    label: t.TipoDestinatario,
    value: t.TipoDestinatario
  }));
},


async salvarPessoaJuridica() {
  const cnpj = String(this.cnpjInput || '').replace(/\D/g, '')
  if (cnpj.length !== 14) {
    this.$q?.notify?.({ type: 'negative', position: 'center', message: 'CNPJ inválido' })
    return
  }

  this.loadingPJ = true
  try {
    const enviados = []

    // Receita sempre salva
    await this.execPJ(20, this.montarPayloadTipo('Receita'))

    //
    enviados.push('Receita')

    if (this.tabsAtivas?.Cliente) {
      await this.execPJ(20, this.montarPayloadTipo('Cliente'))
      enviados.push('Cliente')
    }

    if (this.tabsAtivas?.Fornecedor) {
      await this.execPJ(20, this.montarPayloadTipo('Fornecedor'))
      enviados.push('Fornecedor')
    }

    if (this.tabsAtivas?.Transportadora) {
      await this.execPJ(20, this.montarPayloadTipo('Transportadora'))
      enviados.push('Transportadora')
    }

    this.$q?.notify?.({ type: 'positive', position: 'center', message: `Atualizado: ${enviados.join(', ')}` })

    // recarrega param 2 pra atualizar análise e tabs (se você já tem)
    if (this.consultarValidacaoPJ) {
      await this.consultarValidacaoPJ()
    }

  } catch (e) {
    this.$q?.notify?.({ type: 'negative', position: 'center', message: e?.message || 'Erro ao salvar (param 20)' })
  } finally {
    this.loadingPJ = false
  }
},

async salvarCNPJ (cnpj) {
  const clean = String(cnpj || '').replace(/\D/g, '')
  // seu salvar real é o param 20 (update) ou outro param de insert
  // aqui vou usar 20 (ajuste se seu salvar for outro)
  const payload = this.montarPayloadTipo('Receita')
  payload.cd_cnpj = clean

  const ret = await this.execPJ(20, payload)
  return ret
},

async salvarPessoaJuridicaOld() {
  const cnpj = this.cnpjInput.replace(/\D/g, '');

  const enviar = async (tipo, dados) => {
    await this.execPJ(20, {
      cd_CNPJ: cnpj,
      TipoDestinatario: tipo,
      ...dados
    });
  };

  if (this.tabsAtivas.Receita) await enviar('Receita', this.pjTabs.Receita);
  if (this.tabsAtivas.Cliente) await enviar('Cliente', this.pjTabs.Cliente);
  if (this.tabsAtivas.Fornecedor) await enviar('Fornecedor', this.pjTabs.Fornecedor);

  this.$q.notify({ type: 'positive', position: 'center', message: 'Cadastro atualizado com sucesso' });
},

    // ===== util =====

    logExec(msg) {
      const hora = new Date().toLocaleTimeString();
      const linha = `[${hora}] ${msg}\n`;
      const alvo = this.aba === "lote" ? "lote" : (this.aba === "fila" ? "fila" : "individual");
      this.logs[alvo] += linha;
    },

     cfgBanco () {
    return this.headerBanco ? { headers: { 'x-banco': this.headerBanco } } : undefined
  },

  //
  async execPJ (cd_parametro, extra = {}) {

    //const cnpj = extra.cd_CNPJ

    const body = [{
      ic_json_parametro: 'S',
      cd_parametro: Number(cd_parametro),
      cd_usuario: this.cdUsuario,
      //cd_CNPJ: cnpj
      ...extra
    }]

    console.log('parametros ', body);

    //const resp = await this.$axios.post(`/exec/${this.nm_procedimento_pj}`, body, this.cfgBanco())
    
    const resp = await this.execProc('pr_egis_valida_cadastro_pessoa_juridica', body)

    //return resp?.data
    return Array.isArray(resp) ? resp : []
    //

  },

  async fetchJsonDefensivo(url, options = {}) {
  const headersPadrao = {
    "Content-Type": "application/json",
    "x-banco": this.bancoPadrao
  };

  const base = (process.env.VUE_APP_API_BASE || "").replace(/\/+$/, ""); // remove / final

  // url absoluta? usa como está
  let finalUrl = /^https?:\/\//i.test(url)
    ? url
    : `${base}${url.startsWith("/") ? "" : "/"}${url}`;

  // ✅ evita /api/api
  finalUrl = finalUrl.replace(/\/api\/api\//, "/api/");

  // (opcional) também evita // no meio (exceto após https://)
  finalUrl = finalUrl.replace(/([^:]\/)\/+/g, "$1");

  let res;
  try {
    res = await fetch(finalUrl, {
      ...options,
      headers: { ...headersPadrao, ...(options.headers || {}) }
    });
  } catch (e) {
    this.logExec(`❌ Falha de rede ao acessar ${finalUrl}`);
    throw new Error("Falha de rede ao acessar a API");
  }

  const text = await res.text();

  let json = null;
  try {
    json = text ? JSON.parse(text) : null;
  } catch (e) {
    this.logExec(
      `❌ Retorno não-JSON em ${finalUrl}. HTTP ${res.status}. Trecho: ${text.slice(0, 200)}…`
    );
    throw new Error("Resposta inválida da API");
  }

  if (!res.ok) {
    const msg =
      (json && (json.erro || json.message || json.error)) ||
      `HTTP ${res.status} ${res.statusText}`;

    this.logExec(`⚠️ API ${finalUrl} retornou erro: ${msg}`);
    throw new Error(msg);
  }

  return json;
},

    async fetchJsonDefensivold(url, options = {}) {
      const headersPadrao = {
        "Content-Type": "application/json",
        "x-banco": this.bancoPadrao
      };
      const res = await fetch(url, {
        ...options,
        headers: { ...headersPadrao, ...(options.headers || {}) }
      });

      const text = await res.text();
      let json = null;
      try {
        json = text ? JSON.parse(text) : null;
      } catch (e) {
        this.logExec(`❌ Retorno não-JSON em ${url}. Trecho: ${text.slice(0, 200)}…`);
        throw new Error("Resposta não-JSON da API");
      }

      if (!res.ok) {
        const msg = (json && (json.erro || json.message || json.error)) || `HTTP ${res.status}`;
        throw new Error(msg);
      }
      return json;
    },

    cnpjLimpo(v) {
      return (v || "").replace(/\D/g, "");
    },

    esperar(ms) {
      return new Promise(resolve => setTimeout(resolve, ms));
    },

    // ===== render =====
    renderizarCards(data) {
      const regs = (data.registrations && data.registrations.length > 0) ? data.registrations : [];
      const ultimoRegistro = regs.length ? regs[regs.length - 1] : null;
      const ieNumero = (ultimoRegistro && (ultimoRegistro.number || ultimoRegistro.cd_inscricao)) || "";

      let html = `
        <div class="card">
          <h2>Dados Cadastrais</h2>
          <div class="info-row"><span class="label">CNPJ:</span><span class="value">${data.taxId || ""}</span></div>
          <div class="info-row"><span class="label">Razão Social:</span><span class="value">${(data.company && data.company.name) || ""}</span></div>
          <div class="info-row"><span class="label">Nome Fantasia:</span><span class="value">${data.alias || ""}</span></div>
          <div class="info-row"><span class="label">Situação:</span><span class="value">${(data.status && data.status.text) || ""}</span></div>
          <div class="info-row"><span class="label">Natureza Jurídica:</span><span class="value">${(data.company && data.company.nature && data.company.nature.text) || ""}</span></div>
          <div class="info-row"><span class="label">Porte:</span><span class="value">${(data.company && data.company.size && data.company.size.text) || ""}</span></div>
          <div class="info-row"><span class="label">IE:</span><span class="value">${ieNumero}</span></div>
        </div>

        <div class="card">
          <h2>Endereço</h2>
          <div class="info-row"><span class="label">Rua:</span><span class="value">${(data.address && data.address.street) || ""}, ${(data.address && data.address.number) || ""}</span></div>
          <div class="info-row"><span class="label">Bairro:</span><span class="value">${(data.address && data.address.district) || ""}</span></div>
          <div class="info-row"><span class="label">Cidade:</span><span class="value">${(data.address && data.address.city) || ""} - ${(data.address && data.address.state) || ""}</span></div>
          <div class="info-row"><span class="label">CEP:</span><span class="value">${(data.address && data.address.zip) || ""}</span></div>
        </div>

        <div class="card">
          <h2>Contato</h2>
          <div class="info-row"><span class="label">Telefone:</span><span class="value">${(data.phones || []).map(p => `(${p.area}) ${p.number}`).join(", ") || ""}</span></div>
          <div class="info-row"><span class="label">E-mail:</span><span class="value">${(data.emails || []).map(e => e.address).join(", ") || ""}</span></div>
        </div>
      `;

      if (regs.length) {
        const inscricoes = regs.map(reg => {
          const estado = reg.state || reg.cd_estado || "-";
          const numero = reg.number || reg.cd_inscricao || "-";
          const tipo = (reg.type && reg.type.text) || reg.nm_tipo_inscricao || "-";
          const status = (reg.status && reg.status.text) || reg.nm_status_inscricao || "-";
          const desde = reg.statusDate || reg.dt_inscricao || "-";
          return `
            <div style="margin-bottom: 8px;">
              <strong>Estado:</strong> ${estado} |
              <strong>Inscrição:</strong> ${numero} |
              <strong>Tipo:</strong> ${tipo} |
              <strong>Status:</strong> ${status} |
              <strong>Desde:</strong> ${desde}
            </div>
          `;
        }).join("");

        html += `
          <div class="card" style="background:#fff3cd; border:1px solid #ffeeba;">
            <h4>📄 Inscrições Estaduais</h4>
            ${inscricoes}
          </div>
        `;
      }

      this.resultadoHtml = html;
    },

    transformarRetornoParaDadosEmpresa(row) {
      // mesmo conceito do pesquisaCNPJ.js :contentReference[oaicite:10]{index=10}
      return {
        taxId: row.cd_CNPJ,
        alias: row.nm_fantasia || "",
        founded: row.dt_abertura || "",
        status: { text: row.nm_situacao || "" },
        company: {
          name: row.nm_razao_social || "",
          nature: { text: row.nm_natureza_j || "" },
          size: { text: row.nm_porte || "" }
        },
        mainActivity: { text: row.nm_atividade || "" },
        sideActivities: (row.nm_atividades_s || "").split(",").filter(Boolean).map(t => ({ text: t })),
        emails: (row.nm_email || "").split(",").filter(Boolean).map(address => ({ address })),
        phones: (row.nm_telefone || "").split(",").filter(Boolean).map(s => ({ area: "", number: s.trim() })),
        address: {
          street: row.nm_endereco || "",
          number: row.cd_numero || "",
          district: row.nm_bairro || "",
          city: row.nm_cidade || "",
          state: row.ic_estado || "",
          zip: row.nm_cep_api || ""
        },
        registrations: [{
          state: row.cd_estado_insc || "",
          number: row.cd_inscestadual || "",
          type: { text: row.nm_status_insc || "" },
          status: { text: row.nm_status_insc || "" }
        }].filter(r => r.number)
      };
    },

    //

  // Função genérica para executar procedures

    // ===== banco/procedure =====

async verificarExistenciaNoBanco (cnpj) {
  const cdCnpj = String(cnpj || '').replace(/\D/g, '')

  const payload = [{
    ic_json_parametro: 'S',
    cd_parametro: 0,
    cd_usuario: this.cdUsuario || 1,
    cd_CNPJ: cdCnpj
  }]

  try {
    const resultado = await this.execProc('pr_validacao_cnpj_api_cnpj_ja', payload)
    const retorno = resultado && resultado[0] ? Number(resultado[0].Retorno) : 0
    return retorno === 1
  } catch (e) {
    this.logExec(`⚠️ Falha ao verificar existência: ${e?.message || e}`)
    return false
  }
},


    // ===== INDIVIDUAL =====

    async consultarCNPJ(cnpjParam) {
      const cnpj = this.cnpjLimpo(cnpjParam || this.cnpjInput);

      if (!cnpj || cnpj.length !== 14) {
        alert("Digite um CNPJ válido.");
        return;
      }


      this.consultou = false
      this.loadingConsulta = true

      try {

        const existe = await this.verificarExistenciaNoBanco(cnpj);

        if (existe) {
          this.logExec(`⚠️ CNPJ ${cnpj} já validado e existente na base.`);

          // carrega da base via cd_parametro 99 (mesmo fluxo do JS) :contentReference[oaicite:11]{index=11}
          
          const payload = [{
            cd_parametro: 99,
            cd_CNPJ: cnpj,
            ic_json_parametro: "S"
          }];

            const dados = await this.fetchJsonDefensivo("/api/exec/pr_validacao_cnpj_api_cnpj_ja", {
            method: "POST",
            body: JSON.stringify(payload)
          });
          
          if (dados && dados.length > 0) {
            this.dadosEmpresa = this.transformarRetornoParaDadosEmpresa(dados[0]);
            this.renderizarCards(this.dadosEmpresa);
            //
            await this.consultarValidacaoPJ();
            // 
            this.logExec(`✅ Dados carregados da base para o CNPJ ${cnpj}.`);
       
          } else {
            this.logExec(`⚠️ Nenhum dado encontrado na base para o CNPJ ${cnpj}.`);
          }

          return;

        }

        // consulta API externa (mesmo endpoint do controller) :contentReference[oaicite:12]{index=12}
       
        const res = await fetch(`https://api.cnpja.com/office/${cnpj}?registrations=ORIGIN`, {
          headers: { Authorization: this.chaveAPI }
        });
        if (!res.ok) throw new Error(`Erro ao consultar CNPJ - API : (HTTP ${res.status})`);

        const data = await res.json();

        this.dadosEmpresa = data;
        this.renderizarCards(data);

        // salva automaticamente (mesmo comportamento do JS) :contentReference[oaicite:13]{index=13}
        await this.salvarDados();
        //

      } catch (err) {
        this.logExec(`❌ Erro ao consultar ${cnpj}: ${err.message}`);
        alert("Erro ao consultar CNPJ: " + err.message);
      }


      // 🔁 depois que a consulta antiga terminar
      await this.consultarValidacaoPJ();
      //


      /*
     console.log('Form Básico - passo 1');



try {
  await this.consultarValidacaoPJ()
} catch (e) {
  console.log('PR validação falhou:', e)
}
this.consultou = true
this.loadingConsulta = false



      */
 
    },

    //
    
async consultarValidacaoPJ () {

  const cnpj = String(this.cnpjInput || '').replace(/\D/g, '')
  
  if (cnpj.length !== 14) return

  let resp = []

  try {
    resp = await this.execPJ(2, { cd_CNPJ: cnpj })
  } catch (e) {
    console.error('consultarValidacaoPJ: erro na validação', e)
    resp = []
  }

 //  resp = await this.execPJ(2, { cd_CNPJ: cnpj })
  const row = Array.isArray(resp) && resp.length ? resp[0] : null
  
  //

  console.log('dados execPJ 2 ',row);

    if (row) {
    // exemplo de uso seguro
    console.log('CNPJ encontrado:', row.cd_CNPJ || '(não informado)')
  } else {
    console.warn('Nenhum dado retornado para esse CNPJ')
    
  }
  

  if (!row) {
    this.existeCadastro = false
    this.tabsAtivas.Cliente = false
    this.tabsAtivas.Fornecedor = false
    // se quiser limpar o banner/tabs:
    //Sthis.applyRowValidacao(null)
    //
    await this.carregarTiposDestinatario()
    return
  }

    // 
  this.applyRowValidacao(row)
  //

  this.existeCadastro = true

  // Ativa tabs pela coluna TipoDestinatario (ex: Receita|Cliente|Fornecedor)
  const tipos = String(row.TipoDestinatario || '').split('|').map(s => s.trim())
  
  this.tabsAtivas.Cliente = tipos.includes('Cliente')
  this.tabsAtivas.Fornecedor = tipos.includes('Fornecedor')
  this.tabsAtivas.Transportadora = tipos.includes('Transportadora')

  // Receita (campos do “bloco geral” + se quiser também Receita_*)

  /*
  this.pjTabs.receita = {
    ...this.pjTabs.receita,
    cd_CNPJ: row.cd_CNPJ || cnpj,
    nm_razao_social: row.nm_razao_social || row.Receita_RazaoSocial || '',
    nm_fantasia: row.nm_fantasia || row.Receita_Fantasia || '',
    cd_inscestual: row.cd_inscestual || row.Receita_IE || '',
    nm_cep_api: row.nm_cep_api || row.Receita_CEP || '',
    nm_endereco: row.nm_endereco || row.Receita_Endereco || '',
    cd_numero: row.cd_numero || row.Receita_Numero || '',
    nm_complemento: row.nm_complemento || row.Receita_Complemento || '',
    nm_bairro: row.nm_bairro || row.Receita_Bairro || '',
    nm_cidade: row.nm_cidade || row.Receita_Cidade || '',
    ic_estado: row.ic_estado || row.Receita_Estado || '',
    nm_situacao: row.nm_situacao || '',
    nm_porte: row.nm_porte || ''
  }

  // Cliente_* (se habilitado)
  if (this.tabsAtivas.Cliente) {
    this.pjTabs.cliente = {
      ...this.pjTabs.cliente,
      Cliente_Fantasia: row.Cliente_Fantasia || '',
      Cliente_RazaoSocial: row.Cliente_RazaoSocial || '',
      Cliente_IE: row.Cliente_IE || '',
      Cliente_Endereco: row.Cliente_Endereco || '',
      Cliente_Numero: row.Cliente_Numero || '',
      Cliente_Complemento: row.Cliente_Complemento || '',
      Cliente_Bairro: row.Cliente_Bairro || '',
      Cliente_CEP: row.Cliente_CEP || '',
      Cliente_Telefone: row.Cliente_Telefone || ''
    }
  }

  // Fornecedor_* (se habilitado)

  if (this.tabsAtivas.Fornecedor) {
    this.pjTabs.fornecedor = {
      ...this.pjTabs.fornecedor,
      Fornecedor_Fantasia: row.Fornecedor_Fantasia || '',
      Fornecedor_RazaoSocial: row.Fornecedor_RazaoSocial || '',
      Fornecedor_IE: row.Fornecedor_IE || '',
      Fornecedor_Endereco: row.Fornecedor_Endereco || '',
      Fornecedor_Numero: row.Fornecedor_Numero || '',
      Fornecedor_Complemento: row.Fornecedor_Complemento || '',
      Fornecedor_Bairro: row.Fornecedor_Bairro || '',
      Fornecedor_CEP: row.Fornecedor_CEP || '',
      Fornecedor_Telefone: row.Fornecedor_Telefone || ''
    }
  }

  if (this.tabsAtivas.Transportadora) {
  this.pjTabs.transportadora = {
    Transportadora_Fantasia: row.Transportadora_Fantasia || '',
    Transportadora_RazaoSocial: row.Transportadora_RazaoSocial || '',
    Transportadora_IE: row.Transportadora_IE || '',
    Transportadora_Endereco: row.Transportadora_Endereco || '',
    Transportadora_Numero: row.Transportadora_Numero || '',
    Transportadora_Complemento: row.Transportadora_Complemento || '',
    Transportadora_Bairro: row.Transportadora_Bairro || '',
    Transportadora_CEP: row.Transportadora_CEP || '',
    Transportadora_Telefone: row.Transportadora_Telefone || ''
  }
}
*/

// preenche formBasico com dados da consulta antiga
this.formBasico.cd_CNPJ = this.dadosEmpresa?.taxId || this.formBasico.cd_CNPJ
this.formBasico.nm_razao_social = this.dadosEmpresa?.company?.name || this.formBasico.nm_razao_social
this.formBasico.nm_fantasia = this.dadosEmpresa?.alias || this.formBasico.nm_fantasia
this.formBasico.nm_cep_api = this.dadosEmpresa?.address?.zip || this.formBasico.nm_cep_api
this.formBasico.nm_endereco = this.dadosEmpresa?.address?.street || this.formBasico.nm_endereco
this.formBasico.cd_numero = this.dadosEmpresa?.address?.number || this.formBasico.cd_numero
this.formBasico.nm_bairro = this.dadosEmpresa?.address?.district || this.formBasico.nm_bairro
this.formBasico.nm_cidade = this.dadosEmpresa?.address?.city || this.formBasico.nm_cidade
this.formBasico.ic_estado = this.dadosEmpresa?.address?.state || this.formBasico.ic_estado
this.formBasico.cd_inscestual = row.cd_inscestual

// IE: pega do registrations se tiver
const regs = Array.isArray(this.dadosEmpresa?.registrations) ? this.dadosEmpresa.registrations : []
this.formBasico.cd_inscestual = (regs.find(r => r.number)?.number) || this.formBasico.cd_inscestual

console.log('ie', row.cd_inscestual, this.formBasico.cd_inscestual)
this.formBasico.cd_inscestual = this.formBasico.cd_inscestual || row.cd_inscestual

// agora sim: carregar tabs do param 1
//await this.carregarTabsDestinatario()
//


  // abre sempre Receita primeiro
  this.tabPJ = 'receita'
  //

},

    async salvarDados() {

      if (!this.dadosEmpresa) {
        alert("Nenhuma empresa carregada.");
        return;
      }

      const registros = this.dadosEmpresa.registrations || [];
      const ativos = registros.filter(r => r.enabled && r.statusDate);
      ativos.sort((a, b) => new Date(b.statusDate) - new Date(a.statusDate));
      const ultimoRegistro = ativos[0];

      const payload = [{
        ic_json_parametro: "S",
        cd_parametro: 1,
        cd_usuario: 1,
        cd_CNPJ: this.dadosEmpresa.taxId,
        nm_razao_social: (this.dadosEmpresa.company && this.dadosEmpresa.company.name) || "",
        nm_fantasia: this.dadosEmpresa.alias || "",
        dt_abertura: this.dadosEmpresa.founded,
        nm_situacao: (this.dadosEmpresa.status && this.dadosEmpresa.status.text) || "",
        nm_natureza_j: (this.dadosEmpresa.company && this.dadosEmpresa.company.nature && this.dadosEmpresa.company.nature.text) || "",
        nm_porte: (this.dadosEmpresa.company && this.dadosEmpresa.company.size && this.dadosEmpresa.company.size.text) || "",
        nm_atividade: (this.dadosEmpresa.mainActivity && this.dadosEmpresa.mainActivity.text) || "",
        nm_atividades_s: (this.dadosEmpresa.sideActivities || []).map(a => a.text).join(", "),
        nm_email: (this.dadosEmpresa.emails || []).map(e => e.address).join(", "),
        nm_telefone: (this.dadosEmpresa.phones || []).map(p => `(${p.area}) ${p.number}`).join(", "),
        nm_endereco: (this.dadosEmpresa.address && this.dadosEmpresa.address.street) || "",
        cd_numero: (this.dadosEmpresa.address && this.dadosEmpresa.address.number) || "",
        nm_bairro: (this.dadosEmpresa.address && this.dadosEmpresa.address.district) || "",
        nm_cidade: (this.dadosEmpresa.address && this.dadosEmpresa.address.city) || "",
        ic_estado: (this.dadosEmpresa.address && this.dadosEmpresa.address.state) || "",
        nm_cep_api: (this.dadosEmpresa.address && this.dadosEmpresa.address.zip) || "",
        vl_capital_social: (this.dadosEmpresa.company && this.dadosEmpresa.company.equity) || 0,
        nm_qsa: (this.dadosEmpresa.company && this.dadosEmpresa.company.members ? this.dadosEmpresa.company.members.map(m => m.person.name + " - " + m.role.text).join(", ") : ""),
        cd_inscestadual: (ultimoRegistro && ultimoRegistro.number) || "",
        nm_status_insc: (ultimoRegistro && ultimoRegistro.type && ultimoRegistro.type.text) || "",
        cd_estado_insc: (ultimoRegistro && ultimoRegistro.state) || ""
      }];

      console.log('payload-->', payload);

      try {
        await this.fetchJsonDefensivo("/api/exec/pr_validacao_cnpj_api_cnpj_ja", {
          method: "POST",
          body: JSON.stringify(payload)
        });

        this.logExec(`✅ ${(this.dadosEmpresa.company && this.dadosEmpresa.company.name) || "Empresa"} (${this.dadosEmpresa.taxId}) salva com sucesso.`);
      
      } catch (e) {
        this.logExec(`❌ Erro ao salvar CNPJ ${this.dadosEmpresa.taxId}: ${e.message}`);
        return;
      }

      // payload IE (cd_parametro 2) :contentReference[oaicite:14]{index=14}
      const payloadIE = registros.map(reg => ({
        ic_json_parametro: "S",
        cd_parametro: 2,
        cd_usuario: 1,
        cd_CNPJ: this.dadosEmpresa.taxId,
        cd_inscricao: reg.number || "",
        cd_estado: reg.state || "",
        nm_status_inscricao: (reg.status && reg.status.text) || "",
        nm_tipo_inscricao: (reg.type && reg.type.text) || "",
        dt_inscricao: reg.statusDate || null
      }));

      if (!payloadIE.length) {
        this.logExec(`ℹ️ Nenhuma inscrição estadual encontrada para ${this.dadosEmpresa.taxId}.`);
        return;
      }

      try {
        await this.fetchJsonDefensivo("/api/exec/pr_validacao_cnpj_api_cnpj_ja", {
          method: "POST",
          body: JSON.stringify(payloadIE)
        });
      } catch (e) {
        this.logExec(`⚠️ Falha ao salvar inscrições estaduais: ${e.message}`);
      }
    },

    limparTelaPJ() {
  this.cnpjInput = ''
  this.consultou = false
  this.existeCadastro = false
  this.tabsAtivas = { cliente: false, fornecedor: false }
  this.tipoDestinatarioSelecionado = null
  this.tiposDestinatarioOptions = []
  this.resultadoHtml = ''

  // reseta modelos
  this.pjTabs.receita = { ...this.pjTabs.receita, cd_CNPJ: '' }
  this.pjTabs.cliente = { ...this.pjTabs.cliente }
  this.pjTabs.fornecedor = { ...this.pjTabs.fornecedor }

  this.tabPJ = 'receita'
  
},

    limparConsulta(focar) {
      this.cnpjInput = "";
      this.dadosEmpresa = null;
      this.resultadoHtml = "";
      this.resultadoHtml = ''
      this.rowValidacao = null
      this.consultou = false

this.$set(this, 'tabsAtivas', { cliente: false, fornecedor: false, transportadora: false })
  this.tabPJ = 'receita'

  this.resetarPjTabs()

  // limpa seleção do grid
  this.selectedPessoaKeys = []
  this.selectedPessoaRow = null
  try {
    const inst = this.$refs.gridPessoas && this.$refs.gridPessoas.instance
    if (inst) inst.clearSelection()
  } catch (e) {}


      this.logExec("🧹 Limpeza de tela efetuada.");

      if (focar) {
        this.$nextTick(() => {
          const el = this.$el.querySelector("input.pj-input");
          if (el) el.focus();
        });
      }
    },


    fmtDataBR (v) {
  if (!v) return ''
  // aceita "2001-08-09" ou "2025-12-16T21:46:41.457Z"
  const s = String(v)

  // se for YYYY-MM-DD, não use new Date() direto (pode mudar por fuso)
  const m = s.match(/^(\d{4})-(\d{2})-(\d{2})/)
  if (m) return `${m[3]}/${m[2]}/${m[1]}`

  const d = new Date(s)
  if (isNaN(d.getTime())) return s
  return d.toLocaleDateString('pt-BR')
},

fmtMoedaBR (v) {
  if (v === null || v === undefined || v === '') return ''
  const n = Number(v)
  if (isNaN(n)) return String(v)
  return n.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
},

fmtTexto (v) {
  if (v === null || v === undefined) return ''
  return String(v).trim()
},

montarHtmlComprovante () {
  const r = this.pjTabs?.receita || {}
  const row = this.rowValidacao || {}

  const get = (k, fallback = '') => {
    // busca primeiro no pjTabs.receita e depois no rowValidacao
    return this.fmtTexto(r[k] !== undefined ? r[k] : (row[k] !== undefined ? row[k] : fallback))
  }

  const dataPesquisa = this.fmtDataBR(new Date())

  // campos principais (sem prefixo)
  const cnpj = get('cd_CNPJ', row.cd_CNPJ || row.cd_cnpj || '')
  const razao = get('nm_razao_social', row.nm_razao_social || '')
  const fantasia = get('nm_fantasia', row.nm_fantasia || '')
  const ie = get('cd_inscestual', row.cd_inscestual || '')
  const statusIE = get('nm_status_insc', row.nm_status_insc || '')
  const natureza = get('nm_natureza_j', row.nm_natureza_j || '')
  const situacao = get('nm_situacao', row.nm_situacao || '')
  const porte = get('nm_porte', row.nm_porte || '')
  const abertura = this.fmtDataBR(r.dt_abertura || row.dt_abertura || '')
  const capital = this.fmtMoedaBR(r.vl_capital_social ?? row.vl_capital_social ?? '')
  const qsa = get('nm_qsa', row.nm_qsa || '')

  console.log('ie do comprovante', ie);

  const cep = get('nm_cep_api', row.nm_cep_api || row.nm_cep || '')
  const end = get('nm_endereco', row.nm_endereco || '')
  const num = get('cd_numero', row.cd_numero || '')
  const compl = get('nm_complemento', row.nm_complemento || '')
  const bairro = get('nm_bairro', row.nm_bairro || '')
  const cidade = get('nm_cidade', row.nm_cidade || '')
  const uf = get('ic_estado', row.ic_estado || '')

  const tel = get('nm_telefone', row.nm_telefone || '')
  const email = get('nm_email', row.nm_email || '')

  const atv = get('nm_atividade', row.nm_atividade || '')
  const atvs = get('nm_atividades_s', row.nm_atividades_s || '')

  return `
  <div style="font-family: Arial, sans-serif; padding: 16px;">
    <div style="display:flex; justify-content:space-between; align-items:flex-start;">
      <div>
        <div style="font-size:22px; font-weight:700;">Comprovante de Cadastro Pessoa Jurídica</div>
        <div style="color:#666; margin-top:4px;">Data da pesquisa: <b>${dataPesquisa}</b></div>
      </div>
      <div style="text-align:right; font-size:12px; color:#666;">
        EGISNet
      </div>
    </div>

    <hr style="margin:14px 0;" />

    <h3 style="margin:10px 0;">Dados Cadastrais</h3>
    <table style="width:100%; border-collapse:collapse; font-size:14px;">
      <tr><td style="padding:6px 0; width:180px;"><b>CNPJ:</b></td><td>${cnpj}</td></tr>
      <tr><td style="padding:6px 0;"><b>Razão Social:</b></td><td>${razao}</td></tr>
      <tr><td style="padding:6px 0;"><b>Nome Fantasia:</b></td><td>${fantasia}</td></tr>
      <tr><td style="padding:6px 0;"><b>Situação:</b></td><td>${situacao}</td></tr>
      <tr><td style="padding:6px 0;"><b>Natureza Jurídica:</b></td><td>${natureza}</td></tr>
      <tr><td style="padding:6px 0;"><b>Porte:</b></td><td>${porte}</td></tr>
      <tr><td style="padding:6px 0;"><b>Data de Abertura:</b></td><td>${abertura}</td></tr>
      <tr><td style="padding:6px 0;"><b>Inscr. Estadual:</b></td><td>${ie || '-'}</td></tr>
      <tr><td style="padding:6px 0;"><b>Status IE:</b></td><td>${statusIE}</td></tr>
      <tr><td style="padding:6px 0;"><b>Capital Social:</b></td><td>${capital}</td></tr>
    </table>

    <h3 style="margin:16px 0 8px;">Endereço</h3>
    <table style="width:100%; border-collapse:collapse; font-size:14px;">
      <tr><td style="padding:6px 0; width:180px;"><b>CEP:</b></td><td>${cep}</td></tr>
      <tr><td style="padding:6px 0;"><b>Endereço:</b></td><td>${end}, ${num}${compl ? ' - ' + compl : ''}</td></tr>
      <tr><td style="padding:6px 0;"><b>Bairro:</b></td><td>${bairro}</td></tr>
      <tr><td style="padding:6px 0;"><b>Cidade/UF:</b></td><td>${cidade} - ${uf}</td></tr>
    </table>

    <h3 style="margin:16px 0 8px;">Contato</h3>
    <table style="width:100%; border-collapse:collapse; font-size:14px;">
      <tr><td style="padding:6px 0; width:180px;"><b>Telefone:</b></td><td>${tel}</td></tr>
      <tr><td style="padding:6px 0;"><b>E-mail:</b></td><td>${email}</td></tr>
    </table>

    <h3 style="margin:16px 0 8px;">Atividades</h3>
    <div style="font-size:14px; line-height:1.4;">
      <div><b>Atividade Principal:</b> ${atv}</div>
      <div style="margin-top:6px;"><b>Atividades Secundárias:</b> ${atvs}</div>
    </div>

    <h3 style="margin:16px 0 8px;">QSA</h3>
    <div style="font-size:14px; line-height:1.4;">${qsa}</div>

    <hr style="margin:16px 0;" />
    <div style="font-size:12px; color:#666;">
      Documento gerado pelo sistema em ${dataPesquisa}.
    </div>
  </div>
  `
},

gerarComprovante () {
  const html = this.montarHtmlComprovante()

  const w = window.open('', '_blank')
  if (!w) {
    this.$q?.notify?.({ type: 'negative', position: 'center', message: 'Pop-up bloqueado. Permita pop-ups para imprimir.' })
    return
  }

  w.document.open()
  w.document.write(
    '<html>' +
      '<head>' +
        '<title>Comprovante - Pessoa Jurídica</title>' +
        '<meta charset="utf-8"/>' +
        '<style>@media print{button{display:none}}</style>' +
      '</head>' +
      '<body>' +
        html +
      '</body>' +
    '</html>'
  )
  w.document.close()

  // ✅ sem <script> no HTML (não quebra o .vue)
  w.onload = function () {
    w.focus()
    w.print()
  }
},

    gerarComprovanteOld2() {
  if (!this.dadosEmpresa) {
    alert("Nenhuma empresa carregada para gerar comprovante.");
    return;
  }

  const end = this.dadosEmpresa.address || {};
  const contatos = (this.dadosEmpresa.phones || []).map(p => `(${p.area}) ${p.number}`).join(", ");
  const emails = (this.dadosEmpresa.emails || []).map(e => e.address).join(", ");

  const regs = Array.isArray(this.dadosEmpresa.registrations) ? this.dadosEmpresa.registrations : [];
  const iePrincipal = (regs.find(r => r.number)?.number) || "";

  const listaIE = regs
    .filter(r => r.number)
    .map(r => {
      const uf = r.state || "";
      const ie = r.number || "";
      return `<div><span class="label">IE ${uf}:</span> ${ie}</div>`;
    })
    .join("");

  const hoje = new Date();
  const dataBR = hoje.toLocaleDateString("pt-BR");
  const horaBR = hoje.toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" });

  const win = window.open("", "_blank");
  win.document.write(`
    <html><head><title>Comprovante</title>
      <style>
        body{font-family:Arial;padding:20px;line-height:1.6}
        h2{color:#004d99}
        .label{font-weight:bold;display:inline-block;width:160px;color:#004d99}
        .secao{margin-top:20px;border-top:1px solid #ccc;padding-top:10px}
      </style>
    </head><body>
      <h2>Comprovante de Consulta de CNPJ</h2>

      <div class="secao">
        <div><span class="label">CNPJ:</span>${this.dadosEmpresa.taxId || ""}</div>
        <div><span class="label">Razão Social:</span>${(this.dadosEmpresa.company && this.dadosEmpresa.company.name) || ""}</div>
        <div><span class="label">Nome Fantasia:</span>${this.dadosEmpresa.alias || ""}</div>
        <div><span class="label">Situação:</span>${(this.dadosEmpresa.status && this.dadosEmpresa.status.text) || ""}</div>
        <div><span class="label">Abertura:</span>${this.dadosEmpresa.founded || ""}</div>
        <div><span class="label">Inscrição Estadual:</span>${iePrincipal || "-"}</div>

        ${listaIE ? `<div style="margin-top:10px;"><h3>Inscrições Estaduais</h3>${listaIE}</div>` : ""}
      </div>

      <div class="secao">
        <h3>Endereço</h3>
        <div><span class="label">Logradouro:</span>${end.street || ""}, ${end.number || ""}</div>
        <div><span class="label">Bairro:</span>${end.district || ""}</div>
        <div><span class="label">Cidade:</span>${end.city || ""} - ${end.state || ""}</div>
        <div><span class="label">CEP:</span>${end.zip || ""}</div>
      </div>

      <div class="secao">
        <h3>Contato</h3>
        <div><span class="label">Telefones:</span>${contatos}</div>
        <div><span class="label">E-mails:</span>${emails}</div>
      </div>

      <div style="margin-top:30px;"><em>Emitido em: ${dataBR} ${horaBR}</em></div>
    </body></html>
  `);

  try { win.document.close(); } catch(_) {}
  try { win.print(); } catch(_) {}
},

    gerarComprovanteOld() {
      if (!this.dadosEmpresa) {
        alert("Nenhuma empresa carregada para gerar comprovante.");
        return;
      }

      // Mesmo conceito do gerarComprovante() do JS :contentReference[oaicite:15]{index=15}, versão compacta
      
      const end = this.dadosEmpresa.address || {};
      const contatos = (this.dadosEmpresa.phones || []).map(p => `(${p.area}) ${p.number}`).join(", ");
      const emails = (this.dadosEmpresa.emails || []).map(e => e.address).join(", ");

const regs = Array.isArray(this.dadosEmpresa.registrations) ? this.dadosEmpresa.registrations : [];

// Pega uma IE “principal”
const iePrincipal =
  (regs.find(r => r.number)?.number) ||
  (this.dadosEmpresa.cd_inscestadual) || // caso você venha a colocar isso no objeto
  "";

// Monta lista por UF (se tiver várias)
const listaIE = regs
  .filter(r => r.number)
  .map(r => {
    const uf = r.state || "";
    const ie = r.number || "";
    return `<div><span class="label">IE ${uf}:</span> ${ie}</div>`;
  })
  .join("");


      const hoje = new Date();
      const dataBR = hoje.toLocaleDateString("pt-BR"); // dd/mm/yyyy
      const horaBR = hoje.toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" });

      const win = window.open("", "_blank");
      win.document.write(`
        <html><head><title>Comprovante</title>
          <style>
            body{font-family:Arial;padding:20px;line-height:1.6}
            h2{color:#004d99}
            .label{font-weight:bold;display:inline-block;width:160px}
            .secao{margin-top:20px;border-top:1px solid #ccc;padding-top:10px}
          </style>
        </head><body>
          <h2>Comprovante de Consulta de CNPJ</h2>
          <div class="secao">
            <div><span class="label">CNPJ:</span>${this.dadosEmpresa.taxId || ""}</div>
            <div><span class="label">Razão Social:</span>${(this.dadosEmpresa.company && this.dadosEmpresa.company.name) || ""}</div>
            <div><span class="label">Nome Fantasia:</span>${this.dadosEmpresa.alias || ""}</div>
            <div><span class="label">Situação:</span>${(this.dadosEmpresa.status && this.dadosEmpresa.status.text) || ""}</div>
            <div><span class="label">Abertura:</span>${this.dadosEmpresa.founded || ""}</div>
            <div><span class="label">Inscrição Estadual:</span>${iePrincipal || "-"}</div>
${listaIE ? `<div style="margin-top:10px;"><h3>Inscrições Estaduais</h3>${listaIE}</div>` : ""}

          </div>
          <div class="secao">
            <h3>Endereço</h3>
            <div><span class="label">Logradouro:</span>${end.street || ""}, ${end.number || ""}</div>
            <div><span class="label">Bairro:</span>${end.district || ""}</div>
            <div><span class="label">Cidade:</span>${end.city || ""} - ${end.state || ""}</div>
            <div><span class="label">CEP:</span>${end.zip || ""}</div>
          </div>
          <div class="secao">
            <h3>Contato</h3>
            <div><span class="label">Telefones:</span>${contatos}</div>
            <div><span class="label">E-mails:</span>${emails}</div>
          </div>
          <div style="margin-top:30px;"><em>Emitido em: ${dataBR} ${horaBR}</em></div>
        </body></html>
      `);
      try { win.document.close(); } catch(_) {}
      try { win.print(); } catch(_) {}
    },

    // ===== LOTE =====
    async validarListaCNPJs() {
      const cnpjs = (this.listaCNPJs || "")
        .split("\n")
        .map(l => this.cnpjLimpo(l.trim()))
        .filter(c => c.length === 14);

      if (!cnpjs.length) {
        alert("Nenhum CNPJ válido na lista.");
        return;
      }

      this.statusValidacao = "";
      this.progresso = 0;
      this.resultadoHtml = "";
      this.logs.lote = "";

      this.logExec(`🔍 Iniciando validação de ${cnpjs.length} CNPJs...`);

      let consultas = 0;
      const limite = 5;
      const intervalo = 60000;

      for (let i = 0; i < cnpjs.length; i++) {
        const cnpj = cnpjs[i];

        this.logExec(`⏳ Validando ${i + 1}/${cnpjs.length}: ${cnpj}`);

        if (consultas >= limite) {
          this.logExec("⏳ Aguardando 60 segundos para respeitar o limite da API...");
          await this.esperar(intervalo);
          consultas = 0;
        }

        const existe = await this.verificarExistenciaNoBanco(cnpj);
        if (existe) {
          this.logExec(`⚠️ CNPJ ${cnpj} já validado anteriormente. Pulando...`);
          this.progresso = Math.round(((i + 1) / cnpjs.length) * 100);
          continue;
        }

        try {
          await this.consultarCNPJ(cnpj); // consulta + salva
          consultas++;
        } catch (e) {
          this.logExec(`⛔ Parando processamento por erro: ${e.message}`);
          break;
        }

        this.progresso = Math.round(((i + 1) / cnpjs.length) * 100);
        await this.esperar(3000);
      }

      this.statusValidacao = "✅ Validação finalizada!";
      this.logExec("✅ Validação finalizada!");
    },

    // ===== FILA =====
    async abrirFila() {
      this.aba = "fila";
      await this.carregarFila();
      // se quiser auto-start igual ao HTML :contentReference[oaicite:16]{index=16}:
      // setTimeout(() => this.executarFila(), 1000);
    },

    async carregarFila() {
      try {
        const payload = [{ cd_parametro: 10, ic_json_parametro: "S" }];
        const lista = await this.fetchJsonDefensivo("/api/exec/pr_validacao_cnpj_api_cnpj_ja", {
          method: "POST",
          body: JSON.stringify(payload)
        });
        this.fila = Array.isArray(lista) ? lista : [];
        this.logExec("📋 Fila carregada com sucesso.");
      } catch (e) {
        this.logExec("❌ Erro ao carregar fila: " + e.message);
      }
    },

    async marcarFilaComoConcluida(cd_fila) {
      const payload = [{ cd_parametro: 11, cd_fila, ic_json_parametro: "S" }];
      await this.fetchJsonDefensivo("/api/exec/pr_validacao_cnpj_api_cnpj_ja", {
        method: "POST",
        body: JSON.stringify(payload)
      });
      this.logExec(`📦 Fila ${cd_fila} atualizada no banco.`);
    },

    async executarFila() {
      if (!this.fila.length) {
        alert("Nenhuma fila carregada.");
        return;
      }

      let consultas = 0;
      const limite = 5;
      const intervalo = 60000;

      for (let i = 0; i < this.fila.length; i++) {
        const item = this.fila[i];
        const cd_fila = item.cd_fila;
        const cnpj = this.cnpjLimpo(item.cd_cnpj);

        this.logExec(`🔄 Fila: processando ${cnpj}`);

        if (consultas >= limite) {
          this.logExec("⏳ Aguardando 60 segundos para respeitar o limite da API...");
          await this.esperar(intervalo);
          consultas = 0;
        }

        try {
          const existe = await this.verificarExistenciaNoBanco(cnpj);
          if (existe) {
            this.logExec(`⚠️ ${cnpj} já existe na base. Marcando como concluída.`);
            await this.marcarFilaComoConcluida(cd_fila);
            continue;
          }

          await this.consultarCNPJ(cnpj); // consulta + salva
          await this.marcarFilaComoConcluida(cd_fila);
          consultas++;

        } catch (e) {
          this.logExec(`❌ Erro na fila (${cnpj}): ${e.message}`);
        }

        await this.esperar(3000);
      }

      this.logExec("✅ Fila de validação finalizada!");
      await this.carregarFila();
    }
  }
};
</script>

<style scoped>
/* Paleta e layout espelhando pesquisaCNPJ.html :contentReference[oaicite:17]{index=17} */
.pj-wrap { font-family: Roboto, Arial, sans-serif; background:#f4f8fb; color:#333; padding: 16px; }
.pj-topbar { display:flex; align-items:center; justify-content:space-between; gap:16px; margin-bottom:10px; }
.pj-title { display:flex; align-items:center; gap:12px; }
.pj-ico { font-size: 26px; }
.pj-h1 { font-weight:700; color:#004d99; }
.pj-h2 { font-size: 12px; opacity:.8; }
.pj-actions { display:flex; gap:10px; flex-wrap:wrap; }

.pj-nav { background:#004d99; padding:10px; display:flex; gap:20px; border-radius:8px; }
.pj-tab { color:#fff; cursor:pointer; user-select:none; opacity:.9; }
.pj-tab.active { font-weight:700; opacity:1; text-decoration: underline; }

.pj-section { margin-top: 14px; }
.pj-row { display:flex; gap:10px; align-items:center; flex-wrap:wrap; }
.pj-input { padding:10px; border-radius:6px; border:1px solid #cfd8dc; min-width:260px; }
.pj-textarea { width:100%; border-radius:6px; border:1px solid #cfd8dc; padding:10px; }

.btn { background:#004d99; color:#fff; border:none; padding:10px 16px; font-weight:700; border-radius:6px; cursor:pointer; }
.btn:hover { background:#003366; }
.btn.primary { box-shadow: 0 0 0 2px rgba(255,102,0,.2) inset; }
.btn:disabled { opacity:.5; cursor:not-allowed; }

.card { background:#fff; border-left:5px solid #ff6600; box-shadow: 0 0 10px rgba(0,0,0,0.05); padding:15px 20px; margin: 12px 0; border-radius:8px; }
.card h3 { margin-top:0; color:#004d99; }
.info-row { margin:5px 0; }
.label { font-weight:bold; color:#004d99; }
.value { margin-left:5px; }

.pj-log { width:100%; background:#f8f8f8; color:#333; font-family:monospace; border:1px solid #cfd8dc; border-radius:6px; padding:10px; }

.pj-table { width:100%; margin-top:10px; background:#fff; border-collapse: collapse; }
.pj-table th, .pj-table td { border:1px solid #e0e0e0; padding:8px; text-align:left; }
.pj-table th { background:#f0f6ff; color:#004d99; }

.pj-status { font-weight:700; color:#004d99; }
.pj-progress { margin-top:10px; }
.pj-progress-txt { font-size: 0.9em; margin-top: 4px; }



/* tudo que for do componente pode ficar normal aqui */

/* ✅ CSS dos cards (igual pesquisaCNPJ.html) */
::v-deep .card {
  background: #fff;
  border-left: 5px solid #ff6600;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.05);
  padding: 15px 20px;
  margin-bottom: 15px;
  border-radius: 8px;
}

::v-deep .card h3 {
  margin-top: 0;
  color: #004d99;
}

::v-deep .info-row {
  margin: 5px 0;
}

::v-deep .label {
  font-weight: bold;
  color: #004d99;
}

::v-deep .value {
  margin-left: 5px;
}

.toolbar-scroll { padding: 4px 2px; }
.seta-form { color: #512da8; }
.bg-form { font-weight: 700; }


.pj-split {
  display: flex;
  gap: 14px;
  align-items: flex-start;
}

/* esquerda mais estreita (cards) */
.pj-left {
  flex: 0 0 42%;
  max-width: 42%;
}

/* direita maior (tabs/form) */
.pj-right {
  flex: 1;
  min-width: 0;
}

/* responsivo: empilha no mobile */
@media (max-width: 1100px) {
  .pj-split {
    flex-direction: column;
  }
  .pj-left, .pj-right {
    max-width: 100%;
    flex: 1 1 auto;
  }
}
::v-deep .card {
  width: 100% !important;
}

.tab-alerta {
  color: #c62828 !important;
  font-weight: 700;
}

.campo-dif .q-field__control {
  border: 1px solid #d32f2f !important;
}
.campo-dif .q-field__label {
  color: #d32f2f !important;
}

</style>

