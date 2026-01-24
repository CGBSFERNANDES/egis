<template>
  <unico-form-especial
    :cd_menu_entrada="8906"
    :cd_acesso_entrada="cdAcesso"
    modo_inicial="GRID"
    :overrides="overrides"
    :hooks="hooks"
    @selecionou="onSelecionou"
  >
    <template #form-custom>
      <div class="q-pa-sm">
        <q-tabs
          v-model="abaAtiva"
          dense
          align="left"
          class="text-deep-purple-7 q-mb-sm"
          active-color="deep-purple-7"
          indicator-color="deep-orange-7"
        >
          <q-tab name="despesas" icon="receipt_long" label="Despesas" />
        </q-tabs>

        <q-separator class="q-mb-sm" />

        <q-tab-panels v-model="abaAtiva" animated>
          <q-tab-panel name="despesas" class="q-pa-none">
            <div class="row items-center q-gutter-sm q-mb-sm">
              <q-banner dense class="bg-grey-2 text-grey-9 rounded-borders">
                <div class="text-caption">
                  Lote selecionado: <b>{{ cdLoteSelecionado || "-" }}</b>
                </div>
              </q-banner>

              <q-btn
                dense
                color="deep-purple-7"
                icon="table_view"
                label="Lançamentos"
                :disable="!cdLoteSelecionado"
                @click="abrirLancamentos"
              />
            </div>

            <q-inner-loading :showing="carregandoDespesas">
              <q-spinner size="40px" color="deep-purple-7" />
            </q-inner-loading>

            <DxDataGrid
              v-if="despesasRows.length"
              :data-source="despesasRows"
              :show-borders="true"
              :column-auto-width="true"
              :height="480"
            >
              <DxSearchPanel :visible="true" />
              <DxPaging :page-size="20" />
              <DxPager
                :show-page-size-selector="true"
                :allowed-page-sizes="[10, 20, 50, 100]"
                :show-info="true"
              />
              <DxColumn
                v-for="col in despesasColumns"
                :key="col.dataField"
                :data-field="col.dataField"
                :caption="col.caption"
                :data-type="col.dataType"
                :format="col.format"
                :visible="col.visible"
                :width="col.width"
                :alignment="col.alignment"
              />
            </DxDataGrid>

            <q-banner
              v-else-if="!carregandoDespesas"
              class="bg-orange-1 text-orange-10 rounded-borders"
            >
              Nenhuma despesa encontrada para o registro selecionado.
            </q-banner>
          </q-tab-panel>
        </q-tab-panels>
      </div>
    </template>

    <q-dialog v-model="modalLancamentos" maximized>
      <q-card class="q-pa-md">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Lançamentos Contábeis</div>
          <q-space />
          <q-btn
            flat
            round
            dense
            icon="close"
            @click="modalLancamentos = false"
          />
        </q-card-section>

        <q-separator class="q-mb-sm" />

        <q-card-section class="q-pa-none">
          <q-inner-loading :showing="carregandoLancamentos">
            <q-spinner size="40px" color="deep-purple-7" />
          </q-inner-loading>

          <DxDataGrid
            v-if="lancamentosRows.length"
            :data-source="lancamentosRows"
            :show-borders="true"
            :column-auto-width="true"
            :height="600"
          >
            <DxSearchPanel :visible="true" />
            <DxPaging :page-size="20" />
            <DxPager
              :show-page-size-selector="true"
              :allowed-page-sizes="[10, 20, 50, 100]"
              :show-info="true"
            />
            <DxColumn
              v-for="col in lancamentosColumns"
              :key="col.dataField"
              :data-field="col.dataField"
              :caption="col.caption"
              :data-type="col.dataType"
              :format="col.format"
              :visible="col.visible"
              :width="col.width"
              :alignment="col.alignment"
            />
          </DxDataGrid>

          <q-banner
            v-else-if="!carregandoLancamentos"
            class="bg-orange-1 text-orange-10 rounded-borders"
          >
            Nenhum lançamento contábil disponível para o lote selecionado.
          </q-banner>
        </q-card-section>
      </q-card>
    </q-dialog>
  </unico-form-especial>
</template>

