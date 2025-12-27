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
        :key="dia._key"
        class="col-xs-12 col-sm-6 col-md-4 col-lg-3"
      >
        <q-card class="cursor-pointer" @click="abrirDia(dia)" :class="diaCardClass(dia)">
          <q-card-section :class="['bg-grey-2', diaHeaderClass(dia)]">
            <div class="text-subtitle2">
              {{ formatDateBR(dia._date) }} • {{ weekdayPt(dia._date) }}
            </div>
            <div class="text-caption text-grey-7">
              {{ dia.qt_total_dia || 0 }} atividade(s)
            </div>
          </q-card-section>
          <q-separator />
          <q-card-section v-if="(dia._atividades || []).length">
            <div
              v-for="(a,idx) in dia._atividades"
              :key="(a.cd_registro_suporte || idx) + '-' + idx"
              class="q-mb-sm"
            >
              <div class="text-body2 ellipsis">
                #{{ a.cd_registro_suporte }} — {{ resumo(a.ds_ocorrencia_suporte) }}
              </div>
              <div class="text-caption text-grey-7">
                {{ consultorNome(a) }}
              </div>
              <div class="text-caption">
                {{ horaAtividade(a, dia._date) }}
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
            {{ formatDateBR(modal._date) }} • {{ weekdayPt(modal._date) }}
          </div>
          <q-space />
          <q-btn dense flat icon="close" v-close-popup />
        </q-bar>

        <q-card-section>
          <q-table
            :rows="modal.rows"
            :columns="columnsDetalhe"
            row-key="cd_registro_suporte"
            flat dense separator="cell"
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
import api from '@/boot/axios'

