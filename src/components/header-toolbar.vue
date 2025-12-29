<template>
  <div>
    <header class="header-component">
      <dx-toolbar class="header-toolbar">
        <dx-item :visible="menuToggleEnabled" location="before" css-class="menu-button">
          <!-- eslint-disable vue/no-unused-vars -->
          <dx-button icon="menu" styling-mode="text" @click="toggleMenuFunc" slot-scope="_" />
          <!-- eslint-enable -->
        </dx-item>

        <dx-item v-if="title" location="before" css-class="header-title dx-toolbar-label">
          <!-- eslint-disable vue/no-unused-vars -->
          <div slot-scope="_">
            {{ title }}
            <b> - {{ empresa }} </b>
            <div class="modulo">
              <label>
                {{ modulo }}
                <!-- <q-badge @click="popup()" rounded align="top" color="red" label="Manual"/>-->
              </label>
            </div>
            <div class="modulo" v-if="1 == 0">
              {{ hoje }}
            </div>
          </div>

          <!-- eslint-enable -->
        </dx-item>

        <dx-item v-if="this.celular == 0" class="img" location="before">
          <img v-if="!caminho == ''" class="img" v-bind:src="pegaImg()" alt="" />
        </dx-item>

        <dx-item location="center">
          <div
            class="text-weight-medium dt-storage"
            slot-scope="_"
            @click="popupData = true"
            v-if="data_tela_inicial != '' && data_tela_final != ''"
          >
            <q-badge color="empresa-cor" rounded>
              {{ data_tela_inicial }}
            </q-badge>
            até
            <q-badge color="empresa-cor" rounded>
              {{ data_tela_final }}
            </q-badge>
          </div>

          <div class="text-weight-medium" slot-scope="_" @click="popupData = true" v-else>
            <q-badge color="empresa-cor" rounded> Selecione a Data </q-badge>
          </div>
        </dx-item>

        <dx-item location="after" v-show="qt_suporte > 0">
          <div slot-scope="_">
            <q-btn
              v-show="qt_suporte > 0"
              flat
              dense
              color="cyan-7"
              round
              icon="support_agent"
              class="q-ml-md"
            >
              <q-badge rounded color="cyan-7" floating>{{ qt_suporte }}</q-badge>
              <q-tooltip self="center middle" class="bg-black"> Atendimentos </q-tooltip>
            </q-btn>

            <q-btn-dropdown
              v-if="avisoModulo && avisoModulo.length > 0"
              color="primary"
              rounded
              flat
              icon="notifications"
            >
              <template v-slot:label>
                <q-badge color="red" floating>{{ `${avisoModulo.length}` }}</q-badge>
              </template>
              <q-list>
                <q-item clickable v-close-popup v-for="(aviso, key) in avisoModulo" :key="key">
                  <q-item-section>
                    <q-item-label @click="onClickAviso(aviso)">{{
                      `${aviso.nm_aviso_web_modulo}`
                    }}</q-item-label>
                  </q-item-section>
                </q-item>
              </q-list>
            </q-btn-dropdown>
          </div>
        </dx-item>

        <dx-item location="after">
          <div v-if="qt_financeiro > 0" slot-scope="_">
            <div class="badge">
              <span>
                {{ qt_financeiro }}
              </span>
            </div>

            <DxButton class="btn" icon="fas fa-coins" type="gbs_red" @click="onFinanceiro()">
              <q-tooltip self="center middle" class="bg-black"> Pendências Financeiras </q-tooltip>
            </DxButton>
          </div>
        </dx-item>

        <dx-item location="after">
          <div v-if="qt_atividade > 0" slot-scope="_">
            <div class="badge">
              <span>
                {{ qt_atividade }}
              </span>
            </div>

            <DxButton class="btn" icon="far fa-bell" type="gbs" @click="onAtividade()">
              <q-tooltip self="center middle" class="bg-black"> Atividades </q-tooltip>
            </DxButton>
          </div>
        </dx-item>

        <dx-item location="after">
          <div v-if="qt_informativo > 0" slot-scope="_">
            <div class="badge">
              <span>
                {{ qt_informativo }}
              </span>
            </div>

            <DxButton class="btn" icon="fas fa-info" type="gbs" @click="onInformativo()">
              <q-tooltip self="center middle" class="bg-black"> Informativo </q-tooltip>
            </DxButton>
          </div>
        </dx-item>

        <dx-item location="after">
          <div v-if="qt_mensagem > 0" slot-scope="_">
            <div class="badge">
              <span>
                {{ qt_mensagem }}
              </span>
            </div>

            <DxButton class="btn" icon="far fa-envelope" type="outro" @click="onMensagem()">
              <q-tooltip self="center middle" class="bg-black"> Mensagens </q-tooltip>
            </DxButton>
          </div>
        </dx-item>

        <!-- Sininho: Avisos dos Módulos (antes do user-panel) -->

        <dx-item location="after">
          <div slot-scope="_">
            <q-btn-dropdown
              rounded
              flat
              icon="notifications"
              color="deep-orange-7"
              class="q-ml-md"
              dropdown-icon=""
              content-class="menu-aviso-dropdown"
              :content-style="{ padding: '0', maxHeight: '320px' }"
            >
              <q-list style="min-width: 360px" class="lista-menu">
                <q-item clickable v-close-popup @click="onAvisoModuloClick">
                  <q-item-section avatar>
                    <!-- Ícone DEVEXTREME: fields -->
                    <i class="dx-icon dx-icon-fields"></i>
                  </q-item-section>

                  <q-item-section>
                    <q-item-label>Aviso dos Módulos</q-item-label>
                  </q-item-section>
                </q-item>
                <q-item clickable v-close-popup @click="onAniversariantes">
                  <q-item-section avatar>
                    <q-icon name="cake" color="purple" />
                  </q-item-section>
                  <q-item-section>
                    <q-item-label>Aniversariantes</q-item-label>
                  </q-item-section>
                </q-item>
              </q-list>
              <q-separator />
              <div class="aniversariantes-dropdown q-pa-sm">
                <lista-aniversariantes />
              </div>
            </q-btn-dropdown>
          </div>
        </dx-item>

        <dx-item location="after" locate-in-menu="auto" menu-item-template="menuUserItem">
          <div slot-scope="_">
            <dx-button
              class="user-button authorization"
              :width="230"
              height="100%"
              styling-mode="text"
            >
              <user-panel :menu-items="userMenuItems" menu-mode="context" />
            </dx-button>
          </div>
        </dx-item>

        <dx-item location="after" round>
          <div slot-scope="_">
            <q-btn color="empresa-cor" round flat icon="settings">
              <q-menu fit style="min-width: 200px; height: auto">
                <q-list style="min-width: 200px" class="lista-menu">
                  <q-item clickable v-close-popup @click="$q.fullscreen.toggle()">
                    <q-item-section>
                      <q-btn flat round color="empresa-cor" icon="copy_all" />Tela Inteira
                    </q-item-section>
                  </q-item>

                  <q-item
                    v-if="$store._mutations.SET_Usuario.ic_tipo_usuario === 'S'"
                    clickable
                    v-close-popup
                    @click="popup_senha_colaboradores = !popup_senha_colaboradores"
                  >
                    <q-item-section>
                      <q-btn flat round color="empresa-cor" icon="person" />Colaboradores
                    </q-item-section>
                  </q-item>

                  <!-- <q-item
                    v-if="$store._mutations.SET_Usuario.ic_tipo_usuario === 'S'"
                    clickable
                    v-close-popup
                    @click="popup_validacao_credito = !popup_validacao_credito"
                  >
                    <q-item-section>
                      <q-btn flat round color="empresa-cor" icon="person_search" />Validação de
                      Crédito
                    </q-item-section>
                  </q-item> -->

                  <!-- linha abaixo do "Tela Inteira" -->

                  <q-separator />
                  <!-- label Empresa + chip com cd_empresa -->
                  <q-item>
                    <q-item-section>
                      <div class="row items-center no-wrap">
                        <span class="empresa-chip"
                          ><b>{{ nm_fantasia }}</b></span
                        >

                        <q-chip dense color="deep-purple-7" text-color="white" class="q-ml-sm">
                          {{ cd_empresa }}
                        </q-chip>
                      </div>
                    </q-item-section>
                    <!-- Novo chip com versão/build -->
                  </q-item>

                  <q-item>
                    <q-separator />
                    <q-item-section>
                      <q-chip dense color="grey-8" text-color="white" class="q-ml-sm">
                        v{{ appVersion }} - {{ appBuild }}
                      </q-chip>
                    </q-item-section>
                  </q-item>
                  <q-item
                    clickable
                    v-close-popup
                    id="dt-response"
                    class="row items-center"
                    @click="popupData = true"
                  >
                    <q-item-section class="col items-center">
                      <q-badge color="empresa-cor" rounded>
                        {{ data_tela_inicial }}
                      </q-badge>
                      até
                      <q-badge color="empresa-cor" rounded>
                        {{ data_tela_final }}
                      </q-badge>
                    </q-item-section>
                  </q-item>
                </q-list>
              </q-menu>
            </q-btn>

            <!-- Popups -->
            <q-dialog maximized v-model="popup_colaboradores">
              <q-card>
                <q-card-section class="row items-center q-pb-none">
                  <div class="text-h6">Colaboradores</div>
                  <q-space />
                  <q-btn icon="close" flat rounded dense v-close-popup />
                </q-card-section>

                <q-btn
                  rounded
                  icon="person_off"
                  color="red"
                  label="Desabilitar"
                  @click="onDesabilitarUsuario"
                />

                <grid
                  v-if="grid_colaboradores"
                  class="margin1"
                  :cd_apiID="965"
                  :cd_menuID="8749"
                  :ic_mostra_titulo="false"
                  @linha="linhaSelecionada"
                  @emit-click="doubleClick"
                  :nm_json="{}"
                />
              </q-card>
            </q-dialog>
            <!-- Solicitar senha para abrir Colaboradores -->
            <q-dialog v-model="popup_senha_colaboradores" persistent>
              <q-card style="min-width: 350px">
                <q-card-section>
                  <div class="text-h6">Digite a senha</div>
                </q-card-section>

                <q-card-section class="q-pt-none">
                  <q-input
                    dense
                    v-model="nm_senha_digitada"
                    autofocus
                    @keyup.enter="onVerificaSenhaColaboradores"
                    type="password"
                  />
                </q-card-section>

                <q-card-actions align="right" class="text-primary">
                  <q-btn
                    rounded
                    color="primary"
                    label="Confirmar"
                    @click="onVerificaSenhaColaboradores"
                  />
                  <q-btn rounded color="red" label="Cancelar" v-close-popup />
                </q-card-actions>
              </q-card>
            </q-dialog>
            <!-- Validação de Crédito -->
            <q-dialog v-model="popup_validacao_credito" maximized persistent>
              <q-card>
                <q-card-section class="row items-center q-pb-none">
                  <div class="text-h6">Validação de Crédito</div>
                  <q-space />
                  <q-btn icon="close" flat rounded dense v-close-popup />
                </q-card-section>

                <ValidacaoCredito />
              </q-card>
            </q-dialog>
            <!-- Validação de Crédito -->
          </div>
        </dx-item>

        <user-panel
          :menu-items="userMenuItems"
          menu-mode="list"
          slot-scope="_"
          slot="menuUserItem"
        />
      </dx-toolbar>

      <q-tabs
        align="left"
        v-model="tab"
        v-show="menuTabs.length > 0"
        inline-label
        class="bg-empresa-cor text-white tab-header"
        @click="clickTab()"
      >
        <q-tab
          v-for="(ta, tabIndex) in menuTabs"
          :key="tabIndex"
          :name="ta.path"
          :label="ta.name"
          class="tab-header"
        />
      </q-tabs>
    </header>

    <q-dialog v-model="popupData">
      <q-card>
        <q-card-section class="row items-center q-pb-none">
          <div class="text-h6">Seleção de Data</div>
          <q-space />
          <q-btn icon="close" @click="selecaoPeriodoData()" flat round dense v-close-popup />
        </q-card-section>
        <selecaoData @click="fechaPopup()" :cd_volta_home="1"></selecaoData>
      </q-card>
    </q-dialog>

    <q-dialog v-model="alert">
      <q-card>
        <q-card-section>
          {{ modulo }}
        </q-card-section>
        <q-card-section>
          <q-video :src="pegaVideo()" />
        </q-card-section>
      </q-card>
    </q-dialog>

    <q-dialog seamless full-width v-model="collapse" position="top">
      <q-card class="collapse-card">
        <q-bar style="background-color: #f63b00">
          <q-space />
          <q-btn dense color="white" flat @click="collapse = false" icon="close" v-close-popup>
            <q-tooltip class="bg-white text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section class="row no-wrap">
          <div style="text-align: center; width: 30%">
            <q-card flat bordered class="my-card collapse-card">
              <q-card-section>
                <img src="https://www.egisnet.com.br/img/logo_gbstec_sistema.png" alt="" />
                <div style="text-align: center" class="text-h6">Horário de Funcionamento</div>
              </q-card-section>

              <q-card-section style="text-align: center" class="q-pt-none">
                Horário: 08:00 - 18:00 <br />
                (Segunda á Sexta-Feira) <br />
                Fone: +55 11 3907-4141
              </q-card-section>

              <q-separator />

              <q-card-section>
                <div style="justify-content: center">
                  <div style="text-align: center" class="text-h6">Chat Online</div>
                  <a
                    href="https://gbsnet.mysuite.com.br/client/chatan.php?urlorigem=gbsnet.mysuite.com.br&param=sochat_chatdep&inf=&sl=gbs"
                    target="_blank"
                    style="text-decoration: none"
                  >
                    <DxButton
                      class="q-ma-sm text-weight-medium"
                      :width="200"
                      type="default"
                      styling-mode="contained"
                      horizontal-alignment="left"
                      >ENTRAR NO CHAT
                    </DxButton>
                  </a>
                </div>
              </q-card-section>
            </q-card>
          </div>

          <div class="col">
            <q-card flat bordered class="my-card collapse-card">
              <q-card-section>
                <div style="text-align: center" class="text-h6">Contato</div>
              </q-card-section>

              <q-card-section style="text-align: center" class="q-pt-none">
                <q-input v-model="nm_nome_contato" label="Nome" />
                <q-input v-model="nm_email_contato" label="Email" />
                <q-option-group
                  v-model="group"
                  :options="options"
                  color="primary"
                  inline
                  type="checkbox"
                />
                <q-input type="textarea" v-model="nm_mensagem" label="Mensagem" />
                <DxButton
                  class="q-ma-sm text-weight-medium"
                  :width="200"
                  type="default"
                  styling-mode="contained"
                  horizontal-alignment="left"
                  @click="chatOnline()"
                  >ENVIAR EMAIL</DxButton
                >
              </q-card-section>
            </q-card>
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>
    <DigisacWebchat />
    <Atividade v-if="this.ic_atividade == true"> </Atividade>
  </div>
