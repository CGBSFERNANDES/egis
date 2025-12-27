<template>
  <div>
    <q-expansion-item
      class="overflow-hidden margin1 bg-white shadow-1"
      style="border-radius: 20px; height: auto"
      icon="public"
      default-opened
      :label="tituloMenu"
      :header-class="'bg-' + corID + ' text-white items-center text-h6'"
      expand-icon-class="text-white"
    >
      <div class="row items-center header">
        <!--<h4 class="content-block margin1">{{ tituloMenu }}</h4>-->
        <div
          class="text-bold margin1"
          v-if="
            this.updating == true && this.tabs == '1' && !!this.cd_cep == true
          "
        >
          {{ line.cd_cep_cliente.trim() }} -
          {{ line.nm_endereco_cliente.trim() }} -
          {{ "N° " + line.cd_numero_endereco.trim() }} -
          {{ line.nm_bairro_cliente.trim() }} - {{ line.nm_cidade.trim() }}/{{
            line.sg_estado.trim()
          }}
        </div>
        <q-space />
        <div class="margin1 header">
          <q-btn
            v-if="ic_novo_endereco == false"
            rounded
            :color="corID"
            flat
            label="Novo"
            icon="add"
            @click="AddAdress"
          />

          <q-btn
            v-else
            round
            flat
            :color="corID"
            icon="undo"
            @click="
              ic_novo_endereco = false;
              tabs = '0';
            "
          />
        </div>
      </div>
      <q-tabs
        v-model="tabs"
        inline-label
        mobile-arrows
        align="justify"
        style="border-radius: 20px"
        :class="'margin1 text-white bg-' + corID"
      >
        <q-tab name="0" icon="pin_drop" label="Endereços" />
        <q-tab name="1" icon="edit" label="Edição" />
      </q-tabs>

      <q-tab-panels v-model="tabs" animated>
        <q-tab-panel name="0">
          <dx-data-grid
            v-if="consulta_endereco.length > 0"
            class="dx-card wide-card margin1"
            id="grid-endereco"
            :data-source="consulta_endereco"
            :columns="colunaEndereco"
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
            :cacheEnable="false"
            @selection-Changed="ChangeLine"
            @row-removed="DeleteAdress($event)"
          >
            <DxEditing
              :allow-updating="false"
              :allow-adding="false"
              :allow-deleting="true"
              mode="batch"
            />
            <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
            <DxGrouping :auto-expand-all="true" />
            <DxPaging :page-size="10" />
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
              :allowed-page-sizes="[10, 20, 50, 100]"
              :show-info="true"
            />
            <DxFilterRow :visible="false" />
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
            <DxFilterPanel :visible="true" />
            <DxColumnFixing :enabled="false" />
            <DxColumnChooser :enabled="true" mode="select" />
          </dx-data-grid>
          <div class="text-h6 text-center" v-else>
            Nenhum endereço cadastrado!
          </div>
        </q-tab-panel>

        <q-tab-panel name="1" style="padding: 2.5px">
          <div class="row items-center justify-around">
            <q-select
              class="margin1 quatro-tela"
              option-value="cd_tipo_endereco"
              option-label="nm_tipo_endereco"
              :loading="loadingCEP"
              v-model="tipo_endereco"
              :color="corID"
              :disable="updating"
              :options="datasetTipoEndereco"
              label="Tipo de Endereço"
            >
              <template v-slot:prepend>
                <q-icon name="format_list_bulleted"></q-icon>
              </template>
            </q-select>

            <q-input
              class="margin1 quatro-tela"
              @blur="SearchCEP()"
              :color="corID"
              :loading="loadingCEP"
              mask="#####-###"
              v-model="cd_cep"
              label="CEP"
            >
              <template v-slot:prepend>
                <q-icon name="badge"></q-icon>
              </template>
            </q-input>
            <q-select
              class="margin1 quatro-tela"
              option-value="cd_pais"
              option-label="nm_pais"
              v-model="pais"
              @input="FilterPais()"
              :color="corID"
              :options="dataset_pais"
              :loading="loadingCEP"
              label="País"
            >
              <template v-slot:prepend>
                <q-icon name="public"></q-icon>
              </template>
            </q-select>
            <q-select
              class="margin1 quatro-tela"
              option-value="cd_estado"
              option-label="sg_estado"
              v-model="estado"
              @input="FilterUF()"
              :color="corID"
              :options="dataset_estado"
              :loading="loadingCEP"
              label="Estado"
            >
              <template v-slot:prepend>
                <q-icon name="map"></q-icon>
              </template>
            </q-select>
          </div>
          <div class="row items-center justify-around">
            <q-select
              class="margin1 quatro-tela"
              option-value="cd_cidade"
              option-label="nm_cidade"
              v-model="cidade"
              :color="corID"
              :options="dataset_cidade"
              :loading="loadingCEP"
              label="Cidade"
            >
              <template v-slot:prepend>
                <q-icon name="my_location"></q-icon>
              </template>
            </q-select>
            <q-input
              class="margin1 quatro-tela"
              :color="corID"
              :loading="loadingCEP"
              v-model="logradouro"
              label="Logradouro"
            >
              <template v-slot:prepend>
                <q-icon name="person_pin_circle"></q-icon>
              </template>
            </q-input>
            <q-input
              class="margin1 quatro-tela"
              :color="corID"
              :loading="loadingCEP"
              v-model="bairro"
              label="Bairro"
            >
              <template v-slot:prepend>
                <q-icon name="location_on"></q-icon>
              </template>
            </q-input>
            <q-input
              class="margin1 quatro-tela"
              :color="corID"
              :loading="loadingCEP"
              v-model="numero"
              type="number"
              min="0"
              label="Número"
            >
              <template v-slot:prepend>
                <q-icon name="where_to_vote"></q-icon>
              </template>
            </q-input>
          </div>

          <div class="row items-center justify-around">
            <q-input
              class="margin1 tres-tela"
              :color="corID"
              :loading="loadingCEP"
              v-model="complemento"
              autogrow
              label="Complemento"
            >
              <template v-slot:prepend>
                <q-icon name="description"></q-icon>
              </template>
            </q-input>
            <q-input
              class="margin1 tres-tela"
              :color="corID"
              :loading="loadingCEP"
              v-model="referencia"
              autogrow
              label="Ponto de Referência"
            >
              <template v-slot:prepend>
                <q-icon name="psychology_alt"></q-icon>
              </template>
            </q-input>

            <q-input
              class="margin1 tres-tela"
              :color="corID"
              :loading="loadingCEP"
              v-model="telefone"
              mask="(##) ####-####"
              label="Telefone"
            >
              <template v-slot:prepend>
                <q-icon name="call"></q-icon>
              </template>
            </q-input>
          </div>
          <div class="row items-center">
            <q-btn
              rounded
              class="margin1"
              label="Salvar"
              :color="corID"
              icon="check"
              @click="SendAdress(updating)"
            />
            <q-space />
            <q-btn
              rounded
              class="margin1"
              label="Cancelar"
              :color="corID"
              icon="close"
              @click="
                ClearAll();
                tabs = '0';
              "
            />
          </div>
        </q-tab-panel>
      </q-tab-panels>

      <!--Loading Tela-------------------------------------------------------------------->
      <q-dialog v-model="load" maximized persistent>
        <carregando
          :mensagemID="mensagemCarregando"
          :corID="corID"
        ></carregando>
      </q-dialog>
    </q-expansion-item>
  </div>
