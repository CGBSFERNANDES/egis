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
      <q-btn flat dense icon="arrow_back" label="Voltar ao Motor" @click="voltarMotor" />

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
            placeholder="Digite aqui ... "
            @keyup.enter="confirmarPrompt()"
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
            :disable="loading || !((prompt || '').trim())"
            @click="enviarPrompt()"
          />
        </div>
      </q-card-section>

      <!-- Chips de sugestões -->
      <q-card-section class="q-pt-none">
        <div class="row q-col-gutter-sm items-center">
          <div class="col-12 col-md">

            <!-- PESQUISA: mostra Menus do ERP + Sugestões do Motor -->

            <div v-if="(prompt || '').trim().length >= 3">

             <div class="text-caption q-mt-sm">Menus do ERP</div>

                <div v-for="m in sugestoesMenus" :key="'m'+(m.cd_menu||m.cd_rota||m.nm_rota)">
                  <q-btn flat dense align="left" @click="abrirMenu(m)">
                    {{ m.nm_menu_titulo || m.nm_menu || m.nm_sugestao }}
                  </q-btn>
                </div>


              <div class="text-caption text-grey-6 q-mb-xs">Sugestões do Motor</div>

              <div class="row q-gutter-sm">
                <div v-for="s in sugestoesMotor" :key="'s'+(s.cd_sugestao||s.nm_sugestao)">
  <q-btn flat dense align="left" @click="executarSugestao(s)">
    {{ s.nm_sugestao }}
  </q-btn>
</div>
              </div>
            </div>

            <!-- SEM PESQUISA: Top do usuário (param=50) -->
            <div v-else class="row q-gutter-sm">
              <q-chip
                v-for="(s, idx) in sugestoesUsuario"
                :key="'user-' + idx"
                clickable
                @click="executarSugestao(normalizarItemMotor(s))"
                class="chip-sugestao"
                :disable="loading"
              >
                <q-icon :name="iconeDestino(s.tp_destino)" class="q-mr-xs" />
                {{ s.nm_sugestao || s.label }}
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
  try {
    // Se já existe rota com esse path, não adiciona de novo
    const matched = router.match(route.path);
    if (matched && matched.matched && matched.matched.length) return;

    router.addRoutes([route]);

    // mantém compatibilidade com seu push em options.routes, mas sem duplicar

    if (router.options && Array.isArray(router.options.routes)) {
      const exists = router.options.routes.some(r => r.path === route.path || r.name === route.name);
      if (!exists) router.options.routes.push(route);
    }

  } catch (e) {
    // fallback: se algo der errado, não derruba
    console.warn("addRouteIfMissing warn:", e);
  }
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


