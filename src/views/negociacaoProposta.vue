<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <transition name="slide-fade">
      <div
        v-show="!!tituloMenu && !!negociacao.cd_consulta"
        class="text-h6 row margin1"
      >
        {{ tituloMenu }} - Proposta: {{ negociacao.cd_consulta }}
      </div>
    </transition>
    <q-tabs
      v-model="tab"
      inline-label
      mobile-arrows
      @click="ChangeTab()"
      :class="'bg-' + color + ' text-white shadow-2 items-center borda'"
    >
      <q-tab :name="0" icon="description" label="Dados" />
      <q-tab :name="1" icon="edit" label="Alteração/Cadastro" />
    </q-tabs>
    <transition name="slide-fade">
      <div v-if="tab == 0" class="margin1">
        <grid
          v-if="tab == 0"
          :cd_menuID="7506"
          :cd_apiID="776"
          :cd_parametroID="0"
          :cd_consulta="1"
          :nm_json="{
            cd_parametro: 0,
            cd_consulta: this.negociacao.cd_consulta,
            cd_usuario: localStorage.cd_usuario,
          }"
          @Linha="PegaLinha($event)"
          ref="grid"
        />
        <div class="row">
          <q-btn
            v-if="tab != 1"
            :color="color"
            icon="refresh"
            class="margin1"
            label="Recarregar"
            rounded
            @click="$refs.grid.carregaDados()"
          />

          <q-btn
            :color="color"
            icon="add"
            class="margin1"
            label="Inserir"
            rounded
            @click="
              Clear();
              tab = 1;
            "
          />
        </div>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="tab == 1">
        <div class="row justify-around">
          <q-input
            class="umTercoTela margin1"
            :color="color"
            v-model="negociacao.cd_negociacao_consulta"
            v-show="!!negociacao.cd_negociacao_consulta"
            type="text"
            readonly
            label="Negociação"
          >
            <!--:disable="loading_org"-->
            <template v-slot:prepend>
              <q-icon name="work" />
            </template>
          </q-input>
          <q-input
            class="umTercoTela margin1"
            :color="color"
            v-model="negociacao.nm_fantasia_cliente"
            type="text"
            readonly
            label="Cliente"
          >
            <!--:disable="loading_org"-->
            <template v-slot:prepend>
              <q-icon name="face" />
            </template>
          </q-input>
          <q-input
            class="umTercoTela margin1"
            :color="color"
            v-model="negociacao.cd_telefone"
            type="text"
            readonly
            label="Telefone"
          >
            <!--:disable="loading_org"-->
            <template v-slot:prepend>
              <q-icon name="call" />
            </template>
          </q-input>
        </div>
        <div class="row justify-around">
          <q-input
            class="umTercoTela margin1"
            :color="color"
            v-model="negociacao.nm_email_cliente"
            type="text"
            readonly
            label="E-mail"
          >
            <!--:disable="loading_org"-->
            <template v-slot:prepend>
              <q-icon name="mail" />
            </template>
          </q-input>
          <q-input
            class="umTercoTela margin1"
            :color="color"
            v-model="negociacao.dt_consulta"
            type="text"
            readonly
            label="Data emissão"
          >
            <!--:disable="loading_org"-->
            <template v-slot:prepend>
              <q-icon name="today" />
            </template>
          </q-input>
          <q-input
            class="umTercoTela margin1"
            :color="color"
            v-model="negociacao.nm_fantasia_vendedor"
            type="text"
            readonly
            label="Vendedor Proposta"
          >
            <!--:disable="loading_org"-->
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-input>
        </div>

        <q-separator :color="color" style="margin:5px 0px" />

        <div class="row justify-around">
          <q-input
            v-model="negociacao.dt_negociacao_consulta"
            class="metadeTela margin1"
            mask="##/##/####"
            label="Data"
            :color="color"
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
                    v-model="negociacao.dt_negociacao_consulta"
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
          <q-select
            class=" margin1 metadeTela"
            :color="color"
            option-value="cd_vendedor"
            option-label="nm_fantasia_vendedor"
            v-model="negociacao.vendedor"
            :options="lokup_vendedor"
            label="Vendedor"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-select>
        </div>
        <div class="row justify-around">
          <q-input
            class="metadeTela margin1"
            :color="color"
            v-model="negociacao.nm_negociacao_consulta"
            type="text"
            maxlength="40"
            label="Nome"
          >
            <!--:disable="loading_org"-->
            <template v-slot:prepend>
              <q-icon name="badge" />
            </template>
          </q-input>
          <q-select
            class=" margin1 metadeTela"
            :color="color"
            option-value="cd_tipo_negociacao"
            option-label="nm_tipo_negociacao"
            v-model="negociacao.tipo"
            :options="lokup_tipo_negociacao"
            label="Tipo Negociação"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-select>
        </div>
        <div class="row">
          <q-input
            :color="color"
            class="telaInteira margin1"
            v-model="negociacao.ds_negociacao_consulta"
            type="text"
            autogrow
            label="Descritivo"
          >
            <!--:disable="loading_org"-->
            <template v-slot:prepend>
              <q-icon name="description" />
            </template>
          </q-input>
        </div>
        <div class="row items-center">
          <q-toggle
            :color="color"
            class="margin1"
            v-model="negociacao.ic_negociacao_finalizada"
            label="Negociação Finalizada"
          />
        </div>
        <div class="row items-center">
          <q-space />
          <transition name="slide-fade">
            <q-btn
              v-if="tab == 1"
              :color="color"
              icon="save"
              class="margin1"
              label="gravar"
              rounded
              @click="Save()"
            />
          </transition>
        </div>
      </div>
    </transition>
  </div>