export default {
  name: 'agendaAtividadesCon',
  data () {
    const hoje = new Date()
    const y = hoje.getFullYear()
    const m = String(hoje.getMonth() + 1).padStart(2, '0')
    const inicio = `${y}-${m}-01`
    const fim = `${y}-${m}-28`

    return {
      loading: false,
      agenda: [],
      filtro: {
        inicio,
        fim,
        qtDia: 6,
        cdConsultor: null
      },
      titulos: {}, // { nm_atributo: nm_titulo }
      consultoresMap: {}, // { cd_consultor: nm_consultor }
      modal: {
        aberto: false,
        _date: null,
        rows: []
      },
      paginacao: { rowsPerPage: 10 }
    }
  },
  computed: {
    columnsDetalhe () {
      const fields = [
        'cd_registro_suporte','dt_registro_suporte','hr_entrada','dt_ocorrencia_suporte',
        'ds_ocorrencia_suporte','ds_mensagem_suporte','ds_observacao_suporte','nm_doc_registro_suporte',
        'dt_previsao_solucao','cd_consultor_solucao','ic_agendar_visita','qt_hora_registro',
        'ic_cronograma','cd_consultor','cd_cliente','cd_contato','cd_modulo'
      ]
      return fields.map(f => ({
        name: f,
        label: this.titulos[f] || f,
        field: f,
        align: 'left',
        sortable: true
      }))
    }
  },
  mounted () {
    this.carregarTitulos().then(this.carregarAgenda)
  },
  methods: {
    http () {
      return this.$api || api
    },

    // ===========================
    // PARSE/FORMAT DE DATAS (LOCAL)
    // ===========================
    // Aceita: 'YYYY-MM-DD', 'YYYY-MM-DD HH:mm[:ss[.fff]]', 'YYYY-MM-DDTHH:mm[:ss[.fff]]'
    parseLocalDate (v) {
      if (!v) return null
      const s = String(v)
      const m = s.match(
        /^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2})(?::(\d{2})(?::(\d{2})(?:\.(\d{1,3}))?)?)?)?$/
      )
      if (!m) {
        // fallback: tenta construir e validar
        const d = new Date(s)
        return isNaN(d) ? null : d
      }
      const [, yy, MM, dd, hh, mm, ss, fff] = m
      return new Date(
        Number(yy),
        Number(MM) - 1,
        Number(dd),
        Number(hh || 0),
        Number(mm || 0),
        Number(ss || 0),
        Number(fff || 0)
      )
    },

    startOfDay (d) {
      if (!d) return null
      return new Date(d.getFullYear(), d.getMonth(), d.getDate(), 0, 0, 0, 0)
    },

    formatDateBR (d) {
      if (!d) return ''
      return d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' })
    },

    weekdayPt (d) {
      if (!d) return ''
      return d
        .toLocaleDateString('pt-BR', { weekday: 'long' })
        .replace(/^./, c => c.toUpperCase())
    },

    // ===========================
    // CARGA DE TÍTULOS (egisAdmin)
    // ===========================
    async carregarTitulos () {
      try {
        const body = [{ ic_json_parametro: 'S', cd_parametro: 0, cd_tabela: 1885 }]
        const { data } = await this.http().post('/api/exec/pr_egis_atributos_tabela', body, {
          headers: { 'x-banco': 'egisAdmin' }
        })
        const rows = Array.isArray(data) ? data : (data?.data || data?.rows || data?.recordset || [])
        const map = {}
        rows.forEach(r => { map[r.nm_atributo] = r.nm_titulo })
        this.titulos = map
      } catch (e) {
        this.titulos = {}
      }
    },

    // ===========================
    // CARGA DA AGENDA (empresa)
    // ===========================
    async carregarAgenda () {
      this.loading = true
      try {
        const body = [{
          ic_json_parametro: 'S',
          cd_parametro: 1,
          dt_inicial: this.filtro.inicio,
          dt_final: this.filtro.fim,
          qt_dia_atividade: this.filtro.qtDia || 6,
          cd_consultor: this.filtro.cdConsultor || null
        }]

        const { data } = await this.http().post('/api/exec/pr_egis_atividades_processo_modulo', body)
        const rows = Array.isArray(data) ? data : (data?.data || data?.rows || data?.recordset || [])

        const today0 = this.startOfDay(new Date())
        const agenda = rows.map(r => {
          const d = this.parseLocalDate(r.dt_agenda)
          const d0 = this.startOfDay(d)
          const status = !d0 ? 'future'
            : (d0 < today0 ? 'late' : (d0.getTime() === today0.getTime() ? 'today' : 'future'))

          const acts = this.parseAtividades(r.atividades_json)

          return {
            ...r,
            _key: `${r.dt_agenda || ''}-${r.nm_dia_semana || ''}`,
            _date: d,
            _status: status,
            _atividades: acts
          }
        })

        this.agenda = agenda
        // opcional: buscar nomes dos consultores (se houver proc e quiser exibir)
        this.carregarConsultoresDe(agenda).catch(() => {})
      } catch (e) {
        this.agenda = []
      } finally {
        this.loading = false
      }
    },

    // ===========================
    // CONSULTOR (opcional)
    // ===========================
    async carregarConsultoresDe (agenda) {
      const set = new Set()
      agenda.forEach(d => (d._atividades || []).forEach(a => {
        const cd = a.cd_consultor_solucao || a.cd_consultor
        if (cd) set.add(cd)
      }))
      if (!set.size) return
      try {
        const body = [{ ic_json_parametro: 'S', cd_parametro: 0, cds: Array.from(set).join(',') }]
        const { data } = await this.http().post('/api/exec/pr_egis_consultores', body, {
          headers: { 'x-banco': 'egisAdmin' }
        })
        const list = Array.isArray(data) ? data : (data?.data || data?.rows || data?.recordset || [])
        const map = {}
        list.forEach(x => { map[x.cd_consultor] = x.nm_consultor })
        this.consultoresMap = map
      } catch {
        // fica com fallback #<cd>
      }
    },

    // ===========================
    // PARSE DO JSON DE ATIVIDADES
    // ===========================
    parseAtividades (val) {
      if (!val) return []
      if (Array.isArray(val)) return val
      if (typeof val === 'object') return [val]
      if (typeof val === 'string') {
        try { return JSON.parse(val) } catch (e) {}
        const t = val.trim()
        if ((t.startsWith('"') && t.endsWith('"')) || (t.startsWith("'") && t.endsWith("'"))) {
          try { return JSON.parse(t.slice(1, -1)) } catch (e2) {}
        }
      }
      return []
    },

    // ===========================
    // UI / FORMATAÇÕES
    // ===========================
    abrirDia (dia) {
      this.modal.aberto = true
      this.modal._date = dia._date
      this.modal.rows = dia._atividades || []
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
      if (a.nm_consultor) return a.nm_consultor
      const cd = a.cd_consultor_solucao || a.cd_consultor
      if (!cd) return ''
      return this.consultoresMap[cd] || `#${cd}`
    },

    horaAtividade (a, diaDate, somenteHora = false) {
      // base: dt_previsao_solucao (ou data do dia do card)
      const base = this.parseLocalDate(a.dt_previsao_solucao) || diaDate
      if (!base) return ''
      const start = new Date(base.getFullYear(), base.getMonth(), base.getDate(), 9, 0, 0, 0)
      if (a.hr_entrada) {
        const [H, M] = String(a.hr_entrada).split(':')
        start.setHours(+H || 9, +M || 0, 0, 0)
      }
      const end = new Date(start)
      end.setHours(start.getHours() + 1)
      const hIni = start.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
      const hFim = end.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
      if (somenteHora) return `${hIni} - ${hFim}`
      const dataPt = start.toLocaleDateString('pt-BR', { day: 'numeric', month: 'long' })
      return `${dataPt} ${hIni} - ${hFim}`
    },

    resumo (txt) {
      return (txt || '').toString().slice(0, 70)
    },

    renderCell (field, val) {
      if (val == null) return ''
      if (String(field).startsWith('dt_')) {
        const d = this.parseLocalDate(val)
        return d ? d.toLocaleString('pt-BR') : String(val)
      }
      return val
    }
  }
}
</script>

<style scoped>
.cursor-pointer { cursor: pointer; }
.ellipsis { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

/* cores suaves de status */
.status-late  { border-left: 6px solid #fca5a5; background: #ffecec; }
.status-today { border-left: 6px solid #facc15; background: #fff8d6; }
</style>
