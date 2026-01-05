<template>
  <div>
    <div class="row q-col-gutter-sm items-center">
      <q-input filled v-model="dtIni" type="date" label="Data Inicial" class="col-3"/>
      <q-input filled v-model="dtFim" type="date" label="Data Final" class="col-3"/>
      <q-btn color="deep-purple-7" label="Carregar" @click="carregar" class="col-auto"/>
      <div class="col"></div>
      <div class="col-auto">
        <q-badge color="red" :label="rows.length" />
      </div>
    </div>

    <div class="row q-col-gutter-md q-mt-md">
      <div class="col-3">
        <q-card><q-card-section>
          <div class="text-caption">Receita Líquida</div>
          <div class="text-h6">{{ kpi.vl_liquido | moeda }}</div>
        </q-card-section></q-card>
      </div>

      <div class="col-3">
        <q-card><q-card-section>
          <div class="text-caption">Litros</div>
          <div class="text-h6">{{ kpi.litros.toFixed(2) }}</div>
        </q-card-section></q-card>
      </div>

      <div class="col-3">
        <q-card><q-card-section>
          <div class="text-caption">Clientes Ativos</div>
          <div class="text-h6">{{ kpi.clientes }}</div>
        </q-card-section></q-card>
      </div>

      <div class="col-3">
        <q-card><q-card-section>
          <div class="text-caption">Ticket Médio</div>
          <div class="text-h6">{{ kpi.ticket | moeda }}</div>
        </q-card-section></q-card>
      </div>
    </div>

    <div class="q-mt-md">
      <!-- Chart (DevExtreme) -->
      <dx-chart :data-source="seriePorDia" >
        <dx-series value-field="vl_liquido" argument-field="dt" type="line" />
        <dx-argument-axis argument-type="datetime" />
        <dx-tooltip :enabled="true"/>
      </dx-chart>
    </div>

    <div class="q-mt-md">
      <!-- Grid (DevExtreme) -->
      <dx-data-grid
        ref="grid"
        :data-source="rows"
        :show-borders="true"
        :column-auto-width="true"
        :hover-state-enabled="true"
      >
        <dx-group-panel :visible="true" />
        <dx-search-panel :visible="true" />
        <dx-filter-row :visible="true" />
        <dx-paging :page-size="25" />
        <dx-pager :show-page-size-selector="true" :allowed-page-sizes="[25,50,100]" />

        <dx-column data-field="dt_faturamento" data-type="date" caption="Data" />
        <dx-column data-field="nm_cliente" caption="Cliente" />
        <dx-column data-field="nm_canal" caption="Canal" />
        <dx-column data-field="nm_produto" caption="Produto" />
        <dx-column data-field="litros" data-type="number" caption="Litros" format="#,##0.00" />
        <dx-column data-field="vl_liquido" data-type="number" caption="R$ Líquido" format="currency" />
        <dx-column data-field="nm_vendedor" caption="Vendedor" />
      </dx-data-grid>
    </div>
  </div>
</template>

<script>
import { DxDataGrid, DxColumn, DxPaging, DxPager, DxFilterRow, DxSearchPanel, DxGroupPanel } from "devextreme-vue/data-grid";
import { DxChart, DxSeries, DxArgumentAxis, DxTooltip } from "devextreme-vue/chart";
import { loadBi } from "@/services/biService";

export default {
  name: "DashboardVendas",
  components: {
    DxDataGrid, DxColumn, DxPaging, DxPager, DxFilterRow, DxSearchPanel, DxGroupPanel,
    DxChart, DxSeries, DxArgumentAxis, DxTooltip
  },
  props: {
    cd_empresa: { type: Number, required: true },
    cd_segmento: { type: Number, required: true }
  },
  data() {
    const hoje = new Date();
    const dtFim = hoje.toISOString().slice(0,10);
    const dtIni = new Date(hoje.getFullYear(), hoje.getMonth(), 1).toISOString().slice(0,10);

    return {
      dtIni,
      dtFim,
      rows: [],
      loading: false
    };
  },
  computed: {
    kpi() {
      const rows = this.rows || [];
      const vl = rows.reduce((a,r) => a + (Number(r.vl_liquido)||0), 0);
      const litros = rows.reduce((a,r) => a + (Number(r.litros)||0), 0);
      const clientes = new Set(rows.map(r => r.cd_cliente)).size;
      const ticket = clientes > 0 ? (vl / clientes) : 0;
      return { vl_liquido: vl, litros, clientes, ticket };
    },
    seriePorDia() {
      // agrega por dia
      const map = new Map();
      for (const r of (this.rows || [])) {
        const k = String(r.dt_faturamento).slice(0,10);
        map.set(k, (map.get(k) || 0) + (Number(r.vl_liquido)||0));
      }
      return [...map.entries()].map(([k, v]) => ({ dt: new Date(k), vl_liquido: v }))
                              .sort((a,b)=>a.dt-b.dt);
    }
  },
  methods: {
    async carregar() {
      this.loading = true;
      try {
        this.rows = await loadBi("pr_bi_fato_vendas", {
          cd_empresa: this.cd_empresa,
          cd_segmento: this.cd_segmento,
          dtIni: new Date(this.dtIni),
          dtFim: new Date(this.dtFim),
        });
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    moeda(v) {
      const n = Number(v)||0;
      return n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
    }
  },
  mounted() {
    this.carregar();
  }
};
</script>
