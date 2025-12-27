<template>
  <div>
    <!-- Modal -->
    <div class="modal show d-block" v-if="visible">
      <div class="modal-dialog modal-fullscreen">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-scroll"></i>
              {{ modalTitle }}
            </h5>
            <button type="button" class="btn-close" @click="close"></button>
          </div>

          <div class="modal-body">
            <!-- Abas (ex.: só 1 aba “Cadastro” aqui para simplificar) -->
            <ul class="nav nav-pills nav-fill">
              <li class="nav-item">
                <a class="nav-link active">Cadastro</a>
              </li>
            </ul>

            <div class="tab-content mt-3">
              <div class="tab-pane fade show active">
                <div class="row g-3">
                  <div
                    v-for="campo in orderedFields"
                    :key="campo.nm_atributo"
                    class="col-12 col-md-6"
                  >
                    <label class="form-label">
                      {{ labelCampo(campo) }}
                    </label>

                    <!-- Caso 1: lookup com pesquisa dinâmica (cd_menu_pesquisa > 0) -->
                    <div
                      v-if="campo.cd_menu_pesquisa && campo.cd_menu_pesquisa > 0"
                      class="input-group"
                    >
                      <button
                        type="button"
                        class="btn btn-outline-secondary"
                        :disabled="isReadonly(campo)"
                        @click="abrirPesquisa(campo)"
                        title="Pesquisar"
                      >🔍</button>

                      <input
                        class="form-control"
                        :class="inputClass(campo)"
                        :name="campo.nm_atributo"
                        v-model="form[campo.nm_atributo]"
                        :readonly="isReadonly(campo)"
                        @blur="validarCampoDinamicoBlur(campo)"
                      />

                      <!-- Descrição (somente leitura) -->
                      <input
                        class="form-control mt-2"
                        :value="descricaoLookup(campo)"
                        readonly
                      />
                    </div>

                    <!-- Caso 2: Lista_Valor => <select> -->
                    <select
                      v-else-if="isListaValor(campo)"
                      class="form-control"
                      :class="inputClass(campo)"
                      :name="campo.nm_atributo"
                      v-model="form[campo.nm_atributo]"
                      :disabled="isReadonly(campo)"
                    >
                      <option value="">Selecione...</option>
                      <option
                        v-for="opt in listaValores(campo)"
                        :key="opt.cd_lista_valor"
                        :value="String(opt.cd_lista_valor)"
                      >
                        {{ opt.nm_lista_valor }}
                      </option>
                    </select>

                    <!-- Caso 3: lookup direto via nm_lookup_tabela => <select> -->
                    <select
                      v-else-if="campo.nm_lookup_tabela && !campo.cd_menu_pesquisa"
                      class="form-control"
                      :class="inputClass(campo)"
                      :name="campo.nm_atributo"
                      v-model="form[campo.nm_atributo]"
                      :disabled="isReadonly(campo)"
                    >
                      <option value="">Carregando...</option>
                      <option
                        v-for="opt in lookupOptions[campo.nm_atributo] || []"
                        :key="opt.__value"
                        :value="String(opt.__value)"
                      >
                        {{ opt.__label }}
                      </option>
                    </select>

                    <!-- Demais campos -->
                    <input
                      v-else
                      class="form-control"
                      :class="inputClass(campo)"
                      :type="inputType(campo)"
                      :name="campo.nm_atributo"
                      v-model="form[campo.nm_atributo]"
                      :readonly="isReadonly(campo)"
                      :disabled="isReadonly(campo)"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="modal-footer">
            <button v-if="mode==='novo'" class="btn btn-primary" @click="salvarNovo">Salvar</button>
            <button v-if="mode==='alteracao'" class="btn btn-warning" @click="salvarAlteracao">Alterar</button>
            <button class="btn btn-secondary" @click="close">Fechar</button>
          </div>
        </div>
      </div>
    </div>

    <!-- /Modal -->
  </div>
</template>

