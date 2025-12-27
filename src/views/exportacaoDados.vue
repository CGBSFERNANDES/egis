<template>
  <div>
    <div class="q-pa-md column">
      <!-- Linha de filtros principais -->
      <div class="row q-gutter-sm items-end">
        <!-- Modelo -->
        <div class="col-12 col-md-4">
          <q-select
            v-model="filtro.cd_modelo"
            :options="opcoesModelos"
            option-value="cd_modelo"
            :option-label="optLabel"
            emit-value
            map-options
            dense
            outlined
            clearable
            label="Modelo de Exportação"
            :popup-content-style="{ maxHeight: '50vh' }"
            @input="onModeloChange"
          >
            <template v-slot:option="scope">
              <q-item v-bind="scope.itemProps" v-on="scope.itemEvents">
                <q-item-section>
                  <q-item-label>{{ scope.opt.nm_modelo }}</q-item-label>
                  <q-item-label caption>
                    <span v-if="scope.opt.ic_admin_tabela === 'S'">
                      · admin</span
                    >
                  </q-item-label>
                </q-item-section>
              </q-item>
            </template>

            <!-- Como o item selecionado aparece no campo -->
            <template v-slot:selected-item="scope">
              <q-chip dense square>
                {{ scope.opt.nm_modelo }}
                <span v-if="scope.opt.ic_admin_tabela === 'S'"> (admin)</span>
              </q-chip>
            </template>
          </q-select>
        </div>

        <!-- Tipo de saída (preenchido pelo modelo; pode editar se quiser) -->
        <div class="col-12 col-md-2">
          <q-select
            v-model="filtro.ic_tipo_saida"
            :options="opcoesTipoSaida"
            emit-value
            map-options
            dense
            outlined
            label="Tipo de Saída"
          />
        </div>

        <!-- Datas (usadas em modelos padrão; em admin nem sempre se aplicam) -->
        <div class="col-12 col-md-2">
          <q-input
            v-model="filtro.dt_inicial"
            mask="##/##/####"
            dense
            outlined
            fill-mask
            autocomplete="off"
            label="Data Inicial"            
          >
          <template v-slot:append>
    <q-icon name="event" class="cursor-pointer">
      <q-popup-proxy cover transition-show="scale" transition-hide="scale">
        <q-date
          v-model="filtro.dt_inicial"
          mask="DD/MM/YYYY"
          :locale="localePtBr"
          today-btn
        />
      </q-popup-proxy>
    </q-icon>
  </template>
          </q-input>
        </div>
        <div class="col-12 col-md-2">
          <q-input
            v-model="filtro.dt_final"
            mask="##/##/####"
            dense
            outlined
            label="Data Final"
            fill-mask
            autocomplete="off"
          >
           <template v-slot:append>
    <q-icon name="event" class="cursor-pointer">
      <q-popup-proxy cover transition-show="scale" transition-hide="scale">
        <q-date
          v-model="filtro.dt_final"
          mask="DD/MM/YYYY"
          :locale="localePtBr"
          today-btn
        />
      </q-popup-proxy>
    </q-icon>
  </template>
          </q-input>
        </div>

        <div class="col-12 col-md-2 q-gutter-xs">
          <q-btn
            color="primary"
            icon="search"
            label="Consultar"
            @click="consultar"
            :loading="loading"
          />
          <q-btn
            flat
            icon="download"
            label="Exportar"
            @click="exportarTipoSelecionado"
            :disable="rows.length === 0"
          />
        </div>

        <!-- Banner de modo admin -->
        <q-banner
          v-if="adminMode"
          class="q-mt-md bg-blue-1 text-blue-9"
          rounded
        >
          <div class="row items-center q-gutter-sm">
            <div class="col-grow">
              Modo <b>Admin de Tabelas</b>: primeiro escolha a tabela/view que
              deseja exportar.
            </div>
            <div class="col-auto">
              <q-chip
                square
                color="blue-3"
                text-color="blue-10"
                icon="table_chart"
                label="Modelo exige escolha de tabela"
              />
            </div>
          </div>
        </q-banner>

        <!-- Filtro de tabela + ações (só no modo admin) -->
        <div class="row q-gutter-sm q-mt-md" v-if="adminMode">
          <div class="col-12 col-md-4">
            <q-input
              v-model="filtro.q"
              dense
              outlined
              clearable
              label="Filtrar por nome da tabela/view (q)"
              @keyup.enter="listarTabelas"
            />
          </div>
          <div class="col-12 col-md-3">
            <q-btn
              icon="search"
              color="secondary"
              label="Listar Tabelas"
              @click="listarTabelas"
            />
            <q-btn
              class="q-ml-sm"
              flat
              icon="refresh"
              label="Limpar seleção"
              @click="limparTabela"
            />
          </div>
          <div class="col-12 col-md-5">
            <q-input
              v-model="filtro.nm_tabela"
              dense
              outlined
              readonly
              label="Tabela escolhida"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Grids de dados -->

    <div class="row q-pa-md">
      <!-- Grids de dados -->
      <div class="q-mt-md" v-show="columns.length">
        <q-card flat bordered class="grid-card">
          <q-card-section class="q-pa-none">
            <DxDataGrid
              :data-source="rows"
              :show-borders="true"
              :column-auto-width="true"
              :row-alternation-enabled="true"
              height="calc(100vh - 220px)"
              ref="grid"
            >
              <DxFilterRow :visible="true" />
              <DxHeaderFilter :visible="true" />
              <DxGroupPanel :visible="true" />
              <DxGrouping :auto-expand-all="false" />
              <DxSearchPanel
                :visible="true"
                :width="300"
                placeholder="Procurar..."
              />
              <DxExport :enabled="false" />
              <DxSummary>
                <DxTotalItem
                  column="_count"
                  summary-type="count"
                  display-format="{0} registro(s)"
                />
              </DxSummary>
              <DxColumn
                v-for="c in columns"
                :key="c.dataField"
                :data-field="c.dataField"
                :caption="c.caption"
                :data-type="c.dataType"
                :format="c.format"
              />
            </DxDataGrid>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <div class="q-mt-md">
      <div v-if="adminMode && !filtro.nm_tabela">
        <q-card flat bordered class="grid-card">
          <q-card-section class="q-pa-none">
            <DxDataGrid
              :data-source="adminTablesRows"
              :show-borders="true"
              :column-auto-width="true"
              height="420px"
              key-expr="nm_tabela"
              @row-dbl-click="onTabelaDblClick"
              @row-click="onTabelaClick"
            >
              <DxSelection mode="single" />
              <DxFilterRow :visible="true" />
              <DxHeaderFilter :visible="true" />
              <DxSearchPanel
                :visible="true"
                :width="300"
                placeholder="Procurar..."
              />
              <DxColumn data-field="cd_tabela" caption="Código" />
              <DxColumn data-field="nm_tabela" caption="Tabela" />
              <DxColumn data-field="ds_tabela" caption="Descritivo" />
            </DxDataGrid>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </div>
