<template>
  <div>
    <div class="text-h5 margin1">{{ tituloMenu }}</div>
    <div class="row justify-evenly">
      <q-input
        class="tres-tela margin1"
        v-model="nm_nome"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        label="Nome Completo"
      >
        <template v-slot:prepend>
          <q-icon name="drive_file_rename_outline" />
        </template>
      </q-input>

      <q-input
        class="tres-tela margin1"
        v-model="email"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        label="E-mail"
      >
        <template v-slot:prepend>
          <q-icon name="contact_mail" />
        </template>
      </q-input>

      <!--<q-input
        class="quatro-tela margin1"
        v-model="cd_rg"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        mask="##.###.###-#"
        label="RG"
      >
        <template v-slot:prepend>
          <q-icon name="badge" />
        </template>
      </q-input>-->
      <!-- <q-input
        class="tres-tela margin1"
        v-model="cd_cpf"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        mask="##.###.###/####-##"
        label="CNPJ"
      >
        <template v-slot:prepend>
          <q-icon name="badge" />
        </template>
      </q-input> -->

      <q-input
        class="tres-tela margin1"
        v-model="cd_cpf"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        mask="###.###.###-##"
        label="CPF"
      >
        <template v-slot:prepend>
          <q-icon name="badge" />
        </template>
      </q-input>
    </div>

    <div class="row justify-evenly">
      <q-input
        class="quatro-tela margin1"
        v-model="dt_nasc"
        type="text"
        mask="##/##/####"
        label="Data de nascimento"
      >
        <template v-slot:prepend>
          <q-icon name="apps" />
        </template>
      </q-input>

      <q-input
        class="quatro-tela margin1"
        @blur="buscaCep()"
        v-model="cd_cep"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        mask="#####-###"
        label="CEP"
      >
        <template v-slot:prepend>
          <q-icon name="home" />
        </template>
      </q-input>

      <q-input
        class="quatro-tela margin1"
        v-model="nm_endereco"
        label="Endereço"
        :loading="load"
      >
        <template v-slot:prepend>
          <q-icon name="house" />
        </template>
      </q-input>

      <q-input
        class="quatro-tela margin1"
        :loading="load"
        v-model="bairro"
        label="Bairro"
      >
        <template v-slot:prepend>
          <q-icon name="my_location" />
        </template>
      </q-input>
    </div>

    <div class="row justify-evenly">
      <q-select
        class="quatro-tela margin1"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        option-value="cd_estado"
        option-label="sg_estado"
        :options="lookup_dataset_estado"
        :loading="load"
        v-model="sg_estado"
        label="Estado"
      >
        <template v-slot:prepend>
          <q-icon name="map" />
        </template>
      </q-select>

      <q-select
        class="quatro-tela margin1"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        option-value="cd_cidade"
        option-label="nm_cidade"
        :options="lookup_cidade"
        v-model="nm_cidade"
        :loading="load"
        label="Cidade"
      >
        <template v-slot:prepend>
          <q-icon name="location_on" />
        </template>
      </q-select>

      <q-input
        class="quatro-tela margin1"
        v-model="complemento"
        :loading="load"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        label="Complemento"
      >
        <template v-slot:prepend>
          <q-icon name="description" />
        </template>
      </q-input>

      <q-input
        class="quatro-tela margin1"
        v-model="cd_numero"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        label="Número"
      >
        <template v-slot:prepend>
          <q-icon name="pin" />
        </template>
      </q-input>
    </div>
    <div class="row justify-evenly">
      <q-input
        class="quatro-tela margin1"
        v-model="pc_empresa"
        @blur="formata_pc(pc_empresa)"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        label="(%) da Empresa"
      >
        <template v-slot:prepend>
          <q-icon name="format_list_numbered" />
        </template>
      </q-input>
      <q-input
        class="quatro-tela margin1"
        v-model="cd_telefone"
        label="Telefone"
        mask="(##) ####-####"
      >
        <template v-slot:prepend>
          <q-icon name="call" />
        </template>
      </q-input>
      <q-input
        class="quatro-tela margin1"
        v-model="cd_celular"
        label="Celular"
        mask="(##)#####-####"
      >
        <template v-slot:prepend>
          <q-icon name="smartphone" />
        </template>
      </q-input>

      <q-input
        class="quatro-tela margin1"
        v-model="profissao"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        label="Profissão"
      >
        <template v-slot:prepend>
          <q-icon name="person_4" />
        </template>
      </q-input>
    </div>
    <div class="row justify-evenly">
      <q-input
        class="quatro-tela margin1"
        v-model="nm_cargo"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        label="Cargo"
      >
        <template v-slot:prepend>
          <q-icon name="psychology" />
        </template>
      </q-input>

      <q-input
        class="quatro-tela margin1"
        v-model="vl_faturamento_mensal"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        label="Faturamento Mensal"
        @blur="FormataValor(1)"
      >
        <template v-slot:prepend>
          <q-icon name="attach_money" />
        </template>
      </q-input>

      <q-input
        class="quatro-tela margin1"
        v-model="vl_faturamento_anual"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        label="Faturamento Anual"
        @blur="FormataValor(2)"
      >
        <template v-slot:prepend>
          <q-icon name="attach_money" />
        </template>
      </q-input>

      <q-select
        class="quatro-tela margin1"
        :rules="[(val) => !!val || 'Campo obrigatório']"
        option-value="cd_estado_civil"
        option-label="nm_estado_civil"
        v-model="cd_estado_civil"
        :options="lookup_dataset_estado_civil"
        label="Estado Civil"
      >
        <template v-slot:prepend>
          <q-icon name="wc" />
        </template>
      </q-select>
    </div>
    <!--Loading Tela-------------------------------------------------------------------->
    <q-dialog v-model="load_tela" maximized persistent>
      <carregando
        :mensagemID="'Carregando dados do Sócio...'"
        :corID="'orange-9'"
      ></carregando>
    </q-dialog>
  </div>
