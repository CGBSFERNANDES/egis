<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <transition name="slide-fade">
      <div
        class="margin1 text-h5"
        v-show="!!title == true && cd_tipo_pesquisaID == 0"
      >
        {{ title }}
      </div>
    </transition>
    <q-tabs
      v-if="cd_tipo_pesquisaID == 0"
      @click="ChangeTab()"
      :class="' borda margin1 bg-' + color"
      v-model="tab"
      inline-label
      mobile-arrows
      class="text-white shadow-2 items-center"
    >
      <q-tab
        name="1"
        icon="account_circle"
        :label="tabName[0]"
        v-if="cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 1"
      />
      <q-tab
        name="2"
        icon="storefront"
        :label="tabName[1]"
        v-if="cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 2"
      />
      <q-tab
        name="3"
        icon="person"
        :label="tabName[2]"
        v-if="cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 3"
      />
      <q-tab
        name="4"
        icon="local_shipping"
        :label="tabName[3]"
        v-if="cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 4"
      />
      <!--

      <q-tab
        name="4"
        icon="local_shipping"
        :label="tabName[3]"
        v-if="cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 4"
      />
      <q-tab
        name="5"
        icon="face"
        :label="tabName[4]"
        v-if="cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 5"
      />
      <q-tab
        name="6"
        icon="badge"
        :label="tabName[5]"
        v-if="cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 6"
      />
      <q-tab
        name="7"
        icon="account_balance"
        :label="tabName[6]"
        v-if="cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 7"
      />
      -->
      <q-tab
        name="5"
        icon="account_balance"
        :label="tabName[4]"
        v-if="cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 5"
      />
    </q-tabs>
    <!--CLIENTE------------------------------------------------------------>
    <transition name="slide-fade">
      <div
        class="margin1"
        v-if="
          tab == '1' && (cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 1)
        "
      >
        <cliente ref="cliente" @DbClick="OnSelectCliente($event)" />
      </div>
    </transition>

    <!--Fornecedor------------------------------------------------------------>
    <transition name="slide-fade">
      <div class="margin1" v-if="tab > 1">
        <div class="row text-h6 margin1">
          Cadastro de {{ tabName[tab - 1] }}
        </div>
        <q-tabs
          v-model="tabChild"
          inline-label
          mobile-arrows
          @click="clicktabChild()"
          align="justify"
          style="border-radius:20px"
          :class="'bg-' + color + ' text-white shadow-2 margin1'"
        >
          <q-tab :name="0" icon="description" label="Dados" />
          <q-tab :name="1" icon="edit" :label="tabName[tab - 1]" />
        </q-tabs>
        <div class="margin1" v-if="tabChild == 0">
          <grid
            v-if="tab == 2"
            :cd_menuID="7495"
            :cd_apiID="771"
            :cd_parametroID="0"
            :cd_consulta="0"
            :nm_json="{}"
            @Linha="PegaLinha($event, 2)"
            @emit-click="OnSelectCliente($event)"
            ref="grid_fornecedor"
          />
          <grid_vendedor
            v-if="tab == 3"
            :cd_menuID="7497"
            :cd_apiID="773"
            :cd_parametroID="0"
            :cd_consulta="0"
            :nm_json="{}"
            @Linha="PegaLinha($event, 3)"
            @emit-click="OnSelectCliente($event)"
            ref="grid_vendedor"
          />

          <grid_transportadora
            v-if="tab == 4"
            :cd_menuID="7502"
            :cd_apiID="775"
            :cd_parametroID="0"
            :cd_consulta="0"
            :nm_json="{}"
            @Linha="PegaLinha($event, 4)"
            @emit-click="OnSelectCliente($event)"
            ref="grid_transportadora"
          />

          <grid_empresa_diversa
            v-if="tab == 5"
            :cd_menuID="7953"
            :cd_apiID="933"
            :cd_parametroID="0"
            :cd_consulta="0"
            :nm_json="{}"
            @Linha="PegaLinha($event, 4)"
            @emit-click="OnSelectCliente($event)"
            ref="grid_empresa_diversa"
          />

          <div class="row">
            <q-btn
              v-if="tab != 1"
              :color="color"
              icon="refresh"
              class="margin1"
              label="Recarregar"
              rounded
              @click="CarregaGrid()"
            />

            <q-btn
              :color="color"
              icon="add"
              class="margin1"
              label="Inserir"
              rounded
              @click="
                Clear();
                tabChild = 1;
              "
            />
            <transition name="slide-fade">
              <q-btn
                :color="color"
                icon="close"
                class="margin1"
                v-show="
                  !!destinatario.cd_fornecedor ||
                    !!destinatario.cd_vendedor ||
                    !!destinatario.cd_transportadora
                "
                label="Excluir"
                rounded
                @click="Excluir()"
              />
            </transition>
          </div>
        </div>

        <div v-if="tabChild == 1">
          <q-card style="border-radius:20px" class="margin1">
            <div class="row justify-around">
              <q-select
                class=" margin1 metadeTela"
                option-value="cd_tipo_pessoa"
                option-label="nm_tipo_pessoa"
                v-model="destinatario.tipo_pessoa"
                :options="lokup_tipo_pessoa"
                label="Tipo Pessoa"
                filled
              >
                <template v-slot:prepend>
                  <q-icon name="group" />
                </template>
              </q-select>
            </div>
            <div class="row justify-around">
              <transition name="slide-fade">
                <q-input
                  class="margin1 umTercoTela "
                  id="cnpj"
                  v-if="destinatario.tipo_pessoa.cd_tipo_pessoa == 1"
                  @blur="SearchCNPJ()"
                  mask="##.###.###/####-##"
                  v-model="destinatario.cd_cnpj_fornecedor"
                  :value.sync="destinatario.cd_cnpj_fornecedor"
                  label="CNPJ"
                >
                  <template v-slot:prepend>
                    <q-icon name="badge"></q-icon>
                  </template>
                </q-input>
              </transition>
              <transition name="slide-fade">
                <q-input
                  class="margin1 umTercoTela "
                  id="cpf"
                  v-if="destinatario.tipo_pessoa.cd_tipo_pessoa == 2"
                  mask="###.###.###-##"
                  v-model="destinatario.cd_cnpj_fornecedor"
                  :value.sync="destinatario.cd_cnpj_fornecedor"
                  label="CPF"
                >
                  <template v-slot:prepend>
                    <q-icon name="badge" />
                  </template>
                </q-input>
              </transition>
              <q-input
                class="margin1 umTercoTela "
                v-model="destinatario.nm_fantasia_destinatario"
                :value.sync="destinatario.nm_fantasia_destinatario"
                label="Fantasia"
              >
                <template v-slot:prepend>
                  <q-icon name="badge"></q-icon>
                </template>
              </q-input>

              <q-input
                @blur="
                  if (destinatario.nm_razao_social.length > 2) {
                    destinatario.sg_fornecedor = destinatario.nm_razao_social
                      .substring(0, 3)
                      .toUpperCase();
                  }
                "
                class="margin1 umTercoTela"
                v-if="destinatario.tipo_pessoa.cd_tipo_pessoa == 1"
                v-model="destinatario.nm_razao_social"
                :value.sync="destinatario.nm_razao_social"
                label="Razão Social"
              >
                <template v-slot:prepend>
                  <q-icon name="badge"></q-icon>
                </template>
              </q-input>

              <q-input
                v-else
                class="margin1 umTercoTela"
                @blur="
                  if (destinatario.nm_razao_social.length > 2) {
                    destinatario.sg_fornecedor = destinatario.nm_razao_social
                      .substring(0, 3)
                      .toUpperCase();
                  }
                "
                v-model="destinatario.nm_razao_social"
                :value.sync="destinatario.nm_razao_social"
                label="Nome Completo"
              >
                <template v-slot:prepend>
                  <q-icon name="edit"></q-icon>
                </template>
              </q-input>
            </div>
            <div class="row justify-around">
              <q-input
                v-model="destinatario.dt_cadastro_fornecedor"
                class="umTercoTela margin1"
                mask="##/##/####"
                :label="
                  destinatario.tipo_pessoa.cd_tipo_pessoa == 1
                    ? 'Data de Abertura'
                    : 'Data de Nascimento'
                "
              >
                <template v-slot:prepend>
                  <q-icon name="today" />
                </template>
                <template v-slot:append>
                  <q-btn
                    icon="event"
                    :color="color"
                    round
                    size="sm"
                    class="cursor-pointer"
                  >
                    <q-popup-proxy
                      mask="DD/MM/YYYY"
                      ref="qDateProxy"
                      cover
                      transition-show="scale"
                      transition-hide="scale"
                      :color="color"
                    >
                      <q-date
                        id="data-pop"
                        v-model="destinatario.dt_cadastro_fornecedor"
                        mask="DD/MM/YYYY"
                        :color="color"
                      >
                        <div class="row justify-around">
                          <q-btn
                            v-close-popup
                            round
                            :color="color"
                            icon="close"
                            size="sm"
                          />
                        </div>
                      </q-date>
                    </q-popup-proxy>
                  </q-btn>
                </template>
              </q-input>
              <q-input
                class="margin1 umTercoTela "
                v-model="destinatario.cd_telefone"
                :value.sync="destinatario.cd_telefone"
                mask="(##) ####-####"
                label="Telefone"
              >
                <template v-slot:prepend>
                  <q-icon name="call"></q-icon>
                </template>
              </q-input>

              <q-input
                class="margin1 umTercoTela "
                v-model="destinatario.cd_celular"
                v-if="tab != 4"
                :value.sync="destinatario.cd_celular"
                mask="(##) #####-####"
                label="Celular"
              >
                <template v-slot:prepend>
                  <q-icon name="call"></q-icon>
                </template>
              </q-input>
            </div>
            <div class="row justify-around">
              <q-input
                class="margin1 umTercoTela "
                maxlength="10"
                v-model="destinatario.sg_fornecedor"
                :value.sync="destinatario.sg_fornecedor"
                label="Sigla"
              >
                <template v-slot:prepend>
                  <q-icon name="badge" />
                </template>
              </q-input>
              <q-input
                class="margin1 umTercoTela "
                v-model="destinatario.cd_cep"
                autogrow
                @blur="BuscaCep()"
                :value.sync="destinatario.cd_cep"
                label="CEP"
                mask="##.###-###"
              >
                <template v-slot:prepend>
                  <q-icon name="home" />
                </template>
              </q-input>
              <q-input
                class="margin1 umTercoTela "
                v-model="destinatario.cd_numero_endereco"
                :value.sync="destinatario.cd_numero_endereco"
                label="Número"
              >
                <template v-slot:prepend>
                  <q-icon name="tag" />
                </template>
              </q-input>
              <q-select
                class=" margin1 umTercoTela"
                option-value="cd_estado"
                @blur="FiltraCidade()"
                option-label="sg_estado"
                v-model="destinatario.estado"
                :options="lokup_estado"
                label="Estado"
              >
                <template v-slot:prepend>
                  <q-icon name="real_estate_agent" />
                </template>
              </q-select>
              <transition name="slide-fade">
                <q-select
                  class=" margin1 umTercoTela"
                  option-value="cd_cidade"
                  option-label="nm_cidade"
                  v-model="destinatario.cidade"
                  v-show="!!destinatario.estado.cd_estado == true"
                  :options="lokup_cidade_filtrado"
                  label="Cidade"
                >
                  <template v-slot:prepend>
                    <q-icon name="public" />
                  </template>
                </q-select>
              </transition>

              <q-input
                class="margin1 umTercoTela "
                v-model="destinatario.nm_endereco_destinatario"
                :value.sync="destinatario.nm_endereco_destinatario"
                label="Endereço"
              >
                <template v-slot:prepend>
                  <q-icon name="subject" />
                </template>
              </q-input>

              <q-input
                class="margin1 umTercoTela "
                v-model="destinatario.nm_bairro"
                :value.sync="destinatario.nm_bairro"
                label="Bairro"
              >
                <template v-slot:prepend>
                  <q-icon name="person_pin_circle" />
                </template>
              </q-input>
              <q-input
                class="margin1 umTercoTela "
                v-model="destinatario.nm_complemento_endereco"
                :value.sync="destinatario.nm_complemento_endereco"
                label="Complemento"
              >
                <template v-slot:prepend>
                  <q-icon name="bookmark_added" />
                </template>
              </q-input>

              <q-input
                class="margin1 umTercoTela "
                v-model="destinatario.nm_email_destinatario"
                autogrow
                :value.sync="destinatario.nm_email_destinatario"
                label="E-mail"
              >
                <template v-slot:prepend>
                  <q-icon name="mail" />
                </template>
              </q-input>
              <q-input
                class="margin1 telaInteira "
                v-model="destinatario.ds_destinatario"
                autogrow
                :value.sync="destinatario.ds_destinatario"
                label="Descritivo"
              >
                <template v-slot:prepend>
                  <q-icon name="description" />
                </template>
              </q-input>
            </div>
          </q-card>
          <q-card style="border-radius:20px" class="margin1">
            <div class="row justify-around">
              <q-select
                v-if="tab == 3"
                class=" margin1 umTercoTela"
                option-value="cd_tipo_vendedor"
                option-label="nm_tipo_vendedor"
                v-model="destinatario.vendedor"
                :options="lokup_tipo_vendedor"
                label="Tipo Vendedor"
              >
                <template v-slot:prepend>
                  <q-icon name="double_arrow" />
                </template>
              </q-select>
              <q-select
                v-if="tab == 3"
                class=" margin1 umTercoTela"
                option-value="cd_tipo_comissao"
                option-label="nm_tipo_comissao"
                v-model="destinatario.comissao"
                :options="lookup_tipo_comissao"
                label="Tipo Comissão"
              >
                <template v-slot:prepend>
                  <q-icon name="format_align_left" />
                </template>
              </q-select>

              <q-select
                v-if="tab == 3"
                class=" margin1 umTercoTela"
                option-value="cd_departamento"
                option-label="nm_departamento"
                v-model="destinatario.departamento"
                :options="lookup_departamento"
                label="Departamento"
              >
                <template v-slot:prepend>
                  <q-icon name="checklist" />
                </template>
              </q-select>

              <q-select
                v-if="tab == 2"
                class=" margin1 umTercoTela"
                option-value="cd_tipo_envio"
                option-label="nm_tipo_envio"
                v-model="destinatario.envio"
                :options="lookup_tipo_envio"
                label="Tipo Envio"
              >
                <template v-slot:prepend>
                  <q-icon name="double_arrow" />
                </template>
              </q-select>
              <q-select
                v-if="tab == 2"
                class="margin1 umTercoTela"
                option-value="cd_condicao_pagamento"
                option-label="nm_condicao_pagamento"
                v-model="destinatario.pagamento"
                :options="lookup_condicao_pagamento"
                label="Condição Pagamento"
              >
                <template v-slot:prepend>
                  <q-icon name="payments" />
                </template>
              </q-select>
              <q-select
                v-if="tab == 2"
                class="margin1 umTercoTela"
                option-value="cd_destinacao_produto"
                option-label="nm_destinacao_produto"
                v-model="destinatario.destincacao"
                :options="lookup_destinacao"
                label="Destinação Produto"
              >
                <template v-slot:prepend>
                  <q-icon name="category" />
                </template>
              </q-select>
            </div>
            <div class="row justify-around">
              <q-select
                v-if="tab == 2 || tab == 4"
                class="margin1 umTercoTela"
                option-value="cd_tipo_mercado"
                option-label="nm_tipo_mercado"
                v-model="destinatario.mercado"
                :options="lookup_mercado"
                label="Tipo Mercado"
              >
                <template v-slot:prepend>
                  <q-icon name="storefront" />
                </template>
              </q-select>
              <q-select
                v-if="tab == 4"
                class="margin1 umTercoTela"
                option-value="cd_tipo_frete"
                option-label="nm_tipo_frete"
                v-model="destinatario.frete"
                :options="lokup_tipo_frete"
                label="Tipo Frete"
              >
                <template v-slot:prepend>
                  <q-icon name="local_shipping" />
                </template>
              </q-select>
              <q-select
                v-if="tab == 4"
                class="margin1 umTercoTela"
                option-value="cd_tipo_transporte"
                option-label="nm_tipo_transporte"
                v-model="destinatario.transporte"
                :options="lookup_tipo_transporte"
                label="Tipo Transporte"
              >
                <template v-slot:prepend>
                  <q-icon name="format_align_center" />
                </template>
              </q-select>
              <q-select
                v-if="tab == 4"
                class="margin1 telaInteira"
                option-value="cd_tipo_pagamento_frete"
                option-label="nm_tipo_pagamento_frete"
                v-model="destinatario.pagamento_frete"
                :options="lookup_tipo_pagamento_frete"
                label="Tipo Pagamento Frete"
              >
                <template v-slot:prepend>
                  <q-icon name="payments" />
                </template>
              </q-select>

              <q-select
                v-if="tab == 2"
                class="margin1 umTercoTela"
                option-value="cd_transportadora"
                option-label="nm_transportadora"
                v-model="destinatario.transportadora"
                :options="lookup_transportadora"
                label="Transportadora"
              >
                <template v-slot:prepend>
                  <q-icon name="local_shipping" />
                </template>
              </q-select>
              <q-select
                v-if="tab == 2"
                class="margin1 umTercoTela"
                option-value="cd_grupo_fornecedor"
                option-label="nm_grupo_fornecedor"
                v-model="destinatario.grupo"
                :options="lookup_grupo"
                label="Grupo"
              >
                <template v-slot:prepend>
                  <q-icon name="group" />
                </template>
              </q-select>
              <!--
