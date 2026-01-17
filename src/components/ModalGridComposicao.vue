<template>
  <div>
  <q-dialog v-model="internalVisible" maximized persistent>
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
                {{ tituloMenu || '' }} - {{ tituloModal || 'Composição' }}
                <q-badge rounded class="q-ml-sm top-badge" color="deep-orange-7" :label="String(cdModalBadge)" />
                <q-badge 
                   v-if="false && itens.length" color="deep-purple-7" class="q-ml-sm">{{ itens.length }}</q-badge>
              </div>

              <div class="text-caption text-grey-7">
                {{ subTituloModal || '' }}
              </div>
            </div>

            <q-bar 
              v-if="false"
              class="bg-white text-black">

  <q-space />

  <q-btn dense color="deep-purple-7" label="Salvar" icon="save" @click="salvarNoLocal" />
  <q-btn dense color="deep-purple-7" label="Limpar" icon="cleaning_services" @click="limparDigitacao" />
  <q-btn
  v-if="Number(cd_relatorio || 0) > 0"
  color="deep-purple-7"
  icon="description"
  label="Relatório"
  :loading="loadingRelatorio"
  style="margin-left: 5px;"
  @click="abrirRelatorio" />

  <q-btn dense color="deep-purple-7" label="Cancelar" icon="close" @click="cancelarModal" />
  <q-btn dense color="deep-purple-7" label="Confirmar" icon="check" @click="confirmarModal" />
  <q-btn rounded dense color="deep-purple-7" round icon="close" v-close-popup />

</q-bar>

 <q-btn rounded dense color="deep-purple-7" round icon="close" v-close-popup />

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
                  :mask="isCampoData(campo) ? '##/##/####' : undefined"
                  :fill-mask="isCampoData(campo) ? '_' : undefined"
                  @input="onCampoAlterado(campo, $event)"
                  @blur="onBlurCampo(campo)"
                  @keydown="onKeyDownCampo(campo, $event)"
                            >
                
                <template v-slot:append>

  <!-- Calendário para campos de data -->
  <q-icon
    v-if="isCampoData(campo)"
    name="event"
    class="cursor-pointer"
    @click.stop
  >
    <q-popup-proxy transition-show="scale" transition-hide="scale">
      <q-date
        v-model="valores[campo.nm_atributo]"
        mask="DD/MM/YYYY"
        @input="() => onDataSelecionada(campo)"
      />
    </q-popup-proxy>
  </q-icon>

  <!-- 📎 Arquivo: Upload (ic_tipo_arquivo = 1) -->
  <q-btn
     v-if="!isSomenteLeitura(campo) && isCampoArquivo(campo) && tipoArquivo(campo) === 1"
  dense flat round
  class="q-ml-xs"
  icon="attach_file"
  @click.stop="abrirSeletorArquivo(campo)"
>
  <q-tooltip>Anexar arquivo</q-tooltip>
</q-btn>

  <!-- ⬇️ Arquivo: Baixar/Salvar como (ic_tipo_arquivo = 2) -->
  <q-btn
    v-if="isCampoArquivo(campo) && tipoArquivo(campo) === 2"
    dense flat round
    class="q-ml-xs"
    icon="save_alt"
    @click.stop="baixarConteudoTexto()"
  >
  <q-tooltip>Baixar - Salvar como</q-tooltip>
</q-btn>

<!-- 📄 Relatório do atributo (igual UnicoFormEspecial) -->
<q-btn
  v-if="temRelatorioAtributo(campo)"
  icon="description"
  flat
  round
  dense
  class="q-ml-xs"
  color="deep-purple-7"
  :disable="!podeRelatorioDoCampo(campo)"
  :loading="loadingRelatorio"
  @click.stop="onRelatorioDoCampo(campo)"
  :title="`Relatório de ${labelCampo(campo)}`"
/>


  <!-- Lupa (continua igual) -->
  <q-btn
    v-if="!isSomenteLeitura(campo) && Number(campo.cd_menu || 0) !== 0"
    dense
    flat
    round
    icon="search"
    @click.stop="onClickLupa(campo)"
  >
  
    <q-tooltip>Buscar</q-tooltip>

  </q-btn></template>

                               </component>
                </div>
             </div>
            </div>

        <!-- Ações do form -->

        <div class="row items-center q-mt-md" style="margin-top: -10px;">
          <q-btn
            color="deep-purple-7"
            icon="save"
            label="Salvar"
            :loading="loadingSalvar"
            @click="salvarNoLocal"
          />
         <q-btn
            color="deep-purple-7"
            icon="clear"
            label="Limpar"
            style="margin-left: 5px;"
            @click="limparDigitacao"
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

<!-- Conteúdo do Arquivo (quando ic_arquivo_texto = 'S') -->

<div v-if="mostrarArquivoTexto" class="q-mt-md">
  <div class="text-subtitle2 text-grey-8 q-mb-xs">Conteúdo do Arquivo</div>

  <q-input
    v-model="retornoArquivoTexto"
    type="textarea"
    outlined
    dense
    autogrow
    readonly
    class="full-width"
  />
</div>


        <!-- GRID dos itens salvos -->

<div class="q-mt-lg"
  v-if="!ocultarGridPorArquivoTexto">
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
  v-if="itensGrid.length"
  :data-source="itensGrid"
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

  <template #acoesTemplate="{ data: cell }">
  <div class="row no-wrap items-center justify-center q-gutter-xs">

    <q-btn
      dense flat round icon="edit" color="deep-purple-7"
      @click.native.stop="onActionEditar(cell && cell.data)"
    >
      <q-tooltip>Editar</q-tooltip>
    </q-btn>

    <q-btn
      dense flat round icon="delete" color="negative"
      @click.native.stop="removerPorRowId(cell && cell.data && cell.data.__rowid)"
    >
      <q-tooltip>Remover</q-tooltip>
    </q-btn>

  </div></template>

  <!-- Coluna de Ações -->

  <dx-column
    caption="Ações"
    width="80"
    alignment="center"
    :fixed="true"
    fixed-position="left"
    :allow-sorting="false"
    :allow-filtering="false"
    :allow-header-filtering="false"
    :allow-search="false"
    cell-template="acoesTemplate"
  />
  <!-- Colunas dinâmicas pelo meta -->

<dx-column
  v-for="(col, i) in gridColumnsDx"
  :key="`dxcol_${col.dataField}_${i}`"
  :data-field="col.dataField"
  :caption="col.caption"
  :data-type="col.dataType"
  :format="col.format"
  :alignment="col.alignment"
  :customize-text="col.customizeText"
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
    <!-- input único para upload de arquivo (não repetir por campo) -->
<input
  ref="fileHidden"
  type="file"
  style="display:none"
  @change="onFileSelectedHidden"
/>

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

const ENDPOINT_EXEC_SQL = '/exec/pr_egis_sql_exec'


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
      dadosArquivo: null,
      headerBanco: localStorage.nm_banco_empresa,
      loading: false,
      internalVisible: this.value,

      loadingSalvar: false,
      loadingConfirmar: false,

      meta: [],
      valores: {},
      itens: [],
      tituloMenu : localStorage.nm_menu_titulo,
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
      editingRowId: null,     // quando != null, estamos editando
      editingIndex: -1,
      _campoArquivoAtual: null,
      retornoArquivoTexto: '',
      cd_relatorio: 0,
      loadingRelatorio: false,

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
    
    ocultarGridPorArquivoTexto () {
      return (this.metaCampos || []).some(m => String(m?.ic_arquivo_texto || '').toUpperCase() === 'S')
    },

    cdModalBadge () { return Number(this.cdModal || 0) },

    metaCampos () {
  return Array.isArray(this.meta) ? this.meta : []
},

