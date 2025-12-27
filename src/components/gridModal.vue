<template>
  <div v-if="show" class="modal-mask">
    <div class="modal-wrapper" style="max-width:96%">
      <div class="modal-container" style="padding:10px 14px">
        <div class="modal-header">
          <h3>Resultado — {{ procedure }}</h3>
          <button class="btn secondary" @click="$emit('update:show', false)">Fechar</button>
        </div>

        <div class="modal-body">
          <div v-if="loading">Carregando…</div>
          <DxDataGrid v-else
            :data-source="rows"
            :show-borders="true"
            :column-auto-width="true"
            :height="600"
          >
            <DxSearchPanel :visible="true" />
            <DxPaging :page-size="20" />
            <DxPager :show-page-size-selector="true" :allowed-page-sizes="[10,20,50]" :show-info="true" />
            <DxColumn v-for="c in dxColumns" :key="c.dataField"
              :data-field="c.dataField" :caption="c.caption" :visible="c.visible"
              :width="c.width" :format="c.format" :alignment="c.alignment" />
            <DxSummary>
              <DxTotalItem v-for="s in summaryItems" :key="s.column + s.summaryType"
                :column="s.column" :summary-type="s.summaryType"
                :show-in-column="s.showInColumn" :display-format="s.displayFormat" />
            </DxSummary>
          </DxDataGrid>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import { DxDataGrid, DxColumn, DxSearchPanel, DxPager, DxPaging, DxSummary, DxTotalItem } from 'devextreme-vue/data-grid';

export default {
  name: 'GridModal',
  components: { DxDataGrid, DxColumn, DxSearchPanel, DxPager, DxPaging, DxSummary, DxTotalItem },
  props: {
    show: { type: Boolean, default: false },
    procedure: { type: String, required: true },
    form: { type: Object, default: () => ({}) },
    apiBase: { type: String, required: true }    // '/api/meta-dados'
  },
  data(){ return { cols: [], rows: [], loading: false }; },
  computed:{
    http(){ return axios.create({ baseURL: this.apiBase.replace(/\/$/, '') }); },
    dxColumns(){
      return (this.cols||[]).map(c=>{
        const precisa = ['fixedPoint','currency','percent'].includes(c.formato_coluna);
        const item = {
          dataField: c.dataField || c.nome_coluna,
          caption: c.caption || c.titulo_exibicao || c.dataField || c.nome_coluna,
          width: c.width || c.largura ? parseInt(c.width || c.largura) : undefined,
          visible: c.visivel===1 || c.visivel===true || c.visivel==='1' || c.visivel==null,
          ordem: parseInt(c.qt_ordem_coluna) || 999
        };
        if (c.formato_coluna) {
          item.format = c.formato_coluna==='shortDate'
            ? 'dd/MM/yyyy'
            : { type: c.formato_coluna, precision: precisa ? 2 : undefined };
          item.alignment = precisa ? 'right' : 'left';
        }
        return item;
      }).sort((a,b)=>a.ordem-b.ordem);
    },
    summaryItems(){
      return (this.cols||[])
        .filter(c => c.soma || c.contagem)
        .map(c => ({
          column: c.dataField || c.nome_coluna,
          summaryType: c.soma ? 'sum' : 'count',
          showInColumn: c.dataField || c.nome_coluna,
          displayFormat: c.soma ? undefined : '{0} registros'
        }));
    }
  },
  watch:{
    show(v){ if(v) this.load(); }
  },
  methods:{
    async load(){
      this.loading = true;
      try{
        const colRes = await this.http.get(`/colunas/${this.procedure}`);
        const cols = Array.isArray(colRes.data) ? colRes.data : [];

        const execRes = await this.http.post(`/exec/${this.procedure}`, this.form || {});
        const dados = Array.isArray(execRes.data) ? execRes.data : [];

        // normaliza shortDate
        cols.filter(c=>c.formato_coluna==='shortDate').forEach(c=>{
          dados.forEach(r=>{
            const f = c.dataField || c.nome_coluna;
            if(r[f]) r[f] = new Date(r[f]);
          });
        });

        this.cols = cols;
        this.rows = dados;
      } finally { this.loading = false; }
    }
  }
};
</script>

<style>
.modal-mask{position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.35);display:flex;align-items:center;justify-content:center}
.modal-wrapper{width:92%;max-width:1200px}
.modal-container{background:#fff;border-radius:6px;box-shadow:0 2px 8px rgba(0,0,0,.33);overflow:hidden}
.modal-header,.modal-footer{padding:10px 14px}
.modal-header{display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #eee}
.modal-body{max-height:80vh;overflow:auto;padding:10px 14px}
.btn{background:#fd7e14;color:#fff;border:none;padding:8px 14px;font-weight:600;border-radius:4px;cursor:pointer}
.btn.secondary{background:#6c757d}
</style>
