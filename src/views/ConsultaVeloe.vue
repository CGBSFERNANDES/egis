<script>
  import Incluir from "../http/incluir_registro";
  import {
    DxDataGrid,
    DxColumn,
    DxGroupPanel,
    DxGrouping,
    DxExport,
    DxFilterRow,
    DxStateStoring,
    DxSelectBox,
    DxSelection,
    DxColumnChooser,
    DxHeaderFilter,
    DxSearchPanel,
    DxPager,
    DxPaging,
  } from "devextreme-vue/data-grid";
  import DxChart, {
    DxCommonSeriesSettings,
    DxArgumentAxis,
    DxSeries,
    DxLabel,
    DxTooltip,
    DxSize,
    DxLegend,
  } from "devextreme-vue/chart";
  import notify from "devextreme/ui/notify";
  import { exportDataGrid } from "devextreme/excel_exporter";
  import ExcelJS from "exceljs";
  import saveAs from "file-saver";
  import { locale, loadMessages } from "devextreme/localization";
  import ptMessages from "devextreme/localization/messages/pt.json";

  export default {
    data() {
      return {
        captionsTable: {
          cd_ano: "Ano",
          qt_consumo: "Consumo (Litros)",
          vl_total: "Total(R$)",
          qt_veiculo: "Veículos",
          qt_motorista: "Motoristas",
          qt_combustivel: "Combustíveis",
          qt_fornecedor: "Fornecedores",
          qt_cidade: "Cidades",
          nm_mes: "Mês",
          dt_movimento: "Data de Abastecimento",
          nm_placa: "Placa",
          vehicleModel: "Modelo",
          nm_combustivel: "Combustível",
          nm_motorista: "Motorista",
          nm_fornecedor: "Fornecedor",
          nm_cidade: "Estado",
          dt_ultima_atualizacao: "Data Referência",
          transactionDate: "Data de Transação",
          qt_registros: "Quantidade de Registros",
        },
        dataSource: [],
        typeQuery: "",
        cd_empresa: "",
        cd_menu: "",
        api: "941/1454", // Consulta Histórico Veloe Abastecimento
        cd_parametro: 0,
        isDisabled: false,
        dataGridInstance: null,
        allMode: "allPages",
        checkBoxesMode: "onClick",
        pageSizes: [10, 20, 50, 100],
      };
    },
    created() {
      this.cd_empresa = localStorage.cd_empresa;
      locale(navigator.language);
      loadMessages(ptMessages);
    },
    destroyed() {
      this.$destroy();
    },
    computed: {
      getColumns() {
        return Object.keys(this.dataSource[0]);
      },
      getFuelConsumption() {
        return this.dataSource.map((d) => d.qt_consumo);
      },
      getPlates() {
        return this.dataSource.map((d) => d.nm_placa);
      },
    },
    methods: {
      async getData() {
        try {
          this.isDisabled = true;
          const query = {
            cd_parametro: this.cd_parametro,
            dt_inicial: this.formatDateMMDDYYYY(localStorage.dt_inicial),
            dt_final: this.formatDateMMDDYYYY(localStorage.dt_final),
          };
          const res = await Incluir.incluirRegistro(this.api, query);
          this.isDisabled = false;
          this.dataSource = res;
        } catch (error) {
          notify("Erro ao consultar", error);
        } finally {
          this.isDisabled = false;
        }
      },
      formatDateMMDDYYYY(data) {
        const [month, day, year] = data.split("-");
        return `${month}/${day}/${year}`;
      },
      onExporting(e) {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet("Consulta");

        exportDataGrid({
          component: e.component,
          worksheet: worksheet,
          autoFilterEnabled: true,
        }).then(function() {
          // https://github.com/exceljs/exceljs#writing-xlsx
          workbook.xlsx.writeBuffer().then(function(buffer) {
            saveAs(
              new Blob([buffer], { type: "application/octet-stream" }),
              "DataGrid.xlsx"
            );
          });
        });
        e.cancel = true;
      },
      saveGridInstance(e) {
        this.dataGridInstance = e.component;
      },
    },
    components: {
      DxDataGrid,
      DxColumn,
      DxLabel,
      DxArgumentAxis,
      DxCommonSeriesSettings,
      DxChart,
      DxTooltip,
      DxSeries,
      DxGroupPanel,
      DxGrouping,
      DxExport,
      DxFilterRow,
      DxStateStoring,
      DxSelection,
      DxHeaderFilter,
      DxSearchPanel,
      DxSelectBox,
      DxColumnChooser,
      DxSize,
      DxPager,
      DxPaging,
      DxLegend,
    },
  };
