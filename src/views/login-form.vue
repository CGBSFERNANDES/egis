<template>
  <div class="login-page">
    <div class="login-card">
      <div class="brand">
        <div class="brand-name">EGIS</div>
        <div class="brand-subtitle">2026 começa agora, Conecte-se ao que vem por aí...</div>
      </div>

      <q-input
        class="field"
        autofocus
        v-model.trim="login"
        type="text"
        label="Usuário ou e-mail"
        @keyup.enter="onLoginClick()"
        outlined
      />

      <q-input
        class="field"
        v-model="password"
        :type="isPwd ? 'password' : 'text'"
        label="Senha"
        @keyup.enter="onLoginClick()"
        outlined
        autocomplete="new-password"

      >
        <template v-slot:append>
          <q-btn
            round
            flat
            class="eye-btn"
            @click="isPwd = !isPwd"
            :icon="isPwd ? 'visibility_off' : 'visibility'"
          />
        </template>
      </q-input>

      <div class="row items-center justify-between q-mt-xs q-mb-md">
        <q-checkbox v-model="rememberUser" label="Lembrar usuário" />
        <a class="link" @click.prevent="onEsqueciSenha()">Esqueci minha senha</a>
      </div>

      <q-btn
        rounded
        class="btn-primary full-width"
        label="Entrar"
        :loading="load_login"
        @click="onLoginClick()"
        unelevated
      />

      <q-btn
        rounded
        class="btn-secondary full-width q-mt-sm"
        label="Registre-se"
        outline
        @click="onRegistroClick()"
      />

      <div class="divider"></div>

      <div class="footer">
        <div class="footer-text">Gestão inteligente para um novo tempo, com energia e propósito.</div>
        <div class="store-links row justify-center q-gutter-md">
          <a href="https://apps.apple.com/nz/app/egismob/id6470312463" target="_blank">
            <img class="store-icon" :src="imagemApple" alt="Apple" />
          </a>
          <a
            href="https://play.google.com/store/apps/details?id=com.carlos.c.fernandes.EgisMob&hl=pt_BR&pli=1"
            target="_blank"
          >
            <img class="store-icon store-icon--android" :src="imagemAndroid" alt="Android" />
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import auth from '../auth'
import validaDestinatario from '../http/destinatario'
import validaLogin from '../http/validaLogin'
import formataData from '../http/formataData'
import funcao from '../http/funcoes-padroes'
import notify from 'devextreme/ui/notify'

let dlogin = {}
let dDestinatario = {}

