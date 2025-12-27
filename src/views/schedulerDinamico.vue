<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />

    <!-- TOPO no estilo do unicoFormEspecial.vue -->
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
            :label="totalRegistros"
            class="q-ml-sm bg-form"
          />
        </h2>
      </transition>

      <!-- ações à direita -->
      <div class="col">
        <!-- Atualizar -->
        <q-btn
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="refresh"
          @click="carregarTudo"
        />

        <!-- Novo registro -->
        <q-btn
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="add"
          @click="abrirDialogInclusao()"
        />
<!-- Gerar cronograma (param 20) -->
<q-btn
  rounded
  color="deep-purple-7"
  class="q-mt-sm q-ml-sm"
  icon="event"
  @click="gerarCronograma"
/>

        <!-- Info do menu (ícone i) -->
        <q-btn
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm"
          icon="info"
          @click="onInfoClick"
        />

        <!-- Chip com cd_menu (igual outros formulários) -->
        <q-chip
          v-if="cdMenu || cd_menu"
          rounded
          color="deep-purple-7"
          class="q-mt-sm q-ml-sm margin-menu"
          size="16px"
          text-color="white"
          :label="`${cdMenu || cd_menu}`"
        />

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
              <q-btn
                flat
                label="Fechar"
                color="primary"
                v-close-popup
              />
            </q-card-actions>
          </q-card>
        </q-dialog>
      </div>
    </div>

    <!-- CONTEÚDO: filtros + scheduler -->
    <div class="q-pa-md">
      <!-- FILTROS -->
      <q-card flat bordered class="q-mb-md">
        <q-card-section class="row q-col-gutter-sm">
          <div class="col-12 col-md-3">
            <q-select
              v-model="filtros.cd_projeto_sistema"
              :options="optionsProjetos"
              option-value="cd_projeto_sistema"
              option-label="nm_projeto"
              emit-value
              map-options
              clearable
              label="Projeto"
              dense
            />
          </div>

          <div class="col-12 col-md-3">
            <q-select
              v-model="atividadeForm.cd_cliente"
              :options="optionsClientes"
              option-value="cd_cliente"
              option-label="nm_fantasia_cliente"
              emit-value
              map-options
              clearable
              label="Cliente"
              dense
            />
          </div>

          <div class="col-12 col-md-3">
            <q-select
              v-model="filtros.cd_consultor"
              :options="optionsConsultores"
              option-value="cd_consultor"
              option-label="nm_fantasia_consultor"
              emit-value
              map-options
              clearable
              label="Consultor"
              dense
            />
          </div>

          <div class="col-12 col-md-3">
            <q-select
              v-model="filtros.cd_atividade"
              :options="optionsAtividades"
              option-value="cd_atividade"
              option-label="nm_atividade"
              emit-value
              map-options
              clearable
              label="Atividade"
              dense
            />
          </div>
        </q-card-section>
      </q-card>

      <!-- SCHEDULER DEVEXTREME -->
      <dx-scheduler
        :data-source="appointmentsFiltrados"
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
        @appointment-updating="onAppointmentUpdating"
        @appointment-deleting="onAppointmentDeleting"
        appointment-tooltip-template="AppointmentTooltipTemplateSlot"
      >
       <!-- Tooltip customizado (Vue 2 + DevExtreme) -->
        <template
          slot="AppointmentTooltipTemplateSlot"
          slot-scope="{ data }"
        >
          <div class="q-pa-sm" style="max-width: 380px;">
            <!-- título -->
            <div class="text-subtitle2 q-mb-xs">
              {{ data.appointmentData.text }}
            </div>

            <!-- horário -->
            <div class="text-caption text-grey-7 q-mb-xs">
              {{ formatHora(data.appointmentData.startDate) }} -
              {{ formatHora(data.appointmentData.endDate) }}
            </div>

            <!-- descrição longa (ds_registro_atividade) -->
            <div
              v-if="data.appointmentData.descricao"
              class="text-body2"
              style="white-space: pre-wrap;"
            >
              {{ data.appointmentData.descricao }}
            </div>
          </div>
        </template>
      </dx-scheduler>


      <!-- DIALOGO CADASTRO / EDIÇÃO DA ATIVIDADE -->
      <q-dialog v-model="dlgAtividade">
        <q-card style="min-width: 500px; max-width: 800px;">
          <q-card-section>
            <div class="text-h6">
              {{ modoEdicao === 'I' ? 'Nova Atividade' : 'Editar Atividade' }}
            </div>
          </q-card-section>

          <q-card-section class="q-gutter-md">
            <q-input
              v-model="atividadeForm.ds_registro_atividade"
              label="Descrição / Título"
              type="textarea"
              autogrow
              dense
            />

            <div class="row q-col-gutter-sm">
              <div class="col-12 col-md-6">
                <q-select
                  v-model="atividadeForm.cd_projeto_sistema"
                  :options="optionsProjetos"
                  option-value="cd_projeto_sistema"
                  option-label="nm_projeto"
                  emit-value
                  map-options
                  label="Projeto"
                  dense
                />
              </div>
              <div class="col-12 col-md-6">
                <q-select
                  v-model="atividadeForm.cd_cliente"
                  :options="optionsClientes"
                  option-value="cd_cliente"
                  option-label="nm_fantasia_cliente"
                  emit-value
                  map-options
                  label="Cliente"
                  dense
                />
              </div>
            </div>

            <div class="row q-col-gutter-sm">
              <div class="col-12 col-md-6">
                <q-select
                  v-model="atividadeForm.cd_consultor"
                  :options="optionsConsultores"
                  option-value="cd_consultor"
                  option-label="nm_fantasia_consultor"
                  emit-value
                  map-options
                  label="Consultor"
                  dense
                />
              </div>
              <div class="col-12 col-md-6">
                <q-select
                  v-model="atividadeForm.cd_atividade"
                  :options="optionsAtividades"
                  option-value="cd_atividade"
                  option-label="nm_atividade"
                  emit-value
                  map-options
                  label="Atividade"
                  dense
                />
              </div>
            </div>

            <div class="row q-col-gutter-sm">
              <div class="col-12 col-md-6">
                <q-input
                  v-model="atividadeForm.dt_inicio_atividade"
                  label="Início"
                  type="datetime-local"
                  dense
                />
              </div>
              <div class="col-12 col-md-6">
                <q-input
                  v-model="atividadeForm.dt_final_atividade"
                  label="Fim"
                  type="datetime-local"
                  dense
                />
              </div>
            </div>
          </q-card-section>

          <q-card-actions align="right">
            <q-btn flat label="Cancelar" color="grey" v-close-popup />
            <q-btn
              flat
              label="Excluir"
              color="negative"
              v-if="modoEdicao === 'A'"
              @click="confirmarExcluir"
            />
            <q-btn
              unelevated
              label="Salvar"
              color="primary"
              @click="salvarAtividade"
            />
          </q-card-actions>
        </q-card>
      </q-dialog>
    </div>
  </div>
