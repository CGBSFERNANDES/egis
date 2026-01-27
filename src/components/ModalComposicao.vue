<template>
  <q-dialog v-model="internalVisible" persistent>
    <q-card style="min-width: 980px; max-width: 98vw;">
      <q-card-section class="row no-wrap items-start q-gutter-md">
        <!-- COLUNA ESQUERDA: ÍCONE / IDENTIDADE VISUAL -->
        <div
          class="col-auto flex flex-center bg-deep-purple-1 q-pa-lg"
          style="border-radius: 80px;"
        >
          <q-icon name="tune" size="56px" color="deep-purple-7" />
        </div>

        <!-- COLUNA DIREITA: CONTEÚDO -->
        <div class="col">
          <!-- TÍTULO + BOTÃO FECHAR -->
          <div class="row items-start justify-between">
            <div>
              <div class="text-h6 text-weight-bold">
                {{ tituloModal }}
                <q-badge
                  rounded
                  class="q-ml-sm top-badge"
                  color="deep-orange-7"
                  :label="String(cdModalBadge)"
                />
              </div>

              <div class="text-caption text-grey-7">
                {{ subTituloModal }}
              </div>
            </div>

            <q-btn icon="close" flat round dense @click="fechar" />
          </div>

          <q-separator spaced />

          <!-- CONTEÚDO PRINCIPAL -->
          <div v-if="loading" class="row justify-center q-my-lg">
            <q-spinner size="42px" />
          </div>

          <div v-else>
            <div
              v-for="(campo, index) in meta"
              :key="campo.nm_atributo || campo.cd_atributo || index"
              class="row q-mb-sm items-center"
            >
              <div class="col-4 text-weight-medium">
                {{ labelCampo(campo) }}
              </div>

              <div class="col-8">
                <!-- input dinâmico -->

                <component
                  :is="resolveComponent(campo)"
                  v-model="valores[campo.nm_atributo]"
                  dense
                  outlined
                  clearable
                  :type="resolveType(campo)"
                  :options="getOptions(campo)"
                  emit-value
                  map-options
                  :label="campo.ds_campo_help || ''"
                  :hint="campo.ds_campo_help || ''"
                  :readonly="isSomenteLeitura(campo)"
                  :class="{ 'leitura-azul': isSomenteLeitura(campo) }"
                  :input-style="{
                    textAlign: 'center',
                    paddingTop: '8px',
                    paddingBottom: '8px',
                    lineHeight: '20px',
                    backgroundColor: isSomenteLeitura(campo) ? '#e3f2fd' : undefined,
                    color: isSomenteLeitura(campo) ? '#000000' : undefined,
                    fontWeight: isSomenteLeitura(campo) ? 'bold' : undefined
                  }"
                  :style="estiloCampo(campo)"
                  :bg-color="bgColorCampo(campo)"
                >
                  <template
                    v-if="!campo.nm_lookup_tabela && !campo.Lista_Valor"
                    v-slot:prepend
                  >
                    <q-icon name="tune" />
                  </template>
                  <template v-slot:append>
                    <q-btn
                      v-if="Number(campo.cd_menu || 0) !== 0"
                      dense
                      flat
                      round
                      icon="search"
                      @click="abrirUnicoEspecial(campo)"
                    >
                      <q-tooltip>Buscar</q-tooltip>
                    </q-btn></template
                  >
                </component>
                <!-- descrição do lookup direto (igual UnicoFormEspecial) -->
                <q-input
                  v-if="1 === 2 && temLookupDireto(campo)"
                  class="q-mt-xs leitura-azul"
                  :value="descricaoLookup(campo)"
                  label="Descrição"
                  readonly
                  filled
                  :disable="isSomenteLeitura(campo)"
                  :class="{ 'leitura-azul': isSomenteLeitura(campo) }"
                />
              </div>
            </div>
          </div>
        </div>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn flat label="Cancelar" @click="fechar" />
        <q-btn color="deep-purple-7" label="Confirmar" @click="confirmar" />
      </q-card-actions>
    </q-card>

    <q-dialog v-model="showUnicoEspecial" persistent>
      <q-card style="min-width: 95vw; min-height: 90vh;">
        <UnicoFormEspecial
          :cd_menu_entrada="this.cd_menu_item_modal"
          :cd_menu_modal_entrada="0"
          :titulo_menu_entrada="tituloMenuUnico"
          :cd_acesso_entrada="0"
          ic_modal_pesquisa="S"
          @fechar="fecharUnicoEspecial"
        />
      </q-card>
    </q-dialog>
  </q-dialog>
