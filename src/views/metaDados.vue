<template>
  <div id="meta-form" class="page">
    <div class="row items-center">
      <transition name="slide-fade">
        <h2 class="content-block col-8" v-show="tituloMenu || title">
          <q-btn
            flat
            round
            dense
            icon="arrow_back"
            class="q-mr-sm"
            aria-label="Voltar"
            @click="onVoltar"
          />
          {{ tituloMenu || title }}
        </h2>
      </transition>
    </div>

    <div class="mf-row mf-card">
  <label class="mf-lbl"><strong>MenuId:</strong></label>

  <input
    type="number"
    v-model.number="menuIdBusca"
    placeholder="Código Menu"
    @keyup.enter="carregarPorMenuId(menuIdBusca)"
  />

  <button class="mf-btn mf-primary" @click="carregarPorMenuId(menuIdBusca)">
    Carregar Menu
  </button>

  <small class="mf-hint">
    Digite o MenuId e carregue. Se já existir, você edita. Se não existir, use Executar para gerar.
  </small>
</div>


    <!-- Menu + badge cd_menu_id -->
    <div class="mf-row mf-card">
      <label class="mf-lbl"><strong>Menu:</strong></label>
      <select v-model="menuId" @change="onMenuChange">
        <option v-for="m in menusFiltrados" :key="m.cd_menu" :value="m.cd_menu">
          {{ m.nm_menu }}
        </option>
      </select>

      <span v-if="menuIdDaProcedure" class="mf-badge">
        vinculado ao cd_menu_id: {{ menuIdDaProcedure }}
      </span>
      <span v-else-if="usarMenuSelecionado && menuId" class="mf-badge">
         menu selecionado: {{ menuId }}
     </span>

    </div>

    <!-- Linha 2: Busca de menu e listbox -->
    <div class="mf-row mf-card">
      <label class="mf-lbl"><strong>Buscar Menu:</strong></label>
      <input
        type="text"
        v-model.trim="menuSearch"
        placeholder="Digite parte do nome"
        @input="filtrarMenus"
        class="mf-menu-search"
      />

        
        <div style="flex-basis:100%; height:0;"></div>

  <select size="8" class="menu-list" v-model="menuId" @change="onMenuChange">
    <option v-for="m in menusFiltrados" :key="m.cd_menu" :value="m.cd_menu">
      {{ m.nm_menu }}
    </option>

  </select>
    </div>

  <!-- Linha : Atualizar, busca de procedure, combo Procedure -->
    <div class="mf-row mf-card">
      <button class="mf-btn mf-secondary" @click="atualizarProcedures">Atualizar Lista de Procedures</button>

      <div class="mf-inline-field">
        <label class="mf-lbl"><strong>Buscar Procedure </strong></label>
        <div>
         <label class="mf-inline-toggle"
            title="Marque para informar uma procedure manualmente (quando o menu não tiver procedure vinculada).">
            <input type="checkbox" v-model="procedureManual" />
               Manual
         </label>
        </div>
        <input
          type="text"
          v-model.trim="procedureSearch"
          placeholder="Buscar procedure..."
          @input="filtrarProcedures(procedureSearch)"
          @blur="fixarProcedurePorTexto"
          @keyup.enter="fixarProcedurePorTexto"
        />

         <small v-if="!podeEditarProcedure" class="mf-hint">
    Primeiro informe o <strong>Menu</strong> (ou marque <strong>Manual</strong>).
  </small>

  <small v-else-if="menuSemProcedure" class="mf-hint">
    Este menu não tem procedure vinculada. Marque <strong>Manual</strong> e informe a procedure.
  </small>

      </div>

      <div class="mf-inline-field">
        <label class="mf-lbl"><strong>Procedure:</strong></label>
        <q-select
          v-model="procedureSelecionada"
          :options="proceduresFiltradas"
          use-input
          input-debounce="300"
          @filter="filtrarProcedures"
          @update:model-value="onProcedureSelecionada"
          label="Selecione a procedure"
          filled
          clearable
          emit-value
          class="mf-select"
        />
      </div>
    </div>
  

    <!-- Linha 3: editar parâmetros -->
    <div class="mf-row mf-card">
      <button class="mf-btn mf-secondary" @click="abrirEditorParametros">Editar Parâmetros</button>
    </div>

    <!-- Linha 4: formulário de parâmetros + Executar/Gravar -->
    <div class="mf-row mf-card">
      <div id="paramForm" class="mf-param-form">
        <div class="mf-inline-field" v-for="p in parametros" :key="p.nome_parametro">
          <label class="mf-lbl">{{ p.nome_parametro }}</label>
          <input
            :type="campoType(p)"
            :name="p.nome_parametro.replace('@','')"
            v-model="form[p.nome_parametro.replace('@','')]"
          />
        </div>
      </div>

      <button class="mf-btn mf-accent" @click="executarESalvar">Executar e Gravar Cabeçalhos</button>
      <span v-show="loadingExec" class="mf-loading">⏳ Carregando...</span>
    </div>

    <!-- Linha 5: Buscar por ID do Menu + botões -->
    <div class="mf-row mf-card">
      <div class="mf-row">
        <label class="mf-lbl"><strong>Buscar por ID do Menu:</strong></label>
        <input type="number" v-model.number="menuIdBusca" placeholder="Digite o ID do menu" />
        <button class="mf-btn mf-primary" @click="buscarCabecalhosPorMenuId">Buscar Cabeçalhos</button>
      </div>

      <button class="mf-btn mf-secondary" @click="carregarCabecalhos">Ver Cabeçalhos Gravados</button>
      <button class="mf-btn mf-accent" @click="salvarCabecalhos">Salvar Alterações</button>
      <button class="mf-btn mf-primary" @click="abrirGrid">Visualizar Grid DevExtreme</button>
    </div>

    <!-- Tabela resultado -->
    <div id="cabecalhosContainer" class="mf-card">
      <table id="resultadoTable" class="mf-table" border="1">
        <thead>
          <tr>
            <th>#</th>
            <th>Nome</th>
            <th>Tipo</th>
            <th>Ordem</th>
            <th>Título</th>
            <th>Visível</th>
            <th>Ordem Grid</th>
            <th>Contagem</th>
            <th>Soma</th>
            <th>Formato</th>
            <th>Largura</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="d in cabecalhos" :key="d.id || d.nome_coluna">
            <td>{{ d.id || '-' }}</td>
            <td>{{ d.nome_coluna }}</td>
            <td>{{ d.tipo_coluna }}</td>
            <td>{{ d.ordem_coluna }}</td>
            <td>
              <input
               type="text"
               class="mf-input-inline"
               :value="d.titulo_exibicao || d.nome_coluna"
               @input="atualizarCampo(d, 'titulo_exibicao', $event.target.value)"
              />
            </td>
            <td><input type="checkbox" :checked="!!d.visivel" @change="atualizarCampo(d,'visivel',$event.target.checked?1:0)"/></td>
            <td><input type="number" :value="d.qt_ordem_coluna || ''" @change="atualizarCampo(d,'qt_ordem_coluna',$event.target.value)"/></td>
            <td><input type="checkbox" :checked="!!d.contagem" @change="atualizarCampo(d,'contagem',$event.target.checked?1:0)"/></td>
            <td><input type="checkbox" :checked="!!d.soma" @change="atualizarCampo(d,'soma',$event.target.checked?1:0)"/></td>
            <td><input type="text" :value="d.formato_coluna || ''" @change="atualizarCampo(d,'formato_coluna',$event.target.value)"/></td>
            <td><input type="number" :value="d.largura || ''" @change="atualizarCampo(d,'largura',$event.target.value)"/></td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- ===== MODAL PARÂMETROS ===== -->
    <div v-if="showParams" class="mf-modal-mask">
      <div class="mf-modal-wrapper">
        <div class="mf-modal-container">
          <div class="mf-modal-header">
            <h2>Parâmetros — {{ procedureSelecionada }}</h2>
            <button class="mf-btn mf-secondary" @click="showParams=false">Fechar</button>
          </div>

          <div class="mf-modal-toolbar">
            <input v-model="paramsFilter" class="mf-inp" placeholder="filtrar por nome/título..." />
            <button class="mf-btn mf-primary" @click="syncParametros">Sincronizar Parâmetros</button>
          </div>

          <div class="mf-modal-body">
            <div v-if="paramsLoading">Carregando…</div>
            <table v-else class="mf-table">
              <thead>
                <tr>
                  <th>Nome</th>
                  <th>Tipo</th>
                  <th style="width:220px">Valor Padrão</th>
                  <th>Obrig.</th>
                  <th>Editável</th>
                  <th style="width:260px">Título</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="p in paramsList.filter(pp => {
                    const t=(paramsFilter||'').toLowerCase();
                    return (pp.nome_parametro||'').toLowerCase().includes(t) ||
                           (pp.titulo_parametro||'').toLowerCase().includes(t);
                  })"
                  :key="p.id"
                >
                  <td>{{ p.nome_parametro }}</td>
                  <td>{{ p.tipo_parametro }}</td>
                  <td><input class="mf-inp" v-model="p.valor_padrao"></td>
                  <td class="mf-c"><input type="checkbox" v-model="p.obrigatorio" true-value="1" false-value="0"></td>
                  <td class="mf-c"><input type="checkbox" v-model="p.editavel" true-value="1" false-value="0"></td>
                  <td><input class="mf-inp" v-model="p.titulo_parametro"></td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="mf-modal-footer">
            <button class="mf-btn mf-accent" :disabled="paramsSaving" @click="salvarParametros">
              {{ paramsSaving ? 'Salvando…' : 'Salvar Alterações' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- ===== MODAL GRID ===== -->
    <div v-if="showGrid" class="mf-modal-mask">
      <div class="mf-modal-wrapper" style="max-width: 96%;">
        <div class="mf-modal-container" style="padding: 10px 14px;">
          <div class="mf-modal-header">
            <h3>Resultado - {{ procedureSelecionada }}</h3>
            <button class="mf-btn mf-secondary" @click="showGrid=false">Fechar</button>
          </div>

          <div class="mf-modal-body">
            <div v-if="gridLoading">Carregando…</div>
            <DxDataGrid
              v-else
              :data-source="gridRows"
              :show-borders="true"
              :column-auto-width="true"
              :height="600"
            >
              <DxSearchPanel :visible="true" />
              <DxPaging :page-size="20" />
              <DxPager :show-page-size-selector="true" :allowed-page-sizes="[10,20,50]" :show-info="true" />
              <DxColumn
                v-for="c in gridCols
                           .map(k => {
                             const precisa=['fixedPoint','currency','percent'].includes(k.formato_coluna);
                             const o = {
                               dataField: k.dataField || k.nome_coluna,
                               caption: k.caption || k.titulo_exibicao || k.dataField || k.nome_coluna,
                               width: k.width || k.largura ? parseInt(k.width || k.largura) : undefined,
                               visible: k.visivel===1 || k.visivel===true || k.visivel==='1' || k.visivel==null,
                               ordem: parseInt(k.qt_ordem_coluna) || 999
                             };
                             if (k.formato_coluna) {
                               o.format = k.formato_coluna==='shortDate'
                                 ? 'dd/MM/yyyy'
                                 : { type: k.formato_coluna, precision: precisa ? 2 : undefined };
                               o.alignment = precisa ? 'right' : 'left';
                             }
                             return o;
                           }).sort((a,b)=>a.ordem-b.ordem)"
                :key="c.dataField"
                :data-field="c.dataField" :caption="c.caption" :visible="c.visible"
                :width="c.width" :format="c.format" :alignment="c.alignment"
              />
              <DxSummary>
                <DxTotalItem
                  v-for="s in gridCols.filter(k => k.soma || k.contagem).map(k => ({
                              column: k.dataField || k.nome_coluna,
                              summaryType: k.soma ? 'sum' : 'count',
                              showInColumn: k.dataField || k.nome_coluna,
                              displayFormat: k.soma ? undefined : '{0} registros'
                           }))"
                  :key="s.column + s.summaryType"
                  :column="s.column" :summary-type="s.summaryType"
                  :show-in-column="s.showInColumn" :display-format="s.displayFormat"
                />
              </DxSummary>
            </DxDataGrid>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import axios from 'axios';
