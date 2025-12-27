<template>
  <div class="padding1">
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="text-h5 text-bold padding1">Documentos</div>
    <div v-show="this.mostra_grid == true">
      <q-toggle class="text-bold" v-model="edit" label="Edição" />
      <DxDataGrid
        :show-borders="true"
        :data-source="dados_grid"
        v-if="this.mostra_grid == true"
        id="grid-padrao"
        class="dx-card wide-card"
        :columns="columns"
        key-expr="cd_controle"
        :focused-row-enabled="true"
        :column-auto-width="true"
        :column-hiding-enabled="false"
        :selection="{ mode: 'single' }"
        :remote-operations="false"
        :word-wrap-enabled="false"
        :allow-column-reordering="true"
        :allow-column-resizing="true"
        :row-alternation-enabled="true"
        :repaint-changes-only="true"
        :autoNavigateToFocusedRow="true"
        :cacheEnable="false"
        @row-updated="AlteraDoc"
        @row-removing="ExcluiDoc"
        @selection-changed="MudaLinha"
      >
        <DxEditing :allow-updating="edit" :allow-deleting="true" mode="batch" />
      </DxDataGrid>
    </div>
    <div class="text-center text-h6 text-bold" v-if="this.mostra_grid == false">
      <q-separator />
      Sem documentos
      <q-separator />
    </div>
    <div class="row text-h6 padding1">Enviar Documentos</div>
    <div class="row">
      <div class="col padding1">
        <q-select
          label="Tipo de Documento"
          v-model="doc"
          input-debounce="0"
          :options="this.dataset_documento"
          option-value="cd_tipo_documento"
          option-label="nm_tipo_documento"
          @input="CodigoDoc()"
        >
          <template v-slot:prepend>
            <q-icon name="store" />
          </template>
        </q-select>
        <q-select
          v-if="cd_modulo == 256"
          label="Operação Fiscal"
          v-model="operacao_fiscal"
          input-debounce="0"
          :options="this.dataset_operacao_fiscal"
          option-value="cd_operacao_fiscal"
          option-label="nm_op_fiscal"
        >
          <template v-slot:prepend>
            <q-icon name="gavel" />
          </template>
        </q-select>
      </div>
      <div class="col padding1">
        <q-file
          v-model="getUrl"
          multiple
          label="Arquivos"
          use-chips
          class="input"
          :hint="avisa_campo"
        >
          <template v-slot:prepend>
            <q-icon name="attach_file" />
          </template>
        </q-file>
      </div>
    </div>

    <div class="margin1 row" id="div-baixar">
      <div
        v-show="this.edit == false"
        class="col"
        style="margin: 0; padding: 0"
      >
        <q-btn
          v-if="this.mostra_baixar == false && this.mostra_carregar == true"
          @click="carregaDoc()"
          :loading="loading"
          rounded
          label="Carregar"
          class="padding1"
          color="primary"
          icon="file_download"
          style="margin-top: 5px"
        />
        <q-space />
        <q-btn
          class="margin1"
          v-if="this.getUrl.length > 0"
          label="Enviar"
          color="primary"
          rounded
          icon="send"
          style="margin-top: 5px; float: right"
          @click="Docs()"
        />
      </div>
    </div>

    <q-dialog maximized v-model="carregando" persistent>
      <carregando v-if="carregando == true" :corID="'primary'" />
    </q-dialog>

    <xlsx-read :file="getUrl[0]">
      <xlsx-json>
        <template #default="{ collection }">
          <gravaJson
            v-if="gravaV == true"
            :json="collection"
            :Parametros="gravaVM"
          >
          </gravaJson>
        </template>
      </xlsx-json>
    </xlsx-read>
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
import Menu from "../http/menu";

import { XlsxRead, XlsxJson } from "../xlsx/vue-xlsx.es";



import gravaJson from "../components/gravaJson";
import geraJson from "../components/geraExceltoJson";

