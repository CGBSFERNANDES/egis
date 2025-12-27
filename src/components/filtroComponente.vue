<template>
  <q-dialog v-model="internalVisible" maximized persistent>
    <q-card class="q-pa-none" style="min-height: 100vh">
      <q-card-section class="row items-start no-wrap q-gutter-md">
        <!-- identidade visual -->
        <div class="col-auto flex flex-center bg-deep-purple-1 q-pa-lg" style="border-radius: 80px">
          <q-icon name="filter_alt" size="56px" color="deep-purple-7" />
        </div>

        <div class="col">
          <div class="row items-start justify-between">
            <div>
              <div class="text-h6 text-weight-bold">
                {{ tituloModal || 'Filtro' }}
                <q-badge
                  rounded
                  class="q-ml-sm"
                  color="deep-orange-7"
                  :label="String(cdMenu || cdTabela || '')"
                />
              </div>
              <div class="text-caption text-grey-7">
                Selecione os registros para aplicar o filtro
              </div>
            </div>

            <q-btn rounded dense color="deep-purple-7" round icon="close" v-close-popup />
          </div>

          <q-separator spaced />

          <div v-if="loading" class="row justify-center q-my-lg">
            <q-spinner size="42px" />
          </div>

          <div v-else>
            <dx-data-grid
              ref="grid"
              :data-source="gridRows"
              :show-borders="true"
              :hover-state-enabled="true"
              :row-alternation-enabled="true"
              :column-auto-width="true"
              :key-expr="keyField"
              height="72vh"
              :selection="{ mode: 'multiple', showCheckBoxesMode: 'always' }"
              @selection-changed="onSelectionChanged"
            >
              <dx-scrolling mode="standard" />
              <dx-search-panel :visible="true" :width="320" placeholder="Procurar..." />
              <dx-paging :page-size="50" />
              <dx-pager
                :show-page-size-selector="true"
                :allowed-page-sizes="[10, 20, 50, 100]"
                :show-info="true"
              />

              <!-- Coluna Ações (checkbox) para ficar igual a ideia do UnicoFormEspecial -->
              <dx-column
                caption="Ações"
                :width="90"
                alignment="center"
                cell-template="acoesCellTemplate"
                :allow-filtering="false"
                :allow-sorting="false"
                :fixed="true"
                fixed-position="left"
              />
              <template #acoesCellTemplate="{ data }">
                <q-checkbox
                  v-if="false"
                  dense
                  :value="isSelected(data.data)"
                  @input="() => toggleRow(data.data)"
                />
              </template>

              <dx-column
                v-for="c in gridColumns"
                :key="c.dataField"
                :data-field="c.dataField"
                :caption="c.caption"
                :data-type="c.dataType"
                :format="c.format"
                :alignment="c.alignment"
                :width="c.width"
              />
            </dx-data-grid>

            <div class="row items-center q-mt-md">
              <q-btn
                color="deep-purple-7"
                icon="check"
                label="Confirmar"
                :loading="loadingConfirmar"
                @click="confirmar"
              />
              <q-btn flat label="Cancelar" class="q-ml-sm" @click="cancelar" />
              <q-space />
              <q-badge color="deep-purple-7">Selecionados: {{ selectedRowKeys.length }}</q-badge>
            </div>
          </div>
        </div>
      </q-card-section>
    </q-card>
  </q-dialog>
</template>

<script>
import axios from 'axios'

import { payloadTabela, execProcedure } from '@/services'

import DxDataGrid, {
  DxColumn,
  DxPaging,
  DxPager,
  DxScrolling,
  DxSearchPanel,
} from 'devextreme-vue/data-grid'

const api = axios.create({
  baseURL: 'https://egiserp.com.br/api',
  withCredentials: true,
  timeout: 60000,
})

api.interceptors.request.use((cfg) => {
  const banco = localStorage.nm_banco_empresa || ''
  if (banco) cfg.headers['x-banco'] = banco
  cfg.headers['Authorization'] = 'Bearer superchave123'
  if (!cfg.headers['Content-Type']) cfg.headers['Content-Type'] = 'application/json'
  return cfg
})

function normalizeDataType(t) {
  const s = String(t || '').toLowerCase()
  if (!s) return undefined
  if (s.includes('date') && !s.includes('time')) return 'date'
  if (s.includes('datetime') || s.includes('timestamp')) return 'datetime'
  if (s.includes('int') || s.includes('number') || s.includes('numeric') || s.includes('decimal'))
    return 'number'
  if (s.includes('bool')) return 'boolean'
  return 'string'
}

