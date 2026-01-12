<template>
  <div class="q-pa-md">
<div class="q-pa-md">
    <!-- HEADER (padrão unicoFormEspecial) -->
    <h2 class="content-block row items-center no-wrap toolbar-scroll">
      <q-btn
        flat round dense
        icon="arrow_back"
        class="q-mr-sm seta-form"
        aria-label="Voltar"
        @click="$router.back()"
      />

      <span class="q-mr-sm">
        Proposta Comercial
      </span>

      <q-chip
        dense rounded
        color="deep-purple-7"
        size="16px"
        text-color="white"
        class="q-ml-sm"
        :label="cd_consultaLabel"
      >
        <q-tooltip>cd_consulta</q-tooltip>
      </q-chip>

      <q-space />

      <q-chip dense outline color="cyan-7" text-color="cyan-10" class="q-mr-sm">
        Etapa {{ etapaAtual }}
      </q-chip>

      <q-btn
        no-caps
        color="cyan-7"
        icon="print"
        label="Salvar em PDF / Imprimir"
        @click="imprimir"
      />
    </h2>

    <div class="row q-col-gutter-md">
      <!-- Coluna esquerda: Wizard -->
      <div class="col-12 col-lg-5">
        <q-card flat bordered class="q-pa-md">
          <div class="row items-center q-mb-md">
            <div>
              <div class="text-subtitle1 text-weight-bold">Processo</div>
              <div class="text-caption text-grey-7">
                Procedure: <b>pr_egis_proposta_processo_modulo</b> (JSON via cd_parametro 2..8)
              </div>
            </div>
            <q-space />
            <q-btn
              dense outline
              color="deep-purple-7"
              icon="refresh"
              label="Init (0)"
              :loading="loading"
              @click="initProc"
            />
          </div>

          <q-separator class="q-mb-md" />

          <q-stepper v-model="etapaAtual" color="deep-purple-7" animated flat>
            <!-- 2) Dados do Cliente -->
            <q-step :name="2" title="Dados do Cliente" icon="person" :done="etapaAtual > 2">
              <div class="q-gutter-sm">
                <q-input v-model="consulta.cd_cliente" type="number" label="cd_cliente" dense outlined />
                <q-input v-model="consulta.dt_consulta" label="dt_consulta (YYYY-MM-DD)" dense outlined />
                <q-input v-model="consulta.dt_validade_consulta" label="dt_validade_consulta (YYYY-MM-DD)" dense outlined />

                <q-input v-model="consulta.cd_vendedor" type="number" label="cd_vendedor" dense outlined />
                <q-input v-model="consulta.cd_condicao_pagamento" type="number" label="cd_condicao_pagamento" dense outlined />

                <q-input
                  v-model="consulta.ds_observacao_consulta"
                  type="textarea"
                  label="Observações"
                  dense
                  outlined
                  autogrow
                />
              </div>

              <div class="row justify-between q-gutter-sm q-mt-md">
                <q-btn outline color="deep-purple-7" label="Executar (2)" :loading="loading" @click="executar(2)" />
                <q-btn color="deep-purple-7" label="Próximo" @click="etapaAtual = 3" />
              </div>
            </q-step>

            <!-- 3) Produto -->
            <q-step :name="3" title="Produto" icon="inventory_2" :done="etapaAtual > 3">
              <ProdutoStep ref="prodStep" v-model="itensProdutos" />

              <div class="row justify-between q-gutter-sm q-mt-md">
                <q-btn outline color="deep-purple-7" label="Voltar" @click="etapaAtual = 2" />
                <div class="row q-gutter-sm">
                  <q-btn outline color="deep-purple-7" label="Executar (3)" :loading="loading" @click="executar(3)" />
                  <q-btn color="deep-purple-7" label="Próximo" @click="etapaAtual = 4" />
                </div>
              </div>
            </q-step>

            <!-- 4) Serviço -->
            <q-step :name="4" title="Serviço" icon="handyman" :done="etapaAtual > 4">
              <ServicoStep ref="servStep" v-model="itensServicos" />

              <div class="row justify-between q-gutter-sm q-mt-md">
                <q-btn outline color="deep-purple-7" label="Voltar" @click="etapaAtual = 3" />
                <div class="row q-gutter-sm">
                  <q-btn outline color="deep-purple-7" label="Executar (4)" :loading="loading" @click="executar(4)" />
                  <q-btn color="deep-purple-7" label="Próximo" @click="etapaAtual = 5" />
                </div>
              </div>
            </q-step>

            <!-- 5) Insert/Update -->
            <q-step :name="5" title="Insert / Update" icon="save" :done="etapaAtual > 5">
              <div class="text-body2">
                Confirme e salve a proposta via <b>cd_parametro=5</b>.
              </div>

              <div class="q-mt-sm">
                <q-list bordered separator>
                  <q-item>
                    <q-item-section>
                      <q-item-label>Total produtos</q-item-label>
                      <q-item-label caption>{{ brl(totalProdutos) }} ({{ itensProdutos.length }} item(ns))</q-item-label>
                    </q-item-section>
                  </q-item>
                  <q-item>
                    <q-item-section>
                      <q-item-label>Total serviços</q-item-label>
                      <q-item-label caption>{{ brl(totalServicos) }} ({{ itensServicos.length }} item(ns))</q-item-label>
                    </q-item-section>
                  </q-item>
                  <q-item>
                    <q-item-section>
                      <q-item-label class="text-weight-bold">Total geral</q-item-label>
                      <q-item-label caption class="text-weight-bold">{{ brl(totalGeral) }}</q-item-label>
                    </q-item-section>
                  </q-item>
                </q-list>

                <div class="text-caption text-grey-7 q-mt-sm">
                  *No modo genérico, o total é calculado somando <b>vl_total</b> dos itens.
                </div>
              </div>

              <div class="row justify-between q-gutter-sm q-mt-md">
                <q-btn outline color="deep-purple-7" label="Voltar" @click="etapaAtual = 4" />
                <div class="row q-gutter-sm">
                  <q-btn outline color="deep-purple-7" label="Executar (5)" :loading="loading" @click="salvar" />
                  <q-btn color="cyan-7" icon="check" label="Salvar e avançar" :loading="loading" @click="salvar(true)" />
                </div>
              </div>
            </q-step>

            <!-- 6) Cancelamento -->
            <q-step :name="6" title="Cancelamento" icon="cancel" :done="etapaAtual > 6">
              <div class="text-body2">
                Cancela a proposta via <b>cd_parametro=6</b>.
              </div>
              <div class="row justify-between q-gutter-sm q-mt-md">
                <q-btn outline color="deep-purple-7" label="Voltar" @click="etapaAtual = 5" />
                <q-btn color="deep-orange-6" label="Cancelar" :disable="!hasConsulta" :loading="loading" @click="cancelar" />
              </div>
            </q-step>

            <!-- 7) Perda -->
            <q-step :name="7" title="Perda" icon="block" :done="etapaAtual > 7">
              <div class="text-body2">
                Marca como perda via <b>cd_parametro=7</b>.
              </div>
              <div class="row justify-between q-gutter-sm q-mt-md">
                <q-btn outline color="deep-purple-7" label="Voltar" @click="etapaAtual = 6" />
                <q-btn color="deep-orange-6" label="Marcar perda" :disable="!hasConsulta" :loading="loading" @click="perda" />
              </div>
            </q-step>

            <!-- 8) Outros -->
            <q-step :name="8" title="Outros" icon="more_horiz">
              <div class="text-body2">
                Executa ações extras via <b>cd_parametro=8</b>.
              </div>
              <div class="row justify-between q-gutter-sm q-mt-md">
                <q-btn outline color="deep-purple-7" label="Voltar" @click="etapaAtual = 7" />
                <q-btn color="cyan-7" label="Executar" :disable="!hasConsulta" :loading="loading" @click="outros" />
              </div>
            </q-step>
          </q-stepper>

          <q-separator class="q-mt-md q-mb-sm" />

          <div class="text-caption text-grey-7">
            Payload enviado como <b>Array[0]</b> com <b>dados_modal</b> e <b>dados_registro</b> (compatível com seu SQL).
          </div>
        </q-card>
      </div>

      <!-- Coluna direita: Preview -->
      <div class="col-12 col-lg-7">
        <q-card flat bordered class="q-pa-md">
          <div class="row items-center">
            <div class="text-subtitle1 text-weight-bold">Preview PDF</div>
            <q-space />
            <q-chip dense outline color="deep-purple-7" text-color="deep-purple-10">
              Tema 3 • Executive Blueprint
            </q-chip>
          </div>

          <div class="q-mt-md">
            <PropostaPreviewTema3 :consulta="consulta" :itens="itensAll" />
          </div>
        </q-card>
      </div>
    </div>
  </div>
  </div>
  
