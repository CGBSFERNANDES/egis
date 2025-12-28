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
          @click="abaAtiva = 'grupos'"
        />
        <span>Grupo de Usuário</span>

        <q-space />
      </h2>
    </div>

    <q-tabs
      v-model="abaAtiva"
      dense
      align="left"
      class="text-deep-purple-7 q-mb-sm tabs-ajuste"
      active-color="deep-purple-7"
      indicator-color="deep-orange-7"
    >
      <q-tab name="grupos" icon="group" label="Grupos" 
         class="tab-label-pad"/>
      <q-tab
        name="modulos"
        icon="view_module"
        label="Módulos"
         class="tab-label-pad"
        :disable="!grupoSelecionado"
      />
      <q-tab
        name="menus"
        icon="menu_book"
        label="Menus"
         class="tab-label-pad"
        :disable="!grupoSelecionado"
      />
      <q-tab
        name="usuarios"
        icon="people_alt"
        label="Usuários"
         class="tab-label-pad"
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
              <q-card-section class="grupo-top text-center">
                <div class="grupo-avatar row justify-center q-mb-sm">
                  <q-avatar size="56px" color="deep-orange-7" text-color="white">
                    {{ letra(g) }}
                  </q-avatar>
                </div>

                <div class="text-subtitle1 text-weight-bold">
                  {{ nomeGrupo(g) || 'Grupo' }}
                </div>

                <div class="grupo-sub text-caption text-grey-7 q-mt-xs">
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

              <q-card-section class="grupo-footer text-center">
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
              label="Voltar"
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
            label="Aplicar"
            :disable="!grupoSelecionado"
            @click="abaAtiva = 'grupos'"
          />
          <q-btn
            unelevated
            color="deep-purple-7"
            icon="save"
            label="Salvar"
            :loading="salvandoModulos"
            :disable="!grupoSelecionado || loadingModulos"
            @click="salvarModulosSelecionados"
          />
        </div>
      </q-tab-panel>

      <q-tab-panel name="menus" class="q-pa-none">
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
                Menus no grupo: <b>{{ menusDoGrupo.length }}</b>
                <span
                v-if="menusDisponiveis && menusDisponiveis.length"
                 class="q-ml-sm">| Disponíveis: <b>{{ menusDisponiveis.length }}</b></span>
              </div>
            </div>
            <q-btn
              flat
              dense
              round
              icon="refresh"
              :loading="loadingMenus"
              :disable="loadingMenus"
              @click="carregarMenusDoGrupo"
            >
              <q-tooltip>Recarregar menus</q-tooltip>
            </q-btn>
          </div>
        </q-banner>

        <div class="row q-col-gutter-md q-mb-sm">
          <div class="col-12 col-md-6">
            <q-input
              dense
              outlined
              v-model="filtroMenu"
              placeholder="Filtrar menus..."
              clearable
              :disable="loadingMenus"
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
              label="Voltar"
              @click="abaAtiva = 'grupos'"
            />
          </div>
        </div>

        <q-inner-loading :showing="loadingMenus">
          <q-spinner size="36px" />
        </q-inner-loading>

        <div v-if="!loadingMenus" class="q-mt-sm">
          <div class="row q-col-gutter-lg">
            <div class="col-12 col-lg-6">
              <div class="text-subtitle2 text-grey-8 q-mb-xs">Menus disponíveis</div>
              <dx-data-grid
                :key="gridMenuDisponivelKey"
                :data-source="menusDisponiveisFiltrados"
                :key-expr="'cd_menu'"
                :column-auto-width="true"
                :show-borders="false"
                :hover-state-enabled="true"
                :row-alternation-enabled="true"
                :height="'50vh'"
                :no-data-text="'Nenhum menu disponível.'"
                :selected-row-keys="menusDisponiveisSelecionados"
                @selection-changed="onMenusDisponiveisSelectionChanged"
              >
                <dx-scrolling mode="standard" />
                <dx-selection
                  mode="multiple"
                  show-check-boxes-mode="always"
                  select-all-mode="allPages"
                />
                <dx-search-panel :visible="true" :width="300" placeholder="Filtrar..." />
                <dx-paging :page-size="10" />
                <dx-pager
                  :show-page-size-selector="true"
                  :allowed-page-sizes="[10, 15, 30, 50]"
                  :show-info="true"
                />

                <dx-column data-field="cd_modulo" caption="Cód. módulo" width="110" />
                <dx-column data-field="nm_modulo" caption="Módulo" />
                <dx-column data-field="cd_funcao" caption="Cód. função" width="110" />
                <dx-column data-field="nm_funcao" caption="Função" />
                <dx-column data-field="cd_menu" caption="Cód. menu" width="110" />
                <dx-column data-field="nm_menu_titulo" caption="Menu" />
              </dx-data-grid>
            </div>

            <div class="col-12 col-lg-6">
              <div class="text-subtitle2 text-grey-8 q-mb-xs">Menus do grupo</div>
              <dx-data-grid
                :key="gridMenuSelecionadoKey"
                :data-source="menusDoGrupoFiltrados"
                :key-expr="'cd_menu'"
                :column-auto-width="true"
                :show-borders="false"
                :hover-state-enabled="true"
                :row-alternation-enabled="true"
                :height="'50vh'"
                :no-data-text="'Nenhum menu vinculado ao grupo.'"
                :selected-row-keys="menusDoGrupoSelecionados"
                @selection-changed="onMenusDoGrupoSelectionChanged"
              >
                <dx-scrolling mode="standard" />
                <dx-selection
                  mode="multiple"
                  show-check-boxes-mode="always"
                  select-all-mode="allPages"
                />
                <dx-search-panel :visible="true" :width="300" placeholder="Filtrar..." />
                <dx-paging :page-size="10" />
                <dx-pager
                  :show-page-size-selector="true"
                  :allowed-page-sizes="[10, 15, 30, 50]"
                  :show-info="true"
                />

                <dx-column data-field="cd_modulo" caption="Cód. módulo" width="110" />
                <dx-column data-field="nm_modulo" caption="Módulo" />
                <dx-column data-field="cd_funcao" caption="Cód. função" width="110" />
                <dx-column data-field="nm_funcao" caption="Função" />
                <dx-column data-field="cd_menu" caption="Cód. menu" width="110" />
                <dx-column data-field="nm_menu_titulo" caption="Menu" />
              </dx-data-grid>
            </div>
          </div>

          <div class="row items-center justify-between q-gutter-sm q-mt-md">
            <div class="col-auto">
              <q-btn
                color="deep-purple-7"
                icon="east"
                label="Adicionar ao grupo"
                :disable="menusDisponiveisSelecionados.length === 0 || loadingMenus"
                @click="adicionarMenusAoGrupo"
              />
              <q-btn
                outline
                color="deep-orange-7"
                icon="west"
                class="q-ml-sm"
                label="Remover do grupo"
                :disable="menusDoGrupoSelecionados.length === 0 || loadingMenus"
                @click="removerMenusDoGrupo"
              />
            </div>

            <div class="col-auto">
              <q-btn
                unelevated
                color="deep-purple-7"
                icon="save"
                label="Salvar menus"
                :loading="salvandoMenus"
                :disable="loadingMenus || !grupoSelecionado"
                @click="salvarMenusSelecionados"
              />
            </div>
          </div>
        </div>
      </q-tab-panel>

      <q-tab-panel name="usuarios" class="q-pa-none">
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
                Usuários no grupo: <b>{{ usuarios.length }}</b>
              </div>
            </div>
            <q-btn
              flat
              dense
              round
              icon="refresh"
              :loading="loadingUsuarios"
              :disable="loadingUsuarios"
              @click="carregarUsuariosDoGrupo"
            >
              <q-tooltip>Recarregar usuários</q-tooltip>
            </q-btn>
          </div>
        </q-banner>

        <div class="row q-col-gutter-md q-mb-sm">
          <div class="col-12 col-md-6">
            <q-input
              dense
              outlined
              v-model="filtroUsuario"
              placeholder="Filtrar usuários..."
              clearable
              :disable="loadingUsuarios"
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
              label="Voltar"
              @click="abaAtiva = 'grupos'"
            />
          </div>
        </div>

        <q-inner-loading :showing="loadingUsuarios">
          <q-spinner size="36px" />
        </q-inner-loading>

        <div v-if="!loadingUsuarios" class="q-mt-sm">
          <dx-data-grid
            :key="gridUsuariosKey"
            :data-source="usuariosFiltrados"
            :key-expr="'cd_usuario'"
            :column-auto-width="true"
            :show-borders="false"
            :hover-state-enabled="true"
            :row-alternation-enabled="true"
            :height="'60vh'"
            :no-data-text="'Nenhum usuário vinculado ao grupo.'"
          >
            <dx-scrolling mode="standard" />
            <dx-search-panel :visible="true" :width="300" placeholder="Filtrar..." />
            <dx-paging :page-size="15" />
            <dx-pager
              :show-page-size-selector="true"
              :allowed-page-sizes="[10, 15, 30, 50]"
              :show-info="true"
            />

            <dx-column data-field="cd_usuario" caption="Cód." width="100" />
            <dx-column data-field="nm_usuario" caption="Usuário" />
            <dx-column data-field="nm_fantasia_usuario" caption="Fantasia" />
          </dx-data-grid>
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
      loadingMenus: false,
      salvandoMenus: false,
      loadingUsuarios: false,
      menusDisponiveis: [],
      filtro: "",
      filtroModulo: "",
      filtroMenu: "",
      filtroUsuario: "",
      grupos: [],
      modulos: [],
      menus: [],
      usuarios: [],
      modulosSelecionados: [],
      menusDoGrupoSelecionados: [],
      menusDisponiveisSelecionados: [],
      ultimoGrupoCarregado: null,
      gridModuloKey: 0,
      gridMenuDisponivelKey: 0,
      gridMenuSelecionadoKey: 0,
      gridUsuariosKey: 0,
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

    menusDisponiveisFiltrados() {
      const termo = (this.filtroMenu || "").trim().toLowerCase();
      const disponiveis = this.menus.filter((m) => Number(m.cd_menu_grupo_usuario) === 0);
      if (!termo) return disponiveis;

      return disponiveis.filter((m) => {
        const nome = String(m.nm_menu_titulo || "").toLowerCase();
        const cod = String(m.cd_menu || "").toLowerCase();
        const modulo = String(m.nm_modulo || "").toLowerCase();
        return nome.includes(termo) || cod.includes(termo) || modulo.includes(termo);
      });
    },

    menusDoGrupo() {
      return this.menus.filter((m) => Number(m.cd_menu_grupo_usuario) !== 0);
    },

    menusDoGrupoFiltrados() {
      const termo = (this.filtroMenu || "").trim().toLowerCase();
      const list = this.menusDoGrupo;
      if (!termo) return list;

      return list.filter((m) => {
        const nome = String(m.nm_menu_titulo || "").toLowerCase();
        const cod = String(m.cd_menu || "").toLowerCase();
        const modulo = String(m.nm_modulo || "").toLowerCase();
        return nome.includes(termo) || cod.includes(termo) || modulo.includes(termo);
      });
    },

    usuariosFiltrados() {
      const termo = (this.filtroUsuario || "").trim().toLowerCase();
      if (!termo) return this.usuarios;

      return this.usuarios.filter((u) => {
        const nome = String(u.nm_usuario || "").toLowerCase();
        const fantasia = String(u.nm_fantasia_usuario || "").toLowerCase();
        const cod = String(u.cd_usuario || "").toLowerCase();
        return nome.includes(termo) || fantasia.includes(termo) || cod.includes(termo);
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
      if (
        novaAba === "menus" &&
        this.grupoSelecionado &&
        !this.loadingMenus &&
        this.menus.length === 0
      ) {
        this.carregarMenusDoGrupo();
      }
      if (
        novaAba === "usuarios" &&
        this.grupoSelecionado &&
        !this.loadingUsuarios &&
        this.usuarios.length === 0
      ) {
        this.carregarUsuariosDoGrupo();
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
            position: "center",
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
      this.gridMenuDisponivelKey += 1;
      this.gridMenuSelecionadoKey += 1;
      this.gridUsuariosKey += 1;
      this.menus = [];
      this.usuarios = [];
      this.menusDoGrupoSelecionados = [];
      this.menusDisponiveisSelecionados = [];
      this.abaAtiva = "modulos";
      this.carregarModulosDoGrupo();
    },

    async carregarModulosDoGrupo() {
      if (!this.grupoSelecionado) return;

      const cd_grupo_usuario = this.codigoGrupo(this.grupoSelecionado);
      if (!cd_grupo_usuario) {
        this.$q?.notify?.({
          type: "warning",
          position: "center",
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
          position: "center",
          message: "Erro ao carregar módulos do grupo. Veja o console.",
        });
      } finally {
        this.loadingModulos = false;
      }
    },

    async carregarMenusDoGrupo() {
      if (!this.grupoSelecionado) return;

      const cd_grupo_usuario = this.codigoGrupo(this.grupoSelecionado);
      if (!cd_grupo_usuario) {
        this.$q?.notify?.({
          type: "warning",
          position: "center",
          message: "Selecione um grupo para carregar os menus.",
        });
        return;
      }

      this.loadingMenus = true;
      this.menus = [];
      this.menusDoGrupoSelecionados = [];
      this.menusDisponiveisSelecionados = [];

      try {
        const body = [
          {
            ic_json_parametro: "S",
            cd_parametro: 40,
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

        this.menus = rows.map((m) => ({
          ...m,
          cd_menu: Number(m.cd_menu),
          cd_modulo: Number(m.cd_modulo),
          cd_menu_grupo_usuario: Number(m.cd_menu_grupo_usuario || 0),
        }));

        this.gridMenuDisponivelKey += 1;
        this.gridMenuSelecionadoKey += 1;
      } catch (error) {
        console.error("[mostraUsuarioGrupo] erro ao carregar menus:", error);
        this.menus = [];
        this.$q?.notify?.({
          type: "negative",
          position: "center",
          message: "Erro ao carregar menus do grupo. Veja o console.",
        });
      } finally {
        this.loadingMenus = false;
      }
    },

    onMenusDisponiveisSelectionChanged(e) {
      const keys = Array.isArray(e?.selectedRowKeys) ? e.selectedRowKeys : [];
      this.menusDisponiveisSelecionados = keys.map((k) => Number(k));
    },

    onMenusDoGrupoSelectionChanged(e) {
      const keys = Array.isArray(e?.selectedRowKeys) ? e.selectedRowKeys : [];
      this.menusDoGrupoSelecionados = keys.map((k) => Number(k));
    },

    adicionarMenusAoGrupo() {
      if (this.menusDisponiveisSelecionados.length === 0) return;
      const selecionados = new Set(this.menusDisponiveisSelecionados.map(Number));
      this.menus = this.menus.map((m) => {
        if (selecionados.has(Number(m.cd_menu))) {
          return { ...m, cd_menu_grupo_usuario: m.cd_menu };
        }
        return m;
      });
      this.menusDisponiveisSelecionados = [];
      this.gridMenuDisponivelKey += 1;
      this.gridMenuSelecionadoKey += 1;
    },

    removerMenusDoGrupo() {
      if (this.menusDoGrupoSelecionados.length === 0) return;
      const selecionados = new Set(this.menusDoGrupoSelecionados.map(Number));
      this.menus = this.menus.map((m) => {
        if (selecionados.has(Number(m.cd_menu))) {
          return { ...m, cd_menu_grupo_usuario: 0 };
        }
        return m;
      });
      this.menusDoGrupoSelecionados = [];
      this.gridMenuDisponivelKey += 1;
      this.gridMenuSelecionadoKey += 1;
    },

    async salvarMenusSelecionados() {
      if (!this.grupoSelecionado) return;

      const cd_grupo_usuario = this.codigoGrupo(this.grupoSelecionado);

      if (!cd_grupo_usuario) {
        this.$q?.notify?.({
          type: "warning",
          position: "center",
          message: "Selecione um grupo antes de salvar os menus.",
        });
        return;
      }

      this.salvandoMenus = true;

      try {
        const body = [
          {
            ic_json_parametro: "S",
            cd_parametro: 60,
            cd_usuario: this.cd_usuario,
            cd_grupo_usuario,
            cd_empresa: localStorage.cd_empresa,
            dados_registro: this.menus.map((m) => ({
              cd_grupo_usuario: Number(cd_grupo_usuario),
              cd_modulo: Number(m.cd_modulo),
              cd_menu: Number(m.cd_menu),
              ic_grupo_modulo: Number(m.cd_menu_grupo_usuario) !== 0 ? "S" : "N",
            })),
          },
        ];

        const cfg = this.headerBanco
          ? { headers: { "x-banco": this.headerBanco } }
          : undefined;

        await api.post("/exec/pr_egis_admin_processo_modulo", body, cfg);

        this.$q?.notify?.({
          type: "positive",
          position: "center",
          message: "Menus enviados com sucesso.",
        });
      } catch (error) {
        console.error("[mostraUsuarioGrupo] erro ao salvar menus:", error);
        this.$q?.notify?.({
          type: "negative",
          position: "center",
          message: "Não foi possível salvar os menus selecionados.",
        });
      } finally {
        this.salvandoMenus = false;
        this.carregarModulosDoGrupo();
      }
    },

    async carregarUsuariosDoGrupo() {
      if (!this.grupoSelecionado) return;

      const cd_grupo_usuario = this.codigoGrupo(this.grupoSelecionado);
      if (!cd_grupo_usuario) {
        this.$q?.notify?.({
          type: "warning",
          position: "center",
          message: "Selecione um grupo para carregar os usuários.",
        });
        return;
      }

      this.loadingUsuarios = true;
      this.usuarios = [];

      try {
        const body = [
          {
            ic_json_parametro: "S",
            cd_parametro: 50,
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

        this.usuarios = rows;
        this.gridUsuariosKey += 1;
      } catch (error) {
        console.error("[mostraUsuarioGrupo] erro ao carregar usuários:", error);
        this.usuarios = [];
        this.$q?.notify?.({
          type: "negative",
          position: "center",
          message: "Erro ao carregar usuários do grupo. Veja o console.",
        });
      } finally {
        this.loadingUsuarios = false;
      }
    },

    async salvarModulosSelecionados() {
      
      if (!this.grupoSelecionado) return;

      const cd_grupo_usuario = this.codigoGrupo(this.grupoSelecionado);
      
      if (!cd_grupo_usuario) {
        this.$q?.notify?.({
          type: "warning",
          position: "center",
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

        const dados_registro = (modulosPayload || []).map((m) => ({
          cd_grupo_usuario: Number(cd_grupo_usuario),
          cd_modulo: Number(m.cd_modulo),
          ic_grupo_modulo: String(m.ic_grupo_modulo || "N").toUpperCase(),
        }));


        const body = [
          {
            ic_json_parametro: "S",
            cd_parametro: 30,
            cd_usuario: this.cd_usuario,
            cd_grupo_usuario,
            cd_empresa: localStorage.cd_empresa,
            modulos: modulosPayload,
            dados_registro,
          },
        ];

        console.log('modulosPayload', modulosPayload);

        const cfg = this.headerBanco
          ? { headers: { "x-banco": this.headerBanco } }
          : undefined;

        await api.post("/exec/pr_egis_admin_processo_modulo", body, cfg);

        this.$q?.notify?.({
          type: "positive",
          position: "center",
          message: "Módulos enviados com sucesso.",
        });
      } catch (error) {
        console.error("[mostraUsuarioGrupo] erro ao salvar módulos:", error);
        this.$q?.notify?.({
          type: "negative",
          position: "center",
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

.grupo-card{
  width: 320px;              /* ajuste como quiser (ou 100% dentro da col) */
  height: 220px;             /* altura fixa para todos */
  display: flex;
  flex-direction: column;
  border-radius: 14px;
}

.grupo-top{
  flex: 1;                   /* ocupa o “miolo” e empurra o rodapé pra baixo */
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 18px 16px;
  text-align: center;
}

.grupo-avatar{
  width: 56px;
  height: 56px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  font-weight: 700;
  margin-bottom: 10px;
  /* se você já usa cor via classe/inline, pode remover */
}

.grupo-title{
  font-size: 15px;           /* tamanho fixo do nome */
  font-weight: 700;
  line-height: 1.2;
  margin: 4px 0 6px;

  /* padrão */
  display: block;
  overflow: hidden;

  /* clamp moderno */
  line-clamp: 2;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.grupo-sub{
  font-size: 12px;
  opacity: 0.7;
}

.grupo-footer{
  min-height: 54px;          /* rodapé com altura fixa */
  padding: 10px 12px;
}

.grupo-footer .q-btn__content{
  white-space: nowrap;
}

.tabs-ajuste .q-tab__content {
  flex-direction: row;
}

.tabs-ajuste .q-tab__icon {
  margin-right: 8px; /* ajuste fino aqui */
}



.tab-label-pad :deep(.q-tab__content) {
  padding: 0 10px;
  gap: 6px;            /* espaço entre ícone e label */
}


.tab-label-pad .q-tab__label {
  padding-left: 6px;
  margin-left: 15px;
  margin-right: 6px;
  
}

.tab-label-pad :deep(.q-tab__icon) {
  margin-right: 6px;
}

</style>
