<template>
  <div>
    <div>
      <div>
        <DxButton
          v-if="!ds_menu_descritivo == ''"
          class="botao-info"
          icon="info"
          text=""
          @click="popClick()"
        />
        <!-- <DxButton class="botao-info" icon="event" text="" @click="popClick()" /> -->

        <div class="info-periodo" v-if="periodoVisible == true">
          De: {{ dt_inicial }} até {{ dt_final }}
        </div>

        <div class="title">
          <h2 style="width: auto; margin-right: 10px">
            {{ tituloMenu }} - {{ hoje }} | <label id="hora_atual"></label>
          </h2>

          <h2 class="tipo_maquina_parada">Previsão: {{ termino_estimado }}</h2>

          <div class="bola-verde" v-show="this.status_bolinha == 1"></div>
          <div class="bola-amarela" v-show="this.status_bolinha == 2"></div>
          <div class="bola-vermelho" v-show="this.status_bolinha == 3"></div>

          <div class="tipo_maquina_parada" v-show="this.status_bolinha == 3">
            Aguardando Início
          </div>

          <div
            class="tipo_maquina_parada"
            v-if="motivo_tipo_maquina_parada != 0"
          >
            {{ motivo_tipo_maquina_parada }}
          </div>
        </div>
        <q-btn
          color="orange-10"
          icon="play_arrow"
          rounded
          class="margin1"
          label="Início"
          @click="onInicio()"
        />
        <q-btn
          color="orange-10"
          v-if="this.inicio == 1 && this.status_bolinha != 2"
          icon="last_page"
          rounded
          class="margin1"
          label="Fim"
          @click="onClickSetupFim()"
        />
        <q-btn
          color="orange-10"
          icon="pause"
          rounded
          class="margin1"
          label="Refúgo"
          @click="onClickRefugo()"
        />
        <q-btn
          color="orange-10"
          icon="close"
          rounded
          class="margin1"
          label="Parada"
          @click="onClickParada()"
        />
        <q-btn
          color="orange-10"
          icon="precision_manufacturing"
          rounded
          class="margin1"
          label="Produção"
          @click="onClickProducao()"
        />
        <q-btn
          color="orange-10"
          icon="more_vert"
          rounded
          class="margin1"
          label="Componentes"
          @click="onClickComponentes()"
        />
        <q-btn
          color="orange-10"
          icon="perm_contact_calendar"
          rounded
          class="margin1"
          label="Operador"
          @click="onClickApontamento()"
        />
        <q-btn
          color="orange-10"
          icon="show_chart"
          rounded
          class="margin1"
          label="Desenho"
          @click="onDesenho()"
        />
        <!--<DxButton 
        class="buttons-column"
        v-if="this.inicio == 0"
        :width="120"
        text="INICIO"
        type="default"
        styling-mode="contained"
        horizontal-alignment="left"
        @click="onInicio()"
      />
      <DxButton class="buttons-column"
        v-if="this.inicio == 1 && this.status_bolinha != 2"
        :width="120"
        text="FIM"
        type="default"
        styling-mode="contained"
        horizontal-alignment="left"
        @click="onClickSetupFim()"
      />
      <DxButton class="buttons-column"
        :width="120"
        text="REFUGO"
        type="default"
        styling-mode="contained"
        horizontal-alignment="left"
        @click="onClickRefugo()"
      />
      <DxButton class="buttons-column"
        :width="120"
        text="PARADA"
        type="default"
        styling-mode="contained"
        horizontal-alignment="left"
        @click="onClickParada()"
      />
      
      <DxButton class="buttons-column"
        :width="120"
        text="PRODUÇÃO"
        type="default"
        styling-mode="contained"
        horizontal-alignment="left"
        @click="onClickProducao()"
      />
      <DxButton class="buttons-column"
        :width="160"
        text="COMPONENTES"
        type="default"
        styling-mode="contained"
        horizontal-alignment="left"
        @click="onClickComponentes()"
      /> 
      <DxButton class="buttons-column"
        :width="120"
        text="OPERADOR"
        type="default"
        styling-mode="contained"
        horizontal-alignment="left"
        @click="onClickApontamento()"
      />   
      <DxButton class="buttons-column"
        :width="120"
        text="DESENHO"
        type="default"
        styling-mode="contained"
        horizontal-alignment="left"
        @click="onDesenho()"                 
      />  -->
      </div>

      <div class="q-pa-md q-gutter-sm">
        <q-dialog
          v-model="dialog"
          persistent
          :maximized="maximizedToggle"
          transition-show="slide-up"
          transition-hide="slide-down"
        >
          <q-card class="bg-primary text-white">
            <q-bar>
              <q-space />

              <q-btn
                dense
                flat
                icon="minimize"
                @click="maximizedToggle = false"
                :disable="!maximizedToggle"
              >
                <q-tooltip
                  v-if="maximizedToggle"
                  content-class="bg-white text-primary"
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
                  content-class="bg-white text-primary"
                  >Maximizar</q-tooltip
                >
              </q-btn>
              <q-btn dense flat icon="close" v-close-popup>
                <q-tooltip content-class="bg-white text-primary"
                  >Fechar</q-tooltip
                >
              </q-btn>
            </q-bar>

            <q-card-section>
              <div class="text-h6">ATENÇÃO...</div>
            </q-card-section>

            <q-card-section class="q-pt-none">
              {{ Alerta_Mensagem }}
            </q-card-section>
          </q-card>
        </q-dialog>
      </div>

      <div v-if="ic_form_menu == 'S'">
        <div id="form-container">
          <div class="linha">
            <div class="coluna-501">
              <div class="infos">
                <div>MÁQUINA</div>
                <div>
                  <b> {{ nm_maquina }} </b>
                </div>
              </div>

              <div class="infos">
                <div>TURNO E OPERADOR</div>
                <div>
                  <b> {{ turno }} - {{ operador }} </b>
                </div>
              </div>

              <div class="infos">
                <div>ORDEM DE PRODUÇÃO</div>
                <div>
                  <b> {{ this.ordem }} </b>
                </div>
              </div>

              <div class="infos">
                <div>PROCESSO PADRÃO</div>
                <div>
                  <b>
                    {{ this.nm_processo_padrao }} -
                    {{ this.cd_processo_padrao }}</b
                  >
                </div>
              </div>

              <div class="infos">
                <div>CLIENTE</div>
                <div>
                  <b> {{ this.cliente }} </b>
                </div>
              </div>

              <div class="infos">
                <div>OBSERVAÇÕES TÉCNICAS</div>
                <div>
                  <b> {{ this.ds_processo }} </b>
                </div>
              </div>

              <div class="infos">
                <div>
                  TEMPO <b>( {{ this.sg_unidade_processo }} )</b>
                </div>
                <div>
                  <b> {{ this.prod }} </b>
                </div>
              </div>

              <div class="infos" v-if="this.sequencia != null">
                <div>SEQUÊNCIA</div>
                <div>
                  <b> {{ this.sequencia }} </b>
                </div>
              </div>

              <div class="infos">
                <div>OPERAÇÃO</div>
                <div>
                  <b> {{ this.operacao_nm }} </b>
                </div>
              </div>

              <div class="infos" v-if="this.proxima_operacao != null">
                <div>PRÓXIMA OPERAÇÃO</div>
                <div>
                  <b> {{ this.proxima_operacao }} </b>
                </div>
              </div>
            </div>

            <div class="coluna-501">
              <div class="infos">
                <div>DATA DE ENTREGA</div>
                <div>
                  <b> {{ this.entrega }} </b>
                </div>
              </div>

              <div class="infos">
                <div>PRODUTO</div>
                <div>
                  <b> {{ this.produto }} </b>
                </div>
              </div>

              <div class="infos" v-if="this.cd_requisicao_interna != ''">
                <div>REQUISIÇÃO INTERNA</div>
                <div>
                  <b> {{ this.cd_requisicao_interna }} </b>
                </div>
              </div>

              <div class="infos">
                <div>QUANTIDADE</div>
                <div>
                  <b> {{ this.qtd }} {{ this.sg_unidade_medida }} </b>
                </div>
              </div>

              <div class="infos">
                <div>SALDO</div>
                <div>
                  <b> {{ this.saldo }} {{ this.sg_unidade_medida }} </b>
                </div>
              </div>

              <div class="infos" v-if="this.qt_produzida != 0">
                <div>PRODUZIDA</div>
                <div>
                  <b> {{ this.qt_produzida }} </b>
                </div>
              </div>

              <div class="infos" v-if="this.medidas != ''">
                <div>{{ this.label_MEDIDAS }}</div>
                <div>
                  <b> {{ this.medidas }} </b>
                </div>
              </div>

              <div class="infos" v-if="this.instrucoes == true">
                INSTRUÇÕES DE TRABALHO
                <q-input
                  v-model="ds_processo_prod_texto"
                  filled
                  type="textarea"
                  enabled="true"
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      <q-btn
        v-if="ic_form_menu == 'S' || ic_form_menu == 'N'"
        color="orange-10"
        icon="list_alt"
        rounded
        class="margin1"
        label="Programação"
        @click="onClickProgramacao()"
      />
      <q-btn
        v-if="ic_form_menu == 'S' || ic_form_menu == 'N'"
        color="orange-10"
        icon="checklist"
        rounded
        class="margin1"
        label="Ordem"
        @click="onClickOrdem()"
      />
      <q-btn
        v-if="ic_form_menu == 'S' || ic_form_menu == 'N'"
        color="orange-10"
        icon="format_list_bulleted"
        rounded
        class="margin1"
        label="Instruções"
        @click="onClikInstrucao()"
      />
      <q-btn
        v-if="ic_form_menu == 'S' || ic_form_menu == 'N'"
        color="orange-10"
        icon="task"
        rounded
        class="margin1"
        label="Manutenção"
        @click="onClickManutencao()"
      />
      <q-btn
        v-if="ic_form_menu == 'S' || ic_form_menu == 'N'"
        color="orange-10"
        icon="border_color"
        rounded
        class="margin1"
        label="Operações"
        @click="onClickOperacao()"
      />

      <div>
        <DxTabPanel
          class="dx-card wide-card"
          v-if="tabPanel == true"
          :visible="true"
          :show-nav-buttons="true"
          :repaint-changes-only="true"
        >
          <DxItem
            v-if="iTipoComponente == 1"
            title="Operador"
            template="operador-tab"
          />
          <template #operador-tab>
            <grid
              id="gridOperador"
              :cd_menuID="6761"
              :cd_apiID="209"
              :cd_parametroID="0"
              :nm_json="{}"
              :cd_identificacaoID="0"
            />
          </template>
          <DxItem
            v-if="iTipoComponente == 2"
            title="Parada"
            template="parada-tab"
          />
          <template #parada-tab>
            <grid
              :nm_json="{}"
              :cd_menuID="6912"
              :cd_apiID="346"
              :cd_parametroID="2"
              :cd_identificacaoID="ordem"
            />
          </template>
          <DxItem
            v-if="this.iTipoComponente == 3"
            title="Componentes"
            template="comp-tab"
          />
          <template #comp-tab>
            <grid
              :nm_json="{}"
              :cd_menuID="6909"
              :cd_apiID="343"
              :cd_parametroID="2"
              :cd_identificacaoID="ordem"
            />
          </template>
          <DxItem
            v-if="this.iTipoComponente == 4"
            title="Produção"
            template="comp-prod"
          />
          <!-- :cd_parametroID="2" -->
          <template #comp-prod>
            <grid
              :nm_json="{}"
              :cd_menuID="6910"
              :cd_apiID="344"
              :cd_parametroID="0"
              :cd_identificacaoID="ordem"
            />
          </template>
          <DxItem
            v-if="this.iTipoComponente == 5"
            title="Refugo/Perda de Produção"
            template="comp-refugo"
          />
          <template #comp-refugo>
            <grid
              :nm_json="{}"
              :cd_menuID="6911"
              :cd_apiID="345"
              :cd_parametroID="0"
              :cd_identificacaoID="ordem"
            />
          </template>
          <template #operacao-tab>
            <grid
              :nm_json="{}"
              id="grid-3"
              :cd_menuID="7139"
              :cd_apiID="528"
              :cd_parametroID="ordem"
            />
          </template>
          <DxItem
            v-if="iTipoComponente == 6"
            title="Operações"
            template="operacao-tab"
          />
        </DxTabPanel>

        <div v-if="tabPanel == true">
          <q-btn
            color="orange-10"
            v-if="button_cancelar == 1"
            icon="close"
            rounded
            class="margin1"
            label="Fechar"
            @click="onClickFecharTab()"
          />
          <q-btn
            color="orange-10"
            v-if="button_operador == 1"
            icon="change_circle"
            rounded
            class="margin1"
            label="Trocar"
            @click="onTrocar()"
          />
        </div>
      </div>

      <dx-data-grid
        v-if="ic_form_menu_prox == 'S'"
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
        @initialized="saveGridInstance"
        @focused-row-changed="onFocusedRowChanged"
      >
        <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

        <DxGrouping :auto-expand-all="true" />
        <DxExport :enabled="true" />

        <DxPaging :enable="true" :page-size="10" />

        <DxStateStoring
          :enabled="false"
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
        <DxHeaderFilter :visible="true" :allow-search="true" />
        <DxSearchPanel
          :visible="temPanel"
          :width="100"
          placeholder="Procurar..."
        />
        <DxFilterPanel :visible="true" />
        <DxColumnFixing :enabled="true" />
        <DxColumnChooser :enabled="true" mode="select" />
      </dx-data-grid>

      <div class="task-info" v-if="temD === true">
        <div class="info">
          <div id="taskSubject">{{ taskSubject }}</div>
          <p id="taskDetails" v-html="taskDetails" />
        </div>
      </div>
      <div></div>

      <DxPopup
        :visible="popupVisible"
        :title="tituloMenu"
        :height="250"
        :show-title="true"
        :close-on-outside-click="true"
        :drag-enabled="false"
        @hiding="onHiding"
      >
        <div>
          <b class="info-cor">{{ ds_menu_descritivo }}</b>
        </div>
      </DxPopup>

      <!--------------------------------------------------------------------------------------------------->

      <div v-if="agendamento_manutencao == true" class="q-pa-md q-gutter-sm">
        <q-dialog v-model="agendamento_manutencao" persistent>
          <q-card>
            <q-card-section>
              <div class="text-h5 text-orange-9" style="text-align: center">
                <b>MANUTENÇÃO AGENDADA PARA HOJE</b>
              </div>
            </q-card-section>

            <q-card-actions align="right" class="text-primary">
              <DxButton
                class="buttons-column"
                width="100%"
                text="OK"
                type="default"
                styling-mode="contained"
                horizontal-alignment="left"
                @click="1 == 1"
                v-close-popup
              />
            </q-card-actions>
          </q-card>
        </q-dialog>
      </div>

      <!--------------------------------------------------------------------------------------------------->

      <div v-if="fimproducao == true" class="q-pa-md q-gutter-sm">
        <q-dialog v-model="fimproducao" persistent>
          <q-card>
            <q-card-section>
              <div class="text-h5" style="text-align: left">
                <b>{{ this.produto }}</b>
              </div>
            </q-card-section>
            <q-card-section
              class="my-card q-pa-md row items-start q-gutter-md"
              flat
              bordered
            >
              <q-card-section>
                <div class="text-h5 text-overline text-orange-9">
                  <b>FIM DE PRODUÇÃO</b> | Saldo: {{ this.saldo }}
                </div>
                <div class="text-h5 q-mt-sm q-mb-xs">Quantidade Produzida</div>

                <q-input
                  style="font-size: 25px"
                  outlined
                  v-model="qtd_producao"
                />

                <div class="text-caption text-grey">
                  <br /><b>{{ msgFimProducao }}</b>
                </div>
              </q-card-section>
            </q-card-section>
            <q-card-actions align="right" class="text-primary">
              <q-btn flat label="CANCELAR" v-close-popup />
              <!--                v-if="qtd_producao > 0 && qtd_producao <= saldo"
