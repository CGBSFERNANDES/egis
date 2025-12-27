<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div>
      <div id="tela_inteira">
        <div class="linha">
          <div class="coluna-80">
            <div class="borda">
              <div class="todas" style="display: inline-block">
                <label
                  ><b>{{ turno }} - {{ operador }} | {{ hoje }} {{ hora }} </b>
                </label>
              </div>
              <div class="todas">
                <label class="dados_ordem"
                  >OP <br /><b> {{ ordem }} </b>
                </label>
                <label class="dados_ordem"
                  >Pedido <br /><b>
                    {{ pedido }} - {{ cd_item_pedido_venda }}</b
                  >
                </label>
                <label class="dados_ordem"
                  >Data <br /><b> {{ data }} </b>
                </label>
                <label class="dados_ordem"
                  >Entrega <br /><b> {{ entrega }} </b>
                </label>
              </div>
              <div class="todas linha-cliente" style="padding-left: 6px">
                <label class="razao"
                  >Razão Social
                  <b style="padding-left: 6px">
                    {{ nm_razao_social_cliente }}
                  </b>
                </label>
                <label class="fantasia" style="padding-left: 6px">
                  Fantasia
                  <b style="padding-left: 6px"> {{ cliente }} </b>
                </label>
              </div>
              <div class="todas">
                <label class="produto"
                  >Produto <b>{{ produto }}</b></label
                >
                <label class="produto_cod"
                  >Código <b>{{ cd_mascara_produto }}</b></label
                >
              </div>
              <div class="todas">
                <label class="dados_prod"
                  >Quantidade <br /><b>{{ qtd }} </b>
                </label>
                <label class="dados_prod"
                  >Largura <br /><b>{{ larg }} </b>
                </label>
                <label class="dados_prod"
                  >Espessura <br /><b>{{ esp }} </b>
                </label>
                <label class="dados_prod"
                  >Comprimento <br /><b>{{ comp }} </b>
                </label>
                <label class="dados_prod"
                  >Volume <br /><b>{{ vol }} </b>
                </label>
                <label class="dados_prod"
                  >Peso <br /><b>{{ peso }} KG</b>
                </label>
              </div>
              <transition name="slide-fade">
                <div class="todas" v-if="this.aponamento_inicio == 1">
                  <div class="lista_comp">
                    <label> QUANTIDADE </label>

                    <br />
                    <label class="qtd_prod">
                      {{ qtd }} {{ sg_unidade_medida }}
                    </label>
                  </div>

                  <div class="lista_comp">
                    <label> PRODUZIDO </label>
                    <br />
                    <label class="qtd_prod">
                      {{ this.qtd_produzida }} {{ sg_unidade_medida }}
                    </label>
                  </div>

                  <div class="lista_comp">
                    <label> SALDO</label>
                    <br />
                    <label class="qtd_prod">
                      {{ this.saldo }} {{ sg_unidade_medida }}
                    </label>
                  </div>
                </div>
              </transition>
              <transition name="slide-fade">
                <div class="todas" v-if="this.data_componentes.length != 0">
                  <!--v-if=" this.aponamento_inicio == 0"-->

                  <div
                    style="width: 100%; padding-left: 0px"
                    v-if="this.data_componentes.length != 0"
                  >
                    <div class="todas" style="background-color: #c0c0c0">
                      <label class="lista_componentes">COMPONENTE</label>
                      <label class="lista_quantidade">QUANTIDADE </label>
                      <label class="lista_quantidade">PESO</label>
                    </div>
                    <transition-group name="slide-fade">
                      <ul
                        v-for="(b, componentes_atual) in componentes_atual"
                        v-bind:key="componentes_atual"
                      >
                        <li class="todas">
                          <label
                            style="text-align: left; margin-left: 20px"
                            class="lista_componentes"
                          >
                            <b>{{ b.Descricao }}</b>
                          </label>
                          <label
                            style="text-align: center"
                            class="lista_quantidade"
                            ><b>{{ b.Quantidade }} </b></label
                          >
                          <label
                            style="text-align: right; margin-right: 20px"
                            class="lista_quantidade"
                            ><b
                              >{{ b.PesoLiquido.toString().replace(".", ",") }}
                              KG
                            </b></label
                          >
                        </li>
                      </ul>
                    </transition-group>
                  </div>
                </div>
              </transition>
              <transition name="slide-fade">
                <div class="todas" v-if="this.cd_empresa == 136">
                  <label class="dados_peso"
                    >Peso Material <br /><b>{{ Peso_Material }} KG </b>
                  </label>
                  <label class="dados_peso"
                    >Peso Mat + Tubete <br /><b>{{ Peso_Material_Tub }} KG </b>
                  </label>
                  <label class="dados_peso"
                    >Peso Mat + Tub + Caixa <br /><b
                      >{{ Peso_Material_Tub_Caixa }} KG
                    </b>
                  </label>
                  <label class="dados_peso"
                    >Qtd. p/ Caixa <br /><b>{{ Qt_caixa }} </b>
                  </label>
                  <label class="dados_peso"
                    >Caixa Coletiva <br /><b>{{ Caixa_coletiva }} KG </b>
                  </label>
                </div>
              </transition>

              <q-card class="text-center">
                <q-card-section style="padding: 10px">
                  <q-input filled v-model="ds_processo" autogrow readonly />
                </q-card-section>
              </q-card>
            </div>

            <div class="todas" style="border: none">
              <transition name="slide-fade">
                <div
                  v-if="
                    this.dataSourceConfig.length >= 2 &&
                      this.index_data + 1 <= this.dataSourceConfig.length - 1
                  "
                  class="proximas_ordens"
                >
                  <label
                    v-if="
                      this.index_data + 1 <= this.dataSourceConfig.length - 1
                    "
                  >
                    Ordem de Produção
                    <b
                      v-if="
                        this.index_data + 1 <= this.dataSourceConfig.length - 1
                      "
                    >
                      {{
                        this.dataSourceConfig[this.index_data + 1].cd_processo
                      }}
                    </b>
                    - Pedido
                    <b
                      v-if="
                        this.index_data + 1 <= this.dataSourceConfig.length - 1
                      "
                      >{{
                        this.dataSourceConfig[this.index_data + 1]
                          .cd_pedido_venda
                      }}
                      -
                      {{
                        this.dataSourceConfig[this.index_data + 1]
                          .cd_item_pedido_venda
                      }}
                    </b>
                  </label>
                  <br />
                  <label
                    v-if="
                      this.index_data + 1 <= this.dataSourceConfig.length - 1
                    "
                  >
                    Produto
                    <b
                      v-if="
                        this.index_data + 1 <= this.dataSourceConfig.length - 1
                      "
                      >{{
                        this.dataSourceConfig[this.index_data + 1]
                          .nm_produto_pedido
                      }}
                      -
                      {{
                        this.dataSourceConfig[this.index_data + 1]
                          .qt_largura_item
                      }}
                      x
                      {{
                        this.dataSourceConfig[this.index_data + 1]
                          .qt_espessura_item
                      }}
                      x
                      {{
                        this.dataSourceConfig[this.index_data + 1]
                          .qt_comprimento_item
                      }}
                    </b>
                  </label>
                  <br />
                  <label
                    v-if="
                      this.index_data + 1 <= this.dataSourceConfig.length - 1
                    "
                  >
                    Quantidade
                    <b
                      v-if="
                        this.index_data + 1 <= this.dataSourceConfig.length - 1
                      "
                    >
                      {{
                        this.dataSourceConfig[
                          this.index_data + 1
                        ].qt_planejada_processo
                          .toString()
                          .replace(".", ",")
                      }}
                    </b>
                    Peso
                    <b
                      v-if="
                        this.index_data + 1 <= this.dataSourceConfig.length - 1
                      "
                    >
                      {{
                        this.dataSourceConfig[
                          this.index_data + 1
                        ].qt_peso_liquido_total
                          .toString()
                          .replace(".", ",")
                      }}
                      KG
                    </b>
                  </label>
                  <br />

                  <div class="todas" style="background-color: #c0c0c0">
                    <label class="lista_componentes">COMPONENTE</label>
                    <label class="lista_quantidade">QUANTIDADE</label>
                    <label class="lista_quantidade">PESO</label>
                  </div>
                  <transition-group name="slide-fade">
                    <ul v-for="(a, prox_1) in prox_1" v-bind:key="prox_1">
                      <li class="todas">
                        <label
                          style="text-align: left; margin-left: 20px"
                          class="lista_componentes"
                        >
                          <b>{{ a.Descricao }}</b></label
                        >
                        <label
                          style="text-align: center"
                          class="lista_quantidade"
                          ><b>{{ a.Quantidade }} </b></label
                        >
                        <label
                          style="text-align: right; margin-right: 20px"
                          class="lista_quantidade"
                          ><b
                            >{{ a.PesoLiquido.toString().replace(".", ",") }} KG
                          </b></label
                        >
                      </li>
                    </ul>
                  </transition-group>
                </div>
              </transition>

              <transition name="slide-fade">
                <div
                  v-if="
                    this.dataSourceConfig.length >= 3 &&
                      this.index_data + 2 <= this.dataSourceConfig.length - 1
                  "
                  class="proximas_ordens"
                >
                  <label
                    v-if="
                      this.index_data + 2 <= this.dataSourceConfig.length - 1
                    "
                  >
                    Ordem de Produção
                    <b
                      v-if="
                        this.index_data + 2 <= this.dataSourceConfig.length - 1
                      "
                      >{{
                        this.dataSourceConfig[this.index_data + 2].cd_processo
                      }}</b
                    >
                    Pedido
                    <b
                      v-if="
                        this.index_data + 2 <= this.dataSourceConfig.length - 1
                      "
                      >{{
                        this.dataSourceConfig[this.index_data + 2]
                          .cd_pedido_venda
                      }}-
                      {{
                        this.dataSourceConfig[this.index_data + 2]
                          .cd_item_pedido_venda
                      }}
                    </b>
                  </label>
                  <br />
                  <label
                    v-if="
                      this.index_data + 2 <= this.dataSourceConfig.length - 1
                    "
                  >
                    Produto
                    <b
                      >{{
                        this.dataSourceConfig[this.index_data + 2]
                          .nm_produto_pedido
                      }}
                      -
                      {{
                        this.dataSourceConfig[this.index_data + 2]
                          .qt_largura_item
                      }}
                      x
                      {{
                        this.dataSourceConfig[this.index_data + 2]
                          .qt_espessura_item
                      }}
                      x
                      {{
                        this.dataSourceConfig[this.index_data + 2]
                          .qt_comprimento_item
                      }}
                    </b>
                  </label>
                  <br />
                  <label
                    v-if="
                      this.index_data + 2 <= this.dataSourceConfig.length - 1
                    "
                  >
                    Quantidade
                    <b
                      v-if="
                        this.index_data + 2 <= this.dataSourceConfig.length - 1
                      "
                    >
                      {{
                        this.dataSourceConfig[
                          this.index_data + 2
                        ].qt_planejada_processo
                          .toString()
                          .replace(".", ",")
                      }}
                    </b>
                    Peso
                    <b
                      v-if="
                        this.index_data + 2 <= this.dataSourceConfig.length - 1
                      "
                    >
                      {{
                        this.dataSourceConfig[
                          this.index_data + 2
                        ].qt_peso_liquido_total
                          .toString()
                          .replace(".", ",")
                      }}
                      KG
                    </b>
                  </label>
                  <br />

                  <div class="todas" style="background-color: #c0c0c0">
                    <label class="lista_componentes">COMPONENTE</label>
                    <label class="lista_quantidade">QUANTIDADE</label>
                    <label class="lista_quantidade">PESO</label>
                  </div>
                  <transition-group name="slide-fade">
                    <ul v-for="(c, prox_2) in prox_2" v-bind:key="prox_2">
                      <li class="todas">
                        <label
                          style="text-align: left; margin-left: 20px"
                          class="lista_componentes"
                          ><b>{{ c.Descricao }}</b></label
                        >
                        <label
                          style="text-align: center"
                          class="lista_quantidade"
                          ><b>{{ c.Quantidade }} </b></label
                        >
                        <label
                          style="text-align: right; margin-right: 20px"
                          class="lista_quantidade"
                          ><b
                            >{{ c.PesoLiquido.toString().replace(".", ",") }} KG
                          </b></label
                        >
                      </li>
                    </ul>
                  </transition-group>
                </div>
              </transition>
            </div>
          </div>
          <div class="coluna-20">
            <div class="row">
              <q-btn
                size="lg"
                class="col button buttons-column"
                label="Recarregar"
                rounded
                color="orange-9"
                @click="carregaDados()"
              />
            </div>
            <div class="row">
              <transition name="slide-fade">
                <q-btn
                  size="lg"
                  rounded
                  icon="arrow_forward"
                  v-show="this.producao == false"
                  color="positive"
                  class="col button buttons-column"
                  text-color="white"
                  label="Início"
                  @click="onInicio()"
                />
              </transition>
            </div>

            <div class="row">
              <transition name="slide-fade">
                <q-btn
                  size="lg"
                  rounded
                  v-show="this.aponamento_inicio == 1"
                  color="grey"
                  class="col button buttons-column"
                  text-color="white"
                  label="Produção"
                  :disable="carregaEstorno"
                  :loading="carregaEstorno"
                  @click="onFim()"
                />
              </transition>
            </div>
            <div class="row">
              <transition name="slide-fade">
                <q-btn
                  size="lg"
                  rounded
                  text-color="white"
                  color="orange-9"
                  class="col button buttons-column"
                  label="Estorno"
                  :disable="carregaEstorno"
                  :loading="carregaEstorno"
                  v-show="qtd_produzida > 0"
                  @click="onClickEstorno()"
                />
              </transition>
            </div>
            <div class="row">
              <transition name="slide-fade">
                <q-btn
                  size="lg"
                  rounded
                  text-color="white"
                  color="positive"
                  class="col button buttons-column"
                  label="Fim"
                  :disable="carregaEstorno"
                  :loading="carregaEstorno"
                  v-show="
                    this.aponamento_inicio == 1 &&
                      this.qtd_produzida >= this.saldo
                  "
                  @click="onFimOP()"
                />
              </transition>
            </div>

            <div class="row">
              <transition name="slide-fade">
                <q-btn
                  size="lg"
                  rounded
                  v-show="this.producao == true"
                  color="indigo-5"
                  class="col button buttons-column"
                  text-color="white"
                  label="Voltar"
                  @click="onVoltar()"
                />
              </transition>
            </div>
            <transition name="slide-fade">
              <div v-show="this.aponamento_inicio == 1">
                <label style="font-size: 25px"> Múltiplos </label>
                <br />
                <div class="multiplos" style="width: 100%">
                  <q-input
                    v-model="qtd_producao"
                    type="number"
                    :max="1000"
                    :min="1"
                    filled
                    style="font-size: 40px"
                  />
                </div>
              </div>
            </transition>

            <div class="row">
              <transition name="slide-fade">
                <q-btn
                  size="lg"
                  rounded
                  v-show="this.aponamento_inicio == 0 && !!this.ordem == true"
                  color="brown-7"
                  class="col button buttons-column"
                  text-color="white"
                  label="Próxima"
                  @click="onClickProxima()"
                />
              </transition>
            </div>

            <div class="row">
              <q-btn
                size="lg"
                rounded
                color="negative"
                class="col button buttons-column"
                label="Parada"
                @click="onClickParada()"
              />
              <!--<q-btn size="lg" color="brown-7" class="button buttons-column" text-color="white" label="Outras Operações" @click="onOutros()"/>-->
              <!--<DxButton
         class="buttons-column button"
                 id="proxima"
                 text="OUTRAS OPERAÇÕES"
                 type="default"
                 horizontal-alignment="left"
                 @click="onOutros()" 
                 style="background-color: #AA4810;
                 width: 100%;
                 height: 70px"
               />  -->
            </div>
            <div class="row">
              <q-btn
                size="lg"
                rounded
                text-color="white"
                color="black"
                class="col button buttons-column"
                label="Apara"
                @click="onClickRefugo()"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
    <!------------------------------------------------------------------------------------------------>

    <!------------------------------------------------------------------------------------------------>
    <div class="q-pa-md q-gutter-sm">
      <q-dialog v-model="desenho" persistent>
        <q-card style="min-width: 520px; min-height: 250px">
          <q-card-section>
            <div class="text-h5" style="text-align: left">
              <b>{{ this.produto }}</b>
            </div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <transition name="slide-fade">
              <div v-if="this.caminho_desenho == ''">
                <label class="text-h6">
                  Caminho do Desenho não encontrado
                </label>
              </div>
            </transition>
            <img v-bind:src="pegaImg()" alt="" />
          </q-card-section>

          <q-card-section v-if="!!this.cd_processo_padrao">
            <div class="text-h6" style="text-align: left">
              Processo Padrão : {{ this.cd_processo_padrao }}
            </div>
          </q-card-section>

          <q-card-actions align="right" class="text-primary">
            <q-btn flat label="OK" v-close-popup />
          </q-card-actions>
        </q-card>
      </q-dialog>
    </div>

    <!------------------------------------------------------------------------------------------------>

    <div v-if="dialog == true" class="q-pa-md q-gutter-sm">
      <q-dialog
        v-model="dialog"
        persistent
        :maximized="maximizedToggle"
        transition-show="slide-up"
        transition-hide="slide-down"
      >
        <q-card
          style="width: 700px; max-width: 80vw"
          class="bg-primary text-white"
        >
          <q-bar>
            <q-space />

            <q-btn
              dense
              flat
              icon="minimize"
              @click="maximizedToggle = false"
              :disable="!maximizedToggle"
            >
              <q-tooltip
                v-if="maximizedToggle"
                content-class="bg-white text-primary"
                >Minimizar</q-tooltip
              >
            </q-btn>
            <q-btn
              dense
              flat
              icon="crop_square"
              @click="maximizedToggle = true"
              :disable="maximizedToggle"
            >
              <q-tooltip
                v-if="!maximizedToggle"
                content-class="bg-white text-primary"
                >Maximizar</q-tooltip
              >
            </q-btn>
            <q-btn dense flat icon="close" v-close-popup>
              <q-tooltip content-class="bg-white text-primary"
                >Fechar</q-tooltip
              >
            </q-btn>
          </q-bar>

          <q-card-section>
            <div class="text-h6">ATENÇÃO...</div>
          </q-card-section>

          <q-card-section class="q-pt-none">
            {{ Alerta_Mensagem }}
          </q-card-section>
        </q-card>
      </q-dialog>
    </div>

    <!------------------------------------------------------------------------------------------------>

    <div v-if="fimproducao == true" class="q-pa-md q-gutter-sm">
      <q-dialog v-model="fimproducao" persistent>
        <q-card style="min-width: 620px; min-height: 250px">
          <q-card-section>
            <div class="text-h5" style="text-align: left">
              <b>{{ this.produto }}</b>
            </div>
          </q-card-section>
          <q-card-section
            class="my-card q-pa-md row items-start q-gutter-md"
            flat
            bordered
          >
            <q-card-section>
              <div class="text-h5 text-overline text-orange-9">
                <b>FIM DE PRODUÇÃO</b>
              </div>
              <div class="text-h5 q-mt-sm q-mb-xs">Quantidade Produzida</div>

              <q-input
                outlined
                v-model="qtd_producao"
                :value.sync="qtd_producao"
              />

              <div class="text-caption text-grey">
                <br /><b>{{ msgFimProducao }}</b>
              </div>
            </q-card-section>
          </q-card-section>
          <q-card-actions align="right" class="text-primary">
            <q-btn flat label="CANCELAR" v-close-popup @click="1 == 1" />
            <q-btn flat label="OK" v-close-popup @click="onFim()" />
          </q-card-actions>
        </q-card>
      </q-dialog>
    </div>

    <!------------------------------------------------------------------------------------------------>
    <div v-if="outros == true" class="q-pa-md q-gutter-sm">
      <q-dialog v-model="outros" persistent>
        <q-card style="min-width: 620px; min-height: 250px">
          <q-card-actions>
            <div style="width: 100%; text-align: center">
              <h4>OUTRAS OPERAÇÕES</h4>
            </div>
          </q-card-actions>
          <q-card-actions style="width: 100%" class="row">
            <q-btn
              size="lg"
              color="negative"
              class="col button buttons-column"
              label="Parada"
              @click="onClickParada()"
            />
            <q-btn
              size="lg"
              text-color="white"
              color="black"
              class="col button buttons-column"
              label="Apara"
              @click="onClickRefugo()"
            />
            <!--<DxButton
                class="button buttons-column"
                text="PARADA"
                type="default"
                styling-mode="contained"
                horizontal-alignment="left"
                @click="onClickParada()"
                style="background-color: #9D1515;
                width: 98%;
                height: 70px;"
              />
              <DxButton
                class="button buttons-column"
                id="apara"
                text="APARA"
                type="default"
                styling-mode="contained"
                horizontal-alignment="left"
                @click="onClickRefugo();"
                style="background-color: #090B08;
                width: 98%;
                height: 70px;"
              />

              <DxButton
                v-if="this.aponamento_inicio == 1"
                class="button buttons-column"
                id="apara"
                text="FIM"
                type="default"
                styling-mode="contained"
                horizontal-alignment="left"
                @click="onFimOP();"
                style="background-color: #0873A9;
                width: 98%;
                height: 70px;"
              />   -->
          </q-card-actions>
          <transition name="slide-fade">
            <q-card-actions
              v-if="this.aponamento_inicio == 1"
              style="width: 100%"
              class="row"
            >
              <q-btn
                size="lg"
                v-if="this.aponamento_inicio == 1"
                text-color="white"
                color="black"
                class="col button buttons-column"
                label="Fim"
                @click="onFimOP()"
              />
            </q-card-actions>
          </transition>
          <q-card-actions align="right" class="text-primary">
            <q-btn flat label="CANCELAR" v-close-popup />
            <!--<q-btn flat label="OK"       v-close-popup/>-->
          </q-card-actions>
        </q-card>
      </q-dialog>
    </div>

    <!------------------------------------------------------------------------------------------------>

    <div v-if="this.carregando == true" class="q-pa-md q-gutter-sm">
      <q-dialog
        v-model="this.carregando"
        persistent
        transition-show="flip-down"
        transition-hide="flip-up"
      >
        <q-card class="bg-primary text-white">
          <q-bar>
            <q-space />
          </q-bar>
          <q-card-section class="q-pt-none">
            <q-circular-progress
              v-if="this.carregando == true"
              indeterminate
              size="50px"
              color="blue"
              class="q-ma-md"
            />
            Aguarde, estamos carregando os dados...
          </q-card-section>
        </q-card>
      </q-dialog>
    </div>

    <!------------------------------------------------------------------------------------------------>

    <div v-if="refugo == true" class="q-pa-md q-gutter-sm">
      <q-dialog v-model="refugo" persistent>
        <q-card style="min-width: 620px; min-height: 250px">
          <q-card-section>
            <div class="text-h5" style="text-align: left">
              <b>{{ this.produto }}</b>
            </div>
          </q-card-section>
          <q-card-section
            class="my-card q-pa-md row items-start q-gutter-md"
            flat
            bordered
          >
            <q-card-section>
              <div class="text-h5 q-mt-sm q-mb-xs">REFUGO/PERDA PRODUÇÃO</div>

              <div class="text-h5 text-overline text-orange-9">
                <b>Causa</b>
              </div>

              <div class="div-select">
                <select v-model="causa_refugo">
                  <option
                    v-for="lookup_dataset_ref in lookup_dataset_ref"
                    v-bind:key="lookup_dataset_ref.cd_causa_refugo"
                    v-bind:value="lookup_dataset_ref.cd_causa_refugo"
                  >
                    {{ lookup_dataset_ref.nm_causa_refugo }}
                  </option>
                </select>
              </div>

              <!--<DxSelectBox 
              v-model="causa_refugo"
              v-bind:value="this.id_ref"
              :data-source="lookup_dataset_ref"
              :value-expr="id_ref"
              :display-expr="display_ref"
              placeholder=" Selecionar"
              :show-clear-button="true"
              style='margin-bottom: 15px'
             >
             </DxSelectBox>-->

              <div class="text-h5 text-overline text-orange-9">
                <b>Quantidade</b>
              </div>
              <q-input
                style="font-size: 25px"
                class="input"
                outlined
                v-model="qtd_refugo"
                :value.sync="qtd_refugo"
              />

              <div class="text-caption text-grey">
                <br /><b>{{ msgRefugoProducao }}</b>
              </div>
            </q-card-section>
          </q-card-section>
          <q-card-actions align="right" class="text-primary">
            <q-btn flat label="CANCELAR" v-close-popup @click="1 == 1" />
            <q-btn flat label="OK" v-close-popup @click="onApara()" />
          </q-card-actions>
        </q-card>
      </q-dialog>
    </div>

    <div v-if="parada == true" class="q-pa-md q-gutter-sm">
      <q-dialog v-model="parada" persistent>
        <q-card>
          <q-card-section>
            <div class="text-h5" style="text-align: left">
              <b>{{ this.nm_maquina }}</b>
            </div>
          </q-card-section>
          <q-card-section>
            <transition name="slide-fade">
              <div
                v-if="this.cd_status_producao == 3"
                class="q-pa-md flex flex-center"
              >
                <q-knob
                  :max="61"
                  :min="1"
                  disable
                  v-model="tempo_parado"
                  show-value
                  size="90px"
                  :thickness="0.1"
                  color="F63B00"
                  class="text-primary q-ma-md"
                />
              </div>
            </transition>
            <transition name="slide-fade">
              <div
                class="text-h3 text-orange-9"
                style="text-align: center"
                v-if="this.cd_status_producao == 3"
              >
                <label> {{ this.tempo_passado }} MINUTO (S) </label>
              </div>
            </transition>
          </q-card-section>
          <transition name="slide-fade">
            <q-card-section
              v-if="this.nm_causa_parada != ''"
              class="my-card q-pa-md row items-start q-gutter-md motivo_parada"
              flat
              bordered
            >
              <div class="motivo_parada text-h4">
                {{ this.nm_causa_parada }}
              </div>
            </q-card-section>
          </transition>

          <q-card-section
            class="my-card q-pa-md row items-start q-gutter-md"
            flat
            bordered
          >
            <q-card-section>
              <div class="text-h5 text-overline text-orange-9">
                <b>PARADA DE PRODUÇÃO</b>
              </div>
              <transition name="slide-fade">
                <div
                  v-if="this.status_parada == 'INICIO DA PARADA'"
                  class="text-h5 q-mt-sm q-mb-xs"
                >
                  TIPO DE PARADA

                  <div class="div-select">
                    <select v-model="causa_parada">
                      <option
                        v-for="lookup_dataset in lookup_dataset"
                        v-bind:key="lookup_dataset.cd_tipo_maquina_parada"
                        v-bind:value="lookup_dataset.cd_tipo_maquina_parada"
                      >
                        {{ lookup_dataset.nm_tipo_maquina_parada }}
                      </option>
                    </select>
                  </div>

                  <!--<DxSelectBox
              v-model="causa_parada"
              v-bind:value="this.id"
              :data-source="lookup_dataset"
              :value-expr="id"
              :display-expr="display"
              placeholder=" Selecionar"
              :show-clear-button="true"
             >
             </DxSelectBox>-->
                </div>
              </transition>

              <div class="text-caption text-grey">
                <b>{{ msgParadaProducao }}</b>
              </div>
            </q-card-section>
          </q-card-section>
          <q-card-actions align="right" class="text-primary">
            <transition name="slide-fade">
              <q-btn
                v-if="this.cd_status_producao != 3"
                flat
                label="CANCELAR"
                v-close-popup
                @click="1 == 1"
              />
            </transition>
            <q-btn flat @click="onParada()"> {{ this.status_parada }} </q-btn>
          </q-card-actions>
        </q-card>
      </q-dialog>
    </div>

    <!--------------------------------------------------------------------------------------------------->
    <q-dialog v-model="popupMotivoProxima">
      <q-card style="width: 700px; max-width: 80vw;">
        <div class="text-h5 row margin1 ">
          Selecione o motivo
          <q-space />
          <q-btn flat v-close-popup round dense icon="close" />
        </div>
        <q-separator />
        <div
          class="text-negative text-center text-h6 margin1"
          v-show="consultaLog.length >= 3"
        >
          Essa OP foi pulada 3 vezes ou mais, um aviso será enviado ao Gestor!
        </div>
        <q-select
          label="Motivo"
          class="margin1"
          v-model="motivo_proxima"
          input-debounce="0"
          :options="this.lookup_motivo_proxima"
          option-value="cd_motivo_desvio"
          option-label="nm_motivo_desvio"
        >
          <template v-slot:prepend>
            <q-icon name="store" />
          </template>
        </q-select>
        <!--<div>
            <grid
              :cd_menuID="6852"
              :cd_apiID="306"
              :cd_parametroID="this.cd_maquina"
              :nm_json="{}"
            />
          </div>-->

        <q-card-actions class="margin1">
          <q-btn
            rounded
            color="primary"
            icon="check"
            label="Confirmar"
            :loading="icProximaOP"
            :disable="icProximaOP"
            @click="ProximaOP()"
          />

          <q-space />
          <q-btn
            flat
            color="primary"
            icon="close"
            rounded
            label="Cancelar"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import { DxSelectBox } from "devextreme-vue/select-box";
