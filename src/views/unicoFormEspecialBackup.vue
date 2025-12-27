<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />

    <!-- TOPO no estilo -->

    <div class="row items-center">
      <transition name="slide-fade">
        <!-- título + seta + badge -->
        <h2 class="content-block col-8" v-show="tituloMenu || title">
          <!-- seta voltar -->
          <q-btn
            flat
            round
            dense
            icon="arrow_back"
            class="q-mr-sm"
            aria-label="Voltar"
            @click="onVoltar"
          />
          <span :class="ic_modal_pesquisa === 'S' ? 'titulo-modal' : ''">
            {{ tituloMenu || title }}
            </span>

          <!--{{ tituloMenu || title }}-->

          <!-- badge com total de registros -->

          <q-badge
            v-if="(qt_registro || recordCount) >= 0"
            align="middle"
            rounded            
            color="red"
            :label="qt_registro || recordCount"
            class="q-ml-sm bg-form"
          />

          <q-btn
            v-if="cd_tabela > 0"
            dense
            rounded
            color="deep-purple-7"
            :class="['q-mt-sm', 'q-ml-sm', cd_tabela != 0 ? 'fo-margin' : '']"
            icon="add"
            size="lg"
            @click="abrirFormEspecial({ modo: 'I', registro: {} })"
          />
          
        <q-btn
          dense
          rounded
          icon="refresh"
          color="deep-purple-7"
          size="lg"
          :class="['q-mt-sm', 'q-ml-sm', cd_tabela === 0 ? 'fo-margin' : '']"
          @click="onRefreshConsulta"
       />
   
           <q-btn
            v-if="cd_form_modal>0"
          rounded
          dense
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="tune"
          size="lg"
          :disable="cd_form_modal <= 0"
          @click="abrirModalComposicao"
        />

<modal-composicao
  v-if="mostrarBotaoModalComposicao"
  v-model="dialogModalComposicao"
  :cd-modal="cd_form_modal"
  :registros-selecionados="registrosSelecionados"  
  @sucesso="onRefreshConsulta"
/>

          <q-btn
          rounded
          dense
          color="deep-purple-7"
          icon="far fa-file-excel"
          class="q-mt-sm q-ml-sm"
          size="lg"
          @click="exportarExcel && exportarExcel()"
        />

        <q-btn
          rounded
          dense
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="picture_as_pdf"
          size="lg"
          @click="exportarPDF && exportarPDF()"
        />

        <q-btn
          rounded
          dense
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="description"
          size="lg"
          @click="abrirRelatorio"
        />

      <q-btn
        dense
        rounded
        color="deep-purple-7"
        icon="dashboard"
        size="lg"
        class="q-mt-sm q-ml-sm"
        @click="abrirDashboardDinamico"    
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
      size="lg"
      @click="abrirMenuProcessos"
     />
        <q-btn
           rounded
           dense
           color="deep-purple-7"
           class="q-mt-sm q-ml-sm"
           icon="view_list"   
           size="lg"        
           @click="dlgMapaAtributos = true"
        />
        <q-btn
          dense
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"          
          icon="info"
          size="lg"
          @click="onInfoClick && onInfoClick()"
        />
        


      <q-chip
        v-if="(cdMenu || cd_menu )  && ( 1==1 )"
        dense
        rounded
        color="deep-purple-7"
        class="q-mt-sm q-ml-sm margin-menu"
        size="16px"
        text-color="white"
        :label="`${cdMenu || cd_menu}`"
      />
        </h2>
      </transition>

      <!-- Ações à direita (como no seu topo) -->

      <div class="col">
         
        <!-- Modal -->

<!-- Dialog para exibir o dashboard -->
<q-dialog v-model="showDashDinamico" maximized>
  <q-card class="q-pa-sm" style="height:100vh;width:100vw;">
    <q-btn flat dense round icon="close" class="absolute-top-right q-ma-sm" @click="showDashDinamico=false" />
    <dashboard-dinamico
      :rows="rowsParaDashboard"
      :columns="colsParaDashboard"
      :titulo="tituloDashboard"
      :cd-menu="cd_menu || cdMenu"
      @voltar="showDashDinamico = false"
    />
  </q-card>
</q-dialog>

<q-dialog v-model="infoDialog">
  <q-card style="min-width: 640px">
    <q-card-section class="text-h6">
      <q-icon name="info" color="deep-orange-9" size="48px" class="q-mr-sm" /> 
      {{ infoTitulo }}</q-card-section>
    <q-separator />
    <q-card-section class="text-body1">
  
      {{ infoTexto }}

    </q-card-section>
    <q-card-actions align="right">
      <q-btn flat label="Fechar" color="primary" v-close-popup/>
    </q-card-actions>
  </q-card>
