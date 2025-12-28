<template>
  <div class="q-pa-md modulo-composicao">
    <div class="row items-center q-gutter-sm q-mb-md">
      <h2 class="content-block">{{ tituloPagina }}</h2>
      <q-space />
      <q-btn
        dense
        rounded
        color="deep-purple-7"
        icon="refresh"
        :loading="carregandoModulos"
        :disable="carregandoModulos"
        @click="carregarModulos"
      >
        <q-tooltip>Atualizar módulos</q-tooltip>
      </q-btn>
    </div>

    <div class="row q-col-gutter-md q-mb-md filtros-modulos">
      <div class="col-12 col-md-4">
        <q-input
          dense
          outlined
          v-model="filtroTexto"
          placeholder="Buscar módulo..."
          clearable
          debounce="200"
        />
      </div>

      <div class="col-12 col-md-4">
        <q-select
          dense
          outlined
          v-model="filtroCadeia"
          :options="opcoesCadeia"
          emit-value
          map-options
          label="Cadeia de Valor"
        />
      </div>
    </div>

    <div class="cards-wrapper q-mb-xl">
      <div
        v-for="modulo in modulosFiltrados"
        :key="modulo.cd_modulo"
        class="modulo-card cursor-pointer card-modulo"
        :class="{
          'modulo-card-selecionado':
            moduloSelecionado && moduloSelecionado.cd_modulo === modulo.cd_modulo,
        }"
        @click="selecionarModulo(modulo)"
      >
        <div class="modulo-card-body">
          <div class="logo-modulo">
            <span class="logo-letter">
              {{ (modulo.sg_modulo || modulo.nm_modulo || '').charAt(0) }}
            </span>
          </div>

          <div class="codigo-modulo">
            {{ modulo.cd_modulo }}
          </div>

          <div class="nome-modulo">
            {{ modulo.nm_modulo }}
          </div>

          <div class="descricao-modulo q-mt-xs">
            {{ modulo.ds_modulo }}
          </div>
        </div>

        <div class="cadeia-modulo">
          {{ modulo.nm_cadeia_valor }}
        </div>
      </div>
    </div>

    <div v-if="moduloSelecionado" class="q-mt-xl">
      <div class="row items-center q-mb-sm">
        <div class="text-h6">
          {{ `Composição de ${moduloSelecionado.nm_modulo || ''}` }}
        </div>
        <q-space />
        <q-btn
          dense
          rounded
          color="deep-purple-7"
          icon="refresh"
          :loading="carregandoComposicao"
          :disable="carregandoComposicao"
          @click="carregarComposicao"
        >
          <q-tooltip>Recarregar composição</q-tooltip>
        </q-btn>
      </div>

      <dx-data-grid
        v-if="!carregandoComposicao"
        class="dx-card wide-card"
        :data-source="composicaoComChave"
        :show-borders="true"
        :column-auto-width="true"
        :allow-column-reordering="true"
        :allow-column-resizing="true"
        :row-alternation-enabled="true"
        :word-wrap-enabled="true"
        key-expr="__rowKey"
        @exporting="onExporting"
      >
        <DxSelection mode="single" />
        <DxGrouping :auto-expand-all="false" />
        <DxGroupPanel :visible="true" empty-panel-text="Colunas para agrupar..." />
        <DxFilterRow :visible="true" />
        <DxHeaderFilter :visible="true" :allow-search="true" />
        <DxFilterPanel :visible="true" />
        <DxColumnChooser :enabled="true" mode="select" />
        <DxColumnFixing :enabled="true" />
        <DxSearchPanel :visible="true" :width="300" placeholder="Procurar..." />
        <DxPaging :page-size="15" />
        <DxPager :show-info="true" :show-page-size-selector="true" />
        <DxExport :enabled="true" />
        <DxStateStoring
          :enabled="true"
          type="localStorage"
          storage-key="grid_modulo_composicao"
        />
        <DxColumn
          v-for="coluna in colunasComposicao"
          :key="coluna.dataField"
          :data-field="coluna.dataField"
          :caption="coluna.caption"
          :data-type="coluna.dataType"
        />
      </dx-data-grid>

      <div v-else class="row justify-center q-my-lg">
        <q-spinner color="deep-purple-7" size="48px" />
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { DxDataGrid, DxColumn } from "devextreme-vue/data-grid";
import {
  DxColumnChooser,
  DxColumnFixing,
  DxExport,
  DxFilterPanel,
  DxFilterRow,
  DxGroupPanel,
  DxGrouping,
  DxHeaderFilter,
  DxPager,
  DxPaging,
  DxSearchPanel,
  DxSelection,
  DxStateStoring,
} from "devextreme-vue/data-grid";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import notify from "devextreme/ui/notify";
import Menu from "../http/menu";
import Procedimento from "../http/procedimento";