export default {
  name: 'FiltroComponente',
  components: {
    DxDataGrid,
    DxColumn,
    DxPaging,
    DxPager,
    DxScrolling,
    DxSearchPanel,
  },
  props: {
    value: { type: Boolean, default: false },
    cdMenu: { type: [Number, String], default: 0 },
    cdTabela: { type: [Number, String], default: 0 },
    cdUsuario: { type: [Number, String], default: 0 },
    cd_parametro_relatorio: { type: [Number, String], default: 0 },
    // se você quiser forçar a chave, pode passar
    keyFieldProp: { type: String, default: '' },
  },
  data() {
    return {
      internalVisible: this.value,
      loading: false,
      loadingConfirmar: false,

      tituloModal: '',
      metaGrid: [],
      gridColumns: [],
      gridRows: [],

      keyField: '',

      selectedRowKeys: [],
      selectedRows: [],
      columns: [],
      metaTabela: [],
      captionMap: {}, // { 'cd_motivo_retirada_caixa': 'Código', ... }
    }
  },
  watch: {
    value(v) {
      this.internalVisible = v
      if (v) this.bootstrap()
    },
    internalVisible(v) {
      this.$emit('input', v)
    },
  },
  methods: {
    async bootstrap() {
      console.log(
        '[FiltroComponente] bootstrap cdMenu:',
        this.cdMenu,
        'cdTabela:',
        this.cdTabela,
        'cdUsuario:',
        this.cdUsuario
      )

      this.loading = true
      try {
        await this.carregarMetaGrid()
        await this.carregarRows()
      } finally {
        this.loading = false
      }
    },

    //

    async carregarMeta() {
      const payload = {
        ic_json_parametro: 'S',
        cd_tabela: Number(this.cdTabela),
        cd_parametro: 1,
        cd_form: localStorage.cd_form,
        cd_menu: Number(this.cdMenu),
        nm_tabela_origem: '',
        cd_usuario: Number(this.cdUsuario),
      }

      let resp

      try {
        resp = await payloadTabela(payload)
      } catch (e) {
        console.error('[FiltroComponente] payloadTabela ERRO:', e, payload)
        throw e
      }

      const data = resp?.data ?? resp
      const meta = Array.isArray(data) ? data : []
      this.metaTabela = meta

      // ✅ monta um mapa confiável: nm_atributo -> ds_titulo
      const map = {}
      meta.forEach((m) => {
        const field = String(m.nm_atributo || m.nm_atributo_consulta || '').trim()
        const title = String(m.ds_titulo || m.nm_titulo || '').trim()
        if (field && title) {
          map[field] = title
          map[field.toLowerCase()] = title
        }
      })
      this.captionMap = map

      console.log('[FiltroComponente] carregarMeta OK:', {
        meta: meta.length,
        map: Object.keys(this.captionMap).length,
      })
    },

    mapDataType(tp) {
      switch (String(tp).toUpperCase()) {
        case 'N':
        case 'NUMBER':
          return 'number'
        case 'D':
        case 'DATE':
          return 'date'
        case 'B':
          return 'boolean'
        default:
          return 'string'
      }
    },

    aplicarTraducaoCabecalho() {
      const map = this.captionMap || {}

      this.gridColumns = (this.gridColumns || []).map((c) => {
        const df = String(c.dataField || '').trim()
        const translated = map[df] || map[df.toLowerCase()] || c.caption

        return { ...c, caption: translated }
      })

      console.log('[FiltroComponente] aplicarTraducaoCabecalho OK')
    },

    // (1) meta para montagem da grid dinâmica
    async carregarMetaGrid() {
      console.log(
        '[FiltroComponente] carregarMetaGrid cdMenu:',
        this.cdMenu,
        'cdTabela:',
        this.cdTabela,
        'cdUsuario:',
        this.cdUsuario
      )

      await this.carregarMeta()

      const body = [
        {
          cd_menu: Number(this.cdMenu || 0),
          cd_tabela: Number(this.cdTabela || 0),
          cd_parametro: 1,
          cd_usuario: Number(this.cdUsuario || localStorage.cd_usuario || 0),
          ic_json_parametro: 'S',
        },
      ]

      const { data } = await api.post('/exec/pr_egis_pesquisa_filtro_selecao', body)
      this.metaGrid = Array.isArray(data) ? data : []

      const m0 = this.metaGrid[0] || {}
      this.tituloModal = m0.nm_titulo_modal || m0.nm_titulo || m0.ds_titulo || this.tituloModal

      const cols = (this.metaGrid || [])
        .filter((m) => String(m.ic_mostra_grid || 'S').toUpperCase() !== 'N')
        .map((m) => {
          const dataField = m.nm_atributo_consulta || m.nm_atributo || m.nm_campo || m.dataField
          return {
            dataField,
            caption:
              m.nm_titulo_menu_atributo || m.ds_rotulo || m.nm_filtro || m.nm_atributo || dataField,
            dataType: normalizeDataType(m.nm_datatype || m.dataType),
            alignment:
              normalizeDataType(m.nm_datatype || m.dataType) === 'number' ? 'right' : 'left',
            width: m.nu_largura || m.width || undefined,
            format: m.ds_formato || m.format || undefined,
          }
        })
        .filter((c) => !!c.dataField)

      this.gridColumns = cols

      // ✅ tradução só UMA VEZ e NO FINAL
      this.aplicarTraducaoCabecalho()

      console.log('[FiltroComponente] carregarMetaGrid gridColumns:', this.gridColumns)

      // detecta chave (mantive igual seu)
      this.keyField =
        String(this.keyFieldProp || '').trim() || this.detectKeyField(cols, this.metaGrid)
    },

    detectKeyField(cols, meta) {
      // 1) meta com flag de chave
      const candMeta = (meta || []).find(
        (m) => String(m.ic_chave || m.ic_pk || '').toUpperCase() === 'S'
      )
      if (candMeta) return candMeta.nm_atributo_consulta || candMeta.nm_atributo

      // 2) primeiro campo cd_ / id
      const cand =
        (cols || []).find((c) => /^cd_/i.test(String(c.dataField || ''))) ||
        (cols || []).find((c) => /^id$/i.test(String(c.dataField || ''))) ||
        (cols || [])[0]

      return cand ? String(cand.dataField) : ''
    },

    // (2) dados para seleção
    async carregarRows() {
      const body = [
        {
          cd_menu: Number(this.cdMenu || 0),
          cd_tabela: Number(this.cdTabela || 0),
          cd_parametro: 2,
          cd_usuario: Number(this.cdUsuario || localStorage.cd_usuario || 0),
          ic_json_parametro: 'S',
        },
      ]

      const { data } = await api.post('/exec/pr_egis_pesquisa_filtro_selecao', body)
      this.gridRows = Array.isArray(data) ? data : []

      // limpa seleção ao recarregar
      this.selectedRowKeys = []
      this.selectedRows = []
    },

    onSelectionChanged(e) {
      this.selectedRowKeys = Array.isArray(e.selectedRowKeys) ? e.selectedRowKeys : []
      this.selectedRows = Array.isArray(e.selectedRowsData) ? e.selectedRowsData : []
    },

    gridInstance() {
      return this.$refs.grid && this.$refs.grid.instance ? this.$refs.grid.instance : null
    },

    isSelected(row) {
      if (!this.keyField) return false
      const val = row ? row[this.keyField] : undefined
      return this.selectedRowKeys.includes(val)
    },

    toggleRow(row) {
      const grid = this.gridInstance()
      if (!grid || !this.keyField) return
      const key = row[this.keyField]
      const isSel = this.selectedRowKeys.includes(key)
      if (isSel) grid.deselectRows([key])
      else grid.selectRows([key], true)
    },

    // (3) salva seleção no backend e devolve para o UnicoFormEspecial filtrar
    async confirmar() {
      this.loadingConfirmar = true
      try {
        const sjonA = (this.selectedRows || []).map((r) => ({
          [this.keyField]: r[this.keyField],
        }))

        const body = [
          {
            cd_parametro: 3,
            cd_tabela: Number(this.cdTabela || 0),
            cd_usuario: Number(this.cdUsuario || localStorage.cd_usuario || 0),
            cd_menu: Number(this.cdMenu || 0),
            cd_modulo: 0,
            cd_parametro_relatorio: this.cd_parametro_relatorio,
            ic_json_parametro: 'S',
            sjonA,
          },
        ]

        await api.post('/exec/pr_egis_pesquisa_filtro_selecao', body)

        this.$emit('aplicou', {
          keyField: this.keyField,
          keys: this.selectedRowKeys,
          rows: this.selectedRows,
        })

        this.internalVisible = false
      } catch (e) {
        console.error('[FiltroComponente] erro ao confirmar:', e)
      } finally {
        this.loadingConfirmar = false
      }
    },

    cancelar() {
      this.internalVisible = false
    },
  },
}
</script>

<style scoped>
.top-badge {
  vertical-align: middle;
}
</style>
