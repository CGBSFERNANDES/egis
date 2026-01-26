<template>
  <q-card class="pesquisa-menu-card">
    <q-card-section class="row items-center q-pb-none">
      <div class="text-h6">Pesquisa de Menu</div>
      <q-space />
      <q-btn icon="close" flat round dense @click="fecharPesquisa" />
    </q-card-section>

    <q-card-section class="q-pt-none">
      <div class="row q-col-gutter-md items-center">
        <div class="col-12 col-md-6">
          <q-input
            dense
            outlined
            v-model="filtroTexto"
            placeholder="Buscar menu..."
            clearable
          />
        </div>
        <div class="col-12 col-md-6 text-right text-grey-6">
          {{ menusFiltrados.length }} de {{ menusDisponiveis.length }} menus
        </div>
      </div>
    </q-card-section>

    <q-card-section class="q-pt-none">
      <div v-if="carregando" class="row justify-center q-pa-md">
        <q-spinner color="primary" size="40px" />
      </div>
      <div v-else class="menus-grid">
        <div
          v-for="menu in menusFiltrados"
          :key="menu.path || menu.text"
          class="menu-card cursor-pointer"
          @click="selecionarMenu(menu)"
        >
          <div class="menu-card-body">
            <div class="menu-logo">
              <span class="menu-logo-letter">
                {{ (menu.text || '').charAt(0) }}
              </span>
            </div>
            <div class="menu-nome">
              {{ menu.text }}
            </div>
            <div class="menu-path" v-if="menu.path">
              {{ menu.path }}
            </div>
          </div>
        </div>
        <div v-if="menusFiltrados.length === 0" class="text-grey-6 q-pa-md">
          Nenhum menu encontrado.
        </div>
      </div>
    </q-card-section>
  </q-card>
</template>

<script>
import Modulo from "../http/modulo"
import Rota from "../http/rota"
import defaultLayout from "../layouts/side-nav-outer-toolbar"
import { resolveMenuContent } from "@/menus/menu-component-resolver"

export default {
  name: "PesquisaMenu",
  data() {
    return {
      filtroTexto: "",
      items: [],
      carregando: false,
    }
  },
  computed: {
    menusDisponiveis() {
      return this.flattenMenus(this.items)
    },
    menusFiltrados() {
      if (!this.filtroTexto) {
        return this.menusDisponiveis
      }
      const termo = this.filtroTexto.toUpperCase()
      return this.menusDisponiveis.filter((menu) =>
        (menu.text || "").toUpperCase().includes(termo)
      )
    },
  },
  async created() {
    await this.carregarMenus()
  },
  methods: {
    fecharPesquisa() {
      this.$emit("close")
    },
    async carregarMenus() {
      this.carregando = true
      const cd_modulo = localStorage.cd_modulo
      try {
        const res = await Modulo.getModulo(cd_modulo)
        if (Array.isArray(res)) {
          this.items = JSON.parse(JSON.stringify(res))
        } else {
          console.warn("Modulo.getModulo retornou inválido:", res)
          this.items = []
        }
      } catch (e) {
        console.error("Erro ao carregar menus:", e)
        this.items = []
      } finally {
        this.carregando = false
      }
    },
    flattenMenus(items) {
      if (!Array.isArray(items)) return []
      const lista = []
      items.forEach((item) => {
        if (item && item.path) {
          lista.push(item)
        }
        if (Array.isArray(item.items) && item.items.length) {
          lista.push(...this.flattenMenus(item.items))
        }
      })
      return lista
    },
    routeExists(name) {
      const n = String(name)
      const all =
        (this.$router.getRoutes && this.$router.getRoutes()) ||
        (this.$router.matcher &&
          this.$router.matcher.getRoutes &&
          this.$router.matcher.getRoutes()) ||
        []
      if (all.length) return all.some((r) => r.name === n)
      return false
    },
    ensureRoute(route) {
      if (this.routeExists(route.name)) return
      if (typeof this.$router.addRoute === "function") {
        this.$router.addRoute(route)
      } else if (typeof this.$router.addRoutes === "function") {
        this.$router.addRoutes([route])
      }
      if (this.$router.options && Array.isArray(this.$router.options.routes)) {
        this.$router.options.routes.push(route)
      }
    },
    async selecionarMenu(menu) {
      if (!menu || !menu.path) return
      await this.abrirMenu(menu)
      this.$emit("menu-selecionado")
    },
    async abrirMenu(menu) {
      const dados = await Rota.apiMenu(menu.path)
      this.$store._mutations.SET_Rotas = dados
      if (!dados) return

      localStorage.cd_menu = dados.cd_menu
      localStorage.nm_identificacao_api = dados.nm_identificacao_api
      localStorage.cd_api = dados.cd_api
      localStorage.nm_menu_titulo = dados.nm_menu_titulo

      if (dados.cd_api === 0) {
        alert("Falta configuração da API: " + dados.cd_api)
      }

      const cd_menu = Number(dados.cd_menu) || 0
      if (!cd_menu) return

      const nm_local_componente = (dados.nm_local_componente || "").trim()

      let contentLoader = null
      if (nm_local_componente === "Financeiro") {
        contentLoader = () => import(`@/Financeiro/${dados.nm_caminho_componente}`)
      } else if (nm_local_componente === "Compras") {
        contentLoader = () => import(`@/Compras/${dados.nm_caminho_componente}`)
      } else if (nm_local_componente === "gestaoFood") {
        contentLoader = () => import(`@/gestaoFood/${dados.nm_caminho_componente}`)
      } else {
        let caminho = dados.nm_caminho_componente
        if (dados.cd_rota === 204) {
          caminho = `my_${cd_menu}`
          contentLoader = () => import(`@/views/${caminho}`)
        } else {
          contentLoader = resolveMenuContent(cd_menu, caminho)
        }
      }

      const route = {
        path: "/",
        name: `${cd_menu}`,
        meta: { requiresAuth: true },
        components: {
          layout: defaultLayout,
          content: contentLoader,
        },
      }

      this.ensureRoute(route)

      if (localStorage.polling == 1) {
        clearInterval(localStorage.polling)
        localStorage.polling = 0
      }

      this.$router.push({ name: `${cd_menu}` }).catch(() => {})

      sessionStorage.setItem("egis:returnTo", this.$route.fullPath)
    },
  },
}
</script>

<style scoped>
.pesquisa-menu-card {
  min-width: 720px;
  max-width: 1100px;
}

.menus-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 12px;
}

.menu-card {
  background: #ffffff;
  border-radius: 18px;
  padding: 20px;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.12);
  color: #512da8;
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 100%;
  box-sizing: border-box;
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}

.menu-card:hover {
  box-shadow: 0 10px 26px rgba(0, 0, 0, 0.2);
  transform: translateY(-2px);
}

.menu-card-body {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 6px;
}

.menu-logo {
  background: #512da8;
  color: white;
  width: 56px;
  height: 56px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 26px;
  margin-bottom: 6px;
}

.menu-logo-letter {
  font-size: 26px;
  line-height: 1;
  font-weight: 800;
  color: #fff;
  text-transform: uppercase;
}

.menu-nome {
  font-weight: 700;
  font-size: 14px;
  color: #512da8;
}

.menu-path {
  font-size: 12px;
  color: #666;
}
</style>
