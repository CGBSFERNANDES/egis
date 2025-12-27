<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />

    <!-- TOPO no estilo UnicoFormEspecial / SchedulerDinamico -->
    <div class="row items-center">
      <transition name="slide-fade">
        <!-- título + seta + badge -->
        <h2 class="content-block col-8" v-show="tituloMenu">
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
          {{ tituloMenu }}

          <!-- badge com total de registros -->
          <q-badge
            v-if="totalRegistros >= 0"
            align="middle"
            rounded
            color="red"
            class="q-ml-sm bg-form"
          >
            {{ totalRegistros }}
          </q-badge>
        </h2>
        
      </transition>
      <!-- Atualizar -->
        <q-btn
          rounded
          dense
          size="lg"
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="refresh"
          @click="carregarAgenda"
        />

        <!-- Info do menu -->
        <q-btn
          rounded
          dense
          size="lg"
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="info"
          @click="onInfoClick"
        />

      <!-- ações à direita -->
      <div class="col">
        
        <!-- Chip com cd_menu (igual outros formulários) -->
        <q-chip
          v-if="cdMenu || cd_menu"
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm margin-menu cd_menu-chip"
          size="16px"
          text-color="white"
          :label="`${cdMenu || cd_menu}`"
        />
      </div>

      <!-- Modal de informação do menu -->
      <q-dialog v-model="infoDialog">
        <q-card style="min-width: 640px">
          <q-card-section class="text-h6">
            <q-icon
              name="info"
              color="deep-orange-9"
              size="48px"
              class="q-mr-sm"
            />
            {{ infoTitulo }}
          </q-card-section>
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

    <!-- Scheduler padrão (somente leitura) -->
    <div class="q-mt-md">
      <dx-scheduler
        :data-source="appointments"
        :current-date="currentDate"
        :views="views"
        current-view="week"
        :start-day-hour="0"
        :end-day-hour="23"
        text-expr="text"
        start-date-expr="startDate"
        end-date-expr="endDate"
        all-day-expr="allDay"
        :resources="resources"
        :editing="editingConfig"
        height="650"
        @appointment-dbl-click="onAppointmentDblClick"
        @current-date-changed="onCurrentDateChanged"
        appointment-tooltip-template="AppointmentTooltipTemplateSlot"
      >
        <!-- Tooltip customizado -->
        <template
          slot="AppointmentTooltipTemplateSlot"
          slot-scope="{ data }"
        >
          <div class="q-pa-sm" style="max-width: 380px;">
            <!-- título -->
            <div class="text-subtitle2 q-mb-xs">
              {{ data.appointmentData.text }}
            </div>

            <!-- data -->
            <div class="text-caption">
              {{ formatarIntervalo(
                data.appointmentData.startDate,
                data.appointmentData.endDate
              ) }}
            </div>
          </div>
        </template>
      </dx-scheduler>
    </div>

    <!-- Dialog simples ao dar 2 cliques no compromisso -->
    <q-dialog v-model="detalheDialog">
      <q-card style="min-width: 480px">
        <q-card-section class="text-h6">
          {{ (compromissoSelecionado && compromissoSelecionado.text) || 'Detalhe da Agenda' }}
        </q-card-section>
        <q-separator />
        <q-card-section>
          <div class="text-caption q-mb-xs">
            {{ formatarIntervalo(
              compromissoSelecionado && compromissoSelecionado.startDate,
              compromissoSelecionado && compromissoSelecionado.endDate
            ) }}
          </div>
          <div v-if="compromissoSelecionado && compromissoSelecionado.raw">
            <!-- Aqui você pode exibir mais campos da procedure, se existirem -->
            <pre style="white-space: pre-wrap;">
{{ compromissoSelecionado.raw }}
            </pre>
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Fechar" color="primary" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import { DxScheduler } from 'devextreme-vue/scheduler'
import { execProcedure, getInfoDoMenu } from '@/services'

