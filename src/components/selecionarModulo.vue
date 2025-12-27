<template>
  <div class="selmod-wrapper q-pa-md">
    <!-- Header -->
    <div class="row items-center q-col-gutter-md q-mb-md">
      <div class="text-h5 col-grow">Módulos</div>

      <!-- contador -->
      <div class="text-subtitle2 text-grey-7">
        {{ qtdLiberados }} módulo{{ qtdLiberados === 1 ? '' : 's' }} liberado{{ qtdLiberados === 1 ? '' : 's' }}!
      </div>
    </div>

    <!-- Filtros -->
    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-12 col-md-6">
        <q-input
          dense outlined
          v-model="termo"
          placeholder="Buscar módulo..."
          debounce="200"
          clearable
          @input="salvarFiltro"
        >
          <template v-slot:prepend><q-icon name="search"/></template>
        </q-input>
      </div>

      <div class="col-12 col-md-4">
        <q-select
          dense outlined emit-value map-options
          v-model="cadeia"
          :options="opcoesCadeia"
          option-label="label" option-value="value"
          placeholder="Todas Cadeias"
          @input="salvarFiltro"
        />
      </div>
    </div>

    <!-- Grid de módulos -->
    
    <div class="row q-col-gutter-xl">
      <div
        v-for="m in filtrados"
        :key="m.cd_modulo"
        class="col-12 col-md-6 col-lg-4"
      >
        <q-card class="selmod-card cursor-pointer" @click="abrirModulo(m)">
          <div class="row items-center q-pa-md">
            <div class="selmod-icon" style="margin-left: 25px">{{ (m.sg_modulo || 'Eg').slice(0,2) }}</div>
            <div class="col q-ml-md">
              <div class="row items-center">
                <div class="text-subtitle1 text-weight-bold q-mr-sm">
                  {{ m.nm_modulo }}
                </div>
                <q-badge color="orange-8" text-color="white" class="q-ml-xs">
                  {{ m.cd_modulo }}
                </q-badge>
              </div>
              <div class="text-grey-6">
                {{ m.nm_cadeia_valor || '—' }}
              </div>
            </div>
          </div>

          <!-- botão legado (quando permitido) -->
          <q-separator />
          <div class="q-pa-sm" v-if="m.ic_exec_modulo === 'S'">
            <q-btn
              color="orange-8" text-color="white" unelevated
              label="Abrir Versão Legada"
              @click.stop="abrirLegado(m)"
            />
          </div>
        </q-card>
      </div>
    </div>

    <div v-if="!carregando && !filtrados.length" class="q-my-xl text-center text-grey-6">
      Nenhum módulo encontrado.
    </div>

    <q-inner-loading :showing="carregando">
      <q-spinner size="42px" color="primary" />
    </q-inner-loading>
  </div>
</template>

<script>

/**
 * SelecionarModulo.vue — Vue 2 + Quasar
 * - carrega /modulos
 * - busca por termo e cadeia de valor
 * - mostra contagem de "liberados"
 * - abrir módulo (atualiza menu lateral, troca de view)
 * - abrir versão legada quando permitido
 * (Portado a partir do modulos.js) 
 */

export default {
  name: 'selecionarModulo',
  props: {
    value: { type: Boolean, default: true },          // opcional se for usar dentro de <q-dialog>
  },
  data () {
    return {
      carregando: false,
      lista: [],
      termo: sessionStorage.getItem('filtro_termo_modulo') || '',
      cadeia: sessionStorage.getItem('filtro_cadeia_valor') || '',
      moduloStartId: Number(sessionStorage.getItem('cd_modulo_start') || 0)
    }
  },
  computed: {
    opcoesCadeia () {
      const set = new Set(this.lista.map(m => m.nm_cadeia_valor).filter(Boolean))
      return [{ label: 'Todas Cadeias', value: '' }, ...Array.from(set).map(c => ({ label: c, value: c }))]
    },
    filtrados () {
      const t = (this.termo || '').toLowerCase()
      const c = this.cadeia || ''
      return this.lista.filter(m =>
        (!c || m.nm_cadeia_valor === c) &&
        (
          (m.nm_modulo || '').toLowerCase().includes(t) ||
          (m.sg_modulo || '').toLowerCase().includes(t)
        )
      )
    },
    qtdLiberados () {
      return this.lista.filter(m => m.ic_liberado).length
    }
  },
  created () {
    this.carregarModulos()
  },
  methods: {
    salvarFiltro () {
      sessionStorage.setItem('filtro_cadeia_valor', this.cadeia || '')
      sessionStorage.setItem('filtro_termo_modulo', this.termo || '')
    },

    async carregarModulos () {
      this.carregando = true
      try {
        const res = await fetch('/modulos', { credentials: 'include' })
        if (!res.ok) throw new Error(`Erro ${res.status}`)
        const data = await res.json()
        this.lista = Array.isArray(data) ? data : []
      } catch (err) {
        console.error('Erro ao carregar módulos:', err)
        this.$q.notify({ type:'negative', message:'Falha ao carregar módulos', position:'top-right' })
      } finally {
        this.carregando = false
      }
    },

    async abrirModulo (modulo) {
      // guarda contexto
      sessionStorage.setItem('cd_modulo', modulo.cd_modulo)
      sessionStorage.setItem('nm_modulo', modulo.nm_modulo)
      sessionStorage.setItem('origem_modulo_path', 'modulos')
      sessionStorage.setItem('origem_modulo_id', modulo.cd_modulo)
      sessionStorage.setItem('origem_modulo_nome', modulo.nm_modulo)

      // atualiza menu lateral
      try {
        const r = await fetch(`/api/menu-lateral?modulo=${modulo.cd_modulo}`, { credentials:'include' })
        const menuData = await r.json()
        // caso você tenha um store ou evento para atualizar sidebar:
        this.$emit('menu-lateral:update', menuData)
      } catch (e) {
        console.warn('Menu lateral não pôde ser atualizado agora.', e)
      }

      // navega ou apenas emite evento para quem está hospedando o seletor
      this.$emit('selecionado', modulo)

      // se usa views tipo “kanban-view”, você pode emitir outro evento:
      // this.$emit('trocar-view', 'kanban')
    },

    abrirLegado (modulo) {
      // chama serviço local (mesma lógica do seu modulos.js)
      const host = window.location.hostname
      const body = { nomeModulo: modulo.exePath, parametros: modulo.parametros || '' }

      this.$q.loading.show()
      fetch(`http://${host}:3000/executar`, {
        method:'POST',
        headers:{ 'Content-Type':'application/json' },
        body: JSON.stringify(body)
      })
      .then(res => res.text())
      .then(msg => this.$q.notify({ type:'positive', message: msg, position:'top-right' }))
      .catch(err => this.$q.notify({ type:'negative', message: String(err), position:'top-right' }))
      .finally(() => this.$q.loading.hide())
    }
  }
}
</script>

<style scoped>
.selmod-card {
  border-radius: 14px;
  transition: box-shadow .2s ease, transform .1s ease;
}
.selmod-card:hover { transform: translateY(-1px); box-shadow: 0 6px 18px rgba(0,0,0,.08); }
.selmod-icon {
  width: 44px; height: 44px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  background: #ff9800; color: #fff; font-weight: 700;
}
</style>
