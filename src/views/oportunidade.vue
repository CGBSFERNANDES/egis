<template>
  <div>
    <div id="FocaTopo"></div>
    <q-layout view="lhh LpR ffr">
      <q-card-section class="row">
        <div class="text-h6 row margin1">
          Oportunidade
          <transition name="slide-fade">
            <div v-show="!up_cd_movimento == 0">
              <q-badge
                align="top"
                rounded
                color="primary"
                :label="up_cd_movimento"
              />
              | cadastro {{ dt_op }}
            </div>
          </transition>
          | {{ this.nm_vendedor }}
          <transition name="slide-fade">
            <b v-show="this.dt_op != ''"> - {{ this.hoje }} </b>
          </transition>

          <autoForm v-show="false" ref="autoForm" />
        </div>
      </q-card-section>

      <q-expansion-item
        icon="description"
        :label="'Dados'"
        default-opened
        v-model="Expansion"
        class="shadow-1 overflow-hidden margin1"
        style="border-radius: 20px; height: auto"
        header-class="row bg-primary text-white item-center text-h6"
        expand-icon-class="text-white"
      >
        <div class="borda-bloco shadow-2 margin1">
          <div class="row">
            <q-input
              dense
              class="tres-partes margin1"
              v-model="business"
              type="text"
              :label="nm_org"
              :loading="loading_org"
              ref="inputOrg"
              debounce="1000"
              @input="PesquisaOrganizacaoNome"
            >
              <!--:disable="loading_org"-->
              <template v-slot:prepend>
                <q-icon name="work" />
              </template>
              <template v-slot:append>
                <q-btn
                  round
                  color="primary"
                  icon="add"
                  size="sm"
                  @click="onAddEmpresa(1)"
                />
                <q-icon
                  v-if="business !== ''"
                  name="close"
                  @click.stop="
                    (business = ''),
                      (contact_pesq = ''),
                      (cd_site = ''),
                      (novo_telefone_org = ''),
                      (novo_email = ''),
                      (cd_organizacao = 0),
                      (cd_cliente = 0),
                      (novo_celular = ''),
                      (GridOrg = false),
                      (GridContato = false),
                      (popup_cadastro_contato = false),
                      (popup_insere_empresa = false)
                  "
                  class="cursor-pointer"
                ></q-icon>
              </template>
            </q-input>

            <q-input
              readonly
              dense
              class="tres-partes margin1"
              v-model="cd_site"
              type="text"
              label="Site"
            >
              <template v-slot:prepend>
                <q-icon name="language" />
              </template>
            </q-input>

            <q-input
              readonly
              dense
              class="tres-partes margin1"
              v-model="novo_telefone_org"
              type="text"
              label="Telefone (Organização)"
            >
              <template v-slot:prepend>
                <q-icon name="call" />
              </template>
            </q-input>
          </div>
          <transition name="slide-fade">
            <div
              style="margin: 5px 0"
              v-if="GridOrg == true && this.business.length > 0"
            >
              <div class="row">
                <q-space />
                <q-btn
                  color="primary"
                  icon="chevron_right"
                  rounded
                  label="Selecionar"
                  class="margin1"
                  @click="SelecionaOrganizacao()"
                >
                </q-btn>
              </div>
              <grid
                ref="gridOrganizacao"
                v-if="GridOrg == true && this.business.length > 0"
                :nm_json="consultaOrganizacao"
                :cd_consulta="2"
                :cd_menuID="7294"
                :cd_apiID="636"
                :filterGrid="false"
                @emit-click="SelecionaOrganizacao()"
              />
            </div>
          </transition>
          <q-separator />
          <transition name="slide-fade">
            <div class="row items-center">
              <q-input
                dense
                class="tres-partes margin1"
                v-model="contact_pesq"
                type="text"
                label="Contato"
                ref="inputOrg"
                debounce="1000"
                @input="PesquisaContatoNome"
              >
                <template v-slot:prepend>
                  <q-icon name="person_add_alt_1" />
                </template>
                <template v-slot:append>
                  <q-btn
                    round
                    color="primary"
                    icon="add"
                    size="sm"
                    @click="onAddContato(2)"
                  />
                  <q-icon
                    v-if="contact_pesq !== ''"
                    name="close"
                    @click.stop="
                      (contact_pesq = ''),
                        (novo_email = ''),
                        (novo_celular = '')
                    "
                    class="cursor-pointer"
                  ></q-icon>
                </template>
              </q-input>

              <q-input
                dense
                readonly
                class="tres-partes margin1"
                v-model="novo_email"
                type="text"
                label="E-mail"
              >
                <template v-slot:prepend>
                  <q-icon name="email" />
                </template>
              </q-input>

              <q-input
                dense
                readonly
                class="tres-partes margin1"
                v-model="novo_celular"
                mask="(##) #####-####"
                type="text"
                label="Celular (Contato)"
              >
                <template v-slot:prepend>
                  <q-icon name="smartphone" />
                </template>
              </q-input>
            </div>
          </transition>
          <transition name="slide-fade">
            <div
              v-if="popup_insere_empresa"
              transition-show="slide-up"
              transition-hide="slide-down"
            >
              <!-- CADASTRO DE ORGANIZACAO -->
              <div class="borda-bloco shadow-2 margin1">
                <div class="row items-center q-pb-none margin1">
                  <div class="text-h6">Nova {{ nm_org }}</div>
                  <q-space />
                  <q-btn
                    icon="close"
                    flat
                    round
                    dense
                    @click="popup_insere_empresa = false"
                  />
                </div>
                <div class="row justify-around">
                  <q-input
                    dense
                    class="metadeTela margin1"
                    v-model="cd_cnpj"
                    label="CPF/CNPJ"
                    debounce="1000"
                    @input="IdentificaPessoa()"
                  >
                    <template v-slot:prepend>
                      <q-icon name="app_registration" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    class="metadeTela margin1"
                    v-model="nova_organizacao"
                    type="text"
                    label="Organização"
                  >
                    <template v-slot:prepend>
                      <q-icon name="corporate_fare" />
                    </template>
                  </q-input>
                </div>
                <div class="row justify-around">
                  <q-input
                    dense
                    @blur="business = nova_organizacao_fantasia"
                    class="metadeTela margin1"
                    v-model="nova_organizacao_fantasia"
                    type="text"
                    label="Fantasia"
                  >
                    <template v-slot:prepend>
                      <q-icon name="badge" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    class="metadeTela margin1"
                    v-model="cd_site"
                    type="text"
                    label="Site"
                  >
                    <template v-slot:prepend>
                      <q-icon name="language" />
                    </template>
                  </q-input>
                </div>
                <div class="row justify-around">
                  <q-input
                    dense
                    class="metadeTela margin1"
                    v-model="nm_email_organizacao"
                    type="text"
                    label="E-mail"
                    @blur="PesquisaOrganizacao(1)"
                  >
                    <template v-slot:prepend>
                      <q-icon name="mail" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    class="metadeTela margin1"
                    v-model="novo_telefone_org"
                    maxlength="15"
                    type="text"
                    label="Telefone"
                    @input="MaskTelefone(novo_telefone_org)"
                  >
                    <template v-slot:prepend>
                      <q-icon name="call" />
                    </template>
                  </q-input>
                </div>

                <div class="row justify-around">
                  <q-select
                    dense
                    use-input
                    hide-selected
                    fill-input
                    class="metadeTela margin1"
                    label="Tipo de Mercado"
                    v-model="tipo_mercado"
                    input-debounce="0"
                    :options="dataset_lookup_tipo_mercado"
                    option-value="cd_tipo_mercado"
                    option-label="nm_tipo_mercado"
                    @input="onTipoMercado()"
                  >
                    <template v-slot:prepend>
                      <q-icon name="storefront" />
                    </template>
                  </q-select>
                  <q-select
                    dense
                    use-input
                    hide-selected
                    fill-input
                    class="metadeTela margin1"
                    label="Região"
                    v-model="regiao"
                    input-debounce="0"
                    :options="dataset_lookup_regiao"
                    option-value="cd_regiao"
                    option-label="nm_regiao"
                  >
                    <template v-slot:prepend>
                      <q-icon name="public" />
                    </template>
                  </q-select>
                </div>

                <div class="row justify-around">
                  <q-select
                    dense
                    use-input
                    hide-selected
                    fill-input
                    @filter="filterTipoPessoa"
                    class="metadeTela margin1"
                    label="Tipo de Pessoa"
                    v-model="tipo_pessoa"
                    input-debounce="0"
                    :options="opcoes_tipo_pessoa"
                    option-value="cd_tipo_pessoa"
                    option-label="nm_tipo_pessoa"
                  >
                    <template v-slot:prepend>
                      <q-icon name="groups" />
                    </template>
                  </q-select>
                  <q-input
                    dense
                    class="metadeTela margin1"
                    @blur="onBuscaCep(cep)"
                    :loading="CEPLoading"
                    v-model="cep"
                    mask="#####-###"
                    :value.sync="this.cep"
                    label="CEP"
                  >
                    <template v-slot:prepend>
                      <q-icon name="travel_explore" />
                    </template>
                  </q-input>
                </div>

                <div class="row justify-around">
                  <q-input
                    dense
                    class="umQuartoTela margin1"
                    v-model="nm_endereco"
                    :loading="CEPLoading"
                    :value.sync="this.nm_endereco"
                    label="Endereço"
                  >
                    <template v-slot:prepend>
                      <q-icon name="home" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    class="umQuartoTela margin1"
                    v-model="nm_numero_endereco"
                    mask="NNNNNNNNNN"
                    label="Número"
                  >
                    <template v-slot:prepend>
                      <q-icon name="list" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    class="umQuartoTela margin1"
                    v-model="nm_complemento_endereco"
                    label="Complemento"
                  >
                    <template v-slot:prepend>
                      <q-icon name="description" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    class="umQuartoTela margin1"
                    v-model="bairro"
                    :loading="CEPLoading"
                    label="Bairro"
                  >
                    <template v-slot:prepend>
                      <q-icon name="apartment" />
                    </template>
                  </q-input>
                </div>

                <div class="row justify-around">
                  <q-input
                    v-if="tipo_mercado.cd_tipo_mercado === 2"
                    dense
                    label="País"
                    class="umQuartoTela margin1"
                    v-model="pais"
                    input-debounce="0"
                    :loading="CEPLoading"
                  >
                    <template v-slot:prepend>
                      <q-icon name="public" />
                    </template>
                  </q-input>
                  <q-select
                    v-if="tipo_mercado.cd_tipo_mercado !== 2"
                    dense
                    label="País"
                    class="umQuartoTela margin1"
                    v-model="pais"
                    input-debounce="0"
                    :loading="CEPLoading"
                    :options="lookup_pais"
                    option-value="cd_pais"
                    option-label="nm_pais"
                  >
                    <template v-slot:prepend>
                      <q-icon name="public" />
                    </template>
                  </q-select>
                  <q-select
                    dense
                    v-if="
                      tipo_pessoa.cd_tipo_pessoa == 2 &&
                      tipo_mercado.cd_tipo_mercado !== 2
                    "
                    label="Naturalidade - Estado"
                    class="umQuartoTela margin1"
                    v-model="natural_estado"
                    input-debounce="0"
                    :loading="CEPLoading"
                    @input="SelecionaEstado(true)"
                    :options="lookup_estado_natural"
                    option-value="cd_estado"
                    option-label="nm_estado"
                  >
                    <template v-slot:prepend>
                      <q-icon name="map" />
                    </template>
                  </q-select>
                  <q-select
                    dense
                    v-if="
                      tipo_pessoa.cd_tipo_pessoa != 2 &&
                      tipo_mercado.cd_tipo_mercado !== 2
                    "
                    label="Estado"
                    class="umQuartoTela margin1"
                    v-model="natural_estado"
                    input-debounce="0"
                    :loading="CEPLoading"
                    @input="SelecionaEstado(true)"
                    :options="lookup_estado_natural"
                    option-value="cd_estado"
                    option-label="nm_estado"
                  >
                    <template v-slot:prepend>
                      <q-icon name="map" />
                    </template>
                  </q-select>
                  <!-- Estado EXT -->
                  <q-input
                    dense
                    v-if="tipo_mercado.cd_tipo_mercado === 2"
                    label="Estado"
                    class="umQuartoTela margin1"
                    v-model="natural_estado"
                    input-debounce="0"
                    :loading="CEPLoading"
                  >
                    <template v-slot:prepend>
                      <q-icon name="map" />
                    </template>
                  </q-input>
                  <q-select
                    dense
                    v-if="
                      natural_estado.cd_estado != undefined &&
                      tipo_pessoa.cd_tipo_pessoa == 2 &&
                      tipo_mercado.cd_tipo_mercado !== 2
                    "
                    label="Naturalidade - Cidade"
                    class="umQuartoTela margin1"
                    v-model="natural_cidade"
                    input-debounce="0"
                    :loading="carrega_cidade"
                    :options="lookup_cidade_filtrado"
                    option-value="cd_cidade"
                    option-label="nm_cidade"
                  >
                    <template v-slot:prepend>
                      <q-icon name="pin_drop" />
                    </template>
                  </q-select>
                  <q-select
                    dense
                    v-else
                    v-show="
                      natural_estado.cd_estado != undefined &&
                      tipo_mercado.cd_tipo_mercado !== 2
                    "
                    label="Cidade"
                    class="umQuartoTela margin1"
                    v-model="natural_cidade"
                    input-debounce="0"
                    :loading="carrega_cidade"
                    :options="lookup_cidade_filtrado"
                    option-value="cd_cidade"
                    option-label="nm_cidade"
                  >
                    <template v-slot:prepend>
                      <q-icon name="pin_drop" />
                    </template>
                  </q-select>
                  <!-- Cidade EXT -->
                  <q-input
                    dense
                    v-if="tipo_mercado.cd_tipo_mercado === 2"
                    label="Cidade"
                    class="umQuartoTela margin1"
                    v-model="natural_cidade"
                    input-debounce="0"
                    :loading="carrega_cidade"
                  >
                    <template v-slot:prepend>
                      <q-icon name="pin_drop" />
                    </template>
                  </q-input>

                  <q-select
                    dense
                    use-input
                    hide-selected
                    fill-input
                    @filter="filterRegiaoVenda"
                    class="umQuartoTela margin1"
                    label="Região"
                    v-model="regiao_venda"
                    input-debounce="0"
                    :options="opcoes_regiao_venda"
                    option-value="cd_regiao_venda"
                    option-label="nm_regiao_venda"
                  >
                    <template v-slot:prepend>
                      <q-icon name="map" />
                    </template>
                  </q-select>
                </div>

                <div class="row justify-around">
                  <q-select
                    dense
                    use-input
                    v-if="cd_empresa != 150"
                    hide-selected
                    fill-input
                    @filter="filterTipoDestinatario"
                    class="umTercoTela margin1"
                    label="Tipo de Destinatário"
                    :readonly="tipo_d"
                    v-model="tipo_destinatario"
                    input-debounce="0"
                    :options="opcoes_tipo_destinatario"
                    option-value="cd_tipo_destinatario"
                    option-label="nm_tipo_destinatario"
                  >
                    <template v-slot:prepend>
                      <q-icon name="receipt" />
                    </template>
                  </q-select>
                  <q-select
                    dense
                    use-input
                    hide-selected
                    fill-input
                    @filter="filterSegmentoOrganizacao"
                    class="umTercoTela margin1"
                    label="Segmento de Mercado"
                    v-model="segmento_organizacao"
                    input-debounce="0"
                    :options="opcoes_segmento_organizacao"
                    option-value="cd_segmento_mercado"
                    option-label="nm_segmento_mercado"
                  >
                    <template v-slot:prepend>
                      <q-icon name="store" />
                    </template>
                  </q-select>
                  <q-select
                    dense
                    class="umTercoTela margin1"
                    label="Grupo"
                    v-model="grupo"
                    input-debounce="0"
                    :options="lookup_cliente_grupo"
                    option-value="cd_cliente_grupo "
                    option-label="nm_cliente_grupo"
                  >
                    <template v-slot:prepend>
                      <q-icon name="group" />
                    </template>
                  </q-select>
                </div>

                <q-input
                  class="margin1"
                  v-model="ds_organizacao"
                  filled
                  type="textarea"
                  label="Perfil"
                />

                <!-- <q-card-actions align="right" class="bg-white text-primary"> -->
                <q-btn
                  rounded
                  class="margin1"
                  label="Salvar"
                  :disable="CEPLoading"
                  :loading="CEPLoading"
                  @click="oninsertOrganizacao"
                  color="primary"
                >
                  <q-tooltip> Salvar Organização </q-tooltip>
                </q-btn>
                <q-btn
                  flat
                  label="Cancelar"
                  rounded
                  class="margin1 float-right"
                  color="primary"
                  @click="onCancelaOrganizacao"
                />
                <!-- </q-card-actions> -->
              </div>
            </div>
          </transition>
          <!-- PESQUISA DE CONTATO -->
          <transition name="slide-fade">
            <div style="margin: 5px 0" v-if="GridContato">
              <div class="row">
                <q-space />
                <q-btn
                  color="primary"
                  icon="chevron_right"
                  rounded
                  label="Selecionar"
                  class="margin1"
                  @click="SelecionaGridContato()"
                >
                </q-btn>
              </div>
              <grid
                ref="gridContato"
                v-if="GridContato == true"
                :nm_json="consultaContatoNome"
                :cd_consulta="2"
                :cd_menuID="7488"
                :cd_apiID="767"
                :filterGrid="false"
                @emit-click="SelecionaGridContato()"
              />
            </div>
          </transition>
          <!-- CADASTRO DE CONTATO -->
          <transition name="slide-fade">
            <div
              v-if="popup_cadastro_contato"
              transition-show="slide-up"
              transition-hide="slide-down"
            >
              <div class="borda-bloco shadow-2 margin1">
                <div class="row text-h6 margin1" style="font-weight: normal">
                  Novo Contato
                  <q-space />
                  <q-btn
                    icon="close"
                    flat
                    round
                    dense
                    @click="popup_cadastro_contato = false"
                  />
                </div>
                <div class="row justify-around">
                  <q-input
                    dense
                    class="metadeTela margin1"
                    v-model="novo_contato"
                    type="text"
                    label="Nome Completo"
                  >
                    <template v-slot:prepend>
                      <q-icon name="person_add_alt_1" />
                    </template>
                  </q-input>
                  <q-input
                    dense
                    class="metadeTela margin1"
                    v-model="novo_email"
                    type="email"
                    label="E-Mail"
                  >
                    <template v-slot:prepend>
                      <q-icon name="email" />
                    </template>
                  </q-input>
                </div>

                <div class="row justify-around">
                  <q-input
                    dense
                    class="metadeTela margin1"
                    v-model="novo_telefone"
                    mask="(##) ####-####"
                    type="text"
                    label="Telefone"
                  >
                    <template v-slot:prepend>
                      <q-icon name="phone" />
                    </template>
                  </q-input>

                  <q-input
                    dense
                    class="metadeTela margin1"
                    v-model="novo_celular"
                    mask="(##) #####-####"
                    type="text"
                    label="Celular"
                  >
                    <template v-slot:prepend>
                      <q-icon name="phone_iphone" />
                    </template>
                  </q-input>
                </div>

                <q-btn
                  label="Salvar"
                  rounded
                  color="primary"
                  class="margin1"
                  @click="onInsereContato"
                />
                <q-btn
                  flat
                  class="margin1 float-right"
                  color="primary"
                  label="Cancelar"
                  rounded
                  @click="onCancelaContato"
                />
                <!-- </q-card-actions> -->
              </div>
            </div>
          </transition>
          <!-- CADASTRO DE CONTATO -->
        </div>
        <div class="borda-bloco shadow-2 margin1">
          <div class="row">
            <q-select
              dense
              use-input
              hide-selected
              fill-input
              input-debounce="0"
              @filter="filterTipoOportunidade"
              class="tres-partes margin1"
              v-model="tipo_oportunidade"
              option-value="cd_fonte_informacao"
              option-label="nm_fonte_informacao"
              :options="opcoes_tipo_oportunidade"
              label="Fonte de Informação"
              @blur="SetaTitulo()"
            >
              <template v-slot:prepend>
                <q-icon name="public" />
              </template>
            </q-select>

            <q-input
              dense
              class="tres-partes margin1"
              v-model="title"
              type="text"
              label="Oportunidade"
            >
              <template v-slot:prepend>
                <q-icon name="drive_file_rename_outline" />
              </template>
            </q-input>

            <q-input
              dense
              class="tres-partes margin1"
              @blur="FormataMoeda"
              v-model="valor"
              :readonly="ValorReadyOnly"
              type="text"
              label="Valor"
            >
              <template v-slot:prepend>
                <q-icon name="attach_money" />
              </template>
            </q-input>
          </div>

          <div class="row">
            <q-select
              dense
              use-input
              hide-selected
              fill-input
              input-debounce="0"
              @filter="filterTipoPedido"
              class="tres-partes margin1"
              option-value="cd_tipo_pedido"
              option-label="nm_tipo_pedido"
              v-model="nm_tipo_venda"
              :options="opcoes_tipo_pedido"
              label="Tipo de Venda"
            >
              <template v-slot:prepend>
                <q-icon name="format_list_numbered" />
              </template>
            </q-select>

            <q-input
              dense
              v-model="dt_retorno"
              class="tres-partes margin1"
              mask="##/##/####"
              label="Data Retorno"
              icon="schedule"
              @blur="DataRetorno(dt_retorno)"
            >
              <template v-slot:append>
                <q-btn
                  icon="event"
                  color="primary"
                  round
                  class="cursor-pointer"
                  size="sm"
                >
                  <q-popup-proxy
                    ref="qDateProxy"
                    cover
                    transition-show="scale"
                    transition-hide="scale"
                  >
                    <q-date
                      v-model="dt_picker_retorno"
                      @input="DataRetorno(dt_picker_retorno)"
                      class="qdate"
                    >
                    </q-date>
                    <div class="row items-center justify-end">
                      <q-btn
                        v-close-popup
                        rounded
                        color="primary"
                        icon="close"
                        label="Fechar"
                      />
                    </div>
                  </q-popup-proxy>
                </q-btn>
              </template>
              <template v-slot:prepend>
                <q-icon name="calendar_today" />
              </template>
            </q-input>

            <q-input
              dense
              v-model="hr_retorno"
              class="tres-partes margin1"
              mask="##:##"
              label="Horário Retorno"
              icon="history"
            >
              <template v-slot:append>
                <q-btn
                  icon="history"
                  color="primary"
                  round
                  class="cursor-pointer"
                  size="sm"
                >
                  <q-popup-proxy
                    ref="qDateProxy"
                    cover
                    transition-show="scale"
                    transition-hide="scale"
                  >
                    <q-time
                      v-model="hr_retorno"
                      mask="HH:mm"
                      color="primary"
                      class="qdate"
                    >
                    </q-time>
                    <div class="row items-center justify-end">
                      <q-btn
                        v-close-popup
                        rounded
                        color="primary"
                        icon="close"
                        label="Fechar"
                      />
                    </div>
                  </q-popup-proxy>
                </q-btn>
              </template>
              <template v-slot:prepend>
                <q-icon name="history" />
              </template>
            </q-input>

            <q-input
              dense
              v-model="dt_previsto_fechamento"
              class="tres-partes margin1"
              mask="##/##/####"
              label="Previsão (Fechamento)"
              @blur="Data(dt_picker)"
              icon="schedule"
            >
              <template v-slot:append>
                <q-btn
                  icon="event"
                  color="primary"
                  round
                  class="cursor-pointer"
                  size="sm"
                >
                  <q-popup-proxy
                    ref="qDateProxy"
                    cover
                    transition-show="scale"
                    transition-hide="scale"
                  >
                    <q-date
                      v-model="dt_picker"
                      @input="Data(dt_picker)"
                      class="qdate"
                    >
                    </q-date>
                    <div class="row items-center justify-end">
                      <q-btn
                        v-close-popup
                        rounded
                        color="primary"
                        icon="close"
                        label="Fechar"
                      />
                    </div>
                  </q-popup-proxy>
                </q-btn>
              </template>
              <template v-slot:prepend>
                <q-icon name="calendar_today" />
              </template>
            </q-input>
            <q-select
              dense
              use-input
              hide-selected
              fill-input
              class="tres-partes margin1"
              label="Moeda"
              v-model="moeda"
              input-debounce="0"
              :options="dataset_lookup_moeda"
              option-value="cd_moeda"
              option-label="nm_moeda"
              @input="OnMoeda()"
            >
              <template v-slot:prepend>
                <q-icon name="attach_money" />
              </template>
            </q-select>
            <q-select
              dense
              use-input
              hide-selected
              fill-input
              class="tres-partes margin1"
              label="País"
              v-model="pais_oportunidade"
              input-debounce="0"
              :options="lookup_pais"
              option-value="cd_pais"
              option-label="nm_pais"
              @input="OnPais()"
            >
              <template v-slot:prepend>
                <q-icon name="public" />
              </template>
            </q-select>
          </div>
        </div>

        <!--CLASSIFICAÇÃO AQUI-->
        <div class="row">
          <template v-if="cd_empresa != 150">
            <div class="margin1 col" style="max-width: 700px">
              <q-input
                v-model="ds_historico"
                filled
                autogrow
                type="text"
                label="Observações"
              >
                <template v-slot:prepend>
                  <transition name="slide-fade">
                    <q-badge
                      color="primary"
                      text-color="white"
                      v-show="qtd_historico_timeline > 0"
                      :label="qtd_historico_timeline"
                    />
                  </transition>
                </template>
              </q-input>
            </div>
          </template>

          <div class="margin1 col classificacao">
            <p><b>Classificação</b></p>
            <q-rating v-model="ratingModel" size="2.0em" color="primary" />
          </div>
        </div>

        <!--HISTÓRICO-->
        <q-expansion-item
          v-if="up_cd_movimento && atualiza_Historico"
          icon="history"
          v-model="Exp_hist_cliente_org"
          label="Histórico da Organização/Cliente"
          class="shadow-1 overflow-hidden margin1"
          style="border-radius: 20px; height: auto"
          header-class="bg-primary text-white item-center text-h6"
          expand-icon-class="text-white"
        >
          <div v-if="!!this.timelineI.cd_movimento">
            <timeline
              class="margin1"
              :nm_json="this.timelineI"
              :cd_apiID="this.api_timeline"
              :cd_consulta="1"
              :corID="'primary'"
              :inputID="true"
              :cd_apiInput="'737/1119'"
              :cd_parametroID="this.up_cd_movimento"
              ref="timeline"
            />
          </div>
        </q-expansion-item>
        <!--<q-separator/> mostraProposta-->
      </q-expansion-item>

      <q-expansion-item
        v-model="Expansion"
        v-if="cd_empresa != 150"
        class="shadow-1 overflow-hidden bg-primary margin1"
        style="border-radius: 20px; height: auto"
        icon="shopping_cart"
        expand-icon-class="text-white"
        :label="'Produtos - ' + total_prod + ' (' + carrinho.length + ')'"
        header-class="row text-white item-center text-h6"
      >
        <q-card>
          <div class="row">
            <div class="margin1" style="font-weight: bold">
              {{ "Simples" }}
              <q-toggle
                v-model="tipo_pesquisa_produto"
                :false-value="'N'"
                :true-value="'S'"
                color="primary"
              />{{ "Completa" }}
            </div>
          </div>

          <div class="margin1 shadow-2 text-black">
            <transition name="slide-fade">
              <div v-if="tipo_pesquisa_produto == 'S'" class="col">
                <div class="row">
                  <q-select
                    dense
                    color="primary"
                    class="margin1 tres-tela media"
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
                    color="primary"
                    class="margin1 tres-tela media"
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
                    color="primary"
                    class="margin1 tres-tela media"
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

                <div class="row margin1">
                  <q-input
                    dense
                    color="primary"
                    class="margin1 tres-tela media"
                    v-model="cd_mascara_produto"
                    label="Máscara"
                    @input="InputProduto(3)"
                  >
                    <template v-slot:prepend>
                      <q-icon name="masks" />
                    </template>
                  </q-input>

                  <q-input
                    dense
                    color="primary"
                    class="margin1 tres-tela media"
                    v-model="nm_fantasia_produto"
                    label="Fantasia"
                    @input="InputProduto(2)"
                  >
                    <template v-slot:prepend>
                      <q-icon name="face_retouching_natural" />
                    </template>
                  </q-input>

                  <q-input
                    dense
                    color="primary"
                    class="margin1 tres-tela media"
                    v-model="nm_produto"
                    label="Produto"
                    @input="InputProduto(1)"
                  >
                    <template v-slot:prepend>
                      <q-icon name="inventory_2" />
                    </template>
                    <template v-slot:append>
                      <q-btn
                        size="sm"
                        round
                        color="primary"
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
              </div>
            </transition>

            <q-input
              color="primary"
              class="margin1 inputProduto"
              v-if="tipo_pesquisa_produto == 'N'"
              v-model="nm_produto"
              label="Produto"
              @input="InputProduto(1)"
            >
              <template v-slot:prepend>
                <q-icon name="inventory_2" />
              </template>
              <template v-slot:append>
                <q-btn
                  size="sm"
                  round
                  color="primary"
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
          <transition name="slide-fade">
            <div
              v-show="
                resultado_categoria.length > 0 && grid_card == false && codigo
              "
            >
              <div class="row items-center">
                <q-space />
                <q-btn
                  rounded
                  class="margin1"
                  color="primary"
                  label="Inserir"
                  icon="input"
                  @click="ListaCarrinho(linha_selecionada)"
                />
              </div>

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
                :autoNavigateToFocusedRow="false"
                :cacheEnable="false"
                @focused-row-changed="linhacategoria($event)"
                @row-dbl-click="ListaCarrinho($event.data)"
              >
                <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
                <DxExport :enabled="true" />
                <DxPager
                  :show-page-size-selector="true"
                  :allowed-page-sizes="[10, 20, 50, 100]"
                  :show-info="true"
                />

                <DxPaging :enable="true" :page-size="10" />
                <DxSearchPanel
                  :visible="true"
                  :width="300"
                  placeholder="Procurar..."
                />
              </DxDataGrid>
            </div>
          </transition>
          <DxScrollView
            v-show="resultado_categoria.length > 0 && grid_card == true"
            id="scrollview"
            show-scrollbar="hover"
            class="row justify-center"
          >
            <transition name="slide-fade">
              <div v-if="codigo">
                <div
                  v-for="(e, index) in resultado_categoria.length"
                  :key="index"
                  class="list margin5 text-center"
                >
                  <q-card class="margin5 card">
                    <div class="row text-bold items-center">
                      <div class="col">
                        {{ resultado_categoria[e - 1].Produto }}
                      </div>
                      <div class="col-2 items-end">
                        <q-btn
                          round
                          style="float: right; margin: 2px"
                          color="primary"
                          size="sm"
                          icon="add"
                          @click="ListaCarrinho(resultado_categoria[e - 1])"
                        />
                      </div>
                    </div>
                    <q-separator />
                    <div class="card1">
                      <div class="row margin5">
                        {{
                          "Categoria: " + resultado_categoria[e - 1].Categoria
                        }}
                      </div>
                      <div class="row margin5">
                        {{ "Fantasia: " + resultado_categoria[e - 1].Fantasia }}
                      </div>
                      <div class="row margin5">
                        {{ "Grupo: " + resultado_categoria[e - 1].Grupo }}
                      </div>
                      <div class="row margin5">
                        {{ "Marca: " + resultado_categoria[e - 1].Marca }}
                      </div>
                      <div class="row margin5">
                        {{ "Máscara: " + resultado_categoria[e - 1].Máscara }}
                      </div>
                      <div class="row margin5">
                        {{
                          "Unidade de Medida: " + resultado_categoria[e - 1].Un
                        }}
                      </div>
                      <div class="row margin5">
                        <q-input
                          borderless
                          class="margin1"
                          color="primary"
                          type="number"
                          :prefix="'R$'"
                          :min="1"
                          v-model="resultado_categoria[e - 1].Valor"
                          label="Valor"
                        >
                        </q-input>
                      </div>
                      <q-input
                        borderless
                        class="margin1"
                        color="primary"
                        type="number"
                        :min="1"
                        v-model="resultado_categoria[e - 1].Quantidade"
                        label="Quantidade"
                      >
                      </q-input>
                    </div>
                  </q-card>
                </div>
              </div>
            </transition>
          </DxScrollView>
          <div v-if="codigo == false">
            <p style="text-align: center">Nenhum produto encontrado!</p>
          </div>
          <!--</q-expansion-item>-->
          <!---CARRINHO DE PRODUTOS--->
          <div class="row">
            <div class="row margin1 text-h6">Itens</div>
            <DxDataGrid
              v-if="carrinho"
              class="margin1 shadow-2"
              style="width: 100%"
              id="grid_carrinho"
              :ref="gridRefNameCarrinho"
              key-expr="cd_controle"
              :columns="colunas"
              :data-source="carrinho"
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
              :autoNavigateToFocusedRow="false"
              @row-removed="ExcluirProduto"
              :cacheEnable="false"
              @saved="onCalculaTotal()"
              @row-updated="onCalculaTotal"
              @focused-row-changed="onFocusedRowChangedCarrinho($event)"
            >
              <DxEditing
                :allow-updating="true"
                :allow-adding="false"
                :allow-deleting="true"
                :select-text-on-edit-start="true"
                mode="form"
              >
                <DxForm>
                  <DxGroupItem caption="Personal Data">
                    <DxSimpleItem data-field="Codigo" />
                    <DxSimpleItem data-field="Fantasia" />
                    <DxSimpleItem data-field="Produto" />
                    <DxSimpleItem
                      data-field="Duties"
                      editor-type="dxTextArea"
                    />
                  </DxGroupItem>
                  <DxGroupItem caption="Contacts">
                    <DxSimpleItem data-field="Email" />
                    <DxSimpleItem data-field="Skype" />
                  </DxGroupItem>
                </DxForm>
              </DxEditing>
              <DxPaging :enable="true" :page-size="10" />
            </DxDataGrid>
          </div>
        </q-card>
      </q-expansion-item>

      <q-expansion-item
        v-model="Expansion"
        v-if="cd_empresa != 150"
        class="shadow-1 overflow-hidden bg-primary margin1"
        style="border-radius: 20px; height: auto"
        icon="engineering"
        expand-icon-class="text-white"
        :label="
          'Serviços - ' + total_servicos + ' (' + lista_servicos.length + ')'
        "
        header-class="row text-white item-center text-h6"
      >
        <q-card>
          <div>
            <ListagemPadrao
              cd_apiID="919/1429"
              :cd_menuID="7798"
              nm_atributo="Servico"
              @attLista="attListaServicos"
              :lista="lista_servicos"
              :ic_mostra_titulo="false"
              :ic_tipo_pesquisa="false"
              :edita_lista="editing_list"
            ></ListagemPadrao>
          </div>
        </q-card>
      </q-expansion-item>

      <q-card-actions class="text-teal" style="justify-content: space-between">
        <div style="align-items: start">
          <q-btn
            rounded
            label="Transferir"
            color="primary"
            class="margin1"
            icon="change_circle"
            v-if="!up_cd_movimento == 0"
            @click="onTransferir"
          >
            <q-tooltip> Transferir Oportunidade </q-tooltip>
          </q-btn>

          <q-btn
            rounded
            label="Gerar Proposta"
            color="primary"
            class="margin1"
            v-close-popup
            icon="description"
            v-if="!up_cd_movimento == 0"
            @click="geraProposta()"
          >
            <q-tooltip> Gerar Proposta </q-tooltip>
          </q-btn>

          <q-btn
            rounded
            v-if="ic_salvar"
            label="Salvar"
            color="primary"
            class="margin1"
            icon="save"
            @click="onInsertOportunidade"
          >
            <q-tooltip> Salvar Oportunidade </q-tooltip>
          </q-btn>

          <q-btn
            rounded
            v-if="!ic_salvar"
            label="Salvar"
            color="primary"
            class="margin1"
            icon="save"
            @click="onEditarOportunidade"
          >
            <q-tooltip> Salvar Oportunidade </q-tooltip>
          </q-btn>
        </div>
        <div style="align-items: end">
          <q-btn
            flat
            rounded
            label="Excluir"
            color="primary"
            class="margin1"
            icon="delete"
            v-if="!up_cd_movimento == 0"
            @click="confirma_exclusao"
          >
            <q-tooltip> Excluir Oportunidade </q-tooltip>
          </q-btn>
          <q-btn
            flat
            label="Fechar"
            rounded
            color="primary"
            class="margin1"
            icon="close"
            v-close-popup
          />
        </div>
      </q-card-actions>

      <q-expansion-item
        v-show="cd_empresa == 150 && timelineI.cd_movimento > 0"
        icon="description"
        label="Histórico"
        default-opened
        v-model="Expansion"
        class="shadow-1 overflow-hidden margin1"
        style="border-radius: 20px; height: auto"
        header-class="bg-primary text-white item-center text-h6"
        expand-icon-class="text-white"
      >
        <div>
          <timeline
            class="margin1"
            v-show="cd_empresa == 150 && timelineI.cd_movimento > 0"
            :cd_apiInput="'737/1119'"
            ref="timeline_intermedium"
            :inputID="true"
            :nm_json="timelineI"
            :cd_consulta="2"
            :cd_parametroID="0"
            cd_apiID="728/1101"
          />
        </div>
      </q-expansion-item>

      <q-page-sticky position="bottom-right" :offset="[18, 18]">
        <q-fab
          style="padding: 76%"
          color="primary"
          icon="keyboard_return"
          direction="left"
        >
          <q-fab-action
            label="Excluir"
            color="primary"
            icon="delete"
            v-if="!up_cd_movimento == 0"
            @click="confirma_exclusao"
          >
            <q-tooltip> Excluir Oportunidade </q-tooltip>
          </q-fab-action>

          <q-fab-action
            v-if="ic_salvar"
            label="Salvar"
            color="primary"
            icon="save"
            @click="onInsertOportunidade"
          >
            <q-tooltip> Salvar Oportunidade </q-tooltip>
          </q-fab-action>

          <q-fab-action
            v-if="!ic_salvar"
            label="Salvar"
            color="primary"
            icon="save"
            @click="onEditarOportunidade"
          >
            <q-tooltip> Salvar Oportunidade </q-tooltip>
          </q-fab-action>

          <q-fab-action
            label="Gerar Proposta"
            color="primary"
            v-close-popup
            icon="description"
            v-if="!up_cd_movimento == 0"
            @click="geraProposta()"
          >
            <q-tooltip> Gerar Proposta </q-tooltip>
          </q-fab-action>

          <q-fab-action
            label="Transferir"
            color="primary"
            icon="change_circle"
            v-if="!up_cd_movimento == 0"
            @click="onTransferir"
          >
            <q-tooltip> Transferir Oportunidade </q-tooltip>
          </q-fab-action>
        </q-fab>
      </q-page-sticky>
    </q-layout>
    <!---------EXCLUIR OPORTUNIDADE---------------------------------------------------->
    <q-dialog
      v-model="popup_excluir"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card style="width: 700px; max-width: 80vw">
        <q-card-section>
          <div class="text-h6" style="font-weight: bold">
            Deseja realmente excluir a Oportunidade
            {{ `${up_cd_movimento} ? ` }}
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right" class="bg-white text-teal">
          <q-btn
            flat
            label="Confirmar"
            @click="onExcluirOportunidade"
            v-close-popup
          />
          <q-btn flat label="Cancelar" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!---------INSERIR EMPRESA---------------------------------------------------->
    <div
      v-show="false"
      style="max-width: 80vw"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <div style="width: 700px; max-width: 80vw">
        <div class="row items-center q-pb-none margin1">
          <div class="text-h6">Nova {{ nm_org }}</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </div>

        <q-separator />

        <q-input
          item-aligned
          class="espaco-interno"
          v-model="nova_organizacao"
          type="text"
          label="Nome"
        >
          <template v-slot:prepend>
            <q-icon name="corporate_fare" />
          </template>
        </q-input>

        <q-input
          item-aligned
          class="espaco-interno"
          v-model="nova_organizacao_fantasia"
          type="text"
          :rules="[(val) => val.length > 0 || 'Obrigatório']"
          label="Nome Fantasia"
        >
          <template v-slot:prepend>
            <q-icon name="badge" />
          </template>
        </q-input>

        <q-input
          item-aligned
          class="espaco-interno"
          v-model="cd_site"
          type="text"
          label="Site"
        >
          <template v-slot:prepend>
            <q-icon name="language" />
          </template>
        </q-input>

        <q-input
          item-aligned
          class="espaco-interno"
          v-model="nm_email_organizacao"
          type="text"
          label="E-mail"
          @blur="PesquisaOrganizacao(1)"
        >
          <template v-slot:prepend>
            <q-icon name="mail" />
          </template>
        </q-input>

        <div class="row">
          <div class="col">
            <q-input
              item-aligned
              class="espaco-interno"
              v-model="novo_telefone_org"
              maxlength="15"
              type="text"
              label="Telefone"
              @input="MaskTelefone(novo_telefone_org)"
            >
              <template v-slot:prepend>
                <q-icon name="call" />
              </template>
            </q-input>
          </div>

          <div class="col">
            <q-select
              use-input
              hide-selected
              fill-input
              @filter="filterTipoPessoa"
              class="select-funil"
              label="Tipo Pessoa"
              v-model="tipo_pessoa"
              input-debounce="0"
              :options="opcoes_tipo_pessoa"
              option-value="cd_tipo_pessoa"
              option-label="nm_tipo_pessoa"
              item-aligned
            >
              <template v-slot:prepend>
                <q-icon name="groups" />
              </template>
            </q-select>
          </div>
        </div>

        <div class="row">
          <div class="col">
            <q-select
              use-input
              hide-selected
              fill-input
              @filter="filterRegiaoVenda"
              class="select-funil"
              label="Região"
              v-model="regiao_venda"
              input-debounce="0"
              :options="opcoes_regiao_venda"
              option-value="cd_regiao_venda"
              option-label="nm_regiao_venda"
              item-aligned
            >
              <template v-slot:prepend>
                <q-icon name="map" />
              </template>
            </q-select>
          </div>
          <div class="col">
            <q-select
              use-input
              v-if="cd_empresa != 150"
              hide-selected
              fill-input
              @filter="filterTipoDestinatario"
              class="select-funil"
              label="Tipo de Destinatário"
              :readonly="tipo_d"
              v-model="tipo_destinatario"
              input-debounce="0"
              :options="opcoes_tipo_destinatario"
              option-value="cd_tipo_destinatario"
              option-label="nm_tipo_destinatario"
              item-aligned
            >
              <template v-slot:prepend>
                <q-icon name="receipt" />
              </template>
            </q-select>
          </div>
        </div>

        <q-select
          use-input
          hide-selected
          fill-input
          @filter="filterSegmentoOrganizacao"
          class="select-funil"
          label="Segmento de Mercado"
          v-model="segmento_organizacao"
          input-debounce="0"
          :options="opcoes_segmento_organizacao"
          option-value="cd_segmento_mercado"
          option-label="nm_segmento_mercado"
          item-aligned
        >
          <template v-slot:prepend>
            <q-icon name="store" />
          </template>
        </q-select>

        <q-input
          class="margin1"
          v-model="ds_organizacao"
          filled
          type="textarea"
          label="Perfil"
        />

        <!-- <q-card-actions align="right" class="bg-white text-primary"> -->
        <q-btn flat label="Salvar" @click="oninsertOrganizacao">
          <q-tooltip> Salvar Organização </q-tooltip>
        </q-btn>
        <q-btn
          flat
          label="Cancelar"
          @click="onCancelaOrganizacao"
          v-close-popup
        />
        <!-- </q-card-actions> -->
      </div>
    </div>
    <!-----TRANSFERIR OPORTUNIDADE------------------------------------------->
    <q-dialog
      v-model="popup_transferir"
      style="max-width: 80vw"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card style="width: 700px; max-width: 80vw">
        <q-card-section>
          <div class="text-h6" style="font-weight: bold">
            Transferir Oportunidade
          </div>
        </q-card-section>

        <q-separator />

        <q-select
          class="select-funil"
          label="Destinatário"
          v-model="vendedor"
          input-debounce="0"
          :options="lookup_vendedor"
          option-value="cd_usuario"
          option-label="nm_usuario"
          item-aligned
        >
          <template v-slot:prepend>
            <q-icon name="format_list_bulleted" />
          </template>
        </q-select>

        <q-input
          item-aligned
          class="espaco-interno"
          v-model="ds_motivo_transferencia"
          type="text"
          :rules="[(val) => val.length > 0 || 'Obrigatório']"
          label="Motivo da transferência"
        >
          <template v-slot:prepend>
            <q-icon name="change_circle" />
          </template>
        </q-input>

        <q-card-actions class="bg-white" style="justify-content: space-between">
          <q-btn
            color="primary"
            class="margin1"
            rounded
            label="Confirmar"
            @click="onTransferirOportunidade"
          />
          <q-btn
            flat
            color="primary"
            label="Cancelar"
            class="margin1"
            @click="onTransferirOportunidadeCancela"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!--------CARREGANDO---------------------------------------------------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando :mensagemID="msgDinamica"></carregando>
    </q-dialog>
    <!------------------------------------------------------------------------------------>
    <q-dialog v-model="popupEncontrato" full-width>
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Organizações Encontradas</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section>
          <DxDataGrid
            :data-source="pesquisa_site"
            :show-borders="true"
            key-expr="cd_controle"
            :focused-row-enabled="true"
            :column-auto-width="true"
            :column-hiding-enabled="false"
            :remote-operations="false"
            :word-wrap-enabled="false"
            :allow-column-reordering="true"
            :allow-column-resizing="true"
            :row-alternation-enabled="true"
            :repaint-changes-only="true"
            :autoNavigateToFocusedRow="false"
            :cacheEnable="false"
            @focused-row-changed="onFocusedRowChanged"
            >>
            <DxColumn data-field="nm_organizacao" caption="Nome" />
            <DxColumn data-field="nm_fantasia" caption="Nome Fantasia" />
            <DxColumn data-field="nm_regiao_venda" caption="Região" />
            <DxColumn data-field="nm_segmento_mercado" caption="Segmento" />
            <DxColumn data-field="nm_tipo_pessoa" caption="Tipo Pessoa" />
          </DxDataGrid>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn
            flat
            label="Selecionar"
            color="positive"
            v-close-popup
            @click="ContinuaPesquisa()"
          />
          <q-btn flat label="Novo Cadastro" color="primary" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------------------------------>
  </div>