import ParametrosModal from '@/components/parametrosModal.vue';
import GridModal from '@/components/gridModal.vue';

// client único para /api/meta-dados  (SEM barra inicial nas chamadas)
const api = axios.create({
  baseURL: (axios.defaults.baseURL || '').replace(/\/$/, '') + '/meta-dados/'
});

// injeta headers a cada request (x-banco + bearer fixo)
api.interceptors.request.use((cfg) => {
  const banco = localStorage.nm_banco_empresa || "";
  if (banco) cfg.headers["x-banco"] = banco;
  cfg.headers["Authorization"] = "Bearer superchave123";
  if (!cfg.headers["Content-Type"])
    cfg.headers["Content-Type"] = "application/json";
  // DEBUG: veja a URL real que está indo
  console.log(
    "[REQ]",
    banco,
    cfg.method?.toUpperCase(),
    (cfg.baseURL || "") + cfg.url
  );
  return cfg;
});

api.interceptors.response.use(
  r => r,
  err => {
    const s = err?.response?.status;
    const d = err?.response?.data;
    console.error('[RES ERR]', s, d);
    return Promise.reject(err);
  }
);


function toDateInput(v) {
  if (!v) return '';
  const d = new Date(v);
  if (isNaN(d)) return '';
  return d.toISOString().slice(0, 10); // yyyy-mm-dd
}

