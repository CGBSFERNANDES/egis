<template>
  <div style="background: white">
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <q-toolbar class="my-header margin1">
      <q-img :src="img_logo" class="imagem-header" spinner-color="white" />
      <div style="font-weight: bold; font-size: 24px">{{ nm_empresa }}</div>
      <q-space />
    </q-toolbar>
    <div style="background: white">
      <q-dialog
        v-model="pedeID"
        persistent
        :maximized="maximizedToggle"
        transition-show="slide-up"
        transition-hide="slide-down"
      >
        <q-card>
          <q-bar class="bg-deep-orange-3 text-white text-center">
            <q-space />
          </q-bar>
          <div class="fixed-center item-center text-center">
            <div class="text-bold" style="font-size: 3vw;">
              {{ `Digite o código da Proposta!` }}
            </div>
            <q-input
              v-model="cd_id_processo"
              type="password"
              color="black"
              label="Codigo da Proposta"
            >
              <template v-slot:prepend>
                <q-icon name="password" />
              </template>
            </q-input>
            <q-btn
              class="margin1"
              size="lg"
              icon="done"
              color="positive"
              :loading="loadingID"
              round
              @click="verificaProposta(cd_id_processo)"
            />
          </div>
        </q-card>
      </q-dialog>
    </div>
    <!-- PROPOSTA FICA AQUI -->
    <q-expansion-item
      v-if="cd_proposta > 0"
      icon="summarize"
      :label="`Proposta - ${cd_proposta}`"
      default-opened
      class="shadow-1 overflow-hidden margin1"
      style="border-radius: 20px; height:auto"
      header-class="bg-orange-9 text-white item-center text-h6"
      expand-icon-class="text-white"
    >
      <q-card-section class="scroll margin1">
        <div>
          <!---DADOS DO CLIENTE--->
          <div class="shadow-1 margin1 borda-bloco">
            <div class="nome-campo margin1 text-bold">Cliente</div>
            <div class="row">
              <q-field
                dense
                color="orange-9"
                class="tres-tela media margin1"
                label="Fantasia"
                :stack-label="!!Fantasia"
              >
                <template v-slot:prepend>
                  <q-icon name="business" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ Fantasia }}
                  </div>
                </template>
              </q-field>

              <q-field
                dense
                color="orange-9"
                class="tres-tela media margin1"
                label="Razão Social"
                :stack-label="!!Razao_Social"
              >
                <template v-slot:prepend>
                  <q-icon name="location_city" />
                </template>
                <template v-slot:control>
                  <div
                    class="self-center full-width no-outline"
                    style="white-space : normal"
                  >
                    {{ Razao_Social }}
                  </div>
                </template>
              </q-field>

              <q-field
                dense
                color="orange-9"
                class="tres-tela media margin1"
                label="Telefone"
                :stack-label="!!Telefone_Empresa"
              >
                <template v-slot:prepend>
                  <q-icon name="call" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ Telefone_Empresa }}
                  </div>
                </template>
              </q-field>
            </div>

            <div class="row ">
              <q-field
                dense
                color="orange-9"
                class="tres-tela media margin1"
                :label="CNPJouCPF"
                :stack-label="!!CNPJ"
              >
                <template v-slot:prepend>
                  <q-icon name="app_registration" />
                </template>
                <template v-slot:control>
                  <div
                    v-if="CNPJ.length != 11"
                    class="self-center full-width no-outline"
                  >
                    {{ `${CNPJ}` }}
                  </div>
                </template>
              </q-field>

              <q-field
                dense
                color="orange-9"
                class="tres-tela media margin1"
                label="Site"
                :stack-label="!!nm_dominio_cliente"
              >
                <template v-slot:prepend>
                  <q-icon name="language" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ nm_dominio_cliente }}
                  </div>
                </template>
              </q-field>

              <q-field
                dense
                color="orange-9"
                class="tres-tela media margin1"
                label="E-mail"
                :stack-label="!!Email"
              >
                <template v-slot:prepend>
                  <q-icon name="email" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ Email }}
                  </div>
                </template>
              </q-field>
            </div>

            <div class="row">
              <q-field
                dense
                color="orange-9"
                class="tres-tela media margin1"
                label="Tipo de Pessoa"
                :stack-label="!!Tipo_Pessoa"
              >
                <template v-slot:prepend>
                  <q-icon name="people" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ Tipo_Pessoa }}
                  </div>
                </template>
              </q-field>

              <q-field
                dense
                color="orange-9"
                class="tres-tela media margin1"
                label="Ramo de Atividade"
                :stack-label="!!Ramo_Atividade"
              >
                <template v-slot:prepend>
                  <q-icon name="badge" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ Ramo_Atividade }}
                  </div>
                </template>
              </q-field>
            </div>
          </div>
          <!---DADOS DA PROPOSTA--->
          <div class="shadow-1 margin1 borda-bloco">
            <div class="margin1 text-bold">Condições</div>

            <div class="row">
              <q-field
                class="tres-tela media margin1"
                dense
                label="Vendedor"
                color="orange-9"
                :stack-label="!!vendedor"
              >
                <template v-slot:prepend>
                  <q-icon name="person" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ vendedor }}
                  </div>
                </template>
              </q-field>

              <q-field
                class="tres-tela media margin1"
                dense
                label="Transportadora"
                color="orange-9"
                :stack-label="!!transportadora"
              >
                <template v-slot:prepend>
                  <q-icon name="local_shipping" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ transportadora }}
                  </div>
                </template>
              </q-field>

              <q-field
                class="tres-tela media margin1"
                dense
                label="Destinação"
                color="orange-9"
                :stack-label="!!destinacao"
              >
                <template v-slot:prepend>
                  <q-icon name="map" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ destinacao }}
                  </div>
                </template>
              </q-field>
            </div>

            <div class="row">
              <q-field
                class="tres-tela media margin1"
                dense
                label="Tipo de Pedido"
                color="orange-9"
                :stack-label="!!tipo_pedido"
              >
                <template v-slot:prepend>
                  <q-icon name="format_list_bulleted" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ tipo_pedido }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="tres-tela media margin1"
                dense
                label="Tipo de Endereço"
                color="orange-9"
                :stack-label="!!tipo_endereco"
              >
                <template v-slot:prepend>
                  <q-icon name="pin_drop" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ tipo_endereco }}
                  </div>
                </template>
              </q-field>

              <q-field
                class="tres-tela media margin1"
                dense
                label="Tipo de Frete"
                color="orange-9"
                :stack-label="!!tipo_frete"
              >
                <template v-slot:prepend>
                  <q-icon name="local_shipping" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ tipo_frete }}
                  </div>
                </template>
              </q-field>
            </div>

            <div class="row">
              <q-field
                class="tres-tela media margin1"
                dense
                label="Condição de Pagamento"
                color="orange-9"
                :stack-label="!!pagamento"
              >
                <template v-slot:prepend>
                  <q-icon name="account_balance_wallet" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ pagamento }}
                  </div>
                </template>
              </q-field>

              <q-field
                class="tres-tela media margin1"
                dense
                label="Pagamento do Frete"
                color="orange-9"
                :stack-label="!!frete_pagamento"
              >
                <template v-slot:prepend>
                  <q-icon name="payments" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ frete_pagamento }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="tres-tela media margin1"
                dense
                label="Observações"
                color="orange-9"
                :stack-label="!!obs"
              >
                <template v-slot:prepend>
                  <q-icon name="description" />
                </template>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ obs }}
                  </div>
                </template>
              </q-field>
            </div>
          </div>
        </div>
      </q-card-section>
      <q-expansion-item
        expand-separator
        default-opened
        icon="local_offer"
        class="shadow-1 overflow-hidden margin1"
        style="border-radius: 20px; height:auto"
        header-class="bg-orange-9 text-white item-center text-h6"
        expand-icon-class="text-white"
      >
        <template v-slot:header>
          <q-item-section avatar>
            <q-avatar icon="local_offer" text-color="white"></q-avatar>
          </q-item-section>

          <q-item-section>
            {{ `Itens da Proposta` }}
          </q-item-section>

          <q-item-section center>
            <div class="row items-center text-bold">
              <!-- {{ `Itens: ${carrinho.length} | Total: ${valorTotal}` }} -->
            </div>
          </q-item-section>
        </template>
        <q-card>
          <q-card-section>
            <DxDataGrid
              class="margin1"
              key-expr="cd_controle"
              :data-source="dataSource"
              :columns="coluna"
              :show-borders="true"
              :selection="{ mode: 'single' }"
              :focused-row-enabled="true"
              :column-auto-width="true"
              :column-hiding-enabled="false"
              :remote-operations="false"
              :word-wrap-enabled="false"
              :allow-column-reordering="false"
              :allow-column-resizing="true"
              :row-alternation-enabled="true"
              :repaint-changes-only="true"
              :autoNavigateToFocusedRow="true"
              :focused-row-index="0"
              :cacheEnable="false"
            >
            </DxDataGrid>
            <div v-if="botoes" class="col">
              <a :href="WhatsApp" target="_blank" style="text-decoration: none">
                
                <q-btn
                  rounded
                  size="md"
                  icon="thumbs_up_down"
                  color="orange-9"  
                  class="margin1"
                  label="Negociar"
                  style="float: left;"
                >
                  <q-tooltip>
                    Negociar Proposta
                  </q-tooltip>
                </q-btn>
              </a>
              <q-btn
                rounded
                size="md"
                icon="done"
                color="orange-9"
                class="margin1"
                label="Aceitar"
                style="float: left;"
                @click="popup_aceitar = !popup_aceitar"
              >
                <q-tooltip>
                  Aceitar Proposta
                </q-tooltip>
              </q-btn>
              <q-btn
                size="md"
                icon="close"
                color="orange-9"
                class="margin1"
                flat
                label="Recusar"
                style="float: right;"
                @click="popup_declinar = !popup_declinar"
              >
                <q-tooltip>
                  Recusar Proposta
                </q-tooltip>
              </q-btn>
            </div>
          </q-card-section>
        </q-card>
      </q-expansion-item>
    </q-expansion-item>
    <q-toolbar>
      <q-img
        :src="img_logo_footer"
        class="imagem-header_gbs"
        spinner-color="white"
      />
      <q-space />
      <div class="text-bold">Todos os direitos reservados.</div>
    </q-toolbar>

    <q-dialog v-model="load" maximized persistent>
      <carregando :corID="'orange-9'"></carregando>
    </q-dialog>
    <!---DECLINAR PROPOSTA----------------------------------->
    <q-dialog
      v-if="cd_proposta != 0"
      v-model="popup_declinar"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card style="border-radius: 20px;">
        <parcial
          @FechaPopup="FechaPopupAltera()"
          :ic_perda="true"
          :cd_movimento="parseInt(cd_proposta)"
        />
      </q-card>
    </q-dialog>
    <!------------------------------------------------->
    <!---ACEITAR PROPOSTA----------------------------------->
    <q-dialog
      v-if="cd_proposta != 0"
      v-model="popup_aceitar"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card style="border-radius: 20px;">
        <parcial
          @FechaPopup="FechaPopupAltera()"
          :ic_perda="false"
          :cd_movimento="parseInt(cd_proposta)"
        />
      </q-card>
    </q-dialog>
    <!------------------------------------------------->
  </div>
