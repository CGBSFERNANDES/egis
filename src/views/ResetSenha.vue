<template>
  <div class="recover-page">
    <div class="recover-card">
      <div class="title">Nova senha</div>
      <div class="subtitle">Defina sua nova senha para continuar.</div>

      <q-input outlined v-model="novaSenha" type="password" label="Nova senha" class="q-mt-md" />
      <q-input outlined v-model="confirmacao" type="password" label="Confirmar senha" class="q-mt-sm" />

      <q-btn
        class="btn-primary full-width q-mt-md"
        label="Salvar nova senha"
        :loading="loading"
        unelevated
        rounded
        @click="salvar"
      />

      <div class="q-mt-md text-center">
        <a class="link" @click.prevent="voltar()">← Voltar ao login</a>
      </div>

    </div>
  </div>
</template>

<script>
import api from "@/boot/axios"


export default {
  name: 'ResetSenha',
  data () {
    return { novaSenha: '', confirmacao: '', loading: false,
      token: '',
      senha: '',
      senha2: '',
    }
  },
  computed: {
    ztoken () {
      return this.$route.query.token || '';
    }
  },
  async created () {
    this.token = this.$route.query.token || ''
    console.log('TOKEN NA URL:', this.$route.query.token)
     // (opcional) validar token antes de liberar a tela
    if (this.token) {
      try {
        const { data } = await api.get('/auth/password/reset/validate', {
          params: { token: this.token }
        })
        if (!data?.valid) {
          this.$q.notify({ type: 'negative', position: 'center', message: 'Token inválido ou expirado.' })
        //  this.$router.push({ name: 'login-form' })
        }
      } catch (e) {
        // se der erro no validate, deixa tentar salvar mesmo
      }
    }

  },

  methods: {
    voltar () {
      this.$router.push({ path: '/' })
    },

    async salvar () {
      if (!this.token) {
        this.$q.notify({ type: 'negative', position: 'center', message: 'Token inválido.' })
        return
      }
      if (!this.novaSenha || this.novaSenha.length < 4) {
        this.$q.notify({ type: 'warning',  position: 'center', message: 'Informe uma senha válida.' })
        return
      }
      if (this.novaSenha !== this.confirmacao) {
        this.$q.notify({ type: 'warning',  position: 'center', message: 'As senhas não conferem.' })
        return
      }

      this.loading = true
      
      try {
        //await api.post('/auth/password/reset', { token: this.token, novaSenha: this.novaSenha })
   
        const { data } = await api.post('/auth/password/reset', {
          token: this.token,
          senha: this.novaSenha
        })

          this.$q.notify({
          type: 'positive',
          position: 'center',
          message: data?.message || 'Senha alterada com sucesso.'
        })


        //this.$q.notify({ type: 'positive',  position: 'center', message: 'Senha atualizada com sucesso.' })
        this.$router.push({ path: '/' })
        //

      } catch (e) {
       // console.error(e?.response?.status, e?.response?.data || e?.message)
       // this.$q.notify({ type: 'negative',  position: 'center', message: 'Token inválido/expirado ou erro ao salvar.' })
      
    console.error('RESET ERROR:', e?.response?.status, e?.response?.data || e?.message)

        // pra ficar mais claro na tela:
        const msg =
          e?.response?.data?.message ||
          e?.response?.data?.erro ||
          e?.message ||
          'Falha ao salvar.'

        this.$q.notify({ type: 'negative', position: 'center', message: msg })
 
    
    } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped lang="scss">
.recover-page { position: fixed; inset: 0; display: grid; place-items: center; padding: 16px; background: #fff; }
.recover-card { width: 92vw; max-width: 560px; padding: 28px 22px; border-radius: 26px; background: #fff;
  box-shadow: 0 24px 70px rgba(0,0,0,.12); border: 1px solid rgba(10,14,22,.06); }
.title { font-size: 34px; font-weight: 900; color: #5e35b1; text-align: center; }
.subtitle { margin-top: 10px; color: rgba(20,25,35,.68); font-weight: 600; text-align: center; }
.btn-primary { height: 52px; border-radius: 18px; font-weight: 800; background: #fb8c00 !important; color: #fff !important; }
.link { color: #5e35b1; font-weight: 700; cursor: pointer; }
.link:hover { text-decoration: underline; }
</style>