import DxButton from "devextreme-vue/button";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import Procedimento from "../http/procedimento";
import Producao from "../http/producao";
import Menu from "../http/menu";
import grid_orden from "../views/grid";
import componente from "../views/display-componente";
import MasterDetail from "./MasterDetail.vue";
import Grid from "./grid.vue";
import Lookup from "../http/lookup";

var filename = "DataGrid.xlsx";
var cd_empresa = 0;
var cd_menu = 0;
var cd_cliente = 0;
var cd_api = 0;
var api = "";
var a = false;
cd_empresa = localStorage.cd_empresa;
var dados = [];
var sParametroApi = "";
const dataGridRef = "dataGrid";

export default {
  data() {
    return {
      tituloMenu: "",
      dt_inicial: "",
      dt_final: "",
      columns: [],
      dataSourceConfig: [],
      aponamento_inicio: 0,
      total: {},
      dataGridInstance: null,

      temD: false,
      temPanel: false,
      cd_menu_destino: 0,
      cd_api_destino: 0,
      qt_tempo: 0,
      polling: 60000,
      exportar: false,
      cd_empresa: 0,
      cd_menu: 0,
      cd_cliente: 0,
      cd_api: 0,
      api: 0,
      cd_menu_origem: 0,
      cd_api_origem: 0,
      ds_arquivo: "",
      ds_menu_descritivo: "",
      popupVisible: false,
      ic_form_menu: "N",
      formData: {},
      popupMotivoProxima: false,
      turno: "",
      operador: "",
      inotifica: 0,
      icProximaOP: false,
      tabPanel: false,
      ordem: 0,
      entrega: "",
      vol: "",
      comp: "",
      esp: "",
      larg: "",
      qtd: "",
      cliente: "",
      nm_razao_social_cliente: "",
      produto: "",
      pedido: "",
      data: "",
      peso: "",
      composicao: "",
      obs: "",
      funcionario: "",
      ds_processo: "",
      hoje: "",
      hora: "",
      sg_unidade_medida: "",
      sg_unidade_processo: "",
      show: false,
      cd_operacao: 0,
      cd_mascara_produto: 0,
      qt_planejada_processo: 0,
      cd_processo_padrao: 0,
      iparada: 1,
      desenho: false,
      fimproducao: false,
      refugo: false,
      parada: false,
      labelQtd: "Quantidade",
      retorno: "",
      medida: "",
      cd_maquina: 0,
      cd_item_processo: 0,
      motivo_proxima: "",
      cd_operador: 0,
      caminho_desenho: "",
      desenho_processo: "",
      saldo: 0,
      qtd_producao: 0,
      nm_maquina: "",
      qtd_refugo: 0,
      qtd_parada: 0,
      label_MEDIDAS: "MEDIDAS",
      medidas: "",
      desativa_imagem: 1,
      sequencia: 0,
      operacao_nm: "",
      setup: "",
      prod: "",
      dialog: false,
      maximizedToggle: false,
      Alerta_Mensagem: "",
      msgFimProducao:
        "Atenção, o Operador pode realizar a Baixa Total ou Parcial da Produção.!",
      msgRefugoProducao:
        "Atenção, o Operador deve digitar a quantidade que foi Perdida ou Refugada.!",
      msgParadaProducao:
        "Atenção, o Operador deve informar o motivo da Parada de Produção.!",
      motivo_parada: "",
      apontamento_parada: 0,
      status_parada: "",
      proximas_ordens: 0,
      lookup_dados: [],
      lookup_dataset: [],
      id: "",
      display: "",
      id_tipo_parada: 0,
      cd_mascara_produto: "",
      dados_componentes: [],
      par_api: "",
      data_componentes: [],
      prox_ordem: false,
      lookup_dados_ref: [],
      lookup_dataset_ref: [],
      id_ref: "",
      display_ref: "",
      id_tipo_parada_ref: 0,
      carregando: false,
      cd_item_pedido_venda: 0,
      tipo_parada_selecionada: 0,
      outros: false,
      producao: false,
      causa_refugo: 0,
      causa_parada: 0,
      qtd_produzida: 0,
      index_data: 0,
      Peso_Material: "",
      Peso_Material_Tub: "",
      lookup_motivo_proxima: [],
      Peso_Material_Tub_Caixa: "",
      Qt_caixa: "",
      Caixa_coletiva: "",
      timer: "",
      carregaEstorno: false,
      tempo_parado: 0,
      tempo_passado: 0,
      cd_status_producao: 0,
      cd_bloqueio_parada: false,
      nm_causa_parada: "",
      status_produzida: false,
      componentes: false,
      componentes_atual: [],
      prox_1: [],
      prox_2: [],
      consultaLog: [],
    };
  },
  computed: {
    dataGrid: function() {
      return this.$refs[dataGridRef].instance;
    },
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

    if (!this.qt_tempo == 0) {
      this.pollData();
      localStorage.polling = 1;
    }
  },

  async mounted() {
    await this.carregaDados();
    var d = await Lookup.montarSelect(this.cd_empresa, 4497);
    this.lookup_motivo_proxima = JSON.parse(
      JSON.parse(JSON.stringify(d.dataset))
    );
  },

  components: {
    DxButton,
    grid_orden,
    componente,
    MasterDetail,
    Grid,
    Lookup,
    DxSelectBox,
  },
  watch: {
    async qtd_produzida() {
      if (this.saldo == NaN) {
        this.saldo = 0;
      }
      await this.CalculaSaldo();
    },
    async qtd() {
      if (this.saldo == NaN) {
        this.saldo = 0;
      }
      await this.CalculaSaldo();
    },
    async saldo() {
      if (this.saldo == NaN) {
        this.saldo = 0;
        await this.CalculaSaldo();
      }
    },
    async index_data() {
      if (this.index_data > this.dataSourceConfig.length - 1) {
        this.index_data = this.dataSourceConfig.length - 1;
      }
    },
  },

  methods: {
    async ProximaOP() {
      if (!!this.motivo_proxima.cd_motivo_desvio == false) {
        let not = {
          message: "Selecione o motivo!",
          type: "error",
        };
        notify(not);
        return;
      }

      this.icProximaOP = true;
      localStorage.cd_cliente = 0;
      localStorage.qt_refugo = 0;
      localStorage.cd_parametro = 11;
      localStorage.cd_processo = this.ordem;
      localStorage.cd_operacao = 0;
      localStorage.cd_maquina = this.cd_maquina;
      localStorage.cd_operador = this.cd_operador;
      localStorage.qt_apontamento = 0;
      localStorage.cd_motivo = this.motivo_proxima.cd_motivo_desvio;
      localStorage.cd_item_processo = this.cd_item_processo;
      try {
        api = "";
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);
        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;
        //var proxima = [];

        let proxima = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );
      } catch (error) {
        let not = {
          message: "Impossível salvar Log!",
          type: "error",
        };
        notify(not);
      }

      try {
        if (this.index_data + 1 > this.dataSourceConfig.length - 1) {
          await this.carregaDados();
          this.icProximaOP = false;
          this.popupMotivoProxima = false;
          this.index_data = 0;
          return;
        }
        if (this.index_data < this.dataSourceConfig.length - 1) {
          this.index_data = this.index_data + 1;
        }

        await this.carregaDados();

        this.popupMotivoProxima = false;
        this.icProximaOP = false;
      } catch (error) {
        this.icProximaOP = false;
        this.popupMotivoProxima = false;
      }
    },
    async onClickProxima() {
      this.motivo_proxima = "";
      localStorage.cd_cliente = 0;
      localStorage.qt_refugo = 0;
      localStorage.cd_parametro = 10;
      localStorage.cd_processo = this.ordem;
      localStorage.cd_operacao = 0;
      localStorage.cd_maquina = this.cd_maquina;
      localStorage.cd_operador = this.cd_operador;
      localStorage.qt_apontamento = 0;
      localStorage.cd_motivo = 0;
      localStorage.cd_item_processo = this.cd_item_processo;
      try {
        api = "";
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);

        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        this.consultaLog = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );
      } catch (error) {
        let not = {
          message: "Impossível consultar Logs!",
          type: "error",
        };
        notify(not);
      }
      this.popupMotivoProxima = true;
    },
    async onClickSetupFim() {
      localStorage.cd_cliente = 0;
      localStorage.qt_refugo = 0;
      localStorage.cd_parametro = 2;
      localStorage.cd_processo = this.ordem;
      localStorage.cd_operacao = this.cd_operacao;
      localStorage.cd_maquina = this.cd_maquina;
      localStorage.cd_operador = this.cd_operador;
      localStorage.qt_apontamento = this.qtd_producao;
      localStorage.cd_motivo = 0;
      localStorage.cd_item_processo = this.cd_item_processo;
      try {
        this.carregaEstorno = true;
        api = "";
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);

        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        var dataSourceConfigs_fim = [];
        dataSourceConfigs_fim = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );
      } catch (error) {
        let not = {
          message: "Impossivel lançar o múltiplo!",
          type: "error",
        };
        notify(not);
        this.carregaEstorno = false;
      }
      //Próximo Op com Saldo, inclusive pode ser a mesma.
      this.limpa_tudo();
      this.saldo = 0;
      this.index_data = 0;
      await this.carregaDados();
    },
    async CalculaSaldo() {
      if (this.saldo == NaN) {
        this.saldo = 0;
      }
      this.saldo = parseInt(this.qtd) - parseInt(this.qtd_produzida);
    },
    async onClickEstorno() {
      this.carregaEstorno = true;
      localStorage.cd_cliente = 0;
      localStorage.qt_refugo = 0;
      localStorage.cd_parametro = 9;
      localStorage.cd_processo = this.ordem;
      localStorage.cd_operacao = this.cd_operacao;
      localStorage.cd_maquina = this.cd_maquina;
      localStorage.cd_operador = this.cd_operador;
      localStorage.qt_apontamento = this.qtd_producao;
      localStorage.cd_motivo = 0;
      localStorage.cd_item_processo = this.cd_item_processo;

      let dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);
      //

      let api = dados.nm_identificacao_api;

      let sParametroApi = dados.nm_api_parametro;

      var SendExtorno = [];

      SendExtorno = await Producao.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        sParametroApi
      );
      this.carregaEstorno = false;
      if (SendExtorno[0].Cod == 0) {
        notify(SendExtorno[0].Msg);
      } else {
        this.qtd_produzida = SendExtorno[0].Produzido;
        this.qtd = SendExtorno[0].Planejado;
        this.saldo = parseInt(this.qtd) - parseInt(this.qtd_produzida);
      }

      //await this.carregaDados();
      //notify(SendExtorno[0].Msg);
    },
    onClickRefugo() {
      this.tabPanel = true;
      this.refugo = true;
      this.outros = false;
    },
    onClickParada() {
      if (this.apontamento_parada == 0) {
        this.status_parada = "INICIO DA PARADA";
      } else {
        this.status_parada = "FIM DA PARADA";
      }
      this.parada = true;
    },
    //onClickSetupFim() {
    //  this.outros = false;
    //  this.qtd_producao = this.saldo;
    //},

    popClick() {
      this.popupVisible = true;
    },

    onHiding() {
      this.popupVisible = false; // Handler of the 'hiding' event
    },

    onOrdem() {
      if (this.proximas_ordens == 0) {
        this.proximas_ordens = 1;
      } else {
        this.proximas_ordens = 0;
      }
    },

    onOutros() {
      if (this.outros == false) {
        this.outros = true;
      } else {
        this.outros = false;
      }
    },

    async showMenu() {
      //liberação do localStorage
      localStorage.caminho_desenho = "";
      localStorage.desenho_processo = "";
      localStorage.cd_parametro = 0;

      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_menu = localStorage.cd_menu;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      this.maquina = localStorage.usuario;
      this.ordem = 0;
      this.cd_parametro = 0;

      //Api Origem
      if (this.cd_api_origem == 0) {
        this.api_origem = this.cd_api;
        this.cd_menu_origem = this.cd_menu;
      } else {
        this.cd_api = this.cd_api_origem;
        this.cd_menu = this.cd_menu_origem;
      }
      //
      var data = new Date(),
        dia = data.getDate().toString(),
        diaF = dia.length == 1 ? "0" + dia : dia,
        mes = (data.getMonth() + 1).toString(), //+1 pois no getMonth Janeiro começa com zero.
        mesF = mes.length == 1 ? "0" + mes : mes,
        anoF = data.getFullYear();

      localStorage.dt_inicial = mes + "-" + dia + "-" + anoF;
      localStorage.dt_final = mesF + "-" + diaF + "-" + anoF;
      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';
      sParametroApi = dados.nm_api_parametro;

      this.qt_tabsheet = dados.qt_tabsheet;
      this.cd_menu_destino = this.cd_menu;
      this.cd_api_destino = this.cd_api;
      this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa;
      this.exportar = false;
      this.ds_menu_descritivo = dados.ds_menu_descritivo;
      this.ic_form_menu = dados.ic_form_menu;
      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      if (dados.ic_exportacao == "S") {
        this.exportar = true;
      }

      localStorage.cd_tipo_consulta = 0;

      if (!dados.cd_tipo_consulta == 0) {
        dados.cd_tipo_consulta;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';

      filename = this.tituloMenu + ".xlsx";

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
    },

    pegaImg() {
      var imagem =
        "http://www.egisnet.com.br/img/Desenho/" +
        localStorage.nm_caminho_logo_empresa;
      return imagem;
    },

    ContaSegundos() {
      if (this.tempo_parado == 61) {
        this.tempo_parado = 1;
        this.tempo_passado++;
      } else {
        this.tempo_parado++;
      }
    },

    async carregaDados() {
      notify("Aguarde...");
      this.carregaEstorno = true;
      this.outros = false;
      await this.showMenu();
      this.temPanel = true;
      if (this.inotifica == 0) {
        notify(`Aguarde... estamos montando a consulta para você, aguarde !`);
        this.inotifica = 1;
      }
      let sApi = sParametroApi;

      this.dataSourceConfig = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        this.api,
        sApi
      );

      if (this.dataSourceConfig.length == 0) {
        await this.limpa_tudo();
        notify("Nenhuma Ordem de Produção encontrada!");
        return;
      }

      if (this.dataSourceConfig[0].cd_processo == 0) {
        this.turno = this.dataSourceConfig[0].sg_turno;
        this.operador = this.dataSourceConfig[this.index_data].nm_funcionario;
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else if (!!this.dataSourceConfig[this.index_data].cd_processo) {
        this.componentes_atual = await this.carregaComponentes(
          this.dataSourceConfig[this.index_data].cd_processo
        );

        if (this.index_data + 1 <= this.dataSourceConfig.length - 1) {
          this.prox_1 = await this.carregaComponentes(
            this.dataSourceConfig[this.index_data + 1].cd_processo
          );
        }

        if (this.index_data + 2 <= this.dataSourceConfig.length - 1) {
          this.prox_2 = await this.carregaComponentes(
            this.dataSourceConfig[this.index_data + 2].cd_processo
          );
        }

        //---------------

        //if (this.dataSourceConfig.length == 2) {
        //  this.prox_1 = await this.carregaComponentes(
        //    this.dataSourceConfig[this.index_data + 1].cd_processo
        //  );
        //} else if (this.dataSourceConfig.length >= 3) {
        //  this.prox_1 = await this.carregaComponentes(
        //    this.dataSourceConfig[this.index_data + 1].cd_processo
        //  );
        //  this.prox_2 = await this.carregaComponentes(
        //    this.dataSourceConfig[this.index_data + 2].cd_processo
        //  );
        //}

        this.ordem = this.dataSourceConfig[this.index_data].cd_processo;
        this.turno = this.dataSourceConfig[this.index_data].sg_turno;
        this.operador = this.dataSourceConfig[this.index_data].nm_funcionario;
        this.data = this.dataSourceConfig[this.index_data].dt_programacao;

        this.entrega = new Date(
          this.dataSourceConfig[this.index_data].dt_entrega_processo
        ).toLocaleDateString();
        this.cliente = this.dataSourceConfig[
          this.index_data
        ].nm_fantasia_cliente;
        this.nm_razao_social_cliente = this.dataSourceConfig[
          this.index_data
        ].nm_razao_social_cliente;
        this.nm_maquina = this.dataSourceConfig[this.index_data].nm_maquina;
        this.produto = this.dataSourceConfig[this.index_data].nm_produto_pedido;
        this.pedido = this.dataSourceConfig[this.index_data].cd_pedido_venda;
        this.cd_item_pedido_venda = this.dataSourceConfig[
          this.index_data
        ].cd_item_pedido_venda;
        this.qtd = this.dataSourceConfig[this.index_data].qt_planejada_processo
          .toString()
          .replace(".", ",");
        this.larg = this.dataSourceConfig[this.index_data].qt_largura
          .toString()
          .replace(".", ",");
        this.esp = this.dataSourceConfig[this.index_data].qt_espessura
          .toString()
          .replace(".", ",");
        this.comp = this.dataSourceConfig[this.index_data].qt_comprimento
          .toString()
          .replace(".", ",");
        this.vol = this.dataSourceConfig[this.index_data].qt_volume
          .toString()
          .replace(".", ",");
        this.peso = this.dataSourceConfig[this.index_data].qt_peso_liquido_total
          .toString()
          .replace(".", ","); //Peso bruto -> qt_peso_bruto_total
        this.composicao = this.dataSourceConfig[
          this.index_data
        ].nm_projeto_composicao;
        this.peso_un = this.dataSourceConfig[this.index_data].qt_peso_unitario;
        this.peso_esp = this.dataSourceConfig[
          this.index_data
        ].qt_peso_especifico;
        this.peso_emb = this.dataSourceConfig[this.index_data].qt_embalagem;
        this.obs = this.dataSourceConfig[this.index_data].nm_obs_operacao;
        this.ds_processo = this.dataSourceConfig[
          this.index_data
        ].nm_obs_medida_item;

        this.sg_unidade_medida = this.dataSourceConfig[
          this.index_data
        ].sg_unidade_medida;
        this.sg_unidade_processo = this.dataSourceConfig[
          this.index_data
        ].sg_unidade_processo;
        this.qt_utilizada = this.dataSourceConfig[this.index_data].qt_utilizada;
        this.cd_mascara_produto = this.dataSourceConfig[
          this.index_data
        ].cd_mascara_produto;
        this.qt_planejada_processo = this.dataSourceConfig[
          this.index_data
        ].qt_planejada_processo;
        this.cd_processo_padrao = this.dataSourceConfig[
          this.index_data
        ].cd_processo_padrao;
        this.caminho_desenho = this.dataSourceConfig[
          this.index_data
        ].nm_caminho_desenho;
        this.desenho_processo = this.dataSourceConfig[
          this.index_data
        ].nm_desenho_processo;
        this.cd_maquina = this.dataSourceConfig[this.index_data].cd_maquina;
        this.cd_item_processo = this.dataSourceConfig[
          this.index_data
        ].cd_item_processo;
        this.cd_operador = this.dataSourceConfig[this.index_data].cd_operador;
        this.cd_operacao = this.dataSourceConfig[this.index_data].cd_operacao;
        this.saldo = this.dataSourceConfig[this.index_data].qt_saldo;
        this.medidas = this.dataSourceConfig[this.index_data].nm_medida_retorno;
        this.sequencia = this.dataSourceConfig[this.index_data].cd_seq_processo;
        this.operacao_nm = this.dataSourceConfig[
          this.index_data
        ].nm_fantasia_operacao;
        this.setup = this.index_data; //this.dataSourceConfig[this.index_data].
        this.prod = this.dataSourceConfig[
          this.index_data
        ].qt_hora_prog_operacao;
        this.cd_mascara_produto = this.dataSourceConfig[
          this.index_data
        ].cd_mascara_produto;
        this.Peso_Material = this.dataSourceConfig[
          this.index_data
        ].qt_peso_liquido
          .toString()
          .replace(".", ",");
        this.Peso_Material_Tub = this.dataSourceConfig[
          this.index_data
        ].qt_peso_liq_material
          .toString()
          .replace(".", ",");
        this.Peso_Material_Tub_Caixa = this.dataSourceConfig[
          this.index_data
        ].qt_peso_liq_material_cx
          .toString()
          .replace(".", ",");
        this.Qt_caixa = this.dataSourceConfig[this.index_data].qt_embalagem;
        this.Caixa_coletiva = this.dataSourceConfig[
          this.index_data
        ].qt_peso_liq_total
          .toString()
          .replace(".", ",");
        this.qtd_produzida = parseInt(this.qtd) - parseInt(this.saldo);
        this.cd_status_producao = this.dataSourceConfig[
          this.index_data
        ].cd_status_producao;

        if (this.cd_status_producao == 3) {
          //Inicio de Parada com bloqueio
          this.cd_bloqueio_parada = true;
          this.parada = true;
          this.apontamento_parada = 1;
          this.onClickParada();
          this.timer = setInterval(this.ContaSegundos, 1000);
        } else if (this.cd_status_producao == 33) {
          //Inicio de Parada Simples
          this.cd_bloqueio_parada = false;
          this.parada = true;
          this.apontamento_parada = 1;
          this.onClickParada();
        }
        if (this.saldo < 0) {
          this.saldo = 0;
        }
        if (this.medidas == "") {
          this.label_MEDIDAS = "DESENHO";
          this.medidas = this.dataSourceConfig[
            this.index_data
          ].cd_desenho_processo_padrao;
        }
        if (
          this.dataSourceConfig[this.index_data].dt_ini_prod_operacao == null
        ) {
          this.aponamento_inicio = 0;
          this.producao = false;
        } else {
          this.aponamento_inicio = 1;
          this.producao = true;
        }
        if (this.dataSourceConfig[this.index_data].desenho_processo == "") {
          this.desativa_imagem = 1;
        } else {
          this.desativa_imagem = 0;
        }

        localStorage.caminho_desenho = this.caminho_desenho;
        localStorage.desenho_processo = this.desenho_processo;
        this.lookup_dados = await Lookup.montarSelect(this.cd_empresa, 633);
        this.lookup_dataset = JSON.parse(
          JSON.parse(JSON.stringify(this.lookup_dados.dataset))
        );
        this.id = this.lookup_dados.chave;
        this.display = this.lookup_dados.display;
        this.lookup_dados_ref = await Lookup.montarSelect(
          this.cd_empresa,
          2742
        );
        this.lookup_dataset_ref = JSON.parse(
          JSON.parse(JSON.stringify(this.lookup_dados_ref.dataset))
        );
        this.id_ref = this.lookup_dados_ref.chave;
        this.display_ref = this.lookup_dados_ref.display;
        //Avaliar o Status da Ordem de produção e Já confirmar o Posicionamento dos botões
      }
      this.carregaEstorno = false;

      notify("Carregamento Concluído");
    },

    async onInicio() {
      if (!this.ordem == 0) {
        this.aponamento_inicio = 1;

        //definindo e validando

        localStorage.cd_cliente = 0;
        localStorage.cd_parametro = 1; //INICIO
        localStorage.qt_refugo = 0; //REFUGO ESTA 0 POIS É INICIO DE APONTAMENTO
        localStorage.cd_processo = this.ordem;
        localStorage.cd_operacao = this.cd_operacao;
        localStorage.cd_maquina = this.cd_maquina;
        localStorage.cd_operador = this.cd_operador;
        localStorage.qt_apontamento = this.saldo;
        localStorage.cd_motivo = 0;
        localStorage.cd_item_processo = this.cd_item_processo;

        api = "";
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);
        //

        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        var dataSourceConfigs = [];
        dataSourceConfigs = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );

        this.formData = dataSourceConfigs[0];

        if (dataSourceConfigs[0].result == "S") {
          notify(dataSourceConfigs[0].mensagem);
          this.inotifica = 1;
        } else {
          notify(dataSourceConfigs[0].mensagem);
          this.inotifica = 1;
        }

        this.carregaDados();
      } else {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      }
      //dataSourceConfigs = [];
    },

    async carregaComponentes(cd_processo) {
      notify("Aguarde");

      if (!!cd_processo == false) {
        return;
      }

      let a = cd_processo;

      //LISTANDO COMPONENTES//
      this.dados_componentes = await Menu.montarMenu(this.cd_empresa, 0, 343); //'titulo';
      this.par_api = this.dados_componentes.nm_api_parametro;
      localStorage.cd_identificacao = a;
      localStorage.cd_parametro = 0;

      this.data_componentes = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        "343/471",
        this.par_api
      );
      return this.data_componentes;
    },

    onVoltar() {
      if (this.aponamento_inicio == 0) {
        this.aponamento_inicio = 1;
      } else {
        this.aponamento_inicio = 0;
      }
    },

    async onFim(carrega) {
      !!carrega == false ? (carrega = false) : "";
      if (this.qtd_producao == 0 || this.qtd_producao < 0) {
        notify("A quantidade mínima para apontamento deve ser maior que 0!");
        this.qtd_producao = 0;
        return;
      }
      this.carregaEstorno = true;

      notify("Aguarde...");
      if (this.ordem == 0) {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else {
        this.outros = false;
        //this.aponamento_inicio = 0;
        //definindo e validando

        localStorage.cd_cliente = 0;
        localStorage.qt_refugo = 0;
        localStorage.cd_parametro = 2;
        localStorage.cd_processo = this.ordem;
        localStorage.cd_operacao = this.cd_operacao;
        localStorage.cd_maquina = this.cd_maquina;
        localStorage.cd_operador = this.cd_operador;
        localStorage.qt_apontamento = this.qtd_producao;
        localStorage.cd_motivo = 0;
        localStorage.cd_item_processo = this.cd_item_processo;

        //Atualiza o Saldo, apenas para mostrar na tela
        this.qtd_produzida =
          parseInt(this.qtd_producao) + parseInt(this.qtd_produzida);
        this.saldo = this.qtd - this.qtd_produzida;

        //if (this.saldo == 0) {
        //  this.status_produzida = true;
        //  this.dialog = true;
        //  this.Alerta_Mensagem = "Ordem de produção finalizada!";
        //}
        if (this.saldo < 0) {
          this.saldo = 0;
          if (this.status_produzida == false) {
            this.status_produzida = true;
            this.dialog = true;
            this.Alerta_Mensagem =
              "A quantidade produzida ultrapassou a quantidade planejada";
          }
          this.saldo = 0;
        }
        try {
          api = "";
          dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);

          api = dados.nm_identificacao_api;

          let sParametroApi = dados.nm_api_parametro;

          var dataSourceConfigs_fim = [];

          dataSourceConfigs_fim = await Producao.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            api,
            sParametroApi
          );
        } catch (error) {
          let not = {
            message: "Impossivel lançar o múltiplo!",
            type: "error",
          };
          notify(not);
          this.carregaEstorno = false;
        }
        this.carregaEstorno = false;
      }
      //  this.formData = dataSourceConfigs_fim[0];
      //
      //  if (dataSourceConfigs_fim[0].result == "S") {
      //    notify(dataSourceConfigs_fim[0].mensagem);
      //    this.inotifica = 1;
      //  } else {
      //    notify(dataSourceConfigs_fim[0].mensagem);
      //    this.inotifica = 1;
      //  }
      //}
      //this.carregaEstorno = false;
      //
      //dataSourceConfigs_fim = [];
      //
      ////Próximo Op com Saldo, inclusive pode ser a mesma.
      ////this.limpa_tudo();
      //this.index_data = 0;
      //if (carrega == true) {
      //  if (this.saldo == 0 || this.saldo < 0) {
      //    await this.carregaDados();
      //  }
      //}
    },

    async onParada() {
      if (this.ordem == 0) {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else {
        try {
          var index_parada = this.lookup_dataset.findIndex(
            (obj) => obj.cd_tipo_maquina_parada == this.causa_parada
          );
          this.nm_causa_parada = this.lookup_dataset[
            index_parada
          ].nm_tipo_maquina_parada;
        } catch {
          this.nm_causa_parada = "";
        }

        //parada = true - produção esta parada

        if (this.apontamento_parada == 0) {
          this.apontamento_parada = 1;
          localStorage.cd_parametro = 3;
        } else {
          this.apontamento_parada = 0;
          localStorage.cd_parametro = 4;
          clearInterval(this.timer);
          //this.parada = false;
        }

        //definindo e validando

        localStorage.cd_cliente = 0;
        //this.cd_inicio               = 1;
        localStorage.qt_refugo = 0;
        localStorage.cd_processo = this.ordem;
        localStorage.cd_operacao = this.cd_operacao;
        localStorage.cd_maquina = this.cd_maquina;
        localStorage.cd_operador = this.cd_operador;
        localStorage.qt_apontamento = 0;
        localStorage.cd_motivo = this.causa_parada;
        localStorage.cd_item_processo = this.cd_item_processo;

        //Atualiza o Saldo, apenas para mostrar na tela
        this.saldo = this.qtd - this.qtd_producao;
        //

        api = "";
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);
        //

        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        var dataSourceConfigs_parada = [];

        this.cd_empresa = localStorage.cd_empresa;
        dataSourceConfigs_parada = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );

        this.formData = dataSourceConfigs_parada[0];

        if (dataSourceConfigs_parada[0].result == "S") {
          notify(dataSourceConfigs_parada[0].mensagem);
          this.inotifica = 1;
        } else {
          notify(dataSourceConfigs_parada[0].mensagem);
          this.inotifica = 1;
        }
      }
      await this.carregaDados();

      if (this.cd_status_producao == 3) {
        if (this.cd_status_producao == 3) {
        } else {
          clearInterval(this.timer);
          this.tempo_parado = 0;
          this.tempo_passado = 0;
          this.parada = false;
        }
      } else {
        this.parada = false;
        clearInterval(this.timer);
        this.tempo_parado = 0;
        this.tempo_passado = 0;
      }
      this.status_parada = "FIM DA PARADA";

      dataSourceConfigs_parada = [];

      //Próximo Op com Saldo, inclusive pode ser a mesma.
      //
      this.causa_parada = 0;
    },

    async onApara() {
      if (this.ordem == 0) {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else {
        localStorage.cd_parametro = 6;
        localStorage.cd_cliente = 0;
        localStorage.qt_refugo = this.qtd_refugo;
        localStorage.cd_processo = this.ordem;
        localStorage.cd_operacao = this.cd_operacao;
        localStorage.cd_maquina = this.cd_maquina;
        localStorage.cd_operador = this.cd_operador;
        localStorage.qt_apontamento = this.qtd_refugo;
        localStorage.cd_motivo = this.causa_refugo;
        localStorage.cd_item_processo = this.cd_item_processo;

        api = "";

        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);

        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        var dataSourceConfigs_refugo = [];
        dataSourceConfigs_refugo = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );

        this.formData = dataSourceConfigs_refugo[0];

        if (dataSourceConfigs_refugo[0].result == "S") {
          notify(dataSourceConfigs_refugo[0].mensagem);
          this.inotifica = 1;
        } else {
          notify(dataSourceConfigs_refugo[0].mensagem);
          this.inotifica = 1;
        }

        this.carregaDados();
      }
    },

    async onFimOP() {
      var dataSourceConfigs_fim = [];
      if (this.ordem == 0) {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else {
        this.outros = false;
        this.producao = false;
        this.aponamento_inicio = 0;

        localStorage.cd_cliente = 0;
        localStorage.qt_refugo = 0;
        localStorage.cd_parametro = 8;
        localStorage.cd_processo = this.ordem;
        localStorage.cd_operacao = this.cd_operacao;
        localStorage.cd_maquina = this.cd_maquina;
        localStorage.cd_operador = this.cd_operador;
        localStorage.qt_apontamento = 0;
        localStorage.cd_motivo = 0;
        localStorage.cd_item_processo = this.cd_item_processo;

        api = "";
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);
        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        dataSourceConfigs_fim = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );
        this.index_data = 0;
        await this.limpa_tudo();
        this.formData = dataSourceConfigs_fim[0];
        if (dataSourceConfigs_fim[0].result == "S") {
          notify(dataSourceConfigs_fim[0].mensagem);
          this.inotifica = 1;
        } else {
          notify(dataSourceConfigs_fim[0].mensagem);
        }
        this.inotifica = 1;
      }
      dataSourceConfigs_fim = [];
      await this.carregaDados();
    },

    async onImagem() {
      this.desenho = true;
    },

    onDesenho() {
      if (this.ordem == 0) {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else {
        this.desenho = true;
      }
    },
    pegaImg() {
      if (this.desativa_imagem == 1) {
      } else {
        var imagem =
          "http://www.egisnet.com.br/img/Desenho/" + this.desenho_processo;
        return imagem;
      }
    },

    async onConfirmarParada() {
      if (this.ordem == 0) {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else {
        if (this.parada == 0) {
          this.iparada = 1;
        } else {
          this.iparada = 0;
        }
        //#region definindo e validando
        localStorage.cd_cliente = 0;
        this.cd_inicio = 0;

        localStorage.cd_processo = this.ordem;
        localStorage.cd_operacao = this.cd_operacao;
        localStorage.cd_maquina = localStorage.cd_usuario;
        localStorage.cd_operador = this.cd_operador;
        localStorage.qt_apontamento = this.qtd_producao;
        localStorage.cd_motivo = 0;
        localStorage.cd_item_processo = this.cd_item_processo;

        //#endregion

        api = "";
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);

        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        var dataSourceConfigs = [];

        dataSourceConfigs = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );
        this.formData = dataSourceConfigs[0];
        if (dataSourceConfigs[0].Codigo == 1) {
          notify("PRODUÇÃO INICIADA!");
          this.inotifica = 1;
        } else {
          notify("ERRO AO INICIAR PRODUÇÃO!");
          this.inotifica = 1;
        }
        this.carregaDados();
      }
    },
    async limpa_tudo() {
      this.turno = "";
      this.operador = "";
      this.data = "";
      this.entrega = "";
      this.cliente = "";
      this.produto = "";
      this.nm_razao_social_cliente = "";
      this.pedido = "";
      this.qtd = "";
      this.larg = "";
      this.esp = "";
      this.comp = "";
      this.vol = "";
      this.peso = "";
      this.composicao = "";
      this.peso_un = "";
      this.peso_esp = "";
      this.peso_emb = "";
      this.obs = "";
      this.ds_processo = "";
      this.sg_unidade_medida = "";
      this.sg_unidade_processo = "";
      this.qt_utilizada = "";
      this.cd_mascara_produto = "";
      this.qt_planejada_processo = "";
      this.cd_processo_padrao = "";
      this.caminho_desenho = "";
      this.desenho_processo = "";
      this.cd_maquina = "";
      this.cd_item_processo = "";
      this.cd_operador = "";
      this.cd_operacao = "";
      this.saldo = "";
      this.medidas = "";
      this.sequencia = "";
      this.operacao_nm = "";
      this.setup = "";
      this.prod = "";
      this.saldo = 0;
      this.qtd_produzida = 0;
      this.data_componentes = [];
      this.Peso_Material = 0;
      this.Peso_Material_Tub = 0;
      this.Peso_Material_Tub_Caixa = 0;
      this.Qt_caixa = 0;
      this.Caixa_coletiva = 0;
      this.qtd_produzida = 0;
    },
  },
};
</script>