</template>

<script>
import Procedimento from "../http/procedimento";
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";

import formataData from "../http/formataData";

import contato from "../views/contato";
import funcao from "../http/funcoes-padroes";
import Incluir from "../http/incluir_registro";
import Lookup from "../http/lookup";

export default {
  props: {
    cd_contrato: { type: Number, default: 0 },
    cd_cliente_socio: { type: Number, default: 0 },
    cadastro: { type: Boolean, default: false },
    cd_ficha_vendaID: { type: Number, default: 0 },
    cd_indicacaoID: { type: Number, default: 0 }, //0 = Contrato, 1= ficha venda
  },

  data() {
    return {
      alteracaoS: false,
      dataSourceConfig: [],
      tituloMenu: "",
      dt_inicial: "",
      dt_final: "",
      cd_empresa: 0,
      cd_cliente: 0,
      api: 0,
      load: false,
      lookup_dataset_estado_civil: [],
      cd_estado_civil: "",
      nm_nome: "",
      dt_nasc: "",
      complemento: "",
      lookup_dataset_estado: [],
      cd_rg: "",
      cd_cpf: "",
      vl_faturamento_anual: "",
      email: "",
      vl_faturamento_mensal: "",
      profissao: "",
      bairro: "",
      cd_cep: "",
      nm_bairro: "",
      nm_endereco: "", //rua
      cd_numero: "",
      load_tela: false,
      nm_complemento: "",
      nm_cidade: "",
      ic_estado: "",
      sg_estado: "",
      pc_empresa: 0,
      cd_telefone: "",
      lookup_cidade: "",
      cd_celular: "",
      nm_cargo: "",
      contato_selecionado: [],
      dados_contato_socio: [],
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

    this.tituloMenu = "Cadastro de Sócio Majoritário";
    try {
      this.load_tela = true;
      let est = await Lookup.montarSelect(this.cd_empresa, 96);
      this.lookup_dataset_estado = JSON.parse(
        JSON.parse(JSON.stringify(est.dataset))
      );

      let cid = await Lookup.montarSelect(this.cd_empresa, 97);
      this.lookup_cidade = JSON.parse(JSON.parse(JSON.stringify(cid.dataset)));

      let lookup_dados_estado_civil = await Lookup.montarSelect(
        this.cd_empresa,
        373
      );
      this.lookup_dataset_estado_civil = JSON.parse(
        JSON.parse(JSON.stringify(lookup_dados_estado_civil.dataset))
      );
    } catch (error) {
      this.load_tela = false;
    }
    this.load_tela = false;
    //if (this.cd_indicacaoID == 0 && this.cd_contrato > 0) {
    //  this.load_tela = true;
    //  let s = {
    //    cd_parametro: 9,
    //    cd_contrato: this.cd_contrato,
    //  };
    //  try {
    //    this.dados_contato_socio = await Incluir.incluirRegistro("706/1073", s);
    //  } catch (error) {
    //    this.load_tela = false;
    //  }
    //  if (this.dados_contato_socio[0].Cod == 0) {
    //    this.load_tela = false;
    //
    //    notify(this.dados_contato_socio[0].Msg);
    //    this.nm_nome = "";
    //    this.cd_rg = "";
    //    this.cd_cpf = "";
    //    this.alteracaoS = false;
    //    this.cd_cep = "";
    //    this.nm_endereco = "";
    //    this.nm_cidade = "";
    //    this.cd_numero = "";
    //    this.pc_empresa = "";
    //    this.cd_telefone = "";
    //    this.cd_celular = "";
    //    this.nm_cargo = "";
    //    this.cd_estado_civil = "";
    //  } else {
    //    this.load_tela = false;
    //
    //    this.alteracaoS = true;
    //    this.nm_nome = this.dados_contato_socio[0].nm_razao_contrato;
    //    this.cd_rg = this.dados_contato_socio[0].cd_ie_rg_contrato;
    //    this.cd_cpf = this.dados_contato_socio[0].cd_cnpj_cpf_contrato;
    //    //this.dt_nasc = this.dados_contato_socio[0].dt_nascimento;
    //    this.cd_cep = this.dados_contato_socio[0].cd_cep;
    //    this.nm_endereco = this.dados_contato_socio[0].nm_endereco;
    //    this.nm_cidade = this.dados_contato_socio[0].nm_cidade;
    //    this.cd_numero = this.dados_contato_socio[0].cd_numero;
    //    this.pc_empresa = this.dados_contato_socio[0].pc_empresa;
    //    this.cd_telefone = this.dados_contato_socio[0].cd_telefone;
    //    this.cd_celular = this.dados_contato_socio[0].cd_celular;
    //    this.nm_cargo = this.dados_contato_socio[0].nm_cargo;
    //    this.cd_estado_civil = this.dados_contato_socio[0].cd_estado_civil;
    //    this.estado_civil = {
    //      cd_estado_civil: this.dados_contato_socio[0].cd_estado_civil,
    //      nm_estado_civil: this.dados_contato_socio[0].nm_estado_civil,
    //    };
    //  }
    //}
    this.load_tela = false;

    await this.buscaDadosSocio();
  },

  components: {
    contato,
    carregando: () => import("../components/carregando.vue"),
  },
  watch: {},
  methods: {
    async FormataValor(index) {
      //1 --> Formata mensal
      //2 --> Formata Anual
      if (index == 1) {
        this.vl_faturamento_anual = await funcao.FormataValor(
          this.vl_faturamento_mensal
            .replaceAll("R$", "")
            .replaceAll(".", "")
            .replaceAll(",", ".") * 12
        );
        this.vl_faturamento_mensal = await funcao.FormataValor(
          this.vl_faturamento_mensal
        );
      } else if (index == 2) {
        this.vl_faturamento_mensal = await funcao.FormataValor(
          this.vl_faturamento_anual
            .replaceAll("R$", "")
            .replaceAll(".", "")
            .replaceAll(",", ".") / 12
        );
        this.vl_faturamento_anual = await funcao.FormataValor(
          this.vl_faturamento_anual
        );
      }
    },
    async limpaCadastro() {
      this.contato_selecionado = "";
      this.alteracaoS = false;
      this.limpatudo();
    },

    formata_pc(pc_empresa) {
      var formata = this.pc_empresa;
      formata = parseInt(formata.replace(/[\D]+/g, ""));
      if (formata > 10000) {
        formata = 10000;
      }
      formata = formata + "";
      formata = formata.replace(/([0-9]{2})$/g, ",$1");
      formata = formata + "%";
      if (formata == NaN + "%") {
        formata = 0;
      }
      this.pc_empresa = formata;
      return formata;
    },

    limpatudo() {
      this.nm_nome = "";
      this.cd_rg = "";
      this.cd_cpf = "";
      this.dt_nasc = "";
      this.cd_cep = "";
      this.nm_endereco = "";
      this.nm_cidade = "";
      this.cd_numero = "";
      this.pc_empresa = 0;
      this.cd_telefone = "";
      this.cd_celular = "";
      this.nm_cargo = "";
      this.cd_estado_civil = "";
    },

    socio_selecionado() {
      this.limpatudo();
      this.nm_nome = this.contato_selecionado.nm_razao_contrato;
      this.cd_rg = this.contato_selecionado.cd_ie_rg_contrato;
      this.cd_cpf = this.contato_selecionado.cd_cnpj_cpf_contrato;
      //this.dt_nasc = this.contato_selecionado.dt_nascimento;
      this.cd_cep = this.contato_selecionado.cd_cep;
      this.nm_endereco = this.contato_selecionado.nm_endereco;
      this.nm_cidade = this.contato_selecionado.nm_cidade;
      this.cd_numero = this.contato_selecionado.cd_numero;
      this.pc_empresa = this.contato_selecionado.pc_empresa;
      this.cd_telefone = this.contato_selecionado.cd_telefone;
      this.cd_celular = this.contato_selecionado.cd_celular;
      this.nm_cargo = this.contato_selecionado.nm_cargo;
      this.cd_estado_civil = {
        cd_estado_civil: this.contato_selecionado.cd_estado_civil,
        nm_estado_civil: this.contato_selecionado.nm_estado_civil,
      };
      this.alteracaoS = true;
    },

    async gravaSocio() {
      var retorno = formataData.formataDataSQL(this.dt_nasc);
      if (this.nm_nome == "") {
        notify("Por favor, digite o nome completo");
        return;
      }
      if (this.email == "") {
        notify("Por favor, digite o e-mail");
        return;
      }
      if (this.cd_cpf == "") {
        notify("Por favor, digite o CPF");
        return;
      }
      if (retorno == "--") {
        notify("Por favor, digite a data de nascimento");
        return;
      }
      if (this.cd_cep == "") {
        notify("Por favor, digite o CEP");
        return;
      }
      if (this.cd_numero == "") {
        notify("Por favor, digite o número do endereço");
        return;
      }
      if (
        this.pc_empresa == NaN ||
        this.pc_empresa == 0 ||
        this.pc_empresa == ""
      ) {
        notify("Por favor, digite a (%)");
        return;
      }
      if (this.cd_telefone == "") {
        notify("Por favor, digite o telefone");
        return;
      }
      if (this.cd_celular == "") {
        notify("Por favor, digite o celular");
        return;
      }
      if (this.profissao == "") {
        notify("Por favor, digite a profissão");
        return;
      }

      if (this.nm_cargo == "") {
        notify("Por favor, digite o seu cargo");
        return;
      }
      if (this.cd_estado_civil.cd_estado_civil == "") {
        notify("Por favor, digite o seu estado civil");
        return;
      }

      var api = "706/1073";
      var dados = {
        cd_parametro: 5,
        cd_contrato: this.cd_contrato,
        cd_usuario: localStorage.cd_usuario,
        cd_usuario_inclusao: localStorage.cd_usuario,
        pc_empresa: this.pc_empresa,
        cd_item_cadastro: 1,
        cd_tipo_pessoa: 2,
        cd_ie_rg_contrato: this.cd_rg,
        cd_telefone: this.cd_telefone,
        cd_celular: this.cd_celular,
        cd_cnpj_cpf_contrato: this.cd_cpf,
        nm_razao_contrato: funcao.ValidaString(this.nm_nome),
        cd_cep: this.cd_cep,
        nm_endereco: funcao.ValidaString(this.nm_endereco),
        cd_numero: this.cd_numero,
        nm_complemento: funcao.ValidaString(this.complemento),
        cd_cidade: this.nm_cidade.cd_cidade,
        dt_nascimento: retorno,
        nm_cargo: funcao.ValidaString(this.nm_cargo),
        cd_estado_civil: this.cd_estado_civil.cd_estado_civil,
        cd_cliente: this.cd_cliente_socio,
        nm_email: funcao.ValidaString(this.email),
        nm_bairro: funcao.ValidaString(this.bairro),
        cd_estado: this.sg_estado.cd_estado,
        vl_faturamento_mensal: this.vl_faturamento_mensal,
        vl_faturamento_anual: this.vl_faturamento_anual,
        nm_profissao: funcao.ValidaString(this.profissao),
      };

      //if (this.cd_indicacaoID == 0) {
      //  api = "706/1073";
      //  dados.cd_ficha_venda = this.cd_ficha_vendaID;
      //  dados.cd_item_cadastro = 2;
      //
      if (this.alteracaoS == true) {
        dados.cd_parametro = 10;
      } else {
        dados.cd_parametro = 5;
      }
      this.alteracaoS = true;
      var s = await Incluir.incluirRegistro(api, dados);
      return s[0].Msg;
    },

    async buscaDadosSocio() {
      localStorage.cd_parametro = this.cd_contrato;
      this.load_tela = true;
      let resultado = [];
      try {
        resultado = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          "453/617",
          "${cd_empresa}/${cd_parametro}"
        );
      } catch (error) {
        this.load_tela = false;
      }

      if (resultado.length == 1) {
        this.nm_nome = resultado[0].nm_razao_contrato;
        this.cd_rg = resultado[0].cd_ie_rg_contrato;
        this.cd_cpf = await funcao.FormataCPF(
          resultado[0].cd_cnpj_cpf_contrato
        );
        this.cd_cep = resultado[0].cd_cep;
        this.bairro = resultado[0].nm_bairro;
        this.nm_endereco = resultado[0].nm_endereco;
        this.cd_numero = resultado[0].cd_numero;
        this.complemento = resultado[0].nm_complemento;
        this.nm_cidade = {
          cd_cidade: resultado[0].cd_cidade,
          nm_cidade: resultado[0].nm_cidade,
        };
        this.ic_estado = resultado[0].ic_estado;
        this.pc_empresa = resultado[0].pc_empresa;
        this.cd_telefone = resultado[0].cd_telefone;
        this.cd_celular = resultado[0].cd_celular;
        this.nm_cargo = resultado[0].nm_cargo;
        this.cd_estado_civil = {
          cd_estado_civil: resultado[0].cd_estado_civil,
          nm_estado_civil: resultado[0].nm_estado_civil,
        };
        this.dt_nasc = resultado[0].dt_nascimento;
        this.email = resultado[0].nm_email;
        this.vl_faturamento_anual = resultado[0].vl_faturamento_anual;
        this.vl_faturamento_mensal = resultado[0].vl_faturamento_mensal;
        this.profissao = resultado[0].nm_profissao;

        this.sg_estado = {
          cd_estado: resultado[0].cd_estado,
          sg_estado: resultado[0].sg_estado,
        };
        this.load_tela = false;
      } else {
        this.dt_nasc = "";
        this.nm_nome = "";
        this.cd_rg = "";
        this.cd_cpf = "";
        this.cd_cep = "";
        this.nm_bairro = "";
        this.nm_endereco = "";
        this.cd_numero = "";
        this.nm_complemento = "";
        this.nm_cidade = "";
        this.ic_estado = "";
        this.pc_empresa = "";
        this.cd_telefone = "";
        this.cd_celular = "";
        this.nm_cargo = "";
        this.cd_estado_civil = "";
        this.load_tela = false;
      }
      this.load_tela = false;
    },

    async buscaCep() {
      this.load = true;

      localStorage.cd_cep = this.cd_cep.replace("-", "");
      if (this.cd_cep.includes("_") == false) {
        if (!this.cd_cep.trim() == "") {
          try {
            this.dataSourceConfig = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_cliente,
              "413/550",
              "/${cd_empresa}/${cd_cep}"
            );
            this.nm_endereco = this.dataSourceConfig[0].logradouro;
            this.nm_complemento = this.dataSourceConfig[0].complemento;
            this.ic_estado = this.dataSourceConfig[0].uf;
            this.nm_cidade = {
              cd_cidade: this.dataSourceConfig[0].cd_cidade,
              nm_cidade: this.dataSourceConfig[0].localidade,
            };
            this.sg_estado = {
              cd_estado: this.dataSourceConfig[0].cd_estado,
              sg_estado: this.dataSourceConfig[0].uf,
            };
            this.bairro = this.dataSourceConfig[0].bairro;
            this.load = false;
          } catch {
            this.load = false;
          }
        } else {
          this.load = false;
        }
      } else {
        this.load = false;
      }
      this.load = false;
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}
.duas-tela {
  width: 48%;
}
.quatro-tela {
  width: 23%;
}
.tres-tela {
  width: 31%;
}

@media (max-width: 1145px) {
  .duas-tela {
    width: 98%;
  }

  .quatro-tela {
    width: 98%;
  }
  .tres-tela {
    width: 98%;
  }
}
</style>