</template>

<script>
import Incluir from "../http/incluir_registro";
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import notify from "devextreme/ui/notify";
import Lookup from "../http/lookup";
import funcao from "../http/funcoes-padroes";
import Menu from "../http/menu";
import {
  DxDataGrid,
  DxColumn,
  DxExport,
  DxPaging,
  DxEditing,
  DxSelection,
  DxLookup,
} from "devextreme-vue/data-grid";
import {
  DxColumnChooser,
  DxGrouping,
  DxGroupPanel,
  DxPager,
  DxSearchPanel,
  DxHeaderFilter,
  DxFilterPanel,
  DxStateStoring,
  DxFilterRow,
  DxColumnFixing,
} from "devextreme-vue/data-grid";
import ptMessages from "devextreme/localization/messages/pt.json";

export default {
  name: "cliente_endereco",
  props: {
    cd_cliente: { type: Number, default: 0 },
    corID: { type: String, default: "primary" },
  },
  components: {
    carregando: () => import("../components/carregando.vue"),
    DxColumnChooser,
    DxGrouping,
    DxGroupPanel,
    DxPager,
    DxSearchPanel,
    DxHeaderFilter,
    DxFilterPanel,
    DxStateStoring,
    DxFilterRow,
    DxColumnFixing,
    DxDataGrid,
    DxColumn,
    DxExport,
    DxPaging,
    DxEditing,
    DxSelection,
    DxLookup,
  },
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      tituloMenu: "Cadastro de Endereço",
      api_endereco: "472/666", // Procedimento 1345 - pr_egisnet_cadastra_cliente
      carregando: false,
      tabs: "0",
      consulta_endereco: [],
      colunaEndereco: [],
      load: false,
      mensagemCarregando: "Aguarde...",
      cd_cep: "",
      logradouro: "",
      ic_novo_endereco: false,
      tipo_endereco: [],
      updating: false,
      datasetTipoEndereco: [],
      loadingCEP: false,
      dataset_cidade: [],
      dataset_estado: [],
      numero: "",
      complemento: "",
      cidade: "",
      telefone: "",
      referencia: "",
      line: {},
      datasetCidadeOrigem: [],
      datasetPaisOrigem: [],
      cd_identifica_cep: "",
      datasetEstadoOrigem: [],
      estado: "",
      dataset_pais: [],
      pais: "",
      bairro: "",
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    this.loadingCEP = true;
    let d = await Menu.montarMenu(this.cd_empresa, 7453, 400);
    this.colunaEndereco = JSON.parse(JSON.parse(JSON.stringify(d.coluna)));
    await this.CarregaDados();

    let tipoEnd = await Lookup.montarSelect(this.cd_empresa, 117);
    this.datasetTipoEndereco = JSON.parse(
      JSON.parse(JSON.stringify(tipoEnd.dataset))
    );
    let pais = await Lookup.montarSelect(this.cd_empresa, 492);
    this.dataset_pais = JSON.parse(JSON.parse(JSON.stringify(pais.dataset)));
    this.datasetPaisOrigem = this.dataset_pais;

    let est = await Lookup.montarSelect(this.cd_empresa, 96);
    this.dataset_estado = JSON.parse(JSON.parse(JSON.stringify(est.dataset)));
    this.datasetEstadoOrigem = this.dataset_estado;

    let cid = await Lookup.montarSelect(this.cd_empresa, 97);
    this.dataset_cidade = JSON.parse(JSON.parse(JSON.stringify(cid.dataset)));
    this.datasetCidadeOrigem = this.dataset_cidade;

    this.tipo_endereco = {
      cd_tipo_endereco: 1,
      nm_tipo_endereco: "Único",
    };
    this.loadingCEP = false;
    if (this.cd_cliente == 0) return;
  },
  watch: {
    async tabs() {
      if (this.tabs == "0") {
        this.ic_novo_endereco = false;
        this.ClearAll();
        //await funcao.sleep(500);
        await this.CarregaDados();
      } else if (this.tabs == "1" && !!this.line.cd_cliente == true) {
        this.updating = true;
        this.cd_cep = this.line.cd_cep_cliente.trim();
        this.pais = {
          cd_pais: this.line.cd_pais,
          nm_pais: this.line.nm_pais,
        };
        this.estado = {
          cd_estado: this.line.cd_estado,
          sg_estado: this.line.sg_estado,
        };
        this.cidade = {
          cd_cidade: this.line.cd_cidade,
          nm_cidade: this.line.nm_cidade.trim(),
        };
        this.logradouro = this.line.nm_endereco_cliente;
        this.bairro = this.line.nm_bairro_cliente;
        this.numero = parseFloat(this.line.cd_numero_endereco.trim());
        this.complemento = this.line.nm_complemento_endereco;
        this.referencia = this.line.nm_ponto_ref_cli_endereco;
        this.telefone =
          "(" +
          this.line.cd_ddd_cliente.trim() +
          ")" +
          this.line.cd_telefone_cliente.trim();
      }
    },
  },
  methods: {
    async DeleteAdress(e) {
      let ex = {
        cd_parametro: 5,
        cd_cliente: e.data.cd_cliente,
        cd_tipo_endereco: e.data.cd_tipo_endereco,
      };
      let exclusion = await Incluir.incluirRegistro(this.api_endereco, ex);
      notify(exclusion[0].Msg);
    },
    async SendAdress(method) {
      // method => True = Update.
      // method => False = Insert.
      let s = {
        cd_parametro: 4,
        cd_cliente: this.cd_cliente,
        cd_tipo_endereco: this.tipo_endereco.cd_tipo_endereco,
        cd_cep: this.cd_cep,
        cd_pais: this.pais.cd_pais,
        cd_estado: this.estado.cd_estado,
        cd_cidade: this.cidade.cd_cidade,
        nm_endereco_cliente: funcao.ValidaString(this.logradouro),
        nm_bairro_cliente: funcao.ValidaString(this.bairro),
        cd_numero_endereco: this.numero,
        nm_complemento_endereco: funcao.ValidaString(this.complemento),
        nm_ponto_ref_cli_endereco: funcao.ValidaString(this.referencia),
        cd_identifica_cep: this.cd_identifica_cep,
        cd_usuario: this.cd_usuario,
        cd_empresa: this.cd_empresa,
        cd_telefone: this.telefone,
      };
      if (method == false) {
        let conferencia = await this.Validation();
        if (conferencia == false) return;

        let send = await Incluir.incluirRegistro(this.api_endereco, s);
        if (send[0].Cod == 0) {
          notify(send[0].Msg);
          return;
        } else {
          notify(send[0].Msg);
          this.tabs = "0";
          this.ClearAll();
        }
      } else {
        let conferencia = await this.Validation();
        if (conferencia == false) return;
        s.cd_parametro = 6;
        let send = await Incluir.incluirRegistro(this.api_endereco, s);
        notify(send[0].Msg);
        this.line = {};
        this.ClearAll();
        this.tabs = "0";
      }
    },
    async Validation() {
      //Validação dos campos para envio do JSON.
      let ret = true;
      if (!!this.tipo_endereco.cd_tipo_endereco == false) {
        notify("Selecione o tipo do endereço!");
        ret = false;
        return ret;
      } else if (this.cd_cep.length != 9) {
        notify("Digite o CEP completo!");
        ret = false;
        return ret;
      } else if (!!this.pais.cd_pais == false) {
        notify("Selecione o País!");
        ret = false;
        return ret;
      } else if (!!this.estado.cd_estado == false) {
        notify("Selecione o Estado!");
        ret = false;
        return ret;
      } else if (!!this.cidade.cd_cidade == false) {
        notify("Selecione a Cidade!");
        ret = false;
        return ret;
      } else if (this.logradouro == "") {
        notify("Digite o Logradouro");
        ret = false;
        return ret;
      } else if (this.bairro == "") {
        notify("Digite o Bairro!");
        ret = false;
        return ret;
      } else if (this.numero == "" || this.numero == 0) {
        notify("Digite o Número!");
        ret = false;
        return ret;
      } else {
        ret = true;
        return ret;
      }
    },
    async FilterPais() {
      this.dataset_estado = this.datasetEstadoOrigem;
      this.estado = "";
      this.dataset_estado = this.dataset_estado.filter((e) => {
        return e.cd_pais == this.pais.cd_pais;
      });
    },
    async FilterUF() {
      this.dataset_cidade = this.datasetCidadeOrigem;
      this.cidade = "";
      this.dataset_cidade = this.dataset_cidade.filter((e) => {
        return e.cd_estado == this.estado.cd_estado;
      });
    },
    async SearchCEP() {
      if (this.cd_cep.length != 9) return;
      this.loadingCEP = true;
      let busca = await funcao.buscaCep(this.cd_cep);
      if (!!busca[0].cd_cep == false) {
        this.loadingCEP = false;
        notify("Cep não encontrado");
        return;
      }
      this.cidade = {
        cd_cidade: busca[0].cd_cidade,
        nm_cidade: busca[0].localidade,
      };
      this.estado = {
        cd_estado: busca[0].cd_estado,
        sg_estado: busca[0].uf,
      };
      this.cd_identifica_cep = busca[0].cd_identifica_cep;
      let f = this.dataset_pais.filter((e) => {
        return e.cd_pais == busca[0].cd_pais;
      });
      this.pais = {
        cd_pais: f[0].cd_pais,
        nm_pais: f[0].nm_pais,
      };
      this.logradouro = busca[0].logradouro;
      this.bairro = busca[0].bairro;
      this.loadingCEP = false;
    },
    async ClearAll() {
      this.cd_cep = "";
      this.pais = "";
      this.estado = "";
      this.cidade = "";
      this.logradouro = "";
      this.bairro = "";
      this.numero = "";
      this.complemento = "";
      this.referencia = "";
      this.telefone = "";
      this.line = {};
      this.tipo_endereco = {
        cd_tipo_endereco: 1,
        nm_tipo_endereco: "Único",
      };

      this.dataset_cidade = this.datasetCidadeOrigem;
      this.dataset_estado = this.datasetEstadoOrigem;
      this.dataset_pais = this.datasetPaisOrigem;
    },
    async AddAdress() {
      await this.ClearAll();
      this.tabs = "1";
      this.ic_novo_endereco = true;
      this.line = {};
      this.updating = false;
    },
    async CarregaDados() {
      this.mensagemCarregando = "Buscando endereços...";
      this.load = true;
      let consulta;
      let c = {
        cd_parametro: 3,
        cd_cliente: this.cd_cliente,
      };
      try {
        consulta = await Incluir.incluirRegistro(this.api_endereco, c);
      } catch (error) {
        this.load = false;
      }
      if (consulta[0].Cod == 0) {
        this.load = false;
        notify(consulta[0].Msg);
        this.consulta_endereco = [];
        return;
      }
      this.consulta_endereco = consulta;
      this.load = false;
    },
    async ChangeLine({ selectedRowKeys, selectedRowsData }) {
      this.line = selectedRowsData[0];
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: none;
}
.tres-tela {
  width: 31%;
}
.duas-tela {
  width: 47%;
}
.quatro-tela {
  width: 22%;
}
.grid-endereco {
  height: 70vh;
}
@media (max-width: 900px) {
  .duas-tela {
    width: 100%;
  }

  .tres-tela {
    width: 100%;
  }

  .quatro-tela {
    width: 100%;
  }
  .header {
    width: 100%;
    text-align: center;
    align-items: center;
  }
}
</style>
