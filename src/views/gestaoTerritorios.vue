<template>
  <div class="margin1">
    <div style="display: flex; align-items: center; justify-content: center">
      <q-btn
        rounded
        color="orange-9"
        text-color="white"
        size="lg"
        :label="`${dados.nm_menu_titulo}`"
      />
    </div>
    <div class="margin1 container">
      <!-- Parte esquerda -->
      <div class="left-section">
        <h2>Vendedores</h2>
        <div class="row flexBox">
          <q-file
            dense
            use-input
            hide-selected
            fill-input
            class="margin1 col"
            v-model="arq_upload"
            label="Escolher arquivo"
            accept=".xls, .xlsx"
            @input="onFile($event)"
          >
            <template v-slot:prepend>
              <q-icon name="description" />
            </template>
          </q-file>
          <q-select
            dense
            use-input
            hide-selected
            fill-input
            class="margin1 col"
            label="Vendedor"
            v-model="vendedor_left"
            :options="dados_lookup_vendedor"
            :loading="load_vendedor_left"
            option-value="cd_vendedor"
            option-label="nm_vendedor"
            @input="selectVendedor()"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-select>
        </div>
        <div class="row listButtons">
          <q-btn
            rounded
            class="margin1"
            color="orange-9"
            text-color="white"
            label="Transferir selecionados"
            @click="onTransferir()"
          />
          <div class="margin1 valor_total">
            {{ `Total ${total_left}` }}
            <br />
            {{
              `Meta Vigente ${
                jsonData.length > 0 ? jsonData[0].vl_meta : "R$ 0,00"
              }`
            }}
          </div>
        </div>
        <dx-data-grid
          id="grid-padrao"
          ref="grid-padrao"
          class="margin1 dx-card wide-card-gc"
          key-expr="cd_controle"
          :focused-row-key="0"
          :data-source="jsonData"
          :columns="columns"
          :show-borders="true"
          :focused-row-enabled="true"
          :column-auto-width="true"
          :column-hiding-enabled="false"
          :remote-operations="false"
          :word-wrap-enabled="false"
          :allow-column-reordering="true"
          :allow-column-resizing="true"
          :row-alternation-enabled="false"
          :repaint-changes-only="true"
          :autoNavigateToFocusedRow="true"
          :cacheEnable="false"
          noDataText="Sem dados"
          @contentReady="onDataSource"
          @selectionChanged="selectRow"
        >
          <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

          <DxGrouping :auto-expand-all="true" />
          <DxExport :enabled="true" />

          <DxEditing
            :allow-updating="true"
            :allow-adding="false"
            :allow-deleting="false"
            mode="cell"
          />

          <DxPaging :enable="true" :page-size="10" />

          <DxSelection mode="multiple" />

          <DxStateStoring
            :enabled="true"
            type="localStorage"
            storage-key="storage"
          />
          <DxPager
            :show-page-size-selector="true"
            :allowed-page-sizes="[10, 20, 50, 100]"
            :show-info="true"
          />
          <DxHeaderFilter
            :visible="true"
            :allow-search="true"
            :width="400"
            :height="400"
          />
          <DxSearchPanel
            :visible="true"
            :width="300"
            placeholder="Procurar..."
          />
          <DxColumnChooser :enabled="true" mode="select" />
        </dx-data-grid>
      </div>
      <!-- Parte direita -->
      <div class="right-section">
        <h2>Dados transferidos</h2>
        <div class="row flexBox">
          <q-select
            dense
            use-input
            hide-selected
            fill-input
            class="margin1 col"
            label="Vendedor"
            v-model="vendedor_right"
            :options="dados_lookup_vendedor"
            option-value="cd_vendedor"
            option-label="nm_vendedor"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-select>
        </div>
        <div class="row listButtons">
          <q-btn
            rounded
            class="margin1"
            color="orange-9"
            text-color="white"
            :loading="load_confirmar"
            label="Confirmar"
            @click="onConfirmar()"
          />
          <q-btn
            v-if="jsonTransferidos.length > 0"
            rounded
            class="margin1"
            color="red"
            text-color="white"
            label="Voltar"
            @click="onVoltar()"
          />
          <div v-if="jsonTransferidos.length > 0" class="margin1 valor_total">
            {{ `Total ${total_right}` }}
            <br />
            {{
              `Meta Vigente ${
                jsonData.length > 0 ? jsonData[0].vl_meta : "R$ 0,00"
              }`
            }}
          </div>
        </div>
        <dx-data-grid
          id="grid-selecionada"
          ref="grid-selecionada"
          class="margin1 dx-card wide-card-gc"
          key-expr="cd_controle"
          :focused-row-key="0"
          :data-source="jsonTransferidos"
          :columns="columns"
          :show-borders="true"
          :focused-row-enabled="true"
          :column-auto-width="true"
          :column-hiding-enabled="false"
          :remote-operations="false"
          :word-wrap-enabled="false"
          :allow-column-reordering="true"
          :allow-column-resizing="true"
          :row-alternation-enabled="false"
          :repaint-changes-only="true"
          :autoNavigateToFocusedRow="true"
          :cacheEnable="false"
          noDataText="Sem dados"
          @contentReady="onDataSource"
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
          <DxPager
            :show-page-size-selector="true"
            :allowed-page-sizes="[10, 20, 50, 100]"
            :show-info="true"
          />
          <DxHeaderFilter
            :visible="true"
            :allow-search="true"
            :width="400"
            :height="400"
          />
          <DxSearchPanel
            :visible="true"
            :width="300"
            placeholder="Procurar..."
          />
          <DxColumnChooser :enabled="true" mode="select" />
        </dx-data-grid>
      </div>
    </div>
  </div>
