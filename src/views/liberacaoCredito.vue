<template>
  <div>
    <div class="row text-h6 margin1" v-show="!!tituloMenu">
      {{ tituloMenu }}
      <q-space />
      <q-btn round :color="colorID" @click="popupData = true" icon="event" />
    </div>

    <q-input
      class="margin1"
      v-model="cd_pedido_venda"
      label="Pedido de Venda"
      type="number"
      :color="colorID"
      @keypress.enter="PesquisaPedido()"
      @blur="PesquisaPedido()"
      min="0"
    >
      <template v-slot:prepend>
        <q-icon name="sell" />
      </template>
    </q-input>
    <div>
      <grid
        class="margin1"
        :cd_menuID="cd_menu"
        :cd_apiID="777"
        :multipleSelection="true"
        :cd_parametroID="0"
        :cd_consulta="1"
        :nm_json="{
          cd_parametro: 0,
          cd_pedido_venda: this.cd_pedido_venda,
          dt_inicial: dt_inicial,
          dt_final: dt_final,
          cd_usuario: localStorage.cd_usuario,
        }"
        @Linha="PegaLinha($event)"
        ref="grid"
      />
      <div class="row items-center">
        <q-btn
          rounded
          class="margin1"
          :color="colorID"
          label="Recarregar"
          @click="
            cd_pedido_venda = '';
            $refs.grid.carregaDados();
          "
          icon="refresh"
        />
        <transition name="slide-fade">
          <q-btn
            rounded
            class="margin1"
            :color="colorID"
            v-show="pedidos.length > 0"
            label="Liberar"
            @click="Liberar()"
            icon="payments"
          />
        </transition>
      </div>
    </div>
    <q-dialog
      v-model="popupData"
      style="width: auto !important; height: auto !important;"
    >
      <q-card style="width: auto !important; height: auto !important">
        <div
          class="text-center margin1 row items-center"
          style="font-size:20px"
        >
          Seleção de Data
          <q-space />
          <q-btn round flat v-close-popup icon="close" />
        </div>
        <selecaoData :cd_volta_home="1" />
      </q-card>
    </q-dialog>
    <!----------------------------------------------------------------------------------->
    <q-dialog v-model="popupConfirmacao" class="Qcard">
      <q-expansion-item
        class="overflow-hidden Qcard"
        style="border-radius: 20px; height:auto;margin:0;"
        icon="check"
        label="Clientes com crédito suspenso"
        default-opened
        v-model="expansion"
        :header-class="'bg-' + colorID + ' text-white items-center text-h6'"
        expand-icon-class="text-white "
      >
        <q-card class="Qcard">
          <q-scroll-area class="scroll-area">
            <q-list v-for="(a, q) in pedidos" :key="q" class="list-response">
              <q-item
                v-show="a.CreditoSuspenso == 'S'"
                style="font-size:16px; height: auto;"
                class="row items-center"
              >
                <q-item-section class=" text-bold margin1 response">
                  Pedido de Venda - {{ a.cd_pedido_venda }}
                </q-item-section>

                <q-item-section class="margin1 response">
                  {{ a.Cliente }} - {{ a.cd_cnpj_cliente }}
                </q-item-section>

                <q-item-section side style="float:right" class="response1">
                  <div style="float:right; width:auto">
                    <transition name="slide-fade">
                      <q-btn
                        class="margin1"
                        round
                        v-if="a.Save == 'N'"
                        color="positive"
                        icon="check"
                        @click="a.Save = 'S'"
                      />
                      <q-btn
                        class="margin1"
                        round
                        flat
                        v-else
                        @click="a.Save = 'N'"
                        color="negative"
                        icon="close"
                      />
                    </transition>
                  </div>
                </q-item-section>
              </q-item>
              <q-separator :color="colorID" />
            </q-list>
            <!--<div class="margin1"  >
              <div class="row text-h6 text-negative">
                {{ q + 1 }} - Pedido - {{ a.cd_pedido_venda }}
              </div>
            </div>-->
          </q-scroll-area>
          <div class="buttons-card">
            <!---->
            <q-btn
              class="margin1"
              rounded
              v-close-popup
              label="Cancelar"
              :color="colorID"
              icon="close"
            />

            <q-btn
              class="margin1"
              rounded
              label="Confirmar"
              :color="colorID"
              @click="ConfirmarCredito()"
              icon="close"
            />
          </div>

          <!--<div class=" row items-center margin1"></div>-->
        </q-card>
      </q-expansion-item>
    </q-dialog>
    <!------------------------------------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando :mensagemID="'Aguarde...'" :colorID="colorID" />
    </q-dialog>
  </div>
