<template>
  <div>
    <h2 class="content-block">{{ tituloMenu }}</h2>
    <div class="sep">
      <div class="botoes-man">
        <div class="alt-but botoes-man">
          <DxButton
            :width="120"
            text="Alterar"
            type="default"
            styling-mode="contained"
            horizontal-alignment="right"
            @click="OnSelecionou()"
          />
        </div>
      </div>
      <div class="dis">
        <q-select
          filled
          label="Manutenção"
          v-model="manutencao_selecionada"
          :options="manutencao"
          option-value="cd_manutencao"
          option-label="nm_manutencao"
          option-disable="inactive"
          emit-value
          map-options
          style="min-width: 250px; max-width: 300px;"
          @input="OnAlterarConta()"
        />
      </div>
    </div>
    <grid
      v-if="manutencao_selecionada != null"
      :cd_menuID="7050"
      :cd_apiID="457"
      ref="grids"
      :cd_consulta="1"
      :nm_json="this.json"
    >
    </grid>

    <div v-if="alterar == true">
      <q-dialog v-model="alterar">
        <q-card style="width: 900px; max-width: 80vw;">
          <q-card-section>
            <div class=" q-gutter-md row items-start Botao-pesquisa">
              <q-input
                class="col"
                type="number"
                v-model="cd_conta"
                label="Conta Contábil"
                :rules="[(val) => !!val || 'Digite a Numeração']"
              />
              <q-input
                class="col"
                v-model="fantasia_destinatario"
                label="Fantasia"
                readonly
              />
              <q-input
                class="col"
                v-model="razao_destinatario"
                label="Razão Destinatário"
                readonly
              />
            </div>
          </q-card-section>
          <q-card-section>
            <div class="q-gutter-md row items-start Botao-pesquisa">
              <q-input class="col" v-model="pessoa" label="Campo" readonly />
              <q-input class="col" v-model="CNPJ" label="CNPJ" readonly />
            </div>
          </q-card-section>
          <q-separator></q-separator>
          <q-card-section>
            <div class="q-gutter-md row items-start Botao-pesquisa">
              <q-select
                filled
                label="Classificação"
                v-model="mascara_selecionada"
                :options="mascara_dataset"
                option-value="cd_conta"
                option-label="nm_conta"
                option-disable="inactive"
                emit-value
                map-options
                css-style="dis"
                style="min-width: 250px; max-width: 300px;"
                @input="SelecionaContaContabil()"
              />
              <q-input
                class="col"
                v-model="this.Mascara"
                label="Classificação"
                readonly
              />
              <q-input
                class="col"
                v-model="this.Conta"
                label="Conta Contábil"
                readonly
              />
            </div>
            <!-- <div class="q-gutter-md row items-start Botao-pesquisa">
            <q-input class="col" v-model="this.mascara_dataset[this.index].nm_conta" label="Conta" readonly/>
             </div>-->
          </q-card-section>
          <q-card-actions align="right">
            <q-btn
              flat
              label="Confirmar"
              v-if="cd_conta > 0"
              @click="onAlterar()"
              color="primary"
              v-close-popup
            />
            <q-btn
              flat
              label="Cancelar"
              @click="limpar()"
              color="primary"
              v-close-popup
            />
          </q-card-actions>
        </q-card>
      </q-dialog>
    </div>

    <!--<div v-if="inserir == true">
         <q-dialog v-model="inserir" >
          <q-card style="width: 900px; max-width: 80vw;">
            <q-card-section>
                <div class="q-gutter-md row items-start Botao-pesquisa">
                    <q-input class="col" type="string" v-model="this.classificacao" label="Classificação"/>
                </div>
                <div>
                    <q-input class="col" type="string" v-model="this.nome_conta" label="Nome"/>
                </div>
          
            </q-card-section>
            <q-card-actions align="right">
                <q-btn flat label="Confirmar" @click="onIncluir()" color="primary" v-close-popup />
                <q-btn flat label="Cancelar"  @click="limpar()" color="primary" v-close-popup />
            </q-card-actions>
          </q-card>
        </q-dialog>
    </div>-->
  </div>
</template>

<script>
import grid from "./grid.vue";
import DxButton from "devextreme-vue/button";

import Menu from "../http/menu";
import Incluir from "../http/incluir_registro";

import cliente from "../views/cliente.vue";
import notify from "devextreme/ui/notify";
import lookup from "../http/lookup";