</template>

<script>
import axios from "axios";
//import UnicoFormEspecial from '@/views/unicoFormEspecial.vue'

// Se você já tem um `api` global, pode importar de lá.
// Aqui deixo um exemplo simples, igual ao estilo do UnicoFormEspecial.
const api = axios.create({
  baseURL: "https://egiserp.com.br/api",
  withCredentials: true,
  timeout: 60000,
});

api.interceptors.request.use(cfg => {
  const banco = localStorage.nm_banco_empresa || "";
  if (banco) cfg.headers["x-banco"] = banco;
  cfg.headers["Authorization"] = "Bearer superchave123";
  if (!cfg.headers["Content-Type"])
    cfg.headers["Content-Type"] = "application/json";
  return cfg;
});

function montaDadosTecnicos(row, meta) {
  if (!row || typeof row !== "object") row = {};
  if (!Array.isArray(meta)) meta = [];

  const dadosTecnicos = {};

  meta.forEach(m => {
    if (!m || !m.nm_atributo) return;

    const candidatos = [
      m.nm_atributo,
      m.nm_titulo_menu_atributo,
      m.nm_atributo_consulta,
    ].filter(Boolean);

    let valor;

    for (let i = 0; i < candidatos.length; i++) {
      const k = candidatos[i];

      if (k in row) {
        valor = row[k];
        break;
      }

      const alt = Object.keys(row).find(
        kk => kk.toLowerCase() === String(k).toLowerCase()
      );
      if (alt) {
        valor = row[alt];
        break;
      }
    }

    // normalizações
    const tipo = String(m.nm_datatype || "").toLowerCase();

    if (valor === "") valor = null;

    // Datas
    if (
      valor != null &&
      (tipo === "date" || tipo === "datetime" || tipo === "shortdate")
    ) {
      const isoMatch = /^(\d{4})-(\d{2})-(\d{2})$/.exec(valor);
      if (isoMatch) {
        const [, yyyy, mm, dd] = isoMatch;
        valor = `${yyyy}-${mm}-${dd}`;
      } else {
        const d = new Date(valor);
        if (!isNaN(d.getTime())) {
          const yyyy = d.getFullYear();
          const mm = String(d.getMonth() + 1).padStart(2, "0");
          const dd = String(d.getDate()).padStart(2, "0");
          valor = `${yyyy}-${mm}-${dd}`;
        } else {
          valor = null;
        }
      }
    }

    // Number / Currency
    if (valor != null && (tipo === "number" || tipo === "currency")) {
      if (typeof valor === "string") {
        const s = valor
          .replace(/[R$\s]/g, "")
          .replace(/\./g, "")
          .replace(",", ".");
        const n = +s;
        if (!isNaN(n)) valor = n;
      }
    }

    // grava no objeto técnico
    dadosTecnicos[m.nm_atributo] = valor == null ? "" : valor;
  });

  // limpeza de sobras comuns
  delete dadosTecnicos.id;
  delete dadosTecnicos["Código"];
  delete dadosTecnicos["Descricao"];
  delete dadosTecnicos["Descrição"];

  return dadosTecnicos;
}

