<template>
  <div>
    <!-- Funcionalidades  
    Contas a Pagar
    Contas a Receber
    Movimento Bancário
    Movimento Caixa
    Controle de Aplicação Financeira
    ---------------------------------------------------
    API Dólar
    Movimento Diário/Semanal/Anual/Mensal
    Plano Financeiro
    Orçamento
    DRE
    Produtos
    Recebimento de Materiais
    Compras / Requisição de Compras
     -->
    <div class="text-h6 text-bold margin1 ">
      {{ "Lançamento Financeiro" }}
    </div>
    <div class="row">
      <q-select
        dense
        class="margin1 col"
        v-model="tipo_lancamento"
        :options="dataset_lookup_tipo_lancamento"
        option-value="cd_tipo_lancamento"
        option-label="nm_tipo_lancamento"
        label="Tipo de Lançamento"
        @input="OnTipoLancamento(tipo_lancamento)"
      >
        <template v-slot:prepend>
          <q-icon name="format_list_bulleted" class="cursor-pointer"></q-icon>
        </template>
      </q-select>
      <q-select
        dense
        class="margin1 col"
        v-model="tipo_destinatario"
        :options="dataset_lookup_tipo_destinatario"
        option-value="cd_tipo_destinatario"
        option-label="nm_tipo_destinatario"
        label="Destinatário"
        @input="PopUpPesquisaDestinatario = true"
      >
        <template v-slot:prepend>
          <q-icon name="person" class="cursor-pointer"></q-icon>
        </template>
      </q-select>
    </div>
    <transition name="slide-fade">
      <div v-if="destinatario">
        <q-expansion-item
          class="margin1"
          expand-separator
          icon="person"
          label="Destinatário selecionado"
          :caption="nm_destinatario"
        >
          <q-card>
            <q-card-section>
              <div v-for="(n, index) in destinatario" :key="index">
                <div class="row">
                  <q-input
                    class="col-6"
                    readonly
                    :label="
                      index
                        .slice(3)
                        .replaceAll('_', ' ')
                        .toString()
                    "
                  />
                  <q-input class="col-6" readonly :label="n.toString()" />
                </div>
              </div>
            </q-card-section>
          </q-card>
        </q-expansion-item>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="PopUpPesquisaDestinatario">
        <pesquisaDestinatario
          @DbClickDestinatario="OnClickDestinatario($event)"
          :cd_tipo_pesquisaID="
            tipo_destinatario.cd_tipo_destinatario <= 4
              ? tipo_destinatario.cd_tipo_destinatario
              : 0
          "
        />
      </div>
    </transition>
    <!-- TIPOS DE LANÇAMENTO -->
    <transition name="slide-fade">
      <div
        class="margin1 borda-bloco shadow-2"
        v-if="tipo_lancamento.cd_tipo_lancamento == 1"
      >
        <conta-pagar :ic_ativa_btn="false" />
      </div>
    </transition>
    <transition name="slide-fade">
      <div
        class="margin1 borda-bloco shadow-2"
        v-if="tipo_lancamento.cd_tipo_lancamento == 2"
      >
        <conta-receber :ic_ativa_btn="false" />
      </div>
    </transition>
    <transition name="slide-fade">
      <div
        class="margin1 borda-bloco shadow-2"
        v-if="tipo_lancamento.cd_tipo_lancamento == 6"
      >
        <caixinha :ic_ativa_btn="false" />
      </div>
    </transition>
    <transition name="slide-fade">
      <div
        class="margin1 borda-bloco shadow-2"
        v-if="tipo_lancamento.cd_tipo_lancamento == 5"
      >
        <movimento-bancario :ic_ativa_btn="false" />
      </div>
    </transition>
    <transition name="slide-fade">
      <div
        class="margin1 borda-bloco shadow-2"
        v-if="tipo_lancamento.cd_tipo_lancamento == 9"
      >
        <investimento :ic_ativa_btn="false" />
      </div>
    </transition>
    <transition name="slide-fade">
      <div
        class="margin1 borda-bloco shadow-2"
        v-if="tipo_lancamento.cd_tipo_lancamento == 10"
      >
        <div class="margin1 titulo-bloco">Transferência entre Contas</div>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="tipo_lancamento == ''" class="margin1 titulo-vazio">
        {{ `Lançamento não selecionado` }}
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="tipo_lancamento != ''">
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
//import Incluir from "../http/incluir_registro";

