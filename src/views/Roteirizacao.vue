<template>
  <div>
    <div
      class="text-h6 text-bold"
      style="margin: 10px 10px 5px 10px"
      v-if="diminuiTela == true"
    >
      {{ tituloMenu }}
    </div>

    <q-expansion-item
      class="text-bold text-h6 borda-bloco"
      v-model="expanded"
      v-if="diminuiTela == true"
      label="Parâmetros"
    >
      <q-card>
        <q-card-section>
          <div class="row">
            <div class="col items-center text-bold">
              <q-input
                v-model="dt_entrega_inicial"
                mask="##/##/####"
                @blur="onValueChanged($event)"
                color="black"
                class="response padding-comp"
                label="Data Inicial"
              >
                <template v-slot:append>
                  <q-icon name="event" class="cursor-pointer" color="orange-10">
                    <q-popup-proxy
                      ref="qDateProxy"
                      cover
                      transition-show="scale"
                      transition-hide="scale"
                    >
                      <q-date
                        v-model="dt_entrega_inicial"
                        mask="DD/MM/YYYY"
                        color="orange-10"
                        @blur="onValueChanged($event)"
                        class="qdate"
                      >
                        <div class="row items-center justify-end">
                          <q-btn
                            v-close-popup
                            round
                            color="orange-10"
                            @blur="onValueChanged($event)"
                            icon="close"
                            size="sm"
                          />
                        </div>
                      </q-date>
                    </q-popup-proxy>
                  </q-icon>
                </template>
              </q-input>
              <q-input
                v-model="dt_entrega_final"
                mask="##/##/####"
                @blur="onValueChanged($event)"
                color="black"
                class="response padding-comp"
                label="Data Final"
              >
                <template v-slot:append>
                  <q-icon name="event" class="cursor-pointer" color="orange-10">
                    <q-popup-proxy
                      ref="qDateProxy"
                      cover
                      transition-show="scale"
                      transition-hide="scale"
                    >
                      <q-date
                        v-model="dt_entrega_final"
                        mask="DD/MM/YYYY"
                        color="orange-10"
                        @blur="onValueChanged($event)"
                        class="qdate"
                      >
                        <div class="row items-center justify-end">
                          <q-btn
                            v-close-popup
                            round
                            color="orange-10"
                            @blur="onValueChanged($event)"
                            icon="close"
                            size="sm"
                          />
                        </div>
                      </q-date>
                    </q-popup-proxy>
                  </q-icon>
                </template>
              </q-input>
            </div>

            <q-select
              label="Origem"
              class="col padding-comp"
              v-model="empresa_faturamento"
              input-debounce="0"
              :options="this.dataset_empresa_faturamento"
              option-value="cd_empresa"
              option-label="nm_empresa"
            >
              <template v-slot:prepend>
                <q-icon name="store" />
              </template>
            </q-select>
          </div>

          <div class="row">
            <q-select
              label="Entregador"
              class="col padding-comp"
              v-model="entregador"
              input-debounce="0"
              :options="this.dataset_entregador"
              option-value="cd_entregador"
              option-label="nm_entregador"
              @input="SelecionaItinerario(itinerario)"
            >
              <!--@input="SelecionaEntregador(cd_entregador)"-->
              <template v-slot:prepend>
                <q-icon name="face" />
              </template>
            </q-select>
            <q-select
              label="Itinerário"
              v-model="itinerario"
              id="itin"
              class="col padding-comp"
              input-debounce="0"
              :options="this.dataset_itinerario"
              option-value="cd_itinerario"
              option-label="nm_itinerario"
              @input="SelecionaItinerario(itinerario)"
            >
              <template v-slot:prepend>
                <q-icon name="map" />
              </template>
            </q-select>
          </div>

          <div class="row">
            <div class="buttons-column col">
              <q-btn
                style="float: left; margin: 0.1vw"
                size="sm"
                @click="onClickRoteiro()"
                round
                color="warning"
                icon="directions"
              >
                <q-tooltip transition-show="scale" transition-hide="scale">
                  Confirmar roteiro
                </q-tooltip>
              </q-btn>

              <q-btn
                style="float: left; margin: 0.1vw"
                size="sm"
                @click="onClickConsultaRoteiro()"
                round
                color="primary"
                icon="query_stats"
              >
                <q-tooltip transition-show="scale" transition-hide="scale">
                  Consulta de Roteiro
                </q-tooltip>
              </q-btn>

              <q-btn
                style="float: left; margin: 0.1vw"
                size="sm"
                @click="onClickConsultaGrid()"
                round
                color="orange-10"
                icon="toc"
              >
                <q-tooltip transition-show="scale" transition-hide="scale">
                  Consultar roteiros do dia: {{ dt_entrega_inicial }} até
                  {{ dt_entrega_final }}
                </q-tooltip>
              </q-btn>
            </div>
            <div class="buttons-column col">
              <q-btn
                style="float: right; margin: 0.1vw"
                size="sm"
                @click="clearSelection()"
                round
                color="negative"
                icon="delete"
              >
                <q-tooltip transition-show="scale" transition-hide="scale">
                  Deletar
                </q-tooltip>
              </q-btn>
            </div>
          </div>
        </q-card-section>
      </q-card>
    </q-expansion-item>

    <q-expansion-item
      class="text-bold text-h6 borda-bloco"
      v-model="expanded_map"
      label="Roteiro"
    >
      <q-card>
        <div class="row">
          <q-input
            v-model="p_cd_romaneio"
            @blur="AcrescentaRomaneio()"
            class="response padding-comp margin1"
            style="margin: 0 5px 5px 15px"
            label="Romaneio"
          >
            <template v-slot:prepend>
              <q-icon name="bookmark" />
            </template>
            <template v-slot:append>
              <q-btn
                round
                color="primary"
                icon="search"
                size="sm"
                @click="AcrescentaRomaneio()"
              />
              <q-icon
                v-if="p_cd_romaneio !== ''"
                name="close"
                @click.stop="p_cd_romaneio = ''"
                class="cursor-pointer"
              ></q-icon>
            </template>
          </q-input>
        </div>
        <div class="row">
          <div class="col-3">
            <div style="margin: 0 5px 5px 15px" class="text-bold text-h6">
              Romaneios
              <q-badge
                v-if="this.dataSourceConfig.length > 0"
                align="top"
                color="orange-10"
                rounded
              >
                {{ dataSourceConfig.length }}
              </q-badge>
              <q-btn
                v-if="this.dataSourceConfig.length > 0"
                round
                color="primary"
                icon="east"
                size="sm"
                style="float: right; margin: 0 5px 5px 15px"
                @click="EnviaTodos()"
              >
                <q-tooltip>Enviar todos</q-tooltip>
              </q-btn>
            </div>

            <DxScrollView id="scrollview" show-scrollbar="always">
              <div v-for="(e, index) in 1" :key="index" class="list">
                <DxSortable
                  :data="dataSourceConfig"
                  class="sortable-cards"
                  group="tasksGroup"
                  @drag-start="onTaskDragStart($event)"
                  @reorder="ReordenaColuna(dataSourceConfig)"
                  @add="onTaskDrop($event)"
                >
                  <div
                    v-for="task in dataSourceConfig"
                    v-on:dblclick="dbClick(task, dataSourceConfig)"
                    :key="task.cd_controle"
                    class="card dx-card dx-theme-text-color dx-theme-background-color"
                  >
                    <div class="row justify-between">
                      <div class="col-9 text-subtitle2 text-bold text-blue-8">
                        {{ task.nm_razao_social_cliente }}
                      </div>
                      <div class="col-3 text-subtitle2 text-bold">
                        <q-badge
                          class="esquerda"
                          rounded
                          color="primary"
                          text-color="white"
                          :label="task.cd_romaneio"
                        />
                      </div>
                    </div>

                    <q-separator />
                    <div
                      class="row text-subtitle2 text-bold"
                      style="margin: 3px"
                    >
                      {{ task.nm_endereco_apresenta }}
                    </div>
                    <div
                      class="row text-subtitle2 text-bold"
                      style="margin: 3px"
                    >
                      <div class="col-11">CEP: {{ task.cd_cep }}</div>

                      <div class="col-1 items-center">
                        <q-btn
                          round
                          color="negative"
                          size="xs"
                          icon="autorenew"
                          v-if="task.cd_cep == '00000000'"
                          @click="TrocaCep(task.cd_romaneio)"
                        >
                          <q-tooltip>Alterar CEP</q-tooltip>
                        </q-btn>
                      </div>
                    </div>
                    <div
                      class="row text-subtitle2 text-bold"
                      style="margin: 3px"
                      v-if="!task.hr_entrega == ''"
                    >
                      Previsão: {{ task.hr_entrega }}
                    </div>

                    <div
                      class="row text-subtitle2 text-bold"
                      style="margin: 3px"
                      v-if="!task.nm_obs_romaneio == ''"
                    >
                      Obs: {{ task.nm_obs_romaneio }}
                    </div>
                  </div>
                </DxSortable>
              </div>
            </DxScrollView>
          </div>

          <div style="height: 65vw" class="col-6">
            <div style="margin: 0 5px 5px 15pxF" class="text-bold text-h6">
              Mapa
            </div>
            <div
              id="mapaR"
              style="height: 65vw"
              v-if="this.ic_altera_sede == true"
            >
              <mapaRoteiro
                v-if="
                  this.controla_mapa == false && this.ic_altera_sede == true
                "
                id="maparoteiro"
                :selecaoID="this.destinos"
                :origemID="this.origem"
                @pinPoint="DataPin($event)"
                style="height: 60vw"
              >
              </mapaRoteiro>
            </div>
          </div>
          <q-dialog
            v-model="popup_mapa"
            persistent
            :maximized="maximizedToggle"
            transition-show="slide-up"
            transition-hide="slide-down"
          >
            <q-card>
              <q-bar class="bg-deep-orange-3 text-white">
                Mapa de Roteirização
                <q-space />

                <q-btn
                  dense
                  flat
                  icon="minimize"
                  @click="maximizedToggle = false"
                  :disable="!maximizedToggle"
                >
                  <q-tooltip v-if="maximizedToggle" class="bg-orange text-white"
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
                    class="bg-orange text-white"
                    >Maximizar</q-tooltip
                  >
                </q-btn>
                <q-btn dense flat icon="close" v-close-popup>
                  <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
                </q-btn>
              </q-bar>

              <q-card-section class="q-pt-none">
                <mapaRoteiro :selecaoID="this.pin" :origemID="this.origem">
                </mapaRoteiro>
              </q-card-section>
            </q-card>
          </q-dialog>
          <div class="col-3">
            <div style="margin: 0 5px 5px 15px" class="text-bold text-h6">
              <q-btn
                v-if="this.pin.length > 0"
                round
                color="red"
                icon="west"
                size="sm"
                @click="VoltarTodos()"
              >
                <q-tooltip>Desfazer rotas</q-tooltip>
              </q-btn>

              <div style="float: right; margin: 0 15px 0 0">
                <q-badge
                  v-if="this.pin.length > 0"
                  align="top"
                  color="orange-10"
                  rounded
                >
                  {{ pin.length }}
                </q-badge>
                Entregas
              </div>
            </div>
            <DxScrollView id="scrollview" show-scrollbar="always">
              <div v-for="(e, index) in 1" :key="index" class="list">
                <DxSortable
                  :data="pin"
                  class="sortable-cards"
                  group="tasksGroup"
                  @drag-start="onTaskDragStart2($event)"
                  @reorder="ReordenaRota($event)"
                  @add="onTaskDrop2($event)"
                >
                  <div
                    v-for="task in pin"
                    v-on:dblclick="dbClick2(task, pin)"
                    :key="task.cd_controle"
                    class="card dx-card dx-theme-text-color dx-theme-background-color"
                  >
                    <div class="row justify-between">
                      <div class="col-9 text-subtitle2 text-bold text-blue-8">
                        {{ task.nm_razao_social_cliente }}
                      </div>
                      <div class="col-3 text-subtitle2 text-bold">
                        <q-badge
                          class="esquerda"
                          rounded
                          color="primary"
                          text-color="white"
                          :label="task.cd_romaneio"
                        />
                      </div>
                    </div>

                    <div class="col text-subtitle2 text-bold">
                      <q-badge
                        style="margin-top: 3px"
                        class="esquerda"
                        rounded
                        color="negative"
                        text-color="white"
                        :label="task.qt_ordem_selecao"
                      />
                    </div>
                    <q-separator />
                    <div
                      class="row text-subtitle2 text-bold"
                      style="margin: 3px"
                    >
                      {{ task.nm_endereco_apresenta }}
                    </div>
                    <div
                      class="row text-subtitle2 text-bold"
                      style="margin: 3px"
                    >
                      CEP: {{ task.cd_cep }}
                    </div>
                    <div
                      class="row text-subtitle2 text-bold"
                      style="margin: 3px"
                      v-if="!task.hr_entrega == ''"
                    >
                      Entrega: {{ task.hr_entrega }}
                    </div>

                    <div
                      class="row text-subtitle2 text-bold"
                      style="margin: 3px"
                      v-if="!task.nm_obs_romaneio == ''"
                    >
                      Obs: {{ task.nm_obs_romaneio }}
                    </div>
                    <div
                      class="row text-subtitle2 text-bold"
                      style="margin: 3px"
                      v-if="!task.distancia == ''"
                    >
                      Distancia: {{ task.distancia }}
                    </div>
                    <div
                      class="row text-subtitle2 text-bold"
                      style="margin: 3px"
                      v-if="!task.tempo == ''"
                    >
                      Tempo: {{ task.tempo }}
                    </div>
                  </div>
                </DxSortable>
              </div>
            </DxScrollView>
          </div>
        </div>
      </q-card>
    </q-expansion-item>

    <q-expansion-item
      class="text-bold text-h6 borda-bloco"
      v-model="expanded_grid"
      label="Consulta"
    >
      <div class="row borda-bloco">
        <dx-data-grid
          class="dx-card wide-card-d"
          id="grid-padrao"
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
          :ref="dataGridRefName"
          @exporting="onExporting"
          @initialized="saveGridInstance"
          @selection-Changed="LinhaSelecionada"
        >
          <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
          <DxGrouping :auto-expand-all="true" />
          <DxExport :enabled="true" />

          <DxPaging :enable="true" :page-size="10" />
          <DxEditing :allow-updating="false" mode="popup">
            <DxPopup
              :show-title="true"
              :width="700"
              :height="525"
              title="Romaneio"
            />
          </DxEditing>
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
        </dx-data-grid>
      </div>
    </q-expansion-item>
    <q-dialog v-model="load" maximized persistent>
      <carregando :mensagemID="mensagem"></carregando>
    </q-dialog>
    <!------------------------------------------------------------------------------------>

    <q-dialog
      v-model="popup_roteirizacao"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-3 text-white">
          Consulta de Roteirização
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white"
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
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section class="row">
          <div class="col-3">
            <div style="margin: 0 5px 5px 15px" class="text-bold text-h6 col-3">
              Romaneios em aberto
              <q-badge
                v-if="this.dataSourceConfig.length > 0"
                align="top"
                color="orange-10"
                rounded
              >
                {{ dataSourceConfig.length }}
              </q-badge>
            </div>

            <DxScrollView id="scrollview" show-scrollbar="always">
              <div v-for="(e, index) in 1" :key="index" class="list">
                <DxSortable
                  :data="dataSourceConfig"
                  class="sortable-cards"
                  group="tasksGroup"
                  @drag-start="onTaskDragStart($event)"
                  @reorder="ReordenaColuna(dataSourceConfig)"
                  @add="ExcluiRoteiro($event)"
                >
                  <div
                    v-for="task in dataSourceConfig"
                    :key="task.cd_controle"
                    class="card dx-card dx-theme-text-color dx-theme-background-color"
                  >
                    <div class="row text-center justify-between">
                      <div class="col-9 text-body2 text-bold text-blue-8">
                        {{ task.nm_razao_social_cliente }}
                      </div>
                      <div class="col items-center row text-body2 text-bold">
                        <div class="col items-center">
                          <q-badge
                            class="esquerda items-center"
                            rounded
                            color="primary"
                            text-color="white"
                            :label="task.cd_romaneio"
                          />
                        </div>
                      </div>
                    </div>

                    <q-separator />
                    <div class="row text-bold" style="margin: 3px">
                      CEP: {{ task.cd_cep }}
                    </div>
                    <div
                      class="row text-bold"
                      style="margin: 3px"
                      v-if="!task.nm_endereco_apresenta == ''"
                    >
                      {{ task.nm_endereco_apresenta }}
                      <!--- -->
                    </div>
                    <div
                      class="row text-body2 text-bold"
                      style="margin: 3px"
                      v-else
                    >
                      {{ task.nm_endereco }} - {{ task.cd_numero }} -
                      {{ task.nm_bairro }} - {{ task.nm_cidade }}/{{
                        task.sg_estado
                      }}
                      - {{ task.nm_complemento }}
                    </div>

                    <div
                      class="row text-bold"
                      style="margin: 3px"
                      v-if="!task.nm_obs_romaneio == ''"
                    >
                      Obs: {{ task.nm_obs_romaneio }}
                    </div>
                  </div>
                </DxSortable>
              </div>
            </DxScrollView>
          </div>

          <div class="col-6">
            <div style="margin: 0 5px 5px 15px" class="text-bold text-h6">
              Mapa
            </div>
            <mapaRoteiro
              v-if="controla_mapa == true"
              id="maparoteiro"
              :selecaoID="this.roteiros"
              :origemID="this.origem"
              style="height: 60vw"
              :directionRenderer="true"
            >
            </mapaRoteiro>
          </div>

          <div class="col-3">
            <div style="margin: 0 5px 5px 15px" class="text-bold text-h6">
              Roteirizações feitas
              <q-badge
                v-if="this.roteiros.length > 0"
                align="top"
                color="orange-10"
                rounded
              >
                {{ roteiros.length }}
              </q-badge>
            </div>
            <DxScrollView id="scrollview" show-scrollbar="always">
              <div v-for="(e, index) in 1" :key="index" class="list">
                <DxSortable
                  :data="roteiros"
                  class="sortable-cards"
                  group="tasksGroup"
                  @drag-start="onTaskDragStart($event)"
                  @reorder="RotasProntas($event)"
                  @add="AdicionaRoteiro($event)"
                >
                  <div
                    v-for="task in roteiros"
                    :key="task.cd_controle"
                    class="card dx-card dx-theme-text-color dx-theme-background-color"
                  >
                    <div class="row text-center justify-between">
                      <div class="col-6 text-body2 text-bold text-blue-8">
                        {{ task.nm_razao_social_cliente }}
                      </div>
                      <div class="col items-center row text-body2 text-bold">
                        <div class="col items-start">
                          <q-badge
                            class="esquerda items-start"
                            rounded
                            color="negative"
                            text-color="white"
                            :label="task.qt_ordem_selecao"
                          />
                        </div>
                        <div class="col items-center">
                          <q-badge
                            class="esquerda items-center"
                            rounded
                            color="primary"
                            text-color="white"
                            :label="task.cd_romaneio"
                          />
                        </div>
                      </div>
                    </div>

                    <q-separator />
                    <div
                      class="row text-body2 text-bold"
                      style="margin: 3px"
                      v-if="!task.nm_usuario == ''"
                    >
                      Registro: {{ task.nm_usuario }}
                    </div>

                    <div class="row text-body2 text-bold" style="margin: 3px">
                      CEP: {{ task.cd_cep }}
                    </div>

                    <div
                      class="row text-body2 text-bold"
                      style="margin: 3px"
                      v-if="
                        !task.nm_endereco_apresenta == '' ||
                        !task.nm_endereco_apresenta == undefined
                      "
                    >
                      {{ task.nm_endereco_apresenta }}
                    </div>
                    <div
                      class="row text-body2 text-bold"
                      style="margin: 3px"
                      v-else
                    >
                      {{ task.nm_endereco }} - {{ task.cd_numero }} -
                      {{ task.nm_bairro }} - {{ task.nm_cidade }}/{{
                        task.sg_estado
                      }}
                      - {{ task.nm_complemento }}
                    </div>

                    <div
                      class="row text-bold"
                      style="margin: 3px"
                      v-if="!task.nm_obs_romaneio == ''"
                    >
                      Obs: {{ task.nm_obs_romaneio }}
                    </div>
                  </div>
                </DxSortable>
              </div>
            </DxScrollView>
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------------------------------>
    <q-dialog
      v-model="popup_altera_cep"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-3 text-white">
          <div class="">Romaneio</div>
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white"
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
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section class="margin1">
          <romaneioF :cd_romaneioID="cd_romaneioID" />
        </q-card-section>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------------------------------>
    <q-dialog
      v-model="popup_consulta_roteiros"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-3 text-white">
          <div class="">Roteiros</div>
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white"
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
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section class="margin1">
          <grid
            :cd_menuID="7366"
            :cd_apiID="639"
            :cd_parametroID="0"
            :cd_consulta="1"
            :nm_json="this.json_c"
            ref="grid_c"
          >
          </grid>
        </q-card-section>
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
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxStateStoring,
  DxSearchPanel,
  DxEditing,
  DxPopup,
} from "devextreme-vue/data-grid";

