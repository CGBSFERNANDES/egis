<template>
  <div>
    <transition name="slide-fade">
      <div v-if="cd_proposta == 0" class="text-h5 text-bold margin1 ">
        {{ tituloMenu }}
      </div>
      <div v-else class="text-h5 text-bold margin1 ">
        {{ tituloMenu }} {{ " - " + cd_proposta }} - {{ hoje }}
      </div>
    </transition>

    <!--PROPOSTA--------------------------------------------------------------------------------->
    <div class="borda shadow-2 margin1">
      <div class="row margin1 text-h6">Proposta</div>

      <div class="row items-center justify-around">
        <transition name="slide-fade">
          <div
            class="margin1 umTercoTela text-center endereco"
            v-if="!!dt_consulta"
          >
            Data: {{ dt_consulta }}
          </div>
        </transition>

        <q-input
          class="margin1 umTercoTela"
          v-model="nm_cliente"
          type="text"
          label="Cliente"
          debounce="800"
          @input="PesquisaCliente(1)"
          :color="color"
          :loading="loadingCliente"
          :readonly="readyOnly"
        >
          <template v-slot:prepend>
            <q-icon name="person" />
          </template>
          <template v-slot:append>
            <q-btn
              @click="PesquisaCliente(1)"
              size="sm"
              round
              :color="color"
              icon="search"
            />
          </template>
        </q-input>

        <transition name="slide-fade">
          <q-select
            class="umTercoTela margin1"
            v-model="contato"
            label="Contato"
            :color="color"
            v-if="!!cd_cliente && ic_mostra_contatos"
            :options="contatos"
            option-value="cd_contato"
            option-label="nm_fantasia_contato"
            :stack-label="!!contato"
            :readonly="readyOnly"
            :loading="loadingContato"
          >
            <template v-slot:prepend>
              <q-icon name="format_list_bulleted" />
            </template>
          </q-select>
        </transition>
        <transition name="slide-fade">
          <div
            class="umTercoTela margin1 text-center"
            v-if="!!this.cd_cliente && ic_mostra_contatos == false"
          >
            <q-btn
              round
              color="negative"
              icon="refresh"
              v-if="alteraContato == false"
              size="sm"
              class="margin1"
              @click="alteraContato = true"
            />
            <q-btn
              round
              color="positive"
              icon="check"
              v-else
              size="sm"
              class="margin1"
              @click="
                alteraContato = false;
                PesquisaContato(1);
              "
            />
            Sem contatos Adicionados
          </div>
        </transition>
      </div>
      <div>
        <transition name="slide-fade">
          <contatoCliente
            v-if="!!this.cd_cliente && !!alteraContato"
            :cd_cliente_contato="this.cd_cliente"
            :pos_venda="0"
            :corID="color"
          >
          </contatoCliente>
        </transition>
      </div>
    </div>
    <div class="borda shadow-2 margin1">
      <div class="row items-center margin1 text-h6">Entrega</div>
      <div class="row items-center justify-around">
        <q-select
          class="umTercoTela margin1"
          v-model="tipo_pedido"
          label="Tipo de Pedido"
          :color="color"
          :options="dataset_tipo_pedido"
          option-value="cd_tipo_pedido"
          option-label="nm_tipo_pedido"
          :stack-label="!!tipo_pedido"
          :readonly="readyOnly"
        >
          <template v-slot:prepend>
            <q-icon name="format_list_bulleted" />
          </template>
        </q-select>
        <q-select
          class="umTercoTela margin1"
          v-model="forma_entrega"
          label="Forma de Entrega"
          :options="dataset_forma_entrega"
          option-value="cd_forma_entrega"
          option-label="nm_forma_entrega"
          :color="color"
          :stack-label="!!forma_entrega"
          :readonly="readyOnly"
        >
          <template v-slot:prepend>
            <q-icon name="airport_shuttle" />
          </template>
        </q-select>

        <q-select
          class="umTercoTela margin1"
          v-model="tipo_local_entrega"
          label="Local de Entrega"
          :color="color"
          :options="dataset_local_entrega"
          option-value="cd_tipo_local_entrega"
          option-label="nm_tipo_local_entrega"
          :stack-label="!!tipo_local_entrega"
          :readonly="readyOnly"
        >
          <template v-slot:prepend>
            <q-icon name="other_houses" />
          </template>
        </q-select>
      </div>
      <div class="row items-center justify-around">
        <q-checkbox
          class="umTercoTela margin1"
          :disable="readyOnly"
          :color="color"
          v-model="ic_email_consulta"
          label="Gera E-mail Confirmação Pedido"
        />
        <q-checkbox
          class="umTercoTela margin1"
          v-model="ic_fechamento_total"
          :color="color"
          :disable="readyOnly"
          label="Fechamento Total"
        />
        <q-checkbox
          class="umTercoTela margin1"
          v-model="ic_outro_cliente"
          :color="color"
          :disable="readyOnly"
          label="Entrega Outro Cliente"
        />
      </div>

      <div class="row items-center justify-around">
        <transition name="slide-fade">
          <q-input
            v-show="ic_outro_cliente"
            class="margin1 metadeTela"
            v-model="nm_cliente_entrega"
            type="text"
            debounce="800"
            @input="PesquisaCliente(3)"
            label="Cliente (Entrega)"
            :color="color"
            :readonly="readyOnly"
            :loading="loadingClienteEntrega"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
            <template v-slot:append>
              <q-btn
                @click="PesquisaCliente(3)"
                size="sm"
                round
                :color="color"
                icon="search"
              />
            </template>
          </q-input>
        </transition>
        <transition name="slide-fade">
          <div
            class="margin1 metadeTela text-center endereco"
            v-if="ic_outro_cliente && !!this.nm_endereco_entrega == true"
          >
            Endereço de Entrega: {{ nm_endereco_entrega }}
          </div>
        </transition>
      </div>
    </div>
    <transition name="slide-fade">
      <div class="borda shadow-2 margin1" v-show="ic_fechamento_total == false">
        <div class="row items-center margin1 text-h6">Items</div>

        <DxDataGrid
          class="margin1"
          id="grid"
          :data-source="itens"
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
          @selection-Changed="TrocaLinhaItens"
        >
          <DxSelection mode="single" />

          <DxColumn
            v-for="(v, index) in colunaItens"
            :key="index"
            :alignment="v.alignment"
            :caption="v.caption"
            :dataField="v.dataField"
            :dataType="v.dataType"
          />
          <DxSelection mode="multiple" />
        </DxDataGrid>
      </div>
    </transition>
    <div class="borda shadow-2 margin1">
      <div class="row items-center margin1 text-h6">Fatura</div>
      <div class="row items-center ">
        <q-checkbox
          class="umTercoTela margin1"
          v-model="ic_operacao_triangular"
          :color="color"
          :disable="readyOnly"
          label="Operação Triangular"
        />
      </div>
      <div class="row items-center justify-around">
        <q-select
          class="umTercoTela margin1"
          v-model="tipo_restricao_pedido"
          label="Restrição de Faturamento"
          :color="color"
          :readonly="readyOnly"
          :options="dataset_tipo_restricao_pedido"
          option-value="cd_tipo_restricao_pedido"
          option-label="nm_tipo_restricao_pedido"
          :stack-label="!!tipo_restricao_pedido"
        >
          <template v-slot:prepend>
            <q-icon name="lock" />
          </template>
        </q-select>
        <transition name="slide-fade">
          <q-input
            class="margin1 umTercoTela"
            v-model="nm_cliente_faturamento"
            type="text"
            v-show="!!ic_operacao_triangular"
            :readonly="readyOnly"
            @input="PesquisaCliente(2)"
            debounce="800"
            label="Cliente (Faturamento)"
            :color="color"
            :loading="loadingClienteFaturamento"
          >
            <template v-slot:prepend>
              <q-icon name="paid" />
            </template>
            <template v-slot:append>
              <q-btn
                @click="PesquisaCliente(2)"
                size="sm"
                round
                :color="color"
                icon="search"
              />
            </template>
          </q-input>
        </transition>
        <transition name="slide-fade">
          <q-select
            v-if="ic_contato_vazio == false && !!this.cd_cliente_fatura"
            class="umTercoTela margin1"
            v-model="contato_faturamento"
            label="Contato (Faturamento)"
            :color="color"
            :readonly="readyOnly"
            :options="contatosFaturamento"
            option-value="cd_contato"
            option-label="nm_fantasia_contato"
            :stack-label="!!tipo_restricao_pedido"
            :loading="loadingContatoFaturamento"
          >
            <template v-slot:prepend>
              <q-icon name="lock" />
            </template>
          </q-select>
        </transition>
        <transition name="slide-fade">
          <div
            class="umTercoTela margin1 text-center"
            v-if="ic_contato_vazio == true && !!this.cd_cliente_fatura"
          >
            <q-btn
              round
              color="negative"
              icon="refresh"
              v-if="alteraContatoFatura == false"
              size="sm"
              class="margin1"
              @click="alteraContatoFatura = true"
            />
            <q-btn
              round
              color="positive"
              icon="check"
              v-else
              size="sm"
              class="margin1"
              @click="
                alteraContatoFatura = false;
                PesquisaContato(2);
              "
            />
            Sem contatos Adicionados
          </div>
        </transition>
      </div>
      <transition name="slide-fade">
        <contato
          v-if="!!this.cd_cliente_fatura && !!alteraContatoFatura"
          :cd_cliente_contato="this.cd_cliente_fatura"
          :pos_venda="0"
          :corID="color"
        >
        </contato>
      </transition>
    </div>
    <div class="borda shadow-2 margin1">
      <div class="row items-center margin1 text-h6">Vendedor</div>
      <div class="row items-center justify-around">
        <q-select
          class="metadeTela margin1"
          v-model="vendedor_interno"
          :readonly="readyOnly"
          label="Interno"
          :color="color"
          :options="lookup_vendedor_interno"
          option-value="cd_vendedor"
          option-label="nm_vendedor"
          :stack-label="!!vendedor_interno"
        >
          <template v-slot:prepend>
            <q-icon name="lock" />
          </template>
        </q-select>
        <q-select
          class="metadeTela margin1"
          v-model="vendedor_externo"
          :readonly="readyOnly"
          label="Externo"
          :color="color"
          :options="lookup_vendedor_externo"
          option-value="cd_vendedor"
          option-label="nm_vendedor"
          :stack-label="!!vendedor_externo"
        >
          <template v-slot:prepend>
            <q-icon name="lock" />
          </template>
        </q-select>
      </div>
    </div>
    <div class="borda shadow-2 margin1">
      <div class="row items-center margin1 text-h6">Transportadora</div>
      <div class="row items-center justify-around">
        <q-select
          class="telaInteira margin1"
          v-model="transportadora"
          label="Transportadora"
          :color="color"
          :options="dataset_lookup_transportadora"
          :readonly="readyOnly"
          option-value="cd_transportadora"
          option-label="nm_transportadora"
          :stack-label="!!transportadora"
        >
          <template v-slot:prepend>
            <q-icon name="lock" />
          </template>
        </q-select>
      </div>
    </div>
    <div class="borda shadow-2 margin1">
      <div class="row items-center margin1 text-h6">Fechamento</div>
      <div class="row items-center justify-around">
        <q-select
          class="umQuartoTela margin1"
          v-model="pagamento"
          label="Condição de Pagamento"
          :color="color"
          :readonly="readyOnly"
          :options="dataset_lookup_pagamento"
          option-value="cd_condicao_pagamento"
          option-label="nm_condicao_pagamento"
          :stack-label="!!pagamento"
        >
          <template v-slot:prepend>
            <q-icon name="lock" />
          </template>
        </q-select>
        <q-select
          class="umQuartoTela margin1"
          v-model="tipo_frete"
          label="Tipo de Frete"
          :readonly="readyOnly"
          :color="color"
          :options="dataset_lookup_tipo_frete"
          option-value="cd_tipo_pagamento_frete"
          option-label="nm_tipo_pagamento_frete"
          :stack-label="!!tipo_frete"
        >
          <template v-slot:prepend>
            <q-icon name="lock" />
          </template>
        </q-select>
        <q-input
          class="margin1 umQuartoTela"
          v-model="dt_fechamento_consulta"
          type="text"
          :color="color"
          label="Data do Fechamento"
          :loading="loading"
          :readonly="readyOnly"
          mask="##/##/####"
        >
          <template v-slot:prepend>
            <q-icon name="event" />
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
                ref="qDateProxy"
                cover
                transition-show="scale"
                transition-hide="scale"
              >
                <q-date
                  :color="color"
                  mask="DD/MM/YYYY"
                  v-model="dt_fechamento_consulta"
                  class="qdate"
                />
              </q-popup-proxy>
            </q-btn>
          </template>
        </q-input>
        <q-select
          class="umQuartoTela margin1"
          v-model="destinacao"
          label="Destinação (Cálculo Imposto Nota)"
          :color="color"
          :readonly="readyOnly"
          :options="dataset_lookup_destinacao"
          option-value="cd_destinacao_produto"
          option-label="nm_destinacao_produto"
          :stack-label="!!destinacao"
        >
          <template v-slot:prepend>
            <q-icon name="lock" />
          </template>
        </q-select>
      </div>
      <div class="row items-center justify-around">
        <q-input
          class="margin1 metadeTela"
          v-model="cd_pedido_compra_consulta"
          type="text"
          :color="color"
          label="Pedido do Cliente"
          :loading="loading"
          :readonly="readyOnly"
        >
          <template v-slot:prepend>
            <q-icon name="event" />
          </template>
        </q-input>

        <q-select
          class="metadeTela margin1"
          v-model="forma_pagamento"
          :readonly="readyOnly"
          label="Forma de Pagamento"
          :color="color"
          :options="dataset_lookup_forma_pagamento"
          option-value="cd_forma_pagamento"
          option-label="nm_forma_pagamento"
          :stack-label="!!destinacao"
        >
          <template v-slot:prepend>
            <q-icon name="lock" />
          </template>
        </q-select>
      </div>
      <div class="row items-center justify-around">
        <q-checkbox
          class="umTercoTela margin1"
          :color="color"
          :disable="readyOnly"
          v-model="ic_email_confirmacao"
          label="Gera e-mail Fechamento"
        />
        <q-checkbox
          class="umTercoTela margin1"
          :color="color"
          :disable="readyOnly"
          v-model="ic_obs_corpo_nf"
          label="Grava observação abaixo no corpo da nota fiscal"
        />
      </div>
      <div class="row items-center justify-around">
        <transition name="slide-fade">
          <q-input
            class="margin1 telaInteira"
            v-model="ds_obs_fat_consulta"
            type="text"
            :readonly="readyOnly"
            :color="color"
            v-show="!!ic_obs_corpo_nf"
            label="Obs. para faturamento Corpo da Nota"
            :loading="loading"
            autogrow
          >
            <template v-slot:prepend>
              <q-icon name="event" />
            </template>
          </q-input>
        </transition>
      </div>
    </div>

    <div class="row items-center ">
      <q-btn
        color="orange-9"
        rounded
        class="margin1"
        icon="check"
        label="Gravar"
        :loading="load_gravar"
        @click="FechaProposta()"
      >
        <q-tooltip>
          Salvar Proposta
        </q-tooltip>
      </q-btn>
      <q-space />
      <q-btn
        flat
        color="orange-9"
        rounded
        v-close-popup
        class="margin1"
        icon="close"
        label="Cancelar"
      >
        <q-tooltip>
          Cancelar
        </q-tooltip>
      </q-btn>
    </div>
    <!------------------POPUP de cliente--------------------------->
    <q-dialog v-model="popupCliente" full-width persistent>
      <q-card>
        <q-card-section class="row items-center margin1">
          <div class="text-h6">Selecione o Cliente</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <DxDataGrid
          class="margin1"
          id="grid"
          :data-source="clientes"
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
          @selection-Changed="TrocaLinha"
        >
          <DxSelection mode="single" />

          <DxColumn
            v-for="(v, index) in colunaPesquisa"
            :key="index"
            :alignment="v.alignment"
            :caption="v.caption"
            :dataField="v.dataField"
            :dataType="v.dataType"
          />
        </DxDataGrid>

        <div class="row items-center">
          <q-btn
            rounded
            class="margin1"
            label="Selecionar"
            color="orange-9"
            v-close-popup
            icon="done"
            @click="SelecionaCliente(1)"
          />
        </div>
      </q-card>
    </q-dialog>
    <!------------------POPUP de cliente Faturamento--------------------------->
    <q-dialog v-model="popupClienteFaturamento" full-width persistent>
      <q-card>
        <q-card-section class="row items-center margin1">
          <div class="text-h6">Selecione o Cliente (Faturamento)</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <DxDataGrid
          class="margin1"
          id="grid"
          :data-source="clientes"
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
          @selection-Changed="TrocaLinhaFaturamento"
        >
          <DxSelection mode="single" />

          <DxColumn
            v-for="(v, index) in colunaPesquisa"
            :key="index"
            :alignment="v.alignment"
            :caption="v.caption"
            :dataField="v.dataField"
            :dataType="v.dataType"
          />
        </DxDataGrid>

        <div class="row items-center">
          <q-btn
            rounded
            class="margin1"
            label="Selecionar"
            color="orange-9"
            v-close-popup
            icon="done"
            @click="SelecionaClienteFaturamento()"
          />
        </div>
      </q-card>
    </q-dialog>
    <!------------------POPUP de cliente Entrega--------------------------->
    <q-dialog v-model="popupClienteEntrega" full-width persistent>
      <q-card>
        <q-card-section class="row items-center margin1">
          <div class="text-h6">Selecione o Cliente de Entrega</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <DxDataGrid
          class="margin1"
          id="grid"
          :data-source="clientes"
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
          @selection-Changed="TrocaLinhaEntrega"
        >
          <DxSelection mode="single" />

          <DxColumn
            v-for="(v, index) in colunaPesquisa"
            :key="index"
            :alignment="v.alignment"
            :caption="v.caption"
            :dataField="v.dataField"
            :dataType="v.dataType"
          />
        </DxDataGrid>

        <div class="row items-center">
          <q-btn
            rounded
            class="margin1"
            label="Selecionar"
            color="orange-9"
            v-close-popup
            icon="done"
            @click="SelecionaClienteEntrega()"
          />
        </div>
      </q-card>
    </q-dialog>

    <!---CARREGANDO----------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando :corID="'orange-9'"></carregando>
    </q-dialog>
    <!--  -->
  </div>
