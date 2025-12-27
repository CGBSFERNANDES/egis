<template>
  <div>
  <q-dialog v-model="internalVisible" persistent>
    <q-card :style="cardStyle" class="q-pa-none">
     <q-card-section class="row no-wrap items-start q-gutter-md">

        <!-- COLUNA ESQUERDA: ÍCONE / IDENTIDADE VISUAL -->
        <div class="col-auto flex flex-center bg-deep-purple-1 q-pa-lg" style="border-radius: 80px;">
          <q-icon name="tune" size="56px" color="deep-purple-7" />
        </div>

        <!-- COLUNA DIREITA: CONTEÚDO -->
        <div class="col">

          <!-- TÍTULO + BOTÃO FECHAR -->
          <div class="row items-start justify-between">
            <div>
              <div class="text-h6 text-weight-bold">
                {{ tituloModal || 'Composição' }}
                <q-badge rounded class="q-ml-sm top-badge" color="deep-orange-7" :label="String(cdModalBadge)" />
                <q-badge v-if="itens.length" color="deep-purple-7" class="q-ml-sm">{{ itens.length }}</q-badge>
              </div>

              <div class="text-caption text-grey-7">
                {{ subTituloModal || '' }}
              </div>
            </div>

            <q-btn icon="close" flat round dense @click="cancelar" />
          </div>

          <q-separator spaced />

          
          <!-- CONTEÚDO PRINCIPAL -->

          <div v-if="loading" class="row justify-center q-my-lg">
            <q-spinner size="42px" />
          </div>

          <div v-else>
            <!-- FORM (igual ModalComposicao: input dinâmico) -->
            <div class="row q-col-gutter-xs">
              <div
                v-for="(campo, idx) in metaCampos"
                :key="`${String(campo.nm_atributo || 'x')}_${String(campo.nu_ordem || campo.qt_ordem_atributo || idx)}`"
                :ref="`fld_${campo.nm_atributo}`"
                ref-in-for
                class="col-12 col-sm-6" style="margin-bottom: 4px;"
              >
                <div class="text-caption text-grey-8" style="margin-bottom: 2px;">
                  {{ labelCampo(campo) }}
                </div>

                  <div class="col-8">

                <component
                  :is="resolveComponent(campo)"
                  :ref="isSomenteLeitura(campo) ? null : ('campo_' + campo.nm_atributo)"
                  v-model="valores[campo.nm_atributo]"
                  dense
                  outlined
                  :clearable="!isSomenteLeitura(campo)"
                  :type="resolveType(campo)"
                  :options="getOptions(campo)"
                  emit-value
                  map-options
                  hide-bottom-space   
                  :label="campo.ds_campo_help || ''"
                  :hint="campo.ds_campo_help || ''"
                  :disable="isSomenteLeitura(campo)"
                  :readonly="isSomenteLeitura(campo)"
                  :tabindex="isSomenteLeitura(campo) ? -1 : 0"
                  :input-style="{
  paddingTop: '8px',
  paddingBottom: '8px',
  lineHeight: '20px', 
  backgroundColor: isSomenteLeitura(campo) ? '#e3f2fd' : undefined,
  color: isSomenteLeitura(campo) ? '#000000' : undefined,
   fontWeight: isSomenteLeitura(campo) ? 'bold' : undefined
}"
                  :class="{'leitura-azul': isSomenteLeitura(campo)}"
                  :style="estiloCampo(campo)"
                  :bg-color="bgColorCampo(campo)" 
                  @input="onCampoAlterado(campo, $event)"
                  @blur="onBlurCampo(campo)"
                  @keydown="onKeyDownCampo(campo, $event)"
                            >
                
                  <template v-slot:append>
                    <q-btn
                      v-if="!isSomenteLeitura(campo) && Number(campo.cd_menu || 0) !== 0"
                      dense
                      flat
                      round
                      icon="search"
                      @click="onClickLupa(campo)"
                    >
                      <q-tooltip>Buscar</q-tooltip>
                    </q-btn>
                  </template>
                </component>
                </div>
             </div>
            </div>


        <!-- Ações do form -->
        <div class="row items-center q-mt-md">
          <q-btn
            color="deep-purple-7"
            icon="save"
            label="Salvar"
            :loading="loadingSalvar"
            @click="salvarNoLocal"
          />

          <q-space />

          <q-btn flat label="Cancelar" @click="cancelar" />
          <q-btn
            color="deep-purple-7"
            label="Confirmar"
            :loading="loadingConfirmar"
            @click="confirmar"
            class="q-ml-sm"
          />
        </div>

        <!-- GRID dos itens salvos -->
<div class="q-mt-lg">
  <div class="row items-center q-mb-sm">
    <div class="text-subtitle2 text-grey-8">Itens salvos</div>

    <q-badge color="deep-purple-7" class="q-ml-sm">
      {{ qtdRegistros }}
    </q-badge>

    <q-badge color="deep-purple-7" class="q-ml-sm">
      Qtde: {{ totalQuantidade }}
    </q-badge>
  </div>

  <dx-data-grid
  :data-source="itens"
  :key-expr="'__rowid'"
  :show-borders="true"
  :hover-state-enabled="true"
  :row-alternation-enabled="true"
  height="240"
   @row-click="onGridRowClick"
>
  <dx-scrolling mode="standard" />
  <dx-selection mode="single" />
  <dx-paging :page-size="10" />
  <dx-pager
    :show-page-size-selector="true"
    :allowed-page-sizes="[5,10,20]"
    :show-info="true"
  />
  <template slot="acoesTemplate" slot-scope="{ data }">
  <q-btn
    dense flat round icon="delete" color="negative"
    @click.stop="removerItem(data.__rowid)"
  >
    <q-tooltip>Remover</q-tooltip>
  </q-btn></template>

  <!-- Colunas dinâmicas pelo meta -->

  <dx-column
    v-for="(col, i) in gridColumnsDx"
    :key="`dxcol_${col.dataField || 'acoes'}_${i}`"
    :data-field="col.dataField"
    :caption="col.caption"
  />
  
  <dx-summary>
  <dx-total-item
    column="__rowid"
    summary-type="count"
    display-format="Registros: {0}"
  />

  <dx-total-item
    v-for="c in colunasTotalGrid"
    :key="c"
    :column="c"
    summary-type="sum"
    value-format="#,##0.00"
    :display-format="`Total: {0}`"
  />
