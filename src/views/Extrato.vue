<template>
  <div>
    <div class="text-h6 text-bold margin1"></div>
    <div class="row">
      <div class="col">
        <div class="text-h6 text-bold margin1">
          Extrato | Entregador: {{ nm_entregador }} | {{ nm_veiculo }} |
        </div>
      </div>
      <div class="text-h6 text-bold margin1 self-end" style="float:right">
        <q-btn round color="orange-10" size="xs" icon="battery_charging_full" />
        {{ pc_bateria }}
      </div>
    </div>

    <div class="borda-bloco shadow-2">
      <DxDataGrid
        class="margin1 padding1"
        id="grid-padrao"
        :data-source="json_local"
        :columns="colunas"
        key-expr="cd_controle"
        :summary="total"
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
        @exporting="onExporting"
      >
        <DxFilterRow :visible="false" />
        <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
        <DxGrouping :auto-expand-all="true" />
        <DxExport :enabled="true" />
        <DxPaging :page-size="10" />
        <DxFilterRow :visible="false" />
        <DxPager
          :show-page-size-selector="true"
          :allowed-page-sizes="pageSizes"
          :show-info="true"
        />
        <DxSummary>
          <DxTotalItem column="cd_controle" summary-type="count" />
          <DxTotalItem column="OrderDate" summary-type="min" />
          <DxTotalItem
            column="SaleAmount"
            summary-type="sum"
            value-format="currency"
          />
        </DxSummary>

        <!--<DxEditing
            style="margin:0; padding:0"
            :allow-updating="true"
            :allow-deleting="true"
            mode="batch"
          />
        
         <DxColumn :data-field="colunas[0]" alignment="left"/>
         <DxColumn :data-field="colunas[1]" alignment="left"/>
         <DxColumn :data-field="colunas[2]" alignment="left"/>
         <DxColumn :data-field="colunas[4]" alignment="left"/>
         <DxColumn :data-field="colunas[5]" alignment="left"/>
         <DxColumn :data-field="colunas[6]" alignment="left"/>
         <DxColumn :data-field="colunas[7]" alignment="left"/>
         <DxColumn :data-field="colunas[8]" alignment="left"/>
         <DxColumn :data-field="colunas[9]" alignment="left"/>
         <DxColumn :data-field="colunas[10]" alignment="left"/>
         <DxColumn :data-field="colunas[11]" alignment="left"/>
         <DxColumn :data-field="colunas[12]" alignment="left"/>
         <DxColumn :data-field="colunas[13]" alignment="left"/>
         <DxColumn :data-field="colunas[14]" alignment="left"/>
         <DxColumn :data-field="colunas[15]" alignment="left"/>
         <DxColumn :data-field="colunas[16]" alignment="left"/>
         <DxColumn :data-field="colunas[17]" alignment="left"/>
         <DxColumn :data-field="colunas[18]" alignment="left"/>
         <DxColumn :data-field="colunas[19]" alignment="left"/>
         <DxColumn :data-field="colunas[20]" alignment="left"/>-->
        <DxPaging :page-size="100" />
      </DxDataGrid>
    </div>
  </div>
</template>

<script>
import Incluir from "../http/incluir_registro";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import ExcelJS from "exceljs";

import {
  DxSummary,
  DxDataGrid,
  DxFilterRow,
  DxPager,
  DxPaging,
  DxExport,
  DxGroupPanel,
  DxTotalItem,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxSelection,
  DxStateStoring,
  DxSearchPanel,
  DxEditing,
  DxPosition,
  DxMasterDetail,
  //  DxPopup
} from "devextreme-vue/data-grid";
export default {
  props: {
    cd_romaneio: { type: String, default: "0" },
    cd_parametro: { type: Number, default: 0 },
  },
  name: "extrato",
  components: {
    DxDataGrid,
    DxPager,
    DxPaging,
    DxEditing,
    DxFilterRow,
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
    DxTotalItem,
    DxEditing,
    DxPosition,
    DxSummary,
  },

  data() {
    return {
      json_local: [],
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_cliente: localStorage.cd_cliente,
      api: "628/890",
      cd_menu: localStorage.cd_menu,
      pageSizes: [10, 20, 50, 100],
      nm_entregador: "",
      nm_veiculo: "",
      pc_bateria: "",
      total: {},
      colunas: [
        "Razao Social",
        "Data",
        "Data Entrega",
        "Hora",
        "Data Chegada",
        "Data Saida",
        "Hora Saida",
        "Hora Chegada",
        "Entrega",
        "Hora Entrega",
        "Entregador",
        "Veiculo",
        "Bateria",
        "Endere�o",
        "N",
        "Complemento",
        "Bairro",
        "CEP",
        "Estado",
        "Cidade",
        "Latitude",
        "Longitude",
        "cd_controle",
      ],
    };
  },
  created() {
    //var dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.api);
    //let sParametroApi = '/'+0+'/'+localStorage.cd_usuario+'/'+this.cd_romaneio+'/"'+localStorage.dt_inicial//+'"/"'+localStorage.dt_final+'"';
    if (this.cd_romaneio != 0) {
      this.carregadados();
    }
  },
  methods: {
    async carregadados() {
      var c = {
        cd_parametro: this.cd_parametro,
        cd_usuario: this.cd_usuario,
        cd_identificacao: this.cd_romaneio,
        dt_inicial: localStorage.dt_inicial,
        dt_final: localStorage.dt_final,
      };
      this.json_local = await Incluir.incluirRegistro(this.api, c); //pr_extrato_entregador
      if (this.json_local.length > 0) {
        this.nm_entregador = this.json_local[0].Entregador;
        this.nm_veiculo = this.json_local[0].Veiculo;
        this.pc_bateria = this.json_local[0].Bateria;
      }
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
            filename
          );
        });
      });
      e.cancel = true;
    },
  },
};
</script>

<style scoped>
.padding1 {
  padding: 0.3% 0.8%;
}
.margin1 {
  margin: 0.5%;
}
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}
#grid-padrao {
  max-height: 600px !important;
}
</style>