</template>
<script>
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import Menu from "../http/menu";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import Lookup from "../http/lookup";
import formataData from "../http/formataData";
import funcao from "../http/funcoes-padroes";

import {
  DxDataGrid,
  DxColumn,
  DxSearchPanel,
  DxSelection,
} from "devextreme-vue/data-grid";

export default {
  props: {
    cd_consulta: {
      type: Number,
      default: 0,
    },
  },
  emits: ["FechaProposta"],

  components: {
    contato: () => import("../views/contato.vue"),
    contatoCliente: () => import("../views/contato.vue"),
    DxDataGrid,
    DxSearchPanel,
    DxSelection,
    DxSearchPanel,
    DxColumn,
    parcial: () => import("../components/fechamentoParcial.vue"),
    carregando: () => import("../components/carregando.vue"),
    gridCliente: () => import("../views/grid.vue"),
  },

  data() {
    return {
      tituloMenu: "",
      dt_consulta: "",
      nm_cliente: "",
      nm_contato: "",
      readyOnly: false,
      dataset_forma_entrega: [],
      forma_entrega: "",
      dataset_local_entrega: [],
      tipo_local_entrega: "",
      ic_email_consulta: false,
      ic_outro_cliente: false,
      ic_fechamento_total: true,
      color: "orange-9",
      nm_cliente_entrega: "",
      cd_cliente_entrega: 0,
      nm_endereco_entrega: "",
      tipo_restricao_pedido: "",
      dataset_tipo_restricao_pedido: [],
      ic_operacao_triangular: false,
      nm_cliente_faturamento: "",
      cd_cliente_fatura: 0,
      nm_contato_faturamento: "",
      vendedor_interno: "",
      cd_pedido_compra_consulta: "Verbal",
      dataset_condicao_pagamento: [],
      cd_item_pedido_compra_consulta: 0,
      ic_email_confirmacao: false,
      ic_obs_corpo_nf: false,
      ds_obs_fat_consulta: "",
      dt_fechamento_consulta: "",
      loadingCliente: false,
      forma_pagamento: "",
      popupCliente: false,
      clientes: [],
      linha: {},
      cd_cliente: 0,
      contato: "",
      contatos: [],
      loadingClienteFaturamento: false,
      loadingContatoFaturamento: false,
      popupClienteFaturamento: false,
      loadingContato: false,
      contato_faturamento: "",
      contatosFaturamento: [],
      ic_contato_vazio: true,
      loadingClienteEntrega: false,
      ic_mostra_contatos: false,
      popupClienteEntrega: false,
      linhaEntrega: {},
      nm_endereco_entrega: "",
      itens: [],
      linhaItens: [],
      alteraContato: false,
      alteraContatoFatura: false,
      colunaItens: [
        {
          alignment: "center",
          caption: "Código",
          dataField: "Código",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Item",
          dataField: "cd_item_pedido_venda",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Descricao",
          dataField: "Descricao",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Disponivel",
          dataField: "Disponivel",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Fantasia",
          dataField: "Fantasia",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Produto",
          dataField: "Produto",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Quantidade",
          dataField: "Quantidade",
          dataType: "text",
        },
      ],

      colunaPesquisa: [
        {
          alignment: "center",
          caption: "CNPJ",
          dataField: "CNPJ",
          dataType: "text",
        },

        {
          alignment: "center",
          caption: "Razão Social",
          dataField: "Razao_Social",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Fantasia",
          dataField: "Fantasia",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Tipo Pessoa",
          dataField: "Tipo_Pessoa",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Status",
          dataField: "Status_Cliente",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "E-mail",
          dataField: "Email",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Domínio",
          dataField: "nm_dominio_cliente",
          dataType: "text",
        },

        {
          alignment: "center",
          caption: "CEP",
          dataField: "CEP",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Estado",
          dataField: "Estado",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Cidade",
          dataField: "Cidade",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Bairro",
          dataField: "Bairro",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Endereço",
          dataField: "Endereco",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Complemento",
          dataField: "Complemento",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Número",
          dataField: "Numero",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Tipo Local Entrega",
          dataField: "nm_tipo_local_entrega",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Transportadora",
          dataField: "Transportadora",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Tipo Pagamento",
          dataField: "Tipo_Pagamento",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Tipo Pagamento Frete",
          dataField: "Tipo_Pagamento_Frete",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Forma Pagamento",
          dataField: "Forma_Pagamento",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Condição Pagamento",
          dataField: "Condicao_Pagamento",
          dataType: "text",
        },
        {
          alignment: "center",
          caption: "Ramo Atividade",
          dataField: "Ramo_Atividade",
          dataType: "text",
        },
      ],

      //-------------
      api: "562/781", // Procedimento 1439 - pr_egisnet_elabora_proposta
      nm_json: {}, // JSON Enviado para a API
      colunas: [],
      cd_usuario: localStorage.cd_usuario,
      cd_vendedor: 0,
      hoje: "",
      cd_empresa: localStorage.cd_empresa,
      load: false,
      cd_proposta: "",
      Fantasia: "",
      lookup_vendedor_interno: [],
      lookup_vendedor_externo: [],
      vendedor_externo: "",
      dataset_lookup_pagamento: [],
      dataset_lookup_forma_pagamento: [],
      pagamento: "",
      dataset_tipo_pedido: [],
      tipo_pedido: "",
      categoria: "",
      grupo: "",
      marca: "",
      dados_lookup_cliente: [],
      dataset_lookup_cliente: [],
      cliente: "",
      dataset_lookup_vendedor: [],
      vendedor: "",
      dataset_lookup_transportadora: [],
      transportadora: "",
      dataset_lookup_tipo_entrega: [],
      tipo_entrega: "",
      dataset_lookup_destinacao: [],
      destinacao: "",
      dataset_lookup_tipo_endereco: [],
      tipo_endereco: "",
      dataset_lookup_tipo_frete: [],
      tipo_frete: "",
      frete_pagamento: "",
      dataset_lookup_um: [],
      um: "",
      selecao: false,
      Razao_Social: "",
      Telefone_Empresa: "",
      CNPJ: "",
      nm_dominio_cliente: "",
      Tipo_Pessoa: "",
      Ramo_Atividade: "",
      Status_Cliente: "",
      Insc_Estadual: "",
      Insc_Municipal: "",
      CEP: "",
      Endereco: "",
      Numero: "",
      Complemento: "",
      Bairro: "",
      Cidade: "",
      Estado: "",
      obs: "",
      loading: false,
      load_gravar: false,
      total_banco: "",
      Email: "",
      produtos: [],
      total: {},
      carrinho: [],
      valorTotal: 0,
      IPI: "0",
      ICMS: "0",
      colunaGrid: [],
      totalGrid: {},
      gridProposta: [],
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    try {
      this.load = true;
      this.cd_vendedor = await funcao.buscaVendedor(this.cd_usuario);
      this.dt_fechamento_consulta = funcao.DataHoje();
      const dados_lookup_pedido = await Lookup.montarSelect(
        this.cd_empresa,
        202
      );
      this.dataset_tipo_pedido = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_pedido.dataset))
      );

      const dados_restricao = await Lookup.montarSelect(this.cd_empresa, 273);
      this.dataset_tipo_restricao_pedido = JSON.parse(
        JSON.parse(JSON.stringify(dados_restricao.dataset))
      );
      const dados_lookup_tipo_frete = await Lookup.montarSelect(
        this.cd_empresa,
        242
      );
      this.dataset_lookup_tipo_frete = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_tipo_frete.dataset))
      );
      const dados_condicao = await Lookup.montarSelect(this.cd_empresa, 308);
      this.dataset_condicao_pagamento = JSON.parse(
        JSON.parse(JSON.stringify(dados_condicao.dataset))
      );

      const dados_lookup_destinacao = await Lookup.montarSelect(
        this.cd_empresa,
        227
      );
      this.dataset_lookup_destinacao = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_destinacao.dataset))
      );
      const dados_forma_pagamento = await Lookup.montarSelect(
        this.cd_empresa,
        2774
      );
      this.dataset_lookup_forma_pagamento = JSON.parse(
        JSON.parse(JSON.stringify(dados_forma_pagamento.dataset))
      );
      const dados_lookup_pagamento = await Lookup.montarSelect(
        this.cd_empresa,
        308
      );
      this.dataset_lookup_pagamento = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_pagamento.dataset))
      );
      const dados_lookup_vendedor = await Lookup.montarSelect(
        this.cd_empresa,
        141
      );
      this.dataset_lookup_vendedor = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_vendedor.dataset))
      );

      const dados_lookup_transportadora = await Lookup.montarSelect(
        this.cd_empresa,
        297
      );
      this.dataset_lookup_transportadora = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_transportadora.dataset))
      );
      const dados_lookup_tipo_entrega = await Lookup.montarSelect(
        this.cd_empresa,
        397
      );
      this.dataset_lookup_tipo_entrega = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_tipo_entrega.dataset))
      );
      let da = await Lookup.montarSelect(this.cd_empresa, 510);
      this.dataset_forma_entrega = JSON.parse(
        JSON.parse(JSON.stringify(da.dataset))
      );
      const find = this.dataset_forma_entrega.find((e) => {
        return e.ic_pad_forma_entrega == "S";
      });
      if (!!find) {
        this.forma_entrega = find;
      }
      //---------------------------------------------------------------------

      this.dados_lookup_cliente = await Lookup.montarSelect(
        this.cd_empresa,
        93
      );
      this.dataset_lookup_cliente = JSON.parse(
        JSON.parse(JSON.stringify(this.dados_lookup_cliente.dataset))
      );
      const dados_lookup_tipo_local_entrega = await Lookup.montarSelect(
        this.cd_empresa,
        250 //Tipo_Local_Entrega
      );
      this.dataset_local_entrega = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_tipo_local_entrega.dataset))
      );

      const dados_lookup_um = await Lookup.montarSelect(this.cd_empresa, 138);
      this.dataset_lookup_um = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_um.dataset))
      );

      this.lookup_vendedor_interno = this.dataset_lookup_vendedor.filter(
        (interno) => {
          return interno.cd_tipo_vendedor == 1;
        }
      );

      this.lookup_vendedor_externo = this.dataset_lookup_vendedor.filter(
        (externo) => {
          return externo.cd_tipo_vendedor == 2;
        }
      );
      if (!!this.cd_consulta == true) {
        const c = {
          cd_parametro: 6,
          cd_consulta: this.cd_consulta,
        };

        const capa = await Incluir.incluirRegistro(this.api, c);
        this.itens = capa;
        this.cd_cliente = capa[0].cd_cliente;

        this.destinacao = {
          cd_destinacao_produto: capa[0].cd_destinacao_produto,
          nm_destinacao_produto: capa[0].nm_destinacao_produto,
        };
        this.dt_consulta = capa[0].dt_consulta_formatado;
        this.nm_cliente = capa[0].nm_fantasia_cliente;
        //this.nm_contato = capa[0].nm_fantasia_contato;
        this.tipo_pedido = {
          cd_tipo_pedido: capa[0].cd_tipo_pedido,
          nm_tipo_pedido: capa[0].nm_tipo_pedido,
        };
        this.forma_entrega = {
          cd_forma_entrega: capa[0].cd_forma_entrega,
          nm_forma_entrega: capa[0].nm_forma_entrega,
        };

        this.tipo_local_entrega = {
          cd_tipo_local_entrega: capa[0].cd_tipo_local_entrega,
          nm_tipo_local_entrega: capa[0].nm_tipo_local_entrega,
        };
        this.nm_cliente_entrega = ""; //Busca cliente e salva o cd_cliente_entrega
        this.cd_cliente_entrega = 0;

        this.cd_cliente_fatura = capa[0].cd_cliente_fatura;
        this.nm_cliente_faturamento = capa[0].nm_fantasia_cliente_faturamento;
        this.ds_obs_fat_consulta = capa[0].ds_obs_fat_consulta;
        this.tipo_restricao_pedido = {
          cd_tipo_restricao_pedido: capa[0].cd_tipo_restricao_pedido,
          nm_tipo_restricao_pedido: capa[0].nm_tipo_restricao_pedido,
        };
        if (capa[0].ic_operacao_triangular == "S") {
          this.ic_operacao_triangular = true;
        }
        if (capa[0].ic_email_consulta == "S") {
          this.ic_email_consulta = true;
        }
        if (capa[0].ic_fechamento_total == "S") {
          this.ic_fechamento_total = true;
        }
        if (capa[0].ic_outro_cliente == "S") {
          this.ic_outro_cliente = true;
        }
        if (capa[0].ic_obs_corpo_nf == "S") {
          this.ic_obs_corpo_nf = true;
        }

        this.tipo_frete = {
          cd_tipo_pagamento_frete: capa[0].cd_tipo_pagamento_frete,
          nm_tipo_pagamento_frete: capa[0].nm_tipo_pagamento_frete,
        };

        this.pagamento = {
          cd_condicao_pagamento: capa[0].cd_condicao_pagamento,
          nm_condicao_pagamento: capa[0].nm_condicao_pagamento,
        };

        this.transportadora = {
          cd_transportadora: capa[0].cd_transportadora,
          nm_transportadora: capa[0].nm_transportadora,
        };

        this.vendedor_interno = {
          cd_vendedor: capa[0].cd_vendedor,
          nm_vendedor: capa[0].nm_vendedor,
        };

        this.vendedor_externo = {
          cd_vendedor: capa[0].cd_vendedor_externo,
          nm_vendedor: capa[0].nm_vendedor_externo,
        };
        if (!!capa[0].dt_fechamento_consulta) {
          this.dt_fechamento_consulta = capa[0].dt_fechamento_consulta;
        }

        this.cd_cliente_fatura = capa[0].cd_cliente_faturamento;
        this.nm_cliente_faturamento = capa[0].nm_fantasia_cliente_faturamento;
        this.cd_cliente__entrega = capa[0].cd_cliente_entrega;
        this.nm_cliente_entrega = capa[0].nm_fantasia_cliente_entrega;
        this.cd_pedido_compra_consulta = capa[0].cd_pedido_compra_consulta;
        this.cd_item_pedido_compra_consulta =
          capa[0].cd_item_pedido_compra_consulta;
        this.forma_pagamento = {
          cd_forma_pagamento: capa[0].cd_forma_pagamento,
          nm_forma_pagamento: capa[0].nm_forma_pagamento,
        };
      }
      var PegaData = new Date();
      var dia = String(PegaData.getDate()).padStart(2, "0");
      var mes = String(PegaData.getMonth() + 1).padStart(2, "0");
      var ano = PegaData.getFullYear();
      this.hoje = `${dia}/${mes}/${ano}`;
      this.load = false;

      this.contato = {
        cd_contato: capa[0].cd_contato,
        nm_fantasia_contato: capa[0].nm_fantasia_contato,
      };
    } catch (error) {
      this.load = false;
    }
  },

  async mounted() {
    !!this.cd_consulta == false
      ? (this.tituloMenu = "Fechamento de Proposta")
      : (this.tituloMenu = "Fechamento de Proposta - " + this.cd_consulta);
    //this.tituloMenu = "Fechamento de Proposta - " = this.cd_consulta;
    if (!!this.dt_fechamento_consulta == true) {
      this.readyOnly = false;
    } else {
      this.readonly = true;
    }

    //await this.grid_carrinho.saveEditData();
  },
  watch: {
    async contatos() {
      if (this.contatos.length > 0) {
        this.ic_mostra_contatos = true;
      } else {
        this.ic_mostra_contatos = false;
      }
    },
    async cd_cliente() {
      if (!!this.cd_cliente) {
        await this.PesquisaContato(1);
      }
    },
    async cd_cliente_fatura() {
      if (!!this.cd_cliente_fatura) {
        await this.PesquisaContato(2);
      }
    },
    async cd_cliente_entrega() {
      if (!!this.cd_cliente_entrega) {
        await this.PesquisaContato(3);
      }
    },
  },

  methods: {
    async AtualizaItens() {
      for (let j = 0; j < this.linhaItens.length; j++) {
        const item = {
          cd_parametro: 19,
          cd_consulta: this.cd_consulta,
          cd_item_consulta: this.linhaItens[j].cd_item_consulta,
        };
        const post = await Incluir.incluirRegistro(this.api, item);
        notify(post[0].Msg);
      }
    },
    async SelecionaClienteEntrega() {
      this.cd_cliente_entrega = this.linhaEntrega.cd_cliente;
      this.nm_cliente_entrega = this.linhaEntrega.Fantasia;
      this.nm_endereco_entrega =
        this.linhaEntrega.Endereco +
        " - " +
        this.linhaEntrega.Numero +
        " - " +
        this.linhaEntrega.Bairro +
        " - " +
        this.linhaEntrega.Cidade +
        "/" +
        this.linhaEntrega.Estado;

      //await this.PesquisaContato(3);
    },
    async SelecionaClienteFaturamento() {
      this.cd_cliente_fatura = this.linhaFaturamento.cd_cliente;
      this.nm_cliente_faturamento = this.linhaFaturamento.Fantasia;
      await this.PesquisaContato(2);
    },
    async FechaProposta() {
      if (!!this.cd_consulta == false) {
        let not = {
          message: "Proposta não encontrada!",
          type: "error",
        };
        notify(not);
        return;
      }
      if (!!this.dt_consulta == false) {
        let not = {
          message: "Digite a data da proposta!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.cd_cliente == false) {
        let not = {
          message: "Indique o Cliente!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.contato.cd_contato == false) {
        let not = {
          message: "Indique o Contato do Cliente",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.tipo_pedido.cd_tipo_pedido == false) {
        let not = {
          message: "Indique o tipo de pedido!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.forma_entrega.cd_forma_entrega == false) {
        let not = {
          message: "Indique a forma de entrega!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.tipo_local_entrega.cd_tipo_local_entrega == false) {
        let not = {
          message: "Indique o tipo de local de entrega!",
          type: "error",
        };
        notify(not);
        return;
      } else if (
        this.ic_outro_cliente == true &&
        !!this.cd_cliente_entrega == false
      ) {
        let not = {
          message: "Indique o cliente de entrega!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.ic_operacao_triangular == true) {
        if (!!this.cd_cliente_fatura == false) {
          let not = {
            message: "Indique o cliente de faturamento!",
            type: "error",
          };
          notify(not);
          return;
        }
        if (!!this.contato_faturamento.cd_contato == false) {
          let not = {
            message: "Indique o contato de faturamento!",
            type: "error",
          };
          notify(not);
          return;
        }
      } else if (!!this.transportadora.cd_transportadora == false) {
        let not = {
          message: "Indique a transportadora!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.pagamento.cd_condicao_pagamento == false) {
        let not = {
          message: "Indique a condição de pagamento!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.tipo_frete.cd_tipo_pagamento_frete == false) {
        let not = {
          message: "Indique o tipo de frete!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.dt_fechamento_consulta == false) {
        let not = {
          message: "Indique a data de fechamento!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.destinacao.cd_destinacao_produto == false) {
        let not = {
          message: "Indique a destinação do produto!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.forma_pagamento.cd_forma_pagamento == false) {
        let not = {
          message: "Indique a forma de pagamento!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.vendedor_externo.cd_vendedor == false) {
        let not = {
          message: "Indique o vendedor externo!",
          type: "error",
        };
        notify(not);
        return;
      } else if (!!this.vendedor_interno.cd_vendedor == false) {
        let not = {
          message: "Indique o vendedor interno!",
          type: "error",
        };
        notify(not);
        return;
      }

      if (this.ic_fechamento_total == false) {
        await this.AtualizaItens();
      }

      let ic_email_consulta = "N";
      let ic_fechamento_total = "N";
      let ic_outro_cliente = "N";
      let ic_operacao_triangular = "N";
      let ic_email_confirmacao = "N";
      let ic_obs_corpo_nf = "N";

      this.ic_fechamento_total == true
        ? (ic_fechamento_total = "S")
        : (ic_fechamento_total = "N");

      this.ic_email_consulta == true
        ? (ic_email_consulta = "S")
        : (ic_email_consulta = "N");

      this.ic_outro_cliente == true
        ? (ic_outro_cliente = "S")
        : (ic_outro_cliente = "N");

      this.ic_operacao_triangular == true
        ? (ic_operacao_triangular = "S")
        : (ic_operacao_triangular = "N");

      this.ic_email_confirmacao == true
        ? (ic_email_confirmacao = "S")
        : (ic_email_confirmacao = "N");

      this.ic_obs_corpo_nf == true
        ? (ic_obs_corpo_nf = "S")
        : (ic_obs_corpo_nf = "N");

      let proposta = {
        cd_consulta: this.cd_consulta,
        dt_fechamento_consulta: formataData.formataDataSQL(
          this.dt_fechamento_consulta
        ),
        cd_cliente: this.cd_cliente,
        cd_usuario: this.cd_usuario,
        cd_contato: this.contato.cd_contato,
        cd_tipo_pedido: this.tipo_pedido.cd_tipo_pedido,
        cd_tipo_entrega_produto: this.forma_entrega.cd_forma_entrega,
        cd_tipo_local_entrega: this.tipo_local_entrega.cd_tipo_local_entrega,
        ic_email_consulta: ic_email_consulta,
        ic_fechamento_total: ic_fechamento_total,
        ic_outro_cliente: ic_outro_cliente,
        ic_operacao_triangular: ic_operacao_triangular,
        cd_tipo_restricao_pedido: this.tipo_restricao_pedido
          .cd_tipo_restricao_pedido,
        cd_cliente_fatura: this.cd_cliente_fatura,
        cd_contato_faturamento: this.contato_faturamento.cd_contato,
        cd_vendedor_interno: this.vendedor_interno.cd_vendedor,
        cd_vendedor_externo: this.vendedor_externo.cd_vendedor,
        cd_transportadora: this.transportadora.cd_transportadora,
        cd_condicao_pagamento: this.pagamento.cd_condicao_pagamento,
        cd_tipo_pagamento_frete: this.tipo_frete.cd_tipo_pagamento_frete,
        dt_fechamento: formataData.formataDataSQL(this.dt_fechamento_consulta),
        cd_destinacao_produto: this.destinacao.cd_destinacao_produto,
        cd_pedido_compra_consulta: this.cd_pedido_compra_consulta,
        cd_item_pedido_compra_consulta: this.cd_item_pedido_compra_consulta,
        cd_forma_pagamento: this.forma_pagamento.cd_forma_pagamento,
        ic_email_confirmacao: ic_email_confirmacao,
        ic_obs_corpo_nf: ic_obs_corpo_nf,
        cd_parametro: 18,
        ds_obs_fat_consulta: this.ds_obs_fat_consulta,
        cd_cliente_entrega: this.cd_cliente_entrega,
      };

      try {
        this.load = true;
        const pedido = await Incluir.incluirRegistro(this.api, proposta);
        this.load = false;
        notify(pedido[0].Msg);
        this.$emit("FechaProposta");
      } catch (error) {
        this.load = false;
      }
    },
    async PesquisaContato(param) {
      if (param == 1) {
        try {
          this.loadingContato = true;
          //this.contato = "";
          this.contatos = [];
          let c = {
            cd_parametro: 2,
            cd_cliente: this.cd_cliente,
          };
          this.contatos = await Incluir.incluirRegistro(this.api, c);

          this.loadingContato = false;
        } catch (error) {
          this.loadingContato = false;
        }
      } else if (param == 2) {
        try {
          this.loadingContatoFaturamento = true;
          this.contato_faturamento = "";
          this.contatosFaturamento = [];
          let c = {
            cd_parametro: 2,
            cd_cliente: this.cd_cliente_fatura,
          };
          this.contatosFaturamento = await Incluir.incluirRegistro(this.api, c);
          if (this.contatosFaturamento[0].Cod == 0) {
            notify(this.contatosFaturamento[0].Msg);
            this.ic_contato_vazio = true;
          } else {
            this.ic_contato_vazio = false;
          }
          this.loadingContatoFaturamento = false;
        } catch (error) {
          this.loadingContatoFaturamento = false;
        }
      } else if (param == 3) {
      }
    },
    async TrocaLinhaItens({ selectedRowKeys, selectedRowsData }) {
      this.linhaItens = selectedRowsData;
    },
    async TrocaLinhaEntrega({ selectedRowKeys, selectedRowsData }) {
      this.linhaEntrega = selectedRowsData[0];
    },
    async TrocaLinhaFaturamento({ selectedRowKeys, selectedRowsData }) {
      this.linhaFaturamento = selectedRowsData[0];
    },
    async TrocaLinha({ selectedRowKeys, selectedRowsData }) {
      this.linha = selectedRowsData[0];
    },
    async SelecionaCliente(param) {
      if (!!this.linha.cd_cliente == false) return;
      this.nm_cliente = this.linha.Fantasia;
      this.cd_cliente = this.linha.cd_cliente;
      this.pagamento = {
        cd_condicao_pagamento: this.linha.cd_condicao_pagamento,
        nm_condicao_pagamento: this.linha.Condicao_Pagamento,
      };
      this.destinacao = {
        cd_destinacao_produto: this.linha.cd_destinacao_produto,
        nm_destinacao_produto: this.linha.Destinacao_Produto,
      };
      this.forma_pagamento = {
        cd_forma_pagamento: this.linha.cd_forma_pagamento,
        nm_forma_pagamento: this.linha.Forma_Pagamento,
      };
      this.transportadora = {
        cd_transportadora: this.linha.cd_transportadora,
        nm_transportadora: this.linha.Transportadora,
      };
      this.vendedor_interno = {
        cd_vendedor: this.linha.cd_vendedor_interno,
        nm_vendedor: this.linha.Vendedor_Interno,
      };
      this.vendedor_externo = {
        cd_vendedor: this.linha.cd_vendedor,
        nm_vendedor: this.linha.Vendedor,
      };
      this.tipo_local_entrega = {
        cd_tipo_local_entrega: this.linha.cd_tipo_local_entrega,
        nm_tipo_local_entrega: this.linha.nm_tipo_local_entrega,
      };
    },
    async PesquisaCliente(parametro) {
      if (parametro == 1) {
        this.loadingCliente = true;

        const c = {
          cd_parametro: 1,
          nm_cliente: this.nm_cliente,
        };
        this.clientes = await Incluir.incluirRegistro(this.api, c);
      } else if (parametro == 2) {
        this.loadingClienteFaturamento = true;

        const c = {
          cd_parametro: 1,
          nm_cliente: this.nm_cliente_faturamento,
        };
        this.clientes = await Incluir.incluirRegistro(this.api, c);
      } else if (parametro == 3) {
        this.nm_endereco_entrega = "";
        this.loadingClienteEntrega = true;

        const c = {
          cd_parametro: 1,
          nm_cliente: this.nm_cliente_entrega,
        };
        this.clientes = await Incluir.incluirRegistro(this.api, c);
      }

      try {
        if (parametro == 1) {
          if (this.clientes[0].Cod == 0) {
            notify(this.clientes[0].Msg);
          } else if (this.clientes.length == 1) {
            this.nm_cliente = this.clientes[0].Fantasia;
            this.tipo_pedido = {
              cd_tipo_pedido: this.clientes[0].cd_tipo_pedido,
              nm_tipo_pedido: this.clientes[0].nm_tipo_pedido,
            };
            this.tipo_local_entrega = {
              cd_tipo_local_entrega: this.clientes[0].cd_tipo_local_entrega,
              nm_tipo_local_entrega: this.clientes[0].nm_tipo_local_entrega,
            };
            this.transportadora = {
              cd_transportadora: this.clientes[0].cd_transportadora,
              nm_transportadora: this.clientes[0].Transportadora,
            };
            this.pagamento = {
              cd_condicao_pagamento: this.clientes[0].cd_condicao_pagamento,
              nm_condicao_pagamento: this.clientes[0].Condicao_Pagamento,
            };
            this.destinacao = {
              cd_destinacao_produto: this.clientes[0].cd_destinacao_produto,
              nm_destinacao_produto: this.clientes[0].Destinacao_Produto,
            };
            this.forma_pagamento = {
              cd_forma_pagamento: this.clientes[0].cd_forma_pagamento,
              nm_forma_pagamento: this.clientes[0].Forma_Pagamento,
            };
          } else {
            this.popupCliente = true;
          }
        } else if (parametro == 2) {
          if (this.clientes[0].Cod == 0) {
            notify(this.clientes[0].Msg);
          } else {
            if (this.clientes.length == 1) {
              this.cd_cliente_fatura = this.clientes[0].cd_cliente;
              this.nm_cliente_faturamento = this.clientes[0].Fantasia;
            } else {
              this.popupClienteFaturamento = true;
            }

            this.loadingClienteFaturamento = false;
          }
        } else if (parametro == 3) {
          if (this.clientes[0].Cod == 0) {
            notify(this.clientes[0].Msg);
            this.nm_endereco_entrega = "";
            this.loadingClienteEntrega = false;
          } else {
            if (this.clientes.length == 1) {
              this.loadingClienteEntrega = false;
              this.cd_cliente_entrega = this.clientes[0].cd_cliente;
              this.nm_cliente_entrega = this.clientes[0].Fantasia;
              this.nm_endereco_entrega =
                this.clientes[0].Endereco +
                " - " +
                this.clientes[0].Numero +
                " - " +
                this.clientes[0].Bairro +
                " - " +
                this.clientes[0].Cidade +
                "/" +
                this.clientes[0].Estado;
            } else {
              this.loadingClienteEntrega = false;
              this.popupClienteEntrega = true;
            }
          }
        }

        this.loadingCliente = false;
      } catch (error) {
        this.loadingCliente = false;
        this.loadingClienteFaturamento = false;
      }
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 1vh 1vw;
  padding: 0;
}

.borda {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
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
  .margin1 {
    margin: 1vh 1vw;
  }
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
#grid {
  max-height: 600px !important;
}
.endereco {
  font-size: 16px;
  font-weight: 500;
}
.qdate {
  width: 310px;

  flex-direction: none !important;
  overflow-x: hidden;
}
</style>
