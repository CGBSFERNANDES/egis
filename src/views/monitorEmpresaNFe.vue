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
      <div class="col-12 col-sm-4">
  <div class="row items-center no-wrap q-gutter-sm">
    <q-toggle
      v-model="exibirComoCards"
      color="deep-purple-7"
      checked-icon="view_module"
      unchecked-icon="view_list"
      :label="exibirComoCards ? 'cards' : 'grid'"
      keep-color
    />

    <q-chip
      dense
      rounded
      color="red-7"
      class="q-mt-sm q-ml-sm"
      size="16px"
      text-color="white"
      clickable
      :disable="loading"
      @click="abrirGridRejeicoes"
    >
      <q-icon name="report_problem" size="xs" class="q-mr-xs" />
      REJEIÇÕES
      <q-tooltip>Ver todas as rejeições</q-tooltip>
    </q-chip>

    <q-chip
      dense
      rounded
      color="deep-purple-7"
      class="q-mt-sm q-ml-sm"
      size="16px"
      text-color="white"
      clickable
      :disable="loading"
      @click="abrirGridFilaValidacao"
    >
      <q-icon name="queue" size="xs" class="q-mr-xs" />
      FILA VALIDAÇÃO
      <q-tooltip>Ver fila de validação</q-tooltip>
    </q-chip>
  </div>
</div>

      
    </div>

<!-- RESUMO GERAL -->
<div class="q-mt-md">
  <q-card class="resumo-card">
    <div class="row items-center q-col-gutter-md">

      <div class="col-6 col-md-2">
        <div class="text-caption text-grey-7">Total Geral (Empresas)</div>
        <div class="text-h6 text-weight-bold">
          {{ formatarInteiro(resumoGeral.totalGeral) }}
        </div>
      </div>

      <div class="col-6 col-md-2">
        <div class="text-caption text-grey-7">Empresas (com notas)</div>
        <div class="text-h6 text-weight-bold text-deep-purple-7">
          {{ formatarInteiro(resumoGeral.empresasComNotas) }}
        </div>
      </div>

      <div class="col-6 col-md-2">
        <div class="text-caption text-grey-7">Qtd. Notas (Hoje)</div>
        <div class="text-h6 text-weight-bold text-deep-orange-6">
          {{ formatarInteiro(resumoGeral.qtdNotas) }}
        </div>
      </div>

      <div class="col-6 col-md-2">
        <div class="text-caption text-grey-7">Qtd. Filas (Hoje)</div>
        <div class="text-h6 text-weight-bold text-indigo-7">
          {{ formatarInteiro(resumoGeral.qtdFilas) }}
        </div>
      </div>

      <div class="col-6 col-md-2">
        <div class="text-caption text-grey-7">Qtd. Rejeições (Hoje)</div>
        <div class="text-h6 text-weight-bold text-red-7">
          {{ formatarInteiro(resumoGeral.qtdRejeicoes) }}
        </div>
      </div>

      <div class="col-6 col-md-2">
        <div class="text-caption text-grey-7">Valor Total (Hoje)</div>
        <div class="text-h6 text-weight-bold text-cyan-7">
          {{ formatarMoeda(resumoGeral.valorTotal) }}
        </div>
      </div>

    </div>
  </q-card>
</div>

    <!-- Conteúdo principal -->
    <!-- CARDS (entrada) -->

    <div class="q-mt-lg">
      <div v-if="exibirComoCards" class="cards-wrapper">
        <div
          v-for="(item, idx) in cards"
          :key="idx"
          class="monitor-card cursor-pointer"
          :class="classeCard(item)"
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

