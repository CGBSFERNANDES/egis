<template>
  <div>
    <div>
      <div class="text-h6 margin1" style="display: flex; justify-content: space-between">
        <div v-if="ic_pagina_modulo === 'S'">
          <div v-show="!load_pagina">
            <div class="margin1 row justify-end">
              <q-btn
                class="margin1"
                round
                color="primary"
                icon="restart_alt"
                @click="recarregarHTML()"
              >
                <q-tooltip> Recarregar </q-tooltip>
              </q-btn>

              <q-btn
                round
                class="margin1"
                color="primary"
                icon="close"
                @click="ic_pagina_modulo = 'N'"
              >
                <q-tooltip> Fechar </q-tooltip>
              </q-btn>
            </div>
            <HTMLDinamico
              @semIframe="ic_pagina_modulo = 'N'"
              :cd_pagina_modulo="cd_pagina_modulo"
            />
          </div>
          <div v-show="load_pagina" class="flex flex-center" style="height: 100vh">
            <q-spinner color="primary" size="10rem" />
          </div>
        </div>

        <div>
          {{ tituloMenu }}

          <div v-if="showDashboard" class="dashboard">
            <div flat class="q-pa-sm" style="height: 100vh; width: 100vw">
              <!-- Fechar -->
              <q-btn
                flat
                dense
                round
                icon="close"
                class="absolute-top-right q-ma-sm"
                @click="abrirDashboard()"
                aria-label="Fechar"
              />

              <!-- Seu novo dashboard -->
              <dashBoard_Componente
                :cd-modulo="cdModuloDash"
                :cd-usuario="cdUsuarioDash"
                :dt-inicial="dtInicialDash"
                :dt-final="dtFinalDash"
              />
            </div>
          </div>

          <template v-if="!showDashboard">
            <q-badge align="middle" rounded color="red" :label.sync="qt_registro" />
            <q-btn
              round
              color="primary"
              class="margin1"
              @click="$emit('GraficoKanban')"
              icon="calendar_view_week"
            >
              <q-tooltip> Gráfico </q-tooltip>
            </q-btn>

            <q-btn
              class="btn-dash"
              round
              color="deep-orange-6"
              v-if="cd_pagina_modulo > 0 && ic_pagina_modulo === 'N'"
              @click="abrirDashboard"
              icon="dashboard"
            >
              <q-tooltip> Dashboard </q-tooltip>
            </q-btn>
          </template>
        </div>

        <!-- Indicadores -->
        <!-- <div>
          <q-fab v-if="dados_indicador" :loading="load_indicador" align="right" class="margin1" color="orange-9" text-color="white" icon="keyboard_arrow_left" direction="left" >
            <q-fab-action flat v-for="(indicador, index) in dados_indicador" :key="index">
              <div class="conteudo">
                <div class="aviso">{{ indicador.nm_aviso_sistema }}</div>
                <div class="resultado">{{ indicador.nm_resultado }}</div>
              </div>
            </q-fab-action>
          </q-fab>
        </div> -->
      </div>
      <!-- <painelModulo></painelModulo> -->
      <section v-if="!showDashboard">
        <div class="arrows">
          <q-btn
            rounded
            flat
            color="orange-9"
            text-color="orange-9"
            icon="arrow_back"
            @click="scrollKanban('left')"
          />
          <q-btn
            rounded
            flat
            color="orange-9"
            text-color="orange-9"
            icon="arrow_forward"
            @click="scrollKanban('right')"
          />
        </div>
        <div v-if="false">
          <relatoriop ref="relatoriopadrao" :cd_relatorioID="1" />
        </div>
        <div v-if="popup_premio == true">
          <q-dialog v-model="popup_premio" full-width full-height>
            <q-card>
              <q-card-section class="FundoPremio row">
                <div class="items-center justify-center col">
                  <div class="text-h3">{{ this.nome_premio }}</div>
                  <premio :qt_pontoID="2"></premio>
                  <div class="text-h5">{{ 'RS: ' + this.cd_movimento }}</div>
                  <div class="text-h5">
                    {{ 'Posição: ' + this.cd_posicao + 'º' }}
                  </div>
                  <div class="text-h5">
                    {{ 'Pontuação Acumulada: ' + this.cd_pontuacao }}
                  </div>
                </div>
                <div class="MeuGif col">
                  <q-img src="https://i.chzbgr.com/full/8481508608/h719B5595/que" />
                </div>
                <!--<h5>{{'Contato: ' + this.contato_premio}} {{'Empresa: '+ this.empresa_premio}}</h5>-->
              </q-card-section>
            </q-card>
          </q-dialog>
        </div>

        <q-toolbar
          class="row items-center bg-white shadow-1 toolbar-center text-primary text-center margin1"
          style="border-radius: 20px; height: 20px"
        >
          <!-- <q-btn-dropdown
          v-if="resultadoForm.length > 0"
          flat
          rounded
          dense
          color="orange-9"
          icon="description"
        >
          <div
            clickable
            v-close-popup
            class="margin1 row"
            v-for="(n, index) of resultadoForm"
            :key="index"
          >
            <q-btn
              unelevated
              :dark-percentage="false"
              flat
              color="black"
              rounded
              dense
              size="sm"
              :label="n.nm_form"
              @click="onDashboard(n)"
            />
          </div>
        </q-btn-dropdown> -->
          <q-btn flat round color="orange-9" dense icon="dashboard" @click="onGraficos($event)">
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Gráficos
            </q-tooltip>
          </q-btn>

          <q-btn
            flat
            round
            color="orange-9"
            dense
            :disable="ic_processo_modulo"
            icon="account_tree"
            @click="onProcessos($event)"
          >
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Processos
            </q-tooltip>
          </q-btn>
          <q-btn flat round color="orange-9" dense icon="publish" @click="onImportacao($event)">
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Importação
            </q-tooltip>
          </q-btn>
          <q-btn
            v-if="false"
            flat
            round
            color="orange-9"
            dense
            icon="ads_click"
            @click="onSelecao($event)"
          >
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Seleção
            </q-tooltip>
          </q-btn>
          <!-- Botões por Módulo -->
          <div v-for="(btn_barra, index) in dados_botoes_barra" :key="index">
            <q-btn
              style="text-transform: none; margin-left: 5px"
              rounded
              color="primary"
              size="sm"
              :label="btn_barra.nm_badge_barra_etapa"
              :icon="btn_barra.nm_icone || undefined"
              @click="onBotaoModulo(btn_barra)"
            >
              <q-tooltip
                v-if="btn_barra.nm_tooltip"
                anchor="bottom middle"
                self="top middle"
                :offset="[10, 10]"
              >
                {{ `${btn_barra.nm_tooltip || ''}` }}
              </q-tooltip>
            </q-btn>
          </div>
          <q-toolbar-title>
            <q-btn
              v-show="items.length > 0"
              v-for="(b, index) in items"
              :key="index"
              round
              size="sm"
              style="margin: 2.5px; float: left"
              color="primary"
              @click="ReordenaEtapa(b)"
              :loading="load_delete"
              :label="b.nm_etapa.substr(0, 1)"
            >
              <q-tooltip>{{ b.nm_etapa }}</q-tooltip>
            </q-btn>

            <div class="margin1 msgCentral">
              Etapas - {{ hoje }}
              <q-badge color="primary" rounded align="top">{{ dia_semana }}</q-badge>
              <q-btn
                class="paginationButton"
                v-if="paginationEtapa.length > 0"
                flat
                round
                color="orange-9"
                dense
                icon="arrow_downward"
                @click="addCards()"
              >
                <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                  Adicionar registros no Kanban
                </q-tooltip>
              </q-btn>
              <q-btn
                v-if="cd_modulo == 241 && cd_empresa == 354"
                class="paginationButton"
                flat
                round
                color="deep-purple"
                dense
                icon="print"
                @click="AbreGeraRelatorioGeral()"
              >
                <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                  Geração de Relatórios Geral
                </q-tooltip>
              </q-btn>
              <q-btn
                class="paginationButton"
                flat
                round
                color="orange-9"
                dense
                icon="filter_list"
                @click="AbreFiltro()"
              >
                <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                  Filtrar Kanban
                </q-tooltip>
              </q-btn>

              <q-btn
                v-if="filtroGeral"
                class="paginationButton"
                flat
                round
                color="orange-9"
                dense
                icon="cleaning_services"
                @click="FiltrarEtapa({}, 2, $event)"
              >
                <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                  Limpar filtros do Kanban
                </q-tooltip>
              </q-btn>
            </div>
          </q-toolbar-title>
          <q-btn flat round color="orange-9" dense icon="task" @click="onRelatorioPopup()">
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Relatório do Módulo
            </q-tooltip>
          </q-btn>
          <q-btn
            flat
            round
            color="orange-9"
            dense
            icon="analytics"
            @click="ic_grafico_do_kanban = !ic_grafico_do_kanban"
          >
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Gráfico do Kanban
            </q-tooltip>
          </q-btn>

          <q-btn flat round color="orange-9" dense icon="view_list" @click="withGrid = !withGrid">
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Tabela do Kanban
            </q-tooltip>
          </q-btn>

          <q-toggle icon="refresh" v-model="refresh" color="orange-9">
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              <b v-if="refresh == true"> Desliga carregamento automático </b>
              <b v-else> Liga carregamento automático </b>
            </q-tooltip>
          </q-toggle>
          <!-- <q-btn-dropdown
          :loading="load_atividade"
          flat
          rounded
          v-if="atividade_modulo.length > 0"
          dense
          color="orange-9"
          icon="description"
        >
          <q-list class="margin1">
            <q-item
              clickable
              v-close-popup
              class="row"
              v-for="(n, index) of atividade_modulo"
              v-bind:key="index"
            >
              <q-item-section avatar>
                <q-avatar
                  :icon="n.nm_icone_atributo"
                  :color="n.nm_valor_cor"
                  text-color="white"
                >
                  <q-badge :color="n.nm_valor_cor" floating rounded>{{
                    `${n.cd_tipo_atividade}`
                  }}</q-badge>
                </q-avatar>
              </q-item-section>
              <q-item-section>
                <q-item-label>{{ n.nm_tipo_atividade }}</q-item-label>
              </q-item-section>
              <q-item-section side v-show="n.cd_tipo_prioridade == 1">
                <q-icon name="info" color="negative" />
              </q-item-section>
            </q-item>
          </q-list>
          <q-tooltip
            anchor="bottom middle"
            self="top middle"
            :offset="[10, 10]"
          >
            Atividades
          </q-tooltip>
        </q-btn-dropdown> -->

          <q-btn
            flat
            round
            color="orange-9"
            dense
            icon="cleaning_services"
            @click="FiltrarEtapa({}, 2, $event)"
          >
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Limpar Filtro
            </q-tooltip>
          </q-btn>

          <q-btn
            flat
            color="orange-9"
            round
            id="CarregamentoF5"
            dense
            icon="autorenew"
            :loading="load_carregar"
            @click="carregaDados()"
          >
            <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
              Recarregar
            </q-tooltip>
          </q-btn>
        </q-toolbar>

        <div v-if="showCard == true" class="q-pa-md" style="max-width: 550px">
          <q-toolbar class="bg-primary text-white shadow-2">
            <q-toolbar-title>Operadores</q-toolbar-title>
          </q-toolbar>

          <q-list bordered separator>
            <q-item
              v-for="operador in operadores"
              :key="operador.cd_controle"
              class="q-my-sm"
              clickable
              v-ripple
            >
              <q-item-section avatar>
                <q-avatar color="primary" text-color="white">
                  {{ operador.nm_usuario.charAt(0) }}
                </q-avatar>
              </q-item-section>

              <q-item-section>
                <q-item-label>{{ operador.nm_usuario }}</q-item-label>
                <q-item-label caption lines="1">{{ operador.nm_email_usuario }}</q-item-label>
              </q-item-section>
              <q-item-section>
                <q-item-label></q-item-label>
                <q-item-label caption lines="1"
                  >Fone: {{ operador.cd_telefone_usuario }}</q-item-label
                >
              </q-item-section>

              <q-item-section side>
                <q-badge :color="operador.ic_disponivel == 'Sim' ? 'light-green-5' : 'red'">
                  {{ operador.ic_disponivel == 'Sim' ? 'OnLine' : 'Indisponível' }}
                </q-badge>
              </q-item-section>
            </q-item>
          </q-list>
        </div>

        <grid
          class="margin1"
          v-if="withGrid == true"
          :cd_menuID="7198"
          :cd_apiID="569"
          :cd_identificacaoID="569 / 788"
          :cd_parametroID="1"
          :cd_usuarioID="0"
          :cd_consulta="0"
          :nm_json="this.nm_jsonp"
          ref="grid_c"
        >
        </grid>

        <!---POP UP DO MAPA---->
        <q-dialog
          v-model="popup_mapa"
          persistent
          :maximized="maximizedToggle"
          transition-show="slide-up"
          transition-hide="slide-down"
        >
          <q-card>
            <q-bar class="bg-deep-orange-3">
              <q-space />

              <q-btn
                dense
                flat
                icon="minimize"
                @click="maximizedToggle = false"
                :disable="!maximizedToggle"
              >
                <q-tooltip v-if="maximizedToggle" class="bg-orange text-white">Minimizar</q-tooltip>
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

            <q-card-section class="q-pt-none">
              <mapaRoteiro></mapaRoteiro>
            </q-card-section>
          </q-card>
        </q-dialog>
        <!---POP UP DO LINK---->
        <q-dialog
          v-model="popup_link"
          persistent
          transition-show="slide-up"
          transition-hide="slide-down"
        >
          <q-card>
            <q-bar class="bg-deep-orange-3"
              >{{ nm_titulo_link }}
              <q-space />

              <q-btn
                dense
                flat
                icon="minimize"
                @click="maximizedToggle = false"
                :disable="!maximizedToggle"
              >
                <q-tooltip v-if="maximizedToggle" class="bg-orange text-white">Minimizar</q-tooltip>
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

            <q-card-section class="q-pt-none">
              <a :href="nm_link" _blank>{{ nm_link }}</a>
              <img v-bind:src="this.nm_img_link" />
            </q-card-section>
          </q-card>
        </q-dialog>
        <!------------>
        <q-dialog
          v-model="popupDocCard"
          persistent
          :maximized="maximizedToggle"
          transition-show="slide-up"
          transition-hide="slide-down"
        >
          <q-card>
            <q-bar class="bg-deep-orange-3 text-white">
              Cadastro de Documento
              <q-space />

              <q-btn
                dense
                flat
                icon="minimize"
                @click="maximizedToggle = false"
                :disable="!maximizedToggle"
              >
                <q-tooltip v-if="maximizedToggle" class="bg-orange text-white">Minimizar</q-tooltip>
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
            <!--v-if="!this.cd_documento==0" Parâmetro para verificar se abre o doc ou documentosCRUD-->
            <q-card-section class="q-pt-none">
              <!-- <doc
              :cd_documentoID="this.cd_documento"
              :cd_grava_etapa="this.grava_etapa"
              :cd_grava_mov="this.grava_mov"
            >
          </doc> -->
              <documentosCRUD
                :documento_json="this.card_json"
                :nm_origem="this.titulo_bar"
                :cd_documentoID="this.cd_documento"
                :Fantasia="this.nm_destinatario"
              ></documentosCRUD>
            </q-card-section>
          </q-card>
        </q-dialog>

        <div id="kanban" v-if="withGrid == false">
          <DxScrollView
            ref="kanbanScrollRef"
            class="scrollable-board"
            direction="horizontal"
            show-scrollbar="always"
          >
            <DxSortable
              class="sortable-lists"
              item-orientation="horizontal"
              handle=".list-title"
              @reorder="onListReorder"
            >
              <!-- Grafico -->
              <DxPieChart
                v-if="ic_grafico_do_kanban"
                id="pie"
                :data-source="dataSourceConfig"
                title=""
                palette="Soft Pastel"
                @point-click="pointClickHandler"
              >
                <DxSeries argument-field="nm_etapa" value-field="vl_etapa">
                  <DxLabel :visible="true">
                    <DxConnector :visible="true" />
                  </DxLabel>
                  <DxHoverStyle color="#ffd700" />
                </DxSeries>

                <DxExport :enabled="true" :margin-left="0" horizontal-alignment="left" />

                <DxLegend :margin="-50" horizontal-alignment="left" vertical-alignment="top" />

                <DxTooltip :enabled="true" :customize-tooltip="customizeTooltip"> </DxTooltip>
              </DxPieChart>
              <div v-if="!ic_grafico_do_kanban">
                <div v-for="(e, index) in dataSourceConfig" :key="index" class="list">
                  <div class="list-title items-center">
                    <q-btn
                      v-if="e.ic_grafico_etapa == 'S'"
                      @click="onClickGrafico(e)"
                      round
                      flat
                      icon="analytics"
                      class="text-indigo-10"
                      size="0.7em"
                    />
                    <q-btn
                      v-if="e.ic_grafico_etapa == 'N'"
                      icon="today"
                      class="text-grey"
                      round
                      flat
                      size="0.7em"
                    />

                    <b @click="onClickProcesso(e)">{{ e.nm_etapa }}</b>
                    <q-badge
                      v-if="!!e.qt_etapa"
                      class=""
                      align="top"
                      rounded
                      color="blue"
                      :label="e.qt_etapa"
                    />

                    <q-badge
                      class=""
                      v-if="
                        !!e.nm_valor_etapa &&
                        e.nm_valor_etapa.trim() != 'R$ NaN' &&
                        e.nm_valor_etapa.trim() != 'R$ 0,00'
                      "
                      align="top"
                      rounded
                      color="positive"
                      :label="e.nm_valor_etapa"
                    />
                    <q-badge
                      class="badge-data"
                      v-if="!!e.dt_etapa"
                      align="top"
                      rounded
                      color="accent"
                      :label="e.dt_etapa"
                    />

                    <q-btn
                      flat
                      v-if="e.ic_documento_etapa == 'S'"
                      icon="attach_file"
                      round
                      @click="onClick(e)"
                      color="deep-orange-7"
                      size="0.7em"
                    />

                    <q-btn
                      v-if="cd_modulo == 241 && cd_empresa == 354 && !!e.qt_etapa"
                      flat
                      round
                      color="deep-purple"
                      dense
                      icon="print"
                      @click="AbreGeraRelatorio(e)"
                    >
                      <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                        Geração de Relatórios
                      </q-tooltip>
                    </q-btn>

                    <q-btn
                      push
                      round
                      color="orange-9"
                      @click="AbreFiltro(e)"
                      flat
                      icon="filter_list"
                      size="0.7em"
                    >
                      <q-tooltip> Filtrar </q-tooltip>
                    </q-btn>

                    <q-btn
                      v-if="e.mostraFiltro == 'S'"
                      push
                      round
                      color="orange-9"
                      @click="FiltrarEtapa({}, 2, e)"
                      flat
                      icon="cleaning_services"
                      size="0.7em"
                    >
                      <q-tooltip> Limpar filtro </q-tooltip>
                    </q-btn>

                    <q-btn
                      @click="onRemoveEtapa(e)"
                      round
                      :loading="load_delete"
                      flat
                      icon="delete_outline"
                      class="text-grey"
                      size="0.6em"
                    />
                    <q-btn
                      v-if="dataCheckbox.some((element) => element.cd_etapa === e.cd_etapa)"
                      class="esquerda"
                      icon="arrow_forward"
                      round
                      @click="pop_multi_cards = true"
                      color="primary"
                      size="0.6em"
                    >
                      <q-tooltip> Enviar {{ e.nm_etapa }} </q-tooltip>
                    </q-btn>
                  </div>

                  <DxPieChart
                    v-if="
                      ic_grafico_do_kanban_individual &&
                      e.cd_etapa == dados_kanban_etapa[0].cd_etapa
                    "
                    id="pie"
                    :data-source="dados_kanban_etapa"
                    title=""
                    palette="Soft Pastel"
                    @point-click="pointClickHandler"
                  >
                    <DxSeries argument-field="nm_destinatario" value-field="vl_etapa">
                      <DxLabel :visible="true">
                        <DxConnector :visible="true" />
                      </DxLabel>
                      <DxHoverStyle color="#ffd700" />
                    </DxSeries>

                    <DxExport :enabled="true" :margin-left="0" horizontal-alignment="left" />

                    <DxLegend :margin="-50" horizontal-alignment="left" vertical-alignment="top" />

                    <DxTooltip :enabled="true" :customize-tooltip="customizeTooltip"> </DxTooltip>
                  </DxPieChart>
                  <DxScrollView class="scrollable-list" show-scrollbar="always">
                    <DxSortable
                      ref="dxSortable"
                      :data="dados_pipeline"
                      class="sortable-cards"
                      group="tasksGroup"
                      @drag-start="onTaskDragStart($event, e.cd_etapa)"
                      @reorder="verificaEtapas($event, e.cd_etapa)"
                      @add="verificaEtapas($event, e.cd_etapa)"
                    >
                      <div v-for="(d, index) in dados_pipeline" :key="index">
                        <div
                          class="dx-card dx-theme-text-color dx-theme-background-color card"
                          v-if="e.cd_etapa == d.cd_etapa && d.mostraFiltro == 'S'"
                        >
                          <div
                            style="
                              position: absolute;
                              top: 10px;
                              bottom: 10px;
                              left: 5px;
                              width: 5px;
                              border-radius: 2px;
                            "
                            class="bg-accent"
                          ></div>

                          <div class="card-subject">
                            <q-checkbox
                              v-if="e.nm_processo"
                              v-model="d.nm_status"
                              checked-icon="star"
                              unchecked-icon="star_border"
                              indeterminate-icon="help"
                              true-value="S"
                              false-value=""
                              indeterminate-value=""
                              size="xs"
                              @input="onCheckBox({ ...e, ...d })"
                            />
                            <b v-if="!!d.nm_destinatario">{{ d.nm_destinatario }}</b>

                            <q-badge
                              class="esquerda"
                              align="top"
                              rounded
                              color="yellow-6"
                              text-color="black"
                              :label="d.cd_movimento"
                            />
                            <q-separator />
                          </div>

                          <div
                            class="card-assignee"
                            v-if="!!d.sg_modulo"
                            v-html="nl2brSafe(d.sg_modulo)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_contato"
                            v-html="nl2brSafe(d.nm_contato)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_ocorrencia"
                            v-html="nl2brSafe(d.nm_ocorrencia)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_responsavel"
                            v-html="nl2brSafe(d.nm_responsavel)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_executor"
                            v-html="nl2brSafe(d.nm_executor)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_atendimento"
                            v-html="nl2brSafe(d.nm_atendimento)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_campo1"
                            v-html="nl2brSafe(d.nm_campo1)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_campo2"
                            v-html="nl2brSafe(d.nm_campo2)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_campo3"
                            v-html="nl2brSafe(d.nm_campo3)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_campo4"
                            v-html="nl2brSafe(d.nm_campo4)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_campo5"
                            v-html="nl2brSafe(d.nm_campo5)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_campo6"
                            v-html="nl2brSafe(d.nm_campo6)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_campo7"
                            v-html="nl2brSafe(d.nm_campo7)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_campo8"
                            v-html="nl2brSafe(d.nm_campo8)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_campo9"
                            v-html="nl2brSafe(d.nm_campo9)"
                          ></div>
                          <div
                            class="card-assignee"
                            v-if="!!d.nm_campo10"
                            v-html="nl2brSafe(d.nm_campo10)"
                          ></div>

                          <div class="card-assignee">
                            {{ d.dt_movimento }}

                            <q-btn class="esquerda" v-if="!!d.nm_financeiro == true" color="blue">
                              {{ d.nm_financeiro }}
                              <q-badge color="red" rounded floating />
                            </q-btn>
                            <div>
                              <q-separator inset size="0.1em" style="margin: 0 0 5px 0" />

                              <div
                                v-show="flag_temporario == true"
                                v-for="(a, q) in StatusTemporario"
                                :key="'Q' + q"
                                class="row"
                                style="display: inline-block; margin: 0"
                              >
                                <div
                                  v-if="
                                    d.cd_etapa == a.cd_etapa && d.cd_movimento == a.cd_movimento
                                  "
                                >
                                  <q-badge
                                    v-if="
                                      d.cd_etapa == a.cd_etapa &&
                                      d.cd_movimento == a.cd_movimento &&
                                      a.ic_adiciona == true
                                    "
                                    class="direita"
                                    rounded
                                    :color="a.nm_cor_status"
                                    :text-color="a.nm_cor_texto"
                                    :label="a.nm_status"
                                  />
                                </div>
                              </div>

                              <div
                                v-for="(s, i) in dados_status"
                                class="row"
                                v-show="
                                  d.cd_etapa == s.cd_etapa && d.cd_documento == s.cd_documento
                                "
                                style="display: inline-block; margin: 0"
                                :key="i"
                              >
                                <q-badge
                                  v-if="
                                    d.cd_etapa == s.cd_etapa && d.cd_documento == s.cd_documento
                                  "
                                  class="direita"
                                  rounded
                                  :color="s.nm_cor_status"
                                  :text-color="s.nm_cor_texto"
                                  :label="s.nm_status"
                                />
                              </div>
                            </div>
                          </div>

                          <div class="direita" style="margin: 5px 0 3px 0">
                            <q-btn
                              v-if="!e.cd_link == 0"
                              class="esquerda"
                              icon="link"
                              round
                              @click="onLink(e, d)"
                              color="grey-8"
                              size="0.6em"
                            >
                              <q-tooltip> Link {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>

                            <q-btn
                              v-show="cd_empresa == 150 && cd_modulo == 310"
                              class="esquerda"
                              icon="manage_search"
                              round
                              @click="onEditHistorico(d, e, index, dados_pipeline)"
                              color="light-blue-7"
                              size="0.6em"
                            >
                              <q-tooltip> Histórico </q-tooltip>
                            </q-btn>

                            <q-btn
                              class="esquerda"
                              icon="local_offer"
                              round
                              v-if="e.ic_status_etapa == 'S'"
                              @click="onEditStatusCard(d, e, index, dados_pipeline)"
                              color="orange-9"
                              size="0.6em"
                            >
                              <q-tooltip> Status {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>

                            <q-btn
                              v-if="e.ic_edicao_etapa == 'S' && e.ic_edit_titulo_etapa !== 'S'"
                              class="esquerda"
                              icon="mode_edit"
                              round
                              @click="onEditOportunidade(d, e)"
                              color="primary"
                              size="0.6em"
                            >
                              <q-tooltip> Editar {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>
                            <q-btn
                              v-if="e.ic_documento_etapa == 'S' && !d.cd_documento == 0"
                              class="esquerda"
                              icon="attach_file"
                              round
                              @click="onClickDocCard(d, index)"
                              color="grey-10"
                              size="0.6em"
                            >
                              <q-tooltip> Documento {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>
                            <!--

                          -->
                            <q-btn
                              v-if="e.ic_mensagem_etapa == 'S'"
                              class="esquerda"
                              icon="img:/whatsapp.svg"
                              round
                              @click="onEnviarWhatsApp(d, e)"
                              color="green"
                              size="0.6em"
                            >
                              <q-tooltip> Enviar WhatsApp </q-tooltip>
                            </q-btn>
                            <!---->
                            <q-btn
                              v-if="e.cd_tipo_email > 0"
                              class="esquerda"
                              icon="email"
                              round
                              @click="onEnviarEmail(d)"
                              color="teal-7"
                              size="0.6em"
                            >
                              <q-tooltip> Enviar E-mail </q-tooltip>
                            </q-btn>
                            <q-btn
                              v-if="!d.cd_relatorio == 0"
                              class="esquerda"
                              icon="print"
                              round
                              @click="onClickRelatorio(d, index, e)"
                              color="blue-grey-6"
                              size="0.6em"
                            >
                              <q-tooltip> Relatório {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>
                            <q-btn
                              v-if="d.ic_detalhe_etapa == 'S' && !d.cd_documento == 0"
                              class="esquerda"
                              icon="view_list"
                              round
                              @click="onClickNoCard(e, d, dados_pipeline)"
                              color="pink-5"
                              size="0.6em"
                            >
                              <q-tooltip> Consulta {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>

                            <q-btn
                              v-if="e.ic_informativo == 'S'"
                              class="esquerda"
                              icon="insights"
                              round
                              color="deep-orange"
                              size="0.6em"
                            >
                              <q-tooltip> Informativo {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>
                            <q-btn
                              v-if="d.nm_imagem"
                              class="esquerda"
                              icon="image"
                              round
                              color="teal"
                              size="0.6em"
                              @click="onClickVisualizar(d, index, e)"
                            >
                              <q-tooltip> Visualizar {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>
                            <q-btn
                              v-if="d.cd_pagina"
                              class="esquerda"
                              icon="article"
                              round
                              color="deep-purple"
                              size="0.6em"
                              @click="onClickPagina(d)"
                            >
                              <q-tooltip>
                                Detalhe
                                {{ `${d.nm_titulo_pagina_etapa || d.nm_pagina}` }}
                              </q-tooltip>
                            </q-btn>

                            <q-btn
                              v-if="d.nm_nfe_link"
                              class="esquerda"
                              icon="mark_email_read"
                              round
                              color="primary"
                              size="0.6em"
                              @click="onClickEnviarEmailNfe(d)"
                            >
                              <q-tooltip> E-mail {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>

                            <q-btn
                              v-if="d.nm_xml"
                              class="esquerda"
                              icon="sim_card_download"
                              round
                              color="deep-orange"
                              size="0.6em"
                              @click="onClickBaixarXMLNfe(d)"
                            >
                              <q-tooltip> XML {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>

                            <q-btn
                              v-if="d.nm_nfe_link"
                              class="esquerda"
                              icon="task"
                              round
                              color="positive"
                              size="0.6em"
                              @click="onClickAbrirNfe(d, e)"
                            >
                              <q-tooltip> Abrir {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>

                            <q-btn
                              v-if="d.nm_link_nfe_local"
                              class="esquerda"
                              icon="task"
                              round
                              color="black"
                              size="0.6em"
                              @click="onImprimirLocalNfe(d, e)"
                            >
                              <q-tooltip> Imprimir {{ e.nm_etapa }} </q-tooltip>
                            </q-btn>
                          </div>
                          <!-- Botao do lado direito -->
                          <div style="margin: 5px 0 3px 0">
                            <q-btn-dropdown
                              v-if="e.nm_processo"
                              color="yellow-6"
                              text-color="black"
                              class="esquerda"
                              icon="account_tree"
                              rounded
                              size="0.6em"
                            >
                              <q-list>
                                <q-item
                                  v-for="(processo, index) in JSON.parse(e.nm_processo)"
                                  :key="index"
                                  clickable
                                  v-close-popup
                                  @click="onProcessItem(d, e, processo)"
                                >
                                  <q-item-section>
                                    <q-item-label>{{ `${processo.nm_form}` }}</q-item-label>
                                  </q-item-section>
                                </q-item>
                              </q-list>
                              <q-tooltip> Processos {{ e.nm_etapa }} </q-tooltip>
                            </q-btn-dropdown>
                          </div>
                          <div class="card-hour" v-if="!!d.hr_status">
                            {{ d.hr_status }}
                          </div>
                        </div>
                      </div>
                    </DxSortable>
                  </DxScrollView>
                </div>
              </div>
            </DxSortable>
          </DxScrollView>

          <!---------------------------------------->
          <q-dialog v-model="popupConfirm" persistent>
            <q-card>
              <q-card-section class="row items-center">
                <q-avatar icon="check" color="positive" text-color="white" />
                <span class="margin1 text-h6 text-center">
                  Confirmar movimentação para a próxima etapa
                </span>
              </q-card-section>

              <q-card-actions style="justify-content: space-between" class="margin1 row">
                <div style="align-items: start">
                  <q-btn
                    label="Continuar"
                    color="primary"
                    rounded
                    v-close-popup
                    @click="confirmarTroca()"
                  />
                </div>
                <div style="align-items: end">
                  <q-btn
                    flat
                    label="Cancelar"
                    color="primary"
                    rounded
                    v-close-popup
                    @click="cancelarTroca()"
                  />
                </div>
              </q-card-actions>
            </q-card>
          </q-dialog>
          <q-dialog v-model="popup_senha_movimento" persistent>
            <q-card style="min-width: 350px">
              <q-card-section>
                <div class="text-h6">Digite a senha</div>
              </q-card-section>

              <q-card-section class="q-pt-none">
                <q-input
                  dense
                  v-model="nm_senha_digitada"
                  autofocus
                  @keyup.enter="onVerificaSenhaMovimento"
                  type="password"
                />
              </q-card-section>

              <q-card-actions align="right" class="text-primary">
                <q-btn
                  rounded
                  color="primary"
                  label="Confirmar"
                  @click="onVerificaSenhaMovimento"
                />
                <q-btn rounded color="red" label="Cancelar" v-close-popup />
              </q-card-actions>
            </q-card>
          </q-dialog>
          <q-dialog
            v-model="pop_importacao"
            persistent
            :maximized="maximizedToggle"
            transition-show="slide-up"
            transition-hide="slide-down"
          >
            <q-card>
              <q-bar class="bg-deep-orange-9 text-white">
                {{ `Importação  - ${titulo_bar}` }}
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
              <q-card-section class="q-pt-none">
                <importacaoSistema
                  :cd_parametroID="this.cd_etapa"
                  :cd_rotaID="this.cd_rota"
                  :cd_formID="this.cd_form"
                  :cd_apiID="this.cd_api"
                  :cd_menuID="this.cd_menu"
                  :cd_documentoID="this.cd_documento"
                  @click="pop_importacao = false"
                  @dadosgrid="onDataSource($event, undefined, undefined)"
                  :cd_item_documentoID="this.cd_item_documento"
                  :cd_tipo_consultaID="this.cd_menu"
                  :prop_form="this.props_oportunidade"
                >
                </importacaoSistema>
              </q-card-section>
            </q-card>
          </q-dialog>
          <!---------------------------------------->
          <!-- Seleção de Componentes (vue) -->
          <q-dialog
            v-model="pop_selecao"
            persistent
            :maximized="maximizedToggle"
            transition-show="slide-up"
            transition-hide="slide-down"
          >
            <q-card>
              <q-bar class="bg-deep-orange-9 text-white">
                {{ `${titulo_bar}` }}
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
              <q-card-section class="q-pt-none">
                <component :is="dynamicComponent" />
              </q-card-section>
            </q-card>
          </q-dialog>
          <!---------------------------------------->
          <!-- Botões por Módulo chamando Form Especial -->
          <q-dialog
            v-model="pop_botao_modulo"
            persistent
            :maximized="maximizedToggle"
            transition-show="slide-up"
            transition-hide="slide-down"
          >
            <q-card>
              <q-bar class="bg-deep-orange-9 text-white">
                Informações {{ `${titulo_bar}` }}
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
              <q-card-section class="q-pt-none">
                <autoForm
                  :cd_formID="this.cd_form"
                  :cd_rotaID="this.cd_rota"
                  :cd_apiID="this.cd_api"
                  :cd_menuID="this.cd_menu"
                  :cd_documentoID="this.cd_documento"
                  @click="fechaPopBtnSuperior()"
                  @dadosgrid="onDataSource($event, undefined, undefined)"
                  :prop_form="this.props_oportunidade"
                >
                </autoForm>
              </q-card-section>
            </q-card>
          </q-dialog>
          <!---------------------------------------->
          <q-dialog
            v-model="pop_processo"
            persistent
            :maximized="maximizedToggle"
            transition-show="slide-up"
            transition-hide="slide-down"
          >
            <q-card>
              <q-bar class="bg-deep-orange-9 text-white">
                {{ `Processos - ${titulo_bar}` }}
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
              <q-card-section class="q-pt-none">
                <processoSistema
                  :cd_parametroID="this.cd_etapa"
                  :cd_rotaID="this.cd_rota"
                  :cd_formID="this.cd_form"
                  :cd_apiID="this.cd_api"
                  :cd_menuID="this.cd_menu"
                  :cd_documentoID="this.cd_documento"
                  @click="pop_processo = false"
                  @dadosgrid="onDataSource($event, undefined, undefined)"
                  :cd_item_documentoID="this.cd_item_documento"
                  :cd_tipo_consultaID="this.cd_menu"
                  :prop_form="this.props_oportunidade"
                >
                </processoSistema>
              </q-card-section>
            </q-card>
          </q-dialog>
          <!---------------------------------------->
          <q-dialog
            v-model="pop_grafico"
            persistent
            :maximized="maximizedToggle"
            transition-show="slide-up"
            transition-hide="slide-down"
          >
            <q-card>
              <q-bar class="bg-deep-orange-9 text-white">
                {{ `Gráficos - ${titulo_bar}` }}
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
              <q-card-section class="q-pt-none">
                <grafico-modulo
                  :cd_parametroID="this.cd_etapa"
                  :cd_rotaID="this.cd_rota"
                  :cd_formID="this.cd_form"
                  :cd_apiID="this.cd_api"
                  :cd_menuID="this.cd_menu"
                  :cd_documentoID="this.cd_documento"
                  @click="pop_grafico = false"
                  @dadosgrid="onDataSource($event, undefined, undefined)"
                  :cd_item_documentoID="this.cd_item_documento"
                  :cd_tipo_consultaID="this.cd_menu"
                  :prop_form="this.props_oportunidade"
                >
                </grafico-modulo>
              </q-card-section>
            </q-card>
          </q-dialog>
          <!---------------------------------------->
          <q-dialog
            v-model="popupVisible"
            persistent
            :maximized="maximizedToggle"
            transition-show="slide-up"
            transition-hide="slide-down"
          >
            <q-card>
              <q-bar class="bg-deep-orange-9 text-white">
                Informações {{ `${titulo_bar} - ${InfoConsulta.cd_movimento}` }}
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
              <q-card-section class="q-pt-none">
                <div v-if="ic_cab_etapa == 'S'">
                  <div class="row items-center text-h6 margin1">
                    <div class="col">
                      <q-icon name="summarize" color="orange-9" style="margin: 0 5px" size="md" />N°
                      {{ InfoConsulta.cd_movimento }}
                    </div>
                    <div class="col">
                      <q-icon
                        name="payments"
                        color="orange-9"
                        style="margin: 0 5px"
                        size="md"
                      />Condição de Pagamento
                      {{ InfoConsulta.nm_condicao_pagamento }}
                    </div>
                  </div>
                  <div class="row items-center text-h6 margin1">
                    <div class="col">
                      <q-icon
                        name="person"
                        color="orange-9"
                        style="margin: 0 5px"
                        size="md"
                      />Cliente {{ InfoConsulta.nm_contato }}
                    </div>
                    <div class="col">
                      <q-icon
                        name="local_shipping"
                        color="orange-9"
                        style="margin: 0 5px"
                        size="md"
                      />Transportadora {{ InfoConsulta.nm_transportadora }}
                    </div>
                  </div>
                  <div class="row items-center text-h6 margin1">
                    <div class="col">
                      <q-icon
                        name="sell"
                        color="orange-9"
                        style="margin: 0 5px"
                        size="md"
                      />Vendedor {{ InfoConsulta.nm_vendedor }}
                    </div>
                    <div class="col">
                      <q-icon
                        name="payments"
                        color="orange-9"
                        style="margin: 0 5px"
                        size="md"
                      />Limite {{ InfoConsulta.vl_credito }}
                    </div>
                  </div>
                  <div class="row items-center text-h6 margin1">
                    <div class="col">
                      <q-icon
                        name="attach_money"
                        color="orange-9"
                        style="margin: 0 5px"
                        size="md"
                      />Valor total {{ InfoConsulta.vl_card }}
                    </div>
                    <div class="col">
                      <q-icon
                        name="credit_score"
                        color="orange-9"
                        style="margin: 0 5px"
                        size="md"
                      />Saldo {{ InfoConsulta.vl_saldo }}
                    </div>
                  </div>
                  <div class="row items-center text-h6 margin1">
                    <q-icon name="today" color="orange-9" style="margin: 0 5px" size="md" />Data de
                    Emissão {{ InfoConsulta.dt_card }}
                  </div>
                  <div class="row items-center text-h6 margin1">
                    <q-icon
                      name="format_list_bulleted"
                      color="orange-9"
                      style="margin: 0 5px"
                      size="md"
                    />{{ `Tipo de ${nm_tipo} ${InfoConsulta.tipo_proposta}` }}
                  </div>
                  <div v-if="InfoConsulta.cd_pagina > 0" class="row items-center text-h6 margin1">
                    <q-btn
                      rounded
                      dense
                      icon="dashboard"
                      color="orange-9"
                      @click="onClickPagina(InfoConsulta)"
                    >
                      <q-tooltip class="bg-orange text-white">{{
                        InfoConsulta.nm_pagina
                      }}</q-tooltip>
                    </q-btn>
                  </div>
                </div>
                <autoForm
                  :cd_parametroID="this.cd_etapa"
                  :cd_rotaID="this.cd_rota"
                  :cd_formID="this.cd_form"
                  :cd_apiID="this.cd_api"
                  :cd_menuID="this.cd_menu"
                  :cd_documentoID="this.cd_documento"
                  @click="fechaPopVisible()"
                  @dadosgrid="onDataSource($event, undefined, undefined)"
                  :cd_item_documentoID="this.cd_item_documento"
                  :cd_tipo_consultaID="this.cd_menu"
                  :prop_form="this.props_oportunidade"
                >
                </autoForm>
              </q-card-section>
            </q-card>
          </q-dialog>

          <q-dialog v-model="popupVisibleDoc" full-width>
            <q-card>
              <q-card-section class="row">
                <div class="text-h5 col" style="margin: 2px; float: left">Documentos</div>
                <div class="col" style="margin: 2px">
                  <q-btn style="float: right" round color="primary" icon="close" v-close-popup />
                </div>
              </q-card-section>

              <doc style="height: 100%; width: 100%"></doc>
            </q-card>
          </q-dialog>
        </div>
      </section>
    </div>

    <q-dialog v-model="pop_status" transition-show="scale" transition-hide="scale">
      <q-card style="width: 700px; padding: 0">
        <!--<q-bar class="bg-deep-orange-3 text-white">-->
        <div class="row items-center self-center text-center">
          <div class="text-h6 col text-center text-bold" style="margin: 5px">
            {{ cardStatus.titulo_status }}
            <q-badge align="top" rounded color="orange-9">{{ cardStatus.cd_movimento }}</q-badge>
          </div>

          <div style="float: right" class="bg-white col-1 items-center">
            <q-btn
              icon="close"
              flat
              round
              size="sm"
              v-close-popup
              style="margin-right: 5px; float: right"
            />
          </div>
        </div>
        <!-------------Primeira Linha----------->
        <div class="text-subtitle2 row items-center" style="margin: 5px 10px">
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_destinatario">
            <q-icon name="person" color="orange-9" style="margin: 0 5px" size="sm" />{{
              cardStatus.nm_destinatario
            }}
          </div>
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_contato">
            <q-icon name="face" color="orange-9" style="margin: 0 5px" size="sm" />
            {{ cardStatus.nm_contato }}
          </div>
        </div>
        <!---------------Segunda Linha----------->
        <div class="text-subtitle2 row items-center" style="margin: 5px 10px">
          <div class="metadeTela text-justify" v-if="!!cardStatus.dt_movimento">
            <q-icon name="today" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.dt_movimento
            }}
          </div>
          <div class="metadeTela text-justify" v-if="!!cardStatus.sg_modulo">
            <q-icon name="attach_money" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.sg_modulo
            }}
          </div>
        </div>
        <!---------------Terceira Linha----------->
        <div
          class="text-subtitle2 row items-center"
          style="margin: 5px 10px"
          v-show="!!cardStatus.nm_campo1 || !!cardStatus.nm_campo2"
        >
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_campo1">
            <q-icon name="chevron_right" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.nm_campo1
            }}
          </div>
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_campo2">
            <q-icon name="chevron_right" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.nm_campo2
            }}
          </div>
        </div>
        <!---------------Quarta Linha----------->
        <div
          class="text-subtitle2 row items-center"
          style="margin: 5px 10px"
          v-show="!!cardStatus.nm_campo3 || !!cardStatus.nm_campo4"
        >
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_campo3">
            <q-icon name="chevron_right" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.nm_campo3
            }}
          </div>
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_campo4">
            <q-icon name="chevron_right" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.nm_campo4
            }}
          </div>
        </div>
        <!---------------Quinta Linha----------->
        <div
          class="text-subtitle2 row items-center"
          style="margin: 5px 10px"
          v-show="!!cardStatus.nm_campo5 || !!cardStatus.nm_campo6"
        >
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_campo5">
            <q-icon name="chevron_right" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.nm_campo5
            }}
          </div>
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_campo6">
            <q-icon name="chevron_right" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.nm_campo6
            }}
          </div>
        </div>
        <!---------------Sexta Linha----------->
        <div
          class="text-subtitle2 row items-center"
          style="margin: 5px 10px"
          v-show="!!cardStatus.nm_campo7 || !!cardStatus.nm_campo8"
        >
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_campo7">
            <q-icon name="chevron_right" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.nm_campo7
            }}
          </div>
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_campo8">
            <q-icon name="chevron_right" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.nm_campo8
            }}
          </div>
        </div>
        <!---------------Setima Linha----------->
        <div
          class="text-subtitle2 row items-center"
          style="margin: 5px 10px"
          v-show="!!cardStatus.nm_campo9 || !!cardStatus.nm_campo10"
        >
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_campo9">
            <q-icon name="chevron_right" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.nm_campo9
            }}
          </div>
          <div class="metadeTela text-justify" v-if="!!cardStatus.nm_campo10">
            <q-icon name="chevron_right" style="margin: 0 5px" color="orange-9" size="sm" />{{
              cardStatus.nm_campo10
            }}
          </div>
        </div>

        <q-separator />

        <chip
          class="items-center"
          :cd_etapaID="this.cd_etapa"
          :cd_movimentoID="this.cd_movimento"
          :cd_documentoID="this.cd_documento"
          :cd_item_documentoID="this.cd_item_documento"
          :ic_valida_status="this.ic_valida_status"
          ref="chip"
        ></chip>
      </q-card>
    </q-dialog>

    <q-dialog
      v-model="pop_auto"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card style="border-radius: 15px; min-width: 45vw">
        <q-bar class="bg-orange-9 text-white" style="border-radius: 0px">
          <b v-if="!titulo_bar == ''">
            {{ titulo_bar }}
          </b>
          <q-space />
          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white">Minimizar</q-tooltip>
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white">Maximizar</q-tooltip>
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section>
          <autoForm
            :cd_parametroID="this.cd_etapa"
            :cd_rotaID="this.cd_rota"
            :cd_formID="this.cd_form"
            :cd_apiID="this.cd_api"
            :cd_menuID="this.cd_menu"
            :cd_documentoID="this.cd_documento"
            :cd_item_documentoID="this.cd_item_documento"
            @click="fechaPop()"
            :prop_form="this.props_oportunidade"
          >
          </autoForm>
        </q-card-section>
      </q-card>
    </q-dialog>
    <!--COLOCAR UM POPUP-->
    <q-dialog v-model="pop_multi_cards">
      <q-card style="width: 300px; padding: 0">
        <div class="row items-center" style="margin: 0.7vw">
          <div class="text-bold text-subtitle2 col items-center">
            {{ 'Selecione o processo' }}
          </div>

          <div class="col-1">
            <q-btn
              style="float: right"
              flat
              round
              icon="close"
              v-close-popup
              size="sm"
              @click="pop_multi_cards = false"
            />
          </div>
        </div>

        <div class="row items-center self-center justify-center" style="margin: 0.7vw">
          <div v-if="dataCheckbox.length > 0">
            <div v-for="(proc, ind) in JSON.parse(dataCheckbox[0].nm_processo)" :key="ind">
              <q-btn
                class="margin1"
                rounded
                color="primary"
                size="md"
                :label="proc.nm_form"
                @click="ProcessoMulti(proc)"
              />
            </div>
          </div>
        </div>

        <!-- Notice v-close-popup -->
      </q-card>
    </q-dialog>

    <q-dialog v-model="ic_impressao">
      <q-card style="width: 300px; padding: 0">
        <div class="row items-center" style="margin: 0.7vw">
          <div class="text-bold text-subtitle2 col items-center">
            {{ tituloPop }}
          </div>

          <div class="col-1">
            <q-btn style="float: right" flat round icon="close" v-close-popup size="sm" />
          </div>
        </div>

        <div class="row items-center self-center justify-center" style="margin: 0.7vw">
          <div v-if="cd_modulo == 260">Aguarde a Impressão...</div>
          <relatorio
            v-else
            :cd_relatorioID="this.cd_relatorio"
            :cd_documentoID="this.cd_documento"
            :cd_item_documentoID="this.cd_item_documento"
            @NaoGerouRelatorio="onNaoGeraRelatorio()"
          ></relatorio>
        </div>

        <!-- Notice v-close-popup -->
      </q-card>
    </q-dialog>

    <q-dialog v-model="ic_impressao_relatorio">
      <q-card style="width: 300px; padding: 0">
        <q-card-section>
          <div class="row items-center" style="margin: 0.7vw">
            <div class="text-bold text-subtitle2 col items-center">
              <q-btn flat icon="warning" color="warning" />{{
                `Deseja realmente gerar todos os relatórios desta etapa ?`
              }}
            </div>
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Gerar" @click="onGerarRelatorio()" color="primary" v-close-popup />
          <q-btn flat label="Cancelar" color="red" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="ic_impressao_relatorio_geral">
      <q-card style="width: 300px; padding: 0">
        <q-card-section>
          <div class="row items-center" style="margin: 0.7vw">
            <div class="text-bold text-subtitle2 col items-center">
              <q-btn flat icon="warning" color="warning" />{{
                `Deseja realmente gerar todos os relatórios do módulo ?`
              }}
            </div>
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn
            flat
            label="Gerar"
            @click="onGerarRelatorioGeral()"
            color="primary"
            v-close-popup
          />
          <q-btn flat label="Cancelar" color="red" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="pop_egiserp_relatorios" maximized>
      <q-card>
        <q-bar>
          <q-space />
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-white text-primary">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section>
          <HTMLDinamico
            :url_pagina="`https://egiserp.com.br/relatorio/fila_relatorios.html`"
            :ic_abre_outra_pagina="'S'"
            @semIframe="pop_egiserp_relatorios = false"
          />
        </q-card-section>
      </q-card>
    </q-dialog>

    <q-dialog v-model="ic_filtro_status">
      <q-card style="width: 300px; padding: 0">
        <div class="row items-center" style="margin: 0.2vw">
          <div class="col-1">
            <q-btn style="float: right" flat round icon="close" v-close-popup size="sm" />
          </div>
        </div>

        <div class="row items-center self-center justify-center" style="margin: 0.7vw">
          <filtroStatus
            :etapa="json_etapa"
            :pipeline_dados="dados_pipeline_completo"
            @closePopup="ic_filtro_status = false"
            @AchouCard="FiltrarEtapa({}, 3, $event)"
            @EtapaFiltrar="FiltrarEtapa({}, 2, $event)"
          ></filtroStatus>
        </div>
      </q-card>
    </q-dialog>

    <!-- Visualizar Imagem no servidor -->
    <q-dialog
      v-model="ic_popup_view"
      persistent
      :maximized="true"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card class="bg-primary text-white">
        <q-bar>
          <q-space />
          <div>
            <q-btn
              dense
              flat
              icon="minimize"
              @click="maximizedToggle = false"
              :disable="!maximizedToggle"
            >
              <q-tooltip v-if="maximizedToggle" content-class="bg-white text-primary"
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
              <q-tooltip v-if="!maximizedToggle" content-class="bg-white text-primary"
                >Maximizar</q-tooltip
              >
            </q-btn>
            <q-btn dense flat icon="close" v-close-popup>
              <q-tooltip content-class="bg-white text-primary">Fechar</q-tooltip>
            </q-btn>
          </div>
        </q-bar>
        <q-space />
        <div v-if="!!this.caminho_view">
          <img
            :src="caminho_view"
            name="iframeDesenho"
            title="Desenho"
            width="100%"
            height="100%"
          />
        </div>
      </q-card>
    </q-dialog>

    <vue-html2pdf
      ref="html2Pdf"
      :show-layout="false"
      :enable-download="false"
      :preview-modal="true"
      :paginate-elements-by-height="3508"
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

    <!-------------------------------HISTÓRICO------------------------------------------------------------------->
    <q-dialog v-model="pop_historico" persistent full-width>
      <q-expansion-item
        class="overflow-hidden"
        style="border-radius: 20px"
        icon="timeline"
        label="Histórico"
        default-opened
        header-class="bg-orange-9 text-white items-center"
        expand-icon-class="text-white"
      >
        <q-card>
          <div class="row">
            <q-space />
            <q-btn
              style="float: right"
              class="margin1"
              flat
              round
              icon="close"
              v-close-popup
              size="sm"
            />
          </div>
          <q-scroll-area style="height: 75vh">
            <q-card-section>
              <div>
                <timeline
                  :cd_apiInput="'737/1119'"
                  ref="timeline"
                  class="margin1"
                  :inputID="true"
                  :nm_json="objectTimeline"
                  :cd_consulta="2"
                  :cd_parametroID="0"
                  cd_apiID="728/1101"
                /><!--1557 - pr_egisnet_consulta_historico_geral -->
              </div>
            </q-card-section>
          </q-scroll-area>
        </q-card>
      </q-expansion-item>
    </q-dialog>
    <!-- relatório Modulo -->
    <q-dialog
      v-model="ic_relatorio_modulo"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-9 text-white">
          {{ `Relatório - ${titulo_bar}` }}
          <q-space />
          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white">Minimizar</q-tooltip>
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white">Maximizar</q-tooltip>
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section class="q-pt-none">
          <relatorio-modulo
            @FechaPopup="FechaPopupAltera()"
            :ic_perda="true"
            :cd_movimento="cd_movimento"
          />
        </q-card-section>
      </q-card>
    </q-dialog>
    <!-- relatório Modulo -->

    <q-dialog
      v-model="popupAltera"
      transition-show="slide-up"
      transition-hide="slide-down"
      persistent
      full-width
    >
      <q-card style="border-radius: 20px">
        <parcial
          v-if="cd_componente == 1"
          @FechaPopup="FechaPopupAltera()"
          :ic_perda="true"
          :cd_movimento="cd_movimento"
        />
        <info-adm
          v-if="cd_componente == 2"
          @FechaPopup="FechaPopupAltera()"
          :cd_movimento="cd_movimento"
        />
      </q-card>
    </q-dialog>
    <!------Alerta sobre processo inválido------------------------------------------------------------------------------------>

    <q-dialog v-model="ic_posicao" persistent style="width: auto">
      <q-card style="width: auto">
        <div class="row items-center margin1" style="width: auto">
          <q-avatar icon="fmd_bad" color="orange-9" text-color="white" />
          <span class="margin1 text-h6">{{ Msg }}</span>
        </div>

        <q-card-actions align="right">
          <q-btn flat rounded style="float: right" color="orange-9" @click="onFecharValidacao()"
            >Fechar</q-btn
          >
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!--<q-dialog v-model="ic_posicao" full-width>
      <q-card>
        <q-card-section class="row">
          <div class="text-h5 col" style="margin: 2px; float:left;">
            {{ Msg }}
          </div>
          <div class="col" style="margin: 2px;"></div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right">
          <q-btn
            style="float:right;"
            color="orange-9"
            @click="onFecharValidacao()"
            >Fechar</q-btn
          >
        </q-card-actions>
      </q-card>
    </q-dialog>-->
    <!--Travamento de tela para loading-------------------------------------------------------------------------->
    <q-dialog maximized v-model="load_tela" persistent>
      <carregando
        v-if="load_tela == true"
        :corID="'orange-9'"
        :mensagemID="mensagemTela"
      ></carregando>
    </q-dialog>
    <!--------SOLICITAÇÃO DE SENHA---------------------------------------------------------------------------->
    <q-dialog v-model="pop_senha_proceso" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Insira a senha</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            label="Senha"
            dense
            v-model="nm_senha"
            :type="isPwd ? 'password' : 'text'"
            autofocus
            @keyup.enter="confirmaSenha()"
          >
            <template v-slot:append>
              <q-icon
                :name="isPwd ? 'visibility_off' : 'visibility'"
                class="cursor-pointer"
                @click="isPwd = !isPwd"
              />
            </template>
          </q-input>
        </q-card-section>

        <q-card-actions align="right" class="text-white">
          <q-btn
            rounded
            color="orange-9"
            class="q-ml-sm"
            icon="check"
            label="Confirmar"
            @click="confirmaSenha()"
          />
          <q-btn
            rounded
            color="orange-9"
            flat
            class="q-ml-sm"
            icon="close"
            label="Fechar"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import notify from 'devextreme/ui/notify'
