<template>
  <div class="shadow-2 borda-bloco">
    <transition name="slide-fade">
      <div v-if="cd_cadastro != 2 && !!tituloMenu == true && !ic_pesquisa" class="text-h6 margin1">
        {{ tituloMenu }}
      </div>
    </transition>
    <div v-if="!ic_pesquisa" class="row justify-around">
      <transition name="slide-fade">
        <div v-if="cd_cadastro == 2" class="text-h6 margin1">
          {{ tituloMenu }}
          <q-btn round color="orange-9" icon="arrow_back" size="sm" @click="AddCliente()">
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Pesquisar Cliente
            </q-tooltip>
          </q-btn>
        </div>
      </transition>

      <q-space />
    </div>
    <!-- Pesquisa Cliente -->
    <div v-if="ic_pesquisa">
      <q-input
        dense
        class="margin1"
        v-model="nm_cliente"
        color="orange-9"
        type="text"
        label="Cliente"
        :loading="loading"
        debounce="1000"
        @input="PesquisaCliente"
        @keypress.enter="TodosClientes"
      >
        <template v-slot:prepend>
          <q-icon name="contacts" />
        </template>
        <template v-slot:append>
          <q-btn
            size="sm"
            v-if="cd_cliente != 0 && ic_pesquisa_contato"
            round
            color="orange-9"
            icon="contact_page"
            :loading="load_contato"
            @click.stop="onPesquisaContato"
          >
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Pesquisar Contatos
            </q-tooltip>
          </q-btn>
          <q-btn round color="orange-9" icon="add" size="sm" @click="AddCliente()">
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Adicionar Cliente
            </q-tooltip>
          </q-btn>

          <q-icon
            v-if="nm_cliente !== ''"
            name="close"
            @click.stop="limpaCliente()"
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
          :loading="loading"
          class="margin1"
          @click="SelecionaCliente()"
        >
        </q-btn>
        <DxDataGrid
          class="margin1"
          id="grid_cliente"
          key-expr="cd_controle"
          :data-source="dataset_cliente"
          :columns="coluna_cliente"
          :show-borders="true"
          :selection="{ mode: 'single' }"
          :focused-row-enabled="true"
          :column-auto-width="config_grid.columnAutoWidth"
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
      <!-- Dados Cliente Pesquisado -->
      <transition name="slide-fade">
        <q-expansion-item
          v-if="cd_cliente != 0"
          class="margin1 shadow-1 overflow-hidden"
          style="border-radius: 30px"
          header-class="bg-primary text-white"
          expand-icon-class="text-white"
          icon="perm_identity"
          :label="`Dados do Cliente - ${cliente.nm_fantasia_cliente || ''} (${
            this.cliente.cd_cliente || ''
          })`"
        >
          <q-card>
            <q-card-section class="row">
              <q-field class="col margin1" dense rounded standout label="Fantasia" stack-label>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${cliente.nm_fantasia_cliente}` }}
                  </div>
                </template>
              </q-field>
              <q-field class="col margin1" dense rounded standout label="CNPJ" stack-label>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${CNPJ}` }}
                  </div>
                </template>
              </q-field>
              <q-field class="col margin1" dense rounded standout label="CEP" stack-label>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${CEP}` }}
                  </div>
                </template>
              </q-field>
              <q-field class="col margin1" dense rounded standout label="Endereço" stack-label>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${Endereco}` }}
                  </div>
                </template>
              </q-field>
              <q-field class="col margin1" dense rounded standout label="Numero" stack-label>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${Numero}` }}
                  </div>
                </template>
              </q-field>
              <q-field class="col margin1" dense rounded standout label="Complemento" stack-label>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${Complemento}` }}
                  </div>
                </template>
              </q-field>
              <q-field class="col margin1" dense rounded standout label="Cidade" stack-label>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${Cidade}` }}
                  </div>
                </template>
              </q-field>
              <q-field class="col margin1" dense rounded standout label="Estado" stack-label>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${Estado}` }}
                  </div>
                </template>
              </q-field>
            </q-card-section>
            <q-card-section class="row">
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Vendedor Interno"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${vendedor.nm_vendedor}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Vendedor Externo"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${vendedor_externo.nm_vendedor}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Transportadora"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${transportadora.nm_transportadora}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Condição de Pagamento"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${pagamento.nm_condicao_pagamento}` }}
                  </div>
                </template>
              </q-field>
              <q-field class="col margin1" dense rounded standout label="Frete" stack-label>
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${frete_pagamento.nm_tipo_pagamento_frete}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Forma de Pagamento"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${forma_pagamento.nm_forma_pagamento}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                v-if="cliente.nm_tabela_preco"
                class="col margin1"
                dense
                rounded
                standout
                label="Tabela de Preço"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${cliente.nm_tabela_preco}` }}
                  </div>
                </template>
              </q-field>
            </q-card-section>
            <q-card-section class="row">
              <q-select
                dense
                rounded
                standout
                stack-label
                class="col margin1"
                label="Contato"
                v-model="cliente_contato"
                option-value="cd_contato"
                option-label="nm_contato_cliente"
                :options="lookup_cliente_contato"
                @input="OnClienteContato()"
              >
                <template v-slot:prepend>
                  <q-icon name="group"></q-icon>
                </template>
                <template v-slot:append>
                  <q-btn
                    round
                    color="primary"
                    size="sm"
                    :icon="contato ? 'close' : 'add'"
                    :loading="load_contato"
                    @click="contato = !contato"
                  >
                    <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                      {{ `${contato ? 'Fechar' : 'Adicionar'} Contato` }}
                    </q-tooltip>
                  </q-btn>
                </template>
              </q-select>

              <q-select
                dense
                rounded
                standout
                stack-label
                class="col margin1"
                label="Local de Entrega"
                v-model="cliente_endereco"
                option-value="cd_tipo_enderecoA65"
                option-label="nm_tipo_enderecoA65"
                :options="lookup_cliente_endereco"
                @input="LocalEntrega()"
              >
                <template v-slot:prepend>
                  <q-icon name="group"></q-icon>
                </template>
              </q-select>

              <q-select
                dense
                rounded
                standout
                stack-label
                class="col margin1"
                label="Tipo de Faturamento"
                v-model="tipo_faturamento"
                option-value="cd_tipo_faturamento"
                option-label="nm_tipo_faturamento"
                :options="lookup_tipo_faturamento"
              >
                <template v-slot:prepend>
                  <q-icon name="attach_money"></q-icon>
                </template>
              </q-select>

              <q-select
                dense
                rounded
                standout
                stack-label
                class="col margin1"
                label="Empresa"
                v-model="cliente_empresa"
                option-value="cd_empresa"
                option-label="nm_empresa"
                :options="lookup_cliente_empresa"
              >
                <template v-slot:prepend>
                  <q-icon name="apartment"></q-icon>
                </template>
              </q-select>
            </q-card-section>
            <transition name="slide-fade">
              <q-card-section v-if="contato == true && this.cd_cliente > 0">
                <contato
                  :cd_cliente_contato="this.cd_cliente"
                  :pos_venda="this.cd_pos_venda"
                  :corID="colorID"
                  @ListaContatos="AttLookupContato($event)"
                >
                </contato>
              </q-card-section>
            </transition>

            <q-card-section v-if="cliente_contato" class="row">
              <q-input
                dense
                rounded
                standout
                class="col margin1"
                v-model="nm_email_contato_cliente"
                label="E-mail (Contato)"
              >
                <template v-slot:prepend>
                  <q-icon name="email"></q-icon>
                </template>
              </q-input>

              <q-input
                dense
                rounded
                standout
                class="col margin1"
                v-model="nm_telefone_contato"
                label="Telefone (Contato)"
              >
                <template v-slot:prepend>
                  <q-icon name="phone"></q-icon>
                </template>
              </q-input>
            </q-card-section>
          </q-card>
        </q-expansion-item>
      </transition>
      <!-- Dados Cliente Pesquisado -->
    </div>
    <!-- Pesquisa Cliente -->
    <div v-if="!ic_pesquisa">
      <q-tabs
        v-model="index"
        v-if="cd_cliente_c == 0"
        inline-label
        mobile-arrows
        align="justify"
        style="border-radius: 20px"
        :class="'bg-' + colorID + ' text-white shadow-2 margin1'"
      >
        <q-tab :name="0" icon="description" label="Dados" />
        <q-tab :name="1" icon="person" label="Cliente" />
      </q-tabs>

      <transition name="slide-fade">
        <div v-if="index == 0">
          <dx-data-grid
            class="margin1 shadow-2"
            id="grid-cliente"
            :data-source="consulta_cliente"
            :columns="columns"
            key-expr="cd_controle"
            :show-borders="true"
            :focused-row-enabled="true"
            :column-auto-width="config_grid.columnAutoWidth"
            :column-hiding-enabled="false"
            :remote-operations="false"
            :word-wrap-enabled="false"
            :allow-column-reordering="true"
            :allow-column-resizing="true"
            :row-alternation-enabled="true"
            :repaint-changes-only="true"
            :autoNavigateToFocusedRow="true"
            :cacheEnable="false"
            @row-dbl-click="onDbClick"
            @selection-Changed="onFocusedRowChanged"
            @row-removed="exclusao"
          >
            <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
            <DxGrouping :auto-expand-all="true" />
            <DxPaging :page-size="10" />
            <DxStateStoring :enabled="true" type="localStorage" storage-key="storage" />
            <DxPager
              :show-page-size-selector="true"
              :allowed-page-sizes="pageSizes"
              :show-info="true"
            />
            <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

            <DxGrouping :auto-expand-all="true" />
            <DxExport :enabled="true" />

            <DxPaging :enable="true" :page-size="10" />

            <DxStateStoring :enabled="true" type="localStorage" storage-key="storage" />
            <DxSelection mode="single" />
            <DxPager
              :show-page-size-selector="true"
              :allowed-page-sizes="pageSizes"
              :show-info="true"
            />
            <DxFilterRow :visible="false" />
            <DxHeaderFilter :visible="true" :allow-search="true" :width="400" :height="400" />
            <DxSearchPanel :visible="true" :width="300" placeholder="Procurar..." />
            <DxFilterPanel :visible="true" />
            <DxColumnFixing :enabled="false" />
            <DxColumnChooser :enabled="true" mode="select" />
            <DxEditing
              :refresh-mode="'reshape'"
              :allow-updating="false"
              :allow-adding="false"
              :allow-deleting="true"
              mode="popup"
            >
              <DxPopup :show-title="true" title="menu" :close-on-outside-click="false"> </DxPopup>
            </DxEditing>
          </dx-data-grid>
          <transition name="slide-fade">
            <q-btn
              v-if="cd_cliente_c == 0"
              :color="colorID"
              icon="refresh"
              label="Recarregar"
              rounded
              size="md"
              class="margin1"
              @click="carregaDados()"
            />
          </transition>
          <transition name="slide-fade">
            <q-btn
              v-if="cd_cliente_c == 0"
              :color="colorID"
              icon="add"
              label="Novo"
              rounded
              size="md"
              class="margin1"
              @click="onNovo()"
            />
          </transition>

          <!--API -  519 / PROCEDIMENTO - 1392 - pr_consulta_cliente_egisnet -->
        </div>
      </transition>
      <transition name="slide-fade">
        <div v-if="index == 1">
          <div class="row justify-around margin1">
            <q-select
              dense
              class="metadeTela margin1"
              @input="selec_pessoa()"
              option-value="cd_tipo_pessoa"
              option-label="nm_tipo_pessoa"
              v-model="tipo_pessoa_selecionada"
              :options="lookup_dataset"
              label="Tipo de Pessoa"
            >
              <template v-slot:prepend>
                <q-icon name="group"></q-icon>
              </template>
            </q-select>

            <q-select
              dense
              class="metadeTela items-start margin1"
              option-value="cd_status_cliente"
              option-label="nm_status_cliente"
              v-model="status_cliente"
              :options="lookup_dataset_status_cliente"
              label="Status do Cliente"
            >
              <template v-slot:prepend>
                <q-icon name="domain"></q-icon>
              </template>
            </q-select>
          </div>
          <div class="margin1" v-if="tipo_pessoa == 1">
            <!-- JURIDICA -->

            <div class="row justify-around">
              <q-input
                dense
                class="margin1 umQuartoTela"
                id="cnpj"
                @blur="SearchCNPJ()"
                mask="##.###.###/####-##"
                v-model="cd_cnpj"
                :value.sync="cd_cnpj"
                label="CNPJ"
              >
                <template v-slot:prepend>
                  <q-icon name="badge"></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="margin1 umQuartoTela"
                :loading="load"
                v-model="fantasia"
                :value.sync="this.fantasia"
                label="Nome Fantasia"
              >
                <template v-slot:prepend>
                  <q-icon name="business"></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="margin1 umQuartoTela"
                :loading="load"
                v-model="razao_social"
                :value.sync="this.razao_social"
                label="Razão Social"
              >
                <template v-slot:prepend>
                  <q-icon name="business_center"></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="margin1 umQuartoTela"
                v-model="celular"
                mask="(##) #####-####"
                label="Celular"
              >
                <template v-slot:prepend>
                  <q-icon name="smartphone"></q-icon>
                </template>
              </q-input>
            </div>

            <div class="row justify-around">
              <q-input
                dense
                v-model="data_nasc"
                class="umQuartoTela margin1"
                mask="##/##/####"
                label="Data de Abertura"
              >
                <template v-slot:prepend>
                  <q-icon name="today" />
                </template>
                <template v-slot:append>
                  <q-btn icon="event" :color="colorID" round size="sm" class="cursor-pointer">
                    <q-popup-proxy
                      mask="DD/MM/YYYY"
                      ref="qDateProxy"
                      cover
                      transition-show="scale"
                      transition-hide="scale"
                      :color="colorID"
                    >
                      <q-date id="data-pop" v-model="data_nasc" mask="DD/MM/YYYY" :color="colorID">
                        <div class="row justify-around">
                          <q-btn v-close-popup round :color="colorID" icon="close" size="sm" />
                        </div>
                      </q-date>
                    </q-popup-proxy>
                  </q-btn>
                </template>
              </q-input>
              <q-input
                dense
                class="umQuartoTela margin1"
                v-model="telefone"
                mask="(##) ####-####"
                label="Telefone Fixo"
              >
                <template v-slot:prepend>
                  <q-icon name="call"></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="umQuartoTela margin1"
                v-model="email"
                type="email"
                label="E-mail"
              >
                <template v-slot:prepend>
                  <q-icon name="mail"></q-icon>
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umQuartoTela"
                v-model="vl_capital_social"
                label="Capital Social"
                @blur="FormataVal(3)"
              >
                <template v-slot:prepend>
                  <q-icon name="attach_money" />
                </template>
              </q-input>
              <!-- Campos Faltantes
              Site
              Ramo de Atividade (Lookup)
              Inscrição Estadual, 
              Municipal
             -->
              <q-input dense class="margin1 umTercoTela" v-model="nm_dominio_cliente" label="Site">
                <template v-slot:prepend>
                  <q-icon name="language" />
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="cd_inscMunicipal"
                label="Inscrição Municipal"
                mask="NNNNNNNNNNNNNNNNNN"
              >
                <template v-slot:prepend>
                  <q-icon name="app_registration" />
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="cd_inscestadual"
                label="Inscrição Estadual"
                mask="##################"
              >
                <template v-slot:prepend>
                  <q-icon name="app_registration" />
                </template>
              </q-input>

              <!--  -->

              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="vl_renda_anual"
                label="Renda Anual"
                @blur="FormataVal(2)"
              >
                <template v-slot:prepend>
                  <q-icon name="paid" />
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="vl_renda_mensal"
                label="Renda Mensal"
                @blur="FormataVal(1)"
              >
                <template v-slot:prepend>
                  <q-icon name="attach_money" />
                </template>
              </q-input>

              <q-select
                dense
                v-if="cd_consulta == false"
                class="umTercoTela margin1"
                option-value="cd_ramo_atividade"
                option-label="nm_ramo_atividade"
                v-model="ramo_atividade"
                :options="lookup_dataset_ramo"
                label="Ramo de Atividade"
              >
                <template v-slot:prepend>
                  <q-icon name="work"></q-icon>
                </template>
              </q-select>
            </div>
            <div class="row justify-around">
              <q-input
                dense
                class="margin1 umTercoTela"
                @blur="onBuscaCep(cep)"
                v-model="cep"
                mask="#####-###"
                :value.sync="this.cep"
                label="CEP"
              >
                <template v-slot:prepend>
                  <q-icon name="travel_explore"></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="margin1 umTercoTela"
                :loading="load"
                v-model="endereco"
                :value.sync="this.endereco"
                label="Endereço"
              >
                <template v-slot:prepend>
                  <q-icon name="home"></q-icon>
                </template>
              </q-input>
              <q-input dense class="margin1 umTercoTela" v-model="numero" label="Número">
                <template v-slot:prepend>
                  <q-icon name="pin"></q-icon>
                </template>
              </q-input>
            </div>

            <div class="row justify-around">
              <q-input
                dense
                class="margin1 umQuartoTela"
                :loading="load"
                v-model="complemento"
                label="Complemento"
              >
                <template v-slot:prepend>
                  <q-icon name="info"></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="margin1 umQuartoTela"
                :loading="load"
                v-model="bairro"
                label="Bairro"
              >
                <template v-slot:prepend>
                  <q-icon name="apartment"></q-icon>
                </template>
              </q-input>

              <q-select
                dense
                label="Estado"
                class="margin1 umQuartoTela"
                v-model="estado"
                input-debounce="0"
                @input="SelecionaEstadoEndereco(true)"
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
                v-if="estado.cd_estado != undefined"
                label="Cidade"
                class="margin1 umQuartoTela"
                v-model="cidade"
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
            </div>
          </div>

          <div class="margin1" v-if="tipo_pessoa == 2">
            <!-- FISICA -->

            <div class="row justify-around margin1">
              <q-input
                dense
                class="margin1 umQuartoTela"
                id="nome-completo"
                v-model="razao_social"
                label="Nome Completo"
              >
                <template v-slot:prepend>
                  <q-icon name="person"></q-icon>
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umQuartoTela"
                v-model="fantasia"
                :value.sync="this.fantasia"
                label="Nome Social"
              >
                <template v-slot:prepend>
                  <q-icon name="business"></q-icon>
                </template>
              </q-input>

              <q-input
                dense
                v-model="data_nasc"
                class="margin1 umQuartoTela"
                mask="##/##/####"
                label="Data de Nascimento"
              >
                <template v-slot:prepend>
                  <q-icon name="today" />
                </template>
                <template v-slot:append>
                  <q-btn icon="event" :color="colorID" round size="sm" class="cursor-pointer">
                    <q-popup-proxy
                      mask="DD/MM/YYYY"
                      ref="qDateProxy"
                      cover
                      transition-show="scale"
                      transition-hide="scale"
                    >
                      <q-date id="data-pop" v-model="data_nasc" mask="DD/MM/YYYY" :color="colorID">
                        <div class="row justify-around">
                          <q-btn v-close-popup round :color="colorID" icon="close" size="sm" />
                        </div>
                      </q-date>
                    </q-popup-proxy>
                  </q-btn>
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umQuartoTela"
                v-model="celular"
                mask="(##) #####-####"
                label="Celular"
              >
                <template v-slot:prepend>
                  <q-icon name="smartphone"></q-icon>
                </template>
              </q-input>
            </div>

            <div class="row justify-around margin1">
              <q-input
                dense
                class="margin1 umQuartoTela"
                v-model="telefone"
                mask="(##) ####-####"
                label="Telefone"
              >
                <template v-slot:prepend>
                  <q-icon name="call"></q-icon>
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umQuartoTela"
                v-model="email"
                type="email"
                label="E-mail"
              >
                <template v-slot:prepend>
                  <q-icon name="mail"></q-icon>
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umQuartoTela"
                mask="##.###.###-#"
                v-model="rg"
                label="RG"
              >
                <template v-slot:prepend>
                  <q-icon name="contact_page"></q-icon>
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umQuartoTela"
                mask="###.###.###-##"
                v-model="cd_cnpj"
                label="CPF"
              >
                <template v-slot:prepend>
                  <q-icon name="assignment_ind" />
                </template>
              </q-input>
            </div>

            <div class="row justify-around margin1">
              <q-select
                dense
                class="margin1 umQuartoTela"
                option-value="cd_ramo_atividade"
                option-label="nm_ramo_atividade"
                v-model="ramo_atividade"
                :options="lookup_dataset_ramo"
                label="Ramo de Atividade"
              >
                <template v-slot:prepend>
                  <q-icon name="work"></q-icon>
                </template>
              </q-select>
              <q-select
                dense
                label="Estado Civil"
                class="margin1 umQuartoTela"
                v-model="estado_civil"
                input-debounce="0"
                :options="lokup_estado_civil"
                option-value="cd_estado_civil"
                option-label="nm_estado_civil"
              >
                <template v-slot:prepend>
                  <q-icon name="map" />
                </template>
              </q-select>

              <q-select
                dense
                label="Naturalidade - Estado"
                class="margin1 umQuartoTela"
                v-model="natural_estado"
                input-debounce="0"
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
                v-if="natural_estado.cd_estado != undefined"
                label="Naturalidade - Cidade"
                class="margin1 umQuartoTela"
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
            </div>

            <div class="row justify-around">
              <q-input dense class="margin1 umTercoTela" v-model="nm_mae" label="Nome da Mãe">
                <template v-slot:prepend>
                  <q-icon name="female" />
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="vl_renda_anual"
                label="Renda Anual"
                @blur="FormataVal(2)"
              >
                <template v-slot:prepend>
                  <q-icon name="paid" />
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="vl_renda_mensal"
                label="Renda Mensal"
                @blur="FormataVal(1)"
              >
                <template v-slot:prepend>
                  <q-icon name="attach_money" />
                </template>
              </q-input>
            </div>

            <div class="row justify-around margin1">
              <q-input
                dense
                class="margin1 umTercoTela"
                @blur="onBuscaCep(cep)"
                mask="#####-###"
                v-model="cep"
                label="CEP"
              >
                <template v-slot:prepend>
                  <q-icon name="travel_explore"></q-icon>
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="endereco"
                :loading="load"
                label="Endereço"
              >
                <template v-slot:prepend>
                  <q-icon name="home"></q-icon>
                </template>
              </q-input>
              <q-input dense class="margin1 umTercoTela" v-model="numero" label="Número">
                <template v-slot:prepend>
                  <q-icon name="pin"></q-icon>
                </template>
              </q-input>
            </div>
            <div class="row justify-around">
              <q-input
                dense
                class="margin1 umQuartoTela"
                v-model="complemento"
                :loading="load"
                label="Complemento"
              >
                <template v-slot:prepend>
                  <q-icon name="info"></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="margin1 umQuartoTela"
                v-model="bairro"
                :loading="load"
                label="Bairro"
              >
                <template v-slot:prepend>
                  <q-icon name="apartment"></q-icon>
                </template>
              </q-input>

              <q-select
                dense
                label="Estado"
                class="margin1 umQuartoTela"
                v-model="estado"
                input-debounce="0"
                @input="SelecionaEstadoEndereco(true)"
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
                v-if="estado.cd_estado != undefined"
                label="Cidade"
                class="margin1 umQuartoTela"
                v-model="cidade"
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
            </div>
          </div>

          <div class="row">
            <q-btn
              rounded
              class="margin1"
              :color="colorID"
              icon="save"
              label="Gravar"
              @click="onGravar()"
            />
            <q-space />
            <q-btn
              class="margin1"
              :color="colorID"
              rounded
              icon="contact_mail"
              label="Contato"
              @click="onContato()"
            />
          </div>
          <transition name="slide-fade">
            <contato
              v-if="contato == true && this.cd_cliente > 0"
              :cd_cliente_contato="this.cd_cliente"
              :pos_venda="this.cd_pos_venda"
              :corID="colorID"
            >
            </contato>
          </transition>

          <endereco
            ref="enderecoCliente"
            v-if="cd_cliente_endereco > 0"
            :cd_cliente="this.cd_cliente_endereco"
          />
        </div>
      </transition>
    </div>
    <!---CARREGANDO----------------------------------->
    <q-dialog v-model="carregando" maximized persistent>
      <carregando></carregando>
    </q-dialog>
    <!------------------------------------------------->
  </div>
</template>

<script>
import Menu from '../http/menu'
import Procedimento from '../http/procedimento'
import select from '../http/select'
import config from 'devextreme/core/config'
import { loadMessages, locale } from 'devextreme/localization'
import notify from 'devextreme/ui/notify'
import ptMessages from 'devextreme/localization/messages/pt.json'
import { DxPopup } from 'devextreme-vue/popup'
import carregando from '../components/carregando.vue'
import contato from '../views/contato'
import formataData from '../http/formataData'
import funcao from '../http/funcoes-padroes'
import Incluir from '../http/incluir_registro'
import Lookup from '../http/lookup'

import { DxDataGrid, DxExport, DxPaging, DxEditing, DxSelection } from 'devextreme-vue/data-grid'

import {
  DxColumnChooser,
  DxGrouping,
  DxGroupPanel,
  DxPager,
  DxSearchPanel,
  DxHeaderFilter,
  DxFilterPanel,
  DxStateStoring,
  DxFilterRow,
  DxColumnFixing,
} from 'devextreme-vue/data-grid'

export default {
  name: 'cliente',
  props: {
    cd_cadastro: { type: Number, default: 2 },
    cd_cliente_c: { type: Number, default: 0 },
    cd_cliente_props: { type: Number, default: 0 },
    cd_usuario: { type: String, default: '' },
    cd_consulta: { type: Boolean, default: false },
    ic_pesquisa: { type: Boolean, default: false },
    ic_pesquisa_contato: { type: Boolean, default: true },
    cd_cadastro_c: { type: Boolean, default: false },
    att_endereco: { type: Object, default: null },
    colorID: { type: String, default: 'primary' },
    config_grid: {
      type: Object,
      default: () => ({
        columnAutoWidth: false,
      }),
    },
  },

  data() {
    return {
      longtabs: [
        { text: 'Dados', id: 0 },
        { text: 'Cliente', id: 1 },
      ],
      tituloMenu: '',
      ramo_atividade: '',
      columns: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      nm_mae: '',
      carregando: false,
      cd_empresa: localStorage.cd_empresa,
      cd_cliente: 0,
      api: '562/781', //pr_egisnet_elabora_proposta
      cd_cnpj: '',
      load: false,
      linha: {},
      lokup_estado_civil: [],
      fantasia: '',
      razao_social: '',
      vl_capital_social: '',
      nome: '',
      data_nasc: '',
      rg: '',
      cd_cliente_endereco: 0,
      nm_dominio_cliente: '',
      cd_inscMunicipal: '',
      cd_inscestadual: '',
      // Pesquisa Cliente
      nm_cliente: '',
      loading: false,
      load_contato: false,
      GridCli: false,
      resultado_pesquisa_cliente: [],
      resultado_pesquisa_contato: [],
      nm_email_contato_cliente: '',
      nm_telefone_contato: '',
      dataset_cliente: [],
      coluna_cliente: [],
      cliente_selecionado: '',
      CNPJ: '',
      Insc_Estadual: '',
      Insc_Municipal: '',
      CEP: '',
      Endereco: '',
      Numero: '',
      Complemento: '',
      Bairro: '',
      Cidade: '',
      Estado: '',
      vendedor_api: '',
      vendedor: '',
      vendedor_externo: '',
      transportadora: '',
      destinacao: '',
      tipo_pedido: '',
      tipo_endereco: '',
      pagamento: '',
      frete_pagamento: '',
      forma_pagamento: '',
      resultado_contato: '',
      popup_contato: '',
      cliente_popup: '',
      selecao_contato: '',
      contato_selecionado: '',
      selecao: '',
      //Contato do Cliente
      cliente_contato: '',
      lookup_cliente_contato: [],
      // Endereco do Cliente
      cliente_endereco: '',
      lookup_cliente_endereco: [],
      //Tipo de Faturamento
      tipo_faturamento: '',
      lookup_tipo_faturamento: [],
      //Cliente Empresa
      cliente_empresa: '',
      lookup_cliente_empresa: [],
      // Pesquisa Cliente
      cpf: '',
      cep: '',
      bairro: '',
      endereco: '',
      numero: '',
      complemento: '',
      cidade: '',
      estado: '',
      natural_estado: '',
      cd_pais: 0,
      consulta_cliente: [],
      lookup_dataset: [],
      lookup_dados: [],
      carrega_cidade: false,
      lookup_dataset_status_cliente: [],
      lookup_status_cliente: [],
      lookup_ramo: [],
      lookup_dataset_ramo: [],
      email: '',
      lookup_estado_natural: [],
      lookup_cidade_natural: [],
      lookup_cidade_filtrado: [],
      natural_cidade: '',
      tipo_pessoa: 0,
      contato: false,
      estado_civil: '',
      telefone: '',
      vl_renda_anual: '',
      alteracao: false,
      vl_renda_mensal: '',
      tipo_pessoa_selecionada: '',
      status_cliente: '',
      cliente: {},
      index: 0,
      cd_pos_venda: 0,
      export: {},
    }
  },

  async created() {
    config({ defaultCurrency: 'BRL' })
    loadMessages(ptMessages)
    locale(navigator.language)
    if (this.cd_usuario) {
      this.vendedor_api = await funcao.buscaVendedor(this.cd_usuario)
    }
    this.carregaDados()
    let e = await Lookup.montarSelect(this.cd_empresa, 373)
    this.lokup_estado_civil = JSON.parse(JSON.parse(JSON.stringify(e.dataset)))
    let lokup_cidade = await Lookup.montarSelect(this.cd_empresa, 97)
    this.lookup_cidade_natural = JSON.parse(JSON.parse(JSON.stringify(lokup_cidade.dataset)))
    if (this.cd_consulta == true) {
      this.tituloMenu = 'Dados do Cliente'
      if (this.cd_cliente_c) {
        this.cd_cliente = this.cd_cliente_c
        this.consultaCliente()
        this.index = 1
      }
      this.index = 1
      this.contato = true
      this.cd_pos_venda = 1
    } else {
      this.tituloMenu = 'Cadastro de Clientes'
    }
    if (this.cd_cadastro_c == true) {
      this.onNovo()
    }
    //await this.showMenu();
  },

  async mounted() {
    this.lookup_dados = await Lookup.montarSelect(this.cd_empresa, 116)
    this.lookup_dataset = JSON.parse(JSON.parse(JSON.stringify(this.lookup_dados.dataset)))
    this.lookup_status_cliente = await Lookup.montarSelect(this.cd_empresa, 107)
    this.lookup_dataset_status_cliente = JSON.parse(
      JSON.parse(JSON.stringify(this.lookup_status_cliente.dataset))
    )

    var lookup_estado = await Lookup.montarSelect(this.cd_empresa, 731)
    var lokup = JSON.parse(JSON.parse(JSON.stringify(lookup_estado.dataset)))
    this.lookup_estado_natural = lokup.filter((element) => element.cd_pais == 1)
    if (this.cd_empresa == 150 || this.cd_empresa == 116) {
      this.status_cliente = {
        cd_status_cliente: 1,
        nm_status_cliente: 'Ativo',
        ic_dado_obrigatorio: 'N',
      }
    }

    this.lookup_ramo = await Lookup.montarSelect(this.cd_empresa, 92)
    this.lookup_dataset_ramo = JSON.parse(JSON.parse(JSON.stringify(this.lookup_ramo.dataset)))
  },

  components: {
    DxDataGrid,
    DxPopup,
    DxExport,
    DxPaging,
    DxSelection,
    DxColumnChooser,
    DxEditing,
    DxGrouping,
    DxGroupPanel,
    DxPager,
    DxSearchPanel,
    DxHeaderFilter,
    DxFilterPanel,
    DxStateStoring,
    DxFilterRow,
    endereco: () => import('../views/cliente_endereco.vue'),
    DxColumnFixing,
    carregando,
    contato,
  },
  watch: {
    async cd_cliente() {
      this.cd_cliente_endereco = this.cd_cliente
      this.contato = false
      await this.sleep(500)
      //this.contato = true;
    },
    cd_cliente_c() {
      this.consultaCliente()
    },
    async cd_cliente_props(a) {
      if (a > 0) {
        let json_pesquisa = {
          cd_parametro: 6,
          cd_cliente: a,
        }
        ;[this.cliente_selecionado] = await Incluir.incluirRegistro(
          '911/1412', //this.api,
          json_pesquisa
        )
        await this.SelecionaCliente()
      }
      if (a == 0) {
        this.cd_cliente = 0
        this.cliente = ''
        this.linha = {}
      }
    },
    async index() {
      if (this.alteracao == false) {
        await this.tabPanelTitleClick(this.index)
      }
      if (this.index == 0) {
        this.alteracao = false
      }
      if (this.index == 0) {
        await this.carregaDados()
      }
    },
    att_endereco() {
      this.CEP = this.att_endereco.cep
      this.Endereco = this.att_endereco.logradouro
      this.Numero = '' //this.att_endereco
      this.Complemento = this.att_endereco.complemento
      this.Cidade = this.att_endereco.nm_cidade
      this.Estado = this.att_endereco.nm_estado
    },
  },
  methods: {
    limpaCliente() {
      this.cliente = ''
      this.nm_cliente = ''
      this.GridCli = false
      this.limpatudo()
      this.$emit('limpaCliente', '')
    },
    async FormataVal(index) {
      if (index == 1 && this.vl_renda_mensal != '') {
        this.vl_renda_mensal = await funcao.FormataValor(this.vl_renda_mensal)
      } else if (index == 2 && this.vl_renda_anual != '') {
        this.vl_renda_anual = await funcao.FormataValor(this.vl_renda_anual)
        this.vl_renda_mensal = await funcao.Divisao(this.vl_renda_anual, 12)
      } else if (index == 3 && this.vl_capital_social != '') {
        this.vl_capital_social = await funcao.FormataValor(this.vl_capital_social)
      }
    },

    async SelecionaEstado(limpa) {
      this.carrega_cidade = true
      if (limpa == true) {
        this.natural_cidade = ''
      }
      let estado = this.natural_estado
      this.lookup_cidade_filtrado = this.lookup_cidade_natural.filter(
        (element) => element.cd_estado == estado.cd_estado
      )

      this.carrega_cidade = false
    },

    async SelecionaEstadoEndereco(limpa) {
      this.carrega_cidade = true
      if (limpa == true) {
        this.cidade = ''
      }
      let estado = this.estado
      this.lookup_cidade_filtrado = this.lookup_cidade_natural.filter(
        (element) => element.cd_estado == estado.cd_estado
      )

      this.carrega_cidade = false
    },
    async sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms))
    },

    async PesquisaCliente() {
      this.loading = true
      this.GridCli = false
      if (this.resultado_pesquisa_cliente.length == 0) {
        let menu_grid_cliente = await Menu.montarMenu(
          this.cd_empresa,
          7467, // Procedimento 1582
          562 //pr_egisnet_elabora_proposta - Procedimento 1439
        )
        this.coluna_cliente = JSON.parse(JSON.parse(JSON.stringify(menu_grid_cliente.coluna)))

        let json_pesquisa_cliente = {
          cd_parametro: 0,
          cd_vendedor: this.vendedor_api.cd_vendedor,
        }
        this.resultado_pesquisa_cliente = await Incluir.incluirRegistro(
          this.api, //pr_egisnet_elabora_proposta
          json_pesquisa_cliente
        )
      }
      if (parseInt(this.nm_cliente)) {
        this.dataset_cliente = this.resultado_pesquisa_cliente.filter(
          (f) => f.cd_cliente == this.nm_cliente
        )
      } else {
        this.dataset_cliente = this.resultado_pesquisa_cliente.filter((f) =>
          f.Fantasia.toUpperCase().includes(this.nm_cliente.toUpperCase())
        )
      }
      if (this.resultado_pesquisa_cliente[0].Cod == 0) {
        notify(this.resultado_pesquisa_cliente[0].Msg)
        return
      } else {
        this.loading = false
        this.GridCli = true
      }
    },

    async TodosClientes() {
      if (this.nm_cliente == '') {
        await this.PesquisaCliente()
      }
    },

    async onPesquisaContato() {
      let json_pesquisa = {
        cd_parametro: 2,
        cd_cliente: this.cd_cliente,
      }
      this.load_contato = true
      this.resultado_contato = await Incluir.incluirRegistro(this.api, json_pesquisa)
      this.load_contato = false
      if (this.resultado_contato[0].Cod == 0) {
        notify('Nenhum contato encontrado...')
        return
      }
      notify(this.resultado_contato[0].Msg)
      this.popup_contato = !this.popup_contato
    },
    AddCliente() {
      this.ic_pesquisa = !this.ic_pesquisa
    },
    async SelecionaCliente(cliente) {
      this.loading = true
      if (cliente) {
        this.cliente_selecionado = cliente
      }
      this.$emit('SelectCliente', this.cliente_selecionado)
      let {
        Fantasia = '',
        Razao_Social = '',
        Telefone_Empresa = '',
        Telefone = '',
        CNPJ = '',
        nm_dominio_cliente = '',
        Tipo_Pessoa = '',
        Ramo_Atividade = '',
        Status_Cliente = '',
        cd_vendedor = '',
        Vendedor = '',
        cd_vendedor_interno = '',
        Vendedor_Interno = '',
        cd_transportadora = '',
        Transportadora = '',
        cd_destinacao_produto = '',
        Destinacao_Produto = '',
        cd_tipo_pedido = '',
        Tipo_Pedido = '',
        cd_tipo_endereco = '',
        Tipo_Endereco = '',
        cep_entrega = '',
        endereco_entrega = '',
        numero_entrega = '',
        complemento_entrega = '',
        bairro_entrega = '',
        estado_entrega = '',
        cidade_entrega = '',
        referencia_entrega = '',
        CEP = '',
        Email = '',
        Endereco = '',
        Numero = '',
        Complemento = '',
        Bairro = '',
        Cidade = '',
        Estado = '',
        Insc_Estadual = '',
        Insc_Municipal = '',
        cd_condicao_pagamento = '',
        Condicao_Pagamento = '',
        qt_parcela_condicao_pgto = '',
        cd_forma_pagamento = '',
        Forma_Pagamento = '',
        cd_tipo_pagamento_frete = '',
        Tipo_Pagamento_Frete = '',
        cd_tipo_faturamento = '',
        nm_tipo_faturamento = '',
      } = this.cliente_selecionado
      this.cd_cliente = this.cliente_selecionado.cd_cliente
      let contatos_json = {
        cd_empresa: this.cd_empresa,
        cd_tabela: 111,
        order: 'D',
        where: [{ cd_cliente: this.cd_cliente }],
      }
      let contatos = await select.montarSelect(this.cd_empresa, contatos_json)
      if (contatos[0].dataset !== null) {
        this.lookup_cliente_contato = JSON.parse(JSON.parse(JSON.stringify(contatos[0].dataset)))
        this.cliente_contato = this.lookup_cliente_contato[0]
        await this.OnClienteContato()
      }
      ////Endereço do Cliente
      let endereco_json = {
        cd_empresa: this.cd_empresa,
        cd_tabela: 121,
        order: 'D',
        join: 'Tipo_Endereco',
        where: [{ cd_cliente: this.cd_cliente }],
      }
      let endereco = await select.montarSelect(this.cd_empresa, endereco_json)
      this.lookup_cliente_endereco = JSON.parse(JSON.parse(JSON.stringify(endereco[0].dataset)))
      ////Tipo de Faturamento
      this.lookup_tipo_faturamento = await Lookup.montarSelect(this.cd_empresa, 3931)
      this.lookup_tipo_faturamento = JSON.parse(
        JSON.parse(JSON.stringify(this.lookup_tipo_faturamento.dataset))
      )
      this.tipo_faturamento = this.lookup_tipo_faturamento ? this.lookup_tipo_faturamento[0] : null
      //Cliente Empresa//
      let cliente_empresa_json = {
        cd_empresa: this.cd_empresa,
        cd_tabela: 5488,
        order: 'D',
        join: 'Empresa',
        where: [{ cd_cliente: this.cd_cliente }],
      }
      let cliente_empresa = await select.montarSelect(this.cd_empresa, cliente_empresa_json)
      this.lookup_cliente_empresa = JSON.parse(
        JSON.parse(JSON.stringify(cliente_empresa[0].dataset))
      )
      //Cliente//
      Fantasia == null ? (this.Fantasia = '') : (this.Fantasia = Fantasia)
      Razao_Social == null ? (this.Razao_Social = '') : (this.Razao_Social = Razao_Social)
      Telefone_Empresa == null || Telefone_Empresa == ''
        ? (this.Telefone_Empresa = null)
        : (this.Telefone_Empresa = Telefone_Empresa)
      this.Telefone_Empresa == null && Telefone != null
        ? (this.Telefone_Empresa = Telefone)
        : (this.Telefone_Empresa = '')
      nm_dominio_cliente == null
        ? (this.nm_dominio_cliente = '')
        : (this.nm_dominio_cliente = nm_dominio_cliente)
      Email == null ? (this.Email = '') : (this.Email = Email)
      Tipo_Pessoa == null ? (this.Tipo_Pessoa = '') : (this.Tipo_Pessoa = Tipo_Pessoa)
      Ramo_Atividade == null ? (this.Ramo_Atividade = '') : (this.Ramo_Atividade = Ramo_Atividade)
      Status_Cliente == null ? (this.Status_Cliente = '') : (this.Status_Cliente = Status_Cliente)
      this.CNPJ = CNPJ
      // this.CNPJ.length == 11
      //   ? funcao.FormataCPF(this.CNPJ).then((e) => {
      //       this.CNPJ = e;
      //     })
      //   : funcao.FormataCNPJ(this.CNPJ).then((e) => {
      //       this.CNPJ = e;
      //     });
      this.Insc_Estadual == null ? (this.Insc_Estadual = '') : (this.Insc_Estadual = Insc_Estadual)
      this.Insc_Municipal == null
        ? (this.Insc_Municipal = '')
        : (this.Insc_Municipal = Insc_Municipal)
      this.CEP == null ? (this.CEP = '') : (this.CEP = CEP)
      this.Endereco == null ? (this.Endereco = '') : (this.Endereco = Endereco)
      this.Numero == null ? (this.Numero = '') : (this.Numero = Numero)
      this.Complemento == null ? (this.Complemento = '') : (this.Complemento = Complemento)
      this.Bairro == null ? (this.Bairro = '') : (this.Bairro = Bairro)
      this.Cidade == null ? (this.Cidade = '') : (this.Cidade = Cidade)
      this.Estado == null ? (this.Estado = '') : (this.Estado = Estado)
      //Proposta//
      this.vendedor = {
        cd_vendedor: cd_vendedor_interno,
        nm_vendedor: Vendedor_Interno,
      }

      this.vendedor_externo = {
        cd_vendedor: cd_vendedor,
        nm_vendedor: Vendedor,
      }

      this.transportadora = {
        cd_transportadora: cd_transportadora,
        nm_transportadora: Transportadora,
      }

      this.destinacao = {
        cd_destinacao_produto: cd_destinacao_produto,
        nm_destinacao_produto: Destinacao_Produto,
      }
      this.tipo_pedido = {
        cd_tipo_pedido: cd_tipo_pedido,
        nm_tipo_pedido: Tipo_Pedido,
      }

      this.tipo_faturamento = {
        cd_tipo_faturamento: cd_tipo_faturamento,
        nm_tipo_faturamento: nm_tipo_faturamento,
      }

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
      }

      //Pagamento//

      this.pagamento = {
        cd_condicao_pagamento: cd_condicao_pagamento,
        nm_condicao_pagamento: Condicao_Pagamento,
        qt_parcela_condicao_pgto: qt_parcela_condicao_pgto,
      }
      this.frete_pagamento = {
        cd_tipo_pagamento_frete: cd_tipo_pagamento_frete,
        nm_tipo_pagamento_frete: Tipo_Pagamento_Frete,
      }
      this.forma_pagamento = {
        cd_forma_pagamento: cd_forma_pagamento,
        nm_forma_pagamento: Forma_Pagamento,
      }
      this.cliente = {
        cd_cliente: this.cliente_selecionado.cd_cliente,
        nm_fantasia_cliente: this.cliente_selecionado.Fantasia,
        nm_tabela_preco: this.cliente_selecionado.nm_tabela_preco,
      }
      this.resultado_contato = []
      this.popup_contato = false
      //await this.onPesquisaContato();
      this.GridCli = false
      this.cliente_popup = false
      this.selecao_contato = false
      this.contato_selecionado = []
      this.selecao = true
      this.loading = false
    },
    LinhaGridCliente: function (e) {
      this.cliente_selecionado = e.row && e.row.data
    },

    async carregaDados() {
      let dados_linha = await Menu.montarMenu(localStorage.cd_empresa, 0, 519) //pr_consulta_cliente_egisnet
      let api = dados_linha.nm_identificacao_api
      let sParametroApi = dados_linha.nm_api_parametro
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados_linha.coluna)))
      this.consulta_cliente = []
      localStorage.cd_parametro = 0

      this.consulta_cliente = await Procedimento.montarProcedimento(
        this.cd_empresa,
        0,
        api,
        sParametroApi
      )
    },

    async SearchCNPJ() {
      if (this.cd_cnpj == '') return
      try {
        if (this.cd_cnpj.length < 18) {
          notify('Digite o CNPJ corretamente')
          return
        }
        //else {
        //  var response = await funcao.BuscaCNPJ(this.cd_cnpj)
        //  this.fantasia = response.nm_fantasia_cnpj
        //  this.razao_social = response.nm_razao_social_cnpj
        //  this.data_nasc = response.dt_abertura
        //  this.telefone = response.cd_telefone_cnpj
        //  this.email = response.nm_email
        //  this.vl_capital_social = response.vl_capital_social
        //  this.cep = response.cd_cep
        //  this.endereco = response.nm_endereco_cnpj
        //  this.numero = response.cd_numero_cnpj
        //  this.complemento = response.nm_complemento
        //  this.bairro = response.nm_bairro
        //  this.cd_inscestadual = response.cd_inscestual
        //  if (response.cd_estado) {
        //    let est = this.lookup_estado.find((e) => {
        //      return (e.cd_estado = response.cd_estado)
        //    })
        //    if (est) {
        //      this.estado = est
        //    }
        //  }
        //  if (response.cd_cidade) {
        //    let cid = this.lookup_cidade_natural.find((e) => {
        //      return (e.cd_cidade = response.cd_cidade)
        //    })
        //    if (cid) {
        //      this.cidade = cid
        //    }
        //  }
        //}
        this.load = true

        localStorage.cd_cnpj = this.cd_cnpj
          .replace('.', '')
          .replace('.', '')
          .replace('/', '')
          .replace('-', '')
        this.cd_cnpj = this.cd_cnpj
          .replace('.', '')
          .replace('.', '')
          .replace('/', '')
          .replace('-', '')

        if (this.cd_cnpj.includes('_') == false) {
          this.dataSourceConfig = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            '400/534',
            '/${cd_empresa}/${cd_cnpj}'
          )
        } else {
          this.cd_cnpj = ''
          notify('CNPJ Não encontrado!')
        }
        //carrega os dados do cliente
        this.razao_social = this.dataSourceConfig[0].nm_razao_social
          ? this.dataSourceConfig[0].nm_razao_social
          : ''
        this.cep = this.dataSourceConfig[0].nm_cep
          ? this.dataSourceConfig[0].nm_cep.replace('.', '')
          : ''
        this.bairro = this.dataSourceConfig[0].nm_bairro ? this.dataSourceConfig[0].nm_bairro : ''
        this.endereco = this.dataSourceConfig[0].nm_endereco
          ? this.dataSourceConfig[0].nm_endereco
          : ''
        this.numero = this.dataSourceConfig[0].cd_numero ? this.dataSourceConfig[0].cd_numero : ''
        this.complemento = this.dataSourceConfig[0].nm_complemento
          ? this.dataSourceConfig[0].nm_complemento
          : ''
        if (this.dataSourceConfig[0].cd_estado) {
          this.estado = this.dataSourceConfig[0].cd_estado
            ? await this.lookup_estado_natural.find(
                (element) => element.cd_estado == this.dataSourceConfig[0].cd_estado
              )
            : null
          this.cidade = this.dataSourceConfig[0].cd_cidade
            ? this.lookup_cidade_natural.find(
                (element) => element.cd_cidade == this.dataSourceConfig[0].cd_cidade
              )
            : null
          this.lookup_cidade_filtrado = this.estado.cd_estado
            ? this.lookup_cidade_natural.filter(
                (element) => element.cd_estado == this.estado.cd_estado
              )
            : null
        }
        this.cd_pais = this.dataSourceConfig[0].cd_pais ? this.dataSourceConfig[0].cd_pais : 0
        this.data_nasc = this.dataSourceConfig[0].dt_abertura
          ? this.dataSourceConfig[0].dt_abertura
          : ''
        this.email = this.dataSourceConfig[0].nm_email ? this.dataSourceConfig[0].nm_email : ''
        this.fantasia = this.dataSourceConfig[0].nm_fantasia
          ? this.dataSourceConfig[0].nm_fantasia
          : ''
        this.telefone = this.dataSourceConfig[0].nm_telefone
          ? this.dataSourceConfig[0].nm_telefone
          : ''
        this.vl_capital_social = this.dataSourceConfig[0].vl_capital_social
          ? this.dataSourceConfig[0].vl_capital_social
          : ''
        this.FormataVal(3)
        if (!!this.cep == true) {
          await this.onBuscaCep()
        }
      } catch (error) {
        console.error(error)
      } finally {
        this.load = false
      }
    },

    onDbClick(e) {
      this.$emit('DbClick', e.data)
    },

    // eslint-disable-next-line no-unused-vars
    onFocusedRowChanged({ selectedRowKeys, selectedRowsData }) {
      this.tipo_pessoa = selectedRowsData[0].cd_tipo_pessoa
      this.linha = selectedRowsData[0]
    },

    async exclusao(e) {
      let line = e.data
      var api = '472/666' // Procedimento 1345 - pr_egisnet_cadastra_cliente
      let ex = {
        cd_parametro: 2,
        cd_cliente: line.cd_cliente,
      }
      var exc = await Incluir.incluirRegistro(api, ex)
      notify(exc[0].Msg)
      this.carregaDados()
    },

    async onBuscaCep() {
      this.load = true
      localStorage.cd_cep = this.cep.replace('-', '')
      if (this.cep.includes('_') == false) {
        if (!this.cep) {
          try {
            this.dataSourceConfig = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_cliente,
              '413/550',
              '/${cd_empresa}/${cd_cep}'
            )
            if (!this.dataSourceConfig[0].cep) {
              notify('CEP Não encontrado!')
              this.load = false
              return
            }
            this.endereco = this.dataSourceConfig[0].logradouro ?? ''
            this.bairro = this.dataSourceConfig[0].bairro ?? ''
            this.complemento = this.dataSourceConfig[0].complemento ?? ''
            if (this.dataSourceConfig[0].cd_estado) {
              this.estado = this.dataSourceConfig[0].cd_estado
                ? this.lookup_estado_natural.find(
                    (element) => element.cd_estado == this.dataSourceConfig[0].cd_estado
                  )
                : ''
              let cidade_obj = this.dataSourceConfig[0].cd_cidade
                ? this.lookup_cidade_natural.filter(
                    (element) => element.cd_cidade == this.dataSourceConfig[0].cd_cidade
                  )
                : ''
              this.cidade = cidade_obj[0]
              this.lookup_cidade_filtrado = this.estado.cd_estado
                ? this.lookup_cidade_natural.filter(
                    (element) => element.cd_estado == this.estado.cd_estado
                  )
                : ''
            }
            this.cd_pais = this.dataSourceConfig[0].cd_pais ?? 0
          } catch (err) {
            // eslint-disable-next-line no-console
            console.error(err)
          } finally {
            this.load = false
          }
        }
      }
      this.load = false
    },

    onContato() {
      this.contato = !this.contato
    },

    async ValidaIntermedium() {
      let ret = true

      if (this.rg == '' && this.tipo_pessoa == 2) {
        notify('Digite o RG Completo!')
        ret = false
      }

      if (this.razao_social == '') {
        notify('Digite o Nome Completo!')
        ret = false
      }
      if (this.vl_capital_social == '' && this.tipo_pessoa == 1) {
        notify('Digite o capital social!')
        ret = false
      }
      if (this.estado_civil == '' && this.tipo_pessoa == 2) {
        notify('Selecione o Estado Civil!')
        ret = false
      }
      if (this.fantasia == '') {
        notify('Digite o Nome Fantasia!')
        ret = false
      }
      if (this.data_nasc == '') {
        notify('Digite a data de nascimento!')
        ret = false
      }
      if (this.celular == '') {
        notify('Digite o Celular!')
        ret = false
      }
      if (this.telefone == '') {
        notify('Digite o Telefone!')
        ret = false
      }
      if (this.email == '') {
        notify('Digite o E-mail!')
        ret = false
      }
      if (this.cd_cnpj == '') {
        notify('Digite o CNPJ/CPF!')
        ret = false
      }
      if (this.natural_cidade == '' && this.tipo_pessoa == 2) {
        notify('Selecione a Naturalidade - Cidade!')
        ret = false
      }
      if (this.natural_estado == '' && this.tipo_pessoa == 2) {
        notify('Selecione a Naturalidade - Estado!')
        ret = false
      }
      if (this.nm_mae == '' && this.tipo_pessoa == 2) {
        notify('Digite o Nome da Mãe!')
        ret = false
      }
      if (this.vl_renda_anual == '' && this.tipo_pessoa == 2) {
        notify('Digite a Renda Anual!')
        ret = false
      }
      if (this.vl_renda_mensal == '' && this.tipo_pessoa == 2) {
        notify('Digite a Renda Mensal!')
        ret = false
      }
      if (this.cep == '') {
        notify('Digite o CEP!')
        ret = false
      }
      if (this.endereco == '') {
        notify('Digite o Endereço!')
        ret = false
      }
      if (this.numero == '') {
        notify('Digite o Número!')
        ret = false
      }
      if (this.bairro == '') {
        notify('Digite o Bairro!')
        ret = false
      }
      if (this.cidade == '') {
        notify('Digite a Cidade do Endereço!')
        ret = false
      }
      if (this.estado == '') {
        notify('Digite o Estado do Endereço!')
        ret = false
      }
      return ret
    },

    async onGravar() {
      let retorno
      if (this.cd_empresa == 150) {
        retorno = await this.ValidaIntermedium()
        if (retorno == false) {
          return retorno
        }
      }

      var api = '472/666' // Procedimento 1345 - pr_egisnet_cadastra_cliente
      if (this.data_nasc != null) {
        var data_salvar = formataData.formataDataSQL(this.data_nasc)
        // this.data_nasc = formataData.formataDataSQL(this.data_nasc);
      }
      if (this.ramo_atividade == undefined) {
        this.ramo_atividade = ''
      }
      if (this.tipo_pessoa_selecionada == '') {
        notify('Selecione o tipo de pessoa!')
        return retorno
      }
      if (!this.razao_social) {
        notify('Por favor, digite o Nome!')
        return retorno
      }

      if (this.status_cliente == null) {
        this.status_cliente = {
          cd_status_cliente: 9,
          nm_status_cliente: 'PROSPECT',
          ic_dado_obrigatorio: 'N',
        }
      }
      this.carregando = true
      var cd_parametro = 0
      this.cd_cliente = this.cd_cliente_c != 0 ? this.cd_cliente_c : this.cd_cliente
      if (this.cd_cliente == 0) {
        cd_parametro = 0 //Insere
      } else {
        cd_parametro = 1 //Atualiza
      }

      //this.cd_cnpj = await funcao.FormataCNPJ(this.cd_cnpj);

      let cli = {
        cd_cep: this.cep,
        cd_numero_endereco: this.numero,
        cd_tipo_pessoa: this.tipo_pessoa_selecionada.cd_tipo_pessoa,
        cd_parametro: cd_parametro,
        cd_cliente: this.cd_cliente == 0 ? this.cd_cliente_c : this.cd_cliente,
        cd_usuario: localStorage.cd_usuario,
        nm_razao_social_cliente: funcao.ValidaString(this.razao_social, 60),
        nm_fantasia_cliente: funcao.ValidaString(this.fantasia, 30),
        nm_bairro: funcao.ValidaString(this.bairro, 60),
        nm_endereco_cliente: funcao.ValidaString(this.endereco, 60),
        nm_complemento_endereco: funcao.ValidaString(this.complemento, 60),
        nm_dominio_cliente: funcao.ValidaString(this.nm_dominio_cliente, 100),
        cd_inscMunicipal: this.cd_inscMunicipal,
        cd_inscestadual: this.cd_inscestadual,
        cd_estado: this.estado.cd_estado,
        cd_cidade: this.cidade.cd_cidade,
        cd_pais: this.cd_pais,
        cd_telefone: this.telefone,
        cd_celular_cliente: this.celular,
        cd_cnpj_cliente: this.cd_cnpj,
        nm_email_cliente: funcao.ValidaString(this.email, 150),
        cd_rg_cliente: this.rg,
        dt_aniversario_cliente: data_salvar,
        cd_ramo_atividade: this.ramo_atividade.cd_ramo_atividade,
        cd_status_cliente: this.status_cliente.cd_status_cliente,
        ic_dado_obrigatorio: this.status_cliente.ic_dado_obrigatorio,
        cd_cidade_nascimento: this.natural_cidade.cd_cidade,
        cd_estado_nascimento: this.natural_estado.cd_estado,
        nm_mae: funcao.ValidaString(this.nm_mae),
        cd_estado_civil: this.estado_civil.cd_estado_civil,
        vl_renda_mensal: this.vl_renda_mensal,
        vl_renda_anual: this.vl_renda_anual,
        vl_capital_social: this.vl_capital_social,
      }
      if (this.cd_empresa == 150) {
        this.status_cliente.ic_dado_obrigatorio = 'N'
      }
      if (this.status_cliente.ic_dado_obrigatorio == 'S') {
        if (this.validaCampos() == true) {
          try {
            var a = await Incluir.incluirRegistro(api, cli)
            notify(a[0].Msg)
            this.$emit('AtualizaCliente')
            this.carregando = false
            if (a[0].cd_cliente != undefined) {
              this.cd_cliente = a[0].cd_cliente
            }
          } catch {
            notify('Não foi possível atualizar esse cliente.')
            this.carregando = false
          }
          return retorno
        } else {
          notify('Não foi possível atualizar esse cliente. Faltam campos para validar.')
          this.carregando = false
          return retorno
        }
      } else if (this.status_cliente.ic_dado_obrigatorio != 'S') {
        try {
          var b = await Incluir.incluirRegistro(api, cli)
          notify(b[0].Msg)
          this.$emit('AtualizaCliente')
          this.carregando = false
          if (b[0].cd_cliente != undefined) {
            this.cd_cliente = b[0].cd_cliente
          }
        } catch {
          notify('Não foi possível atualizar esse cliente.')
          this.carregando = false
        }
        return retorno
      }

      return retorno
    },

    async consultaCliente() {
      let api = '477/671' //1350 - pr_egisnet_consulta_cliente
      localStorage.cd_parametro = this.cd_cliente_c
      localStorage.nm_fantasia = 'null'
      try {
        let dados_cliente = await Procedimento.montarProcedimento(
          localStorage.cd_empresa,
          localStorage.cd_cliente,
          api,
          '/${cd_empresa}/${cd_parametro}/${nm_fantasia}'
        )
        if (dados_cliente[0].Cod == 0) {
          notify(dados_cliente[0].Msg)
          return
        }
        this.cliente = {
          cd_cliente: dados_cliente[0].cd_cliente,
          nm_fantasia_cliente: dados_cliente[0].nm_razao_social_cliente,
        }
        this.cd_cliente = dados_cliente[0].cd_cliente
        //Campos do expansion item
        this.CEP = dados_cliente[0].cd_cep
        this.CNPJ = dados_cliente[0].cd_cnpj_cliente
        this.Endereco = dados_cliente[0].nm_endereco_cliente
        this.Numero = dados_cliente[0].cd_numero_endereco
        this.Complemento = dados_cliente[0].nm_complemento_endereco
        this.Cidade = dados_cliente[0].nm_cidade
        this.Estado = dados_cliente[0].nm_estado
        // this.Cidade = {
        // cd_cidade: dados_cliente[0].cd_cidade,
        // nm_cidade: dados_cliente[0].nm_cidade,
        // };
        // this.Estado = {
        // cd_estado: dados_cliente[0].cd_estado,
        // nm_estado: dados_cliente[0].nm_estado,
        // };
        this.vendedor = {
          cd_vendedor: dados_cliente[0].cd_vendedor_interno,
          nm_vendedor: dados_cliente[0].nm_vendedor_interno,
        }

        this.vendedor_externo = {
          cd_vendedor: dados_cliente[0].cd_vendedor,
          nm_vendedor: dados_cliente[0].nm_vendedor,
        }

        this.transportadora = {
          cd_transportadora: dados_cliente[0].cd_transportadora,
          nm_transportadora: dados_cliente[0].nm_transportadora,
        }
        this.pagamento = {
          cd_condicao_pagamento: dados_cliente[0].cd_condicao_pagamento,
          nm_condicao_pagamento: dados_cliente[0].nm_condicao_pagamento,
          qt_parcela_condicao_pgto: dados_cliente[0].qt_parcela_condicao_pgto,
        }
        this.frete_pagamento = {
          cd_tipo_pagamento_frete: dados_cliente[0].cd_tipo_pagamento_frete,
          nm_tipo_pagamento_frete: dados_cliente[0].nm_tipo_pagamento_frete,
        }
        this.forma_pagamento = {
          cd_forma_pagamento: dados_cliente[0].cd_forma_pagamento,
          nm_forma_pagamento: dados_cliente[0].nm_forma_pagamento,
        }
        // Cliente Contato
        try {
          let contatos_json = {
            cd_empresa: this.cd_empresa,
            cd_tabela: 111,
            order: 'D',
            where: [{ cd_cliente: this.cd_cliente }],
          }
          let contatos = await select.montarSelect(this.cd_empresa, contatos_json)
          this.lookup_cliente_contato = JSON.parse(JSON.parse(JSON.stringify(contatos[0].dataset)))
          this.cliente_contato = this.lookup_cliente_contato[0]
          await this.OnClienteContato()
        } catch (error) {
          // eslint-disable-next-line no-console
          console.error(error)
        }
        ////Tipo de Faturamento
        try {
          this.lookup_tipo_faturamento = await Lookup.montarSelect(this.cd_empresa, 3931)
          this.lookup_tipo_faturamento = JSON.parse(
            JSON.parse(JSON.stringify(this.lookup_tipo_faturamento.dataset))
          )
          this.tipo_faturamento = this.lookup_tipo_faturamento[0]
        } catch (error) {
          // eslint-disable-next-line no-console
          console.error(error)
        }
        this.tipo_pessoa = dados_cliente[0].cd_tipo_pessoa
        this.status_cliente = {
          cd_status_cliente: dados_cliente[0].cd_status_cliente,
          nm_status_cliente: dados_cliente[0].nm_status_cliente,
        }
        this.estado_civil = {
          cd_estado_civil: dados_cliente[0].cd_estado_civil,
          nm_estado_civil: dados_cliente[0].nm_estado_civil,
        }
        this.fantasia = dados_cliente[0].nm_fantasia_cliente
        this.nm_dominio_cliente = dados_cliente[0].nm_dominio_cliente
        this.cd_inscMunicipal = dados_cliente[0].cd_inscMunicipal
        this.cd_inscestadual = dados_cliente[0].cd_inscestadual
        this.cep = dados_cliente[0].cd_cep
        this.bairro = dados_cliente[0].nm_bairro
        this.endereco = dados_cliente[0].nm_endereco_cliente
        this.numero = dados_cliente[0].cd_numero_endereco
        this.complemento = dados_cliente[0].nm_complemento_endereco
        this.telefone = dados_cliente[0].cd_telefone
        this.email = dados_cliente[0].nm_email_cliente
        this.celular = dados_cliente[0].cd_celular_cliente
        this.razao_social = dados_cliente[0].nm_razao_social_cliente
        this.cd_cnpj = dados_cliente[0].cd_cnpj_cliente
        this.vl_capital_social = dados_cliente[0].vl_capital_social
        this.data_nasc = dados_cliente[0].dt_aniversario_cliente
        this.tipo_pessoa_selecionada = {
          cd_tipo_pessoa: dados_cliente[0].cd_tipo_pessoa,
          nm_tipo_pessoa: dados_cliente[0].nm_tipo_pessoa,
        }
        this.ramo_atividade = {
          cd_ramo_atividade: dados_cliente[0].cd_ramo_atividade,
          nm_ramo_atividade: dados_cliente[0].nm_ramo_atividade,
        }

        this.nm_mae = dados_cliente[0].nm_mae
        this.vl_renda_anual = dados_cliente[0].vl_renda_anual
        this.vl_renda_mensal = dados_cliente[0].vl_renda_mensal

        this.estado = {
          cd_estado: dados_cliente[0].cd_estado,
          nm_estado: dados_cliente[0].nm_estado,
        }

        //this.estado = await this.lookup_estado_natural.find(
        //  (element) => element.cd_estado == dados_cliente[0].cd_estado
        //);
        this.cidade = this.lookup_cidade_natural.find(
          (element) => element.cd_cidade == dados_cliente[0].cd_cidade
        )
        if (this.estado.cd_estado > 0) {
          this.lookup_cidade_filtrado = this.lookup_cidade_natural.filter((e) => {
            return e.cd_estado == this.estado.cd_estado
          })
        }

        if (dados_cliente[0].cd_estado_nascimento > 0) {
          this.natural_estado = {
            cd_estado: dados_cliente[0].cd_estado_nascimento,
            nm_estado: dados_cliente[0].nm_estado_nascimento,
          }
        }
        if (dados_cliente[0].cd_cidade_nascimento > 0) {
          this.natural_cidade = {
            cd_cidade: dados_cliente[0].cd_cidade_nascimento,
            nm_cidade: dados_cliente[0].nm_cidade_nascimento,
          }
          await this.SelecionaEstado(false)
          await this.SelecionaEstadoEndereco(false)
        }

        if (this.tipo_pessoa == 1) {
          //this.data_nasc = dados_cliente[0].dt_ativacao_cliente;
        } else if (this.tipo_pessoa == 2) {
          this.nome = dados_cliente[0].nm_fantasia_cliente
          this.rg = dados_cliente[0].cd_rg_cliente
          //this.data_nasc = dados_cliente[0].dt_aniversario_cliente;
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error)
      }
      if (this.cd_empresa == 150) {
        this.status_cliente = {
          cd_status_cliente: 1,
          nm_status_cliente: 'Ativo',
        }
      }
    },

    async onNovo() {
      this.alteracao = true
      await this.limpatudo()
      this.index = 1

      this.tipo_pessoa_selecionada = ''

      if (localStorage.cd_empresa == 150) {
        this.status_cliente = {
          cd_status_cliente: 1,
          nm_status_cliente: 'Ativo',
        }
      }
    },

    async tabPanelTitleClick(e) {
      await this.limpatudo()

      this.cliente = this.linha
      let Status_Selecionado = this.lookup_dataset_status_cliente.filter(
        (arg) => arg.cd_status_cliente == this.cliente.cd_status_cliente
      )
      this.status_cliente = Status_Selecionado[0]

      let Ramo_Selecionado = this.lookup_dataset_ramo.filter(
        (arg) => arg.cd_ramo_atividade == this.cliente.cd_ramo_atividade
      )
      this.ramo_atividade = Ramo_Selecionado[0]

      this.index = e

      this.tipo_pessoa = this.cliente.cd_tipo_pessoa
      if (!!this.cliente.cd_cliente == true) {
        this.cd_cliente = this.cliente.cd_cliente
      } else {
        this.cd_cliente = this.cd_cliente_c
      }

      this.onContato()
      this.tipo_pessoa_selecionada = {
        cd_tipo_pessoa: this.linha.cd_tipo_pessoa,
        nm_tipo_pessoa: this.linha.nm_tipo_pessoa,
      }
      this.cd_pais = this.cliente.cd_pais
      this.tipo_pessoa = this.linha.cd_tipo_pessoa
      this.nm_dominio_cliente = this.cliente.nm_dominio_cliente
      this.cd_inscestadual = this.cliente.cd_inscestadual
      this.cd_inscMunicipal = this.cliente.cd_inscMunicipal
      //this.cod_cli = this.cliente.cd_cliente;
      this.fantasia = this.cliente.nm_fantasia_cliente
      this.razao_social = this.cliente.nm_razao_social_cliente
      this.cep = this.cliente.cd_cep
      this.bairro = this.cliente.nm_bairro
      this.endereco = this.cliente.nm_endereco_cliente
      this.numero = this.cliente.cd_numero_endereco
      this.complemento = this.cliente.nm_complemento_endereco

      this.cidade = {
        cd_cidade: this.cliente.cd_cidade,
        nm_cidade: this.cliente.nm_cidade,
      }
      this.estado = {
        cd_estado: this.cliente.cd_estado,
        nm_estado: this.cliente.nm_estado,
      }

      this.data_nasc = this.cliente.dt_aniversario_cliente
      this.telefone = this.cliente.cd_telefone
      this.celular = this.cliente.cd_celular
      this.rg = this.cliente.cd_rg_cliente
      this.cpf = this.cliente.cd_cnpj_cliente
      this.cd_cnpj = this.cliente.cd_cnpj_cliente
      this.nome = this.cliente.nm_fantasia_cliente
      this.email = this.cliente.nm_email_cliente
      this.nm_mae = this.cliente.nm_mae
      this.vl_renda_anual = this.cliente.vl_renda_anual
      this.vl_renda_mensal = this.cliente.vl_renda_mensal
      this.estado_civil = {
        cd_estado_civil: this.cliente.cd_estado_civil,
        nm_estado_civil: this.cliente.nm_estado_civil,
      }
      this.rg = this.cliente.cd_rg_cliente
      if (this.cliente.cd_estado_nascimento > 0) {
        this.natural_estado = {
          cd_estado: this.cliente.cd_estado_nascimento,
          nm_estado: this.cliente.nm_estado_nascimento,
        }
      }
      if (this.cliente.cd_cidade_nascimento > 0) {
        this.natural_cidade = {
          cd_cidade: this.cliente.cd_cidade_nascimento,
          nm_cidade: this.cliente.nm_cidade_nascimento,
        }
        await this.SelecionaEstado(false)
        await this.SelecionaEstadoEndereco(false)
      }

      let ramo_atividade = this.lookup_dataset_ramo.filter((e) => {
        return e.cd_ramo_atividade == this.cliente.cd_ramo_atividade
      })
      this.ramo_atividade = ramo_atividade[0]

      //await this.carregaDados();
    },

    LocalEntrega() {
      this.$emit('LocalEntrega', this.cliente_endereco)
    },

    async OnClienteContato() {
      try {
        this.load_contato = true
        let json_pesquisa_contato = {
          cd_parametro: 18,
          cd_cliente: this.cd_cliente,
          cd_contato: this.cliente_contato.cd_contato,
        }
        ;[this.resultado_pesquisa_contato] = await Incluir.incluirRegistro(
          this.api,
          json_pesquisa_contato
        )
        this.nm_email_contato_cliente = this.resultado_pesquisa_contato.cd_email_contato_cliente
          ? this.resultado_pesquisa_contato.cd_email_contato_cliente
          : ''
        this.nm_telefone_contato = this.resultado_pesquisa_contato.cd_telefone_contato
          ? this.resultado_pesquisa_contato.cd_telefone_contato
          : ''
        this.$emit('ClienteContato', this.resultado_pesquisa_contato)
        this.load_contato = false
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error)
      } finally {
        this.load_contato = false
      }
    },

    AttLookupContato(e) {
      this.lookup_cliente_contato = e
      let lastContact = this.lookup_cliente_contato[this.lookup_cliente_contato.length - 1]
      this.nm_email_contato_cliente = lastContact.cd_email_contato_cliente || ''
      this.nm_telefone_contato = lastContact.cd_telefone_contato || ''
      this.contato = false
    },

    validaCampos() {
      if (this.tipo_pessoa == 1) {
        if (this.fantasia == '') {
          this.notifica('Fantasia')
          return false
        } else if (this.razao_social == '') {
          this.notifica('Razão Social')
          return false
        } else if (this.cd_cnpj.replace('.', '').replace('-', '').replace('/', '') == '') {
          this.notifica('CNPJ')
          return false
        } else if (this.endereco == '') {
          this.notifica('Endereço')
          return false
        } else if (this.telefone == '') {
          this.notifica('Telefone')
          return false
        } else if (this.cep == '') {
          this.notifica('CEP')
          return false
        } else if (this.numero == '') {
          this.notifica('Número de residência')
          return false
        }
      } else if (this.tipo_pessoa == 2) {
        if (this.razao_social == '') {
          this.notifica('Nome')
          return false
        }
        //else if (this.cd_cnpj == "") {
        //  this.notifica("CPF");
        //  return false;
        //}
        else if (this.endereco == '') {
          this.notifica('Endereço')
          return false
        } else if (this.data_nasc == '') {
          this.notifica('Data de Nascimento')
          return false
        } else if (this.telefone == '') {
          this.notifica('Telefone')
          return false
        } else if (this.cep == '') {
          this.notifica('CEP')
          return false
        } else if (this.numero == '') {
          this.notifica('Número de residência')
          return false
        }
      }

      return true
    },

    notifica(e) {
      notify('Preencha o campo: ' + e)
    },

    async limpatudo() {
      this.cd_cliente = 0
      this.fantasia = ''
      this.razao_social = ''
      this.cep = ''
      this.natural_estado = ''
      this.natural_cidade = ''
      this.bairro = ''
      this.endereco = ''
      this.numero = ''
      this.complemento = ''
      this.cidade = ''
      this.estado_civil = ''
      this.estado = ''
      this.data_nasc = ''
      this.rg = ''
      this.cd_cnpj = ''
      this.email = ''
      this.nm_mae = ''
      this.nome = null
      this.telefone = ''
      this.celular = ''
      this.ramo_atividade = ''
      this.status_cliente = ''
      this.vl_renda_anual = ''
      this.vl_renda_mensal = ''
      this.nm_dominio_cliente = ''
      this.cd_inscMunicipal = ''
      this.vl_capital_social = ''
      this.cd_inscestadual = ''
      if (localStorage.cd_empresa == 150) {
        this.status_cliente = {
          cd_status_cliente: 1,
          nm_status_cliente: 'Ativo',
        }
      }
    },

    selec_pessoa() {
      this.tipo_pessoa = this.tipo_pessoa_selecionada.cd_tipo_pessoa
      this.limpatudo()
      //if(this.tipo_pessoa_selecionada.cd_tipo_pessoa == 1){
      //  document.getElementById("cnpj").focus();
      //}else if(this.tipo_pessoa_selecionada.cd_tipo_pessoa == 2){
      //  document.getElementById("nome-completo").focus();
      //}
    },
  },
}
</script>

<style scoped>
#data-pop {
  flex-direction: none !important;
  width: 310px;
  overflow-x: hidden;
}

.metadeTela {
  width: 47.5%;
}

.umTercoTela {
  width: 31%;
}

.umQuartoTela {
  width: 22.5%;
}
#grid-cliente {
  max-height: 70vh;
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
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}
.row {
  padding: none;
}
@media (max-width: 900px) {
  .metadeTela {
    width: 100%;
  }

  .umTercoTela {
    width: 100%;
  }

  .umQuartoTela {
    width: 100%;
  }
  #grid-cliente {
    max-height: 100vh;
  }
  .margin1 {
    margin: 1vh 1vw;
  }
}
</style>
