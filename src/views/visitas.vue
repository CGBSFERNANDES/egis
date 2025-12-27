<template>
  <div>
    <div class="margin1 top-header">
      <h2 style="margin-bottom: 0px" class="content-block">{{ tituloMenu }}</h2>
      <!-- <div>
        <q-btn-dropdown rounded color="primary" label="Cor" icon="palette">
          <q-color v-model="colorID" />
        </q-btn-dropdown>
      </div> -->
    </div>

    <q-tabs
      v-model="selectedIndex"
      inline-label
      mobile-arrows
      align="justify"
      style="border-radius: 20px"
      class="text-white shadow-2 margin1 bg-orange-9"
      @input="onTrocaTab(selectedIndex)"
    >
      <q-tab :name="0" icon="description" label="Dados" />
      <q-tab :name="1" icon="person" label="Visita" />
    </q-tabs>

    <div v-show="this.selectedIndex == 0">
      <div style="margin: 0px 5px 20px 10px">
        <q-btn
          class="margin1"
          rounded
          color="primary"
          icon="add"
          label="Novo"
          @click="onNovoRegistro()"
        >
          <q-tooltip> Agendar nova visita </q-tooltip>
        </q-btn>
        <transition name="slide-fade">
          <q-btn
            v-if="this.cd_visita != ''"
            class="margin1"
            rounded
            color="red"
            icon="close"
            label="Cancelar"
            @click="onInicioCancelamento"
          >
            <q-tooltip> Cancelar visita </q-tooltip>
          </q-btn>
        </transition>
      </div>

      <q-dialog v-model="popup_cancelamento">
        <q-card style="width: 700px; max-width: 80vw">
          <q-card-section>
            <div class="text-h6">Cancelamento de Visita</div>
          </q-card-section>
          <q-separator />
          <q-card-section>
            <q-select
              class="col espaco-interno"
              label="Motivo"
              :color="colorID"
              v-model="motivo_cancelamento"
              :options="this.dataset_lookup_cancelamento"
              option-value="cd_cancelamento_visita"
              option-label="nm_cancelamento_visita"
            />
          </q-card-section>

          <q-card-actions align="right">
            <q-btn
              rounded
              color="primary"
              label="Confirmar"
              @click="onEnviarCancelamento()"
              v-close-popup
            />
            <q-btn rounded label="Cancelar" color="red" v-close-popup />
          </q-card-actions>
        </q-card>
      </q-dialog>

      <div v-if="dataSourceConfig.length == 0" class="row">
        <q-spinner-facebook class="col margin1" color="orange-9" size="6em" />
        <q-tooltip :offset="[0, 8]">Carregando...</q-tooltip>
      </div>
      <dx-data-grid
        v-else
        class="dx-card wide-card"
        id="grid"
        :data-source="dataSourceConfig"
        key-expr="cd_controle"
        :show-borders="true"
        :column-auto-width="true"
        :column-hiding-enabled="false"
        :selection="{ mode: 'single' }"
        :word-wrap-enabled="false"
        :allow-column-reordering="true"
        :allow-column-resizing="true"
        :row-alternation-enabled="true"
        :repaint-changes-only="true"
        :autoNavigateToFocusedRow="false"
        :focused-row-enabled="true"
        :cacheEnable="false"
        ref="grid_consulta"
        :selected-row-key="focusedRow"
        @selection-changed="RowSelected"
      >
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
          :allowed-page-sizes="pageSizes"
          :show-info="true"
        />
        <DxFilterRow :visible="false" />
        <DxHeaderFilter :visible="true" :allow-search="true" />
        <DxSearchPanel
          :visible="temPanel"
          :width="300"
          placeholder="Procurar..."
        />
        <DxFilterPanel :visible="true" />
        <DxColumnFixing :enabled="true" />
        <DxColumnChooser :enabled="true" mode="select" />
        <DxForm :form-data="formData" :items="items">
          <DxItem :col-count="2" :col-span="2" item-type="group" />
        </DxForm>
      </dx-data-grid>
    </div>

    <div class="margin1" v-if="this.selectedIndex == 1">
      <div class="row">
        <q-input
          class="col margin1"
          v-model="dt_visita"
          :color="colorID"
          label="Data da Visita"
          mask="##/##/####"
        >
          <template v-slot:prepend>
            <q-icon name="event" />
          </template>
          <template v-slot:append>
            <q-btn
              class="margin1"
              round
              :color="colorID"
              icon="event"
              size="sm"
            >
              <q-popup-proxy
                cover
                transition-show="scale"
                transition-hide="scale"
              >
                <div class="row">
                  <q-date
                    v-model="dt_visita"
                    :color="colorID"
                    mask="DD/MM/YYYY"
                    tabindex="-1"
                  >
                  </q-date>
                </div>
              </q-popup-proxy>
              <q-tooltip>Data</q-tooltip>
            </q-btn>
          </template>
        </q-input>

        <q-input
          class="col margin1"
          v-model="nm_cliente"
          :color="colorID"
          type="text"
          label="Cliente"
          :loading="loading"
          :readonly="readyOnly_cliente"
          ref="inputOrg"
          debounce="1000"
          @input="PesquisaCliente"
        >
          <template v-slot:prepend>
            <q-icon name="contacts" />
          </template>
          <template v-slot:append>
            <q-btn
              size="sm"
              v-if="cd_cliente != 0"
              round
              color="orange-9"
              icon="contact_page"
              :loading="load_contato"
              @click.stop="onPesquisaContato"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                Pesquisar Contatos
              </q-tooltip>
            </q-btn>
            <q-btn
              round
              color="orange-9"
              icon="add"
              size="sm"
              @click="AddCliente()"
            />

            <q-icon
              v-if="nm_cliente !== '' && readyOnly_cliente == false"
              name="close"
              @click.stop="(cliente = ''), (nm_cliente = ''), (GridCli = false)"
              class="cursor-pointer"
            ></q-icon>
          </template>
        </q-input>

        <div v-if="GridCli">
          <q-btn
            color="orange-9"
            flat
            rounded
            label="Selecionar"
            class="margin1"
            @click="SelecionaCliente()"
          >
          </q-btn>
          <DxDataGrid
            class="margin1"
            id="grid_cliente"
            key-expr="cd_controle"
            :data-source="resultado_pesquisa_cliente"
            :columns="coluna_cliente"
            :show-borders="true"
            :selection="{ mode: 'single' }"
            :focused-row-enabled="true"
            :column-hiding-enabled="false"
            :remote-operations="false"
            :word-wrap-enabled="false"
            :allow-column-reordering="false"
            :allow-column-resizing="true"
            :row-alternation-enabled="true"
            :repaint-changes-only="true"
            :autoNavigateToFocusedRow="true"
            :focused-row-index="0"
            :cacheEnable="false"
            @focused-row-changed="LinhaGridCliente($event)"
            @row-dbl-click="SelecionaCliente()"
          >
          </DxDataGrid>
        </div>

        <q-select
          class="col margin1"
          v-model="tipo_visita"
          label="Tipo de Visita"
          :color="colorID"
          :options="dataset_lookup_tipo_visita"
          option-value="cd_tipo_visita"
          option-label="nm_tipo_visita"
        >
          <template v-slot:prepend>
            <q-icon name="description" />
          </template>
        </q-select>
      </div>
      <div class="row">
        <q-input
          class="margin1 col"
          label="Horário Início"
          :color="colorID"
          v-model="hr_inicio_visita"
          mask="time"
          :rules="['time']"
        >
          <template v-slot:prepend>
            <q-icon name="schedule" />
          </template>
          <template v-slot:append>
            <q-icon name="access_time" class="cursor-pointer">
              <q-popup-proxy
                cover
                transition-show="scale"
                transition-hide="scale"
              >
                <q-time v-model="hr_inicio_visita">
                  <div class="row items-center justify-end">
                    <q-btn
                      v-close-popup
                      label="Fechar"
                      color="primary"
                      flat
                    ></q-btn>
                  </div>
                </q-time>
              </q-popup-proxy>
            </q-icon>
          </template>
        </q-input>

        <q-input
          class="margin1 col"
          label="Horário Início"
          :color="colorID"
          v-model="hr_fim_visita"
          mask="time"
          :rules="['time']"
        >
          <template v-slot:prepend>
            <q-icon name="schedule" />
          </template>
          <template v-slot:append>
            <q-icon name="access_time" class="cursor-pointer">
              <q-popup-proxy
                cover
                transition-show="scale"
                transition-hide="scale"
              >
                <q-time v-model="hr_fim_visita">
                  <div class="row items-center justify-end">
                    <q-btn
                      v-close-popup
                      label="Fechar"
                      color="primary"
                      flat
                    ></q-btn>
                  </div>
                </q-time>
              </q-popup-proxy>
            </q-icon>
          </template>
        </q-input>

        <q-select
          class="margin1 col"
          label="Operador que Agendou"
          :color="colorID"
          v-model="operador_agendou"
          :options="dataset_lookup_operador"
          option-value="cd_operador_telemarketing"
          option-label="nm_operador_telemarketing"
        >
          <template v-slot:prepend>
            <q-icon name="person" />
          </template>
        </q-select>
      </div>
      <div class="row">
        <q-input
          class="col margin1"
          label="Descrição"
          :color="colorID"
          v-model="ds_visita"
          autogrow
        >
          <template v-slot:prepend>
            <q-icon name="description" />
          </template>
        </q-input>
        <q-select
          class="col margin1"
          v-model="motivo_visita"
          label="Motivo"
          :color="colorID"
          :options="dataset_lookup_motivo_visita"
          option-value="cd_motivo_visita"
          option-label="nm_motivo_visita"
        >
          <template v-slot:prepend>
            <q-icon name="assignment" />
          </template>
        </q-select>
      </div>
      <div class="margin1 new-save" v-show="selectedIndex == 1">
        <q-btn
          v-show="this.alteracao == false"
          class="margin1"
          rounded
          :color="colorID"
          icon="save"
          label="salvar"
          @click="onSaveVisita()"
        >
          <q-tooltip> Salvar registro </q-tooltip>
        </q-btn>

        <q-btn
          v-show="this.alteracao == true"
          class="margin1"
          rounded
          :color="colorID"
          icon="save"
          label="Alterar"
          @click="onAlterarRegistro()"
        >
          <q-tooltip> Alterar registro </q-tooltip>
        </q-btn>
      </div>
    </div>
  </div>
