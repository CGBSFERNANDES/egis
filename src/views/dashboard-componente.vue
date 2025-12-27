<template>
  
  <div class="main-content">
    <div class="container-alinhado">
      <div class="linha-topo-dashboard">
        <div class="grupo-esquerda">
          <div v-if="1 == 1" class="grupo-titulo" style="margin-left: -50px">
            <h2 id="titulo-modulo">{{ tituloModulo }}</h2>
          </div>
          <span
            id="filtros-resumo"
            class="ml-2"
            style="font-size: 0.9rem; color: #555"
            >{{ resumoFiltros }}</span
          >
        </div>

        <div class="grupo-direita dias-periodo-container" id="dias-periodo">
          <button
            v-if="1 == 2"
            id="btnDashboardFiltros"
            class="btn-filtro-card"
            style="display: inline-flex"
            @click="montarFiltrosDinamicos"
          >
            <span class="filtro-icone">🔍</span>
            <span class="filtro-texto">Filtros</span>
          </button>

          <div v-if="1 == 2" id="timer-dashboard" class="dia-indicador">
            <div class="dia-valor" id="tempo-restante">
              {{ tempoRestanteFmt }}
            </div>
            <div class="dia-label">🔄 Atualização</div>
            <label class="switch-autoupdate">
              <input
                type="checkbox"
                id="toggle-auto-refresh"
                v-model="autoRefreshAtivo"
              />
              <span class="slider"></span>
            </label>
          </div>

          <div id="dias-periodo-wrapper" class="periodo-dias-container">
            <div v-for="(d, i) in diasPeriodo" :key="i" class="dia-indicador">
              <div class="dia-valor">{{ d.valor }}</div>
              <div class="dia-label">{{ d.label }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- painel de filtros dinâmicos -->
      <div
        id="filtros-dashboard"
        class="painel-filtros-card"
        v-show="painelFiltrosVisivel"
      >
        <div
          v-for="(f, idx) in filtros"
          :key="idx"
          class="mb-2"
          style="min-width: 220px"
        >
          <label class="mb-1">{{ f.nm_edit_label }}</label>

          <!-- lookup múltiplo/único -->
          <select
            v-if="temLookup(f)"
            class="form-control"
            :multiple="f.ic_filtro_selecao === 'S'"
            :size="f.ic_filtro_selecao === 'S' ? 5 : null"
            v-model="valoresFiltro[f.nm_campo_chave_lookup]"
          >
            <option v-if="f.ic_filtro_selecao !== 'S'" value="">
              Selecione...
            </option>
            <option
              v-for="op in opcoesLookup[f.nm_campo_chave_lookup] || []"
              :key="op.value"
              :value="op.value"
            >
              {{ op.label }}
            </option>
          </select>

          <!-- input comum -->
          <input
            v-else
            class="form-control"
            :type="inputType(f)"
            v-model="valoresFiltro[f.nm_atributo]"
          />
        </div>

        <div class="mt-2">
          <button class="btn btn-success mr-2" @click="aplicarFiltros">
            Aplicar
          </button>
          <button class="btn btn-limpar" @click="limparFiltros">Limpar</button>
        </div>
      </div>

      <!-- indicadores -->

      <div id="indicadores" class="indicadores-container" style="margin-left: -50px">
        <div
          v-for="(card, i) in indicadores"
          :key="i"
          class="indicador-card"
          :class="corCard(i)"
          @click="abrirGridDoCard(card)"
          :style="{ cursor: card.cd_menu ? 'pointer' : 'default' }"
        >
   <div class="card-top">
  <h3 class="titulo-card">{{ card.nm_titulo || "Sem Título" }}</h3>
</div>


          <div class="valor" v-if="Number(card.vl_total || 0) !== 0">
            {{ moeda(card.vl_total) }}
          </div>

          <div
            class="indicador-icone"
            v-if="card.nm_icone && card.nm_cor"
            :style="{
              color: card.nm_cor,
              fontSize: '1.2rem',
              marginTop: '4px',
            }"
          >
            <i class="material-icons">{{ card.nm_icone }}</i>
          </div>

          <div class="detalhe">
            <template v-if="card.qt_total > 0"
              >Qtd: {{ card.qt_total }}<br
            /></template>
            <template v-if="card.pc_total"
              >{{ (Number(card.pc_total) || 0).toFixed(2) }}%</template
            >
          </div>

          <div class="observacao-card" v-if="card.nm_obs_item_composicao">
            {{ card.nm_obs_item_composicao }}
          </div>
          <div class="observacao-card" v-if="card.nm_obs_item_aux">
            {{ card.nm_obs_item_aux }}
          </div>
        </div>
      </div>

      <!-- gráficos -->
      
      <div class="graficos-grid" style="margin-left: -50px">
        <div 
          v-if="1==1"
          id="grafico-diario" class="grafico-item">
          <h2>Diário</h2>
          <canvas ref="graficoDiario"></canvas>
        </div>
        <div 
          v-if="1==1"
          id="grafico-mensal" class="grafico-item">
          <h2>Mensal</h2>
          <canvas ref="graficoMensal"></canvas>
        </div>
        <div 
          v-if="1==1"
          id="grafico-anual" class="grafico-item">
          <h2>Anual</h2>
          <canvas ref="graficoAnual"></canvas>
        </div>
        <div
          v-if="temGraficosCliente" 
          id="grafico-cliente" class="grafico-item">
          <h2>Clientes</h2>
          <canvas ref="graficoVendas"></canvas>
        </div>
        <div 
          v-if="temGraficosVendedor"
          id="grafico-vendedor" class="grafico-item">
          <h2>Vendedor</h2>
          <canvas ref="graficoVendedores"></canvas>
        </div>
        <div
          v-if="temGraficosCategoria" 
          id="grafico-categoria" class="grafico-item">
          <h2>Categorias</h2>
          <canvas ref="graficoCategorias"></canvas>
        </div>
        <div 
          v-if="temGraficosProduto"
          id="grafico-produtos" class="grafico-item">
          <h2>Produtos</h2>
          <canvas ref="graficoProdutos"></canvas>
        </div>
        <div 
          v-if="temGraficosProduto"
          id="grafico-produtos-5" class="grafico-item">
          <h2>Top 5</h2>
          <canvas ref="graficoProduto5"></canvas>
        </div>
      </div>

      <div
        id="indicadores-compactos"
        class="indicadores-container-compactos"
      ></div>
    </div>

    <!-- Área do formulário/grid -->

   <div id="devextreme-wrapper-limpo">
      <div id="grid-limpa" class="modo-claro-grid"></div>
   </div>

    <q-slide-transition v-if="1==2">
      <div v-show="showForm" ref="areaForm" class="q-mt-md">
        <div class="painel-grid bg-white q-pa-md" style="border-radius: 12px">
          <div class="row items-center justify-between q-mb-sm">
            <div class="col">
              <h2 class="titulo-grid">Detalhes</h2>
            </div>
            <div class="col-auto">
              <q-btn dense flat round icon="close" @click="showForm = false" />
            </div>
          </div>

          <!-- Aqui renderiza o componente que já funciona para a sua grid -->

          <UnicoFormEspecial

            v-if="1==2 && selectedMenu"
            :key="formKey"
            :cd-menu="selectedMenu"
            :cd-usuario="cdUsuarioResolved"
            :dt-inicial="dtInicialResolved"
            :dt-final="dtFinalResolved"
            :cd_menu_modal_entrada="0"
            
          />
        </div>
      </div>
    </q-slide-transition>

    <!-- grids dinâmicas -->

<!-- GRID PRINCIPAL (padrão unicoFormEspecial) -->

<div class="dashboard-grid-wrapper q-mt-md">

  <div
  v-if="rowsGrid && rowsGrid.length"
  ref="gridCard"
  class="dashboard-card q-mt-md"
>

<div class="grid-header q-mb-sm row items-center no-wrap">
  <!-- LEFT -->
  <div class="grid-header-left row items-center no-wrap">
    <q-btn
      dense
      rounded
      color="deep-orange-9"
      icon="keyboard_arrow_up"
      @click="scrollToTop"
      class="q-mr-sm"
    />

    <h2 v-if="nmMenuTitulo" class="grid-title">
      {{ nmMenuTitulo }}
    </h2>

    <div class="text-subtitle2 top-det-grid q-ml-sm">
      ({{ rowsGrid.length }} registros)
    </div>
  </div>

  <q-space />

  <!-- RIGHT -->
  <div class="grid-header-right row items-center no-wrap">
    <q-btn
      dense
      outline
      icon="description"
      label="RELATÓRIO"
      color="primary"
      @click="gerarRelatorioGrid"
      :disable="!rowsGrid || !rowsGrid.length"
    />
    <q-btn
      dense
      outline
      icon="dashboard"
      label="DASHBOARD"
      color="primary"
      class="q-ml-sm"
      style="margin-right: 40px"
      @click="abrirDashboardDaGrid"
      :disable="!rowsGrid || !rowsGrid.length"
    />
  </div>
</div>

<!-- Dialog do Relatório -->
<q-dialog v-model="showRelatorio" maximized>
  <q-card style="min-height: 90vh">
    <q-card-section class="row items-center q-pb-none">
      <div class="text-h6">Relatório</div>
      <q-space />
      <q-btn dense flat icon="close" @click="showRelatorio = false" />
    </q-card-section>

    <q-separator />

    <q-card-section>
      <Relatorio
        v-if="showRelatorio"
        :columns="gridColumns"
        :rows="rowsRelatorio"
        :summary="totalColumns"
        :titulo="tituloMenu"
        :menu-codigo="cdMenuRel"
        :usuario-nome-ou-id="nm_usuario"
        :logoSrc="logo"
        :empresaNome="Empresa"
        :totais="totalColumns"
        @pdf="exportarPDF"
        @excel="exportarExcel"
      />
    </q-card-section>
  </q-card>
</q-dialog>
<!-- Dialog do Dashboard Dinâmico -->
<q-dialog v-model="showDashDinamico" maximized>
  <q-card class="q-pa-sm" style="height:100vh;width:100vw;">
    <q-btn
      flat
      dense
      round
      icon="close"
      class="absolute-top-right q-ma-sm"
      @click="showDashDinamico = false"
    />
    <dashboard-dinamico
      :rows="rowsParaDashboard"
      :columns="colsParaDashboard"
      :titulo="tituloDashboard"
      :cd-menu="gridContext ? gridContext.cd_menu : 0"
      @voltar="showDashDinamico = false"
    />
  </q-card>
