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
        <span>Aviso dos Módulos</span>

        <q-space />

        <q-btn
          dense
          rounded
          icon="refresh"
          color="deep-purple-7"
          size="lg"
          class="q-ml-sm"
          @click="carregarAvisos"
          :loading="loading"
          :disable="loading"
        >
          <q-tooltip>Atualizar</q-tooltip>
        </q-btn>
      </h2>
    </div>

    <!-- Filtro -->
    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-12 col-md-7">
        <q-input
          dense
          outlined
          v-model="filtro"
          placeholder="Buscar por módulo, aviso..."
          clearable
        >
          <template v-slot:prepend>
            <q-icon name="search" />
          </template>
        </q-input>
      </div>

      <div class="col-12 col-md-5">
        <q-banner dense class="bg-grey-2 text-grey-9 rounded-borders">
          <div class="text-caption">
            Módulo: <b>{{ cd_modulo }}</b>
            <span class="q-ml-sm">| Avisos: <b>{{ avisos.length }}</b></span>
          </div>
        </q-banner>
      </div>
    </div>

    <q-inner-loading :showing="loading">
      <q-spinner size="50px" />
    </q-inner-loading>

    <div v-if="!loading && avisosFiltrados.length === 0" class="q-mt-md">
      <q-banner class="bg-orange-1 text-orange-10 rounded-borders">
        Nenhum aviso encontrado.
      </q-banner>
    </div>

    <!-- Cards -->
    <div class="row q-col-gutter-md q-mt-sm">
      <div
        v-for="(a, idx) in avisosFiltrados"
        :key="idx"
        class="col-12 col-sm-6 col-md-4 col-lg-3"
      >
        <q-card class="cursor-pointer card-hover" @click="abrirDetalhe(a)">
          <q-card-section class="text-center">
            <div class="row justify-center q-mb-sm">
              <q-avatar size="56px" color="cyan-7" text-color="white">
                {{ letraAviso(a) }}
              </q-avatar>
            </div>

            <div class="text-subtitle2 text-weight-bold">
              {{ safe(a.nm_aviso_sistema) || "Aviso" }}
            </div>

            <div class="text-caption text-grey-7 q-mt-xs">
              Módulo: <b>{{ safe(a.nm_modulo) || "-" }}</b>
            </div>

            <div class="text-caption text-grey-7 q-mt-xs">
              Código: <b>{{ a.cd_aviso_sistema ? a.cd_aviso_sistema : "-" }}</b>
            </div>

             <div class="q-mt-sm aviso-preview">
                <!-- Se tiver valor numérico, destaca em moeda -->
                <div v-if="temValor(a.vl_resultado)" class="valor-destaque">
                     {{ formatBRL(a.vl_resultado) }}
                </div>

                <!-- Senão, cai no preview normal -->
                <div v-else class="text-caption text-grey-7">
                   {{ preview(safe(a.vl_resultado)) }}
                  </div>
            </div>



            <div class="text-caption text-grey-7 q-mt-sm aviso-preview">
              {{ preview(safe(a.ds_aviso_sistema)) }}
            </div>

          </q-card-section>

          <q-separator />

          <q-card-section class="text-center">
            <q-btn
              v-if="Number(a.cd_menu || 0) > 0"
              rounded
              flat
              color="deep-orange-6"
              label="Acessar"
              icon="open_in_new"
              @click.stop="abrirMenuAviso(a)"
            />
            <q-btn
              v-else
              flat
              rounded
              icon="info"
              label="Detalhes"
              class="full-width"
              @click.stop="abrirDetalhe(a)"
            />
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- Dialog Detalhe -->
    <q-dialog v-model="dlgDetalhe">
      <q-card style="min-width: 360px; max-width: 820px;">
        <q-card-section class="row items-center">
          <div class="text-h6">{{ safe(avisoSel.nm_aviso_sistema) || "Aviso" }}</div>
          <q-space />
          <q-btn icon="close" flat rounded dense v-close-popup />
        </q-card-section>

        <q-separator />

        <q-card-section>
          <div class="text-caption text-grey-7">
            Módulo: <b>{{ safe(avisoSel.nm_modulo) || "-" }}</b>
          </div>

          <div class="q-mt-md text-body2">
            {{ safe(avisoSel.ds_aviso_sistema) || "" }}
          </div>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right">
          <q-btn
            v-if="Number(avisoSel.cd_menu || 0) > 0"
            rounded
            color="primary"
            icon="open_in_new"
            label="Abrir"
            @click="abrirMenuAviso(avisoSel)"
          />
          <q-btn flat label="Fechar" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Dialog UnicoFormEspecial embutido -->
    <q-dialog maximized v-model="dlgForm">
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">
            {{ safe(avisoSel.nm_aviso_sistema) || "Abrir" }}
          </div>
          <q-space />
          <q-btn icon="close" flat rounded dense v-close-popup />
        </q-card-section>

        <q-separator />

        <q-card-section class="q-pa-none">
          <!-- Abrir o menu do aviso dentro do UnicoFormEspecial -->
          <UnicoFormEspecial
            :embedMode="true"
            v-if="Number(avisoSel.cd_menu || 0) > 0"
            :cd_menu_entrada="Number(avisoSel.cd_menu || 0)"
            :titulo_menu_entrada="safe(avisoSel.nm_aviso_sistema)"
            :ic_modal_pesquisa="'N'"
            :modo_inicial="(String(avisoSel.ic_grid_resultado || 'S') === 'N') ? 'EDIT' : 'GRID'"
            @fechar="dlgForm = false"
            @voltar="dlgForm = false"
          />
        </q-card-section>
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