-->
              <q-btn flat label="OK" v-close-popup @click="onFim()" />
            </q-card-actions>
          </q-card>
        </q-dialog>
      </div>

      <div v-if="refugo == true" class="q-pa-md q-gutter-sm">
        <q-dialog v-model="refugo" persistent>
          <q-card>
            <q-card-section>
              <div class="text-h5" style="text-align: left">
                <b>{{ this.produto }}</b>
              </div>
            </q-card-section>
            <q-card-section
              class="my-card q-pa-md row items-start q-gutter-md"
              flat
              bordered
            >
              <q-card-section>
                <div class="text-h5 q-mt-sm q-mb-xs">REFUGO/PERDA PRODUÇÃO</div>

                <div class="text-h5 text-overline text-orange-9">
                  <b>Causa</b>
                </div>

                <div class="div-select">
                  <select v-model="causa_refugo">
                    <option
                      v-for="lookup_dataset_ref in lookup_dataset_ref"
                      v-bind:key="lookup_dataset_ref.cd_causa_refugo"
                      v-bind:value="lookup_dataset_ref.cd_causa_refugo"
                    >
                      {{ lookup_dataset_ref.nm_causa_refugo }}
                    </option>
                  </select>
                </div>

                <div class="text-h5 text-overline text-orange-9">
                  <b>Quantidade</b>
                </div>
                <q-input
                  class="input"
                  outlined
                  v-model="qtd_refugo"
                  :value.sync="qtd_refugo"
                  :rules="[(val) => val < saldo + 1 || 'Valor inválido']"
                />

                <div class="text-caption text-grey">
                  <br /><b>{{ msgRefugoProducao }}</b>
                </div>
              </q-card-section>
            </q-card-section>
            <q-card-actions align="right" class="text-primary">
              <q-btn flat label="CANCELAR" v-close-popup @click="1 == 1" />
              <q-btn flat label="OK" v-close-popup @click="onApara()" />
            </q-card-actions>
          </q-card>
        </q-dialog>
      </div>

      <div v-if="parada == true" class="q-pa-md q-gutter-sm">
        <q-dialog v-model="parada" persistent>
          <q-card>
            <q-card-section>
              <div class="text-h5">
                <b>{{ this.produto }}</b>
              </div>
            </q-card-section>
            <q-card-section v-if="1 == 1">
              <div
                v-if="this.cd_status_producao == 3"
                class="q-pa-md flex flex-center"
              >
                <q-knob
                  :max="61"
                  :min="1"
                  disable
                  v-model="tempo_parado"
                  show-value
                  size="90px"
                  :thickness="0.1"
                  color="F63B00"
                  class="text-primary q-ma-md"
                />
              </div>
              <div
                class="text-h3 text-orange-9"
                style="text-align: center"
                v-if="this.cd_status_producao == 3"
              >
                <label> {{ this.tempo_passado }} MINUTO (S) </label>
                <br />
              </div>
            </q-card-section>

            <q-card-section class="" flat bordered>
              <q-card-section style="width: 100%; text-align: center">
                <label class="text-h5" v-if="this.cd_status_producao == 3">
                  {{ motivo_tipo_maquina_parada }}
                </label>
                <div
                  style="text-align: center; width: 100%"
                  v-if="this.cd_status_producao == 3"
                >
                  <div class="text-h6">ORDEM: {{ this.ordem }}</div>
                  <div class="text-h6">DATA: {{ this.data }}</div>
                  <div class="text-h6">OPERADOR: {{ this.operador }}</div>
                </div>
                <div
                  v-if="this.status_parada == 'INICIO DA PARADA'"
                  class="text-h5 text-overline text-orange-9"
                >
                  <b>PARADA DE PRODUÇÃO</b>
                </div>
                <div
                  v-if="this.status_parada == 'INICIO DA PARADA'"
                  class="text-h5 q-mt-sm q-mb-xs"
                >
                  TIPO DE PARADA

                  <div class="div-select">
                    <select v-model="causa_parada" @blur="trocaTipo">
                      <option
                        v-for="lookup_dataset in lookup_dataset"
                        v-bind:key="lookup_dataset.cd_tipo_maquina_parada"
                        v-bind:value="lookup_dataset.cd_tipo_maquina_parada"
                      >
                        {{ lookup_dataset.nm_tipo_maquina_parada }}
                      </option>
                    </select>
                  </div>
                </div>

                <div
                  v-if="this.status_parada == 'INICIO DA PARADA'"
                  class="text-caption text-grey"
                >
                  <b>{{ msgParadaProducao }}</b>
                </div>
                <div class="div-select" v-if="ic_troca_operador == true">
                  <q-select
                    filled
                    v-model="operador_selecionado"
                    :options="lookup_dataset_operador"
                    option-value="cd_operador"
                    option-label="nm_operador"
                    label="Operador"
                    options-selected-class="text-deep-orange"
                  >
                  </q-select>
                </div>
              </q-card-section>
            </q-card-section>
            <q-card-actions align="right" class="text-primary">
              <q-btn
                v-if="this.cd_status_producao != 3"
                flat
                label="CANCELAR"
                v-close-popup
              />
              <q-btn flat @click="onParada()"> {{ this.status_parada }} </q-btn>
            </q-card-actions>
          </q-card>
        </q-dialog>
      </div>

      <!--     <div 
         v-if="ic_aprovacao == true"
         class="q-pa-md q-gutter-sm">
         <q-dialog v-model="ic_aprovacao" persistent>
         <q-card >
         <q-card-section>
           <div class="text-h5" style="text-align: left"><b>Aguardando Aprovação</b></div>
         </q-card-section>       
           <q-card-section>
             <div class="text-h2 text-overline text-orange-9"> <b>Solicite a Aprovação para o Fim de Parada</b></div>           
           </q-card-section>
        <q-card-actions align="right" class="text-primary">
          <q-btn flat 
          label="Prosseguir"
          @click="onRevisaAprovacao()"
           />
        </q-card-actions>
      </q-card>
    </q-dialog>
    </div>-->

      <div v-if="prox_ordem == true" class="q-pa-md q-gutter-sm">
        <q-dialog v-model="prox_ordem" persistent>
          <q-card style="min-width: 620px; min-height: 250px">
            <q-card-section>
              <div class="text-h5" style="text-align: left">
                <b>Proximas Ordens de Produção</b>
              </div>
            </q-card-section>
            <q-card-section
              class="my-card q-pa-md row items-start q-gutter-md"
              flat
              bordered
            >
              <q-card-section>
                <div class="text-h5 text-overline text-orange-9">
                  <b>Digite uma Ordem de Produção</b>
                </div>

                <q-input
                  outlined
                  v-model="ordem_prox"
                  :value.sync="ordem_prox"
                />

                <div class="text-caption text-grey">
                  <br /><b>{{ msgProximasOrdens }}</b>
                </div>
              </q-card-section>
            </q-card-section>
            <q-card-actions align="right" class="text-primary">
              <q-btn flat label="CANCELAR" v-close-popup @click="1 == 1" />
              <q-btn
                flat
                label="CONFIRMAR"
                v-close-popup
                @click="onProximaOrdem()"
              />
            </q-card-actions>
          </q-card>
        </q-dialog>
      </div>

      <!--------------------------------------------------------------------------------------------------->

      <div v-if="desenho == true" class="q-pa-md q-gutter-sm">
        <q-btn label="Maximized" color="primary" @click="dialog = true" />

        <q-dialog
          v-model="desenho"
          persistent
          :maximized="true"
          transition-show="slide-up"
          transition-hide="slide-down"
        >
          <q-card class="bg-primary text-white">
            <q-bar>
              <div class="div50">
                <label> PAINEL DE DESENHO </label>
              </div>
              <div class="div48">
                <q-btn
                  dense
                  flat
                  icon="minimize"
                  @click="maximizedToggle = false"
                  :disable="!maximizedToggle"
                >
                  <q-tooltip
                    v-if="maximizedToggle"
                    content-class="bg-white text-primary"
                    >Minimize</q-tooltip
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
                    content-class="bg-white text-primary"
                    >Maximize</q-tooltip
                  >
                </q-btn>
                <q-btn dense flat icon="close" v-close-popup>
                  <q-tooltip content-class="bg-white text-primary"
                    >Close</q-tooltip
                  >
                </q-btn>
              </div>
            </q-bar>
            <q-space />
            <div class="desenho">
              <label class="label_desenho"> PRODUTO </label>
              <b>{{ this.produto }}</b>

              <br />
              <label class="label_desenho"> CÓDIGO </label>
              <b>{{ this.cd_mascara_produto }}</b>

              <br />
              <label class="label_desenho"> PROCESSO PADRÃO </label>
              <b
                >{{ this.nm_processo_padrao }} - {{ this.cd_processo_padrao }}
              </b>
              (CÓDIGO)

              <br />
            </div>

            <div v-if="!!this.desenho_processo == true">
              <img
                :src="
                  'http://www.egisnet.com.br/img/Desenho/' +
                  this.desenho_processo
                "
                name="iframeDesenho"
                title="Desenho"
                width="100%"
                height="100%"
              />
            </div>

            <div v-else class="text-center text-h6 margin1">
              Desenho não encontrado!
            </div>
          </q-card>
        </q-dialog>
      </div>

      <!--------------------------------------------------------------------------------------------------->

      <div v-if="manutencao == true" class="q-pa-md q-gutter-sm">
        <q-btn label="Maximized" color="primary" @click="dialog = true" />

        <q-dialog
          v-model="manutencao"
          persistent
          :maximized="true"
          transition-show="slide-up"
          transition-hide="slide-down"
        >
          <q-card class="text-white">
            <q-bar style="background-color: #145ea8">
              <div style="width: 50%">
                <label> PAINEL DE MANUTENÇÃO </label>
              </div>
              <div style="width: 49%; text-align: right">
                <q-btn
                  dense
                  flat
                  icon="minimize"
                  @click="maximizedToggle = false"
                  :disable="!maximizedToggle"
                >
                  <q-tooltip
                    v-if="maximizedToggle"
                    content-class="bg-white text-primary"
                    >Minimize</q-tooltip
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
                    content-class="bg-white text-primary"
                    >Maximize</q-tooltip
                  >
                </q-btn>
                <q-btn dense flat icon="close" v-close-popup>
                  <q-tooltip content-class="bg-white text-primary"
                    >Close</q-tooltip
                  >
                </q-btn>
              </div>
            </q-bar>
            <q-space />
            <div class="manutencao">
              <label class="label_manutencao"> MÁQUINA </label>
              <b>{{ this.nm_maquina }} ( {{ this.cd_maquina }} )</b>

              <br />
              <label class="label_manutencao"> TURNO E OPERADOR </label>
              <b>{{ turno }} - {{ operador }}</b>
            </div>
            <div class="manutencao_baixo">
              <q-btn
                color="orange-10"
                icon="receipt_long"
                rounded
                class="margin1"
                label="Instruções"
                @click="onClickInstrucoes_grid()"
              />
              <q-btn
                color="orange-10"
                icon="clear_all"
                rounded
                class="margin1"
                label="Componente"
                @click="onClickComponentes_grid()"
              />
              <q-btn
                color="orange-10"
                icon="history_edu"
                rounded
                class="margin1"
                label="Histórico"
                @click="onClickHitstorico_grid()"
              />
              <!--<DxButton 
        style="margin-left: 20px"
           class="buttons-column"
           :width="150"
           text="INSTRUÇÕES"
           type="default"
           styling-mode="contained"
           horizontal-alignment="left"
           @click="onClickInstrucoes_grid()"
        />
        <DxButton 
           class="buttons-column"
           :width="150"
           text="COMPONENTE"
           type="default"
           styling-mode="contained"
           horizontal-alignment="left"
           @click="onClickComponentes_grid()"
        />
        <DxButton
           class="buttons-column"
           :width="150"
           text="HISTÓRICO"
           type="default"
           styling-mode="contained"
           horizontal-alignment="left"
           @click="onClickHitstorico_grid()"
        />-->

              <grid
                v-show="this.grid_comp == true"
                :cd_menuID="6967"
                :nm_json="{}"
                :cd_apiID="396"
                :cd_parametroID="this.cd_maquina"
              />

              <grid
                v-show="this.grid_hist == true"
                :cd_menuID="6968"
                :cd_apiID="397"
                :cd_parametroID="1"
                :cd_identificacaoID="0"
                :nm_json="{}"
              />

              <grid
                v-show="this.grid_inst == true"
                :cd_menuID="6966"
                :cd_apiID="395"
                :cd_parametroID="1"
                :cd_identificacaoID="0"
                :nm_json="{}"
              />

              <div class="todas">
                <div class="agendamento">
                  <label
                    class="label_data"
                    v-if="this.data_manutencao_agendada != null"
                  >
                    AGENDAMENTO PARA A PROXIMA MANUTENÇÃO:
                  </label>
                  <b>{{ this.data_manutencao_agendada }}</b>
                </div>

                <div class="div_botao_solicitacao">
                  <q-btn
                    color="orange-10"
                    icon="history_edu"
                    rounded
                    class="margin1"
                    label="Solicitação"
                    @click="1 == 1"
                  />
                  <!--<DxButton
             class="botao_solicitacao buttons-column"
             :width="150"
             text="SOLICITAÇÃO"
             type="default"
             styling-mode="contained"
             horizontal-alignment="center"
             @click="1 == 1"
          />-->
                </div>
              </div>
            </div>
          </q-card>
        </q-dialog>
      </div>

      <!--------------------------------------------------------------------------------------------------->

      <div v-if="this.carregando == true" class="q-pa-md q-gutter-sm">
        <q-dialog
          v-model="this.carregando"
          transition-show="flip-down"
          transition-hide="flip-up"
        >
          <q-card class="bg-primary text-white">
            <q-bar>
              <q-space />
            </q-bar>
            <q-card-section class="q-pt-none">
              <q-circular-progress
                v-if="this.carregando == true"
                indeterminate
                size="50px"
                color="blue"
                class="q-ma-md"
              />
              Aguarde, estamos carregando seu apontamento...
            </q-card-section>
          </q-card>
        </q-dialog>
      </div>
    </div>
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
} from "devextreme-vue/data-grid";

