<template>
  <div class="apontamento-producao container-fluid">

    <!-- TÍTULO DO MENU + (o resto fica no toolbar do DevExtreme) -->
    <!-- <h2 class="mb-3 titulo-grid">
      Apontamento de Produção
    </h2> -->

    <div class="row items-center mb-3">
      <transition name="slide-fade">
        <!-- título + seta + badge -->
        <!-- <h2 class="content-block col-8" v-show="tituloMenu || title"> -->
        <div class="w-full topbar">
          <!-- seta voltar -->
          <q-btn flat round dense icon="arrow_back" class="q-mr-sm" aria-label="Voltar" @click="onVoltar" />
          <h2 class="titulo-grid" style="display: inline; margin-bottom: 0;">Apontamento de Produção</h2>

          <!-- badge com total de registros -->

          <!-- TODO: checar se é necessário -->
          <!-- <q-badge v-if="(qt_registro || recordCount) >= 0" align="middle" rounded color="red"
            :label="qt_registro || recordCount" class="q-ml-sm bg-form" /> -->
          <!-- TODO: checar se é necessário -->
          <!-- <q-btn v-if="cd_tabela > 0" rounded color="deep-purple-7"
            :class="['', 'q-ml-sm', cd_tabela != 0 ? 'fo-margin' : '']" icon="add"
            @click="abrirFormEspecial({ modo: 'I', registro: {} })" /> -->

          <q-btn rounded color="deep-purple-7" :class="['', 'q-ml-sm']" icon="far fa-file-excel"
            @click="onExportarExcel" />
          <q-btn rounded color="deep-purple-7" class=" q-ml-sm" icon="picture_as_pdf" @click="exportarPDF" />

          <q-btn rounded color="deep-purple-7" class=" q-ml-sm" icon="description" @click="abrirRelatorio" />
          <q-btn rounded color="deep-purple-7" class=" q-ml-sm" icon="view_list" @click="dlgMapaAtributos = true" />

          <!-- TODO: checar se é necessário -->
          <!-- Botão de processos (3 pontinhos) -->
          <!-- <q-btn v-if="cd_menu_processo > 0" rounded color="deep-purple-7" class=" q-ml-sm" icon="more_horiz"
            @click="abrirMenuProcessos" /> -->
          <q-btn rounded color="deep-purple-7" class=" q-ml-sm" icon="info" @click="onInfoClick && onInfoClick()" />
          <!-- <q-chip v-if="(cdMenu || cd_menu) && (1 == 1)" rounded color="deep-purple-7" class=" q-ml-auto margin-menu"
            size="16px" text-color="white" :label="`${cdMenu || cd_menu}`" /> -->
        </div>
      </transition>

      <!-- Ações à direita (como no seu topo) -->

      <div class="col">

        <!-- Modal -->

        <q-dialog v-model="infoDialog">
          <q-card style="min-width: 640px">
            <q-card-section class="text-h6">
              <q-icon name="info" color="deep-orange-9" size="48px" class="q-mr-sm" />
              {{ infoTitulo }}</q-card-section>
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
    </div>

    <!--  -->
    <!-- FILTRO: Nº ORDEM DE PRODUÇÃO -->
    <div class="card-resumo mb-2">
      <div class="row align-items-end">
        <div class="col-md-3 col-sm-4">
          <label for="numero-op">Nº Ordem de Produção</label>
          <input id="numero-op" v-model.number="numeroOP" type="number" min="0" class="form-control"
            placeholder="Informe o número da OP" @keyup.enter="consultarPorOP">
        </div>

        <div class="col-md-2 col-sm-3 mt-3 mt-sm-0">
          <!-- <button
            class="btn btn-primary w-100"
            @click="consultarPorOP"
          >
            Buscar
          </button> -->
          <q-btn color="deep-orange" label="Buscar" @click="consultarPorOP" />
        </div>

        <div class="col mt-3 mt-sm-0 text-right">
          <small class="text-muted" v-if="infoProcesso">
            Ordem: <strong>{{ infoProcesso.cd_processo }}</strong> ·
            Cliente: <strong>{{ infoProcesso.nm_fantasia_cliente }}</strong> ·
            Produto: <strong>{{ infoProcesso.nm_produto }}</strong>
          </small>
        </div>
      </div>
    </div>

    <!-- RESUMO DO PROCESSO (ABAIXO DO FILTRO, IGUAL FORM WORD) -->
    <div v-if="infoProcesso" class="card-resumo mb-2">
      <div class="resumo-grid">
        <div>
          <label>Cliente</label>
          <div>{{ infoProcesso.nm_fantasia_cliente || '-' }}</div>
        </div>
        <div>
          <label>Produto</label>
          <div>{{ infoProcesso.nm_produto || '-' }}</div>
        </div>
        <div>
          <label>Unid.</label>
          <div>{{ infoProcesso.sg_unidade_medida || '-' }}</div>
        </div>
        <div>
          <label>Qtde Planejada</label>
          <div>{{ infoProcesso.qt_planejada_processo || 0 }}</div>
        </div>
        <div>
          <label>Qtde Produzida</label>
          <div>{{ infoProcesso.qt_produzido_processo || 0 }}</div>
        </div>
        <div>
          <label>Status Geral</label>
          <div>{{ statusGeral }}</div>
        </div>
      </div>
    </div>

    <!-- MENSAGENS -->
    <div v-if="erro" class="alert alert-danger py-2">
      {{ erro }}
    </div>

    <!-- LOADING -->
    <div v-if="carregando" class="alert alert-info py-2">
      Carregando dados de produção...
    </div>
    <!-- LEGENDA DE CORES (igual documento) -->
    <div v-if="linhas.length" class="legenda-cores mt-2">
      <span>Legenda:</span>
      <span class="badge legenda linha-aguardando">Aguardando Início</span>
      <span class="badge legenda linha-producao">Produção</span>
      <span class="badge legenda linha-finalizada">Finalizado</span>
      <span class="badge legenda linha-cancelada">Cancelada</span>
    </div>
    <!-- GRID DEVEXTREME -->
    <DxDataGrid ref="dxGrid" :data-source="linhas" key-expr="cd_item_processo" :column-auto-width="true"
      :show-borders="true" :row-alternation-enabled="false" :hover-state-enabled="true" :focused-row-enabled="true"
      :focused-row-index="0" @row-prepared="rowPrepared">
      <DxSearchPanel :visible="true" :width="250" placeholder="Procurar..." />
      <DxGroupPanel :visible="true" empty-panel-text="📌 Arraste um cabeçalho aqui para agrupar" />
      <DxGrouping :auto-expand-all="false" />
      <DxPaging :page-size="20" />
      <DxPager :show-page-size-selector="true" :allowed-page-sizes="[10,20,50]" :show-info="true"
        :show-navigation-buttons="true" />

      <!-- Botões -->
      <DxColumn caption="Ações" type="buttons" width="140" :buttons="botaoAcao" />

      <!-- Colunas -->
      <DxColumn data-field="nm_operacao" caption="Operação" width="220" />
      <DxColumn data-field="nm_maquina" caption="Máquina" width="220" />
      <DxColumn data-field="qt_tempo_total" caption="Tempo (h)" width="120" alignment="right" />
      <DxColumn data-field="qt_produzido_processo" caption="Produzida" width="120" alignment="right" />
      <DxColumn data-field="hr_inicio_apontamento" caption="Início" width="90" />
      <DxColumn data-field="hr_fim_apontamento" caption="Fim" width="90" />

    </DxDataGrid>

    <!-- LEGENDA DE CORES (igual documento) -->
    <!-- <div v-if="linhas.length" class="legenda-cores mt-2">
      <span class="badge legenda linha-aguardando">Aguardando Início</span>
      <span class="badge legenda linha-producao">Produção</span>
      <span class="badge legenda linha-finalizada">Finalizado</span>
      <span class="badge legenda linha-cancelada">Cancelada</span>
    </div> -->

    <div v-if="!carregando && numeroOP && !linhas.length" class="alert alert-warning mt-2 py-2">
      Nenhuma operação encontrada para a OP {{ numeroOP }}.
    </div>

    <!-- Dialog de editar item -->
    <q-dialog v-model="isDialogEditOpen">
      <q-card style="min-width: 640px">
        <q-card-section class="text-h6">
          <!-- <q-icon name="info" color="deep-orange-9" size="48px" class="q-mr-sm" /> -->
          <!-- {{ infoTitulo }} -->
          Editar Item de Produção
        </q-card-section>
        <q-separator />
        <q-card-section class="text-body1">

          <!-- {{ infoTexto }} -->
          <form @submit.prevent="saveEdit">

            <q-select v-model="editItemForm.cd_maquina" :options="maquina" label="Máquina"
              option-label="nm_fantasia_maquina" option-value="cd_maquina" emit-value map-options />

            <q-select v-model="editItemForm.cd_operacao" :options="operacao" label="Operação"
              option-label="nm_fantasia_operacao" option-value="cd_operacao" emit-value map-options />

            <q-select v-model="editItemForm.cd_operador" :options="operador" label="Operador"
              option-label="nm_fantasia_operador" option-value="cd_operador" emit-value map-options />


            <q-input class="q-mt-xs" v-model.number="editItemForm.qt_produzido_processo" label="Quantidade de produção"
              filled :input-class="'leitura-azul'" />

          </form>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="primary" v-close-popup />
          <q-btn flat label="Salvar" color="deep-orange-9" type="submit" @click="saveEdit" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