</q-dialog>

  </div>
  <DxDataGrid 
    
    id="grid-dashboard"
    v-if="rowsGrid && rowsGrid.length"
    :key="gridKey"
    :data-source="rowsGrid"
    :show-borders="true"
    :column-auto-width="true"
    :row-alternation-enabled="true"
    :word-wrap-enabled="true"
    :allow-column-reordering="true"
    :allow-column-resizing="true"
    @toolbar-preparing="onToolbarGrid"
  >
   <DxColumn
    v-for="col in colunasGrid"
    :key="col.dataField"
    :data-field="col.dataField"
    :caption="col.caption"
    :data-type="col.dataType"
    :format="getFormat(col)"
    :calculate-cell-value="col.calculateCellValue"
  />
  <DxExport :enabled="true" :allow-export-selected-data="false" />
  <DxSummary v-if="summaryItems.length">
  <DxTotalItem
    v-for="it in summaryItems"
    :key="it.key"
    :summary-type="it.summaryType"
    :column="it.column"
    :value-format="it.valueFormat"
    :display-format="it.displayFormat"
  />
</DxSummary>

  </DxDataGrid>

  <div v-else class="text-grey q-mt-md">
    Nenhum dado para exibir na grade.
  </div>
</div>

</div>

    
</template>

<script>
// IMPORTS: ajuste os caminhos de acordo com seu projeto
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue";
import { execProcedure } from "@/services/exec.service";
import { payloadTabela } from "@/services/payload.service";
import { getMenuFiltro } from "@/services/menu.service";
import { lookup } from "@/services/lookup.service";
import Relatorio from "@/components/Relatorio.vue";
import DashboardDinamico from '@/components/dashboardDinamico.vue' // ajuste o caminho


import DxDataGrid, {
  DxColumn,
  DxFilterRow,
  DxHeaderFilter,
  DxSelection,
  DxPaging,
  DxPager,
  DxSorting,
  DxExport,
  DxSummary,
  DxTotalItem
} from "devextreme-vue/data-grid";
//

const CDN_CHART = "https://cdn.jsdelivr.net/npm/chart.js";

//


// helper para converter "1.234,56" -> 1234.56
function toNumberBR(val) {
  if (val == null) return 0;
  if (typeof val === "number") return val;
  const s = String(val).trim();
  // remove separador de milhar e troca vírgula por ponto
  return parseFloat(s.replace(/\./g, "").replace(",", ".")) || 0;
}
//