import formataData from '../http/formataData'

import 'devextreme/ui/select_box'
import ptMessages from 'devextreme/localization/messages/pt.json'
import { locale, loadMessages } from 'devextreme/localization'
import config from 'devextreme/core/config'
import { DxScrollView } from 'devextreme-vue/scroll-view'
import { DxSortable } from 'devextreme-vue/sortable'
import Procedimento from '../http/procedimento'
import Menu from '../http/menu'
import grid from '../views/grid'
import autoForm from './autoForm'
import premio from '../views/premiacao'
import Incluir from '../http/incluir_registro'
import doc from '../views/cadastro-documento.vue'
import mapaRoteiro from '../views/ferramentaRoteiro'
import formatadata from '../http/formataData.js'
import chip from '../components/rotuloChip.vue'
import relatorio from '../views/relatorio.vue'
import timeline from '../views/timeline.vue'
import funcao from '../http/funcoes-padroes.js'
import select from '../http/select'
import VueHtml2pdf from 'vue-html2pdf'
import dashBoard_Componente from '@/views/dashboard-componente.vue' // ajuste o caminho

//import painelModulo from "./painelModulo.vue";
import DxPieChart, {
  DxSeries,
  DxLabel,
  DxConnector,
  DxExport,
  DxLegend,
  DxTooltip,
} from 'devextreme-vue/pie-chart'
import axios from 'axios'

