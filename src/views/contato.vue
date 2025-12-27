<template>
  <div>
    <q-expansion-item
      icon="description"
      :label="tituloMenu"
      default-opened
      class="shadow-1 overflow-hidden margin1"
      style="border-radius: 20px; height:auto"
      :header-class="'bg-' + corID + ' text-white text-h6 items-center'"
      expand-icon-class="text-white"
    >
      <div class="row margin1 items-center justify-center">
        <q-input
          class="items-center margin1 umQuartoTela "
          v-model="Nome"
          label="Nome"
        >
          <template v-slot:prepend>
            <q-icon name="person" />
          </template>
        </q-input>
        <q-input
          class="items-center margin1 umQuartoTela "
          v-model="Telefone"
          label="Telefone"
          mask="(##) ####-####"
        >
          <template v-slot:prepend>
            <q-icon name="phone" />
          </template>
        </q-input>
        <q-input
          class="margin1 umQuartoTela "
          v-model="Celular"
          label="Celular"
          mask="(##)#####-####"
        >
          <template v-slot:prepend>
            <q-icon name="smartphone" />
          </template>
        </q-input>
        <q-input class="margin1 umQuartoTela " v-model="Email" label="Email">
          <template v-slot:prepend>
            <q-icon name="email" />
          </template>
        </q-input>
        <q-checkbox
          :value="Pos"
          class="check-box margin1"
          v-model="Pos"
          :color="corID"
          label="Pós-Venda"
        />
        <div class="check-box margin1">
          <q-btn @click="gravar()" round :color="corID" icon="save"> 
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            Salvar Contato
          </q-tooltip></q-btn>
          <q-btn @click="add()" round :color="corID" icon="add">
            <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            Adicionar Contato
          </q-tooltip>
          </q-btn>
        </div>
      </div>
      <q-separator />
      <q-item
        v-for="(item, index) in contatos_cliente"
        :key="index"
        class="row items-center margin1"
      >
        <q-item-section avatar class=" auto">
          <q-avatar :color="corID" text-color="white">
            {{ item.letra }}
          </q-avatar>
        </q-item-section>

        <q-item-section>
          <q-item-label class="auto ">{{
            item.nm_contato_cliente
          }}</q-item-label>
          <q-item-label class="auto " caption lines="1">
            <b>Email:</b> {{ item.cd_email_contato_cliente }}</q-item-label
          >
          <q-item-label class="auto " caption lines="1">
            <b>Celular:</b> {{ item.cd_celular }}</q-item-label
          >
          <q-item-label class="auto " caption lines="1">
            <b>Telefone:</b> {{ item.cd_telefone_contato }}</q-item-label
          >
        </q-item-section>

        <q-item-section class="auto " side v-if="item.cd_setor_cliente == 1">
          <q-btn
            flat
            rounded
            :color="corID"
            size="md"
            label="P"
            class="margin1"
          >
            <q-tooltip>Pós-Venda</q-tooltip>
          </q-btn>
        </q-item-section>

        <q-item-section side class=" auto">
          <q-btn
            @click="Alterar_Dados(index)"
            round
            :color="corID"
            class="margin1"
            icon="edit"
            flat
          >
            <q-tooltip>
              Alterar Dados
            </q-tooltip>
          </q-btn>
        </q-item-section>

        <q-item-section side class=" auto">
          <q-btn
            class="margin1"
            @click="Excluir_dados(index)"
            round
            :color="corID"
            icon="delete"
            flat
          >
            <q-tooltip>
              Excluir Dados
            </q-tooltip>
          </q-btn>
        </q-item-section>

        <div v-if="Pergunta_Excluir == true">
          <q-dialog v-model="Pergunta_Excluir">
            <q-card>
              <div class="text-h6 margin1 text-center">
                Deseja realmente excluir esse contato ?
              </div>
              <q-card-section class="row items-center" style="padding:0">
                <q-separator />

                <q-btn
                  @click="Excluir()"
                  class="margin1 metadeTela"
                  color="green"
                  icon="check"
                  label="Confirmar"
                  flat
                  rounded
                  v-close-popup
                />
                <q-btn
                  class="margin1 metadeTela"
                  flat
                  rounded
                  color="red"
                  icon="cancel"
                  label="Cancelar"
                  v-close-popup
                />
              </q-card-section>
            </q-card>
          </q-dialog>
        </div>

        <div v-if="Popup_alterar == true">
          <q-dialog v-model="Popup_alterar">
            <q-card style="width:auto">
              <q-card-section>
                <div class="text-h6 row items-center text-center margin1">
                  Alteração de Contato
                </div>
                <q-input class="margin1" v-model="Nome" label="Nome">
                  <template v-slot:prepend>
                    <q-icon name="person" />
                  </template>
                </q-input>
                <q-input class="margin1" v-model="Email" label="E-mail">
                  <template v-slot:prepend>
                    <q-icon name="mail" />
                  </template>
                </q-input>
                <q-input
                  v-model="Telefone"
                  class="margin1"
                  mask="(##) ####-####"
                  label="Telefone"
                >
                  <template v-slot:prepend>
                    <q-icon name="call" />
                  </template>
                </q-input>
                <q-input
                  v-model="Celular"
                  class="margin1"
                  mask="(##)#####-####"
                  label="Celular"
                >
                  <template v-slot:prepend>
                    <q-icon name="smartphone" />
                  </template>
                </q-input>
                <div class="row items-center">
                  <q-checkbox v-model="Pos" class="margin1" label="Pós-Venda" />
                </div>
                <div class="row">
                  <q-btn
                    class="margin1"
                    @click="Alterar(index)"
                    color="green"
                    icon="check"
                    label="Confirmar"
                    flat
                    rounded
                    v-close-popup
                  />
                  <q-btn
                    class="margin1"
                    color="red"
                    icon="cancel"
                    flat
                    rounded
                    label="Cancelar"
                    v-close-popup
                  />
                </div>
              </q-card-section>
            </q-card>
          </q-dialog>
        </div>
      </q-item>

      <div v-if="carrega_load == true">
        <q-dialog v-model="carrega_load">
          <q-card>
            <div class="q-pa-md">
              <div class="q-gutter-md row">
                <q-spinner
                  :color="corID"
                  size="3em"
                  :thickness="10"
                ></q-spinner>
              </div>
            </div>
          </q-card>
        </q-dialog>
      </div>
    </q-expansion-item>
  </div>
