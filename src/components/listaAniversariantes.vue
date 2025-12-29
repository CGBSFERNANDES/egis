<template>
  <div class="lista-aniversariantes q-pa-md">
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
        <span>Aniversariantes</span>

        <q-space />

        <q-btn
          dense
          rounded
          icon="refresh"
          color="deep-purple-7"
          size="lg"
          class="q-ml-sm"
          @click="carregarAniversariantes"
          :loading="loading"
          :disable="loading"
        >
          <q-tooltip>Atualizar</q-tooltip>
        </q-btn>
      </h2>
    </div>

    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-12 col-md-6">
        <q-input dense outlined v-model="filtro" placeholder="Buscar aniversariante..." clearable>
          <template v-slot:prepend>
            <q-icon name="search" />
          </template>
        </q-input>
      </div>

      <div class="col-12 col-md-6">
        <q-banner dense class="bg-grey-2 text-grey-9 rounded-borders">
          <div class="text-caption">
            Empresa: <b>{{ cd_empresa }}</b>
            <span v-if="empresaAtualNome"> | <b>{{ empresaAtualNome }}</b> </span>
            <span class="q-ml-sm"> | Usuário logado: <b>{{ cd_usuario }}</b> </span>
            <span class="q-ml-sm">
              | Período:
              <b>{{ dtInicial }}</b>
              até
              <b>{{ dtFinal }}</b>
            </span>
            <span class="q-ml-sm"> | Total: <b>{{ aniversariantes.length }}</b> </span>
          </div>
        </q-banner>
      </div>
    </div>

    <q-inner-loading :showing="loading">
      <q-spinner size="50px" />
    </q-inner-loading>

    <div v-if="!loading && aniversariantesFiltrados.length === 0" class="q-mt-md">
      <q-banner class="bg-orange-1 text-orange-10 rounded-borders">
        Nenhum aniversariante encontrado.
      </q-banner>
    </div>

    <div class="row q-col-gutter-md q-mt-sm">
      <div
        v-for="(u, idx) in aniversariantesFiltrados"
        :key="idx"
        class="col-12 col-sm-6 col-md-4 col-lg-3"
      >
        <q-card class="cursor-pointer card-hover card-aniversariante" @click="selecionarUsuario(u)">
          <q-card-section class="text-center">
            <div class="row justify-center q-mb-sm">
              <q-avatar size="86px" class="avatar-shadow">
                <img
                  v-if="fotoUsuario(u)"
                  :src="fotoUsuario(u)"
                  alt="Foto do usuário"
                  class="foto-rounded"
                  @error="onImgError(u)"
                />
                <div v-else class="fallback-avatar">
                  {{ letraUsuario(u) }}
                </div>
              </q-avatar>
            </div>

            <div class="text-subtitle1 text-weight-bold">
              {{ nomeUsuario(u) || 'Usuário' }}
            </div>

            <div class="text-caption text-grey-7 q-mt-xs">
              Login: <b>{{ fantasiaUsuario(u) || '-' }}</b>
            </div>

            <div class="text-caption text-grey-7 q-mt-xs">
              Departamento: <b>{{ departamentoUsuario(u) || '-' }}</b>
            </div>

            <div class="text-caption text-grey-7 q-mt-xs">
              Código: <b>{{ codigoUsuario(u) ? codigoUsuario(u) : '-' }}</b>
            </div>

            <div class="text-caption text-grey-7 q-mt-xs">
              Aniversário: <b>{{ dataAniversario(u) || '-' }}</b>
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

const api = axios.create({
  baseURL: 'https://egiserp.com.br/api',
  withCredentials: true,
  timeout: 60000,
})

api.interceptors.request.use((cfg) => {
  const banco = localStorage.nm_banco_empresa || ''
  if (banco) cfg.headers['x-banco'] = banco
  cfg.headers['Authorization'] = 'Bearer superchave123'
  if (!cfg.headers['Content-Type']) cfg.headers['Content-Type'] = 'application/json'
  return cfg
})