import "devextreme-vue/text-area";
import DxButton from "devextreme-vue/button";
import { DxTabPanel, DxItem } from "devextreme-vue/tab-panel";
import { DxPopup } from "devextreme-vue/popup";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";

import Procedimento from "../http/procedimento";
import Producao from "../http/producao";
import Menu from "../http/menu";
import grid from "../views/grid";
import Lookup from "../http/lookup";

var filename = "DataGrid.xlsx";

var dados = [];
var sParametroApi = "";
var api = "";

const dataGridRef = "dataGrid";

//setInterval(function() {
//  if (localStorage.cd_menu == 6759) {
//    let novaHora = new Date();
//    let hora = novaHora.getHours();
//    let minuto = novaHora.getMinutes();
//    let segundo = novaHora.getSeconds();
//    // Chamamos a função zero para que ela retorne a concatenação
//    // com os minutos e segundos
//    if (minuto < 10) {
//      minuto = "0" + minuto;
//    }
//    if (segundo < 10) {
//      segundo = "0" + segundo;
//    }
//    document.getElementById("hora_atual").textContent =
//      hora + ":" + minuto + ":" + segundo;
//  }
//}, 100);

export default {
  data() {
    return {
      tituloMenu: "",
      dt_inicial: "",
      dt_final: "",
      columns: [],
      pageSizes: [10, 20, 50, 100],
      dataSourceConfig: [],
      total: {},
      dataGridInstance: null,
      taskSubject: "Descritivo",
      taskDetails: "",
      temD: false,
      temPanel: false,
      cd_menu_destino: 0,
      cd_api_destino: 0,
      qt_tempo: 0,
      polling: 60000,
      exportar: false,
      cd_empresa: 0,
      cd_menu: 0,
      cd_cliente: 0,
      cd_api: 0,
      api: 0,
      cd_menu_origem: 0,
      cd_api_origem: 0,
      ds_arquivo: "",
      ds_menu_descritivo: "",
      popupVisible: false,
      periodoVisible: false,
      ic_form_menu: "N",
      ic_form_menu_prox: "N",
      formData: {},
      turno: "",
      operador: "",
      inotifica: 0,
      tabPanel: false,
      ordem: 0,
      entrega: "",
      vol: "",
      comp: "",
      esp: "",
      larg: "",
      qtd: "",
      cliente: "",
      produto: "",
      pedido: "",
      data: "",
      peso: "",
      composicao: "",
      obs: "",
      funcionario: "",
      ds_processo: "",
      hoje: "",
      hora: "",
      sg_unidade_medida: "",
      cd_item_req_interna: 0,
      cd_requisicao_interna: 0,
      sg_unidade_processo: "",
      show: false,
      confirm: false,
      prompt: false,
      cd_operacao: 0,
      cd_registro_funcionario: 0,
      cd_mascara_produto: 0,
      qt_planejada_processo: 0,
      cd_processo_padrao: 0,
      iparada: 1,
      desenho: false,
      fimproducao: false,
      refugo: false,
      parada: false,
      prox_ordem: false,
      labelQtd: "Quantidade",
      cd_funcionario: 0,
      medida: "",
      cd_maquina: 0,
      nm_maquina: "",
      cd_item_processo: 0,
      cd_operador: 0,
      inicio: 0,
      caminho_desenho: "",
      desenho_processo: "",
      saldo: 0,
      qtd_producao: 0,
      qtd_refugo: 0,
      qtd_parada: 0,
      label_MEDIDAS: "MEDIDAS",
      medidas: "",
      desativa_imagem: 1,
      ic_troca_operador: false,
      imagem_src: "",
      sequencia: 0,
      operacao_nm: "",
      setup: "",
      prod: "",
      dialog: false,
      maximizedToggle: false,
      Alerta_Mensagem: "",
      iTipoComponente: 0,
      msgFimProducao:
        "Atenção, o Operador pode realizar a Baixa Total ou Parcial da Produção.!",
      msgRefugoProducao:
        "Atenção, o Operador deve digitar a quantidade que foi Perdida ou Refugada.!",
      msgParadaProducao:
        "Atenção, o Operador deve informar o motivo da Parada de Produção.!",
      msgProximasOrdens:
        "Atenção, o Operador pode selecionar uma Ordem de Produção para ser Iniciada.!",
      motivo_parada: "",
      apontamento_parada: 0,
      status_parada: "",

      // LOOKUP MOTIVO PARADA //
      lookup_dados: [],
      lookup_dataset: [],
      id: "",
      display: "",
      id_tipo_parada: 0,
      // LOOKUP MOTIVO PARADA //

      // LOOKUP MOTIVO REFUGO //
      lookup_dados_ref: [],
      lookup_dataset_ref: [],
      id_ref: "",
      display_ref: "",
      id_tipo_parada_ref: 0,
      // LOOKUP MOTIVO REFUGO //

      ordem_prox: "",
      index_data: 0,
      cd_motivo: 0,
      carregando: false,
      ds_processo_prod_texto: "",
      ic_apontamento: "",
      instrucoes: false,

      tipo_parada_selecionada: "",
      proxima_operacao: "",
      causa_parada: 0,
      causa_refugo: 0,
      nm_processo_padrao: "",

      button_operador: 0,

      ic_parada: false,

      timer: "",
      tempo_parado: 0,
      tempo_passado: 0,

      cd_status_producao: 0,

      cd_bloqueio_parada: false,
      menu_grid: 0,
      api_grid: 0,

      //grid
      grid_comp: false,
      grid_hist: false,
      grid_inst: false,
      manutencao: false,

      //manutencao
      data_manutencao_agendada: "",

      agendamento_manutencao: false,
      status_desenho: false,

      nm_causa_parada: 0,
      status_bolinha: 0,
      button_cancelar: 1,
      //1- Produzindo 2- Parada 3-Fim de Producao

      motivo_tipo_maquina_parada: "",
      ic_aprovacao: false,
      termino_estimado: "00:00",

      qt_produzida: 0,

      lookup_operador: [],
      lookup_dataset_operador: [],

      operador_selecionado: "",
      imagem: "",
    };
  },

  computed: {
    dataGrid: function () {
      return this.$refs[dataGridRef].instance;
    },
  },

  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();
    this.dt_final = new Date(localStorage.dt_final).toLocaleDateString();
    this.hoje = new Date().toLocaleDateString();
    var h = new Date().toLocaleTimeString();
    this.hora = h.substring(0, 5);

    await this.showMenu();

    if (!this.qt_tempo == 0) {
      //this.pollData();   Kelvin - Comentado por que não achei o methodo e estava gerando erro
      localStorage.polling = 1;
    }
  },

  async mounted() {
    await this.carregaDados();
    if (this.data_manutencao_agendada == localStorage.dt_base) {
      this.agendamento_manutencao = true;
    }
  },

  destroyed() {
    clearInterval();
  },

  async beforeupdate() {
    // this.carregaDados();
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
    DxStateStoring,
    DxSearchPanel,
    DxTabPanel,
    DxItem,
    DxButton,
    DxPopup,
    grid,
    //componente
  },

  methods: {
    detectar() {
      if (
        navigator.userAgent.match(/Android/i) ||
        navigator.userAgent.match(/webOS/i) ||
        navigator.userAgent.match(/iPhone/i) ||
        navigator.userAgent.match(/iPad/i) ||
        navigator.userAgent.match(/iPod/i) ||
        navigator.userAgent.match(/BlackBerry/i) ||
        navigator.userAgent.match(/Windows Phone/i)
      ) {
        this.celular = 1;
      } else {
        this.celular = 0;
      }
    },

    popClick() {
      this.popupVisible = true;
    },

    ContaSegundos() {
      if (this.tempo_parado == 61) {
        this.tempo_parado = 1;
        this.tempo_passado++;
      } else {
        this.tempo_parado++;
      }
    },

    onHiding() {
      this.popupVisible = false; // Handler of the 'hiding' event
    },

    async showMenu() {
      //liberação do localStorage
      localStorage.caminho_desenho = "";
      localStorage.desenho_processo = "";
      localStorage.cd_parametro = 0;
      //

      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_menu = localStorage.cd_menu;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      this.maquina = localStorage.usuario;
      this.ordem = 0;
      this.cd_parametro = 0;

      //Api Origem
      if (this.cd_api_origem == 0) {
        this.api_origem = this.cd_api;
        this.cd_menu_origem = this.cd_menu;
      } else {
        this.cd_api = this.cd_api_origem;
        this.cd_menu = this.cd_menu_origem;
      }
      //

      var data = new Date(),
        dia = data.getDate().toString(),
        diaF = dia.length == 1 ? "0" + dia : dia,
        mes = (data.getMonth() + 1).toString(), //+1 pois no getMonth Janeiro começa com zero.
        mesF = mes.length == 1 ? "0" + mes : mes,
        anoF = data.getFullYear();

      localStorage.dt_inicial = mes + "-" + dia + "-" + anoF;
      localStorage.dt_final = mesF + "-" + diaF + "-" + anoF;

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';
      //
      sParametroApi = dados.nm_api_parametro;
      //

      this.qt_tabsheet = dados.qt_tabsheet;
      this.cd_menu_destino = this.cd_menu;
      this.cd_api_destino = this.cd_api;
      this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa;
      this.exportar = false;
      this.ds_menu_descritivo = dados.ds_menu_descritivo;
      this.ic_form_menu = dados.ic_form_menu;

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      if (dados.ic_exportacao == "S") {
        this.exportar = true;
      }

      localStorage.cd_tipo_consulta = 0;

      if (!dados.cd_tipo_consulta == 0) {
        dados.cd_tipo_consulta;
      }

      this.tituloMenu = dados.nm_menu_titulo; //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';

      filename = this.tituloMenu + ".xlsx";

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
    },

    onFocusedRowChanged: function (e) {
      var data = e.row && e.row.data;

      // this.taskSubject = data && data.ds_informativo;
      this.taskDetails = data && data.ds_informativo;
      this.ds_arquivo = data && data.ds_arquivo;

      if (!data.ds_informativo == "") {
        this.temD = true;
      }
    },

    async carregaDados() {
      //this.carregando = true;
      await this.showMenu();
      this.temPanel = true;

      if (this.inotifica == 0) {
        notify("Aguarde... estamos montando a consulta para você, aguarde !");
        this.inotifica = 1;
      }
      if (this.qt_tabsheet == 0) {
        let sApi = sParametroApi;
        this.dataSourceConfig = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          this.api,
          sApi
        );

        this.dialog = false;
        this.ordem = 0;

        this.formData = this.dataSourceConfig[this.index_data];

        if (this.dataSourceConfig[this.index_data].cd_processo == 0) {
          this.dialog = true;
          this.Alerta_Mensagem =
            "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
        } else {
          this.formData = this.dataSourceConfig[this.index_data];
          this.ordem = this.dataSourceConfig[this.index_data].cd_processo;
          this.turno = this.dataSourceConfig[this.index_data].sg_turno;

          if (this.operador == "" || this.operador == null) {
            this.operador =
              this.dataSourceConfig[this.index_data].nm_funcionario;
          }

          this.data = new Date(
            this.dataSourceConfig[this.index_data].dt_programacao
          ).toLocaleDateString();
          this.entrega = new Date(
            this.dataSourceConfig[this.index_data].dt_entrega_processo
          ).toLocaleDateString();
          this.cliente =
            this.dataSourceConfig[this.index_data].nm_fantasia_cliente;
          this.produto =
            this.dataSourceConfig[this.index_data].nm_produto_pedido;
          this.pedido = this.dataSourceConfig[this.index_data].cd_pedido;
          this.qtd =
            this.dataSourceConfig[this.index_data].qt_planejada_processo;
          this.larg = this.dataSourceConfig[this.index_data].qt_largura;
          this.esp = this.dataSourceConfig[this.index_data].qt_espessura;
          this.comp = this.dataSourceConfig[this.index_data].qt_comprimento;
          this.vol = this.dataSourceConfig[this.index_data].qt_volume;
          this.peso =
            this.dataSourceConfig[this.index_data].qt_peso_bruto_total;
          this.composicao =
            this.dataSourceConfig[this.index_data].nm_projeto_composicao;
          this.peso_un =
            this.dataSourceConfig[this.index_data].qt_peso_unitario;
          this.peso_esp =
            this.dataSourceConfig[this.index_data].qt_peso_especifico;
          this.peso_emb = this.dataSourceConfig[this.index_data].qt_embalagem;
          this.obs = this.dataSourceConfig[this.index_data].nm_obs_operacao;
          this.ds_processo = this.dataSourceConfig[this.index_data].ds_processo;
          this.sg_unidade_medida =
            this.dataSourceConfig[this.index_data].sg_unidade_medida;
          this.cd_item_req_interna =
            this.dataSourceConfig[this.index_data].cd_item_req_interna;
          this.cd_requisicao_interna =
            this.dataSourceConfig[this.index_data].cd_requiscao_interna;
          this.sg_unidade_processo =
            this.dataSourceConfig[this.index_data].sg_unidade_processo;
          this.qt_utilizada =
            this.dataSourceConfig[this.index_data].qt_utilizada;
          this.cd_mascara_produto =
            this.dataSourceConfig[this.index_data].cd_mascara_produto;
          this.qt_planejada_processo =
            this.dataSourceConfig[this.index_data].qt_planejada_processo;
          this.cd_processo_padrao =
            this.dataSourceConfig[this.index_data].cd_processo_padrao;
          this.caminho_desenho =
            this.dataSourceConfig[this.index_data].nm_caminho_desenho;
          this.desenho_processo =
            this.dataSourceConfig[this.index_data].nm_desenho_processo;
          this.cd_maquina = this.dataSourceConfig[this.index_data].cd_maquina;
          this.nm_maquina = this.dataSourceConfig[this.index_data].nm_maquina;
          this.cd_item_processo =
            this.dataSourceConfig[this.index_data].cd_item_processo;
          this.data_manutencao_agendada =
            this.dataSourceConfig[this.index_data].dt_inicio_manutencao;
          this.cd_operador = this.dataSourceConfig[this.index_data].cd_operador;

          if (this.cd_operador == 0) {
            this.tabPanel = true;
            this.ic_form_menu = "G";
            this.iTipoComponente = 1;
            this.button_cancelar = 0;
            if (this.button_operador == 1) {
              this.button_operador = 0;
            } else {
              this.button_operador = 1;
            }
          }

          this.cd_operacao = this.dataSourceConfig[this.index_data].cd_operacao;
          this.saldo = this.dataSourceConfig[this.index_data].qt_saldo;
          this.medidas =
            this.dataSourceConfig[this.index_data].nm_medida_retorno;
          this.sequencia =
            this.dataSourceConfig[this.index_data].cd_item_processo;
          this.operacao_nm =
            this.dataSourceConfig[this.index_data].nm_fantasia_operacao;
          this.setup = 0; //this.dataSourceConfig[this.index_data].
          this.prod =
            this.dataSourceConfig[this.index_data].qt_hora_prog_operacao;
          this.termino_estimado = this.dataSourceConfig[
            this.index_data
          ].termino_estimado.substring(0, 5);

          this.ds_processo_prod_texto =
            this.dataSourceConfig[this.index_data].ds_processo_prod_texto;
          this.ic_apontamento =
            this.dataSourceConfig[this.index_data].ic_apontamento;
          this.proxima_operacao =
            this.dataSourceConfig[this.index_data].nm_proxima_operacao;
          this.nm_processo_padrao =
            this.dataSourceConfig[this.index_data].nm_processo_padrao;
          this.cd_status_producao =
            this.dataSourceConfig[this.index_data].cd_status_producao;

          //this.qt_produzida = this.qtd - this.saldo;
          this.qt_produzida =
            this.dataSourceConfig[this.index_data].qt_finalizada;

          if (this.dataSourceConfig[this.index_data].ic_aprovacao == "S") {
            this.ic_aprovacao = true;
          } else {
            this.ic_aprovacao = false;
          }

          this.motivo_tipo_maquina_parada = "";
          if (this.cd_status_producao == 3) {
            this.motivo_tipo_maquina_parada =
              this.dataSourceConfig[this.index_data].nm_tipo_maquina_parada;
            this.status_bolinha = 2;
            //Inicio de Parada com bloqueio
            this.cd_bloqueio_parada = true;
            if (
              this.dataSourceConfig[this.index_data].ic_operador_parada == "S"
            ) {
              this.ic_troca_operador = true;
            } else {
              this.ic_troca_operador = false;
            }

            this.parada = true;
            this.apontamento_parada = 1;
            this.onClickParada();
            this.timer = setInterval(this.ContaSegundos, 1000);
          } else if (this.cd_status_producao == 33) {
            this.motivo_tipo_maquina_parada =
              this.dataSourceConfig[this.index_data].nm_tipo_maquina_parada;
            this.status_bolinha = 2;
            //Inicio de Parada Simples
            this.cd_bloqueio_parada = false;
            this.parada = true;

            this.apontamento_parada = 1;
            this.onClickParada();
          }

          if (this.medidas == "") {
            this.label_MEDIDAS = "DESENHO";
            this.medidas =
              this.dataSourceConfig[this.index_data].cd_desenho_processo_padrao;
          }

          if (
            this.dataSourceConfig[this.index_data].dt_ini_prod_operacao == null
          ) {
            this.inicio = 0;
            this.status_bolinha = 3;
          } else {
            this.inicio = 1;
            if (this.status_bolinha != 2) {
              this.status_bolinha = 1;
            } else {
              this.status_bolinha = 2;
            }
          }

          if (this.dataSourceConfig[this.index_data].desenho_processo == "") {
            this.status_desenho = false;
          } else {
            this.desativa_imagem = true;
          }

          localStorage.caminho_desenho = this.caminho_desenho;
          localStorage.desenho_processo = this.desenho_processo;

          //if (this.caminho_desenho == "" && this.desenho_processo == "") {
          //  this.caminho_desenho = "Desenho nãoencontrado";
          //  this.desenho_processo = "Desenho nãoencontrado";
          //}

          this.lookup_dados = await Lookup.montarSelect(this.cd_empresa, 633);
          this.lookup_dataset = JSON.parse(
            JSON.parse(JSON.stringify(this.lookup_dados.dataset))
          );

          this.id = this.lookup_dados.chave;
          this.display = this.lookup_dados.display;

          this.lookup_dados_ref = await Lookup.montarSelect(
            this.cd_empresa,
            2742
          );
          this.lookup_dataset_ref = JSON.parse(
            JSON.parse(JSON.stringify(this.lookup_dados_ref.dataset))
          );

          this.id_ref = this.lookup_dados_ref.chave;
          this.display_ref = this.lookup_dados_ref.display;
          //Avaliar o Status da Ordem de produção e Já confirmar o Posicionamento dos botões
        }
      }
      //this.carregando = false;
    },

    async onInicio() {
      this.status_bolinha = 1;
      if (!this.ordem == 0) {
        this.inicio = 1;
        this.cd_inicio = 0;

        localStorage.cd_cliente = 0;
        localStorage.cd_parametro = 1; //INICIO
        localStorage.qt_refugo = 0; //REFUGO ESTA 0 POIS É INICIO DE APONTAMENTO
        localStorage.cd_processo = this.ordem;
        localStorage.cd_operacao = this.cd_operacao;
        localStorage.cd_maquina = this.cd_maquina;
        localStorage.cd_operador = this.cd_operador;
        localStorage.qt_apontamento = this.saldo;
        localStorage.cd_motivo = 0;
        localStorage.cd_item_processo = this.cd_item_processo;

        api = "";
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);
        //

        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        var dataSourceConfigs = [];
        dataSourceConfigs = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api, //1222 - pr_egisnet_apontamento
          sParametroApi
        );

        this.formData = dataSourceConfigs[0];

        this.status_bolinha = 1;

        if (dataSourceConfigs[0].result == "S") {
          notify(dataSourceConfigs[0].mensagem);
          this.inotifica = 1;
        } else {
          notify(dataSourceConfigs[0].mensagem);
          this.inotifica = 1;
        }

        //this.carregaDados();
      } else {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      }

      dataSourceConfigs = [];
    },

    async onFim() {
      if (this.ordem == 0) {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else {
        this.fimproducao = false;
        this.carregando = true;

        this.inicio = 0;
        this.status_bolinha = 3;

        //definindo e validando

        localStorage.cd_cliente = 0;
        this.cd_inicio = 0;
        localStorage.qt_refugo = 0;
        localStorage.cd_parametro = 2;
        localStorage.cd_processo = this.ordem;
        localStorage.cd_operacao = this.cd_operacao;
        localStorage.cd_maquina = this.cd_maquina;
        localStorage.cd_operador = this.cd_operador;
        localStorage.qt_apontamento = this.qtd_producao;
        localStorage.cd_motivo = 0;
        localStorage.cd_item_processo = this.cd_item_processo;

        //Atualiza o Saldo, apenas para mostrar na tela
        //this.saldo = this.qtd - this.qtd_producao;
        //

        api = "";
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);
        //

        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        var dataSourceConfigs_fim = [];
        dataSourceConfigs_fim = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );

        this.formData = dataSourceConfigs_fim[0];

        if (dataSourceConfigs_fim[0].result == "S") {
          notify(dataSourceConfigs_fim[0].mensagem);
          this.inotifica = 1;
        } else {
          notify(dataSourceConfigs_fim[0].mensagem);
          this.inotifica = 1;
        }
      }

      dataSourceConfigs_fim = [];

      //Próximo Op com Saldo, inclusive pode ser a mesma.
      this.limpa_tudo();
      this.index_data = 0;
      await this.carregaDados();
      //
      this.carregando = false;
    },

    async onParada() {
      this.carregando = true;
      if (this.apontamento_parada == 0) {
        this.status_bolinha = 2;

        var cd_parada = 0;
        cd_parada = this.lookup_dataset.findIndex(
          (obj) => obj.cd_tipo_maquina_parada == this.causa_parada
        );
        this.nm_causa_parada =
          this.lookup_dataset[cd_parada].nm_tipo_maquina_parada;
        if (this.lookup_dataset[cd_parada].ic_aprovacao == "S") {
          this.ic_aprovacao = true;
        } else {
          this.ic_aprovacao = false;
        }
      } else {
        this.status_bolinha = 1;
      }
      this.parada = false;

      if (this.ordem == 0) {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else {
        //parada = true - produção esta parada
        this.ic_parada = true;

        if (this.apontamento_parada == 0) {
          this.apontamento_parada = 1;
          localStorage.cd_parametro = 3;
        } else {
          this.apontamento_parada = 0;
          localStorage.cd_parametro = 4;
          clearInterval(this.timer);
          //this.parada = false;
        }

        //definindo e validando

        localStorage.cd_cliente = 0;
        //this.cd_inicio               = 1;
        localStorage.qt_refugo = 0;
        localStorage.cd_processo = this.ordem;
        localStorage.cd_operacao = this.cd_operacao;
        localStorage.cd_maquina = this.cd_maquina;
        if (this.ic_troca_operador == true) {
          localStorage.cd_operador = this.operador_selecionado.cd_operador;
        } else {
          localStorage.cd_operador = this.cd_operador;
        }

        localStorage.qt_apontamento = 0;
        localStorage.cd_motivo = this.causa_parada;
        localStorage.cd_item_processo = this.cd_item_processo;

        //Atualiza o Saldo, apenas para mostrar na tela
        //this.saldo = this.qtd - this.qtd_producao;
        //

        api = "";
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);
        //

        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        var dataSourceConfigs_parada = [];

        this.cd_empresa = localStorage.cd_empresa;
        dataSourceConfigs_parada = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );

        this.formData = dataSourceConfigs_parada[0];

        if (dataSourceConfigs_parada[0].result == "S") {
          notify(dataSourceConfigs_parada[0].mensagem);
          this.inotifica = 1;
        } else {
          notify(dataSourceConfigs_parada[0].mensagem);
          this.inotifica = 1;
        }
      }
      await this.carregaDados();

      if (this.cd_status_producao == 3) {
        clearInterval(this.timer);
        this.tempo_parado = 0;
        this.tempo_passado = 0;
      } else {
        clearInterval(this.timer);
        this.tempo_parado = 0;
        this.tempo_passado = 0;
      }
      this.status_parada = "FIM DA PARADA";

      dataSourceConfigs_parada = [];

      //Próximo Op com Saldo, inclusive pode ser a mesma.
      //
      //this.causa_parada = 0;
      this.carregando = false;
    },

    async onApara() {
      if (this.ordem == 0) {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else {
        this.cd_inicio = 0;

        localStorage.cd_parametro = 6;
        localStorage.cd_cliente = 0;
        localStorage.qt_refugo = this.qtd_refugo;
        localStorage.cd_processo = this.ordem;
        localStorage.cd_operacao = this.cd_operacao;
        localStorage.cd_maquina = this.cd_maquina;
        localStorage.cd_operador = this.cd_operador;
        localStorage.qt_apontamento = this.qtd_refugo;
        localStorage.cd_motivo = this.causa_refugo;
        localStorage.cd_item_processo = this.cd_item_processo;

        api = "";

        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338);

        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        var dataSourceConfigs_refugo = [];
        dataSourceConfigs_refugo = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );

        //this.formData = dataSourceConfigs_refugo[0];

        if (dataSourceConfigs_refugo[0].result == "S") {
          notify(dataSourceConfigs_refugo[0].mensagem);
          this.inotifica = 1;
        } else {
          notify(dataSourceConfigs_refugo[0].mensagem);
          this.inotifica = 1;
        }

        this.causa_refugo = 0;
        this.carregaDados();
      }
    },

    async onDesenho() {
      if (this.ordem == 0) {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else {
        this.desenho = true;
        try {
          var imagem =
            "http://www.egisnet.com.br/img/Desenho/" + this.desenho_processo;
          //+".pdf";
          if (imagem == undefined) {
            this.status_desenho = false;
          } else {
            this.status_desenho = true;
          }
          return imagem;
        } catch {
          this.status_desenho = false;
        }
      }
    },

    onClickOrdem() {
      this.prox_ordem = true;
    },

    async onRevisaAprovacao() {
      localStorage.cd_parametro = this.ordem;
      var api = "527/734"; //pr_consulta_aprovacao_parada
      var parametroApi = "/${cd_empresa}/${cd_parametro}";
      var dataAprovacao = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        parametroApi
      );
      if (dataAprovacao[0].cd_status == "false") {
        this.ic_aprovacao = false;
      } else {
        this.ic_aprovacao = false;
      }
    },

    async onProximaOrdem() {
      this.index_data = this.dataSourceConfig.findIndex(
        (obj) => obj.cd_processo == this.ordem_prox
      );
      if (this.index_data == -1) {
        notify("NÃO FOI POSSÍVEL LOCALIZAR A OP: " + this.ordem_prox);
      } else {
        this.carregando = true;
        await this.limpa_tudo();
        notify("CARREGANDO OP: " + this.ordem_prox);
        await this.carregaDados();

        if (this.data_manutencao_agendada == localStorage.dt_base) {
          this.agendamento_manutencao = true;
        }
        this.carregando = false;
      }
    },

    async onConfirmarParada() {
      if (this.ordem == 0) {
        this.dialog = true;
        this.Alerta_Mensagem =
          "Não existem ordens de produção, por favor, entrar em contato com o PCP-Planejamento, para fazer novas programações. Obrigado !";
      } else {
        if (this.parada == 0) {
          this.iparada = 1;
        } else {
          this.iparada = 0;
        }

        //#region definindo e validando
        localStorage.cd_cliente = 0;
        this.cd_inicio = 0;

        localStorage.cd_processo = this.cd_processo;
        localStorage.cd_operacao = this.cd_operacao;
        localStorage.cd_maquina = localStorage.cd_usuario;
        localStorage.cd_operador = this.cd_operador;
        localStorage.qt_apontamento = this.qtd_producao;
        localStorage.cd_motivo = 0;
        localStorage.cd_item_processo = this.cd_item_processo;

        //#endregion

        api = "";
        dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 338); //pr_consulta_aprovacao_parada

        api = dados.nm_identificacao_api;

        let sParametroApi = dados.nm_api_parametro;

        var dataSourceConfigs = [];
        dataSourceConfigs = await Producao.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        );

        this.formData = dataSourceConfigs[0];

        if (dataSourceConfigs[0].Codigo == 1) {
          notify("PRODUÇÃO INICIADA!");
          this.inotifica = 1;
        } else {
          notify("ERRO AO INICIAR PRODUÇÃO!");
          this.inotifica = 1;
        }
      }
    },

    limpa_tudo() {
      this.turno = "";
      this.operador = "";
      this.data = "";
      this.entrega = "";
      this.cliente = "";
      this.produto = "";
      this.pedido = "";
      this.qtd = "";
      this.larg = "";
      this.esp = "";
      this.comp = "";
      this.vol = "";
      this.peso = "";
      this.composicao = "";
      this.peso_un = "";
      this.peso_esp = "";
      this.peso_emb = "";
      this.obs = "";
      this.ds_processo = "";
      this.sg_unidade_medida = "";
      this.cd_item_req_interna = "";
      this.cd_requiscao_interna = "";
      this.cd_requisicao_interna = "";
      this.sg_unidade_processo = "";
      this.qt_utilizada = "";
      this.cd_mascara_produto = "";
      this.qt_planejada_processo = "";
      this.cd_processo_padrao = "";
      this.caminho_desenho = "";
      this.desenho_processo = "";
      this.cd_maquina = "";
      this.cd_item_processo = "";
      this.cd_operador = "";
      this.cd_operacao = "";
      this.saldo = "";
      this.medidas = "";
      this.sequencia = "";
      this.operacao_nm = "";
      this.setup = "";
      this.prod = "";
      this.qt_produzida = 0;
    },

    onClickFecharTab() {
      this.tabPanel = false;
      this.ic_form_menu = "S";
      this.refugo = false;
      this.parada = false;
      this.button_operador = 0;
    },

    onClickSetupFim() {
      this.ic_form_menu = "S";
      this.fimproducao = true;
      this.qtd_producao = this.saldo;
    },
    trocaTipo() {
      var cd_parada = 0;
      cd_parada = this.lookup_dataset.findIndex(
        (obj) => obj.cd_tipo_maquina_parada == this.causa_parada
      );
      if (this.lookup_dataset[cd_parada].ic_operador_parada == "S") {
        this.ic_troca_operador = true;
      } else {
        this.ic_troca_operador = false;
      }
    },

    async onClickParada() {
      var api = "540/747"; //pr_lookup_maquina_turno_operador
      var ParamApi = "/${cd_empresa}/${cd_parametro}/${cd_usuario}";
      this.lookup_operador = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        ParamApi
      );
      this.lookup_dataset_operador = JSON.parse(
        this.lookup_operador[0].operadores
      );

      if (this.apontamento_parada == 0) {
        this.status_parada = "INICIO DA PARADA";
      } else {
        this.status_parada = "FIM DA PARADA";
      }

      this.ic_parada = false;
      this.tabPanel = true;
      this.ic_form_menu = "G";
      this.iTipoComponente = 2;
      this.parada = true;
    },

    async onTrocar() {
      let linha = await grid.Selecionada();

      if (!!linha.nm_funcionario == false) {
        notify("Selecione o operador!");
        return;
      }
      this.operador = linha.nm_funcionario;
      //this.operador = a.
      this.cd_operador = linha.cd_turno;
      this.tabPanel = false;
      this.ic_form_menu = "S";
      this.refugo = false;
      this.parada = false;
      this.button_operador = 0;
    },

    onClikInstrucao() {
      if (this.instrucoes == false) {
        this.instrucoes = true;
      } else {
        this.instrucoes = false;
      }
    },

    onClickProducao() {
      this.tabPanel = true;
      this.ic_form_menu = "G";
      this.iTipoComponente = 4;
    },

    onClickRefugo() {
      this.tabPanel = true;
      this.ic_form_menu = "G";
      this.iTipoComponente = 5;
      this.refugo = true;
    },

    onClickProgramacao() {
      if (this.ic_form_menu_prox == "S") {
        this.ic_form_menu_prox = "N";
      } else {
        this.ic_form_menu_prox = "S";
      }
    },

    onClickApontamento() {
      this.tabPanel = true;
      this.ic_form_menu = "G";
      this.iTipoComponente = 1;
      this.button_cancelar = 1;

      if (this.button_operador == 1) {
        this.button_operador = 0;
        this.button_cancelar = 1;
      } else {
        this.button_operador = 1;
      }
    },

    onClickComponentes() {
      this.tabPanel = true;
      this.ic_form_menu = "G";
      this.iTipoComponente = 3;
    },
    onClickOperacao() {
      this.tabPanel = true;
      this.ic_form_menu = "G";
      this.iTipoComponente = 6;
    },
    onClickComponentes_grid() {
      this.grid_hist = false;
      this.grid_inst = false;
      if (this.grid_comp == true) {
        this.grid_comp = false;
      } else {
        this.grid_comp = true;
      }
    },
    onClickHitstorico_grid() {
      this.grid_inst = false;
      this.grid_comp = false;
      if (this.grid_hist == true) {
        this.grid_hist = false;
      } else {
        this.grid_hist = true;
      }
    },
    onClickInstrucoes_grid() {
      this.grid_comp = false;
      this.grid_hist = false;
      if (this.grid_inst == true) {
        this.grid_inst = false;
      } else {
        this.grid_inst = true;
      }
    },

    onClickManutencao() {
      this.manutencao = true;
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component;
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

    destroyed() {
      this.$destroy();
    },
  },
};
</script>

