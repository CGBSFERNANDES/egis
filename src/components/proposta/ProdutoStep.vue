<template>
  <div>
    <div class="row items-center q-mb-sm">
      <div class="text-subtitle2 text-weight-bold">Produtos</div>
      <q-space />
      <q-btn dense outline color="deep-purple-7" icon="add" label="Adicionar" @click="addRow" />
    </div>

    <dx-data-grid
      ref="grid"
      :data-source="localRows"
      key-expr="id"
      :show-borders="true"
      :column-auto-width="true"
      :row-alternation-enabled="true"
      :hover-state-enabled="true"
      @row-updating="onRowUpdating"
      @row-inserting="onRowInserting"
      @row-inserted="emitRows"
      @row-updated="emitRows"
      @row-removed="emitRows"
    >
      <dx-editing
        mode="row"
        :allow-updating="true"
        :allow-adding="true"
        :allow-deleting="true"
        :use-icons="true"
        new-row-position="top"
      />

      <dx-column data-field="tp_item" caption="Tipo" width="90" :allow-editing="false" />
      <dx-column data-field="ds_item" caption="Descrição" />
      <dx-column data-field="qt_item" caption="Qtde" width="90" data-type="number" />
      <dx-column data-field="vl_unitario" caption="Vlr Unit" width="120" data-type="number" format="currency" />
      <dx-column data-field="pc_desconto" caption="% Desc" width="110" data-type="number" />
      <dx-column data-field="vl_total" caption="Total" width="130" data-type="number" format="currency" :allow-editing="false" />

      <dx-summary>
        <dx-total-item column="vl_total" summary-type="sum" value-format="currency" display-format="Total: {0}" />
      </dx-summary>
    </dx-data-grid>

    <div class="text-caption text-grey-7 q-mt-sm">
      Dica: o campo <b>Total</b> é calculado automaticamente: (qtde × unit) − desconto.
    </div>
  </div>
</template>

<script>
import DxDataGrid, { DxColumn, DxEditing, DxSummary, DxTotalItem } from "devextreme-vue/data-grid";

export default {
  name: "ProdutoStep",
  components: { DxDataGrid, DxColumn, DxEditing, DxSummary, DxTotalItem },
  props: { value: { type: Array, default: () => [] } },

  data() {
    return {
      localRows: (this.value || []).map(r => ({ ...r, id: r.id || this.makeId() }))
    };
  },

  watch: {
    // sincroniza do pai -> filho (sem watcher em rows)
    value: {
      deep: true,
      handler(v) {
        this.localRows = (v || []).map(r => ({ ...r, id: r.id || this.makeId() }));
      }
    }
  },

  methods: {
    makeId() {
      return Date.now() + Math.floor(Math.random() * 100000);
    },

    calcRow(row) {
      const qt = Number(row.qt_item || 0);
      const vu = Number(row.vl_unitario || 0);
      const pc = Number(row.pc_desconto || 0);
      const bruto = qt * vu;
      const desc = bruto * (pc / 100);
      row.vl_total = Number((bruto - desc).toFixed(2));
      return row;
    },

    emitRows() {
      this.$emit("input", (this.localRows || []).map(r => ({ ...r })));
    },

    addRow() {
      const grid = this.$refs.grid && this.$refs.grid.instance;
      if (grid) {
        try { grid.updateDimensions(); } catch (e) {}
        grid.addRow();
        return;
      }

      // fallback
      const row = this.calcRow({
        id: this.makeId(),
        tp_item: "PROD",
        ds_item: "",
        qt_item: 1,
        vl_unitario: 0,
        pc_desconto: 0,
        vl_total: 0
      });
      this.localRows = [row, ...this.localRows];
      this.emitRows();
    },

    onRowUpdating(e) {
      e.newData = this.calcRow({ ...e.oldData, ...e.newData });
    },

    onRowInserting(e) {
      e.data = this.calcRow({
        id: this.makeId(),
        tp_item: "PROD",
        ...e.data
      });
    }
  }
};
</script>
