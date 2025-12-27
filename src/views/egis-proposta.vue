<template>
  <div>
    <div v-if="cd_proposta == 0" class="text-h6 text-bold margin1">
      {{ tituloMenu }}
    </div>
    <div v-else class="text-h6 text-bold margin1">
      {{ tituloMenu }} {{ " - " + cd_proposta }} - {{ hoje }}
    </div>
    <relatoriop v-show="ShowRelatorio" :cd_relatorioID="1" ref="relatoriop" />
    <div class="row items-center" v-show="kanban == false">
      <div class="col">
        <q-btn
          v-show="popup_proposta == true && kanban == false"
          round
          flat
          color="orange-9"
          icon="keyboard_return"
          class="margin1"
          @click="
            (popup_proposta = false),
              $refs.grid_c.carregaDados(),
              limpaTudo(),
              (EditFiltroProposta = false)
          "
        >
          <q-tooltip> Voltar </q-tooltip>
        </q-btn>
      </div>

      <div class="col">
        <q-btn
          v-show="kanban == false"
          color="orange-9"
          icon="add"
          style="float: right"
          class="margin1"
          rounded
          label="Novo"
          @click="NovaProposta()"
        >
          <q-tooltip> Nova Proposta </q-tooltip>
        </q-btn>

        <q-btn
          v-show="kanban == false"
          color="orange-9"
          icon="edit"
          style="float: right"
          class="margin1"
          rounded
          label="Editar"
          @click="EditaProposta()"
        >
          <q-tooltip> Editar Proposta </q-tooltip>
        </q-btn>

        <q-input
          v-show="!EditFiltroProposta"
          color="orange-9"
          v-model="cd_proposta"
          :readonly="EditFiltroProposta"
          type="number"
          min="0"
          label="Proposta"
          @input="filtraProposta"
        >
          <template v-slot:prepend>
            <q-icon name="description" />
          </template>
        </q-input>
      </div>
    </div>

    <div>
      <!-- Procedimento 1537 - pr_consulta_proposta_vendedor_aberto_net -->
      <grid
        class="margin1"
        v-show="popup_proposta == false"
        :cd_menuID="7365"
        :cd_apiID="700"
        :cd_parametroID="0"
        :nm_json="{}"
        ref="grid_c"
        :masterDetail="false"
      >
      </grid>
    </div>

    <!--PROPOSTA--------------------------------------------------------------------------------->
    <q-layout view="lhh LpR ffr">
      <div v-show="popup_proposta == true">
        <q-expansion-item
          icon="summarize"
          v-model="Expansion"
          label="Proposta"
          default-opened
          class="shadow-2 overflow-hidden margin1"
          style="border-radius: 20px; height: auto"
          header-class="bg-orange-9 text-white item-center text-h6"
          expand-icon-class="text-white"
        >
          <div class="scroll margin1">
            <q-input
              dense
              class="margin1"
              v-model="nm_cliente"
              color="orange-9"
              type="text"
              label="Cliente"
              :loading="loading"
              :readonly="readyOnly_cliente"
              ref="inputOrg"
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
                  @click.stop="
                    (cliente = ''), (nm_cliente = ''), (GridCli = false)
                  "
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
            <div class="margin1" v-if="cliente_popup">
              <cliente
                :cd_consulta="true"
                :cd_cadastro_c="this.cliente.cd_cliente == false ? true : false"
                :cd_cliente_c="this.cliente.cd_cliente"
                ref="consulta_cliente"
                @AtualizaCliente="AttCliente()"
              >
              </cliente>
            </div>

            <div v-if="popup_contato" class="margin1" style="max-width: 9vw">
              <q-card style="width: 90vw">
                <q-card-section>
                  <div class="text-h6">Selecione o contato</div>
                </q-card-section>

                <q-separator />

                <q-item
                  v-for="resultado_contato in resultado_contato"
                  :key="resultado_contato.cd_controle"
                  class="q-my-sm"
                  clickable
                  v-ripple
                >
                  <q-item-section avatar>
                    <q-avatar color="orange-9" text-color="white">
                      {{ resultado_contato.letra }}
                    </q-avatar>
                  </q-item-section>

                  <q-item-section>
                    <q-item-label>{{
                      resultado_contato.nm_fantasia_contato
                    }}</q-item-label>
                  </q-item-section>

                  <q-item-section>
                    <q-item-label caption lines="1">{{
                      "Telefone: " + resultado_contato.cd_telefone_contato
                    }}</q-item-label>
                  </q-item-section>
                  <q-item-section>
                    <q-item-label caption lines="1">{{
                      "Celular: " + resultado_contato.cd_celular
                    }}</q-item-label>
                  </q-item-section>
                  <q-item-section>
                    <q-item-label caption lines="1">{{
                      "E-mail: " + resultado_contato.cd_email_contato_cliente
                    }}</q-item-label>
                  </q-item-section>
                  <q-item-section side>
                    <q-btn
                      round
                      icon="send"
                      color="orange-9"
                      @click="ContatoSelecionado(resultado_contato)"
                      clickable
                    />
                  </q-item-section>
                </q-item>
              </q-card>
            </div>

            <div v-if="selecao_contato == true">
              <br />
              <q-bar class="bg-primary text-white" style="border-radius: 10px">
                Contato
              </q-bar>

              <div class="row items-center justify-around">
                <q-input
                  readonly
                  dense
                  color="orange-9"
                  class="umQuartoTela margin1"
                  label="Contato"
                  :stack-label="!!contato_selecionado.Fantasia_contato"
                  v-model="contato_selecionado.Fantasia_contato"
                >
                  <template v-slot:prepend>
                    <q-icon name="contact_page" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="umQuartoTela margin1"
                  label="Telefone"
                  readonly
                  :stack-label="!!contato_selecionado.telefone_contato"
                  v-model="contato_selecionado.telefone_contato"
                >
                  <template v-slot:prepend>
                    <q-icon name="call" />
                  </template>
                </q-input>

                <q-input
                  dense
                  readonly
                  color="orange-9"
                  class="umQuartoTela margin1"
                  label="Celular"
                  :stack-label="!!contato_selecionado.celular_contato"
                  v-model="contato_selecionado.celular_contato"
                >
                  <template v-slot:prepend>
                    <q-icon name="smartphone" />
                  </template>
                </q-input>

                <q-input
                  dense
                  readonly
                  color="orange-9"
                  class="umQuartoTela margin1"
                  label="E-mail"
                  :stack-label="!!contato_selecionado.email_contato"
                  v-model="contato_selecionado.email_contato"
                >
                  <template v-slot:prepend>
                    <q-icon name="email" />
                  </template>
                </q-input>
              </div>
            </div>

            <div v-if="selecao == true">
              <!---DADOS DO CLIENTE--->
              <br />
              <q-bar class="bg-primary text-white" style="border-radius: 10px">
                Cliente
              </q-bar>

              <div class="row items-center justify-around">
                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Fantasia"
                  :stack-label="!!Fantasia"
                  v-model="Fantasia"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="business" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Razão Social"
                  :stack-label="!!Razao_Social"
                  v-model="Razao_Social"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="location_city" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Telefone"
                  :stack-label="!!Telefone_Empresa"
                  v-model="Telefone_Empresa"
                  readyonly
                >
                  <template v-slot:prepend>
                    <q-icon name="call" />
                  </template>
                </q-input>
              </div>

              <div class="row items-center justify-around">
                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="CNPJ/CPF"
                  :stack-label="!!CNPJ"
                  v-model="CNPJ"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="app_registration" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Site"
                  :stack-label="!!nm_dominio_cliente"
                  v-model="nm_dominio_cliente"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="language" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="E-mail"
                  :stack-label="!!Email"
                  v-model="Email"
                  autogrow
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="email" />
                  </template>
                </q-input>
              </div>

              <div class="row items-center justify-around">
                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Tipo de Pessoa"
                  :stack-label="!!Tipo_Pessoa"
                  v-model="Tipo_Pessoa"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="people" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Ramo de Atividade"
                  :stack-label="!!Ramo_Atividade"
                  v-model="Ramo_Atividade"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="badge" />
                  </template>
                </q-input>

                <q-input
                  dense
                  readonly
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Status"
                  :stack-label="!!Status_Cliente"
                  v-model="Status_Cliente"
                >
                  <template v-slot:prepend>
                    <q-icon name="info" />
                  </template>
                </q-input>
              </div>

              <div class="row items-center justify-around">
                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Inscrição Estadual"
                  :stack-label="!!Insc_Estadual"
                  v-model="Insc_Estadual"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="app_registration" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Inscrição Municipal"
                  :stack-label="!!Insc_Municipal"
                  v-model="Insc_Municipal"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="app_registration" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="CEP"
                  :stack-label="!!CEP"
                  v-model="CEP"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="map" />
                  </template>
                </q-input>
              </div>

              <div class="row items-center justify-around">
                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Endereço"
                  :stack-label="!!Endereco"
                  v-model="Endereco"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="pin" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Número"
                  :stack-label="!!Numero"
                  v-model="Numero"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="push_pin" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Complemento"
                  :stack-label="!!Complemento"
                  v-model="Complemento"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="info" />
                  </template>
                </q-input>
              </div>

              <div class="row items-center justify-around">
                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Estado"
                  :stack-label="!!Estado"
                  v-model="Estado"
                >
                  <template v-slot:prepend>
                    <q-icon name="public" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Cidade"
                  :stack-label="!!Cidade"
                  v-model="Cidade"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="apartment" />
                  </template>
                </q-input>
                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Bairro"
                  :stack-label="!!Bairro"
                  v-model="Bairro"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="group" />
                  </template>
                </q-input>
              </div>
              <!-----------------------------------DADOS DA PROPOSTA---------------------------------->
              <br />
              <q-bar
                class="bg-primary text-white"
                @click="toggleCondicoes()"
                style="border-radius: 10px; cursor: pointer"
              >
                Condições
              </q-bar>

              <div
                v-if="toggle_condicoes"
                class="row items-center justify-around"
              >
                <q-select
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="transportadora"
                  label="Transportadora"
                  :options="dataset_lookup_transportadora"
                  option-value="cd_transportadora"
                  option-label="nm_transportadora"
                  :stack-label="!!transportadora"
                >
                  <template v-slot:prepend>
                    <q-icon name="local_shipping" />
                  </template>
                </q-select>
                <q-select
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="tipo_entrega"
                  label="Tipo de Entrega"
                  :options="dataset_lookup_tipo_entrega"
                  option-value="cd_tipo_entrega_produto"
                  option-label="nm_tipo_entrega_produto"
                  :stack-label="!!tipo_entrega"
                  @input="onTipoEntrega()"
                >
                  <template v-slot:prepend>
                    <q-icon name="checklist" />
                  </template>
                </q-select>
              </div>

              <!-- Novos campos -->
              <div
                v-if="toggle_condicoes"
                class="row items-center justify-around"
              >
                <q-toggle
                  class="metadeTela media margin1"
                  label="Fechamento Total"
                  v-model="ic_fechamento_total"
                  disable
                  color="orange-9"
                  :false-value="'N'"
                  :true-value="'S'"
                />
                <q-toggle
                  class="metadeTela media margin1"
                  label="Gera E-mail de Confirmação"
                  v-model="ic_gera_email_confirmacao"
                  color="orange-9"
                  :false-value="'N'"
                  :true-value="'S'"
                />
              </div>
              <div
                v-if="toggle_condicoes"
                class="row justify-around items-center"
              >
                <q-toggle
                  class="metadeTela media margin1"
                  label="Operação Triangular"
                  v-model="ic_operacao_triangular"
                  color="orange-9"
                  :false-value="'N'"
                  :true-value="'S'"
                />
                <q-select
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="tipo_restricao_pedido"
                  label="Restrição de Faturamento"
                  :options="dataset_lookup_tipo_restricao_pedido"
                  option-value="cd_tipo_restricao_pedido"
                  option-label="nm_tipo_restricao_pedido"
                  :stack-label="!!tipo_restricao_pedido"
                >
                  <template v-slot:prepend>
                    <q-icon name="money_off" />
                  </template>
                </q-select>
              </div>
              <!--  -->
              <div
                v-if="toggle_condicoes"
                class="row items-center justify-around"
              >
                <q-select
                  dense
                  class="metadeTela media margin1"
                  color="orange-9"
                  v-model="vendedor"
                  label="Vendedor Interno"
                  :options="lookup_vendedor_interno"
                  option-value="cd_vendedor"
                  option-label="nm_vendedor"
                  :stack-label="!!vendedor"
                >
                  <template v-slot:prepend>
                    <q-icon name="person" />
                  </template>
                </q-select>
                <q-select
                  dense
                  class="metadeTela media margin1"
                  color="orange-9"
                  v-model="vendedor_externo"
                  label="Vendedor Externo"
                  :options="lookup_vendedor_externo"
                  option-value="cd_vendedor"
                  option-label="nm_vendedor"
                  :stack-label="!!vendedor"
                >
                  <template v-slot:prepend>
                    <q-icon name="person" />
                  </template>
                </q-select>
              </div>

              <div
                v-if="toggle_condicoes"
                class="row items-center justify-around"
              >
                <q-select
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="destinacao"
                  label="Destinação"
                  :options="dataset_lookup_destinacao"
                  option-value="cd_destinacao_produto"
                  option-label="nm_destinacao_produto"
                  :stack-label="!!destinacao"
                >
                  <template v-slot:prepend>
                    <q-icon name="map" />
                  </template>
                </q-select>

                <q-select
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="tipo_pedido"
                  label="Tipo de Pedido"
                  :options="dataset_lookup_pedido"
                  option-value="cd_tipo_pedido"
                  option-label="nm_tipo_pedido"
                  :stack-label="!!tipo_pedido"
                >
                  <template v-slot:prepend>
                    <q-icon name="format_list_bulleted" />
                  </template>
                </q-select>
              </div>

              <div
                v-if="toggle_condicoes"
                class="row items-center justify-around"
              >
                <q-select
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="tipo_local_entrega"
                  label="Local de Entrega"
                  :options="dataset_lookup_tipo_local_entrega"
                  option-value="cd_tipo_local_entrega"
                  option-label="nm_tipo_local_entrega"
                >
                  <template v-slot:prepend>
                    <q-icon name="pin_drop" />
                  </template>
                </q-select>

                <q-select
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="tipo_frete"
                  label="Frete"
                  :options="dataset_lookup_tipo_frete"
                  option-value="cd_tipo_frete"
                  option-label="nm_tipo_frete"
                >
                  <template v-slot:prepend>
                    <q-icon name="local_shipping" />
                  </template>
                </q-select>
              </div>
              <transition name="slide-fade">
                <div
                  v-if="
                    !!tipo_local_entrega &&
                    tipo_local_entrega.ic_end_tipo_local_entrega == 'S' &&
                    toggle_condicoes
                  "
                  class="row items-center justify-around"
                >
                  <q-select
                    dense
                    color="orange-9"
                    class="metadeTela media margin1"
                    v-model="tipo_endereco"
                    label="Tipo de Endereço"
                    :options="dataset_lookup_tipo_endereco"
                    option-value="cd_tipo_endereco"
                    option-label="nm_tipo_endereco"
                  >
                    <template v-slot:prepend>
                      <q-icon name="location_on" />
                    </template>
                  </q-select>
                  <q-input
                    dense
                    color="orange-9"
                    class="metadeTela media margin1"
                    v-model="tipo_endereco.cep_entrega"
                    readonly
                    autogrow
                    type="text"
                    label="CEP de Entrega"
                  >
                    <template v-slot:prepend>
                      <q-icon name="map" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    color="orange-9"
                    class="metadeTela media margin1"
                    v-model="tipo_endereco.endereco_entrega"
                    autogrow
                    readonly
                    type="text"
                    label="Endereço de Entrega"
                  >
                    <template v-slot:prepend>
                      <q-icon name="pin" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    color="orange-9"
                    class="metadeTela media margin1"
                    v-model="tipo_endereco.numero_entrega"
                    autogrow
                    readonly
                    type="text"
                    label="Número de entrega"
                  >
                    <template v-slot:prepend>
                      <q-icon name="push_pin" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    color="orange-9"
                    class="metadeTela media margin1"
                    v-model="tipo_endereco.complemento_entrega"
                    autogrow
                    readonly
                    type="text"
                    label="Complemento"
                  >
                    <template v-slot:prepend>
                      <q-icon name="info" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    color="orange-9"
                    class="duas-tela media margin1"
                    v-model="tipo_endereco.bairro_entrega"
                    autogrow
                    readonly
                    type="text"
                    label="Bairro"
                  >
                    <template v-slot:prepend>
                      <q-icon name="group" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    color="orange-9"
                    class="tres-tela media margin1"
                    v-model="tipo_endereco.estado_entrega"
                    autogrow
                    readonly
                    type="text"
                    label="Estado"
                  >
                    <template v-slot:prepend>
                      <q-icon name="public" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    color="orange-9"
                    class="tres-tela media margin1"
                    v-model="tipo_endereco.cidade_entrega"
                    autogrow
                    readonly
                    type="text"
                    label="Cidade"
                  >
                    <template v-slot:prepend>
                      <q-icon name="apartment" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    color="orange-9"
                    class="tres-tela media margin1"
                    v-model="tipo_endereco.referencia_entrega"
                    autogrow
                    readonly
                    type="text"
                    label="Ponto de referência da Entrega"
                  >
                    <template v-slot:prepend>
                      <q-icon name="near_me" />
                    </template>
                  </q-input>
                </div>
                <div
                  v-if="toggle_condicoes"
                  class="row items-center justify-around"
                >
                  <q-select
                    dense
                    color="orange-9"
                    class="metadeTela media margin1"
                    v-model="moeda"
                    label="Moeda"
                    :options="dataset_lookup_moeda"
                    option-value="cd_moeda"
                    option-label="nm_moeda"
                    :stack-label="!!moeda"
                    @input="OnMoeda()"
                  >
                    <template v-slot:prepend>
                      <q-icon name="attach_money" />
                    </template>
                  </q-select>

                  <!-- <q-select
                    dense
                    color="orange-9"
                    class="metadeTela media margin1"
                    v-model="pais"
                    label="País"
                    :options="dataset_lookup_pais"
                    option-value="cd_pais"
                    option-label="nm_pais"
                    :stack-label="!!pais"
                  >
                    <template v-slot:prepend>
                      <q-icon name="public" />
                    </template>
                  </q-select> -->
                </div>
              </transition>

              <div
                v-if="toggle_condicoes"
                class="row items-center justify-around"
              >
                <q-input
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="nm_referencia_consulta"
                  autogrow
                  type="text"
                  label="Referência do Cliente"
                >
                  <template v-slot:prepend>
                    <q-icon name="shopping_cart" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="obs"
                  autogrow
                  type="text"
                  label="Observações"
                >
                  <template v-slot:prepend>
                    <q-icon name="description" />
                  </template>
                </q-input>
              </div>
              <br />
              <q-bar
                class="bg-primary text-white"
                @click="toggleValores()"
                style="border-radius: 10px; cursor: pointer"
              >
                Valores
              </q-bar>

              <div
                v-if="toggle_valores"
                class="row items-center justify-around"
              >
                <q-select
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="pagamento"
                  label="Condição de Pagamento"
                  :options="dataset_lookup_pagamento"
                  option-value="cd_condicao_pagamento"
                  option-label="nm_condicao_pagamento"
                  :stack-label="!!pagamento"
                  @input="ValorParcela()"
                >
                  <template v-slot:prepend>
                    <q-icon name="account_balance_wallet" />
                  </template>
                </q-select>

                <q-select
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="frete_pagamento"
                  label="Pagamento do Frete"
                  :options="dataset_lookup_frete_pagamento"
                  option-value="cd_tipo_pagamento_frete"
                  option-label="nm_tipo_pagamento_frete"
                  :stack-label="!!frete_pagamento"
                >
                  <template v-slot:prepend>
                    <q-icon name="payments" />
                  </template>
                </q-select>
              </div>
              <div
                v-if="toggle_valores"
                class="row items-center justify-around"
              >
                <q-input
                  dense
                  readonly
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="vl_parcela_condicao_pgto"
                  label="Valor da Parcela"
                >
                  <template v-slot:prepend>
                    <q-icon name="attach_money" />
                  </template>
                </q-input>
                <q-select
                  dense
                  color="orange-9"
                  class="metadeTela media margin1"
                  v-model="forma_pagamento"
                  label="Forma de Pagamento"
                  :options="dataset_lookup_forma_pagamento"
                  option-value="cd_forma_pagamento"
                  option-label="nm_forma_pagamento"
                  :stack-label="!!forma_pagamento"
                >
                  <template v-slot:prepend>
                    <q-icon name="account_balance_wallet" />
                  </template>
                </q-select>
              </div>

              <div v-if="toggle_valores" class="row iems-center justify-around">
                <q-input
                  dense
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Valor Total"
                  :stack-label="!!valorTotal"
                  v-model="valorTotal"
                  readonly
                >
                  <template v-slot:prepend>
                    <q-icon name="payments" />
                  </template>
                </q-input>

                <q-input
                  dense
                  readonly
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Valor do Frete"
                  :stack-label="!!Vl_frete"
                  v-model="Vl_frete"
                >
                  <template v-slot:prepend>
                    <q-icon name="local_shipping" />
                  </template>
                  <!-- <template v-slot:control>
                      <div class="self-center full-width no-outline">
                        {{ Vl_frete }}
                      </div>
                    </template>-->
                </q-input>

                <q-input
                  dense
                  readonly
                  color="orange-9"
                  class="umTercoTela media margin1"
                  label="Produtos + Frete"
                  :stack-label="!!produto_frete"
                  v-model="produto_frete"
                >
                  <template v-slot:prepend>
                    <q-icon name="compress" />
                  </template>
                  <!--<template v-slot:control>
                      <div class="self-center full-width no-outline">
                        {{ produto_frete }}
                      </div>
                    </template>-->
                </q-input>
              </div>

              <div
                v-if="toggle_valores"
                class="row items-center justify-around"
              >
                <q-input
                  dense
                  readonly
                  color="orange-9"
                  class="metadeTela media margin1"
                  label="Total ICMS"
                  :stack-label="!!ICMS"
                  v-model="ICMS"
                >
                  <template v-slot:prepend>
                    <q-icon name="fact_check" />
                  </template>
                </q-input>
                <q-input
                  dense
                  readonly
                  color="orange-9"
                  class="metadeTela media margin1"
                  label="Produto + ICMS"
                  :stack-label="!!produto_icms"
                  v-model="produto_icms"
                >
                  <template v-slot:prepend>
                    <q-icon name="compress" />
                  </template>
                </q-input>
              </div>

              <div
                v-if="toggle_valores"
                class="row items-center justify-around"
              >
                <q-input
                  dense
                  readonly
                  color="orange-9"
                  class="metadeTela media margin1"
                  label="Total IPI"
                  :stack-label="!!IPI"
                  v-model="IPI"
                >
                  <template v-slot:prepend>
                    <q-icon name="fact_check" />
                  </template>
                </q-input>
                <q-input
                  dense
                  readonly
                  color="orange-9"
                  class="metadeTela media margin1"
                  label="Produto + IPI"
                  :stack-label="!!produto_ipi"
                  v-model="produto_ipi"
                >
                  <template v-slot:prepend>
                    <q-icon name="compress" />
                  </template>
                </q-input>
              </div>
              <br />
              <q-bar
                @click="pop_historico = !pop_historico"
                class="bg-primary text-white"
                style="border-radius: 10px"
              >
                Histórico
                <q-space />
                <q-icon :name="pop_historico ? 'north' : 'south'" />
              </q-bar>
              <transition name="slide-fade">
                <div v-if="pop_historico" class="row items-center">
                  <timeline
                    class="margin1"
                    :nm_json="this.timelineI"
                    cd_apiID="674/996"
                    :cd_consulta="1"
                    :corID="'primary'"
                    :inputID="true"
                    :cd_apiInput="'737/1119'"
                    :cd_parametroID="this.cd_proposta"
                    :cd_tipo_consultaID="this.cd_documento"
                  />
                </div>
              </transition>
            </div>
          </div>

          <br />
          <q-bar
            class="margin1 bg-primary text-white"
            style="border-radius: 10px; height: auto"
          >
            <h5
              class="metadeTela"
              style="height: auto; padding: 0; margin: 2.5px"
            >
              Itens da Proposta
            </h5>

            <h5
              class="metadeTela"
              style="height: auto; padding: 0; margin: 2.5px"
            >
              {{ `Itens: ${carrinho.length} | Total: ${valorTotal}` }}
            </h5>
          </q-bar>

          <div class="row items-center">
            <q-btn
              color="orange-9"
              rounded
              icon="add"
              class="margin1"
              label="Novo"
              @click="NovoItem()"
            />

            <div class="margin1" style="font-weight: bold">
              {{ "Tabela" }}
              <q-toggle v-model="grid_card_carrinho" color="orange-9" />{{
                "Cards"
              }}
            </div>

            <q-space />
            <q-btn
              color="orange-9"
              rounded
              flat
              class="margin1"
              icon="close"
              label="Cancelar"
              @click="onCancelaItens()"
            />
          </div>

          <q-expansion-item
            v-if="pesquisa_produto"
            expand-separator
            default-opened
            icon="shopping_cart"
            :label="`Pesquisa de itens`"
            class="shadow-1 overflow-hidden margin1"
            style="border-radius: 10px; height: auto"
            header-class="bg-orange-9 text-white item-center text-h6"
            expand-icon-class="text-white"
          >
            <div class="row items-center justify-around">
              <div
                v-if="!pesquisa_produto_servico"
                class="margin1 metadeTela"
                style="font-weight: bold"
              >
                {{ "Simples" }}
                <q-toggle
                  v-model="tipo_pesquisa_produto"
                  :false-value="'N'"
                  :true-value="'S'"
                  color="orange-9"
                />{{ "Completa" }}
              </div>
              <div class="margin1 metadeTela" style="font-weight: bold">
                {{ "Produto" }}
                <q-toggle
                  v-model="pesquisa_produto_servico"
                  color="orange-9"
                />{{ "Serviço" }}
              </div>
            </div>
            <div v-if="!pesquisa_produto_servico">
              <div
                class="row items-center justify-around"
                v-if="tipo_pesquisa_produto == 'S'"
              >
                <q-select
                  dense
                  color="orange-9"
                  class="margin1 umTercoTela media"
                  v-model="categoria"
                  :options="dataset_lookup_categoria"
                  option-value="cd_categoria_produto"
                  option-label="nm_categoria_produto"
                  label="Categoria"
                >
                  <template v-slot:prepend>
                    <q-icon name="category" />
                  </template>
                </q-select>

                <q-select
                  dense
                  color="orange-9"
                  class="margin1 umTercoTela media"
                  v-model="grupo"
                  :options="dataset_lookup_grupo"
                  option-value="cd_grupo_produto"
                  option-label="nm_grupo_produto"
                  label="Grupo"
                >
                  <template v-slot:prepend>
                    <q-icon name="inventory_2" />
                  </template>
                </q-select>

                <q-select
                  dense
                  color="orange-9"
                  class="margin1 umTercoTela media"
                  v-model="marca"
                  :options="dataset_lookup_marca"
                  option-value="cd_marca_produto"
                  option-label="nm_marca_produto"
                  label="Marca"
                >
                  <template v-slot:prepend>
                    <q-icon name="branding_watermark" />
                  </template>
                </q-select>
              </div>

              <div
                class="row items-center justify-around"
                v-if="tipo_pesquisa_produto == 'S'"
              >
                <q-input
                  dense
                  color="orange-9"
                  class="margin1 umTercoTela media"
                  v-model="cd_mascara_produto"
                  label="Máscara"
                >
                  <template v-slot:prepend>
                    <q-icon name="masks" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="margin1 umTercoTela media"
                  v-model="nm_fantasia_produto"
                  label="Fantasia"
                >
                  <template v-slot:prepend>
                    <q-icon name="face_retouching_natural" />
                  </template>
                </q-input>

                <q-input
                  dense
                  color="orange-9"
                  class="margin1 umTercoTela media"
                  v-model="nm_produto"
                  label="Produto"
                >
                  <template v-slot:prepend>
                    <q-icon name="inventory_2" />
                  </template>
                  <template v-slot:append>
                    <q-btn
                      size="sm"
                      round
                      color="orange-9"
                      icon="search"
                      @click="onVerificaPesquisaProduto()"
                    >
                      <q-tooltip
                        anchor="bottom middle"
                        self="top middle"
                        :offset="[10, 10]"
                      >
                        Pesquisar
                      </q-tooltip>
                    </q-btn>
                  </template>
                </q-input>
              </div>

              <q-input
                dense
                color="orange-9"
                class="margin1 inputProduto"
                v-if="tipo_pesquisa_produto == 'N'"
                v-model="nm_produto"
                autofocus
                label="Produto "
                debounce="1000"
                @input="onVerificaPesquisaProduto()"
              >
                <template v-slot:prepend>
                  <q-icon name="inventory_2" />
                </template>
                <template v-slot:append>
                  <q-btn
                    size="sm"
                    round
                    color="orange-9"
                    icon="search"
                    @click="onVerificaPesquisaProduto()"
                  >
                    <q-tooltip
                      anchor="bottom middle"
                      self="top middle"
                      :offset="[10, 10]"
                    >
                      Pesquisar
                    </q-tooltip>
                  </q-btn>
                </template>
              </q-input>
            </div>
            <div v-else>
              <ListagemPadrao
                cd_apiID="919/1429"
                :cd_menuID="7798"
                nm_atributo="Servico"
                @itemSelecionado="ListaCarrinho"
                :ic_mostra_titulo="false"
                :ic_mostra_grid="false"
                :ic_tipo_pesquisa="false"
                :edita_lista="editing_list"
              ></ListagemPadrao>
            </div>
            <div v-show="resultado_categoria.length > 0 && codigo">
              <q-btn
                flat
                rounded
                class="margin1"
                color="orange-9"
                label="Inserir"
                icon="input"
                @click="ListaCarrinho(linha_selecionada)"
              />
              <DxDataGrid
                class="margin1"
                id="grid"
                :ref="gridRefName"
                key-expr="cd_controle"
                :data-source="resultado_categoria"
                :columns="colunas"
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
                @focused-row-changed="onFocusedRowChanged($event)"
                @row-dbl-click="ListaCarrinho($event.data)"
              >
                <DxEditing
                  style="margin: 0; padding: 0"
                  :allow-updating="false"
                  :allow-adding="false"
                  :allow-deleting="false"
                  mode="batch"
                />

                <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
                <DxExport :enabled="true" />
                <DxPager
                  :show-page-size-selector="true"
                  :allowed-page-sizes="[10, 20, 50, 100]"
                  :show-info="true"
                />
                <DxScrolling column-rendering-mode="virtual" />
                <DxPaging :enable="true" :page-size="10" />
                <DxSearchPanel
                  :visible="true"
                  :width="300"
                  placeholder="Procurar..."
                />
              </DxDataGrid>
            </div>
            <div v-if="codigo == false">
              <p style="text-align: center">Nenhum produto encontrado!</p>
            </div>
          </q-expansion-item>

          <!---CARRINHO DE PRODUTOS E SERVIÇOS--->
          <div style="margin: 0; padding: 0" class="row">
            <div v-show="grid_card_carrinho == false">
              <DxDataGrid
                class="margin1 shadow-1 grid-padrao"
                id="grid_carrinho"
                :ref="gridRefNameCarrinho"
                key-expr="cd_controle"
                :data-source="carrinho"
                :columns="colunas_carrinho"
                :show-borders="true"
                :selection="{ mode: 'single' }"
                :focused-row-enabled="true"
                :column-hiding-enabled="false"
                :column-auto-width="true"
                :remote-operations="false"
                :word-wrap-enabled="false"
                :allow-column-reordering="false"
                :allow-column-resizing="true"
                :row-alternation-enabled="true"
                :repaint-changes-only="true"
                :autoNavigateToFocusedRow="true"
                :focused-row-index="0"
                :cacheEnable="false"
                @cell-prepared="onCellPrepared"
                @row-updated="CalculaValores"
                @focused-cell-Changing="attQtd($event)"
                @focused-row-changed="onFocusedRowChangedCarrinho($event)"
              >
                <DxEditing
                  :allow-updating="true"
                  :allow-adding="false"
                  :allow-deleting="true"
                  :select-text-on-edit-start="true"
                  mode="batch"
                />
                <DxGroupPanel :visible="true" empty-panel-text="Agrupar..." />
                <DxExport :enabled="true" />
                <DxPager
                  :show-page-size-selector="true"
                  :allowed-page-sizes="[10, 20, 50, 100]"
                  :show-info="true"
                />
                <DxScrolling column-rendering-mode="virtual" />
                <DxPaging :enable="true" :page-size="10" />
                <DxSearchPanel
                  :visible="true"
                  :width="300"
                  placeholder="Procurar..."
                />
              </DxDataGrid>
            </div>
            <div v-show="grid_card_carrinho">
              <div
                v-for="(n, index) in this.carrinho.length"
                :key="index"
                class="margin1 shadow-2 carrinho borda-bloco"
              >
                <div class="margin5 row text-bold items-center">
                  <div style="width: 90%">
                    {{ carrinho[index].Produto }}
                  </div>
                  <div style="width: 7%">
                    <q-btn
                      style="float: right"
                      round
                      flat
                      size="sm"
                      color="orange-9"
                      icon="delete"
                      @click="DeletaItem(carrinho[index], index)"
                    >
                      <q-tooltip
                        anchor="bottom middle"
                        self="top middle"
                        :offset="[10, 10]"
                      >
                        Deletar
                      </q-tooltip>
                    </q-btn>
                  </div>
                </div>
                <q-separator />
                <div class="margin5 row items-center">
                  {{ "Marca: " }} {{ carrinho[index].Marca }}
                </div>
                <div class="margin5 row items-center">
                  {{ "Descrição: " }} {{ carrinho[index].Descrição }}
                </div>
                <div class="margin5 row items-center">
                  {{ "Un. Medida: " }} {{ carrinho[index].Un }}
                </div>
                <div class="margin5 row items-center">
                  <q-input
                    borderless
                    color="orange-9"
                    label="Valor"
                    :prefix="'R$'"
                    type="number"
                    v-model="carrinho[index].Valor"
                    @input="SomaItens(carrinho[index])"
                  />
                </div>

                <div class="row items-center" style="justify-content: center">
                  <q-btn
                    size="sm"
                    round
                    color="negative"
                    icon="remove"
                    style="margin: 0 5px"
                    @click="Menos(carrinho[index], index)"
                  />
                  <q-input
                    borderless
                    color="orange-9"
                    class="quantidade"
                    type="number"
                    :min="1"
                    v-model="carrinho[index].Quantidade"
                    @input="verificaQuantidade(carrinho[index])"
                    label="Quantidade"
                  />
                  <q-btn
                    size="sm"
                    round
                    color="positive"
                    icon="add"
                    style="margin: 0 5px"
                    @click="Mais(carrinho[index], index)"
                  />
                </div>
                <div
                  class="row items-center text-bold"
                  style="justify-content: center"
                >
                  {{ "Total: "
                  }}{{
                    (
                      Number(carrinho[index].Quantidade) *
                      Number(carrinho[index].Valor)
                    ).toLocaleString("pt-br", {
                      style: "currency",
                      currency: "BRL",
                    })
                  }}
                </div>
              </div>
            </div>
          </div>

          <q-card-actions class="text-orange-9">
            <q-page-sticky position="bottom-right" :offset="[18, 18]">
              <q-fab
                style="padding: 76%"
                color="orange-9"
                icon="keyboard_return"
                direction="left"
              >
                <q-fab-action
                  color="orange-9"
                  icon="close"
                  label="Cancelar"
                  @click="limpaTudo()"
                >
                  <q-tooltip> Cancelar </q-tooltip>
                </q-fab-action>

                <q-fab-action
                  color="orange-9"
                  icon="check"
                  label="Gravar"
                  @click="onSalvarItens()"
                >
                  <q-tooltip> Salvar Proposta </q-tooltip>
                </q-fab-action>

                <q-fab-action
                  color="orange-9"
                  icon="print"
                  label="Imprimir"
                  @click="OnImpressao()"
                >
                  <q-tooltip> Imprimir Proposta </q-tooltip>
                </q-fab-action>

                <q-fab-action
                  color="orange-9"
                  icon="cancel"
                  label="Declinar"
                  @click="popup_declinar = true"
                >
                  <q-tooltip> Declinar Proposta </q-tooltip>
                </q-fab-action>

                <q-fab-action
                  color="orange-9"
                  icon="verified"
                  label="Fechar"
                  @click="FechaProposta()"
                >
                  <q-tooltip> Fechar Proposta </q-tooltip>
                </q-fab-action>

                <q-fab-action
                  color="orange-9"
                  icon="email"
                  label="Enviar"
                  @click="EnviaProposta()"
                >
                  <q-tooltip> Enviar Proposta </q-tooltip>
                </q-fab-action>
              </q-fab>
            </q-page-sticky>
            <div v-if="cd_proposta > 0" class="margin5">
              <q-btn
                rounded
                color="orange-9"
                class="margin5"
                icon="email"
                label="Enviar"
                :loading="load_email"
                @click="EnviaProposta()"
              >
                <q-tooltip> Enviar Proposta </q-tooltip>
              </q-btn>

              <q-btn
                rounded
                color="orange-9"
                class="margin5"
                icon="verified"
                label="Fechar"
                @click="FechaProposta()"
              >
                <q-tooltip> Fechar Proposta </q-tooltip>
              </q-btn>

              <q-btn
                rounded
                color="orange-9"
                class="margin5"
                icon="cancel"
                label="Declinar"
                @click="popup_declinar = true"
              >
                <q-tooltip> Declinar </q-tooltip>
              </q-btn>

              <q-btn
                rounded
                color="orange-9"
                class="margin5"
                label="Imprimir"
                icon="print"
                :loading="load_impressao"
                @click="OnImpressao()"
              >
                <q-tooltip> Imprimir proposta </q-tooltip>
              </q-btn>
              <q-btn
                rounded
                color="orange-9"
                class="margin5"
                label="Documentos"
                icon="upload"
                :loading="show_documentos"
                @click="show_documentos = true"
              >
                <q-tooltip> Salvar arquivos </q-tooltip>
              </q-btn>
            </div>

            <q-btn
              color="orange-9"
              rounded
              icon="check"
              label="Gravar"
              :loading="load_gravar"
              @click="onSalvarItens()"
            >
              <q-tooltip> Salvar Proposta </q-tooltip>
            </q-btn>
            <q-space />
            <q-btn
              flat
              rounded
              label="Cancelar"
              icon="close"
              @click="limpaTudo()"
              v-close-popup
            >
              <q-tooltip> Cancelar </q-tooltip>
            </q-btn>
          </q-card-actions>
        </q-expansion-item>
      </div>
    </q-layout>
    <!---ENVIAR PROPOSTA----------------------------------->
    <q-dialog v-model="popup_enviar">
      <q-card style="width: 700px; max-width: 80vw; border-radius: 20px">
        <q-expansion-item
          class="overflow-hidden"
          style="border-radius: 20px; height: auto; margin: 0"
          icon="mail"
          label="Envio da Proposta via e-mail"
          default-opened
          header-class="bg-orange-9 text-white items-center text-h6"
          expand-icon-class="text-white"
        >
          <q-card-section class="q-py-none">
            <div class="text-bold text-center margin1">
              {{ `Proposta ${cd_proposta} enviada por E-mail` }}
            </div>
          </q-card-section>
          <q-card-section class="q-py-none">
            <div class="text-bold text-center margin1">
              {{ `Codigo da proposta: ${cd_crypto_proposta}` }}
            </div>
          </q-card-section>
          <q-card-section class="q-py-none">
            <div class="text-left margin1">
              {{
                `*Informe esse código para que o cliente possa visualizar a proposta.`
              }}
            </div>
          </q-card-section>

          <q-card-actions align="right">
            <q-btn flat label="Fechar" rounded color="orange-9" v-close-popup />
          </q-card-actions>
        </q-expansion-item>
      </q-card>
    </q-dialog>

    <!-----------------------------------FECHAR PROPOSTA----------------------------------->
    <q-dialog
      v-model="popup_fechar"
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="text-white bg-primary">
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-white text-primary"
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
            <q-tooltip v-if="!maximizedToggle" class="bg-white text-primary"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-white text-primary">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <!-- <q-expansion-item
          class="overflow-hidden "
          style="border-radius: 20px; height:auto;margin:0"
          icon="attach_money"
          label="Fechamento da Proposta"
          default-opened
          header-class="bg-orange-9 text-white item-center text-h6"
          expand-icon-class="text-white"
        >-->

        <!-- Componente de Fechamento de Proposta (Consulta) -->
        <FechamentoProposta
          :cd_consulta="cd_proposta"
          @FechaProposta="PropostaFechada()"
          @FechaPopUp="FechaConsulta()"
        />
        <!--</q-expansion-item>  -->
      </q-card>
    </q-dialog>
    <!--------------------------------------DECLINAR PROPOSTA----------------------------------->
    <q-dialog
      v-if="cd_proposta != 0"
      v-model="popup_declinar"
      transition-show="slide-up"
      transition-hide="slide-down"
      full-width
    >
      <q-card style="border-radius: 20px">
        <parcial
          @FechaPopup="FechaPopupDeclina()"
          :ic_perda="true"
          :cd_movimento="cd_proposta"
        />
      </q-card>
    </q-dialog>
    <!------------------------------------------------->
    <q-dialog v-model="ic_impressao" persistent>
      <q-card style="width: 27%; padding: 0">
        <div class="row items-center" style="margin: 0.7vw">
          <div class="text-bold col items-center">
            {{ `Proposta - ${cd_proposta}` }}
          </div>
          <div class="col-1">
            <q-btn
              style="float: right"
              flat
              round
              icon="close"
              v-close-popup
              size="sm"
            />
          </div>
        </div>
        <div
          class="row items-center self-center justify-center"
          style="margin: 0.7vw"
        ></div>
      </q-card>
    </q-dialog>

    <!---Confirma Exclusão de produto----------------------------------->
    <q-dialog v-model="confirma_exclusao" persistent>
      <q-card>
        <q-card-section>
          <div class="text-h6">Confirma exclusão</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <div>
            <b>{{
              `Deseja realmente excluir ${produto_excluir.Produto} do seu carrinho ?`
            }}</b>
          </div>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            flat
            rounded
            label="Confirmar"
            color="orange-9"
            @click="ExcluiItem()"
            v-close-popup
          ></q-btn>
          <q-btn
            flat
            rounded
            label="Cancelar"
            color="orange-9"
            v-close-popup
          ></q-btn>
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!------------------------------------------------->

    <!---CARREGANDO----------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando :corID="'orange-9'"></carregando>
    </q-dialog>

    <!----POPUP CONFIRMA PESQUISA DE PRODUTO SEM FILTRO---------------------------------------------------------->
    <q-dialog v-model="popup_pesquisa_filtro" style="max-width: 40%">
      <q-card style="max-width: 40%">
        <q-card-section>
          <div class="text-h6">
            <b>Deseja</b> realmente pesquisar todos os produtos ?
          </div>
          <q-separator class="margin1" />
          <div class="text-h7"><b>* Essa</b> pesquisa pode demorar!</div>
          <br />
          <q-item-section side class="margin1">
            <q-btn
              rounded
              flat
              icon="check"
              color="positive"
              @click="onPesquisaProduto"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                <strong>Confirmar</strong>
              </q-tooltip>
            </q-btn>
            <q-btn rounded flat icon="close" color="negative" v-close-popup>
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                <strong>Cancelar</strong>
              </q-tooltip>
            </q-btn>
          </q-item-section>
        </q-card-section>
      </q-card>
    </q-dialog>
    <!----Documentos (Upload e Download)---------------------------------------------------------->
    <q-dialog v-model="show_documentos" persistent maximized>
      <q-card>
        <q-card-section>
          <documentosCRUD
            :documento_json="this.consulta_up"
            nm_origem="Propostas"
            :cd_documentoID="cd_proposta"
            :Fantasia="Fantasia"
          ></documentosCRUD>
        </q-card-section>
        <!-- <q-card-section>
          <div class="text-h6">
            <b>Documentos</b> vinculados a proposta
            {{ `- ${cd_proposta} - ${Fantasia}` }}
          </div>
        </q-card-section>
        <q-card-section>
          <q-item-section class="margin1 centralize" style="margin: 5%;">
            <q-file
              rounded
              standout
              bg-color="primary"
              v-model="documento_upload"
              label="Documento"
            >
              <template v-slot:prepend> <q-icon name="attach_file" /> </template
            ></q-file>
          </q-item-section>
        </q-card-section>
        <q-card-actions align="right">
          <transition name="slide-fade">
            <q-btn
              v-if="linha_doc"
              rounded
              class="margin1"
              icon="download"
              color="primary"
              label="Baixar"
              :loading="uploading_load"
              @click="onDownloadDoc()"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                <strong>Baixar documento</strong>
              </q-tooltip>
            </q-btn>
          </transition>
          <transition name="slide-fade">
            <q-btn
              v-if="linha_doc"
              rounded
              class="margin1"
              icon="delete"
              color="negative"
              label="Excluir"
              :loading="uploading_load"
              @click="deletaDoc()"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                <strong>Excluir documento</strong>
              </q-tooltip>
            </q-btn>
          </transition>
          <q-btn
            rounded
            class="margin1"
            icon="check"
            color="positive"
            label="Confirmar"
            :loading="uploading_load"
            @click="onUploadDoc()"
          >
            <q-tooltip
              anchor="bottom middle"
              self="top middle"
              :offset="[10, 10]"
            >
              <strong>Confirmar</strong>
            </q-tooltip>
          </q-btn>
          <q-btn
            rounded
            icon="close"
            color="negative"
            class="margin1"
            label="Fechar"
            v-close-popup
          >
            <q-tooltip
              anchor="bottom middle"
              self="top middle"
              :offset="[10, 10]"
            >
              <strong>Fechar</strong>
            </q-tooltip>
          </q-btn>
        </q-card-actions>
        <q-card-section>
          <grid
            class="margin1"
            :cd_menuID="7803"
            :cd_apiID="562"
            :att_json="att_grid_doc"
            :cd_parametroID="0"
            @linha="linhaDoc($event)"
            :nm_json="{
              cd_parametro: 20,
              cd_consulta: this.cd_proposta,
            }"
            :masterDetail="false"
          />
        </q-card-section> -->
      </q-card>
    </q-dialog>
  </div>
