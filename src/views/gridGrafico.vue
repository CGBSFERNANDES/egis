<template>
  <div style="display: inline">
    <div class="row">
      <div class="col">
        <transition name="slide-fade">
          <q-card
            class="my-card"
            v-if="cd_dado_painel == 5 && tituloCard.length > 0"
          >
            <q-card-section class="card-titulo">
              {{ tituloPainel }}
              <q-linear-progress
                size="2px"
                :value="0.5"
                rounded
                color="grey-9"
              />
            </q-card-section>
            <q-separator />
            <q-card-section v-for="n in tituloCard" v-bind:key="n">
              <label class="label_cima">
                {{ n.card }}
                <p class="text-h5 text-center">
                  {{ dataSourceConfig[0][n.campo] }}
                </p>
              </label>
            </q-card-section>
          </q-card>
        </transition>
      </div>
    </div>
    <div
      v-if="
        (cd_dado_painel == 2 || cd_dado_painel == 3) && cd_tipo_grafico == 3
      "
    >
      <transition name="slide-fade">
        <DxChart
          v-if="dataSourceConfig.length > 0"
          id="chart-demo"
          :data-source="dataSourceConfig"
          palette="Harmony Light"
          class="margin1"
          :title="tituloGrafico"
        >
          <DxCommonSeriesSettings :type="type" :argument-field="'dt_grafico'" />
          <DxSeries value-field="vl_total" name="Total Líquido" />
          <DxMargin :bottom="20" />
          <DxArgumentAxis :value-margins-enabled="false" />
          <DxLegend vertical-alignment="bottom" horizontal-alignment="center" />
          <DxExport :enabled="true" />
          <DxTooltip
            :enabled="true"
            :customize-tooltip="customizeTooltip"
            location="edge"
          />
        </DxChart>
      </transition>

      <div
        id="chart"
        v-if="
          (cd_dado_painel == 2 || cd_dado_painel == 3) && cd_tipo_grafico == 2
        "
      >
        <transition name="slide-fade">
          <DxChart
            v-if="dataSourceConfig.length > 0"
            :data-source="dataSourceConfig"
            palette="Violet"
            :title="tituloGrafico"
          >
            <DxSeriesTemplate
              :customize-series="customizeSeries"
              name-field="cd_ano"
            />
            <DxCommonSeriesSettings
              argument-field="nm_mes"
              value-field="vl_total"
              type="bar"
            />
            <DxTitle :text="tituloGrafico">
              <DxSubtitle text="(R$)" />
            </DxTitle>
            <DxLegend
              vertical-alignment="bottom"
              horizontal-alignment="center"
            />
            <DxExport :enabled="true" />
          </DxChart>
        </transition>
      </div>
    </div>

    <div
      v-if="
        (cd_dado_painel == 2 || cd_dado_painel == 3) && cd_tipo_grafico == 1
      "
    >
      <transition name="slide-fade">
        <DxPieChart
          class="pie"
          v-if="dataSourceConfig.length > 0"
          :data-source="dataSourceConfig"
          palette="Soft Pastel"
          :title="tituloGrafico"
          @point-click="pointClickHandler($event)"
          @legend-click="legendClickHandler($event)"
        >
          <DxAdaptiveLayout :height="300" :width="400" keepLabels="false" />
          <DxSeries
            argument-field="nm_dado_grafico"
            value-field="vl_dado_grafico"
          >
            <DxLabel
              :visible="true"
              :customize-text="formatLabelPie"
              position="columns"
            >
              <DxConnector :visible="true" :width="0.5" />
              <DxFont :size="16" />
            </DxLabel>
          </DxSeries>
          <DxExport :enabled="true" />
        </DxPieChart>
      </transition>
    </div>

    <div
      v-if="
        (cd_dado_painel == 2 || cd_dado_painel == 3) && cd_tipo_grafico == 6
      "
    >
      <DxFunnel
        id="funnel"
        v-if="dataSourceConfig.length > 0"
        :data-source="dataSourceConfig"
        palette="Soft Pastel"
        argument-field="nm_etapa"
        value-field="qt_movimento"
      >
        <DxTitle :text="tituloGrafico">
          <DxMargin :bottom="30" />
        </DxTitle>
        <DxExport :enabled="true" />
        <DxTooltip :enabled="true" format="fixedPoint" />
        <DxItem>
          <DxBorder :visible="true" />
        </DxItem>
        <DxLabel
          :visible="true"
          :customize-text="formatLabel"
          position="inside"
          background-color="none"
        />
      </DxFunnel>
    </div>

    <div
      v-if="
        (cd_dado_painel == 2 || cd_dado_painel == 3) && cd_tipo_grafico == 7
      "
    >
      <div class="long-title">
        <h3>Resultado do C-VAT Sales</h3>
      </div>
      <div id="chart-demo">
        <DxPolarChart
          v-if="dataSourceConfig.length > 0"
          id="radarChart"
          :data-source="dataSourceConfig"
        >
          <DxCommonSeriesSettings type="area" />
          <DxSeries
            value-field="qt_resultado"
            name="Resultado"
            color="#ba4d51"
          />
          <DxMargin :top="50" :bottom="50" :left="100" />
        </DxPolarChart>
      </div>
    </div>

    <dx-data-grid
      v-if="cd_dado_painel == 1 || cd_dado_painel == 3"
      id="grid-padrao"
      class="dx-card wide-card-g1 margin1"
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
      @focused-row-changed="onFocusedRowChanged"
    >
      <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

      <DxGrouping :auto-expand-all="true" />
      <DxExport :enabled="true" />

      <DxPaging :enable="true" :page-size="10" />

      <DxStateStoring
        :enabled="true"
        type="localStorage"
        storage-key="storage"
      />
      <DxSelection mode="single" />
      <DxPager
        :show-page-size-selector="true"
        :allowed-page-sizes="pageSizes"
        :show-info="true"
      />
      <DxFilterRow :visible="false" />
      <DxHeaderFilter :visible="true" :allow-search="true" />
      <DxSearchPanel :visible="true" :width="300" placeholder="Procurar..." />
      <DxFilterPanel :visible="true" />
      <DxColumnFixing :enabled="false" />
      <DxColumnChooser :enabled="true" mode="select" />
    </dx-data-grid>
  </div>
