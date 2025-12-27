<template>
  <div class="dx-swatch-additional side-navigation-menu" @click="forwardClick">
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <slot />
    <div v-if="celular == 1" class="logo">
      <img class="img-sideNav" v-bind:src="pegaImg()" alt="" />
    </div>
    <div class="menu-container">
      <!--:class="{ padding1: ic_pesquisa }"-->
      <dx-tree-view
        :ref="treeViewRef"
        :items="items"
        :key-expr="path"
        selection-mode="single"
        :focus-state-enabled="true"
        expand-event="click"
        @item-click="handleItemClick"
        width="100%"
      >
      </dx-tree-view>
    </div>
    <div class="hoje">
      <transition name="bounce">
        <q-btn
          flat
          rounded
          class="items-center"
          label="Limpar"
          icon="close"
          v-show="ic_pesquisa == true"
          @click="LimpaPesquisa()"
        />
      </transition>
      <transition name="bounce">
        <q-btn
          flat
          rounded
          class="items-center"
          label="Pesquisar"
          icon="search"
          v-if="ic_pesquisa == false"
          @click="FocusPesquisa()"
        />
        <!--@blur="PesquisaMenu()"-->
        <q-input
          v-else
          color="grey-1"
          v-model="nm_menu"
          label-color="grey-1"
          id="inputPesquisa"
          style="margin: 5px 10px; color: white"
          label="Menu"
          v-on:keyup.enter="PesquisaMenu()"
          ref="searchinput"
          dark
          class="text-grey-1 inputPesquisa"
          autofocus
          outlined
        >
          <template v-slot:prepend>
            <q-icon name="menu_open" color="grey-1" />
          </template>
        </q-input>
      </transition>
    </div>

    <div class="hoje">
      {{ hoje }}
    </div>
  </div>
</template>

<script>
import DxTreeView from "devextreme-vue/ui/tree-view";

import navigation from "../app-navigation";

//Busca o Código do Módulo
import Modulo from "../http/modulo";
import Rota from "../http/rota";
import Router from "../router";
import defaultLayout from "../layouts/side-nav-outer-toolbar";
import funcao from "../http/funcoes-padroes";

const treeViewRef = "treeViewRef";

var items = [];
var dados = [];
var cd_menu = 0;

async function buscaRota(srota) {
  return await Rota.apiMenu(srota);
}

const addedRouteNames = new Set();

// --- Helpers para rotas dinâmicas (evita duplicidades) -----------------------
function routeExists (router, name) {
  if (typeof router.getRoutes === 'function') {
    return router.getRoutes().some(r => r.name === name)
  }
  // Vue Router 3 clássico
  return router.options && Array.isArray(router.options.routes) &&
         router.options.routes.some(r => r.name === name)
}

function ensureRoute(router, def) {
  if (!def?.name || !def?.path || !def?.component) return;

  if (addedRouteNames.has(def.name) || routeExists(router, def.name)) {
    return; // já existe
  }

  router.addRoutes([{
    name: def.name,
    path: def.path,
    component: def.component
  }]);

  addedRouteNames.add(def.name);
}

function addRouteIfMissing (router, route) {
  if (routeExists(router, route.name)) return
  if (typeof router.addRoute === 'function') {
    router.addRoute(route)                // Vue Router >= 3.5
  } else if (typeof router.addRoutes === 'function') {
    router.addRoutes([route])             // Vue Router 3.x antigo
  }
  // mantém options.routes em sincronia (útil para a checagem acima)
  if (router.options && Array.isArray(router.options.routes)) {
    router.options.routes.push(route)
  }
}


function ensureRouteExists(route) {
  // v3 (com addRoutes):
  const exists = (Router.options?.routes || []).some(r => r.name === route.name || r.path === route.path)
  if (!exists) {
    Router.addRoutes([route])
  }
}
  
/**
 * Monta a definição da rota a partir de "dados".
 * Sempre path único: /menu/<cd_menu>
 * Faz import dinâmico por pasta com base em nm_local_componente.
 */
function buildRouteFromDados(dados, defaultLayout) {
  const name = String(dados.cd_menu)
  const path = `/menu/${name}` // nunca "/" e nunca vazio!

  const comp = (folder) => () => import(`@/${folder}/${dados.nm_caminho_componente}`)

  let content
  if (dados.nm_local_componente === 'Financeiro') {
    content = comp('Financeiro')
  } else if (dados.nm_local_componente === 'Compras') {
    content = comp('Compras')        // <— se seus arquivos de Compras estão em outra pasta, ajuste aqui
  } else if (dados.nm_local_componente === 'gestaoFood') {
    content = comp('gestaoFood')
  } else {
    content = comp('views')          // default
  }

  return {
    name,
    path,
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content
    }
  }
}