export default {
  name: "dashBoard_Componente",
  components: { UnicoFormEspecial,
     DxDataGrid,
    DxColumn,
    DxFilterRow,
    DxHeaderFilter,
    DxSelection,
    DxPaging,
    DxPager,
    DxSorting,
    DxExport,
    DxTotalItem,
    DxSummary,
    Relatorio,
    DashboardDinamico,
   },

  props: {
    cdModulo: [Number, String],
    cdUsuario: [Number, String],
    dtInicial: String,
    dtFinal: String,
  },
  data() {
    return {
      loading: false,
      showScrollTop: false,
      tituloModulo: "Título",
      resumoFiltros: "",
      indicadores: [],
      filtros: [],
      painelFiltrosVisivel: false,
      valoresFiltro: {},
      opcoesLookup: {},

      tempoRestante: 600,
      autoRefreshAtivo: false,
      timerId: null,

      diasPeriodo: [],

      charts: {
        diario: null,
        mensal: null,
        anual: null,
        barras: null,
        clientes: null,
        vendedores: null,
        rosca: null,       
        categoria: null,
        produtos: null,
      
      },
      loadingGraficos: false,
      secoesGrid: [],

      // controle do form que renderiza a grid:
      showForm: false,
      selectedMenu: null,
      formKey: 0, // força remount quando trocar menu
      rowsGrid: [],
      colunasGrid: [],      
      hasGrid: false,
      totalRegistrosGrid: 0,
      totalizadoresGrid: {},      // se quiser somar colunas
      ultimoPayloadGrid: null,
      gridKey: 0,
      cd_menu_modal : 0,
      cd_form_modal : 0,
      headerBanco : localStorage.nm_banco_empresa,
      cd_modulo : localStorage.cd_modulo,
      nmMenuTitulo : '',
      gridContext: null,
      showRelatorio: false,
      showDashDinamico: false,

      // props para relatório
      gridColumns: [],
      rowsRelatorio: [],
      totalColumns: [],
      tituloMenu: '',
      cdMenuRel: 0,

      // props para dashboard
      rowsParaDashboard: [],
      colsParaDashboard: [],
      tituloDashboard: '',
      cdMenuGridAtual: 0,
      logo: this.nm_caminho_logo_empresa || '',
      Empresa: localStorage.fantasia || localStorage.empresa || '',
      nm_usuario: localStorage.usuario || '',
    };
  },

  computed: {

     summaryItems() {
      const items = []

    // COUNT: DevExtreme conta valores não-null da coluna.
    // Se você quer "qtd linhas", escolha uma coluna qualquer (a primeira).
    const firstCol = this.colunasGrid?.[0]?.dataField

    console.log('summaryItems - colunasGrid:', this.colunasGrid)

    this.colunasGrid.forEach(c => {
      if (c.ic_contagem === 'S' && firstCol) {
        items.push({
          key: c.dataField + '_count',
          summaryType: 'count',
          column: c.dataField,
          valueFormat: undefined,
          displayFormat: 'Qtd: {0}'
        })
      }

      if (c.ic_soma === 'S') {
        items.push({
          key: c.dataField + '_sum',
          summaryType: 'sum',
          column: c.dataField,
          valueFormat: c.format?.type === 'currency' ? { type: 'currency', currency: 'BRL', precision: 2 } : { type: 'fixedPoint', precision: 2 },
          displayFormat: 'Total: {0}'
        })
      }
    })

    return items

  },

    temGraficosVendedor () {
     return this.vendedores && this.vendedores.length > 0
    },
    temGraficosCliente () {
     return this.clientes && this.clientes.length > 0
    },
    temGraficosProduto () {
     return this.produtos && this.produtos.length > 0
    },
    temGraficosCategoria () {
     return this.categoria && this.categoria.length > 0
    },



    tempoRestanteFmt() {
      const m = String(Math.floor(this.tempoRestante / 60)).padStart(2, "0");
      const s = String(this.tempoRestante % 60).padStart(2, "0");
      return `${m}:${s}`;
    },
    cdUsuarioResolved() {
      return Number(
        this.cdUsuario || sessionStorage.getItem("cd_usuario") || 0
      );
    },
    dtInicialResolved() {
      return (
        this.dtInicial || sessionStorage.getItem("dt_inicial_padrao") || ""
      );
    },
    dtFinalResolved() {
      return this.dtFinal || sessionStorage.getItem("dt_final_padrao") || "";
    },

      colunasGridx () {
    const exemplo = this.rowsGrid[0] || {};
    const chaves = Object.keys(exemplo);

    return chaves.map(k => {
      const caption = (k || "")
        .replace(/_/g, " ")
        .replace(/\s+/g, " ")
        .toLowerCase()
        .replace(/(^|\s)\S/g, t => t.toUpperCase()); // nm_semana -> "Nm Semana"

      return {
        dataField: k,
        caption,
        dataType: this.detectDataType(exemplo[k]),
      };
    });
  },

  },

  watch: {
    autoRefreshAtivo(val) {
      if (val) {
        this.resetTimer();
        this.iniciarDashboard(true);
      } else {
        clearInterval(this.timerId);
      }
    },
  },

  async mounted() {

    window.addEventListener("scroll", this.handleScroll);

    this.headerBanco = localStorage.nm_banco_empresa;
    this.cd_modulo   = localStorage.cd_modulo;

    console.log('[dashboardDinamico] mounted - rows recebidas:', (this.rows || []).length)
    console.log('[dashboardDinamico] primeiros rows:', (this.rows || []).slice(0, 3))
    console.log('[dashboardDinamico] columns recebidas:', this.columns)

    await this.ensureChartJs();
  
    this.resetTimer();
    this.iniciarDashboard();
    //

  },

  beforeDestroy() {
    clearInterval(this.timerId);
    var self = this;
    Object.keys(this.charts).forEach(function (k) {
      var c = self.charts[k];
      if (c && c.destroy) c.destroy();
    });

    window.removeEventListener("scroll", this.handleScroll);

  },

  methods: {
   
    onScroll() {
      this.showScrollTop = window.scrollY > 300
    },

      handleScroll() {
    // mostra o botão se rolar mais de 200px
    this.showScrollTop = window.scrollY > 200;
  },

  scrollToTop () {
    // tenta usar o ref do topo do dashboard
    const topo = this.$refs.topoDashboard || this.$el
    if (topo && topo.scrollIntoView) {
      topo.scrollIntoView({ behavior: 'smooth', block: 'start' })
    } else {
      window.scrollTo({ top: 0, behavior: 'smooth' })
    }
  },

  
  abrirDashboardDaGrid() {
  if (!this.rowsGrid?.length) return

  // 1) monta mapa: dataField -> caption
  const mapFieldToCaption = {}
  ;(this.colunasGrid || []).forEach(c => {
    const field = c?.dataField
    const cap = c?.caption
    if (field && cap) mapFieldToCaption[field] = cap
  })

  // 2) cria rows "traduzidos" (chaves = caption)
  const rowsTraduzidos = (this.rowsGrid || []).map(r => {
    const novo = {}
    Object.keys(r || {}).forEach(k => {
      const cap = mapFieldToCaption[k] || k
      // evita colisão de captions repetidos
      let keyFinal = cap
      if (novo[keyFinal] !== undefined) keyFinal = `${cap} (${k})`
      novo[keyFinal] = r[k]
    })
    return novo
  })

  // 3) columns para o dashboard = captions (strings)
  const colsTraduzidas = Object.values(mapFieldToCaption)

  // fallback (se não tiver caption no meta)
  const finalCols = colsTraduzidas.length ? colsTraduzidas : Object.keys(this.rowsGrid[0])

  this.rowsParaDashboard = rowsTraduzidos
  this.colsParaDashboard = finalCols

  this.tituloDashboard = this.nmMenuTitulo || 'Dashboard'
  this.cdMenuGridAtual = this.gridContext?.cd_menu || 0
  this.showDashDinamico = true
},


  gerarRelatorioGrid() {
    if (!this.rowsGrid?.length) return

  this.gridColumns = this.colunasGrid
  this.rowsRelatorio = this.rowsGrid
  this.totalColumns = this.montarTotalColumnsParaRelatorio()

  this.tituloMenu = this.nmMenuTitulo || (this.gridContext?.nm_menu_titulo || 'Relatório')
  this.cdMenuRel = this.gridContext?.cd_menu || 0

  this.showRelatorio = true  
  },

  montarTotalColumnsParaRelatorio() {
    // usa as flags já calculadas nas colunasGrid
    const totais = []
    const rows = this.rowsGrid || []

     const toNumber = (v) => {
    if (v == null || v === '') return 0
    // se vier "1.234,56" ou "123,45"
    if (typeof v === 'string') {
      const s = v.replace(/\./g, '').replace(',', '.')
      const n = Number(s)
      return isNaN(n) ? 0 : n
    }
    const n = Number(v)
    return isNaN(n) ? 0 : n
  }

  ;(this.colunasGrid || []).forEach(c => {
    const contador = String(c.ic_contador_grid || c.ic_contagem || 'N').trim().toUpperCase()
    const total = String(c.ic_total_grid || c.ic_soma || 'N').trim().toUpperCase()

    if (contador === 'S') {
      totais.push({
        dataField: c.dataField,
        caption: c.caption,
        tipo: 'count',
        value: rows.length,          // ✅ qtd registros
        format: null
      })
    }

    if (total === 'S') {

      const soma = rows.reduce((acc, r) => acc + toNumber(r[c.dataField]), 0)

      totais.push({
        dataField: c.dataField,
        caption: c.caption,
        tipo: 'sum',
        format: c.format,
        value: soma // placeholder
      })
    }
  })

  return totais
},


getFormat(col) {
    if (col.dataType === 'currency') {
      return {
        type: 'currency',
        currency: 'BRL',
        precision: 2
      }
    }

    if (col.dataType === 'number') {
      return { type: 'fixedPoint', precision: 2 }
    }

    if (col.dataType === 'date') {
      return 'dd/MM/yyyy'
    }

    return undefined
  },

    onToolbarGrid(e) {
       const toolbar = e.toolbarOptions.items || [];


  toolbar.unshift(
    /*
    {
      location: "before",
      widget: "dxButton",
      options: {
        icon: "exportxlsx",
        hint: "Exportar para Excel",
        onClick: () => this.$refs.gridDashboard.instance.exportToExcel()
      }
    },

    {
      location: "before",
      widget: "dxButton",
      options: {
        icon: "print",
        hint: "Imprimir",
        onClick: () => window.print()
      }
        
    },
   */

  )
},

    async exportarPDF() {
      try {
        const { default: jsPDF } = await import("jspdf");
        const { default: autoTable } = await import("jspdf-autotable");

        // 1) Pega suas colunas / linhas já mostradas na grid
        const metaCols =
          (this.columns?.length ? this.columns : this.gridColumns) || [];
        const rowsSrc = (this.rows?.length ? this.rows : this.gridRows) || [];

        if (!rowsSrc.length) {
          this.$q?.notify?.({
            type: "warning",
            position: 'center',
            message: "Sem dados para exportar.",
          });
          return;
        }

        // 2) Mapa de atributo -> atributo_consulta salvo no payload

        let mapa = {};
        try {
          mapa = JSON.parse(
            sessionStorage.getItem("mapa_consulta_para_atributo") || "{}"
          );
        } catch (_) {}

        // 3) Monta colunas exportáveis (ignora coluna de ações)
        const cols = metaCols
          .filter((c) => c.type !== "buttons")
          .map((c) => ({
            label:
              c.caption ||
              c.label ||
              c.nm_titulo_menu_atributo ||
              c.dataField ||
              c.field,
            field: c.dataField || c.field || c.name,
            fmt: c.format || null,
            width: c.width,
          }));

        // 4) Helpers de formatação
        const toBR = (v) => {
          if (v == null || v === "") return "";
          if (v instanceof Date) {
            const dd = String(v.getDate()).padStart(2, "0");
            const mm = String(v.getMonth() + 1).padStart(2, "0");
            const yy = v.getFullYear();
            return `${dd}/${mm}/${yy}`;
          }
          const s = String(v);
          if (/^\d{2}\/\d{2}\/\d{4}$/.test(s)) return s;
          // ISO -> pega só a data
          const m = s.match(/^(\d{4})-(\d{2})-(\d{2})/);
          if (m) return `${m[3]}/${m[2]}/${m[1]}`;
          return s;
        };
        const money = (n) => {
          const x = Number(String(n).replace(",", "."));
          return Number.isFinite(x)
            ? x.toLocaleString("pt-BR", { style: "currency", currency: "BRL" })
            : n ?? "";
        };

        // 5) Resolve valor seguro por coluna e linha
        const safeGet = (row, col) => {
          const tryKeys = [];
          const base = col.field;
          tryKeys.push(base);
          if (mapa[base]) tryKeys.push(mapa[base]); // mapeamento meta->consulta
          // tenta achar por case-insensitive
          const alt = Object.keys(row).find(
            (k) => k.toLowerCase() === base?.toLowerCase()
          );
          if (alt && !tryKeys.includes(alt)) tryKeys.push(alt);

          let val;
          for (const k of tryKeys) {
            if (k in row) {
              val = row[k];
              break;
            }
          }
          // formata
          if (
            col.fmt &&
            ["currency", "fixedPoint", "number", "percent"].includes(col.fmt)
          ) {
            return money(val);
          }
          if (/^(dt_|data|emissao|entrega)/i.test(col.field)) return toBR(val);
          return val == null ? "" : String(val);
        };

        // 6) Cabeçalho/Metadados
        const empresa =
          localStorage.nm_razao_social ||
          sessionStorage.getItem("empresa") ||
          "-";
        const menu =
          this.cd_menu ||
          this.cdMenu ||
          sessionStorage.getItem("cd_menu") ||
          "";
        const usuario =
          localStorage.nm_usuario || sessionStorage.getItem("nm_usuario") || "";
        const getFiltro = (k) =>
          (this.filtrosValores && this.filtrosValores[k]) || "";
        const dtIni =
          getFiltro("dt_inicial") || getFiltro("dtini") || getFiltro("dt_inic");
        const dtFim =
          getFiltro("dt_final") || getFiltro("dtfim") || getFiltro("dt_fim");

        // 7) Prepara head/body para o AutoTable
        const head = [cols.map((c) => c.label)];
        const body = rowsSrc.map((r) => cols.map((c) => safeGet(r, c)));

        // 8) Totais/resumo com base no seu meta de totalização
        const summary = [];
        if (Array.isArray(this.totalColumns) && this.totalColumns.length) {
          const tot = this.totalColumns.map((t) => {
            if (t.type === "count") {
              return {
                label: "registro(s)",
                value: rowsSrc.length,
                isCurrency: false,
              };
            } else {
              const soma = rowsSrc.reduce((acc, rr) => {
                const v = Number(rr[t.dataField]) || 0;
                return acc + v;
              }, 0);
              return {
                label: t.display?.replace("{0}", "Total") || "Total",
                value: soma,
                isCurrency: true,
              };
            }
          });
          summary.push(...tot);
        }

        // 9) Gera o PDF
        const doc = new jsPDF({
          orientation: "landscape",
          unit: "pt",
          format: "a4",
        });
        const margin = 28;
        const pageW = doc.internal.pageSize.getWidth();
        let y = margin;

        // (opcional) logo – precisa ser HTTPS e CORS habilitado

        try {
          const nm_caminho_logo_empresa = localStorage.nm_caminho_logo_empresa || "";
          const logoUrl = `https://egisapp.com.br/img/${nm_caminho_logo_empresa}`;
          const res = await fetch(logoUrl);
          const b = await res.blob();
          const b64 = await new Promise((r) => {
            const fr = new FileReader();
            fr.onload = () => r(fr.result);
            fr.readAsDataURL(b);
          });
          doc.addImage(b64, "PNG", margin, y, 90, 30);
        } catch (_) {
          /* se falhar, segue sem logo */
        }

        // Título
        doc.setFont("helvetica", "bold");
        doc.setFontSize(22);
        doc.text(
          this.title || this.pageTitle || "Entregas por Periodo",
          margin + 120,
          y + 22
        );

        // Meta linha 1
        doc.setFont("helvetica", "normal");
        doc.setFontSize(11);
        y += 46;
        doc.text(
          `Empresa: ${empresa}  •  Menu: ${menu}  •  Data/Hora: ${toBR(
            new Date()
          )} ${new Date().toLocaleTimeString("pt-BR")}`,
          margin,
          y
        );
        // Período
        y += 18;
        doc.text(
          `Data Inicial: ${toBR(dtIni)}   |   Data Final: ${toBR(dtFim)}`,
          margin,
          y
        );

        // Tabela
        const columnStyles = {};
        cols.forEach((c, i) => {
          if (c.width) columnStyles[i] = { cellWidth: c.width };
          if (
            c.fmt &&
            ["currency", "fixedPoint", "number", "percent"].includes(c.fmt)
          ) {
            columnStyles[i] = { ...(columnStyles[i] || {}), halign: "right" };
          }
        });

        autoTable(doc, {
          head,
          body,
          startY: y + 12,
          styles: {
            fontSize: 9,
            lineWidth: 0.1,
            lineColor: 80,
            cellPadding: 4,
            overflow: "linebreak",
          },
          headStyles: {
            fillColor: [220, 220, 220],
            textColor: 20,
            halign: "left",
          }, // mais contraste
          alternateRowStyles: { fillColor: [245, 245, 245] },
          columnStyles,
          theme: "grid",
          didDrawPage: (data) => {
            const pg = `Página ${doc.internal.getNumberOfPages()}`;
            doc.setFontSize(9);
            doc.text(
              pg,
              pageW - margin - doc.getTextWidth(pg),
              doc.internal.pageSize.getHeight() - 10
            );
          },
        });

        // Resumo
        if (summary.length) {
          const lastY = doc.lastAutoTable.finalY || y + 60;
          autoTable(doc, {
            head: [["Resumo", "Valor"]],
            body: summary.map((s) => [
              s.label,
              s.isCurrency
                ? (Number(s.value) || 0).toLocaleString("pt-BR", {
                    style: "currency",
                    currency: "BRL",
                  })
                : s.value,
            ]),
            startY: lastY + 12,
            styles: { fontSize: 10, cellPadding: 4 },
            headStyles: { fillColor: [230, 230, 230] },
            columnStyles: { 1: { halign: "right" } },
            theme: "grid",
          });
        }

        // Salva
        const arq = (this.title || this.pageTitle || "relatorio") + ".pdf";
        doc.save(arq);
      } catch (e) {
        console.error("PDF erro", e);
        this.$q?.notify?.({
          type: "negative",
          position: 'center',
          message: "Falha ao exportar PDF.",
        });
      }
    },

    async exportarExcel() {
      try {
        const grid = this.$refs.grid && this.$refs.grid.instance;
        if (!grid) return;

        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet("Dados");

        await exportDataGrid({
          component: grid,
          worksheet,
          // preserve os formatos visuais:
          customizeCell: ({ gridCell, excelCell }) => {
            if (!gridCell) return;

            // currency
            const col =
              this.gridColumns.find(
                (c) => c.dataField === gridCell.column?.dataField
              ) || {};
            const tipoFmt = (col?.format?.type || col?._tipoFmt || "")
              .toString()
              .toLowerCase();

            if (tipoFmt === "fixedpoint" && Number.isFinite(gridCell.value)) {
              excelCell.numFmt = "#,##0.00";
            }
            // datas
            if (
              gridCell.column?.dataType === "date" &&
              gridCell.value instanceof Date
            ) {
              excelCell.value = new Date(
                gridCell.value.getFullYear(),
                gridCell.value.getMonth(),
                gridCell.value.getDate()
              );
              excelCell.numFmt = "dd/mm/yyyy";
            }
          },
        });

        const buffer = await workbook.xlsx.writeBuffer();
        const arquivo =
          (this.tituloMenu || "relatorio").replace(/[\s\/\\:?<>|"]/g, "_") +
          ".xlsx";
        //
        saveAs(
          new Blob([buffer], { type: "application/octet-stream" }),
          arquivo
        );
        //this.$q?.notify?.({ type: 'positive', message: 'Excel exportado com sucesso' });
        this.notifyOk("Excel exportado com sucesso!");
        //
      } catch (err) {
        console.error("Falha ao exportar Excel:", err);
        //this.$q?.notify?.({ type: 'negative', message: 'Erro ao exportar Excel' });
        this.notifyErr("Erro ao exportar Excel !");
      }
    },

exportarExcelDashboard() {
  const gridRef = this.$refs.gridDashboard
  const inst = gridRef && gridRef.instance

  console.log('[dash] gridRef', gridRef, 'instance', inst)

  if (inst && inst.exportToExcel) {
    inst.exportToExcel(false)
  } else {
    // fallback, caso precise depurar
    this.$q && this.$q.notify && this.$q.notify({
      type: 'warning',
      message: 'Grid ainda não está pronta para exportação.'
    })
  }
},

async montarGridDashboardDados(payload) {
    
  console.log('[dash] montarGridDashboardDados - payload:', payloadGrid);

      this.lastPayloadGrid = payload

      // 1) busca dos dados da grid
      const respDados = await execProcedure('pr_egis_processo_modulos', [payload])
      const linhas = (respDados && respDados[0] && respDados[0].linhas) || []

      // 2) busca do mapa de atributos para esse menu/procedure
      const payloadMeta = [{
        cd_parametro: 3,
        cd_menu_id: Number(payload.cd_menu),
        nome_procedure: payload.nome_procedure || payload.nome_procedure_grid || ''
      }]

      const respMeta = await execProcedure('pr_egis_pesquisa_mapa_atributo', [payloadMeta])
      const meta = (respMeta && respMeta[0] && respMeta[0].linhas) || []

      console.log('meta dados ->', meta);

      this.nmMenuTitulo = (respMeta && respMeta[0] && respMeta[0].nm_menu_titulo) || ''

      // 3) monta colunas + seta linhas
      //this.colunasGrid = this.montarColunasGrid(meta)

      this.nmMenuTitulo = meta?.[0]?.nm_menu_titulo || ''
      this.colunasGrid = this.montarColunasGrid(meta, linhas) // ✅ passa linhas

      this.rowsGrid = linhas

      console.log('linhas grid dashboard 2', this.rowsGrid)
      console.log('[dash] montarGridDashboardDados - payload:', payload);


      // 4) rola até a grid depois que o DOM atualiza

      this.$nextTick(() => {
        const el = this.$refs.gridCard
        if (el && el.scrollIntoView) {
          el.scrollIntoView({ behavior: 'smooth', block: 'start' })
        }
      })
    
  },


    montarGridDashboard (rows, payload , meta = []) {
    

     // console.log('[dash] montarGridDashboard - rows recebidas:', rows)

    if (!Array.isArray(rows) || !rows.length) {
      this.rowsGrid = []
      this.colunasGrid = []
       this.nmMenuTitulo = ''
      return
    }

    // título do menu (se vier no meta)
    this.nmMenuTitulo = meta?.[0]?.nm_titulo || meta?.[0]?.nm_menu_titulo || ''
    //

  console.log('[dash] montarGridDashboard - nmMenuTitulo:', this.nmMenuTitulo)

// index do meta por campo (ajuste o nome do campo conforme seu retorno real)
  const metaByField = {}
  meta.forEach(m => {
    const field = (m.nm_atributo || m.nm_campo || m.dataField || m.campo || '').toString()
    if (field) metaByField[field] = m
  })

    const primeiro = rows[0]

    const colunas = Object.keys(primeiro).map((campo) => {
      const v = primeiro[campo]
      const m = metaByField[campo] || {}
      
      let dataType = 'string'
      let format = undefined
      let calculateCellValue = undefined

      const metaDatatype = String(m.nm_datatype || '').toLowerCase()
      const metaFormato  = String(m.nm_formato || '').toLowerCase()

      // detectar date (ISO ou YYYY-MM-DD)
    if (typeof v === 'string' && (/^\d{4}-\d{2}-\d{2}$/.test(v) || /^\d{4}-\d{2}-\d{2}t/i.test(v))) {
      dataType = 'date'
      format = 'dd/MM/yyyy'
      calculateCellValue = (row) => this.parseDateNoTZ(row[campo])
    }

    // number/currency
    if (typeof v === 'number') {
      dataType = 'number'

      const nome = campo.toLowerCase()
      const metaTipo = (m.tp_dado || m.tp_atributo || '').toString().toLowerCase()

      const isCurrency =
        metaTipo.includes('moeda') ||
        metaTipo.includes('currency') ||
        nome.startsWith('vl_') ||
        nome.includes('valor') ||
        nome.includes('total') ||
        nome.includes('receita') ||
        nome.includes('meta')

      if (isCurrency) {
        format = { type: 'currency', currency: 'BRL', precision: 2 }
      } else {
        format = { type: 'fixedPoint', precision: 2 }
      }
    }

      return {
        dataField: campo,
        caption: m.nm_atributo_consulta || campo,   // se quiser, depois mapeia pra título mais bonito
        dataType,
        format,
        calculateCellValue,
        // flags do mapa
        ic_contagem: m.ic_contador_grid || m.ic_contagem || 'N',
        ic_soma: m.ic_total_grid || m.ic_soma || 'N',
      }
    })

    this.rowsGrid = rows
    this.colunasGrid = colunas

    //console.log('[dash] rowsGrid para grid:', this.rowsGrid)
    //console.log('[dash] colunasGrid:', this.colunasGrid)

  },

    // helpers que substituem optional chaining no template
    temLookup(f) {
      return (
        f && f.nm_lookup_tabela && String(f.nm_lookup_tabela).trim() !== ""
      );
    },
    inputType(f) {
      if (!f || !f.nm_atributo) return "text";
      var low = String(f.nm_atributo).toLowerCase();
      return low.indexOf("dt_") >= 0 ? "date" : "text";
    },

    loadScript(src) {
      return new Promise((resolve, reject) => {
        // evita inserir duplicado
        if ([...document.scripts].some((s) => s.src.includes(src)))
          return resolve();
        const s = document.createElement("script");
        s.src = src;
        s.async = true;
        s.onload = resolve;
        s.onerror = reject;
        document.head.appendChild(s);
      });
    },

detectarTipo(tipo) {
  tipo = String(tipo || "").toLowerCase()
  if (tipo.includes("date")) return "date"
  if (tipo.includes("number") || tipo.includes("currency")) return "number"
  return "string"
},

detectarFormato(tipo) {
  tipo = String(tipo || "").toLowerCase()
  if (tipo.includes("currency")) return "#,##0.00"
  if (tipo.includes("number")) return "#,##0.00"
  if (tipo.includes("date")) return "dd/MM/yyyy"
  return undefined
},

detectDataType (v) {
    if (v == null || v === "") return "string";
    if (typeof v === "number") return "number";

    const s = String(v);

    // formatos de data mais comuns: 2025-12-31 ou 31/12/2025
    if (/^\d{4}-\d{2}-\d{2}/.test(s) || /^\d{2}[\/-]\d{2}[\/-]\d{4}$/.test(s)) {
      return "date";
    }

    // número em string: "123", "123,45", "-5.2"
    if (/^-?\d+([.,]\d+)?$/.test(s)) return "number";

    return "string";
  },



    async ensureChartJs() {
      if (window.Chart) return;
      await new Promise(function (resolve, reject) {
        const s = document.createElement("script");
        s.src = CDN_CHART;
        s.onload = resolve;
        s.onerror = reject;
        document.head.appendChild(s);
      });
    },
    resetTimer() {
      clearInterval(this.timerId);
      this.tempoRestante = 600;
      const self = this;
      this.timerId = setInterval(function () {
        if (!self.autoRefreshAtivo) return;
        self.tempoRestante--;
        if (self.tempoRestante <= 0) {
          self.iniciarDashboard(true);
          self.tempoRestante = 600;
        }
      }, 1000);
    },
    moeda(v) {
      const n = parseFloat(v || 0);
      return n.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
    },

    
  parseDateNoTZ(value) {
    if (!value) return value

    // "2025-12-01" (só data)
    if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value)) {
      // força meia-noite local
      return new Date(value + 'T00:00:00')
    }

    // "2025-12-01T00:00:00.000Z" ou com T
    if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2}t/i.test(value)) {
      const d = new Date(value)
      // remove o shift de timezone
      return new Date(d.getTime() + d.getTimezoneOffset() * 60000)
    }

    return value
  },


    corCard(i) {
      const classes = [
        "indicador-blue",
        "indicador-green",
        "indicador-orange",
        "indicador-cyan",
      ];
      return classes[i % classes.length];
    },

    async onRefreshConsulta () {
      // se tiver payload da última grid, recarrega
      if (this.ultimoPayloadGrid) {
       await this.montarGridDashboardDados(this.ultimoPayloadGrid)
      }
    },

    fmtISO (valor) {
  if (!valor) return ''

  const s = String(valor).trim()

  // dd/mm/yyyy ou dd-mm-yyyy  -> yyyy-mm-dd
  const mBR = s.match(/^(\d{2})[\/-](\d{2})[\/-](\d{4})/)
  if (mBR) {
    const [, dd, mm, yyyy] = mBR
    return `${yyyy}-${mm}-${dd}`
  }

  // yyyy-mm-ddThh:mm:ss ou yyyy-mm-dd
  const mISO = s.match(/^(\d{4})-(\d{2})-(\d{2})/)
  if (mISO) {
    return `${mISO[1]}-${mISO[2]}-${mISO[3]}`
  }

  // se não reconheceu o formato, devolve como veio (sem usar new Date)
  return s
},

    async iniciarDashboard() {
      try {
        this.loading = true;
        const cd_modulo = localStorage.cd_modulo || Number(
          localStorage.getItem("cd_modulo") ||
            sessionStorage.getItem("cd_modulo") ||
            999999
        );
        const cd_usuario =
          localStorage.cd_usuario ||
          Number(sessionStorage.getItem("cd_usuario") || 0);
        const dt_inicial =
          localStorage.dt_inicial ||
          sessionStorage.getItem("dt_inicial_padrao");
        const dt_final =
          localStorage.dt_final || sessionStorage.getItem("dt_final_padrao");

        console.log("módulo:", cd_modulo, cd_usuario, dt_final, dt_final);

        //
        await this.carregarGridsDinamicas(
          cd_modulo,
          cd_usuario,
          dt_inicial,
          dt_final
        );
        //

        const basePayload = [
          {
            ic_json_parametro: "S",
            cd_modulo: cd_modulo,
            cd_parametro: 100,
            cd_usuario: cd_usuario,
            dt_inicial: dt_inicial,
            dt_final: dt_final,
            ic_json_parametro: "S",
            ...JSON.parse(
              sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
            ),
          },
        ];

        console.log("payload dash:", basePayload);

        const dados = await execProcedure(
          "pr_egis_processo_dashboard_modulos",
          basePayload
        );

        if (!Array.isArray(dados)) return;

        this.indicadores = dados.filter(function (d) {
          return d.ic_formato !== 1;
        });
        this.tituloModulo =
          dados[0] && dados[0].nm_modulo ? dados[0].nm_modulo : "Título";

        if (dados[0] && dados[0].ic_dia_periodo === "S") {
          const periodo = await execProcedure(
            "pr_egis_processo_dashboard_modulos",
            [
              {
                cd_modulo: cd_modulo,
                cd_parametro: 50,
                cd_usuario: cd_usuario,
                dt_inicial: dt_inicial,
                dt_final: dt_final,
                ic_json_parametro: "S",
                ...JSON.parse(
                  sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
                ),
              },
            ]
          );
          const d = periodo && periodo[0];
          if (d) {
            this.diasPeriodo = [
              { label: "Dias Úteis", valor: d.Dia_Uteis },
              { label: "Transcorridos", valor: d.Dia_Transcorridos },
              { label: "Restantes", valor: d.Dia_Restante },
              { label: "Decorrido", valor: (d.Tempo_Decorrido || 0) + "%" },
              { label: "Ano", valor: d.Ano || "" },
            ];
          }
        }

        await this.renderGraficos(cd_modulo, cd_usuario, dt_inicial, dt_final);

        //
        await this.carregarGridsDinamicas(
          cd_modulo,
          cd_usuario,
          dt_inicial,
          dt_final
        );
      } finally {
        this.loading = false;
      }
    },

    //
    //GRÁFICOS
    //
    async renderGraficos(cd_modulo, cd_usuario, dt_inicial, dt_final) {
      const self = this;

      this.loadingGraficos = true; // liga loading

      try {
    // destrói todos os gráficos existentes
    Object.keys(this.charts).forEach(function (k) {
      if (self.charts[k]) {
        self.charts[k].destroy();
        self.charts[k] = null;
      }
    });

    console.log(
      "graficos parametro --> ",
      cd_modulo,
      cd_usuario,
      dt_inicial,
      dt_final
    );

    // ===================== DIÁRIO =====================
    const diarios = await execProcedure("pr_egis_processo_dashboard_modulos", [
      {
        cd_modulo,
        cd_parametro: 10,
        cd_usuario,
        dt_inicial,
        dt_final,
        ic_json_parametro: "S",
        ...JSON.parse(
          sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
        )
      }
    ]);

    if (Array.isArray(diarios) && diarios.length) {
      const ultimoDia = diarios[diarios.length - 1];
      const totalHoje = Number(ultimoDia?.vl_total || 0);

        // soma todos os vl_total
        const totalMes = diarios.reduce(
          (acc, item) => acc + Number(item?.vl_total || 0),
          0
        );

      const totalFormatado = totalMes.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL"
      });

      const containerDiario = this.$el.querySelector("#grafico-diario");
      const tituloDiario = containerDiario?.querySelector("h2");
      if (tituloDiario) {
        tituloDiario.textContent = `Diário - Faturamento Mês ${totalFormatado}`;
      }

      const ctx = this.$refs.graficoDiario.getContext("2d");
      this.charts.diario = new window.Chart(ctx, {
        type: "line",
        data: {
          labels: diarios.map(d => d.cd_dia + "/" + d.cd_mes),
          datasets: [
            {
              label: "Total diário",
              data: diarios.map(d => Number(d.vl_total || 0)),
              fill: false,
              borderColor: "rgba(75,192,192,1)",
              tension: 0.2
            }
          ]
        },
        options: {
          responsive: true,
          scales: { y: { beginAtZero: true } }
        }
      });
    }

    // ===================== MENSAL =====================
    const mensais = await execProcedure(
      "pr_egis_processo_dashboard_modulos",
      [
        {
          cd_modulo,
          cd_parametro: 200,
          cd_usuario,
          dt_inicial,
          dt_final,
          ic_json_parametro: "S",
          ...JSON.parse(
            sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
          )
        }
      ]
    );

    if (Array.isArray(mensais) && mensais.length) {
      const totalAnual = mensais.reduce(
        (acc, d) => acc + Number(d.vl_total || 0),
        0
      );

      const totalFormatado = totalAnual.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL"
      });

      const containerMensal = this.$el.querySelector("#grafico-mensal");
      const tituloMensal = containerMensal?.querySelector("h2");
      if (tituloMensal) {
        tituloMensal.textContent = `Mensal - Faturamento Ano ${totalFormatado}`;
      }

      const ctx = this.$refs.graficoMensal.getContext("2d");
      this.charts.mensal = new window.Chart(ctx, {
        type: "bar",
        data: {
          labels: mensais.map(d => (d.nm_mes || d.cd_mes) + "/" + d.cd_ano),
          datasets: [
            {
              label: "Total mensal (R$)",
              data: mensais.map(d => Number(d.vl_total || 0)),
              backgroundColor: "rgba(255,159,64,0.6)",
              yAxisID: "y"
            },
            {
              label: "% Participação",
              data: mensais.map(d => Number(d.participacao_percentual || 0)),
              type: "line",
              borderColor: "rgba(54,162,235,0.9)",
              backgroundColor: "rgba(54,162,235,0.3)",
              yAxisID: "y1"
            },
            {
              label: "Variação MoM (%)",
              data: mensais.map(d => Number(d.variacao_mom_percentual || 0)),
              type: "line",
              borderColor: "rgba(255,99,132,0.9)",
              backgroundColor: "rgba(255,99,132,0.3)",
              yAxisID: "y1"
            }
          ]
        },
        options: {
          responsive: true,
          interaction: { mode: "index", intersect: false },
          stacked: false,
          scales: {
            y: {
              type: "linear",
              position: "left",
              beginAtZero: true,
              title: { display: true, text: "Faturamento (R$)" }
            },
            y1: {
              type: "linear",
              position: "right",
              beginAtZero: true,
              grid: { drawOnChartArea: false },
              title: { display: true, text: "% Indicadores" }
            }
          }
        }
      });
    }

    // ===================== ANUAL =====================
    const anuais = await execProcedure(
      "pr_egis_processo_dashboard_modulos",
      [
        {
          cd_modulo,
          cd_parametro: 300,
          cd_usuario,
          dt_inicial,
          dt_final,
          ic_json_parametro: "S",
          ...JSON.parse(
            sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
          )
        }
      ]
    );

    if (Array.isArray(anuais) && anuais.length) {
      const totalPeriodo = anuais.reduce(
        (acc, d) => acc + Number(d.vl_total || 0),
        0
      );

      const totalFormatado = totalPeriodo.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL"
      });

      const containerAnual = this.$el.querySelector("#grafico-anual");
      const tituloAnual = containerAnual?.querySelector("h2");
      if (tituloAnual) {
        tituloAnual.textContent = `Anual - Faturamento Total ${totalFormatado}`;
      }

      const ctx = this.$refs.graficoAnual.getContext("2d");
      this.charts.anual = new window.Chart(ctx, {
        type: "bar",
        data: {
          labels: anuais.map(d => d.cd_ano),
          datasets: [
            {
              label: "Total anual (R$)",
              data: anuais.map(d => Number(d.vl_total || 0)),
              backgroundColor: "rgba(153,102,255,0.6)",
              yAxisID: "y"
            },
            {
              label: "YOY (%)",
              data: anuais.map(d => Number(d.yoy_percentual || 0)),
              type: "line",
              borderColor: "rgba(255,99,132,0.9)",
              backgroundColor: "rgba(255,99,132,0.3)",
              yAxisID: "y1"
            },
            {
              label: "Participação (%)",
              data: anuais.map(d => Number(d.participacao_percentual || 0)),
              type: "line",
              borderColor: "rgba(54,162,235,0.9)",
              backgroundColor: "rgba(54,162,235,0.3)",
              yAxisID: "y1"
            }
          ]
        },
        options: {
          responsive: true,
          interaction: { mode: "index", intersect: false },
          stacked: false,
          scales: {
            y: {
              type: "linear",
              position: "left",
              beginAtZero: true,
              title: { display: true, text: "Faturamento (R$)" }
            },
            y1: {
              type: "linear",
              position: "right",
              beginAtZero: true,
              grid: { drawOnChartArea: false },
              title: { display: true, text: "% Indicadores" }
            }
          }
        }
      });
    }

    // ===================== CLIENTES =====================
    const clientes = await execProcedure(
      "pr_egis_processo_dashboard_modulos",
      [
        {
          cd_modulo,
          cd_parametro: 500,
          cd_usuario,
          dt_inicial,
          dt_final,
          ic_json_parametro: "S",
          ...JSON.parse(
            sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
          )
        }
      ]
    );

    if (Array.isArray(clientes) && clientes.length) {
      const ctx = this.$refs.graficoVendas.getContext("2d");

      this.charts.clientes = new window.Chart(ctx, {
        type: "bar",
        data: {
          labels: clientes.map(d => d.nm_fantasia_cliente),
          datasets: [
            {
              label: "Faturamento (R$)",
              data: clientes.map(d => Number(d.vl_total || 0)),
              backgroundColor: "rgba(255,159,64,0.6)",
              xAxisID: "x"
            },
            {
              label: "Participação (%)",
              data: clientes.map(d => Number(d.pc_cliente || 0)),
              type: "line",
              borderColor: "rgba(54,162,235,0.9)",
              backgroundColor: "rgba(54,162,235,0.3)",
              xAxisID: "x1"
            }
          ]
        },
        options: {
          responsive: true,
          indexAxis: "y",
          interaction: { mode: "index", intersect: false },
          stacked: false,
          scales: {
            x: {
              type: "linear",
              position: "top",
              beginAtZero: true,
              title: { display: true, text: "Faturamento (R$)" }
            },
            x1: {
              type: "linear",
              position: "bottom",
              beginAtZero: true,
              grid: { drawOnChartArea: false },
              title: { display: true, text: "% Participação" }
            }
          },
          plugins: {
            title: {
              display: true,
              text: "Top 10 Clientes - Faturamento e Participação"
            },
            legend: { position: "bottom" },
            tooltip: {
              callbacks: {
                label: function (context) {
                  if (context.dataset.label === "Faturamento (R$)") {
                    return "R$ " + context.raw.toLocaleString("pt-BR");
                  } else {
                    return context.raw + "%";
                  }
                }
              }
            }
          }
        }
      });
    }

    // ===================== VENDEDORES =====================
    const vendedores = await execProcedure(
      "pr_egis_processo_dashboard_modulos",
      [
        {
          cd_modulo,
          cd_parametro: 600,
          cd_usuario,
          dt_inicial,
          dt_final,
          ic_json_parametro: "S",
          ...JSON.parse(
            sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
          )
        }
      ]
    );

    if (Array.isArray(vendedores) && vendedores.length) {
      const ctx = this.$refs.graficoVendedores.getContext("2d");

      this.charts.vendedores = new window.Chart(ctx, {
        type: "bar",
        data: {
          labels: vendedores.map(d => d.nm_fantasia_vendedor),
          datasets: [
            {
              label: "Faturamento (R$)",
              data: vendedores.map(d => Number(d.vl_total || 0)),
              backgroundColor: "rgba(255,159,64,0.6)",
              yAxisID: "y"
            },
            {
              label: "% Atingimento da Meta",
              data: vendedores.map(d => Number(d.pc_atingimento || 0)),
              type: "line",
              borderColor: "rgba(54,162,235,0.9)",
              backgroundColor: "rgba(54,162,235,0.3)",
              yAxisID: "y1"
            },
            {
              label: "% Participação",
              data: vendedores.map(d => Number(d.pc_vendedor || 0)),
              type: "line",
              borderColor: "rgba(255,99,132,0.9)",
              backgroundColor: "rgba(255,99,132,0.3)",
              yAxisID: "y1"
            }
          ]
        },
        options: {
          responsive: true,
          interaction: { mode: "index", intersect: false },
          stacked: false,
          scales: {
            y: {
              type: "linear",
              position: "left",
              beginAtZero: true,
              title: { display: true, text: "Faturamento (R$)" }
            },
            y1: {
              type: "linear",
              position: "right",
              beginAtZero: true,
              grid: { drawOnChartArea: false },
              title: { display: true, text: "% Indicadores" }
            }
          },
          plugins: {
            title: {
              display: true,
              text: "Ranking de Vendedores - Faturamento, Meta e Participação"
            },
            legend: { position: "bottom" },
            tooltip: {
              callbacks: {
                label: function (context) {
                  const vendedor =
                    context.chart.data.labels[context.dataIndex];
                  const datasetLabel = context.dataset.label;
                  const valor = context.raw;

                  if (datasetLabel === "Faturamento (R$)") {
                    const meta = vendedores[context.dataIndex].vl_meta;
                    const falta = vendedores[context.dataIndex].vl_falta_meta;
                    const excedente =
                      vendedores[context.dataIndex].vl_excedente;
                    return (
                      `${vendedor}: R$ ${valor.toLocaleString(
                        "pt-BR"
                      )} (Meta R$ ${meta?.toLocaleString("pt-BR")})` +
                      (falta > 0
                        ? ` | Faltam R$ ${falta.toLocaleString("pt-BR")}`
                        : "") +
                      (excedente > 0
                        ? ` | Excedeu R$ ${excedente.toLocaleString("pt-BR")}`
                        : "")
                    );
                  } else {
                    return `${datasetLabel}: ${valor}%`;
                  }
                }
              }
            }
          }
        }
      });
    }

    // ===================== CATEGORIAS (ROSCA) =====================
    const categoria = await execProcedure(
      "pr_egis_processo_dashboard_modulos",
      [
        {
          cd_modulo,
          cd_parametro: 400,
          cd_usuario,
          dt_inicial,
          dt_final,
          ic_json_parametro: "S",
          ...JSON.parse(
            sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
          )
        }
      ]
    );

    if (Array.isArray(categoria) && categoria.length) {
      const ctxR = this.$refs.graficoCategorias.getContext("2d");

      if (this.charts.rosca) {
        this.charts.rosca.destroy();
      }

      this.charts.rosca = new window.Chart(ctxR, {
        type: "doughnut",
        data: {
          labels: categoria.map(d => d.nm_categoria_produto),
          datasets: [
            {
              data: categoria.map(d => Number(d.vl_total_produto || 0)),
              backgroundColor: categoria.map(
                (_d, i) => "hsl(" + i * 45 + ",70%,60%)"
              )
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          cutout: "55%",
          layout: { padding: 16 },
          plugins: {
            tooltip: {
              callbacks: {
                label: function (context) {
                  const valor = context.raw || 0;
                  const cat = context.label || "";
                  const total =
                    context.chart.data.datasets[0].data.reduce(
                      (a, b) => a + (b || 0),
                      0
                    );
                  const perc = total
                    ? ((valor / total) * 100).toFixed(2)
                    : "0.00";
                  return `${cat}: R$ ${valor.toLocaleString(
                    "pt-BR"
                  )} (${perc}%)`;
                }
              }
            },
            legend: {
              position: "bottom",
              labels: {
                boxWidth: 12,
                padding: 8,
                font: { size: 11 }
              }
            },
            title: { display: true, text: "Faturamento por Categoria" }
          }
        }
      });
    }

    // ===================== PRODUTOS =====================
    const produtos = await execProcedure(
      "pr_egis_processo_dashboard_modulos",
      [
        {
          cd_modulo,
          cd_parametro: 700, // ajuste se o procedure usar outro código
          cd_usuario,
          dt_inicial,
          dt_final,
          ic_json_parametro: "S",
          ...JSON.parse(
            sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
          )
        }
      ]
    );

    if (Array.isArray(produtos) && produtos.length) {
  const topProdutos = [...produtos]
    .sort((a, b) => toNumberBR(b.vl_total_produto) - toNumberBR(a.vl_total_produto))
    .slice(0, 10);

  const ctx = this.$refs.graficoProdutos.getContext("2d");

  // garanta que existe altura suficiente no container
  // ex.: via CSS: #grafico-produto canvas { height: 360px; }

  this.charts.produtos = new window.Chart(ctx, {
    type: "bar",
    data: {
      labels: topProdutos.map(d => d.nm_produto),
      datasets: [
        {
          label: "Faturamento (R$)",
          data: topProdutos.map(d => toNumberBR(d.vl_total_produto)),
          backgroundColor: "rgba(255,159,64,0.6)",
          xAxisID: "x"   // eixo horizontal principal (valores)
        },
        {
          label: "% Participação",
          data: topProdutos.map(d => toNumberBR(d.pc_produto)),
          type: "line",
          borderColor: "rgba(54,162,235,0.9)",
          backgroundColor: "rgba(54,162,235,0.3)",
          xAxisID: "x1"  // eixo horizontal secundário (percentual)
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      indexAxis: "y", // horizontal para nomes longos
      interaction: { mode: "index", intersect: false },
      stacked: false,
      scales: {
        // eixo de valores (faturamento)
        x: {
          type: "linear",
          position: "top",
          beginAtZero: true,
          title: { display: true, text: "Faturamento (R$)" },
          ticks: {
            callback: v => "R$ " + toNumberBR(v).toLocaleString("pt-BR")
          }
        },
        // eixo de valores (percentual)
        x1: {
          type: "linear",
          position: "bottom",
          beginAtZero: true,
          grid: { drawOnChartArea: false },
          title: { display: true, text: "% Participação" },
          ticks: {
            callback: v => `${v}%`
          }
        },
        // eixo de categorias (nomes dos produtos)
        y: {
          type: "category",
          ticks: {
            // melhora legibilidade de nomes grandes
            callback: label => String(label).length > 38 ? String(label).slice(0, 38) + "…" : label
          }
        }
      },
      plugins: {
        title: {
          display: true,
          text: "Top 10 Produtos - Faturamento e Participação"
        },
        legend: { position: "bottom" },
        tooltip: {
          callbacks: {
            label: function (context) {
              const val = context.raw || 0;
              if (context.dataset.label === "Faturamento (R$)") {
                return "R$ " + toNumberBR(val).toLocaleString("pt-BR");
              } else {
                return `${toNumberBR(val)}%`;
              }
            }
          }
        }
      }
    }
  });
}


  if (Array.isArray(produtos)) {
  // pega apenas os 5 primeiros ordenados por faturamento
  const topProdutos = produtos
    .sort((a, b) => b.vl_total_produto - a.vl_total_produto)
    .slice(0, 5);

  const ctxP = this.$refs.graficoProduto5.getContext("2d");

  this.charts.produtos = new window.Chart(ctxP, {
    type: "doughnut",
    data: {
      labels: topProdutos.map(d => d.nm_produto),
      datasets: [
        {
          data: topProdutos.map(d => Number(d.vl_total_produto || 0)),
          backgroundColor: topProdutos.map((_d, i) => "hsl(" + i * 72 + ",70%,60%)"),
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      cutout: "55%",
      plugins: {
        title: {
          display: true,
          text: "Top 5 Produtos - Participação no Faturamento"
        },
        legend: {
          position: "bottom",
          labels: {
            boxWidth: 12,
            padding: 8,
            font: { size: 11 }
          }
        },
        tooltip: {
          callbacks: {
            label: function (context) {
              const valor = context.raw;
              const produto = context.label;
              const total = context.chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
              const perc = ((valor / total) * 100).toFixed(2);
              return `${produto}: R$ ${valor.toLocaleString("pt-BR")} (${perc}%)`;
            }
          }
        }
      }
    }
  });
}

  } finally {
    this.loadingGraficos = false; // desliga loading
  }
},



    //
    async carregarGridsDinamicas(cd_modulo, cd_usuario, dt_inicial, dt_final) {
      
      const menus = await execProcedure("pr_egis_processo_dashboard_modulos", [
        {
          cd_modulo: cd_modulo,
          cd_parametro: 99,
          cd_usuario: cd_usuario,
          dt_inicial: dt_inicial,
          dt_final: dt_final,
          ic_json_parametro: "S",
          ...JSON.parse(
            sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
          ),
        },
      ]);

      console.log('menus', menus);

      if (!Array.isArray(menus)) return;

      this.secoesGrid = [];

      for (let i = 0; i < menus.length; i++) {
        const m = menus[i];
        const cd_menu = m.cd_menu;
        const nm_menu = m.nm_menu;
        const cd_parametro = m.cd_parametro;

        sessionStorage.setItem("cd_menu", cd_menu);

        const mPayload = await payloadTabela({
          cd_form: sessionStorage.getItem("cd_form"),
          cd_menu: cd_menu,
          cd_usuario: cd_usuario,
        });

        console.log('payload tabela grid dashboard', mPayload);

        const resultado  = await execProcedure("pr_egis_processo_modulos", [
          {
            cd_modulo: cd_modulo,
            cd_parametro: cd_parametro,
            cd_menu: cd_menu,
            cd_usuario: cd_usuario,
            dt_inicial: dt_inicial,
            dt_final: dt_final,
            ic_json_parametro: "S",
            ...JSON.parse(
              sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
            ),
          },
        ]);

        //const rows = resultado[0] || [];

        const rows = resultado || []; //.data && resultado.data.linhas ? resultado.data.linhas : []

        
        console.log("linhas grid dashboard", rows, mPayload);

        //console.log('linhas grid dashboard', rows);

        this.montarGridDashboard(rows,'', mPayload)

        }
    },

  montarColunasGrid(meta, linhas) {
    if (!Array.isArray(linhas) || !linhas.length) return []

    const primeiraLinha = linhas[0] || {}
    const metaByField = {}
      ;(meta || []).forEach(m => {
    if (m?.nm_atributo) metaByField[m.nm_atributo] = m
  })

  const mapTipo = (m) => {
    const t = String(m.nm_datatype || '').toLowerCase()
    if (t.includes('date')) return 'date'
    if (t.includes('number') || t.includes('float') || t.includes('int')) return 'number'
    return 'string'
  }

  const isIsoDate = (v) =>
    typeof v === 'string' &&
    (/^\d{4}-\d{2}-\d{2}$/.test(v) || /^\d{4}-\d{2}-\d{2}t/i.test(v))

  const parseDateNoTZ = (value) => {
    if (!value) return value
    if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value)) {
      return new Date(value + 'T00:00:00')
    }
    if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2}t/i.test(value)) {
      const d = new Date(value)
      return new Date(d.getTime() + d.getTimezoneOffset() * 60000)
    }
    return value
  }

  const colunas = []

  ;(meta || []).forEach(m => {
     //const campo = m?.nm_atributo
     const campo = metaByField[m] || {}

    if (!campo) return
    if (!(campo in primeiraLinha)) return

    const dataType = mapTipo(m)
    const col = {
      dataField: campo,
      caption: m.nm_titulo || campo,          // ✅ tradução
      dataType,
      ic_contagem: m.ic_contagem || m.ic_contador_grid ||'N',      // ✅ flags
      ic_soma: m.ic_soma || m.ic_total_grid ||'N',
    }

    // ✅ formato currency / number
    const fmt = String(m.nm_formato || '').toLowerCase()
    if (dataType === 'number') {
      if (fmt === 'currency') col.format = { type: 'currency', currency: 'BRL', precision: 2 }
      else col.format = { type: 'fixedPoint', precision: 2 }
    }

    // ✅ data -1 dia (timezone) usando calculateCellValue (sem mexer nos rows)
    const v = primeiraLinha[campo]
    if (dataType === 'date' && isIsoDate(v)) {
      col.format = 'dd/MM/yyyy'
      col.calculateCellValue = (row) => parseDateNoTZ(row[campo])
    }

    colunas.push(col)
  })

  // fallback se meta vier vazio
  if (!colunas.length) {
    Object.keys(primeiraLinha).forEach(k => {
      colunas.push({
        dataField: k,
        caption: k,
        dataType: typeof primeiraLinha[k] === 'number' ? 'number' : 'string'
      })
    })
  }

  return colunas
},

    async montarFiltrosDinamicos() {
      this.painelFiltrosVisivel = true;
      const cd_menu_dash = Number(sessionStorage.getItem("cd_menu") || 0);
      const cd_usuario = Number(sessionStorage.getItem("cd_usuario") || 0);
      const filtros = await getMenuFiltro({
        cd_menu: cd_menu_dash,
        cd_usuario: cd_usuario,
      });
      this.filtros = Array.isArray(filtros) ? filtros : [];

      this.opcoesLookup = {};
      for (let i = 0; i < this.filtros.length; i++) {
        const f = this.filtros[i];
        if (
          f &&
          f.nm_lookup_tabela &&
          String(f.nm_lookup_tabela).trim() !== ""
        ) {
          const dados = await lookup(f.nm_lookup_tabela);
          this.$set(
            this.opcoesLookup,
            f.nm_campo_chave_lookup,
            (dados || []).map(function (op) {
              const value = op[f.nm_campo_chave_lookup];
              const label = op.Descricao || Object.values(op)[1];
              return { value: value, label: label };
            })
          );
        }
      }
    },

    aplicarFiltros() {
      const campos = {};
      Object.keys(sessionStorage)
        .filter(function (k) {
          return k.indexOf("fixo_") === 0;
        })
        .forEach(function (k) {
          campos[k.replace("fixo_", "")] = sessionStorage.getItem(k);
        });

      for (const k in this.valoresFiltro) {
        const v = this.valoresFiltro[k];
        if (Array.isArray(v)) campos[k] = JSON.stringify(v);
        else if (v) campos[k] = v;
      }

      sessionStorage.setItem(
        "camposDinamicos_dashboard",
        JSON.stringify(campos)
      );
      this.resumoFiltros = Object.keys(campos)
        .map(function (k) {
          return k + ": " + campos[k];
        })
        .join(" | ");
      this.painelFiltrosVisivel = false;
      this.iniciarDashboard(true);
    },

    limparFiltros() {
      sessionStorage.removeItem("camposDinamicos_dashboard");
      this.valoresFiltro = {};
      this.resumoFiltros = "";
      this.painelFiltrosVisivel = false;
      this.iniciarDashboard(true);
    },

    //

    async abrirGridDoCard(item) {
      if (!item) return;

      console.log('item = ', item);

      // tenta vários campos possiveis vindos do card

      let keys;
      keys = ["cd_menu"];

      const cdMenu = keys.map((k) => item[k]).find(Boolean);
      
      keys = ["cd_parametro"];
      const cd_parametro = keys.map((k) => item[k]).find(Boolean);

      console.log("módulo, menu/parâmetro do card", this.cd_modulo, cdMenu, cd_parametro);

      if (!cdMenu) return;
      //--------------------------------------------------------------------------------

      const id = "grid-" + String(cdMenu);

      //console.log('id grid -->', id);

      // grava na sessão (o unicoFormEspecial costuma ler daqui)
      sessionStorage.setItem("cd_menu", String(cdMenu));

      if (this.dtInicialResolved)
        sessionStorage.setItem("dt_inicial_padrao", this.dtInicialResolved);
      
       if (this.dtFinalResolved)
        sessionStorage.setItem("dt_final_padrao", this.dtFinalResolved);

      // abre o form dentro do dashboard
      this.selectedMenu = Number(cdMenu);
      this.formKey++; // força recriar o componente para novo menu
      this.showForm = true;

      const payloadGrid = [{
        cd_parametro: cd_parametro,
        cd_modulo: this.cd_modulo,
        cd_form: "0",
        cd_menu: Number(cdMenu),
        cd_usuario: Number(this.cdUsuarioResolved || 0),
        ic_json_parametro: "S",
        dt_inicial: localStorage.dt_inicial || null,
        dt_final: localStorage.dt_final || null,
    }];

    console.log("payload GRID do dashboard:", payloadGrid);
    
    this.headerBanco = localStorage.nm_banco_empresa || '';

      let rows = [];
    
      try {
      const resultado = await execProcedure(
        "pr_egis_processo_modulos",
        payloadGrid,
        this.headerBanco || "EGISSQL"
      );

      // seu execProcedure geralmente retorna o array direto
      rows = Array.isArray(resultado) ? resultado : (resultado?.linhas || []);
      //

    } catch (err) {
      console.error("Erro ao chamar pr_egis_processo_modulos:", err);
      // se der 500 aqui, não deixa travar o restante
      rows = [];
    }

    //payload para o Mapa

    const mPayload = await payloadTabela({
          cd_form: sessionStorage.getItem("cd_form"),
          cd_menu: this.selectedMenu,
          cd_usuario: localStorage.cd_usuario || 0,
        });

        console.log('payload tabela grid dashboard', mPayload);


      console.log("linhas grid dashboard 0 grid", rows);

        // carrega grid
        //this.montarGridDashboard(payloadGrid);
        //

      // 5) Atualiza a grid Vue do dashboard
      this.montarGridDashboard(rows, '', mPayload);
      //

      this.gridContext = {
       cd_menu: Number(item.cd_menu || 0),
       nm_menu_titulo: this.nmMenuTitulo || '',
       // se você precisa usuário/empresa/logo pro relatório:
       nm_usuario: localStorage.usuario,
       Empresa: localStorage.fantasia || localStorage.empresa || '',
       logo: localStorage.nm_caminho_logo_empresa || '',
       }

      console.log("gridContext atualizado:", this.gridContext);

      //Grid
      //Abrir a Grid

      // rola até a área do form
      this.$nextTick(() => {
        var el = this.$refs.gridCard;
        if (el) el.scrollIntoView({ behavior: "smooth", block: "start" });
      });
    },

    // Busca o objeto do menu (procedimento 99) a partir do cd_menu

    async obterMenuPorCd(
      cd_modulo,
      cd_usuario,
      dt_inicial,
      dt_final,
      cd_menu_alvo
    ) {
      console.log("menu alvo --> ", cd_menu_alvo);

      const menus = await execProcedure("pr_egis_processo_dashboard_modulos", [
        {
          cd_modulo: cd_modulo,
          cd_parametro: 100,
          cd_usuario: cd_usuario,
          dt_inicial: dt_inicial,
          dt_final: dt_final,
          ic_json_parametro: "S",
          ...JSON.parse(
            sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
          ),
        },
      ]);

      console.log("menus", menus);

      if (!Array.isArray(menus)) return null;
      return (
        menus.find((m) => String(m.cd_menu) === String(cd_menu_alvo)) || null
      );
    },

    // Monta SOMENTE a grid do cd_menu informado (on-demand)

    async montarGridEspecifica(cd_menu_alvo) {
      try {
        this.loading = true;
        const cd_modulo = Number(
          localStorage.cd_modulo ||
            this.cdModulo ||
            sessionStorage.getItem("cd_dashboard") ||
            sessionStorage.getItem("cd_modulo") ||
            0
        );
        const cd_usuario = Number(
          localStorage.cd_usuario ||
            this.cdUsuario ||
            sessionStorage.getItem("cd_usuario") ||
            0
        );
        const dt_inicial = this.fmtISO(
          localStorage.dt_inicial ||
            this.dtInicial ||
            sessionStorage.getItem("dt_inicial_padrao")
        );
        const dt_final = this.fmtISO(
          localStorage.dt_final ||
            this.dtFinal ||
            sessionStorage.getItem("dt_final_padrao")
        );

        if (!cd_modulo || !cd_usuario || !dt_inicial || !dt_final) return;

        //console.log('modulo para card',cd_modulo);

        const menu = await this.obterMenuPorCd(
          cd_modulo,
          cd_usuario,
          dt_inicial,
          dt_final,
          cd_menu_alvo
        );

        console.log("menu retorno", menu);

        if (!menu) return;

        const cd_menu = menu.cd_menu;
        const nm_menu = menu.nm_menu;
        const cd_parametro = menu.cd_parametro;

        // payload/meta para a grid
        const cd_form =
          localStorage.cd_form || sessionStorage.getItem("cd_form") || "DASH";

        await payloadTabela({
          cd_parametro: 1,
          cd_form,
          cd_menu,
          nm_tabela_origem: "",
          cd_usuario,
        });

        // dados da grid
        const rows = await execProcedure("pr_egis_processo_modulos", [
          {
            cd_modulo,
            cd_parametro,
            cd_usuario,
            dt_inicial,
            dt_final,
            ic_json_parametro: "S",
            ...JSON.parse(
              sessionStorage.getItem("camposDinamicos_dashboard") || "{}"
            ),
          },
        ]);

        console.log('linhas para dash--> ', rows);

        // cria a seção se ainda não existir
        const containerId = "grid-" + cd_menu;
        const jaExiste = this.secoesGrid.some(
          (s) => s.containerId === containerId
        );
        if (!jaExiste) {
          this.secoesGrid.push({ containerId, titulo: nm_menu || "Dados" });
        }

        // monta a DX grid

        //Falta analisar o motivo aqui
        //
        
        this.$nextTick(() => {
          try {
            sessionStorage.setItem(
              "dados_resultado_consulta_" + cd_menu,
              JSON.stringify(rows || [])
            );
            sessionStorage.setItem("cd_menu_tela", cd_menu);
            // montarGridResultadosDevExtreme('#' + containerId, rows || [])
            this.montarGridDX("#" + containerId, rows || []);
          } catch (e) {
            console.warn("Grid DX (on-demand):", e);
          }
        });
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<style scoped>
/* ------------------------------------------------------------------
   IMPORTS (deixe no topo)
------------------------------------------------------------------- */
@import url("https://fonts.googleapis.com/icon?family=Material+Icons");

/* ------------------------------------------------------------------
   LAYOUT GERAL DO DASHBOARD
------------------------------------------------------------------- */
.main-content {
  display: flex;
  flex-direction: column;
  min-height: 100%;
  width: 100%;
  box-sizing: border-box;
  padding: 12px 16px 24px; /* dá respiro geral */
  background: #f9f9f9;
}

.container-alinhado {
  max-width: 1440px;
  width: 100%;
  margin: 0 auto;
}

/* Topo: título + filtros + período */
.linha-topo-dashboard {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 16px;
}

.grupo-esquerda {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.grupo-direita {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.grupo-titulo h2#titulo-modulo {
  margin: 0;
  font-size: 28px;
  line-height: 1.2;
  font-weight: 600;
  color: #222;
}

/* Botão Filtros */
.btn-filtro-card {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  border-radius: 8px;
  background: #fff;
  border: 1px solid #e3e3e3;
  cursor: pointer;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
  font-size: 14px;
}
.btn-filtro-card:hover {
  background: #fafafa;
}

/* Toggle auto-refresh */
.switch-autoupdate {
  display: inline-block;
  position: relative;
  width: 40px;
  height: 22px;
  margin-left: 6px;
}
.switch-autoupdate input {
  display: none;
}
.switch-autoupdate .slider {
  position: absolute;
  inset: 0;
  cursor: pointer;
  background: #ddd;
  border-radius: 22px;
  transition: all 0.2s ease;
}
.switch-autoupdate .slider:before {
  content: "";
  position: absolute;
  left: 3px;
  top: 3px;
  width: 16px;
  height: 16px;
  background: #fff;
  border-radius: 50%;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.15);
  transition: all 0.2s ease;
}
.switch-autoupdate input:checked + .slider {
  background: #00b386;
}
.switch-autoupdate input:checked + .slider:before {
  transform: translateX(18px);
}

/* Período (chips) */
.periodo-dias-container {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}
.dia-indicador {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #fff;
  border: 1px dashed #e2e2e2;
  border-radius: 8px;
  padding: 6px 10px;
  min-width: 80px;
}
.dia-valor {
  font-weight: 700;
  font-size: 13px;
}
.dia-label {
  font-size: 12px;
  color: #555;
}

/* Painel de filtros dinâmicos */
.painel-filtros-card {
  background: #fff;
  border: 1px solid #eee;
  border-radius: 10px;
  padding: 12px;
  margin: 8px 0 20px;
  display: block;
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.04);
}
.painel-filtros-card .form-control {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid #e1e1e1;
  border-radius: 8px;
}
.btn-limpar {
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 8px 12px;
}

/* ------------------------------------------------------------------
   INDICADORES (cards do topo)
------------------------------------------------------------------- */
.indicadores-container {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin: 12px 0 20px;
}
.indicador-card {
  flex: 1;
  min-width: 210px;
  max-width: 260px;
  padding: 14px;
  border-radius: 12px;
  background: #fff;
  border: 2px solid transparent;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.indicador-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
}

.indicador-card .titulo-card {
  font-size: 15px;
  margin: -2px 0 6px;
  color: #444;
}

.indicador-card .titulo-card{
  font-size: 16px;          /* um pouco maior */
  font-weight: 700;         /* mais “PowerBI-like” */
  margin: 0 0 10px;
  color: #1f2937;           /* cinza escuro elegante */
  letter-spacing: .2px;
  line-height: 1.2;
}

/* detalhe visual discreto abaixo do título (opcional) */
.indicador-card .titulo-card::after{
  content: "";
  display: block;
  width: 34px;
  height: 3px;
  border-radius: 99px;
  margin-top: 8px;
  background: rgba(0,0,0,.10); /* neutro, não briga com sua corCard */
}


.indicador-card .valor {
  font-size: 22px;
  font-weight: 700;
  margin-bottom: 2px;
}
.indicador-card .detalhe {
  font-size: 12.5px;
  color: #666;
}
.observacao-card {
  margin-top: 6px;
  font-size: 12.5px;
  color: #000;
}
.indicador-blue {
  border-color: #2196f3;
  color: #2196f3;
}
.indicador-green {
  border-color: #4caf50;
  color: #4caf50;
}
.indicador-orange {
  border-color: #ff9800;
  color: #ff9800;
}
.indicador-cyan {
  border-color: #00bcd4;
  color: #00bcd4;
}

/* versão compacta (se usar) */
.indicadores-container-compactos {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
}

/* ------------------------------------------------------------------
   GRÁFICOS
------------------------------------------------------------------- */
.graficos-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(300px, 1fr));
  gap: 20px;
  width: 100%;
  box-sizing: border-box;
  margin-bottom: 22px;
}
.grafico-item {
  background: #fff;
  border-radius: 12px;
  padding: 14px;
  min-height: 320px;
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.05);
}
.grafico-item > h2 {
  font-size: 22px;
  margin: 0 0 8px;
  color: #222;
}
.grafico-item canvas {
  width: 100% !important;
  height: 260px !important; /* garante altura em branco */
}

