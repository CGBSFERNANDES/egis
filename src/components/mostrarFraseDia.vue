<template>
  <div class="q-pa-md">
    <!-- Topo: seta voltar + atualizar -->
    <div class="row items-center q-mb-md">
      <h2 class="content-block col-12 row items-center no-wrap toolbar-scroll">
        <q-btn
          flat
          round
          dense
          icon="arrow_back"
          class="q-mr-sm seta-form"
          aria-label="Voltar"
          @click="onVoltar"
        />
        <span>Frase do Dia</span>

        <q-space />

        <q-btn
          dense
          rounded
          icon="refresh"
          color="deep-purple-7"
          size="lg"
          class="q-ml-sm"
          @click="carregarFrases(true)"
          :loading="loading"
          :disable="loading"
        >
          <q-tooltip>Atualizar</q-tooltip>
        </q-btn>
      </h2>
    </div>

    <!-- Pesquisa local + pesquisa internet -->
    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-12 col-md-7">
        <q-input
          dense
          outlined
          v-model="filtro"
          placeholder="Buscar frase, autor, tema..."
          clearable
          @keyup.enter="onPesquisarInternet"
        >
          <template v-slot:prepend>
            <q-icon name="search" />
          </template>
          <template v-slot:append>
            <q-btn
              flat
              dense
              icon="search"
              @click="onPesquisarInternet"
              :disable="!(filtro && filtro.trim())"
              title="Pesquisar na internet (abre em nova aba)"
            />
          </template>
        </q-input>

        <div class="text-caption text-grey-7 q-mt-xs">
          Dica: digite algo e aperte Enter para pesquisar na internet.
        </div>
      </div>

      <div class="col-12 col-md-5">
        <q-banner dense class="bg-grey-2 text-grey-9 rounded-borders">
          <div class="text-caption">
            Usuário: <b>{{ cd_usuario }}</b>
            <span class="q-ml-sm">| Frases: <b>{{ frases.length }}</b></span>
          </div>
        </q-banner>
      </div>
    </div>

    <q-inner-loading :showing="loading">
      <q-spinner size="50px" />
    </q-inner-loading>

    <div v-if="!loading && frasesFiltradas.length === 0" class="q-mt-md">
      <q-banner class="bg-orange-1 text-orange-10 rounded-borders">
        Nenhuma frase encontrada.
      </q-banner>
    </div>

    <!-- Lista de frases -->
    <div class="row q-col-gutter-md q-mt-sm">
      <div
        v-for="(f, idx) in frasesFiltradas"
        :key="idx"
        class="col-12 col-sm-6 col-md-4 col-lg-3"
      >
        <q-card class="cursor-pointer card-hover" @click="abrirDialogFrase(f, false)">
          <q-card-section>
            <div class="row justify-center q-mb-sm">
              <q-avatar size="56px" color="deep-purple-7" text-color="white">
                {{ letraFrase(f) }}
              </q-avatar>
            </div>

            <div class="text-body2 text-weight-medium frase-preview">
              “{{ textoFrase(f) || '...' }}”
            </div>

            <div class="text-caption text-grey-7 q-mt-sm">
              <span v-if="autorFrase(f)">Autor: <b>{{ autorFrase(f) }}</b></span>
              <span v-else>Autor: <b>-</b></span>
            </div>

            <div class="text-caption text-grey-7 q-mt-xs">
              Tema: <b>{{ temaFrase(f) || '-' }}</b>
            </div>
          </q-card-section>

          <q-separator />

          <q-card-section
            v-if="false" 
            class="text-center">
            <q-btn
              unelevated
              color="primary"
              icon="check"
              label="Usar como frase do dia"
              class="full-width"
              @click.stop="definirComoFraseDoDia(f)"
            />
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Dialog da Frase do Dia / detalhe -->
    <q-dialog v-model="dialogAberto" persistent>
      <q-card style="min-width: 340px; max-width: 680px;">
        <q-card-section class="row items-center">
          <q-avatar size="46px" color="deep-purple-7" text-color="white">
            {{ dialogTituloLetra }}
          </q-avatar>
          <div class="q-ml-md">
            <div class="text-subtitle1 text-weight-bold">{{ dialogTitulo }}</div>
            <div class="text-caption text-grey-7">
              {{ dialogSubtitulo }}
            </div>
          </div>

          <q-space />

          <q-btn
            flat
            round
            dense
            icon="close"
            @click="fecharDialog"
            aria-label="Fechar"
          />
        </q-card-section>

        <q-separator />

        <q-card-section>
          <div class="text-body1">
            <span class="aspas">“</span>{{ dialogTexto }}<span class="aspas">”</span>
          </div>

          <div class="text-caption text-grey-7 q-mt-md">
            <div>Autor: <b>{{ dialogAutor || '-' }}</b></div>
            <div>Tema: <b>{{ dialogTema || '-' }}</b></div>
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right">
          <q-btn
            flat
            icon="search"
            label="Pesquisar na internet"
            @click="pesquisarInternet(dialogTexto)"
          />
          <q-btn
            unelevated
            color="deep-purple-7"
            icon="check"
            label="Definir como frase do dia"
            @click="definirComoFraseDoDia(dialogFrase)"
          />
          <q-btn
            flat
            label="Fechar"
            @click="fecharDialog"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>

