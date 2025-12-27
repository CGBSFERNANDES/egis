<template>
<div class="simple">
  <dx-scroll-view class="simple">
     <div ><slot /></div>
  </dx-scroll-view>
</div>
</template>

<script>
import DxScrollView from "devextreme-vue/scroll-view";

export default {
  name: 'Simple',

  components: {
    DxScrollView
  }
};
</script>

<style lang="scss">
.simple {
    width: 100vw;
    margin: 0 none;
}
</style>
