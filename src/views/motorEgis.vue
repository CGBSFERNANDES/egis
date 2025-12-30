<template>
  <div class="q-pa-md motor-codex">

    <!-- Barra superior (simples, estilo header) -->
    <div class="row items-center q-mb-lg">
      <div class="row items-center q-gutter-sm">
        <q-icon name="blur_on" size="22px" />
        <div class="text-subtitle1 text-weight-bold">Egis • Motor</div>
      </div>

      <q-space />

      <q-btn flat dense icon="settings" label="Configurações" @click="showConfig = !showConfig" />
      <q-btn flat dense icon="description" label="Documentos" />
      <q-btn round dense icon="account_circle" />
    </div>

    <!-- Título grande central -->
    <div class="text-h4 text-center text-weight-medium q-mb-lg titulo">
      O que vamos fazer a seguir?
    </div>

    <!-- Caixa de prompt (tipo Codex) -->
    <q-card class="prompt-card">
      <q-card-section class="row items-center q-col-gutter-sm">
        <div class="col-auto">
          <q-btn flat round icon="add" @click="abrirMenuAcoes" />
          <q-menu v-model="menuAcoes">
            <q-list style="min-width: 260px;">
              <q-item clickable v-close-popup @click="inserirSugestao('Vendas de Hoje')">
                <q-item-section avatar><q-icon name="shopping_cart" /></q-item-section>
                <q-item-section>Vendas de Hoje</q-item-section>
              </q-item>
              <q-item clickable v-close-popup @click="inserirSugestao('Produto que mais vendeu')">
                <q-item-section avatar><q-icon name="emoji_events" /></q-item-section>
                <q-item-section>Produto que mais vendeu</q-item-section>
              </q-item>
              <q-item clickable v-close-popup @click="inserirSugestao('O vendedor fez pedido ou visita?')">
                <q-item-section avatar><q-icon name="badge" /></q-item-section>
                <q-item-section>Vendedor: pedido ou visita?</q-item-section>
              </q-item>
              <q-separator />
              <q-item clickable v-close-popup @click="resetar">
                <q-item-section avatar><q-icon name="restart_alt" /></q-item-section>
                <q-item-section>Limpar</q-item-section>
              </q-item>
            </q-list>
          </q-menu>
        </div>

        <div class="col">
          <q-input
            dense
            borderless
            v-model="prompt"
            placeholder="O que vamos fazer a seguir?"
            @keyup.enter="enviarPrompt()"
            :disable="loading"
            input-class="prompt-input"
          />
        </div>

        <div class="col-auto row items-center q-gutter-sm">
          <q-btn flat round icon="mic" :disable="loading" @click="notify('Microfone: opcional (não implementado)')" />
          <q-btn
            round
            color="white"
            text-color="black"
            icon="north"
            :loading="loading"
            :disable="loading || !prompt.trim()"
            @click="enviarPrompt()"
          />
        </div>
      </q-card-section>

      <!-- Chips de sugestões -->
      <q-card-section class="q-pt-none">
        <div class="row q-col-gutter-sm items-center">
          <div class="col-12 col-md">
            <div class="row q-gutter-sm">
              <q-chip
                v-for="(s, idx) in sugestoesUsuario"
                :key="idx"
                clickable
                @click="executarSugestao(s)"
                class="chip-sugestao"
                :disable="loading"
              >
                <q-icon :name="s.tp_destino === 'MENU' ? 'menu' : (s.tp_destino === 'PROC' ? 'bolt' : 'widgets')" class="q-mr-xs" />
                  {{ s.ds_titulo || s.label }}
           
              </q-chip>
            </div>
          </div>

          <div class="col-12 col-md-auto text-caption text-grey-5 q-mt-sm q-mt-md-none">
            banco: <b>{{ headerBanco || '-' }}</b> • empresa: <b>{{ cd_empresa }}</b> • usuário: <b>{{ cd_usuario }}</b>
          </div>
        </div>
      </q-card-section>
    </q-card>

    <!-- Configuração rápida (opcional) -->
    <q-slide-transition>
      <div v-show="showConfig" class="q-mt-md">
        <q-card>
          <q-card-section class="row q-col-gutter-md">
            <div class="col-12 col-md-3">
              <q-input dense outlined v-model="headerBanco" label="x-banco" />
            </div>
            <div class="col-12 col-md-3">
              <q-input dense outlined v-model.number="cd_empresa" label="cd_empresa" type="number" />
            </div>
            <div class="col-12 col-md-3">
              <q-input dense outlined v-model.number="cd_usuario" label="cd_usuario" type="number" />
            </div>
            <div class="col-12 col-md-3">
              <q-btn unelevated color="deep-purple-7" class="full-width" label="Salvar no localStorage" @click="salvarLocal()" />
            </div>
          </q-card-section>
        </q-card>
      </div>
    </q-slide-transition>

    <!-- Chat / Histórico -->
    <q-card class="q-mt-md">
      <q-card-section class="row items-center">
        <div class="text-h6">Histórico</div>
        <q-space />
        <q-btn flat dense icon="delete" label="Limpar histórico" @click="limparChat" />
      </q-card-section>

      <q-separator />

      <q-card-section>
        <div v-if="chat.length === 0" class="text-grey-6">
          Escolha uma sugestão acima ou digite um pedido.
        </div>

        <div v-else class="chat">
          <div v-for="(m, i) in chat" :key="i" class="q-mb-md">
            <div class="row items-start q-col-gutter-sm" v-if="m.role === 'user'">
              <div class="col-auto"><q-avatar icon="person" /></div>
              <div class="col">
                <q-card class="msg user">
                  <q-card-section class="q-py-sm">
                    {{ m.text }}
                  </q-card-section>
                </q-card>
              </div>
            </div>

            <div class="row items-start q-col-gutter-sm" v-else>
              <div class="col-auto"><q-avatar icon="smart_toy" /></div>
              <div class="col">
                <q-card class="msg bot">
                  <q-card-section class="q-py-sm">
                    <div v-if="m.status" class="text-caption q-mb-xs">
                      Status: <b>{{ m.status.codigo }}</b> — {{ m.status.mensagem }}
                    </div>

                    <div v-if="m.text" class="q-mb-sm">{{ m.text }}</div>

                    <div v-if="m.previewJson" class="codebox">
                      <pre>{{ m.previewJson }}</pre>
                    </div>
                  </q-card-section>
                </q-card>
              </div>
            </div>
          </div>
        </div>

      </q-card-section>
    </q-card>

    <!-- Resultado tabular -->
    <q-card v-if="rows.length" class="q-mt-md">
      <q-card-section class="row items-center">
        <div class="text-h6">Resultado</div>
        <q-space />
        <q-btn flat dense icon="content_copy" label="Copiar JSON" @click="copiarJson" />
      </q-card-section>
      <q-separator />
      <q-card-section>
        <q-table
          :data="rows"
          :columns="columns"
          row-key="__rowKey"
          dense
          flat
          :pagination.sync="pagination"
          :rows-per-page-options="[10, 20, 50, 0]"
        />
      </q-card-section>
    </q-card>

  </div>