metaCamposold () {
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

mostrarArquivoTexto () {
  return (this.metaCampos || []).some(m => String(m?.ic_arquivo_texto || '').toUpperCase() === 'S')
},

    // compat: alguns pontos usam this.gridMeta (padrão do ModalComposicao)
    gridMeta () {
      return this.metaCampos || []
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

  itensGrid () {
    this.normalizeItens()
    return this.itens
  },

    //

    gridColumnsDx () {
  
      // ⚡️ performance: só depende do metaCampos (computed já cacheia)
  const meta = Array.isArray(this.metaCampos) ? this.metaCampos : []

  // monta colunas únicas por nm_atributo (evita repetição)
  const map = new Map()

  for (const m of meta) {
    if (!m || !m.nm_atributo) continue
    const dataField = m.nm_atributo
    if (dataField === '__rowid') continue

    // visibilidade / ordem
    const ordem = Number(m.nu_ordem || m.qt_ordem_atributo || 0)

    const col = {
      dataField,
      caption: m.ds_atributo || m.nm_atributo,
      visible: String(m.ic_visivel_grid || 'S').toUpperCase() !== 'N',
      width: m.nu_largura_grid ? Number(m.nu_largura_grid) : undefined,
      alignment: 'left',
      dataType: undefined,
      format: undefined,
      ordem
    }

    const dt = String(m.nm_datatype || '').toLowerCase()
    const nm = String(m.nm_atributo || '').toLowerCase()

    
    // Datas
    if (dt.includes('date') || dt.includes('data')) {
      col.dataType = 'date'
      col.format = 'dd/MM/yyyy'
    }

    // Inteiros / Quantidades
    const isQt = nm.startsWith('qt_') || nm.includes('quantidade') || dt.includes('int')
    if (isQt) {
      col.dataType = 'number'
      col.alignment = 'right'
      col.format = { type: 'fixedPoint', precision: 0 }
    }

    // Moeda / Decimais
    const isMoney = dt.includes('currency') || dt.includes('money') || nm.startsWith('vl_') || nm.includes('valor')
    const isDecimal = dt.includes('decimal') || dt.includes('numeric') || dt.includes('float') || dt.includes('double')
    if (isMoney) {
      col.dataType = 'number'
      col.alignment = 'right'
      col.format = { type: 'currency', precision: 2 }
    } else if (isDecimal && !isQt) {
      col.dataType = 'number'
      col.alignment = 'right'
      col.format = { type: 'fixedPoint', precision: 2 }
    }

    // Percentual (se existir)
    if (dt.includes('percent') || dt.includes('%')) {
      col.dataType = 'number'
      col.alignment = 'right'
      col.format = { type: 'percent', precision: 2 }
    }
    

    //const dt = String(m.nm_datatype || '').toLowerCase()
//const nm = String(m.nm_atributo || '').toLowerCase()

col.customizeText = (cell) => {
  const v = cell && cell.value

  if (v === null || v === undefined || v === '') return ''

  // datas
  if (col.dataType === 'date') {
    const d = (v instanceof Date) ? v : new Date(v)
    if (isNaN(d.getTime())) return String(v)
    return d.toLocaleDateString('pt-BR')
  }

  // números
  if (col.dataType === 'number') {
    //const num = Number(v)
    const num = this.toNumberBR(v)  

    if (isNaN(num)) return String(v)

    const isMoney = dt.includes('currency') || dt.includes('money') || nm.startsWith('vl_') || nm.includes('valor')
    const isInt = nm.startsWith('qt_') || dt.includes('int')

    if (isMoney) {
      return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(num)
    }

    if (dt.includes('percent') || dt.includes('%')) {
      return new Intl.NumberFormat('pt-BR', { style: 'percent', minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(num)
    }

    if (isInt) {
      return new Intl.NumberFormat('pt-BR', { maximumFractionDigits: 0 }).format(num)
    }

    return new Intl.NumberFormat('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(num)
  }

  return String(v)

}

    // evita sobrescrever caso já exista uma col melhor (mantém a primeira por padrão)
    if (!map.has(dataField)) map.set(dataField, col)
  }

  // ordena pela ordem do meta
  return [...map.values()].sort((a, b) => Number(a.ordem || 0) - Number(b.ordem || 0))

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
    },

    registrosSelecionados: {
      deep: true,
      handler () {
       // se o modal está aberto e o meta já carregou, reaplica
       if (this.internalVisible && (this.metaCampos || []).length) {
          this.aplicarRegistroSelecionado()
          this.inicializarValoresDoForm()
        }
  }
},

  },

  created () {
    this.headerBanco = localStorage.nm_banco_empresa;

    if (this.internalVisible) this.bootstrap()
  },

  methods: {

    montarSqlComParametros (sql) {
  const s = String(sql || '')
  if (!s.trim()) return ''

  // encontra tokens do tipo @alguma_coisa
  const tokens = Array.from(new Set(s.match(/@\w+/g) || []))

  let out = s
  tokens.forEach(tok => {
    const valor = this.resolverParametro(tok) // sem o @
    // se não achou valor, deixa como está (ou você pode forçar NULL)
    if (valor === null || valor === undefined || String(valor).trim() === '') return

    // se for número: sem aspas; senão: com aspas e escapando
    const isNum = !Number.isNaN(Number(valor)) && String(valor).trim() !== ''
    const repl = isNum
      ? String(Number(valor))
      : `'${String(valor).replace(/'/g, "''")}'`

    // substitui TODAS as ocorrências desse token
    out = out.replace(new RegExp(tok.replace('@', '\\@'), 'g'), repl)
  })

  return out
},

    resolverParametro (nome) {
  const key = String(nome || '').replace(/^@/, '').trim()
  if (!key) return null

  // 1) se existir no componente (data/computed)
  if (this[key] !== undefined && this[key] !== null && String(this[key]).trim() !== '') {
    return this[key]
  }

  // 2) se estiver nos valores do modal
  if (this.valores?.[key] !== undefined && this.valores?.[key] !== null && String(this.valores[key]).trim() !== '') {
    return this.valores[key]
  }

  // 3) localStorage (fallback)
  const ls = localStorage.getItem(key)
  if (ls !== null && String(ls).trim() !== '') return ls

  return null
},

    async onChangeCampo (campo) {
      if (Number(campo?.ic_tipo_validacao || 0) !== 1) return
      await this.aplicarValidacaoDoAtributo(campo)
    },



async aplicarValidacoesPorTipo (tipo) {
  const t = Number(tipo || 0)

  const lista = (this.metaCampos || []).filter(a =>
    Number(a?.ic_tipo_validacao || 0) === t &&
    String(a?.ds_atributo_validacao || '').trim() !== ''
  )

  for (const attr of lista) {
    await this.aplicarValidacaoDoAtributo(attr)
  }
},

extrairPrimeiroValor (data) {
  const row = Array.isArray(data) ? (data[0] || null) : (data || null)
  if (!row) return null

  if (typeof row === 'string' || typeof row === 'number') return row

  if (typeof row === 'object') {
    const keys = Object.keys(row)
    if (!keys.length) return null
    return row[keys[0]]
  }
  return null
},

async aplicarValidacoesTipo3 () {
  const lista = (this.metaCampos || []).filter(a =>
    Number(a?.ic_tipo_validacao || 0) === 3 &&
    String(a?.ds_atributo_validacao || '').trim() !== ''
  )

  for (const attr of lista) {
    await this.aplicarValidacaoDoAtributo(attr)
  }
},


async aplicarValidacaoDoAtributo (attr) {
  const sql = String(attr?.ds_atributo_validacao || '').trim()
  if (!sql) return

  const nm = String(attr?.nm_atributo || '').trim()
  if (!nm) return

  const data = await this.executarSqlValidacao(sql)
  const valor = this.extrairPrimeiroValor(data)

  const finalValue =
    (valor !== undefined && valor !== null && String(valor).trim() !== '')
      ? (Number.isNaN(Number(valor)) ? String(valor) : Number(valor))
      : ''

  this.$set(this.valores, nm, finalValue)
},

    async executarSqlValidacao (sqlText) {
  const cfg = this.headerBanco
    ? { headers: { 'x-banco': this.headerBanco } }
    : undefined

  const sqlFinal = this.montarSqlComParametros(sqlText)

  const payload = [{
    ic_json_parametro: 'S',
    cd_menu: Number(localStorage.cd_menu || 0),
    cd_usuario: String(localStorage.cd_usuario || 0),
    ds_sql: sqlFinal
  }]

  console.log('[executarSqlValidacao] ds_sql:', sqlFinal)

  const { data } = await api.post('/exec/pr_egis_sql_exec', payload, cfg)
  return data
},


     normalizarValorDocumento (raw) {
  // null/undefined
  if (raw === null || raw === undefined) return null

  // string
  if (typeof raw === 'string') {
    const s = raw.trim()
    if (!s) return null
    // se for número em string, retorna número
    const n = Number(s)
    return Number.isNaN(n) ? s : n
  }

  // number
  if (typeof raw === 'number') {
    return raw
  }

  // boolean (raro)
  if (typeof raw === 'boolean') {
    return raw ? 1 : 0
  }

  // objeto (ex.: q-select)
  if (typeof raw === 'object') {
    // padrões comuns
    if (raw.value !== undefined) return this.normalizarValorDocumento(raw.value)
    if (raw.id !== undefined) return this.normalizarValorDocumento(raw.id)

    // tenta achar um "cd_*" qualquer
    const keyCd = Object.keys(raw).find(k => /^cd_/i.test(k))
    if (keyCd) return this.normalizarValorDocumento(raw[keyCd])

    // fallback: não sei extrair
    return null
  }

  return null
},

podeRelatorioDoCampo (attr) {
  // tem relatório?
  const cdRel = Number(attr?.cd_atributo_relatorio ?? attr?.cd_relatorio_atributo ?? 0)
  if (cdRel <= 0) return false

  // valor do input -> cd_documento
  const raw = this.valores?.[attr?.nm_atributo]
  const doc = this.normalizarValorDocumento(raw)

  // regra: habilita apenas se doc != 0
  if (doc === null) return false
  if (typeof doc === 'number') return doc !== 0
  // string: "0" desabilita, resto habilita
  return String(doc).trim() !== '' && String(doc).trim() !== '0'
},


      temRelatorioAtributo (attr) {
  // aceita tanto cd_atributo_relatorio quanto cd_atributo_relatorio (se variar o nome)
  const v = attr?.cd_atributo_relatorio ?? attr?.cd_atributo_relatorio
  return Number(v || 0) > 0
},

async onRelatorioDoCampo (attr) {
  console.log('[onRelatorioDoCampo] attr:', attr)

  const cd_relatorio = Number(attr?.cd_atributo_relatorio ?? this.cd_relatorio ?? 0)

  // pega o valor digitado no campo (normalmente um código/id)
  const raw = this.valores?.[attr?.nm_atributo]
  const cd_documento = this.normalizarValorDocumento(raw)

  /*
  const cd_documento = (raw !== undefined && raw !== null && String(raw).trim() !== '')
    ? (Number.isNaN(Number(raw)) ? String(raw) : Number(raw))
    : null
  */

  console.log('[onRelatorioDoCampo] raw:', raw, 'cd_documento:', cd_documento)
  console.log('[onRelatorioDoCampo] cd_relatorio:', cd_relatorio, 'cd_documento:', cd_documento)

  //await this.onRelatorioGrid({ ...(this.valores || {}) }, { cd_relatorio, cd_documento })

  await this.onRelatorioGrid(
     { ...(this.valores || {}) },
     { cd_relatorio, cd_documento, nm_parametro: attr?.nm_atributo } 
  )

},

async onRelatorioGrid (registro = {}, opts = {}) {
  try {
    const cd_relatorio = Number(opts.cd_relatorio || 0)
    const cd_documento = (opts.cd_documento !== undefined ? opts.cd_documento : null)

    if (!cd_relatorio) {
      this.$q?.notify?.({
        type: 'warning',
        position: 'center',
        message: 'Relatório não configurado para este campo.'
      })
      return
    }

    this.loadingRelatorio = true

    const cfg = this.headerBanco
      ? { headers: { 'x-banco': this.headerBanco } }
      : undefined


      const nm_parametro = String(opts?.nm_parametro || '').trim()

      const payloadRow = {
      ic_json_parametro: 'S',
      cd_menu: Number(localStorage.cd_menu || 0),
      cd_usuario: String(localStorage.cd_usuario || 0),
      cd_relatorio
    }

    // ✅ parâmetro dinâmico: nome do atributo recebe o valor do input
    if (nm_parametro) {
      payloadRow[nm_parametro] = cd_documento
    } else {
      // fallback (se por algum motivo não vier o nome)
      payloadRow.cd_documento = cd_documento
    }

const payload = [payloadRow]

console.log('[onRelatorioGrid] payload:', payload)

    // mesmo padrão do Unico: payload em array
    /*
    const payload = [{
      ic_json_parametro: 'S',
      cd_menu: Number(localStorage.cd_menu || 0),
      cd_usuario: String(localStorage.cd_usuario || 0),
      cd_relatorio,
      cd_documento,
      id: cd_documentoth
    }]
   */

    console.log('[onRelatorioGrid] payload:', payload, cfg)

    const { data } = await api.post('/exec/pr_egis_relatorio_padrao', payload, cfg)

    console.log('[onRelatorioGrid] data:', data)

    //
    const row = Array.isArray(data) ? (data[0] || null) : (data || null)

// ✅ 1) casos diretos por nome conhecido
let html =
  row?.RelatorioHTML ??
  row?.RelatorioHtml ??
  row?.relatoriohtml ??
  row?.html ??
  row?.HTML ??
  null

// ✅ 2) caso específico do seu retorno: chave vazia ''
if (!html && row && typeof row === 'object' && row[''] != null) {
  html = row['']
}

// ✅ 3) fallback geral: pega o PRIMEIRO valor do objeto
if (!html && row && typeof row === 'object') {
  const firstVal = Object.values(row)[0]
  if (typeof firstVal === 'string') html = firstVal
}

// ✅ 4) fallback: procurar qualquer string grande com cara de html
if (!html && row && typeof row === 'object') {
  const candidatos = Object.values(row).map(v => {
    // tenta converter para string se for algo tipo Buffer/obj
    if (typeof v === 'string') return v
    if (v == null) return null
    try { return String(v) } catch (_) { return null }
  }).filter(Boolean)

  html = candidatos.find(s =>
    s.includes('<style') || s.includes('<html') || s.includes('<div') || s.includes('class="report"')
  ) || null
}

// ✅ 5) se row vier string direto
if (!html && typeof row === 'string') {
  html = row
}

if (!html) {
  console.log('[onRelatorioGrid] row:', row)
  console.log('[onRelatorioGrid] row keys:', row && typeof row === 'object' ? Object.keys(row) : typeof row)
  throw new Error('RelatorioHTML não retornado (nenhum campo HTML encontrado)')
}

    //
    const win = window.open('about:blank', '_blank')
    if (!win) throw new Error('Popup bloqueado pelo navegador')

    win.document.open()
    win.document.write(String(html))
    win.document.close()
  } catch (e) {

    console.error('[onRelatorioGrid] erro:', e)
    
     const msg =
    e?.response?.data?.message ||
    e?.response?.data?.error ||
    (typeof e?.response?.data === 'string' ? e.response.data : '') ||
    e?.message ||
    'Erro ao gerar relatório.'

  this.$q?.notify?.({
    type: 'negative',
    position: 'center',
    message: msg
  })
  } finally {
    this.loadingRelatorio = false
  }
},

       limparRegistroParaPayload (obj) {
      const out = { ...(obj || {}) }
      // remove chaves técnicas (ex.: __rowid)
      Object.keys(out).forEach(k => { if (String(k).startsWith("__")) delete out[k] })
      return out
    },

    extrairIdRegistro (obj) {
      const o = obj || {}
      const candidatos = ["id", "cd_documento", "cd_composicao", "cd_item", "cd_registro"]
      for (const k of candidatos) {
        const v = o[k]
        if (v !== undefined && v !== null && String(v).trim() !== "") {
          const n = Number(v)
          return Number.isNaN(n) ? String(v) : n
        }
      }
      // fallback: primeiro campo "cd_*" que pareça id
      const k2 = Object.keys(o).find(k => /^cd_/i.test(k) && (/_id$/i.test(k) || /codigo|chave|documento|registro/i.test(k)))
      if (k2) {
        const v = o[k2]
        const n = Number(v)
        return Number.isNaN(n) ? String(v) : n
      }
      return null
    },

    
        async abrirRelatorio () {
      const cdRel = Number(this.cd_relatorio || 0)
      if (!cdRel) {
        this.notificar("Este modal não possui relatório configurado (cd_relatorio=0).", "warning")
        return
      }

      try {
        this.loadingRelatorio = true

        const registroLimpo = this.limparRegistroParaPayload(this.valores)
        const cd_documento = this.extrairIdRegistro(registroLimpo)

        const payload = [{
          cd_empresa: Number(localStorage.cd_empresa || 0),
          cd_modulo: Number(localStorage.cd_modulo || 0),
          cd_usuario: Number(localStorage.cd_usuario || 0),
          cd_menu: Number(localStorage.cd_menu || 0),
          dt_inicial: localStorage.dt_inicial,
          dt_final: localStorage.dt_final,
          cd_modal: Number(this.cdModal || 0),
          cd_relatorio: cdRel,
          cd_documento: cd_documento,
          id: cd_documento,
          registro: registroLimpo,
        }]

        const resp = await api.post("/exec/pr_egis_relatorio_padrao", payload)
        const data = resp && resp.data
        const row = Array.isArray(data) ? data[0] : data

        const html = String((row && (row.RelatorioHTML || row.relatoriohtml)) || "")
        if (!html) throw new Error("RelatorioHTML não retornado")

        const win = window.open("about:blank", "_blank")
        if (!win) throw new Error("Popup bloqueado pelo navegador")
        win.document.open()
        win.document.write(html)
        win.document.close()

        this.notificar("Relatório gerado com sucesso.", "positive")
      } catch (e) {
        // eslint-disable-next-line no-console
        console.error("[ModalGridComposicao] Erro ao gerar relatório:", e)
        this.notificar(`Erro ao gerar relatório: ${e && e.message ? e.message : e}`, "negative")
      } finally {
        this.loadingRelatorio = false
      }
    },

    lerArquivoComoTexto (file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(String(reader.result || ''))
    reader.onerror = () => reject(reader.error || new Error('Falha ao ler arquivo como texto'))
    reader.readAsText(file) // UTF-8
  })
},

lerArquivoComoDataURL (file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(String(reader.result || ''))
    reader.onerror = () => reject(reader.error || new Error('Falha ao ler arquivo como base64'))
    reader.readAsDataURL(file) // "data:...;base64,xxxx"
  })
},

extrairBase64 (dataUrl) {
  const s = String(dataUrl || '')
  const idx = s.indexOf('base64,')
  return idx >= 0 ? s.slice(idx + 7) : ''
},

    notificar (message, type = 'negative') {
      // Quasar notify, se existir; senão cai no console
      if (this.$q && typeof this.$q.notify === 'function') {
        this.$q.notify({ type, message })
      } else {
        // eslint-disable-next-line no-console
        console.warn('[ModalGridComposicao]', message)
      }
    },

    isCampoData (campo) {
  const dt = String(campo.nm_datatype || '').toLowerCase()
  const nm = String(campo.nm_atributo || '').toLowerCase()
  return dt.includes('date') || dt.includes('data') || nm.includes('data')
},

async onDataSelecionada (campo) {
  // dispara seu fluxo normal de alteração
  this.onCampoAlterado && this.onCampoAlterado(campo, this.valores[campo.nm_atributo])

  // valida como se fosse blur
  const ok = await (this.validarCampoRegra ? this.validarCampoRegra(campo, 'blur') : true)
  if (ok === false) return

  await this.$nextTick()
  setTimeout(() => this.focarProximoCampo && this.focarProximoCampo(campo), 0)
},

    editarItem (row) {
      if (!row) return
      const id = row.__rowid
      if (!id) return

      this.editingRowId = id

      // carrega valores do item no form
      ;(this.metaCampos || []).forEach(m => {
        if (!m || !m.nm_atributo) return
        if (m.nm_atributo === '__rowid') return
        this.$set(this.valores, m.nm_atributo, row[m.nm_atributo])
      })

      this.persistirDraft()
      this.$nextTick(() => this.focarPrimeiroCampo())
    },

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

limparDigitacao() {
    this.limparLocal()
    // limpa valores
    // limpa valores (mantém chaves do meta quando já carregado)
      if (Array.isArray(this.metaCampos) && this.metaCampos.length) {
        ;(this.metaCampos || []).forEach(m => {
          if (!m || !m.nm_atributo) return
          this.$set(this.valores, m.nm_atributo, '')
        })
      } else {
        this.valores = {}
      }

      this.itens = []
      this.persistirDraft()

      this.editingRowId = null
      this.editingIndex = -1

   // this.salvarEstadoLocal()
   // this.resetarEstadoModal();
    
   // foca primeiro campo
   this.$nextTick(() => this.focarPrimeiroCampo());
   //
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

      // se não abriu Unico, força o avanço de foco depois do render
if (!this.showUnicoEspecial) {
  await this.$nextTick()
  setTimeout(() => this.focarProximoCampo(campo), 0)
}
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

       this.ensureRowId(row)

       this.editingRowId = row.__rowid
       this.editingIndex = this.itens.findIndex(it => it.__rowid === row.__rowid)

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

    if (Number(campo?.ic_tipo_validacao || 0) == 2) {
       await this.aplicarValidacaoDoAtributo(campo)
    }

  // ✅ Se estiver vazio: NÃO valida e NÃO abre Unico automaticamente
  if (vazio) return

  // valida (se tiver regra)
  const ok = await this.validarCampoRegra(campo, 'blur')

  if (ok === false) return
  // validação feita


// se abriu o Unico (ou vai abrir), não muda foco aqui
if (this.showUnicoEspecial) return

// vai para o próximo editável
await this.$nextTick()
setTimeout(() => this.focarProximoCampo && this.focarProximoCampo(campo), 0)  

  

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
      dt_inicial: localStorage.dt_inicial,
      dt_final: localStorage.dt_final,
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

   //this.cd_relatorio = Number(retorno.cd_relatorio || 0)


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
      const tipo = String(campo.nm_datatype || '').toLowerCase()


      // DATA SEMPRE é input (evita virar select e “limpar” o valor)
      if (this.isCampoData(campo) || tipo === 'date' || tipo === 'datetime') return 'q-input'
      //

      const lista = (campo.Lista_Valor || '').toString().trim()
      const hasLista = lista !== '' && lista !== 'N'
      const hasLookup = campo.nm_lookup_tabela && String(campo.nm_lookup_tabela).trim() !== ''

      // Se tiver Lista_Valor válida OU lookup, usa select
      if (hasLista || hasLookup) return 'q-select'

      //const tipo = String(campo.nm_datatype || '').toLowerCase()
      
      if (tipo === 'checkbox' || tipo === 'boolean' || tipo === 'bool') return 'q-input'
      if (tipo === 'date' || tipo === 'datetime') return 'q-input'

      // default
      return 'q-input'

    },

    resolveType (f) {
      const nome = (f.nm_atributo || '').toLowerCase()
      const titulo = (f.nm_titulo_menu_atributo || '').toLowerCase()
      const tipo = (f.nm_datatype || '').toLowerCase()

      if (this.isCampoData(f)) return 'text'

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

    // === Normaliza opção para {label,value} (padrão Quasar map-options) ===
normalizaOpcao (item) {
  if (!item || typeof item !== 'object') {
    return { label: String(item || ''), value: item }
  }

  return {
    label:
      item.nm_lista_valor ||
      item.nm_atributo_consulta ||
      item.ds_atributo ||
      item.Descricao ||
      item.__label ||
      item.label ||
      item.text ||
      '',
    value:
      item.cd_lista_valor ||
      item.cd_atributo ||
      item.valor ||
      item.__value ||
      item.value ||
      item.id ||
      item.key ||
      '',
  }
},

getOptions (campo) {
  // 1) LOOKUP (nm_lookup_tabela) -> usa lookupOptions já carregado e normaliza
  const hasLookup = campo.nm_lookup_tabela && String(campo.nm_lookup_tabela).trim() !== ''
  if (hasLookup) {
    const raw = (this.lookupOptions && this.lookupOptions[campo.nm_atributo]) ? this.lookupOptions[campo.nm_atributo] : []
    if (Array.isArray(raw)) return raw.map(this.normalizaOpcao)
    return []
  }

  // 2) Lista_Valor -> aceita array ou string JSON ou "1=Ativo;2=Inativo"
  let l = campo.Lista_Valor
  if (!l) return []

  // se já vier array
  if (Array.isArray(l)) {
    return l.map(this.normalizaOpcao)
  }

  // se vier string
  if (typeof l === 'string') {
    l = l.trim()
    if (!l || l === 'N') return []

    // tentar JSON primeiro
    const parsed = safeParse(l, null)
    if (Array.isArray(parsed)) {
      return parsed.map(this.normalizaOpcao)
    }

    // fallback: "1=Ativo;2=Inativo" ou "A;B;C"
    const parts = l.split(/[;|,]/).map(s => s.trim()).filter(Boolean)
    return parts.map(p => {
      const [k, ...rest] = p.split('=')
      const val = (rest.length ? k : p).trim()
      const lab = (rest.length ? rest.join('=').trim() : p).trim()
      return { value: val, label: lab }
    })
  }

  return []
},

// ---------- LOOKUP DIRETO (nm_lookup_tabela) - igual ModalComposicao ----------
temLookupDireto (campo) {
  return !!(campo.nm_lookup_tabela && String(campo.nm_lookup_tabela).trim() !== '')
},

async postLookup (query) {
  const cfg = this.headerBanco
    ? { headers: { 'x-banco': this.headerBanco } }
    : undefined

  const { data } = await api.post('/lookup', { query }, cfg)
  return Array.isArray(data) ? data : []
},

async carregarLookupsDiretos () {
  const attrs = (this.metaCampos || []).filter(a => this.temLookupDireto(a))
  if (!attrs.length) return

  await Promise.all(attrs.map(a => this.carregarLookupDireto(a)))
},

async carregarLookupDireto (campo) {
  if (!this.temLookupDireto(campo)) return

  const rows = await this.postLookup(campo.nm_lookup_tabela)

  const nomeCodigo = (campo.nm_atributo_lookup || '').toLowerCase()

  const opts = rows.map(r => {
    const vals = Object.values(r || {})
    const code = (nomeCodigo && r[nomeCodigo] != null) ? r[nomeCodigo] : vals[0]
    const label = (r.Descricao != null) ? r.Descricao : (vals[1] != null ? vals[1] : code)

    return { value: String(code), label: String(label) }
  })

  if (!this.lookupOptions) this.lookupOptions = {}
  this.$set(this.lookupOptions, campo.nm_atributo, opts)
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

async fecharUnicoEspecial () {
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
  const campoOrigem = this.campoUnicoAtivo
  this.campoUnicoAtivo = null
  this.rowUnicoSelecionado = null
  await this.$nextTick()
  if (campoOrigem) this.focarProximoCampo(campoOrigem)

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
      //
    },

    limparLocal () {
      try { localStorage.removeItem(this.storageKey) } catch (e) {}
    },

ensureRowId (item) {
  if (!item) return item
  if (!item.__rowid) {
    item.__rowid = `${Date.now()}_${Math.random().toString(16).slice(2)}`
  }
  return item
},

normalizeItens () {
  if (!Array.isArray(this.itens)) this.itens = []
  this.itens.forEach(it => this.ensureRowId(it))
},


    // ===== Boot =====

    async bootstrap () {
      // Ao abrir o modal: limpa cache/draft e carrega dados iniciais (se existir procedure no meta)
      this.limparLocal()
      this.limparCargaInicialLocal()
      this.valores = {}
      this.itens = []

      await this.carregarMeta()

      // se o meta trouxer uma procedure de carga inicial, executa e preenche o modal/grid
      await this.carregarDadosIniciais()
      //

      this.normalizeItens()

      //

      // persiste estado inicial já carregado
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
          dt_inicial: localStorage.dt_inicial,
          dt_final: localStorage.dt_final,
        }]

        // ✅ TROCA pedida
        const { data } = await api.post('/exec/pr_egis_grid_modal_composicao', body, cfg)

        //this.meta = Array.isArray(data) ? data : []

        this.meta = Array.isArray(data)
  ? Object.values(
      data.reduce((acc, m) => {
        const nm = m?.nm_atributo ? String(m.nm_atributo).trim() : ''
        if (!nm) return acc

        const k = nm.toLowerCase()
        const atual = acc[k]

        if (!atual) {
          acc[k] = { ...m }
          return acc
        }

        // ✅ mescla: mantém o que já tem e completa com o que vier “melhor”
        const merged = { ...atual, ...m }

        // 🔥 regra principal: se vier cd_atributo_relatorio > 0, não pode perder
        const novoRel = Number(m?.cd_atributo_relatorio || 0)
        if (novoRel > 0) merged.cd_atributo_relatorio = novoRel

        acc[k] = merged
        return acc
      }, {})
    )
  : []
        console.log('Meta carregado do ModalGridComposicao:', this.meta)  

        // Título/subtítulo (se vier no meta)
        const m0 = this.meta[0] || {}
        this.tituloModal = m0.nm_titulo_modal || this.tituloModal
        this.subTituloModal = m0.ds_subtitulo_modal || this.subTituloModal
        this.nm_procedimento = m0.nm_procedimento || this.nm_procedimento
        this.cd_parametro_procedimento = m0.cd_parametro || this.cd_parametro_procedimento
        this.lookupOptions = m0.lookup_options || {}

        // 1) aplica registro selecionado (vem do grid do unicoFormEspecial)
        this.aplicarRegistroSelecionado()
        
        // depois de carregar o meta, inicializa os valores do form (garante chaves reativas)

        this.inicializarValoresDoForm()
        // carrega lookups diretos (nm_lookup_tabela)
        await this.carregarLookupsDiretos()


        //

      } catch (e) {
        console.error('Erro ao carregar meta do ModalGridComposicao:', e)
      } finally {
        this.loading = false
      }
    },

    // ===== Carga inicial (procedure definida no meta) =====
    storageKeyCargaInicial () {
      // chave fixa pedida para armazenar o "estado inicial" (cache)
      return 'modal_grid_composicao_9999'
    },

    limparCargaInicialLocal () {
      try { localStorage.removeItem(this.storageKeyCargaInicial()) } catch (e) {}
    },

    salvarCargaInicialLocal () {
      const payload = {
        valores: this.valores || {},
        itens: this.itens || []
      }
      try { localStorage.setItem(this.storageKeyCargaInicial(), JSON.stringify(payload)) } catch (e) {}
    },

    async carregarDadosIniciais () {
      try {
        const m0 = (Array.isArray(this.meta) ? this.meta[0] : null) || {}

        // 1) Verifica no meta se existe nm_procedimento_dados
        const nmProcDados = String(m0.nm_procedimento_dados || '').trim()

        console.log('[ModalGridComposicao] Procedimento de carga inicial:', nmProcDados)
        
        if (!nmProcDados) return

        // 2) Parametro de carga (cd_carga_parametro) vindo do meta
        const cdCargaParametro = Number(
          m0.cd_carga_parametro || m0.cd_parametro_carga || m0.cd_carga_parametro_procedimento || 0
        )

        const cfg = this.headerBanco
          ? { headers: { 'x-banco': this.headerBanco } }
          : undefined

        // registros selecionados (padrão técnico)
        const docsSelecionados = (this.registrosSelecionados || []).map((row) =>
          montaDadosTecnicos(row, Array.isArray(this.gridMeta) ? this.gridMeta : [])
        )

        console.log('docsSelecionados:',  docsSelecionados);


        const body = [
          {
            ic_json_parametro: 'S',
            cd_chave_modal: Number(localStorage.cd_chave_modal || 0),
            cd_parametro: cdCargaParametro,
            cd_usuario: Number(localStorage.cd_usuario || 0),
            dt_inicial: localStorage.dt_inicial,
            dt_final: localStorage.dt_final,
            cd_modal: Number(this.cdModal || 0),
            dados_registro: docsSelecionados
          }
        ]

        console.log('[ModalGridComposicao] carga inicial:', nmProcDados, 'cd_parametro:', cdCargaParametro)
        console.log('body =>', body)

        const { data } = await api.post(`/exec/${nmProcDados}`, body, cfg)

        const rows = Array.isArray(data) ? data : (data ? [data] : [])

        
        console.log('[ModalGridComposicao] dados carga inicial recebidos:', rows)

        if (!rows.length) return


        this.cd_relatorio = Number(rows.cd_relatorio || 0)

        console.log('[ModalGridComposicao] dados carga inicial recebidos:', rows)

        // 3) Se tiver dados: preenche o objeto no storage e o modal
        //    - se vier 1 linha, assume retorno "único" para preencher o form
        //    - se vier N linhas, assume dataset para popular grid

        if (rows.length === 1) {
          this.aplicarRetornoInicial(rows[0])
        } else {
          this.itens = rows.map((r) => {
            const item = {}
            ;(this.metaCampos || []).forEach((m) => {
              if (!m || !m.nm_atributo) return
              item[m.nm_atributo] = r[m.nm_atributo]
            })
            item.__rowid = `${Date.now()}_${Math.random().toString(16).slice(2)}`

            console.log('Item carga inicial:', item)  
            return item
          })
        }

        this.salvarEstadoLocal()
        this.salvarCargaInicialLocal()
      } catch (e) {
        console.error('[ModalGridComposicao] erro carga inicial:', e)
      }
    },

    aplicarRetornoInicial (dados) {
      if (!dados || typeof dados !== 'object') return

      // parecido com aplicarRetornoUnico, porém aqui aplica QUALQUER atributo do meta
      const meta = this.metaCampos || []
      const mapaDados = {}
      Object.keys(dados).forEach((k) => {
        mapaDados[this.normaliza(k)] = dados[k]
      })

      meta.forEach((m) => {
        if (!m || !m.nm_atributo) return

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

        console.log('Atributo:', m.nm_atributo, '=> valor encontrado:', valorEncontrado )

        if (valorEncontrado !== undefined) {
          this.$set(this.valores, m.nm_atributo, valorEncontrado)
        }
      })

      this.calcularCampos()
      this.persistirDraft()
    },


    fmtDDMMYYYY (val) {
  if (!val) return val

  // já está no formato esperado
  if (typeof val === 'string' && /^\d{2}\/\d{2}\/\d{4}$/.test(val.trim())) return val.trim()

  // ISO: 2025-12-31 ou 2025-12-31T00:00:00
  if (typeof val === 'string' && /^\d{4}-\d{2}-\d{2}/.test(val.trim())) {
    const s = val.trim().slice(0, 10) // yyyy-mm-dd
    const [y, m, d] = s.split('-')
    return `${d}/${m}/${y}`
  }

  // Date object
  if (val instanceof Date && !isNaN(val.getTime())) {
    const dd = String(val.getDate()).padStart(2, '0')
    const mm = String(val.getMonth() + 1).padStart(2, '0')
    const yyyy = String(val.getFullYear()).padStart(4, '0')
    return `${dd}/${mm}/${yyyy}`
  }

  return val
},

