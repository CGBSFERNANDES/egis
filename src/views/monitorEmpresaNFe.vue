<template>
  <div class="q-pa-md">
    <!-- Topo / Título -->
    <div class="row items-center q-col-gutter-sm">
      <div class="col">
        <div class="row items-center no-wrap">

          <!-- seta voltar (igual unicoFormEspecial) -->
      <q-btn
        flat
        round
        dense
        icon="arrow_back"
        class="q-mr-sm seta-form"
        aria-label="Voltar"
        @click="onVoltar"
      />

          <div class="text-h6 text-weight-bold q-mr-sm">
            Monitor de Notas Fiscais de Empresa
          </div>

          <q-chip
            dense
            color="deep-purple-7"
            text-color="white"
            icon="menu"
            v-if="cd_menu"
          >
            {{ cd_menu }}
          </q-chip>

       <!-- Empresa selecionada -->

<div v-if="cardSelecionado" class="row items-center q-col-gutter-sm q-mt-sm">
  <div class="col-auto">

 <q-avatar size="56px" class="logo-destaque" v-if="cardSelecionado">
  <img
    v-if="cardSelecionado.logo"
    :src="cardSelecionado.logo"
    :alt="cardSelecionado.nm_fantasia_empresa || 'Logo'"
  />
  <q-icon v-else name="business" />
</q-avatar>

  </div>

  <div class="col">
    <div class="text-subtitle1 text-weight-bold">
      {{ cardSelecionado.nm_fantasia_empresa || cardSelecionado.nm_empresa }}
    </div>
    <div class="text-caption text-grey-7">
      <span v-if="cardSelecionado.cd_empresa">Empresa: {{ cardSelecionado.cd_empresa }}</span>
      <span v-if="cardSelecionado.nm_banco_empresa"> • Banco: {{ cardSelecionado.nm_banco_empresa }}</span>
      <span v-if="cardSelecionado.nm_versao_esquema_nfc"> • Versão: {{ cardSelecionado.nm_versao_esquema_nfc }}</span>
    </div>
  </div>

  <div class="col-auto">
  <div class="row q-col-gutter-lg items-end">
    <div class="col-auto">
      <div class="text-caption text-grey-7">Qtd. Notas (Hoje)</div>
      <div class="text-subtitle2 text-weight-bold text-deep-orange-6">
        {{ formatarInteiro(cardSelecionado.QtdNotasHoje) }}
      </div>
    </div>

    <div class="col-auto text-right">
      <div class="text-caption text-grey-7">Valor Total (Hoje)</div>
      <div class="text-subtitle2 text-weight-bold text-cyan-7 valor-direita">
        {{ formatarMoeda(cardSelecionado.VlTotalHoje) }}
      </div>
    </div>
  </div>
</div>

</div>


        </div>

       </div>

      <div class="col-auto">
        <q-btn
          rounded
          dense
          color="deep-purple-7"
          icon="refresh"
          label="Atualizar"
          :loading="loading"
          @click="carregarTudo"
        />
      </div>
    </div>

    <!-- Filtros mínimos (baseado no exemplo do backend com dt_inicial/dt_final) -->
    <div class="row q-col-gutter-md q-mt-md">
      <div class="col-12 col-sm-4">
        <q-input
          dense
          outlined
          v-model="dt_inicial"
          label="Data inicial"
          fill-mask
          placeholder="dd/mm/aaaa"
        />
      </div>
      <div class="col-12 col-sm-4">
        <q-input
          dense
          outlined
          v-model="dt_final"
          label="Data final"
          mask="##/##/####"
          fill-mask
          placeholder="dd/mm/aaaa"
        />
      </div>
      <div class="col-12 col-sm-4 flex items-center">
        <q-toggle
          v-model="exibirComoCards"
          color="deep-purple-7"
          checked-icon="view_module"
          unchecked-icon="view_list"
          :label="exibirComoCards ? 'cards' : 'grid'"
          keep-color
        />
      </div>
    </div>

    <!-- CARDS (entrada) -->
    <div class="q-mt-lg">
      <div v-if="exibirComoCards" class="cards-wrapper">
        <div
          v-for="(item, idx) in cards"
          :key="idx"
          class="monitor-card cursor-pointer"
          @click="selecionarCard(item)"
        >
          <!-- Sem inventar campos: mostra um resumo baseado nas chaves existentes -->
         <div class="row items-center no-wrap q-col-gutter-sm">
  <div class="col-auto">
  
  <q-avatar size="54px" class="logo-destaque">
  <img
    v-if="item && item.logo"
    :src="item.logo"
    :alt="item.nm_fantasia_empresa || 'Logo'"
  />
  <q-icon v-else name="business" />
