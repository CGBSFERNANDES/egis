<template>
  <div>
    <h2 class="content-block">{{ tituloMenu }}</h2>
    <q-tabs
      v-model="index"
      inline-label
      mobile-arrows
      align="justify"
      style="border-radius:20px"
      class="shadow-2 margin1 bg-empresa-cor"
    >
      <q-tab :name="0" icon="person" label="Clientes" />
      <q-tab :name="1" icon="map" label="Mapa" />
    </q-tabs>
    <transition name="slide-fade">
      <div class="margin1" v-if="index == 0">
        <grid
          :cd_menuID="7804"
          :cd_apiID="619"
          :cd_parametroID="9"
          :cd_consulta="0"
          :nm_json="{}"
          @linha="linhaSelecionada($event)"
          :cd_tipo_consultaID="2"
          ref="grid_c"
        >
        </grid>
      </div>
    </transition>
    <transition name="slide-fade">
      <div v-if="index == 1">
        <div class="margin1" v-if="mostra_mapa == true">
          <div class="row">
            <div v-if="array_cliente.length > 0" class="text-h6 col margin1">
              Quantidade de Clientes<q-badge color="primary">{{
                `${this.array_cliente.length}`
              }}</q-badge>
            </div>
            <q-btn
              v-if="vendedor"
              dense
              :style="{ backgroundColor: vendedor.nm_cor_vendedor }"
              rounded
              icon="person"
              class="q-ml-xl col-1 margin1"
            >
              <q-badge color="red" floating>{{
                `${this.ClientesVendedor.length}`
              }}</q-badge>
            </q-btn>
            <q-select
              class="col margin1"
              rounded
              standout
              v-model="vendedor"
              :options="listaVendedor"
              option-value="cd_vendedor"
              option-label="nm_vendedor"
              @input="SelectVendedor()"
              label="Vendedor"
            >
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
            </q-select>
          </div>
          <GoogleMap
            :cd_tipo_mapaID="iTipoRoteiro"
            :cd_parametroID="cd_parametro"
            :cd_documentoID="cd_documento"
            :RomaneioU="true"
            :painelCliente="true"
            @dataClientes="dadosCliente($event)"
            :obj_clienteProps="obj_cliente"
            :array_clienteProps="ClientesVendedor"
            :object_Get="consulta_dia"
          >
          </GoogleMap>
        </div>
      </div>
    </transition>
    <!------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando :mensagemID="mensagem"></carregando>
    </q-dialog>
    <!---------------------------------------------------------->
  </div>
</template>

<script>
import GoogleMap from "../views/GoogleMap.vue";
import Menu from "../http/menu";
import dataEscrita from "../http/dataEscrita";
import carregando from "../components/carregando.vue";
import grid from "../views/grid.vue";

export default {
  name: "painelCliente",
  props: {
    cd_tipoRoteiroID: { type: Number, default: 0 },
    cd_parametroID: { type: Number, default: 0 },
    cd_documentoID: { type: Number, default: 0 },
  },
  components: {
    GoogleMap,
    carregando,
    grid,
  },
  data() {
    return {
      iTipoRoteiro: 0,
      cd_parametro: 0,
      cd_documento: 0,
      index: 0,
      tituloMenu: "",
      obj_cliente: {},
      array_cliente: [],
      listaVendedor: [],
      ClientesVendedor: [],
      vendedor: "",
      popNovoRomaneio: false,
      itinerario: "",
      hoje: dataEscrita.DataHoje(),
      hoje_sql: "",
      dt_previsao: "",
      maximizedToggle: true,
      popRelatorio: false,
      api_i: "639/904", //pr_egisnet_crud_itinerario
      dataset_itinerario: [],
      mostra_iti: true,
      mostra_mapa: true,
      consulta_dia: {},
      load: false,
      mensagem: "",
    };
  },

  created() {
    this.iTipoRoteiro = this.cd_tipoRoteiroID;
    this.cd_parametro = this.cd_parametroID;
    this.cd_documento = this.cd_documentoID;
    this.dt_previsao = this.hoje;
  },
  async mounted() {
    this.mensagem = "Carregando menu...";
    this.load = true;

    var dados = await Menu.montarMenu(
      localStorage.cd_empresa,
      localStorage.cd_menu,
      localStorage.cd_api,
    ); //'titulo';
    this.tituloMenu = dados.nm_menu_titulo;
    this.load = false;
  },

  methods: {
    sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },
    linhaSelecionada(e) {
      this.obj_cliente = e;
    },
    dadosCliente(e) {
      this.array_cliente = e;
      this.listaVendedor = e
        .map((pedido) => pedido)
        .filter(
          (vendedor, index, self) =>
            index ===
            self.findIndex((v) => v.cd_vendedor === vendedor.cd_vendedor),
        );
      //Gera uma cor aleatória para cada vendedor
      this.listaVendedor.map((v) => {
        v.nm_cor_vendedor = `#${String(Math.random()).slice(2, 8)}`;
      });
    },
    SelectVendedor() {
      this.ClientesVendedor = this.array_cliente.filter(
        (v) => v.cd_vendedor === this.vendedor.cd_vendedor,
      );
    },
  },
};
</script>

<style scoped>
@import url("../views/views.css");
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}
</style>