<style scoped>
.task-info {
  font-family: Segoe UI;
  min-height: 200px;
  display: flex;
  flex-wrap: nowrap;
  border: 2px solid rgba(0, 0, 0, 0.1);
  padding: 5px;
  box-sizing: border-box;
  align-items: baseline;
  justify-content: space-between;
  margin-left: 10px;
  margin-right: 10px;
}

#taskSubject {
  line-height: 29px;
  font-size: 18px;
  font-weight: bold;
}

#taskDetails {
  line-height: 22px;
  font-size: 14px;
  margin-top: 0;
  margin-bottom: 0;
  padding-left: 10px;
}

.info {
  margin-right: 40px;
}

.options {
  margin-top: 20px;
  padding: 20px;
  background-color: rgba(191, 191, 191, 0.15);
  position: relative;
}

.caption {
  font-size: 18px;
  font-weight: 500;
}

.option {
  margin-top: 10px;
  margin-right: 40px;
  display: inline-block;
}

.option:last-child {
  margin-right: 0;
}

.option > .dx-numberbox {
  width: 200px;
  display: inline-block;
  vertical-align: middle;
}

.option > span {
  margin-right: 10px;
}

.botao-info {
  float: right;
  right: 10px;
}

.info-periodo {
  margin-top: 10px;
  float: right;
  margin-right: 25px;
  right: 10px;
  font-size: 16px;
}