</template>

<script>
import { DxDataGrid } from "devextreme-vue/data-grid";

import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import ptMessages from "devextreme/localization/messages/pt.json";
import Menu from "../http/menu";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import carregando from "../components/carregando.vue";
import funcao from "../http/funcoes-padroes";

export default {
  watch: {
    async popup_declinar(a, b) {
      if (a == false) {
        var json_consulta = {
          cd_parametro: 6,
          cd_consulta: this.cd_proposta,
          cd_empresa: this.cd_empresa,
        };
        this.load = true;
        let proposta_consulta = await Incluir.incluirRegistro(
          this.api,
          json_consulta
        ); //pr_egisnet_elabora_proposta
        this.load = false;
        if (
          proposta_consulta[0].cd_pedido_venda > 0 ||
          !!proposta_consulta[0].dt_fechamento_consulta
        ) {
          notify("Proposta encerrada!");
          this.botoes = false;
          return;
        }
      }
    },
    async popup_aceitar(a, b) {
      if (a == false) {
        var json_consulta = {
          cd_parametro: 6,
          cd_consulta: this.cd_proposta,
          cd_empresa: this.cd_empresa,
        };
        this.load = true;
        let proposta_consulta = await Incluir.incluirRegistro(
          this.api,
          json_consulta
        ); //pr_egisnet_elabora_proposta
        this.load = false;
        if (
          proposta_consulta[0].cd_pedido_venda > 0 ||
          !!proposta_consulta[0].dt_fechamento_consulta
        ) {
          notify("Proposta encerrada!");
          this.botoes = false;
          return;
        }
      }
    },
  },
  components: {
    DxDataGrid,
    carregando,
    parcial: () => import("../components/fechamentoParcial.vue"),
  },
  data() {
    return {
      load: false,
      pedeID: true,
      cd_id_processo: "",
      loadingID: false,
      popup_declinar: false,
      popup_aceitar: false,
      WhatsApp: "",
      botoes: true,
      coluna: [],
      cd_proposta: 0,
      dataSource: [],
      column: [],
      dt_inicial: "",
      dt_final: "",
      maximizedToggle: true,
      img_logo: "",
      img_logo_footer: "",
      logo_gbs: "",
      cd_empresa: 0,
      nm_empresa: "",
      cd_consulta: 0,
      transportadora: "",
      Telefone_Empresa: "",
      Fantasia: "",
      Razao_Social: "",
      CNPJouCPF: "CNPJ",
      CNPJ: "",
      nm_dominio_cliente: "",
      Email: "",
      Tipo_Pessoa: "",
      Ramo_Atividade: "",
      vendedor: "",
      destinacao: "",
      tipo_pedido: "",
      tipo_endereco: "",
      tipo_frete: "",
      pagamento: "",
      frete_pagamento: "",
      obs: "",
      api: "562/781", // Procedimento 1439 - pr_egisnet_elabora_proposta
    };
  },
  computed: {},
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    this.cd_empresa = localStorage.cd_empresa;
    this.logo_gbs =
      "http://gbstec.com.br/wp-content/uploads/2019/10/Logo-novo-gbs-menor.png";
    this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();
    this.dt_final = new Date(localStorage.dt_final).toLocaleDateString();
    this.hoje = new Date().toLocaleDateString();
    var h = new Date().toLocaleTimeString();
    this.hora = h.substring(0, 5);
  },

  methods: {
    async verificaProposta(e) {
      this.loadingID = true;
      //Chave da negociação - cd_empresa/cd_consulta
      if (e.length === 65 && e.includes(":")) {
        const valor_descriptografado = await funcao.descriptografa(e);
        if (!!valor_descriptografado) {
          //console.log(valor_descriptografado, "VALOR desCRIPTOGRAFADO");
          const [empresa, consulta] = valor_descriptografado.split("/");
          localStorage.cd_empresa = empresa;
          this.cd_empresa = empresa;
          this.cd_proposta = consulta;
          let menu_grid = await Menu.montarMenu(
            localStorage.cd_empresa,
            7441,
            562
          );
          this.coluna = JSON.parse(
            JSON.parse(JSON.stringify(menu_grid.coluna))
          );
          var json_consulta = {
            cd_parametro: 6,
            cd_consulta: this.cd_proposta,
            cd_empresa: this.cd_empresa,
          };
          let proposta_consulta = await Incluir.incluirRegistro(
            this.api,
            json_consulta
          ); //pr_egisnet_elabora_proposta
          this.dataSource = proposta_consulta;
          //console.log(this.dataSource, "MEU DATA SOURCE");
          if (
            this.dataSource[0].cd_pedido_venda > 0 ||
            !!this.dataSource[0].dt_fechamento_consulta
          ) {
            notify("Proposta encerrada!");
            this.loadingID = false;
            return;
          }
          (this.WhatsApp = `https://api.whatsapp.com/send?phone=55${proposta_consulta[0].WhatsApp}&text=Ol%C3%A1%20tudo%20bem%20%3F%20Quero%20negociar%20a%20proposta%20${this.cd_proposta}`),
            (this.img_logo =
              "http://www.egisnet.com.br/img/" + proposta_consulta[0].nm_logo);
          this.img_logo_footer =
            "http://www.egisnet.com.br/img/" + proposta_consulta[0].nm_logo;
          this.nm_empresa = proposta_consulta[0].nm_empresa;
          this.Fantasia = proposta_consulta[0].nm_fantasia_cliente;
          this.Razao_Social = proposta_consulta[0].nm_razao_social_cliente;
          this.Telefone_Empresa =
            "(" +
            proposta_consulta[0].cd_ddd +
            ")" +
            proposta_consulta[0].cd_telefone;
          // this.CNPJ = await funcao.FormataCNPJ(
          //   proposta_consulta[0].cd_cnpj_cliente
          // );

          if (proposta_consulta[0].cd_cnpj_cliente.length == 11) {
            this.CNPJ = await funcao.FormataCPF(
              proposta_consulta[0].cd_cnpj_cliente
            );
            this.CNPJouCPF = "CPF";
          } else {
            this.CNPJ = await funcao.FormataCNPJ(
              proposta_consulta[0].cd_cnpj_cliente
            );
            this.CNPJouCPF = "CNPJ";
          }
          this.nm_dominio_cliente = proposta_consulta[0].nm_dominio_cliente;
          this.Email = proposta_consulta[0].nm_email_cliente;
          this.Tipo_Pessoa = proposta_consulta[0].nm_tipo_pessoa;
          this.Ramo_Atividade = proposta_consulta[0].nm_ramo_atividade;
          this.transportadora = proposta_consulta[0].nm_transportadora;
          this.vendedor = proposta_consulta[0].nm_vendedor;
          this.destinacao = proposta_consulta[0].nm_destinacao_produto;
          this.tipo_pedido = proposta_consulta[0].nm_tipo_pedido;
          this.tipo_endereco = proposta_consulta[0].nm_tipo_local_entrega;
          this.tipo_frete = proposta_consulta[0].nm_tipo_pagamento_frete;
          this.pagamento = proposta_consulta[0].nm_condicao_pagamento;
          this.frete_pagamento = proposta_consulta[0].nm_tipo_pagamento_frete;
          this.obs = proposta_consulta[0].ds_observacao_consulta;
          this.loadingID = false;
          this.pedeID = false;
        } else {
          notify("Código incorreto!");
          this.loadingID = false;
        }
      } else {
        notify("Código incorreto!");
        this.loadingID = false;
      }
    },

    async FormataMoeda() {
      this.salario_atual = await funcao.FormataValor(this.salario_atual);
    },
  },
};
</script>

<style scooped>
.input {
  width: 33%;
}
.margin1 {
  margin: 0.5% 0.4%;
  padding: 0;
}
.my-header {
  max-height: 4vw;
}
.imagem-header {
  max-height: 200px;
  max-width: 200px;
}
.imagem-header_gbs {
  margin: 2px;
  max-height: 5%;
  max-width: 5%;
}

.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
  margin: 0.5vw;
}

.metade-tela {
  width: 48% !important;
}

.tres-tela {
  width: 31%;
}

.line {
  display: inline-flex;
}
.card-questoes {
  width: 20vw;
}
.card-questoes2 {
  width: 23vw;
}

@media (max-width: 920px) {
  .metade-tela {
    width: 100% !important;
  }

  .tres-tela {
    width: 100% !important;
  }
  .card-questoes {
    width: 100%;
  }
  .line {
    display: block;
  }
  .card-questoes2 {
    width: 100%;
  }
}
</style>