</template>

<script>
import Menu from "../http/menu";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import Lookup from "../http/lookup";
import funcao from "../http/funcoes-padroes";
import formatadata from "../http/formataData";
import Incluir from "../http/incluir_registro";

export default {
  name: "negociacaoProposta",
  props: {
    cd_consultaID: { type: Number, default: 0 },
    cd_menuID: { type: Number, default: 0 },
    cd_apiID: { type: Number, default: 0 },
  },
  components: {
    grid: () => import("./grid.vue"),
  },
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_menu: 0,
      cd_api: 0,

      menu: {},
      api: "",
      tituloMenu: "",
      tab: 0,
      color: "orange-9",
      lokup_vendedor: [],
      lokup_tipo_negociacao: [],
      negociacao: {
        nm_email_cliente: "",
        nm_fantasia_cliente: "",
        cd_telefone: "",
        dt_consulta: "",
        cd_consulta: 0,
        cd_negociacao_consulta: 0,
        nm_fantasia_vendedor: "",
        ds_negociacao_consulta: "",
        nm_negociacao_consulta: "",
        ic_negociacao_finalizada: false,
        dt_negociacao_consulta: funcao.DataHoje(),
        vendedor: {
          cd_vendedor: 0,
          nm_fantasia_vendedor: "",
        },
        tipo: {
          cd_tipo_negociacao: 0,
          nm_tipo_negociacao: "",
        },
      },
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    await this.carregaMenu();
    await this.BuscaVendedor();
    await this.carregaDados();
  },

  methods: {
    async carregaDados() {
      let j = {
        cd_parametro: 2,
        cd_consulta: this.negociacao.cd_consulta,
      };
      var a = await Incluir.incluirRegistro(this.api, j);

      if (a[0].Cod == 0) return;
      a = a[0];
      this.negociacao.cd_consulta = a.cd_consulta;
      this.negociacao.cd_telefone = await funcao.FormataTelefone(
        a.cd_telefone.trim(),
      );
      this.negociacao.nm_email_cliente = a.nm_email_cliente;
      this.negociacao.nm_fantasia_cliente = a.nm_fantasia_cliente;
      this.negociacao.nm_fantasia_vendedor = a.nm_fantasia_vendedor;
      this.negociacao.dt_consulta = a.dt_consulta;
    },
    async ChangeTab() {
      if (this.tab == 1) {
        //await funcao.sleep(1000);
        if (!!this.negociacao.cd_negociacao_consulta == false) {
          notify("Selecione uma negociação!");
          this.Clear();
          this.tab = 0;
        }
      } else {
        this.Clear();
      }
    },
    async Save() {
      let finalizado = "N";
      this.negociacao.ic_negociacao_finalizada == true
        ? (finalizado = "S")
        : (finalizado = "N");
      let e = {
        cd_parametro: 1,
        cd_consulta: this.negociacao.cd_consulta,
        cd_negociacao_consulta: this.negociacao.cd_negociacao_consulta,
        dt_negociacao_consulta: formatadata.formataDataSQL(
          this.negociacao.dt_negociacao_consulta,
        ),
        cd_vendedor: this.negociacao.vendedor.cd_vendedor,
        nm_negociacao_consulta: this.negociacao.nm_negociacao_consulta,
        cd_tipo_negociacao: this.negociacao.tipo.cd_tipo_negociacao,
        ds_negociacao_consulta: this.negociacao.ds_negociacao_consulta,
        ic_negociacao_finalizada: finalizado,
      };
      var a = await Incluir.incluirRegistro(this.api, e);
      notify(a[0].Msg);
      this.tab = 0;
    },
    async BuscaVendedor() {
      let v = await Lookup.montarSelect(this.cd_empresa, 141);
      this.lokup_vendedor = JSON.parse(JSON.parse(JSON.stringify(v.dataset)));
      let vendedor = await funcao.buscaVendedor(this.cd_usuario);
      this.negociacao.vendedor = {
        cd_vendedor: vendedor.cd_vendedor,
        nm_fantasia_vendedor: vendedor.nm_fantasia_vendedor,
      };
    },
    async Clear() {
      this.negociacao.cd_consulta = this.cd_consultaID;
      this.negociacao.cd_negociacao_consulta = 0;
      this.negociacao.ds_negociacao_consulta = "";
      this.negociacao.nm_negociacao_consulta = "";
      this.negociacao.ic_negociacao_finalizada = false;
      this.negociacao.dt_negociacao_consulta = await funcao.DataHoje();
      this.negociacao.vendedor.cd_vendedor = 0;
      this.negociacao.vendedor.nm_fantasia_vendedor = "";
      this.negociacao.tipo.cd_tipo_negociacao = 0;
      this.negociacao.tipo.nm_tipo_negociacao = "";

      await this.BuscaVendedor();
    },
    async PegaLinha(l) {
      this.negociacao.cd_consulta = l.cd_consulta;

      this.negociacao.vendedor = {
        cd_vendedor: l.cd_vendedor,
        nm_fantasia_vendedor: l.nm_fantasia_vendedor_negociacao,
      };
      this.negociacao.cd_negociacao_consulta = l.cd_negociacao_consulta;
      this.negociacao.dt_negociacao_consulta = l.dt_negociacao_consulta;

      this.negociacao.nm_negociacao_consulta = l.nm_negociacao_consulta;
      this.negociacao.tipo = {
        cd_tipo_negociacao: l.cd_tipo_negociacao,
        nm_tipo_negociacao: l.nm_tipo_negociacao,
      };
      this.negociacao.ds_negociacao_consulta = l.ds_negociacao_consulta;
      l.ic_negociacao_finalizada == "N"
        ? (this.negociacao.ic_negociacao_finalizada = false)
        : (this.negociacao.ic_negociacao_finalizada = true);
    },
    async carregaMenu() {
      this.cd_menu = this.cd_menuID;
      this.cd_api = this.cd_apiID;
      this.negociacao.cd_consulta = this.cd_consultaID;

      this.menu = await Menu.montarMenu(
        this.cd_empresa,
        this.cd_menu,
        this.cd_api,
      );
      this.api = this.menu.nm_identificacao_api;
      this.tituloMenu = this.menu.nm_menu_titulo;
      //----------------------------------------------
      let tn = await Lookup.montarSelect(this.cd_empresa, 4403);
      this.lokup_tipo_negociacao = JSON.parse(
        JSON.parse(JSON.stringify(tn.dataset)),
      );
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
}
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
.borda {
  border-radius: 20px;
}
#data-pop {
  flex-direction: none !important;
  width: 310px;
  overflow-x: hidden;
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