.info-cor {
  color: #506ad4;
  font-size: 20px;
}

#form-container {
  margin: 10px 10px 30px;
}

.infos {
  margin-bottom: 10px;
  text-align: left;
  font-size: 15px;
}

.coluna-501 {
  width: 30%;
  margin-left: 1%;
  margin-right: 1%;
}

.linha {
  display: flex;
  flex-flow: row wrap;
  margin: 1%;
}

.my-card {
  width: 100%;
  max-width: 350px;
}

.dx-dropdownlist-popup-wrapper
  .dx-list:not(.dx-list-select-decorator-enabled)
  .dx-list-item-content {
  padding-left: 7px;
  padding-right: 7px;
}

.desenho {
  font-size: 20px;
  margin-top: 5px;
  margin-bottom: 5px;
}

select {
  width: 100%; /* Tamanho do select, maior que o tamanho da div "div-select" */
  height: 53px; /* altura do select, importante para que tenha a mesma altura em todo os navegadores */
  border-radius: 4px;
  border-color: #c2c2c2;
  font-size: 20px; /* Tamanho da Fonte */
  color: #000; /* Cor da Fonte */
  text-indent: 0.01px; /* Remove seta padrão do FireFox */
  text-overflow: ""; /* Remove seta padrão do FireFox */
}

