<template>
  <div>
    <top-menu
      :display-title="displayTitle"
      :ic_modal_pesquisa="ic_modal_pesquisa"
      :qt_registro="qt_registro"
      :record-count="recordCount"
      :mostrar-toolbar="mostrarToolbar"
      :ui-lite="uiLite"
      :cd_tabela="cd_tabela"
      :cd_form_modal="cd_form_modal"
      :cd_menu_processo="cd_menu_processo"
      :filtros="filtros"
      :ic_card_menu="ic_card_menu"
      :exibir-como-cards="exibirComoCards"
      :ic_treeview_menu="ic_treeview_menu"
      :exibir-como-tree="exibirComoTree"
      :cd-menu="cdMenu"
      :cd_menu="cd_menu"
      :is-hidden="isHidden"
      :engine="this"
      @voltar="onVoltar"
      @novo="toolbarNovo"
      @filtros="toolbarFiltros"
      @refresh="toolbarRefresh"
      @detalhe="toolbarDetalhe"
      @excel="toolbarExcel"
      @pdf="toolbarPDF"
      @relatorio="toolbarRelatorio"
      @dash="toolbarDash"
      @processos="toolbarProcessos"
      @mapa-atributos="toolbarMapaAtributos"
      @info="toolbarInfo"
      @drawer-filtros="toolbarDrawerFiltros"
      @update:exibirComoCards="exibirComoCards = $event"
      @update:exibirComoTree="exibirComoTree = $event"
      @menu-chip="showAvisoConfig = true"
    >
      <template #toolbar-left="{ engine }">
        <slot name="toolbar-left" :engine="engine" />
      </template>
      <template #toolbar-right="{ engine }">
        <slot name="toolbar-right" :engine="engine" />
      </template>
    </top-menu>
  </div>
</template>

<script>
/*
  <unico-form-especial
    :cd_menu_entrada="MENU_ID"
    :cd_acesso_entrada="cdAcesso"
    :modo_inicial="modoInicial"
    :embedMode="embedMode"
    :registro_pai="registroPai"
    :cd_chave_registro="cdChaveRegistro"
    :overrides="overrides"
    :hooks="hooks"
    @selecionou="onSelecionou"
    @voltar="onVoltar"
    @fechar="onFechar"
  />
*/

import TopMenu from "@/components/topMenu.vue";
import UnicoFormEspecial from "@/views/unicoFormEspecial.vue";

const MENU_ID = 8912;

export default {
  name: "my_8912",
  components: { UnicoFormEspecial, TopMenu },

  props: {
    embedMode: { type: Boolean, default: false },
    registroPai: { type: Object, default: null },
    cdChaveRegistro: { type: Number, default: 0 },
  },

  data() {
    return {
      MENU_ID,
      cdAcesso: Number(localStorage.cd_chave_pesquisa || 0),
      modoInicial: "GRID",

      overrides: {
        title: "Teste",
        gridPageSize: 200,
      },

      hooks: {},
    };
  },

  methods: {
    onSelecionou(registro) {
      // afterRowSelect (ou equivalente)
    },
    onVoltar() {
      this.$router.back();
    },
    onFechar() {
      this.$router.back();
    },
  },
};
</script>
