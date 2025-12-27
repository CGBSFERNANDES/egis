<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center">
      <transition name="slide-fade">
        <h2
          class="content-block col-8"
          v-show="!!tituloMenu != false && ic_mostra_titulo"
        >
          {{ tituloMenu }}
          <q-badge
            v-if="qt_registro > 0"
            align="middle"
            rounded
            color="red"
            :label="qt_registro"
          />
        </h2>
      </transition>
    </div>
    <q-tabs
      v-model="index"
      inline-label
      mobile-arrows
      align="justify"
      style="border-radius: 20px"
      :class="'bg-' + colorID + ' text-white shadow-2 margin1'"
    >
      <q-tab :name="0" icon="description" label="Dados" />
      <q-tab :name="1" icon="checklist" label="Orçamento" />
    </q-tabs>
    <transition name="slide-fade">
      <div v-if="index == 0">
        <DxDataGrid
          class="margin1"
          key-expr="cd_controle"
          :data-source="dataOrcamento"
          :columns="colunas_orcamento"
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
          @focused-row-changed="orcamentoSelect($event)"
          @row-dbl-click="index = 1"
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
    <transition name="slide-fade">
      <div v-if="index == 1">
        <div class="row">
          <q-btn
            :color="colorID"
            icon="add"
            label="Novo"
            rounded
            size="md"
            class="margin1"
            @click="limpaTudo()"
          />
          <transition name="slide-fade">
            <div v-if="cd_orcamento > 0" class="margin1 col-2 tituloOrcamento">
              <div class="borda-bloco shadow-2 bg-primary">
                {{ `Orçamento - ${cd_orcamento}` }}
              </div>
            </div>
          </transition>
        </div>
        <!-- Veículo -->
        <div class="margin1">
          <veiculos
            :cd_usuario="cd_usuario"
            :cd_cliente_props="parseInt(cd_cliente)"
            :cd_veiculo_props="veiculo.cd_veiculo"
            @DbClick="SelecionaVeiculo($event)"
            :ic_pesquisa="ic_pesquisa"
            @update:ic_pesquisa="ic_pesquisa = $event"
          />
        </div>
        <!-- Veículo -->
        <!-- Cliente -->
        <div class="margin1">
          <cliente
            :cd_usuario="cd_usuario"
            :cd_cliente_props="veiculo.cd_cliente"
            @SelectCliente="SelecionaCliente($event)"
            :ic_pesquisa="true"
          />
        </div>
        <!-- Cliente -->
        <div class="row">
          <q-select
            v-if="1 == 2"
            rounded
            outlined
            bottom-slots
            class="margin1 col-2 opcoes"
            v-model="forma_pagamento"
            :options="lookup_forma_pagamento"
            option-value="cd_forma_pagamento"
            option-label="nm_forma_pagamento"
            label="Pagamento"
            @input="CalculaDesconto()"
          >
            <template v-slot:prepend>
              <q-icon name="attach_money"></q-icon>
            </template>
            <template v-slot:hint>
              <transition name="slide-fade">
                <div
                  style="font-weight: bold"
                  v-if="forma_pagamento.pc_desconto_pedido > 0"
                >
                  {{ `${forma_pagamento.pc_desconto_pedido}% de Desconto` }}
                </div>
              </transition>
            </template>
          </q-select>

          <q-input
            v-if="1 == 2"
            class="margin1 col-2 opcoes"
            rounded
            outlined
            stack-label
            type="date"
            v-model="dt_entrega"
            label="Data de Entrega"
          >
            <template v-slot:prepend>
              <q-icon name="event"></q-icon>
            </template>
          </q-input>
          <q-input
            v-if="1 == 2"
            class="margin1 col-2 opcoes"
            rounded
            outlined
            stack-label
            type="time"
            v-model="hr_entrega"
            label="Horário"
          >
            <template v-slot:prepend>
              <q-icon name="event"></q-icon>
            </template>
          </q-input>
          <q-input
            class="margin1 col-2 opcoes"
            rounded
            outlined
            v-model="ds_descricao"
            label="Observação"
          >
            <template v-slot:prepend>
              <q-icon name="folder"></q-icon>
            </template>
          </q-input>
          <div class="margin1">
            <q-btn-dropdown
              rounded
              color="primary"
              :label="`Total ${this.vl_total_produto_formatado}`"
            >
              <q-list class="text-weight-bold">
                <q-item clickable v-close-popup>
                  <q-item-section>
                    <q-item-label>{{ `Produtos` }}</q-item-label>
                  </q-item-section>
                  <q-item-section side>
                    <q-item-label>{{
                      `${this.dataSourceConfig.length}`
                    }}</q-item-label>
                  </q-item-section>
                </q-item>

                <q-item clickable v-close-popup>
                  <q-item-section>
                    <q-item-label>{{ `Total` }}</q-item-label>
                  </q-item-section>
                  <q-item-section side>
                    <q-item-label>{{
                      `${this.vl_total_produto_formatado}`
                    }}</q-item-label>
                  </q-item-section>
                </q-item>

                <q-item
                  v-if="vl_desconto_pedido"
                  style="color: red"
                  clickable
                  v-close-popup
                >
                  <q-item-section>
                    <q-item-label>{{ `Desconto` }}</q-item-label>
                  </q-item-section>
                  <q-item-section side>
                    <q-item-label>{{
                      `${this.vl_desconto_pedido}`
                    }}</q-item-label>
                  </q-item-section>
                </q-item>

                <q-item
                  v-if="valor_liquido"
                  style="color: red"
                  clickable
                  v-close-popup
                >
                  <q-item-section>
                    <q-item-label>{{ `Líquido` }}</q-item-label>
                  </q-item-section>
                  <q-item-section side>
                    <q-item-label>{{ `${this.valor_liquido}` }}</q-item-label>
                  </q-item-section>
                </q-item>
              </q-list>
            </q-btn-dropdown>
          </div>

          <div style="display: block">
            <q-btn
              v-if="1 == 2"
              round
              class="margin1"
              text-color="white"
              color="primary"
              icon="shopping_bag"
              @click="onCesta()"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                Cesta de Pedido
              </q-tooltip>
            </q-btn>
            <q-btn
              v-if="cd_orcamento > 0"
              round
              class="margin1"
              color="red"
              text-color="white"
              icon="delete"
              @click="pop_excluir = true"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                Excluir
              </q-tooltip>
            </q-btn>
            <q-btn
              round
              class="margin1"
              color="orange-9"
              text-color="white"
              icon="print"
              :loading="loadingPDF"
              @click="onPDF()"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                Gerar PDF
              </q-tooltip>
            </q-btn>
            <q-btn
              round
              class="margin1"
              color="green"
              text-color="white"
              icon="description"
              @click="onEnviarOrcamento()"
            >
              <q-tooltip
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                Enviar Orçamento
              </q-tooltip>
            </q-btn>
          </div>
        </div>
        <div class="shadow-2 margin1 borda-bloco">
          <div class="row">
            <div class="margin1" style="font-weight: bold">
              {{ "Produto" }}
              <q-toggle
                v-model="ic_produto_servico"
                :false-value="'N'"
                :true-value="'S'"
                color="primary"
              />{{ "Serviço" }}
            </div>
            <div class="margin1">
              <listaProduto
                :ic_parametro_obrigatorio="cd_cliente == 0 ? false : true"
                nm_parametro_obrigatorio="Cliente"
                @listaSelecionada="onListaSelecionada($event)"
              ></listaProduto>
            </div>
          </div>
          <div class="margin1 text-black">
            <transition name="slide-fade">
              <div v-if="ic_produto_servico === 'N'" class="col">
                <div class="row">
                  <!-- <q-select
                    v-show="!!dataset_lookup_categoria"
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
                  </q-select> -->

                  <!-- <q-select
                    v-show="!!dataset_lookup_grupo"
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
                  </q-select> -->

                  <!-- <q-select
                    v-show="!!dataset_lookup_marca"
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
                  </q-select> -->
                </div>

                <div class="row margin1">
                  <q-input
                    dense
                    color="primary"
                    class="margin1 tres-tela media"
                    v-model="cd_mascara_produto"
                    label="Máscara"
                    debounce="1500"
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
                    debounce="1500"
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
                    debounce="1500"
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

            <div v-if="ic_produto_servico === 'S'">
              <div class="row">
                <q-select
                  bottom-slots
                  class="margin1 col"
                  v-model="tipo_servico"
                  :options="lookup_tipo_servico"
                  option-value="cd_tipo_servico"
                  option-label="nm_tipo_servico"
                  label="Tipo de serviço"
                >
                  <template v-slot:prepend>
                    <q-icon name="attach_money"></q-icon>
                  </template>
                  <template v-slot:hint>
                    <transition name="slide-fade">
                      <div
                        style="font-weight: bold"
                        v-if="forma_pagamento.pc_desconto_pedido > 0"
                      >
                        {{
                          `${forma_pagamento.pc_desconto_pedido}% de Desconto`
                        }}
                      </div>
                    </transition>
                  </template>
                </q-select>
                <q-input
                  color="primary"
                  class="margin1 col"
                  v-model="nm_servico"
                  autofocus
                  label="Serviço"
                  debounce="1500"
                  @input="InputProduto(2)"
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
          </div>
          <Transition name="slide-fade">
            <div v-if="resultado_item.length > 0">
              <DxDataGrid
                class="margin1"
                id="grid"
                ref="grid"
                key-expr="cd_controle"
                :data-source="resultado_item"
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
          </Transition>
        </div>
        <!-- Grid -->
        <div v-if="loadingDataSourceConfig == true" class="row">
          <q-spinner-facebook class="col margin1" color="orange-9" size="6em" />
          <q-tooltip :offset="[0, 8]">Carregando...</q-tooltip>
        </div>
        <div v-else>
          <transition name="slide-fade">
            <dx-data-grid
              v-if="!ic_grid_cesta"
              id="gridPadrao"
              ref="gridPadrao"
              class="margin1 dx-card wide-card-gc"
              :data-source="dataSourceConfig"
              :columns="columns"
              :summary="total"
              key-expr="cd_controle"
              :selection="{ mode: 'single' }"
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
              noDataText="Sem dados"
              @exporting="onExporting"
              @focused-cell-Changing="attQtd($event)"
              @init-new-row="onNovaLinha($event)"
            >
              <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

              <DxEditing
                :allow-updating="true"
                :allow-adding="true"
                :allow-deleting="true"
                :select-text-on-edit-start="true"
                mode="batch"
              />

              <DxMasterDetail
                v-if="masterDetail == true"
                :enabled="true"
                template="masterDetailTemplate"
              />

              <template #masterDetailTemplate="{ data: dataSourceConfig }">
                {{ dataSourceConfig.data }}
              </template>

              <DxGrouping :auto-expand-all="true" v-if="filterGrid == true" />
              <DxExport :enabled="true" v-if="filterGrid == true" />

              <DxPaging :enable="true" :page-size="10" />

              <DxStateStoring
                :enabled="true"
                type="localStorage"
                storage-key="storage"
              />
              <DxSelection mode="multiple" v-if="multipleSelection == true" />
              <DxSelection mode="single" v-else />
              <DxPager
                :show-page-size-selector="true"
                :allowed-page-sizes="pageSizes"
                :show-info="true"
              />
              <DxFilterRow :visible="false" v-if="filterGrid == true" />
              <DxHeaderFilter
                :visible="true"
                :allow-search="true"
                :width="400"
                v-if="filterGrid == true"
                :height="400"
              />
              <DxSearchPanel
                :visible="true"
                :width="300"
                placeholder="Procurar..."
                v-if="filterGrid == true"
              />
              <DxFilterPanel :visible="true" v-if="filterGrid == true" />
              <DxColumnFixing :enabled="false" v-if="filterGrid == true" />
              <DxColumnChooser
                :enabled="true"
                mode="select"
                v-if="filterGrid == true"
              />
            </dx-data-grid>
          </transition>
        </div>
        <!-- PDF para Imprimir -->
        <transition name="slide-fade">
          <div id="cesta" class="margin1 borda-bloco" v-show="ic_grid_cesta">
            <div v-if="complemento_impressao">
              <h2 class="content-block" style="display: block">
                <div class="row margin1" style="display: flex">
                  <div style="font-weight: bolder; font-size: 36px">
                    {{ `MEDICAM` }}
                  </div>
                  <input class="checkboxPDF" type="checkbox" />
                  <div style="font-weight: bolder; font-size: 36px">
                    {{ `ALPHASET` }}
                  </div>
                  <input class="checkboxPDF" type="checkbox" />
                </div>
                <div
                  class="row borda-bloco"
                  style="
                    font-weight: bold;
                    font-size: 14px;
                    display: flex;
                    flex-wrap: wrap;
                    padding: 0px;
                    margin: 0px;
                  "
                >
                  <div class="borda-bloco col-8 borda-zero">
                    <div class="cor-relatorio">{{ `CLIENTE` }}</div>
                    <div style="margin: 5px; height: 1px; padding: 0px">
                      {{ `${this.cliente.Fantasia || ""}` }}
                    </div>
                  </div>
                  <div class="borda-bloco col-2 borda-zero">
                    <div class="cor-relatorio">{{ `Nº ORÇAMENTO` }}</div>
                    <div style="padding: 0px; margin: 3px; height: 4vh">
                      {{ `${cd_orcamento}` }}
                    </div>
                  </div>
                  <div class="borda-bloco col-2 borda-zero">
                    <div class="cor-relatorio">{{ `DATA` }}</div>
                    <div style="padding: 0px; margin: 3px; height: 4vh">
                      {{ `${this.dt_entrega || ""}` }}
                    </div>
                  </div>
                  <div class="borda-bloco col-2 borda-zero">
                    <div class="cor-relatorio">{{ `VEÍCULO` }}</div>
                    <div style="padding: 0px; margin: 3px; height: 4vh">
                      {{ `${this.veiculo.nm_veiculo || ""}` }}
                    </div>
                  </div>
                  <div class="borda-bloco col-8 borda-zero">
                    <div class="cor-relatorio">{{ `MOTOR` }}</div>
                    <div style="padding: 0px; margin: 3px; height: 4vh">
                      {{ `${this.veiculo.nm_motor || ""}` }}
                    </div>
                  </div>
                  <div class="borda-bloco col-2 borda-zero">
                    <div class="cor-relatorio">{{ `HORA` }}</div>
                    <div style="padding: 0px; margin: 3px; height: 4vh">
                      {{ `${this.hr_entrega || ""}` }}
                    </div>
                  </div>
                  <div class="borda-bloco col-2 borda-zero">
                    <div class="cor-relatorio">{{ `MECÂNICO` }}</div>
                    <div style="padding: 0px; margin: 3px; height: 4vh">
                      {{ `${this.veiculo.nm_mecanico || ""}` }}
                    </div>
                  </div>
                  <div class="borda-bloco col-2 borda-zero">
                    <div class="cor-relatorio">{{ `PLACA` }}</div>
                    <div style="padding: 0px; margin: 3px; height: 4vh">
                      {{ `${this.veiculo.cd_placa_veiculo || ""}` }}
                    </div>
                  </div>
                  <div class="borda-bloco col-2 borda-zero">
                    <div class="cor-relatorio">{{ `ANO` }}</div>
                    <div style="padding: 0px; margin: 3px; height: 4vh">
                      {{ `${this.veiculo.aa_veiculo || ""}` }}
                    </div>
                  </div>
                  <div class="borda-bloco col-2 borda-zero">
                    <div class="cor-relatorio">{{ `KM` }}</div>
                    <div style="padding: 0px; margin: 3px; height: 4vh">
                      {{ `${this.veiculo.qt_km_atual_veiculo || ""}` }}
                    </div>
                  </div>
                  <div class="borda-bloco col-2 borda-zero">
                    <div class="cor-relatorio">{{ `PREFIXO` }}</div>
                    <div style="padding: 0px; margin: 3px; height: 4vh">
                      {{ `${this.veiculo.nm_prefixo_veiculo || ""}` }}
                    </div>
                  </div>
                  <br />
                </div>
              </h2>
            </div>
            <div class="card-cesta row borda-bloco margin1">
              <DxDataGrid
                class="margin1"
                ref="gridPDF"
                key-expr="cd_controle"
                :data-source="dataSourceConfig"
                :columns="colunas_pdf"
                :show-borders="false"
                :selection="{ mode: 'single' }"
                :focused-row-enabled="false"
                :column-hiding-enabled="false"
                :remote-operations="false"
                :word-wrap-enabled="false"
                :allow-column-reordering="false"
                :allow-column-resizing="true"
                :row-alternation-enabled="false"
                :repaint-changes-only="false"
                :autoNavigateToFocusedRow="true"
                :focused-row-index="0"
                :cacheEnable="false"
                noDataText="Sem dados"
              >
                <DxGroupPanel :visible="false" empty-panel-text="agrupar..." />
                <DxExport :enabled="false" />
                <DxPager :show-page-size-selector="false" />
                <DxPaging :enable="false" :page-size="50" />
                <DxSearchPanel :visible="false" />
              </DxDataGrid>
            </div>
          </div>
        </transition>
      </div>
    </transition>
    <q-dialog v-model="loadingPDF" maximized persistent>
      <q-card class="bg-white">
        <carregando corID="orange-9" mensagemID="Aguarde..."></carregando>
      </q-card>
    </q-dialog>
    <q-dialog v-model="pop_excluir" persistent>
      <q-card>
        <q-card-section class="row items-center">
          <q-avatar icon="warning" color="yellow" text-color="black" />
          <span class="q-ml-sm text-bold">{{
            `Deseja realmente excluir o Orçamento ${cd_orcamento} ?`
          }}</span>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn
            rounded
            icon="check"
            label="Confirmar"
            color="primary"
            v-close-popup
            @click="onExcluir()"
          />
          <q-btn
            rounded
            icon="close"
            label="Cancelar"
            color="red"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
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
  DxEditing,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxSelection,
  DxStateStoring,
  DxMasterDetail,
  DxSearchPanel,
} from "devextreme-vue/data-grid";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import funcao from "../http/funcoes-padroes";
import Incluir from "../http/incluir_registro";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import Lookup from "../http/lookup";
import formataData from "../http/formataData";
import notify from "devextreme/ui/notify";
import carregando from "../components/carregando.vue";
import html2pdf from "html2pdf.js";
var dados = [];
var dados_orcamento = [];
let filename = "DataGrid.xlsx";
var sParametroApi = "";

