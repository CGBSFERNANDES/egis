<template>
  <div>
    <div
      v-if="flag_romaneio == true && painelCliente == false"
      class="shadow-2 padding1 margin1 borda-bloco"
    >
      <div class="row text-subtitle1  text-bold">
        <div class="col-4">
          <q-icon
            name="bookmark"
            color="orange-10"
            style="font-size: 1.6em; "
          />
          <b class="items-end"> Romaneio: {{ cd_romaneio }} </b>
        </div>
        <div
          class="col text-subtitle1 text-bold items-end"
          v-show="endereco != ''"
        >
          <q-icon name="room" color="orange-10" style="font-size: 1.6em;" />
          <b class="items-end"> {{ endereco }} {{ cidade }} {{ estado }}</b>
        </div>
      </div>

      <div class="row ">
        <div class="col-4 text-subtitle1 text-bold " v-show="cliente != ''">
          <q-icon name="person" color="orange-10" style="font-size: 1.6em; " />
          <b class="items-end">Cliente: {{ cliente }} </b>
        </div>

        <div class="col text-subtitle1 text-bold items-end">
          <q-icon
            name="social_distance"
            color="orange-10"
            style="font-size: 1.6em; "
          /><b class="items-end"
            >Distância: {{ qt_distancia }} Km em {{ qt_tempo }} minutos.</b
          >
        </div>
      </div>
    </div>

    <div id="map-canvas" v-if="fecha_mapa == true">
      <gmap-map
        :center="center"
        :zoom="zoomMap"
        @dblclick="zoomMap + 2"
        style="width:100%;  height: 600px; margin-left: 10px; margin-right: 10px "
        id="Gmap"
        ref="mapRef"
        :options="{
          disableDefaultUi: false,
        }"
        name="mapaGoogle"
      >
        <gmap-marker
          :key="index"
          v-show="props_flag == true && flag_preto == false"
          v-for="(m, index) in dados_pins"
          :position="{
            lat: dados_pins[index].qt_latitude,
            lng: dados_pins[index].qt_longitude,
          }"
          :clickable="true"
          :name="'marker' + m.qt_ordem_selecao"
          :icon="
            'http://www.egisnet.com.br/img/pin/pin_' +
              dados_pins[index].icon +
              dados_pins[index].qt_ordem_selecao +
              '.png'
          "
          @click="openInfoWindowTemplate(m)"
        />
        <gmap-info-window
          :options="{
            maxWidth: 600,
            pixelOffset: { width: 0, height: -35 },
          }"
          :position="infoWindow.position"
          :opened="infoWindow.open"
          @closeclick="infoWindow.open = false"
          style="margin:2px; padding:0"
        >
          <div v-html="infoWindow.template"></div>
          <q-btn
            v-if="1 == 2"
            size="sm"
            round
            color="orange-10"
            @click="ClickCliente(infoWindow)"
            style="margin:5px; padding:0"
            icon="person"
          >
            <q-tooltip transition-show="scale" transition-hide="scale">
              Editar Cliente
            </q-tooltip>
          </q-btn>
          <q-btn
            v-if="!painelCliente"
            size="sm"
            round
            color="orange-10"
            @click="ClickRomaneio()"
            style="margin:5px; padding:0"
            icon="sync"
          >
            <q-tooltip transition-show="scale" transition-hide="scale">
              Alterar Romaneio
            </q-tooltip>
          </q-btn>
        </gmap-info-window>
      </gmap-map>
    </div>

    <q-dialog v-model="load" maximized persistent>
      <carregando :mensagemID="mensagem"></carregando>
    </q-dialog>
    <!---------------------------------------------------->
    <q-dialog
      v-model="popupRomaneio"
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
          <romaneio :cd_romaneioID="romaneio_temp" :alteraEndereco="false" />
        </q-card-section>
      </q-card>
    </q-dialog>
    <!----Cliente------------------------------------------------>
    <q-dialog
      v-model="popupCliente"
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
          <cliente
            :cd_cliente_c="parseInt(infoWindow.cliente.cd_cliente)"
            :cd_consulta="true"
          />
        </q-card-section>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import DirectionsRenderer from "../DirectionsRenderer";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import notify from "devextreme/ui/notify";
import Incluir from "../http/incluir_registro";
import carregando from "../components/carregando.vue";
import romaneio from "../views/romaneio.vue";
var dados = [];
var intervalo;

function addInfoWindow(marker, message) {
  var info = new google.maps.InfoWindow({
    content: message,
  });

  google.maps.event.addListener(marker, "click", function() {
    info.open(document.getElementById("Gmap"), marker);
  });
}

