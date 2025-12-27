<template>
  <div>
    <q-dialog v-if="1 == 2" class="dialog" persistent full-width v-model="toolbar">
      <q-card class="bg-light-blue-1 ">
        <q-toolbar>
          <q-avatar color="blue-10" text-color="white" icon="back_hand">

          </q-avatar>

          <q-toolbar-title><span class="text-weight-bold">Atividades</span> em Aberto</q-toolbar-title>

          <q-btn flat round dense icon="close" v-close-popup />
        </q-toolbar>

        <q-card-section>
          <grid :cd_menuID="this.cd_menu" :cd_apiID="this.cd_api" ref="grid_c">
          </grid>


        </q-card-section>
      </q-card>
    </q-dialog>

    <grid :cd_menuID="this.cd_menu" :cd_apiID="this.cd_api" ref="grid_c">
    </grid>
  </div>
</template>

<script>
import grid from '../views/grid';


export default {
  props: {
  },
  components: {

    grid

  },

  data() {
    return {
      cd_api: 0,
      cd_menu: 0,
      toolbar: true
    }
  },
  created() {
    this.cd_api = 684;
    this.cd_menu = 7349;
    localStorage.cd_etapa = 0;
  }

}
</script>

<style scoped>
#container {
  padding: 10px;
}

#container ul {
  list-style-type: none;
  text-align: center;
}

#container ul li {
  display: inline-block;
  width: 160px;
  margin: 10px;
}

#container ul li img {
  width: 100px;
}

.dx-popup-content p {
  margin-bottom: 10px;
  margin-top: 0;
}

.dialog {
  position: absolute;
  z-index: -1;
}
</style>