</template>

<script>
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

import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import Incluir from "../http/incluir_registro";

import {
  DxChart,
  DxSeries,
  DxSeriesTemplate,
  DxTitle,
  DxSubtitle,
  DxArgumentAxis,
  DxCommonSeriesSettings,
  DxLegend,
  DxMargin,
  DxTooltip,
  DxAdaptiveLayout,
} from "devextreme-vue/chart";

import { DxPolarChart } from "devextreme-vue/polar-chart";

import DxFunnel, { DxItem, DxBorder, DxLabel } from "devextreme-vue/funnel";

import DxPieChart, { DxConnector, DxFont } from "devextreme-vue/pie-chart";

let dados = [];
let sParametroApi = "";

var data_selecionada = {};

export default {
  props: {
    cd_menuID: { type: Number, default: 0 },
    cd_apiID: { type: Number, default: 0 },
    cd_identificacaoID: { type: Number, default: 0 },
    cd_parametroID: { type: Number, default: 0 },
    cd_dado_painelID: { type: Number, default: 0 },
    nm_tituloID: { type: String, default: "" },
    nm_graficoID: { type: String, default: "" },
    cd_tipo_graficoID: { type: Number, default: 0 },
    cd_usuarioID: { type: Number, default: 0 },
    cd_consulta: { type: Number, default: 0 },
  },

  Selecionada() {
    return data_selecionada;
    //data_selecionada = {};
  },

  data() {
    const types = ["area", "stackedarea", "fullstackedarea"];
    return {
      tituloMenu: "",
      tituloPainel: "",
      tituloGrafico: "",
      dt_inicial: "",
      dt_final: "",
      columns: [],
      pageSizes: [10, 20, 50, 100],
      total: {},
      dataSourceConfig: [],
      dataSourceConfigG: [],
      cd_empresa: 0,
      cd_menu: 0,
      cd_cliente: 0,
      cd_api: 0,
      cd_dado_painel: 0,
      api: 0,
      types,
      type: types[0],
      tituloCard: [],
      cd_tipo_grafico: 0,
      currentType: types[0],
    };
  },

  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    this.carregaDados();
  },

  async mounted() {
    //this.carregaDados();
  },

  async beforeupdate() {
    //this.carregaDados();
  },

  components: {
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
    DxChart,
    DxSeries,
    DxArgumentAxis,
    DxCommonSeriesSettings,
    DxLegend,
    DxMargin,
    DxTooltip,
    DxSeriesTemplate,
    DxTitle,
    DxSubtitle,
    DxFunnel,
    DxItem,
    DxBorder,
    DxLabel,
    DxPieChart,
    DxConnector,
    DxFont,
    DxAdaptiveLayout,
    DxPolarChart,
  },

  methods: {
    pointClickHandler(e) {
      this.toggleVisibility(e.target);
    },
    legendClickHandler(e) {
      let arg = e.target,
        item = e.component.getAllSeries()[0].getPointsByArg(arg)[0];

      this.toggleVisibility(item);
    },
    toggleVisibility(item) {
      item.isVisible() ? item.hide() : item.show();
    },

    formatLabelPie(pointInfo) {
      return `${pointInfo.valueText} (${pointInfo.percentText})`;
    },

    formatLabel(arg) {
      return `<span class="label">${arg.percentText}</span><br/>${arg.item.argument}`;
    },

    customizeSeries(seriesName) {
      return seriesName === 2021
        ? { type: "line", label: { visible: true }, color: "#ff3f7a" }
        : {};
    },
    customizeTooltip(pointInfo) {
      return {
        text: `${pointInfo.seriesName} : ${pointInfo.valueText}`,
      };
    },

    async showMenu() {
      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_menu = this.cd_menuID;
      this.cd_api = this.cd_apiID;
      this.api = "";
      this.cd_dado_painel = this.cd_dado_painelID;
      this.tituloPainel = this.nm_tituloID;
      this.tituloGrafico = this.nm_graficoID;
      this.cd_tipo_grafico = this.cd_tipo_graficoID;
      this.dt_inicial = null;
      this.dt_final = null;

      //parametro de Pesquisa

      localStorage.cd_identificacao = 0;
      localStorage.cd_parametro = 0;

      if (!this.cd_parametroID == 0) {
        localStorage.cd_parametro = this.cd_parametroID;
      }

      if (!this.cd_identificacaoID == 0) {
        localStorage.cd_identificacao = this.cd_identificacaoID;
      }

      //

      var data = new Date(),
        dia = data.getDate().toString(),
        diaF = dia.length == 1 ? "0" + dia : dia,
        mes = (data.getMonth() + 1).toString(), //+1 pois no getMonth Janeiro começa com zero.
        mesF = mes.length == 1 ? "0" + mes : mes,
        anoF = data.getFullYear();

      //  localStorage.dt_inicial        =  mes+"-"+dia+"-"+anoF;
      // localStorage.dt_final          =  mesF+"-"+diaF+"-"+anoF;

      //exec pr_estrutura_generica 136,6761,0

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';

      //dados = json de retorn da pr (pr_estrutura_generica)
      //
      //this.sParametroApi       = dados.nm_api_parametro;
      sParametroApi = dados.nm_api_parametro;
      //

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      localStorage.cd_tipo_consulta = 0;

      if (!dados.cd_tipo_consulta == 0) {
        dados.cd_tipo_consulta;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));

      //
      if (dados.tituloCard !== "") {
        this.tituloCard = JSON.parse(
          JSON.parse(JSON.stringify(dados.tituloCard))
        );
      }
      //

      //
      //this.tituloCard =

      // this.tituloCard = [{card: 'Hoje'}];
    },

    retorno() {
      return this.dataSourceConfig;
    },

    //
    //mágica - carrego o Json com o Resulta do Stored procedure
    //
    async carregaDados() {
      if (this.cd_consulta == 0) {
        localStorage.cd_parametro = 0;

        await this.showMenu();

        notify(`Aguarde... estamos montando a consulta para você, aguarde !`);

        let sApi = sParametroApi;

        localStorage.cd_parametro = this.cd_parametroID;
        localStorage.cd_identificacao = 1;
        localStorage.cd_tipo_consulta = 1;

        if (!sApi == "") {
          //Rodo a pr no Banco SQL server através da API ( end-Point)
          //traz os dados de retorno em JSON
          this.dataSourceConfig = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            this.api,
            sApi
          );

          //Criado para transformar todos os dt_grafico em string
          for (let a = 0; a < this.dataSourceConfig.length; a++) {
            if (!!this.dataSourceConfig[a].dt_grafico != false) {
              this.dataSourceConfig[a].dt_grafico =
                this.dataSourceConfig[a].dt_grafico + "";
            }
          }

          //this.dataSourceConfigG = await Procedimento.montarProcedimento(
          //  this.cd_empresa,
          //  this.cd_cliente,
          //  this.api,
          //  sApi
          //);
          //
          //this.dataSourceConfigG.unshift({
          //  dt_grafico: "Controle",
          //  vl_total: 0,
          //});
        }

        localStorage.cd_parametro = 0;
        localStorage.cd_identificacao = 0;
        return this.dataSourceConfig;
      } else if (this.cd_consulta != 0) {
        //let API = '457/663'
        await this.showMenu();

        let sApi = dados.nm_api_parametro;

        if (!sApi == "") {
          //Rodo a pr no Banco SQL server através da API ( end-Point)
          //traz os dados de retorno em JSON

          this.dataSourceConfig = await Incluir.incluirRegistro(
            API,
            this.nm_json
          );
        }
        return this.nm_json;
      }
    },

    TrocaInfo(a) {
      a = grid.Selecionada();
      return a;
    },

    onFocusedRowChanged: function (e) {
      data_selecionada = e.row && e.row.data;
    },

    destroyed() {
      this.$destroy();
    },
  },
};
</script>
<style scoped>
#parametro {
  margin-top: 5px;
  padding-top: 5px;
}

