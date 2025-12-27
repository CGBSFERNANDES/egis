<template>
  <div class="content-block" v-show="footerVisible">
    <footer class="footer">
      <span>
        <a
          ><b>
            {{
              `GBS TECNOLOGIA E CONSULTORIA © 2021-${new Date().getFullYear()} `
            }}
          </b>
        </a>
        <a class="gbs-dados" href="http://www.gbstec.com.br" target="_blank">
          <b>www.gbstec.com.br </b></a
        >
      </span>
    </footer>
  </div>
</template>

<script>
export default {
  computed: {
    footerVisible() {
      return this.$store && this.$store.getters && typeof this.$store.getters.footerVisible !== "undefined"
        ? this.$store.getters.footerVisible
        : true;
    },
  },
  created() {
    if (this.$store._mutations.SET_Usuario.nm_cor_empresa) {
      document.documentElement.style.setProperty(
        "--cor-principal",
        this.$store._mutations.SET_Usuario.nm_cor_empresa,
      );
    } else {
      document.documentElement.style.setProperty("--cor-principal", "#ff5722");
    }
  },
  methods: {
    hideFooter(id = "manual") {
      if (this.$store && this.$store.commit) this.$store.commit("ADD_FOOTER_HIDE_REQUEST", id);
    },
    showFooter(id = "manual") {
      if (this.$store && this.$store.commit) this.$store.commit("REMOVE_FOOTER_HIDE_REQUEST", id);
    },
    toggleFooter(id = "manual") {
      if (!this.$store || !this.$store.getters) return;
      const visible = this.$store.getters.footerVisible;
      if (visible) {
        this.hideFooter(id);
      } else {
        this.showFooter(id);
      }
    },
  },
};
</script>

<style lang="scss">
@import "../themes/generated/variables.base.scss";
@import url("../views/views.css");

.dx-theme-material-typography a {
  color: var(--cor-principal);
}

.footer {
  display: block;
  margin-top: 1px;
  margin-bottom: 1px;
  color: var(--cor-principal);
  border-top: 1px solid rgba(0, 0, 0, 0.1);
  padding-top: 5px;
  padding-bottom: 10px;
  justify-content: flex-end;
  font-size: 15px;
}
.gbs-dados {
  float: right;
  right: 10px;
}
</style>