/* global $, DevExpress, ExcelJS, saveAs */
/**
 * Componente: apontamentoProducao.vue
 *
 * Ajustes pedidos:
 * 1) Título e botões (Excel / PDF / Relatório) via toolbar do DevExtreme,
 *    seguindo o padrão do unicoFormEspecial/grid.service.js 
 * 2) Input para digitar o Nº da Ordem de Produção (cd_processo)
 * 3) Grid DevExtreme com layout padrão da aplicação
 */

import { execProcedure, getInfoDoMenu, exportarParaExcel } from "@/services"; // usa exec.service + index.js 

import DxDataGrid, {
  DxColumn,
  DxGrouping,
  DxGroupPanel,
  DxSearchPanel,
  DxPager,
  DxPaging
} from "devextreme-vue/data-grid";

export default {
  name: 'ApontamentoProducao',
    components: {
    DxDataGrid,
    DxColumn,
    DxGrouping,
    DxGroupPanel,
    DxSearchPanel,
    DxPager,
    DxPaging
  },

  props: {
    /**
     * Banco (x-banco) opcional. Se não vier, usa session/localStorage.
     */
    banco: {
      type: String,
      default: ''
    }
  },

  data () {
    return {
      numeroOP: null,           // digitado na tela → cd_processo
      cdProcessoAtual: null,    // usado no payload
      linhas: [],
      carregando: false,
      erro: '',
      cdUsuario: 0,
      bancoInterno: '',
      gridId: 'grid-apontamento-producao',
      gridInstance: null,

      infoDialog: false,
      cd_menu: localStorage.cd_menu,
      isDialogEditOpen: false,

      // Estado do modal de edição
      editItem: {
        nm_maquina: "",
        nm_operacao: "",
        
      },
      editItemForm: {
        nm_maquina: "",
        nm_operacao: "",
        qt_produzido_processo: 0,

        //selects do formulário de edição
        maquina: null,
        operacao: null,
        operador: null
      },
      // editSelect: {
        // maquina: null,
        // operacao: null,
        // operador: null
      // },
      operador: [],
      maquina: [],
      operacao: [],
      infoTitulo: "",
      infoTexto: ""
    };
  },

  computed: {

    botaoAcao () {
    return [
      // TODO: implementar edição
      {
        hint: "Editar item de Produção",
        text: "Editar",
        icon: "edit",
        onClick: (e) => {this.onEditClick(e.row.data);},        
        visible: e => this.podeFinalizar(e.row.data)       
      },
      {
        hint: 'Início de Produção',
        text: 'Iniciar',
        icon: 'video',
        onClick: e => this.onCliqueInicio(e.row.data),
        visible: e => this.podeIniciar(e.row.data)
      // visible: true
      },

      {
        hint: 'Fim de Produção',
        text: 'Finalizar',
        icon: 'check',
        onClick: e => this.onCliqueFim(e.row.data),
        visible: e => this.podeFinalizar(e.row.data)
      }
    ]
  },

    infoProcesso () {
      if (!this.linhas.length) return null
      const row = this.linhas[0]
      return {
        cd_processo: row.cd_processo,
        nm_fantasia_cliente: row.nm_fantasia_cliente,
        nm_produto: row.nm_produto,
        sg_unidade_medida: row.sg_unidade_medida,
        qt_planejada_processo: row.qt_planejada_processo,
        qt_produzido_processo: row.qt_produzido_processo
      }
    },

    statusGeral () {
      if (!this.linhas.length) return '-'
      const todasFinalizadas = this.linhas.every(r => r.hr_fim_apontamento)
      const algumaEmProducao = this.linhas.some(r => r.hr_inicio_apontamento && !r.hr_fim_apontamento)
      const algumaCancelada = this.linhas.some(r => r.dt_cancelamento)

      if (algumaCancelada) return 'Com operações canceladas'
      if (todasFinalizadas) return 'Finalizado'
      if (algumaEmProducao) return 'Em Produção'
      return 'Aguardando Início'
    }
  },

  created () {
    // usuário + banco igual resto do sistema
    const cdUsuario = parseInt(sessionStorage.getItem('cd_usuario') || localStorage.getItem('cd_usuario') || 0)
    this.cdUsuario = isNaN(cdUsuario) ? 0 : cdUsuario

    this.bancoInterno = this.banco ||
      sessionStorage.getItem('nm_banco') ||
      localStorage.getItem('nm_banco') ||
      ''
  },

  mounted () {
    // Se estivermos usando o wrapper `devextreme-vue`, pegue a instância via ref
    this.$nextTick(() => {
      if (this.$refs.dxGrid && this.$refs.dxGrid.instance) {
        this.gridInstance = this.$refs.dxGrid.instance
      }
    })
  },

  methods: {
    /** ------------- PAYLOAD / BACKEND ------------- **/

    montarPayloadConsulta ( parametro = 10 ) {
        //40=Operador
        //50=Maquina
        //60=Operação
      return [
        {
          ic_json_parametro: 'S',
          cd_parametro: parametro, // 10 = consultar processo
          cd_processo: this.cdProcessoAtual,
          cd_usuario: this.cdUsuario || 0
        }
      ]
    },

    //Grava o início ou fim do apontamento

    montarPayloadAcao (acao, row) {
      return [
        {
          ic_json_parametro: 'S',
          cd_parametro: 10, // se depois você separar INICIO/FIM, troca aqui
          acao, // 'INICIO' | 'FIM'
          cd_processo: row.cd_processo,
          cd_item_processo: row.cd_item_processo,
          cd_operacao: row.cd_operacao || 0,          // Modal
          cd_maquina: row.cd_maquina || 0,            // Modal 
          Quantidade: row.qt_produzido_processo || 0, // Modal
          cd_operador: row.cd_operador || 0,          // Modal
          cd_usuario: this.cdUsuario || 0
        }
        
      ]


      //console.log('Payload ação:', payload);

    },

    async consultarPorOP () {
      this.erro = ''
      this.linhas = []

      if (!this.numeroOP || this.numeroOP <= 0) {
        this.erro = 'Informe um número de Ordem de Produção válido.'
        this.atualizarDataSourceGrid()
        return
      }

      this.cdProcessoAtual = this.numeroOP
      await this.carregarDados()
    },

    async carregarDados () {
      if (!this.cdProcessoAtual) return

      this.carregando = true
      this.erro = ''

      try {
        const payload = this.montarPayloadConsulta()
        const data = await execProcedure(
          'pr_egis_pcp_processo_modulo',
          payload,
          { banco: this.bancoInterno }
        )

       console.log('Dados carregados do processo:', data);
             

        this.linhas = Array.isArray(data)
          ? data
          : (data?.recordset || data?.rows || [])

        this.atualizarDataSourceGrid();

        const payloadOperador = this.montarPayloadConsulta(40);

        const dataOperador = await execProcedure(
          "pr_egis_pcp_processo_modulo",
          payloadOperador,
          { banco: this.bancoInterno }
        );

        this.operador = Array.isArray(dataOperador)
          ? dataOperador
          : (dataOperador?.recordset || dataOperador?.rows || []);

        const payloadMaquina = this.montarPayloadConsulta(50);
        const dataMaquina = await execProcedure(
          "pr_egis_pcp_processo_modulo",
          payloadMaquina,
          { banco: this.bancoInterno }
        );

        this.maquina = Array.isArray(dataMaquina)
          ? dataMaquina
          : (dataMaquina?.recordset || dataMaquina?.rows || []);

        const payloadOperacao = this.montarPayloadConsulta(60);
        const dataOperacao = await execProcedure(
          "pr_egis_pcp_processo_modulo",
          payloadOperacao,
          { banco: this.bancoInterno }
        );

        this.operacao = Array.isArray(dataOperacao)
          ? dataOperacao
          : (dataOperacao?.recordset || dataOperacao?.rows || []);
      } catch (err) {
        console.error('Erro ao carregar dados do processo:', err);
        this.erro = 'Erro ao carregar dados de produção.'
        this.linhas = []
        this.atualizarDataSourceGrid();
      } finally {
        this.carregando = false;
      }
    },

    /** ------------- REGRAS DE STATUS ------------- **/

    podeIniciar (row) {
      if (row.dt_cancelamento) return false
      if (row.hr_inicio_apontamento) return false
      return true
    },

    podeFinalizar (row) {
      if (row.dt_cancelamento) return false
      if (!row.hr_inicio_apontamento) return false
      if (row.hr_fim_apontamento) return false
      return true
    },

    rowClass (row) {
      if (row.dt_cancelamento) return 'linha-cancelada'
      if (row.hr_fim_apontamento) return 'linha-finalizada'
      if (row.hr_inicio_apontamento && !row.hr_fim_apontamento) return 'linha-producao'
      return 'linha-aguardando'
    },

    /** ------------- AÇÕES INÍCIO / FIM ------------- **/

    async onCliqueInicio (row) {
      console.log('row', row)
      if (!this.podeIniciar(row)) return
      try {
        this.carregando = true
        const payload = this.montarPayloadAcao('INICIO', row)
        console.log('Payload Início:', payload)
        
        await execProcedure('pr_egis_pcp_processo_modulo', payload, { banco: this.bancoInterno })
        console.log('Início apontado com sucesso.')
        await this.carregarDados()

      } catch (err) {
        console.error('Erro ao apontar início de produção:', err)
        this.erro = 'Erro ao apontar início de produção.'
      } finally {
        this.carregando = false
      }
    },

    async onCliqueFim (row) {
      console.log('Clicou Fim para:', row)
      if (!this.podeFinalizar(row)) return
      try {
        this.carregando = true
        const payload = this.montarPayloadAcao('FIM', row)
        await execProcedure('pr_egis_pcp_processo_modulo', payload, { banco: this.bancoInterno })
        await this.carregarDados();
        // this.grid
      } catch (err) {
        console.error('Erro ao apontar fim de produção:', err)
        this.erro = 'Erro ao apontar fim de produção.'
      } finally {
        this.carregando = false
      }
    },

    /** ------------- GRID DEVEXTREME ------------- **/

    inicializarGridDevExtreme () {
      const self = this
      const gridSelector = `#${this.gridId}`
      const $el = $(gridSelector)

      if (!$el.length) {
        console.warn('⚠️ Container da grid não encontrado:', gridSelector)
        return
      }

      this.gridInstance = $el.dxDataGrid({
        dataSource: this.linhas,
        keyExpr: 'cd_item_processo', // ajuste se precisar
        columnAutoWidth: true,
        showBorders: true,
        rowAlternationEnabled: true,
        hoverStateEnabled: true,
        focusedRowEnabled: true,
        focusedRowIndex: 0,
        paging: { pageSize: 20 },
        pager: {
          showPageSizeSelector: true,
          allowedPageSizes: [10, 20, 50],
          showInfo: true,
          showNavigationButtons: true
        },
        searchPanel: {
          visible: true,
          width: 250,
          placeholder: 'Procurar...'
        },
        grouping: { autoExpandAll: false },
        groupPanel: {
          visible: true,
          allowColumnDragging: true,
          emptyPanelText: '📌 Arraste um cabeçalho aqui para agrupar'
        },
        export: {
          enabled: false,
          allowExportSelectedData: true,
          fileName: 'apontamento_producao'
        },
        columns: [
          {
            dataField: 'nm_operacao',
            caption: 'Operação',
            width: 220,
            cellTemplate: function (container, options) {
              const dados = options.data || {}
              const nome = dados.nm_operacao || '-'
              const grupo = dados.nm_grupo_operacao || ''
              $('<div>').addClass('texto-primario').text(nome).appendTo(container)
              if (grupo) {
                $('<div>').addClass('texto-secundario').text(grupo).appendTo(container)
              }
            }
          },
          {
            dataField: 'nm_maquina',
            caption: 'Máquina / Grupo',
            width: 220,
            cellTemplate: function (container, options) {
              const dados = options.data || {}
              const nome = dados.nm_maquina || dados.nm_grupo_maquina || '-'
              const status = dados.nm_status_maquina || ''
              $('<div>').addClass('texto-primario').text(nome).appendTo(container)
              if (status) {
                $('<div>').addClass('texto-secundario').text(status).appendTo(container)
              }
            }
          },
          {
            dataField: 'qt_tempo_total',
            caption: 'Tempo Estimado (h)',
            alignment: 'right',
            width: 120
          },
          {
            dataField: 'qt_planejada_processo',
            caption: 'Qtd. Planejada',
            alignment: 'right',
            width: 120
          },
          {
            dataField: 'qt_produzido_processo',
            caption: 'Qtd. Produzida',
            alignment: 'right',
            width: 120
          },
          {
            dataField: 'hr_inicio_apontamento',
            caption: 'Início',
            width: 90
          },
          {
            dataField: 'hr_fim_apontamento',
            caption: 'Fim',
            width: 90
          },
          {
            caption: 'Ações',
            type: 'buttons',
            width: 140,
            buttons: [
              {
                hint: 'Início de Produção',
                icon: 'play',
                text: 'Iniciar',
                onClick: function (e) {
                  self.onCliqueInicio(e.row.data)
                },
                visible: function (e) {
                  return self.podeIniciar(e.row.data)
                }
              },
              {
                hint: 'Fim de Produção',
                text: 'Finalizar',
                icon: 'check',
                onClick: function (e) {
                  self.onCliqueFim(e.row.data)
                },
                visible: function (e) {
                  return self.podeFinalizar(e.row.data)
                }
              }
            ]
          }
        ],
        rowPrepared: function (e) {
          if (e.rowType !== 'data') return
          // delegate to the Vue instance handler so the class logic is centralized
          try {
            if (typeof self.rowPrepared === 'function') {
              self.rowPrepared(e)
            }
          } catch (err) {
            // keep a silent fallback but log for debugging
            console.error('rowPrepared delegation error:', err)
          }
        },

        // TOOLBAR igual padrão unicoFormEspecial (Excel / PDF / Relatório)
        toolbar: {
          items: [
            'groupPanel',
            'searchPanel',
            {
              location: 'after',
              widget: 'dxButton',
              options: {
                icon: 'exportxlsx',
                text: 'Excel',
                type: 'default',
                stylingMode: 'contained',
                onClick: () => self.exportarExcel()
              }
            },
            {
              location: 'after',
              widget: 'dxButton',
              options: {
                icon: 'exportpdf',
                text: 'PDF',
                type: 'default',
                stylingMode: 'contained',
                onClick: () => self.exportarPDF()
              }
            },
            {
              location: 'after',
              widget: 'dxButton',
              options: {
                icon: 'paste',
                text: 'RELATÓRIO',
                type: 'default',
                stylingMode: 'contained',
                onClick: () => self.abrirRelatorio()
              }
            }
          ]
        }
      }).dxDataGrid('instance')
    },
    rowPrepared: function (e) {
      if (e.rowType !== 'data') return
      const cls = this.rowClass(e.data) || ''
      if (!cls) return

      const el = e.rowElement || e.element
      if (!el) return

      // jQuery-like element (DevExtreme sometimes provides jQuery wrapper)
      if (typeof el.addClass === "function") {
        el.addClass(cls);
        // also apply inline background color for visual consistency
        try {
          const colorMap = {
            "linha-cancelada": "#ffebee",
            "linha-finalizada": "#e8f5e9",
            "linha-producao": "#e3f2fd"
          };
          Object.keys(colorMap).forEach(k => {
            if (cls.indexOf(k) !== -1) {
              if (typeof el.css === "function") el.css("background", colorMap[k]);
              else if (el.get && el.get(0) && el.get(0).style) el.get(0).style.background = colorMap[k];
            }
          });
        } catch (err) {
          // ignore styling errors
        }
        return;
      }

      // native DOM element
      if (el.classList && typeof el.classList.add === "function") {
        cls.split(/\s+/).forEach(c => { if (c) el.classList.add(c); });
        // also apply inline background color
        try {
          const colorMap = {
            "linha-cancelada": "#ffebee",
            "linha-finalizada": "#e8f5e9",
            "linha-producao": "#e3f2fd"
          };
          Object.keys(colorMap).forEach(k => {
            if (cls.indexOf(k) !== -1) {
              el.style.background = colorMap[k];
            }
          });
        } catch (err) {
          // ignore
        }
        return;
      }

      // last-resort fallback to e.element (if present and jQuery-like)
      if (e.element && typeof e.element.addClass === 'function') {
        e.element.addClass(cls)
      }
    },
    atualizarDataSourceGrid () {
      const inst = this.gridInstance || (this.$refs.dxGrid && this.$refs.dxGrid.instance)
      if (!inst) return
      try {
        inst.option('dataSource', this.linhas || [])
        console.log("Atualizou dataSource da grid:", this.linhas)
        this.$nextTick(() => {
          try { inst.refresh() } catch (e) { /* ignore */ }
        })
      } catch (err) {
        console.error('Erro ao atualizar dataSource da grid:', err)
      }
    },

    /** ------------- BOTÕES MENU (EXCEL / PDF / RELATÓRIO) ------------- **/

    exportarExcel () {
      if (window.exportarGridExcel) {
        window.exportarGridExcel(this.gridId)
        return
      }
      // fallback simples: export do próprio DevExtreme, se quiser
      const inst = this.gridInstance || (this.$refs.dxGrid && this.$refs.dxGrid.instance)
      if (!inst) return
      DevExpress.excelExporter.exportDataGrid({
        component: inst,
        worksheet: new ExcelJS.Workbook().addWorksheet('Planilha'),
        autoFilterEnabled: true
      })
    },

    // exportarPDF () {
    //   if (window.exportarGridPDF) {
    //     window.exportarGridPDF(this.gridId)
    //     return
    //   }
    //   // se não tiver helper global, dá pra implementar depois
    // },

    abrirRelatorio () {
      if (window.gerarRelatorio) {
        window.gerarRelatorio(this.gridId)
      } else {
        alert('Funcionalidade de relatório ainda não está disponível nesta tela.')
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
    onVoltar() {
      if (this.$router) this.$router.back();
      else window.history.back();
    },
    async onExportarExcel() {
      console.log("chamou onExportarExcel");
      try {
        // pegue seus dados atuais do grid;
        // se você guarda em this.rows ou this.dataSource, ajuste abaixo:
        const rows = Array.isArray(this.linhas) ? this.linhas : (this.dataSource || [])
        await exportarParaExcel({ rows, nomeArquivo: `${this.pageTitle || "dados"}.xlsx` })
      } catch (e) {
        console.error("Falha ao exportar Excel", e);
        this.$q && this.$q.notify({ type: "negative", message: "Erro ao exportar Excel." })
      }
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
          message: "Falha ao exportar PDF.",
        });
      }
    },
    onEditClick(row) {
      console.log("Editar item de produção:", row);
      this.$set(this, "editItem", { ...row });
      this.$set(this, "editItemForm", { ...row });

      // this.editItem = row;
      // Maquina
      // this.editItemForm.cd_maquina = row.cd_maquina;
      // this.editItemForm.nm_maquina = row.nm_maquina;

      // // Operação
      // this.editItemForm.cd_operacao = row.cd_operacao;
      // this.editItemForm.nm_operacao = row.nm_operacao;

      // // Produzido / Quantidade
      // this.editItemForm.qt_produzido_processo = row.qt_produzido_processo;

      // this.editItemForm.cd_processo = row.cd_processo;
      // this.editItemForm.cd_item_processo = row.cd_item_processo;

      //selects do formulário de edição
      // this.editItemForm.maquina = row.cd_maquina;
      // this.editItemForm.operacao = row.cd_operacao;
      // this.editItemForm.operador = row.cd_operador;

      this.isDialogEditOpen = true;
    },
    async saveEdit() {
      const row = this.editItem;
      console.log("saveEdit chamado", row);
      // Atualiza campos numéricos/quantidade
      row.qt_produzido_processo = this.editItemForm.qt_produzido_processo;

      // Atualiza cd_* a partir dos selects (são primitivos: emit-value)
      row.cd_maquina = this.editItemForm.cd_maquina;
      row.cd_operacao = this.editItemForm.cd_operacao;
      row.cd_operador = this.editItemForm.cd_operador;

      // Resolve nomes (labels) das opções selecionadas para exibir na grid
      try {
        if (row.cd_maquina != null) {
          const m = (this.maquina || []).find(x => Number(x.cd_maquina) === Number(row.cd_maquina));
          if (m) {
            row.nm_maquina = m.nm_fantasia_maquina || m.nm_maquina || row.nm_maquina;
          }
        }
        if (row.cd_operacao != null) {
          const o = (this.operacao || []).find(x => Number(x.cd_operacao) === Number(row.cd_operacao));
          if (o) {
            row.nm_operacao = o.nm_fantasia_operacao || o.nm_operacao || row.nm_operacao;
          }
        }
        if (row.cd_operador != null) {
          const p = (this.operador || []).find(x => Number(x.cd_operador) === Number(row.cd_operador));
          if (p) {
            row.nm_operador = p.nm_fantasia_operador || p.nm_operador || row.nm_operador;
          }
        }
      } catch (err) {
        console.warn('Não foi possível resolver labels das opções selecionadas', err);
      }

      // Atualiza o item na lista de forma reativa
      const idx = this.linhas.findIndex(r => r.cd_item_processo === row.cd_item_processo);
      if (idx >= 0) {
        this.$set(this.linhas, idx, Object.assign({}, this.linhas[idx], row));
      } else {
        this.linhas = [...this.linhas, row];
      }
      this.atualizarDataSourceGrid();
      //TODO: verificar se é necessário chamar o backend para salvar as alterações / try catch
      try {
        // this.carregando = true;
        // const payload = this.montarPayloadAcao("FIM", row);
        // const data = await execProcedure("pr_egis_pcp_processo_modulo", payload, { banco: this.bancoInterno });
        // console.log("Item de produção editado com sucesso.", data);
        // await this.carregarDados();
      } catch (err) {
        console.error("Erro ao editar item de produção:", err);
        this.erro = "Erro ao editar item de produção.";
      } finally {
        this.isDialogEditOpen = false;
        this.carregando = false;
        this.editItem = null;
      }
    }
  }
}
</script>

