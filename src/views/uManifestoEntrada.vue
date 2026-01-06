<template>
  <div class="q-pa-md">
    <unico-form-especial
      v-if="true"
      :title="'Manifesto de Notas de Entrada'"
      :recordCount="rows.length"
      :cd_tabela="0"
      :cd_form_modal="0"
      :ic_card_menu="'N'"
      @refresh="carregar()"
    />
    <!-- status da empresa / serviço -->
    <q-card flat bordered class="q-mt-sm">
    <q-card-section class="row items-center q-col-gutter-md">
        <div class="col-12 col-md-6">
        <div class="text-subtitle1 text-weight-bold">
            {{ cfg.nm_empresa || 'Empresa' }}
        </div>
        <div class="text-caption text-grey-8">
            CNPJ: <span class="text-weight-medium">{{ cfg.cd_cnpj_empresa || '-' }}</span>
            | UF: <span class="text-weight-medium">{{ cfg.sg_estado_empresa || '-' }}</span>
            | Código: <span class="text-weight-medium">{{ cdEmpresa || '-' }}</span>
        </div>
        </div>

        <div class="col-12 col-md-6">
        <div class="row q-col-gutter-sm justify-end">
            <div class="col-auto">
            <q-badge :color="cfg.ic_dfe_ativo === 'S' ? 'positive' : 'negative'">
                DFe: {{ cfg.ic_dfe_ativo === 'S' ? 'ATIVO' : 'INATIVO' }}
            </q-badge>
            </div>
            <div class="col-auto">
            <q-badge color="grey-8">
                Hora: {{ cfg.hr_nfe_servico || '06:00:00' }}
            </q-badge>
            </div>
            <div class="col-auto">
           <q-badge color="indigo-8">
              NSU: {{ cfg.ult_nsu != null ? cfg.ult_nsu : 0 }} / {{ cfg.max_nsu != null ? cfg.max_nsu : 0 }}
            </q-badge>

            </div>
            <div class="col-auto">
            <q-badge :color="temCert ? 'positive' : 'negative'">
                Cert: {{ temCert ? 'OK' : 'FALTANDO' }}
            </q-badge>
            </div>
        </div>

        <q-banner v-if="cfgErro" class="q-mt-sm bg-red-1 text-red-9">
            {{ cfgErro }}
        </q-banner>
        </div>
    </q-card-section>
    </q-card>

    <!-- filtros -->
    <div class="row q-col-gutter-sm q-mt-sm items-end">
      <div class="col-12 col-md-3">
        <q-input v-model="filtro.cnpj" dense outlined label="CNPJ (destinatário)" />
      </div>

      <div class="col-12 col-md-3">
        <q-input v-model="filtro.dataIni" dense outlined label="Data inicial" />
      </div>

      <div class="col-12 col-md-3">
        <q-input v-model="filtro.dataFim" dense outlined label="Data final" />
      </div>

      <div class="col-12 col-md-3">
        <q-toggle v-model="filtro.somentePendentes" label="Somente não lançadas" />
      </div>

      <div class="col-12">
        <q-btn color="deep-purple-7" icon="sync" label="Atualizar" @click="carregar" :loading="loading" />
        <q-btn class="q-ml-sm" color="deep-purple-7" icon="cloud_download" label="Sincronizar SEFAZ"
               @click="syncAgora" :loading="syncing" :disable="!podeSincronizar" />
      </div>
    </div>

    <!-- grid -->
    <div class="q-mt-md">
      <q-card flat bordered>
        <q-card-section class="q-pa-none">
          <DxDataGrid
            ref="grid"
            :data-source="rows"
            :show-borders="true"
            :hover-state-enabled="true"
            :row-alternation-enabled="true"
            :word-wrap-enabled="true"
            no-data-text="Sem dados"
            :onRowPrepared="onRowPrepared"
          >
            <DxFilterRow :visible="true" />
            <DxSearchPanel :visible="true" :highlight-case-sensitive="false" :width="280" />
            <DxPaging :page-size="30" />
            <DxPager :show-info="true" :show-page-size-selector="true" :allowed-page-sizes="[15,30,60,120]" />

            <DxColumn caption="Ações" :width="220" cell-template="acoesCell" :allow-sorting="false" />

            <DxColumn data-field="dhEmi" caption="Emissão" :width="170" />
            <DxColumn data-field="chave" caption="Chave" :width="280" />
            <DxColumn data-field="emitente" caption="Emitente" />
            <DxColumn data-field="vNF" caption="Valor" :width="120" />
            <DxColumn data-field="ja_lancada" caption="Lançada?" :width="110" />
            <DxColumn data-field="manifesto_status" caption="Manifesto" :width="130" />
            <DxColumn data-field="tem_xml" caption="Tem XML?" :width="110" />

            <template #acoesCell="{ data }">
              <div class="q-gutter-xs">
                <q-btn
                  dense
                  color="deep-purple-7"
                  icon="gavel"
                  label="Manifesto"
                  :disable="!podeManifestar"
                  @click="abrirManifesto(data.data)"
                />
                <q-btn
                  dense
                  color="primary"
                  icon="description"
                  label="XML"
                  :disable="!data.data.tem_xml"
                  @click="abrirXml(data.data)"
                />
              </div>
            </template>
          </DxDataGrid>
        </q-card-section>
      </q-card>
    </div>

    <!-- Modal manifesto -->
    <q-dialog v-model="dlgManifesto" persistent>
      <q-card style="min-width: 560px; max-width: 95vw;">
        <q-card-section class="row items-center">
          <div class="text-h6">Manifestar Nota</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-separator />

        <q-card-section>
          <div class="text-caption text-grey-8">Chave</div>
          <div class="text-weight-bold q-mb-sm">{{ sel.chave }}</div>

          <div class="text-caption text-grey-8">Emitente</div>
          <div class="q-mb-sm">{{ sel.emitente }}</div>

          <q-select
            v-model="manifesto.tpEvento"
            :options="opcoesManifesto"
            emit-value map-options
            dense outlined
            label="Tipo de Manifesto"
          />

          <q-input
            v-model="manifesto.justificativa"
            dense outlined
            label="Justificativa (se necessário)"
            class="q-mt-sm"
          />

          <q-banner class="q-mt-sm bg-grey-2 text-grey-9">
            Dica: para “só reconhecer que viu”, use <b>Ciência (210210)</b>.  
            Confirmar (210200) é mais forte, e as outras opções só se aplicam em casos específicos.
          </q-banner>
        </q-card-section>

        <q-separator />

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" v-close-popup />
          <q-btn color="deep-purple-7" label="Confirmar" :loading="manifestando" @click="confirmarManifesto" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Modal XML -->
    <q-dialog v-model="dlgXml" maximized persistent>
      <q-card>
        <q-card-section class="row items-center">
          <div class="text-h6">Entrada XML</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>
        <q-separator />

        <!-- Aqui você “encaixa” o EntradaXML.vue -->
        <!-- A ideia é: EntradaXML recebe a chave e busca o XML via API, ou recebe o xml direto -->
        <q-card-section style="height: calc(100vh - 110px); overflow:auto;">
          <EntradaXML
            v-if="sel.chave"
            :chave="sel.chave"
            :cnpj="filtro.cnpj"
          />
        </q-card-section>
      </q-card>
    </q-dialog>

  </div>