</template>

<script>
//
import api from "@/boot/axios";
//

import { saveAs } from "file-saver";
import ExcelJS from "exceljs";
import {
  DxDataGrid,
  DxColumn,
  DxFilterRow,
  DxHeaderFilter,
  DxGroupPanel,
  DxGrouping,
  DxSearchPanel,
  DxSummary,
  DxTotalItem,
  DxSelection,
  DxExport,
} from "devextreme-vue/data-grid";


// utils de data (no <script> do exportacaoDados.vue)
const pad2 = n => (n < 10 ? '0' + n : '' + n)

// retorna "DD/MM/YYYY"
function ddmmyyyy(d) {
  return `${pad2(d.getDate())}/${pad2(d.getMonth() + 1)}/${d.getFullYear()}`
}
// converte "DD/MM/YYYY" -> "MM/DD/YYYY" (para API/SQL)
function toApiDate(br) {
  if (!br) return ''
  const [dd, mm, yyyy] = br.split('/')
  return `${mm}/${dd}/${yyyy}`
 //return fmt === 'YMD' ? `${yyyy}-${mm}-${dd}` : `${mm}/${dd}/${yyyy}`
}
// mês atual (primeiro e último dia)
function currentMonthRange() {
  const now = new Date()
  const first = new Date(now.getFullYear(), now.getMonth(), 1)
  const last  = new Date(now.getFullYear(), now.getMonth() + 1, 0)
  return { first, last }
}

