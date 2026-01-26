<template>
  <div :class="['unico-root', { 'unico-embed': embedMode }]">
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />

    <!-- TOPO no estilo -->

    <div v-if="!hideChrome && !isEmbeddedClean" class="row items-center">
      <transition name="slide-fade">
        <!-- título + seta + badge -->
        <h2
          class="content-block col-8 row items-center no-wrap toolbar-scroll"
          v-show="displayTitle"
        >
          <!-- seta voltar -->
          <q-btn
            flat
            round
            dense
            icon="arrow_back"
            class="q-mr-sm seta-form"
            aria-label="Voltar"
            @click="onVoltar"
          />
          <span
            v-if="displayTitle"
            :class="ic_modal_pesquisa === 'S' ? 'titulo-modal' : ''"
          >
            {{ displayTitle }}
          </span>

          <!--{{ tituloMenu || title }}-->

          <!-- badge com total de registros -->

          <div style="display: flex; align-items: center;">
            <q-badge
              v-if="(qt_registro || recordCount) >= 0"
              align="middle"
              rounded
              color="red"
              :label="qt_registro || recordCount"
              class="q-ml-sm bg-form"
            />
          </div>

          <template v-if="mostrarToolbar">
            <slot name="toolbar-left" :engine="this" />
          </template>

          <template v-if="!uiLite && mostrarToolbar">
            <q-btn
              v-if="cd_tabela > 0 && !isHidden('novo')"
              dense
              rounded
              color="deep-purple-7"
              :class="['q-mt-sm', 'q-ml-sm', cd_tabela != 0 ? 'fo-margin' : '']"
              icon="add"
              @click="toolbarNovo"
            >
              <q-tooltip>Novo Registro</q-tooltip>
            </q-btn>

            <q-btn
              v-if="cd_tabela > 0 && !isHidden('novo')"
              dense
              rounded
              color="deep-purple-7"
              :class="['q-mt-sm', 'q-ml-sm']"
              icon="filter_alt"
              @click="toolbarFiltros"
            >
              <q-tooltip>Filtros</q-tooltip>
            </q-btn>

            <q-btn
              v-if="!isHidden('refresh')"
              dense
              rounded
              icon="refresh"
              color="deep-purple-7"
              :class="[
                'q-mt-sm',
                'q-ml-sm',
                cd_tabela === 0 ? 'fo-margin' : '',
              ]"
              @click="toolbarRefresh"
            >
              <q-tooltip>Atualizar os Dados</q-tooltip>
            </q-btn>

            <q-btn
              v-if="cd_form_modal > 0"
              rounded
              dense
              color="deep-purple-7"
              class="q-mt-sm q-ml-sm"
              icon="tune"
              :disable="cd_form_modal <= 0"
              @click="toolbarDetalhe"
            >
              <q-tooltip>Detalhe</q-tooltip>
            </q-btn>

            <q-btn
              v-if="!isHidden('excel')"
              rounded
              dense
              color="deep-purple-7"
              icon="far fa-file-excel"
              class="q-mt-sm q-ml-sm"
              @click="toolbarExcel"
            >
              <q-tooltip>Exportar Excel</q-tooltip>
            </q-btn>

            <q-btn
              v-if="!isHidden('pdf')"
              rounded
              dense
              color="deep-purple-7"
              class="q-mt-sm q-ml-sm"
              icon="picture_as_pdf"
              @click="toolbarPDF"
            >
              <q-tooltip>Exportar PDF</q-tooltip>
            </q-btn>
            <q-btn
              v-if="!isHidden('relatorio')"
              rounded
              dense
              color="deep-purple-7"
              class="q-mt-sm q-ml-sm"
              icon="description"
              @click="toolbarRelatorio"
            >
              <q-tooltip>Abrir Relatório</q-tooltip>
            </q-btn>

            <q-btn
              v-if="!isHidden('dash')"
              dense
              rounded
              color="deep-purple-7"
              icon="dashboard"
              class="q-mt-sm q-ml-sm"
              @click="toolbarDash"
            >
              <q-tooltip>Dashboard dos dados</q-tooltip>
            </q-btn>

            <!-- Botão de processos (3 pontinhos) -->
            <q-btn
              v-if="cd_menu_processo > 0"
              dense
              rounded
              color="deep-purple-7"
              class="q-mt-sm q-ml-sm"
              icon="more_horiz"
              @click="toolbarProcessos"
            >
              <q-tooltip>Processos</q-tooltip>
            </q-btn>
            <q-btn
              v-if="!isHidden('mapaAtributos')"
              rounded
              dense
              color="deep-purple-7"
              class="q-mt-sm q-ml-sm"
              icon="view_list"
              @click="toolbarMapaAtributos"
            >
              <q-tooltip>Mapa de Atributos</q-tooltip>
            </q-btn>

            <q-btn
              v-if="false && !isHidden('info')"
              dense
              rounded
              color="deep-purple-7"
              class="q-mt-sm q-ml-sm"
              icon="info"
              @click.stop.prevent="toolbarInfo"
            >
              <q-tooltip>Informações</q-tooltip>
            </q-btn>

            <q-btn
              v-if="filtros && filtros.length"
              dense
              rounded
              color="deep-purple-7"
              class="q-mt-sm q-ml-sm"
              icon="filter_alt_off"
              @click="toolbarDrawerFiltros"
            >
              <q-tooltip>Seleção de Filtros</q-tooltip>
            </q-btn>

            <!-- TOGGLE: GRID x CARDS (só aparece quando meta permite) -->

            <q-toggle
              v-if="String(ic_card_menu || 'N').toUpperCase() === 'S'"
              v-model="exibirComoCards"
              color="deep-purple-7"
              checked-icon="view_module"
              unchecked-icon="view_list"
              :label="exibirComoCards ? 'cards' : 'grid'"
              keep-color
              class="q-mt-sm q-ml-sm"
            />

            <!-- TOGGLE TreeView x Grid -->

            <q-toggle
              v-if="String(ic_treeview_menu || 'N').toUpperCase() === 'S'"
              v-model="exibirComoTree"
              color="deep-purple-7"
              checked-icon="account_tree"
              unchecked-icon="view_list"
              :label="exibirComoTree ? 'tree' : 'grid'"
              keep-color
              class="q-mt-sm q-ml-sm"
            />

            <q-chip
              v-if="cdMenu || cd_menu"
              dense
              rounded
              color="deep-purple-7"
              class="q-mt-sm q-ml-sm margin-menu"
              size="12px"
              text-color="white"
              :label="`${cdMenu || cd_menu}`"
              @click.native.stop.prevent="showAvisoConfig = true"
            >
              <q-tooltip>identificação</q-tooltip>
            </q-chip>
          </template>

          <template v-if="mostrarToolbar">
            <slot name="toolbar-right" :engine="this" />
          </template>
        </h2>
      </transition>

      <modal-composicao
        v-if="mostrarBotaoModalComposicao && this.ic_grid_modal === 'N'"
        v-model="dialogModalComposicao"
        :cd-modal="cd_form_modal"
        :registros-selecionados="registrosSelecionados"
        @sucesso="onSucessoModal"
      />

      <modal-grid-composicao
        v-if="mostrarBotaoModalComposicao && ic_grid_modal === 'S'"
        v-model="dialogModalGridComposicao"
        :cd-modal="cd_form_modal"
        :registros-selecionados="registrosSelecionados"
        @sucesso="onSucessoModal"
      />

      <!-- Ações à direita (como no seu topo) -->

      <div class="col">
        <!-- Modal -->

        <!-- Dialog para exibir o dashboard -->

        <q-dialog
          v-model="showDashDinamico"
          maximized
          content-class="dlg-form-branco"
        >
          <q-card class="q-pa-sm" style="height:100vh;width:100vw;">
            <q-btn
              flat
              dense
              round
              icon="close"
              class="absolute-top-right q-ma-sm"
              @click="showDashDinamico = false"
            />
            <dashboard-dinamico
              :rows="rowsParaDashboard"
              :columns="colsParaDashboard"
              :titulo="tituloDashboard"
              :cd-menu="cd_menu || cdMenu"
              :return-to="returnTo"
              @voltar="showDashDinamico = false"
            />
          </q-card>
        </q-dialog>

        <q-dialog v-model="infoDialog" content-class="dlg-form-branco">
          <q-card style="min-width: 640px">
            <q-card-section class="text-h6">
              <q-icon
                name="info"
                color="deep-orange-9"
                size="48px"
                class="q-mr-sm"
              />
              {{ infoTitulo }}</q-card-section
            >
            <q-separator />
            <q-card-section class="text-body1">
              {{ infoTexto }}
            </q-card-section>
            <q-card-actions align="right">
              <q-btn flat label="Fechar" color="primary" v-close-popup />
            </q-card-actions>
          </q-card>
        </q-dialog>
      </div>
    </div>

    <!-- ✅ Tudo do PAI (tabs/form/grid/modais) some quando takeoverFilhoGrid -->

    <div v-show="!takeoverFilhoGrid">
      <!-- ✅ fecha wrapper do PAI -->
    </div>

    <!-- MODAL DO FORM ESPECIAL -->

    <q-dialog
      :key="dlgKey"
      v-model="dlgForm"
      persistent
      maximized
      transition-show="slide-up"
      transition-hide="slide-down"
      content-class="dlg-form-branco"
    >
      <q-card class="dlg-form-card dlg-form-premium">
        <q-card-section
          class="dlg-form-card__hero row items-center justify-between no-wrap q-gutter-md"
        >
          <div
            class="row items-center no-wrap q-gutter-md dlg-form-card__hero-main"
          >
            <div class="col-auto">
              <div class="dlg-form-card__hero-icon">
                <q-icon name="tune" size="48px" color="white" />
              </div>
            </div>
            <div class="col">
              <div class="dlg-form-card__eyebrow">
                {{ modulo }}
              </div>
              <div class="dlg-form-card__title">
                {{ tituloMenu || title }} —
                {{
                  formMode === "E"
                    ? "Excluir registro"
                    : formSomenteLeitura
                    ? "Consulta de registro"
                    : formMode === "I"
                    ? "Novo registro"
                    : "Editar registro"
                }}
              </div>
            </div>
          </div>
          <div class="col-auto">
            <q-btn
              icon="close"
              flat
              round
              dense
              class="dlg-form-card__close"
              @click="fecharForm()"
            />
          </div>
        </q-card-section>

        <q-separator class="dlg-form-card__divider" />

        <q-card-section class="dlg-form-card__body">
          <!-- área para renderizador dinâmico (form_especial.js) -->
          <div ref="formEspecialMount"></div>

          <!-- fallback simples se nada for renderizado dinamicamente -->

          <!-- fallback simples se nada for renderizado dinamicamente -->
          <div v-if="!formRenderizou" class="q-mt-md">
            <!-- Abas do formulário (Tabsheets) -->

            <div v-if="tabsheetsForm.length" class="q-mb-md">
              <q-tabs
                v-model="activeTabsheet"
                dense
                align="center"
                class="tabsheets-form"
                active-color="white"
                indicator-color="cyan-6"
              >
                <q-tab
                  v-for="(t, idx) in tabsheetsForm"
                  :key="`tab_${t.key || 'x'}_${idx}`"
                  :name="t.key || `t_${idx}`"
                  :label="t.label"
                  class="tabsheets-form__tab"
                />
              </q-tabs>
            </div>

            <!-- CAMPOS DA ABA ATIVA :key="`${attr.nm_atributo || 'attr'}_${idx}`" -->

            <div class="row q-col-gutter-md">
              <div
                v-for="(attr, idx) in camposFormAtivos"
                :key="attr.cd_atributo || attr.nm_atributo || idx"
                class="col-12 col-sm-6"
              >
                <!-- 3A.2 — LOOKUP com pesquisa dinâmica (cd_menu_pesquisa > 0) -->
                <!-- 3A.2 — LOOKUP com pesquisa dinâmica (cd_menu_pesquisa > 0) -->

                <div v-if="temPesquisaDinamica(attr)">
                  <div class="row q-col-gutter-md items-center no-wrap">
                    <!-- DESCRIÇÃO (grande) + lupa -->

                    <div class="col-grow lookup-desc">
                      <q-input
                        :value="descricaoLookup(attr)"
                        :label="labelCampo(attr)"
                        filled
                        stack-label
                        readonly
                        class="campo-azul"
                      >
                        <template v-slot:append>
                          <q-btn
                            icon="search"
                            flat
                            round
                            dense
                            color="deep-purple-7"
                            :disable="isReadonly(attr)"
                            @click="abrirPesquisa(attr)"
                            :title="
                              `Pesquisar ${attr.nm_edit_label ||
                                attr.nm_atributo_consulta}`
                            "
                          />
                        </template>
                      </q-input>
                    </div>

                    <!-- CÓDIGO (pequeno) -->
                    <div class="col-auto lookup-cod">
                      <q-input
                        v-model="
                          formData[attr.cd_chave_retorno || attr.nm_atributo]
                        "
                        :label="`Código ${labelCampo(attr)}`"
                        filled
                        clearable
                        stack-label
                        :readonly="isReadonly(attr)"
                        :input-class="inputClass(attr)"
                        @blur="validarCampoDinamico(attr)"
                        class="campo-azul"
                      />
                    </div>
                  </div>
                </div>

                <!-- fim -->

                <!-- 3B.2 — LOOKUP direto (nm_lookup_tabela) -->
                <div v-else-if="temLookupDireto(attr)">
                  <div class="row q-col-gutter-md items-center no-wrap">
                    <!-- DESCRIÇÃO (grande) -->

                    <div class="col-grow lookup-desc">
                      <q-select
                        v-model="formData[attr.nm_atributo]"
                        :label="labelCampo(attr)"
                        :options="lookupOptions[attr.nm_atributo] || []"
                        option-label="__label"
                        option-value="__value"
                        emit-value
                        map-options
                        filled
                        clearable
                        stack-label
                        :readonly="isReadonly(attr)"
                        :input-class="inputClass(attr)"
                        :class="
                          isReadonly(attr) ? 'leitura-azul' : 'campo-azul'
                        "
                      />
                    </div>

                    <!-- CÓDIGO (pequeno) -->
                    <div class="col-auto lookup-cod">
                      <q-input
                        :value="formData[attr.nm_atributo]"
                        :label="`Código ${labelCampo(attr)}`"
                        filled
                        stack-label
                        readonly
                        :class="
                          isReadonly(attr) ? 'leitura-azul' : 'campo-azul'
                        "
                      />
                    </div>
                  </div>
                </div>

                <!-- fim -->

                <!-- 2.2 — Lista de valores (Lista_Valor) -->

                <q-select
                  v-else-if="temListaValor(attr)"
                  v-model="formData[attr.nm_atributo]"
                  :label="labelCampo(attr)"
                  :options="listaValores(attr)"
                  option-label="nm_lista_valor"
                  option-value="cd_lista_valor"
                  emit-value
                  map-options
                  filled
                  clearable
                  :dense="false"
                  stack-label
                  :readonly="isReadonly(attr)"
                  :input-class="inputClass(attr)"
                  :hide-hint="false"
                />

                <!-- 3.0 — CAMPO DE ARQUIVO / ANEXO (ic_doc_caminho_atributo = 'S') -->

                <div v-else-if="isCampoArquivo(attr)">
                  <q-input
                    v-model="formData[attr.nm_atributo]"
                    :label="labelCampo(attr)"
                    filled
                    stack-label
                    :readonly="true"
                    :input-class="'leitura-azul'"
                  >
                    <template v-slot:append>
                      <!-- Botão para escolher arquivo (clip) -->
                      <q-btn
                        round
                        dense
                        flat
                        icon="attach_file"
                        :loading="uploadingArquivo"
                        @click="abrirSeletorArquivo(attr)"
                        :title="`Anexar arquivo para ${labelCampo(attr)}`"
                      />

                      <!-- Botão para abrir/download do arquivo existente -->

                      <q-btn
                        v-if="formData[attr.nm_atributo]"
                        round
                        dense
                        flat
                        icon="cloud_download"
                        color="primary"
                        @click="abrirArquivoAnexo(attr)"
                        :title="`Abrir anexo de ${labelCampo(attr)}`"
                      />
                    </template>
                  </q-input>

                  <!-- input file escondido para upload -->
                  <input
                    type="file"
                    :ref="`file_${attr.nm_atributo}`"
                    style="display:none"
                    @change="ev => onFileSelected(attr, ev)"
                  />
                </div>

                <!-- 1.2 — INPUT padrão com regra azul/readonly e '*' em numeração automática -->

                <q-input
                  v-else-if="
                    !temPesquisaDinamica(attr) &&
                      !temLookupDireto(attr) &&
                      !temListaValor(attr) &&
                      !isCampoArquivo(attr)
                  "
                  v-model="formData[attr.nm_atributo]"
                  :type="inputType(attr)"
                  :label="labelCampo(attr)"
                  filled
                  clearable
                  :dense="false"
                  stack-label
                  :readonly="isReadonly(attr)"
                  :input-class="inputClass(attr)"
                >
                  <template v-if="isDateField(attr)" v-slot:prepend>
                    <q-icon name="event" />
                  </template>

                  <template v-if="temRelatorioAtributo(attr)" v-slot:append>
                    <q-btn
                      icon="description"
                      flat
                      round
                      dense
                      color="deep-purple-7"
                      :disable="isReadonly(attr)"
                      @click="onRelatorioDoCampo(attr)"
                      :title="`Relatório de ${labelCampo(attr)}`"
                  /></template>
                </q-input>
              </div>
            </div>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right" class="dlg-form-card__actions">
          <!-- Cancelar -->
          <q-btn
            rounded
            class="q-mt-sm q-ml-sm"
            flat
            color="black"
            label="Cancelar"
            @click="fecharForm()"
          />
          <!-- EXCLUIR -->
          <q-btn
            v-if="formMode === 'E'"
            rounded
            unelevated
            color="deep-orange-9"
            class="q-mt-sm q-ml-sm"
            :loading="salvando"
            label="Excluir"
            @click="confirmarExclusao"
          />
          <!-- SALVAR / ATUALIZAR -->
          <q-btn
            v-if="!formSomenteLeitura && formMode !== 'E'"
            rounded
            color="deep-orange-9"
            class="q-mt-sm q-ml-sm"
            unelevated
            :loading="salvando"
            :label="formMode === 'I' ? 'Salvar' : 'Atualizar'"
            @click="salvarCRUD({ modo: formMode, registro: formData })"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Diálogo do Relatório PDF -->

    <q-dialog v-model="showRelatorio" maximized content-class="dlg-form-branco">
      <q-card style="min-height: 90vh">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Relatório</div>
          <q-space />
          <q-btn dense flat icon="close" @click="showRelatorio = false" />
        </q-card-section>

        <q-separator />

        <q-card-section>
          <!-- Passe props se já tiver os dados/meta no form -->
          <Relatorio
            v-if="showRelatorio"
            :columns="gridColumns"
            :rows="this.rows"
            :summary="totalColumns"
            :titulo="this.tituloMenu"
            :menu-codigo="this.cd_menu"
            :usuario-nome-ou-id="this.nm_usuario"
            :logoSrc="this.logo"
            :empresaNome="this.Empresa"
            :totais="totalColumns"
            @pdf="exportarPDF()"
            @excel="exportarExcel()"
          />
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- FIM do TOPO -->

    <!-- Modal Diálogo – Processos do Menu -->

    <q-dialog
      v-model="dlgMenuProcessos"
      persistent
      maximized
      content-class="dlg-form-branco"
    >
      <q-card class="dlg-form-card">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Processos - {{ tituloMenu || title }}</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-separator />

        <q-card-section>
          <div v-if="menuProcessoLoading" class="q-pa-md">
            <q-spinner size="md" color="deep-orange-9" />
            <span class="q-ml-sm">Carregando processos...</span>
          </div>

          <div v-else>
            <dx-data-grid
              class="dx-card wide-card"
              :data-source="menuProcessoRows"
              :columns="columnsProcessos"
              :column-auto-width="true"
              :row-alternation-enabled="true"
              :show-borders="false"
              :hover-state-enabled="true"
              :selection="{ mode: 'single' }"
              height="60vh"
              :key-expr="'id'"
            >
              <DxSearchPanel
                :visible="true"
                :width="320"
                placeholder="Procurar..."
              />

              <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
              <DxGrouping :auto-expand-all="true" />
              <DxPaging :page-size="50" />
              <DxPager
                :show-page-size-selector="true"
                :allowed-page-sizes="[10, 20, 50, 100]"
                :show-info="true"
              />
              <DxFilterRow :visible="false" />
              <DxHeaderFilter :visible="true" :allow-search="true" />

              <DxColumnChooser :enabled="false" />
            </dx-data-grid>
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- DIALOG DO MAPA DE ATRIBUTOS -->

    <q-dialog
      v-model="dlgMapaAtributos"
      maximized
      content-class="dlg-form-branco"
    >
      <q-card style="min-width: 760px; max-width: 96vw">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">
            Mapa de Atributos – {{ tituloMenu || title }}
            {{ cd_tabela ? ` (Tabela: ${cd_tabela})` : "" }}
          </div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-separator />

        <q-card-section>
          <dx-data-grid
            class="dx-card wide-card"
            :data-source="mapaRows"
            :column-auto-width="true"
            :row-alternation-enabled="true"
            :show-borders="true"
            height="60vh"
          >
            <DxColumn
              v-for="c in mapaColumns"
              :key="c.dataField"
              :data-field="c.dataField"
              :caption="c.caption"
              :width="c.width"
              :min-width="c.minWidth"
              :alignment="c.alignment"
            />
          </dx-data-grid>
        </q-card-section>
      </q-card>
    </q-dialog>

    <div v-if="dashboardCards && dashboardCards.length" class="kpi-row">
      <div v-for="(k, i) in dashboardCards" :key="`kpi_${i}`" class="kpi">
        <div class="kpi-title">{{ k.titulo }}</div>
        <div class="kpi-value">{{ formatarValorCard(k.valor, k.formato) }}</div>
        <div class="kpi-sub">{{ k.subtitulo }}</div>
      </div>
    </div>

    <!-- FILTROS (mesma ideia do Form Especial) -->

    <section class="hpanel pane filtros">
      <!-- seus filtros aqui -->

      <!-- FILTROS (mesma ideia do Form Especial) -->

      <q-expansion-item
        v-if="temSessao && filtros && filtros.length"
        icon="filter_list"
        label="Seleção de Filtros"
        expand-separator
        header-class="text-weight-bold"
      >
        <slot name="filtros-bloco">
          <form
            class="dx-card wide-card"
            action="#"
            @submit.prevent="handleSubmit && handleSubmit($event)"
          >
            <div class="row q-col-gutter-md filtros-grid">
              <div
                v-for="(f, idx) in filtros.filter(
                  x => x.ic_visivel_filtro !== 'N'
                )"
                :key="
                  `filtro_${f.nm_campo_chave_lookup ||
                    f.nm_atributo ||
                    'x'}_${idx}`
                "
                class="col-12 col-sm-6 col-md-4 filtro-item"
              >
                <component
                  :is="f.nm_lookup_tabela ? 'q-select' : 'q-input'"
                  v-model="
                    filtrosValores[f.nm_campo_chave_lookup || f.nm_atributo]
                  "
                  :type="inputType(f)"
                  :label="f.nm_edit_label || f.nm_filtro || f.nm_atributo"
                  :options="f._options || []"
                  option-value="value"
                  option-label="label"
                  filled
                  clearable
                  :dense="false"
                  stack-label
                  :disable="f.ic_fixo_filtro === 'S'"
                >
                  <template v-if="!f.nm_lookup_tabela" v-slot:prepend>
                    <q-icon name="tune" />
                  </template>
                </component>
              </div>
            </div>
            <div class="row filtros-actions">
              <q-btn
                class="q-mt-sm q-ml-sm"
                color="deep-orange-9"
                rounded
                label="Pesquisar"
                @click="consultar && consultar()"
              />
            </div>
          </form>
        </slot>
      </q-expansion-item>
    </section>

    <!-- TABS (NOVO)  —  SIMPLIFICADO -->
    <!-- 1) Cabeçalho de abas só quando houver tabs -->

    <div v-if="tabsDetalhe.length">
      <q-tabs
        v-model="abaAtiva"
        dense
        align="left"
        class="q-mb-sm text-deep-orange-9"
        active-color="deep-orange-9"
        indicator-color="deep-orange-9"
        narrow-indicator
        color="deep-purple-7"
      >
        <q-tab name="principal" label="DADOS" />
        <q-tab
          v-for="(t, idx) in tabsDetalhe"
          :key="`panel_${t.key || 'x'}_${idx}`"
          :name="t.key || `p_${idx}`"
          :label="t.label"
          :disable="t.disabled"
        />
      </q-tabs>
    </div>

    <!-- 2) PRINCIPAL: fica SEMPRE no DOM.
       - Se existem tabs: mostra só quando abaAtiva === 'principal'
       - Se NÃO existem tabs: mostra sempre (porque tabsDetalhe.length == 0) -->

    <section v-show="!tabsDetalhe.length || abaAtiva === 'principal'">
      <!-- ======================= -->
      <!-- TABSHEETS DO FORMULARIO -->
      <!-- ======================= -->

      <div v-if="1 === 2 && tabsheets.length" class="q-mb-md">
        <q-tabs
          v-model="activeTabsheet"
          dense
          align="left"
          class="text-deep-orange-9"
          active-color="deep-orange-9"
          indicator-color="deep-orange-9"
          narrow-indicator
        >
          <q-tab
            v-for="(t, idx) in tabsheets"
            :key="`tab2_${t.key || 'x'}_${idx}`"
            :name="t.key || `t2_${idx}`"
            :label="t.label"
          />
        </q-tabs>

        <q-separator color="deep-orange-9" />
      </div>

      <!-- FIM DAS TABSHEETS DO FORMULARIO -->

      <!-- GRID DevExtreme (SEU BLOCO ORIGINAL) -->

      <div v-if="false" class="row justify-center q-gutter-xs q-mb-sm q-mt-sm">
        <q-btn
          flat
          round
          dense
          icon="chevron_left"
          color="deep-orange-7"
          aria-label="Rolar grid para a esquerda"
          @click="scrollGridHorizontal(-240)"
        />
        <q-btn
          flat
          round
          dense
          icon="chevron_right"
          color="deep-orange-7"
          aria-label="Rolar grid para a direita"
          @click="scrollGridHorizontal(240)"
        />
        <q-btn
          v-if="true"
          flat
          round
          dense
          icon="settings"
          color="deep-purple-7"
          aria-label="Configurar altura da grid"
        >
          <q-menu anchor="bottom right" self="top right">
            <div class="q-pa-sm" style="min-width: 240px">
              <div style="margin-bottom: 15px" class="text-subtitle2 q-mb-xs">
                Altura da grid
              </div>

              <q-slider
                style="margin-top: 20px"
                v-model="gridAlturaAtual"
                :min="gridAlturaMin"
                :max="gridAlturaMax"
                :step="20"
                color="deep-purple-7"
                label
                label-always
              />
              <div class="row justify-between q-mt-sm q-gutter-xs">
                <q-btn
                  flat
                  dense
                  icon="refresh"
                  label="Padrão"
                  color="grey-8"
                  @click="resetarAlturaGrid"
                />
                <q-btn
                  flat
                  dense
                  icon="aspect_ratio"
                  label="Ajustar à tela"
                  color="deep-purple-7"
                  @click="ajustarAlturaTela"
                />
              </div>
            </div>
          </q-menu>
        </q-btn>
      </div>

      <div class="grid-shell-outer">
        <div class="grid-top-outer">
          <!-- Legenda de Status (acima da grid) -->

          <div
            v-if="legendaAcoesGrid && legendaAcoesGrid.length"
            class="acoes-grid-legenda"
          >
            <span class="acoes-grid-legenda-titulo">Status:</span>

            <span
              v-for="(item, idx) in legendaAcoesGrid"
              :key="idx"
              class="acoes-grid-legenda-item"
            >
              <span
                class="acoes-grid-color-dot"
                :class="'bg-' + item.nm_cor"
              ></span>
              <span class="acoes-grid-legenda-text">
                {{ item.nm_fase_pedido }}
              </span>
            </span>
          </div>

          <!-- Tabs de composição vindas do menu ** 2026 ** -->

          <div v-if="menuTabs.length" class="q-mt-md grid-align">
            <q-tabs
              v-model="activeMenuTab"
              dense
              align="left"
              class="grid-align-x text-deep-orange-9"
              active-color="deep-purple-7"
            >
              <q-tab name="principal" label="Dados" />

              <q-tab
                v-for="t in menuTabs"
                :key="t.key"
                :name="t.key"
                :label="t.label"
                @click="onClickMenuTab(t)"
              />
            </q-tabs>

            <q-separator class="q-mb-md q-mx-lg grid-align-x" />

            <q-tab-panels v-model="activeMenuTab" animated class="grid-align-x">
              <!-- Painel principal: não precisa renderizar nada,
            porque o grid já está em cima -->

              <!-- Painéis dinâmicos -->

              <q-tab-panel
                v-for="t in menuTabs"
                :key="`panel_${t.key}`"
                :name="t.key"
                class="q-pa-none tab_principal"
              >
                <div v-if="embedMode && showContextHeader" class="ctx-card">
                  <div class="ctx-title">
                    {{ titulo_menu_entrada || displayTitle }}
                  </div>

                  <div class="ctx-sub" v-if="registro_pai">
                    <b>{{ keyName || "id" }}:</b>
                    {{ registro_pai[keyName || "id"] }}
                    <span v-if="registro_pai.nome">
                      • <b>Nome:</b> {{ registro_pai.nome }}</span
                    >
                    <span v-if="registro_pai.cd_fornecedor">
                      • <b>Cód. Fornecedor:</b>
                      {{ registro_pai.cd_fornecedor }}</span
                    >
                  </div>

                  <div class="ctx-sub" v-else>
                    Selecione um registro na grid principal.
                  </div>
                </div>

                <div class="area-filhas area-filhas-full">
                  <UnicoFormEspecial
                    :embedMode="true"
                    :hideChrome="true"
                    :hideToolbar="true"
                    uiPreset="lite"
                    v-if="t.cd_menu_composicao > 0"
                    :cd_menu_entrada="t.cd_menu_composicao"
                    :titulo_menu_entrada="t.label"
                    :ic_modal_pesquisa="'N'"
                    :ref="`child_${t.key}`"
                    :modo_inicial="
                      (t.ic_grid_menu || 'S') === 'N' ? 'EDIT' : 'GRID'
                    "
                    @fechar.native.stop=""
                    @voltar="onFecharTabFilha(t)"
                    :cd_acesso_entrada="cd_chave_registro_local"
                    :cd_chave_registro="cd_chave_registro_local"
                    :registro_pai="registroSelecionado"
                    :parent-header="getParentHeader(registroSelecionado)"
                    :closeOnDlgFormClose="false"
                  />
                </div>
              </q-tab-panel>
            </q-tab-panels>
          </div>
        </div>

        <!-- CONTROLE PRINCIPAL -->

        <!-- ======= MODO TREEVIEW ======= -->

        <div
          v-if="
            String(ic_treeview_menu || 'N').toUpperCase() === 'S' &&
              exibirComoTree
          "
          class="q-mt-md"
        >
          <div class="row items-center q-col-gutter-md q-mb-md">
            <div class="col-12 col-md-5" style="margin-left: 25px">
              <q-input
                dense
                outlined
                v-model="filtroTreeTexto"
                placeholder="Buscar no tree..."
                clearable
              />
            </div>

            <div class="col text-grey-6">{{ treeNodes.length }} raiz(es)</div>
          </div>

          <div class="row items-center q-gutter-sm q-mb-sm">
            <q-btn
              rounded
              dense
              unelevated
              color="deep-purple-7"
              icon="unfold_more"
              label="Expandir"
              @click="expandirTudoTree"
              style="margin-left: 20px"
            />
            <q-btn
              rounded
              dense
              flat
              color="deep-orange-6"
              icon="unfold_less"
              label="Recolher"
              @click="recolherTudoTree"
            />
          </div>

          <div
            class="dx-card tree-card"
            style="margin-top: 10px; margin-left: 20px"
          >
            <q-tree
              :nodes="treeNodesFiltrados"
              node-key="id"
              label-key="label"
              children-key="children"
              :expanded.sync="treeExpanded"
              :selected.sync="treeSelected"
              :filter="filtroTreeTexto"
              default-expand-all
              dense
              @update:selected="onTreeSelected"
            >
              <template v-slot:default-header="prop">
                <div class="row items-center no-wrap full-width">
                  <div class="col">
                    <div class="tree-title">
                      {{ prop.node.label }}
                    </div>

                    <div v-if="prop.node.subtitle" class="tree-subtitle">
                      {{ prop.node.subtitle }}
                    </div>
                  </div>

                  <div class="col-auto q-gutter-xs">
                    <!-- botão Selecionar no modo pesquisa -->
                    <q-btn
                      v-if="
                        prop.node.isLeaf &&
                          String(ic_modal_pesquisa || 'N').toUpperCase() === 'S'
                      "
                      rounded
                      dense
                      unelevated
                      color="deep-purple-7"
                      icon="check"
                      label="Selecionar"
                      @click.stop="
                        selecionarERetornar(prop.node._raw || prop.node)
                      "
                    />

                    <!-- botão Abrir em modo normal -->
                    <q-btn
                      v-else-if="prop.node.isLeaf"
                      rounded
                      dense
                      flat
                      color="deep-orange-6"
                      icon="open_in_new"
                      label="Abrir"
                      @click.stop="
                        abrirFormEspecial({
                          modo: 'A',
                          registro: prop.node._raw || prop.node,
                        })
                      "
                    />
                  </div>
                </div>
              </template>
            </q-tree>
          </div>
        </div>

        <!-- ======= MODO CARDS ======= -->

        <div
          v-if="
            String(ic_card_menu || 'N').toUpperCase() === 'S' && exibirComoCards
          "
          class="q-mt-md"
        >
          <div class="row items-center q-col-gutter-md q-mb-md">
            <div class="col-12 col-md-5" style="margin-left: 20px">
              <q-input
                dense
                outlined
                v-model="filtroCardsTexto"
                placeholder="Buscar..."
                clearable
              />
            </div>

            <div class="col text-grey-6">
              {{ cardsFiltrados.length }} registro(s)
            </div>
          </div>

          <div class="cards-wrapper" style="margin-top: 10px">
            <div
              v-for="(r, idx) in cardsFiltrados"
              :key="r && r.id != null ? r.id : idx"
              class="card-unico dx-card cursor-pointer"
              @dblclick="abrirFormEspecial({ modo: 'A', registro: r })"
            >
              <div class="card-unico-body">
                <div class="logo-unico">
                  <span class="logo-letter">
                    {{ (tituloMenu || title || "X").charAt(0) }}
                  </span>
                </div>

                <div class="text-subtitle1 q-mt-sm">
                  {{ cardTitulo(r) }}
                </div>

                <div class="q-mt-sm card-campos">
                  <div
                    v-for="(c, i) in cardCampos(r)"
                    :key="i"
                    class="text-caption text-grey-8"
                  >
                    <strong class="text-grey-9">{{ c.label }}:</strong>
                    <span class="q-ml-xs">{{ c.value }}</span>
                  </div>
                </div>

                <div class="q-mt-md row justify-center q-gutter-sm">
                  <q-btn
                    v-if="
                      String(ic_modal_pesquisa || 'N').toUpperCase() === 'S'
                    "
                    rounded
                    color="deep-purple-7"
                    unelevated
                    icon="check"
                    label="Selecionar"
                    @click.stop="selecionarERetornar(r)"
                  />
                  <q-btn
                    v-else
                    rounded
                    dense
                    color="deep-orange-6"
                    flat
                    icon="edit"
                    label="Abrir"
                    @click.stop="abrirFormEspecial({ modo: 'A', registro: r })"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- GRID PRINCIPAL     @initialized="onGridInitialized" @onSelectionChanged="onSelectionChangedPrincipal"  -->

        <!-- BANNER DO PAI (aparece só na grid filha embed limpa) -->
        <div
          v-if="isEmbeddedClean && showParentHeader && parentHeader"
          class="embed-parent-banner"
        >
          <div class="embed-parent-title">
            {{ titulo_menu_entrada || tituloMenu || "" }}
          </div>
          <div class="embed-parent-sub">{{ parentHeader }}</div>
        </div>

        <div
          v-show="
            activeMenuTab === 'principal' &&
              !(
                String(ic_treeview_menu || 'N').toUpperCase() === 'S' &&
                exibirComoTree
              )
          "
          class="grid-scroll-shell"
        >
          <div class="grid-scroll-track">
            <transition name="slide-fade">
              <div class="grid-body">
                <dx-data-grid
                  class="dx-card wide-card"
                  width="100%"
                  v-if="temSessao && rows.length"
                  id="grid-padrao"
                  ref="grid"
                  :data-source="rows || dataSourceConfig"
                  :columns="columns"
                  :key-expr="keyName || 'id'"
                  :summary="gridSummaryConfig"
                  :show-borders="false"
                  :focused-row-enabled="false"
                  :focused-row-key="null"
                  :focused-row-index="null"
                  :column-auto-width="true"
                  :column-hiding-enabled="false"
                  :column-resizing-mode="'widget'"
                  :remote-operations="false"
                  :row-alternation-enabled="false"
                  :repaint-changes-only="false"
                  :paging="{ enabled: true, pageSize: gridPageSize }"
                  :pager="{
                    visible: true,
                    showInfo: true,
                    showNavigationButtons: true,
                    showPageSizeSelector: true,
                    allowedPageSizes: [10, 20, 50, 100],
                  }"
                  :scrolling="{
                    mode: 'standard',
                    useNative: true,
                    preloadEnabled: true,
                    useNative: true,
                  }"
                  :selection="gridSelectionConfig"
                  @selection-changed="onSelectionChangedGrid"
                  @onSelectionChanged="onSelectionChangedPrincipal"
                  @toolbar-preparing="onToolbarPreparing"
                  @rowClick="onRowClickPrincipal"
                  @option-changed="onOptionChanged"
                  @rowDblClick="
                    e => abrirFormEspecial({ modo: 'A', registro: e.data })
                  "
                  @row-prepared="onRowPreparedPrincipal"
                >
                  <template #acoesGridColorCellTemplate="{ data }">
                    <div class="acoes-grid-color-wrapper">
                      <span
                        v-for="(item, idx) in getAcoesGridCores(
                          data.data.acoesGridColor
                        )"
                        :key="idx"
                        class="acoes-grid-color-dot"
                        :class="'bg-' + item.cor"
                      ></span></div
                  ></template>
                  <DxToolbar :visible="true" />
                  <DxSearchPanel
                    :visible="true"
                    :width="320"
                    placeholder="Procurar..."
                  />
                  <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
                  <DxGrouping :auto-expand-all="true" />
                  <DxPaging :page-size="50" />
                  <DxPager
                    :show-page-size-selector="true"
                    :allowed-page-sizes="[10, 20, 50, 100]"
                    :show-info="true"
                  />
                  <DxFilterRow :visible="false" />
                  <DxHeaderFilter :visible="true" :allow-search="true" />

                  <DxColumnChooser :enabled="true" />
                </dx-data-grid>

                <div v-else-if="ic_pesquisa_banco === 'S'" class="no-records">
                  <div class="no-records__card">
                    <div class="no-records__title">
                      <span class="no-records__icon">!</span>
                      Atenção
                    </div>

                    <p class="no-records__text">
                      Não existem registros na base de dados para os
                      filtros/período selecionados.
                    </p>

                    <p class="no-records__hint">
                      Dica: revise o período, empresa, parâmetros ou demais
                      filtros da consulta.
                    </p>
                  </div>
                </div>
              </div>
            </transition>
          </div>
        </div>

        <!-- seta para descer -->

        <q-btn
          v-if="mostrarSetasGrid"
          round
          dense
          color="deep-orange-9"
          icon="keyboard_arrow_down"
          class="fab-down"
          @click="scrollDown('principal')"
        />
      </div>
    </section>

    <!-- ========================= -->
    <!-- TAB: MAPA DE ATRIBUTOS   -->
    <!-- ========================= -->

    <section v-show="activeTabsheet === 'mapa'">
      <DxDataGrid
        :data-source="mapaRows"
        :column-auto-width="true"
        :row-alternation-enabled="true"
        :show-borders="true"
        class="dx-card wide-card"
      >
        <DxColumn
          v-for="(c, idx) in mapaColumns"
          :key="`col_${c.dataField || c.caption || 'x'}_${idx}`"
          :data-field="c.dataField"
          :caption="c.caption"
          :width="c.width"
          :min-width="c.minWidth"
          :alignment="c.alignment"
        />
      </DxDataGrid>
    </section>

    <!-- FIM DA PRINCIPAL -->

    <!-- 3) PAINÉIS DAS ABAS DE DETALHE: só existem quando tabsDetalhe.length > 0 -->

    <q-tab-panels v-if="tabsDetalhe.length" v-model="abaAtiva" animated>
      <q-tab-panel v-for="t in tabsDetalhe" :key="t.key" :name="t.key">
        <!-- Toolbar do detalhe -->
        <div class="row items-center q-mb-sm">
          <q-input
            dense
            filled
            clearable
            :value="filhos[t.cd_menu] ? filhos[t.cd_menu].filtro : ''"
            placeholder="Pesquisar itens..."
            @input="val => setFiltroFilho(t.cd_menu, val)"
            @keyup.enter="consultarFilho(t)"
            style="max-width: 320px"
          />
          <q-btn
            class="q-ml-sm"
            color="deep-purple-7"
            dense
            rounded
            label="Buscar"
            @click="consultarFilho(t)"
          />
          <q-space />
          <q-btn
            v-if="idPaiDetalhe && false"
            color="primary"
            rounded
            dense
            icon="add"
            label="Novo item"
            @click="abrirFormEspecialFilho({ tab: t, modo: 'I' })"
          />
        </div>

        <!-- Banner com ID + descrição do pai -->

        <div class="q-mb-sm" v-if="paiSelecionadoId !== null">
          <q-banner dense class="bg-grey-2 text-grey-9 q-pa-sm" rounded>
            <div class="row items-center">
              <div class="col-auto">
                <q-badge
                  color="deep-orange-9"
                  text-color="white"
                  class="q-mr-sm"
                >
                  {{ paiSelecionadoId }}
                </q-badge>
              </div>
              <div class="col ellipsis">
                <strong>{{ paiSelecionadoTexto || "—" }}</strong>
              </div>
            </div>
          </q-banner>
        </div>

        <!-- Grid do detalhe -->

        <div class="grid-scroll-shell" :ref="'scrollShellDet_' + t.cd_menu">
          <dx-data-grid
            class="dx-card wide-card"
            :data-source="(filhos[t.cd_menu] && filhos[t.cd_menu].rows) || []"
            :columns="(filhos[t.cd_menu] && filhos[t.cd_menu].columns) || []"
            :key-expr="(filhos[t.cd_menu] && filhos[t.cd_menu].keyExpr) || 'id'"
            :show-borders="true"
            :row-alternation-enabled="true"
            :repaint-changes-only="true"
            @rowDblClick="
              e =>
                abrirFormEspecialFilho({ tab: t, modo: 'A', registro: e.data })
            "
          >
            <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />
            <DxGrouping :auto-expand-all="true" />
            <DxPaging :page-size="50" />
            <DxPager
              :show-page-size-selector="true"
              :allowed-page-sizes="[10, 20, 50, 100]"
              :show-info="true"
            />
            <DxFilterRow :visible="false" />
            <DxHeaderFilter :visible="true" :allow-search="true" />
            <DxSearchPanel
              :visible="true"
              :width="320"
              placeholder="Procurar..."
            />
            <DxColumnChooser :enabled="true" />
          </dx-data-grid>

          <!-- seta para descer -->
          <q-btn
            round
            dense
            color="deep-orange-9"
            icon="keyboard_arrow_down"
            class="fab-down"
            @click="scrollDown('det', t.cd_menu)"
          />
        </div>
      </q-tab-panel>
    </q-tab-panels>

    <!-- Setas flutuantes -->
    <div v-if="mostrarSetasGrid" class="arrow-btn left" @click="scrollGrid(-1)">
      <q-btn round color="orange" icon="chevron_left" />
    </div>

    <div v-if="mostrarSetasGrid" class="arrow-btn right" @click="scrollGrid(1)">
      <q-btn round color="orange" icon="chevron_right" />
    </div>

    <q-dialog
      v-model="showLookup"
      persistent
      maximized
      content-class="dlg-form-branco"
    >
      <q-card style="min-width: 95vw; min-height: 90vh;">
        <UnicoFormEspecial
          :cd_menu_entrada="
            campoLookupAtivo && campoLookupAtivo.cd_menu_pesquisa
              ? Number(campoLookupAtivo.cd_menu_pesquisa)
              : 0
          "
          :cd_menu_modal_entrada="
            cdMenuAnteriorLookup ? Number(cdMenuAnteriorLookup) : 0
          "
          :titulo_menu_entrada="tituloLookup"
          :cd_acesso_entrada="0"
          ic_modal_pesquisa="S"
          @selecionou="onSelecionouLookup"
          @fechar="fecharLookup"
        />
      </q-card>
    </q-dialog>

    <filtro-componente
      v-model="dialogFiltroSelecao"
      :cd-menu="Number(cd_menu || cdMenu || 0)"
      :cd-tabela="Number(this.cd_tabela || 0)"
      :cd-usuario="Number(cd_usuario || 0)"
      @aplicou="onAplicouFiltroSelecao"
    />

    <!-- Modal de aviso de configuração (tabela/procedure) -->

    <q-dialog
      v-model="showAvisoConfig"
      persistent
      content-class="dlg-form-branco"
    >
      <q-card style="min-width: 520px; max-width: 90vw;">
        <q-card-section class="row items-center q-gutter-md">
          <q-icon name="warning" size="48px" color="orange-8" />
          <div class="col">
            <div class="text-h6">Atenção</div>
            <div class="text-body1 q-mt-xs">
              Atenção para este Menu ({{ cd_menu || cd_menu_entrada || "?" }}) -
              {{ tituloMenu || titulo_menu_entrada || "" }}, falta a
              configuração da <b>Tabela</b> ou do
              <b>procedimento de consulta</b>.
            </div>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right">
          <q-btn
            flat
            label="Fechar"
            color="primary"
            v-close-popup
            @click="showAvisoConfig = false"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="drawerFiltros" position="right">
      <q-card style="width: 420px; max-width: 90vw;">
        <q-card-section class="row items-center">
          <div class="text-subtitle1 text-weight-bold">Filtros</div>
          <q-space />
          <q-btn flat round dense icon="close" @click="drawerFiltros = false" />
        </q-card-section>

        <q-separator />

        <q-card-section class="q-pa-md">
          <!-- seu form de filtros (igual, sem mudar nada) -->
          <form
            class="dx-card wide-card"
            action="#"
            @submit.prevent="handleSubmit && handleSubmit($event)"
          >
            <div class="row q-col-gutter-md filtros-grid">
              <div
                v-for="(f, idx) in filtros.filter(
                  x => x.ic_visivel_filtro !== 'N'
                )"
                :key="
                  `filtro_${f.nm_campo_chave_lookup ||
                    f.nm_atributo ||
                    'x'}_${idx}`
                "
                class="col-12 filtro-item"
              >
                <component
                  :is="f.nm_lookup_tabela ? 'q-select' : 'q-input'"
                  v-model="
                    filtrosValores[f.nm_campo_chave_lookup || f.nm_atributo]
                  "
                  :type="inputType(f)"
                  :label="f.nm_edit_label || f.nm_filtro || f.nm_atributo"
                  :options="f._options || []"
                  option-value="value"
                  option-label="label"
                  filled
                  clearable
                  stack-label
                  :disable="f.ic_fixo_filtro === 'S'"
                >
                  <template v-if="!f.nm_lookup_tabela" v-slot:prepend>
                    <q-icon name="tune" />
                  </template>
                </component>
              </div>
            </div>

            <div class="row q-mt-md q-gutter-sm justify-end">
              <q-btn
                color="deep-orange-9"
                rounded
                icon="search"
                label="Aplicar"
                @click="
                  consultar && consultar();
                  drawerFiltros = false;
                "
              />
            </div>
          </form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import axios from "axios";
import DashboardDinamico from "@/components/dashboardDinamico.vue"; // ajuste o caminho
import ModalComposicao from "@/components/ModalComposicao.vue";
import ModalGridComposicao from "@/components/ModalGridComposicao.vue";
import filtroComponente from "@/components/filtroComponente.vue";

//import { locale } from 'devextreme/localization';

import {
  payloadTabela,
  getColumnsForMenu,
  getRowsFromPesquisa,
  getRowsExecPorMenu,
  getPayloadTabela,
  salvarDadosForm,
  lookup,
  execProcedure,
  getInfoDoMenu,
} from "@/services";

import {
  exportarParaExcel,
  importarExcelParaTabela,
  gerarPdfRelatorio,
  getCatalogoRelatorio,
  gerarRelatorioPadrao,
} from "@/services";

//import axios from "boot/axios";

import Relatorio from "@/components/Relatorio.vue";
import Localbase from "localbase";

//import api from '@/boot/axios'
const banco = localStorage.nm_banco_empresa;
//

const offlineDb = new Localbase("egis-offline-cache");
const GRID_CACHE_COLLECTION = "gridSnapshots";
const GRID_CACHE_PREFIX = "unicoFormEspecial";

const api = axios.create({
  baseURL: "https://egiserp.com.br/api",
  withCredentials: true, // ⬅️ mantém cookies da sessão
  timeout: 60000,
  headers: { "Content-Type": "application/json", "x-banco": banco },

  // headers: { 'Content-Type': 'application/json', 'x-banco': banco }
}); // cai no proxy acima

// injeta headers a cada request (x-banco + bearer fixo)
api.interceptors.request.use(cfg => {
  const banco = localStorage.nm_banco_empresa || "";
  if (banco) cfg.headers["x-banco"] = banco;
  cfg.headers["Authorization"] = "Bearer superchave123";
  if (!cfg.headers["Content-Type"])
    cfg.headers["Content-Type"] = "application/json";
  // DEBUG: veja a URL real que está indo
  console.log(
    "[REQ]",
    banco,
    cfg.method?.toUpperCase(),
    (cfg.baseURL || "") + cfg.url
  );
  return cfg;
});

//
/*
// Exemplo de chamada para a procedure
async function executarProcedure(payload) {
  try {
    const { data } = await api.post('/exec/pr_mapa_carteira_cliente_aberto', payload);
    console.log('Retorno da procedure:', data);
  } catch (err) {
    console.error('Erro completo:', err);
    if (err.response) {
      console.error('Status:', err.response.status);
      console.error('Data:', err.response.data);
    }
  }
}
*/

//
//console.log('banco de dados:', banco);
//

// ---------- Normalização genérica p/ filtros dinâmicos ----------

const isEmptyLike = v =>
  v === undefined || v === null || v === "" || v === "null" || v === "NULL";

const looksLikeDate = s =>
  typeof s === "string" &&
  (/^\d{2}[/-]\d{2}[/-]\d{4}$/.test(s) || /^\d{4}-\d{2}-\d{2}$/.test(s));

function toIsoDate(s, preferDayFirst = true) {
  if (s == null || s === "") return null;

  // 1) Date object
  if (s instanceof Date && !isNaN(s)) {
    const y = s.getFullYear();
    const m = String(s.getMonth() + 1).padStart(2, "0");
    const d = String(s.getDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
  }

  // 2) Força string
  if (typeof s !== "string") s = String(s);
  s = s.trim();

  // 3) yyyy-mm-dd (date-only) → ok
  if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;

  // 4) ISO com hora → corta para date-only
  const isoMatch = /^(\d{4}-\d{2}-\d{2})T/i.exec(s);
  if (isoMatch) return isoMatch[1];

  // 5) dd/mm/yyyy ou mm/dd/yyyy (aceita 1-2 dígitos)
  const m = /^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$/.exec(s);
  if (m) {
    let [, a, b, yyyy] = m;
    a = a.padStart(2, "0");
    b = b.padStart(2, "0");

    let dd, mm;
    if (preferDayFirst) {
      // Heurística: se b > 12, então b é dia → troca
      if (+b > 12 && +a <= 12) {
        dd = b;
        mm = a;
      } else {
        dd = a;
        mm = b;
      }
    } else {
      if (+a > 12 && +b <= 12) {
        mm = b;
        dd = a;
      } else {
        mm = a;
        dd = b;
      }
    }

    if (isValidYMD(yyyy, mm, dd)) return `${yyyy}-${mm}-${dd}`;
    return null;
  }

  // 6) Último recurso: tentar Date (local) e extrair date-only (evita “-1 dia”)
  const d = new Date(s);
  if (!isNaN(d)) {
    const y = d.getFullYear();
    const m2 = String(d.getMonth() + 1).padStart(2, "0");
    const d2 = String(d.getDate()).padStart(2, "0");
    return `${y}-${m2}-${d2}`;
  }

  // 7) Não parece data → mantém sua semântica original (retorna s) ou troque por null
  // return null;
  return s;

  function isValidYMD(yyyy, mm, dd) {
    const y = +yyyy,
      m = +mm,
      d = +dd;
    if (!y || m < 1 || m > 12 || d < 1 || d > 31) return false;
    const test = new Date(y, m - 1, d);
    return (
      test.getFullYear() === y &&
      test.getMonth() + 1 === m &&
      test.getDate() === d
    );
  }
}

const toSN = v => {
  if (v === true || v === 1 || v === "1" || `${v}`.toUpperCase() === "S")
    return "S";
  if (v === false || v === 0 || v === "0" || `${v}`.toUpperCase() === "N")
    return "N";
  return null; // deixa o back decidir quando não informado
};

const shouldBeNumberByKey = k =>
  /^cd_/.test(k) || /_id$/.test(k) || /^qtd/.test(k) || /^vl_/.test(k);

function normalizeValue(key, val) {
  if (isEmptyLike(val)) return null;

  // arrays/objetos: normaliza recursivo
  if (Array.isArray(val)) return val.map(x => normalizeValue(key, x));
  if (val && typeof val === "object") return normalizePayload(val);

  // booleans/flags
  if (key.startsWith("ic_") || key.startsWith("fl_")) {
    const v = toSN(val);
    return v === null ? null : v;
  }

  // datas (chaves dt_* ou strings parecendo data)
  if (key.startsWith("dt_") || looksLikeDate(val)) {
    return toIsoDate(val, /*preferDayFirst=*/ true); // dd/mm/yyyy -> yyyy-mm-dd
  }

  // números por heurística do nome
  if (shouldBeNumberByKey(key)) {
    const s = String(val).trim();
    const isNumeric = /^-?\d+([.,]\d+)?$/.test(s);
    if (!isNumeric) return val;

    const n = Number(s.replace(",", "."));
    return Number.isFinite(n) ? n : null;
  }

  return val; // mantém o resto como está
}

function normalizeKey(s) {
  return String(s || "")
    .replace(/\u00A0/g, " ")
    .trim(); // remove NBSP
}

function normalizePayload(obj) {
  if (!obj || typeof obj !== "object") return obj;
  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    out[k] = normalizeValue(k, v);
  }
  return out;
}

// normaliza um array de linhas com base num “meta” (tipos vindos do payload)

function normalizarTipos(dados, camposMeta) {
  if (!Array.isArray(dados)) return dados;

  const mapa = {};

  (camposMeta || []).forEach(c => {
    const key = c.nm_atributo_consulta || c.nm_atributo;

    // determinar tipo
    const tipo = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    mapa[key] = tipo;
    //
  });

  return dados.map(reg => {
    const out = { ...reg };
    for (const [key, tipo] of Object.entries(mapa)) {
      const v = out[key];
      if (v == null || v === "") continue;
      if (
        [
          "currency",
          "number",
          "fixedpoint",
          "decimal",
          "float",
          "percent",
        ].includes(tipo)
      ) {
        const num = Number(
          String(v)
            .replace(/\./g, "")
            .replace(",", ".")
        );
        if (!Number.isNaN(num)) out[key] = num;
      } else if (["date", "shortdate", "datetime"].includes(tipo)) {
        const d = new Date(v);
        if (!isNaN(d.getTime())) out[key] = d; // vira Date real
      }
    }
    return out;
  });
}

// ==== BUILDERS DE COLUNAS E TOTAIS ====

function parseToUtcDate(v, preferDayFirst = true) {
  if (!v) return null;

  // já é Date
  if (v instanceof Date && !isNaN(v)) {
    // normaliza para UTC-only (sem hora local)
    return new Date(Date.UTC(v.getFullYear(), v.getMonth(), v.getDate()));
  }

  // força string
  if (typeof v !== "string") v = String(v);
  v = v.trim();

  // 'YYYY-MM-DD' (NÃO usar new Date('YYYY-MM-DD') porque é UTC 00:00Z -> pode "voltar 1 dia" na exibição local)
  let m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(v);
  if (m) {
    const y = +m[1],
      mm = +m[2],
      dd = +m[3];
    return new Date(Date.UTC(y, mm - 1, dd));
  }

  // ISO com hora -> Date comum já interpreta corretamente
  if (/^\d{4}-\d{2}-\d{2}T/.test(v)) {
    const d = new Date(v);
    if (!isNaN(d)) {
      // zera hora em UTC para ficar só a data
      return new Date(
        Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate())
      );
    }
  }

  // DD/MM/YYYY ou MM/DD/YYYY (aceita 1-2 dígitos)
  m = /^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$/.exec(v);
  if (m) {
    let a = +m[1],
      b = +m[2],
      y = +m[3];
    let dd, mm;
    if (preferDayFirst) {
      // heurística para ambíguo: se b>12, b é dia
      if (b > 12 && a <= 12) {
        dd = b;
        mm = a;
      } else {
        dd = a;
        mm = b;
      }
    } else {
      if (a > 12 && b <= 12) {
        mm = b;
        dd = a;
      } else {
        mm = a;
        dd = b;
      }
    }
    const test = new Date(Date.UTC(y, mm - 1, dd));
    // validação simples (rola e confere)
    if (
      test.getUTCFullYear() === y &&
      test.getUTCMonth() + 1 === mm &&
      test.getUTCDate() === dd
    ) {
      return test;
    }
    return null;
  }

  // Último recurso: tentar Date e normalizar para UTC-date-only
  const d = new Date(v);
  if (!isNaN(d)) {
    return new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
  }

  return null;
}

function buildOptionsFromRows(rows) {
  if (!Array.isArray(rows) || rows.length === 0) return [];

  const keys = Object.keys(rows[0]); // ex: ['cd_estado', 'Estado']

  const keyValue = keys[0]; // 1ª coluna → value
  const keyLabel = keys[1] || keys[0]; // 2ª coluna (se existir) → label

  return rows.map(r => ({
    value: r[keyValue],
    label: r[keyLabel],
  }));
}

function makeSafeFieldName(label, fallback, idx) {
  const base = normalizeKey(label || fallback || `col_${idx}`);
  // troca tudo que não é letra/numero/_ por _
  let safe = base.normalize("NFD").replace(/[\u0300-\u036f]/g, ""); // remove acentos
  safe = safe.replace(/[^A-Za-z0-9_]/g, "_");
  safe = safe.replace(/_+/g, "_").replace(/^_+|_+$/g, "");
  if (!safe) safe = `col_${idx}`;
  // garante que não começa com número
  if (/^\d/.test(safe)) safe = `c_${safe}`;
  // garante unicidade básica
  return `${safe}__${idx}`;
}

function buildColumnsFromMeta(camposMeta = []) {
  return (camposMeta || []).map((c, idx) => {
    const keyOriginal = normalizeKey(c.nm_atributo_consulta || c.nm_atributo); // ✅ chave real na row
    const caption = normalizeKey(
      c.nm_atributo_consulta || c.nm_edit_label || keyOriginal
    );

    // dataField seguro (alias) para não quebrar com ponto/espaço
    const dataField = makeSafeFieldName(caption, c.nm_atributo, idx);

    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();

    const align = [
      "currency",
      "percent",
      "fixedpoint",
      "number",
      "decimal",
      "float",
    ].includes(tipoFmt)
      ? "right"
      : "left";

    const col = {
      dataField,
      caption,
      visible: c.ic_visivel !== "N",
      width: c.largura || undefined,
      alignment: align,
      allowFiltering: true,
      allowSorting: true,

      // ✅ aqui está o pulo do gato:
      calculateCellValue: rowData => rowData?.[keyOriginal],
    };

    // seus campos especiais (mas agora pelo ORIGINAL também)
    if (
      keyOriginal === "linhaGridColor" ||
      keyOriginal === "acoesGridColor" ||
      keyOriginal === "fasePedido"
    ) {
      col.visible = false;
    }

    // Datas
    const tecnico = String(c.nm_atributo || "");
    if (
      ["date", "shortdate", "datetime"].includes(tipoFmt) ||
      tecnico.startsWith("dt_")
    ) {
      col.dataType = "date";

      col.calculateCellValue = rowData => {
        const v = rowData?.[keyOriginal];
        return parseToUtcDate(v);
      };

      col.customizeText = e => {
        if (!e.value) return "";
        return new Intl.DateTimeFormat("pt-BR", { timeZone: "UTC" }).format(
          e.value
        );
      };

      col.calculateSortValue = rowData => {
        const d = parseToUtcDate(rowData?.[keyOriginal]);
        return d ? d.getTime() : -Infinity;
      };

      col.filterOperations = ["=", ">", "<", "<=", ">=", "between"];
    }

    // Moeda
    if (
      tipoFmt === "currency" ||
      tecnico.startsWith("vl_") ||
      keyOriginal.startsWith("vl_")
    ) {
      col.customizeText = e =>
        e.value == null || e.value === ""
          ? ""
          : Number(e.value).toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            });

      col.cellTemplate = (container, options) => {
        const val = options.value;
        const span = document.createElement("span");
        if (typeof val === "number" && val < 0) span.style.color = "#c62828";
        span.textContent =
          val == null || val === ""
            ? ""
            : Number(val).toLocaleString("pt-BR", {
                style: "currency",
                currency: "BRL",
              });
        container.append(span);
      };
    }

    // Percentual
    if (tipoFmt === "percent") {
      col.customizeText = e =>
        e.value == null || e.value === ""
          ? ""
          : `${(Number(e.value) * 100).toFixed(2)}%`;
    }

    // Números simples
    if (["fixedpoint", "decimal", "float"].includes(tipoFmt)) {
      col.format = { type: "fixedPoint", precision: 2 };
    }

    if (tipoFmt === "number") {
      col.customizeText = e => {
        if (e.value == null || e.value === "") return "";
        const n = Number(e.value);
        if (Number.isNaN(n)) return String(e.value);
        return n.toLocaleString("pt-BR", {
          maximumFractionDigits: 0,
          minimumFractionDigits: 0,
        });
      };

      // opcional: garante ordenação numérica
      col.calculateSortValue = rowData => {
        const v = rowData?.[keyOriginal];
        const n = Number(v);
        return Number.isNaN(n) ? -Infinity : n;
      };
    }

    return col;
  });
}

//Colunas de grid a partir do meta

function buildColumnsFromMetaold(camposMeta = []) {
  return (camposMeta || []).map(c => {
    //const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const dataField = normalizeKey(c.nm_atributo_consulta); // ✅ SEMPRE técnico
    const caption = c.nm_atributo_consulta || c.nm_edit_label || dataField;
    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    const align = [
      "currency",
      "percent",
      "fixedpoint",
      "number",
      "decimal",
      "float",
    ].includes(tipoFmt)
      ? "right"
      : "left";

    const col = {
      dataField,
      caption,
      visible: c.ic_visivel !== "N",
      width: c.largura || undefined,
      alignment: align,
      allowFiltering: true,
      allowSorting: true,
    };

    if (dataField === "linhaGridColor") {
      col.visible = false;
    }

    if (dataField === "acoesGridColor") {
      col.visible = false;
    }

    if (dataField === "fasePedido") {
      col.visible = false;
    }

    // Datas (exibição dd/MM/yyyy, filtro/sort corretos sem "voltar 1 dia")
    if (
      ["date", "shortdate", "datetime"].includes(tipoFmt) ||
      String(dataField).startsWith("dt_")
    ) {
      col.dataType = "date";

      // 1) Converte diferentes formatos para Date(UTC) de forma segura
      col.calculateCellValue = rowData => {
        const v = rowData?.[dataField];
        return parseToUtcDate(v); // retorna Date ou null
      };

      // 2) Exibe em pt-BR (dd/MM/yyyy), fixando UTC para não deslocar o dia
      col.customizeText = e => {
        if (!e.value) return "";
        return new Intl.DateTimeFormat("pt-BR", { timeZone: "UTC" }).format(
          e.value
        );
      };

      // 3) Ordenação consistente mesmo se algum valor ficar string
      col.calculateSortValue = rowData => {
        const d = parseToUtcDate(rowData?.[dataField]);
        return d ? d.getTime() : -Infinity;
      };

      // 4) (Opcional) formato no filtro de linha/header filter
      col.filterOperations = ["=", ">", "<", "<=", ">=", "between"];
    }

    // Moeda

    if (tipoFmt === "currency" || dataField.startsWith("vl_")) {
      col.customizeText = e =>
        e.value == null || e.value === ""
          ? ""
          : Number(e.value).toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            });

      col.cellTemplate = (container, options) => {
        const val = options.value;
        const span = document.createElement("span");
        if (typeof val === "number" && val < 0) span.style.color = "#c62828";
        span.textContent =
          val == null || val === ""
            ? ""
            : val.toLocaleString("pt-BR", {
                style: "currency",
                currency: "BRL",
              });
        container.append(span);
      };
    }

    // Percentual

    if (tipoFmt === "percent") {
      col.customizeText = e =>
        e.value == null || e.value === ""
          ? ""
          : `${(Number(e.value) * 100).toFixed(2)}%`;
    }

    // Números simples

    if (["fixedpoint", "decimal", "float"].includes(tipoFmt)) {
      col.format = { type: "fixedPoint", precision: 2 };
    }

    if (["number"].includes(tipoFmt)) {
      col.format = {
        formatter: function(value) {
          if (value > 1000) {
            // Força 3 casas decimais no padrão brasileiro
            return value.toLocaleString("pt-BR", {
              minimumFractionDigits: 3,
              maximumFractionDigits: 3,
            });
          }
          // Sem casas decimais
          return value.toLocaleString("pt-BR", {
            minimumFractionDigits: 0,
            maximumFractionDigits: 0,
          });
        },
      };
    }

    return col;
  });
}

function mapRowsByGridMeta(rows = [], meta = []) {
  const metaList = meta || [];

  return (rows || []).map(row => {
    const out = { ...row };

    metaList.forEach(c => {
      const tech = c?.nm_atributo; // ex: CodCliente
      const label = c?.nm_atributo_consulta; // ex: Cód. Cliente
      if (!tech) return;

      // se já existe a chave técnica, beleza
      if (out[tech] !== undefined) return;

      // 1) match direto pelo label
      if (label && out[label] !== undefined) {
        out[tech] = out[label];
        return;
      }

      // 2) match "trimado" (às vezes vem com espaços)
      if (label) {
        const k = Object.keys(out).find(
          kk => kk.trim() === String(label).trim()
        );
        if (k) out[tech] = out[k];
      }
    });

    return out;
  });
}

function buildSummaryFromMeta(camposMeta = []) {
  const totalizaveis = (camposMeta || []).filter(
    c => c.ic_total_grid === "S" || c.ic_contador_grid === "S"
  );

  const totalItems = totalizaveis.map(c => {
    const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    const isSum = c.ic_total_grid === "S";
    return {
      column: dataField,
      summaryType: isSum ? "sum" : "count",
      alignByColumn: true,
      displayFormat: isSum ? "Total: {0}" : "{0} registro(s)",
      customizeText: e => {
        if (isSum && (tipoFmt === "currency" || dataField.startsWith("vl_"))) {
          return `Total: ${Number(e.value || 0).toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL",
          })}`;
        }
        if (isSum && tipoFmt === "percent") {
          return `Total: ${(Number(e.value || 0) * 100).toFixed(2)}%`;
        }
        return isSum ? `Total: ${e.value}` : `${e.value} registro(s)`;
      },
    };
  });

  const groupItems = totalizaveis.map(c => {
    const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    const isSum = c.ic_total_grid === "S";
    return {
      column: dataField,
      summaryType: isSum ? "sum" : "count",
      showInGroupFooter: true,
      alignByColumn: true,
      displayFormat: isSum ? "Subtotal: {0}" : "{0} registro(s)",
      customizeText: e => {
        if (isSum && (tipoFmt === "currency" || dataField.startsWith("vl_"))) {
          return `Subtotal: ${Number(e.value || 0).toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL",
          })}`;
        }
        if (isSum && tipoFmt === "percent") {
          return `Subtotal: ${(Number(e.value || 0) * 100).toFixed(2)}%`;
        }
        return isSum ? `Subtotal: ${e.value}` : `${e.value} registro(s)`;
      },
    };
  });

  return {
    totalItems,
    groupItems,
    texts: { sum: "Total: {0}", count: "Registro(s): {0}" },
  };
}

// ---------------------------------------------------------------

import saveAs from "file-saver";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import { exportDataGrid } from "devextreme/excel_exporter";
import ExcelJS from "exceljs";
import jsPDF from "jspdf";
import "jspdf-autotable";
import { exportGridToPDF } from "@/utils/pdfExport";

import DxDataGrid, {
  DxColumn,
  DxGrouping,
  DxGroupPanel,
  DxSummary,
  DxTotalItem,
  DxSearchPanel,
  DxHeaderFilter,
  DxFilterRow,
  DxPager,
  DxPaging,
  DxColumnChooser,
} from "devextreme-vue/data-grid";

import { DxTabPanel, DxItem as DxTabItem } from "devextreme-vue/tab-panel";

import { act } from "react";
import { DxButton, DxToolbar } from "devextreme-vue";
import { is } from "core-js/core/object";

//

//
function buscarValor(row, nomes) {
  for (const nome of nomes) {
    if (typeof nome !== "string") continue; // ignora valores inválidos

    const chave = Object.keys(row).find(
      k => k.toLowerCase() === nome.toLowerCase()
    );
    if (chave) return row[chave];
  }
  return undefined;
}

const splitClass = s =>
  norm(s)
    .split(".")
    .filter(Boolean);
const joinClass = arr => arr.join(".");

const groupClassFromChildren = childrenRows => {
  if (!kClass) return "";
  const partsList = childrenRows
    .map(r => splitClass(getVal(r, kClass)))
    .filter(a => a.length > 0);

  if (!partsList.length) return "";

  // prefixo comum
  let pref = partsList[0];
  for (let i = 1; i < partsList.length; i++) {
    const cur = partsList[i];
    let j = 0;
    while (j < pref.length && j < cur.length && pref[j] === cur[j]) j++;
    pref = pref.slice(0, j);
    if (!pref.length) break;
  }

  // no seu cenário, o grupo é o nível acima do filho.
  // Se o prefixo comum já vier no nível do grupo, ótimo.
  // Se vier mais fundo, corta.
  if (pref.length >= 2) return joinClass(pref.slice(0, 2)); // 02.02
  return joinClass(pref);
};

// ---------------------------------------------------------------

export default {
  name: "UnicoFormEspecial",
  props: {
    cd_menu_entrada: Number,
    cd_acesso_entrada: Number, //Chave de acesso (p/ filtros salvos)
    cd_menu_modal_entrada: Number,
    titulo_menu_entrada: { type: String, default: "" },
    ic_modal_pesquisa: {
      // << NOVO
      type: String,
      default: "N",
    },
    modo_inicial: { type: String, default: "GRID" }, // 'GRID' ou 'EDIT'
    embedMode: { type: Boolean, default: false },
    registro_pai: { type: Object, default: null },
    cd_chave_registro: { type: Number, default: 0 },
    overrides: { type: Object, default: () => ({}) },
    hooks: { type: Object, default: () => ({}) },
    services: { type: Object, default: () => ({}) },
    uiPreset: { type: String, default: "full" }, // "full" | "lite"
    hideChrome: { type: Boolean, default: false }, // esconde header/toolbar do próprio componente
    hideToolbar: { type: Boolean, default: false }, // se quiser granularidade
    parentHeader: { type: String, default: "" },
    showParentHeader: { type: Boolean, default: true },
    closeOnDlgFormClose: { type: Boolean, default: true },
  },

  components: {
    Relatorio,
    DxDataGrid,
    DxColumn,
    DxGrouping,
    DxGroupPanel,
    DxSummary,
    DxTotalItem,
    DxSearchPanel,
    DxHeaderFilter,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxColumnChooser,
    DxToolbar,
    DxTabPanel,
    DxTabItem,
    DxButton,
    DashboardDinamico,
    ModalComposicao,
    ModalGridComposicao,
    filtroComponente,
    UnicoFormEspecial: () => import("@/views/unicoFormEspecial.vue"),
  },

  // ===== DADOS =====

  data() {
    return {
      _tabStack: [], // histórico de abas
      _closingInternalDialog: false,
      _tabAntesModal: null,
      _estavaEmTabFilha: false,
      dlgKey: 0,
      dashboardRows: [],
      drawerFiltros: false,
      keyFieldDb: null,
      _rowClickLock: false,
      _dedupRowClick: { key: null, ts: 0 },
      selectedRowKeys: [],
      focusedRowKey: null,
      _gridReady: false,
      _syncSelecionando: false,
      _gridDimTimer: null,
      gridAutoFit: true,
      gridPageSize: 200, // ajuste: 100 / 200 / 500 conforme performance
      gridBodyHeight: 0,
      ic_treeview_menu: "N",
      exibirComoTree: false,
      treeSelected: null,
      treeExpanded: [],
      treeNodes: [],
      // cache do meta do tree (pra não recalcular em todo lugar)
      treeCampoPai: null, // nm_atributo do pai (ic_atributo_pai='S')
      treeCampoFilho: null, // nm_atributo do filho (ic_atributo_filho='S')
      treeCampoLabel: null, // campo texto (heurística)
      treeCampoSub: null, // opcional
      filtroTreeTexto: "",
      ic_card_menu: "N",
      exibirComoCards: false,
      filtroCardsTexto: "",
      showAvisoConfig: false,
      bloquearCarregamentoPorConfig: false,
      takeoverFilhoGrid: false,
      cd_relatorio: 0,
      carregandoContexto: false,
      cd_chave_pesquisa: 0,
      cd_chave_registro_local: Number(this.cd_chave_registro || 0),
      menuTabs: [], // tabs vindas do sqlTabs
      activeMenuTab: "principal", // 'principal' = grid principal
      returnTo: null,
      showClearButton: false, // controla se o botão aparece
      showDashDinamico: false,
      ncd_acesso_entrada:
        this.cd_acesso_entrada || localStorage.cd_chave_pesquisa || 0,
      ncd_menu_entrada: this.cd_menu_entrada || 0,
      mostrarSetasGrid: false, // exibe setas de scroll vertical
      gridAlturaMin: 420,
      gridAlturaMax: 10000,
      gridAlturaPadrao: 720,
      gridAlturaAtual: 720,
      infoDialog: false,
      infoTitulo: "",
      infoTexto: "",
      panelIndex: 0, // 0 = filtros, 1 = grid
      showRelatorio: false,
      relatoriosDisponiveis: [],
      relatorioSelecionado: null,
      title: "",
      qt_registro: 0, // badge (display-data usa isso)
      mostrarAcoes: true,
      rows: [],
      columns: [],
      totalColumns: [],
      gridMeta: [],
      linhaGridColorColEscondida: false,
      // chave primária (detectada)
      keyName: "id",
      keyExprFinal: null,
      isPesquisa: false,
      loading: false,
      filtros: [],
      filtrosValores: this.filtrosValores || {},
      nome_procedure: "*",
      ic_json_parametro: "N",
      temSessao: false,
      searchText: "",
      cd_empresa: localStorage.cd_empresa,
      cd_modulo: localStorage.cd_modulo,
      cd_usuario: localStorage.cd_usuario,
      cd_menu: localStorage.cd_menu,
      nm_usuario: localStorage.usuario,
      logo: localStorage.nm_caminho_logo_empresa,
      cd_cliente: 0,
      cd_parametro_menu: 0,
      dateBoxOptions: {
        invalidDateMessage: "Data tem estar no formato: dd/mm/yyyy",
      },
      total: { totalItems: [] }, // usado por :summary do DataGrid
      totalQuantidade: 0, // usado no cabeçalho/rodapé
      totalValor: 0, // idem
      gridRows: [],
      gridColumns: [],
      gridSummary: null,
      // guarde o “meta” de colunas (vem do payload que define campos)
      camposMetaGrid: [], // ← vamos preencher no passo 3
      // filtros dinâmicos
      empresaAtual: localStorage.nm_banco_empresa || "",
      usuarioAtual:
        (localStorage.cd_usuario ? `${localStorage.cd_usuario} - ` : "") +
        (localStorage.nm_usuario || ""),
      Empresa: localStorage.fantasia || localStorage.empresa || "",
      // logoEmpresa: localStorage.imageUrl || '/img/logo.png',
      tituloMenu: localStorage.nm_menu_titulo || "Relatório de Dados",
      modulo: localStorage.nm_modulo || "",
      pageTitle: localStorage.nm_menu_titulo || this.pageTitle || "",
      cd_tabela: 0,
      dlgForm: false,
      formMode: "I", // 'I' incluir | 'A' alterar
      formData: {}, // dados do formulário
      atributosForm: [], // metadados para montar inputs
      formRenderizou: false,
      salvando: false,

      // meta de atributos recebida do payload/menu-filtro

      metaAtributos: [],
      lookupOptions: {},

      mapaRows: [],
      mapaColumns: [],

      // TABS do formulário (definidas pelo meta)
      tabsheets: [], // [{ key, label, cd_tabsheet, fields:[] }]
      activeTabsheet: "dados",
      // controle das abas principal/detalhes
      tabs: [],
      abaAtiva: "principal", // controla a aba aberta (principal | det_<cd>)
      tabsDetalhe: [], // [{ key:'det_123', label:'Itens...', cd_menu:123, disabled:true }]
      idPaiDetalhe: null, // valor da PK do registro selecionado na principal
      filhos: {}, // Mapa por cd_menu_detalhe: { meta, columns, rows, keyName, filtro }
      // identificação/legenda do registro pai selecionado (NOVO)
      paiSelecionadoId: null,
      paiSelecionadoTexto: "",
      registroSelecionado: null,
      registroSelecionadoPrincipal: null,
      dlgMapaAtributos: false,
      //
      cd_menu_processo: 0, // vem do payload (meta)
      dlgMenuProcessos: false, // controla o modal
      menuProcessoRows: [], // linhas da grid de processos
      columnsProcessos: [], // colunas da grid de processos
      menuProcessoLoading: false, // loading do modal
      formSomenteLeitura: false,
      uploadingArquivo: false,
      uploadErroArquivo: null,
      acoesGridColor: [
        { cor: "grey-7" },
        { cor: "deep-orange-7" },
        { cor: "orange-7" },
        { cor: "blue-7" },
        { cor: "green-7" },
        { cor: "red-7" },
        { cor: "purple-7" },
        { cor: "teal-7" },
        { cor: "brown-7" },
        { cor: "indigo-7" },
        { cor: "cyan-7" },
        { cor: "pink-7" },
        { cor: "lime-7" },
        { cor: "amber-7" },
        { cor: "yellow-7" },
      ],
      legendaAcoesGrid: [],
      fasePedido: [],
      cd_form: 0,
      cd_menu_modal: 0,
      cd_form_modal: 0,
      ic_grid_modal: "N",
      ic_selecao_registro: "N",
      selectionMode: "multiple", // 'single' ou 'multiple'
      registrosSelecionados: [], // registros selecionados na grid
      mostrarBotaoModalComposicao: false,
      dialogModalComposicao: false,
      dialogModalGridComposicao: false,
      showLookup: false,
      campoLookupAtivo: null,
      cdMenuAnteriorLookup: Number(localStorage.cd_menu || 0),
      tituloLookup: "",
      ultimoSelecionadoLookup: null,
      cd_menu_principal: 0,
      formStack: [],
      dialogFiltroSelecao: false,
      filtroSelecao: { keyField: "", keys: [] },
      ic_pesquisa_banco: "N",
    };
  },

  created() {
    ///
    this.bootstrap();
    ///

    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    if (!this.embedMode) {
      localStorage.cd_filtro = 0;
      localStorage.cd_parametro = 0;
      localStorage.cd_tipo_consulta = 0;
      localStorage.cd_tipo_filtro = 0;
      localStorage.cd_documento = 0;
    }

    this.dt_inicial = localStorage.dt_inicial;
    this.dt_final = localStorage.dt_final;
    this.dt_base = localStorage.dt_base;
    this.periodoVisible = false;
    this.tituloMenu = localStorage.nm_menu_titulo;

    //
    this.cd_menu = localStorage.cd_menu;
    //

    if (Number(this.cd_menu_entrada || 0) != 0) {
      this.cd_menu = Number(this.cd_menu_entrada || 0);
    }

    //
    this.nm_usuario = localStorage.usuario;
    this.cd_menu_principal = localStorage.cd_menu;
    this.hoje = "";
    this.hora = "";

    // preencher datas do mês vigente (item 3)
    this.$nextTick(() => {
      this.preencherDatasDoMes();
    });

    //

    if (!this.qt_tempo == 0) {
      this.pollData();
      localStorage.polling = 1;
    }

    // se veio título do modal, usa ele
    if (this.titulo_menu_entrada) {
      this.tituloMenu = this.titulo_menu_entrada;
      this.title = this.titulo_menu_entrada;
      //localStorage.nm_menu_titulo = this.titulo_menu_entrada // opcional, mas ajuda seu topo atual
    }

    //this.dialogFiltroSelecao = true;
  },

  async mounted() {
    this.$nextTick(() => {
      this.restoreGridConfig();
    });

    //this.restoreGridConfig();

    //
    this.definirAlturaInicialGrid();

    // Mantém a grid sempre ocupando o resto da tela (vertical)
    window.addEventListener("resize", this.ajustarAlturaTela, {
      passive: true,
    });
    // garante o cálculo correto após o primeiro render
    this.$nextTick(() => this.ajustarAlturaTela());

    locale("pt"); // ou 'pt-BR'

    this.ic_pesquisa_banco = "N";
    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;

    // se você já usa onToolbarPreparing, acrescente mais um item
    //this.onToolbarPreparing && this.onToolbarPreparing({
    // addExcelButton: true
    //});

    if (typeof this.carregarCatalogoRelatorios === "function") {
      this.carregarCatalogoRelatorios();
    }
    //this.carregaDados();
  },

  beforeDestroy() {
    window.removeEventListener("resize", this.ajustarAlturaTela);
  },

  computed: {
    registroPaiEfetivo() {
      return (
        this.registroSelecionadoPrincipal ||
        (this.registrosSelecionados && this.registrosSelecionados[0]) ||
        null
      );
    },

    isRootInstance() {
      // raiz = NÃO está em embed
      return this.embedMode !== true;
    },

    isEmbeddedInstance() {
      return this.embedMode === true;
    },

    emTabFilha() {
      return this.activeMenuTab && this.activeMenuTab !== "principal";
    },

    mostrarToolbar() {
      // toolbar aparece SOMENTE na raiz
      return this.isRootInstance;
    },

    mostrarHeaderInterno() {
      // header (seta + título) aparece
      // ❗ SOMENTE quando for embed E for a primeira camada
      return this.isEmbeddedInstance && !this.hideToolbar;
    },

    isEmbeddedClean() {
      return this.embedMode && this.hideChrome;
    },

    uiLite() {
      return !!this.engineOverrides.ui_lite;
    },

    engineOverrides() {
      return this.overrides || {};
    },

    displayTitle() {
      return this.engineOverrides.title || this.tituloMenu || this.title || "";
    },

    hideButtons() {
      return this.engineOverrides.hideButtons || {};
    },

    treeNodesFiltrados() {
      // q-tree já filtra via prop :filter, mas aqui você pode manter “como está”
      return this.treeNodes || [];
    },

    treeMetaPai() {
      return (
        (this.gridMeta || []).find(
          m => String(m.ic_atributo_pai || "").toUpperCase() === "S"
        ) || null
      );
    },

    treeMetaFilho() {
      return (
        (this.gridMeta || []).find(
          m => String(m.ic_atributo_filho || "").toUpperCase() === "S"
        ) || null
      );
    },

    // tenta achar o “melhor campo de descrição” para mostrar no leaf
    treeMetaLabelLeaf() {
      const meta = (this.gridMeta || []).filter(
        m => String(m.ic_mostra_grid || "S").toUpperCase() === "S"
      );

      // descarta campos “id-like”
      const candidatos = meta.filter(m => {
        const nm = (
          m.nm_atributo ||
          m.nm_atributo_consulta ||
          ""
        ).toLowerCase();
        if (!nm) return false;
        if (nm.includes("cd_")) return false;
        if (nm.includes("id")) return false;
        return true;
      });

      // prioriza por “título/descrição” no nome
      const preferidos = candidatos.find(m => {
        const nm = (
          m.nm_atributo ||
          m.nm_atributo_consulta ||
          ""
        ).toLowerCase();
        return (
          nm.includes("descricao") ||
          nm.includes("descrição") ||
          nm.includes("nome") ||
          nm.includes("nm_")
        );
      });

      return preferidos || candidatos[0] || null;
    },

    dashboardAtributos() {
      const cols = Array.isArray(this.columns) ? this.columns : [];
      return cols.filter(c => {
        const flag = String(
          (c && c.ic_dashboard_atributo) ||
            (c && c.ic_ic_dashboard_atributo) ||
            "N"
        ).toUpperCase();
        return flag === "S";
      });
    },

    dashboardCards() {
      const rows = Array.isArray(this.rowsParaDashboard)
        ? this.rowsParaDashboard
        : [];
      const attrs = this.dashboardAtributos || [];
      if (!rows.length || !attrs.length) return [];

      const sampleRow = rows.find(r => r && typeof r === "object") || {};

      return attrs
        .map(a => {
          const candidatos = [
            a?.nm_dashboard_campo,
            a?.nm_atributo_consulta,
            a?.nm_edit_label,
            a?.nm_atributo,
            a?.dataField,
            a?.caption,
          ]
            .filter(Boolean)
            .map(s => String(s).trim());

          const key =
            candidatos.find(k =>
              Object.prototype.hasOwnProperty.call(sampleRow, k)
            ) ||
            candidatos.find(k =>
              rows.some(r => r && Object.prototype.hasOwnProperty.call(r, k))
            ) ||
            candidatos[0];

          if (!key) return null;

          const titulo = String(
            a?.nm_dashboard_titulo ||
              a?.nm_edit_label ||
              a?.caption ||
              a?.nm_atributo_consulta ||
              a?.nm_atributo ||
              key ||
              "Indicador"
          ).trim();

          const aggRaw = String(a?.nm_dashboard_agregacao || "").toUpperCase();
          const agg = [
            "COUNT",
            "DISTINCT_COUNT",
            "AVG",
            "MAX",
            "MIN",
            "SUM",
          ].includes(aggRaw)
            ? aggRaw
            : "SUM";

          const valores = rows.map(r => (r ? r[key] : undefined));
          const nums = valores
            .map(v => Number(v))
            .filter(v => !Number.isNaN(v));

          const temNumeros = nums.length > 0;
          const soma = temNumeros ? nums.reduce((s, v) => s + v, 0) : 0;

          let valor = 0;

          if (agg === "COUNT") {
            valor = rows.length;
          } else if (agg === "DISTINCT_COUNT") {
            const set = new Set(
              valores.filter(v => v !== null && v !== undefined)
            );
            valor = set.size;
          } else if (agg === "AVG") {
            valor = temNumeros ? soma / nums.length : 0;
          } else if (agg === "MAX") {
            valor = temNumeros ? Math.max(...nums) : 0;
          } else if (agg === "MIN") {
            valor = temNumeros ? Math.min(...nums) : 0;
          } else {
            valor = temNumeros ? soma : rows.length;
          }

          return {
            field: key,
            titulo,
            valor,
            subtitulo:
              a?.nm_dashboard_subtitulo ||
              (agg === "COUNT"
                ? "total de registros"
                : agg === "DISTINCT_COUNT"
                ? "valores únicos"
                : agg === "AVG"
                ? "média"
                : "total"),
            formato:
              a?.nm_dashboard_formato || a?.nm_formato || a?.format || "",
          };
        })
        .filter(Boolean);
    },

    cardsFiltrados() {
      //const lista = Array.isArray(this.rows) ? this.rows : []
      const lista =
        Array.isArray(this.rows) && this.rows.length
          ? this.rows
          : Array.isArray(this.dashboardRows)
          ? this.dashboardRows
          : [];

      const f = String(this.filtroCardsTexto || "")
        .trim()
        .toLowerCase();
      if (!f) return lista;

      return lista.filter(r => {
        try {
          return JSON.stringify(r)
            .toLowerCase()
            .includes(f);
        } catch (_) {
          return false;
        }
      });
    },

    gridSummaryConfig() {
      const t = this.total;
      if (!t) return undefined;

      // se vier array direto, embrulha
      if (Array.isArray(t)) return t.length ? { totalItems: t } : undefined;

      // se vier no formato correto
      if (t && Array.isArray(t.totalItems))
        return t.totalItems.length ? t : undefined;

      return undefined;
    },

    gridScrollStyles() {
      const alturaBruta = Number(this.gridAlturaAtual || 0);
      if (!alturaBruta) return {};

      const altura = Math.max(
        this.gridAlturaMin,
        Math.min(this.gridAlturaMax, alturaBruta)
      );

      return {
        height: `${altura}px`,
        maxHeight: `${altura}px`,
        minHeight: `${Math.min(altura, this.gridAlturaMax)}px`,
      };
    },

    menuIdEfetivo() {
      // prioridade: o que vem da tab (cd_menu_composicao)
      const v = Number(this.cd_menu_entrada || 0);

      if (v > 0) return v;

      // fallback: o menu normal (rota / prop antiga)
      return Number(this.cd_menu || this.cdMenu || 0);
    },

    // DataSource já filtrado pelo FiltroComponente (se houver seleção)

    gridDataSource() {
      const base = this.rows || this.dataSourceConfig || [];

      if (!Array.isArray(base)) return base;

      const keys =
        this.filtroSelecao && Array.isArray(this.filtroSelecao.keys)
          ? this.filtroSelecao.keys
          : [];
      const keyField = this.filtroSelecao
        ? String(this.filtroSelecao.keyField || "")
        : "";

      if (!keys.length || !keyField) return base;

      // aceita diferença de caixa (cd_x vs CD_X)
      return base.filter(r => {
        if (!r || typeof r !== "object") return false;
        let val = r[keyField];
        if (val === undefined) {
          const alt = Object.keys(r).find(
            k => k.toLowerCase() === keyField.toLowerCase()
          );
          if (alt) val = r[alt];
        }
        return keys.includes(val);
      });
    },

    gridSelectionConfig() {
      if (this.ic_selecao_registro !== "S") {
        // sem seleção
        return { mode: "none" };
      }

      return {
        mode: this.selectionMode, // 'single' ou 'multiple'
        showCheckBoxesMode: "always", // checkbox sempre visível
        selectByClick: true, // 👈 importante
      };
    },

    // TRUE quando temos dados para graficar
    temDadosGrid() {
      return this.rowsParaDashboard && this.rowsParaDashboard.length > 0;
    },

    rowsParaDashboard() {
      // 1) Se você já tem um array "rows" usado pela grid, usa ele:
      if (Array.isArray(this.rows) && this.rows.length) {
        //console.log('[rowsDashboard] via this.rows length:', this.rows.length)
        return this.rows;
      }

      // 2) Se a grid usa somente dataSourceConfig (DevExtreme), lê da instância:
      try {
        const gridRef = this.$refs.dxGrid || this.$refs.grid;
        const grid = gridRef && gridRef.instance ? gridRef.instance : null;

        //console.log('[rowsDashboard] gridRef:', this.$refs, 'grid instance:', !!grid)

        if (grid && typeof grid.getVisibleRows === "function") {
          const lista = grid.getVisibleRows().map(r => r.data);
          //console.log('[rowsDashboard] via grid.getVisibleRows length:', lista.length)
          return lista;
        }

        // alternativa, se você usa DataSource:
        const ds =
          grid && typeof grid.getDataSource === "function"
            ? grid.getDataSource()
            : null;
        if (ds && typeof ds.items === "function") {
          const lista = ds.items();
          //console.log('[rowsDashboard] via dataSource.items length:', lista.length)
          return lista;
        }
      } catch (e) {
        console.warn("[rowsDashboard] erro lendo grid:", e);
      }

      //console.log('[rowsDashboard] sem dados, retornando []')
      return [];
    },

    colsParaDashboard() {
      if (Array.isArray(this.columns) && this.columns.length) {
        const cols = this.columns.map(c => c.dataField || c.name || c.key || c);
        //console.log('[columnsDashboard] via this.columns:', cols)
        return cols;
      }

      const rows = this.rowsDashboard;
      if (rows && rows.length) {
        const cols = Object.keys(rows[0]);
        //console.log('[columnsDashboard] via keys do primeiro row:', cols)
        return cols;
      }

      //console.log('[columnsDashboard] sem colunas, retornando []')

      return [];
    },

    tituloDashboard() {
      // Use o mesmo título que você já exibe no topo do únicoForm
      return this.tituloMenu || this.nm_menu_titulo || "Dashboard";
    },

    tituloModal() {
      const t =
        this.tituloMenu || sessionStorage.getItem("menu_titulo") || "Cadastro";
      if (this.modo === "novo") return `Inclusão - ${t}`;
      if (this.modo === "alteracao") return `Alteração - ${t}`;
      if (this.modo === "consulta") return `Consulta - ${t}`;
      if (this.modo === "exclusao") return `Exclusão - ${t}`;
      return t;
    },

    tabsheetsForm() {
      return (
        (this.tabsheets || [])
          // se não quiser "Mapa de Atributos" no modal, já tira aqui:
          .filter(t => t.key !== "mapa")
          // não mostra aba sem campo
          .filter(t => Array.isArray(t.fields) && t.fields.length > 0)
      );
    },

    camposFormAtivos() {
      const tabs = this.tabsheetsForm;

      // se não tiver tabsheets válidos, volta pro comportamento antigo
      if (!tabs.length) {
        return this.atributosForm || [];
      }

      const aba = tabs.find(t => t.key === this.activeTabsheet) || tabs[0];
      return Array.isArray(aba.fields) ? aba.fields : [];
    },

    // fim camposFormAtivos

    // mantém o que você já tem e acrescente:
    recordCount() {
      // badge quando a tela usa rows (FormEspecial) OU dataSourceConfig (display-data)
      if (Array.isArray(this.rows)) return this.rows.length;
      if (Array.isArray(this.dataSourceConfig))
        return this.dataSourceConfig.length;
      return 0;
    },

    gridColumnsNovo() {
      // suas colunas atuais (ex.: vindas de meta)
      const base = (this.colunasGrid || []).map(c => ({
        dataField: c.dataField || c.nm_atributo,
        caption: c.caption || c.titulo,
      }));

      // garante que a coluna da chave exista e venha primeiro
      const key = this.keyName;
      //

      let cols = base;

      if (key) {
        const temChave = base.some(c => c.dataField === key);
        if (!temChave) {
          cols = [
            { dataField: key, caption: this.keyCaption || "Código" },
            ...base,
          ];
        } else {
          // move para a primeira posição
          const idx = base.findIndex(c => c.dataField === key);
          const [col] = base.splice(idx, 1);
          cols = [{ ...col, caption: this.keyCaption || col.caption }, ...base];
        }
      }

      // nunca renderize a coluna "id" (ela só existe se você usou fallback)
      cols = cols.filter(c => c.dataField !== "id");

      // coluna de ações (editar)

      const acoes = {
        caption: "Ações",
        width: 110,
        alignment: "center",
        cellTemplate: (container, options) => {
          const wrap = document.createElement("div");
          wrap.className = "dx-command-edit";

          const editar = document.createElement("a");
          editar.className = "dx-link dx-link-edit";
          editar.title = "Editar";
          editar.innerHTML = '<i class="fa fa-pencil"></i>';
          editar.addEventListener("click", () => {
            this.abrirFormEspecial({ modo: "A", registro: options.data });
          });

          wrap.appendChild(editar);
          container.appendChild(wrap);
        },
      };

      return [...base, ...cols, acoes];
    },
  },

  watch: {
    dialogModalComposicao(aberto) {
      if (!aberto && !this.embedMode) this.limparSelecaoGrid();
    },

    dialogModalGridComposicao(aberto) {
      if (!aberto && !this.embedMode) this.limparSelecaoGrid();
    },

    gridAlturaAtual() {
      // se usuário mexeu no slider, sai do auto-fit
      if (this.gridAutoFit) return; // auto-fit controla
      this.$nextTick(() => this.aplicarAlturaGrid());
    },

    cd_chave_registro: {
      immediate: true,
      handler(v) {
        this.cd_chave_registro_local = Number(v || 0);
      },
    },

    dlgForm(val) {
      if (val === false && this.embedMode && this.closeOnDlgFormClose) {
        this.$emit("fechar");
      }
    },

    abaAtiva() {
      if (this.abaAtiva === "principal") return;
      const t = this.tabsDetalhe.find(x => x.key === this.abaAtiva);
      if (t) this.consultarFilho(t);
    },
    dataSourceConfig(v) {
      this.qt_registro = Array.isArray(v) ? v.length : 0;
    },
    rows(v) {
      this.qt_registro = Array.isArray(v) ? v.length : 0;

      if (
        String(this.ic_treeview_menu || "N").toUpperCase() === "S" &&
        this.exibirComoTree
      ) {
        this.$nextTick(() => this.montarTreeview());
      }
    },

    // quando filtros chegarem/alterarem, tenta preencher datas
    filtros: {
      immediate: true,
      deep: true,
      handler() {
        this.$nextTick(() => this.preencherDatasDoMes());
      },
    },
    filters: {
      numero(v) {
        return Number(v || 0).toLocaleString("pt-br", {
          minimumFractionDigits: 2,
        });
      },
      moeda(v) {
        return Number(v || 0).toLocaleString("pt-br", {
          style: "currency",
          currency: "BRL",
        });
      },
    },
    visible(v) {
      if (v) {
        // ... sua rotina atual de init ...
        this.loadAllLookups(); // adiciona aqui
      }
    },

    activeMenuTab(novo, antigo) {
      // garante stack
      if (!Array.isArray(this._tabStack)) this._tabStack = [];

      // evita lixo
      if (!antigo || antigo === novo) return;

      // só empilha se estamos indo para uma aba filha
      if (novo !== "principal") {
        // evita duplicar a mesma aba seguida
        const last = this._tabStack[this._tabStack.length - 1];
        if (last !== antigo) this._tabStack.push(antigo);
      }
    },
  },

  methods: {
    onGridReady() {
      this.restoreGridConfig();
    },

    onGridInitialized(e) {
      if (this._gridReady) return;
      this._gridReady = true;

      const grid = e.component;
      if (!grid) return;

      this.$nextTick(() => {
        try {
          // força criação interna de estado (SEM selecionar nada visível)
          grid.option("focusedRowIndex", -1);
          grid.clearSelection();

          // força cálculo de layout
          grid.repaint();
        } catch (err) {}
      });
    },

    abrirTabFilhaPorLinha(row) {
      if (!row) return;

      // 1) força seleção interna igual seu fluxo
      this.registroSelecionado = row;
      this.registroSelecionadoPrincipal = row;
      this.registrosSelecionados = [row];

      const kf = this.keyName || "id";
      this.cd_chave_registro_local = Number(row?.[kf] || row?.id || 0);

      // 2) acha a tab de composição (preferência: "Parcelas")
      const tabs = Array.isArray(this.menuTabs) ? this.menuTabs : [];
      let t = tabs.find(x => (x.label || "").toLowerCase().includes("parcela"));
      if (!t) t = tabs[0];

      if (!t) {
        this.$q.notify({
          type: "warning",
          position: "top",
          message: "Nenhuma aba filha configurada.",
        });
        return;
      }

      // 3) muda para a tab e reaproveita sua lógica existente
      this.activeMenuTab = t.key;
      this.$nextTick(() => this.onClickMenuTab(t));
      //
    },

    getParentHeader(reg) {
      if (!reg) return "";

      // tenta montar algo “bonito” e genérico:
      const prefer = [
        "codigo",
        "cd",
        "id",
        "nome",
        "nm",
        "fornecedor",
        "razao",
        "fantasia",
        "documento",
        "numero",
        "emissao",
      ];

      const keys = Object.keys(reg)
        .filter(k => reg[k] !== null && reg[k] !== undefined && reg[k] !== "")
        .filter(k => typeof reg[k] !== "object");

      // ordena priorizando chaves “prováveis”
      keys.sort((a, b) => {
        const pa = prefer.findIndex(p => a.toLowerCase().includes(p));
        const pb = prefer.findIndex(p => b.toLowerCase().includes(p));
        return (pa === -1 ? 999 : pa) - (pb === -1 ? 999 : pb);
      });

      // pega 4 campos no máximo
      const pick = keys.slice(0, 4);

      return pick.map(k => `${k}: ${reg[k]}`).join("  •  ");
    },

    getToolbarEngine() {
      const child = this.getActiveChildRef();
      return child || this;
    },

    getActiveChildRef() {
      const key = this.activeMenuTab;
      if (!key || key === "principal") return null;
      const refName = `child_${key}`;
      const comp = this.$refs[refName];
      // Vue2: ref de v-for pode virar array
      return Array.isArray(comp) ? comp[0] : comp;
    },

    onClickRefresh() {
      const child = this.getActiveChildRef();
      if (child && typeof child.consultar === "function") {
        child.consultar();
        return;
      }
      this.consultar();
    },

    onClickNovo() {
      const child = this.getActiveChildRef();
      if (child && typeof child.abrirFormEspecial === "function") {
        child.abrirFormEspecial({ modo: "I" });
        return;
      }
      this.abrirFormEspecial({ modo: "I" });
    },

    async onSucessoModal() {
      const tab = this._tabAntesModal || this.activeMenuTab || "principal";
      const estavaFilha = this._estavaEmTabFilha === true;

      await this.onRefreshConsulta();

      // se estava em tab filha, tenta reabrir ela
      //this.limparSelecaoGrid();

      // ✅ restaura a aba filha
      if (estavaFilha) {
        this.$nextTick(() => {
          this.activeMenuTab = tab;

          // se você tem lógica de carregar a grid filha ao entrar na tab:
          const t = (this.menuTabs || []).find(x => x.key === tab);
          if (t) this.onClickMenuTab(t); // ou this.consultarFilho(t), conforme seu fluxo
        });
      }

      // limpa o checkpoint
      this._tabAntesModal = null;
      this._estavaEmTabFilha = false;
    },

    limparSelecaoGrid() {
      // limpa estado Vue
      this.registrosSelecionados = [];
      this.registroSelecionadoPrincipal = null;
      this.registroSelecionado = null;
      this.cd_chave_registro_local = 0;

      // limpa seleção no DevExtreme
      this.$nextTick(() => {
        const grid = this.$refs.grid;
        const inst = grid && grid.instance;
        if (inst && typeof inst.clearSelection === "function") {
          inst.clearSelection();
        }
      });
    },

    toolbarNovo() {
      const e = this.getToolbarEngine();
      if (typeof e.abrirFormEspecial === "function") {
        e.abrirFormEspecial({ modo: "I", registro: {} });
      }
    },

    toolbarRefresh() {
      const e = this.getToolbarEngine();
      // prioriza seu fluxo normal
      if (typeof e.onRefreshConsulta === "function")
        return e.onRefreshConsulta();
      if (typeof e.consultar === "function") return e.consultar();
    },

    toolbarFiltros() {
      const e = this.getToolbarEngine();
      if (typeof e.abrirFiltroSelecao === "function") e.abrirFiltroSelecao();
    },

    toolbarDetalhe() {
      const e = this.getToolbarEngine();
      if (typeof e.abrirModalComposicao === "function")
        e.abrirModalComposicao();
    },

    toolbarExcel() {
      const e = this.getToolbarEngine();
      if (typeof e.exportarExcel === "function") e.exportarExcel();
    },

    toolbarPDF() {
      const e = this.getToolbarEngine();
      if (typeof e.exportarPDF === "function") e.exportarPDF();
    },

    toolbarRelatorio() {
      const e = this.getToolbarEngine();
      if (typeof e.abrirRelatorio === "function") e.abrirRelatorio();
    },

    toolbarDash() {
      const e = this.getToolbarEngine();
      if (typeof e.abrirDashboardDinamico === "function")
        e.abrirDashboardDinamico();
    },

    toolbarProcessos() {
      const e = this.getToolbarEngine();
      if (typeof e.abrirMenuProcessos === "function") e.abrirMenuProcessos();
    },

    toolbarMapaAtributos() {
      const e = this.getToolbarEngine();

      // se o filho tem o mesmo dialog, abre nele
      if (e && Object.prototype.hasOwnProperty.call(e, "dlgMapaAtributos")) {
        e.dlgMapaAtributos = true;
        return;
      }

      // fallback: abre no pai
      this.dlgMapaAtributos = true;
    },

    toolbarDrawerFiltros() {
      const e = this.getToolbarEngine();

      if (e && Object.prototype.hasOwnProperty.call(e, "drawerFiltros")) {
        e.drawerFiltros = true;
        return;
      }

      this.drawerFiltros = true;
    },

    toolbarInfo() {
      const e = this.getToolbarEngine();

      // tenta rodar no filho (pra mostrar o cd_menu/infos do filho)
      if (e && typeof e.onInfoClick === "function") {
        e.onInfoClick();
        return;
      }

      // fallback
      if (typeof this.onInfoClick === "function") this.onInfoClick();

      // fallback direto:
      this.infoDialog = true;
      //
    },

    formatarKpiValor(valor, formato) {
      if (valor === null || valor === undefined) return "—";

      if (formato === "moeda") {
        return new Intl.NumberFormat("pt-BR", {
          style: "currency",
          currency: "BRL",
        }).format(Number(valor) || 0);
      }
      if (formato === "percentual") {
        return `${(Number(valor) || 0).toFixed(2)}%`;
      }
      if (formato === "inteiro") {
        return new Intl.NumberFormat("pt-BR").format(
          Math.round(Number(valor) || 0)
        );
      }
      // default: mostra “bonito”
      return new Intl.NumberFormat("pt-BR").format(Number(valor) || 0);
    },

    ensureKeyOnRows() {
      if (!this.keyFieldDb) this.resolveKeyFieldDb();
      if (!Array.isArray(this.rows) || !this.rows.length) return;

      const meta = this.getMetaAtual ? this.getMetaAtual() : [];
      const pkDb = this.keyFieldDb;

      // nome "Código" (ou outro) na grid
      const pkGridCaption = meta.find(
        m =>
          String(m.ic_atributo_chave || "")
            .trim()
            .toUpperCase() === "S"
      )?.nm_atributo_consulta;

      this.rows = this.rows.map(r => {
        const row = { ...r };

        // se já tem pkDb, ok
        if (row[pkDb] != null) return row;

        // tenta pegar do caption (ex.: "Código")
        if (pkGridCaption && row[pkGridCaption] != null) {
          row[pkDb] = row[pkGridCaption];
          return row;
        }

        // fallback: campo "Código" padrão
        if (row["Código"] != null) row[pkDb] = row["Código"];

        return row;
      });
    },

    resolveKeyFieldDb() {
      const cdMenu = Number(
        this.cd_menu ||
          sessionStorage.getItem("cd_menu") ||
          localStorage.getItem("cd_menu")
      );
      const metaKey = `campos_grid_meta_${cdMenu}`;

      let meta = [];
      try {
        meta = JSON.parse(sessionStorage.getItem(metaKey) || "[]");
      } catch (_) {}

      const pk = meta.find(
        m =>
          String(m.ic_atributo_chave || "")
            .trim()
            .toUpperCase() === "S"
      );
      this.keyFieldDb = pk?.nm_atributo ? String(pk.nm_atributo).trim() : "id";

      console.log("🔑 keyFieldDb resolvido:", this.keyFieldDb);
      return this.keyFieldDb;
    },

    isHidden(btn) {
      if (this.uiPreset === "lite") return true;

      return (
        String(this.hideButtons[btn] || "false") === "true" ||
        this.hideButtons[btn] === true
      );
    },

    async runHook(name, ctx = {}) {
      try {
        const fn = this.hooks && this.hooks[name];
        if (typeof fn === "function") {
          return await fn({ ...ctx, engine: this });
        }
        return null;
      } catch (err) {
        try {
          const onError = this.hooks && this.hooks.onError;
          if (typeof onError === "function") {
            await onError({ err, hook: name, ...ctx, engine: this });
          }
        } catch (_) {}
        throw err;
      }
    },

    agendarUpdateGrid() {
      clearTimeout(this._gridDimTimer);
      this._gridDimTimer = setTimeout(() => {
        const grid = this.$refs?.grid?.instance;
        if (grid) grid.updateDimensions();
      }, 80);
    },

    ajustarGridATela() {
      this.gridAutoFit = true;
      this.$nextTick(() => this.recalcularAlturasGrid());
    },

    aplicarAlturaGrid() {
      // aqui a grid deve acompanhar o slider
      const topEl = this.$refs?.gridTop;
      const topH = topEl ? topEl.offsetHeight : 0;

      // altura útil do grid = altura total escolhida - topo
      const body = Math.max(180, Math.floor(this.gridAlturaAtual - topH));
      this.gridBodyHeight = body;

      // força o DevExtreme recalcular viewport (senão ele “não pinta” direito)
      const grid = this.$refs?.grid?.instance;
      if (grid) setTimeout(() => grid.updateDimensions(), 0);
    },

    async ensureConsultaCacheLoaded() {
      const cdMenu =
        Number(
          this.cd_menu_entrada ||
            this.ncd_menu_entrada ||
            this.cd_menu ||
            this.cdMenu ||
            0
        ) || null;

      // Colunas
      if (!Array.isArray(this.columns) || this.columns.length === 0) {
        const cols =
          (cdMenu &&
            (await this.lerCacheSeguro(this.ssKey("colunas_grid", cdMenu)))) ||
          (cdMenu &&
            (await this.lerCacheSeguro(
              this.ssKey("colunas_grid_full", cdMenu)
            ))) ||
          (await this.lerCacheSeguro("colunas_grid")) ||
          [];
        if (Array.isArray(cols) && cols.length) this.columns = cols;
      }

      // Linhas
      if (!Array.isArray(this.rows) || this.rows.length === 0) {
        const rows =
          (cdMenu &&
            (await this.lerCacheSeguro(
              this.ssKey("dados_resultado_consulta", cdMenu)
            ))) ||
          (await this.lerCacheSeguro("dados_resultado_consulta")) ||
          [];
        if (Array.isArray(rows) && rows.length) this.rows = rows;
      }
    },

    sortRowsForTreeAndGrid() {
      const meta = this.gridMeta || this.metaCampos || [];

      const mPai = meta.find(
        m => String(m.ic_atributo_pai || "N").toUpperCase() === "S"
      );
      const mFilho = meta.find(
        m => String(m.ic_atributo_filho || "N").toUpperCase() === "S"
      );

      const kPai = mPai && (mPai.nm_atributo_consulta || mPai.nm_atributo);
      const kId = mFilho && (mFilho.nm_atributo_consulta || mFilho.nm_atributo);

      const norm = v => (v === null || v === undefined ? "" : String(v).trim());

      const cmpSmart = (a, b) => {
        const na = Number(a),
          nb = Number(b);
        const aNum = !Number.isNaN(na) && String(a).trim() !== "";
        const bNum = !Number.isNaN(nb) && String(b).trim() !== "";
        if (aNum && bNum) return na - nb;
        return String(a).localeCompare(String(b), "pt-BR", {
          numeric: true,
          sensitivity: "base",
        });
      };

      this.rows = (this.rows || []).slice().sort((ra, rb) => {
        const ap = norm(kPai ? ra[kPai] : "");
        const bp = norm(kPai ? rb[kPai] : "");
        const ai = norm(kId ? ra[kId] : ra.id ?? "");
        const bi = norm(kId ? rb[kId] : rb.id ?? "");

        const c1 = cmpSmart(ap, bp);
        if (c1 !== 0) return c1;
        return cmpSmart(ai, bi);
      });
    },

    montarTreeview() {
      const rows = this.rows || [];
      const meta = this.gridMeta || this.metaCampos || [];

      // campos pai/filho
      const mPai = meta.find(
        m => String(m.ic_atributo_pai || "N").toUpperCase() === "S"
      );
      const mFilho = meta.find(
        m => String(m.ic_atributo_filho || "N").toUpperCase() === "S"
      );

      const kPai = mPai && (mPai.nm_atributo_consulta || mPai.nm_atributo);
      const kFilho =
        mFilho && (mFilho.nm_atributo_consulta || mFilho.nm_atributo);

      // label base do item
      const proibidosLabel = new Set([kPai, kFilho].filter(Boolean));
      const candidatosLabel = meta
        .filter(m => String(m.ic_mostra_grid || "").toUpperCase() === "S")
        .filter(m => {
          const fmt = String(m.formato_coluna || "").toLowerCase();
          return ![
            "currency",
            "number",
            "percent",
            "fixedpoint",
            "date",
            "datetime",
          ].includes(fmt);
        })
        .map(m => m.nm_atributo_consulta || m.nm_atributo)
        .filter(k => k && !proibidosLabel.has(k));

      const kLabel = candidatosLabel[0] || "Descrição";

      // atributos extras do tree (ordenados)
      const toOrd = (m, idx) =>
        Number(
          m.nu_ordem || m.qt_ordem_atributo || m.qt_ordem || idx + 1 || 999999
        );

      const metasTreeAttr = meta
        .filter(
          m => String(m.ic_treeview_atributo || "N").toUpperCase() === "S"
        )
        .map((m, idx) => ({ m, ordem: toOrd(m, idx) }))
        .sort((a, b) => (a.ordem || 999999) - (b.ordem || 999999))
        .map(x => x.m);

      const getVal = (r, k) => {
        if (!r || !k) return null;
        return r[k] ?? r[String(k)] ?? null;
      };
      const norm = v => (v === null || v === undefined ? "" : String(v).trim());

      // descobre campo de "Classificação"
      const mClass = meta.find(m => {
        const t = String(
          m.ds_atributo ||
            m.nm_titulo_menu_atributo ||
            m.nm_atributo_consulta ||
            m.nm_atributo ||
            ""
        ).toLowerCase();
        return t.includes("classifica");
      });
      const kClass =
        mClass && (mClass.nm_atributo_consulta || mClass.nm_atributo);

      // monta sufixo de atributos (SEM "titulo:", só o valor)
      const buildAttrsSuffix = (r, ignoreKeys = new Set()) => {
        const parts = [];
        for (const m of metasTreeAttr) {
          const key = m.nm_atributo_consulta || m.nm_atributo;
          if (!key || ignoreKeys.has(key)) continue;

          const val = norm(getVal(r, key));
          if (!val) continue;

          parts.push(val); // só o conteúdo
        }
        return parts.length ? ` · ${parts.join(" · ")}` : "";
      };

      // comparador
      const cmpSmart = (a, b) => {
        const na = Number(a),
          nb = Number(b);
        const aNum = !Number.isNaN(na) && String(a).trim() !== "";
        const bNum = !Number.isNaN(nb) && String(b).trim() !== "";
        if (aNum && bNum) return na - nb;
        return String(a).localeCompare(String(b), "pt-BR", {
          numeric: true,
          sensitivity: "base",
        });
      };

      // fallback: se não existir row pai, calcula classe do grupo a partir dos filhos
      const splitClass = s =>
        norm(s)
          .split(".")
          .filter(Boolean);
      const joinClass = arr => arr.join(".");
      const groupClassFromChildren = childrenRows => {
        if (!kClass) return "";
        const partsList = (childrenRows || [])
          .map(r => splitClass(getVal(r, kClass)))
          .filter(a => a.length > 0);
        if (!partsList.length) return "";

        // prefixo comum
        let pref = partsList[0];
        for (let i = 1; i < partsList.length; i++) {
          const cur = partsList[i];
          let j = 0;
          while (j < pref.length && j < cur.length && pref[j] === cur[j]) j++;
          pref = pref.slice(0, j);
          if (!pref.length) break;
        }

        // se der só "02", tenta usar 2 níveis do primeiro filho
        if (pref.length === 1 && partsList[0].length >= 2)
          return joinClass(partsList[0].slice(0, 2));
        return joinClass(pref);
      };

      // ====== AGRUPAMENTO CERTO ======
      // A ideia: identificar "row pai" (quando kPai está vazio) e usar ela para a classe do grupo (01/02).
      // E os filhos são as rows que têm kPai preenchido.
      const grupos = new Map(); // nomeGrupo -> { rowPai, children[] }

      rows.forEach(r => {
        const paiKeyVal = norm(getVal(r, kPai)); // quando vazio -> é registro pai
        const isRowPai = paiKeyVal === "";

        // define nome do grupo:
        // - se é row pai: usa o label dela (Descrição)
        // - se é filho: usa o valor do campo pai (kPai), que deve ser o nome do grupo
        const nomeGrupo = isRowPai
          ? norm(getVal(r, kLabel)) || norm(getVal(r, kFilho)) || "Sem grupo"
          : paiKeyVal || "Sem grupo";

        if (!grupos.has(nomeGrupo))
          grupos.set(nomeGrupo, { rowPai: null, children: [] });
        const g = grupos.get(nomeGrupo);

        if (isRowPai) {
          g.rowPai = r;
          return; // não inclui pai como filho
        }

        const filhoVal = getVal(r, kFilho) ?? r.id ?? null;
        if (filhoVal == null) return;

        const baseLeaf = norm(getVal(r, kLabel)) || String(filhoVal);
        const ignoreLeaf = new Set([kPai, kFilho, kLabel].filter(Boolean));
        const leafLabel = `${baseLeaf}${buildAttrsSuffix(r, ignoreLeaf)}`;

        g.children.push({
          id: `F_${filhoVal}`,
          label: leafLabel,
          isLeaf: true,
          _raw: r,
          _ord: filhoVal,
        });
      });

      // monta nodes
      const nodes = Array.from(grupos.entries()).map(([nomeGrupo, g]) => {
        const ignorePai = new Set([kPai].filter(Boolean));

        // fonte dos atributos do pai:
        // - se existe rowPai, usar ela (classe 01/02 igual grid)
        // - senão: usar fallback por filhos
        const rowBasePai =
          g.rowPai || (g.children[0] && g.children[0]._raw) || null;

        let classGrupo = "";
        if (g.rowPai && kClass) {
          classGrupo = norm(getVal(g.rowPai, kClass)); // 01 / 02
        } else {
          const rowsDoGrupo = g.children.map(c => c._raw).filter(Boolean);
          classGrupo = groupClassFromChildren(rowsDoGrupo);
        }

        // attrs no pai: quando for classificação, usa classGrupo; demais vem do rowBasePai
        const buildAttrsSuffixPai = () => {
          const parts = [];
          for (const m of metasTreeAttr) {
            const key = m.nm_atributo_consulta || m.nm_atributo;
            if (!key || ignorePai.has(key)) continue;

            let val = "";
            if (kClass && key === kClass) {
              val = norm(classGrupo);
            } else {
              val = rowBasePai ? norm(getVal(rowBasePai, key)) : "";
            }

            if (!val) continue;
            parts.push(val); // só conteúdo
          }
          return parts.length ? ` · ${parts.join(" · ")}` : "";
        };

        const paiLabel = `${nomeGrupo}${buildAttrsSuffixPai()}`;

        // ordena filhos por id
        g.children.sort((a, b) => cmpSmart(a._ord, b._ord));

        return {
          id: `P_${nomeGrupo}`,
          label: paiLabel,
          children: g.children,
          _ord: nomeGrupo,
          _ordClass: classGrupo || nomeGrupo,
        };
      });

      // ordena grupos pelo nome (ou adapte se quiser por código)
      //nodes.sort((a, b) => cmpSmart(a._ord, b._ord))
      nodes.sort((a, b) => cmpSmart(a._ordClass, b._ordClass));

      /*
  nodes.sort((a, b) => {
  const c = cmpSmart(a._ordClass, b._ordClass)
  if (c !== 0) return c
  return cmpSmart(a._ord, b._ord)
})
*/

      this.treeNodes = nodes;
      this.treeExpanded = nodes.map(n => n.id);
    },

    expandirTudoTree() {
      // expande todos os ids (recursivo)
      const ids = [];
      const walk = ns =>
        (ns || []).forEach(n => {
          ids.push(n.id);
          if (n.children && n.children.length) walk(n.children);
        });
      walk(this.treeNodes);
      this.treeExpanded = ids;
    },

    recolherTudoTree() {
      this.treeExpanded = [];
    },

    getTreeFieldsFromMeta() {
      const meta = this.metaCampos || this.gridMeta || [];

      // campo PAI (grupo)
      const pai = meta.find(
        m => String(m.ic_atributo_pai || "").toUpperCase() === "S"
      );
      // campo FILHO (id do leaf)
      const filho = meta.find(
        m => String(m.ic_atributo_filho || "").toUpperCase() === "S"
      );

      // campo LABEL (o que aparece no tree)
      // regra: primeiro campo visível na grid e “textual” (não é pai/filho)
      const proibidos = new Set(
        [pai?.nm_atributo, filho?.nm_atributo].filter(Boolean)
      );

      const label = meta.find(m => {
        const k = m?.nm_atributo;
        if (!k || proibidos.has(k)) return false;
        if (String(m.ic_mostra_grid || "").toUpperCase() !== "S") return false;

        const fmt = String(m.formato_coluna || "").toLowerCase();
        // evita num/currency/percent
        if (
          [
            "currency",
            "number",
            "percent",
            "fixedpoint",
            "date",
            "datetime",
          ].includes(fmt)
        )
          return false;
        return true;
      });

      this.treeFieldPai =
        (pai && (pai.nm_atributo || pai.nm_atributo_consulta)) || "";
      this.treeFieldFilho =
        (filho && (filho.nm_atributo || filho.nm_atributo_consulta)) || "";
      this.treeFieldLabel =
        (label && (label.nm_atributo || label.nm_atributo_consulta)) || "";

      // fallback extra: se não achou label, tenta um “consulta” típico
      if (!this.treeFieldLabel) {
        const alt = meta.find(
          m => String(m.nm_atributo_consulta || "").trim() !== ""
        );
        this.treeFieldLabel = alt?.nm_atributo_consulta || "";
      }

      // console pra você validar no browser
      console.log("[TREE META]", {
        treeFieldPai: this.treeFieldPai,
        treeFieldFilho: this.treeFieldFilho,
        treeFieldLabel: this.treeFieldLabel,
      });
    },

    buildTreeNodesFromRows() {
      const rows = this.rows || [];
      const kPai = this.treeFieldPai;
      const kFilho = this.treeFieldFilho;
      const kLabel = this.treeFieldLabel;

      const grupos = new Map();

      const getVal = (obj, key) => {
        if (!obj || !key) return null;
        return obj[key] ?? obj[String(key)] ?? null;
      };

      const norm = v => (v === null || v === undefined ? "" : String(v).trim());

      rows.forEach(r => {
        const paiVal = norm(getVal(r, kPai)) || "Sem grupo";
        const filhoVal = getVal(r, kFilho);

        // label do leaf: tenta labelField, senão tenta descrição genérica, senão usa o id
        let labelVal = norm(getVal(r, kLabel));

        if (!labelVal) {
          // tenta achar algum campo string decente no próprio objeto (sem hardcode)
          const cand = Object.keys(r || {}).find(k => {
            const v = r[k];
            if (v === null || v === undefined) return false;
            const s = String(v).trim();
            if (!s) return false;
            // evita pegar o próprio pai/filho
            if (k === kPai || k === kFilho) return false;
            // evita “Codigo ...” puro se tiver algo melhor
            return s.length >= 3;
          });
          if (cand) labelVal = norm(r[cand]);
        }

        if (!labelVal) labelVal = filhoVal != null ? String(filhoVal) : "—";

        if (!grupos.has(paiVal)) {
          grupos.set(paiVal, {
            id: `G_${paiVal}`,
            label: paiVal,
            isLeaf: false,
            children: [],
          });
        }

        grupos.get(paiVal).children.push({
          id: filhoVal != null ? String(filhoVal) : `leaf_${Math.random()}`,
          label: labelVal,
          isLeaf: true,
          _raw: r,
        });
      });

      this.treeNodes = Array.from(grupos.values());

      // raiz(es) expandido(s) por padrão (opcional)
      this.treeExpanded = this.treeNodes.map(n => n.id);
    },

    tree_collectAllIds(nodes) {
      const out = [];
      const walk = arr => {
        (arr || []).forEach(n => {
          out.push(String(n.id));
          if (n.children && n.children.length) walk(n.children);
        });
      };
      walk(nodes);
      return out;
    },

    tree_expandAll() {
      this.treeExpanded = this.tree_collectAllIds(this.treeNodes);
    },

    tree_collapseAll() {
      this.treeExpanded = [];
    },

    onTreeSelected(id) {
      const node = this.findNodeById(this.treeNodes, id);
      if (!node || !node.isLeaf) return;

      const row = node._raw || node;
      if (String(this.ic_modal_pesquisa || "N").toUpperCase() === "S") {
        this.selecionarERetornar(row);
      } else {
        this.abrirFormEspecial({ modo: "A", registro: row });
      }
    },

    findNodeById(nodes, id) {
      for (const n of nodes || []) {
        if (n.id === id) return n;
        const f = this.findNodeById(n.children, id);
        if (f) return f;
      }
      return null;
    },

    metaPai() {
      const meta = this.gridMeta || this.metaCampos || [];
      return (
        meta.find(
          m => String(m.ic_atributo_pai || "N").toUpperCase() === "S"
        ) || null
      );
    },
    metaFilho() {
      const meta = this.gridMeta || this.metaCampos || [];
      return (
        meta.find(
          m => String(m.ic_atributo_filho || "N").toUpperCase() === "S"
        ) || null
      );
    },

    // pega valor do campo no row, tentando nm_atributo e nm_atributo_consulta
    getRowValue(row, metaCampo) {
      if (!row || !metaCampo) return null;
      const a = metaCampo.nm_atributo;
      const b = metaCampo.nm_atributo_consulta;
      return (
        (a && row[a] != null ? row[a] : null) ??
        (b && row[b] != null ? row[b] : null)
      );
    },

    slug(s) {
      return String(s || "")
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .replace(/[^a-zA-Z0-9]+/g, "_")
        .replace(/^_+|_+$/g, "")
        .toLowerCase()
        .slice(0, 60);
    },

    // ====== Monta árvore com parent_id ======
    treeFromParent(rows) {
      const getId = r => r.id ?? r.cd_id ?? r.cd_menu ?? r.cd ?? r.key;
      const getParent = r => r.parent_id ?? r.cd_pai ?? r.id_pai ?? null;

      const map = new Map();
      const roots = [];

      // cria nós
      rows.forEach(r => {
        const id = getId(r);
        if (id == null) return;

        map.set(id, {
          id,
          label: this.cardTitulo ? this.cardTitulo(r) : r.label || String(id),
          subtitle: this.nodeSubtitle(r),
          children: [],
          isLeaf: true,
          _raw: r,
        });
      });

      // linka pais/filhos
      rows.forEach(r => {
        const id = getId(r);
        if (id == null) return;

        const parentId = getParent(r);
        const node = map.get(id);
        if (!node) return;

        if (parentId != null && map.has(parentId)) {
          const parentNode = map.get(parentId);
          parentNode.children.push(node);
          parentNode.isLeaf = false;
        } else {
          roots.push(node);
        }
      });

      return roots;
    },

    // ====== Fallback: árvore por grupo ======
    treeFromGroupFallback(rows) {
      const groupKey =
        rows[0]?.nm_grupo || rows[0]?.nm_categoria || rows[0]?.grupo || null;

      if (!groupKey) {
        // sem info pra tree, vira uma lista simples
        return rows.map((r, idx) => ({
          id: r.id ?? idx,
          label: this.cardTitulo ? this.cardTitulo(r) : `#${idx}`,
          subtitle: this.nodeSubtitle(r),
          children: [],
          isLeaf: true,
          _raw: r,
        }));
      }

      const groups = {};
      rows.forEach((r, idx) => {
        const g = r.nm_grupo || r.nm_categoria || r.grupo || "Outros";
        if (!groups[g]) groups[g] = [];
        groups[g].push(r);
      });

      return Object.keys(groups).map((g, i) => ({
        id: `grp_${i}_${g}`,
        label: g,
        subtitle: `${groups[g].length} item(s)`,
        isLeaf: false,
        children: groups[g].map((r, idx) => ({
          id: r.id ?? `${g}_${idx}`,
          label: this.cardTitulo ? this.cardTitulo(r) : String(r.id ?? idx),
          subtitle: this.nodeSubtitle(r),
          children: [],
          isLeaf: true,
          _raw: r,
        })),
      }));
    },

    nodeSubtitle(r) {
      if (!r) return "";
      // coloca uma segunda linha leve no nó (não fixa campo)
      // tenta usar a 2ª coluna visível
      const cols = (this.columns || []).filter(c => c && c.dataField);
      const k = cols?.[1]?.dataField;
      if (k && r[k] != null && String(r[k]).trim() !== "") return String(r[k]);
      return "";
    },

    cardTitulo(row) {
      if (!row) return "—";
      // tenta usar a 1ª coluna visível como "título"
      const cols = (this.columns || []).filter(c => c && c.dataField);
      const k = cols?.[0]?.dataField;
      return k && row[k] != null
        ? String(row[k])
        : row.id != null
        ? `#${row.id}`
        : "—";
    },

    cardCampos(row) {
      console.log("cardCampos -->", row);

      const cols = (this.columns || [])
        .filter(c => c && c.dataField) // ignora coluna buttons
        .slice(0, 5); // pega 4 campos pro card

      return cols.map(c => {
        const label = c.caption || c.dataField || c.nm_atributo_consulta;

        const campo =
          c.nm_atributo_consulta || c.dataField || c.nm_atributo || c.caption;

        // ✅ fallback: se não achar pelo campo técnico, tenta pelo caption (que é como está no row)
        const raw = row
          ? row[campo] !== undefined
            ? row[campo]
            : row[label]
          : null;

        const value = this.formatarValorCard(raw, c.format);

        console.log("valor do card -->", campo, label, raw, c.format);

        return { label, value };
      });
    },

    formatarValorCard(raw, format) {
      if (raw === null || raw === undefined || raw === "") return "—";

      // tenta converter para número quando possível
      const n =
        typeof raw === "number"
          ? raw
          : Number(
              String(raw)
                .replace(/\./g, "")
                .replace(",", ".")
            );
      const isNum = !Number.isNaN(n);

      const f = String(format || "").toLowerCase();

      // moeda
      if (
        f === "currency" ||
        f.includes("moeda") ||
        f.includes("brl") ||
        f.includes("r$")
      ) {
        const v = isNum ? n : 0;
        return new Intl.NumberFormat("pt-BR", {
          style: "currency",
          currency: "BRL",
        }).format(v);
      }

      // percentual
      if (f.includes("%") || f.includes("percent")) {
        const v = isNum ? n : 0;
        return `${new Intl.NumberFormat("pt-BR", {
          maximumFractionDigits: 2,
        }).format(v)}%`;
      }

      // decimal (2 casas)
      if (f.includes("decimal") || f.includes("float")) {
        const v = isNum ? n : 0;
        return new Intl.NumberFormat("pt-BR", {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        }).format(v);
      }

      // inteiro
      if (f.includes("int")) {
        const v = isNum ? Math.round(n) : raw;
        return isNum ? new Intl.NumberFormat("pt-BR").format(v) : String(raw);
      }

      // default: se for número, formata “bonito”
      if (isNum) {
        return new Intl.NumberFormat("pt-BR", {
          maximumFractionDigits: 6,
        }).format(n);
      }

      return String(raw);
    },

    temConfigConsultaInvalida() {
      const cdTabela = Number(this.cd_tabela || 0);

      // nome_procedure pode estar em lugares diferentes; tente os mais comuns
      const procRaw =
        this.nome_procedure ??
        this.gridMeta?.nome_procedure ??
        this.gridMeta?.nm_procedure ??
        this.gridMeta?.Nome_Procedure ??
        "";

      const proc = String(procRaw || "").trim();

      const procInvalida = proc === "" || proc === "*";
      return cdTabela === 0 && procInvalida;
    },

    abrirAvisoConfigConsulta() {
      this.bloquearCarregamentoPorConfig = true;
      this.showAvisoConfig = true;
    },

    temRelatorioAtributo(attr) {
      return (
        !!attr?.cd_atributo_relatorio && Number(attr.cd_atributo_relatorio) > 0
      );
    },

    async onRelatorioDoCampo(attr) {
      console.log("attr-->", attr);
      const cd_relatorio = Number(
        attr?.cd_atributo_relatorio ?? this.cd_relatorio ?? 0
      );
      const raw = this.formData?.[attr?.nm_atributo];

      const cd_documento =
        raw !== undefined && raw !== null && String(raw).trim() !== ""
          ? Number.isNaN(Number(raw))
            ? String(raw)
            : Number(raw)
          : null;

      console.log("Relatório do Atributo: ", cd_relatorio);

      await this.onRelatorioGrid(
        { ...(this.formData || {}) },
        { cd_relatorio, cd_documento }
      );
    },

    extrairIdRegistro(row) {
      if (!row) return null;

      // 1) id padrão
      let id = row.id;

      // 2) id pode vir composto [127, "40"]
      if (Array.isArray(id)) {
        const v = id.find(x => x != null && String(x).trim() !== "");
        id = v != null ? v : null;
      }

      // 3) tenta normalizar número
      if (id != null && String(id).trim() !== "") {
        const n = Number(id);
        if (!Number.isNaN(n)) return n;
        return String(id);
      }

      // 4) fallback: tenta achar algum cd_* típico (sem travar em um só)
      const candidatos = [
        row.cd_chave,
        row.cd_codigo,
        row.cd_registro,
        row.cd_produto,
        row.cd_cliente,
        row.cd_fornecedor,
        row.cd_contrato,
        row.cd_contrato_pagar,
      ];

      for (const c of candidatos) {
        if (c != null && String(c).trim() !== "") {
          const n = Number(c);
          return Number.isNaN(n) ? String(c) : n;
        }
      }

      // 5) último recurso: procurar primeira chave que comece com cd_ e pareça id
      const k = Object.keys(row).find(
        k => /^cd_/.test(k) && row[k] != null && String(row[k]).trim() !== ""
      );
      if (k) {
        const n = Number(row[k]);
        return Number.isNaN(n) ? String(row[k]) : n;
      }

      return null;
    },

    limparRegistroParaPayload(row) {
      // remove reatividade / getters e evita circular
      const plain = JSON.parse(JSON.stringify(row || {}));

      // se tiver id composto, mantém (às vezes ajuda debug/back)
      if (Array.isArray(plain.id)) plain.id_composto = [...plain.id];

      // normaliza id também no registro limpo
      const id = this.extrairIdRegistro(plain);
      if (id != null) plain.id = id;

      return plain;
    },

    async onRelatorioGrid(row, opts = {}) {
      console.log("linhas do relatório : ", row);

      const cd_relatorio = Number(opts.cd_relatorio ?? this.cd_relatorio ?? 0);

      const registroLimpo = this.limparRegistroParaPayload(row);
      const idExtraido = this.extrairIdRegistro(registroLimpo);
      const cd_documento =
        opts.cd_documento !== undefined &&
        opts.cd_documento !== null &&
        String(opts.cd_documento).trim() !== ""
          ? Number.isNaN(Number(opts.cd_documento))
            ? String(opts.cd_documento)
            : Number(opts.cd_documento)
          : idExtraido;

      try {
        //const cd_relatorio = Number(this.cd_relatorio || 0);

        if (!cd_relatorio) {
          this.$q?.notify?.({
            type: "warning",
            position: "center",
            message:
              "Este menu não possui relatório configurado (cd_relatorio=0).",
          });

          return;
        }

        // payload do PR genérico

        const payload = [
          {
            ic_json_parametro: "S",
            cd_menu: Number(this.cd_menu || 0),
            cd_usuario: String(this.cd_usuario || 0),
            cd_relatorio: cd_relatorio,
            cd_documento: cd_documento,
            id: cd_documento,

            // opcional: se seu PR usa filtros e/ou registro selecionado
            //cd_relatorio,
            //id,                 // ✅ aqui vai o id
            //filtros: Array.isArray(this.filtrosPesquisa) ? this.filtrosPesquisa : [], // ajuste se seu filtro tem outro nome
            //registro: registroLimpo, // opcional, mas útil
          },
        ];

        console.log("payload de relatório ", payload);

        //const resp = await gerarRelatorioPadrao(payload);

        const resp = await api.post("/exec/pr_egis_relatorio_padrao", payload);

        const data = resp?.data;

        console.log("Relatório --> ", data);

        // ✅ normaliza retorno (pode vir array ou objeto)
        const row = Array.isArray(data) ? data[0] : data;

        if (!row || !row.RelatorioHTML) {
          throw new Error("RelatorioHTML não retornado");
        }

        const html = String(row.RelatorioHTML || "");

        // abre o HTML
        const win = window.open("about:blank", "_blank");
        if (!win) throw new Error("Popup bloqueado pelo navegador");

        win.document.open();
        win.document.write(html);
        win.document.close();

        this.$q?.notify?.({
          type: "positive",
          position: "center",
          message: "Relatório gerado com sucesso",
        });
      } catch (e) {
        console.error("Erro ao gerar relatório do grid:", e);
        this.$q?.notify?.({
          type: "negative",
          position: "center",
          message: "Erro ao gerar relatório.",
        });
      }

      //
    },

    montarHtmlRelatorio(retorno, payload) {
      const safe = v =>
        String(v ?? "")
          .replaceAll("&", "&amp;")
          .replaceAll("<", "&lt;")
          .replaceAll(">", "&gt;")
          .replaceAll('"', "&quot;")
          .replaceAll("'", "&#039;");

      // tenta descobrir onde está a lista de linhas
      const rows = Array.isArray(retorno)
        ? retorno
        : Array.isArray(retorno?.dados)
        ? retorno.dados
        : Array.isArray(retorno?.rows)
        ? retorno.rows
        : Array.isArray(retorno?.resultado)
        ? retorno.resultado
        : [];

      const cols = rows.length ? Object.keys(rows[0]) : [];

      const table = rows.length
        ? `
      <table>
        <thead>
          <tr>${cols.map(c => `<th>${safe(c)}</th>`).join("")}</tr>
        </thead>
        <tbody>
          ${rows
            .map(
              r => `
            <tr>${cols.map(c => `<td>${safe(r[c])}</td>`).join("")}</tr>
          `
            )
            .join("")}
        </tbody>
      </table>
    `
        : `<pre style="white-space:pre-wrap">${safe(
            JSON.stringify(retorno, null, 2)
          )}</pre>`;

      const titulo = `Relatório ${safe(payload?.cd_relatorio)} - Menu ${safe(
        payload?.cd_menu
      )}`;

      return `
  <!doctype html>
  <html lang="pt-br">
  <head>
    <meta charset="utf-8" />
    <title>${titulo}</title>
    <style>
      body { font-family: Arial, sans-serif; padding: 16px; color: #222; }
      h1 { font-size: 18px; margin: 0 0 10px; }
      .meta { font-size: 12px; color: #666; margin-bottom: 14px; }
      table { border-collapse: collapse; width: 100%; }
      th, td { border: 1px solid #ddd; padding: 8px; font-size: 12px; }
      th { background: #f5f5f5; text-align: left; position: sticky; top: 0; }
      tr:nth-child(even) td { background: #fafafa; }
      .actions { margin: 10px 0 14px; }
      button { padding: 8px 10px; cursor: pointer; }
    </style>
  </head>
  <body>
    <h1>${titulo}</h1>
    <div class="meta">
      Usuário: ${safe(payload?.cd_usuario)} |
      Gerado em: ${safe(new Date().toLocaleString())}
    </div>

    <div class="actions">
      <button onclick="window.print()">Imprimir</button>
    </div>

    ${table}
  </body>
  </html>
  `;
    },

    //
    async abrirPorChaveDoPai({ cd_menu_composicao, chave }) {
      if (!cd_menu_composicao || cd_menu_composicao <= 0) return;
      if (!chave || chave <= 0) return;

      if (this.carregandoContexto) return;
      this.carregandoContexto = true;

      try {
        // 1) troca contexto para o menu composição
        this.ncd_menu_entrada = Number(cd_menu_composicao);
        //sessionStorage.setItem("cd_menu", String(this.ncd_menu_entrada))

        // 2) carrega payload do menu (filtros, colunas, tabs do menu etc)
        await this.loadPayload(this.ncd_menu_entrada);
        await this.loadFiltros(this.ncd_menu_entrada);

        //
        await this.$nextTick();
        //

        // 3) seta chave e consulta dados do grid do menu composição
        this.cd_chave_pesquisa = Number(chave);
        //
        //console.log('pesquisa de chave do form de Entrada ->', this.cd_chave_pesquisa);
        //

        await this.consultarComChave(this.cd_chave_pesquisa);

        // 4) tenta localizar registro e abrir modal em Alteração/ Inclusão
        const achou = this.localizarRegistroPorChave(this.cd_chave_pesquisa);
        //

        console.log("registro encontrado na composição ->", achou);
        //

        // ✅ se o menu for GRID, não abre modal: posiciona na grid e pronto
        if (String(this.modo_inicial || "GRID").toUpperCase() === "GRID") {
          if (achou) {
            this.registroSelecionado = achou;
            await this.$nextTick();
            this.posicionarNaGridPorChave(this.cd_chave_pesquisa);
          } else {
            this.$q.notify({
              type: "warning",
              position: "center",
              message: "Registro não encontrado na grid da composição.",
            });
          }
          return;
        }

        //console.log('tratamento de tipo de entrada->', achou);

        if (achou) {
          this.abrirFormEspecial({ modo: "A", registro: achou });
        } else {
          // abre inclusão (opcional: pode pré-preencher a chave)
          this.abrirFormEspecial({ modo: "I", registro: {} });
        }
      } finally {
        this.carregandoContexto = false;
      }
    },

    async consultarComChave(chave) {
      // Se o seu back já filtra por "cd_chave_pesquisa", coloque isso no payload da consulta.
      // Pelo seu log, você já imprime "chave de pesquisa".
      // Então aqui só garantimos que a consulta use "this.cd_chave_pesquisa".

      // Evite chamar recarregarMenuDoContexto aqui dentro (causa loop / stack overflow)
      await this.consultar();
      //
    },

    localizarRegistroPorChave(chave) {
      if (!Array.isArray(this.rows) || !this.rows.length) return null;

      const keyField = this.keyName || "id";

      const alvo = Number(chave || 0);
      if (!keyField || !alvo) return null;

      return this.rows.find(r => Number(r?.[keyField] || 0) === alvo) || null;
    },

    posicionarNaGridPorChave(chave) {
      const grid = this.$refs.grid?.instance;
      if (!grid) return;

      const keyField = this.keyName || "id";

      const alvo = Number(chave || 0);
      if (!alvo) return;

      // tenta achar a row (para pegar a key real, caso seja diferente)
      const row = this.localizarRegistroPorChave(alvo);
      const rowKey = row ? row[keyField] ?? alvo : alvo;

      try {
        // foca e navega
        if (grid.option) {
          grid.option("focusedRowEnabled", true);
          grid.option("focusedRowKey", rowKey);
        }
        if (grid.navigateToRow) grid.navigateToRow(rowKey);
        if (grid.selectRows) grid.selectRows([rowKey], false);
      } catch (e) {
        console.warn("posicionarNaGridPorChave falhou", e);
      }
    },

    async onClickMenuTab(t) {
      // se tem seleção via checkbox, prioriza o último selecionado
      if (
        this.ic_selecao_registro === "S" &&
        this.registrosSelecionados?.length
      ) {
        const last = this.registrosSelecionados[
          this.registrosSelecionados.length - 1
        ];
        this.registroSelecionado = last;
        this.registroSelecionadoPrincipal = last;

        const kf = this.keyName || "id";
        this.cd_chave_registro_local = Number(last?.[kf] || last?.id || 0);
      }

      this.registroSelecionadoPrincipal =
        this.registroSelecionadoPrincipal || this.registroSelecionado || null;

      const chave = Number(
        this.cd_chave_registro_local || this.cd_acesso_entrada || 0
      );

      if (!chave || chave <= 0) {
        this.$q.notify({
          type: "warning",
          position: "center",
          message: "Selecione um registro na grid principal.",
        });

        return;

        // MUITO IMPORTANTE:
        // se a aba for de edição (ic_grid_menu = 'N'), não faz mais nada
        //if ((t.ic_grid_menu || 'S') !== 'S') return
      }

      // tab filha exige registro pai
      if (t.cd_menu_composicao > 0 && !this.registroSelecionado) {
        this.$q.notify({
          type: "warning",
          position: "top",
          message:
            "Selecione um registro na grade antes de abrir a composição.",
        });
        //this.activeMenuTab = "principal";

        if (!this._estavaEmTabFilha) {
          this.activeMenuTab = "principal";
        }

        return;
      }

      this.activeMenuTab = t.key;

      if (!t || Number(t.cd_menu_composicao || 0) <= 0) return;

      // ✅ takeover quando a aba filha for GRID (ic_grid_menu = 'S')
      this.takeoverFilhoGrid = String(t.ic_grid_menu || "S") === "S";
      //

      // pega instância do filho renderizado
      await this.$nextTick();
      //
      const refName = `child_${t.key}`;
      const child = this.$refs[refName];
      const inst = Array.isArray(child) ? child[0] : child;
      if (!inst || typeof inst.abrirPorChaveDoPai !== "function") return;

      await inst.abrirPorChaveDoPai({
        cd_menu_composicao: Number(t.cd_menu_composicao || 0),
        chave: Number(this.cd_chave_registro_local || 0),
      });
    },

    parseSqlTabs(raw) {
      if (!raw) return [];

      let arr = raw;
      try {
        // se vier string JSON
        if (typeof raw === "string") arr = JSON.parse(raw);
      } catch (e) {
        console.warn("sqlTabs inválido:", raw);
        return [];
      }

      if (!Array.isArray(arr)) arr = [arr];

      return arr.map((t, i) => ({
        key: `ts_${t.cd_tabsheet || i}`,
        label: t.nm_tabsheet || `Aba ${i + 1}`,
        cd_menu_composicao: Number(t.cd_menu_composicao || 0),
        ic_grid_menu: t.ic_grid_menu || "S",
        raw: t,
      }));
    },

    // ...

    ssKey(base) {
      const m = Number(this.cd_menu_entrada || this.cd_menu || 0);
      return m ? `${base}_${m}` : base;
    },

    ssGet(k, fallback = null) {
      try {
        return sessionStorage.getItem(this.ssKey(k)) ?? fallback;
      } catch (e) {
        return fallback;
      }
    },

    ssSet(k, v) {
      try {
        sessionStorage.setItem(this.ssKey(k), v);
      } catch (e) {}
    },

    isQuotaError(err) {
      return (
        err &&
        (err.name === "QuotaExceededError" ||
          err.code === 22 ||
          err.code === 1014 ||
          (err.message || "").toLowerCase().includes("quota"))
      );
    },

    serializeForStorage(value) {
      return typeof value === "string" ? value : JSON.stringify(value);
    },

    async salvarCacheSeguro(key, value, { parseJson = true } = {}) {
      const payload = parseJson ? this.serializeForStorage(value) : value;

      // tenta salvar no sessionStorage; se falhar por quota, cai para IndexedDB
      try {
        sessionStorage.setItem(key, payload);

        //

        // se salvou no localStorage, remove do IndexedDB para não ficar lixo/stale
        //try {
        // await offlineDb.collection(GRID_CACHE_COLLECTION).doc({ key }).delete();
        //..} catch (_) {}

        // IMPORTANTE: manter cópia no IndexedDB para outras abas/janelas
        //await offlineDb.collection(GRID_CACHE_COLLECTION).doc({ key }).set({
        //  key,
        //  value: payload,
        //  updatedAt: Date.now()
        //});

        return;
      } catch (err) {
        if (!this.isQuotaError(err)) {
          console.warn(
            "[unicoFormEspecial] Falha ao salvar no sessionStorage:",
            err
          );
        }
      }

      // fallback: IndexedDB via Localbase
      try {
        const docId = key; // chave vira o id do documento

        await offlineDb
          .collection(GRID_CACHE_COLLECTION)
          .doc(docId)
          .set({
            key,
            value: payload,
            updatedAt: Date.now(),
          });

        //await offlineDb.collection(GRID_CACHE_COLLECTION).doc({ key }).set({
        //  key,
        //  value,
        // scope: GRID_CACHE_PREFIX,
        //  updatedAt: new Date().toISOString(),
        //});
      } catch (dbErr) {
        console.error(
          "[unicoFormEspecial] Falha ao salvar no IndexedDB:",
          dbErr
        );
      }
    },

    async lerCacheSeguro(key, { parseJson = true } = {}) {
      try {
        const raw = sessionStorage.getItem(key);
        if (raw !== null && raw !== undefined) {
          return parseJson ? JSON.parse(raw) : raw;
        }
      } catch (err) {
        if (!this.isQuotaError(err)) {
          console.warn(
            "[unicoFormEspecial] Falha ao ler do sessionStorage:",
            err
          );
        }
      }

      try {
        const doc = await offlineDb
          .collection(GRID_CACHE_COLLECTION)
          .doc({ key })
          .get();

        if (doc && Object.prototype.hasOwnProperty.call(doc, "value")) {
          //return doc.value;
          const raw = doc.value;
          if (raw == null) return null;

          return parseJson ? this.deserializeFromStorage(raw) : raw;
        }
      } catch (dbErr) {
        // ausência de doc não é erro crítico; log apenas se for outra falha
        if (dbErr && !/No Documents found/i.test(dbErr.message || "")) {
          console.warn("[unicoFormEspecial] Falha ao ler do IndexedDB:", dbErr);
        }
      }

      return null;
    },

    async removerCacheSeguro(key) {
      try {
        sessionStorage.removeItem(key);
      } catch (err) {}

      try {
        await offlineDb
          .collection(GRID_CACHE_COLLECTION)
          .doc({ key })
          .delete();
      } catch (dbErr) {
        // ignora ausência de documento
        if (dbErr && !/No Documents found/i.test(dbErr.message || "")) {
          console.warn("[unicoFormEspecial] Falha ao limpar IndexedDB:", dbErr);
        }
      }
    },

    async onInfoClick() {
      const { titulo, descricao } = await getInfoDoMenu(this.cd_menu, {
        tituloFallback: localStorage.menu_titulo || this.pageTitle, // se você tiver um título local
      });
      this.infoTitulo = titulo + " - " + this.cd_menu.toString();
      this.infoTexto =
        descricao + this.cd_tabela
          ? `\n\nTabela vinculada: ${this.cd_tabela}`
          : "";

      this.infoDialog = true;
      this.showAvisoConfig = true;
    },

    pushFormContext() {
      this.formStack.push({
        cd_menu: this.cd_menu,
        atributosForm: JSON.parse(JSON.stringify(this.atributosForm || [])),
        gridMeta: JSON.parse(JSON.stringify(this.gridMeta || [])),
        // importante: CLONAR para não manter referência
        formData: JSON.parse(JSON.stringify(this.formData || {})),
        modoCRUD: this.modoCRUD,
        // qualquer outro estado que seu bootstrap troca
      });
    },

    abrirFiltroSelecao() {
      this.dialogFiltroSelecao = true;
    },

    async limparFiltroSelecao() {
      const full = await this.getRowsFullFromSession();
      this.rows = Array.isArray(full) ? full : [];

      // opcional: também limpa filtros internos do devextreme (se houver)
      const grid = this.$refs.grid?.instance;
      if (grid) {
        grid.clearFilter();
        grid.clearSelection?.();
        grid.refresh();
      }
    },

    traduzCampoFiltroParaGrid(fieldTecnico) {
      if (!fieldTecnico) return fieldTecnico;

      const menu = this.cdMenu || this.cd_menu || 0;
      const key = `campos_grid_meta_${menu}`;

      let meta = [];
      try {
        meta = JSON.parse(sessionStorage.getItem(key) || "[]");
      } catch (e) {
        return fieldTecnico;
      }

      // procura nm_atributo -> nm_atributo_consulta
      const found = meta.find(
        m =>
          String(m.nm_atributo || "").toLowerCase() ===
          String(fieldTecnico).toLowerCase()
      );

      return found?.nm_atributo_consulta || fieldTecnico;
    },

    async onAplicouFiltroSelecao({ keyField, keys }) {
      const fieldTecnico = String(keyField || "").trim();
      const values = Array.isArray(keys) ? keys : [];

      // 🔁 traduz campo técnico -> campo da grid
      const fieldGrid = this.traduzCampoFiltroParaGrid(fieldTecnico);

      //console.log('[Filtro] técnico:', fieldTecnico, '-> grid:', fieldGrid, 'values:', values)

      // pega FULL do sessionStorage
      const full = await this.getRowsFullFromSession();

      // sem filtro → volta tudo
      if (!fieldGrid || values.length === 0) {
        this.rows = Array.isArray(full) ? full : [];
        return;
      }

      // detecta tipo pelo dado real da grid
      const sample = full?.[0]?.[fieldGrid];

      let normalized = values;
      if (typeof sample === "number") {
        normalized = values.map(v => Number(v)).filter(v => !Number.isNaN(v));
      } else {
        normalized = values.map(v => String(v));
      }

      const set = new Set(normalized);

      this.rows = (Array.isArray(full) ? full : []).filter(r => {
        const v = r?.[fieldGrid];
        if (typeof sample === "number") return set.has(Number(v));
        return set.has(String(v));
      });
    },

    //
    abrirPesquisaCampo(campo) {
      if (!campo || Number(campo.cd_menu_pesquisa || 0) <= 0) return;

      this.campoLookupAtivo = campo;
      this.cdMenuAnteriorLookup = Number(localStorage.cd_menu || 0);

      // título (ajuste se seu payload traz outro nome)
      this.tituloLookup =
        campo.nm_titulo_pesquisa ||
        campo.ds_titulo_pesquisa ||
        campo.ds_rotulo ||
        "Pesquisa";

      // muda o menu ativo para o lookup
      localStorage.cd_menu = Number(campo.cd_menu_pesquisa);

      this.showLookup = true;
    },

    abrirPesquisa(attr) {
      console.log("Abrir Pesquisa - 0", attr);

      if (!attr || Number(attr.cd_menu_pesquisa || 0) <= 0) return;

      this.campoLookupAtivo = attr;
      this.ultimoSelecionadoLookup = null;

      this.pushFormContext(); // 👈 salva o pai antes de entrar no “filho”

      this.cdMenuAnteriorLookup = Number(localStorage.cd_menu || 0);

      this.tituloLookup =
        attr.nm_titulo_pesquisa ||
        attr.ds_titulo_pesquisa ||
        this.labelCampo(attr) ||
        "Pesquisa";

      console.log("Abrir Pesquisa - 1", attr, this.tituloLookup);

      // tenta setar o menu (se o browser bloquear storage, não tem problema pois passamos por props também)
      try {
        localStorage.cd_menu = Number(attr.cd_menu_pesquisa);
      } catch (e) {}

      this.showLookup = true;
    },

    onSelecionouLookup(plain) {
      console.log("PAI - plain - retorno", plain);

      this.$emit("selecionou", plain);
      this.showLookup = false;

      // aqui você injeta no form de inclusão/edição
      //this.registroSelecionado = plain
      //

      this.ultimoSelecionadoLookup = plain;

      //
      // ✅ chama a rotina que aplica e fecha
      this.fecharLookup();
      //
    },

    aplicarRetornoLookup(dados) {
      if (!dados || typeof dados !== "object") return;

      const meta = this.metaCampos || [];
      if (!Array.isArray(meta) || meta.length === 0) return;

      // mapa normalizado do retorno (caption ou nome técnico)
      const mapaDados = {};
      Object.keys(dados).forEach(k => {
        mapaDados[this.normaliza(k)] = dados[k];
      });

      meta.forEach(m => {
        if (!m || !m.nm_atributo) return;
        if (String(m.ic_retorno_atributo || "").toUpperCase() !== "S") return;

        const candidatos = [
          m.nm_atributo,
          m.nm_atributo_consulta,
          m.nm_atributo_lookup,
          m.nm_titulo_menu_atributo,
          m.ds_atributo,
        ].filter(Boolean);

        let valorEncontrado;

        for (const c of candidatos) {
          const key = this.normaliza(c);
          if (mapaDados[key] !== undefined) {
            valorEncontrado = mapaDados[key];
            break;
          }
        }

        //console.log('Valor Encontrado: ', valorEncontrado);

        if (valorEncontrado !== undefined) {
          this.$set(this.formData, m.nm_atributo, valorEncontrado);
        }
      });

      // se você tiver essas rotinas no UnicoFormEspecial, ótimo:
      if (typeof this.calcularCampos === "function") this.calcularCampos();
      if (typeof this.persistirDraft === "function") this.persistirDraft();
    },

    popFormContext() {
      const ctx = this.formStack.pop();
      if (!ctx) return;

      this.cd_menu = ctx.cd_menu;
      this.atributosForm = ctx.atributosForm;
      this.gridMeta = ctx.gridMeta;
      this.formData = ctx.formData;
      this.modoCRUD = ctx.modoCRUD;
    },

    descricaoLookup(attr) {
      if (!attr) return "";

      const fd = this.formData || {};

      const record = this.record || {};

      const campoChave = attr.cd_chave_retorno || attr.nm_atributo;
      const descKeyInterna = `__lookup_desc__${attr.nm_atributo ||
        campoChave ||
        "x"}`;

      // 1) prioridade: descrição interna (vem do retorno do lookup)
      if (
        fd[descKeyInterna] !== undefined &&
        fd[descKeyInterna] !== null &&
        String(fd[descKeyInterna]).trim() !== ""
      ) {
        return fd[descKeyInterna];
      }

      // 2) fallback: tenta pelos campos do meta
      const candidatos = [
        attr.nm_campo_mostra_combo_box,
        attr.nm_atributo_lookup,
        attr.nm_atributo_consulta,
        attr.nm_atributo,
      ].filter(Boolean);

      for (const k of candidatos) {
        // console.log('Descrição Lookup - 1', fd[k])

        if (
          fd[k] !== undefined &&
          fd[k] !== null &&
          String(fd[k]).trim() !== ""
        )
          return fd[k];
      }

      //
      //for (const k of candidatos) {
      //  if (record[k] !== undefined && record[k] !== null && String(record[k]).trim() !== '') return record[k]
      // }
      // ✅ no NOVO, não herdar descrição do record anterior
      if (this.formMode !== "I") {
        for (const k of candidatos) {
          if (
            record[k] !== undefined &&
            record[k] !== null &&
            String(record[k]).trim() !== ""
          )
            return record[k];
        }
      }

      // 3) fallback pelo META (retorno 'S' e nm_/ds_)
      const meta = Array.isArray(this.metaCampos) ? this.metaCampos : [];
      const candidatosMeta = meta
        .filter(m => String(m?.ic_retorno_atributo || "").toUpperCase() === "S")
        .map(m => m?.nm_atributo)
        .filter(
          nm =>
            nm &&
            nm !== campoChave &&
            (nm.startsWith("nm_") || nm.startsWith("ds_"))
        );

      for (const nm of candidatosMeta) {
        if (fd[nm] != null && String(fd[nm]).trim() !== "")
          return String(fd[nm]);
      }

      return "";
    },

    fecharLookup() {
      this.showLookup = false;
      this.$emit("fechar");

      try {
        localStorage.cd_menu = Number(this.cdMenuAnteriorLookup || 0);
      } catch (_) {}

      const attr = this.campoLookupAtivo;

      console.log("Fechar Lookup - 1", attr);

      //if (!attr) return

      const cdMenuPesquisa = Number(attr.cd_menu_pesquisa || 0);

      //console.log('cdMenuPesquisa => ', cdMenuPesquisa, ' attr => ', attr);

      let sel = this.ultimoSelecionadoLookup;

      //if (!sel) return

      // ✅ primeiro restaura o contexto do pai
      this.popFormContext();
      //

      console.log("Registro Traduzido ", sel, this.traduzRegistroSelecionado);

      // normaliza
      const selTec = this.traduzRegistroSelecionado
        ? this.traduzRegistroSelecionado(sel, cdMenuPesquisa)
        : sel;

      this.aplicarRetornoLookup(selTec);

      // ----- descrição genérica (sem depender do meta) -----
      const campoChaveTec = attr.cd_chave_retorno || attr.nm_atributo;
      const descKeyInterna = `__lookup_desc__${attr.nm_atributo ||
        campoChaveTec ||
        "x"}`;

      // 1) Preferências explícitas do próprio attr (se existirem e tiverem valor)
      const preferidos = [
        attr.nm_campo_mostra_combo_box,
        attr.nm_atributo_lookup,
        attr.nm_atributo_consulta,
      ].filter(Boolean);

      const campoChamador =
        attr.nm_campo_mostra_combo_box ||
        attr.nm_atributo_consulta ||
        attr.nm_atributo_lookup ||
        attr.nm_atributo;

      if (preferidos.length === 0) {
        // ✅ fallback: usa o campo que chamou a pesquisa
        const v = this.formData?.[campoChamador] ?? selTec?.[campoChamador];
        const desc = v != null ? String(v).trim() : "";
        if (desc) this.$set(this.formData, descKeyInterna, desc);
        //return
      }

      let desc = "";

      for (const k of preferidos) {
        const v =
          (selTec && selTec[k] != null ? selTec[k] : null) ??
          (this.formData && this.formData[k] != null ? this.formData[k] : null);

        if (v != null && String(v).trim() !== "") {
          desc = String(v).trim();
          break;
        }
      }

      // 2) Se não achou, pega o PRIMEIRO campo do meta marcado como retorno 'S' que seja nm_/ds_ (e não a chave)

      if (!desc) {
        const meta = Array.isArray(this.metaCampos) ? this.metaCampos : [];
        const candidatosMeta = meta
          .filter(
            m => String(m?.ic_retorno_atributo || "").toUpperCase() === "S"
          )
          //.map(m => m?.nm_atributo_consulta)
          .map(m => m?.nm_atributo)
          .filter(
            nm =>
              nm &&
              nm !== campoChaveTec &&
              (nm.startsWith("nm_") || nm.startsWith("ds_"))
          );

        for (const nm of candidatosMeta) {
          const v =
            (selTec && selTec[nm] != null ? selTec[nm] : null) ??
            (this.formData && this.formData[nm] != null
              ? this.formData[nm]
              : null);

          if (v != null && String(v).trim() !== "") {
            desc = String(v).trim();
            break;
          }
        }
      }

      if (!desc && selTec && typeof selTec === "object") {
        const blacklist = new Set(
          [campoChaveTec, attr.nm_atributo, attr.cd_chave_retorno, "id"].filter(
            Boolean
          )
        );

        for (const k of Object.keys(selTec)) {
          if (blacklist.has(k)) continue;
          const v = selTec[k];
          if (typeof v === "string" && v.trim() !== "") {
            desc = v.trim();
            break;
          }
        }
      }

      // 3) grava a descrição interna (é isso que o q-input vai mostrar)
      if (desc) {
        this.$set(this.formData, descKeyInterna, desc);
        if (this.record) this.$set(this.record, descKeyInterna, desc);

        // ✅ faz o input "da tela chamadora" ter o nm_/ds_ preenchido
        //if (attr.nm_atributo_consulta) {
        //  this.$set(this.formData, attr.nm_atributo_consulta, desc)
        //  if (this.record) this.$set(this.record, attr.nm_atributo_consulta, desc)
        // }

        const campoTextoTec =
          attr.nm_atributo_lookup || // geralmente nm_/ds_ técnico
          attr.nm_campo_mostra_combo_box || // se existir e for técnico
          null;

        if (campoTextoTec) {
          this.$set(this.formData, campoTextoTec, desc);
          if (this.record) this.$set(this.record, campoTextoTec, desc);
        }
      }

      // tenta achar um texto "bom" no retorno: primeiro string não vazia e que não seja a chave
      /*
let descGenerica = ''

if (selTec && typeof selTec === 'object') {
  for (const k of Object.keys(selTec)) {
    if (!k) continue
    if (k === campoChaveTec) continue
    const v = selTec[k]
    if (typeof v === 'string' && v.trim() !== '') {
      descGenerica = v.trim()
      break
    }
  }
}

// grava a descrição genérica no formData (para o input usar sempre)
if (descGenerica) {
  this.$set(this.formData, descKeyInterna, descGenerica)
}
*/

      //console.log('selecionado lookup traduzido => ', selTec);

      // código (nm_atributo)
      //this.$set(this.formData, attr.nm_atributo, selTec[attr.nm_atributo] ?? this.formData[attr.nm_atributo]);

      /* ================================
     1️⃣ CHAVE (ID)
     ================================ */

      const campoChave = attr.cd_chave_retorno || attr.nm_atributo;
      const valorChave = selTec[campoChave] ?? selTec.id ?? null;

      //console.log('campoChave => ', campoChave);
      //console.log('valorChave => ', valorChave);

      if (campoChave && valorChave != null) {
        this.$set(this.formData, campoChave, valorChave);
      }

      /* ================================
     2️⃣ TEXTO / DESCRIÇÃO
     ================================ */
      const campoDescricao =
        attr.nm_campo_mostra_combo_box ||
        attr.nm_atributo_consulta || // ✅ MUITO importante na pesquisa dinâmica
        attr.nm_atributo_lookup ||
        "";

      const valorDescricao = selTec[campoDescricao] ?? "";

      //console.log('campoDescricao => ', campoDescricao);
      //console.log('valorDescricao => ', valorDescricao);

      if (campoDescricao && valorDescricao) {
        this.$set(this.formData, campoDescricao, valorDescricao);
      }

      /* ================================
     3️⃣ LIMPEZA
     ================================ */

      this.campoLookupAtivo = null;
      this.ultimoSelecionadoLookup = null;

      console.log("DESCKEY:", descKeyInterna);
      console.log("FD DESCKEY VAL:", this.formData?.[descKeyInterna]);
      console.log("REC DESCKEY VAL:", this.record?.[descKeyInterna]);
      console.log(
        "nm_atributo_consulta:",
        attr.nm_atributo_consulta,
        "VAL:",
        this.formData?.[attr.nm_atributo_consulta]
      );
    },

    //
    async onSelectionChangedGrid(e) {
      // e.selectedRowsData é um array com os registros completos
      this.registrosSelecionados = e.selectedRowsData || [];
      //

      // se o click já está sendo tratado, não entra aqui
      if (this._rowClickLock) return;
      //

      // pega a última selecionada (ou a primeira)
      const row = e?.selectedRowsData?.[e.selectedRowsData.length - 1];

      if (!row) return;

      const keyAtual =
        this.keyName && typeof row[this.keyName] !== "undefined"
          ? row[this.keyName]
          : typeof row.id !== "undefined"
          ? row.id
          : null;

      // marca dedup (porque quase sempre veio logo após um clique)
      this._dedupRowClick = { key: keyAtual, ts: Date.now() };

      // evita loop caso o onRowClick altere seleção internamente
      if (this._syncSelecionando) return;
      this._syncSelecionando = true;

      try {
        // chama o mesmo fluxo do clique na linha
        await this.onRowClickPrincipal({ data: row, row: { data: row } });
        //
      } finally {
        this.$nextTick(() => (this._syncSelecionando = false));
      }
    },

    onSelectionChangedGridOld(e) {
      // e.selectedRowsData é um array com os registros completos
      this.registrosSelecionados = e.selectedRowsData || [];
      //

      // pega a chave pelo seu keyName/id
      const keyField = this.keyName || this.id || "id";

      this.cd_chave_registro_local = e.selectedRowsData
        ? Number(e.selectedRowsData[keyField] || 0)
        : 0;

      // se você quiser só as chaves, pode usar e.selectedRowKeys
      // this.registrosSelecionados = e.selectedRowKeys || []
      // console.log('selecionados => ', this.registrosSelecionados)
    },

    onSelectionChangedPrincipal(e) {
      // e.selectedRowsData sempre vem do DevExtreme
      const selecionados = e && e.selectedRowsData ? e.selectedRowsData : [];

      this.registrosSelecionados = selecionados;

      // e.selectedRowsData é o que importa
      const data =
        e && e.selectedRowsData && e.selectedRowsData.length
          ? e.selectedRowsData[e.selectedRowsData.length - 1]
          : null;

      if (!data) return;
      this.gravarRegistroSelecionado(data); // ✅ reutiliza a mesma gravação
    },

    gravarRegistroSelecionado(data) {
      const cdMenu = Number(localStorage.cd_menu || this.cd_menu_entrada || 0);

      // transforma em plain pra evitar JSON quebrar
      const plain = {};
      Object.keys(data || {}).forEach(k => {
        const v = data[k];
        if (v === null || v === undefined) return (plain[k] = v);
        const t = typeof v;
        if (t === "string" || t === "number" || t === "boolean")
          return (plain[k] = v);
        try {
          plain[k] = JSON.parse(JSON.stringify(v));
        } catch (err) {
          plain[k] = String(v);
        }
      });

      sessionStorage.setItem("registro_selecionado", JSON.stringify(plain));

      if (cdMenu)
        sessionStorage.setItem(
          `registro_selecionado_${cdMenu}`,
          JSON.stringify(plain)
        );
    },

    selecionarERetornarOld(rows) {
      console.log("Selecionar e Retornar ->", rows);

      const row = rows;
      if (!row) {
        console.warn("Sem e.row.data no evento", rows);
        return;
      }

      console.log("ROW SELECIONADA ->", row);

      this.gravarRegistroSelecionado(row);

      console.log("EMIT selecionou");
      this.$emit("selecionou", row);

      console.log("EMIT fechar");
      this.$emit("fechar");
    },

    onSelecionarRegistroPesquisa(t, registro) {
      try {
        // exemplo: qual campo está sendo pesquisado agora
        const ctx = this.campoPesquisaAtual || {};
        const nmCodigo = ctx.nmCampoCodigo; // ex: 'cd_produto'
        const nmDesc = ctx.nmCampoDesc; // ex: 'nm_produto'

        if (!nmCodigo) {
          console.warn("Sem campoPesquisaAtual definido");
          return;
        }

        // tenta achar o código e a descrição no registro retornado
        // (você pode ajustar heurísticas conforme seu backend)
        const code =
          registro[nmCodigo] ??
          registro.id ??
          (Array.isArray(registro.id) ? registro.id[0] : undefined);

        // descrição: tenta nm_* / ds_* / Descrição / Nome
        const desc =
          registro[nmDesc] ??
          registro[`ds_${nmCodigo.replace(/^cd_/, "")}`] ??
          registro["Descrição"] ??
          registro["Descricao"] ??
          registro["Nome"] ??
          "";

        // aplica no form do pai
        this.formData = this.formData || {};
        this.$set(this.formData, nmCodigo, code != null ? String(code) : "");
        if (nmDesc) this.$set(this.formData, nmDesc, desc ? String(desc) : "");

        // fecha a tab/modal filha
        this.onFecharTabFilha(t);
        //
      } catch (e) {
        console.error("onSelecionarRegistroPesquisa erro:", e);
      }
    },

    onOptionChanged(e) {
      if (!e || !e.fullName) return;

      // captura mudanças de sort

      if (
        e.fullName.includes("sortOrder") ||
        e.fullName.includes("sortIndex")
      ) {
        this.$nextTick(() => {
          const grid = this.$refs.grid && this.$refs.grid.instance;
          if (!grid) return;

          const scrollable = grid.getScrollable && grid.getScrollable();

          // vai para o topo (isso funciona em qualquer versão)
          if (scrollable && scrollable.scrollTo) {
            scrollable.scrollTo({ top: 0 });
          }

          // opcional: “foca” no primeiro registro visível sem quebrar
          const first = grid.getVisibleRows && grid.getVisibleRows()[0];
          if (first && first.key != null && grid.navigateToRow) {
            grid.navigateToRow(first.key);

            // só chama se existir (evita o TypeError)
            if (typeof grid.scrollToRow === "function") {
              grid.scrollToRow(first.key);
            } else if (
              scrollable &&
              typeof scrollable.scrollToElement === "function" &&
              typeof grid.getRowIndexByKey === "function" &&
              typeof grid.getRowElement === "function"
            ) {
              const idx = grid.getRowIndexByKey(first.key);
              const el = grid.getRowElement(idx);
              // getRowElement pode vir como array (jQuery-like)
              const node = Array.isArray(el) ? el[0] : el && el[0] ? el[0] : el;
              if (node) scrollable.scrollToElement(node);
            }
          }
        });
      }

      if (e.name === "columns") {
        this.saveGridConfig();
      }
      //

      if (e.name === "filterValue" || e.name === "columns") {
        const dataGrid = e.component;
        const hasFilter = dataGrid.getCombinedFilter() !== null;
        this.showClearButton = !!hasFilter;

        // força atualização da toolbar
        dataGrid.repaint();
        //
      }
    },

    abrirModalComposicao() {
      // fecha ambos por segurança
      this.dialogModalComposicao = false;
      this.dialogModalGridComposicao = false;
      this._tabAntesModal = this.activeMenuTab || "principal";
      this._estavaEmTabFilha =
        this._tabAntesModal && this._tabAntesModal !== "principal";

      if (
        (!this.registrosSelecionados ||
          this.registrosSelecionados.length === 0) &&
        this.registroSelecionadoPrincipal
      ) {
        this.registrosSelecionados = [this.registroSelecionadoPrincipal];
      }

      // se o menu exigir seleção e não houver nenhum selecionado, avisa

      if (
        this.ic_selecao_registro === "S" &&
        (!this.registrosSelecionados || this.registrosSelecionados.length === 0)
      ) {
        this.$q.notify({
          type: "warning",
          position: "top",
          message:
            "Selecione ao menos um registro na grade antes de continuar.",
        });
        return;
      }

      if (this.cd_form_modal > 0) {
        localStorage.cd_chave_modal = this.registrosSelecionados
          .map(r => r[this.keyName || "id"])
          .join(",");

        if (String(this.ic_grid_modal || "N").toUpperCase() === "S") {
          this.dialogModalGridComposicao = true;
        } else {
          this.dialogModalComposicao = true;
        }
      }
    },

    async onRefreshConsulta() {
      // se existir um "loading", dá pra ligar aqui também, se você tiver
      // this.loading = true

      if (typeof this.consultar === "function") {
        this.consultar();
      } else {
        console.warn("Função consultar() não encontrada no componente.");
      }
    },

    getIcModalPesquisa() {
      // 1) se a prop já veio 'S', continua valendo
      if (this.ic_modal_pesquisa === "S") {
        return "S";
      }

      let temMenuModal = false;
      temMenuModal = this.cd_menu_modal !== 0;

      // se encontrou cd_menu_modal <> 0 → força 'S'

      if (temMenuModal) {
        return "S";
      }

      // fallback: prop ou 'N'
      return this.ic_modal_pesquisa || "N";
    },

    async abrirDashboardDinamico() {
      await this.ensureConsultaCacheLoaded();

      this.returnTo = this.$route.fullPath;

      //console.log('[unicoFormEspecial] abrirDashboardDinamico clicado, rows:',
      //(this.rowsParaDashboard || []).length)

      this.showDashDinamico = true;
    },

    saveGridConfig() {
      //const grid = this.$refs.grid.instance;

      const grid = this.$refs?.grid?.instance;
      if (!grid) return;

      const config = grid.option("columns").map(col => ({
        dataField: col.dataField,
        visible: col.visible,
      }));
      const key = `gridConfig_${this.menu}_${this.usuario}`;
      localStorage.setItem(key, JSON.stringify(config));
    },

    restoreGridConfig() {
      const key = `gridConfig_${this.menu}_${this.usuario}`;
      const saved = localStorage.getItem(key);
      if (saved) {
        const config = JSON.parse(saved);
        //const grid = this.$refs.grid.instance;

        const grid = this.$refs?.grid?.instance;

        if (!grid) return;

        config.forEach(col => {
          grid.columnOption(col.dataField, "visible", col.visible);
        });
      }
    },

    isCampoArquivo(attr) {
      return (
        String(attr.ic_doc_caminho_atributo || "N")
          .trim()
          .toUpperCase() === "S"
      );
    },

    abrirSeletorArquivo(attr) {
      const refName = `file_${attr.nm_atributo}`;
      const ref = this.$refs[refName];

      if (Array.isArray(ref) && ref[0]) {
        ref[0].click();
      } else if (ref) {
        ref.click();
      }
    },
    onFiltroCardsChange() {
      try {
        const grid = this.$refs.grid && this.$refs.grid.instance;
        if (grid && typeof grid.searchByText === "function") {
          grid.searchByText(this.filtroCardsTexto || "");
        }
      } catch (e) {
        // silencioso pra não quebrar tela
      }
    },

    onFiltroCardsClear() {
      this.filtroCardsTexto = "";
      this.onFiltroCardsChange();
    },

    onFileSelected(attr, event) {
      const file = event.target.files && event.target.files[0];
      if (!file) return;

      this.uploadArquivo(attr, file);

      // limpa o input pra permitir subir o mesmo arquivo outra vez, se quiser
      event.target.value = "";
    },

    async uploadArquivo(attr, file) {
      this.uploadErroArquivo = null;
      this.uploadingArquivo = true;

      try {
        const formData = new FormData();
        formData.append("arquivo", file);

        const { data } = await api.post("/upload-arquivo", formData, {
          headers: {
            "Content-Type": "multipart/form-data",
          },
        });

        //console.log('[upload-arquivo] retorno =>', data)

        if (!data || !data.url_publica) {
          throw new Error("Resposta da API sem url_publica");
        }

        const url = data.url_publica;

        // grava a URL no campo do formulário
        if (!this.formData) this.formData = {};

        this.$set(this.formData, attr.nm_atributo, url);

        // opcional: notificação
        this.$q &&
          this.$q.notify({
            type: "positive",
            position: "center",
            message: "Arquivo anexado com sucesso.",
          });
      } catch (err) {
        console.error("[upload-arquivo] erro =>", err);
        this.uploadErroArquivo = err.message || "Erro ao enviar arquivo";

        this.$q &&
          this.$q.notify({
            type: "negative",
            position: "center",
            message: "Erro ao anexar arquivo.",
          });
      } finally {
        this.uploadingArquivo = false;
      }
    },

    abrirArquivoAnexo(attr) {
      if (!this.formData || !attr || !attr.nm_atributo) return;

      const valor = this.formData[attr.nm_atributo];
      if (!valor) return;

      // se já vier URL completa, abre direto
      const url = String(valor);

      window.open(url, "_blank");
    },

    resolverCodigoDocumento(base) {
      if (!base) return 0;

      // 1) Se já vier um número direto
      if (typeof base === "number") return base;

      // 2) Se vier um ARRAY (ex.: [1, "SETUP", 17, "Treinamento"])
      if (Array.isArray(base)) {
        const nums = base.filter(v => typeof v === "number");
        return nums.length ? nums[0] : 0; // pega o primeiro número
      }

      // 3) Se for objeto e tiver id como ARRAY
      if (Array.isArray(base.id)) {
        const nums = base.id.filter(v => typeof v === "number");
        if (nums.length) return nums[0];
      }

      // 4) Se for objeto e tiver id numérico simples
      if (typeof base.id === "number") {
        return base.id;
      }

      // 5) Procura campos numéricos com cara de código
      const candidatos = [];
      Object.keys(base).forEach(k => {
        const val = base[k];
        if (
          typeof val === "number" &&
          /(^id$|^cd_|c[óo]digo)/i.test(k) // id, cd_*, Código*
        ) {
          candidatos.push(val);
        }
      });

      if (candidatos.length) return candidatos[0];

      return 0;
    },

    resolveCdParametro(row) {
      const fromFiltro = Number(
        row?.cd_parametro ?? row?.cd_parametro_filtro ?? 0
      );
      const fromMenu = Number(this.cd_parametro_menu ?? 0);

      if (fromFiltro > 0) return fromFiltro;
      if (fromMenu > 0) return fromMenu;

      return 1; // ou 0, dependendo da sua regra
    },

    async executarProcesso(row) {
      if (!row) return;

      // 1) Descobre usuário atual (mesma lógica que você usa em outros lugares)
      const cd_usuario = localStorage.cd_usuario || 0; //this._getUsuarioId

      // 2) Datas – pego dos campos que você já usa no payload principal.
      //    Ajuste os nomes se na sua tela for outro (dataInicial/dataFinal, etc.).

      const dt_inicial =
        this.dt_inicial || this.data_inicial || this.dataInicial || null;

      const dt_final =
        this.dt_final || this.data_final || this.dataFinal || null;

      //console.log('Perído: ', dt_inicial, dt_final);

      // 3) Chave do documento = PK da grid principal
      let cd_documento = 0;

      // base = registro selecionado na grid principal
      const base =
        this.registroSelecionadoPrincipal || this.registroSelecionado || null;

      // 1) tenta extrair do registro selecionado
      if (base) {
        cd_documento = this.resolverCodigoDocumento(base);
      }

      // 2) fallback: tenta no próprio row do processo

      if (!cd_documento && row) {
        cd_documento =
          this.resolverCodigoDocumento(row.cd_documento) ||
          this.resolverCodigoDocumento(row.Documento) ||
          0;
      }

      //  console.log('[processo] base registro =>', base);
      //  console.log('[processo] cd_documento =>', cd_documento);

      // 3) Monta o JSON exatamente como a proc @json espera

      const payloadExec = [
        {
          ic_json_parametro: "S",
          cd_processo: row.cd_processo || row.Processo || 0,
          cd_documento: cd_documento,
          //cd_parametro: row.cd_parametro || this.cd_parametro_menu || 0,
          cd_parametro: this.resolveCdParametro(row),
          cd_usuario,
          dt_inicial,
          dt_final,
        },
      ];

      //console.log('[processo] payloadExec =>', payloadExec)

      try {
        // chama diretamente a procedure de geração de processos
        const { data } = await api.post(
          "/exec/pr_api_geracao_processo_sistema",
          payloadExec
        );

        //console.log('[processo] retorno =>', data)

        if (this.$q) {
          this.$q.notify({
            type: "positive",
            position: "center",
            message: "Processo executado com sucesso.",
            classes: "my-notify",
          });
        }
      } catch (err) {
        console.error("[processo] erro =>", err);
        if (err.response) {
          console.error("[processo] status:", err.response.status);
          console.error("[processo] body:", err.response.data);
        }
        if (this.$q) {
          this.$q.notify({
            type: "negative",
            position: "center",
            message: "Erro ao executar o processo.",
          });
        }
      }
    },

    //
    async abrirMenuProcessos() {
      if (!this.cd_menu_processo) {
        return;
      }

      const cd_menu = Number(this.cd_menu_processo);
      const cd_usuario = localStorage.cd_usuario || 0; //this._getUsuarioId
      //? this._getUsuarioId()
      //: Number(this.cd_usuario || sessionStorage.getItem('cd_usuario') || 0)

      const payloadExec = [
        {
          ic_json_parametro: "S",
          cd_menu,
          cd_usuario,
        },
      ];

      this.dlgMenuProcessos = true;
      this.menuProcessoLoading = true;
      this.menuProcessoRows = [];

      try {
        // mesma ideia do exec que você já usa:
        const { data } = await api.post(
          "/exec/pr_egis_menu_processo",
          payloadExec
        );

        //console.log('[menu_processo] dados recebidos:', data );

        // Mapeia para Processo / Descritivo

        this.menuProcessoRows = (Array.isArray(data) ? data : []).map(
          (row, idx) => {
            return {
              ...row,
              id: idx + 1,
              processo: row.Processo || row.cd_processo || "",

              descritivo: row.Descritivo || "",
            };
          }
        );

        // mesmas ideias da coluna Ações da grid principal

        const colAcoesProcesso = {
          type: "buttons",
          caption: "Ações",
          width: 110,
          alignment: "center",
          allowSorting: false,
          allowFiltering: false,
          buttons: [
            {
              hint: "Executar processo",
              icon: "copy", // (copy) ícone nativo DevExtreme
              onClick: e => this.executarProcesso(e.row.data),
            },
          ],
        };

        const colProcesso = {
          dataField: "processo",
          caption: "Processo",
        };

        const colDescritivo = {
          dataField: "descritivo",
          caption: "Descritivo",
        };

        this.columnsProcessos = [colAcoesProcesso, colProcesso, colDescritivo];
        //
      } catch (err) {
        console.error("[menu_processo] erro", err);
        this.menuProcessoRows = [];
      } finally {
        this.menuProcessoLoading = false;
      }
    },

    //

    async copiarRegistro(registro) {
      // ✅ normaliza: se vier e.row, usa e.row.data
      const rowData =
        registro?.data && typeof registro.data === "object"
          ? registro.data
          : registro;

      if (!rowData || typeof rowData !== "object") return;

      // (opcional) debug rápido
      // console.log("[COPIAR] registro=", registro);
      // console.log("[COPIAR] rowData=", rowData);

      const pkAttr =
        (
          (this.gridMeta || []).find(
            m =>
              String(m.ic_atributo_chave || "")
                .trim()
                .toUpperCase() === "S"
          ) || {}
        ).nm_atributo ||
        this.keyName ||
        this.id ||
        null;

      const modelo = JSON.parse(JSON.stringify(rowData));

      // remove PK correta
      if (pkAttr && Object.prototype.hasOwnProperty.call(modelo, pkAttr))
        delete modelo[pkAttr];
      if (Object.prototype.hasOwnProperty.call(modelo, "id")) delete modelo.id;

      // zera numeração automática
      if (Array.isArray(this.gridMeta)) {
        this.gridMeta.forEach(attr => {
          const ehAuto =
            String(attr.ic_numeracao_automatica || "").toUpperCase() === "S";
          if (
            ehAuto &&
            attr.nm_atributo &&
            Object.prototype.hasOwnProperty.call(modelo, attr.nm_atributo)
          ) {
            modelo[attr.nm_atributo] = null;
          }
        });
      }

      await this.abrirFormEspecial({
        modo: "I",
        registro: modelo,
        copia: true,
      });

      // garante PK nula no formData
      if (
        pkAttr &&
        this.formData &&
        Object.prototype.hasOwnProperty.call(this.formData, pkAttr)
      ) {
        this.$set(this.formData, pkAttr, null);
      }
      if (
        this.formData &&
        Object.prototype.hasOwnProperty.call(this.formData, "id")
      ) {
        this.$set(this.formData, "id", null);
      }

      await this.$nextTick();
    },

    montarPayloadPesquisa() {
      const ic_cliente = this.gridMeta?.[0]?.ic_cliente || "N";
      const cd_cliente =
        localStorage.cd_cliente ||
        Number(sessionStorage.getItem("cd_cliente")) ||
        0;

      //
      const base = {
        cd_parametro: 0,
        cd_menu: this.cd_menu,
        cd_usuario: this.cd_usuario || localStorage.cd_usuario || 0,
        ...(ic_cliente === "S" && cd_cliente > 0 ? { cd_cliente } : {}),
      };

      const filtrosObj = {};

      this.filtros.forEach(f => {
        // nome do campo que a procedure espera
        const key = f.nm_campo_chave_lookup || f.nm_campo;

        //console.log('key = atributo para o filtro -->', key);

        // valor digitado / selecionado
        let v = f.valor ?? f[f.nm_campo];

        // se for lookup { value, label }, pega só o value
        if (v && typeof v === "object" && "value" in v) {
          v = v.value;
        }

        // ignora vazios
        if (v !== null && v !== "" && typeof v !== "undefined") {
          filtrosObj[key] = v;
        }
      });

      const payload = [{ ...base, ...filtrosObj }];

      //console.log('payload da consulta dos filtros:', payload);
      return payload;
    },

    // Campos pertencentes a um cd_tabsheet específico
    getCamposTabsheet(cd_tabsheet) {
      const cd = Number(cd_tabsheet || 0);
      return (this.gridMeta || []).filter(
        r => Number(r.cd_tabsheet || 0) === cd
      );
    },

    // Texto bonitinho do label de cada campo

    labelCampoTabsheet(attr) {
      return (
        attr.nm_atributo_consulta ||
        attr.nm_edit_label ||
        attr.ds_atributo ||
        attr.nm_titulo_menu_atributo ||
        attr.nm_atributo
      );
    },

    // === Constrói Tabsheets a partir do gridMeta ===
    buildTabsheetsFromMeta(meta) {
      // Garante que sempre vamos trabalhar com um array
      const arr = Array.isArray(meta) ? meta : meta ? [meta] : [];

      // Se não vier nada do back, zera as tabs

      if (!arr.length) {
        this.tabsheets = [
          {
            key: "dados",
            label: "Dados",
            cd_tabsheet: 1,
            fields: [],
          },
          {
            key: "mapa",
            label: "Atributos",
            cd_tabsheet: -1,
            fields: [],
          },
        ];

        this.activeTabsheet = "dados";
        return;
      }

      // Agrupa atributos por cd_tabsheet
      const grupos = {};

      arr.forEach(r => {
        // <-- AGORA CORRETO
        const cd = Number(r.cd_tabsheet || 0);
        const nm = String(r.nm_tabsheet || "").trim() || "Dados";

        if (!grupos[cd]) {
          grupos[cd] = {
            key: cd === 0 ? "dados" : `tab_${cd}`,
            label: nm,
            cd_tabsheet: cd,
            fields: [],
          };
        }

        grupos[cd].fields.push(r);
      });

      // Ordena pelos códigos de aba
      let tabs = Object.values(grupos).sort(
        (a, b) => a.cd_tabsheet - b.cd_tabsheet
      );

      // Garante que exista uma aba "Dados" (caso tudo venha com cd_tabsheet != 1)

      /*
  if (!tabs.find(t => t.key === 'dados')) {
    const primeira = tabs[0]
    tabs.unshift({
      key: 'dados',
      label: 'Dados',
      cd_tabsheet: primeira ? primeira.cd_tabsheet : 1,
      fields: primeira ? primeira.fields : []
    })
  }
  */

      // Aba extra "Mapa de Atributos" no final
      tabs.push({
        key: "mapa",
        label: "Mapa de Atributos",
        cd_tabsheet: -1,
        fields: [],
      });

      this.tabsheets = tabs;

      // Se a aba ativa atual não existir mais, volta pra primeira
      if (!tabs.find(t => t.key === this.activeTabsheet)) {
        this.activeTabsheet = tabs[0].key;
      }
    },

    // Constrói as linhas da Grid "Mapa de Atributos" a partir da gridMeta
    _buildMapaRowsFromMeta(meta) {
      const arr = Array.isArray(meta) ? meta : [];

      const rows = arr.map((r, idx) => {
        // ordem: tenta nu_ordem / qt_ordem_atributo, senão índice

        const ordem = Number(
          r.nu_ordem || r.qt_ordem_atributo || r.qt_ordem || idx + 1
        );

        const codigo = Number(r.cd_atributo || 0);
        const atributo = String(r.nm_atributo || "").trim();

        const descricao = String(
          r.nm_atributo_consulta ||
            r.ds_atributo ||
            r.nm_titulo_menu_atributo ||
            atributo
        ).trim();

        return { ordem, codigo, atributo, descricao };
      });

      // ordena pela ordem (se vier 0, joga lá pro fim)
      rows.sort((a, b) => (a.ordem || 999999) - (b.ordem || 999999));

      return rows;
    },

    async carregarCatalogoRelatorios() {
      try {
        this.relatoriosDisponiveis = await getCatalogoRelatorio({
          cd_menu: this.cd_menu,
          cd_usuario: this.cd_usuario,
        });
      } catch (e) {
        console.error("Catálogo relatório erro", e);
      }
    },

    // === HELPERS GENÉRICOS ===
    getGridRows() {
      // tenta descobrir onde estão as linhas atuais do grid
      if (Array.isArray(this.rows)) return this.rows;
      if (Array.isArray(this.dataSource)) return this.dataSource;
      if (this.gridData && Array.isArray(this.gridData)) return this.gridData;
      return [];
    },

    async refreshGrid() {
      // tenta as rotinas mais comuns para recarregar
      if (typeof this.carregarGrid === "function") return this.carregarGrid();
      if (typeof this.loadRows === "function") return this.loadRows();
      if (typeof this.reload === "function") return this.reload();
      // devextreme dxDataGrid via ref? tenta refresh:
      if (
        this.$refs &&
        this.$refs.dxGrid &&
        typeof this.$refs.dxGrid.refresh === "function"
      ) {
        return this.$refs.dxGrid.refresh();
      }
    },

    async onGerarRelatorio() {
      try {
        const payload = {
          cd_menu: this.cd_menu,
          cd_usuario: this.cd_usuario,
          cd_relatorio: this.relatorioSelecionado, // se você selecionar em um combo
          filtros: this.filtros || {}, // opcional
        };

        const dados = await gerarRelatorioPadrao(payload);

        // você pode reaproveitar os dados pra exportar/mostrar/abrir PDF
        // Ex.: gerar PDF com os dados retornados:

        await gerarPdfRelatorio({
          cd_menu: this.cd_menu,
          cd_usuario: this.cd_usuario,
          dados,
        });
      } catch (e) {
        console.error("Relatório erro", e);
        this.$q &&
          this.$q.notify({
            type: "negative",
            position: "center",
            message: "Erro ao gerar relatório.",
          });
      }
    },

    montarRegistroNovo() {
      // Se você tem this.columns (DevExtreme) já carregadas:
      const cols = (this.columns || []).map(c => c.dataField).filter(Boolean);
      const registro = {};
      cols.forEach(f => {
        registro[f] = null;
      });

      // valores padrão (se precisar)
      if (this.cd_cliente_padrao) registro.cd_cliente = this.cd_cliente_padrao;
      registro.dt_cadastro = new Date().toISOString().slice(0, 10);

      return registro;
    },

    async onNovoRegistro() {
      try {
        const novo = this.montarRegistroNovo();

        // Monte o payload conforme seu backend espera.
        // Exemplo comum: { cd_menu, cd_usuario, operacao: 'INSERT', registro }
        const payload = {
          cd_menu: this.cd_menu,
          cd_usuario: this.cd_usuario,
          operacao: "INSERT",
          registro: novo,
        };

        await salvarDadosForm(payload);

        this.$q &&
          this.$q.notify({
            type: "positive",
            position: "center",
            message: "Registro incluído.",
          });

        // Recarrega o grid
        typeof this.carregarGrid === "function"
          ? await this.carregarGrid()
          : this.reload && this.reload();
      } catch (e) {
        console.error("Inclusão erro", e);
        this.$q &&
          this.$q.notify({
            type: "negative",
            position: "center",
            message: "Erro ao incluir registro.",
          });
      }
    },

    scrollDown(qual, cdMenu) {
      // decide o container de scroll
      let refEl = null;
      if (qual === "principal") {
        refEl = this.$refs.scrollShell;
      } else if (qual === "det" && this.$refs["scrollShellDet_" + cdMenu]) {
        // quando v-for com ref, o Vue devolve um array
        const arr = this.$refs["scrollShellDet_" + cdMenu];
        refEl = Array.isArray(arr) ? arr[0] : arr;
      }
      if (!refEl) return;

      // rolar um “bloco” de linhas
      try {
        refEl.scrollBy({ top: 400, left: 0, behavior: "smooth" });
      } catch (_) {
        // fallback para browsers sem scrollBy options
        refEl.scrollTop = (refEl.scrollTop || 0) + 400;
      }
    },

    recalcularAlturasGrid() {
      const viewport = window.innerHeight || 0;
      const shell = this.$refs && this.$refs.scrollShell;

      if (!viewport || !shell) return;

      const shellTop = shell.getBoundingClientRect().top || 0;
      const bottomGap = 12; // respiro inferior

      // altura total disponível para o "bloco" da grid (container)
      const total = Math.floor(viewport - shellTop - bottomGap);

      const maxDinamico = Math.max(this.gridAlturaMax || 0, total);
      this.gridAlturaMax = maxDinamico;

      const totalClamped = Math.max(
        this.gridAlturaMin,
        //Math.min(this.gridAlturaMax, total)
        Math.min(maxDinamico, total)
      );

      if (this.gridAutoFit) {
        this.gridAlturaAtual = totalClamped; // só no auto-fit
        this.gridAlturaPadrao = totalClamped;
      }
      //this.gridAlturaAtual = totalClamped;
      //this.gridAlturaPadrao = totalClamped;

      this.$nextTick(() => this.aplicarAlturaGrid());

      /*
      // Agora desconta o que existe acima da tabela (legenda/tabs/etc)
      const topEl = this.$refs && this.$refs.gridTop;
      const topH = topEl ? topEl.offsetHeight : 0;

      // altura útil real do DataGrid
      const body = Math.max(180, totalClamped - topH);

      this.gridBodyHeight = body;

  // 🔥 IMPORTANTE: quando usa virtual/infinite e altura dinâmica,
  // o DevExtreme precisa recalcular dimensões para renderizar as linhas
  this.$nextTick(() => {
    const gridCmp = this.$refs && this.$refs.grid;
    const grid = gridCmp && gridCmp.instance;
    if (!grid) return;
    // 2 ticks pra garantir que o DOM já aplicou a altura
    setTimeout(() => {
      try {
        grid.updateDimensions();
        // opcional: se ainda tiver falha em alguns casos
        // grid.repaint();
      } catch (e) {}
    }, 0);
  });
  */

      this.agendarUpdateGrid();
    },

    definirAlturaInicialGrid() {
      this.$nextTick(() => this.recalcularAlturasGrid());
    },

    ajustarAlturaTela() {
      if (!this.gridAutoFit) return; // se está manual, não mexe!
      this.$nextTick(() => this.recalcularAlturasGrid());
    },

    resetarAlturaGrid() {
      const alvo = this.gridAlturaPadrao || this.gridAlturaMin;
      this.gridAutoFit = false;
      this.gridAlturaAtual = alvo;
      this.$nextTick(() => this.aplicarAlturaGrid());
    },

    setFiltroFilho(cdMenu, val) {
      if (!this.filhos[cdMenu]) {
        // garante o slot antes de setar (Vue 2 precisa de $set p/ reatividade nova chave)
        this.$set(this.filhos, cdMenu, {
          meta: [],
          columns: [],
          rows: [],
          keyName: null,
          filtro: "",
        });
      }
      this.$set(this.filhos[cdMenu], "filtro", val);
    },

    // ========== ABAS DE DETALHE (NOVO) ==========

    montarAbasDetalhe() {
      // 1) Tenta sessionStorage.tab_menu
      let tabMenu = [];
      try {
        tabMenu = JSON.parse(sessionStorage.getItem("tab_menu") || "[]");
      } catch (e) {
        tabMenu = [];
      }

      // 2) Se vazio, tenta no payload que você já carregou no componente

      if (!Array.isArray(tabMenu) || tabMenu.length === 0) {
        const possiveis = [
          this.payload, // se você usa this.payload
          this.payloadPrincipal, // se você salvou assim
          this.gridMetaPayload, // qualquer outro nome que você já use
          this.$data && this.$data.payload_padrao_formulario, // fallback
        ].filter(Boolean);

        for (const p of possiveis) {
          const arr = p && p.tab_menu;
          if (Array.isArray(arr) && arr.length) {
            tabMenu = arr;
            break;
          }
        }
      }

      // 3) Normaliza (se ainda não for array, vira array vazio)
      if (!Array.isArray(tabMenu)) tabMenu = [];

      // 4) Mapeia para a estrutura de abas (seu payload: nm_tabsheet_menu / nm_menu_titulo)
      const novasTabs = tabMenu.map(t => {
        const cd = Number(t.cd_menu_detalhe || t.cd_menu); // prioridade cd_menu_detalhe
        const label = t.nm_tabsheet_menu || t.nm_menu_titulo || `Itens ${cd}`;

        if (!this.filhos[cd]) {
          this.$set(this.filhos, cd, {
            meta: [],
            columns: [],
            rows: [],
            keyName: null,
            filtro: "",
          });
        }

        return {
          key: `det_${cd}`,
          label,
          cd_menu: cd,
          nm_campo_fk: t.nm_campo_fk || null, // <- se existir no payload
          disabled: true, // habilita após selecionar a linha do pai
        };
      });

      // 5) Seta tudo de uma vez (reativo)
      this.tabsDetalhe = novasTabs;
      //

      // DEBUG opcional
      // console.log('tabsDetalhe ->', this.tabsDetalhe);
    },

    // ao clicar numa linha da PRINCIPAL
    //

    // ao clicar numa linha da PRINCIPAL

    async onRowClickPrincipal(e) {
      // ===== anti "pisca": evita dupla execução (rowClick + selectionChanged) =====
      const keyAtual =
        e && typeof e.key !== "undefined"
          ? e.key
          : e &&
            e.data &&
            this.keyName &&
            typeof e.data[this.keyName] !== "undefined"
          ? e.data[this.keyName]
          : e && e.data && typeof e.data.id !== "undefined"
          ? e.data.id
          : null;

      const agora = Date.now();
      if (
        this._dedupRowClick &&
        this._dedupRowClick.key === keyAtual &&
        agora - this._dedupRowClick.ts < 250
      ) {
        return;
      }
      this._dedupRowClick = { key: keyAtual, ts: agora };
      // ==========================================================================

      // trava reentrância no mesmo ciclo de render
      if (this._rowClickLock) return;
      this._rowClickLock = true;

      try {
        const data = e && (e.data || e.row?.data) ? e.data || e.row.data : null;

        // (linha acima evita repetir e.data||e.row.data)
        // se seu lint reclamar, troque por:
        // const data = e && (e.data || e.row?.data) ? (e.data || e.row.data) : null;

        const cdMenu = Number(
          localStorage.cd_menu || this.cd_menu_entrada || 0
        );
        if (!data) return;

        // garante o "registro pai" sempre
        this.registroSelecionado = data || null;
        this.registroSelecionadoPrincipal = data || null;

        const row = data || {};
        const cd_menu =
          localStorage.cd_menu || sessionStorage.getItem("cd_menu");

        // ====== quando exige seleção por checkbox: clique vira seleção ======
        if (this.ic_selecao_registro === "S") {
          const grid = this.$refs?.grid?.instance;
          if (grid && typeof grid.selectRows === "function") {
            // single: limpa e marca a clicada
            if ((this.selectionMode || "single") === "single") {
              if (typeof grid.clearSelection === "function")
                grid.clearSelection();
              grid.selectRows([keyAtual], false);
            } else {
              // multiple: toggle
              const keys =
                typeof grid.getSelectedRowKeys === "function"
                  ? grid.getSelectedRowKeys() || []
                  : [];
              const isSel = keys.includes(keyAtual);
              if (isSel && typeof grid.deselectRows === "function") {
                grid.deselectRows([keyAtual]);
              } else {
                grid.selectRows([keyAtual], true);
              }
            }

            // sincroniza array local
            this.$nextTick(() => {
              try {
                this.registrosSelecionados =
                  typeof grid.getSelectedRowsData === "function"
                    ? grid.getSelectedRowsData() || []
                    : data
                    ? [data]
                    : [];
              } catch (_) {
                this.registrosSelecionados = data ? [data] : [];
              }
            });
          } else {
            // fallback se grid não tiver instance
            this.registrosSelecionados = data ? [data] : [];
          }
        } else {
          // sem modo seleção: mantém um único registro como "selecionado"
          this.registrosSelecionados = data ? [data] : [];
        }
        // ================================================================

        // ---- seu bloco "plain" e sessionStorage (mantido) ----
        const plain = {};
        Object.keys(data).forEach(k => {
          const v = data[k];
          if (v === null || v === undefined) {
            plain[k] = v;
            return;
          }
          const t = typeof v;
          if (t === "string" || t === "number" || t === "boolean") {
            plain[k] = v;
            return;
          }
          try {
            plain[k] = JSON.parse(JSON.stringify(v));
          } catch (err) {
            plain[k] = String(v);
          }
        });

        try {
          sessionStorage.setItem("registro_selecionado", JSON.stringify(plain));
          if (cdMenu) {
            sessionStorage.setItem(
              `registro_selecionado_${cdMenu}`,
              JSON.stringify(plain)
            );
          }
        } catch (err) {
          console.warn(
            "Falha ao gravar registro selecionado no sessionStorage:",
            err
          );
        }

        // ---- sua lógica de PK/ID (mantida) ----
        let pkPai =
          this.keyName && row[this.keyName] !== undefined
            ? this.keyName
            : this.keyName || "id";

        let id = e && typeof e.key !== "undefined" ? e.key : null;

        if (id === null || id === undefined) {
          if (pkPai && Object.prototype.hasOwnProperty.call(data, pkPai)) {
            const v = data[pkPai];
            if (v !== null && v !== undefined) id = v;
          }
        }

        if (id === null || id === undefined) {
          if (data.id !== undefined && data.id !== null) id = data.id;
          else if (data.ID !== undefined && data.ID !== null) id = data.ID;
        }

        if (id === null || id === undefined) {
          const chaveMatch = Object.keys(data).find(k =>
            /(^id$|^cd_|_id$)/i.test(k)
          );
          if (chaveMatch) id = row[chaveMatch];
        }

        this.cd_chave_registro_local = id;
        this.paiSelecionadoId = id;
        this.idPaiDetalhe = id;

        // ---- descKey (mantido) ----
        let descKey = null;
        try {
          const meta = Array.isArray(this.gridMeta)
            ? this.gridMeta
            : JSON.parse(sessionStorage.getItem("campos_grid_meta") || "[]");

          const visiveis = (meta || []).filter(c => c.ic_mostra_grid === "S");
          const prefer = [
            "descr",
            "descrição",
            "descricao",
            "nome",
            "ds_",
            "nm_",
          ];

          const porTitulo = visiveis.find(c =>
            prefer.some(p =>
              (c.nm_titulo_menu_atributo || "").toLowerCase().includes(p)
            )
          );
          const porNome = visiveis.find(c =>
            prefer.some(p =>
              (c.nm_atributo || c.nm_atributo_consulta || "")
                .toLowerCase()
                .includes(p)
            )
          );
          const primeiraNaoPk = visiveis.find(
            c => (c.nm_atributo || c.nm_atributo_consulta) !== pkPai
          );

          descKey =
            (porTitulo &&
              (porTitulo.nm_atributo || porTitulo.nm_atributo_consulta)) ||
            (porNome &&
              (porNome.nm_atributo || porNome.nm_atributo_consulta)) ||
            (primeiraNaoPk &&
              (primeiraNaoPk.nm_atributo ||
                primeiraNaoPk.nm_atributo_consulta)) ||
            null;
        } catch (_) {}

        this.idPaiDetalhe = this.paiSelecionadoId;
        this.paiSelecionadoTexto = descKey ? data[descKey] || "" : "";

        // ---- habilitar abas (mantido) ----
        this.tabsDetalhe = this.tabsDetalhe.map(t => ({
          ...t,
          disabled: false,
        }));

        // ---- recarregar aba atual se necessário (mantido) ----
        if (this.abaAtiva !== "principal") {
          const t = this.tabsDetalhe.find(x => x.key === this.abaAtiva);
          if (t) this.consultarFilho(t);
        }
      } finally {
        // ✅ IMPORTANTÍSSIMO: libera o lock, senão trava tudo após 1 clique
        this.$nextTick(() => {
          this._rowClickLock = false;
        });
      }
    },

    //

    // carrega META do filho (uma vez por cd_menu)

    async carregarMetaFilho(tab) {
      const cd_usuario = Number(
        this.cd_usuario || sessionStorage.getItem("cd_usuario") || 0
      );

      if (!tab || !tab.cd_menu) return;

      // se já tem, pula
      const slot = this.filhos[tab.cd_menu];
      if (slot && Array.isArray(slot.meta) && slot.meta.length > 0) {
        this.resolverFkFilho(tab);
        return;
      }

      const payload = {
        cd_parametro: 1,
        cd_form: localStorage.cd_form,
        cd_menu: Number(tab.cd_menu),
        nm_tabela_origem: "",
        cd_usuario,
      };

      //const { data } = await api.post("/payload-tabela", payload); // mesmo endpoint que você já usa
      const { data } = await payloadTabela(payload);

      //
      const meta = Array.isArray(data) ? data : [];

      // monta columns (repetindo seu padrão da principal)

      // === PK do filho: pode ser composta ===
      const pks = (meta || []).filter(
        m => String(m.ic_atributo_chave || "").toUpperCase() === "S"
      );

      const keyList = pks
        .map(m => m.nm_atributo || m.nm_atributo_consulta)
        .filter(Boolean);

      // mantém compatibilidade: string se for 1 campo, array se for >1
      const keyExpr = keyList.length <= 1 ? keyList[0] || "id" : keyList;

      // === FK do filho: prioriza ic_chave_estrangeira === 'S', senão faz heurística ===
      let fkCampo = null;
      const fkFromMeta = (meta || []).find(
        m => String(m.ic_chave_estrangeira || "").toUpperCase() === "S"
      );
      if (fkFromMeta) {
        fkCampo = fkFromMeta.nm_atributo || fkFromMeta.nm_atributo_consulta;
      }
      if (!fkCampo) {
        // fallback: heurística baseada na PK do pai
        const pkPai = (this.keyName || "id").toString().toLowerCase();
        const cand = (meta || []).filter(
          c => String(c.ic_atributo_chave || "").toUpperCase() !== "S"
        );
        fkCampo =
          cand.find(
            c =>
              (c.nm_atributo || c.nm_atributo_consulta || "").toLowerCase() ===
              pkPai
          )?.nm_atributo ||
          cand.find(c =>
            (c.nm_atributo || c.nm_atributo_consulta || "")
              .toLowerCase()
              .includes(pkPai.replace(/^cd_/, ""))
          )?.nm_atributo ||
          cand.find(c => {
            const n = (
              c.nm_atributo ||
              c.nm_atributo_consulta ||
              ""
            ).toLowerCase();
            return (
              n.startsWith("cd_") || n.endsWith("_id") || n.includes("_cd_")
            );
          })?.nm_atributo ||
          this.keyName ||
          "id";
      }

      // monta columns SEM exemplo (vamos revalidar após a 1ª consulta)

      var columns = (meta || [])
        .filter(function(c) {
          return c.ic_mostra_grid === "S";
        })
        .sort(function(a, b) {
          return (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0);
        })
        .map(function(c) {
          const df = c.nm_atributo || c.nm_atributo_consulta;
          return {
            //dataField: c.nm_atributo || c.nm_atributo_consulta,
            dataField: df,
            caption:
              c.nm_titulo_menu_atributo ||
              c.nm_atributo_consulta ||
              c.nm_atributo,
            format: c.formato_coluna || undefined,
            alignment:
              ["currency", "number", "percent", "fixedPoint"].indexOf(
                c.formato_coluna
              ) >= 0
                ? "right"
                : "left",
            width: c.largura || undefined,
            visible: df === "linhaGridColor" ? false : true,
          };
        });

      // grava no slot do filho
      this.$set(this.filhos, tab.cd_menu, {
        ...(this.filhos[tab.cd_menu] || {}),
        meta,
        columns,
        keyExpr, // <<<<<< usa no template
        keyName: keyExpr, // mantém seu campo antigo, se alguém usa
        filtro:
          (this.filhos[tab.cd_menu] && this.filhos[tab.cd_menu].filtro) || "",
      });

      // anota no próprio tab (útil na consulta e no "novo")
      tab._pk_list = keyList;
      tab._pk = Array.isArray(keyExpr) ? keyExpr[0] : keyExpr;
      tab._fk = fkCampo;

      // resolve dinamicamente a FK do filho com base na meta e na PK do pai
      this.resolverFkFilho(tab);
      //
    },

    onRowPreparedPrincipal(e) {
      // só linhas de dados
      if (!e || e.rowType !== "data" || !e.data) return;

      // ✅ se o grid está preparando a linha por causa de seleção, NÃO mexe no DOM
      //if (e.isSelected) return;

      let rawColor = null;

      // 1) tenta pegar a primeira cor da acoesGridColor
      const cores = this.getAcoesGridCores(e.data.acoesGridColor);

      if (cores && cores.length) {
        const c0 = cores[0] || {};
        rawColor = (c0.cor || c0.nm_cor || "").trim();
      }

      // 2) se não tiver cor em acoesGridColor, usa linhaGridColor como fallback
      if (!rawColor && e.data.linhaGridColor != null) {
        rawColor = String(e.data.linhaGridColor).trim();
      }

      if (!rawColor) return;

      const cor = String(rawColor).trim();
      if (!cor) return;

      // normaliza o elemento da linha
      let rowEl = e.rowElement;

      if (Array.isArray(rowEl)) {
        rowEl = rowEl[0];
      } else if (rowEl && rowEl.get && typeof rowEl.get === "function") {
        rowEl = rowEl.get(0);
      }

      if (!rowEl) return;

      // ✅ se a mesma cor já foi aplicada nesta linha, não refaz (evita blink)
      const flag = `__uic_cor_${cor}`;
      if (rowEl.dataset && rowEl.dataset[flag] === "1") return;

      // se mudou a cor, limpa flags antigas (pra não acumular)
      if (rowEl.dataset) {
        Object.keys(rowEl.dataset).forEach(k => {
          if (k.startsWith("__uic_cor_")) delete rowEl.dataset[k];
        });
        rowEl.dataset[flag] = "1";
      }

      // pega TODOS os <td> da linha
      const tds = rowEl.querySelectorAll("td");
      if (!tds || !tds.length) return;

      const isQuasarColor = /^[a-z]+-\d+$/i.test(cor);

      const limparBgClasses = el => {
        if (!el || !el.className) return;
        el.className = el.className
          .split(" ")
          .filter(c => c && !c.startsWith("bg-"))
          .join(" ");
      };

      // 1) limpa bg- do <tr> e zera background
      limparBgClasses(rowEl);

      // rowEl.style.backgroundColor = "";

      // 2) limpa bg- e background de TODOS os <td>
      tds.forEach(td => {
        limparBgClasses(td);
        //td.style.backgroundColor = "";
      });

      // 3) aplica cor APENAS a partir da 2ª coluna (índice 1 em diante)

      if (isQuasarColor) {
        const bgClass = `bg-${cor}`;
        tds.forEach((td, index) => {
          if (index === 0) {
            // primeira coluna (Legenda) SEM cor de fundo
            // se quiser garantir branco:
            td.style.backgroundColor = "#ffffff";
            return;
          }
          td.classList.add(bgClass);
        });
      } else {
        // cor CSS normal (#ff0, rgb(), etc.)
        tds.forEach((td, index) => {
          if (index === 0) {
            td.style.backgroundColor = "#ffffff";
            return;
          }
          td.style.backgroundColor = cor;
        });
      }
    },

    // Descobre dinamicamente o campo FK do filho comparando com a PK do pai

    resolverFkFilho(tab) {
      if (!tab) return;
      if (tab._fk) return; // já resolvida

      if (tab.nm_campo_fk) {
        tab._fk = tab.nm_campo_fk;
        return;
      }

      // PK do pai já descoberta no seu fluxo
      const pkPai = (this.keyName || "id").toString().toLowerCase();

      const slot = this.filhos[tab.cd_menu] || {};
      const metaFilho = Array.isArray(slot.meta) ? slot.meta : [];

      // 1) candidatos: todos campos do filho que NÃO são PK do filho
      //    e que parecem chave (começam com 'cd_' ou terminam com '_id' etc.)
      const candidatos = metaFilho.filter(c => {
        const nome = (c.nm_atributo || c.nm_atributo_consulta || "").toString();
        const isPkFilho =
          String(c.ic_atributo_chave || "").toUpperCase() === "S";
        const nomeLow = nome.toLowerCase();
        const temCaraDeChave =
          nomeLow.startsWith("cd_") ||
          nomeLow.endsWith("_id") ||
          nomeLow.includes("_cd_");
        return (
          !isPkFilho &&
          (temCaraDeChave || nomeLow.includes(pkPai.replace(/^cd_/, "")))
        );
      });

      // 2) priorize os que casam exatamente com a PK do pai
      let escolhido = candidatos.find(
        c =>
          (c.nm_atributo || c.nm_atributo_consulta || "").toLowerCase() ===
          pkPai
      ) ||
        // 3) se não houver, os que CONTÉM o nome da PK do pai (tirando "cd_")
        candidatos.find(c => {
          const nome = (
            c.nm_atributo ||
            c.nm_atributo_consulta ||
            ""
          ).toLowerCase();
          const base = pkPai.replace(/^cd_/, ""); // ex: cd_condicao_pagamento -> condicao_pagamento
          return nome.includes(base);
        }) ||
        // 4) fallback: primeiro candidato com cara de chave
        candidatos[0] || { nm_atributo: this.keyName }; // 5) fallback definitivo: use a PK do pai

      // guarda no tab._fk o nome do campo, usando a mesma regra que você usa nos demais lugares
      tab._fk =
        escolhido.nm_atributo || escolhido.nm_atributo_consulta || this.keyName;
      //
    },

    // consultar itens do filho

    async consultarFilho(tab) {
      if (!tab || !tab.cd_menu) return;

      if (!this.idPaiDetalhe) {
        try {
          const cd_menu = sessionStorage.getItem("cd_menu");
          const salvo = JSON.parse(
            sessionStorage.getItem(`registro_selecionado_${cd_menu}`) ||
              sessionStorage.getItem("registro_selecionado") ||
              "null"
          );
          if (salvo) {
            const id =
              this.keyName && salvo[this.keyName] !== undefined
                ? salvo[this.keyName]
                : salvo.id ??
                  salvo.ID ??
                  (Object.keys(salvo).find(k => /(^id$|^cd_|_id$)/i.test(k)) &&
                    salvo[
                      Object.keys(salvo).find(k => /(^id$|^cd_|_id$)/i.test(k))
                    ]);
            if (id !== undefined && id !== null) this.idPaiDetalhe = id;
          }
        } catch (_) {}
      }

      const cd_usuario = Number(
        this.cd_usuario || sessionStorage.getItem("cd_usuario") || 0
      );

      // garante meta carregada (e tab._pk / tab._fk definidos)
      await this.carregarMetaFilho(tab);

      // FK do filho (pode ter sido ajustada manualmente depois do carregarMetaFilho)
      const fkCampo = tab._fk || this.keyName || "id";

      // Filtro livre digitado no input do detalhe
      const filtroLivre = (this.filhos[tab.cd_menu].filtro || "").trim();

      // >>> Se a principal envia período/filial/outros parâmetros, recupere daqui:
      // pegue do mesmo lugar que a principal pega (exemplos de chaves comuns; ajuste aos seus nomes reais)

      const paramsExtras = {};

      try {
        const p = JSON.parse(
          sessionStorage.getItem("parametros_pesquisa") || "{}"
        );
        Object.assign(paramsExtras, p);
      } catch (e) {}

      // Monte o body igual ao da principal, apenas mudando cd_menu e acrescentando a FK do pai

      const body = [
        {
          cd_parametro: 1,
          cd_menu: Number(tab.cd_menu),
          cd_usuario,
          filtro: filtroLivre,
          [fkCampo]: this.idPaiDetalhe,
          ...paramsExtras,
        },
      ];

      // DEBUG opcional
      // console.log('consulta FILHO ->', body);
      //const payload = this.montarPayloadPesquisa();

      const { data } = await api.post("/menu-pesquisa", body);

      const rows = Array.isArray(data) ? data : [];

      // DevExtreme exige que TODOS os campos da PK composta existam nas linhas:
      // se o backend não retorna a FK, injeta com o valor do pai (não muda persistência – só a grid)
      if (Array.isArray(tab._pk_list) && tab._pk_list.length > 1) {
        rows.forEach(r => {
          if (fkCampo && (r[fkCampo] === undefined || r[fkCampo] === null)) {
            r[fkCampo] = this.idPaiDetalhe;
          }
        });
      }

      // Realinhar dataField das colunas com base no primeiro row
      var exemplo = rows && rows.length ? rows[0] : null;
      var metaFilho = this.filhos[tab.cd_menu].meta || [];
      var columnsFix = metaFilho
        .filter(function(c) {
          return c.ic_mostra_grid === "S";
        })
        .sort(function(a, b) {
          return (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0);
        })
        .map(c => {
          var df = this._resolverDataFieldColuna(c, exemplo);
          return {
            dataField: df,
            caption:
              c.nm_titulo_menu_atributo ||
              c.nm_atributo_consulta ||
              c.nm_atributo ||
              df,
            format: c.formato_coluna || undefined,
            alignment:
              ["currency", "number", "percent", "fixedPoint"].indexOf(
                c.formato_coluna
              ) >= 0
                ? "right"
                : "left",
            width: c.largura || undefined,
            visible: df === "linhaGridColor" ? false : true,
          };
        });

      // mantém seu padrão de sessionStorage
      sessionStorage.setItem(
        `dados_resultado_consulta_detalhe_${tab.cd_menu}`,
        JSON.stringify(rows)
      );
      sessionStorage.setItem(
        `id_pai_detalhe_${tab.cd_menu}`,
        String(this.idPaiDetalhe)
      );

      // atualiza grid do detalhe
      const slot = this.filhos[tab.cd_menu] || {};
      this.$set(this.filhos, tab.cd_menu, { ...slot, rows });
    },

    // Escolhe o dataField certo para a coluna (detalhe) baseado no primeiro row
    _resolverDataFieldColuna(metaCampo, exemploRow) {
      var a = metaCampo || {};
      var cand = [a.nm_atributo, a.nm_atributo_consulta].filter(Boolean);

      // se tiver linha de exemplo, use o primeiro candidato que exista na linha
      if (exemploRow && typeof exemploRow === "object") {
        for (var i = 0; i < cand.length; i++) {
          var k = cand[i];
          if (k && Object.prototype.hasOwnProperty.call(exemploRow, k))
            return k;
          // tenta case-insensitive
          var keyCi = Object.keys(exemploRow).find(function(n) {
            return n.toLowerCase() === String(k).toLowerCase();
          });
          if (keyCi) return keyCi;
        }
      }
      // fallback: nm_atributo
      return a.nm_atributo || a.nm_atributo_consulta || "id";
    },

    // ao trocar de aba
    async trocarAbaSeNecessario() {
      if (this.abaAtiva === "principal") return;
      const t = this.tabsDetalhe.find(x => x.key === this.abaAtiva);
      if (t) await this.consultarFilho(t);
    },

    // abrir modal do filho (reaproveitando sua mesma lógica do pai)

    async abrirFormEspecialFilho({ tab, modo, registro = {} }) {
      if (!tab) return;

      // injeta FK do pai no modelo ao incluir
      if (modo === "I" && this.idPaiDetalhe && tab._fk) {
        registro = { ...registro, [tab._fk]: this.idPaiDetalhe };
      }
      // dica: você pode reaproveitar seu abrirFormEspecial, passando metadados de tab.cd_menu
      // Se você preferir distinguir no backend, use cd_menu=tab.cd_menu e set o pai no modelo
      const modelo = { ...registro };

      // injeta a FK do pai se for inclusão
      if (modo === "I" && this.idPaiDetalhe) {
        // usa a mesma chave detectada como PK do pai
        const fk = this.keyName || "id";
        modelo[fk] = this.idPaiDetalhe;
      }

      // Carrega payload do DETALHE e usa no modal

      const cd_usuario = Number(
        this.cd_usuario || sessionStorage.getItem("cd_usuario") || 0
      );

      const detPayloadReq = {
        cd_parametro: 1,
        cd_form: localStorage.cd_form,
        cd_menu: Number(tab.cd_menu),
        nm_tabela_origem: "",
        cd_usuario,
      };

      const { data: payloadDetalhe } = await api.post(
        "/payload-tabela",
        detPayloadReq
      );

      // truque seguro: salva o payload da principal, troca pelo do detalhe, abre modal e depois restaura

      const backup =
        sessionStorage.getItem("payload_padrao_formulario") || null;
      var backupCdMenu = sessionStorage.getItem("cd_menu");
      sessionStorage.setItem("cd_menu", String(tab.cd_menu)); // << usa menu do DETALHE

      sessionStorage.setItem(
        "payload_padrao_formulario",
        JSON.stringify(payloadDetalhe)
      );
      try {
        this.abrirFormEspecial({ modo: modo === "I" ? "I" : "A", registro }); // reusa seu modal
      } finally {
        if (backup !== null) {
          sessionStorage.setItem("payload_padrao_formulario", backup);
        } else {
          sessionStorage.removeItem("payload_padrao_formulario");
        }

        if (backupCdMenu !== null && backupCdMenu !== undefined) {
          sessionStorage.setItem("cd_menu", backupCdMenu);
        } else {
          sessionStorage.removeItem("cd_menu");
        }
      }

      // chama o mesmo modal que você já usa
      //this.abrirFormEspecial({ modo: (modo === 'I' ? 'I' : 'A'), registro: modelo, cd_menu_detalhe: tab.cd_menu });
      //
    },

    scrollGrid(dir) {
      const shell = this.$refs.scrollShell;
      if (!shell) return;

      const width = shell.clientWidth;
      shell.scrollBy({
        left: dir * width * 0.8, // move 80% da largura visível
        behavior: "smooth",
      });
    },
    scrollGridHorizontal(delta) {
      const shell = this.$refs.scrollShell;
      if (!shell) return;

      shell.scrollBy({
        left: delta,
        behavior: "smooth",
      });
    },
    go(dir) {
      // dir: -1 (volta), 1 (avança)
      const max = 1; // temos 2 painéis: 0 e 1
      let next = this.panelIndex + dir;
      if (next < 0) next = 0;
      if (next > max) next = max;
      if (next === this.panelIndex) return;

      this.panelIndex = next;

      // depois que o slide termina, força a grid a recalcular dimensões
      // (evita "sumir" quando fora de viewport)
      this.$nextTick(() => {
        setTimeout(() => {
          try {
            const inst = this.$refs?.grid?.instance;
            inst?.updateDimensions?.();
            inst?.refresh?.();
          } catch (_) {}
        }, 260); // ligeiramente > transition CSS (250ms)
      });
    },

    scroll(dir) {
      // dir: -1 = filtros, 1 = grid
      const el = this.$refs.viewport;
      if (!el) return;
      const delta = dir * el.clientWidth; // 1 tela
      el.scrollBy({ left: delta, behavior: "smooth" });
    },

    /* ==== Lookup helper (sem getDb; interceptor já cuida) ==== */
    async postLookup(query) {
      //console.log('query dados para api de lookup', query);
      try {
        const { data } = await api.post("/lookup", { query }); // ou '/api/lookup' se esse for o seu prefixo
        return Array.isArray(data) ? data : [];
      } catch (e) {
        //console.error("[lookup] erro", e);
        console.error("[lookup] erro", e?.response || e);
        throw e; // ← melhor deixar estourar pra gente tratar fora
        //return [];
      }
    },

    //

    //async abrirFormEspecial({ modo = "I", registro = {} } = {}) {

    async abrirFormEspecial({ modo = "I", registro = {}, copia = false } = {}) {
      //

      this._tabAntesModal = this.activeMenuTab || "principal";

      this._estavaEmTabFilha =
        this._tabAntesModal && this._tabAntesModal !== "principal";

      // 1) define modo (I/A/E)
      const m = String(modo || "I").toUpperCase();

      this.formMode =
        m === "A" || Number(modo) === 2
          ? "A"
          : m === "E" || m === "D" || Number(modo) === 3
          ? "E"
          : "I";

      // no modo E, travar edição (pra não salvar sem querer)
      this.formSomenteLeitura = this.formMode === "E";

      if (this.formMode === "I") this.dlgKey++;

      this.dlgForm = true;

      // console.log('registros do form ->', registro);

      try {
        // log pra garantir que veio algo
        //console.log('[Form] abrirFormEspecial.modo=', modo, 'registro=', registro);

        await this.runHook("beforeOpenEdit", { modo, registro });

        // 1) define modo
        //this.formMode =
        //  String(modo).toUpperCase() === "A" || Number(modo) === 2 ? "A" : "I";

        // 2) pegue os metadados primeiro (lookups dependem disso)
        this.atributosForm = this.obterAtributosParaForm();
        //

        //console.log('[Form] atributosForm=', this.atributosForm);

        // Monta tabsheets do formulário a partir dos atributos (nm_tabsheet / cd_tabsheet)
        this.buildTabsheetsFromMeta(this.atributosForm);

        // garante que o modal comece na primeira aba "real" (Cadastro, Endereço, Perfil...)
        this.$nextTick(() => {
          const tabs = this.tabsheetsForm; // usa o computed
          this.activeTabsheet = tabs.length ? tabs[0].key : null;
        });

        // se não tiver atributos, monta genérico a partir do registro ou da 1ª linha da grid

        if (!this.atributosForm?.length) {
          const fonte = this.rows?.[0] || registro || {};
          this.atributosForm = Object.keys(fonte).map(k => ({
            nm_atributo: k,
            nm_edit_label: k,
            tipo_coluna: "varchar",
            tipo_input: "text",
          }));
        }

        // 3) base

        this.record = this.record || {};

        //this.formData = this.formData || registro || {};
        this.formData = JSON.parse(JSON.stringify(registro || {}));
        //

        console.log("[Form] abrirFormEspecial.registro=", registro);

        if (this.formMode === "I") {
          // ✅ importante: impede “vazamento” de descrições do registro anterior
          this.record = {};
          //

          const temRegistroBase =
            copia || (registro && Object.keys(registro).length > 0);

          if (temRegistroBase) {
            // ✅ o pulo do gato: alinhar as chaves do registro com o meta do form
            const registroMapeado = this.mapearConsultaParaAtributoRobusto(
              registro,
              this.atributosForm
            );

            // monta vazio + aplica os valores mapeados
            this.formData = Object.assign(
              this.montarRegistroVazio(),
              registroMapeado
            );
          } else {
            this.formData = this.montarRegistroVazio();
          }

          // ✅ remove qualquer __lookup_desc__ que tenha sobrado por acidente
          Object.keys(this.formData).forEach(k => {
            if (k.startsWith("__lookup_desc__")) this.$delete(this.formData, k);
          });

          //  console.log("[Form] formData após montar vazio=", this.formData);

          //
          this.aplicarDataPadraoNosCampos(this.formData, this.atributosForm);
          //

          Object.keys(sessionStorage)
            .filter(k => k.startsWith("fixo_"))
            .forEach(k => {
              const campo = k.replace("fixo_", "");
              const val = sessionStorage.getItem(k);
              if (campo) this.$set(this.formData, campo, val);
            });

          // carrega opções dos selects
          await this.carregarLookupsDiretos();
          //
        } else {
          // ALTERAÇÃO
          // mapeia a linha da grid pro conjunto de atributos
          this.formData = this.mapearConsultaParaAtributoRobusto(
            registro,
            this.atributosForm
          );

          // ✅ aplica data padrão (ic_data_padrao = 'S') apenas no NOVO e se estiver vazio

          if (this.modoCRUD === 1 && Array.isArray(this.atributosForm)) {
            const hoje = toIsoDate(new Date(), true); // YYYY-MM-DD

            this.atributosForm.forEach(a => {
              if (String(a.ic_data_padrao || "N").toUpperCase() !== "S") return;

              const nm = a.nm_atributo;
              if (!nm) return;

              const atual = this.formData[nm];
              if (atual == null || String(atual).trim() === "") {
                this.$set(this.formData, nm, hoje);
              }
            });
          }

          //console.log("[Form] formData após mapear=", this.formData);

          await this.$nextTick();
          await this.syncLookupsFromFormData();

          //

          //await this.resolverDescricoesLookupsNoForm(this.formData, this.atributos);

          // normaliza para string onde necessário (selects)

          for (const a of this.atributosForm || []) {
            if (
              this.temLookupDireto(a) ||
              this.temPesquisaDinamica(a) ||
              this.temListaValor(a)
            ) {
              const v = this.formData[a.nm_atributo];
              if (v !== undefined && v !== null && v !== "") {
                this.$set(this.formData, a.nm_atributo, String(v));
              }
            }
          }

          // 1º: opções
          await this.carregarLookupsDiretos();

          // 2º: descrições (se não vieram da grid)
          await this.preencherFormEdicao(registro);

          //console.log(
          //  "[Form] formData após preencher descrições=",
          //  this.formData
          //);

          //if (this.formData === null || {}) {
          //  this.formData = registro || {};
          // }
        }

        // 4) abre modal

        this.dlgForm = true;
        this.formRenderizou = false;
        this.dialogCadastro = true;

        await this.$nextTick();
        this.montarFormEspecialDinamico?.();
      } catch (e) {
        console.error("Falha ao abrir form especial:", e);
        this.notifyErr("Erro ao abrir formulário.");
      }
    },

    //
    async preencherFormEdicao(registro) {
      const row = registro || {};
      if (!row || !this.atributosForm?.length) return;

      this.record = this.record || {};
      this.formData = this.formData || {};

      for (const attr of this.atributosForm) {
        const nome = attr.nm_atributo;
        const nomeDesc = attr.nm_atributo_consulta;

        // garante que formData já tem o código (mapa robusto já fez isso)
        const code = this.formData[nome];

        // se a descrição veio na grid, usa
        const descFromGrid = nomeDesc ? row[nomeDesc] ?? "" : "";
        if (nomeDesc && descFromGrid) {
          this.$set(this.record, nomeDesc, descFromGrid);
          continue;
        }

        // senão, se é lookup e tem código, busca a descrição
        if (
          (this.temLookupDireto(attr) || this.temPesquisaDinamica(attr)) &&
          code !== "" &&
          code != null
        ) {
          await this.syncLookupDescription(attr, code);
        }
      }
    },

    ensureLookupOption(attr, code, label) {
      try {
        if (!attr || !attr.nm_atributo) return;
        if (code == null || String(code).trim() === "") return;
        if (label == null || String(label).trim() === "") return;

        if (!this.lookupOptions) this.lookupOptions = {};

        const key = attr.nm_atributo; // ex: "cd_produto"
        const opts = Array.isArray(this.lookupOptions[key])
          ? this.lookupOptions[key].slice()
          : [];

        const valueStr = String(code);
        const labelStr = String(label);

        const idx = opts.findIndex(o => String(o.__value) === valueStr);

        if (idx >= 0) {
          // atualiza label se mudou
          opts[idx] = { ...opts[idx], __label: labelStr };
        } else {
          // insere no topo para o select já enxergar
          opts.unshift({ __value: valueStr, __label: labelStr });
        }

        this.$set(this.lookupOptions, key, opts);
      } catch (e) {
        console.warn("[ensureLookupOption] erro:", e);
      }
    },

    //
    deveAbrirPesquisaAutomatica(a, val) {
      // não abre automaticamente em embed, a menos que usuário clique
      if (this.embedMode) return false;

      // se está em alteração e já tem código, não abre
      if (this.modoCRUD === 2 && val != null && String(val).trim() !== "")
        return false;

      return true;
    },

    async resolverDescricoesLookupsNoForm(formData, atributos) {
      try {
        if (!formData || !atributos || !atributos.length) return;

        // Evita tempestade de requests: processa 1 por vez (simples e seguro)
        for (const a of atributos) {
          const nm = a.nm_atributo || "";
          if (!nm.startsWith("cd_")) continue;

          // só para campos que são lookup/pesquisa/lista
          const ehLookup =
            this.temLookupDireto(a) ||
            this.temPesquisaDinamica(a) ||
            this.temListaValor(a);
          if (!ehLookup) continue;

          const cd = formData[nm];
          if (cd == null || String(cd).trim() === "") continue;

          const base = nm.replace(/^cd_/, ""); // cliente, produto, veiculo...
          const nmDesc = `nm_${base}`;
          const dsDesc = `ds_${base}`;

          // se já tem descrição, pula
          if (formData[nmDesc] && String(formData[nmDesc]).trim() !== "")
            continue;
          if (formData[dsDesc] && String(formData[dsDesc]).trim() !== "")
            continue;

          // ✅ aqui chamamos lookup genérico usando o próprio atributo "a"
          // você provavelmente já tem um método que monta payload e chama /api/lookup
          // Vou criar um wrapper: tentar usar um método existente, senão fallback axios
          const desc = await this.buscarDescricaoLookupGenerico(a, cd);

          if (desc && String(desc).trim() !== "") {
            // Prioriza nm_*
            this.$set(formData, nmDesc, String(desc));
            // Mantém record também, se você usa em algum lugar
            this.record = this.record || {};
            this.$set(this.record, nmDesc, String(desc));
          }
        }
      } catch (e) {
        console.warn("[resolverDescricoesLookupsNoForm] erro:", e);
      }
    },

    async buscarDescricaoLookupGenerico(a, valorCd) {
      try {
        // 1) Se você já tem um método pronto, use aqui:
        // if (this.executarLookupDireto) return await this.executarLookupDireto(a, valorCd);

        // 2) Fallback: chamada padrão /api/lookup (AJUSTE o payload conforme seu backend)
        const cd_usuario = String(
          this.cd_usuario || sessionStorage.getItem("cd_usuario") || 0
        );
        const cd_menu = String(
          (this.getCdMenuAtivoParaCrud && this.getCdMenuAtivoParaCrud()) ||
            this.ncd_menu_entrada ||
            this.cd_menu ||
            sessionStorage.getItem("cd_menu") ||
            0
        );

        // 🔧 ajuste os campos conforme seu backend de lookup:
        const payload = [
          {
            cd_usuario,
            cd_menu,
            nm_atributo: a.nm_atributo, // ajuda o back a saber qual lookup
            valor: String(valorCd),
          },
        ];

        const resp = await this.$axios.post(
          "https://egiserp.com.br/api/lookup",
          payload
        );
        const data = resp?.data;

        // Tenta extrair um texto em formatos comuns
        if (Array.isArray(data) && data.length) {
          return (
            data[0]?.nm ||
            data[0]?.descricao ||
            data[0]?.label ||
            data[0]?.text ||
            null
          );
        }
        if (
          data?.resultado &&
          Array.isArray(data.resultado) &&
          data.resultado.length
        ) {
          const r = data.resultado[0];
          return r?.nm || r?.descricao || r?.label || r?.text || null;
        }

        return null;
      } catch (e) {
        console.warn(
          "[buscarDescricaoLookupGenerico] falha:",
          a?.nm_atributo,
          valorCd,
          e
        );
        return null;
      }
    },

    //

    mapearConsultaParaAtributoRobusto(registro, atributos) {
      console.log("Mapa de Registros e Atributos ->", registro, atributos);

      const out = {};

      // ✅ 1) Se veio array (resultado com 1 item), pega o primeiro
      const rowRaw = Array.isArray(registro)
        ? registro[0] || {}
        : registro || {};

      // ✅ 2) Copia para não mexer no objeto reativo do Vue
      const row = { ...rowRaw };

      // ✅ 3) Normaliza id quando vier como chave composta (array)
      if (Array.isArray(row.id)) {
        row.id_composto = row.id.slice();
        const candidato =
          row.id[0] != null
            ? row.id[0]
            : row.id.find(v => v != null && String(v).trim() !== "");
        row.id =
          candidato != null ? Number(candidato) || String(candidato) : null;
      }

      // mapa case-insensitive das chaves do retorno
      const keysLower = Object.keys(row).reduce((acc, k) => {
        acc[String(k).toLowerCase()] = k;
        return acc;
      }, {});

      const get = nome => {
        if (!nome) return undefined;
        const k = keysLower[String(nome).toLowerCase()];
        return k ? row[k] : undefined;
      };

      // helper: vazio?
      const isEmpty = v => v == null || String(v).trim() === "";

      for (const a of atributos || []) {
        const nm = a.nm_atributo; // ex.: cd_produto / dt_emissao
        if (!nm) continue;

        // label mais provável que pode vir no retorno da grid
        const lbl =
          a.nm_titulo_menu_atributo ||
          a.nm_edit_label ||
          a.ds_atributo ||
          a.caption ||
          a.label ||
          a.nm_atributo;

        const tituloCodigo = `Código ${lbl}`;

        // ✅ valor principal (o que alimenta o v-model do campo)
        let val = get(nm) ?? get(tituloCodigo) ?? get(lbl) ?? undefined;

        // === Detecta DATA e normaliza ===
        const rawTipo = String(a.tp_atributo || a.tipo || "").toUpperCase();
        const pareceNomeDeData = /(^dt(_|$))|(^data(_|$))|(_data$)|(_dt$)/i.test(
          nm
        );
        const isDate =
          rawTipo.includes("DATE") ||
          rawTipo === "D" ||
          rawTipo === "DATA" ||
          pareceNomeDeData;

        if (isDate && val != null && !isEmpty(val)) {
          val = toIsoDate(val, true); // 'YYYY-MM-DD'
        }

        // se for select/lookup/lista, garanta string pro componente
        if (
          val != null &&
          (this.temLookupDireto(a) ||
            this.temPesquisaDinamica(a) ||
            this.temListaValor(a))
        ) {
          val = String(val);
        }

        out[nm] = val != null ? val : "";

        // ✅ DESCRIÇÃO DO LOOKUP (DINÂMICO!)
        // o seu renderer usa attr.nm_atributo_consulta dentro de descricaoLookup()
        const kDesc = a.nm_atributo_consulta; // ex.: nm_produto / nm_cliente / ds_veiculo ...
        if (kDesc) {
          // 1) tenta pegar exatamente pela coluna nm_*/ds_* se existir no retorno
          let desc = get(kDesc);

          // 2) fallback: tenta pelo label do atributo (às vezes o retorno vem com "Produto", "Cliente", etc)
          if (isEmpty(desc)) desc = get(lbl);

          // 3) fallback: tenta por "Descrição"/"Descricao"/"Nome"
          if (isEmpty(desc))
            desc = get("Descrição") ?? get("Descricao") ?? get("Nome");

          if (!isEmpty(desc)) {
            // ✅ MUITO IMPORTANTE: isso faz o campo mostrar a descrição no form
            out[kDesc] = String(desc);

            // opcional: mantém record pra outras partes do componente
            this.record = this.record || {};
            this.record[kDesc] = String(desc);
          }
        }
      }

      return out;
    },

    mapearConsultaParaAtributoRobustoOld2(registro, atributos) {
      console.log("Mapa de Registros e Atributos ->", registro, atributos);

      const out = {};

      // ✅ 1) Se veio array (ex.: resultado com 1 item), pega o primeiro objeto
      const rowRaw = Array.isArray(registro)
        ? registro[0] || {}
        : registro || {};

      // ✅ 2) Copia para não mexer no objeto reativo do Vue
      const row = { ...rowRaw };

      // ✅ 3) Normaliza id quando vier como chave composta (array)
      if (Array.isArray(row.id)) {
        row.id_composto = row.id.slice();

        // regra padrão: primeira posição costuma ser a chave do registro
        const candidato =
          row.id[0] != null
            ? row.id[0]
            : row.id.find(v => v != null && String(v).trim() !== "");

        row.id =
          candidato != null ? Number(candidato) || String(candidato) : null;
      }

      const keysLower = Object.keys(row).reduce((acc, k) => {
        acc[k.toLowerCase()] = k;
        return acc;
      }, {});

      const get = nome => {
        if (!nome) return undefined;
        const k = keysLower[String(nome).toLowerCase()];
        return k ? row[k] : undefined;
      };

      const hojeISO = () => {
        const d = new Date();
        const y = d.getFullYear();
        const m = String(d.getMonth() + 1).padStart(2, "0");
        const day = String(d.getDate()).padStart(2, "0");
        return `${y}-${m}-${day}`;
      };

      const isCampoData = (a, nm) => {
        const rawTipo = String(a.tp_atributo || a.tipo || "").toUpperCase();
        const pareceNomeDeData = /(^dt(_|$))|(^data(_|$))|(_data$)|(_dt$)/i.test(
          nm || ""
        );
        return (
          rawTipo.includes("DATE") ||
          rawTipo === "D" ||
          rawTipo === "DATA" ||
          pareceNomeDeData
        );
      };

      // --- Mapeia valores principais (cd_*, campos etc) ---
      for (const a of atributos || []) {
        const nm = a.nm_atributo; // ex.: cd_produto

        const lbl =
          a.nm_atributo_consulta ||
          a.nm_titulo_menu_atributo ||
          a.nm_edit_label ||
          a.ds_atributo ||
          a.nm_atributo;

        const nmDesc = a.nm_atributo_consulta; // às vezes vem como nome de coluna descritiva
        const tituloCodigo = `Código ${lbl}`;

        // tenta pegar valor em múltiplas formas
        let val =
          get(nm) ??
          get(tituloCodigo) ?? // coluna da grid com prefixo "Código ..."
          get(lbl) ?? // às vezes o código está na coluna com o mesmo label
          undefined;

        // normaliza data para yyyy-MM-dd
        if (isCampoData(a, nm) && val != null && String(val).trim() !== "") {
          // usa sua função existente
          val = toIsoDate(val, true);
        }

        // === Detecta se é campo de DATA ===
        const rawTipo = String(a.tp_atributo || a.tipo || "").toUpperCase();
        const pareceNomeDeData = /(^dt(_|$))|(^data(_|$))|(_data$)|(_dt$)/i.test(
          nm
        );
        const isDate =
          rawTipo.includes("DATE") ||
          rawTipo === "D" ||
          rawTipo === "DATA" ||
          pareceNomeDeData;

        if (isDate && val != null) {
          val = toIsoDate(val, true); // normaliza para 'yyyy-MM-dd'
        }

        // se for select (lookup/lista), garanta string
        if (
          val != null &&
          (this.temLookupDireto(a) ||
            this.temPesquisaDinamica(a) ||
            this.temListaValor(a))
        ) {
          val = String(val);
        }

        out[nm] = val != null ? val : "";

        // ✅ descrição (quando existir no retorno)
        // Sem usar "base" inexistente, e gravando nm_* no out quando nm for cd_*
        if (nmDesc) {
          const desc =
            get(nmDesc) ?? get("Descrição") ?? get("Descricao") ?? "";

          if (desc != null && String(desc).trim() !== "") {
            this.record = this.record || {};
            this.record[nmDesc] = String(desc);

            // se o atributo for cd_*, grava nm_* correspondente
            if (nm && nm.startsWith("cd_")) {
              const baseLocal = nm.replace(/^cd_/, "");
              out[`nm_${baseLocal}`] = String(desc);
              this.record[`nm_${baseLocal}`] = String(desc);
            }
          }
        }
      }

      // ✅ auto-popula nm_* (descrição) para campos cd_*
      // padrão: se atributo é cd_xxx e existir coluna "xxx" (texto), salva nm_xxx
      for (const a2 of atributos || []) {
        const nm2 = a2.nm_atributo || "";
        if (!nm2.startsWith("cd_")) continue;

        const base2 = nm2.replace(/^cd_/, ""); // produto, tributacao, etc

        const possiveis2 = [
          `nm_${base2}`,
          `ds_${base2}`,
          base2,
          base2.replace(/_/g, " "),
        ];

        let desc2 = null;

        for (const p of possiveis2) {
          const v = get(p);
          if (v != null && String(v).trim() !== "") {
            desc2 = String(v);
            break;
          }
        }

        // fallback: tenta pelo label do atributo (quando retorno veio com label)
        if (!desc2) {
          const lbl2 =
            a2.nm_atributo_consulta ||
            a2.nm_titulo_menu_atributo ||
            a2.nm_edit_label ||
            a2.ds_atributo ||
            a2.nm_atributo;

          const v2 = get(lbl2);
          if (v2 != null && String(v2).trim() !== "") desc2 = String(v2);
        }

        // fallback específico (grid costuma vir "Produto")
        if (!desc2 && base2 === "produto") {
          const v3 = get("Produto") || get("Descrição") || get("Nome");
          if (v3 != null && String(v3).trim() !== "") desc2 = String(v3);
        }

        if (desc2) {
          // ✅ o mais importante: colocar no out (formData)
          out[`nm_${base2}`] = desc2;

          // ✅ opcional: também em record, se alguma parte do componente usa
          this.record = this.record || {};
          this.record[`nm_${base2}`] = desc2;
        }
      }

      if (
        String(a.ic_data_padrao || "").toUpperCase() === "S" &&
        isCampoData(a, nm)
      ) {
        const atual = out[nm];
        if (atual == null || String(atual).trim() === "") {
          out[nm] = hojeISO();
        }
      }

      //
      return out;
      //
    },

    selecionarERetornar(e) {
      console.log("Estamos aqui ", e);

      // aceita clique em botão da linha OU seleção do grid
      const data =
        (e && e.row && e.row.data) ||
        (e && e.data) ||
        (e && e.selectedRowsData && e.selectedRowsData.length
          ? e.selectedRowsData[e.selectedRowsData.length - 1]
          : null);

      if (!data) {
        if (this.$q && this.$q.notify) {
          this.$q.notify({
            type: "warning",
            position: "center",
            message: "Selecione um registro.",
          });
        }
        return;
      }

      // transforma em objeto simples (evita Observer do Vue quebrar)
      let plain = {};
      try {
        plain = JSON.parse(JSON.stringify(data));
      } catch (err) {
        Object.keys(data || {}).forEach(k => (plain[k] = data[k]));
      }

      // guarda também no sessionStorage (mantém compat com o que você já tem)
      try {
        sessionStorage.setItem("registro_selecionado", JSON.stringify(plain));
        const cdMenu = Number(
          this.cd_menu || this.cd_menu_entrada || this.cd_menu_principal || 0
        );
        if (cdMenu)
          sessionStorage.setItem(
            `registro_selecionado_${cdMenu}`,
            JSON.stringify(plain)
          );
      } catch (err) {}

      // ✅ o principal: avisa o pai que selecionou
      // e o pai decide fechar tab/modal/embed e aplicar no campo
      this.$emit("selecionar", plain);
      this.$emit("selecionou", plain);

      // opcional: se você já usa voltar/fechar em embedMode, dispare também
      // (não quebra, o pai pode ignorar)
      this.$emit("voltar");
      //
      setTimeout(() => this.$emit("fechar"), 0);
    },

    // Dado um SELECT de lookup (nm_lookup_tabela) e o attr.nm_atributo = "cd_empresa",
    // montamos um SELECT filtrado que retorna a "Descricao".

    buildLookupByCodeSQL(attr, code) {
      // remove ORDER BY do select-base
      const base = (attr.nm_lookup_tabela || "")
        .replace(/order\s+by[\s\S]*$/i, "")
        .trim();
      if (!base) return null;

      // detecta se é numérico (ajuste se seu back usa outro naming)
      const isNumber = /(int|numeric|decimal|float|money|number)/i.test(
        attr.nm_datatype || ""
      );
      const codeExpr = isNumber
        ? String(Number(code))
        : `'${String(code).replace(/'/g, "''")}'`;

      // filtra pelo campo-código (nm_atributo)
      const codigoCampo = attr.nm_atributo;
      return `SELECT TOP 1 * FROM (${base}) T WHERE T.${codigoCampo} = ${codeExpr}`;
    },

    async syncLookupDescription(attr, code) {
      try {
        if (!attr || !attr.nm_atributo) return;
        if (code == null || String(code).trim() === "") return;

        // 1) tenta nas opções já carregadas
        const opts = this.lookupOptions?.[attr.nm_atributo] || [];
        const got = opts.find(o => String(o.__value) === String(code));

        if (got) {
          // garante que o select tenha esse item (e label)
          this.ensureLookupOption(attr, code, got.__label || "");

          // se você usa record pra alguma coisa extra, mantém:
          if (attr.nm_atributo_consulta) {
            this.record = this.record || {};
            this.$set(
              this.record,
              attr.nm_atributo_consulta,
              got.__label || ""
            );
          }
          return;
        }

        // 2) busca direto no banco pelo código (top 1)
        const sql = this.buildLookupByCodeSQL(attr, code);
        if (!sql) return;

        const rows = await this.postLookup(sql);
        const row = rows?.[0] || {};

        // tenta pegar descrição em chaves comuns
        const desc =
          row.Descricao ??
          row.DESCRICAO ??
          row.descricao ??
          row.Nome ??
          row.NM ??
          row.nm ??
          "";

        if (desc && String(desc).trim() !== "") {
          // ✅ aqui é o pulo do gato: alimentar options para o q-select mostrar
          this.ensureLookupOption(attr, code, String(desc));

          // opcional: manter record
          if (attr.nm_atributo_consulta) {
            this.record = this.record || {};
            this.$set(this.record, attr.nm_atributo_consulta, String(desc));
          }
        }
      } catch (e) {
        console.warn("[syncLookupDescription] erro:", e);
      }
    },

    async syncLookupsFromFormData() {
      try {
        const attrs = Array.isArray(this.atributosForm)
          ? this.atributosForm
          : [];
        const data = this.formData || {};

        const alvo = attrs.filter(
          a =>
            (this.temLookupDireto(a) ||
              this.temPesquisaDinamica(a) ||
              this.temListaValor(a)) &&
            (a.nm_atributo || "").startsWith("cd_")
        );

        // 1 por vez (mais estável no seu cenário)
        for (const a of alvo) {
          const code = data[a.nm_atributo];
          if (code != null && String(code).trim() !== "") {
            await this.syncLookupDescription(a, code);
          }
        }
      } catch (e) {
        console.warn("[syncLookupsFromFormData] erro:", e);
      }
    },

    async syncLookupDescriptionOld(attr, code) {
      // 1) tenta nas opções já carregadas
      const opts = this.lookupOptions?.[attr.nm_atributo] || [];
      const got = opts.find(o => String(o.__value) === String(code));
      if (got && attr.nm_atributo_consulta) {
        this.$set(this.record, attr.nm_atributo_consulta, got.__label || "");
        return;
      }
      // 2) busca direto no banco
      const sql = this.buildLookupByCodeSQL(attr, code);
      if (!sql) return;

      const rows = await this.postLookup(sql);
      const row = rows[0];
      const desc = row?.Descricao || "";
      if (desc && attr.nm_atributo_consulta) {
        this.$set(this.record, attr.nm_atributo_consulta, String(desc));
      }
    },

    //
    async carregarLookupsDiretos() {
      const attrs = (this.atributosForm || []).filter(a =>
        this.temLookupDireto(a)
      );
      await Promise.all(attrs.map(a => this.carregarLookupDireto(a)));
    },

    async carregarLookupDireto(attr) {
      const rows = await this.postLookup(attr.nm_lookup_tabela);
      const nomeCampo = (attr.nm_atributo || "").toLowerCase();

      const opts = rows.map(r => {
        const vals = Object.values(r || {});
        const code = r[nomeCampo] != null ? r[nomeCampo] : vals[0];
        const label =
          r.Descricao != null ? r.Descricao : vals[1] != null ? vals[1] : code;
        return { __value: String(code), __label: String(label) };
      });

      if (!this.lookupOptions) this.lookupOptions = {};
      this.$set(this.lookupOptions, attr.nm_atributo, opts);
    },

    v2_isReadonly(campo) {
      // consulta/exclusão sempre readonly (igual form-especial)
      if (["consulta", "exclusao"].includes(this.modo)) return true;
      // regra pedida: em NOVO, se ic_edita_cadastro='N' → bloquear
      if (this.modo === "novo" && campo.ic_edita_cadastro === "N") return true;
      // numeracao automática em novo → bloquear
      if (this.modo === "novo" && campo.ic_numeracao_automatica === "S")
        return true;
      return false;
    },
    inputClass(campo) {
      return this.isReadonly(campo) ? "leitura-azul" : "";
    },

    // helpers de meta
    isInclusao() {
      return this.formMode === "I"; // 'I' = inclusão, 'A' = alteração (pelo seu código)
    },
    isChave(attr) {
      return attr.ic_atributo_chave === "S";
    },

    isAutoNum(attr) {
      // cobre as duas grafias que vi no projeto
      return attr.ic_numeracao_automatica === "S";
    },

    // 2.1 visibilidade
    showField(attr) {
      // regra: em INCLUSÃO, se for CHAVE + numeração automática => não mostra
      if (this.isInclusao() && this.isChave(attr))
        //&& this.isAutoNum(attr))
        return false;
      return true;
    },

    // 2.2 readonly + classe azul
    isReadonly(attr) {
      // modo consulta => tudo readonly
      if (this.formSomenteLeitura) return true;

      // INCLUSÃO: trava se meta pedir
      if (this.isInclusao() && attr.ic_edita_cadastro === "N") return true;
      // ALTERAÇÃO: trava se meta não editável
      //if (!this.isInclusao() && attr.ic_editavel === 'N') return true;
      // chaves com auto numeração: sempre readonly (ex.: na alteração)
      if (this.isChave(attr) && this.isAutoNum(attr)) return true;
      return false;
    },

    fieldClass(attr) {
      // classe no componente (q-input/q-select) – pinta o wrapper
      return this.isReadonly(attr) ? "leitura-azul" : "";
    },

    // 2.3 label com "*"

    labelCampo(attr) {
      const base =
        attr.nm_atributo_consulta || attr.ds_atributo || attr.nm_atributo;
      const estrela = this.isAutoNum(attr) ? " *" : "";
      return base + estrela;
    },

    // 2.4 lista de valores
    /* ===== Lista de Valores ===== */
    // 1) tenta pegar direto do attr.Lista_Valor (string ou array)
    // 2) se não tiver, varre o payload em busca de um array "solto" com nm_atributo = do campo
    listaValores(attr) {
      // caso 1: vem dentro do attr
      let l = attr && attr.Lista_Valor;
      if (l) {
        if (typeof l === "string") {
          try {
            l = JSON.parse(l);
          } catch (e) {
            l = [];
          }
        }
        if (Array.isArray(l)) return l;
      }
      // caso 2: vem "solto" no payload (como você mostrou no exemplo)
      const nome = attr && attr.nm_atributo;
      if (!nome) return [];
      try {
        // procura em cada item de atributosForm um campo Lista_Valor (string/array)
        const agregados = [];
        (this.atributosForm || []).forEach(a => {
          let lv = a && a.Lista_Valor;
          if (!lv) return;
          if (typeof lv === "string") {
            try {
              lv = JSON.parse(lv);
            } catch (e) {
              lv = [];
            }
          }
          if (Array.isArray(lv)) {
            lv.forEach(x => {
              if (x && x.nm_atributo === nome) agregados.push(x);
            });
          }
        });
        return agregados;
      } catch (e) {
        return [];
      }
    },

    temListaValor(attr) {
      return this.listaValores(attr).length > 0;
    },

    // 2.5 lookup dinâmico (lupa)
    temPesquisaDinamica(attr) {
      return !!attr.cd_menu_pesquisa && Number(attr.cd_menu_pesquisa) > 0;
    },

    validarCampoDinamico(attr) {
      if (!this.temPesquisaDinamica(attr)) return;
      window.validarCampoDinamico &&
        window.validarCampoDinamico(
          { value: this.formData[attr.nm_atributo] },
          attr.nm_atributo,
          attr.cd_menu_pesquisa
        );
    },

    //

    // 2.6 lookup direto (select vindo do backend)
    /* garanta que você já popula this.lookupOptions[attr.nm_atributo] = [{__value, __label}] */
    temLookupDireto(attr) {
      return !!attr.nm_lookup_tabela && !attr.cd_menu_pesquisa;
    },

    async loadAllLookups() {
      const alvos = (this.payload || []).filter(c => this.temLookupDireto(c));
      await Promise.all(alvos.map(c => this.loadLookup(c)));
    },

    classeAzulBloqueado(campo) {
      const bloquear =
        (this.modo === "novo" && campo.ic_edita_cadastro === "N") ||
        (this.modo === "novo" && campo.ic_numeracao_automatica === "S");
      return bloquear ? "bg-primary text-white" : "";
    },

    isDateField(f) {
      const tipo = (f.ic_tipo || f.tipo || "").toString().toLowerCase();
      return tipo.includes("data") || /^dt_/.test(f.nm_atributo || "");
    },

    inputType(f) {
      // Se você já tem resolvType, mantemos a prioridade
      const base = this.resolvType ? this.resolvType(f) : null;
      if (base) return base;
      // se identificamos que é data, retorna 'date', senão 'text'
      return this.isDateField(f) ? "date" : "text";
    },

    toYMD(d) {
      if (!d) {
        console.warn("Data inválida:", d);
        return "";
      }

      // Se for string no formato "dd/mm/aaaa", converte corretamente
      if (typeof d === "string" && /^\d{2}\/\d{2}\/\d{4}$/.test(d)) {
        const [day, month, year] = d.split("/");
        d = new Date(`${year}-${month}-${day}`);
      } else {
        d = new Date(d);
      }

      if (isNaN(d)) return "";

      //const date = new Date(d);
      //if (isNaN(date)) {
      //  console.warn('Data inválida:', d)
      //return ''
      // }

      const y = d.getFullYear();
      const m = String(d.getMonth() + 1).padStart(2, "0");
      const day = String(d.getDate()).padStart(2, "0");
      return `${y}-${m}-${day}`;
    },

    formatBR(d) {
      const dd = String(d.getDate()).padStart(2, "0");
      const mm = String(d.getMonth() + 1).padStart(2, "0");
      const yyyy = d.getFullYear();
      return `${dd}/${mm}/${yyyy}`;
    },

    preencherDatasDoMes() {
      if (!this.filtros || !this.filtros.length) return;

      const hoje = new Date();
      const inicio = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
      const fim = new Date(hoje.getFullYear(), hoje.getMonth() + 1, 0);

      // escolhe o formato certo para cada filtro

      const valorPara = (f, data) => {
        const tipo = this.resolvType ? this.resolvType(f) : "text";
        return tipo === "date" ? this.toYMD(data) : this.formatBR(data);
      };

      const setIfEmpty = (key, val) => {
        if (!this.filtrosValores) this.filtrosValores = {};
        const v = this.filtrosValores[key];
        // só preenche se estiver vazio/indefinido
        if (v === undefined || v === null || v === "") {
          this.$set(this.filtrosValores, key, val);
        }
      };

      // tenta “dt_inicial / dt_final”
      const fDtIni = this.filtros.find(f =>
        /dt_?inicial/i.test(f.nm_atributo || "")
      );
      const fDtFim = this.filtros.find(f =>
        /dt_?final/i.test(f.nm_atributo || "")
      );

      if (fDtIni) setIfEmpty(fDtIni.nm_atributo, valorPara(fDtIni, inicio));
      if (fDtFim) setIfEmpty(fDtFim.nm_atributo, valorPara(fDtFim, fim));

      // fallback: se não existem campos explícitos inicial/final, aplica no(s) campos de data vazios
      if (!fDtIni && !fDtFim) {
        const datas = this.filtros.filter(this.isDateField);
        if (datas.length) {
          datas.forEach((f, idx) => {
            setIfEmpty(f.nm_atributo, valorPara(f, idx === 0 ? inicio : fim));
          });
        }
      }
    },

    montarFormEspecialDinamico() {
      const mountEl = this.$refs.formEspecialMount;

      if (!mountEl) return;

      // limpa container
      mountEl.innerHTML = "";

      // 1) Se você tiver importado algo como: import { buildFormEspecial } from '@/utils/form-especial'
      //    chame aqui. Como não sei o caminho no seu projeto, também suporte "window.buildFormEspecial"
      const builder =
        typeof this.buildFormEspecial === "function"
          ? this.buildFormEspecial
          : typeof window !== "undefined"
          ? window.buildFormEspecial
          : null;

      if (builder) {
        try {
          // builder(container, atributos, dados, options)
          builder(mountEl, this.atributosForm, this.formData, {
            modo: this.formMode,
            onChange: (campo, valor) => this.$set(this.formData, campo, valor),
          });

          this.formRenderizou = true;
          return;
        } catch (err) {
          console.warn(
            "builder do form especial falhou, usando fallback.",
            err
          );
        }
      }

      // 2) Se não houver builder, ficará no fallback de inputs (já no template)
      this.formRenderizou = false;
      //
    },

    getCdMenuAtivoParaCrud() {
      // ✅ se estou em composição/embed, o menu ativo é o menu entrada atual
      const fromEntrada = Number(
        this.ncd_menu_entrada || this.cd_menu_entrada || 0
      );

      if (fromEntrada > 0) return String(fromEntrada);

      // ✅ fallback para o form normal
      const fromPrincipal = Number(this.cd_menu_principal || 0);
      if (fromPrincipal > 0) return String(fromPrincipal);

      const fromState = Number(this.cd_menu || 0);
      if (fromState > 0) return String(fromState);

      const fromSession = Number(sessionStorage.getItem("cd_menu") || 0);
      if (fromSession > 0) return String(fromSession || 0);

      return localStorage.cd_menu || 0;
      //
    },

    // salvar o CRUD (inclusão/alteração)

    async salvarCRUD(opts) {
      const params = opts || {};

      // 1) registro canônico (o que está no form)
      const registro =
        params.registro != null
          ? params.registro
          : this.formData || this.formulario || this.registroAtual || {};
      //

      const modoIn = params.modo != null ? params.modo : this.modoCRUD; // pode vir 'I' | 'A' | 'E' | 1 | 2 | 3

      function mapModo(m) {
        const s = String(m).toUpperCase();
        if (s === "1" || s === "I" || s === "N" || s === "C") return 1; // Inclusão
        if (s === "2" || s === "A" || s === "U" || s === "ALT" || s === "EDIT")
          return 2; // Alteração
        if (s === "3" || s === "E" || s === "D" || s === "DEL" || s === "EXC")
          return 3; // Exclusão
        return 0;
      }

      let cd_parametro_form = mapModo(modoIn);
      let cd_documento_form = "0";
      let keyVal;

      if (
        cd_parametro_form === "3" &&
        (!registro || !registro[this.keyNameInfer()])
      ) {
        throw new Error("Sem registro indicado para excluir!");
      }

      try {
        //console.log("Salvando CRUD com formData:", this.formData);

        // validação de obrigatórios

        this.salvando = true;

        const obrig = this.atributosForm
          .filter(a => a.ic_obrigatorio === "S")
          .map(a => a.nm_atributo);

        const faltando = obrig.filter(
          c =>
            this.formData[c] === null ||
            this.formData[c] === "" ||
            this.formData[c] === undefined
        );

        if (faltando.length) {
          this.notifyWarn(
            `Preencha os campos obrigatórios: ${faltando.join(", ")}`
          );
          this.salvando = false;
          return;
        }

        // 1) META completo do payload (mesmo que você já usa)

        let meta = Array.isArray(this.gridMeta) ? this.gridMeta : [];

        if (!meta.length) {
          try {
            // fallback só se realmente não existir gridMeta local
            //meta = JSON.parse(sessionStorage.getItem("campos_grid_meta") || "[]");
            const metaKey = `campos_grid_meta_${localStorage.cd_menu ||
              sessionStorage.getItem("cd_menu")}`;
            // tenta pegar meta específica do menu atual
            meta =
              JSON.parse(sessionStorage.getItem(metaKey)) ||
              JSON.parse(sessionStorage.getItem("campos_grid_meta")) ||
              "[]";
          } catch (_) {
            meta = [];
          }
        }

        // 2) Registro que você está salvando (use o que você já tem)
        //    Deixe essas opções na ordem que seu form usa.
        let row = this.formData || {};

        //console.log('Registro a salvar:', row);

        if (!row || typeof row !== "object") row = {};

        // 3) Constrói "dados" usando **nm_atributo** (NOME TÉCNICO)
        const dadosTecnicos = {};
        // percorre o meta para garantir a ordem e nomes corretos

        meta.forEach(m => {
          if (!m || !m.nm_atributo) return;

          // onde esse valor pode estar no objeto da UI
          const candidatos = [
            m.nm_atributo, // já técnico
            m.nm_titulo_menu_atributo, // título do payload
            m.nm_atributo_consulta, // legenda/label da grid
          ].filter(Boolean);

          let valor;

          for (let i = 0; i < candidatos.length; i++) {
            const k = candidatos[i];
            if (k in row) {
              valor = row[k];
              break;
            }
            const alt = Object.keys(row).find(
              kk => kk.toLowerCase() === String(k).toLowerCase()
            );
            if (alt) {
              valor = row[alt];
              break;
            }
          }

          // normalizações (números/currency/datas vazias)
          const tipo = String(m.nm_datatype || "").toLowerCase();
          //

          if (valor === "") valor = null;

          //
          //Date
          if (
            valor != null &&
            (tipo === "date" || tipo === "datetime" || tipo === "shortdate")
          ) {
            // Se vier como string yyyy-mm-dd, separa manualmente
            const isoMatch = /^(\d{4})-(\d{2})-(\d{2})$/.exec(valor);
            if (isoMatch) {
              const [, yyyy, mm, dd] = isoMatch;
              valor = `${yyyy}-${mm}-${dd}`; // já está no formato correto
            } else {
              // fallback para Date
              const d = new Date(valor);
              if (!isNaN(d.getTime())) {
                const yyyy = d.getFullYear();
                const mm = String(d.getMonth() + 1).padStart(2, "0");
                const dd = String(d.getDate()).padStart(2, "0");
                valor = `${yyyy}-${mm}-${dd}`;
              } else {
                valor = null;
              }
            }
          }

          //
          if (valor != null && (tipo === "number" || tipo === "currency")) {
            if (typeof valor === "string") {
              const s = valor
                .replace(/[R$\s]/g, "")
                .replace(/\./g, "")
                .replace(",", "."); // R$ 1.234,56 -> 1234.56
              const n = +s;
              if (!isNaN(n)) valor = n;
            }
          }

          //console.log('Processando atributo:', m.nm_atributo, 'Valor encontrado:', valor);

          // 4) CHAVE PRIMÁRIA correta a partir do payload

          const chaveAttr = (
            meta.find(
              m =>
                String(m.ic_atributo_chave || "")
                  .trim()
                  .toUpperCase() === "S"
            ) || {}
          ).nm_atributo;
          //

          console.log("Atributo chave encontrado:", chaveAttr);
          console.log("Valor da chave no row:", row[chaveAttr]);
          console.log("Payload completo do row:", row);
          console.log("Payload meta:", meta);

          if (chaveAttr && m.nm_atributo === chaveAttr) {
            cd_documento_form = valor || "0";
            keyVal = valor || row[chaveAttr] || undefined;

            // console.log('Valor da chave primária para o payload:', chaveAttr, keyVal, cd_documento_form);

            // se a UI usa "id" (grid), copie para a chave real
            if (!(chaveAttr in dadosTecnicos) && "id" in row)
              dadosTecnicos[chaveAttr] = row.id;
          }

          dadosTecnicos[m.nm_atributo] =
            cd_parametro_form === 3
              ? m.nm_atributo === chaveAttr
                ? valor ?? keyVal ?? ""
                : ""
              : valor == null
              ? ""
              : valor;

          // fim do forEach
        });

        console.log("cd_documento_form:", cd_documento_form);

        //

        // 5) Campos especiais do payload
        //const cd_documento_form = keyVal != null ? String(keyVal) : '0';
        //

        // limpeza de sobras da UI
        delete dadosTecnicos.id;
        delete dadosTecnicos["Código"];
        delete dadosTecnicos["Descricao"];
        delete dadosTecnicos["Descrição"];

        //const nowIso = new Date().toISOString();
        /*
        const now = new Date();

        // formata manualmente no padrão SQL Server: 2024-05-17 10:25:22.000
        const pad = (n) => n.toString().padStart(2, "0");
        const nowIso =
          now.getFullYear() +
          "-" +
          pad(now.getMonth() + 1) +
          "-" +
          pad(now.getDate()) +
          " " +
          pad(now.getHours()) +
          ":" +
          pad(now.getMinutes()) +
          ":" +
          pad(now.getSeconds()) +
          ".000";

        //console.log(nowIso); // ex.: "2024-05-17 10:25:22.000"
        */

        const unico = Object.assign(
          {
            //cd_menu: String(
            //  this.cd_menu_principal || this.cd_menu || sessionStorage.getItem("cd_menu") || 0
            //),
            //Menuj
            cd_menu: this.getCdMenuAtivoParaCrud() || localStorage.cd_menu,
            //
            cd_form: "0",
            cd_parametro_form, // Number(this.modoCRUD), // 1/2/3 conforme sua ação
            cd_usuario: String(
              this.cd_usuario || sessionStorage.getItem("cd_usuario") || 0
            ),
            cd_cliente_form: "0",
            cd_contato_form: "",
            //dt_usuario: nowIso,
            //dt_usuario: formatSQLDateTime(new Date()), // 'YYYY-MM-DD HH:mm:ss.000'
            lookup_formEspecial: {},
            detalhe: [],
            lote: [],
            cd_modulo: "",
            cd_documento_form,
          },

          //--Dados do Registro que será gravado ou atualizado---------------------------
          dadosTecnicos
          //-----------
        );

        if (!unico.cd_menu) {
          unico.cd_menu = this.getCdMenuAtivoParaCrud() || po;
          localStorage.getItem("cd_menu") ||
            sessionStorage.getItem("cd_menu") ||
            "";
        }

        // payload final = array com 1 objeto
        let payload = unico;
        //

        const modo = cd_parametro_form;
        const mapped = await this.runHook("mapPayload", {
          modo,
          registro,
          payload,
        });
        if (mapped) payload = mapped;

        //
        await this.runHook("beforeSave", { modo, registro, payload });
        //

        // debug
        console.log(
          "JSON que vai para a rota -> pr_egis_api_crud_dados_especial :",
          this.getCdMenuAtivoParaCrud(),
          localStorage.cd_menu,
          cd_parametro_form,
          payload,
          dadosTecnicos
        );

        //
        ////
        ///pr_egis_api_crud_dados_especial
        ///

        let response = null;

        try {
          response = await api.post("/api-dados-form", payload, {
            headers: { "Content-Type": "application/json" },
          });

          console.log("registro do response --> ", response);

          // 🔎 1) tenta achar um retorno padrão do banco (se vier ok/mensagem)
          const data = response && response.data ? response.data : null;
          const row0 = Array.isArray(data) ? data[0] : data;

          // Caso sua PR devolva algo tipo: { ok: 0, mensagem: 'Registro já existe.' }
          if (row0 && (row0.ok === 0 || row0.ok === "0")) {
            const msg =
              row0.mensagem || row0.message || "Não foi possível gravar.";
            // se for duplicidade:
            const errNum = String(row0.erro_numero || row0.error_number || "");
            const errSql = String(
              row0.erro_sql || row0.error_message || row0.erro || ""
            );

            if (
              errNum === "2627" ||
              errNum === "2601" ||
              errSql.includes("Cannot insert duplicate key") ||
              errSql.includes("Violation of PRIMARY KEY") ||
              errSql.includes("duplicate key")
            ) {
              this.$q.notify({
                type: "warning",
                message: msg || "Registro já existe.",
              });
              return;
            }

            this.$q.notify({ type: "negative", message: msg });
            return;
          }

          // ✅ sucesso (mantém seu fluxo)
          this.notifyOk(
            this.formMode === "I"
              ? "Registro atualizado com sucesso."
              : "Registro atualizado com sucesso."
          );

          await this.runHook("afterSave", { modo, registro, response });
        } catch (err) {
          // 🔥 2) fallback: quando o backend estoura erro (não vem ok/mensagem)
          const raw =
            (err &&
              err.response &&
              err.response.data &&
              (err.response.data.message || err.response.data.error)) ||
            (err && err.message) ||
            "";

          const msg = String(raw);

          if (
            msg.includes("2627") ||
            msg.includes("2601") ||
            msg.includes("Cannot insert duplicate key") ||
            msg.includes("Violation of PRIMARY KEY") ||
            msg.includes("duplicate key")
          ) {
            this.$q.notify({ type: "warning", message: "Registro já existe." });
            return;
          }

          // seu tratamento genérico de erro (se já tiver um, mantenha)
          this.$q.notify({
            type: "negative",
            message: msg || "Erro ao gravar.",
          });
          // ou: throw err; (se você quiser propagar)
        }

        /*
        let response = null

        response = await api.post("/api-dados-form", payload, {
          headers: { "Content-Type": "application/json" },
        });
        ///

        console.log('registro do response --> ', response );

        this.notifyOk(
          this.formMode === "I"
            ? "Registro atualizado com sucesso."
            : "Registro atualizado com sucesso."
        );

        //
        await this.runHook("afterSave", { modo, registro, response })
        //
        */

        //
        //Fechar o Modal
        this.dlgForm = false;

        if (this.embedMode) {
          this.$emit("voltar"); // ou "fechar" conforme seu fluxo
        }

        // === RECARREGAR A GRID (coloque logo após o POST OK) ===
        try {
          // 1) Reconsultar seus dados do backend (mantém seus nomes)
          if (typeof this.consultar === "function") {
            await this.consultar(); // deve repopular this.rows com os dados mais recentes
          }
        } catch (e) {
          console.warn("Refresh pós-CRUD falhou:", e);
        }

        //
        //this.applyCrudResult({ modo: cd_parametro_form, response, registroLocal: row, meta: this.getMetaAtual() })
        //

        //
        // === pós-CRUD: atualizar grid local (sem consultar tudo) ===

        //
      } catch (e) {
        console.error("Falha ao salvar CRUD:", e);
        this.notifyErr("Erro ao salvar dados do formulário.");
      } finally {
        this.salvando = false;
        this.dialogCadastro = false; // fecha modal depois do refresh
        this.formData = {};
      }
    },

    applyCrudResult({
      modo,
      response,
      registroLocal = null,
      meta = null,
    } = {}) {
      const m = Number(modo || 0); // 1=I, 2=A, 3=E
      if (![1, 2, 3].includes(m)) return;

      const d0 = response?.data?.dados?.[0] || null;
      if (!d0) return;

      const pkField = this.getPkFieldFromMeta(meta);
      if (!pkField) return;

      // Parse do registro vindo do SQL (pode vir string JSON)
      let registroDb = d0.registro ?? null;
      if (typeof registroDb === "string") {
        const s = registroDb.trim();
        if (s.startsWith("{") && s.endsWith("}")) {
          try {
            registroDb = JSON.parse(s);
          } catch (_) {}
        }
      }

      const chave =
        d0.chave ?? registroDb?.[pkField] ?? registroLocal?.[pkField] ?? null;

      // DELETE: remove e sai
      if (m === 3) {
        if (chave == null) return;
        if (!Array.isArray(this.rows)) this.rows = [];
        const idx = this.rows.findIndex(
          r => String(r?.[pkField]) === String(chave)
        );
        if (idx >= 0) this.rows.splice(idx, 1);
        this.focusedRowKey = null;
        const grid = this.$refs?.grid?.instance;
        if (grid) grid.refresh();
        return;
      }

      // INSERT/UPDATE precisam de objeto
      if (!registroDb || typeof registroDb !== "object") {
        // fallback: usa o que estava no form
        registroDb =
          registroLocal && typeof registroLocal === "object"
            ? { ...registroLocal }
            : null;
      }
      if (!registroDb) return;

      // garante PK no objeto
      if (chave != null && registroDb[pkField] == null)
        registroDb[pkField] = chave;

      if (!Array.isArray(this.rows)) this.rows = [];

      // mantém/gera id (se você usa id para outras coisas)
      if (registroDb.id == null) {
        const maxId = this.rows.reduce(
          (acc, r) => Math.max(acc, Number(r?.id || 0)),
          0
        );
        registroDb.id = maxId + 1;
      }

      const idx = this.rows.findIndex(
        r => String(r?.[pkField]) === String(registroDb[pkField])
      );

      if (idx >= 0) {
        // UPDATE (ou INSERT de registro já existente): merge
        const merged = { ...this.rows[idx], ...registroDb };
        if (this.$set) this.$set(this.rows, idx, merged);
        else this.rows[idx] = merged;
      } else {
        // INSERT novo
        this.rows.push({ ...registroDb });
      }

      // foco/posição na grid
      this.focusedRowKey = registroDb[pkField];

      this.$nextTick(() => {
        const grid = this.$refs?.grid?.instance;
        if (grid && this.focusedRowKey != null) {
          try {
            grid.option("focusedRowEnabled", true);
            grid.option("focusedRowKey", this.focusedRowKey);
            grid.navigateToRow(this.focusedRowKey);
            grid.selectRows([this.focusedRowKey], false);
            grid.refresh();
          } catch (e) {
            console.warn("Falha ao focar linha na grid:", e);
          }
        }
      });
    },

    getKeyFieldFromMeta() {
      const meta = JSON.parse(
        sessionStorage.getItem(`campos_grid_meta_${Number(this.cd_menu)}`) ||
          "[]"
      );
      return (
        meta.find(m => String(m.ic_atributo_chave || "").trim() === "S")
          ?.nm_atributo || "id"
      );
    },

    mapRegistroDbParaGrid(registroDb) {
      const src = JSON.parse(JSON.stringify(registroDb || {}));

      const meta = JSON.parse(
        localStorage.getItem(`campos_grid_meta_${this.cd_menu}`) || "[]"
      );

      // mapa: nm_atributo (db) -> nm_atributo_consulta (grid)
      const map = new Map();
      meta.forEach(m => {
        if (m?.nm_atributo && m?.nm_atributo_consulta) {
          map.set(m.nm_atributo, m.nm_atributo_consulta);
        }
      });

      const out = {};
      Object.keys(src).forEach(k => {
        out[map.get(k) || k] = src[k];
      });

      return out;
    },

    getPkFieldFromMeta(metaIn = null) {
      const meta =
        Array.isArray(metaIn) && metaIn.length
          ? metaIn
          : Array.isArray(this.gridMeta)
          ? this.gridMeta
          : [];
      const m = meta.find(
        x =>
          String(x?.ic_atributo_chave || "")
            .trim()
            .toUpperCase() === "S"
      );
      const pk = (m?.nm_atributo || m?.nm_atributo_consulta || "").trim();
      if (pk) return pk;

      const p = this.payloadTabela || {};
      if (p.key_name) return String(p.key_name).trim() || "id";

      // último fallback: derivação pelo nome da tabela
      const t = (p.nm_tabela || p.nm_tabela_consulta || "")
        .toLowerCase()
        .replace(/^dbo\./, "");
      return t ? `cd_${t}` : "id";
    },

    keyNameInfer() {
      // mantém compatibilidade com chamadas existentes
      const pk = this.getPkFieldFromMeta();
      // também atualiza o keyName usado pela grid
      if (pk && this.keyName !== pk) this.keyName = pk;
      return pk || "id";
    },

    getMetaAtual() {
      let meta = Array.isArray(this.gridMeta) ? this.gridMeta : [];

      if (!meta.length) {
        const cdMenu =
          this.cd_menu ||
          localStorage.cd_menu ||
          sessionStorage.getItem("cd_menu");
        const metaKey = `campos_grid_meta_${cdMenu}`;
        try {
          meta = JSON.parse(
            localStorage.getItem(metaKey) ||
              sessionStorage.getItem(metaKey) ||
              "[]"
          );
        } catch (_) {
          meta = [];
        }
      }
      return meta;
    },

    //

    async focarNaLinha(keyVal) {
      const grid = this.$refs?.grid?.instance;
      if (!grid || keyVal == null) return;

      try {
        grid.option("focusedRowEnabled", true);
        grid.option("focusedRowKey", keyVal);
        await grid.navigateToRow(keyVal);
        grid.selectRows([keyVal], false);
      } catch (e) {
        console.warn("Falha ao focar/navegar na linha:", e);
      }
    },

    //
    keyNameInferOLD() {
      const p = this.payloadTabela || {};

      if (p.key_name) return String(p.key_name).trim() || "id";
      const t = (p.nm_tabela || p.nm_tabela_consulta || "")
        .toLowerCase()
        .replace(/^dbo\./, "");
      return t ? `cd_${t}` : "id";
    },

    async abrirFormConsulta({ registro = {} } = {}) {
      this._tabAntesModal = this.activeMenuTab || "principal";
      this._estavaEmTabFilha =
        this._tabAntesModal && this._tabAntesModal !== "principal";

      if (!registro) return;
      // ativa modo somente leitura
      this.formSomenteLeitura = true;
      // reaproveita toda a lógica de edição (preencher formData, lookups, etc.)
      await this.abrirFormEspecial({ modo: "A", registro });
    },

    // fecha o form especial

    fecharForm() {
      this.dlgForm = false;
      this.formSomenteLeitura = false;

      if (this.embedMode) {
        this.$emit("voltar");
        this.$emit("fechar");
        return;
      }

      // se quiser limpar lixo de builder:
      const mountEl = this.$refs.formEspecialMount;

      if (mountEl) mountEl.innerHTML = "";

      this.formRenderizou = false;

      //

      if (this.$emit) {
        this.$emit("fechar");
        //
      }
    },

    onFecharTabFilha(t) {
      this.takeoverFilhoGrid = false;

      // pega a última aba da pilha; se não tiver, volta pra principal
      const voltarPara = this._tabStack.length
        ? this._tabStack.pop()
        : "principal";

      this.activeMenuTab = voltarPara;

      //this.limparSelecaoGrid();
    },

    // preenche campos de data com início/fim do mês vigente
    preencherDatasDoMesOld() {
      // se ainda não tem filtros, não faz nada
      if (!this.filtros || !this.filtros.length) return;

      // datas do mês vigente
      const hoje = new Date();
      const inicio = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
      const fim = new Date(hoje.getFullYear(), hoje.getMonth() + 1, 0);

      // garante o objeto de valores
      if (!this.filtrosValores) this.filtrosValores = {};
      //

      // util: seta só se estiver vazio (mantém o que o usuário já digitou)
      const setIfEmpty = (key, val) => {
        const cur = this.filtrosValores[key];
        if (cur === undefined || cur === null || cur === "") {
          // usa formatBR que já existe no seu código
          this.$set(this.filtrosValores, key, this.formatBR(val));
        }
      };

      // tenta achar campos padrão "inicial" e "final"
      const isInicial = f =>
        /dt_?inicial|data_?inicial|ini(cio|cial)?/i.test(f.nm_atributo || "");
      const isFinal = f =>
        /dt_?final|data_?final|fim/i.test(f.nm_atributo || "");

      const fInicial = this.filtros.find(isInicial);
      const fFinal = this.filtros.find(isFinal);

      if (fInicial) setIfEmpty(fInicial.nm_atributo, inicio);
      if (fFinal) setIfEmpty(fFinal.nm_atributo, fim);

      // fallback: se não existem campos explícitos de inicial/final,
      // preenche os primeiros campos de "data" encontrados
      if (!fInicial && !fFinal) {
        // heurística: nome contendo "dt" ou "data" ou tp_dado === 'D'
        const camposData = this.filtros.filter(
          f =>
            /(^dt_|data|_dt$)/i.test(f.nm_atributo || "") ||
            String(f.tp_dado || "").toUpperCase() === "D"
        );
        if (camposData.length === 1) {
          setIfEmpty(camposData[0].nm_atributo, inicio);
        } else if (camposData.length > 1) {
          setIfEmpty(camposData[0].nm_atributo, inicio);
          setIfEmpty(camposData[1].nm_atributo, fim);
        }
      }
    },

    // pega colunas/linhas do mesmo jeito que o display-data.vue salva

    _getColsRowsFromLocalStorage() {
      // colunas
      const meta = JSON.parse(localStorage.getItem("campos_grid_meta") || "[]");
      const cols =
        this.columns && this.columns.length
          ? this.columns
          : meta.map(c => ({
              field: c.nm_atributo,
              label: c.nm_label || c.nm_atributo,
              name: c.nm_atributo,
            }));

      // linhas
      const rows =
        this.rows && this.rows.length
          ? this.rows
          : JSON.parse(
              localStorage.getItem("dados_resultado_consulta") || "[]"
            );

      return { cols, rows };
    },

    async abrirRelatorio() {
      // garanta que gridRows e camposMetaGrid estão prontos aqui
      if (!Array.isArray(this.columns) || this.columns.length === 0) {
        //this.$q.notify({ type:'warning', position:'top-right', message:'Sem dados para o relatório.' })
        this.notifyWarn("Sem dados para o relatório.");
        return;
      }

      await this.ensureConsultaCacheLoaded();

      // Se já tiver grid pronta no form, passe os dados e meta por props:
      // this.$refs.relComp (opcional) poderá acessar depois
      this.showRelatorio = true;
    },

    async bootstrap() {
      // pega da URL (ex.: ?cd_menu=236&cd_usuario=842) e do localStorage
      const q = new URLSearchParams(window.location.search);
      const cd_menu_q = q.get("cd_menu");
      const cd_usuario_q = q.get("cd_usuario");

      // compat: projetos antigos gravam como propriedades (localStorage.cd_menu),
      // então leio dos DOIS jeitos
      const cd_menu_ls_dot = window.localStorage.cd_menu;
      const cd_usuario_ls_dot = window.localStorage.cd_usuario;
      const cd_menu_ls_get = window.localStorage.getItem("cd_menu");
      const cd_usuario_ls_get = window.localStorage.getItem("cd_usuario");

      // ✅ PRIORIDADE: se veio via props (ex.: embed/composição), usa isso
      const cd_menu_from_props =
        Number(this.cd_menu_entrada || this.ncd_menu_entrada || 0) || null;

      const cd_menu =
        cd_menu_from_props || cd_menu_q || cd_menu_ls_dot || cd_menu_ls_get;
      const cd_usuario = cd_usuario_q || cd_usuario_ls_dot || cd_usuario_ls_get;

      // ✅ AQUI É O LUGAR CERTO:
      this.ncd_menu_entrada = Number(cd_menu || 0);
      this.cd_menu = cd_menu ? String(cd_menu) : null;
      this.cdMenu = this.cd_menu;
      this.temSessao = !!(this.cd_menu && cd_usuario);

      // chave dinâmica que veio do pai (nota / documento / etc)

      this.ncd_acesso_entrada =
        this.ncd_acesso_entrada ||
        window.localStorage.cd_acesso_entrada ||
        window.localStorage.getItem("cd_acesso_entrada") ||
        null;

      if (!this.temSessao) {
        console.warn("cd_menu/cd_usuario ausentes na sessão.");
        // limpa qualquer lixo visual e sai sem erro
        this.rows = [];
        this.columns = [];
        this.totalColumns = [];
        this.qt_registro = 0;

        return;
      }

      // Carrega configuração da grid e filtros
      // --> pr_egis_payload_tabela
      //
      await this.loadPayload(cd_menu, cd_usuario);
      //

      //
      this.montarAbasDetalhe();
      //

      // Carrega os filtros dinâmicos
      await this.loadFiltros(cd_menu, cd_usuario);
      // Se não houver filtro obrigatório, já faz a consulta

      const filtroObrig = this.gridMeta.some(
        c => c.ic_filtro_obrigatorio === "S"
      );
      const registroMenu = this.gridMeta.some(
        c => c.ic_registro_tabela_menu === "S"
      );

      //antes
      //if (registroMenu && !filtroObrig && !this.isPesquisa) {
      //  this.consultar();
      //}

      // ✅ No embedMode, quem manda é o abrirPorChaveDoPai (não auto-consultar no bootstrap)

      if (!this.embedMode) {
        if (registroMenu && !filtroObrig && !this.isPesquisa) {
          this.consultar();
        }
      }
    },

    notifyOk(msg) {
      this.$q.notify({
        type: "positive",
        message: msg,
        position: "center",
        timeout: 3000,
        actions: [{ icon: "close", color: "white" }],
      });
    },

    notifyWarn(msg) {
      this.$q.notify({
        type: "warning",
        message: msg,
        position: "center",
        timeout: 3000,
        actions: [{ icon: "close", color: "white" }],
      });
    },
    notifyErr(msg) {
      this.$q.notify({
        type: "negative",
        message: msg,
        position: "center",
        timeout: 3000,
        actions: [{ icon: "close", color: "white" }],
      });
    },

    async showMenu() {
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;
      this.cd_menu_destino = 0;
      this.cd_api_destino = 0;
      localStorage.cd_parametro = 0;

      var dataI = new Date(localStorage.dt_inicial);
      var diaI = dataI.getDate().toString();
      var mesI = (dataI.getMonth() + 1).toString();
      var anoI = dataI.getFullYear();
      localStorage.dt_inicial = mesI + "-" + diaI + "-" + anoI;

      var dataF = new Date(localStorage.dt_final);
      var diaF = dataF.getDate().toString();
      var mesF = (dataF.getMonth() + 1).toString();
      var anoF = dataF.getFullYear();
      localStorage.dt_final = mesF + "-" + diaF + "-" + anoF;

      var dataB = new Date(localStorage.dt_base);
      var diaB = dataB.getDate().toString();
      var mesB = (dataB.getMonth() + 1).toString();
      var anoB = dataB.getFullYear();

      localStorage.dt_base = mesB + "-" + diaB + "-" + anoB;

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';

      //dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';

      this.menu_titulo = dados.nm_menu_titulo;
      this.menu_relatorio = dados.menu_relatorio;
      this.cd_parametro_menu = dados.cd_parametro_menu;

      //console.log('menu: ',dados, dados.cd_parametro_menu);

      //this.sParametroApi       = dados.nm_api_parametro;

      sParametroApi = dados.nm_api_parametro;
      let parametro_valor = JSON.parse(dados.nm_api_parametro_valor);
      Object.keys(parametro_valor).map((e, index) => {
        if (parametro_valor[Object.keys(parametro_valor)[index]]) {
          if (e.startsWith("dt_")) {
            //Verifica as datas e formata
            let novaData = formataData.formataDataSQL(
              parametro_valor[Object.keys(parametro_valor)[index]]
            );
            // eslint-disable-next-line no-useless-escape
            let regexData = /([0-9]{2})\-([0-9]{2})\-([0-9]{4})/;
            regexData.test(novaData)
              ? (localStorage[e] =
                  parametro_valor[Object.keys(parametro_valor)[index]])
              : "";
          } else {
            localStorage[e] =
              parametro_valor[Object.keys(parametro_valor)[index]];
          }
        }
      });

      if (
        !dados.nm_identificacao_api == "" &&
        !dados.nm_identificacao_api == this.api
      ) {
        this.api = dados.nm_identificacao_api;
      }

      this.qt_tabsheet = dados.qt_tabsheet;
      this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa || "N";
      this.exportar = false;
      this.arquivo_abrir = false;
      this.ativaPDF = false;
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

      filename = this.tituloMenu + ".xlsx";
      filenametxt = this.tituloMenu + ".txt";
      filenamedoc = this.tituloMenu + ".docx";
      filenamexml = this.tituloMenu + ".xml";

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)));
      //
      this.columns.map(c => {
        if (c.ic_botao === "S") {
          c.cellTemplate = (cellElement, cellInfo) => {
            const buttonEdit = document.createElement("button");
            buttonEdit.textContent = c.nm_botao_texto;
            buttonEdit.style.padding = "8px 12px";
            buttonEdit.style.marginRight = "5px";
            buttonEdit.style.border = "none";
            buttonEdit.style.borderRadius = "4px";
            buttonEdit.style.fontSize = "14px";
            buttonEdit.style.cursor = "pointer";
            buttonEdit.style.backgroundColor = "#1976D2";
            buttonEdit.style.color = "white";
            buttonEdit.style.transition =
              "background-color 0.3s ease, transform 0.2s ease";

            // Adicionando efeito de hover
            buttonEdit.onmouseover = () => {
              buttonEdit.style.backgroundColor = "#1565C0"; // Cor mais escura ao passar o mouse
              buttonEdit.style.transform = "scale(1.05)"; // Leve aumento no tamanho
            };
            buttonEdit.onmouseout = () => {
              buttonEdit.style.backgroundColor = "#1976D2"; // Volta à cor original
              buttonEdit.style.transform = "scale(1)"; // Retorna ao tamanho normal
            };
            buttonEdit.onclick = () =>
              this.handleButton({
                data: cellInfo.data,
                ic_procedimento_crud: c.ic_procedimento_crud,
                nm_api_busca: c.nm_api_busca,
              });

            cellElement.appendChild(buttonEdit);
          };
        }
        if (c.dataType === "date") {
          c.calculateCellValue = row => {
            if (!row[c.dataField]) return "";
            if (row[c.dataField].length < 10) return row[c.dataField];

            const [datePart] = row[c.dataField].split(" ");
            const [year, month, day] = datePart.split("-");

            return `${day.substring(0, 2)}/${month}/${year}`;
          };
        }
      });

      //dados do total
      //this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)));
      //

      this.total = (() => {
        try {
          const raw =
            dados && dados.coluna_total
              ? dados.coluna_total
              : '{"totalItems":[]}';

          let parsed = raw;

          // se vier string JSON
          if (typeof parsed === "string") parsed = JSON.parse(parsed);

          // se vier no formato { totalItems: [...] }
          if (parsed && Array.isArray(parsed.totalItems)) {
            return { totalItems: parsed.totalItems };
          }

          // se vier array direto
          if (Array.isArray(parsed)) {
            return { totalItems: parsed };
          }

          return { totalItems: [] };

          //Antes
          //return JSON.parse(JSON.parse(JSON.stringify(raw)));
        } catch (e) {
          return { totalItems: [] };
        }
      })();

      //TabSheet
      this.tabs = [];
      //

      if (!this.qt_tabsheet == 0) {
        this.tabs = JSON.parse(JSON.parse(JSON.stringify(dados.TabSheet)));
        this.cd_menu_destino = parseInt(this.cd_menu);
        this.cd_api_destino = parseInt(this.cd_api);
      }

      //Filtros

      this.filtro = [];

      if (this.ic_filtro_pesquisa == "S") {
        this.filtro = await JSON.parse(
          JSON.parse(JSON.stringify(dados.Filtro))
        );

        if (!!this.filtro[0].cd_tabela == false) {
          this.dados_lookup = await Lookup.montarSelect(
            this.cd_empresa,
            dados.cd_tabela
          );
        } else {
          this.dados_lookup = await Lookup.montarSelect(
            this.cd_empresa,
            this.filtro[0].cd_tabela
          );
        }
        if (!!this.dados_lookup != false) {
          this.dataset_lookup = JSON.parse(
            JSON.parse(JSON.stringify(this.dados_lookup.dataset))
          );
          this.value_lookup = this.filtro[0].nm_campo_chave_lookup;
          this.label_lookup = this.filtro[0].nm_campo;
          this.placeholder_lookup = this.filtro[0].nm_campo_descricao_lookup;
        }
      }

      //trocar para dados.laberFormFiltro
      //this.formDataFiltro = JSON.parse(dados.Filtro);
      //this.itemsFiltro = JSON.parse(dados.labelForm);
      //
    },

    onVoltar() {
      const hasVoltarListener =
        this.$listeners &&
        Object.prototype.hasOwnProperty.call(this.$listeners, "voltar");

      if (this.embedMode || hasVoltarListener) {
        this.$emit("voltar");
        return;
      }

      // senão segue navegação padrão

      if (this.ic_modal_pesquisa === "S" || this.cd_chave_pesquisa > 0) {
        if (this.$emit) {
          this.$emit("fechar");
        }
        return;
      }

      if (this.$router) this.$router.back();
      else window.history.back();
    },

    // integração com o searchPanel do DevExtreme
    onSearchChange(val) {
      const inst = this.$refs.grid && this.$refs.grid.instance;
      if (inst && inst.searchByText) {
        inst.searchByText(val || "");
      }
    },

    // coloca ícones/botões na toolbar da grid

    onToolbarPreparing(e) {
      console.log("🔧 Preparando toolbar...");
      const dataGrid = e.component;
      // limpa os itens padrão
      e.toolbarOptions.items.push({
        location: "after",
        widget: "dxButton",
        //color: "primary",
        options: {
          icon: "clear",
          text: "Limpar Filtros",
          //color: "primary",
          // estilo do botão
          type: "normal",
          // ação ao clicar
          onClick: () => {
            dataGrid.clearFilter();
            // botão de limpar filtros
            this.limparFiltroSelecao();
            //
          },
        },
        visible: this.showClearButton, // visibilidade controlada
      });

      /*
        // limpa os itens padrão
    e.toolbarOptions.items = [];

    // adiciona o SearchPanel primeiro
    e.toolbarOptions.items.push({
      location: 'before',
     
      widget: 'dxTextBox',
      options: {
        placeholder: '📌 Procurar...',
         width: 600,
        showClearButton: true,
        onValueChanged: (args) => {
          e.component.searchByText(args.value);
        }
      }
    });

    // depois adiciona o GroupPanel
    e.toolbarOptions.items.push({
      location: 'after',
      name: 'groupPanel'
    });
    */
    },

    imprimirPDF() {
      window.print();
    },

    async exportarPDF() {
      await this.ensureConsultaCacheLoaded();

      try {
        const { default: jsPDF } = await import("jspdf");
        const { default: autoTable } = await import("jspdf-autotable");

        // 1) Pega suas colunas / linhas já mostradas na grid
        const metaCols =
          (this.columns?.length ? this.columns : this.gridColumns) || [];

        const rowsSrc = (this.rows?.length ? this.rows : this.gridRows) || [];

        if (!rowsSrc.length) {
          this.$q?.notify?.({
            type: "warning",
            position: "center",
            message: "Sem dados para exportar.",
          });
          return;
        }

        // 2) Mapa de atributo -> atributo_consulta salvo no payload

        let mapa = {};
        try {
          mapa = JSON.parse(
            sessionStorage.getItem("mapa_consulta_para_atributo") || "{}"
          );
        } catch (_) {}

        // 3) Monta colunas exportáveis (ignora coluna de ações)
        const cols = metaCols
          .filter(c => c.type !== "buttons")
          .map(c => ({
            label:
              c.caption ||
              c.label ||
              c.nm_titulo_menu_atributo ||
              c.dataField ||
              c.field,
            field: c.dataField || c.field || c.name,
            fmt: c.format || null,
            width: c.width,
          }));

        // 4) Helpers de formatação
        const toBR = v => {
          if (v == null || v === "") return "";
          if (v instanceof Date) {
            const dd = String(v.getDate()).padStart(2, "0");
            const mm = String(v.getMonth() + 1).padStart(2, "0");
            const yy = v.getFullYear();
            return `${dd}/${mm}/${yy}`;
          }
          const s = String(v);
          if (/^\d{2}\/\d{2}\/\d{4}$/.test(s)) return s;
          // ISO -> pega só a data
          const m = s.match(/^(\d{4})-(\d{2})-(\d{2})/);
          if (m) return `${m[3]}/${m[2]}/${m[1]}`;
          return s;
        };
        const money = n => {
          const x = Number(String(n).replace(",", "."));
          return Number.isFinite(x)
            ? x.toLocaleString("pt-BR", { style: "currency", currency: "BRL" })
            : n ?? "";
        };

        // 5) Resolve valor seguro por coluna e linha
        const safeGet = (row, col) => {
          const tryKeys = [];
          const base = col.field;
          tryKeys.push(base);
          if (mapa[base]) tryKeys.push(mapa[base]); // mapeamento meta->consulta
          // tenta achar por case-insensitive
          const alt = Object.keys(row).find(
            k => k.toLowerCase() === base?.toLowerCase()
          );
          if (alt && !tryKeys.includes(alt)) tryKeys.push(alt);

          let val;
          for (const k of tryKeys) {
            if (k in row) {
              val = row[k];
              break;
            }
          }
          // formata
          if (
            col.fmt &&
            ["currency", "fixedPoint", "number", "percent"].includes(col.fmt)
          ) {
            return money(val);
          }
          if (/^(dt_|data|emissao|entrega)/i.test(col.field)) return toBR(val);
          return val == null ? "" : String(val);
        };

        // 6) Cabeçalho/Metadados
        const empresa =
          localStorage.nm_razao_social ||
          sessionStorage.getItem("empresa") ||
          "-";
        const menu =
          this.cd_menu ||
          this.cdMenu ||
          sessionStorage.getItem("cd_menu") ||
          "";
        const usuario =
          localStorage.nm_usuario || sessionStorage.getItem("nm_usuario") || "";
        const getFiltro = k =>
          (this.filtrosValores && this.filtrosValores[k]) || "";
        const dtIni =
          getFiltro("dt_inicial") || getFiltro("dtini") || getFiltro("dt_inic");
        const dtFim =
          getFiltro("dt_final") || getFiltro("dtfim") || getFiltro("dt_fim");

        // 7) Prepara head/body para o AutoTable
        const head = [cols.map(c => c.label)];
        const body = rowsSrc.map(r => cols.map(c => safeGet(r, c)));

        // 8) Totais/resumo com base no seu meta de totalização
        const summary = [];
        if (Array.isArray(this.totalColumns) && this.totalColumns.length) {
          const tot = this.totalColumns.map(t => {
            if (t.type === "count") {
              return {
                label: "registro(s)",
                value: rowsSrc.length,
                isCurrency: false,
              };
            } else {
              const soma = rowsSrc.reduce((acc, rr) => {
                const v = Number(rr[t.dataField]) || 0;
                return acc + v;
              }, 0);
              return {
                label: t.display?.replace("{0}", "Total") || "Total",
                value: soma,
                isCurrency: true,
              };
            }
          });
          summary.push(...tot);
        }

        // 9) Gera o PDF
        const doc = new jsPDF({
          orientation: "landscape",
          unit: "pt",
          format: "a4",
        });
        const margin = 28;
        const pageW = doc.internal.pageSize.getWidth();
        let y = margin;

        // (opcional) logo – precisa ser HTTPS e CORS habilitado

        try {
          const nm_caminho_logo_empresa =
            localStorage.nm_caminho_logo_empresa || "";
          const logoUrl = `https://egisapp.com.br/img/${nm_caminho_logo_empresa}`;
          const res = await fetch(logoUrl);
          const b = await res.blob();
          const b64 = await new Promise(r => {
            const fr = new FileReader();
            fr.onload = () => r(fr.result);
            fr.readAsDataURL(b);
          });
          doc.addImage(b64, "PNG", margin, y, 90, 30);
        } catch (_) {
          /* se falhar, segue sem logo */
        }

        // Título
        doc.setFont("helvetica", "bold");
        doc.setFontSize(22);
        doc.text(
          this.title || this.pageTitle || "Entregas por Periodo",
          margin + 120,
          y + 22
        );

        // Meta linha 1
        doc.setFont("helvetica", "normal");
        doc.setFontSize(11);
        y += 46;
        doc.text(
          `Empresa: ${empresa}  •  Menu: ${menu}  •  Data/Hora: ${toBR(
            new Date()
          )} ${new Date().toLocaleTimeString("pt-BR")}`,
          margin,
          y
        );
        // Período
        y += 18;
        doc.text(
          `Data Inicial: ${toBR(dtIni)}   |   Data Final: ${toBR(dtFim)}`,
          margin,
          y
        );

        // Tabela
        const columnStyles = {};
        cols.forEach((c, i) => {
          if (c.width) columnStyles[i] = { cellWidth: c.width };
          if (
            c.fmt &&
            ["currency", "fixedPoint", "number", "percent"].includes(c.fmt)
          ) {
            columnStyles[i] = { ...(columnStyles[i] || {}), halign: "right" };
          }
        });

        autoTable(doc, {
          head,
          body,
          startY: y + 12,
          styles: {
            fontSize: 9,
            lineWidth: 0.1,
            lineColor: 80,
            cellPadding: 4,
            overflow: "linebreak",
          },
          headStyles: {
            fillColor: [220, 220, 220],
            textColor: 20,
            halign: "left",
          }, // mais contraste
          alternateRowStyles: { fillColor: [245, 245, 245] },
          columnStyles,
          theme: "grid",
          didDrawPage: data => {
            const pg = `Página ${doc.internal.getNumberOfPages()}`;
            doc.setFontSize(9);
            doc.text(
              pg,
              pageW - margin - doc.getTextWidth(pg),
              doc.internal.pageSize.getHeight() - 10
            );
          },
        });

        // Resumo

        if (summary.length) {
          const lastY = doc.lastAutoTable.finalY || y + 60;
          autoTable(doc, {
            head: [["Resumo", "Valor"]],
            body: summary.map(s => [
              s.label,
              s.isCurrency
                ? (Number(s.value) || 0).toLocaleString("pt-BR", {
                    style: "currency",
                    currency: "BRL",
                  })
                : s.value,
            ]),
            startY: lastY + 12,
            styles: { fontSize: 10, cellPadding: 4 },
            headStyles: { fillColor: [230, 230, 230] },
            columnStyles: { 1: { halign: "right" } },
            theme: "grid",
          });
        }

        // Salva
        const arq = (this.title || this.pageTitle || "relatorio") + ".pdf";
        doc.save(arq);
      } catch (e) {
        console.error("PDF erro", e);
        this.$q?.notify?.({
          type: "negative",
          position: "center",
          message: "Falha ao exportar PDF.",
        });
      }
    },

    async exportarPDFold() {
      try {
        // 1) Tenta pegar do seu storage (mantido)
        let cols = [];
        let rows = [];
        try {
          const r = this._getColsRowsFromLocalStorage?.() || {};
          cols = Array.isArray(r.cols) ? r.cols : [];
          rows = Array.isArray(r.rows) ? r.rows : [];
        } catch (_) {}

        // 2) Fallback: usa colunas/linhas que já estão na tela
        if (!rows.length) rows = this.rows || this.gridRows || [];
        if (!cols.length) cols = this.columns || this.gridColumns || [];

        // 3) Limpa colunas “de ação”
        const isAcao = c =>
          c?.type === "buttons" ||
          c?.buttons ||
          c?.field === "__acoes" ||
          c?.name === "__acoes";
        cols = (cols || []).filter(c => !isAcao(c));

        if (!Array.isArray(rows) || rows.length === 0) {
          this.$q?.notify?.({
            type: "warning",
            position: "center",
            message: "Sem dados para exportar.",
          });
          return;
        }
        if (!Array.isArray(cols) || cols.length === 0) {
          this.$q?.notify?.({
            type: "warning",
            position: "center",
            message: "Sem colunas para exportar.",
          });
          return;
        }

        // 4) Imports dinâmicos
        const jsPDF = (await import(/* webpackChunkName: "jspdf" */ "jspdf"))
          .default;
        const { default: autoTable } = await import(
          /* webpackChunkName: "jspdf-autotable" */ "jspdf-autotable"
        );

        // 5) Helpers de formatação
        const toBRDate = v => {
          if (v == null || v === "") return "";
          try {
            if (typeof v === "string" && /^\d{2}\/\d{2}\/\d{4}$/.test(v))
              return v; // já está em BR
            const d = new Date(v);
            return isNaN(d) ? String(v) : d.toLocaleDateString("pt-BR");
          } catch {
            return String(v);
          }
        };

        const toBRNumber = v => {
          const n = Number(v);
          if (!isFinite(n)) return v ?? "";
          return n.toLocaleString("pt-BR");
        };

        const toBRMoney = v => {
          const n = Number(v);
          if (!isFinite(n)) return v ?? "";
          return n.toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL",
          });
        };

        // se você já tem this.formatCell/metaPorDataField, uso; senão aplico heurística
        const fmtCell = (val, meta = {}) => {
          if (typeof this.formatCell === "function")
            return this.formatCell(val, meta);
          const fmt = (meta.formato_coluna || meta.format || "")
            .toString()
            .toLowerCase();
          if (fmt.includes("date")) return toBRDate(val);
          if (fmt.includes("currency")) return toBRMoney(val);
          if (
            fmt.includes("number") ||
            fmt.includes("fixed") ||
            fmt.includes("percent")
          )
            return toBRNumber(val);
          return val ?? "";
        };

        const getField = c => c.field || c.name || c.dataField;
        const getLabel = c =>
          c.label || c.caption || c.name || c.field || c.dataField;

        // 6) Cabeçalho (logo/empresa/título/filtros)
        const titulo =
          this.pageTitle ||
          this.title ||
          sessionStorage.getItem("menu_titulo") ||
          "Relatório";
        const empresa =
          localStorage.nm_fantasia_empresa || localStorage.empresa || "";
        const logoURL =
          localStorage.logo_url ||
          sessionStorage.getItem("logo_url") ||
          "/img/logo.png"; // ajuste para um caminho seu (mesma origem, de preferência)

        // melhor esforço para carregar logo (se falhar, segue sem)
        const loadImageAsDataUrl = url =>
          new Promise(resolve => {
            try {
              const img = new Image();
              img.crossOrigin = "anonymous";
              img.onload = () => {
                try {
                  const cv = document.createElement("canvas");
                  cv.width = img.naturalWidth;
                  cv.height = img.naturalHeight;
                  const ctx = cv.getContext("2d");
                  ctx.drawImage(img, 0, 0);
                  resolve(cv.toDataURL("image/png"));
                } catch {
                  resolve(null);
                }
              };
              img.onerror = () => resolve(null);
              img.src = url;
            } catch {
              resolve(null);
            }
          });

        const logoDataUrl = await loadImageAsDataUrl(logoURL).catch(() => null);

        // monta texto de filtros
        const filtrosTxt = (() => {
          try {
            if (!this.filtros || !this.filtros.length) return "";
            const pares = [];
            for (const f of this.filtros) {
              const k = f.nm_atributo;
              const rot = f.nm_edit_label || f.nm_filtro || k;
              let v = this?.filtrosValores?.[k];
              // força data BR
              if (/^dt_/.test(k)) v = toBRDate(v);
              if (v != null && v !== "") pares.push(`${rot}: ${v}`);
            }
            return pares.join("  |  ");
          } catch {
            return "";
          }
        })();

        // 7) Prepara tabela
        const columnsForPDF = cols.map(c => ({
          header: getLabel(c),
          dataKey: getField(c),
        }));

        const body = rows.map(r => {
          const obj = {};
          for (const c of cols) {
            const key = getField(c);
            const meta = { ...c, formato_coluna: c.formato_coluna || c.format };
            obj[key] = fmtCell(r[key], meta);
          }
          return obj;
        });

        // 8) Cria PDF
        const doc = new jsPDF({
          orientation: "landscape",
          unit: "pt",
          format: "a4",
        });
        const pageW = doc.internal.pageSize.getWidth();
        const margin = 40;
        let cursorY = margin;

        // logo (opcional)
        if (logoDataUrl) {
          const logoW = 120;
          const logoH = 40;
          doc.addImage(logoDataUrl, "PNG", margin, cursorY - 10, logoW, logoH);
        }

        // empresa + título
        doc.setFontSize(20);
        doc.text(String(titulo), margin + (logoDataUrl ? 130 : 0), cursorY + 5);

        doc.setFontSize(10);
        const agora = new Date();
        const headerRight = [
          empresa ? `Empresa: ${empresa}` : null,
          `Data/Hora: ${agora.toLocaleString("pt-BR")}`,
        ]
          .filter(Boolean)
          .join("  |  ");
        doc.text(headerRight, pageW - margin, cursorY, { align: "right" });

        cursorY += 28;

        if (filtrosTxt) {
          doc.setFontSize(11);
          doc.text(filtrosTxt, margin, cursorY, {
            maxWidth: pageW - margin * 2,
          });
          cursorY += 16;
        }

        // 9) Tabela
        autoTable(doc, {
          startY: cursorY,
          margin: { left: margin, right: margin },
          columns: columnsForPDF,
          body,
          styles: {
            fontSize: 9,
            cellPadding: 4,
            halign: "left",
            valign: "middle",
          },
          headStyles: { fillColor: [240, 240, 240] },
          didDrawPage: () => {
            // rodapé
            const w = doc.internal.pageSize.getWidth();
            const h = doc.internal.pageSize.getHeight();
            doc.setFontSize(8);
            doc.text(
              `Página ${doc.internal.getNumberOfPages()}`,
              w - margin,
              h - 12,
              { align: "right" }
            );
          },
        });

        // 10) Totais (this.totalColumns ou this.total?.totalItems)
        const montarTotais = () => {
          const tcols = this.totalColumns || this.total?.totalItems || [];
          if (!Array.isArray(tcols) || !tcols.length) return [];

          const out = [];
          tcols.forEach(t => {
            const df = t.dataField || t.name || t.field;
            const tipo = String(t.type || "").toLowerCase();
            if (!df || !tipo) return;

            if (tipo === "sum") {
              const soma = rows.reduce((acc, r) => {
                const n = Number(r[df]);
                return acc + (isFinite(n) ? n : 0);
              }, 0);
              const caption = (t.display || `Total de ${df}`)
                .replace("{0}", "")
                .trim();
              out.push({ caption, value: toBRMoney(soma) });
            } else if (tipo === "count") {
              const caption = (t.display || `Quantidade`)
                .replace("{0}", "")
                .trim();
              out.push({ caption, value: toBRNumber(rows.length) });
            }
          });
          return out;
        };

        const totais = montarTotais();
        if (totais.length) {
          const y = doc.lastAutoTable?.finalY
            ? doc.lastAutoTable.finalY + 12
            : cursorY + 12;
          autoTable(doc, {
            startY: y,
            margin: { left: margin, right: margin },
            columns: [
              { header: "Resumo", dataKey: "caption" },
              { header: "Valor", dataKey: "value" },
            ],
            body: totais,
            styles: { fontSize: 10, cellPadding: 3 },
            headStyles: { fillColor: [230, 230, 230] },
          });
        }

        // 11) salvar
        const nome = String(titulo)
          .replace(/\s+/g, "_")
          .normalize("NFD")
          .replace(/[\u0300-\u036f]/g, "");
        doc.save(`${nome || "relatorio"}.pdf`);
      } catch (e) {
        console.error("PDF erro", e);
        this.$q?.notify?.({
          type: "negative",
          position: "center",
          message: "Falha ao exportar PDF.",
        });
      }
    },

    async onExportarExcel() {
      try {
        // pegue seus dados atuais do grid;
        // se você guarda em this.rows ou this.dataSource, ajuste abaixo:
        const rows = Array.isArray(this.rows)
          ? this.rows
          : this.dataSource || [];
        await exportarParaExcel({
          rows,
          nomeArquivo: `${this.pageTitle || "dados"}.xlsx`,
        });
      } catch (e) {
        console.error("Falha ao exportar Excel", e);
        this.$q &&
          this.$q.notify({
            type: "negative",
            position: "center",
            message: "Erro ao exportar Excel.",
          });
      }
    },

    async onImportarExcelParaTabela(dadosPlanilha) {
      // dadosPlanilha: array de objetos (linhas) já lidos pelo browser
      try {
        await importarExcelParaTabela({
          nome_tabela: this.nome_tabela_import || "TMP_IMPORT",
          dados: dadosPlanilha,
        });
        this.$q &&
          this.$q.notify({
            type: "positive",
            message: "Importação concluída.",
          });
      } catch (e) {
        console.error("Falha ao importar Excel", e);
        this.$q &&
          this.$q.notify({
            type: "negative",
            position: "center",
            message: "Erro ao importar Excel.",
          });
      }
    },

    // export usando ExcelJS + exporter oficial do DevExtreme

    async exportarExcel() {
      try {
        const grid = this.$refs.grid && this.$refs.grid.instance;
        if (!grid) return;

        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet("Dados");

        await exportDataGrid({
          component: grid,
          worksheet,
          // preserve os formatos visuais:
          customizeCell: ({ gridCell, excelCell }) => {
            if (!gridCell) return;

            // currency
            const col =
              this.gridColumns.find(
                c => c.dataField === gridCell.column?.dataField
              ) || {};
            const tipoFmt = (col?.format?.type || col?._tipoFmt || "")
              .toString()
              .toLowerCase();

            if (tipoFmt === "fixedpoint" && Number.isFinite(gridCell.value)) {
              excelCell.numFmt = "#,##0.00";
            }
            // datas
            if (
              gridCell.column?.dataType === "date" &&
              gridCell.value instanceof Date
            ) {
              excelCell.value = new Date(
                gridCell.value.getFullYear(),
                gridCell.value.getMonth(),
                gridCell.value.getDate()
              );
              excelCell.numFmt = "dd/mm/yyyy";
            }
          },
        });

        const buffer = await workbook.xlsx.writeBuffer();
        const arquivo =
          (this.tituloMenu || "relatorio").replace(/[\s\/\\:?<>|"]/g, "_") +
          ".xlsx";
        //
        saveAs(
          new Blob([buffer], { type: "application/octet-stream" }),
          arquivo
        );
        //this.$q?.notify?.({ type: 'positive', message: 'Excel exportado com sucesso' });
        this.notifyOk("Excel exportado com sucesso!");
        //
      } catch (err) {
        console.error("Falha ao exportar Excel:", err);
        //this.$q?.notify?.({ type: 'negative', message: 'Erro ao exportar Excel' });
        this.notifyErr("Erro ao exportar Excel !");
      }
    },

    async onGerarPdf() {
      try {
        // obtenha os dados atuais; ajuste a origem conforme seu componente
        const dados = Array.isArray(this.rows)
          ? this.rows
          : this.dataSource || [];

        await this.ensureConsultaCacheLoaded();

        await gerarPdfRelatorio({
          cd_menu: this.cd_menu,
          cd_usuario: this.cd_usuario,
          dados,
        });
        // abre nova aba com o PDF (feito no service)
      } catch (e) {
        console.error("PDF erro", e);
        this.$q &&
          this.$q.notify({
            type: "negative",
            position: "center",
            message: "Erro ao gerar PDF.",
          });
      }
    },

    // ações (placeholders — conecte com seu CRUD/export já existentes)

    onNovo() {
      // abra seu modal de cadastro
      //this.abrirFormEspecial({ modo: 'I', registro: {} });

      // 1) preparar modo
      this.formMode = "I";
      this.formData = {};

      // 2) montar registro vazio pela lista de atributos disponível
      this.formData = this.montarRegistroVazio();

      // 3) aplicar fixos do sessionStorage (ex.: cd_cliente, cd_empresa, etc.)
      Object.keys(sessionStorage)
        .filter(k => k.startsWith("fixo_"))
        .forEach(k => {
          const campo = k.replace("fixo_", "");
          const val = sessionStorage.getItem(k);
          if (campo) this.$set(this.formData, campo, val);
        });

      // 4) abrir modal
      this.dlgNovo = true;
      //
    },

    onEditar(row) {
      this.formMode = "A";
      this.dialogCadastro = true;
      this.abrirFormEspecial({ modo: "A", registro: row });
    },

    async confirmarExclusao() {
      const registro = this.formData || {};
      const cd_menu = this.cd_menu || localStorage.cd_menu;

      // ✅ 1) Descobrir o campo chave no localStorage
      const metaKey = `campos_grid_meta_${cd_menu}`;
      const meta = JSON.parse(sessionStorage.getItem(metaKey) || "[]");

      console.log("meta --> ", meta);

      const keyField =
        meta.find(m => String(m.ic_atributo_chave || "").trim() === "S")
          ?.nm_atributo ||
        this.keyNameInfer?.() ||
        "id";

      // ✅ 2) Pegar o valor da chave
      const keyValue = registro?.[keyField];

      console.log(
        "[Excluir] keyField:",
        keyField,
        "keyValue:",
        keyValue,
        "registro:",
        registro
      );

      if (keyValue == null || keyValue === 0 || keyValue === "0") {
        this.$q.notify({
          type: "warning",
          position: "center",
          message: `Nenhum registro válido selecionado para exclusão (chave ${keyField} não encontrada).`,
        });
        return;
      }

      // ✅ 3) Força o registro a ter a chave correta
      const registroParaExcluir = { ...registro, [keyField]: keyValue };

      this.salvando = true;
      try {
        await this.runHook("beforeDelete", { registro: registroParaExcluir });

        const response = await this.salvarCRUD({
          modo: "E",
          registro: registroParaExcluir,
        });

        await this.runHook("afterDelete", {
          registro: registroParaExcluir,
          response,
        });

        this.$q.notify({
          type: "positive",
          message: "Registro excluído com sucesso.",
        });
        this.fecharForm();
      } catch (e) {
        console.error(e);
        this.$q.notify({
          type: "negative",
          message: e?.message || "Erro ao excluir registro.",
        });
      } finally {
        this.salvando = false;
      }
    },

    async onExcluir(e) {
      // DevExtreme geralmente manda o registro em e.row.data
      const rowData = e?.row?.data || e?.data || e;

      if (!rowData || typeof rowData !== "object") {
        this.$q.notify({
          type: "warning",
          position: "center",
          message: "Não foi possível identificar o registro para exclusão.",
        });
        return;
      }
      //if (!row) return;

      // garanta que é um objeto plano
      //const plain = JSON.parse(JSON.stringify(row));

      // garante objeto plano
      const plain = JSON.parse(JSON.stringify(rowData));
      //

      const meta = JSON.parse(
        localStorage.getItem(`campos_grid_meta_${this.cd_menu}`) || "[]"
      );
      const keyField = meta.find(
        m => String(m.ic_atributo_chave || "").trim() === "S"
      )?.nm_atributo;

      if (keyField && plain[keyField] == null) {
        // se por algum motivo o valor veio em outro lugar (ex: Código)
        plain[keyField] = plain["Código"] ?? plain["codigo"] ?? plain["id"];
      }

      //console.log('Excluir registro:', plain);
      this.formData = plain;
      //
      this.formMode = "E";

      // abrir form especial (se necessário)
      //
      this.abrirFormEspecial({ modo: "E", registro: plain });
      //

      //if (!confirm("Confirma exclusão?")) return;

      //await this.runHook("beforeDelete", { plain })

      // mapa campos se necessário
      //const response = await this.salvarCRUD({ modo: "E", registro: plain }); // cd_parametro_form = 3
      //

      //
      //await this.runHook("afterDelete", { plain, response })
      //
    },

    montarRegistroVazio() {
      const attrs = this.obterAtributosParaForm();

      const novo = {};

      attrs.forEach(a => {
        const nome = a.nm_atributo || a.dataField || a.nome;
        if (!nome) return;
        const t = (a.tipo_coluna || a.tipo || "").toLowerCase();
        if (/(int|bigint|smallint|tinyint|numeric|decimal|float|money)/.test(t))
          novo[nome] = 0;
        else if (/(bit|bool)/.test(t)) novo[nome] = 0;
        else if (/date/.test(t)) novo[nome] = null;
        else novo[nome] = "";
      });
      return novo;
    },

    mapearConsultaParaAtributo(row) {
      // usa o mapa salvo no sessionStorage (se existir)
      const mapa = JSON.parse(
        sessionStorage.getItem("mapa_consulta_para_atributo") || "{}"
      );

      if (!mapa || !Object.keys(mapa).length) return { ...row };

      const novo = {};

      Object.keys(row).forEach(k => {
        const destino = mapa[k] || k;
        novo[destino] = row[k];
      });
      return novo;
    },

    obterAtributosParaForm() {
      // 1) se já estiver pronto, reuse
      if (Array.isArray(this.atributosForm) && this.atributosForm.length) {
        return this.atributosForm;
      }

      // 2) tenta descobrir a “base” de atributos
      let base =
        (Array.isArray(this.gridMeta) &&
          this.gridMeta.length &&
          this.gridMeta) ||
        (Array.isArray(this.gridMeta?.atributos) && this.gridMeta.atributos) ||
        (Array.isArray(this.gridMeta?.colunas) && this.gridMeta.colunas) ||
        (Array.isArray(this.colunasGrid) && this.colunasGrid) ||
        [];

      console.log("Base de Atributos.", base);

      // 3) NORMALIZAÇÃO: mantém metadados e só ajeita o necessário
      base = base.filter(Boolean).map(a => {
        const attr = { ...a };

        // nm_atributo é obrigatório
        attr.nm_atributo = attr.nm_atributo || attr.dataField || attr.nome;

        // label padrão (fallback)
        attr.nm_edit_label =
          attr.nm_edit_label ||
          attr.nm_titulo_menu_atributo ||
          attr.caption ||
          attr.label ||
          attr.ds_atributo ||
          attr.nm_atributo;

        // Lista_Valor pode vir como string vazia/JSON
        if (typeof attr.Lista_Valor === "string") {
          const s = attr.Lista_Valor.trim();
          if (s.startsWith("[") && s.endsWith("]")) {
            try {
              attr.Lista_Valor = JSON.parse(s);
            } catch {
              attr.Lista_Valor = [];
            }
          } else {
            attr.Lista_Valor = [];
          }
        }
        if (!Array.isArray(attr.Lista_Valor)) attr.Lista_Valor = [];

        // flags podem vir null/undefined
        const flags = [
          "ic_atributo_chave",
          "ic_edita_cadastro",
          "ic_editavel",
          "ic_numeracao_automatica",
          "ic_numeracao_aumotatica",
          "ic_data_padrao",
        ];
        flags.forEach(f => {
          if (attr[f] == null) attr[f] = "N";
        });

        return attr;
      });

      // Helpers
      const isVazio = v =>
        v == null || (typeof v === "string" && v.trim() === "");

      // 3.1) Inicializa valores do formData (é isso que a tela usa)
      if (!this.formData) this.formData = {};
      if (!this.form) this.form = {}; // se você ainda usa em outras rotinas

      console.log("formData antes ->", this.formData);

      base.forEach(attr => {
        const k = attr.nm_atributo;
        if (!k) return;

        // valor atual preferindo o que já está no formData (não sobrescreve o que veio da consulta)
        let valorAtual =
          (!isVazio(this.formData[k]) ? this.formData[k] : null) ??
          (!isVazio(this.form?.[k]) ? this.form[k] : null) ??
          (!isVazio(this.rowEdit?.[k]) ? this.rowEdit[k] : null) ??
          (attr.vl_atributo != null ? attr.vl_atributo : null);

        const isDate = this.isDateField
          ? this.isDateField(attr)
          : /^dt_/.test(k);
        const icPadrao =
          String(attr.ic_data_padrao || "N").toUpperCase() === "S";

        // ✅ se for DATA e ic_data_padrao=S e estiver vazio -> coloca HOJE
        if (isDate && isVazio(valorAtual) && icPadrao) {
          valorAtual = toIsoDate(new Date(), true); // "YYYY-MM-DD"
          console.log("Data padrão aplicada ->", k, valorAtual);
        }

        // ✅ normaliza datas SEMPRE para string "YYYY-MM-DD" (q-input type=date exige isso)
        if (isDate && !isVazio(valorAtual)) {
          valorAtual = toIsoDate(valorAtual, true) || "";
        }

        // seta nos dois (por compat), mas o que manda na tela é o formData
        this.$set(this.formData, k, valorAtual);
        this.$set(this.form, k, valorAtual);
      });

      // 4) cache
      this.atributosForm = base;

      // 5) devolve a lista COMPLETA
      return base;
    },

    aplicarDataPadraoNosCampos(formData, atributos) {
      try {
        if (!formData || !Array.isArray(atributos)) return;

        const isVazio = v =>
          v == null || (typeof v === "string" && v.trim() === "");

        for (const attr of atributos) {
          const k = attr?.nm_atributo;
          if (!k) continue;

          const icPadrao =
            String(attr.ic_data_padrao || "N").toUpperCase() === "S";
          if (!icPadrao) continue;

          // detecta se é campo de data
          const rawTipo = String(
            attr.tp_atributo || attr.tipo || ""
          ).toUpperCase();
          const pareceNomeDeData = /(^dt(_|$))|(^data(_|$))|(_data$)|(_dt$)/i.test(
            k
          );
          const isDate =
            rawTipo.includes("DATE") ||
            rawTipo === "D" ||
            rawTipo === "DATA" ||
            pareceNomeDeData;

          if (!isDate) continue;

          // só aplica se estiver vazio
          if (isVazio(formData[k])) {
            const hoje = toIsoDate(new Date(), true); // "YYYY-MM-DD"
            this.$set(formData, k, hoje);
            // debug opcional:
            // console.log("✅ Data padrão aplicada:", k, hoje);
          } else {
            // se já tem valor, só normaliza pra "YYYY-MM-DD"
            const norm = toIsoDate(formData[k], true);
            if (norm && norm !== formData[k]) this.$set(formData, k, norm);
          }
        }
      } catch (e) {
        console.error("Erro ao aplicar data padrão:", e);
      }
    },

    obterAtributosParaFormOld() {
      // 1) se já estiver pronto, reuse
      if (Array.isArray(this.atributosForm) && this.atributosForm.length) {
        return this.atributosForm;
      }

      // 2) tente descobrir a “base” de atributos
      //    (gridMeta já é um ARRAY de atributos no seu log)

      let base =
        (Array.isArray(this.gridMeta) &&
          this.gridMeta.length &&
          this.gridMeta) ||
        (Array.isArray(this.gridMeta?.atributos) && this.gridMeta.atributos) ||
        (Array.isArray(this.gridMeta?.colunas) && this.gridMeta.colunas) ||
        (Array.isArray(this.colunasGrid) && this.colunasGrid) ||
        [];

      console.log("Base de Atributos.", base);

      // 3) NORMALIZAÇÃO: não “simplifique” os atributos aqui!
      //    Apenas garanta que Lista_Valor esteja em array

      base = base.filter(Boolean).map(a => {
        const attr = { ...a };

        // nm_atributo é obrigatório
        attr.nm_atributo = attr.nm_atributo || attr.dataField || attr.nome;

        // label padrão (só fallback, sem sobrescrever se já existir)
        attr.nm_edit_label =
          attr.nm_edit_label ||
          attr.nm_titulo_menu_atributo ||
          attr.caption ||
          attr.label ||
          attr.ds_atributo ||
          attr.nm_atributo;

        // Lista_Valor pode vir como string vazia, " ", ou JSON
        if (typeof attr.Lista_Valor === "string") {
          const s = attr.Lista_Valor.trim();
          if (s.startsWith("[") && s.endsWith("]")) {
            try {
              attr.Lista_Valor = JSON.parse(s);
            } catch {
              attr.Lista_Valor = [];
            }
          } else {
            attr.Lista_Valor = [];
          }
        }
        if (!Array.isArray(attr.Lista_Valor)) {
          attr.Lista_Valor = [];
        }

        // flags que podem vir null/undefined → normaliza com 'N'
        const flags = [
          "ic_atributo_chave",
          "ic_edita_cadastro",
          "ic_editavel",
          "ic_numeracao_automatica",
          "ic_numeracao_aumotatica",
          "ic_data_padrao",
        ];

        flags.forEach(f => {
          if (attr[f] == null) attr[f] = "N";
        });

        // === ADIÇÃO: detectar se é campo de DATA ===

        const rawTipo = String(
          attr.tp_atributo || attr.tipo || ""
        ).toUpperCase();
        const nome = String(attr.nm_atributo || "");
        const pareceNomeDeData = /(^dt(_|$))|(^data(_|$))|(_data$)|(_dt$)/i.test(
          nome
        );
        const isDate =
          rawTipo.includes("DATE") ||
          rawTipo === "D" ||
          rawTipo === "DATA" ||
          pareceNomeDeData;

        if (isDate) {
          attr.dataType = attr.dataType || "date";
          attr.__isDate = true; // marca para o renderer
          attr.display_format = attr.display_format || "dd/MM/yyyy";
          attr.date_serialization_format = "yyyy-MM-dd"; // date-only, sem fuso
          // (se você tiver um motor de componentes dinâmicos)
          if (!attr.edit_component) attr.edit_component = "dxDateBox";
          if (!attr.componentOptions) attr.componentOptions = {};
          Object.assign(attr.componentOptions, {
            type: "date",
            displayFormat: attr.display_format,
            dateSerializationFormat: attr.date_serialization_format,
            useMaskBehavior: true,
            pickerType: "calendar",
          });
        }

        return attr;
      });

      //
      // 3.1) Inicializa valores do form respeitando campos de DATA

      if (!this.form) this.form = {};

      // helper: hoje em YYYY-MM-DD
      const hojeISO = () => {
        const d = new Date();
        const y = d.getFullYear();
        const m = String(d.getMonth() + 1).padStart(2, "0");
        const day = String(d.getDate()).padStart(2, "0");
        return `${y}-${m}-${day}`;
      };

      // helper: vazio?
      const isVazio = v =>
        v == null || (typeof v === "string" && v.trim() === "");

      //Antes de Preecher os valores
      console.log("form->", this.form);

      //
      base.forEach(attr => {
        const k = attr.nm_atributo;

        // garante que existe formData (é isso que a tela normalmente usa)
        if (!this.formData) this.formData = {};
        if (!this.form) this.form = {};

        const valorAtual =
          this.formData && this.formData[k] != null
            ? this.formData[k]
            : this.form && this.form[k] != null
            ? this.form[k]
            : this.rowEdit && this.rowEdit[k] != null
            ? this.rowEdit[k]
            : attr.vl_atributo != null
            ? attr.vl_atributo
            : null;

        const isVazio = v =>
          v == null || (typeof v === "string" && v.trim() === "");

        // helper hoje
        const hojeISO = () => {
          const d = new Date();
          const y = d.getFullYear();
          const m = String(d.getMonth() + 1).padStart(2, "0");
          const day = String(d.getDate()).padStart(2, "0");
          return `${y}-${m}-${day}`;
        };

        // helper: ISO -> Date (sem timezone drift)
        const isoToDate = iso => {
          if (!iso) return null;
          const s = String(iso).slice(0, 10); // YYYY-MM-DD
          // força meia-noite local sem dar shift
          const [Y, M, D] = s.split("-").map(n => parseInt(n, 10));
          if (!Y || !M || !D) return null;
          return new Date(Y, M - 1, D);
        };

        if (attr.__isDate) {
          const usaPadrao =
            String(attr.ic_data_padrao || "N").toUpperCase() === "S";

          let iso = null;

          // se veio valor, normaliza para ISO
          if (!isVazio(valorAtual)) {
            iso = toIsoDate(valorAtual, true) || null;
          }

          // se está vazio e tem data padrão, aplica hoje
          if (!iso && usaPadrao) {
            iso = hojeISO();
            console.log(
              "Data padrao true mas na tela nao deu certo....no formData....."
            );
          }

          console.log("valores:", k, iso);

          // ✅ pulo do gato: para o DevExtreme renderizar SEM BRIGAR, passa Date
          const dateObj = iso ? isoToDate(iso) : null;

          // seta nos dois (mantém compatibilidade com qualquer parte do componente)
          this.$set(this.formData, k, dateObj);
          this.$set(this.form, k, dateObj);
        } else {
          this.$set(this.formData, k, valorAtual);
          this.$set(this.form, k, valorAtual);
        }
      });

      //

      // 4) cache local (opcional, se você usa como data)
      this.atributosForm = base;

      // 5) devolve a lista COMPLETA (com todos os metadados!)
      return base;
    },

    // salvar novo registro (form especial)

    async salvarNovo() {
      try {
        this.salvando = true;

        // valida mínimos
        const obrig = this.obterObrigatorios();
        const faltando = obrig.filter(c => !this.temValor(this.formData[c]));
        if (faltando.length) {
          this.notifyWarn(
            `Preencha os campos obrigatórios: ${faltando.join(", ")}`
          );
          this.salvando = false;
          return;
        }

        const p = this.payloadTabela || {};

        const payload = {
          nm_tabela: p.nm_tabela || p.nm_tabela_consulta, // da /api/payload-tabela
          nm_schema: p.nm_schema || "dbo",
          cd_usuario: Number(sessionStorage.getItem("cd_usuario")) || 1,
          cd_parametro: 1, // 1 = INCLUIR
          dados: { ...this.formData },
        };

        // (se sua proc exigir campos de auditoria, complete aqui)
        // payload.dados.cd_empresa = payload.dados.cd_empresa || Number(sessionStorage.getItem('fixo_cd_empresa')) || null;

        const { data } = await api.post("/api-dados-form", payload);

        // se a SP retornou a PK gerada, injeta no objeto (ex.: cd_xxx)

        if (Array.isArray(data) && data.length) {
          const ret = data[0];
          const chave = this.keyNameInfer(); // tenta descobrir o nome do campo-chave
          if (chave && ret[chave]) this.formData[chave] = ret[chave];
        }

        this.notifyOk("Registro incluído com sucesso.");
        this.dlgNovo = false;

        // recarrega grid com os filtros atuais
        await this.consultar();
        //
      } catch (e) {
        console.error("Erro ao incluir:", e);
        this.notifyErr("Erro ao incluir registro.");
      } finally {
        this.salvando = false;
      }
    },

    //

    obterObrigatorios() {
      // se sua meta marcar obrigatórios (ic_obrigatorio === 'S'), use isso
      const attrs = this.obterAtributosParaForm();
      return attrs
        .filter(a => a.ic_obrigatorio === "S")
        .map(a => a.nm_atributo);
    },

    temValor(v) {
      return !(v === null || v === undefined || v === "" || v === "null");
    },

    exportPdf() {
      // idem PDF
    },

    copiarDados() {
      try {
        const texto = JSON.stringify(this.rows || []);
        navigator.clipboard.writeText(texto);
        //this.$q.notify({ type:'positive', message:'Dados copiados' })
        this.notifyOk("Dados copiados!");
      } catch (_e) {
        //this.$q.notify({ type:'warning', message:'Não foi possível copiar' })
        this.notifyWarn("Não foi possível copiar!");
      }
    },

    abrirCalendario() {
      // opcional
    },

    abrirInfo() {
      // opcional: mostrar info do payload, etc
    },

    resolvType(f) {
      const nome = (f.nm_atributo || "").toLowerCase();

      if (
        nome.includes("dt_inicial") ||
        nome.includes("dt_final") ||
        f.nm_datatype === "date"
      )
        return "date";

      if (/(date|data)/.test(nome)) return "date";

      if (/(number|inteiro|decimal)/.test(nome)) return "number";

      return "text";
    },

    //

    async loadPayload(cd_menu, cd_usuario) {
      const isModal =
        String(this.ic_modal_pesquisa || "N").toUpperCase() === "S";
      // se for modal de pesquisa, NÃO limpa o menu pai

      //
      //console.log('menu do loadpayload -> ',cd_menu);

      const limparChaves = [
        "payload_padrao_formulario",
        "campos_grid_meta",
        "dados_resultado_consulta",
        "filtros_form_especial",
        "registro_selecionado",
        "mapa_consulta_para_atributo",
        "tab_menu",
        "ic_filtro_obrigatorio",
        "ic_crud_processo",
        "ic_detalhe_menu",
        "nome_procedure",
        "ic_json_parametro",
        "cd_relatorio",
        "cd_relatorio_auto",
      ];

      if (!isModal) {
        limparChaves.forEach(k => sessionStorage.removeItem(k));

        Object.keys(sessionStorage).forEach(k => {
          if (!k.endsWith(`_${cd_menu}`)) return;

          //const m = k.match(/^(payload_padrao_formulario|campos_grid_meta|dados_resultado_consulta|registro_selecionado|cd_menu_detalhe|payload_padrao_formulario_detalhe|campos_grid_meta_detalhe|id_pai_detalhe)_(\d+)$/);

          //if (!m) return;

          if (
            /(payload_padrao_formulario|campos_grid_meta|dados_resultado_consulta|registro_selecionado|cd_menu_detalhe|payload_padrao_formulario_detalhe|campos_grid_meta_detalhe|id_pai_detalhe)_(\d+)$/.test(
              k
            )
          ) {
            sessionStorage.removeItem(k);
          }
        });
      }

      //
      //payload - Body para chamada dos dados inicias do atributos para o Form/Menu
      //

      const payload = {
        cd_parametro: 1,
        cd_form: localStorage.cd_form, //sessionStorage.getItem("cd_form"),
        cd_menu: Number(cd_menu),
        nm_tabela_origem: "",
        cd_usuario: Number(cd_usuario),
        //
      };

      //console.log("payload->", payload, banco);

      //const { data } = await axios.post("/api/payload-tabela", payload);

      //
      //const { data } = await api.post("/payload-tabela", payload);
      //

      const data = await getPayloadTabela(payload);

      // { headers: { 'x-banco': banco } })

      //console.log('dados do retorno: ', data);
      //
      //////
      this.gridMeta = Array.isArray(data) ? data : [];
      //////

      this.cd_parametro_menu = this.gridMeta?.[0]?.cd_parametro_menu || 0;

      const metaProc = (this.gridMeta || []).find(
        r => Number(r.cd_menu_processo || 0) > 0
      );

      // cd_menu_processo (se houver)
      this.cd_menu_processo = metaProc ? Number(metaProc.cd_menu_processo) : 0;
      //

      // tabsheets (se houver)
      //Tabs Dinâmicas
      this.buildTabsheetsFromMeta(this.gridMeta);
      //

      // mapa de atributos (consulta → atributo)
      this.mapaRows = this._buildMapaRowsFromMeta(this.gridMeta);

      //console.log('grid: ', this.gridMeta, this.cd_parametro_menu  );

      // flag: quando cd_tabela > 0, consulta será direta na tabela
      this.cd_tabela = Number(this.gridMeta?.[0]?.cd_tabela) || 0;
      this.cd_relatorio = this.gridMeta?.[0]?.cd_relatorio || 0;

      //
      this.mostrarAcoes =
        this.cd_tabela > 0 ||
        this.ic_modal_pesquisa === "S" ||
        this.cd_relatorio > 0;
      //

      // título da tela

      this.title =
        this.gridMeta?.[0]?.nm_titulo ||
        sessionStorage.getItem("menu_titulo") ||
        "Formulário";

      if (!isModal) {
        sessionStorage.setItem(
          "payload_padrao_formulario",
          JSON.stringify(this.gridMeta)
        );
        sessionStorage.setItem(
          "campos_grid_meta",
          JSON.stringify(this.gridMeta)
        );
      }

      sessionStorage.setItem(
        `payload_padrao_formulario_${cd_menu}`,
        JSON.stringify(this.gridMeta)
      );

      sessionStorage.setItem(
        `campos_grid_meta_${cd_menu}`,
        JSON.stringify(this.gridMeta)
      );

      sessionStorage.setItem("menu_titulo", this.title);

      //console.log('consulta dos dados menu ->', this.gridMeta[0]);

      if (this.gridMeta?.length > 0) {
        this.nome_procedure = this.gridMeta?.[0]?.nome_procedure || "*";
        this.ic_json_parametro = this.gridMeta?.[0]?.ic_json_parametro || "N";
        this.cd_menu_modal =
          this.gridMeta?.[0].cd_menu_modal || this.cd_menu_modal_entrada || 0;
        this.cd_form_modal = this.gridMeta?.[0].cd_form_modal || 0;
        this.ic_grid_modal = this.gridMeta?.[0].ic_grid_modal || "N";
        this.ic_selecao_registro =
          this.gridMeta?.[0].ic_selecao_registro || "N";
        this.ic_card_menu = this.gridMeta?.[0].ic_card_menu || "N";
        this.ic_treeview_menu = this.gridMeta?.[0].ic_treeview_menu || "N";
        this.mostrarBotaoModalComposicao = this.cd_form_modal > 0;
        this.selectionMode =
          this.ic_selecao_registro === "S" ? "multiple" : "single";
        this.menuTabs = this.parseSqlTabs(this.gridMeta?.[0].sqlTabs);
        this.activeMenuTab = "principal";

        this.ic_card_menu = this.gridMeta?.[0]?.ic_card_menu || "N";
        this.ic_treeview_menu = this.gridMeta?.[0]?.ic_treeview_menu || "N";

        // se quiser já iniciar em cards quando o menu permitir:
        if (String(this.ic_card_menu).toUpperCase() === "S") {
          // mantém o valor se o usuário já trocou, senão default = true
          if (this.exibirComoCards === false) this.exibirComoCards = true;
        } else {
          this.exibirComoCards = false;
        }

        // default: se tree liberado, inicia em Tree (ou mantenha grid, você escolhe)
        if (String(this.ic_treeview_menu).toUpperCase() === "S") {
          if (this.exibirComoTree === false) this.exibirComoTree = true;

          //this.montarTreeview()
        } else {
          this.exibirComoTree = false;
        }

        console.log("Treeview", this.ic_treeview_menu, this.exibirComoTree);
      }

      //console.log('tabs menu ...', this.menuTabs);

      // tab_menu (se houver)
      sessionStorage.setItem("tab_menu", this.gridMeta?.[0]?.tab_menu || "");

      //Validação//
      //Se existe Tabela ou Procedimento

      if (this.temConfigConsultaInvalida()) {
        this.abrirAvisoConfigConsulta();
        return;
      }
      //

      // 1) MONTAR colunas e totalColumns (meta antigo)

      this.columns = this.gridMeta
        .filter(c => c.ic_mostra_grid === "S")
        .sort((a, b) => (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0))
        .map(c => ({
          dataField: c.nm_atributo || c.nm_atributo_consulta,
          caption: c.nm_titulo_menu_atributo || c.nm_atributo_consulta,
          format: c.formato_coluna || undefined,
          alignment: ["currency", "number", "percent", "fixedPoint"].includes(
            c.formato_coluna
          )
            ? "right"
            : "left",
          width: c.largura || undefined,
        }));

      // coluna de ações (editar / excluir)
      let colAcoes = null;

      if (this.cd_tabela > 0) {
        const vm = this;

        colAcoes = {
          type: "buttons",
          caption: "Ações",
          width: 170,
          alignment: "center",
          allowSorting: false,
          allowFiltering: false,
          buttons: [
            {
              hint: "Selecionar",
              icon: "check",
              visible: () => String(this.ic_modal_pesquisa || "N") === "S",
              onClick: e => {
                console.log("CLIQUE SELECIONAR (DENTRO DO onClick)", e);
                vm.selecionarERetornar(e);
              },
            },
            {
              hint: "Detalhes",
              icon: "chevrondoubleright", // ou "arrowright", "chevronnext" (depende do seu pacote)
              visible: () => this.menuTabs && this.menuTabs.length > 0, // só aparece se existir aba filha
              onClick: e => {
                // garante que não vai disparar outras ações da linha
                if (e?.event?.stopPropagation) e.event.stopPropagation();

                const row = e?.row?.data || null;
                if (!row) return;

                // chama seu método (o 1.2 que você já fez)
                this.abrirTabFilhaPorLinha(row);
              },
            },

            {
              hint: "Consultar",
              icon: "search",
              onClick: e => this.abrirFormConsulta({ registro: e.row.data }),
            },
            {
              hint: "Editar",
              icon: "edit",
              onClick: e =>
                this.abrirFormEspecial({ modo: "A", registro: e.row.data }),
            },
            {
              hint: "Copiar",
              icon: "copy",
              onClick: e => this.copiarRegistro(e.row.data),
            },

            {
              hint: "Relatório",
              icon: "print",
              visible: () => Number(this.cd_relatorio || 0) > 0,
              onClick: e => {
                // passa o registro atual
                this.onRelatorioGrid(e.row.data || {});
              },
            },

            {
              hint: "Excluir",
              icon: "trash",
              onClick: e => {
                // idem: objeto PLANO
                const plain = JSON.parse(JSON.stringify(e.row.data));
                this.onExcluir(plain);
              },
            },
          ],
        };
      } else {
        console.log("MONTANDO ACOES PARA MODAL DE PESQUISA", this.cd_relatorio);

        colAcoes = {
          type: "buttons",
          caption: "Ações",
          width: 90,
          alignment: "center",
          allowSorting: false,
          allowFiltering: false,
          buttons: [
            {
              hint: "Selecionar",
              icon: "check",
              cssClass: "btn-selecionar-modal",
              onClick: e =>
                //vm.selecionarERetornar( e.row.data ),
                {
                  console.log("CLIQUE SELECIONAR (DENTRO DO onClick) 2", e);
                  this.selecionarERetornar(e);
                },
            },

            {
              hint: "Detalhes",
              icon: "chevrondoubleright",
              visible: () => this.menuTabs && this.menuTabs.length > 0,
              onClick: e => {
                if (e?.event?.stopPropagation) e.event.stopPropagation();
                const row = e?.row?.data || null;
                if (!row) return;
                this.abrirTabFilhaPorLinha(row);
              },
            },

            // ✅ NOVO BOTÃO (opcional aqui)
            {
              hint: "Relatório",
              icon: "print",
              visible: () => Number(this.cd_relatorio || 0) > 0,
              onClick: e => this.onRelatorioGrid(e.row.data || {}),
            },
          ],
        };
      }

      //summary e totalizadores

      //
      this.totalColumns = this.gridMeta
        .filter(c => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
        .map(c => ({
          dataField: c.nm_atributo || c.nm_atributo_consulta,
          type: c.ic_total_grid === "S" ? "sum" : "count",
          display: c.ic_total_grid === "S" ? "Total: {0}" : "{0} registro(s)",
        }));

      this.total = { totalItems: this.totalColumns };

      const mapa = {};

      this.gridMeta.forEach(c => {
        if (c.nm_atributo && c.nm_atributo_consulta) {
          //mapa[c.nm_atributo] = c.nm_atributo_consulta;
          mapa[c.nm_atributo_consulta] = c.nm_atributo;
        }
      });

      sessionStorage.setItem(
        "mapa_consulta_para_atributo",
        JSON.stringify(mapa)
      );
      //
      sessionStorage.setItem(
        this.ssKey("mapa_consulta_para_atributo"),
        JSON.stringify(mapa)
      );

      // console.log('mapa:', mapa);

      //this.total = { totalItems: this.totalColumns };

      // guarde o meta dos campos (usado na consulta e exportação)
      this.camposMetaGrid = this.gridMeta;
      //

      // 2) NORMALIZAR dados (datas → Date, números → Number, etc.)
      const normalizados = normalizarTipos(data, this.gridMeta);

      //console.log('normalizados:', normalizados);

      // 3) MONTAR colunas e summary
      this.gridColumns = buildColumnsFromMeta(this.gridMeta);
      this.gridSummary = buildSummaryFromMeta(this.gridMeta);

      //
      //

      // 4) ATUALIZAR estado
      this.gridRows = normalizados;

      //this.columns = this.gridColumns;
      this.total = this.gridSummary;

      // põe no início da lista de colunas

      if (this.mostrarAcoes) {
        this.columns = [colAcoes, ...this.gridColumns];
      } else {
        this.columns = [...this.gridColumns];
      }

      //Legenda de Ações
      this.aplicarLegendaAcoesGrid();
      //
      //ccf
      //this.keyName = this.keyNameInfer("db"); // ex.: cd_processo

      //

      // 5) NUNCA popular dados aqui; zera!

      this.rows = [];
      this.gridRows = [];
      this.totalQuantidade = 0;
      this.totalValor = 0;
    },

    getAcoesGridCores(valor) {
      if (!valor) return [];

      //console.log("getAcoesGridCores valor bruto =>", valor);

      // se já for array
      if (Array.isArray(valor)) {
        // guarda como legenda se ainda não estiver preenchido
        if (!this.legendaAcoesGrid.length) {
          this.legendaAcoesGrid = valor;
        }
        return valor;
      }

      // se veio como string JSON (seu caso)
      if (typeof valor === "string") {
        const txt = valor.trim();
        if (!txt) return [];
        try {
          const parsed = JSON.parse(txt);

          if (Array.isArray(parsed)) {
            //return parsed;
            if (!this.legendaAcoesGrid.length) {
              this.legendaAcoesGrid = parsed;
            }
            return parsed.slice(0, 5);
          }
        } catch (e) {
          console.warn("JSON inválido em acoesGridColor:", e);
          return [];
        }
      }

      return [];
    },

    aplicarLegendaAcoesGrid() {
      if (!this.columns || !this.columns.length) return;

      // Legenda de Ações: injeta coluna visual na frente se existir acoesGridColor
      const temAcoesGridColor = (this.columns || []).some(
        c => c && c.dataField === "acoesGridColor"
      );

      if (temAcoesGridColor) {
        this.columns = [
          {
            caption: "Legenda",
            width: 80,
            allowSorting: false,
            allowFiltering: false,
            allowGrouping: false,
            allowHeaderFiltering: false,
            cellTemplate: "acoesGridColorCellTemplate", // 👈 AGORA GARANTE O TEMPLATE
          },
          ...this.columns,
        ];

        //console.log('columns com ações --> ', this.columns);
      }
    },

    acoesGridColorCellTemplate(container, options) {
      const row = options && options.data;
      if (!row) return;

      const cores = this.getAcoesGridCores(row.acoesGridColor);
      if (!cores || !cores.length) return;

      let el = container;
      if (el && el.get && typeof el.get === "function") {
        el = el.get(0);
      }
      if (!el) return;

      const doc = el.ownerDocument || document;

      const wrapper = doc.createElement("div");
      wrapper.className = "acoes-grid-color-wrapper";

      cores.forEach(item => {
        const cor = item && item.cor ? String(item.cor).trim() : "";
        if (!cor) return;

        const dot = doc.createElement("span");
        dot.className = "acoes-grid-color-dot bg-" + cor;
        wrapper.appendChild(dot);
      });

      el.appendChild(wrapper);

      // marca o TD dessa coluna pra tratarmos no onRowPrepared
      const td = el.closest ? el.closest("td") : el.parentElement;
      if (td) {
        td.classList.add("acoes-grid-color-cell");
      }
    },

    acoesGridColorCellTemplateold(container, options) {
      // DevExtreme passa a linha em options.data
      const row = options && options.data;
      if (!row) return;

      const cores = this.getAcoesGridCores(row.acoesGridColor);

      //console.log("cores calculadas =>", cores);

      if (!cores || !cores.length) return;

      // na maior parte dos casos já é um elemento DOM
      let el = container;
      if (el && el.get && typeof el.get === "function") {
        // se for dxElement / jQuery wrapper
        el = el.get(0);
      }
      if (!el) return;

      const doc = el.ownerDocument || document;

      const wrapper = doc.createElement("div");
      wrapper.className = "acoes-grid-color-wrapper";

      cores.forEach(item => {
        const cor = item && item.cor ? String(item.cor).trim() : "";
        if (!cor) return;

        const dot = doc.createElement("span");
        // Quasar: bg-grey-7, bg-deep-orange-7, etc
        dot.className = "acoes-grid-color-dot bg-" + cor;
        wrapper.appendChild(dot);
      });

      el.appendChild(wrapper);

      // 👇 marca o TD dessa coluna pra não receber cor de linha
      const td = el.closest ? el.closest("td") : el.parentElement;
      if (td) {
        td.classList.add("acoes-grid-color-cell");
      }
    },

    //novo

    async loadFiltros(cd_menu, cd_usuario) {
      const { data } = await api.post(
        "/menu-filtro",
        { cd_menu: Number(cd_menu), cd_usuario: Number(cd_usuario) },
        { headers: { "x-banco": banco } }
      );

      this.filtros = Array.isArray(data) ? data : [];

      //console.log("Filtro Preenchimento --> ", this.filtros);

      for (const f of this.filtros) {
        // Chaves normalizadas
        const chaveLookup = (f.nm_campo_chave_lookup || "").trim(); // pode ser ''
        const destino =
          chaveLookup !== "" ? chaveLookup : (f.nm_atributo || "").trim(); // fallback para nm_atributo
        const descFieldName = (f.nm_campo_descricao_lookup || "").trim(); // ex.: "Estado"

        // Se não temos destino válido, pula (evita criar chave "")
        if (!destino) {
          console.warn("Filtro sem chave e sem atributo válido:", f);
          continue;
        }

        // 1) Define valor padrão inicial (antes do lookup), sem criar chave vazia
        if (f.nm_valor_padrao != null && this.filtrosValores[destino] == null) {
          const tipo = this.resolvType(f);
          const val =
            tipo === "date"
              ? this.toYMD(f.nm_valor_padrao)
              : String(f.nm_valor_padrao);
          this.$set(this.filtrosValores, destino, val);

          //console.log(`Definindo valor padrão do filtro ${destino} = ${val}`);
        }

        // 2) Filtros fixos: salvar com a chave correta
        if (f.ic_fixo_filtro === "S") {
          sessionStorage.setItem(`fixo_${destino}`, f.nm_valor_padrao);
          continue;
        }

        // 3) Lookup de tabela
        if (f.nm_lookup_tabela && f.nm_lookup_tabela.trim()) {
          try {
            const rows = await this.postLookup(f.nm_lookup_tabela);

            const opts = Array.isArray(rows)
              ? rows.map(r => {
                  const lower = {};
                  Object.entries(r || {}).forEach(([k, v]) => {
                    lower[String(k).toLowerCase()] = v;
                  });

                  const keyField = (chaveLookup || destino || "").toLowerCase(); // prioridade para cd_estado; se vazio, usa nm_atributo
                  const descField = (descFieldName || "").toLowerCase(); // alias do SQL, ex.: "estado"

                  const values = Object.values(r || {});
                  const code =
                    lower[keyField] != null ? lower[keyField] : values[0];

                  const label = descField
                    ? lower[descField] != null
                      ? lower[descField]
                      : values[1] != null
                      ? values[1]
                      : code
                    : lower.descricao != null
                    ? lower.descricao
                    : values[1] != null
                    ? values[1]
                    : code;

                  return { value: String(code), label: String(label) };
                })
              : [];

            this.$set(f, "_options", [
              { value: "", label: "Selecione..." },
              ...opts,
            ]);

            // 4) Ajuste do valor padrão baseado nas opções (garante código no destino)
            if (
              f.nm_valor_padrao != null &&
              this.filtrosValores[destino] == null
            ) {
              const padrao = String(f.nm_valor_padrao);
              const optValue = (f._options || []).find(o => o.value === padrao);
              const optLabel = (f._options || []).find(o => o.label === padrao);
              const chosen = optValue || optLabel;
              const val = chosen ? chosen.value : padrao;

              this.$set(this.filtrosValores, destino, val);

              // Se também quiser armazenar o label textual em nm_campo (ex.: nm_estado), faz aqui
              if (chosen && f.nm_campo) {
                this.$set(this.filtrosValores, f.nm_campo, chosen.label);
              }
            }
          } catch (e) {
            console.error("erro lookup filtros", e);
            this.$set(f, "_options", [
              { value: "", label: "Erro ao carregar" },
            ]);
          }
        }
      }

      // 5) Restaura filtros salvos
      const salvos = JSON.parse(
        sessionStorage.getItem("filtros_form_especial") || "{}"
      );
      Object.keys(salvos).forEach(k =>
        this.$set(this.filtrosValores, k, salvos[k])
      );

      // 6) Pós-carregamento
      this.$nextTick(() => this.preencherDatasDoMes());

      //console.log("filtros carregados:", this.filtrosValores);
    },

    //
    async loadFiltrosVelho(cd_menu, cd_usuario) {
      //console.log(banco);

      const { data } = await api.post(
        "/menu-filtro",
        {
          cd_menu: Number(cd_menu),
          cd_usuario: Number(cd_usuario),
        },
        { headers: { "x-banco": banco } }
      );

      this.filtros = Array.isArray(data) ? data : [];

      //console.log('Filtro Preenchimento --> ', this.filtros);

      for (const f of this.filtros) {
        //console.log('filtro para o payload --> ', f.nm_campo_chave_lookup);

        if (
          f.nm_valor_padrao != null &&
          this.filtrosValores[f.nm_campo_chave_lookup] == null
        ) {
          const tipo = this.resolvType(f); // <- novo

          const val =
            tipo === "date" // <- novo
              ? this.toYMD(f.nm_valor_padrao) // <- novo (aceita "dd/mm/aaaa" ou Date)
              : f.nm_valor_padrao;

          if (f.nm_campo_chave_lookup != "") {
            console.log(
              `Definindo valor padrão do filtro ${f.nm_campo_chave_lookup} = ${val}`
            );
            this.$set(this.filtrosValores, f.nm_campo_chave_lookup, val);
          } else {
            this.$set(this.filtrosValores, f.nm_atributo, val);
          }
        }

        // -----------------------------------------------------

        if (f.ic_fixo_filtro === "S") {
          if (f.nm_campo_chave_lookup != "") {
            sessionStorage.setItem(
              `fixo_${f.nm_campo_chave_lookup}`,
              f.nm_valor_padrao
            );
          } else {
            sessionStorage.setItem(`fixo_${f.nm_atributo}`, f.nm_valor_padrao);
          }
          continue;
        }

        if (
          f.nm_valor_padrao != null &&
          this.filtrosValores[f.nm_campo_chave_lookup] == null
        ) {
          // se o lookup já trouxe opções, tenta casar pelo label
          const opt = (f._options || []).find(
            o => o.label === f.nm_valor_padrao || o.value === f.nm_valor_padrao
          );

          const val = opt ? opt.value : f.nm_valor_padrao;

          this.$set(this.filtrosValores, f.nm_campo_chave_lookup, val);
        } else {
          // se o lookup já trouxe opções, tenta casar pelo label
          const opt = (f._options || []).find(
            o => o.label === f.nm_valor_padrao || o.value === f.nm_valor_padrao
          );

          const val = opt ? opt.value : f.nm_valor_padrao;

          this.$set(this.filtrosValores, f.nm_atributo, val);
        }

        //console.log('lookup -> ', f.nm_lookup_tabela);

        // lookup de tabela
        if (f.nm_lookup_tabela && f.nm_lookup_tabela.trim()) {
          try {
            // usa o helper do componente
            const rows = await this.postLookup(f.nm_lookup_tabela);

            const opts = Array.isArray(rows)
              ? rows.map(r => {
                  const vals = Object.values(r || {});
                  const nomeCampo = (
                    f.nm_campo_chave_lookup || ""
                  ).toLowerCase();

                  // acesso case-insensitive ao campo código

                  const lower = {};

                  Object.entries(r || {}).forEach(([k, v]) => {
                    lower[String(k).toLowerCase()] = v;
                  });

                  const code =
                    lower[nomeCampo] != null ? lower[nomeCampo] : vals[0];

                  //console.log('code', code);

                  const label =
                    lower.descricao != null
                      ? lower.descricao
                      : vals[1] != null
                      ? vals[1]
                      : code;

                  //console.log('label -->', label)

                  return {
                    value: String(code),
                    label: String(label),
                  };
                })
              : [];

            this.$set(f, "_options", [
              { value: "", label: "Selecione..." },
              ...opts,
            ]);
          } catch (e) {
            console.error("erro lookup filtros", e);
            this.$set(f, "_options", [
              { value: "", label: "Erro ao carregar" },
            ]);
          }
        }
        //
      }

      const salvos = JSON.parse(
        sessionStorage.getItem("filtros_form_especial") || "{}"
      );

      //console.log('filtros salvos --> ', salvos);

      Object.keys(salvos).forEach(k =>
        //console.log('montagem: ', this.filtrosValores, k, salvos[k])
        this.$set(this.filtrosValores, k, salvos[k])
      );

      // se tiver filtro de data no form, preencha datas do mês atual
      this.$nextTick(() => this.preencherDatasDoMes());
      //
      //console.log("filtros carregados:", this.filtrosValores);
      //
    },

    ///////////////////////////////////////////////////////////////////////////////////////////////

    getCdParametroContexto() {
      // 0) Se o menu tem um parâmetro “fixo”
      const fromMenu = Number(this.cd_parametro_menu || 0);
      if (fromMenu > 0)
        console.log("cd_parametro vindo do menu (fixo) = ", fromMenu);

      return fromMenu;
      //

      // 1) Prioridade: vem do registro pai (embed/composição)
      const fromPai = Number(this.registro_pai?.cd_parametro || 0);
      if (fromPai > 0) return fromPai;

      // 2) Se o filtro trouxe (string “200”), aproveita
      const fromFiltro = Number(this.filtrosValores?.cd_parametro || 0);
      if (fromFiltro > 0) return fromFiltro;

      // 4) fallback geral (caso o app guarde em storage)
      const fromLS = Number(localStorage.cd_parametro || 0);
      if (fromLS > 0) return fromLS;

      return 0;
    },
    ///////////////////////////////////////////////////////////////////////////////////

    // função principal: monta payload e chama a procedure

    async consultar(payloadManual = null) {
      this.loading = true;
      this.registrosSelecionados = [];

      if (this.ic_selecao_registro === "S") {
        this.$nextTick(() => {
          //const c = this.$refs.consultaRef;
          //if (c && typeof c.clearSelection === "function") {
          //  c.clearSelection();
          //  }
          const grid = this.$refs.grid;
          const inst = grid && grid.instance;
          if (inst && typeof inst.clearSelection === "function") {
            inst.clearSelection();
          }
        });
      }

      //console.log('Iniciando consulta...', this.ic_json_parametro, this.nome_procedure);
      // monta payload e chama a procedure

      try {
        //const cd_menu = Number(sessionStorage.getItem("cd_menu"));

        const cd_usuario =
          localStorage.cd_usuario ||
          Number(sessionStorage.getItem("cd_usuario"));
        const dt_inicial =
          localStorage.dt_inicial ||
          sessionStorage.getItem("dt_inicial_padrao");
        const dt_final =
          localStorage.dt_final || sessionStorage.getItem("dt_final_padrao");
        const banco =
          localStorage.nm_banco_empresa ||
          sessionStorage.getItem("banco") ||
          "";

        const campos = {};

        Object.keys(sessionStorage)
          .filter(k => k.startsWith("fixo_"))
          .forEach(
            k => (campos[k.replace("fixo_", "")] = sessionStorage.getItem(k))
          );

        //console.log('valores dos filtros -->', this.filtrosValores);

        Object.assign(campos, this.filtrosValores);

        // 🔹 1) Achata objetos de lookup { value, label } => "value"

        Object.keys(campos).forEach(k => {
          const v = campos[k];
          if (v && typeof v === "object" && "value" in v) {
            campos[k] = v.value; // ex.: sg_estado: {value:"5",label:"BA"} -> "5"
          }
        });

        // validação de filtros obrigatórios

        this.cd_relatorio = this.gridMeta?.[0]?.cd_relatorio || 0;

        // console.log('relatório do menu:', this.cd_relatorio);

        const ic_filtro_obrigatorio = this.gridMeta?.[0]?.ic_filtro_obrigatorio;
        const ic_cliente = this.gridMeta?.[0]?.ic_cliente || "N";
        const cd_cliente =
          localStorage.cd_cliente ||
          Number(sessionStorage.getItem("cd_cliente")) ||
          0;

        const filtroPreenchido = Object.values(campos).some(
          v => v != null && v !== "" && v !== 0
        );

        //console.log('filtro --> ', filtroPreenchido,campos);

        //const cd_parametro      = this.cd_parametro_menu || 0;
        const cd_parametro = this.getCdParametroContexto();
        //

        //const cd_chave_pesquisa = localStorage.cd_acesso_entrada || this.ncd_acesso_entrada || this.cd_chave_pesquisa || 0;

        const cd_chave_pesquisa = this.embedMode
          ? this.cd_chave_pesquisa ||
            this.ncd_acesso_entrada ||
            this.cd_acesso_entrada ||
            0
          : localStorage.cd_acesso_entrada ||
            this.ncd_acesso_entrada ||
            this.cd_chave_pesquisa ||
            0;

        //console.log('chave de pesquisa', cd_chave_pesquisa);

        //Menu
        //20.12.2025 (ccf)
        //const cd_menu =
        //  this.gridMeta?.[0]?.cd_menu ||
        //  Number(sessionStorage.getItem("cd_menu")) ||
        //  0;

        const cd_menu =
          Number(this.ncd_menu_entrada || this.cd_menu_entrada || 0) ||
          this.gridMeta?.[0]?.cd_menu ||
          Number(sessionStorage.getItem("cd_menu")) ||
          0;

        //console.log('parametro = ',payloadManual, cd_parametro);

        if (ic_filtro_obrigatorio === "S" && !filtroPreenchido) {
          //this.$q.notify({ type: "warning", message: "Atenção: Nenhum filtro preenchido para consulta." });
          this.notifyWarn("Atenção: Nenhum filtro preenchido para consulta.");
          return;
        }

        // monta payload conforme o que foi passado (manual ou automático)

        await this.runHook("beforeFetchRows", {
          cd_menu: this.cd_menu,
          filtros: this.filtrosValores,
        });

        //

        let dados = [];
        let payloadExec;

        //console.log('campos do form:', campos);

        // campos vem dinâmicos do seu form
        const camposNormalizados = normalizePayload(campos);

        //console.log('campos da consulta:', camposNormalizados);
        //console.log(campos);
        // se nome_procedure = "*", usa o endpoint /menu-pesquisa (payload padrão)
        //console.log('nome_procedure:', this.nome_procedure);

        if (this.nome_procedure === "*" || this.nome_procedure === undefined) {
          //console.log('usando endpoint /menu-pesquisa');

          // ✅ não deixa filtros sobrescreverem campos reservados do menu-pesquisa
          const camposPayload = { ...campos };
          //
          delete camposPayload.cd_parametro;
          delete camposPayload.cd_menu;
          delete camposPayload.cd_usuario;
          delete camposPayload.cd_chave_pesquisa;
          delete camposPayload.ic_modal_pesquisa;

          const payload = [
            {
              cd_parametro,
              cd_menu,
              cd_usuario: localStorage.cd_usuario || this.cd_usuario || 0,
              cd_chave_pesquisa:
                cd_chave_pesquisa || Number(this.cd_acesso_entrada || 0),
              //ic_modal_pesquisa: this.getIcModalPesquisa() || this.ic_modal_pesquisa || 'N',
              ic_modal_pesquisa:
                (this.getIcModalPesquisa && this.getIcModalPesquisa()) ||
                this.ic_modal_pesquisa ||
                "N",
              ...camposPayload,
              //dt_inicial, dt_final,
              //dt_inicial: clean(sessionStorage.getItem("dt_inicial_padrao")),
              //dt_final:   clean(sessionStorage.getItem("dt_final_padrao")),
              //...campos,
              //...camposNormalizados,
              ...(ic_cliente === "S" && cd_cliente > 0 ? { cd_cliente } : {}),
            },
          ];

          //const payloadNew = this.montarPayloadPesquisa();

          //console.log('payload da consulta:', payloadNew);

          console.log(" >>>> payload da consulta: >>>> ", payload);

          //
          //pr_egis_pesquisa_dados
          // chama o endpoint padrão de pesquisa
          ///////////////////////////////////////////////////////////////////////////////
          const { data } = await api.post("/menu-pesquisa", payload);
          dados = data;
          //
        } else {
          // senão, chama a procedure com o payload montado
          if (payloadManual && !(payloadManual instanceof Event)) {
            //payloadExec = JSON.stringify(payloadManual);
            payloadExec = payloadManual; // já é objeto/array
          } else {
            payloadExec =
              //this.ic_json_parametro === "S"
              //  ? JSON.stringify([{ ic_json_parametro: "S", ...campos }])
              //  : JSON.stringify({ ic_json_parametro: "N", ...campos });
              this.ic_json_parametro === "S"
                ? [
                    {
                      cd_parametro,
                      cd_usuario:
                        localStorage.cd_usuario || this.cd_usuario || 0,
                      ic_json_parametro: "S",
                      ...camposNormalizados,
                      ...(ic_cliente === "S" && cd_cliente > 0
                        ? { cd_cliente }
                        : {}),
                      ic_modal_pesquisa: this.ic_modal_pesquisa || "N",
                      dt_inicial,
                      dt_final,
                    },
                  ]
                : {
                    ic_json_parametro: "N",
                    ...camposNormalizados,
                    ...(ic_cliente === "S" && cd_cliente > 0
                      ? { cd_cliente }
                      : {}),
                    cd_usuario: localStorage.cd_usuario || this.cd_usuario || 0,
                  };
          }

          //
          console.log(
            "payload da consulta:",
            this.nome_procedure,
            payloadExec,
            banco
          );
          //

          //
          // chama a procedure
          //onsole.log('Chamando procedure:', this.nome_procedure);
          //

          const { data } = await api.post(
            `/exec/${this.nome_procedure}`,
            payloadExec
          );

          //

          // ajusta nomes dos campos conforme o mapa (nm_atributo_consulta -> nm_atributo)

          const mapaOriginal = JSON.parse(
            sessionStorage.getItem("mapa_consulta_para_atributo") || "{}"
          );
          // inverte: técnico->consulta  ==> consulta->técnico
          const mapa = {};
          Object.keys(mapaOriginal).forEach(tec => {
            mapa[mapaOriginal[tec]] = tec;
          });

          //
          dados = (data || []).map(item => {
            const novo = {};
            Object.keys(item).forEach(k => (novo[mapa[k] || k] = item[k]));
            return novo;
          });
        }

        //this.rows = (dados || []).map((it, idx) => ({ id: it.id || idx + 1, ...it }));

        //
        this.ic_pesquisa_banco = "S";
        //
        //Dados do Retorno do Back-End procedure pr_egis_pesquisa_dados ou pr do Menu
        this.rows = (dados || []).map((it, idx) => ({
          id: it.id || idx + 1,
          ...it,
        }));
        //
        //Chave-pk--
        this.garantirPkNoRows();

        //
        this.sortRowsForTreeAndGrid();
        //

        if (
          String(this.ic_treeview_menu || "N").toUpperCase() === "S" &&
          this.exibirComoTree
        ) {
          this.$nextTick(() => this.montarTreeview());
        }

        //DashBoard
        this.dashboardRows = this.rows;
        //

        // >>> NOVO: se veio do botão lápis (modal de pesquisa),
        // abre automaticamente o formulário de edição

        if (this.ic_modal_pesquisa === "S") {
          const chave = this.keyNameInfer(); // tenta descobrir o campo PK
          const valorChave =
            this.ncd_acesso_entrada ||
            this.cd_acesso_entrada ||
            localStorage.cd_acesso_entrada ||
            localStorage.cd_chave_pesquisa ||
            null;

          if (chave && valorChave != null) {
            const registro = this.rows.find(
              r => String(r[chave]) === String(valorChave)
            );

            if (registro) {
              this.$nextTick(() => {
                this.abrirFormEspecial({ modo: "A", registro }); // edição direta
              });
            }
          }
        }

        //
        await this.salvarCacheSeguro("dados_resultado_consulta", this.rows);

        await this.salvarCacheSeguro(
          this.ssKey("dados_resultado_consulta"),
          this.rows
        );

        await this.salvarCacheSeguro(
          "filtros_form_especial",
          this.filtrosValores
        );

        await this.salvarCacheSeguro(
          this.ssKey("filtros_form_especial"),
          this.filtrosValores
        );

        //console.log('mapa', dados);
        //console.log('resultado', this.rows);

        // 🔴 AQUI: extrai fasePedido da primeira linha

        if (this.rows && this.rows.length && this.rows[0].fasePedido) {
          try {
            // pode vir como array ou como string JSON
            const valor = this.rows[0].fasePedido;
            this.fasePedido = Array.isArray(valor) ? valor : JSON.parse(valor);
          } catch (e) {
            console.warn("Erro ao parsear fasePedido:", e);
            this.fasePedido = [];
          }

          // só fases com cor definida
          this.legendaAcoesGrid = (this.fasePedido || []).filter(
            f => f && f.nm_cor
          );

          //console.log("legendaAcoesGrid =>", this.legendaAcoesGrid);
        } else {
          this.fasePedido = [];
          this.legendaAcoesGrid = [];
        }

        // totais simples para o rodapé
        this.totalQuantidade = this.totalColumns.some(c => c.type === "count")
          ? this.rows.length
          : 0;

        this.totalValor = this.totalColumns
          .filter(c => c.type === "sum")
          .reduce(
            (acc, c) =>
              acc +
              this.rows.reduce((s, r) => s + Number(r[c.dataField] || 0), 0),
            0
          );

        //this.$q.notify({ type: "positive", message: `Consulta finalizada: ${this.rows.length} registros.`,
        //  position: 'top-right', timeout: 3000,
        //  action: [{ icon: 'close', color: 'white' }]

        //}
        //);

        //
        await this.runHook("afterFetchRows", {
          cd_menu: this.cd_menu,
          rows: this.rows,
        });
        //

        this.notifyOk(`Consulta finalizada: ${this.rows.length} registro(s).`);

        this.panelIndex = 1; // mostra a grid

        console.log("this rows --> linhas para relatório ", this.rows);
        this.$nextTick(() => {
          try {
            const inst =
              this.$refs && this.$refs.grid && this.$refs.grid.instance
                ? this.$refs.grid.instance
                : null;

            if (inst) {
              inst.beginUpdate();
              inst.option("dataSource", this.rows); // 2º: dataSource
              inst.option("focusedRowEnabled", true);
              inst.endUpdate();
              inst.refresh();
            }
          } catch (e) {
            console.warn("Não consegui aplicar keyExpr/dataSource:", e);
          }
        });

        //Total de Registros - Badge
        this.qt_registro = this.rows.length;
        //
      } catch (e) {
        console.error("Erro na consulta:", e);
        //this.$q.notify({ type: "negative", message: "Erro ao consultar dados." });
        this.notifyErr("Erro ao consultar dados !");
      } finally {
        this.loading = false;
      }
    },

    garantirPkNoRows() {
      const meta = Array.isArray(this.gridMeta) ? this.gridMeta : [];
      const rows = Array.isArray(this.rows) ? this.rows : [];

      if (!meta.length || !rows.length) return;

      // pega PK do meta (nome de banco)
      const pkMeta = meta.find(
        m => String(m.ic_atributo_chave || "").toUpperCase() === "S"
      );
      if (!pkMeta) return;

      const pk = (pkMeta.nm_atributo || "").trim(); // ex.: cd_tabela_preco
      if (!pk) return;

      // qual chave "existe" no row hoje? (caption / consulta)
      const candidatos = [
        pkMeta.nm_atributo_consulta,
        pkMeta.nm_edit_label,
        pkMeta.nm_filtro,
        pkMeta.caption,
      ]
        .filter(Boolean)
        .map(s => String(s).trim());

      const row0 = rows[0] || {};
      const chaveExistenteNoRow = candidatos.find(k =>
        Object.prototype.hasOwnProperty.call(row0, k)
      );

      if (!chaveExistenteNoRow) return;

      // injeta pk (nome de banco) usando o valor que já existe no row (caption)
      rows.forEach(r => {
        if (r && (r[pk] === undefined || r[pk] === null)) {
          r[pk] = r[chaveExistenteNoRow];
        }
      });
    },

    async getRowsFullFromSession() {
      const k1 = this.ssKey ? this.ssKey("dados_resultado_consulta") : null;

      if (k1) {
        const scoped = await this.lerCacheSeguro(k1);
        if (scoped) return scoped;
      }

      const raw = await this.lerCacheSeguro("dados_resultado_consulta");
      if (raw) return raw;

      return [];
    },

    async setRowsFullToSession(rows) {
      await this.salvarCacheSeguro("dados_resultado_consulta", rows);

      const k1 = this.ssKey ? this.ssKey("dados_resultado_consulta") : null;
      if (k1) {
        await this.salvarCacheSeguro(k1, rows);
      }
    },

    onRowDblClick(e) {
      const data = e.data;
      sessionStorage.setItem("registro_selecionado", JSON.stringify(data));
      const cd_menu = sessionStorage.getItem("cd_menu");
      sessionStorage.setItem(
        `registro_selecionado_${cd_menu}`,
        JSON.stringify(data)
      );

      if (this.isPesquisa && window.confirmarRetornoPesquisa) {
        window.confirmarRetornoPesquisa();
      }
    },
  },
};

//
//<style scoped src="@/css/unico/antigo.css"></style>
//

//<style scoped src="@/css/unico/grid.css"></style>
//<style scoped src="@/css/unico/filters.css"></style>
//<style scoped src="@/css/unico/dialog.css"></style>
</script>

<style scoped src="@/css/unico/grid.css"></style>
<style scoped src="@/css/unico/filters.css"></style>
<style scoped src="@/css/unico/dialog.css"></style>