</template>

<script>
import Menu from "../http/menu";
import Lookup from "../http/lookup";
import funcao from "../http/funcoes-padroes";
import formataData from "../http/formataData";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";

export default {
  props: {
    colorID: { type: String, default: "primary" },
  },
  name: "liberacaoCredito",
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_menu: 7508,
      cd_api: "777/1179",
      tituloMenu: "",
      cd_pedido_venda: "",
      dt_final: localStorage.dt_final,
      dt_inicial: localStorage.dt_inicial,
      popupData: false,
      menu: {},
      pedidos: [],
      load: false,
      popupConfirmacao: false,
      expansion: true,
    };
  },
  async created() {
    this.menu = await Menu.montarMenu(this.cd_empresa, this.cd_menu, 777);
    this.tituloMenu = this.menu.nm_menu_titulo;
  },
  components: {
    grid: () => import("../views/grid.vue"),
    selecaoData: () => import("../views/selecao-periodo.vue"),
    carregando: () => import("../components/carregando.vue"),
  },
  watch: {
    expansion() {
      if (this.expansion == false) {
        this.expansion = true;
      }
    },
    popupData() {
      if (this.popupData == false) {
        this.$refs.grid.carregaDados();
        this.dt_final = localStorage.dt_final;
        this.dt_inicial = localStorage.dt_inicial;
      }
    },
  },
  methods: {
    async gravaPedido(cd_pedido_venda) {
      let dt_hoje = funcao.DataHoje();
      dt_hoje = formataData.formataDataSQL(dt_hoje);

      try {
        let i = {
          cd_parametro: 1,
          cd_pedido_venda: cd_pedido_venda,
          dt_credito_pedido_venda: dt_hoje,
          cd_usuario: this.cd_usuario,
        };
        let lib = await Incluir.incluirRegistro(this.cd_api, i);
        notify(lib[0].Msg);
      } catch (error) {
        this.load = false;
      }
    },
    async ConfirmarCredito() {
      this.load = true;
      try {
        for (let a = 0; a < this.pedidos.length; a++) {
          if (this.pedidos[a].Save == "S") {
            this.load = true;
            await this.gravaPedido(this.pedidos[a].cd_pedido_venda);
            this.load = false;
          }
        }
        this.popupConfirmacao = false;
        this.load = false;
      } catch (error) {
        this.load = false;
      }
      this.$refs.grid.carregaDados();
    },
    async PesquisaPedido() {
      if (!!this.cd_pedido_venda) {
        localStorage.dt_final = "12-31-2027";
        localStorage.dt_inicial = "01-01-1980";
        this.dt_inicial = localStorage.dt_inicial;
        this.dt_final = localStorage.dt_final;
        this.$refs.grid.carregaDados();
      }
    },
    async Liberar() {
      let abrePopup = false;
      //Valida o crédito do cliente
      for (let a = 0; a < this.pedidos.length; a++) {
        if (
          this.pedidos[a].CreditoSuspenso == "S" &&
          this.pedidos[0].ic_valida_limite_credito == "S"
        ) {
          abrePopup = true;
        } else {
          this.load = true;
          await this.gravaPedido(this.pedidos[a].cd_pedido_venda);
          this.load = false;
        }
      }
      //------------

      if (abrePopup == true) {
        this.popupConfirmacao = true;
      } else {
        this.$refs.grid.carregaDados();
      }
    },
    async PegaLinha(l) {
      this.pedidos = l;
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: none;
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
.Qcard {
  width: 90vw;
  height: 90vh;
}
.scroll-area {
  width: 70vw;
  height: 78vh;
}

@media (min-width: 600px) {
  .q-dialog__inner--minimized > div {
    max-width: 70vw !important;
    height: 90vh !important;
  }
}
@media (max-width: 640px) {
  .response {
    width: 42%;
    text-align: center;
  }
  .response1 {
    width: 15%;
  }
  .list-response {
    height: 60px;
  }
  .Qcard {
    width: 90vw;
    height: 90vh;
  }
  .scroll-area {
    width: 90vw;
    height: 80vh;
  }
  .buttons-card {
    align-content: center;
    text-align: center;
    justify-items: center;
  }
}

/*
.


.column {
  height: 30px !important;
}

*/
</style>
