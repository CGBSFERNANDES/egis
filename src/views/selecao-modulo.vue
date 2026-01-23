<template>
  <div>
    <div class="row items-center q-mb-md">
      <h2 class="content-block">{{ tituloMenu }}</h2>

      <q-btn
        round
        color="primary"
        icon="dashboard"
        size="sm"
        @click.stop="toggleDashboard"
        :loading="loadDashBoard"
        :disable="loadDashBoard"
      >
        <q-tooltip> Dashboard </q-tooltip>
      </q-btn>

      <!-- TOGGLE: GRID x CARDS -->
      <q-toggle
        v-model="exibirComoCards"
        color="deep-purple-7"
        checked-icon="view_module"
        unchecked-icon="view_list"
        :label="exibirComoCards ? 'grid' : 'cards'"
        keep-color
      />

      <!-- contador vem DEPOIS -->
      <div class="q-ml-md text-grey-6">
        {{ qtdFiltrados }} de {{ qtdTotal }} módulos liberados
      </div>
    </div>

    <div v-if="dashBoard">
      <dx-data-grid
        v-if="!exibirComoCards"
        class="dx-card wide-card"
        :data-source="dataSourceConfig"
        :columns="columns"
        :summary="total"
        key-expr="cd_controle"
        :show-borders="true"
        :focused-row-enabled="true"
        :column-auto-width="true"
        :column-hiding-enabled="false"
        :remote-operations="false"
        :word-wrap-enabled="false"
        :allow-column-reordering="true"
        :allow-column-resizing="true"
        :row-alternation-enabled="true"
        :repaint-changes-only="true"
        :autoNavigateToFocusedRow="true"
        :focused-row-index="0"
        :cacheEnable="false"
        @row-dbl-click="onClickAprovar($event)"
        @exporting="onExporting"
        @initialized="saveGridInstance"
        @focused-row-changed="onFocusedRowChanged"
      >
        <DxGroupPanel
          :visible="true"
          empty-panel-text="Colunas para agrupar..."
        />

        <DxGrouping :auto-expand-all="true" />
        <DxExport :enabled="true" />

        <DxPaging :enable="true" :page-size="10" />

        <DxStateStoring
          :enabled="false"
          type="localStorage"
          storage-key="storage"
        />
        <DxSelection mode="single" />
        <DxPager
          :show-page-size-selector="true"
          :allowed-page-sizes="[10, 20, 50, 100]"
          :show-info="true"
        />
        <DxFilterRow :visible="false" />
        <DxHeaderFilter :visible="true" :allow-search="true" />
        <DxSearchPanel
          :visible="temPanel"
          :width="300"
          placeholder="Procurar..."
        />
        <DxFilterPanel :visible="true" />
        <DxColumnFixing :enabled="true" />
        <DxColumnChooser :enabled="true" mode="select" />
      </dx-data-grid>
      <!-- CARDS DOS MÓDULOS -->
      <div v-else class="q-mt-lg q-ml-lg">
        <div class="q-mb-md filtros-modulos">
          <div class="row q-col-gutter-md q-mt-sm items-center">
            <div class="col-12 col-md-4">
              <q-input
                dense
                outlined
                v-model="filtroTexto"
                placeholder="Buscar módulo..."
                clearable
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
        </div>

        <div class="cards-wrapper">
          <div
            v-for="modulo in modulosFiltrados"
            :key="modulo.cd_modulo"
            class="modulo-card cursor-pointer card-modulo"
            @click="selecionarModulo(modulo)"
          >
            <div class="modulo-card-body">
              <div class="logo-modulo">
                <span class="logo-letter">
                  {{ (modulo.sg_modulo || modulo.nm_modulo || "").charAt(0) }}
                </span>
              </div>

              <!-- código do módulo -->
              <div class="codigo-modulo">
                {{ modulo.cd_modulo }}
              </div>

              <!-- nome do módulo -->
              <div class="nome-modulo">
                {{ modulo.nm_modulo }}
              </div>

              <!-- descrição / observação / qualquer texto extra que você tiver -->
              <div class="descricao-modulo q-mt-xs">
                {{ modulo.ds_modulo }}<br />
              </div>
            </div>
            <!-- LINHA FIXA NO RODAPÉ DO CARD -->
            <div class="cadeia-modulo">
              {{ modulo.nm_cadeia_valor }}
            </div>
          </div>
        </div>
      </div>

      <div class="row items-center">
        <q-btn
          color="positive"
          icon="check"
          rounded
          class="margin1"
          label="Acessar"
          @click="onClickAprovar($event)"
        />
        <q-btn
          color="negative"
          icon="close"
          class="margin1"
          rounded
          flat
          label="Cancelar"
          @click="onClickDeclinar($event)"
        />
      </div>

      <div class="margin1" v-if="!!taskDetails.trim() == true">
        <q-bar class="bg-orange-9 text-white text-bold borda">Descritivo</q-bar>
        <p class="margin1 text-justify" id="taskDetails" v-html="taskDetails" />
      </div>
    </div>
    <div class="row items-center" v-else>
      <div v-for="(i, index) in dashBoardConfig" :key="index">
        <DxPieChart
          class="telaInteira"
          id="pie"
          v-show="dashBoardConfig[index][0].Cod != 0"
          :data-source="dashBoardConfig[index]"
          resolve-label-overlapping="shift"
          palette="Material"
          material="material.orange.light"
          :title="dataSourceConfig[index].nm_modulo"
        >
          <DxSeries argument-field="nm_etapa" value-field="vl_etapa">
            <DxAnimation
              easing="linear"
              :duration="500"
              :max-point-count-supported="100"
            />
            <DxLabel
              :visible="true"
              :customize-text="formatLabel"
              :format="{ style: 'currency', currency: 'BRL' }"
            >
              <DxConnector :visible="true" :width="1" />
            </DxLabel>
          </DxSeries>
          <DxLegend horizontal-alignment="center" vertical-alignment="bottom" />
          <DxExport :enabled="true" />
        </DxPieChart>
      </div>
    </div>
  </div>