</template>

<script>
import { executarParametro } from "@/services/propostaService";

import ProdutoStep from "@/components/proposta/ProdutoStep.vue";
import ServicoStep from "@/components/proposta/ServicoStep.vue";
import PropostaPreviewTema3 from "@/components/proposta/PropostaPreviewTema3.vue";

export default {
  name: "PropostaComercial",
  components: { ProdutoStep, ServicoStep, PropostaPreviewTema3 },

  data() {
    return {
      etapaAtual: 2,
      loading: false,

      // Cabeçalho (consulta)
      consulta: {
        cd_consulta: 0,
        dt_consulta: null,
        cd_cliente: null,
        cd_vendedor: null,
        cd_condicao_pagamento: null,
        ds_observacao_consulta: "",
        dt_validade_consulta: null,

        // campos “genéricos” para cálculo/preview
        vl_total_consulta: 0,
        pc_desconto_consulta: 0
      },

      // Itens (genérico)
      itensProdutos: [],
      itensServicos: []
    };
  },


  watch: {
  etapaAtual(val) {
    this.$nextTick(() => {
      try {
        if (val === 3) {
          const grid = this.$refs?.prodStep?.$refs?.grid?.instance;
          if (grid) grid.updateDimensions();
        }
        if (val === 4) {
          const grid = this.$refs?.servStep?.$refs?.grid?.instance;
          if (grid) grid.updateDimensions();
        }
      } catch (e) {
        console.log("updateDimensions error:", e);
      }
    });
  }
},

  computed: {
    hasConsulta() {
      return Number(this.consulta.cd_consulta || 0) > 0;
    },
    cd_consultaLabel() {
      return this.hasConsulta ? String(this.consulta.cd_consulta) : "NOVO";
    },
    itensAll() {
      return [...(this.itensProdutos || []), ...(this.itensServicos || [])];
    },
    totalProdutos() {
      return this.sumBy(this.itensProdutos, "vl_total");
    },
    totalServicos() {
      return this.sumBy(this.itensServicos, "vl_total");
    },
    totalGeral() {
      return Number((this.totalProdutos + this.totalServicos).toFixed(2));
    }
  },

  methods: {
    imprimir() {
      window.print();
    },

    brl(v) {
      const n = Number(v || 0);
      return new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(n);
    },

    sumBy(arr, key) {
      return Number((arr || []).reduce((acc, x) => acc + Number(x?.[key] || 0), 0).toFixed(2));
    },

    montarDadosRegistro() {
      // header da consulta (primeiro elemento) + itens
      const header = {
        cd_consulta: Number(this.consulta.cd_consulta || 0),
        dt_consulta: this.consulta.dt_consulta,
        cd_cliente: this.consulta.cd_cliente,
        cd_vendedor: this.consulta.cd_vendedor,
        cd_condicao_pagamento: this.consulta.cd_condicao_pagamento,
        ds_observacao_consulta: this.consulta.ds_observacao_consulta,
        dt_validade_consulta: this.consulta.dt_validade_consulta,

        vl_total_consulta: this.totalGeral,
        pc_desconto_consulta: Number(this.consulta.pc_desconto_consulta || 0)
      };

      const prod = (this.itensProdutos || []).map((it, idx) => ({
        nr_linha: idx + 1,
        ...it,
        tp_item: "PROD"
      }));

      const serv = (this.itensServicos || []).map((it, idx) => ({
        nr_linha: 1000 + idx + 1,
        ...it,
        tp_item: "SERV"
      }));

      return [header, ...prod, ...serv];
    },

    montarDadosModal() {
      // casa com o exemplo do seu SQL (cd_parametro=1) e dá base para os outros
      return {
        nm_vendedor: String(this.consulta.cd_vendedor || ""),
        nm_condicao_pagamento: String(this.consulta.cd_condicao_pagamento || ""),
        dt_alteracao: new Date().toISOString().slice(0, 10)
      };
    },

    async initProc() {
      this.loading = true;
      try {
        const rows = await executarParametro({
          cd_parametro: 0,
          dados_modal: {},
          dados_registro: []
        });
        console.log("init rows:", rows);
        this.$q.notify({ type: "info", message: "Init executado (cd_parametro=0)." });
      } catch (e) {
        console.error(e);
        this.$q.notify({ type: "negative", message: "Erro no Init (0)." });
      } finally {
        this.loading = false;
      }
    },

    async executar(cd_parametro) {
      this.loading = true;
      try {
        const rows = await executarParametro({
          cd_parametro,
          dados_modal: this.montarDadosModal(),
          dados_registro: this.montarDadosRegistro()
        });
        console.log("exec rows:", cd_parametro, rows);
        this.$q.notify({ type: "positive", message: `Executado cd_parametro=${cd_parametro}.` });
      } catch (e) {
        console.error(e);
        this.$q.notify({ type: "negative", message: `Erro ao executar cd_parametro=${cd_parametro}.` });
      } finally {
        this.loading = false;
      }
    },

    async salvar(avancar = false) {
      this.loading = true;
      try {
        const rows = await executarParametro({
          cd_parametro: 5,
          dados_modal: this.montarDadosModal(),
          dados_registro: this.montarDadosRegistro()
        });

        // Quando seu SQL do parâmetro 5 retornar cd_consulta, pegamos aqui.
        const first = rows?.[0] || null;
        if (first?.cd_consulta) this.consulta.cd_consulta = Number(first.cd_consulta);

        this.$q.notify({ type: "positive", message: "Proposta salva com sucesso." });
        if (avancar) this.etapaAtual = 6;
      } catch (e) {
        console.error(e);
        this.$q.notify({ type: "negative", message: "Erro ao salvar (cd_parametro=5)." });
      } finally {
        this.loading = false;
      }
    },

    async cancelar() {
      this.loading = true;
      try {
        await executarParametro({
          cd_parametro: 6,
          dados_modal: {},
          dados_registro: [{ cd_consulta: Number(this.consulta.cd_consulta || 0) }]
        });
        this.$q.notify({ type: "warning", message: "Proposta cancelada." });
      } catch (e) {
        console.error(e);
        this.$q.notify({ type: "negative", message: "Erro ao cancelar (cd_parametro=6)." });
      } finally {
        this.loading = false;
      }
    },

    async perda() {
      this.loading = true;
      try {
        await executarParametro({
          cd_parametro: 7,
          dados_modal: {},
          dados_registro: [{ cd_consulta: Number(this.consulta.cd_consulta || 0) }]
        });
        this.$q.notify({ type: "warning", message: "Proposta marcada como perda." });
      } catch (e) {
        console.error(e);
        this.$q.notify({ type: "negative", message: "Erro ao marcar perda (cd_parametro=7)." });
      } finally {
        this.loading = false;
      }
    },

    async outros() {
      this.loading = true;
      try {
        await executarParametro({
          cd_parametro: 8,
          dados_modal: {},
          dados_registro: [{ cd_consulta: Number(this.consulta.cd_consulta || 0) }]
        });
        this.$q.notify({ type: "info", message: "Ação executada (cd_parametro=8)." });
      } catch (e) {
        console.error(e);
        this.$q.notify({ type: "negative", message: "Erro ao executar outros (cd_parametro=8)." });
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
/* padrão do unicoFormEspecial.vue */
.seta-form {
  margin-left: 10px;
  color: #512da8; /* deep-purple-7 */
}

/* opcional: no print, esconder a coluna wizard e imprimir só o preview */
@media print {
  .toolbar-scroll,
  .q-stepper,
  .q-btn,
  .q-chip:not(.print-keep) {
    display: none !important;
  }
}
</style>
