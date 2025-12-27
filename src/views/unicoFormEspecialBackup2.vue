<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />

    <!-- TOPO no estilo do display-data.vue -->

    <div class="row items-center">
      <transition name="slide-fade">
        <!-- título + seta + badge -->
        <h2 class="content-block col-8" v-show="tituloMenu || title">
          <!-- seta voltar -->
          <q-btn
            flat
            round
            dense
            icon="arrow_back"
            class="q-mr-sm"
            aria-label="Voltar"
            @click="onVoltar"
          />
          {{ tituloMenu || title }}

          <!-- badge com total de registros -->

          <q-badge
            v-if="(qt_registro || recordCount) >= 0"
            align="middle"
            rounded
            color="red"
            :label="qt_registro || recordCount"
            class="q-ml-sm"
          />

          <q-btn
            v-if="cd_tabela > 0"
            rounded
            color="black"
            class="q-mt-sm q-ml-sm"
            icon="add"
            @click="abrirFormEspecial({ modo: 'I', registro: {} })"
          />
        </h2>
      </transition>

      <!-- Ações à direita (como no seu topo) -->

      <div class="col">
        <q-btn
          rounded
          color="deep-orange-9"
          class="q-mt-sm q-ml-sm"
          label="Excel"
          @click="exportarExcel && exportarExcel()"
        />

        <q-btn
          rounded
          color="deep-orange-9"
          class="q-mt-sm q-ml-sm"
          label="PDF"
          @click="exportarPDF && exportarPDF()"
        />

        <q-btn
          rounded
          color="deep-orange-9"
          class="q-mt-sm q-ml-sm"
          icon="description"
          @click="abrirRelatorio"
        />

        <!-- chip cd_menu -->
        <q-btn
          rounded
          color="deep-orange-9"
          class="q-mt-sm q-ml-sm"
          style="float: right"
          icon="info"
          @click="abrirInfo && abrirInfo()"
        />
      </div>
      <q-chip
        v-if="cdMenu || cd_menu"
        rounded
        color="black"
        class="q-mt-sm q-ml-sm"
        size="sm"
        text-color="white"
        :label="`${cdMenu || cd_menu}`"
      />
    </div>

    <!-- MODAL DO FORM ESPECIAL -->

    <q-dialog v-model="dlgForm" persistent>
      <q-card style="min-width: 760px; max-width: 94vw">
        <q-card-section class="row items-center justify-between">
          <div class="text-h6">
            {{ formMode === "I" ? "Novo registro" : "Editar registro" }}
          </div>
          <q-btn icon="close" flat round dense @click="fecharForm()" />
        </q-card-section>

        <q-separator />

        <q-card-section>
          <!-- área para renderizador dinâmico (form_especial.js) -->
          <div ref="formEspecialMount"></div>

          <!-- fallback simples se nada for renderizado dinamicamente -->

          <!-- fallback simples se nada for renderizado dinamicamente -->
          <div v-if="!formRenderizou" class="q-mt-md">
            <div class="row q-col-gutter-md">
              <div
                v-for="attr in atributosForm"
                :key="attr.nm_atributo"
                class="col-12 col-sm-6"
              >
                <!-- 3A.2 — LOOKUP com pesquisa dinâmica (cd_menu_pesquisa > 0) -->
                <div v-if="temPesquisaDinamica(attr)">
                  <q-input
                    v-model="formData[attr.nm_atributo]"
                    :label="labelCampo(attr)"
                    :type="inputType(attr)"
                    filled
                    clearable
                    :dense="false"
                    stack-label
                    :readonly="isReadonly(attr)"
                    :input-class="inputClass(attr)"
                    @blur="validarCampoDinamico(attr)"
                  >
                    <template v-slot:prepend>
                      <q-btn
                        icon="search"
                        flat
                        round
                        dense
                        :disable="isReadonly(attr)"
                        @click="abrirPesquisa(attr)"
                        :title="`Pesquisar ${
                          attr.nm_edit_label || attr.nm_atributo
                        }`"
                      />
                    </template>
                    <template v-if="isDateField(attr)" v-slot:append>
                      <q-icon name="event" />
                    </template>
                  </q-input>

                  <!-- descrição do lookup (somente leitura) -->
                  <q-input
                    class="q-mt-xs"
                    :value="descricaoLookup(attr)"
                    label="Descrição"
                    filled
                    readonly
                    :input-class="'leitura-azul'"
                  />
                </div>

                <!-- 3B.2 — LOOKUP direto (nm_lookup_tabela) -->

                <q-select
                  v-else-if="temLookupDireto(attr)"
                  v-model="formData[attr.nm_atributo]"
                  :label="labelCampo(attr)"
                  :options="lookupOptions[attr.nm_atributo] || []"
                  option-label="__label"
                  option-value="__value"
                  emit-value
                  map-options
                  filled
                  clearable
                  :dense="false"
                  stack-label
                  :readonly="isReadonly(attr)"
                  :input-class="inputClass(attr)"
                />

                <!-- Descrição (readonly) para QUALQUER lookup -->
                <q-input
                  v-if="temLookupDireto(attr) || temPesquisaDinamica(attr)"
                  class="q-mt-xs leitura-azul"
                  :value="descricaoLookup(attr)"
                  :label="`Descrição`"
                  readonly
                  filled
                />

                <!-- 2.2 — Lista de valores (Lista_Valor) -->
                <q-select
                  v-else-if="temListaValor(attr)"
                  v-model="formData[attr.nm_atributo]"
                  :label="labelCampo(attr)"
                  :options="listaValores(attr)"
                  option-label="nm_lista_valor"
                  option-value="cd_lista_valor"
                  emit-value
                  map-options
                  filled
                  clearable
                  :dense="false"
                  stack-label
                  :readonly="isReadonly(attr)"
                  :input-class="inputClass(attr)"
                  :hide-hint="false"
                />

                <!-- 1.2 — INPUT padrão com regra azul/readonly e '*' em numeração automática -->
                <q-input
                  v-else
                  v-model="formData[attr.nm_atributo]"
                  :type="inputType(attr)"
                  :label="labelCampo(attr)"
                  filled
                  clearable
                  :dense="false"
                  stack-label
                  :readonly="isReadonly(attr)"
                  :input-class="inputClass(attr)"
                >
                  <template v-if="isDateField(attr)" v-slot:prepend>
                    <q-icon name="event" />
                  </template>
                </q-input>
              </div>
            </div>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right">
          <q-btn
            rounded
            class="q-mt-sm q-ml-sm"
            flat
            color="black"
            label="Cancelar"
            @click="fecharForm()"
          />

          <q-btn
            rounded
            color="deep-orange-9"
            class="q-mt-sm q-ml-sm"
            unelevated
            :loading="salvando"
            :label="formMode === 'I' ? 'Salvar' : 'Atualizar'"
            @click="salvarCRUD({ modo: formMode, registro: formData })"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Diálogo do Relatório PDF -->
    <q-dialog v-model="showRelatorio" maximized>
      <q-card style="min-height: 90vh">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Relatório</div>
          <q-space />
          <q-btn dense flat icon="close" @click="showRelatorio = false" />
        </q-card-section>

        <q-separator />

        <q-card-section>
          <!-- Passe props se já tiver os dados/meta no form -->
          <Relatorio
            v-if="showRelatorio"
            :columns="gridColumns"
            :rows="rows"
            :summary="totalColumns"
            :titulo="this.tituloMenu"
            :menu-codigo="this.cd_menu"
            :usuario-nome-ou-id="this.nm_usuario"
            :logoSrc="this.logo"
            :empresaNome="this.Empresa"
            :totais="totalColumns"
            @pdf="exportarPDF()"
            @excel="exportarExcel()"
          />
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- FIM do TOPO -->

    <section class="hpanel pane filtros">
      <!-- seus filtros aqui -->

      <!-- FILTROS (mesma ideia do Form Especial) -->
      <q-expansion-item
        v-if="temSessao && filtros && filtros.length"
        icon="filter_list"
        label="Seleção de Filtros"
        expand-separator
        default-opened
      >
        <slot name="filtros-bloco">
          <form
            class="dx-card wide-card"
            action="#"
            @submit.prevent="handleSubmit && handleSubmit($event)"
          >
            <div class="row q-col-gutter-md filtros-grid">
              <div
                v-for="f in filtros"
                :key="f.nm_atributo"
                class="col-12 col-sm-6 col-md-4 filtro-item"
              >
                <component
                  :is="f.nm_lookup_tabela ? 'q-select' : 'q-input'"
                  v-model="filtrosValores[f.nm_atributo]"
                  :type="inputType(f)"
                  :label="f.nm_edit_label || f.nm_filtro || f.nm_atributo"
                  :options="f._options || []"
                  option-value="value"
                  option-label="label"
                  filled
                  clearable
                  :dense="false"
                  stack-label
                  :disable="f.ic_fixo_filtro === 'S'"
                >
                  <template v-if="!f.nm_lookup_tabela" v-slot:prepend>
                    <q-icon name="tune" />
                  </template>
                </component>
              </div>
            </div>
            <div class="row filtros-actions">
              <q-btn
                class="q-mt-sm q-ml-sm"
                color="deep-orange-9"
                rounded
                label="Pesquisar"
                @click="consultar && consultar()"
              />
            </div>
          </form>
        </slot>
      </q-expansion-item>
    </section>

    <!-- TABS (NOVO)  —  SIMPLIFICADO -->
    <!-- 1) Cabeçalho de abas só quando houver tabs -->
    <div v-if="tabsDetalhe.length">
      <q-tabs
        v-model="abaAtiva"
        dense
        align="left"
        class="q-mb-sm text-deep-orange-9"
        active-color="deep-orange-9"
        indicator-color="deep-orange-9"
        narrow-indicator
      >
        <q-tab name="principal" label="PRINCIPAL" />
        <q-tab
          v-for="t in tabsDetalhe"
          :key="t.key"
          :name="t.key"
          :label="t.label"
          :disable="t.disabled"
        />
      </q-tabs>
      <q-separator color="deep-orange-9" />
    </div>

    <!-- 2) PRINCIPAL: fica SEMPRE no DOM.
       - Se existem tabs: mostra só quando abaAtiva === 'principal'
       - Se NÃO existem tabs: mostra sempre (porque tabsDetalhe.length == 0) -->
    <section v-show="!tabsDetalhe.length || abaAtiva === 'principal'">
      <!-- GRID DevExtreme (SEU BLOCO ORIGINAL) -->
      <div class="grid-scroll-shell" ref="scrollShell">
        <div class="grid-scroll-track" ref="scrollTrack">
          <transition name="slide-fade">
            <dx-data-grid
              class="dx-card wide-card"
              v-if="temSessao"
              id="grid-padrao"
              ref="grid"
              :data-source="rows || dataSourceConfig"
              :columns="columns"
              :key-expr="keyName || undefined"
              :summary="total || undefined"
              :show-borders="true"
              :focused-row-enabled="false"
              :focused-row-key="null"
              :focused-row-index="null"
              :column-auto-width="true"
              :column-hiding-enabled="false"
              :column-resizing-mode="'widget'"
              :remote-operations="false"
              :row-alternation-enabled="true"
              :repaint-changes-only="true"
              @rowClick="onRowClickPrincipal"
              @rowDblClick="
                (e) => abrirFormEspecial({ modo: 'A', registro: e.data })
              "
            >
              <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
              <DxGrouping :auto-expand-all="true" />
              <DxPaging :page-size="50" />
              <DxPager
                :show-page-size-selector="true"
                :allowed-page-sizes="[10, 20, 50, 100]"
                :show-info="true"
              />
              <DxFilterRow :visible="false" />
              <DxHeaderFilter :visible="true" :allow-search="true" />
              <DxSearchPanel
                :visible="true"
                :width="320"
                placeholder="Procurar..."
              />
              <DxColumnChooser :enabled="true" />
            </dx-data-grid>
          </transition>
        </div>

        <!-- seta para descer -->
        <q-btn
          round
          dense
          color="deep-orange-9"
          icon="keyboard_arrow_down"
          class="fab-down"
          @click="scrollDown('principal')"
        />
      </div>
    </section>

    <!-- 3) PAINÉIS DAS ABAS DE DETALHE: só existem quando tabsDetalhe.length > 0 -->
    <q-tab-panels v-if="tabsDetalhe.length" v-model="abaAtiva" animated>
      <q-tab-panel v-for="t in tabsDetalhe" :key="t.key" :name="t.key">
        <!-- Toolbar do detalhe -->
        <div class="row items-center q-mb-sm">
          <q-input
            dense
            filled
            clearable
            :value="filhos[t.cd_menu] ? filhos[t.cd_menu].filtro : ''"
            placeholder="Pesquisar itens..."
            @input="(val) => setFiltroFilho(t.cd_menu, val)"
            @keyup.enter="consultarFilho(t)"
            style="max-width: 320px"
          />
          <q-btn
            class="q-ml-sm"
            color="black"
            dense
            rounded
            label="Buscar"
            @click="consultarFilho(t)"
          />
          <q-space />
          <q-btn
            v-if="idPaiDetalhe"
            color="primary"
            rounded
            dense
            icon="add"
            label="Novo item"
            @click="abrirFormEspecialFilho({ tab: t, modo: 'I' })"
          />
        </div>

        <!-- Banner com ID + descrição do pai -->
        <div class="q-mb-sm" v-if="paiSelecionadoId !== null">
          <q-banner dense class="bg-grey-2 text-grey-9 q-pa-sm" rounded>
            <div class="row items-center">
              <div class="col-auto">
                <q-badge
                  color="deep-orange-9"
                  text-color="white"
                  class="q-mr-sm"
                >
                  {{ paiSelecionadoId }}
                </q-badge>
              </div>
              <div class="col ellipsis">
                <strong>{{ paiSelecionadoTexto || "—" }}</strong>
              </div>
            </div>
          </q-banner>
        </div>

        <!-- Grid do detalhe -->
        <div class="grid-scroll-shell" :ref="'scrollShellDet_' + t.cd_menu">
          <dx-data-grid
            class="dx-card wide-card"
            :data-source="(filhos[t.cd_menu] && filhos[t.cd_menu].rows) || []"
            :columns="(filhos[t.cd_menu] && filhos[t.cd_menu].columns) || []"
            :key-expr="
              (filhos[t.cd_menu] && filhos[t.cd_menu].keyExpr) || undefined
            "
            :show-borders="true"
            :row-alternation-enabled="true"
            :repaint-changes-only="true"
            @rowDblClick="
              (e) =>
                abrirFormEspecialFilho({ tab: t, modo: 'A', registro: e.data })
            "
          >
            <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
            <DxGrouping :auto-expand-all="true" />
            <DxPaging :page-size="50" />
            <DxPager
              :show-page-size-selector="true"
              :allowed-page-sizes="[10, 20, 50, 100]"
              :show-info="true"
            />
            <DxFilterRow :visible="false" />
            <DxHeaderFilter :visible="true" :allow-search="true" />
            <DxSearchPanel
              :visible="true"
              :width="320"
              placeholder="Procurar..."
            />
            <DxColumnChooser :enabled="true" />
          </dx-data-grid>

          <!-- seta para descer -->
          <q-btn
            round
            dense
            color="deep-orange-9"
            icon="keyboard_arrow_down"
            class="fab-down"
            @click="scrollDown('det', t.cd_menu)"
          />
        </div>
      </q-tab-panel>
    </q-tab-panels>

    <!-- Setas flutuantes -->
    <div class="arrow-btn left" @click="scrollGrid(-1)">
      <q-btn round color="orange" icon="chevron_left" />
    </div>

    <div class="arrow-btn right" @click="scrollGrid(1)">
      <q-btn round color="orange" icon="chevron_right" />
    </div>
  </div>
</template>

<script>
import axios from "axios";
//import axios from "boot/axios";

import Relatorio from "@/components/Relatorio.vue";

//import api from '@/boot/axios'
const banco = localStorage.nm_banco_empresa;
//

const api = axios.create({
  baseURL: "https://egiserp.com.br/api",
  withCredentials: true, // ⬅️ mantém cookies da sessão
  timeout: 60000,
  headers: { "Content-Type": "application/json", "x-banco": banco },

  // headers: { 'Content-Type': 'application/json', 'x-banco': banco }
}); // cai no proxy acima

// injeta headers a cada request (x-banco + bearer fixo)
api.interceptors.request.use((cfg) => {
  const banco = localStorage.nm_banco_empresa || "";
  if (banco) cfg.headers["x-banco"] = banco;
  cfg.headers["Authorization"] = "Bearer superchave123";
  if (!cfg.headers["Content-Type"])
    cfg.headers["Content-Type"] = "application/json";
  // DEBUG: veja a URL real que está indo
  console.log(
    "[REQ]",
    banco,
    cfg.method?.toUpperCase(),
    (cfg.baseURL || "") + cfg.url
  );
  return cfg;
});

//
/*
// Exemplo de chamada para a procedure
async function executarProcedure(payload) {
  try {
    const { data } = await api.post('/exec/pr_mapa_carteira_cliente_aberto', payload);
    console.log('Retorno da procedure:', data);
  } catch (err) {
    console.error('Erro completo:', err);
    if (err.response) {
      console.error('Status:', err.response.status);
      console.error('Data:', err.response.data);
    }
  }
}
*/

//
//console.log('banco de dados:', banco);
//

// ---------- Normalização genérica p/ filtros dinâmicos ----------

const isEmptyLike = (v) =>
  v === undefined || v === null || v === "" || v === "null" || v === "NULL";

const looksLikeDate = (s) =>
  typeof s === "string" &&
  (/^\d{2}[/-]\d{2}[/-]\d{4}$/.test(s) || /^\d{4}-\d{2}-\d{2}$/.test(s));

function toIsoDate(s, preferDayFirst = true) {
  if (!looksLikeDate(s)) return s;
  // yyyy-mm-dd
  if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;

  // dd/mm/yyyy ou dd-mm-yyyy
  if (/^\d{2}[/-]\d{2}[/-]\d{4}$/.test(s)) {
    const sep = s.includes("/") ? "/" : "-";
    const [a, b, c] = s.split(sep).map((x) => x.trim());
    let dd = a,
      mm = b,
      yyyy = c;
    // se for dia primeiro (campos iniciando com 'dt_' geralmente são datas BR)
    if (!preferDayFirst) [mm, dd] = [dd, mm];
    return `${yyyy}-${mm.padStart(2, "0")}-${dd.padStart(2, "0")}`;
  }
  return s;
}

const toSN = (v) => {
  if (v === true || v === 1 || v === "1" || `${v}`.toUpperCase() === "S")
    return "S";
  if (v === false || v === 0 || v === "0" || `${v}`.toUpperCase() === "N")
    return "N";
  return null; // deixa o back decidir quando não informado
};

const shouldBeNumberByKey = (k) =>
  /^cd_/.test(k) || /_id$/.test(k) || /^qtd/.test(k) || /^vl_/.test(k);

function normalizeValue(key, val) {
  if (isEmptyLike(val)) return null;

  // arrays/objetos: normaliza recursivo
  if (Array.isArray(val)) return val.map((x) => normalizeValue(key, x));
  if (val && typeof val === "object") return normalizePayload(val);

  // booleans/flags
  if (key.startsWith("ic_") || key.startsWith("fl_")) {
    const v = toSN(val);
    return v === null ? null : v;
  }

  // datas (chaves dt_* ou strings parecendo data)
  if (key.startsWith("dt_") || looksLikeDate(val)) {
    return toIsoDate(val, /*preferDayFirst=*/ true); // dd/mm/yyyy -> yyyy-mm-dd
  }

  // números por heurística do nome
  if (shouldBeNumberByKey(key)) {
    const n = Number(val);
    return Number.isFinite(n) ? n : null;
  }

  return val; // mantém o resto como está
}

function normalizePayload(obj) {
  if (!obj || typeof obj !== "object") return obj;
  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    out[k] = normalizeValue(k, v);
  }
  return out;
}

// normaliza um array de linhas com base num “meta” (tipos vindos do payload)

function normalizarTipos(dados, camposMeta) {
  if (!Array.isArray(dados)) return dados;

  const mapa = {};

  (camposMeta || []).forEach((c) => {
    const key = c.nm_atributo_consulta || c.nm_atributo;

    // determinar tipo
    const tipo = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    mapa[key] = tipo;
    //
  });
  return dados.map((reg) => {
    const out = { ...reg };
    for (const [key, tipo] of Object.entries(mapa)) {
      const v = out[key];
      if (v == null || v === "") continue;
      if (
        [
          "currency",
          "number",
          "fixedpoint",
          "decimal",
          "float",
          "percent",
        ].includes(tipo)
      ) {
        const num = Number(String(v).replace(/\./g, "").replace(",", "."));
        if (!Number.isNaN(num)) out[key] = num;
      } else if (["date", "shortdate", "datetime"].includes(tipo)) {
        const d = new Date(v);
        if (!isNaN(d.getTime())) out[key] = d; // vira Date real
      }
    }
    return out;
  });
}

// ==== BUILDERS DE COLUNAS E TOTAIS ====

function buildColumnsFromMeta(camposMeta = []) {
  return (camposMeta || []).map((c) => {
    const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const caption = c.nm_edit_label || dataField;
    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    const align = [
      "currency",
      "percent",
      "fixedpoint",
      "number",
      "decimal",
      "float",
    ].includes(tipoFmt)
      ? "right"
      : "left";

    const col = {
      dataField,
      caption,
      visible: c.ic_visivel !== "N",
      width: c.largura || undefined,
      alignment: align,
      allowFiltering: true,
      allowSorting: true,
    };

    // Datas (exibição dd/MM/yyyy, filtro por data)
    
    if (['date','shortdate','datetime'].includes(tipoFmt) || dataField.startsWith('dt_')) {
      col.dataType = 'date';
col.customizeText = (e) => {
  if (!e.value) return '';

        const d = e.value instanceof Date ? e.value : new Date(e.value);
        if (isNaN(d)) return "";

        return d.toLocaleDateString("pt-BR", {
          timeZone: "UTC",
          day: "2-digit",
          month: "2-digit",
          year: "numeric",
        });
      };
    }

    /*
      col.customizeText = (e) => {
        if (!e.value) return '';
        
        const d = (e.value instanceof Date) ? e.value : new Date(e.value);
        if (isNaN(d)) return '';
        const dd = String(d.getDate()).padStart(2,'0');
        const mm = String(d.getMonth()+1).padStart(2,'0');
        const yyyy = d.getFullYear();
        return `${dd}/${mm}/${yyyy}`;
      };
    }
    */

    /*
if (['date','shortdate','datetime'].includes(tipoFmt) || dataField.startsWith('dt_')) {
  // REMOVE dataType para evitar UTC
  col.dataType = 'string';
  if (['date','shortdate','datetime'].includes(tipoFmt) || dataField.startsWith('dt_')) {
  col.dataType = 'string'; // evita UTC
  col.customizeText = undefined; // opcional, já está formatado
}

  /*
  col.cellTemplate = (container, options) => {
  let texto = '';

  if (options.value instanceof Date) {
    texto = options.value.toLocaleDateString('pt-BR');
  } else if (typeof options.value === 'string') {
    try {
      // Cria Date com componentes separados para evitar UTC
      const [datePart] = options.value.split(' ');
      const [year, month, day] = datePart.split('-').map(Number);
      const dateObj = new Date(year, month - 1, day);
      texto = dateObj.toLocaleDateString('pt-BR');
    } catch {
      texto = options.value;
    }
  } else {
    texto = String(options.value ?? '');
  }

  const span = document.createElement('span');
  span.textContent = texto;
  container.appendChild(span);
};
*/

    //}

    // Moeda
    if (tipoFmt === "currency" || dataField.startsWith("vl_")) {
      col.customizeText = (e) =>
        e.value == null || e.value === ""
          ? ""
          : Number(e.value).toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            });
      col.cellTemplate = (container, options) => {
        const val = options.value;
        const span = document.createElement("span");
        if (typeof val === "number" && val < 0) span.style.color = "#c62828";
        span.textContent =
          val == null || val === ""
            ? ""
            : val.toLocaleString("pt-BR", {
                style: "currency",
                currency: "BRL",
              });
        container.append(span);
      };
    }

    // Percentual
    if (tipoFmt === "percent") {
      col.customizeText = (e) =>
        e.value == null || e.value === ""
          ? ""
          : `${(Number(e.value) * 100).toFixed(2)}%`;
    }

    // Números simples
    if (["number", "fixedpoint", "decimal", "float"].includes(tipoFmt)) {
      col.format = { type: "fixedPoint", precision: 2 };
    }

    return col;

  });

}

function buildSummaryFromMeta(camposMeta = []) {
  const totalizaveis = (camposMeta || []).filter(
    (c) => c.ic_total_grid === "S" || c.ic_contador_grid === "S"
  );

  const totalItems = totalizaveis.map((c) => {
    const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    const isSum = c.ic_total_grid === "S";
    return {
      column: dataField,
      summaryType: isSum ? "sum" : "count",
      alignByColumn: true,
      displayFormat: isSum ? "Total: {0}" : "{0} registro(s)",
      customizeText: (e) => {
        if (isSum && (tipoFmt === "currency" || dataField.startsWith("vl_"))) {
          return `Total: ${Number(e.value || 0).toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL",
          })}`;
        }
        if (isSum && tipoFmt === "percent") {
          return `Total: ${(Number(e.value || 0) * 100).toFixed(2)}%`;
        }
        return isSum ? `Total: ${e.value}` : `${e.value} registro(s)`;
      },
    };
  });

  const groupItems = totalizaveis.map((c) => {
    const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    const isSum = c.ic_total_grid === "S";
    return {
      column: dataField,
      summaryType: isSum ? "sum" : "count",
      showInGroupFooter: true,
      alignByColumn: true,
      displayFormat: isSum ? "Subtotal: {0}" : "{0} registro(s)",
      customizeText: (e) => {
        if (isSum && (tipoFmt === "currency" || dataField.startsWith("vl_"))) {
          return `Subtotal: ${Number(e.value || 0).toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL",
          })}`;
        }
        if (isSum && tipoFmt === "percent") {
          return `Subtotal: ${(Number(e.value || 0) * 100).toFixed(2)}%`;
        }
        return isSum ? `Subtotal: ${e.value}` : `${e.value} registro(s)`;
      },
    };
  });

  return {
    totalItems,
    groupItems,
    texts: { sum: "Total: {0}", count: "Registro(s): {0}" },
  };
}  
// ---------------------------------------------------------------
//
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import jsPDF from "jspdf";
import "jspdf-autotable";
import { exportGridToPDF } from "@/utils/pdfExport";

import DxDataGrid, {
  DxColumn,
  DxGrouping,
  DxGroupPanel,
  DxSummary,
  DxTotalItem,
  DxSearchPanel,
  DxHeaderFilter,
  DxFilterRow,
  DxPager,
  DxPaging,
  DxColumnChooser,
} from "devextreme-vue/data-grid";

import { act } from "react";

//

//
function buscarValor(row, nomes) {
  for (const nome of nomes) {
    if (typeof nome !== "string") continue; // ignora valores inválidos

    const chave = Object.keys(row).find(
      (k) => k.toLowerCase() === nome.toLowerCase()
    );
    if (chave) return row[chave];
  }
  return undefined;
}

// ---------------------------------------------------------------

export default {
  name: "UnicoFormEspecial",
  components: {
    Relatorio,
    DxDataGrid,
    DxColumn,
    DxGrouping,
    DxGroupPanel,
    DxSummary,
    DxTotalItem,
    DxSearchPanel,
    DxHeaderFilter,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxColumnChooser,
  },

  // ===== DADOS =====

  data() {
    return {
      panelIndex: 0, // 0 = filtros, 1 = grid
      showRelatorio: false,
      title: "",
      qt_registro: 0, // badge (display-data usa isso)
      rows: [],
      columns: [],
      totalColumns: [],
      gridMeta: [],
      // chave primária (detectada)
      keyName: null,
      keyExprFinal: null,
      isPesquisa: false,
      loading: false,
      filtros: [],
      filtrosValores: this.filtrosValores || {},
      nome_procedure: "*",
      ic_json_parametro: "N",
      temSessao: false,
      searchText: "",
      cd_empresa: localStorage.cd_empresa,
      cd_modulo: localStorage.cd_modulo,
      cd_usuario: localStorage.cd_usuario,
      cd_menu: localStorage.cd_menu,
      nm_usuario: localStorage.usuario,
      logo: localStorage.nm_caminho_logo_empresa,
      cd_cliente: 0,
      cd_parametro_menu: 0,
      dateBoxOptions: {
        invalidDateMessage: "Data tem estar no formato: dd/mm/yyyy",
      },
      total: { totalItems: [] }, // usado por :summary do DataGrid
      totalQuantidade: 0, // usado no cabeçalho/rodapé
      totalValor: 0, // idem
      gridRows: [],
      gridColumns: [],
      gridSummary: null,
      // guarde o “meta” de colunas (vem do payload que define campos)
      camposMetaGrid: [], // ← vamos preencher no passo 3
      // filtros dinâmicos
      empresaAtual: localStorage.nm_banco_empresa || "",
      usuarioAtual:
        (localStorage.cd_usuario ? `${localStorage.cd_usuario} - ` : "") +
        (localStorage.nm_usuario || ""),
      Empresa: localStorage.fantasia || localStorage.empresa || "",
      // logoEmpresa: localStorage.imageUrl || '/img/logo.png',
      tituloMenu: localStorage.nm_menu_titulo || "Relatório de Dados",
      pageTitle: localStorage.nm_menu_titulo || this.pageTitle || "",
      cd_tabela: 0,
      dlgForm: false,
      formMode: "I", // 'I' incluir | 'A' alterar
      formData: {}, // dados do formulário
      atributosForm: [], // metadados para montar inputs
      formRenderizou: false,
      salvando: false,
      // meta de atributos recebida do payload/menu-filtro
      metaAtributos: [],
      lookupOptions: {},
      tabs: [],
      abaAtiva: "principal", // controla a aba aberta (principal | det_<cd>)
      tabsDetalhe: [], // [{ key:'det_123', label:'Itens...', cd_menu:123, disabled:true }]
      idPaiDetalhe: null, // valor da PK do registro selecionado na principal
      filhos: {}, // Mapa por cd_menu_detalhe: { meta, columns, rows, keyName, filtro }
      // identificação/legenda do registro pai selecionado (NOVO)
      paiSelecionadoId: null,
      paiSelecionadoTexto: "",
    };
  },

  created() {
    this.bootstrap();

    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;

    this.dt_inicial = localStorage.dt_inicial;
    this.dt_final = localStorage.dt_final;
    this.dt_base = localStorage.dt_base;
    this.periodoVisible = false;
    this.tituloMenu = localStorage.nm_menu_titulo;

    this.hoje = "";
    this.hora = "";

    // preencher datas do mês vigente (item 3)
    this.$nextTick(() => {
      this.preencherDatasDoMes();
    });

    //

    if (!this.qt_tempo == 0) {
      this.pollData();
      localStorage.polling = 1;
    }
  },

  async mounted() {
    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;

    //this.carregaDados();
  },

  computed: {
    tituloModal() {
      const t = sessionStorage.getItem("menu_titulo") || "Cadastro";
      if (this.modo === "novo") return `Inclusão - ${t}`;
      if (this.modo === "alteracao") return `Alteração - ${t}`;
      if (this.modo === "consulta") return `Consulta - ${t}`;
      if (this.modo === "exclusao") return `Exclusão - ${t}`;
      return t;
    },
    // mantém o que você já tem e acrescente:
    recordCount() {
      // badge quando a tela usa rows (FormEspecial) OU dataSourceConfig (display-data)
      if (Array.isArray(this.rows)) return this.rows.length;
      if (Array.isArray(this.dataSourceConfig))
        return this.dataSourceConfig.length;
      return 0;
    },

    gridColumnsNovo() {
      // suas colunas atuais (ex.: vindas de meta)
      const base = (this.colunasGrid || []).map((c) => ({
        dataField: c.dataField || c.nm_atributo,
        caption: c.caption || c.titulo,
      }));

      // garante que a coluna da chave exista e venha primeiro
      const key = this.keyName;
      //

      let cols = base;
      if (key) {
        const temChave = base.some((c) => c.dataField === key);
        if (!temChave) {
          cols = [
            { dataField: key, caption: this.keyCaption || "Código" },
            ...base,
          ];
        } else {
          // move para a primeira posição
          const idx = base.findIndex((c) => c.dataField === key);
          const [col] = base.splice(idx, 1);
          cols = [{ ...col, caption: this.keyCaption || col.caption }, ...base];
        }
      }

      // nunca renderize a coluna "id" (ela só existe se você usou fallback)
      cols = cols.filter((c) => c.dataField !== "id");

      // coluna de ações (editar)
      const acoes = {
        caption: "Ações",
        width: 110,
        alignment: "center",
        cellTemplate: (container, options) => {
          const wrap = document.createElement("div");
          wrap.className = "dx-command-edit";

          const editar = document.createElement("a");
          editar.className = "dx-link dx-link-edit";
          editar.title = "Editar";
          editar.innerHTML = '<i class="fa fa-pencil"></i>';
          editar.addEventListener("click", () => {
            this.abrirFormEspecial({ modo: "A", registro: options.data });
          });

          wrap.appendChild(editar);
          container.appendChild(wrap);
        },
      };

      return [...base, ...cols, acoes];
    },
  },
  watch: {
    abaAtiva() {
      if (this.abaAtiva === "principal") return;
      const t = this.tabsDetalhe.find((x) => x.key === this.abaAtiva);
      if (t) this.consultarFilho(t);
    },
    dataSourceConfig(v) {
      this.qt_registro = Array.isArray(v) ? v.length : 0;
    },
    rows(v) {
      this.qt_registro = Array.isArray(v) ? v.length : 0;
    },
    // quando filtros chegarem/alterarem, tenta preencher datas
    filtros: {
      immediate: true,
      deep: true,
      handler() {
        this.$nextTick(() => this.preencherDatasDoMes());
      },
    },
    filters: {
      numero(v) {
        return Number(v || 0).toLocaleString("pt-br", {
          minimumFractionDigits: 2,
        });
      },
      moeda(v) {
        return Number(v || 0).toLocaleString("pt-br", {
          style: "currency",
          currency: "BRL",
        });
      },
    },
    visible(v) {
      if (v) {
        // ... sua rotina atual de init ...
        this.loadAllLookups(); // adiciona aqui
      }
    },
  },

  methods: {
    // ...
    scrollDown(qual, cdMenu) {
      // decide o container de scroll
      let refEl = null;
      if (qual === "principal") {
        refEl = this.$refs.scrollShellPrincipal;
      } else if (qual === "det" && this.$refs["scrollShellDet_" + cdMenu]) {
        // quando v-for com ref, o Vue devolve um array
        const arr = this.$refs["scrollShellDet_" + cdMenu];
        refEl = Array.isArray(arr) ? arr[0] : arr;
      }
      if (!refEl) return;

      // rolar um “bloco” de linhas
      try {
        refEl.scrollBy({ top: 400, left: 0, behavior: "smooth" });
      } catch (_) {
        // fallback para browsers sem scrollBy options
        refEl.scrollTop = (refEl.scrollTop || 0) + 400;
      }
    },

    setFiltroFilho(cdMenu, val) {
      if (!this.filhos[cdMenu]) {
        // garante o slot antes de setar (Vue 2 precisa de $set p/ reatividade nova chave)
        this.$set(this.filhos, cdMenu, {
          meta: [],
          columns: [],
          rows: [],
          keyName: null,
          filtro: "",
        });
      }
      this.$set(this.filhos[cdMenu], "filtro", val);
    },

    // ========== ABAS DE DETALHE (NOVO) ==========

    montarAbasDetalhe() {
      // 1) Tenta sessionStorage.tab_menu
      let tabMenu = [];
      try {
        tabMenu = JSON.parse(sessionStorage.getItem("tab_menu") || "[]");
      } catch (e) {
        tabMenu = [];
      }

      // 2) Se vazio, tenta no payload que você já carregou no componente
      if (!Array.isArray(tabMenu) || tabMenu.length === 0) {
        const possiveis = [
          this.payload, // se você usa this.payload
          this.payloadPrincipal, // se você salvou assim
          this.gridMetaPayload, // qualquer outro nome que você já use
          this.$data && this.$data.payload_padrao_formulario, // fallback
        ].filter(Boolean);

        for (const p of possiveis) {
          const arr = p && p.tab_menu;
          if (Array.isArray(arr) && arr.length) {
            tabMenu = arr;
            break;
          }
        }
      }

      // 3) Normaliza (se ainda não for array, vira array vazio)
      if (!Array.isArray(tabMenu)) tabMenu = [];

      // 4) Mapeia para a estrutura de abas (seu payload: nm_tabsheet_menu / nm_menu_titulo)
      const novasTabs = tabMenu.map((t) => {
        const cd = Number(t.cd_menu_detalhe || t.cd_menu); // prioridade cd_menu_detalhe
        const label = t.nm_tabsheet_menu || t.nm_menu_titulo || `Itens ${cd}`;

        if (!this.filhos[cd]) {
          this.$set(this.filhos, cd, {
            meta: [],
            columns: [],
            rows: [],
            keyName: null,
            filtro: "",
          });
        }

        return {
          key: `det_${cd}`,
          label,
          cd_menu: cd,
          nm_campo_fk: t.nm_campo_fk || null, // <- se existir no payload
          disabled: true, // habilita após selecionar a linha do pai
        };
      });

      // 5) Seta tudo de uma vez (reativo)
      this.tabsDetalhe = novasTabs;

      // DEBUG opcional
      // console.log('tabsDetalhe ->', this.tabsDetalhe);
    },

    // ao clicar numa linha da PRINCIPAL

    onRowClickPrincipal(e) {
      const data = e && (e.data || e.row?.data) ? e.data || e.row.data : null;
      if (!data) return;

      // salva registro selecionado como você já faz no dblclick
      sessionStorage.setItem("registro_selecionado", JSON.stringify(data));
      const cd_menu = sessionStorage.getItem("cd_menu");
      if (cd_menu)
        sessionStorage.setItem(
          `registro_selecionado_${cd_menu}`,
          JSON.stringify(data)
        );

      // descobre a PK do pai usando sua meta atual (mesma lógica que você já usa)
      let pkPai =
        this.keyName && row[this.keyName] !== undefined
          ? this.keyName
          : this.keyName || "id";

      // DevExtreme fornece e.key; use se existir
      const idPorKeyDoDx = e && e.key !== undefined ? e.key : undefined;

      // tenta vários caminhos para achar o ID
      // tenta vários caminhos para achar o ID (sem usar ??)
      let id = e && typeof e.key !== "undefined" ? e.key : null;

      // 1) pk da grid
      if (id === null || id === undefined) {
        if (pkPai && Object.prototype.hasOwnProperty.call(data, pkPai)) {
          const v = data[pkPai];
          if (v !== null && v !== undefined) id = v;
        }
      }

      // 2) campos comuns
      if (id === null || id === undefined) {
        if (data.id !== undefined && data.id !== null) id = data.id;
        else if (data.ID !== undefined && row.ID !== null) id = data.ID;
      }

      // 3) fallback: primeira prop com “cara de chave”
      if (id === null || id === undefined) {
        const chaveMatch = Object.keys(data).find((k) =>
          /(^id$|^cd_|_id$)/i.test(k)
        );
        if (chaveMatch) id = row[chaveMatch];
      }

      this.idPaiDetalhe = id;

      // 4) guardar para a consulta do detalhe
      let descKey = null;
      try {
        const meta = Array.isArray(this.gridMeta)
          ? this.gridMeta
          : JSON.parse(sessionStorage.getItem("campos_grid_meta") || "[]");

        const visiveis = (meta || []).filter((c) => c.ic_mostra_grid === "S");
        const prefer = [
          "descr",
          "descrição",
          "descricao",
          "nome",
          "ds_",
          "nm_",
        ];
        const porTitulo = visiveis.find((c) =>
          prefer.some((p) =>
            (c.nm_titulo_menu_atributo || "").toLowerCase().includes(p)
          )
        );
        const porNome = visiveis.find((c) =>
          prefer.some((p) =>
            (c.nm_atributo || c.nm_atributo_consulta || "")
              .toLowerCase()
              .includes(p)
          )
        );
        const primeiraNaoPk = visiveis.find(
          (c) => (c.nm_atributo || c.nm_atributo_consulta) !== pkPai
        );

        descKey =
          (porTitulo &&
            (porTitulo.nm_atributo || porTitulo.nm_atributo_consulta)) ||
          (porNome && (porNome.nm_atributo || porNome.nm_atributo_consulta)) ||
          (primeiraNaoPk &&
            (primeiraNaoPk.nm_atributo ||
              primeiraNaoPk.nm_atributo_consulta)) ||
          null;
      } catch (_) {}

      this.idPaiDetalhe = this.paiSelecionadoId;
      this.paiSelecionadoTexto = descKey ? data[descKey] || "" : "";

      // 5) habilitar as abas de detalhe
      this.tabsDetalhe = this.tabsDetalhe.map((t) => ({
        ...t,
        disabled: false,
      }));

      // 6) se já está em uma aba de detalhe, recarregar
      if (this.abaAtiva !== "principal") {
        const t = this.tabsDetalhe.find((x) => x.key === this.abaAtiva);
        if (t) this.consultarFilho(t);
      }
    },

    // carrega META do filho (uma vez por cd_menu)

    async carregarMetaFilho(tab) {
      const cd_usuario = Number(
        this.cd_usuario || sessionStorage.getItem("cd_usuario") || 0
      );

      if (!tab || !tab.cd_menu) return;

      // se já tem, pula
      const slot = this.filhos[tab.cd_menu];
      if (slot && Array.isArray(slot.meta) && slot.meta.length > 0) {
        this.resolverFkFilho(tab);
        return;
      }

      const payload = {
        cd_parametro: 1,
        cd_form: localStorage.cd_form,
        cd_menu: Number(tab.cd_menu),
        nm_tabela_origem: "",
        cd_usuario,
      };

      const { data } = await api.post("/payload-tabela", payload); // mesmo endpoint que você já usa
      //
      const meta = Array.isArray(data) ? data : [];

      // monta columns (repetindo seu padrão da principal)

      // === PK do filho: pode ser composta ===
      const pks = (meta || []).filter(
        (m) => String(m.ic_atributo_chave || "").toUpperCase() === "S"
      );
      const keyList = pks
        .map((m) => m.nm_atributo || m.nm_atributo_consulta)
        .filter(Boolean);

      // mantém compatibilidade: string se for 1 campo, array se for >1
      const keyExpr = keyList.length <= 1 ? keyList[0] || "id" : keyList;

      // === FK do filho: prioriza ic_chave_estrangeira === 'S', senão faz heurística ===
      let fkCampo = null;
      const fkFromMeta = (meta || []).find(
        (m) => String(m.ic_chave_estrangeira || "").toUpperCase() === "S"
      );
      if (fkFromMeta) {
        fkCampo = fkFromMeta.nm_atributo || fkFromMeta.nm_atributo_consulta;
      }
      if (!fkCampo) {
        // fallback: heurística baseada na PK do pai
        const pkPai = (this.keyName || "id").toString().toLowerCase();
        const cand = (meta || []).filter(
          (c) => String(c.ic_atributo_chave || "").toUpperCase() !== "S"
        );
        fkCampo =
          cand.find(
            (c) =>
              (c.nm_atributo || c.nm_atributo_consulta || "").toLowerCase() ===
              pkPai
          )?.nm_atributo ||
          cand.find((c) =>
            (c.nm_atributo || c.nm_atributo_consulta || "")
              .toLowerCase()
              .includes(pkPai.replace(/^cd_/, ""))
          )?.nm_atributo ||
          cand.find((c) => {
            const n = (
              c.nm_atributo ||
              c.nm_atributo_consulta ||
              ""
            ).toLowerCase();
            return (
              n.startsWith("cd_") || n.endsWith("_id") || n.includes("_cd_")
            );
          })?.nm_atributo ||
          this.keyName ||
          "id";
      }

      // monta columns SEM exemplo (vamos revalidar após a 1ª consulta)
      var columns = (meta || [])
        .filter(function (c) {
          return c.ic_mostra_grid === "S";
        })
        .sort(function (a, b) {
          return (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0);
        })
        .map(function (c) {
          return {
            dataField: c.nm_atributo || c.nm_atributo_consulta,
            caption:
              c.nm_titulo_menu_atributo ||
              c.nm_atributo_consulta ||
              c.nm_atributo,
            format: c.formato_coluna || undefined,
            alignment:
              ["currency", "number", "percent", "fixedPoint"].indexOf(
                c.formato_coluna
              ) >= 0
                ? "right"
                : "left",
            width: c.largura || undefined,
          };
        });

      // grava no slot do filho
      this.$set(this.filhos, tab.cd_menu, {
        ...(this.filhos[tab.cd_menu] || {}),
        meta,
        columns,
        keyExpr, // <<<<<< usa no template
        keyName: keyExpr, // mantém seu campo antigo, se alguém usa
        filtro:
          (this.filhos[tab.cd_menu] && this.filhos[tab.cd_menu].filtro) || "",
      });

      // anota no próprio tab (útil na consulta e no "novo")
      tab._pk_list = keyList;
      tab._pk = Array.isArray(keyExpr) ? keyExpr[0] : keyExpr;
      tab._fk = fkCampo;

      // resolve dinamicamente a FK do filho com base na meta e na PK do pai
      this.resolverFkFilho(tab);
      //
    },

    // Descobre dinamicamente o campo FK do filho comparando com a PK do pai

    resolverFkFilho(tab) {
      if (!tab) return;
      if (tab._fk) return; // já resolvida

      if (tab.nm_campo_fk) {
        tab._fk = tab.nm_campo_fk;
        return;
      }

      // PK do pai já descoberta no seu fluxo
      const pkPai = (this.keyName || "id").toString().toLowerCase();

      const slot = this.filhos[tab.cd_menu] || {};
      const metaFilho = Array.isArray(slot.meta) ? slot.meta : [];

      // 1) candidatos: todos campos do filho que NÃO são PK do filho
      //    e que parecem chave (começam com 'cd_' ou terminam com '_id' etc.)
      const candidatos = metaFilho.filter((c) => {
        const nome = (c.nm_atributo || c.nm_atributo_consulta || "").toString();
        const isPkFilho =
          String(c.ic_atributo_chave || "").toUpperCase() === "S";
        const nomeLow = nome.toLowerCase();
        const temCaraDeChave =
          nomeLow.startsWith("cd_") ||
          nomeLow.endsWith("_id") ||
          nomeLow.includes("_cd_");
        return (
          !isPkFilho &&
          (temCaraDeChave || nomeLow.includes(pkPai.replace(/^cd_/, "")))
        );
      });

      // 2) priorize os que casam exatamente com a PK do pai
      let escolhido = candidatos.find(
        (c) =>
          (c.nm_atributo || c.nm_atributo_consulta || "").toLowerCase() ===
          pkPai
      ) ||
        // 3) se não houver, os que CONTÉM o nome da PK do pai (tirando "cd_")
        candidatos.find((c) => {
          const nome = (
            c.nm_atributo ||
            c.nm_atributo_consulta ||
            ""
          ).toLowerCase();
          const base = pkPai.replace(/^cd_/, ""); // ex: cd_condicao_pagamento -> condicao_pagamento
          return nome.includes(base);
        }) ||
        // 4) fallback: primeiro candidato com cara de chave
        candidatos[0] || { nm_atributo: this.keyName }; // 5) fallback definitivo: use a PK do pai

      // guarda no tab._fk o nome do campo, usando a mesma regra que você usa nos demais lugares
      tab._fk =
        escolhido.nm_atributo || escolhido.nm_atributo_consulta || this.keyName;
      //
    },

    // consultar itens do filho

    async consultarFilho(tab) {
      if (!tab || !tab.cd_menu) return;

      if (!this.idPaiDetalhe) {
        try {
          const cd_menu = sessionStorage.getItem("cd_menu");
          const salvo = JSON.parse(
            sessionStorage.getItem(`registro_selecionado_${cd_menu}`) ||
              sessionStorage.getItem("registro_selecionado") ||
              "null"
          );
          if (salvo) {
            const id =
              this.keyName && salvo[this.keyName] !== undefined
                ? salvo[this.keyName]
                : salvo.id ??
                  salvo.ID ??
                  (Object.keys(salvo).find((k) =>
                    /(^id$|^cd_|_id$)/i.test(k)
                  ) &&
                    salvo[
                      Object.keys(salvo).find((k) =>
                        /(^id$|^cd_|_id$)/i.test(k)
                      )
                    ]);
            if (id !== undefined && id !== null) this.idPaiDetalhe = id;
          }
        } catch (_) {}
      }

      const cd_usuario = Number(
        this.cd_usuario || sessionStorage.getItem("cd_usuario") || 0
      );

      // garante meta carregada (e tab._pk / tab._fk definidos)
      await this.carregarMetaFilho(tab);

      // FK do filho (pode ter sido ajustada manualmente depois do carregarMetaFilho)
      const fkCampo = tab._fk || this.keyName || "id";

      // Filtro livre digitado no input do detalhe
      const filtroLivre = (this.filhos[tab.cd_menu].filtro || "").trim();

      // >>> Se a principal envia período/filial/outros parâmetros, recupere daqui:
      // pegue do mesmo lugar que a principal pega (exemplos de chaves comuns; ajuste aos seus nomes reais)

      const paramsExtras = {};

      try {
        const p = JSON.parse(
          sessionStorage.getItem("parametros_pesquisa") || "{}"
        );
        Object.assign(paramsExtras, p);
      } catch (e) {}

      // Monte o body igual ao da principal, apenas mudando cd_menu e acrescentando a FK do pai

      const body = [
        {
          cd_parametro: 1,
          cd_menu: Number(tab.cd_menu),
          cd_usuario,
          filtro: filtroLivre,
          [fkCampo]: this.idPaiDetalhe,
          ...paramsExtras,
        },
      ];

      // DEBUG opcional
      // console.log('consulta FILHO ->', body);

      const { data } = await api.post("/menu-pesquisa", body);

      const rows = Array.isArray(data) ? data : [];

      // DevExtreme exige que TODOS os campos da PK composta existam nas linhas:
      // se o backend não retorna a FK, injeta com o valor do pai (não muda persistência – só a grid)
      if (Array.isArray(tab._pk_list) && tab._pk_list.length > 1) {
        rows.forEach((r) => {
          if (fkCampo && (r[fkCampo] === undefined || r[fkCampo] === null)) {
            r[fkCampo] = this.idPaiDetalhe;
          }
        });
      }

      // Realinhar dataField das colunas com base no primeiro row
      var exemplo = rows && rows.length ? rows[0] : null;
      var metaFilho = this.filhos[tab.cd_menu].meta || [];
      var columnsFix = metaFilho
        .filter(function (c) {
          return c.ic_mostra_grid === "S";
        })
        .sort(function (a, b) {
          return (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0);
        })
        .map((c) => {
          var df = this._resolverDataFieldColuna(c, exemplo);
          return {
            dataField: df,
            caption:
              c.nm_titulo_menu_atributo ||
              c.nm_atributo_consulta ||
              c.nm_atributo ||
              df,
            format: c.formato_coluna || undefined,
            alignment:
              ["currency", "number", "percent", "fixedPoint"].indexOf(
                c.formato_coluna
              ) >= 0
                ? "right"
                : "left",
            width: c.largura || undefined,
          };
        });

      // mantém seu padrão de sessionStorage
      sessionStorage.setItem(
        `dados_resultado_consulta_detalhe_${tab.cd_menu}`,
        JSON.stringify(rows)
      );
      sessionStorage.setItem(
        `id_pai_detalhe_${tab.cd_menu}`,
        String(this.idPaiDetalhe)
      );

      // atualiza grid do detalhe
      const slot = this.filhos[tab.cd_menu] || {};
      this.$set(this.filhos, tab.cd_menu, { ...slot, rows });
    },

    // Escolhe o dataField certo para a coluna (detalhe) baseado no primeiro row
    _resolverDataFieldColuna(metaCampo, exemploRow) {
      var a = metaCampo || {};
      var cand = [a.nm_atributo, a.nm_atributo_consulta].filter(Boolean);

      // se tiver linha de exemplo, use o primeiro candidato que exista na linha
      if (exemploRow && typeof exemploRow === "object") {
        for (var i = 0; i < cand.length; i++) {
          var k = cand[i];
          if (k && Object.prototype.hasOwnProperty.call(exemploRow, k))
            return k;
          // tenta case-insensitive
          var keyCi = Object.keys(exemploRow).find(function (n) {
            return n.toLowerCase() === String(k).toLowerCase();
          });
          if (keyCi) return keyCi;
        }
      }
      // fallback: nm_atributo
      return a.nm_atributo || a.nm_atributo_consulta || "id";
    },

    // ao trocar de aba
    async trocarAbaSeNecessario() {
      if (this.abaAtiva === "principal") return;
      const t = this.tabsDetalhe.find((x) => x.key === this.abaAtiva);
      if (t) await this.consultarFilho(t);
    },

    // abrir modal do filho (reaproveitando sua mesma lógica do pai)

    async abrirFormEspecialFilho({ tab, modo, registro = {} }) {
      if (!tab) return;

      // injeta FK do pai no modelo ao incluir
      if (modo === "I" && this.idPaiDetalhe && tab._fk) {
        registro = { ...registro, [tab._fk]: this.idPaiDetalhe };
      }
      // dica: você pode reaproveitar seu abrirFormEspecial, passando metadados de tab.cd_menu
      // Se você preferir distinguir no backend, use cd_menu=tab.cd_menu e set o pai no modelo
      const modelo = { ...registro };

      // injeta a FK do pai se for inclusão
      if (modo === "I" && this.idPaiDetalhe) {
        // usa a mesma chave detectada como PK do pai
        const fk = this.keyName || "id";
        modelo[fk] = this.idPaiDetalhe;
      }

      // Carrega payload do DETALHE e usa no modal
      const cd_usuario = Number(
        this.cd_usuario || sessionStorage.getItem("cd_usuario") || 0
      );
      const detPayloadReq = {
        cd_parametro: 1,
        cd_form: localStorage.cd_form,
        cd_menu: Number(tab.cd_menu),
        nm_tabela_origem: "",
        cd_usuario,
      };

      const { data: payloadDetalhe } = await api.post(
        "/payload-tabela",
        detPayloadReq
      );

      // truque seguro: salva o payload da principal, troca pelo do detalhe, abre modal e depois restaura
      const backup =
        sessionStorage.getItem("payload_padrao_formulario") || null;
      var backupCdMenu = sessionStorage.getItem("cd_menu");
      sessionStorage.setItem("cd_menu", String(tab.cd_menu)); // << usa menu do DETALHE

      sessionStorage.setItem(
        "payload_padrao_formulario",
        JSON.stringify(payloadDetalhe)
      );
      try {
        this.abrirFormEspecial({ modo: modo === "I" ? "I" : "A", registro }); // reusa seu modal
      } finally {
        if (backup !== null) {
          sessionStorage.setItem("payload_padrao_formulario", backup);
        } else {
          sessionStorage.removeItem("payload_padrao_formulario");
        }
        if (backupCdMenu !== null && backupCdMenu !== undefined) {
          sessionStorage.setItem("cd_menu", backupCdMenu);
        } else {
          sessionStorage.removeItem("cd_menu");
        }
      }

      // chama o mesmo modal que você já usa
      //this.abrirFormEspecial({ modo: (modo === 'I' ? 'I' : 'A'), registro: modelo, cd_menu_detalhe: tab.cd_menu });
      //
    },

    scrollGrid(dir) {
      const shell = this.$refs.scrollShell;
      if (!shell) return;

      const width = shell.clientWidth;
      shell.scrollBy({
        left: dir * width * 0.8, // move 80% da largura visível
        behavior: "smooth",
      });
    },
    go(dir) {
      // dir: -1 (volta), 1 (avança)
      const max = 1; // temos 2 painéis: 0 e 1
      let next = this.panelIndex + dir;
      if (next < 0) next = 0;
      if (next > max) next = max;
      if (next === this.panelIndex) return;

      this.panelIndex = next;

      // depois que o slide termina, força a grid a recalcular dimensões
      // (evita "sumir" quando fora de viewport)
      this.$nextTick(() => {
        setTimeout(() => {
          try {
            const inst = this.$refs?.grid?.instance;
            inst?.updateDimensions?.();
            inst?.refresh?.();
          } catch (_) {}
        }, 260); // ligeiramente > transition CSS (250ms)
      });
    },

    scroll(dir) {
      // dir: -1 = filtros, 1 = grid
      const el = this.$refs.viewport;
      if (!el) return;
      const delta = dir * el.clientWidth; // 1 tela
      el.scrollBy({ left: delta, behavior: "smooth" });
    },

    /* ==== Lookup helper (sem getDb; interceptor já cuida) ==== */
    async postLookup(query) {
      try {
        const { data } = await api.post("/lookup", { query }); // ou '/api/lookup' se esse for o seu prefixo
        return Array.isArray(data) ? data : [];
      } catch (e) {
        console.error("[lookup] erro", e);
        return [];
      }
    },
    //
    async abrirFormEspecial({ modo = "I", registro = {} } = {}) {
      try {
        // log pra garantir que veio algo
        //console.log('[Form] abrirFormEspecial.modo=', modo, 'registro=', registro);

        // 1) define modo
        this.formMode =
          String(modo).toUpperCase() === "A" || Number(modo) === 2 ? "A" : "I";

        // 2) pegue os metadados primeiro (lookups dependem disso)
        this.atributosForm = this.obterAtributosParaForm();

        //console.log('[Form] atributosForm=', this.atributosForm);

        if (!this.atributosForm?.length) {
          const fonte = this.rows?.[0] || registro || {};
          this.atributosForm = Object.keys(fonte).map((k) => ({
            nm_atributo: k,
            nm_edit_label: k,
            tipo_coluna: "varchar",
            tipo_input: "text",
          }));
        }

        // 3) base
        this.record = this.record || {};
        this.formData = this.formData || registro || {};

        if (this.formMode === "I") {
          // inclusão
          this.formData = this.montarRegistroVazio();

          Object.keys(sessionStorage)
            .filter((k) => k.startsWith("fixo_"))
            .forEach((k) => {
              const campo = k.replace("fixo_", "");
              const val = sessionStorage.getItem(k);
              if (campo) this.$set(this.formData, campo, val);
            });

          // carrega opções dos selects
          await this.carregarLookupsDiretos();
          //
        } else {
          // ALTERAÇÃO
          // mapeia a linha da grid pro conjunto de atributos
          this.formData = this.mapearConsultaParaAtributoRobusto(
            registro,
            this.atributosForm
          );

          console.log("[Form] formData após mapear=", this.formData);

          // normaliza para string onde necessário (selects)
          for (const a of this.atributosForm || []) {
            if (
              this.temLookupDireto(a) ||
              this.temPesquisaDinamica(a) ||
              this.temListaValor(a)
            ) {
              const v = this.formData[a.nm_atributo];
              if (v !== undefined && v !== null && v !== "") {
                this.$set(this.formData, a.nm_atributo, String(v));
              }
            }
          }

          // 1º: opções
          await this.carregarLookupsDiretos();

          // 2º: descrições (se não vieram da grid)
          await this.preencherFormEdicao(registro);
          console.log(
            "[Form] formData após preencher descrições=",
            this.formData
          );

          //if (this.formData === null || {}) {
          //  this.formData = registro || {};
          // }
        }

        // 4) abre modal
        this.dlgForm = true;
        this.formRenderizou = false;
        this.dialogCadastro = true;

        await this.$nextTick();
        this.montarFormEspecialDinamico?.();
      } catch (e) {
        console.error("Falha ao abrir form especial:", e);
        this.notifyErr("Erro ao abrir formulário.");
      }
    },

    //
    async preencherFormEdicao(registro) {
      const row = registro || {};
      if (!row || !this.atributosForm?.length) return;

      this.record = this.record || {};
      this.formData = this.formData || {};

      for (const attr of this.atributosForm) {
        const nome = attr.nm_atributo;
        const nomeDesc = attr.nm_atributo_consulta;

        // garante que formData já tem o código (mapa robusto já fez isso)
        const code = this.formData[nome];

        // se a descrição veio na grid, usa
        const descFromGrid = nomeDesc ? row[nomeDesc] ?? "" : "";
        if (nomeDesc && descFromGrid) {
          this.$set(this.record, nomeDesc, descFromGrid);
          continue;
        }

        // senão, se é lookup e tem código, busca a descrição
        if (
          (this.temLookupDireto(attr) || this.temPesquisaDinamica(attr)) &&
          code !== "" &&
          code != null
        ) {
          await this.syncLookupDescription(attr, code);
        }
      }
    },

    mapearConsultaParaAtributoRobusto(registro, atributos) {
      const out = {};
      const row = registro || {};
      const keysLower = Object.keys(row).reduce((acc, k) => {
        acc[k.toLowerCase()] = k;
        return acc;
      }, {});

      const get = (nome) => {
        if (!nome) return undefined;
        const k = keysLower[nome.toLowerCase()];
        return k ? row[k] : undefined;
      };

      for (const a of atributos || []) {
        const nm = a.nm_atributo; // ex.: cd_roteiro
        const lbl =
          a.nm_titulo_menu_atributo ||
          a.nm_edit_label ||
          a.ds_atributo ||
          a.nm_atributo;
        const nmDesc = a.nm_atributo_consulta; // ex.: nm_roteiro
        const tituloCodigo = `Código ${lbl}`; // ex.: "Código Roteiro de Visita Padrão"

        // tenta pegar valor em múltiplas formas
        let val =
          get(nm) ??
          get(tituloCodigo) ?? // coluna da grid com prefixo "Código ..."
          get(lbl) ?? // às vezes o código está na coluna com o mesmo label
          undefined;

        // se for select (lookup/lista), garanta string
        if (
          val != null &&
          (this.temLookupDireto(a) ||
            this.temPesquisaDinamica(a) ||
            this.temListaValor(a))
        ) {
          val = String(val);
        }

        out[nm] = val != null ? val : "";

        // para fins de exibir a descrição logo (se existir na grid)
        if (nmDesc) {
          const desc =
            get(nmDesc) ?? get("Descrição") ?? get(`Descricao`) ?? "";
          if (desc) {
            this.record = this.record || {};
            this.record[nmDesc] = String(desc);
          }
        }
      }

      return out;
    },

    // Dado um SELECT de lookup (nm_lookup_tabela) e o attr.nm_atributo = "cd_empresa",
    // montamos um SELECT filtrado que retorna a "Descricao".

    buildLookupByCodeSQL(attr, code) {
      // remove ORDER BY do select-base
      const base = (attr.nm_lookup_tabela || "")
        .replace(/order\s+by[\s\S]*$/i, "")
        .trim();
      if (!base) return null;

      // detecta se é numérico (ajuste se seu back usa outro naming)
      const isNumber = /(int|numeric|decimal|float|money|number)/i.test(
        attr.nm_datatype || ""
      );
      const codeExpr = isNumber
        ? String(Number(code))
        : `'${String(code).replace(/'/g, "''")}'`;

      // filtra pelo campo-código (nm_atributo)
      const codigoCampo = attr.nm_atributo;
      return `SELECT TOP 1 * FROM (${base}) T WHERE T.${codigoCampo} = ${codeExpr}`;
    },

    async syncLookupDescription(attr, code) {
      // 1) tenta nas opções já carregadas
      const opts = this.lookupOptions?.[attr.nm_atributo] || [];
      const got = opts.find((o) => String(o.__value) === String(code));
      if (got && attr.nm_atributo_consulta) {
        this.$set(this.record, attr.nm_atributo_consulta, got.__label || "");
        return;
      }
      // 2) busca direto no banco
      const sql = this.buildLookupByCodeSQL(attr, code);
      if (!sql) return;

      const rows = await this.postLookup(sql);
      const row = rows[0];
      const desc = row?.Descricao || "";
      if (desc && attr.nm_atributo_consulta) {
        this.$set(this.record, attr.nm_atributo_consulta, String(desc));
      }
    },

    //
    async carregarLookupsDiretos() {
      const attrs = (this.atributosForm || []).filter((a) =>
        this.temLookupDireto(a)
      );
      await Promise.all(attrs.map((a) => this.carregarLookupDireto(a)));
    },

    async carregarLookupDireto(attr) {
      const rows = await this.postLookup(attr.nm_lookup_tabela);
      const nomeCampo = (attr.nm_atributo || "").toLowerCase();

      const opts = rows.map((r) => {
        const vals = Object.values(r || {});
        const code = r[nomeCampo] != null ? r[nomeCampo] : vals[0];
        const label =
          r.Descricao != null ? r.Descricao : vals[1] != null ? vals[1] : code;
        return { __value: String(code), __label: String(label) };
      });

      if (!this.lookupOptions) this.lookupOptions = {};
      this.$set(this.lookupOptions, attr.nm_atributo, opts);
    },

    v2_isReadonly(campo) {
      // consulta/exclusão sempre readonly (igual form-especial)
      if (["consulta", "exclusao"].includes(this.modo)) return true;
      // regra pedida: em NOVO, se ic_edita_cadastro='N' → bloquear
      if (this.modo === "novo" && campo.ic_edita_cadastro === "N") return true;
      // numeracao automática em novo → bloquear
      if (this.modo === "novo" && campo.ic_numeracao_automatica === "S")
        return true;
      return false;
    },
    inputClass(campo) {
      return this.isReadonly(campo) ? "leitura-azul" : "";
    },

    // helpers de meta
    isInclusao() {
      return this.formMode === "I"; // 'I' = inclusão, 'A' = alteração (pelo seu código)
    },
    isChave(attr) {
      return attr.ic_atributo_chave === "S";
    },
    isAutoNum(attr) {
      // cobre as duas grafias que vi no projeto
      return attr.ic_numeracao_automatica === "S";
    },

    // 2.1 visibilidade
    showField(attr) {
      // regra: em INCLUSÃO, se for CHAVE + numeração automática => não mostra
      if (this.isInclusao() && this.isChave(attr))
        //&& this.isAutoNum(attr))
        return false;
      return true;
    },

    // 2.2 readonly + classe azul
    isReadonly(attr) {
      // INCLUSÃO: trava se meta pedir
      if (this.isInclusao() && attr.ic_edita_cadastro === "N") return true;
      // ALTERAÇÃO: trava se meta não editável
      //if (!this.isInclusao() && attr.ic_editavel === 'N') return true;
      // chaves com auto numeração: sempre readonly (ex.: na alteração)
      if (this.isChave(attr) && this.isAutoNum(attr)) return true;
      return false;
    },
    fieldClass(attr) {
      // classe no componente (q-input/q-select) – pinta o wrapper
      return this.isReadonly(attr) ? "leitura-azul" : "";
    },

    // 2.3 label com "*"
    labelCampo(attr) {
      const base =
        attr.nm_titulo_menu_atributo || attr.ds_atributo || attr.nm_atributo;
      const estrela = this.isAutoNum(attr) ? " *" : "";
      return base + estrela;
    },

    // 2.4 lista de valores
    /* ===== Lista de Valores ===== */
    // 1) tenta pegar direto do attr.Lista_Valor (string ou array)
    // 2) se não tiver, varre o payload em busca de um array "solto" com nm_atributo = do campo
    listaValores(attr) {
      // caso 1: vem dentro do attr
      let l = attr && attr.Lista_Valor;
      if (l) {
        if (typeof l === "string") {
          try {
            l = JSON.parse(l);
          } catch (e) {
            l = [];
          }
        }
        if (Array.isArray(l)) return l;
      }
      // caso 2: vem "solto" no payload (como você mostrou no exemplo)
      const nome = attr && attr.nm_atributo;
      if (!nome) return [];
      try {
        // procura em cada item de atributosForm um campo Lista_Valor (string/array)
        const agregados = [];
        (this.atributosForm || []).forEach((a) => {
          let lv = a && a.Lista_Valor;
          if (!lv) return;
          if (typeof lv === "string") {
            try {
              lv = JSON.parse(lv);
            } catch (e) {
              lv = [];
            }
          }
          if (Array.isArray(lv)) {
            lv.forEach((x) => {
              if (x && x.nm_atributo === nome) agregados.push(x);
            });
          }
        });
        return agregados;
      } catch (e) {
        return [];
      }
    },

    temListaValor(attr) {
      return this.listaValores(attr).length > 0;
    },

    // 2.5 lookup dinâmico (lupa)
    temPesquisaDinamica(attr) {
      return !!attr.cd_menu_pesquisa && Number(attr.cd_menu_pesquisa) > 0;
    },
    abrirPesquisa(attr) {
      if (!this.temPesquisaDinamica(attr)) return;
      window.abrirPesquisaDinamica &&
        window.abrirPesquisaDinamica(attr.nm_atributo, attr.cd_menu_pesquisa);
    },
    validarCampoDinamico(attr) {
      if (!this.temPesquisaDinamica(attr)) return;
      window.validarCampoDinamico &&
        window.validarCampoDinamico(
          { value: this.formData[attr.nm_atributo] },
          attr.nm_atributo,
          attr.cd_menu_pesquisa
        );
    },
    descricaoLookup(attr) {
      return this.record && attr.nm_atributo_consulta
        ? this.record[attr.nm_atributo_consulta] || ""
        : "";
    },

    // 2.6 lookup direto (select vindo do backend)
    /* garanta que você já popula this.lookupOptions[attr.nm_atributo] = [{__value, __label}] */
    temLookupDireto(attr) {
      return !!attr.nm_lookup_tabela && !attr.cd_menu_pesquisa;
    },

    async loadAllLookups() {
      const alvos = (this.payload || []).filter((c) => this.temLookupDireto(c));
      await Promise.all(alvos.map((c) => this.loadLookup(c)));
    },

    classeAzulBloqueado(campo) {
      const bloquear =
        (this.modo === "novo" && campo.ic_edita_cadastro === "N") ||
        (this.modo === "novo" && campo.ic_numeracao_automatica === "S");
      return bloquear ? "bg-primary text-white" : "";
    },

    isDateField(f) {
      const tipo = (f.ic_tipo || f.tipo || "").toString().toLowerCase();
      return tipo.includes("data") || /^dt_/.test(f.nm_atributo || "");
    },

    inputType(f) {
      // Se você já tem resolvType, mantemos a prioridade
      const base = this.resolvType ? this.resolvType(f) : null;
      if (base) return base;
      // se identificamos que é data, retorna 'date', senão 'text'
      return this.isDateField(f) ? "date" : "text";
    },

    toYMD(d) {
      if (!d) {
        console.warn("Data inválida:", d);
        return "";
      }

      // Se for string no formato "dd/mm/aaaa", converte corretamente
      if (typeof d === "string" && /^\d{2}\/\d{2}\/\d{4}$/.test(d)) {
        const [day, month, year] = d.split("/");
        d = new Date(`${year}-${month}-${day}`);
      } else {
        d = new Date(d);
      }

      if (isNaN(d)) return "";

      //const date = new Date(d);
      //if (isNaN(date)) {
      //  console.warn('Data inválida:', d)
      //return ''
      // }

      const y = d.getFullYear();
      const m = String(d.getMonth() + 1).padStart(2, "0");
      const day = String(d.getDate()).padStart(2, "0");
      return `${y}-${m}-${day}`;
    },

    formatBR(d) {
      const dd = String(d.getDate()).padStart(2, "0");
      const mm = String(d.getMonth() + 1).padStart(2, "0");
      const yyyy = d.getFullYear();
      return `${dd}/${mm}/${yyyy}`;
    },

    preencherDatasDoMes() {
      if (!this.filtros || !this.filtros.length) return;

      const hoje = new Date();
      const inicio = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
      const fim = new Date(hoje.getFullYear(), hoje.getMonth() + 1, 0);

      // escolhe o formato certo para cada filtro

      const valorPara = (f, data) => {
        const tipo = this.resolvType ? this.resolvType(f) : "text";
        return tipo === "date" ? this.toYMD(data) : this.formatBR(data);
      };

      const setIfEmpty = (key, val) => {
        if (!this.filtrosValores) this.filtrosValores = {};
        const v = this.filtrosValores[key];
        // só preenche se estiver vazio/indefinido
        if (v === undefined || v === null || v === "") {
          this.$set(this.filtrosValores, key, val);
        }
      };

      // tenta “dt_inicial / dt_final”
      const fDtIni = this.filtros.find((f) =>
        /dt_?inicial/i.test(f.nm_atributo || "")
      );
      const fDtFim = this.filtros.find((f) =>
        /dt_?final/i.test(f.nm_atributo || "")
      );

      if (fDtIni) setIfEmpty(fDtIni.nm_atributo, valorPara(fDtIni, inicio));
      if (fDtFim) setIfEmpty(fDtFim.nm_atributo, valorPara(fDtFim, fim));

      // fallback: se não existem campos explícitos inicial/final, aplica no(s) campos de data vazios
      if (!fDtIni && !fDtFim) {
        const datas = this.filtros.filter(this.isDateField);
        if (datas.length) {
          datas.forEach((f, idx) => {
            setIfEmpty(f.nm_atributo, valorPara(f, idx === 0 ? inicio : fim));
          });
        }
      }
    },

    montarFormEspecialDinamico() {
      const mountEl = this.$refs.formEspecialMount;

      if (!mountEl) return;

      // limpa container
      mountEl.innerHTML = "";

      // 1) Se você tiver importado algo como: import { buildFormEspecial } from '@/utils/form-especial'
      //    chame aqui. Como não sei o caminho no seu projeto, também suporte "window.buildFormEspecial"
      const builder =
        typeof this.buildFormEspecial === "function"
          ? this.buildFormEspecial
          : typeof window !== "undefined"
          ? window.buildFormEspecial
          : null;

      if (builder) {
        try {
          // builder(container, atributos, dados, options)
          builder(mountEl, this.atributosForm, this.formData, {
            modo: this.formMode,
            onChange: (campo, valor) => this.$set(this.formData, campo, valor),
          });
          this.formRenderizou = true;
          return;
        } catch (err) {
          console.warn(
            "builder do form especial falhou, usando fallback.",
            err
          );
        }
      }

      // 2) Se não houver builder, ficará no fallback de inputs (já no template)
      this.formRenderizou = false;
    },

    // salvar o CRUD (inclusão/alteração)

    async salvarCRUD(opts) {
      const params = opts || {};
      const modoIn = params.modo != null ? params.modo : this.modoCRUD; // pode vir 'I' | 'A' | 'E' | 1 | 2 | 3
      function mapModo(m) {
        const s = String(m).toUpperCase();
        if (s === "1" || s === "I" || s === "N" || s === "C") return 1; // Inclusão
        if (s === "2" || s === "A" || s === "U" || s === "ALT" || s === "EDIT")
          return 2; // Alteração
        if (s === "3" || s === "E" || s === "D" || s === "DEL" || s === "EXC")
          return 3; // Exclusão
        return 0;
      }

      let cd_parametro_form = mapModo(modoIn);
      let cd_documento_form = "0";
      let keyVal;

      try {
        console.log("Salvando CRUD com formData:", this.formData);

        // validação de obrigatórios

        this.salvando = true;

        const obrig = this.atributosForm
          .filter((a) => a.ic_obrigatorio === "S")
          .map((a) => a.nm_atributo);

        const faltando = obrig.filter(
          (c) =>
            this.formData[c] === null ||
            this.formData[c] === "" ||
            this.formData[c] === undefined
        );

        if (faltando.length) {
          this.notifyWarn(
            `Preencha os campos obrigatórios: ${faltando.join(", ")}`
          );
          this.salvando = false;
          return;
        }

        //const p = this.payloadTabela || {};
        //console.log('Payload tabela:', p);

        // constrói o payload correto para o salvar CRUD

        // 1) META completo do payload (mesmo que você já usa)

        let meta = [];

        try {
          meta = JSON.parse(sessionStorage.getItem("campos_grid_meta") || "[]");
        } catch (_) {
          meta = Array.isArray(this.gridMeta) ? this.gridMeta : [];
        }

        // 2) Registro que você está salvando (use o que você já tem)
        //    Deixe essas opções na ordem que seu form usa.
        let row = this.formData || {};

        //console.log('Registro a salvar:', row);

        if (!row || typeof row !== "object") row = {};

        // 3) Constrói "dados" usando **nm_atributo** (NOME TÉCNICO)
        const dadosTecnicos = {};
        // percorre o meta para garantir a ordem e nomes corretos

        meta.forEach((m) => {
          if (!m || !m.nm_atributo) return;

          // onde esse valor pode estar no objeto da UI
          const candidatos = [
            m.nm_atributo, // já técnico
            m.nm_titulo_menu_atributo, // título do payload
            m.nm_atributo_consulta, // legenda/label da grid
          ].filter(Boolean);

          let valor;

          for (let i = 0; i < candidatos.length; i++) {
            const k = candidatos[i];
            if (k in row) {
              valor = row[k];
              break;
            }
            const alt = Object.keys(row).find(
              (kk) => kk.toLowerCase() === String(k).toLowerCase()
            );
            if (alt) {
              valor = row[alt];
              break;
            }
          }

          // normalizações (números/currency/datas vazias)
          const tipo = String(m.nm_datatype || "").toLowerCase();

          if (valor === "") valor = null;

          if (
            valor != null &&
            (tipo === "date" || tipo === "datetime" || tipo === "shortdate")
          ) {
            const d = new Date(valor);
            if (!isNaN(d.getTime())) {
              // formata para ISO yyyy-mm-dd
              const yyyy = d.getFullYear();
              const mm = String(d.getMonth() + 1).padStart(2, "0");
              const dd = String(d.getDate()).padStart(2, "0");
              valor = `${yyyy}-${mm}-${dd}`;
            } else {
              valor = null;
            }
          }
          if (valor != null && (tipo === "number" || tipo === "currency")) {
            if (typeof valor === "string") {
              const s = valor
                .replace(/[R$\s]/g, "")
                .replace(/\./g, "")
                .replace(",", "."); // R$ 1.234,56 -> 1234.56
              const n = +s;
              if (!isNaN(n)) valor = n;
            }
          }

          //dadosTecnicos[m.nm_atributo] = valor == null ? null : valor;
          // trata exclusão: zera todos os campos, exceto a chave primária
          //const keyAttr = (meta.find(m => String(m.ic_atributo_chave || '').trim().toUpperCase() === 'S') || {}).nm_atributo;
          //const keyVal  = row[keyAttr]; // tenta pegar do payload original

          //console.log('Processando atributo:', m.nm_atributo, 'Valor encontrado:', valor);

          // 4) CHAVE PRIMÁRIA correta a partir do payload
          const chaveAttr = (
            meta.find(
              (m) =>
                String(m.ic_atributo_chave || "")
                  .trim()
                  .toUpperCase() === "S"
            ) || {}
          ).nm_atributo;
          //

          //console.log('Atributo chave encontrado:', chaveAttr);

          //console.log('Valor da chave no row:', row[chaveAttr]);
          //console.log('Payload completo do row:', row);
          //console.log('Payload meta:', meta);

          if (chaveAttr && m.nm_atributo === chaveAttr) {
            cd_documento_form = valor || "0";
            keyVal = valor || row[chaveAttr] || undefined;
            // console.log('Valor da chave primária para o payload:', chaveAttr, keyVal, cd_documento_form);

            // se a UI usa "id" (grid), copie para a chave real
            if (!(chaveAttr in dadosTecnicos) && "id" in row)
              dadosTecnicos[chaveAttr] = row.id;
          }

          dadosTecnicos[m.nm_atributo] =
            cd_parametro_form === 3
              ? m.nm_atributo === chaveAttr
                ? valor ?? keyVal ?? ""
                : ""
              : valor == null
              ? ""
              : valor;

          // fim do forEach
        });

        //console.log('cd_documento_form:', cd_documento_form);

        //

        // 5) Campos especiais do payload
        //const cd_documento_form = keyVal != null ? String(keyVal) : '0';
        //

        // limpeza de sobras da UI
        delete dadosTecnicos.id;
        delete dadosTecnicos["Código"];
        delete dadosTecnicos["Descricao"];
        delete dadosTecnicos["Descrição"];

        //const nowIso = new Date().toISOString();

        const now = new Date();

        // formata manualmente no padrão SQL Server: 2024-05-17 10:25:22.000
        const pad = (n) => n.toString().padStart(2, "0");
        const nowIso =
          now.getFullYear() +
          "-" +
          pad(now.getMonth() + 1) +
          "-" +
          pad(now.getDate()) +
          " " +
          pad(now.getHours()) +
          ":" +
          pad(now.getMinutes()) +
          ":" +
          pad(now.getSeconds()) +
          ".000";

        //console.log(nowIso); // ex.: "2024-05-17 10:25:22.000"

        const unico = Object.assign(
          {
            cd_menu: String(
              this.cd_menu || sessionStorage.getItem("cd_menu") || 0
            ),
            cd_form: "0",
            cd_parametro_form, // Number(this.modoCRUD), // 1/2/3 conforme sua ação
            cd_usuario: String(
              this.cd_usuario || sessionStorage.getItem("cd_usuario") || 0
            ),
            cd_cliente_form: "0",
            cd_contato_form: "",
            dt_usuario: nowIso,
            //dt_usuario: formatSQLDateTime(new Date()), // 'YYYY-MM-DD HH:mm:ss.000'
            lookup_formEspecial: {},
            detalhe: [],
            lote: [],
            cd_modulo: "",
            cd_documento_form,
          },
          dadosTecnicos
        );

        // payload final = array com 1 objeto
        const payload = unico;
        //

        // debug
        console.log(
          "JSON que vai para a rota:",
          cd_parametro_form,
          payload,
          dadosTecnicos
        );
        //
        ////
        await api.post("/api-dados-form", payload, {
          headers: { "Content-Type": "application/json" },
        });
        ///

        this.notifyOk(
          this.formMode === "I"
            ? "Registro atualizado com sucesso."
            : "Registro atualizado com sucesso."
        );

        this.dlgForm = false;
        // === RECARREGAR A GRID (coloque logo após o POST OK) ===
        try {
          // 1) Reconsultar seus dados do backend (mantém seus nomes)
          if (typeof this.consultar === "function") {
            await this.consultar(); // deve repopular this.rows com os dados mais recentes
          }

          // 2) Aguarda a atualização reativa
          await this.$nextTick();

          // 3) Pega a instância do grid
          const inst =
            this.$refs && this.$refs.grid && this.$refs.grid.instance
              ? this.$refs.grid.instance
              : null;

          if (inst) {
            inst.beginUpdate();

            // 3.1 Zera foco/seleção que podem apontar para registro excluído

            try {
              inst.clearSelection && inst.clearSelection();
              inst.option("focusedRowKey", null);
              inst.option("focusedRowIndex", -1);
              inst.option("focusedRowEnabled", false);
            } catch (_) {}

            // 3.2 (Re)descobre a chave técnica pelo meta
            let meta = [];
            //
            try {
              meta = JSON.parse(
                sessionStorage.getItem("campos_grid_meta") || "[]"
              );
            } catch (_) {
              meta = Array.isArray(this.gridMeta) ? this.gridMeta : [];
            }

            let keyName = "id";
            //
            const campoChave = Array.isArray(meta)
              ? meta.find(
                  (m) =>
                    String(m.ic_atributo_chave || "")
                      .trim()
                      .toUpperCase() === "S"
                )
              : null;
            if (campoChave && campoChave.nm_atributo)
              keyName = campoChave.nm_atributo;

            // 3.3 Se os registros não têm a chave, gera fallback 'id'

            if (Array.isArray(this.rows) && this.rows.length) {
              const temChave =
                keyName &&
                (keyName in this.rows[0] ||
                  Object.keys(this.rows[0]).some(
                    (k) => k.toLowerCase() === String(keyName).toLowerCase()
                  ));
              if (!temChave) {
                this.rows = this.rows.map((r, i) => ({ id: i + 1, ...r }));
                keyName = "id";
              }
            }

            // 3.4 Reaplica keyExpr antes do dataSource
            inst.option("keyExpr", keyName);

            // 3.5 Força **rebind** do dataSource (novo array = novo ref)
            //    (evita “não recarregar” quando o Vue atualiza o mesmo array)
            const novaFonte = Array.isArray(this.rows) ? this.rows.slice() : [];
            inst.option("dataSource", null); // quebra o binding anterior
            inst.option("dataSource", novaFonte); // rebind com referência nova

            // 3.6 Reativa foco (se você usa)
            inst.option("focusedRowEnabled", true);

            inst.endUpdate();
            inst.refresh();
          } else {
            // Fallback: se não houver instância da grid, faz uma reconsulta completa
            if (typeof this.consultar === "function") {
              await this.consultar();
            }
          }
        } catch (e) {
          console.warn("Refresh pós-CRUD falhou:", e);
        }
      } catch (e) {
        console.error("Falha ao salvar CRUD:", e);
        this.notifyErr("Erro ao salvar dados do formulário.");
      } finally {
        this.salvando = false;
        this.dialogCadastro = false; // fecha modal depois do refresh
        this.formData = {};
      }
    },

    //
    keyNameInfer() {
      const p = this.payloadTabela || {};
      if (p.key_name) return p.key_name;
      const t = (p.nm_tabela || p.nm_tabela_consulta || "")
        .toLowerCase()
        .replace(/^dbo\./, "");
      return t ? `cd_${t}` : "id";
    },

    // fecha o form especial

    fecharForm() {
      this.dlgForm = false;
      // se quiser limpar lixo de builder:
      const mountEl = this.$refs.formEspecialMount;
      if (mountEl) mountEl.innerHTML = "";
      this.formRenderizou = false;
    },

    // preenche campos de data com início/fim do mês vigente
    preencherDatasDoMesOld() {
      // se ainda não tem filtros, não faz nada
      if (!this.filtros || !this.filtros.length) return;

      // datas do mês vigente
      const hoje = new Date();
      const inicio = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
      const fim = new Date(hoje.getFullYear(), hoje.getMonth() + 1, 0);

      // garante o objeto de valores
      if (!this.filtrosValores) this.filtrosValores = {};

      // util: seta só se estiver vazio (mantém o que o usuário já digitou)
      const setIfEmpty = (key, val) => {
        const cur = this.filtrosValores[key];
        if (cur === undefined || cur === null || cur === "") {
          // usa formatBR que já existe no seu código
          this.$set(this.filtrosValores, key, this.formatBR(val));
        }
      };

      // tenta achar campos padrão "inicial" e "final"
      const isInicial = (f) =>
        /dt_?inicial|data_?inicial|ini(cio|cial)?/i.test(f.nm_atributo || "");
      const isFinal = (f) =>
        /dt_?final|data_?final|fim/i.test(f.nm_atributo || "");

      const fInicial = this.filtros.find(isInicial);
      const fFinal = this.filtros.find(isFinal);

      if (fInicial) setIfEmpty(fInicial.nm_atributo, inicio);
      if (fFinal) setIfEmpty(fFinal.nm_atributo, fim);

      // fallback: se não existem campos explícitos de inicial/final,
      // preenche os primeiros campos de "data" encontrados
      if (!fInicial && !fFinal) {
        // heurística: nome contendo "dt" ou "data" ou tp_dado === 'D'
        const camposData = this.filtros.filter(
          (f) =>
            /(^dt_|data|_dt$)/i.test(f.nm_atributo || "") ||
            String(f.tp_dado || "").toUpperCase() === "D"
        );
        if (camposData.length === 1) {
          setIfEmpty(camposData[0].nm_atributo, inicio);
        } else if (camposData.length > 1) {
          setIfEmpty(camposData[0].nm_atributo, inicio);
          setIfEmpty(camposData[1].nm_atributo, fim);
        }
      }
    },

    // pega colunas/linhas do mesmo jeito que o display-data.vue salva

    _getColsRowsFromLocalStorage() {
      // colunas
      const meta = JSON.parse(localStorage.getItem("campos_grid_meta") || "[]");
      const cols =
        this.columns && this.columns.length
          ? this.columns
          : meta.map((c) => ({
              field: c.nm_atributo,
              label: c.nm_label || c.nm_atributo,
              name: c.nm_atributo,
            }));

      // linhas
      const rows =
        this.rows && this.rows.length
          ? this.rows
          : JSON.parse(
              localStorage.getItem("dados_resultado_consulta") || "[]"
            );

      return { cols, rows };
    },

    abrirRelatorio() {
      // garanta que gridRows e camposMetaGrid estão prontos aqui
      if (!Array.isArray(this.columns) || this.columns.length === 0) {
        //this.$q.notify({ type:'warning', position:'top-right', message:'Sem dados para o relatório.' })
        this.notifyWarn("Sem dados para o relatório.");
        return;
      }
      // Se já tiver grid pronta no form, passe os dados e meta por props:
      // this.$refs.relComp (opcional) poderá acessar depois
      this.showRelatorio = true;
    },

    async bootstrap() {
      // pega da URL (ex.: ?cd_menu=236&cd_usuario=842) e do localStorage
      const q = new URLSearchParams(window.location.search);
      const cd_menu_q = q.get("cd_menu");
      const cd_usuario_q = q.get("cd_usuario");

      // compat: projetos antigos gravam como propriedades (localStorage.cd_menu),
      // então leio dos DOIS jeitos
      const cd_menu_ls_dot = window.localStorage.cd_menu;
      const cd_usuario_ls_dot = window.localStorage.cd_usuario;
      const cd_menu_ls_get = window.localStorage.getItem("cd_menu");
      const cd_usuario_ls_get = window.localStorage.getItem("cd_usuario");

      const cd_menu = cd_menu_q || cd_menu_ls_dot || cd_menu_ls_get;
      const cd_usuario = cd_usuario_q || cd_usuario_ls_dot || cd_usuario_ls_get;

      this.cd_menu = cd_menu ? String(cd_menu) : null;
      this.cdMenu = this.cd_menu;
      this.temSessao = !!(this.cd_menu && cd_usuario);

      if (!this.temSessao) {
        console.warn("cd_menu/cd_usuario ausentes na sessão.");
        // limpa qualquer lixo visual e sai sem erro
        this.rows = [];
        this.columns = [];
        this.totalColumns = [];
        this.qt_registro = 0;

        return;
      }

      // Carrega configuração da grid e filtros
      // --> pr_egis_payload_tabela
      //
      await this.loadPayload(cd_menu, cd_usuario);

      //
      this.montarAbasDetalhe();
      //

      // Carrega os filtros dinâmicos
      await this.loadFiltros(cd_menu, cd_usuario);
      // Se não houver filtro obrigatório, já faz a consulta

      const filtroObrig = this.gridMeta.some(
        (c) => c.ic_filtro_obrigatorio === "S"
      );
      const registroMenu = this.gridMeta.some(
        (c) => c.ic_registro_tabela_menu === "S"
      );

      if (registroMenu && !filtroObrig && !this.isPesquisa) {
        this.consultar();
      }
    },

    notifyOk(msg) {
      this.$q.notify({
        type: "positive",
        message: msg,
        position: "center",
        timeout: 3000,
        actions: [{ icon: "close", color: "white" }],
      });
    },

    notifyWarn(msg) {
      this.$q.notify({
        type: "warning",
        message: msg,
        position: "center",
        timeout: 3000,
        actions: [{ icon: "close", color: "white" }],
      });
    },
    notifyErr(msg) {
      this.$q.notify({
        type: "negative",
        message: msg,
        position: "center",
        timeout: 3000,
        actions: [{ icon: "close", color: "white" }],
      });
    },

    async showMenu() {
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      this.cd_menu_destino = 0;
      this.cd_api_destino = 0;
      localStorage.cd_parametro = 0;

      var dataI = new Date(localStorage.dt_inicial);
      var diaI = dataI.getDate().toString();
      var mesI = (dataI.getMonth() + 1).toString();
      var anoI = dataI.getFullYear();
      localStorage.dt_inicial = mesI + "-" + diaI + "-" + anoI;

      var dataF = new Date(localStorage.dt_final);
      var diaF = dataF.getDate().toString();
      var mesF = (dataF.getMonth() + 1).toString();
      var anoF = dataF.getFullYear();
      localStorage.dt_final = mesF + "-" + diaF + "-" + anoF;

      var dataB = new Date(localStorage.dt_base);
      var diaB = dataB.getDate().toString();
      var mesB = (dataB.getMonth() + 1).toString();
      var anoB = dataB.getFullYear();

      localStorage.dt_base = mesB + "-" + diaB + "-" + anoB;

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';

      //dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';
      this.menu_titulo = dados.nm_menu_titulo;
      this.menu_relatorio = dados.menu_relatorio;
      this.cd_parametro_menu = dados.cd_parametro_menu;

      //console.log('menu: ',dados, dados.cd_parametro_menu);

      //this.sParametroApi       = dados.nm_api_parametro;

      sParametroApi = dados.nm_api_parametro;
      let parametro_valor = JSON.parse(dados.nm_api_parametro_valor);
      Object.keys(parametro_valor).map((e, index) => {
        if (parametro_valor[Object.keys(parametro_valor)[index]]) {
          if (e.startsWith("dt_")) {
            //Verifica as datas e formata
            let novaData = formataData.formataDataSQL(
              parametro_valor[Object.keys(parametro_valor)[index]]
            );
            // eslint-disable-next-line no-useless-escape
            let regexData = /([0-9]{2})\-([0-9]{2})\-([0-9]{4})/;
            regexData.test(novaData)
              ? (localStorage[e] =
                  parametro_valor[Object.keys(parametro_valor)[index]])
              : "";
          } else {
            localStorage[e] =
              parametro_valor[Object.keys(parametro_valor)[index]];
          }
        }
      });

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      this.qt_tabsheet = dados.qt_tabsheet;
      this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa;
      this.exportar = false;
      this.arquivo_abrir = false;
      this.ativaPDF = false;
      this.qt_tempo = dados.qt_tempo_menu;
      this.ds_menu_descritivo = dados.ds_menu_descritivo;
      this.ic_form_menu = dados.ic_form_menu;
      this.ic_tipo_data_menu = dados.ic_tipo_data_menu;
      this.cd_tipo_email = dados.cd_tipo_email;
      this.cd_detalhe = dados.cd_detalhe;
      this.cd_menu_detalhe = dados.cd_menu_detalhe;
      this.cd_api_detalhe = dados.cd_api_detalhe;

      //this.cd_relatorio       = dados.cd_relatorio;

      if (this.ic_tipo_data_menu == "1") {
        this.hoje = " - " + new Date().toLocaleDateString();
      }
      if (this.ic_tipo_data_menu == "2" || this.ic_tipo_data_menu == "3") {
        this.hora = new Date().toLocaleTimeString().substring(0, 5);
      }

      if (dados.ic_exportacao == "S") {
        this.exportar = true;
      }

      localStorage.cd_tipo_consulta = 0;

      if (!dados.cd_tipo_consulta == 0) {
        localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.menu = dados.nm_menu;

      filename = this.tituloMenu + ".xlsx";
      filenametxt = this.tituloMenu + ".txt";
      filenamedoc = this.tituloMenu + ".docx";
      filenamexml = this.tituloMenu + ".xml";

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      //
      this.columns.map((c) => {
        if (c.ic_botao === "S") {
          c.cellTemplate = (cellElement, cellInfo) => {
            const buttonEdit = document.createElement("button");
            buttonEdit.textContent = c.nm_botao_texto;
            buttonEdit.style.padding = "8px 12px";
            buttonEdit.style.marginRight = "5px";
            buttonEdit.style.border = "none";
            buttonEdit.style.borderRadius = "4px";
            buttonEdit.style.fontSize = "14px";
            buttonEdit.style.cursor = "pointer";
            buttonEdit.style.backgroundColor = "#1976D2";
            buttonEdit.style.color = "white";
            buttonEdit.style.transition =
              "background-color 0.3s ease, transform 0.2s ease";

            // Adicionando efeito de hover
            buttonEdit.onmouseover = () => {
              buttonEdit.style.backgroundColor = "#1565C0"; // Cor mais escura ao passar o mouse
              buttonEdit.style.transform = "scale(1.05)"; // Leve aumento no tamanho
            };
            buttonEdit.onmouseout = () => {
              buttonEdit.style.backgroundColor = "#1976D2"; // Volta à cor original
              buttonEdit.style.transform = "scale(1)"; // Retorna ao tamanho normal
            };
            buttonEdit.onclick = () =>
              this.handleButton({
                data: cellInfo.data,
                ic_procedimento_crud: c.ic_procedimento_crud,
                nm_api_busca: c.nm_api_busca,
              });

            cellElement.appendChild(buttonEdit);
          };
        }
        if (c.dataType === "date") {
          c.calculateCellValue = (row) => {
            if (!row[c.dataField]) return "";
            if (row[c.dataField].length < 10) return row[c.dataField];

            const [datePart] = row[c.dataField].split(" ");
            const [year, month, day] = datePart.split("-");

            return `${day.substring(0, 2)}/${month}/${year}`;
          };
        }
      });
      //dados do total
      //this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //
      this.total = (() => {
        try {
          const raw =
            dados && dados.coluna_total
              ? dados.coluna_total
              : '{"totalItems":[]}';
          return JSON.parse(JSON.parse(JSON.stringify(raw)));
        } catch (e) {
          return { totalItems: [] };
        }
      })();

      //TabSheet
      this.tabs = [];
      //

      if (!this.qt_tabsheet == 0) {
        this.tabs = JSON.parse(JSON.parse(JSON.stringify(dados.TabSheet)));
        this.cd_menu_destino = parseInt(this.cd_menu);
        this.cd_api_destino = parseInt(this.cd_api);
      }
      //Filtros

      this.filtro = [];

      if (this.ic_filtro_pesquisa == "S") {
        this.filtro = await JSON.parse(
          JSON.parse(JSON.stringify(dados.Filtro))
        );

        if (!!this.filtro[0].cd_tabela == false) {
          this.dados_lookup = await Lookup.montarSelect(
            this.cd_empresa,
            dados.cd_tabela
          );
        } else {
          this.dados_lookup = await Lookup.montarSelect(
            this.cd_empresa,
            this.filtro[0].cd_tabela
          );
        }
        if (!!this.dados_lookup != false) {
          this.dataset_lookup = JSON.parse(
            JSON.parse(JSON.stringify(this.dados_lookup.dataset))
          );
          this.value_lookup = this.filtro[0].nm_campo_chave_lookup;
          this.label_lookup = this.filtro[0].nm_campo;
          this.placeholder_lookup = this.filtro[0].nm_campo_descricao_lookup;
        }
      }

      //trocar para dados.laberFormFiltro
      //this.formDataFiltro = JSON.parse(dados.Filtro);
      //this.itemsFiltro = JSON.parse(dados.labelForm);
      //
    },

    onVoltar() {
      if (this.$router) this.$router.back();
      else window.history.back();
    },

    // integração com o searchPanel do DevExtreme
    onSearchChange(val) {
      const inst = this.$refs.grid && this.$refs.grid.instance;
      if (inst && inst.searchByText) {
        inst.searchByText(val || "");
      }
    },

    // coloca ícones/botões na toolbar da grid
    onToolbarPreparing(e) {
      const items = e.toolbarOptions.items;
      // Botão Excel (à direita)
      items.push({
        location: "after",
        widget: "dxButton",
        options: {
          hint: "Exportar Excel",
          icon: "exportxlsx",
          onClick: this.exportarExcel,
        },
      });

      // (opcional) botão limpar filtros
      items.push({
        location: "after",
        widget: "dxButton",
        options: {
          hint: "Limpar filtros",
          icon: "clearsquare",
          onClick: () => this.$refs.grid.instance.clearFilter(),
        },
      });
    },

    imprimirPDF() {
      window.print();
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
          const logoUrl = "https://egisapp.com.br/img/logo_your_company.png";
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
          message: "Falha ao exportar PDF.",
        });
      }
    },

    async exportarPDFold() {
      try {
        // 1) Tenta pegar do seu storage (mantido)
        let cols = [];
        let rows = [];
        try {
          const r = this._getColsRowsFromLocalStorage?.() || {};
          cols = Array.isArray(r.cols) ? r.cols : [];
          rows = Array.isArray(r.rows) ? r.rows : [];
        } catch (_) {}

        // 2) Fallback: usa colunas/linhas que já estão na tela
        if (!rows.length) rows = this.rows || this.gridRows || [];
        if (!cols.length) cols = this.columns || this.gridColumns || [];

        // 3) Limpa colunas “de ação”
        const isAcao = (c) =>
          c?.type === "buttons" ||
          c?.buttons ||
          c?.field === "__acoes" ||
          c?.name === "__acoes";
        cols = (cols || []).filter((c) => !isAcao(c));

        if (!Array.isArray(rows) || rows.length === 0) {
          this.$q?.notify?.({
            type: "warning",
            message: "Sem dados para exportar.",
          });
          return;
        }
        if (!Array.isArray(cols) || cols.length === 0) {
          this.$q?.notify?.({
            type: "warning",
            message: "Sem colunas para exportar.",
          });
          return;
        }

        // 4) Imports dinâmicos
        const jsPDF = (await import(/* webpackChunkName: "jspdf" */ "jspdf"))
          .default;
        const { default: autoTable } = await import(
          /* webpackChunkName: "jspdf-autotable" */ "jspdf-autotable"
        );

        // 5) Helpers de formatação
        const toBRDate = (v) => {
          if (v == null || v === "") return "";
          try {
            if (typeof v === "string" && /^\d{2}\/\d{2}\/\d{4}$/.test(v))
              return v; // já está em BR
            const d = new Date(v);
            return isNaN(d) ? String(v) : d.toLocaleDateString("pt-BR");
          } catch {
            return String(v);
          }
        };

        const toBRNumber = (v) => {
          const n = Number(v);
          if (!isFinite(n)) return v ?? "";
          return n.toLocaleString("pt-BR");
        };

        const toBRMoney = (v) => {
          const n = Number(v);
          if (!isFinite(n)) return v ?? "";
          return n.toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL",
          });
        };

        // se você já tem this.formatCell/metaPorDataField, uso; senão aplico heurística
        const fmtCell = (val, meta = {}) => {
          if (typeof this.formatCell === "function")
            return this.formatCell(val, meta);
          const fmt = (meta.formato_coluna || meta.format || "")
            .toString()
            .toLowerCase();
          if (fmt.includes("date")) return toBRDate(val);
          if (fmt.includes("currency")) return toBRMoney(val);
          if (
            fmt.includes("number") ||
            fmt.includes("fixed") ||
            fmt.includes("percent")
          )
            return toBRNumber(val);
          return val ?? "";
        };

        const getField = (c) => c.field || c.name || c.dataField;
        const getLabel = (c) =>
          c.label || c.caption || c.name || c.field || c.dataField;

        // 6) Cabeçalho (logo/empresa/título/filtros)
        const titulo =
          this.pageTitle ||
          this.title ||
          sessionStorage.getItem("menu_titulo") ||
          "Relatório";
        const empresa =
          localStorage.nm_fantasia_empresa || localStorage.empresa || "";
        const logoURL =
          localStorage.logo_url ||
          sessionStorage.getItem("logo_url") ||
          "/img/logo.png"; // ajuste para um caminho seu (mesma origem, de preferência)

        // melhor esforço para carregar logo (se falhar, segue sem)
        const loadImageAsDataUrl = (url) =>
          new Promise((resolve) => {
            try {
              const img = new Image();
              img.crossOrigin = "anonymous";
              img.onload = () => {
                try {
                  const cv = document.createElement("canvas");
                  cv.width = img.naturalWidth;
                  cv.height = img.naturalHeight;
                  const ctx = cv.getContext("2d");
                  ctx.drawImage(img, 0, 0);
                  resolve(cv.toDataURL("image/png"));
                } catch {
                  resolve(null);
                }
              };
              img.onerror = () => resolve(null);
              img.src = url;
            } catch {
              resolve(null);
            }
          });

        const logoDataUrl = await loadImageAsDataUrl(logoURL).catch(() => null);

        // monta texto de filtros
        const filtrosTxt = (() => {
          try {
            if (!this.filtros || !this.filtros.length) return "";
            const pares = [];
            for (const f of this.filtros) {
              const k = f.nm_atributo;
              const rot = f.nm_edit_label || f.nm_filtro || k;
              let v = this?.filtrosValores?.[k];
              // força data BR
              if (/^dt_/.test(k)) v = toBRDate(v);
              if (v != null && v !== "") pares.push(`${rot}: ${v}`);
            }
            return pares.join("  |  ");
          } catch {
            return "";
          }
        })();

        // 7) Prepara tabela
        const columnsForPDF = cols.map((c) => ({
          header: getLabel(c),
          dataKey: getField(c),
        }));

        const body = rows.map((r) => {
          const obj = {};
          for (const c of cols) {
            const key = getField(c);
            const meta = { ...c, formato_coluna: c.formato_coluna || c.format };
            obj[key] = fmtCell(r[key], meta);
          }
          return obj;
        });

        // 8) Cria PDF
        const doc = new jsPDF({
          orientation: "landscape",
          unit: "pt",
          format: "a4",
        });
        const pageW = doc.internal.pageSize.getWidth();
        const margin = 40;
        let cursorY = margin;

        // logo (opcional)
        if (logoDataUrl) {
          const logoW = 120;
          const logoH = 40;
          doc.addImage(logoDataUrl, "PNG", margin, cursorY - 10, logoW, logoH);
        }

        // empresa + título
        doc.setFontSize(20);
        doc.text(String(titulo), margin + (logoDataUrl ? 130 : 0), cursorY + 5);

        doc.setFontSize(10);
        const agora = new Date();
        const headerRight = [
          empresa ? `Empresa: ${empresa}` : null,
          `Data/Hora: ${agora.toLocaleString("pt-BR")}`,
        ]
          .filter(Boolean)
          .join("  |  ");
        doc.text(headerRight, pageW - margin, cursorY, { align: "right" });

        cursorY += 28;

        if (filtrosTxt) {
          doc.setFontSize(11);
          doc.text(filtrosTxt, margin, cursorY, {
            maxWidth: pageW - margin * 2,
          });
          cursorY += 16;
        }

        // 9) Tabela
        autoTable(doc, {
          startY: cursorY,
          margin: { left: margin, right: margin },
          columns: columnsForPDF,
          body,
          styles: {
            fontSize: 9,
            cellPadding: 4,
            halign: "left",
            valign: "middle",
          },
          headStyles: { fillColor: [240, 240, 240] },
          didDrawPage: () => {
            // rodapé
            const w = doc.internal.pageSize.getWidth();
            const h = doc.internal.pageSize.getHeight();
            doc.setFontSize(8);
            doc.text(
              `Página ${doc.internal.getNumberOfPages()}`,
              w - margin,
              h - 12,
              { align: "right" }
            );
          },
        });

        // 10) Totais (this.totalColumns ou this.total?.totalItems)
        const montarTotais = () => {
          const tcols = this.totalColumns || this.total?.totalItems || [];
          if (!Array.isArray(tcols) || !tcols.length) return [];

          const out = [];
          tcols.forEach((t) => {
            const df = t.dataField || t.name || t.field;
            const tipo = String(t.type || "").toLowerCase();
            if (!df || !tipo) return;

            if (tipo === "sum") {
              const soma = rows.reduce((acc, r) => {
                const n = Number(r[df]);
                return acc + (isFinite(n) ? n : 0);
              }, 0);
              const caption = (t.display || `Total de ${df}`)
                .replace("{0}", "")
                .trim();
              out.push({ caption, value: toBRMoney(soma) });
            } else if (tipo === "count") {
              const caption = (t.display || `Quantidade`)
                .replace("{0}", "")
                .trim();
              out.push({ caption, value: toBRNumber(rows.length) });
            }
          });
          return out;
        };

        const totais = montarTotais();
        if (totais.length) {
          const y = doc.lastAutoTable?.finalY
            ? doc.lastAutoTable.finalY + 12
            : cursorY + 12;
          autoTable(doc, {
            startY: y,
            margin: { left: margin, right: margin },
            columns: [
              { header: "Resumo", dataKey: "caption" },
              { header: "Valor", dataKey: "value" },
            ],
            body: totais,
            styles: { fontSize: 10, cellPadding: 3 },
            headStyles: { fillColor: [230, 230, 230] },
          });
        }

        // 11) salvar
        const nome = String(titulo)
          .replace(/\s+/g, "_")
          .normalize("NFD")
          .replace(/[\u0300-\u036f]/g, "");
        doc.save(`${nome || "relatorio"}.pdf`);
      } catch (e) {
        console.error("PDF erro", e);
        this.$q?.notify?.({
          type: "negative",
          message: "Falha ao exportar PDF.",
        });
      }
    },

    // export usando ExcelJS + exporter oficial do DevExtreme
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

    // ações (placeholders — conecte com seu CRUD/export já existentes)
    onNovo() {
      // abra seu modal de cadastro
      //this.abrirFormEspecial({ modo: 'I', registro: {} });

      // 1) preparar modo
      this.formMode = "I";
      this.formData = {};

      // 2) montar registro vazio pela lista de atributos disponível
      this.formData = this.montarRegistroVazio();

      // 3) aplicar fixos do sessionStorage (ex.: cd_cliente, cd_empresa, etc.)
      Object.keys(sessionStorage)
        .filter((k) => k.startsWith("fixo_"))
        .forEach((k) => {
          const campo = k.replace("fixo_", "");
          const val = sessionStorage.getItem(k);
          if (campo) this.$set(this.formData, campo, val);
        });

      // 4) abrir modal
      this.dlgNovo = true;
      //
    },

    onEditar(row) {
      this.formMode = "A";
      this.dialogCadastro = true;
      this.abrirFormEspecial({ modo: "A", registro: row });
    },

    async onExcluir(row) {
      // garanta que é um objeto plano
      const plain = JSON.parse(JSON.stringify(row));
      // abrir form especial (se necessário)
      //
      this.abrirFormEspecial({ modo: "E", registro: row });
      //

      if (!confirm("Confirma exclusão?")) return;

      //await this.salvarCRUD({ modo: 'E', registro: row });
      //this.gridInst.refresh(); // ou recarregue os dados

      //console.log('Excluir registro:', plain);
      this.formData = plain;
      //
      this.formMode = "E";
      // mapa campos se necessário
      await this.salvarCRUD({ modo: "E", registro: plain }); // cd_parametro_form = 3
      //

      // refresh seguro da grid
      //try {
      //  const inst = this.$refs && this.$refs.grid && this.$refs.grid.instance ? this.$refs.grid.instance : null;
      // if (inst) inst.refresh();
      // else if (typeof this.consultar === 'function') await this.consultar();
      // }
      //   catch(_) {}
      //
    },

    montarRegistroVazio() {
      const attrs = this.obterAtributosParaForm();

      const novo = {};
      attrs.forEach((a) => {
        const nome = a.nm_atributo || a.dataField || a.nome;
        if (!nome) return;
        const t = (a.tipo_coluna || a.tipo || "").toLowerCase();
        if (/(int|bigint|smallint|tinyint|numeric|decimal|float|money)/.test(t))
          novo[nome] = 0;
        else if (/(bit|bool)/.test(t)) novo[nome] = 0;
        else if (/date/.test(t)) novo[nome] = null;
        else novo[nome] = "";
      });
      return novo;
    },

    mapearConsultaParaAtributo(row) {
      // usa o mapa salvo no sessionStorage (se existir)
      const mapa = JSON.parse(
        sessionStorage.getItem("mapa_consulta_para_atributo") || "{}"
      );
      if (!mapa || !Object.keys(mapa).length) return { ...row };

      const novo = {};
      Object.keys(row).forEach((k) => {
        const destino = mapa[k] || k;
        novo[destino] = row[k];
      });
      return novo;
    },

    obterAtributosParaForm() {
      // 1) se já estiver pronto, reuse
      if (Array.isArray(this.atributosForm) && this.atributosForm.length) {
        return this.atributosForm;
      }

      // 2) tente descobrir a “base” de atributos
      //    (gridMeta já é um ARRAY de atributos no seu log)
      let base =
        (Array.isArray(this.gridMeta) &&
          this.gridMeta.length &&
          this.gridMeta) ||
        (Array.isArray(this.gridMeta?.atributos) && this.gridMeta.atributos) ||
        (Array.isArray(this.gridMeta?.colunas) && this.gridMeta.colunas) ||
        (Array.isArray(this.colunasGrid) && this.colunasGrid) ||
        [];

      // 3) NORMALIZAÇÃO: não “simplifique” os atributos aqui!
      //    Apenas garanta que Lista_Valor esteja em array
      base = base.filter(Boolean).map((a) => {
        const attr = { ...a };

        // nm_atributo é obrigatório
        attr.nm_atributo = attr.nm_atributo || attr.dataField || attr.nome;

        // label padrão (só fallback, sem sobrescrever se já existir)
        attr.nm_edit_label =
          attr.nm_edit_label ||
          attr.nm_titulo_menu_atributo ||
          attr.caption ||
          attr.label ||
          attr.ds_atributo ||
          attr.nm_atributo;

        // Lista_Valor pode vir como string vazia, " ", ou JSON
        if (typeof attr.Lista_Valor === "string") {
          const s = attr.Lista_Valor.trim();
          if (s.startsWith("[") && s.endsWith("]")) {
            try {
              attr.Lista_Valor = JSON.parse(s);
            } catch {
              attr.Lista_Valor = [];
            }
          } else {
            attr.Lista_Valor = [];
          }
        }
        if (!Array.isArray(attr.Lista_Valor)) {
          attr.Lista_Valor = [];
        }

        // flags que podem vir null/undefined → normaliza com 'N'
        const flags = [
          "ic_atributo_chave",
          "ic_edita_cadastro",
          "ic_editavel",
          "ic_numeracao_automatica",
          "ic_numeracao_aumotatica",
        ];
        flags.forEach((f) => {
          if (attr[f] == null) attr[f] = "N";
        });

        return attr;
      });

      // 4) cache local (opcional, se você usa como data)
      this.atributosForm = base;

      // 5) devolve a lista COMPLETA (com todos os metadados!)
      return base;
    },

    // salvar novo registro (form especial)

    async salvarNovo() {
      try {
        this.salvando = true;

        // valida mínimos
        const obrig = this.obterObrigatorios();
        const faltando = obrig.filter((c) => !this.temValor(this.formData[c]));
        if (faltando.length) {
          this.notifyWarn(
            `Preencha os campos obrigatórios: ${faltando.join(", ")}`
          );
          this.salvando = false;
          return;
        }

        const p = this.payloadTabela || {};

        const payload = {
          nm_tabela: p.nm_tabela || p.nm_tabela_consulta, // da /api/payload-tabela
          nm_schema: p.nm_schema || "dbo",
          cd_usuario: Number(sessionStorage.getItem("cd_usuario")) || 1,
          cd_parametro: 1, // 1 = INCLUIR
          dados: { ...this.formData },
        };

        // (se sua proc exigir campos de auditoria, complete aqui)
        // payload.dados.cd_empresa = payload.dados.cd_empresa || Number(sessionStorage.getItem('fixo_cd_empresa')) || null;

        const { data } = await api.post("/api-dados-form", payload);

        // se a SP retornou a PK gerada, injeta no objeto (ex.: cd_xxx)

        if (Array.isArray(data) && data.length) {
          const ret = data[0];
          const chave = this.keyNameInfer(); // tenta descobrir o nome do campo-chave
          if (chave && ret[chave]) this.formData[chave] = ret[chave];
        }

        this.notifyOk("Registro incluído com sucesso.");
        this.dlgNovo = false;

        // recarrega grid com os filtros atuais
        await this.consultar();
        //
      } catch (e) {
        console.error("Erro ao incluir:", e);
        this.notifyErr("Erro ao incluir registro.");
      } finally {
        this.salvando = false;
      }
    },

    //

    obterObrigatorios() {
      // se sua meta marcar obrigatórios (ic_obrigatorio === 'S'), use isso
      const attrs = this.obterAtributosParaForm();
      return attrs
        .filter((a) => a.ic_obrigatorio === "S")
        .map((a) => a.nm_atributo);
    },

    temValor(v) {
      return !(v === null || v === undefined || v === "" || v === "null");
    },

    exportPdf() {
      // idem PDF
    },

    copiarDados() {
      try {
        const texto = JSON.stringify(this.rows || []);
        navigator.clipboard.writeText(texto);
        //this.$q.notify({ type:'positive', message:'Dados copiados' })
        this.notifyOk("Dados copiados!");
      } catch (_e) {
        //this.$q.notify({ type:'warning', message:'Não foi possível copiar' })
        this.notifyWarn("Não foi possível copiar!");
      }
    },

    abrirCalendario() {
      // opcional
    },

    abrirInfo() {
      // opcional: mostrar info do payload, etc
    },

    resolvType(f) {
      const nome = (f.nm_atributo || "").toLowerCase();

      if (
        nome.includes("dt_inicial") ||
        nome.includes("dt_final") ||
        f.nm_datatype === "date"
      )
        return "date";

      if (/(date|data)/.test(nome)) return "date";

      if (/(number|inteiro|decimal)/.test(nome)) return "number";

      return "text";
    },

    //

    async loadPayload(cd_menu, cd_usuario) {
      //

      const limparChaves = [
        "payload_padrao_formulario",
        "campos_grid_meta",
        "dados_resultado_consulta",
        "filtros_form_especial",
        "registro_selecionado",
        "mapa_consulta_para_atributo",
        "tab_menu",
        "ic_filtro_obrigatorio",
        "ic_crud_processo",
        "ic_detalhe_menu",
        "nome_procedure",
        "ic_json_parametro",
        "cd_relatorio",
        "cd_relatorio_auto",
      ];
      limparChaves.forEach((k) => sessionStorage.removeItem(k));

      // Remove versões por menu (…_<cd>)
      Object.keys(sessionStorage).forEach((k) => {
        if (
          /(payload_padrao_formulario|campos_grid_meta|dados_resultado_consulta|registro_selecionado|cd_menu_detalhe|payload_padrao_formulario_detalhe|campos_grid_meta_detalhe|id_pai_detalhe)_(\d+)$/.test(
            k
          )
        ) {
          sessionStorage.removeItem(k);
        }
      });

      const payload = {
        cd_parametro: 1,
        cd_form: localStorage.cd_form, //sessionStorage.getItem("cd_form"),
        cd_menu: Number(cd_menu),
        nm_tabela_origem: "",
        cd_usuario: Number(cd_usuario),
      };

      console.log("payload->", payload, banco);

      //const { data } = await axios.post("/api/payload-tabela", payload);

      //
      const { data } = await api.post("/payload-tabela", payload);
      //

      // { headers: { 'x-banco': banco } })

      //console.log('dados do retorno: ', data);
      //

      this.gridMeta = Array.isArray(data) ? data : [];

      this.cd_parametro_menu = this.gridMeta?.[0]?.cd_parametro_menu || 0;

      //console.log('grid: ', this.gridMeta, this.cd_parametro_menu  );

      // flag: quando cd_tabela > 0, consulta será direta na tabela
      this.cd_tabela = Number(this.gridMeta?.[0]?.cd_tabela) || 0;
      //

      // título da tela

      this.title =
        this.gridMeta?.[0]?.nm_titulo ||
        sessionStorage.getItem("menu_titulo") ||
        "Formulário";

      sessionStorage.setItem(
        "payload_padrao_formulario",
        JSON.stringify(this.gridMeta)
      );
      sessionStorage.setItem(
        `payload_padrao_formulario_${cd_menu}`,
        JSON.stringify(this.gridMeta)
      );
      sessionStorage.setItem("campos_grid_meta", JSON.stringify(this.gridMeta));
      sessionStorage.setItem(
        `campos_grid_meta_${cd_menu}`,
        JSON.stringify(this.gridMeta)
      );
      sessionStorage.setItem("menu_titulo", this.title);

      this.nome_procedure = this.gridMeta?.[0]?.nome_procedure || "*";
      this.ic_json_parametro = this.gridMeta?.[0]?.ic_json_parametro || "N";
      sessionStorage.setItem("tab_menu", this.gridMeta?.[0]?.tab_menu || "");

      // 1) MONTAR colunas e totalColumns (meta antigo)

      this.columns = this.gridMeta
        .filter((c) => c.ic_mostra_grid === "S")
        .sort((a, b) => (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0))
        .map((c) => ({
          dataField: c.nm_atributo || c.nm_atributo_consulta,
          caption: c.nm_titulo_menu_atributo || c.nm_atributo_consulta,
          format: c.formato_coluna || undefined,
          alignment: ["currency", "number", "percent", "fixedPoint"].includes(
            c.formato_coluna
          )
            ? "right"
            : "left",
          width: c.largura || undefined,
        }));

      // coluna de ações (editar / excluir)
      const colAcoes = {
        type: "buttons",
        caption: "Ações",
        width: 110,
        alignment: "center",
        allowSorting: false,
        allowFiltering: false,
        buttons: [
          {
            hint: "Editar",
            icon: "edit",
            onClick: (e) =>
              this.abrirFormEspecial({ modo: "A", registro: e.row.data }),
          },
          {
            hint: "Excluir",
            icon: "trash",
            onClick: (e) => {
              // idem: objeto PLANO
              const plain = JSON.parse(JSON.stringify(e.row.data));
              this.onExcluir(plain);
            },
          },
        ],
      };

      //summary e totalizadores

      //
      this.totalColumns = this.gridMeta
        .filter((c) => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
        .map((c) => ({
          dataField: c.nm_atributo || c.nm_atributo_consulta,
          type: c.ic_total_grid === "S" ? "sum" : "count",
          display: c.ic_total_grid === "S" ? "Total: {0}" : "{0} registro(s)",
        }));

      this.total = { totalItems: this.totalColumns };

      const mapa = {};

      this.gridMeta.forEach((c) => {
        if (c.nm_atributo && c.nm_atributo_consulta) {
          //mapa[c.nm_atributo] = c.nm_atributo_consulta;
          mapa[c.nm_atributo_consulta] = c.nm_atributo;
        }
      });

      sessionStorage.setItem("mapa_consulta_para_atributo", JSON.stringify(mapa));

     // console.log('mapa:', mapa);

      //this.total = { totalItems: this.totalColumns };

      // guarde o meta dos campos (usado na consulta e exportação)
      this.camposMetaGrid = this.gridMeta;
      //

      // 2) NORMALIZAR dados (datas → Date, números → Number, etc.)
      const normalizados = normalizarTipos(data, this.gridMeta);
      //console.log('normalizados:', normalizados);

      // 3) MONTAR colunas e summary
      this.gridColumns = buildColumnsFromMeta(this.gridMeta);
      this.gridSummary = buildSummaryFromMeta(this.gridMeta);

      // 4) ATUALIZAR estado
      this.gridRows = normalizados;
      //this.columns = this.gridColumns;
      this.total = this.gridSummary;
      
      // põe no início da lista de colunas
      this.columns = [colAcoes, ...this.gridColumns];
      //

      // 5) NUNCA popular dados aqui; zera!
      this.rows = [];
      this.gridRows = [];
      this.totalQuantidade = 0;
      this.totalValor = 0;
    },

    async loadFiltros(cd_menu, cd_usuario) {
      //console.log(banco);

      const { data } = await api.post(
        "/menu-filtro",
        {
          cd_menu: Number(cd_menu),
          cd_usuario: Number(cd_usuario),
        },
        { headers: { "x-banco": banco } }
      );

      this.filtros = Array.isArray(data) ? data : [];

      for (const f of this.filtros) {
        if (
          f.nm_valor_padrao != null &&
          this.filtrosValores[f.nm_atributo] == null
        ) {
          const tipo = this.resolvType(f); // <- novo
          const val =
            tipo === "date" // <- novo
              ? this.toYMD(f.nm_valor_padrao) // <- novo (aceita "dd/mm/aaaa" ou Date)
              : f.nm_valor_padrao;
          this.$set(this.filtrosValores, f.nm_atributo, val);
        }

        // -----------------------------------------------------

        if (f.ic_fixo_filtro === "S") {
          sessionStorage.setItem(`fixo_${f.nm_atributo}`, f.nm_valor_padrao);
          continue;
        }

        if (
          f.nm_valor_padrao != null &&
          this.filtrosValores[f.nm_atributo] == null
        ) {
          this.$set(this.filtrosValores, f.nm_atributo, f.nm_valor_padrao);
        }

        if (f.nm_lookup_tabela && f.nm_lookup_tabela.trim()) {
          try {
            //const resp = await api.post("/lookup", { query: f.nm_lookup_tabela });
            const resp = await api.postLookup(f.nm_lookup_tabela);

            const opts = Array.isArray(resp.data)
              ? resp.data.map((row) => ({
                  value: row[f.nm_atributo] ?? Object.values(row)[0],
                  label: row.Descricao || row.label || Object.values(row)[1],
                }))
              : [];
            this.$set(f, "_options", [
              { value: "", label: "Selecione..." },
              ...opts,
            ]);
          } catch (_) {
            this.$set(f, "_options", [
              { value: "", label: "Erro ao carregar" },
            ]);
          }
        }
      }

      const salvos = JSON.parse(
        sessionStorage.getItem("filtros_form_especial") || "{}"
      );
      Object.keys(salvos).forEach((k) =>
        this.$set(this.filtrosValores, k, salvos[k])
      );

      // se tiver filtro de data no form, preencha datas do mês atual
      this.$nextTick(() => this.preencherDatasDoMes());
      //
      console.log("filtros carregados:", this.filtros, this.filtrosValores);
      //
    },

    // função principal: monta payload e chama a procedure

    async consultar(payloadManual = null) {
      this.loading = true;

      //console.log('Iniciando consulta...', this.ic_json_parametro, this.nome_procedure);
      // monta payload e chama a procedure
      try {
        //const cd_menu = Number(sessionStorage.getItem("cd_menu"));
        const cd_usuario = Number(sessionStorage.getItem("cd_usuario"));
        const dt_inicial = sessionStorage.getItem("dt_inicial_padrao");
        const dt_final = sessionStorage.getItem("dt_final_padrao");
        const banco = localStorage.nm_banco_empresa || sessionStorage.getItem('banco') || '';
        const campos = {};

        Object.keys(sessionStorage)
          .filter((k) => k.startsWith("fixo_"))
          .forEach(
            (k) => (campos[k.replace("fixo_", "")] = sessionStorage.getItem(k))
          );
        Object.assign(campos, this.filtrosValores);

        const ic_filtro_obrigatorio = this.gridMeta?.[0]?.ic_filtro_obrigatorio;
        const filtroPreenchido = Object.values(campos).some(
          (v) => v != null && v !== "" && v !== 0
        );
        const cd_parametro = this.cd_parametro_menu || 0;
        const cd_menu =
          this.gridMeta?.[0]?.cd_menu ||
          Number(sessionStorage.getItem("cd_menu")) ||
          0;

        //console.log('parametro = ',payloadManual, cd_parametro);

        if (ic_filtro_obrigatorio === "S" && !filtroPreenchido) {
          //this.$q.notify({ type: "warning", message: "Atenção: Nenhum filtro preenchido para consulta." });
          this.notifyWarn("Atenção: Nenhum filtro preenchido para consulta.");
          return;
        }
                
        // monta payload conforme o que foi passado (manual ou automático)

        let dados = [];
        let payloadExec;

        //console.log('campos do form:', campos);

        // campos vem dinâmicos do seu form
        const camposNormalizados = normalizePayload(campos);

        //console.log('campos da consulta:', camposNormalizados);
        //console.log(campos);
        // se nome_procedure = "*", usa o endpoint /menu-pesquisa (payload padrão)
        console.log('nome_procedure:', this.nome_procedure);
        
        if (this.nome_procedure === "*" || this.nome_procedure === undefined) {
          //console.log('usando endpoint /menu-pesquisa');
          const payload = [
            {
              cd_parametro,
              cd_menu,
              cd_usuario,
              //dt_inicial, dt_final,
              //dt_inicial: clean(sessionStorage.getItem("dt_inicial_padrao")),
              //dt_final:   clean(sessionStorage.getItem("dt_final_padrao")),
              ...campos,
            },
          ];

          console.log('payload da consulta:', payload);
          
          const { data } = await api.post("/menu-pesquisa", payload);
          dados = data;
        } else {
          // senão, chama a procedure com o payload montado
          if (payloadManual && !(payloadManual instanceof Event)) {
            //payloadExec = JSON.stringify(payloadManual);
            payloadExec = payloadManual; // já é objeto/array
          } else {
            payloadExec =
              //this.ic_json_parametro === "S"
              //  ? JSON.stringify([{ ic_json_parametro: "S", ...campos }])
              //  : JSON.stringify({ ic_json_parametro: "N", ...campos });
              this.ic_json_parametro === "S"
                ? [
                    {
                      ic_json_parametro: "S",
                      ...camposNormalizados,
                      cd_parametro,
                    },
                  ]
                : { ic_json_parametro: "N", ...camposNormalizados };
          }

          //
          console.log('payload da consulta:', this.nome_procedure,payloadExec, banco);
          
          //
          // chama a procedure
          const { data } = await api.post(
            `/exec/${this.nome_procedure}`,
            payloadExec
          );
          //

          // ajusta nomes dos campos conforme o mapa (nm_atributo_consulta -> nm_atributo)

          const mapaOriginal = JSON.parse(
            sessionStorage.getItem("mapa_consulta_para_atributo") || "{}"
          );
          // inverte: técnico->consulta  ==> consulta->técnico
          const mapa = {};
          Object.keys(mapaOriginal).forEach((tec) => {
            mapa[mapaOriginal[tec]] = tec;
          });
          //
          dados = (data || []).map((item) => {
            const novo = {};
            Object.keys(item).forEach((k) => (novo[mapa[k] || k] = item[k]));
            return novo;
          });
        }
       
        this.rows = (dados || []).map((it, idx) => ({ id: it.id || idx + 1, ...it }));
        
        // 24.10.2025
        /*
        this.rows = (dados || []).map((it, idx) => {
        const ajustado = { id: it.id || idx + 1 };

  Object.entries(it).forEach(([key, value]) => {
    if (typeof value === 'string') {
      // ISO com "T"
      if (/^\d{4}-\d{2}-\d{2}T/.test(value)) {
        const [datePart] = value.split('T');
        const [yyyy, mm, dd] = datePart.split('-');
        ajustado[key] = `${dd}/${mm}/${yyyy}`;
        return;
      }

      // Formato com espaço
      if (/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/.test(value)) {
        const [datePart] = value.split(' ');
        const [yyyy, mm, dd] = datePart.split('-');
        ajustado[key] = `${dd}/${mm}/${yyyy}`;
        return;
      }
    }

    ajustado[key] = value;
  });

  return ajustado;
});
*/


        /*
        this.rows = (dados || []).map((it, idx) => {
        const ajustado = { id: it.id || idx + 1 };

  Object.entries(it).forEach(([key, value]) => {
    if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/.test(value)) {
      try {
        const [datePart] = value.split(' ');
        const [year, month, day] = datePart.split('-');
        ajustado[key] = `${day}/${month}/${year}`; // formato dd/mm/yyyy
      } catch (e) {
        ajustado[key] = value;
      }
    } else {
      ajustado[key] = value;
    }
  });
  console.log('ajustado', ajustado);

  return ajustado;
}); 
  */
      
          
        //
        sessionStorage.setItem(
          "dados_resultado_consulta",
          JSON.stringify(this.rows)
        );
        sessionStorage.setItem(
          "filtros_form_especial",
          JSON.stringify(this.filtrosValores)
        );

        console.log('mapa', dados);
        console.log('resultado', this.rows);
        

        // totais simples para o rodapé
        this.totalQuantidade = this.totalColumns.some((c) => c.type === "count")
          ? this.rows.length
          : 0;
        this.totalValor = this.totalColumns
          .filter((c) => c.type === "sum")
          .reduce(
            (acc, c) =>
              acc +
              this.rows.reduce((s, r) => s + Number(r[c.dataField] || 0), 0),
            0
          );

        //this.$q.notify({ type: "positive", message: `Consulta finalizada: ${this.rows.length} registros.`,
        //  position: 'top-right', timeout: 3000,
        //  action: [{ icon: 'close', color: 'white' }]

        //}
        //);

        this.notifyOk(`Consulta finalizada: ${this.rows.length} registro(s).`);

        this.panelIndex = 1; // mostra a grid

        this.$nextTick(() => {
          try {
            const inst =
              this.$refs && this.$refs.grid && this.$refs.grid.instance
                ? this.$refs.grid.instance
                : null;

          if (inst) {
          inst.beginUpdate();
          inst.option('dataSource', this.rows); // 2º: dataSource
          inst.option('focusedRowEnabled', true);
          inst.endUpdate();
          inst.refresh();
          }
          } catch (e) {
            console.warn("Não consegui aplicar keyExpr/dataSource:", e);
          }
        });

        //Total de Registros - Badge
        this.qt_registro = this.rows.length;
        //
      } catch (e) {
        console.error("Erro na consulta:", e);
        //this.$q.notify({ type: "negative", message: "Erro ao consultar dados." });
        this.notifyErr("Erro ao consultar dados !");
      } finally {
        this.loading = false;
      }
    },

    onRowDblClick(e) {
      const data = e.data;
      sessionStorage.setItem("registro_selecionado", JSON.stringify(data));
      const cd_menu = sessionStorage.getItem("cd_menu");
      sessionStorage.setItem(
        `registro_selecionado_${cd_menu}`,
        JSON.stringify(data)
      );

      if (this.isPesquisa && window.confirmarRetornoPesquisa) {
        window.confirmarRetornoPesquisa();
      }
    },
  },
};
</script>

