<template>
  <div>
    <div class="margin1 titulo-bloco">Contas a Pagar</div>
    <q-tabs
      v-model="tab"
      class="text-orange-9"
      dense
      align="justify"
      inline-label
      @input="onTabs()"
    >
      <q-tab name="dados" icon="folder" label="Dados" />
      <q-tab name="documento" icon="description" label="Documento" />
      <q-tab name="baixa" icon="price_check" label="Baixa" />
      <q-tab name="cancelamento" icon="block" label="Cancelamento" />
    </q-tabs>
    <q-tab-panels v-model="tab" animated>
      <q-tab-panel name="dados">
        <div
          class="row margin1 borda-bloco shadow-2"
          style="font-weight: bold; max-width: 40%"
        >
          <div class="margin1 row">
            {{ `Tipo de Consulta` }}
          </div>
          <div class="row">
            <q-radio v-model="ic_tipo_consulta" val="line" label="Aberto" />
            <q-radio v-model="ic_tipo_consulta" val="rectangle" label="Pagos" />
            <q-radio v-model="ic_tipo_consulta" val="ellipse" label="Todos" />
          </div>
        </div>
        <dx-data-grid
          id="grid-padrao"
          class="dx-card wide-card-gc"
          :data-source="dataSource"
          key-expr="cd_controle"
          :show-borders="true"
          :focused-row-enabled="true"
          :column-auto-width="true"
          :column-hiding-enabled="false"
          :remote-operations="false"
          :word-wrap-enabled="false"
          :allow-column-reordering="true"
          :allow-column-resizing="true"
          :row-alternation-enabled="false"
          :repaint-changes-only="true"
          :autoNavigateToFocusedRow="true"
          :cacheEnable="false"
        >
          <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
          <DxGrouping :auto-expand-all="true" />
          <DxExport :enabled="true" />
          <DxPaging :enable="true" :page-size="10" />
          <DxStateStoring
            :enabled="true"
            type="localStorage"
            storage-key="storage"
          />
          <DxPager
            :show-page-size-selector="true"
            :allowed-page-sizes="[10, 20, 50, 100]"
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
        </dx-data-grid>
      </q-tab-panel>
      <q-tab-panel name="documento">
        <div
          class="row margin1 borda-bloco shadow-2"
          style="font-weight: bold; max-width: 40%"
        >
          <div class="margin1 row">{{ `Tipo de Documento` }}</div>
          <div class="row">
            <q-radio
              class="col"
              v-model="ic_tipo_documento"
              val="Diversos"
              label="Diversos"
              color="orange-9"
            />
            <q-radio
              class="col"
              v-model="ic_tipo_documento"
              val="Fornecedor"
              label="Fornecedor"
              color="orange-9"
            />
          </div>
        </div>
        <div class="row">
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Identificação"
          >
            <template v-slot:prepend>
              <q-icon name="badge" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Vencimento Original"
          >
            <template v-slot:append>
              <q-btn
                icon="event"
                color="orange-9"
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
                    <div class="row items-center justify-end">
                      <q-btn v-close-popup round flat icon="close" size="sm" />
                    </div>
                  </q-date>
                </q-popup-proxy>
              </q-btn>
            </template>
            <template v-slot:prepend>
              <q-icon name="today" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Vencimento">
            <template v-slot:append>
              <q-btn
                icon="event"
                color="orange-9"
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
                    <div class="row items-center justify-end">
                      <q-btn v-close-popup round flat icon="close" size="sm" />
                    </div>
                  </q-date>
                </q-popup-proxy>
              </q-btn>
            </template>
            <template v-slot:prepend>
              <q-icon name="today" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Emissão">
            <template v-slot:append>
              <q-btn
                icon="event"
                color="orange-9"
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
                    <div class="row items-center justify-end">
                      <q-btn v-close-popup round flat icon="close" size="sm" />
                    </div>
                  </q-date>
                </q-popup-proxy>
              </q-btn>
            </template>
            <template v-slot:prepend>
              <q-icon name="today" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
        <transition name="slide-fade">
          <div
            class="row margin1 borda-bloco shadow-2"
            v-if="ic_tipo_documento == 'Diversos'"
          >
            <div
              class="col margin1 borda-bloco shadow-2"
              style="display: flex; font-weight: bold; flex-wrap: wrap"
            >
              <div class="margin1">Favorecido</div>
              <q-radio
                class="row"
                v-model="ic_favorecido"
                val="empresa_diversa"
                label="Empresa Diversa"
                color="orange-9"
              />
              <q-radio
                class="row"
                v-model="ic_favorecido"
                val="funcionario"
                label="Funcionário"
                color="orange-9"
              />
              <q-radio
                class="row"
                v-model="ic_favorecido"
                val="contrato"
                label="Contrato"
                color="orange-9"
              />
            </div>
            <div class="col">
              <div class="row" v-if="ic_favorecido == 'empresa_diversa'">
                <q-input
                  dense
                  class="col margin1"
                  v-model="text"
                  label="Empresa Diversa"
                  ><template v-slot:prepend>
                    <q-icon name="store" class="cursor-pointer"></q-icon>
                  </template>
                </q-input>
                <q-input
                  dense
                  class="col margin1"
                  v-model="text"
                  label="Favorecido da Empresa Diversa"
                  ><template v-slot:prepend>
                    <q-icon name="store" class="cursor-pointer"></q-icon>
                  </template>
                </q-input>
              </div>
              <div v-if="ic_favorecido == 'funcionario'">
                <q-input
                  dense
                  class="col margin1"
                  v-model="text"
                  label="Funcionário"
                  ><template v-slot:prepend>
                    <q-icon name="group" class="cursor-pointer"></q-icon>
                  </template>
                </q-input>
              </div>
              <div v-if="ic_favorecido == 'contrato'">
                <q-input
                  dense
                  class="col margin1"
                  v-model="text"
                  label="Contrato / Fornecedor"
                  ><template v-slot:prepend>
                    <q-icon name="work" class="cursor-pointer"></q-icon>
                  </template>
                </q-input>
              </div>
            </div>
          </div>
        </transition>
        <transition name="slide-fade">
          <div
            class="margin1 borda-bloco shadow-2"
            v-if="ic_tipo_documento == 'Fornecedor'"
          >
            <div class="margin1" style="font-weight: bold">Documento</div>
            <div class="row">
              <q-input dense class="col margin1" v-model="text" label="REM/RENA"
                ><template v-slot:prepend>
                  <q-icon
                    name="format_list_bulleted"
                    class="cursor-pointer"
                  ></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="col margin1"
                v-model="text"
                label="Data REM"
              >
                <template v-slot:append>
                  <q-btn
                    icon="event"
                    color="orange-9"
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
                        <div class="row items-center justify-end">
                          <q-btn
                            v-close-popup
                            round
                            flat
                            icon="close"
                            size="sm"
                          />
                        </div>
                      </q-date>
                    </q-popup-proxy>
                  </q-btn>
                </template>
                <template v-slot:prepend>
                  <q-icon name="event" class="cursor-pointer"></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="col margin1"
                v-model="text"
                label="Nota Fiscal de Saída"
                ><template v-slot:prepend>
                  <q-icon name="receipt_long" class="cursor-pointer"></q-icon>
                </template>
              </q-input>
            </div>
            <div class="row">
              <q-input dense class="col margin1" v-model="text" label="NF"
                ><template v-slot:prepend>
                  <q-icon name="summarize" class="cursor-pointer"></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="col margin1"
                v-model="text"
                label="Série NFE"
                ><template v-slot:prepend>
                  <q-icon
                    name="format_list_numbered"
                    class="cursor-pointer"
                  ></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="col margin1"
                v-model="text"
                label="Pedido de Compra"
                ><template v-slot:prepend>
                  <q-icon name="article" class="cursor-pointer"></q-icon>
                </template>
              </q-input>
            </div>
            <div class="row">
              <q-input
                dense
                class="col margin1"
                v-model="text"
                label="Data Contábil"
              >
                <template v-slot:append>
                  <q-btn
                    icon="event"
                    color="orange-9"
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
                        <div class="row items-center justify-end">
                          <q-btn
                            v-close-popup
                            round
                            flat
                            icon="close"
                            size="sm"
                          />
                        </div>
                      </q-date>
                    </q-popup-proxy>
                  </q-btn>
                </template>
                <template v-slot:prepend>
                  <q-icon name="event" class="cursor-pointer"></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="col margin1"
                v-model="text"
                label="Nº Borderô"
                ><template v-slot:prepend>
                  <q-icon
                    name="format_list_bulleted"
                    class="cursor-pointer"
                  ></q-icon>
                </template>
              </q-input>
              <q-input
                dense
                class="col margin1"
                v-model="text"
                label="Data Devolução"
              >
                <template v-slot:append>
                  <q-btn
                    icon="event"
                    color="orange-9"
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
                        <div class="row items-center justify-end">
                          <q-btn
                            v-close-popup
                            round
                            flat
                            icon="close"
                            size="sm"
                          />
                        </div>
                      </q-date>
                    </q-popup-proxy>
                  </q-btn>
                </template>
                <template v-slot:prepend>
                  <q-icon name="event" class="cursor-pointer"></q-icon>
                </template>
              </q-input>
              <q-input dense class="col margin1" v-model="text" label="Motivo"
                ><template v-slot:prepend>
                  <q-icon name="speaker_notes" class="cursor-pointer"></q-icon>
                </template>
              </q-input>
            </div>
          </div>
        </transition>
        <div class="row">
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Tipo de Documento"
            ><template v-slot:prepend>
              <q-icon
                name="format_list_bulleted"
                class="cursor-pointer"
              ></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Centro de Custo"
            ><template v-slot:prepend>
              <q-icon name="location_city" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Classificação da Conta"
            ><template v-slot:prepend>
              <q-icon name="checklist" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            readonly
            v-model="text"
            label="Valor Principal"
            ><template v-slot:prepend>
              <q-icon name="attach_money" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
        <div class="row">
          <q-input dense class="col margin1" v-model="text" label="Observação"
            ><template v-slot:prepend>
              <q-icon name="visibility" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Moeda"
            ><template v-slot:prepend>
              <q-icon name="monetization_on" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Saldo a Pagar"
            ><template v-slot:prepend>
              <q-icon name="payments" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
        <div class="row margin1 borda-bloco shadow-2">
          <div class="margin1 titulo-bloco">{{ `Dados bancários` }}</div>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Banco | Agência | Conta"
            ><template v-slot:prepend>
              <q-icon name="account_balance" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Situação do Documento"
            ><template v-slot:prepend>
              <q-icon
                name="format_list_bulleted"
                class="cursor-pointer"
              ></q-icon>
            </template>
          </q-input>
        </div>
        <div class="row margin1 borda-bloco shadow-2">
          <div class="margin1 titulo-bloco">{{ `Plano Financeiro` }}</div>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Plano Financeiro"
            ><template v-slot:prepend>
              <q-icon
                name="format_list_bulleted"
                class="cursor-pointer"
              ></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Conta Contábil"
            ><template v-slot:prepend>
              <q-icon
                name="format_list_bulleted"
                class="cursor-pointer"
              ></q-icon>
            </template>
          </q-input>
        </div>
        <transition name="slide-fade">
          <div v-if="ic_ativa_btn == true">
            <q-btn
              rounded
              color="orange-9"
              icon="save"
              label="Salvar"
              class="margin1"
            >
              <q-tooltip> Salvar </q-tooltip>
            </q-btn>
            <q-btn
              rounded
              flat
              color="orange-9"
              icon="cleaning_services"
              style="float: right"
              label="Limpar"
              class="margin1"
              @click="OnLimpar()"
            >
              <q-tooltip> Limpar </q-tooltip>
            </q-btn>
          </div>
        </transition>
      </q-tab-panel>

      <q-tab-panel name="baixa">
        <div class="row">
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Código/Fantasia"
          >
            <template v-slot:prepend>
              <q-icon name="badge" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Identificação"
          >
            <template v-slot:prepend>
              <q-icon name="badge" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Emissão">
            <template v-slot:prepend>
              <q-icon name="event" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Vencimento">
            <template v-slot:prepend>
              <q-icon name="event" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
        <div class="row">
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Valor Original"
          >
            <template v-slot:prepend>
              <q-icon name="attach_money" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Juros">
            <template v-slot:prepend>
              <q-icon
                name="account_balance_wallet"
                class="cursor-pointer"
              ></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Abatimento">
            <template v-slot:prepend>
              <svg style="width: 24px; height: 24px" viewBox="0 0 24 24">
                <path
                  fill="currentColor"
                  d="M20.04,8.71V4H15.34L12,0.69L8.71,4H4V8.71L0.69,12L4,15.34V20.04H8.71L12,23.35L15.34,20.04H20.04V15.34L23.35,12L20.04,8.71M8.83,7.05C9.81,7.05 10.6,7.84 10.6,8.83A1.77,1.77 0 0,1 8.83,10.6C7.84,10.6 7.05,9.81 7.05,8.83C7.05,7.84 7.84,7.05 8.83,7.05M15.22,17C14.24,17 13.45,16.2 13.45,15.22A1.77,1.77 0 0,1 15.22,13.45C16.2,13.45 17,14.24 17,15.22A1.78,1.78 0 0,1 15.22,17M8.5,17.03L7,15.53L15.53,7L17.03,8.5L8.5,17.03Z"
                />
              </svg>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Desconto">
            <template v-slot:prepend>
              <svg style="width: 24px; height: 24px" viewBox="0 0 24 24">
                <path
                  fill="currentColor"
                  d="M20.04,8.71V4H15.34L12,0.69L8.71,4H4V8.71L0.69,12L4,15.34V20.04H8.71L12,23.35L15.34,20.04H20.04V15.34L23.35,12L20.04,8.71M8.83,7.05C9.81,7.05 10.6,7.84 10.6,8.83A1.77,1.77 0 0,1 8.83,10.6C7.84,10.6 7.05,9.81 7.05,8.83C7.05,7.84 7.84,7.05 8.83,7.05M15.22,17C14.24,17 13.45,16.2 13.45,15.22A1.77,1.77 0 0,1 15.22,13.45C16.2,13.45 17,14.24 17,15.22A1.78,1.78 0 0,1 15.22,17M8.5,17.03L7,15.53L15.53,7L17.03,8.5L8.5,17.03Z"
                />
              </svg>
            </template>
          </q-input>
        </div>
        <div class="row">
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Total Adiantamento"
          >
            <template v-slot:prepend>
              <q-icon name="add" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Acréscimos">
            <template v-slot:prepend>
              <q-icon name="add" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Multa">
            <template v-slot:prepend>
              <q-icon name="description" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Saldo á Pagar"
          >
            <template v-slot:prepend>
              <q-icon name="attach_money" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
        <div class="margin1 borda-bloco shadow-2">
          <div class="margin1 titulo-bloco">{{ "Baixa" }}</div>
          <div class="row">
            LANÇAMENTO DE NOVAS BAIXAS (CRUD)
            <q-input
              dense
              class="col margin1"
              v-model="text"
              label="Data de Pagamento"
            >
              <template v-slot:prepend>
                <q-icon name="event" class="cursor-pointer"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="col margin1"
              v-model="text"
              label="Tipo de Pagamento"
            >
              <template v-slot:prepend>
                <q-icon
                  name="format_list_bulleted"
                  class="cursor-pointer"
                ></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="col margin1"
              v-model="text"
              label="Identificação do Pagamento"
            >
              <template v-slot:prepend>
                <q-icon name="task" class="cursor-pointer"></q-icon>
              </template>
            </q-input>
          </div>
          <div class="row">
            <q-input
              dense
              class="col margin1"
              v-model="text"
              label="Valor Original"
            >
              <template v-slot:prepend>
                <q-icon name="attach_money" class="cursor-pointer"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="col margin1"
              v-model="text"
              label="(+) Juros/Multa"
            >
              <template v-slot:prepend>
                <svg style="width: 24px; height: 24px" viewBox="0 0 24 24">
                  <path
                    fill="currentColor"
                    d="M20.04,8.71V4H15.34L12,0.69L8.71,4H4V8.71L0.69,12L4,15.34V20.04H8.71L12,23.35L15.34,20.04H20.04V15.34L23.35,12L20.04,8.71M8.83,7.05C9.81,7.05 10.6,7.84 10.6,8.83A1.77,1.77 0 0,1 8.83,10.6C7.84,10.6 7.05,9.81 7.05,8.83C7.05,7.84 7.84,7.05 8.83,7.05M15.22,17C14.24,17 13.45,16.2 13.45,15.22A1.77,1.77 0 0,1 15.22,13.45C16.2,13.45 17,14.24 17,15.22A1.78,1.78 0 0,1 15.22,17M8.5,17.03L7,15.53L15.53,7L17.03,8.5L8.5,17.03Z"
                  />
                </svg>
              </template>
            </q-input>
            <q-input
              dense
              class="col margin1"
              v-model="text"
              label="(-) Abatimento"
            >
              <template v-slot:prepend>
                <svg style="width: 24px; height: 24px" viewBox="0 0 24 24">
                  <path
                    fill="currentColor"
                    d="M20.04,8.71V4H15.34L12,0.69L8.71,4H4V8.71L0.69,12L4,15.34V20.04H8.71L12,23.35L15.34,20.04H20.04V15.34L23.35,12L20.04,8.71M8.83,7.05C9.81,7.05 10.6,7.84 10.6,8.83A1.77,1.77 0 0,1 8.83,10.6C7.84,10.6 7.05,9.81 7.05,8.83C7.05,7.84 7.84,7.05 8.83,7.05M15.22,17C14.24,17 13.45,16.2 13.45,15.22A1.77,1.77 0 0,1 15.22,13.45C16.2,13.45 17,14.24 17,15.22A1.78,1.78 0 0,1 15.22,17M8.5,17.03L7,15.53L15.53,7L17.03,8.5L8.5,17.03Z"
                  />
                </svg>
              </template>
            </q-input>
            <q-input
              dense
              class="col margin1"
              v-model="text"
              label="(-) Desconto"
            >
              <template v-slot:prepend>
                <svg style="width: 24px; height: 24px" viewBox="0 0 24 24">
                  <path
                    fill="currentColor"
                    d="M20.04,8.71V4H15.34L12,0.69L8.71,4H4V8.71L0.69,12L4,15.34V20.04H8.71L12,23.35L15.34,20.04H20.04V15.34L23.35,12L20.04,8.71M8.83,7.05C9.81,7.05 10.6,7.84 10.6,8.83A1.77,1.77 0 0,1 8.83,10.6C7.84,10.6 7.05,9.81 7.05,8.83C7.05,7.84 7.84,7.05 8.83,7.05M15.22,17C14.24,17 13.45,16.2 13.45,15.22A1.77,1.77 0 0,1 15.22,13.45C16.2,13.45 17,14.24 17,15.22A1.78,1.78 0 0,1 15.22,17M8.5,17.03L7,15.53L15.53,7L17.03,8.5L8.5,17.03Z"
                  />
                </svg>
              </template>
            </q-input>
            <q-input
              dense
              class="col margin1"
              v-model="text"
              label="(+) Outros Acréscimos"
            >
              <template v-slot:prepend>
                <svg style="width: 24px; height: 24px" viewBox="0 0 24 24">
                  <path
                    fill="currentColor"
                    d="M20.04,8.71V4H15.34L12,0.69L8.71,4H4V8.71L0.69,12L4,15.34V20.04H8.71L12,23.35L15.34,20.04H20.04V15.34L23.35,12L20.04,8.71M8.83,7.05C9.81,7.05 10.6,7.84 10.6,8.83A1.77,1.77 0 0,1 8.83,10.6C7.84,10.6 7.05,9.81 7.05,8.83C7.05,7.84 7.84,7.05 8.83,7.05M15.22,17C14.24,17 13.45,16.2 13.45,15.22A1.77,1.77 0 0,1 15.22,13.45C16.2,13.45 17,14.24 17,15.22A1.78,1.78 0 0,1 15.22,17M8.5,17.03L7,15.53L15.53,7L17.03,8.5L8.5,17.03Z"
                  />
                </svg>
              </template>
            </q-input>
            <q-input
              dense
              class="col margin1"
              v-model="text"
              label="Total Pago"
            >
              <template v-slot:prepend>
                <q-icon name="attach_money" class="cursor-pointer"></q-icon>
              </template>
            </q-input>
          </div>
          <div class="row margin1 borda-bloco shadow-2">
            <div class="margin1 titulo-bloco">{{ `Dados bancários` }}</div>
            <q-input dense class="col margin1" v-model="text" label="Conta">
              <template v-slot:prepend>
                <q-icon
                  name="account_balance_wallet"
                  class="cursor-pointer"
                ></q-icon>
              </template>
            </q-input>
            <q-input dense class="col margin1" v-model="text" label="Agência">
              <template v-slot:prepend>
                <q-icon name="account_balance" class="cursor-pointer"></q-icon>
              </template>
            </q-input>
            <q-input dense class="col margin1" v-model="text" label="Banco">
              <template v-slot:prepend>
                <q-icon name="account_balance" class="cursor-pointer"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="col margin1"
              v-model="text"
              label="Conta Contábil"
            >
              <template v-slot:prepend>
                <q-icon
                  name="account_balance_wallet"
                  class="cursor-pointer"
                ></q-icon>
              </template>
            </q-input>
          </div>
          <div class="row margin1 borda-bloco shadow-2">
            <div class="margin1 titulo-bloco">{{ `Câmbio` }}</div>
            <q-input dense class="col margin1" v-model="text" label="Moeda">
              <template v-slot:prepend>
                <q-icon name="monetization_on" class="cursor-pointer"></q-icon>
              </template>
            </q-input>
            <q-input dense class="col margin1" v-model="text" label="Data">
              <template v-slot:prepend>
                <q-icon name="event" class="cursor-pointer"></q-icon>
              </template>
            </q-input>
            <q-input dense class="col margin1" v-model="text" label="Cotação">
              <template v-slot:prepend>
                <q-icon name="request_quote" class="cursor-pointer"></q-icon>
              </template>
            </q-input>
            <q-input dense class="col margin1" v-model="text" label="Tarifa">
              <template v-slot:prepend>
                <q-icon name="request_quote" class="cursor-pointer"></q-icon>
              </template>
            </q-input>
          </div>
        </div>
        GRID DE PAGAMENTO DO DOCUMENTO
      </q-tab-panel>

      <q-tab-panel name="cancelamento">
        <div class="row">
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Identificação"
          >
            <template v-slot:prepend>
              <q-icon name="badge" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Emissão">
            <template v-slot:prepend>
              <q-icon name="event" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input dense class="col margin1" v-model="text" label="Vencimento">
            <template v-slot:prepend>
              <q-icon name="event" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Valor Original"
          >
            <template v-slot:prepend>
              <q-icon name="attach_money" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
        <div class="row">
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Data de Cancelamento"
          >
            <template v-slot:prepend>
              <q-icon name="event" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Histórico do Cancelamento"
          >
            <template v-slot:prepend>
              <q-icon name="history" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
          <q-input
            dense
            class="col margin1"
            v-model="text"
            label="Saldo á Pagar"
          >
            <template v-slot:prepend>
              <q-icon name="attach_money" class="cursor-pointer"></q-icon>
            </template>
          </q-input>
        </div>
      </q-tab-panel>
    </q-tab-panels>
    <q-dialog v-model="load" maximized persistent>
      <carregando />
    </q-dialog>
  </div>
