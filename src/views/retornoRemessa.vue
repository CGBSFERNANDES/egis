<!-- eslint-disable no-console -->
<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center">
      <transition name="slide-fade">
        <h2 class="content-block col-8" v-show="tituloMenu">
          {{ tituloMenu }}
        </h2>
      </transition>
    </div>
    <div
      class="margin1"
      style="display: flex; align-items: center; justify-content: center"
    >
      <q-btn
        rounded
        color="orange-9"
        text-color="white"
        size="lg"
        label="Retorno da remessa"
      />
    </div>
    <div class="text-h5 text-bold margin1">
      <q-badge v-if="prop_form.cd_movimento" align="top" color="blue">
        {{ prop_form.cd_movimento }}
      </q-badge>
    </div>
    <div class="row">
      <q-select
        dense
        use-input
        hide-selected
        fill-input
        class="metadeTela margin1"
        label="Arquivo de Retorno"
        v-model="importacao"
        input-debounce="0"
        :loading="load_grid"
        :options="dados_lookup_importacao"
        option-value="cd_conta_banco"
        option-label="nm_conta_banco"
      >
        <template v-slot:prepend>
          <q-icon name="publish" />
        </template>
      </q-select>
      <q-file
        v-if="importacao"
        dense
        use-input
        hide-selected
        fill-input
        class="metadeTela margin1 col-5"
        v-model="arq_upload"
        :loading="load_grid"
        label="Selecionar Arquivo"
        accept=".txt"
        hint="Apenas arquivos .txt"
        @input="onFile($event)"
      >
        <template v-slot:prepend>
          <q-icon name="description" />
        </template>
      </q-file>
    </div>
    <!--  -->
    <div class="margin1">
      <q-btn
        rounded
        label="Processar"
        type="submit"
        color="orange-9"
        icon="save"
        :loading="load_importar"
        @click="onSalvarRegistro"
      />
      <q-btn
        rounded
        label="Limpar"
        type="reset"
        color="orange-9"
        flat
        class="q-ml-sm"
        icon="cleaning_services"
        @click="onLimparRegistro"
      />
      <q-btn
        rounded
        label="Fechar"
        type="reset"
        color="orange-9"
        flat
        class="q-ml-sm"
        icon="close"
        @click="onFechar"
      />
    </div>
    <!-- Div para exibir o conteúdo simples do arquivo -->
    <div v-if="fileContent" class="margin1">
      <q-card class="q-pa-md">
        <q-card-section>
          <div class="text-h6 q-mb-md">Conteúdo do Arquivo</div>
          <div class="file-content-container">
            <pre class="file-content">{{ fileContent }}</pre>
          </div>
        </q-card-section>
      </q-card>
    </div>
    <!--------SOLICITAÇÃO DE SENHA---------------------------------------------------------------------------->
    <q-dialog v-model="pop_senha" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Insira a senha</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            label="Senha"
            dense
            v-model="nm_senha"
            :type="isPwd ? 'password' : 'text'"
            autofocus
            @keyup.enter="confirmaSenha()"
          >
            <template v-slot:append>
              <q-icon
                :name="isPwd ? 'visibility_off' : 'visibility'"
                class="cursor-pointer"
                @click="isPwd = !isPwd"
              />
            </template>
          </q-input>
        </q-card-section>

        <q-card-actions align="right" class="text-white">
          <q-btn
            rounded
            color="orange-9"
            class="q-ml-sm"
            icon="check"
            label="Confirmar"
            @click="confirmaSenha()"
          />
          <q-btn
            rounded
            color="orange-9"
            flat
            class="q-ml-sm"
            icon="close"
            label="Fechar"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!--------VALIDAÇÃO IMPORTAÇÃO PROCEDURE---------------------------------------------------------------------------->
    <q-dialog v-model="ic_alerta" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <q-avatar icon="warning" color="warning" text-color="white" />
          <div class="text-h6">Alerta</div>
        </q-card-section>
        <q-card-section class="q-pt-none listNotImport">
          <p>{{ `${msg_alerta}` }}</p>
        </q-card-section>

        <q-card-actions align="right" class="text-white">
          <q-btn
            rounded
            color="orange-9"
            flat
            class="q-ml-sm"
            icon="close"
            label="Fechar"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------------------------------>
  </div>
</template>

