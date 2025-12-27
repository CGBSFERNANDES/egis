<template>
  <div class="q-pa-md">
    <div class="row items-center q-mb-md">
      <div class="text-h6 text-weight-bold">Agenda (DxScheduler)</div>
      <q-space />
      <q-input
        v-model="filtro.inicio"
        label="Início"
        dense
        type="date"
        class="q-mr-sm"
        @change="load"
      />
      <q-input
        v-model="filtro.fim"
        label="Fim"
        dense
        type="date"
        class="q-mr-sm"
        @change="load"
      />
      <q-input
        v-model.number="filtro.cdConsultor"
        type="number"
        label="Cd. Consultor"
        dense
        style="max-width: 180px"
        @keyup.enter="load"
      />
      <q-btn dense color="primary" class="q-ml-sm" :loading="loading" @click="load" icon="refresh" />
    </div>

    <DxScheduler
      :data-source="events"
      :views="views"
      current-view="week"
      :current-date="currentDate"
      :first-day-of-week="1"
      :start-day-hour="8"
      :end-day-hour="19"
      height="750"
      time-zone="America/Sao_Paulo"
      :adaptivity-enabled="true"
    >
      <DxResource
        field-expr="status"
        label="Status"
        :use-color-as-default="true"
        :data-source="statusDS"
      />
      <DxResource
        field-expr="cd_consultor_solucao"
        label="Consultor"
        :data-source="consultoresDS"
      />
    </DxScheduler>
  </div>
</template>

<script>
import { DxScheduler, DxResource } from 'devextreme-vue/scheduler'
import { locale } from 'devextreme/localization'
import api from '@/boot/axios'

export default {
  name: 'agendaAtividadesDx',
  components: { DxScheduler, DxResource },
  data () {
    const hoje = new Date()
    const y = hoje.getFullYear()
    const m = String(hoje.getMonth() + 1).padStart(2, '0')
    const inicio = `${y}-${m}-01`
    const fim = `${y}-${m}-28`

    return {
      loading: false,
      currentDate: hoje,
      views: ['day', 'week', 'month'],
      events: [],
      consultoresDS: [],
      statusDS: [
        { id: 'late',  text: 'Atrasado', color: '#fca5a5' },
        { id: 'today', text: 'Hoje',     color: '#facc15' },
        { id: 'future',text: 'Próximo',  color: '#86efac' }
      ],
      filtro: {
        inicio,
        fim,
        cdConsultor: null
      }
    }
  },
  mounted () {
    locale('pt-BR')
    this.load()
  },
  methods: {
    // ---------------------------
    // Helpers de data (LOCAL)
    // ---------------------------
    // Aceita: 'YYYY-MM-DD', 'YYYY-MM-DD HH:mm[:ss[.fff]]', 'YYYY-MM-DDTHH:mm[:ss[.fff]]'
    parseLocalDate (v) {
      if (!v) return null
      const s = String(v)
      const m = s.match(
        /^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2})(?::(\d{2})(?::(\d{2})(?:\.(\d{1,3}))?)?)?)?$/
      )
      if (!m) {
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

    normalizeRows (resp) {
      if (Array.isArray(resp)) return resp
      if (resp && Array.isArray(resp.data)) return resp.data
      if (resp && Array.isArray(resp.rows)) return resp.rows
      if (resp && Array.isArray(resp.recordset)) return resp.recordset
      if (resp && resp[0] && Array.isArray(resp[0].recordset)) return resp[0].recordset
      return []
    },

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

    // ---------------------------
    // Carregar Agenda
    // ---------------------------
    async load () {
      this.loading = true
      try {
        const body = [{
          ic_json_parametro: 'S',
          cd_parametro: 1,
          dt_inicial: this.filtro.inicio,
          dt_final: this.filtro.fim,
          qt_dia_atividade: 6,
          cd_consultor: this.filtro.cdConsultor || null
        }]

        const { data: resp } = await api.post('/api/exec/pr_egis_atividades_processo_modulo', body)
        const rows = this.normalizeRows(resp)

        const events = []
        const setConsultor = new Set()
        const today0 = this.startOfDay(new Date())

        rows.forEach(r => {
          const day = this.parseLocalDate(r.dt_agenda)
          const day0 = this.startOfDay(day)
          const status = !day0 ? 'future'
            : (day0 < today0 ? 'late' : (day0.getTime() === today0.getTime() ? 'today' : 'future'))

          const acts = this.parseAtividades(r.atividades_json)
          acts.forEach(a => {
            // base = dt_previsao_solucao (ou a própria data da agenda)
            const base = this.parseLocalDate(a.dt_previsao_solucao) || day
            if (!base) return
            // hora de início: hr_entrada (fallback 09:00)
            const start = new Date(base.getFullYear(), base.getMonth(), base.getDate(), 9, 0, 0, 0)
            if (a.hr_entrada) {
              const [H, M] = String(a.hr_entrada).split(':')
              start.setHours(+H || 9, +M || 0, 0, 0)
            }
            // duração pela qt_hora_registro (fallback 1h)
            const dur = Number(a.qt_hora_registro) > 0 ? Number(a.qt_hora_registro) : 1
            const end = new Date(start); end.setHours(start.getHours() + dur)

            events.push({
              text: `#${a.cd_registro_suporte} — ${a.ds_ocorrencia_suporte || ''}`,
              startDate: start,
              endDate: end,
              status,
              cd_consultor_solucao: a.cd_consultor_solucao || a.cd_consultor || null
            })

            const cd = a.cd_consultor_solucao || a.cd_consultor
            if (cd) setConsultor.add(cd)
          })
        })

        this.events = events
        this.currentDate = this.parseLocalDate(this.filtro.inicio) || new Date()

        // opcional: carregar nomes dos consultores para o resource
        await this.loadConsultores(Array.from(setConsultor))
      } catch (e) {
        this.events = []
      } finally {
        this.loading = false
      }
    },

    async loadConsultores (ids) {
      if (!ids || !ids.length) {
        this.consultoresDS = []
        return
      }
      try {
        const body = [{ ic_json_parametro: 'S', cd_parametro: 0, cds: ids.join(',') }]
        const { data: resp } = await api.post('/api/exec/pr_egis_consultores', body, {
          headers: { 'x-banco': 'egisAdmin' }
        })
        const rows = this.normalizeRows(resp)
        this.consultoresDS = rows.map(x => ({ id: x.cd_consultor, text: x.nm_consultor }))
      } catch {
        // se não existir ainda a proc de consultores, resource fica vazio
        this.consultoresDS = ids.map(id => ({ id, text: `#${id}` }))
      }
    }
  }
}
</script>
