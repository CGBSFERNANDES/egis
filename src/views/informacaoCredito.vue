<template>
  <div>
    <!-- --------------------Topo------------- -->
    <q-toolbar class="bg-orange-9 text-white shadow-2 tabs">
      <q-radio
        class="margin1"
        color="white"
        dark
        v-model="pesquisa_cliente"
        val="Fantasia"
        label="Fantasia"
      ></q-radio>
      <q-radio
        class="margin1"
        color="white"
        dark
        v-model="pesquisa_cliente"
        val="CNPJ"
        label="CNPJ"
      ></q-radio>
      <q-radio
        class="margin1"
        color="white"
        dark
        v-model="pesquisa_cliente"
        val="CPF"
        label="CPF"
      ></q-radio>

      <q-input
        dark
        dense
        borderless
        color="white"
        :maxlength="length_pesquisa"
        :mask="mask_pesquisa"
        v-model="input_cliente"
        label="Pesquisar"
        input-class="text-left"
        style="width:74%"
        @blur="PesquisaCliente"
      >
        <template v-slot:append>
          <q-icon v-if="input_cliente === ''" name="search"></q-icon>
          <q-icon
            v-else
            name="clear"
            class="cursor-pointer"
            @click="input_cliente = ''"
          ></q-icon>
        </template>
      </q-input>
    </q-toolbar>
    <!-- ------------------------ABAS (TABSHEET)------------------ -->
    <q-tabs
      v-model="abas"
      class="bg-orange-9 text-white shadow-2"
      inline-label
      no-caps
    >
      <q-tab name="0" icon="analytics" label="Dados" />
      <q-tab name="1" icon="description" label="Documento" />
      <q-tab name="2" icon="visibility" label="Observações" />
      <q-tab name="3" icon="app_registration" label="Informações de Cadastro" />
    </q-tabs>
    <q-tab-panels v-model="abas" animated>
      <q-tab-panel name="0">
        <!-- ------------------------GRID------------------ -->

        <q-expansion-item
          :label="'Cliente'"
          default-opened
          class="shadow-1 overflow-hidden margin1"
          style="border-radius: 20px; height:auto"
          header-class="bg-orange-9 text-white item-center text-h6"
          expand-icon-class="text-white"
        >
          <div class="borda-bloco shadow-2 margin1">
            <div class="row">
              <q-input dense class="tres-partes margin1">
                <template v-slot:prepend>
                  <q-icon name="work" />
                </template>
                <template v-slot:append>
                  <q-icon
                    v-if="business !== ''"
                    name="close"
                    @click.stop="
                      (business = ''),
                        (contact_pesq = ''),
                        (cd_site = ''),
                        (novo_telefone_org = ''),
                        (novo_email = ''),
                        (novo_celular = '')
                    "
                    class="cursor-pointer"
                  ></q-icon>
                </template>
              </q-input>
              <q-input
                readonly
                dense
                class="tres-partes margin1"
                v-model="cd_site"
                type="text"
                label="Site"
              >
                <template v-slot:prepend>
                  <q-icon name="language" />
                </template>
              </q-input>

              <q-input
                readonly
                dense
                class="tres-partes margin1"
                v-model="novo_telefone_org"
                type="text"
                label="Telefone"
              >
                <template v-slot:prepend>
                  <q-icon name="call" />
                </template>
              </q-input>
            </div>
          </div>
          <transition name="slide-fade">
            <div
              style="margin: 5px 0"
              v-if="GridOrg == true && this.business.length > 0"
            >
              <div class="row">
                <q-space />
                <q-btn
                  color="primary"
                  flat
                  rounded
                  label="Selecionar"
                  class="margin1"
                  @click="SelecionaOrganizacao()"
                >
                </q-btn>
              </div>
              <grid
                ref="gridOrganizacao"
                v-if="GridOrg == true && this.business.length > 0"
                :nm_json="consultaOrganizacao"
                :cd_consulta="2"
                :cd_menuID="7294"
                :cd_apiID="636"
                :filterGrid="false"
              />
            </div>
          </transition>
          <transition name="slide-fade">
            <div class="row items-center" v-show="cd_organizacao > 0">
              <q-select
                v-model="contact_pesq"
                dense
                use-input
                hide-selected
                fill-input
                input-debounce="0"
                :options="opcoes_organizacao_contato"
                option-value="cd_contato_crm"
                option-label="nm_contato_crm"
                @filter="filterOrganizacaoContato"
                label="Contato"
                class="input-add tres-partes margin1"
                @input="DadosContato"
              >
                <template v-slot:append>
                  <q-btn
                    round
                    color="primary"
                    icon="add"
                    size="sm"
                    @click="onAddContato(2)"
                  />
                </template>
                <template v-slot:prepend>
                  <q-icon name="person_add_alt_1" />
                </template>
              </q-select>
            </div>
          </transition>
          <template v-slot:no-option>
            <q-item>
              <q-btn
                round
                color="primary"
                icon="add"
                @click="onAddContato(2)"
                style="float:right"
              >
                <q-tooltip
                  anchor="bottom middle"
                  self="top middle"
                  :offset="[10, 10]"
                >
                  <strong>Novo Cadastro</strong>
                </q-tooltip>
              </q-btn>
              <q-item-section class="text-italic text-grey">
                Nenhum contato encontrado.
              </q-item-section>
            </q-item>
          </template>
          <q-input
            dense
            readonly
            class="tres-partes margin1"
            v-model="novo_email"
            type="text"
            label="E-mail"
          >
            <template v-slot:prepend>
              <q-icon name="email" />
            </template>
          </q-input>

          <q-input
            dense
            readonly
            class="tres-partes margin1"
            v-model="novo_celular"
            mask="(##) #####-####"
            type="text"
            label="Celular"
          >
            <template v-slot:prepend>
              <q-icon name="smartphone" />
            </template>
          </q-input>
        </q-expansion-item>
        <q-expansion-item
          :label="'Dados do Crédito'"
          default-opened
          class="shadow-1 overflow-hidden margin1"
          style="border-radius: 20px; height:auto"
          header-class="bg-orange-9 text-white item-center text-h6"
          expand-icon-class="text-white"
        >
          <div class="borda-bloco shadow-2 margin1">
            <div class="row">
              <q-input dense class="tres-partes margin1">
                <template v-slot:prepend>
                  <q-icon name="work" />
                </template>
                <template v-slot:append>
                  <q-icon
                    v-if="business !== ''"
                    name="close"
                    @click.stop="
                      (business = ''),
                        (contact_pesq = ''),
                        (cd_site = ''),
                        (novo_telefone_org = ''),
                        (novo_email = ''),
                        (novo_celular = '')
                    "
                    class="cursor-pointer"
                  ></q-icon>
                </template>
              </q-input>
              <q-input
                readonly
                dense
                class="tres-partes margin1"
                v-model="cd_site"
                type="text"
                label="Site"
              >
                <template v-slot:prepend>
                  <q-icon name="language" />
                </template>
              </q-input>

              <q-input
                readonly
                dense
                class="tres-partes margin1"
                v-model="novo_telefone_org"
                type="text"
                label="Telefone"
              >
                <template v-slot:prepend>
                  <q-icon name="call" />
                </template>
              </q-input>
            </div>
          </div>
          <transition name="slide-fade">
            <div
              style="margin: 5px 0"
              v-if="GridOrg == true && this.business.length > 0"
            >
              <div class="row">
                <q-space />
                <q-btn
                  color="primary"
                  flat
                  rounded
                  label="Selecionar"
                  class="margin1"
                  @click="SelecionaOrganizacao()"
                >
                </q-btn>
              </div>
              <grid
                ref="gridOrganizacao"
                v-if="GridOrg == true && this.business.length > 0"
                :nm_json="consultaOrganizacao"
                :cd_consulta="2"
                :cd_menuID="7294"
                :cd_apiID="636"
                :filterGrid="false"
              />
            </div>
          </transition>
          <transition name="slide-fade">
            <div class="row items-center" v-show="cd_organizacao > 0">
              <q-select
                v-model="contact_pesq"
                dense
                use-input
                hide-selected
                fill-input
                input-debounce="0"
                :options="opcoes_organizacao_contato"
                option-value="cd_contato_crm"
                option-label="nm_contato_crm"
                @filter="filterOrganizacaoContato"
                label="Contato"
                class="input-add tres-partes margin1"
                @input="DadosContato"
              >
                <template v-slot:append>
                  <q-btn
                    round
                    color="primary"
                    icon="add"
                    size="sm"
                    @click="onAddContato(2)"
                  />
                </template>
                <template v-slot:prepend>
                  <q-icon name="person_add_alt_1" />
                </template>
              </q-select>
            </div>
          </transition>
          <template v-slot:no-option>
            <q-item>
              <q-btn
                round
                color="primary"
                icon="add"
                @click="onAddContato(2)"
                style="float:right"
              >
                <q-tooltip
                  anchor="bottom middle"
                  self="top middle"
                  :offset="[10, 10]"
                >
                  <strong>Novo Cadastro</strong>
                </q-tooltip>
              </q-btn>
              <q-item-section class="text-italic text-grey">
                Nenhum contato encontrado.
              </q-item-section>
            </q-item>
          </template>
          <q-input
            dense
            readonly
            class="tres-partes margin1"
            v-model="novo_email"
            type="text"
            label="E-mail"
          >
            <template v-slot:prepend>
              <q-icon name="email" />
            </template>
          </q-input>

          <q-input
            dense
            readonly
            class="tres-partes margin1"
            v-model="novo_celular"
            mask="(##) #####-####"
            type="text"
            label="Celular"
          >
            <template v-slot:prepend>
              <q-icon name="smartphone" />
            </template>
          </q-input>
        </q-expansion-item>
      </q-tab-panel>
    </q-tab-panels>

    <!-- ------------------------GRIDFIM------------------ -->
  </div>