export default {
  name: 'AgendaPadraoScheduler',
  components: {
    DxScheduler
  },
  data () {
    return {
      // topo / menu
      tituloMenu: localStorage.nm_menu_titulo || 'Agenda Padrão',
      cd_menu: Number(localStorage.cd_menu || 0),
      cdMenu: Number(localStorage.cd_menu || 0),
      infoDialog: false,
      infoTitulo: '',
      infoTexto: '',

      // scheduler
      currentDate: new Date(),
      views: ['day', 'week', 'month'],
      editingConfig: {
        allowDragging: false,
        allowUpdating: false,
        allowDeleting: false,
        allowAdding: false // somente leitura
      },

      // dados da agenda (resultado da procedure)
      registros: [],
      totalRegistros: 0,

      // resources (se quiser agrupar por algum campo depois)
      resources: [],

      // contexto de sessão / conexão
      cd_empresa: Number(localStorage.cd_empresa || 0),
      cd_usuario: Number(localStorage.cd_usuario || 0),
      banco: localStorage.nm_banco_empresa || '',

      // detalhe ao dar 2 cliques
      detalheDialog: false,
      compromissoSelecionado: null
    }
  },
  computed: {
    /**
     * Converte o resultado da procedure (dt_agenda, nm_agenda)
     * em appointments para o DxScheduler
     */
    appointments () {
      return this.registros.map(r => {
        // dt_agenda pode vir como string SQL / ISO -> convertemos
        const start = this.sqlToDateLocal(r.dt_agenda)
        // duração padrão de 1h (ajuste se quiser)
        let end = start
          ? new Date(start.getTime() + 60 * 60 * 1000)
          : null

        const allDay = false

        return {
          text: r.nm_agenda || '(sem título)',
          startDate: start,
          endDate: end,
          allDay,
          raw: r // guardamos o registro original para exibir no diálogo
        }
      })
    }
  },
  created () {
    this.bootstrap()
  },
  methods: {
    onVoltar () {
      if (this.$router) {
        this.$router.back()
      } else {
        this.$emit('voltar')
      }
    },

    async onInfoClick () {
      try {
        const { titulo, descricao } = await getInfoDoMenu(this.cd_menu, {
          tituloFallback: this.tituloMenu || 'Agenda Padrão'
        })
        this.infoTitulo = `${titulo} - ${this.cd_menu}`
        this.infoTexto = descricao || ''
        this.infoDialog = true
      } catch (err) {
        console.error('Erro ao carregar info do menu:', err)
      }
    },

    async bootstrap () {
      await this.carregarAgenda()
    },

    async montarPayloadAgenda (extras = {}) {
      const hoje = new Date()
      const ano = hoje.getFullYear()
      const mes = hoje.getMonth() // 0-11
      const dtIni = new Date(ano, mes, 1)
      const dtFim = new Date(ano, mes + 1, 0)

      const dt_inicial = dtIni.toISOString().substring(0, 10)
      const dt_final = dtFim.toISOString().substring(0, 10)

      //Busca o Parâmetro do cd_menu --> loca

      const payloadTabela = 
      [{ic_json_parametro: 'S', 
        cd_parametro: 1, 
        cd_form: localStorage.cd_form,
        cd_menu: Number(localStorage.cd_menu), 
        nm_tabela_origem: "",
        cd_usuario: localStorage.cd_usuario, }];

      //const { data } = await api.post("/payload-tabela", payload);

       const  data  = await execProcedure(
          'pr_egis_payload_tabela',
          payloadTabela,
          { banco: this.banco }
        )
      
        const cd_parametro_menu = data[0].cd_parametro_menu ? data[0].cd_parametro_menu : 0;
        console.log('Meta do payload tabela:', data);  

      return [
        {
          ic_json_parametro: 'S',
          cd_empresa: this.cd_empresa,
          cd_usuario: this.cd_usuario,
          cd_parametro: cd_parametro_menu, // <- AGENDA PADRÃO
          dt_inicial,
          dt_final,
          ...extras
        }
      ]
    },

    onCurrentDateChanged (e) {
      // e.value é a nova data do header do scheduler
      if (!e || !e.value) return
      this.currentDate = e.value
      // ao mudar a data, recarrega a agenda para o novo mês/ano
      this.carregarAgenda()
      // console.log('Data atual do Scheduler alterada para:', this.currentDate)
    },

    normalizarRetorno (dados, contexto = '') {
      if (!dados) return []

      if (Array.isArray(dados)) {
        return dados
      }

      if (Array.isArray(dados.recordset)) {
        return dados.recordset
      }

      if (Array.isArray(dados.data)) {
        return dados.data
      }

      if (Array.isArray(dados.rows)) {
        return dados.rows
      }

      return [dados]
    },

    async carregarAgenda () {
      try {
        const payload = await this.montarPayloadAgenda()
        console.log('Payload Agenda Padrão (param 1):', payload, this.banco)

        const dados = await execProcedure(
          'pr_egis_agenda_processo_modulo',
          payload,
          { banco: this.banco }
        )

        const lista = this.normalizarRetorno(dados, 'agendaPadrao')
        this.registros = lista
        this.totalRegistros = lista.length

        //if (this.appointments.length > 0 && this.appointments[0].startDate) {
        //  this.currentDate = this.appointments[0].startDate
       // }

        console.log('Registros agenda carregados:', this.registros)

      } catch (err) {
        console.error('Erro ao carregar agenda padrão:', err)
        this.$q && this.$q.notify({
          type: 'negative',
          position: 'top-right',
          message: 'Erro ao carregar agenda padrão.'
        })
      }
    },

    sqlToDateLocal (value) {
      if (!value) return null
      if (value instanceof Date) return value
      if (typeof value !== 'string') return null

      let datePart = ''
      let timePart = ''

      if (value.includes('T')) {
        ;[datePart, timePart] = value.split('T')
      } else if (value.includes(' ')) {
        ;[datePart, timePart] = value.split(' ')
      } else {
        const d = new Date(value)
        return isNaN(d.getTime()) ? null : d
      }

      if (!datePart) return null

      const parts = datePart.split('-').map(Number)
      const yyyy = parts[0]
      const mm = parts[1]
      const dd = parts[2]

      const timeArr = (timePart || '00:00:00').split(':').map(Number)
      const hh = timeArr[0] || 0
      const mi = timeArr[1] || 0
      const ss = timeArr[2] || 0

      const dt = new Date(
        yyyy,
        (mm || 1) - 1,
        dd || 1,
        hh || 0,
        mi || 0,
        ss || 0
      )
      return isNaN(dt.getTime()) ? null : dt
    },

    formatarIntervalo (inicio, fim) {
      if (!inicio) return ''
      const i = inicio instanceof Date ? inicio : new Date(inicio)
      const f = fim instanceof Date ? fim : (fim ? new Date(fim) : null)

      const pad = n => String(n).padStart(2, '0')

      const data =
        pad(i.getDate()) +
        '/' +
        pad(i.getMonth() + 1) +
        '/' +
        i.getFullYear()

      const horaIni = pad(i.getHours()) + ':' + pad(i.getMinutes())
      let texto = data + ' ' + horaIni

      if (f && !isNaN(f.getTime())) {
        const horaFim = pad(f.getHours()) + ':' + pad(f.getMinutes())
        texto += ' - ' + horaFim
      }

      return texto
    },

    onAppointmentDblClick (e) {
      const dado = e.appointmentData || {}
      this.compromissoSelecionado = dado
      this.detalheDialog = true

      e.cancel = true
    }
  }
}
</script>

<style scoped>
.margin-menu {
  position: absolute; right: 10px;
  top: 30px;
}

.bg-form {
  background-color: #fff;
}

.cd-menu-chip {
  min-height: 40px;            /* altura parecida com o q-btn padrão */
  padding: 0 18px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 500;
  margin-top: 4px;
}

</style>
