<template>
  <div class="shadow-2 borda-bloco">
    <transition name="slide-fade">
      <div
        v-if="cd_cadastro != 2 && !!tituloMenu == true && !ic_pesquisa"
        class="text-h6 margin1"
      >
        {{ tituloMenu }}
      </div>
    </transition>
    <div v-if="!ic_pesquisa" class="row justify-around">
      <transition name="slide-fade">
        <div v-if="cd_cadastro == 2" class="text-h6 margin1">
          {{ tituloMenu }}
          <q-btn
            round
            color="orange-9"
            icon="arrow_back"
            size="sm"
            @click="ic_pesquisa = !ic_pesquisa"
          >
            <q-tooltip
              anchor="bottom middle"
              self="top middle"
              :offset="[10, 10]"
            >
              Pesquisar Fornecedor
            </q-tooltip>
          </q-btn>
        </div>
      </transition>

      <q-space />
    </div>
    <!-- Pesquisa -->
    <div v-if="ic_pesquisa">
      <q-input
        dense
        class="margin1"
        v-model="nm_fornecedor"
        color="orange-9"
        type="text"
        label="Fornecedor"
        :loading="loading"
        debounce="1000"
        @input="PesquisaNome"
        @keypress.enter="PesquisaTodos"
      >
        <template v-slot:prepend>
          <q-icon name="contacts" />
        </template>
        <template v-slot:append>
          <!-- <q-btn
            size="sm"
            v-if="cd_fornecedor != 0 && ic_pesquisa_contato"
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
          </q-btn> -->
          <!-- <q-btn
            round
            color="orange-9"
            icon="add"
            size="sm"
            @click="ic_pesquisa = !ic_pesquisa"
          >
            <q-tooltip
              anchor="bottom middle"
              self="top middle"
              :offset="[10, 10]"
            >
              Adicionar Fornecedor
            </q-tooltip>
          </q-btn> -->

          <q-icon
            v-if="nm_fornecedor !== ''"
            name="close"
            @click.stop="limpaFornecedor()"
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
          @click="SelecionaFornecedor()"
        >
        </q-btn>
        <DxDataGrid
          class="margin1"
          key-expr="cd_controle"
          :data-source="dataset_grid"
          :columns="coluna"
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
          @focused-row-changed="LinhaGridFornecedor($event)"
          @row-dbl-click="SelecionaFornecedor()"
        >
        </DxDataGrid>
      </div>
      <!-- Dados Fornecedor Pesquisado -->
      <transition name="slide-fade">
        <q-expansion-item
          v-if="cd_fornecedor != 0"
          class="margin1 shadow-1 overflow-hidden"
          style="border-radius: 30px"
          header-class="bg-primary text-white"
          expand-icon-class="text-white"
          icon="perm_identity"
          :label="`Dados do Fornecedor - ${
            fornecedor.nm_fantasia_fornecedor || ''
          } (${this.fornecedor.cd_fornecedor || ''})`"
        >
          <q-card>
            <q-card-section class="row">
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Fantasia"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${fornecedor.nm_fantasia_fornecedor}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="CNPJ"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${cd_cnpj_fornecedor}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="CEP"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${cd_cep}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Endereço"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${nm_endereco_fornecedor}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Número"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${cd_numero_endereco}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Complemento"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${nm_complemento_endereco}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Cidade"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${nm_cidade}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Estado"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${sg_estado}` }}
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
              <q-field
                v-if="fornecedor.nm_tabela_preco"
                class="col margin1"
                dense
                rounded
                standout
                label="Tabela de Preço"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${fornecedor.nm_tabela_preco}` }}
                  </div>
                </template>
              </q-field>
            </q-card-section>
          </q-card>
        </q-expansion-item>
      </transition>
      <!-- Dados Pesquisado -->
    </div>
    <!-- Pesquisa -->
    <div v-if="!ic_pesquisa">
      <q-tabs
        v-model="index"
        v-if="cd_fornecedor_c == 0"
        inline-label
        mobile-arrows
        align="justify"
        style="border-radius: 20px"
        :class="'bg-' + colorID + ' text-white shadow-2 margin1'"
      >
        <q-tab :name="0" icon="description" label="Dados" />
        <q-tab :name="1" icon="person" label="Fornecedor" />
      </q-tabs>

      <transition name="slide-fade">
        <div v-if="index == 0">
          <dx-data-grid
            class="margin1 shadow-2"
            id="grid-fornecedor"
            :data-source="consulta_fornecedor"
            :columns="columns"
            key-expr="cd_controle"
            :show-borders="true"
            :focused-row-enabled="true"
            :column-auto-width="true"
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
            <DxStateStoring
              :enabled="true"
              type="localStorage"
              storage-key="storage"
            />
            <DxPager
              :show-page-size-selector="true"
              :allowed-page-sizes="pageSizes"
              :show-info="true"
            />
            <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

            <DxGrouping :auto-expand-all="true" />
            <DxExport :enabled="true" />

            <DxPaging :enable="true" :page-size="10" />

            <DxStateStoring
              :enabled="true"
              type="localStorage"
              storage-key="storage"
            />
            <DxSelection mode="single" />
            <DxPager
              :show-page-size-selector="true"
              :allowed-page-sizes="pageSizes"
              :show-info="true"
            />
            <DxFilterRow :visible="false" />
            <DxHeaderFilter
              :visible="true"
              :allow-search="true"
              :width="400"
              :height="400"
            />
            <DxSearchPanel
              :visible="true"
              :width="300"
              placeholder="Procurar..."
            />
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
              <DxPopup
                :show-title="true"
                title="menu"
                :close-on-outside-click="false"
              >
              </DxPopup>
            </DxEditing>
          </dx-data-grid>
          <transition name="slide-fade">
            <q-btn
              v-if="cd_fornecedor_c == 0"
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
              v-if="cd_fornecedor_c == 0"
              :color="colorID"
              icon="add"
              label="Novo"
              rounded
              size="md"
              class="margin1"
              @click="onNovo()"
            />
          </transition>

          <!--API -  519 / PROCEDIMENTO - 1392 -->
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
              option-value="cd_status_fornecedor"
              option-label="nm_status_fornecedor"
              v-model="status_fornecedor"
              :options="lookup_dataset_status_fornecedor"
              label="Status do Fornecedor"
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
                  <q-btn
                    icon="event"
                    :color="colorID"
                    round
                    size="sm"
                    class="cursor-pointer"
                  >
                    <q-popup-proxy
                      mask="DD/MM/YYYY"
                      ref="qDateProxy"
                      cover
                      transition-show="scale"
                      transition-hide="scale"
                      :color="colorID"
                    >
                      <q-date
                        id="data-pop"
                        v-model="data_nasc"
                        mask="DD/MM/YYYY"
                        :color="colorID"
                      >
                        <div class="row justify-around">
                          <q-btn
                            v-close-popup
                            round
                            :color="colorID"
                            icon="close"
                            size="sm"
                          />
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
              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="nm_dominio_fornecedor"
                label="Site"
              >
                <template v-slot:prepend>
                  <q-icon name="language" />
                </template>
              </q-input>

              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="cd_inscMunicipal"
                label="Inscrição Municipal"
                mask="NNNNNNNNNNN"
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
                mask="#########"
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
              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="numero"
                label="Número"
              >
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
                @input="Selecionasg_estadoEndereco(true)"
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
                  <q-btn
                    icon="event"
                    :color="colorID"
                    round
                    size="sm"
                    class="cursor-pointer"
                  >
                    <q-popup-proxy
                      mask="DD/MM/YYYY"
                      ref="qDateProxy"
                      cover
                      transition-show="scale"
                      transition-hide="scale"
                    >
                      <q-date
                        id="data-pop"
                        v-model="data_nasc"
                        mask="DD/MM/YYYY"
                        :color="colorID"
                      >
                        <div class="row justify-around">
                          <q-btn
                            v-close-popup
                            round
                            :color="colorID"
                            icon="close"
                            size="sm"
                          />
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
                label="sg_estado Civil"
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
                label="Naturalidade - sg_estado"
                class="margin1 umQuartoTela"
                v-model="natural_estado"
                input-debounce="0"
                @input="Selecionasg_estado(true)"
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
              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="nm_mae"
                label="Nome da Mãe"
              >
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
              <q-input
                dense
                class="margin1 umTercoTela"
                v-model="numero"
                label="Número"
              >
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
                @input="Selecionasg_estadoEndereco(true)"
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
import Menu from "../http/menu";
import Procedimento from "../http/procedimento";
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";
import { DxPopup } from "devextreme-vue/popup";
import carregando from "../components/carregando.vue";
import contato from "../views/contato";
import formataData from "../http/formataData";
import funcao from "../http/funcoes-padroes";
import Incluir from "../http/incluir_registro";
import Lookup from "../http/lookup";

import {
  DxDataGrid,
  DxExport,
  DxPaging,
  DxEditing,
  DxSelection,
} from "devextreme-vue/data-grid";

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
} from "devextreme-vue/data-grid";

export default {
  name: "fornecedor",
  props: {
    cd_cadastro: { type: Number, default: 2 },
    cd_fornecedor_c: { type: Number, default: 0 },
    cd_fornecedor_props: { type: Number, default: 0 },
    cd_usuario: { type: String, default: "" },
    cd_consulta: { type: Boolean, default: false },
    ic_pesquisa: { type: Boolean, default: false },
    ic_pesquisa_contato: { type: Boolean, default: true },
    cd_cadastro_c: { type: Boolean, default: false },
    att_endereco: { type: Object, default: null },
    colorID: { type: String, default: "primary" },
  },

  data() {
    return {
      longtabs: [
        { text: "Dados", id: 0 },
        { text: "Fornecedor", id: 1 },
      ],
      tituloMenu: "",
      ramo_atividade: "",
      columns: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      nm_mae: "",
      carregando: false,
      cd_empresa: localStorage.cd_empresa,
      cd_fornecedor: 0,
      api: "964/1480", //pr_egisnet_controle_fornecedor
      cd_cnpj: "",
      load: false,
      linha: {},
      lokup_estado_civil: [],
      fantasia: "",
      razao_social: "",
      vl_capital_social: "",
      nome: "",
      data_nasc: "",
      rg: "",
      nm_dominio_fornecedor: "",
      cd_inscMunicipal: "",
      cd_inscestadual: "",
      // Pesquisa
      nm_fornecedor: "",
      loading: false,
      load_contato: false,
      GridCli: false,
      resultado_pesquisa_contato: [],
      nm_email_contato_fornecedor: "",
      nm_telefone_contato: "",
      dataset_grid: [],
      coluna: [],
      fornecedor_selecionado: "",
      cd_cnpj_fornecedor: "",
      Insc_Estadual: "",
      Insc_Municipal: "",
      cd_cep: "",
      nm_endereco_fornecedor: "",
      cd_numero_endereco: "",
      nm_complemento_endereco: "",
      Bairro: "",
      nm_cidade: "",
      sg_estado: "",
      transportadora: "",
      destinacao: "",
      tipo_pedido: "",
      tipo_endereco: "",
      pagamento: "",
      resultado_contato: "",
      popup_contato: "",
      fornecedor_popup: "",
      selecao_contato: "",
      contato_selecionado: "",
      selecao: "",
      // Pesquisa
      cpf: "",
      cep: "",
      bairro: "",
      endereco: "",
      numero: "",
      complemento: "",
      cidade: "",
      estado: "",
      natural_estado: "",
      cd_pais: 0,
      consulta_fornecedor: [],
      lookup_dataset: [],
      lookup_dados: [],
      carrega_cidade: false,
      lookup_dataset_status_fornecedor: [],
      lookup_status_fornecedor: [],
      lookup_ramo: [],
      lookup_dataset_ramo: [],
      email: "",
      lookup_estado_natural: [],
      lookup_cidade_natural: [],
      lookup_cidade_filtrado: [],
      natural_cidade: "",
      tipo_pessoa: 0,
      contato: false,
      estado_civil: "",
      telefone: "",
      vl_renda_anual: "",
      alteracao: false,
      vl_renda_mensal: "",
      tipo_pessoa_selecionada: "",
      status_fornecedor: "",
      fornecedor: {},
      index: 0,
      cd_pos_venda: 0,
      export: {},
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    this.carregaDados();
    let e = await Lookup.montarSelect(this.cd_empresa, 373);
    this.lokup_estado_civil = JSON.parse(JSON.parse(JSON.stringify(e.dataset)));
    let lokup_cidade = await Lookup.montarSelect(this.cd_empresa, 97);
    this.lookup_cidade_natural = JSON.parse(
      JSON.parse(JSON.stringify(lokup_cidade.dataset))
    );
    if (this.cd_consulta == true) {
      this.tituloMenu = "Dados do Fornecedor";
      if (this.cd_fornecedor_c) {
        this.cd_fornecedor = this.cd_fornecedor_c;
        this.consultaFornecedor();
        this.index = 1;
      }
      this.index = 1;
      this.contato = true;
      this.cd_pos_venda = 1;
    } else {
      this.tituloMenu = "Cadastro de Fornecedores";
    }

    if (this.cd_cadastro_c == true) {
      this.onNovo();
    }
    //await this.showMenu();
  },

  async mounted() {
    this.lookup_dados = await Lookup.montarSelect(this.cd_empresa, 116);
    this.lookup_dataset = JSON.parse(
      JSON.parse(JSON.stringify(this.lookup_dados.dataset))
    );
    this.lookup_status_fornecedor = await Lookup.montarSelect(
      this.cd_empresa,
      107
    );
    this.lookup_dataset_status_fornecedor = JSON.parse(
      JSON.parse(JSON.stringify(this.lookup_status_fornecedor.dataset))
    );

    var lookup_estado = await Lookup.montarSelect(this.cd_empresa, 731);
    var lokup = JSON.parse(JSON.parse(JSON.stringify(lookup_estado.dataset)));
    this.lookup_estado_natural = lokup.filter(
      (element) => element.cd_pais == 1
    );

    this.lookup_ramo = await Lookup.montarSelect(this.cd_empresa, 92);
    this.lookup_dataset_ramo = JSON.parse(
      JSON.parse(JSON.stringify(this.lookup_ramo.dataset))
    );
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
    DxColumnFixing,
    carregando,
    contato,
  },
  watch: {
    async cd_fornecedor() {
      this.contato = false;
      await this.sleep(500);
    },
    cd_fornecedor_c() {
      this.consultaFornecedor();
    },
    async cd_fornecedor_props(a) {
      if (a > 0) {
        let json_pesquisa = {
          cd_parametro: 6,
          cd_fornecedor: a,
        };
        [this.fornecedor_selecionado] = await Incluir.incluirRegistro(
          "911/1412", //this.api,
          json_pesquisa
        );
        await this.SelecionaFornecedor();
      }
      if (a == 0) {
        this.cd_fornecedor = 0;
        this.fornecedor = "";
        this.linha = {};
      }
    },
    async index() {
      if (this.alteracao == false) {
        await this.tabPanelTitleClick(this.index);
      }
      if (this.index == 0) {
        this.alteracao = false;
      }
      if (this.index == 0) {
        await this.carregaDados();
      }
    },
    att_endereco() {
      this.cd_cep = this.att_endereco.cep;
      this.nm_endereco_fornecedor = this.att_endereco.logradouro;
      this.cd_numero_endereco = ""; //this.att_endereco
      this.nm_complemento_endereco = this.att_endereco.complemento;
      this.nm_cidade = this.att_endereco.nm_cidade;
      this.sg_estado = this.att_endereco.nm_estado;
    },
  },
  methods: {
    limpaFornecedor() {
      this.fornecedor = "";
      this.nm_fornecedor = "";
      this.GridCli = false;
      this.limpatudo();
      this.$emit("limpaFornecedor", "");
    },
    async FormataVal(index) {
      if (index == 1 && this.vl_renda_mensal != "") {
        this.vl_renda_mensal = await funcao.FormataValor(this.vl_renda_mensal);
      } else if (index == 2 && this.vl_renda_anual != "") {
        this.vl_renda_anual = await funcao.FormataValor(this.vl_renda_anual);
        this.vl_renda_mensal = await funcao.Divisao(this.vl_renda_anual, 12);
      } else if (index == 3 && this.vl_capital_social != "") {
        this.vl_capital_social = await funcao.FormataValor(
          this.vl_capital_social
        );
      }
    },

    async Selecionasg_estado(limpa) {
      this.carrega_cidade = true;
      if (limpa == true) {
        this.natural_cidade = "";
      }
      let estado = this.natural_estado;
      this.lookup_cidade_filtrado = this.lookup_cidade_natural.filter(
        (element) => element.cd_estado == estado.cd_estado
      );

      this.carrega_cidade = false;
    },

    async Selecionasg_estadoEndereco(limpa) {
      this.carrega_cidade = true;
      if (limpa == true) {
        this.cidade = "";
      }
      let estado = this.estado;
      this.lookup_cidade_filtrado = this.lookup_cidade_natural.filter(
        (element) => element.cd_estado == estado.cd_estado
      );

      this.carrega_cidade = false;
    },
    async sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },

    async PesquisaNome() {
      this.loading = true;
      this.GridCli = false;
      let menu_grid = await Menu.montarMenu(
        this.cd_empresa,
        8259, // Procedimento 1842
        964 //pr_egisnet_controle_fornecedor - Procedimento 1842
      );
      this.coluna = JSON.parse(JSON.parse(JSON.stringify(menu_grid.coluna)));
      let json_pesquisa = {
        cd_parametro: 2,
        nm_fantasia_fornecedor: this.nm_fornecedor,
      };
      this.dataset_grid = await Incluir.incluirRegistro(
        this.api, //pr_egisnet_controle_fornecedor
        json_pesquisa
      );
      this.loading = false;
      this.GridCli = true;
    },

    async PesquisaTodos() {
      if (this.nm_fornecedor == "") {
        await this.PesquisaNome();
      }
    },

    async SelecionaFornecedor() {
      this.loading = true;
      this.$emit("SelectFornecedor", this.fornecedor_selecionado);
      let {
        nm_fantasia_fornecedor = "",
        Razao_Social = "",
        Telefone_Empresa = "",
        Telefone = "",
        cd_cnpj_fornecedor = "",
        nm_dominio_fornecedor = "",
        Tipo_Pessoa = "",
        Ramo_Atividade = "",
        Status_Fornecedor = "",
        cd_transportadora = "",
        nm_transportadora = "",
        cd_destinacao_produto = "",
        Destinacao_Produto = "",
        cd_tipo_pedido = "",
        Tipo_Pedido = "",
        cd_tipo_endereco = "",
        Tipo_Endereco = "",
        cep_entrega = "",
        endereco_entrega = "",
        numero_entrega = "",
        complemento_entrega = "",
        bairro_entrega = "",
        estado_entrega = "",
        cidade_entrega = "",
        referencia_entrega = "",
        cd_cep = "",
        Email = "",
        nm_endereco_fornecedor = "",
        cd_numero_endereco = "",
        nm_complemento_endereco = "",
        Bairro = "",
        nm_cidade = "",
        sg_estado = "",
        Insc_Estadual = "",
        Insc_Municipal = "",
        cd_condicao_pagamento = "",
        Condicao_Pagamento = "",
        qt_parcela_condicao_pgto = "",
      } = this.fornecedor_selecionado;
      this.cd_fornecedor = this.fornecedor_selecionado.cd_fornecedor;
      //Fornecedor//
      nm_fantasia_fornecedor == null
        ? (this.nm_fantasia_fornecedor = "")
        : (this.nm_fantasia_fornecedor = nm_fantasia_fornecedor);
      Razao_Social == null
        ? (this.Razao_Social = "")
        : (this.Razao_Social = Razao_Social);
      Telefone_Empresa == null || Telefone_Empresa == ""
        ? (this.Telefone_Empresa = null)
        : (this.Telefone_Empresa = Telefone_Empresa);
      this.Telefone_Empresa == null && Telefone != null
        ? (this.Telefone_Empresa = Telefone)
        : (this.Telefone_Empresa = "");
      nm_dominio_fornecedor == null
        ? (this.nm_dominio_fornecedor = "")
        : (this.nm_dominio_fornecedor = nm_dominio_fornecedor);
      Email == null ? (this.Email = "") : (this.Email = Email);
      Tipo_Pessoa == null
        ? (this.Tipo_Pessoa = "")
        : (this.Tipo_Pessoa = Tipo_Pessoa);
      Ramo_Atividade == null
        ? (this.Ramo_Atividade = "")
        : (this.Ramo_Atividade = Ramo_Atividade);
      Status_Fornecedor == null
        ? (this.Status_Fornecedor = "")
        : (this.Status_Fornecedor = Status_Fornecedor);
      this.cd_cnpj_fornecedor = cd_cnpj_fornecedor;
      this.Insc_Estadual == null
        ? (this.Insc_Estadual = "")
        : (this.Insc_Estadual = Insc_Estadual);
      this.Insc_Municipal == null
        ? (this.Insc_Municipal = "")
        : (this.Insc_Municipal = Insc_Municipal);
      this.cd_cep == null ? (this.cd_cep = "") : (this.cd_cep = cd_cep);
      this.nm_endereco_fornecedor == null
        ? (this.nm_endereco_fornecedor = "")
        : (this.nm_endereco_fornecedor = nm_endereco_fornecedor);
      this.cd_numero_endereco == null
        ? (this.cd_numero_endereco = "")
        : (this.cd_numero_endereco = cd_numero_endereco);
      this.nm_complemento_endereco == null
        ? (this.nm_complemento_endereco = "")
        : (this.nm_complemento_endereco = nm_complemento_endereco);
      this.Bairro == null ? (this.Bairro = "") : (this.Bairro = Bairro);
      this.nm_cidade == null
        ? (this.nm_cidade = "")
        : (this.nm_cidade = nm_cidade);
      this.sg_estado == null
        ? (this.sg_estado = "")
        : (this.sg_estado = sg_estado);
      //Proposta//

      this.transportadora = {
        cd_transportadora: cd_transportadora,
        nm_transportadora: nm_transportadora,
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
      this.fornecedor = {
        cd_fornecedor: this.fornecedor_selecionado.cd_fornecedor,
        nm_fantasia_fornecedor:
          this.fornecedor_selecionado.nm_fantasia_fornecedor,
        nm_tabela_preco: this.fornecedor_selecionado.nm_tabela_preco,
      };
      this.resultado_contato = [];
      this.popup_contato = false;
      this.GridCli = false;
      this.fornecedor_popup = false;
      this.selecao_contato = false;
      this.contato_selecionado = [];
      this.selecao = true;
      this.loading = false;
    },
    LinhaGridFornecedor: function (e) {
      this.fornecedor_selecionado = e.row && e.row.data;
    },

    async carregaDados() {
      let dados_linha = await Menu.montarMenu(localStorage.cd_empresa, 0, 519); //pr_consulta_cliente_egisnet
      let api = dados_linha.nm_identificacao_api;
      let sParametroApi = dados_linha.nm_api_parametro;
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados_linha.coluna)));
      this.consulta_fornecedor = [];
      localStorage.cd_parametro = 0;

      this.consulta_fornecedor = await Procedimento.montarProcedimento(
        this.cd_empresa,
        0,
        api,
        sParametroApi
      );
    },

    async SearchCNPJ() {
      if (this.cd_cnpj == "") return;
      try {
        if (this.cd_cnpj.length < 18) {
          notify("Digite o CNPJ corretamente");
          return;
        } else {
          var response = await funcao.BuscaCNPJ(this.cd_cnpj);
          this.fantasia = response.nm_fantasia_cnpj;
          this.razao_social = response.nm_razao_social_cnpj;
          this.data_nasc = response.dt_abertura;
          this.telefone = response.cd_telefone_cnpj;
          this.email = response.nm_email;
          this.vl_capital_social = response.vl_capital_social;
          this.cep = response.cd_cep;
          this.endereco = response.nm_endereco_cnpj;
          this.numero = response.cd_numero_cnpj;
          this.complemento = response.nm_complemento;
          this.bairro = response.nm_bairro;
          this.cd_inscestadual = response.cd_inscestual;
          if (response.cd_estado) {
            let est = this.lookup_estado.find((e) => {
              return (e.cd_estado = response.cd_estado);
            });
            if (est) {
              this.estado = est;
            }
          }
          if (response.cd_cidade) {
            let cid = this.lookup_cidade_natural.find((e) => {
              return (e.cd_cidade = response.cd_cidade);
            });
            if (cid) {
              this.cidade = cid;
            }
          }
        }
      } catch {
        this.load = true;

        localStorage.cd_cnpj = this.cd_cnpj
          .replace(".", "")
          .replace(".", "")
          .replace("/", "")
          .replace("-", "");
        this.cd_cnpj = this.cd_cnpj
          .replace(".", "")
          .replace(".", "")
          .replace("/", "")
          .replace("-", "");

        if (this.cd_cnpj.includes("_") == false) {
          this.dataSourceConfig = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_fornecedor,
            "400/534",
            "/${cd_empresa}/${cd_cnpj}"
          );
        } else {
          this.cd_cnpj = "";
          notify("CNPJ Não encontrado!");
        }
        //carrega os dados
        this.razao_social = this.dataSourceConfig[0].nm_razao_social;
        this.cep = this.dataSourceConfig[0].nm_cep.replace(".", "");
        this.bairro = this.dataSourceConfig[0].nm_bairro;
        this.endereco = this.dataSourceConfig[0].nm_endereco;
        this.numero = this.dataSourceConfig[0].cd_numero.trim();
        this.complemento = this.dataSourceConfig[0].nm_complemento;
        this.estado = await this.lookup_estado_natural.find(
          (element) => element.cd_estado == this.dataSourceConfig[0].cd_estado
        );
        this.cidade = this.lookup_cidade_natural.find(
          (element) => element.cd_cidade == this.dataSourceConfig[0].cd_cidade
        );
        this.lookup_cidade_filtrado = this.lookup_cidade_natural.filter(
          (element) => element.cd_estado == this.estado.cd_estado
        );
        this.cd_pais = this.dataSourceConfig[0].cd_pais;
        this.data_nasc = this.dataSourceConfig[0].dt_abertura;
        this.email = this.dataSourceConfig[0].nm_email;
        this.fantasia = this.dataSourceConfig[0].nm_fantasia;
        this.telefone = this.dataSourceConfig[0].nm_telefone;
        this.vl_capital_social = this.dataSourceConfig[0].vl_capital_social;
        this.FormataVal(3);
        if (!!this.cep == true) {
          await this.onBuscaCep();
        }
      } finally {
        this.load = false;
      }
    },

    onDbClick(e) {
      this.$emit("DbClick", e.data);
    },

    // eslint-disable-next-line no-unused-vars
    onFocusedRowChanged({ selectedRowKeys, selectedRowsData }) {
      this.tipo_pessoa = selectedRowsData[0].cd_tipo_pessoa;
      this.linha = selectedRowsData[0];
    },

    async exclusao(e) {
      let line = e.data;
      var api = "472/666"; // Procedimento 1345 - pr_egisnet_cadastra_cliente
      let ex = {
        cd_parametro: 2,
        cd_fornecedor: line.cd_fornecedor,
      };
      var exc = await Incluir.incluirRegistro(api, ex);
      notify(exc[0].Msg);
      this.carregaDados();
    },

    async onBuscaCep() {
      this.load = true;
      localStorage.cd_cep = this.cep.replace("-", "");
      if (this.cep.includes("_") == false) {
        if (!this.cep.trim() == "") {
          try {
            this.dataSourceConfig = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_fornecedor,
              "413/550",
              "/${cd_empresa}/${cd_cep}"
            );
            this.endereco = this.dataSourceConfig[0].logradouro;
            this.bairro = this.dataSourceConfig[0].bairro;
            this.complemento = this.dataSourceConfig[0].complemento;
            this.estado = this.lookup_estado_natural.find(
              (element) =>
                element.cd_estado == this.dataSourceConfig[0].cd_estado
            );
            let cidade_obj = this.lookup_cidade_natural.filter(
              (element) =>
                element.cd_cidade == this.dataSourceConfig[0].cd_cidade
            );
            this.cidade = cidade_obj[0];
            this.lookup_cidade_filtrado = this.lookup_cidade_natural.filter(
              (element) => element.cd_estado == this.estado.cd_estado
            );
            this.cd_pais = this.dataSourceConfig[0].cd_pais;
          } catch (err) {
            // eslint-disable-next-line no-console
            console.error(err);
          } finally {
            this.load = false;
          }
        }
      }
      this.load = false;
    },

    onContato() {
      this.contato = !this.contato;
    },

    async onGravar() {
      let retorno;

      var api = "472/666"; // Procedimento 1345 - pr_egisnet_cadastra_cliente
      if (this.data_nasc != null) {
        var data_salvar = formataData.formataDataSQL(this.data_nasc);
        // this.data_nasc = formataData.formataDataSQL(this.data_nasc);
      }
      if (this.ramo_atividade == undefined) {
        this.ramo_atividade = "";
      }
      if (this.tipo_pessoa_selecionada == "") {
        notify("Selecione o tipo de pessoa!");
        return retorno;
      }
      if (this.razao_social.trim() == "") {
        notify("Por favor, digite o Nome!");
        return retorno;
      }

      this.carregando = true;
      var cd_parametro = 0;
      this.cd_fornecedor =
        this.cd_fornecedor_c != 0 ? this.cd_fornecedor_c : this.cd_fornecedor;
      if (this.cd_fornecedor == 0) {
        cd_parametro = 0; //Insere
      } else {
        cd_parametro = 1; //Atualiza
      }

      let cli = {
        cd_cep: this.cep,
        cd_numero_endereco: this.numero,
        cd_tipo_pessoa: this.tipo_pessoa_selecionada.cd_tipo_pessoa,
        cd_parametro: cd_parametro,
        cd_fornecedor:
          this.cd_fornecedor == 0 ? this.cd_fornecedor_c : this.cd_fornecedor,
        cd_usuario: localStorage.cd_usuario,
        nm_razao_social_fornecedor: funcao.ValidaString(this.razao_social, 60),
        nm_fantasia_fornecedor: funcao.ValidaString(this.fantasia, 30),
        nm_bairro: funcao.ValidaString(this.bairro, 60),
        nm_endereco_fornecedor: funcao.ValidaString(this.endereco, 60),
        nm_complemento_endereco: funcao.ValidaString(this.complemento, 60),
        nm_dominio_fornecedor: funcao.ValidaString(
          this.nm_dominio_fornecedor,
          100
        ),
        cd_inscMunicipal: this.cd_inscMunicipal,
        cd_inscestadual: this.cd_inscestadual,
        cd_estado: this.estado.cd_estado,
        cd_cidade: this.cidade.cd_cidade,
        cd_pais: this.cd_pais,
        cd_telefone: this.telefone,
        cd_celular_fornecedor: this.celular,
        cd_cnpj_fornecedor: this.cd_cnpj,
        nm_email_fornecedor: funcao.ValidaString(this.email, 150),
        cd_rg_fornecedor: this.rg,
        dt_aniversario_fornecedor: data_salvar,
        cd_ramo_atividade: this.ramo_atividade.cd_ramo_atividade,
        cd_status_fornecedor: this.status_fornecedor.cd_status_fornecedor,
        ic_dado_obrigatorio: this.status_fornecedor.ic_dado_obrigatorio,
        cd_cidade_nascimento: this.natural_cidade.cd_cidade,
        cd_estado_nascimento: this.natural_estado.cd_estado,
        nm_mae: funcao.ValidaString(this.nm_mae),
        cd_estado_civil: this.estado_civil.cd_estado_civil,
        vl_renda_mensal: this.vl_renda_mensal,
        vl_renda_anual: this.vl_renda_anual,
        vl_capital_social: this.vl_capital_social,
      };
      if (this.status_fornecedor.ic_dado_obrigatorio == "S") {
        if (this.validaCampos() == true) {
          try {
            var a = await Incluir.incluirRegistro(api, cli);
            notify(a[0].Msg);
            this.$emit("AtualizaFornecedor");
            this.carregando = false;
            if (a[0].cd_fornecedor != undefined) {
              this.cd_fornecedor = a[0].cd_fornecedor;
            }
          } catch {
            notify("Não foi possível atualizar esse fornecedor.");
            this.carregando = false;
          }
          return retorno;
        } else {
          notify(
            "Não foi possível atualizar esse fornecedor. Faltam campos para validar."
          );
          this.carregando = false;
          return retorno;
        }
      } else if (this.status_fornecedor.ic_dado_obrigatorio != "S") {
        try {
          var b = await Incluir.incluirRegistro(api, cli);
          notify(b[0].Msg);
          this.$emit("AtualizaFornecedor");
          this.carregando = false;
          if (b[0].cd_fornecedor != undefined) {
            this.cd_fornecedor = b[0].cd_fornecedor;
          }
        } catch {
          notify("Não foi possível atualizar esse fornecedor.");
          this.carregando = false;
        }
        return retorno;
      }

      return retorno;
    },

    async consultaFornecedor() {
      let api = "477/671"; //1350 - pr_egisnet_consulta_cliente
      localStorage.cd_parametro = this.cd_fornecedor_c;
      localStorage.nm_fantasia = "null";
      try {
        let dados_fornecedor = await Procedimento.montarProcedimento(
          localStorage.cd_empresa,
          localStorage.cd_fornecedor,
          api,
          "/${cd_empresa}/${cd_parametro}/${nm_fantasia}"
        );
        if (dados_fornecedor[0].Cod == 0) {
          notify(dados_fornecedor[0].Msg);
          return;
        }
        this.fornecedor = {
          cd_fornecedor: dados_fornecedor[0].cd_fornecedor,
          nm_fantasia_fornecedor:
            dados_fornecedor[0].nm_razao_social_fornecedor,
        };
        this.cd_fornecedor = dados_fornecedor[0].cd_fornecedor;
        //Campos do expansion item
        this.cd_cep = dados_fornecedor[0].cd_cep;
        this.cd_cnpj_fornecedor = dados_fornecedor[0].cd_cnpj_fornecedor;
        this.nm_endereco_fornecedor =
          dados_fornecedor[0].nm_endereco_fornecedor;
        this.cd_numero_endereco = dados_fornecedor[0].cd_numero_endereco;
        this.nm_complemento_endereco =
          dados_fornecedor[0].nm_complemento_endereco;
        this.nm_cidade = dados_fornecedor[0].nm_cidade;
        this.sg_estado = dados_fornecedor[0].nm_estado;

        this.transportadora = {
          cd_transportadora: dados_fornecedor[0].cd_transportadora,
          nm_transportadora: dados_fornecedor[0].nm_transportadora,
        };
        this.pagamento = {
          cd_condicao_pagamento: dados_fornecedor[0].cd_condicao_pagamento,
          nm_condicao_pagamento: dados_fornecedor[0].nm_condicao_pagamento,
          qt_parcela_condicao_pgto:
            dados_fornecedor[0].qt_parcela_condicao_pgto,
        };
        this.tipo_pessoa = dados_fornecedor[0].cd_tipo_pessoa;
        this.status_fornecedor = {
          cd_status_fornecedor: dados_fornecedor[0].cd_status_fornecedor,
          nm_status_fornecedor: dados_fornecedor[0].nm_status_fornecedor,
        };
        this.estado_civil = {
          cd_estado_civil: dados_fornecedor[0].cd_estado_civil,
          nm_estado_civil: dados_fornecedor[0].nm_estado_civil,
        };
        this.fantasia = dados_fornecedor[0].nm_fantasia_fornecedor;
        this.nm_dominio_fornecedor = dados_fornecedor[0].nm_dominio_fornecedor;
        this.cd_inscMunicipal = dados_fornecedor[0].cd_inscMunicipal;
        this.cd_inscestadual = dados_fornecedor[0].cd_inscestadual;
        this.cep = dados_fornecedor[0].cd_cep;
        this.bairro = dados_fornecedor[0].nm_bairro;
        this.endereco = dados_fornecedor[0].nm_endereco_fornecedor;
        this.numero = dados_fornecedor[0].cd_numero_endereco;
        this.complemento = dados_fornecedor[0].nm_complemento_endereco;
        this.telefone = dados_fornecedor[0].cd_telefone;
        this.email = dados_fornecedor[0].nm_email_fornecedor;
        this.celular = dados_fornecedor[0].cd_celular_fornecedor;
        this.razao_social = dados_fornecedor[0].nm_razao_social_fornecedor;
        this.cd_cnpj = dados_fornecedor[0].cd_cnpj_fornecedor;
        this.vl_capital_social = dados_fornecedor[0].vl_capital_social;
        this.data_nasc = dados_fornecedor[0].dt_aniversario_fornecedor;
        this.tipo_pessoa_selecionada = {
          cd_tipo_pessoa: dados_fornecedor[0].cd_tipo_pessoa,
          nm_tipo_pessoa: dados_fornecedor[0].nm_tipo_pessoa,
        };
        this.ramo_atividade = {
          cd_ramo_atividade: dados_fornecedor[0].cd_ramo_atividade,
          nm_ramo_atividade: dados_fornecedor[0].nm_ramo_atividade,
        };

        this.nm_mae = dados_fornecedor[0].nm_mae;
        this.vl_renda_anual = dados_fornecedor[0].vl_renda_anual;
        this.vl_renda_mensal = dados_fornecedor[0].vl_renda_mensal;

        this.estado = {
          cd_estado: dados_fornecedor[0].cd_estado,
          nm_estado: dados_fornecedor[0].nm_estado,
        };

        this.cidade = this.lookup_cidade_natural.find(
          (element) => element.cd_cidade == dados_fornecedor[0].cd_cidade
        );
        if (this.estado.cd_estado > 0) {
          this.lookup_cidade_filtrado = this.lookup_cidade_natural.filter(
            (e) => {
              return e.cd_estado == this.estado.cd_estado;
            }
          );
        }

        if (dados_fornecedor[0].cd_estado_nascimento > 0) {
          this.natural_estado = {
            cd_estado: dados_fornecedor[0].cd_estado_nascimento,
            nm_estado: dados_fornecedor[0].nm_estado_nascimento,
          };
        }
        if (dados_fornecedor[0].cd_cidade_nascimento > 0) {
          this.natural_cidade = {
            cd_cidade: dados_fornecedor[0].cd_cidade_nascimento,
            nm_cidade: dados_fornecedor[0].nm_cidade_nascimento,
          };
          await this.Selecionasg_estado(false);
          await this.Selecionasg_estadoEndereco(false);
        }

        if (this.tipo_pessoa == 1) {
          //this.data_nasc = dados_fornecedor[0].dt_ativacao_fornecedor;
        } else if (this.tipo_pessoa == 2) {
          this.nome = dados_fornecedor[0].nm_fantasia_fornecedor;
          this.rg = dados_fornecedor[0].cd_rg_fornecedor;
          //this.data_nasc = dados_fornecedor[0].dt_aniversario_fornecedor;
        }
      } catch (error) {
        console.error(error);
      }
    },

    async onNovo() {
      this.alteracao = true;
      await this.limpatudo();
      this.index = 1;
      this.tipo_pessoa_selecionada = "";
    },

    async tabPanelTitleClick(e) {
      await this.limpatudo();

      this.fornecedor = this.linha;
      let Status_Selecionado = this.lookup_dataset_status_fornecedor.filter(
        (arg) =>
          arg.cd_status_fornecedor == this.fornecedor.cd_status_fornecedor
      );
      this.status_fornecedor = Status_Selecionado[0];

      let Ramo_Selecionado = this.lookup_dataset_ramo.filter(
        (arg) => arg.cd_ramo_atividade == this.fornecedor.cd_ramo_atividade
      );
      this.ramo_atividade = Ramo_Selecionado[0];

      this.index = e;

      this.tipo_pessoa = this.fornecedor.cd_tipo_pessoa;
      if (!!this.fornecedor.cd_fornecedor == true) {
        this.cd_fornecedor = this.fornecedor.cd_fornecedor;
      } else {
        this.cd_fornecedor = this.cd_fornecedor_c;
      }

      this.onContato();
      this.tipo_pessoa_selecionada = {
        cd_tipo_pessoa: this.linha.cd_tipo_pessoa,
        nm_tipo_pessoa: this.linha.nm_tipo_pessoa,
      };
      this.cd_pais = this.fornecedor.cd_pais;
      this.tipo_pessoa = this.linha.cd_tipo_pessoa;
      this.nm_dominio_fornecedor = this.fornecedor.nm_dominio_fornecedor;
      this.cd_inscestadual = this.fornecedor.cd_inscestadual;
      this.cd_inscMunicipal = this.fornecedor.cd_inscMunicipal;
      //this.cod_cli = this.fornecedor.cd_fornecedor;
      this.fantasia = this.fornecedor.nm_fantasia_fornecedor;
      this.razao_social = this.fornecedor.nm_razao_social_fornecedor;
      this.cep = this.fornecedor.cd_cep;
      this.bairro = this.fornecedor.nm_bairro;
      this.endereco = this.fornecedor.nm_endereco_fornecedor;
      this.numero = this.fornecedor.cd_numero_endereco;
      this.complemento = this.fornecedor.nm_complemento_endereco;

      this.cidade = {
        cd_cidade: this.fornecedor.cd_cidade,
        nm_cidade: this.fornecedor.nm_cidade,
      };
      this.estado = {
        cd_estado: this.fornecedor.cd_estado,
        nm_estado: this.fornecedor.nm_estado,
      };

      this.data_nasc = this.fornecedor.dt_aniversario_fornecedor;
      this.telefone = this.fornecedor.cd_telefone;
      this.celular = this.fornecedor.cd_celular;
      this.rg = this.fornecedor.cd_rg_fornecedor;
      this.cpf = this.fornecedor.cd_cnpj_fornecedor;
      this.cd_cnpj = this.fornecedor.cd_cnpj_fornecedor;
      this.nome = this.fornecedor.nm_fantasia_fornecedor;
      this.email = this.fornecedor.nm_email_fornecedor;
      this.nm_mae = this.fornecedor.nm_mae;
      this.vl_renda_anual = this.fornecedor.vl_renda_anual;
      this.vl_renda_mensal = this.fornecedor.vl_renda_mensal;
      this.estado_civil = {
        cd_estado_civil: this.fornecedor.cd_estado_civil,
        nm_estado_civil: this.fornecedor.nm_estado_civil,
      };
      this.rg = this.fornecedor.cd_rg_fornecedor;
      if (this.fornecedor.cd_estado_nascimento > 0) {
        this.natural_estado = {
          cd_estado: this.fornecedor.cd_estado_nascimento,
          nm_estado: this.fornecedor.nm_estado_nascimento,
        };
      }
      if (this.fornecedor.cd_cidade_nascimento > 0) {
        this.natural_cidade = {
          cd_cidade: this.fornecedor.cd_cidade_nascimento,
          nm_cidade: this.fornecedor.nm_cidade_nascimento,
        };
        await this.Selecionasg_estado(false);
        await this.Selecionasg_estadoEndereco(false);
      }

      let ramo_atividade = this.lookup_dataset_ramo.filter((e) => {
        return e.cd_ramo_atividade == this.fornecedor.cd_ramo_atividade;
      });
      this.ramo_atividade = ramo_atividade[0];
    },

    validaCampos() {
      if (this.tipo_pessoa == 1) {
        if (this.fantasia == "") {
          this.notifica("Fantasia");
          return false;
        } else if (this.razao_social == "") {
          this.notifica("Razão Social");
          return false;
        } else if (
          this.cd_cnpj.replace(".", "").replace("-", "").replace("/", "") == ""
        ) {
          this.notifica("CNPJ");
          return false;
        } else if (this.endereco == "") {
          this.notifica("Endereço");
          return false;
        } else if (this.telefone == "") {
          this.notifica("Telefone");
          return false;
        } else if (this.cep == "") {
          this.notifica("CEP");
          return false;
        } else if (this.numero == "") {
          this.notifica("Número de residência");
          return false;
        }
      } else if (this.tipo_pessoa == 2) {
        if (this.razao_social == "") {
          this.notifica("Nome");
          return false;
        } else if (this.endereco == "") {
          this.notifica("Endereço");
          return false;
        } else if (this.data_nasc == "") {
          this.notifica("Data de Nascimento");
          return false;
        } else if (this.telefone == "") {
          this.notifica("Telefone");
          return false;
        } else if (this.cep == "") {
          this.notifica("CEP");
          return false;
        } else if (this.numero == "") {
          this.notifica("Número de residência");
          return false;
        }
      }

      return true;
    },

    notifica(e) {
      notify("Preencha o campo: " + e);
    },

    async limpatudo() {
      this.cd_fornecedor = 0;
      this.fantasia = "";
      this.razao_social = "";
      this.cep = "";
      this.natural_estado = "";
      this.natural_cidade = "";
      this.bairro = "";
      this.endereco = "";
      this.numero = "";
      this.complemento = "";
      this.cidade = "";
      this.estado_civil = "";
      this.estado = "";
      this.data_nasc = "";
      this.rg = "";
      this.cd_cnpj = "";
      this.email = "";
      this.nm_mae = "";
      this.nome = null;
      this.telefone = "";
      this.celular = "";
      this.ramo_atividade = "";
      this.status_fornecedor = "";
      this.vl_renda_anual = "";
      this.vl_renda_mensal = "";
      this.nm_dominio_fornecedor = "";
      this.cd_inscMunicipal = "";
      this.vl_capital_social = "";
      this.cd_inscestadual = "";
    },

    selec_pessoa() {
      this.tipo_pessoa = this.tipo_pessoa_selecionada.cd_tipo_pessoa;
      this.limpatudo();
    },
  },
};
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
#grid-fornecedor {
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
  #grid-fornecedor {
    max-height: 100vh;
  }
  .margin1 {
    margin: 1vh 1vw;
  }
}
</style>
