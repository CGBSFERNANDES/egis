<template>
  <div>

    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />

    <!-- TOPO no estilo -->

    <div class="row items-center">
      <transition name="slide-fade">
        <!-- título + seta + badge -->
        <div class="topbar" v-show="tituloMenu || title">
          <!-- seta voltar -->
          <q-btn flat round dense icon="arrow_back" class="q-mr-sm" aria-label="Voltar" @click="onVoltar" />
          <h2>
            {{ tituloMenu || title }}
          </h2>

          <!-- badge com total de registros -->

          <q-badge v-if="(qt_registro || recordCount) >= 0" align="middle" rounded color="red"
            :label="qt_registro || recordCount" class="q-ml-sm bg-form" />

          <!-- botões -->
          <q-btn rounded color="deep-purple-7" class=" q-ml-sm" icon="picture_as_pdf" @click="exportarPDF" />
          <q-btn rounded color="deep-purple-7" class=" q-ml-sm" icon="description" @click="abrirRelatorio" />
          <q-btn rounded color="deep-purple-7" class=" q-ml-sm" icon="view_list" @click="dlgMapaAtributos = true" />
<q-btn
  v-if="false"
  color="deep-purple-7"
  class=" q-ml-sm"
  dense
  rounded
  icon="visibility"
  label="NFS-e"
  :disable="!podeVisualizarNFSe"
  @click="visualizarNFSe"
/>
<q-btn
  v-if="false"
  color="deep-purple-7"
  class=" q-ml-sm"
  rounded
  dense
  icon="visibility"
  label="CT-e"
  :disable="!podeVisualizarCTe"
  @click="visualizarCTe"
/>


          <!-- TODO: checar se é necessário -->
          <!-- Botão de processos (3 pontinhos) -->
          <!-- <q-btn v-if="cd_menu_processo > 0" rounded color="deep-purple-7" class=" q-ml-sm" icon="more_horiz"
            @click="abrirMenuProcessos" /> -->
          <q-btn rounded color="deep-purple-7" class=" q-ml-sm" icon="info" @click="onInfoClick" />
          <!-- <q-chip v-if="(cdMenu || cd_menu) && (1 == 1)" rounded color="deep-purple-7" class=" q-ml-auto margin-menu"
            size="16px" text-color="white" :label="`${cdMenu || cd_menu}`" /> -->
        </div>
      </transition>
    </div>

    <!-- Formulário de entrada -->
    <div class="toolbar-entrada q-pa-md">


    <!-- Tipo XML -->
    <div class="te-item te-tipo-xml">
      <q-select
        v-model="form.cd_tipo_xml"
        :options="opcoesTipoXml"
        emit-value
        map-options
        dense
        outlined
        label="Tipo XML"
      />
    </div>

     <div class="te-item te-filtro-tipo">
      <q-select
        v-model="filtro.cd_tipo_xml"
        :options="[{ label: 'Todos', value: null }, ...opcoesTipoXml]"
        emit-value
        map-options
        dense
        outlined
        label="Filtrar por Tipo"
      />
    </div>

    <!-- Arquivo XML -->
    <div class="te-item te-arquivo">
      <q-file
        v-if="1===2"
        v-model="form.arquivo"
        accept=".xml"
        dense
        outlined
        label="Selecione o arquivo XML"
        use-chips
        @input="onFileChange"
      >
        <template v-slot:append>
          <q-btn
            flat
            dense
            icon="close"
            round
            @click="limparArquivo"
            v-if="form.arquivo"
          />
        </template>
      </q-file>

      <q-file
        v-model="form.arquivos"
        label="Selecione o arquivo XML"
        multiple
        @update:model-value="onFilesSelected"
      >
        <template v-slot:append>
          <q-btn
            flat
            dense
            icon="close"
            round
            @click="limparArquivo"
            v-if="form.arquivos.length"
          />
        </template>
      </q-file>
    </div>

    <!-- BOTÕES, TODOS LADO A LADO -->
    <div class="te-item te-botoes">
      <q-btn
        color="deep-purple-7"
        label="Importar"
        :disable="!podeImportar"
        :loading="importando"
        @click="enviar"
        rounded
        unelevated
        icon="cloud_upload"
        :class="['q-mt-sm', 'q-ml-sm']"
      />
     <q-btn
        color="deep-purple-7"
        label="Consultar"
        :loading="loading"
        @click="consultar"
        rounded
        unelevated
        :class="['q-mt-sm', 'q-ml-sm']"
        icon="search"
      />
       <q-btn
        color="deep-purple-7"
        label="Processar"
        :loading="loading"
        @click="processar"
        rounded
        unelevated
        :class="['q-mt-sm', 'q-ml-sm']"
        icon="repeat"
      />
    
     <q-btn
        rounded
        color="deep-purple-7"
        icon="far fa-file-excel"
        @click="exportarExcel && exportarExcel()"
        :disable="!rows.length"
        :loading="exporting"
        :class="['q-mt-sm', 'q-ml-sm']"
        label="Excel"
      />
    </div>

  <!-- Grid -->
      <div class="q-mt-md grid">
        <q-card flat bordered>
          <q-separator />
          <q-card-section class="q-pa-none">
            <DxDataGrid
              ref="gridDados"
              :width="'100%'"
              :data-source="rows"
              :height="gridHeight"
              :column-auto-width="true"
              :row-alternation-enabled="true"
              :show-borders="true"
              :hover-state-enabled="true"
              :word-wrap-enabled="true"
              no-data-text="Sem dados"
              :onRowDblClick="onRowDblClick"
            >
             <DxColumn
                caption="Ações"
                :width="180"
                :allow-sorting="false"
                cell-template="acoesCell"
              />
              <DxFilterRow :visible="true" />
              <DxHeaderFilter :visible="true" />
              <DxSearchPanel :visible="true" :highlight-case-sensitive="false" :width="260" />
              <DxGroupPanel :visible="false" />
              <DxGrouping :auto-expand-all="false" />
              <DxSelection mode="none" />

              <!-- Paginação -->
              <DxPaging :enabled="!usarScrollVirtual" :page-size="pageSize" />
              <DxPager
                :visible="!usarScrollVirtual"
                :show-page-size-selector="true"
                :allowed-page-sizes="pageSizes.map(p=>p.value)"
                :show-navigation-buttons="true"
                :show-info="true"
              />

              <!-- Scrolling -->

              <DxScrolling :mode="usarScrollVirtual ? 'virtual' : 'standard'" />

              <DxColumn
                v-for="c in columns"
                :key="c.dataField"
                :data-field="c.dataField"
                :caption="c.caption"
                :data-type="c.dataType"
                :format="c.format || undefined"
                :width="c.width || undefined"
                :visible="c.visible !== false"
                :allow-sorting="true"
              />
              <template #acoesCell="{ data }">
                          <div class="q-gutter-xs">
                              <q-btn
                                dense
                                round
                                color="deep-orange-9"
                                icon="edit"
                                @click="abrirFormEspecialNota(data.data)"
                           />
                           <q-btn
                            dense
                            round
                            color="deep-purple-7"
                            icon="list_alt"
                            @click="abrirItensNota(data.data)" 
                          />
                          <q-btn dense round
                           color="primary" icon="picture_as_pdf" @click="abrirDanfe(data.data)" />
                          <q-btn dense 
                           round 
                           color="secondary" icon="cloud_download" @click="baixarXml(data.data)" />
                       </div>
              </template>
            </DxDataGrid>

<!-- Dialog full-screen com o unicoFormEspecial dentro -->

<q-dialog v-model="mostrarFormEspecial" persistent maximized>
  <q-card style="width: 100%; height: 100%;">
    <unico-form-especial
      :cd_menu_entrada="cdMenuForm"
      :cd_acesso_entrada="cdAcessoEntradaForm"
      :ic_modal_pesquisa="icModalPesquisaForm"
      :cd_menu_modal="cdMenuModalForm"
      @fechar="fecharFormEspecial"
    />
  </q-card>
