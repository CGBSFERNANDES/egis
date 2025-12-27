<template>
  <div>
        <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />

    <!-- MESMA estrutura de filtros do schedulerDinamico -->
    <div class="q-pa-md">
      <q-card flat class="q-pa-md">

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

  <q-btn
    rounded
    color="deep-purple-7"
    class="q-mt-sm q-ml-sm"
    icon="refresh"
    @click="carregarTudo"
  />

  <!-- Ajuste este método para o que você quiser abrir: cadastro, dialog, etc -->
  <q-btn
    rounded
    color="deep-purple-7"
    class="q-mt-sm q-ml-sm"
    icon="add"
    @click="abrirCadastroAtividade"
  />

  <q-btn
    rounded
    color="deep-purple-7"
    class="q-mt-sm q-ml-sm"
    icon="info"
    @click="onInfoClick"
  />

<!-- AÇÕES À DIREITA (igual scheduler) -->
<div class="col">
</div>

        <!-- Filtros (copiados do schedulerDinamico) -->
        <div class="row q-col-gutter-md">
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
              v-model="filtros.cd_cliente"
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
        </div>
      </q-card>
    </div>

    <!-- Área do Gantt -->
    <div class="gantt-wrapper q-pa-md">
         <DxGantt
  :root-value="0"
  task-title-position="none"
  :editing="{ enabled: false }"
  :validation="{ autoUpdateParentTasks: true }"
  scale-type="days"
  :height="650"
  ref="gantt"
  :tasks="{
    dataSource: tarefasGantt,
    keyExpr: 'id',
    parentIdExpr: 'parentId',
    titleExpr: 'title',
    startExpr: 'start',   // << nomes IGUAIS ao objeto
    endExpr: 'end',
    progressExpr: 'progress'
  }"
  :dependencies="{
    dataSource: dependenciasGantt,
    keyExpr: 'id',
    predecessorIdExpr: 'predecessorId',
    successorIdExpr: 'successorId',
    typeExpr: 'type'
  }"
  :resources="{
    dataSource: recursosGantt,
    keyExpr: 'id',
    textExpr: 'text'
  }"
  :resource-assignments="{
    dataSource: atribuicoesGantt,
    keyExpr: 'id',
    taskIdExpr: 'taskId',
    resourceIdExpr: 'resourceId'
  }"
  :task-list-width="450"
    
>
 <dx-toolbar>
    <dx-item name="undo" />
    <dx-item name="redo" />
    <dx-item name="separator" />
    <dx-item name="zoomIn" />
    <dx-item name="zoomOut" />
    <dx-item name="separator" />
    <dx-item name="collapseAll" />
    <dx-item name="expandAll" />

  </dx-toolbar>
  
  <DxColumn data-field="title" caption="Atividade" />
  <DxColumn data-field="start" caption="Início" />
  <DxColumn data-field="end" caption="Fim" />
  <DxColumn data-field="progress" caption="% Conclusão" />

</DxGantt>

    </div>
  </div>
</template>


<script>
import {
  DxGantt,
  DxTasks,
  DxDependencies,
  DxResources,
  DxResourceAssignments,
  DxToolbar,
  DxToolbarItem,
  DxItem,
  DxColumn,
  DxGanttToolbarItem
} from 'devextreme-vue/gantt';

import { DxScrollView } from 'devextreme-vue';
import { DxDrawer, DxDrawerItem } from 'devextreme-vue/drawer';

import { execProcedure, getInfoDoMenu } from '@/services'


function fixDate(dateStr) {
  if (!dateStr) return null;
  return new Date(dateStr.replace("T", " ") + "Z");
}


