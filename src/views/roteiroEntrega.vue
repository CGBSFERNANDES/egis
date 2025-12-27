<template>
  <div>
    <h2 class="content-block">{{ tituloMenu }}</h2>
    <div class="borda-bloco margin1 shadow-2">
      <div v-if="flag_romaneioUnico == false">
        <div class="row items-center">
          <q-input
            v-model="dt_previsao"
            class="col margin1"
            mask="##/##/####"
            label="Data"
            @blur="carregaItinerario()"
          >
            <template v-slot:prepend>
              <q-icon name="today" />
            </template>
            <template v-slot:append>
              <q-btn
                icon="event"
                color="orange-10"
                round
                size="sm"
                class="cursor-pointer"
              >
                <q-popup-proxy
                  ref="qDateProxy"
                  cover
                  transition-show="scale"
                  transition-hide="scale"
                >
                  <q-date
                    mask="DD/MM/YYYY"
                    color="orange-10"
                    id="data-pop"
                    v-model="dt_previsao"
                    class="qdate"
                  >
                    <div class="row items-center justify-end">
                      <q-btn
                        v-close-popup
                        round
                        color="orange-10"
                        icon="close"
                        size="sm"
                      />
                    </div>
                  </q-date>
                </q-popup-proxy>
              </q-btn>
            </template>
          </q-input>

          <q-select
            v-if="mostra_iti == true"
            label="Itinerário"
            class="margin1 col"
            v-model="itinerario"
            input-debounce="0"
            :options="this.dataset_itinerario"
            option-value="cd_controle"
            option-label="mostra_lokup"
          >
            <template v-if="itinerario" v-slot:append>
              <q-icon
                name="cancel"
                @click.stop="itinerario = null"
                class="cursor-pointer"
              />
            </template>
            <template v-slot:prepend>
              <q-icon name="map" />
            </template>
          </q-select>
          <div
            class="col text-bold text-subtitle-2 margin1 items-center text-center"
            v-else
          >
            {{ this.dataset_itinerario[0].Msg }}
          </div>
        </div>

        <div class="row">
          <q-btn
            color="orange-10"
            rounded
            class="margin1"
            outline
            icon="search"
            label="Pesquisar"
            @click="carregaDados()"
          />
          <q-btn
            color="orange-10"
            rounded
            class="margin1"
            outline
            icon="info"
            label="Informações"
            @click="abreRelatorio()"
          />
          <q-btn
            color="orange-10"
            rounded
            class="margin1"
            outline
            icon="dialpad"
            label="Romaneio"
            @click="popNovoRomaneio = true"
          />
        </div>
      </div>
    </div>

    <div class="margin1" v-if="mostra_mapa == true">
      <GoogleMap
        v-if="popNovoRomaneio == false"
        :cd_tipo_mapaID="iTipoRoteiro"
        :cd_parametroID="cd_parametro"
        :cd_documentoID="cd_documento"
        :RomaneioU="flag_romaneioUnico"
        :object_Get="consulta_dia"
      >
      </GoogleMap>
    </div>

    <!------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando :mensagemID="mensagem"></carregando>
    </q-dialog>
    <!---------------------------------------------------------->
    <q-dialog
      v-model="popRelatorio"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-orange-10">
          <q-space />

          <q-btn
            dense
            class="text-white"
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-white text-primary"
              >Minimize</q-tooltip
            >
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            class="text-white"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-white text-primary"
              >Maximize</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" class="text-white" v-close-popup>
            <q-tooltip class="bg-white text-primary">Close</q-tooltip>
          </q-btn>
        </q-bar>
        <div class="text-h5 text-bold margin1 ">
          Informações - {{ dt_previsao }}
        </div>

        <div class="margin1">
          <grid
            :cd_menuID="7281"
            :cd_apiID="621"
            :cd_parametroID="0"
            :cd_consulta="0"
            :cd_tipo_consultaID="2"
            :nm_json="{}"
            ref="grid_c"
          >
          </grid>
        </div>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------------------------>
    <q-dialog
      v-model="popNovoRomaneio"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-3">
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white"
              >Minimizar</q-tooltip
            >
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section class="q-pt-none">
          <romaneio :cd_romaneioID="0" :alteraEndereco="false" />
        </q-card-section>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import GoogleMap from "../views/GoogleMap.vue";