const api = axios.create({
  baseURL: "https://egiserp.com.br/api",
  withCredentials: true,
  timeout: 60000,
});

api.interceptors.request.use((cfg) => {
  const banco = localStorage.nm_banco_empresa || "";
  if (banco) cfg.headers["x-banco"] = banco;
  cfg.headers["Authorization"] = "Bearer superchave123";
  if (!cfg.headers["Content-Type"]) cfg.headers["Content-Type"] = "application/json";
  return cfg;
});

export default {
  name: "moduloComposicao",
  components: {
    DxDataGrid,
    DxColumn,
    DxSelection,
    DxGrouping,
    DxGroupPanel,
    DxFilterRow,
    DxHeaderFilter,
    DxFilterPanel,
    DxColumnChooser,
    DxColumnFixing,
    DxExport,
    DxPaging,
    DxPager,
    DxSearchPanel,
    DxStateStoring,
  },
  data() {
    return {
      tituloMenu: "",
      modulos: [],
      composicao: [],
      moduloSelecionado: null,
      filtroTexto: "",
      filtroCadeia: "TODAS",
      carregandoModulos: false,
      carregandoComposicao: false,
      cd_empresa: Number(localStorage.cd_empresa || 0),
      cd_menu: Number(localStorage.cd_menu || 0),
      cd_api: Number(localStorage.cd_api || 0),
      cd_cliente: Number(localStorage.cd_cliente || 0),
      headerBanco: localStorage.nm_banco_empresa || "",
    };
  },
  computed: {
    tituloPagina() {
      if (this.tituloMenu) return this.tituloMenu;
      return "Composição do Módulo";
    },
    opcoesCadeia() {
      const lista = Array.isArray(this.modulos) ? this.modulos : [];
      const unicas = Array.from(
        new Set(
          lista
            .map((m) => (m.nm_cadeia_valor || "").trim())
            .filter(Boolean),
        ),
      ).sort((a, b) => a.localeCompare(b));

      return [
        { label: "Todas Cadeias", value: "TODAS" },
        ...unicas.map((x) => ({ label: x, value: x })),
      ];
    },
    modulosFiltrados() {
      const lista = Array.isArray(this.modulos) ? this.modulos : [];

      const texto = (this.filtroTexto || "").toLowerCase().trim();
      const cadeia = (this.filtroCadeia || "TODAS").toLowerCase();

      return lista.filter((m) => {
        const nome = (m.nm_modulo || "").toLowerCase();
        const sigla = (m.sg_modulo || "").toLowerCase();
        const cadeiaModulo = (m.nm_cadeia_valor || "").toLowerCase();

        const okTexto = !texto || nome.includes(texto) || sigla.includes(texto);
        const okCadeia = cadeia === "todas" || cadeiaModulo === cadeia;

        return okTexto && okCadeia;
      });
    },
    composicaoComChave() {
      return (this.composicao || []).map((row, idx) => ({
        __rowKey:
          row.cd_controle ||
          row.id ||
          row.cd_item ||
          row.cd_modulo ||
          `${idx}`,
        ...row,
      }));
    },
    colunasComposicao() {
      const rows = this.composicaoComChave;
      if (!rows.length) return [];

      const sample = rows[0];
      return Object.keys(sample)
        .filter((k) => k !== "__rowKey")
        .map((key) => ({
          dataField: key,
          caption: this.tituloColuna(key),
          dataType: this.detectaTipo(sample[key]),
        }));
    },
  },
  async created() {
    await this.carregarModulos();
  },
  methods: {
    tituloColuna(chave) {
      if (!chave) return "";
      return chave
        .replace(/_/g, " ")
        .replace(/\s+/g, " ")
        .trim()
        .replace(/\b\w/g, (l) => l.toUpperCase());
    },
    detectaTipo(valor) {
      if (typeof valor === "number") return "number";
      if (valor instanceof Date) return "date";
      return undefined;
    },
    async carregarModulos() {
      this.carregandoModulos = true;
      try {
        const dadosMenu = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api);
        const sParametroApi = dadosMenu.nm_api_parametro;

        this.tituloMenu = dadosMenu.nm_menu_titulo;

        const apiModulo = dadosMenu.nm_identificacao_api || localStorage.nm_identificacao_api;
        const modulos = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          apiModulo,
          sParametroApi,
        );

        this.modulos = Array.isArray(modulos) ? modulos : [];
      } catch (e) {
        console.error("[moduloComposicao] erro ao carregar módulos:", e);
        notify("Erro ao carregar os módulos. Tente novamente.");
        this.modulos = [];
      } finally {
        this.carregandoModulos = false;
      }
    },
    selecionarModulo(modulo) {
      this.moduloSelecionado = modulo;
      localStorage.cd_modulo = modulo.cd_modulo;
      localStorage.nm_modulo = modulo.nm_modulo;
      this.carregarComposicao();
    },
    async carregarComposicao() {
      if (!this.moduloSelecionado) return;

      this.carregandoComposicao = true;
      try {
        const body = [
          {
            ic_json_parametro: "S",
            cd_parametro: 100,
            cd_modulo: this.moduloSelecionado.cd_modulo,
            cd_usuario: Number(localStorage.cd_usuario || 0),
            cd_empresa: this.cd_empresa,
          },
        ];

        const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;

        const resp = await api.post("/exec/pr_egis_admin_processo_modulo", body, cfg);

        let rows = resp && resp.data ? resp.data : [];
        if (rows && rows.dados) rows = rows.dados;
        if (!Array.isArray(rows)) rows = rows ? [rows] : [];

        this.composicao = rows;
      } catch (e) {
        console.error("[moduloComposicao] erro ao carregar composição:", e);
        notify("Não foi possível carregar a composição do módulo.");
        this.composicao = [];
      } finally {
        this.carregandoComposicao = false;
      }
    },
    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Composicao");

      exportDataGrid({
        component: e.component,
        worksheet,
        autoFilterEnabled: true,
      }).then(() => {
        workbook.xlsx.writeBuffer().then((buffer) => {
          saveAs(
            new Blob([buffer], { type: "application/octet-stream" }),
            `${this.tituloPagina}.xlsx`,
          );
        });
      });

      e.cancel = true;
    },
  },
};
</script>