function routeExistsByName(router, name) {
  try {
    return (router && router.matcher && router.match({ name })) ? true : false;
  } catch (_) { return false; }
}

export default {
  props: {
    compactMode: Boolean,
  },
  emits: ["AbreMenu"],
  data() {
    return {
      treeViewRef,
      nm_menu: "",
      items,
      path: "",
      celular: 0,
      dt_inicial: "",
      dt_final: "",
      hoje: "",
      ic_pesquisa: false,
      items_temp: [],
      compacted: true,
    };
  },
  async created() {
    window.addEventListener("keydown", (event) => {
      if (event.keyCode == 114) {
        event.preventDefault();
      }
    });
    this.compacted = this.compactMode;
    this.hoje = new Date().toLocaleDateString();

    this.detectar();

    var cd_modulo = localStorage.cd_modulo;

    //if (!navigation.cd_modulo == 0) cd_modulo = navigation.cd_modulo;

    if (navigation.cd_modulo !== 0) {
       cd_modulo = navigation.cd_modulo
    }


    /*
    await Modulo.getModulo(cd_modulo).then((res) => {
      this.items = JSON.parse(JSON.stringify(res));
      this.items_temp = this.items;
    });
    */
    try {
  const res = await Modulo.getModulo(cd_modulo)

  if (Array.isArray(res)) {
    // clone seguro
    this.items = JSON.parse(JSON.stringify(res))
    this.items_temp = this.items
  } else {
    console.warn('Modulo.getModulo retornou inválido:', res)
    this.items = []
    this.items_temp = []
  }

} catch (e) {
  console.error('Erro ao carregar módulos do menu:', e)
  this.items = []
  this.items_temp = []
}



    document.onkeydown = (e) => {
      if (e.keyCode == 114 && this.ic_pesquisa == false) {
        this.ic_pesquisa = true;
        this.compacted = false;
        this.$emit("AbreMenu");
        setTimeout(() => {
          const el = document.getElementById("inputPesquisa");
          el.focus();
        }, 200);
      } else if (e.keyCode == 114 && this.ic_pesquisa == true) {
        this.items = this.items_temp;
        this.ic_pesquisa = false;
        this.nm_menu = "";
        this.treeView.collapseAll();
      }
    };

    // this.compactMode = true;
  },

  safeParseJson(v, fallback = null) {
  if (v === null || v === undefined) return fallback
  if (v === 'undefined' || v === 'null' || v === '') return fallback
  try {
    return typeof v === 'string' ? JSON.parse(v) : v
  } catch (e) {
    return fallback
  }
},

  beforeUpdate() {},

  methods: {
    async LimpaPesquisa() {
      this.items = this.items_temp;
      this.ic_pesquisa = false;
      this.nm_menu = "";
    },
    async FocusPesquisa() {
      this.ic_pesquisa = true;
      await funcao.sleep(1000);
      setTimeout(() => {
        this.$refs.searchinput.focus();
      }, 200);
    },
    async PesquisaMenu() {
      if (this.nm_menu == "") {
        this.ic_pesquisa = false;
        this.items = this.items_temp;
      } else {
        let find = [];
        this.items = this.items_temp;
        if (this.nm_menu.toUpperCase() == "HOME") {
          find.push(this.items[0]);
        }
        for (let g = 0; g < this.items.length; g++) {
          if (this.items[g].text != "Home") {
            for (let t = 0; t < this.items[g].items.length; t++) {
              if (
                this.items[g].items[t].text
                  .toUpperCase()
                  .includes(this.nm_menu.toUpperCase()) == true
              ) {
                find.push(this.items[g].items[t]);
              }
            }
          }
        }

        this.items = find;

        //if (this.items.length == 1) {
        //  let y = {
        //    itemData: {
        //      path: this.items[0].path,
        //      text: this.items[0].text,
        //    },
        //  };
        //  this.handleItemClick(y);
        //}

        //this.nm_menu = "";
      }
    },
    forwardClick(...args) {
      this.$emit("click", args);
    },

    detectar() {
      if (
        navigator.userAgent.match(/Android/i) ||
        navigator.userAgent.match(/webOS/i) ||
        navigator.userAgent.match(/iPhone/i) ||
        navigator.userAgent.match(/iPad/i) ||
        navigator.userAgent.match(/iPod/i) ||
        navigator.userAgent.match(/BlackBerry/i) ||
        navigator.userAgent.match(/Windows Phone/i)
      ) {
        this.celular = 1;
      } else {
        this.celular = 0;
      }
    },

    pegaImg() {
      this.caminho = localStorage.nm_caminho_logo_empresa;
      var imagem = "http://www.egisnet.com.br/img/" + this.caminho;
      return imagem;
    },

    async handleItemClicknovo(e) {
  // Home
  if (e.itemData.text === 'Home') {
    this.$router.push({ name: 'home' })
    return
  }

  localStorage.cd_tipo_consulta = 0

  // sem path configurado no item do menu
  if (!e.itemData.path) return

  // Busca mapeamento da rota -> menu/api
  const dados = await buscaRota(e.itemData.path)
  this.$store._mutations.SET_Rotas = dados

  
  if (!dados) return

  // Seta contexto no localStorage (mantive sua lógica)
  localStorage.cd_menu = 0
  localStorage.nm_identificacao_api = ''
  localStorage.cd_api = 0

  localStorage.cd_menu = dados.cd_menu
  localStorage.nm_identificacao_api = dados.nm_identificacao_api
  localStorage.cd_api = dados.cd_api

  if (dados && Number(dados.cd_api) === 0) {
    alert('Falta configuração da API: ' + dados.cd_api)
  }

  // Monta rota única por menu e registra só se não existir
  const routeDef = buildRouteFromDados(dados, defaultLayout)
  addRouteIfMissing(this.$router, routeDef)

  // guarda path atual só por compatibilidade com seu código
  this.path = routeDef.path

  // Para qualquer polling pendente dos forms
  if (localStorage.polling == 1) {
    clearInterval(localStorage.polling)
    localStorage.polling = 0
  }

  // Navega pela rota PELO NAME (não use path "/")
  this.$router.push({ name: routeDef.name }).catch(err => err)

  // evita propagação do clique no treeview/devextreme
  const pointerEvent = e.event
  pointerEvent && pointerEvent.stopPropagation && pointerEvent.stopPropagation()
  
},

//
async handleItemClicknaofunciona(e) {
  // 1) Home
  if (e.itemData?.text === 'Home') {
    this.$router.push({ name: 'home' })
    return
  }

  // 2) Sem path no item do menu → avisa e sai
  if (!e.itemData?.path) {
    this.$q?.notify?.({ type: 'warning',
     position: 'center',    
     message: 'Menu sem rota configurada.',
     classes: 'my-notify' })
    return
  }

  // 3) Busca mapeamento da API/rota
  const dados = await buscaRota(e.itemData.path)

  // Se o backend não devolveu dados OU o componente não foi configurado → vai para "Indisponível"
  if (!dados || !dados.nm_caminho_componente) {
    this.$q?.dialog?.({
      title: 'Indisponível',
      message: 'Componente/rota inexistente ou em manutenção.'
    })
    this.$router.push({ name: 'unavailable' })
    return
  }

  // 4) Guarda contexto (mantive sua lógica)
  localStorage.cd_tipo_consulta = 0
  localStorage.cd_menu = String(dados.cd_menu || '')
  localStorage.nm_identificacao_api = dados.nm_identificacao_api || ''
  localStorage.cd_api = Number(dados.cd_api || 0)

  // 5) Monta rota dinâmica, garantindo path único
  const route = buildRouteFromDados(dados, defaultLayout)

  // 6) Evita duplicar rota (checa por nome OU path)
  ensureRouteExists(route)

  // 7) Navega SEM duplicar (use path único)
  this.$router.push(route.path)
  //this.$router.push({ name: route.name })
},


//

   async handleItemClick(e) {

      
      if (e.itemData.text == "Home") {
        this.$router.push({ name: "home" });
      }

      localStorage.cd_tipo_consulta = 0;

      if (!!e.itemData.path == false) {
          //|| this.compacted) {
        return;
      }

      //Define o Menu

      //Localizar o Código do Menu de acordo com a Rota
      //
      // path --> cd_menu

      dados = await buscaRota(e.itemData.path);

      this.$store._mutations.SET_Rotas = dados;
      
      if (dados) {
        localStorage.cd_menu = 0;
        localStorage.nm_identificacao_api = "";
        localStorage.cd_api = 0;

        localStorage.cd_menu              = dados.cd_menu;
        localStorage.nm_identificacao_api = dados.nm_identificacao_api;
        localStorage.cd_api               = dados.cd_api;
        localStorage.nm_menu_titulo       = dados.nm_menu_titulo;
        
        //console.log('dados do menu:', dados);

        if (dados && dados.cd_api == 0) {
          alert("Falta configuração da API: " + dados.cd_api);
        }

        cd_menu = dados.cd_menu;

      }

      //Adicionar as Rotas do Módulo

      if (!cd_menu == 0) {
        
        var link = false;
        const name = String(cd_menu);
        const nm_local_componente = dados.nm_local_componente || ''
        
        if (!link) {
      
          //const name = `${cd_menu}`;
          
          //ccf - 06.03.2022

          if (
            nm_local_componente &&
            nm_local_componente == "Financeiro"
          ) {
            if (!routeExists(this.$router, name)) {
               Router.addRoutes([
              {
                path: "/",
                name: `${cd_menu}`,
                meta: { requiresAuth: true },
                components: {
                  layout: defaultLayout,
                  content: () =>
                    import(
                      /* webpackChunkName: "display-data" */ `@/Financeiro/${dados.nm_caminho_componente}`
                    ),
                },
              },
            ]);
            }
          }

          //11.07.2022 - CCF / Nathan

          if (
            nm_local_componente &&
            nm_local_componente == "Compras"
          ) {
            if (!routeExists(this.$router, name)) {
            Router.addRoutes([
              {
                path: "/",
                name: `${cd_menu}`,
                meta: { requiresAuth: true },
                components: {
                  layout: defaultLayout,
                  content: () =>
                    import(
                      /* webpackChunkName: "display-data" */ `@/Financeiro/${dados.nm_caminho_componente}`
                    ),
                },
              },
            ]);
            }
          }
          //
          if (
            nm_local_componente &&
            nm_local_componente == "gestaoFood"
          ) {
            if (!routeExists(this.$router, name)) {
            Router.addRoutes([
              {
                path: "/",
                name: `${cd_menu}`,
                meta: { requiresAuth: true },
                components: {
                  layout: defaultLayout,
                  content: () =>
                    import(
                      /* webpackChunkName: "display-data" */ `@/gestaoFood/${dados.nm_caminho_componente}`
                    ),
                },
              },
            ]);
            }
          }

          //
          //Kelvin-Carlos -> 30.04.2022
          //
          else {
            
            console.log('Adicionando rota genérica para menu', name, cd_menu, dados.nm_caminho_componente);

            /////////////////////////////////////////////////////////////////////////////////////////
            if (!routeExists(this.$router, name)) {
              Router.addRoutes([
                {
                path: "/",
                name: `${cd_menu}`,
                meta: { requiresAuth: true },
                components: {
                  layout: defaultLayout,
                  content: () =>
                    import(
                      /* webpackChunkName: "display-data" */ `@/views/${dados.nm_caminho_componente}`
                    ),
                },
              },
            ]);
            }
          }
        }

        //      this.$router.push({
        //       path: e.itemData.path,
        //       query: { redirect: this.$route.path }
        //     }).catch(err=>err);

        //
        this.path = e.itemData.path;
        //

        //Rotina de Intervalo nos Forms

        if (localStorage.polling == 1) {
          clearInterval(localStorage.polling);
          localStorage.polling = 0;
        }
        //

        //Ativa a Rota
        this.$router
          .push({
            path: "/",
            name: e.itemData.path,
            key: dados.cd_menu,
            //query: { redirect: this.$route.path }
          })
          .catch((err) => err);

        //Promisse
        //var nRota = '/'+e.itemData.path;

        //this.$router.push(e.itemData.path);

        //this.$router.push( { path: `${e.itemData.path}` } );
        //this.$router.push(this.$route.query.redirect || `${e.itemData.path}` ,  { clearHistory: true });

        //.catch(()=>{});
        //

        const pointerEvent = e.event;
        pointerEvent.stopPropagation();
        //

      }


    },

    updateSelection() {
      if (!this.treeView) {
        return;
      }

      //      this.treeView.selectItem(this.$route.path);
      //      this.treeView.expandItem(this.$route.path);

      if (!cd_menu == 0) {
        const rota = this.$router.resolve({ name: `${cd_menu}` });

        if (rota) {
          this.treeView.selectItem(this.$route.name);
          this.treeView.expandItem(this.$route.name);
        }
      }
    },
  },

  mounted() {
    this.treeView = this.$refs[treeViewRef] && this.$refs[treeViewRef].instance;

    this.updateSelection();

    if (this.compacted) {
      this.treeView.collapseAll();
    }
  },

  updated() {
    this.treeView = this.$refs[treeViewRef] && this.$refs[treeViewRef].instance;
    this.updateSelection();

    if (this.compacted) {
      this.treeView.collapseAll();
    }
  },
  watch: {
    $route() {
      this.updateSelection();
    },
    compactMode() {
      if (this.compacted) {
        this.treeView.collapseAll();
      } else {
        this.updateSelection();
      }
    },
  },
  components: {
    DxTreeView,
  },
};
</script>

