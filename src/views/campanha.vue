<template>
  <div class="margin1">
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div>
      <div
        class="text-h5 text-bold margin1 items-center self-center"
        v-show="titulo != ''"
      >
        <q-icon name="description" color="orange-9" size="sm" /> {{ titulo }}
      </div>

      <div
        class="row text-subtitle1 margin1 items-center self-center"
        v-show="cd_contrato > 0"
      >
        <q-icon name="arrow_forward_ios" color="orange-9" size="sm" /> Ficha de
        venda:
        {{ cd_contrato }}
      </div>
      <!--
      <div
        class="row text-subtitle2 margin1 items-center self-center"
        v-show="cd_cota_contrato > 0"
      >
        <q-icon name="arrow_forward_ios" color="orange-9" size="sm" />
        Cota/Contrato:
        {{ cd_cota_contrato }}
      </div>
      -->

      <div
        class="text-subtitle2 margin1 items-center self-center"
        v-show="dt_contrato != ''"
      >
        <q-icon name="event" color="orange-9" size="sm" /> {{ dt_contrato }}
      </div>

      <div
        class="text-subtitle2 margin1 items-center self-center"
        v-show="cliente != ''"
      >
        <q-icon name="person" color="orange-9" size="sm" /> {{ cliente }}
      </div>

      <div
        class="text-subtitle2 margin1 items-center self-center"
        v-show="vendedor != ''"
      >
        <q-icon name="person_add" color="orange-9" size="sm" /> {{ vendedor }}
      </div>

      <q-input
        class="col margin1"
        v-model="nm_ref_contrato"
        label="Numera��o do Contrato"
      >
        <template v-slot:prepend>
          <q-icon name="dialpad" />
        </template>
      </q-input>
      <q-input
        class="col margin1"
        v-model="nm_ref_cota"
        label="Numera��o da Cota"
      >
        <template v-slot:prepend>
          <q-icon name="vpn_key" />
        </template>
      </q-input>

      <q-input
        class="col margin1"
        v-model="pc_ponto_campanha"
        maxlength="3"
        @blur="FormataPC()"
        label="Percentual por Campanha"
        suffix="%"
      >
        <template v-slot:prepend>
          <q-icon name="add" />
        </template>
      </q-input>

      <q-input class="col margin1" v-model="cd_grupo_contrato" label="Grupo">
        <template v-slot:prepend>
          <q-icon name="group" />
        </template>
      </q-input>

      <q-input
        class="col margin1"
        v-model="qt_prazo_contrato"
        label="Prazo"
        type="number"
      >
        <template v-slot:prepend>
          <q-icon name="event" />
        </template>
      </q-input>

      <q-input
        class="col margin1"
        v-model="vl_contrato"
        label="Valor"
        @blur="FormataValor(vl_contrato, 1)"
      >
        <template v-slot:prepend>
          <q-icon name="attach_money" />
        </template>
      </q-input>

      <q-select
        class="col margin1"
        option-value="cd_administradora"
        option-label="nm_administradora"
        v-model="administradora"
        @input="buscaTabela()"
        readonly
        :options="lookup_administradora"
        label="Administradora"
      >
        <template v-slot:prepend>
          <q-icon name="brightness_auto" />
        </template>
      </q-select>

      <q-select
        class="col margin1"
        option-value="cd_tabela"
        option-label="nm_tabela"
        v-model="tabela"
        :options="lookup_dataset_tabela"
        label="Tabela"
      >
        <template v-slot:prepend>
          <q-icon name="drag_indicator" />
        </template>
      </q-select>

      <q-btn
        class="margin1"
        style="float: right"
        color="positive"
        icon-right="check"
        rounded
        label="Confirmar"
        @click="ConfirmaCota()"
      />
    </div>
  </div>
</template>

<script>
import notify from "devextreme/ui/notify";
import Incluir from "../http/incluir_registro";
import Procedimento from "../http/procedimento";
import Lookup from "../http/lookup";