export default {
  name: 'LoginFormBusiness',

  data () {
    return {
      imagemApple: require('../../public/ios.png'),
      imagemAndroid: require('../../public/android-Photoroom.png'),
      load_login: false,
      login: '',
      password: '',
      isPwd: true,
      rememberUser: false
    }
  },

  async created () {
    // cor principal (laranja EGIS)
    document.documentElement.style.setProperty('--egis-orange', '#ff6a00')
    document.documentElement.style.setProperty('--egis-orange-2', '#ff8533')

    // lembrar SOMENTE o login (nunca senha)
    this.login = localStorage.getItem('login') || ''
    this.rememberUser = localStorage.getItem('rememberUser') === 'true'

    // limpar qualquer sobra antiga de senha (migração segura)
    localStorage.removeItem('password')

    // se você precisa limpar estado do app, faça sem apagar o remember
    await this.LimpaStorageSemCredenciais()

    await funcao.sleep(1)
  },

  methods: {
    async LimpaStorageSemCredenciais () {
      // mantém login/rememberUser; zera o resto do “estado global”
      const keepLogin = localStorage.getItem('login')
      const keepRemember = localStorage.getItem('rememberUser')

      // aqui você pode continuar limpando os campos que já limpava, mas SEM mexer em senha
      localStorage.usuario = ''
      localStorage.cd_empresa = 0
      localStorage.cd_tipo_destinatario = 0
      localStorage.cd_destinatario = 0
      localStorage.nm_destinatario = ''
      localStorage.empresa = ''
      localStorage.fantasia = ''
      localStorage.email = ''
      localStorage.cd_modulo = 0
      localStorage.cd_usuario = 0
      localStorage.ic_etapa_processo = 'N'
      localStorage.vb_imagem64 = ''
      localStorage.nm_caminho_imagem = ''
      localStorage.polling = 0
      localStorage.token = ''

      // restaura o remember
      if (keepLogin) localStorage.setItem('login', keepLogin)
      if (keepRemember !== null) localStorage.setItem('rememberUser', keepRemember)
    },

    onRegistroClick () {
      this.$router.push(this.$route.query.redirect || '/registro')
    },

    onEsqueciSenha () {
      // ajuste para sua rota real (ou abra modal)
      //this.$router.push(this.$route.query.redirect || '/esqueci-senha')
       this.$router.push({ name: 'esqueci-senha' })
    },

    async onLoginClick (e) {
      if (!this.login || !this.password) {
        notify({ message: 'Login e senha são obrigatórios!', type: 'error' })
        return
      }

      this.load_login = true

      notify('Efetuando login, por favor aguarde...')

      try {
        // lembrar apenas o login
        
        localStorage.setItem('cd_cliente',0);

        if (this.rememberUser) {
          localStorage.setItem('login', this.login)
          localStorage.setItem('rememberUser', 'true')
        } else {
          localStorage.removeItem('login')
          localStorage.setItem('rememberUser', 'false')
        }

        // MIGRAÇÃO: garantir que não existe senha persistida
        localStorage.removeItem('password')

        // datas padrão (mantive teu padrão)
        const date = new Date()
        
        localStorage.dt_inicial = await formataData.formataDataSQL(
          new Date(date.getFullYear(), date.getMonth(), 1).toLocaleDateString('pt-br')
        )
        localStorage.dt_final = await formataData.formataDataSQL(
          new Date(date.getFullYear(), date.getMonth() + 1, 0).toLocaleDateString('pt-br')
        )
        localStorage.cd_ano = date.getFullYear()

        // login
        const payload = {
          nm_fantasia_usuario: this.login,
          cd_senha_usuario: this.password
        }

        const result = await validaLogin.validar(payload)
        dlogin = result[0]

        console.log('dados do login', dlogin);

        // IMPORTANTÍSSIMO: não gravar senha retornada
        // localStorage.password = dlogin.cd_senha_acesso  // ❌ NUNCA MAIS

        // validação mantém como está hoje (até você ajustar o back-end)
        const userLogin = this.login.toUpperCase()
        const userPassword = this.password.toUpperCase()

        const ok =
          (dlogin.nm_fantasia_usuario === userLogin && dlogin.cd_senha_acesso === userPassword) ||
          (dlogin.nm_usuario_email === userLogin && dlogin.cd_senha_acesso === userPassword) ||
          (dlogin.nm_usuario_email?.toUpperCase?.() === userLogin &&
            dlogin.cd_senha_acesso?.toUpperCase?.() === userPassword)

        if (!ok) {
          notify('Usuário ou senha inválidos!', 'error', 2000)
          this.password = ''
          this.load_login = false
          return
        }

        // storage (mantive teu fluxo atual, SEM senha)
        localStorage.usuario = dlogin.nm_fantasia_usuario
        localStorage.cd_empresa = dlogin.cd_empresa
        localStorage.cd_tipo_destinatario = dlogin.cd_tipo_destinatario
        localStorage.cd_destinatario = dlogin.cd_destinatario
        localStorage.empresa = dlogin.nm_empresa
        localStorage.fantasia = dlogin.nm_fantasia_empresa
        localStorage.email = dlogin.nm_usuario_email
        localStorage.cd_modulo = dlogin.cd_modulo
        localStorage.cd_cliente = 0 
        localStorage.cd_usuario = dlogin.cd_usuario
        localStorage.ic_etapa_processo = dlogin.ic_etapa_processo
        localStorage.cd_cliente = dlogin.cd_cliente || localStorage.cd_cliente || 0
        localStorage.cd_contato = dlogin.cd_contato
        localStorage.cd_fornecedor = dlogin.cd_fornecedor
        localStorage.cd_api = dlogin.cd_api
        localStorage.cd_home = dlogin.cd_api
        localStorage.nm_modulo = dlogin.nm_modulo
        localStorage.nm_caminho_logo_empresa = dlogin.nm_caminho_logo_empresa
        localStorage.vb_imagem64 = dlogin.vb_base64
        localStorage.dt_nascimento_usuario = dlogin.dt_nascimento_usuario
        localStorage.nm_identificacao_rota = dlogin.nm_identificacao_rota
        localStorage.ic_plano_armazenamento_ftp = dlogin.ic_plano_armazenamento_ftp
        localStorage.nm_ftp_empresa = dlogin.nm_ftp_empresa
        localStorage.nm_banco_empresa = dlogin.nm_banco_empresa
        localStorage.nm_video_modulo = dlogin.nm_video_modulo
        localStorage.nm_caminho_imagem = dlogin.nm_caminho_imagem

        // destinatário (mantive)

        if (dlogin.cd_destinatario > 0) {
          dDestinatario = await validaDestinatario.getDestinatario(
            dlogin.cd_empresa,
            dlogin.cd_tipo_destinatario,
            dlogin.cd_destinatario
          )
          localStorage.nm_destinatario = dDestinatario?.[0]?.nm_fantasia || ''
        }

        this.$store._mutations.SET_Usuario = dlogin


        // autenticação
        auth.logIn()
        //

         //-----------------------------------------------------------------------------------
          this.$store._mutations.SET_ConfigUsuario = {
            ic_usuario_internet: dlogin.ic_usuario_internet,
            ic_periodo_internet: dlogin.ic_periodo_internet,
            ic_modulo_internet: dlogin.ic_modulo_internet,
            ic_empresa_internet: dlogin.ic_empresa_internet,
            ic_contato_internet: dlogin.ic_contato_internet,
            nm_usuario_imagem: `https://egis-store.com.br/img/perfil/${localStorage.cd_usuario}.jpg`,
            ic_login_painel: dlogin.ic_login_painel,
          }

          this.$store._mutations.SET_avisoModulo = dlogin.avisoModulo
            ? JSON.parse(dlogin.avisoModulo)
            : null
          //Tenta buscar Imagem de Perfil no servidor se não tiver salvo na tabela Usuario_Imagem
          if (!this.$store._mutations.SET_Usuario.nm_caminho_imagem) {
            if (await this.checkImage(this.$store._mutations.SET_ConfigUsuario.nm_usuario_imagem)) {
              this.$store._mutations.SET_Usuario.nm_caminho_imagem =
                this.$store._mutations.SET_ConfigUsuario.nm_usuario_imagem
            } else {
              this.$store._mutations.SET_Usuario.nm_caminho_imagem =
                'data:image/jpeg;base64,' +
                localStorage.vb_imagem64.replace('[{"i":"', '').replace('"}]', '')
            }
          }


        // redireciona
        if (dlogin.ic_login_painel === 'S') {
          this.$router.push({ name: 'selecao-modulo-card' })
        } else if (dlogin.nm_identificacao_rota) {
          this.$router.push({ name: dlogin.nm_identificacao_rota })
        } else {
          this.$router.push({ name: 'home' })
        }

        // limpa senha da memória
        
        this.password = ''
        
        e === undefined ? '' : e.validationGroup.reset()


      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error)
        this.password = ''

      } finally {
        this.load_login = false
      }
    }
  }
}
</script>

