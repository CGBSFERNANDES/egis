//<template>
  <div class="q-pa-md column gap-md">
    <!-- Seleção do cliente -->
    <q-card flat bordered class="q-pa-md" style="min-width: 200px; max-width: 95vw;">
        <!-- Cliente -->
    <div class="margin1">
      <cliente
        :cd_usuario="cd_usuario"
        @SelectCliente="SelecionaCliente($event)"
        @limpaCliente="cleanCliente($event)"
        :ic_pesquisa="true"
        :ic_pesquisa_contato="false"
      />
    </div>
      <div class="row items-center q-col-gutter-md">
        <div class="col-auto">
          <q-icon name="person_search" size="md" />
        </div>
        <div class="col">
          <!-- Componente existente: cliente.vue -->
          <!-- <cliente @cliente-selecionado="onClienteSelecionado" /> -->
        </div>
        <div class="col-auto">
          <q-btn
            label="Novo Registro"
            icon="add"
            color="primary"
            :disable="!cd_cliente"
            @click="novoRegistro"
          />
        </div>
        <div class="col-auto">
          <q-btn
            label="Recarregar"
            icon="refresh"
            color="secondary"
            :loading="loading"
            @click="carregarGrid"
          />
        </div>
      </div>
    
    <!-- Grid DevExtreme -->
    <q-card flat bordered>
      <div class="q-pa-sm">
        <DxDataGrid
          :data-source="dataSource"
          :remote-operations="false"
          :show-borders="true"
          :hover-state-enabled="true"
          :allow-column-reordering="true"
          :column-auto-width="true"
          @rowDblClick="editarRegistro"
        >
          <DxPaging :page-size="20" />
          <DxPager
            :show-page-size-selector="true"
            :allowed-page-sizes="[10, 20, 50, 100]"
            :show-info="true"
          />
          <DxFilterRow :visible="true" />
          <DxSearchPanel :visible="true" placeholder="Buscar..." />

          <!-- Colunas principais (com base no Excel Cliente_Empresa) -->
          <DxColumn data-field="cd_empresa" caption="Empresa" data-type="number" />
          <DxColumn data-field="cd_tipo_pedido" caption="Tipo Pedido" data-type="number" />
          <DxColumn data-field="cd_condicao_pagamento" caption="Cond. Pagto" data-type="number" />
          <DxColumn data-field="cd_tabela_preco" caption="Tabela Preço" data-type="number" />
          <DxColumn data-field="cd_transportadora" caption="Transportadora" data-type="number" />
          <DxColumn data-field="cd_conta_banco" caption="Conta Banco" data-type="number" />
          <DxColumn data-field="ic_padrao" caption="Padrão?" data-type="string" />
          <DxColumn data-field="cd_tipo_pedido_bonificacao" caption="Tipo Ped. Bonif." data-type="number" />
          <DxColumn data-field="cd_base_retirada" caption="Base de Retirada" data-type="number" />

          <DxColumn type="buttons">
            <DxButton icon="edit" hint="Editar" onClick="onEditar" />
            <DxButton icon="trash" hint="Excluir" onClick="onExcluir" />
          </DxColumn>
        </DxDataGrid>
      </div>
    </q-card>
</q-card>

    <!-- Dialog Edição -->
    <q-dialog v-model="dlg" persistent>
      <q-card style="min-width: 700px; max-width: 95vw;">
        <q-card-section class="row items-center q-gutter-sm">
          <q-icon name="edit_note" />
          <div class="text-h6">Cliente x Empresa</div>
          <q-space />
          <q-btn dense flat icon="close" v-close-popup />
        </q-card-section>

        <q-separator />

        <q-card-section class="q-gutter-md">
          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-4">
              <q-input v-model.number="form.cd_empresa" type="number" label="Empresa" dense outlined />
            </div>
            <div class="col-12 col-sm-4">
              <q-input v-model.number="form.cd_tipo_pedido" type="number" label="Tipo de Pedido" dense outlined />
            </div>
            <div class="col-12 col-sm-4">
              <q-input v-model.number="form.cd_condicao_pagamento" type="number" label="Condição de Pagamento" dense outlined />
            </div>

            <div class="col-12 col-sm-4">
              <q-input v-model.number="form.cd_tabela_preco" type="number" label="Tabela de Preço" dense outlined />
            </div>
            <div class="col-12 col-sm-4">
              <q-input v-model.number="form.cd_transportadora" type="number" label="Transportadora" dense outlined />
            </div>
            <div class="col-12 col-sm-4">
              <q-input v-model.number="form.cd_conta_banco" type="number" label="Conta Banco" dense outlined />
            </div>

            <div class="col-12 col-sm-4">
              <q-select
                v-model="form.ic_padrao"
                :options="[{label:'Sim',value:'S'},{label:'Não',value:'N'}]"
                label="Padrão?"
                dense outlined
                emit-value map-options
              />
            </div>
            <div class="col-12 col-sm-4">
              <q-input v-model.number="form.cd_tipo_pedido_bonificacao" type="number" label="Tipo Ped. Bonificação" dense outlined />
            </div>
            <div class="col-12 col-sm-4">
              <q-input v-model.number="form.cd_base_retirada" type="number" label="Base de Retirada" dense outlined />
            </div>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right" class="q-pa-md">
          <q-btn flat color="secondary" label="Cancelar" v-close-popup />
          <q-btn unelevated color="primary" :loading="salvando" label="Salvar" @click="salvar" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import axios from "axios";
import cliente from "@/views/cliente.vue"; // já existente
import {
  DxDataGrid, DxColumn, DxPaging, DxPager, DxFilterRow, DxSearchPanel, DxButton
} from "devextreme-vue/data-grid";

