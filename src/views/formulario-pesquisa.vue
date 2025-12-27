<template>
  <div style="background: white">
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="alinha_pergunta" style="background: white">
      <div class="text-h4">
        Seja bem-vindo, {{ this.nome_completo.split(" ")[0] }}!
      </div>
      <ol v-if="texto_inicial">
        <li>
          {{ texto_inicial }}
        </li>
        <li v-if="texto_inicial2">
          {{ texto_inicial2 }}
        </li>
      </ol>
      <div class="q-pa-lg flex flex-center">
        <q-pagination
          v-model="step"
          :max="2"
          color="orange-7"
          text-color="black"
          size="20px"
          round
          @click="trocaPage(step)"
        />
      </div>

      <q-linear-progress
        rounded
        size="25px"
        :value="progressao"
        color="orange-7"
      >
        <div class="absolute-full flex flex-center">
          <q-badge
            color="white"
            text-color="orange-7"
            :label="progressao_label"
          ></q-badge>
        </div>
      </q-linear-progress>

      <q-dialog
        v-model="pedeID"
        persistent
        :maximized="maximizedToggle"
        transition-show="slide-up"
        transition-hide="slide-down"
      >
        <q-card>
          <q-bar class="bg-deep-orange-3 text-white text-center">
            <q-space />
          </q-bar>
          <div class="fixed-center item-center text-center">
            <div
              class="text-bold"
              style="font-size: 4vw; padding: 0; margin: 0;"
            >
              Selecione a pesquisa!
            </div>
            <q-select
              v-model="pesquisa"
              :options="this.lookup_pesquisa"
              label="Selecione a pesquisa"
              option-value="cd_pesquisa"
              option-label="nm_pesquisa"
            >
              <template v-slot:prepend>
                <q-icon name="password" />
              </template>
            </q-select>
            <!-- <q-input
              v-model="cd_id_vaga"
              type="number"
              min="0"
              maxlength="12"
              color="black"
              label="ID"
            >
              <template v-slot:prepend>
                <q-icon name="password" />
              </template>
            </q-input> -->
            <q-btn
              class="margin1"
              size="xl"
              icon="done"
              color="positive"
              round
              @click="verificaPesquisa(pesquisa)"
            />
          </div>
        </q-card>
      </q-dialog>

      <div v-if="step == 1">
        <div class="row">
          <q-input
            class="metade-tela espaco-interno"
            v-model="nome_completo"
            :rules="[(val) => !!val || 'Campo obrigatório']"
            color="black"
            label="Nome Completo"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-input>
          <q-input
            class="metade-tela"
            v-model="email"
            :rules="[(val) => !!val || 'Campo obrigatório']"
            color="black"
            label="E-mail"
            @blur="VerificaEntrevistado()"
          >
            <template v-slot:prepend>
              <q-icon name="email" />
            </template>
          </q-input>
        </div>
        <div class="row">
          <q-input
            class="metade-tela"
            v-model="data_nasc"
            mask="##/##/####"
            :rules="[(val) => !!val || 'Campo obrigatório']"
            color="black"
            label="Data de Nascimento"
          >
            <template v-slot:prepend>
              <q-btn
                round
                icon="event"
                text-color="black"
                class="cursor-pointer"
                color="orange-7"
                size="sm"
              >
                <q-popup-proxy
                  ref="qDateProxy"
                  cover
                  transition-show="scale"
                  transition-hide="scale"
                >
                  <q-date
                    class="qdate fixed-center item-center text-center data-pop"
                    v-model="dt_picker"
                    @input="Data()"
                    color="orange-7"
                  >
                    <div class="row items-center justify-end">
                      <q-btn
                        v-close-popup
                        round
                        color="orange-7"
                        icon="close"
                        size="sm"
                      />
                    </div>
                  </q-date>
                </q-popup-proxy>
              </q-btn>
            </template>
          </q-input>

          <div
            class="metade-tela items-center justify-center self-center"
            style="margin-left:1%"
          >
            <label class="text-bold">Sexo:</label>
            <q-radio
              v-model="sexo"
              color="orange-7"
              :val="1"
              label="Masculino"
            />
            <q-radio
              v-model="sexo"
              color="orange-7"
              :val="2"
              label="Feminino"
            />
          </div>
        </div>

        <div class="row">
          <q-input
            class="metade-tela"
            style="margin: 3.5px"
            v-model="celular"
            mask="(##) #####-####"
            :rules="[(val) => !!val || 'Campo obrigatório']"
            color="black"
            label="Celular"
            @blur="VerificaEntrevistado()"
          >
            <template v-slot:prepend>
              <q-icon name="smartphone" />
            </template>
          </q-input>

          <q-select
            label="Grau de instrução"
            v-model="escolaridade"
            input-debounce="0"
            class="metade-tela"
            style="margin: 3.5px"
            :options="this.dataset_dados_grau"
            option-value="cd_grau_instrucao"
            option-label="nm_grau_instrucao"
            :rules="[(val) => !!val || 'Campo obrigatório']"
          >
            <template v-slot:prepend>
              <q-icon name="school" />
            </template>
          </q-select>
        </div>
        <div class="row">
          <q-input
            class="umTercoTela espaco-interno"
            v-model="CEP"
            :rules="[(val) => !!val || 'Campo obrigatório']"
            color="black"
            label="CEP"
            mask="#####-###"
            :loading="load_CEP"
            debounce="1200"
            @input="BuscaCEP"
          >
            <template v-slot:prepend>
              <q-icon name="map" />
            </template>
          </q-input>
          <q-input
            class="umTercoTela espaco-interno"
            v-model="endereco"
            :rules="[(val) => !!val || 'Campo obrigatório']"
            color="black"
            :loading="load_CEP"
            label="Endereço"
          >
            <template v-slot:prepend>
              <q-icon name="pin_drop" />
            </template>
          </q-input>
          <q-input
            class="umTercoTela espaco-interno"
            v-model="end_numero"
            :rules="[(val) => !!val || 'Campo obrigatório']"
            color="black"
            label="Número"
          >
            <template v-slot:prepend>
              <q-icon name="pin" />
            </template>
          </q-input>
          <q-select
            label="Estado"
            v-model="estado"
            input-debounce="0"
            class="metade-tela"
            style="margin: 3.5px"
            :options="dataset_dados_estado"
            option-value="cd_estado"
            option-label="nm_estado"
            :rules="[(val) => !!val || 'Campo obrigatório']"
            :loading="load_CEP"
            @input="SelectEstado"
          >
            <template v-slot:prepend>
              <q-icon name="location_city" />
            </template>
          </q-select>
          <q-select
            label="Cidade"
            v-model="cidade"
            :disable="estado"
            input-debounce="0"
            class="metade-tela"
            style="margin: 3.5px"
            :options="dataset_dados_cidade"
            option-value="cd_cidade"
            option-label="nm_cidade"
            :loading="load_CEP"
            :rules="[(val) => !!val || 'Campo obrigatório']"
          >
            <template v-slot:prepend>
              <q-icon name="location_city" />
            </template>
          </q-select>
          <q-input
            class="metade-tela espaco-interno"
            v-model="bairro"
            :rules="[(val) => !!val || 'Campo obrigatório']"
            color="black"
            :loading="load_CEP"
            label="Bairro"
          >
            <template v-slot:prepend>
              <q-icon name="emoji_transportation" />
            </template>
          </q-input>
          <q-input
            class="metade-tela espaco-interno"
            v-model="complemento"
            :rules="[(val) => !!val || 'Campo obrigatório']"
            color="black"
            :loading="load_CEP"
            label="Complemento"
          >
            <template v-slot:prepend>
              <q-icon name="circle" />
            </template>
          </q-input>
        </div>

        <q-toggle
          v-model="ic_trabalhando"
          color="orange-7"
          icon="check"
          text-color="black"
          label="Trabalhando"
        ></q-toggle>
        <q-input
          class="metade-tela espaco-interno"
          v-model="Empresa_atual"
          v-if="ic_trabalhando == true"
          label="Empresa Atual"
        >
          <template v-slot:prepend>
            <q-icon name="business" />
          </template>
        </q-input>
        <div class="row">
          <q-input
            class="metade-tela espaco-interno"
            v-model="salario_atual"
            @blur="FormataMoeda"
            v-if="ic_trabalhando == true"
            hint="Campo opcional!"
            maxlength="8"
            label="Remuneração Atual (Fixo + Variável)"
          >
            <template v-slot:prepend>
              <q-icon name="paid" />
            </template>
          </q-input>

          <q-select
            class="metade-tela espaco-interno"
            v-if="ic_trabalhando == true"
            label="Cargo Atual"
            v-model="cargo_atual"
            input-debounce=""
            :options="this.dataset_dados_cargo"
            option-value="cd_cargo_funcionario"
            option-label="nm_cargo_funcionario"
            :rules="[(val) => !!val || 'Campo obrigatório']"
          >
            <template v-slot:prepend>
              <q-icon name="work" />
            </template>
          </q-select>
        </div>
        <q-input
          class="metade-tela espaco-interno"
          v-model="Empresa_atual"
          v-if="ic_trabalhando == false"
          label="Última Empresa"
        >
          <template v-slot:prepend>
            <q-icon name="business" />
          </template>
        </q-input>
        <div class="row">
          <q-input
            class="metade-tela espaco-interno"
            v-model="salario_atual"
            @blur="FormataMoeda"
            v-if="ic_trabalhando == false"
            hint="Campo opcional!"
            label="Última Remuneração (Fixo + Variável)"
          >
            <template v-slot:prepend>
              <q-icon name="paid" />
            </template>
          </q-input>

          <q-select
            class="metade-tela espaco-interno"
            v-if="ic_trabalhando == false"
            label="Último Cargo"
            v-model="cargo_atual"
            input-debounce=""
            :options="this.dataset_dados_cargo"
            option-value="cd_cargo_funcionario"
            option-label="nm_cargo_funcionario"
            :rules="[(val) => !!val || 'Campo obrigatório']"
          >
            <template v-slot:prepend>
              <q-icon name="work" />
            </template>
          </q-select>
        </div>

        <q-btn
          push
          color="orange-7"
          v-if="cd_entrevistado == 0"
          label="Próximo"
          text-color="black"
          class="botaoProximo"
          @click="NovoCandidato()"
        />
        <q-btn
          push
          color="orange-7"
          v-if="cd_entrevistado != 0"
          label="Próximo"
          text-color="black"
          class="botaoProximo"
          @click="AtualizaEntrevistado()"
        />
      </div>

      <div v-if="step == 2">
        <div v-for="(x, index) in dados_formulario.length" :key="index">
          <div class="margin1 borda-bloco shadow-2">
            <div class="row margin1 items-center text-bold" :tabindex="x">
              <q-badge rounded color="orange" text-color="black" :label="x" />
              <div class="margin1">
                {{ dados_formulario[index].nm_questao_pesquisa }}
              </div>
            </div>

            <q-input
              v-if="dados_formulario[index].cd_tipo_pergunta == 1"
              class="margin1"
              maxlength="200"
              :readonly="LeForm"
              v-model="dados_formulario[index].nm_resposta"
              label="Resposta"
            />
            <q-option-group
              v-if="dados_formulario[index].cd_tipo_pergunta == 2"
              v-model="dados_formulario[index].nm_resposta"
              :options="dados_formulario[index].alternativas"
              color="orange-9"
              @input="
                SelecionouAlt(
                  dados_formulario[index].nm_resposta,
                  dados_formulario[index],
                  index,
                )
              "
            />
            <q-option-group
              v-if="dados_formulario[index].cd_tipo_pergunta == 3"
              v-model="dados_formulario[index].nm_resposta"
              :options="dados_formulario[index].alternativas"
              color="orange-9"
              type="checkbox"
              @input="
                SelecionouAlt(
                  dados_formulario[index].nm_resposta,
                  dados_formulario[index],
                  index,
                )
              "
            />
            <div
              v-if="dados_formulario[index].cd_tipo_pergunta == 4"
              class="margin1"
            >
              {{ "Não"
              }}<q-toggle
                class="margin1"
                v-model="dados_formulario[index].nm_resposta"
                :disable="LeForm"
                :false-value="'Não'"
                :true-value="'Sim'"
                color="orange-9"
                @input="
                  SelecionouAlt(
                    dados_formulario[index].nm_resposta,
                    dados_formulario[index],
                    index,
                  )
                "
              />{{ "Sim" }}
            </div>
            <q-rating
              v-if="dados_formulario[index].cd_tipo_pergunta == 6"
              class="margin1"
              v-model="dados_formulario[index].nm_resposta"
              :readonly="LeForm"
              size="2em"
              max="4"
              color="orange-9"
            />
          </div>
        </div>
        <q-btn
          push
          color="orange-7"
          label="Anterior"
          text-color="black"
          class="botaoProximo"
          @click="step = 1"
        />
        <q-btn
          push
          color="orange-7"
          label="Finalizar"
          text-color="black"
          class="botaoProximo"
          @click="PreencheQuestionario()"
        />
      </div>
    </div>
    <q-toolbar>
      <q-space />
      <div class="text-bold">Todos os direitos reservados.</div>
    </q-toolbar>

    <q-dialog v-model="load" maximized persistent>
      <carregando :corID="'orange-9'"></carregando>
    </q-dialog>
  </div>