export default {
  name: "digitacaoOrcamento",
  props: {
    ic_mostra_titulo: { type: Boolean, default: true },
    colorID: { type: String, default: "primary" },
  },
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_cliente: localStorage.cd_cliente,
      cd_modulo: localStorage.cd_modulo,
      cd_menu: localStorage.cd_menu,
      cd_api: localStorage.cd_api,
      cd_orcamento: 0,
      api: "",
      api_crud: "912/1413", //pr_egisnet_gera_orcamento_ordem_servico
      index: 1,
      tipo_pesquisa_produto: "N",
      ic_produto_servico: "N",
      linha_selecionada: [],
      pop_excluir: false,
      ic_pesquisa: true,
      veiculo: {},
      cliente: {},
      //Somas
      valor: 0,
      vl_total_produto: 0,
      vl_total_produto_formatado: 0,
      valor_liquido: 0,
      qtd: 0,
      vl_desconto_pedido: 0,
      //////////////////////
      loadingPDF: false,
      loadingDataSourceConfig: false,
      masterDetail: false,
      filterGrid: true,
      multipleSelection: false,
      ic_grid_cesta: false,
      complemento_impressao: false,
      pageSizes: [10, 20, 50, 100],
      dataOrcamento: [],
      dataSourceConfig: [],
      resultado_item: [],
      orcamentoSelecionado: {},
      qt_registro: "",
      columns: [],
      colunas_orcamento: [],
      colunas_pdf: [],
      total: {},
      tituloMenu: "",
      forma_pagamento: "",
      lookup_forma_pagamento: [],
      tipo_servico: "",
      lookup_tipo_servico: [],
      condicao_pagamento: "",
      lookup_forma_condicao_pagamento: [],
      transportadora: "",
      lookup_forma_transportadora: [],
      dataset_lookup_categoria: [],
      categoria: "",
      dataset_lookup_grupo: [],
      grupo: "",
      dataset_lookup_marca: [],
      marca: "",
      cd_mascara_produto: "",
      nm_fantasia_produto: "",
      nm_produto: "",
      nm_servico: "",
      dt_entrega: "",
      hr_entrega: "",
      ds_descricao: "",
    };
  },

  components: {
    DxDataGrid,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxEditing,
    DxGrouping,
    DxColumnChooser,
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxSelection,
    DxStateStoring,
    DxMasterDetail,
    DxSearchPanel,
    carregando,
    cliente: () => import("../views/cliente.vue"),
    veiculos: () => import("../views/veiculos.vue"),
    listaProduto: () => import("../views/lista-produto.vue"),
  },

  async created() {
    // let lookup_forma_pagamento = await Lookup.montarSelect(
    //   this.cd_empresa,
    //   2774,
    // );
    // this.lookup_forma_pagamento = JSON.parse(
    //   JSON.parse(JSON.stringify(lookup_forma_pagamento.dataset)),
    // );
    // this.lookup_forma_pagamento = this.lookup_forma_pagamento.filter((e) => {
    //   return e.ic_selecao_pedido === "S";
    // });
    ////////////////////////
    // let lookup_categoria = await Lookup.montarSelect(
    //   this.cd_empresa,
    //   261
    // );
    // this.dataset_lookup_categoria = JSON.parse(
    //   JSON.parse(JSON.stringify(lookup_categoria.dataset))
    // );
    ////////////////////////////
    // let lookup_grupo = await Lookup.montarSelect(
    //   this.cd_empresa,
    //   159
    // );
    // this.dataset_lookup_grupo = JSON.parse(
    //   JSON.parse(JSON.stringify(lookup_grupo.dataset))
    // );
    ////////////////////////////
    // let lookup_marca = await Lookup.montarSelect(
    //   this.cd_empresa,
    //   2406
    // );
    // this.dataset_lookup_marca = JSON.parse(
    //   JSON.parse(JSON.stringify(lookup_marca.dataset))
    // );
    ////////////////////////////
    let lookup_tipo_servico_let = await Lookup.montarSelect(
      this.cd_empresa,
      1103
    );
    this.lookup_tipo_servico = JSON.parse(
      JSON.parse(JSON.stringify(lookup_tipo_servico_let.dataset))
    );

    ////////////////////////////
    this.dt_entrega = formataData.AnoMesDia(new Date());
    await this.carregaDados();
  },

  computed: {
    gridPadrao() {
      return this.$refs["gridPadrao"].instance;
    },
    gridPDF() {
      return this.$refs["gridPDF"].instance;
    },
  },

  watch: {
    ic_produto_servico() {
      this.resultado_item = [];
      this.nm_produto = "";
      this.nm_servico = "";
    },
    index(novo, antigo) {
      if (novo === 1 && antigo === 0) {
        this.consultaOrcamento();
      }
    },
  },

  methods: {
    async carregaDados(showNotify) {
      localStorage.cd_identificacao = 0;
      await this.showMenu();
      if (!showNotify) {
        notify(`Aguarde... estamos montando a consulta para você!`);
      }
      let sApis = sParametroApi;
      if (!sApis == "") {
        try {
          this.loadingDataSourceConfig = true;
          this.dataSourceConfig = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            this.api,
            sApis
          );
          this.loadingDataSourceConfig = false;
        } catch (error) {
          this.loadingDataSourceConfig = false;
          console.error(error);
        }
      }
      await this.gridOrcamento();
    },
    async showMenu() {
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      localStorage.cd_parametro = 0;

      dados_orcamento = await Menu.montarMenu(
        this.cd_empresa,
        "7796", //this.cd_menu,
        this.cd_api
      );
      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api);
      sParametroApi = dados.nm_api_parametro;

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      //this.menu = dados.nm_menu;
      filename = this.tituloMenu + ".xlsx";
      //dados da coluna
      this.colunas_orcamento = JSON.parse(
        JSON.parse(JSON.stringify(dados_orcamento.coluna))
      );
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      this.columns.map((e) => {
        e.encodeHtml = false;
        if (
          e.dataField == "qt_digitacao" ||
          e.dataField == "ds_produto_orcamento" ||
          e.dataField == "VL_PRODUTO" ||
          e.dataField == "FANTASIA" ||
          e.dataField == "CODIGO" ||
          e.dataField == "Produto"
        ) {
          e.allowEditing = true;
        } else {
          e.allowEditing = false;
        }
      });
      this.colunas_pdf = JSON.parse(JSON.stringify(this.columns));
      this.colunas_pdf.map((p) => {
        p.alignment = "left";
        let desabilita = [
          "vl_total_item",
          "VL_PRODUTO",
          "CODIGO",
          "Produto",
          "FANTASIA",
          "ds_produto_orcamento",
          "cd_controle",
        ];
        if (desabilita.find((e) => e === p.dataField)) {
          p.visible = false;
        }
        if (p.dataField == "ds_impressao") {
          p.caption = "Descrição";
          p.visible = true;
        }
      });
      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //
    },

    async gridOrcamento() {
      var json_consulta_orcamento = {
        cd_parametro: 1,
      };
      this.dataOrcamento = await Incluir.incluirRegistro(
        this.api_crud,
        json_consulta_orcamento
      ); //pr_egisnet_gera_orcamento_ordem_servico
      this.qt_registro = this.dataOrcamento.length;
    },
    onListaSelecionada(e) {
      if (this.dataSourceConfig.length === 0) {
        this.dataSourceConfig = e;
      } else {
        let array_controle = e.map((i) => {
          i.cd_controle = i.cd_controle + this.dataSourceConfig.length;
          i.vl_total_item = i.qt_digitacao * i.VL_PRODUTO;
          return i;
        });
        this.dataSourceConfig = this.dataSourceConfig.concat(array_controle);
      }
      if (!this.cd_orcamento) {
        this.cd_orcamento =
          this.dataSourceConfig.find((o) => o.cd_orcamento > 0) || 0;
        this.cd_orcamento = this.cd_orcamento.cd_orcamento;
      }
      this.SomaTotalItems();
    },
    orcamentoSelect(e) {
      this.orcamentoSelecionado = e.row.data;
      this.cd_orcamento = this.orcamentoSelecionado.cd_orcamento;
    },
    async consultaOrcamento() {
      var json_consulta_orcamento = {
        cd_parametro: 4,
        cd_orcamento: this.cd_orcamento,
      };
      this.dataSourceConfig = await Incluir.incluirRegistro(
        this.api_crud,
        json_consulta_orcamento
      ); //pr_egisnet_gera_orcamento_ordem_servico
      this.ds_descricao = this.dataSourceConfig[0].ds_orcamento;
      this.cd_cliente = this.dataSourceConfig[0].cd_cliente;
      this.veiculo = { ...this.dataSourceConfig[0] }; //vl_total_item
      this.SomaTotalItems();
    },

    SomaTotalItems() {
      this.vl_total_produto = this.dataSourceConfig.reduce(function (
        acumulador,
        valorAtual
      ) {
        return acumulador + valorAtual.vl_total_item;
      },
      0);
      this.vl_total_produto_formatado = this.vl_total_produto.toLocaleString(
        "pt-BR",
        {
          style: "currency",
          currency: "BRL",
        }
      );
    },

    linhacategoria: function (e) {
      this.linha_selecionada = e.row && e.row.data;
    },
    async ListaCarrinho(e) {
      e.qt_digitacao = 1;
      if (e.Quantidade == 0) {
        e.Quantidade = parseFloat(e.Quantidade + 1);

        if (this.dataSourceConfig.length === 0) {
          this.dataSourceConfig.push(e);
        } else {
          e.cd_controle = parseFloat(
            this.dataSourceConfig[this.dataSourceConfig.length - 1]
              .cd_controle + 1
          );
          this.dataSourceConfig.push(e);
        }
      } else {
        this.dataSourceConfig.push(e);
      }
      //this.SomaItens();
      this.categoria = "";
      this.grupo = "";
      this.marca = "";
      this.cd_mascara_produto = "";
      this.nm_fantasia_produto = "";
      this.nm_produto = "";
      this.resultado_item = [];
      this.pesquisa_produto = false;
      this.nm_servico = "";
      this.tipo_servico = [];
      notify("Item adicionado ao carrinho!");
    },
    async onEnviarOrcamento() {
      try {
        await this.$refs.gridPadrao.instance.saveEditData();
        await funcao.sleep(1);
      } catch {
        notify("Salvando orçamento");
      }
      if (!this.veiculo.cd_veiculo) {
        notify("Veículo não informado");
        return;
      }
      if (this.cd_cliente == 0) {
        notify("Cliente não informado");
        return;
      }
      if (this.dataSourceConfig.length == 0) {
        notify("Nenhum produto/serviço foi informado");
        return;
      }
      var json_envia_pedido = {
        cd_parametro: 0,
        dt_entrega: this.dt_entrega,
        hr_entrega: this.hr_entrega,
        ds_orcamento: this.ds_descricao,
        cd_cliente: this.cd_cliente,
        cd_veiculo: this.veiculo.cd_veiculo,
        cd_usuario: this.cd_usuario,
        cd_contato: localStorage.cd_contato,
        vl_total_orcamento: this.vl_total_produto,
        grid: this.dataSourceConfig,
      };
      if (
        this.dataSourceConfig.some((o) => o.cd_orcamento > 0) ||
        this.cd_orcamento > 0
      ) {
        json_envia_pedido.cd_parametro = 2;
        json_envia_pedido.cd_orcamento = this.cd_orcamento;
      }
      console.log(json_envia_pedido, "json_envia_pedido");
      let [result_pedido] = await Incluir.incluirRegistro(
        this.api_crud,
        json_envia_pedido
      ); //pr_egisnet_gera_orcamento_ordem_servico
      if (result_pedido != undefined && result_pedido.cd_orcamento) {
        notify(`Orçamento ${result_pedido.cd_orcamento} enviado com sucesso`);
      } else if (result_pedido.Msg) {
        notify(`${result_pedido.Msg}`);
      } else {
        notify(`Não foi possível enviar o orçamento`);
      }
      this.limpaTudo();
      this.carregaDados(true);
    },
    async onExcluir() {
      if (this.cd_orcamento > 0) {
        var json_exclui_orcamento = {
          cd_parametro: 3,
          cd_orcamento: this.cd_orcamento,
        };
        let [resultado_exc] = await Incluir.incluirRegistro(
          this.api_crud,
          json_exclui_orcamento
        ); //pr_egisnet_gera_orcamento_ordem_servico
        notify(resultado_exc.Msg);
        await this.carregaDados();
        await this.limpaTudo();
      } else {
        notify("Orçamento não informado!");
      }
    },
    async onCesta() {
      try {
        await this.$refs.gridPadrao.instance.saveEditData();
        await funcao.sleep(1);
      } catch {
        notify("Aguarde...");
      }
      this.ic_grid_cesta = !this.ic_grid_cesta;
    },
    SelecionaVeiculo(e) {
      this.veiculo = e;
    },
    async SelecionaCliente(e) {
      this.cliente = e;
      localStorage.cd_tabela_preco = e.cd_tabela_preco;
      this.cd_cliente = e.cd_cliente;
      this.forma_pagamento = this.lookup_forma_pagamento.filter(
        (p) => p.cd_forma_pagamento == e.cd_forma_pagamento
      );
    },
    CalculaDesconto() {
      if (this.forma_pagamento.pc_desconto_pedido) {
        this.vl_desconto_pedido =
          (this.valor / 100) *
          parseFloat(this.forma_pagamento.pc_desconto_pedido);
        this.valor_liquido =
          this.valor -
          this.valor *
            (parseFloat(this.forma_pagamento.pc_desconto_pedido) / 100);

        this.valor_liquido = this.valor_liquido.toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
        this.vl_desconto_pedido = this.vl_desconto_pedido.toLocaleString(
          "pt-BR",
          {
            style: "currency",
            currency: "BRL",
          }
        );
      } else {
        this.vl_desconto_pedido = 0;
        this.valor_liquido = 0;
      }
    },
    async onPDF() {
      await funcao.sleep(1);
      if (this.dataSourceConfig.length > 0) {
        try {
          this.loadingPDF = true;
          await this.$refs.gridPDF.instance.deselectAll();
          this.complemento_impressao = true;
          this.dt_entrega = formataData.DiaMesAno(new Date(), true);
          const minutos =
            new Date().getMinutes() < 10
              ? "0" + new Date().getMinutes()
              : new Date().getMinutes();
          this.hr_entrega = `${new Date().getHours()}:${minutos}`;
          this.ic_grid_cesta = true;
          await funcao.sleep(1000);
          let html = document.getElementById("cesta");
          html2pdf()
            .from(html)
            .toPdf()
            .get("pdf")
            .then((pdf) => {
              window.open(pdf.output("bloburl"));
            });
          //Cria o documento PDF
          await funcao.ExportHTML(html, "A", config);
          this.loadingPDF = false;
          await funcao.sleep(10);
          await this.onEnviarOrcamento();
          this.complemento_impressao = false;
          this.ic_grid_cesta = false;
        } catch {
          this.loadingPDF = false;
          this.complemento_impressao = false;
          this.ic_grid_cesta = false;
        }
        this.dt_entrega = formataData.AnoMesDia(new Date());
      } else {
        notify("Insira pelo menos um item para gerar o relatório");
      }
    },
    async InputProduto(i) {
      if (this.cd_cliente > 0) {
        if (i === 1) {
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
          this.resultado_item = await Incluir.incluirRegistro(
            "562/781",
            this.nm_json
          );
          this.load = false;
          this.codigo = true;
          if (this.resultado_item[0].Cod === 0) {
            this.codigo = false;
            notify("Nenhum produto encontrado!");
            return;
          }
        } else if (i === 2) {
          this.nm_json = {
            cd_parametro: 19,
            cd_usuario: this.cd_usuario,
            cd_tipo_servico: this.tipo_servico.cd_tipo_servico,
            nm_produto: this.nm_servico,
          };
          this.load = true;
          this.resultado_item = await Incluir.incluirRegistro(
            "562/781",
            this.nm_json
          );
          this.load = false;
          this.codigo = true;
          if (this.resultado_item[0].Cod === 0) {
            this.codigo = false;
            notify("Nenhum serviço encontrado!");
            return;
          }
        }
      } else {
        notify(`Selecione Cliente`);
      }
    },
    async attQtd(e) {
      await funcao.sleep(1);
      var SomaItens = [];
      e.rows.map((i) => {
        SomaItens.push(i.data.vl_total_item);
        this.vl_total_produto = SomaItens.reduce(
          (partialSum, currentNumber) => partialSum + currentNumber,
          0
        );
        this.vl_total_produto_formatado = this.vl_total_produto.toLocaleString(
          "pt-BR",
          {
            style: "currency",
            currency: "BRL",
          }
        );
        if (
          i.data.qt_digitacao == null ||
          i.data.qt_digitacao == undefined ||
          i.data.qt_digitacao < 0
        ) {
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "qt_digitacao",
            0.0
          );
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_item",
            0.0
          );
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_liquido",
            0.0
          );
          i.data.qt_digitacao = 0;
        }
        if (typeof i.data.qt_digitacao === "string") {
          i.data.qt_digitacao = funcao.RealParaInt(i.data.qt_digitacao);
        }
        if (typeof i.data.VL_PRODUTO === "string") {
          i.data.VL_PRODUTO = funcao.RealParaInt(i.data.VL_PRODUTO);
        }
        if (
          i.data.qt_digitacao == 0 &&
          this.dataSourceConfig.find(
            (e) => e.cd_controle === i.data.cd_controle
          )
        ) {
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "qt_digitacao",
            0.0
          );
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_item",
            0.0
          );
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_liquido",
            0.0
          );
        }
        if (i.data.qt_digitacao > 0) {
          ////Verifica se a qtdade digitada é maior que o disponível
          if (
            this.dataSourceConfig.length == 0 ||
            (!this.dataSourceConfig.find(
              (e) => e.cd_controle === i.data.cd_controle
            ) &&
              !i.data.ic_produto_especial)
          ) {
            this.dataSourceConfig.push(i.data);
          } else if (
            !this.dataSourceConfig.find(
              (e) => e.cd_controle === i.data.cd_controle
            ) &&
            i.data.ic_produto_especial
          ) {
            this.$refs.gridPadrao.instance.saveEditData();
          } else {
            let alterouQtd = this.dataSourceConfig.find(
              (e) => e.cd_controle === i.data.cd_controle
            );
            alterouQtd.index = this.dataSourceConfig.findIndex(
              (e) => e.cd_controle === i.data.cd_controle
            );
            if (alterouQtd.qt_digitacao != i.data.qt_digitacao) {
              this.dataSourceConfig[alterouQtd.index].qt_digitacao =
                i.data.qt_digitacao;
            }
          }
          let vl_total_item =
            i.data.qt_digitacao.toFixed(2) * i.data.VL_PRODUTO.toFixed(2);
          let vl_total_liquido =
            i.data.qt_digitacao.toFixed(2) * i.data.VL_PRODUTO.toFixed(2);
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_item",
            vl_total_item
          );
          this.$refs.gridPadrao.instance.cellValue(
            i.rowIndex,
            "vl_total_liquido",
            vl_total_liquido
          );
        }
      });
    },

    onNovaLinha(e) {
      e.data = {
        cd_controle: this.dataSourceConfig.length + 1,
        VL_PRODUTO: 1.0,
        ic_produto_especial: true,
        ds_produto_orcamento: "",
        FANTASIA: "",
        CODIGO: "",
        Produto: "",
      };
    },

    limpaTudo() {
      this.veiculo = {};
      this.cliente = {};
      this.cd_cliente = 0;
      this.cd_orcamento = 0;
      this.ds_descricao = "";
      this.dataSourceConfig = [];
      this.limpaTotais();
    },
    limpaTotais() {
      this.valor = 0;
      this.qtd = 0;
      this.valor_liquido = 0;
      this.vl_total_produto_formatado = 0;
      this.vl_desconto_pedido = 0;
    },
    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Employees");

      exportDataGrid({
        component: e.component,
        worksheet: worksheet,
        autoFilterEnabled: true,
      }).then(function () {
        // https://github.com/exceljs/exceljs#writing-xlsx
        workbook.xlsx.writeBuffer().then(function (buffer) {
          saveAs(
            new Blob([buffer], { type: "application/octet-stream" }),
            filename
          );
        });
      });
      e.cancel = true;
    },
  },
};
</script>

