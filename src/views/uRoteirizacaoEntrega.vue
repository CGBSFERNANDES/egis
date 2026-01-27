<template>
  <div class="q-pa-md">
    <div class="row items-center q-col-gutter-md">
      <div class="col-12 col-sm-3">
        <q-input
          filled
          dense
          v-model="dtEntrega"
          label="Data de Entrega"
          mask="##/##/####"
          placeholder="DD/MM/AAAA"
        >
          <template v-slot:append>
            <q-icon name="event" class="cursor-pointer">
              <q-popup-proxy transition-show="scale" transition-hide="scale">
                <!-- Mantém DD/MM/YYYY no v-model -->
                <q-date v-model="dtEntrega" mask="DD/MM/YYYY" />
              </q-popup-proxy>
            </q-icon>
          </template>
        </q-input>
      </div>

      <div class="col-12 col-sm-9">
        <q-btn
          color="primary"
          label="Consultar"
          class="q-mr-sm"
          :loading="loadingMaster"
          @click="consultar"
        />
        <q-btn
          color="secondary"
          label="Atualizar Roteiro"
          :loading="loadingMaster"
          @click="consultar"
        />

        <span class="q-ml-md text-caption">
          Itinerários: {{ roteiros.length }}
        </span>
      </div>
    </div>

    <q-separator class="q-my-md" />

    <q-splitter
      v-model="split"
      style="height: calc(100vh - 210px);"
      separator-class="bg-grey-4"
    >
      <!-- LISTA (cards) -->
      <template v-slot:before>
        <div class="q-pa-sm" style="height:100%;">
          <div
            class="row q-col-gutter-md"
            style="height:100%; align-content:flex-start;"
          >
            <div
              v-for="r in roteiros"
              :key="r.cd_roteiro"
              class="col-12 col-md-4"
            >
              <q-card
                bordered
                class="fit"
                :class="
                  selected && selected.cd_roteiro === r.cd_roteiro
                    ? 'bg-blue-1'
                    : ''
                "
              >
                <q-card-section class="q-pb-sm">
                  <div class="text-subtitle2">
                    {{ r.nm_itinerario || "Roteiro " + r.cd_roteiro }}
                  </div>
                  <div class="text-caption">
                    Roteiro: <b>{{ r.cd_roteiro }}</b> — Romaneio:
                    {{ r.cd_romaneio }}<br />
                    Veículo: {{ r.nm_veiculo || "-" }}<br />
                    Entregador: {{ r.nm_entregador || "-" }}<br />
                    Entregas: {{ r.qt_entrega }} | Clientes: {{ r.qt_cliente }}
                  </div>
                </q-card-section>

                <q-separator />

                <!-- Resumo pivotado: Cliente x Produtos (colunas dinâmicas) -->
                <q-card-section class="q-pa-none">
                  <DxDataGrid
                    :data-source="r._pivotRows"
                    :show-borders="true"
                    :column-auto-width="true"
                    :row-alternation-enabled="true"
                    :hover-state-enabled="true"
                    :height="260"
                    @row-click="e => onCardRowClick(r, e)"
                  >
                    <DxColumn
                      data-field="cliente"
                      caption="Cliente"
                      :min-width="180"
                    />

                    <DxColumn
                      v-for="p in r._pivotColumns"
                      :key="p"
                      :data-field="p"
                      :caption="p"
                      data-type="number"
                      alignment="right"
                      format="#,##0"
                      :width="110"
                    />

                    <DxColumn
                      data-field="Total"
                      caption="Total"
                      data-type="number"
                      alignment="right"
                      format="#,##0"
                      :width="110"
                    />

                    <DxSummary>
                      <DxTotalItem
                        v-for="p in [...r._pivotColumns, 'Total']"
                        :key="p"
                        :column="p"
                        summary-type="sum"
                        value-format="#,##0"
                        :display-format="p + ': {0}'"
                      />
                    </DxSummary>
                  </DxDataGrid>
                </q-card-section>

                <q-separator />

                <q-card-actions align="right">
                  <q-btn
                    dense
                    flat
                    color="primary"
                    label="Selecionar"
                    @click="selecionarRoteiro(r)"
                  />
                </q-card-actions>
              </q-card>
            </div>
          </div>
        </div>
      </template>

      <!-- DETALHE (itens do roteiro selecionado) -->
      <template v-slot:after>
        <div class="q-pa-sm" style="height:100%;">
          <q-card bordered class="fit">
            <q-card-section class="q-pb-sm">
              <div class="text-subtitle2">Detalhe do Itinerário</div>
              <div class="text-caption">
                <span v-if="selected">
                  {{ selected.nm_itinerario }} — Roteiro
                  <b>{{ selected.cd_roteiro }}</b>
                </span>
                <span v-else>Selecione um itinerário na esquerda.</span>
              </div>
            </q-card-section>

            <q-separator />

            <q-card-section class="q-pa-none">
              <div v-if="!selected" class="q-pa-md text-caption">
                Nenhum itinerário selecionado.
              </div>

              <DxDataGrid
                v-if="selected"
                :data-source="detailRows"
                :show-borders="true"
                :column-auto-width="true"
                :row-alternation-enabled="true"
                :hover-state-enabled="true"
                :height="520"
                key-expr="cd_controle"
              >
                <DxColumn
                  v-for="c in detailColumns"
                  :key="c.dataField"
                  :data-field="c.dataField"
                  :caption="c.caption"
                  :data-type="c.dataType"
                  :format="c.format"
                  :alignment="c.alignment"
                  :width="c.width"
                />

                <DxSummary v-if="detailSummaryItems.length">
                  <DxTotalItem
                    v-for="s in detailSummaryItems"
                    :key="s.column"
                    :column="s.column"
                    :summary-type="s.summaryType"
                    :value-format="s.valueFormat"
                    :display-format="s.displayFormat"
                  />
                </DxSummary>
              </DxDataGrid>
            </q-card-section>
          </q-card>
        </div>
      </template>
    </q-splitter>
  </div>
