<template>
  <div class="q-pa-md">
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
    <span>Grupo de Usuário</span>

    <q-space />

      <q-btn       
        v-if="false" 
        rounded        
        dense
        color="deep-purple-7"
        icon="refresh"
        label="Atualizar"
        @click="carregarGrupos"
        :loading="loading"
        :disable="loading"
      />

      <q-btn
        v-if="false"
        rounded        
        dense
        color="deep-purple-7"
        icon="close"
        label="Fechar"
        class="q-ml-sm"
        @click="voltar"
      />
      </h2>
    </div>

    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-12 col-md-6">
        <q-input
          dense
          outlined
          v-model="filtro"
          placeholder="Buscar grupo..."
          clearable
        >
          <template v-slot:prepend>
            <q-icon name="search" />
          </template>
        </q-input>
      </div>

      <div class="col-12 col-md-6">
        <q-banner dense class="bg-grey-2 text-grey-9 rounded-borders">
          <div
            v-if="false" 
            class="text-caption">
            Usuário: <b>{{ cd_usuario }}</b>
            <span v-if="grupoAtualNome">
              | Atual: <b>{{ grupoAtualNome }}</b>
            </span>
          </div>
        </q-banner>
      </div>
    </div>

    <q-inner-loading :showing="loading">
      <q-spinner size="50px" />
    </q-inner-loading>

    <div v-if="!loading && gruposFiltrados.length === 0" class="q-mt-md">
      <q-banner class="bg-orange-1 text-orange-10 rounded-borders">
        Nenhum grupo encontrado.
      </q-banner>
    </div>

    <div class="row q-col-gutter-md q-mt-sm">
      <div
        v-for="(g, idx) in gruposFiltrados"
        :key="idx"
        class="col-12 col-sm-6 col-md-4 col-lg-3"
      >
        <q-card class="cursor-pointer card-hover">
          <q-card-section class="text-center">
            <div class="row justify-center q-mb-sm">
              <q-avatar size="56px" color="deep-orange-7" text-color="white">
                {{ letra(g) }}
              </q-avatar>
            </div>

            <div class="text-subtitle1 text-weight-bold">
              {{ nomeGrupo(g) || 'Grupo' }}
            </div>

            <div class="text-caption text-grey-7 q-mt-xs">
                 Código: <b>{{ (codigoGrupo(g) !== null && codigoGrupo(g) !== undefined && codigoGrupo(g) !== '') ? codigoGrupo(g) : '-' }}</b>
            </div>

          </q-card-section>

          <q-separator />

          
        </q-card>
      </div>
    </div>
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
  name: "mostraUsuarioGrupo",

  data() {
    return {
      loading: false,
      filtro: "",
      grupos: [],
      cd_usuario: Number(localStorage.cd_usuario || 0),
      grupoAtualNome: localStorage.nm_grupo_usuario || "",
      headerBanco: localStorage.nm_banco_empresa || "", // se você usa x-banco em algum lugar
    };
  },

  computed: {
    gruposFiltrados() {
      const f = (this.filtro || "").trim().toLowerCase();
      if (!f) return this.grupos;

      return this.grupos.filter((g) => {
        const nome = String(this.nomeGrupo(g) || "").toLowerCase();
        const cod = String(this.codigoGrupo(g) || "").toLowerCase();
        return nome.includes(f) || cod.includes(f);
      });
    },
  },

  created() {
    this.carregarGrupos();
  },

  methods: {
    // --- helpers para tolerar nomes de colunas diferentes ---
    pickCI(obj, keys) {
      if (!obj) return null;
      const map = {};
      Object.keys(obj).forEach((k) => (map[k.toLowerCase()] = k));
      for (const kk of keys) {
        const real = map[String(kk).toLowerCase()];
        if (real) return obj[real];
      }
      return null;
    },

    nomeGrupo(g) {
      return this.pickCI(g, ["nm_grupo_usuario", "nm_grupo", "grupo", "nm_grupo_de_usuario"]);
    },

    codigoGrupo(g) {
      return this.pickCI(g, ["cd_grupo_usuario", "cd_grupo", "cd_grupo_de_usuario", "cd"]);
    },

    letra(g) {
      const n = String(this.nomeGrupo(g) || "G").trim();
      return (n[0] || "G").toUpperCase();
    },

    //

    async carregarGrupos() {
  this.loading = true;
  try {
    const body = [
      {
        ic_json_parametro: "S",
        cd_empresa: localStorage.cd_empresa,
        cd_parametro: 1,
        cd_usuario: this.cd_usuario,
      },
    ];

    const cfg = this.headerBanco
      ? { headers: { "x-banco": this.headerBanco } }
      : undefined;

    const resp = await api.post(
      "/exec/pr_egis_admin_processo_modulo",
      body,
      cfg
    );

    // axios retorna { data, status, headers... }
    // a lista vem em resp.data (ou resp.data.dados em alguns padrões)
    var rows = (resp && resp.data) ? resp.data : [];

    // se vier embrulhado
    if (rows && rows.dados) rows = rows.dados;

    if (!Array.isArray(rows)) rows = rows ? [rows] : [];

    console.log("dados", rows);
    this.grupos = rows;

  } catch (e) {
    console.error("[mostraUsuarioGrupo] erro ao carregar:", e);
    this.grupos = [];

    if (this.$q && this.$q.notify) {
      this.$q.notify({
        type: "negative",
        message: "Erro ao carregar grupos. Veja o console.",
      });
    }
  } finally {
    this.loading = false;
  }
},

    selecionarGrupo(g) {
      const cd = this.codigoGrupo(g);
      const nm = this.nomeGrupo(g);

      // grava no localStorage pra header “pegar” igual faz com módulo
      localStorage.cd_grupo_usuario = (cd !== null && cd !== undefined) ? cd : "";
      localStorage.nm_grupo_usuario = (nm !== null && nm !== undefined) ? nm : "";
      //


      // opcional: se você precisa resetar menu, etc, faça aqui
      // localStorage.cd_menu = 0;

      //this.voltar(true);

      setTimeout(() => this.onVoltar(), 50);

    },

    onVoltar() {
  // volta para o HOME (igual você pediu: não "fechar", e sim voltar)
  if (this.$router) {
    // tenta por nome primeiro
    this.$router.push({ name: "home" }).catch(() => {
      // fallback caso não exista name="home"
      this.$router.push({ path: "/" }).catch(() => {});
    });
  } else {
    window.location.href = "/";
  }
},

    voltar(reload = false) {
      // volta pra tela anterior
      if (this.$router) {
        this.$router.back();
        if (reload) {
          // força o header atualizar lendo localStorage
          setTimeout(() => window.location.reload(), 50);
        }
      }
    },
  },
};
</script>

<style scoped>
.content-block {
  margin: 0;
}
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

</style>