export default {
  name: "cadastro-documento",
  props: {
    cd_documentoID: { type: Number, default: 0 },
    cd_grava_etapa: { type: Boolean, default: false },
    cd_grava_mov: { type: Boolean, default: false },
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
      linha: {},
      carregando: false,
      dataset_documento: [],
      dataset_operacao_fiscal: [],
      cd_empresa: localStorage.cd_empresa,
      doc: "",
      operacao_fiscal: "",
      edit: false,
      cd_interno: 0,
      baixar: "",
      nm_arquivo: "",
      loading: false,
      mostra_baixar: false,
      ic_converte: false,
      file: null,
      gravaVM: {},
      gravaV: false,
      mostra_carregar: false,
      avisa_campo: "",
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
    if (this.cd_grava_etapa === true) {
      localStorage.filtro = 1; //filtro para consulta e inserção por etapa
    } else if (this.cd_grava_mov === true) {
      localStorage.filtro = 2; //filtro para consulta e inserção por movimento
    } else {
      localStorage.filtro = 0; //sem filtro (ainda não desenvolvindo na pr esse tratamento)
    }

    var dados = await Menu.montarMenu(this.cd_empresa, 7304, 606);
    this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
    let dados_documento = await Lookup.montarSelect(this.cd_empresa, 187);

    this.dataset_documento = JSON.parse(
      JSON.parse(JSON.stringify(dados_documento.dataset))
    );

    this.dataset_documento = this.dataset_documento.filter(
      (e) => e.ic_selecao_documento === "S"
    );
    let dados_operacao_fiscal = await Lookup.montarSelect(this.cd_empresa, 237);

    this.dataset_operacao_fiscal = JSON.parse(
      JSON.parse(JSON.stringify(dados_operacao_fiscal.dataset))
    );

    this.dataset_operacao_fiscal = this.dataset_operacao_fiscal.filter((e) => {
      //CFOP de Entrada
      if (
        e.cd_grupo_operacao_fiscal == 1 ||
        e.cd_grupo_operacao_fiscal == 2 ||
        e.cd_grupo_operacao_fiscal == 3
      )
        return e;
    });
    this.dataset_operacao_fiscal.map((e) => {
      e.nm_op_fiscal = String(
        `${e.cd_mascara_operacao} | ${e.nm_operacao_fiscal}`
      );
    });
    this.dataset_operacao_fiscal = this.dataset_operacao_fiscal.sort(function (
      a,
      b
    ) {
      if (a.cd_mascara_operacao < b.cd_mascara_operacao) return -1;
      return 1;
    });
    //this.carregaMenu();
    await this.carregaDados();
    this.cd_usuario = localStorage.cd_usuario;
    this.cd_modulo = localStorage.cd_modulo;
  },
  watch: {
    dados_grid() {
      if (this.dados_grid.length == 0) {
        this.mostra_carregar = false;
        this.mostra_grid = false;
      }
    },
  },

  methods: {
    async carregaMenu() {
      let y = {
        cd_parametro: 6,
      };
      this.dataset_documento = await Incluir.incluirRegistro(this.api, y);
    },
    async carregaDados() {
      this.mostra_grid = false;
      notify("Carregando...");
      if (localStorage.filtro == 1) {
        var c = {
          cd_parametro: 1,
          cd_etapa: localStorage.cd_kan,
        };
      } else if (localStorage.filtro == 2) {
        var c = {
          cd_parametro: 1,
          cd_movimento: localStorage.cd_mov,
        };
      } else if (localStorage.filtro == 0) {
        var c = {
          cd_parametro: 1,
        };
      }
      this.dados_grid = await Incluir.incluirRegistro(this.api, c);
      if (this.dados_grid.length == 0 || this.dados_grid[0].Cod == 0) {
        notify("Sem documentos anexados");
        this.mostra_grid = false;
      } else {
        this.mostra_grid = true;
      }
      this.gravaV = false;
      this.mostra_carregar = false;
    },

    async AlteraDoc(a) {
      var key = a.data.cd_interno;

      var up = {
        cd_parametro: 3,
        cd_interno: key,
        cd_usuario: this.cd_usuario,
        ds_documento: a.data.Descrição,
        nm_documento: a.data.Documento,
        nm_obs_documento: a.data.Observação,
      };
      var update = await Incluir.incluirRegistro(this.api, up);
      notify(update[0].Msg);
      this.carregaDados();
    },

    async ExcluiDoc(e) {
      var exe = await ftp.DeleteServer(
        e.data.nm_caminho_documento,
        e.data.nm_documento_interno
      );

      this.mostra_baixar = false;

      var v = {
        cd_parametro: 2,
        cd_interno: e.data.cd_interno,
      };
      var exclusao = await Incluir.incluirRegistro(this.api, v);
      notify(exclusao[0].Msg);
      //this.carregaDados();
    },

    jsonDocs() {
      this.ic_converte = !this.ic_converte;
    },

    async Docs() {
      if (!!this.doc.cd_tipo_documento == false) {
        notify("Selecione o tipo de documento!");
        return;
      }
      try {
        this.carregando = true;
        for (let i = 0; i < this.getUrl.length; i++) {
          const file = this.getUrl[i];
          let envio = await ftp.Upload(file, this.cd_empresa);
          const nameFile = envio.envio.Arquivo;
          //localStorage.ds_xml = envio.envio.ConteudoArquivo;
          let arq = {
            cd_parametro: 4,
            nm_documento: file.name,
            cd_usuario: this.cd_usuario,
            cd_tipo_documento: this.doc.cd_tipo_documento,
            cd_etapa: localStorage.cd_kan,
            cd_modulo: this.cd_modulo,
            ds_documento: envio.envio.ConteudoArquivo,
            cd_movimento: 0,
            cd_documento: localStorage.doc,
            nm_documento_interno: nameFile,
            nm_caminho_documento: "EGISNET/" + this.cd_empresa,
          };
          if (localStorage.filtro == 2) {
            arq.cd_etapa = 0;
            arq.cd_movimento = localStorage.cd_mov;
          } else if (localStorage.filtro == 0) {
            arq.cd_movimento = localStorage.cd_mov;
            arq.cd_documento = localStorage.doc;
          }
          var inclu = await Incluir.incluirRegistro("606/844", arq);
          notify(inclu[0].Msg);

          let json_nf = {
            cd_parametro: "1",
            cd_interno: inclu[0].cd_interno,
            cd_operacao_fiscal: this.operacao_fiscal.cd_operacao_fiscal,
            cd_usuario: this.cd_usuario,
          };
          await Incluir.incluirRegistro("849/1326", json_nf);
        }
        this.carregando = false;
        this.getUrl = [];
        this.carregando = false;
        this.doc = "";

        this.carregaDados();
      } catch (error) {
        this.carregando = false;
      }
    },

    CodigoDoc() {
      if (this.doc.cd_documento == 22) {
        this.avisa_campo = "Selecione apenas um arquivo Excel por vez!";
        notify("Selecione apenas um arquivo por vez!");
      } else {
        this.avisa_campo = "";
      }
      localStorage.doc = 0;
      localStorage.doc = this.doc.cd_tipo_documento;
    },
    MudaLinha({ selectedRowsData }) {
      this.linha = selectedRowsData[0];
      this.cd_interno = selectedRowsData[0].cd_interno;
      this.nm_arquivo = selectedRowsData[0].Documento;
      this.mostra_carregar = true;
      this.loading = false;
      this.mostra_baixar = false;
    },
    async carregaDoc() {
      this.carregando = true;
      try {
        let blob = await ftp.Download(
          this.cd_empresa,
          this.linha.nm_documento_interno
        );

        const link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.download = this.linha.nm_documento;
        link.click();
        URL.revokeObjectURL(link.href);
        this.carregando = false;
      } catch (error) {
        this.carregando = false;
      }
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