</q-dialog>

          </q-card-section>
        </q-card>
      </div>
    </div>
    <q-inner-loading :showing="loading || importando" />

    <!-- TODO: precisa ajustar DIALOG DO MAPA DE ATRIBUTOS -->

    <q-dialog v-model="dlgMapaAtributos">
      <q-card style="min-width: 760px; max-width: 96vw">
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">
            Mapa de Atributos – {{ tituloMenu || title }}
          </div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-separator />

        <q-card-section>
          <dx-data-grid class="dx-card wide-card" :data-source="mapaRows" :column-auto-width="true"
            :row-alternation-enabled="true" :show-borders="true" height="60vh">
            <DxColumn v-for="c in mapaColumns" :key="c.dataField" :data-field="c.dataField" :caption="c.caption"
              :width="c.width" :min-width="c.minWidth" :alignment="c.alignment" />
          </dx-data-grid>
        </q-card-section>
      </q-card>
    </q-dialog>

    <!-- TODO: precisa ajustar Diálogo do Relatório PDF -->
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
            :empresaNome="this.empresa"
            :totais="totalColumns"
            @pdf="exportarPDF()"
            @excel="exportarExcel()"
          />
        </q-card-section>
      </q-card>
    </q-dialog>


    <q-dialog v-model="nfseRel.open" maximized>
  <q-card class="bg-white">
    <q-bar>
      <div class="text-weight-medium">Visualização NFS-e</div>
      <q-space />
      <q-btn dense flat icon="print" @click="imprimirNFSe" />
      <q-btn dense flat icon="close" v-close-popup />
    </q-bar>

    <q-card-section class="q-pa-md">
      <div v-if="!nfseRel.dados" class="text-grey">
        Sem dados.
      </div>

      <div v-else class="nfse-paper">

        <div class="row items-start q-col-gutter-md">
          <div class="col-8">
            <div class="text-h6">NFS-e (DANFSE)</div>
            <div class="text-caption text-grey">Layout: {{ nfseRel.dados.ds_layout }}</div>
          </div>
          <div class="col-4 text-right">
            <div class="text-subtitle1"><b>Nº:</b> {{ nfseRel.dados.nr_nfse }}</div>
            <div><b>Emissão:</b> {{ nfseRel.dados.dt_emissao }}</div>
            <div><b>Cód. Verificação:</b> {{ nfseRel.dados.cd_verificacao }}</div>
          </div>
        </div>

        <q-separator class="q-my-sm" />

        <div class="row q-col-gutter-md">
          <div class="col-6">
            <div class="text-subtitle2">Prestador</div>
            <div><b>CNPJ:</b> {{ nfseRel.dados.cnpj_prestador }}</div>
            <div><b>IM:</b> {{ nfseRel.dados.im_prestador }}</div>
          </div>
          <div class="col-6">
            <div class="text-subtitle2">Tomador</div>
            <div><b>CNPJ:</b> {{ nfseRel.dados.cnpj_tomador }}</div>
          </div>
        </div>

        <q-separator class="q-my-sm" />

        <div class="row q-col-gutter-md">
          <div class="col-12">
            <div class="text-subtitle2">Serviço</div>
            <div class="row q-col-gutter-md">
              <div class="col-4"><b>Item Lista:</b> {{ nfseRel.dados.item_lista_servico }}</div>
              <div class="col-4"><b>Cód. Trib. Mun.:</b> {{ nfseRel.dados.cod_trib_municipio }}</div>
              <div class="col-4"><b>Município Prest.:</b> {{ nfseRel.dados.municipio_prestacao }}</div>
            </div>
            <div class="q-mt-sm">
              <b>Discriminação:</b>
              <div class="nfse-box">{{ nfseRel.dados.ds_discriminacao }}</div>
            </div>
          </div>
        </div>

        <q-separator class="q-my-sm" />

        <div class="row q-col-gutter-md">
          <div class="col-3"><b>Vlr Serviços:</b> {{ nfseRel.dados.vl_servicos }}</div>
          <div class="col-3"><b>Base Calc:</b> {{ nfseRel.dados.base_calculo }}</div>
          <div class="col-3"><b>Alíquota:</b> {{ nfseRel.dados.aliq_iss }}</div>
          <div class="col-3"><b>Vlr ISS:</b> {{ nfseRel.dados.vl_iss }}</div>
          <div class="col-12 text-right q-mt-sm">
            <div class="text-subtitle1"><b>Valor Líquido:</b> {{ nfseRel.dados.vl_liquido }}</div>
          </div>
        </div>

      </div>
    </q-card-section>
  </q-card>
</q-dialog>

<q-dialog v-model="cteRel.open" maximized>
  <q-card class="bg-white">
    <q-bar>
      <div class="text-weight-medium">DACTE Simplificado</div>
      <q-space />
      <q-btn dense flat icon="print" @click="imprimirCTe" />
      <q-btn dense flat icon="close" v-close-popup />
    </q-bar>

    <q-card-section class="q-pa-md">
      <div v-if="!cteRel.dados" class="text-grey">
        Sem dados.
      </div>

      <div v-else class="cte-paper">

        <div class="row items-start q-col-gutter-md">
          <div class="col-8">
            <div class="text-h6">Conhecimento de Transporte Eletrônico (CT-e)</div>
            <div class="text-caption text-grey">
              Chave: {{ cteRel.dados.ch_cte }}
            </div>
          </div>

          <div class="col-4 text-right">
            <div class="text-subtitle1">
              <b>Nº:</b> {{ cteRel.dados.nr_cte }} <span v-if="cteRel.dados.serie">/ {{ cteRel.dados.serie }}</span>
            </div>
            <div><b>Emissão:</b> {{ cteRel.dados.dt_emissao }}</div>
            <div><b>Modal:</b> {{ cteRel.dados.modal }} <span v-if="cteRel.dados.cfop">| <b>CFOP:</b> {{ cteRel.dados.cfop }}</span></div>
          </div>
        </div>

        <q-separator class="q-my-sm" />

        <div class="row q-col-gutter-md">
          <div class="col-6">
            <div class="text-subtitle2">Emitente</div>
            <div><b>CNPJ:</b> {{ cteRel.dados.cnpj_emit }}</div>
            <div><b>Nome:</b> {{ cteRel.dados.xnome_emit }}</div>
          </div>
          <div class="col-6">
            <div class="text-subtitle2">Destinatário</div>
            <div><b>Doc:</b> {{ cteRel.dados.cnpj_dest }}</div>
            <div><b>Nome:</b> {{ cteRel.dados.xnome_dest }}</div>
          </div>
        </div>

        <q-separator class="q-my-sm" />

        <div class="row q-col-gutter-md">
          <div class="col-12">
            <div class="text-subtitle2">Percurso</div>
            <div class="row q-col-gutter-md">
              <div class="col-6">
                <b>Origem:</b> {{ cteRel.dados.xmun_ini }} - {{ cteRel.dados.uf_ini }}
              </div>
              <div class="col-6">
                <b>Destino:</b> {{ cteRel.dados.xmun_fim }} - {{ cteRel.dados.uf_fim }}
              </div>
            </div>
          </div>
        </div>

        <q-separator class="q-my-sm" />

        <div class="row q-col-gutter-md">
          <div class="col-12">
            <div class="text-subtitle2">Carga</div>
            <div class="row q-col-gutter-md">
              <div class="col-4"><b>Vlr Carga:</b> {{ cteRel.dados.v_carga }}</div>
              <div class="col-8"><b>Produto Predominante:</b> {{ cteRel.dados.pro_pred }}</div>
            </div>
          </div>
        </div>

        <q-separator class="q-my-sm" />

        <div class="row q-col-gutter-md">
          <div class="col-3"><b>Vlr Prestação:</b> {{ cteRel.dados.v_tprest }}</div>
          <div class="col-3"><b>Vlr a Receber:</b> {{ cteRel.dados.v_rec }}</div>
          <div class="col-3"><b>Tipo CT-e:</b> {{ cteRel.dados.tp_cte }}</div>
          <div class="col-3"><b>Tipo Serviço:</b> {{ cteRel.dados.tp_serv }}</div>
        </div>

      </div>
    </q-card-section>
  </q-card>
</q-dialog>


  </div>
</template>

<script>

import api from "@/boot/axios";
import { getInfoDoMenu, getPayloadTabela } from "@/services";
import { mapColumnsFromDB, fetchMapaAtributo  } from '@/services/mapaAtributo';
import UnicoFormEspecial from '@/views/unicoFormEspecial.vue' // ajuste o caminho se for outro