<style scoped>
@import url("./views.css");

.cards-wrapper {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  grid-auto-rows: 1fr;
  gap: 10px;
  margin-right: 10px;
}

.modulo-card {
  background: #ffffff;
  border-radius: 24px;
  padding: 24px 32px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.16);
  color: #512da8;
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 100%;
  box-sizing: border-box;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.modulo-card:hover,
.modulo-card-selecionado {
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.25);
  transform: translateY(-2px);
}

.codigo-modulo {
  font-weight: 700;
  font-size: 18px;
  margin-bottom: 12px;
  color: #e65100;
}

.nome-modulo {
  font-weight: 700;
  font-size: 16px;
  text-align: center;
  margin-bottom: 6px;
  color: #512da8;
}

.descricao-modulo {
  text-align: center;
  font-size: 13px;
  line-height: 1.4;
  color: #555;
}

.logo-modulo {
  background: #512da8;
  color: white;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  margin-bottom: 10px;
}

.logo-letter {
  font-size: 32px;
  line-height: 1;
  font-weight: 800;
  color: #fff;
  text-transform: uppercase;
}

.modulo-card-body {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.cadeia-modulo {
  margin-top: 16px;
  font-weight: 600;
  font-size: 13px;
  text-align: center;
  color: #333;
}

.filtros-modulos {
  max-width: 1100px;
}

.card-modulo {
  border-radius: 18px;
}
</style>