<script>
export default {
  name: "UnicoFormEspecialBackup",
  props: {
    visible: { type: Boolean, default: false },
    mode: { type: String, default: "novo" }, // 'novo' | 'alteracao'
    payload: { type: Array, default: () => [] }, // metadados dos campos
    record: { type: Object, default: () => ({}) }, // dados da alteração
  },
  data() {
    return {
      form: {},
      lookupOptions: {}, // { [nm_atributo]: [{__value, __label}, ...] }
    };
  },
  computed: {
    modalTitle() {
      const titulo = sessionStorage.getItem("menu_titulo") || "Cadastro";
      return this.mode === "novo" ? `Inclusão - ${titulo}` : `Alteração - ${titulo}`;
    },
    orderedFields() {
      // mesma ideia do form-especial.js: ordenar por nu_ordem
      const arr = [...this.payload];
      return arr.sort((a, b) => (a.nu_ordem || 0) - (b.nu_ordem || 0));
    },
  },
  watch: {
    visible(v) {
      if (v) this.initForm();
    },
  },
  methods: {
    // === Inicialização do formulário ===
    initForm() {
      // valores iniciais: no 'novo', pega defaults; no 'alteracao', carrega do record
      this.form = {};
      this.orderedFields.forEach((campo) => {
        const nome = campo.nm_atributo;
        let val = this.mode === "alteracao"
          ? (this.record[nome] ?? this.record[campo.nm_atributo_consulta])
          : (campo.vl_default || "");
        // data de hoje se marcado no meta e estiver vazio
        if (this.mode === "novo" && campo.ic_data_hoje === "S" && (val == null || val === "")) {
          const hoje = new Date();
          const dd = String(hoje.getDate()).padStart(2, "0");
          const mm = String(hoje.getMonth() + 1).padStart(2, "0");
          const yyyy = hoje.getFullYear();
          val = `${dd}/${mm}/${yyyy}`;
        }
        // chave com numeracao automatica => mostra '*' (visualmente no label), o valor pode ficar vazio/readonly
        this.form[nome] = val == null ? "" : val;
      });

      // carrega options de lookups diretos (nm_lookup_tabela)
      this.loadAllLookups();
    },

    // === Regras de visual ===
    isReadonly(campo) {
      if (this.mode === "novo") {
        // Regra 1: inclusão e ic_edita_cadastro='N' => sem edição
        return campo.ic_edita_cadastro === "N";
      }
      // Regra para alteração: se o metadado marcar como não editável
      return campo.ic_editavel === "N";
    },
    inputClass(campo) {
      return this.isReadonly(campo) ? "leitura-azul" : "";
    },
    labelCampo(campo) {
      const base =
        campo.nm_titulo_menu_atributo ||
        campo.nm_edit_label ||
        campo.ds_atributo ||
        campo.nm_atributo;
      const estrela = campo.ic_numeracao_automatica === "S" ? " *" : "";
      return base + estrela;
    },
    inputType(campo) {
      return (campo.nm_datatype === "date" || campo.nm_datatype === "shortDate") ? "date" : "text";
    },

    // === Lista de valores ===
    isListaValor(campo) {
      return this.listaValores(campo).length > 0;
    },
    listaValores(campo) {
      let lista = campo.Lista_Valor;
      if (!lista) return [];
      if (typeof lista === "string") {
        try { lista = JSON.parse(lista); } catch { lista = []; }
      }
      return Array.isArray(lista) ? lista : [];
    },

    // === Lookup com pesquisa dinâmica ===
    abrirPesquisa(campo) {
      // Reusa a função global (já existente no projeto)
      // mesmo padrão do form-especial.js
      window.abrirPesquisaDinamica &&
        window.abrirPesquisaDinamica(campo.nm_atributo, campo.cd_menu_pesquisa);
    },
    validarCampoDinamicoBlur(campo) {
      // idem ao form-especial.js: valida o código digitado e preenche descrição
      window.validarCampoDinamico &&
        window.validarCampoDinamico(
          { value: this.form[campo.nm_atributo] },
          campo.nm_atributo,
          campo.cd_menu_pesquisa
        );
    },
    descricaoLookup(campo) {
      // exibe o campo de “descrição” que vem mapeado no payload via nm_atributo_consulta
      const fromRecord =
        this.record?.[campo.nm_atributo_consulta] ??
        this.record?.[campo.nm_edit_label] ??
        "";
      return this.mode === "alteracao" ? (fromRecord || "") : "";
    },

    // === Lookup direto (nm_lookup_tabela) ===
    async loadAllLookups() {
      const toLoad = this.orderedFields.filter(
        (c) => c.nm_lookup_tabela && !c.cd_menu_pesquisa
      );
      await Promise.all(toLoad.map((c) => this.loadLookup(c)));
    },
    async loadLookup(campo) {
      try {
        const res = await fetch("/api/lookup", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ query: campo.nm_lookup_tabela }),
        });
        const rows = await res.json(); // backend já existente
        const nomeCampo = (campo.nm_atributo || "").toLowerCase();
        // tenta inferir {__value,__label}
        const opts = (rows || []).map((r) => {
          const values = Object.values(r || {});
          const __value = r[nomeCampo] ?? values[0];
          const __label = r.Descricao || r.label || values[1] || __value;
          return { __value, __label };
        });
        this.$set(this.lookupOptions, campo.nm_atributo, opts);
      } catch (e) {
        this.$set(this.lookupOptions, campo.nm_atributo, []);
      }
    },

    // === Persistência ===
    async salvarNovo() {
      // você pode reusar as helpers globais:
      // const payload = window.montarPayloadEnvio(1); window.enviarPayloadParaAPI(payload);
      // ou enviar direto para a rota que o projeto já expõe:
      await this.salvarGenerico(1);
    },
    async salvarAlteracao() {
      await this.salvarGenerico(2);
    },
    async salvarGenerico(tipoOperacao) {
      // Monta o payload básico no mesmo padrão do projeto
      const cd_menu = sessionStorage.getItem("cd_menu");
      const cd_usuario = sessionStorage.getItem("cd_usuario");
      const body = {
        cd_parametro: tipoOperacao, // 1=incluir | 2=alterar
        cd_menu,
        cd_usuario,
        ...this.form,
      };
      const res = await fetch("/api/api-dados-form", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      if (!res.ok) {
        alert("Erro ao salvar.");
        return;
      }
      this.$emit("saved"); // para o pai recarregar a grid
      this.close();
    },

    close() {
      this.$emit("close");
    },
  },
};
</script>

<style scoped>
/* azul para leitura/bloqueado (inclusão quando ic_edita_cadastro='N') */
.leitura-azul {
  background-color: #e7f1ff !important;
  color: #0d47a1;
}
/* herdando tuas bases do CSS global do projeto */
</style>