// ajuste o caminho conforme seu projeto
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue";

export default {
  
  name: "mostrarAvisoModulo",
  components: { UnicoFormEspecial },

  data() {
    return {
      loading: false,
      filtro: "",
      avisos: [],

      cd_modulo: Number(localStorage.cd_modulo || 0),
      cd_usuario: Number(localStorage.cd_usuario || 0),
      headerBanco: localStorage.nm_banco_empresa || "",

      dlgDetalhe: false,
      dlgForm: false,
      avisoSel: {},
    };
  },

  computed: {
    avisosFiltrados() {
      var f = (this.filtro || "").trim().toLowerCase();
      if (!f) return this.avisos;

      return this.avisos.filter((a) => {
        var mod = String(a.nm_modulo || "").toLowerCase();
        var tit = String(a.nm_aviso_sistema || "").toLowerCase();
        var desc = String(a.ds_aviso_sistema || "").toLowerCase();
        return mod.indexOf(f) >= 0 || tit.indexOf(f) >= 0 || desc.indexOf(f) >= 0;
      });
    },
  },

  created() {
    this.carregarAvisos();
  },

  methods: {

    temValor(v) {
  // aceita number ou string numérica (com vírgula/ponto)
  if (v === null || v === undefined) return false;

  if (typeof v === "number") return !isNaN(v);

  var s = String(v).trim();
  if (!s) return false;

  // remove separadores comuns e tenta converter
  // ex: "1.234,56" -> "1234.56"
  s = s.replace(/\./g, "").replace(",", ".");
  var n = Number(s);

  return !isNaN(n);
},

toNumber(v) {
  if (typeof v === "number") return v;
  var s = String(v || "").trim();
  s = s.replace(/\./g, "").replace(",", ".");
  var n = Number(s);
  return isNaN(n) ? 0 : n;
},

formatBRL(v) {
  var n = this.toNumber(v);
  try {
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(n);
  } catch (e) {
    // fallback simples
    return "R$ " + n.toFixed(2).replace(".", ",");
  }
},

    safe(v) {
      if (v === null || v === undefined) return "";
      return String(v);
    },

    preview(txt) {
      txt = String(txt || "").trim();
      if (!txt) return "(Sem descrição)";
      if (txt.length <= 110) return txt;
      return txt.substring(0, 110) + "...";
    },

    letraAviso(a) {
      var t = String(a.nm_modulo || a.nm_aviso_sistema || "A").trim();
      return (t[0] || "A").toUpperCase();
    },

    async carregarAvisos() {
      this.loading = true;
      try {
        // formato EXATO que você passou:
        // exec pr_egis_avisos_processo '[{"cd_parametro":4},{"cd_modulo":234},{"cd_usuario":1}]'
        var body = [
          { ic_json_parametro: 'S' ,  
            cd_parametro: 4 ,
            cd_aviso_sistema: 0,
            cd_modulo: this.cd_modulo ,
            cd_usuario: this.cd_usuario },
        ];

        console.log('body avisos=>', body);
        
        var cfg = this.headerBanco
          ? { headers: { "x-banco": this.headerBanco } }
          : undefined;

        var resp = await api.post("/exec/pr_egis_avisos_processo", body, cfg);

        // se voltar HTML, sessão caiu
        if (resp && typeof resp.data === "string") {
          throw new Error("Sessão inválida (API retornou HTML/login).");
        }

        var rows = (resp && resp.data) ? resp.data : [];
        if (rows && rows.dados) rows = rows.dados;
        if (!Array.isArray(rows)) rows = rows ? [rows] : [];

        this.avisos = rows;

        console.log('avisos:', rows);

      } catch (e) {
        console.error("[mostrarAvisoModulo] erro:", e);
        this.avisos = [];

        if (this.$q && this.$q.notify) {
          this.$q.notify({
            type: "negative",
            message: "Erro ao carregar avisos do módulo. Veja o console.",
          });
        }
      } finally {
        this.loading = false;
      }
    },

    abrirDetalhe(a) {
      this.avisoSel = a || {};
      this.dlgDetalhe = true;
    },

    abrirMenuAviso(a) {
      this.avisoSel = a || {};
      this.dlgDetalhe = false;
      this.dlgForm = true;
    },

    onVoltar() {
      // volta pro home
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

.aviso-preview{
  min-height: 54px;
}

.valor-destaque{
  font-size: 18px;
  font-weight: 800;
  color: #512da8;
  text-align: center;
  padding: 8px 10px;
  border-radius: 12px;
  background: rgba(81,45,168,.08);
  letter-spacing: .3px;
}


</style>