getValorDoRegistro (registro, nmAtributo) {
  if (!registro || !nmAtributo) return undefined

  // tenta bater por vários formatos de chave
  if (registro[nmAtributo] !== undefined) return registro[nmAtributo]

  const alvo = String(nmAtributo).toLowerCase()
  const key = Object.keys(registro).find(k => String(k).toLowerCase() === alvo)
  if (key) return registro[key]

  return undefined
},

aplicarRegistroSelecionado () {
  const reg = Array.isArray(this.registrosSelecionados) ? this.registrosSelecionados[0] : null

  console.log('Registro selecionado para aplicar no form:', reg)


  if (!reg) return

  // garante objeto reativo
  if (!this.valores || typeof this.valores !== 'object') this.valores = {}

  ;(this.metaCampos || []).forEach(campo => {
    const nm = campo?.nm_atributo
    if (!nm) return

    const v = this.getValorDoRegistro(reg, nm)
    if (v === undefined || v === null || v === '') return

    // se for campo data, normaliza para DD/MM/YYYY (seu q-date usa mask DD/MM/YYYY)
    if (this.isCampoData && this.isCampoData(campo)) {
      this.$set(this.valores, nm, this.fmtDDMMYYYY(v))
    } else {
      this.$set(this.valores, nm, v)
    }
  })
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

      //item[m.nm_atributo] = this.valores[m.nm_atributo]

      // trata tipos básicos
      const key = m.nm_atributo
const dt = String(m.nm_datatype || '').toLowerCase()

const isNumber =
  dt.includes('currency') || dt.includes('money') ||
  dt.includes('decimal') || dt.includes('numeric') ||
  dt.includes('int') || dt.includes('float') || dt.includes('double') ||
  dt.includes('percent')

if (isNumber) {
  item[key] = this.toNumberBR(this.valores[key])
} else {
  item[key] = this.valores[key]
}


    })

    // rowid
    //item.__rowid = `${Date.now()}_${Math.random().toString(16).slice(2)}`

    // ✅ Vue2: push é o caminho mais seguro de reatividade
    if (!Array.isArray(this.itens)) this.itens = []
    

      // se está em modo edição, atualiza o item existente
    if (this.editingRowId) {
      const idx = this.itens.findIndex(r => r && r.__rowid === this.editingRowId)

      // mantém o mesmo __rowid
      item.__rowid = this.editingRowId

      if (idx >= 0) {
        this.$set(this.itens, idx, item)
      } else {
        // fallback: se não achou, insere como novo
        this.ensureRowId(item)
        this.itens.push(item)
      }

      // sai do modo edição
      this.editingRowId = null
      this.editingIndex = -1
    } else {
      // novo item
      this.ensureRowId(item)
      this.itens.push(item)
    }

    //this.itens.push(item)


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

      
      this.editingRowId = null
      this.editingIndex = -1

      // limpa os campos dinâmicos do form
