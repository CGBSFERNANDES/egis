<template>
  <div class="q-pa-md">
    <div class="row items-center q-mb-md">
      <div class="text-h6 text-weight-bold">Cadastro de Bens</div>
      <q-space />
      <q-btn color="primary" icon="add" label="Incluir" @click="addRow" />
      <q-btn class="q-ml-sm" flat icon="refresh" @click="carregarBem" />
    </div>

    <DxDataGrid
      ref="grid"
      :data-source="rows"
      :remote-operations="false"
      :show-borders="true"
      :hover-state-enabled="true"
      :row-alternation-enabled="true"
      :column-auto-width="true"
      :word-wrap-enabled="true"
      :two-way-binding-enabled="false"
      key-expr="cd_bem"
      @row-inserting="onRowInserting"
      @row-updating="onRowUpdating"
      @row-removing="onRowRemoving"
      :no-data-text="'Nenhum registro encontrado'"
    >
      <DxToolbar>
        <DxItem name="searchPanel" />
        <DxItem name="addRowButton" />
        <DxItem name="exportButton" />
      </DxToolbar>

      <DxPaging :page-size="10" />
      <DxPager :show-page-size-selector="true" :allowed-page-sizes="[10,20,50,100]" :show-info="true" />

      <DxSearchPanel :visible="true" :width="260" placeholder="Pesquisar..." />
      <DxFilterRow :visible="true" />
      <DxHeaderFilter :visible="true" />
      <DxColumnChooser :enabled="true" />

      <DxEditing
        mode="popup"
        :allow-adding="true"
        :allow-updating="true"
        :allow-deleting="true"
        :use-icons="true"
      />
      <DxPopup :title="'Bem'" :show-title="true" :width="920" :height="620" />
      <DxForm>
        <DxItemForm data-field="nm_bem" />
        <DxItemForm data-field="ds_bem" editor-type="dxTextArea" :editor-options="{minHeight:80}" />
        <DxItemForm data-field="cd_grupo_bem" />
        <DxItemForm data-field="cd_patrimonio_bem" />
        <DxItemForm data-field="nm_registro_bem" />
        <DxItemForm data-field="nm_serie_bem" />
        <DxItemForm data-field="nm_marca_bem" />
        <DxItemForm data-field="nm_modelo_bem" />
        <DxItemForm data-field="qt_capacidade_bem" />
        <DxItemForm data-field="qt_voltagem_bem" />
        <DxItemForm data-field="vl_aquisicao_bem" />
        <DxItemForm data-field="dt_aquisicao_bem" />
        <DxItemForm data-field="nm_obs_item" />
        <DxItemForm data-field="cd_produto" />
        <DxItemForm data-field="cd_cliente" />
      </DxForm>

      <!-- colunas dinâmicas -->
      <template v-for="col in columnDefs">
        <DxColumn
          v-if="!col.lookup"
          :key="col.dataField"
          :data-field="col.dataField"
          :caption="col.caption"
          :data-type="col.dataType"
          :format="col.format || null"
          :width="col.width || null"
          :allow-editing="col.allowEditing"
          :visible="col.visible !== false"
        />
        <DxColumn
          v-else
          :key="col.dataField"
          :data-field="col.dataField"
          :caption="col.caption"
          :data-type="col.dataType"
          :width="col.width || null"
          :allow-editing="col.allowEditing"
          :visible="col.visible !== false"
        >
          <DxLookup :data-source="col.lookup.dataSource" value-expr="id" display-expr="text" />
        </DxColumn>
      </template>

      <!-- Coluna Ações (opcional, pois já há botões padrão do DevExtreme) -->
      <!-- <DxColumn type="buttons" width="120">
        <DxButton hint="Editar" icon="edit" name="edit" />
        <DxButton hint="Excluir" icon="trash" name="delete" />
      </DxColumn> -->
    </DxDataGrid>
  </div>
</template>

<script>
// DevExtreme
import {
  DxDataGrid, DxColumn, DxEditing, DxPaging, DxPager, DxFilterRow, DxHeaderFilter,
  DxSearchPanel, DxToolbar, DxItem, DxColumnChooser, DxPopup, DxForm,
  DxItem as DxItemForm, DxLookup
} from 'devextreme-vue/data-grid'
import api from '@/boot/axios'

