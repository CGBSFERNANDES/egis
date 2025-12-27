<template>
  <div>
    <div class="text-h6 text-bold margin1">
      {{ "Lançamento Financeiro Automático" }}
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
          <!-- <q-card>
            <q-card-section>
              <div v-for="(n, index) in destinatario" :key="index">
                <div class="row">
                  <q-input class="col-6" readonly :label="index" />
                  <q-input class="col-6" readonly :label="n" />
                </div>
              </div>
            </q-card-section>
          </q-card> -->
        </q-expansion-item>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="PopUpPesquisaDestinatario">
        <q-btn
          class="margin1"
          round
          color="red"
          icon="close"
          @click="(PopUpPesquisaDestinatario = false), (tipo_destinatario = '')"
        >
          <q-tooltip class="bg-accent">Fechar</q-tooltip>
        </q-btn>
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
    <!-- INFORMAÇÕES EM COMUM -->
    <q-input class="margin1" v-model="cd_identificacao" label="Identificação">
      <template v-slot:prepend>
        <q-icon name="description" class="cursor-pointer"></q-icon>
      </template>
    </q-input>
    <q-input
      class="col margin1"
      v-model="dt_emissao"
      mask="##/##/####"
      label="Data de Emissão"
      @blur="DataEmissao(dt_emissao)"
    >
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
              v-model="dt_picker_emissao"
              @input="DataEmissao(dt_picker_emissao)"
              class="qdate"
            >
            </q-date>
          </q-popup-proxy>
        </q-btn>
      </template>
      <template v-slot:prepend>
        <q-icon name="today" class="cursor-pointer"></q-icon>
      </template>
    </q-input>
    <q-input
      class="margin1"
      type="number"
      min="0"
      v-model="qt_parcelas"
      label="Qtd. Parcelas"
    >
      <template v-slot:prepend>
        <q-icon name="list" class="cursor-pointer"></q-icon>
      </template>
    </q-input>
    <q-input
      class="margin1"
      v-model="vl_lancamento"
      @blur="onValorLancamento()"
      label="Valor"
    >
      <template v-slot:prepend>
        <q-icon name="attach_money" class="cursor-pointer"></q-icon>
      </template>
    </q-input>

    <q-select
      class="margin1 col"
      v-model="plano_financeiro"
      :options="dataset_lookup_plano_financeiro"
      option-value="cd_plano_financeiro"
      option-label="nm_conta_plano_financeiro"
      label="Plano Financeiro"
    >
      <template v-slot:prepend>
        <q-icon name="folder" class="cursor-pointer"></q-icon>
      </template>
    </q-select>

    <q-select
      class="margin1 col"
      v-model="centro_custo"
      :options="dataset_lookup_centro_custo"
      option-value="cd_centro_custo"
      option-label="nm_centro_custo"
      label="Centro de custo"
    >
      <template v-slot:prepend>
        <q-icon name="folder" class="cursor-pointer"></q-icon>
      </template>
    </q-select>

    <q-input class="margin1" v-model="nm_obs" label="Observação">
      <template v-slot:prepend>
        <q-icon name="visibility" class="cursor-pointer"></q-icon>
      </template>
    </q-input>
    <!-- TIPOS DE LANÇAMENTO -->
    <!-- <transition name="slide-fade">
      <div
        class="margin1 borda-bloco shadow-2"
        v-if="tipo_lancamento.cd_tipo_lancamento == 1"
      >
        {{ "Conta Pagar" }}
      </div>
    </transition> -->
    <transition name="slide-fade">
      <div
        class="margin1 borda-bloco shadow-2"
        v-if="tipo_lancamento.cd_tipo_lancamento == 2"
      >
        <div class="row">
          <q-input
            class="col margin1"
            v-model="dt_vencimento"
            mask="##/##/####"
            label="Data de Vencimento"
            @blur="DataVencimento(dt_vencimento)"
          >
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
                    v-model="dt_picker"
                    @input="DataVencimento(dt_picker)"
                    class="qdate"
                  >
                  </q-date>
                </q-popup-proxy>
              </q-btn>
            </template>
            <template v-slot:prepend>
              <q-icon name="today" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-select
            class="margin1 col"
            v-model="portador"
            :options="dataset_lookup_portador"
            option-value="cd_portador"
            option-label="nm_portador"
            label="Portador"
          >
            <template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-select>
          <q-select
            class="margin1 col"
            v-model="tipo_cobranca"
            :options="dataset_lookup_tipo_cobranca"
            option-value="cd_tipo_cobranca"
            option-label="nm_tipo_cobranca"
            label="Tipo de Cobrança"
          >
            <template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-select>
        </div>
        <div class="row">
          <q-select
            class="margin1 col"
            v-model="tipo_documento"
            :options="dataset_lookup_tipo_documento"
            option-value="cd_tipo_documento"
            option-label="nm_tipo_documento"
            label="Tipo de Documento"
          >
            <template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-select>
          <q-input
            class="margin1 col"
            v-model="vl_saldo"
            @blur="onValorSaldo()"
            label="Saldo"
          >
            <template v-slot:prepend>
              <q-icon name="attach_money" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
      </div>
    </transition>
    <transition name="slide-fade">
      <div
        class="margin1 borda-bloco shadow-2"
        v-if="tipo_lancamento.cd_tipo_lancamento == 6"
      >
        <div class="row">
          <div class="col margin1">
            {{ "Saída" }}
            <q-toggle
              v-model="cd_tipo_operacao"
              true-value="2"
              false-value="1"
              color="orange-9"
            />
            {{ "Entrada" }}
          </div>
          <q-select
            class="margin1 col"
            v-model="tipo_caixa"
            :options="dataset_lookup_tipo_caixa"
            option-value="cd_tipo_caixa"
            option-label="nm_tipo_caixa"
            label="Tipo de Caixa"
          >
            <template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-select>
        </div>
      </div>
    </transition>
    <transition name="slide-fade">
      <div
        class="margin1 borda-bloco shadow-2"
        v-if="tipo_lancamento.cd_tipo_lancamento == 5"
      >
        <div class="row">
          <q-select
            dense
            class="margin1 col"
            v-model="banco"
            :options="dataset_lookup_banco"
            option-value="cd_banco"
            option-label="nm_banco"
            label="Banco"
          >
            <template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-select>
          <q-select
            dense
            class="margin1 col"
            v-model="agencia"
            :options="dataset_lookup_agencia"
            option-value="cd_agencia_banco"
            option-label="nm_agencia_banco"
            label="Agência"
          >
            <template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-select>
          <q-select
            dense
            class="margin1 col"
            v-model="conta"
            :options="dataset_lookup_conta"
            option-value="cd_conta_banco"
            option-label="nm_conta_banco"
            label="Conta"
          >
            <template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-select>
          <div class="margin1">
            {{ "Saída" }}
            <q-toggle
              v-model="cd_tipo_operacao"
              true-value="2"
              false-value="1"
              color="orange-9"
            />
            {{ "Entrada" }}
          </div>
        </div>
      </div>
    </transition>
    <transition name="slide-fade">
      <div
        class="margin1 borda-bloco shadow-2"
        v-if="tipo_lancamento.cd_tipo_lancamento == 9"
      >
        <div class="row">
          <q-select
            dense
            class="margin1 col"
            v-model="banco"
            :options="dataset_lookup_banco"
            option-value="cd_banco"
            option-label="nm_banco"
            label="Banco"
          >
            <template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-select>
          <q-select
            dense
            class="margin1 col"
            v-model="agencia"
            :options="dataset_lookup_agencia"
            option-value="cd_agencia_banco"
            option-label="nm_agencia_banco"
            label="Agência"
          >
            <template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-select>
          <q-select
            dense
            class="margin1 col"
            v-model="conta"
            :options="dataset_lookup_conta"
            option-value="cd_conta_banco"
            option-label="nm_conta_banco"
            label="Conta"
          >
            <template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-select>
        </div>
        <div class="row">
          <q-select
            dense
            class="margin1 col"
            v-model="tipo_aplicacao_finan"
            :options="dataset_lookup_tipo_aplicacao_finan"
            option-value="cd_tipo_aplicacao_finan"
            option-label="nm_tipo_aplicacao_finan"
            label="Tipo Aplicação Financeira"
          >
            <template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-select>
        </div>
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
    <div>
      <q-btn
        rounded
        color="orange-9"
        icon="save"
        label="Salvar"
        class="margin1"
        @click="onSalvar()"
      >
        <q-tooltip> Salvar </q-tooltip>
      </q-btn>
      <q-btn
        rounded
        flat
        color="orange-9"
        icon="cleaning_services"
        style="float: right"
        label="Limpar"
        class="margin1"
        @click="OnLimpar()"
      >
        <q-tooltip> Limpar </q-tooltip>
      </q-btn>
    </div>
    <q-dialog v-model="load" maximized persistent>
      <carregando />
    </q-dialog>
  </div>