</template>

<script>
import { DxScheduler } from 'devextreme-vue/scheduler'
import { execProcedure, getInfoDoMenu } from '@/services'

export default {
  name: 'SchedulerDinamico',
  components: {
    DxScheduler
  },
  data () {
    return {
      // topo / menu
      tituloMenu: localStorage.nm_menu_titulo || "Agenda",
      cd_menu: Number(localStorage.cd_menu || 0),
      cdMenu: Number(localStorage.cd_menu || 0),
      infoDialog: false,
      infoTitulo: '',
      infoTexto: '',

      // scheduler
      currentDate: new Date(),
      views: ['day', 'week', 'month'],
      editingConfig: {
        allowDragging: true,
        allowUpdating: true,
        allowDeleting: true,
        allowAdding: false // inclusão via diálogo próprio
      },

      // dados vindos da procedure
      consultores: [],
      clientes: [],
      projetos: [],
      etapas: [],
      atividades: [],
      registros: [],

      filtros: {
        cd_projeto_sistema: null,
        cd_cliente: null,
        cd_consultor: null,
        cd_atividade: null
      },

      dlgAtividade: false,
      modoEdicao: 'I', // I = inclusão, A = alteração
      atividadeForm: {
        cd_registro_atividade: null,
        ds_registro_atividade: '',
        cd_projeto_sistema: null,
        cd_cliente: null,
        cd_consultor: null,
        cd_atividade: null,
        dt_inicio_atividade: '',
        dt_final_atividade: ''
      },

      cd_empresa: Number(localStorage.cd_empresa || 0),
      cd_usuario: Number(localStorage.cd_usuario || 0),
      banco: localStorage.nm_banco_empresa || '',
      totalRegistros: 0
    }
  },
  computed: {
    optionsConsultores () {
      return this.consultores
    },
    optionsProjetos () {
      return this.projetos
    },
    optionsAtividades () {
      return this.atividades
    },
    optionsClientes () {
      // clientes montados a partir dos registros (join na procedure)
      const mapa = {}
      //this.registros.forEach(r => {
      this.clientes.forEach(r => {  
        if (r.cd_cliente && r.nm_fantasia_cliente) {
          mapa[r.cd_cliente] = {
            cd_cliente: r.cd_cliente,
            nm_fantasia_cliente: r.nm_fantasia_cliente
          }
        }
      })
      return Object.values(mapa)
    },
    resources () {
      return [
        {
          fieldExpr: 'cd_consultor',
          dataSource: this.consultores,
          valueExpr: 'cd_consultor',
          displayExpr: 'nm_fantasia_consultor',
          label: 'Consultor'
        },
        {
          fieldExpr: 'cd_projeto_sistema',
          dataSource: this.projetos,
          valueExpr: 'cd_projeto_sistema',
          displayExpr: 'nm_projeto',
          label: 'Projeto'
        }
      ]
    },


    // registros -> appointments do scheduler
  appointments () {

    console.log('Calculando appointments a partir dos registros:', this.registros);

    const lista = this.registros.map(r => {
    //const startDate = r.dt_inicio_atividade
    //  ? new Date(r.dt_inicio_atividade)
    //  : null

    let startDate = startDate = this.sqlToDateLocal
      ? this.sqlToDateLocal(r.dt_inicio_atividade)
      : new Date(r.dt_inicio_atividade);

    let endDate = this.sqlToDateLocal
      ? this.sqlToDateLocal(r.dt_final_atividade)
      : new Date(r.dt_final_atividade);


    //const endDate = r.dt_final_atividade
    //  ? new Date(r.dt_final_atividade)
    //  : null


       // ⚠️ Alguns registros vêm com dt_final_atividade = null ou igual ao início (00:00–00:00)
        // Para não virar um "risquinho", força duração mínima de 2h
        if (startDate && (!endDate || endDate <= startDate)) {
          endDate = new Date(startDate.getTime() + 2 * 60 * 60 * 1000) // +2h
        }


    const text = [
      r.nm_atividade,
      r.nm_projeto,
      r.nm_fantasia_cliente,
      r.nm_consultor
    ].filter(Boolean).join(' | ')

    return {
      id: r.cd_registro_atividade,
      text,
      startDate,
      endDate,
      allDay: false,
      cd_consultor: r.cd_consultor,
      cd_projeto_sistema: r.cd_projeto_sistema,
      cd_cliente: r.cd_cliente,
      cd_atividade: r.cd_atividade,
      descricao: r.ds_registro_atividade || '', // 👈 vamos usar no tooltip
      _raw: r
    }
  })

  console.log('Appointments calculados:', lista)

  return lista

},

    appointmentsoLD () {

      return this.registros.map(r => {
        const startDate = r.dt_inicio_atividade ? new Date(r.dt_inicio_atividade) : null
        const endDate = r.dt_final_atividade ? new Date(r.dt_final_atividade) : null

        const textoBase = r.nm_atividade || ''
        const cliente = r.nm_fantasia_cliente || ''
        const projeto = r.nm_projeto || ''

        //const text = [textoBase, projeto, cliente].filter(Boolean).join(' - ')
       // Texto visível no quadradinho do scheduler
       const text = [
         r.nm_atividade,
         r.nm_projeto,
         r.nm_fantasia_cliente
       ].filter(Boolean).join(' | ')

        return {
          id: r.cd_registro_atividade,
          text,
          startDate,
          endDate,
          allDay: false,
          cd_consultor: r.cd_consultor,
          cd_projeto_sistema: r.cd_projeto_sistema,
          cd_cliente: r.cd_cliente,
          cd_atividade: r.cd_atividade,
          _raw: r
        }
      })
    },

    appointmentsFiltrados () {
      return this.appointments.filter(a => {
        const f = this.filtros
        if (f.cd_projeto_sistema && a.cd_projeto_sistema !== f.cd_projeto_sistema) return false
        if (f.cd_cliente && a.cd_cliente !== f.cd_cliente) return false
        if (f.cd_consultor && a.cd_consultor !== f.cd_consultor) return false
        if (f.cd_atividade && a.cd_atividade !== f.cd_atividade) return false
        return true
      })
    }
  },
  async created () {
    await this.buscarConsultor()
    await this.carregarTituloMenu()
    await this.carregarTudo()
  },
  watch: {
    'filtros.cd_consultor' () {
      this.carregarClientes()
    },
    'filtros.cd_projeto_sistema' () {
      this.carregarClientes()
    }
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
          tituloFallback: this.tituloMenu || 'Scheduler'
        })
        this.infoTitulo = `${titulo} - ${this.cd_menu}`
        this.infoTexto = descricao
        this.infoDialog = true
      } catch (e) {
        console.error('Erro ao carregar info do menu', e)
      }
    },

    formatHora (value) {
      if (!value) return ''
      const d = value instanceof Date ? value : new Date(value)
      if (isNaN(d.getTime())) return ''
      return d.toLocaleTimeString('pt-BR', {
        hour: '2-digit',
        minute: '2-digit'
      })
    },

    async gerarCronograma () {

      const filtrosAtuais = { ...this.filtros }
      console.log('Gerar cronograma - filtros atuais:', filtrosAtuais)

        // Fallback: se cd_cliente estiver nulo mas só existir 1 cliente na lista,
  // assume automaticamente esse cliente
  if (!this.filtros.cd_cliente && this.optionsClientes.length === 1) {
    this.filtros.cd_cliente = this.optionsClientes[0].cd_cliente
    console.log(
      'cd_cliente estava null, usado cliente único da lista:',
      this.filtros.cd_cliente
    )
  }

      const f = this.filtros

  // precisamos pelo menos destes filtros
  console.log('Gerar cronograma - filtros atuais:', f);

  if (!f.cd_cliente || !f.cd_projeto_sistema || !f.cd_consultor ) {
    this.$q && this.$q.notify({
      type: 'warning',
      position: 'center',
      message: 'Informe Projeto, Cliente e Consultor para gerar o cronograma.'
    })
    return
  }

  // usa o dia "central" do calendário (currentDate) como dt_inicial/dt_final
  const d = new Date(this.currentDate)
  d.setHours(0, 0, 0, 0)
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  const dataStr = `${yyyy}-${mm}-${dd}` // "YYYY-MM-DD"

  const payload = [
    {
      ic_json_parametro: 'S',
      cd_empresa: this.cd_empresa,
      cd_usuario: this.cd_usuario,
      cd_parametro: 20,
      cd_cliente: f.cd_cliente,
      cd_projeto: f.cd_projeto_sistema, // a proc espera cd_projeto
      cd_consultor: f.cd_consultor,
      cd_atividade: f.cd_atividade,
      dt_inicial: dataStr,
      dt_final: dataStr
    }
  ]

  try {
    console.log('Payload cronograma (param 20):', payload, this.banco)

    await execProcedure(
      'pr_egis_implantacao_processo_modulo',
      payload,
      { banco: this.banco }
    )

    this.$q && this.$q.notify({
      type: 'positive',
      position: 'center',
      message: 'Cronograma de atividades gerado com sucesso.'
    })

    // recarrega a agenda
    await this.carregarRegistros()
    // restaura filtros
    this.filtros = filtrosAtuais;
    // força atualização dos clientes (se mudou o cd_consultor)
    await this.carregarClientes()
    
  } catch (e) {
    console.error('Erro ao gerar cronograma (param 20):', e.response?.data || e)
    this.$q && this.$q.notify({
      type: 'negative',
      position: 'center',
      message: 'Erro ao gerar cronograma de atividades.'
    })
  }
},

    // Formata Date -> string "YYYY-MM-DDTHH:MM" em HORA LOCAL
        // Date -> "YYYY-MM-DDTHH:MM" (para o input datetime-local)
    formatDateTimeLocal (value) {
      if (!value) return ''

      const d = value instanceof Date ? value : new Date(value)
      if (isNaN(d.getTime())) return ''

      const yyyy = d.getFullYear()
      const mm = String(d.getMonth() + 1).padStart(2, '0')
      const dd = String(d.getDate()).padStart(2, '0')
      const hh = String(d.getHours()).padStart(2, '0')
      const mi = String(d.getMinutes()).padStart(2, '0')

      return `${yyyy}-${mm}-${dd}T${hh}:${mi}`
    },

    // string "YYYY-MM-DDTHH:MM" -> "YYYY-MM-DD HH:MM:SS" (para SQL, hora local)
    inputToSQLDateTime (value) {
      if (!value || typeof value !== 'string') return null

      const parts = value.split('T')
      const datePart = parts[0]
      const timePart = parts[1] || '00:00'

      const [hh = '00', mi = '00'] = timePart.split(':')

      return `${datePart} ${hh}:${mi}:00`
    },

    // string SQL/ISO -> Date em hora local (sem fuso maluco)
    sqlToDateLocal (value) {
      if (!value) return null
      if (value instanceof Date) return value
      if (typeof value !== 'string') return null

      let datePart = ''
      let timePart = ''

      if (value.includes('T')) {
        [datePart, timePart] = value.split('T')
      } else if (value.includes(' ')) {
        [datePart, timePart] = value.split(' ')
      } else {
        const d = new Date(value)
        return isNaN(d.getTime()) ? null : d
      }

      if (!datePart) return null

      const [yyyy, mm, dd] = datePart.split('-').map(Number)
      const [hh = 0, mi = 0, ss = 0] = (timePart || '00:00:00').split(':').map(Number)

      const dt = new Date(yyyy, (mm || 1) - 1, dd || 1, hh || 0, mi || 0, ss || 0)
      return isNaN(dt.getTime()) ? null : dt
    },

    // Date -> "YYYY-MM-DD HH:MM:SS" (para SQL, hora local)
    dateToSQLDateTime (value) {
      if (!value) return null

      const d = value instanceof Date ? value : new Date(value)
      if (isNaN(d.getTime())) return null

      const yyyy = d.getFullYear()
      const mm = String(d.getMonth() + 1).padStart(2, '0')
      const dd = String(d.getDate()).padStart(2, '0')
      const hh = String(d.getHours()).padStart(2, '0')
      const mi = String(d.getMinutes()).padStart(2, '0')
      const ss = String(d.getSeconds()).padStart(2, '0')

      return `${yyyy}-${mm}-${dd} ${hh}:${mi}:${ss}`
    },

    // busca o consultor padrão do usuário (parâmetro 9) 
    async buscarConsultor () {
  try {
    // Usa o mesmo formato de payload do resto (com ic_json_parametro)
    const payload = this.montarPayload(9)

    console.log('Payload param 9 (consultor usuário):', payload, this.banco)

    const dados = await execProcedure(
      'pr_egis_implantacao_processo_modulo',
      payload,
      { banco: this.banco }
    )

    const lista = this.normalizarRetorno(dados, 'consultorUsuario')
    console.log('Retorno param 9:', lista)

    if (lista && lista.length) {
      const row = lista[0]

      // cobre tanto cd_consultor quanto CD_CONSULTOR
      const cd = row.cd_consultor || row.CD_CONSULTOR

      if (cd && Number(cd) !== 0) {
        // seta o filtro de consultor
        this.filtros.cd_consultor = cd
        console.log('Consultor padrão aplicado:', cd)
      }
    }
  } catch (e) {
    console.error('Erro ao buscar consultor padrão (param 9):', e)
    // não bloqueia a tela, só loga o erro
  }
},

    async carregarTituloMenu () {
      try {
        if (!this.cd_menu) return
        const { titulo } = await getInfoDoMenu(this.cd_menu, {
          tituloFallback: localStorage.nm_menu_titulo || 'Scheduler Dinâmico'
        })
        this.tituloMenu = titulo
      } catch (e) {
        console.error('Erro ao carregar título do menu', e)
        this.tituloMenu = localStorage.nm_menu_titulo || 'Scheduler Dinâmico';
      }
    },

    normalizarRetorno (dados, contexto = '') {
    // Só pra debug se quiser ver no console
    // console.log('RETORNO SQL ->', contexto, dados)

    if (!dados) return []

    if (Array.isArray(dados)) {
      return dados
    }

    if (Array.isArray(dados.recordset)) {
      return dados.recordset
    }

    if (Array.isArray(dados.recordsets?.[0])) {
      return dados.recordsets[0]
    }

    if (Array.isArray(dados.data)) {
      return dados.data
    }

    // se algum backend embrulhar em { rows: [...] } ou algo parecido
    if (Array.isArray(dados.rows)) {
      return dados.rows
    }

    // fallback: se vier um objeto "simples", devolve como array de 1
    return [dados]
    },

    montarPayload (cd_parametro, extras = {}) {
      const hoje = new Date()
      const ano = hoje.getFullYear()
      const mes = hoje.getMonth() // 0-11
      const dtIni = new Date(ano, mes, 1)
      const dtFim = new Date(ano, mes + 1, 0)

      const dt_inicial = dtIni.toISOString().substring(0, 10)
      const dt_final = dtFim.toISOString().substring(0, 10)

      return [
         {ic_json_parametro: 'S',
          cd_empresa: this.cd_empresa,
          cd_usuario: this.cd_usuario,
          cd_parametro,
          dt_inicial,
          dt_final,
          ...extras
        }
      ]
    },

    async carregarTudo () {
      try {
        await Promise.all([
          this.carregarClientes(),
          this.carregarConsultores(),
          this.carregarProjetos(),
          this.carregarEtapas(),
          this.carregarAtividades(),
          this.carregarRegistros()
        ])
      } catch (e) {
        console.error('Erro ao carregar dados do scheduler', e)
        this.$q && this.$q.notify({
          type: 'negative',
          position: 'center',    // <-- aqui
          message: 'Erro ao carregar dados do scheduler'
        })
      }
    },

    async carregarConsultores () {
      const payload = this.montarPayload(1);

      console.log('Payload consultores:', payload, this.banco);

      const dados = await execProcedure('pr_egis_implantacao_processo_modulo', payload, {
        banco: this.banco
      })
      console.log('Dados consultores:', dados);
      //this.consultores = this.normalizarRetorno(dados, 'consultores')
      this.consultores = Array.isArray(dados) ? dados : (dados.recordset || [])
    },