</template>

<script>
import axios from "axios";
import DxDataGrid, {
  DxColumn,
  DxSummary,
  DxTotalItem,
} from "devextreme-vue/data-grid";

const bancoInicial = localStorage.nm_banco_empresa;

const api = axios.create({
  baseURL: "https://egiserp.com.br/api",
  withCredentials: true,
  timeout: 60000,
  headers: { "Content-Type": "application/json", "x-banco": bancoInicial },
});

api.interceptors.request.use(function(cfg) {
  const banco = localStorage.nm_banco_empresa || "";
  if (banco) cfg.headers["x-banco"] = banco;
  cfg.headers["Authorization"] = "Bearer superchave123";
  return cfg;
});

export default {
  name: "uRoteirizacaoEntrega",
  components: { DxDataGrid, DxColumn, DxSummary, DxTotalItem },

  data() {
    return {
      split: 70,

      // ✅ INPUT DD/MM/YYYY
      dtEntrega: "26/01/2026",

      loadingMaster: false,
      roteiros: [],
      selected: null,
      detailRows: [],

      hiddenFields: { sel: true },
    };
  },

  computed: {
    detailColumns() {
      return this.buildColumnsFromRows(this.detailRows);
    },
    detailSummaryItems() {
      const cols = this.detailColumns || [];
      const list = [];
      for (const c of cols) {
        const df = String(c.dataField || "").toLowerCase();
        if (
          c.dataType === "number" &&
          (df.startsWith("qt_") || df.includes("qtd") || df.includes("quant"))
        ) {
          list.push({
            column: c.dataField,
            summaryType: "sum",
            valueFormat: c.format || "#,##0",
            displayFormat: c.caption + ": {0}",
          });
        }
      }
      return list;
    },
  },

  mounted() {
    this.consultar();
  },

  methods: {
    // ✅ converte DD/MM/YYYY -> MM-DD-YYYY (o backend usa isso)
    dtEntregaApi() {
      const s = (this.dtEntrega || "").trim();
      const parts = s.split("/");
      if (parts.length !== 3) return "";
      const [dd, mm, yyyy] = parts;
      if (!dd || !mm || !yyyy) return "";
      return `${mm}-${dd}-${yyyy}`;
    },

    normalizeRows(raw) {
      let data = raw;
      if (typeof data === "string") {
        try {
          data = JSON.parse(data);
        } catch (e) {}
      }
      if (data && typeof data === "object" && !Array.isArray(data)) {
        if (Array.isArray(data.data)) data = data.data;
        else if (Array.isArray(data.rows)) data = data.rows;
        else if (Array.isArray(data.result)) data = data.result;
        else if (Array.isArray(data.resultset)) data = data.resultset;
      }
      if (!Array.isArray(data)) return [];

      const out = [];
      for (const row of data) {
        if (!row || typeof row !== "object") continue;
        const isStatus = "sucesso" in row && "codigo" in row;
        const hasBiz =
          "cd_roteiro" in row || "cd_controle" in row || "nm_itinerario" in row;
        if (isStatus && !hasBiz) continue;
        out.push(row);
      }
      return out;
    },

    async consultar() {
      this.loadingMaster = true;
      this.roteiros = [];
      this.selected = null;
      this.detailRows = [];

      try {
        const dt = this.dtEntregaApi();

        // ✅ PARAM 1: lista de roteiros
        const payload1 = [
          {
            cd_parametro: 1,
            dt_inicial: dt,
            dt_final: dt,
            ic_json_parametro: "S",
            ic_modal_pesquisa: "N",
          },
        ];

        const resp1 = await api.post(
          "/exec/pr_egis_logistica_processo_modulo",
          payload1
        );
        const rows1 = this.normalizeRows(resp1.data);

        this.roteiros = rows1.map(r => ({
          ...r,
          _itens: [],
          _pivotRows: [],
          _pivotColumns: [],
        }));

        // ✅ PARAM 2: carregar itens de cada roteiro + pivot dinâmico (Cliente x Produto)
        await Promise.all(this.roteiros.map(r => this.carregarParam2EPivot(r)));

        if (this.roteiros.length) this.selecionarRoteiro(this.roteiros[0]);
      } catch (err) {
        console.error(err);
        this.$q.notify({
          type: "negative",
          message: err && err.message ? err.message : "Erro ao consultar.",
        });
      } finally {
        this.loadingMaster = false;
      }
    },

    async carregarParam2EPivot(roteiro) {
      const dt = this.dtEntregaApi();

      const payload2 = [
        {
          cd_parametro: 2,
          dt_inicial: dt,
          dt_final: dt,
          cd_roteiro: roteiro.cd_roteiro,
          ic_json_parametro: "S",
          ic_modal_pesquisa: "N",
        },
      ];

      const resp2 = await api.post(
        "/exec/pr_egis_logistica_processo_modulo",
        payload2
      );
      const all = this.normalizeRows(resp2.data);

      // filtra por cd_roteiro (se vier “misturado”)
      const itens = all
        .filter(x => String(x.cd_roteiro) === String(roteiro.cd_roteiro))
        .map(x => {
          const y = { ...x };
          if (this.hiddenFields.sel) delete y.sel;
          return y;
        });

      roteiro._itens = itens;

      const pivot = this.pivotClientesProdutos(itens);
      roteiro._pivotRows = pivot.rows;
      roteiro._pivotColumns = pivot.columns;
    },

    // ✅ Monta colunas dinamicas por produto (CAIXA_20, CAIXA_40, etc)
    pivotClientesProdutos(itens) {
      if (!itens || !itens.length) return { rows: [], columns: [] };

      // detecta campos prováveis (cliente/produto/qtde)
      const sample = itens[0];
      const keys = Object.keys(sample).map(k => k.toLowerCase());

      const pickKey = cands => {
        for (const c of cands) {
          const idx = keys.indexOf(c);
          if (idx >= 0) return Object.keys(sample)[idx];
        }
        return null;
      };

      const kCliente =
        pickKey([
          "nm_fantasia_cliente",
          "nm_cliente",
          "cliente",
          "razao_social",
          "nm_fantasia",
        ]) || "nm_fantasia_cliente";
      const kProduto =
        pickKey([
          "produto",
          "nm_produto",
          "ds_produto",
          "nm_item",
          "ds_item",
          "cd_produto",
        ]) || "produto";
      const kQtd =
        pickKey([
          "qtd",
          "qt",
          "qt_caixa",
          "qt_item",
          "qt_produto",
          "quantidade",
        ]) || "qt_caixa";

      // coletar produtos
      const prodSet = new Set();
      for (const it of itens) {
        const p = (it[kProduto] ?? "").toString().trim();
        if (p) prodSet.add(p);
      }
      const columns = Array.from(prodSet).sort();

      // agrupar por cliente
      const mapCli = new Map();
      for (const it of itens) {
        const cli =
          (it[kCliente] ?? "(Sem cliente)").toString().trim() ||
          "(Sem cliente)";
        const prod = (it[kProduto] ?? "").toString().trim();
        const qtd = Number(it[kQtd] ?? 0) || 0;

        if (!mapCli.has(cli)) mapCli.set(cli, {});
        const row = mapCli.get(cli);

        row.cliente = cli;
        row[prod] = (row[prod] || 0) + qtd;
      }

      // montar rows com Total + zerar colunas ausentes
      const rows = [];
      for (const [cli, row] of mapCli.entries()) {
        let total = 0;
        for (const p of columns) {
          row[p] = Number(row[p] || 0);
          total += row[p];
        }
        row.Total = total;
        rows.push(row);
      }

      // ordena por Total desc
      rows.sort((a, b) => (b.Total || 0) - (a.Total || 0));

      return { rows, columns };
    },

    // clique em uma linha do card (ou botão selecionar)
    onCardRowClick(roteiro /*, e */) {
      this.selecionarRoteiro(roteiro);
    },

    selecionarRoteiro(r) {
      this.selected = r;
      this.detailRows = r && r._itens ? r._itens : [];
    },

    buildColumnsFromRows(rows) {
      if (!rows || !rows.length) return [];

      const first = rows[0];
      const keys = Object.keys(first);

      const cols = [];
      for (const k of keys) {
        if (this.hiddenFields[k]) continue;

        let sample = null;
        for (const rr of rows) {
          if (rr && rr[k] !== null && rr[k] !== undefined) {
            sample = rr[k];
            break;
          }
        }

        const isNumeric =
          typeof sample === "number" ||
          (typeof sample === "string" &&
            sample.trim() !== "" &&
            !isNaN(Number(sample)));

        const dataType = isNumeric ? "number" : "string";
        const lower = String(k).toLowerCase();

        let format;
        if (dataType === "number") format = "#,##0";

        cols.push({
          dataField: k,
          caption: this.humanize(k),
          dataType,
          alignment: dataType === "number" ? "right" : "left",
          format,
          width: this.suggestWidth(k),
        });
      }

      return cols;
    },

    humanize(s) {
      return String(s)
        .split("_")
        .join(" ")
        .replace(/\b\w/g, m => m.toUpperCase());
    },

    suggestWidth(field) {
      const f = String(field).toLowerCase();
      if (f === "cd_controle") return 90;
      if (f.startsWith("cd_")) return 110;
      if (f.startsWith("qt_") || f.includes("qtd") || f.includes("quant"))
        return 120;
      if (f.startsWith("nm_") || f.includes("fantasia") >= 0) return 260;
      return undefined;
    },
  },
};
</script>

<style scoped>
.bg-blue-1 {
  border: 1px solid rgba(25, 118, 210, 0.35);
}
</style>
