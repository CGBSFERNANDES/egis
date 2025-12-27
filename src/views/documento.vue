<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="text-h5 text-bold padding1">Documentos</div>
    <div style="width: 100vw; height: 100vh;">
      <embed
        :src="nm_caminho_documento"
        type="application/pdf"
        width="100%"
        height="100%"
      />
    </div>

    <q-dialog maximized v-model="carregando" persistent>
      <carregando v-if="carregando == true" :corID="'primary'" />
    </q-dialog>
  </div>
</template>

<script>
import ftp from "../http/ftp.js";
import {
  DxDataGrid,
  DxColumn,
  DxColumnChooser,
  DxColumnFixing,
  DxEditing,
} from "devextreme-vue/data-grid";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import Lookup from "../http/lookup";
import select from "../http/select";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
//import { XlsxRead, XlsxJson } from "../../dist/vue-xlsx.es.js"

//import { XlsxRead, XlsxJson } from "../xlsx/vue-xlsx.es";
// Adapter: mantém o import antigo funcionando,
// mas entrega os exports do pacote oficial.
export { XlsxRead, XlsxJson, XlsxWorkbook } from 'vue-xlsx';




import gravaJson from "../components/gravaJson";
import geraJson from "../components/geraExceltoJson";

export default {
  name: "documento",
  props: {
    cd_documentoID: { type: Number, default: 0 },
  },
  data() {
    return {
      getUrl: [],
      api: "606/844", //pr_egisnet_crud_documentos
      dados_grid: {},
      columns: [],
      mostra_grid: false,
      cd_usuario: 0,
      cd_modulo: 0,
      carregando: false,
      dataset_documento: [],
      nm_caminho_documento: "",
      cd_empresa: localStorage.cd_empresa,
      cd_menu: localStorage.cd_menu,
      doc: "",
      operacao_fiscal: "",
      edit: false,
      cd_interno: 0,
      baixar: "",
      mostra_baixar: false,
      file: null,
      gravaV: false,
      mostra_carregar: false,
    };
  },
  components: {
    carregando: () => import("../components/carregando.vue"),
    DxDataGrid,
    DxColumn,
    DxColumnChooser,
    DxColumnFixing,
    DxEditing,
    XlsxRead,
    XlsxJson,
    geraJson,
    gravaJson,
  },

  async created() {
    var d = await Menu.montarMenu(this.cd_empresa, this.cd_menu, 663); //"pr_consulta_status_etapa_modulo";
    this.nm_caminho_documento = d.nm_caminho_documento;
  },

  methods: {
    sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },
  },
};
</script>

<style>
.input {
  width: 100%;
  margin-bottom: 1%;
}
#grid-padrao {
  max-height: 600px !important;
}
.your_div_class {
  overflow-x: hidden;
  overflow-y: scroll;
}
.column {
  height: 20px !important;
}
.padding1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}
.democlass {
  width: 40px;
  height: 40px;
  background: red;
}
</style>