form {
  margin-left: 10px;
  margin-right: 10px;
  padding-left: 10px;
  padding-right: 10px;
  margin-top: 5px;
}

.task-info {
  font-family: Segoe UI;
  min-height: 200px;
  display: flex;
  flex-wrap: nowrap;
  border: 2px solid rgba(0, 0, 0, 0.1);
  padding: 5px;
  box-sizing: border-box;
  align-items: baseline;
  justify-content: space-between;
  margin-left: 10px;
  margin-right: 10px;
}

#taskSubject {
  line-height: 29px;
  font-size: 18px;
  font-weight: bold;
}
#taskDetails {
  line-height: 22px;
  font-size: 14px;
  margin-top: 0;
  margin-bottom: 0;
  padding-left: 10px;
}

.info {
  margin-right: 40px;
}

#taskProgress {
  line-height: 42px;
  font-size: 40px;
  font-weight: bold;
}

.options {
  margin-top: 20px;
  padding: 20px;
  background-color: rgba(191, 191, 191, 0.15);
  position: relative;
}

.caption {
  font-size: 18px;
  font-weight: 500;
}

.option {
  margin-top: 10px;
  margin-right: 40px;
  display: inline-block;
}

.option:last-child {
  margin-right: 0;
}

.option > .dx-numberbox {
  width: 200px;
  display: inline-block;
  vertical-align: middle;
}