</template>

<script>

import axios from 'axios'

// Ajuste os imports para o caminho real do seu projeto
import unicoFormEspecial from './unicoFormEspecial.vue'
import EntradaXML from './entradaXMLold.vue'

// DevExtreme
import { DxDataGrid, DxColumn, DxFilterRow, DxSearchPanel, DxPaging, DxPager } from 'devextreme-vue/data-grid'


// Se você já tem um `api` global, pode importar de lá.
// Aqui deixo um exemplo simples, igual ao estilo do UnicoFormEspecial.
const api = axios.create({
  baseURL: 'https://egiserp.com.br/api',
  withCredentials: true,
  timeout: 60000,
})

api.interceptors.request.use(cfg => {
  
  //const banco = localStorage.nm_banco_empresa || ''
  
  //if (banco) cfg.headers['x-banco'] = banco
     
  // respeita x-banco já definido na chamada
  const headers = cfg.headers || (cfg.headers = {})

  // procura x-banco em qualquer variação
  const jaTemBanco =
    headers['x-banco'] || headers['X-Banco'] || headers['x-Banco'] || headers['X-BANCO']

  if (!jaTemBanco) {
    const banco = localStorage.nm_banco_empresa || ''
    if (banco) headers['x-banco'] = banco
  }


  cfg.headers['Authorization'] = 'Bearer superchave123'
  
  if (!cfg.headers['Content-Type']) cfg.headers['Content-Type'] = 'application/json'
  return cfg

})