import axios from "axios";

const api = axios.create({
  baseURL: "https://egiserp.com.br/api",
  withCredentials: true,
  timeout: 60000,
});

api.interceptors.request.use(cfg => {
  const banco = localStorage.nm_banco_empresa || ''
  if (banco) cfg.headers['x-banco'] = banco
  cfg.headers['Authorization'] = 'Bearer superchave123'
  if (!cfg.headers['Content-Type']) cfg.headers['Content-Type'] = 'application/json'
  return cfg
})

export default {
  name: "mostrarFraseDia",

  data() {
    return {
      loading: false,
      filtro: "",
      frases: [],

      cd_usuario: Number(localStorage.cd_usuario || 0),
      headerBanco: localStorage.nm_banco_empresa || "",

      dialogAberto: false,
      dialogFrase: null,
      dialogTitulo: "Frase",
      dialogSubtitulo: "",
      dialogTexto: "",
      dialogAutor: "",
      dialogTema: "",
      dialogTituloLetra: "F",
    };
  },

  computed: {
    frasesFiltradas() {
      var f = (this.filtro || "").trim().toLowerCase();
      if (!f) return this.frases;

      return this.frases.filter((x) => {
        var t = String(this.textoFrase(x) || "").toLowerCase();
        var a = String(this.autorFrase(x) || "").toLowerCase();
        var m = String(this.temaFrase(x) || "").toLowerCase();
        return t.indexOf(f) >= 0 || a.indexOf(f) >= 0 || m.indexOf(f) >= 0;
      });
    },
  },

  created() {
    this.carregarFrases(false);
  },

  methods: {
    // -------------- helpers tolerantes --------------
    pickCI(obj, keys) {
      if (!obj) return null;
      var map = {};
      Object.keys(obj).forEach(function (k) {
        map[k.toLowerCase()] = k;
      });
      for (var i = 0; i < keys.length; i++) {
        var kk = String(keys[i]).toLowerCase();
        var real = map[kk];
        if (real) return obj[real];
      }
      return null;
    },

    idFrase(f) {
      return this.pickCI(f, ["cd_dica", "cd_frase_dia", "cd", "id"]);
    },

    textoFrase(f) {
      return this.pickCI(f, ["ds_dica", "nm_frase", "frase", "ds_texto", "texto"]);
    },

    autorFrase(f) {
      return this.pickCI(f, ["nm_autor", "autor", "nm_usuario", "nm_fantasia_usuario"]);
    },

    temaFrase(f) {
      return this.pickCI(f, ["nm_dica", "tema", "nm_categoria", "categoria"]);
    },

    letraFrase(f) {
      var t = String(this.temaFrase(f) || this.autorFrase(f) || "F").trim();
      return (t[0] || "F").toUpperCase();
    },

    // -------------- lógica frase do dia --------------
    hojeKey() {
      // yyyy-mm-dd
      var d = new Date();
      var mm = String(d.getMonth() + 1).padStart(2, "0");
      var dd = String(d.getDate()).padStart(2, "0");
      return d.getFullYear() + "-" + mm + "-" + dd;
    },

    jaEscolheuHoje() {
      return localStorage.frase_dia_data === this.hojeKey();
    },

    salvarFraseDia(frase) {
      localStorage.frase_dia_data = this.hojeKey();
      localStorage.frase_dia_id = (this.idFrase(frase) !== null && this.idFrase(frase) !== undefined)
        ? this.idFrase(frase)
        : "";
      localStorage.frase_dia_texto = this.textoFrase(frase) || "";
      localStorage.frase_dia_autor = this.autorFrase(frase) || "";
      localStorage.frase_dia_tema = this.temaFrase(frase) || "";
    },

    escolherRandom(frases) {
      if (!frases || !frases.length) return null;
      var idx = Math.floor(Math.random() * frases.length);
      return frases[idx];
    },

    abrirDialogFrase(frase, isFraseDia) {
      this.dialogFrase = frase || null;

      var txt = this.textoFrase(frase) || "";
      var autor = this.autorFrase(frase) || "";
      var tema = this.temaFrase(frase) || "";

      this.dialogTitulo = isFraseDia ? "Frase do Dia" : "Frase";
      this.dialogSubtitulo = isFraseDia ? ("Escolhida em " + this.hojeKey()) : "Detalhe";
      this.dialogTexto = txt;
      this.dialogAutor = autor;
      this.dialogTema = tema;

      var letra = String(tema || autor || "F").trim();
      this.dialogTituloLetra = (letra[0] || "F").toUpperCase();

      this.dialogAberto = true;
    },

    fecharDialog() {
      this.dialogAberto = false;
    },

    definirComoFraseDoDia(frase) {
      if (!frase) return;
      this.salvarFraseDia(frase);

      if (this.$q && this.$q.notify) {
        this.$q.notify({
          type: "positive",
          message: "Frase do dia definida!",
        });
      }

      this.dialogAberto = false;
    },

    // -------------- chamadas API --------------
    async carregarFrases(forceMostrarRandom) {
      this.loading = true;
      try {
        var body = [
          {
            ic_json_parametro: "S",
            cd_parametro: 10,
            cd_usuario: this.cd_usuario,
          },
        ];

        var cfg = this.headerBanco
          ? { headers: { "x-banco": this.headerBanco } }
          : undefined;

        var resp = await api.post(
          "/exec/pr_egis_admin_processo_modulo",
          body,
          cfg
        );

        // se voltar HTML (login), cai fora
        if (resp && typeof resp.data === "string") {
          throw new Error("Sessão inválida (API retornou HTML/login).");
        }

        var rows = (resp && resp.data) ? resp.data : [];
        if (rows && rows.dados) rows = rows.dados;
        if (!Array.isArray(rows)) rows = rows ? [rows] : [];

        this.frases = rows;

        // Primeira vez do dia: escolhe random e mostra dialog
        // Ou se forceMostrarRandom for true, mostra de novo (útil pra testar)
        if ((forceMostrarRandom || !this.jaEscolheuHoje()) && this.frases.length) {
          var frase = this.escolherRandom(this.frases);
          if (frase) {
            this.salvarFraseDia(frase);
            this.abrirDialogFrase(frase, true);
          }
        }

      } catch (e) {
        console.error("[mostrarFraseDia] erro:", e);
        this.frases = [];

        if (this.$q && this.$q.notify) {
          this.$q.notify({
            type: "negative",
            message: "Erro ao carregar frases. Veja o console.",
          });
        }
      } finally {
        this.loading = false;
      }
    },

    // -------------- internet search --------------
    pesquisarInternet(texto) {
      var q = String(texto || "").trim();
      if (!q) return;
      // abre em nova aba, sem CORS, simples e efetivo
      var url = "https://www.google.com/search?q=" + encodeURIComponent(q);
      window.open(url, "_blank");
    },

    onPesquisarInternet() {
      var q = String(this.filtro || "").trim();
      if (!q) return;
      this.pesquisarInternet(q);
    },

    // -------------- navegação --------------
    onVoltar() {
      if (this.$router) {
        this.$router.push({ name: "home" }).catch(() => {
          this.$router.push({ path: "/" }).catch(() => {});
        });
      } else {
        window.location.href = "/";
      }
    },
  },
};
</script>

<style scoped>
.toolbar-scroll {
  overflow-x: auto;
  white-space: nowrap;
}

.seta-form {
  margin-left: 10px;
  color: #512da8;
}

.content-block {
  margin: 0;
}

.card-hover{
  border-radius: 18px;
  transition: transform .2s ease, box-shadow .2s ease;
}

.card-hover:hover{
  transform: translateY(-4px);
  box-shadow: 0 12px 28px rgba(0,0,0,.18);
}

.frase-preview{
  min-height: 54px;
}

.aspas{
  color: #512da8;
  font-size: 22px;
  font-weight: 700;
}
</style>
