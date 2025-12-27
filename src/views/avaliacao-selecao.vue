<template>
  <div style="background: white">
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <q-toolbar class="cvat-header">
      <q-img
        :src="img_logo"
        class="imagem-header alinha_pergunta"
        spinner-color="white"
      />
      <q-space />
      <a href="https://www.facebook.com/SuperVendedores/" target="_blank">
        <q-icon name="instagram" color="white" style="font-size:2em" />
        <q-tooltip
          class="bg-indigo"
          :offset="[10, 10]"
          transition-show="flip-right"
          transition-hide="flip-left"
          anchor="center left"
          self="center right"
        >
          Página do Facebook
        </q-tooltip>
      </a>
    </q-toolbar>
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
          :max="3"
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
        class="instrucoes"
        v-model="instrucoes"
        persistent
        :maximized="maximizedToggle"
        transition-show="slide-up"
        transition-hide="slide-down"
      >
        <q-card>
          <q-bar class="bg-deep-orange-3 text-white text-center">
            Instruções de Preenchimento de Questão C-VAT
          </q-bar>

          <q-card-section v-if="array_perguntas_ex.length > 0">
            <div class="line">
              <q-card
                class="card-questoes2 margin1 text-center"
                v-for="y in 4"
                v-bind:key="y"
              >
                <q-card-section>
                  <label class="pergunta">{{
                    array_perguntas_ex[y - 1].pergunta
                  }}</label>
                  <q-separator />
                  <q-rating
                    v-model="array_perguntas_ex[y - 1].resposta"
                    size="3.1em"
                    color="orange-7"
                    :readonly="true"
                    max="4"
                    tabindex=""
                  >
                    <template v-slot:tip-1>
                      <q-tooltip>Ruim</q-tooltip>
                    </template>
                    <template v-slot:tip-2>
                      <q-tooltip>Razoável</q-tooltip>
                    </template>
                    <template v-slot:tip-3>
                      <q-tooltip>Bom</q-tooltip>
                    </template>
                    <template v-slot:tip-4>
                      <q-tooltip>Ótimo</q-tooltip>
                    </template>
                  </q-rating>
                </q-card-section>
              </q-card>
            </div>
            <h4><b>Instruções para preenchimento do CVAT SALES</b></h4>
            <ol>
              <b>
                <li>Prefira preencher no computador ao invés do celular.</li>
                <br />
                <li>
                  Coloque as frases em ordem de sua preferência, sendo 4
                  estrelas para a frase que você mais gosta e 1 para a que você
                  menos gosta.
                </li>
                <br />
                <li>
                  Confira se preencheu todo o questionário antes de tentar
                  concluir.
                </li>
                <br />
                <li>
                  Cada conjunto de 4 frases são avaliados independente das
                  respostas anteriores.
                </li>
                <br />
                <li>
                  O formulário não tem pegadinhas. Não importa se você deu 4
                  para algo e agora tem que dar 1 para algo parecido, pois as
                  outras três frases são diferentes.
                </li>
                <br />
                <li>
                  Responda com sinceridade, ou o laudo não te ajudará em nada.
                </li>
                <br />
                <li>
                  Responda como foco em como você é hoje, não ‘’como você
                  gostaria de ser’’ ou acha bonito ser. Não tente esconder
                  coisas, ou responder o que acha mais certo.
                </li>
                <br />
                <li>
                  Não existe certo e errado. Não existe perfil bom ou ruim.
                  Existe o seu perfil e é ele que queremos conhecer!
                </li>
                <br />
                <li>
                  Não tente separar seu perfil em profissional/vida pessoal,
                  responda com base no que você realmente sente.
                </li>
                <br />
                <li>
                  Em caso de dúvida, opte sempre pelo que foi sua primeira
                  impressão.
                </li>
                <br />
                <li>
                  Existirão conjuntos que você pode não gostar de nenhuma frase,
                  ou gostar de todas as frases, mesmo assim você terá que
                  colocar em uma ordem.
                </li>
                <br />
                <li>
                  Certifique-se de que ao finalizar, não apareceu uma mensagem
                  falando que faltou alguma coisa.
                </li>
                <br />
              </b>
            </ol>
            <q-checkbox
              v-model="ic_instrucao"
              label="`Li e concordo com os termos e instruções.`"
              size="xl"
              color="orange-9"
            ></q-checkbox>
          </q-card-section>
          <div class="row">
            <div class="col items-center text-center">
              <q-btn
                round
                size="lg"
                color="green-5"
                icon="check"
                @click="onAceite()"
              />
            </div>
          </div>
        </q-card>
      </q-dialog>

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
              Digite o seu ID do C-VAT!
            </div>
            <q-input
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
            </q-input>
            <q-btn
              class="margin1"
              size="xl"
              icon="done"
              color="positive"
              round
              @click="verificaVaga(cd_id_vaga)"
            />
          </div>
        </q-card>
      </q-dialog>

      <q-dialog
        v-model="agradecimento"
        persistent
        :maximized="maximizedToggle"
        transition-show="slide-up"
        transition-hide="slide-down"
      >
        <q-card>
          <q-bar class="bg-deep-orange-3 text-white text-center">
            <q-space />
          </q-bar>
          <q-card-section
            class="q-pa-none fixed-center item-center text-center"
          >
            <q-btn size="xl" round icon="done" color="positive" />
            <div class="text-bold text-h3">Obrigado!</div>
            <div class="text-h6">Avaliação C-VAT concluída com sucesso!</div>
            <div class="col centralizado">
              <div class="row">
                <div class="col">
                  <q-img
                    :src="img_logo_footer"
                    class="imagem-middle"
                    spinner-color="white"
                  />
                </div>
              </div>

              <a
                href="https://www.instagram.com/SuperVendedores/"
                target="_blank"
              >
                <q-img
                  style="height: 75px; max-width: 75px; margin: 2%"
                  src="https://policiacivil.pb.gov.br/imagens/capa/instagram.png/@@images/3302391d-ecd4-40a0-b294-06c606c889e8.png"
                  alt="INSTAGRAM"
                >
                  <q-tooltip
                    class="bg-indigo"
                    :offset="[10, 10]"
                    transition-show="flip-right"
                    transition-hide="flip-left"
                    anchor="center left"
                    self="center right"
                  >
                    Instagram
                  </q-tooltip>
                </q-img>
              </a>

              <a href="https://supervendedores.com.br/" target="_blank">
                <q-icon
                  name="language"
                  color="black"
                  style="font-size:4em; margin: 2%"
                />
                <q-tooltip
                  class="bg-indigo"
                  :offset="[10, 10]"
                  transition-show="flip-right"
                  transition-hide="flip-left"
                  anchor="center left"
                  self="center right"
                >
                  Site
                </q-tooltip>
              </a>

              <a
                href="https://www.youtube.com/c/SupervendedoresBr"
                target="_blank"
              >
                <q-img
                  style="height: 63px; max-width: 63px; margin: 2%"
                  src="https://cdn-icons-png.flaticon.com/512/1077/1077046.png"
                  alt="Youtube"
                >
                  <q-tooltip
                    class="bg-indigo"
                    :offset="[10, 10]"
                    transition-show="flip-right"
                    transition-hide="flip-left"
                    anchor="center left"
                    self="center right"
                  >
                    Youtube
                  </q-tooltip>
                </q-img>
              </a>

              <a
                href="https://open.spotify.com/show/4U2BlsHRMYGIKpXgAcl613?si=299a49e103aa4fe5"
                target="_blank"
              >
                <q-img
                  style="height: 58px; max-width: 58px; margin: 2%"
                  src="https://icons-for-free.com/iconfiles/png/512/simple+and+minimal+line+icons+spotify-1324450581038445238.png"
                  alt="Spotify"
                >
                  <q-tooltip
                    class="bg-indigo"
                    :offset="[10, 10]"
                    transition-show="flip-right"
                    transition-hide="flip-left"
                    anchor="center left"
                    self="center right"
                  >
                    Spotify
                  </q-tooltip>
                </q-img>
              </a>
            </div>
          </q-card-section>
        </q-card>
      </q-dialog>

      <q-dialog
        v-model="vaga_inexistente"
        persistent
        :maximized="maximizedToggle"
        transition-show="slide-up"
        transition-hide="slide-down"
      >
        <q-card>
          <q-bar class="bg-deep-orange-3 text-white text-center">
            <q-space />
          </q-bar>
          <q-card-section
            class="q-pt-none fixed-center item-center text-center"
          >
            <q-btn round size="xl" color="negative" icon="close"></q-btn><br />
            <div class="text-bold text-h4">
              Código de vaga incorreto, por favor verificar!
            </div>
          </q-card-section>
        </q-card>
      </q-dialog>

      <div v-if="step == 3" class="sem-espaco">
        <div class="row items-center">
          <div class="metade-tela ">
            <h2 class="content-block h2">{{ tituloMenu }}</h2>
          </div>
          <div class="metade-tela ">
            <q-btn
              style="float:right"
              icon="quiz"
              class="margin1"
              color="orange-7"
              label="INSTRUÇÕES"
              @click="onExemplo()"
            />
          </div>
        </div>

        <div
          v-for="n in this.array_perguntas.length"
          v-bind:key="n"
          class="margin1"
          v-show="array_perguntas.length > 0"
          :id="`Finaliza${n}`"
        >
          <div class="text-bold text-h6">{{ n + "º Questão" }}</div>
          <div class="line">
            <q-card
              class=" card-questoes text-center itens-center"
              style="margin: 1%"
              v-for="z in 4"
              :key="z"
            >
              <q-card-section>
                <div class="pergunta">
                  {{ array_perguntas[n - 1][z - 1].pergunta }}
                </div>
                <q-separator />
                <q-rating
                  v-model="array_perguntas[n - 1][z - 1].resposta"
                  size="3.1em"
                  color="orange-7"
                  max="4"
                  tabindex=""
                  :readonly="LeCVAT"
                  @click="
                    onClicou(
                      array_perguntas[n - 1],
                      array_perguntas[n - 1][z - 1]
                    )
                  "
                >
                  <template v-slot:tip-1>
                    <q-tooltip>Ruim</q-tooltip>
                  </template>
                  <template v-slot:tip-2>
                    <q-tooltip>Razoável</q-tooltip>
                  </template>
                  <template v-slot:tip-3>
                    <q-tooltip>Bom</q-tooltip>
                  </template>
                  <template v-slot:tip-4>
                    <q-tooltip>Ótimo</q-tooltip>
                  </template>
                </q-rating>
              </q-card-section>
            </q-card>
          </div>
        </div>
        <q-btn
          push
          color="orange-7"
          label="Anterior"
          text-color="black"
          class="botaoProximo"
          @click="step = 2"
        />
        <q-btn
          push
          color="orange-7"
          label="Finalizar"
          text-color="black"
          class="botaoProximo"
          href="#Finaliza"
          @click="onFinalizar()"
        />
      </div>

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
            @blur="VerificaCandidato()"
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
          <!--<q-input class="col" style="margin: 3.5px" v-model="ramo_atividade" color="black" label="Ramo de Atividade">
                <template v-slot:prepend>
                  <q-icon name="local_activity" />
                </template> 
              </q-input>-->
          <q-input
            class="metade-tela"
            style="margin: 3.5px"
            v-model="celular"
            mask="(##) #####-####"
            :rules="[(val) => !!val || 'Campo obrigatório']"
            color="black"
            label="Celular"
            @blur="VerificaCandidato()"
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
          <!--<q-input class="col espaco-interno" v-model="escolaridade" color="black" label="Grau de Instrução">
                 <template v-slot:prepend>
                   <q-icon name="school" />
                 </template> 
                 </q-input>-->
          <!--<q-input class="col" style="margin-left:1%;" v-model="empresa_desejada" color="black" label="Empresa desejada">
                 <template v-slot:prepend>
                   <q-icon name="location_city" />
                 </template> 
               </q-input>-->
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
            hint="Campo não obrigatório!"
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
        <!--<div class="row ">
              <q-input class="col" v-model="hierarquia" v-if="ic_trabalhando == true" label="Hierarquia">
                <template v-slot:prepend>
                  <q-icon name="tune" />
                </template> 
              </q-input>
          </div>-->
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
            hint="Campo não obrigatório!"
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
          v-if="cd_candidato == 0"
          label="Próximo"
          text-color="black"
          class="botaoProximo"
          @click="NovoCandidato()"
        />
        <q-btn
          push
          color="orange-7"
          v-if="cd_candidato != 0"
          label="Próximo"
          text-color="black"
          class="botaoProximo"
          @click="AtualizaCandidato()"
        />
      </div>

      <div v-if="step == 2">
        <div v-for="(x, index) in this.dados_formulario.length" :key="index">
          <div class="margin1 borda-bloco shadow-2">
            <div class="row margin1 items-center text-bold" :tabindex="x">
              <q-badge rounded color="orange" text-color="black" :label="x" />
              <div class="margin1">
                {{ dados_formulario[index].nm_questao }}
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
          label="Próximo"
          text-color="black"
          class="botaoProximo"
          @click="PreencheQuestionario()"
        />
      </div>
    </div>
    <q-toolbar>
      <q-img
        :src="img_logo_footer"
        class="imagem-header_gbs"
        spinner-color="white"
      />
      <q-space />
      <div class="text-bold">Todos os direitos reservados.</div>
    </q-toolbar>

    <q-dialog v-model="load" maximized persistent>
      <carregando :corID="'orange-9'"></carregando>
    </q-dialog>
    <!--EXEMPLO DE QUESTÃO---->
    <q-dialog
      v-model="btn_exemplo"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-3 text-white">
          Exemplo de Preenchimento de Questão C-VAT
          <q-space />
          <q-btn
            dense
            flat
            icon="minimize"
            size="lg"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white"
              >Minimizar</q-tooltip
            >
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            size="lg"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" size="lg" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section class="q-pt-none" v-if="array_perguntas_ex.length > 0">
          <q-card
            class="card-questoes2 margin1 text-center"
            v-for="c in 4"
            v-bind:key="c"
          >
            <q-card-section>
              <label class="pergunta">{{
                array_perguntas_ex[c - 1].pergunta
              }}</label>
              <q-separator />
              <q-rating
                v-model="array_perguntas_ex[c - 1].resposta"
                size="3.1em"
                color="orange-7"
                :readonly="true"
                max="4"
                tabindex=""
              >
                <template v-slot:tip-1>
                  <q-tooltip>Ruim</q-tooltip>
                </template>
                <template v-slot:tip-2>
                  <q-tooltip>Razoável</q-tooltip>
                </template>
                <template v-slot:tip-3>
                  <q-tooltip>Bom</q-tooltip>
                </template>
                <template v-slot:tip-4>
                  <q-tooltip>Ótimo</q-tooltip>
                </template>
              </q-rating>
            </q-card-section>
          </q-card>
          <h4><b>Instruções para preenchimento do CVAT SALES</b></h4>
          <ol>
            <b>
              <li>Prefira preencher no computador ao invés do celular.</li>
              <br />
              <li>
                Coloque as frases em ordem de sua preferência, sendo 4 estrelas
                para a frase que você mais gosta e 1 para a que você menos
                gosta.
              </li>
              <br />
              <li>
                Confira se preencheu todo o questionário antes de tentar
                concluir.
              </li>
              <br />
              <li>
                Cada conjunto de 4 frases são avaliados independente das
                respostas anteriores.
              </li>
              <br />
              <li>
                O formulário não tem pegadinhas. Não importa se você deu 4 para
                algo e agora tem que dar 1 para algo parecido, pois as outras
                três frases são diferentes.
              </li>
              <br />
              <li>
                Responda com sinceridade, ou o laudo não te ajudará em nada.
              </li>
              <br />
              <li>
                Responda como foco em como você é hoje, não ‘’como você gostaria
                de ser’’ ou acha bonito ser. Não tente esconder coisas, ou
                responder o que acha mais certo.
              </li>
              <br />
              <li>
                Não existe certo e errado. Não existe perfil bom ou ruim. Existe
                o seu perfil e é ele que queremos conhecer!
              </li>
              <br />
              <li>
                Não tente separar seu perfil em profissional/vida pessoal,
                responda com base no que você realmente sente.
              </li>
              <br />
              <li>
                Em caso de dúvida, opte sempre pelo que foi sua primeira
                impressão.
              </li>
              <br />
              <li>
                Existirão conjuntos que você pode não gostar de nenhuma frase,
                ou gostar de todas as frases, mesmo assim você terá que colocar
                em uma ordem.
              </li>
              <br />
              <li>
                Certifique-se de que ao finalizar, não apareceu uma mensagem
                falando que faltou alguma coisa.
              </li>
              <br />
            </b>
          </ol>
          <div class="col">
            <q-btn
              style="margin: 0 50%"
              round
              size="lg"
              color="green-5"
              icon="check"
              v-close-popup
            />
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import ptMessages from "devextreme/localization/messages/pt.json";
import Lookup from "../http/lookup";
import { Notify } from "quasar";