</q-avatar>

  </div>

  <div class="col">
    <div class="text-weight-bold text-subtitle1 ellipsis">
      {{ item.nm_fantasia_empresa || item.nm_empresa || obterTituloCard(item) }}
    </div>

    <div class="text-caption text-grey-7 ellipsis">
      {{ item.nm_empresa || obterSubtituloCard(item) }}
    </div>
  </div>
</div>

<div class="row q-col-gutter-sm q-mt-sm items-end">
  <div class="col-6">
    <div class="text-caption text-grey-7">Qtd. Notas (Hoje)</div>
    <div class="text-subtitle2 text-weight-bold text-deep-orange-6">
      {{ formatarInteiro(item.QtdNotasHoje) }}
    </div>
  </div>

  <div class="col-6 text-right">
    <div class="text-caption text-grey-7">Valor Total (Hoje)</div>
    <div class="text-subtitle2 text-weight-bold text-cyan-7 valor-direita">
      {{ formatarMoeda(item.VlTotalHoje) }}
    </div>
  </div>
</div>

        </div>

        <div v-if="!loading && cards.length === 0" class="text-grey-7 q-mt-md">
          Nenhum dado para exibir.
        </div>
      </div>

      <!-- Opção: Grid único para os cards (quando toggle em grid) -->
      <div v-else>
        <dx-data-grid
          class="dx-card wide-card"
          :data-source="cards"
          :columns="columnsCards"
          :show-borders="true"
          :column-auto-width="true"
          :row-alternation-enabled="true"
          :allow-column-resizing="true"
          :allow-column-reordering="true"
          :word-wrap-enabled="false"
          @row-dbl-click="onDblClickCard"
        >
          <DxGroupPanel :visible="true" empty-panel-text="Colunas para agrupar..." />
          <DxGrouping :auto-expand-all="true" />
          <DxPaging :enabled="true" :page-size="10" />
          <DxPager
            :show-page-size-selector="true"
            :allowed-page-sizes="pageSizes"
            :show-info="true"
          />
          <DxHeaderFilter :visible="true" :allow-search="true" />
          <DxColumnChooser :enabled="true" mode="select" />
          <DxColumnFixing :enabled="true" />
        </dx-data-grid>
      </div>
    </div>

    <!-- GRIDS (logo abaixo dos cards) -->
    <div class="q-mt-xl">
      <div class="text-subtitle1 text-weight-bold q-mb-sm">
        Grids
      </div>

      <div v-if="loading" class="text-grey-7">Carregando...</div>

      <div v-if="!loading && grids.length === 0" class="text-grey-7">
        Nenhuma grid retornada.
      </div>

      <div v-for="(g, i) in grids" :key="'grid-' + i" class="q-mb-xl">
        <div class="row items-center q-mb-sm">
          <div class="text-weight-bold">
            {{ g.titulo || ('Grid ' + (i + 1)) }}
          </div>
          <q-space />
          <q-badge rounded color="deep-purple-7" :label="g.rows.length" />
        </div>

        <dx-data-grid
          class="dx-card wide-card"
          :data-source="g.rows"
          :columns="g.columns"
          :show-borders="true"
          :column-auto-width="true"
          :row-alternation-enabled="true"
          :allow-column-resizing="true"
          :allow-column-reordering="true"
          :word-wrap-enabled="false"
        >
          <DxGroupPanel :visible="true" empty-panel-text="Colunas para agrupar..." />
          <DxGrouping :auto-expand-all="true" />
          <DxPaging :enabled="true" :page-size="10" />
          <DxPager
            :show-page-size-selector="true"
            :allowed-page-sizes="pageSizes"
            :show-info="true"
          />
          <DxHeaderFilter :visible="true" :allow-search="true" />
          <DxSearchPanel :visible="true" :width="300" placeholder="Procurar..." />
          <DxColumnChooser :enabled="true" mode="select" />
          <DxColumnFixing :enabled="true" />
        </dx-data-grid>
      </div>
    </div>
  </div>
</template>

<script>
import api from "@/boot/axios";

import {
  DxDataGrid,
  DxGroupPanel,
  DxGrouping,
  DxPaging,
  DxPager,
  DxHeaderFilter,
  DxColumnChooser,
  DxColumnFixing,
  DxSearchPanel,
} from "devextreme-vue/data-grid";

const PROC = "/exec/pr_egis_nfe_monitor_processo";
const MAPA_PROC = "/exec/pr_egis_pesquisa_mapa_atributo";

