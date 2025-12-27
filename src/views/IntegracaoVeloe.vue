<script>
  import axios from "axios";
  import notify from "devextreme/ui/notify";
  import {
    DxDataGrid,
    DxColumn,
    DxPager,
    DxPaging,
    DxGroupPanel,
    DxGrouping,
    DxExport,
    DxStateStoring,
    DxSelection,
    DxFilterRow,
    DxHeaderFilter,
    DxSearchPanel,
    DxSelectBox,
    DxColumnChooser,
  } from "devextreme-vue/data-grid";
  import { exportDataGrid } from "devextreme/excel_exporter";
  import ExcelJS from "exceljs";
  import saveAs from "file-saver";
  import { locale, loadMessages } from "devextreme/localization";
  import ptMessages from "devextreme/localization/messages/pt.json";

  export default {
    data() {
      return {
        accessToken: "",
        tokenTimestamp: "",
        plate: "",
        driver: "",
        records: null,
        isDisabled: false,
        pageSizes: [10, 20, 50, 100],
        allMode: "allPages",
        checkBoxesMode: "onClick",
        dataGridInstance: null,
        errorMessages: {
          ERROR04: "A data de término é posterior à data atual.",
          ERROR03: "O período máximo dos dias é 7.",
        },
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
    methods: {
      async authenticate() {
        const now = Date.now();
        if (
          this.accessToken &&
          this.tokenTimestamp &&
          now - this.tokenTimestamp < 120 * 60 * 1000
        ) {
          return this.accessToken;
        }
        const res = await axios.post(
          "https://api.alelo.com.br/alelo/prd/auto/partner/api/fuel-supply-data/login",
          {},
          {
            headers: {
              "x-ibm-client-id": process.env.VUE_APP_CLIENT_ID,
              "x-ibm-client-secret": process.env.VUE_APP_CLIENT_SECRET,
              clientid: process.env.VUE_APP_CLIENT_ID,
              "Content-Type": "application/json",
            },
          }
        );
        this.accessToken = res.data.body.accessToken;
        this.tokenTimestamp = now;
        return this.accessToken;
      },
      formatDateDDMMYYYY(date) {
        const [month, day, year] = date.split("-");
        return `${day}/${month}/${year}`;
      },
      saveGridInstance(e) {
        this.dataGridInstance = e.component;
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
      async onSubmit() {
        this.isDisabled = true;
        try {
          const token = await this.authenticate();

          const response = await axios.post(
            `https://api.alelo.com.br/alelo/prd/auto/partner/api/fuel-supply-data/v1/supply-history-anp/contract/${process.env.VUE_APP_CONTRACT}`,
            {
              startDate: this.formatDateDDMMYYYY(localStorage.dt_inicial),
              endDate: this.formatDateDDMMYYYY(localStorage.dt_final),
              pageNumber: 0,
              pageSize: 1000,
            },
            {
              headers: {
                "x-ibm-client-id": process.env.VUE_APP_CLIENT_ID,
                Authorization: `Bearer ${token}`,
                "Content-Type": "application/json",
              },
            }
          );
          this.records = response.data.body;
        } catch (err) {
          notify(
            `Erro na importação: ${this.errorMessages[
              err.response.data.errors[0].code
            ] || err.message}`
          );
        } finally {
          this.isDisabled = false;
        }
      },
    },
    computed: {
      filteredData() {
        const plateLowerCase = this.plate.toLowerCase();
        const driverLowerCase = this.driver.toLowerCase();

        if (plateLowerCase.length === 0 && driverLowerCase.length === 0) {
          return this.records;
        }

        return this.records.filter((record) => {
          const recordPlate = (record.vehiclePlate || "").toLowerCase();
          const recordDriver = (record.driverName || "").toLowerCase();

          const plateMatches =
            plateLowerCase.length > 0 && recordPlate.includes(plateLowerCase);

          const driverMatches =
            driverLowerCase.length > 0 &&
            recordDriver.includes(driverLowerCase);

          return (
            (plateLowerCase.length > 0 && plateMatches) ||
            (driverLowerCase.length > 0 && driverMatches)
          );
        });
      },
    },
    components: {
      DxDataGrid,
      DxColumn,
      DxPager,
      DxPaging,
      DxGroupPanel,
      DxGrouping,
      DxExport,
      DxStateStoring,
      DxSelection,
      DxFilterRow,
      DxHeaderFilter,
      DxSearchPanel,
      DxSelectBox,
      DxColumnChooser,
    },
  };
</script>

<template>
  <section class="margin1">
    <div class="text-h6 text-start margin1">Importar Movimento</div>
    <div class="wrapper">
      <q-btn
        :disabled="isDisabled"
        color="orange-9"
        @click="onSubmit()"
        text-color="white"
        :loading="isDisabled"
        >Importar</q-btn
      >
    </div>

    <Dx-DataGrid
      v-if="records"
      id="grid-padrao"
      class="dx-card q-mt-sm"
      :data-source="records"
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
      key-expr="transactionDate"
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
        data-field="transactionDate"
        caption="DATA"
        format="dd/MM/yyyy"
      />
      <Dx-Column data-field="vehiclePlate" caption="PLACA" />
      <Dx-Column data-field="driverName" caption="MOTORISTA" />
      <Dx-Column data-field="vehicleModel" caption="MODELO" />
      <Dx-Column data-field="fuelType" caption="COMBUSTÍVEL" />
      <Dx-Column data-field="amountLiters" caption="LITROS" />
      <Dx-Column data-field="unitValue" caption="VALOR" />
      <Dx-Column data-field="supplyLocation" caption="POSTO" />
    </Dx-DataGrid>
  </section>
</template>

<style scoped lang="scss">
  @import url("./views.css");

  .import {
    display: flex;
    justify-content: start;
  }

  .wrapper {
    display: grid;
    grid-template-columns: repeat(3, 0.5fr);
    column-gap: 10px;
    row-gap: 1em;
    width: 50%;
  }
</style>