<q-select
                class="margin1 umTercoTela"
                option-value="cd_aplicacao_produto"
                option-label="nm_aplicacao_produto"
                v-model="fornecedor.aplicacao"
                :options="lookup_aplicacao"
                label="Aplicação do Produto"
              >
                <template v-slot:prepend>
                  <q-icon name="group" />
                </template>
              </q-select>

              -->
            </div>
            <div class="row justify-around">
              <q-input
                v-if="tab == 2"
                class="margin1 telaInteira"
                autogrow
                maxlength="200"
                v-model="destinatario.cd_pix"
                :value.sync="destinatario.cd_pix"
                label="Pix"
              >
                <template v-slot:prepend>
                  <q-icon name="request_quote" />
                </template>
              </q-input>
            </div>
            <div class="row">
              <q-space />
              <q-btn
                :color="color"
                icon="save"
                label="Gravar"
                class="margin1"
                rounded
                @click="Save()"
              />
            </div>
          </q-card>
        </div>
      </div>
    </transition>

    <!--Vendedor------------------------------------------------------------>
    <!--
   <transition name="slide-fade">
      <div
        class="margin1"
        v-if="
          tab == '3' && (cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 3)
        "
      >
        Vendedor
      </div>
    </transition>

    -->

    <!--Transportadora------------------------------------------------------------>
    <!--
      <transition name="slide-fade">
      <div
        class="margin1"
        v-if="
          tab == '4' && (cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 4)
        "
      >
        Transportadora
      </div>
    </transition>
    -->

    <!--Representante------------------------------------------------------------>
    <!--
       <transition name="slide-fade">
      <div
        class="margin1"
        v-if="
          tab == '5' && (cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 5)
        "
      >
        Representante
      </div>
    </transition>


    -->

    <!--Funcionário------------------------------------------------------------>
    <!--
 <transition name="slide-fade">
      <div
        class="margin1"
        v-if="
          tab == '6' && (cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 6)
        "
      >
        Funcionário
      </div>
    </transition>

    -->

    <!--Agência Banco------------------------------------------------------------>
    <!--
    <transition name="slide-fade">
      <div
        class="margin1"
        v-if="
          tab == '7' && (cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 7)
        "
      >
        Agência Banco
      </div>
    </transition>
    -->

    <!--Empresa Diversa------------------------------------------------------------>
    <transition name="slide-fade">
      <div
        class="margin1"
        v-if="
          tab == '9' && (cd_tipo_pesquisaID == 0 || cd_tipo_pesquisaID == 9)
        "
      >
        Empresa Diversa
      </div>
    </transition>
    

    <!--Loading------------------------------------------------------------>
    <q-dialog v-model="load" maximized persistent>
      <carregando :corID="color" :mensagemID="msgDinamica" />
    </q-dialog>
  </div>