<style scoped>
/* Seleção/linha focada laranja */
.dx-datagrid .dx-row-focused,
.dx-datagrid .dx-selection,
.dx-datagrid .dx-selection.dx-row > td {
  background-color: #ff7043 !important; /* laranja */
  color: #fff !important;
}

/* Cabeçalho mais forte e linha alternada suave */
.dx-datagrid .dx-header-row {
  background-color: #f6f6f6;
  font-weight: 600;
}
.dx-datagrid .dx-row-alt > td {
  background-color: #fafafa;
}
/* Espaço para não colidir com um footer fixo de ~56px */
.q-notifications__list--bottom,
.q-notifications__list--bottom-right,
.q-notifications__list--bottom-left {
  margin-bottom: 64px; /* ajuste conforme a altura do rodapé */
}
.dx-datagrid .dx-command-select {
  width: 36px; /* largura do checkbox */
}
/* dá respiro dentro do card */
.dx-card.wide-card.filtros-card {
  padding: 12px 16px 16px;
  border-radius: 8px;
}

/* Compacta o card de filtros */
.filtros-card {
  padding: 12px 14px; /* antes era maior */
  border-radius: 10px;
}

/* Reduz o espaço entre as colunas sem cortar o padding interno */
.filtros-wrap {
  /* controla o gutter real */
  margin-left: -6px;
  margin-right: -6px;
}