.label_desenho {
  margin-left: 10px;
  display: block;
  float: left;
  width: 200px;
}

.label_manutencao {
  color: white;
  margin-left: 10px;
  display: block;
  float: left;
  width: 200px;
}

.input {
  font-size: 20px;
}

.div_botao_solicitacao {
  width: 20%;
  text-align: right;
  margin-right: 0px;
}

.agendamento {
  width: 80%;
  text-align: left;
  color: black;
  font-size: 20px;
}

.manutencao {
  height: 60px;
  font-size: 20px;
  margin-bottom: 0px;
  border-bottom: 1px solid white;
  background-color: #1976d2;
}

.label_data {
  color: black;
  margin-left: 15px;
  font-size: 20px;
}

.manutencao_baixo {
  background-color: white;
}

.todas {
  width: 98%;
  display: inline-flex;
}

.div50 {
  width: 50%;
}

.div48 {
  width: 49%;
  text-align: right;
}

.bola-verde {
  text-align: center;
  width: 75px;
  background-color: green;
  height: 75px;
  border-radius: 100%;
}

.bola-amarela {
  text-align: left;
  width: 75px;
  background-color: yellow;
  height: 75px;
  border-radius: 100%;
}

.bola-vermelho {
  text-align: left;
  width: 75px;
  background-color: red;
  height: 75px;
  border-radius: 100%;
}

.title {
  display: flex;
  flex-flow: row wrap;
  margin: 1%;
}

.tipo_maquina_parada {
  margin-top: 22px;
  margin-left: 35px;
  margin-right: 15px;
  font-size: 25px;
}

#hora_atual {
  margin-right: 15px;
  left: 0;
}
.margin1 {
  margin: 0.5vh 0.5vw;
}
</style>