<style lang="scss">
@import "../dx-styles.scss";
@import "../themes/generated/variables.additional.scss";

.side-navigation-menu {
  display: flex;
  flex-direction: column;
  min-height: 100%;
  height: 100%;
  width: 250px !important;

  .menu-container {
    min-height: 70%;
    display: flex;
    flex: 1;

    .dx-treeview {
      white-space: nowrap;
      .dx-treeview-item {
        padding-left: 0;
        padding-right: 0;

        .dx-icon {
          width: $side-panel-min-width !important;
          margin: 0 !important;
        }
      }
      .dx-treeview-node {
        padding: 0 0 !important;
      }

      .dx-treeview-toggle-item-visibility {
        right: 10px;
        left: auto;
      }

      .dx-rtl .dx-treeview-toggle-item-visibility {
        left: 10px;
        right: auto;
      }
      .dx-treeview-node {
        &[aria-level="1"] {
          font-weight: bold;
          border-bottom: 1px solid $base-border-color;
        }

        &[aria-level="2"] .dx-treeview-item-content {
          font-weight: normal;
          padding: 0 $side-panel-min-width;
        }
      }
    }

    .dx-treeview {
      .dx-treeview-node-container {
        .dx-treeview-node {
          &.dx-state-selected:not(.dx-state-focused) > .dx-treeview-item {
            background: transparent;
          }

          &.dx-state-selected > .dx-treeview-item * {
            color: $base-accent;
          }

          &:not(.dx-state-focused) > .dx-treeview-item.dx-state-hover {
            background-color: lighten($base-bg, 4);
          }
        }
      }
    }

    .dx-theme-generic .dx-treeview {
      .dx-treeview-node-container
        .dx-treeview-node.dx-state-selected.dx-state-focused
        > .dx-treeview-item
        * {
        color: inherit;
      }
    }
  }
}