.option > span {
  margin-right: 10px;
}

#exportButton {
  margin-bottom: 10px;
}

.botao-exportar {
  margin-top: 10px;
  margin-left: 10px;
}
.botao-info {
  float: right;
  right: 10px;
}
.info-periodo {
  margin-top: 10px;
  float: right;
  margin-right: 25px;
  right: 10px;
  font-size: 16px;
}

.info-cor {
  color: #506ad4;
  font-size: 20px;
}

.my-card {
  max-width: 250px;
  margin: 0.7vw;
  min-height: 550px;
}

.card-titulo {
  color: orangered;
  font-size: 15px;
  font-weight: bold;
}

.label_cima {
  width: 100%;
  margin-left: -5px;
  text-align: left;
}

.chart {
  height: 440px;
  width: 100%;
}

.funnel {
  height: 440px;
}
.funnel .label {
  font-size: 28px;
}

.pie {
  max-width: 800px;
  margin: 0 auto;
  display: flex;
  justify-content: left;
  align-items: left;
  flex-direction: row;
}
#chart-demo {
  height: 440px;
  width: 85vw;
}

#radarChart {
  height: 500px;
}

#chart-demo > .center {
  text-align: center;
}

#chart-demo > .center > div,
#chart-demo > .center > .dx-widget {
  display: inline-block;
  vertical-align: middle;
}

.long-title h3 {
  font-family: "Segoe UI Light", "Helvetica Neue Light", "Segoe UI",
    "Helvetica Neue", "Trebuchet MS", Verdana;
  font-weight: 200;
  font-size: 28px;
  text-align: center;
  margin-bottom: 20px;
}

#grid-padrao {
  max-height: 600px !important;
}
.margin1 {
  margin: 0.5vh 0.5vw;
}

/* Enter and leave animations can use different */
/* durations and timing functions.              */
.slide-fade-enter-active {
  transition: all 0.3s ease;
}
.slide-fade-leave-active {
  transition: all 0.8s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter, .slide-fade-leave-to
/* .slide-fade-leave-active below version 2.1.8 */ {
  transform: translateX(10px);
  opacity: 0;
}
</style>