</dx-summary>

</dx-data-grid>

</div>
</div>
          
        </div> 
      </q-card-section>
    </q-card>
  </q-dialog>
     <!-- Modal UnicoFormEspecial -->
    <q-dialog v-model="showUnicoEspecial" persistent>
      <q-card style="min-width: 95vw; min-height: 90vh;">
        <UnicoFormEspecial
          :cd_menu_entrada="cd_menu_item_modal"
          :cd_menu_modal_entrada="0"
          :titulo_menu_entrada="tituloMenuUnico"
          :cd_acesso_entrada="0"
          ic_modal_pesquisa="S"
          @fechar="fecharUnicoEspecial"
        />
      </q-card>
    </q-dialog>
 </div> 
</template>

<script>
// Ajuste o import para o mesmo caminho do seu ModalComposicao.vue
import axios from 'axios'
import DxDataGrid, {
  DxColumn,
  DxPaging,
  DxPager,
  DxScrolling,
  DxSelection,
  DxSummary,
  DxTotalItem
} from 'devextreme-vue/data-grid'

// Se você já tem um `api` global, pode importar de lá.
// Aqui deixo um exemplo simples, igual ao estilo do UnicoFormEspecial.
const api = axios.create({
  baseURL: 'https://egiserp.com.br/api',
  withCredentials: true,
  timeout: 60000,
})

api.interceptors.request.use(cfg => {
  const banco = localStorage.nm_banco_empresa || ''
  if (banco) cfg.headers['x-banco'] = banco
  cfg.headers['Authorization'] = 'Bearer superchave123'
  if (!cfg.headers['Content-Type']) cfg.headers['Content-Type'] = 'application/json'
  return cfg
})


function safeParse (s, fallback) {
  try { return JSON.parse(s) } catch (e) { return fallback }
}

function montaDadosTecnicos (row, meta) {
  if (!row || typeof row !== 'object') row = {}
  if (!Array.isArray(meta)) meta = []

  const dadosTecnicos = {}

  meta.forEach((m) => {
    if (!m || !m.nm_atributo) return

    const candidatos = [
      m.nm_atributo,
      m.nm_titulo_menu_atributo,
      m.nm_atributo_consulta
    ].filter(Boolean)

    let valor

    for (let i = 0; i < candidatos.length; i++) {
      const k = candidatos[i]
      if (k in row) { valor = row[k]; break }

      const alt = Object.keys(row).find(
        (kk) => kk.toLowerCase() === String(k).toLowerCase()
      )
      if (alt) { valor = row[alt]; break }
    }

    const tipo = String(m.nm_datatype || '').toLowerCase()
    if (valor === '') valor = null

    // Datas
    if (valor != null && (tipo === 'date' || tipo === 'datetime' || tipo === 'shortdate')) {
      const isoMatch = /^(\d{4})-(\d{2})-(\d{2})$/.exec(valor)
      if (isoMatch) {
        const [, yyyy, mm, dd] = isoMatch
        valor = `${yyyy}-${mm}-${dd}`
      } else {
        const d = new Date(valor)
        if (!isNaN(d.getTime())) {
          const yyyy = d.getFullYear()
          const mm = String(d.getMonth() + 1).padStart(2, '0')
          const dd = String(d.getDate()).padStart(2, '0')
          valor = `${yyyy}-${mm}-${dd}`
        } else {
          valor = null
        }
      }
    }

    // Number / Currency
    if (valor != null && (tipo === 'number' || tipo === 'currency')) {
      if (typeof valor === 'string') {
        const s = valor.replace(/[R$\s]/g, '').replace(/\./g, '').replace(',', '.')
        const n = +s
        if (!isNaN(n)) valor = n
      }
    }

    dadosTecnicos[m.nm_atributo] = (valor == null ? '' : valor)

  })

  delete dadosTecnicos.id
  delete dadosTecnicos['Código']
  delete dadosTecnicos['Descricao']
  delete dadosTecnicos['Descrição']

  return dadosTecnicos
}