</template>

<script>
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import Menu from "../http/menu";
import funcao from "../http/funcoes-padroes";

export default {
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
  },
  watch: {
    pesquisa_cliente(a, b) {
      if (a === "Fantasia") {
        this.input_cliente = "";
        this.length_pesquisa = 30;
        this.mask_pesquisa = "";
      } else if (a === "CPF") {
        this.input_cliente = "";
        this.length_pesquisa = 14;
        this.mask_pesquisa = "###.###.###-##";
      } else if (a === "CNPJ") {
        this.input_cliente = "";
        this.length_pesquisa = 18;
        this.mask_pesquisa = "##.###.###/####-##";
      }
    },
    abas(a, b) {
      console.log(a, b, "ABAS");
    },
  },

  data() {
    return {
      business: [],
      api: "",
      abas: 0,
      length_pesquisa: 60,
      mask_pesquisa: "",
      pesquisa_cliente: "",
      input_cliente: [],
      cd_site: [],
      novo_telefone_org: [],
      GridOrg: [],
      cd_organizacao: [],
      opcoes_organizacao_contato: [],
      filterOrganizacaoContato: [],
      DadosContato: [],
      contact_pesq: [],
      novo_email: [],
      novo_celular: [],
      cd_organizacao: [],
    };
  },
  methods: {
    async PesquisaCliente() {
      var cliente = {
        cd_parametro: 1,
        cd_pedido_venda: this.cd_pedido_venda,
        vl_total_pedido_venda: this.valorTotal.replace("R$", ""),
        carrinho: this.carrinho,
      };
      let cliente_encontrado = await Incluir.incluirRegistro(this.api, cliente); //pr_egisnet_elabora_pedido_venda
      console.log(cliente_encontrado, "MEU INDICE");
    },
  },
};
</script>

<style>
.margin1 {
  width: 0.5vh 0.5vw;
}
.tabs {
  color: white;
  text-align: center;
}
</style>