async carregarClientes () {
  try {
    const extras = {
      cd_consultor: this.filtros.cd_consultor || 0,
      cd_projeto_sistema: this.filtros.cd_projeto_sistema || 0
    }

    const payload = this.montarPayload(10, extras)
    const dados = await execProcedure(
      'pr_egis_implantacao_processo_modulo',
      payload,
      { banco: this.banco }
    )

    const lista = this.normalizarRetorno(dados, 'clientes')
    console.log('Clientes carregados (param 10):', lista)

    // Salva a lista
    this.clientes = lista.map(c => ({
      cd_cliente: c.cd_cliente,
      nm_fantasia_cliente: c.nm_fantasia_cliente 
    }))

    

  } catch (e) {
    console.error('Erro ao carregar clientes', e)
    this.$q && this.$q.notify({
      type: 'negative',
      position: 'center',
      message: 'Erro ao carregar clientes'
    })
  }
},

    async carregarProjetos () {
      const payload = this.montarPayload(2)
      const dados = await execProcedure('pr_egis_implantacao_processo_modulo', payload, {
        banco: this.banco
      })
      this.projetos = Array.isArray(dados) ? dados : (dados.recordset || [])
    },

    async carregarEtapas () {
      const payload = this.montarPayload(3)
      const dados = await execProcedure('pr_egis_implantacao_processo_modulo', payload, {
        banco: this.banco
      })
      console.log('Dados etapas:', dados);
      this.etapas = Array.isArray(dados) ? dados : (dados.recordset || [])
    },

    async carregarAtividades () {
      const payload = this.montarPayload(4)
      const dados = await execProcedure('pr_egis_implantacao_processo_modulo', payload, {
        banco: this.banco
      })
      this.atividades = Array.isArray(dados) ? dados : (dados.recordset || [])
    },

    async carregarRegistros () {
      const payload = this.montarPayload(5)
      console.log('Payload registros:', payload, this.banco);
      const dados = await execProcedure('pr_egis_implantacao_processo_modulo', payload, {
        banco: this.banco
      })
      const lista = Array.isArray(dados) ? dados : (dados.recordset || [])
      this.registros = lista
      this.totalRegistros = lista.length
      console.log('Registros carregados:', this.registros);

     // força o calendário a ir para a data do primeiro compromisso
     if (this.appointments.length > 0 && this.appointments[0].startDate) {
        this.currentDate = this.appointments[0].startDate
        console.log('currentDate ajustado para:', this.currentDate)
     }

    },

    // --------- CRUD ----------

    abrirDialogInclusao (dataCell) {
      this.modoEdicao = 'I'
      const inicio = dataCell ? new Date(dataCell) : new Date()
      const fim = new Date(inicio.getTime() + 60 * 60 * 1000)

      //const inicio = this.sqlToLocalDate(registro.dt_inicio_atividade)
      //const fim    = this.sqlToLocalDate(registro.dt_final_atividade)

      this.atividadeForm = {
        cd_registro_atividade: null,
        ds_registro_atividade: '',
        cd_projeto_sistema: this.filtros.cd_projeto_sistema || null,
        cd_cliente: this.filtros.cd_cliente || null,
        cd_consultor: this.filtros.cd_consultor || null,
        cd_atividade: this.filtros.cd_atividade || null,
        dt_inicio_atividade: this.formatDateTimeLocal(inicio),
        dt_final_atividade: this.formatDateTimeLocal(fim)
      }
      this.dlgAtividade = true
    },

    abrirDialogEdicao (registro) {
      this.modoEdicao = 'A'

      const inicio = this.sqlToLocalDate(registro.dt_inicio_atividade)
      const fim    = this.sqlToLocalDate(registro.dt_final_atividade)


      this.atividadeForm = {
        cd_registro_atividade: registro.cd_registro_atividade,
        ds_registro_atividade: registro.ds_registro_atividade || '',
        cd_projeto_sistema: registro.cd_projeto_sistema,
        cd_cliente: registro.cd_cliente,
        cd_consultor: registro.cd_consultor,
        cd_atividade: registro.cd_atividade,
        dt_inicio_atividade: this.formatDateTimeLocal(inicio),
        dt_final_atividade: this.formatDateTimeLocal(fim) 
      }
      this.dlgAtividade = true
    },

    // Date / string "YYYY-MM-DDTHH:MM" -> "YYYY-MM-DD HH:MM:SS" (hora local)
    localDateToSQL (value) {
      if (!value) return null

      const dt = value instanceof Date ? value : new Date(value)
      if (isNaN(dt.getTime())) return null

      const yyyy = dt.getFullYear()
      const mm = String(dt.getMonth() + 1).padStart(2, '0')
      const dd = String(dt.getDate()).padStart(2, '0')
      const hh = String(dt.getHours()).padStart(2, '0')
      const mi = String(dt.getMinutes()).padStart(2, '0')
      const ss = String(dt.getSeconds()).padStart(2, '0')

      // sem UTC
      return `${yyyy}-${mm}-${dd} ${hh}:${mi}:${ss}`
    },

    // string SQL/ISO -> Date em hora local
    sqlToLocalDate (value) {
      if (!value) return null
      if (value instanceof Date) return value
      if (typeof value !== 'string') return null

      let datePart = ''
      let timePart = ''

      if (value.includes('T')) {
        [datePart, timePart] = value.split('T')
      } else if (value.includes(' ')) {
        [datePart, timePart] = value.split(' ')
      } else {
        const d = new Date(value)
        return isNaN(d.getTime()) ? null : d
      }

      if (!datePart) return null

      const [yyyy, mm, dd] = datePart.split('-').map(Number)
      const [hh = 0, mi = 0, ss = 0] = (timePart || '').split(':').map(Number)

      const dt = new Date(yyyy, (mm || 1) - 1, dd || 1, hh || 0, mi || 0, ss || 0)
      return isNaN(dt.getTime()) ? null : dt
    },

    async salvarAtividade () {
      try {
        const f = this.atividadeForm
        const ehInclusao = this.modoEdicao === 'I'
        const cd_parametro = ehInclusao ? 6 : 7 // implementar na procedure

        const payload = [
          { ic_json_parametro: 'S',          
            cd_empresa: this.cd_empresa,
            cd_usuario: this.cd_usuario,
            cd_parametro,
            cd_registro_atividade: f.cd_registro_atividade,
            cd_cliente: f.cd_cliente,
            cd_cliente_sistema: f.cd_cliente,
            cd_projeto_sistema: f.cd_projeto_sistema,
            cd_consultor: f.cd_consultor,
            cd_atividade: f.cd_atividade,
            ds_registro_atividade: f.ds_registro_atividade,
            //dt_inicio_atividade: f.dt_inicio_atividade,
            //dt_final_atividade: f.dt_final_atividade
            dt_inicio_atividade: this.inputToSQLDateTime(f.dt_inicio_atividade),
            dt_final_atividade: this.inputToSQLDateTime(f.dt_final_atividade)

          }
        ]

        await execProcedure('pr_egis_implantacao_processo_modulo', payload, {
          banco: this.banco
        })

        this.dlgAtividade = false
        await this.carregarRegistros()

        this.$q && this.$q.notify({
          type: 'positive',
           position: 'center',    // <-- aqui
          message: 'Atividade salva com sucesso.'
        })
      } catch (e) {
        console.error('Erro ao salvar atividade', e)
        this.$q && this.$q.notify({
          type: 'negative',
           position: 'center',    // <-- aqui
          message: 'Erro ao salvar atividade.'
        })
      }
    },

    async confirmarExcluir () {
      if (!this.atividadeForm.cd_registro_atividade) return
      const ok = window.confirm('Confirma exclusão da atividade?')
      if (!ok) return
      await this.excluirAtividade(this.atividadeForm.cd_registro_atividade)
      this.dlgAtividade = false
    },

    async excluirAtividade (cd_registro_atividade) {
      try {
        const payload = [
          { ic_json_parametro: 'S' ,          
            cd_empresa: this.cd_empresa,
            cd_usuario: this.cd_usuario,
            cd_parametro: 8, // delete – implementar na procedure
            cd_registro_atividade
          }
        ]

        await execProcedure('pr_egis_implantacao_processo_modulo', payload, {
          banco: this.banco
        })
        await this.carregarRegistros()

        this.$q && this.$q.notify({
          type: 'positive',
           position: 'center',    // <-- aqui
          message: 'Atividade excluída.'
        })
      } catch (e) {
        console.error('Erro ao excluir atividade', e)
        this.$q && this.$q.notify({
          type: 'negative',
           position: 'center',    // <-- aqui
          message: 'Erro ao excluir atividade.'
        })
      }
    },

    // -------- eventos do Scheduler ---------

    onAppointmentDblClick (e) {
      const app = e.appointmentData
      if (app && app._raw && app._raw.cd_registro_atividade) {
        e.cancel = true // cancela o form padrão
        this.abrirDialogEdicao(app._raw)
      }
    },

    async onAppointmentUpdating (e) {
      const novo = e.newData
      const antigo = e.oldData

      const registro = this.registros.find(
        r => r.cd_registro_atividade === antigo.id
      )
      if (!registro) return

      const start = novo.startDate || antigo.startDate
      const end = novo.endDate || antigo.endDate

      const cd_consultor = novo.cd_consultor || antigo.cd_consultor
      const cd_projeto_sistema = novo.cd_projeto_sistema || antigo.cd_projeto_sistema

      const payload = [
        { ic_json_parametro: 'S',        
          cd_empresa: this.cd_empresa,
          cd_usuario: this.cd_usuario,
          cd_parametro: 7, // update
          cd_registro_atividade: registro.cd_registro_atividade,
          cd_cliente: registro.cd_cliente,
          cd_projeto_sistema,
          cd_consultor,
          cd_atividade: registro.cd_atividade,
          ds_registro_atividade: registro.ds_registro_atividade,
          dt_inicio_atividade: start.toISOString(),
          dt_final_atividade: end.toISOString()
        }
      ]

      try {
        await execProcedure('pr_egis_implantacao_processo_modulo', payload, {
          banco: this.banco
        })
        await this.carregarRegistros()
      } catch (e2) {
        console.error('Erro ao mover atividade', e2)
        e.cancel = true
      }
    },

    async onAppointmentDeleting (e) {
      const app = e.appointmentData
      if (!app || !app._raw) return
      const id = app._raw.cd_registro_atividade
      const ok = window.confirm('Confirma exclusão da atividade?')
      if (!ok) {
        e.cancel = true
        return
      }
      await this.excluirAtividade(id)
    }
  }
}
</script>
