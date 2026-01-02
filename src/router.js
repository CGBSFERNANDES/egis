import Vue from "vue";
import Router from "vue-router";
import auth from "./auth";
import defaultLayout from "./layouts/side-nav-outer-toolbar";
import Home from "./views/home";
import simpleLayout from "./layouts/single-card";
import Chat from "./views/chat-gbs";
import Simple from "./layouts/Simple";
import gbsPadrao from "./layouts/gbsPadrao";
//import consultaAtividade from './components/consultaAtividade';

//import acesso from "./views/acesso";

Vue.use(Router);

const originalPush = Router.prototype.push;

// Rewrite the push method on the prototype and handle the error message uniformly

Router.prototype.push = function push(location) {
  return originalPush.call(this, location).catch((err) => err);
};

const originalReplace = Router.prototype.replace;

// Rewrite the push method on the prototype and handle the error message uniformly

Router.prototype.replace = function replace(location) {
  return originalReplace.call(this, location).catch((err) => err);
};

/*
//Rotas Básicas para Funcionamento do Módulo
*/

var dados = [];

dados = [
  {
    path: '*',
    name: '',
  },

  {
    path: '/',
    name: 'home',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: Home,
    },
  },
  {
    path: '/',
    name: 'chat-gbs',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: Chat,
    },
  },
  {
    path: '/',
    name: 'login-form',
    meta: { requiresAuth: false },
    components: {
      layout: simpleLayout,
      // route level code-splitting
      // this generates a separate chunk (login.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      content: () => import(/* webpackChunkName: "login" */ './views/login-form'),
    },
  },
  {
    path: '/registro',
    name: 'registroUsuario',
    meta: { requiresAuth: false },
    components: {
      layout: gbsPadrao,
      // route level code-splitting
      // this generates a separate chunk (login.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      content: () => import(/* webpackChunkName: "login" */ './views/registroUsuario'),
    },
  },

  {
    path: '/webchat',
    name: 'webchat',
    meta: { requiresAuth: false },
    components: {
      layout: gbsPadrao,
      // route level code-splitting
      // this generates a separate chunk (login.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      content: () => import(/* webpackChunkName: "login" */ './components/webChat.vue'),
    },
  },

  {
    path: '/acesso/:cd_empresa/:cd_usuario/:cd_menu',
    name: 'acesso',
    meta: { requiresAuth: false },
    components: {
      layout: simpleLayout,
      // route level code-splitting
      // this generates a separate chunk (login.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      content: () => import(/* webpackChunkName: "login" */ './views/acesso'),
    },
  },

  {
    path: '/palestra',
    name: 'palestra',
    meta: { requiresAuth: false },
    components: {
      layout: defaultLayout,
      // route level code-splitting
      // this generates a separate chunk (login.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      content: () => import(/* webpackChunkName: "login" */ './views/palestra'),
    },
  },

  {
    path: '/novoLogin-form',
    name: 'novologin-form',
    meta: { requiresAuth: false },
    components: {
      layout: simpleLayout,
      // route level code-splitting
      // this generates a separate chunk (login.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      content: () => import(/* webpackChunkName: "login" */ './views/novoLogin-form'),
    },
  },
  {
    path: '/',
    name: 'selecao-empresa',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/selecao-empresa'),
    },
  },
  {
    path: '/',
    name: 'consultaAtividade',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () =>
        import(/* webpackChunkName: "display-data" */ './components/consultaAtividade'),
    },
  },

  {
    path: '/',
    name: 'documentosCRUD',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './components/documentosCRUD'),
    },
  },

  {
    path: '/',
    name: 'selecao-modulo',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/selecao-modulo'),
    },
  },

  {
    path: '/',
    name: 'selecao-modulo-card',
    meta: { requiresAuth: true },
    components: {
      layout: gbsPadrao,
      content: () => import(/* webpackChunkName: "display-data" */ './views/selecao-modulo-card'),
    },
  },
  {
    path: '/',
    name: 'modulo-composicao',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/moduloComposicao'),
    },
  },

  {
    path: '/',
    name: 'selecao-periodo',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/selecao-periodo'),
    },
  },

  {
    path: '/',
    name: 'cliente',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/cliente'),
    },
  },

  {
    path: '/',
    name: 'contrato-consorcio',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/contrato-consorcio'),
    },
  },

  {
    path: '/',
    name: 'contato',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/contato'),
    },
  },

  {
    path: '/',
    name: 'config-usuario',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/config-usuario'),
    },
  },

  {
    path: '/',
    name: 'mostra-usuario-grupo',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () =>
        import(/* webpackChunkName: "display-data" */ './components/mostraUsuarioGrupo'),
    },
  },

  {
    path: '/',
    name: 'mostra-usuario-empresa',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () =>
        import(/* webpackChunkName: "display-data" */ './components/mostraUsuarioEmpresa'),
    },
  },
  {
    path: '/',
    name: 'mostra-frase-dia',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './components/mostrarFraseDia'),
    },
  },
  {
    path: '/',
    name: 'lista-aniversariantes',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './components/listaAniversariantes'),
    },
  },
  {
    path: '/',
    name: 'aviso-modulo',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () =>
        import(/* webpackChunkName: "display-data" */ './components/mostrarAvisoModulo'),
    },
  },
  {
    path: '/',
    name: 'egis-sobre',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/egis-sobre'),
    },
  },

  {
    path: '/',
    name: 'cronograma',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/cronograma'),
    },
  },

  {
    path: '/',
    name: 'pesquisa-satisfacao',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/pesquisa-satisfacao'),
    },
  },

  {
    path: '/',
    name: 'geraFormularioEspecial',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () =>
        import(/* webpackChunkName: "display-data" */ './views/geraFormularioEspecial'),
    },
  },

  {
    path: '/',
    name: 'cadastroFormEspecial',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/cadastroFormEspecial'),
    },
  },

  {
    path: '/',
    name: 'parcelas-contrato',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/parcelas-contrato'),
    },
  },
  {
    path: '/',
    name: 'sorteio',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/sorteio'),
    },
  },

  {
    path: '/cvat',
    name: 'avaliacao-selecao',
    meta: { requiresAuth: false },
    components: {
      layout: Simple,
      content: () => import(/* webpackChunkName: "display-data" */ './views/avaliacao-selecao'),
    },
  },

  {
    path: '/negociacao',
    name: 'negociacao',
    meta: { requiresAuth: false },
    components: {
      layout: Simple,
      content: () => import(/* webpackChunkName: "display-data" */ './views/negociacao'),
    },
  },

  {
    path: '/evento',
    name: 'cadastro-evento',
    meta: { requiresAuth: false },
    components: {
      layout: Simple,
      content: () => import(/* webpackChunkName: "display-data" */ './views/cadastro-evento'),
    },
  },

  {
    // criado para cervejaria do chefe - Kelvin
    path: '/entrada_207',
    name: 'registro-entrada',
    meta: { requiresAuth: false },
    components: {
      layout: Simple,
      content: () => import(/* webpackChunkName: "display-data" */ './views/registro-entrada'),
    },
  },

  {
    path: '/',
    name: 'auto-pagamento',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/auto-pagamento'),
    },
  },

  {
    path: '/',
    name: 'Painel',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/Painel'),
    },
  },
  //Localizar

  //Home
  {
    path: '/',
    name: '493',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/home'),
    },
  },

  {
    path: '/',
    name: 'filaAtendimento',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/filaAtendimento'),
    },
  },

  {
    path: '/',
    name: 'salaAtendimento',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/salaAtendimento'),
    },
  },

  {
    path: '/',
    name: 'display-datav2',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/display-datav2'),
    },
  },

  {
    path: '/',
    name: 'ConfiguraViews',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/ConfiguraViews'),
    },
  },

  {
    path: '/',
    name: 'lancamentoEstoque',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/lancamentoEstoque'),
    },
  },

  {
    path: '/',
    name: 'pedido-venda-fabrica',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/pedido-venda-fabrica'),
    },
  },

  {
    path: '/',
    name: 'pedido-venda-cliente',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/pedido-venda-cliente'),
    },
  },

  {
    path: '/',
    name: 'pedido-venda-medida',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/pedido-venda-medida'),
    },
  },

  {
    path: '/',
    name: 'pedido-venda-padrao',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/pedido-venda-padrao'),
    },
  },

  {
    path: '/',
    name: 'osGrafica',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/osGrafica'),
    },
  },

  {
    path: '/',
    name: 'formulario-pesquisa',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/formulario-pesquisa'),
    },
  },

  {
    path: '/',
    name: 'solicitacao-compra',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/solicitacao-compra'),
    },
  },

  {
    path: '/',
    name: 'requisicaoInterna',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/requisicaoInterna'),
    },
  },

  {
    path: '/',
    name: 'digitacaoOrcamento',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/digitacaoOrcamento'),
    },
  },

  {
    path: '/',
    name: 'ordemServicoLancamento',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/ordemServicoLancamento'),
    },
  },

  {
    path: '/',
    name: 'documento',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/documento'),
    },
  },

  {
    path: '/',
    name: 'integracao-magento',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/integracao-magento'),
    },
  },

  {
    path: '/',
    name: 'crud-padrao',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/crud-padrao'),
    },
  },

  {
    path: '/',
    name: 'autoForm',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/autoForm'),
    },
  },

  {
    path: '/',
    name: 'GeradorQRCode',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/GeradorQRCode.vue'),
    },
  },

  {
    path: '/',
    name: 'gridFormulario',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/gridFormulario.vue'),
    },
  },

  {
    path: '/',
    name: 'geracaoRemessa',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/geracaoRemessa.vue'),
    },
  },

  {
    path: '/',
    name: 'retornoRemessa',
    meta: { requiresAuth: true },
    components: {
      layout: defaultLayout,
      content: () => import(/* webpackChunkName: "home" */ './views/retornoRemessa.vue'),
    },
  },

  {
    path: '/afterglass',
    name: 'afterglass',
    meta: { requiresAuth: false },
    components: {
      layout: simpleLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/login-form'),
    },
  },

  {
    path: '/aftersystem',
    name: 'aftersystem',
    meta: { requiresAuth: false },
    components: {
      layout: simpleLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/login-form'),
    },
  },

  {
    path: '/ativos/:empresa/:freezer',
    name: 'ativos',
    meta: { requiresAuth: false },
    components: {
      layout: Simple,
      content: () => import(/* webpackChunkName: "display-data" */ './views/ativos'),
    },
  },
  // Rota de indisponibilidade
  {
    path: '/unavailable',
    name: 'unavailable',
    component: () => import('@/views/Unavailable.vue'),
    meta: { requiresAuth: true },
  },

  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    meta: { requiresAuth: false },
    components: {
      layout: simpleLayout,
      content: () => import(/* webpackChunkName: "display-data" */ './views/NotFound'),
    },
  },
  //

  //
  //30.03.2021
  //
  //até aqui
  //

  //Ler a Tabela do Módulo//
]
//

const router = new Router({
  routes: dados,
  mode: "history",
  duplicateNavigationPolicy: "ignore",
});

router.beforeEach((to, from, next) => {
  if (to.name === "login-form" && auth.authenticated()) {
    next({ name: "home" });
  }

  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!auth.authenticated()) {
      next({
        name: "login-form",
      });
    } else {
      next();
    }
  } else {
    next();
  }
});



export default router;
