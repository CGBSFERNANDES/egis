<template>
  <div class="egis-ia q-pa-md">
    <div class="row q-col-gutter-md">

      <!-- LADO ESQUERDO: PERGUNTA + CHAT -->
      <div class="col-12 col-md-4">
        <q-card flat bordered>

          <q-card-section class="row items-center q-gutter-sm">
            <q-avatar icon="psychology" color="deep-purple-8" text-color="white" />
            <div>
              <div class="text-subtitle1">Egis IA</div>
              <div class="text-caption text-grey-7">
                Pergunte sobre vendas, faturamento, estoque, tendências...
              </div>
            </div>
          </q-card-section>

          <q-separator />

          <!-- Textarea para pergunta -->
          <q-card-section>
            <q-input
              v-model="pergunta"
              type="textarea"
              outlined
              autogrow
              :disable="loading"
              label="Digite sua pergunta"
              @keyup.enter.exact.prevent="perguntar"
            >
              <template v-slot:append>
                <q-btn
                  round
                  dense
                  icon="send"
                  color="primary"
                  :loading="loading"
                  @click="perguntar"
                />
              </template>
            </q-input>

            <!-- Sugestões rápidas -->
            <div class="row q-gutter-xs q-mt-sm">
              <q-chip
                v-for="s in sugestoes"
                :key="s"
                clickable
                dense
                outline
                color="primary"
                @click="usarSugestao(s)"
              >
                {{ s }}
              </q-chip>
            </div>
          </q-card-section>

          <!-- Erro -->
          <q-card-section v-if="erro" class="text-negative text-caption">
            {{ erro }}
          </q-card-section>

          <q-separator />

          <!-- Histórico do chat -->
          <q-card-section class="q-pb-none">
            <div class="row items-center justify-between">
              <div class="text-subtitle2">Conversa</div>
              <q-btn
                dense
                flat
                icon="delete_sweep"
                label="Limpar"
                @click="limparChat"
              />
            </div>
          </q-card-section>

          <q-card-section>
            <q-scroll-area style="height: 260px">
              <div v-if="!historico.length" class="text-grey-6 text-caption q-mt-sm">
                Ainda não há mensagens. Faça uma pergunta para começar.
              </div>

              <div
                v-for="(m, i) in historico"
                :key="i"
                class="q-mb-sm"
              >
                <div
                  class="q-pa-sm q-rounded-borders"
                  :class="m.autor === 'user'
                    ? 'bg-blue-1 text-blue-10'
                    : 'bg-grey-2 text-grey-9'"
                >
                  <div class="row items-center q-mb-xs">
                    <q-icon
                      :name="m.autor === 'user' ? 'person' : 'smart_toy'"
                      size="16px"
                      class="q-mr-xs"
                    />
                    <div class="text-caption text-weight-medium">
                      {{ m.autor === 'user' ? 'Você' : 'Egis IA' }}
                    </div>
                    <div class="text-caption text-grey-6 q-ml-auto">
                      {{ formatarHora(m.ts) }}
                    </div>
                  </div>
                  <div class="text-body2">
                    {{ m.texto }}
                  </div>
                </div>
              </div>
            </q-scroll-area>
          </q-card-section>

        </q-card>
      </div>

      <!-- LADO DIREITO: GRID + DASHBOARD -->
      <div class="col-12 col-md-8">
        <q-card flat bordered>

          <q-card-section class="row items-center justify-between">
            <div>
              <div class="text-subtitle1">
                Resultados da consulta
              </div>
              <div class="text-caption text-grey-7">
                Dados retornados pela IA + Egis (procedures / tabelas)
              </div>
            </div>

            <div class="row items-center q-gutter-sm">
              <q-toggle
                v-model="showDashboard"
                color="primary"
                label="Mostrar Dashboard"
                left-label
              />
              <q-btn
                dense
                flat
                icon="file_download"
                label="Exportar (JSON)"
                :disable="!temResultado"
                @click="exportarJSON"
              />
            </div>
          </q-card-section>

          <q-separator />

          <!-- Loading -->
          <q-card-section v-if="loading" class="row items-center justify-center">
            <q-spinner size="32px" color="primary" />
            <span class="q-ml-sm text-caption">Consultando Egis IA...</span>
          </q-card-section>

          <!-- Sem dados -->
          <q-card-section v-if="!loading && !temResultado" class="text-grey-6 text-caption">
            Nenhum dado retornado ainda. Faça uma pergunta sobre vendas, faturamento, estoque, etc.
          </q-card-section>

          <!-- Grid -->
          <q-card-section v-if="temResultado">
            <div class="text-subtitle2 q-mb-xs">
              Tabela dinâmica
            </div>
            <DxDataGrid
              :data-source="rows"
              :column-auto-width="true"
              :row-alternation-enabled="true"
              :show-borders="true"
              height="60vh"
            >
              <DxColumn
                v-for="c in columns"
                :key="c.dataField"
                :data-field="c.dataField"
                :caption="c.caption"
                :width="c.width"
                :min-width="c.minWidth"
                :alignment="c.alignment"
              />

              <DxSearchPanel
                :visible="true"
                :width="240"
                placeholder="Pesquisar..."
              />
              <DxFilterRow :visible="true" />
              <DxHeaderFilter :visible="true" />
              <DxGrouping :auto-expand-all="false" />
              <DxGroupPanel :visible="true" />
              <DxPaging :page-size="20" />
              <DxPager
                :show-page-size-selector="true"
                :allowed-page-sizes="[20, 50, 100]"
                :show-navigation-buttons="true"
              />
              <DxColumnChooser :enabled="true" />
              <DxSummary>
                <DxTotalItem
                  column=""
                  summary-type=""
                />
              </DxSummary>
            </DxDataGrid>
          </q-card-section>

          <q-separator v-if="temResultado && showDashboard" />

          <!-- Dashboard Dinâmico -->
          <q-card-section v-if="temResultado && showDashboard">
            <dashboard-dinamico
              :rows="rows"
              :columns="columns"
              :titulo="tituloDashboard"
              :cd-menu="cdMenu"
              @voltar="showDashboard = false"
            />
          </q-card-section>

        </q-card>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import { payloadTabela, 
         getColumnsForMenu,
         getRowsFromPesquisa,
         getRowsExecPorMenu,
         getPayloadTabela,
         salvarDadosForm,
         lookup,
         execProcedure,
         getInfoDoMenu
 } from '@/services'