</template>

<script>
import DxButton from 'devextreme-vue/button'
import DxToolbar, { DxItem } from 'devextreme-vue/toolbar'
import auth from '../auth'
//
import Procedimento from '../http/procedimento'
import Menu from '../http/menu'
import UserPanel from './user-panel'
import Rota from '../http/rota'
import Incluir from '../http/incluir_registro'
import Atividade from '../components/consultaAtividade'
import funcoesPadroes from '../http/funcoes-padroes'
import notify from 'devextreme/ui/notify'

export default {
  props: {
    menuToggleEnabled: Boolean,
    title: String,
    toggleMenuFunc: Function,
    logOutFunc: Function,
  },

  components: {
    DxButton,
    DxToolbar,
    DxItem,
    UserPanel,
    ListaAniversariantes: () => import('./listaAniversariantes.vue'),
    selecaoData: () => import('../views/selecao-periodo'),
    DigisacWebchat: () => import('../components/webChat.vue'),
    grid: () => import('../views/grid.vue'),
    ValidacaoCredito: () => import('../views/validacaoCredito.vue'),
    Atividade,
  },

  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      nm_fantasia: localStorage.fantasia,
      caminho: '',
      empresa: '',
      modulo: '',
      hoje: '',
      celular: 0,
      avisoModulo: this.$store._mutations.SET_avisoModulo,
      alert: false,
      collapse: false,
      grid_colaboradores: true,
      popup_senha_colaboradores: false,
      popup_validacao_credito: false,
      popup_colaboradores: false,
      colaborador_selecionado: null,
      nm_senha_digitada: '',
      options: [
        {
          label: 'Visita',
          value: '1',
        },
        {
          label: 'Treinamento',
          value: '2',
        },
        {
          label: 'Conferencia',
          value: '3',
        },
        {
          label: 'Suporte',
          value: '4',
        },
        {
          label: 'Novas Funcionalidades',
          value: '5',
        },
      ],
      qt_atividade: 0,
      qt_informativo: 0,
      qt_mensagem: 0,
      qt_aniversario: 0,
      qt_financeiro: 0,
      qt_suporte: 0,
      ic_aniversario: 'N',
      nm_nome_contato: '',
      nm_email_contato: '',
      nm_mensagem: '',
      tab: '',
      menuTabs: [],
      group: [],
      userMenuItems: [
        {
          text: 'Empresas',
          icon: 'globe',
          onClick: this.onEmpresaClick,
          disabled: false,
          visible: true,
        },
        {
          text: 'Usuário',
          icon: 'user',
          onClick: this.onUsuarioClick,
          disabled: false,
          visible: true,
        },
        {
          text: 'Grupo de Usuário',
          icon: 'group',
          onClick: this.onGrupoUsuarioClick,
          disabled: false,
          visible: true,
        },
        {
          text: 'Usuários da Empresa',
          icon: 'map',
          onClick: this.onUsuarioEmpresaClick,
          disabled: false,
          visible: true,
        },
        //{ separator: true }, // ou { type: "separator" }
        {
          text: 'Módulos',
          icon: 'fields',
          onClick: this.onModuloClick,
          disabled: false,
          visible: true,
          beginGroup: true,
        },
        {
          text: 'Composição',
          icon: 'doc',
          onClick: this.onModuloComposicaoClick,
          disabled: false,
          visible: true,
        },

        {
          text: 'Período',
          icon: 'event',
          onClick: this.selecaoPeriodoData,
          disabled: false,
          visible: true,
        },
        {
          text: 'Contato',
          icon: 'mention',
          onClick: this.onContatoClick,
          disabled: false,
          visible: true,
        },
        {
          text: 'Frase do Dia',
          icon: 'card',
          onClick: this.onFraseDiaClick,
          disabled: false,
          visible: true,
        },
        {
          text: 'Speed Test',
          icon: 'check',
          onClick: this.onSpeedTestClick,
          disabled: false,
          visible: true,
          beginGroup: true,       // cria o traço separador antes do item
        },
        {
          text: 'Site GBS',
          icon: 'rename',          // se não existir, use 'info' ou 'fields'        
          onClick: this.abrirSiteGBS,
        },
        {
          text: 'Sobre o Egis',
          icon: 'favorites',          // use um ícone que você já tem funcionando
          onClick: this.onSobreClick,
        },
        {
          text: 'Sair',
          icon: 'runner',
          beginGroup: true,
          onClick: this.onLogoutClick,
        },
      ],
      dt_inicial: '',
      dt_final: '',
      popupData: false,
      ic_atividade: false,
      ic_informativo: false,
      data_tela_inicial: '',
      data_tela_final: '',
      polling: null,
      meses: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
    }
  },

  computed: {
    appVersion() {
      console.log(process.env.VUE_APP_VERSION)
      return process.env.VUE_APP_VERSION
    },
    appBuild() {
      console.log(process.env.VUE_APP_BUILD)
      return process.env.VUE_APP_BUILD
    },
  },

  async created() {
    this.empresa = localStorage.fantasia
    this.modulo = localStorage.nm_modulo
    this.caminho = localStorage.nm_caminho_logo_empresa
    if (this.$store._mutations.SET_Usuario.nm_cor_empresa) {
      document.documentElement.style.setProperty(
        '--cor-principal',
        this.$store._mutations.SET_Usuario.nm_cor_empresa
      )
    } else {
      document.documentElement.style.setProperty('--cor-principal', '#ff5722')
    }
    this.$store._mutations.SET_ConfigUsuario.ic_usuario_internet === 'S'
      ? ''
      : (this.userMenuItems[0].visible = false)

    this.$store._mutations.SET_ConfigUsuario.ic_periodo_internet === 'S'
      ? ''
      : (this.userMenuItems[1].visible = false)

    this.$store._mutations.SET_ConfigUsuario.ic_modulo_internet === 'S'
      ? ''
      : (this.userMenuItems[2].visible = false)

    this.$store._mutations.SET_ConfigUsuario.ic_empresa_internet === 'S'
      ? ''
      : (this.userMenuItems[3].visible = false)
    this.$store._mutations.SET_ConfigUsuario.ic_contato_internet === 'S'
      ? ''
      : (this.userMenuItems[4].visible = false)

    this.hoje = new Date().toLocaleDateString()

    this.polling = setInterval(() => {
      let dt1 = localStorage.dt_inicial
      let dt2 = localStorage.dt_final
      if (dt1 == '' || dt1 == undefined || dt1 == null) {
        this.data_tela_inicial = ''
        return
      } else if (dt2 == '' || dt2 == undefined || dt2 == null) {
        this.data_tela_final = ''
        return
      }
      //--------------------------------------------------------
      this.data_tela_inicial = new Date(localStorage.dt_inicial).toLocaleDateString()
      if (this.data_tela_inicial == 'Invalid Date') {
        localStorage.dt_inicial = funcoesPadroes.getDataInicial()
        var mesI = localStorage.dt_inicial.substring(0, 2)
        var diaI = localStorage.dt_inicial.substring(3, 5)
        var anoI = localStorage.dt_inicial.substring(6, 10)
        mesI = this.meses[parseInt(mesI - 1)]
        this.data_tela_inicial = diaI + '/' + mesI + '/' + anoI
      } else {
        let m = new Date(localStorage.dt_inicial)
        let d = m.getDate()
        if (d < 10) {
          d = '0' + d
        }
        let mesA = m.getMonth()
        let a = m.getFullYear().toString().substring(2)
        var mes = this.meses[mesA]
        this.data_tela_inicial = d + '/' + mes + '/' + a
      }
      //--------------------------------------------------------
      this.data_tela_final = new Date(localStorage.dt_final).toLocaleDateString()
      if (this.data_tela_final == 'Invalid Date') {
        localStorage.dt_final = funcoesPadroes.getDataFinal()
        var mesF = localStorage.dt_final.substring(0, 2)
        var diaF = localStorage.dt_final.substring(3, 5)
        var anoF = localStorage.dt_final.substring(6, 10)
        mesF = this.meses[parseInt(mesF - 1)]
        this.data_tela_final = diaF + '/' + mesF + '/' + anoF
      } else {
        let mF = new Date(localStorage.dt_final)
        let dF = mF.getDate()
        if (dF < 10) {
          dF = '0' + dF
        }
        let mesAF = mF.getMonth()
        let aF = mF.getFullYear().toString().substring(2)
        let mesF = this.meses[mesAF]
        this.data_tela_final = dF + '/' + mesF + '/' + aF
      }
    }, 2000) //Aciona setInterval
    this.detectar()

    this.validacaoAtividade()
  },

  destroyed() {
    clearInterval(this.polling)
  },

  methods: {
    abrirSiteGBS () {
    try {
      window.open('https://gbsnet.com.br/', '_blank', 'noopener,noreferrer')
    } catch (e) {
      // fallback
      window.open('https://gbsnet.com.br/', '_blank')
    }
   },

    fechaPopup() {
      this.popupData = false
    },
    async clickTab() {
      if (this.tab == 'Home') {
        this.$router.push({ name: 'home' })
      }

      localStorage.cd_menu = 0
      localStorage.nm_identificacao_api = ''
      localStorage.cd_api = 0
      localStorage.cd_tipo_consulta = 0
      localStorage.ic_atividade = 'N'
      localStorage.ic_informativo = 'N'
      localStorage.ic_etapa_processo = 'N'
      localStorage.ic_aniversario = 'N'
      localStorage.ic_financeiro = 'N'
      localStorage.ic_suporte = 'N'
      localStorage.ic_mensagem = 'N'
      localStorage.ic_modulo = 'N'
      localStorage.ic_empresa = 'N'
      localStorage.ic_usuario = 'N'
      localStorage.ic_contato = 'N'
      localStorage.ic_periodo = 'N'
      localStorage.ic_logout = 'N'
      localStorage.ic_tela_inteira = 'N'
      localStorage.ic_configuracao = 'N'
      localStorage.ic_speed_test = 'N'

      await Rota.apiMenu(this.tab)

      this.$router.push({ path: this.tab })
      this.$router.push({ name: 'home' })
    },
    async validacaoAtividade() {
      let dados_menu = await Menu.montarMenu(localStorage.cd_empresa, 0, 685)

      localStorage.cd_parametro = 0

      if (dados_menu) {
        let dados = await Procedimento.montarProcedimento(
          localStorage.cd_empresa,
          localStorage.cd_cliente,
          dados_menu.nm_identificacao_api,
          dados_menu.nm_api_parametro
        )
        if (dados[0].ds_tabsheet) {
          this.menuTabs = JSON.parse(dados[0].ds_tabsheet)
        }
      }
      //
    },

    async onVerificaSenhaColaboradores() {
      if (this.nm_senha_digitada === '') {
        notify('Digite a senha para continuar!')
        return
      }
      try {
        let json_verifica_senha_colaborador = {
          cd_parametro: 3,
          cd_usuario: localStorage.cd_usuario,
          nm_senha: this.nm_senha_digitada,
        }
        let [resultado_senha] = await Incluir.incluirRegistro(
          '966/1482',
          json_verifica_senha_colaborador
        ) //pr_egisnet_controle_config_usuario
        notify(resultado_senha.Msg)
        if (resultado_senha.autorizacao === 'S') {
          this.popup_senha_colaboradores = false
          this.nm_senha_digitada = ''
          this.popup_colaboradores = true
        }
      } catch (error) {
        console.error('Error: ', error)
      }
    },

    linhaSelecionada(linha) {
      this.colaborador_selecionado = linha
    },

    doubleClick(linha) {
      this.colaborador_selecionado = linha
      this.onDesabilitarUsuario()
    },

    async onDesabilitarUsuario() {
      if (!this.colaborador_selecionado) {
        notify('Selecione um colaborador para desabilitar!')
        return
      }
      try {
        this.grid_colaboradores = false
        let json_inativa_colaborador = {
          cd_parametro: 1,
          cd_usuario_selecionado: this.colaborador_selecionado.cd_usuario,
        }
        let [resultado_inativar] = await Incluir.incluirRegistro(
          '966/1482',
          json_inativa_colaborador
        ) //pr_egisnet_controle_config_usuario
        notify(resultado_inativar.Msg)
      } catch (error) {
        console.error('Error: ', error)
      } finally {
        this.grid_colaboradores = true
      }
    },

    onInformativo() {
      alert('buscando o componente listar o informativo !')

      this.ic_informativo = !this.ic_informativo

      if (this.ic_informativo == true) {
        localStorage.ic_etapa_processo = 'N'
      } else {
        localStorage.ic_etapa_processo = 'S'
        //this.$router.push({ name: 'home' });
      }

      //this.$emit('validaEtapa', localStorage.ic_etapa_processo);
    },

    onAtividade() {
      this.ic_atividade = !this.ic_atividade

      //this.$router.push({
      //  name: "consultaAtividade"
      // // query: { redirect: this.$route.path }
      // });
    },

    onAniversariantes() {
      this.$router.push({ name: 'lista-aniversariantes' })
    },

    onMensagem() {
      alert('buscando o componente listar Mensagens !')
    },

    detectar() {
      if (
        navigator.userAgent.match(/Android/i) ||
        navigator.userAgent.match(/webOS/i) ||
        navigator.userAgent.match(/iPhone/i) ||
        navigator.userAgent.match(/iPad/i) ||
        navigator.userAgent.match(/iPod/i) ||
        navigator.userAgent.match(/BlackBerry/i) ||
        navigator.userAgent.match(/Windows Phone/i)
      ) {
        this.celular = 1
      } else {
        this.celular = 0
      }
    },

    pegaVideo() {
      var caminho_video = 'gestaoconsorcio.mp4'

      var video = 'https://www.egisnet.com.br/Videos/gbs/' + caminho_video
      return video
    },

    selecaoPeriodoData() {
      if (this.popupData == true) {
        this.popupData = false
      } else if (this.popupData == false) {
        this.popupData = true
      }
    },

    pegaImg() {
      this.caminho = localStorage.nm_caminho_logo_empresa
      var imagem = 'https://www.egisnet.com.br/img/' + this.caminho
      return imagem
    },

    popup() {
      if (this.alert == true) {
        this.alert = false
      } else {
        this.alert = true
      }
    },

    onModuloClick() {
      localStorage.cd_menu = 6543
      localStorage.nm_identificacao_api = 'Empresa/Modulo'
      localStorage.cd_api = 52
      localStorage.cd_tipo_consulta = 0

      if (this.$store._mutations.SET_ConfigUsuario.ic_login_painel == 'S') {
        this.$router.push({ name: 'selecao-modulo-card' })
        return
      }
      this.$router.push({
        name: 'selecao-modulo',
        //query: { redirect: this.$route.path }
      })
    },
    onModuloComposicaoClick() {
      localStorage.cd_menu = 6543
      localStorage.nm_identificacao_api = 'Empresa/Modulo'
      localStorage.cd_api = 52
      localStorage.cd_tipo_consulta = 0
      this.$router.push({ name: 'modulo-composicao' })
    },
    onContatoClick() {
      this.collapse = true
    },
    onSpeedTestClick() {
      window.open('http://speed.shwcloud.com:8088/', '_blank')
    },

    onEmpresaClick() {
      localStorage.cd_menu = 6542
      localStorage.nm_identificacao_api = '51/54'
      localStorage.cd_api = 51
      localStorage.cd_tipo_consulta = 0

      this.$router.push({
        name: 'selecao-empresa',
        // query: { redirect: this.$route.path }
      })
    },

    onSobreClick () {
       // Opção A (rota)
      this.$router.push({ name: 'egis-sobre' })

      // Se você não tiver rota pelo name, use path:
      // this.$router.push({ path: '/egis-sobre' })
   },

   onLogoutClick() {
      auth.logOut()
      this.$router.replace({
        name: 'login-form',
        //query: { redirect: this.$route.path }
        //query: { redirect: '/home' }
      })
    },
    onUsuarioClick() {
      this.$router.push({
        name: 'config-usuario',
        // query: { redirect: this.$route.path }
      })
    },
    onGrupoUsuarioClick() {
      this.$router.push({
        name: 'mostra-usuario-grupo',
        // query: { redirect: this.$route.path }
      })
    },
    onAvisoModuloClick() {
      this.$router.push({ name: 'aviso-modulo' })
    },

    onUsuarioEmpresaClick() {
      this.$router.push({
        name: 'mostra-usuario-empresa',
        // query: { redirect: this.$route.path }
      })
    },
    onFraseDiaClick() {
      this.$router.push({
        name: 'mostra-frase-dia',
        // query: { redirect: this.$route.path }
      })
    },
    async onClickAviso(aviso) {
      try {
        let json_aviso = {
          cd_parametro: 2,
          cd_usuario: localStorage.cd_usuario,
          cd_aviso_web_modulo: aviso.cd_aviso_web_modulo,
        }
        let [resultado_aviso] = await Incluir.incluirRegistro('942/1455', json_aviso) //pr_egisnet_crud_avisos
        notify(resultado_aviso.Msg)
        this.avisoModulo = this.avisoModulo.filter(
          (item) => item.cd_aviso_web_modulo != aviso.cd_aviso_web_modulo
        )
        this.$store._mutations.SET_avisoModulo = this.avisoModulo
      } catch (error) {
        console.error('Error: ', error)
      }
    },
  },
}
</script>