<style>
body {
  display: flex;
  flex-direction: column;
}

.caption {
  font-size: 18px;
  font-weight: 500;
}

.option {
  margin-top: 10px;
  margin-right: 40px;
  display: inline-block;
}

.option:last-child {
  margin-right: 0;
}

.option > .dx-numberbox {
  width: 200px;
  display: inline-block;
  vertical-align: middle;
}

.option > span {
  margin-right: 10px;
}
label-info {
  float: left;
}

label-info-red {
  float: left;
  color: red;
  font-size: 20px;
}

.coluna-20 {
  width: 18%;
  margin-left: 1%;
  margin-right: 1%;
}

.coluna-80 {
  width: 80%;

  height: 100%;
}

.linha {
  display: flex;
  flex-flow: row wrap;
  margin: 1%;
}

.todas {
  width: 100%;
  text-align: center;
  font-size: 17px;
  border-bottom: 1px solid black;
  display: inline-flex;
}

.dados_ordem {
  border-right: 1px solid black;
  width: 25%;
  display: inline-block;
}

.dados_prod {
  border-right: 1px solid black;
  width: 17%;
  display: inline-block;
}

.dados_peso {
  border-right: 1px solid black;
  width: 25%;
  display: inline-block;
}
.obs {
  width: auto;
  word-wrap: break-word;
  border-radius: 0 0 10px 10px;
}

