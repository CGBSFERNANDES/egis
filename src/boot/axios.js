// src/boot/axios.js
import Vue from "vue";
import axios from "axios";

function getBaseURL () {
  // prioridade: storage -> env -> default
  const fromStorage = (localStorage.getItem('API_BASE') || '').trim()
  const fromEnv = (process.env.VUE_APP_API_BASE || '').trim();
  return (fromStorage || fromEnv || 'https://egisnet.com.br/api').replace(/\/+$/, '')
}

// instância global (axios)
axios.defaults.baseURL = getBaseURL()
axios.defaults.withCredentials = false
axios.defaults.timeout = 60000  


// -------- instância local (segue como você usa hoje) --------
const api = axios.create({
 // baseURL: '/',     // ajuste se precisar
  baseURL: getBaseURL(), // <<< AGORA APONTA PARA /api
  withCredentials: false,
  timeout: 60000
});

// helper p/ montar url final (evita 404 em :8080/<n>)
function absUrl (url) {
  if (!url) return url
  // se já for absoluta, retorna como está
  if (/^https?:\/\//i.test(url)) return url
  // garante barra única entre base e path
  return `${api.defaults.baseURL}/${String(url).replace(/^\/+/, '')}`
}

// -------- Request interceptor (api + global) --------

function onRequest(config) {
  // normaliza URL relativa quando vier algo como "685/1025/..."
  if (config && config.url && !/^https?:\/\//i.test(config.url)) {
    config.url = config.url.replace(/^\/+/, ''); // sem barra inicial
  }
  config.url = absUrl(config.url); // torna absoluta

  // custom header p/ identificar o banco (se houver)
  const banco = (localStorage.getItem('nm_banco_empresa') || '').trim();
  if (banco) config.headers['x-banco'] = banco;

  // só manda Authorization se existir token (evita 500 em endpoints que não esperam)
  const token = localStorage.getItem('auth_token') || 'superchave123';
  //console.log('token-->', token);
  //if (token)
  config.headers.Authorization = `Bearer ${token}`;

  // JSON por padrão
  if (!config.headers['Content-Type']) {
    config.headers['Content-Type'] = 'application/json';
  }
  //console.log('Authorization header:', config.headers.Authorization);

  //console.log('config axios headers: ', config);

  return config;

  //
}

api.interceptors.request.use(onRequest)
axios.interceptors.request.use(onRequest) // <— GLOBAL

// -------- Response interceptor (api + global) --------
function onResponseError(err) {
  const status = err?.response?.status
  // Mostra notificação global quando der 5xx ou quando não houver resposta (timeout/network)
  if ((status && status >= 500) || !status) {
    if (Vue.prototype.$q) {
      Vue.prototype.$q.notify({
        type: 'negative',
        message: 'Erro no servidor. Tente novamente em instantes.',
        timeout: 3000,
      })
    } else {
      console.error('Erro no servidor:', err)
      // fallback simples
      // alert('Erro no servidor. Tente novamente.')
    }
  }
  // 401/403: opcional redirecionar para login
  // if (status === 401 || status === 403) { ... }
  return Promise.reject(err)
}

api.interceptors.response.use(r => r, onResponseError)
axios.interceptors.response.use(r => r, onResponseError) // <— GLOBAL

export { api }
export default api
// Agora você pode usar `import { api } from 'src/boot/axios'`
// ou `import axios from 'axios'` (global)