export default {
  name: "campanha",
  props: {
    info: { type: Object, default: {} },
  },
  data() {
    return {
      titulo: "",
      api: "695/1044",
      pc_ponto_campanha: "",
      cliente: "",
      vendedor: "",
      vl_contrato: "",
      nm_ref_contrato: "",
      nm_ref_cota: "",
      cd_grupo_contrato: "",
      qt_prazo_contrato: "",
      dt_contrato: "",
      nm_cliente: "",
      administradora: "",
      cd_contrato: 0,
      lookup_dataset_tabela: [],
      lookup_administradora: [],
      tabela: "",
      cd_empresa: localStorage.cd_empresa,
      cd_cliente: 0,
      cd_cota_contrato: 0,
    };
  },

  async created() {
    this.cd_contrato = this.info.cd_documento;
    this.cd_cota_contrato = this.info.cd_item_documento;
    if (this.info.cd_etapa == 135) {
      this.carregaDados();
    } else if (this.info.cd_etapa == 93) {
      await this.carregaCota();
    }
    let dados_adm = await Lookup.montarSelect(this.cd_empresa, 5238);
    this.lookup_administradora = JSON.parse(
      JSON.parse(JSON.stringify(dados_adm.dataset))
    );
  },

  methods: {
    FormataPC() {
      if (this.pc_ponto_campanha > 100) {
        this.pc_ponto_campanha = 100;
      } else if (this.pc_ponto_campanha < 0) {
        this.pc_ponto_campanha = 0;
      }
    },
    async ConfirmaCota() {
      this.cd_contrato = this.info.cd_movimento;
      const send = {
        cd_parametro: 4,
        cd_contrato: this.cd_contrato,
        cd_tabela: this.tabela.cd_tabela,
        vl_contrato: this.vl_contrato,
        qt_prazo_contrato: this.qt_prazo_contrato,
        cd_grupo_contrato: this.cd_grupo_contrato,
        nm_ref_contrato: this.nm_ref_contrato,
        pc_ponto_campanha: this.pc_ponto_campanha,
        cd_administradora: this.administradora.cd_administradora,
        cd_tabela: this.tabela.cd_tabela,
        cd_cota_contrato: this.cd_cota_contrato,
        nm_ref_cota: this.nm_ref_cota,
      };
      const confirmar = await Incluir.incluirRegistro(this.api, send);
      notify(confirmar[0].Msg);
    },
    FormataValor(valorT, indice) {
      if (valorT == "" || valorT == "0") return;

      if (valorT == "" || valorT == "R$ NaN" || valorT == undefined) {
        valorT = 0;
      }
      if (valorT.includes("R$") == false) {
        let valor = valorT;

        if (valor.includes("R$") == true) {
          valor = valor.replace("R$", " ");
        }

        if (valor.includes(",") == true) {
          valor = valor.replace(",", ".");
        }
        valor = parseFloat(valor);
        valorT = valor.toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
        if (indice == 1) {
          this.vl_contrato = valorT;
        }
        if (indice == 2) {
        }
      }
    },
    async buscaTabela() {
      if (this.administradora == 0) return;
      this.tabela = "";
      localStorage.cd_parametro = this.administradora.cd_administradora;
      this.lookup_dataset_tabela = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        "458/631",
        "/${cd_empresa}/${cd_parametro}"
      );
      this.lookup_dataset_tabela = JSON.parse(
        JSON.parse(JSON.stringify(this.lookup_dataset_tabela[0].dataset))
      );
      if (this.lookup_dataset_tabela == null) {
        notify("Nenhuma tabela foi encontrada para a administradora!");
      }
    },

    async carregaCota() {
      let contrato = this.info.cd_movimento;
      let c = {
        cd_parametro: 3,
        cd_contrato: contrato,
        cd_cota_contrato: this.cd_cota_contrato,
      };
      let cota = await Incluir.incluirRegistro(this.api, c);
      this.cd_grupo_contrato = cota[0].cd_grupo_contrato;
      this.vl_contrato = cota[0].vl_contrato;
      this.administradora = {
        cd_administradora: cota[0].cd_administradora,
        nm_administradora: cota[0].nm_administradora,
      };
      if (this.administradora.cd_administradora > 0) {
        await this.buscaTabela();
      }
      this.qt_prazo_contrato = cota[0].qt_prazo_contrato;
      this.nm_cliente = cota[0].nm_fantasia_cliente;
      this.nm_ref_contrato = cota[0].nm_ref_contrato;
      this.nm_ref_cota = cota[0].nm_ref_cota;
      this.pc_ponto_campanha = cota[0].pc_campanha_cota;
      if (cota[0].cd_tabela > 0) {
        this.tabela = {
          cd_tabela: cota[0].cd_tabela,
          nm_tabela: cota[0].nm_tabela,
        };
      }
    },

    async carregaDados() {
      let c = {
        cd_parametro: 1,
        cd_contrato: this.info.cd_movimento,
        cd_cota_contrato: this.cd_cota_contrato,
      };
      const consulta = await Incluir.incluirRegistro(this.api, c);
      if (consulta[0].Cod == 0) {
        notify(consulta[0].Msg);
        return;
      }

      this.cd_contrato = consulta[0].cd_contrato;
      this.pc_ponto_campanha = consulta[0].pc_ponto_campanha;
      this.titulo = consulta[0].titulo;
      this.cliente = consulta[0].nm_fantasia_cliente;
      this.vendedor = consulta[0].nm_vendedor;
      this.dt_contrato = consulta[0].dt_contrato;
      this.nm_ref_contrato = consulta[0].nm_ref_cota;
      this.cd_grupo_contrato = consulta[0].cd_grupo_cota;
      this.qt_prazo_contrato = consulta[0].qt_prazo_cota;
      this.vl_contrato = consulta[0].vl_cota_contrato;
      this.administradora = {
        cd_administradora: consulta[0].cd_administradora,
        nm_administradora: consulta[0].nm_administradora,
      };
      this.buscaTabela();
      this.tabela = {
        cd_tabela: consulta[0].cd_tabela,
        nm_tabela: consulta[0].nm_tabela,
      };
    },
  },
};
</script>

<style scoped>
@import url(./views.css);
</style>