export default {
  name: "GoogleMap",
  props: {
    cd_tipo_mapaID: { type: Number, default: 0 },
    cd_parametroID: { type: Number, default: 0 },
    cd_documentoID: { type: Number, default: 0 },
    RomaneioU: { type: Boolean, default: false },
    painelCliente: { type: Boolean, default: false },
    obj_clienteProps: { type: Object, default: {} },
    array_clienteProps: { type: Array, default: [] },
    object_Get: { type: Object, default: null },
  },
  components: {
    DirectionsRenderer,
    carregando,
    romaneio,
    cliente: () => import("../views/cliente.vue"),
  },

  data() {
    return {
      dataSourceConfig: [],
      qt_distancia: 0,
      qt_tempo: 0,
      cd_parametro: 0,
      maximizedToggle: true,
      cd_documento: 0,
      cd_empresa: 0,
      cd_cliente: 0,
      load: false,
      mensagem: "Buscando informações...",
      icongbs: "",
      api: 0,
      center: { lat: -23.553187671630067, lng: -46.63760845893985 },
      currentPlace: null,
      markers: [],
      startLocation: null,
      endLocation: null,
      tituloMenu: "Mapa de Entregas",
      itipoMapa: 0,
      popupRomaneio: false,
      popupCliente: false,
      cd_romaneio: 0,
      cliente: "",
      endereco: "",
      cidade: "",
      dados_pins: [],
      mostra_entregador: false,
      fecha_mapa: true,
      zoomMap: 10,
      props_flag: false,
      pin_entregador: [],
      romaneio_temp: 0,
      estado: "",
      intervalo,
      infoWindow: {
        position: { lat: 0, lng: 0 },
        open: false,
        template: "",
        cliente: {},
      },
      flag_romaneio: false,
      encontrado: {},
      flag_preto: false,
    };
  },
  async beforeDestroy() {
    clearInterval(intervalo);
  },

  async created() {
    if (localStorage.cd_empresa == 106) {
      this.icongbs = "http://www.egisnet.com.br/img/pin/pin_maximus.png";
    } else if (localStorage.cd_empresa == 200) {
      this.icongbs = "http://www.egisnet.com.br/img/pin/pin_leonardo.png";
    } else if (localStorage.cd_empresa == 164) {
      this.icongbs = "http://www.egisnet.com.br/img/pin/pin_aba.png";
    } else if (localStorage.cd_empresa == 96) {
      this.icongbs = "http://www.egisnet.com.br/img/pin/pin_byr.png";
    } else if (localStorage.cd_empresa == 194) {
      this.icongbs = "http://www.egisnet.com.br/img/pin/pin_sede.png";
    } else if (localStorage.cd_empresa == 201) {
      this.icongbs = "http://www.egisnet.com.br/img/pin/pin_gbs.png";
    } else if (localStorage.cd_empresa == 197) {
      this.icongbs = "http://www.egisnet.com.br/img/pin/pin_aptkspirits.png";
    } else if (localStorage.cd_empresa == 36) {
      this.icongbs = "http://www.egisnet.com.br/img/pin/pin_bherlim.png";
    } else {
      this.icongbs = "http://www.egisnet.com.br/img/pin/pin_gbs.png";
    }

    this.itipoMapa = this.cd_tipo_mapaID;
    this.cd_parametro = this.cd_parametroID;
    this.cd_documento = this.cd_documentoID;
    this.flag_romaneio = this.RomaneioU;
    this.verificaLocal();

    if (this.itipoMapa == 0) {
      this.tituloMenu = "Endereço";
    }
  },

  async mounted() {
    this.$refs.mapRef.$mapPromise.then((map) => (this.map = map));
    this.CriaPropsMarker();
    this.verificaLocal();
  },
  beforeUpdate() {
    this.verificaLocal();
  },

  watch: {
    popupRomaneio() {
      if (this.popupRomaneio == false) {
        this.fecha_mapa = true;
      }
    },
    array_clienteProps(a) {
      this.dados_pins = a;
    },
  },
  methods: {
    ClickCliente() {
      this.popupCliente = true;
    },
    ClickRomaneio() {
      this.fecha_mapa = false;
      this.popupRomaneio = true;
    },

    openInfoWindowTemplate(romaneio) {
      const latitude = romaneio.qt_latitude;
      const longitude = romaneio.qt_longitude;
      this.romaneio_temp = romaneio.cd_romaneio;
      romaneio.nm_razao_social_cliente == undefined
        ? (romaneio.nm_razao_social_cliente = "")
        : "";
      const temp =
        '<div  style="margin:2px; padding:0" class="text-subtitle2" >Cliente: ' +
        romaneio.nm_razao_social_cliente +
        "<br> Romaneio: " +
        romaneio.cd_romaneio +
        "<br>" +
        "Endereço: " +
        romaneio.nm_endereco +
        ", " +
        romaneio.nm_bairro +
        " - " +
        romaneio.nm_cidade +
        "/" +
        romaneio.sg_estado +
        "</div>";
      const tempCliente = `<div  style="margin:2px; padding:0" class="text-subtitle2" >
        Cliente: ${romaneio.nm_fantasia_cliente || ""} 
        <br> 
        Razão Social: ${romaneio.nm_razao_social_cliente || ""} 
        <br> 
        Endereço: ${romaneio.nm_endereco_cliente || ""} 
        <br>
        CNPJ: ${romaneio.cd_cnpj_cliente || ""} 
        <br>
        Vendedor: ${romaneio.nm_vendedor || ""} 
        <br>
        Região: ${romaneio.nm_regiao || ""} 
        <br>
        Segmento: ${romaneio.nm_ramo_atividade || ""} 
        <br>
        Telefone: ${romaneio.cd_telefone || ""} 
        <br>
        Faturamento(Ano): ${romaneio.vl_total_ano || ""} 
        <br>
        Média: ${romaneio.vl_media || ""} 
        <br>
        </div>`;
      this.infoWindow.position = { lat: latitude, lng: longitude };
      this.infoWindow.template = this.painelCliente ? tempCliente : temp;
      this.infoWindow.open = true;
      this.infoWindow.cliente = romaneio;
    },
    async ProcuraEntrega(array) {
      this.encontrado = array.find((element) => element.flag_entregue == "N");
      if (this.encontrado != undefined) {
        var start = new google.maps.LatLng(
          this.pin_entregador.qt_latitude,
          this.pin_entregador.qt_longitude,
        );
        var end = new google.maps.LatLng(
          this.encontrado.qt_latitude,
          this.encontrado.qt_longitude,
        );
        var icon_e = this.pin_entregador;
        var icon_p =
          "http://www.egisnet.com.br/img/pin/pin_" +
          this.encontrado.icon +
          this.encontrado.qt_ordem_selecao +
          ".png";
        var dados_p = this.dados_pins;
        var request = {
          origin: start,
          destination: end,
          travelMode: google.maps.DirectionsTravelMode.DRIVING,
        };
        var directionsService = new google.maps.DirectionsService();
        var directionsDisplay = new google.maps.DirectionsRenderer({
          suppressMarkers: true,
          drivingOptions: {
            departureTime: new Date(Date.now() + 36000), // for the time N milliseconds from now.
            trafficModel: "optimistic",
          },
          polylineOptions: { strokeColor: "black" },
        });

        var myOptions = {
          zoom: 3,
          mapTypeId: google.maps.MapTypeId.ROADMAP,
        };
        directionsService.route(request, function(response, status) {
          if (status != "OK") {
            for (let m = 0; m < dados_p.length; m++) {
              let posicao = new google.maps.LatLng(
                dados_p[m].qt_latitude,
                dados_p[m].qt_longitude,
              );
              let icon_marker =
                "http://www.egisnet.com.br/img/pin/pin_" +
                dados_p[m].icon +
                dados_p[m].qt_ordem_selecao +
                ".png";
              var marker_e = new google.maps.Marker({
                position: posicao,
                map: map,
                animation: google.maps.Animation.DROP,
                icon: icon_marker,
              });
            }
            return;
          }
          if (status == google.maps.DirectionsStatus.OK) {
            directionsDisplay.setDirections(response);
            var route = response.routes[0];
            var map = new google.maps.Map(
              document.getElementById("Gmap"),
              myOptions,
            );
            directionsDisplay.setMap(map);

            var marker = new google.maps.Marker({
              position: start,
              map: map,
              animation: google.maps.Animation.DROP,
              icon: icon_e.link_moto,
            });
            let entregadorF =
              '<div class="text-subtitle2" style="max-width=600px">' +
              icon_e.nm_entregador +
              "<br>" +
              icon_e.nm_veiculo +
              "</div>";
            addInfoWindow(marker, entregadorF);
            //var marker_e = new google.maps.Marker({
            //  position: end,
            //  map: map,
            //  animation: google.maps.Animation.DROP,
            //  icon: icon_p
            //});

            for (let m = 0; m < dados_p.length; m++) {
              let posicao = new google.maps.LatLng(
                dados_p[m].qt_latitude,
                dados_p[m].qt_longitude,
              );
              let icon_marker =
                "http://www.egisnet.com.br/img/pin/pin_" +
                dados_p[m].icon +
                dados_p[m].qt_ordem_selecao +
                ".png";
              var marker_e = new google.maps.Marker({
                position: posicao,
                map: map,
                animation: google.maps.Animation.DROP,
                icon: icon_marker,
              });
              dados_p[m].nm_razao_social_cliente == undefined
                ? (dados_p[m].nm_razao_social_cliente = "")
                : "";
              const information =
                '<div class="text-subtitle2" style="max-width=600px" name="info+' +
                dados_p[m].qt_ordem_selecao +
                '" >Cliente: ' +
                dados_p[m].nm_razao_social_cliente +
                "<br> Romaneio: " +
                dados_p[m].cd_romaneio +
                "<br>" +
                "Endereço: " +
                dados_p[m].nm_endereco +
                ", " +
                dados_p[m].nm_bairro +
                " - " +
                dados_p[m].nm_cidade +
                "/" +
                dados_p[m].sg_estado +
                "</div>";
              addInfoWindow(marker_e, information);
            }
          }
        });
      }
    },

    verificaLocal() {
      if (this.center.lat == 0 || this.center.lng == 0) {
        this.$getLocation({}).then((coordinates) => {
          this.center = coordinates;
        });
      }
    },
    async carregaEntregador() {
      let entregador = {
        cd_parametro: 10,
        cd_entregador: this.object_Get.cd_entregador,
      };

      this.mostra_entregador = false;
      var get = await Incluir.incluirRegistro("639/904", entregador);
      if (get[0].Cod == 0) {
        this.mostra_entregador = false;
        return;
      } else {
        this.pin_entregador = get[0];
        this.mostra_entregador = true;
        this.ProcuraEntrega(this.dados_pins);
      }
    },

    async CriaPropsMarker() {
      if (this.flag_romaneio == false) {
        this.load = true;
        this.object_Get.cd_parametro = 9;
        try {
          this.dados_pins = await Incluir.incluirRegistro(
            "639/904",
            this.object_Get,
          );
          //
          this.center = {
            lat: this.dados_pins[0].qt_latitude
              ? this.dados_pins[0].qt_latitude
              : this.dados_pins[0].qt_latitude_empresa,
            lng: this.dados_pins[0].qt_longitude
              ? this.dados_pins[0].qt_longitude
              : this.dados_pins[0].qt_longitude_empresa,
          };
          if (this.dados_pins[0].Cod == 0) {
            this.load = false;
            notify(this.dados_pins[0].Msg);
            return;
          }
        } catch (error) {
          this.load = false;
        }

        if (this.object_Get.cd_entregador !== undefined) {
          await this.carregaEntregador();
          //intervalo = setInterval(() => {
          //  this.carregaEntregador();
          //}, 15000);s
        }
        this.props_flag = true;
        this.load = false;
      } else {
        this.addListaEndereco();
      }
      this.load = false;
    },
    sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },
    setPlace(place) {
      this.currentPlace = place;
    },

    async addListaEndereco() {
      this.load = true;
      let api = "";

      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;

      //
      localStorage.cd_parametro = this.cd_parametro;
      localStorage.cd_identificacao = this.cd_documento;
      //

      dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 619); //pr_rota_endereco_cliente
      api = dados.nm_identificacao_api;

      let sParametroApi = dados.nm_api_parametro;

      if (this.RomaneioU == true) {
        localStorage.cd_parametro = 2;
        localStorage.cd_identificacao = this.cd_documentoID;
      }
      if (this.painelCliente) {
        localStorage.cd_parametro = 9;
      }
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        sParametroApi,
      );
      if (this.painelCliente) {
        //Se for true não realiza os outros processos
        let dadosCliente = this.dataSourceConfig.filter(
          (w) => w.qt_latitude_cliente && w.qt_longitude_cliente,
        );
        // if (this.obj_clienteProps.cd_cliente) {
        //   dadosCliente = this.dataSourceConfig.filter(
        //     (w) => w.cd_cliente === this.obj_clienteProps.cd_cliente,
        //   );
        // }
        this.dados_pins = dadosCliente;
        this.center = {
          lat: dadosCliente[0].qt_latitude_empresa,
          lng: dadosCliente[0].qt_longitude_empresa,
        };
        this.$emit("dataClientes", this.dados_pins);
        return;
      }
      if (this.dataSourceConfig.length < 2) {
        notify("Localização não encontrada!");
        return;
      }
      this.load = false;
      localStorage.cd_parametro = 0;
      localStorage.cd_identificacao = 0;

      for (let h = 0; h < this.dataSourceConfig.length; h++) {
        if (
          this.dataSourceConfig[h].qt_latitude_cliente == null ||
          this.dataSourceConfig[h].qt_longitude_cliente == null
        ) {
          notify("Impossível localizar rota!");
          return;
        }
      }
      if (this.dataSourceConfig.length > 0) {
        this.startLocation = new google.maps.LatLng(
          this.dataSourceConfig[0].qt_latitude_cliente,
          this.dataSourceConfig[0].qt_longitude_cliente,
        );
        this.endLocation = new google.maps.LatLng(
          this.dataSourceConfig[1].qt_latitude_cliente,
          this.dataSourceConfig[1].qt_longitude_cliente,
        );
        //this.endLocation = {
        //  lat : this.dataSourceConfig[1].qt_latitude_cliente,
        //  lng : this.dataSourceConfig[1].qt_longitude_cliente
        //}
        var request = {
          origin: this.endLocation,
          destination: this.startLocation,
          travelMode: google.maps.DirectionsTravelMode.DRIVING,
        };

        let directionsDisplay = new google.maps.DirectionsRenderer({
          suppressMarkers: false,
          //markerOptions:{
          //  icon: this.icongbs,
          //}
        });
        directionsDisplay.setOptions({
          polylineOptions: {
            strokeColor: "black",
          },
        });

        let map = new google.maps.Map(document.getElementById("Gmap"));
        //map.setMapTypeId('satellite'); altera o tipo do mapa
        //map.MapOptions({
        //  mapId: "8e0a97af9386fef"
        //})
        directionsDisplay.setMap(map);

        var directionsService = new google.maps.DirectionsService();
        directionsService.route(request, function(response, status) {
          if (status == "OK") {
            directionsDisplay.setDirections(response);
            const directions = directionsDisplay.getDirections();
            directions.routes[0].legs[0].steps;
          } else {
            notify("Não foi possível localizar o entregador!");
          }
        });

        for (var i = 0; this.dataSourceConfig.length; i++) {
          this.cliente = this.dataSourceConfig[i].nm_razao_social_cliente;
          this.cd_romaneio = this.dataSourceConfig[i].cd_romaneio;
          this.endereco = this.dataSourceConfig[i].nm_endereco_cliente;
          this.qt_tempo = this.dataSourceConfig[i].qt_tempo;
          this.qt_distancia = this.dataSourceConfig[i].qt_distancia;
          this.cidade = this.dataSourceConfig[i].nm_cidade;
          this.estado = this.dataSourceConfig[i].sg_estado;

          const marker = new google.maps.LatLng(
            this.dataSourceConfig[i].qt_latitude_cliente,
            this.dataSourceConfig[i].qt_longitude_cliente,
          );
          // const marker = {
          //   lat: this.dataSourceConfig[i].qt_latitude_cliente,
          //   lng: this.dataSourceConfig[i].qt_longitude_cliente
          //};

          this.addgbs(marker, i);
        }
      }

      //Distance Matrix Service
      // this.calcularDistancia(this.startLocation, this.endLocation);
    },

    addgbs(marker) {
      this.markers.push({ position: marker });
      //this.startLocation = this.markers[0];
      //this.endLocation = this.markers[1];

      //Alinha o mapa ao centro
      this.center = marker;
      //

      //if (index === 0) {
      //  this.startLocation = marker;
      //}
      //
      //if (index > 0) {this.endLocation   = marker;
      //}
    },

    geolocate: function() {
      navigator.geolocation.getCurrentPosition((position) => {
        this.center = {
          lat: position.coords.latitude,
          lng: position.coords.longitude,
        };
      });
    },
    getIcons() {
      let n;
      for (let a = 1; a < this.dados_pins.length; a++) {
        n = this.dados_pins.length - 1;
      }
      n = String(n);
      return "http://www.egisnet.com.br/img/pin/pin_verde_" + n + ".png";
    },

    //calcularDistancia(p1, p2) {
      //navigator.
      // var dx = this.p1 - point.x;               // delta x
      //var dy = this.y - point.y;               // delta y
      //var dist = Math.sqrt(dx * dx + dy * dy); // distance
      //return dist;
    //},
  },
};
</script>
<style scoped>
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 7px;
  margin: 10px;
}
</style>
