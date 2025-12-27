<template>
  <div>
    <div class="margin1 titulo-bloco">Investimento</div>
    <q-tabs
      v-model="tab"
      class="text-orange-9"
      dense
      align="justify"
      inline-label
    >
      <q-tab name="dados" icon="folder" label="Dados" />
      <q-tab name="lancamento" icon="description" label="Lançamento" />
    </q-tabs>
    <q-tab-panels v-model="tab" animated>
      <q-tab-panel name="dados">
        GRID COM TODOS INVESTIMENTOS
        <!-- <grid :cd_menuID="this.cd_menu" :cd_apiID="this.cd_api" ref="grid_c">
        </grid> -->
      </q-tab-panel>
      <q-tab-panel name="lancamento">
        <div class="row">
          <q-input dense class="col margin1" v-model="text" label="Nome">
            <template v-slot:prepend>
              <q-icon name="person" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Data">
            <template v-slot:append>
              <q-btn
                icon="event"
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
                  <q-date
                    v-model="dt_picker_retorno"
                    @input="DataRetorno(dt_picker_retorno)"
                    class="qdate"
                  >
                    <div class="row items-center justify-end">
                      <q-btn v-close-popup round flat icon="close" size="sm" />
                    </div>
                  </q-date>
                </q-popup-proxy>
              </q-btn>
            </template>
            <template v-slot:prepend>
              <q-icon name="event" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Tipo de Aplicação"
            ><template v-slot:prepend>
              <q-icon
                name="format_list_bulleted"
                class="cursor-pointer"
              ></q-icon>
            </template>
          </q-input>
        </div>
        <div class="row">
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Conta / Agência / Banco"
            ><template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Valor Aplicado"
            ><template v-slot:prepend>
              <q-icon name="price_check" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            readonly
            v-model="text"
            label="Tempo Aplicado"
            ><template v-slot:prepend>
              <q-icon name="date_range" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
        <div class="row">
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Rendimento (R$)"
            ><template v-slot:prepend>
              <q-icon name="payments" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Rendimento (%)"
            ><template v-slot:prepend>
              <q-icon name="payments" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Resgate">
            <template v-slot:append>
              <q-btn
                icon="event"
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
                  <q-date
                    v-model="dt_picker_retorno"
                    @input="DataRetorno(dt_picker_retorno)"
                    class="qdate"
                  >
                    <div class="row items-center justify-end">
                      <q-btn v-close-popup round flat icon="close" size="sm" />
                    </div>
                  </q-date>
                </q-popup-proxy>
              </q-btn>
            </template>
            <template v-slot:prepend>
              <q-icon name="today" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
        <div class="row">
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Histórico de Resgate"
            ><template v-slot:prepend>
              <q-icon name="history" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Valor Atual"
            ><template v-slot:prepend>
              <q-icon name="attach_money" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="(%) I.R - Imposto de Renda"
            ><template v-slot:prepend>
              <q-icon name="work" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
        <div class="row">
          <q-input dense class="col margin1" v-model="text" label="(%) IOF"
            ><template v-slot:prepend>
              <q-icon name="work" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Plano Financeiro"
            ><template v-slot:prepend>
              <q-icon name="description" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Observação"
            ><template v-slot:prepend>
              <q-icon name="visibility" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
      </q-tab-panel>
    </q-tab-panels>

    <transition name="slide-fade">
      <div v-if="ic_ativa_btn == true">
        <q-btn
          rounded
          color="orange-9"
          icon="save"
          label="Salvar"
          class="margin1"
        >
          <q-tooltip>
            Salvar
          </q-tooltip>
        </q-btn>
        <q-btn
          rounded
          flat
          color="orange-9"
          icon="cleaning_services"
          style="float: right;"
          label="Limpar"
          class="margin1"
          @click="OnLimpar()"
        >
          <q-tooltip>
            Limpar
          </q-tooltip>
        </q-btn>
      </div>
    </transition>
    <q-dialog v-model="load" maximized persistent>
      <carregando />
    </q-dialog>
  </div>
</template>

<script>
export default {
  props: {
    cd_tipo_lancamento: { type: Number, default: 0 },
    ic_ativa_btn: { type: Boolean, default: true },
  },
  components: {
    carregando: () => import("../components/carregando.vue"),
  },
  data() {
    return {
      text: "",
      load: false,
      dt_picker_retorno: 0,
      tab: "dados",
    };
  },
  methods: {
    DataRetorno() {},
  },
};
</script>

<style scoped>
@import "./views.css";

* {
  background-color: #f2f2f2;
}

.margin1 {
  margin: 0.7vw 0.4vw;
  padding: 0;
}
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}
.titulo-bloco {
  font-weight: bold;
  font-size: larger;
}
</style>
