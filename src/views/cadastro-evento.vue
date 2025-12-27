<template>
  <div class="fundo">
    <q-dialog v-model="mostra_cadastro" full-width persistent>
      <q-card class="encaixa">
        <q-card-section class="row justify-center">
          <div>
            <q-img
              class="logo-bni"
              src="http://www.egisnet.com.br/img/bni_endeavour.png"
              style="width: 80px; height: 80px"
              spinner-color="white"
            />
          </div>
        </q-card-section>
        <div class="row justify-center">
          <div class="text-h4 text-bold text-center">
            {{ info.nm_evento_sorteio }}
          </div>
        </div>

        <div class="row justify-center">
          <div class="text-h4 text-bold text-center">
            {{ info.dt_evento_sorteio }}
          </div>
        </div>
        <q-input item-aligned v-model="nm_convidado" type="text" label="Nome">
          <template v-slot:prepend>
            <q-icon name="person" />
          </template>
        </q-input>
        <q-input
          item-aligned
          v-model="cd_telefone"
          type="text"
          mask="(##)#####-####"
          label="Celular"
        >
          <template v-slot:prepend>
            <q-icon name="smartphone" />
          </template>
        </q-input>
        <q-input item-aligned v-model="nm_email" type="email" label="E-Mail">
          <template v-slot:prepend>
            <q-icon name="mail" />
          </template>
        </q-input>
        <q-input
          item-aligned
          v-model="nm_empresa_convidado"
          type="text"
          label="Empresa"
        >
          <template v-slot:prepend>
            <q-icon name="business" />
          </template>
        </q-input>
        <q-input
          item-aligned
          v-model="nm_especialidade"
          type="text"
          label="Especialidade"
        >
          <template v-slot:prepend>
            <q-icon name="work" />
          </template>
        </q-input>
        <q-input
          item-aligned
          v-model="nm_convidado_por"
          type="text"
          label="Convidado por"
        >
          <template v-slot:prepend>
            <q-icon name="account_circle" />
          </template>
        </q-input>

        <q-card-actions align="right" class="text-teal float-right">
          <q-btn
            color="orange-8"
            label="Cadastrar"
            outline
            @click="InsertSorteio"
          />
        </q-card-actions>
        <div class="row">
          <q-card-actions class="col">
            <q-img
              class="logo-gbs"
              src="http://www.egisnet.com.br/img/logo_gbs_oficial.jpg"
              style="max-width: 120px; max-height: 60px"
            />
          </q-card-actions>
        </div>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------>
    <q-dialog
      persistent
      v-model="agradecimento"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card style="width: auto; height: auto">
        <div style="margin: 20px">
          <h3 class="text-h3"><b>Obrigado, ótima reunião e boa sorte !</b></h3>
          <q-card-actions align="right" class="text-teal float-right">
            <a
              href="http://bniguarulhos.com.br/regiao-guarulhos-bni-gru-endeavour/pt-BR/index"
            >
              <q-btn flat color="orange-8" label="Fechar" />
            </a>
          </q-card-actions>
        </div>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";

export default {
  data() {
    return {
      nm_convidado: "",
      cd_telefone: "",
      nm_email: "",
      nm_empresa_convidado: "",
      nm_especialidade: "",
      cadastro: {},
      info: {},
      mostra_cadastro: true,
      agradecimento: false,
      fone: "Fone: (11) 3907-4141",
      nm_convidado_por: "",
    };
  },
  async created() {
    localStorage.cd_empresa = 155;
    var json_menu = {
      cd_parametro: 3,
    };
    this.info = (await Incluir.incluirRegistro("574/794", json_menu))[0];
  },
  methods: {
    async InsertSorteio() {
      if (this.nm_convidado == "") {
        notify("Digite o nome");
        return;
      }
      if (this.cd_telefone == "") {
        notify("Digite o celular!");
        return;
      }
      if (this.nm_email == "") {
        notify("Digite o e-mail!");
        return;
      }
      var json = {
        cd_parametro: 1,
        nm_convidado: this.nm_convidado,
        cd_telefone: this.cd_telefone,
        nm_email: this.nm_email,
        nm_empresa_convidado: this.nm_empresa_convidado,
        nm_especialidade: this.nm_especialidade,
        nm_convidado_por: this.nm_convidado_por,
        nm_evento_sorteio: this.info.nm_evento_sorteio,
      };
      this.cadastro = await Incluir.incluirRegistro("574/794", json);
      notify(this.cadastro[0].Msg);
      if (this.cadastro[0].Cod == 0) {
        notify(this.cadastro[0].Msg);
        return;
      } else {
        this.nm_convidado = "";
        this.cd_telefone = "";
        this.nm_email = "";
        this.nm_empresa_convidado = "";
        this.nm_especialidade = "";
        this.cadastro = {};
      }
      this.agradecimento = true;
    },
  },
};
</script>

<style>
.cadastro {
  margin: 5px;
  margin-left: 10px;
}

.capa {
  background-image: url("http://www.egisnet.com.br/img/capa_evento.jpeg");
  width: 614px;
  height: 616px;
  background-position: center center;
  background-repeat: no-repeat;
}

.encaixa {
  width: 100%;
}
.logo-bni {
  margin: 5px;
}
a:link,
a:visited {
  color: inherit;
  text-decoration: inherit;
  cursor: auto;
}

a:link:active,
a:visited:active {
  color: inherit;
}

.logo-gbs {
  float: left;
  width: 180px;
  margin: 10px;
}
</style>