export default {
  name: "clienteEmpresa",
  components: { cliente, DxDataGrid, DxColumn, DxPaging, DxPager, DxFilterRow, DxSearchPanel, DxButton },
  data() {
    return {
      cd_cliente: null,
      dataSource: [],
      loading: false,
      dlg: false,
      salvando: false,
      mostraGrid: false,
      cd_usuario: localStorage.getItem("cd_usuario") || null,
      form: this.novoForm()
    };
  },
  methods: {

    async SelecionaCliente(e) {
      this.cd_cliente = e.cd_cliente;
      await this.carregarGrid();
      this.mostraGrid = true;
    },

    cleanCliente() {
      this.dataSourceConfig = [];
      this.qt_registro = 0;
    },
 
    novoForm() {
      return {
        // chaves:
        cd_cliente: this.cd_cliente || null,
        cd_empresa: null,

        // campos:
        cd_tipo_pedido: null,
        cd_condicao_pagamento: null,
        cd_tabela_preco: null,
        cd_transportadora: null,
        cd_conta_banco: null,
        ic_padrao: "N",
        cd_tipo_pedido_bonificacao: null,
        cd_base_retirada: null
      };
    },

    onClienteSelecionado(payload) {
        console.log("Cliente selecionado:", payload);

      // payload esperado do componente cliente.vue (ajuste se necessário)
      // Ex.: payload = { cd_cliente: 123, nm_cliente: '...' }
      this.cd_cliente = payload?.cd_cliente || null;
      //
      this.carregarGrid();
      //
    },

    async chamarProcedure(nomeProcedure, corpo) {
      // Rota universal do seu back-end
      // - aceita @json quando enviamos ic_json_parametro='S'
      // - usa banco da sessão/headers; OK para nosso uso
      // ver index.js para detalhes. :contentReference[oaicite:3]{index=3}
      const url = `https://egiserp.com.br/api/exec/${nomeProcedure}`;
      const { data } = await axios.post(url, corpo);
      return data;
    },

    async carregarGrid() {

      console.log("Carregando grid para cd_cliente:", this.cd_cliente);

      if (!this.cd_cliente) return;
      this.loading = true;
      try {
        const payload = [{
          ic_json_parametro: "S",
          cd_parametro: 0,           // listar
          cd_cliente: this.cd_cliente
        }];
        //
        console.log("Carregar grid com payload:", payload);
        const dados = await this.chamarProcedure("pr_egis_cliente_empresa", payload);
        //
        console.log("Dados recebidos:", dados);
        // Ajuste conforme a estrutura retornada pelo seu back-end
        this.dataSource = Array.isArray(dados) ? dados : [];
      } catch (err) {
        this.$q.notify({ type: "negative", message: "Erro ao carregar dados." });
        console.error(err);
      } finally {
        this.loading = false;
      }
    },

    novoRegistro() {
      this.form = this.novoForm();
      this.dlg = true;
    },

    editarRegistro(e) {
      const row = e?.data;
      if (!row) return;
      this.form = { ...row, cd_cliente: this.cd_cliente };
      this.dlg = true;
    },

    onEditar(e) {
      const row = e.row?.data;
      if (!row) return;
      this.form = { ...row, cd_cliente: this.cd_cliente };
      this.dlg = true;
    },

    async onExcluir(e) {
      const row = e.row?.data;
      if (!row) return;

      this.$q.dialog({
        title: "Confirmação",
        message: "Deseja excluir este vínculo Cliente/Empresa?",
        cancel: true,
        persistent: true
      }).onOk(async () => {
        try {
          const payload = [{
            ic_json_parametro: "S",
            cd_parametro: 2, // excluir
            cd_cliente: this.cd_cliente,
            cd_empresa: row.cd_empresa
          }];
          await this.chamarProcedure("pr_egis_cliente_empresa", payload);
          this.$q.notify({ type: "positive", message: "Excluído com sucesso." });
          this.carregarGrid();
        } catch (err) {
          this.$q.notify({ type: "negative", message: "Erro ao excluir." });
          console.error(err);
        }
      });
    },

    async salvar() {
      if (!this.cd_cliente || !this.form.cd_empresa) {
        this.$q.notify({ type: "warning", message: "Informe Cliente e Empresa." });
        return;
      }
      this.salvando = true;
      try {
        const payload = [{
          ic_json_parametro: "S",
          cd_parametro: 1, // upsert
          cd_cliente: this.cd_cliente,
          cd_empresa: this.form.cd_empresa,

          cd_tipo_pedido: this.form.cd_tipo_pedido,
          cd_condicao_pagamento: this.form.cd_condicao_pagamento,
          cd_tabela_preco: this.form.cd_tabela_preco,
          cd_transportadora: this.form.cd_transportadora,
          cd_conta_banco: this.form.cd_conta_banco,
          ic_padrao: this.form.ic_padrao || "N",
          cd_tipo_pedido_bonificacao: this.form.cd_tipo_pedido_bonificacao,
          cd_base_retirada: this.form.cd_base_retirada
        }];
        await this.chamarProcedure("pr_egis_cliente_empresa", payload);
        this.$q.notify({ type: "positive", message: "Salvo com sucesso." });
        this.dlg = false;
        this.carregarGrid();
      } catch (err) {
        this.$q.notify({ type: "negative", message: "Erro ao salvar." });
        console.error(err);
      } finally {
        this.salvando = false;
      }
    }
  }
};
</script>

<style scoped>
.column.gap-md > * + * { margin-top: 12px; }
</style>