import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import formataData from "../http/formataData";
import carregando from "../components/carregando.vue";
import funcao from "../http/funcoes-padroes";

export default {
  data() {
    return {
      //pontuacao_cores    : ['yellow-5', 'yellow-6', 'yellow-12', 'yellow-13'],
      load: false,
      texto_inicial:
        "Antes de realizar o C-VAT, pedimos que confirme os seus dados.",
      texto_inicial2:
        "Caso algum dado esteja incorreto, basta alterá-lo para atualizarmos seu cadastro. Vamos lá ?",
      progressao: 0.33,
      LeCVAT: false,
      LeForm: false,
      progressao_label: "1/3",
      cd_vaga: 0,
      cd_item: 1,
      instrucoes: false,
      ic_instrucao: false,
      vaga_inexistente: false,
      pedeID: true,
      agradecimento: false,
      cd_usuario: 0,
      cd_id_vaga: "",
      dados_formulario: [],
      nm_resposta: "",
      contador_erro_id: 0,
      abriu: 0,
      dados_candidato: [],
      tituloMenu: "Avaliação de Perfil - CVAT",
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
      cod: 1,
      nome_completo: "",
      email: "",
      sexo: 0,
      Empresa_atual: "",
      salario_atual: "",
      cargo_atual: "",
      experiencia: "",
      ramo_atividade: "",
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
      api: "598/827", //Procedimento 1473 - pr_montagem_avaliacao_candidato
      cd_candidato: 0,
      dados_grau: {},
      dataset_dados_grau: [],
      dados_cargo: {},
      dataset_dados_cargo: [],
      resposta: ["1", "2", "3", "4"],
      array_perguntas: [],
      array_perguntas_ex: [],
      resultado_cvat: [],
      btn_exemplo: false,
      existe_vaga: [],
    };
  },
  computed: {},
  async created() {
    this.load = true;
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    this.progressao_label = "1/3"; //this.progressao * 100 + '%';

    localStorage.cd_empresa = 153;
    this.cd_empresa = localStorage.cd_empresa;
    this.cd_usuario = localStorage.cd_usuario;
    /*----------------------------------------------------------------------------------------------------*/

    this.dados_grau = await Lookup.montarSelect(localStorage.cd_empresa, 335);
    this.dataset_dados_grau = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_grau.dataset))
    );
    /*----------------------------------------------------------------------------------------------------*/

    this.dados_cargo = await Lookup.montarSelect(localStorage.cd_empresa, 336);
    this.dataset_dados_cargo = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_cargo.dataset))
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
    await this.MontagemQuestao();
    this.cd_candidato > 0
      ? await this.MontagemCandidato()
      : (this.cd_candidato = 0);
    this.load = false;
  },

  updated() {
    if (this.step == 1) {
      this.progressao = 0.33;
      this.progressao_label = "1/3"; //this.progressao * 100 + '%';
      this.texto_inicial =
        "Antes de realizar o C-VAT, pedimos que confirme os seus dados.";
      this.texto_inicial2 =
        "Caso algum dado esteja incorreto, basta alterá-lo para atualizarmos seu cadastro. Vamos lá ?";
    } else if (this.step == 2) {
      this.progressao = 0.66;
      this.progressao_label = "2/3"; //this.progressao * 100 + '%';
      this.texto_inicial =
        "Preencha o formulário abaixo, antes de iniciar a avaliação C-VAT.";
      this.texto_inicial2 = "";
    } else if (this.step == 3) {
      this.progressao = 0.99;
      this.progressao_label = "3/3"; //this.progressao * 100 + '%';
      this.texto_inicial = "";
      this.texto_inicial2 = "";
    }
  },

  components: {
    carregando,
  },

  methods: {
    async verificaVaga(e) {
      if (e.includes("e") || e.includes(".")) {
        notify("ID Incorreto! Tente novamente. 1");
        return;
      }
      if (e.length !== 12) {
        notify("ID Incorreto! Tente novamente. 2");
        return;
      }
      try {
        var verifica_vaga = {
          //1473 - pr_montagem_avaliacao_candidato
          cd_parametro: 5,
          cd_id_vaga: e,
        };
        this.existe_vaga = await Incluir.incluirRegistro(
          "598/827",
          verifica_vaga
        );
        if (this.existe_vaga[0].Cod == 1) {
          //ID CORRETO
          this.cd_vaga = this.existe_vaga[0].cd_requisicao_vaga;
          this.cd_item = this.existe_vaga[0].cd_item_requisicao_vaga;
          this.cd_cliente = this.existe_vaga[0].cd_cliente;
          this.vaga_inexistente = false;
          this.pedeID = false;
          await this.MontagemFormulario(e);
        } else {
          //ID INCORRETO
          this.contador_erro_id = this.contador_erro_id + 1;
          notify("ID Incorreto! Tente novamente.");
        }
        if (this.contador_erro_id === 4) {
          this.vaga_inexistente = true;
        }
      } catch {
        notify("Vaga não encontrada! Tente novamente.");
      }
    },

    async VerificaCandidato() {
      var dados_verificacao = {
        cd_parametro: 12,
        nm_email: this.email,
        nm_telefone: this.celular,
      };
      var candidato_encontrado = await Incluir.incluirRegistro(
        this.api,
        dados_verificacao
      );
      if (candidato_encontrado[0].Cod === 1) {
        //Candidato não cadastrado
        return;
      } else {
        //Candidato cadastrado, e traz as informações dele
        var preencheu_cvat = false;
        var preencheu_formulario = false;
        this.cd_candidato = candidato_encontrado[0].cd_candidato;
        this.nome_completo = candidato_encontrado[0].nm_candidato;

        this.email == ""
          ? (this.email = candidato_encontrado[0].nm_email_candidato)
          : "";
        this.celular == ""
          ? (this.celular = candidato_encontrado[0].cd_celular_candidato)
          : "";
        this.data_nasc = formataData.formataDataJS(
          candidato_encontrado[0].dt_nascimento_candidato
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
          candidato_encontrado[0].ic_trabalhando_candidato == "S"
            ? true
            : false;
        this.Empresa_atual = candidato_encontrado[0].nm_empresa_atual;
        this.salario_atual = candidato_encontrado[0].vl_salario_candidato;
        this.FormataMoeda();
        candidato_encontrado.map((e) => {
          if (
            e.cd_avaliacao != 1 &&
            this.dados_formulario[0] &&
            e.cd_avaliacao == this.dados_formulario[0].cd_avaliacao
          ) {
            //Formulário Respondido
            this.dados_formulario[e.cd_questao - 1].nm_resposta =
              e.nm_resultado_resposta;
            this.LeForm = true;
          } else if (e.cd_avaliacao == 1 && this.vaga == e.cd_requisicao_vaga) {
            //C-VAT Respondido array_perguntas
            this.array_perguntas[e.cd_questao - 1][e.cd_resposta - 1].resposta =
              e.qt_resultado;

            this.LeCVAT = true;
          }
          ////Verifica se os dois estão preenchidos e se estiver mostra Thank You Page
          e.cd_avaliacao == 1 && this.cd_vaga == e.cd_requisicao_vaga ? (preencheu_cvat = true) : "";
          if (this.dados_formulario[0]) {
            e.cd_avaliacao == this.dados_formulario[0].cd_avaliacao
              ? (preencheu_formulario = true)
              : "";
          } else {
            preencheu_formulario = true;
          }
          if (preencheu_cvat && preencheu_formulario) {
            this.agradecimento = true;
            //return;
          }
        });
        ////Volta ao estado original caso não tenha preenchido
        let encontrou_cvat = await candidato_encontrado.some(
          (e) => e.cd_avaliacao == 1
        );
        let encontrou_form = await candidato_encontrado.some(
          (e) =>
            e.cd_avaliacao != 1 &&
            e.cd_avaliacao == this.dados_formulario[0].cd_avaliacao
        );
        if (!encontrou_form && !encontrou_form) {
          this.dados_formulario.map((e) => {
            if (e.cd_tipo_pergunta == 4) {
              e.nm_resposta = "Não";
            }
            if (e.cd_tipo_pergunta == 6) {
              e.nm_resposta = 0;
            } else {
              e.nm_resposta = "";
            }
          });
          this.LeForm = false;
        }
        if (!preencheu_cvat && !encontrou_cvat) {
          candidato_encontrado.map((e) => {
            if (e.cd_avaliacao === 1) {
              this.array_perguntas[e.cd_questao - 1][
                e.cd_resposta - 1
              ].resposta = null;
            }
          });
          this.LeCVAT = false;
        }
      }
    },

    async FormataMoeda() {
      this.salario_atual = await funcao.FormataValor(this.salario_atual);
    },

    async MontagemCandidato() {
      //Consulta informação do candidato
      var dados = {
        cd_parametro: 0,
        cd_candidato: this.cd_candidato,
      };
      var consulta_cand = await Incluir.incluirRegistro(this.api, dados);
      if (consulta_cand[0].Cod == 0) {
        notify(consulta_cand[0].Msg);
        return;
      }
      var dt = formataData.formataDataJS(
        consulta_cand[0].dt_nascimento_candidato
      );
      this.nome_completo = consulta_cand[0].nm_candidato;
      this.email = consulta_cand[0].nm_email_candidato;
      this.celular = consulta_cand[0].cd_celular_candidato;
      this.data_nasc = dt;
      this.sexo = consulta_cand[0].cd_sexo;
      this.Empresa_atual = consulta_cand[0].nm_empresa_atual;
      this.salario_atual = consulta_cand[0].vl_salario_candidato;
      this.experiencia = consulta_cand[0].nm_experiencia;
      this.cargo_atual = {
        cd_cargo_funcionario: consulta_cand[0].cd_cargo_funcionario,
        nm_cargo_funcionario: consulta_cand[0].nm_cargo_atual,
      };
      this.ramo_atividade = consulta_cand[0].nm_ramo_atividade;
      this.escolaridade = {
        cd_grau_instrucao: consulta_cand[0].cd_grau_instrucao,
        nm_grau_instrucao: consulta_cand[0].nm_grau_instrucao,
      };
      this.hierarquia = consulta_cand[0].nm_hierarquia;
      this.empresa_desejada = consulta_cand[0].nm_empresa_desejada;
      this.ic_trabalhando =
        consulta_cand[0].ic_trabalhando_candidato == "S" ? true : false;
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
      await this.VerificaCandidato();
      let ic_trabalhando_atualiza = this.ic_trabalhando ? "S" : "N";
      var data = formataData.formataDataSQL(this.data_nasc);
      var novo = {
        cd_parametro: 4,
        cd_vaga: this.cd_vaga,
        cd_item_requisicao_vaga: this.cd_item,
        nm_candidato: funcao.ValidaString(this.nome_completo, 70),
        nm_email: funcao.ValidaString(this.email, 70),
        nm_celular: this.celular,
        dt_nasc: data,
        cd_sexo: this.sexo,
        nm_empresa_atual: funcao.ValidaString(this.Empresa_atual, 60),
        vl_salario_candidato: this.salario_atual
          .replaceAll(".", "")
          .replace("R$", ""),
        cd_cargo_funcionario: this.cargo_atual.cd_cargo_funcionario,
        nm_cargo_atual: this.cargo_atual.nm_cargo_funcionario,
        nm_experiencia: this.experiencia,
        nm_ramo_atividade: this.ramo_atividade,
        cd_escolaridade: this.escolaridade.cd_grau_instrucao,
        nm_escolaridade: this.escolaridade.nm_grau_instrucao,
        nm_hierarquia: this.hierarquia,
        nm_empresa_desejada: this.empresa_desejada,
        ic_trabalhando: ic_trabalhando_atualiza,
      };
      this.load = true;
      var novo_candidato = await Incluir.incluirRegistro(this.api, novo);
      this.load = false;
      this.cd_candidato = novo_candidato[0].cd_candidato;
      notify(novo_candidato[0].Msg);
      if (novo_candidato[0].Cod == 0) {
        this.cd_candidato = 0;
        return;
      } else {
        this.step = 2;
      }
    },

    async AtualizaCandidato() {
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
        cd_candidato: this.cd_candidato,
        nm_candidato: funcao.ValidaString(this.nome_completo, 70),
        nm_email: funcao.ValidaString(this.email, 70),
        nm_celular: this.celular,
        dt_nasc: data,
        cd_sexo: this.sexo,
        nm_empresa_atual: funcao.ValidaString(this.Empresa_atual, 60),
        vl_salario_candidato: this.salario_atual
          .replaceAll(".", "")
          .replace("R$", ""),
        cd_cargo_funcionario: this.cargo_atual.cd_cargo_funcionario,
        nm_cargo_atual: this.cargo_atual.nm_cargo_funcionario,
        nm_experiencia: this.experiencia,
        nm_ramo_atividade: this.ramo_atividade,
        cd_escolaridade: this.escolaridade.cd_grau_instrucao,
        nm_escolaridade: this.escolaridade.nm_grau_instrucao,
        nm_hierarquia: this.hierarquia,
        nm_empresa_desejada: this.empresa_desejada,
        ic_trabalhando: ic_trabalhando_atualiza,
      };
      this.load = true;
      var up_candidato = await Incluir.incluirRegistro(this.api, up);

      this.load = false;
      this.step = 2;
      notify(up_candidato[0].Msg);
    },

    async PreencheQuestionario() {
      let falta_questoes = false;
      for (let v = 0; v < this.dados_formulario.length; v++) {
        if (
          this.dados_formulario[v].cd_tipo_pergunta == 1 &&
          this.dados_formulario[v].nm_resposta != null
        ) {
          this.dados_formulario[v].nm_resposta = funcao.ValidaString(
            this.dados_formulario[v].nm_resposta
          );
        }
        if (
          this.dados_formulario[v].nm_resposta === null ||
          this.dados_formulario[v].nm_resposta === "" ||
          this.dados_formulario[v].nm_resposta === 0
        ) {
          falta_questoes = true;
          return notify(`Preencha todas as questões do formulário!`);
        }
      }

      if (falta_questoes == false) {
        this.step = 3;
      }
      try {
        this.load = true;
        var salvaFormulario = {
          cd_parametro: 11,
          cd_usuario: localStorage.cd_usuario,
          cd_vaga: this.existe_vaga[0].cd_requisicao_vaga,
          cd_item_requisicao_vaga: this.existe_vaga[0].cd_item_requisicao_vaga,
          cd_candidato: this.cd_candidato,
          json_formulario: this.dados_formulario,
        };
        let resultado_formulario = await Incluir.incluirRegistro(
          this.api,
          salvaFormulario
        );
        this.load = false;
        notify(resultado_formulario[0].Msg);
      } catch (e) {
        notify(e);
        this.load = false;
      }
      if (this.abriu == 1) {
        return;
      } else {
        this.instrucoes = true;
        this.abriu = 1;
      }
    },

    onExemplo() {
      this.btn_exemplo = true;
    },

    onAceite() {
      this.ic_instrucao == true
        ? (this.instrucoes = false)
        : (this.instrucoes = true);
    },

    onClicou(e) {
      if (
        e[0].resposta == e[1].resposta ||
        e[0].resposta == e[2].resposta ||
        e[0].resposta == e[3].resposta
      ) {
        e[0].resposta = 0;
      }
      if (
        e[1].resposta == e[0].resposta ||
        e[1].resposta == e[2].resposta ||
        e[1].resposta == e[3].resposta
      ) {
        e[1].resposta = 0;
      }
      if (
        e[2].resposta == e[1].resposta ||
        e[2].resposta == e[0].resposta ||
        e[2].resposta == e[3].resposta
      ) {
        e[2].resposta = 0;
      }
      if (
        e[3].resposta == e[1].resposta ||
        e[3].resposta == e[2].resposta ||
        e[3].resposta == e[0].resposta
      ) {
        e[3].resposta = 0;
      }
    },

    async MontagemQuestao() {
      var consulta = {
        cd_parametro: 1,
      };
      this.dados_candidato = await Incluir.incluirRegistro(this.api, consulta);
      for (let a = 0; a < this.dados_candidato.length; a++) {
        this.filtra += this.dados_candidato[a].json_resposta + ",";
        a = a + 3;
      }

      var array_filtrado = this.filtra.substring(0, this.filtra.length - 1);
      array_filtrado =
        "[" + array_filtrado.substring(0, array_filtrado.length) + "]";
      this.array_perguntas = JSON.parse(array_filtrado);
      const exemplo = this.array_perguntas.shift();
      this.array_perguntas_ex = exemplo;
      this.array_perguntas_ex[0].resposta = 1;
      this.array_perguntas_ex[1].resposta = 2;
      this.array_perguntas_ex[2].resposta = 3;
      this.array_perguntas_ex[3].resposta = 4;
    },

    async MontagemFormulario(e) {
      var formulario = {
        cd_parametro: 10,
        cd_id_vaga: e,
      };
      this.dados_formulario = await Incluir.incluirRegistro(
        this.api,
        formulario
      );
      this.dados_formulario.forEach((e) => {
        if (e.cd_tipo_pergunta == 4) {
          e.nm_resposta = "Não";
        }
        if (e.cd_tipo_pergunta == 6) {
          e.nm_resposta = 0;
        }
      });
    },

    Data() {
      var ano = this.dt_picker.substring(0, 4);
      var mes = this.dt_picker.substring(5, 7);
      var dia = this.dt_picker.substring(8, 10);
      this.data_nasc = dia + mes + ano;
    },

    async trocaPage(step) {
      if (this.cd_candidato == 0) {
        notify("Por favor, preencha os dados do candidato!");
        return (this.step = 1);
      }
      if (step == 2) {
        if (this.cd_candidato != 0) {
          this.AtualizaCandidato();
        }
      } else if (step == 3) {
        this.step = 2;
        this.PreencheQuestionario();
      }
    },

    async onFinalizar() {
      //Verifica se tem resposta não preenchida
      for (let v = 0; v < this.array_perguntas.length; v++) {
        if (this.array_perguntas[v][0].resposta == "") {
          document.querySelectorAll('[id^="Finaliza"]').forEach((anchor) => {
            if (anchor.id.slice(8, 13) == v + 1) {
              var el = document.getElementById(anchor.id);
              el.setAttribute("href", anchor.id);
              el.scrollIntoView({ behavior: "smooth", block: "center" });
            }
          });
          return Notify.create({
            message: `A Questão <strong>${this.array_perguntas[v][0].cd_questao}</strong>, afirmativa 1, não foi respondida, <strong>todas as questões precisam ser respondidas!</strong>`,
            html: true,
            icon: "warning",
            color: "orange",
            textColor: "black",
            position: "bottom",
            classes: "MyNotify",
          });
        }
        if (this.array_perguntas[v][1].resposta == "") {
          document.querySelectorAll('[id^="Finaliza"]').forEach((anchor) => {
            if (anchor.id.slice(8, 13) == v + 1) {
              var el = document.getElementById(anchor.id);
              el.setAttribute("href", anchor.id);
              el.scrollIntoView({ behavior: "smooth", block: "center" });
            }
          });

          return Notify.create({
            message: `A Questão <strong>${this.array_perguntas[v][0].cd_questao}</strong>, afirmativa 2, não foi respondida, <strong>todas as questões precisam ser respondidas!</strong>`,
            html: true,
            icon: "warning",
            color: "orange",
            textColor: "black",
            position: "bottom",
            classes: "MyNotify",
          });
        }
        if (this.array_perguntas[v][2].resposta == "") {
          document.querySelectorAll('[id^="Finaliza"]').forEach((anchor) => {
            if (anchor.id.slice(8, 13) == v + 1) {
              var el = document.getElementById(anchor.id);
              el.setAttribute("href", anchor.id);
              el.scrollIntoView({ behavior: "smooth", block: "center" });
            }
          });
          return Notify.create({
            message: `A Questão <strong>${this.array_perguntas[v][0].cd_questao}</strong>, afirmativa 3, não foi respondida, <strong>todas as questões precisam ser respondidas!</strong>`,
            html: true,
            icon: "warning",
            color: "orange",
            textColor: "black",
            position: "bottom",
            classes: "MyNotify",
          });
        }
        if (this.array_perguntas[v][3].resposta == "") {
          document.querySelectorAll('[id^="Finaliza"]').forEach((anchor) => {
            if (anchor.id.slice(8, 13) == v + 1) {
              var el = document.getElementById(anchor.id);
              el.setAttribute("href", anchor.id);
              el.scrollIntoView({ behavior: "smooth", block: "center" });
            }
          });
          return Notify.create({
            message: `A Questão <strong>${this.array_perguntas[v][0].cd_questao}</strong>, afirmativa 4, não foi respondida, <strong>todas as questões precisam ser respondidas!</strong>`,
            html: true,
            icon: "warning",
            color: "orange",
            textColor: "black",
            position: "bottom",
            classes: "MyNotify",
          });
        }
      }
      this.load = true;
      var finalizaCVAT = {
        cd_parametro: 3,
        cd_usuario: localStorage.cd_usuario,
        cd_vaga: this.cd_vaga,
        cd_item_requisicao_vaga: this.cd_item,
        cd_candidato: this.cd_candidato,
        json_questionario_resposta: this.array_perguntas,
      };
      
      this.resultado_cvat = await Incluir.incluirRegistro(
        this.api,
        finalizaCVAT
      );
      this.load = false;
      notify(this.resultado_cvat[0].Msg);
      if (this.resultado_cvat[0].Cod == 1) {
        this.agradecimento = true;
      }
    },
  },
};
</script>

<style scooped>
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

.sem-espaco {
  margin: 0;
  padding: 0;
}
.cvat-header {
  max-height: 4vw;
  background: black;
}
.imagem-header {
  max-height: 200px;
  max-width: 200px;
}
.imagem-header_gbs {
  margin: 2px;
  max-height: 5%;
  max-width: 5%;
}

.imagem-middle {
  max-width: 15vw;
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
.card-questoes2 {
  width: 23vw;
}

.instrucoes {
  transform: scale(1);
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
  .card-questoes2 {
    width: 100%;
  }
}

.MyNotify {
  margin: -100px !important;
  padding: 0px !important;
}
</style>
