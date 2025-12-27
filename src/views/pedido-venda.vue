<template>
  <div>
    <div v-if="cd_pedido_venda == 0" class="text-h6 text-bold margin1">
      {{ tituloMenu }}
    </div>
    <div v-else class="text-h6 text-bold margin1">
      {{ tituloMenu }} {{ " - " + cd_pedido_venda }} - {{ hoje }}
    </div>

    <!--PROPOSTA--------------------------------------------------------------------------------->
    <div v-show="popup_proposta == true">
      <q-expansion-item
        icon="summarize"
        v-model="Expansion"
        label="Pedido de Venda"
        default-opened
        class="shadow-1 overflow-hidden margin1"
        style="border-radius: 20px; height: auto"
        header-class="bg-orange-9 text-white item-center text-h6"
        expand-icon-class="text-white"
      >
        <q-card-section class="scroll margin1">
          <q-select
            dense
            label="Cliente"
            class="row margin1"
            v-model="cliente"
            use-input
            :readonly="selecao_cliente"
            :options="lista_cliente"
            option-value="cd_cliente"
            option-label="nm_fantasia_cliente"
            :loading="loading"
            @virtual-scroll="onScroll"
            @filter="filterCliente"
            @input="PesquisaCliente"
          >
            <template v-slot:prepend>
              <q-icon name="contacts" />
            </template>
          </q-select>

          <div v-if="selecao == true">
            <!---DADOS DO CLIENTE--->
            <div class="shadow-1 margin1 borda-bloco">
              <div class="nome-campo margin1 text-subtitle2">Cliente</div>
              <div class="row">
                <q-field
                  dense
                  class="tres-tela media margin1"
                  label="Fantasia"
                  :stack-label="!!Fantasia"
                >
                  <template v-slot:prepend>
                    <q-icon name="business" />
                  </template>
                  <template v-slot:control>
                    <div class="self-center full-width no-outline">
                      {{ Fantasia }}
                    </div>
                  </template>
                </q-field>

                <q-field
                  dense
                  class="tres-tela media margin1"
                  label="Razão Social"
                  :stack-label="!!Razao_Social"
                >
                  <template v-slot:prepend>
                    <q-icon name="location_city" />
                  </template>
                  <template v-slot:control>
                    <div
                      class="self-center full-width no-outline"
                      style="white-space: normal"
                    >
                      {{ Razao_Social }}
                    </div>
                  </template>
                </q-field>

                <q-field
                  dense
                  class="tres-tela media margin1"
                  label="Telefone"
                  :stack-label="!!Telefone_Empresa"
                >
                  <template v-slot:prepend>
                    <q-icon name="call" />
                  </template>
                  <template v-slot:control>
                    <div class="self-center full-width no-outline">
                      {{ Telefone_Empresa }}
                    </div>
                  </template>
                </q-field>
              </div>

              <div class="row">
                <q-field
                  dense
                  class="tres-tela media margin1"
                  :label="CNPJouCPF"
                  :stack-label="!!CNPJ"
                >
                  <template v-slot:prepend>
                    <q-icon name="app_registration" />
                  </template>
                  <template v-slot:control>
                    <div class="self-center full-width no-outline">
                      {{ CNPJ }}
                    </div>
                  </template>
                </q-field>

                <q-field
                  dense
                  class="tres-tela media margin1"
                  label="Site"
                  :stack-label="!!nm_dominio_cliente"
                >
                  <template v-slot:prepend>
                    <q-icon name="language" />
                  </template>
                  <template v-slot:control>
                    <div class="self-center full-width no-outline">
                      {{ nm_dominio_cliente }}
                    </div>
                  </template>
                </q-field>

                <q-field
                  dense
                  class="tres-tela media margin1"
                  label="E-mail"
                  :stack-label="!!Email"
                >
                  <template v-slot:prepend>
                    <q-icon name="email" />
                  </template>
                  <template v-slot:control>
                    <div class="self-center full-width no-outline">
                      {{ Email }}
                    </div>
                  </template>
                </q-field>
              </div>

              <div class="row">
                <q-field
                  dense
                  class="tres-tela media margin1"
                  label="Tipo de Pessoa"
                  :stack-label="!!Tipo_Pessoa"
                >
                  <template v-slot:prepend>
                    <q-icon name="people" />
                  </template>
                  <template v-slot:control>
                    <div class="self-center full-width no-outline">
                      {{ Tipo_Pessoa }}
                    </div>
                  </template>
                </q-field>

                <q-field
                  dense
                  class="tres-tela media margin1"
                  label="Ramo de Atividade"
                  :stack-label="!!Ramo_Atividade"
                >
                  <template v-slot:prepend>
                    <q-icon name="badge" />
                  </template>
                  <template v-slot:control>
                    <div class="self-center full-width no-outline">
                      {{ Ramo_Atividade }}
                    </div>
                  </template>
                </q-field>

                <q-field
                  dense
                  class="tres-tela media margin1"
                  label="Status"
                  :stack-label="!!Status_Cliente"
                >
                  <template v-slot:prepend>
                    <q-icon name="info" />
                  </template>
                  <template v-slot:control>
                    <div class="self-center full-width no-outline">
                      {{ Status_Cliente }}
                    </div>
                  </template>
                </q-field>
              </div>
            </div>
            <!---DADOS DA PROPOSTA--->
            <div class="shadow-1 margin1 borda-bloco">
              <div
                class="nome-campo margin1 text-subtitle2"
                @click="toggleCondicoes()"
              >
                Condições
              </div>

              <div v-if="toggle_condicoes" class="row">
                <q-select
                  dense
                  class="duas-tela media margin1"
                  v-model="vendedor"
                  label="Vendedor"
                  :options="dataset_lookup_vendedor"
                  option-value="cd_vendedor"
                  option-label="nm_vendedor"
                  :stack-label="!!vendedor"
                  @input="SelecionaVendedor()"
                >
                  <template v-slot:prepend>
                    <q-icon name="person" />
                  </template>
                </q-select>

                <q-select
                  dense
                  class="duas-tela media margin1"
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
              </div>

              <div v-if="toggle_condicoes" class="row">
                <q-select
                  dense
                  class="duas-tela media margin1"
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
                  class="duas-tela media margin1"
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

              <div v-if="toggle_condicoes" class="row">
                <q-select
                  dense
                  class="duas-tela media margin1"
                  v-model="tipo_endereco"
                  label="Local de Entrega"
                  :options="dataset_lookup_tipo_endereco"
                  option-value="cd_tipo_local_entrega"
                  option-label="nm_tipo_local_entrega"
                >
                  <template v-slot:prepend>
                    <q-icon name="pin_drop" />
                  </template>
                </q-select>

                <q-select
                  dense
                  class="duas-tela media margin1"
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

              <div v-if="toggle_condicoes" class="row">
                <q-select
                  dense
                  class="duas-tela media margin1"
                  v-model="pagamento"
                  label="Condição de Pagamento"
                  :options="dataset_lookup_pagamento"
                  option-value="cd_condicao_pagamento"
                  option-label="nm_condicao_pagamento"
                  :stack-label="!!pagamento"
                >
                  <template v-slot:prepend>
                    <q-icon name="account_balance_wallet" />
                  </template>
                </q-select>

                <q-select
                  dense
                  class="duas-tela media margin1"
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

              <div v-if="toggle_condicoes" class="row">
                <q-input
                  dense
                  class="duas-tela media margin1"
                  v-model="cd_pedido_compra_consulta"
                  autogrow
                  type="text"
                  label="Pedido de Compra"
                  maxlength="40"
                >
                  <template v-slot:prepend>
                    <q-icon name="shopping_cart" />
                  </template>
                </q-input>

                <q-input
                  dense
                  class="duas-tela media margin1"
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
            </div>
          </div>
        </q-card-section>

        <q-expansion-item
          expand-separator
          default-opened
          icon="local_offer"
          class="shadow-1 overflow-hidden margin1"
          style="border-radius: 20px; height: auto"
          header-class="bg-orange-9 text-white item-center text-h6"
          expand-icon-class="text-white"
        >
          <template v-slot:header>
            <q-item-section avatar>
              <q-avatar icon="local_offer" text-color="white"></q-avatar>
            </q-item-section>

            <q-item-section>
              {{ `Itens do Pedido de Venda` }}
            </q-item-section>

            <q-item-section center>
              <div class="row items-center text-bold">
                {{ `Itens: ${carrinho.length} | Total: ${valorTotal}` }}
              </div>
            </q-item-section>
          </template>

          <div class="row margin1" style="justify-content: space-between">
            <q-btn
              color="orange-9"
              rounded
              icon="add"
              label="Novo"
              @click="AddNovoItem()"
            />
            <q-btn
              color="orange-9"
              rounded
              flat
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
            style="border-radius: 20px; height: auto"
            header-class="bg-orange-9 text-white item-center text-h6"
            expand-icon-class="text-white"
          >
            <div class="margin1 borda-bloco shadow-2">
              <div class="margin1 metadeTela" style="font-weight: bold">
                {{ "Produto" }}
                <q-toggle
                  v-model="pesquisa_produto_servico"
                  color="orange-9"
                />{{ "Serviço" }}
              </div>
              <q-separator class="margin1"></q-separator>
              <div v-if="!pesquisa_produto_servico">
                <div class="row">
                  <div class="margin1 col" style="font-weight: bold">
                    {{ "Simples" }}
                    <q-toggle
                      v-model="tipo_pesquisa_produto"
                      :false-value="'N'"
                      :true-value="'S'"
                      color="orange-9"
                    />{{ "Completa" }}
                  </div>
                </div>
                <div v-if="tipo_pesquisa_produto == 'S'" class="col">
                  <div class="row">
                    <q-select
                      dense
                      color="orange-9"
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
                      color="orange-9"
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
                      color="orange-9"
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
                      color="orange-9"
                      class="margin1 tres-tela media"
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
                      class="margin1 tres-tela media"
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
                      class="margin1 tres-tela media"
                      v-model="nm_produto"
                      label="Produto "
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
                </div>

                <q-input
                  dense
                  color="orange-9"
                  class="margin1 inputProduto"
                  v-if="tipo_pesquisa_produto == 'N'"
                  v-model="nm_produto"
                  autofocus
                  label="Produto"
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
                      :allow-updating="true"
                      :allow-adding="false"
                      :allow-deleting="false"
                      mode="batch"
                    />

                    <DxGroupPanel
                      :visible="true"
                      empty-panel-text="agrupar..."
                    />
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
              <div v-if="codigo == false">
                <p style="text-align: center">Nenhum produto encontrado!</p>
              </div>
            </div>
          </q-expansion-item>

          <!---CARRINHO DE PRODUTOS--->
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
                @focused-cell-changing="RegraCelula($event)"
                @focused-row-changed="onFocusedRowChangedCarrinho($event)"
              >
                <DxEditing
                  :allow-updating="true"
                  :allow-adding="false"
                  :allow-deleting="true"
                  :select-text-on-edit-start="true"
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
          </div>
        </q-expansion-item>

        <q-card-actions
          align="right"
          class="text-orange-9"
          style="justify-content: space-between"
        >
          <div style="align-items: start">
            <q-btn
              rounded
              color="orange-9"
              class="margin5"
              label="Imprimir"
              icon="print"
              @click="OnImpressao()"
            >
              <q-tooltip> Imprimir Pedido de Venda </q-tooltip>
            </q-btn>

            <q-btn
              rounded
              color="orange-9"
              label="Salvar"
              icon="done"
              @click="onSalvarItens"
            >
              <q-tooltip> Salvar Pedido de Venda </q-tooltip>
            </q-btn>
          </div>
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

    <!---FECHAR PROPOSTA----------------------------------->
    <q-dialog v-model="popup_fechar" persistent>
      <q-card>
        <q-card-section>
          <div class="text-h6">Aprovação</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <div>Deseja realmente fechar essa proposta?</div>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            flat
            rounded
            label="Confirmar"
            color="orange-9"
            @click="AprovaProposta()"
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

    <!---DECLINAR PROPOSTA----------------------------------->
    <!-- <q-dialog v-model="popup_declinar" persistent>
      <q-card>
        <q-select
          class="row margin1"
          v-model="concorrente"
          label="Concorrente"
          :options="dataset_lookup_concorrente"
          option-value="cd_concorrente"
          option-label="nm_concorrente"
        >
          <template v-slot:prepend>
            <q-icon name="group" />
          </template>
        </q-select>

        <q-select
          class="row margin1"
          v-model="motivo_perda"
          label="Motivo da Perda"
          :options="dataset_lookup_motivo_perda"
          option-value="cd_motivo_perda"
          option-label="nm_motivo_perda"
        >
          <template v-slot:prepend>
            <q-icon name="description" />
          </template>
        </q-select>

        <q-card-section class="q-pt-none">
          <q-input
            v-model="ds_declinio"
            filled
            type="textarea"
            label="Descritivo"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            flat
            label="Confirmar"
            color="primary"
            @click="DeclinaProposta()"
            v-close-popup
          ></q-btn>
          <q-btn flat label="Cancelar" color="negative" v-close-popup></q-btn>
        </q-card-actions>
      </q-card>
    </q-dialog> -->
    <!------------------------------------------------->
    <!--  -->
    <vue-html2pdf
      ref="html2Pdf"
      :show-layout="false"
      :enable-download="false"
      :preview-modal="true"
      :paginate-elements-by-height="3508"
      filename="Pedido de Venda"
      :pdf-quality="2"
      :manual-pagination="true"
      pdf-format="a4"
      pdf-orientation="landscape"
      pdf-content-width="95%"
      :html-to-pdf-options="{
        margin: 3,
      }"
    >
      <section slot="pdf-content">
        <!-- PDF Content Here -->
        <div id="relatorioHTML"></div>
      </section>
    </vue-html2pdf>
    <!--  -->
    <q-dialog v-model="ic_impressao">
      <q-card style="width: 300px; padding: 0">
        <div class="row items-center" style="margin: 0.7vw">
          <div class="text-bold text-subtitle2 col items-center">
            {{ `Pedido de Venda - ${cd_pedido_venda}` }}
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
        >
          <relatorio
            :cd_relatorioID="11"
            :cd_documentoID="this.cd_pedido_venda"
            :cd_item_documentoID="0"
            :nm_jsonID="{}"
          ></relatorio>
        </div>
      </q-card>
    </q-dialog>

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
          <div class="text-h7"><b>Essa</b> pesquisa pode demorar!</div>
          <br />
          <q-item-section side class="margin1">
            <q-btn
              round
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
            <q-btn
              round
              icon="cancel"
              color="negative"
              @click="popup_pesquisa_filtro = false"
            >
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
  </div>