</template>

<script>
import grid from "../views/grid";
import Lookup from "../http/lookup";
import procedimento from "../http/procedimento";
import notify from "devextreme/ui/notify";
import formataData from "../http/formataData";
import Incluir from "../http/incluir_registro";
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import ptMessages from "devextreme/localization/messages/pt.json";
import Menu from "../http/menu";

import { DxForm, DxItem } from "devextreme-vue/form";
import { DxDataGrid, DxPaging } from "devextreme-vue/data-grid";
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

export default {
  components: {
    grid,
    DxDataGrid,
    DxGroupPanel,
    DxGrouping,
    DxPager,
    DxStateStoring,
    DxSearchPanel,
    DxFilterRow,
    DxFilterPanel,
    DxHeaderFilter,
    DxColumnChooser,
    DxColumnFixing,
    DxPaging,
    DxForm,
    DxItem,
  },
  data() {
    return {
      selectedIndex: 0,
      colorID: "orange-9",
      cd_usuario: 0,
      cd_menu: 0,
      tituloMenu: "Visitas",
      dataset_lookup_tipo_visita: [],
      dataset_lookup_motivo_visita: [],
      tipo_visita: [],
      motivo_visita: [],
      dataset_lookup_operador: [],
      nm_cliente: "",
      loading: false,
      readyOnly_cliente: false,
      GridCli: false,
      resultado_pesquisa_cliente: [],
      coluna_cliente: [],
      vendedor: "",
      cliente: "",
      dt_visita: "",
      hr_inicio_visita: "",
      hr_fim_visita: "",
      operador_agendou: "",
      ds_visita: "",
      cd_cliente: 0,
      cd_parametro: 0,
      popup: false,
      popup_cancelamento: false,
      dataset_lookup_cancelamento: [],
      motivo_cancelamento: "",
      pageSizes: [10, 20, 50],
      temPanel: false,
      formData: {},
      items: [],
      dataSourceConfig: [],
      alteracao: false,
      linha: {},
      focusedRow: [],
      cd_visita: "",
      columns: {},
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    this.cd_menu = localStorage.cd_menu;
    this.cd_usuario = localStorage.cd_usuario;
    this.cd_empresa = localStorage.cd_empresa;

    this.dataset_lookup_tipo_visita = await Lookup.montarSelect(
      this.cd_empresa,
      124
    );
    this.dataset_lookup_tipo_visita = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_tipo_visita.dataset))
    );

    this.dataset_lookup_motivo_visita = await Lookup.montarSelect(
      this.cd_empresa,
      2034
    );
    this.dataset_lookup_motivo_visita = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_motivo_visita.dataset))
    );

    this.dataset_lookup_operador = await Lookup.montarSelect(
      this.cd_empresa,
      908
    );
    this.dataset_lookup_operador = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_operador.dataset))
    );
    this.dataset_lookup_cancelamento = await Lookup.montarSelect(
      this.cd_empresa,
      2035
    ); //codigo que traz os dados e a montagem do select
    this.dataset_lookup_cancelamento = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_lookup_cancelamento.dataset))
    ); //variavel que mostra e capta a seleção do usuario
    this.carregaDados();
  },
  methods: {
    onNovoRegistro() {
      this.alteracao = false;
      this.cd_parametro = 1;
      this.cd_visita = 0;
      this.nm_cliente = "";
      this.tipo_visita = "";
      this.dt_visita = "";
      this.hr_inicio_visita = "";
      this.hr_fim_visita = "";
      this.nm_operador_telemarketing = "";
      this.ds_visita = "";
      this.selectedIndex = 1;
    },

    //-------------------------------------
    async onTrocaTab() {
      if (this.selectedIndex == 1) {
        this.alteracao = true;
        this.nm_cliente = this.linha.nm_fantasia_cliente;
        this.cd_visita = this.linha.cd_visita;

        let tipo_visita = this.dataset_lookup_tipo_visita.filter((item) => {
          return item.cd_tipo_visita == this.linha.cd_tipo_visita;
        });
        this.tipo_visita = tipo_visita[0];

        this.dt_visita = this.linha.Data;
        this.hr_inicio_visita = this.linha.Inicio;
        this.hr_fim_visita = this.linha.Fim;
        this.ds_visita = this.linha.Descrição;

        let operador_agendou = this.dataset_lookup_operador.filter((item) => {
          return (
            item.cd_operador_telemarketing ==
            this.linha.cd_operador_telemarketing
          );
        });
        this.operador_agendou = operador_agendou[0];

        let motivo_visita = this.dataset_lookup_motivo_visita.filter((item) => {
          return item.cd_motivo_visita == this.linha.cd_motivo_visita;
        });
        this.motivo_visita = motivo_visita[0];

        if (this.linha.cd_cliente) {
          this.cliente = {
            cd_cliente: this.linha.cd_cliente,
            nm_fantasia_cliente: this.linha.Cliente,
          };
          this.nm_cliente = this.linha.Cliente;
        }
      }
      if (this.selectedIndex == 0) {
        await this.carregaDados();
        this.alteracao = false;
      }
    },
    //-------------------------------------------------------------------------------------
    async carregaDados() {
      var c = {
        cd_parametro: 0,
        cd_usuario: this.cd_usuario,
      };
      this.dataSourceConfig = await Incluir.incluirRegistro("518/724", c); //pr_egisnet_lancamento_visita_vendedor
      if (this.dataSourceConfig[0].Cod == 0) {
        notify(this.dataSourceConfig[0].Msg);
        return;
      }
      this.focusedRow = await this.dataSourceConfig[0].cd_controle;
    },

    //----------------------------------------

    async onSaveVisita() {
      if (this.nm_cliente == "") {
        notify("Digite um Cliente...");
        return;
      }
      if (this.tipo_visita == "") {
        notify("Selecione um Tipo de Visita...");
        return;
      }
      if (this.dt_visita == "") {
        notify("Selecione a Data de Visita...");
        return;
      }
      if (this.hr_inicio_visita == "") {
        notify("Selecione o Horário de Início...");
        return;
      }
      if (this.hr_fim_visita == "") {
        notify("Selecione o Horário Final...");
        return;
      }
      notify("Aguarde...");
      this.dt_visita = formataData.formataDataSQL(this.dt_visita);

      var insert = {
        cd_parametro: 1,
        dt_visita: this.dt_visita,
        cd_usuario: this.cd_usuario,
        cd_tipo_visita: this.tipo_visita.cd_tipo_visita,
        cd_motivo_visita:
          this.motivo_visita == undefined
            ? null
            : this.motivo_visita.cd_motivo_visita,
        cd_operador_telemarketing:
          this.operador_agendou == undefined
            ? null
            : this.operador_agendou.cd_operador_telemarketing,
        cd_cliente: this.cliente.cd_cliente,
        hr_inicio_visita: this.hr_inicio_visita,
        hr_fim_visita: this.hr_fim_visita,
        ds_visita: this.ds_visita,
      };
      //console.log(insert, "INSERT");
      var a = await Incluir.incluirRegistro("518/724", insert);
      notify(a[0].Msg);
      await this.carregaDados();
      this.selectedIndex = 0;
    },
    //-------------------------------------------------
    SelecionaCliente() {
      this.cliente = {
        cd_cliente: this.cliente_selecionado.cd_cliente,
        nm_fantasia_cliente: this.cliente_selecionado.Fantasia,
      };
      this.nm_cliente = this.cliente_selecionado.Fantasia;
      this.GridCli = false;
    },
    //-------------------------------------------------
    async PesquisaCliente() {
      this.loading = true;
      this.GridCli = false;

      try {
        let json_pesquisa_cliente = {
          cd_parametro: 1,
          nm_cliente: this.nm_cliente,
        };
        let menu_grid_cliente = await Menu.montarMenu(
          this.cd_empresa,
          7467,
          562
        );
        this.coluna_cliente = JSON.parse(
          JSON.parse(JSON.stringify(menu_grid_cliente.coluna))
        );

        this.resultado_pesquisa_cliente = await Incluir.incluirRegistro(
          "562/781",
          json_pesquisa_cliente
        );
        if (this.resultado_pesquisa_cliente[0].Cod == 0) {
          notify(this.resultado_pesquisa_cliente[0].Msg);
          return;
        } else {
          this.loading = false;
          this.GridCli = true;
        }
      } catch {
        this.loading = false;
        this.GridCli = false;
      }
    },
    //-------------------------------------------------------------------------------
    async onEnviarCancelamento() {
      this.cd_visita = this.linha.cd_visita;
      if (this.cd_visita == undefined) {
        notify("Selecione uma visita...");
        return;
      }
      var c = {
        cd_visita: this.cd_visita,
        cd_parametro: 2,
        cd_cancelamento_visita: this.motivo_cancelamento.cd_cancelamento_visita,
        cd_usuario: this.cd_usuario,
      };
      var z = await Incluir.incluirRegistro("518/724", c);
      notify(z[0].Msg);
      this.dataSourceConfig = [];
      await this.carregaDados();
      this.selectedIndex = 0;
    },
    RowSelected({ selectedRowsData }) {
      this.linha = selectedRowsData[0];
      this.cd_visita = this.linha.cd_visita;
    },
    async onAlterarRegistro() {
      notify("Aguarde...");

      this.dt_visita = formataData.formataDataSQL(this.dt_visita);
      var u = {
        cd_parametro: 3,
        cd_visita: this.cd_visita,
        dt_visita: this.dt_visita,
        cd_cliente: this.cliente.cd_cliente,
        cd_tipo_visita: this.tipo_visita.cd_tipo_visita,
        cd_motivo_visita: this.motivo_visita.cd_motivo_visita,
        hr_inicio_visita: this.hr_inicio_visita,
        hr_fim_visita: this.hr_fim_visita,
        cd_operador_telemarketing:
          this.operador_agendou == undefined
            ? null
            : this.operador_agendou.cd_operador_telemarketing,
        ds_visita: this.ds_visita,
        cd_usuario: this.cd_usuario,
      };
      //console.log(u, "ALTERAÇÃO");
      var n = await Incluir.incluirRegistro("518/724", u);
      notify(n[0].Msg);
      this.carregaDados();
      this.selectedIndex = 0;
    },
    onInicioCancelamento() {
      this.popup_cancelamento = true;
    },
    LinhaGridCliente: function (e) {
      this.cliente_selecionado = e.row && e.row.data;
    },
  },
};
</script>
<style>
@import url("./views.css");
.espaco-interno {
  padding: 3px;
}
.new-save {
  margin-top: 10px;
}

.top-header {
  display: flex;
  justify-content: space-between;
}
</style>