</template>

<script>
import Incluir from "../http/incluir_registro";
import { DxAnimation } from "devextreme-vue/pie-chart";
import DxPieChart, {
  DxSeries,
  DxLabel,
  DxConnector,
  DxLegend,
} from "devextreme-vue/pie-chart";

import {
  DxDataGrid,
  DxFilterRow,
  DxPager,
  DxPaging,
  DxExport,
  DxGroupPanel,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxSelection,
  DxStateStoring,
  DxSearchPanel,
} from "devextreme-vue/data-grid";

import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import notify from "devextreme/ui/notify";
import validaLogin from "../http/validaLogin";

var cd_cliente = 0;
var api = "";

var filename = "DataGrid.xlsx";
var dados = [];

export default {
  data() {
    return {
      filtroTexto: "",
      filtroCadeia: "Todas",
      tituloMenu: "",
      columns: [],
      isReady: false,
      dataSourceConfig: [],
      total: {},
      dataGridInstance: null,
      taskDetails: "",
      dashBoardConfig: [],
      temPanel: false,
      cd_empresa: localStorage.cd_empresa,
      cd_modulo: localStorage.cd_modulo,
      cd_api: localStorage.cd_api,
      cd_menu: localStorage.cd_menu,
      cd_usuario: localStorage.cd_usuario,
      loadDashBoard: false,
      cd_cliente: localStorage.cd_cliente,
      modulosDisponiveis: [],
      linha: {},
      dashBoard: true,
      exibirComoCards: true,
    };
  },

  created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    // locale('pt-BR');
  },

  async mounted() {
    this.carregaDados();
  },

  components: {
    DxPieChart,
    DxSeries,
    DxLabel,
    DxConnector,
    DxLegend,
    DxExport,
    DxDataGrid,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxGroupPanel,
    DxAnimation,
    DxGrouping,
    DxColumnChooser,
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxSelection,
    DxStateStoring,
    DxSearchPanel,
  },

  computed: {
    qtdFiltrados() {
      return this.modulosFiltrados.length;
    },

    qtdLiberados() {
      return Array.isArray(this.dataSourceConfig)
        ? this.dataSourceConfig.length
        : 0;
    },

    qtdTotal() {
      return Array.isArray(this.dataSourceConfig)
        ? this.dataSourceConfig.length
        : 0;
    },

    opcoesCadeia() {
      const lista = Array.isArray(this.dataSourceConfig)
        ? this.dataSourceConfig
        : [];
      const unicas = Array.from(
        new Set(
          lista.map(m => (m.nm_cadeia_valor || "").trim()).filter(Boolean)
        )
      ).sort((a, b) => a.localeCompare(b));

      return [
        { label: "Todas Cadeias", value: "TODAS" },
        ...unicas.map(x => ({ label: x, value: x })),
      ];
    },

    modulosFiltrados() {
      const lista = Array.isArray(this.dataSourceConfig)
        ? this.dataSourceConfig
        : [];

      const texto = (this.filtroTexto || "").toLowerCase().trim();
      const cadeia = (this.filtroCadeia || "TODAS").toLowerCase();

      return lista.filter(m => {
        const nome = (m.nm_modulo || "").toLowerCase();
        const sigla = (m.sg_modulo || "").toLowerCase();
        const cadeiaModulo = (m.nm_cadeia_valor || "").toLowerCase();

        const okTexto = !texto || nome.includes(texto) || sigla.includes(texto);

        const okCadeia = cadeia === "todas" || cadeiaModulo === cadeia;

        return okTexto && okCadeia;
      });
    },
  },

  methods: {
    async toggleDashboard() {
      // se está carregando, não faz nada
      if (this.loadDashBoard) return;

      // abriu o painel?
      this.dashBoard = !this.dashBoard;
      //

      // só carrega quando abrir e ainda não tem config
      if (
        this.dashBoard &&
        (!this.dashBoardConfig || this.dashBoardConfig.length === 0)
      ) {
        await this.carregaDados();
      }
    },

    formatLabel(pointInfo) {
      return `${pointInfo.argumentText}: ${pointInfo.valueText}`;
    },

    onFocusedRowChanged: function(e) {
      var data = e.row && e.row.data;
      this.linha = data;
      this.taskDetails = data && data.ds_informativo;

      localStorage.cd_modulo_selecao = data && data.cd_modulo;
      localStorage.nm_modulo_selecao = data && data.nm_modulo;
    },

    async carregaDados() {
      this.temPanel = true;
      this.loadDashBoard = true;
      try {
        cd_cliente = localStorage.cd_cliente;
        api = localStorage.nm_identificacao_api;
        dados = await Menu.montarMenu(
          this.cd_empresa,
          this.cd_menu,
          this.cd_api
        ); //'titulo';

        let sParametroApi = dados.nm_api_parametro;
        localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

        this.tituloMenu = dados.nm_menu_titulo;

        this.dataSourceConfig = await Procedimento.montarProcedimento(
          this.cd_empresa,
          cd_cliente,
          api,
          sParametroApi
        );

        filename = this.tituloMenu + ".xlsx";
        this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
        this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));

        // 🔥 reset antes de preencher
        this.dashBoardConfig = [];
        //

        // ⚡️ carrega em paralelo (bem mais rápido e reduz chance de “parecer travado”)
        const promessas = (this.dataSourceConfig || []).map(async m => {
          const json = {
            cd_parametro: 0,
            cd_modulo: m.cd_controle,
            dt_inicial: localStorage.dt_inicial,
            dt_final: localStorage.dt_final,
            cd_usuario: this.cd_usuario,
          };

          const busca = await Incluir.incluirRegistro("803/1265", json);
          return busca && busca.length > 0 ? busca : null;
        });

        const resultados = await Promise.allSettled(promessas);

        this.dashBoardConfig = resultados
          .filter(r => r.status === "fulfilled" && r.value)
          .map(r => r.value);
      } catch (error) {
        console.error("carregaDados erro:", error);
      } finally {
        // ✅ GARANTIA ABSOLUTA: spinner sempre para
        this.loadDashBoard = false;
      }
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    selecionarModulo(modulo) {
      this.linha = modulo;
      this.onClickAprovar();
    },

    async onClickAprovar() {
      notify("Aguarde... vamos acessar o módulo para você !");

      localStorage.cd_modulo = this.linha.cd_modulo;
      localStorage.nm_modulo = this.linha.nm_modulo;

      localStorage.cd_modulo_selecao = 0;
      localStorage.cd_menu = 0;

      //Atualização do Módulo
      localStorage.cd_cliente = 0;
      localStorage.cd_parametro = 0;

      api = "";
      dados = await Menu.montarMenu(this.cd_empresa, 0, 99); //'titulo'; Procedimento 938 -- pr_atualiza_modulo_acesso_usuario_empresa

      api = dados.nm_identificacao_api;

      let sParametroApi = dados.nm_api_parametro;

      //console.log(api)

      dados = await Procedimento.montarProcedimento(
        this.cd_empresa,
        cd_cliente,
        api,
        sParametroApi
      );

      //console.log('Selecao de Módulo --> ', dados)
      localStorage.cd_modulo = dados[0].cd_modulo;
      localStorage.nm_modulo = dados[0].nm_modulo;
      localStorage.cd_api = dados[0].cd_api;
      localStorage.nm_identificacao_api = dados[0].nm_identificacao_api;

      //localStorage.cd_menu = dados[0].cd_menu;

      var dados_u;

      dados_u = await validaLogin.validar({
        nm_fantasia_usuario: localStorage.login,
        cd_senha_usuario: localStorage.password,
      });

      localStorage.cd_home = dados_u.cd_api;

      this.$store._mutations.SET_Usuario = dados_u[0];

      this.$router.push({ name: "home" });
    },

    onClickDeclinar() {
      notify(`Aguarde...`);

      this.$router.push({ name: "home" });
    },

    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Employees");

      exportDataGrid({
        component: e.component,
        worksheet: worksheet,
        autoFilterEnabled: true,
      }).then(function() {
        // https://github.com/exceljs/exceljs#writing-xlsx
        workbook.xlsx.writeBuffer().then(function(buffer) {
          saveAs(
            new Blob([buffer], { type: "application/octet-stream" }),
            filename
          );
        });
      });

      e.cancel = true;
    },

    destroyed() {
      this.$destroy();
    },
  },
};
</script>
<style>
@import url("./views.css");

