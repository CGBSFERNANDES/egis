<template>
  <div class="recover-page">
    <div class="recover-card">
      <div class="title">Recuperar Senha</div>
      <div class="subtitle">
        Informe seu e-mail ou usuário para receber o link de redefinição.
      </div>

      <q-input
        outlined
        v-model.trim="identificador"
        label="E-mail ou Usuário"
        class="q-mt-md"
        @keyup.enter="enviar"
      />

      <q-btn
        class="btn-primary full-width q-mt-md"
        label="Enviar link de recuperação"
        :loading="loading"
        unelevated
        rounded
        @click="enviar"
      />

      <q-btn
  flat
  class="full-width q-mt-sm"
  label="(teste) Abrir ResetSenha"
  @click="abrirResetTeste"
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
  name: 'EsqueciSenha',
  data () {
    return { identificador: '', loading: false }
  },
  methods: {
    voltar () {
      //this.$router.push({ name: 'login' })
      this.$router.push('/')
      //
    },

    abrirResetTeste () {
  // token fake só pra abrir a tela e validar layout/roteamento
  this.$router.push({ path: '/reset-senha', query: { token: 'TESTE_TOKEN' } })
},

    async enviar () {
      if (!this.identificador) {
        this.$q.notify({ type: 'warning', position: 'center', message: 'Informe e-mail ou usuário.' })
        return
      }

      this.loading = true

      try {
        // seu backend usa /recuperar-senha esperando { usuario }
            console.log('API DEBUG >>>', api)
        console.log('antes do post', this.identificador)
        //await api.post('/recuperar-senha', { usuario: this.identificador })
        await api.post('/auth/password/forgot', { identificador: this.identificador })

        // resposta genérica (boa prática)
        this.$q.notify({
          type: 'positive',
          position: 'center',
          message: 'Se o cadastro existir, enviaremos um link de recuperação.'
        })
        this.identificador = ''

    } catch (e) {
  console.error('RECOVER ERROR:', e?.response?.status, e?.response?.data || e?.message)
  this.$q.notify({
    type: 'negative',
    position: 'center',
    message: `Falha ao enviar (${e?.response?.status || ''})`.trim()
  })
} finally {
    this.loading = false
      }
    }
  }
}
</script>

<style scoped lang="scss">
.recover-page {
  position: fixed;
  inset: 0;
  width: 100vw;
  height: 100svh;
  display: grid;
  place-items: center;
  padding: 16px;
  background: #fff;
  overflow: hidden;
}

/* garante que em telas pequenas o card não “vaze” */
.recover-card {
  width: 92vw;
  max-width: 560px;
  max-height: 92svh;
  overflow: auto;

  padding: 28px 22px 22px;
  border-radius: 26px;
  background: #fff;
  box-shadow: 0 24px 70px rgba(0,0,0,.12);
  border: 1px solid rgba(10, 14, 22, 0.06);
}

.title {
  font-size: 34px;
  font-weight: 900;
  color: #5e35b1; /* deep-purple-7 */
  text-align: center;
  margin-bottom: 6px;
}

.subtitle {
  color: rgba(20,25,35,.68);
  font-weight: 600;
  text-align: center;
  line-height: 1.3;
}

.btn-primary {
  height: 52px;
  border-radius: 18px;
  font-weight: 800;
  background: #fb8c00 !important; /* deep-orange-6 */
  color: #fff !important;
}

.link {
  color: #5e35b1;
  font-weight: 700;
  cursor: pointer;
}
.link:hover { text-decoration: underline; }

/* autofill azul */
:deep(input:-webkit-autofill) {
  -webkit-text-fill-color: rgba(20,25,35,.95) !important;
  transition: background-color 9999s ease-in-out 0s;
  box-shadow: 0 0 0px 1000px rgba(243, 247, 255, 1) inset !important;
  border-radius: 22px !important;
}

/* inputs mais round */
:deep(.q-field__control) {
  background: rgba(243, 247, 255, 1) !important;
  border-radius: 22px !important;
}
:deep(.q-field--outlined .q-field__control:before) {
  border-radius: 22px !important;
}
</style>