<style lang="scss">
@import '../themes/generated/variables.base.scss';
@import '../dx-styles.scss';
@import url('../views/views.css');

.text-empresa-cor {
  color: var(--cor-principal) !important;
}

.bg-empresa-cor {
  background: var(--cor-principal) !important;
  color: white;
}

.header-component {
  flex: 0 0 auto;
  background: white;
  z-index: 1;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 1px rgba(0, 0, 0, 0.24);

  .dx-toolbar .dx-toolbar-item.menu-button > .dx-toolbar-item-content .dx-icon {
    color: var(--cor-principal) !important;
  }
}

.dx-toolbar.header-toolbar .dx-toolbar-items-container .dx-toolbar-after {
  padding: 0 40px;

  .screen-x-small & {
    padding: 0 20px;
  }
}

.dx-toolbar .dx-toolbar-item.dx-toolbar-button.menu-button {
  width: $side-panel-min-width;
  text-align: center;
  padding: 0;
}

.header-title .dx-item-content {
  padding: 0;
  margin: 0;
}

.dx-theme-generic {
  .dx-toolbar {
    padding: 10px 0;
  }

  .user-button > .dx-button-content {
    padding: 0px;
  }

  .logogbs {
    width: 287;
  }
}

.img {
  max-width: 250px;
  max-height: 60px;
  width: auto;
  height: auto;
  padding-left: 10%;
}