export default {
  name: 'cadastroBem',
  components: {
    DxDataGrid, DxColumn, DxEditing, DxPaging, DxPager, DxFilterRow, DxHeaderFilter,
    DxSearchPanel, DxToolbar, DxItem, DxColumnChooser, DxPopup, DxForm, DxItemForm, DxLookup
  },
  data () {
    return {
      loading: false,
      // dados
      rows: [],
      titulos: {},       // nm_atributo -> nm_titulo (pr_egis_atributos_tabela cd_tabela=369)
      columnDefs: [],    // colunas dinâmicas p/ DataGrid
      gruposDS: [],      // lookup grupo do bem
    }
  },
  mounted () {
    // ordem: carrega títulos -> monta colunas -> carrega lookups -> carrega dados
    this.carregarTitulos()
      .then(this.montaColunas)
      .then(this.carregarGrupos)
      .then(this.carregarBem)
  },
  methods: {
    // ===== helpers =====
    normalizeRows (resp) {
      if (Array.isArray(resp)) return resp
      if (resp && Array.isArray(resp.data)) return resp.data
      if (resp && Array.isArray(resp.rows)) return resp.rows
      if (resp && Array.isArray(resp.recordset)) return resp.recordset
      if (resp && resp[0] && Array.isArray(resp[0].recordset)) return resp[0].recordset
      return []
    },
    lbl (k, fallback) { return this.titulos[k] || fallback || k },

    // Data local (sem UTC) e serialização YYYY-MM-DD
    parseLocalDate (v) {
      if (!v) return null
      const s = String(v)
      const m = s.match(
        /^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2})(?::(\d{2})(?::(\d{2})(?:\.(\d{1,3}))?)?)?)?$/
      )
      if (!m) {
        const d = new Date(s); return isNaN(d) ? null : d
      }
      const [, yy, MM, dd, hh, mm, ss, fff] = m
      return new Date(+yy, +MM - 1, +dd, +(hh||0), +(mm||0), +(ss||0), +(fff||0))
    },
    toISODate (d) {
      if (!d) return null
      if (typeof d === 'string') {
        // DevExtreme (date editor) pode mandar string ISO já ok
        const p = this.parseLocalDate(d); if (p) return p.toISOString().slice(0,10)
        return d.slice(0,10)
      }
      try { return new Date(d).toISOString().slice(0,10) } catch { return null }
    },

    // ===== títulos (dicionário) =====
    async carregarTitulos () {
      const body = [{ ic_json_parametro: 'S', cd_parametro: 0, cd_tabela: 369 }]
      const { data } = await api.post('/api/exec/pr_egis_atributos_tabela', body, {
        headers: { 'x-banco': 'egisAdmin' }
      })
      const rows = this.normalizeRows(data)
      const map = {}; rows.forEach(r => { map[r.nm_atributo] = r.nm_titulo })
      this.titulos = map
    },

    // ===== colunas dinâmicas (igual display-data.vue, mas com tipos/lookup) =====
    montaColunas () {
      const fields = [
        'cd_bem','nm_bem','ds_bem','cd_grupo_bem','cd_patrimonio_bem','nm_registro_bem',
        'nm_serie_bem','nm_marca_bem','nm_modelo_bem','qt_capacidade_bem','qt_voltagem_bem',
        'vl_aquisicao_bem','dt_aquisicao_bem','nm_obs_item','cd_produto','cd_cliente'
      ]

      const isDate = f => f.startsWith('dt_')
      const isNumber = f => f.startsWith('vl_') || f.startsWith('qt_') || f === 'cd_bem' || f.startsWith('cd_')
      const widthHint = f => {
        if (f === 'cd_bem') return 100
        if (f.startsWith('cd_')) return 120
        if (f.startsWith('vl_') || f.startsWith('qt_')) return 140
        if (f === 'ds_bem' || f === 'nm_obs_item') return 240
        return undefined
      }

      const cols = fields.map(f => {
        const col = {
          dataField: f,
          caption: this.lbl(f, f),
          dataType: isDate(f) ? 'date' : (isNumber(f) ? 'number' : 'string'),
          width: widthHint(f),
          allowEditing: f !== 'cd_bem', // chave não edita
          visible: true
        }

        if (f === 'vl_aquisicao_bem') col.format = { type: 'fixedPoint', precision: 2 }
        if (f === 'dt_aquisicao_bem') col.format = 'dd/MM/yyyy'

        if (f === 'cd_grupo_bem') {
          col.lookup = { dataSource: this.gruposDS }
          col.dataType = 'number'
        }

        return col
      })

      this.columnDefs = cols
    },

    // ===== lookup grupos =====
    async carregarGrupos (q = null) {
      try {
        const body = [{ ic_json_parametro: 'S', q }]
        const { data } = await api.post('/api/exec/pr_egis_lookup_grupo_bem', body)
        this.gruposDS = this.normalizeRows(data) // [{id, text}]
        // reatribui lookup na coluna caso o mount tenha corrido antes
        const col = this.columnDefs.find(c => c.dataField === 'cd_grupo_bem')
        if (col) col.lookup = { dataSource: this.gruposDS }
      } catch {
        this.gruposDS = []
      }
    },

    // ===== dados =====
    async carregarBem () {
      this.loading = true
      try {
        const body = [{ ic_json_parametro: 'S', cd_parametro: 1 }]
        const { data } = await api.post('/api/exec/pr_egis_ativo_processo_modulo', body)
        const rows = this.normalizeRows(data)
        // normaliza datas para o editor date (YYYY-MM-DD)
        rows.forEach(r => {
          if (r.dt_aquisicao_bem) {
            const d = this.parseLocalDate(r.dt_aquisicao_bem)
            if (d) r.dt_aquisicao_bem = this.toISODate(d)
          }
        })
        this.rows = rows
      } catch (e) {
        this.rows = []
      } finally {
        this.loading = false
      }
    },

    // ===== Toolbar =====
    addRow () {
      const inst = this.$refs.grid && this.$refs.grid.instance
      if (inst) inst.addRow()
    },

    // ===== CRUD Handlers =====
    async onRowInserting (e) {
      // e.data tem os campos novos
      const payload = { ...e.data }
      payload.dt_aquisicao_bem = this.toISODate(payload.dt_aquisicao_bem)
      const body = [{ ic_json_parametro: 'S', cd_parametro: 50, ...payload }]

      try {
        const { data } = await api.post('/api/exec/pr_egis_ativo_processo_modulo', body)
        const r = Array.isArray(data) ? data[0] : data
        if (!(r && r.ok === 1)) throw new Error(r?.erro || 'Falha no cadastro')
        // injeta o cd_bem retornado
        e.data.cd_bem = r.cd_bem
      } catch (err) {
        e.cancel = true
        this.$q.notify({ type: 'negative', message: err.message || 'Erro ao incluir' })
      }
    },

    async onRowUpdating (e) {
      // DevExtreme entrega only changes em e.newData – merge com old
      const merged = { ...e.oldData, ...e.newData }
      merged.dt_aquisicao_bem = this.toISODate(merged.dt_aquisicao_bem)

      const body = [{ ic_json_parametro: 'S', cd_parametro: 60, ...merged }]

      try {
        const { data } = await api.post('/api/exec/pr_egis_ativo_processo_modulo', body)
        const r = Array.isArray(data) ? data[0] : data
        if (!(r && r.ok === 1)) throw new Error(r?.erro || 'Falha na atualização')
      } catch (err) {
        e.cancel = true
        this.$q.notify({ type: 'negative', message: err.message || 'Erro ao atualizar' })
      }
    },

    async onRowRemoving (e) {
      const id = e.data && e.data.cd_bem
      if (!id) { e.cancel = true; return }
      const body = [{ ic_json_parametro: 'S', cd_parametro: 70, cd_bem: id }]

      try {
        const { data } = await api.post('/api/exec/pr_egis_ativo_processo_modulo', body)
        const r = Array.isArray(data) ? data[0] : data
        if (!(r && r.ok === 1)) throw new Error(r?.erro || 'Falha ao excluir')
      } catch (err) {
        e.cancel = true
        this.$q.notify({ type: 'negative', message: err.message || 'Erro ao excluir' })
      }
    }
  }
}
</script>