var sParametroApi = ''

export default {
  emits: ['GraficoKanban'],
  props: {
    chargeDados: { type: Boolean, default: false },
  },

  computed: {
    cardsPorEtapa() {
      const map = {}
      for (const card of this.dados_pipeline) {
        if (card.mostraFiltro !== 'S') continue
        const k = card.cd_etapa
        if (!map[k]) map[k] = []
        map[k].push(card)
      }
      return map
    },

    relatoriopadrao() {
      return this.$refs['relatoriopadrao'].instance
    },
    // pegue de onde fizer sentido no seu app; aqui um fallback no sessionStorage
    cdModuloDash() {
      return Number(
        this.cd_modulo ||
          localStorage.cd_modulo ||
          sessionStorage.getItem('cd_dashboard') ||
          sessionStorage.getItem('cd_modulo') ||
          0
      )
    },
    cdUsuarioDash() {
      return Number(
        this.cd_usuario || localStorage.cd_usuario || sessionStorage.getItem('cd_usuario') || 0
      )
    },
    dtInicialDash() {
      return (
        this.dt_inicial ||
        localStorage.dt_inicial ||
        sessionStorage.getItem('dt_inicial_padrao') ||
        ''
      )
    },
    dtFinalDash() {
      return (
        this.dt_final || localStorage.dt_final || sessionStorage.getItem('dt_final_padrao') || ''
      )
    },
  },
  components: {
    DxPieChart,
    DxSeries,
    DxLabel,
    DxConnector,
    DxExport,
    DxLegend,
    DxTooltip,
    DxScrollView,
    DxSortable,
    grid,
    autoForm,
    premio,
    doc,
    mapaRoteiro,
    chip,
    relatorio,
    VueHtml2pdf,
    dashBoard_Componente,
    //painelModulo,
    filtroStatus: () => import('../components/filtroStatus.vue'),
    relatoriop: () => import('../components/relatorio-padrao.vue'),
    parcial: () => import('../components/fechamentoParcial.vue'),
    carregando: () => import('../components/carregando.vue'),
    infoAdm: () => import('../components/infoAdm.vue'),
    processoSistema: () => import('../components/processoSistema.vue'),
    importacaoSistema: () => import('../components/importacaoSistema.vue'),
    documentosCRUD: () => import('../components/documentosCRUD.vue'),
    relatorioModulo: () => import('../components/relatorioModulo.vue'),
    graficoModulo: () => import('../components/graficoModulo.vue'),
    timeline,
    HTMLDinamico: () => import('./HTMLDinamico.vue'),
  },
  data() {
    var lists = []
    var statuses = []

    return {
      versaoPipeline: 0,
      showDashboard: false, // controla o QDialog
      atividade_modulo: [],
      qtdEtapa: {},
      paginationEtapa: [],
      paginationCount: 20,
      load_atividade: false,
      popupAltera: false,
      popup_premio: false,
      pop_auto: false,
      pop_status: false,
      pop_validacao: false,
      pop_historico: false,
      pop_processo: false,
      pop_grafico: false,
      pop_importacao: false,
      pop_selecao: false,
      dynamicComponent: null,
      pop_botao_modulo: false,
      pop_senha_proceso: false,
      nm_senha: '',
      isPwd: true,
      senhaAutorizada: false,
      card_movimento: {},
      item_movimento: {},
      movimento_processo: {},
      ic_processo_modulo: false,
      ic_grafico_do_kanban: false,
      ic_grafico_do_kanban_individual: false,
      ic_popup_confirmacao: false,
      popupConfirm: false,
      dadosArrastar: {},
      etapaArrastar: {},
      cancelar: '',
      ic_relatorio_modulo: false,
      dados_kanban_etapa: [],
      ic_etapa: 'S',
      cp: 0,
      nm_jsonp: {},
      card_json: {},
      json_etapa: {},
      lists,
      dados: [],
      load_indicador: false,
      dados_menu_pipeline: [],
      statuses,
      chat: 0,
      tituloMenu: 'Processos',
      mensagemTela: 'Aguarde...',
      hoje: '',
      objectTimeline: {},
      hora: '',
      nm_link: '',
      load_tela: false,
      load_carregar: false,
      nm_img_link: '',
      nm_titulo_link: '',
      dataSourceConfig: [],
      dataCheckbox: [],
      pop_multi_cards: false,
      botao_etapa: 'ANALÍTICO',
      cd_menu: 0,
      cd_cliente: 0,
      cd_api: 0,
      cd_etapa: 0,
      cd_rota: 0,
      cd_form: 0,
      api: '',
      inotifica: 0,
      dados_pipeline: [],
      dados_pipeline_completo: [],
      dados_status: [],
      dados_indicador: undefined,
      dados_botoes_barra: undefined,
      dados_popup: [],
      InfoConsulta: {},
      cd_documento: 0,
      cd_item_documento: 0,
      nm_destinatario: '',
      ic_valida_status: '',
      buscaIndicador: '',
      qt_registro: 0,
      items: [],
      withTitleVisible: false,
      withGrid: false,
      showCard: false,
      ic_cab_etapa: 'N',
      operadores: [],
      polling: null,
      nome_premio: '',
      contato_premio: '',
      empresa_premio: '',
      cd_movimento: 0,
      cd_posicao: '',
      cd_pontuacao: '',
      cd_etapa_origem: 0,
      linha_perda: {},
      cd_relatorio: 0,
      fechou_rs: [],
      ic_posicao: false,
      Msg: '',
      popup_mapa: false,
      popup_link: false,
      num_status: 0,
      cliente_status: '',
      refresh: false,
      maximizedToggle: true,
      titulo_bar: '',
      nm_tipo: '',
      tituloPop: '',
      filtroGeral: false,
      dadosArrastarSenha: null,
      etapaArrastarSenha: null,
      popup_senha_movimento: false,
      nm_senha_digitada: '',
      cardStatus: {
        cd_movimento: 0,
        cd_etapa: 0,
        cd_documento: 0,
        dt_movimento: '',
        cd_item_documento: 0,
        nm_destinatario: '',
        sg_modulo: '',
        nm_campo1: '',
        nm_campo2: '',
        nm_campo3: '',
        nm_campo4: '',
        nm_campo5: '',
        nm_campo6: '',
        nm_campo7: '',
        nm_campo8: '',
        nm_campo9: '',
        nm_campo10: '',
        titulo_status: '',
        nm_financeiro: '',
      },
      titulo_status: '',
      cd_empresa: localStorage.cd_empresa,
      Array_musica: [
        'https://www.myinstants.com/media/sounds/tmpbxydyrz3.mp3',
        'https://www.myinstants.com/media/sounds/uepa-mp3cut.mp3',
        'https://www.myinstants.com/media/sounds/acabou.mp3',
        'https://www.myinstants.com/media/sounds/and-his-name-is-john-cena-1.mp3',
        'https://www.myinstants.com/media/sounds/turn-down-for-what.mp3',
        'https://www.myinstants.com/media/sounds/titanic-parody-mp3cut.mp3',
        'https://www.myinstants.com/media/sounds/we-are-the-champions-copia.mp3',
      ],
      popupVisible: false,
      flag_temporario: false,
      cd_modulo: localStorage.cd_modulo,
      popupAtividade: false,
      popupVisibleDoc: false,
      popupProcesso: false,
      popupDocCard: false,
      titleProcesso: '',
      resultadoForm: [],
      props_oportunidade: {},
      grava_etapa: false,
      load_delete: false,
      grava_mov: false,
      ic_impressao: false,
      ic_impressao_relatorio_geral: false,
      ic_impressao_relatorio: false,
      dados_etapa_selecionada: {},
      pop_egiserp_relatorios: false,
      StatusTemporario: [],
      filtro_status: [],
      ic_filtro_status: false,
      ic_popup_view: false,
      caminho_view: '',
      dia_semana: '',
      cd_componente: 0,
      load_pagina: false,
      cd_pagina_modulo: this.$store._mutations.SET_Usuario.cd_pagina || 0,
      ic_aprov_requisicao: this.$store._mutations.SET_Usuario.ic_aprov_requisicao || '',
      ic_pagina_modulo: 'N',
      menuCarregado: false,
      primeiraCargaCompleta: false,
    }
  },

  beforeDestroy() {
    clearInterval(this.polling)
    try {
      if (this.$store && this.$store.commit) {
        this.$store.commit('REMOVE_FOOTER_HIDE_REQUEST', 'moduloEtapaProcesso')
      }
    } catch (err) {
      // ignore
    }
  },

  async created() {
    config({ defaultCurrency: 'BRL' })
    loadMessages(ptMessages)
    locale(navigator.language)

    this.dia_semana = await funcao.DiaSemana()
    this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString()
    this.dt_final = new Date(localStorage.dt_final).toLocaleDateString()
    this.hoje = new Date().toLocaleDateString('pt-BR')
    var h = new Date().toLocaleTimeString()
    this.hora = h.substring(0, 5)
    if (this.chargeDados == true) return

    this.PegaTitulo()
    ////Verifica se o Módulo possui Processo cadastrado (Modulo_Processo)
    let processos_json = {
      cd_empresa: '0',
      cd_tabela: 5538,
      order: 'D',
      where: [{ cd_modulo: this.cd_modulo }],
    }
    let [processo_modulo] = await select.montarSelect(
      '0', //this.cd_empresa,
      processos_json
    )
    this.ic_processo_modulo = !processo_modulo.dataset
    this.resultadoForm = JSON.parse(this.$store._mutations.SET_Usuario.resultadoForm)
  },

  async mounted() {
    this.load_pagina = false

    this.PegaTitulo()
    if (this.cd_modulo == 346) {
      this.hoje = await funcao.Semana(1)
    }
    if (this.cd_modulo == 346) {
      const atual = funcao.DataHoje()
      localStorage.dt_inicial = formatadata.formataDataSQL(atual)
      this.hoje = await funcao.Semana(1)
      const dates = await funcao.Semana(2)
      localStorage.dt_inicial = formatadata.formataDataSQL(dates.dt_inicial)
      localStorage.dt_final = formatadata.formataDataSQL(dates.dt_final)
    }

    //await this.carregaDados();
    this.carregaDados({ full: true })
  },

  updated() {
    this.PegaTitulo()
  },

  beforeUpdate() {
    this.PegaTitulo()
  },
  destroyed() {
    clearInterval(this.polling)
  },

  watch: {
    //showDashboard (val) { this.ic_pagina_modulo = val ? 'S' : 'N' },

    refresh() {
      if (this.refresh == true) {
        this.polling = setInterval(() => {
          this.carregaDados()
        }, 120000)
      } else {
        clearInterval(this.polling)
      }
    },
    popupAtividade(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },
    popupVisible(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },
    popupVisibleDoc(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },
    popupProcesso(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },
    pop_validacao(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },
    popup_premio(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },
    popup_mapa(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },
    popupDocCard(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },
    withGrid(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },
    ic_impressao(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },
    ic_posicao(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },
    pop_historico(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
      }
    },

    async pop_status(Novo) {
      if (Novo == true) {
        clearInterval(this.polling)
      }
      if (Novo == false) {
        if (this.refresh == true) {
          this.polling = setInterval(() => {
            this.carregaDados()
          }, 36000)
        } else {
          clearInterval(this.polling)
        }
        this.tituloPop = ''
        var v = this.$refs.chip.EnviaTemporario()
        if (v.length == 0) return
        for (let c = 0; c < v.length; c++) {
          if (v[c].ic_adiciona == false) {
            let found
            found = this.dados_status.find(
              (element) =>
                element.cd_movimento == v[c].cd_movimento &&
                element.cd_etapa == v[c].cd_etapa &&
                element.cd_status == v[c].cd_status
            )
            if (found != undefined) {
              this.dados_status.splice(this.dados_status.indexOf(found), 1)
            } else {
              found = this.StatusTemporario.find(
                (element) =>
                  element.cd_movimento == v[c].cd_movimento &&
                  element.cd_etapa == v[c].cd_etapa &&
                  element.cd_status == v[c].cd_status
              )
              this.StatusTemporario.splice(this.StatusTemporario.indexOf(found), 1)
            }
          } else {
            this.StatusTemporario.push(v[c])
          }
        }
      }
    },
    StatusTemporario(A) {
      if (A.length > 0) {
        this.flag_temporario = true
      } else {
        this.flag_temporario = false
      }
    },
    pop_auto(Novo) {
      if (Novo == false) {
        this.tituloPop = ''
        if (this.props_oportunidade.cd_movimento || this.props_oportunidade.cd_documento) {
          this.onUpdateOneCard()
        }
      } else {
        clearInterval(this.polling)
      }
    },
  },

  methods: {
    async carregarCardsSnap() {
      this.load_carregar = true
      try {
        const { data } = await api.get(`/pipeline/snapshot/${this.cd_empresa}/${this.cd_modulo}`, {
          params: { versaoAtual: this.versaoPipeline },
        })

        if (data.dados) {
          this.versaoPipeline = data.versao
          this.dados_pipeline = data.dados
          this.dados_pipeline_completo = data.dados
          await this.atualizaKanban()
        }
      } finally {
        this.load_carregar = false
      }
    },

    abrirDashboard() {
      this.showDashboard = !this.showDashboard
      try {
        if (this.$store && this.$store.commit) {
          const id = 'moduloEtapaProcesso'
          if (this.showDashboard) {
            // dashboard visible -> request footer hidden
            this.$store.commit('ADD_FOOTER_HIDE_REQUEST', id)
          } else {
            // dashboard hidden -> remove request
            this.$store.commit('REMOVE_FOOTER_HIDE_REQUEST', id)
          }
        }
      } catch (err) {
        console.error('Erro ao alterar footer via Vuex:', err)
      }
      // debug: veja no console se foi chamado
      console.log('[moduloEtapa] showDashboard:', this.showDashboard, {
        cdModulo: this.cdModuloDash,
        cdUsuario: this.cdUsuarioDash,
        dtInicial: this.dtInicialDash,
        dtFinal: this.dtFinalDash,
      })
    },

    onNaoGeraRelatorio() {
      this.ic_impressao = false
      notify('Não foi possivel gerar o relatório!')
    },
    async FechaPopupAltera() {
      this.popupAltera = false
    },
    pointClickHandler({ target }) {
      target.select()
    },
    customizeTooltip({ valueText, percent }) {
      return {
        text: `${valueText} - ${(percent * 100).toFixed(2)}%`,
      }
    },
    async addCards() {
      this.paginationCount += 20
      await this.carregaPipes()
    },
    onRelatorioPopup() {
      this.ic_relatorio_modulo = !this.ic_relatorio_modulo
      this.titulo_bar = localStorage.nm_modulo
    },
    async onCellPrepared(e) {
      //Verifica o type de inicialização da célula.
      if (e.rowType == 'header') {
        return
      }
      //Caso seja uma célula de valor e a data de perda for preenchida a linha é pintada de vermelho.
      if (e.values[9] != '' && e.rowType == 'data') {
        e.cellElement.style.color = 'red'
      }
    },
    async PegaLinha(e) {
      this.linha_perda = e.row.data
    },

    async ConfirmIc(index) {
      if (this.dados_pipeline.length > 0 && index == 1) {
        this.dados_pipeline.forEach((element) => {
          element.ic_popup_altera == undefined ? (element.ic_popup_altera = 'N') : ''
        })
      }
      // Ordena todos os cards da etapa em ordem decrescente de cd_movimento
      this.dados_pipeline = this.dados_pipeline.sort((a, b) => {
        if (
          a.cd_etapa === this.props_oportunidade.cd_etapa &&
          b.cd_etapa === this.props_oportunidade.cd_etapa
        ) {
          return b.cd_movimento - a.cd_movimento // DESC
        }
        return 0 // Mantém ordem dos outros cards
      })
    },
    async ReordenaEtapa(item) {
      this.load_delete = true
      this.dataSourceConfig.push(item)
      this.dataSourceConfig.sort(function (a, b) {
        if (a.qt_ordem_etapa > b.qt_ordem_etapa) {
          return 1
        }
        if (a.qt_ordem_etapa < b.qt_ordem_etapa) {
          return -1
        }
        return 0
      })
      this.items.splice(this.items.indexOf(item), 1)

      this.load_delete = false
    },
    async FilterKanBan(e, limpar) {
      let etapa = e.cd_etapa
      //Criado para fazer um filtro de card dentro da etapa selecionada
      if (limpar == true) {
        this.load = true

        let indicador = parseInt(this.buscaIndicador)
        for (let c = 0; c < this.dados_pipeline.length; c++) {
          if (
            this.dados_pipeline[c].cd_etapa == etapa &&
            indicador == this.dados_pipeline[c].cd_movimento
          ) {
            this.dados_pipeline[c].mostraFiltro = 'S'
          } else if (this.dados_pipeline[c].cd_etapa == etapa) {
            this.dados_pipeline[c].mostraFiltro = 'N'
          }
        }
        this.load = false
        //this.buscaIndicador = "";
      } else {
        for (let c = 0; c < this.dados_pipeline.length; c++) {
          if (this.dados_pipeline[c].cd_etapa == etapa) {
            this.dados_pipeline[c].mostraFiltro = 'S'
          }
        }
        await this.FiltrarEtapa({}, 2)
      }
    },
    fechaPopVisible() {
      this.popupVisible = false
    },

    onDataSource(e) {
      if (e !== undefined && e[0]) {
        this.InfoConsulta.nm_contato ? '' : (this.InfoConsulta.nm_contato = e[0].nm_destinatario)
        this.InfoConsulta.vl_card ? '' : (this.InfoConsulta.sg_modulo = e[0].sg_modulo)
        this.InfoConsulta.dt_card ? '' : (this.InfoConsulta.dt_movimento = e[0].dt_movimento)
        this.InfoConsulta.cd_movimento ? '' : (this.InfoConsulta.cd_movimento = e[0].cd_movimento)
        this.InfoConsulta.nm_vendedor ? '' : (this.InfoConsulta.nm_vendedor = e[0].nm_vendedor)
        this.InfoConsulta.tipo_proposta
          ? ''
          : (this.InfoConsulta.nm_atendimento = e[0].nm_atendimento)
        this.InfoConsulta.nm_transportadora
          ? ''
          : (this.InfoConsulta.nm_transportadora = e[0].nm_transportadora)
        this.InfoConsulta.nm_condicao_pagamento
          ? ''
          : (this.InfoConsulta.nm_condicao_pagamento = e[0].nm_condicao_pagamento)
        this.InfoConsulta.vl_credito ? '' : (this.InfoConsulta.vl_credito = e[0].vl_credito)
        this.InfoConsulta.vl_saldo ? '' : (this.InfoConsulta.vl_saldo = e[0].vl_saldo)
      }
    },

    fechaPop() {
      this.onUpdateOneEtapa()
      this.pop_auto = false
    },

    fechaPopBtnSuperior() {
      this.pop_botao_modulo = false
      this.carregaDados()
    },

    async CalculaCard(etapa_origem, etapa_destino) {
      if (etapa_destino == etapa_origem) return
      //Calculo da Etapa de origem-----------------------------
      if (etapa_origem) {
        var EtapaOrigem = this.dados_pipeline.filter((e) => {
          return e.cd_etapa == etapa_origem
        })
        if (EtapaOrigem.length > 0) {
          let ArrayValoresOrigem = []
          for (let p = 0; p < EtapaOrigem.length; p++) {
            if (EtapaOrigem[p].sg_modulo) {
              ArrayValoresOrigem.push(EtapaOrigem[p].sg_modulo)
            }
          }
          const valorOrigemEtapa = await funcao.CalculaTotal(
            ArrayValoresOrigem,
            EtapaOrigem[0].sg_moeda || 'BRL'
          )
          const findOrigem = this.dataSourceConfig.findIndex((e) => {
            return e.cd_etapa == etapa_origem
          })
          if (findOrigem != -1) {
            this.dataSourceConfig[findOrigem].nm_valor_etapa = valorOrigemEtapa
            this.dataSourceConfig[findOrigem].qt_etapa = ArrayValoresOrigem.length
          }
        } else {
          const index = this.dataSourceConfig.findIndex((e) => {
            return e.cd_etapa == etapa_origem
          })
          this.dataSourceConfig[index].qt_etapa = 0
          this.dataSourceConfig[index].nm_valor_etapa = 0
        }
      }
      //-------------------------------------------------------------
      if (etapa_destino) {
        const EtapaDestino = this.dados_pipeline.filter((e) => {
          return e.cd_etapa == etapa_destino
        })
        if (EtapaDestino.length > 0) {
          let ArrayValoresDestino = []
          for (let p = 0; p < EtapaDestino.length; p++) {
            if (EtapaDestino[p].sg_modulo) {
              ArrayValoresDestino.push(EtapaDestino[p].sg_modulo)
            }
          }
          const valorDestinoEtapa = await funcao.CalculaTotal(
            ArrayValoresDestino,
            EtapaOrigem[0].sg_moeda || 'BRL'
          )
          const findDestino = this.dataSourceConfig.findIndex((e) => {
            return e.cd_etapa == etapa_destino
          })
          if (findDestino != -1) {
            this.dataSourceConfig[findDestino].nm_valor_etapa = valorDestinoEtapa
            this.dataSourceConfig[findDestino].qt_etapa = ArrayValoresDestino.length
          }
        } else {
          const index = this.dataSourceConfig.findIndex((e) => {
            return e.cd_etapa == etapa_destino
          })
          this.dataSourceConfig[index].qt_etapa = 0
          this.dataSourceConfig[index].nm_valor_etapa = 0
        }
      }
    },

    FechaPopup() {
      this.pop_auto = false
      return 'OK'
    },

    async onEditHistorico(card) {
      this.tituloPop = 'Histórico ' + card.nm_destinatario

      let dt_inicial = localStorage.dt_inicial
      let dt_final = localStorage.dt_final
      this.objectTimeline = {
        cd_modulo: card.cd_modulo,
        cd_movimento: card.cd_movimento,
        cd_etapa: card.cd_etapa,
        cd_empresa: this.cd_empresa,
        cd_usuario: localStorage.cd_usuario,
        dt_inicial: dt_inicial,
        dt_final: dt_final,
        ic_edicao: 'S',
        ic_parametro: 1,
        cd_historico: card.cd_historico,
      }
      this.setConfig(10) //pop_historico
    },

    Grafico_Kanban(index) {
      this.ic_etapa = 'N'
      localStorage.ic_etapa_processo = 'N'
      this.$emit('emit-click', index)
    },

    async FiltrarEtapa(status, index, evt) {
      this.buscaIndicador = ''
      var cd_etapa = status.cd_etapa
      var cd_status = status.cd_status
      this.dados_pipeline = []
      this.dados_pipeline = this.dados_pipeline_completo
      let found = {}
      if (index == 1) {
        // Executa o Filtro por status

        for (let c = 0; c < this.dados_pipeline.length; c++) {
          if (this.dados_pipeline[c].cd_etapa == cd_etapa) {
            this.dados_pipeline[c].mostraFiltro = 'N'
          } else {
            this.dados_pipeline[c].mostraFiltro = 'S'
          }
        }
        for (let g = 0; g < this.dados_status.length; g++) {
          if (this.dados_status[g] != undefined) {
            if (
              this.dados_status[g].cd_etapa == cd_etapa &&
              this.dados_status[g].cd_status == cd_status
            ) {
              let cd_movimento = this.dados_status[g].cd_movimento
              found = {}

              found = this.dados_pipeline.find(
                (element) => element.cd_movimento == cd_movimento && element.cd_etapa == cd_etapa
              )

              if (found != {} || found != undefined) {
                for (let a = 0; a < this.dados_pipeline.length; a++) {
                  if (found === undefined) {
                    found = {}
                  }
                  if (found != {}) {
                    if (
                      found.cd_movimento == this.dados_pipeline[a].cd_movimento &&
                      found.cd_etapa == this.dados_pipeline[a].cd_etapa
                    ) {
                      this.dados_pipeline[a].mostraFiltro = 'S'
                    }
                  }
                }
              }
            }
          }
        }
        if (this.StatusTemporario.length > 0) {
          for (let g = 0; g < this.StatusTemporario.length; g++) {
            if (
              this.StatusTemporario[g].cd_etapa == cd_etapa &&
              this.StatusTemporario[g].cd_status == cd_status
            ) {
              let cd_movimento = this.StatusTemporario[g].cd_movimento
              found = this.dados_pipeline.find(
                (element) => element.cd_etapa == cd_etapa && element.cd_movimento == cd_movimento
              )
              if (found != undefined) {
                for (let a = 0; a < this.dados_pipeline.length; a++) {
                  if (
                    found.cd_movimento == this.dados_pipeline[a].cd_movimento &&
                    found.cd_etapa == this.dados_pipeline[a].cd_etapa
                  ) {
                    this.dados_pipeline[a].mostraFiltro = 'S'
                  }
                }
              }
            }
          }
        }
      } else if (index == 2) {
        //Limpa o Filtro
        this.dataSourceConfig.map((etapas) => {
          if (etapas.cd_etapa == evt.cd_etapa) {
            etapas.mostraFiltro = 'N'
          } else {
            this.filtroGeral = false
            etapas.mostraFiltro = 'N'
          }
        })
        this.paginationCount = 20
        await this.carregaPipes()
        this.ic_filtro_status = false
      } else if (index == 3) {
        //Faz o Filtro
        this.dataSourceConfig.map((etapas) => {
          if (etapas.cd_etapa == evt.cd_etapa && !evt.filtroGeral) {
            etapas.mostraFiltro = 'S'
          } else if (evt.filtroGeral) {
            etapas.filtroGeral, (this.filtroGeral = true)
          }
        })
        this.ic_filtro_status = false
      }
    },

    async onGraficos() {
      this.pop_grafico = true
      this.titulo_bar = localStorage.nm_modulo
    },

    async onProcessos() {
      this.pop_processo = true
      this.titulo_bar = localStorage.nm_modulo
    },

    onImportacao() {
      this.pop_importacao = true
      this.titulo_bar = localStorage.nm_modulo
    },

    async onSelecao() {
      try {
        const path = 'selecaopedidosCarga'
        this.dynamicComponent = () => import(`./${path}.vue`)
        this.pop_selecao = true
        this.titulo_bar = localStorage.nm_modulo
      } catch (error) {
        console.error('Erro ao carregar o componente de seleção:', error)
      }
    },

    onBotaoModulo(btn_barra) {
      this.cd_rota = btn_barra.cd_rota_menu
      this.cd_form = btn_barra.cd_form
      this.props_oportunidade = btn_barra
      this.props_oportunidade.nm_caminho_pagina = btn_barra.nm_caminho_pagina
      this.props_oportunidade.nm_endereco_pagina = btn_barra.nm_endereco_pagina
      this.pop_botao_modulo = true
      this.titulo_bar = localStorage.nm_modulo
      this.cd_documento = null
    },

    async AbreFiltro(e) {
      this.ic_filtro_status = !this.ic_filtro_status
      this.json_etapa = e
    },

    async onGerarRelatorio() {
      const cards_etapa = this.dados_pipeline
        .filter((item) => item.cd_etapa === this.dados_etapa_selecionada.cd_etapa)
        .map(({ cd_documento, cd_item_documento, cd_movimento }) => ({
          cd_documento,
          cd_item_documento,
          cd_movimento,
        }))

      const json_relatorio_geral = {
        cd_usuario_relatorio: localStorage.cd_usuario,
        cd_relatorio: this.dados_etapa_selecionada.cd_relatorio,
        cd_status_relatorio: 1,
        ds_ocorrencia: '',
        cd_usuario_inclusao: localStorage.cd_usuario,
        qt_documento: this.dados_etapa_selecionada.qt_etapa,
        cd_ordem: 1,
        cd_usuario: localStorage.cd_usuario,
        cd_modulo: this.cd_modulo,
        cd_etapa: this.dados_etapa_selecionada.cd_etapa,
        composicoes: cards_etapa,
      }
      let [result_relatorio_geral] = await Incluir.incluirRegistro(
        '952/1465', //pr_egis_geracao_fila_relatorio
        json_relatorio_geral
      )
      if (result_relatorio_geral.Msg) {
        notify(result_relatorio_geral.Msg)
      }
      this.pop_egiserp_relatorios = true
    },

    AbreGeraRelatorio(e) {
      this.dados_etapa_selecionada = e
      this.ic_impressao_relatorio = true
    },

    AbreGeraRelatorioGeral() {
      this.ic_impressao_relatorio_geral = true
    },

    async onGerarRelatorioGeral() {
      const json_relatorio_geral = {
        cd_usuario_relatorio: localStorage.cd_usuario,
        cd_usuario_inclusao: localStorage.cd_usuario,
        cd_usuario: localStorage.cd_usuario,
        cd_ordem: 1,
        cd_modulo: this.cd_modulo,
        cd_etapa: 0,
      }
      let [result_relatorio_geral] = await Incluir.incluirRegistro(
        '952/1465', //pr_egis_geracao_fila_relatorio
        json_relatorio_geral
      )
      if (result_relatorio_geral.Msg) {
        notify(result_relatorio_geral.Msg)
      }
      this.pop_egiserp_relatorios = true
    },

    async onEnviarWhatsApp(d, e) {
      if (d.nm_contato_whatsapp) {
        return notify('Número para envio não informado!')
      }
      if (e.ds_mensagem) {
        return notify('Mensagem para envio não informada!')
      }
      this.dados = await Menu.montarMenu(this.cd_empresa, 0, 865)
      // "865/1342" pr_gera_mensagem_api_whatsapp
      let api = this.dados.nm_identificacao_api
      localStorage.nm_documento = d.nm_contato_whatsapp //"5511992737805"; //Carlos
      localStorage.ds_parametro = e.ds_mensagem
      await Procedimento.montarProcedimento(
        this.cd_empresa,
        localStorage.cd_cliente,
        api,
        this.dados.nm_api_parametro //d.nm_api_parametro
      )
      this.pop_egiserp_relatorios = true
    },

    async onEnviarEmail(d) {
      this.dados = await Menu.montarMenu(this.cd_empresa, 0, 677)

      let api = this.dados.nm_identificacao_api

      let json = {
        cd_parametro: 0,
        cd_tipo_email: d.cd_tipo_email,
        cd_documento: d.cd_documento,
        cd_item_documento: d.cd_item_documento,
        cd_tipo_documento: d.cd_tipo_documento,
        cd_modulo: localStorage.cd_modulo,
        cd_usuario: localStorage.cd_usuario,
      }

      var email = await Incluir.incluirRegistro(api, json)

      notify(email[0].Msg)
    },

    async onUpdateOneCard() {
      try {
        let jsonUpdateCard = {
          cd_etapa: this.props_oportunidade.cd_etapa,
          cd_movimento: this.props_oportunidade.cd_movimento,
          cd_documento: this.props_oportunidade.cd_documento,
        }
        var [resultUpdateCard] = await Incluir.incluirRegistro(
          `935/1448/${localStorage.cd_empresa}/${localStorage.cd_modulo}/0/3/${localStorage.cd_usuario}/${localStorage.dt_inicial}/${localStorage.dt_final}`,
          jsonUpdateCard,
          'admin'
        )
        const index = this.dados_pipeline.findIndex(
          (item) =>
            item.cd_etapa === resultUpdateCard.cd_etapa &&
            item.cd_movimento === resultUpdateCard.cd_movimento
        )
        if (index !== -1) {
          this.$set(this.dados_pipeline, index, {
            ...this.dados_pipeline[index],
            ...resultUpdateCard,
          })
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error)
      }
    },

    async onUpdateOneEtapa() {
      try {
        let jsonUpdateCard = {
          cd_etapa: this.props_oportunidade.cd_etapa,
        }
        // Chama o back-end e recebe uma lista atualizada
        var resultUpdateCard = await Incluir.incluirRegistro(
          `935/1448/${localStorage.cd_empresa}/${localStorage.cd_modulo}/0/4/${localStorage.cd_usuario}/${localStorage.dt_inicial}/${localStorage.dt_final}`,
          jsonUpdateCard,
          'admin'
        )
        this.dados_pipeline = [
          ...this.dados_pipeline.filter(
            (card) => card.cd_etapa !== this.props_oportunidade.cd_etapa
          ),
          ...resultUpdateCard,
        ]
        await this.atualizaKanban()
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error)
      }
    },

    async onRemoveEtapa(e) {
      this.dataSourceConfig = this.dataSourceConfig.filter((g) => {
        return g.cd_etapa != e.cd_etapa
      })
      this.items.push(e)
    },

    setConfig(p) {
      this.popupAtividade = false
      this.popupVisible = false
      this.popupVisibleDoc = false
      this.popupProcesso = false
      this.pop_auto = false
      this.pop_status = false
      this.pop_validacao = false
      this.popup_premio = false
      this.popup_mapa = false
      this.popupDocCard = false
      this.withGrid = false
      this.ic_impressao = false
      this.ic_posicao = false
      this.pop_historico = false

      //
      switch (p) {
        case 1:
          this.popupAtividade = true
          break
        case 2:
          this.popupVisibleDoc = true
          break
        case 3:
          this.popupVisible = true
          break
        case 4:
          this.pop_auto = true
          break
        case 6:
          this.popupDocCard = true
          break
        case 8:
          this.pop_status = true
          break
        case 9:
          this.ic_impressao = true
          break
        case 10:
          this.pop_historico = true
          break
      }
    },

    async onFecharValidacao() {
      this.ic_posicao = false
      this.Msg = ''
    },

    async onClickDocCard(e, i) {
      this.grava_etapa = true
      this.cd_documento = e.cd_documento
      this.nm_destinatario = e.nm_destinatario
      this.titulo_bar = e.nm_etapa
      localStorage.cd_mov = e.cd_movimento
      localStorage.cd_item = i
      localStorage.cd_kan = e.cd_etapa
      localStorage.cd_mov = e.cd_movimento
      localStorage.cd_docu = this.cd_documento
      this.card_json = e
      if (localStorage.cd_docu == undefined) {
        localStorage.cd_docu = 0
      }

      this.grava_etapa = false
      this.grava_mov = true
      this.popupAtividade = false
      this.popupVisible = false
      this.popupVisibleDoc = false
      this.popupProcesso = false
      this.pop_auto = false
      this.pop_status = false
      this.pop_validacao = false
      this.popup_premio = false
      this.popup_mapa = false

      this.withGrid = false
      this.ic_impressao = false
      this.ic_posicao = false
      this.popupDocCard = true

      //this.setConfig(6);
    },

    onClickNoCard(e, d) {
      //Sempre será a Grid
      //------------Atenção ao alterar--------------
      localStorage.cd_parametro = e.cd_etapa
      this.cd_etapa = e.cd_etapa ? e.cd_etapa : d.cd_etapa
      this.cd_rota = 0
      this.cd_form = 0
      this.cd_api = e.cd_api ? e.cd_api : d.cd_api
      this.cd_menu = e.cd_menu ? e.cd_menu : d.cd_menu
      this.cd_documento = d.cd_documento
      this.cd_item_documento = d.cd_item_documento
      this.titulo_bar = d.nm_etapa
      switch (this.titulo_bar) {
        case 'Propostas':
          this.nm_tipo = 'Proposta'
          break
        case 'Carteira':
          this.nm_tipo = 'Pedido'
          break
        default:
          this.nm_tipo = 'Pedido'
      }
      //---------------------------------------------
      this.InfoConsulta = {
        nm_contato: d.nm_destinatario,
        vl_card: d.sg_modulo,
        dt_card: d.dt_movimento,
        cd_movimento: d.cd_movimento,
        nm_vendedor: d.nm_vendedor,
        tipo_proposta: d.nm_atendimento,
        nm_transportadora: d.nm_transportadora,
        nm_condicao_pagamento: d.nm_condicao_pagamento,
        vl_credito: d.vl_credito,
        vl_saldo: d.vl_saldo,
        cd_pagina: d.cd_pagina,
        nm_titulo_pagina_etapa: d.nm_titulo_pagina_etapa,
        nm_pagina: d.nm_pagina,
        nm_caminho_pagina: d.nm_caminho_pagina,
      }
      this.ic_cab_etapa = d.ic_cab_etapa ? d.ic_cab_etapa : e.ic_cab_etapa
      this.setConfig(3) //popupVisible
    },

    async ProcessoMulti(process) {
      this.dataCheckbox.forEach(async (item) => {
        let json_salvar_processo = {
          cd_empresa: localStorage.cd_empresa,
          cd_modulo: localStorage.cd_modulo,
          cd_menu: localStorage.cd_menu,
          cd_processo: process.cd_processo,
          cd_documento: item.cd_documento,
          cd_item_documento: 0,
          cd_etapa: item.cd_etapa,
          cd_form: process.cd_form,
          cd_parametro: 0, //this.prop_form.cd_documento ? "2" : "1", //2 - Update | 1 - Insert
          cd_usuario: localStorage.cd_usuario,
          dt_usuario: formataData.AnoMesDia(new Date()),
        }
        try {
          let [result] = await Incluir.incluirRegistro('921/1431', json_salvar_processo) //pr_api_geracao_processo_sistema
          if (result.Msg !== '') {
            notify(result.Msg)
          } else {
            notify('Processo salvo com sucesso')
          }
        } catch (error) {
          // eslint-disable-next-line no-console
          console.error(error)
          notify(
            `Não foi possivel executar o processo, verifique o processo ${process.cd_processo}`
          )
        }
      })
      this.pop_multi_cards = false
      this.dataCheckbox = []
      this.dados_pipeline.map((item) => {
        item.nm_status = ''
      })
      await this.carregaDados()
    },

    onDashboard(e) {
      this.cd_rota = 0
      this.cd_form = e.cd_form
      this.setConfig(4) //this.pop_auto
    },

    async confirmaSenha() {
      if (this.nm_senha === this.movimento_processo.cd_senha_processo) {
        this.pop_senha_proceso = false
        this.senhaAutorizada = true
        await this.onProcessItem(this.card_movimento, this.item_movimento, this.movimento_processo)
      } else {
        notify('Senha incorreta!')
      }
    },

    async onProcessItem(card, e, process) {
      //Ele perguntara a senha uma vez e após isso não mais
      //Se quiser que pergunte a senha sempre é só descomentar a linha abaixo
      //this.senhaAutorizada = false;
      if (process.cd_senha_processo && !this.senhaAutorizada) {
        this.card_movimento = card
        this.item_movimento = e
        this.movimento_processo = process
        this.pop_senha_proceso = true
        this.senhaAutorizada = false
        return
      }
      if (process.cd_processo > 0) {
        let json_salvar_processo = {
          cd_empresa: localStorage.cd_empresa,
          cd_modulo: localStorage.cd_modulo,
          cd_menu: localStorage.cd_menu,
          cd_processo: process.cd_processo,
          cd_documento: card.cd_documento,
          cd_item_documento: card.cd_item_documento,
          cd_etapa: card.cd_etapa,
          cd_form: card.cd_form,
          cd_parametro: 0, //this.prop_form.cd_documento ? "2" : "1", //2 - Update | 1 - Insert
          cd_usuario: localStorage.cd_usuario,
          dt_usuario: formataData.AnoMesDia(new Date()),
        }
        try {
          let [result] = await Incluir.incluirRegistro('921/1431', json_salvar_processo) //pr_api_geracao_processo_sistema
          if (result.Msg !== '') {
            notify(result.Msg)
          } else {
            notify(
              `Não foi possivel executar o processo, verifique o processo ${process.cd_processo}`
            )
          }
        } catch (error) {
          // eslint-disable-next-line no-console
          console.error(error)
          notify('Não foi possivel salvar o processo')
        }
        return
      }
      this.props_oportunidade.cd_step = 3
      this.cd_rota = process.cd_rota_menu ? process.cd_rota_menu : e.cd_rota
      this.cd_form = process.cd_form

      if (this.cd_rota == 103 || this.cd_rota == 125 || this.cd_rota == 137) {
        this.maximizedToggle = false
      } else {
        this.maximizedToggle = true
      }

      if (this.cd_rota === undefined) {
        notify('Erro ao abrir o menu!')
        return
      }
      if (!this.cd_rota == 0 || !this.cd_form == 0) {
        this.props_oportunidade.cd_movimento = card.cd_movimento
        this.props_oportunidade.cd_documento = card.cd_documento
        this.props_oportunidade.cd_item_documento = card.cd_item_documento
        this.props_oportunidade.cd_etapa = card.cd_etapa
        this.props_oportunidade = card
        this.props_oportunidade.nm_caminho_pagina = process.nm_caminho_pagina
        this.props_oportunidade.nm_endereco_pagina = process.nm_endereco_pagina
        this.titulo_bar = `${localStorage.nm_modulo} - ${localStorage.fantasia}`
        this.cd_documento = card.cd_documento
        this.cd_item_documento = card.cd_item_documento
        this.setConfig(4) //this.pop_auto
      }
    },

    onClick(dados) {
      this.card_json = dados
      this.cd_etapa = dados.cd_etapa
      this.cd_rota = dados.cd_rota
      this.cd_form = dados.cd_form
      this.cd_api = dados.cd_api
      this.cd_menu = dados.cd_menu
      this.cd_documento = dados.cd_documento
      this.cd_item_documento = dados.cd_item_documento
      this.dados_popup = dados

      localStorage.cd_item_documento = dados.cd_item_documento

      if (localStorage.cd_item_documento == undefined) {
        localStorage.cd_item_documento = 0
      }

      localStorage.cd_mov = dados.cd_movimento

      this.titulo_bar = ''

      if (!dados.nm_menu == '') {
        this.titulo_bar = dados.nm_menu
      }

      localStorage.cd_documento = this.cd_documento

      if (localStorage.cd_docu == undefined) {
        localStorage.cd_docu = 0
      }

      localStorage.cd_item_documento = this.cd_item_documento

      this.grava_etapa = true
      this.grava_mov = false

      //até digitar a API correta
      //localStorage.cd_parametro      = this.cd_documento;
      //
      //
      //
      //if (! this.cd_documento == 0) {
      //  this.showInfo();
      //}

      this.setConfig(6) //this.popupVisible    = true;
    },

    onClickProcesso(dados) {
      this.props_oportunidade.cd_movimento = 0
      this.props_oportunidade.cd_documento = undefined
      /////////////////////////////////////////
      if (dados.cd_form != 0 || dados.cd_rota != 0) {
        //Abre popup se tiver form ou rota
        this.setConfig(4) //this.pop_auto
      }
      /////////////////////////////////////////
      this.cd_documento = 0
      this.cd_item_documento = 0
      this.titleProcesso = dados.nm_etapa
      this.cd_etapa = dados.cd_etapa
      this.cd_rota = dados.cd_rota
      this.cp = 0
      this.cd_form = dados.cd_form
      this.cd_api = dados.cd_api
      this.cd_menu = dados.cd_menu
      this.props_oportunidade = dados
      this.titulo_bar = `${localStorage.nm_modulo} - ${localStorage.fantasia}`
      localStorage.cd_kan = this.cd_etapa

      if (!this.cd_rota == 0 || !this.cd_form == 0) {
        this.cp = 1
      }
    },

    onClickGrafico(dados) {
      this.ic_grafico_do_kanban_individual = !this.ic_grafico_do_kanban_individual
      this.dados_kanban_etapa = this.dados_pipeline.filter((e) => e.cd_etapa == dados.cd_etapa)
      this.cd_etapa = dados.cd_etapa
      this.cd_rota = dados.cd_rota
      this.cd_form = dados.cd_form
      this.cd_api = dados.cd_api
      this.cd_menu = dados.cd_menu
    },

    //async Ativa_premio() {
    //  for (var i = 0; i < this.fechou_rs.length; i++) {
    //    var musica = Math.floor(Math.random() * this.Array_musica.length);
    //    var data = { soundurl: this.Array_musica[musica] };
    //    var audio = new Audio(data.soundurl);
    //
    //    audio.play();
    //
    //    this.nome_premio = this.fechou_rs[i].nm_executor;
    //    this.contato_premio = this.fechou_rs[i].nm_contato;
    //    this.empresa_premio = this.fechou_rs[i].nm_destinatario;
    //    this.cd_movimento = this.fechou_rs[i].cd_movimento;
    //
    //    var api_premio = "595/824";
    //
    //    var dados_premio = {
    //      cd_parametro: 0,
    //      cd_movimento: this.cd_movimento,
    //    };
    //    var a = await Incluir.incluirRegistro(api_premio, dados_premio);
    //    if (a.length > 0) {
    //      this.cd_posicao = a[0].cd_controle;
    //      this.cd_pontuacao = a[0].Pontuacao;
    //    } else {
    //      return;
    //    }
    //    this.popup_premio = true;
    //    await this.sleep(36000);
    //    this.popup_premio = false;
    //  }
    //  this.fechou_rs = [];
    //  this.nome_premio = "";
    //  this.contato_premio = "";
    //  this.empresa_premio = "";
    //  this.cd_movimento = 0;
    //},

    async atualizaKanban() {
      this.qtdEtapa = this.dados_pipeline.reduce((acumulador, item) => {
        acumulador[item.cd_etapa] = (acumulador[item.cd_etapa] || 0) + 1
        return acumulador
      }, {})
      Object.entries(this.qtdEtapa).forEach(([valor, frequencia]) => {
        if (frequencia > 100) {
          this.paginationEtapa = []
          this.paginationEtapa = this.dados_pipeline.filter((item) => {
            return item.cd_etapa == valor
          })
          this.paginationEtapa = this.paginationEtapa.slice(
            this.paginationCount,
            this.paginationEtapa.length
          )
          this.dados_pipeline = this.dados_pipeline.filter((itemCompleto) => {
            if (
              !this.paginationEtapa.find(
                (item) =>
                  valor == itemCompleto.cd_etapa && item.cd_documento == itemCompleto.cd_documento
              )
            ) {
              return itemCompleto
            }
          })
        }
      })
      if (this.dados_pipeline.length > 0) {
        for (let d = 0; d < this.dados_pipeline.length; d++) {
          this.dados_pipeline[d].mostraFiltro = 'S'
        }
      }
      await this.ConfirmIc(1)
    },

    async carregaPipes() {
      let api = ''
      //pr_movimento_modulo_pipeline
      localStorage.cd_parametro = 1
      if (!this.dados_menu_pipeline.nm_identificacao_api) {
        this.dados_menu_pipeline = await Menu.montarMenu(this.cd_empresa, 0, 569) //pr_movimento_modulo_pipeline
      }
      if (this.dados_pipeline.length == 0) {
        api = this.dados_menu_pipeline.nm_identificacao_api
        sParametroApi = this.dados_menu_pipeline.nm_api_parametro
        this.dados_pipeline = []

        this.dados_pipeline = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        )
        this.dados_pipeline_completo = this.dados_pipeline
        this.ic_popup_confirmacao = false
        this.dados_pipeline.map((pipe) => {
          if (pipe.ic_popup_confirmacao == 'S') {
            this.ic_popup_confirmacao = true
          }
        })
      } else {
        this.dados_pipeline = []
        this.dados_pipeline = this.dados_pipeline_completo
      }
      await this.atualizaKanban()
    },

    async usuario() {
      await this.carregaPipes()
      //Status
      var api = ''
      try {
        this.qt_registro = this.dados_pipeline.length
        this.dados_status = this.dados_pipeline.nm_status_etapa
        localStorage.cd_parametro = 2

        this.dados = await Menu.montarMenu(this.cd_empresa, 0, 604)

        //
        api = this.dados.nm_identificacao_api

        sParametroApi = this.dados.nm_api_parametro

        this.dados_status = []

        this.dados_status = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        )
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error)
      }
      //Indicadores
      // try {
      //   this.load_indicador = true
      //   localStorage.cd_parametro = 999;
      //   let api = "";
      //   let indicadores = await Menu.montarMenu(this.cd_empresa, 0, 604);
      // //
      // api = indicadores.nm_identificacao_api;

      // sParametroApi = indicadores.nm_api_parametro;
      // this.dados_indicador = await Procedimento.montarProcedimento(
      //   this.cd_empresa,
      //   this.cd_cliente,
      //   api,
      //   sParametroApi,
      // );
      // this.$emit("indicadores", this.dados_indicador);
      // } catch (error) {
      //   // eslint-disable-next-line no-console
      //   console.error(error)
      // } finally {
      //   this.load_indicador = false;
      // }
      try {
        this.load_indicador = true
        localStorage.cd_parametro = 999
        let api = ''
        let indicadores = await Menu.montarMenu(this.cd_empresa, 0, 604)
        //
        api = indicadores.nm_identificacao_api

        sParametroApi = indicadores.nm_api_parametro
        this.dados_indicador = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        )
        this.$emit('indicadores', this.dados_indicador)
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error)
      } finally {
        this.load_indicador = false
      }

      //Botões barras
      try {
        localStorage.cd_parametro = 100
        let api = ''
        let botoes_barra = await Menu.montarMenu(this.cd_empresa, 0, 604)

        //
        api = botoes_barra.nm_identificacao_api

        sParametroApi = botoes_barra.nm_api_parametro

        this.dados_botoes_barra = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api,
          sParametroApi
        )

        /*
        if (this.dados_botoes_barra[0].Msg) {
          //notify(this.dados_botoes_barra[0].Msg);
          this.dados_botoes_barra = [];
        }
        */
        const msg = this.dados_botoes_barra?.[0]?.Msg ?? null
        if (msg) {
          // notify(msg);
          this.dados_botoes_barra = []
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error)
      }
      localStorage.cd_parametro = 1
    },

    async onClickRelatorio(card, d, e) {
      try {
        this.tituloPop = 'Relatório ' + e.nm_etapa

        this.cd_relatorio = card.cd_relatorio
        this.cd_documento = card.cd_documento
        this.cd_item_documento = card.cd_item_documento
        if (card.nm_link_relatorio) {
          try {
            this.load_tela = true
            window.open(
              `${card.nm_link_relatorio}` //`http://34.203.196.98:8085/emitirDANFE?cd_empresa=${this.cd_empresa}&nf=${card.cd_movimento}&serie=${card.cd_serie_nota}`,
            )
            this.load_tela = false
          } catch {
            this.load_tela = false
          }
        } else if (card.cd_relatorio > 0) {
          try {
            this.load_tela = true
            let json_relatorio = {
              cd_empresa: localStorage.cd_empresa,
              cd_modulo: localStorage.cd_modulo,
              cd_menu: localStorage.cd_menu,
              cd_relatorio: card.cd_relatorio,
              cd_processo: '',
              cd_item_processo: '',
              cd_documento_form: card.cd_documento,
              cd_item_documento_form: '0',
              cd_parametro: '0',
              cd_usuario: localStorage.cd_usuario,
            }
            let [relatorio] = await Incluir.incluirRegistro('923/1433', json_relatorio) //pr_egis_relatorio_padrao
            // let json_relatorio = {
            //   cd_consulta: card.cd_documento,
            //   //cd_pedido_venda: this.prop_form.cd_documento,
            //   cd_menu: 5428,
            //   cd_parametro: 14,
            //   cd_usuario: localStorage.cd_usuario,
            // };
            // let [relatorio] = await Incluir.incluirRegistro(
            //   "897/1377",
            //   json_relatorio,
            // ); //pr_modulo_processo_egismob_post -> pr_egismob_relatorio_pedido
            //let documento = document.getElementById("relatorioHTML");
            //documento.innerHTML = relatorio.RelatorioHTML;
            //this.$refs.html2Pdf.generatePdf();
            const htmlContent = relatorio.RelatorioHTML // Armazene o conteúdo HTML retornado
            // Crie um blob com o conteúdo HTML
            const blob = new Blob([htmlContent], { type: 'text/html' })
            // Gere uma URL temporária para o blob
            const url = URL.createObjectURL(blob)
            // Abra a URL em uma nova aba
            window.open(url, '_blank')
            // Opcional: liberar o objeto URL depois que não for mais necessário
            URL.revokeObjectURL(url)
            notify('Relatório gerado com sucesso')
            this.load_tela = false
          } catch (error) {
            this.load_tela = false
            notify('Não foi possivel gerar o relatório')
          }
        } else {
          try {
            this.load_tela = true
            if (localStorage.cd_modulo == 260) {
              await this.$refs.relatoriopadrao.chamaRelatorio({
                cd_consulta: this.cd_documento,
              })
            }
            this.load_tela = false
            this.setConfig(9)
          } catch (error) {
            notify('Não foi possivel gerar o relatório!')
          }
        }
      } catch (error) {
        console.error(error)
      } finally {
        this.cd_relatorio = null
        this.cd_documento = null
        this.cd_item_documento = null
      }
    },

    onClickAbrirNfe(d) {
      window.open(d.nm_nfe_link, '_blank')
    },

    async onImprimirLocalNfe(d) {
      try {
        await axios.get(d.nm_link_nfe_local)
        notify('Documento aberto com sucesso!')
      } catch (error) {
        console.error(error)
        notify('Não foi possível abrir o documento')
      }
    },

    onClickBaixarXMLNfe(d) {
      const blob = new Blob([d.nm_xml], { type: 'application/xml' })

      const url = URL.createObjectURL(blob)

      const a = document.createElement('a')
      a.href = url
      a.download = `${d.nm_destinatario}-${d.cd_movimento}`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)

      setTimeout(() => URL.revokeObjectURL(url), 10000)
    },

    onClickEnviarEmailNfe(d) {
      window.open(d.nm_link_nfe_email, '_blank')
    },

    onClickVisualizar(d) {
      try {
        this.ic_popup_view = true
        this.caminho_view = 'http://www.egisnet.com.br/img/' + d.nm_imagem
      } catch {
        this.ic_popup_view = false
      }
    },

    async onEditStatusCard(card) {
      this.cardStatus = {
        cd_movimento: card.cd_movimento,
        cd_etapa: 0,
        cd_item_documento: card.cd_item_documento,
        cd_documento: card.cd_documento,
        dt_movimento: card.dt_movimento,
        nm_destinatario: card.nm_destinatario,
        sg_modulo: card.sg_modulo,
        nm_contato: card.nm_contato,
        nm_campo1: card.nm_campo1,
        nm_campo2: card.nm_campo2,
        nm_campo3: card.nm_campo3,
        nm_campo4: card.nm_campo4,
        nm_campo5: card.nm_campo5,
        nm_campo6: card.nm_campo6,
        nm_campo7: card.nm_campo7,
        nm_campo8: card.nm_campo8,
        nm_campo9: card.nm_campo9,
        nm_campo10: card.nm_campo10,
        nm_financeiro: card.nm_financeiro,
        titulo_status: card.nm_etapa,
      }

      this.cd_etapa = card.cd_etapa
      this.titulo_bar = card.nm_destinatario
      this.cd_movimento = card.cd_movimento
      this.cd_documento = card.cd_documento
      this.cd_item_documento = card.cd_item_documento
      this.titulo_status = card.nm_etapa
      this.num_status = card.cd_movimento
      this.cliente_status = card.nm_destinatario

      if (card.nm_contato != null) {
        this.cardStatus.nm_contato = '- ' + card.nm_contato
      } else {
        this.cardStatus.nm_contato = ''
      }

      if (this.cardStatus.nm_contato == '- ') {
        this.cardStatus.nm_contato = ''
      }

      this.ic_valida_status = card.ic_valida_status
      this.setConfig(8)
    },

    onLink(e, d) {
      this.nm_link = e.nm_endereco_link + '/' + d.cd_movimento
      this.nm_img_link = e.nm_local_imagem_link
      this.nm_titulo_link = e.nm_link
      this.popup_link = true
      this.popup_mapa = false
      this.popupAtividade = false
      this.popupVisibleDoc = false
      this.popupDocCard = false
      this.grava_etapa = false
      this.grava_mov = false
      this.withGrid = false
      this.popupVisible = false
      this.popupProcesso = false
      this.pop_status = false
      this.pop_auto = false
      this.ic_impressao = false
    },

    async onEditOportunidade(card, e) {
      try {
        this.props_oportunidade.cd_step = 3
        if (!!card.cd_interface == false) {
          card.cd_interface = 1
        }
        this.props_oportunidade.cd_cota_contrato = card.cd_interface
        this.cd_rota = e.cd_rota
        this.cd_form = e.cd_form

        if (this.cd_rota == 103 || this.cd_rota == 125 || this.cd_rota == 137) {
          this.maximizedToggle = false
        } else {
          this.maximizedToggle = true
        }

        if (this.cd_rota === undefined) {
          notify('Erro ao abrir o menu!')
          return
        }

        if (!this.cd_rota == 0 || !this.cd_form == 0) {
          this.props_oportunidade = card
          this.titulo_bar = `${localStorage.nm_modulo} - ${localStorage.fantasia}`
          this.cd_documento = card.cd_documento
          this.cd_item_documento = card.cd_item_documento
          this.setConfig(4) //this.pop_auto
        }
      } catch (error) {
        console.error(error)
      }
    },

    async showMenu(force = false) {
      // se já carregou e não foi pedido "force", não faz nada
      if (this.menuCarregado && !force) {
        return
      }

      this.cd_empresa = this.cd_empresa
      this.cd_cliente = localStorage.cd_cliente
      this.cd_parametro = 1
      this.cd_menu = 7221 //localStorage.cd_menu;
      this.cd_api = 581 //localStorage.cd_api;
      this.api = '581/801' //localStorage.nm_identificacao_api;
      this.cd_modulo = localStorage.cd_modulo

      this.dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api) //'titulo';
      sParametroApi = this.dados.nm_api_parametro

      if (!this.dados.nm_identificacao_api == '' && !this.dados.nm_identificacao_api == this.api) {
        this.api = this.dados.nm_identificacao_api
      }

      localStorage.cd_tipo_consulta = 0

      if (!this.dados.cd_tipo_consulta == 0) {
        this.dados.cd_tipo_consulta
      }

      if (this.dados.nm_menu_titulo != undefined) {
        this.tituloMenu = this.dados.nm_menu_titulo //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      }

      this.menuCarregado = true
    },

    async carregarCardsRapido() {
      this.load_carregar = true

      try {
        // cd_parametro 1 costuma ser “movimentos do módulo”
        localStorage.cd_parametro = 1

        const sApi = sParametroApi

        this.dados_pipeline = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          this.api,
          sApi
        )

        this.dados_pipeline_completo = this.dados_pipeline
        await this.atualizaKanban()
        await this.usuario() // se precisar atualizar status / indicadores
      } catch (err) {
        console.error(err)
        this.load_atividade = false
      } finally {
        this.load_carregar = false
      }
    },
    async carregaDados(opcoes = {}) {
      const { full = false } = opcoes

      this.load_carregar = true

      if (this.cd_modulo == 346) {
        // teu cálculo de semana continua igual
        const dates = await funcao.Semana(1)
        this.hoje = dates
        const d = await funcao.Semana(2)
        localStorage.dt_inicial = formatadata.formataDataSQL(d.dt_inicial)
        localStorage.dt_final = formatadata.formataDataSQL(d.dt_final)
      }

      try {
        this.filtroGeral = false

        // Só recarrega menu / estrutura se ainda não fez
        // ou se for um "full refresh"
        await this.showMenu(full || !this.menuCarregado)

        if (!this.primeiraCargaCompleta || full) {
          // aqui fica a parte que hoje monta dataSourceConfig
          // (config de etapas, totals, etc)
          localStorage.cd_parametro = 1
          const sApi = sParametroApi
          this.StatusTemporario = []

          if (sParametroApi) {
            this.dataSourceConfig = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_cliente,
              this.api,
              sApi
            )

            this.dataSourceConfig.map(async (e) => {
              if (e.dt_etapa) {
                e.dt_etapa = await formatadata.formataDataJS(e.dt_etapa)
              }
            })
          }

          this.primeiraCargaCompleta = true
        }

        // Agora recarrega apenas os cards
        this.dados_pipeline = []
        await this.usuario() // continua chamando carregaPipes lá dentro
      } catch (err) {
        console.error(err)
        this.load_atividade = false
      } finally {
        this.load_carregar = false
      }
    },

    async carregaDadosOld() {
      this.load_carregar = true
      if (this.cd_modulo == 346) {
        this.hoje = await funcao.Semana(1)
        const dates = await funcao.Semana(1)
        this.hoje = dates
        const d = await funcao.Semana(2)
        localStorage.dt_inicial = formatadata.formataDataSQL(d.dt_inicial)
        localStorage.dt_final = formatadata.formataDataSQL(d.dt_final)
      }
      try {
        this.filtroGeral = false
        await this.showMenu()
        this.load_atividade = true
        this.load_atividade = true

        if (this.inotifica == 0) {
          notify('Aguarde... estamos montando a consulta para você, aguarde !')
          this.inotifica = 1
        }

        localStorage.cd_parametro = 1

        let sApi = sParametroApi
        this.StatusTemporario = []
        if (!sParametroApi == '') {
          this.dataSourceConfig = []

          this.dataSourceConfig = await Procedimento.montarProcedimento(
            this.cd_empresa,
            this.cd_cliente,
            this.api,
            sApi
          )

          if (this.dataSourceConfig.length == 0) {
            notify('Nenhum registro encontrado!')
          }

          this.dataSourceConfig.map(async (e) => {
            if (e.dt_etapa) {
              e.dt_etapa = await formatadata.formataDataJS(e.dt_etapa)
            }
          })
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error)
        this.load_atividade = false
      }
      //this.items = this.dataSourceConfig;
      try {
        this.dados_pipeline = []
        await this.usuario()
      } catch {
        this.load_atividade = false
      } finally {
        this.load_carregar = false
      }

      // let JSON_atividade = {
      //   cd_parametro: 9,
      //   cd_modulo: this.cd_modulo,
      // };
      // try {
      //   this.atividade_modulo = await Incluir.incluirRegistro(
      //     "768/1167",
      //     JSON_atividade,
      //   );
      // } catch {
      //   this.load_atividade = false;
      // } finally {
      //   this.load_atividade = false;
      // }
    },

    onListReorder(e) {
      //const list = this.lists.splice(e.fromIndex, 1)[0];
      //this.lists.splice(e.toIndex, 0, list);

      //this.dataSourceConfig.splice(e.fromIndex, 1);
      //this.dataSourceConfig.splice(e.toIndex, 0, e.itemData);
      this.dataSourceConfig.splice(e.toIndex, 0, this.dataSourceConfig.splice(e.fromIndex, 1)[0])

      //aqui ccf - gravar a Api com a Ordem --> modulo_etapa_usuario

      //const status = this.statuses.splice(e.fromIndex, 1)[0];
      //this.statuses.splice(e.toIndex, 0, status);
    },

    confirmarTroca() {
      this.onTaskDrop(this.dadosArrastar, this.etapaArrastar)
      this.popupConfirm = false
    },

    cancelarTroca() {
      if (this.dados_movimento[0].cd_posicao == 0) {
        this.cancelar = this.dadosArrastar
        this.ic_posicao = true
        this.Msg = this.dados_movimento[0].Msg
      }
      this.popupConfirm = false
    },

    verificaEtapas(arrastar, etapa) {
      this.etapaArrastar = etapa // destino
      this.dadosArrastar = arrastar // origem
      arrastar.itemData = arrastar.fromData[arrastar.fromIndex]
      this.cancelar = arrastar.itemData.cd_etapa

      const etapa_origem = arrastar.itemData.cd_etapa
      const etapa_destino = etapa
      if (this.ic_aprov_requisicao !== 'S') {
        this.onTaskDrop(this.dadosArrastar, this.etapaArrastar)
        return
      }
      //Karen pediu para tirar 08/01/2026
      //if (etapa_origem == 64 && etapa_destino == 153) {
      //  this.dadosArrastarSenha = arrastar
      //  this.etapaArrastarSenha = etapa
      //
      //  this.popup_senha_movimento = true
      //  return
      //}
      if (etapa_destino == etapa_origem) {
        this.popupConfirm = false
      } else if (!this.ic_popup_confirmacao) {
        this.onTaskDrop(this.dadosArrastar, this.etapaArrastar)
      } else {
        this.popupConfirm = true
      }
    },

    async onVerificaSenhaMovimento() {
      if (this.nm_senha_digitada === '') {
        notify('Digite a senha para continuar!')
        return
      }
      try {
        let json_verifica_senha_colaborador = {
          cd_parametro: 3,
          cd_usuario: localStorage.cd_usuario,
          nm_senha: this.nm_senha_digitada,
        }
        let [resultado_senha] = await Incluir.incluirRegistro(
          '966/1482',
          json_verifica_senha_colaborador
        ) //pr_egisnet_controle_config_usuario
        notify(resultado_senha.Msg)
        if (resultado_senha.autorizacao === 'S') {
          this.popup_senha_movimento = false
          this.nm_senha_digitada = ''

          if (this.dadosArrastarSenha && this.etapaArrastarSenha != null) {
            await this.onTaskDrop(this.dadosArrastarSenha, this.etapaArrastarSenha)
          }
          this.dadosArrastarSenha = null
          this.etapaArrastarSenha = null
        } else {
          notify('Senha incorreta! O card voltará para a etapa original.')

          this.popup_senha_movimento = false
          this.nm_senha_digitada = ''
          if (this.dadosArrastarSenha) {
            const origem = this.dadosArrastarSenha.itemData.cd_etapa
            this.dadosArrastarSenha.itemData.cd_etapa = origem
          }
          this.dadosArrastarSenha = null
          this.etapaArrastarSenha = null
        }
      } catch (error) {
        console.error('Error: ', error)
        notify('Erro ao verificar a senha. Tente novamente.')

        this.popup_senha_movimento = false
        this.nm_senha_digitada = ''
        this.dadosArrastarSenha = null
        this.etapaArrastarSenha = null
      }
    },

    onTaskDragStart(e, origem) {
      //e.itemData = e.fromData[e.fromIndex].cd_etapa;
      //mostra o numero de qual etapa ele esta sendo puxado
      e.itemData = e.fromData[e.fromIndex]
      this.cd_etapa_origem = origem
    },

    async onTaskDrop(e, t) {
      var cd_etapa_destino = t //Valor da etapa destino
      //Se o card for para Negociação ele deve alterar o flag caso volte para perda.
      if (cd_etapa_destino == 33) {
        e.itemData.ic_popup_altera = 'S'
      }
      if (this.cd_etapa_origem !== cd_etapa_destino) {
        e.itemData.cd_etapa = cd_etapa_destino //
        //Chamar a Api de Atualização do Movimento da Etapa//
        //15.01.2022

        localStorage.cd_parametro = localStorage.cd_modulo
        localStorage.cd_documento = e.itemData.cd_documento || e.itemData.cd_movimento
        localStorage.cd_tipo_documento = e.itemData.cd_tipo_documento
          ? e.itemData.cd_tipo_documento
          : 0
        localStorage.cd_item_documento = e.itemData.cd_item_documento
          ? e.itemData.cd_item_documento
          : 0
        localStorage.cd_etapa_origem = this.cd_etapa_origem
        localStorage.cd_etapa_destino = cd_etapa_destino
        let api = ''

        this.dados = await Menu.montarMenu(this.cd_empresa, 0, 633) //pr_geracao_movimento_modulo_etapa
        api = this.dados.nm_identificacao_api
        sParametroApi = this.dados.nm_api_parametro
        this.dados_movimento = []

        localStorage.cd_etapa = ''
        //1499 - pr_geracao_movimento_modulo_etapa
        //Observa se existe o card precizsa acrescentar alguma informação no arrastar ------------------------------------------
        await this.cardObserver(e, cd_etapa_destino)
        //Calculo do total dos kanbans.........................................................................................

        if (this.ic_posicao == false && this.popupAltera == false) {
          try {
            this.dados_movimento = await Procedimento.montarProcedimento(
              this.cd_empresa,
              this.cd_cliente,
              api,
              sParametroApi
            )
            //Caso exista retorno da pr o front é atualizadop com novo numero indicador
            if (this.dados_movimento[0].cd_movimento != undefined) {
              notify(this.dados_movimento[0].Msg)
              e.itemData.cd_movimento = this.dados_movimento[0].cd_movimento
            } else {
              notify(this.dados_movimento[0].Msg)
            }
          } catch (error) {
            notify('Não foi possível realizar o processo!')
            this.CalculaCard(this.cd_etapa_origem, cd_etapa_destino)
          }
          this.ic_posicao = false

          if (this.dados_movimento[0].cd_posicao == 0) {
            e.itemData.cd_etapa = this.cd_etapa_origem
            this.ic_posicao = true
            this.Msg = this.dados_movimento[0].Msg
          } else {
            this.CalculaCard(this.cd_etapa_origem, cd_etapa_destino)
          }
        }
      }
    },

    onCheckBox(e) {
      if (e.nm_status === 'S') {
        this.dataCheckbox.push(e)
      } else {
        this.dataCheckbox = this.dataCheckbox.filter((item) => {
          return item.cd_movimento !== e.cd_movimento
        })
      }
      this.dataCheckbox = this.dataCheckbox.filter((item) => {
        return item.cd_etapa === e.cd_etapa
      })
      this.dados_pipeline.map((item) => {
        if (item.cd_etapa !== e.cd_etapa) {
          item.nm_status = ''
        }
      })
    },
    async cardObserver(card, etapa) {
      //Obtém o cd_movimento e abre o popup para registro de perda
      this.cd_movimento = card.itemData.cd_movimento
      if (
        card.itemData.ic_popup_altera == 'S' &&
        [294, 122].includes(etapa) &&
        [33, 43].includes(this.cd_etapa_origem)
      ) {
        this.popupAltera = true
        this.cd_componente = card.itemData.cd_componente
        !!this.cd_componente == false ? (this.cd_componente = 1) : ''
      }
    },

    nl2brSafe(text = '') {
      // transforma "/n" e "\n" em nova linha real
      let s = String(text || '')
      s = s.replace(/\/n/g, '\n').replace(/\\n/g, '\n')

      // escapa HTML e converte quebras reais em <br/>
      const esc = s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      return esc.replace(/\r\n|\r|\n/g, '<br/>')
    },

    PegaTitulo() {
      if (!localStorage.titulo_menu_watch == '') {
        this.titulo_bar = localStorage.titulo_menu_watch
      }
    },
    getPriorityClass(task) {
      return `priority-${task.cd_prioridade}`
    },
    scrollKanban(direction) {
      const scrollViewInstance = this.$refs.kanbanScrollRef.instance
      const scrollStep = 300
      const offset = direction === 'right' ? scrollStep : -scrollStep
      scrollViewInstance.scrollBy({ left: offset })
    },
    onClickPagina(infoConsulta) {
      if (infoConsulta.nm_caminho_pagina) {
        let jsonOriginal = JSON.stringify({
          banco: localStorage.nm_banco_empresa,
          usuario: 'admin',
          senha: '1234',
          cd_usuario: 1,
          dt_inicial: localStorage.dt_inicial,
          dt_final: localStorage.dt_final,
        })
        let jsonBase64 = btoa(jsonOriginal)
        const url = new URL(infoConsulta.nm_caminho_pagina)
        const params = url.searchParams
        params.set('cd_usuario', localStorage.cd_usuario)
        params.set('cd_empresa', localStorage.cd_empresa)
        params.set('cd_relatorio', localStorage.cd_relatorio)
        params.set('dt_inicial', localStorage.dt_inicial)
        params.set('dt_final', localStorage.dt_final)
        params.set('cd_documento', infoConsulta.cd_movimento || infoConsulta.cd_documento)
        params.set('banco', localStorage.nm_banco_empresa)
        params.set('dados_b64', jsonBase64)
        infoConsulta.nm_caminho_pagina = url.toString()
        window.open(infoConsulta.nm_caminho_pagina, '_blank')
      } else {
        notify('Nenhuma URL disponível para abrir.')
      }
    },
  },
}
</script>