<style scoped>
@import url("./views.css");

.borda-zero {
  height: 12vh;
  padding: 0px;
  margin: 0px;
}

.cor-relatorio {
  color: #bbe0fd;
  padding: 0px;
  margin: -14px 5px 5px 5px;
  height: 5vh;
}

.medicam {
  font-weight: bolder;
  font-size: 36px;
  background: linear-gradient(to top, #95b4d1, #d2e4fa);
  background-clip: text; /* Define o clipping do gradiente */
  -webkit-background-clip: text; /* Para navegadores WebKit (Safari, Chrome, etc.) */
  -moz-background-clip: text; /* Para navegadores Gecko (Firefox) */
  -o-background-clip: text; /* Para navegadores Opera */
  -ms-background-clip: text; /* Para navegadores antigos da Microsoft (IE) */
  -webkit-text-fill-color: transparent;
  color: transparent;
}

.alphaset {
  font-weight: 400;
  font-size: 36px;
  background: linear-gradient(to top, #8db4e6, #afcff0);
  background-clip: text; /* Define o clipping do gradiente */
  -webkit-background-clip: text; /* Para navegadores WebKit (Safari, Chrome, etc.) */
  -moz-background-clip: text; /* Para navegadores Gecko (Firefox) */
  -o-background-clip: text; /* Para navegadores Opera */
  -ms-background-clip: text; /* Para navegadores antigos da Microsoft (IE) */
  -webkit-text-fill-color: transparent; /* Define a cor do texto como transparente para permitir que o gradiente apareça */
  color: transparent; /* Define a cor do texto como transparente para navegadores que não suportam 'text-fill-color' */
}

.checkboxPDF {
  width: 4vw;
  height: 4vh;
}

.tituloOrcamento {
  font-weight: bold;
  font-size: 18px;
  color: #fff;
}

.card-cesta {
  display: flex;
  flex-wrap: wrap;
  font-weight: bold;
}

.opcoes {
  display: flex;
  flex-wrap: wrap;
  width: calc(100% / 8);
}

@media (max-width: 800px) {
  .opcoes {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
  }
}
</style>
