<template>
  <div class="lista-aniversariantes relative-position">
    <div class="row items-center q-mb-sm">
      <div class="text-subtitle1 text-weight-bold">Aniversariantes</div>
      <q-space />
      <q-btn
        size="sm"
        flat
        round
        color="primary"
        icon="refresh"
        @click="carregarAniversariantes"
        :loading="loading"
        :disable="loading"
      >
        <q-tooltip>Atualizar</q-tooltip>
      </q-btn>
    </div>

    <q-inner-loading :showing="loading">
      <q-spinner size="32px" />
    </q-inner-loading>

    <div v-if="!loading && aniversariantes.length === 0" class="texto-vazio">
      Nenhum aniversariante encontrado.
    </div>

    <div v-else class="row q-col-gutter-sm">
      <div v-for="(u, idx) in aniversariantes" :key="idx" class="col-12">
        <q-card class="card-aniversariante">
          <div class="row no-wrap items-center">
            <q-avatar size="56px" class="avatar-shadow q-mr-md">
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

            <div class="col">
              <div class="text-body1 text-weight-bold">
                {{ nomeUsuario(u) || "Usuário" }}
              </div>
              <div class="text-caption text-grey-7">
                {{ fantasiaUsuario(u) || "-" }}
              </div>
              <div v-if="departamentoUsuario(u)" class="text-caption text-grey-6">
                {{ departamentoUsuario(u) }}
              </div>
            </div>

            <div class="text-right data-aniversario">
              <div class="text-caption text-grey-6">Aniversário</div>
              <div class="text-subtitle2 text-weight-bold">
                {{ dataAniversario(u) || "-" }}
              </div>
            </div>
          </div>
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
    }
  },

  computed: {
    dtInicial() {
      return localStorage.dt_inicial || '01/01/2025'
    },
    dtFinal() {
      return localStorage.dt_final || '12/31/2025'
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
      return this.pickCI(u, ['cd_usuario'])
    },

    nomeUsuario(u) {
      return this.pickCI(u, ['nm_usuario'])
    },

    fantasiaUsuario(u) {
      return this.pickCI(u, ['nm_fantasia_usuario'])
    },

    departamentoUsuario(u) {
      return this.pickCI(u, ['nm_departamento'])
    },

    fotoUsuario(u) {
      const cd = this.codigoUsuario(u)
      const url = this.pickCI(u, ['nm_caminho_imagem'])
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
  },
}
</script>

<style scoped>
.lista-aniversariantes {
  min-width: 340px;
}

.card-aniversariante {
  border-radius: 14px;
  padding: 8px 10px;
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.12);
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
  font-size: 20px;
}

.avatar-shadow {
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.14);
}

.texto-vazio {
  color: #666;
  font-size: 12px;
  padding: 8px 4px;
}

.data-aniversario {
  min-width: 96px;
}
</style>