export default {
  name: 'uManifestoEntrada',
  components: {
    unicoFormEspecial,
    EntradaXML,
    DxDataGrid, DxColumn, DxFilterRow, DxSearchPanel, DxPaging, DxPager
  },
  data () {
    return {
        cdEmpresa: localStorage.cd_empresa || 0,
        cfg: {
        cd_empresa: null,
        nm_empresa: null,
        cd_cnpj_empresa: null,
        sg_estado_empresa: null,
        ic_dfe_ativo: null,
        hr_nfe_servico: null,
        ult_nsu: null,
        max_nsu: null,
        nm_certificado: null,
        cd_senha_certificado: null
        },
        cfgLoading: false,
        cfgErro: '',

      loading: false,
      syncing: false,
      manifestando: false,

      filtro: {
        cnpj: '',
        dataIni: localStorage.dt_inicial,
        dataFim: localStorage.dt_final,
        somentePendentes: false
      },

      rows: [],

      dlgManifesto: false,
      dlgXml: false,

      sel: {
        chave: '',
        emitente: ''
      },

      manifesto: {
        tpEvento: 210210,
        justificativa: ''
      },

      opcoesManifesto: [
        { label: 'Ciência da Operação (210210)', value: 210210 },
        { label: 'Confirmação da Operação (210200)', value: 210200 },
        { label: 'Desconhecimento da Operação (210220)', value: 210220 },
        { label: 'Operação não Realizada (210240)', value: 210240 }
      ]
    }
  },
  computed: {
  temCert () {
    return !!(this.cfg.nm_certificado && this.cfg.cd_senha_certificado)
  },
  podeSincronizar () {
    return this.cfg.ic_dfe_ativo === 'S' && this.temCert && !!this.cfg.cd_cnpj_empresa
  },
  podeManifestar () {
    // manifesto depende de DFe ativo e certificado ok
    return this.podeSincronizar
  }
},

  methods: {
  
    async carregar () {
      
        this.loading = true
    
      try {
        // 1) validações
        if (!this.cfg || !this.cfg.nm_banco_empresa) {
          this.cfgErro = 'Banco da empresa não encontrado (nm_banco_empresa).'
          return
        }

        if (!this.filtro.cnpj) {
           this.cfgErro = 'CNPJ não informado.'
           return
        }

        // 2) monta body para procedure (padrão /exec)
        // Atenção: ajuste os nomes conforme sua pr_api_distdfe_manifesto
        var body = [{
        ic_json_parametro: 'S',
        cd_parametro: 1 , // "listar recebidas" (conforme seu padrão)
        dt_inicial: this.filtro.dataIni || null,
        dt_final: this.filtro.dataFim || null,
        somente_pendentes: this.filtro.somentePendentes ? 'S' : 'N'
        }]

        // 3) chama a SP no banco da empresa (EGISSQL_xxx)
        var resp = await api.post('/exec/pr_egis_manifesto_processo_modulo', body, {
        headers: { 'x-banco': this.cfg.nm_banco_empresa }
        })

        //console.log('dados da api --> ', resp, data)
        
        // 4) normaliza retorno
        
        
        var data = (resp && resp.data) ? resp.data : []
        
        console.log('dados da api --> ', resp, data)
        
        
        var lista = Array.isArray(data) ? data : (data && Array.isArray(data.rows) ? data.rows : [])

        // 5) mapeia para o formato da grid
        this.rows = lista.map(function (r) {
        // tenta várias chaves possíveis (porque cada SP devolve diferente)
        var chave = r.chave || r.chave_nfe || r.chave_nfe_entrada || r.cd_chave_acesso || r.chave_nfe_saida || r.chave_nfe || r.chave_nfe
        var dhEmi = r.dhEmi || r.dh_emi || r.data_emissao || r.dt_emissao || r.dh_emissao
        var emitente = r.emitente || r.xNome || r.nm_emitente || r.nome_emitente || r.nm_empresa_emitente
        var vNF = r.vNF || r.v_nf || r.valor || r.vl_total || r.vl_nota

        var tipo = r.tipo || r.tp || null
        var temXml = (r.tem_xml != null) ? !!r.tem_xml : (tipo === 'proc' || !!r.xml_conteudo)

        var jaLancada = (r.ja_lancada != null) ? !!r.ja_lancada : false

        return {
            nsu: r.nsu,
            chave: chave,
            dhEmi: dhEmi,
            emitente: emitente,
            vNF: vNF,
            tipo: tipo,
            tem_xml: temXml,
            ja_lancada: jaLancada,
            manifesto_status: r.manifesto_status || r.manifesto || null
        }
        })

        this.cfgErro = ''

    } catch (e) {
        var msg = (e && e.response && e.response.data && e.response.data.erro) ? e.response.data.erro
        : (e && e.message) ? e.message
        : 'Falha ao carregar notas do Inbox.'
        this.cfgErro = msg
        this.$q.notify({ type: 'negative', position: 'center', message: msg })
    } finally {
        this.loading = false
    }
    },

    async carregarConfigEmpresa () {
        this.cfgErro = ''
        this.cfgLoading = true
        try {
        // pega cd_empresa do localStorage
        const cd = (localStorage.getItem('cd_empresa') || '').toString().trim()
        this.cdEmpresa = cd || localStorage.cd_empresa || null;
        
        if (!this.cdEmpresa) {
            this.cfgErro = 'cd_empresa não encontrado no localStorage.'
            return
        }
              
         const body = [{
           ic_json_parametro: 'S',
           cd_empresa : this.cdEmpresa || localStorage.cd_empresa
         }]

         console.log('payload', body);

        // chama backend que executa a procedure no EgisAdmin
        // você pode ajustar a URL conforme seu projeto

       // força executar no EgisAdmin (pelo header x-banco)
       var resp = await api.post('/exec/pr_egis_config_nfe_empresa', body, {
        headers: { 'x-banco': 'EgisAdmin' }
       })

        console.log('resultado ',resp);

        // esperado: resp.data.row ou resp.data[0]
       var data = (resp && resp.data) ? resp.data : null

        // alguns backends devolvem { rows: [...] } ou { data: [...] } ou diretamente [...]
        var row = null
        if (data && data.row) row = data.row
        else if (Array.isArray(data) && data.length) row = data[0]
        else if (data && Array.isArray(data.rows) && data.rows.length) row = data.rows[0]
        else if (data && Array.isArray(data.data) && data.data.length) row = data.data[0]
        else if (data && data.recordset && Array.isArray(data.recordset) && data.recordset.length) row = data.recordset[0]
        else row = data


        console.log('dados ',row);

        if (!row) {
            this.cfgErro = 'Procedure não retornou dados da empresa.'
            return
        }

        this.cfg = {
        cd_empresa: (row && row.cd_empresa) ? row.cd_empresa : this.cdEmpresa,
        nm_empresa: row ? row.nm_empresa : null,
        cd_cnpj_empresa: row ? row.cd_cnpj_empresa : null,
        sg_estado_empresa: row ? row.sg_estado_empresa : null,
        ic_dfe_ativo: row ? row.ic_dfe_ativo : null,
        hr_nfe_servico: (row && (row.hr_dfe_servico || row.hr_nfe_servico)) ? (row.hr_dfe_servico || row.hr_nfe_servico) : '06:00:00',
        ult_nsu: (row && row.ult_nsu != null) ? row.ult_nsu : 0,
        max_nsu: (row && row.max_nsu != null) ? row.max_nsu : 0,
        nm_certificado: row ? row.nm_certificado : null,
        cd_senha_certificado: row ? row.cd_senha_certificado : null,
        nm_banco_empresa: row ? row.nm_banco_empresa : null
        }


        // já deixa o filtro CNPJ preenchido
        this.filtro.cnpj = this.cfg.cd_cnpj_empresa || this.filtro.cnpj

        if (this.cfg.nm_banco_empresa) {
            localStorage.nm_banco_empresa = this.cfg.nm_banco_empresa
        }

        // se estiver tudo ok, já carrega a grid
        if (this.podeSincronizar) {
            await this.carregar()
        } else {
            if (this.cfg.ic_dfe_ativo !== 'S') this.cfgErro = 'Serviço DFe está INATIVO para esta empresa (ic_dfe_ativo != S).'
            else if (!this.temCert) this.cfgErro = 'Certificado/senha não configurados para esta empresa.'
        }

        } catch (e) {
        this.cfgErro = e?.response?.data?.erro || e?.message || 'Falha ao carregar configuração da empresa.'
        } finally {
        this.cfgLoading = false
        }
    },


    async carregarOld () {
      this.loading = true
      try {
        // Ajuste: use o seu axios/serviço HTTP padrão do projeto
        const resp = await this.$axios.get('/api/dfe/inbox', {
          params: {
            cnpj: this.filtro.cnpj,
            dataIni: this.filtro.dataIni || null,
            dataFim: this.filtro.dataFim || null,
            somentePendentes: this.filtro.somentePendentes ? 1 : 0
          }
        })
        this.rows = Array.isArray(resp.data) ? resp.data : (resp.data?.rows || [])
      } catch (e) {
        this.$q.notify({ type: 'negative', position: 'center', message: e?.message || 'Falha ao carregar inbox' })
      } finally {
        this.loading = false
      }
    },

    // dispara a coleta via backend (Node chamando PHP distdfe_sync.php)

    async syncAgora () {
      
      this.syncing = true

      try {
    
        // chama Node que chama PHP distdfe_sync.php (SEFAZ)
    var resp = await api.post('/dfe/sync', { cnpj: this.filtro.cnpj })

    // resp normalmente tem: { cursor: {ultNSU,maxNSU}, gate: {..} } ou { cursor, coletado }
    var ult = (resp && resp.data && resp.data.cursor && resp.data.cursor.ultNSU != null)
      ? resp.data.cursor.ultNSU
      : '?'

    // se veio gate 656, só avisa e não tenta “forçar” carregar XML
    if (resp && resp.data && resp.data.gate && resp.data.gate.cStat === 656) {
      var next = resp.data.gate.nextAllowedLocal || resp.data.gate.nextAllowedUtc || '(aguarde 1 hora)'
      this.$q.notify({ type: 'warning', position: 'center',
                       message: 'SEFAZ bloqueou (656). Próxima tentativa: ' + next })
      return
    }

    // 137 nenhum doc
    if (resp.data?.cursor?.cStat === 137) {
    this.$q.notify({
       type: 'info',
       position: 'center',
       message: `Nenhum documento localizado. Nova tentativa: ${resp.data.gate?.nextAllowedLocal || 'em alguns minutos'}`
     })
     return
    }

    this.$q.notify({ type: 'positive', position: 'center', message: 'Sync OK. ultNSU=' + ult })

    //
    await this.carregar()
    //

  } catch (e) {
    var msg = (e && e.response && e.response.data && e.response.data.erro)
      ? e.response.data.erro
      : (e && e.message) ? e.message : 'Falha no sync'
    this.$q.notify({ type: 'negative', position: 'center', message: msg })
  } finally {
    this.syncing = false
  }
},

    onRowPrepared (e) {
      if (e.rowType !== 'data') return
      // pinta não lançadas
      if (e.data && e.data.ja_lancada === false) {
        e.rowElement.style.backgroundColor = '#fff3e0' // laranja bem claro
      }
      // se não tem XML ainda, deixa “apagado”
      if (e.data && !e.data.tem_xml) {
        e.rowElement.style.opacity = '0.88'
      }
    },

    abrirManifesto (row) {
      this.sel = {
        chave: row.chave,
        emitente: row.emitente
      }
      this.manifesto.tpEvento = 210210
      this.manifesto.justificativa = ''
      this.dlgManifesto = true
    },

    async confirmarManifesto () {
      this.manifestando = true
      try {

        console.log('Clique do Manifesto')
        
        await api.post('/dfe/manifestar', {
          cnpj: this.filtro.cnpj,
          chave: this.sel.chave,
          tpEvento: this.manifesto.tpEvento,
          justificativa: this.manifesto.justificativa || ''
        })

        this.$q.notify({ type: 'positive', position: 'center', message: 'Manifesto enviado com sucesso' })
        this.dlgManifesto = false

        //
        await this.carregar()
        //

      } catch (e) {
        this.$q.notify({ type: 'negative', position: 'center', message: e?.response?.data?.erro || e?.message || 'Falha ao manifestar' })
      } finally {
        this.manifestando = false
      }
    },

    abrirXml (row) {
      this.sel = { chave: row.chave, emitente: row.emitente }
      this.dlgXml = true
    }
  },

  mounted () {
    
    this.carregarConfigEmpresa();

    // se você tiver CNPJ logado, pode preencher aqui automaticamente
    // this.filtro.cnpj = this.$store.state.empresa.cnpj
    // this.filtro.dataIni = '2025-11-01'
    // this.filtro.dataFim = '2025-11-30'
    // this.carregar()

  }
}
</script>