</template>

<script>
import axios from "axios";
import Rota from "../http/rota";
import Router from "../router";
import defaultLayout from "../layouts/side-nav-outer-toolbar";

function addRouteIfMissing(router, route) {
  const exists = (router.options?.routes || []).some(r => r.name === route.name || r.path === route.path);
  if (!exists) router.addRoutes([route]);
  if (router.options?.routes) router.options.routes.push(route);
}

function buildRouteFromDados(dados) {
  const name = String(dados.cd_menu);
  const path = `/menu/${name}`;

  const comp = (folder) => () => import(`@/${folder}/${dados.nm_caminho_componente}`);

  let content;
  if (dados.nm_local_componente === "Financeiro") content = comp("Financeiro");
  else if (dados.nm_local_componente === "Compras") content = comp("Compras");
  else if (dados.nm_local_componente === "gestaoFood") content = comp("gestaoFood");
  else content = comp("views");

  return {
    name,
    path,
    meta: { requiresAuth: true },
    components: { layout: defaultLayout, content }
  };
}


//const api = axios.create({ baseURL: process.env.API_URL || "" });

const api = axios.create({
  baseURL: "https://egiserp.com.br/api",
  withCredentials: true,
  timeout: 60000,
});


api.interceptors.request.use((cfg) => {
  const banco = localStorage.nm_banco_empresa || "";
  if (banco) cfg.headers["x-banco"] = banco;

  // Mantém igual seus componentes atuais:
  cfg.headers["Authorization"] = "Bearer superchave123";
  if (!cfg.headers["Content-Type"]) cfg.headers["Content-Type"] = "application/json";
  return cfg;
});