<style lang="scss" scoped>
/* ========= Brand colors ========= */
:root {
  --egis-orange: #fb8c00;      // deep-orange-6 (aprox)
  --egis-orange-2: #ffb74d;    // um highlight mais suave
  --egis-purple: #5e35b1;      // deep-purple-7
}

/* ========= Full screen background ========= */
.login-page {
  position: fixed;
  inset: 0;
  width: 100vw;
  height: 100svh;
  display: grid;
  place-items: center;
  padding: 16px;
  overflow: hidden;

  /* Foto corporativa (pessoas/decisão) + overlay */
  background:
    linear-gradient(180deg, rgba(8, 12, 18, 0.86), rgba(8, 12, 18, 0.62)),
    url("https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=2000&q=80")
      center / cover no-repeat;
}

/* ========= Card clean ========= */
.login-card {
  width: 92vw;
  max-width: 520px;
  max-height: 92svh;
  overflow-y: auto;

  padding: 26px 26px 18px;
  border-radius: 22px;

  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(255, 255, 255, 0.55);

  box-shadow:
    0 30px 70px rgba(0, 0, 0, 0.45),
    0 2px 0 rgba(255, 255, 255, 0.65) inset;

  backdrop-filter: blur(6px);
}

/* ========= Brand header ========= */
.brand {
  text-align: center;
  margin-bottom: 18px;
}