<script>
import "devextreme-vue/text-area";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import Menu from "../http/menu";

export default {
  props: {
    cd_formID: { type: Number, default: 0 },
    cd_documentoID: { type: Number, default: 0 },
    cd_item_documentoID: { type: Number, default: 0 },
    prop_form: {
      type: Object,
      default() {
        return {};
      },
    },
  },
  name: "retornoRemessa",
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_menu: localStorage.cd_menu,
      cd_api: localStorage.cd_api,
      cd_modulo: localStorage.cd_modulo,
      dados: [],
      jsonData: [],
      columns: [],
      dados_lookup_importacao: [],
      importacao: "",
      arq_upload: [],
      isPwd: false,
      ic_alerta: false,
      tituloMenu: "",
      msg_alerta: "",
      pop_senha: false,
      nm_senha: "",
      senhaAutorizada: false,
      api: "944/1457",
      load: false,
      load_grid: false,
      load_importar: false,
      fileContent: "", // Conteúdo simples do arquivo
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    await this.carregaDados();
  },

  async mounted() {
    try {
      this.load = true;
      let carregaDataSouce = {
        cd_parametro: 1,
      };
      this.dados_lookup_importacao = await Incluir.incluirRegistro(
        this.api,
        carregaDataSouce
      ); //pr_egis_geracao_retorno_banco
      this.load = false;
    } catch (error) {
      this.load = false;
    }
  },
  methods: {
    async carregaDados() {
      await this.showMenu();
    },
    async showMenu() {
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;

      const dados = await Menu.montarMenu(
        this.cd_empresa,
        this.cd_menu,
        this.cd_api
      );

      this.tituloMenu = dados.nm_menu_titulo;
    },
    async onSalvarRegistro() {
      try {
        if (this.importacao) {
          let json_importacao = {
            dados_arquivo: this.fileContent,
            cd_usuario: localStorage.cd_usuario,
            cd_empresa: this.cd_empresa,
          };
          try {
            await Incluir.incluirRegistro(this.api, json_importacao); //pr_egis_geracao_retorno_banco
            this.onFechar(json_importacao);
            notify("Remessa gerada com sucesso");
          } catch (error) {
            notify("Não foi possivel gerar a remessa");
          }
        } else {
          notify("Selecione um modelo de arquivo para remessa");
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
      } finally {
        this.load_importar = false;
      }
      return;
    },

    onLimparRegistro() {
      this.importacao = "";
      this.jsonData = [];
      this.arq_upload = [];
      this.fileContent = "";
    },
    onFechar() {
      this.onLimparRegistro();
      this.$emit("click");
    },
    async onFile(file) {
      try {
        this.columns = [];
        this.jsonData = [];
        this.fileContent = ""; // Limpa o conteúdo anterior
        this.load_grid = true;

        const reader = new FileReader();
        reader.onload = (e) => {
          const text = e.target.result;
          // Armazena o conteúdo simples do arquivo
          this.fileContent = text;
          // Divide o texto em linhas
          const lines = text.split(/\r?\n/).filter((l) => l.trim() !== "");
          // Se quiser mostrar cada linha como um item
          this.columns = ["linha"];
          this.jsonData = lines.map((linha, idx) => ({
            cd_controle: idx + 1,
            linha,
          }));
          this.load_grid = false;
        };
        reader.onerror = () => {
          notify("Erro ao ler o arquivo .txt");
          this.load_grid = false;
        };

        reader.readAsText(file);
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
        notify("Erro ao processar o arquivo .txt");
        this.load_grid = false;
      }
    },
    async confirmaSenha() {
      if (this.nm_senha === this.importacao.cd_senha_acesso) {
        this.pop_senha = false;
        this.senhaAutorizada = true;
        await this.onSalvarRegistro();
      } else {
        notify("Senha incorreta!");
      }
    },
  },
};
</script>

<style scoped>
@import url("../views/views.css");

.listNotImport {
  font-weight: bold;
}

.file-content-container {
  max-height: 400px;
  overflow-y: auto;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  background-color: #f5f5f5;
}

.file-content {
  margin: 0;
  padding: 16px;
  font-family: "Courier New", monospace;
  font-size: 12px;
  line-height: 1.4;
  white-space: pre-wrap;
  word-wrap: break-word;
  background-color: #f5f5f5;
  color: #333;
}
</style>