</script>

<template>
  <div class="margin1">
    <div class="text-h6">Consultas Veloe</div>

    <div class="dx-card responsive-paddings borda lista-botoes-consultas">
      <q-btn
        color="orange-9"
        text-color="white"
        @click="
          () => {
            dataSource = [];
            typeQuery = 'ano';
            cd_parametro = 2;
          }
        "
        >Anual</q-btn
      >
      <q-btn
        color="orange-9"
        text-color="white"
        @click="
          () => {
            dataSource = [];
            typeQuery = 'mês';
            cd_parametro = 3;
          }
        "
        >Mensal</q-btn
      >
      <q-btn
        color="orange-9"
        text-color="white"
        @click="
          () => {
            dataSource = [];
            typeQuery = 'dia';
            cd_parametro = 9;
          }
        "
        >Diária</q-btn
      >
      <q-btn
        color="orange-9"
        text-color="white"
        @click="
          () => {
            dataSource = [];
            typeQuery = 'placa';
            cd_parametro = 4;
          }
        "
        >Placa</q-btn
      >
      <q-btn
        color="orange-9"
        text-color="white"
        @click="
          () => {
            dataSource = [];
            typeQuery = 'combustivel';
            cd_parametro = 6;
          }
        "
        >Combustível</q-btn
      >
      <q-btn
        color="orange-9"
        text-color="white"
        @click="
          () => {
            dataSource = [];
            typeQuery = 'motorista';
            cd_parametro = 5;
          }
        "
        >Motorista</q-btn
      >
      <q-btn
        color="orange-9"
        text-color="white"
        @click="
          () => {
            dataSource = [];
            typeQuery = 'fornecedor';
            cd_parametro = 8;
          }
        "
        >Fornecedor</q-btn
      >
      <q-btn
        color="orange-9"
        text-color="white"
        @click="
          () => {
            dataSource = [];
            typeQuery = 'estado';
            cd_parametro = 7;
          }
        "
        >Estado</q-btn
      >
      <q-btn
        color="orange-9"
        text-color="white"
        @click="
          () => {
            dataSource = [];
            typeQuery = 'histórico';
            cd_parametro = 0;
          }
        "
        >Histórico de Atualização</q-btn
      >
    </div>

    <div v-if="typeQuery" class="text-body1 text-weight-bold q-mt-md">
      Relatório de consumo por {{ typeQuery }}

      <div v-if="typeQuery" class="row q-mt-sm">
        <q-btn
          :disabled="isDisabled"
          color="orange-9"
          @click="getData()"
          text-color="white"
          :loading="isDisabled"
        >
          Consultar
        </q-btn>
      </div>
      <template
        v-if="
          typeQuery === 'ano' ||
            typeQuery === 'mês' ||
            typeQuery === 'combustivel' ||
            typeQuery === 'motorista' ||
            typeQuery === 'fornecedor' ||
            typeQuery === 'estado'
        "
      >
        <div class="chart-scroll-wrapper">
          <DxChart
            class="q-mt-md"
            :title="`Consumo e valor total por ${typeQuery}`"
            v-if="dataSource.length > 0"
            :data-source="dataSource"
          >
            <DxSize
              v-if="['motorista', 'fornecedor'].includes(typeQuery)"
              :height="700"
              width="2000"
            />
            <DxTooltip :enabled="true" />
            <DxCommonSeriesSettings
              :argument-field="
                (typeQuery === 'ano' && 'cd_ano') ||
                  (typeQuery === 'mês' && 'nm_mes') ||
                  (typeQuery === 'combustivel' && 'nm_combustivel') ||
                  (typeQuery === 'motorista' && 'nm_motorista') ||
                  (typeQuery === 'fornecedor' && 'nm_fornecedor') ||
                  (typeQuery === 'estado' && 'nm_cidade')
              "
            />
            <DxLegend
              position="outside"
              orientation="horizontal"
              verticalAlignment="top"
              horizontalAlignment="center"
              :margin="{ bottom: 20 }"
            />

            <DxArgumentAxis>
              <DxLabel :rotation-angle="90" overlapping-behavior="rotate" />
            </DxArgumentAxis>
            <DxSeries
              name="Consumo (Litros)"
              value-field="qt_consumo"
              type="bar"
            />
            <DxSeries name="Total (R$)" value-field="vl_total" type="bar" />
            <DxSeries
              v-if="typeQuery === 'motorista'"
              name="Média de consumo"
              value-field="vl_media_consumo"
              type="spline"
            />
          </DxChart>
        </div>
      </template>

      <template v-if="typeQuery === 'dia'">
        <DxChart
          :title="`Consumo total por ${typeQuery}`"
          v-if="dataSource.length > 0"
          :data-source="dataSource"
        >
          <DxCommonSeriesSettings type="spline" />
          <DxTooltip :enabled="true" />
          <DxLegend
            position="outside"
            orientation="horizontal"
            verticalAlignment="top"
            horizontalAlignment="center"
            :margin="{ bottom: 20 }"
          />
          <DxArgumentAxis>
            <DxLabel
              :customize-text="(e) => new Date(e.value).toLocaleDateString()"
            />
          </DxArgumentAxis>
          <DxSeries
            argument-field="dt_movimento"
            value-field="qt_consumo"
            name="Litros"
          />
        </DxChart>
      </template>

      <template v-if="typeQuery === 'placa'">
        <div class="chart-scroll-wrapper">
          <DxChart
            style="min-width: 2000px"
            :title="`Consumo total por ${typeQuery}`"
            v-if="dataSource.length > 0"
            :data-source="dataSource"
          >
            <DxTooltip :enabled="true" />
            <DxLegend
              position="outside"
              orientation="horizontal"
              verticalAlignment="top"
              horizontalAlignment="center"
              :margin="{ bottom: 20 }"
            />
            <DxArgumentAxis>
              <DxLabel :rotation-angle="45" :overlapping-behavior="'rotate'" />
            </DxArgumentAxis>
            <DxSeries
              argument-field="nm_placa"
              value-field="qt_consumo"
              name="Litros"
              type="bar"
            />
            <DxSeries
              argument-field="nm_placa"
              value-field="vl_media_consumo"
              name="Média de consumo"
              type="spline"
            />
          </DxChart>
        </div>
      </template>

      <Dx-DataGrid
        v-if="dataSource.length > 0"
        id="grid-padrao"
        class="dx-card q-mt-sm"
        :data-source="dataSource"
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
        :key-expr="
          typeQuery === 'histórico' ? 'dt_ultima_atualizacao' : 'qt_consumo'
        "
        @exporting="onExporting"
        @initialized="saveGridInstance"
      >
        <DxPager
          :show-page-size-selector="true"
          :allowed-page-sizes="pageSizes"
          :show-info="true"
        />
        <DxPaging :page-size="50" />
        <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
        <DxGrouping :auto-expand-all="true" />
        <DxExport :enabled="true" />
        <DxStateStoring
          :enabled="true"
          type="localStorage"
          storage-key="storageGrid"
        />
        <DxSelection mode="single" />
        <DxFilterRow :visible="false" />
        <DxHeaderFilter :visible="true" :allow-search="true" />
        <DxSelection
          :select-all-mode="allMode"
          :show-check-boxes-mode="checkBoxesMode"
          mode="multiple"
        />
        <DxSearchPanel :visible="true" :width="200" placeholder="Procurar..." />
        <DxSelectBox
          id="select-all-mode"
          :data-source="['allPages', 'page']"
          :disabled="checkBoxesMode === 'none'"
          :v-model:value="allMode"
        />
        <DxColumnChooser :enabled="true" mode="select" />
        <Dx-Column
          v-for="field in getColumns"
          :key="field"
          :visible="!(field === 'cd_mes' || field === 'vl_media_consumo')"
          :data-field="field"
          :caption="captionsTable[field] || field"
          v-bind="
            (field === 'vl_total' && {
              format: { type: 'currency', currency: 'BRL', precision: 2 },
            }) ||
              ((field === 'dt_movimento' ||
                field === 'dt_ultima_atualizacao') && {
                dataType: 'date',
                format: 'shortDate',
              }) ||
              (field === 'transactionDate' && {
                dataType: 'date',
                format: 'dd/MM/yyyy HH:mm:ss',
              })
          "
        />
      </Dx-DataGrid>
    </div>
  </div>
</template>

<style scoped>
  @import url("./views.css");

  .lista-botoes-consultas {
    display: flex;
    gap: 1rem;
  }

  .row {
    gap: 1rem;
  }

  .chart-scroll-wrapper {
    width: 100%;
    overflow-x: auto;
  }
</style>