</template>

<script>
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import ptMessages from "devextreme/localization/messages/pt.json";

import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";

var dados = [];

export default {
  props: {
    cd_cliente_contato: { type: Number, default: 0 },
    pos_venda: { type: Number, default: 0 },
    corID: { type: String, default: "primary" },
  },

  data() {
    return {
      Celular: "",
      Contato: 0,
      Nome: "",
      Telefone: "",
      Email: "",
      Pos: false,
      Pergunta_Excluir: false,
      Popup_alterar: false,
      contatos_cliente: [],
      carrega_load: false,
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();
    this.dt_final = new Date(localStorage.dt_final).toLocaleDateString();
    this.hoje = new Date().toLocaleDateString();
    var h = new Date().toLocaleTimeString();
    this.hora = h.substring(0, 5);
    this.cd_empresa = localStorage.cd_empresa;
    this.tituloMenu = "Cadastro de Contato";

    await this.consultaContato();
  },

  methods: {
    async gravar() {
      let VerificaPos = 0;
      if (this.Pos == true) {
        VerificaPos = 1;
      } else {
        VerificaPos = 0;
      }

      if (this.Nome != "") {
        dados = {
          cd_parametro: 0,
          nm_contato_cliente: this.Nome,
          cd_usuario: localStorage.cd_usuario,
          cd_email_contato_cliente: this.Email,
          pos_venda: VerificaPos,
          cd_ddd_contato_cliente: "11",
          cd_celular: this.Celular,
          cd_telefone: this.Telefone,
          cd_cliente: this.cd_cliente_contato,
        };
        this.carrega_load = true;
        await this.onGravar();
        this.carrega_load = false;
        this.add();
      } else {
        return notify('Informe o nome do Contato!');
      }
    },

    Excluir_dados(index) {
      this.Pergunta_Excluir = true;
      dados = {
        cd_parametro: 2,
        nm_contato_cliente: this.contatos_cliente[index].nm_contato_cliente,
        cd_usuario: this.contatos_cliente[index].cd_usuario,
        cd_email_contato_cliente: this.contatos_cliente[index]
          .cd_email_contato_cliente,
        pos_venda: this.contatos_cliente[index].cd_setor_cliente,
        cd_ddd_contato_cliente: "11",
        cd_celular: this.contatos_cliente[index].cd_celular,
        cd_cliente: this.contatos_cliente[index].cd_cliente,
        cd_contato: this.contatos_cliente[index].cd_contato,
      };
    },

    async Excluir() {
      this.carrega_load = true;
      await this.onGravar();
      this.carrega_load = false;
    },

    Alterar_Dados(index) {
      this.Nome = "";
      this.Telefone = "";
      this.Celular = "";
      this.Email = "";

      if (this.contatos_cliente[index].cd_setor_cliente == 1) {
        this.Pos = true;
      } else {
        this.Pos = false;
      }

      this.Nome = this.contatos_cliente[index].nm_contato_cliente;
      this.Telefone = this.contatos_cliente[index].cd_telefone_contato;
      this.Celular = this.contatos_cliente[index].cd_celular;
      this.Email = this.contatos_cliente[index].cd_email_contato_cliente;
      //this.Pos      = this.contatos_cliente[index].cd_setor_cliente
      this.Contato = this.contatos_cliente[index].cd_contato;

      this.Popup_alterar = true;
    },

    async Alterar(index) {
      let VerificaPos = 0;

      if (this.Pos == true) {
        VerificaPos = 1;
      } else {
        VerificaPos = 0;
      }

      dados = {
        cd_parametro: 3,
        nm_contato_cliente: this.Nome,
        cd_email_contato_cliente: this.Email,
        pos_venda: VerificaPos,
        cd_ddd_contato_cliente: "11",
        cd_telefone: this.Telefone,
        cd_celular: this.Celular,
        cd_cliente: this.contatos_cliente[index].cd_cliente,
        cd_contato: this.Contato,
      };
      this.carrega_load = true;
      await this.onGravar();
      this.carrega_load = false;
      this.add();
    },

    async onGravar() {
      var api = "495/698"; //1368 - pr_inserir_cliente_contato
      var s = await Incluir.incluirRegistro(api, dados);
      notify(s[0].Msg);
      this.contatos_cliente = JSON.parse(
        JSON.parse(JSON.stringify(s[0].Contatos))
      );
    this.$emit("ListaContatos", this.contatos_cliente);
    },

    add() {
      this.Nome = "";
      this.Telefone = "";
      this.Celular = "";
      this.Email = "";
      this.Pos = false;
    },

    async consultaContato() {
      var api = "495/698"; // Procedimento 1368 - pr_inserir_cliente_contato
      var dados_consulta = {
        cd_cliente: this.cd_cliente_contato,
        cd_parametro: 1,
        cd_pos_venda: this.pos_venda,
      };
      var s = await Incluir.incluirRegistro(api, dados_consulta);
      this.contatos_cliente = s;
      return this.contatos_cliente;
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}
.metadeTela {
  width: 44%;
}

.umTercoTela {
  width: 31%;
}

.umQuartoTela {
  width: 18%;
}
.check-box {
  width: auto;
}
.auto {
  width: auto;
}

@media (max-width: 750px) {
  .metadeTela {
    width: 100%;
  }

  .umTercoTela {
    width: 100%;
  }

  .umQuartoTela {
    width: 100%;
  }
  .auto {
    width: 100%;
  }
}
</style>