</template>

<script>
import {
  DxDataGrid,
  DxFilterRow,
  DxPager,
  DxPaging,
  DxExport,
  DxGroupPanel,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxStateStoring,
  DxSearchPanel,
} from "devextreme-vue/data-grid";

//import Incluir from "../http/incluir_registro";

export default {
  props: {
    cd_tipo_lancamento: { type: Number, default: 0 },
    ic_ativa_btn: { type: Boolean, default: true },
  },
  components: {
    carregando: () => import("../components/carregando.vue"),
    DxDataGrid,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxGrouping,
    DxColumnChooser,
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxStateStoring,
    DxSearchPanel,
  },
  data() {
    return {
      text: "",
      load: false,
      ic_tipo_documento: "",
      ic_favorecido: "",
      ic_tipo_consulta: "",
      dt_picker_retorno: "",
      dataSource: [],
      tab: "documento",
    };
  },
  methods: {
    // async onTabs() {
    //   var consulta_item = {
    //     cd_tipo_lancamento: 1,
    //     cd_parametro: 1,
    //   };
    //   this.dataSource = await Incluir.incluirRegistro(
    //     "810/1272",
    //     consulta_item
    //   ); //pr_egisnet_lancamento_financeiro
    //   console.log(this.dataSource, "RESULTADO DO ITEM");
    // },
    DataRetorno() {},
  },
};
</script>

<style scoped>
@import "./views.css";

* {
  background-color: #f2f2f2;
}

.margin1 {
  margin: 0.7vw 0.4vw;
  padding: 0;
}
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}
.titulo-bloco {
  flex-direction: column;
  font-weight: bold;
  font-size: larger;
  flex-wrap: wrap;
  justify-content: center;
  align-items: center;
  align-content: center;
}
</style>