/* reativa gutters mesmo se algum reset tiver zerado .row */
.filtros-row {
  margin-left: -8px !important;
  margin-right: -8px !important;
}
.filtros-row > [class*="col-"] {
  padding-left: 8px !important;
  padding-right: 8px !important;
}

/* garante que q-input/q-select ocupem toda a coluna */
.full-w,
.full-w .q-field,
.full-w.q-input,
.full-w.q-select {
  width: 100%;
}

/* se algum CSS global removeu espaçamento vertical do q-field, repõe */
.filtros-row .q-field {
  margin-top: 4px;
  margin-bottom: 4px;
}

.row {
  margin: 0 !important;
}
.row > [class*="col-"] {
  padding: 0 !important;
}

/* aumenta a altura (min-height) dos campos e alinha os ícones lateral/append */
.filtro-item .q-field--filled .q-field__control,
.filtro-item .q-field--outlined .q-field__control {
  min-height: 56px; /* ajuste aqui: 48px, 56px, 64px... */
  padding-top: 10px; /* espaço pro label empilhado */
  padding-bottom: 6px;
}

.filtro-item .q-field__marginal {
  height: 56px; /* mantém os ícones com a mesma altura */
}

/* se quiser dar um respiro vertical entre linhas no mobile */
.filtro-item {
  /* ajusta respiro interno do campo */
  padding: 4px 2px;
  padding-left: 6px;
  padding-right: 6px;
  margin-bottom: 12px;
}