/* uma coluna no mobile */
@media (max-width: 900px) {
  .graficos-grid {
    grid-template-columns: 1fr;
  }
  .linha-topo-dashboard {
    flex-direction: column;
    align-items: stretch;
  }
  .grupo-direita {
    justify-content: space-between;
  }
}

/* ------------------------------------------------------------------
   GRIDS DEVEXTREME
------------------------------------------------------------------- */
.form-especial-container {
  width: 100%;
}
.painel-grid {
  background: #fff;
  border-radius: 12px;
  padding: 14px;
  box-shadow: 0 0 8px rgba(0, 0, 0, 0.05);
}
.titulo-grid {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #222;
}
.btn-topo {
  border: 1px solid #e1e1e1;
}

/* força tema claro na grid quando app não está em dark */
.modo-claro-grid .dx-datagrid-headers {
  background: #f2f2f2 !important;
  color: #333 !important;
}
.modo-claro-grid .dx-datagrid-rowsview .dx-row:nth-child(even) {
  background: #fff;
}
.modo-claro-grid .dx-datagrid-rowsview .dx-row:nth-child(odd) {
  background: #f9f9f9;
}
.modo-claro-grid .dx-datagrid .dx-row > td {
  color: #222;
}
.modo-claro-grid .dx-toolbar,
.modo-claro-grid .dx-datagrid-search-panel,
.modo-claro-grid .dx-datagrid-filter-row {
  background: #fff !important;
  color: #000 !important;
}
.modo-claro-grid .dx-datagrid .dx-datagrid-content {
  background: #fff !important;
}