// Quasar QDate espera "locale" = objeto:
const localePtBr = {
  days:       'Domingo_Segunda_Terça_Quarta_Quinta_Sexta_Sábado'.split('_'),
  daysShort:  'Dom_Seg_Ter_Qua_Qui_Sex_Sáb'.split('_'),
  months:     'Janeiro_Fevereiro_Março_Abril_Maio_Junho_Julho_Agosto_Setembro_Outubro_Novembro_Dezembro'.split('_'),
  monthsShort:'Jan_Fev_Mar_Abr_Mai_Jun_Jul_Ago_Set_Out_Nov_Dez'.split('_'),
  firstDayOfWeek: 1
}

export default {
  name: "ViewExportacaoDados",
  components: {
    DxDataGrid,
    DxColumn,
    DxFilterRow,
    DxHeaderFilter,
    DxGroupPanel,
    DxGrouping,
    DxSearchPanel,
    DxSummary,
    DxTotalItem,
    DxSelection,
    DxExport,
  },
  data() {
    const { first, last } = currentMonthRange()
    return {
      loading: false,
      localePtBr,
      gridHeight: "65vh", // altura estável: a grid para de “sumir”
      filtro: {
        cd_modelo: null,
        ic_tipo_saida: "EXCEL",
        dt_inicial: ddmmyyyy(first), // exibe DD/MM/YYYY,
        dt_final: ddmmyyyy(last),  // exibe DD/MM/YYYY,
        q: "", // filtro de nome de tabela (modo admin)
        nm_tabela: "", // tabela/view escolhida (modo admin)
      },
      opcoesModelos: [], // { cd_modelo, nm_modelo, ic_tipo_saida, ic_admin_tabela }
      opcoesTipoSaida: [
        { label: "EXCEL", value: "EXCEL" },
        { label: "JSON", value: "JSON" },
        { label: "JSON-E", value: "JE" },
        { label: "CSV", value: "CSV" },
        { label: "TXT", value: "TXT" },
        { label: "XML", value: "XML" },
        { label: "OFX", value: "OFX" },
      ],
      modeloSelecionado: 'N',
      // grid de dados
      rows: [],
      columns: [],
      // grid de tabelas (modo admin)
      adminTablesRows: [],
      linhaTabelaSelecionada: null,
    };
  },
  computed: {
    adminMode() {
      const id =
        typeof this.filtro.cd_modelo === "string"
          ? parseInt(this.filtro.cd_modelo, 10)
          : this.filtro.cd_modelo;
      const m = this.opcoesModelos.find(
        (o) => Number(o.cd_modelo) === Number(id)
      );
      return m && m.ic_admin_tabela === "S";
    },
  },
  created() {
    const { first, last } = currentMonthRange()
    this.filtro.dt_inicial = ddmmyyyy(first)
    this.filtro.dt_final   = ddmmyyyy(last)
  },

  mounted() {
    this.forceGridResize();
    window.addEventListener("resize", this.forceGridResize);
    this.carregarModelos();
    //
  },
  watch: {
    "filtro.cd_modelo"(novo) {
      this.onModeloChange(novo);
    },
  },
  methods: {
    toApiDate, 
    setPeriodo(){
        // se estiverem vazias, repõe mês vigente
    if (!this.filtro.dt_inicial || !this.filtro.dt_final) {
      const { first, last } = currentMonthRange()
      if (!this.filtro.dt_inicial) this.filtro.dt_inicial = ddmmyyyy(first)
      if (!this.filtro.dt_final)   this.filtro.dt_final   = ddmmyyyy(last)
    }
    },
    forceGridResize() {
      this.$nextTick(() => {
        try {
          if (this.$refs.gridDados && this.$refs.gridDados.instance) {
            this.$refs.gridDados.instance.updateDimensions();
          }
        } catch (e) {
          /* ignora */
        }
      });
    },

    notify(type, message) {
      this.$q.notify({
        type,
        message,
        position: "top-right",
        timeout: 4000,
        progress: true,
      });
    },

    // quando selecionar o modelo no QSelect
    async onModeloChange(val) {
      // normaliza para número quando possível
      const id = typeof val === "string" ? parseInt(val, 10) : val;
      this.filtro.cd_modelo = id;

      // limpa estados
      this.rows = [];
      this.columns = [];
      this.filtro.nm_tabela = "";
      this.linhaTabelaSelecionada = null;

      // pega o modelo para ajustar ic_tipo_saida
      const m = this.opcoesModelos.find(
        (o) => Number(o.cd_modelo) === Number(id)
      );
      //

      if (m) this.filtro.ic_tipo_saida = m.ic_tipo_saida || "";

      console.log('dados change: ', m, m.ic_tipo_saida, this.filtro.ic_tipo_saida);

      // se for admin, lista tabeas primeiro; senão, já consulta os dados

      if (this.adminMode) {
        await this.listarTabelas();
      } else {
        await this.consultar();
      }
    },

    optLabel(opt) {
      if (!opt) return "";
      return (
        (opt.nm_modelo || "") + (opt.ic_admin_tabela === "S" ? " (admin)" : "")
      );
    },

    // rótulo do modelo no QSelect,
    labelModelo(opt) {
      const flag = opt && opt.ic_admin_tabela === "S" ? " (admin)" : "";
      return (opt && opt.nm_modelo ? opt.nm_modelo : "") + flag;
    },

    resolveRows(data) {
      if (Array.isArray(data)) return data;
      if (data && data.recordset) return data.recordset;
      if (data && data.rows) return data.rows;
      if (data && data.data) return data.data;
      return [];
    },

    async carregarModelos() {
      try {
        const body = [{ ic_json_parametro: "S", cd_parametro: 0 }];
        const resp = await api.post("/exec/pr_egis_exportacao_dados", body);
        const rows = this.resolveRows(resp && resp.data);
        
        //console.log('dados',resp, rows);

        // esperamos: cd_modelo, nm_modelo, ic_tipo_saida, nm_view, json_meta, ic_admin_tabela
        this.opcoesModelos = rows.map((r) => ({
          cd_modelo: r.cd_modelo,
          nm_modelo: r.nm_modelo,
          ic_tipo_saida: r.ic_tipo_saida || "EXCEL",
          ic_admin_tabela: r.ic_admin_tabela === "S" ? "S" : "N",
        }));
      } catch (e) {
        const r = e && e.response;
        const msg =
          (r && r.data && (r.data.Msg || r.data.message)) ||
          e.message ||
          "Falha ao carregar modelos";
        // this.$q.notify({ type: 'negative', message: msg })
        this.notify("negative", msg);
      }
    },

    async onModeloChange(cd) {
      // zera estado
      this.rows = [];
      this.columns = [];
      this.filtro.nm_tabela = "";
      this.linhaTabelaSelecionada = null;

      const m = this.opcoesModelos.find((o) => o.cd_modelo === cd);
      if (m) {
        this.filtro.ic_tipo_saida = m.ic_tipo_saida || "EXCEL";
      }
      if (this.adminMode) {
        // carrega a lista de tabelas já de cara
        await this.listarTabelas();
      } else {
        // consulta normal
        await this.consultar();
      }
    },
    async listarTabelas() {
      try {
        const body = [
          {
            ic_json_parametro: "S",
            cd_parametro: 500,
            q: this.filtro.q || null,
          },
        ];
        const resp = await api.post("/exec/pr_egis_exportacao_dados", body);
        this.adminTablesRows = this.resolveRows(resp && resp.data);
        if (!this.adminTablesRows.length) {
          this.$q.notify({
            type: "warning",
            message: "Nenhuma tabela/view encontrada.",
          });
        }
      } catch (e) {
        const r = e && e.response;
        const msg =
          (r && r.data && (r.data.Msg || r.data.message)) ||
          e.message ||
          "Falha ao listar tabelas";
        // this.$q.notify({ type: 'negative', message: msg })
        this.notify("negative", msg);
      }
    },
    onTabelaClick(e) {
      this.linhaTabelaSelecionada = e && e.data ? e.data : null;
    },
    onTabelaDblClick(e) {
      if (e && e.data && e.data.nm_tabela) {
        this.linhaTabelaSelecionada = e.data;
        this.confirmarTabela();
      }
    },
    confirmarTabela() {
      const row = this.linhaTabelaSelecionada;
      if (!row || !row.nm_tabela) {
        this.$q.notify({ type: "warning", message: "Selecione uma tabela." });
        return;
      }
      this.filtro.nm_tabela = row.nm_tabela.replace(/\[|\]/g, ""); // opcional
      this.$q.notify({
        type: "positive",
        message: `Tabela selecionada: ${this.filtro.nm_tabela}`,
      });
      // após selecionar, já consulta os dados
      this.consultar();
      //
      
    },
    limparTabela() {
      this.filtro.nm_tabela = "";
      this.linhaTabelaSelecionada = null;
      this.rows = [];
      this.columns = [];
    },
    async consultar() {
      if (!this.filtro.cd_modelo) {
        this.$q.notify({ type: "warning", message: "Selecione um modelo." });
        return;
      }
      if (this.adminMode && !this.filtro.nm_tabela) {
        this.$q.notify({
          type: "warning",
          message: "Escolha uma tabela antes de consultar.",
        });
        return;
      }

      this.setPeriodo();

      this.loading = true;

      try {
        const payload = [
          {
            ic_json_parametro: "S",
            cd_parametro: 1, // dados para grid
            cd_modelo: this.filtro.cd_modelo,
           // dt_inicial: this.filtro.dt_inicial || null,
           // dt_final: this.filtro.dt_final || null,
            dt_inicial: toApiDate(this.filtro.dt_inicial), // MM/DD/YYYY
            dt_final:   toApiDate(this.filtro.dt_final)    // MM/DD/YYYY
          },
        ];

        if (this.adminMode) payload[0].nm_tabela = this.filtro.nm_tabela;

        console.log('payload ->',payload);
        
        const resp = await api.post(
          "/exec/pr_egis_exportacao_dados",
          payload
        );
        const rows = this.resolveRows(resp && resp.data);
        this.rows = Array.isArray(rows) ? rows : [];
        this.columns = this.inferirColunas(this.rows);
        this.$q.notify({
          type: "positive",
          message: `${this.rows.length} registro(s).`,
        });
        this.forceGridResize();
      } catch (e) {
        const r = e && e.response;
        const msg =
          (r && r.data && (r.data.Msg || r.data.message)) ||
          e.message ||
          "Erro na consulta";
        this.$q.notify({ type: "negative", message: msg });
      } finally {
        this.loading = false;
      }
    },
    inferirColunas(linhas) {
      if (!linhas || !linhas.length) return [];
      const sample = linhas[0];
      return Object.keys(sample).map((k) => ({
        dataField: k,
        caption: this.titulo(k),
        dataType: this.tipo(sample[k]),
        format: this.formato(sample[k]),
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
      if (typeof v === "string" && /^\d{4}-\d{2}-\d{2}/.test(v)) return "date";
      return "string";
    },
    formato(v) {
      return typeof v === "number"
        ? { type: "fixedPoint", precision: 2 }
        : undefined;
    },

    async exportarTipoSelecionado() {
      // mantém exportação client-side rápida para qualquer grid (Excel, CSV, etc.)
      // se quiser exportar pelo modelo (cd_parametro=10), dá pra ligar aqui também.
      if (this.filtro.ic_tipo_saida === "EXCEL") return this.exportarExcel();
      if (this.filtro.ic_tipo_saida === "CSV") return this.exportarCSV();
      if (this.filtro.ic_tipo_saida === "TXT") return this.exportarTXT();
      if (this.filtro.ic_tipo_saida === "JSON") return this.exportarJSON();
      if (this.filtro.ic_tipo_saida === "JE") return this.exportarJSONEspecial();
      if (this.filtro.ic_tipo_saida === "XML") return this.exportarXML();
      if (this.filtro.ic_tipo_saida === "OFX") return this.exportarOFX();

      this.$q.notify({
        type: "info",
        message: "Tipo de saída não suportado aqui.",
      });
    },

    async exportarExcel() {
      if (!this.rows.length) return;
      const wb = new ExcelJS.Workbook();
      const ws = wb.addWorksheet("Dados");
      const headers = this.columns.map((c) => c.caption || c.dataField);
      ws.addRow(headers);
      for (let i = 0; i < this.rows.length; i++) {
        const r = this.rows[i];
        ws.addRow(this.columns.map((c) => r[c.dataField]));
      }
      const buf = await wb.xlsx.writeBuffer();
      saveAs(new Blob([buf]), `exportacao_${this.filtro.cd_modelo}.xlsx`);
    },
    exportarCSV() {
      if (!this.rows.length) return;
      const sep = ";";
      const head = this.columns
        .map((c) => '"' + (c.caption || c.dataField) + '"')
        .join(sep);
      const rows = this.rows.map((r) =>
        this.columns
          .map((c) => {
            const v = r[c.dataField];
            const s = (v == null ? "" : String(v)).replace(/"/g, '""');
            return '"' + s + '"';
          })
          .join(sep)
      );
      const blob = new Blob([head + "\n" + rows.join("\n")], {
        type: "text/csv;charset=utf-8",
      });
      saveAs(blob, `exportacao_${this.filtro.cd_modelo}.csv`);
    },
    exportarTXT() {
      if (!this.rows.length) return;
      const sep = "\t";
      const head = this.columns.map((c) => c.caption || c.dataField).join(sep);
      const rows = this.rows.map((r) =>
        this.columns.map((c) => r[c.dataField]).join(sep)
      );
      const blob = new Blob([head + "\n" + rows.join("\n")], {
        type: "text/plain;charset=utf-8",
      });
      saveAs(blob, `exportacao_${this.filtro.cd_modelo}.txt`);
    },

    exportarJSON() {
      if (!this.rows.length) return;
      const blob = new Blob([JSON.stringify(this.rows, null, 2)], {
        type: "application/json;charset=utf-8",
      });
      saveAs(blob, `exportacao_${this.filtro.cd_modelo}.json`);
    },

    async exportarJSONEspecial() {
     //
      try {
      // 1) Se não tem linhas e não é exportação pela proc, sai
      /*
      const isJsonDoModelo = this.modeloSelecionado && String(this.modeloSelecionado.ic_exportacao_json).toUpperCase() === 'S'

      if (!isJsonDoModelo) {
        // fallback antigo: baixa o que está na grid
        if (!this.rows || !this.rows.length) return
        const blob = new Blob([JSON.stringify(this.rows, null, 2)], {
          type: 'application/json;charset=utf-8'
        })
        saveAs(blob, `exportacao_${this.filtro.cd_modelo}.json`)
        return
      }
      */

      this.setPeriodo();

      // 2) Quando ic_exportacao_json = 'S': busca JSON direto da procedure (parametro 20)
      this.loading = true

      // garanta datas em formato ISO (YYYY-MM-DD) se precisar
      const toISO = d => (d ? new Date(d).toISOString().slice(0, 10) : null)

      const payload = [{
        cd_parametro: 20,                 // <- retorna o JSON montado no SQL
        cd_modelo: this.filtro.cd_modelo, // modelo atual
        dt_inicial: toApiDate(this.dt_inicial),
        dt_final: toApiDate(this.dt_final),
       // dt_inicial: toISO(this.filtro.dt_inicial),
       // dt_final:   toISO(this.filtro.dt_final),
        // opcional: nm_objeto se você estiver filtrando por bloco/objeto
        nm_objeto: this.filtro.nm_objeto || '',
        ic_json_parametro: 'S'
      }];

       //
      console.log('payload 20 = ',payload);
      //

      // ajuste a URL do seu backend
      const resp = await api.post('/exec/pr_egis_exportacao_dados', payload);
     

      let jsonText

      // 3) Normaliza o retorno (pode vir string crua, {json_out}, ou [ { json_out } ])
      if (typeof resp.data === 'string') {
        // pode ser a string JSON ou uma string contendo JSON stringificado
        // tenta detectar { ... } já pronto
        jsonText = resp.data.trim()
      } else if (resp.data && typeof resp.data === 'object') {
        if (resp.data.json_out) {
          jsonText = resp.data.json_out
        } else if (Array.isArray(resp.data) && resp.data.length && resp.data[0].json_out) {
          jsonText = resp.data[0].json_out
        } else {
          // fallback: stringify do objeto recebido
          jsonText = JSON.stringify(resp.data)
        }
      } else {
        // fallback genérico
        jsonText = JSON.stringify(resp.data)
      }

      // 4) Download
      const blob = new Blob([jsonText], { type: 'application/json;charset=utf-8' })
      saveAs(blob, `exportacao_${this.filtro.cd_modelo}.json`)
    } catch (err) {
      console.error('Erro ao exportar JSON do modelo:', err)
      this.$toast && this.$toast.error('Falha ao exportar JSON do modelo.')
    } finally {
      this.loading = false
    }
  
    },


    exportarXML() {
      if (!this.rows.length) return;
      const esc = (s) =>
        String(s)
          .replace(/&/g, "&amp;")
          .replace(/</g, "&lt;")
          .replace(/>/g, "&gt;")
          .replace(/"/g, "&quot;")
          .replace(/'/g, "&apos;");
      const cols = this.columns.map((c) => c.dataField);
      const items = this.rows
        .map(
          (r) =>
            `  <item>\n${cols
              .map((f) => `    <${f}>${esc(r[f] == null ? "" : r[f])}</${f}>`)
              .join("\n")}\n  </item>`
        )
        .join("\n");
      const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<rows>\n${items}\n</rows>`;
      const blob = new Blob([xml], { type: "application/xml;charset=utf-8" });
      saveAs(blob, `exportacao_${this.filtro.cd_modelo}.xml`);
    },
    exportarOFX() {
      if (!this.rows.length) return;
      // gerador simples (mesma versão que já te passei)
      const dateCol = this.columns.find((c) =>
        /data|dt|emissao|mov/i.test(c.dataField)
      );
      const valCol = this.columns.find((c) =>
        /valor|vl|amount|preco/i.test(c.dataField)
      );
      const idCol = this.columns.find((c) =>
        /id|doc|documento|numero/i.test(c.dataField)
      );
      const memoCol = this.columns.find((c) =>
        /histor|memo|desc|descricao|obs/i.test(c.dataField)
      );
      if (!dateCol || !valCol) {
        this.$q.notify({
          type: "warning",
          message: "Não foi possível mapear campos para OFX automaticamente.",
        });
        return;
      }
      const fmt = (s) => {
        const d = typeof s === "string" ? new Date(s) : s;
        const y = d.getFullYear();
        const m = String(d.getMonth() + 1).padStart(2, "0");
        const da = String(d.getDate()).padStart(2, "0");
        return `${y}${m}${da}000000`;
      };
      const header = [
        "OFXHEADER:100",
        "DATA:OFXSGML",
        "VERSION:103",
        "SECURITY:NONE",
        "ENCODING:USASCII",
        "CHARSET:1252",
        "COMPRESSION:NONE",
        "OLDFILEUID:NONE",
        "NEWFILEUID:NONE",
        "",
      ].join("\n");
      const today = fmt(new Date());
      const txns = this.rows
        .map((r, i) =>
          [
            "<STMTTRN>",
            `<TRNTYPE>OTHER`,
            `<DTPOSTED>${fmt(r[dateCol.dataField])}`,
            `<TRNAMT>${String(r[valCol.dataField]).replace(",", ".")}`,
            `<FITID>${idCol ? r[idCol.dataField] : i + 1}`,
            `<NAME>${memoCol ? r[memoCol.dataField] : "Movimento"}`,
            "</STMTTRN>",
          ].join("\n")
        )
        .join("\n");
      const body = `\n<OFX>\n  <BANKMSGSRSV1>\n    <STMTTRNRS>\n      <STMTRS>\n        <BANKTRANLIST>\n          <DTSTART>${today}\n          <DTEND>${today}\n${txns}\n        </BANKTRANLIST>\n      </STMTRS>\n    </STMTTRNRS>\n  </BANKMSGSRSV1>\n</OFX>`;
      const blob = new Blob([header + "\n" + body], {
        type: "application/x-ofx",
      });
      saveAs(blob, `exportacao_${this.filtro.cd_modelo}.ofx`);
    },
    onDataSelection() {}, // reservado
  },
};
</script>

<style scoped>
/* mantém os filtros em cima e a grid logo abaixo */
.filters-row {
  flex: 0 0 auto;
}

.grid-card {
  margin-top: 100px;
  padding-top: 1px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

/* garante que menus/popups fiquem sobre a grid */
:deep(.q-menu) {
  z-index: 2000;
}
</style>
