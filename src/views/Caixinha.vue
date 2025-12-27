<template>
  <div>
    <div class="margin1 titulo-bloco">Caixa Interno</div>
    <div class="row">
      <q-input dense class="col margin1" v-model="text" label="Código"
        ><template v-slot:prepend>
          <q-icon name="badge" class="cursor-pointer"></q-icon>
        </template>
      </q-input>
      <q-input dense class="col margin1" v-model="text" label="Moeda"
        ><template v-slot:prepend>
          <q-icon name="monetization_on" class="cursor-pointer"></q-icon>
        </template>
      </q-input>
      <q-input dense class="col margin1" v-model="text" label="Tipo Caixa"
        ><template v-slot:prepend>
          <q-icon name="format_list_bulleted" class="cursor-pointer"></q-icon>
        </template>
      </q-input>
    </div>
    <div class="row">
      <q-input dense class="col margin1" v-model="text" label="Plano Financeiro"
        ><template v-slot:prepend>
          <q-icon name="description" class="cursor-pointer"></q-icon>
        </template>
      </q-input>
      <q-input
        dense
        class="col margin1"
        v-model="text"
        label="Lançamento Contábil Padrão"
        ><template v-slot:prepend>
          <q-icon name="edit_note" class="cursor-pointer"></q-icon>
        </template>
      </q-input>
      <q-input dense class="col margin1" readonly v-model="text" label="Data">
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
      <q-input dense class="col margin1" v-model="text" label="Valor"
        ><template v-slot:prepend>
          <q-icon name="attach_money" class="cursor-pointer"></q-icon>
        </template>
      </q-input>
      <q-input
        dense
        class="col margin1"
        v-model="text"
        label="Histórico Financeiro"
        ><template v-slot:prepend>
          <q-icon name="history" class="cursor-pointer"></q-icon>
        </template>
      </q-input>
      <q-input dense class="col margin1" v-model="text" label="Complemento"
        ><template v-slot:prepend>
          <q-icon name="description" class="cursor-pointer"></q-icon>
        </template>
      </q-input>
    </div>
    <div class="row">
      <q-input dense class="col margin1" v-model="text" label="Observação"
        ><template v-slot:prepend>
          <q-icon name="visibility" class="cursor-pointer"></q-icon>
        </template>
      </q-input>
      <q-select
        dense
        class="margin1 col"
        v-model="tipo_documento"
        :options="dataset_lookup_tipo_documento"
        option-value="cd_tipo_documento"
        option-label="nm_tipo_documento"
        label="Tipo de Documento"
        @input="OnTipoDocumento()"
        ><template v-slot:prepend>
          <q-icon name="format_list_bulleted" class="cursor-pointer"></q-icon>
        </template>
      </q-select>
    </div>
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
import Lookup from "../http/lookup";
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
      load: false,
      text: "",
      tipo_documento: "",
      dt_picker_retorno: 0,
      dataset_lookup_tipo_documento: [],
    };
  },
  async created() {
    this.dataset_lookup_tipo_documento = await Lookup.montarSelect(
      localStorage.cd_empresa,
      187
    );
    this.dataset_lookup_tipo_documento = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_tipo_documento.dataset))
    );
    this.dataset_lookup_tipo_documento = this.dataset_lookup_tipo_documento.filter(
      (e) => {
        return (
          e.cd_tipo_documento == 1 ||
          //e.cd_tipo_documento == 3 ||
          e.cd_tipo_documento == 5 ||
          e.cd_tipo_documento == 13 ||
          e.cd_tipo_documento == 16 ||
          e.cd_tipo_documento == 17 ||
          e.cd_tipo_documento == 18 ||
          e.cd_tipo_documento == 22 ||
          e.cd_tipo_documento == 27
        );
      }
    );
  },
  methods: { DataRetorno() {} },
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
