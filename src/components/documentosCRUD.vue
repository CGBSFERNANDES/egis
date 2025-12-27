<template>
  <div>
    <div class="text-h6">
      <b>Documentos</b>{{ ` vinculados ${nm_origem}` }}
      {{ `- ${cd_documentoID} - ${Fantasia}` }}
    </div>
    <div>
      <div class="margin1 centralize" style="margin: 5%;">
        <q-file
          rounded
          standout
          bg-color="primary"
          v-model="documento_upload"
          label="Clique aqui para adicionar o documento"
        >
          <template v-slot:prepend> <q-icon name="attach_file" /> </template
        ></q-file>
      </div>
    </div>
    <div align="right">
      <transition name="slide-fade">
        <q-btn
          v-if="linha_doc"
          rounded
          class="margin1"
          icon="download"
          color="primary"
          label="Baixar"
          :loading="uploading_load"
          @click="onDownloadDoc()"
        >
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            <strong>Baixar documento</strong>
          </q-tooltip>
        </q-btn>
      </transition>
      <transition name="slide-fade">
        <q-btn
          v-if="linha_doc"
          rounded
          class="margin1"
          icon="delete"
          color="negative"
          label="Excluir"
          :loading="uploading_load"
          @click="deletaDoc()"
        >
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            <strong>Excluir documento</strong>
          </q-tooltip>
        </q-btn>
      </transition>
      <q-btn
        rounded
        class="margin1"
        icon="check"
        color="positive"
        label="Confirmar"
        :loading="uploading_load"
        @click="onUploadDoc()"
      >
        <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
          <strong>Confirmar</strong>
        </q-tooltip>
      </q-btn>
      <q-btn
        rounded
        icon="close"
        color="negative"
        class="margin1"
        label="Fechar"
        v-close-popup
      >
        <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
          <strong>Fechar</strong>
        </q-tooltip>
      </q-btn>
    </div>
    <!-- Se for Card (Antigamente era Propostas (Consulta)) -->
    <div v-if="this.documento_json.cd_movimento">
      <grid
        class="margin1"
        :cd_menuID="7803"
        :cd_apiID="562"
        :att_json="att_grid_doc"
        :cd_parametroID="0"
        @linha="linhaDoc($event)"
        :nm_json="{
          cd_parametro: 20,
          cd_consulta: this.cd_documentoID,
          cd_modulo: this.cd_modulo,
          cd_etapa: this.documento_json.cd_etapa,
          cd_usuario: this.cd_usuario
        }"
        :masterDetail="false"
      />
    </div>
    <!-- Modulo_Etapa_Documento (Geral por cliente) -->
    <div v-if="!this.documento_json.cd_movimento">
      <grid
        class="margin1"
        :cd_menuID="7304"
        :cd_apiID="606"
        :att_json="att_grid_doc_geral"
        :cd_parametroID="0"
        @linha="linhaDoc($event)"
        :nm_json="{
          cd_parametro: 1,
          cd_movimento: this.cd_documentoID,
          cd_etapa: this.documento_json.cd_etapa,
          cd_usuario: this.cd_usuario
        }"
        :masterDetail="false"
      />
    </div>
  </div>
</template>

<script>
import axios from "axios";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";