.cliente {
  padding-left: 10px;
  min-width: auto;
}

.produto {
  padding-left: 10px;
  width: 80%;
  text-align: left;
}
.produto_cod {
  padding-left: 50px;
  width: 18%;
}

ul {
  list-style-type: none;
  padding: 0px;
  margin: 0px;
}

.lista_comp {
  width: 100%;
}

.qtd_prod {
  font-size: 50px;
  color: orange;
}

.multiplos {
  margin-bottom: 20px;
  text-align: center;
  width: 100%;
  height: 70px;
}

.lista_quantidade {
  width: 25%;
}

.lista_componentes {
  width: 50%;
}

.div-select {
  width: 100%; /* Tamanho final do select */
  overflow: hidden; /* Esconde o conteúdo que passar do tamanho especificado */
}
select {
  width: 100%; /* Tamanho do select, maior que o tamanho da div "div-select" */
  height: 48px; /* altura do select, importante para que tenha a mesma altura em todo os navegadores */
  font-size: 25px; /* Tamanho da Fonte */
  color: #000; /* Cor da Fonte */
  text-indent: 0.01px; /* Remove seta padrão do FireFox */
  text-overflow: ""; /* Remove seta padrão do FireFox */
}

.motivo_parada {
  width: 100%;
  margin: 0;
  text-align: center;
}

.proximas_ordens {
  margin-left: 1%;
  margin-right: 1%;
  width: 50%;
}
.borda {
  border: 1px solid black;
  border-radius: 10px;
}

.tela_inteira {
  margin-top: 0px;
}
.slide-fade-enter-active {
  transition: all 0.3s ease;
}
.slide-fade-leave-active {
  transition: all 0.4s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter, .slide-fade-leave-to
/* .slide-fade-leave-active below version 2.1.8 */ {
  transform: translateX(10px);
  opacity: 0;
}
.linha-cliente {
  width: 100%;
}
.razao {
  width: 50%;
}
.fantasia {
  width: 50%;
}
</style>
