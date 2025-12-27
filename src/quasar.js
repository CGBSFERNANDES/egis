import Vue from 'vue'

import 'quasar/dist/quasar.css'
import lang from 'quasar/lang/pt-br.js'
import '@quasar/extras/roboto-font/roboto-font.css'
import '@quasar/extras/material-icons/material-icons.css'
import '@quasar/extras/fontawesome-v5/fontawesome-v5.css'
import { Quasar, AppFullscreen, Notify } from 'quasar'

Vue.use(Quasar, {
  plugins: {
    AppFullscreen,
    Notify
  },
  config: {
  },
  lang: lang
})