</template>
<script>
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import Menu from "../http/menu";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import Lookup from "../http/lookup";
import formataData from "../http/formataData";
import funcao from "../http/funcoes-padroes";
import Procedimento from "../http/procedimento";
import axios from "axios";

import {
  DxDataGrid,
  DxPaging,
  DxScrolling,
  DxSearchPanel,
  DxEditing,
  DxGroupPanel,
  DxExport,
  DxPager,
} from "devextreme-vue/data-grid";

import grid from "../views/grid.vue";

export default {
  props: {
    consulta_up: {
      type: Object,
      default() {
        return {};
      },
    },
    kanban: { type: Boolean, default: false },
  },

  watch: {
    async popup_declinar() {
      if (this.popup_declinar == false) {
        this.EditaProposta();
      }
    },
    async Expansion() {
      if (this.Expansion == false) {
        this.Expansion = true;
      }
    },
    async grid_card_carrinho() {
      await this.onSalvarItens();
    },
    cd_proposta(a) {
      if (a == 0) {
        this.readyOnly_cliente = false;
      } else {
        this.readyOnly_cliente = true;
      }
    },
  },

  components: {
    DxDataGrid,
    DxSearchPanel,
    DxEditing,
    DxGroupPanel,
    DxExport,
    DxPager,
    DxPaging,
    DxScrolling,
    parcial: () => import("../components/fechamentoParcial.vue"),
    carregando: () => import("../components/carregando.vue"),
    documentosCRUD: () => import("../components/documentosCRUD.vue"),
    relatoriop: () => import("../components/relatorio-padrao.vue"),
    FechamentoProposta: () => import("../views/FechamentoProposta.vue"),
    ListagemPadrao: () => import("../views/listagem-padrao.vue"),
    timeline: () => import("../views/timeline.vue"),
    cliente: () => import("../views/cliente.vue"),
    grid: () => import("../views/grid.vue"),
  },

  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_modulo: localStorage.cd_modulo,
      proposta_consulta: [],
      tituloMenu: "",
      gridRefName: "grid",
      gridRefNameCarrinho: "grid_carrinho",
      linha_selecionada: [],
      cliente_selecionado: [],
      linha_anterior: Object,
      EditFiltroProposta: false,
      cd_crypto_proposta: null,
      readyOnly_cliente: false,
      api: "562/781", // Procedimento 1439 - pr_egisnet_elabora_proposta
      nm_json: {}, // JSON Enviado para a API
      timelineI: {
        ic_parametro: 2,
        cd_form: 1, //oportunidade
        cd_movimento: 0,
        cd_empresa: localStorage.cd_empresa,
        dt_inicial: "",
        dt_final: "",
        cd_usuario: localStorage.cd_usuario,
      },
      vl_parcela_condicao_pgto: [],
      pesquisa_produto_servico: false,
      grid_card_carrinho: false,
      confirma_exclusao: false,
      colunas: [],
      colunas_carrinho: [],
      produto_excluir: [],
      indice_excluir: 0,
      cd_vendedor: 0,
      maximizedToggle: true,
      VerificaDeclinio: false,
      hoje: "",
      cliente_popup: false,
      popup_proposta: false,
      popup_declinar: false,
      popup_fechar: false,
      popup_enviar: false,
      ic_impressao: false,
      tipo_pesquisa_produto: "N",
      codigo: null,
      load: false,
      cd_proposta: "",
      cd_documento: 0,
      ds_declinio: "",
      Fantasia: "",
      cd_mascara_produto: "",
      nm_fantasia_produto: "",
      nm_produto: "",
      ic_fechamento_total: "N",
      ic_operacao_triangular: "N",
      ic_gera_email_confirmacao: "N",
      dataset_lookup_tipo_restricao_pedido: [],
      tipo_restricao_pedido: "",
      ////Serviços///////////////////
      editing_list: {
        mode: "batch",
        allowUpdating: true,
        allowAdding: false,
        allowDeleting: true,
        colunas: [
          "nm_servico",
          "qt_servico",
          "vl_servico",
          "ds_servico",
          "pc_iss_servico",
          "pc_irrf_servico",
          "pc_comissao_servico",
        ],
      },
      ///////////////////////
      lookup_vendedor_interno: [],
      lookup_vendedor_externo: [],
      vendedor_externo: "",
      dataset_lookup_forma_pagamento: [],
      forma_pagamento: "",
      dataset_lookup_pais: [],
      pais: "",
      dataset_lookup_moeda: [],
      moeda: "",
      dataset_lookup_pagamento: [],
      pagamento: "",
      dataset_lookup_pedido: [],
      tipo_pedido: "",
      dataset_lookup_categoria: [],
      ShowRelatorio: false,
      show_documentos: false,
      documento_upload: [],
      linha_doc: "",
      att_grid_doc: false,
      uploading_load: false,
      categoria: "",
      dataset_lookup_grupo: [],
      grupo: "",
      dataset_lookup_marca: [],
      marca: "",
      dados_lookup_cliente: [],
      dataset_lookup_cliente: [],
      cliente: "",
      nm_cliente: "",
      dataset_lookup_vendedor: [],
      vendedor: "",
      dataset_lookup_transportadora: [],
      transportadora: "",
      dataset_lookup_tipo_entrega: [],
      tipo_entrega: "",
      dataset_lookup_destinacao: [],
      destinacao: "",
      dataset_lookup_tipo_local_entrega: [],
      Expansion: true,
      tipo_local_entrega: "",
      dataset_lookup_tipo_endereco: [],
      tipo_endereco: "",
      dataset_lookup_tipo_frete: [],
      tipo_frete: "",
      dataset_lookup_frete_pagamento: [],
      frete_pagamento: "",
      dataset_lookup_um: [],
      um: "",
      cd_cliente: 0,
      resultado_contato: [],
      filter_cliente: "",
      popup_contato: false,
      selecao: false,
      Razao_Social: "",
      Telefone_Empresa: "",
      CNPJ: "",
      nm_dominio_cliente: "",
      Tipo_Pessoa: "",
      Ramo_Atividade: "",
      Status_Cliente: "",
      Insc_Estadual: "",
      Insc_Municipal: "",
      CEP: "",
      Endereco: "",
      Numero: "",
      Complemento: "",
      Bairro: "",
      Cidade: "",
      Estado: "",
      envio_proposta: [],
      envio_consulta: [],
      obs: "",
      nm_referencia_consulta: "",
      loading: false,
      load_contato: false,
      load_email: false,
      load_impressao: false,
      load_gravar: false,
      toggle_condicoes: false,
      toggle_valores: false,
      GridCli: false,
      nextPage: 2,
      total_banco: "",
      selecao_contato: false,
      contato_selecionado: [],
      resultado_pesquisa_cliente: [],
      coluna_cliente: [],
      Email: "",
      pesquisa_produto: false,
      resultado_categoria: [],
      produtos: [],
      total: {},
      carrinho: [],
      popup_pesquisa_filtro: false,
      pop_historico: true,
      valorTotal: 0,
      IPI: "0",
      ICMS: "0",
      Vl_frete: "0",
      produto_frete: "0",
      produto_icms: "0",
      produto_ipi: "0",
      colunaGrid: [],
      totalGrid: {},
      gridProposta: [],
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    if (
      this.consulta_up.cd_movimento == 0 ||
      this.consulta_up.cd_movimento == undefined
    ) {
      this.kanban = false;
    } else {
      this.kanban = true;
    }
    let menu_grid = await Menu.montarMenu(this.cd_empresa, 7365, 700);
    this.colunaGrid = JSON.parse(JSON.parse(JSON.stringify(menu_grid.coluna)));

    this.totalGrid = JSON.parse(
      JSON.parse(JSON.stringify(menu_grid.coluna_total))
    );

    this.gridProposta = await Procedimento.montarProcedimento(
      this.cd_empresa,
      0,
      menu_grid.nm_identificacao_api,
      menu_grid.nm_api_parametro
    );

    this.cd_vendedor = await funcao.buscaVendedor(this.cd_usuario);
    try {
      this.load = true;
      let dados_lookup_um = await Lookup.montarSelect(this.cd_empresa, 138);
      this.dataset_lookup_um = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_um.dataset))
      );
      //Cliente
      if (this.dataset_lookup_cliente.length == 0) {
        this.dados_lookup_cliente = await Lookup.montarSelect(
          this.cd_empresa,
          93
        );
        this.dataset_lookup_cliente = JSON.parse(
          JSON.parse(JSON.stringify(this.dados_lookup_cliente.dataset))
        );
      }

      if (this.consulta_up.cd_movimento > 0) {
        await this.EditaProposta();
      }
      var PegaData = new Date();
      var dia = String(PegaData.getDate()).padStart(2, "0");
      var mes = String(PegaData.getMonth() + 1).padStart(2, "0");
      var ano = PegaData.getFullYear();
      this.hoje = `${dia}/${mes}/${ano}`;
      this.load = false;
    } catch {
      this.load = false;
    }
    await this.carregaCarrinho();
  },

  async mounted() {
    this.tituloMenu = "Elaboração da Proposta";
    await this.grid_carrinho.saveEditData();
  },

  computed: {
    grid() {
      return this.$refs[this.gridRefName].instance;
    },
    grid_carrinho() {
      return this.$refs[this.gridRefNameCarrinho].instance;
    },
  },

  methods: {
    async toggleCondicoes() {
      this.toggle_condicoes = !this.toggle_condicoes;
      if (this.toggle_condicoes) {
        //Tipo Restrição Pedido
        if (this.dataset_lookup_tipo_restricao_pedido.length == 0) {
          const dados_lookup_tipo_restricao_pedido = await Lookup.montarSelect(
            this.cd_empresa,
            273
          );
          this.dataset_lookup_tipo_restricao_pedido = JSON.parse(
            JSON.parse(
              JSON.stringify(dados_lookup_tipo_restricao_pedido.dataset)
            )
          );
          this.tipo_restricao_pedido = {
            cd_tipo_restricao_pedido:
              this.proposta_consulta[0].cd_tipo_restricao_pedido,
            nm_tipo_restricao_pedido:
              this.proposta_consulta[0].nm_tipo_restricao_pedido,
          };
        }
        //Moeda
        if (this.dataset_lookup_moeda.length == 0) {
          const dados_lookup_moeda = await Lookup.montarSelect(
            this.cd_empresa,
            175
          );
          this.dataset_lookup_moeda = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_moeda.dataset))
          );
        }
        //Pais
        // if(this.dataset_lookup_pais.length == 0){
        //   const dados_lookup_pais = await Lookup.montarSelect(this.cd_empresa, 492);
        //   this.dataset_lookup_pais = JSON.parse(
        //     JSON.parse(JSON.stringify(dados_lookup_pais.dataset)),
        //   );
        // }
        //Pedido
        if (this.dataset_lookup_pedido.length == 0) {
          const dados_lookup_pedido = await Lookup.montarSelect(
            this.cd_empresa,
            202
          );
          this.dataset_lookup_pedido = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_pedido.dataset))
          );
          this.tipo_pedido = {
            cd_tipo_pedido: this.proposta_consulta[0].cd_tipo_pedido,
            nm_tipo_pedido: this.proposta_consulta[0].nm_tipo_pedido,
          };
        }
        //Vendedor
        if (this.dataset_lookup_vendedor.length == 0) {
          let dados_lookup_vendedor = await Lookup.montarSelect(
            this.cd_empresa,
            141
          );
          this.dataset_lookup_vendedor = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_vendedor.dataset))
          );
          this.lookup_vendedor_interno = this.dataset_lookup_vendedor.filter(
            (interno) => {
              return interno.cd_tipo_vendedor == 1;
            }
          );

          this.lookup_vendedor_externo = this.dataset_lookup_vendedor.filter(
            (externo) => {
              return externo.cd_tipo_vendedor == 2;
            }
          );
          this.vendedor = {
            cd_vendedor:
              this.proposta_consulta[0].cd_vendedor == null
                ? this.cd_vendedor.cd_vendedor
                : this.proposta_consulta[0].cd_vendedor,
            nm_vendedor:
              this.proposta_consulta[0].nm_vendedor == null
                ? this.cd_vendedor.nm_vendedor
                : this.proposta_consulta[0].nm_vendedor,
          };

          this.vendedor_externo = {
            cd_vendedor: this.proposta_consulta[0].cd_vendedor_externo,
            nm_vendedor: this.proposta_consulta[0].nm_vendedor_externo,
          };
        }
        //Transportadora
        if (this.dataset_lookup_transportadora.length == 0) {
          let dados_lookup_transportadora = await Lookup.montarSelect(
            this.cd_empresa,
            297
          );
          this.dataset_lookup_transportadora = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_transportadora.dataset))
          );
          this.transportadora = {
            cd_transportadora: this.proposta_consulta[0].cd_transportadora,
            nm_transportadora: this.proposta_consulta[0].nm_transportadora,
          };
        }
        //Tipo de Entrega
        if (this.dataset_lookup_tipo_entrega.length == 0) {
          let dados_lookup_tipo_entrega = await Lookup.montarSelect(
            this.cd_empresa,
            397
          );
          this.dataset_lookup_tipo_entrega = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_tipo_entrega.dataset))
          );
          if (this.proposta_consulta[0].cd_tipo_entrega_produto != undefined) {
            this.tipo_entrega = this.dataset_lookup_tipo_entrega.find(
              (elem) =>
                elem.cd_tipo_entrega_produto ==
                this.proposta_consulta[0].cd_tipo_entrega_produto
            );
          }
          await this.onTipoEntrega();
        }
        //Destinação
        if (this.dataset_lookup_destinacao.length == 0) {
          let dados_lookup_destinacao = await Lookup.montarSelect(
            this.cd_empresa,
            227
          );
          this.dataset_lookup_destinacao = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_destinacao.dataset))
          );
          this.destinacao = {
            cd_destinacao_produto:
              this.proposta_consulta[0].cd_destinacao_produto,
            nm_destinacao_produto:
              this.proposta_consulta[0].nm_destinacao_produto,
          };
        }
        //local Entrega
        if (this.dataset_lookup_tipo_local_entrega.length == 0) {
          let dados_lookup_tipo_local_entrega = await Lookup.montarSelect(
            this.cd_empresa,
            250 //Tipo_Local_Entrega
          );
          this.dataset_lookup_tipo_local_entrega = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_tipo_local_entrega.dataset))
          );
          if (this.proposta_consulta[0].cd_tipo_local_entrega != undefined) {
            this.tipo_local_entrega =
              this.dataset_lookup_tipo_local_entrega.find(
                (elem) =>
                  elem.cd_tipo_local_entrega ==
                  this.proposta_consulta[0].cd_tipo_local_entrega
              );
          }
          if (!this.tipo_local_entrega.cd_tipo_local_entrega) {
            this.tipo_local_entrega = {
              cd_tipo_local_entrega:
                this.proposta_consulta[0].cd_tipo_local_entrega,
              nm_tipo_local_entrega:
                this.proposta_consulta[0].nm_tipo_local_entrega,
              ic_end_tipo_local_entrega:
                this.proposta_consulta[0].ic_end_tipo_local_entrega == undefined
                  ? ""
                  : this.proposta_consulta[0].ic_end_tipo_local_entrega,
            };
          }
        }
        //Tipo Frete
        if (this.dataset_lookup_tipo_frete.length == 0) {
          let dados_lookup_tipo_frete = await Lookup.montarSelect(
            this.cd_empresa,
            200
          );
          this.dataset_lookup_tipo_frete = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_tipo_frete.dataset))
          );
          this.tipo_frete = {
            cd_tipo_frete: this.proposta_consulta[0].cd_tipo_frete,
            nm_tipo_frete: this.proposta_consulta[0].nm_tipo_frete,
          };
        }
      }
      this.nm_referencia_consulta =
        this.proposta_consulta[0].nm_referencia_consulta;
      this.obs = this.proposta_consulta[0].ds_observacao_consulta;
      (this.ic_operacao_triangular = this.proposta_consulta[0]
        .ic_operacao_triangular
        ? this.proposta_consulta[0].ic_operacao_triangular
        : "N"),
        (this.ic_fechamento_total = this.proposta_consulta[0]
          .ic_fechamento_total
          ? this.proposta_consulta[0].ic_fechamento_total
          : "N");
    },
    async toggleValores() {
      this.toggle_valores = !this.toggle_valores;
      if (this.toggle_valores) {
        //Forma Pagamento
        if (this.dataset_lookup_forma_pagamento.length == 0) {
          const dados_lookup_forma_pagamento = await Lookup.montarSelect(
            this.cd_empresa,
            2774
          );
          this.dataset_lookup_forma_pagamento = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_forma_pagamento.dataset))
          );
          this.forma_pagamento = {
            cd_forma_pagamento: this.proposta_consulta[0].cd_forma_pagamento,
            nm_forma_pagamento: this.proposta_consulta[0].nm_forma_pagamento,
          };
        }
        //Pagamento
        if (this.dataset_lookup_pagamento.length == 0) {
          const dados_lookup_pagamento = await Lookup.montarSelect(
            this.cd_empresa,
            308
          );
          this.dataset_lookup_pagamento = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_pagamento.dataset))
          );
          this.pagamento = {
            cd_condicao_pagamento:
              this.proposta_consulta[0].cd_condicao_pagamento,
            nm_condicao_pagamento:
              this.proposta_consulta[0].nm_condicao_pagamento,
            qt_parcela_condicao_pgto:
              this.proposta_consulta[0].qt_parcela_condicao_pgto,
          };
        }
        //Frete Pagamento
        if (this.dataset_lookup_frete_pagamento.length == 0) {
          let dados_lookup_frete_pagamento = await Lookup.montarSelect(
            this.cd_empresa,
            242
          );
          this.dataset_lookup_frete_pagamento = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_frete_pagamento.dataset))
          );
        }
        this.frete_pagamento = {
          cd_tipo_pagamento_frete:
            this.proposta_consulta[0].cd_tipo_pagamento_frete,
          nm_tipo_pagamento_frete:
            this.proposta_consulta[0].nm_tipo_pagamento_frete,
        };
      }
    },
    async NovoItem() {
      this.pesquisa_produto = !this.pesquisa_produto;

      let dados_lookup_config_proposta = await Lookup.montarSelect(
        this.cd_empresa,
        5442
      );

      let dataset_lookup_config_proposta;
      if (dados_lookup_config_proposta.dataset) {
        dataset_lookup_config_proposta = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_config_proposta.dataset))
        );
      }

      if (dataset_lookup_config_proposta) {
        this.tipo_pesquisa_produto =
          dataset_lookup_config_proposta[0].ic_pesquisa_produto;
      }
      //Categoria
      const dados_lookup_categoria = await Lookup.montarSelect(
        this.cd_empresa,
        261
      );
      this.dataset_lookup_categoria = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_categoria.dataset))
      );
      //Grupo
      const dados_lookup_grupo = await Lookup.montarSelect(
        this.cd_empresa,
        159
      );
      this.dataset_lookup_grupo = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_grupo.dataset))
      );
      //Marca
      const dados_lookup_marca = await Lookup.montarSelect(
        this.cd_empresa,
        2406
      );
      this.dataset_lookup_marca = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_marca.dataset))
      );
    },
    async onCellPrepared(e) {
      //Verifica o type de inicialização da célula.
      if (e.rowType == "header") {
        return;
      }
      //Caso seja uma célula de valor e a data de perda for preenchida a linha é pintada de vermelho.
      if (!!e.data.dt_perda_consulta_itens != false && e.rowType == "data") {
        e.cellElement.style.color = "red";
      }
    },
    async PropostaFechada() {
      this.$emit("click");
    },
    async EnviaProposta() {
      if (this.Email == "") {
        notify("Cliente sem E-mail cadastrado");
        return;
      }
      this.load_email = true;
      try {
        let chave_proposta = `${this.cd_empresa}/${this.cd_proposta}`;
        this.cd_crypto_proposta = await funcao.criptografa(chave_proposta);
        let json = {
          cd_parametro: 0,
          cd_tipo_email: 248,
          cd_etapa: 43,
          cd_documento: this.cd_proposta,
          cd_modulo: this.cd_modulo,
          cd_usuario: this.cd_usuario,
          nm_chave: this.cd_crypto_proposta,
        };
        await funcao.EnviaEmail(json);
        this.popup_enviar = true;
        this.load_email = false;
      } catch {
        this.load_email = false;
        notify("Não foi possível enviar E-mail");
      }
    },
    async NovaProposta() {
      this.EditFiltroProposta = true;
      this.popup_proposta = true;
      this.limpaTudo();
      await this.carregaCarrinho();
    },

    onTipoEntrega() {
      this.tipo_entrega.cd_tipo_entrega_produto == 1
        ? (this.ic_fechamento_total = "S")
        : (this.ic_fechamento_total = "N");
    },

    async OnImpressao() {
      try {
        this.load = true;
        this.load_impressao = true;
        this.ShowRelatorio = true;
        await this.$refs.relatoriop.chamaRelatorio(this.linha_selecionada);
        this.load_impressao = false;
        this.load = false;
        this.ShowRelatorio = false;
      } catch {
        this.load_impressao = false;
        this.load = false;
        this.ShowRelatorio = false;
      }
    },

    linhaDoc(e) {
      this.linha_doc = e;
    },

    async deletaDoc() {
      // const options = {
      //   method: "GET",
      //   url: `https://egis-store.com.br/api/removeDoc/${this.linha_doc.nm_caminho_documento}`,
      // };
      // axios(options)
      //   .then((response) => {
      //     notify(response.data);
      //   })
      //   .catch((error) => {
      //     console.error("Erro:", error);
      //   });
      try {
        let json_exclui_doc = {
          cd_parametro: 22,
          cd_consulta: this.cd_proposta,
          cd_consulta_documento: this.linha_doc.cd_consulta_documento,
          cd_usuario: this.cd_usuario,
        };
        let [doc_excluido] = await Incluir.incluirRegistro(
          this.api,
          json_exclui_doc
        );
        notify(doc_excluido.Msg);
        this.documento_upload = [];
        this.att_grid_doc = !this.att_grid_doc; //Atualiza a grid de documento
      } catch (error) {
        notify("Não foi possível excluir o documento!");
      }
    },

    filtraProposta() {
      this.$refs.grid_c.FiltraGrid(this.cd_proposta);
    },

    async AttCliente() {
      this.load = true;
      this.cliente_popup = false;
      await this.EditaProposta();
      //await this.Lookup_Tipo_Endereco();

      this.load = false;
    },

    verificaQuantidade(e) {
      if (e.Quantidade === "") {
        e.Quantidade = 0;
      }
      e.Quantidade = parseFloat(e.Quantidade);
      if (e.Quantidade <= 0) {
        this.carrinho.find((i) => {
          if (i.cd_controle == e.cd_controle) {
            i.Quantidade = 1;
          }
          return i.cd_controle == e.cd_controle;
        });
      }
      this.SomaItens();
    },

    async ExcluiItem() {
      if (this.produto_excluir.cd_consulta != undefined) {
        var exclui_item = {
          cd_parametro: 7,
          vl_total_consulta: this.valorTotal,
          cd_consulta: this.produto_excluir.cd_consulta,
          cd_item_consulta: this.produto_excluir.cd_item_consulta,
        };
        let item_excluido = await Incluir.incluirRegistro(
          this.api,
          exclui_item
        ); //pr_egisnet_elabora_proposta
        notify(item_excluido[0].Msg);
        this.EditaProposta();
      } else {
        this.carrinho.splice(this.indice_excluir, 1);
        notify("Item excluído");
      }
    },

    FechaPopupDeclina() {
      //Fecha a tela após declinar a proposta
      this.$emit("click");
    },

    FechaConsulta() {
      this.$emit("click");
    },

    async OnMoeda() {
      this.valorTotal = await funcao.FormataValor(
        this.valorTotal,
        this.moeda ? this.moeda.sg_moeda_funcao : "BRL"
      );
    },

    async ValorParcela() {
      if (this.pagamento.qt_parcela_condicao_pgto) {
        this.vl_parcela_condicao_pgto = await funcao.FormataValor(
          this.valorTotal,
          this.moeda ? this.moeda.sg_moeda_funcao : "BRL"
        );
      }

      //Se quiser mostrar o valor da cada parcela
      // for (var i = 0; i < this.pagamento.qt_parcela_condicao_pgto; i++) {
      //   this.vl_parcela_condicao_pgto.push(valor_dividido).toFixed(2);
      // }
    },

    async carregaCarrinho() {
      const menu = await Menu.montarMenu(this.cd_empresa, 7442, 562); // 1565 - pr_egisnet_elabora_proposta
      this.colunas_carrinho = JSON.parse(
        JSON.parse(JSON.stringify(menu.coluna))
      );
      this.colunas_carrinho.map((e) => {
        e.encodeHtml = false;
        if (
          e.dataField == "Valor" ||
          e.dataField == "Quantidade" ||
          e.dataField == "Un" ||
          e.dataField == "pc_desconto_item" ||
          e.dataField == "qt_dia_entrega_consulta" ||
          e.dataField == "Máscara" ||
          e.dataField == "Produto" ||
          //e.dataField == "dt_entrega_consulta" ||
          //e.dataField == "pc_ipi" ||
          //e.dataField == "pc_icms" ||
          e.dataField == "cd_pedido_compra_consulta" ||
          e.dataField == "cd_it_ped_compra_cliente" ||
          e.dataField == "qt_peso_bruto" ||
          e.dataField == "vl_frete_item_consulta"
        ) {
          e.allowEditing = true;
        } else {
          e.allowEditing = false;
        }
        if (e.dataField == "Un") {
          (e.dataType = "array"),
            (e.data = this.dataset_lookup_um),
            (e.key = "cd_unidade_medida");
        }
      });
    },

    async EditaProposta() {
      this.EditFiltroProposta = true;
      if (this.cd_proposta == 0) {
        this.linha_selecionada = grid.Selecionada();
        if (
          this.consulta_up.cd_movimento != undefined &&
          this.consulta_up.cd_movimento != 0
        ) {
          this.cd_proposta = this.consulta_up.cd_movimento;
          this.cd_documento = this.consulta_up.cd_documento;
        } else if (this.linha_selecionada.cd_consulta != undefined) {
          this.cd_proposta = this.linha_selecionada.cd_consulta;
          this.cd_documento = this.linha_selecionada.cd_documento;
        } else {
          notify("Nenhuma proposta foi selecionada para editar!");
          return;
        }
      } else {
        var json_altera_consulta = {
          cd_parametro: 8,
          cd_consulta: this.cd_proposta,
          cd_cliente: this.cd_cliente,
          cd_vendedor: this.vendedor.cd_vendedor,
          cd_vendedor_externo: this.vendedor_externo.cd_vendedor,
          cd_contato: this.contato_selecionado.cd_contato_selecionado,
          cd_transportadora: this.transportadora.cd_transportadora,
          cd_destinacao_produto: this.destinacao.cd_destinacao_produto,
          cd_tipo_endereco: this.tipo_endereco.cd_tipo_endereco,
          cd_usuario: this.cd_usuario,
          cd_tipo_pedido: this.tipo_pedido.cd_tipo_pedido,
          cd_tipo_local_entrega: this.tipo_local_entrega.cd_tipo_local_entrega,
          cd_tipo_frete: this.tipo_frete.cd_tipo_frete,
          cd_condicao_pagamento: this.pagamento.cd_condicao_pagamento,
          cd_tipo_pagamento_frete: this.frete_pagamento.cd_tipo_pagamento_frete,
          cd_moeda: this.moeda ? this.moeda.cd_moeda : 1,
          //cd_pais: this.pais.cd_pais,
          nm_referencia_consulta: this.nm_referencia_consulta,
          ds_observacao_consulta: this.obs,
          vl_total_consulta: this.total_banco,
          cd_tipo_entrega:
            this.tipo_entrega == undefined
              ? ""
              : this.tipo_entrega.cd_tipo_entrega_produto,
          cd_forma_pagamento: this.forma_pagamento.cd_forma_pagamento,
          ic_operacao_triangular: this.ic_operacao_triangular
            ? this.ic_operacao_triangular
            : "N",
          ic_email_consulta: this.ic_gera_email_confirmacao,
          ic_fechamento_total: this.ic_fechamento_total,
          cd_tipo_restricao_pedido:
            this.tipo_restricao_pedido.cd_tipo_restricao_pedido,
        };
        const altera_consulta = await Incluir.incluirRegistro(
          this.api,
          json_altera_consulta
        );
        notify(altera_consulta[0].Msg);
      }
      this.popup_proposta = true;
      var json_consulta = {
        cd_parametro: 6,
        cd_consulta: this.cd_proposta,
      };
      this.proposta_consulta = await Incluir.incluirRegistro(
        this.api,
        json_consulta
      ); //pr_egisnet_elabora_proposta
      this.cliente = this.dataset_lookup_cliente.find(
        (element) => element.cd_cliente == this.proposta_consulta[0].cd_cliente
      );
      //await this.Lookup_Tipo_Endereco();

      this.nm_cliente = this.cliente.nm_fantasia_cliente;
      this.cd_cliente = this.proposta_consulta[0].cd_cliente;
      this.ic_fechamento_total = this.proposta_consulta[0].ic_fechamento_total
        ? this.proposta_consulta[0].ic_fechamento_total
        : "N";
      this.ic_operacao_triangular = this.proposta_consulta[0]
        .ic_operacao_triangular
        ? this.proposta_consulta[0].ic_operacao_triangular
        : "N";
      this.ic_gera_email_confirmacao = this.proposta_consulta[0]
        .ic_email_consulta
        ? this.proposta_consulta[0].ic_email_consulta
        : "N";
      this.selecao = true;
      if (this.proposta_consulta[0].cd_contato > 0) {
        this.selecao_contato = true;
        this.contato_selecionado.Fantasia_contato =
          this.proposta_consulta[0].nm_fantasia_contato;
        this.contato_selecionado.email_contato =
          this.proposta_consulta[0].cd_email_contato_cliente;
        this.contato_selecionado.telefone_contato =
          this.proposta_consulta[0].cd_telefone_contato;
        this.contato_selecionado.celular_contato =
          this.proposta_consulta[0].cd_celular;
        this.contato_selecionado.cd_contato_selecionado =
          this.proposta_consulta[0].cd_contato;
      }
      //PREENCHE AS INFORMAÇÕES DO CLIENTE
      this.Fantasia = this.proposta_consulta[0].nm_fantasia_cliente;
      this.Razao_Social = this.proposta_consulta[0].nm_razao_social_cliente;
      if (
        this.proposta_consulta[0].cd_ddd != null ||
        this.proposta_consulta[0].cd_telefone != null
      ) {
        this.Telefone_Empresa =
          "(" +
          this.proposta_consulta[0].cd_ddd +
          ")" +
          this.proposta_consulta[0].cd_telefone;
      } else {
        this.Telefone_Empresa = "";
      }
      this.CNPJ = this.proposta_consulta[0].cd_cnpj_cliente;
      if (this.CNPJ != "") {
        this.CNPJ.length == 11
          ? funcao.FormataCPF(this.CNPJ).then((e) => {
              this.CNPJ = e;
            })
          : funcao.FormataCNPJ(this.CNPJ).then((e) => {
              this.CNPJ = e;
            });
      }
      this.nm_dominio_cliente = this.proposta_consulta[0].nm_dominio_cliente;
      this.Email = this.proposta_consulta[0].nm_email_cliente;
      this.Tipo_Pessoa = this.proposta_consulta[0].nm_tipo_pessoa;
      this.Ramo_Atividade = this.proposta_consulta[0].nm_ramo_atividade;
      this.Status_Cliente = this.proposta_consulta[0].nm_status_cliente;

      this.Insc_Estadual = this.proposta_consulta[0].cd_inscestadual;
      this.Insc_Municipal = this.proposta_consulta[0].cd_inscMunicipal;
      this.CEP = this.proposta_consulta[0].cd_cep;
      this.Endereco = this.proposta_consulta[0].nm_endereco_cliente;
      this.Numero = this.proposta_consulta[0].cd_numero_endereco;
      this.Complemento = this.proposta_consulta[0].nm_complemento_endereco;
      this.Bairro = this.proposta_consulta[0].nm_bairro;
      this.Cidade = this.proposta_consulta[0].nm_cidade;
      this.Estado = this.proposta_consulta[0].nm_estado;
      this.tipo_endereco = {
        cd_tipo_endereco: this.proposta_consulta[0].cd_tipo_endereco,
        nm_tipo_endereco: this.proposta_consulta[0].nm_tipo_endereco,
        cep_entrega: this.proposta_consulta[0].cd_cep_entrega,
        endereco_entrega: this.proposta_consulta[0].nm_endereco_entrega,
        numero_entrega: this.proposta_consulta[0].cd_numero_entrega,
        complemento_entrega:
          this.proposta_consulta[0].nm_complemento_endereco_entrega,
        bairro_entrega: this.proposta_consulta[0].nm_bairro_entrega,
        estado_entrega: this.proposta_consulta[0].nm_estado_entrega,
        cidade_entrega: this.proposta_consulta[0].nm_cidade_entrega,
        referencia_entrega: this.proposta_consulta[0].nm_ponto_ref_cli_endereco,
      };
      try {
        this.hoje = formataData.formataDataJS(
          this.proposta_consulta[0].dt_consulta
        );
      } catch {
        this.hoje = "";
      }
      this.selecao = true;

      /////////////////////////////////////////////////////////////
      //CARRINHO DE COMPRAS
      this.carrinho = [];
      if (this.proposta_consulta[0].Cod_Produto != 0) {
        this.carrinho = this.proposta_consulta.slice();
        await this.carregaCarrinho();
      }
      [this.moeda] = this.dataset_lookup_moeda.filter((m) => {
        return m.cd_moeda === this.proposta_consulta[0].cd_moeda;
      });
      //aqui
      await this.SomaItens();
      /////////////////////////////////////////////////////////////
      await this.ValorParcela();
      this.cd_cliente = this.proposta_consulta[0].cd_cliente;
    },

    async Lookup_Tipo_Endereco() {
      var json_lookup = {
        cd_parametro: 9,
        cd_cliente: this.cliente.cd_cliente,
      };
      this.dataset_lookup_tipo_endereco = await Incluir.incluirRegistro(
        this.api,
        json_lookup
      ); //pr_egisnet_elabora_proposta
    },

    limpaPesquisa() {
      this.categoria = "";
      this.grupo = "";
      this.marca = "";
      this.cd_mascara_produto = "";
      this.nm_fantasia_produto = "";
      this.nm_produto = "";
    },

    limpaTudo() {
      this.cd_proposta = 0;
      this.cd_documento = 0;
      this.nm_cliente = "";
      this.cliente = "";
      this.Fantasia = "";
      this.Razao_Social = "";
      this.Telefone_Empresa = "";
      this.CNPJ = "";
      this.nm_dominio_cliente = "";
      this.Email = "";
      this.Tipo_Pessoa = "";
      this.Ramo_Atividade = "";
      this.Status_Cliente = "";
      this.carrinho = [];
      this.vendedor = "";
      this.vendedor_externo = "";
      this.transportadora = "";
      this.ic_operacao_triangular = "N";
      this.ic_fechamento_total = "N";
      this.ic_gera_email_confirmacao = "N";
      this.tipo_restricao_pedido = [];
      this.destinacao = "";
      this.tipo_pedido = "";
      this.tipo_endereco = "";
      this.tipo_local_entrega = "";
      this.tipo_frete = "";
      this.pagamento = "";
      this.forma_pagamento = "";
      this.frete_pagamento = "";
      this.moeda = "";
      this.pais = "";
      this.nm_referencia_consulta = "";
      this.obs = "";
      this.valorTotal = 0;
      this.contato_selecionado = [];
      this.selecao_contato = false;
      this.cliente_popup = false;
      this.selecao = true;
    },

    onFocusedRowChanged: function (e) {
      this.linha_selecionada = e.row && e.row.data;
    },

    onFocusedRowChangedCarrinho: function (e) {
      this.linha_selecionada = e.row && e.row.data;
    },

    LinhaGridCliente: function (e) {
      this.cliente_selecionado = e.row && e.row.data;
    },

    async attQtd(e) {
      await funcao.sleep(1);
      var SomaItens = [];
      e.rows.map((i) => {
        SomaItens.push(i.data.vl_total_item);
        if (
          i.data.Quantidade == null ||
          i.data.Quantidade == undefined ||
          i.data.Quantidade < 0
        ) {
          this.grid_carrinho.cellValue(i.rowIndex, "Quantidade", 0.0);
          this.grid_carrinho.cellValue(i.rowIndex, "vl_total_item", 0.0);
          i.data.Quantidade = 0;
        }
        if (i.data.Quantidade > 0) {
          ////Verifica se a qtdade digitada é maior que o disponível
          if (
            !this.carrinho.find((e) => e.cd_controle === i.data.cd_controle)
          ) {
            this.grid_carrinho.saveEditData();
          } else {
            let alterouQtd = this.carrinho.find(
              (e) => e.cd_controle === i.data.cd_controle
            );
            alterouQtd.index = this.carrinho.findIndex(
              (e) => e.cd_controle === i.data.cd_controle
            );
            if (alterouQtd.Quantidade != i.data.Quantidade) {
              this.carrinho[alterouQtd.index].Quantidade = i.data.Quantidade;
            }
          }
          let vl_total_item =
            i.data.Quantidade * (i.data.VL_PRODUTO || i.data.Valor);
          this.grid_carrinho.cellValue(
            i.rowIndex,
            "vl_total_item",
            vl_total_item
          );
        }
      });
      let vl_somado = SomaItens.reduce(
        (partialSum, currentNumber) => partialSum + currentNumber,
        0
      );
      this.valorTotal = await funcao.FormataValor(
        vl_somado,
        this.moeda ? this.moeda.sg_moeda_funcao : "BRL"
      );
    },

    async CalculaValores() {
      //Realizar todos os calculos de porcentagens
      for (let i = 0; i < this.carrinho.length; i++) {
        let valorLinha =
          this.carrinho[i].vl_lista_item * this.carrinho[i].Quantidade;
        if (this.carrinho[i].pc_desconto_item < 0) {
          this.carrinho[i].pc_desconto_item = 0;
        }
        if (valorLinha > 0 && !!this.carrinho[i].pc_desconto_item) {
          this.carrinho[i].Valor = await funcao.Desconto(
            valorLinha,
            this.carrinho[i].pc_desconto_item
          );
        }

        if (this.carrinho[i].Valor < 0) {
          this.carrinho[i].Valor = this.carrinho[i].vl_lista_item;
        }
      }
    },

    async SalvaESoma() {
      await this.grid_carrinho.saveEditData();
      await funcao.sleep(1);
      await this.SomaItens();
    },

    async AddCliente() {
      this.cliente_popup = !this.cliente_popup;
      this.dados_lookup_cliente = await Lookup.montarSelect(
        this.cd_empresa,
        93
      );
      this.dataset_lookup_cliente = JSON.parse(
        JSON.parse(JSON.stringify(this.dados_lookup_cliente.dataset))
      );
      this.lista_cliente = this.dataset_lookup_cliente.slice(0, 40);
    },

    async AprovaProposta() {
      if (this.CNPJ.length == 0) {
        notify("O cliente precisa ter o CNPJ/CPF preenchido!");
        return;
      }

      if (this.Status_Cliente != "Ativo") {
        notify(
          "Não é possivel Aprovar proposta para clientes que não estejam Ativos!"
        );
        return;
      }

      if (this.carrinho.length == 0) {
        notify("A proposta precisa de pelo menos 1 produto!");
        return;
      }

      if (this.valorTotal <= 0) {
        notify("O valor da proposta precisa está zerado!");
        return;
      }
      var j = {
        cd_parametro: 14,
        cd_vendedor: this.vendedor.cd_vendedor,
        cd_vendedor_externo: this.vendedor_externo.cd_vendedor,
        vl_total_consulta: this.valorTotal,
        cd_cliente: this.cd_cliente,
        cd_destinacao_produto: this.destinacao.cd_destinacao_produto,
        cd_tipo_pedido: this.tipo_pedido.cd_tipo_pedido,
        cd_tipo_frete: this.tipo_frete.cd_tipo_frete,
        cd_tipo_pagamento_frete: this.frete_pagamento.cd_tipo_pagamento_frete,
        cd_forma_pagamento: this.forma_pagamento.cd_forma_pagamento,
        cd_transportadora: this.transportadora.cd_transportadora,
        cd_contato: this.contato_selecionado.cd_contato_selecionado,
        cd_usuario: this.cd_usuario,
        cd_condicao_pagamento: this.pagamento.cd_condicao_pagamento,
        cd_tipo_local_entrega: this.tipo_local_entrega.cd_tipo_local_entrega,
        cd_tipo_endereco: this.tipo_endereco.cd_tipo_endereco,
        cd_consulta: this.cd_proposta,
        cd_moeda: this.moeda ? this.moeda.cd_moeda : 1,
        //cd_pais: this.pais.cd_pais,
        carrinho: this.carrinho,
        ic_operacao_triangular: this.ic_operacao_triangular,
        ic_fechamento_total: this.ic_fechamento_total,
        cd_tipo_restricao_pedido:
          this.tipo_restricao_pedido.cd_tipo_restricao_pedido,
      };
      let aprova_proposta = await Incluir.incluirRegistro(this.api, j);
      notify(aprova_proposta[0].Msg);
      this.$emit("click");
      this.popup_fechar = false;
    },

    FechaProposta() {
      //CNPJ IE Endereço do cliente DDD e Telefone
      //Add IE, Endereço do Cliente
      if (this.CNPJ.length == 0) {
        notify("O cliente precisa ter o CNPJ/CPF preenchido!");
        return;
      }
      if (this.Telefone_Empresa.length == 0) {
        notify("O telefone precisa ser preenchido!");
        return;
      }
      // if (this.Insc_Estadual == undefined) {
      //   notify("a Inscrição Estadual precisa estar preenchida!");
      //   return;
      // }
      if (this.Endereco == undefined) {
        notify("O endereço precisa ser preenchido!");
        return;
      }
      this.popup_fechar = true;
    },

    async ListaCarrinho(e) {
      e.Valor = e.Valor.includes("R$") ? e.Valor.replace("R$", "") : e.Valor;
      e.Valor = e.Valor.includes("US$") ? e.Valor.replace("US$", "") : e.Valor;
      e.Valor = e.Valor.includes("€") ? e.Valor.replace("€", "") : e.Valor;
      if (e.Quantidade == 0) {
        e.Quantidade = parseFloat(e.Quantidade + 1);

        if (this.carrinho.length === 0) {
          this.carrinho.push(e);
        } else {
          e.cd_controle = parseFloat(
            this.carrinho[this.carrinho.length - 1].cd_controle + 1
          );
          this.carrinho.push(e);
        }
      } else {
        this.carrinho.push(e);
      }
      await this.SomaItens(e);
      await this.SalvaESoma();
      this.limpaPesquisa();
      this.resultado_categoria = [];
      this.pesquisa_produto = false;
      notify("Item adicionado ao carrinho!");
    },

    async SomaItens(e) {
      //Impede de inserir valor negativo
      if (e !== undefined) {
        if (e.Valor <= 0) {
          this.carrinho.find((i) => {
            if (i.cd_controle == e.cd_controle) {
              i.Valor = 1;
            }
            return i.cd_controle == e.cd_controle;
          });
        }
      }
      //Soma dos itens e do Valor total
      this.valorTotal = 0;
      this.carrinho.map((item) => {
        item.vl_total_item == undefined
          ? (item.vl_total_item = parseFloat(item.vl_lista_item))
          : "";
        item.Valor = parseFloat(item.Valor);
        item.pc_desconto_item = parseFloat(item.pc_desconto_item);
        item.qt_peso_bruto = parseFloat(item.qt_peso_bruto);
        item.pc_ipi = parseFloat(item.pc_ipi);
        item.pc_icms = parseFloat(item.pc_icms);
        if (!item.vl_total_item) {
          this.valorTotal = parseFloat(
            this.valorTotal +
              parseFloat(item.VL_PRODUTO) *
                parseFloat(item.Quantidade.toFixed(2))
          );
        } else {
          this.valorTotal += item.vl_total_item;
        }
      });
      this.valorTotal = await funcao.FormataValor(
        this.valorTotal,
        this.moeda ? this.moeda.sg_moeda_funcao : "BRL"
      );
    },

    ContatoSelecionado(e) {
      this.contato_selecionado = [];
      this.contato_selecionado.Fantasia_contato = e.nm_fantasia_contato;
      this.contato_selecionado.email_contato = e.cd_email_contato_cliente;
      this.contato_selecionado.telefone_contato = e.cd_telefone_contato;
      this.contato_selecionado.celular_contato = e.cd_celular;
      this.contato_selecionado.cd_contato_selecionado = e.cd_contato;

      this.selecao_contato = true;
      this.popup_contato = false;
    },

    async onPesquisaContato() {
      let json_pesquisa = {
        cd_parametro: 2,
        cd_cliente: this.cd_cliente,
      };
      this.load_contato = true;
      this.resultado_contato = await Incluir.incluirRegistro(
        this.api,
        json_pesquisa
      );
      this.load_contato = false;
      if (this.resultado_contato[0].Cod == 0) {
        notify("Nenhum contato encontrado...");
        return;
      }
      notify(this.resultado_contato[0].Msg);
      this.popup_contato = !this.popup_contato;
    },

    async onVerificaPesquisaProduto() {
      if (
        this.categoria.cd_categoria_produto == undefined &&
        this.grupo.cd_grupo_produto == undefined &&
        this.marca.cd_marca_produto == undefined &&
        this.cd_mascara_produto == "" &&
        this.nm_fantasia_produto == "" &&
        this.nm_produto == ""
      ) {
        this.popup_pesquisa_filtro = true;
      } else {
        await this.onPesquisaProduto();
      }
    },

    async onPesquisaProduto() {
      notify("Aguarde...");
      this.resultado_categoria = [];
      this.popup_pesquisa_filtro = false;
      if (this.tipo_pesquisa_produto == "S") {
        this.nm_json = {
          cd_parametro: 10,
          cd_usuario: this.cd_usuario,
          cd_categoria_produto: this.categoria.cd_categoria_produto,
          cd_grupo_produto: this.grupo.cd_grupo_produto,
          cd_marca_produto: this.marca.cd_marca_produto,
          cd_mascara_produto: this.cd_mascara_produto,
          nm_fantasia_produto: this.nm_fantasia_produto,
          nm_produto: this.nm_produto,
        };
      } else if (this.tipo_pesquisa_produto == "N") {
        this.nm_json = {
          cd_parametro: 12,
          cd_usuario: this.cd_usuario,
          nm_produto: this.nm_produto,
        };
      }

      let menu_pesquisa = await Menu.montarMenu(this.cd_empresa, 7441, 562);
      this.colunas = JSON.parse(
        JSON.parse(JSON.stringify(menu_pesquisa.coluna))
      );

      try {
        this.load = true;
        this.resultado_categoria = await Incluir.incluirRegistro(
          this.api,
          this.nm_json
        );
        this.load = false;
      } catch (error) {
        this.load = false;
      }

      this.codigo = true;
      if (this.resultado_categoria[0].Cod === 0) {
        this.codigo = false;
        notify("Nenhum produto encontrado!");
        return;
      }
    },

    async onUploadDoc() {
      if (this.documento_upload.size !== undefined) {
        // Cria um objeto FormData e anexa o arquivo a ele
        this.uploading_load = true;
        const formData = new FormData();
        formData.append("file", this.documento_upload);
        formData.append("nm_ftp_empresa", localStorage.nm_ftp_empresa);
        formData.append("nm_pasta_ftp", this.consulta_up.nm_pasta_ftp);
        // Configura as opções da requisição
        const options = {
          method: "POST",
          url: "https://egis-store.com.br/api/upload",
          headers: {
            "Content-Type": "multipart/form-data", // Define o tipo de conteúdo como multipart/form-data
          },
          data: formData, // Define o corpo da requisição como o objeto FormData
        };
        axios(options)
          .then(async () => {
            ////Salva o caminho do documento
            let json_salva_doc = {
              cd_parametro: 21,
              cd_consulta: this.cd_proposta,
              nm_caminho_documento: this.documento_upload.name,
              cd_usuario: this.cd_usuario,
            };
            let [doc_inserido] = await Incluir.incluirRegistro(
              this.api, //pr_egisnet_elabora_proposta
              json_salva_doc
            );
            notify(doc_inserido.Msg);
            this.documento_upload = [];
          })
          .catch((error) => {
            // eslint-disable-next-line no-console
            console.error("Erro:", error);
            notify("Não foi possível salvar o documento");
          })
          .finally(() => {
            this.uploading_load = false;
            this.att_grid_doc = !this.att_grid_doc; //Atualiza a grid de documento
          });
      } else {
        notify("Selecione um documento para salvar");
      }
    },

    async onDownloadDoc() {
      const options = {
        method: "GET",
        responseType: "blob",
        url: `https://egis-store.com.br/api/download/${this.linha_doc.nm_caminho_documento}/${localStorage.nm_ftp_empresa}/${this.consulta_up.nm_pasta_ftp}`,
      };

      // Faz a solicitação usando Axios
      axios(options)
        .then((response) => {
          const blob = new Blob([response.data], {
            type: "application/octet-stream",
          }); // Cria um Blob a partir dos dados recebidos

          // Cria um link para o Blob e define seus atributos
          const url = window.URL.createObjectURL(blob);
          const link = document.createElement("a");
          link.href = url;
          link.download = this.linha_doc.nm_consulta_documento; // Define o nome do arquivo que será baixado

          // Adiciona o link ao documento e simula um clique para iniciar o download
          document.body.appendChild(link);
          link.click();

          // Limpa o objeto URL criado após o download
          window.URL.revokeObjectURL(url);
        })
        .catch((error) => {
          // eslint-disable-next-line no-console
          console.error("Erro:", error);
        });
    },

    onDeleteDoc() {},

    async onCancelaItens() {
      try {
        this.load = true;
        await this.EditaProposta();
        this.load = false;
      } catch {
        this.load = false;
      }
    },

    async onSalvarItens() {
      if (this.cliente == "") {
        return notify("Selecione o cliente");
      }

      if (!!this.tipo_pedido == false || this.tipo_pedido == "") {
        return notify("Selecione o Tipo de Pedido");
      }

      this.load_gravar = true;
      await this.grid_carrinho.saveEditData();
      await this.SomaItens();
      if (this.valorTotal <= "R$ 0,00") {
        notify("O valor da proposta deve ser maior que 0!");
        this.load_gravar = false;
        return;
      }
      if (this.carrinho.length == 0) {
        return notify("Insira pelo menos um produto");
      }
      var item_carrinho_zerado = false;
      this.carrinho.forEach((e) => {
        if (e.Valor == 0 || e.Valor == null) {
          notify(`O produto ${e.Produto} está com valor zerado!`);
          this.load_gravar = false;
          return (item_carrinho_zerado = true);
        }
      });
      if (item_carrinho_zerado == true) {
        return;
      }
      if (this.cd_proposta == 0) {
        this.load_gravar = false;
        await this.InsertProposta();
      }

      if (this.cd_proposta == 0) {
        this.load_gravar = false;
        notify("Selecione a proposta!");
        return;
      }
      var meuJson = {
        cd_parametro: 4,
        cd_consulta: this.cd_proposta,
        vl_total_consulta: this.valorTotal,
        cd_usuario: this.cd_usuario,
        carrinho: this.carrinho,
      };
      this.load = true;
      var inseriu_itens = await Incluir.incluirRegistro(this.api, meuJson);
      notify(inseriu_itens[0].Msg);
      try {
        await this.EditaProposta();
        this.load_gravar = false;
        this.load = false;
      } catch (err) {
        // eslint-disable-next-line no-console
        console.error(err);
        notify("Não foi possível gravar a proposta!");
        this.load_gravar = false;
        this.load = false;
      }
    },

    DeletaItem(e, index) {
      this.confirma_exclusao = true;
      this.produto_excluir = e;
      this.indice_excluir = index;
    },

    Menos(e, index) {
      if (parseInt(e.Quantidade) - 1 == 0) {
        this.confirma_exclusao = true;
        this.produto_excluir = e;
        this.indice_excluir = index;
      } else {
        e.Quantidade = parseInt(e.Quantidade) - 1;
      }
      this.SomaItens();
    },
    Mais(e) {
      e.Quantidade = parseInt(e.Quantidade) + 1;
      this.SomaItens();
    },

    async InsertProposta() {
      notify("Aguarde...");
      var json_insert_consulta = {
        cd_parametro: 5,
        cd_cliente: this.cd_cliente,
        cd_vendedor: this.vendedor.cd_vendedor,
        cd_vendedor_externo: this.vendedor_externo.cd_vendedor,
        cd_contato: this.contato_selecionado.cd_contato_selecionado,
        cd_transportadora: this.transportadora.cd_transportadora,
        cd_destinacao_produto: this.destinacao.cd_destinacao_produto,
        cd_usuario: this.cd_usuario,
        cd_tipo_pedido: this.tipo_pedido.cd_tipo_pedido,
        cd_tipo_local_entrega: this.tipo_local_entrega.cd_tipo_local_entrega,
        cd_tipo_endereco: this.tipo_endereco.cd_tipo_endereco,
        cd_tipo_frete: this.tipo_frete.cd_tipo_frete,
        cd_condicao_pagamento: this.pagamento.cd_condicao_pagamento,
        cd_tipo_pagamento_frete: this.frete_pagamento.cd_tipo_pagamento_frete,
        cd_moeda: this.moeda ? this.moeda.cd_moeda : 1,
        //cd_pais: this.pais.cd_pais,
        nm_referencia_consulta: this.nm_referencia_consulta,
        ds_observacao_consulta: this.obs,
        vl_total_consulta: this.total_banco,
        cd_tipo_entrega:
          this.tipo_entrega == undefined
            ? ""
            : this.tipo_entrega.cd_tipo_entrega_produto,
        cd_forma_pagamento: this.forma_pagamento.cd_forma_pagamento,
        ic_operacao_triangular: this.ic_operacao_triangular,
        ic_email_consulta: this.ic_gera_email_confirmacao,
        ic_fechamento_total: this.ic_fechamento_total,
        cd_tipo_restricao_pedido:
          this.tipo_restricao_pedido.cd_tipo_restricao_pedido,
      };
      //return;
      this.envio_consulta = await Incluir.incluirRegistro(
        this.api,
        json_insert_consulta
      );
      notify(this.envio_consulta[0].Msg);

      this.pesquisa_produto = true;

      this.cd_proposta = this.envio_consulta[0].Cod;

      let j = 0;
      for (j = 0; j < this.produtos.length; j++) {
        json_confirma = {};
        var json_confirma = {
          cd_consulta: this.cd_proposta,
          cd_parametro: 4,
          cd_produto: this.produtos[j].Cod_Produto,
          qt_prod: this.produtos[j].quantidade,
          vl_produto: this.produtos[j].Valor,
          cd_cliente: this.cd_cliente,
          cd_destinacao_produto: this.destinacao.cd_destinacao_produto,
          cd_usuario: this.cd_usuario,
        };
        this.envio_proposta = await Incluir.incluirRegistro(
          this.api,
          json_confirma
        );
        notify(this.envio_proposta[0].Msg);
      }
    },

    async PesquisaCliente() {
      this.loading = true;
      this.GridCli = false;
      let before = this.nm_cliente.length;

      await funcao.sleep(1000);
      let after = this.nm_cliente.length;
      if (before == after) {
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
          this.api,
          json_pesquisa_cliente
        );
        if (this.resultado_pesquisa_cliente[0].Cod == 0) {
          notify(this.resultado_pesquisa_cliente[0].Msg);
          return;
        } else {
          this.loading = false;
          this.GridCli = true;
        }
      } else {
        this.loading = false;
        this.GridCli = false;
      }
    },
    SelecionaCliente() {
      let {
        Fantasia,
        Razao_Social,
        Telefone_Empresa,
        Telefone,
        CNPJ,
        nm_dominio_cliente,
        Tipo_Pessoa,
        Ramo_Atividade,
        Status_Cliente,
        cd_vendedor,
        Vendedor,
        cd_vendedor_interno,
        Vendedor_Interno,
        cd_transportadora,
        Transportadora,
        cd_destinacao_produto,
        Destinacao_Produto,
        cd_tipo_pedido,
        Tipo_Pedido,
        cd_tipo_endereco,
        Tipo_Endereco,
        cep_entrega,
        endereco_entrega,
        numero_entrega,
        complemento_entrega,
        bairro_entrega,
        estado_entrega,
        cidade_entrega,
        referencia_entrega,
        CEP,
        Email,
        Endereco,
        Numero,
        Complemento,
        Bairro,
        Cidade,
        Estado,
        Insc_Estadual,
        Insc_Municipal,
        cd_condicao_pagamento,
        Condicao_Pagamento,
        qt_parcela_condicao_pgto,
        cd_forma_pagamento,
        Forma_Pagamento,
        cd_tipo_pagamento_frete,
        Tipo_Pagamento_Frete,
      } = this.cliente_selecionado;
      //Cliente//
      Fantasia == null ? (this.Fantasia = "") : (this.Fantasia = Fantasia);
      Razao_Social == null
        ? (this.Razao_Social = "")
        : (this.Razao_Social = Razao_Social);
      Telefone_Empresa == null || Telefone_Empresa == ""
        ? (this.Telefone_Empresa = null)
        : (this.Telefone_Empresa = Telefone_Empresa);
      this.Telefone_Empresa == null && Telefone != null
        ? (this.Telefone_Empresa = Telefone)
        : (this.Telefone_Empresa = "");
      nm_dominio_cliente == null
        ? (this.nm_dominio_cliente = "")
        : (this.nm_dominio_cliente = nm_dominio_cliente);
      Email == null ? (this.Email = "") : (this.Email = Email);
      Tipo_Pessoa == null
        ? (this.Tipo_Pessoa = "")
        : (this.Tipo_Pessoa = Tipo_Pessoa);
      Ramo_Atividade == null
        ? (this.Ramo_Atividade = "")
        : (this.Ramo_Atividade = Ramo_Atividade);
      Status_Cliente == null
        ? (this.Status_Cliente = "")
        : (this.Status_Cliente = Status_Cliente);
      this.CNPJ = CNPJ;
      this.CNPJ.length == 11
        ? funcao.FormataCPF(this.CNPJ).then((e) => {
            this.CNPJ = e;
          })
        : funcao.FormataCNPJ(this.CNPJ).then((e) => {
            this.CNPJ = e;
          });
      this.Insc_Estadual == null
        ? (this.Insc_Estadual = "")
        : (this.Insc_Estadual = Insc_Estadual);
      this.Insc_Municipal == null
        ? (this.Insc_Municipal = "")
        : (this.Insc_Municipal = Insc_Municipal);
      this.CEP == null ? (this.CEP = "") : (this.CEP = CEP);
      this.Endereco == null ? (this.Endereco = "") : (this.Endereco = Endereco);
      this.Numero == null ? (this.Numero = "") : (this.Numero = Numero);
      this.Complemento == null
        ? (this.Complemento = "")
        : (this.Complemento = Complemento);
      this.Bairro == null ? (this.Bairro = "") : (this.Bairro = Bairro);
      this.Cidade == null ? (this.Cidade = "") : (this.Cidade = Cidade);
      this.Estado == null ? (this.Estado = "") : (this.Estado = Estado);
      //Proposta//
      this.vendedor = {
        cd_vendedor:
          cd_vendedor_interno == null
            ? this.cd_vendedor.cd_vendedor
            : cd_vendedor_interno,
        nm_vendedor:
          Vendedor_Interno == null
            ? this.cd_vendedor.nm_vendedor
            : Vendedor_Interno,
      };

      this.vendedor_externo = {
        cd_vendedor:
          cd_vendedor == null ? this.cd_vendedor.cd_vendedor : cd_vendedor,
        nm_vendedor: Vendedor == null ? this.cd_vendedor.nm_vendedor : Vendedor,
      };

      this.transportadora = {
        cd_transportadora: cd_transportadora,
        nm_transportadora: Transportadora,
      };
      this.destinacao = {
        cd_destinacao_produto: cd_destinacao_produto,
        nm_destinacao_produto: Destinacao_Produto,
      };
      this.tipo_pedido = {
        cd_tipo_pedido: cd_tipo_pedido,
        nm_tipo_pedido: Tipo_Pedido,
      };

      this.tipo_endereco = {
        cd_tipo_endereco: cd_tipo_endereco,
        nm_tipo_endereco: Tipo_Endereco,
        cep_entrega: cep_entrega,
        endereco_entrega: endereco_entrega,
        numero_entrega: numero_entrega,
        complemento_entrega: complemento_entrega,
        bairro_entrega: bairro_entrega,
        estado_entrega: estado_entrega,
        cidade_entrega: cidade_entrega,
        referencia_entrega: referencia_entrega,
      };

      //Pagamento//

      this.pagamento = {
        cd_condicao_pagamento: cd_condicao_pagamento,
        nm_condicao_pagamento: Condicao_Pagamento,
        qt_parcela_condicao_pgto: qt_parcela_condicao_pgto,
      };
      this.frete_pagamento = {
        cd_tipo_pagamento_frete: cd_tipo_pagamento_frete,
        nm_tipo_pagamento_frete: Tipo_Pagamento_Frete,
      };
      this.forma_pagamento = {
        cd_forma_pagamento: cd_forma_pagamento,
        nm_forma_pagamento: Forma_Pagamento,
      };
      this.cliente = {
        cd_cliente: this.cliente_selecionado.cd_cliente,
        nm_fantasia_cliente: this.cliente_selecionado.Fantasia,
      };
      this.cd_cliente = this.cliente_selecionado.cd_cliente;
      this.resultado_contato = [];
      this.popup_contato = false;
      //await this.onPesquisaContato();
      this.GridCli = false;
      this.cliente_popup = false;
      this.selecao_contato = false;
      this.contato_selecionado = [];
      this.selecao = true;
    },
  },
};
</script>