/* garante largura total e não “estoura” */
.dx-datagrid,
.modo-claro-grid .dx-datagrid {
  max-width: 100% !important;
  box-sizing: border-box;
}

/* ------------------------------------------------------------------
   AJUSTES QUE TINHA NO SEU dashboards.css ORIGINAL
   (reaproveitados aqui para manter o visual)
------------------------------------------------------------------- */
#titulo-modulo {
  margin-top: 0 !important;
  padding-top: 0 !important;
}
.layout {
  display: flex;
  min-height: 100vh;
}
.sidebar {
  width: 220px;
  flex-shrink: 0;
}
.sidebar.collapsed {
  width: 40px;
}

/* modo escuro opcional – compatível com seu arquivo */
body.dark .dx-datagrid,
body.dark .dx-datagrid * {
  background-color: transparent !important;
  color: inherit !important;
}
body.dark .dx-datagrid .dx-header-row,
body.dark .dx-datagrid .dx-data-row {
  background-color: #2a2a2a !important;
  color: #eee !important;
}

.btn-scroll-top {
  position: fixed;
  bottom: 22px;
  right: 22px;
  z-index: 1000;
}

.dashboard-card {
  padding: 18px;
  border-radius: 12px;
  background: white;
  box-shadow: 0 3px 12px rgba(0,0,0,0.08);
  margin-bottom: 18px;
}