export default {
  name: 'ModalGridComposicao',
  components: {
         UnicoFormEspecial: () => import('@/views/unicoFormEspecial.vue'),
          DxDataGrid,
  DxColumn,
  DxPaging,
  DxPager,
  DxScrolling,
  DxSelection,
  DxSummary,
  DxTotalItem
  },
  props: {
    value: { type: Boolean, default: false },
    cdModal: { type: Number, required: true },
    registrosSelecionados: { type: Array, default: () => [] }
  },

  data () {
    return {
      headerBanco: localStorage.nm_banco_empresa,
      loading: false,
      internalVisible: this.value,

      loadingSalvar: false,
      loadingConfirmar: false,

      meta: [],
      valores: {},
      itens: [],

      tituloModal: '',
      subTituloModal: '',

      lookupOptions: {},

      // drag
      dragX: 0,
      dragY: 0,
      dragStartX: 0,
      dragStartY: 0,
      showUnicoEspecial: false,
      campoUnicoAtivo: null,
      cdMenuAnterior: Number(localStorage.cd_menu || 0),
      cd_menu_item_modal: 0,
      tituloMenuUnico: '',
      rowUnicoSelecionado: null,
      nm_procedimento: '',
      cd_parametro_procedimento: 0,
      autoSaveArmed: false,
      autoSaveLock: false,
      validandoCampos: {},       // trava por campo
      ultimaValidacao: {},       // evita validar o mesmo valor repetido

    }
  },

  computed: {
    storageKey () {
      return `modal_grid_composicao_${Number(this.cdModal || 0)}`
    },

    cardStyle () {
      return {
        minWidth: '980px',
        maxWidth: '98vw',
        transform: `translate(${this.dragX}px, ${this.dragY}px)`
      }
    },
    
    cdModalBadge () { return Number(this.cdModal || 0) },

        // compat: alguns pontos usam this.gridMeta (padrão do ModalComposicao)
    gridMeta () {
      return this.metaCampos || []
    },

metaCampos () {
  const arr = Array.isArray(this.meta) ? this.meta : []
  const seen = new Set()
  const out = []

  for (let i = 0; i < arr.length; i++) {
    const m = arr[i]
    const nm = m?.nm_atributo ? String(m.nm_atributo).trim() : ''
    if (!nm) continue

    const k = nm.toLowerCase()
    if (seen.has(k)) continue
    seen.add(k)

    out.push(m)
  }

  return out
},

 

    itensRows () {
  // garante que SEMPRE é array para o QTable
  return Array.isArray(this.itens) ? this.itens : []
},

    qtdRegistros () {
     return Array.isArray(this.itens) ? this.itens.length : 0
},

    totalQuantidade () {
  const campoQt = (this.metaCampos || []).find(m => {
    const nm = String(m?.nm_atributo || '').toLowerCase()
    return nm.startsWith('qt_') || nm.includes('quantidade')
  })?.nm_atributo

  if (!campoQt) return 0

  return (this.itens || []).reduce((acc, r) => {
    const v = r?.[campoQt]
    const n = typeof v === 'number' ? v : Number(String(v || '').replace(',', '.'))
    return acc + (isNaN(n) ? 0 : n)
  }, 0)
},

    //
   gridColumnsDx () {
  const meta = Array.isArray(this.metaCampos) ? this.metaCampos : []

  const baseCols = [{
    caption: 'Ações',
    width: 70,
    alignment: 'center',
    fixed: true,
    fixedPosition: 'left',
    allowSorting: false,
    allowFiltering: false,
    allowHeaderFiltering: false,
    allowSearch: false,
    cellTemplate: 'acoesTemplate'
  }]

  const map = new Map() // key normalizada -> col

  for (const m of meta) {
    const nmRaw = String(m?.nm_atributo || '')
    const nm = nmRaw.trim()
    if (!nm || nm === '__rowid') continue

    const k = nm.toLowerCase()
    if (map.has(k)) continue

    const dt = String(m.nm_datatype || '').toLowerCase()
    const col = {
      dataField: nm,
      caption: m.nm_edit_label || m.nm_titulo_menu_atributo || nm,
      alignment: 'left'
    }

    if (dt.includes('date')) {
      col.dataType = 'date'
      col.format = 'dd/MM/yyyy'
    }

    if (dt.includes('currency') || dt.includes('money')) {
      col.dataType = 'number'
      col.alignment = 'right'
      col.format = { type: 'currency', precision: 2 }
    }

    if (dt.includes('number') || dt.includes('decimal') || dt.includes('int')) {
      col.dataType = 'number'
      col.alignment = 'right'
      const isQt = nm.toLowerCase().startsWith('qt_') || nm.toLowerCase().includes('quantidade') || dt.includes('int')
      col.format = isQt ? { type: 'fixedPoint', precision: 0 } : { type: 'fixedPoint', precision: 2 }
    }

    map.set(k, col)
  }

  return baseCols.concat([...map.values()])
},



totaisGrid () {
  const totais = {}

  this.metaCampos.forEach(m => {
    if (String(m.ic_total_grid).toUpperCase() === 'S') {
      totais[m.nm_atributo] = this.itens.reduce((acc, r) => {
        const v = Number(r[m.nm_atributo] || 0)
        return acc + (isNaN(v) ? 0 : v)
      }, 0)
    }
  })

  return totais
},

    gridColumnsSafe () {
      return this.gridColumnsDx || []
    },

    camposEditaveis () {
    return (this.metaCampos || [])
      .filter(m => !this.isSomenteLeitura(m))
      .slice()
      .sort((a, b) => Number(a.nu_ordem || a.qt_ordem_atributo || 0) - Number(b.nu_ordem || b.qt_ordem_atributo || 0))
  },

ultimoCampoEditavel () {
  const editaveis = this.metaCampos.filter(
    m => String(m.ic_edicao_atributo).toUpperCase() === 'S'
  )
  return editaveis.length
    ? editaveis[editaveis.length - 1].nm_atributo
    : null
},

colunasTotalGrid () {
  const cols = (this.metaCampos || [])
    .filter(m => String(m.ic_total_grid || '').toUpperCase() === 'S')
    .map(m => m.nm_atributo)
    .filter(Boolean)

  return Array.from(new Set(cols))
},

primeiroCampoEditavelNm () {
  const primeiro = (this.camposEditaveis && this.camposEditaveis[0]) ? this.camposEditaveis[0] : null
  return primeiro ? primeiro.nm_atributo : null
},

  //
  },

  watch: {
    value (v) {
      this.internalVisible = v
      if (v) this.bootstrap()
    },
    internalVisible (v) {
      this.$emit('input', v)
      this.$emit('update:value', v)
    }
  },

  created () {
    this.headerBanco = localStorage.nm_banco_empresa;

    if (this.internalVisible) this.bootstrap()
  },

  methods: {

    bgColorCampo (campo) {
      // azul clarinho só para campos somente leitura
      return this.isSomenteLeitura(campo) ? 'blue-1' : void 0
    },

    propsExtrasCampo (campo) {
  // só faz sentido em q-input
  if (this.resolveComponent(campo) !== 'q-input') return {}

  const dt = String(campo?.nm_datatype || '').toLowerCase()
  const nm = String(campo?.nm_atributo || '').toLowerCase()

  // quantidade (inteiro)
  if (dt.includes('int') || nm.startsWith('qt_')) {
    return { mask: '##########', fillMask: '0' }
  }

  // currency/decimal
  if (dt.includes('currency') || dt.includes('money') || dt.includes('decimal') || nm.startsWith('vl_')) {
    // máscara simples (você pode refinar depois)
    return { mask: '###.###.###.###,##', reverseFillMask: true, fillMask: '0' }
  }

  return {}
},

    metaByAttr () {
  const map = {}
  ;(this.metaCampos || []).forEach(m => {
    map[m.nm_atributo] = m
  })
  return map
},

    toNumber (v) {
  if (v == null) return 0
  if (typeof v === 'number') return v
  const s = String(v).replace(/[R$\s]/g, '').replace(/\./g, '').replace(',', '.')
  const n = Number(s)
  return isNaN(n) ? 0 : n
},

focarPrimeiroCampo () {
  this.$nextTick(() => {
    const nm = this.primeiroCampoEditavelNm
    if (!nm) return

    const refKey = `campo_${nm}`
    const el = this.$refs[refKey]
    if (!el) return

    // q-input / q-select têm .focus()
    if (typeof el.focus === 'function') el.focus()
    else if (Array.isArray(el) && el[0] && typeof el[0].focus === 'function') el[0].focus()
  })
},

  async onKeyDownCampo (campo, e) {
    const key = e.key

    // pega o valor atual
    const raw = this.valores[campo.nm_atributo]
    const valor = (raw === null || raw === undefined) ? '' : String(raw).trim()

    // se vazio, não valida (e deixa seguir a vida)
    if (!valor) {
      // se apertar seta pra baixo e tiver lupa, pode abrir a pesquisa direto (opcional)
      if (key === 'ArrowDown' && Number(campo.cd_menu || 0) !== 0) {
        e.preventDefault()
        this.onClickLupa(campo)
      }
      return
    }

    // ENTER: valida e impede submit / comportamento estranho
    if (key === 'Enter') {
      e.preventDefault()

      // garante que o v-model já atualizou antes de validar
      await this.$nextTick()

      await this.validarEConsultarCampo(campo, { origem: 'ENTER' })
      return
    }

    // TAB: valida mas NÃO bloqueia o tab (senão o foco não anda)
    if (key === 'Tab') {
      // não use preventDefault aqui
      await this.$nextTick()
      await this.validarEConsultarCampo(campo, { origem: 'TAB' })
      return
    }

    // SETA PARA BAIXO:
    // comportamento típico: se for lookup abre lupa, senão valida
    if (key === 'ArrowDown') {
      if (Number(campo.cd_menu || 0) !== 0) {
        e.preventDefault()
        this.onClickLupa(campo)
      } else {
        await this.$nextTick()
        await this.validarEConsultarCampo(campo, { origem: 'DOWN' })
      }
    }
  },

  async validarEConsultarCampo (campo, { origem }) {
    // 1) chama sua validação (regra)
    // 2) se for lookup, tenta buscar pelo valor digitado
    // 3) se não achou nada, abre lupa (se aplicável)
    // 4) se achou, preenche os demais campos

    const valor = String(this.valores[campo.nm_atributo] ?? '').trim()
    if (!valor) return

    const ok = await this.validarCampoRegra?.(campo, valor, origem) // adapte ao seu método
    if (ok === false) return

    const temLupa = Number(campo.cd_menu || 0) !== 0

    const achou = await this.buscarPorCodigo?.(campo, valor, origem) // adapte ao seu método
    if (!achou && temLupa) {
      this.onClickLupa(campo)
    }
    // foca próximo campo
    await this.focarProximoCampo(campo)

  },



    // ===== Eventos da grid =====

    onGridRowClick (e) {
  const row = e && e.data ? e.data : null
  if (!row) return

  // preenche somente campos do meta (mantém padrão)
  ;(this.metaCampos || []).forEach(m => {
    if (!m || !m.nm_atributo) return
    if (m.nm_atributo === '__rowid') return
    this.$set(this.valores, m.nm_atributo, row[m.nm_atributo])
  })

  this.persistirDraft()
},

  avaliarFormula (formula) {
     if (!formula) return null

  // pega nomes de variáveis (atributos)
  const tokens = String(formula).match(/[a-zA-Z_][a-zA-Z0-9_]*/g) || []
  let expr = String(formula)

  tokens.forEach(t => {
    const val = this.toNumber(this.valores[t])
    // substitui todas as ocorrências da variável (boundary)
    expr = expr.replace(new RegExp(`\\b${t}\\b`, 'g'), String(val))
  })

  // segurança: só deixa números, operadores, espaços, ponto e parênteses
  if (!/^[0-9+\-*/().,\s]+$/.test(expr)) return null

  // vírgula vira ponto
  expr = expr.replace(/,/g, '.')

  console.log('formula',expr)

  try {
    // eslint-disable-next-line no-new-func
    const n = Function(`"use strict"; return (${expr});`)()
    return (typeof n === 'number' && isFinite(n)) ? n : null
  } catch (e) {
    return null
  }
},

async onBlurCampo (campo) {
  if (!campo || !campo.nm_atributo) return

  const nm = campo.nm_atributo
  const v = (this.valores && nm in this.valores) ? this.valores[nm] : ''
  const vazio = v === null || v === undefined || String(v).trim() === ''

  // ✅ Se estiver vazio: NÃO valida e NÃO abre Unico automaticamente
  if (vazio) return

  // valida (se tiver regra)
  await this.validarCampoRegra(campo, 'blur')

  // ✅ NUNCA abre Unico aqui. Lupa é que manda.

  // último campo editável: salva
  if (nm === this.ultimoCampoEditavel) {
    this.calcularCampos()
    this.salvarNoLocal()
    return
  }
},

async onEnterCampo (campo) {
  // Enter no último campo faz a mesma coisa
  await this.onBlurCampo(campo)

    // ✅ se não for o último campo editável, avança foco
  if (campo?.nm_atributo && campo.nm_atributo !== this.ultimoCampoEditavel) {
    this.focarProximoCampo(campo)
  }

},

  // ===== Validação de campo por regra =====

  async validarCampoRegra (campo, origem = '') {
  try {
    if (!campo) return false

    const cdRegra = Number(campo.cd_regra_validacao || 0)
    if (!cdRegra || cdRegra <= 0) return true

    const nm = campo.nm_atributo
    if (!nm) return false

    const valor = this.valores ? this.valores[nm] : null
    const valorStr = String(valor == null ? '' : valor).trim()
    if (!valorStr) return false

    // evita repetir validação do mesmo valor
    if (!this.ultimaValidacao) this.ultimaValidacao = {}
    if (!this.validandoCampos) this.validandoCampos = {}

    const key = `${nm}`
    if (this.ultimaValidacao[key] === valorStr) return true

    if (this.validandoCampos[key]) return false
    this.$set(this.validandoCampos, key, true)

    const cfg = this.headerBanco
      ? { headers: { 'x-banco': this.headerBanco } }
      : undefined

    const body = [{
      ic_json_parametro: 'S',
      cd_usuario: Number(localStorage.cd_usuario || 0),
      cd_menu: Number(localStorage.cd_menu || 0),
      cd_modal: Number(this.cdModal || 0),
      cd_regra_validacao: cdRegra,
      origem,
      //nm_atributo: nm,
      //vl_atributo: valorStr,
      // [nm]: valorStr, // 👈 mágica acontece aqui
       ...(nm ? { [nm]: valorStr } : {})
    
    }]

    console.log('[validarCampoRegra] body:', body)

    const { data } = await api.post('/exec/pr_egis_regra_validacao_atributo_modulos', body, cfg)

    // normaliza retorno
    const retorno = Array.isArray(data) ? (data[0] || null) : (data || null)

    // retorno vazio => não achou
    if (!retorno || (typeof retorno === 'object' && Object.keys(retorno).length === 0)) {
      this.$set(this.ultimaValidacao, key, '')
      return false
    }

    // ✅ usa sua função existente
    if (typeof this.aplicarRetornoUnico === 'function') {
      this.aplicarRetornoUnico(retorno)
    } else {
      // fallback: aplica só o que existir em "valores"
      Object.keys(retorno || {}).forEach(k => {
        if (this.valores && this.valores[k] !== undefined) {
          this.$set(this.valores, k, retorno[k])
        }
      })
    }

    this.persistirDraft()

    // critério de “achou”: após aplicar, o campo original ficou preenchido
    const depois = String(this.valores?.[nm] ?? '').trim()
    const achou = !!depois

    this.$set(this.ultimaValidacao, key, achou ? valorStr : '')
    return achou
  } catch (e) {
    console.error('[validarCampoRegra] erro:', e)
    return false
  } finally {
    const nm = campo?.nm_atributo
    if (nm) this.$set(this.validandoCampos, nm, false)
  }
},


  // aplica dados retornados do UnicoFormEspecial
  aplicarRetornoUnico (dados) {
  if (!dados || typeof dados !== 'object') return

  const meta = this.metaCampos || []

  // cria mapa normalizado do retorno
  const mapaDados = {}
  Object.keys(dados).forEach(k => {
    mapaDados[this.normaliza(k)] = dados[k]
  })

  meta.forEach(m => {
    if (!m || !m.nm_atributo) return
    if (String(m.ic_retorno_atributo || '').toUpperCase() !== 'S') return

    // candidatos a buscar no retorno
    const candidatos = [
      m.nm_atributo,
      m.nm_atributo_consulta,
      m.nm_atributo_lookup,
      m.nm_titulo_menu_atributo,
      m.ds_atributo
    ].filter(Boolean)

    let valorEncontrado

    for (const c of candidatos) {
      const key = this.normaliza(c)
      if (mapaDados[key] !== undefined) {
        valorEncontrado = mapaDados[key]
        break
      }
    }

    if (valorEncontrado !== undefined) {
      this.$set(this.valores, m.nm_atributo, valorEncontrado)
    }
  })

  // depois de preencher tudo:
  //this.recalcularCampos()
  this.calcularCampos()
  this.persistirDraft()

},


    // ===== Drag =====
    onDragStart (ev) {
      this.dragStartX = ev.clientX - this.dragX
      this.dragStartY = ev.clientY - this.dragY
      document.addEventListener('mousemove', this.onDragMove)
      document.addEventListener('mouseup', this.onDragEnd)
    },
    onDragMove (ev) {
      this.dragX = ev.clientX - this.dragStartX
      this.dragY = ev.clientY - this.dragStartY
    },
    onDragEnd () {
      document.removeEventListener('mousemove', this.onDragMove)
      document.removeEventListener('mouseup', this.onDragEnd)
    },

    // ===== Helpers UI =====
    labelCampo (campo) {
      return campo.nm_edit_label || campo.nm_titulo_menu_atributo || campo.nm_atributo
    },

resolveComponent (campo) {
      const lista = (campo.Lista_Valor || '').toString().trim()
      const hasLista = lista !== '' && lista !== 'N'
      const hasLookup = campo.nm_lookup_tabela && String(campo.nm_lookup_tabela).trim() !== ''

      // Se tiver Lista_Valor válida OU lookup, usa select
      if (hasLista || hasLookup) return 'q-select'

      const tipo = String(campo.nm_datatype || '').toLowerCase()
      if (tipo === 'checkbox' || tipo === 'boolean' || tipo === 'bool') return 'q-input'
      if (tipo === 'date' || tipo === 'datetime') return 'q-input'

      // default
      return 'q-input'
    },

    resolveType (f) {
      const nome = (f.nm_atributo || '').toLowerCase()
      const titulo = (f.nm_titulo_menu_atributo || '').toLowerCase()
      const tipo = (f.nm_datatype || '').toLowerCase()

      // textarea vindo do meta
      if (tipo === 'textarea' || tipo === 'text_area' || tipo === 'memo') return 'textarea'

      // se o título for "data" ou contiver "data", trata como date
      if (
        titulo.startsWith('data ') ||
        titulo === 'data' ||
        titulo.includes('data pagamento') ||
        titulo.includes('data da baixa')
      ) return 'date'

      if (nome.includes('dt_inicial') || nome.includes('dt_final') || tipo === 'date') return 'date'
      if (/(date|data)/.test(nome)) return 'date'
      if (/(number|inteiro|decimal)/.test(nome)) return 'number'

      return 'text'
    },

    getOptions (campo) {
      const lista = (campo.Lista_Valor || '').toString().trim()
      const hasLista = lista !== '' && lista !== 'N'

      if (hasLista) {
        // suportar formatos:
        // 1) JSON: [{"value":1,"label":"A"}]
        // 2) "1=Ativo;2=Inativo"
        // 3) "A;B;C"
        const asJson = safeParse(lista, null)
        if (Array.isArray(asJson)) {
          return asJson.map(o => ({
            __value: o.value ?? o.__value ?? o.id ?? o.key ?? o,
            __label: o.label ?? o.__label ?? o.text ?? String(o.value ?? o)
          }))
        }

        const parts = lista.split(/[;|,]/).map(s => s.trim()).filter(Boolean)
        return parts.map(p => {
          const [k, ...rest] = p.split('=')
          const val = (rest.length ? k : p).trim()
          const lab = (rest.length ? rest.join('=').trim() : p).trim()
          return { __value: val, __label: lab }
        })
      }

      // Lookup (carregado via carregarMeta)
      if (this.lookupOptions && this.lookupOptions[campo.nm_atributo]) {
        return this.lookupOptions[campo.nm_atributo]
      }

      return []
    },

    estiloCampo (campo) {
      return 'width: 100%;  marginRight: 8px;'
    },

    isSomenteLeitura (campo) {

      if (String(campo.ic_calculado || '').toUpperCase() === 'S') return true

      // se meta trouxer flag de edição
      const ed = String(campo.ic_edicao_atributo || campo.ic_edita_cadastro || '').toUpperCase()
      if (ed === 'N') return true

      //
      const fl = String(campo.fl_somente_leitura || campo.fl_readonly || '').toLowerCase()
      if (fl === 's' || fl === '1' || fl === 'true') return true

      const tipo = String(campo.nm_datatype || '').toLowerCase()
      // se vier explicitamente "readonly" no tipo
      if (tipo.includes('readonly')) return true
      return false

    },

  async onClickLupa (campo) {
  const achou = await this.validarCampoRegra(campo, 'LUPA')
  if (!achou) this.abrirUnicoEspecial(campo)
},
  
  async abrirUnicoEspecial (campo) {
  if (!campo || !campo.cd_menu) return

    // se tiver regra de validação, tenta primeiro
  const cdRegra = Number(campo.cd_regra_validacao || 0)
  if (cdRegra > 0) {
    const achou = await this.validarCampoRegra(campo, 'lupa')
    if (achou) return // ✅ achou e preencheu, então NÃO abre o Unico
  }


  this.campoUnicoAtivo = campo

  // guarda o menu atual
  this.cdMenuAnterior = Number(localStorage.cd_menu || 0)

  // 🔥 ESSENCIAL: o Unico usa cd_menu do localStorage
  localStorage.cd_menu = String(campo.cd_menu)

  this.cd_menu_item_modal = Number(campo.cd_menu)
  this.tituloMenuUnico =
    campo.nm_titulo_menu_atributo ||
    campo.ds_campo_help ||
    campo.nm_atributo ||
    'Busca'

  this.rowUnicoSelecionado = null
  this.showUnicoEspecial = true
},

fecharUnicoEspecial () {
  this.showUnicoEspecial = false

  // restaura menu anterior
  localStorage.cd_menu = String(this.cdMenuAnterior || 0)

  if (!this.campoUnicoAtivo) {
    this.campoUnicoAtivo = null
    return
  }

  const cdMenu = Number(this.campoUnicoAtivo.cd_menu || 0)

  let registro = null
  try {
    // padrão usado pelo UnicoFormEspecial
    registro =
      JSON.parse(sessionStorage.getItem(`registro_selecionado_${cdMenu}`)) ||
      JSON.parse(sessionStorage.getItem('registro_selecionado'))
  } catch (e) {
    registro = null
  }

  if (registro) {
    const dadosBase = registro.data && typeof registro.data === 'object'
  ? registro.data
  : registro

   const dados = this.traduzRegistroSelecionado(dadosBase)

   console.log('Dados retornados do UnicoFormEspecial:', dados );

   this.aplicarRetornoUnico(dados);

   /*
   const nm = this.campoUnicoAtivo.nm_atributo

   if (nm && dados[nm] !== undefined) {
     this.$set(this.valores, nm, dados[nm])
     this.persistirDraft()
    }
  }
  */
  }
  this.campoUnicoAtivo = null
  this.rowUnicoSelecionado = null
},

    normaliza (s) {
  return String(s || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]/g, '')
},

    isSelect (campo) {
      // Se sua meta já marca lookup/lista, ajuste aqui.
      // Mantive simples: se existir Lista_Valor ou nm_lookup_tabela, vira select se options existirem.
      return Boolean(this.lookupOptions[campo.nm_atributo] && this.lookupOptions[campo.nm_atributo].length)
    },

    // ===== Persistência =====
    carregarEstadoLocal () {
      const st = safeParse(localStorage.getItem(this.storageKey) || 'null', null)
      if (!st) return

      if (st && typeof st === 'object') {
        if (st.valores && typeof st.valores === 'object') this.valores = { ...st.valores }
        if (Array.isArray(st.itens)) this.itens = st.itens
      }
    },

    salvarEstadoLocal () {
      const payload = {
        valores: this.valores || {},
        itens: this.itens || []
      }
      localStorage.setItem(this.storageKey, JSON.stringify(payload))
    },

    persistirDraft () {
      // chamado a cada mudança de campo
      this.salvarEstadoLocal()
    },

    limparLocal () {
      try { localStorage.removeItem(this.storageKey) } catch (e) {}
    },

    // ===== Boot =====

    async bootstrap () {
      this.carregarEstadoLocal()
      await this.carregarMeta()
      // depois do meta, garante que não perde o draft:
      this.salvarEstadoLocal()

        // ✅ foco inicial ao abrir o modal (após carregar meta)
        this.$nextTick(() => {
          setTimeout(() => this.focarPrimeiroCampo(), 50)
        })
        // ...

    },

  listaEditaveisOrdenada () {
    return (this.metaCampos || [])
      .filter(m =>
        String(m.ic_edicao_atributo || '').toUpperCase() === 'S' &&
        !this.isSomenteLeitura(m)
      )
      .slice()
      .sort((a, b) =>
        Number(a.nu_ordem || a.qt_ordem_atributo || 0) -
        Number(b.nu_ordem || b.qt_ordem_atributo || 0)
      )
  },

focarCampoPorNome (nm) {
  this.$nextTick(() => {
    const r = this.$refs[`fld_${nm}`]
    const comp = Array.isArray(r) ? r[0] : r
    if (!comp) return

    // Quasar components normalmente expõem focus()
    if (typeof comp.focus === 'function') {
      comp.focus()
      return
    }

    // fallback: tenta focar o input interno
    const root = comp.$el || comp
    const inp = root && root.querySelector ? root.querySelector('input,textarea,[tabindex]') : null
    if (inp && typeof inp.focus === 'function') inp.focus()
  })
},

  async focarProximoCampo (campoAtual) {
    const editaveis = this.listaEditaveisOrdenada()
    if (!editaveis.length) return

    const atualNm = campoAtual?.nm_atributo
    const idx = editaveis.findIndex(m => m.nm_atributo === atualNm)

    // se não achou o atual, foca no primeiro editável
    if (idx < 0) {
      this.focarCampoPorNome(editaveis[0].nm_atributo)
      return
    }

    const proximo = editaveis[idx + 1]

    // se acabou a lista: salva e o salvarNoLocal já volta o foco pro primeiro
    if (!proximo) {
      this.calcularCampos()
      this.salvarNoLocal() // já chama focarPrimeiroCampo() no final :contentReference[oaicite:3]{index=3}
      return
    }

    this.focarCampoPorNome(proximo.nm_atributo)
  },


    lerMapaConsultaParaAtributo () {
  try {
    return JSON.parse(sessionStorage.getItem('mapa_consulta_para_atributo') || '{}')
  } catch (e) {
    return {}
  }
},

traduzRegistroSelecionado (rowTela) {
  const mapa = this.lerMapaConsultaParaAtributo()
  const rowTec = {}

  Object.keys(rowTela || {}).forEach((kTela) => {
    const kTec = mapa[kTela]
    if (kTec) rowTec[kTec] = rowTela[kTela]
  })

  return { ...rowTela, ...rowTec }
},

    // ===== Meta / Procedure =====
    async carregarMeta () {

      // 🔁 AQUI é a mudança principal: procedure do GRID modal composição
      this.loading = true
      
      try {
        
       const cfg = this.headerBanco
      ? { headers: { 'x-banco': this.headerBanco } }
      : undefined

        const body = [{
          cd_modal: Number(this.cdModal || 0),
          cd_usuario: Number(localStorage.cd_usuario || 0),
          cd_menu: Number(localStorage.cd_menu || 0),
          ic_json_parametro: 'S',
        }]

        // ✅ TROCA pedida
        const { data } = await api.post('/exec/pr_egis_grid_modal_composicao', body, cfg)

        //this.meta = Array.isArray(data) ? data : []

        this.meta = Array.isArray(data)
  ? Object.values(
      data.reduce((acc, m) => {
        if (!m || !m.nm_atributo) return acc
        if (!acc[m.nm_atributo]) acc[m.nm_atributo] = m
        return acc
      }, {})
    )
  : []

        // Título/subtítulo (se vier no meta)
        const m0 = this.meta[0] || {}
        this.tituloModal = m0.nm_titulo_modal || this.tituloModal
        this.subTituloModal = m0.ds_subtitulo_modal || this.subTituloModal
        this.nm_procedimento = m0.nm_procedimento || this.nm_procedimento
        this.cd_parametro_procedimento = m0.cd_parametro_procedimento || this.cd_parametro_procedimento
        this.lookupOptions = m0.lookup_options || {}

        // depois de carregar o meta, inicializa os valores do form (garante chaves reativas)

        this.inicializarValoresDoForm()


        //

      } catch (e) {
        console.error('Erro ao carregar meta do ModalGridComposicao:', e)
      } finally {
        this.loading = false
      }
    },

    // ===== Salvar item (LocalStorage + grid) =====
    
    salvarNoLocal () {

      
      this.loadingSalvar = true

       console.log('valores agora =>', JSON.stringify(this.valores))

       try {

       // monta item pegando exatamente as chaves do meta
       const item = {}
       ;(this.metaCampos || []).forEach(m => {
         if (!m || !m.nm_atributo) return
      item[m.nm_atributo] = this.valores[m.nm_atributo]
    })

    // rowid
    item.__rowid = `${Date.now()}_${Math.random().toString(16).slice(2)}`

    // ✅ Vue2: push é o caminho mais seguro de reatividade
    if (!Array.isArray(this.itens)) this.itens = []
    
    this.itens.push(item)
    this.itens = [...this.itens]

    this.salvarEstadoLocal()

    // limpa form (mantém chaves)
    ;(this.metaCampos || []).forEach(m => {
      if (!m || !m.nm_atributo) return
      this.$set(this.valores, m.nm_atributo, '')
    })

    this.persistirDraft()
    this.focarPrimeiroCampo()

  } finally {
    this.loadingSalvar = false
  }
},
   
    removerItem (rowid) {
      this.itens = (this.itens || []).filter(r => r.__rowid !== rowid)
      this.salvarEstadoLocal()
      this.persistirDraft()
      this.focarPrimeiroCampo()
      
    },

    // ===== Confirmar final (backend + limpa localStorage) =====
    
   async confirmar () {
  this.loadingConfirmar = true
  try {
    const itensLimpos = (this.itens || []).map(r => {
      const cp = { ...r }
      delete cp.__rowid
      return cp
    })

    // (opcional) registros selecionados no padrão técnico igual ModalComposicao
    const docsSelecionados = (this.registrosSelecionados || []).map((row) =>
      montaDadosTecnicos(row, Array.isArray(this.gridMeta) ? this.gridMeta : [])
    )

    const body = [
      {
        ic_json_parametro: 'S',
        cd_parametro: Number(this.cd_parametro_procedimento || 0),
        cd_usuario: Number(localStorage.cd_usuario || 0),
        cd_modal: Number(this.cdModal || 0),

        // ✅ aqui vai o “conteúdo do modal”
        dados_modal: {
          itens: itensLimpos
        },

        // ✅ mantém padrão do ModalComposicao
        dados_registro: docsSelecionados
      }
    ]

    const cfg = this.headerBanco
      ? { headers: { 'x-banco': this.headerBanco } }
      : undefined

    console.log('[confirmar ModalGridComposicao] body =>', body)

    // ✅ igual ModalComposicao.vue
    if (!this.nm_procedimento) {
      throw new Error('nm_procedimento não veio no meta (m0.nm_procedimento)')
    }

    await api.post(`/exec/${this.nm_procedimento}`, body, cfg)

    // limpa local e fecha
    this.limparLocal()
    this.$emit('sucesso')
    this.internalVisible = false
  } catch (e) {
    console.error('Erro ao confirmar ModalGridComposicao:', e)
    if (e && e.response) {
      console.error('[API] status:', e.response.status)
      console.error('[API] data:', e.response.data)
    }
  } finally {
    this.loadingConfirmar = false
  }
},

    cancelar () {
      // não limpa localStorage (pedido)
      this.internalVisible = false
      this.$emit('fechar')
    },

    inicializarValoresDoForm () {
  if (!Array.isArray(this.metaCampos)) return

  // mantém o que já foi digitado/local, mas cria as chaves faltantes de forma reativa
  const atual = this.valores && typeof this.valores === 'object' ? this.valores : {}
  const novo = { ...atual }

  this.metaCampos.forEach(m => {
    if (!m || !m.nm_atributo) return
    if (novo[m.nm_atributo] === undefined) {
      // Vue2: garante reatividade
      this.$set(novo, m.nm_atributo, '')
    }
  })

  this.valores = novo
},

toNumber (v) {
  if (v == null) return 0
  if (typeof v === 'number') return v
  const s = String(v).replace(/[R$\s]/g, '').replace(/\./g, '').replace(',', '.')
  const n = Number(s)
  return isNaN(n) ? 0 : n
},

calcularCampos () {
  const meta = this.metaCampos || []
  if (!meta.length) return

  // contexto com valores, mas normalizando números
  const ctx = {}

  meta.forEach(m => {
    const k = m.nm_atributo
    const tipo = String(m.nm_datatype || '').toLowerCase()
    const v = this.valores[k]

    if (tipo.includes('number') || tipo.includes('decimal') || tipo.includes('int') || tipo.includes('currency') || k.startsWith('qt_') || k.startsWith('vl_')) {
      ctx[k] = this.toNumber(v)
    } else {
      ctx[k] = v
    }
  })

  meta.forEach(m => {
    if (String(m.ic_calculado || '').toUpperCase() !== 'S') return
    const formula = (m.nm_formula_calculo || '').trim()
    if (!formula) return

    // substitui variáveis pelo ctx
    let expr = formula
    Object.keys(ctx).forEach(k => {
      expr = expr.replace(new RegExp(`\\b${k}\\b`, 'g'), String(ctx[k] ?? 0))
    })

    // segurança básica
    if (!/^[0-9+\-*/().\s]+$/.test(expr)) return

    try {
      // eslint-disable-next-line no-new-func
      const r = Function(`"use strict"; return (${expr});`)()
      this.$set(this.valores, m.nm_atributo, (typeof r === 'number' && isFinite(r)) ? r : 0)
    } catch (e) {
      this.$set(this.valores, m.nm_atributo, 0)
    }
  })
},


//
recalcularCampos () {
  const meta = this.metaCampos || []

  meta.forEach(m => {
    if (!m || !m.nm_atributo) return
    if (String(m.ic_calculado || '').toUpperCase() !== 'S') return

    const formula = m.nm_formula_calculo || m.ds_formula_calculo || ''
    if (formula) {
      const r = this.avaliarFormula(formula)
      if (r != null) this.$set(this.valores, m.nm_atributo, r)
    }
  })
},

     onCampoAlterado (campo, valor) {
       if (!campo || !campo.nm_atributo) return

       // garante a gravação
       this.$set(this.valores, campo.nm_atributo, valor)
       this.autoSaveArmed = true

  // recalcula o que for calculado
  //this.recalcularCampos()
      this.calcularCampos() 

  // salva rascunho
  this.persistirDraft()
  
},



  }
}
</script>

<style>
/* Altura máxima para o conteúdo, se tiver muitos campos */
.q-card-section {
  max-height: 70vh;
  overflow-y: auto;
}


.top-badge {
  position: relative;
  top: -10px;
  margin-left: -1px;
}

/* opcional: deixa a grid mais “limpa” */
.q-table__container {
  border: none;
} 


/* pinta o input (texto) */
.campo-readonly {
  background-color: #e3f2fd !important;
}
/* pinta a caixa toda do quasar (onde estava o espaço branco) */
:deep(.q-field--disabled .q-field__control),
:deep(.q-field--readonly .q-field__control),
:deep(.q-field--disabled .q-field__control-container),
:deep(.q-field--readonly .q-field__control-container) {
  background-color: #e3f2fd !important;
  border-radius: 4px;
}

/* opcional: deixa texto com “cara” de leitura */
:deep(.q-field--disabled .q-field__native),
:deep(.q-field--readonly .q-field__native) {
  color: #1565c0;
}

.input-readonly {
  background-color: #e3f2fd !important;
}

.campo-readonly .q-field__native {
  background-color: #e3f2fd !important;
}

.campo-readonly ::v-deep(.q-field__native) {
  background-color: #e3f2fd !important;
}

</style>