import {
  DxDataGrid,
  DxColumn,
  DxFilterRow,
  DxHeaderFilter,
  DxGroupPanel,
  DxGrouping,
  DxSearchPanel,
  DxSelection,
  DxPaging,
  DxPager,
  DxScrolling,
} from "devextreme-vue/data-grid";
import ExcelJS from "exceljs";
import { saveAs } from "file-saver";
import { exportDataGrid } from "devextreme/excel_exporter";
import Relatorio from "@/components/Relatorio.vue";

// ==== utils de data ==== //
const pad2 = n => (n < 10 ? '0' + n : '' + n)
function ddmmyyyy(date) {
  if (!date) return null
  const d = new Date(date)
  const dd = pad2(d.getDate())
  const mm = pad2(d.getMonth() + 1)
  const yyyy = d.getFullYear()
  return `${dd}/${mm}/${yyyy}`
}
function yyyymmdd(date) {
  if (!date) return null
  const d = new Date(date)
  const dd = pad2(d.getDate())
  const mm = pad2(d.getMonth() + 1)
  const yyyy = d.getFullYear()
  return `${yyyy}-${mm}-${dd}`
}
function parseDMY(str) {
  if (!str) return null
  const m = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(str)
  if (!m) return null
  const [ , dd, mm, yyyy ] = m
  return new Date(+yyyy, +mm - 1, +dd)
}
function currentMonthRange() {
  const now = new Date()
  const first = new Date(now.getFullYear(), now.getMonth(), 1)
  const last  = new Date(now.getFullYear(), now.getMonth() + 1, 0)
  return { first, last }
}
// ======================== //
const banco = localStorage.nm_banco_empresa;

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
//
export default {
  name: "EntradaXML",
  components: {
    Relatorio,
    DxDataGrid,
    DxColumn,
    DxFilterRow,
    DxHeaderFilter,
    DxGroupPanel,
    DxGrouping,
    DxSearchPanel,
    DxSelection,
    DxPaging,
    DxPager,
    DxScrolling,
    UnicoFormEspecial,
  },
  data() {
    
    const { first, last } = currentMonthRange()

    return {
      cd_empresa: localStorage.cd_empresa || 0,
      tituloMenu: localStorage.nm_menu_titulo || "Entrada de XML",
      iLote : 0,
      importando: false,
      cd_tabela: null,
      loading: false,
      loadingImport: false,
      exporting: false,
      gridHeight: "65vh",
      cd_nota: null,   
      // upload/import
      form: {
        cd_tipo_xml: 55,
        arquivo: null,
        arquivos: [],
        ds_xml: "",
      },

      // filtros
      filtro: {
        cd_tipo_xml: null,
        dt_inicial: ddmmyyyy(localStorage.dt_inicial) || ddmmyyyy(first),
        dt_final: ddmmyyyy(localStorage.dt_final) || ddmmyyyy(last),
      },

      rows: [],
      columns: [],

      opcoesTipoXml: [
        { label: "55 - NFe", value: 55 },
        { label: "65 - NFCe", value: 65 },
        { label: "NFS-e (Serviço - GINFES)", value: 200 },
        { label: "CT-e (Conhecimento Transporte)", value: 300 },
      ],

      usarScrollVirtual: false,

      pageSize: 50,

      pageSizes: [
        { label: '20', value: 20 },
        { label: '50', value: 50 },
        { label: '100', value: 100 },
        { label: '200', value: 200 },
      ],
      qt_registro: null,
      usuario: null,
      headerBanco: null,
      recordCount: null,
      mostrarFormEspecial: false,
      cdMenuForm: null,
      cdMenuModalForm: null,
      cdAcessoEntradaForm: null,
      processingNotas: null,
      icModalPesquisaForm: 'N',

      // info do menu
      cd_menu: localStorage.cd_menu,
      isDialogInfoOpen: false,
      infoTitulo: "",
      infoTexto: "",

      // mapa de atributos
      dlgMapaAtributos: false,
      mapaRows: [],
      mapaColumns: [],

      // TABS do formulário (definidas pelo meta)
      tabsheets: [],        // [{ key, label, cd_tabsheet, fields:[] }]
      activeTabsheet: "dados",

      gridMeta: [],

      showRelatorio: false,
      logo: localStorage.nm_caminho_logo_empresa,
      nm_usuario: localStorage.usuario,

      gridRows: [],
      gridColumns: [],
      gridSummary: null,
      empresa: localStorage.empresa,
      nfseRel: {
        open: false,
        loading: false,
        dados: null
      },
      cteRel: {
        open: false,
        loading: false,
        dados: null
      },
 

    };
  },
  async created () {
    
    // ...restante do seu fluxo (carregar rows, etc.)
    this.bootstrap();
  },

  computed: {
  
  podeVisualizarCTe () {
    const driver = this._tipoDriver(this.form.cd_tipo_xml || this.filtro.cd_tipo_xml);
    if (driver.tipo !== 'CTE') return false;

    const row = this.linhaSelecionada || (this.selectedRows && this.selectedRows[0]);
    return !!(row && row.cd_cte_xml);
  },
  
  podeVisualizarNFSe () {
    const driver = this._tipoDriver(this.form.cd_tipo_xml || this.filtro.cd_tipo_xml);
    if (driver.tipo !== 'NFSE') return false;
    // ajuste aqui conforme seu controle de seleção:
    return this.linhaSelecionada && (this.linhaSelecionada.cd_nfse_xml || this.linhaSelecionada.cd_nfse_xml === 0);
  },


  podeImportar () {
    const temArquivos = Array.isArray(this.form.arquivos) && this.form.arquivos.length > 0
    const temXmlDigitado = !!this.form.ds_xml

    return (
      !!this.form.cd_tipo_xml &&
      (temArquivos || temXmlDigitado) && !this.importando
  )
   },
  },  

  methods: {

    imprimirCTe () {
  window.print();
},

    async visualizarCTe () {
  const row = this.linhaSelecionada || (this.selectedRows && this.selectedRows[0]);
  const id = row && row.cd_cte_xml;

  if (!id) {
    this.$q.notify({ type: 'warning', position: 'center', message: 'Selecione um CT-e.' });
    return;
  }

  this.cteRel.loading = true;

  try {
    const cfg = this.headerBanco ? { headers: { 'x-banco': this.headerBanco } } : undefined;

    // mantenha o mesmo formato que seu /exec já aceita (objeto)
    const body = 
    [{ ic_json_parametro: 'S',
       cd_cte_xml: id }];


    const resp = await api.post('/exec/pr_cte_xml_obter', body, cfg);
    const rows = this.resolveRows(resp && resp.data);
    const dados = Array.isArray(rows) ? rows[0] : null;

    if (!dados) {
      this.$q.notify({ type: 'warning', position: 'center', message: 'CT-e não encontrado.' });
      return;
    }

    this.cteRel.dados = dados;
    this.cteRel.open = true;

  } catch (e) {
    const r = e && e.response;
    const msg =
      (r && r.data && (r.data.Msg || r.data.message || r.data.error)) ||
      e.message ||
      'Erro ao abrir visualização do CT-e.';
    this.$q.notify({ type: 'negative', position: 'center', message: msg });
  } finally {
    this.cteRel.loading = false;
  }
},


    imprimirNFSe () {
  // imprime o modal. Se quiser imprimir só a área nfse-paper,
  // a gente cria CSS @media print mais enxuto.
  window.print();
},

async visualizarNFSe () {
  const row = this.linhaSelecionada; // ajuste conforme seu grid
  const id = row && row.cd_nfse_xml;

  if (!id) {
    this.$q.notify({ type: 'warning', position: 'center', message: 'Selecione uma NFS-e.' });
    return;
  }

  this.nfseRel.loading = true;

  try {
    const cfg = this.headerBanco ? { headers: { 'x-banco': this.headerBanco } } : undefined;

    // IMPORTANTE: manter o mesmo formato de payload que seu /exec já aceita.
    // Seu consultar original funciona com OBJETO. Então aqui também vai como OBJETO.
    const body = [{ 
      ic_json_parametro: 'S',
      cd_nfse_xml: id }];

    const resp = await api.post('/exec/pr_nfse_xml_obter', body, cfg);
    const rows = this.resolveRows(resp && resp.data);
    const dados = Array.isArray(rows) ? rows[0] : null;

    if (!dados) {
      this.$q.notify({ type: 'warning', position: 'center', message: 'NFS-e não encontrada.' });
      return;
    }

    this.nfseRel.dados = dados;
    this.nfseRel.open = true;

  } catch (e) {
    const r = e && e.response;
    const msg =
      (r && r.data && (r.data.Msg || r.data.message || r.data.error)) ||
      e.message ||
      'Erro ao abrir visualização.';
    this.$q.notify({ type: 'negative', position: 'center', message: msg });
  } finally {
    this.nfseRel.loading = false;
  }
},

    
    async loadPayload(cd_menu, cd_usuario) {
      //

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
      Object.keys(sessionStorage).forEach((k) => {
        if (
          /(payload_padrao_formulario|campos_grid_meta|dados_resultado_consulta|registro_selecionado|cd_menu_detalhe|payload_padrao_formulario_detalhe|campos_grid_meta_detalhe|id_pai_detalhe)_(\d+)$/.test(
            k
          )
        ) {
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

      console.log("payload->", payload, banco);

      //const { data } = await axios.post("/api/payload-tabela", payload);

      //
      //const { data } = await api.post("/payload-tabela", payload);
      //

      const data = await getPayloadTabela(payload);

      // { headers: { 'x-banco': banco } })

      //console.log('dados do retorno: ', data);
      //

      this.gridMeta = Array.isArray(data) ? data : [];

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

      // mapa de atributos (consulta → atributo)
      this.mapaRows = this._buildMapaRowsFromMeta(this.gridMeta);

      //console.log('grid: ', this.gridMeta, this.cd_parametro_menu  );

      // flag: quando cd_tabela > 0, consulta será direta na tabela
      this.cd_tabela = Number(this.gridMeta?.[0]?.cd_tabela) || 0;
      //
      this.mostrarAcoes = (this.cd_tabela > 0);

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

      this.nome_procedure = this.gridMeta?.[0]?.nome_procedure || "*";
      this.ic_json_parametro = this.gridMeta?.[0]?.ic_json_parametro || "N";

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

      const colAcoes = {
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
              this.copiarRegistro(e.row.data),
          },
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
      };

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

      //

      // 5) NUNCA popular dados aqui; zera!
      this.rows = [];
      this.gridRows = [];
      this.totalQuantidade = 0;
      this.totalValor = 0;

    },

    async loadFiltros(cd_menu, cd_usuario) {
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

      for (const f of this.filtros) {
        if (
          f.nm_valor_padrao != null &&
          this.filtrosValores[f.nm_atributo] == null
        ) {
          const tipo = this.resolvType(f); // <- novo
          const val =
            tipo === "date" // <- novo
              ? this.toYMD(f.nm_valor_padrao) // <- novo (aceita "dd/mm/aaaa" ou Date)
              : f.nm_valor_padrao;
          this.$set(this.filtrosValores, f.nm_atributo, val);
        }

        // -----------------------------------------------------

        if (f.ic_fixo_filtro === "S") {
          sessionStorage.setItem(`fixo_${f.nm_atributo}`, f.nm_valor_padrao);
          continue;
        }

        if (
          f.nm_valor_padrao != null &&
          this.filtrosValores[f.nm_atributo] == null
        ) {
          this.$set(this.filtrosValores, f.nm_atributo, f.nm_valor_padrao);
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
                  const nomeCampo = (f.nm_atributo || "").toLowerCase();

                  // acesso case-insensitive ao campo código
                  const lower = {};
                  Object.entries(r || {}).forEach(([k, v]) => {
                    lower[String(k).toLowerCase()] = v;
                  });

                  const code =
                    lower[nomeCampo] != null ? lower[nomeCampo] : vals[0];

                  const label =
                    lower.descricao != null
                      ? lower.descricao
                      : vals[1] != null
                      ? vals[1]
                      : code;

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

      Object.keys(salvos).forEach((k) =>
        this.$set(this.filtrosValores, k, salvos[k])
      );

      // se tiver filtro de data no form, preencha datas do mês atual
      this.$nextTick(() => this.preencherDatasDoMes());
      //
      console.log("filtros carregados:", this.filtros, this.filtrosValores);
      //
    },

    // === Constrói Tabsheets a partir do gridMeta ===
    buildTabsheetsFromMeta(meta) {

      // Garante que sempre vamos trabalhar com um array
      const arr = Array.isArray(meta) ? meta : (meta ? [meta] : [])

      // Se não vier nada do back, zera as tabs

      if (!arr.length) {
        this.tabsheets = [
          {
            key: "dados",
            label: "Dados",
            cd_tabsheet: 1,
            fields: []
          },
          {
            key: "mapa",
            label: "Atributos",
            cd_tabsheet: -1,
            fields: []
          }
        ];

        this.activeTabsheet = "dados";
        return;

      }

      // Agrupa atributos por cd_tabsheet
      const grupos = {};

      arr.forEach(r => {           // <-- AGORA CORRETO
        const cd = Number(r.cd_tabsheet || 0);
        const nm = String(r.nm_tabsheet || "").trim() || "Dados";

        if (!grupos[cd]) {
          grupos[cd] = {
            key: cd === 0 ? "dados" : `tab_${cd}`,
            label: nm,
            cd_tabsheet: cd,
            fields: []
          };
        }

        grupos[cd].fields.push(r);

      });

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
        key: "mapa",
        label: "Mapa de Atributos",
        cd_tabsheet: -1,
        fields: []
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
          r.nu_ordem ||
          r.qt_ordem_atributo ||
          r.qt_ordem ||
          idx + 1
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
    async bootstrap() {
      console.log("bootstrap da entrada XML");
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

      // TODO: checar se this.montarAbasDetalhe() é necessário igual no unicoFormEspecial.vue
      // this.montarAbasDetalhe();
      //

      // Carrega os filtros dinâmicos
      console.log("antes de chamar loadFiltros", cd_menu, cd_usuario);
      console.log("cd_menu:", cd_menu); 
      console.log("cd_usuario:", cd_usuario);
      await this.loadFiltros(cd_menu, cd_usuario);
      // Se não houver filtro obrigatório, já faz a consulta

      const filtroObrig = this.gridMeta.some(
        (c) => c.ic_filtro_obrigatorio === "S"
      );
      const registroMenu = this.gridMeta.some(
        (c) => c.ic_registro_tabela_menu === "S"
      );

      if (registroMenu && !filtroObrig && !this.isPesquisa) {
        console.log(
          "antes de chamar this.consultar(); - sem filtro obrigatório e registro tabela menu → consulta automática"
        );
        this.consultar();
      }
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

    // Botões do topo
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
    async exportarPDF() {
      console.log("chamou exportarPDF");
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
        } catch (_) { }

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
    async onInfoClick() {
      const { titulo, descricao } = await getInfoDoMenu(this.cd_menu, {
        tituloFallback: localStorage.menu_titulo || this.pageTitle // se você tiver um título local
      });
      this.infoTitulo = titulo + " - " + this.cd_menu.toString();
      this.infoTexto = descricao;
      this.infoDialog = true;
    },
    // ======
    onVoltar() {
      if (this.$router) this.$router.back();
      else window.history.back();
    },

    // === ações da grid ===
   onRowDblClick(e){
      if(e && e.data)
      //console.log('dados da grid',e.data);
      //this.abrirDanfe(e.data) },
    this.abrirItensNota(e.data);
    // abre o form especial (itens da nota)

},

abrirFormEspecialNota(row) {

    console.log('abrirFormEspecialNota ->', row);

    // mesma lógica para descobrir a chave da nota
    const cd_nota = row.cd_xml_nota || 0;
    console.log('nota para edição', cd_nota);

    const cd_usuario =
      Number(localStorage.getItem("cd_usuario")) ||
      Number(this.$store?.state?.user?.cd_usuario || 0);

    const cd_menu = 8518; // mesmo menu que você já está usando

    // props que vão para o unicoFormEspecial
    this.cdMenuForm = cd_menu;
    this.cdAcessoEntradaForm = cd_nota || 0;
    this.cdMenuModalForm = cd_menu;
    this.icModalPesquisaForm = 'N';

    // grava no localStorage para o unicoFormEspecial usar no payload
    localStorage.setItem("cd_menu", cd_menu);
    localStorage.setItem("cd_menu_entrada", cd_menu);
    localStorage.setItem("cd_menu_modal", cd_menu);

    localStorage.cd_chave_pesquisa  = cd_nota || 0;
    localStorage.cd_acesso_entrada  = cd_nota || 0;

    // <<< AQUI É O PULO DO GATO: diz pro filho que veio de modal de pesquisa
    //this.icModalPesquisaForm = 'N';

    // abre o diálogo com o único form
    this.mostrarFormEspecial = true;

},


abrirItensNota(row) {
    console.log('abrirItensNota ->', row);
    // aqui você pega o ID da nota
    // ajuste o campo conforme vem do seu back: cd_nota, cd_documento, etc.
    const cd_nota = row.cd_xml_nota || 0;
    console.log('nota', cd_nota);

    // garante cd_usuario (pega de onde você já usa no sistema)
    const cd_usuario =
      Number(localStorage.getItem("cd_usuario")) ||
      Number(this.$store?.state?.user?.cd_usuario || 0);

    // grava o menu e a nota em storage (o unicoFormEspecial já usa isso)
     this.cdMenuForm = 8755   // para esse caso específico (itens nota entrada)
     this.cdAcessoEntradaForm = row.cd_nota || 0 ;
     this.icModalPesquisaForm = 'N';

    localStorage.setItem("cd_menu", 8755);
 
    localStorage.setItem("cd_menu_entrada", 8755);

    // se quiser, mantém a nota também na sessionStorage
    localStorage.cd_chave_pesquisa = cd_nota || 0;
    localStorage.cd_acesso_entrada =  cd_nota || 0;

    this.icModalPesquisaForm = 'N';

    //
        
    // abre o componente filho
    this.mostrarFormEspecial = true
    //
    
  },

  fecharFormEspecial () {
    this.mostrarFormEspecial = false
  },

getBanco(){
    const b = localStorage.nm_banco_empresa;
return b || this.headerBanco || (this.$route && this.$route.query && this.$route.query.banco) || ''
},

getApiBase(){
try { return process.env.VUE_APP_API_BASE || window.location.origin } catch(e){ return window.location.origin }
},

abrirDanfe(row){
  
  // Se o DxDataGrid te entrega { data: { ... } } em alguns templates,
  // garanta o objeto certo:
  const r = row?.data ? row.data : row;

  // 1) SETA a seleção usada pelos relatórios
  this.linhaSelecionada = r;

  // 2) pega o tipo vindo do select (form ou filtro)
  const cdTipo = Number(this.form?.cd_tipo_xml ?? this.filtro?.cd_tipo_xml ?? 0);

  // debug forte
  console.log('PDF -> row:', row);
  console.log('PDF -> cdTipo:', cdTipo, 'typeof:', typeof cdTipo);

  const driver = this._tipoDriver(cdTipo);
  const tipo = (driver?.tipo || '').toUpperCase();

  console.log('PDF -> driver:', driver, 'tipo:', tipo);

   if (tipo === 'NFSE') {
      return this.visualizarNFSe()  // já usa linhaSelecionada
   }

   if (tipo === 'CTE') {
      return this.visualizarCTe()   // já usa linhaSelecionada
   }

   //continua o que está está gerando corretamente

   //console.log('abrir danfe', row);

   const banco = this.getBanco() || localStorage.nm;
   const base = this.getApiBase();
 
 //console.log(banco, base);

 const chave = String(row.cd_chave_acesso || row.chave || row.chave_acesso || '').replace(/\D+/g,'');
 
 //console.log('chave de acesso :', chave);

 if (!chave || chave.length !== 44) {
    this.$q.notify({ type:'warning', position: 'center', message:'Chave inválida.' });
    return;
 }

const appBase = window.location.origin.replace(/\/+$/,''); 
const apiBase = this.getApiBase(); // ex.: https://egiserp.com.br/api

//console.log(appBase);
//console.log(apiBase);

// monta a URL do informativo, repassando api, banco e chave
  const urlInfo = `${appBase}/informativo-danfe.php`
    + `?chave=${encodeURIComponent(chave)}`
    + (banco ? `&banco=${encodeURIComponent(banco)}` : '')
    + `&api=${encodeURIComponent(apiBase)}`
    + `&somente=1`; // <<< isso faz o informativo usar diretamente o nfecon

 // window.open(urlInfo, '_blank');

 if (chave && chave.length === 44){
//const url = `${base}/nfe/nfce/danfe/${encodeURIComponent(chave)}${banco?`?banco=${encodeURIComponent(banco)}`:''}`.replace(/\$/g,'$$');
const url = `${base}/nfe/danfe/por-chave/${encodeURIComponent(chave)}${banco ? `?banco=${encodeURIComponent(banco)}` : ''}`;
// 

window.open(url,'_blank');
return;

}
if (row.cd_nota_saida){
const url = `${base}/api/nfe/nfce/danfe/xml/${encodeURIComponent(row.cd_nota_saida)}${banco?`?banco=${encodeURIComponent(banco)}`:''}`.replace(/\$/g,'$$');
window.open(url,'_blank');
return;
}
this.$q.notify({type:'warning', position: 'center', message:'Linha sem chave de acesso (44 dígitos).'});
},

baixarXml(row){

 const banco = this.getBanco();
const base = this.getApiBase();
const chave = String(row.cd_chave_acesso || row.chave || row.chave_acesso || '').replace(/\D+/g,'');
if (!chave || chave.length !== 44){
this.$q.notify({type:'warning', position: 'center', message:'Esta linha não tem chave de acesso (44 dígitos).'});
return;
}
//const url = `${base}/api/nfe/nfce/xml/${encodeURIComponent(chave)}${banco?`?banco=${encodeURIComponent(banco)}`:''}`.replace(/\$/g,'$$');
//
const url = `${base}/api/nfe/xml/por-chave/${encodeURIComponent(chave)}${banco ? `?banco=${encodeURIComponent(banco)}` : ''}`;
// 
window.open(url,'_blank');
//
},

// === helpers de grid ===

    inferirColunas(linhas) {
      if (!linhas || !linhas.length) return [];
      const sample = linhas[0];
      return Object.keys(sample).map((k) => ({
        dataField: k,
        caption: this.titulo(k),
        dataType: this.tipo(sample[k]),
        format: this.formato(sample[k]),
        width: k === "ds_xml_preview" ? 500 : undefined,
      }));
    },
    titulo(k) {
      return (k || "")
        .replace(/_/g, " ")
        .replace(/\b\w/g, (c) => c.toUpperCase());
    },
    tipo(v) {
      if (v == null) return "string";
      if (typeof v === "number") return "number";
      if (v instanceof Date) return "date";
      if (/^\d{4}-\d{2}-\d{2}T/.test(String(v))) return "datetime";
      return "string";
    },
    formato(v) {
      if (v instanceof Date) return "dd/MM/yyyy";
      if (/^\d{4}-\d{2}-\d{2}T/.test(String(v))) return "dd/MM/yyyy HH:mm";
      return undefined;
    },
    resolveRows(data) {
      if (Array.isArray(data)) return data;
      if (data && data.recordset) return data.recordset;
      if (data && data.rows) return data.rows;
      if (data && data.data) return data.data;
      return [];
    },
    forceGridResize() {
      this.$nextTick(() => {
        try {
          if (this.$refs.gridDados && this.$refs.gridDados.instance) {
            this.$refs.gridDados.instance.updateDimensions();
          }
        } catch (e) {}
      });
    },

    // === upload ===
    onFileChange(val) {
      const file = Array.isArray(val) ? val[0] : val;
      if (!file) {
        this.form.ds_xml = "";
        return;
      }
      const reader = new FileReader();
      reader.onload = (evt) => {
        this.form.ds_xml = evt.target.result;
      };
      reader.onerror = () => {
        this.$q.notify({ type: "negative", position: 'center', message: "Erro ao ler o XML." });
      };
      reader.readAsText(file, "UTF-8");
    },
    
    limparArquivo() {
      this.form.arquivo = null;
      this.form.ds_xml = "";
      this.form.arquivos = [];
    },

    extrairChaveAcesso(xmlString = '', fileName = '') {
    // 1) tenta pelo nome do arquivo (mostra na sua UI)
    const fromName = String(fileName || '').match(/\b\d{44}\b/);
    if (fromName) return fromName[0];

    // 2) tenta pela tag <chNFe>...</chNFe>
    const byTag = String(xmlString || '').match(/<chNFe>\s*(\d{44})\s*<\/chNFe>/i);
    if (byTag) return byTag[1];

    // 3) tenta pelo atributo Id="NFeNNNN..." (ou CFe, por garantia)
    const byIdNFe = String(xmlString || '').match(/<infNFe[^>]*Id=["']NFe(\d{44})["']/i);
    if (byIdNFe) return byIdNFe[1];

    const byIdCFe = String(xmlString || '').match(/<infNFe[^>]*Id=["']CFe(\d{44})["']/i);
    if (byIdCFe) return byIdCFe[1];

    return '';
  },

  // NOVO: ler arquivo como texto
  lerArquivoXml (file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = e => resolve(e.target.result)
      reader.onerror = reject
      reader.readAsText(file)
    })
  },

  validarXmlAssinatura (xmlString) {
    if (!xmlString) {
      return { valido: false, mensagem: 'XML inválido: conteúdo vazio.' }
    }

    const parser = new DOMParser()
    const xmlDoc = parser.parseFromString(xmlString, 'application/xml')
    const parseError = xmlDoc.getElementsByTagName('parsererror')
    if (parseError && parseError.length) {
      return { valido: false, mensagem: 'XML inválido: formato não reconhecido.' }
    }

    const infNfeTags = xmlDoc.getElementsByTagNameNS('*', 'infNFe')
    if (!infNfeTags || !infNfeTags.length) {
      return { valido: false, mensagem: 'XML inválido: não contém infNFe.' }
    }

    const signatureTags = xmlDoc.getElementsByTagNameNS('*', 'Signature')
    if (!signatureTags || !signatureTags.length) {
      return { valido: false, mensagem: 'XML inválido: assinatura digital não encontrada.' }
    }

    return { valido: true, mensagem: '' }
  },

  onFilesSelected (valOrEvent) {
    // se vier do input nativo
    if (valOrEvent && valOrEvent.target && valOrEvent.target.files) {
      this.form.arquivos = Array.from(valOrEvent.target.files)
    } else {
      // se vier do q-file (array de files já)
      this.form.arquivos = Array.isArray(valOrEvent) ? valOrEvent : (valOrEvent ? [valOrEvent] : [])
    }

    // opcional: se só 1 arquivo, já mostra o XML dele na tela
    if (this.form.arquivos.length === 1) {
      this.lerArquivoXml(this.form.arquivos[0]).then(xml => {
        this.form.ds_xml = xml
      })
    } else {
      this.form.ds_xml = ''
    }

    this.iLote = this.form.arquivos.length; 


  },

    // === exportação ===
    async exportarExcel() {
      if (!this.rows.length) return;
      this.exporting = true;
      try {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet("Notas XML");

        await exportDataGrid({
          component: this.$refs.gridDados.instance,
          worksheet,
          keepColumnWidths: true,
          customizeCell: ({ gridCell, excelCell }) => {
            if (gridCell && gridCell.rowType === 'data') {
              if (gridCell.column && gridCell.column.dataField === 'ds_xml_preview') {
                excelCell.alignment = { wrapText: true, vertical: 'top' };
              }
            }
          }
        });

        const buffer = await workbook.xlsx.writeBuffer();
        const stamp = new Date();
        const nome = `notas_xml_${stamp.getFullYear()}-${pad2(stamp.getMonth()+1)}-${pad2(stamp.getDate())}_${pad2(stamp.getHours())}${pad2(stamp.getMinutes())}.xlsx`;
        saveAs(new Blob([buffer], { type: 'application/octet-stream' }), nome);
        this.$q.notify({ type: 'positive', position: 'center', message: 'Excel gerado com sucesso.' });
      } catch (e) {
        this.$q.notify({ type: 'negative', position: 'center', message: e.message || 'Falha ao exportar Excel.' });
      } finally {
        this.exporting = false;
      }
    },

    
    _tipoDriver (cdTipo) {
      const t = Number(cdTipo || 0)

      // NFe / NFCe (produto)
      if (t === 55 || t === 65) {
        return {
          tipo: 'NFE',
          inserirProc: 'pr_nota_xml_inserir',
          listarProc: 'pr_nota_xml_listar',
          processarProc: 'pr_egis_recebimento_processo_modulo',
          processarParametro: 5
        }
      }

      // NFS-e (serviço - GINFES)
      if (t === 200) {
        return {
          tipo: 'NFSE',
          inserirProc: 'pr_nfse_xml_inserir',
          listarProc: 'pr_nfse_xml_listar',
           obterProc:  'pr_nfse_xml_obter',
          processarProc: 'pr_egis_nota_servico_processo',
          processarParametro: 900
        }
      }

      // CT-e (placeholder)
      if (t === 300) {
        return {
          tipo: 'CTE',
          inserirProc: 'pr_cte_xml_inserir',
          listarProc: 'pr_cte_xml_listar',
          obterProc:  'pr_cte_xml_obter',
          processarProc: 'pr_cte_processo',
          processarParametro: 950,
          disabled: false
        }
      }

      // fallback
      return {
        tipo: 'NFE',
        inserirProc: 'pr_nota_xml_inserir',
        listarProc: 'pr_nota_xml_listar',
        processarProc: 'pr_egis_recebimento_processo_modulo',
        processarParametro: 5
      }
    },


    async enviarOld () {
  if (!this.podeImportar) return;

  this.importando = true;
  const arquivos = Array.isArray(this.form.arquivos) ? this.form.arquivos : [];

  const cfg = this.headerBanco
    ? { headers: { 'x-banco': this.headerBanco } }
    : undefined;

  try {
    // 1) há arquivos selecionados? importa cada um
    if (arquivos.length) {
      for (const file of arquivos) {
        const xml = await this.lerArquivoXml(file);
        const chave = this.extrairChaveAcesso(xml, file.name) || null;

        const body = [{
          ic_json_parametro: 'S',
          cd_tipo_xml: this.form.cd_tipo_xml,
          ds_xml: xml,
          cd_chave_acesso: chave,
          cd_empresa: this.cd_empresa || localStorage.cd_empresa || 0,
          cd_usuario_inclusao: localStorage.cd_usuario || this.usuario?.cd_usuario || null
        }];

        console.log('Importando XML:', file.name, 'chave:', chave, body);

        //
        await api.post('/exec/pr_nota_xml_inserir', body, cfg);
        //

      }

    } else if (this.form.ds_xml) {
      // 2) fallback: sem arquivos, mas XML digitado/colado manualmente
      const chave = this.extrairChaveAcesso(this.form.ds_xml, '') || null;

      const body = [{
        ic_json_parametro: 'S',
        cd_tipo_xml: this.form.cd_tipo_xml,
        ds_xml: this.form.ds_xml,
        cd_chave_acesso: chave,
        cd_usuario_inclusao: this.usuario?.cd_usuario || null
      }];

      console.log('Importando XML único (ds_xml): chave:', chave, body);

      await api.post('/exec/pr_nota_xml_inserir', body, cfg);

    } else {
      console.warn('Nenhum XML selecionado/definido para importar.');
      return;
    }

    // 3) limpar form e recarregar grid

    this.form.arquivos = [];
    this.form.ds_xml = '';

    // ajuste aqui para o método que você usa para listar as notas importadas
    if (typeof this.consultar === 'function') {
      await this.consultar();
    }


  } catch (e) {
    console.error('Erro ao importar XML(s):', e);
    if (this.$q?.notify) {
      this.$q.notify({ type: 'negative', position: 'center', message: 'Erro ao importar XML(s): ' + (e.message || e) });
    } else {
      alert('Erro ao importar XML(s): ' + (e.message || e));
    }
  } finally {
    this.importando = false;
  }
},

//

 async enviar () {

  if (!this.podeImportar) return;

  const driver = this._tipoDriver(this.form.cd_tipo_xml);
  if (driver.disabled) {
    this.$q?.notify?.({ type: 'warning', position: 'center', message: 'Tipo ainda não implantado.' });
    return;
  }

  this.importando = true;
  const arquivos = Array.isArray(this.form.arquivos) ? this.form.arquivos : [];

  const cfg = this.headerBanco
    ? { headers: { 'x-banco': this.headerBanco } }
    : undefined;

  try {
    // 1) há arquivos selecionados? importa cada um
    if (arquivos.length) {
      for (const file of arquivos) {
        const xml = await this.lerArquivoXml(file);
        const chave = this.extrairChaveAcesso(xml, file.name) || null;

        if (driver.tipo === 'NFE') {
          const validacao = this.validarXmlAssinatura(xml);
          if (!validacao.valido) {
            this.$q?.notify?.({
              type: 'warning',
              position: 'center',
              message: `${file.name}: ${validacao.mensagem}`
            });
            continue;
          }
        }
        
        let body = '' 

        /*
        const body = driver.tipo === 'NFSE'
          ? [{
              ic_json_parametro: 'S',
              cd_usuario_inclusao: this.usuario?.cd_usuario || null,
              ds_layout: 'GINFES',
              ds_xml: xml
            }]
          : [{
              ic_json_parametro: 'S',
              cd_tipo_xml: this.form.cd_tipo_xml,
              ds_xml: xml,
              cd_chave_acesso: chave,
              cd_usuario_inclusao: this.usuario?.cd_usuario || null
            }];
        */


        if (driver.tipo === 'NFSE') {
  // ✅ NFSe: melhor mandar cd_empresa e manter ic_json_parametro
  body = [{
    ic_json_parametro: 'S',
    cd_empresa: this.cd_empresa || localStorage.cd_empresa || 0,
    cd_usuario_inclusao: localStorage.cd_usuario || this.usuario?.cd_usuario || null,
    ds_layout: 'GINFES',
    ds_xml: xml
  }];

} else if (driver.tipo === 'CTE') {
  // ✅ CT-e (300)
  body = [{
    ic_json_parametro: 'S',
    cd_empresa: this.cd_empresa || localStorage.cd_empresa || 0,
    cd_usuario_inclusao: localStorage.cd_usuario || this.usuario?.cd_usuario || null,
    ds_layout: 'CTE',
    ds_xml: xml
  }];

} else {
  // ✅ NFe/NFCe (como já estava)
  body = [{
    ic_json_parametro: 'S',
    cd_tipo_xml: this.form.cd_tipo_xml,
    ds_xml: xml,
    cd_chave_acesso: chave,
    cd_empresa: this.cd_empresa || localStorage.cd_empresa || 0,
    cd_usuario_inclusao: localStorage.cd_usuario || this.usuario?.cd_usuario || null,

  }];
}

        console.log('Importando XML:', file.name, 'chave:', chave, body);

        //
        await api.post(`/exec/${driver.inserirProc}`, body, cfg);
        //

      }

    } else if (this.form.ds_xml) {
      // 2) fallback: sem arquivos, mas XML digitado/colado manualmente
      const chave = this.extrairChaveAcesso(this.form.ds_xml, '') || null;

      if (driver.tipo === 'NFE') {
        const validacao = this.validarXmlAssinatura(this.form.ds_xml);
        if (!validacao.valido) {
          this.$q?.notify?.({
            type: 'warning',
            position: 'center',
            message: validacao.mensagem
          });
          return;
        }
      }

      const body = driver.tipo === 'NFSE'
        ? [{
            cd_usuario_inclusao: this.usuario?.cd_usuario || null,
            ds_layout: 'GINFES',
            ds_xml: this.form.ds_xml
          }]
        : [{
            ic_json_parametro: 'S',
            cd_tipo_xml: this.form.cd_tipo_xml,
            ds_xml: this.form.ds_xml,
            cd_chave_acesso: chave,
            cd_usuario_inclusao: this.usuario?.cd_usuario || null
          }];

      console.log('Importando XML único (ds_xml): chave:', cfg, chave, body, `${driver.inserirProc}`);

      await api.post(`/exec/${driver.inserirProc}`, body, cfg);

    } else {
      console.warn('Nenhum XML selecionado/definido para importar.');
      return;
    }

    // 3) limpar form e recarregar grid

    this.form.arquivos = [];
    this.form.ds_xml = '';

    // ajuste aqui para o método que você usa para listar as notas importadas
    if (typeof this.consultar === 'function') {
      await this.consultar();
    }


  } catch (e) {
    console.error('Erro ao importar XML(s):', e);
    if (this.$q?.notify) {
      this.$q.notify({ type: 'negative', position: 'center', message: 'Erro ao importar XML(s): ' + (e.message || e) });
    } else {
      alert('Erro ao importar XML(s): ' + (e.message || e));
    }
  } finally {
    this.importando = false;
  }
},



//
    setPeriodoPadrao() {
      if (!this.filtro.dt_inicial || !this.filtro.dt_final) {
        const { first, last } = currentMonthRange();
        if (!this.filtro.dt_inicial) this.filtro.dt_inicial = ddmmyyyy(first);
        if (!this.filtro.dt_final)   this.filtro.dt_final   = ddmmyyyy(last);
      }
    },

    //Processsar a Notas 
    async processarOld() {
      //
      if (!this.rows || !this.rows.length) {
        this.$q.notify({ type: 'warning', position: 'center', message: 'Nenhuma nota para processar.' })
        return
      }

    this.processingNotas = true

    const cfg = this.headerBanco
      ? { headers: { 'x-banco': this.headerBanco } }
      : undefined


       try {
      const cd_usuario =
        Number(localStorage.getItem("cd_usuario")) ||
        Number(this.usuario?.cd_usuario || 1)

      // loop das notas da grid
      for (const row of this.rows) {
        // tenta achar o código da nota de entrada na linha
        const cd_nota_entrada =
          row.cd_identificacao || 0
          ||
          null

        if (!cd_nota_entrada) {
          console.warn('Linha sem cd_nota_entrada válido:', row)
          continue
        }

        const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;

        const body = [{
          // se o seu backend usa isso como nos outros procs, mantém:
          ic_json_parametro: 'S',
          cd_parametro: 5,
          cd_nota_entrada: cd_nota_entrada,
          cd_operacao_fiscal: 0,
          cd_usuario: cd_usuario,
          cd_pedido_compra: 0,
          cd_item_pedido_compra: 0,
          cd_nota_nfe: row.cd_xml_nota || 0,
          cd_empresa_fat: row.cd_empresa_fat || null
        }]

        console.log('payload do processo --> ', body);

        // chamada ao exec da procedure
        await api.post('/exec/pr_egis_recebimento_processo_modulo', body, cfg)

      }

      this.$q.notify({ type: 'positive', 
      position: 'center',
      message: 'Notas processadas com sucesso.' })

    } catch (e) {
      console.error(e)
      this.$q.notify({
        type: 'negative',
        position: 'center',
        message: e?.message || 'Erro ao processar notas.'
      })
    } finally {
      this.processingNotas = false
    }
  
    },


    //Processsar a Notas 
    async processar() {
      const driver = this._tipoDriver(this.form.cd_tipo_xml);
      if (driver.disabled) {
        this.$q?.notify?.({ type: 'warning', position: 'center', message: 'Tipo ainda não implantado.' });
        return;
      }

      //
      if (!this.rows || !this.rows.length) {
        this.$q.notify({ type: 'warning', position: 'center', message: 'Nenhuma nota para processar.' })
        return
      }

    this.processingNotas = true

    const cfg = this.headerBanco
      ? { headers: { 'x-banco': this.headerBanco } }
      : undefined


       try {
      const cd_usuario =
        Number(localStorage.getItem("cd_usuario")) ||
        Number(this.usuario?.cd_usuario || 1)

      // loop das notas da grid
      for (const row of this.rows) {
        // tenta achar o código da nota de entrada na linha
        const idProcesso = driver.tipo === 'NFSE'
          ? (row.cd_nfse_xml || row.cd_identificacao || null)
          : (row.cd_identificacao || null)

        if (!idProcesso) {
          console.warn('Linha sem cd_nota_entrada válido:', row)
          continue
        }

        const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;

        const body = driver.tipo === 'NFSE'
          ? [{
              ic_json_parametro: 'S',
              cd_parametro: driver.processarParametro,
              cd_usuario: cd_usuario,
              dados_registro: JSON.stringify({ cd_nfse_xml: idProcesso })
            }]
          : [{
              // se o seu backend usa isso como nos outros procs, mantém:
              ic_json_parametro: 'S',
              cd_parametro: driver.processarParametro,
              cd_nota_entrada: idProcesso,
              cd_operacao_fiscal: 0,
              cd_usuario: cd_usuario,
              cd_pedido_compra: 0,
              cd_item_pedido_compra: 0,
              cd_nota_nfe: row.cd_xml_nota || 0,
              cd_empresa_fat: row.cd_empresa_fat || null
            }]

        console.log('payload do processo --> ', body);

        // chamada ao exec da procedure
        await api.post(`/exec/${driver.processarProc}`, body, cfg)

      }

      this.$q.notify({ type: 'positive', 
      position: 'center',
      message: 'Notas processadas com sucesso.' })

    } catch (e) {
      console.error(e)
      this.$q.notify({
        type: 'negative',
        position: 'center',
        message: e?.message || 'Erro ao processar notas.'
      })
    } finally {
      this.processingNotas = false
    }
  
    },

async consultar () {
  this.setPeriodoPadrao();
  this.loading = true;

  // escolhe o tipo a partir do filtro (ou do form como fallback)
  const driver = this._tipoDriver(this.filtro.cd_tipo_xml || this.form.cd_tipo_xml);

  if (driver.disabled) {
    this.loading = false;
    this.$q?.notify?.({ type: 'warning', position: 'center', message: 'Tipo ainda não implantado.' });
    return;
  }

  try {
    const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;

    const dtIni = parseDMY(this.filtro.dt_inicial);
    const dtFim = parseDMY(this.filtro.dt_final);

    // monta payload conforme o tipo
    // (mantive o formato OBJETO igual seu consultar original, porque no seu /exec isso funcionou)
    
    const body =
      (driver.tipo === 'NFSE' || driver.tipo === 'CTE')
        ? [{
            ic_json_parametro: 'S',
            cd_empresa: this.cd_empresa || null, // opcional, mas ajuda
            dt_inicial: dtIni ? yyyymmdd(dtIni) : null,
            dt_final: dtFim ? yyyymmdd(dtFim) : null,
          }]
        : {
            ic_json_parametro: 'N',
            cd_tipo_xml: this.filtro.cd_tipo_xml,
            dt_ini: dtIni ? yyyymmdd(dtIni) : null,
            dt_fim: dtFim ? yyyymmdd(dtFim) : null,
          };

    // chama a PR correta
    const resp = await api.post(`/exec/${driver.listarProc}`, body, cfg);

    const rows = this.resolveRows(resp && resp.data);
    this.rows = Array.isArray(rows) ? rows : [];

    console.log('Dados da consulta notas', body, rows);

    this.columns = this.inferirColunas(this.rows);

    try {
      // OBS: no seu código você usa cd_tabela e cdTabela (um com underscore e outro camel)
      // Mantive exatamente seu padrão, só ajuste se sua prop correta for cd_tabela mesmo.
      this.cd_tabela = 0;
      this.columns = await mapColumnsFromDB(this.cd_tabela, this.columns, { cd_parametro: 1, useCache: true });

      const nomes = this.columns.map(c => c.dataField).filter(Boolean);
      const probe = await fetchMapaAtributo(this.cdTabela, nomes, { cd_parametro: 1, useCache: false });
      console.table(nomes);
      console.log('Consultar() - byAtrib:', probe.byAtrib);

    } catch (e) {
      console.warn('Mapa atributo indisponível (segue rótulos padrões):', e);
    }

    this.$q.notify({ type: "positive", position: 'center', message: `${this.rows.length} registro(s).` });
    this.forceGridResize();

  } catch (e) {
    const r = e && e.response;
    const msg =
      (r && r.data && (r.data.Msg || r.data.message || r.data.error)) ||
      e.message ||
      "Erro ao consultar.";
    this.$q.notify({ type: "negative", position: 'center', message: msg });
  } finally {
    this.loading = false;
  }
},

    async consultarOld() {

      this.setPeriodoPadrao();

      this.loading = true;

      try {
        const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;

        const dtIni = parseDMY(this.filtro.dt_inicial);
        const dtFim = parseDMY(this.filtro.dt_final);

        const body = {
          cd_tipo_xml: this.filtro.cd_tipo_xml,
          dt_ini: dtIni ? yyyymmdd(dtIni) : null,
          dt_fim: dtFim ? yyyymmdd(dtFim) : null,
        };

        const resp = await api.post("/exec/pr_nota_xml_listar", body, cfg);

        const rows = this.resolveRows(resp && resp.data);
        this.rows = Array.isArray(rows) ? rows : [];
        
        //console.log('antes: ', this.colums);
        this.columns = this.inferirColunas(this.rows);
        //

        try {
         // cd_parametro: 2  (conforme sua necessidade)
         this.cd_tabela = 0;
         this.columns = await mapColumnsFromDB(this.cd_tabela, this.columns, { cd_parametro: 1, useCache: true })
         //console.log('RETORNO: ',this.columns);

         const nomes = this.columns.map(c => c.dataField).filter(Boolean);
         const probe = await fetchMapaAtributo(this.cdTabela, nomes, { cd_parametro: 1, useCache: false });
         console.table(nomes);
         console.log('byAtrib:', probe.byAtrib);

     
        } catch (e) {
          console.warn('Mapa atributo indisponível (segue rótulos padrões):', e)
        }


        this.$q.notify({ type: "positive", position: 'center', message: `${this.rows.length} registro(s).` });
        
        this.forceGridResize();

      } catch (e) {
        const r = e && e.response;
        const msg =
          (r && r.data && (r.data.Msg || r.data.message || r.data.error)) ||
          e.message ||
          "Erro ao consultar.";
        this.$q.notify({ type: "negative", position: 'center', message: msg });
      } finally {
        this.loading = false;
      }
    },



  },

  
  async mounted() {

    this.cd_empresa = localStorage.cd_empresa || 0;

    await this.consultar();
     this._onResize = () => this.forceGridResize();
     window.addEventListener('resize', this._onResize);
     setTimeout(() => this.forceGridResize(), 150);
  },
  beforeDestroy() {
    if (this._onResize) window.removeEventListener('resize', this._onResize);
  }
};
</script>

<style scoped>
.grid {
  width: 100%;
}  
.datagrid-wrap { width: 100%; }
.datagrid-wrap .dx-datagrid {  
   width: 100%; }
.datagrid-wrap .q-btn { min-width: 0; } /* deixa os botões mais compactos */
.toolbar-entrada {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 16px;
}

/* largura fixa pros selects */
.toolbar-entrada .te-tipo-xml,
.toolbar-entrada .te-filtro-tipo {
  width: 180px;
}

/* arquivo ocupa o máximo possível da linha */
.toolbar-entrada .te-arquivo {
  flex: 1 1 400px;
}

/* grupo de botões encostados um no outro */
.toolbar-entrada .te-botoes {
  white-space: nowrap;
}

.toolbar-entrada .te-botoes .q-btn {
  min-width: 130px;
}

/* RESPONSIVO: em telas menores, quebra para coluna */
@media (max-width: 960px) {
  .toolbar-entrada {
    flex-direction: column;
    align-items: stretch;
  }

  .toolbar-entrada .te-tipo-xml,
  .toolbar-entrada .te-filtro-tipo,
  .toolbar-entrada .te-arquivo,
  .toolbar-entrada .te-botoes {
    width: 100%;
  }

  .toolbar-entrada .te-botoes {
    white-space: normal;
  }

  .toolbar-entrada .te-botoes .q-btn {
    width: 100%;
    margin-bottom: 6px;
  }
}
.topbar {
  padding: 10px;
  display: flex;
  align-items: center;
  width: 100%;
}

.nfse-paper { max-width: 980px; margin: 0 auto; }
.nfse-box { border: 1px solid #ddd; padding: 8px; min-height: 90px; white-space: pre-wrap; }
@media print {
  .q-dialog__backdrop, .q-bar, .q-btn { display: none !important; }
}

.cte-paper {
  max-width: 980px;
  margin: 0 auto;
}

@media print {
  /* some toolbars/buttons */
  .q-dialog__backdrop,
  .q-bar,
  .q-btn {
    display: none !important;
  }

  /* tenta garantir fundo branco */
  body {
    background: #fff !important;
  }
}

</style>
