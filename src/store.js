import Vue from 'vue'
import Vuex from 'vuex'
import Procedimento from './http/procedimento'
import Menu from './http/menu'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    operadores: [],
    disponivel: [],
    dataSourceConfig: [],
    configUsuario: [],
    usuario: [],
    rotas: [],
    avisoModulo:[],
    footerHideRequests: [],
  },

  mutations: {

    setDados(state, payload) {
      state.dataSourceConfig = payload
    },


    SET_OPERADOR(state, payload) {
      state.operadores = payload
    },

    SET_DATASOURCE(state, payload) {
      state.dataSourceConfig = payload
    },

    SET_ConfigUsuario(state, payload) {
      state.configUsuario = payload
    },
    
    SET_avisoModulo(state, payload) {
      state.avisoModulo = payload
    },

    SET_Usuario(state, payload) {
      state.usuario = payload
    },

    SET_Rotas(state, payload) {
      state.rotas = payload
    },

    getOperadorDisponivel(state) {
      state.disponivel = state.operadores.filter(state.operadores.ic_disponivel == 'Sim');

    },

    ADD_FOOTER_HIDE_REQUEST(state, id) {
      if (!id) return;
      if (!state.footerHideRequests.includes(id)) state.footerHideRequests.push(id);
    },

    REMOVE_FOOTER_HIDE_REQUEST(state, id) {
      if (!id) return;
      state.footerHideRequests = state.footerHideRequests.filter((x) => x !== id);
    },
  },

  actions: {

    async getDados({ commit }) {

      let api = '';
      var dados = await Menu.montarMenu(localStorage.cd_empresa, localStorage.cd_menu, localStorage.cd_api);
      api = dados.nm_identificacao_api;
      localStorage.cd_parametro = 4;
      let sParametroApi = dados.nm_api_parametro;
      let dataSourceConfig = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        api,
        sParametroApi
      )

      commit('setDados', dataSourceConfig);

    },


    getOperadorDisponivel({ commit }) {
      commit('getOperadorDisponivel', disponivel);
    },

    async loadOperador({ commit }) {

      let api = '';

      var dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 570);

      api = dados.nm_identificacao_api;

      let sParametroApi = dados.nm_api_parametro

      let operadores = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        api,
        sParametroApi
      )

      commit('SET_OPERADOR', operadores)
    },
    addFooterHideRequest({ commit }, id) {
      commit("ADD_FOOTER_HIDE_REQUEST", id);
    },
    removeFooterHideRequest({ commit }, id) {
      commit("REMOVE_FOOTER_HIDE_REQUEST", id);
    }
  },
  getters: {
    allDados: (state) => {
      return state.dataSourceConfig
    },
    footerVisible: (state) => {
      return state.footerHideRequests.length === 0;
    }
  },
  setter: {

  }
})
