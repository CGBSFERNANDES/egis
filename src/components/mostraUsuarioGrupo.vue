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
      </h2>
    </div>

    <q-tabs
      v-model="abaAtiva"
      dense
      align="left"
      class="text-deep-purple-7 q-mb-sm"
      active-color="deep-purple-7"
      indicator-color="deep-orange-7"
    >
      <q-tab name="grupos" icon="group" label="Grupos" />
      <q-tab
        name="modulos"
        icon="view_module"
        label="Módulos do grupo"
        :disable="!grupoSelecionado"
      />
    </q-tabs>
    <q-separator class="q-mb-md" />

    <q-tab-panels v-model="abaAtiva" animated>
      <q-tab-panel name="grupos" class="q-pa-none">
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
              <div v-if="grupoAtualNome" class="text-caption">
                Usuário: <b>{{ cd_usuario }}</b>
                <span class="q-ml-sm">
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
            <q-card class="cursor-pointer card-hover" @click="selecionarGrupo(g)">
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
                  Código:
                  <b>
                    {{
                      (codigoGrupo(g) !== null && codigoGrupo(g) !== undefined && codigoGrupo(g) !== '')
                        ? codigoGrupo(g)
                        : '-'
                    }}
                  </b>
                </div>
              </q-card-section>

              <q-separator />

              <q-card-section class="text-center">
                <q-btn
                  flat
                  dense
                  color="deep-purple-7"
                  icon="check_circle"
                  label="Configurar módulos"
                  @click.stop="selecionarGrupo(g)"
                />
              </q-card-section>
            </q-card>
          </div>
        </div>
      </q-tab-panel>

      <q-tab-panel name="modulos" class="q-pa-none">
        <q-banner
          dense
          class="bg-deep-purple-1 text-deep-purple-9 rounded-borders q-mb-md"
          v-if="grupoSelecionado"
        >
          <div class="row items-center no-wrap">
            <div class="col">
              <div class="text-body1">
                Grupo selecionado:
                <b>{{ nomeGrupo(grupoSelecionado) }}</b>
                <span class="text-caption text-grey-8 q-ml-sm">
                  ({{ codigoGrupo(grupoSelecionado) }})
                </span>
              </div>
              <div class="text-caption text-grey-8">
                Módulos marcados: <b>{{ modulosSelecionados.length }}</b>
              </div>
            </div>
            <q-btn
              flat
              dense
              round
              icon="refresh"
              :loading="loadingModulos"
              :disable="loadingModulos"
              @click="carregarModulosDoGrupo"
            >
              <q-tooltip>Recarregar módulos</q-tooltip>
            </q-btn>
          </div>
        </q-banner>

        <div class="row q-col-gutter-md q-mb-sm">
          <div class="col-12 col-md-6">
            <q-input
              dense
              outlined
              v-model="filtroModulo"
              placeholder="Filtrar módulos..."
              clearable
              :disable="loadingModulos"
            >
              <template v-slot:prepend>
                <q-icon name="search" />
              </template>
            </q-input>
          </div>

          <div class="col-12 col-md-6 text-right">
            <q-btn
              flat
              dense
              color="deep-purple-7"
              icon="arrow_back"
              label="Voltar para grupos"
              @click="abaAtiva = 'grupos'"
            />
          </div>
        </div>

        <q-inner-loading :showing="loadingModulos">
          <q-spinner size="36px" />
        </q-inner-loading>

        <div v-if="!loadingModulos" class="q-mt-sm">
          <dx-data-grid
            v-if="grupoSelecionado"
            :key="gridModuloKey"
            :data-source="modulosFiltrados"
            :key-expr="'cd_modulo'"
            :column-auto-width="true"
            :show-borders="false"
            :hover-state-enabled="true"
            :row-alternation-enabled="true"
            :height="'60vh'"
            :selected-row-keys="modulosSelecionados"
            :no-data-text="grupoSelecionado ? 'Nenhum módulo retornado para o grupo.' : 'Selecione um grupo para listar módulos.'"
            @selection-changed="onSelectionChanged"
          >
            <dx-scrolling mode="standard" />
            <dx-selection
              mode="multiple"
              show-check-boxes-mode="always"
              select-all-mode="allPages"
            />
            <dx-search-panel :visible="true" :width="300" placeholder="Filtrar..." />
            <dx-paging :page-size="15" />
            <dx-pager
              :show-page-size-selector="true"
              :allowed-page-sizes="[10, 15, 30, 50]"
              :show-info="true"
            />
            <dx-toolbar>
              <dx-item location="before" template="tituloModulo" />
            </dx-toolbar>

            <template #tituloModulo>
              <div class="text-subtitle2 text-grey-8">
                {{ grupoSelecionado ? 'Selecione os módulos do grupo' : 'Selecione um grupo para listar módulos' }}
              </div>
            </template>

            <dx-column
              data-field="cd_modulo"
              caption="Código"
              data-type="number"
              width="110"
              :allow-filtering="true"
              :allow-sorting="true"
            />
            <dx-column
              data-field="nm_modulo"
              caption="Módulo"
              :allow-filtering="true"
              :allow-sorting="true"
            />
            <dx-column
              data-field="ic_grupo_modulo"
              caption="Está no grupo?"
              width="140"
            />
          </dx-data-grid>
        </div>

        <div class="row justify-end q-gutter-sm q-mt-md">
          <q-btn
            outline
            color="deep-purple-7"
            icon="home"
            label="Aplicar grupo e voltar"
            :disable="!grupoSelecionado"
            @click="aplicarGrupoSelecionado"
          />
          <q-btn
            unelevated
            color="deep-purple-7"
            icon="save"
            label="Salvar módulos selecionados"
            :loading="salvandoModulos"
            :disable="!grupoSelecionado || loadingModulos"
            @click="salvarModulosSelecionados"
          />
        </div>
      </q-tab-panel>
    </q-tab-panels>
  </div>