const PARAM_MENU_SEARCH = 1;   // busca menus por texto (faturamento -> 28)
const PARAM_TODAS = 10;        // catálogo de sugestões do motor
const PARAM_TOP_USUARIO = 50;  // top do usuário
const PARAM_LOG_USO = 60;      // opcional (se existir no seu SP)

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
      sugestoesMenusERP: [],   // param=1 (menus do ERP)
      sugestoesMenusMotor: [], // param=10 (catálogo do motor)

      sugestoesMenus: [],
      sugestoesMotor: [],
      
      // sugestões iniciais (param=50)
      sugestoesUsuario: [],

      // chat e resultado
      chat: [],
      rows: [],
      columns: [],
      pagination: { rowsPerPage: 20 },
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
        this.sugestoesMenusERP = [];
        this.sugestoesMenusMotor = [];
        this.sugestoesMenus = [];
        this.sugestoesMotor = [];
        return;
      }
      this.tmrBusca = setTimeout(() => this.buscarSugestoes(v), 350);
    }
  },

  methods: {
  
    voltarMotor() {
      const to = window.localStorage.getItem("egis_motor_return") || "/"; // ou a rota do motor
      this.$router.push(to).catch(err => err);
    },

    abrirMenuAcoes() { this.menuAcoes = true; },

    //
    
    async abrirMenuComoSideNav(item) {
  try {
    console.log("abrir menu ->", item);

    // Salva retorno para voltar ao Motor (opcional)
    // (não use localStorage no template; use method voltarMotor)
    window.localStorage.setItem(
      "egis_motor_return",
      (this.$route && this.$route.fullPath) ? this.$route.fullPath : "/"
    );

    // ---- helpers ----
    const pickStr = (v) => {
      if (Array.isArray(v)) return String(v.find(x => x) || "").trim();
      return String(v || "").trim();
    };

    const pickNum = (v) => {
      const s = pickStr(v);
      const n = Number(s);
      return Number.isFinite(n) ? n : 0;
    };

    const routeExists = (router, routeName) => {
      try {
        return (router?.options?.routes || []).some(r => r.name === routeName);
      } catch (e) {}
      return false;
    };

    // ---- dados vindos do ITEM (sem apiMenu) ----
    const cd_menu = pickNum(item.cd_menu || item.cd_item_menu);
    if (!cd_menu) {
      console.warn("Item sem cd_menu:", item);
      return;
    }

    // path/rota "real" (igual side-nav: e.itemData.path)
    // NÃO usar nm_identificacao_rota aqui
    const path =
      pickStr(item.nm_identificacao_rota) ||
      pickStr(item.nm_rota_menu) ||
      pickStr(item.nm_rota) ||
      pickStr(item.nm_executavel) ||
      pickStr(item.nm_form_menu);

    if (!path) {
      console.warn("Sugestão sem path (nm_rota/nm_rota_menu):", item);
      return;
    }

    // componente
    const nm_local_componente = pickStr(item.nm_local_componente); // Financeiro/Compras/gestaoFood/""(views)
    const nm_caminho_componente_raw = item.nm_caminho_componente;
    const nm_caminho_componente = Array.isArray(nm_caminho_componente_raw)
      ? pickStr(nm_caminho_componente_raw)
      : pickStr(nm_caminho_componente_raw);

    if (!nm_caminho_componente) {
      console.warn("Item sem nm_caminho_componente:", item);
      return;
    }

    // ---- localStorage igual side-nav ----
    localStorage.cd_tipo_consulta = 0;

    localStorage.cd_menu = 0;
    localStorage.nm_identificacao_api = "";
    localStorage.cd_api = 0;

    localStorage.cd_menu = cd_menu;
    localStorage.nm_identificacao_api = pickStr(item.nm_identificacao_api);
    localStorage.cd_api = pickNum(item.cd_api);
    localStorage.nm_menu_titulo = pickStr(item.nm_menu_titulo || item.nm_menu);

    // (mantém seu alerta se quiser)
    //if (localStorage.cd_api == 0) {
      // alert("Falta configuração da API: " + localStorage.cd_api);
    //}

    // ---- adiciona rota dinâmica igual side-nav ----
    const name = String(cd_menu);

    // Define base de import conforme módulo
    let importBase = "@/views/";

    if (nm_local_componente === "Financeiro") importBase = "@/Financeiro/";
    else if (nm_local_componente === "Compras") importBase = "@/Compras/";
    else if (nm_local_componente === "gestaoFood") importBase = "@/gestaoFood/";

    // normaliza caminho vindo do banco (ex: "../views/unicoFormEspecial" -> "unicoFormEspecial")
    const compLimpo = String(nm_caminho_componente)
      .replace(/\.vue$/i, "")
      .replace(/^(\.\.\/)+/g, "")   // remove ../
      .replace(/^@\/+/g, "")        // remove @/
      .replace(/^views\//, "")      // remove "views/"
      .replace(/^\/+/, "");         // remove "/"

    if (!routeExists(this.$router, name)) {
      console.log("Adicionando rota genérica para menu", name, cd_menu, importBase + compLimpo);

      Router.addRoutes([
        {
          path: "/",                // <= igual side-nav
          name: `${cd_menu}`,       // <= cd_menu
          meta: { requiresAuth: true },
          components: {
            layout: defaultLayout,
            content: () =>
              import(
                /* webpackChunkName: "display-data" */ `${importBase}${compLimpo}`
              ),
          },
        },
      ]);
    }

    // ---- polling igual side-nav ----
    if (localStorage.polling == 1) {
      clearInterval(localStorage.polling);
      localStorage.polling = 0;
    }

    // ---- ativa rota igual side-nav (name: path) ----
    this.path = path;
    console.log('path',path)
    this.$router
      .push({
        path: "/",
        name: cd_menu, //path,     // <= IGUAL seu handleItemClick: name: e.itemData.path
        key: cd_menu,
      })
      .catch((err) => err);

  } catch (e) {
    console.error("abrirMenuComoSideNav erro:", e);
  }
},

   //

    async abrirMenu(item) {

      const nm_rota = item.nm_identificacao_rota || item.nm_rota || item.nm_rota_menu;
   
      console.log('dados do menu ', nm_rota);

      if (!nm_rota) throw new Error("Menu sem nm_rota/nm_rota_menu.");

      const dados = await Rota.apiMenu(nm_rota);
      if (!dados) throw new Error("apiMenu não retornou dados.");

  // se você já tem buildRouteFromDados/addRouteIfMissing no arquivo, usa eles
  const routeDef = buildRouteFromDados(dados);
  addRouteIfMissing(Router, routeDef);

  await this.$router.push({ name: routeDef.name }).catch(err => err);

},


confirmarPrompt() {

  // Enter NÃO deve disparar execução do processo.
  // Se já existem sugestões listadas, só orienta o usuário a clicar nelas.
  const total =
    (this.sugestoesMenus ? this.sugestoesMenus.length : 0) +
    (this.sugestoesMotor ? this.sugestoesMotor.length : 0);

  if (total > 0) {
    if (this.pushBot) {
      this.pushBot({
        text: `Encontrei ${total} sugestão(ões). Clique em uma delas acima para executar.`,
        status: { sucesso: true, codigo: 200, mensagem: "OK" }
      });
    }
    return;
  }

  // Se não tem sugestões, força uma busca pelo texto
  const v = (this.prompt || "").trim();

  if (v.length >= 3) {
    this.buscarSugestoes(v);
  }
},

async carregarSugestoesUsuario() {
  try {
    // carrega top do usuário (param=50) sem passar por buscarSugestoes(texto)
    const out = await this.execMotor(50, null);
    this.sugestoesUsuario = Array.isArray(out?.rows) ? out.rows : [];

    // fallback: se vazio, pega catálogo (param=10)
    if (!this.sugestoesUsuario.length) {
      const all = await this.execMotor(10, null);
      this.sugestoesUsuario = Array.isArray(all?.rows) ? all.rows.slice(0, 8) : [];
    }
  } catch (e) {
    this.sugestoesUsuario = [];
  }
},

async executarSugestao(item) {
  try {
    const destino = this.destinoDe(item.tp_destino); // 1/2/3 -> MENU/PROC/COMPONENTE

    if (destino === "MENU") {
      //await this.abrirMenu(item);
      await this.abrirMenuComoSideNav(item);

    } else if (destino === "COMPONENTE") {
      if (item.nm_rota) this.$router.push(item.nm_rota);
    } else if (destino === "PROC") {
      await this.executarProcesso(item); // se você já tem essa função
    }

    // se existir registrarUso, ok; se não, remova a linha abaixo
    if (this.registrarUso) this.registrarUso(item, true);

  } catch (e) {
    if (this.registrarUso) this.registrarUso(item, false, e.message);
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

//

async buscarSugestoes(texto) {

  this.sugestoesMenus = [];
  this.sugestoesMotor = [];

  try {
    // garante arrays limpos sempre (evita duplicação)
    if (this.sugestoesMenus) this.sugestoesMenus = [];
    if (this.sugestoesMotor) this.sugestoesMotor = [];

       // normaliza qualquer tipo (number/object/event) para string
    let v = "";
    
    if (typeof texto === "string") v = texto;
    else if (typeof texto === "number") v = String(texto);
    else if (texto && typeof texto === "object") {
      // caso venha evento do input, ou objeto {target:{value}}
      if (texto.target && typeof texto.target.value === "string") v = texto.target.value;
      else if (typeof texto.value === "string") v = texto.value;
      else v = "";
    }

    v = v.trim();

    if (v.length < 3) {
      this.sugestoesMenus = [];
      this.sugestoesMotor = [];
      return;
    }


    // 1) MENUS DO ERP (param=1)
    const r1 = await this.execMotor(1, v);       // <-- usa seu executor
    const menus = (r1 && r1.rows) ? r1.rows : [];

    // 2) SUGESTÕES DO MOTOR (param=10)
    const r10 = await this.execMotor(10, v);     // <-- usa seu executor
    const motor = (r10 && r10.rows) ? r10.rows : [];

    // Dedup por chave forte

    const dedupe = (rows) => {
      const seen = new Set();
      return (rows || []).filter(r => {
        const key =
          r.cd_sugestao ??
          (r.nm_rota || r.nm_rota_menu) ??
          (r.cd_menu ? `m:${r.cd_menu}` : null) ??
          (r.cd_rota ? `r:${r.cd_rota}` : null) ??
          r.nm_sugestao ??
          r.nm_menu;

        const k = String(key || "").toLowerCase().trim();

        if (!k) return true;
        if (seen.has(k)) return false;
        seen.add(k);
        return true;

      });

    };

    // popula as listas que a tela renderiza
    this.sugestoesMenus = dedupe(menus).slice(0, 20);
    this.sugestoesMotor = dedupe(motor).slice(0, 20);

  } catch (e) {
    console.log("buscarSugestoes erro:", e);
  }
},

async execMotor(cd_parametro, ds_prompt) {

  const body = [{
    ic_json_parametro: "S",
    cd_parametro,
    cd_empresa: this.cd_empresa,
    cd_usuario: this.cd_usuario,
    ds_prompt: ds_prompt || undefined
  }];

  const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;

  console.log('dados de execução-->', cfg, body, cd_parametro, ds_prompt);


   // IMPORTANTE: use o cliente que EXISTE no seu projeto.
  // Opção A: se você tem "api" (axios.create) no arquivo, use "api.post"
  if (typeof api !== "undefined" && api && api.post) {
    const resp = await api.post("/exec/pr_egis_motor_processo_modulo", body, cfg);
    return this.normalizarResposta(resp?.data);
  }

  throw new Error("Cliente api não disponível.");

  // usa o MESMO axios/api que você já usa no componente
  //const resp = await this.api.post("/exec/pr_egis_motor_processo_modulo", body, cfg);

  // normaliza no formato {rows, status}
  //const out = this.normalizarResposta(resp && resp.data ? resp.data : []);
  //

  //console.log('dados do banco-->', out);


  //return out;
},

    dedupeSugestoes(rows) {
  const seen = new Set();
  return (rows || []).filter(r => {
    const key =
      r.cd_sugestao ??
      (r.nm_rota || r.nm_rota_menu) ??
      (r.cd_menu ? `m:${r.cd_menu}` : null) ??
      (r.cd_rota ? `r:${r.cd_rota}` : null) ??
      r.nm_sugestao ??
      r.nm_menu;

    console.log('key', key);

    const k = String(key || "").toLowerCase().trim();

    
    if (!k) return true;
    if (seen.has(k)) return false;
    seen.add(k);
    return true;
  });
},


    inserirSugestao(txt) {
      this.prompt = txt;
      this.$nextTick(() => this.enviarPrompt());
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

    destinoDe(tp) {
      const n = Number(tp);
      if (n === 1) return "MENU";
      if (n === 2) return "PROC";
      if (n === 3) return "COMPONENTE";
      return "MENU";
    },

    iconeDestino(tp_destino) {
      const d = this.destinoDe(tp_destino);
      if (d === "MENU") return "menu";
      if (d === "PROC") return "bolt";
      if (d === "COMPONENTE") return "widgets";
      return "menu";
    },

    normalizarItemMotor(s) {
      return { ...s, tp_destino: this.destinoDe(s.tp_destino) };
    },

    normalizarItemERP(s) {
      return {
        ...s,
        tp_destino: "MENU",
        nm_rota: s.nm_rota || s.nm_rota_menu || s.nm_executavel || s.nm_form_menu,
      };
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
    //

      let payload = data;
      
      if (payload && payload.dados) payload = payload.dados;

      let status = null;

      console.log('payload-->', payload);

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