export default {
  data() {
    return {
      tituloMenu: "",
      cd_mascara_conta: 0,
      cd_digito_verificacao: "",
      cd_conta_reduzido: "",
      nm_conta: "",
      nm_grupo_conta: "",
      json: {
        cd_parametro: 1,
        cd_usuario: localStorage.cd_usuario,
      },
      manutencao: [
        { cd_manutencao: 1, nm_manutencao: "Cliente" },
        { cd_manutencao: 2, nm_manutencao: "Fornecedor" },
        { cd_manutencao: 3, nm_manutencao: "Plano Financeiro" },
      ],
      manutencao_selecionada: null,
      conta: "",
      fantasia_destinatario: "",
      razao_destinatario: "",
      pessoa: "",
      CNPJ: "",
      alterar: false,
      inserir: false,
      mascara_selecionada: null,
      mascara: [],
      mascara_dataset: [],
      cd_conta: 0,
      cd_mascara_conta: 0,
      index: null,
      Mascara: "",
      Conta: 0,
      Nome: "",
      classificacao: "",
      nome_conta: "",
    };
  },
  components: {
    grid,
    DxButton,
    cliente,
  },
  created() {
    this.showMenu();
  },
  methods: {
    async showMenu() {
      let dados = await Menu.montarMenu(
        localStorage.cd_empresa,
        localStorage.cd_menu,
        localStorage.cd_api,
      );
      this.tituloMenu = dados.nm_menu_titulo;
      this.mascara = await lookup.montarSelect(localStorage.cd_empresa, 10);
      console.log(this.mascara);
      this.mascara_dataset = JSON.parse(
        JSON.parse(JSON.stringify(this.mascara.dataset)),
      );
      //this.mascara_dataset[0].cd_conta
      //this.mascara_dataset[0].cd_mascara_conta
      //this.mascara_dataset[0].nm_conta
    },
    async OnSelecionou() {
      this.limpar();
      let Selecionou = await grid.Selecionada();

      this.conta = Selecionou.conta;
      this.fantasia_destinatario = Selecionou.fantasia_destinatario;
      this.razao_destinatario = Selecionou.razao_destinatario;
      this.pessoa = Selecionou.pessoa;
      this.CNPJ = Selecionou.CNPJ;
      this.json = {
        cd_parametro: 1,
        cd_usuario: localStorage.cd_usuario,
      };

      this.alterar = true;
    },

    InserirPlanoConta() {
      this.limpar();
      //Insert into na tabela plano_conta
      this.inserir = true;
    },

    async OnCliente() {
      this.json = {
        cd_parametro: 1,
        cd_usuario: localStorage.cd_usuario,
      };
      Carrega = await this.$refs.grids.carregaDados();
    },
    async OnFornecedor() {
      this.json = {
        cd_parametro: 2,
        cd_usuario: localStorage.cd_usuario,
      };
      Carrega = await this.$refs.grids.carregaDados();
    },
    async OnPlanoFinanceiro() {
      this.json = {
        cd_parametro: 3,
        cd_usuario: localStorage.cd_usuario,
      };
      Carrega = await this.$refs.grids.carregaDados();
    },
    OnAlterarConta() {
      this.limpar();
      if (this.manutencao_selecionada == 1) {
        this.OnCliente();
      } else if (this.manutencao_selecionada == 2) {
        this.OnFornecedor();
      } else if (this.manutencao_selecionada == 3) {
        this.OnPlanoFinanceiro();
      }
    },
    limpar() {
      this.conta = "";
      this.fantasia_destinatario = "";
      this.razao_destinatario = "";
      this.pessoa = "";
      this.CNPJ = "";
      this.cd_mascara_conta = 0;
    },

    async onAlterar() {
      let api = "457/663";
      this.json = {
        cd_parametro: 4,
        cd_empresa: localStorage.cd_empresa,
        cd_conta: this.cd_conta,
        fantasia_destinatario: this.fantasia_destinatario,
        cd_identificacao: this.manutencao_selecionada,
        cd_usuario: localStorage.cd_usuario,
      };
      let a = await Incluir.incluirRegistro(api, this.json);
      console.log(a);
      notify(a[0].Msg);
    },

    // async onIncluir(){
    //     let api = '457/663'
    //     this.json = {
    //         "cd_parametro"           : 5,
    //         "cd_empresa"             : localStorage.cd_empresa,
    //         "cd_conta"               : this.cd_conta,
    //         "classificacao"          : this.classificacao,
    //         "nome_conta"             : this.nome_conta
    //     }
    //     console.log(this.json);
    //     let a  = await Incluir.incluirRegistro(api,this.json);
    //     console.log(a);
    //     notify(a[0].Msg)
    // },

    SelecionaContaContabil() {
      this.index = this.mascara_dataset.findIndex(
        (obj) => obj.cd_conta == this.mascara_selecionada,
      );
      console.log(this.mascara_dataset[this.index]);
      this.Mascara = this.mascara_dataset[this.index].cd_mascara_conta;
      this.Conta = this.mascara_dataset[this.index].cd_conta;
      this.Nome = this.mascara_dataset[this.index].nm_conta;
    },
  },
};
</script>

<style>
.button {
  margin: 5px 10px;
}

.botao-alterar {
  text-align: right;
}
.Botao-pesquisa {
  margin-left: 10px;
  margin-right: 15px;
  padding: none;
}

.Botao-direita {
  align-items: right;
}

.botoes-man {
  display: flex;
  float: right;
}
.sep {
  width: 100%;
  margin: 5px;
}
.dis {
  margin-left: 10px;
}
.alt-but {
  margin-right: 10px;
  align-items: left;
}
.ins-but {
  margin-right: 20px;
  align-items: right;
}
</style>