<style scoped>
.toolbar-label,
.toolbar-label > b {
  font-size: 16px;
}

.dashboard {
  display: flex;
}

.conteudo {
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background-color: #f9f9f9;
  width: 200px;
}

.aviso {
  font-size: 20px;
  font-weight: bold;
  color: #ff5722;
  padding: 5px;
}

.resultado {
  font-size: 16px;
  color: #757575;
  font-weight: bold;
  text-decoration: underline;
}

.paginationButton {
  margin-left: 20px;
}

#pie {
  height: 240px;
  padding-left: -50px;
}

.list {
  border-radius: 8px;
  margin: 5px;
  background-color: rgba(192, 192, 192, 0.4);
  display: inline-block;
  vertical-align: top;
  white-space: nowrap;
  max-width: 400px;
  height: 69vh;
}

.badge-data {
  font-weight: bold;
  font-size: 14px;
}

.list-title {
  display: flex;
  flex-wrap: nowrap;
  font-size: 16px;
  padding: 8px;
  padding-left: 8px;
  margin-bottom: -10px;
  font-weight: bold;
  cursor: pointer;
}

.scrollable-list {
  min-height: 400px;
  height: 65vh;
  min-width: 320px;
}

.sortable-cards {
  min-height: 300px;
  /*height: 69vh;*/
  max-height: 92%;
}