<div class="metricas-card q-mt-sm">
  <div class="metrica-item">
    <div class="metrica-label">Qtd. Notas (Hoje)</div>
    <div class="metrica-valor text-deep-orange-6">{{ formatarInteiro(item.QtdNotasHoje) }}</div>
  </div>
  <div class="metrica-item">
    <div class="metrica-label">Qtd. Filas (Hoje)</div>
    <div class="metrica-valor text-indigo-7">{{ formatarInteiro(item.QtdFilaHoje) }}</div>
  </div>
  <div class="metrica-item">
    <div class="metrica-label">Qtd. Rejeições (Hoje)</div>
    <div class="metrica-valor text-red-7">{{ formatarInteiro(item.QtdRejeicaoHoje) }}</div>
  </div>
  <div class="metrica-item">
    <div class="metrica-label">Valor Total (Hoje)</div>
    <div class="metrica-valor text-cyan-7">{{ formatarMoeda(item.VlTotalHoje) }}</div>
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

  computed: {
  resumoGeral() {
    const lista = Array.isArray(this.cards) ? this.cards : [];

    const totalGeral = lista.length;

    const empresasComNotas = lista.filter((c) => {
      const qtd = Number(c?.QtdNotasHoje || 0);
      return Number.isFinite(qtd) && qtd > 0;
    }).length;

    const qtdNotas = lista.reduce((acc, c) => {
      const qtd = Number(c?.QtdNotasHoje || 0);
      return acc + (Number.isFinite(qtd) ? qtd : 0);
    }, 0);

    const qtdFilas = lista.reduce((acc, c) => acc + Number(c?.QtdFilaHoje || 0), 0);

    const qtdRejeicoes = lista.reduce((acc, c) => acc + Number(c?.QtdRejeicaoHoje || 0), 0);


    const valorTotal = lista.reduce((acc, c) => {
      return acc + this.normalizarNumero(c?.VlTotalHoje);
    }, 0);

    return { totalGeral, empresasComNotas, qtdNotas, qtdFilas, qtdRejeicoes, valorTotal };
  }
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

classeCard(item) {
  const rej = Number(item?.QtdRejeicaoHoje || 0) > 0;
  const fila = Number(item?.QtdFilaHoje || 0) > 0;

  // prioridade: rejeição > fila
  if (rej) return "card-rejeicao";
  if (fila) return "card-fila";
  return "";
},

async abrirGridRejeicoes() {
  // Rejeição -> cd_parametro 700
  await this.carregarGridEspecial(700, "Rejeições");
},

async abrirGridFilaValidacao() {
  // Fila de validação -> cd_parametro 800
  await this.carregarGridEspecial(800, "Fila de Validação");
},

async carregarGridEspecial(cd_parametro, titulo) {
  this.loading = true;

  try {
    const payload = [
      {
        ic_json_parametro: "S",
        cd_parametro,
        cd_usuario: Number(localStorage.cd_usuario || 0),
        cd_empresa: Number(localStorage.cd_empresa || 0),
        dt_inicial: this.dt_inicial,
        dt_final: this.dt_final,
      },
    ];

    const resp = await api.post(PROC, payload);
    const data = resp?.data ?? resp;

    // pega rows independente do formato
    const recordsets = data?.recordsets;
    let rows = [];

    if (Array.isArray(recordsets) && recordsets.length) {
      rows = this.stripStatusRows(recordsets[0] || []);
    } else {
      rows = this.stripStatusRows(
        (data?.recordset) || (data?.rows) || (Array.isArray(data) ? data : [])
      );
    }

    // monta colunas com captions
    const chaves = Object.keys(rows[0] || {});
    const mapa = chaves.length ? await this.obterMapaCaption(chaves) : {};
    const columns = this.montarColumnsPorChaves(rows, mapa);

    // substitui as grids atuais por esta
    this.grids = [
      {
        titulo,
        rows,
        columns,
      },
    ];

    // opcional: força visualização em grid
    this.exibirComoCards = false;

    // opcional: rolar até a seção de grids (se quiser)
    // this.$nextTick(() => window.scrollTo({ top: document.body.scrollHeight, behavior: "smooth" }));
  } catch (e) {
    console.error("Erro ao carregar grid especial:", e);
  } finally {
    this.loading = false;
  }
},


normalizarNumero(valor) {
  if (valor === null || valor === undefined || valor === "") return 0;

  if (typeof valor === "string") {
    // troca milhar "." e decimal "," -> padrão JS
    const v = valor.replace(/\./g, "").replace(",", ".");
    const n = Number(v);
    return Number.isFinite(n) ? n : 0;
  }

  const n = Number(valor);
  return Number.isFinite(n) ? n : 0;
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

    async selecionarCard(item) {
      this.cardSelecionado = item || null;
      
      // Se a empresa tem rejeições, carrega as rejeições específicas dela
      if (item && Number(item.QtdRejeicaoHoje || 0) > 0) {
        await this.carregarRejeicoesEmpresa(item);
      } else if (item && Number(item.QtdFilaHoje || 0) > 0) {
        // Se tem fila, carrega a fila específica da empresa
        await this.carregarFilaEmpresa(item);
      } else {
        // Limpa grids se não há rejeições nem fila
        this.grids = [];
      }
    },

    async carregarRejeicoesEmpresa(empresa) {
      this.loading = true;
      try {
        // Busca TODAS as rejeições primeiro (a API não filtra por empresa)
        const payload = [
          {
            ic_json_parametro: "S",
            cd_parametro: 700, // Rejeições
            cd_usuario: Number(localStorage.cd_usuario || 0),
            cd_empresa: Number(localStorage.cd_empresa || 0),
            dt_inicial: this.dt_inicial,
            dt_final: this.dt_final,
          },
        ];

        const resp = await api.post(PROC, payload);
        const data = resp?.data ?? resp;

        const recordsets = data?.recordsets;
        let rows = [];

        if (Array.isArray(recordsets) && recordsets.length) {
          rows = this.stripStatusRows(recordsets[0] || []);
        } else {
          rows = this.stripStatusRows(
            (data?.recordset) || (data?.rows) || (Array.isArray(data) ? data : [])
          );
        }

        // FILTRAR LOCALMENTE pela empresa selecionada
        const cdEmpresaFiltro = Number(empresa.cd_empresa || 0);
        const nmBancoFiltro = (empresa.nm_banco_empresa || "").toLowerCase().trim();
        const nmFantasiaFiltro = (empresa.nm_fantasia_empresa || "").toLowerCase().trim();
        const nmEmpresaFiltro = (empresa.nm_empresa || "").toLowerCase().trim();

        if (rows.length > 0) {
          rows = rows.filter(r => {
            // Tenta diferentes campos que podem identificar a empresa
            const cdEmpresaRow = Number(r.cd_empresa || r.cd_empresa_nota || r.CdEmpresa || r.cd_emp || 0);
            const nmBancoRow = (r.nm_banco_empresa || r.nm_banco || r.NmBancoEmpresa || r.banco || "").toLowerCase().trim();
            const nmFantasiaRow = (r.nm_fantasia_empresa || r.nm_fantasia || r.NmFantasia || "").toLowerCase().trim();
            const nmEmpresaRow = (r.nm_empresa || r.NmEmpresa || r.razao_social || "").toLowerCase().trim();
            
            // Filtra por qualquer campo que bata
            if (cdEmpresaFiltro > 0 && cdEmpresaRow === cdEmpresaFiltro) return true;
            if (nmBancoFiltro && nmBancoRow === nmBancoFiltro) return true;
            if (nmFantasiaFiltro && nmFantasiaRow.includes(nmFantasiaFiltro)) return true;
            if (nmEmpresaFiltro && nmEmpresaRow.includes(nmEmpresaFiltro)) return true;
            
            return false;
          });
        }

        const chaves = Object.keys(rows[0] || {});
        const mapa = chaves.length ? await this.obterMapaCaption(chaves) : {};
        const columns = this.montarColumnsPorChaves(rows, mapa);

        this.grids = [
          {
            titulo: `Rejeições - ${empresa.nm_fantasia_empresa || empresa.nm_empresa}`,
            rows,
            columns,
          },
        ];
      } catch (e) {
        console.error("Erro ao carregar rejeições da empresa:", e);
        this.grids = [];
      } finally {
        this.loading = false;
      }
    },

    async carregarFilaEmpresa(empresa) {
      this.loading = true;
      try {
        // Busca TODAS as filas primeiro (a API não filtra por empresa)
        const payload = [
          {
            ic_json_parametro: "S",
            cd_parametro: 800, // Fila de Validação
            cd_usuario: Number(localStorage.cd_usuario || 0),
            cd_empresa: Number(localStorage.cd_empresa || 0),
            dt_inicial: this.dt_inicial,
            dt_final: this.dt_final,
          },
        ];

        const resp = await api.post(PROC, payload);
        const data = resp?.data ?? resp;

        const recordsets = data?.recordsets;
        let rows = [];

        if (Array.isArray(recordsets) && recordsets.length) {
          rows = this.stripStatusRows(recordsets[0] || []);
        } else {
          rows = this.stripStatusRows(
            (data?.recordset) || (data?.rows) || (Array.isArray(data) ? data : [])
          );
        }

        // FILTRAR LOCALMENTE pela empresa selecionada
        const cdEmpresaFiltro = Number(empresa.cd_empresa || 0);
        const nmBancoFiltro = (empresa.nm_banco_empresa || "").toLowerCase().trim();
        const nmFantasiaFiltro = (empresa.nm_fantasia_empresa || "").toLowerCase().trim();
        const nmEmpresaFiltro = (empresa.nm_empresa || "").toLowerCase().trim();

        if (rows.length > 0) {
          rows = rows.filter(r => {
            // Tenta diferentes campos que podem identificar a empresa
            const cdEmpresaRow = Number(r.cd_empresa || r.cd_empresa_nota || r.CdEmpresa || r.cd_emp || 0);
            const nmBancoRow = (r.nm_banco_empresa || r.nm_banco || r.NmBancoEmpresa || r.banco || "").toLowerCase().trim();
            const nmFantasiaRow = (r.nm_fantasia_empresa || r.nm_fantasia || r.NmFantasia || "").toLowerCase().trim();
            const nmEmpresaRow = (r.nm_empresa || r.NmEmpresa || r.razao_social || "").toLowerCase().trim();
            
            // Filtra por qualquer campo que bata
            if (cdEmpresaFiltro > 0 && cdEmpresaRow === cdEmpresaFiltro) return true;
            if (nmBancoFiltro && nmBancoRow === nmBancoFiltro) return true;
            if (nmFantasiaFiltro && nmFantasiaRow.includes(nmFantasiaFiltro)) return true;
            if (nmEmpresaFiltro && nmEmpresaRow.includes(nmEmpresaFiltro)) return true;
            
            return false;
          });
        }

        const chaves = Object.keys(rows[0] || {});
        const mapa = chaves.length ? await this.obterMapaCaption(chaves) : {};
        const columns = this.montarColumnsPorChaves(rows, mapa);

        this.grids = [
          {
            titulo: `Fila de Validação - ${empresa.nm_fantasia_empresa || empresa.nm_empresa}`,
            rows,
            columns,
          },
        ];
      } catch (e) {
        console.error("Erro ao carregar fila da empresa:", e);
        this.grids = [];
      } finally {
        this.loading = false;
      }
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
  grid-template-columns: repeat(4, 1fr); /* Força exatamente 4 colunas */
  gap: 12px;
}

/* Responsivo: menos colunas em telas menores */
@media (max-width: 1400px) {
  .cards-wrapper {
    grid-template-columns: repeat(3, 1fr);
  }
}
@media (max-width: 1024px) {
  .cards-wrapper {
    grid-template-columns: repeat(2, 1fr);
  }
}
@media (max-width: 600px) {
  .cards-wrapper {
    grid-template-columns: 1fr;
  }
}

.monitor-card {
  border: 1px solid rgba(0,0,0,0.08);
  border-radius: 12px;
  padding: 12px;
  background: #fff;
  transition: transform 0.12s ease, box-shadow 0.12s ease;
  min-width: 0; /* Permite que o card encolha se necessário */
  overflow: hidden;
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

.resumo-card {
  border-radius: 12px;
  border: 1px solid rgba(0,0,0,0.08);
  background: #fff;
  padding: 12px;
}

/* Fundo bem clarinho quando tem rejeição */
.card-rejeicao {
  background: #ffebee !important; /* vermelho bem leve */
  border: 1px solid rgba(244, 67, 54, 0.25);
}

/* Fundo bem clarinho quando tem fila */
.card-fila {
  background: #f3e5f5 !important; /* roxo bem leve */
  border: 1px solid rgba(156, 39, 176, 0.25);
}

/* Layout de métricas em grid 2x2 */
.metricas-card {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 6px 12px;
}

.metrica-item {
  min-width: 0;
  overflow: hidden;
}

.metrica-label {
  font-size: 11px;
  color: #757575;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.metrica-valor {
  font-size: 13px;
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

</style>
