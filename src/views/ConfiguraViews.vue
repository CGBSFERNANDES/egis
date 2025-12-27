<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="row items-center">
      <transition name="slide-fade">
        <h2 class="col-8 tituloTexto" v-show="!!tituloMenu != false">
          {{ tituloMenu }}
          <q-badge
            v-if="this.dataSourceConfig.length > 0"
            align="middle"
            rounded
            color="red"
            :label="this.dataSourceConfig.length"
          />
        </h2>
      </transition>
    </div>

    <!-- Informações -->
    <q-btn
      rounded
      class="margin1"
      color="primary"
      icon="add"
      label="Novo"
      @click="onNovo()"
    />
    <q-tabs
      v-model="index"
      inline-label
      mobile-arrows
      align="justify"
      style="border-radius: 20px"
      :class="'bg-orange text-white shadow-2 margin1'"
    >
      <q-tab :name="0" icon="description" label="Dados" />
      <q-tab :name="1" icon="menu" label="Menu" />
    </q-tabs>
    <!-- Dados -->
    <transition name="slide-fade">
      <div v-if="index == 0">
        <dx-data-grid
          id="grid-padrao"
          class="dx-card wide-card"
          :data-source="dataSourceConfig"
          :columns="columns"
          :summary="total"
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
          :focused-row-index="0"
          :cacheEnable="false"
          @exporting="onExporting"
          @focused-row-changed="onFocusedRowChanged"
          @row-removing="RemoveMenu"
        >
          <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

          <DxGrouping :auto-expand-all="true" />

          <DxExport :enabled="true" />

          <DxPaging :page-size="10" />

          <DxSelection
            :select-all-mode="allMode"
            :show-check-boxes-mode="checkBoxesMode"
            mode="multiple"
          />

          <DxSelectBox
            id="select-all-mode"
            :data-source="['allPages', 'page']"
            :disabled="checkBoxesMode === 'none'"
            :v-model:value="allMode"
          />

          <DxStateStoring
            :enabled="true"
            type="localStorage"
            storage-key="storageGrid"
          />
          <DxSelection mode="single" />
          <DxPager
            :show-page-size-selector="true"
            :allowed-page-sizes="[10, 20, 50, 100]"
            :show-info="true"
          />
          <DxFilterRow :visible="false" />
          <DxHeaderFilter :visible="true" :allow-search="true" />
          <DxSearchPanel
            :visible="true"
            :width="300"
            placeholder="Procurar..."
          />
          <DxFilterPanel :visible="true" />
          <DxColumnFixing :enabled="true" />
          <DxColumnChooser :enabled="true" mode="select" />
          <DxEditing
            refresh-mode="reshape"
            :allow-update="true"
            :allow-deleting="true"
            mode="popup"
          >
            <DxPopup :show-title="true" title="menu">
              <DxPosition my="top" at="top" of="window" />
            </DxPopup>
          </DxEditing>

          <DxMasterDetail
            v-if="!cd_detalhe == 0"
            :enabled="true"
            template="master-detail"
          />

          <template #master-detail="{ data }">
            <MasterDetail
              :cd_menuID="cd_menu_detalhe"
              :cd_apiID="cd_api_detalhe"
              :master-detail-data="data"
            />
          </template>
        </dx-data-grid>
      </div>
    </transition>
    <!-- Menu -->
    <transition name="slide-fade">
      <div v-if="index == 1">
        <div class="borda-bloco shadow-2 margin1 text-bold">
          <div class="margin1">
            {{ `Menu` }}
            {{ `${menu_select.cd_menu ? menu_select.cd_menu : ""}` }}
          </div>
          <div class="row">
            <q-input dense class="col margin1" v-model="nm_menu" label="Menu">
              <template v-slot:prepend>
                <q-icon name="menu"></q-icon>
              </template>
            </q-input>
            <q-input
              dense
              class="col margin1"
              v-model="nm_titulo"
              label="Título"
            >
              <template v-slot:prepend>
                <q-icon name="subtitles"></q-icon>
              </template>
            </q-input>
            <q-select
              dense
              class="col margin1"
              v-model="nivel_acesso"
              :options="dados_lookup_nivel_acesso"
              option-value="cd_nivel_acesso"
              option-label="nm_nivel_acesso"
              label="Nível de Acesso"
            >
              <template v-slot:prepend>
                <q-icon name="trending_up"></q-icon>
              </template>
            </q-select>
          </div>
          <div class="row">
            <q-select
              dense
              class="col margin1"
              v-model="procedimento"
              :options="dados_lookup_procedimento"
              option-value="cd_procedimento"
              option-label="nm_procedimento"
              label="Procedimento"
              :hint="procedimento.nm_sql_procedimento"
            >
              <template v-slot:prepend>
                <q-icon name="account_tree"></q-icon>
              </template>
            </q-select>
            <q-select
              dense
              class="col margin1"
              v-model="rota"
              :options="dados_lookup_rota"
              option-value="cd_rota"
              option-label="nm_rota"
              label="Rota"
            >
              <template v-slot:prepend>
                <q-icon name="directions"></q-icon>
              </template>
            </q-select>
            <q-select
              dense
              use-input
              input-debounce="0"
              class="col margin1"
              v-model="menu_api"
              :options="dados_lookup_api_menu"
              option-value="cd_api"
              option-label="nm_api"
              label="API"
              @filter="filterFnMenu"
            >
              <template v-slot:prepend>
                <q-icon name="code"></q-icon>
              </template>
              <template v-slot:no-option>
                <q-item>
                  <q-item-section class="text-grey">
                    Não encontrado
                  </q-item-section>
                </q-item>
              </template>
              <q-tooltip>
                {{ `Busca tabela ou procedure` }}
              </q-tooltip>
            </q-select>
          </div>
          <transition name="slide-fade">
            <div class="margin1" v-if="menu_api">
              {{ `Código da API: ${menu_api.cd_api} | ` }}
              {{ `Nome: ${menu_api.nm_api} | ` }}
              {{
                `Procedimento: ${
                  menu_api.cd_procedimento ? menu_api.cd_procedimento : ""
                } | `
              }}
              {{ `Tabela: ${menu_api.cd_tabela ? menu_api.cd_tabela : ""} ` }}
              {{
                `Tipo de Procedure: ${
                  menu_api.ic_procedimento_crud === "S" ? "JSON" : "Parâmetros"
                }`
              }}
            </div>
          </transition>
        </div>
        <div class="borda-bloco shadow-2 margin1 text-bold">
          <div class="margin1">
            {{ `Componentes` }}
            <q-btn
              style="margin: 5px"
              round
              color="orange"
              icon="add"
              @click="AddComponente()"
              size="sm"
            >
              <q-tooltip> Adicionar </q-tooltip>
            </q-btn>
            <q-btn
              style="margin: 5px"
              round
              color="red"
              icon="delete"
              @click="DeleteComponente()"
              size="sm"
            >
              <q-tooltip> Deletar </q-tooltip>
            </q-btn>
          </div>
          <div class="row">
            <q-select
              dense
              class="col margin1"
              v-model="componente"
              :options="dados_lookup_componente"
              option-value="cd_componente"
              option-label="nm_componente"
              label="Componente"
              @input="SelectComponente()"
            >
              <template v-slot:prepend>
                <q-icon name="inventory_2"></q-icon>
              </template>
            </q-select>
            <transition name="slide-fade">
              <q-select
                v-if="
                  componente.cd_componente === 1 ||
                  componente.cd_componente === 2 ||
                  componente.cd_componente === 6
                "
                dense
                class="col margin1"
                v-model="icone"
                :options="dados_lookup_icone"
                option-value="cd_icone"
                option-label="nm_icone"
                label="Icones"
                @input="SelectIcones()"
              >
                <template v-slot:prepend>
                  <q-icon name="add_reaction"></q-icon>
                </template>
              </q-select>
            </transition>
            <transition name="slide-fade">
              <q-select
                v-if="componente.cd_componente && componente.cd_componente != 4"
                dense
                class="col margin1"
                v-model="cor"
                :options="dados_lookup_cor"
                option-value="cd_cor"
                option-label="nm_cor"
                label="Cor"
                @input="SelectCor()"
              >
                <template v-slot:prepend>
                  <q-icon name="palette"></q-icon>
                </template>
              </q-select>
            </transition>
            <transition name="slide-fade">
              <div
                class="col margin1"
                v-if="
                  componente.cd_componente === 1 ||
                  componente.cd_componente === 2
                "
              >
                {{ `Menor` }}
                <q-toggle dense v-model="dense_comp" @input="TogglePopup()">
                  <q-tooltip>
                    {{ `Deixa o componente menor ou normal` }}
                  </q-tooltip>
                </q-toggle>
                {{ `Maior` }}
              </div>
            </transition>
          </div>
          <div class="row">
            <transition name="slide-fade">
              <q-input
                v-if="componente.cd_componente && componente.cd_componente != 4"
                dense
                class="col margin1"
                v-model="nm_texto"
                @input="onText()"
                label="Texto"
              >
                <template v-slot:prepend>
                  <q-icon name="description"></q-icon>
                </template>
              </q-input>
            </transition>

            <transition name="slide-fade">
              <q-input
                v-if="componente.cd_componente && componente.cd_componente == 3"
                dense
                class="col margin1"
                v-model="nm_texto_direita"
                @input="onTextDireita()"
                label="Texto Direita"
              >
                <template v-slot:prepend>
                  <q-icon name="description"></q-icon>
                </template>
              </q-input>
            </transition>
            <transition name="slide-fade">
              <q-select
                v-if="componente.cd_componente === 1"
                dense
                class="col margin1"
                v-model="natureza"
                :options="dados_lookup_natureza"
                option-value="cd_natureza_atributo"
                option-label="nm_natureza_atributo"
                label="Natureza"
                @input="SelectNatureza()"
              >
                <template v-slot:prepend>
                  <q-icon name="format_list_bulleted"></q-icon>
                </template>
              </q-select>
            </transition>
            <transition name="slide-fade">
              <q-select
                v-if="
                  componente.cd_componente === 1 ||
                  componente.cd_componente === 2 ||
                  componente.cd_componente === 6
                "
                dense
                class="col margin1"
                v-model="estilo"
                :options="dados_lookup_estilo"
                option-value="cd_estilo"
                option-label="nm_estilo"
                label="Estilo"
                @input="SelectEstilo()"
              >
                <template v-slot:prepend>
                  <q-icon name="format_paint"></q-icon>
                </template>
              </q-select>
            </transition>
            <transition name="slide-fade">
              <q-select
                v-if="
                  componente.cd_componente === 2 ||
                  componente.cd_componente === 4 ||
                  componente.cd_componente === 6
                "
                dense
                use-input
                input-debounce="0"
                class="col margin1"
                v-model="componente_api"
                :options="dados_lookup_api_comp"
                option-value="cd_api"
                option-label="nm_api"
                label="API"
                @input="SelectApi()"
                @filter="filterFnComp"
              >
                <template v-slot:prepend>
                  <q-icon name="code"></q-icon>
                </template>
                <q-tooltip>
                  {{ `Busca tabela ou procedure` }}
                </q-tooltip>
              </q-select>
            </transition>
          </div>
          <div class="row">
            <transition name="slide-fade">
              <q-input
                v-if="componente.cd_componente === 1"
                dense
                class="col margin1"
                v-model="nm_prefixo"
                label="Prefixo"
                @input="onPrefixo()"
              >
                <template v-slot:prepend>
                  <q-icon name="arrow_back"></q-icon>
                </template>
              </q-input>
            </transition>

            <transition name="slide-fade">
              <q-input
                v-if="componente.cd_componente === 1"
                dense
                class="col margin1"
                v-model="nm_sufixo"
                label="Sufixo"
                @input="onSufixo()"
              >
                <template v-slot:prepend>
                  <q-icon name="arrow_forward"></q-icon>
                </template>
              </q-input>
            </transition>

            <transition name="slide-fade">
              <q-input
                v-if="componente.cd_componente && componente.cd_componente != 4"
                dense
                class="col margin1"
                v-model="ds_descritivo"
                label="Descritivo"
                @input="onDescritivo()"
              >
                <template v-slot:prepend>
                  <q-icon name="description"></q-icon>
                </template>
                <q-tooltip>
                  {{ `Texto que aparece ao passar o mouse` }}
                </q-tooltip>
              </q-input>
            </transition>

            <transition name="slide-fade">
              <q-input
                v-if="
                  componente.cd_componente === 1 ||
                  componente.cd_componente === 2
                "
                dense
                class="col margin1"
                v-model="nm_campo_valor"
                label="Valor"
                @input="onValor()"
              >
                <template v-slot:prepend>
                  <q-icon name="code"></q-icon>
                </template>
                <q-tooltip>
                  {{ `Valor que é buscado na Procedure` }}
                </q-tooltip>
              </q-input>
            </transition>
            <transition name="slide-fade">
              <div class="col margin1" v-if="componente.cd_componente === 6">
                {{ `Tabela` }}
                <q-toggle
                  dense
                  v-model="ic_grid_componente"
                  @input="ToggleBtn()"
                >
                  <q-tooltip>
                    {{
                      `Indica se vai buscar informação da linha selecionada na tabela ou dos componentes`
                    }}
                  </q-tooltip>
                </q-toggle>
                {{ `Componentes` }}
              </div>
            </transition>
            <q-select
              dense
              class="col margin1"
              v-model="posicao"
              :options="dados_lookup_posicao"
              option-value="cd_posicao"
              option-label="nm_posicao"
              label="Posição"
              @input="SelectPosicao()"
            >
              <template v-slot:prepend>
                <q-icon name="picture_in_picture_alt"></q-icon>
              </template>
            </q-select>
          </div>
          <transition name="slide-fade">
            <div class="margin1" v-if="componente_api">
              {{ `Código da API: ${componente_api.cd_api} | ` }}
              {{ `Nome: ${componente_api.nm_api} | ` }}
              {{
                `Procedimento: ${
                  componente_api.cd_procedimento
                    ? componente_api.cd_procedimento
                    : ""
                } | `
              }}
              {{
                `Tabela: ${
                  componente_api.cd_tabela ? componente_api.cd_tabela : ""
                }`
              }}
              {{
                `Tipo de Procedure: ${
                  componente_api.ic_procedimento_crud === "S"
                    ? "JSON"
                    : "Parâmetros"
                }`
              }}
            </div>
          </transition>
        </div>

        <div class="borda-bloco shadow-2 margin1 text-bold">
          <div class="margin1">
            {{ `Pré-Visualização` }}
          </div>
          <transition name="slide-fade">
            <div class="row items-center" v-if="nm_titulo">
              <h2 class="col-8 tituloTexto">
                {{ nm_titulo }}
              </h2>
            </div>
          </transition>
          <div class="row">
            <transition-group
              name="slide-fade"
              tag="div"
              style="display: flex; flex-wrap: wrap"
            >
              <div v-for="(c, index) in lista_componentes" :key="index">
                <div class="col-8">
                  <q-btn
                    style="margin: 5px"
                    round
                    color="orange"
                    icon="edit"
                    @click="EditarComponente(c, index)"
                    size="xs"
                  >
                    <q-tooltip>
                      {{ `Editar componente ${index + 1}` }}
                    </q-tooltip>
                  </q-btn>
                  <q-btn
                    style="margin: 5px"
                    round
                    color="red"
                    icon="delete"
                    @click="DeleteComponente(c)"
                    size="xs"
                  >
                    <q-tooltip>
                      {{ `Deletar componente ${index + 1}` }}
                    </q-tooltip>
                  </q-btn>
                  {{
                    `${
                      componente_edit !== "" && componente_edit.index === index
                        ? "Editando"
                        : ""
                    }`
                  }}
                  <div v-if="c.cd_componente == 1">
                    <q-input
                      :prefix="c.prefixo"
                      :suffix="c.sufixo"
                      :color="c.vl_cor"
                      :filled="c.cd_estilo === 2 ? true : false"
                      :outlined="
                        c.cd_estilo === 3 || c.cd_estilo === 6 ? true : false
                      "
                      :standout="
                        c.cd_estilo === 4 || c.cd_estilo === 6 ? true : false
                      "
                      :borderless="c.cd_estilo === 5 ? true : false"
                      :rounded="c.cd_estilo === 6 ? true : false"
                      :type="
                        c.vl_natureza_atributo ? c.vl_natureza_atributo : 'text'
                      "
                      :dense="c.dense"
                      :dark="false"
                      class="col margin1"
                      v-model="model"
                      :label="c.nm_texto"
                    >
                      <template v-slot:prepend>
                        <q-icon :name="c.nm_icone_atributo"></q-icon>
                      </template>
                      <q-tooltip v-if="c.descritivo">
                        {{ `${c.descritivo}` }}
                      </q-tooltip>
                    </q-input>
                  </div>
                  <div v-if="c.cd_componente == 2">
                    <q-select
                      :filled="c.cd_estilo === 2 ? true : false"
                      :outlined="
                        c.cd_estilo === 3 || c.cd_estilo === 6 ? true : false
                      "
                      :standout="
                        c.cd_estilo === 4 || c.cd_estilo === 6 ? true : false
                      "
                      :borderless="c.cd_estilo === 5 ? true : false"
                      :rounded="c.cd_estilo === 6 ? true : false"
                      class="col margin1"
                      v-model="select"
                      :options="options"
                      :color="c.vl_cor"
                      :dense="c.dense"
                      option-value="cd_teste"
                      option-label="nm_teste"
                      :label="c.nm_texto"
                    >
                      <template v-slot:prepend>
                        <q-icon :name="c.nm_icone_atributo"></q-icon>
                      </template>
                      <q-tooltip v-if="c.descritivo">
                        {{ `${c.descritivo}` }}
                      </q-tooltip>
                    </q-select>
                  </div>
                  <div v-if="c.cd_componente == 3">
                    {{ `${c.nm_texto}` }}
                    <q-toggle
                      class="col margin1"
                      v-model="ic_pre_visualizacao"
                      :color="c.vl_cor"
                    >
                      <q-tooltip v-if="c.descritivo">
                        {{ `${c.descritivo}` }}
                      </q-tooltip>
                    </q-toggle>
                    {{ `${c.nm_texto_direita}` }}
                  </div>
                  <div v-if="c.cd_componente == 4">
                    <!-- GRID -->
                    <dx-data-grid
                      id="grid-padrao"
                      class="dx-card wide-card"
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
                      :focused-row-index="0"
                      :cacheEnable="false"
                    >
                      <DxGroupPanel
                        :visible="true"
                        empty-panel-text="agrupar..."
                      />

                      <DxGrouping :auto-expand-all="true" />

                      <DxExport :enabled="true" />

                      <DxPaging :page-size="10" />

                      <DxSelection
                        :select-all-mode="allMode"
                        :show-check-boxes-mode="checkBoxesMode"
                        mode="multiple"
                      />

                      <DxSelectBox
                        id="select-all-mode"
                        :data-source="['allPages', 'page']"
                        :disabled="checkBoxesMode === 'none'"
                        :v-model:value="allMode"
                      />

                      <DxStateStoring
                        :enabled="true"
                        type="localStorage"
                        storage-key="storageGrid"
                      />
                      <DxSelection mode="single" />
                      <DxPager
                        :show-page-size-selector="true"
                        :allowed-page-sizes="[10, 20, 50, 100]"
                        :show-info="true"
                      />
                      <DxFilterRow :visible="false" />
                      <DxHeaderFilter :visible="true" :allow-search="true" />
                      <DxSearchPanel
                        :visible="true"
                        :width="300"
                        placeholder="Procurar..."
                      />
                      <DxFilterPanel :visible="true" />
                      <DxColumnFixing :enabled="true" />
                      <DxColumnChooser :enabled="true" mode="select" />
                      <DxEditing
                        refresh-mode="reshape"
                        :allow-adding="true"
                        :allow-update="true"
                        mode="popup"
                      >
                        <DxPopup :show-title="true" title="menu">
                          <DxPosition my="top" at="top" of="window" />
                        </DxPopup>
                      </DxEditing>

                      <DxMasterDetail
                        v-if="!cd_detalhe == 0"
                        :enabled="true"
                        template="master-detail"
                      />

                      <template #master-detail="{ data }">
                        <MasterDetail
                          :cd_menuID="cd_menu_detalhe"
                          :cd_apiID="cd_api_detalhe"
                          :master-detail-data="data"
                        />
                      </template>
                    </dx-data-grid>
                  </div>
                  <div v-if="c.cd_componente == 5">
                    <q-card class="my-card">
                      <q-card-section
                        style="margin: 0.2vw; padding: 0px; text-align: center"
                        class="margin1"
                      >
                        {{ `${c.nm_texto}` }}
                      </q-card-section>
                      <q-card-section
                        class="borda-bloco"
                        style="margin: 0.4vw; padding: 0px"
                      >
                        {{ `Texto do Card` }}<br />
                      </q-card-section>
                      <q-tooltip v-if="c.descritivo">
                        {{ `${c.descritivo}` }}
                      </q-tooltip>
                    </q-card>
                  </div>
                  <div v-if="c.cd_componente == 6">
                    <q-btn
                      class="margin1"
                      :rounded="c.cd_estilo === 6 ? true : false"
                      :color="c.vl_cor"
                      :icon="c.nm_icone_atributo"
                      text-color="black"
                      :label="c.nm_texto"
                    >
                      <q-tooltip v-if="c.descritivo">
                        {{ `${c.descritivo}` }}
                      </q-tooltip>
                    </q-btn>
                  </div>
                </div>
              </div>
            </transition-group>
          </div>
        </div>

        <div class="row">
          <q-btn
            rounded
            class="margin1"
            color="orange-9"
            icon="save"
            label="Salvar"
            @click="onSalvar()"
          />
          <q-space />
          <q-btn
            rounded
            class="margin1"
            color="red"
            icon="close"
            label="Cancelar"
            @click="onCancelar()"
          />
        </div>
        <!-- <div class="row"></div> -->
      </div>
    </transition>
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
  DxSelection,
  DxStateStoring,
  DxSearchPanel,
  DxEditing,
  DxPosition,
  DxMasterDetail,
  DxPopup,
} from "devextreme-vue/data-grid";