;(this.metaCampos || []).forEach(m => {
  if (!m || !m.nm_atributo) return
  if (m.nm_atributo === '__rowid') return
  this.$set(this.valores, m.nm_atributo, '')
})

      this.salvarEstadoLocal()

      // se você usa draft/local do form, limpa também
      this.persistirDraft && this.persistirDraft()

  // volta o foco pro primeiro campo
  this.$nextTick(() => {
    this.focarPrimeiroCampo && this.focarPrimeiroCampo()
  })
      
    },

    onActionEditar (row) {
  if (!row) return
  this.ensureRowId(row)

  // entra em edição
  this.editingRowId = row.__rowid
  this.editingIndex = this.itens.findIndex(it => it && it.__rowid === row.__rowid)

  // preenche inputs dinamicamente pelo meta
  ;(this.metaCampos || []).forEach(m => {
    if (!m || !m.nm_atributo) return
    if (m.nm_atributo === '__rowid') return
    this.$set(this.valores, m.nm_atributo, row[m.nm_atributo])
  })

  this.persistirDraft && this.persistirDraft()
  this.focarPrimeiroCampo && this.focarPrimeiroCampo()
},

removerPorRowId (rowid) {
  if (!rowid) return
  const idx = (this.itens || []).findIndex(it => it && it.__rowid === rowid)
  if (idx >= 0) this.itens.splice(idx, 1)

  // se removeu o que estava editando, reseta
  if (this.editingRowId === rowid) {
    this.editingRowId = null
    this.editingIndex = -1
  }

  // limpa os campos dinâmicos do form
 ;(this.metaCampos || []).forEach(m => {
   if (!m || !m.nm_atributo) return
   if (m.nm_atributo === '__rowid') return
   this.$set(this.valores, m.nm_atributo, '')
 })

  // força reatividade e persiste
  this.itens = [...this.itens]
  this.salvarEstadoLocal && this.salvarEstadoLocal()

  this.persistirDraft && this.persistirDraft()
  this.focarPrimeiroCampo && this.focarPrimeiroCampo()    
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
        dt_inicial: localStorage.dt_inicial,
        dt_final: localStorage.dt_final,
        // ✅ aqui vai o “conteúdo do modal”
        dados_modal: {
          itens: itensLimpos
        },

        // ✅ mantém padrão do ModalComposicao
        dados_registro: docsSelecionados,
        //

        dados_arquivo: this.dadosArquivo,

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

const precisaArquivo = (this.metaCampos || []).some(m =>
  String(m?.ic_doc_caminho_atributo || '').toUpperCase() === 'S' &&
  parseInt(m?.ic_tipo_arquivo, 10) === 1
)

if (precisaArquivo && !this.dadosArquivo) {
  this.$q.notify({ type: 'warning', message: 'Selecione um arquivo antes de confirmar.' })
  return
}


    //await api.post(`/exec/${this.nm_procedimento}`, body, cfg)

    const resp = await api.post(`/exec/${this.nm_procedimento}`, body, cfg)
    const data = resp ? resp.data : null
    


    // exemplo genérico: ajuste para a sua variável real do confirmar
    const teveRetorno = Array.isArray(data) ? data.length > 0 : !!data

    if (teveRetorno) {
       await this.aplicarValidacoesTipo3()
    }

    // Se ic_arquivo_texto='S', joga retorno no textarea

   if (this.mostrarArquivoTexto) {
  let texto = ''

  // 1) se vier string direto
  if (typeof data === 'string') {
    texto = data

  // 2) se vier array tipo: [ { ds_retorno: "..." } ]
  } else if (Array.isArray(data)) {
    if (data.length > 0 && data[0] && typeof data[0] === 'object') {
      // tenta chaves comuns do seu backend
      texto =
        data[0].ds_retorno ||
        data[0].conteudo ||
        data[0].texto ||
        data[0].ds_arquivo ||
        data[0].ds_mensagem ||
        ''
    } else if (data.length === 1 && typeof data[0] === 'string') {
      texto = data[0]
    }

    // fallback se ainda não achou
    if (!texto) texto = JSON.stringify(data, null, 2)

  // 3) se vier objeto
  } else if (data && typeof data === 'object') {
    texto =
      data.ds_retorno ||
      data.conteudo ||
      data.texto ||
      JSON.stringify(data, null, 2)

  } else if (data != null) {
    texto = String(data)
  }

  this.retornoArquivoTexto = texto



  //this.retornoArquivoTexto = texto


// Se tiver campo de caminho (download) -> cria arquivo e seta valores[campo]
const campoDownload = (this.metaCampos || []).find(m =>
  String(m?.ic_doc_caminho_atributo || '').toUpperCase() === 'S' &&
  parseInt(m?.ic_tipo_arquivo, 10) === 2
)

if (campoDownload && this.retornoArquivoTexto && 1==2 )  {
  const nomeBase = (this.valores?.[campoDownload.nm_atributo] || campoDownload.ds_atributo || campoDownload.nm_atributo || 'arquivo').toString()
  const nome = nomeBase.toLowerCase().endsWith('.txt') ? nomeBase : `${nomeBase}.txt`

  const blob = new Blob([this.retornoArquivoTexto], { type: 'text/plain;charset=utf-8' })
  const url = URL.createObjectURL(blob)

  // grava no campo Local (nm_local_documento) um link blob:...
  this.$set(this.valores, campoDownload.nm_atributo, url)

  // opcional: já dispara o download automaticamente
  // (se você preferir só deixar o botão disponível, comente a linha abaixo)
  this.baixarArquivoAnexo(campoDownload)


  //Retorno de Confirmacao
  //await this.aplicarValidacoesPorTipo(3)
  //

}


}


    // limpa local e fecha
    this.limparLocal()


    // Se for retorno de arquivo texto, não emite "sucesso" porque o pai fecha o modal
    if (this.mostrarArquivoTexto) {
    // opcional: feedback visual
    this.$q && this.$q.notify && this.$q.notify({
      type: 'positive',
      message: 'Arquivo gerado. Visualize o conteúdo e use o botão para baixar.'
    })
    return
   }

    //
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

baixarConteudoTexto () {
  if (!this.retornoArquivoTexto) return

  // nome do arquivo: tenta usar Documento + datas, senão fallback
  const doc = (this.valores?.nm_documento_magnetico || 'arquivo').toString().replace(/[^\w\-]+/g, '_')
  const di = (this.valores?.dt_inicial || '').toString().replace(/[^\d]+/g, '')
  const df = (this.valores?.dt_final || '').toString().replace(/[^\d]+/g, '')

  const nome = `${doc}_${di}_${df}.txt`.replace(/__+/g, '_')

  const blob = new Blob([this.retornoArquivoTexto], { type: 'text/plain;charset=utf-8' })
  const url = URL.createObjectURL(blob)

  const a = document.createElement('a')
  a.href = url
  a.download = nome
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)

  // libera memória
  URL.revokeObjectURL(url)
},


   cancelar () {
      // não limpa localStorage (pedido)
      this.internalVisible = false
      this.$emit('fechar')
    },


    inicializarValoresDoForm () {
  if (!Array.isArray(this.metaCampos)) return

  const atual = this.valores && typeof this.valores === 'object' ? this.valores : {}
  const novo = { ...atual }

  // helpers: sempre devolvem DD/MM/YYYY (compatível com q-date mask="DD/MM/YYYY")
  const fmtDDMMYYYY = (d) => {
    const dd = String(d.getDate()).padStart(2, '0')
    const mm = String(d.getMonth() + 1).padStart(2, '0')
    const yyyy = String(d.getFullYear()).padStart(4, '0')
    return `${dd}/${mm}/${yyyy}`
  }

  const hojeDDMMYYYY = () => fmtDDMMYYYY(new Date())

  const primeiroDiaMesDDMMYYYY = () => {
    const d = new Date()
    const first = new Date(d.getFullYear(), d.getMonth(), 1)
    return fmtDDMMYYYY(first)
  }

  const ultimoDiaMesDDMMYYYY = () => {
    const d = new Date()
    // dia 0 do mês seguinte = último dia do mês atual
    const last = new Date(d.getFullYear(), d.getMonth() + 1, 0)
    return fmtDDMMYYYY(last)
  }

  this.metaCampos.forEach(m => {
    if (!m || !m.nm_atributo) return

    // mantém valor já existente (não sobrescreve o que o usuário digitou)
    if (novo[m.nm_atributo] === undefined) {
      let def = (m.vl_default || '').toString().trim()

      const attr = (m.nm_atributo || '').toLowerCase()

      // detecta campo de data (bem tolerante)
      const isDate =
        m.nm_datatype === 'date' ||
        attr.includes('data') ||
        attr.startsWith('dt_') ||
        attr.includes('_dt_')

      // 1) ic_data_hoje
      if (String(m.ic_data_hoje || '').toUpperCase() === 'S' && isDate) {
        def = hojeDDMMYYYY()
      }

      // 2) ic_periodo_vigente: dt_inicial / dt_final
      if (String(m.ic_periodo_vigente || '').toUpperCase() === 'S' && isDate) {
        if (attr === 'dt_inicial') def = primeiroDiaMesDDMMYYYY()
        if (attr === 'dt_final') def = ultimoDiaMesDDMMYYYY()
      }

      this.$set(novo, m.nm_atributo, def ? def : null)
    }
  })

  this.valores = novo
},