export default {
  name: "monitorEmpresaNFe",
  components: {
    DxDataGrid,
    DxGroupPanel,
    DxGrouping,
    DxPaging,
    DxPager,
    DxHeaderFilter,
    DxColumnChooser,
    DxColumnFixing,
    DxSearchPanel,
  },
  data() {
    return {
      loading: false,
      exibirComoCards: true,

      // datas mínimas (conforme exemplo do exec no documento)
      dt_inicial: "01/01/2025",
      dt_final: "12/31/2026",

      cd_menu: 0,

      pageSizes: [10, 20, 50, 100],

      // dados
      cards: [],
      columnsCards: [],
      grids: [], // [{ titulo, rows, columns }]
      cardSelecionado: null,
    };
  },
  created() {
    this.cd_menu =
      Number(this.$route?.meta?.cd_menu || this.$route?.params?.cd_menu || 0) || 0;

    this.carregarTudo();

  },
  methods: {

    onVoltar() {
  // padrão mais seguro: volta uma página
  if (this.$router) this.$router.back();
},

    formatarInteiro(valor) {
  const n = Number(valor);
  if (!Number.isFinite(n)) return "-";
  return new Intl.NumberFormat("pt-BR", { maximumFractionDigits: 0 }).format(n);
},

formatarMoeda(valor) {
  // Seu backend pode mandar "462013,76" (string com vírgula) ou número.
  if (valor === null || valor === undefined || valor === "") return "-";

  let n;
  if (typeof valor === "string") {
    // troca milhar "." e decimal "," -> padrão JS
    const v = valor.replace(/\./g, "").replace(",", ".");
    n = Number(v);
  } else {
    n = Number(valor);
  }

  if (!Number.isFinite(n)) return "-";

  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
  }).format(n);
},

    // -------- Helpers mínimos (sem depender de lógica externa) --------
    stripStatusRows(rows) {
      // remove linhas que parecem ser "status" (quando vier um recordset com 1 coluna de status, etc.)
      if (!Array.isArray(rows)) return [];
      return rows.filter((r) => {
        if (!r || typeof r !== "object") return false;
        const keys = Object.keys(r);
        if (keys.length === 0) return false;

        // se for uma linha com 1 chave contendo "status", removemos
        if (keys.length === 1) {
          const k = keys[0].toLowerCase();
          if (k.includes("status")) return false;
        }
        return true;
      });
    },

    montarColumnsPorChaves(rows, mapaCaption) {
      const first = Array.isArray(rows) && rows.length ? rows[0] : null;
      if (!first || typeof first !== "object") return [];

      return Object.keys(first).map((k) => ({
        dataField: k,
        caption: (mapaCaption && mapaCaption[k]) ? mapaCaption[k] : k,
      }));
    },

    async obterMapaCaption(atributos) {
  // atributos: ["nm_grupo_conta", "dt_usuario", ...]
  if (!Array.isArray(atributos) || atributos.length === 0) return {};

  try {
    const payload = [
      {
        ic_json_parametro: "S",
        cd_parametro: 1,
        cd_usuario: Number(localStorage.cd_usuario || 0),
        cd_empresa: Number(localStorage.cd_empresa || 0),
        cd_tabela: 0
      },
      {
        dados: atributos.map((nm_atributo) => ({ nm_atributo }))
      }
    ];

    const resp = await api.post("/exec/pr_egis_pesquisa_mapa_atributo", payload);
    const data = resp?.data ?? resp;

    // mssql costuma devolver em result.recordset ou result.recordsets
    const rows =
      (data?.recordset) ||
      (data?.rows) ||
      (Array.isArray(data) ? data : null) ||
      (data?.recordsets && data.recordsets[0]) ||
      [];

    const limpo = this.stripStatusRows(rows);

    const mapa = {};
    limpo.forEach((r) => {
      const nm = r?.nm_atributo;
      if (!nm) return;

      const possiveis = Object.keys(r).filter((k) => k !== "nm_atributo");
      let rotulo = null;

      for (const k of possiveis) {
        if (typeof r[k] === "string" && r[k].trim()) {
          rotulo = r[k].trim();
          break;
        }
      }
      mapa[nm] = rotulo || nm;
    });

    return mapa;
  } catch (e) {
    console.warn("Mapa de atributos falhou, usando chaves como caption.", e);
    return {}; // <-- essencial: não quebra mais
  }
},

    obterTituloCard(item) {
      if (!item || typeof item !== "object") return "Item";
      // tenta usar a primeira chave como "título" sem inventar campo
      const keys = Object.keys(item);
      const k = keys.find((x) => typeof item[x] === "string" && item[x]) || keys[0];
      return String(item[k] ?? "Item");
    },

    obterSubtituloCard(item) {
      if (!item || typeof item !== "object") return "";
      const keys = Object.keys(item);
      // tenta montar um subtítulo com 2 chaves úteis
      const pares = [];
      for (const k of keys) {
        const v = item[k];
        if (v === null || v === undefined) continue;
        if (typeof v === "object") continue;
        // evita repetir o título
        const txt = `${k}: ${v}`;
        pares.push(txt);
        if (pares.length >= 2) break;
      }
      return pares.join(" • ");
    },

    obterBadgeCard(item) {
      if (!item || typeof item !== "object") return null;
      // se existir um valor numérico “óbvio”, usa como badge (sem amarrar em nome)
      const keys = Object.keys(item);
      for (const k of keys) {
        const v = item[k];
        if (typeof v === "number") return v;
      }
      return null;
    },

    selecionarCard(item) {
      this.cardSelecionado = item || null;
      // neste modelo não inventamos navegação/processos;
      // se o backend retornar grids dependentes do card, dá para chamar outro cd_parametro aqui.
    },

    onDblClickCard(e) {
      const item = e?.data;
      if (item) this.selecionarCard(item);
    },

    // --------- Chamada principal (param 500) ----------
    
    async carregarTudo() {
      
      this.loading = true;

      try {
        const payload = [
          {
            ic_json_parametro: "S",
            cd_parametro: 500,
            cd_usuario: Number(localStorage.cd_usuario || 0),
            cd_empresa: Number(localStorage.cd_empresa || 0),
            dt_inicial: this.dt_inicial,
            dt_final: this.dt_final,
          },
        ];

        const resp = await api.post(PROC, payload);
        const data = resp?.data ?? resp;

        /**
         * Compatível com retornos comuns:
         * - array direto
         * - { recordset: [...] }
         * - { rows: [...] }
         * - { recordsets: [ [...], [...], ... ] }  (cards + grids)
         */
        const recordsets = data?.recordsets;

        if (Array.isArray(recordsets) && recordsets.length) {
          // 1º recordset -> cards
          const rsCards = this.stripStatusRows(recordsets[0] || []);
          this.cards = rsCards;

          // demais recordsets -> grids
          const grids = [];
          for (let i = 1; i < recordsets.length; i++) {
            const rows = this.stripStatusRows(recordsets[i] || []);
            if (!rows.length) continue;

            // tradução por mapa (param 1) com os nomes das colunas
            const chaves = Object.keys(rows[0] || {});
            const mapa = await this.obterMapaCaption(chaves);
            const columns = this.montarColumnsPorChaves(rows, mapa);

            grids.push({
              titulo: null,
              rows,
              columns,
            });
          }
          this.grids = grids;
        } else {
          // fallback: se vier só uma lista, mostramos como cards e criamos 1 grid abaixo
          const rows =
            (Array.isArray(data) ? data : data?.recordset || data?.rows || []) || [];
          const limpo = this.stripStatusRows(rows);

          this.cards = limpo;

          if (!this.cardSelecionado && Array.isArray(this.cards) && this.cards.length) {
  this.cardSelecionado = this.cards[0];
}


          const chaves = Object.keys(limpo[0] || {});
          const mapa = chaves.length ? await this.obterMapaCaption(chaves) : {};
          this.columnsCards = this.montarColumnsPorChaves(this.cards, mapa);

          this.grids = limpo.length
            ? [
                {
                  titulo: null,
                  rows: limpo,
                  columns: this.columnsCards,
                },
              ]
            : [];
        }

        // columns do grid dos cards (quando toggle em grid)
        if (!this.columnsCards.length && this.cards.length) {
          const chaves = Object.keys(this.cards[0] || {});
          const mapa = chaves.length ? await this.obterMapaCaption(chaves) : {};
          this.columnsCards = this.montarColumnsPorChaves(this.cards, mapa);
        }
      } catch (err) {
        console.error("Erro ao carregar monitor:", err);
       // this.cards = [];
       // this.grids = [];
       // this.columnsCards = [];
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<style scoped>
.cards-wrapper {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 14px;
}

.monitor-card {
  border: 1px solid rgba(0,0,0,0.08);
  border-radius: 12px;
  padding: 14px;
  background: #fff;
  transition: transform 0.12s ease, box-shadow 0.12s ease;
}

.monitor-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 18px rgba(0,0,0,0.08);
}

.logo-empresa img {
  object-fit: contain;
}

.seta-form {
 
  color: #512da8
}


/* Emblema: anel + miolo branco + sombra */
.logo-destaque {
  border-radius: 50%;
  background: #fff; /* <-- miolo branco */
  border: 1px solid rgba(103, 58, 183, 0.60); /* deep-purple */
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.12);
  overflow: hidden;

  /* centraliza conteúdo dentro do avatar */
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

/* Logo bem maior dentro do círculo */
.logo-destaque img {
  width: 88%;
  height: 88%;
  object-fit: contain; /* não distorce */
  padding: 0;         /* <-- remove o respiro que deixava pequeno */
  background: #fff;   /* garante branco mesmo se a imagem tiver transparência */
}

/* Se cair no ícone padrão */
.logo-destaque .q-icon {
  font-size: 28px;
  color: rgba(103, 58, 183, 0.75);
}

</style>