.card {
  position: relative;
  background-color: white;
  box-sizing: border-box;
  width: 100%; /* Ocupa 100% do espaço disponível na coluna */
  max-width: 100%; /* Garante que não ultrapasse os limites da coluna */
  padding: 10px 20px;
  margin: 10px; /* Ajusta espaçamento vertical */
  cursor: pointer;
  overflow: hidden; /* Evita que o conteúdo extrapole */
  word-wrap: break-word; /* Quebra palavras longas */
  white-space: normal; /* Permite quebra de linha */
}

.card-subject {
  padding-bottom: 10px;
}

.card-assignee {
  opacity: 0.6;
  max-width: 280px;
  overflow-wrap: break-word;
  word-wrap: break-word;
  word-break: break-word;
}

.card-hour {
  font-weight: bold;
  color: rgb(100, 100, 253);
  float: right;
}

.orange {
  color: #ff5722;
}

.esquerda {
  float: right;
  opacity: 1;
  margin-left: 1px;
  margin-right: 5px;
}
.direita {
  float: left;
  opacity: 1;
}

.FundoPremio {
  background: url('https://acegif.com/wp-content/gif/confetti-17.gif');
}

.MeuGif {
  width: 300px;
  height: 300px;
  align-content: right;
}

#kanban {
  white-space: nowrap;
}

.scrollable-board {
  width: 100%;
  height: 70vh;
}

.sortable-lists {
  padding: 0 400px 0 0;
  margin: 0 200px 0 0;
  max-height: 97%;
}

.margin1 {
  margin: 0.5vh 0.5vw;
  padding: none;
}
.setenta-tela {
  width: 60%;
}
.trinta-tela {
  width: 40%;
  float: right;
}
.toolbar-center {
  height: 80px;
  width: 98%;
}
/*PRIMEIRA MEDIA-----------------------------------------------------------------------*/
@media screen and (max-height: 480px) {
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

.metadeTela {
  width: 47.5%;
}

@media screen and (max-width: 1024px) {
  #kanban {
    white-space: normal;
  }

  .scrollable-board {
    height: auto;
  }

  .scrollable-board .dx-scrollview-content {
    display: flex;
    flex-direction: column;
  }

  .sortable-lists {
    display: flex;
    flex-direction: column;
    padding: 0;
    margin: 0;
  }

  .list {
    display: block;
    max-width: 100%;
    width: 100%;
    white-space: normal;
  }
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
  .msgCentral {
    display: none;
  }
}

.arrows {
  display: flex;
  justify-content: space-between;
}

.btn-dash {
  margin-left: -10px;
}
</style>
