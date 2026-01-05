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

    async LimpaStorage() {
      localStorage.usuario = ''
      localStorage.cd_empresa = 0
      localStorage.cd_tipo_destinatario = 0
      localStorage.cd_destinatario = 0
      localStorage.nm_destinatario = ''
      localStorage.empresa = ''
      localStorage.fantasia = ''
      localStorage.email = ''
      localStorage.cd_modulo = 0
      localStorage.cd_cep = 0
      localStorage.ic_etapa_processo = 'N'
      localStorage.cd_menu = 0
      localStorage.cd_usuario = 0
      localStorage.cd_cliente = 0
      localStorage.cd_contato = 0
      localStorage.cd_fornecedor = 0
      localStorage.cd_api = 0
      localStorage.cd_tipo_consulta = 0
      localStorage.dt_base = new Date().toLocaleDateString()
      localStorage.cd_identificacao = 0
      localStorage.nm_documento = ''
      localStorage.ds_parametro = ''
      localStorage.cd_modulo_selecao = 0
      localStorage.nm_modulo = ''
      localStorage.ic_etapa_processo = 'N'
      localStorage.password = ''
      localStorage.nm_pesquisa = ''
      localStorage.polling = 0
      localStorage.vb_imagem64 = ''
      localStorage.nm_json = ''
      localStorage.cd_documento = 0
      localStorage.cd_item_documento = 0
      localStorage.cd_tipo_documento = 0
      localStorage.cd_etapa = 0
      localStorage.cd_etapa_origem = 0
      localStorage.cd_etapa_destino = 0
      localStorage.cd_empresa_fat = 0
      localStorage.cd_entregador = 0
      localStorage.qt_ordem = 0
      localStorage.cd_tipo_parametro = 0
      localStorage.cd_tipo_email = 0
      localStorage.cd_relatorio = 0
      localStorage.cd_form = 0
      localStorage.cd_form_capa = 0
      localStorage.cd_comanda = 0
      localStorage.cd_tabela_preco = 0
      localStorage.ic_plano_armazenamento_ftp = 'N'
      localStorage.nm_ftp_empresa = ''
      localStorage.nm_banco_empresa = ''
    },
    
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
        
        localStorage.setItem('cd_cliente',0)
        localStorage.setItem('cd_usuario',0)

        //

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

        //console.log('dados do login', dlogin);

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
        localStorage.cd_usuario = dlogin.cd_usuario
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

        //Imagem Padrão

          if (dlogin.vb_base64 == null) {
            localStorage.vb_imagem64 =
              '[{"i":"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"}]'
          } else {
            localStorage.vb_imagem64.replace('[{"i":"', '').replace('"}]', '')
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
    },

    
    checkImage(url) {
      return new Promise((resolve) => {
        const img = new Image()
        img.onload = () => resolve(true)
        img.onerror = () => resolve(false)
        img.src = url
      })
    },
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
