import "devextreme/dist/css/dx.common.css";
import "./themes/generated/theme.base.css";
import "./themes/generated/theme.additional.css";

import Vue from "vue";
import App from "./App";
import router from "./router";
import appInfo from "./app-info";
import "./registerServiceWorker";
import "./quasar";
import store from "./store";
import * as VueGoogleMaps from "vue2-google-maps";
import VueGeolocation from "vue-browser-geolocation";
import Localbase from "localbase";
import './boot/axios';

let db = new Localbase("db");

window.addEventListener("message", (event) => {
  // Hot reload manda strings tipo "webpackHotUpdate..."
  // Não tenta tratar isso como JSON
  if (typeof event.data !== "string") return;

  const s = event.data.trim();

  // Só deixa passar se "parece" JSON
  if (!s.startsWith("{") && !s.startsWith("[")) return;

  // Se alguém for fazer parse em algum lugar, não estoura
  try {
    JSON.parse(s);
  } catch (e) {
    return;
  }
});
// ---- FIM 

//npm i vue2-google-maps

Vue.config.productionTip = false;
Vue.prototype.$appInfo = appInfo;

Vue.use(VueGoogleMaps, {
  load: {
    key: VUE_APP_GOOGLE_API_KEY,
    //key: VUE_APP_GOOGLE_API_KEY,
    //
    libraries: 'places',
  },
})

Vue.use(VueGeolocation);

new Vue({
  router,
  store,
  render: (h) => h(App),
}).$mount("#app");