/* opcional: deixa o label um pouco mais forte/visível */
.filtro-item .q-field__label {
  font-weight: 600;
}

/* Ícones (prepend/append) menos “folgados” */
.filtro-item .q-field__prepend,
.filtro-item .q-field__append {
  padding-left: 6px;
  padding-right: 6px;
}

/* Linha do botão com pouco espaço acima */
.filtros-actions {
  margin-top: 8px;
  padding-left: 2px;
}

.filters-grid {
  display: grid;
  /*grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); */
  grid-template-columns: repeat(12, 1fr);
  grid-column-gap: 12px; /* horizontal gap menor */
  grid-row-gap: 10px; /* vertical gap menor */
}

.filter-grid > div {
  grid-column: span 12; /* default: 1 por linha no mobile */
}

/* cada filtro ocupa 4 colunas em desktop, 12 no mobile */
.filter-item {
  grid-column: span 12;
}

/* altura visual dos inputs “filled” do Quasar */
.q-field--filled .q-field__control {
  min-height: 64px; /* aumenta a “altura” do campo */
  padding-top: 8px;
  padding-bottom: 6px;
}

.dx-card.wide-card {
  padding: 12px 12px; /* sutil e consistente */
}

.espaco {
  padding-top: 200px;
  margin-top: 100px;
}

