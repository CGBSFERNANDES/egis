<template>
  <div>
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
            icon="directions_car"
            size="sm"
            @click="AddVeiculo()"
          >
            <q-tooltip
              anchor="bottom middle"
              self="top middle"
              :offset="[10, 10]"
            >
              Pesquisar Veículo
            </q-tooltip>
          </q-btn>
        </div>
      </transition>

      <q-space />
    </div>
    <!-- Pesquisa Veiculo -->
    <div v-if="ic_pesquisa">
      <q-input
        dense
        class="margin1"
        v-model="nm_veiculo"
        color="orange-9"
        type="text"
        label="Placa do Veículo"
        :loading="loading"
        debounce="1000"
        @input="PesquisaVeiculo(nm_veiculo)"
        @keypress.enter="TodosVeiculos"
      >
        <template v-slot:prepend>
          <q-icon name="directions_car" />
        </template>
        <template v-slot:append>
          <q-btn
            round
            color="orange-9"
            icon="search"
            size="sm"
            @click="TodosVeiculos"
          >
            <q-tooltip
              anchor="bottom middle"
              self="top middle"
              :offset="[10, 10]"
            >
              Pesquisar todos veículos
            </q-tooltip>
          </q-btn>
          <q-btn
            round
            color="orange-9"
            icon="add"
            size="sm"
            @click="AddVeiculo()"
          >
            <q-tooltip
              anchor="bottom middle"
              self="top middle"
              :offset="[10, 10]"
            >
              Adicionar Veículo
            </q-tooltip>
          </q-btn>

          <q-icon
            v-if="nm_veiculo !== ''"
            name="close"
            @click.stop="(cliente = ''), (nm_veiculo = ''), (GridCli = false)"
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
          @click="SelecionaLinha($event)"
        >
        </q-btn>
        <DxDataGrid
          class="margin1"
          id="grid_veiculo"
          key-expr="cd_controle"
          :data-source="dataset_cliente"
          :columns="columns"
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
          @row-dbl-click="SelecionaLinha($event)"
        >
        </DxDataGrid>
      </div>
      <!-- Dados Veiculo Pesquisado -->
      <transition name="slide-fade">
        <q-expansion-item
          v-if="!!linha.cd_veiculo"
          class="margin1 shadow-1 overflow-hidden"
          style="border-radius: 30px"
          header-class="bg-primary text-white"
          expand-icon-class="text-white"
          icon="directions_car"
          :label="`Dados do Veiculo - ${linha.nm_veiculo || ''}`"
        >
          <q-card>
            <q-card-section class="row">
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Veículo"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${!!linha.nm_veiculo ? linha.nm_veiculo : ""}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Marca"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.nm_marca_veiculo ? linha.nm_marca_veiculo : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Tipo de Combustível"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.nm_tipo_combustivel
                          ? linha.nm_tipo_combustivel
                          : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Cor"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${!!linha.nm_cor ? linha.nm_cor : ""}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Cliente"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.nm_fantasia_cliente
                          ? linha.nm_fantasia_cliente
                          : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Data de Aquisição"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.dt_aquisicao_veiculo
                          ? `${linha.dt_aquisicao_veiculo.slice(
                              8,
                              10
                            )}/${linha.dt_aquisicao_veiculo.slice(
                              5,
                              7
                            )}/${linha.dt_aquisicao_veiculo.slice(0, 4)}`
                          : ""
                      }`
                    }}
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
                    {{ `${!!linha.nm_cidade ? linha.nm_cidade : ""}` }}
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
                    {{ `${!!linha.nm_estado ? linha.nm_estado : ""}` }}
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
                label="Placa do Veículo"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.cd_placa_veiculo ? linha.cd_placa_veiculo : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Descrição"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${!!linha.ds_veiculo ? linha.ds_veiculo : ""}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Qtd. Revisões"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.qt_revisao_veiculo
                          ? linha.qt_revisao_veiculo
                          : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Qtd. Combustível"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.qt_combustivel_veiculo
                          ? linha.qt_combustivel_veiculo
                          : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="KM Atual"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.qt_km_atual_veiculo
                          ? linha.qt_km_atual_veiculo
                          : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Renavam"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.cd_renavam_veiculo
                          ? linha.cd_renavam_veiculo
                          : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Chassi"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.cd_chassi_veiculo ? linha.cd_chassi_veiculo : ""
                      }`
                    }}
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
                label="Qtd. Consumo"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.qt_consumo_veiculo
                          ? linha.qt_consumo_veiculo
                          : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Qtd. Entrega Diária"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.qt_entrega_diaria_veiculo
                          ? linha.qt_entrega_diaria_veiculo
                          : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Modelo"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.nm_modelo_veiculo ? linha.nm_modelo_veiculo : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="TAG"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${!!linha.cd_tag_veiculo ? linha.cd_tag_veiculo : ""}`
                    }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Capacidade"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${!!linha.qt_capacidade ? linha.qt_capacidade : ""}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Ano"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{ `${!!linha.aa_veiculo ? linha.aa_veiculo : ""}` }}
                  </div>
                </template>
              </q-field>
              <q-field
                class="col margin1"
                dense
                rounded
                standout
                label="Prefixo"
                stack-label
              >
                <template v-slot:control>
                  <div class="self-center full-width no-outline">
                    {{
                      `${
                        !!linha.nm_prefixo_veiculo
                          ? linha.nm_prefixo_veiculo
                          : ""
                      }`
                    }}
                  </div>
                </template>
              </q-field>
            </q-card-section>
          </q-card>
        </q-expansion-item>
      </transition>
      <!-- Dados Veiculo Pesquisado -->
    </div>
    <!-- Pesquisa Veiculo -->
    <div v-if="!ic_pesquisa">
      <q-tabs
        v-model="index"
        inline-label
        mobile-arrows
        align="justify"
        style="border-radius: 20px"
        :class="'bg-' + colorID + ' text-white shadow-2 margin1'"
      >
        <q-tab :name="0" icon="description" label="Dados" />
        <q-tab :name="1" icon="person" label="Veículo" />
      </q-tabs>

      <transition name="slide-fade">
        <div v-if="index == 0">
          <q-btn
            :color="colorID"
            icon="refresh"
            label="Recarregar"
            rounded
            size="md"
            class="margin1"
            @click="carregaDados()"
          />
          <q-btn
            :color="colorID"
            icon="add"
            label="Novo"
            rounded
            size="md"
            class="margin1"
            @click="onNovo()"
          />
          <dx-data-grid
            class="margin1 shadow-2"
            id="grid-veiculo"
            :data-source="consulta_veiculos"
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
            @selection-Changed="onFocusedRowChanged"
            @row-dbl-click="SelecionaLinha($event)"
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
          <!--API -  911 / PROCEDIMENTO - 1767 - pr_egisnet_crud_veiculo -->
        </div>
      </transition>
      <transition name="slide-fade">
        <div v-if="index == 1">
          <q-btn
            :color="colorID"
            icon="add"
            label="Novo"
            rounded
            size="md"
            class="margin1"
            @click="onNovo()"
          />
          <div class="row justify-around margin1">
            <q-select
              dense
              class="umTercoTela items-start margin1"
              option-value="cd_cliente"
              option-label="nm_fantasia_cliente"
              v-model="cliente"
              :options="lookup_dataset_cliente"
              label="Cliente"
            >
              <template v-slot:prepend>
                <q-icon name="person"></q-icon>
              </template>
            </q-select>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.cd_placa_veiculo"
              label="Placa de Veículo*"
              maxlength="7"
            >
              <template v-slot:prepend>
                <q-icon name="money"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.nm_veiculo"
              label="Veículo*"
            >
              <template v-slot:prepend>
                <q-icon name="directions_car"></q-icon>
              </template>
            </q-input>
            <q-select
              dense
              class="umTercoTela items-start margin1"
              option-value="cd_marca_veiculo"
              option-label="nm_marca_veiculo"
              v-model="marca"
              :options="lookup_dataset_marca"
              label="Marca"
            >
              <template v-slot:prepend>
                <q-icon name="branding_watermark"></q-icon>
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela items-start margin1"
              option-value="cd_tipo_combustivel"
              option-label="nm_tipo_combustivel"
              v-model="tipo_combustivel"
              :options="lookup_dataset_tipo_combustivel"
              label="Combustível"
            >
              <template v-slot:prepend>
                <q-icon name="local_gas_station"></q-icon>
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela items-start margin1"
              option-value="cd_cor"
              option-label="nm_cor"
              v-model="cor_veiculo"
              :options="lookup_dataset_cor_veiculo"
              label="Cor"
            >
              <template v-slot:prepend>
                <q-icon name="palette"></q-icon>
              </template>
            </q-select>

            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.dt_aquisicao_veiculo"
              type="date"
              stack-label
              label="Data de Aquisição"
            >
              <template v-slot:prepend>
                <q-icon name="event"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.qt_revisao_veiculo"
              type="number"
              min="0"
              label="Qtd. Revisões"
            >
              <template v-slot:prepend>
                <q-icon name="home_repair_service"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.ds_veiculo"
              label="Descrição"
            >
              <template v-slot:prepend>
                <q-icon name="description"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.qt_combustivel_veiculo"
              label="Qtd. Combustível"
              type="number"
              min="0"
            >
              <template v-slot:prepend>
                <q-icon name="local_gas_station"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.qt_km_atual_veiculo"
              label="KM Atual"
              type="number"
              min="0"
            >
              <template v-slot:prepend>
                <q-icon name="speed"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.cd_renavam_veiculo"
              label="Renavam"
              maxlength="11"
            >
              <template v-slot:prepend>
                <q-icon name="description"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.cd_chassi_veiculo"
              label="Chassi"
              maxlength="17"
            >
              <template v-slot:prepend>
                <q-icon name="description"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.qt_consumo_veiculo"
              label="Qtd. Consumo"
              type="number"
              min="0"
            >
              <template v-slot:prepend>
                <q-icon name="water_full"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.qt_entrega_diaria_veiculo"
              label="Qtd. Entrega Diária"
              type="number"
              min="0"
            >
              <template v-slot:prepend>
                <q-icon name="local_shipping"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.nm_modelo_veiculo"
              label="Modelo"
            >
              <template v-slot:prepend>
                <q-icon name="directions_car"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.cd_tag_veiculo"
              label="TAG"
            >
              <template v-slot:prepend>
                <q-icon name="sell"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela items-start margin1"
              v-model="veiculo.qt_capacidade"
              label="Capacidade"
              type="number"
              min="0"
            >
              <template v-slot:prepend>
                <q-icon name="reduce_capacity"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umQuartoTela items-start margin1"
              v-model="veiculo.nm_motor"
              label="Motor"
            >
              <template v-slot:prepend>
                <q-icon name="precision_manufacturing"></q-icon>
              </template>
            </q-input>
            <q-select
              dense
              class="umQuartoTela items-start margin1"
              option-value="cd_mecanico"
              option-label="nm_mecanico"
              v-model="mecanico"
              :options="lookup_dataset_mecanico"
              label="Mecânico"
            >
              <template v-slot:prepend>
                <q-icon name="engineering"></q-icon>
              </template>
            </q-select>
            <q-input
              dense
              class="umQuartoTela items-start margin1"
              v-model="veiculo.aa_veiculo"
              type="number"
              label="Ano"
            >
              <template v-slot:prepend>
                <q-icon name="description"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="umQuartoTela items-start margin1"
              v-model="veiculo.nm_prefixo_veiculo"
              label="Prefixo"
            >
              <template v-slot:prepend>
                <q-icon name="description"></q-icon>
              </template>
            </q-input>
          </div>
          <div class="row justify-around">
            <q-input
              dense
              class="margin1 umQuartoTela"
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
              class="margin1 umQuartoTela"
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
              class="margin1 umQuartoTela"
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

          <div class="row">
            <q-btn
              rounded
              class="margin1"
              :color="colorID"
              icon="save"
              label="Gravar"
              @click="onGravar()"
            />
            <q-btn
              v-if="
                veiculo.cd_veiculo > 0 &&
                veiculo.dt_baixa_veiculo == null &&
                1 == 2
              "
              rounded
              class="margin1"
              color="warning"
              icon="vertical_align_bottom"
              label="Baixar"
              @click="baixa_popup = !baixa_popup"
            />
            <q-btn
              v-if="veiculo.cd_veiculo > 0 && veiculo.dt_baixa_veiculo != null"
              rounded
              class="margin1"
              color="warning"
              icon="vertical_align_bottom"
              label="Retirar baixa"
              @click="onRetiraBaixa()"
            />
          </div>
        </div>
      </transition>
    </div>
    <!---BAIXA VEICULO----------------------------------->
    <q-dialog v-model="baixa_popup" persistent>
      <q-card style="min-width: 425px">
        <q-card-section class="q-pt-none">
          <div class="text-h6">Baixar o Veículo</div>
          <q-select
            dense
            class="margin1"
            option-value="cd_motivo_baixa_veiculo"
            option-label="nm_motivo_baixa_veiculo"
            v-model="motivo_baixa_veiculo"
            :options="lookup_dataset_motivo_baixa_veiculo"
            label="Motivo da baixa"
          >
            <template v-slot:prepend>
              <q-icon name="arrow_downward"></q-icon>
            </template>
          </q-select>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            rounded
            label="OK"
            color="primary"
            icon="check"
            @click="onBaixar()"
            v-close-popup
          />
          <q-btn
            rounded
            label="Cancelar"
            icon="close"
            color="primary"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!--------------------------------------------------->
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
import select from "../http/select";
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";
import { DxPopup } from "devextreme-vue/popup";
import carregando from "../components/carregando.vue";