</template>

<script>
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import ptMessages from "devextreme/localization/messages/pt.json";
import Lookup from "../http/lookup";
import select from "../http/select";
import { Notify } from "quasar";

import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import formataData from "../http/formataData";
import carregando from "../components/carregando.vue";
import funcao from "../http/funcoes-padroes";

export default {
  data() {
    return {
      load: false,
      texto_inicial:
        "Antes de realizar a pesquisa, pedimos que informe os seus dados.",
      texto_inicial2:
        "Caso algum dado esteja incorreto, basta alterá-lo para atualizarmos seu cadastro. Vamos lá ?",
      progressao: 0.48,
      LeForm: false,
      CEP: "",
      load_CEP: false,
      endereco: "",
      end_numero: "",
      estado: "",
      dataset_dados_estado: "",
      cidade: "",
      dataset_dados_cidade: "",
      bairro: "",
      complemento: "",
      progressao_label: "1/2",
      cd_item: 1,
      pedeID: true,
      cd_usuario: 0,
      cd_id_vaga: "",
      pesquisa: "",
      lookup_pesquisa: "",
      cd_entrevistado: 0,
      perguntas_obrigatorias: false,
      dados_formulario: [],
      dados_formulario_completo: [],
      nm_resposta: "",
      contador_erro_id: 0,
      dados_candidato: [],
      tituloMenu: "Avaliação de Perfil",
      dt_inicial: "",
      dt_final: "",
      maximizedToggle: true,
      ic_trabalhando: false,
      img_logo:
        "http://www.egisnet.com.br/img/logo_supervendedores_sem_fundo.jpg",
      img_logo_footer:
        "http://www.egisnet.com.br/img/logo_supervendedores_redondo.jpg",
      logo_gbs: "",
      cd_empresa: 0,
      cd_cliente: 0,
      step: 1,
      nome_completo: "",
      email: "",
      sexo: 0,
      Empresa_atual: "",
      salario_atual: "",
      cargo_atual: "",
      celular: "",
      escolaridade: {
        nm_grau_instrucao: "",
        cd_grau_instrucao: 0,
      },
      filtra: [],
      hierarquia: "",
      empresa_desejada: "",
      data_nasc: "",
      dt_picker: "",
      api: "908/1406", //Procedimento 1764 - pr_montagem_pesquisa
      cd_candidato: 0,
      dados_grau: {},
      dataset_dados_grau: [],
      dados_cargo: {},
      dataset_dados_cargo: [],
      array_perguntas: [],
      resultado_cvat: [],
      existe_vaga: [],
    };
  },
  async created() {
    this.load = true;
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    this.progressao_label = "1/3"; //this.progressao * 100 + '%';

    //localStorage.cd_empresa = 153;
    this.cd_empresa = localStorage.cd_empresa;
    this.cd_usuario = localStorage.cd_usuario;
    /*----------------------------------------------------------------------------------------------------*/
    let itens_pesquisa = await Lookup.montarSelect(
      localStorage.cd_empresa,
      387,
    );
    this.lookup_pesquisa = JSON.parse(itens_pesquisa.dataset);
    /*----------------------------------------------------------------------------------------------------*/

    this.dados_grau = await Lookup.montarSelect(localStorage.cd_empresa, 335);
    this.dataset_dados_grau = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_grau.dataset)),
    );
    /*----------------------------------------------------------------------------------------------------*/

    this.dados_cargo = await Lookup.montarSelect(localStorage.cd_empresa, 336);
    this.dataset_dados_cargo = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_cargo.dataset)),
    );
    /*----------------------------------------------------------------------------------------------------*/
    [this.dataset_dados_estado] = await select.montarSelect(this.cd_empresa, {
      cd_empresa: this.cd_empresa,
      cd_tabela: 96,
      order: "D",
      where: [{ cd_pais: 1 }],
    });
    this.dataset_dados_estado = JSON.parse(
      JSON.parse(JSON.stringify(this.dataset_dados_estado.dataset)),
    );
    /*----------------------------------------------------------------------------------------------------*/

    //this.img_logo = 'https://supervendedores.com.br/wp-content/uploads/2020/05/logo-branco.png'
    this.logo_gbs =
      "http://gbstec.com.br/wp-content/uploads/2019/10/Logo-novo-gbs-menor.png";
    this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();
    this.dt_final = new Date(localStorage.dt_final).toLocaleDateString();
    this.hoje = new Date().toLocaleDateString();
    var h = new Date().toLocaleTimeString();
    this.hora = h.substring(0, 5);
    this.load = false;
  },

  updated() {
    if (this.step == 1) {
      this.progressao = 0.48;
      this.progressao_label = "1/2"; //this.progressao * 100 + '%';
      this.texto_inicial =
        "Antes de realizar a pesquisa, pedimos que informe os seus dados.";
      this.texto_inicial2 =
        "Caso algum dado esteja incorreto, basta alterá-lo para atualizarmos seu cadastro. Vamos lá ?";
    } else if (this.step == 2) {
      this.progressao = 0.98;
      this.progressao_label = "2/2"; //this.progressao * 100 + '%';
      this.texto_inicial =
        "Preencha o formulário abaixo, antes de iniciar a pesquisa.";
      this.texto_inicial2 = "";
    }
  },

  components: {
    carregando,
  },

  methods: {
    async verificaPesquisa(e) {
      if (this.pesquisa == "") {
        notify("Selecione uma pesquisa");
      } else {
        this.pedeID = false;
        await this.MontagemFormulario(e);
      }
    },

    async VerificaEntrevistado() {
      if (!!this.cd_entrevistado == false) {
        var dados_verificacao = {
          cd_parametro: 0,
          nm_email: this.email,
          nm_celular: this.celular,
        };
        var candidato_encontrado = await Incluir.incluirRegistro(
          this.api,
          dados_verificacao,
        );
        if (candidato_encontrado[0].Cod === 0) {
          //Candidato não cadastrado
          return;
        } else {
          //Entrevistado cadastrado, e traz as informações dele
          this.cd_entrevistado = candidato_encontrado[0].cd_entrevistado;
          this.nome_completo = candidato_encontrado[0].nm_entrevistado;

          this.email == ""
            ? (this.email = candidato_encontrado[0].nm_email)
            : "";
          this.celular == ""
            ? (this.celular = candidato_encontrado[0].nm_celular)
            : "";
          this.data_nasc = formataData.formataDataJS(
            candidato_encontrado[0].dt_nascimento,
          );
          this.sexo = candidato_encontrado[0].cd_sexo;

          this.escolaridade = {
            cd_grau_instrucao: candidato_encontrado[0].cd_grau_instrucao,
            nm_grau_instrucao: candidato_encontrado[0].nm_grau_instrucao,
          };
          this.cargo_atual = {
            cd_cargo_funcionario: candidato_encontrado[0].cd_cargo_funcionario,
            nm_cargo_funcionario: candidato_encontrado[0].nm_cargo_funcionario,
          };
          this.ic_trabalhando =
            candidato_encontrado[0].ic_trabalhando == "S" ? true : false;
          this.Empresa_atual = candidato_encontrado[0].nm_empresa;
          this.salario_atual = candidato_encontrado[0].nm_remuneracao;
          //CEP

          this.CEP = candidato_encontrado[0].cd_cep;
          this.endereco = candidato_encontrado[0].nm_endereco;
          this.end_numero = candidato_encontrado[0].cd_numero;
          this.estado = this.dataset_dados_estado.filter(
            (e) => e.cd_estado === candidato_encontrado[0].cd_estado,
          );
          this.cidade = this.dataset_dados_cidade.filter(
            (c) => c.cd_cidade === candidato_encontrado[0].cd_cidade,
          );
          this.bairro = candidato_encontrado[0].nm_bairro;
          this.complemento = candidato_encontrado[0].nm_complemento;
          //Endereco numero, estado cidade bairro complemento
          this.FormataMoeda();
        }
      }
    },

    async FormataMoeda() {
      this.salario_atual = await funcao.FormataValor(this.salario_atual);
    },

    async NovoCandidato() {
      if (this.data_nasc == "") {
        return notify("Por favor, preencha a data de nascimento!");
      }
      if (this.nome_completo == "") {
        return notify("Por favor, preencha o nome completo!");
      }
      if (this.email == "") {
        return notify("Por favor, preencha o e-mail!");
      }
      if (this.celular == "") {
        return notify("Por favor, preencha o telefone!");
      }
      await this.VerificaEntrevistado();
      let ic_trabalhando_atualiza = this.ic_trabalhando ? "S" : "N";
      var data = formataData.formataDataSQL(this.data_nasc);
      var novo = {
        cd_parametro: 3,
        cd_usuario: localStorage.cd_usuario,
        cd_cep: this.CEP,
        nm_endereco: this.endereco,
        cd_numero: this.end_numero,
        cd_estado: this.estado.cd_estado,
        cd_cidade: this.cidade.cd_cidade,
        nm_bairro: this.bairro,
        nm_complemento: this.complemento,
        cd_item_requisicao_vaga: this.cd_item,
        nm_entrevistado: funcao.ValidaString(this.nome_completo, 70),
        nm_email: funcao.ValidaString(this.email, 70),
        nm_celular: this.celular,
        dt_nascimento: data,
        cd_sexo: this.sexo,
        nm_empresa: funcao.ValidaString(this.Empresa_atual, 60),
        nm_remuneracao: this.salario_atual
          .replaceAll(".", "")
          .replace("R$", ""),
        cd_cargo: this.cargo_atual.cd_cargo_funcionario,
        nm_cargo_atual: this.cargo_atual.nm_cargo_funcionario,
        cd_escolaridade: this.escolaridade.cd_grau_instrucao,
        nm_escolaridade: this.escolaridade.nm_grau_instrucao,
        nm_hierarquia: this.hierarquia,
        nm_empresa_desejada: this.empresa_desejada,
        ic_trabalhando: ic_trabalhando_atualiza,
      };
      this.load = true;
      var novo_candidato = await Incluir.incluirRegistro(this.api, novo);
      this.load = false;
      this.cd_candidato = novo_candidato[0].cd_entrevistado;
      notify(novo_candidato[0].Msg);
      if (novo_candidato[0].Cod == 0) {
        this.cd_candidato = 0;
        return;
      } else {
        this.step = 2;
      }
    },

    async AtualizaEntrevistado() {
      if (this.data_nasc == "") {
        return notify("Por favor, preencha a data de nascimento!");
      }
      if (this.nome_completo == "") {
        return notify("Por favor, preencha o nome completo!");
      }
      if (this.email == "") {
        return notify("Por favor, preencha o e-mail!");
      }
      if (this.celular == "") {
        return notify("Por favor, preencha o telefone!");
      }
      let ic_trabalhando_atualiza = this.ic_trabalhando ? "S" : "N";
      var data = formataData.formataDataSQL(this.data_nasc);
      var up = {
        cd_parametro: 2,
        cd_entrevistado: this.cd_entrevistado,
        nm_entrevistado: funcao.ValidaString(this.nome_completo, 70),
        nm_email: funcao.ValidaString(this.email, 70),
        nm_celular: this.celular,
        dt_nascimento: data,
        cd_sexo: this.sexo,
        nm_empresa: funcao.ValidaString(this.Empresa_atual, 60),
        vl_salario: this.salario_atual.replaceAll(".", "").replace("R$", ""),
        cd_cargo_funcionario: this.cargo_atual.cd_cargo_funcionario,
        cd_escolaridade: this.escolaridade.cd_grau_instrucao,
        ic_trabalhando: ic_trabalhando_atualiza,
        cd_cep: this.CEP,
        nm_endereco: this.endereco,
        cd_numero: this.end_numero,
        cd_estado: this.estado.cd_estado,
        cd_cidade: this.cidade.cd_cidade,
        nm_bairro: this.bairro,
        nm_complemento: this.complemento,
      };
      this.load = true;
      var up_entrevistado = await Incluir.incluirRegistro(this.api, up);

      this.load = false;
      this.step = 2;
      notify(up_entrevistado[0].Msg);
    },

    async PreencheQuestionario() {
      let falta_questoes = false;
      for (let v = 0; v < this.dados_formulario.length; v++) {
        if (
          this.dados_formulario[v].cd_tipo_pergunta == 1 &&
          this.dados_formulario[v].nm_resposta != null
        ) {
          this.dados_formulario[v].nm_resposta = funcao.ValidaString(
            this.dados_formulario[v].nm_resposta,
          );
        }
        if (
          this.dados_formulario[v].nm_resposta === null ||
          this.dados_formulario[v].nm_resposta === "" ||
          this.dados_formulario[v].nm_resposta === 0 ||
          this.dados_formulario[v].nm_resposta == undefined
        ) {
          falta_questoes = true;
          return notify(`Preencha todas as questões do formulário!`);
        }
      }

      let dados_formulario_salvar = this.dados_formulario.map(
        ({
          alternativas,
          cd_controle,
          qt_cliente_pesquisa,
          qt_resposta_pesquisa,
          ...demais
        }) => demais,
      );
      dados_formulario_salvar.map((i) => {
        if (i.cd_tipo_pergunta === 3) {
          i.nm_resposta = i.nm_resposta.toString().replaceAll(",", " | ");
        }
      });
      var dados_formulario = {
        cd_parametro: 5,
        cd_usuario: localStorage.cd_usuario,
        json_formulario: dados_formulario_salvar,
      };
      var resultado_save = await Incluir.incluirRegistro(
        this.api,
        dados_formulario,
      );
      return notify(resultado_save[0].Msg);
    },

    async BuscaCEP() {
      if (this.CEP.length === 9) {
        try {
          this.load_CEP = true;
          let [cep_encontrado] = await funcao.buscaCep(this.CEP);
          this.bairro = cep_encontrado.bairro;
          [this.estado] = this.dataset_dados_estado.filter(
            (e) => e.cd_estado == cep_encontrado.cd_estado,
          );
          [this.dataset_dados_cidade] = await select.montarSelect(
            this.cd_empresa,
            {
              cd_empresa: this.cd_empresa,
              cd_tabela: 97,
              order: "D",
              where: [{ cd_pais: 1, cd_estado: this.estado.cd_estado }],
            },
          );
          this.dataset_dados_cidade = JSON.parse(
            JSON.parse(JSON.stringify(this.dataset_dados_cidade.dataset)),
          );
          [this.cidade] = this.dataset_dados_cidade.filter(
            (e) => e.cd_cidade == cep_encontrado.cd_cidade,
          );
          this.complemento = cep_encontrado.complemento;
          this.endereco = cep_encontrado.logradouro;
          this.load_CEP = false;
        } catch {
          this.load_CEP = false;
          notify("CEP não encontrado!");
        }
      } else {
        notify("CEP digitado incorretamente!");
      }
    },

    async SelectEstado() {
      [this.dataset_dados_cidade] = await select.montarSelect(this.cd_empresa, {
        cd_empresa: this.cd_empresa,
        cd_tabela: 97,
        order: "D",
        where: [{ cd_pais: 1, cd_estado: this.estado.cd_estado }],
      });
      this.dataset_dados_cidade = JSON.parse(
        JSON.parse(JSON.stringify(this.dataset_dados_cidade.dataset)),
      );
    },

    async MontagemFormulario(e, y) {
      var formulario = {
        cd_parametro: 1,
        cd_pesquisa: e.cd_pesquisa,
      };
      this.dados_formulario_completo = await Incluir.incluirRegistro(
        this.api,
        formulario,
      );
      this.dados_formulario_completo.map((e) => {
        e.alternativas = JSON.parse(JSON.parse(JSON.stringify(e.alternativas)));
        if (e.cd_tipo_pergunta == 3) {
          e.nm_resposta = [];
        }
        if (e.cd_tipo_pergunta == 4) {
          e.nm_resposta = "Não";
        }
        if (e.cd_tipo_pergunta == 6) {
          e.nm_resposta = 0;
        }
      });
      this.dados_formulario = this.dados_formulario_completo.filter(
        (o) => o.ic_pergunta_eliminatoria == "S",
      );
      if (this.dados_formulario.length == 0) {
        this.dados_formulario = this.dados_formulario_completo;
      }
    },

    Data() {
      var ano = this.dt_picker.substring(0, 4);
      var mes = this.dt_picker.substring(5, 7);
      var dia = this.dt_picker.substring(8, 10);
      this.data_nasc = dia + mes + ano;
    },

    async SelecionouAlt(resp, obj, index) {
      this.dados_formulario_completo[index].nm_resposta = resp;
      if (
        this.dados_formulario.every(
          (v) => v.nm_resposta == 1 || v.nm_resposta === "Sim",
        ) &&
        this.dados_formulario.length != this.dados_formulario_completo.length
      ) {
        this.dados_formulario = this.dados_formulario_completo;
      }
    },

    async trocaPage(step) {
      //   if (this.cd_candidato == 0) {
      //     notify("Por favor, preencha os dados do candidato!");
      //     return (this.step = 1);
      //   }
      //   if (step == 2) {
      //     if (this.cd_candidato != 0) {
      //       this.AtualizaEntrevistado();
      //     }
      //   }
    },
  },
};
</script>

<style scooped>
@import url("./views.css");
.input {
  width: 33%;
}
.margin1 {
  margin: 0.5% 0.4%;
  padding: 0;
}

.botaoProximo {
  margin: 3% 0.5%;
}

.alinha_pergunta {
  margin: 1% 5vw;
}
.espaco-interno {
  margin: auto 2% auto 0%;
}
.pergunta {
  font-size: 18px;
  font-weight: bold;
}
.questao {
  border: 1px solid;
  padding: 10px;
  border-radius: 20%;
  margin: 5px 5px 5px 7px;
}
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
  margin: 0.5vw;
}

.data-pop {
  flex-direction: none !important;
}

.centralizado {
  text-align: center;
}

.qdate {
  width: 310px;
  overflow-x: hidden;
}

.metade-tela {
  width: 48% !important;
}
.line {
  display: inline-flex;
}
.card-questoes {
  width: 20vw;
}

@media (max-width: 920px) {
  .metade-tela {
    width: 100% !important;
  }
  .card-questoes {
    width: 100%;
  }
  .line {
    display: block;
  }
}
</style>