.video {
  width: 500px;
  height: auto;
}

.collapse {
  width: 100%;
  position: absolute;
  float: left;
}

.collapse-card {
  height: 100%;
}

.data-header {
  text-align: center;
  width: 300px !important;
  margin-top: 10px;
}

.btn {
  margin-top: -10px;
  margin-right: 10px;
}

.badge {
  background-color: orangered;
  color: white;
  border-radius: 10px;
  margin-top: 1px;
  margin-left: 30px;
  margin-bottom: 1px;
  padding-top: 2px;
  padding-bottom: 1px;
  padding-left: 5px;
  padding-right: 5px;
  font-size: 10px;
}

.dx-button.dx-button-gbs {
  background-color: rgb(80, 255, 246);
}

.dx-button.dx-button-gbs_red {
  background-color: rgb(255, 80, 124);
}

.dx-button.dx-button-gbs_orange {
  background-color: rgb(80, 255, 246);
}

.dx-button.dx-button-outro {
  background-color: rgb(80, 255, 246);
}

.tab-header {
  width: 50vw;
  height: 30px;
  border-radius: 0px 3px 3px 0px;
}

.dt-storage {
  width: auto;
}

#dt-response {
  width: 0px;
  height: 0px;
  visibility: hidden;
  padding: 0;
  display: none;
  margin: 0;
  min-height: 0px !important;
  max-height: 0 !important;
}

@media (max-width: 1200px) {
  .tab-header {
    width: 50vw;
  }
}

@media (max-width: 1024px) {
  .tab-header {
    width: 50vw;
  }
}

@media (max-width: 768px) {
  .tab-header {
    width: 100vw;
  }

  .dt-storage {
    display: none;
    width: 0;
    height: 0;
  }

  #dt-response {
    visibility: visible;
    width: 200px;
    padding: 8px 16px;
    display: block;
  }

  .q-hoverable:hover > .q-focus-helper {
    background: currentColor;
    opacity: 0;
  }

  .lista-menu {
    height: auto;
  }
}

@media (max-width: 480px) {
  .tab-header {
    width: 100vw;
  }
}

.empresa-chip {
  margin-top: 12px;
}

.q-btn-dropdown__arrow {
  display: none !important;
}

.menu-aviso-dropdown {
  padding: 0 !important;
}
</style>