.img-sideNav {
  background-color: white;
  width: 80%;
  margin: 10px;
}

.logo {
  width: 100%;
  height: 100%;
  background-color: white;
}

.hoje {
  text-align: center;
  font-size: 20px;
  margin-bottom: 15px;
  font-weight: bold;
}
/* Enter and leave animations can use different */
/* durations and timing functions.              */
.slide-fade-enter-active {
  transition: all 0.3s ease;
}
.slide-fade-leave-active {
  transition: all 0.4s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter, .slide-fade-leave-to
/* .slide-fade-leave-active below version 2.1.8 */ {
  transform: translateX(10px);
  opacity: 0;
}
#inputPesquisa {
  color: white !important;
}
.padding1 {
  padding: 0.5vh 0.5vw;
}
.inputPesquisa {
  color: white !important;
}

.bounce-enter-active {
  animation: bounce-in 0.5s;
}
.bounce-leave-active {
  animation: bounce-in 0.5s reverse;
}
@keyframes bounce-in {
  0% {
    transform: scale(0);
  }
  50% {
    transform: scale(1.1);
  }
  100% {
    transform: scale(1);
  }
}

@media screen and (min-width: 600px) {
  .logo {
    background-color: black;
    height: 0px;
  }
  .img-sideNav {
    visibility: hidden;
  }
}
.my-notify {
  font-size: 1.4rem;     /* aumenta o texto */
  padding: 20px;         /* mais espaço interno */
  border-radius: 8px;    /* cantos arredondados */
  text-align: center;    /* centraliza o texto */
}

</style>