@media (min-width: 768px) {
  .filter-grid > div {
    grid-column: span 6; /* 2 por linha no tablet */
  }
}

@media (min-width: 1200px) {
  .filter-grid > div {
    grid-column: span 4; /* 3 por linha no desktop */
  }
}

.leitura-azul {
  background-color: #e7f1ff !important;
  color: #0d47a1;
}
/* pode ser global ou no <style scoped> do SFC */
.leitura-azul .q-field__control {
  background: #e7f1ff !important;
}
.leitura-azul .q-field__native,
.leitura-azul .q-field__label {
  color: #0d47a1 !important;
}

.viewport {
  overflow: hidden;
  width: 100%;
}
.track {
  display: flex;
  width: 200%;
  transition: transform 0.3s ease;
}
.pane {
  width: 50%;
  padding: 8px;
}

.hshell {
  width: 100%;
  overflow: hidden; /* oculta o painel fora de vista */
  position: relative;
  min-height: 320px; /* ajuste: garante altura para a grid */
}

.htrack {
  display: flex;
  width: 200%; /* 2 painéis de 100% cada */
  transition: transform 0.25s ease;
}

.hpanel {
  flex: 0 0 100%; /* cada painel ocupa 100% da largura da hshell */
  width: 100%;
  box-sizing: border-box;
  padding: 8px 8px 0;
}

