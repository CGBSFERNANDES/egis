<template>
  <div class="q-pa-md">
    <div class="row items-center q-mb-md">
      <div class="text-h6 text-weight-bold">Agenda por Consultor</div>
      <q-space />
      <q-input
        v-model="filtro.inicio"
        label="Início"
        dense
        type="date"
        class="q-mr-sm"
        @change="carregarAgenda"
      />
      <q-input
        v-model="filtro.fim"
        label="Fim"
        dense
        type="date"
        class="q-mr-sm"
        @change="carregarAgenda"
      />
      <q-input
        v-model.number="filtro.qtDia"
        type="number"
        label="Atividades/dia"
        dense
        style="max-width: 140px"
        @change="carregarAgenda"
      />
      <q-input
        v-model.number="filtro.cdConsultor"
        type="number"
        label="Cd. Consultor"
        dense
        style="max-width: 180px"
        @keyup.enter="carregarAgenda"
      />
      <q-btn :loading="loading" dense color="primary" class="q-ml-sm" @click="carregarAgenda" icon="refresh" />
    </div>

    <q-spinner v-if="loading" size="lg" />

    <div v-else class="row q-col-gutter-md">
      <div
        v-for="dia in agenda"
        :key="dia.dt_agenda"
        class="col-xs-12 col-sm-6 col-md-4 col-lg-3"
      >
        <q-card class="cursor-pointer" @click="abrirDia(dia)" :class="diaCardClass(dia)">

          <q-card-section class="bg-grey-2">
            <div class="text-subtitle2">
              {{ formatDate(dia.dt_agenda) }} • {{ weekdayPt(dia.dt_agenda) }}
            </div>


            <div class="text-caption text-grey-7">
              {{ dia.qt_total_dia }} atividade(s)
            </div>
          </q-card-section>
          <q-separator />
            <q-card-section v-if="dia._atividades && dia._atividades.length">
            <div
                v-for="(a, idx) in dia._atividades"
              :key="a.cd_registro_suporte + '-' + idx"
              class="q-mb-xs text-body2 ellipsis"
            >
              #{{ a.cd_registro_suporte }} — {{ resumo(a.ds_ocorrencia_suporte) }}
              <div class="text-caption text-grey-7">
                {{ consultorNome(a) }}
              </div>


            </div>
          </q-card-section>
          <q-card-section v-else class="text-grey-6">
            Sem atividades.
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Detalhes do dia -->
    <q-dialog v-model="modal.aberto" persistent maximized>
      <q-card>
        <q-bar>
          <div class="text-subtitle2">
                 {{ formatDate(modal.dt) }} • {{ weekdayPt(modal.dt) }}
          </div>
          <q-space />
          <q-btn dense flat icon="close" v-close-popup />
        </q-bar>

        <q-card-section>
          <q-table
            :rows="modal.rows"
            :columns="columnsDetalhe"
            row-key="cd_registro_suporte"
            flat
            dense
            separator="cell"
            :pagination.sync="paginacao"
          >
            <template v-slot:body-cell="props">
              <q-td :props="props">
                <span>{{ renderCell(props.col.name, props.row[props.col.name]) }}</span>
              </q-td>
            </template>
          </q-table>
        </q-card-section>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>

//
import api from '@/boot/axios'
//

const API_BASE = 'https://egiserp.com.br'; // BACKEND REAL