// flag do backend para campo de arquivo
isCampoArquivo (campo) {
  // flag da sua meta
  return String(campo?.ic_doc_caminho_atributo || '').toUpperCase() === 'S'
},

// 1 = upload | 2 = download/salvar como
tipoArquivo (campo) {
  const n = parseInt(campo && campo.ic_tipo_arquivo, 10)
  return Number.isFinite(n) ? n : 1
},

abrirSeletorArquivo (campo) {
  this._campoArquivoAtual = campo
  if (this.$refs.fileHidden) this.$refs.fileHidden.click()
},


async onFileSelectedHidden (ev) {
  const campo = this._campoArquivoAtual
  const file = ev && ev.target && ev.target.files ? ev.target.files[0] : null
  if (!campo || !file) return

  try {
    // mostra algo no campo (ex: nome do arquivo)
    this.$set(this.valores, campo.nm_atributo, file.name)

    // lê conteúdo do arquivo (texto)
    const texto = await this.lerArquivoComoTexto(file)

    // se a tela usa ic_arquivo_texto='S', mostra o conteúdo na textarea
    if (this.mostrarArquivoTexto) {
      this.retornoArquivoTexto = texto
    }

    // prepara dados para enviar no payload (base64 + metadados)
    const dataUrl = await this.lerArquivoComoDataURL(file)
    const base64 = this.extrairBase64(dataUrl)

    this.dadosArquivo = {
      nm_arquivo: file.name,
      mime_type: file.type || 'text/plain',
      tamanho: file.size || 0,
      conteudo_texto: texto,     // útil para back-end ou debug
      conteudo_base64: base64    // geralmente é o que o back-end quer
    }

  } catch (err) {
    console.error('Erro ao processar arquivo:', err)
    this.$q && this.$q.notify && this.$q.notify({
      type: 'negative',
      message: 'Não foi possível ler o arquivo selecionado.'
    })
  } finally {
    // permite escolher o mesmo arquivo novamente
    ev.target.value = ''
  }
},