<style scoped>
@import url("./views.css");
.smargin {
  margin: 5px;
  margin-left: 10px;
}

.centralize {
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 20px;
  background: #0ff;
}

.list {
  background: rgb(252, 207, 125);
  border-radius: 8px;
  margin: 0px;
  padding: 0;
  display: inline-block;
  vertical-align: top;
  white-space: normal;
}
.sortable-cards {
  min-height: 0 !important;
}
.card1 {
  width: 100%;
}

.card {
  width: 15vw;
  height: 25vw;
}

#scrollview {
  max-width: 98vw;
}

.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}

.margin5 {
  margin: 5px;
}

.quatro-tela {
  padding: 0;
  width: 21vw;
}

.tres-tela {
  width: 31%;
}
.duas-tela {
  width: 47%;
}

.carrinho {
  width: 20vw;
  height: auto;
  display: inline-block;
}
.nome-campo {
  width: 100%;
  padding: 0;
}

.quantidade {
  width: 24% !important;
}
.um-quinto {
  width: 14.5vw;
}
.inputProduto {
  width: 30vw;
}
.botao5 {
  min-width: 10vw;
  width: auto;
}
.grid-padrao {
  width: 91.5vw !important;
}

@media (max-width: 950px) {
  .carrinho {
    width: 40vw;
    height: auto;
    display: inline-block;
  }
  .card {
    width: 40vw;
  }

  .quatro-tela {
    width: 100%;
  }

  .tres-tela {
    width: 100%;
  }
  .duas-tela {
    width: 100%;
  }
  .um-quinto {
    width: 100%;
  }
  .inputProduto {
    width: 100%;
    justify-content: center;
  }
  .botao5 {
    justify-content: center;
    min-width: 100%;
    width: 100%;
  }
}
@media (max-width: 640px) {
  .carrinho {
    width: 90vw;
    height: auto;
    display: inline-block;
  }
  .media {
    width: 100% !important;
  }
  .card {
    width: 80vw;
  }
}
</style>