<script>
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue";
import { execProcedure, buildColumnsFromData } from "@/services";
import {
  DxDataGrid,
  DxColumn,
  DxSearchPanel,
  DxPager,
  DxPaging,
} from "devextreme-vue/data-grid";

export default {
  name: "my_8906",
  components: {
    UnicoFormEspecial,
    DxDataGrid,
    DxColumn,
    DxSearchPanel,
    DxPager,
    DxPaging,
  },
  data() {
    return {
      cdAcesso: Number(localStorage.cd_chave_pesquisa || 0),
      cdEmpresa: Number(localStorage.cd_empresa || 0),
      abaAtiva: "despesas",
      cdLoteSelecionado: 0,
      cdNotaDebitoSelecionada: 0,
      despesasRows: [],
      despesasColumns: [],
      carregandoDespesas: false,
      modalLancamentos: false,
      lancamentosRows: [],
      lancamentosColumns: [],
      carregandoLancamentos: false,
      overrides: {
        title: "Nota Débito",
        gridPageSize: 200,
      },
      hooks: {
        mapPayload: async ({ payload }) => {
          const cd_lote = Number(this.cdLoteSelecionado || 0);
          return {
            ...payload,
            cd_empresa: this.cdEmpresa,
            ...(cd_lote ? { cd_lote } : {}),
          };
        },
      },
    };
  },
  methods: {
    normalizeRows(resp) {
      if (!resp) return [];
      if (resp.dados)
        return Array.isArray(resp.dados) ? resp.dados : [resp.dados];
      if (resp.recordset) return resp.recordset;
      if (resp.rows) return resp.rows;
      return Array.isArray(resp) ? resp : [resp];
    },
    resolveNotaDebito(registro) {
      return Number(
        registro?.cd_nota_debito_despesa ||
          registro?.cd_nota_debito ||
          registro?.cd_chave_pesquisa ||
          0
      );
    },
    async carregarDespesas() {
      if (!this.cdNotaDebitoSelecionada) {
        this.despesasRows = [];
        this.despesasColumns = [];
        return;
      }

      this.carregandoDespesas = true;
      try {
        const payload = [
          {
            ic_json_parametro: "S",
            cd_parametro: 50,
            cd_nota_debito_despesa: this.cdNotaDebitoSelecionada,
          },
        ];

        const resp = await execProcedure(
          "pr_egis_servicos_processo_modulo",
          payload
        );
        const rows = this.normalizeRows(resp);
        this.despesasRows = rows;
        this.despesasColumns = await buildColumnsFromData(rows, {
          cd_tabela: 0,
          cd_parametro: 1,
        });
      } catch (err) {
        console.error("Erro ao carregar despesas:", err);
        this.despesasRows = [];
        this.despesasColumns = [];
      } finally {
        this.carregandoDespesas = false;
      }
    },
    async carregarLancamentos() {
      if (!this.cdLoteSelecionado) {
        this.lancamentosRows = [];
        this.lancamentosColumns = [];
        return;
      }

      this.carregandoLancamentos = true;
      try {
        const payload = [
          {
            ic_json_parametro: "S",
            cd_parametro: 2,
            cd_empresa: this.cdEmpresa,
            cd_lote: this.cdLoteSelecionado,
          },
        ];

        const resp = await execProcedure(
          "pr_egis_contabilidade_processo_modulo",
          payload
        );
        const rows = this.normalizeRows(resp);
        this.lancamentosRows = rows;
        this.lancamentosColumns = await buildColumnsFromData(rows, {
          cd_tabela: 0,
          cd_parametro: 1,
        });
      } catch (err) {
        console.error("Erro ao carregar lançamentos:", err);
        this.lancamentosRows = [];
        this.lancamentosColumns = [];
      } finally {
        this.carregandoLancamentos = false;
      }
    },
    onSelecionou(registro) {
      this.cdLoteSelecionado = Number(registro?.cd_lote || 0);
      this.cdNotaDebitoSelecionada = this.resolveNotaDebito(registro);
      this.carregarDespesas();
      if (this.cdLoteSelecionado) this.abrirLancamentos();
    },
    async abrirLancamentos() {
      if (!this.cdLoteSelecionado) return;
      this.modalLancamentos = true;
      await this.carregarLancamentos();
    },
  },
};
</script>