</template>
  
  <script>
import {
  DxDataGrid,
  DxPager,
  DxPaging,
  DxSelection,
  DxExport,
  DxEditing,
  DxGroupPanel,
  DxGrouping,
  DxColumnChooser,
  DxHeaderFilter,
  DxStateStoring,
  DxSearchPanel,
} from "devextreme-vue/data-grid";

import "devextreme-vue/text-area";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import Menu from "../http/menu";
import select from "../http/select";
import ExcelJS from "exceljs";

export default {
  components: {
    DxDataGrid,
    DxPager,
    DxPaging,
    DxSelection,
    DxExport,
    DxEditing,
    DxGroupPanel,
    DxGrouping,
    DxColumnChooser,
    DxHeaderFilter,
    DxStateStoring,
    DxSearchPanel,
  },
  name: "gestaoTerrirorios",
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      dados: [],
      dataSourceConfig: [],
      tabsheets: [],
      dataSourceGrid: [],
      arq_upload: [],
      obj_item: {},
      columns: [],
      jsonData: [],
      api: "928/1438", //pr_egisnet_gestao_territorios
      jsonTransferidos: [],
      firstTabsheet: "",
      linhas_selecionadas: [],
      load_vendedor_left: false,
      vendedor_left: "",
      vendedor_right: "",
      total_left: "",
      total_right: "",
      dados_lookup_vendedor: [],
      load_grid: true,
      load_confirmar: false,
      load: false,
      semana: {
        store: {
          type: "array",
          key: "cd_semana",
          data: [
            {
              cd_semana: 1,
              nm_semana: "Domingo",
              sg_semana: "DOM",
            },
            {
              cd_semana: 2,
              nm_semana: "Segunda-Feira",
              sg_semana: "SEG",
            },
            {
              cd_semana: 3,
              nm_semana: "Terça-Feira",
              sg_semana: "TER",
            },
            {
              cd_semana: 4,
              nm_semana: "Quarta-Feira",
              sg_semana: "QUA",
            },
            {
              cd_semana: 5,
              nm_semana: "Quinta-Feira",
              sg_semana: "QUI",
            },
            {
              cd_semana: 6,
              nm_semana: "Sexta-Feira",
              sg_semana: "SEX",
            },
            {
              cd_semana: 7,
              nm_semana: "Sábado",
              sg_semana: "SAB",
            },
          ],
        },
        pageSize: 10,
        paginate: true,
      },
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
  },

  async mounted() {
    try {
      this.load = true;
      await this.carregaDados();
      this.load = false;
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(error);
    } finally {
      this.load = false;
    }
  },
  watch: {
    jsonData(NOVO) {
      this.total_left = 0;
      let total_left = NOVO.reduce(
        (total, item) =>
          total +
          parseFloat(
            item.Faturamento.replace("R$ ", "")
              .replaceAll(".", "")
              .replace(",", ".")
          ),
        0
      );
      this.total_left = total_left.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
    },
    jsonTransferidos(NOVO) {
      this.total_right = 0;
      let total_right = NOVO.reduce(
        (total, item) =>
          total +
          parseFloat(
            item.Faturamento.replace("R$ ", "")
              .replaceAll(".", "")
              .replace(",", ".")
          ),
        0
      );
      this.total_right = total_right.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
    },
  },
  computed: {
    grid() {
      return this.$refs["grid-padrao"].instance;
    },
  },

  methods: {
    async carregaDados() {
      this.dados = await Menu.montarMenu(
        localStorage.cd_empresa,
        localStorage.cd_menu,
        localStorage.cd_api
      );

      let processos_json = {
        cd_empresa: this.cd_empresa,
        cd_tabela: 141,
        order: "nm_fantasia_vendedor",
        where: [{ ic_ativo: "S" }, { "isnull(ic_egismob_vendedor,S)": "S" }],
      };
      let [lookup_vendedor] = await select.montarSelect(
        this.cd_empresa,
        processos_json
      );
      this.dados_lookup_vendedor = JSON.parse(
        JSON.parse(JSON.stringify(lookup_vendedor.dataset))
      );
    },
    async onFile(file) {
      try {
        this.columns = [];
        this.jsonData = [];
        this.load_grid = true;
        const reader = new FileReader();
        reader.onload = async (e) => {
          const arrayBuffer = e.target.result;
          const workbook = new ExcelJS.Workbook();
          await workbook.xlsx.load(arrayBuffer);
          workbook._worksheets.forEach((element) => {
            this.firstTabsheet = element.name;
          });
          const worksheet = workbook.getWorksheet(this.firstTabsheet); // Pegue a primeira planilha
          worksheet.eachRow((row, rowNumber) => {
            if (rowNumber === 1) {
              this.columns = row.values.slice(1);
            } else {
              let itemAdd = this.columns.reduce(
                (acc, header, index) => (
                  (acc.cd_controle = rowNumber),
                  (acc[header] = row.getCell(index + 1).value),
                  acc
                ),
                {}
              );
              this.jsonData.push(itemAdd);
            }
          });
        };
        reader.readAsArrayBuffer(file);
        this.load_grid = false;
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
        this.load_grid = false;
      }
    },
    onTransferir() {
      if (!this.vendedor_left) {
        return notify("Selecione o vendedor");
      }
      if (this.linhas_selecionadas.length > 0) {
        this.jsonTransferidos.push(...this.linhas_selecionadas);
        const filtered = this.jsonData.filter(
          (item) =>
            !this.linhas_selecionadas.some(
              (selecionado) => item.cd_controle === selecionado.cd_controle
            )
        );
        this.jsonData = [];
        this.jsonData.push(...filtered);
      } else {
        notify("Selecione pelo menos um cliente para transferir");
      }
    },
    async selectVendedor() {
      try {
        this.load_vendedor_left = true;
        this.columns = [
          { caption: "Vendedor", dataField: "Vendedor", allowEditing: false },
          { caption: "Cliente", dataField: "Cliente", allowEditing: false },
          {
            caption: "Razão Social",
            dataField: "RazaoSocial",
            allowEditing: false,
          },
          {
            caption: "Faturamento Anual",
            dataField: "Faturamento",
            allowEditing: false,
          },
          {
            caption: "Faturamento Mensal",
            dataField: "FaturamentoMensal",
            allowEditing: false,
          },
          { caption: "Meta", dataField: "vl_meta", allowEditing: false },
          { caption: "Média", dataField: "vl_media", allowEditing: false },
          { caption: "Cidade", dataField: "Cidade", allowEditing: false },
          {
            caption: "Semana",
            dataField: "cd_semana",
            lookup: {
              dataSource: this.semana,
              displayExpr: "nm_semana",
              valueExpr: "cd_semana",
            },
            allowEditing: true,
          },
        ];
        let carregaVisita = {
          cd_parametro: 2,
          cd_usuario: localStorage.cd_usuario,
          cd_vendedor_origem: this.vendedor_left.cd_vendedor,
          dt_inicial: localStorage.dt_inicial,
          dt_final: localStorage.dt_final,
        };
        this.jsonData = await Incluir.incluirRegistro(this.api, carregaVisita); //pr_egisnet_gestao_territorios
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
      } finally {
        this.load_vendedor_left = false;
      }
    },
    onDataSource() {
      this.grid.selectRows([this.jsonData[0]]);
    },
    selectRow(first) {
      this.linhas_selecionadas = first.selectedRowsData;
    },
    async onConfirmar() {
      if (!this.vendedor_right) {
        return notify("Selecione o vendedor para transferir");
      }
      try {
        if (this.jsonTransferidos.length > 0) {
          this.load_confirmar = true;
          //Transferir os clientes
          let carregaDataSouce = {
            cd_parametro: 0,
            cd_usuario: localStorage.cd_usuario,
            cd_vendedor_origem: this.vendedor_left.cd_vendedor,
            cd_vendedor_destino: this.vendedor_right.cd_vendedor,
            dataSource: this.jsonTransferidos,
          };
          let [result_transferencia] = await Incluir.incluirRegistro(
            this.api,
            carregaDataSouce
          ); //pr_egisnet_gestao_territorios
          notify(result_transferencia.Msg);
        } else {
          return notify("Nenhum item selecionado");
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
      } finally {
        this.load_confirmar = false;
      }
    },
    onVoltar() {
      if (this.jsonTransferidos.length > 0) {
        this.jsonData.push(...this.jsonTransferidos);
        this.jsonTransferidos = [];
      }
    },
  },
};
</script>
  
  <style scoped>
@import url("../views/views.css");

.flexBox {
  display: flex;
  width: 100%;
}

.listButtons {
  display: flex;
  align-items: flex-start;
  justify-content: flex-start;
}

/* Contêiner principal */
.container {
  display: flex;
  flex-direction: row; /* Divisão em linhas (horizontal) */
  height: 100%;
  flex-wrap: wrap;
}

/* Parte esquerda */
.left-section {
  flex: 1; /* Ocupa metade da largura */
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

/* Parte direita */
.right-section {
  flex: 1; /* Ocupa metade da largura */
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border-left: 1px solid #000; /* Cor e espessura da linha divisória */
}

.valor_total {
  font-weight: bold;
  margin-top: 10px;
  text-align: right;
  color: #333;
}
</style>
  