export default {
  components: {
    grid: () => import("../views/grid.vue"),
  },
  props: {
    // eslint-disable-next-line vue/require-valid-default-prop
    documento_json: { type: Object, default: {} },
    nm_origem: { type: String, default: "Propostas" },
    cd_documentoID: { type: Number, default: 0 },
    Fantasia: { type: String, default: "" },
  },
  data() {
    return {
      documento_upload: [],
      linha_doc: {},
      api: "562/781", // Procedimento 1439 - pr_egisnet_elabora_proposta
      api_geral: "606/844", //pr_egisnet_crud_documentos
      uploading_load: false,
      att_grid_doc: false,
      att_grid_doc_geral: false,
      cd_usuario: localStorage.cd_usuario,
      cd_modulo: localStorage.cd_modulo,
    };
  },

  methods: {
    linhaDoc(e) {
      this.linha_doc = e;
    },
    async onUploadDoc() {
      if (this.documento_upload.size !== undefined) {
        this.uploading_load = true;
        let extArq = this.documento_upload.name.split(".");
        let ds_consulta_documento_download = `${localStorage.cd_empresa}-${
          localStorage.cd_modulo
        }-${localStorage.cd_usuario}-${this.cd_documentoID}-${Date.now()}.${
          extArq[1]
        }`;
        const formData = new FormData();
        formData.append("file", this.documento_upload);
        formData.append("nm_documento", ds_consulta_documento_download);
        formData.append("cd_empresa", localStorage.cd_empresa);
        formData.append("cd_usuario", localStorage.cd_usuario);
        formData.append("cd_cliente", localStorage.cd_cliente);
        formData.append("nm_ftp_empresa", localStorage.nm_ftp_empresa);
        formData.append("nm_pasta_ftp", this.documento_json.nm_pasta_ftp);
        const options = {
          method: "POST",
          url: "https://egis-store.com.br/api/upload",
          headers: {
            "Content-Type": "multipart/form-data", // Define o tipo de conteúdo como multipart/form-data
          },
          data: formData, // Define o corpo da requisição como o objeto FormData
        };
        axios(options)
          .then(async () => {
            ////Salva o caminho do documento na Proposta (Consulta)
            // if (this.nm_origem === "Propostas") {
            //   let json_salva_doc = {
            //     cd_parametro: 21,
            //     cd_consulta: this.cd_documentoID,
            //     nm_caminho_documento: this.documento_upload.name,
            //     ds_consulta_documento: ds_consulta_documento_download,
            //     cd_usuario: this.cd_usuario,
            //   };
            //   let [doc_inserido] = await Incluir.incluirRegistro(
            //     this.api, //pr_egisnet_elabora_proposta
            //     json_salva_doc,
            //   );
            //   notify(doc_inserido.Msg);
            //   this.documento_upload = [];
            // } else {
              ////Salva o caminho do documento na tabela geral
              let json_salva_doc = {
                cd_parametro: 4,
                nm_documento: this.documento_upload.name,
                ds_documento: this.documento_upload.name,
                cd_usuario: this.cd_usuario,
                cd_modulo: localStorage.cd_modulo,
                //cd_tipo_documento: this.cd_tipo_documento,
                cd_etapa: this.documento_json.cd_etapa,
                cd_movimento: this.documento_json.cd_movimento,
                cd_documento: this.documento_json.cd_documento,
                //nm_caminho_documento: this.nm_caminho_documento,
                //nm_documento_interno: this.nm_documento_interno,
              };
              let [doc_inserido] = await Incluir.incluirRegistro(
                this.api_geral, //pr_egisnet_crud_documentos
                json_salva_doc,
              );
              notify(doc_inserido.Msg);
              this.documento_upload = [];
            //}
          })
          .catch((error) => {
            // eslint-disable-next-line no-console
            console.error("Erro:", error);
            notify("Não foi possível salvar o documento");
          })
          .finally(() => {
            this.uploading_load = false;
            this.att_grid_doc = !this.att_grid_doc; //Atualiza a grid de documento
            this.att_grid_doc_geral = !this.att_grid_doc_geral; //Atualiza a grid de documento
          });
      } else {
        notify("Selecione um documento para salvar");
      }
    },
    async deletaDoc() {
      try {
        //Remove o arquivo do FTP e do servidor
        const options = {
          method: "DELETE",
          url: `https://egis-store.com.br/api/removeDoc/${localStorage.nm_ftp_empresa}/${this.documento_json.nm_pasta_ftp}/${this.linha_doc.nm_caminho_documento}`,
        };
        axios(options)
          .then(async () => {
              notify("Documento excluído com sucesso");
          })
          .catch((error) => {
            // eslint-disable-next-line no-console
            console.error("Erro:", error);
            notify("Não foi possível excluir o documento");
          })
          ///////////////////////////////
        if (this.nm_origem === "Propostas") {
          let json_exclui_doc = {
            cd_parametro: 22,
            cd_consulta: this.cd_documentoID,
            cd_consulta_documento: this.linha_doc.cd_consulta_documento,
            cd_usuario: this.cd_usuario,
          };
          let [doc_excluido] = await Incluir.incluirRegistro(
            this.api,
            json_exclui_doc,
          );
          notify(doc_excluido.Msg);
        } else {
          let json_exclui_doc = {
            cd_parametro: 2,
            cd_interno: this.linha_doc.cd_interno,
            cd_usuario: this.cd_usuario,
          };
          let [doc_excluido] = await Incluir.incluirRegistro(
            this.api_geral, //pr_egisnet_crud_documentos
            json_exclui_doc,
          );
          notify(doc_excluido.Msg);
        }
        this.documento_upload = [];
        this.att_grid_doc = !this.att_grid_doc; //Atualiza a grid de documento
        this.att_grid_doc_geral = !this.att_grid_doc_geral; //Atualiza a grid de documento
      } catch (error) {
        notify("Não foi possível excluir o documento!");
      }
    },
    async onDownloadDoc() {
      const options = {
        method: "GET",
        responseType: "blob",
        url: `https://egis-store.com.br/api/download/${this.linha_doc.nm_caminho_documento}/${localStorage.nm_ftp_empresa}/${this.documento_json.nm_pasta_ftp}`,
      };
      axios(options)
        .then((response) => {
          const blob = new Blob([response.data], {
            type: "application/octet-stream",
          });
          const url = window.URL.createObjectURL(blob);
          const link = document.createElement("a");
          link.href = url;
          link.download = this.linha_doc.nm_caminho_documento;
          document.body.appendChild(link);
          link.click();
          window.URL.revokeObjectURL(url);
        })
        .catch((error) => {
          // eslint-disable-next-line no-console
          console.error("Erro:", error);
        });
    },
  },
};
</script>

<style scoped>
@import url("../views/views.css");
</style>
