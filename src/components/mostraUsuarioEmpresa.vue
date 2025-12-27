<template>
  <div class="q-pa-md">
    <!-- Topo estilo unicoFormEspecial: seta voltar + atualizar -->
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
        <span>Usuários da Empresa</span>

        <q-space />

        <q-btn
          dense
          rounded
          icon="refresh"
          color="deep-purple-7"
          size="lg"
          class="q-ml-sm"
          @click="carregarUsuariosEmpresa"
          :loading="loading"
          :disable="loading"
        >
          <q-tooltip>Atualizar</q-tooltip>
        </q-btn>
      </h2>
    </div>

    <!-- Filtros -->
    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-12 col-md-6">
        <q-input
          dense
          outlined
          v-model="filtro"
          placeholder="Buscar usuário..."
          clearable
        >
          <template v-slot:prepend>
            <q-icon name="search" />
          </template>
        </q-input>
      </div>

      <div class="col-12 col-md-6">
        <q-banner dense class="bg-grey-2 text-grey-9 rounded-borders">
          <div class="text-caption">
            Empresa: <b>{{ cd_empresa }}</b>
            <span v-if="empresaAtualNome">
              | <b>{{ empresaAtualNome }}</b>
            </span>
            <span class="q-ml-sm">
              | Usuário logado: <b>{{ cd_usuario }}</b>
            </span>
          </div>
        </q-banner>
      </div>
    </div>

    <q-inner-loading :showing="loading">
      <q-spinner size="50px" />
    </q-inner-loading>

    <div v-if="!loading && usuariosFiltrados.length === 0" class="q-mt-md">
      <q-banner class="bg-orange-1 text-orange-10 rounded-borders">
        Nenhum usuário encontrado.
      </q-banner>
    </div>

    <!-- Cards -->
    <div class="row q-col-gutter-md q-mt-sm">
      <div
        v-for="(u, idx) in usuariosFiltrados"
        :key="idx"
        class="col-12 col-sm-6 col-md-4 col-lg-3"
      >
        <q-card class="cursor-pointer card-hover card-usuario" @click="selecionarUsuario(u)">
          <q-card-section class="text-center">
            <!-- Foto rounded no meio do card -->
            <div class="row justify-center q-mb-sm">
              <q-avatar size="86px" class="avatar-shadow">
                <img
                  v-if="fotoUsuario(u)"
                  :src="fotoUsuario(u)"
                  alt="Foto do usuário"
                  class="foto-rounded"
                  @error="onImgError(u)"
                />
                <div v-else class="fallback-avatar">
                  {{ letraUsuario(u) }}
                </div>
              </q-avatar>
            </div>

            <div class="text-subtitle1 text-weight-bold">
              {{ nomeUsuario(u) || 'Usuário' }}
            </div>

            <div class="text-caption text-grey-7 q-mt-xs">
              Login: <b>{{ fantasiaUsuario(u) || '-' }}</b>
            </div>

            <div class="text-caption text-grey-7 q-mt-xs">
              Departamento: <b>{{ departamentoUsuario(u) || '-' }}</b>
            </div>

            <div class="text-caption text-grey-7 q-mt-xs">
              Código: <b>{{ codigoUsuario(u) ? codigoUsuario(u) : '-' }}</b>
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
              label="Selecionar"
              @click.stop="selecionarUsuario(u)"
              class="full-width"
            />
          </q-card-section>
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
  name: "mostraUsuarioEmpresa",

  data() {
    return {
      loading: false,
      filtro: "",
      usuarios: [],
      cd_usuario: Number(localStorage.cd_usuario || 0),
      cd_empresa: Number(localStorage.cd_empresa || 0),
      empresaAtualNome: localStorage.fantasia || localStorage.nm_fantasia_empresa || "",
      headerBanco: localStorage.nm_banco_empresa || "",
      // cache de imagens que falharam
      imgFalhou: {},
    };
  },

  computed: {
    usuariosFiltrados() {
      var f = (this.filtro || "").trim().toLowerCase();
      if (!f) return this.usuarios;

      return this.usuarios.filter((u) => {
        var nome = String(this.nomeUsuario(u) || "").toLowerCase();
        var login = String(this.fantasiaUsuario(u) || "").toLowerCase();
        var depto = String(this.departamentoUsuario(u) || "").toLowerCase();
        var cod = String(this.codigoUsuario(u) || "").toLowerCase();
        return (
          nome.indexOf(f) >= 0 ||
          login.indexOf(f) >= 0 ||
          depto.indexOf(f) >= 0 ||
          cod.indexOf(f) >= 0
        );
      });
    },
  },

  created() {
    this.carregarUsuariosEmpresa();
  },

  methods: {
    // helpers p/ pegar campos com tolerância
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

    codigoUsuario(u) {
      return this.pickCI(u, ["cd_usuario"]);
    },

    nomeUsuario(u) {
      return this.pickCI(u, ["nm_usuario"]);
    },

    fantasiaUsuario(u) {
      return this.pickCI(u, ["nm_fantasia_usuario"]);
    },

    departamentoUsuario(u) {
      return this.pickCI(u, ["nm_departamento"]);
    },

    fotoUsuario(u) {
      var cd = this.codigoUsuario(u);
      var url = this.pickCI(u, ["nm_caminho_imagem"]);

      // se já marcou falha, não tenta de novo
      if (cd && this.imgFalhou[String(cd)]) return "";

      if (!url) return "";
      url = String(url).trim();
      if (!url) return "";

      return url;
    },

    letraUsuario(u) {
      var n = String(this.nomeUsuario(u) || this.fantasiaUsuario(u) || "U").trim();
      return (n[0] || "U").toUpperCase();
    },

    onImgError(u) {
      var cd = this.codigoUsuario(u);
      if (cd) this.$set(this.imgFalhou, String(cd), true);
    },

    async carregarUsuariosEmpresa() {
      this.loading = true;
      try {
        var body = [
          {
            ic_json_parametro: "S",
            cd_parametro: 2,
            cd_usuario: this.cd_usuario,
          },
        ];

        var cfg = this.headerBanco
          ? { headers: { "x-banco": this.headerBanco } }
          : undefined;

        // IMPORTANTÍSSIMO: usar o axios global do projeto (mesma sessão)
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

        console.log("dados", rows);
        this.usuarios = rows;
      } catch (e) {
        console.error("[mostraUsuarioEmpresa] erro:", e);
        this.usuarios = [];

        if (this.$q && this.$q.notify) {
          this.$q.notify({
            type: "negative",
            message: "Erro ao carregar usuários da empresa. Veja o console.",
          });
        }
      } finally {
        this.loading = false;
      }
    },

    selecionarUsuario(u) {
      var cd = this.codigoUsuario(u);
      var nm = this.nomeUsuario(u);
      var login = this.fantasiaUsuario(u);

      // guarda o selecionado (se você quiser usar isso em outro lugar)
      localStorage.cd_usuario_selecionado = (cd !== null && cd !== undefined) ? cd : "";
      localStorage.nm_usuario_selecionado = (nm !== null && nm !== undefined) ? nm : "";
      localStorage.nm_fantasia_usuario_selecionado = (login !== null && login !== undefined) ? login : "";

      // volta pro Home
      setTimeout(() => this.onVoltar(), 50);
    },

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

.card-usuario {
  border-radius: 16px;
}

.foto-rounded {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 999px;
}

.fallback-avatar {
  width: 100%;
  height: 100%;
  border-radius: 999px;
  background: #512da8;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 26px;
}

.avatar-shadow {
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.18);
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