function normalizeParamValue(p) {
  const tipo = String(p.tipo_parametro || '').toLowerCase();
  const val  = p.valor_padrao;

  if (['date','datetime','smalldatetime','date_time'].includes(tipo)) {
    return toDateInput(val);
  }
  if (['bit','boolean','bool'].includes(tipo)) {
    return (val === 1 || val === '1' || val === true) ? 1 : 0;
  }
  if (val == null) return '';
  return val;
}

export default {
  name: 'MetaDadosBaseadoNoMenuHTML',
  components: { ParametrosModal, GridModal  },
  data(){
    return {
      // topo
      title: localStorage.menu_titulo,            // usado no template
      tituloMenu: localStorage.menu_titulo,       // se seu template usa isso

      // navegação
      onVoltar(){ history.back(); }, // handler citado no template
      
      paramsFilter: '',
      paramsLoading: false,
      paramsSaving: false,
      paramsList: [],
      menuIdDaProcedure: null,
      usarMenuSelecionado: true,
       showGrid:false,
       showParams:false,
       procedureSelecionada:'',
      // procedures
      proceduresOriginais: [],
      proceduresFiltradas: [],
      procedureSearch: '',
      // menus
      listaMenus: [],
      menusFiltrados: [],
      menuSearch: '',
      menuId: '',
      // parametros
      parametros: [],
      form: {},
      // tabela
      cabecalhos: [],
      // estados
      loadingExec: false,
      menuIdBusca: null,
      procedureManual: false,
      menuSemProcedure: false,
      _syncing: false,

    }
  },
  created(){
    this.carregarProcedures();
    this.carregarMenus();
  },

watch: {
  menuId (n, o) {
    if (this._syncing) return;
    if (n !== o && !this.procedureManual) {
      this.procedureSelecionada = '';
      this.procedureSearch = '';
      this.menuIdDaProcedure = null;
    }
  },
  
  /*
  procedureSelecionada(nova) {
    if (!nova) return;
      // sincroniza menu + parâmetros via headers -> cd_menu_id
      this.syncDaProcedure(nova);
      this.carregarParametrosDaProcedure();     
  }
  */
 
},

computed: {
  podeEditarProcedure () {
    return !!this.menuId || !!this.procedureManual;
  }
},

  methods: {
     abrirGrid(){
      if(!this.procedureSelecionada){ alert('Selecione uma procedure primeiro!'); return; }
      this.execGrid();
      this.showGrid = true;
    },

    async carregarPorMenuId(cdMenu) {
  const id = Number(cdMenu);
  if (!id) { alert('Informe um MenuId válido.'); return; }

  // limpa estado para não “vazar” menu anterior
  this.menuId = String(id);
  this.menuIdDaProcedure = null;
  this.procedureSelecionada = '';
  this.procedureSearch = '';
  this.cabecalhos = [];
  this.parametros = [];
  this.form = {};
  this.menuSemProcedure = false;
  this.procedureManual = false;
  let nomeProc = '';

  try {
    // 1) Cabeçalhos já gravados (se existir, é isso que você quer editar)
    const cabRes = await api.get(`headers/menuid/${id}`);
    const cab = Array.isArray(cabRes.data) ? cabRes.data : (cabRes.data?.rows || []);
    this.cabecalhos = cab;

    // 2) Procedure vinculada ao menu (se existir)

    //const procRes = await api.get(`procedure/menu/${id}`);
    //nomeProc = procRes?.data?.nome_procedure || procRes?.data?.nm_procedure || '';

    try {
  const procRes = await api.get(`procedure/menu/${id}`);
  nomeProc = procRes?.data?.nome_procedure || procRes?.data?.nm_procedure || '';
} catch (e) {
  // 404 aqui é esperado: menu não tem procedure vinculada
  if (e?.response?.status === 404) {
    nomeProc = '';
  } else {
    throw e; // outros erros (500, 401 etc) aí sim são problema
  }
}


    if (nomeProc) {
      this.procedureSelecionada = nomeProc;
      this.procedureSearch = nomeProc;
      this.menuSemProcedure = false;
    } else {
      this.menuSemProcedure = true;
      this.procedureManual = true; // libera manual quando não há vínculo
    }

    // 3) Parâmetros: preferir por MENU (porque é o que você quer editar por menu)
    try {
      await this.carregarParametrosPorMenu(id);
    } catch (e) {
      // fallback
      if (this.procedureSelecionada) await this.carregarParametrosDaProcedure();
    }

  } catch (e) {
    console.error('carregarPorMenuId()', e?.response?.status, e?.response?.data || e);
    alert('Falha ao carregar dados do MenuId.');
  }
},

    
    //
async syncDaProcedure(procedureName) {
  
  this._syncing = true;

  try {
    // 1) headers -> para descobrir cd_menu_id
    const rHead = await api.get(`headers/${encodeURIComponent(procedureName)}`);
    const cab = Array.isArray(rHead?.data) ? rHead.data : (rHead?.data?.rows || []);
    this.cabecalhos = cab;

    //console.log('Headers recebidos:', cab);

    const cd = cab?.[0]?.cd_menu_id || null;
    this.menuIdDaProcedure = cd;

    // REGRA: não sobrescreve menu já escolhido
    if (!this.menuId && cd) {
     this.menuId = cd;
    }

    // 3) parâmetros do MENU (fonte de verdade p/ o form)
    if (cd) {
      await this.carregarParametrosPorMenu(cd);
    } else {
      // fallback: tenta pelo nome da procedure, se existir a rota
      await this.carregarParametrosDaProcedure();
    }
  } catch (e) {
    console.error('syncDaProcedure()', e);
  }
   finally {
    this._syncing = false;
  }
},

// 2.2) Carrega parâmetros pelo MENU
async carregarParametrosPorMenu(cd_menu) {
  try {
    console.log('carregarParametrosPorMenu()', cd_menu);

    const r = await api.get(`parametros/menu/${cd_menu}`);
    const lista = Array.isArray(r?.data) ? r.data : (r?.data?.rows || []);
    this.parametros = lista;
    console.log('Parâmetros recebidos pelo menu:', lista);


    // monta o form (@param → chave sem @)
    const frm = {};
    (lista || []).forEach(p => {
     const k = String(p.nome_parametro || '').replace(/^@/, '');
      frm[k] = normalizeParamValue(p);   // <- usa helper para datas/bits/strings
    });
    this.form = frm;

  } catch (e) {
    console.error('carregarParametrosPorMenu()', e);
    this.parametros = [];
    this.form = {};
  }
},

// 2.3) Fallback: carrega parâmetros pela PROCEDURE (se a rota existir)

async carregarParametrosDaProcedure() {
  if (!this.procedureSelecionada) return;

  const nomeProc = this.procedureSelecionada;


  try {
    const { data } = await api.get(`parametros/${this.procedureSelecionada}`);
    const lista = Array.isArray(data) ? data : (data?.rows || []);
    this.parametros = lista;

    const frm = {};


    (lista || []).forEach(p => {
       const k = String(p.nome_parametro || '').replace(/^@/, '');
       frm[k] = normalizeParamValue(p);   // <- usa helper para datas/bits/strings
    });
    
    this.form = frm;

  } catch (e) {
    console.info('Sem parâmetros por procedure (ok).');
    this.parametros = [];
    this.form = {};
  }
},

// 2.4) Evento do q-select (Vue 3/Quasar 2) — chama o fluxo correto

async onProcedureSelecionada() {
  if (!this.procedureSelecionada) return;

    if (!this.menuId && !this.procedureManual) {
    alert('Primeiro selecione/informe o Menu (ou marque "Manual" para digitar a procedure).');
    this.procedureSelecionada = '';
    this.procedureSearch = '';
    return;
  }

   // MODO MANUAL: procedure não pode mexer no menu
  if (this.procedureManual) {
    this.menuIdDaProcedure = null;        // ou mantenha, se quiser exibir
    // NÃO chama syncDaProcedure aqui
    await this.carregarParametrosDaProcedure(); // só para montar form/exec
    return;
  }

    // MODO NORMAL: Menu manda. Se não tem menu, aí sim pode sincronizar.
  if (!this.menuId) {
    await this.syncDaProcedure(this.procedureSelecionada);
  } else {
    // Apenas carrega params para execução, sem mover menu
    await this.carregarParametrosDaProcedure();
  }

  //this.menuSemProcedure = false;

  //await this.syncDaProcedure(this.procedureSelecionada);
},

// 2.5) Troca de MENU → pega procedure do menu e sincroniza tudo

async onMenuChange () {

  // 1) limpa estado atual
  //this.menuIdDaProcedure = null;
  //
  
  const id = this.menuId;

  if (!id){ 
    this.cabecalhos = [];
    this.cabecalhos = [];
    this.parametros = [];
    this.form = {};
    this.menuIdDaProcedure = null;
  
    //this.parametros = [];
    //this.form = {};
  
    return;

  }


  try {
   
    // 2) cabeçalhos já gravados para esse menu (equivalente ao /headers/menuid do index.js antigo)
    const cabRes = await api.get(`headers/menuid/${id}`);
    const cab = Array.isArray(cabRes.data) ? cabRes.data : (cabRes.data?.rows || []);

    this.cabecalhos = cab;

    this.menuIdDaProcedure = id;   // sempre mostra o menu selecionado

    if (cab.length) {
      // badge mostra que ESTE menu tem cabeçalhos vinculados
      this.menuIdDaProcedure = id;
    }

    //console.log('onMenuChange()', this.menuId);

    // 3) pega a procedure vinculada a esse menu
    const procRes = await api.get(`procedure/menu/${this.menuId}`);
    console.log('Procedure recebida pelo menu:', procRes?.data);

    const nomeProc = procRes?.data?.nome_procedure || procRes?.data?.nm_procedure || '';

     this.procedureSelecionada = nomeProc;
     this.procedureSearch = nomeProc;

    if (nomeProc) {
       this.menuSemProcedure = false;
       this.procedureManual = false;

       this._syncing = true;
       this.procedureSelecionada = nomeProc;
       this.procedureSearch = nomeProc;
       this._syncing = false;

       await this.carregarParametrosDaProcedure();
       //

  } else {
    // menu sem vínculo: libera modo manual
    this.menuSemProcedure = true;
    this.procedureManual = true;
    this.procedureSelecionada = '';
    this.procedureSearch = '';
    this.parametros = [];
    this.form = {};
   }

    // 3) parâmetros são por PROCEDURE
   //await this.carregarParametrosDaProcedure();
    //

    // 4) carregar parâmetros por menu
    //const parRes = await api.get(`parametros/sync/${nomeProc}`);
    //const lista = Array.isArray(parRes.data) ? parRes.data : (parRes.data?.rows || []);
    //this.parametros = lista;

    // 5) montar o form usando nome do parâmetro sem @
    //const frm = {};
    //(lista || []).forEach(p => {
    //  const k = String(p.nome_parametro || '').replace(/^@/, '');
    //  frm[k] = normalizeParamValue(p);
    //});
    //this.form = frm;

  } catch (e) {
    console.error('onMenuChange()', e?.response?.status, e?.response?.data || e);
  }

    /*
    if (nomeProc) {
      this.procedureSelecionada = nomeProc;
      this.procedureSearch = nomeProc;
      await this.syncDaProcedure(nomeProc);
    } else {
      this.procedureSelecionada = '';
      this.menuIdDaProcedure = null;
      this.parametros = [];
      this.form = {};
    }
  } catch (e) {
    console.error('onMenuChange()', e?.response?.status, e?.response?.data || e);
  }
    */

},

    async execGrid(){
    this.gridLoading = true;
    try{
      const colRes = await api.get(`colunas/${this.procedureSelecionada}`);
      const cols = Array.isArray(colRes.data) ? colRes.data : [];
      const execRes = await api.post(`exec/${this.procedureSelecionada}`, this.form || {});
      const dados = Array.isArray(execRes.data) ? execRes.data : [];
      cols.filter(c=>c.formato_coluna==='shortDate').forEach(c=>{
        dados.forEach(r=>{
          const f = c.dataField || c.nome_coluna;
          if(r[f]) r[f] = new Date(r[f]);
        });
      });
      this.gridCols = cols;
      this.gridRows = dados;
    } finally { this.gridLoading = false; }
  },

    abrirEditorParametros(){
      if(!this.procedureSelecionada){
        alert('Selecione uma procedure primeiro!');
        return;
      }
      
      this.showParams = true;
      this.carregarParametrosModal();
      //

    },

     async carregarParametrosModal(){
       
      this.paramsLoading = true;

       try{     
      const { data } = await api.get(`parametros/${this.procedureSelecionada}`);
      this.paramsList = Array.isArray(data) ? data.map(p=>({
        ...p,
        valor_padrao: normalizeParamValue(p),
        obrigatorio: p.obrigatorio ? 1 : 0,
        editavel:    p.editavel ? 1 : 0
      })) : [];
    } finally { this.paramsLoading = false; }
  },

    salvarParametrosModal(novaLista){
      // se quiser atualizar algo no formulário principal depois de salvar
      console.log('Parâmetros salvos:', novaLista);
    },
  
    async syncParametros(){

       if (!this.procedureSelecionada) {
          alert('Selecione uma procedure primeiro!');
          return;
       }

      console.log('sincronizar parametros...');

    await api.post(`parametros/sync/${this.procedureSelecionada}`);
    await this.carregarParametrosModal();
    //
  },

  async salvarParametros(){
    this.paramsSaving = true;

    try{
      for(const p of this.paramsList){
        await api.put(`parametros/${p.id}`, {
           valor_padrao: normalizeParamValue(p),
           obrigatorio: p.obrigatorio ? 1 : 0,
           editavel: p.editavel ? 1 : 0,
           titulo_parametro: p.titulo_parametro ?? ''
        });
      }

      // 1) atualiza a lista usada no formulário principal
      this.parametros = this.paramsList.map(p => ({ ...p }));


      // reflete no form principal
      const frm = {};

         (this.parametros || []).forEach(p => {
      const k = String(p.nome_parametro || '').replace(/^@/, '');
      frm[k] = normalizeParamValue(p);
    });
      this.form = frm;
      this.showParams = false;
    } finally { this.paramsSaving = false; }
  },

  /* === Procedures === */

  async carregarProcedures () {

  try {
    const { data } = await api.get('procedures');

    this.proceduresOriginais = Array.isArray(data) ? data : [];
    this.proceduresFiltradas = [...this.proceduresOriginais];

    // NÃO selecionar automaticamente
    if (!this.procedureSelecionada) {
      this.procedureSelecionada = '';
      this.procedureSearch = '';
    }
  } catch (e) {
    console.error('Erro ao carregar procedures:', e);
  }
},



    async carregarProceduresOld2(){
      try {
      const { data } = await api.get('procedures');
       console.log('Procedures recebidas:', data);

      this.proceduresOriginais = Array.isArray(data) ? data : [];
      this.proceduresFiltradas = [...this.proceduresOriginais];
      this.procedureSelecionada = this.proceduresFiltradas[0] || '';     
      await this.carregarFormularioParametros();
       } catch (e) {
          console.error('Erro ao carregar procedures:', e);
        }
    },

    async atualizarProcedures(){
    const { data } = await api.post('procedures/update');
      // opcional: toast
      await this.carregarProcedures();
      //
    },

// substitua seu filtrarProcedures atual por este
filtrarProcedures(val, update) {
  // se veio de <input>, val pode ser um Event; se veio do QSelect, é string
  const texto = typeof val === 'string'
    ? val
    : (this.procedureSearch || '');

  const termo = (texto || '').toLowerCase();

  let filtradas = this.proceduresOriginais.filter(p =>
    (p || '').toLowerCase().includes(termo)
  );

  // permite digitar uma opção “livre”
  if (termo && !filtradas.includes(texto)) {
    filtradas.unshift(texto);
  }

  // se for QSelect, update é função; no <input>, aplicamos direto
  const apply = (typeof update === 'function') ? update : (fn) => fn();
  apply(() => { this.proceduresFiltradas = filtradas; });
},

 // 1) ao sair do input ou pressionar Enter: escolhe a procedure correspondente
  fixarProcedurePorTexto() {
    const texto = (this.procedureSearch || '').trim().toLowerCase();
    if (!texto) return;

    const base = Array.isArray(this.proceduresOriginais) ? this.proceduresOriginais : this.proceduresFiltradas || [];
    const igual = base.find(p => (p || '').toLowerCase() === texto);
    const contem = base.find(p => (p || '').toLowerCase().includes(texto));

    const escolhido = igual || contem;
    if (escolhido) {
      this.procedureSelecionada = escolhido;
      this.onProcedureSelecionada(); // sincroniza menu + parâmetros
    }
  },

 // 2) ao escolher a procedure (no q-select ou pelo input), sincroniza menu e parâmetros
  async onProcedureSelecionadax() {
    try {
        const resp = await api.get(`headers/${this.procedureSelecionada}`);
        const cab = Array.isArray(resp?.data) ? resp.data : (resp?.data?.rows || []);
        this.cabecalhos = cab;

        // pega o cd_menu_id (se existir) e posiciona o combo de menu
        this.menuIdDaProcedure = cab?.[0]?.cd_menu_id || null;
        if (this.menuIdDaProcedure) {
          this.menuId = this.menuIdDaProcedure;
        }
      

      // 2.2) carrega parâmetros da procedure (se sua API tiver essa rota)
      // ajuste o endpoint conforme seu backend (ex.: 'params/<procedure>' ou similar)
      try {
          const rp = await api.get(`parametros/${this.procedureSelecionada}`);
          this.parametros = Array.isArray(rp?.data) ? rp.data : (rp?.data?.rows || []);
      } catch (e) {
        // se não houver rota de params, evitamos quebrar a tela
        console.info('Sem rota de parâmetros para esta procedure (ok).');
        this.parametros = this.parametros || [];
      }

    } catch (err) {
      console.error('Erro ao sincronizar procedure:', err);
    }
  },
  
async carregarDadosDaProcedure(nomeProcedure) {
  try {
    // Buscar o menu vinculado
    const menuRes = await api.get(`menu/procedure/${nomeProcedure}`);
    this.menuId = menuRes.data?.cd_menu_ind || null;

    // Buscar parâmetros
    const paramRes = await api.get(`parametros/${nomeProcedure}`);
    this.parametros = Array.isArray(paramRes.data) ? paramRes.data : [];

    // Buscar colunas
    const colRes = await api.get(`headers/${nomeProcedure}`);
    this.cabecalhos = Array.isArray(colRes.data) ? colRes.data : [];

    // NOVO: pega o menu da procedure, se existir
    this.menuIdDaProcedure = this.cabecalhos?.[0]?.cd_menu_id || null;
    //

    // (opcional) já posiciona o combo no menu correspondente
    if (this.menuIdDaProcedure && !this.menuId) {
      this.menuId = this.menuIdDaProcedure;
    }

    // Preencher formulário

    const frm = {};
    this.parametros.forEach(p => {
      const k = String(p.nome_parametro || '').replace(/^@/, '');
      frm[k] = p.valor_padrao ?? '';
    });
    this.form = frm;
  } catch (e) {
    console.error('Erro ao carregar dados da procedure:', e);
  }
},

    /* === Menus === */
    async carregarMenus(){
      const { data } = await api.get('menus');
      this.listaMenus = data || [];
      this.menusFiltrados = [...this.listaMenus];
    },

    filtrarMenus(){
      const t = (this.menuSearch||'').toLowerCase();
      this.menusFiltrados = this.listaMenus.filter(m => (m.nm_menu||'').toLowerCase().includes(t));
    },

    /* === Parâmetros === */
    campoType(p){
      const t = (p.tipo_parametro||'').toLowerCase();
      if(t.includes('date')) return 'date';
      if(t.includes('int')) return 'number';
      return 'text';
    },
    async carregarFormularioParametros(){
      if(!this.procedureSelecionada) return;
      const { data } = await api.get(`parametros/${this.procedureSelecionada}`);
      this.parametros = data || [];
      const frm = {};
      this.parametros.forEach(p=>{ frm[p.nome_parametro.replace('@','')] = p.valor_padrao || '' });
      this.form = frm;
    },

    /* === Execução / Cabeçalhos === */

   async executarESalvar () {

     if (!this.procedureSelecionada) { alert('Selecione uma procedure.'); return; }
     if (!this.menuId) { alert('Selecione um menu.'); return; }

     this.loadingExec = true;

     try {
       // garante que temos os parâmetros carregados (menu → preferencial)
       if (!this.parametros || this.parametros.length === 0) {

       //if (this.menuId) await this.carregarParametrosPorMenu(this.menuId);
       //else
       await this.carregarParametrosDaProcedure();
       //

    }

    // monta objeto DE EXECUÇÃO com @chaves
    
    //const paramsExec = {};
    
    /*
    (this.parametros || []).forEach(p => {
      const chaveComArroba = String(p.nome_parametro || '@').startsWith('@')
        ? p.nome_parametro
        : '@' + String(p.nome_parametro || '');
      const chaveSemArroba = String(chaveComArroba).replace(/^@/, '');
      const val = this.form?.[chaveSemArroba] ?? p.valor_padrao ?? '';
      paramsExec[chaveComArroba] = val;
    });
    */

    // monta objeto DE EXECUÇÃO com chave SEM @  (compatível com execByProcedure/genHeadersFromExecution)
    
    const paramsExec = {};

    (this.parametros || []).forEach(p => {
      // nome do parâmetro sempre com @
      const nomeFull = String(p.nome_parametro || '').startsWith('@')
        ? String(p.nome_parametro)
        : '@' + String(p.nome_parametro || '');

      const chaveForm = nomeFull.replace(/^@/, '');

      let v = this.form?.[chaveForm];

      // se vier undefined ou string vazia, trata como NULL
      if (v === '' || v === undefined) {
        v = null;
      }

      const tipo = String(p.tipo_parametro || '').toLowerCase();

      // converte tipos numéricos / datas se vierem preenchidos
      if (v !== null) {
        if (tipo.includes('int')) {
          const n = parseInt(v, 10);
          v = Number.isNaN(n) ? null : n;
        } else if (
          tipo.includes('decimal') ||
          tipo.includes('numeric') ||
          tipo.includes('money') ||
          tipo.includes('float') ||
          tipo.includes('real')
        ) {
          const n = Number(v);
          v = Number.isNaN(n) ? null : n;
        } else if (tipo.includes('date')) {
          // aqui você já está usando yyyy-mm-dd, que o SQL aceita bem
          v = v || null;
        }
      }

      //paramsExec[nomeFull] = v;

      // use a chave SEM @
      paramsExec[chaveForm] = v;
      //
      


    });

    //

    const payload = {
      procedureName: this.procedureSelecionada,
      parameters: paramsExec,          // <- usa @chaves
      cd_menu: this.menuId,
        nm_menu: this.menuSelecionado?.nm_menu || this.nm_menu || ''
     // nm_menu: (this.listaMenus.find(m => String(m.cd_menu) === String(this.menuId)) || {}).nm_menu
    };

    console.log('Payload para execução/gravação de cabeçalhos:', payload);  

    
   // antes de dar POST, verifica se já existe
   const jaExiste = await api.get(`headers/menuid/${this.menuId}`);
   const existentes = Array.isArray(jaExiste.data) ? jaExiste.data : (jaExiste.data?.rows || []);

if (existentes.length > 0) {
  this.cabecalhos = existentes;
  alert('Este menu já possui cabeçalhos cadastrados. Não vou gerar novamente para evitar duplicação.');
  return;
}


    const { data } = await api.post('headers', payload);

    console.log('Resposta da execução/gravação de cabeçalhos:', data);

    this.cabecalhos = res.data.colunas || [];

    if (data?.colunas) this.cabecalhos = data.colunas;
    //await this.carregarCabecalhos();

    //await this.buscarCabecalhosPorMenuId(Number(this.menuId));

    alert(data?.message || 'Cabeçalhos gerados e gravados com sucesso!');
  } catch (e) {
    console.error('executarESalvar()', e?.response?.status, e?.response?.data || e);
    alert('Falha ao executar/gravar cabeçalhos.');
  } finally {
    this.loadingExec = false;
  }

},


    //
    async carregarCabecalhos(){
      if(!this.procedureSelecionada) return;
      const { data } = await api.get(`headers/${this.procedureSelecionada}`);
      this.cabecalhos = data || [];
    },

    atualizarCampo(obj, campo, valor){
      this.$set(obj, campo, valor);
    },
    async salvarCabecalhos(){
      let alterados = 0;
      for(const cab of this.cabecalhos){
        await api.put(`headers/${cab.id}`,{
          titulo_exibicao: cab.titulo_exibicao,
          visivel: cab.visivel,
          largura: cab.largura,
          qt_ordem_coluna: cab.qt_ordem_coluna,
          contagem: cab.contagem,
          soma: cab.soma,
          formato_coluna: cab.formato_coluna
        });
        alterados++;
      }
      alert(`✔️ ${alterados} cabeçalhos salvos com sucesso!`);
    },
    
    async buscarCabecalhosPorMenuId(){
      if(!this.menuIdBusca){ alert('Informe o ID do menu!'); return; }
      const { data } = await api.get(`headers/menuid/${this.menuIdBusca}`);
      if(!Array.isArray(data) || data.length===0){ alert('Nenhum cabeçalho encontrado para o menu informado.'); return; }
      this.cabecalhos = data;
    },


    async carregarParametrosDaProcedureOld () {
    if (!this.procedureSelecionada) return;
    const { data } = await api.get(`parametros/${this.procedureSelecionada}`);
    this.parametros = Array.isArray(data) ? data : [];
    // prepara form com valores padrão (@param → chave sem @)
    const frm = {};
    this.parametros.forEach(p => {
      const k = String(p.nome_parametro || '').replace(/^@/, '');
      frm[k] = p.valor_padrao ?? '';
    });
    this.form = frm;
  },

  async carregarCabecalhosDaProcedure () {
    if (!this.procedureSelecionada) return;
    const { data } = await api.get(`headers/${this.procedureSelecionada}`);
    this.cabecalhos = Array.isArray(data) ? data : [];
  },

  }
}
</script>
<style scoped>
/* trava fixa abaixo do header; não interfere no Quasar */
#meta-form .mf-guard{
  height: 22px;              /* ajuste fino: 18–28px conforme a espessura da sua toolbar */
  pointer-events: none;      /* não captura clique */
}