</template>

<script>
import axios from "axios";
import {
  DxDataGrid,
  DxColumn,
  DxSelection,
  DxScrolling,
  DxSearchPanel,
  DxPager,
  DxPaging,
  DxToolbar,
  DxItem,
} from "devextreme-vue/data-grid";

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
  components: {
    DxDataGrid,
    DxColumn,
    DxSelection,
    DxScrolling,
    DxSearchPanel,
    DxPager,
    DxPaging,
    DxToolbar,
    DxItem,
  },

  data() {
    return {
      loading: false,
      loadingModulos: false,
      salvandoModulos: false,
      filtro: "",
      filtroModulo: "",
      grupos: [],
      modulos: [],
      modulosSelecionados: [],
      ultimoGrupoCarregado: null,
      gridModuloKey: 0,
      grupoSelecionado: null,
      abaAtiva: "grupos",
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

    modulosFiltrados() {
      const termo = (this.filtroModulo || "").trim().toLowerCase();
      const lista = Array.isArray(this.modulos)
        ? this.modulos.map((m) => ({
            ...m,
            cd_modulo: Number(m.cd_modulo),
          }))
        : [];
      if (!termo) return lista;

      return lista.filter((m) => {
        const nome = String(m.nm_modulo || "").toLowerCase();
        const cod = String(m.cd_modulo || "").toLowerCase();
        return nome.includes(termo) || cod.includes(termo);
      });
    },
  },

  created() {
    this.carregarGrupos();
  },

  watch: {
    abaAtiva(novaAba) {
      if (
        novaAba === "modulos" &&
        this.grupoSelecionado &&
        !this.loadingModulos &&
        this.modulos.length === 0
      ) {
        this.carregarModulosDoGrupo();
      }
    },
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

        var rows = (resp && resp.data) ? resp.data : [];
        if (rows && rows.dados) rows = rows.dados;
        if (!Array.isArray(rows)) rows = rows ? [rows] : [];

        console.log("dados", rows);
        this.grupos = rows;

        if (!this.grupoSelecionado && rows.length) {
          this.grupoSelecionado = rows[0];
        }

        const codigoAtual = this.codigoGrupo(this.grupoSelecionado);
        if (codigoAtual && codigoAtual !== this.ultimoGrupoCarregado) {
          await this.carregarModulosDoGrupo();
        }
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
      this.grupoSelecionado = g;
      const cd = this.codigoGrupo(g);
      const nm = this.nomeGrupo(g);

      localStorage.cd_grupo_usuario = cd ?? "";
      localStorage.nm_grupo_usuario = nm ?? "";

      this.gridModuloKey += 1;
      this.abaAtiva = "modulos";
      this.carregarModulosDoGrupo();
    },

    async carregarModulosDoGrupo() {
      if (!this.grupoSelecionado) return;

      const cd_grupo_usuario = this.codigoGrupo(this.grupoSelecionado);
      if (!cd_grupo_usuario) {
        this.$q?.notify?.({
          type: "warning",
          message: "Selecione um grupo para carregar os módulos.",
        });
        return;
      }

      this.loadingModulos = true;
      this.modulos = [];
      this.modulosSelecionados = [];

      try {
        const body = [
          {
            ic_json_parametro: "S",
            cd_parametro: 20,
            cd_usuario: this.cd_usuario,
            cd_grupo_usuario,
            cd_empresa: localStorage.cd_empresa,
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

        let rows = (resp && resp.data) ? resp.data : [];
        if (rows && rows.dados) rows = rows.dados;
        if (!Array.isArray(rows)) rows = rows ? [rows] : [];

        this.modulos = rows;
        this.modulosSelecionados = rows
          .filter((m) => String(m.ic_grupo_modulo || "").toUpperCase() === "S")
          .map((m) => Number(m.cd_modulo));

        this.ultimoGrupoCarregado = cd_grupo_usuario;
        this.gridModuloKey += 1;
      } catch (error) {
        console.error("[mostraUsuarioGrupo] erro ao carregar módulos:", error);
        this.modulos = [];
        this.modulosSelecionados = [];
        this.$q?.notify?.({
          type: "negative",
          message: "Erro ao carregar módulos do grupo. Veja o console.",
        });
      } finally {
        this.loadingModulos = false;
      }
    },

    async salvarModulosSelecionados() {
      if (!this.grupoSelecionado) return;

      const cd_grupo_usuario = this.codigoGrupo(this.grupoSelecionado);
      if (!cd_grupo_usuario) {
        this.$q?.notify?.({
          type: "warning",
          message: "Selecione um grupo antes de salvar os módulos.",
        });
        return;
      }

      this.salvandoModulos = true;

      try {
        const selecionados = new Set(
          (this.modulosSelecionados || []).map((m) => Number(m))
        );

        const modulosPayload = (this.modulos || []).map((m) => {
          const cd_modulo = Number(m.cd_modulo);
          return {
            cd_modulo,
            ic_grupo_modulo: selecionados.has(cd_modulo) ? "S" : "N",
          };
        });

        const body = [
          {
            ic_json_parametro: "S",
            cd_parametro: 20,
            cd_usuario: this.cd_usuario,
            cd_grupo_usuario,
            cd_empresa: localStorage.cd_empresa,
            modulos: modulosPayload,
          },
        ];

        const cfg = this.headerBanco
          ? { headers: { "x-banco": this.headerBanco } }
          : undefined;

        await api.post("/exec/pr_egis_admin_processo_modulo", body, cfg);

        this.$q?.notify?.({
          type: "positive",
          message: "Módulos enviados com sucesso.",
        });
      } catch (error) {
        console.error("[mostraUsuarioGrupo] erro ao salvar módulos:", error);
        this.$q?.notify?.({
          type: "negative",
          message: "Não foi possível salvar os módulos selecionados.",
        });
      } finally {
        this.salvandoModulos = false;
      }
    },

    aplicarGrupoSelecionado() {
      if (!this.grupoSelecionado) return;

      const cd = this.codigoGrupo(this.grupoSelecionado);
      const nm = this.nomeGrupo(this.grupoSelecionado);

      localStorage.cd_grupo_usuario = cd ?? "";
      localStorage.nm_grupo_usuario = nm ?? "";

      setTimeout(() => this.onVoltar(), 50);
    },

    onSelectionChanged(e) {
      const keys = Array.isArray(e?.selectedRowKeys) ? e.selectedRowKeys : [];
      this.modulosSelecionados = keys.map((k) => Number(k));
    },

    onVoltar() {
      // volta para o HOME (igual você pediu: não "fechar", e sim voltar)
      if (this.$router) {
        this.$router.push({ name: "home" }).catch(() => {
          // fallback caso não exista name="home"
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