</template>
<script>
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import Menu from "../http/menu";
import Lookup from "../http/lookup";
import funcao from "../http/funcoes-padroes";
import VueHtml2pdf from "vue-html2pdf";

import {
  DxDataGrid,
  DxEditing,
  DxGroupPanel,
  DxExport,
  DxPager,
  DxScrolling,
  DxPaging,
  DxSearchPanel,
} from "devextreme-vue/data-grid";

export default {
  props: {
    propPedido: { type: Object, default: () => {} },
  },

  components: {
    DxDataGrid,
    DxEditing,
    DxGroupPanel,
    DxExport,
    DxPager,
    DxScrolling,
    DxPaging,
    DxSearchPanel,
    carregando: () => import("../components/carregando.vue"),
    relatorio: () => import("../views/relatorio.vue"),
    ListagemPadrao: () => import("../views/listagem-padrao.vue"),
    VueHtml2pdf,
  },

  data() {
    return {
      tituloMenu: "",
      api: "753/1153", // Procedimento 1584 - pr_egisnet_elabora_pedido_venda
      nm_json: {}, // JSON Enviado para a API
      cd_usuario: localStorage.cd_usuario,
      hoje: "",
      colunas: [],
      colunas_carrinho: [],
      gridRefName: "grid",
      gridRefNameCarrinho: "grid_carrinho",
      Expansion: true,
      cliente_popup: false,
      popup_proposta: false,
      //popup_declinar: false,
      popup_fechar: false,
      ic_impressao: false,
      grid_card_carrinho: false,
      tipo_pesquisa_produto: "N",
      config_pesquisa: true,
      pesquisa_produto_servico: false,
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
      codigo: null,
      load: false,
      ds_declinio: "",
      Fantasia: "",
      cd_mascara_produto: "",
      nm_fantasia_produto: "",
      nm_produto: "",
      linha_selecionada: [],
      dataset_lookup_pagamento: [],
      pagamento: "",
      dataset_lookup_pedido: [],
      tipo_pedido: "",
      dataset_lookup_categoria: [],
      categoria: "",
      dataset_lookup_grupo: [],
      grupo: "",
      dataset_lookup_marca: [],
      marca: "",
      dados_lookup_cliente: [],
      dataset_lookup_cliente: [],
      cliente: "",
      dataset_lookup_vendedor: [],
      vendedor: "",
      dataset_lookup_transportadora: [],
      transportadora: "",
      dataset_lookup_destinacao: [],
      destinacao: "",
      dataset_lookup_tipo_endereco: [],
      tipo_endereco: "",
      dataset_lookup_tipo_frete: [],
      tipo_frete: "",
      dataset_lookup_frete_pagamento: [],
      frete_pagamento: "",
      dataset_lookup_concorrente: [],
      concorrente: "",
      dataset_lookup_motivo_perda: [],
      motivo_perda: "",
      cd_cliente: 0,
      resultado_contato: [],
      filter_cliente: "",
      popup_contato: false,
      selecao: false,
      Razao_Social: "",
      Telefone_Empresa: "",
      CNPJouCPF: "CNPJ",
      CNPJ: "",
      nm_dominio_cliente: "",
      Tipo_Pessoa: "",
      cd_tipo_pessoa: 0,
      Ramo_Atividade: "",
      Status_Cliente: "",
      envio_proposta: [],
      envio_consulta: [],
      obs: "",
      cd_pedido_compra_consulta: "",
      loading: false,
      nextPage: 2,
      selecao_contato: false,
      selecao_cliente: true,
      contato_selecionado: [],
      lista_cliente: [],
      resultado_pesquisa_cliente: {},
      Email: "",
      cd_pedido_venda: 0,
      pesquisa_produto: false,
      resultado_categoria: [],
      produtos: [],
      total: {},
      carrinho: [],
      popup_carrinho: false,
      popup_pesquisa_filtro: false,
      cd_empresa: localStorage.cd_empresa,
      quantidadeTotal: 0,
      valorTotal: 0,
      total_compra: "",
      toggle_condicoes: false,
    };
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    try {
      this.load = true;
      // let dados_lookup_concorrente = await Lookup.montarSelect(
      //   this.cd_empresa,
      //   108,
      // );
      // this.dataset_lookup_concorrente = JSON.parse(
      //   JSON.parse(JSON.stringify(dados_lookup_concorrente.dataset)),
      // );
      // let dados_lookup_motivo_perda = await Lookup.montarSelect(
      //   this.cd_empresa,
      //   462,
      // );
      // this.dataset_lookup_motivo_perda = JSON.parse(
      //   JSON.parse(JSON.stringify(dados_lookup_motivo_perda.dataset)),
      // );

      this.cd_usuario = localStorage.cd_usuario;
      //Menu
      let menu = await Menu.montarMenu(localStorage.cd_empresa, 7472, 753); // 1584 - pr_egisnet_elabora_pedido_venda
      this.colunas_carrinho = JSON.parse(
        JSON.parse(JSON.stringify(menu.coluna))
      );

      this.colunas_carrinho.map((e) => {
        e.encodeHtml = false;
        if (
          e.dataField == "vl_unitario_item_pedido" ||
          e.dataField == "qt_item_pedido_venda" ||
          e.dataField == "ds_produto" ||
          e.dataField == "qt_dia_entrega_pedido" ||
          e.dataField == "nm_unidade_medida"
        ) {
          e.allowEditing = true;
        } else {
          e.allowEditing = false;
        }
      });
      if (this.propPedido.cd_movimento > 0) {
        this.cd_pedido_venda = this.propPedido.cd_movimento;
        await this.carregaDados();
      } else {
        this.NovaProposta();
      }
      var PegaData = new Date();
      var dia = String(PegaData.getDate()).padStart(2, "0");
      var mes = String(PegaData.getMonth() + 1).padStart(2, "0");
      var ano = PegaData.getFullYear();
      this.hoje = `${dia}/${mes}/${ano}`;
      this.lista_cliente = this.dataset_lookup_cliente.slice(0, 40);
      this.load = false;
    } catch {
      this.load = false;
    }
  },

  async mounted() {
    this.tituloMenu == "" ? (this.tituloMenu = "Pedido de Venda") : "";
  },

  computed: {
    grid() {
      return this.$refs[this.gridRefName].instance;
    },
    grid_carrinho() {
      return this.$refs[this.gridRefNameCarrinho].instance;
    },
  },

  watch: {
    async Expansion() {
      if (this.Expansion == false) {
        this.Expansion = true;
      }
    },
  },

  methods: {
    async toggleCondicoes() {
      this.toggle_condicoes = !this.toggle_condicoes;
      if (this.toggle_condicoes) {
        //Pagamento
        if (this.dataset_lookup_pagamento.length == 0) {
          let dados_lookup_pagamento = await Lookup.montarSelect(
            this.cd_empresa,
            308
          );
          this.dataset_lookup_pagamento = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_pagamento.dataset))
          );
        }
        //Pedido
        if (this.dataset_lookup_pedido.length == 0) {
          let dados_lookup_pedido = await Lookup.montarSelect(
            this.cd_empresa,
            202
          );
          this.dataset_lookup_pedido = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_pedido.dataset))
          );
        }
        //Categoria
        if (this.dataset_lookup_categoria.length == 0) {
          let dados_lookup_categoria = await Lookup.montarSelect(
            this.cd_empresa,
            261
          );
          this.dataset_lookup_categoria = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_categoria.dataset))
          );
        }
        //Grupo
        if (this.dataset_lookup_grupo.length == 0) {
          let dados_lookup_grupo = await Lookup.montarSelect(
            this.cd_empresa,
            159
          );
          this.dataset_lookup_grupo = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_grupo.dataset))
          );
        }
        //Marca
        if (this.dataset_lookup_marca.length == 0) {
          let dados_lookup_marca = await Lookup.montarSelect(
            this.cd_empresa,
            2406
          );
          this.dataset_lookup_marca = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_marca.dataset))
          );
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
        }
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
        //Tipo Endereço
        if (this.dataset_lookup_tipo_endereco.length == 0) {
          let dados_lookup_tipo_endereco = await Lookup.montarSelect(
            this.cd_empresa,
            250
          );
          this.dataset_lookup_tipo_endereco = JSON.parse(
            JSON.parse(JSON.stringify(dados_lookup_tipo_endereco.dataset))
          );
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
      }
    },
    async AddNovoItem() {
      this.pesquisa_produto = !this.pesquisa_produto;
      if (this.pesquisa_produto && this.config_pesquisa) {
        let dados_lookup_config_proposta = await Lookup.montarSelect(
          this.cd_empresa,
          5442
        );
        let dataset_lookup_config_proposta = JSON.parse(
          JSON.parse(JSON.stringify(dados_lookup_config_proposta.dataset))
        );
        if (dataset_lookup_config_proposta != null) {
          this.tipo_pesquisa_produto =
            dataset_lookup_config_proposta[0].ic_pesquisa_produto;
        }
        this.config_pesquisa = false;
      }
    },
    onCancelaItens() {
      this.pesquisa_produto = false;
      this.pesquisa_produto_servico = false;
      this.nm_produto = "";
      this.resultado_categoria = [];
    },
    async carregaDados() {
      let c = {
        cd_parametro: 3,
        cd_usuario: localStorage.cd_usuario,
        cd_pedido_venda: this.cd_pedido_venda,
      };
      let pedido = await Incluir.incluirRegistro(this.api, c); //pr_egisnet_elabora_pedido_venda
      if (pedido[0].Cod == 0) {
        notify(pedido[0].Msg);
        return;
      }
      this.cd_cliente = pedido[0].cd_cliente;
      this.hoje = pedido[0].dt_pedido_venda;
      this.cliente = {
        nm_fantasia_cliente: pedido[0].nm_fantasia_cliente,
        cd_cliente: pedido[0].cd_cliente,
      };
      this.Fantasia = pedido[0].nm_fantasia_cliente;
      this.Razao_Social = pedido[0].nm_razao_social_cliente;
      this.Telefone_Empresa = pedido[0].cd_telefone;
      this.cd_tipo_pessoa = pedido[0].cd_tipo_pessoa;
      if (this.cd_tipo_pessoa == 1) {
        this.CNPJ = await funcao.FormataCNPJ(pedido[0].cd_cnpj_cliente);
        this.CNPJouCPF = "CNPJ";
      } else {
        this.CNPJ = await funcao.FormataCPF(pedido[0].cd_cnpj_cliente);
        this.CNPJouCPF = "CPF";
      }
      this.nm_dominio_cliente = pedido[0].nm_dominio_cliente;
      this.Email = pedido[0].nm_email_cliente;
      this.Tipo_Pessoa = pedido[0].nm_tipo_pessoa;
      this.Ramo_Atividade = pedido[0].nm_ramo_atividade;
      this.vendedor = {
        cd_vendedor: pedido[0].cd_vendedor,
        nm_vendedor: pedido[0].nm_vendedor,
      };
      this.Status_Cliente = pedido[0].nm_status_cliente;

      this.transportadora = {
        cd_transportadora: pedido[0].cd_transportadora,
        nm_transportadora: pedido[0].nm_transportadora,
      };
      this.destinacao = {
        cd_destinacao_produto: pedido[0].cd_destinacao_produto,
        nm_destinacao_produto: pedido[0].nm_destinacao_produto,
      };
      this.tipo_pedido = {
        nm_tipo_pedido: pedido[0].nm_tipo_pedido,
        cd_tipo_pedido: pedido[0].cd_tipo_pedido,
      };
      this.tipo_endereco = {
        cd_tipo_local_entrega: pedido[0].cd_tipo_local_entrega,
        nm_tipo_local_entrega: pedido[0].nm_tipo_local_entrega,
      };
      //this.tipo_endereco = pedido[0].nm_tipo_endereco;
      this.tipo_frete = {
        cd_tipo_frete: pedido[0].cd_tipo_frete,
        nm_tipo_frete: pedido[0].nm_tipo_frete,
      };
      this.pagamento = {
        cd_condicao_pagamento: pedido[0].cd_condicao_pagamento,
        nm_condicao_pagamento: pedido[0].nm_condicao_pagamento,
      };
      this.frete_pagamento = {
        cd_tipo_pagamento_frete: pedido[0].cd_tipo_pagamento_frete,
        nm_tipo_pagamento_frete: pedido[0].nm_tipo_pagamento_frete,
      };
      //CARRINHO DE COMPRAS
      this.carrinho = [];
      if (pedido[0].Cod_Produto != 0 && pedido[0].cd_item_pedido_venda != 0) {
        this.carrinho = pedido.slice();
      }
      this.cd_pedido_compra_consulta = pedido[0].cd_pdcompra_pedido_venda;
      this.obs = pedido[0].ds_observacao_pedido;
      this.selecao = true;
      this.popup_proposta = true;
      this.selecao_contato = true;
      await this.SomaItens();
    },

    async NovaProposta() {
      this.popup_proposta = true;
      this.selecao = true;
      this.selecao_cliente = false; //Desabilita o readyonly
      this.limpaTudo();
    },

    async OnImpressao() {
      try {
        this.load = true;
        let json_relatorio = {
          //cd_consulta: this.prop_form.cd_documento,
          cd_pedido_venda: this.cd_pedido_venda,
          cd_menu: 5428,
          cd_parametro: 14,
          cd_usuario: localStorage.cd_usuario,
        };
        let [relatorio] = await Incluir.incluirRegistro(
          "897/1377",
          json_relatorio
        ); //pr_modulo_processo_egismob_post -> pr_egismob_relatorio_pedido
        let documento = document.getElementById("relatorioHTML");
        documento.innerHTML = relatorio.RelatorioHTML;
        this.$refs.html2Pdf.generatePdf();
        notify("Relatório gerado com sucesso");
        this.load = false;
      } catch (error) {
        this.load = false;
        notify("Não foi possivel gerar o relatório");
      }
      //this.ic_impressao = true;
    },

    async SalvaESoma() {
      await this.grid_carrinho.saveEditData();
      await funcao.sleep(1);
      await this.SomaItens();
    },

    limpaTudo() {
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
      this.transportadora = "";
      this.destinacao = "";
      this.tipo_pedido = "";
      this.tipo_endereco = "";
      this.tipo_frete = "";
      this.pagamento = "";
      this.frete_pagamento = "";
      this.cd_pedido_compra_consulta = "";
      this.obs = "";
      this.quantidadeTotal = 0;
      this.valorTotal = 0;
      this.contato_selecionado = [];
      this.selecao_contato = false;
    },

    onScroll({ to, ref }) {
      if (this.filter_cliente === "") {
        const pageSize = 10;
        const lastPage = Math.ceil(
          this.dataset_lookup_cliente.length / pageSize
        );
        let lastIndex = this.lista_cliente.length - 1;
        this.lista_cliente = this.dataset_lookup_cliente.slice(
          0,
          pageSize * this.nextPage
        );
        if (
          this.loading !== true &&
          this.nextPage < lastPage &&
          to === lastIndex
        ) {
          this.loading = true;
          setTimeout(() => {
            this.nextPage++;
            ref.refresh();
            this.loading = false;
          }, 500);
        }
      }
    },

    filterCliente(val, update) {
      this.filter_cliente = val;
      setTimeout(() => {
        update(() => {
          if (val === "") {
            this.lista_cliente = this.lista_cliente;
          } else {
            const needle = val.toLowerCase();
            this.lista_cliente = this.dataset_lookup_cliente.filter(
              (v) => v.nm_fantasia_cliente.toLowerCase().indexOf(needle) > -1
            );
          }
        });
      }, 300);
    },

    onFocusedRowChanged: function (e) {
      this.linha_selecionada = e.row && e.row.data;
    },

    onFocusedRowChangedCarrinho: function (e) {
      this.linha_selecionada = e.row && e.row.data;
    },

    async RegraCelula(e) {
      await funcao.sleep(1);

      let index_Quantidade;
      let index_Valor;

      e.columns.map((item) => {
        if (item.dataField == "vl_unitario_item_pedido") {
          index_Valor = e.columns.indexOf(item);
        }
        if (item.dataField == "qt_item_pedido_venda") {
          index_Quantidade = e.columns.indexOf(item);
        }
      });
      if (
        e.rows[e.prevRowIndex].cells[e.prevColumnIndex].column.dataField ===
        "vl_unitario_item_pedido"
      ) {
        let valor_total_linha =
          e.rows[e.prevRowIndex].cells[e.prevColumnIndex].value.toFixed(2) *
          e.rows[e.prevRowIndex].cells[index_Quantidade].value.toFixed(2);
        await this.grid_carrinho.cellValue(
          e.prevRowIndex,
          "vl_total_item",
          valor_total_linha
        );
        await this.SalvaESoma();
      }
      if (
        e.rows[e.prevRowIndex].cells[e.prevColumnIndex].column.dataField ===
        "qt_item_pedido_venda"
      ) {
        let valor_total_linha =
          e.rows[e.prevRowIndex].cells[e.prevColumnIndex].value.toFixed(2) *
          e.rows[e.prevRowIndex].cells[index_Valor].value.toFixed(2);
        await this.grid_carrinho.cellValue(
          e.prevRowIndex,
          "vl_total_item",
          valor_total_linha
        );
        await this.SalvaESoma();
      }
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
      var j = {
        cd_parametro: 14,
        cd_vendedor: this.vendedor.cd_vendedor,
        vl_total_consulta: this.valorTotal,
        cd_cliente: this.cd_cliente,
        cd_destinacao_produto: this.destinacao.cd_destinacao_produto,
        cd_tipo_pedido: this.tipo_pedido.cd_tipo_pedido,
        cd_tipo_frete: this.tipo_frete.cd_tipo_frete,
        cd_tipo_pagamento_frete: this.frete_pagamento.cd_tipo_pagamento_frete,
        cd_transportadora: this.transportadora.cd_transportadora,
        cd_contato: this.contato_selecionado.cd_contato_selecionado,
        cd_usuario: this.cd_usuario,
        cd_condicao_pagamento: this.pagamento.cd_condicao_pagamento,
        cd_tipo_local_entrega: this.tipo_endereco.cd_tipo_local_entrega,
        carrinho: this.carrinho,
      };
      let aprova_proposta = await Incluir.incluirRegistro(this.api, j);
      notify(aprova_proposta[0].Msg);
      this.popup_fechar = false;
    },

    async DeclinaProposta() {
      var json_declina = {
        cd_parametro: 13,
        cd_usuario: this.cd_usuario,
        cd_consulta: this.cd_pedido_venda,
      };

      let resultado_declinio = await Incluir.incluirRegistro(
        this.api,
        json_declina
      );
      notify(resultado_declinio[0].Msg);
    },

    async ListaCarrinho(e) {
      if (e.cd_servico) {
        e.Valor = e.Valor.includes("R$") ? e.Valor.replace("R$", "") : e.Valor;
      } else {
        e.vl_produto = e.vl_produto.replace("R$", "");
        e.qt_item_pedido_venda = 1;
      }
      if (this.carrinho.length === 0) {
        this.carrinho.push(e);
      } else {
        e.cd_controle = parseFloat(
          this.carrinho[this.carrinho.length - 1].cd_controle + 1
        );
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
      this.quantidadeTotal = 0;
      this.valorTotal = 0;
      this.carrinho.map((item) => {
        this.quantidadeTotal = parseFloat(
          this.quantidadeTotal + parseFloat(item.qt_item_pedido_venda)
        );
        item.vl_total_pedido_venda = parseFloat(item.vl_total_pedido_venda);

        item.vl_total_item == undefined
          ? (item.vl_total_item = parseFloat(item.vl_lista_item))
          : "";
        item.vl_unitario_item_pedido = parseFloat(item.vl_unitario_item_pedido);
        if (item.vl_total_item == 0) {
          item.vl_total_item =
            parseFloat(item.vl_unitario_item_pedido) *
            parseFloat(item.qt_item_pedido_venda);
        }
        if (!item.vl_total_item) {
          this.valorTotal = parseFloat(
            this.valorTotal +
              parseFloat(item.vl_unitario_item_pedido) *
                parseFloat(item.qt_item_pedido_venda)
          );
        } else {
          this.valorTotal += item.vl_total_item;
        }
      });
      this.valorTotal = await funcao.FormataValor(this.valorTotal);
    },

    limpaPesquisa() {
      this.categoria = "";
      this.grupo = "";
      this.marca = "";
      this.cd_mascara_produto = "";
      this.nm_fantasia_produto = "";
      this.nm_produto = "";
    },

    ContatoSelecionado(e) {
      this.contato_selecionado = [];
      this.contato_selecionado.Fantasia_contato = e.nm_fantasia_contato;
      this.contato_selecionado.email_contato = e.cd_email_contato_cliente;
      this.contato_selecionado.telefone_contato =
        "(" + e.cd_ddd_contato_cliente + ")" + e.cd_telefone_contato;
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
      this.resultado_contato = await Incluir.incluirRegistro(
        this.api,
        json_pesquisa
      );
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
          cd_parametro: 4,
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
          cd_parametro: 5,
          cd_usuario: this.cd_usuario,
          nm_produto: this.nm_produto,
        };
      }
      this.resultado_categoria = await Incluir.incluirRegistro(
        this.api,
        this.nm_json
      );

      let menu_pesquisa = await Menu.montarMenu(
        localStorage.cd_empresa,
        7473,
        753
      );
      this.colunas = JSON.parse(
        JSON.parse(JSON.stringify(menu_pesquisa.coluna))
      );
      this.colunas.map((e) => {
        e.allowEditing = false;
      });
      this.codigo = true;
      if (this.resultado_categoria[0].Cod === 0) {
        this.codigo = false;
        notify("Nenhum produto encontrado!");
        return;
      }
    },

    async onSalvarItens() {
      if (this.cd_cliente == 0) {
        notify("Selecione um cliente!");
        return;
      }
      await this.SalvaESoma();
      await this.InsertUpdatePV();

      if (this.cd_pedido_venda == 0) {
        notify("Selecione a Pedido de Venda!");
        return;
      }

      if (this.carrinho.length == 0) {
        notify("O Pedido de Venda precisa de pelo menos 1 produto!");
        return;
      }

      if (this.valorTotal <= 0) {
        notify("O valor do pedido de venda está zerado!");
        return;
      }
      var item_carrinho_zerado = false;
      this.carrinho.forEach((e) => {
        if (
          e.vl_unitario_item_pedido == 0 ||
          e.vl_unitario_item_pedido == null
        ) {
          notify(`O produto ${e.nm_produto} está com valor zerado!`);
          return (item_carrinho_zerado = true);
        }
      });
      if (item_carrinho_zerado == true) {
        return;
      }
      var json_itens = {
        cd_parametro: 10,
        cd_pedido_venda: this.cd_pedido_venda,
        vl_total_pedido_venda: this.valorTotal
          .replace("R$", "")
          .replaceAll(".", "")
          .replace(",", ".")
          .trim(),
        carrinho: this.carrinho,
      };
      var inseriu_itens = await Incluir.incluirRegistro(this.api, json_itens);
      notify(inseriu_itens[0].Msg);
    },

    async InsertUpdatePV() {
      notify("Aguarde...");

      if (this.cd_pedido_venda > 0) {
        var json_altera = {
          cd_parametro: 8,
          cd_usuario: this.cd_usuario,
          cd_pedido_venda: this.cd_pedido_venda,
          cd_cliente: this.cd_cliente,
          cd_vendedor: this.vendedor.cd_vendedor,
          cd_tipo_frete: this.tipo_frete.cd_tipo_frete,
          cd_destinacao_produto: this.destinacao.cd_destinacao_produto,
          cd_tipo_pedido: this.tipo_pedido.cd_tipo_pedido,
          cd_transportadora: this.transportadora.cd_transportadora,
          cd_contato: this.contato_selecionado.cd_contato_selecionado,
          cd_condicao_pagamento: this.pagamento.cd_condicao_pagamento,
          cd_tipo_pagamento_frete: this.frete_pagamento.cd_tipo_pagamento_frete,
          cd_tipo_local_entrega: this.tipo_endereco.cd_tipo_local_entrega,
          cd_pdcompra_pedido_venda: this.cd_pedido_compra_consulta,
          ds_observacao_pedido: this.obs,
          vl_total_pedido_venda: parseFloat(this.valorTotal.replace("R$", "")),
        };
        let alteracao = await Incluir.incluirRegistro(this.api, json_altera);
        notify(alteracao[0].Msg);
      } else {
        var json_insert = {
          cd_parametro: 6,
          cd_usuario: this.cd_usuario,
          cd_cliente: this.cd_cliente,
          cd_vendedor: this.vendedor.cd_vendedor,
          cd_tipo_frete: this.tipo_frete.cd_tipo_frete,
          cd_destinacao_produto: this.destinacao.cd_destinacao_produto,
          cd_tipo_pedido: this.tipo_pedido.cd_tipo_pedido,
          cd_transportadora: this.transportadora.cd_transportadora,
          cd_contato: this.contato_selecionado.cd_contato_selecionado,
          cd_condicao_pagamento: this.pagamento.cd_condicao_pagamento,
          cd_tipo_pagamento_frete: this.frete_pagamento.cd_tipo_pagamento_frete,
          cd_tipo_local_entrega: this.tipo_endereco.cd_tipo_local_entrega,
          cd_pdcompra_pedido_venda: this.cd_pedido_compra_consulta,
          ds_observacao_pedido: this.obs,
          vl_total_pedido_venda: parseFloat(this.valorTotal.replace("R$", "")),
        };
        this.envio_consulta = await Incluir.incluirRegistro(
          this.api,
          json_insert
        );
        notify(this.envio_consulta[0].Msg);

        this.pesquisa_produto = true;

        this.cd_pedido_venda = this.envio_consulta[0].Cod;
      }
    },

    async PesquisaCliente() {
      let json_pesquisa_cliente = {
        cd_parametro: 1,
        cd_cliente: this.cliente.cd_cliente,
        cd_pedido_venda: this.cd_pedido_venda,
      };
      this.load = true;
      this.cliente_popup = false;
      this.resultado_pesquisa_cliente = await Incluir.incluirRegistro(
        this.api,
        json_pesquisa_cliente
      );
      this.load = false;
      if (this.resultado_pesquisa_cliente[0].Cod == 0) {
        notify(this.resultado_pesquisa_cliente[0].Msg);
        return;
      } else {
        let {
          cd_cliente,
          nm_fantasia_cliente,
          nm_razao_social_cliente,
          cd_cnpj_cliente,
          nm_tipo_pessoa,
          nm_dominio_cliente,
          nm_ramo_atividade,
          cd_telefone,
          nm_email_cliente,
          nm_status_cliente,
          cd_vendedor,
          Vendedor,
          cd_transportadora,
          Transportadora,
          cd_destinacao_produto,
          Destinacao_Produto,
          cd_tipo_pedido,
          Tipo_Pedido,
          cd_condicao_pagamento,
          Condicao_Pagamento,
          cd_tipo_pagamento_frete,
          Tipo_Pagamento_Frete,
        } = this.resultado_pesquisa_cliente[0];
        if (cd_cliente > 0) {
          //Cliente//
          nm_fantasia_cliente == null
            ? (this.Fantasia = "")
            : (this.Fantasia = nm_fantasia_cliente);
          nm_razao_social_cliente == null
            ? (this.Razao_Social = "")
            : (this.Razao_Social = nm_razao_social_cliente);
          cd_telefone == null
            ? (this.Telefone_Empresa = "")
            : (this.Telefone_Empresa = cd_telefone);
          cd_cnpj_cliente == null || cd_cnpj_cliente == ""
            ? (this.CNPJ = "")
            : (this.CNPJ =
                cd_cnpj_cliente.slice(0, 2) +
                "." +
                cd_cnpj_cliente.slice(2, 5) +
                "." +
                cd_cnpj_cliente.slice(5, 8) +
                "/" +
                cd_cnpj_cliente.slice(8, 12) +
                "-" +
                cd_cnpj_cliente.slice(12, 14));
          nm_dominio_cliente == null
            ? (this.nm_dominio_cliente = "")
            : (this.nm_dominio_cliente = nm_dominio_cliente);
          nm_email_cliente == null
            ? (this.Email = "")
            : (this.Email = nm_email_cliente);
          nm_tipo_pessoa == null
            ? (this.Tipo_Pessoa = "")
            : (this.Tipo_Pessoa = nm_tipo_pessoa);
          nm_ramo_atividade == null
            ? (this.Ramo_Atividade = "")
            : (this.Ramo_Atividade = nm_ramo_atividade);
          nm_status_cliente == null
            ? (this.Status_Cliente = "")
            : (this.Status_Cliente = nm_status_cliente);
        } else {
          //Proposta//
          this.vendedor = {
            cd_vendedor: cd_vendedor,
            nm_vendedor: Vendedor,
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

          //Pagamento//

          this.pagamento = {
            cd_condicao_pagamento: cd_condicao_pagamento,
            nm_condicao_pagamento: Condicao_Pagamento,
          };
          this.frete_pagamento = {
            cd_tipo_pagamento_frete: cd_tipo_pagamento_frete,
            nm_tipo_pagamento_frete: Tipo_Pagamento_Frete,
          };
        }
        this.cd_cliente = this.resultado_pesquisa_cliente[0].cd_cliente;
        await this.onPesquisaContato();
        this.selecao_contato = false;
        this.contato_selecionado = [];
        this.selecao = true;
      }
    },
  },
};
</script>

<style scoped>
.smargin {
  margin: 5px;
  margin-left: 10px;
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
  height: 300px;
}

#scrollview {
  max-width: 98vw;
}

.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}

.margin1 {
  margin: 0.7vw 0.4vw;
  padding: 0;
}
.margin5 {
  margin: 5px;
}

.um-quinto {
  width: 14.5vw;
}

.tres-tela {
  width: 31%;
}
.duas-tela {
  width: 47%;
}
.carrinho {
  width: 20vw;
  height: 250px;
  display: inline-block;
}
.nome-campo {
  width: 100%;
  cursor: pointer;
}

.grid-padrao {
  width: 91.5vw !important;
}

@media (max-width: 950px) {
  .carrinho {
    width: 40vw;
    height: 250px;
    display: inline-block;
  }
  .card {
    width: 40vw;
  }
}
@media (max-width: 640px) {
  .carrinho {
    width: 90vw;
    height: 250px;
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