#taskDetails {
  font-size: 16px;
}

.cards-wrapper {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  grid-auto-rows: 1fr;
  gap: 10px; /* espaçamento entre cards */
  margin-right: 10px; /* espacinho na direita, igual empresas */
}

/* card do módulo */
.modulo-card {
  background: #ffffff; /* fundo branco */
  border-radius: 24px;
  padding: 24px 32px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.16);
  color: #512da8; /* deep-purple-7 */
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 100%; /* mesma altura por linha */
  box-sizing: border-box;
}

.modulo-card:hover {
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.25);
  transform: translateY(-2px);
  transition: all 0.15s ease;
}

/* código do módulo (em cima, laranja) */
.codigo-modulo {
  font-weight: 700;
  font-size: 18px;
  margin-bottom: 12px;
  color: #e65100; /* deep-orange-9 */
}

/* nome do módulo */
.nome-modulo {
  font-weight: 700;
  font-size: 16px;
  text-align: center;
  margin-bottom: 6px;
  color: #512da8; /* deep-purple-7 */
}

/* descrição do módulo */
.descricao-modulo {
  text-align: center;
  font-size: 13px;
  line-height: 1.4;
  color: #555;
}

.logo-modulo {
  background: #512da8; /* deep-purple-7 */

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

/* parte de cima do card (tudo menos nm_cadeia_valor) */
.modulo-card-body {
  flex: 1; /* ocupa o espaço variável */
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

/* nm_cadeia_valor sempre como última linha centralizada */
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
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card-modulo:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.18);
}
</style>