</q-dialog>
      </div>
    </div>

    <!-- MODAL DO FORM ESPECIAL -->

    <q-dialog v-model="dlgForm" persistent>
      <q-card class="dlg-form-card">
        <q-card-section class="row items-center justify-between">
          <div class="text-h6">
            {{ tituloMenu || title }} —
            {{
               formSomenteLeitura
               ? "Consulta de registro"
               : formMode === "I"
               ? "Novo registro"
               : "Editar registro"
              }}
           </div>

        <q-btn icon="close" flat round dense @click="fecharForm()" />
        </q-card-section>

        <q-separator />

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
        align="left"
        class="text-deep-orange-9"
        active-color="deep-purple-7"
        
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

                <div v-if="temPesquisaDinamica(attr)">
                  <q-input
                    v-model="formData[attr.nm_campo_mostra_combo_box || attr.nm_atributo || attr.nm_atributo_consulta ]"
                    :label="labelCampo(attr)"
                    :type="inputType(attr)"
                    filled
                    clearable
                    :dense="false"
                    stack-label
                    :readonly="isReadonly(attr)"
                    :input-class="inputClass(attr)"
                    @blur="validarCampoDinamico(attr)"
                  >
                    <template v-slot:prepend>
                      <q-btn
                        icon="search"
                        flat
                        round
                        dense
                        :disable="isReadonly(attr)"
                        @click="abrirPesquisa(attr)"
                        :title="`Pesquisar ${
                          attr.nm_edit_label || attr.nm_atributo
                        }`"
                      />
                    </template>
                    <template v-if="isDateField(attr)" v-slot:append>
                      <q-icon name="event" />
                    </template>
                  </q-input>

                   <!-- abaixo = código -->
                  <q-input
                     v-if="1==2"
                     class="q-mt-xs"
                     :value="formData[attr.nm_atributo]"
                     label="Código"
                     filled
                     readonly
                     :input-class="'leitura-azul'"
                  />

                  <!-- descrição do lookup (somente leitura) -->
                  <q-input 
                    v-if="descricaoLookup(attr)"
                    class="q-mt-xs"
                    :value="descricaoLookup(attr)"
                    label="Descrição"
                    filled
                    readonly
                    :input-class="'leitura-azul'"
                  />
                </div>

                <!-- 3B.2 — LOOKUP direto (nm_lookup_tabela) -->

                <q-select
                  v-else-if="temLookupDireto(attr)"
                  v-model="formData[attr.nm_atributo]"
                  :label="labelCampo(attr)"
                  :options="lookupOptions[attr.nm_atributo] || []"
                  option-label="__label"
                  option-value="__value"
                  emit-value
                  map-options
                  filled
                  clearable
                  :dense="false"
                  stack-label
                  :readonly="isReadonly(attr)"
                  :input-class="inputClass(attr)"
                />

                <!-- Descrição (readonly) para QUALQUER lookup 1==2 && temLookupDireto(attr) || temPesquisaDinamica(attr) -->

                <q-input
                  v-if="false"
                  class="q-mt-xs leitura-azul"
                  :value="descricaoLookup(attr)"
                  :label="`Descrição`"
                  readonly
                  filled
                />

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
    @change="(ev) => onFileSelected(attr, ev)"
  />
</div>

<!-- 1.2 — INPUT padrão com regra azul/readonly e '*' em numeração automática -->
<q-input
  v-else 
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

  </q-input>


              </div>
            </div>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right">
          <q-btn
            rounded
            class="q-mt-sm q-ml-sm"
            flat
            color="black"
            label="Cancelar"
            @click="fecharForm()"
          />

          <q-btn
            v-if="!formSomenteLeitura"
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
    <q-dialog v-model="showRelatorio" maximized>
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
            :rows="rows"
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

<q-dialog v-model="dlgMenuProcessos" persistent>
 <q-card class="dlg-form-card">
    <q-card-section class="row items-center q-pb-none">
      <div class="text-h6">
        Processos - {{ tituloMenu || title  }}
      </div>
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
    
<q-dialog v-model="dlgMapaAtributos">
  <q-card style="min-width: 760px; max-width: 96vw">
    <q-card-section class="row items-center q-pb-none">
      <div class="text-h6">
        Mapa de Atributos – {{ tituloMenu || title }} {{ cd_tabela ? ` (Tabela: ${cd_tabela})` : '' }}   
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

    <!-- FILTROS (mesma ideia do Form Especial) -->


    <section class="hpanel pane filtros">
      <!-- seus filtros aqui -->

      <!-- FILTROS (mesma ideia do Form Especial) -->

      <q-expansion-item
        v-if="temSessao && filtros && filtros.length"
        icon="filter_list"
        label="Seleção de Filtros"
        expand-separator
   
      >
        <slot name="filtros-bloco">
          <form
            class="dx-card wide-card"
            action="#"
            @submit.prevent="handleSubmit && handleSubmit($event)"
          >
            <div class="row q-col-gutter-md filtros-grid">
              <div
                v-for="(f, idx) in filtros.filter(x => x.ic_visivel_filtro !== 'N')"
                :key="`filtro_${f.nm_campo_chave_lookup || f.nm_atributo || 'x'}_${idx}`"
                class="col-12 col-sm-6 col-md-4 filtro-item">
                <component
                  :is="f.nm_lookup_tabela ? 'q-select' : 'q-input'"
                  v-model="filtrosValores[f.nm_campo_chave_lookup || f.nm_atributo]"
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
      >
        <q-tab name="principal" label="PRINCIPAL" />
        <q-tab
           v-for="(t, idx) in tabsDetalhe"
           :key="`panel_${t.key || 'x'}_${idx}`"
           :name="t.key || `p_${idx}`"
           :label="t.label"
           :disable="t.disabled"
        />
      </q-tabs>
      <q-separator color="deep-orange-9" />
    </div>

    <!-- 2) PRINCIPAL: fica SEMPRE no DOM.
       - Se existem tabs: mostra só quando abaAtiva === 'principal'
       - Se NÃO existem tabs: mostra sempre (porque tabsDetalhe.length == 0) -->

    <section v-show="!tabsDetalhe.length || abaAtiva === 'principal'">

<!-- ======================= -->
<!-- TABSHEETS DO FORMULARIO -->
<!-- ======================= -->
<div v-if="1===2 && tabsheets.length" class="q-mb-md">

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

      <div class="grid-scroll-shell" ref="scrollShell">

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
      {{ item.nm_fase_pedido  }}
    </span>
  </span>
</div>
        <div class="grid-scroll-track" ref="scrollTrack">
          <transition name="slide-fade">
            <dx-data-grid
              class="dx-card wide-card"
              v-if="temSessao"
              id="grid-padrao"
              ref="grid"
              :data-source="rows || dataSourceConfig"
              :columns="columns"
              :key-expr="keyName || id"
              :summary="total || undefined"
              :show-borders="true"
              :focused-row-enabled="false"
              :focused-row-key="null"
              :focused-row-index="null"
              :column-auto-width="true"
              :column-hiding-enabled="false"
              :column-resizing-mode="'widget'"
              :remote-operations="false"
              :row-alternation-enabled="false"
              :repaint-changes-only="true"
              :selection="gridSelectionConfig"              
              @selection-changed="onSelectionChangedGrid"
              @toolbar-preparing="onToolbarPreparing"
              @rowClick="onRowClickPrincipal"
              @option-changed="onOptionChanged"
              @rowDblClick="
                (e) => abrirFormEspecial({ modo: 'A', registro: e.data })
              "
               @row-prepared="onRowPreparedPrincipal"
               @onSelectionChanged="onSelectionChangedPrincipal"
            >
            <template #acoesGridColorCellTemplate="{ data }">
  <div class="acoes-grid-color-wrapper">
    <span
      v-for="(item, idx) in getAcoesGridCores(data.data.acoesGridColor)"
      :key="idx"
      class="acoes-grid-color-dot"
      :class="'bg-' + item.cor"
    ></span>
  </div></template> 
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
          </transition>
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
            @input="(val) => setFiltroFilho(t.cd_menu, val)"
            @keyup.enter="consultarFilho(t)"
            style="max-width: 320px"
          />
          <q-btn
            class="q-ml-sm"
            color="black"
            dense
            rounded
            label="Buscar"
            @click="consultarFilho(t)"
          />
          <q-space />
          <q-btn
            v-if="idPaiDetalhe"
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
            :key-expr="
              (filhos[t.cd_menu] && filhos[t.cd_menu].keyExpr) || id"
            :show-borders="true"
            :row-alternation-enabled="true"
            :repaint-changes-only="true"
            @rowDblClick="
              (e) =>
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
    <div
      v-if="mostrarSetasGrid" 
      class="arrow-btn left" 
      @click="scrollGrid(-1)">
      <q-btn round color="orange" icon="chevron_left" />
    </div>

    <div
      v-if="mostrarSetasGrid"
      class="arrow-btn right" @click="scrollGrid(1)">
      <q-btn round color="orange" icon="chevron_right" />
    </div>

    <q-dialog v-model="showLookup" persistent>
  <q-card style="min-width: 95vw; min-height: 90vh;">
    <UnicoFormEspecial
      :cd_menu_entrada="campoLookupAtivo && campoLookupAtivo.cd_menu_pesquisa ? Number(campoLookupAtivo.cd_menu_pesquisa) : 0"
      :cd_menu_modal_entrada="cdMenuAnteriorLookup ? Number(cdMenuAnteriorLookup) : 0"
      :titulo_menu_entrada="tituloLookup"
      :cd_acesso_entrada="0"
      ic_modal_pesquisa="S"
      @selecionou="onSelecionouLookup"
      @fechar="fecharLookup"
    />
  </q-card>
</q-dialog>

  </div>
  
</template>

<script>

import axios from "axios";
import DashboardDinamico from '@/components/dashboardDinamico.vue' // ajuste o caminho
import ModalComposicao from '@/components/ModalComposicao.vue';

//import { locale } from 'devextreme/localization';

import { payloadTabela, 
         getColumnsForMenu,
         getRowsFromPesquisa,
         getRowsExecPorMenu,
         getPayloadTabela,
         salvarDadosForm,
         lookup,
         execProcedure,
         getInfoDoMenu
 } from '@/services'

 import {
  exportarParaExcel,
  importarExcelParaTabela,
  gerarPdfRelatorio,
  getCatalogoRelatorio,
  gerarRelatorioPadrao
  
} from '@/services'

//import axios from "boot/axios";

import Relatorio from "@/components/Relatorio.vue";

//import api from '@/boot/axios'
const banco = localStorage.nm_banco_empresa;
//

const api = axios.create({
  baseURL: "https://egiserp.com.br/api",
  withCredentials: true, // ⬅️ mantém cookies da sessão
  timeout: 60000,
  headers: { "Content-Type": "application/json", "x-banco": banco },

  // headers: { 'Content-Type': 'application/json', 'x-banco': banco }
}); // cai no proxy acima

// injeta headers a cada request (x-banco + bearer fixo)
api.interceptors.request.use((cfg) => {
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

const isEmptyLike = (v) =>
  v === undefined || v === null || v === "" || v === "null" || v === "NULL";

const looksLikeDate = (s) =>
  typeof s === "string" &&
  (/^\d{2}[/-]\d{2}[/-]\d{4}$/.test(s) || /^\d{4}-\d{2}-\d{2}$/.test(s));

function toIsoDate(s, preferDayFirst = true) {
  if (s == null || s === '') return null;

  // 1) Date object
  if (s instanceof Date && !isNaN(s)) {
    const y = s.getFullYear();
    const m = String(s.getMonth() + 1).padStart(2, '0');
    const d = String(s.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  // 2) Força string
  if (typeof s !== 'string') s = String(s);
  s = s.trim();

  // 3) yyyy-mm-dd (date-only) → ok
  if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;

  // 4) ISO com hora → corta para date-only
  const isoMatch = /^(\d{4}-\d{2}-\d{2})T/i.exec(s);
  if (isoMatch) return isoMatch[1];

  // 5) dd/mm/yyyy ou mm/dd/yyyy (aceita 1-2 dígitos)
  const m = /^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$/.exec(s);
  if (m) {
    let [ , a, b, yyyy ] = m;
    a = a.padStart(2, '0');
    b = b.padStart(2, '0');

    let dd, mm;
    if (preferDayFirst) {
      // Heurística: se b > 12, então b é dia → troca
      if (+b > 12 && +a <= 12) { dd = b; mm = a; } else { dd = a; mm = b; }
    } else {
      if (+a > 12 && +b <= 12) { mm = b; dd = a; } else { mm = a; dd = b; }
    }

    if (isValidYMD(yyyy, mm, dd)) return `${yyyy}-${mm}-${dd}`;
    return null;
  }

  // 6) Último recurso: tentar Date (local) e extrair date-only (evita “-1 dia”)
  const d = new Date(s);
  if (!isNaN(d)) {
    const y = d.getFullYear();
    const m2 = String(d.getMonth() + 1).padStart(2, '0');
    const d2 = String(d.getDate()).padStart(2, '0');
    return `${y}-${m2}-${d2}`;
  }

  // 7) Não parece data → mantém sua semântica original (retorna s) ou troque por null
  // return null;
  return s;

  function isValidYMD(yyyy, mm, dd) {
    const y = +yyyy, m = +mm, d = +dd;
    if (!y || m < 1 || m > 12 || d < 1 || d > 31) return false;
    const test = new Date(y, m - 1, d);
    return test.getFullYear() === y && (test.getMonth() + 1) === m && test.getDate() === d;
  }
}

const toSN = (v) => {
  if (v === true || v === 1 || v === "1" || `${v}`.toUpperCase() === "S")
    return "S";
  if (v === false || v === 0 || v === "0" || `${v}`.toUpperCase() === "N")
    return "N";
  return null; // deixa o back decidir quando não informado
};

const shouldBeNumberByKey = (k) =>
  /^cd_/.test(k) || /_id$/.test(k) || /^qtd/.test(k) || /^vl_/.test(k);

function normalizeValue(key, val) {
  if (isEmptyLike(val)) return null;

  // arrays/objetos: normaliza recursivo
  if (Array.isArray(val)) return val.map((x) => normalizeValue(key, x));
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
    const n = Number(val);
    return Number.isFinite(n) ? n : null;
  }

  return val; // mantém o resto como está
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

  (camposMeta || []).forEach((c) => {
    const key = c.nm_atributo_consulta || c.nm_atributo;

    // determinar tipo
    const tipo = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    mapa[key] = tipo;
    //

  });
  return dados.map((reg) => {
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
        const num = Number(String(v).replace(/\./g, "").replace(",", "."));
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
  if (typeof v !== 'string') v = String(v);
  v = v.trim();

  // 'YYYY-MM-DD' (NÃO usar new Date('YYYY-MM-DD') porque é UTC 00:00Z -> pode "voltar 1 dia" na exibição local)
  let m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(v);
  if (m) {
    const y = +m[1], mm = +m[2], dd = +m[3];
    return new Date(Date.UTC(y, mm - 1, dd));
  }

  // ISO com hora -> Date comum já interpreta corretamente
  if (/^\d{4}-\d{2}-\d{2}T/.test(v)) {
    const d = new Date(v);
    if (!isNaN(d)) {
      // zera hora em UTC para ficar só a data
      return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate()));
    }
  }

  // DD/MM/YYYY ou MM/DD/YYYY (aceita 1-2 dígitos)
  m = /^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$/.exec(v);
  if (m) {
    let a = +m[1], b = +m[2], y = +m[3];
    let dd, mm;
    if (preferDayFirst) {
      // heurística para ambíguo: se b>12, b é dia
      if (b > 12 && a <= 12) { dd = b; mm = a; } else { dd = a; mm = b; }
    } else {
      if (a > 12 && b <= 12) { mm = b; dd = a; } else { mm = a; dd = b; }
    }
    const test = new Date(Date.UTC(y, mm - 1, dd));
    // validação simples (rola e confere)
    if (test.getUTCFullYear() === y && (test.getUTCMonth() + 1) === mm && test.getUTCDate() === dd) {
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

  const keys = Object.keys(rows[0]);   // ex: ['cd_estado', 'Estado']

  const keyValue = keys[0];           // 1ª coluna → value
  const keyLabel = keys[1] || keys[0]; // 2ª coluna (se existir) → label

  return rows.map(r => ({
    value: r[keyValue],
    label: r[keyLabel],
  }));
}


//Colunas de grid a partir do meta

function buildColumnsFromMeta(camposMeta = []) {
  return (camposMeta || []).map((c) => {
    const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const caption = c.nm_edit_label || dataField;
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
    };

    if (dataField === "acoesGridColor") {
      col.visible = false;
    }

    if (dataField === "fasePedido") {
      col.visible = false;
    }

    // Datas (exibição dd/MM/yyyy, filtro/sort corretos sem "voltar 1 dia")
    if (['date','shortdate','datetime'].includes(tipoFmt) || String(dataField).startsWith('dt_')) {
       col.dataType = 'date';

  // 1) Converte diferentes formatos para Date(UTC) de forma segura
  col.calculateCellValue = (rowData) => {
    const v = rowData?.[dataField];
    return parseToUtcDate(v); // retorna Date ou null
  };

  // 2) Exibe em pt-BR (dd/MM/yyyy), fixando UTC para não deslocar o dia
  col.customizeText = (e) => {
    if (!e.value) return '';
    return new Intl.DateTimeFormat('pt-BR', { timeZone: 'UTC' }).format(e.value);
  };

  // 3) Ordenação consistente mesmo se algum valor ficar string
  col.calculateSortValue = (rowData) => {
    const d = parseToUtcDate(rowData?.[dataField]);
    return d ? d.getTime() : -Infinity;
  };

  // 4) (Opcional) formato no filtro de linha/header filter
  col.filterOperations = ['=', '>', '<', '<=', '>=', 'between'];
}
    

    // Moeda
    if (tipoFmt === "currency" || dataField.startsWith("vl_")) {
      col.customizeText = (e) =>
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
      col.customizeText = (e) =>
        e.value == null || e.value === ""
          ? ""
          : `${(Number(e.value) * 100).toFixed(2)}%`;
    }

    // Números simples
    if (["number", "fixedpoint", "decimal", "float"].includes(tipoFmt)) {
      col.format = { type: "fixedPoint", precision: 2 };
    }

    return col;

  });

}

function buildSummaryFromMeta(camposMeta = []) {
  const totalizaveis = (camposMeta || []).filter(
    (c) => c.ic_total_grid === "S" || c.ic_contador_grid === "S"
  );

  const totalItems = totalizaveis.map((c) => {
    const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    const isSum = c.ic_total_grid === "S";
    return {
      column: dataField,
      summaryType: isSum ? "sum" : "count",
      alignByColumn: true,
      displayFormat: isSum ? "Total: {0}" : "{0} registro(s)",
      customizeText: (e) => {
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

  const groupItems = totalizaveis.map((c) => {
    const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    const isSum = c.ic_total_grid === "S";
    return {
      column: dataField,
      summaryType: isSum ? "sum" : "count",
      showInGroupFooter: true,
      alignByColumn: true,
      displayFormat: isSum ? "Subtotal: {0}" : "{0} registro(s)",
      customizeText: (e) => {
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

import { DxTabPanel, DxItem as DxTabItem } from 'devextreme-vue/tab-panel'

import { act } from "react";
import { DxButton, DxToolbar } from "devextreme-vue";

//

//
function buscarValor(row, nomes) {
  for (const nome of nomes) {
    if (typeof nome !== "string") continue; // ignora valores inválidos

    const chave = Object.keys(row).find(
      (k) => k.toLowerCase() === nome.toLowerCase()
    );
    if (chave) return row[chave];
  }
  return undefined;
}



// ---------------------------------------------------------------

export default {
  name: "UnicoFormEspecial",
    props: {
    cd_menu_entrada: Number,
    cd_acesso_entrada: Number, //Chave de acesso (p/ filtros salvos)
    cd_menu_modal_entrada: Number,
    titulo_menu_entrada: { type: String, default: '' },
    ic_modal_pesquisa: {       // << NOVO
      type: String,
      default: 'N'
    }
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
    UnicoFormEspecial: () => import('@/views/unicoFormEspecial.vue'),
  },

  // ===== DADOS =====

  data() {
    return {
      showDashDinamico: false,
      ncd_acesso_entrada: this.cd_acesso_entrada || localStorage.cd_chave_pesquisa || 0,
      ncd_menu_entrada: this.cd_menu_entrada || 0,
      mostrarSetasGrid: false, // por padrão NÃO mostra
      infoDialog: false,
      infoTitulo: '',
      infoTexto: '',
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
      keyName: 'id',
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
      tabsheets: [],        // [{ key, label, cd_tabsheet, fields:[] }]
      activeTabsheet: 'dados',
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
      cd_menu_processo: 0,        // vem do payload (meta)
      dlgMenuProcessos: false,    // controla o modal
      menuProcessoRows: [],       // linhas da grid de processos
      columnsProcessos: [],       // colunas da grid de processos
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
      { cor: "yellow-7" }
    ],
    legendaAcoesGrid: [],
    fasePedido: [],
    cd_form: 0,
    cd_menu_modal : 0,
    cd_form_modal : 0,
    ic_selecao_registro: 'N',
    selectionMode: 'multiple',   // 'single' ou 'multiple'
    registrosSelecionados: [],   // registros selecionados na grid
    mostrarBotaoModalComposicao: false,
    dialogModalComposicao: false,
    showLookup: false,
    campoLookupAtivo: null,
    cdMenuAnteriorLookup: Number(localStorage.cd_menu || 0),
    tituloLookup: '',
    ultimoSelecionadoLookup: null,   
    cd_menu_principal: 0, 
     formStack: [],  
    };
  },

  created() {

    this.bootstrap();

    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;

    this.dt_inicial = localStorage.dt_inicial;
    this.dt_final = localStorage.dt_final;
    this.dt_base = localStorage.dt_base;
    this.periodoVisible = false;
    this.tituloMenu = localStorage.nm_menu_titulo;
    this.cd_menu = localStorage.cd_menu;
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
       this.tituloMenu = this.titulo_menu_entrada
       this.title = this.titulo_menu_entrada
      //localStorage.nm_menu_titulo = this.titulo_menu_entrada // opcional, mas ajuda seu topo atual
     }

  },

  async mounted() {

    this.restoreGridConfig();

    locale('pt'); // ou 'pt-BR'
    
    localStorage.cd_filtro = 0;
    localStorage.cd_parametro = 0;
    localStorage.cd_tipo_consulta = 0;
    localStorage.cd_tipo_filtro = 0;
    localStorage.cd_documento = 0;

      // se você já usa onToolbarPreparing, acrescente mais um item
    //this.onToolbarPreparing && this.onToolbarPreparing({
    // addExcelButton: true
    //});

     if (typeof this.carregarCatalogoRelatorios === 'function') {
       this.carregarCatalogoRelatorios()
     }
    //this.carregaDados();
  },

  computed: {

    gridSelectionConfig () {
    if (this.ic_selecao_registro !== 'S') {
      // sem seleção
      return { mode: 'none' }
    }

    return {
      mode: this.selectionMode,       // 'single' ou 'multiple'
      showCheckBoxesMode: 'always',   // checkbox sempre visível
    }
  },

        // TRUE quando temos dados para graficar
    temDadosGrid () {
      return (this.rowsParaDashboard && this.rowsParaDashboard.length > 0)
    },

    rowsParaDashboard () {
       // 1) Se você já tem um array "rows" usado pela grid, usa ele:
    if (Array.isArray(this.rows) && this.rows.length) {
      //console.log('[rowsDashboard] via this.rows length:', this.rows.length)
      return this.rows
    }

    // 2) Se a grid usa somente dataSourceConfig (DevExtreme), lê da instância:
    try {
      const gridRef = this.$refs.dxGrid || this.$refs.grid
      const grid    = gridRef && gridRef.instance ? gridRef.instance : null

      //console.log('[rowsDashboard] gridRef:', this.$refs, 'grid instance:', !!grid)

      if (grid && typeof grid.getVisibleRows === 'function') {
        const lista = grid.getVisibleRows().map(r => r.data)
        //console.log('[rowsDashboard] via grid.getVisibleRows length:', lista.length)
        return lista
      }

      // alternativa, se você usa DataSource:
      const ds = grid && typeof grid.getDataSource === 'function'
        ? grid.getDataSource()
        : null
      if (ds && typeof ds.items === 'function') {
        const lista = ds.items()
        //console.log('[rowsDashboard] via dataSource.items length:', lista.length)
        return lista
      }
    } catch (e) {
      console.warn('[rowsDashboard] erro lendo grid:', e)
    }

    //console.log('[rowsDashboard] sem dados, retornando []')
    return []
  },


  colsParaDashboard () {
    if (Array.isArray(this.columns) && this.columns.length) {
      const cols = this.columns.map(c => c.dataField || c.name || c.key || c)
      //console.log('[columnsDashboard] via this.columns:', cols)
      return cols
    }

    const rows = this.rowsDashboard
    if (rows && rows.length) {
      const cols = Object.keys(rows[0])
      //console.log('[columnsDashboard] via keys do primeiro row:', cols)
      return cols
    }

    console.log('[columnsDashboard] sem colunas, retornando []')
    return []
  },

  tituloDashboard () {
    // Use o mesmo título que você já exibe no topo do únicoForm
    return this.tituloMenu || this.nm_menu_titulo || 'Dashboard'
  },


    tituloModal() {
      const t = this.tituloMenu || sessionStorage.getItem("menu_titulo") || "Cadastro";
      if (this.modo === "novo") return `Inclusão - ${t}`;
      if (this.modo === "alteracao") return `Alteração - ${t}`;
      if (this.modo === "consulta") return `Consulta - ${t}`;
      if (this.modo === "exclusao") return `Exclusão - ${t}`;
      return t;
    },

    tabsheetsForm () {
    return (this.tabsheets || [])
      // se não quiser "Mapa de Atributos" no modal, já tira aqui:
      .filter(t => t.key !== 'mapa')
      // não mostra aba sem campo
      .filter(t => Array.isArray(t.fields) && t.fields.length > 0)
    },

    camposFormAtivos () {
         const tabs = this.tabsheetsForm

    // se não tiver tabsheets válidos, volta pro comportamento antigo
    if (!tabs.length) {
      return this.atributosForm || []
    }

    const aba = tabs.find(t => t.key === this.activeTabsheet) || tabs[0]
    return Array.isArray(aba.fields) ? aba.fields : []

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
      const base = (this.colunasGrid || []).map((c) => ({
        dataField: c.dataField || c.nm_atributo,
        caption: c.caption || c.titulo,
      }));

      // garante que a coluna da chave exista e venha primeiro
      const key = this.keyName;
      //

      let cols = base;

      if (key) {
        const temChave = base.some((c) => c.dataField === key);
        if (!temChave) {
          cols = [
            { dataField: key, caption: this.keyCaption || "Código" },
            ...base,
          ];
        } else {
          // move para a primeira posição
          const idx = base.findIndex((c) => c.dataField === key);
          const [col] = base.splice(idx, 1);
          cols = [{ ...col, caption: this.keyCaption || col.caption }, ...base];
        }
      }

      // nunca renderize a coluna "id" (ela só existe se você usou fallback)
      cols = cols.filter((c) => c.dataField !== "id");

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
    abaAtiva() {
      if (this.abaAtiva === "principal") return;
      const t = this.tabsDetalhe.find((x) => x.key === this.abaAtiva);
      if (t) this.consultarFilho(t);
    },
    dataSourceConfig(v) {
      this.qt_registro = Array.isArray(v) ? v.length : 0;
    },
    rows(v) {
      this.qt_registro = Array.isArray(v) ? v.length : 0;
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
  },

  methods: {
    
    // ...

    ssKey(base) {
      const m = Number(this.cd_menu || 0)
      return m ? `${base}_${m}` : base
    },

     async onInfoClick() {
      const { titulo, descricao } = await getInfoDoMenu(this.cd_menu, {
        tituloFallback: localStorage.menu_titulo || this.pageTitle // se você tiver um título local
      })
      this.infoTitulo = titulo + ' - ' + this.cd_menu.toString();
      this.infoTexto  = descricao + this.cd_tabela ? `\n\nTabela vinculada: ${this.cd_tabela}` : '';        
      this.infoDialog = true
    },

    pushFormContext () {
    this.formStack.push({
    cd_menu: this.cd_menu,
    atributosForm: JSON.parse(JSON.stringify(this.atributosForm || [])),
    gridMeta: JSON.parse(JSON.stringify(this.gridMeta || [])),
    // importante: CLONAR para não manter referência
    formData: JSON.parse(JSON.stringify(this.formData || {})),
    modoCRUD: this.modoCRUD,
    // qualquer outro estado que seu bootstrap troca
  })
},

    //
    abrirPesquisaCampo (campo) {
    if (!campo || Number(campo.cd_menu_pesquisa || 0) <= 0) return

    this.campoLookupAtivo = campo
    this.cdMenuAnteriorLookup = Number(localStorage.cd_menu || 0)

    // título (ajuste se seu payload traz outro nome)
    this.tituloLookup =
      campo.nm_titulo_pesquisa ||
      campo.ds_titulo_pesquisa ||
      campo.ds_rotulo ||
      'Pesquisa'

    // muda o menu ativo para o lookup
    localStorage.cd_menu = Number(campo.cd_menu_pesquisa)

    this.showLookup = true
  },

  abrirPesquisa (attr) {
    if (!attr || Number(attr.cd_menu_pesquisa || 0) <= 0) return

    this.campoLookupAtivo = attr
    this.ultimoSelecionadoLookup = null

    this.pushFormContext()   // 👈 salva o pai antes de entrar no “filho”

    this.cdMenuAnteriorLookup = Number(localStorage.cd_menu || 0)

    this.tituloLookup =
      attr.nm_titulo_pesquisa ||
      attr.ds_titulo_pesquisa ||
      this.labelCampo(attr) ||
      'Pesquisa'

    // tenta setar o menu (se o browser bloquear storage, não tem problema pois passamos por props também)
    try { localStorage.cd_menu = Number(attr.cd_menu_pesquisa) } catch (e) {}

    this.showLookup = true
  },

  onSelecionouLookup (plain) {
    this.ultimoSelecionadoLookup = plain
  },

  popFormContext () {
  const ctx = this.formStack.pop()
  if (!ctx) return

  this.cd_menu = ctx.cd_menu
  this.atributosForm = ctx.atributosForm
  this.gridMeta = ctx.gridMeta
  this.formData = ctx.formData
  this.modoCRUD = ctx.modoCRUD
},

fecharLookup () {
  this.showLookup = false

  try {
    localStorage.cd_menu = Number(this.cdMenuAnteriorLookup || 0)
  } catch (_) {}

  const attr = this.campoLookupAtivo
  if (!attr) return

  let sel = this.ultimoSelecionadoLookup
  if (!sel) return

  // ✅ primeiro restaura o contexto do pai
  this.popFormContext()
  //

  // normaliza
  const selTec = this.traduzRegistroSelecionado
    ? this.traduzRegistroSelecionado(sel)
    : sel

  /* ================================
     1️⃣ CHAVE (ID)
     ================================ */
  const campoChave = attr.cd_chave_retorno || attr.nm_atributo
  const valorChave =
    selTec[campoChave] ??
    selTec.id ??
    null

  if (campoChave && valorChave != null) {
    this.$set(this.formData, campoChave, valorChave)
  }

  /* ================================
     2️⃣ TEXTO / DESCRIÇÃO
     ================================ */
  const campoDescricao =
    attr.nm_campo_mostra_combo_box ||
    attr.nm_atributo_lookup ||
    ''

  const valorDescricao =
    selTec[campoDescricao] ??
    ''

  if (campoDescricao && valorDescricao) {
    this.$set(this.formData, campoDescricao, valorDescricao)
  }

  /* ================================
     3️⃣ LIMPEZA
     ================================ */
  this.campoLookupAtivo = null
  this.ultimoSelecionadoLookup = null

},

  onSelectionChangedGrid(e) {
    // e.selectedRowsData é um array com os registros completos
    this.registrosSelecionados = e.selectedRowsData || []
    // se você quiser só as chaves, pode usar e.selectedRowKeys
    // this.registrosSelecionados = e.selectedRowKeys || []
    // console.log('selecionados => ', this.registrosSelecionados)
  },

  onSelectionChangedPrincipal (e) {
    // e.selectedRowsData é o que importa
    const data = e && e.selectedRowsData && e.selectedRowsData.length
      ? e.selectedRowsData[e.selectedRowsData.length - 1]
      : null

    if (!data) return
    this.gravarRegistroSelecionado(data)   // ✅ reutiliza a mesma gravação
  },

  gravarRegistroSelecionado (data) {
    const cdMenu = Number(localStorage.cd_menu || this.cd_menu_entrada || 0)

    // transforma em plain pra evitar JSON quebrar
    const plain = {}
    Object.keys(data || {}).forEach((k) => {
      const v = data[k]
      if (v === null || v === undefined) return (plain[k] = v)
      const t = typeof v
      if (t === 'string' || t === 'number' || t === 'boolean') return (plain[k] = v)
      try { plain[k] = JSON.parse(JSON.stringify(v)) } catch (err) { plain[k] = String(v) }
    })

    sessionStorage.setItem('registro_selecionado', JSON.stringify(plain))

    if (cdMenu) sessionStorage.setItem(`registro_selecionado_${cdMenu}`, JSON.stringify(plain))
  
  },

  selecionarERetornar (cell) {
    // no dx: cell.data é a row; dependendo do template pode vir direto
    const row = cell && cell.data ? cell.data : cell
    if (!row) return

    this.gravarRegistroSelecionado(row)

    this.$emit('selecionou', row)
    // fecha e volta pro mod
    // al
    this.$emit('fechar')

  },

      onOptionChanged(e) {
      if (e.name === "columns") {
        this.saveGridConfig();
      }
    },

    abrirModalComposicao () {

         // 👇 se não tiver nada no array, mas existir um "registroSelecionadoPrincipal"
  // (última linha clicada), usa ele como selecionado
  if (
    (!this.registrosSelecionados || this.registrosSelecionados.length === 0) &&
    this.registroSelecionadoPrincipal
  ) {
    this.registrosSelecionados = [this.registroSelecionadoPrincipal];
  }

       // se o menu exigir seleção e não houver nenhum selecionado, avisa
       if (
        this.ic_selecao_registro === 'S' &&
        (!this.registrosSelecionados || this.registrosSelecionados.length === 0)
       ) {
       this.$q.notify({
      type: 'warning',
      position: 'top',
      message: 'Selecione ao menos um registro na grade antes de continuar.',
    })
    return
  }

       if (this.cd_form_modal > 0) {
           this.dialogModalComposicao = true;
       }


    },

    onRefreshConsulta() {
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
    if (this.ic_modal_pesquisa === 'S') {
      return 'S';
    }

    let temMenuModal = false;
    temMenuModal = this.cd_menu_modal !== 0;
    
    // se encontrou cd_menu_modal <> 0 → força 'S'

    if (temMenuModal) {
      return 'S';
    }

    // fallback: prop ou 'N'
    return this.ic_modal_pesquisa || 'N';
  
   },

    abrirDashboardDinamico () {
      
      //console.log('[unicoFormEspecial] abrirDashboardDinamico clicado, rows:',
      //(this.rowsParaDashboard || []).length)

    this.showDashDinamico = true
   },

   saveGridConfig() {
      const grid = this.$refs.grid.instance;
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
        const grid = this.$refs.grid.instance;
        config.forEach(col => {
          grid.columnOption(col.dataField, "visible", col.visible);
        });
      }
    },

    isCampoArquivo (attr) {
  return String(attr.ic_doc_caminho_atributo || 'N')
    .trim()
    .toUpperCase() === 'S'
},

abrirSeletorArquivo (attr) {
  const refName = `file_${attr.nm_atributo}`
  const ref = this.$refs[refName]

  if (Array.isArray(ref) && ref[0]) {
    ref[0].click()
  } else if (ref) {
    ref.click()
  }
},
onFileSelected (attr, event) {
  const file = event.target.files && event.target.files[0]
  if (!file) return

  this.uploadArquivo(attr, file)

  // limpa o input pra permitir subir o mesmo arquivo outra vez, se quiser
  event.target.value = ''
},

async uploadArquivo (attr, file) {
  this.uploadErroArquivo = null
  this.uploadingArquivo = true

  try {
    const formData = new FormData()
    formData.append('arquivo', file)

    const { data } = await api.post('/upload-arquivo', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })

    //console.log('[upload-arquivo] retorno =>', data)

    if (!data || !data.url_publica) {
      throw new Error('Resposta da API sem url_publica')
    }

    const url = data.url_publica

    // grava a URL no campo do formulário
    if (!this.formData)
       this.formData = {}

    this.$set(this.formData, attr.nm_atributo, url)

    // opcional: notificação
    this.$q && this.$q.notify({
      type: 'positive',
      position: 'center',
      message: 'Arquivo anexado com sucesso.'
    })
  } catch (err) {
    console.error('[upload-arquivo] erro =>', err)
    this.uploadErroArquivo = err.message || 'Erro ao enviar arquivo'

    this.$q && this.$q.notify({
      type: 'negative',
      position: 'center',
      message: 'Erro ao anexar arquivo.'
    })
  } finally {
    this.uploadingArquivo = false
  }
},

abrirArquivoAnexo (attr) {
  if (!this.formData || !attr || !attr.nm_atributo) return

  const valor = this.formData[attr.nm_atributo]
  if (!valor) return

  // se já vier URL completa, abre direto
  const url = String(valor)

  window.open(url, '_blank')
},

    resolverCodigoDocumento(base) {

  if (!base) return 0;

  // 1) Se já vier um número direto
  if (typeof base === "number") return base;

  // 2) Se vier um ARRAY (ex.: [1, "SETUP", 17, "Treinamento"])
  if (Array.isArray(base)) {
    const nums = base.filter((v) => typeof v === "number");
    return nums.length ? nums[0] : 0; // pega o primeiro número
  }

  // 3) Se for objeto e tiver id como ARRAY
  if (Array.isArray(base.id)) {
    const nums = base.id.filter((v) => typeof v === "number");
    if (nums.length) return nums[0];
  }

  // 4) Se for objeto e tiver id numérico simples
  if (typeof base.id === "number") {
    return base.id;
  }

  // 5) Procura campos numéricos com cara de código
  const candidatos = [];
  Object.keys(base).forEach((k) => {
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

resolveCdParametro (row) {
  const fromFiltro = Number(row?.cd_parametro ?? row?.cd_parametro_filtro ?? 0)
  const fromMenu   = Number(this.cd_parametro_menu ?? 0)

  if (fromFiltro > 0) return fromFiltro
  if (fromMenu > 0) return fromMenu

  return 1 // ou 0, dependendo da sua regra
},

async executarProcesso (row) {
  if (!row) return

  // 1) Descobre usuário atual (mesma lógica que você usa em outros lugares)
  const cd_usuario = localStorage.cd_usuario || 0; //this._getUsuarioId
    
  // 2) Datas – pego dos campos que você já usa no payload principal.
  //    Ajuste os nomes se na sua tela for outro (dataInicial/dataFinal, etc.).
  
  const dt_inicial =
    this.dt_inicial ||
    this.data_inicial ||
    this.dataInicial ||
    null

  const dt_final =
    this.dt_final ||
    this.data_final ||
    this.dataFinal ||
    null

  //console.log('Perído: ', dt_inicial, dt_final);

  // 3) Chave do documento = PK da grid principal
  let cd_documento = 0;

   // base = registro selecionado na grid principal
  const base =
    this.registroSelecionadoPrincipal ||
    this.registroSelecionado ||
    null;

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
      ic_json_parametro: 'S',      
      cd_processo: row.cd_processo || row.Processo || 0,
      cd_documento: cd_documento,
      //cd_parametro: row.cd_parametro || this.cd_parametro_menu || 0,
       cd_parametro: this.resolveCdParametro(row),
      cd_usuario,
      dt_inicial,
      dt_final
    }
  ]

  console.log('[processo] payloadExec =>', payloadExec)

  try {
    // chama diretamente a procedure de geração de processos
    const { data } = await api.post(
      '/exec/pr_api_geracao_processo_sistema',
      payloadExec
    )

    console.log('[processo] retorno =>', data)

    if (this.$q) {
      this.$q.notify({
        type: 'positive',
        position: 'center',
        message: 'Processo executado com sucesso.',
        classes: 'my-notify'

      })
    }
  } catch (err) {
    console.error('[processo] erro =>', err)
    if (err.response) {
      console.error('[processo] status:', err.response.status)
      console.error('[processo] body:', err.response.data)
    }
    if (this.$q) {
      this.$q.notify({
        type: 'negative',
        position: 'center',
        message: 'Erro ao executar o processo.'
      })
    }
  }
},

//
async abrirMenuProcessos () {
  if (!this.cd_menu_processo) {
    return
  }

  const cd_menu = Number(this.cd_menu_processo)
  const cd_usuario = localStorage.cd_usuario || 0; //this._getUsuarioId
    //? this._getUsuarioId()
    //: Number(this.cd_usuario || sessionStorage.getItem('cd_usuario') || 0)

  const payloadExec = [
    {
      ic_json_parametro: 'S',
      cd_menu,
      cd_usuario
    }
  ]

  this.dlgMenuProcessos = true
  this.menuProcessoLoading = true
  this.menuProcessoRows = []

  try {
    // mesma ideia do exec que você já usa:
    const { data } = await api.post(
      '/exec/pr_egis_menu_processo',
      payloadExec
    )

    console.log('[menu_processo] dados recebidos:', data );

    // Mapeia para Processo / Descritivo

    this.menuProcessoRows = (Array.isArray(data) ? data : []).map((row, idx) => {
      return {
        ...row,
        id: idx + 1,
        processo:
          row.Processo ||
          row.cd_processo || '',
         
          
        descritivo:
          row.Descritivo ||          
          ''
      }
    })

    // mesmas ideias da coluna Ações da grid principal

const colAcoesProcesso = {
  type: 'buttons',
  caption: 'Ações',
  width: 110,
  alignment: 'center',
  allowSorting: false,
  allowFiltering: false,
  buttons: [
    {
      hint: 'Executar processo',
      icon: 'copy', // (copy) ícone nativo DevExtreme
      onClick: (e) => this.executarProcesso(e.row.data)
    }
  ]
}

const colProcesso = {
  dataField: 'processo',
  caption: 'Processo'
}

const colDescritivo = {
  dataField: 'descritivo',
  caption: 'Descritivo'
}

this.columnsProcessos = [colAcoesProcesso, colProcesso, colDescritivo]


  } catch (err) {
    console.error('[menu_processo] erro', err)
    this.menuProcessoRows = []
  } finally {
    this.menuProcessoLoading = false
  }
},

//

async copiarRegistro (registro) {

    if (!registro || typeof registro !== 'object') return


      // 1) Descobre a chave primária a partir do META (igual o salvarCRUD faz)

  const pkAttr =
    ((this.gridMeta || []).find(
      m =>
        String(m.ic_atributo_chave || '')
          .trim()
          .toUpperCase() === 'S'
    ) || {}).nm_atributo ||
    this.keyName ||
    this.id ||
    null

    
    // 2) Clona o objeto para não mexer no original
    //const modelo = { ...registro }
    const modelo = JSON.parse(JSON.stringify(registro))

    // 3) Remove o campo chave primária (keyName da grid)
    //    Assim o back entende como "novo registro"
    const pk = this.keyName || this.id || null
    if (pk && Object.prototype.hasOwnProperty.call(modelo, pk)) {
      delete modelo[pk]
    }

    // 4) Zera campos que são numeração automática (se existirem no meta)
    if (Array.isArray(this.gridMeta)) {
      this.gridMeta.forEach(attr => {
        const ehAuto =
          String(attr.ic_numeracao_automatica || '').toUpperCase() === 'S'

        if (ehAuto && attr.nm_atributo && modelo.hasOwnProperty(attr.nm_atributo)) {
          modelo[attr.nm_atributo] = null // ou '' se preferir
        }
      })
    }

    //5)
    this.abrirFormEspecial({
      modo: 'A',        // força o caminho de edição para mapear o registro
      registro: modelo  // já sem PK e com campos ajustados
    })

    // 6) Abre o mesmo modal que você já usa, mas em modo INCLUSÃO
    //    reaproveitando seu abrirFormEspecial sem mudar nada nele
    this.formMode = 'I'

    // 7) Garante que o campo de código esteja REALMENTE zerado no formData
  if (pkAttr && this.formData) {
    if (Object.prototype.hasOwnProperty.call(this.formData, pkAttr)) {
      this.$set(this.formData, pkAttr, null)   // fica em branco no formulário
    }
    if (Object.prototype.hasOwnProperty.call(this.formData, 'id')) {
      this.$set(this.formData, 'id', null)
    }
  }
    /*
    this.abrirFormEspecial({
      modo: 'I',       // inclusão
      registro: modelo // dados copiados
    })
    */  
  },

montarPayloadPesquisa() {

  const ic_cliente = this.gridMeta?.[0]?.ic_cliente || "N";
  const cd_cliente = localStorage.cd_cliente || Number(sessionStorage.getItem("cd_cliente")) || 0;
  
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
    if (v && typeof v === 'object' && 'value' in v) {
      v = v.value;
    }

    // ignora vazios
    if (v !== null && v !== '' && typeof v !== 'undefined') {
      filtrosObj[key] = v;
    }
  });

  const payload = [{ ...base, ...filtrosObj }];

  //console.log('payload da consulta dos filtros:', payload);
  return payload;

},
  
    // Campos pertencentes a um cd_tabsheet específico
getCamposTabsheet (cd_tabsheet) {
  const cd = Number(cd_tabsheet || 0)
  return (this.gridMeta || []).filter(r => Number(r.cd_tabsheet || 0) === cd)
},


// Texto bonitinho do label de cada campo
labelCampoTabsheet (attr) {
  return (
    attr.nm_atributo_consulta ||
    attr.nm_edit_label ||
    attr.ds_atributo ||
    attr.nm_titulo_menu_atributo ||
    attr.nm_atributo
  )
},

    // === Constrói Tabsheets a partir do gridMeta ===
    buildTabsheetsFromMeta(meta) {

       // Garante que sempre vamos trabalhar com um array
       const arr = Array.isArray(meta) ? meta : (meta ? [meta] : [])

       // Se não vier nada do back, zera as tabs

       if (!arr.length) {
    this.tabsheets = [
      {
        key: 'dados',
        label: 'Dados',
        cd_tabsheet: 1,
        fields: []
      },
      {
        key: 'mapa',
        label: 'Atributos',
        cd_tabsheet: -1,
        fields: []
      }
    ]

    this.activeTabsheet = 'dados'
    return

  }

  // Agrupa atributos por cd_tabsheet
  const grupos = {}

  arr.forEach(r => {           // <-- AGORA CORRETO
    const cd = Number(r.cd_tabsheet || 0)
    const nm = String(r.nm_tabsheet || '').trim() || 'Dados'

    if (!grupos[cd]) {
      grupos[cd] = {
        key: cd === 0 ? 'dados' : `tab_${cd}`,
        label: nm,
        cd_tabsheet: cd,
        fields: []
      }
    }
    
    grupos[cd].fields.push(r)

  })

  // Ordena pelos códigos de aba
  let tabs = Object.values(grupos).sort((a, b) => a.cd_tabsheet - b.cd_tabsheet)

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
    key: 'mapa',
    label: 'Mapa de Atributos',
    cd_tabsheet: -1,
    fields: []
  })

   this.tabsheets = tabs

  // Se a aba ativa atual não existir mais, volta pra primeira
  if (!tabs.find(t => t.key === this.activeTabsheet)) {
    this.activeTabsheet = tabs[0].key
  }
},

    // Constrói as linhas da Grid "Mapa de Atributos" a partir da gridMeta
_buildMapaRowsFromMeta(meta) {
  const arr = Array.isArray(meta) ? meta : []

  const rows = arr.map((r, idx) => {
    // ordem: tenta nu_ordem / qt_ordem_atributo, senão índice
    const ordem = Number(
      r.nu_ordem ||
      r.qt_ordem_atributo ||
      r.qt_ordem ||
      idx + 1
    )

    const codigo = Number(r.cd_atributo || 0)
    const atributo = String(r.nm_atributo || '').trim()

    const descricao = String(
      r.nm_atributo_consulta ||
      r.ds_atributo ||
      r.nm_titulo_menu_atributo ||
      atributo
    ).trim()

    return { ordem, codigo, atributo, descricao }
  })

  // ordena pela ordem (se vier 0, joga lá pro fim)
  rows.sort((a, b) => (a.ordem || 999999) - (b.ordem || 999999))

  return rows
},

    async carregarCatalogoRelatorios() {
    try {
      this.relatoriosDisponiveis = await getCatalogoRelatorio({
        cd_menu: this.cd_menu,
        cd_usuario: this.cd_usuario
      })
    } catch (e) {
      console.error('Catálogo relatório erro', e)
    }
  },

  // === HELPERS GENÉRICOS ===
getGridRows () {
  // tenta descobrir onde estão as linhas atuais do grid
  if (Array.isArray(this.rows)) return this.rows
  if (Array.isArray(this.dataSource)) return this.dataSource
  if (this.gridData && Array.isArray(this.gridData)) return this.gridData
  return []
},
async refreshGrid () {
  // tenta as rotinas mais comuns para recarregar
  if (typeof this.carregarGrid === 'function') return this.carregarGrid()
  if (typeof this.loadRows === 'function') return this.loadRows()
  if (typeof this.reload === 'function') return this.reload()
  // devextreme dxDataGrid via ref? tenta refresh:
  if (this.$refs && this.$refs.dxGrid && typeof this.$refs.dxGrid.refresh === 'function') {
    return this.$refs.dxGrid.refresh()
  }
},

  async onGerarRelatorio() {
    try {
      const payload = {
        cd_menu: this.cd_menu,
        cd_usuario: this.cd_usuario,
        cd_relatorio: this.relatorioSelecionado, // se você selecionar em um combo
        filtros: this.filtros || {}              // opcional
      }
      const dados = await gerarRelatorioPadrao(payload)
      // você pode reaproveitar os dados pra exportar/mostrar/abrir PDF
      // Ex.: gerar PDF com os dados retornados:
      await gerarPdfRelatorio({
        cd_menu: this.cd_menu,
        cd_usuario: this.cd_usuario,
        dados
      })
    } catch (e) {
      console.error('Relatório erro', e)
      this.$q && this.$q.notify({ 
        type: 'negative', position: 'center',
        message: 'Erro ao gerar relatório.' })
    }
  },

  montarRegistroNovo() {
    // Se você tem this.columns (DevExtreme) já carregadas:
    const cols = (this.columns || []).map(c => c.dataField).filter(Boolean)
    const registro = {}
    cols.forEach(f => { registro[f] = null })

    // valores padrão (se precisar)
    if (this.cd_cliente_padrao) registro.cd_cliente = this.cd_cliente_padrao
    registro.dt_cadastro = new Date().toISOString().slice(0,10)

    return registro
  },

  async onNovoRegistro() {
    try {
      const novo = this.montarRegistroNovo()

      // Monte o payload conforme seu backend espera.
      // Exemplo comum: { cd_menu, cd_usuario, operacao: 'INSERT', registro }
      const payload = {
        cd_menu: this.cd_menu,
        cd_usuario: this.cd_usuario,
        operacao: 'INSERT',
        registro: novo
      }

      await salvarDadosForm(payload)

      this.$q && this.$q.notify({ type: 'positive', position: 'center',
      message: 'Registro incluído.' })

      // Recarrega o grid
      typeof this.carregarGrid === 'function'
        ? await this.carregarGrid()
        : (this.reload && this.reload())
    } catch (e) {
      console.error('Inclusão erro', e)
      this.$q && this.$q.notify({ type: 'negative', position: 'center',
      message: 'Erro ao incluir registro.' })
    }
  },

    scrollDown(qual, cdMenu) {
      // decide o container de scroll
      let refEl = null;
      if (qual === "principal") {
        refEl = this.$refs.scrollShellPrincipal;
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
      const novasTabs = tabMenu.map((t) => {
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

    onRowClickPrincipal(e) {
      const data = e && (e.data || e.row?.data) ? e.data || e.row.data : null;
      const cdMenu = Number(localStorage.cd_menu || this.cd_menu_entrada || 0);

      if (!data) return;

      this.registroSelecionado = e.data || null
      this.registroSelecionadoPrincipal = data; // <-- para usar no cd_documento do processo

      const row = e.data || e.row?.data || {};

      const cd_menu = localStorage.cd_menu || sessionStorage.getItem("cd_menu");

      //
      const plain = {}
      Object.keys(data).forEach((k) => {
      const v = data[k]
      if (v === null || v === undefined) {
        plain[k] = v
        return
      }
      const t = typeof v
      if (t === 'string' || t === 'number' || t === 'boolean') {
        plain[k] = v
        return
      }
      // fallback seguro
      try { plain[k] = JSON.parse(JSON.stringify(v)) }
     catch (err) { plain[k] = String(v) }
   })

   // ✅ grava os dois formatos (genérico e por menu)
   try {
    sessionStorage.setItem('registro_selecionado', JSON.stringify(plain))
    if (cdMenu) sessionStorage.setItem(`registro_selecionado_${cdMenu}`, JSON.stringify(plain))
  } catch (err) {
    console.warn('Falha ao gravar registro selecionado no sessionStorage:', err)
  }

  // (se quiser também pode emitir pro modal e nem depender de storage depois)
  // this.$emit('selecionou', plain)
      // salva registro selecionado como você já faz no dblclick
/*
      sessionStorage.setItem("registro_selecionado", JSON.stringify(data));

  
      if (cd_menu)
        sessionStorage.setItem(
          `registro_selecionado_${cd_menu}`,
          JSON.stringify(data)
        );
*/
      // descobre a PK do pai usando sua meta atual (mesma lógica que você já usa)
      let pkPai =
        this.keyName && row[this.keyName] !== undefined
          ? this.keyName
          : this.keyName || "id";

      // DevExtreme fornece e.key; use se existir
      const idPorKeyDoDx = e && e.key !== undefined ? e.key : undefined;

      // tenta vários caminhos para achar o ID
      // tenta vários caminhos para achar o ID (sem usar ??)
      let id = e && typeof e.key !== "undefined" ? e.key : null;

      // 1) pk da grid
      if (id === null || id === undefined) {
        if (pkPai && Object.prototype.hasOwnProperty.call(data, pkPai)) {
          const v = data[pkPai];
          if (v !== null && v !== undefined) id = v;
        }
      }

      // 2) campos comuns
      if (id === null || id === undefined) {
        if (data.id !== undefined && data.id !== null) id = data.id;
        else if (data.ID !== undefined && row.ID !== null) id = data.ID;
      }

      // 3) fallback: primeira prop com “cara de chave”
      if (id === null || id === undefined) {
        const chaveMatch = Object.keys(data).find((k) =>
          /(^id$|^cd_|_id$)/i.test(k)
        );
        if (chaveMatch) id = row[chaveMatch];
      }

      // guarda o ID do pai
      this.paiSelecionadoId = id;
      this.idPaiDetalhe = id;

      // 4) guardar para a consulta do detalhe
      let descKey = null;
      try {
        const meta = Array.isArray(this.gridMeta)
          ? this.gridMeta
          : JSON.parse(sessionStorage.getItem("campos_grid_meta") || "[]")
          //: JSON.parse(sessionStorage.getItem("campos_grid_meta") || "[]")
          //: [];

        const visiveis = (meta || []).filter((c) => c.ic_mostra_grid === "S");

        const prefer = [
          "descr",
          "descrição",
          "descricao",
          "nome",
          "ds_",
          "nm_",
        ];

        const porTitulo = visiveis.find((c) =>
          prefer.some((p) =>
            (c.nm_titulo_menu_atributo || "").toLowerCase().includes(p)
          )
        );
        const porNome = visiveis.find((c) =>
          prefer.some((p) =>
            (c.nm_atributo || c.nm_atributo_consulta || "")
              .toLowerCase()
              .includes(p)
          )
        );
        const primeiraNaoPk = visiveis.find(
          (c) => (c.nm_atributo || c.nm_atributo_consulta) !== pkPai
        );

        descKey =
          (porTitulo &&
            (porTitulo.nm_atributo || porTitulo.nm_atributo_consulta)) ||
          (porNome && (porNome.nm_atributo || porNome.nm_atributo_consulta)) ||
          (primeiraNaoPk &&
            (primeiraNaoPk.nm_atributo ||
              primeiraNaoPk.nm_atributo_consulta)) ||
          null;
      } catch (_) {}

      this.idPaiDetalhe = this.paiSelecionadoId;
      this.paiSelecionadoTexto = descKey ? data[descKey] || "" : "";

      // 5) habilitar as abas de detalhe
      this.tabsDetalhe = this.tabsDetalhe.map((t) => ({
        ...t,
        disabled: false,
      }));

      // 6) se já está em uma aba de detalhe, recarregar
      if (this.abaAtiva !== "principal") {
        const t = this.tabsDetalhe.find((x) => x.key === this.abaAtiva);
        if (t) this.consultarFilho(t);
      }
    },

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
      const {data} = await payloadTabela(payload);

      //
      const meta = Array.isArray(data) ? data : [];
        
      // monta columns (repetindo seu padrão da principal)

      // === PK do filho: pode ser composta ===
      const pks = (meta || []).filter(
        (m) => String(m.ic_atributo_chave || "").toUpperCase() === "S"
      );

      const keyList = pks
        .map((m) => m.nm_atributo || m.nm_atributo_consulta)
        .filter(Boolean);

      // mantém compatibilidade: string se for 1 campo, array se for >1
      const keyExpr = keyList.length <= 1 ? keyList[0] || "id" : keyList;

      // === FK do filho: prioriza ic_chave_estrangeira === 'S', senão faz heurística ===
      let fkCampo = null;
      const fkFromMeta = (meta || []).find(
        (m) => String(m.ic_chave_estrangeira || "").toUpperCase() === "S"
      );
      if (fkFromMeta) {
        fkCampo = fkFromMeta.nm_atributo || fkFromMeta.nm_atributo_consulta;
      }
      if (!fkCampo) {
        // fallback: heurística baseada na PK do pai
        const pkPai = (this.keyName || "id").toString().toLowerCase();
        const cand = (meta || []).filter(
          (c) => String(c.ic_atributo_chave || "").toUpperCase() !== "S"
        );
        fkCampo =
          cand.find(
            (c) =>
              (c.nm_atributo || c.nm_atributo_consulta || "").toLowerCase() ===
              pkPai
          )?.nm_atributo ||
          cand.find((c) =>
            (c.nm_atributo || c.nm_atributo_consulta || "")
              .toLowerCase()
              .includes(pkPai.replace(/^cd_/, ""))
          )?.nm_atributo ||
          cand.find((c) => {
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
        .filter(function (c) {
          return c.ic_mostra_grid === "S";
        })
        .sort(function (a, b) {
          return (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0);
        })
        .map(function (c) {
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

  // pega TODOS os <td> da linha
  const tds = rowEl.querySelectorAll("td");
  if (!tds || !tds.length) return;

  const isQuasarColor = /^[a-z]+-\d+$/i.test(cor);

  const limparBgClasses = (el) => {
    if (!el || !el.className) return;
    el.className = el.className
      .split(" ")
      .filter((c) => c && !c.startsWith("bg-"))
      .join(" ");
  };

  // 1) limpa bg- do <tr> e zera background
  limparBgClasses(rowEl);
  rowEl.style.backgroundColor = "";

  // 2) limpa bg- e background de TODOS os <td>
  tds.forEach((td) => {
    limparBgClasses(td);
    td.style.backgroundColor = "";
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
      const candidatos = metaFilho.filter((c) => {
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
        (c) =>
          (c.nm_atributo || c.nm_atributo_consulta || "").toLowerCase() ===
          pkPai
      ) ||
        // 3) se não houver, os que CONTÉM o nome da PK do pai (tirando "cd_")
        candidatos.find((c) => {
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
                  (Object.keys(salvo).find((k) =>
                    /(^id$|^cd_|_id$)/i.test(k)
                  ) &&
                    salvo[
                      Object.keys(salvo).find((k) =>
                        /(^id$|^cd_|_id$)/i.test(k)
                      )
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
        rows.forEach((r) => {
          if (fkCampo && (r[fkCampo] === undefined || r[fkCampo] === null)) {
            r[fkCampo] = this.idPaiDetalhe;
          }
        });
      }

      // Realinhar dataField das colunas com base no primeiro row
      var exemplo = rows && rows.length ? rows[0] : null;
      var metaFilho = this.filhos[tab.cd_menu].meta || [];
      var columnsFix = metaFilho
        .filter(function (c) {
          return c.ic_mostra_grid === "S";
        })
        .sort(function (a, b) {
          return (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0);
        })
        .map((c) => {
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
          var keyCi = Object.keys(exemploRow).find(function (n) {
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
      const t = this.tabsDetalhe.find((x) => x.key === this.abaAtiva);
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
    async abrirFormEspecial({ modo = "I", registro = {} } = {}) {
      try {
        // log pra garantir que veio algo
        //console.log('[Form] abrirFormEspecial.modo=', modo, 'registro=', registro);

        // 1) define modo
        this.formMode =
          String(modo).toUpperCase() === "A" || Number(modo) === 2 ? "A" : "I";

        // 2) pegue os metadados primeiro (lookups dependem disso)
        this.atributosForm = this.obterAtributosParaForm();

        //console.log('[Form] atributosForm=', this.atributosForm);

        // Monta tabsheets do formulário a partir dos atributos (nm_tabsheet / cd_tabsheet)
        this.buildTabsheetsFromMeta(this.atributosForm);

       // garante que o modal comece na primeira aba "real" (Cadastro, Endereço, Perfil...)
       this.$nextTick(() => {
         const tabs = this.tabsheetsForm   // usa o computed
         this.activeTabsheet = tabs.length ? tabs[0].key : null
       })

        // se não tiver atributos, monta genérico a partir do registro ou da 1ª linha da grid

        if (!this.atributosForm?.length) {
          const fonte = this.rows?.[0] || registro || {};
          this.atributosForm = Object.keys(fonte).map((k) => ({
            nm_atributo: k,
            nm_edit_label: k,
            tipo_coluna: "varchar",
            tipo_input: "text",
          }));
        }

        // 3) base
        this.record = this.record || {};
        this.formData = this.formData || registro || {};

        if (this.formMode === "I") {
          // inclusão
          this.formData = this.montarRegistroVazio();

          Object.keys(sessionStorage)
            .filter((k) => k.startsWith("fixo_"))
            .forEach((k) => {
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

         // console.log("[Form] formData após mapear=", this.formData);

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

    mapearConsultaParaAtributoRobusto(registro, atributos) {
      const out = {};
      const row = registro || {};
      const keysLower = Object.keys(row).reduce((acc, k) => {
        acc[k.toLowerCase()] = k;
        return acc;
      }, {});

      const get = (nome) => {
        if (!nome) return undefined;
        const k = keysLower[nome.toLowerCase()];
        return k ? row[k] : undefined;
      };

      for (const a of atributos || []) {
        const nm = a.nm_atributo; // ex.: cd_roteiro
        const lbl =
          a.nm_titulo_menu_atributo ||
          a.nm_edit_label ||
          a.ds_atributo ||
          a.nm_atributo;
        const nmDesc = a.nm_atributo_consulta; // ex.: nm_roteiro
        const tituloCodigo = `Código ${lbl}`; // ex.: "Código Roteiro de Visita Padrão"

        // tenta pegar valor em múltiplas formas
        let val =
          get(nm) ??
          get(tituloCodigo) ?? // coluna da grid com prefixo "Código ..."
          get(lbl) ?? // às vezes o código está na coluna com o mesmo label
          undefined;
  
          // === Detecta se é campo de DATA ===
          const rawTipo = String(a.tp_atributo || a.tipo || "").toUpperCase();
          const pareceNomeDeData = /(^dt(_|$))|(^data(_|$))|(_data$)|(_dt$)/i.test(nm);
          const isDate =
            rawTipo.includes("DATE") || rawTipo === "D" || rawTipo === "DATA" || pareceNomeDeData;

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

        // para fins de exibir a descrição logo (se existir na grid)
        if (nmDesc) {
          const desc =
            get(nmDesc) ?? get("Descrição") ?? get(`Descricao`) ?? "";
          if (desc) {
            this.record = this.record || {};
            this.record[nmDesc] = String(desc);
          }
        }
      }

      return out;

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
      // 1) tenta nas opções já carregadas
      const opts = this.lookupOptions?.[attr.nm_atributo] || [];
      const got = opts.find((o) => String(o.__value) === String(code));
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
      const attrs = (this.atributosForm || []).filter((a) =>
        this.temLookupDireto(a)
      );
      await Promise.all(attrs.map((a) => this.carregarLookupDireto(a)));
    },

    async carregarLookupDireto(attr) {
      const rows = await this.postLookup(attr.nm_lookup_tabela);
      const nomeCampo = (attr.nm_atributo || "").toLowerCase();

      const opts = rows.map((r) => {
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
        attr.nm_titulo_menu_atributo || attr.ds_atributo || attr.nm_atributo;
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
        (this.atributosForm || []).forEach((a) => {
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
            lv.forEach((x) => {
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

    abrirPesquisaold(attr) {
      if (!this.temPesquisaDinamica(attr)) return;
      window.abrirPesquisaDinamica &&
        window.abrirPesquisaDinamica(attr.nm_atributo, attr.cd_menu_pesquisa);
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

    descricaoLookup(attr) {
    const campo =
      attr.nm_campo_mostra_combo_box ||
      attr.nm_atributo_lookup ||
      'nm_fantasia_cliente'

       return this.formData[campo] || ''
   },

    // 2.6 lookup direto (select vindo do backend)
    /* garanta que você já popula this.lookupOptions[attr.nm_atributo] = [{__value, __label}] */
    temLookupDireto(attr) {
      return !!attr.nm_lookup_tabela && !attr.cd_menu_pesquisa;
    },

    async loadAllLookups() {
      const alvos = (this.payload || []).filter((c) => this.temLookupDireto(c));
      await Promise.all(alvos.map((c) => this.loadLookup(c)));
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
      const fDtIni = this.filtros.find((f) =>
        /dt_?inicial/i.test(f.nm_atributo || "")
      );
      const fDtFim = this.filtros.find((f) =>
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

    // salvar o CRUD (inclusão/alteração)

    async salvarCRUD(opts) {
      const params = opts || {};
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

      try {

        console.log("Salvando CRUD com formData:", this.formData);

        // validação de obrigatórios

        this.salvando = true;

        const obrig = this.atributosForm
          .filter((a) => a.ic_obrigatorio === "S")
          .map((a) => a.nm_atributo);

        const faltando = obrig.filter(
          (c) =>
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
             const metaKey = `campos_grid_meta_${localStorage.cd_menu || sessionStorage.getItem('cd_menu')}`; 
             // tenta pegar meta específica do menu atual
             meta = JSON.parse(sessionStorage.getItem(metaKey) || "[]"); 

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

        meta.forEach((m) => {
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
              (kk) => kk.toLowerCase() === String(k).toLowerCase()
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
             const [ , yyyy, mm, dd ] = isoMatch;
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
              (m) =>
                String(m.ic_atributo_chave || "")
                  .trim()
                  .toUpperCase() === "S"
            ) || {}
          ).nm_atributo;
          //

          //console.log('Atributo chave encontrado:', chaveAttr);
          //console.log('Valor da chave no row:', row[chaveAttr]);
          //console.log('Payload completo do row:', row);
          //console.log('Payload meta:', meta);

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

        //console.log('cd_documento_form:', cd_documento_form);

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
            cd_menu: String(
              this.cd_menu_principal || this.cd_menu || sessionStorage.getItem("cd_menu") || 0
            ),
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

        // payload final = array com 1 objeto
        const payload = unico;
        //

        // debug
        console.log(
          "JSON que vai para a rota:",
          cd_parametro_form,
          payload,
          dadosTecnicos
        );

        //
        ////
        await api.post("/api-dados-form", payload, {
          headers: { "Content-Type": "application/json" },
        });
        ///

        this.notifyOk(
          this.formMode === "I"
            ? "Registro atualizado com sucesso."
            : "Registro atualizado com sucesso."
        );

        this.dlgForm = false;

        // === RECARREGAR A GRID (coloque logo após o POST OK) ===
        try {
          // 1) Reconsultar seus dados do backend (mantém seus nomes)
          if (typeof this.consultar === "function") {
            await this.consultar(); // deve repopular this.rows com os dados mais recentes
          }

        } catch (e) {
          console.warn("Refresh pós-CRUD falhou:", e);
        }
        
      } catch (e) {
        console.error("Falha ao salvar CRUD:", e);
        this.notifyErr("Erro ao salvar dados do formulário.");
      } finally {
        this.salvando = false;
        this.dialogCadastro = false; // fecha modal depois do refresh
        this.formData = {};
      }
    },

    //
    keyNameInfer() {
      const p = this.payloadTabela || {};
      if (p.key_name) return String(p.key_name).trim() || 'id';
      const t = (p.nm_tabela || p.nm_tabela_consulta || "")
        .toLowerCase()
        .replace(/^dbo\./, "");
      return t ? `cd_${t}` : "id";
    },

    async abrirFormConsulta({ registro = {} } = {}) {
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
      // se quiser limpar lixo de builder:
      const mountEl = this.$refs.formEspecialMount;
      if (mountEl) mountEl.innerHTML = "";
      this.formRenderizou = false;

      //

      if (this.$emit) {
        this.$emit('fechar');
      //  
  }

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
      const isInicial = (f) =>
        /dt_?inicial|data_?inicial|ini(cio|cial)?/i.test(f.nm_atributo || "");
      const isFinal = (f) =>
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
          (f) =>
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
          : meta.map((c) => ({
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

    abrirRelatorio() {
      // garanta que gridRows e camposMetaGrid estão prontos aqui
      if (!Array.isArray(this.columns) || this.columns.length === 0) {
        //this.$q.notify({ type:'warning', position:'top-right', message:'Sem dados para o relatório.' })
        this.notifyWarn("Sem dados para o relatório.");
        return;
      }
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

      const cd_menu = cd_menu_q || cd_menu_ls_dot || cd_menu_ls_get;
      const cd_usuario = cd_usuario_q || cd_usuario_ls_dot || cd_usuario_ls_get;

      this.cd_menu = cd_menu ? String(cd_menu) : null;
      this.cdMenu = this.cd_menu;
      this.temSessao = !!(this.cd_menu && cd_usuario);

       // chave dinâmica que veio do pai (nota / documento / etc)
       this.ncd_acesso_entrada =
       this.ncd_acesso_entrada ||
         window.localStorage.cd_acesso_entrada ||
         window.localStorage.getItem("cd_acesso_entrada") ||
         null


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
      this.montarAbasDetalhe();
      //

      // Carrega os filtros dinâmicos
      await this.loadFiltros(cd_menu, cd_usuario);
      // Se não houver filtro obrigatório, já faz a consulta

      const filtroObrig = this.gridMeta.some(
        (c) => c.ic_filtro_obrigatorio === "S"
      );
      const registroMenu = this.gridMeta.some(
        (c) => c.ic_registro_tabela_menu === "S"
      );

      if (registroMenu && !filtroObrig && !this.isPesquisa) {
        this.consultar();
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
      this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa || 'N';
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
      this.columns.map((c) => {
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
          c.calculateCellValue = (row) => {
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
          return JSON.parse(JSON.parse(JSON.stringify(raw)));
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

      if (this.ic_modal_pesquisa === 'S' || this.cd_chave_pesquisa>0 ) {
      
        if (this.$emit) {
         this.$emit('fechar');

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
            position: 'center',
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
          .filter((c) => c.type !== "buttons")
          .map((c) => ({
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
        const toBR = (v) => {
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
        const money = (n) => {
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
            (k) => k.toLowerCase() === base?.toLowerCase()
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
        const getFiltro = (k) =>
          (this.filtrosValores && this.filtrosValores[k]) || "";
        const dtIni =
          getFiltro("dt_inicial") || getFiltro("dtini") || getFiltro("dt_inic");
        const dtFim =
          getFiltro("dt_final") || getFiltro("dtfim") || getFiltro("dt_fim");

        // 7) Prepara head/body para o AutoTable
        const head = [cols.map((c) => c.label)];
        const body = rowsSrc.map((r) => cols.map((c) => safeGet(r, c)));

        // 8) Totais/resumo com base no seu meta de totalização
        const summary = [];
        if (Array.isArray(this.totalColumns) && this.totalColumns.length) {
          const tot = this.totalColumns.map((t) => {
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
          const nm_caminho_logo_empresa = localStorage.nm_caminho_logo_empresa || "";
          const logoUrl = `https://egisapp.com.br/img/${nm_caminho_logo_empresa}`;
          const res = await fetch(logoUrl);
          const b = await res.blob();
          const b64 = await new Promise((r) => {
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
          didDrawPage: (data) => {
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
            body: summary.map((s) => [
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
          position: 'center',
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
        const isAcao = (c) =>
          c?.type === "buttons" ||
          c?.buttons ||
          c?.field === "__acoes" ||
          c?.name === "__acoes";
        cols = (cols || []).filter((c) => !isAcao(c));

        if (!Array.isArray(rows) || rows.length === 0) {
          this.$q?.notify?.({
            type: "warning",
            position: 'center',
            message: "Sem dados para exportar.",
          });
          return;
        }
        if (!Array.isArray(cols) || cols.length === 0) {
          this.$q?.notify?.({
            type: "warning",
            position: 'center',
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
        const toBRDate = (v) => {
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

        const toBRNumber = (v) => {
          const n = Number(v);
          if (!isFinite(n)) return v ?? "";
          return n.toLocaleString("pt-BR");
        };

        const toBRMoney = (v) => {
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

        const getField = (c) => c.field || c.name || c.dataField;
        const getLabel = (c) =>
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
        const loadImageAsDataUrl = (url) =>
          new Promise((resolve) => {
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
        const columnsForPDF = cols.map((c) => ({
          header: getLabel(c),
          dataKey: getField(c),
        }));

        const body = rows.map((r) => {
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
          tcols.forEach((t) => {
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
          position: 'center',
          message: "Falha ao exportar PDF.",
        });
      }
    },

    async onExportarExcel() {
    try {
      // pegue seus dados atuais do grid;
      // se você guarda em this.rows ou this.dataSource, ajuste abaixo:
      const rows = Array.isArray(this.rows) ? this.rows : (this.dataSource || [])
      await exportarParaExcel({ rows, nomeArquivo: `${this.pageTitle || 'dados'}.xlsx` })
    } catch (e) {
      console.error('Falha ao exportar Excel', e)
      this.$q && this.$q.notify({ type: 'negative', 
      position: 'center',
      message: 'Erro ao exportar Excel.' })
    }
  },

   async onImportarExcelParaTabela(dadosPlanilha) {
    // dadosPlanilha: array de objetos (linhas) já lidos pelo browser
    try {
      await importarExcelParaTabela({
        nome_tabela: this.nome_tabela_import || 'TMP_IMPORT',
        dados: dadosPlanilha
      })
      this.$q && this.$q.notify({ type: 'positive', message: 'Importação concluída.' })
    } catch (e) {
      console.error('Falha ao importar Excel', e)
      this.$q && this.$q.notify({ type: 'negative', 
      position: 'center',
      message: 'Erro ao importar Excel.' })
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
                (c) => c.dataField === gridCell.column?.dataField
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
      const dados = Array.isArray(this.rows) ? this.rows : (this.dataSource || [])
      await gerarPdfRelatorio({
        cd_menu: this.cd_menu,
        cd_usuario: this.cd_usuario,
        dados
      })
      // abre nova aba com o PDF (feito no service)
    } catch (e) {
      console.error('PDF erro', e)
      this.$q && this.$q.notify({ type: 'negative', position: 'center', message: 'Erro ao gerar PDF.' })
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
        .filter((k) => k.startsWith("fixo_"))
        .forEach((k) => {
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

    async onExcluir(row) {
      // garanta que é um objeto plano
      const plain = JSON.parse(JSON.stringify(row));
      // abrir form especial (se necessário)
      //
      this.abrirFormEspecial({ modo: "E", registro: row });
      //

      if (!confirm("Confirma exclusão?")) return;

      //await this.salvarCRUD({ modo: 'E', registro: row });
      //this.gridInst.refresh(); // ou recarregue os dados

      //console.log('Excluir registro:', plain);
      this.formData = plain;
      //
      this.formMode = "E";
      // mapa campos se necessário
      await this.salvarCRUD({ modo: "E", registro: plain }); // cd_parametro_form = 3
      //

      // refresh seguro da grid
      //try {
      //  const inst = this.$refs && this.$refs.grid && this.$refs.grid.instance ? this.$refs.grid.instance : null;
      // if (inst) inst.refresh();
      // else if (typeof this.consultar === 'function') await this.consultar();
      // }
      //   catch(_) {}
      //
    },

    montarRegistroVazio() {
      const attrs = this.obterAtributosParaForm();

      const novo = {};
      attrs.forEach((a) => {
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
      Object.keys(row).forEach((k) => {
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

      // 3) NORMALIZAÇÃO: não “simplifique” os atributos aqui!
      //    Apenas garanta que Lista_Valor esteja em array

      base = base.filter(Boolean).map((a) => {
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
        ];
        flags.forEach((f) => {
          if (attr[f] == null) attr[f] = "N";
        });

        // === ADIÇÃO: detectar se é campo de DATA ===
  const rawTipo = String(attr.tp_atributo || attr.tipo || "").toUpperCase();
  const nome = String(attr.nm_atributo || "");
  const pareceNomeDeData = /(^dt(_|$))|(^data(_|$))|(_data$)|(_dt$)/i.test(nome);
  const isDate =
    rawTipo.includes("DATE") || rawTipo === "D" || rawTipo === "DATA" || pareceNomeDeData;

  if (isDate) {
    attr.__isDate = true;                        // marca para o renderer
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
base.forEach((attr) => {
  const k = attr.nm_atributo;
  // fonte do valor (ajuste conforme sua estrutura)
  const valorAtual =
    (this.form && this.form[k] != null) ? this.form[k]
    : (this.rowEdit && this.rowEdit[k] != null) ? this.rowEdit[k]
    : (attr.vl_atributo != null ? attr.vl_atributo : null);

   //console.log("Antes:", valorAtual);
//console.log("Depois:", toIsoDate(valorAtual, true));


  if (attr.__isDate) {
    // normaliza para 'YYYY-MM-DD' (date-only) — o dxDateBox entende
    //this.$set(this.form, k, this.dateToDx(valorAtual));
    this.$set(this.form, k, toIsoDate(valorAtual, true) || null);
    //

  } else {
    this.$set(this.form, k, valorAtual);
  }



});

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
        const faltando = obrig.filter((c) => !this.temValor(this.formData[c]));
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
        .filter((a) => a.ic_obrigatorio === "S")
        .map((a) => a.nm_atributo);
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

      limparChaves.forEach((k) => sessionStorage.removeItem(k));


      // Remove versões por menu (…_<cd>)
      const cd_menu_atual = Number(cd_menu || 0);

      Object.keys(sessionStorage).forEach((k) => {

     const m = k.match(/^(payload_padrao_formulario|campos_grid_meta|dados_resultado_consulta|registro_selecionado|cd_menu_detalhe|payload_padrao_formulario_detalhe|campos_grid_meta_detalhe|id_pai_detalhe)_(\d+)$/);
  
     if (!m) return;
          
     const cdKey = Number(m[2] || 0);
          
        if (
          /(payload_padrao_formulario|campos_grid_meta|dados_resultado_consulta|registro_selecionado|cd_menu_detalhe|payload_padrao_formulario_detalhe|campos_grid_meta_detalhe|id_pai_detalhe)_(\d+)$/.test(
            k
          )
        ) 
        {

            // se for modal de pesquisa, NÃO mexe no menu pai
            if (this.ic_modal_pesquisa === 'S') {
            if (cdKey === cd_menu_atual) sessionStorage.removeItem(k);
               return;
             }
          
             sessionStorage.removeItem(k);

             }
      });

      const payload = {
        cd_parametro: 1,
        cd_form: localStorage.cd_form, //sessionStorage.getItem("cd_form"),
        cd_menu: Number(cd_menu),
        nm_tabela_origem: "",
        cd_usuario: Number(cd_usuario)
        //
      };

      //console.log("payload->", payload, banco);

      //const { data } = await axios.post("/api/payload-tabela", payload);

      //
      //const { data } = await api.post("/payload-tabela", payload);
      //

      const  data  = await getPayloadTabela(payload)

      // { headers: { 'x-banco': banco } })

      //console.log('dados do retorno: ', data);
      //

      this.gridMeta = Array.isArray(data) ? data : [];

      this.cd_parametro_menu = this.gridMeta?.[0]?.cd_parametro_menu || 0;

      const metaProc = (this.gridMeta || []).find(
          r => Number(r.cd_menu_processo || 0) > 0
      )
      // cd_menu_processo (se houver)
      this.cd_menu_processo = metaProc ? Number(metaProc.cd_menu_processo) : 0
      //  

      // tabsheets (se houver)
      //Tabs Dinâmicas
      this.buildTabsheetsFromMeta(this.gridMeta)

      // mapa de atributos (consulta → atributo)
      this.mapaRows = this._buildMapaRowsFromMeta(this.gridMeta)

      //console.log('grid: ', this.gridMeta, this.cd_parametro_menu  );

      // flag: quando cd_tabela > 0, consulta será direta na tabela
      this.cd_tabela = Number(this.gridMeta?.[0]?.cd_tabela) || 0;
      
      //
      this.mostrarAcoes = ( this.cd_tabela > 0 || this.ic_modal_pesquisa==='S' ) ;
      //

      // título da tela

      this.title =
        this.gridMeta?.[0]?.nm_titulo ||
        sessionStorage.getItem("menu_titulo") ||
        "Formulário";

      sessionStorage.setItem(
        "payload_padrao_formulario",
        JSON.stringify(this.gridMeta)
      );
      sessionStorage.setItem(
        `payload_padrao_formulario_${cd_menu}`,
        JSON.stringify(this.gridMeta)
      );
      sessionStorage.setItem("campos_grid_meta", JSON.stringify(this.gridMeta));
      sessionStorage.setItem(
        `campos_grid_meta_${cd_menu}`,
        JSON.stringify(this.gridMeta)
      );

      sessionStorage.setItem("menu_titulo", this.title);

      console.log('consulta dos dados menu ->', this.gridMeta[0]);

      if (this.gridMeta?.length > 0) {
      this.nome_procedure      = this.gridMeta?.[0]?.nome_procedure || "*";
      this.ic_json_parametro   = this.gridMeta?.[0]?.ic_json_parametro || "N";
      this.cd_menu_modal       = this.gridMeta?.[0].cd_menu_modal || this.cd_menu_modal_entrada || 0;
      this.cd_form_modal       = this.gridMeta?.[0].cd_form_modal || 0;
      this.ic_selecao_registro = this.gridMeta?.[0].ic_selecao_registro || 'N';
      this.mostrarBotaoModalComposicao = this.cd_form_modal > 0;
      this.selectionMode =  this.ic_selecao_registro === 'S' ? 'multiple' : 'single';
      }
      
      // tab_menu (se houver)
      sessionStorage.setItem("tab_menu", this.gridMeta?.[0]?.tab_menu || "");

      
      // 1) MONTAR colunas e totalColumns (meta antigo)

      this.columns = this.gridMeta
        .filter((c) => c.ic_mostra_grid === "S")
        .sort((a, b) => (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0))
        .map((c) => ({
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

      if (this.cd_tabela > 0 ) {

      colAcoes = {
        type: "buttons",
        caption: "Ações",
        width: 110,
        alignment: "center",
        allowSorting: false,
        allowFiltering: false,
        buttons: [
           {
             hint: "Consultar",
             icon: "search",
             onClick: (e) =>
            this.abrirFormConsulta({ registro: e.row.data }),
          },
          {
            hint: "Editar",
            icon: "edit",
            onClick: (e) =>
              this.abrirFormEspecial({ modo: "A", registro: e.row.data }),
          },
          {
            hint: "Copiar",
            icon: "copy",
            onClick: (e) =>
              this.copiarRegistro(e.row.data),      },
          {
            hint: "Excluir",
            icon: "trash",
            onClick: (e) => {
              // idem: objeto PLANO
              const plain = JSON.parse(JSON.stringify(e.row.data));
              this.onExcluir(plain);
            },
          },
        ],
      } }
      else {
        colAcoes = {
          type: "buttons",
          caption: "Ações",
          width: 80,
          alignment: "center",
          allowSorting: false,
          allowFiltering: false,
          buttons: [
             {
               hint: "Selecionar",
               icon: "selectall",
               cssClass: 'btn-selecionar-modal',
               onClick: (e) =>
              this.selecionarERetornar( e.row.data ),
            },
          ],
        }
      }
    
      //summary e totalizadores

      //
      this.totalColumns = this.gridMeta
        .filter((c) => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
        .map((c) => ({
          dataField: c.nm_atributo || c.nm_atributo_consulta,
          type: c.ic_total_grid === "S" ? "sum" : "count",
          display: c.ic_total_grid === "S" ? "Total: {0}" : "{0} registro(s)",
        }));

      this.total = { totalItems: this.totalColumns };

      const mapa = {};

      this.gridMeta.forEach((c) => {
        if (c.nm_atributo && c.nm_atributo_consulta) {
          //mapa[c.nm_atributo] = c.nm_atributo_consulta;
          mapa[c.nm_atributo_consulta] = c.nm_atributo;
        }
      });

      sessionStorage.setItem("mapa_consulta_para_atributo", JSON.stringify(mapa));
      //
      sessionStorage.setItem(this.ssKey("mapa_consulta_para_atributo"), JSON.stringify(mapa))

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
     c => c && c.dataField === 'acoesGridColor'
   );

 
  if (temAcoesGridColor) {
    this.columns = [
    {
      caption: 'Legenda',
      width: 80,
      allowSorting: false,
      allowFiltering: false,
      allowGrouping: false,
      allowHeaderFiltering: false,
      cellTemplate: 'acoesGridColorCellTemplate' // 👈 AGORA GARANTE O TEMPLATE
    },
    ...this.columns
  ];
  console.log('columns com ações --> ', this.columns);
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

  cores.forEach((item) => {
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

    cores.forEach((item) => {
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
  console.log("Filtro Preenchimento --> ", this.filtros);

  for (const f of this.filtros) {
    // Chaves normalizadas
    const chaveLookup = (f.nm_campo_chave_lookup || "").trim(); // pode ser ''
    const destino = chaveLookup !== "" ? chaveLookup : (f.nm_atributo || "").trim(); // fallback para nm_atributo
    const descFieldName = (f.nm_campo_descricao_lookup || "").trim(); // ex.: "Estado"

    // Se não temos destino válido, pula (evita criar chave "")
    if (!destino) {
      console.warn("Filtro sem chave e sem atributo válido:", f);
      continue;
    }

    // 1) Define valor padrão inicial (antes do lookup), sem criar chave vazia
    if (f.nm_valor_padrao != null && this.filtrosValores[destino] == null) {
      const tipo = this.resolvType(f);
      const val = tipo === "date" ? this.toYMD(f.nm_valor_padrao) : String(f.nm_valor_padrao);
      this.$set(this.filtrosValores, destino, val);
      console.log(`Definindo valor padrão do filtro ${destino} = ${val}`);
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
          ? rows.map((r) => {
              const lower = {};
              Object.entries(r || {}).forEach(([k, v]) => {
                lower[String(k).toLowerCase()] = v;
              });

              const keyField = (chaveLookup || destino || "").toLowerCase(); // prioridade para cd_estado; se vazio, usa nm_atributo
              const descField =
                (descFieldName || "").toLowerCase(); // alias do SQL, ex.: "estado"

              const values = Object.values(r || {});
              const code =
                lower[keyField] != null ? lower[keyField] : values[0];

              const label =
                descField
                  ? (lower[descField] != null ? lower[descField] : (values[1] != null ? values[1] : code))
                  : (lower.descricao != null ? lower.descricao : (values[1] != null ? values[1] : code));

              return { value: String(code), label: String(label) };
            })
          : [];

        this.$set(f, "_options", [{ value: "", label: "Selecione..." }, ...opts]);

        // 4) Ajuste do valor padrão baseado nas opções (garante código no destino)
        if (f.nm_valor_padrao != null && this.filtrosValores[destino] == null) {
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
        this.$set(f, "_options", [{ value: "", label: "Erro ao carregar" }]);
      }
    }
  }

  // 5) Restaura filtros salvos
  const salvos = JSON.parse(sessionStorage.getItem("filtros_form_especial") || "{}");
  Object.keys(salvos).forEach((k) => this.$set(this.filtrosValores, k, salvos[k]));

  // 6) Pós-carregamento
  this.$nextTick(() => this.preencherDatasDoMes());
  console.log("filtros carregados:", this.filtrosValores);
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

      console.log('Filtro Preenchimento --> ', this.filtros);

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

          if (f.nm_campo_chave_lookup != '') {
            console.log(
              `Definindo valor padrão do filtro ${f.nm_campo_chave_lookup} = ${val}`
            );
            this.$set(this.filtrosValores, f.nm_campo_chave_lookup, val);
          }    
          else {
            this.$set(this.filtrosValores, f.nm_atributo, val);
          }
          
        }

        // -----------------------------------------------------

        if (f.ic_fixo_filtro === "S") {
            if (f.nm_campo_chave_lookup != '') {
              sessionStorage.setItem(`fixo_${f.nm_campo_chave_lookup}`, f.nm_valor_padrao);
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

        console.log('lookup -> ', f.nm_lookup_tabela);

        // lookup de tabela
          if (f.nm_lookup_tabela && f.nm_lookup_tabela.trim()) {
          try {
            // usa o helper do componente
            const rows = await this.postLookup(f.nm_lookup_tabela);

            const opts = Array.isArray(rows)
              ? rows.map((r) => {
                  const vals = Object.values(r || {});
                  const nomeCampo = (f.nm_campo_chave_lookup || "").toLowerCase();

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

      Object.keys(salvos).forEach((k) =>
        //console.log('montagem: ', this.filtrosValores, k, salvos[k])
        this.$set(this.filtrosValores, k, salvos[k])
      );

      
      // se tiver filtro de data no form, preencha datas do mês atual
      this.$nextTick(() => this.preencherDatasDoMes());
      //
      console.log("filtros carregados:", this.filtrosValores);
      //
    },

    // função principal: monta payload e chama a procedure

    async consultar(payloadManual = null) {

      this.loading = true;
      this.registrosSelecionados = [];

      if (this.ic_selecao_registro === 'S') {
          this.$nextTick(() => {
          const c = this.$refs.consultaRef;
          if (c && typeof c.clearSelection === "function") {
            c.clearSelection();
            }
         });
      }
      

      //console.log('Iniciando consulta...', this.ic_json_parametro, this.nome_procedure);
      // monta payload e chama a procedure

      try {

        //const cd_menu = Number(sessionStorage.getItem("cd_menu"));
        const cd_usuario = localStorage.cd_usuario || Number(sessionStorage.getItem("cd_usuario"));
        const dt_inicial = localStorage.dt_inicial || sessionStorage.getItem("dt_inicial_padrao");
        const dt_final = localStorage.dt_final || sessionStorage.getItem("dt_final_padrao");
        const banco = localStorage.nm_banco_empresa || sessionStorage.getItem('banco') || '';
        
        const campos = {};

        Object.keys(sessionStorage)
          .filter((k) => k.startsWith("fixo_"))
          .forEach(
            (k) => (campos[k.replace("fixo_", "")] = sessionStorage.getItem(k))
          );

        console.log('valores dos filtros -->', this.filtrosValores);

        Object.assign(campos, this.filtrosValores);

        // 🔹 1) Achata objetos de lookup { value, label } => "value"
        Object.keys(campos).forEach((k) => {
        const v = campos[k];
         if (v && typeof v === "object" && "value" in v) {
            campos[k] = v.value; // ex.: sg_estado: {value:"5",label:"BA"} -> "5"
         }
       });

        // validação de filtros obrigatórios

        const ic_filtro_obrigatorio = this.gridMeta?.[0]?.ic_filtro_obrigatorio;
        const ic_cliente = this.gridMeta?.[0]?.ic_cliente || "N";
        const cd_cliente = localStorage.cd_cliente || Number(sessionStorage.getItem("cd_cliente")) || 0;
        
        const filtroPreenchido = Object.values(campos).some(
          (v) => v != null && v !== "" && v !== 0
        );
        
        console.log('filtro --> ', filtroPreenchido,campos);

        const cd_parametro = this.cd_parametro_menu || 0;
        const cd_chave_pesquisa = localStorage.cd_acesso_entrada || this.ncd_acesso_entrada || this.cd_chave_pesquisa || 0;
        
        console.log('chave de pesquisa', cd_chave_pesquisa);
        
        const cd_menu =
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

        let dados = [];
        let payloadExec;

        //console.log('campos do form:', campos);

        // campos vem dinâmicos do seu form
        const camposNormalizados = normalizePayload(campos);

        //console.log('campos da consulta:', camposNormalizados);
        //console.log(campos);
        // se nome_procedure = "*", usa o endpoint /menu-pesquisa (payload padrão)
        console.log('nome_procedure:', this.nome_procedure);
        
        if (this.nome_procedure === "*" || this.nome_procedure === undefined) {
          //console.log('usando endpoint /menu-pesquisa');

          const payload = [
            {
              cd_parametro,
              cd_menu,
              cd_usuario: localStorage.cd_usuario || this.cd_usuario || 0,
              cd_chave_pesquisa: cd_chave_pesquisa || 0,
              ic_modal_pesquisa: this.getIcModalPesquisa() | this.ic_modal_pesquisa || 'N', 
              //dt_inicial, dt_final,
              //dt_inicial: clean(sessionStorage.getItem("dt_inicial_padrao")),
              //dt_final:   clean(sessionStorage.getItem("dt_final_padrao")),
              ...campos,
              //...camposNormalizados,
              ...(ic_cliente === "S" && cd_cliente > 0 ? { cd_cliente } : {}),
            },
          ];

          //const payloadNew = this.montarPayloadPesquisa();

          //console.log('payload da consulta:', payloadNew);
          
          console.log('payload da consulta:', payload);
          
          //
          //pr_egis_pesquisa_dados
          // chama o endpoint padrão de pesquisa

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
                      cd_usuario : localStorage.cd_usuario || this.cd_usuario || 0,
                      ic_json_parametro: "S",
                      ...camposNormalizados,
                      ...(ic_cliente === "S" && cd_cliente > 0 ? { cd_cliente } : {}),
                      ic_modal_pesquisa: this.ic_modal_pesquisa || 'N',
                      dt_inicial,
                      dt_final 
                    },
                  ]
                : { ic_json_parametro: "N", 
                    ...camposNormalizados,
                    ...(ic_cliente === "S" && cd_cliente > 0 ? { cd_cliente } : {}),
                    cd_usuario : localStorage.cd_usuario || this.cd_usuario || 0,
                  };
          }

          //
          console.log('payload da consulta:', this.nome_procedure,payloadExec, banco);
          
          //
          // chama a procedure
          console.log('Chamando procedure:', this.nome_procedure);
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
          Object.keys(mapaOriginal).forEach((tec) => {
            mapa[mapaOriginal[tec]] = tec;
          });

          //
          dados = (data || []).map((item) => {
            const novo = {};
            Object.keys(item).forEach((k) => (novo[mapa[k] || k] = item[k]));
            return novo;
          });
        }
       
        //this.rows = (dados || []).map((it, idx) => ({ id: it.id || idx + 1, ...it }));      
          
        //

        this.rows = (dados || []).map((it, idx) => ({ id: it.id || idx + 1, ...it }));

// >>> NOVO: se veio do botão lápis (modal de pesquisa),
// abre automaticamente o formulário de edição

if (this.ic_modal_pesquisa === 'S') {
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
        sessionStorage.setItem(
          "dados_resultado_consulta", JSON.stringify(this.rows)
        );
        
        sessionStorage.setItem(this.ssKey("dados_resultado_consulta"), JSON.stringify(this.rows))

        sessionStorage.setItem(
          "filtros_form_especial",
          JSON.stringify(this.filtrosValores)
        );

        sessionStorage.setItem(this.ssKey("filtros_form_especial"), JSON.stringify(this.filtrosValores))

        console.log('mapa', dados);
        console.log('resultado', this.rows);
        

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
         (f) => f && f.nm_cor
        );

        console.log("legendaAcoesGrid =>", this.legendaAcoesGrid);

   
  } else {
    this.fasePedido = [];
    this.legendaAcoesGrid = [];
  }


        // totais simples para o rodapé
        this.totalQuantidade = this.totalColumns.some((c) => c.type === "count")
          ? this.rows.length
          : 0;

        this.totalValor = this.totalColumns
          .filter((c) => c.type === "sum")
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

        this.notifyOk(`Consulta finalizada: ${this.rows.length} registro(s).`);

        this.panelIndex = 1; // mostra a grid

        this.$nextTick(() => {
          try {
            const inst =
              this.$refs && this.$refs.grid && this.$refs.grid.instance
                ? this.$refs.grid.instance
                : null;

          if (inst) {
          inst.beginUpdate();
          inst.option('dataSource', this.rows); // 2º: dataSource
          inst.option('focusedRowEnabled', true);
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
</script>

<style scoped>



/* Seleção/linha focada laranja */
.dx-datagrid .dx-row-focused,
.dx-datagrid .dx-selection,
.dx-datagrid .dx-selection.dx-row > td {
  background-color: #ff7043 !important; /* laranja */
  color: #fff !important;
}

/* Cabeçalho mais forte e linha alternada suave */
.dx-datagrid .dx-header-row {
  background-color: #f6f6f6;
  font-weight: 600;
}
.dx-datagrid .dx-row-alt > td {
  background-color: #fafafa;
}
/* Espaço para não colidir com um footer fixo de ~56px */
.q-notifications__list--bottom,
.q-notifications__list--bottom-right,
.q-notifications__list--bottom-left {
  margin-bottom: 64px; /* ajuste conforme a altura do rodapé */
}
.dx-datagrid .dx-command-select {
  width: 36px; /* largura do checkbox */
}
/* dá respiro dentro do card */
.dx-card.wide-card.filtros-card {
  padding: 12px 16px 16px;
  border-radius: 8px;
}

/* Compacta o card de filtros */
.filtros-card {
  padding: 12px 14px; /* antes era maior */
  border-radius: 10px;
}

/* Reduz o espaço entre as colunas sem cortar o padding interno */
.filtros-wrap {
  /* controla o gutter real */
  margin-left: -6px;
  margin-right: -6px;
}

/* reativa gutters mesmo se algum reset tiver zerado .row */
.filtros-row {
  margin-left: -8px !important;
  margin-right: -8px !important;
}
.filtros-row > [class*="col-"] {
  padding-left: 8px !important;
  padding-right: 8px !important;
}

/* garante que q-input/q-select ocupem toda a coluna */
.full-w,
.full-w .q-field,
.full-w.q-input,
.full-w.q-select {
  width: 100%;
}

/* se algum CSS global removeu espaçamento vertical do q-field, repõe */
.filtros-row .q-field {
  margin-top: 4px;
  margin-bottom: 4px;
}

.row {
  margin: 0 !important;
}
.row > [class*="col-"] {
  padding: 0 !important;
}

/* aumenta a altura (min-height) dos campos e alinha os ícones lateral/append */
.filtro-item .q-field--filled .q-field__control,
.filtro-item .q-field--outlined .q-field__control {
  min-height: 56px; /* ajuste aqui: 48px, 56px, 64px... */
  padding-top: 10px; /* espaço pro label empilhado */
  padding-bottom: 6px;
}

.filtro-item .q-field__marginal {
  height: 56px; /* mantém os ícones com a mesma altura */
}

/* se quiser dar um respiro vertical entre linhas no mobile */
.filtro-item {
  /* ajusta respiro interno do campo */
  padding: 4px 2px;
  padding-left: 6px;
  padding-right: 6px;
  margin-bottom: 12px;
}

/* opcional: deixa o label um pouco mais forte/visível */
.filtro-item .q-field__label {
  font-weight: 600;
}

/* Ícones (prepend/append) menos “folgados” */
.filtro-item .q-field__prepend,
.filtro-item .q-field__append {
  padding-left: 6px;
  padding-right: 6px;
}

/* Linha do botão com pouco espaço acima */
.filtros-actions {
  margin-top: 8px;
  padding-left: 2px;
}

.filters-grid {
  display: grid;
  /*grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); */
  grid-template-columns: repeat(12, 1fr);
  grid-column-gap: 12px; /* horizontal gap menor */
  grid-row-gap: 10px; /* vertical gap menor */
}

.filter-grid > div {
  grid-column: span 12; /* default: 1 por linha no mobile */
}

/* cada filtro ocupa 4 colunas em desktop, 12 no mobile */
.filter-item {
  grid-column: span 12;
}

/* altura visual dos inputs “filled” do Quasar */
.q-field--filled .q-field__control {
  min-height: 64px; /* aumenta a “altura” do campo */
  padding-top: 8px;
  padding-bottom: 6px;
}

.dx-card.wide-card {
  padding: 12px 12px; /* sutil e consistente */
}

.espaco {
  padding-top: 200px;
  margin-top: 100px;
}

@media (min-width: 768px) {
  .filter-grid > div {
    grid-column: span 6; /* 2 por linha no tablet */
  }
}

@media (min-width: 1200px) {
  .filter-grid > div {
    grid-column: span 4; /* 3 por linha no desktop */
  }
}

.leitura-azul {
  background-color: #e7f1ff !important;
  color: #0d47a1;
}
/* pode ser global ou no <style scoped> do SFC */
.leitura-azul .q-field__control {
  background: #e7f1ff !important;
}
.leitura-azul .q-field__native,
.leitura-azul .q-field__label {
  color: #0d47a1 !important;
}

.viewport {
  overflow: hidden;
  width: 100%;
}
.track {
  display: flex;
  width: 200%;
  transition: transform 0.3s ease;
}
.pane {
  width: 50%;
  padding: 8px;
}

.hshell {
  width: 100%;
  overflow: hidden; /* oculta o painel fora de vista */
  position: relative;
  min-height: 320px; /* ajuste: garante altura para a grid */
}

.htrack {
  display: flex;
  width: 200%; /* 2 painéis de 100% cada */
  transition: transform 0.25s ease;
}

.hpanel {
  flex: 0 0 100%; /* cada painel ocupa 100% da largura da hshell */
  width: 100%;
  box-sizing: border-box;
  padding: 8px 8px 0;
}

.filtros-container {
  position: sticky;
  top: 0;
  z-index: 10;
  background: white;
  padding: 8px 0;
  border-bottom: 1px solid #ddd;
}

.grid-scroll-shell {
  overflow-x: auto;        /* só scroll horizontal quando precisar */
  overflow-y: auto;        /* deixa rolar vertical, não corta o bottom */
  white-space: normal;     /* não força tudo numa linha só */
  width: 100%;
  position: relative;
  padding: 0 16px 18px 0;  /* mais respiro na direita e embaixo */
  box-sizing: border-box;  /* padding não “rouba” largura */
}



/* track para garantir largura fluida */
.grid-scroll-track {
  position: relative;
  white-space: nowrap;
  display: inline-block;
  min-width: 100%;
}

.dx-datagrid-rowsview {
  padding-right: 8px;
  padding-bottom: 4px;
}

.arrow-btn {
  position: fixed;
  top: 20%;
  margin-left: 5px;
  margin-right: 5px;
  transform: translateY(40%);
  z-index: 2000;
}

.arrow-btn.left {
  left: 60px;
}

.arrow-btn.right {
  right: 10px;
}

/* escopo local do componente */
.q-tabs__content {
  border-bottom: 2px solid var(--q-color-deep-orange-9);
  margin-bottom: 6px;
}

/* garante que o footer da DevExtreme apareça e não “cole” errado */
.dx-datagrid-total-footer,
.dx-datagrid-pager {
  position: sticky;
  bottom: 0;
  background: #fff;
  z-index: 2;
}

.fab-down {
  position: sticky; /* gruda no fim da área scrollável */
  bottom: 12px;
  float: right;
  margin-right: 12px;
  z-index: 5;
}
.margin-menu {
  position: absolute; right: 10px;
  top: 30px;
 
}
.bg-form {
  position: absolute; top: 20px;
  margin-right: 1px;
  align-items: right;
}
.fo-margin {
  margin-left: 40px;
}
.fo-margin-direita {
  margin-right: 40px;
}
/* Ícone roxo no botão de processo */
::v-deep .btn-processo-menu .dx-link-icon .dx-button-content .dx-icon{
  color: #5e35b1; /* deep-purple-7 */
}
/* Se quiser o fundo do botão com um roxo clarinho: */
::v-deep .btn-processo-menu .dx-link .dx-button-content {
  background-color: #ede7f6;
  border-radius: 9999px;
  padding: 2px 4px;
}

.my-notify {
  font-size: 1.4rem;     /* aumenta o texto */
  padding: 20px;         /* mais espaço interno */
  border-radius: 8px;    /* cantos arredondados */
  text-align: center;    /* centraliza o texto */
}

.tabs-form {
  width: 100%;
}
.tabsheets-form .tabsheets-form__tab {
  flex: 1 1 0;
  min-width: 0;
   justify-content: center; /* centraliza o texto */
}
.tabsheets-form .tabsheets-form__tab--active {
  border-bottom: 3px solid var(--q-color-deep-orange-9);
} 

.dlg-form-card {
  min-width: 760px;
  max-width: 94vw;
  height: 90vh;        /* altura fixa do modal */
  max-height: 90vh;
  display: flex;
  flex-direction: column;
}

/* essa é a área central que deve rolar, não o card inteiro */
.dlg-form-card__body {
  flex: 1 1 auto;
  overflow-y: auto;
}

.acoes-grid-color-wrapper {
  display: flex;
  gap: 4px;
  align-items: center;
  justify-content: center;
}

.acoes-grid-color-dot {
  display: inline-block;      /* 👈 ESSENCIAL */
  width: 16px;
  height: 16px;
  border-radius: 50%;
  /* opcional: borda pra ver bem o círculo */
  border: 1px solid rgba(0, 0, 0, 0.2);
}

.dx-datagrid .acoes-grid-color-dot {
  width: 20px;
  height: 10px;
}

.acoes-grid-legenda {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.acoes-grid-legenda-titulo {
  font-weight: 600;
  margin-top: 6px;
  margin-right: 4px;
  margin-left: 16px;
}

.acoes-grid-legenda-item {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  margin-top: 6px;
}

.acoes-grid-legenda-text {
  white-space: nowrap;
}

.dx-datagrid .dx-row .acoes-grid-color-cell {
  background-color: #ffffff !important;
}

/* primeira coluna da grid (Legenda) SEMPRE branca */
.dx-datagrid-rowsview .dx-row > td:first-child {
  background-color: #ffffff !important;
}

/* mesma coisa quando a linha está selecionada / focada / hover */
.dx-datagrid-rowsview .dx-row.dx-selection > td:first-child,
.dx-datagrid-rowsview .dx-row.dx-row-focused > td:first-child,
.dx-datagrid-rowsview .dx-row.dx-state-hover > td:first-child {
  background-color: #ffffff !important;
}

.tam-icon .q-icon {
  font-size: 16px;
  width: 16px;
  height: 16px; /* ajuda em caso de SVG/inline-block */
  line-height: 16px;
}

.titulo-modal {
  font-size: 28px;
  line-height: 32px;
  font-weight: 600;
}

.titulo-normal {
  font-size: 64px; /* ou o que você já usa */
  line-height: 64px;
  font-weight: 300;

  
}
.titulo-modal {
  white-space: normal;
  word-break: break-word;
}

.btn-selecionar-modal .dx-button {
  background: #673ab7 !important; /* deep-purple */
  border-color: #673ab7 !important;
  color: #fff !important;
}
.btn-selecionar-modal .dx-icon {
  color: #fff !important;
}


</style>