export default {
  name: 'listaAniversariantes',

  data() {
    return {
      aniversariantes: [],
      loading: false,
      headerBanco: localStorage.nm_banco_empresa || '',
      imgFalhou: {},
      filtro: '',
      cd_usuario: Number(localStorage.cd_usuario || 0),
      cd_empresa: Number(localStorage.cd_empresa || 0),
      empresaAtualNome: localStorage.fantasia || localStorage.nm_fantasia_empresa || '',
    }
  },

  computed: {
    dtInicial() {
      return localStorage.dt_inicial || '01/01/2025'
    },
    dtFinal() {
      return localStorage.dt_final || '12/31/2025'
    },
    aniversariantesFiltrados() {
      const f = (this.filtro || '').trim().toLowerCase()
      if (!f) return this.aniversariantes

      return this.aniversariantes.filter((u) => {
        const nome = String(this.nomeUsuario(u) || '').toLowerCase()
        const login = String(this.fantasiaUsuario(u) || '').toLowerCase()
        const depto = String(this.departamentoUsuario(u) || '').toLowerCase()
        const data = String(this.dataAniversario(u) || '').toLowerCase()
        return (
          nome.indexOf(f) >= 0 || login.indexOf(f) >= 0 || depto.indexOf(f) >= 0 || data.indexOf(f) >= 0
        )
      })
    },
  },

  created() {
    this.carregarAniversariantes()
  },

  methods: {
    pickCI(obj, keys) {
      if (!obj) return null
      const map = {}
      Object.keys(obj).forEach((k) => {
        map[k.toLowerCase()] = k
      })
      for (let i = 0; i < keys.length; i++) {
        const kk = String(keys[i]).toLowerCase()
        const real = map[kk]
        if (real) return obj[real]
      }
      return null
    },

    codigoUsuario(u) {
      return this.pickCI(u, ['cd_usuario', 'codigo_usuario', 'cd_usuario_empresa'])
    },

    nomeUsuario(u) {
      return this.pickCI(u, [
        'nm_usuario',
        'nm_nome',
        'nm_nome_usuario',
        'nm_pessoa',
        'nm_usuario_empresa',
      ])
    },

    fantasiaUsuario(u) {
      return this.pickCI(u, ['nm_fantasia_usuario', 'nm_login', 'nm_fantasia', 'login'])
    },

    departamentoUsuario(u) {
      return this.pickCI(u, ['nm_departamento', 'nm_setor', 'nm_departamento_usuario'])
    },

    fotoUsuario(u) {
      const cd = this.codigoUsuario(u)
      const url = this.pickCI(u, ['nm_caminho_imagem', 'nm_foto', 'url_foto'])
      if (cd && this.imgFalhou[String(cd)]) return ''

      if (!url) return ''
      const clean = String(url).trim()
      if (!clean) return ''
      return clean
    },

    letraUsuario(u) {
      const n = String(this.nomeUsuario(u) || this.fantasiaUsuario(u) || 'U').trim()
      return (n[0] || 'U').toUpperCase()
    },

    dataAniversario(u) {
      const raw = this.pickCI(u, [
        'dt_aniversario',
        'dt_nascimento',
        'dt_aniversario_usuario',
        'dt_nasc_usuario',
        'dt_aniversario_user',
        'dt_aniversario_cliente',
        'dt_aniversario_pessoa',
      ])
      return this.formatarData(raw)
    },

    formatarData(v) {
      if (!v) return ''
      if (typeof v === 'string') {
        const clean = v.split('T')[0]
        if (clean.includes('-')) {
          const [ano, mes, dia] = clean.split('-')
          return `${String(dia).padStart(2, '0')}/${String(mes).padStart(2, '0')}/${ano}`
        }
        const partes = clean.split('/')
        if (partes.length === 3) {
          const [dia, mes, ano] = partes
          return `${String(dia).padStart(2, '0')}/${String(mes).padStart(2, '0')}/${ano}`
        }
      }
      const d = new Date(v)
      if (!Number.isNaN(d.getTime())) {
        const dia = String(d.getDate()).padStart(2, '0')
        const mes = String(d.getMonth() + 1).padStart(2, '0')
        const ano = d.getFullYear()
        return `${dia}/${mes}/${ano}`
      }
      return String(v)
    },

    onImgError(u) {
      const cd = this.codigoUsuario(u)
      if (cd) this.$set(this.imgFalhou, String(cd), true)
    },

    selecionarUsuario(u) {
      const cd = this.codigoUsuario(u)
      const nm = this.nomeUsuario(u) || this.fantasiaUsuario(u)
      const login = this.fantasiaUsuario(u) || this.nomeUsuario(u)

      localStorage.cd_usuario_selecionado = cd !== null && cd !== undefined ? cd : ''
      localStorage.nm_usuario_selecionado = nm !== null && nm !== undefined ? nm : ''
      localStorage.nm_fantasia_usuario_selecionado =
        login !== null && login !== undefined ? login : ''
    },

    async carregarAniversariantes() {
      this.loading = true
      try {
        const body = [
          {
            ic_json_parametro: 'S',
            cd_parametro: 200,
            dt_inicial: this.dtInicial,
            dt_final: this.dtFinal,
          },
        ]

        const cfg = this.headerBanco ? { headers: { 'x-banco': this.headerBanco } } : undefined
        const resp = await api.post('/exec/pr_egis_admin_processo_modulo', body, cfg)

        if (resp && typeof resp.data === 'string') {
          throw new Error('Sessão inválida (API retornou HTML/login).')
        }

        let rows = resp && resp.data ? resp.data : []
        if (rows && rows.dados) rows = rows.dados
        if (!Array.isArray(rows)) rows = rows ? [rows] : []

        this.aniversariantes = rows
      } catch (e) {
        console.error('[listaAniversariantes] erro:', e)
        this.aniversariantes = []

        if (this.$q && this.$q.notify) {
          this.$q.notify({
            type: 'negative',
            message: 'Erro ao carregar aniversariantes. Veja o console.',
          })
        }
      } finally {
        this.loading = false
      }
    },

    onVoltar() {
      if (this.$router) {
        this.$router.push({ name: 'home' }).catch(() => {
          this.$router.push({ path: '/' }).catch(() => {})
        })
      } else {
        window.location.href = '/'
      }
    },
  },
}
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

.card-aniversariante {
  border-radius: 16px;
}

.foto-rounded {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 999px;
}

.fallback-avatar {
  width: 100%;
  height: 100%;
  border-radius: 999px;
  background: #512da8;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 26px;
}

.avatar-shadow {
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.18);
}

.card-hover {
  border-radius: 18px;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card-hover:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.18);
}
</style>
