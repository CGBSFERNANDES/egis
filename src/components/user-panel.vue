<template>
  <div class="xuser-panel">
    <div class="user-info">
      <div class="image-container">
        <!-- <img class="user-image" :src="pegaImg()" alt="Foto de Perfil" /> -->
        <img class="user-image" :src="imagem" alt="Foto de Perfil" />
      </div>
      <div class="user-name">
        <h6 class="usu">{{ musuario }}<br />{{ mdestinatario }}</h6>
      </div>
    </div>
    <dx-context-menu
      v-if="menuMode === 'context'"
      target=".user-button"
      :items="menuItems"
      :width="230"
      show-event="dxclick"
      css-class="user-menu"
    >
      <dx-position my="top center" at="bottom center" />
    </dx-context-menu>

    <dx-list
      v-if="menuMode === 'list'"
      class="dx-toolbar-menu-action"
      :items="menuItems"
    />
  </div>
</template>

<script>

import DxContextMenu, { DxPosition } from "devextreme-vue/context-menu";
import axios from "axios";

//menu com as funçoes do menu do usuário
import DxList from "devextreme-vue/list";

export default {
  props: {
    menuMode: String,
    menuItems: Array,
    usuario: String,
    destinatario: String,
  },
  data() {
    return {
      musuario: "",
      mdestinatario: "",
      imagem: this.$store._mutations.SET_Usuario.nm_caminho_imagem,
    };
  },
  async created() {
    this.musuario = "";
    this.mdestinatario = "";
    this.empresa = localStorage.fantasia;
  },
  mounted() {
    this.musuario = localStorage.usuario;
    this.mdestinatario = localStorage.nm_destinatario;
    if (!localStorage.nm_destinatario === "") {
      this.mdestinatario = localStorage.nm_destinatario;
    }
  },
  components: {
    DxContextMenu,
    DxPosition,
    DxList,
  },

  methods: {
    async pegaImg() {
      try {
        let busca_img = "http://localhost:3065/files/segunda-img.png";
        return busca_img;
      } catch {
        var imagem = "";
        imagem =
          "data:image/jpeg;base64," +
          localStorage.vb_imagem64.replace('[{"i":"', "").replace('"}]', "");
        return imagem;
      }
    },
  },
};
</script>

<style lang="scss">
@import "../themes/generated/variables.base.scss";

.user-info {
  display: flex;
  align-items: center;

  .dx-toolbar-menu-section & {
    padding: 10px 6px;
    border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  }

  .image-container {
    border-radius: 50%;
    height: 60px;
    width: 60px;
    margin: 0 4px;

    .user-image {
      width: 100%;
      height: 100%;
      border-radius: 50%;
    }
  }
}

.xuser-panel {
  .dx-list-item .dx-icon {
    vertical-align: middle;
    align-items: center center;
    color: $base-text-color;
    // margin-right: 16px;
  }
  .dx-rtl .dx-list-item .dx-icon {
    margin-right: 0;
    margin-left: 16px;
  }
}

.dx-context-menu.user-menu.dx-menu-base {
  &.dx-rtl {
    .dx-submenu .dx-menu-items-container .dx-icon {
      margin-left: 16px;
    }
  }
  .dx-submenu .dx-menu-items-container .dx-icon {
    margin-right: 16px;
  }
  .dx-menu-item .dx-menu-item-content {
    padding: 0px 15px 4px;
  }
}

.dx-theme-generic .user-menu .dx-menu-item-content .dx-menu-item-text {
  padding-left: 4px;
  padding-right: 4px;
}

.xuser-panel .usu {
  margin: 0;
  font-size: 14px;
  line-height: 15px;
  padding-left: 10px;
}
</style>