export default {
  name: 'agendaAtividadesCon',
  data () {
    const hoje = new Date();
    const y = hoje.getFullYear();
    const m = String(hoje.getMonth()+1).padStart(2,'0');
    const d = String(hoje.getDate()).padStart(2,'0');
    const inicio = `${y}-${m}-01`;
    const fim    = `${y}-${m}-28`; // simples; usuário ajusta
    //const API_BASE = 'https://egiserp.com.br'; // BACKEND REAL

    return {
      loading: false,
      agenda: [],
      consultoresMap: {}, // {cd_consultor: nm_consultor}
      filtro: {
        inicio,
        fim,
        qtDia: 6,
        cdConsultor: null
      },
      titulos: {}, // { nm_atributo: nm_titulo }
      modal: {
        aberto: false,
        dt: null,
        nmDia: '',
        rows: []
      },
      paginacao: { rowsPerPage: 10 }
    };
  },
  computed: {
    columnsDetalhe () {
      // 17 atributos – títulos vindos da atributo(cd_tabela=1885)
      const fields = [
        'cd_registro_suporte','dt_registro_suporte','hr_entrada','dt_ocorrencia_suporte',
        'ds_ocorrencia_suporte','ds_mensagem_suporte','ds_observacao_suporte','nm_doc_registro_suporte',
        'dt_previsao_solucao','cd_consultor_solucao','ic_agendar_visita','qt_hora_registro',
        'ic_cronograma','cd_consultor','cd_cliente','cd_contato','cd_modulo'
      ];
      return fields.map(f => ({
        name: f,
        label: this.titulos[f] || f,
        field: f,
        align: 'left',
        sortable: true
      }));
    }
  },
  mounted () {
    this.carregarTitulos().then(this.carregarAgenda);
  },
  methods: {
    http () {
      // funciona com projetos que usam this.$api *ou* import api
      return this.$api || api
    },

    normalizeRows (resp) {
      // Aceita os formatos mais comuns do executor
      if (Array.isArray(resp)) return resp
      if (resp && Array.isArray(resp.data)) return resp.data
      if (resp && Array.isArray(resp.rows)) return resp.rows
      if (resp && Array.isArray(resp.recordset)) return resp.recordset
      if (resp && resp[0] && Array.isArray(resp[0].recordset)) return resp[0].recordset
      return []
    },

    //
        async carregarTitulos () {
      try {
       const body = [{ ic_json_parametro: 'S', cd_parametro: 0, cd_tabela: 1885 }]
        const { data } = await (this.$api || api).post('/api/exec/pr_egis_atributos_tabela', body, {
          headers: { 'x-banco': 'egisAdmin' }
        })
        const rows = Array.isArray(data) ? data : (data?.data || data?.rows || data?.recordset || [])
        const map = {}; rows.forEach(r => { map[r.nm_atributo] = r.nm_titulo })
        this.titulos = map
      } catch (e) { this.titulos = {} }
    },
    

    //
    async carregarAgenda () {
      this.loading = true;
      try {
 
        const body = [{
          ic_json_parametro: 'S',
          cd_parametro: 1,
          dt_inicial: this.filtro.inicio,
          dt_final: this.filtro.fim,
          qt_dia_atividade: this.filtro.qtDia || 6,
          cd_consultor: this.filtro.cdConsultor || null
        }]
        //const { data: resp } = await this.http().post(
        //  '/api/exec/pr_egis_atividades_processo_modulo',
        //  body
        //)

        //this.agenda = this.normalizeRows(resp)
                const { data } = await (this.$api || api).post('/api/exec/pr_egis_atividades_processo_modulo', body)
        const rows = Array.isArray(data) ? data : (data?.data || data?.rows || data?.recordset || [])
        // pre-parse + status por dia
        const today = new Date(); today.setHours(0,0,0,0)
        const agenda = rows.map(r => {
          const dt = new Date(String(r.dt_agenda).replace(' ', 'T'))
          const atividades = this.parseAtividades(r.atividades_json)
          const d = dt; const d0 = new Date(d); d0.setHours(0,0,0,0)
          const status = d0 < today ? 'late' : (d0.getTime() === today.getTime() ? 'today' : 'future')
          return { ...r, _atividades: atividades, _status: status }
        })
        this.agenda = agenda
        // carrega nomes de consultor, se necessário
        await this.carregarConsultoresDe(agenda)
       //

      } catch (e) {
        this.agenda = [];
      } finally {
        this.loading = false;
      }
    },
        async carregarConsultoresDe (agenda) {
      // junta todos os códigos do período
      const set = new Set()
      agenda.forEach(d => (d._atividades||[]).forEach(a => {
        const cd = a.cd_consultor_solucao || a.cd_consultor
        if (cd) set.add(cd)
      }))
      if (!set.size) return
      try {
        const body = [{ ic_json_parametro: 'S', cd_parametro: 0, cds: Array.from(set).join(',') }]
        // Se ainda não existir essa proc no seu banco, use o fallback do consultorNome()
        const { data } = await (this.$api || api).post('/api/exec/pr_egis_consultores', body, {
          headers: { 'x-banco': 'egisAdmin' }
        })
        const rows = Array.isArray(data) ? data : (data?.data || data?.rows || data?.recordset || [])
        const map = {}; rows.forEach(r => { map[r.cd_consultor] = r.nm_consultor })
        this.consultoresMap = map
      } catch (e) { /* segue com fallback */ }
    },

    abrirDia (dia) {
     // const atividades = this.parseAtividades(dia.atividades_json) || [];
      const atividades = dia._atividades || [];
      this.modal.aberto = true;
      this.modal.dt = dia.dt_agenda;
      //this.modal.nmDia = dia.nm_dia_semana;
      this.modal.nmDia = this.weekdayPt(dia.dt_agenda);
      this.modal.rows = atividades;
    },
  parseAtividades (val) {
      if (!val) return []
      // Já veio array/objeto?
      if (Array.isArray(val)) return val
      if (typeof val === 'object') return [val]
      // Veio string JSON do FOR JSON PATH?
      if (typeof val === 'string') {
        try { return JSON.parse(val) } catch (e) { /* tenta corrigir */ }
        // alguns drivers mandam string com aspas extras
        const trimmed = val.trim()
        if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
            (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
          try { return JSON.parse(trimmed.slice(1, -1)) } catch (e2) {}
        }
      }
      return []
    },
  
      weekdayPt (v) {
      const d = new Date(String(v).replace(' ', 'T'))
      return d.toLocaleDateString('pt-BR', { weekday: 'long' })
        .replace(/^./, c => c.toUpperCase())
        .slice(0,3)},

    formatDate (v) {
     if (!v) return ''
      // aceita 'YYYY-MM-DD HH:mm:ss.sss' -> vira ISO
      const s = typeof v === 'string' ? v.replace(' ', 'T') : v
      const d = new Date(s)
      if (isNaN(d)) return String(v)
      return d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' })
    },

   diaCardClass (dia) {
      return {
        'status-late': dia._status === 'late',
        'status-today': dia._status === 'today'
      }
    },
    diaHeaderClass (dia) {
      return {
        'bg-red-2': dia._status === 'late',
        'bg-yellow-2': dia._status === 'today'
      }
    },
    consultorNome (a) {
      // prioridade: nm_consultor já vindo da API
      if (a.nm_consultor) return a.nm_consultor
      const cd = a.cd_consultor_solucao || a.cd_consultor
      if (!cd) return ''
      return this.consultoresMap[cd] || `#${cd}`
    },


    resumo (txt) { return (txt || '').toString().slice(0,60); },
    renderCell (field, val) {
      if (!val) return '';
      if (String(field).startsWith('dt_')) {
       const dt = new Date((typeof val === 'string') ? val.replace(' ', 'T') : val);
        if (!isNaN(dt)) return dt.toLocaleString('pt-BR');
      }
      return val;
    }
  }
};
</script>

<style scoped>
.cursor-pointer { cursor: pointer; }
.ellipsis { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
/* cores suaves de status */
.status-late  { border-left: 6px solid #fca5a5; background: #ffecec; }
.status-today { border-left: 6px solid #facc15; background: #fff8d6; }
</style>