import Incluir from "../http/incluir_registro";

import romaneioF from "../views/romaneio.vue";
import notify from "devextreme/ui/notify";
import formataData from "../http/formataData";

import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import Lookup from "../http/lookup";
import grid from "../views/grid";
import mapaRoteiro from "../views/ferramentaRoteiro";
import carregando from "../components/carregando.vue";
import { DxScrollView } from "devextreme-vue/scroll-view";
import { DxSortable } from "devextreme-vue/sortable";
import dataEscrita from "../http/dataEscrita";

const romaneio = new Map();

let cd_empresa = 0;
let cd_menu = 0;
let cd_cliente = 0;
let cd_api = 0;
let api = "";

let filename = "DataGrid.xlsx";

let dados = [];
var sParametroApi = "";

export default {
  data() {
    return {
      consulta_grid: {},
      dt_entrega: "",
      dt_entrega_inicial: "",
      dt_entrega_final: "",
      tituloMenu: "",
      popup_altera_cep: false,
      dataSourceRoteirizacao: [],
      linhaSelecionadax: 0,
      arraySelecionada: [],
      columns: [],
      pageSizes: [10, 20, 50, 100],
      p_cd_romaneio: "",
      dataSourceConfig: [],
      popup_consulta_roteiros: false,
      total: {},
      mensagem: "",
      dataGridInstance: null,

      dataGridRefName: "dataGrid",
      //  ENTREGADOR
      entregador: {},
      dataset_entregador: [],
      //  ITINERÁRIO
      itinerario: "",
      dataset_itinerario: [],
      expanded: true,
      itinerario_hora: "",
      cd_romaneioID: "0",
      diminuiTela: true,
      cd_usuario: 0,
      cd_romaneio: "",
      hora_atual: "",
      target: false,
      roteiros: {},
      popup_mapa: false,
      popup_roteirizacao: false,
      mostra_mapa: false,
      maximizedToggle: true,
      dataset_empresa_faturamento: [],
      empresa_faturamento: "",
      pin: [],
      destinos: [],
      expanded_grid: false,
      json_c: {},
      controla_mapa: false,
      titulo_card: "",
      ic_altera_sede: true,
      card_pop_titulo: "",
      lista_itinerario: [],
      load: false,
      expanded_map: true,
      origem: {
        qt_latitude: 0,
        qt_longitude: 0,
      },
    };
  },
  async beforeCreate() {
    let dados_empresa_faturamento = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5137
    );
    this.dataset_empresa_faturamento = JSON.parse(
      JSON.parse(JSON.stringify(dados_empresa_faturamento.dataset))
    );
    this.empresa_faturamento = this.dataset_empresa_faturamento.filter(
      (value) => {
        if (value.ic_padrao_empresa == "S") return value;
      }
    )[0];
    if (this.dataset_empresa_faturamento.length > 1) {
      this.dataset_empresa_faturamento = this.dataset_empresa_faturamento.sort(
        function (a, b) {
          if (a.nm_empresa < b.nm_empresa) return -1;
          return 1;
        }
      );
    }
    if (this.dataset_empresa_faturamento.length == 1) {
      this.empresa_faturamento = {
        cd_empresa: this.dataset_empresa_faturamento[0].cd_empresa,
        nm_empresa: this.dataset_empresa_faturamento[0].nm_empresa,
        qt_latitude: this.dataset_empresa_faturamento[0].qt_latitude,
        qt_longitude: this.dataset_empresa_faturamento[0].qt_longitude,
      };
    }
  },
  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    var str_data = dataEscrita.DataHoje();
    this.dt_entrega_inicial = str_data;
    this.dt_entrega_final = str_data;
    localStorage.dt_base = formataData.formataDataSQL(str_data);

    await this.carregaDados();

    this.cd_usuario = localStorage.cd_usuario;
    this.entregador = "";
    this.titulo_card = "Entregas";

    let dados_itinerario = await Lookup.montarSelect(
      localStorage.cd_empresa,
      495
    );
    this.dataset_itinerario = JSON.parse(
      JSON.parse(JSON.stringify(dados_itinerario.dataset))
    );

    let dados_entregador = await Lookup.montarSelect(
      localStorage.cd_empresa,
      240
    );
    this.dataset_entregador = JSON.parse(
      JSON.parse(JSON.stringify(dados_entregador.dataset))
    );

    var filtrado_ativo = this.dataset_entregador.filter((value) => {
      if (value.ic_ativo_entregador == "S") return value;
    });
    this.dataset_entregador = filtrado_ativo.sort(function (a, b) {
      if (a.nm_entregador < b.nm_entregador) return -1;
      return 1;
    });

    if (this.dataset_entregador.length == 1) {
      this.entregador = {
        cd_entregador: this.dataset_entregador[0].cd_entregador,
        nm_entregador: this.dataset_entregador[0].nm_entregador,
      };
    }

    if (this.dataset_itinerario.length == 1) {
      this.itinerario = {
        cd_itinerario: this.dataset_itinerario[0].cd_itinerario,
        nm_itinerario: this.dataset_itinerario[0].nm_itinerario,
      };
    }

    var h = new Date().toLocaleTimeString();
    this.hora_atual = h.substring(0, 5);
    this.mostra_mapa = false;
    this.mostra_mapa = true;
  },

  components: {
    romaneioF,
    grid,
    DxDataGrid,
    DxFilterRow,
    DxSortable,
    DxScrollView,
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
    DxEditing,
    DxPopup,
    mapaRoteiro,
    carregando,
  },
  watch: {
    async empresa_faturamento() {
      this.ic_altera_sede = false;
      this.origem.qt_latitude = this.empresa_faturamento.qt_latitude;
      this.origem.qt_longitude = this.empresa_faturamento.qt_longitude;
      if (
        this.origem.qt_latitude === undefined ||
        this.origem.qt_longitude === undefined
      ) {
        notify("Erro ao encontrar o endereço da origem!");
        return;
      }
      await this.sleep(1000);
      this.ic_altera_sede = true;
    },
    popup_altera_cep(Novo) {
      if (Novo == false) {
        this.carregaDados();
      }
    },
    pin() {
      this.destinos = this.pin;
    },
    popup_roteirizacao(a, b) {
      if (a == false) {
        this.controla_mapa = false;

        this.onValueChanged();
      } else if (b == true) {
        //this.maparoteiro.calculaRota();
      }
    },
  },

  methods: {
    async TrocaCep(cd_romaneio) {
      this.cd_romaneioID = cd_romaneio + "";
      this.popup_altera_cep = true;
    },

    DataPin(e) {
      e[0].routes[0].legs.map((p, i) => {
        if (this.pin.length - 1 >= i) {
          this.pin[i].distancia = p.distance.text;
          this.pin[i].tempo = p.duration.text;
        }
      });
    },

    async onClickConsultaGrid() {
      let d = formataData.formataDataSQL(this.dt_entrega_inicial);
      let f = formataData.formataDataSQL(this.dt_entrega_final);
      this.json_c = {
        cd_parametro: 6,
        dt_roteiro: d,
        dt_final: f,
        cd_usuario: localStorage.cd_usuario,
      };
      this.popup_consulta_roteiros = true;
    },
    VoltarTodos() {
      for (let a = 0; a < this.pin.length; a++) {
        this.dataSourceConfig.push(this.pin[a]);
      }
      this.pin = [];
      this.ReordenaColuna(this.dataSourceConfig);
    },
    EnviaTodos() {
      if (this.empresa_faturamento == "" || this.empresa_faturamento == null) {
        notify("Selecione a Origem!");
        return;
      } else if (this.entregador == "" || this.entregador == null) {
        notify("Selecione o Entregador!");
        return;
      } else if (this.itinerario == "" || this.itinerario == null) {
        notify("Selecione o Itinerário!");
        return;
      }
      for (let a = 0; a < this.dataSourceConfig.length; a++) {
        this.pin.push(this.dataSourceConfig[a]);
      }

      //this.pin = this.dataSourceConfig;
      this.dataSourceConfig = [];
      for (let o = 0; o < this.pin.length; o++) {
        this.pin[o].qt_ordem_selecao = o + 1;
      }
    },
    sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },
    async AbreConsulta() {
      if (this.dt_entrega_inicial.length !== 10) {
        notify("Revise a data selecionada!");
        return;
      }

      let d = formataData.formataDataSQL(this.dt_entrega_inicial);
      let f = formataData.formataDataSQL(this.dt_entrega_final);
      let c = {
        cd_parametro: 6,
        dt_roteiro: d,
        dt_final: f,
      };
      var iti = "639/904";
      this.lista_itinerario = await Incluir.incluirRegistro(iti, c);
      if (this.lista_itinerario[0].Cod == 0) {
        notify(this.lista_itinerario[0].Msg);
        this.lista_itinerario = [];
        return;
      }
      this.target = true;

      let i = document.getElementById("itin");
      i.focus();
    },
    async FechaConsulta() {
      await this.sleep(2500);
      this.target = false;
      let i = document.getElementById("itin");
      i.focus();
    },
    async AcrescentaRomaneio() {
      if (this.p_cd_romaneio == "") return;

      if (this.empresa_faturamento == "" || this.empresa_faturamento == null) {
        notify("Selecione a Origem!");
        return;
      } else if (this.entregador == "" || this.entregador == null) {
        notify("Selecione o Entregador!");
        return;
      } else if (this.itinerario == "" || this.itinerario == null) {
        notify("Selecione o Itinerário!");
        return;
      }

      if (this.dataSourceConfig.length == 0) {
        notify("Dia sem romaneios!");
        return;
      }
      //Se for mais de um Romaneio
      if (this.p_cd_romaneio.includes(",")) {
        var filtrado_index = this.p_cd_romaneio.split(",");
        var filtrado_info = this.dataSourceConfig.filter((element) =>
          filtrado_index.includes(element.cd_romaneio.toString())
        );
        this.dataSourceConfig = this.dataSourceConfig.filter(
          (element) => !filtrado_index.includes(element.cd_romaneio.toString())
        );
        this.pin.push(...filtrado_info);
        localStorage.cd_identificacao = filtrado_info[0].cd_romaneio;
      } else {
        //Se for apenas um Romaneio
        var filtrado = this.dataSourceConfig.find(
          (element) => element.cd_romaneio == this.p_cd_romaneio
        );
        let index = this.dataSourceConfig.findIndex(
          (element) => element.cd_romaneio == this.p_cd_romaneio
        );
        this.dataSourceConfig.splice(index, 1);
        localStorage.cd_identificacao = filtrado.cd_romaneio;
        this.pin.push(filtrado);
      }
      if (filtrado !== undefined || filtrado_info.length > 0) {
        for (let y = 0; y < this.pin.length; y++) {
          this.pin[y].qt_ordem_selecao = y + 1;
        }
        for (let i = 0; i < this.dataSourceConfig.length; i++) {
          this.dataSourceConfig[i].qt_ordem_selecao = i + 1;
        }

        localStorage.cd_parametro = 1;
        localStorage.cd_tipo_consulta = this.itinerario.cd_itinerario;
        localStorage.cd_entregador = this.entregador.cd_entregador;
        localStorage.cd_empresa_fat = this.empresa_faturamento.cd_empresa;
        localStorage.qt_ordem = this.pin[this.pin.length - 1].qt_ordem_selecao;
        let dataSourceRomaneio = [];
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 634);
        api = dados.nm_identificacao_api;
        let sParametroApi = dados.nm_api_parametro;
        dataSourceRomaneio = await Procedimento.montarProcedimento(
          localStorage.cd_empresa,
          0,
          api,
          sParametroApi
        );
        this.mostra_mapa = false;
        this.destinos = this.pin;

        this.mostra_mapa = true;
        this.p_cd_romaneio = "";
      } else {
        notify("Romaneio não encontrado!");
      }
    },
    onValueChanged() {
      let diaSelect = this.dt_entrega_inicial.slice(0, 2);
      let mesSelect = this.dt_entrega_inicial.slice(3, 5);
      let anoSelect = this.dt_entrega_inicial.slice(6, 11);
      this.dt_entrega_inicial = diaSelect + "/" + mesSelect + "/" + anoSelect;
      localStorage.dt_base = mesSelect + "-" + diaSelect + "-" + anoSelect;
      localStorage.dt_inicial = mesSelect + "-" + diaSelect + "-" + anoSelect;
      let diaF = this.dt_entrega_final.slice(0, 2);
      let mesF = this.dt_entrega_final.slice(3, 5);
      let anoF = this.dt_entrega_final.slice(6, 11);
      localStorage.dt_final = mesF + "-" + diaF + "-" + anoF;
      this.carregaDados();
    },

    onTaskDragStart(e) {
      //e.itemData = e.fromData[e.fromIndex].cd_etapa;
      e.itemData = e.fromData[e.fromIndex];
    },
    onTaskDragStart2(e) {
      //e.itemData = e.fromData[e.fromIndex].cd_etapa;
      e.itemData = e.fromData[e.fromIndex];
    },
    async RotasProntas(e) {
      e.fromData.splice(e.fromIndex, 1);
      e.toData.splice(e.toIndex, 0, e.itemData);

      for (let o = 0; o < this.roteiros.length; o++) {
        this.roteiros[o].qt_ordem_selecao = o + 1;
        if (this.roteiros[o].nm_usuario == undefined) {
          this.roteiros[o].nm_usuario == localStorage.usuario;
        }
      }
      var dt = formataData.formataDataSQL(this.dt_entrega_inicial);
      var dt_final = formataData.formataDataSQL(this.dt_entrega_final);
      for (let g = 0; g < this.roteiros.length; g++) {
        let l = {
          cd_usuario: this.cd_usuario,
          cd_parametro: 2,
          cd_romaneio: this.roteiros[g].cd_romaneio,
          qt_ordem_selecao: this.roteiros[g].qt_ordem_selecao,
          hr_selecao: this.roteiros[g].hr_selecao,
          cd_entregador: this.roteiros[g].cd_entregador,
          cd_itinerario: this.roteiros[g].cd_itinerario,
          dt_selecao: dt,
          dt_final: dt_final,
          cd_romaneio: this.roteiros[g].cd_romaneio,
        };
        var iti = "639/904";
        await Incluir.incluirRegistro(iti, l);
      }
    },
    async onTaskDrop(e) {
      e.fromData.splice(e.fromIndex, 1);
      e.toData.splice(e.toIndex, 0, e.itemData);
      for (let i = 0; i < this.dataSourceConfig.length; i++) {
        this.dataSourceConfig[i].qt_ordem_selecao = i + 1;
      }
      for (let y = 0; y < this.pin.length; y++) {
        this.pin[y].qt_ordem_selecao = y + 1;
      }
      this.ReordenaColuna(this.dataSourceConfig);
      e.itemData.cd_etapa = 2;
      localStorage.cd_parametro = 2;
      localStorage.cd_tipo_consulta = this.itinerario.cd_itinerario;
      localStorage.cd_identificacao = e.itemData.cd_romaneio;
      localStorage.cd_entregador = this.entregador.cd_entregador;
      localStorage.cd_empresa_fat = this.empresa_faturamento.cd_empresa;
      if (this.pin.length == 0) {
        localStorage.qt_ordem = 99999;
      } else {
        localStorage.qt_ordem = this.pin[this.pin.length - 1].qt_ordem_selecao;
      }
      let dataSourceRomaneio = [];
      dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 634);
      api = dados.nm_identificacao_api;
      let sParametroApi = dados.nm_api_parametro;
      dataSourceRomaneio = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        0,
        api,
        sParametroApi
      );
    },
    async RordenaBanco() {
      var iti = "639/904";
      if (this.pin.length > 0) {
        let or = 1;
        for (let o = 0; o < this.pin.length; o++) {
          this.pin[o].qt_ordem_selecao = or;
          let up = {
            cd_parametro: 4,
            cd_romaneio: this.pin[o].cd_romaneio,
            qt_ordem_selecao: this.pin[o].qt_ordem_selecao,
          };
          let ordem = await Incluir.incluirRegistro(iti, up);
          or = or + 1;
        }
      }
    },
    async ReordenaRota(e) {
      e.fromData.splice(e.fromIndex, 1);
      e.toData.splice(e.toIndex, 0, e.itemData);

      for (let o = 0; o < this.pin.length; o++) {
        this.pin[o].qt_ordem_selecao = o + 1;
      }
    },

    async onTaskDrop2(e) {
      if (this.empresa_faturamento == "" || this.empresa_faturamento == null) {
        notify("Selecione a Origem!");
        return;
      } else if (this.entregador == "" || this.entregador == null) {
        notify("Selecione o Entregador!");
        return;
      } else if (this.itinerario == "" || this.itinerario == null) {
        notify("Selecione o Itinerário!");
        return;
      }
      e.fromData.splice(e.fromIndex, 1);
      e.toData.splice(e.toIndex, 0, e.itemData);
      e.itemData.cd_etapa = 1;

      for (let y = 0; y < this.pin.length; y++) {
        this.pin[y].qt_ordem_selecao = y + 1;
      }

      this.mostra_mapa = false;
      this.destinos = this.pin;

      this.mostra_mapa = true;
    },
    ReordenaColuna(valor) {
      valor.sort(function (a, b) {
        return a.cd_cep - b.cd_cep;
      });
      //this.dataSourceConfig.cd_cep.sort()
    },
    async carregaDados() {
      //cd_empresa = localStorage.cd_empresa;

      cd_cliente = localStorage.cd_cliente;
      cd_menu = localStorage.cd_menu;
      cd_api = localStorage.cd_api;
      api = localStorage.nm_identificacao_api;

      //
      localStorage.cd_parametro = 0;
      this.mensagem = "Carregando informações do Google Maps...";
      this.load = true;
      //

      notify(`Aguarde... estamos montando a consulta para você, aguarde !`);

      dados = await Menu.montarMenu(localStorage.cd_empresa, cd_menu, cd_api); //'titulo';
      let sParametroApi = dados.nm_api_parametro;

      localStorage.cd_tipo_consulta = dados.cd_tipo_consulta;

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';

      //procedimento - 1494 - pr_consulta_romaneio_entrega_roteirizacao
      localStorage.cd_parametro = 1;

      try {
        this.dataSourceConfig = await Procedimento.montarProcedimento(
          localStorage.cd_empresa,
          cd_cliente,
          api,
          sParametroApi
        );
      } catch (error) {
        this.load = false;
      }

      if (this.dataSourceConfig.length > 0) {
        this.ReordenaColuna(this.dataSourceConfig);
      }

      this.load = false;

      filename = this.tituloMenu + ".xlsx";
      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //
      this.pin = [];
      notify("Consulta concluída!");

      //this.FormData.Data =  new Date().toLocaleDateString();
    },

    onFocusedRowChanged: function (e) {
      let data = e.row && e.row.data;
      let exemplo = data && data.cd_controle;
    },

    customizeColumns(columns) {
      columns[0].width = 120;
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
    },

    onClick() {
      const buttonText = "Pesquisar os Romaneios ";
      //e.component.option('text');
      notify(`Aguarde... vamos ${this.capitalize(buttonText)} !`);

      this.carregaDados();
    },

    capitalize(text) {
      return text.charAt(0).toUpperCase() + text.slice(1);
    },

    SelecionaItinerario() {
      //this.itinerario_hora = this.itinerario.hr_fim_entrega;
      //if(!this.entregador == '' && !this.itinerario == ''){
      //  this.expanded = false;
      //}else{
      //  this.expanded = true;
      //}
    },
    async AdicionaRoteiro(e) {
      this.mostra_mapa = false;
      e.fromData.splice(e.fromIndex, 1);
      e.toData.splice(e.toIndex, 0, e.itemData);

      var dt = formataData.formataDataSQL(this.dt_entrega_inicial);
      var dt_final = formataData.formataDataSQL(this.dt_entrega_final);
      var iti = "639/904";

      for (let o = 0; o < this.roteiros.length; o++) {
        this.roteiros[o].qt_ordem_selecao = o + 1;
        if (this.roteiros[o].nm_usuario == undefined) {
          this.roteiros[o].nm_usuario == localStorage.usuario;
        }
      }

      this.mostra_mapa = true;
      let u = {
        cd_parametro: 3,
        cd_itinerario: this.itinerario.cd_itinerario,
        cd_controle: e.itemData.cd_controle,
        cd_cliente: e.itemData.cd_cliente,
        qt_ordem_selecao: e.itemData.qt_ordem_selecao,
        cd_romaneio: e.itemData.cd_romaneio,
        cd_entregador: this.entregador.cd_entregador,
        cd_rota: this.itinerario.cd_itinerario,
        cd_usuario: localStorage.cd_usuario,
        dt_selecao: dt,
        dt_final: dt_final,
        cd_empresa: this.empresa_faturamento.cd_empresa,
      };
      var ad = await Incluir.incluirRegistro(iti, u);
      notify(ad[0].Msg);

      var dt = formataData.formataDataSQL(this.dt_entrega_inicial);
      var dt_final = formataData.formataDataSQL(this.dt_entrega_final);
      for (let g = 0; g < this.roteiros.length; g++) {
        let l = {
          cd_usuario: this.cd_usuario,
          cd_parametro: 2,
          cd_romaneio: this.roteiros[g].cd_romaneio,
          qt_ordem_selecao: this.roteiros[g].qt_ordem_selecao,
          hr_selecao: this.roteiros[g].hr_selecao,
          cd_entregador: this.roteiros[g].cd_entregador,
          cd_itinerario: this.roteiros[g].cd_itinerario,
          dt_selecao: dt,
          dt_final: dt_final,
          cd_romaneio: this.roteiros[g].cd_romaneio,
        };
        var iti = "639/904";
        var up = await Incluir.incluirRegistro(iti, l);
      }
    },

    async onClickConsultaRoteiro() {
      if (this.entregador == "") {
        notify("Selecione o entregador!");
        return;
      } else if (this.itinerario == "") {
        notify("Selecione o Itinerário!");
        return;
      }
      this.mensagem = "Buscando isnformações...";
      var dt = formataData.formataDataSQL(this.dt_entrega_inicial);
      var dt_final = formataData.formataDataSQL(this.dt_entrega_final);
      var iti = "639/904"; //pr_egisnet_crud_itinerario
      let i = {
        cd_parametro: 0,
        cd_entregador: this.entregador.cd_entregador,
        cd_itinerario: this.itinerario.cd_itinerario,
        dt_selecao: dt,
        dt_final: dt_final,
      };
      this.load = true;
      this.roteiros = await Incluir.incluirRegistro(iti, i);
      if (this.roteiros[0].Cod == 0) {
        notify("Dia sem roteirização!");
        this.load = false;
        return;
      }
      this.card_pop_titulo = this.roteiros[0].nm_entregador;
      this.load = false;

      dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 635);
      let sParametroApi = dados.nm_api_parametro;
      api = dados.nm_identificacao_api;
      let dataSourceRoteiro = [];

      //
      localStorage.cd_parametro = this.itinerario.cd_itinerario;
      localStorage.cd_entregador = this.entregador.cd_entregador;
      //
      dataSourceRoteiro = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        0,
        api,
        sParametroApi
      );
      this.dataSourceRoteirizacao = dataSourceRoteiro;
      for (let r = 0; r < this.roteiros.length; r++) {
        this.roteiros[r].qt_ordem_selecao = r + 1;
      }
      this.load = false;
      this.mostra_mapa = false;
      this.controla_mapa = true;
      this.mensagem = "";
      this.popup_roteirizacao = true;
      this.ReordenaColuna(this.dataSourceConfig);
      this.mostra_mapa = true;
    },

    async onClickRoteiro() {
      this.load = true;

      this.mensagem = "Salvando informações...";
      let e = this.entregador.cd_entregador;
      let i = this.itinerario.cd_itinerario;
      let o = this.empresa_faturamento.cd_empresa;

      if (this.pin.length > 0) {
        this.pin[0].cd_entregador = e;
        this.pin[0].cd_itinerario = i;
        this.pin[0].cd_empresa = o;
        this.pin[0].cd_parametro = 7;
        this.pin[0].cd_usuario = this.cd_usuario;
        let json = [];
        let g;
        for (let h = 0; h < this.pin.length; h++) {
          g = {
            cd_usuario: this.cd_usuario,
            cd_itinerario: i,
            dt_base: localStorage.dt_base,
            cd_romaneio: this.pin[h].cd_romaneio,
            cd_entregador: e,
            cd_empresa_fat: o,
            qt_ordem_selecao: this.pin[h].qt_ordem_selecao,
          };
          json.push(g);
        }

        let j = {
          cd_parametro: 7,
          json: json,
        };
        var iti = "639/904"; //pr_egisnet_crud_itinerario
        let r = await Incluir.incluirRegistro(iti, j);
      }

      this.load = false;
      this.pin = [];
    },

    //async onClickLiberar(e) {
    //  const buttonText = e.component.option("text");
    //  notify(
    //    `Aguarde... vamos ${this.capitalize(buttonText)} o Roteiro para você !`
    //  );
    //  let api = "626/888";
    //  localStorage.cd_tipo_consulta = 1;
    //  localStorage.cd_identificacao = "144857"; //this.cd_romaneio
    //  localStorage.cd_entregador = 1; //this.entregador.cd_entregador
    //  let sParametroApi =
    //    "/" +
    //    localStorage.cd_empresa +
    //    "/" +
    //    localStorage.cd_parametro +
    //    "/" +
    //    localStorage.cd_usuario +
    //    "/" +
    //    localStorage.cd_tipo_consulta +
    //    "/" +
    //    localStorage.dt_base +
    //    "/" +
    //    localStorage.cd_identificacao +
    //    "/" +
    //    localStorage.cd_entregador;
    //  let liberar = await Procedimento.montarProcedimento(
    //    localStorage.cd_empresa,
    //    localStorage.cd_cliente,
    //    api,
    //    sParametroApi
    //  );
    //},

    //async onClickExcluir(e) {
    //  const buttonText = e.component.option("text");
    //  notify(
    //    `Aguarde... vamos ${this.capitalize(buttonText)} o Roteiro para você !`
    //  );
    //  let api = "626/888";
    //  localStorage.cd_tipo_consulta = 9;
    //  localStorage.cd_identificacao = "144857"; //this.cd_romaneio
    //  localStorage.cd_entregador = 1; //this.entregador.cd_entregador
    //  let sParametroApi =
    //    "/" +
    //    localStorage.cd_empresa +
    //    "/" +
    //    localStorage.cd_parametro +
    //    "/" +
    //    localStorage.cd_usuario +
    //    "/" +
    //    localStorage.cd_tipo_consulta +
    //    "/" +
    //    localStorage.dt_base +
    //    "/" +
    //    localStorage.cd_identificacao +
    //    "/" +
    //    localStorage.cd_entregador;
    //  let excluir = await Procedimento.montarProcedimento(
    //    localStorage.cd_empresa,
    //    localStorage.cd_cliente,
    //    api,
    //    sParametroApi
    //  );
    //},

    async LinhaSelecionada({ selectedRowKeys, selectedRowsData }) {
      let datagrid = this.$refs[this.dataGridRefName].instance;

      if (this.empresa_faturamento == "" || this.empresa_faturamento == null) {
        datagrid.deselectRows(selectedRowKeys);
        notify("Selecione a Origem!");
        return;
      } else if (this.entregador == "" || this.entregador == null) {
        datagrid.deselectRows(selectedRowKeys);
        this.selectedRowsData, (this.selectedRowKeys = []);
        notify("Selecione o Entregador!");
        return;
      } else if (this.itinerario == "" || this.itinerario == null) {
        datagrid.deselectRows(selectedRowKeys);
        this.selectedRowsData, (this.selectedRowKeys = []);
        notify("Selecione o Itinerário!");
        return;
      }

      //
      //this.pin = selectedRowsData;
      //
      localStorage.qt_ordem_selecao = 0;

      //for(let u = 0; u<this.dataSourceConfig.length;u++){
      //  // if (! this.pin[u] == undefined ) {
      //    this.pin[u].qt_ordem_selecao = u+1;
      //    localStorage.qt_ordem_selecao         = u+1;
      //   //}
      //}
      const dataromaneio = selectedRowsData[selectedRowsData.length - 1];

      dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 634);
      api = dados.nm_identificacao_api;
      let sParametroApi = dados.nm_api_parametro;
      localStorage.cd_parametro = 1; //Tipo 1-> Inclusão / Tipo 2-> Exclusão
      localStorage.cd_identificacao = dataromaneio.cd_romaneio;

      if (this.linhaSelecionada > selectedRowKeys.length) {
        localStorage.cd_parametro = 2;
        let filtrado = this.arraySelecionada
          .filter((x) => !selectedRowsData.includes(x))
          .concat(
            selectedRowsData.filter((x) => !this.arraySelecionada.includes(x))
          );
        localStorage.cd_identificacao = filtrado[0].cd_romaneio;
      }

      localStorage.cd_tipo_consulta = this.itinerario.cd_itinerario;
      localStorage.cd_entregador = this.entregador.cd_entregador; //Entregador
      localStorage.cd_empresa_fat = this.empresa_faturamento.cd_empresa; //Empresa Faturamento

      this.linhaSelecionada = selectedRowKeys.length;
      this.arraySelecionada = selectedRowsData;

      for (let y = 0; y < this.pin.length; y++) {
        this.pin[y].qt_ordem_selecao = y + 1;
        //this.dataSourceConfig[y].qt_ordem_selecao = y+1
      }
      let dataSourceRomaneio = [];

      dataSourceRomaneio = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        0,
        api,
        sParametroApi
      );
      //this.carregaDados();
      //    }
    },

    //async AbreMapa() {
    //  if (this.empresa_faturamento == "") {
    //    notify("Selecione a origem!");
    //    return;
    //  } else if (this.entregador == "") {
    //    notify("Selecione o Entregador!");
    //    return;
    //  }
    //  this.popup_mapa = true;
    //},

    //async AbreRoteiro() {
    //  if (this.pin.length == 0) {
    //    notify("Selecione ao menos um romaneio na grid!");
    //    return;
    //  } else if (this.empresa_faturamento == "") {
    //    notify("Selecione a origem!");
    //    return;
    //  } else if (this.entregador == "") {
    //    notify("Selecione o Entregador!");
    //    return;
    //  }
    //  this.popup_mapa = true;
    //},
    async clearSelection() {
      if (this.itinerario.cd_itinerario == undefined) {
        notify("Selecione o itinerário");
        return;
      } else if (this.entregador.cd_entregador == undefined) {
        notify("Selecione o entregador");
        return;
      } else if (this.dt_entrega_inicial == "") {
        notify("Selecione a data!");
        return;
      }
      this.mensagem = "Excluindo romaneios do roteiro, aguarde...";
      this.load = true;

      for (let a = 0; a < this.pin.length; a++) {
        this.dataSourceConfig.unshift(this.pin[a]);
      }
      this.pin = [];
      //LIMPAR OS ROMANEIOS DA TABELA ROMANEIO_SELECAO
      var dt = formataData.formataDataSQL(this.dt_entrega_inicial);
      var dt_final = formataData.formataDataSQL(this.dt_entrega_final);
      let api_ex = "660/955"; //pr_gera_exclusao_roteiro_entrega
      let ex = {
        cd_parametro: 3,
        cd_itinerario: this.itinerario.cd_itinerario,
        cd_entregador: this.entregador.cd_entregador,
        dt_base: dt,
        dt_final: dt_final,
        cd_empresa_faturamento: this.empresa_faturamento.cd_empresa,
      };
      var excluir = await Incluir.incluirRegistro(api_ex, ex);
      notify(excluir[0].Msg);

      dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 634);
      api = dados.nm_identificacao_api;

      this.carregaDados();
      this.p_cd_romaneio = "";
      this.load = false;
      this.mensagem = "";
    },
    async dbClick(e, y) {
      if (this.empresa_faturamento == "" || this.empresa_faturamento == null) {
        notify("Selecione a Origem!");
        return;
      } else if (this.entregador == "" || this.entregador == null) {
        notify("Selecione o Entregador!");
        return;
      } else if (this.itinerario == "" || this.itinerario == null) {
        notify("Selecione o Itinerário!");
        return;
      }

      this.pin.push(e);
      var pos = y.indexOf(e);
      var removedItem = y.splice(pos, 1);

      for (let y = 0; y < this.pin.length; y++) {
        this.pin[y].qt_ordem_selecao = y + 1;
      }
      for (let i = 0; i < this.dataSourceConfig.length; i++) {
        this.dataSourceConfig[i].qt_ordem_selecao = i + 1;
      }

      this.ReordenaColuna(this.dataSourceConfig);
    },
    async dbClick2(e, y) {
      if (this.empresa_faturamento == "" || this.empresa_faturamento == null) {
        notify("Selecione a Origem!");
        return;
      } else if (this.entregador == "" || this.entregador == null) {
        notify("Selecione o Entregador!");
        return;
      } else if (this.itinerario == "" || this.itinerario == null) {
        notify("Selecione o Itinerário!");
        return;
      }
      if (this.pin.length == 1) {
        localStorage.qt_ordem = this.pin[0].qt_ordem_selecao;
      } else {
        localStorage.qt_ordem = this.pin[this.pin.length - 1].qt_ordem_selecao;
      }
      this.dataSourceConfig.push(e);
      var pos2 = y.indexOf(e);
      var removedItem2 = y.splice(pos2, 1);
      for (let y = 0; y < this.pin.length; y++) {
        this.pin[y].qt_ordem_selecao = y + 1;
      }
      for (let i = 0; i < this.dataSourceConfig.length; i++) {
        this.dataSourceConfig[i].qt_ordem_selecao = i + 1;
      }

      e.cd_etapa = 2;
      localStorage.cd_parametro = 2;
      localStorage.cd_tipo_consulta = this.itinerario.cd_itinefrario;
      localStorage.cd_identificacao = e.cd_romaneio;
      localStorage.cd_entregador = this.entregador.cd_entregador;
      localStorage.cd_empresa_fat = this.empresa_faturamento.cd_empresa;

      let dataSourceRomaneio = [];
      dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 634);
      api = dados.nm_identificacao_api;
      let sParametroApi = dados.nm_api_parametro;
      dataSourceRomaneio = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        0,
        api,
        sParametroApi
      );

      this.destinos = this.pin;

      this.ReordenaColuna(this.dataSourceConfig);
    },
    async PesquisaRomaneio() {
      if (this.cd_romaneio == 0 || this.cd_romaneio == null) {
        return;
      }
      notify("Aguarde...");
      var api = "612/859";
      var pesquisa = {
        cd_parametro: 1,
        cd_romaneio: this.cd_romaneio,
      };
      var pesquisa_c = await Incluir.incluirRegistro(api, pesquisa);
      if (pesquisa_c[0].cd_entregador != 0) {
        this.entregador = {
          cd_entregador: 0,
          nm_entregador: "",
        };
        this.entregador.cd_entregador = pesquisa_c[0].cd_entregador;
        this.entregador.nm_entregador = pesquisa_c[0].nm_entregador;
      }
      if (pesquisa_c[0].cd_itinerario != 0) {
        this.itinerario = {
          cd_itinerario: 0,
          nm_itinerario: "",
          hr_fim_entrega: "",
        };
        this.itinerario.cd_itinerario = pesquisa_c[0].cd_itinerario;
        this.itinerario.nm_itinerario = pesquisa_c[0].nm_itinerario;
        this.itinerario.hr_fim_entrega = pesquisa_c[0].hr_fim_entrega;
        this.itinerario_hora = pesquisa_c[0].hr_fim_entrega;
      }
    },
    async ExcluiRoteiro(e) {
      e.fromData.splice(e.fromIndex, 1);
      e.toData.splice(e.toIndex, 0, e.itemData);
      let api_crud = "639/904";
      let ex = {
        cd_parametro: 1,
        cd_controle: e.itemData.cd_controle,
        cd_romaneio: e.itemData.cd_romaneio,
        //   "cd_roteiro"   : e.itemData.cd_roteiro
      };
      let ret = await Incluir.incluirRegistro(api_crud, ex);
      for (let o = 0; o < this.roteiros.length; o++) {
        this.roteiros[o].qt_ordem_selecao = o + 1;
      }
      notify(ret[0].Msg);

      for (let o = 0; o < this.roteiros.length; o++) {
        this.roteiros[o].qt_ordem_selecao = o + 1;
        if (this.roteiros[o].nm_usuario == undefined) {
          this.roteiros[o].nm_usuario == localStorage.usuario;
        }
      }
      var dt = formataData.formataDataSQL(this.dt_entrega_inicial);
      var dt_final = formataData.formataDataSQL(this.dt_entrega_final);
      for (let g = 0; g < this.roteiros.length; g++) {
        let l = {
          cd_usuario: this.cd_usuario,
          cd_parametro: 2,
          cd_romaneio: this.roteiros[g].cd_romaneio,
          qt_ordem_selecao: this.roteiros[g].qt_ordem_selecao,
          hr_selecao: this.roteiros[g].hr_selecao,
          cd_entregador: this.roteiros[g].cd_entregador,
          cd_itinerario: this.roteiros[g].cd_itinerario,
          dt_selecao: dt,
          dt_final: dt_final,
          cd_romaneio: this.roteiros[g].cd_romaneio,
        };
        var iti = "639/904";
        var up = await Incluir.incluirRegistro(iti, l);
        this.ReordenaColuna(this.dataSourceConfig);
      }
    },
    AtualizaRoteiro(e) {
      let api_crud = "639/904";
      let at = {
        cd_parametro: 2,
        cd_usuario: this.cd_usuario,
      };
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
#hora_atual {
  margin-right: 15px;
  left: 0;
}
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
  margin: 0.5vw;
}