<style scoped>

.apontamento-producao {
  padding: 8px;
  font-size: 14px;
}

/* Cabeçalho / resumo */
.card-resumo {
  border: 1px solid #ddd;
  border-radius: 6px;
  padding: 10px;
  background: #fafafa;
}

.card-resumo label {
  font-size: 11px;
  text-transform: uppercase;
  color: #666;
  margin-bottom: 2px;
}

.resumo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  grid-gap: 6px 12px;
}

/* Texto das colunas principais */
.texto-primario {
  font-weight: 600;
  font-size: 13px;
}

.texto-secundario {
  font-size: 11px;
  color: #777;
}

/* Legenda cores */
.legenda-cores {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  padding-top: 16px;
  padding-bottom: 16px;
}

.badge.legenda {
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 11px;
  border: 1px solid #ccc;
  color: #222;
}

/* Cores de linha */
.linha-aguardando {
  background: #ffffff;
}

.linha-producao {
  background: #e3f2fd; /* azul clarinho */
}

.linha-finalizada {
  background: #e8f5e9; /* verde clarinho */
}

.linha-cancelada {
  background: #ffebee; /* vermelho clarinho */
}

/* Painel grid (igual unicoForm) */
.painel-grid {
  margin-top: 4px;
}

/* Ajuste título para ficar igual grid.service/unicoForm */
.titulo-grid {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
}
:deep(.dx-button .dx-icon) {
  font-size: 16px;
}

:deep(.dx-button) {
  display: inline-flex;
  align-items: center;
  padding: 4px 8px;
}

:deep(.dx-button .dx-icon) {
  font-size: 16px;
}

:deep(.dx-button-text) {
  font-size: 12px;
}

.topbar {
  width: 100%;
  display: flex;
  align-items: center;
}

.dx-widget.dx-visibility-change-handler {
  max-width: none !important;
}
</style>