export default {
  props: {
    cd_tipo_lancamento: { type: Number, default: 0 },
  },
  watch: {},
  components: {
    carregando: () => import("../components/carregando.vue"),
    pesquisaDestinatario: () => import("./pesquisaDestinatario.vue"),
    investimento: () => import("./investimento.vue"),
    movimentoBancario: () => import("./movimentoBancario.vue"),
    Caixinha: () => import("./Caixinha.vue"),
    contaPagar: () => import("./contaPagar.vue"),
    contaReceber: () => import("./contaReceber.vue"),
  },
  data() {
    return {
      load: false,
      tipo_lancamento: "",
      dataset_lookup_tipo_lancamento: [],
      grupo_financeiro: "",
      dataset_lookup_grupo_financeiro: [],
      tipo_documento: "",
      dataset_lookup_tipo_documento: [],
      tipo_destinatario: "",
      PopUpPesquisaDestinatario: false,
      dataset_lookup_tipo_destinatario: [],
      cd_id_documento: "",
      cd_num_documento: "",
      cd_tipo_documento: "",
      nm_tipo_documento: "",
      cd_item_nota_fiscal: "",
      cd_serie_nota_fiscal: "",
      qt_parcelas: "",
      nm_parcelas: "",
      cd_conta: "",
      destinatario: false,
      nm_destinatario: "",
    };
  },

  async created() {
    this.load = true;
    this.dataset_lookup_tipo_lancamento = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5295
    );
    this.dataset_lookup_tipo_lancamento = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_tipo_lancamento.dataset))
    );
    this.dataset_lookup_tipo_lancamento = this.dataset_lookup_tipo_lancamento.filter(
      (e) => {
        return (
          e.cd_tipo_lancamento == 1 ||
          e.cd_tipo_lancamento == 2 ||
          e.cd_tipo_lancamento == 5 ||
          e.cd_tipo_lancamento == 6 ||
          e.cd_tipo_lancamento == 9 //||
          //e.cd_tipo_lancamento == 10
        );
      }
    );
    ////////////////////////////////////////////////
    this.dataset_lookup_grupo_financeiro = await Lookup.montarSelect(
      localStorage.cd_empresa,
      413
    );
    this.dataset_lookup_grupo_financeiro = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_grupo_financeiro.dataset))
    );
    ////////////////////////////////////////////////
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
    ////////////////////////////////////////////////
    this.dataset_lookup_tipo_destinatario = await Lookup.montarSelect(
      localStorage.cd_empresa,
      660
    );
    this.dataset_lookup_tipo_destinatario = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_tipo_destinatario.dataset))
    );
    this.dataset_lookup_tipo_destinatario = this.dataset_lookup_tipo_destinatario.filter(
      (e) => {
        return (
          e.cd_tipo_destinatario == 1 ||
          e.cd_tipo_destinatario == 2 ||
          e.cd_tipo_destinatario == 3 ||
          e.cd_tipo_destinatario == 4
        );
      }
    );
    this.load = false;
  },
  methods: {
    async OnTipoLancamento() {
      // var consulta_item = {
      //   cd_tipo_lancamento: item.cd_tipo_lancamento,
      //   cd_parametro: 1,
      // };
      // let result_item = await Incluir.incluirRegistro(
      //   "810/1272",
      //   consulta_item
      // ); //pr_egisnet_lancamento_financeiro
      // console.log(result_item, "LANÇAMENTO SELECIONADO RESULT");

      if (
        this.tipo_destinatario == "" &&
        !!this.destinatario == false &&
        this.tipo_lancamento.cd_tipo_destinatario != undefined &&
        this.tipo_lancamento.cd_tipo_destinatario <= 4
      ) {
        this.tipo_destinatario = this.dataset_lookup_tipo_destinatario.find(
          (e) => {
            return (
              e.cd_tipo_destinatario ==
              this.tipo_lancamento.cd_tipo_destinatario
            );
          }
        );
        this.PopUpPesquisaDestinatario = true;
      }
    },

    OnClickDestinatario(e) {
      this.destinatario = e;
      this.PopUpPesquisaDestinatario = false;
      Object.keys(e).forEach((obj, index) => {
        if (obj.includes("nm_fantasia")) {
          this.nm_destinatario = Object.values(e)[index];
        }
      });
    },

    OnLimpar() {
      this.tipo_lancamento = "";
      this.grupo_financeiro = "";
      this.tipo_documento = "";
      this.tipo_destinatario = "";
      this.cd_id_documento = "";
      this.cd_num_documento = "";
      this.cd_tipo_documento = "";
      this.nm_tipo_documento = "";
      this.cd_item_nota_fiscal = "";
      this.cd_serie_nota_fiscal = "";
      this.qt_parcelas = "";
      this.nm_parcelas = "";
      this.cd_conta = "";
      this.PopUpPesquisaDestinatario = false;
      this.destinatario = false;
      this.nm_destinatario = "";
    },
    OnTipoDocumento() {
      this.nm_tipo_documento = this.tipo_documento.nm_tipo_documento;
    },
  },
};
</script>

<style scoped>
@import "./views.css";

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
.titulo-vazio {
  display: flex;
  justify-content: center;
  font-weight: bold;
  font-size: larger;
}
</style>