import Menu from "../http/menu";
import dataEscrita from "../http/dataEscrita";
import formataData from "../http/formataData";
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import carregando from "../components/carregando.vue";
import grid from "../views/grid.vue";

export default {
  name: "roteiroEntrega",
  props: {
    cd_tipoRoteiroID: { type: Number, default: 0 },
    cd_parametroID: { type: Number, default: 0 },
    cd_documentoID: { type: Number, default: 0 },
    romaneioUnico: { type: Boolean, default: false },
  },
  components: {
    GoogleMap,
    carregando,
    grid,
    romaneio: () => import("../views/romaneio.vue"),
  },
  data() {
    return {
      iTipoRoteiro: 0,
      cd_parametro: 0,
      cd_documento: 0,
      tituloMenu: "",
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
      flag_romaneioUnico: false,
    };
  },

  created() {
    this.iTipoRoteiro = this.cd_tipoRoteiroID;

    this.cd_parametro = this.cd_parametroID;
    this.cd_documento = this.cd_documentoID;
    this.flag_romaneioUnico = this.romaneioUnico;

    this.dt_previsao = this.hoje;
  },
  async mounted() {
    this.mensagem = "Carregando menu...";
    this.load = true;

    var dados = await Menu.montarMenu(
      localStorage.cd_empresa,
      localStorage.cd_menu,
      localStorage.cd_api
    ); //'titulo';
    this.tituloMenu = dados.nm_menu_titulo;
    this.load = false;
    await this.carregaItinerario();
  },
  watch: {
    dt_previsao() {
      this.hoje_sql = formataData.formataDataSQL(this.dt_previsao);
    },
  },

  methods: {
    async abreRelatorio() {
      if (this.dt_previsao.length != 10) {
        notify("Digite uma data válida!");
        return;
      }
      await Menu.montarMenu(localStorage.cd_empresa, 7285, 623); //'titulo';
      localStorage.dt_base = formataData.formataDataSQL(this.dt_previsao);
      this.popRelatorio = true;
    },
    sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },
    async carregaDados() {
      this.mostra_mapa = false;
      let iti;
      let ent;
      if (this.itinerario == "" || this.itinerario == null) {
        iti = null;
        ent = null;
      } else {
        iti = this.itinerario.cd_itinerario;
        ent = this.itinerario.cd_entregador;
      }

      notify("Aguarde...");
      this.consulta_dia = {
        cd_parametro: 9,
        cd_itinerario: iti,
        cd_entregador: ent,
        dt_selecao: this.hoje_sql,
        cd_empresa: localStorage.cd_empresa,
      };
      await this.sleep(100);
      this.mostra_mapa = true;
    },
    async carregaItinerario() {
      if (this.dt_previsao.length != 10) {
        notify("Data inválida");
        return;
      }
      this.mensagem = "Carregando informações...";
      this.load = true;

      this.mostra_iti = false;
      this.dataset_itinerario = [];

      let c = {
        cd_parametro: 8,
        dt_consulta: this.hoje_sql,
      };
      this.dataset_itinerario = await Incluir.incluirRegistro(this.api_i, c);
      if (this.dataset_itinerario[0].Cod == 0) {
        this.load = false;
        notify(this.dataset_itinerario[0].Msg);
        this.mostra_iti = false;
      } else if (this.dataset_itinerario[0].Cod != 0) {
        this.mostra_iti = true;
      } else {
        this.load = false;
        this.mostra_iti = true;
        this.itinerario = {
          cd_controle: this.dataset_itinerario[0].cd_controle,
          mostra_lokup: this.dataset_itinerario[0].mostra_lokup,
        };
      }
      await this.carregaDados();
      this.load = false;
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}
</style>