.dashboard-title {
  font-size: 22px;
  color: #3b3b3b;
  font-weight: 600;
  margin-bottom: 16px;
}

.chart-container {
  background: white;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

@media (max-width: 960px) {
  .dashboard-card {
    padding: 12px;
  }
  .dashboard-title {
    font-size: 18px;
  }
}

.wrapper-grafico-categoria {
  display: flex;
  justify-content: center;
  /* se quiser centralizar vertical: align-items: center; */
}

.grafico-categoria {
  position: relative;
  width: 100%;
  max-width: 600px;   /* ajusta aqui conforme o layout */
  height: 150px;      /* altura fixa p/ não distorcer */
  margin: 0 auto;
}

.grid-title{
  margin:0;
  white-space:nowrap;   /* ✅ não quebra linha */
  overflow:hidden;      /* ✅ não estoura */
  text-overflow:ellipsis; /* ✅ "..." se for grande */
  max-width:100%;
}

.grid-full {
  height: calc(100vh - 220px); /* ajuste fino conforme seu topo/filtros */
  display: flex;
  flex-direction: column;
}

.grid-full #grid-dashboard {
  flex: 1;
  min-height: 300px;
}

.grid-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  gap:12px;
}


.grid-header-left{
  display:flex;
  align-items:baseline;
  gap:10px;
  min-width:0;          /* ✅ permite o texto encolher */
  flex:1 1 auto;
}
.top-det-grid{
  white-space:nowrap;
  flex:0 0 auto;
}
.grid-header-right{
  display:flex;
  gap:8px;
  flex:0 0 auto;        /* ✅ nunca encolhe */
  white-space:nowrap;   /* ✅ botões ficam na mesma linha */
}



</style>