const PARAM_TODAS = 10;
const PARAM_TOP_USUARIO = 50;
const PARAM_LOG_USO = 60; // se você tiver implementado; se não, deixe e o método ignora

export default {
  name: "motorEgis",

  data() {

    return {
      // contexto
      headerBanco: localStorage.nm_banco_empresa || "",
      cd_empresa: Number(localStorage.cd_empresa || 0),
      cd_usuario: Number(localStorage.cd_usuario || 0),

      // UI
      loading: false,
      loadingBusca: false,
      showConfig: false,
      menuAcoes: false,

      // prompt/busca
      prompt: "",
      tmrBusca: null,
      sugestoesMenus: [],   // dropdown do search

      // sugestões
      sugestoesUsuario: [], // param=50
      sugestoesTodas: [],   // param=10 (opcional para tela “ver todas”)

      // chat e resultado
      chat: [],
      rows: [],
      columns: [],
      pagination: { rowsPerPage: 20 },
  
      // Sugestões (você “pluga” a procedure/param aqui)
      sugestoesRapidas: [
        {
          key: "vendas_hoje",
          label: "Vendas de Hoje",
          icon: "shopping_cart",
          action: { proc: "pr_egis_motor_processo_modulo", cd_parametro: 101 } // <-- TROCAR p/ seu código real
        },
        {
          key: "produto_campeao",
          label: "Produto que mais vendeu",
          icon: "emoji_events",
          action: { proc: "pr_egis_motor_processo_modulo", cd_parametro: 102 } // <-- TROCAR
        },
        {
          key: "pedido_ou_visita",
          label: "Pedido ou visita do vendedor",
          icon: "badge",
          action: { proc: "pr_egis_motor_processo_modulo", cd_parametro: 103 } // <-- TROCAR
        }
      ],
    };
  },

  mounted() {
    this.carregarSugestoesUsuario();
  },

  watch: {
    prompt(val) {
      clearTimeout(this.tmrBusca);
      const v = (val || "").trim();
      if (v.length < 3) {
        this.sugestoesMenus = [];
        return;
      }
     //this.tmrBusca = setTimeout(() => this.buscarSugestoes(v), 350);
     this.tmrBusca = setTimeout(() => this.buscarSugestoesPorTexto(v), 350);
    }
  },

  methods: {
  
    abrirMenuAcoes() { this.menuAcoes = true; },

    destinoDe(tp) {
       const n = Number(tp);
       if (n === 1) return "MENU";
       if (n === 2) return "PROC";
       if (n === 3) return "COMPONENTE";
       return "MENU";
   },


    // ------------------------------
  // 1) BUSCA GENÉRICA NA SP
  // ------------------------------
  async fetchSugestoes({ cd_parametro, ds_prompt }) {
    const body = [{
      ic_json_parametro: "S",
      cd_parametro,
      cd_empresa: this.cd_empresa,
      cd_usuario: this.cd_usuario,
      ds_prompt: ds_prompt || undefined,
    }];

    const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;
    const resp = await api.post("/exec/pr_egis_motor_processo_modulo", body, cfg);

    const { rows, status } = this.normalizarResposta(resp?.data);
    if (status && status.sucesso === false) return { rows: [], status };
    return { rows: Array.isArray(rows) ? rows : [], status };
  },

  // ------------------------------
  // 2) CARREGA TOP DO USUÁRIO (50) + FALLBACK (10)
  // ------------------------------
  async carregarSugestoesUsuario() {
  const top = await this.fetchSugestoes({ cd_parametro: 50 });

  // Se param=50 vier “resumido” (só nomes), normaliza via param=10
  if (top.rows?.length) {
    // tenta resolver cada nm_sugestao no catálogo do param=10
    const cat = await this.fetchSugestoes({ cd_parametro: 10 });
    const mapa = new Map((cat.rows || []).map(x => [String(x.nm_sugestao).toLowerCase(), x]));

    this.sugestoesUsuario = top.rows
      .map(r => mapa.get(String(r.nm_sugestao || "").toLowerCase()) || r)
      .filter(Boolean)
      .slice(0, 8);

    return;
  }

  // fallback catálogo
  const all = await this.fetchSugestoes({ cd_parametro: 10 });
  this.sugestoesUsuario = (all.rows || []).slice(0, 8);
},

  // ------------------------------
  // 3) SEARCH NO PROMPT (sugestões em dropdown)
  // ------------------------------

  async buscarSugestoesPorTexto(texto) {
    const out = await this.fetchSugestoes({ cd_parametro: 10, ds_prompt: texto });
    this.sugestoesMenus = (out.rows || []).slice(0, 12);
  },

  async buscarSugestoesPorTextoOld(texto) {
    this.loadingBusca = true;
    try {
      // aqui a ideia é: param=10 com ds_prompt filtrando no SQL
      const out = await this.fetchSugestoes({ cd_parametro: PARAM_TODAS, ds_prompt: texto });
      this.sugestoesMenus = (out.rows || []).slice(0, 12);
    } finally {
      this.loadingBusca = false;
    }
  },

  // ------------------------------
  // 4) EXECUÇÃO ÚNICA (MENU / PROC / COMPONENTE)
  // ------------------------------
  async executarSugestao(item) {
    if (!item) return;

    const titulo = item.ds_titulo || item.label || item.nm_menu || item.nm_rota || "Ação";
    this.pushUser(titulo);

    this.loading = true;
    this.rows = [];
    this.columns = [];

    let sucesso = true;
    let erroMsg = "";

    try {
      const tp = String(item.tp_destino || "").toUpperCase();

      if (tp === "MENU") {
        await this.abrirMenu(item);
        this.pushBot({ text: "Abrindo menu...", status: { sucesso: true, codigo: 200, mensagem: "OK" } });
      } else if (tp === "COMPONENTE") {
        const rota = item.nm_rota || item.path;
        if (!rota) throw new Error("Sugestão sem rota (nm_rota/path).");
        await this.$router.push(rota).catch(err => err);
        this.pushBot({ text: "Abrindo tela...", status: { sucesso: true, codigo: 200, mensagem: "OK" } });
      } else if (tp === "PROC") {
        await this.executarProcesso(item);
      } else {
        // fallback: tenta rota, senão processo
        if (item.nm_rota || item.path) await this.abrirMenu(item);
        else if (item.nm_procedure) await this.executarProcesso(item);
        else throw new Error("Sugestão sem destino configurado (tp_destino).");
      }

    } catch (e) {
      sucesso = false;
      erroMsg = e?.message || "Erro ao executar";
      this.pushBot({
        text: "Falha ao executar.",
        status: { sucesso: false, codigo: 500, mensagem: erroMsg }
      });
    } finally {
      this.loading = false;
      this.prompt = "";
      this.sugestoesMenus = [];
      await this.registrarUso(item, { sucesso, erroMsg });
    }
  },

  // ------------------------------
  // 5) MENU DINÂMICO (igual side-nav-menu.vue)
  // ------------------------------

  async abrirMenu(item) {
  const cd_rota = item.cd_rota;
  if (!cd_rota) throw new Error("Sugestão MENU sem cd_rota.");

  // você cria esse método no mesmo serviço que já tem:
  const dados = await Rota.apiMenuByRota(cd_rota); // <- implementar no seu http/rota
  if (!dados) throw new Error("apiMenuByRota não retornou dados.");

  // montar rota dinâmica igual side-nav
  const routeDef = buildRouteFromDados(dados);
  addRouteIfMissing(Router, routeDef);
  await this.$router.push({ name: routeDef.name }).catch(err => err);
},



  async abrirMenuOLD(item) {
    const path = item.nm_rota || item.path;
    if (!path) throw new Error("Sugestão MENU sem nm_rota/path.");

    const dados = await Rota.apiMenu(path);
    if (!dados) throw new Error("apiMenu não retornou dados para a rota.");

    localStorage.cd_menu = dados.cd_menu;
    localStorage.nm_identificacao_api = dados.nm_identificacao_api || "";
    localStorage.cd_api = dados.cd_api || 0;

    const routeDef = buildRouteFromDados(dados);

    addRouteIfMissing(Router, routeDef);

    await this.$router.push({ name: routeDef.name }).catch(err => err);

  },

  // ------------------------------
  // 6) EXECUTA PROCEDURE (PROC)
  // ------------------------------
  async executarProcesso(item) {
    const proc = item.nm_procedure || item.proc;
    if (!proc) throw new Error("Sugestão PROC sem nm_procedure.");

    const cdParam =
      item.cd_parametro_exec ??
      item.cd_parametro_processo ??
      item.cd_parametro ??
      (item.action && item.action.cd_parametro);

    const body = [{
      ic_json_parametro: "S",
      cd_parametro: cdParam,
      cd_empresa: this.cd_empresa,
      cd_usuario: this.cd_usuario,
      cd_sugestao: item.cd_sugestao,
    }];

    const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;
    const resp = await api.post(`/exec/${proc}`, body, cfg);

    const { rows, status } = this.normalizarResposta(resp?.data);
    this.rows = rows || [];
    this.columns = this.montarColunas(this.rows);

    this.pushBot({
      text: this.rows.length ? "Aqui está o resultado:" : "Executado. Nenhuma linha retornada.",
      status,
      data: this.rows.length ? this.rows : status
    });
  },

  // ------------------------------
  // 7) LOG DE USO (se você implementou param=60)
  // ------------------------------
  async registrarUso(item, { sucesso, erroMsg } = {}) {
    // se não existir no banco, pode comentar este método inteiro
    try {
      const body = [{
        ic_json_parametro: "S",
        cd_parametro: PARAM_LOG_USO,
        cd_empresa: this.cd_empresa,
        cd_usuario: this.cd_usuario,
        cd_sugestao: item?.cd_sugestao,
        tp_destino: item?.tp_destino,
        ic_sucesso: sucesso ? "S" : "N",
        ds_erro: erroMsg || undefined,
      }];

      const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;
      await api.post("/exec/pr_egis_motor_processo_modulo", body, cfg);
    } catch (e) {
      // não quebra UX se log falhar
    }
  },


    async carregarSugestoesUsuarioOLD() {
     const ok = await this.buscarSugestoes(50);
     if (!ok) {
       await this.buscarSugestoes(10);
     }
   },

   async executarSugestao(item) {
    try {
        if (item.tp_destino === "MENU") {
        await this.abrirMenu(item);
        }
        else if (item.tp_destino === "COMPONENTE") {
        this.$router.push(item.nm_rota);
        }
        else if (item.tp_destino === "PROC") {
        await this.executarProcesso(item);
        }

        this.registrarUso(item, true);

    } catch (e) {
        this.registrarUso(item, false, e.message);
    }
    },


    async openMenuSuggestion(item) {
  // item.path precisa existir
  if (!item?.path) return;

  const dados = await Rota.apiMenu(item.path);
  if (!dados) return;

  // contexto padrão (igual side-nav)
  localStorage.cd_menu = dados.cd_menu;
  localStorage.nm_identificacao_api = dados.nm_identificacao_api || "";
  localStorage.cd_api = dados.cd_api || 0;

  const routeDef = buildRouteFromDados(dados);
  addRouteIfMissing(Router, routeDef);

  this.$router.push({ name: routeDef.name }).catch(err => err);
},

    async buscarSugestoes(texto) {
     this.loadingBusca = true;
     try {
      const body = [{
      ic_json_parametro: "S",
      cd_parametro: 1,
      cd_empresa: this.cd_empresa,
      cd_usuario: this.cd_usuario,
      ds_prompt: texto
    }];

    const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;
    const resp = await api.post("/exec/pr_egis_motor_processo_modulo", body, cfg);

    const { rows, status } = this.normalizarResposta(resp?.data);
    if (!status?.sucesso) {
      this.sugestoesMenus = [];
      return;
    }

    // rows aqui são opções de menu/proc/component
    this.sugestoesMenus = Array.isArray(rows) ? rows : [];

  } finally {
    this.loadingBusca = false;
  }
},

    inserirSugestao(txt) {
      this.prompt = txt;
      this.$nextTick(() => this.enviarPrompt());
    },

    executarSugestao(s) {
      this.prompt = s.label;
      this.enviarPrompt(s.action);
    },

    salvarLocal() {
      localStorage.nm_banco_empresa = this.headerBanco || "";
      localStorage.cd_empresa = String(this.cd_empresa || 0);
      localStorage.cd_usuario = String(this.cd_usuario || 0);
      this.notify("Configuração salva.");
    },

    resetar() {
      this.prompt = "";
      this.rows = [];
      this.columns = [];
    },

    limparChat() {
      this.chat = [];
      this.resetar();
    },

    notify(msg) {
      if (this.$q && this.$q.notify) this.$q.notify({ type: "info", message: msg });
    },

    pushUser(text) {
      this.chat.push({ role: "user", text });
    },

    pushBot({ text, status, data }) {
      const previewJson = data ? JSON.stringify(data, null, 2).slice(0, 1200) : "";
      this.chat.push({
        role: "bot",
        text,
        status,
        previewJson: previewJson ? previewJson + (JSON.stringify(data).length > 1200 ? "\n... (cortado)" : "") : ""
      });
    },

    // Heurística simples para transformar texto em “intenção”
    // (Depois a gente deixa isso 100% alinhado ao teu Word/Excel)
    identificarAcaoPorTexto(texto) {
      const t = (texto || "").toLowerCase();

      if (t.includes("vendas") && t.includes("hoje")) return { proc: "pr_egis_motor_processo_modulo", cd_parametro: 101 };
      if (t.includes("produto") && (t.includes("mais") || t.includes("campe"))) return { proc: "pr_egis_motor_processo_modulo", cd_parametro: 102 };
      if (t.includes("vendedor") || t.includes("pedido") || t.includes("visita")) return { proc: "pr_egis_motor_processo_modulo", cd_parametro: 103 };

      // fallback (padrão de teste)
      return { proc: "pr_egis_motor_processo_modulo", cd_parametro: 9999 };
      //

    },

    async enviarPrompt(acaoForcada) {
      const texto = (this.prompt || "").trim();
      if (!texto) return;

      this.pushUser(texto);
      this.loading = true;
      this.rows = [];
      this.columns = [];

      try {
        const acao = acaoForcada || this.identificarAcaoPorTexto(texto);

        // Corpo padrão igual seus componentes: array com 1 objeto

        const body = [
          {
            ic_json_parametro: "S",
            cd_parametro: acao.cd_parametro,
            cd_empresa: this.cd_empresa,
            cd_usuario: this.cd_usuario,

            // opcional: enviar o prompt para o back-end “entender”
            ds_prompt: texto,
          },

        ];

        const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;


        console.log('procedure',`/exec/${acao.proc}`, body, cfg)
        const resp = await api.post(`/exec/${acao.proc}`, body, cfg);
        const { rows, status } = this.normalizarResposta(resp && resp.data ? resp.data : []);

        this.rows = rows;

        console.log(this.rows);

        this.columns = this.montarColunas(rows);

        this.pushBot({
          text: rows.length ? "Aqui está o resultado:" : "Executado. Nenhuma linha retornada.",
          status,
          data: rows.length ? rows : status
        });

      } catch (e) {
        this.pushBot({
          text: "Falha ao executar.",
          status: { sucesso: false, codigo: 500, mensagem: (e && e.message) ? e.message : "Erro desconhecido" }
        });
      } finally {
        this.loading = false;
        this.prompt = "";
      }
    },

    montarColunas(rows) {
      if (!rows || !rows.length) return [];
      const keys = Object.keys(rows[0] || {});
      return keys.map((k) => ({
        name: k,
        label: this.tituloColuna(k),
        field: k,
        align: "left",
        sortable: true,
      }));
    },

    tituloColuna(chave) {
      return String(chave || "")
        .replace(/_/g, " ")
        .replace(/\s+/g, " ")
        .trim()
        .replace(/\b\w/g, (l) => l.toUpperCase());
    },

    // Normaliza retorno (suporta: array, array de resultsets, status no final, etc.)
    normalizarResposta(data) {
      let payload = data;
      if (payload && payload.dados) payload = payload.dados;

      let status = null;

      // caso: [ [rs1], [status] ]
      if (Array.isArray(payload) && payload.length && Array.isArray(payload[payload.length - 1])) {
        const ultimo = payload[payload.length - 1];
        const s = ultimo && ultimo[0];

        if (s && Object.prototype.hasOwnProperty.call(s, "sucesso")) {
          status = { sucesso: !!s.sucesso, codigo: s.codigo, mensagem: s.mensagem };
        }

        const dados = payload.slice(0, -1).flat();
        const rows = (Array.isArray(dados) ? dados : []).map((r, idx) => ({ __rowKey: idx + 1, ...r }));
        return { rows, status: status || { sucesso: true, codigo: 200, mensagem: "OK" } };

      }

      // caso: [ rows..., status ]
      if (Array.isArray(payload)) {
        const last = payload[payload.length - 1];
        if (last && Object.prototype.hasOwnProperty.call(last, "sucesso")) {
          status = { sucesso: !!last.sucesso, codigo: last.codigo, mensagem: last.mensagem };
          payload = payload.slice(0, -1);
        }
        const rows = payload.map((r, idx) => ({ __rowKey: idx + 1, ...r }));
        return { rows, status: status || { sucesso: true, codigo: 200, mensagem: "OK" } };
      }

      // caso: objeto status
      if (payload && typeof payload === "object" && Object.prototype.hasOwnProperty.call(payload, "sucesso")) {
        status = { sucesso: !!payload.sucesso, codigo: payload.codigo, mensagem: payload.mensagem };
        return { rows: [], status };
      }

      return { rows: [], status: { sucesso: true, codigo: 200, mensagem: "OK" } };
    },

    copiarJson() {
      try {
        const txt = JSON.stringify(this.rows || [], null, 2);
        if (navigator?.clipboard?.writeText) navigator.clipboard.writeText(txt);
        if (this.$q?.notify) this.$q.notify({ type: "positive", message: "JSON copiado!" });
      } catch (e) {
        if (this.$q?.notify) this.$q.notify({ type: "negative", message: "Não foi possível copiar." });
      }
    },
  },
};
</script>

<style scoped>
.motor-codex { min-height: 100%; }
.titulo { opacity: 0.95; }

.prompt-card {
  border-radius: 22px;
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.06);
}

.prompt-input {
  font-size: 16px;
  padding: 8px 0;
}

.chip-sugestao {
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.07);
}

.chat .msg {
  border-radius: 14px;
}

.chat .msg.user {
  background: rgba(255,255,255,0.05);
}

.chat .msg.bot {
  background: rgba(103,58,183,0.10);
  border: 1px solid rgba(103,58,183,0.22);
}

.codebox {
  background: rgba(0,0,0,0.35);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 12px;
  padding: 10px;
  overflow: auto;
}
.codebox pre {
  margin: 0;
  font-size: 12px;
  white-space: pre-wrap;
  word-break: break-word;
}
</style>