import DxDataGrid, {
  DxColumn,
  DxGrouping,
  DxGroupPanel,
  DxSummary,
  DxTotalItem,
  DxSearchPanel,
  DxHeaderFilter,
  DxFilterRow,
  DxPager,
  DxPaging,
  DxColumnChooser
} from 'devextreme-vue/data-grid'

import DashboardDinamico from '@/components/dashboardDinamico.vue'

export default {
  name: 'EgisIA',
  components: {
    DxDataGrid,
    DxColumn,
    DxGrouping,
    DxGroupPanel,
    DxSummary,
    DxTotalItem,
    DxSearchPanel,
    DxHeaderFilter,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxColumnChooser,
    DashboardDinamico
  },
  props: {
    // Endpoint que vai conversar com OpenAI + banco Egis
    apiUrl: {
      type: String,
      default: '/api/egis-ia/chat'
    },
    cdEmpresa: {
      type: [Number, String],
      default: null
    },
    cdUsuario: {
      type: [Number, String],
      default: null
    },
      banco: {
       type: String,
       default: null // ex.: 'EGISSQL_355'
      },
        cdModelo: {
    type: [Number, String],
    default: 1 // ou outro padrão que você use
  }
  },
  data () {
    return {
      bancoEmpresa : localStorage.nm_banco_empresa || 'egisAdmin',  
      cd_usuario: localStorage.cd_usuario || 0,
      cd_empresa: localStorage.cd_empresa || 0,
      pergunta: '',
      loading: false,
      erro: null,

      historico: [], // { autor:'user'|'ia', texto, ts:Date }

      rows: [],
      columns: [],
      cdMenu: null,

      showDashboard: true,

      dtInicial: null,
      dtFinal: null,
      cdFilaAtual: null,
      sugestoes: [
        'Quais as vendas de hoje?',
        'Qual o faturamento deste mês?',
        'Quais produtos estão abaixo do estoque mínimo?',
        'Tendência de vendas por semana',
        'Comparativo de faturamento entre meses'
      ]
    }
  },
  mounted () {
     //this.carregarDefaultsIA()
     this.bancoEmpresa = localStorage.nm_banco_empresa || 'egisAdmin'
     //this.carregarDefaultsIA()
     this.carregarHistoricoIA()
  },

  computed: {
    temResultado () {
      return Array.isArray(this.rows) && this.rows.length > 0
    },
    tituloDashboard () {
      if (!this.historico.length) return 'Dashboard dinâmico'
      const ult = this.historico
        .filter(h => h.autor === 'user')
        .slice(-1)[0]
      return ult ? `Dashboard - ${ult.texto}` : 'Dashboard dinâmico'
    }
  },
  methods: {
    montarJsonIA (cd_parametro, extra = {}) {
    return {
      cd_parametro,               // 0 -> default; 1 -> enfileirar pergunta
      cd_empresa: localStorage.cd_empresa || this.cd_empresa || this.cdEmpresa || 0,
      cd_usuario: localStorage.cd_usuario || this.cd_usuario || this.cdUsuario || 0,
      cd_modelo: this.cdModelo,
      dt_inicial: this.dtInicial,
      dt_final: this.dtFinal,
      pergunta: this.pergunta || '',
      cd_fila: this.cdFilaAtual,
       ...extra
    }
   },

    async carregarDefaultsIA () {
    try {

      const json = this.montarJsonIA(0)

      const payload = [
        {
          ic_json_parametro: 'S',
          //json: JSON.stringify(json)
          json: JSON.stringify([json]),     // ✅ ENVIA COMO ARRAY
          //cd_usuario : this.cd_usuario,
          //cd_empresa : this.cd_empresa
        }
      ]

      console.log('dados 0 ->', this.bancoEmpresa, payload);

      const dados = await execProcedure(
        'pr_egis_IA_modelo_procedure',
        payload,
        { banco: this.bancoEmpresa }
      )

      // A procedure faz:
      // select 'Sucesso' as Msg, @cd_modelo cd_modelo, @cd_empresa cd_empresa, @dt_inicial dt_inicial, @dt_final dt_final
      // então 'dados' deve ser um array com pelo menos um item
      const linha = Array.isArray(dados) && dados.length ? dados[0] : null

      console.log('retorno', linha);

      if (linha) {
        this.dtInicial = linha.dt_inicial || this.dtInicial
        this.dtFinal = linha.dt_final || this.dtFinal

        // Se vierem nulos, você ainda pode calcular algo padrão aqui
      }

    } catch (e) {
      console.error('Erro ao carregar defaults IA', e)
      this.erro = 'Erro ao carregar parâmetros padrão da IA.'
    }
  },

async perguntar () {
    
    this.bancoEmpresa = localStorage.nm_banco_empresa || 'egisAdmin';

    const pergunta = (this.pergunta || '').trim()
    if (!pergunta || this.loading) return

    // coloca no histórico da tela
    this.historico.push({
      autor: 'user',
      texto: pergunta,
      ts: new Date()
    })

    this.loading = true
    this.erro = null
    this.cdFilaAtual = null

    try {
      // 1) Monta JSON com cd_parametro = 1 (fila)
      const json = this.montarJsonIA(1)

      const payload = [
        {
          cd_parametro: 1,
          ic_json_parametro: 'S',
          json: JSON.stringify([json]),
          pergunta: this.pergunta || '' 
        }
      ]

    console.log('dados ->', this.bancoEmpresa, payload, pergunta);

      // 2) Chama a procedure via /exec/pr_egis_IA_modelo_procedure
      const dados = await execProcedure(
        'pr_egis_IA_modelo_procedure',
        payload,
        { banco: this.bancoEmpresa }
      )

            const linha = Array.isArray(dados) && dados.length ? dados[0] : null

           console.log('retorno da gravacao da fila -> ', linha); 

      if (!linha || !linha.cd_fila) {
        throw new Error('Não retornou cd_fila da fila.')
      }

      this.cdFilaAtual = linha.cd_fila;

      // Aqui você pode apenas avisar que foi enfileirado:
      this.historico.push({
        autor: 'ia',
        texto: 'Sua pergunta foi enviada para processamento pela Egis IA. Em instantes, o resultado estará disponível na fila/relatórios.',
        ts: new Date()
      })

      // 2) começa a consultar a fila com cd_parametro = 2
      await this.aguardarRespostaIA()
      //

      // Se você depois criar um cd_parametro (ex.: 2) para buscar o resultado
      // da Fila_EgisIA, dá pra complementar aqui com um novo execProcedure
      // que retorna rows/columns e preenche this.rows / this.columns.
      //this.rows = []
      //this.columns = []

    } catch (e) {
      console.error('Erro ao enfileirar pergunta da IA', e)
      this.erro = 'Erro ao enviar a pergunta para a fila da Egis IA.'
    } finally {
      this.loading = false
    }
  },
  //

async aguardarRespostaIA () {
  if (!this.cdFilaAtual) return

  const maxTentativas = 15
  const intervaloMs = 2000
  let tentativa = 0

  const pegarPrimeiraLinha = (dados) => {
    if (!dados) return null
    if (Array.isArray(dados)) return dados[0] || null
    if (Array.isArray(dados?.rows)) return dados.rows[0] || null
    if (Array.isArray(dados?.recordset)) return dados.recordset[0] || null
    if (Array.isArray(dados?.data)) return dados.data[0] || null
    if (typeof dados === 'object' && (dados.nm_status || dados.resposta || dados.cd_fila)) return dados
    return null
  }

  while (tentativa < maxTentativas) {
    tentativa++

    const json = this.montarJsonIA(2, { cd_fila: this.cdFilaAtual })
    const payload = [
      {
        cd_parametro: 3,
        ic_json_parametro: 'S',
        json: JSON.stringify([json]),
        cd_fila: this.cdFilaAtual 
      }
    ]

    const dados = await execProcedure(
      'pr_egis_IA_modelo_procedure',
      payload,
      { banco: this.bancoEmpresa }
    )

    console.log('consulta fila bruto ->', dados)

    const linha = pegarPrimeiraLinha(dados)
    console.log('consulta linha ->', this.bancoEmpresa, this.cdFilaAtual, linha)

    if (linha) {
      const status = String(linha.nm_status || '').trim().toUpperCase()

      let textoResposta = ''
      const r = linha.resposta
      if (typeof r === 'string') {
        const s = r.trim()
        if (s.startsWith('{') || s.startsWith('[')) {
          try {
            const parsed = JSON.parse(s)
            textoResposta = String(parsed?.texto || parsed?.resposta || parsed?.content || parsed)
          } catch {
            textoResposta = s
          }
        } else {
          textoResposta = s
        }
      } else if (r && typeof r === 'object') {
        textoResposta = String(r.texto || r.resposta || r.content || JSON.stringify(r))
      }

      if (status === 'PROCESSADO' && textoResposta) {
        this.historico.push({ autor: 'ia', texto: textoResposta, ts: new Date() })
        return
      }

      if (status === 'ERRO') {
        this.historico.push({
          autor: 'ia',
          texto: 'Ocorreu um erro ao processar sua pergunta na Egis IA.',
          ts: new Date()
        })
        return
      }
    }

    await new Promise(r => setTimeout(r, intervaloMs))

    // opcional: reduzir carga
    if (tentativa % 3 === 0) {
      await this.carregarHistoricoIA()
    }
  }

  this.historico.push({
    autor: 'ia',
    texto: 'Ainda não recebi resposta da Egis IA. Tente novamente em alguns instantes.',
    ts: new Date()
  })
},


  //
  async aguardarRespostaIAold () {
    if (!this.cdFilaAtual) return

    const maxTentativas = 15   // ex.: 15 tentativas
    const intervaloMs = 2000   // a cada 2 segundos
    let tentativa = 0

    while (tentativa < maxTentativas) {
      tentativa++

      const json = this.montarJsonIA(2, { cd_fila: this.cdFilaAtual })

      const payload = [
        {
          cd_parametro: 2,
          ic_json_parametro: 'S',
          json: JSON.stringify([json])
        }
      ]

      const dados = await execProcedure(
        'pr_egis_IA_modelo_procedure',
        payload,
        { banco: this.bancoEmpresa }
      )

      const linha = Array.isArray(dados) && dados.length ? dados[0] : null

      console.log('consulta fila ->', this.bancoEmpresa, this.cdFilaAtual, linha)


      if (linha) {
        const { nm_status, resposta } = linha

        // se já processou e tem resposta, sai do loop e mostra
        if (nm_status === 'PROCESSADO' && resposta) {
          this.historico.push({
            autor: 'ia',
            texto: resposta,
            ts: new Date()
          })
          return
        }

        // se der erro, para também
        if (nm_status === 'ERRO') {
          this.historico.push({
            autor: 'ia',
            texto: 'Ocorreu um erro ao processar sua pergunta na Egis IA.',
            ts: new Date()
          })
          return
        }
      }

      // ainda não tem resposta -> espera e tenta de novo
      await new Promise(r => setTimeout(r, intervaloMs))

      //
      this.carregarHistoricoIA();
      //

    }

    // se chegou aqui, estourou o tempo de espera
    this.historico.push({
      autor: 'ia',
      texto: 'Ainda não recebi resposta da Egis IA. Tente novamente em alguns instantes.',
      ts: new Date()
    })

  },

  async carregarHistoricoIA () {
  try {
    const json = this.montarJsonIA(3)

    const payload = [
      {
        cd_parametro: 3,
        ic_json_parametro: 'S',
        json: JSON.stringify([json])
      }
    ]

    console.log('carregarHistoricoIA payload ->', this.bancoEmpresa, payload)

    const dados = await execProcedure(
      'pr_egis_IA_modelo_procedure',
      payload,
      { banco: this.bancoEmpresa }
    )

    console.log('carregarHistoricoIA retorno ->', dados)

    this.rows = Array.isArray(dados) ? dados : []
    this.columns = this.normalizarColunas(null) // vai inferir das rows
  } catch (e) {
    console.error('Erro ao carregar histórico IA', e)
    // não precisa quebrar a tela, pode só logar
  }
},


    normalizarColunas (cols) {
      // Se o backend não mandar columns, inferimos pelos rows
      if (!Array.isArray(cols) || !cols.length) {
        if (!this.rows.length) return []
        const keys = Object.keys(this.rows[0] || {})
        return keys.map(k => ({
          dataField: k,
          caption: this.labelFromKey(k),
          alignment: 'left'
        }))
      }

      // Se vier como array de strings
      if (typeof cols[0] === 'string') {
        return cols.map(k => ({
          dataField: k,
          caption: this.labelFromKey(k),
          alignment: 'left'
        }))
      }

      // Se vier como objetos já no padrão, apenas ajusta default
      return cols.map(c => {
        const df = c.dataField || c.field || c.name
        return {
          dataField: df,
          caption: c.caption || c.label || this.labelFromKey(df),
          width: c.width,
          minWidth: c.minWidth,
          alignment: c.alignment || (c.type === 'number' ? 'right' : 'left')
        }
      })
    },

    labelFromKey (k) {
      if (!k) return ''
      // nm_produto -> Nm Produto
      const s = String(k).replace(/_/g, ' ')
      return s.replace(/\w\S*/g, txt => {
        return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
      })
    },

    usarSugestao (s) {
      this.pergunta = s
      this.$nextTick(() => this.perguntar())
    },

    limparChat () {
      this.historico = []
      this.rows = []
      this.columns = []
      this.cdMenu = null
      this.erro = null
    },

    exportarJSON () {
      if (!this.temResultado) return
      const blob = new Blob(
        [JSON.stringify({ rows: this.rows, columns: this.columns }, null, 2)],
        { type: 'application/json;charset=utf-8' }
      )
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = 'egis-ia-resultado.json'
      a.click()
      URL.revokeObjectURL(url)
    },

    formatarHora (dt) {
      try {
        const d = dt instanceof Date ? dt : new Date(dt)
        return d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
      } catch (e) {
        return ''
      }
    }
  }
}
</script>

<style scoped>
.egis-ia {
  max-width: 100%;
}
</style>