</template>

<script>
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import Procedimento from "../http/procedimento";
import Incluir from "../http/incluir_registro";
import Lookup from "../http/lookup";
import select from "../http/select";
import Menu from "../http/menu";
import { DxScrollView } from "devextreme-vue/scroll-view";
import formataData from "../http/formataData";
import grid from "../views/grid";
import carregando from "../components/carregando.vue";
import funcao from "../http/funcoes-padroes";
import { EventBus } from "../EventBus";

import {
  DxDataGrid,
  DxColumn,
  DxGroupPanel,
  DxSearchPanel,
  DxPaging,
  DxEditing,
  DxExport,
  DxPager,
} from "devextreme-vue/data-grid";
import { DxForm, DxSimpleItem, DxGroupItem } from "devextreme-vue/form";
import Grid from "./grid.vue";

export default {
  props: {
    oportunidade_up: {
      type: Object,
      default() {
        return {};
      },
    },
  },

  name: "oportunidade",
  title: "Oportunidade",

  data() {
    return {
      qtd_historico_timeline: 0,
      contact_pesq: "",
      business: "",
      title: "",
      valor: "",
      cd_cnpj: "",
      cep: "",
      consultaContatoNome: {},
      GridContato: false,
      dataSourceCNPJ: [],
      validouCPF: false,
      ValorReadyOnly: false,
      AtualizaProduto: 0,
      pesquisa_produto: true,
      CEPLoading: false,
      resultado: "",
      cd_modulo: localStorage.cd_modulo,
      api: "538/745", //Procedimento 1414 - pr_egisnet_cadastra_informacao_pipeline
      api_timeline: "674/996", //Procedimento 1521 - pr_historico_oportunidade
      atualiza_Historico: true,
      nm_departamento: "",
      cd_site: "",
      regiao_venda: "",
      dt_op: "",
      loading_org: false,
      ic_salvar: true,
      dt_previsto_fechamento: "",
      dt_retorno: "",
      novo_telefone_org: "",
      ratingModel: 0,
      dados: {},
      cd_user: 0,
      popup_transferir: false,
      popup_pesquisa_cliente: false,
      tipo_d: false,
      popup_excluir: false,
      hr_retorno: "",
      pesquisa_contato: {},
      popup_cadastro_contato: false,
      novo_contato: "",
      novo_celular: "",
      novo_telefone: "",
      novo_email: "",
      ratingContato: 0,
      pesquisa_business: {},
      popup_insere_empresa: false,
      popupEncontrato: false,
      nova_organizacao: "",
      nova_organizacao_fantasia: "",
      dataset_tipo_oportunidade: [],
      dataset_lookup_destinatario: [],
      linha: {},
      categoria: "",
      carrinho: [],
      carrinho_json: [],
      GridOrg: false,
      tipo_destinatario: "",
      codigo: null,
      linha_selecionada: "",
      cd_cliente: 0,
      linha_contato: {},
      dataset_lookup_tipo_pessoa: [],
      tipo_pessoa: "",
      dataset_lookup_tipo_mercado: [],
      tipo_mercado: "",
      pais_oportunidade: "",
      dataset_lookup_moeda: [],
      moeda: "",
      dataset_lookup_regiao: [],
      regiao: "",
      grid_card: false,
      resultado_categoria: [],
      nm_produto: "",
      dataset_lookup_segmento: [],
      nm_org: "",
      segmento_organizacao: "",
      dataset_lookup_grupo: [],
      dt_picker: "",
      dt_picker_retorno: "",
      nm_email_contato_selec: "",
      lookup_dataset_tipo_pedido: [],
      lookup_dataset_parametro_comercial: [],
      lookup_dataset_parametro_crm: [],
      lookup_dataset_unidade_medida: [],
      lookup_um: {},
      nm_tipo_venda: "",
      org: "",
      produto: "",
      tipo_oportunidade: "",
      ic_cadastro_prod_oportunidade: "",
      gridRefNameCarrinho: "grid_carrinho",
      editing_list: {
        mode: "batch",
        allowUpdating: true,
        allowAdding: false,
        allowDeleting: true,
        colunas: [
          "qt_servico",
          "vl_servico",
          "cd_mascara_servico",
          "nm_servico",
          "ds_servico",
          "pc_iss_servico",
          "pc_irrf_servico",
          "pc_comissao_servico",
          "qt_dia_entrega",
        ],
      },
      timelineI: {
        ic_parametro: 2,
        cd_form: 1, //oportunidade
        cd_movimento: 0,
        cd_empresa: 0,
        dt_inicial: "",
        dt_final: "",
        cd_usuario: localStorage.cd_usuario,
      },
      load: false,
      vendedor: "",
      mostraProposta: false,
      pesquisa_email: [],
      hoje: new Date().toLocaleDateString(),
      msgDinamica: "Aguarde...",
      nm_json: {},
      columns: [],
      colunas: [],
      total: [],
      grupo: "",
      dataset_lookup_marca: [],
      tipo_pesquisa_produto: "N",
      cd_empresa: localStorage.cd_empresa,
      cd_movimento: 0,
      lista_servicos: [],
      total_servicos: 0,
      total_prod: 0,
      up_cd_movimento: null,
      up_cd_oportunidade: null,
      pesquisa_site: [],
      carrega_cidade: false,
      novo_cadastro: false,
      ds_historico: "",
      cd_organizacao: 0,
      ds_organizacao: "",
      ds_motivo_transferencia: "",
      cd_mascara_produto: "",
      marca: "",
      nm_vendedor: "",
      dados_lookup_organizacao: [],
      dataset_lookup_organizacao: [],
      Expansion: true,
      Exp_hist_cliente_org: true,
      gridRefName: "grid",
      dados_nm_organizacao: [],
      dados_lookup_organizacao_contato: [],
      nm_fantasia_produto: "",
      dataset_lookup_organizacao_contato: [],
      nm_email_organizacao: "",
      grid_produto: null,
      dataset_lookup_regiao_venda: [],
      popup_pesquisa_filtro: false,
      lookup_cliente_grupo: [],
      consultaOrganizacao: {
        cd_parametro: 19,
        nm_org: "",
        cd_usuario: localStorage.cd_usuario,
      },
      nm_endereco: "",
      nm_numero_endereco: "",
      nm_complemento_endereco: "",
      bairro: "",
      natural_estado: [],
      natural_cidade: [],
      pais: [],
      lookup_pais: [],
      lookup_estado_natural: [],
      lookup_cidade_filtrado: [],
      dados_nm_organizacao_contato: [],
      opcoes_organizacao: [],
      opcoes_tipo_oportunidade: [],
      opcoes_tipo_pedido: [],
      opcoes_tipo_pessoa: [],
      opcoes_regiao_venda: [],
      opcoes_tipo_destinatario: [],
      opcoes_segmento_organizacao: [],
      lookup_vendedor: [],
    };
  },

  async created() {
    localStorage.titulo_menu_watch = "Oportunidade";
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    if (this.cd_empresa == 150) {
      this.nm_org = "Empresa";
      this.tipo_d = true;
    } else {
      this.nm_org = "Organização";
      this.tipo_d = false;
    }
    try {
      this.load = true;
      ////Parâmetros CRM
      let lookup_dados_parametro_crm = await Lookup.montarSelect(
        this.cd_empresa,
        1765
      );
      lookup_dados_parametro_crm.dataset
        ? ([this.lookup_dataset_parametro_crm] = JSON.parse(
            JSON.parse(JSON.stringify(lookup_dados_parametro_crm.dataset))
          ))
        : (this.lookup_dataset_parametro_crm = []);
      ////Parâmetros Comerciais
      let lookup_dados_parametro_comercial = await Lookup.montarSelect(
        this.cd_empresa,
        866
      );
      this.lookup_dataset_parametro_comercial = JSON.parse(
        JSON.parse(JSON.stringify(lookup_dados_parametro_comercial.dataset))
      );
      this.ic_cadastro_prod_oportunidade =
        this.lookup_dataset_parametro_comercial[0].ic_cadastro_prod_oportunidade;
      this.ic_cadastro_prod_oportunidade == undefined
        ? (this.ic_cadastro_prod_oportunidade = "S")
        : "";
      if (this.ic_cadastro_prod_oportunidade === "S") {
        this.ValorReadyOnly = true;
        let lookup_dados_unidade_medida = await Lookup.montarSelect(
          this.cd_empresa,
          138
        );
        this.lookup_dataset_unidade_medida = JSON.parse(
          JSON.parse(JSON.stringify(lookup_dados_unidade_medida.dataset))
        );
      } else {
        this.ValorReadyOnly = false;
      }

      this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();
      this.dt_final = new Date(localStorage.dt_final).toLocaleDateString();
      var h = new Date().toLocaleTimeString();
      this.hora = h.substring(0, 5);
      this.usuario = localStorage.cd_usuario;
      this.nm_vendedor = localStorage.login;
      this.up_cd_movimento = "";
      this.up_cd_movimento = this.oportunidade_up.cd_movimento;
      this.up_cd_oportunidade = this.oportunidade_up.cd_documento;
      this.timelineI.cd_empresa = this.cd_empresa;
      this.timelineI.dt_inicial = localStorage.dt_inicial;
      this.timelineI.dt_final = localStorage.dt_final;
      this.timelineI.cd_movimento = this.up_cd_movimento;

      //let historico = await Incluir.incluirRegistro('674/996',this.up_cd_movimento); CONSUMIR API E MOSTRAR HISTORICO

      if (!this.up_cd_movimento == 0 || this.ic_salvar == false) {
        this.alteracao = false;
        this.ic_salvar = false;
      } else {
        this.alteracao = true;
        this.ic_salvar = true;
      }
      /*-----------------------------------------------------------------------------*/
      /*--- MOEDA ---*/
      if (
        this.dataset_lookup_moeda !== null &&
        this.dataset_lookup_moeda.length == 0
      ) {
        let dados_lookup_moeda = await Lookup.montarSelect(
          this.cd_empresa,
          175
        );
        this.dataset_lookup_moeda = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_moeda.dataset))
        );
      }
      /*--- PAIS ---*/
      if (this.lookup_pais !== null && this.lookup_pais.length == 0) {
        let dados_lookup_pais = await Lookup.montarSelect(this.cd_empresa, 492);
        this.lookup_pais = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_pais.dataset))
        );
      }
      /*---ORGANIZACAO CONTATO---*/

      this.dados_lookup_organizacao_contato = await Lookup.montarSelect(
        this.cd_empresa,
        5322
      );
      this.dataset_lookup_organizacao_contato = JSON.parse(
        JSON.parse(
          JSON.stringify(this.dados_lookup_organizacao_contato.dataset)
        )
      );
      if (this.dataset_lookup_organizacao_contato != null) {
        for (
          let i = 0;
          i < this.dataset_lookup_organizacao_contato.length;
          i++
        ) {
          this.dados_nm_organizacao_contato.push(
            this.dataset_lookup_organizacao_contato[i].nm_contato_crm
          );
        }
      }
      /*-----------------------------------------------------------------------------*/
      /*---DESTINATARIO---*/
      let dados_lookup_destinatario = await Lookup.montarSelect(
        this.cd_empresa,
        660
      );
      this.dataset_lookup_destinatario = JSON.parse(
        JSON.parse(JSON.stringify(dados_lookup_destinatario.dataset))
      );
      /*-----------------------------------------------------------------------------*/

      /*---TIPO OPORTUNIDADE---*/
      let dados_tipo_oportunidade = await Lookup.montarSelect(
        this.cd_empresa,
        112
      );
      this.dataset_tipo_oportunidade = JSON.parse(
        JSON.parse(JSON.stringify(dados_tipo_oportunidade.dataset))
      );
      /*---PARAMETROS COMERCIAIS---*/
      /*-----------------------------------------------------------------------------*/
      /*---TIPO PEDIDO---*/
      let lookup_dados_tipo_pedido = await Lookup.montarSelect(
        this.cd_empresa,
        202
      );
      this.lookup_dataset_tipo_pedido = JSON.parse(
        JSON.parse(JSON.stringify(lookup_dados_tipo_pedido.dataset))
      );

      this.lookup_dataset_tipo_pedido = this.lookup_dataset_tipo_pedido.filter(
        (e) => {
          return e.ic_tipo_pedido == "V";
        }
      );
      /*-----------------------------------------------------------------------------*/

      this.load = false;
    } catch (error) {
      this.load = false;
    }
    await this.carregaGrid();

    /*---ORGANIZACAO---*/

    this.dados_lookup_organizacao = await Lookup.montarSelect(
      this.cd_empresa,
      5215
    );
    this.dataset_lookup_organizacao = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_lookup_organizacao.dataset))
    );
    if (this.dataset_lookup_organizacao != null) {
      for (let i = 0; i < this.dataset_lookup_organizacao.length; i++) {
        this.dados_nm_organizacao.push(
          this.dataset_lookup_organizacao[i].nm_organizacao
        );
      }
    }
    this.cd_user = localStorage.cd_usuario;
    this.tipo_destinatario = {
      cd_tipo_destinatario: 1,
      nm_tipo_destinatario: "Cliente",
    };
    this.$refs.timeline !== undefined
      ? (this.qtd_historico_timeline = this.$refs.timeline.qtd_historico)
      : "";
    await funcao.sleep(100);
    this.focaNoTopo();
  },

  async mounted() {
    const dados_cliente_grupo = await Lookup.montarSelect(this.cd_empresa, 442);
    this.lookup_cliente_grupo = JSON.parse(
      JSON.parse(JSON.stringify(dados_cliente_grupo.dataset))
    );
    //Filtra para trazer somente os grupos ativos
    this.lookup_cliente_grupo = this.lookup_cliente_grupo.filter((e) => {
      return e.ic_ativo_cliente_grupo == "S";
    });

    if (this.cd_empresa != 150) {
      let menu = await Menu.montarMenu(this.cd_empresa, 7439, 1);

      this.colunas = JSON.parse(JSON.parse(JSON.stringify(menu.coluna)));
      // this.colunas[4].store = {
      //   type: "array",
      //   data: this.lookup_dataset_unidade_medida,
      //   key: "cd_unidade_medida",
      // };
      for (let g = 0; g < this.colunas.length; g++) {
        if (
          this.colunas[g].dataField == "Quantidade" ||
          this.colunas[g].dataField == "Valor" ||
          this.colunas[g].dataField == "Produto" ||
          this.colunas[g].dataField == "Descrição" ||
          this.colunas[g].dataField == "nm_unidade_medida" ||
          this.colunas[g].dataField == "qt_dia_entrega"
        ) {
          this.colunas[g].editing = true;
        } else {
          this.colunas[g].editing = false;
        }
        if (
          this.colunas[g].dataField !== "cd_controle" &&
          this.colunas[g].dataField !== "Disponivel"
        ) {
          this.colunas[g].formItem.disabled = false;
          this.colunas[g].formItem.visible = true;
        }
        if (this.colunas[g].dataField === "Descrição") {
          this.colunas[g].formItem.editorType = "dxTextArea";
          this.colunas[g].formItem.colSpan = "2";
        }
      }
    }
  },

  updated() {
    this.atualiza_Historico = true;
  },

  beforeDestroy() {
    localStorage.titulo_menu_watch = "";
  },
  computed: {
    grid() {
      return this.$refs[this.gridRefName].instance;
    },
    grid_carrinho() {
      return this.$refs[this.gridRefNameCarrinho].instance;
    },
  },
  components: {
    grid,
    DxDataGrid,
    DxPaging,
    DxExport,
    DxScrollView,
    DxSearchPanel,
    DxEditing,
    DxForm,
    DxSimpleItem,
    DxGroupItem,
    DxPager,
    DxGroupPanel,
    DxColumn,
    carregando,
    timeline: () => import("../views/timeline.vue"),
    ListagemPadrao: () => import("../views/listagem-padrao.vue"),
    autoForm: () => import("../views/autoForm"),
    Grid,
  },
  watch: {
    Expansion() {
      if (this.Expansion == false) {
        this.Expansion = true;
      }
    },
    business() {
      if (this.business == "") {
        this.cd_site = "";
        this.novo_telefone_org = "";
        this.GridOrg = false;
      }
    },
    popup_insere_empresa() {
      if (this.popup_insere_empresa == true) {
        this.ds_organizacao = "";
        this.segmento_organizacao = "";
        this.regiao_venda = "";
        this.tipo_pessoa = "";
        this.tipo_mercado = "";
        this.regiao = "";
        this.cd_site = "";
        this.novo_telefone_org = "";
      }
    },
    novo_telefone_org(New) {
      this.MaskTelefone(New);
    },
    async tipo_pesquisa_produto(New) {
      if (
        New === "S" &&
        this.dataset_lookup_marca == [] &&
        this.dataset_lookup_categoria &&
        this.dataset_lookup_grupo
      ) {
        this.load = true;
        let dados_lookup_marca = await Lookup.montarSelect(
          this.cd_empresa,
          2406
        );
        this.dataset_lookup_marca = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_marca.dataset))
        );
        let dados_lookup_categoria = await Lookup.montarSelect(
          this.cd_empresa,
          261
        );
        this.dataset_lookup_categoria = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_categoria.dataset))
        );
        let dados_lookup_grupo = await Lookup.montarSelect(
          this.cd_empresa,
          159
        );
        this.dataset_lookup_grupo = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_grupo.dataset))
        );
        this.load = false;
      }
    },
    async lista_servicos() {
      try {
        await this.onCalculaTotal();
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error, "Error Itens");
      }
    },
  },

  methods: {
    focaNoTopo() {
      const div = document.getElementById("FocaTopo");
      if (div) {
        div.scrollIntoView({ behavior: "smooth" });
        // Opcional: Adicionar um foco visual ou funcional se necessário
        div.focus(); // Isso só funciona se a div for focável (tabindex)
      }
    },
    async IdentificaPessoa() {
      if (this.cd_cnpj.length >= 11) {
        this.cd_cnpj = this.cd_cnpj
          .replaceAll(".", "")
          .replaceAll("-", "")
          .replaceAll(" ", "")
          .replaceAll("/", "")
          .trim();
        if (this.cd_cnpj.length == 11) {
          this.cd_cnpj = await funcao.FormataCPF(this.cd_cnpj);
          this.tipo_pessoa = {
            cd_tipo_pessoa: 2,
            nm_tipo_pessoa: "Física",
          };
        } else if (this.cd_cnpj.length == 14) {
          this.cd_cnpj = await funcao.FormataCNPJ(this.cd_cnpj);
          this.tipo_pessoa = {
            cd_tipo_pessoa: 1,
            nm_tipo_pessoa: "Jurídica",
          };
          await this.buscaCNPJ();
        } else {
          this.tipo_pessoa = "";
          notify("CPF/CNPJ inválidos!");
        }
      }
    },
    async OnMoeda() {
      await this.onCalculaTotal();
    },
    async OnPais() {
      if (this.pais_oportunidade.cd_moeda) {
        [this.moeda] = this.dataset_lookup_moeda.filter((m) => {
          return m.cd_moeda === this.pais_oportunidade.cd_moeda;
        });
        await this.onCalculaTotal();
      }
    },
    async InputProduto(tipo) {
      //1 = Pesquisa pelo nm_produto (Descritivo)
      //2 = Pesquisa pelo Fantasia
      //3 = Pesquisa pelo Máscara
      let p = 0;
      let a = 0;
      if (tipo == 1) {
        p = this.nm_produto.length;
        await funcao.sleep(1000);
        a = this.nm_produto.length;
      } else if (tipo == 2) {
        p = this.nm_fantasia_produto.length;
        await funcao.sleep(1000);
        a = this.nm_fantasia_produto.length;
      } else if (tipo == 3) {
        p = this.cd_mascara_produto.length;
        await funcao.sleep(1000);
        a = this.cd_mascara_produto.length;
      }

      if (tipo == 1) {
        this.nm_fantasia_produto = "";
        this.cd_mascara_produto = "";
      } else if (tipo == 2) {
        this.nm_produto = "";
        this.cd_mascara_produto = "";
      } else if (tipo == 3) {
        this.nm_fantasia_produto = "";
        this.nm_produto = "";
      }

      if (a != p) return;
      if (p == a) {
        await this.onVerificaPesquisaProduto();
      }
    },

    async attListaServicos(e) {
      this.lista_servicos = [];
      this.lista_servicos = e;
    },

    async attQtd() {
      await funcao.sleep(1);
      // if (e.prevColumnIndex === 6) {
      //   await this.grid_carrinho.saveEditData();
      // }
      // if (e.rows[e.newRowIndex].isEditing === false) {
      //   this.grid_carrinho.editRow(e.newRowIndex);
      // }
    },
    onFocusedRowChangedCarrinho: function (e) {
      this.linha_selecionada = e.row && e.row.data;
    },

    async SelecionaEstado(limpa) {
      this.carrega_cidade = true;
      if (limpa == true) {
        this.natural_cidade = "";
      }
      let estado = this.natural_estado;
      ///////////////////
      let cidade_json = {
        cd_empresa: this.cd_empresa,
        cd_tabela: 97,
        order: "D",
        join: "Estado",
        where: [{ cd_estado: estado.cd_estado }],
      };
      let cidades_resultado = await select.montarSelect(
        this.cd_empresa,
        cidade_json
      );
      this.lookup_cidade_filtrado = JSON.parse(
        JSON.parse(JSON.stringify(cidades_resultado[0].dataset))
      );
      ///////////////////

      this.carrega_cidade = false;
    },
    linhacategoria: function (e) {
      this.linha_selecionada = e.row && e.row.data;
    },

    async onBuscaCep() {
      if (
        this.cep.length > 8 &&
        this.cep != "11111-111" &&
        this.cep != "22222-222" &&
        this.cep != "33333-333" &&
        this.cep != "44444-444" &&
        this.cep != "55555-555" &&
        this.cep != "66666-666" &&
        this.cep != "77777-777" &&
        this.cep != "88888-888" &&
        this.cep != "99999-999" &&
        this.cep != "00000-000"
      ) {
        try {
          this.CEPLoading = true;
          let cep_encontrado = await funcao.buscaCep(this.cep);
          if (
            !!cep_encontrado[0].cd_estado &&
            this.tipo_mercado.cd_tipo_mercado !== 2
          ) {
            this.nm_endereco = cep_encontrado[0].logradouro;
            this.bairro = cep_encontrado[0].bairro;
            this.natural_estado = this.lookup_estado_natural.find((e) => {
              return e.cd_estado == cep_encontrado[0].cd_estado;
            });
            if (this.natural_estado) {
              await this.SelecionaEstado(true);
              this.natural_cidade = this.lookup_cidade_filtrado.find((e) => {
                return e.cd_cidade == cep_encontrado[0].cd_cidade;
              });
              this.pais = this.lookup_pais.find((p) => {
                return p.cd_pais == cep_encontrado[0].cd_pais;
              });
            }
          } else {
            this.CEPLoading = false;
          }
          this.CEPLoading = false;
        } catch {
          this.CEPLoading = false;
          notify("CEP não encontrado");
        }
      }
    },

    async ValidacaoCPF() {
      this.validouCPF = await funcao.ValidaCPF(
        this.cd_cnpj.replaceAll(".", "").replace("-", "")
      );
    },

    async buscaCNPJ() {
      if (!!this.cd_cnpj == false) return;

      let retorno = await funcao.BuscaCNPJ(this.cd_cnpj.trim());
      if (retorno.Cod == 500) return;
      this.cep = retorno.cd_cep + "";
      this.nm_numero_endereco = retorno.cd_numero_cnpj;
      this.nm_email_organizacao = retorno.nm_email;
      this.nova_organizacao_fantasia = retorno.nm_fantasia_cnpj
        ? retorno.nm_fantasia_cnpj
        : retorno.nm_razao_social_cnpj.slice(
            0,
            retorno.nm_razao_social_cnpj.indexOf(" ")
          );
      this.nova_organizacao = retorno.nm_razao_social_cnpj;
      if (retorno.cd_telefone_cnpj) {
        if (retorno.cd_telefone_cnpj.includes("/")) {
          retorno.cd_telefone_cnpj = retorno.cd_telefone_cnpj.substring(
            0,
            retorno.cd_telefone_cnpj.indexOf("/")
          );
        }
        if (retorno.cd_telefone_cnpj.length > 8) {
          this.novo_telefone_org = await funcao.FormataTelefone(
            retorno.cd_telefone_cnpj
          );
        }
        this.novo_telefone_org = await funcao.FormataTelefone(
          retorno.cd_telefone_cnpj
        );
      }

      await this.onBuscaCep();
    },
    async ListaCarrinho(e) {
      if (e) {
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
        this.onCalculaTotal();
        this.categoria = "";
        this.grupo = "";
        this.marca = "";
        this.cd_mascara_produto = "";
        this.nm_fantasia_produto = "";
        this.nm_produto = "";
        this.resultado_categoria = [];
        this.pesquisa_produto = false;
        notify("Item adicionado ao carrinho!");
      } else {
        notify("Selecione um item para adicionar");
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
      this.load = true;
      this.resultado_categoria = await Incluir.incluirRegistro(
        "562/781",
        this.nm_json
      );
      this.load = false;
      this.codigo = true;
      if (this.resultado_categoria[0].Cod === 0) {
        this.codigo = false;
        notify("Nenhum produto encontrado!");
        return;
      }
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
    async SelecionaOrganizacao() {
      let linha = await this.$refs.gridOrganizacao.linha;
      this.cd_organizacao = linha.cd_organizacao;
      this.cd_cliente = linha.cd_cliente;
      this.business = linha.nm_organizacao;
      this.contact_pesq = "";
      this.novo_email = "";
      this.novo_celular = "";

      this.cd_site = linha.cd_site;
      if (!!linha.cd_ddd && !!linha.cd_telefone) {
        this.novo_telefone_org = "(" + linha.cd_ddd + ") " + linha.cd_telefone;
      }
      this.loading_org = false;
      this.GridOrg = false;
      this.PesquisaContatoNome();
    },

    async SelecionaGridContato() {
      const linha = await this.$refs.gridContato.linha;
      //Dados da Organização/Cliente
      this.cd_organizacao = linha.cd_organizacao;
      this.cd_cliente = linha.cd_cliente;
      this.business =
        this.business == "" ? linha.nm_organizacao : this.business;
      this.cd_site = linha.cd_site;
      this.novo_telefone_org = linha.cd_telefone_organizacao;

      //Dados do Contato
      this.cd_contato_crm = linha.cd_contato;
      this.contact_pesq = linha.nm_contato;
      this.novo_email = linha.nm_email;
      this.novo_celular = linha.cd_celular;
      this.GridContato = false;
    },

    PesquisaContatoNome() {
      this.GridContato = false;
      this.consultaContatoNome = {
        cd_parametro: 20,
        nm_contato: this.contact_pesq,
        cd_organizacao: this.cd_organizacao,
        cd_cliente: this.cd_cliente,
        cd_usuario: localStorage.cd_usuario,
      };
      this.GridContato = true;
    },

    async PesquisaOrganizacaoNome() {
      this.consultaOrganizacao = {
        cd_parametro: 19,
        nm_org: this.business,
        cd_usuario: localStorage.cd_usuario,
      };
      if (this.business.length > 0) {
        this.loading_org = false;
        this.GridOrg = true;
      }
    },

    saveGridInstance: function (e) {
      this.grid_produto = e.component;
    },

    async carregaGrid() {
      if (this.oportunidade_up.cd_movimento != 0) {
        try {
          this.load = true;
          this.alteracao = true;
          let o = {
            cd_parametro: 8,
            cd_usuario: this.usuario,
            cd_movimento: this.up_cd_movimento,
          };
          let i = {
            cd_parametro: 9,
            cd_usuario: this.usuario,
            cd_movimento: this.up_cd_movimento,
          };
          let get = await Incluir.incluirRegistro(this.api, o);
          try {
            [this.moeda] = this.dataset_lookup_moeda.filter((m) => {
              return m.cd_moeda === get[0].cd_moeda;
            });
          } catch (error) {
            // eslint-disable-next-line no-console
            console.error(error, "Error currency");
          }
          try {
            [this.pais_oportunidade] = this.lookup_pais.filter((p) => {
              return p.cd_pais === get[0].cd_pais;
            });
          } catch (error) {
            // eslint-disable-next-line no-console
            console.error(error, "Error country");
          }

          this.nm_vendedor = get[0].nm_vendedor;
          this.title = get[0].nm_titulo_movimento;
          this.ds_historico = get[0].ds_historico;
          this.ds_organizacao = get[0].ds_organizacao;

          this.cd_organizacao = get[0].cd_organizacao;
          this.cd_cliente = get[0].cd_cliente;
          this.cd_site = get[0].cd_site;

          this.novo_telefone_org = get[0].cd_telefone_organizacao;
          this.MaskTelefone(this.novo_telefone_org);
          this.novo_email = get[0].nm_email_contato_crm;
          this.novo_celular = get[0].cd_telefone_contato
            ? get[0].cd_telefone_contato
            : get[0].cd_telefone_contato_cliente;
          this.nm_departamento = get[0].nm_departamento;

          var v = {
            cd_parametro: 1,
            cd_usuario: this.usuario,
            nm_departamento: this.nm_departamento,
          };
          this.lookup_vendedor = await Incluir.incluirRegistro("688/1028", v);
          this.lookup_vendedor = this.lookup_vendedor.sort(function (a, b) {
            if (a.nm_usuario < b.nm_usuario) return -1;
            return 1;
          });
          this.business = get[0].nm_cliente_organizacao;
          this.cd_organizacao = get[0].cd_organizacao;
          this.contact_pesq = get[0].nm_contato_crm
            ? get[0].nm_contato_crm
            : get[0].nm_contato_cliente;

          this.cd_contato_crm = get[0].cd_contato_crm
            ? get[0].cd_contato_crm
            : get[0].cd_contato;
          this.tipo_oportunidade = {
            cd_fonte_informacao: get[0].cd_fonte_informacao,
            nm_fonte_informacao: get[0].nm_fonte_informacao,
          };
          this.dt_op = formataData.formataDataJS(get[0].dt_usuario_inclusao);
          try {
            this.ValorReadyOnly
              ? (this.valor = await funcao.FormataValor(
                  get[0].vl_movimento2,
                  this.moeda.sg_moeda_funcao
                ))
              : "";
          } catch (error) {
            // eslint-disable-next-line no-console
            console.error(error);
          }
          this.nm_tipo_venda = {
            cd_tipo_pedido: get[0].cd_tipo_pedido,
            nm_tipo_pedido: get[0].nm_tipo_pedido,
          };
          this.dt_previsto_fechamento = get[0].dt_previsto_fechamento;
          this.dt_retorno = get[0].dt_retorno;
          this.hr_retorno = get[0].hr_retorno;
          this.ratingModel = get[0].cd_classificacao;
          ////Items
          let items = await Incluir.incluirRegistro(this.api, i);
          this.nm_vendedor = get[0].nm_fantasia_usuario;
          if (items[0].Cod == 0) {
            this.load = false;
          } else {
            this.carrinho = [];
            for (let it = 0; it < items.length; it++) {
              this.load = false;
              if (items[it].cd_produto == undefined) {
                let servico = {
                  cd_servico: items[it].cd_servico,
                  cd_mascara_servico: items[it].cd_mascara_servico,
                  nm_servico: items[it].nm_obs_item_movimento,
                  qt_servico: items[it].qt_item_produto,
                  vl_servico: items[it].vl,
                  vl_total_servico: items[it].vl * items[it].qt_item_produto,
                  ds_servico: items[it].ds_item_produto,
                  pc_iss_servico: items[it].pc_iss_servico,
                  pc_irrf_servico: items[it].pc_irrf_servico,
                  pc_comissao_servico: items[it].pc_comissao_servico,
                  qt_dia_entrega: items[it].qt_dia_entrega,
                  cd_controle: items[it].cd_controle,
                };
                this.lista_servicos.push(servico);
              } else {
                let line = {
                  Codigo: items[it].Codigo,
                  Fantasia: items[it].Fantasia,
                  Produto: items[it].Produto,
                  Valor: items[it].vl_item_movimento,
                  Disponivel: items[it].Disponivel,
                  Descrição: items[it].ds_item_produto,
                  Un: items[it].nm_unidade_medida,
                  vl_total_item:
                    items[it].vl_item_movimento && items[it].qt_item_produto
                      ? items[it].vl_total_movimento
                      : "R$ 0,00",
                  cd_unidade_medida: items[it].cd_unidade_medida,
                  nm_preco_lista_produto: items[it].nm_preco_lista_produto,
                  Quantidade: items[it].qt_item_produto,
                  cd_produto: items[it].cd_produto, //== undefined ? 0 : items[it].cd_produto,
                  cd_controle: items[it].cd_controle,
                  cd_item_movimento: items[it].cd_item_movimento,
                  qt_dia_entrega: items[it].qt_dia_entrega,
                  id: this.carrinho.length + 1,
                };
                this.total_prod = items[0].vl_total_movimento;
                this.carrinho.push(line);
              }
            }
          }
          if (items[0].vl_total_movimento === undefined) {
            items[0].vl_total_movimento = 0;
          }
          this.load = false;
        } catch (error) {
          this.load = false;
        }
      } else {
        this.contact_pesq = "";
        this.cd_contato_crm = 0;
        this.business = "";
        this.cd_organizacao = 0;
        this.cd_cliente = 0;
        this.tipo_oportunidade = "";
        this.title = "";
        this.valor = "";
        this.nm_tipo_venda = "";
        this.dt_previsto_fechamento = "";
        this.dt_retorno = "";
        this.hr_retorno = "";
        this.ratingModel = 0;
        this.total_prod = 0;
        this.carrinho = [];
        this.alteracao = false;
      }
    },

    async pesquisaContato() {
      if (this.novo_email || this.novo_telefone || this.novo_celular) {
        let c = {
          cd_parametro: 16,
          nm_email_contato_crm: this.novo_email,
          nm_telefone_contato: this.novo_telefone,
          nm_celular_contato: this.novo_celular,
          cd_organizacao: this.cd_organizacao,
          cd_cliente: this.cd_cliente,
          cd_usuario: localStorage.cd_usuario,
        };
        this.pesquisa_email = await Incluir.incluirRegistro(this.api, c);
        if (this.pesquisa_email[0].Cod == 0) {
          notify(this.pesquisa_email[0].Msg);
          return;
        }
      }
    },

    onFocusedRowChanged: function (e) {
      this.linha = e.row && e.row.data;
    },

    async ContinuaPesquisa() {
      this.novo_cadastro = false;
      this.popup_insere_empresa = false;
      this.cd_organizacao = this.linha.cd_organizacao;
      this.cd_cliente = this.linha.cd_cliente;
      this.nova_organizacao = this.linha.nm_organizacao;
      this.nova_organizacao_fantasia = this.linha.nm_fantasia;
      this.cd_site = this.linha.cd_site;
      this.novo_telefone_org = this.linha.cd_telefone;
      this.cd_tipo_pessoa = {
        cd_tipo_pessoa: this.linha.cd_tipo_pessoa,
        nm_tipo_pessoa: this.linha.nm_tipo_pessoa,
      };
      this.regiao_venda = {
        cd_regiao_venda: this.linha.cd_regiao_venda,
        nm_regiao_venda: this.linha.nm_regiao_venda,
      };
      this.segmento_organizacao = {
        cd_segmento_mercado: this.linha.cd_segmento_mercado,
        nm_segmento_mercado: this.linha.nm_segmento_mercado,
      };
      this.ds_organizacao = this.linha.ds_organizacao;
      this.business = this.linha.nm_organizacao;
    },

    async PesquisaOrganizacao() {
      let c = {};
      if (this.nm_email_organizacao == "") return;
      c = {
        cd_parametro: 15,
        nm_email_organizacao: this.nm_email_organizacao,
      };
      this.pesquisa_site = await Incluir.incluirRegistro(this.api, c);
      if (this.pesquisa_site[0].Cod == 0) {
        notify(this.pesquisa_site[0].Msg);
        return;
      } else {
        this.popupEncontrato = true;
      }
    },
    ValidaTudo() {
      let retorno = false;
      if (this.business == "" && !this.cd_organizacao && !this.cd_cliente) {
        retorno = false;
        this.load = false;
        notify("Indique uma organização!");
        return retorno;
      }
      if (this.valor == "R$ NaN") {
        retorno = false;
        this.load = false;
        notify("Digite um valor válido!");
        return retorno;
      }

      if (this.tipo_oportunidade == "") {
        retorno = false;
        this.load = false;
        notify("Selecione a fonte de informação!");
        return retorno;
      }
      if (
        this.nm_tipo_venda.cd_tipo_pedido == undefined ||
        this.nm_tipo_venda.cd_tipo_pedido == 0
      ) {
        retorno = false;
        this.load = false;
        notify("Selecione o tipo de venda!");
        return retorno;
      }
      if (this.ratingModel == 0) {
        retorno = false;
        this.load = false;
        notify("Selecione a classificação!");
        return retorno;
      }

      retorno = true;
      return retorno;
    },

    MaskTelefone(e) {
      if (!!e == false) return;
      if (e !== "") {
        try {
          var r = e.replace(/\D/g, "");
          r = r.replace(/^0/, "");
          if (r.length > 10) {
            r = r.replace(/^(\d\d)(\d{5})(\d{4}).*/, "($1) $2-$3");
          } else if (r.length > 5) {
            r = r.replace(/^(\d\d)(\d{4})(\d{0,4}).*/, "($1) $2-$3");
          } else if (r.length > 2) {
            r = r.replace(/^(\d\d)(\d{0,5})/, "($1) $2");
          } else {
            r = r.replace(/^(\d*)/, "($1");
          }
        } catch {
          r = "";
        }
      }

      this.novo_telefone_org = r;
    },

    onTipoMercado() {
      if (this.tipo_mercado.cd_tipo_mercado === 2) {
        this.pais = "";
        this.natural_estado = "";
        this.natural_cidade = "";
        // [this.natural_estado] = this.lookup_estado_natural.filter((f) => {
        //   return f.cd_pais !== 1 && f.nm_estado.includes("EX");
        // });
      }
    },

    async onInsertOportunidade() {
      if (!this.cd_organizacao && !this.cd_cliente) {
        notify("Indique uma organização!");
        return;
      } else if (
        this.valor == "R$ NaN" &&
        this.lookup_dataset_parametro_crm.ic_oportunidade_sem_item !== "S"
      ) {
        notify("Digite um valor válido!");
      }
      if (this.nm_tipo_venda === "" || this.nm_tipo_venda == undefined) {
        notify("Selecione o Tipo de Venda!");
        return;
      }
      if (
        this.carrinho.length === 0 &&
        this.lista_servicos.length === 0 &&
        this.lookup_dataset_parametro_crm.ic_oportunidade_sem_item !== "S"
      ) {
        notify("Insira pelo menos um item!");
        return;
      }

      if (this.dt_previsto_fechamento != "") {
        var data = formataData.formataDataSQL(this.dt_previsto_fechamento);
      } else {
        this.dt_previsto_fechamento = "";
      }

      if (this.dt_retorno != "") {
        var dataRetorno = formataData.formataDataSQL(this.dt_retorno);
      } else {
        this.dt_retorno = "";
      }
      if (this.cd_empresa == 150) {
        let verificacao = await this.ValidaTudo();
        if (verificacao == false) {
          return;
        }
      }

      if (this.up_cd_movimento == 0 || this.ic_salvar == false) {
        this.alteracao = false;
      } else {
        this.alteracao = true;
        this.ic_salvar = true;
      }
      EventBus.$emit("parent-event", "Chamando evento de salvar grid");
      await this.grid_carrinho.saveEditData();
      this.valor = await funcao.RealParaInt(this.valor);
      this.nm_json = {
        cd_parametro: 2,
        cd_usuario: this.usuario,
        cd_organizacao: this.cd_organizacao,
        cd_cliente: this.cd_cliente,
        nm_organizacao: this.business,
        cd_contato: this.cd_contato_crm,
        nm_contato_crm: this.contact_pesq,
        cd_fonte_informacao: this.tipo_oportunidade.cd_fonte_informacao,
        nm_titulo_movimento: this.title,
        cd_classificacao: this.ratingModel,
        vl_movimento: this.valor,
        nm_cliente: this.contact_pesq,
        nm_email_cliente: this.nm_email_contato_selec,
        cd_oportunidade: this.up_cd_movimento,
        cd_tipo_pedido: this.nm_tipo_venda.cd_tipo_pedido,
        ds_historico: this.ds_historico,
        dt_retorno: dataRetorno,
        hr_retorno: this.hr_retorno,
        dt_previsto_fechamento: data,
        cd_moeda: this.moeda.cd_moeda,
        cd_pais: this.pais_oportunidade
          ? this.pais_oportunidade.cd_oportunidade
          : 1,
        json_produtos: this.carrinho_json,
      };
      this.load = true;
      try {
        this.resultado = await Incluir.incluirRegistro(this.api, this.nm_json);
      } catch (error) {
        this.load = false;
      }
      this.atualiza_Historico = false;
      this.cd_movimento = this.resultado[0].cd_movimento;
      this.up_cd_movimento =
        this.resultado[0].cd_oportunidade || this.resultado[0].cd_movimento;
      this.AtualizaProduto = 0;

      this.load = false;
      this.ic_salvar = false;
      notify(this.resultado[0].Msg);
      if (this.resultado[0].Msg == "Registro Incluído com Sucesso!") {
        this.mostraProposta = true;
        localStorage.cd_parametro = parseInt(this.resultado[0].cd_movimento);
      }
      this.load = false;
    },

    async onEditarOportunidade() {
      if (!this.cd_organizacao && !this.cd_cliente) {
        notify("Indique uma organização!");
        return;
      } else if (
        this.valor == "R$ NaN" &&
        this.lookup_dataset_parametro_crm.ic_oportunidade_sem_item !== "S"
      ) {
        notify("Digite um valor válido!");
      }
      if (
        this.carrinho.length === 0 &&
        this.lista_servicos.length === 0 &&
        this.lookup_dataset_parametro_crm.ic_oportunidade_sem_item !== "S"
      ) {
        notify("Insira pelo menos um item!");
        return;
      }

      if (this.dt_previsto_fechamento != "") {
        var data = formataData.formataDataSQL(this.dt_previsto_fechamento);
      } else {
        this.dt_previsto_fechamento = "";
      }

      if (this.dt_retorno != "") {
        var dataRetorno = formataData.formataDataSQL(this.dt_retorno);
      } else {
        this.dt_retorno = "";
      }
      if (this.cd_empresa == 150) {
        let verificacao = await this.ValidaTudo();
        if (verificacao == false) {
          return;
        }
      }
      this.load = true;
      EventBus.$emit("parent-event", "Chamando evento de salvar grid");
      await this.grid_carrinho.saveEditData();
      await this.onCalculaTotal();
      this.valor = this.carrinho_json.reduce(
        (acc, cur) =>
          acc +
          (cur.Valor
            ? parseFloat(
                cur.Valor.replaceAll("R$", "")
                  .replaceAll("US$", "")
                  .replaceAll("€", "")
                  .replaceAll(".", "")
                  .replaceAll(",", ".")
              )
            : cur.vl_servico),
        0
      );
      try {
        this.nm_json = {
          cd_parametro: 10,
          cd_usuario: this.usuario,
          cd_movimento: this.up_cd_oportunidade,
          cd_organizacao: this.cd_organizacao,
          cd_cliente: this.cd_cliente,
          nm_organizacao: this.business,
          cd_contato: this.cd_contato_crm,
          nm_contato_crm: this.contact_pesq,
          cd_fonte_informacao: this.tipo_oportunidade.cd_fonte_informacao,
          nm_fonte_informacao: this.tipo_oportunidade.nm_fonte_informacao,
          nm_titulo_movimento: this.title,
          cd_classificacao: this.ratingModel,
          vl_movimento: this.valor,
          nm_cliente: this.contact_pesq,
          nm_email_cliente: this.nm_email_contato_selec,
          cd_oportunidade: this.up_cd_movimento,
          cd_tipo_pedido: this.nm_tipo_venda.cd_tipo_pedido,
          ds_historico: this.ds_historico,
          dt_retorno: dataRetorno,
          hr_retorno: this.hr_retorno,
          dt_previsto_fechamento: data,
          cd_moeda: this.moeda.cd_moeda,
          cd_pais: this.pais_oportunidade
            ? this.pais_oportunidade.cd_oportunidade
            : 1,
          json_produtos: this.carrinho_json,
        };
        this.resultado = await Incluir.incluirRegistro(this.api, this.nm_json);
        this.atualiza_Historico = false;
        this.load = false;
        notify(this.resultado[0].Msg);
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error);
      } finally {
        this.load = false;
        this.atualiza_Historico = false;
      }
    },

    filterSegmentoOrganizacao(val, update) {
      if (this.dataset_lookup_segmento != null) {
        update(() => {
          const needle = val.toLowerCase();
          this.opcoes_segmento_organizacao =
            this.dataset_lookup_segmento.filter(
              (v) => v.nm_segmento_mercado.toLowerCase().indexOf(needle) > -1
            );
        });
      }
    },

    filterTipoDestinatario(val, update) {
      if (this.dataset_lookup_destinatario != null) {
        update(() => {
          const needle = val.toLowerCase();
          this.opcoes_tipo_destinatario =
            this.dataset_lookup_destinatario.filter(
              (v) => v.nm_tipo_destinatario.toLowerCase().indexOf(needle) > -1
            );
        });
      }
    },

    filterRegiaoVenda(val, update) {
      if (this.dataset_lookup_regiao_venda != null) {
        update(() => {
          const needle = val.toLowerCase();
          this.opcoes_regiao_venda = this.dataset_lookup_regiao_venda.filter(
            (v) => v.nm_regiao_venda.toLowerCase().indexOf(needle) > -1
          );
        });
      }
    },

    filterTipoPessoa(val, update) {
      if (this.dataset_lookup_tipo_pessoa != null) {
        update(() => {
          const needle = val.toLowerCase();
          this.opcoes_tipo_pessoa = this.dataset_lookup_tipo_pessoa.filter(
            (v) => v.nm_tipo_pessoa.toLowerCase().indexOf(needle) > -1
          );
        });
      }
    },

    filterTipoPedido(val, update) {
      if (this.lookup_dataset_tipo_pedido != null) {
        update(() => {
          const needle = val.toLowerCase();
          this.opcoes_tipo_pedido = this.lookup_dataset_tipo_pedido.filter(
            (v) => v.nm_tipo_pedido.toLowerCase().indexOf(needle) > -1
          );
        });
      }
    },

    filterTipoOportunidade(val, update) {
      if (this.dataset_tipo_oportunidade != null) {
        update(() => {
          const needle = val.toLowerCase();
          this.opcoes_tipo_oportunidade = this.dataset_tipo_oportunidade.filter(
            (v) => v.nm_fonte_informacao.toLowerCase().indexOf(needle) > -1
          );
        });
      }
    },

    filterOrganizacao(val, update) {
      if (this.dataset_lookup_organizacao != null) {
        this.business = val;
        update(() => {
          const needle = val.toLowerCase();
          this.opcoes_organizacao = this.dataset_lookup_organizacao.filter(
            (v) => v.nm_organizacao.toLowerCase().indexOf(needle) > -1
          );
        });
      }
    },

    async geraProposta() {
      try {
        this.load = true;
        let cd_api = "632"; // 1497 Procedimento - pr_geracao_proposta_oportunidade
        let api = "632/894";
        localStorage.cd_documento = this.up_cd_oportunidade;
        localStorage.cd_parametro = this.up_cd_oportunidade;

        let dados = await Menu.montarMenu(this.cd_empresa, 0, cd_api); //'titulo';
        let sParametroApi = dados.nm_api_parametro;

        let d = await Procedimento.montarProcedimento(
          this.cd_empresa,
          0,
          api,
          sParametroApi
        );
        notify(d[0].Msg);
      } catch (error) {
        this.load = false;
      }
      this.load = false;
    },

    onAddContato() {
      this.GridContato = false;

      if (!!this.contact_pesq == false) {
        this.popup_cadastro_contato = !this.popup_cadastro_contato;
      } else {
        this.novo_celular =
          this.contact_pesq.cd_ddd_celular + this.contact_pesq.cd_celular;
        this.novo_email = this.contact_pesq.nm_email_contato_crm;
        if (typeof this.contact_pesq != "object") {
          this.novo_contato = this.contact_pesq;
          this.novo_celular = "";
          this.novo_telefone = "";
          this.novo_email = "";
          this.ratingContato = 0;
          this.org = "";
          if (this.popup_insere_empresa == true) {
            this.popup_cadastro_contato = false;
          } else {
            this.popup_cadastro_contato = true;
          }
          this.popup_cadastro_contato = !this.popup_cadastro_contato;
        }
        this.novo_email = "";
        this.novo_celular = "";
        this.novo_contato = "";
        this.novo_email = "";
        this.novo_telefone = "";
        this.popup_cadastro_contato = !this.popup_cadastro_contato;
      }
    },

    confirma_exclusao() {
      this.popup_excluir = true;
    },

    async onExcluirOportunidade() {
      let json_excluir = {
        cd_parametro: 13,
        cd_usuario: this.cd_user,
        cd_movimento: this.up_cd_oportunidade,
        cd_oportunidade: this.up_cd_movimento,
        cd_modulo: this.cd_modulo,
      };
      let delete_oportunidade = await Incluir.incluirRegistro(
        this.api,
        json_excluir
      );
      notify(delete_oportunidade[0].Msg);
      this.$emit("click");
    },

    onTransferir() {
      this.popup_transferir = true;
    },

    async onTransferirOportunidade() {
      if (this.vendedor == "") {
        notify("Selecione um destinatário");
      } else {
        if (this.dt_previsto_fechamento != "") {
          var data = formataData.formataDataSQL(this.dt_previsto_fechamento);
        } else {
          this.dt_previsto_fechamento = "";
        }

        if (this.dt_retorno != "") {
          var dataRetorno = formataData.formataDataSQL(this.dt_retorno);
        } else {
          this.dt_retorno = "";
        }
        var trocaVendedor = {
          cd_parametro: 14,
          cd_oportunidade: this.up_cd_movimento,
          cd_usuario: this.vendedor.cd_usuario,
          ds_motivo: this.ds_motivo_transferencia,
          cd_organizacao: this.cd_organizacao,
          cd_cliente: this.cd_cliente,
          cd_contato: this.cd_contato_crm,
          nm_titulo_movimento: this.title,
          cd_classificacao: this.ratingModel,
          vl_movimento: this.valor,
          dt_previsto_fechamento: data,
          cd_fonte_informacao: this.tipo_oportunidade.cd_fonte_informacao,
          ds_historico: this.ds_historico,
          dt_retorno: dataRetorno,
          hr_retorno: this.hr_retorno,
        };
        let resultadoTransferencia = await Incluir.incluirRegistro(
          this.api,
          trocaVendedor
        );
        notify(resultadoTransferencia[0].Msg);
        this.popup_transferir = false;
      }
    },

    async onTransferirOportunidadeCancela() {
      this.vendedor = "";
      this.ds_motivo_transferencia = "";
    },

    async onAddEmpresa() {
      if (
        this.lookup_estado_natural !== null &&
        this.lookup_estado_natural.length == 0
      ) {
        var lookup_estado = await Lookup.montarSelect(this.cd_empresa, 731);
        this.lookup_estado_natural = JSON.parse(
          JSON.parse(JSON.stringify(lookup_estado.dataset))
        );
      }
      /*---REGIAO VENDA---*/
      if (
        this.dataset_lookup_regiao_venda !== null &&
        this.dataset_lookup_regiao_venda.length == 0
      ) {
        let dados_lookup_regiao_venda = await Lookup.montarSelect(
          this.cd_empresa,
          886
        );
        this.dataset_lookup_regiao_venda = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_regiao_venda.dataset))
        );
      }
      /*--------------------------------------------------*/
      /*---TIPO PESSOA---*/
      if (
        this.dataset_lookup_tipo_pessoa !== null &&
        this.dataset_lookup_tipo_pessoa.length == 0
      ) {
        let dados_lookup_tipo_pessoa = await Lookup.montarSelect(
          this.cd_empresa,
          116
        );
        this.dataset_lookup_tipo_pessoa = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_tipo_pessoa.dataset))
        );
      }
      /*---TIPO MERCADO---*/
      if (
        this.dataset_lookup_tipo_mercado !== null &&
        this.dataset_lookup_tipo_mercado.length == 0
      ) {
        let dados_lookup_tipo_mercado = await Lookup.montarSelect(
          this.cd_empresa,
          182
        );
        this.dataset_lookup_tipo_mercado = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_tipo_mercado.dataset))
        );
      }
      /*--- REGIÃO ---*/
      if (
        this.dataset_lookup_regiao !== null &&
        this.dataset_lookup_regiao.length == 0
      ) {
        let dados_lookup_regiao = await Lookup.montarSelect(
          this.cd_empresa,
          132
        );
        this.dataset_lookup_regiao = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_regiao.dataset))
        );
      }
      /*--------------------------------------------------*/
      /*---SEGMENTO---*/
      if (
        this.dataset_lookup_segmento !== null &&
        this.dataset_lookup_segmento.length == 0
      ) {
        let dados_lookup_segmento = await Lookup.montarSelect(
          this.cd_empresa,
          4860
        );
        this.dataset_lookup_segmento = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_segmento.dataset))
        );
      }
      /*--------------------------------------------------*/
      this.GridOrg = false;
      this.contact_pesq = "";
      if (this.cd_organizacao == 0) {
        this.nova_organizacao = this.business;
        this.nova_organizacao_fantasia = this.business;

        if (this.popup_cadastro_contato == true) {
          this.nova_organizacao = this.org;
        }
        this.popup_cadastro_contato = false;
      }
      this.popup_insere_empresa = !this.popup_insere_empresa;
      /*---ORGANIZACAO---*/

      this.dados_lookup_organizacao = await Lookup.montarSelect(
        this.cd_empresa,
        5215
      );
      this.dataset_lookup_organizacao = JSON.parse(
        JSON.parse(JSON.stringify(this.dados_lookup_organizacao.dataset))
      );
      for (let i = 0; i < this.dataset_lookup_organizacao.length; i++) {
        this.dados_nm_organizacao.push(
          this.dataset_lookup_organizacao[i].nm_organizacao
        );
      }
    },

    async onInsereContato() {
      if (this.novo_contato == "") {
        notify("Digite o nome do contato...");
        this.popup_cadastro_contato = true;
        return;
      }
      if (!this.cd_organizacao && !this.cd_cliente) {
        notify("Indique uma organização!");
        return;
      }

      if (this.cd_empresa == 150 && this.novo_celular == "") {
        notify("Digite o celular...");
        return;
      }
      if (this.cd_empresa == 150 && this.novo_email == "") {
        notify("Digite o e-mail...");
        return;
      }

      this.cd_user = localStorage.cd_usuario;
      this.nm_json = {
        cd_parametro: 0,
        cd_usuario: this.cd_user,
        nm_contato: this.novo_contato,
        cd_telefone: this.novo_telefone,
        cd_celular: this.novo_celular,
        nm_email: this.novo_email,
        cd_grau_risco: this.ratingContato,
        cd_organizacao: this.cd_organizacao,
        cd_cliente: this.cd_cliente,
      };
      var insert_contato = await Incluir.incluirRegistro(
        this.api,
        this.nm_json
      );
      this.cd_contato_crm = insert_contato[0].Cod;
      if (insert_contato[0].Cod == 0) {
        notify(insert_contato[0].Msg);
        this.popup_cadastro_contato = true;
      }
      notify(insert_contato[0].Msg);
      this.contact_pesq = insert_contato[0].nm_contato;
      this.popup_cadastro_contato = false;
      /*---ORGANIZACAO CONTATO---*/

      this.dados_lookup_organizacao_contato = await Lookup.montarSelect(
        this.cd_empresa,
        5322
      );
      this.dataset_lookup_organizacao_contato = JSON.parse(
        JSON.parse(
          JSON.stringify(this.dados_lookup_organizacao_contato.dataset)
        )
      );
      for (let i = 0; i < this.dataset_lookup_organizacao_contato.length; i++) {
        this.dados_nm_organizacao_contato.push(
          this.dataset_lookup_organizacao_contato[i].nm_contato_crm
        );
      }
    },

    async oninsertOrganizacao() {
      if (this.nm_email_organizacao) {
        this.novo_email = this.nm_email_organizacao;
      }
      if (this.nova_organizacao == "") {
        notify("Digite o nome da Organização...");
        this.popup_insere_empresa = true;
        return;
      }
      if (this.nova_organizacao_fantasia == "") {
        notify("Digite o Fantasia...");
        this.popup_insere_empresa = true;
        return;
      }

      if (this.cd_empresa == 150 && this.novo_telefone_org == "") {
        notify("Digite o contato da organização!");
        return;
      }

      var segmento_empresa = this.segmento_organizacao.cd_segmento_mercado;
      var tipo_pessoa_empresa = this.tipo_pessoa.cd_tipo_pessoa;
      var destinatario = this.tipo_destinatario.cd_tipo_destinatario;
      var regiao = this.regiao_venda.cd_regiao_venda;
      let cd_cliente_grupo = 0;
      if (this.grupo.cd_cliente_grupo) {
        cd_cliente_grupo = this.grupo.cd_cliente_grupo;
      }

      if (this.cd_empresa == 150) {
        destinatario = 1;
      }

      this.nm_json = {
        cd_parametro: 1,
        cd_usuario: this.cd_user,
        nm_organizacao: this.nova_organizacao,
        nm_fantasia: this.nova_organizacao_fantasia,
        cd_site: this.cd_site,
        cd_telefone: this.novo_telefone_org,
        cd_tipo_pessoa: tipo_pessoa_empresa,
        cd_regiao_venda: regiao,
        cd_tipo_destinatario: destinatario,
        cd_segmento_mercado: segmento_empresa,
        ds_organizacao: this.ds_organizacao,
        nm_email_organizacao: this.nm_email_organizacao,
        cd_cep: this.cep.replace("-", ""),
        nm_endereco: this.nm_endereco,
        cd_numero: this.nm_numero_endereco,
        nm_complemento: this.nm_complemento_endereco,
        cd_tipo_mercado: this.tipo_mercado.cd_tipo_mercado,
        nm_pais_ext: this.pais,
        nm_estado_ext: this.natural_estado,
        nm_cidade_ext: this.natural_cidade,
        nm_bairro: this.bairro,
        cd_cidade: this.natural_cidade.cd_cidade,
        cd_estado: this.natural_estado.cd_estado,
        cd_pais: this.pais.cd_pais,
        cd_cnpj: this.cd_cnpj,
        cd_cliente_grupo: cd_cliente_grupo,
      };
      var insert_organizacao = await Incluir.incluirRegistro(
        this.api,
        this.nm_json
      );
      if (insert_organizacao[0].Cod == 0) {
        notify(insert_organizacao[0].Msg);
        this.popup_insere_empresa = true;
        return;
      }
      notify(insert_organizacao[0].Msg);
      this.cd_organizacao = insert_organizacao[0].retorno;
      this.business = insert_organizacao[0].nm_empresa;
      this.popup_insere_empresa = false;
      this.org = this.nova_organizacao;
      this.nova_organizacao_fantasia = "";

      /*---ORGANIZACAO---*/

      this.dados_lookup_organizacao = await Lookup.montarSelect(
        this.cd_empresa,
        5215
      );
      this.dataset_lookup_organizacao = JSON.parse(
        JSON.parse(JSON.stringify(this.dados_lookup_organizacao.dataset))
      );
      for (let i = 0; i < this.dataset_lookup_organizacao.length; i++) {
        this.dados_nm_organizacao.push(
          this.dataset_lookup_organizacao[i].nm_organizacao
        );
      }
    },

    async onCancelaOrganizacao() {
      this.tipo_pessoa = "";
      this.tipo_mercado = "";
      this.regiao = "";
      this.nova_organizacao = "";
      this.tipo_destinatario = "";
      this.segmento_organizacao = "";
      this.nova_organizacao_fantasia = "";
      this.popup_insere_empresa = false;
    },

    async onCancelaContato() {
      this.novo_email = "";
      this.novo_telefone = "";
      this.novo_celular = "";
      this.novo_contato = "";
      this.popup_cadastro_contato = false;
    },

    async Data(dt_picker) {
      if (dt_picker.indexOf("/") == 2) {
        //Inserido no input
        if (funcao.checarData(dt_picker)) {
          var ano2 = dt_picker.substring(6, 10);
          var mes2 = dt_picker.substring(3, 5);
          var dia2 = dt_picker.substring(0, 2);
          this.dt_picker = parseInt(ano2) + "/" + mes2 + "/" + dia2;
          if (
            this.dt_picker_retorno != "" &&
            this.dt_picker_retorno > this.dt_picker
          ) {
            return notify(
              "A data de retorno deve ser menor que a data de previsão"
            );
          }
        } else {
          this.dt_previsto_fechamento = "";
          this.dt_picker = "";
          return;
        }
      } else {
        //Inserido no Data Picker
        //FUNCAO DATA
        if (
          this.dt_picker_retorno != "" &&
          this.dt_picker_retorno > this.dt_picker
        ) {
          return notify(
            "A data de retorno deve ser menor que a data de previsão"
          );
        }
        this.dt_picker = dt_picker;
        var ano = dt_picker.substring(0, 4);
        var mes = dt_picker.substring(5, 7);
        var dia = dt_picker.substring(8, 10);
        this.dt_previsto_fechamento = dia + mes + ano;
      }
    },

    async DataRetorno(dt_picker_retorno) {
      if (dt_picker_retorno.indexOf("/") == 2) {
        //Inserido no input
        if (funcao.checarData(dt_picker_retorno)) {
          var ano2 = dt_picker_retorno.substring(6, 10);
          var mes2 = dt_picker_retorno.substring(3, 5);
          var dia2 = dt_picker_retorno.substring(0, 2);
          this.dt_picker_retorno = parseInt(ano2) + "/" + mes2 + "/" + dia2;
          if (this.dt_picker != "" && this.dt_picker_retorno > this.dt_picker) {
            return notify(
              "A data de retorno deve ser menor que a data de previsão"
            );
          }
        } else {
          this.dt_retorno = "";
          this.dt_picker_retorno = "";
          return;
        }
      } else {
        //Inserido no Data Picker
        //ESSA DATA TEM QUE SER MENOR QUE A DE CIMA
        if (this.dt_picker != "" && this.dt_picker_retorno > this.dt_picker) {
          return notify(
            "A data de retorno deve ser menor que a data de previsão"
          );
        }
        this.dt_picker_retorno = dt_picker_retorno;
        var ano = dt_picker_retorno.substring(0, 4);
        var mes = dt_picker_retorno.substring(5, 7);
        var dia = dt_picker_retorno.substring(8, 10);
        this.dt_retorno = dia + mes + ano;
      }
    },

    async FormataMoeda() {
      this.valor = await funcao.FormataValor(
        this.valor,
        this.moeda.sg_moeda_funcao || null
      );
    },

    async onCalculaTotal() {
      //Carrinho
      if (this.carrinho.length !== 0) {
        this.carrinho.map((item) => {
          item.Descrição = item.Descrição.replaceAll("'", "");
        });
        this.total_prod = this.carrinho.reduce(
          (acc, cur) =>
            acc +
              (cur.Valor &&
                parseFloat(
                  cur.Valor.replaceAll("US$", "")
                    .replaceAll("€", "")
                    .replaceAll("R$", "")
                    .replaceAll(".", "")
                    .replaceAll(",", ".")
                )) || 0,
          0
        );
        this.total_prod = this.total_prod.toLocaleString("pt-BR", {
          style: "currency",
          currency: this.moeda.sg_moeda_funcao || "BRL",
        });
      }
      if (this.total_prod == "R$ NaN") {
        this.total_prod = "R$ 0,00";
      }
      //Lista serviços
      try {
        this.total_servicos = 0;
        this.lista_servicos.map((s) => {
          s.ds_servico = s.ds_servico.replaceAll("'", "");
          s.vl_total_servico = s.qt_servico * s.vl_servico;
          this.total_servicos += parseFloat(s.vl_total_servico);
        });
        this.total_servicos = await funcao.FormataValor(
          this.total_servicos,
          this.moeda.sg_moeda_funcao
        );
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error, "Error Services Itens");
      }
      this.valor = "";
      this.carrinho_json = [
        ...JSON.parse(JSON.stringify(this.carrinho)),
        ...JSON.parse(JSON.stringify(this.lista_servicos)),
      ];
      let total_prod = funcao.RealParaInt(this.total_prod);
      let total_servicos = funcao.RealParaInt(this.total_servicos);
      this.valor = total_prod + total_servicos;
      try {
        this.valor = await funcao.FormataValor(
          this.valor,
          this.moeda.sg_moeda_funcao
        );
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error, "Error Value");
      }
    },
    async ExcluirProduto(e) {
      await this.onCalculaTotal();
      if (this.alteracao == true) {
        let cd_prod = e.data.cd_produto;
        !!cd_prod == false ? (cd_prod = e.data.Cod_Produto) : "";
        let ex = {
          cd_parametro: 11,
          cd_item_movimento: e.data.cd_item_movimento,
          cd_produto: cd_prod,
          cd_movimento: this.up_cd_oportunidade,
          vl_total_movimento: this.total_prod,
        };

        let excluir = await Incluir.incluirRegistro(this.api, ex);
        notify(excluir[0].Msg);
        this.AtualizaProduto = 0;
      }
    },

    SetaTitulo() {
      if (this.tipo_oportunidade.nm_fonte_informacao != "") {
        this.title = this.tipo_oportunidade.nm_fonte_informacao;
      }
    },
  },
};
</script>

<style scoped>
@import url("./views.css");
.quantidade {
  width: 24% !important;
}
.tres-tela {
  width: 31%;
}
.classificacao {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.column {
  height: 20px !important;
}
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}

.input-add {
  width: 97%;
  margin: 0;
  padding: 0;
}
#grid-padrao {
  height: auto;
  max-height: 70vw;
}

.margin1 {
  margin: 0.5vh 0.5vw;
  padding: none;
}

.espaco-interno {
  margin: auto 3% auto 0%;
}

.tres-partes {
  width: 31%;
}
.card1 {
  width: 100%;
}
.quantidade {
  width: 24% !important;
}
.margin5 {
  margin: 5px;
}
.card {
  width: 25vw;
}
.list {
  background: rgb(125, 180, 252);
  border-radius: 8px;
  margin: 0px;
  padding: 0;
  display: inline-block;
  vertical-align: top;
  white-space: normal;
}
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}

/* Enter and leave animations can use different */
/* durations and timing functions.              */
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
@media (max-width: 630px) {
}

@media (max-width: 970px) {
  .tres-partes {
    width: 100% !important;
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
.qdate {
  width: 310px;
  overflow-x: hidden;
}
</style>
