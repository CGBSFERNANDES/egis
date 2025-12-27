<template>
  <div v-if="show" class="modal-mask">
    <div class="modal-wrapper">
      <div class="modal-container">
        <div class="modal-header">
          <h2>Parâmetros — {{ procedure }}</h2>
          <button class="btn secondary" @click="$emit('update:show', false)">Fechar</button>
        </div>

        <div class="modal-toolbar">
          <input v-model="filter" class="inp" placeholder="filtrar por nome/título..." />
          <button class="btn" :disabled="loading" @click="sync">Sincronizar Parâmetros</button>
        </div>

        <div class="modal-body">
          <div v-if="loading">Carregando…</div>
          <table v-else class="tb">
            <thead>
              <tr>
                <th>Nome</th><th>Tipo</th><th style="width:220px">Valor Padrão</th>
                <th>Obrig.</th><th>Editável</th><th style="width:260px">Título</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in filtered" :key="p.id">
                <td>{{ p.nome_parametro }}</td>
                <td>{{ p.tipo_parametro }}</td>
                <td><input class="inp" v-model="p.valor_padrao"></td>
                <td class="c"><input type="checkbox" v-model="p.obrigatorio" :true-value="1" :false-value="0"></td>
                <td class="c"><input type="checkbox" v-model="p.editavel" :true-value="1" :false-value="0"></td>
                <td><input class="inp" v-model="p.titulo_parametro"></td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="modal-footer">
          <button class="btn" :disabled="saving" @click="save">
            {{ saving ? 'Salvando…' : 'Salvar Alterações' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

// client único para /api/meta-dados  (SEM barra inicial nas chamadas)
const api = axios.create({
  baseURL: (axios.defaults.baseURL || '').replace(/\/$/, '') + '/meta-dados'
});

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


function toDateInput(v) {
  if (!v) return '';
  const d = new Date(v);
  if (isNaN(d)) return '';
  return d.toISOString().slice(0, 10); // yyyy-mm-dd
}

function normalizeParamValue(p) {
  const tipo = String(p.tipo_parametro || '').toLowerCase();
  const val  = p.valor_padrao;

  if (['date','datetime','smalldatetime','date_time'].includes(tipo)) {
    return toDateInput(val);
  }
  if (['bit','boolean','bool'].includes(tipo)) {
    return (val === 1 || val === '1' || val === true) ? 1 : 0;
  }
  if (val == null) return '';
  return val;
}


export default {
  name: 'ParametrosModal',
  props: {
    show: { type: Boolean, default: false },          // v-model:show
    procedure: { type: String, required: true },
    apiBase: { type: String, default: '' }            // ex.: '/api/meta-dados' (sem barra final)
  },
  data(){ return {
    list: [], loading: false, saving: false, filter: ''
  }},
  computed:{
    http(){ return axios.create({ baseURL: this.apiBase.replace(/\/$/, '') }); },
    filtered(){
      const t=(this.filter||'').toLowerCase();
      return (this.list||[]).filter(p =>
        (p.nome_parametro||'').toLowerCase().includes(t) ||
        (p.titulo_parametro||'').toLowerCase().includes(t)
      );
    }
  },
  watch:{
    show(v){ if(v) this.load(); }
  },
  methods:{
    async load(){
      
      this.loading = true;
      
      try{
        
        const { data } = await api.get(`parametros/${this.procedure}`);
        
        console.log('parametros: ', data);
        
        this.list = Array.isArray(data) ? data.map(p=>({
          ...p,
          //valor_padrao: p.valor_padrao ?? '',
          valor_padrao: normalizeParamValue(p),
          obrigatorio: p.obrigatorio ? 1 : 0,
          editavel:    p.editavel ? 1 : 0,
          titulo_parametro: p.titulo_parametro ?? ''
        })) : [];
      } finally { this.loading = false; }
    },
    async sync(){
      await api.post(`parametros/sync/${this.procedure}`);

      console.log('-->',this.procedure);

      await this.load();
    },

    async save(){
      this.saving = true;
      try{
        for(const p of (this.list||[])){
          await this.http.put(`/parametros/${p.id}`, {
            //valor_padrao: p.valor_padrao ?? '',
            valor_padrao: normalizeParamValue(p),
            obrigatorio: p.obrigatorio ? 1 : 0,
            editavel: p.editavel ? 1 : 0,
            titulo_parametro: p.titulo_parametro ?? ''
          });
        }
        // devolve lista salva para o pai (para atualizar o form)
        this.$emit('saved', this.list);
        this.$emit('update:show', false);
      } finally { this.saving = false; }
    }
  }
};
</script>

<style>
.modal-mask{position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.35);display:flex;align-items:center;justify-content:center}
.modal-wrapper{width:92%;max-width:1100px}
.modal-container{background:#fff;border-radius:6px;box-shadow:0 2px 8px rgba(0,0,0,.33);overflow:hidden}
.modal-header,.modal-footer,.modal-toolbar{padding:10px 14px}
.modal-header{display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #eee}
.modal-toolbar{display:flex;gap:10px;align-items:center;border-bottom:1px solid #eee}
.modal-body{max-height:60vh;overflow:auto;padding:10px 14px}
.btn{background:#fd7e14;color:#fff;border:none;padding:8px 14px;font-weight:600;border-radius:4px;cursor:pointer}
.btn.secondary{background:#6c757d}
.inp{padding:6px;border:1px solid #ccc;border-radius:4px;width:100%}
.tb{width:100%;border-collapse:collapse;background:#fff}
.tb th,.tb td{border:1px solid #ccc;padding:6px}
.tb th{background:#0d6efd;color:#fff}
.tb td.c{text-align:center}
</style>