#grid-padrao {
  max-height: 600px !important;
}
.padding-comp {
  padding: 0.25vw;
}

.esquerda {
  float: right;
  opacity: 1;
}
.screen-large .responsive-paddings {
  padding: 0 !important;
  margin: 3px;
}
.sortable-cards {
  min-height: 100%;
  min-width: 200px;
  max-width: 100%;
}

#kanban {
  white-space: nowrap;
}

.list {
  border-radius: 8px;
  height: 60vw;
  width: 97%;
  background: #ffffff;
  margin: 10px;
  vertical-align: center;
  white-space: normal;
}

.list-title {
  font-size: 16px;
  padding: 10px;
  padding-left: 30px;
  margin-bottom: -10px;
  font-weight: bold;
  cursor: pointer;
}

.card {
  /*position: relative;*/
  background-color: white;
  box-sizing: border-box;
  width: 95%;
  padding: 5px;
  margin: 5px !important;

  cursor: pointer;
}

.card-subject {
  padding-bottom: 10px;
}

.card-assignee {
  opacity: 0.6;
}

.dx-sortable {
  display: block;
}
.scrollable-list {
  height: 800px;
  width: 260px;
}
#scrollview {
  height: auto;
  min-height: 380px;
  max-height: 65vw;
  width: auto;
  max-width: 100%;
  margin: 5px !important;
  padding: 0px !important;
}
#grid-consulta-romaneio {
  min-height: 500px;
  max-height: 60vw;
}

.column {
  height: 20px !important;
}
.qdate {
  width: 310px;
  overflow-x: hidden;
}
</style>