import grid from "../views/grid";

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
  name: "veiculos",
  props: {
    cd_cadastro: { type: Number, default: 2 },
    cd_usuario: { type: String, default: "" },
    cd_cliente_props: { type: Number, default: 0 },
    cd_veiculo_props: { type: Number, default: 0 },
    ic_pesquisa: { type: Boolean, default: false },
    colorID: { type: String, default: "primary" },
  },

  data() {
    return {
      tituloMenu: "Dados do Veículo",
      columns: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      carregando: false,
      baixa_popup: false,
      cd_empresa: localStorage.cd_empresa,
      cd_cliente: 0,
      api: "911/1412", //pr_egisnet_crud_veiculo
      veiculo: {},
      load: false,
      linha: {},
      nm_dominio_cliente: "",
      // Pesquisa Veiculo
      nm_veiculo: "",
      loading: false,
      GridCli: false,
      cliente: "",
      resultado_pesquisa_veiculo: [],
      dataset_cliente: [],
      CNPJ: "",
      CEP: "",
      Endereco: "",
      Numero: "",
      Complemento: "",
      Bairro: "",
      Cidade: "",
      vendedor_api: "",
      //Contato do Cliente
      cliente_contato: "",
      lookup_cliente_contato: [],
      // Endereco do Cliente
      cliente_endereco: "",
      lookup_cliente_endereco: [],
      // Pesquisa Cliente
      cep: "",
      bairro: "",
      endereco: "",
      numero: "",
      complemento: "",
      cidade: "",
      estado: "",
      natural_estado: "",
      cd_pais: 0,
      consulta_veiculos: [],
      lookup_dataset: [],
      lookup_dados: [],
      carrega_cidade: false,
      lookup_dataset_cliente: [],
      marca: "",
      lookup_dataset_marca: [],
      tipo_combustivel: "",
      lookup_dataset_tipo_combustivel: [],
      motivo_baixa_veiculo: "",
      lookup_dataset_motivo_baixa_veiculo: [],
      cor_veiculo: "",
      lookup_dataset_cor_veiculo: [],
      mecanico: [],
      lookup_dataset_mecanico: [],
      lookup_dataset_ramo: [],
      lookup_estado_natural: [],
      lookup_cidade_natural: [],
      lookup_cidade_filtrado: [],
      natural_cidade: "",
      index: 0,
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    if (this.cd_usuario) {
      this.vendedor_api = await funcao.buscaVendedor(this.cd_usuario);
    }
    this.carregaDados();
    if (this.lookup_dataset_motivo_baixa_veiculo.length == 0) {
      let lokup_motivo_baixa_veiculo = await Lookup.montarSelect(
        this.cd_empresa,
        1270
      );
      this.lookup_dataset_motivo_baixa_veiculo = JSON.parse(
        JSON.parse(JSON.stringify(lokup_motivo_baixa_veiculo.dataset))
      );
    }
    let e = await Lookup.montarSelect(this.cd_empresa, 373);
    let lokup_cidade = await Lookup.montarSelect(this.cd_empresa, 97);
    this.lookup_cidade_natural = JSON.parse(
      JSON.parse(JSON.stringify(lokup_cidade.dataset))
    );
  },

  async mounted() {
    this.lookup_dados = await Lookup.montarSelect(this.cd_empresa, 116);
    this.lookup_dataset = JSON.parse(
      JSON.parse(JSON.stringify(this.lookup_dados.dataset))
    );

    var lookup_estado = await Lookup.montarSelect(this.cd_empresa, 731);
    var lokup = JSON.parse(JSON.parse(JSON.stringify(lookup_estado.dataset)));
    this.lookup_estado_natural = lokup.filter(
      (element) => element.cd_pais == 1
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
    grid,
  },
  watch: {
    async index(A, B) {
      if (this.index == 0) {
        await this.carregaDados();
      }
      if (this.index == 1) {
        await this.tabPanelTitleClick();
      }
    },
    async cd_veiculo_props(a, b) {
      if (a > 0) {
        let json_pesquisa = {
          cd_parametro: 0,
          cd_veiculo: a,
        };
        [this.linha] = await Incluir.incluirRegistro(
          "911/1412", //this.api,
          json_pesquisa
        );
        this.veiculo = this.linha;
        this.loading = false;
        this.GridCli = !this.ic_pesquisa;
      }
      if (a == 0) {
        this.resultado_pesquisa_veiculo = [];
        this.dataset_cliente = [];
        this.nm_veiculo = "";
        this.veiculo = {};
        this.linha = {};
      }
    },
    async cd_cliente_props(a, b) {
      if (a > 0 && this.ic_pesquisa) {
        let json_pesquisa = {
          cd_parametro: 0,
          cd_cliente: a,
        };
        this.resultado_pesquisa_veiculo = await Incluir.incluirRegistro(
          this.api,
          json_pesquisa
        );
        this.dataset_cliente = this.resultado_pesquisa_veiculo;
        this.loading = false;
        this.GridCli = !this.ic_pesquisa;
      }
      if (a == 0) {
        this.resultado_pesquisa_veiculo = [];
        this.dataset_cliente = [];
        this.nm_veiculo = "";
        this.veiculo = {};
        this.linha = {};
      }
    },
  },
  methods: {
    async SelecionaEstado(limpa) {
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

    async SelecionaEstadoEndereco(limpa) {
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

    async PesquisaVeiculo(p) {
      if (p == "") {
        this.GridCli = false;
        this.loading = false;
      } else {
        this.loading = true;
        this.GridCli = false;
        if (this.resultado_pesquisa_veiculo.length == 0) {
          let json_pesquisa_cliente = {
            cd_parametro: 0,
          };
          this.resultado_pesquisa_veiculo = await Incluir.incluirRegistro(
            this.api,
            json_pesquisa_cliente
          );
        }
        if (!!parseInt(this.nm_veiculo)) {
          this.dataset_cliente = this.resultado_pesquisa_veiculo.filter(
            (f) => f.cd_placa_veiculo == this.nm_veiculo
          );
        } else {
          this.dataset_cliente = this.resultado_pesquisa_veiculo.filter((f) =>
            f.cd_placa_veiculo
              .toUpperCase()
              .startsWith(this.nm_veiculo.toUpperCase())
          );
        }
        if (this.resultado_pesquisa_veiculo[0].Cod == 0) {
          notify(this.resultado_pesquisa_veiculo[0].Msg);
          return;
        } else {
          this.loading = false;
          this.GridCli = true;
        }
      }
    },

    async TodosVeiculos() {
      if (this.nm_veiculo == "") {
        await this.PesquisaVeiculo();
      }
    },
    AddVeiculo() {
      this.$emit("update:ic_pesquisa", !this.ic_pesquisa);
      this.onNovo();
    },
    async SelecionaLinha(e) {
      this.linha = e.data;
      this.cd_cliente = this.linha.cd_cliente;
      ////Endereço do Cliente
      let endereco_json = {
        cd_empresa: this.cd_empresa,
        cd_tabela: 121,
        order: "D",
        join: "Tipo_Endereco",
        where: [{ cd_cliente: this.cd_cliente }],
      };
      let endereco = await select.montarSelect(this.cd_empresa, endereco_json);
      this.lookup_cliente_endereco = JSON.parse(
        JSON.parse(JSON.stringify(endereco[0].dataset))
      );
      //Cliente//
      this.$emit("DbClick", this.linha);
      if (!this.ic_pesquisa) {
        this.AddVeiculo();
      } else {
        this.GridCli = false;
      }
    },

    async carregaDados() {
      let dados_linha = await Menu.montarMenu(localStorage.cd_empresa, 0, 911); //pr_egisnet_crud_veiculo
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados_linha.coluna)));

      let json_pesquisa_veiculo = {
        cd_parametro: 0,
      };
      this.consulta_veiculos = await Incluir.incluirRegistro(
        this.api,
        json_pesquisa_veiculo
      );
    },

    onDbClick(e) {
      this.$emit("DbClick", e.data);
    },

    async onFocusedRowChanged({ selectedRowKeys, selectedRowsData }) {
      this.veiculo = selectedRowsData[0];
      this.veiculo.dt_aquisicao_veiculo != null
        ? (this.veiculo.dt_aquisicao_veiculo =
            this.veiculo.dt_aquisicao_veiculo.slice(0, 10))
        : "";
      [this.marca] = this.lookup_dataset_marca.filter(
        (m) => m.cd_marca_veiculo == this.veiculo.cd_marca_veiculo
      );
      [this.tipo_combustivel] = this.lookup_dataset_tipo_combustivel.filter(
        (m) => m.cd_tipo_combustivel == this.veiculo.cd_tipo_combustivel
      );
      [this.cor_veiculo] = this.lookup_dataset_cor_veiculo.filter(
        (m) => m.cd_cor == this.veiculo.cd_cor
      );
      [this.mecanico] = this.lookup_dataset_mecanico.filter(
        (m) => m.cd_mecanico == this.mecanico.cd_mecanico
      );
      [this.cliente] = this.lookup_dataset_cliente.filter(
        (m) => m.cd_cliente == this.veiculo.cd_cliente
      );
    },

    async exclusao(e) {
      let line = e.data;
      let ex = {
        cd_parametro: 3,
        cd_veiculo: line.cd_veiculo,
      };
      var exc = await Incluir.incluirRegistro(this.api, ex);
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
              this.cd_cliente,
              "413/550",
              "/${cd_empresa}/${cd_cep}"
            );

            this.endereco = this.dataSourceConfig[0].logradouro;
            this.bairro = this.dataSourceConfig[0].bairro;
            this.complemento = this.dataSourceConfig[0].complemento;
            [this.estado] = this.lookup_estado_natural.filter(
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
            console.error(err);
          }
        }
      }
      this.load = false;
    },

    async onGravar() {
      let retorno;

      this.carregando = true;
      var cd_parametro = 0;
      if (!this.veiculo.cd_veiculo) {
        cd_parametro = 1; //Insere
      } else {
        cd_parametro = 2; //Atualiza
      }
      let cli = {
        cd_parametro: cd_parametro,
        ...this.veiculo,
        cd_marca_veiculo:
          this.marca == undefined ? null : this.marca.cd_marca_veiculo,
        cd_cor: this.cor_veiculo == undefined ? null : this.cor_veiculo.cd_cor,
        cd_mecanico:
          this.mecanico == undefined ? null : this.mecanico.cd_mecanico,
        cd_tipo_combustivel:
          this.tipo_combustivel == undefined
            ? null
            : this.tipo_combustivel.cd_tipo_combustivel,
        cd_cliente: this.cliente.cd_cliente,
        cd_cep: this.cep,
        cd_numero_endereco: this.numero,
        cd_usuario: localStorage.cd_usuario,
        nm_bairro: !!this.bairro ? funcao.ValidaString(this.bairro, 60) : "",
        nm_endereco: !!this.endereco
          ? funcao.ValidaString(this.endereco, 60)
          : "",
        nm_complemento_endereco: !!this.complemento
          ? funcao.ValidaString(this.complemento, 60)
          : "",
        cd_estado: this.estado == undefined ? null : this.estado.cd_estado,
        cd_cidade: this.cidade == undefined ? null : this.cidade.cd_cidade,
        cd_pais: this.cd_pais,
      };
      if (this.validaCampos()) {
        try {
          var a = await Incluir.incluirRegistro(this.api, cli);
          notify(a[0].Msg);
          this.carregando = false;
          if (a[0].cd_veiculo != undefined) {
            this.veiculo.cd_veiculo = a[0].cd_veiculo;
            this.SelecionaLinha({
              data: { ...cli, cd_veiculo: a[0].cd_veiculo },
            });
          }
        } catch {
          notify("Não foi possível atualizar esse veículo.");
          this.carregando = false;
        }
        return retorno;
      } else {
        this.carregando = false;
        return retorno;
      }
    },

    async onBaixar() {
      if (this.motivo_baixa_veiculo.cd_motivo_baixa_veiculo > 0) {
        let json_baixa_veiculo = {
          cd_parametro: 4,
          cd_veiculo: this.veiculo.cd_veiculo,
          cd_motivo_baixa_veiculo:
            this.motivo_baixa_veiculo.cd_motivo_baixa_veiculo,
        };
        let baixa_veiculo = await Incluir.incluirRegistro(
          this.api,
          json_baixa_veiculo
        );
        notify(baixa_veiculo[0].Msg);
      }
    },

    async onRetiraBaixa() {
      let json_retira_baixa = {
        cd_parametro: 5,
        cd_veiculo: this.veiculo.cd_veiculo,
      };
      let baixa_veiculo = await Incluir.incluirRegistro(
        this.api,
        json_retira_baixa
      );
      notify(baixa_veiculo[0].Msg);
    },

    async consultaCliente() {
      let api = "477/671"; //1350 -
      localStorage.nm_fantasia = "null";
      try {
        let dados_cliente = await Procedimento.montarProcedimento(
          localStorage.cd_empresa,
          localStorage.cd_cliente,
          api,
          "/${cd_empresa}/${cd_parametro}/${nm_fantasia}"
        );
        if (dados_cliente[0].Cod == 0) {
          notify(dados_cliente[0].Msg);
          return;
        }
        this.cliente = {
          cd_cliente: dados_cliente[0].cd_cliente,
          nm_fantasia_cliente: dados_cliente[0].nm_razao_social_cliente,
        };
        this.cd_cliente = dados_cliente[0].cd_cliente;
        //Campos do expansion item
        this.CEP = dados_cliente[0].cd_cep;
        this.Endereco = dados_cliente[0].nm_endereco_cliente;
        this.Numero = dados_cliente[0].cd_numero_endereco;
        this.Complemento = dados_cliente[0].nm_complemento_endereco;
        this.Cidade = dados_cliente[0].nm_cidade;
        this.estado = dados_cliente[0].nm_estado;
        // Cliente Contato
        let contatos_json = {
          cd_empresa: this.cd_empresa,
          cd_tabela: 111,
          order: "D",
          where: [{ cd_cliente: this.cd_cliente }],
        };
        let contatos = await select.montarSelect(
          this.cd_empresa,
          contatos_json
        );
        this.lookup_cliente_contato = JSON.parse(
          JSON.parse(JSON.stringify(contatos[0].dataset))
        );
        this.cliente_contato = this.lookup_cliente_contato[0];
        this.nm_dominio_cliente = dados_cliente[0].nm_dominio_cliente;
        this.cep = dados_cliente[0].cd_cep;
        this.bairro = dados_cliente[0].nm_bairro;
        this.endereco = dados_cliente[0].nm_endereco_cliente;
        this.numero = dados_cliente[0].cd_numero_endereco;
        this.complemento = dados_cliente[0].nm_complemento_endereco;

        this.estado = {
          cd_estado: dados_cliente[0].cd_estado,
          nm_estado: dados_cliente[0].nm_estado,
        };

        //this.estado = await this.lookup_estado_natural.find(
        //  (element) => element.cd_estado == dados_cliente[0].cd_estado
        //);
        this.cidade = this.lookup_cidade_natural.find(
          (element) => element.cd_cidade == dados_cliente[0].cd_cidade
        );
        if (this.estado.cd_estado > 0) {
          this.lookup_cidade_filtrado = this.lookup_cidade_natural.filter(
            (e) => {
              return e.cd_estado == this.estado.cd_estado;
            }
          );
        }
      } catch (err) {
        console.err(err);
      }
    },

    async onNovo() {
      await this.limpatudo();
      this.index = 1;
    },

    async tabPanelTitleClick(e) {
      if (this.lookup_dataset_marca.length == 0) {
        let lokup_marca = await Lookup.montarSelect(this.cd_empresa, 1269);
        this.lookup_dataset_marca = JSON.parse(
          JSON.parse(JSON.stringify(lokup_marca.dataset))
        );
      }

      if (this.lookup_dataset_tipo_combustivel == 0) {
        let lokup_tipo_combustivel = await Lookup.montarSelect(
          this.cd_empresa,
          1267
        );
        this.lookup_dataset_tipo_combustivel = JSON.parse(
          JSON.parse(JSON.stringify(lokup_tipo_combustivel.dataset))
        );
      }

      if (this.lookup_dataset_cor_veiculo == 0) {
        let lokup_cor_veiculo = await Lookup.montarSelect(
          this.cd_empresa,
          5641
        );
        this.lookup_dataset_cor_veiculo = JSON.parse(
          JSON.parse(JSON.stringify(lokup_cor_veiculo.dataset))
        );
      }

      if (this.lookup_dataset_mecanico == 0) {
        let lokup_mecanico = await Lookup.montarSelect(this.cd_empresa, 3622);
        this.lookup_dataset_mecanico = JSON.parse(
          JSON.parse(JSON.stringify(lokup_mecanico.dataset))
        );
      }

      if (this.lookup_dataset_cliente == 0) {
        let cliente_json = {
          cd_empresa: this.cd_empresa,
          cd_tabela: 93,
          order: "D",
          where: [{ cd_status_cliente: "1" }],
        };
        let lookup_cliente = await select.montarSelect(
          this.cd_empresa,
          cliente_json
        );
        this.lookup_dataset_cliente = JSON.parse(
          JSON.parse(JSON.stringify(lookup_cliente[0].dataset))
        );
      }

      if (!!this.cliente.cd_cliente == true) {
        this.cd_cliente = this.cliente.cd_cliente;
      }
      this.cd_pais = this.cliente.cd_pais;
      this.nm_dominio_cliente = this.cliente.nm_dominio_cliente;
      //this.cod_cli = this.cliente.cd_cliente;
      this.cep = this.cliente.cd_cep;
      this.bairro = this.cliente.nm_bairro;
      this.endereco = this.cliente.nm_endereco_cliente;
      this.numero = this.cliente.cd_numero_endereco;
      this.complemento = this.cliente.nm_complemento_endereco;

      this.cidade = {
        cd_cidade: this.cliente.cd_cidade,
        nm_cidade: this.cliente.nm_cidade,
      };
      this.estado = {
        cd_estado: this.cliente.cd_estado,
        nm_estado: this.cliente.nm_estado,
      };
    },
    validaCampos() {
      if (
        this.veiculo.nm_veiculo == undefined ||
        this.veiculo.nm_veiculo == ""
      ) {
        this.notifica("Veículo");
        return false;
      } else if (
        this.veiculo.cd_placa_veiculo == undefined ||
        this.veiculo.cd_placa_veiculo == ""
      ) {
        this.notifica("Placa do veículo");
        return false;
      } else if (this.cliente.cd_cliente == undefined) {
        this.notifica("Cliente");
        return false;
      }

      return true;
    },

    notifica(e) {
      notify("Preencha o campo: " + e);
    },

    async limpatudo() {
      this.veiculo = {};
      this.cliente = "";
      this.cd_cliente = 0;
      this.cep = "";
      this.natural_estado = "";
      this.natural_cidade = "";
      this.bairro = "";
      this.endereco = "";
      this.numero = "";
      this.complemento = "";
      this.cidade = "";
      this.estado = "";
      this.nm_dominio_cliente = "";
    },
  },
};
</script>

<style scoped>
.metadeTela {
  width: 47.5%;
}

.umTercoTela {
  width: 31%;
}

.umQuartoTela {
  width: 22.5%;
}
#grid-veiculo {
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
  #grid-veiculo {
    max-height: 100vh;
  }
  .margin1 {
    margin: 1vh 1vw;
  }
}
</style>