</template>

<script>
import Lookup from "../http/lookup";
import funcao from "../http/funcoes-padroes";
import Incluir from "../http/incluir_registro";
import formatadata from "../http/formataData.js";
import notify from "devextreme/ui/notify";

export default {
  props: {
    cd_tipo_lancamento: { type: Number, default: 0 },
  },
  watch: {},
  components: {
    carregando: () => import("../components/carregando.vue"),
    pesquisaDestinatario: () => import("./pesquisaDestinatario.vue"),
  },
  data() {
    return {
      load: false,
      tipo_lancamento: "",
      dataset_lookup_tipo_lancamento: [],
      plano_financeiro: "",
      dataset_lookup_plano_financeiro: [],
      centro_custo: "",
      dataset_lookup_centro_custo: [],
      tipo_destinatario: "",
      PopUpPesquisaDestinatario: false,
      dataset_lookup_tipo_destinatario: [],
      cd_documento: "",
      cd_identificacao: "",
      qt_parcelas: "",
      cd_conta: "",
      destinatario: false,
      nm_destinatario: "",
      dt_emissao: "",
      dt_vencimento: "",
      dt_picker: "",
      dt_picker_emissao: "",
      vl_lancamento: "",
      vl_saldo: "",
      nm_obs: "",
      banco: "",
      dataset_lookup_banco: [],
      agencia: "",
      dataset_lookup_agencia: [],
      conta: "",
      dataset_lookup_conta: [],
      tipo_caixa: "",
      dataset_lookup_tipo_caixa: [],
      portador: "",
      dataset_lookup_portador: [],
      tipo_documento: "",
      dataset_lookup_tipo_documento: [],
      tipo_cobranca: "",
      dataset_lookup_tipo_cobranca: [],
      cd_tipo_operacao: "1",
      tipo_aplicacao_finan: "",
      dataset_lookup_tipo_aplicacao_finan: [],
      cd_usuario: "",
    };
  },

  async created() {
    this.cd_usuario = localStorage.cd_usuario;
    this.load = true;
    this.dataset_lookup_tipo_lancamento = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5295
    );
    this.dataset_lookup_tipo_lancamento = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_tipo_lancamento.dataset))
    );
    this.dataset_lookup_tipo_lancamento =
      this.dataset_lookup_tipo_lancamento.filter((e) => {
        return (
          e.cd_tipo_lancamento == 1 ||
          e.cd_tipo_lancamento == 2 ||
          e.cd_tipo_lancamento == 5 ||
          e.cd_tipo_lancamento == 6 ||
          e.cd_tipo_lancamento == 9
        );
      });
    ////////////////////////////////////////////////
    this.dataset_lookup_plano_financeiro = await Lookup.montarSelect(
      localStorage.cd_empresa,
      414
    );
    this.dataset_lookup_plano_financeiro = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_plano_financeiro.dataset))
    );
    ////////////////////////////////////////////////
    this.dataset_lookup_centro_custo = await Lookup.montarSelect(
      localStorage.cd_empresa,
      305
    );
    this.dataset_lookup_centro_custo = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_centro_custo.dataset))
    );
    ////////////////////////////////////////////////
    this.dataset_lookup_tipo_destinatario = await Lookup.montarSelect(
      localStorage.cd_empresa,
      660
    );
    this.dataset_lookup_tipo_destinatario = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_tipo_destinatario.dataset))
    );
    this.dataset_lookup_tipo_destinatario =
      this.dataset_lookup_tipo_destinatario.filter((e) => {
        return (
          e.cd_tipo_destinatario == 1 ||
          e.cd_tipo_destinatario == 2 ||
          e.cd_tipo_destinatario == 3 ||
          e.cd_tipo_destinatario == 4 ||
          e.cd_tipo_destinatario == 9
        );
      });
    ////////////////////////////////////////////////
    this.dataset_lookup_banco = await Lookup.montarSelect(
      localStorage.cd_empresa,
      135
    );
    this.dataset_lookup_banco = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_banco.dataset))
    );
    ////////////////////////////////////////////////
    this.dataset_lookup_agencia = await Lookup.montarSelect(
      localStorage.cd_empresa,
      195
    );
    this.dataset_lookup_agencia = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_agencia.dataset))
    );
    ////////////////////////////////////////////////
    this.dataset_lookup_conta = await Lookup.montarSelect(
      localStorage.cd_empresa,
      291
    );
    this.dataset_lookup_conta = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_conta.dataset))
    );
    ////////////////////////////////////////////////
    this.dataset_lookup_tipo_caixa = await Lookup.montarSelect(
      localStorage.cd_empresa,
      409
    );
    this.dataset_lookup_tipo_caixa = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_tipo_caixa.dataset))
    );
    ////////////////////////////////////////////////
    this.dataset_lookup_portador = await Lookup.montarSelect(
      localStorage.cd_empresa,
      188
    );
    this.dataset_lookup_portador = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_portador.dataset))
    );
    ////////////////////////////////////////////////
    this.dataset_lookup_tipo_cobranca = await Lookup.montarSelect(
      localStorage.cd_empresa,
      186
    );
    this.dataset_lookup_tipo_cobranca = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_tipo_cobranca.dataset))
    );
    ////////////////////////////////////////////////
    this.dataset_lookup_tipo_documento = await Lookup.montarSelect(
      localStorage.cd_empresa,
      187
    );
    this.dataset_lookup_tipo_documento = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_tipo_documento.dataset))
    );
    ////////////////////////////////////////////////
    this.dataset_lookup_tipo_aplicacao_finan = await Lookup.montarSelect(
      localStorage.cd_empresa,
      1355
    );
    this.dataset_lookup_tipo_aplicacao_finan = JSON.parse(
      JSON.parse(
        JSON.stringify(this.dataset_lookup_tipo_aplicacao_finan.dataset)
      )
    );
    this.load = false;
  },
  methods: {
    async OnTipoLancamento() {
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
      this.tipo_destinatario = "";
      this.cd_documento = "";
      this.cd_identificacao = "";
      this.qt_parcelas = "";
      this.conta = "";
      this.PopUpPesquisaDestinatario = false;
      this.destinatario = false;
      this.nm_destinatario = "";
      this.plano_financeiro = "";
      this.centro_custo = "";
      this.cd_conta = "";
      this.dt_emissao = "";
      this.dt_vencimento = "";
      this.dt_picker = "";
      this.dt_picker_emissao = "";
      this.vl_lancamento = "";
      this.vl_saldo = "";
      this.nm_obs = "";
      this.banco = "";
      this.agencia = "";
      this.conta = "";
      this.tipo_caixa = "";
      this.portador = "";
      this.tipo_documento = "";
      this.tipo_cobranca = "";
      this.cd_tipo_operacao = "1";
      this.tipo_aplicacao_finan = "";
    },
    async onValorLancamento() {
      this.vl_lancamento = await funcao.FormataValor(this.vl_lancamento);
    },
    async onValorSaldo() {
      this.vl_saldo = await funcao.FormataValor(this.vl_saldo);
    },
    async DataVencimento(dt_picker_retorno) {
      if (dt_picker_retorno.indexOf("/") == 2) {
        //Inserido no input
        if (funcao.checarData(dt_picker_retorno)) {
          var ano2 = dt_picker_retorno.substring(6, 10);
          var mes2 = dt_picker_retorno.substring(3, 5);
          var dia2 = dt_picker_retorno.substring(0, 2);
          this.dt_picker = parseInt(ano2) + "/" + mes2 + "/" + dia2;
        }
      } else {
        //Inserido no Data Picker
        this.dt_picker = dt_picker_retorno;
        var ano = dt_picker_retorno.substring(0, 4);
        var mes = dt_picker_retorno.substring(5, 7);
        var dia = dt_picker_retorno.substring(8, 10);
        this.dt_vencimento = dia + mes + ano;
      }
    },
    async DataEmissao(dt_picker_retorno) {
      if (dt_picker_retorno.indexOf("/") == 2) {
        //Inserido no input
        if (funcao.checarData(dt_picker_retorno)) {
          var ano2 = dt_picker_retorno.substring(6, 10);
          var mes2 = dt_picker_retorno.substring(3, 5);
          var dia2 = dt_picker_retorno.substring(0, 2);
          this.dt_picker = parseInt(ano2) + "/" + mes2 + "/" + dia2;
        }
      } else {
        //Inserido no Data Picker
        this.dt_picker_emissao = dt_picker_retorno;
        var ano = dt_picker_retorno.substring(0, 4);
        var mes = dt_picker_retorno.substring(5, 7);
        var dia = dt_picker_retorno.substring(8, 10);
        this.dt_emissao = dia + mes + ano;
      }
    },
    async onSalvar() {
      if (!this.tipo_lancamento.cd_tipo_lancamento) {
        return notify("Selecione um tipo de lançamento");
      }
      if (!!this.cd_identificacao === false) {
        return notify("Por favor digite a Identificação");
      }
      try {
        this.load = true;

        this.dt_vencimento = await formatadata.formataDataSQL(
          this.dt_vencimento
        );
        this.dt_emissao = await formatadata.formataDataSQL(this.dt_emissao);
        const financeiro_object = {
          cd_tipo_lancamento: this.tipo_lancamento.cd_tipo_lancamento,
          cd_documento: this.documento,
          cd_identificacao: this.cd_identificacao,
          cd_cliente: this.destinatario.cd_cliente,
          dt_emissao: this.dt_emissao,
          dt_vencimento: this.dt_vencimento,
          vl_documento:
            !!this.vl_lancamento == true
              ? this.vl_lancamento
                  .replace("R$", "")
                  .replace(".", "")
                  .replace(",", ".")
              : "0",
          vl_saldo:
            !!this.vl_saldo == true
              ? this.vl_saldo
                  .replace("R$", "")
                  .replace(".", "")
                  .replace(",", ".")
              : "0",
          cd_portador: this.portador.cd_portador,
          cd_tipo_cobranca: this.tipo_cobranca.cd_tipo_cobranca,
          cd_tipo_documento: this.tipo_documento.cd_tipo_documento,
          nm_obs: this.nm_obs,
          cd_usuario: this.cd_usuario,
          cd_plano_financeiro: this.plano_financeiro.cd_plano_financeiro,
          cd_centro_custo: this.centro_custo.cd_centro_custo,
          cd_tipo_destinatario: this.tipo_destinatario.cd_tipo_destinatario,
          cd_conta_banco: this.conta.cd_conta_banco,
          cd_banco: this.banco.cd_banco,
          cd_tipo_operacao: this.cd_tipo_operacao,
          cd_tipo_caixa: this.tipo_caixa.cd_tipo_caixa,
          cd_tipo_aplicacao_finan:
            this.tipo_aplicacao_finan.cd_tipo_aplicacao_finan,
        };
        let result_save = await Incluir.incluirRegistro(
          "811/1273", //pr_egisnet_lancamento_financeiro_automatico
          financeiro_object
        );
        notify(result_save[0].Msg);
        await this.OnLimpar();
      } catch (error) {
        console.error(error);
      } finally {
        this.load = false;
      }
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