onFileSelectedHiddenOld (ev) {
  const campo = this._campoArquivoAtual
  const file = ev && ev.target && ev.target.files ? ev.target.files[0] : null

  if (!campo || !file) return

  // Aqui você encaixa o SEU upload real:
  // Se existir um método seu, chame ele aqui.
  // Ex: this.uploadArquivo(campo, file)
  if (typeof this.uploadArquivo === 'function') {
    this.uploadArquivo(campo, file)
  } else {
    // fallback: só grava o nome para não quebrar e você ver funcionando
    this.$set(this.valores, campo.nm_atributo, file.name)
  }

  // permite escolher o mesmo arquivo de novo
  ev.target.value = ''
},

isArquivoUpload (attr) {
  return this.isCampoArquivo(attr) && this.tipoArquivo(attr) === 1
},

isArquivoDownload (attr) {
  return this.isCampoArquivo(attr) && this.tipoArquivo(attr) === 2
},

baixarArquivoAnexo (campo) {
  const v = this.valores && campo ? this.valores[campo.nm_atributo] : null
  if (!v) return

  // se o valor já for uma URL/caminho baixável
  const url = String(v)

  const a = document.createElement('a')
  a.href = url
  a.target = '_blank'
  a.rel = 'noopener'
  a.download = ''
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
},

toNumberBR (v) {
  if (v === null || v === undefined) return 0
  if (typeof v === 'number') return v

  const s = String(v).trim()
  if (!s) return 0

  // remove separador de milhar e troca vírgula por ponto
  const norm = s.replace(/\./g, '').replace(',', '.')
  const num = Number(norm)
  return isNaN(num) ? 0 : num
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