export default {
  name: "ModalComposicao",
  components: {
    UnicoFormEspecial: () => import("@/views/unicoFormEspecial.vue"),
  },
  props: {
    // v-model
    value: {
      type: Boolean,
      default: false,
    },
    cdModal: {
      type: Number,
      required: true,
    },
    registrosSelecionados: {
      type: Array,
      default: () => [],
    },
  },

  data() {
    return {
      internalVisible: this.value,
      loading: false,
      meta: [], // retorno da pr_egis_modal_composicao
      valores: {}, // objeto com valores dos campos
      tituloModal: "",
      subTituloModal: "",
      headerBanco: localStorage.nm_banco_empresa,
      cd_usuario: localStorage.cd_usuario || 0,
      cd_menu: localStorage.cd_menu || 0,
      lookupOptions: {},
      nm_procedimento: "",
      cd_parametro_procedimento: 0,
      // 👇 para arrastar o modal
      dragX: 0,
      dragY: 0,
      dragStartX: 0,
      dragStartY: 0,
      showUnicoEspecial: false,
      campoUnicoAtivo: null, // guarda qual input chamou o unico
      cdMenuAnterior: Number(localStorage.cd_menu || 0), // pra restaurar
      cd_menu_item_modal: 0,
      tituloMenuUnico: "",
      cd_modal: 0,
    };
  },

  computed: {
    cardStyle() {
      return {
        minWidth: "980px",
        maxWidth: "98vw",
        transform: `translate(${this.dragX}px, ${this.dragY}px)`,
        transition: this.loading ? "none" : "transform 0.03s linear",
      };
    },

    cdModalBadge() {
      // se você tiver um cd_modal fixo do próprio modal, use ele aqui
      // fallback: tenta pegar do meta (primeiro item), e por fim do localStorage
      const m0 = this.cd_modal || 0;
      console.log("badge", m0);
      return Number(
        (m0 && (m0.cd_modal || m0.cd_menu)) ||
          this.cd_modal ||
          this.cd_menu ||
          localStorage.cd_menu ||
          0
      );
    },
  },

  watch: {
    value(val) {
      this.internalVisible = val;
      if (val) {
        this.carregarMeta();
      }
    },
    internalVisible(val) {
      this.$emit("input", val); // para funcionar v-model no Vue 2
    },
  },

  created() {
    this.headerBanco = localStorage.nm_banco_empresa;

    if (this.value) {
      this.carregarMeta();
    }
    //
  },

  methods: {
    fechar() {
      this.internalVisible = false;
    },

    abrirUnicoEspecial(campo) {
      if (!campo || Number(campo.cd_menu || 0) === 0) return;

      // guarda qual campo disparou
      this.campoUnicoAtivo = campo;

      // salva o cd_menu atual pra restaurar na volta
      this.cdMenuAnterior = Number(localStorage.cd_menu || 0);

      // seta o cd_menu do meta no localStorage (o Unico usa isso)
      localStorage.cd_menu = Number(campo.cd_menu);
      //
      this.cd_menu_item_modal = Number(campo.cd_menu || 0);

      this.tituloMenuUnico =
        campo.nm_menu_titulo || this.labelCampo(campo) || "";

      // abre o unico
      this.showUnicoEspecial = true;
      //
    },

    pegaValorSelecionado(row, campo) {
      if (!row || !campo) return null;

      const candidatos = [
        campo.nm_atributo, // ex: nm_fantasia_cliente
        campo.nm_atributo_consulta, // se existir
        campo.nm_atributo_lookup, // se existir
        campo.nm_campo_retorno, // se você tiver isso no payload
      ].filter(Boolean);

      for (let i = 0; i < candidatos.length; i++) {
        const k = candidatos[i];
        if (row[k] !== undefined) return row[k];

        // case-insensitive fallback
        const achou = Object.keys(row).find(
          kk => kk.toLowerCase() === String(k).toLowerCase()
        );
        if (achou) return row[achou];
      }
      return null;
    },

    lerMapaConsultaParaAtributo() {
      try {
        return JSON.parse(
          sessionStorage.getItem("mapa_consulta_para_atributo") || "{}"
        );
      } catch (e) {
        return {};
      }
    },

    traduzRegistroSelecionado(rowTela) {
      const mapa = this.lerMapaConsultaParaAtributo();
      const rowTec = {};

      Object.keys(rowTela || {}).forEach(kTela => {
        const kTec = mapa[kTela];
        if (kTec) rowTec[kTec] = rowTela[kTela];
      });

      // também mantém o original caso precise
      return { ...rowTela, ...rowTec };
    },

    fecharUnicoEspecial() {
      // fecha dialog
      this.showUnicoEspecial = false;

      // restaura cd_menu anterior
      localStorage.cd_menu = Number(this.cdMenuAnterior || 0);

      // tenta recuperar o registro selecionado que o Unico salva
      const cdMenuDoUnico = Number(this.campoUnicoAtivo?.cd_menu || 0);

      let sel = null;

      try {
        // prioridade: o Unico costuma salvar por cd_menu
        const key = cdMenuDoUnico
          ? `registro_selecionado_${cdMenuDoUnico}`
          : "registro_selecionado";
        sel = JSON.parse(sessionStorage.getItem(key) || "null");
        if (!sel)
          sel = JSON.parse(
            sessionStorage.getItem("registro_selecionado") || "null"
          );
      } catch (e) {
        sel = null;
      }

      if (!sel || !this.campoUnicoAtivo) return;

      //
      const selTec = this.traduzRegistroSelecionado(sel);
      //

      const nm = this.campoUnicoAtivo.nm_atributo;
      //const valor = this.pegaValorSelecionado(sel, this.campoUnicoAtivo)
      const valor = selTec[nm];

      if (nm && valor !== null && valor !== undefined) {
        this.$set(this.valores, nm, valor); // ✅ ex.: valores['nm_fantasia_cliente'] = 'ADEILDA MARIA...'
      }

      // 2) ✅ preenche a chave (cd_chave_retorno)
      const chaveCampo = this.campoUnicoAtivo.cd_chave_retorno; // ex.: cd_cliente
      if (chaveCampo) {
        const valorChave =
          selTec[chaveCampo] !== undefined && selTec[chaveCampo] !== null
            ? selTec[chaveCampo]
            : selTec.id;

        if (valorChave !== undefined && valorChave !== null) {
          this.$set(this.valores, chaveCampo, valorChave);
        }
      }

      this.campoUnicoAtivo = null;

      // escolha do valor de retorno (ajuste se você tiver um campo padrão tipo cd_xxx)
      /*
    const valorRetorno =
      (sel[nm] !== undefined ? sel[nm] : null) ??
      (sel.cd_chave !== undefined ? sel.cd_chave : null) ??
      (sel.id !== undefined ? sel.id : null) ??
      (sel.ds_nome !== undefined ? sel.ds_nome : null)

    if (valorRetorno !== null) {
      this.$set(this.valores, nm, valorRetorno)
    }
    */

      // limpa
      this.campoUnicoAtivo = null;
      //
    },

    onPan(ev) {
      // arrasta o card inteiro
      if (ev.isFirst) {
        this.dragStartX = this.dragX;
        this.dragStartY = this.dragY;
      }

      this.dragX = this.dragStartX + ev.delta.x;
      this.dragY = this.dragStartY + ev.delta.y;
    },

    isSomenteLeitura(campo) {
      // prioridade para ic_edicao_atributo, se existir
      let flag = null;

      if (campo.ic_edicao_atributo != null) {
        flag = String(campo.ic_edicao_atributo).toUpperCase();
      } else if (campo.ic_edita_cadastro != null) {
        flag = String(campo.ic_edita_cadastro).toUpperCase();
      } else {
        // se backend não mandar nada, consideramos editável
        flag = "S";
      }

      // somente leitura quando flag != 'S'
      return flag !== "S";
    },

    bgColorCampo(campo) {
      // azul clarinho só para campos somente leitura
      return this.isSomenteLeitura(campo) ? "blue-1" : void 0;
    },

    inputStyleCampo() {
      return { textAlign: "center" };
    },

    // se não estiver usando pra mais nada, pode até remover
    estiloCampo(campo) {
      return {};
    },

    async confirmar() {
      try {
        if (!this.nm_procedimento) {
          this.$q?.notify?.({
            type: "negative",
            message: "Procedure do modal não informada.",
          });
          return;
        }

        // devolve para o pai os valores e a meta, se você quiser usar depois
        this.$emit("confirmar", {
          valores: this.valores,
          meta: this.meta,
        });

        console.log(
          "[confirmar modal] registrosSelecionados =>",
          this.registrosSelecionados
        );
        console.log("[confirmar modal] valores do modal =>", this.valores);
        console.log("[confirmar modal] meta do modal =>", this.meta);

        //Mapa dos Registros//
        // 1) Recupera o META (igual no salvarCrud)

        let meta = [];
        try {
          meta = JSON.parse(sessionStorage.getItem("campos_grid_meta") || "[]");
        } catch (_) {
          meta = Array.isArray(this.gridMeta) ? this.gridMeta : [];
        }

        // 2) Mapa dos Registros: objeto técnico COMPLETO de cada linha selecionada
        const docsSelecionados = (this.registrosSelecionados || []).map(row =>
          montaDadosTecnicos(row, meta)
        );

        console.log("dados do registro selecionado -> ", docsSelecionados);
        console.log("dados do modal digitado -> ", this.valores);

        // 🔁 PATCH: copia valores da GRID para o MODAL quando o atributo é igual
        if (Array.isArray(docsSelecionados) && docsSelecionados.length > 0) {
          const origem = docsSelecionados[0]; // usa a primeira linha selecionada

          if (origem && typeof origem === "object" && this.valores) {
            Object.keys(this.valores).forEach(atributoModal => {
              // se o registro técnico tiver o mesmo atributo, copia o valor
              if (Object.prototype.hasOwnProperty.call(origem, atributoModal)) {
                const valorGrid = origem[atributoModal];

                // regra: só sobrescreve se o valor do modal estiver vazio/nulo
                const atual = this.valores[atributoModal];
                if (
                  atual === null ||
                  atual === "" ||
                  typeof atual === "undefined"
                ) {
                  this.$set(this.valores, atributoModal, valorGrid);
                }

                // 👉 Se você quiser SEMPRE sobrescrever, troque pelo:
                // this.$set(this.valores, atributoModal, valorGrid);
              }
            });
          }
        }

        // monta o JSON no mesmo padrão do resto do sistema:
        // ic_json_parametro = 'S', cd_parametro = cdParametroExec do modal

        const body = [
          {
            ic_json_parametro: "S",
            cd_parametro: Number(this.cd_parametro_procedimento),
            cd_usuario: this.cd_usuario,
            cd_modal: this.cdModal,
            // espalha os valores digitados no modal (dt_baixa_documento, nm_tipo_pagamento, etc)
            //...this.valores,
            dados_modal: this.valores,
            dados_registro: docsSelecionados,
          },
        ];

        const cfg = this.headerBanco
          ? { headers: { "x-banco": this.headerBanco } }
          : undefined;

        console.log("[confirmar modal] body =>", body);

        // chama a procedure do modal, ex.: /exec/pr_egis_pagar_processo_modulo
        await api.post(`/exec/${this.nm_procedimento}`, body, cfg);

        const titulo = this.tituloModal || "Processo";

        this.$q?.notify?.({
          type: "positive",
          position: "top",
          message: `${titulo} realizado com sucesso!`,
        });

        // informa o pai para refresh e fecha
        this.$emit("sucesso");
        this.fechar();
      } catch (e) {
        console.error("Erro ao confirmar modal:", e);
        this.$q?.notify?.({
          type: "negative",
          position: "top",
          message:
            (e.response &&
              e.response.data &&
              (e.response.data.Msg || e.response.data.msg)) ||
            e.message ||
            "Erro ao executar o processo do modal.",
        });
      }
    },

    hojeIso() {
      const d = new Date();
      const yyyy = d.getFullYear();
      const mm = String(d.getMonth() + 1).padStart(2, "0");
      const dd = String(d.getDate()).padStart(2, "0");
      return `${yyyy}-${mm}-${dd}`;
    },

    chaveCampo(campo, index) {
      if (campo.nm_atributo) return campo.nm_atributo;
      if (campo.cd_atributo) return `attr_${campo.cd_atributo}`;
      return `idx_${index}`;
    },

    labelCampo(campo) {
      return (
        campo.nm_titulo_menu_atributo ||
        campo.nm_atributo_consulta ||
        campo.nm_atributo ||
        ""
      );
    },

    // ---------- LOOKUP (nm_lookup_tabela) ----------

    temLookupDireto(campo) {
      return !!(campo.nm_lookup_tabela && campo.nm_lookup_tabela.trim() !== "");
    },

    async postLookup(query) {
      console.log("[lookup] query =>", query);

      const cfg = this.headerBanco
        ? { headers: { "x-banco": this.headerBanco } }
        : undefined;

      const { data } = await api.post("/lookup", { query }, cfg);
      return Array.isArray(data) ? data : [];
    },

    async carregarLookupsDiretos() {
      const attrs = (this.meta || []).filter(a => this.temLookupDireto(a));
      if (!attrs.length) return;

      await Promise.all(attrs.map(a => this.carregarLookupDireto(a)));
    },

    async carregarLookupDireto(campo) {
      if (!this.temLookupDireto(campo)) return;

      // consulta ao backend, igual UnicoFormEspecial
      const rows = await this.postLookup(campo.nm_lookup_tabela);

      // coluna de código: prioriza nm_atributo_lookup (ex.: cd_tipo_caixa)
      const nomeCodigo = (campo.nm_atributo_lookup || "").toLowerCase();

      const opts = rows.map(r => {
        const vals = Object.values(r || {});
        const code =
          nomeCodigo && r[nomeCodigo] != null ? r[nomeCodigo] : vals[0];
        const label =
          r.Descricao != null ? r.Descricao : vals[1] != null ? vals[1] : code;

        return {
          value: String(code),
          label: String(label),
        };
      });

      if (!this.lookupOptions) this.lookupOptions = {};
      this.$set(this.lookupOptions, campo.nm_atributo, opts);
    },

    descricaoLookup(campo) {
      const nm = campo.nm_atributo;
      const val = this.valores[nm];
      if (val === undefined || val === null || val === "") return "";

      const opts = this.lookupOptions?.[nm] || [];
      const found = opts.find(o => String(o.value) === String(val));
      return found ? found.label : "";
    },

    // Mesmo conceito do resolvType do UnicoFormEspecial

    resolveType(f) {
      const nome = (f.nm_atributo || "").toLowerCase();
      const titulo = (f.nm_titulo_menu_atributo || "").toLowerCase();
      const tipo = (f.nm_datatype || "").toLowerCase();

      // textarea vindo do meta
      if (tipo === "textarea" || tipo === "text_area" || tipo === "memo") {
        return "textarea";
      }

      // se o título começar com "data" ou contiver "data", já trata como date
      if (
        titulo.startsWith("data ") ||
        titulo === "data" ||
        titulo.includes("data pagamento") ||
        titulo.includes("data da baixa")
      ) {
        return "date";
      }

      if (
        nome.includes("dt_inicial") ||
        nome.includes("dt_final") ||
        f.nm_datatype === "date"
      ) {
        return "date";
      }

      if (/(date|data)/.test(nome)) return "date";
      if (/(number|inteiro|decimal)/.test(nome)) return "number";

      return "text";
    },

    // Decide se usa q-input ou q-select

    resolveComponent(campo) {
      const lista = (campo.Lista_Valor || "").toString().trim();
      const hasLista = lista !== "" && lista !== "N";
      const hasLookup =
        campo.nm_lookup_tabela && campo.nm_lookup_tabela.trim() !== "";

      // se tiver Lista_Valor válida OU lookup, usa select
      if (hasLista || hasLookup) {
        return "q-select";
      }

      // senão, é input normal
      return "q-input";
    },

    // Monta opções a partir de Lista_Valor (quando houver)
    normalizaOpcao(item) {
      if (!item || typeof item !== "object") {
        return { label: String(item || ""), value: item };
      }

      return {
        label:
          item.nm_lista_valor ||
          item.nm_atributo_consulta ||
          item.ds_atributo ||
          item.Descricao ||
          item.label ||
          "",
        value:
          item.cd_lista_valor ||
          item.cd_atributo ||
          item.valor ||
          item.value ||
          "",
      };
    },

    getOptions(campo) {
      // 1) LOOKUP direto (nm_lookup_tabela)
      if (this.temLookupDireto(campo)) {
        return this.lookupOptions[campo.nm_atributo] || [];
      }

      // 2) Lista_Valor
      let l = campo.Lista_Valor;
      if (!l) return [];

      if (typeof l === "string") {
        l = l.trim();
        if (!l || l === "N") return [];
      }

      // se já vier array
      if (Array.isArray(l)) {
        return l.map(this.normalizaOpcao);
      }

      // tentar JSON se for string
      if (typeof l === "string") {
        try {
          const parsed = JSON.parse(l);
          if (Array.isArray(parsed)) {
            return parsed.map(this.normalizaOpcao);
          }
          return [];
        } catch (e) {
          console.warn(
            "Lista_Valor não é JSON válido para",
            campo.nm_atributo,
            l
          );
          return [];
        }
      }

      return [];
    },

    //Dados do Modal

    async carregarMeta() {
      if (!this.cdModal) return;

      this.loading = true;

      try {
        this.cd_usuario = Number(
          localStorage.cd_usuario || sessionStorage.getItem("cd_usuario") || 0
        );

        this.cd_menu =
          localStorage.cd_menu ||
          Number(sessionStorage.getItem("cd_menu") || 0);

        // Monta o payload no padrão ic_json_parametro = 'S'
        // igual o entradaXML.vue faz com outras procedures.
        const body = [
          {
            ic_json_parametro: "S",
            cd_parametro: 1,
            cd_usuario: this.cd_usuario,
            cd_modal: this.cdModal,
          },
        ];

        const cfg =
          this.headerBanco || localStorage.nm_banco_empresa
            ? { headers: { "x-banco": this.headerBanco } }
            : undefined;

        console.log("payload modal composição => ", cfg, body);

        const { data } = await api.post(
          "/exec/pr_egis_modal_composicao",
          body,
          cfg
        );

        this.meta = Array.isArray(data) ? data : [];

        console.log("resultado: ", this.meta);

        if (this.meta.length) {
          const first = this.meta[0];

          this.cd_modal = first.cd_modal || 0;
          this.nm_procedimento = first.nm_procedimento;
          this.cd_parametro_procedimento = first.cd_parametro;
          //
          this.tituloModal =
            first.nm_titulo_form || first.nm_titulo || "Composição";
          this.subTituloModal = first.nm_tabela || "";
        } else {
          this.tituloModal = "Composição";
          this.subTituloModal = "";
        }

        console.log(
          "parametro de consulta do atributo-->",
          this.cd_parametro_procedimento
        );
        // inicializa valores com vl_default (quando tiver)
        this.valores = {};
        //

        (this.meta || []).forEach(campo => {
          if (!campo.nm_atributo) return;
          let def = (campo.vl_default || "").trim();
          //
          // se for campo de data e ic_data_hoje = 'S', força hoje
          if (
            campo.ic_data_hoje === "S" &&
            (campo.nm_datatype === "date" ||
              (campo.nm_atributo || "").toLowerCase().includes("data") ||
              (campo.nm_atributo || "").toLowerCase().includes("dt_"))
          ) {
            def = this.hojeIso();
          }

          //
          this.$set(this.valores, campo.nm_atributo, def || null);
          //
          //aqui preencher com os valores da Grid

          //
        });

        // 🔁 PATCH FINAL: usar o mesmo fluxo do confirmar() para preencher o modal

        try {
          // 1) tenta pegar registrosSelecionados vindo da prop
          let selecionados = Array.isArray(this.registrosSelecionados)
            ? this.registrosSelecionados
            : [];

          // 2) se ainda estiver vazio, tenta o sessionStorage
          if (!selecionados.length) {
            try {
              const cdMenu = this.cd_menu || sessionStorage.getItem("cd_menu");
              let raw = null;

              if (cdMenu) {
                raw = sessionStorage.getItem(`registro_selecionado_${cdMenu}`);
              }
              if (!raw) {
                raw = sessionStorage.getItem("registro_selecionado");
              }

              if (raw) {
                const linha = JSON.parse(raw);
                selecionados = [linha];
              }
            } catch (e) {
              console.warn(
                "[carregarMeta] erro ao ler registro_selecionado do sessionStorage:",
                e
              );
            }
          }

          console.log("[carregarMeta] selecionados =>", selecionados);

          if (!selecionados.length) {
            console.warn(
              "[carregarMeta] nenhuma linha selecionada para preencher o modal"
            );
          } else {
            // 3) pega o META da GRID e monta o objeto técnico (igual no confirmar)
            const metaGrid = JSON.parse(
              sessionStorage.getItem("campos_grid_meta") || "[]"
            );

            const docsSelecionados = selecionados.map(row =>
              montaDadosTecnicos(row, metaGrid)
            );

            console.log(
              "[carregarMeta] docsSelecionados (grid técnico) =>",
              docsSelecionados
            );

            const origem = docsSelecionados[0] || {};

            // 4) para cada campo do modal, se existir no objeto técnico, copia
            Object.keys(this.valores).forEach(atributoModal => {
              if (Object.prototype.hasOwnProperty.call(origem, atributoModal)) {
                const valorGrid = origem[atributoModal];
                const atual = this.valores[atributoModal];

                // sobrescreve só se estava vazio
                if (
                  atual === null ||
                  atual === "" ||
                  typeof atual === "undefined"
                ) {
                  this.$set(this.valores, atributoModal, valorGrid);
                }
              }
            });
          }
        } catch (e) {
          console.warn(
            "[carregarMeta] erro ao cruzar registro x meta do modal (grid técnico):",
            e
          );
        }

        // 🔴 carrega opções dos lookups (Tipo Pagamento, Caixa, Conta Bancária)
        await this.carregarLookupsDiretos();
        //
      } catch (e) {
        console.error("Erro ao carregar composição:", e);

        // 🔴 ESSENCIAL: logar o que o servidor mandou

        if (e.response) {
          console.error("Status:", e.response.status);
          console.error("Response data:", e.response.data);
        }

        this.$q?.notify?.({
          type: "negative",
          position: "center",
          message: e?.message || "Erro ao carregar composição do modal.",
        });
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>
<style scoped>
/* Altura máxima para o conteúdo, se tiver muitos campos */
.q-card-section {
  max-height: 70vh;
  overflow-y: auto;
}

.leitura-azul .q-field__control {
  background-color: #78b6e2;
}

:deep(.leitura-azul .q-field__control) {
  background-color: #e3f2fd !important; /* azul clarinho */
}
/* se quiser borda em azul mais forte */
:deep(.leitura-azul) .q-field__control:before {
  border-color: #1e88e5;
}
:deep(.leitura-azul .q-field__control:before) {
  border-color: #90caf9 !important;
}
/* reduz o “pé” do q-field quando está em modo leitura-azul */
:deep(.leitura-azul.q-field) {
  padding-bottom: 0 !important;
  margin-bottom: 2px; /* opcional, só pra não grudar demais um no outro */
}

:deep(.leitura-azul .q-field__inner) {
  padding-bottom: 0 !important;
}

:deep(.leitura-azul .q-field__native) {
  padding-top: 2px !important;
  padding-bottom: 6px !important;
  margin-bottom: 2px;
  line-height: 1.2 !important;
  color: #1565c0;
}

:deep(.leitura-azul .q-field__label),
:deep(.q-field.q-field--readonly .q-field__native),
:deep(.q-field.q-field--readonly .q-field__label) {
  color: #1565c0;
}

.top-badge {
  position: relative;
  top: -10px;
  margin-left: -1px;
}
</style>