.filtros-container {
  position: sticky;
  top: 0;
  z-index: 10;
  background: white;
  padding: 8px 0;
  border-bottom: 1px solid #ddd;
}

/* container da grid */
.grid-scroll-shell {
  overflow: auto;
  overflow-x: auto;
  overflow-y: hidden;
  white-space: nowrap;
  width: 100%;
  position: relative;
  padding: 10px;
}

/* track para garantir largura fluida */
.grid-scroll-track {
  position: relative;
  white-space: nowrap;
  display: inline-block;
  min-width: 100%;
}

.arrow-btn {
  position: fixed;
  top: 20%;
  margin-left: 5px;
  margin-right: 5px;
  transform: translateY(40%);
  z-index: 2000;
}

.arrow-btn.left {
  left: 60px;
}

.arrow-btn.right {
  right: 10px;
}

/* escopo local do componente */
.q-tabs__content {
  border-bottom: 2px solid var(--q-color-deep-orange-9);
  margin-bottom: 6px;
}

/* garante que o footer da DevExtreme apareça e não “cole” errado */
.dx-datagrid-total-footer,
.dx-datagrid-pager {
  position: sticky;
  bottom: 0;
  background: #fff;
  z-index: 2;
}

.fab-down {
  position: sticky; /* gruda no fim da área scrollável */
  bottom: 12px;
  float: right;
  margin-right: 12px;
  z-index: 5;
}

</style>