/* garante que nada “pinte” por cima do header */
#meta-form{
  position: relative;
  z-index: 0;
  isolation: isolate;
  padding: 0 16px 24px;      /* sem padding-top aqui; a guarda resolve o respiro */
}


/* layout leve por seção (sem interferir no Quasar) */
#meta-form .mf-row{ display:flex; flex-wrap:wrap; align-items:center; gap:12px; }
#meta-form .mf-card{
  background:#fff; border:1px solid #e5e7eb; border-radius:14px;
  padding:12px; margin:12px 0; box-shadow:0 6px 16px rgba(2,6,23,.06);
}

/* utilidades */
#meta-form .mf-lbl{ font-weight:600; }
#meta-form .mf-btn{
  border:0; border-radius:12px; padding:8px 12px; font-weight:700; cursor:pointer;
  box-shadow:0 6px 16px rgba(2,6,23,.06);
}
#meta-form .mf-primary{ background:#0d6efd; color:#fff; }
#meta-form .mf-accent{  background:#fd7e14; color:#fff; }
#meta-form .mf-secondary{ background:#eef2f7; color:#111827; }

/* largura opcional sem mexer no tema do Quasar */
#meta-form .mf-qselect{ min-width:340px; }

/* listbox não estoura a tela */
/* listbox com rolagem interna e largura previsível */
#meta-form .menu-list{
  display: block;
  width: 520px;          /* pode mudar para 100% se preferir, mantendo o max */
  max-width: 100%;
  max-height: 260px;     /* controla a altura visível */
  overflow: auto;
  box-sizing: border-box;
}

/* no container flex, não deixe o select encolher a ponto de quebrar */
#meta-form .mf-row .menu-list{
  flex: 0 0 520px;       /* mesma largura acima */
}


/* tabela leve (não interfere no DevExtreme) */
#meta-form .mf-table{
  width:100%; border-collapse:collapse; background:#fff; border:1px solid #e5e7eb; border-radius:12px; overflow:hidden;
}
#meta-form .mf-table thead th{ background:#0d6efd; color:#fff; text-align:left; padding:8px 10px; }
#meta-form .mf-table tbody td{ border-top:1px solid #e5e7eb; padding:8px 10px; }


.mf-input-inline {
  width: 100%;
  box-sizing: border-box;
  display: block;
  border: none;
  background: transparent;
  padding: 0 4px;
  outline: none;
}

.mf-input-inline:focus {
  outline: 1px solid #999;
  border-radius: 3px;
}

</style>