export default {
  name: 'AgendaGanttDinamica',
  components: {
     DxGantt,
     DxTasks,
     DxDependencies,
     DxResources,
     DxResourceAssignments,
     DxToolbar,
     DxToolbarItem,
     DxColumn,
     DxDrawer,
     DxScrollView,
     DxItem,
     DxDrawerItem,
     DxGanttToolbarItem,
  },
  data () {
    return {
      // infos de menu/título
         // topo / menu
      tituloMenu: localStorage.nm_menu_titulo || "Agenda",
      cd_menu: Number(localStorage.cd_menu || 0),
      infoDialog: false,
      infoTitulo: '',
      infoTexto: '',

      tituloPagina: '',
      subTituloPagina: '',

      // contexto
      cd_empresa: null,
      cd_usuario: null,
      banco: null,

      // filtros
      filtros: {
        cd_projeto_sistema: null,
        cd_cliente: null,
        cd_consultor: null,
        cd_atividade: null
      },

      // dados vindos das procedures
      projetos: [],
      clientes: [],
      consultores: [],
      atividades: [],
      tarefas: [],

      totalTarefas: 0,

      // Gantt
      scaleType: 'weeks', // 'hours' | 'days' | 'weeks' | 'months'
      tarefasGantt: [], // <- aqui ficam as linhas retornadas da procedure
      recursosGantt: [],
      atribuicoesGantt: [],
      dependenciasGantt: [],
      totalRegistros: 0,
      
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
      return this.clientes
    },

    // Configuração do dataSource de tarefas para o Gantt
    ganttTasksConfig () {
      return {
        dataSource: this.tarefasGantt,
        keyExpr: 'idKey',
        parentIdExpr: 'parentId',
        startExpr: 'start',
        endExpr: 'end',
        progressExpr: 'progress',
        titleExpr: 'title'
      }
    },

    // Configuração da toolbar do Gantt
    ganttToolbarConfig () {
      return {
        items: [
          'undo',
          'redo',
          'separator',
          'collapseAll',
          'expandAll',
          'separator',
          'zoomIn',
          'zoomOut'
        ]
      }
    }
  },

  async created () {
    this.inicializarContexto()
    await this.carregarTituloMenu()
    await this.carregarTudo()
  },

  methods: {
    // pega info de usuário / empresa do localStorage (ajuste se usar outro lugar)
    inicializarContexto () {
      try {
        const egis = JSON.parse(localStorage.getItem('egis_usuario') || '{}')
        this.cd_empresa = egis.cd_empresa
        this.cd_usuario = egis.cd_usuario
        this.banco = egis.banco
        this.cd_menu = this.$route && this.$route.meta && this.$route.meta.cd_menu
      } catch (e) {
        console.error('Erro ao inicializar contexto', e)
      }
    },

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

abrirCadastroAtividade () {
  // aqui você decide:
  // - abrir um outro menu via this.$router.push(...)
  // - ou abrir um QDialog, se você quiser copiar o fluxo do scheduler
  console.log('Clique em cadastrar atividade - implementar ação aqui')
},

    async carregarTituloMenu () {
      try {
        if (!this.cd_menu) return
        const info = await getInfoDoMenu(this.cd_menu)
        if (info) {
          this.tituloPagina = info.nm_menu || this.tituloPagina
          this.subTituloPagina = info.ds_menu || ''
        }
      } catch (e) {
        console.error('Erro ao carregar título do menu', e)
      }
    },

    // helper para montar payload padrão
    montarPayload (cd_parametro, extras = {}) {
      const hoje = new Date()
      const yyyy = hoje.getFullYear()
      const mm = String(hoje.getMonth() + 1).padStart(2, '0')
      const dd = String(hoje.getDate()).padStart(2, '0')

      const dt_inicial = `${yyyy}-${mm}-01`
      const dt_final = `${yyyy}-${mm}-${dd}`

      return [
        {
          ic_json_parametro: 'S',
          cd_empresa: this.cd_empresa,
          cd_usuario: this.cd_usuario,
          cd_parametro,
          dt_inicial,
          dt_final,
          cd_projeto_sistema: this.filtros.cd_projeto_sistema,
          cd_cliente: this.filtros.cd_cliente,
          cd_consultor: this.filtros.cd_consultor,
          cd_atividade: this.filtros.cd_atividade,
          ...extras
        }
      ]
    },

   normalizarRetorno (dados) {
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

  if (Array.isArray(dados.rows)) {
    return dados.rows
  }

  // fallback: se vier um objeto simples, devolve como array de 1
  return [dados]
},

    async carregarConsultores () {
      try {
        const payload = this.montarPayload(1) // ajuste o parâmetro se for outro
        const dados = await execProcedure(
          'pr_egis_implantacao_processo_modulo',
          payload,
          { banco: this.banco }
        )
        this.consultores = this.normalizarRetorno(dados)
      } catch (e) {
        console.error('Erro ao carregar consultores', e)
      }
    },

    async carregarProjetos () {
      try {
        const payload = this.montarPayload(2)
        const dados = await execProcedure(
          'pr_egis_implantacao_processo_modulo',
          payload,
          { banco: this.banco }
        )
        this.projetos = this.normalizarRetorno(dados)
      } catch (e) {
        console.error('Erro ao carregar projetos', e)
      }
    },

    async carregarAtividades () {
      try {
        const payload = this.montarPayload(4)
        const dados = await execProcedure(
          'pr_egis_implantacao_processo_modulo',
          payload,
          { banco: this.banco }
        )
        this.atividades = this.normalizarRetorno(dados)
      } catch (e) {
        console.error('Erro ao carregar atividades', e)
      }
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
        const lista = this.normalizarRetorno(dados)
        this.clientes = lista.map(c => ({
          cd_cliente: c.cd_cliente || c.CD_CLIENTE,
          nm_fantasia_cliente:
            c.nm_fantasia_cliente ||
            c.NM_FANTASIA_CLIENTE ||
            c.nm_cliente ||
            c.NM_CLIENTE
        }))
      } catch (e) {
        console.error('Erro ao carregar clientes', e)
      }
    },

parseDate(valor) {
  if (!valor) return null

  // Se já for Date, devolve
  if (valor instanceof Date) return valor

  // Se vier como "new Date('2025-11-25T00:00:00')", extrai só o conteúdo
  let texto = String(valor).trim()
  const match = texto.match(/new Date\(['"](.+)['"]\)/)
  if (match) {
    texto = match[1]
  }

  // Troca espaço por 'T'
  texto = texto.replace(' ', 'T')

  // Remove frações de segundo
  texto = texto.split('.')[0]

  // Se não tiver fuso horário, adiciona 'Z'
  if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$/.test(texto)) {
    texto += 'Z'
  }

  const dt = new Date(texto)

  if (isNaN(dt.getTime())) {
    console.warn('Data de Gantt inválida:', valor)
    return null
  }

  return dt
},

async carregarParteGantt(cd_parametro) {

    const payload = [
      {
        cd_parametro,       // 1=tarefas, 2=dependências, 3=recursos, 4=assignments
        cd_modelo: this.filtros.cd_modelo, // ou o campo que você já usa
        ic_json_parametro: 'S',
        cd_empresa: localStorage.cd_empresa || 0,
        cd_usuario: localStorage.cd_usuario || 0,
        cd_projeto_sistema: this.projetoSelecionado?.cd_projeto || this.filtros.cd_projeto_sistema || 0,
        cd_cliente: this.clienteSelecionado?.cd_cliente || this.filtros.cd_cliente || 0,
        cd_consultor: this.consultorSelecionado?.cd_consultor || this.filtros.cd_consultor || 0,
        cd_atividade: this.atividadeSelecionada?.cd_atividade_projeto || this.filtros.cd_atividade || 0
        
      }
    ];

    const dados  = await execProcedure('pr_egis_agenda_gantt_dinamica',
                     payload,
                     { banco: this.banco }
    );
    // garante array:
    //return Array.isArray(dados) ? data : (data?.recordset || data || []);
      const lista = this.normalizarRetorno(dados)
      console.log('Retorno Gantt (param', cd_parametro, '):', lista)

  return lista

  },

    async carregarTarefasGantt () {
      try {
        //const payload = this.montarPayload(1) // se a sua procedure usar outro param, ajuste aqui
       
        
        const dados = await this.carregarParteGantt(1);
        
        let lista = this.normalizarRetorno(dados);
        console.log('Dados brutos recebidos para Gantt:', lista)
        //this.tarefasGantt = lista;
        
        // Mapeia os dados para o formato esperado pelo Gantt
        this.tarefasGantt = lista.map((t) => {
  const tarefa = {
    idKey: t.idKey,
    id: t.id,
    parentId: t.parentId,
    title: t.title,
    start: this.parseDate(t.start),
    end: this.parseDate(t.end),
    progress: Number(t.progress || 0)
  }

  console.log('Tarefa Gantt mapeada:', tarefa)
  return tarefa
})

      //  console.log('Tarefas Gantt finais:', this.tarefasGantt);

    // Início do mapeamento
    console.log('Dados brutos para Gantt:', lista)

   
    this.tarefas = this.tarefasGantt;
    this.totalRegistros = this.tarefas.length;

        // 2 - dependências
    const rowsDeps = await this.carregarParteGantt(2);
    this.dependenciasGantt = rowsDeps.map((r, idx) => ({
      id: r.id || r.ID_DEPENDENCIA || idx + 1,
      predecessorId: r.predecessorId ?? r.ID_TAREFA_ORIGEM,
      successorId:   r.successorId   ?? r.ID_TAREFA_DESTINO,
      type: Number(r.tipo ?? r.TIPO ?? 0)   // 0=FS,1=SS,2=FF,3=SF
    }));

     // 3 - recursos
    const rowsRecursos = await this.carregarParteGantt(3);
    this.recursosGantt = rowsRecursos.map((r, idx) => ({
      id: r.id || r.ID_RECURSO || idx + 1,
      text: r.text || r.NM_RECURSO || r.NOME
    }));

    // 4 - assignments
    const rowsAssig = await this.carregarParteGantt(4);
    this.atribuicoesGantt = rowsAssig.map((r, idx) => ({
      id: r.id || r.ID_ATRIBUICAO || idx + 1,
      taskId: r.taskId ?? r.ID_TAREFA,
      resourceId: r.resourceId ?? r.ID_RECURSO
    }));

     console.log('Tarefas Gantt:', this.tarefasGantt);
    console.log('Dependências Gantt:', this.dependenciasGantt);
    console.log('Recursos Gantt:', this.recursosGantt);
    console.log('Assignments Gantt:', this.atribuicoesGantt);

    //this.$forceUpdate();
    //this.$nextTick(() => {
    //  console.log('Gantt atualizado com tarefas:', this.tarefas)
    //})
    // Fim do mapeamento

  } catch (e) {
    console.error('Erro ao carregar tarefas do Gantt', e)
    this.$q && this.$q.notify({
      type: 'negative',
      position: 'center',
      message: 'Erro ao carregar dados da Agenda Gantt'
    })
  }

    },

    async carregarTudo () {
      try {
        await Promise.all([
          this.carregarConsultores(),
          this.carregarProjetos(),
          this.carregarAtividades(),
          this.carregarClientes(),
          this.carregarTarefasGantt()
        ])
        //await this.carregarTarefasGantt()
      } catch (e) {
        console.error('Erro ao carregar dados da Agenda Gantt', e)
        this.$q && this.$q.notify({
          type: 'negative',
          position: 'center',
          message: 'Erro ao carregar dados da Agenda Gantt'
        })
      }
    },

    mostrarInfo () {
      this.$q && this.$q.dialog({
        title: 'Agenda Gantt',
        message: 'Visualização de atividades do projeto em formato Gantt.'
      })
    },

    formatDate (value) {
      if (!value) return ''
      const d = value instanceof Date ? value : new Date(value)
      if (isNaN(d.getTime())) return ''
      return d.toLocaleString('pt-BR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
  }
}
</script>

<style scoped>
/* ajustes visuais, se precisar */
/* wrapper onde está o DxGantt */
.gantt-wrapper {
  height: 650px;
}

/* aumenta a altura das linhas da árvore à esquerda */
.gantt-wrapper ::v-deep .dx-gantt .dx-treelist .dx-row {
  height: 32px;
}

/* dá espaço vertical entre as barras do Gantt */
.gantt-wrapper ::v-deep .dx-gantt .dx-gantt-task-wrapper {
  margin-top: 6px;
  margin-bottom: 6px;
}

/* opcional: deixar a barra um pouco mais “gordinha” */
.gantt-wrapper ::v-deep .dx-gantt .dx-gantt-task {
  height: 14px;
}
</style>