.brand-name {
  font-size: 40px;
  font-weight: 900;
  letter-spacing: 1px;
  color: var(--egis-orange);
  line-height: 1;
}

.brand-subtitle {
  margin-top: 8px;
  color: rgba(20, 25, 35, 0.78);
  font-weight: 600;
}

/* ========= Inputs ========= */
.field {
  margin: 12px 0;
}

/* deixa o ícone “olho” neutro */
.eye-btn {
  color: rgba(20, 25, 35, 0.65) !important;
}

/* ========= Buttons ========= */
.btn-primary {
  height: 50px;
  border-radius: 16px;
  font-weight: 800;
  letter-spacing: 0.4px;

  background: linear-gradient(135deg, var(--egis-orange), var(--egis-orange-2)) !important;
  color: #fff !important;
}

.btn-secondary {
  height: 46px;
  border-radius: 16px;
  font-weight: 700;
  color: rgba(20, 25, 35, 0.9) !important;
  border-color: rgba(20, 25, 35, 0.25) !important;
}

/* ========= Link ========= */
.link {
  font-size: 0.95rem;
    color: rgba(94, 53, 177, 0.92);
  text-decoration: underline;
  cursor: pointer;

  &:hover {
    color: rgba(20, 25, 35, 0.92);
     text-decoration: underline;
  }
}

/* ========= Footer ========= */
.divider {
  margin: 16px 0 12px;
  height: 1px;
  background: rgba(20, 25, 35, 0.10);
}

.footer-text {
  text-align: center;
  color: rgba(20, 25, 35, 0.70);
  font-weight: 700;
  margin-bottom: 10px;
}

.store-icon {
  width: 34px;
  height: 34px;
  opacity: 0.9;
}
.store-icon--android {
  width: 38px;
  height: 38px;
}

/* ========= Quasar: inputs clean ========= */
:deep(.q-field__control) {
  background: rgba(243, 247, 255, 1) !important;
  border-radius: 22px !important;     // <-- mais round
  padding: 4px 6px;
}

/* Label e texto mais “produto” */
:deep(.q-field__label) {
  color: rgba(20, 25, 35, 0.62) !important;
  font-weight: 600;
}

:deep(.q-field__native),
:deep(.q-field__input) {
  color: rgba(20, 25, 35, 0.95) !important;
}

:deep(.q-field--outlined .q-field__control:before) {
  border-color: rgba(25, 30, 40, 0.18) !important;
  border-radius: 22px !important;
}



/* Foco com deep-purple-7 */
:deep(.q-field--outlined.q-field--focused .q-field__control:before) {
  border-color: rgba(94, 53, 177, 0.55) !important;  // deep-purple-7
}

/* Checkbox laranja */
:deep(.q-checkbox__inner--truthy) {
  color: var(--egis-orange) !important;
}

/* ========= Mobile tweaks ========= */
@media (max-width: 420px) {
  .login-card {
    padding: 20px 18px 14px;
    border-radius: 18px;
    max-height: 90svh;
  }

  .brand-name {
    font-size: 34px;
  }
}

@media (max-height: 700px) {
  .login-card {
    max-height: 86svh;
  }
}

/* Remove o azul do autofill (Chrome/Edge/Safari) */
:deep(input:-webkit-autofill),
:deep(textarea:-webkit-autofill),
:deep(select:-webkit-autofill) {
  -webkit-text-fill-color: rgba(20, 25, 35, 0.95) !important;
  transition: background-color 9999s ease-in-out 0s;
  box-shadow: 0 0 0px 1000px rgba(243, 247, 255, 1) inset !important; /* seu fundo claro */
  border-radius: 22px !important; /* mantém round */
}

/* Firefox (algumas versões usam isso) */
:deep(input:autofill) {
  box-shadow: 0 0 0px 1000px rgba(243, 247, 255, 1) inset !important;
}


</style>