</template>

<script>
import funcao from "../http/funcoes-padroes";
import Menu from "../http/menu";
import Lookup from "../http/lookup";
import ptMessages from "devextreme/localization/messages/pt.json";

import notify from "devextreme/ui/notify";
import Incluir from "../http/incluir_registro";
import { loadMessages, locale } from "devextreme/localization";
import config from "devextreme/core/config";

import formataData from "../http/formataData";

export default {
  name: "pesquisaDestinatario",
  props: {
    cd_tipo_pesquisaID: { type: Number, default: 0 },
    colorID: { type: String, default: "" },
  },
  components: {
    carregando: () => import("../components/carregando.vue"),
    cliente: () => import("../views/cliente.vue"),
    grid: () => import("../views/grid.vue"),
    grid_vendedor: () => import("../views/grid.vue"),
    grid_transportadora: () => import("../views/grid.vue"),
    grid_empresa_diversa: () => import("../views/grid.vue"),
  },
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_menu: localStorage.cd_menu,
      apiLocal: localStorage.cd_api, //api localStorage
      cd_modulo: localStorage.cd_modulo,
      cd_usuario: localStorage.cd_usuario,
      tab: "",
      color: "",
      title: "",
      msgDinamica: "Aguarde...",
      lokup_cidade: [],
      lokup_estado: [],
      lokup_cidade_filtrado: [],
      lookup_tipo_envio: [],
      lookup_condicao_pagamento: [],
      lookup_destinacao: [],
      lookup_mercado: [],
      lookup_transportadora: [],
      lookup_aplicacao: [],
      lookup_grupo: [],
      lokup_tipo_frete: [],
      lookup_tipo_comissao: [],
      lokup_tipo_vendedor: [],
      lokup_tipo_pessoa: [],
      lookup_departamento: [],
      lookup_tipo_transporte: [],
      lookup_tipo_pagamento_frete: [],

      load: false,
      destinatario: {
        cd_fornecedor: 0,
        dt_cadastro_fornecedor: "",
        cd_cnpj_fornecedor: "",
        nm_razao_social: "",
        nm_fantasia_destinatario: "",
        cd_telefone: "",
        cd_celular: "",
        cd_cep: "",
        nm_bairro: "",
        nm_email_destinatario: "",
        nm_endereco_destinatario: "",

        nm_complemento_endereco: "",
        cd_numero_endereco: "",
        nm_situacao: "",
        ds_destinatario: "",
        cd_pix: "",
        cd_vendedor: 0,
        cd_transportadora: 0,

        departamento: {
          cd_departamento: 0,
          nm_departamento: "",
        },
        comissao: {
          cd_tipo_comissao: 0,
          nm_tipo_comissao: "",
        },
        vendedor: {
          cd_tipo_vendedor: 0,
          nm_tipo_vendedor: "",
        },
        tipo_pessoa: {
          cd_tipo_pessoa: 1,
          nm_tipo_pessoa: "Jurídica",
        },
        grupo: {
          cd_grupo_fornecedor: 0,
          nm_grupo_fornecedor: "",
        },
        aplicacao: {},
        transportadora: {
          cd_transportadora: 0,
          nm_transportadora: "",
        },
        pagamento_frete: {
          cd_tipo_pagamento_frete: 0,
          nm_tipo_pagamento_frete: "",
        },
        transporte: {
          cd_tipo_transporte: 0,
          nm_tipo_transporte: "",
        },
        frete: {
          cd_tipo_frete: 0,
          nm_tipo_frete: "",
        },
        mercado: {
          cd_tipo_mercado: 1,
          nm_tipo_mercado: "Interno",
        },
        transportadora: {
          cd_transportadora: 0,
          nm_transportadora: "",
        },
        destincacao: {
          cd_destinacao_produto: 0,
          nm_destinacao_produto: "",
        },
        pagamento: {
          cd_condicao_pagamento: 0,
          nm_condicao_pagamento: "",
        },
        cidade: {
          cd_cidade: 0,
          nm_cidade: "",
        },
        estado: {
          cd_estado: 0,
          sg_estado: "",
        },
        sg_fornecedor: "",
        envio: {
          cd_tipo_envio: 0,
          nm_tipo_envio: "",
        },
      },
      cd_api: "",
      tabName: [
        "Clientes",
        "Fornecedores",
        "Vendedores",
        "Transportadoras",
        "Empresa Diversa"
        // "Representantes",
        // "Funcionários",
        // "Agências de Bancos",
      ],
      menu: {},
      tabChild: 0,
    };
  },
  created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    if (this.cd_tipo_pesquisaID > 0) {
      this.tab = this.cd_tipo_pesquisaID;
    }
    this.color = this.colorID;
    !!this.color == false ? (this.color = "primary") : "";
    if (!!this.cd_tipo_pesquisaID == false) {
      this.tab = 1;
    }
    this.carregaMenu();
  },
  watch: {
    async destinatario() {
      await funcao.sleep(1000);
      if (this.destinatario.nm_razao_social.length > 2) {
        this.destinatario.sg_fornecedor = this.destinatario.nm_razao_social
          .substring(0, 3)
          .toUpperCase();
      }
    },
    cd_tipo_pesquisaID(novo, antigo) {
      this.tab = novo;
    },
    async tab() {
      if (this.tab == "0") {
      }
    },
    async tabChild() {
      if (this.tabChild == 0) {
        this.Clear();
      }
    },
  },

  methods: {
    async CarregaGrid() {
      if (this.tab == 2) {
        this.$refs.grid_fornecedor.carregaDados();
      } else if (this.tab == 3) {
        this.$refs.grid_vendedor.carregaDados();
      } else if (this.tab == 4) {
        this.$refs.grid_transportadora.carregaDados();
      } else if (this.tab == 5) {
        this.$refs.grid_empresa_diversa.carregaDados();
      }
    },
    async Excluir() {
      if (this.tab == "2") {
        this.msgDinamica = "Excluindo fornecedor....";
        this.load = true;
        let e = {
          cd_usuario: this.cd_usuario,
          cd_empresa: this.cd_empresa,
          cd_tipo_pesquisaID: 2,
          cd_parametro: 2,
          cd_modulo: this.cd_modulo,
          cd_fornecedor: this.destinatario.cd_fornecedor,
        };
        try {
          var envio = await Incluir.incluirRegistro(this.cd_api, e);
          notify(envio[0].Msg);
          this.load = false;
          this.msgDinamica = "Aguarde...";
          this.Clear();
        } catch (error) {
          this.load = false;
          this.msgDinamica = "Aguarde...";
        }
        this.$refs.grid_fornecedor.carregaDados();
      } else if (this.tab == "3") {
        this.msgDinamica = "Excluindo Vendedor....";
        this.load = true;
        let e = {
          cd_usuario: this.cd_usuario,
          cd_empresa: this.cd_empresa,
          cd_tipo_pesquisaID: 3,
          cd_parametro: 2,
          cd_modulo: this.cd_modulo,
          cd_vendedor: this.destinatario.cd_vendedor,
        };
        try {
          var envio = await Incluir.incluirRegistro(this.cd_api, e);
          notify(envio[0].Msg);
          this.load = false;
          this.msgDinamica = "Aguarde...";
          this.Clear();
        } catch (error) {
          this.load = false;
          this.msgDinamica = "Aguarde...";
        }
        this.$refs.grid_vendedor.carregaDados();
      } else if (this.tab == "4") {
        //Exclui transportadora
        this.msgDinamica = "Excluindo Transportadora....";
        this.load = true;
        let t = {
          cd_usuario: this.cd_usuario,
          cd_empresa: this.cd_empresa,
          cd_tipo_pesquisaID: 4,
          cd_parametro: 2,
          cd_modulo: this.cd_modulo,
          cd_transportadora: this.destinatario.cd_transportadora,
        };
        try {
          var envio = await Incluir.incluirRegistro(this.cd_api, t);
          notify(envio[0].Msg);
          this.load = false;
          this.msgDinamica = "Aguarde...";
          this.Clear();
        } catch (error) {
          this.load = false;
          this.msgDinamica = "Aguarde...";
        }
        this.$refs.grid_transportadora.carregaDados();
      } else if (this.tab == "5") {
        //Exclui Empresa Diversa
        this.msgDinamica = "Excluindo Empresa Diversa....";
        this.load = true;
        let t = {
          cd_usuario: this.cd_usuario,
          cd_empresa: this.cd_empresa,
          cd_tipo_pesquisaID: 4,
          cd_parametro: 2,
          cd_modulo: this.cd_modulo,
          cd_transportadora: this.destinatario.cd_transportadora,
        };
        try {
          var envio = await Incluir.incluirRegistro(this.cd_api, t);
          notify(envio[0].Msg);
          this.load = false;
          this.msgDinamica = "Aguarde...";
          this.Clear();
        } catch (error) {
          this.load = false;
          this.msgDinamica = "Aguarde...";
        }
        this.$refs.grid_empresa_diversa.carregaDados();
      }
    },
    async PegaLinha(linha, dest) {
      this.destinatario.tipo_pessoa = {
        cd_tipo_pessoa: linha.cd_tipo_pessoa,
        nm_tipo_pessoa: linha.nm_tipo_pessoa,
      };
      this.destinatario.cd_cep = linha.cd_cep;
      this.destinatario.cidade = {
        cd_cidade: linha.cd_cidade,
        nm_cidade: linha.nm_cidade,
      };
      this.destinatario.estado = {
        cd_estado: linha.cd_estado,
        sg_estado: linha.sg_estado,
      };
      this.destinatario.cd_telefone = await funcao.FormataTelefone(
        linha.cd_ddd + linha.cd_telefone
      );
      this.destinatario.cd_numero_endereco = linha.cd_numero_endereco;
      this.destinatario.nm_bairro = linha.nm_bairro;
      this.destinatario.nm_complemento_endereco = linha.nm_complemento_endereco;
      //==========================================================================================================================
      //Condicional criada para acertar variaveis com nomeclatura diferente
      if (dest == 2) {
        //Fornecedor---------------------------------------------
        this.destinatario.cd_fornecedor = linha.cd_fornecedor;
        this.destinatario.aplicacao = {
          cd_aplicacao_produto: linha.cd_aplicacao_produto,
          nm_aplicacao_produto: linha.nm_aplicacao_produto,
        };

        this.destinatario.cd_celular = await funcao.FormataCelular(
          linha.cd_celular_fornecedor
        );
        this.destinatario.cd_cnpj_fornecedor = linha.cd_cnpj_fornecedor;
        this.destinatario.pagamento = {
          cd_condicao_pagamento: linha.cd_condicao_pagamento,
          nm_condicao_pagamento: linha.nm_condicao_pagamento,
        };

        this.destinatario.destincacao = {
          cd_destinacao_produto: linha.cd_destinacao_produto,
          nm_destinacao_produto: linha.nm_destinacao_produto,
        };

        this.destinatario.destincacao = {
          cd_destinacao_produto: linha.cd_destinacao_produto,
          nm_destinacao_produto: linha.nm_destinacao_produto,
        };
        this.destinatario.cd_pix = linha.cd_pix;
        this.destinatario.envio = {
          cd_tipo_envio: linha.cd_tipo_envio,
          nm_tipo_envio: linha.nm_tipo_envio,
        };
        this.destinatario.transportadora = {
          cd_transportadora: linha.cd_transportadora,
          nm_transportadora: linha.nm_transportadora,
        };
        this.destinatario.mercado = {
          cd_tipo_mercado: linha.cd_tipo_mercado,
          nm_tipo_mercado: linha.nm_tipo_mercado,
        };

        this.destinatario.ds_destinatario = linha.ds_fornecedor;
        this.destinatario.dt_cadastro_fornecedor = linha.dt_cadastro_fornecedor;
        this.destinatario.pagamento = {
          cd_condicao_pagamento: linha.cd_condicao_pagamento,
          nm_condicao_pagamento: linha.nm_condicao_pagamento,
        };
        this.destinatario.nm_email_destinatario = linha.nm_email_fornecedor;
        this.destinatario.nm_endereco_destinatario =
          linha.nm_endereco_fornecedor;
        this.destinatario.nm_fantasia_destinatario =
          linha.nm_fantasia_fornecedor;
        this.destinatario.nm_razao_social = linha.nm_razao_social;
        this.destinatario.envio = {
          cd_tipo_envio: linha.cd_tipo_envio,
          nm_tipo_envio: linha.nm_tipo_envio,
        };
        this.destinatario.sg_fornecedor = linha.sg_fornecedor;
        this.destinatario.grupo = {
          cd_grupo_fornecedor: linha.cd_grupo_fornecedor,
          nm_grupo_fornecedor: linha.nm_grupo_fornecedor,
        };
      } else if (dest == 3) {
        //Vendedor---------------------------------------------
        if (!!linha.cd_celular) {
          this.destinatario.cd_celular = await funcao.FormataCelular(
            linha.cd_celular
          );
        }
        this.destinatario.cd_cnpj_fornecedor = linha.cd_cnpj;
        this.destinatario.comissao = {
          cd_tipo_comissao: linha.cd_tipo_comissao,
          nm_tipo_comissao: linha.nm_tipo_comissao,
        };
        this.destinatario.departamento = {
          cd_departamento: linha.cd_departamento,
          nm_departamento: linha.nm_departamento,
        };
        this.destinatario.vendedor = {
          cd_tipo_vendedor: linha.cd_tipo_vendedor,
          nm_tipo_vendedor: linha.nm_tipo_vendedor,
        };
        this.destinatario.cd_vendedor = linha.cd_vendedor;
        this.destinatario.nm_email_destinatario;
        this.destinatario.nm_endereco_destinatario = linha.nm_endereco;
        this.destinatario.nm_fantasia_destinatario = linha.nm_fantasia_vendedor;
        this.destinatario.cd_pix = linha.nm_pix_vendedor;
        this.destinatario.nm_razao_social = linha.nm_vendedor;
        this.destinatario.dt_cadastro_fornecedor = linha.dt_nascimento_vendedor;
        this.destinatario.sg_fornecedor = linha.sg_vendedor;
        this.destinatario.nm_email_destinatario = linha.nm_email;
        this.destinatario.ds_destinatario = linha.ds_perfil_vendedor;
        this.destinatario.vendedor = {
          cd_tipo_vendedor: linha.cd_tipo_vendedor,
          nm_tipo_vendedor: linha.nm_tipo_vendedor,
        };
      } else if (dest == 4) {
        //Transportadora---------------------------------------------
        this.destinatario.cd_transportadora = linha.cd_transportadora;
        this.destinatario.cd_cnpj_fornecedor = linha.cd_cnpj_transportadora;
        this.destinatario.ds_destinatario = linha.ds_transportadora;
        this.destinatario.dt_cadastro_fornecedor = linha.dt_cadastro;
        this.destinatario.nm_email_destinatario = linha.nm_email_transportadora;
        this.destinatario.nm_fantasia_destinatario = linha.nm_fantasia;
        this.destinatario.mercado = {
          cd_tipo_mercado: linha.cd_tipo_mercado,
          nm_tipo_mercado: linha.nm_tipo_mercado,
        };
        this.destinatario.nm_razao_social = linha.nm_transportadora;
        this.destinatario.nm_endereco_destinatario = linha.nm_endereco;
        this.destinatario.nm_email_destinatario = linha.nm_email_transportadora;
        this.destinatario.nm_complemento_endereco =
          linha.nm_endereco_complemento;
        this.destinatario.mercado = {
          cd_tipo_mercado: linha.cd_tipo_mercado,
          nm_tipo_mercado: linha.nm_tipo_mercado,
        };
        this.destinatario.pagamento_frete = {
          cd_tipo_pagamento_frete: linha.cd_tipo_pagamento_frete,
          nm_tipo_pagamento_frete: linha.nm_tipo_pagamento_frete,
        };
        this.destinatario.frete = {
          cd_tipo_frete: linha.cd_tipo_frete,
          nm_tipo_frete: linha.nm_tipo_frete,
        };
        this.destinatario.transporte = {
          cd_tipo_transporte: linha.cd_tipo_transporte,
          nm_tipo_transporte: linha.nm_tipo_transporte,
        };
      }
    },
    async BuscaCep() {
      //Busca de CEP
      if (this.destinatario.cd_cep.length < 9) return;

      try {
        this.msgDinamica = "Buscando CEP...";
        this.load = true;
        var cep = await funcao.buscaCep(
          this.destinatario.cd_cep.replace(".", "").replace("-", "")
        );
        cep = cep[0];
        if (
          !!cep.logradouro == false &&
          !!cep.cd_cidade == false &&
          !!cep.cd_estado == false
        ) {
          let not = {
            message: "CEP não encontrado!",
            type: "error",
          };
          notify(not);
        } else {
          this.destinatario.estado.cd_estado = cep.cd_estado;
          this.destinatario.estado.sg_estado = cep.uf;
          this.destinatario.cidade.cd_cidade = cep.cd_cidade;
          this.destinatario.cidade.nm_cidade = cep.localidade;
          this.destinatario.nm_endereco_destinatario = cep.logradouro;
          this.destinatario.nm_bairro = cep.bairro;
          //Acertar os campos recebidos...
        }
        this.load = false;
      } catch (error) {
        this.load = false;
      }
      this.load = false;
      this.msgDinamica = "Aguarde...";
    },
    async clicktabChild() {
      //if (this.tabChild == 1) {
      //  this.Clear();
      //  var linha = grid.Selecionada();
      //
      //  if (!!linha.cd_fornecedor == false) {
      //    this.tabChild = 0;
      //    let not = {
      //      message: "Selecione o fornecedor!",
      //      type: "error",
      //    };
      //    notify(not);
      //    return;
      //  }
      //}
    },
    OnSelectCliente(e) {
      this.$emit("DbClickDestinatario", e);
    },
    async ChangeTab() {
      //if (this.tab == "2") {
      this.tabChild = 0;
      await this.Clear();
      //}
    },
    async Clear() {
      this.destinatario = {
        cd_fornecedor: 0,
        cd_vendedor: 0,
        cd_transportadora: 0,

        dt_cadastro_fornecedor: "",
        cd_cnpj_fornecedor: "",
        nm_razao_social: "",
        nm_fantasia_destinatario: "",
        cd_telefone: "",
        cd_cep: "",
        nm_bairro: "",
        nm_email_destinatario: "",

        nm_complemento_endereco: "",
        nm_endereco_destinatario: "",
        cd_numero_endereco: "",
        nm_situacao: "",
        ds_destinatario: "",
        cd_pix: "",
        vendedor: {
          cd_tipo_vendedor: 0,
          nm_tipo_vendedor: "",
        },
        tipo_pessoa: {
          cd_tipo_pessoa: 1,
          nm_tipo_pessoa: "Jurídica",
        },
        comissao: {
          cd_tipo_comissao: 0,
          nm_tipo_comissao: "",
        },
        departamento: {
          cd_departamento: 0,
          nm_departamento: "",
        },
        transportadora: {
          cd_transportadora: 0,
          nm_transportadora: "",
        },
        mercado: {
          cd_tipo_mercado: 1,
          nm_tipo_mercado: "Interno",
        },
        frete: {
          cd_tipo_frete: 0,
          nm_tipo_frete: "",
        },
        transporte: {
          cd_tipo_transporte: 0,
          nm_tipo_transporte: "",
        },
        pagamento_frete: {
          cd_tipo_pagamento_frete: 0,
          nm_tipo_pagamento_frete: "",
        },
        grupo: {
          cd_grupo_fornecedor: 0,
          nm_grupo_fornecedor: "",
        },
        destincacao: {
          cd_destinacao_produto: 0,
          nm_destinacao_produto: "",
        },
        pagamento: {
          cd_condicao_pagamento: 0,
          nm_condicao_pagamento: "",
        },
        cidade: {
          cd_cidade: 0,
          nm_cidade: "",
        },
        estado: {
          cd_estado: 0,
          sg_estado: "",
        },
        sg_fornecedor: "",
        envio: {
          cd_tipo_envio: 0,
          nm_tipo_envio: "",
        },
      };
    },
    async Save() {
      if (
        this.destinatario.cd_cnpj_fornecedor.length < 14 &&
        this.destinatario.tipo_pessoa.cd_tipo_pessoa == 1
      ) {
        let not = {
          message: "Digite o CNPJ corretamente",
          type: "error",
        };
        notify(not);
        return;
      }
      if (
        this.destinatario.cd_cnpj_fornecedor.length < 11 &&
        this.destinatario.tipo_pessoa.cd_tipo_pessoa == 2
      ) {
        let not = {
          message: "Digite o CPF corretamente",
          type: "error",
        };
        notify(not);
        return;
      }
      if (!!this.destinatario.nm_fantasia_destinatario == false) {
        let not = {
          message: "Digite o nome fantasia!",
          type: "error",
        };
        notify(not);
        return;
      }
      if (this.destinatario.dt_cadastro_fornecedor.length < 10) {
        let not = {
          message: "Digite a data de abertura!",
          type: "error",
        };
        this.destinatario.tipo_pessoa.cd_tipo_pessoa == 2
          ? (not.message = "Digite a data de Nascimento!")
          : "";
        notify(not);
        return;
      }
      if (!!this.destinatario.cd_telefone == false) {
        let not = {
          message: "Digite o telefone",
          type: "error",
        };
        notify(not);
        return;
      }
      if (!!this.destinatario.nm_email_destinatario == false) {
        let not = {
          message: "Digite o E-mail!",
          type: "error",
        };
        notify(not);
        return;
      }

      if (!!this.destinatario.nm_razao_social == false) {
        let not = {
          message: "Digite a razão social!",
          type: "error",
        };
        notify(not);
        return;
      }

      if (this.destinatario.cd_cep.length < 9) {
        let not = {
          message: "Digite o CEP",
          type: "error",
        };
        notify(not);
        return;
      }
      if (!!this.destinatario.estado.cd_estado == false) {
        let not = {
          message: "Selecione o Estado!",
          type: "error",
        };
        notify(not);
        return;
      }
      if (!!this.destinatario.cidade.cd_cidade == false) {
        let not = {
          message: "Selecione a Cidade!",
          type: "error",
        };
        notify(not);
        return;
      }
      if (!!this.destinatario.nm_bairro == false) {
        let not = {
          message: "Digite o bairro!",
          type: "error",
        };
        notify(not);
        return;
      }
      if (!!this.destinatario.cd_numero_endereco == false) {
        let not = {
          message: "Digite o número!",
          type: "error",
        };
        notify(not);
        return;
      }
      //Envia fornecedor
      if (this.tab == 2) {
        let c = {
          cd_fornecedor: this.destinatario.cd_fornecedor,
          cd_cnpj_fornecedor: this.destinatario.cd_cnpj_fornecedor,
          nm_fantasia_fornecedor: this.destinatario.nm_fantasia_destinatario,
          nm_razao_social: this.destinatario.nm_razao_social,
          dt_cadastro_fornecedor: formataData.formataDataSQL(
            this.destinatario.dt_cadastro_fornecedor
          ),

          cd_parametro: 1,
          cd_tipo_pessoa: this.destinatario.tipo_pessoa.cd_tipo_pessoa,
          cd_celular: this.destinatario.cd_celular,
          cd_telefone: this.destinatario.cd_telefone,
          sg_fornecedor: this.destinatario.sg_fornecedor,
          cd_cep: this.destinatario.cd_cep,
          cd_estado: this.destinatario.estado.cd_estado,
          cd_cidade: this.destinatario.cidade.cd_cidade,
          nm_bairro: this.destinatario.nm_bairro,
          cd_tipo_pesquisaID: this.tab,
          nm_complemento_endereco: this.destinatario.nm_complemento_endereco,
          cd_numero_endereco: this.destinatario.cd_numero_endereco,
          nm_email_fornecedor: this.destinatario.nm_email_destinatario,
          ds_fornecedor: this.destinatario.ds_destinatario,
          nm_endereco_fornecedor: this.destinatario.nm_endereco_destinatario,
          cd_tipo_envio: this.destinatario.envio.cd_tipo_envio,
          cd_condicao_pagamento: this.destinatario.pagamento
            .cd_condicao_pagamento,
          cd_destinacao_produto: this.destinatario.destincacao
            .cd_destinacao_produto,
          cd_tipo_mercado: this.destinatario.mercado.cd_tipo_mercado,
          cd_transportadora: this.destinatario.transportadora.cd_transportadora,
          //cd_aplicacao_produto: this.destinatario.aplicacao.cd_aplicacao_produto,
          cd_grupo_fornecedor: this.destinatario.grupo.cd_grupo_fornecedor,
          cd_pix: this.destinatario.cd_pix,
          cd_usuario: this.cd_usuario,
          cd_empresa: this.cd_empresa,
          cd_modulo: this.cd_modulo,
        };

        try {
          this.msgDinamica = "Enviando dados...";
          this.load = true;
          var envio = await Incluir.incluirRegistro(this.cd_api, c);
          this.destinatario.cd_fornecedor = envio[0].cd_fornecedor;
          notify(envio[0].Msg);
          this.load = false;
        } catch (error) {
          this.load = false;
          this.msgDinamica = "Aguarde...";
          notify("Impossivel cadastrar/alterar registro");
        }
        //Envia Vendedor-------------------------------------------------------------
      } else if (this.tab == 3) {
        if (!!this.destinatario.vendedor.cd_tipo_vendedor == false) {
          let not = {
            message: "Selecione o tipo do vendedor!",
            type: "error",
          };
          notify(not);
          return;
        }
        const v = {
          cd_tipo_pesquisaID: this.tab,
          cd_vendedor: this.destinatario.cd_vendedor,
          cd_cep: this.destinatario.cd_cep,
          cd_cnpj_vendedor: this.destinatario.cd_cnpj_fornecedor,
          cd_numero_endereco: this.destinatario.cd_numero_endereco,
          nm_pix_vendedor: this.destinatario.cd_pix,
          cd_telefone: this.destinatario.cd_telefone,
          cd_cidade: this.destinatario.cidade.cd_cidade,
          cd_estado: this.destinatario.estado.cd_estado,
          ds_perfil_vendedor: this.destinatario.ds_destinatario,
          dt_nascimento_vendedor: formataData.formataDataSQL(
            this.destinatario.dt_cadastro_fornecedor
          ),
          cd_tipo_comissao: this.destinatario.comissao.cd_tipo_comissao,
          cd_departamento: this.destinatario.departamento.cd_departamento,
          cd_celular: this.destinatario.cd_celular,
          cd_parametro: 1,
          nm_bairro_vendedor: this.destinatario.nm_bairro,
          nm_complemento_endereco: this.destinatario.nm_complemento_endereco,
          nm_email_vendedor: this.destinatario.nm_email_destinatario,
          nm_endereco_vendedor: this.destinatario.nm_endereco_destinatario,
          nm_fantasia_vendedor: this.destinatario.nm_fantasia_destinatario,
          nm_vendedor: this.destinatario.nm_razao_social,
          sg_vendedor: this.destinatario.sg_fornecedor,
          cd_usuario: this.cd_usuario,
          cd_tipo_pessoa: this.destinatario.tipo_pessoa.cd_tipo_pessoa,
          cd_tipo_vendedor: this.destinatario.vendedor.cd_tipo_vendedor,
        };

        try {
          this.msgDinamica = "Enviando dados...";
          this.load = true;
          var envio = await Incluir.incluirRegistro(this.cd_api, v);
          this.destinatario.cd_vendedor = envio[0].cd_vendedor;
          notify(envio[0].Msg);
          this.load = false;
        } catch (error) {
          this.load = false;
          this.msgDinamica = "Aguarde...";
          notify("Impossivel cadastrar/alterar registro");
        }
      } else if (this.tab == 4) {
        let t = {
          cd_parametro: 1,
          cd_usuario: this.cd_usuario,
          cd_tipo_pesquisaID: this.tab,
          cd_cnpj_transportadora: this.destinatario.cd_cnpj_fornecedor,
          cd_tipo_pagamento_frete: this.destinatario.pagamento_frete
            .cd_tipo_pagamento_frete,
          cd_tipo_frete: this.destinatario.frete.cd_tipo_frete,
          nm_fantasia: this.destinatario.nm_fantasia_destinatario,
          nm_transportadora: this.destinatario.nm_razao_social,
          cd_telefone: this.destinatario.cd_telefone,
          cd_cep: this.destinatario.cd_cep,
          cd_estado: this.destinatario.estado.cd_estado,
          cd_cidade: this.destinatario.cidade.cd_cidade,
          nm_bairro: this.destinatario.nm_bairro,
          dt_cadastro: formataData.formataDataSQL(
            this.destinatario.dt_cadastro_fornecedor
          ),
          nm_endereco: this.destinatario.nm_endereco_destinatario,
          nm_endereco_complemento: this.destinatario.nm_complemento_endereco,
          cd_numero_endereco: this.destinatario.cd_numero_endereco,
          nm_email_transportadora: this.destinatario.nm_email_destinatario,
          ds_transportadora: this.destinatario.ds_destinatario,
          cd_tipo_mercado: this.destinatario.mercado.cd_tipo_mercado,
          cd_transportadora: this.destinatario.cd_transportadora,
          cd_tipo_pessoa: this.destinatario.tipo_pessoa.cd_tipo_pessoa,
          cd_tipo_transporte: this.destinatario.transporte.cd_tipo_transporte,
        };
        try {
          this.msgDinamica = "Enviando dados...";
          this.load = true;
          var envio = await Incluir.incluirRegistro(this.cd_api, t);
          this.destinatario.cd_transportadora = envio[0].cd_transportadora;
          notify(envio[0].Msg);
          this.load = false;
        } catch (error) {
          this.load = false;
          this.msgDinamica = "Aguarde...";
          notify("Impossivel cadastrar/alterar registro");
        }
      }

      this.tabChild = 0;
    },
    async SelectEstado() {
      var estado = this.lokup_estado.filter((e) => {
        return e.sg_estado == this.destinatario.estado.sg_estado;
      });
      this.destinatario.estado.cd_estado = estado[0].cd_estado;
      this.destinatario.estado.sg_estado = estado[0].sg_estado;
      this.FiltraCidade();
    },
    async FiltraCidade() {
      if (!!this.destinatario.estado.cd_estado == false) {
        this.lokup_cidade_filtrado = this.lokup_cidade;
        return;
      }

      this.lokup_cidade_filtrado = this.lokup_cidade.filter((e) => {
        return e.cd_estado == this.destinatario.estado.cd_estado;
      });

      if (!!this.lokup_cidade_filtrado == false) {
        this.lokup_cidade_filtrado = this.lokup_cidade;
      }
    },
    async SearchCNPJ() {
      if (!!this.destinatario.cd_cnpj_fornecedor == false) return;
      try {
        this.msgDinamica = "Buscando CNPJ";
        this.load = true;
        var retorno = await funcao.BuscaCNPJ(
          this.destinatario.cd_cnpj_fornecedor
        );
        if (retorno.data.status == "ERROR") {
          notify("CNPJ inválido");
          this.load = false;
          this.msgDinamica = "Aguarde....";

          return;
        } else if (retorno.status == 500) {
          this.load = false;
          this.msgDinamica = "Aguarde....";
          notify("Excesso de requisições, aguarde um minuto!");
          return;
        } else {
          retorno = retorno.data;
          this.destinatario.nm_fantasia_destinatario = retorno.fantasia;
          this.destinatario.nm_razao_social = retorno.nome;
          this.destinatario.cd_telefone = retorno.telefone;
          this.destinatario.dt_cadastro_fornecedor = retorno.abertura;
          this.destinatario.cd_cep = retorno.cep;
          this.destinatario.nm_complemento_endereco = retorno.complemento;
          this.destinatario.nm_bairro = retorno.bairro;
          this.destinatario.nm_email_destinatario = retorno.email;
          this.destinatario.nm_endereco_destinatario = retorno.logradouro;
          this.destinatario.cd_numero_endereco = retorno.numero;
          this.destinatario.estado.sg_estado = retorno.uf;
          this.destinatario.cidade.nm_cidade = retorno.municipio;
          this.destinatario.nm_situacao = retorno.situacao;
          await this.SelectEstado();
          //Filtra e busca a cidade/codigo que veio da api publica
          var cidade = this.lokup_cidade.filter((e) => {
            return (
              e.nm_cidade.toUpperCase().trim() ==
                retorno.municipio.toUpperCase().trim() &&
              e.cd_estado == this.destinatario.estado.cd_estado
            );
          });

          this.destinatario.cidade.cd_cidade = cidade[0].cd_cidade;
          this.destinatario.cidade.nm_cidade = cidade[0].nm_cidade.trim();
          this.load = false;
          this.msgDinamica = "Aguarde....";
        }
      } catch (error) {
        this.load = false;
      }
    },
    async carregaMenu() {
      try {
        this.menu = await Menu.montarMenu(
          this.cd_empresa,
          this.cd_menu,
          this.apiLocal
        );
        this.title = this.menu.nm_menu_titulo;
        this.cd_api = this.menu.nm_identificacao_api;
        //----------------------------------------------
        let tp = await Lookup.montarSelect(this.cd_empresa, 116);
        this.lokup_tipo_pessoa = JSON.parse(
          JSON.parse(JSON.stringify(tp.dataset))
        );
        //----------------------------------------------
        let tv = await Lookup.montarSelect(this.cd_empresa, 125);
        this.lokup_tipo_vendedor = JSON.parse(
          JSON.parse(JSON.stringify(tv.dataset))
        );
        //----------------------------------------------
        let e = await Lookup.montarSelect(this.cd_empresa, 96);
        this.lokup_estado = JSON.parse(JSON.parse(JSON.stringify(e.dataset)));
        //----------------------------------------------
        let c = await Lookup.montarSelect(this.cd_empresa, 97);
        this.lokup_cidade = JSON.parse(JSON.parse(JSON.stringify(c.dataset)));
        //----------------------------------------------
        let t = await Lookup.montarSelect(this.cd_empresa, 927);
        this.lookup_tipo_envio = JSON.parse(
          JSON.parse(JSON.stringify(t.dataset))
        );
        //----------------------------------------------
        let con = await Lookup.montarSelect(this.cd_empresa, 308);
        this.lookup_condicao_pagamento = JSON.parse(
          JSON.parse(JSON.stringify(con.dataset))
        );
        //----------------------------------------------
        let des = await Lookup.montarSelect(this.cd_empresa, 227);
        this.lookup_destinacao = JSON.parse(
          JSON.parse(JSON.stringify(des.dataset))
        );
        //----------------------------------------------
        let m = await Lookup.montarSelect(this.cd_empresa, 182);
        this.lookup_mercado = JSON.parse(JSON.parse(JSON.stringify(m.dataset)));
        //----------------------------------------------
        let tra = await Lookup.montarSelect(this.cd_empresa, 297);
        this.lookup_transportadora = JSON.parse(
          JSON.parse(JSON.stringify(tra.dataset))
        );
        //----------------------------------------------
        let a = await Lookup.montarSelect(this.cd_empresa, 315);
        this.lookup_aplicacao = JSON.parse(
          JSON.parse(JSON.stringify(a.dataset))
        );
        //----------------------------------------------
        let g = await Lookup.montarSelect(this.cd_empresa, 1096);
        this.lookup_grupo = JSON.parse(JSON.parse(JSON.stringify(g.dataset)));
        //----------------------------------------------
        let f = await Lookup.montarSelect(this.cd_empresa, 200);
        this.lokup_tipo_frete = JSON.parse(
          JSON.parse(JSON.stringify(f.dataset))
        );
      } catch (error) {}
      //----------------------------------------------
      let tc = await Lookup.montarSelect(this.cd_empresa, 893);
      this.lookup_tipo_comissao = JSON.parse(
        JSON.parse(JSON.stringify(tc.dataset))
      );
      //----------------------------------------------
      let de = await Lookup.montarSelect(this.cd_empresa, 726);
      this.lookup_departamento = JSON.parse(
        JSON.parse(JSON.stringify(de.dataset))
      );
      //----------------------------------------------
      let tip = await Lookup.montarSelect(this.cd_empresa, 140);
      this.lookup_tipo_transporte = JSON.parse(
        JSON.parse(JSON.stringify(tip.dataset))
      ); //----------------------------------------------
      let tf = await Lookup.montarSelect(this.cd_empresa, 242);
      this.lookup_tipo_pagamento_frete = JSON.parse(
        JSON.parse(JSON.stringify(tf.dataset))
      );
    },
  },
};
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}

/* Enter and leave animations can use different */
/* durations and timing functions.              */
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
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}
.borda {
  border-radius: 20px;
}
.metadeTela {
  width: 47.5%;
}

.umTercoTela {
  width: 31%;
}

.umQuartoTela {
  width: 22.5%;
}
.telaInteira {
  width: 100%;
}
#data-pop {
  flex-direction: none !important;
  width: 310px;
  overflow-x: hidden;
}
@media (max-width: 900px) {
  .metadeTela {
    width: 100%;
  }

  .umTercoTela {
    width: 100%;
  }

  .umQuartoTela {
    width: 100%;
  }
  #grid-cliente {
    max-height: 100vh;
  }
  .margin1 {
    margin: 1vh 1vw;
  }
}
</style>