import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import Incluir from "../http/incluir_registro";
import Menu from "../http/menu";
import MasterDetail from "../views/MasterDetail";

import Lookup from "../http/lookup";

//import lookup from '../views/lookup';

//import periodo from '../views/selecao-periodo';

import "whatwg-fetch";

import DxSelectBox from "devextreme-vue/select-box";

var dados = [];
var sParametroApi = "";

export default {
  data() {
    return {
      tituloMenu: "",
      menu: "",
      model: "",
      select: "",
      ic_pre_visualizacao: false,
      options: [
        {
          cd_teste: 1,
          nm_teste: "Opção Teste",
        },
        {
          cd_teste: 2,
          nm_teste: "Opção Teste2",
        },
      ],
      // Configurações do Menu
      nm_menu: "",
      nm_titulo: "",
      nivel_acesso: "",
      dados_lookup_nivel_acesso: [],
      icone: "",
      dados_lookup_icone: [],
      cor: "",
      dados_lookup_cor: [],
      procedimento: "",
      dados_lookup_procedimento: [],
      rota: "",
      dados_lookup_rota: [],
      menu_api: "",
      componente_api: "",
      dados_lookup_api: [],
      dados_lookup_api_menu: [],
      dados_lookup_api_comp: [],
      dense_comp: false,
      ic_grid_componente: false,
      nm_texto: "",
      nm_texto_direita: "",
      natureza: "",
      dados_lookup_natureza: [
        {
          cd_natureza_atributo: 1,
          nm_natureza_atributo: "Texto",
          vl_natureza_atributo: "text",
        },
        {
          cd_natureza_atributo: 2,
          nm_natureza_atributo: "Número",
          vl_natureza_atributo: "number",
        },
        {
          cd_natureza_atributo: 3,
          nm_natureza_atributo: "Senha",
          vl_natureza_atributo: "password",
        },
        {
          cd_natureza_atributo: 4,
          nm_natureza_atributo: "Hora",
          vl_natureza_atributo: "time",
        },
        {
          cd_natureza_atributo: 5,
          nm_natureza_atributo: "Data",
          vl_natureza_atributo: "date",
        },
      ],
      estilo: "",
      dados_lookup_estilo: [
        {
          cd_estilo: 1,
          nm_estilo: "Standard",
        },
        {
          cd_estilo: 2,
          nm_estilo: "Filled",
        },
        {
          cd_estilo: 3,
          nm_estilo: "Outlined",
        },
        {
          cd_estilo: 4,
          nm_estilo: "Standout",
        },
        {
          cd_estilo: 5,
          nm_estilo: "Borderless",
        },
        {
          cd_estilo: 6,
          nm_estilo: "Rounded",
        },
      ],
      nm_prefixo: "",
      nm_sufixo: "",
      ds_descritivo: "",
      nm_campo_valor: "",
      posicao: "",
      dados_lookup_posicao: [
        {
          cd_posicao: 1,
          nm_posicao: "Header",
        },
        {
          cd_posicao: 2,
          nm_posicao: "Footer",
        },
      ],
      componente: "",
      dados_lookup_componente: [
        {
          cd_componente: 1,
          nm_componente: "Input",
        },
        {
          cd_componente: 2,
          nm_componente: "Select",
        },
        {
          cd_componente: 3,
          nm_componente: "Toggle",
        },
        {
          cd_componente: 4,
          nm_componente: "Grid(Tabela)",
        },
        {
          cd_componente: 5,
          nm_componente: "Card",
        },
        {
          cd_componente: 6,
          nm_componente: "Botão",
        },
      ],
      lista_componentes: [],
      componente_edit: "",
      //
      allMode: "allPages",
      checkBoxesMode: "onClick",
      menu_select: "",
      index: 0,
      columns: [],
      dataSourceConfig: [],
      total: {},
      tabs: [],
      cd_tipo_consulta: 0,
      ic_filtro_pesquisa: "N",
      qt_tempo: 0,
      filtro: [],
      exportar: false,
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_menu: localStorage.cd_menu,
      cd_cliente: 0,
      cd_api: 0,
      api: 0,
      ds_menu_descritivo: "",
      ic_form_menu: "N",
      ic_tipo_data_menu: "0",
      hoje: "",
      hora: "",
      items: [],
      cd_tipo_email: 0,
      cd_relatorio: 1,
      qt_registro: 0,
      cd_detalhe: 0,
      cd_menu_detalhe: 0,
      cd_api_detalhe: 0,
      cd_identificacao: "",
      periodo: "",
    };
  },

  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    this.hoje = "";
    this.hora = "";
  },

  async mounted() {
    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;

    await this.carregaDados();
    await this.carregaTabela();
  },

  watch: {
    async index(novo, antigo) {
      if (novo === 0 && antigo === 1) {
        await this.carregaDados();
      } else {
        if (this.menu_select.cd_menu) {
          let JSON_Config_Menu = {
            cd_parametro: 4,
            cd_usuario: this.cd_usuario,
            cd_menu: this.menu_select.cd_menu,
          };
          let menu_lista = await Incluir.incluirRegistro(
            this.api,
            JSON_Config_Menu
          );
          this.nm_texto = "";
          this.nm_texto_direita = "";
          this.cor = "";
          this.dense_comp = false;
          this.ic_grid_componente = false;
          this.nm_prefixo = "";
          this.nm_sufixo = "";
          this.ds_descritivo = "";
          this.nm_campo_valor = "";
          this.componente = [];
          this.icone = [];
          this.natureza = [];
          this.estilo = [];
          this.posicao = [];
          this.componente_edit = "";
          this.lista_componentes = [];
          this.select = "";
          this.model = "";
          this.componente_api = "";
          this.ic_pre_visualizacao = false;
          let cor_salva = {};
          let componente_salva = {};
          let icone_salva = {};
          let natureza_salva = {};
          let estilo_salva = {};
          let posicao_salva = {};
          let api_salva = {};
          menu_lista.map((e) => {
            ////Cor
            [cor_salva] = this.dados_lookup_cor.filter((c) => {
              return c.cd_cor === e.cd_cor;
            });
            cor_salva = cor_salva
              ? cor_salva
              : {
                  cd_cor: 0,
                  nm_cor: "",
                  vl_cor: "primary",
                };
            ////Componente
            [componente_salva] = this.dados_lookup_componente.filter((c) => {
              return c.cd_componente === e.cd_componente;
            });
            ////Icone
            [icone_salva] = this.dados_lookup_icone.filter((c) => {
              return c.cd_icone === e.cd_icone;
            });
            icone_salva = icone_salva
              ? icone_salva
              : {
                  cd_icone: 0,
                  nm_icone: "",
                  nm_icone_atributo: "",
                };
            ////Natureza
            [natureza_salva] = this.dados_lookup_natureza.filter((c) => {
              return (
                c.cd_natureza_atributo ===
                (e.cd_natureza_atributo == undefined
                  ? 1
                  : e.cd_natureza_atributo)
              );
            });
            ////Estilo
            [estilo_salva] = this.dados_lookup_estilo.filter((c) => {
              return c.cd_estilo === e.cd_estilo_componente;
            });
            estilo_salva = estilo_salva
              ? estilo_salva
              : {
                  cd_estilo: 1,
                  nm_estilo: "Standard",
                };
            ////Posição
            [posicao_salva] = this.dados_lookup_posicao.filter((c) => {
              return c.cd_posicao === e.cd_posicao ? e.cd_posicao : 1;
            });
            ////API
            [api_salva] = this.dados_lookup_api.filter((c) => {
              return c.cd_api === e.cd_api;
            });
            api_salva = api_salva ? api_salva : "";
            this.lista_componentes.push({
              nm_texto: e.nm_campo_texto,
              nm_texto_direita: e.nm_campo_texto_direita,
              dense: e.ic_dense === "t" ? true : false,
              prefixo: e.nm_prefixo,
              sufixo: e.nm_sufixo,
              descritivo: e.ds_descritivo,
              ic_grid_componente: e.ic_grid_componente === "t" ? true : false,
              nm_campo_valor: e.nm_campo_valor,
              cd_cor: cor_salva.cd_cor,
              nm_cor: cor_salva.nm_cor,
              vl_cor: cor_salva.vl_cor,
              cd_componente: componente_salva.cd_componente,
              nm_componente: componente_salva.nm_componente,
              cd_icone: icone_salva.cd_icone,
              nm_icone: icone_salva.nm_icone,
              nm_icone_atributo: icone_salva.nm_icone_atributo,
              cd_natureza_atributo: natureza_salva.cd_natureza_atributo,
              nm_natureza_atributo: natureza_salva.nm_natureza_atributo,
              vl_natureza_atributo: natureza_salva.vl_natureza_atributo,
              cd_estilo: estilo_salva.cd_estilo,
              nm_estilo: estilo_salva.nm_estilo,
              cd_posicao: posicao_salva.cd_posicao,
              nm_posicao: posicao_salva.nm_posicao,
              cd_api: api_salva.cd_api,
              cd_procedimento: api_salva.cd_procedimento,
              cd_tabela: api_salva.cd_tabela,
              nm_api: api_salva.nm_api,
              nm_identificacao_api: api_salva.nm_identificacao_api,
            });
          });
        }
      }
    },
  },

  components: {
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
    DxSelection,
    DxSelectBox,
    DxStateStoring,
    DxSearchPanel,
    DxPopup,
    DxEditing,
    DxPosition,
    DxMasterDetail,
    MasterDetail,
    //  DxLoadPanel
  },

  methods: {
    async carregaTabela() {
      this.dados_lookup_nivel_acesso = await Lookup.montarSelect(
        this.cd_empresa,
        431
      );
      this.dados_lookup_nivel_acesso = JSON.parse(
        this.dados_lookup_nivel_acesso.dataset
      );
      //////////////////////////
      this.dados_lookup_icone = await Lookup.montarSelect(
        this.cd_empresa,
        5405
      );
      this.dados_lookup_icone = JSON.parse(this.dados_lookup_icone.dataset);
      //////////////////////////
      this.dados_lookup_cor = await Lookup.montarSelect(
        1, //this.cd_empresa,
        5641
      );
      this.dados_lookup_cor = JSON.parse(this.dados_lookup_cor.dataset);
      //////////////////////////
      this.dados_lookup_procedimento = await Lookup.montarSelect(
        this.cd_empresa,
        435
      );
      this.dados_lookup_procedimento = JSON.parse(
        this.dados_lookup_procedimento.dataset
      );
      //////////////////////////
      this.dados_lookup_rota = await Lookup.montarSelect(this.cd_empresa, 5089);
      this.dados_lookup_rota = JSON.parse(this.dados_lookup_rota.dataset);
      //////////////////////////
      this.dados_lookup_api = await Lookup.montarSelect(this.cd_empresa, 5028);
      this.dados_lookup_api = JSON.parse(this.dados_lookup_api.dataset);
      this.dados_lookup_api = this.dados_lookup_api.map((i) => {
        i.nm_api = `${i.cd_api} - ${i.nm_api}`;
        return i;
      });
      //////////////////////////
    },
    async showMenu() {
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      localStorage.cd_parametro = 0;

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';
      //this.sParametroApi       = dados.nm_api_parametro;
      sParametroApi = dados.nm_api_parametro;

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa;
      this.exportar = false;
      this.qt_tempo = dados.qt_tempo_menu;
      this.ds_menu_descritivo = dados.ds_menu_descritivo;
      this.ic_form_menu = dados.ic_form_menu;
      this.ic_tipo_data_menu = dados.ic_tipo_data_menu;
      this.cd_tipo_email = dados.cd_tipo_email;
      this.cd_detalhe = dados.cd_detalhe;
      this.cd_menu_detalhe = dados.cd_menu_detalhe;
      this.cd_api_detalhe = dados.cd_api_detalhe;

      //this.cd_relatorio       = dados.cd_relatorio;

      if (this.ic_tipo_data_menu == "1") {
        this.hoje = " - " + new Date().toLocaleDateString();
      }
      if (this.ic_tipo_data_menu == "2" || this.ic_tipo_data_menu == "3") {
        this.hora = new Date().toLocaleTimeString().substring(0, 5);
      }

      if (dados.ic_exportacao == "S") {
        this.exportar = true;
      }

      localStorage.cd_tipo_consulta = 0;

      if (!dados.cd_tipo_consulta == 0) {
        localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.menu = dados.nm_menu;

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //

      //TabSheet
      this.tabs = [];
      //

      //Filtros

      this.filtro = [];

      //trocar para dados.laberFormFiltro
      //
    },

    async carregaDados() {
      localStorage.cd_identificacao = 0;
      await this.showMenu();

      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);
      //Gera os Dados para Montagem da Grid
      //exec da procedure

      let sApi = sParametroApi;
      if (!sApi == "") {
        !!this.cd_identificacao == true
          ? (localStorage.cd_identificacao = this.cd_identificacao)
          : "";
        let JSON_Config_Menu = {
          cd_parametro: 0,
          cd_usuario: this.cd_usuario,
        };

        this.dataSourceConfig = await Incluir.incluirRegistro(
          this.api,
          JSON_Config_Menu
        );
        this.items = JSON.parse(dados.labelForm);
      }
    },

    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;
      this.menu_select = data;

      this.nm_menu = data.nm_menu;
      this.nm_titulo = data.nm_menu_titulo;
      this.nivel_acesso = {
        cd_nivel_acesso: data.cd_nivel_acesso,
        nm_nivel_acesso: data.nm_nivel_acesso,
      };
      this.procedimento = {
        cd_procedimento: data.cd_procedimento,
        nm_procedimento: data.nm_procedimento,
      };
      this.rota = {
        cd_rota: data.cd_rota,
        nm_rota: data.nm_rota,
      };
      this.menu_api = {
        cd_api: data.cd_api,
        nm_api: data.nm_api,
      };
    },

    async RemoveMenu(e) {
      let JSON_Config_Menu = {
        cd_parametro: 3,
        cd_menu: e.data.cd_menu,
        cd_usuario: this.cd_usuario,
      };
      let [result_remove] = await Incluir.incluirRegistro(
        this.api,
        JSON_Config_Menu
      );
      notify(result_remove.Msg);
    },
    onExporting(e) {
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Consulta");

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
    limpaCampos() {
      ////Menu
      this.menu_select = "";
      this.nm_menu = "";
      this.nm_titulo = "";
      this.nivel_acesso = "";
      this.procedimento = "";
      this.rota = "";
      this.menu_api = "";
      this.lista_componentes = [];
      ////Componente
      this.limpaComponente();
    },
    limpaComponente() {
      this.componente_api = "";
      this.nm_texto = "";
      this.nm_texto_direita = "";
      this.cor = "";
      this.dense_comp = false;
      this.ic_grid_componente = false;
      this.nm_prefixo = "";
      this.nm_sufixo = "";
      this.ds_descritivo = "";
      this.nm_campo_valor = "";
      this.componente = [];
      this.icone = [];
      this.natureza = [];
      this.estilo = [];
      this.posicao = [];
      this.componente_edit = "";
      this.select = "";
      this.model = "";
      this.ic_pre_visualizacao = false;
    },
    async onNovo() {
      await this.limpaCampos();
      this.index = 1;
    },
    async onCancelar() {
      await this.limpaCampos();
      notify("Cancelado com sucesso!");
    },
    async onSalvar() {
      let JSON_salva_menu = {
        cd_usuario: this.cd_usuario,
        nm_menu: this.nm_menu,
        nm_titulo: this.nm_titulo,
        cd_nivel_acesso: this.nivel_acesso.cd_nivel_acesso,
        cd_procedimento: this.procedimento.cd_procedimento,
        cd_rota: this.rota.cd_rota,
        nm_rota: this.rota.nm_rota,
        cd_api: this.menu_api ? this.menu_api.cd_api : null,
        lista_componentes: this.lista_componentes,
      };

      if (this.menu_select.cd_menu) {
        JSON_salva_menu.cd_parametro = 1; //Atualizar
        JSON_salva_menu.cd_menu = this.menu_select.cd_menu;
      } else {
        JSON_salva_menu.cd_parametro = 2; //Inserir
      }
      console.log(JSON_salva_menu, "JSON PRA SALVAR/EDITAR");
      let [resultado_save] = await Incluir.incluirRegistro(
        this.api,
        JSON_salva_menu
      );
      console.log(resultado_save, "RESULTADO");
      notify(resultado_save.Msg);
    },
    //CRUD METHODS
    AddComponente() {
      if (this.componente.cd_componente === undefined) {
        notify("Selecione um componente para adicionar");
      } else {
        this.componente_edit = "";
        this.lista_componentes.push({
          nm_texto: this.nm_texto,
          nm_texto_direita: this.nm_texto_direita,
          dense: this.dense_comp,
          ic_grid_componente: this.ic_grid_componente,
          prefixo: this.nm_prefixo,
          sufixo: this.nm_sufixo,
          descritivo: this.ds_descritivo,
          nm_campo_valor: this.nm_campo_valor,
          ...this.componente_api,
          ...this.cor,
          ...this.componente,
          ...this.icone,
          ...this.natureza,
          ...this.estilo,
          ...this.posicao,
        });
      }
    },
    EditarComponente(item, index) {
      if (this.componente_edit.index === index) {
        this.componente_edit = "";
      } else {
        this.componente_edit = { ...item, index: index };
      }
      this.nm_texto = item.nm_texto;
      this.nm_texto_direita = item.nm_texto_direita;
      this.dense_comp = item.dense ? item.dense : false;
      this.ic_grid_componente = item.ic_grid_componente
        ? item.ic_grid_componente
        : false;
      this.nm_prefixo = item.prefixo;
      this.nm_sufixo = item.sufixo;
      this.ds_descritivo = item.descritivo;
      this.nm_campo_valor = item.nm_campo_valor;
      if (item.cd_api) {
        this.componente_api = {
          cd_api: item.cd_api,
          cd_procedimento: item.cd_procedimento,
          cd_tabela: item.cd_tabela,
          nm_api: item.nm_api,
          nm_identificacao_api: item.nm_identificacao_api,
        };
      } else {
        this.componente_api = "";
      }
      this.cor = {
        cd_cor: item.cd_cor,
        nm_cor: item.nm_cor,
        vl_cor: item.vl_cor,
      };

      this.componente = {
        cd_componente: item.cd_componente,
        nm_componente: item.nm_componente,
      };
      this.icone = {
        cd_icone: item.cd_icone,
        nm_icone: item.nm_icone,
        nm_icone_atributo: item.nm_icone_atributo,
      };
      this.natureza = {
        cd_natureza_atributo: item.cd_natureza_atributo,
        nm_natureza_atributo: item.nm_natureza_atributo,
        vl_natureza_atributo: item.vl_natureza_atributo,
      };
      this.estilo = {
        cd_estilo: item.cd_estilo,
        nm_estilo: item.nm_estilo,
      };
      this.posicao = {
        cd_posicao: item.cd_posicao,
        nm_posicao: item.nm_posicao,
      };
    },
    DeleteComponente(item) {
      if (item === undefined) {
        this.lista_componentes.pop();
      } else {
        this.lista_componentes = this.lista_componentes.filter(
          (it) => it != item
        );
      }
    },
    //COMPONENTS METHODS
    SelectComponente() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        ...this.componente,
      };
    },
    SelectIcones() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        ...this.icone,
      };
    },
    SelectCor() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        ...this.cor,
      };
    },
    TogglePopup() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        dense: this.dense_comp,
      };
    },
    ToggleBtn() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        ic_grid_componente: this.ic_grid_componente,
      };
    },
    onText() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        nm_texto: this.nm_texto,
      };
    },
    onTextDireita() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        nm_texto_direita: this.nm_texto_direita,
      };
    },
    SelectNatureza() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        ...this.natureza,
      };
    },
    SelectEstilo() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        ...this.estilo,
      };
    },
    onPrefixo() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        prefixo: this.nm_prefixo,
      };
    },
    onSufixo() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        sufixo: this.nm_sufixo,
      };
    },
    onDescritivo() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        descritivo: this.ds_descritivo,
      };
    },
    onValor() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        nm_campo_valor: this.nm_campo_valor,
      };
    },
    SelectApi() {
      this.lista_componentes[this.componente_edit.index] = {
        ...this.lista_componentes[this.componente_edit.index],
        ...this.componente_api,
      };
    },
    SelectPosicao() {
      //console.log("SELECIONOU POSICAO");
    },

    filterFnMenu(val, update) {
      update(() => {
        const needle = val.toLowerCase();
        if (val !== "") {
          this.dados_lookup_api_menu = this.dados_lookup_api.filter((v) => {
            return v.nm_api.toLowerCase().includes(needle) === true;
          });

          this.dados_lookup_api_menu = this.dados_lookup_api_menu.sort(
            function (a, b) {
              if (a.cd_api > b.cd_api) return -1;
              return 1;
            }
          );
        } else {
          this.dados_lookup_api_menu = this.dados_lookup_api;
          this.dados_lookup_api_menu = this.dados_lookup_api_menu.sort(
            function (a, b) {
              if (a.cd_api > b.cd_api) return -1;
              return 1;
            }
          );
        }
      });
    },
    filterFnComp(val, update) {
      update(() => {
        const needle = val.toLowerCase();
        if (val !== "") {
          this.dados_lookup_api_comp = this.dados_lookup_api.filter((v) => {
            return v.nm_api.toLowerCase().includes(needle) === true;
          });

          this.dados_lookup_api_comp = this.dados_lookup_api_comp.sort(
            function (a, b) {
              if (a.cd_api > b.cd_api) return -1;
              return 1;
            }
          );
        } else {
          this.dados_lookup_api_comp = this.dados_lookup_api;
          this.dados_lookup_api_comp = this.dados_lookup_api_comp.sort(
            function (a, b) {
              if (a.cd_api > b.cd_api) return -1;
              return 1;
            }
          );
        }
      });
    },
  },
};
</script>
<style scoped>
@import url("./views.css");
</style>
