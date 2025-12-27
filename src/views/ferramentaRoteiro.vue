<template>
  <div class="row">
    <!--<div>
        {{tituloMenu}}
      </div>-->
    <!--{{coordinates.lat}}   mapa:   {{mapCoordinates.lat}}
      <br>
      {{coordinates.lng}}   mapa:   {{mapCoordinates.lng}}-->
    <div class="mapa">
      <gmap-map
        v-if="mapa == true"
        class="mapa"
        id="Gmap"
        :center="this.coordinates"
        :zoom="zoomMap"
        @dblclick="zoomMap + 2"
        ref="mapRef"
        :options="{
          disableDefaultUi: false,
        }"
      >
        <gmap-marker
          :position="center"
          :clickable="true"
          :draggable="false"
          :icon="icongbs"
        >
        </gmap-marker>

        <gmap-marker
          :position="coordinates"
          :clickable="true"
          :draggable="false"
          :icon="icongbs"
        >
        </gmap-marker>
        <gmap-marker
          :key="index"
          v-for="(m, index) in markers"
          :position="m.position"
          :clickable="true"
          :draggable="true"
          :icon="getIcons(loc[0].qt_ordem_selecao)"
        >
        </gmap-marker>
        <!--
    <gmap-marker
          v-else
          v-for="n in parseInt(loc.length)"
          v-bind:key="n"
          id="marker"
          :position="{lat:loc[n-1].qt_latitude, lng:loc[n-1].qt_longitude }"
          :clickable="true"
          :draggable="false" 
          :icon="getIcons(loc[n-1].qt_ordem_selecao)"    
       >
    </gmap-marker>
  
      

       <gmap-marker
          :position="{ lat: -23.71, lng: -46.9182}"
          :clickable="true"
          :draggable="false" 
          :icon="icongbs"    
       >

      <GmapMarker
          :position="{ lat: -23.980, lng: -46.9182}"
          :clickable="true"
          :draggable="true"                    
          :icon="icongbs1"
      />

      <GmapMarker
          :position="{ lat: -23.985, lng: -46.9582}"
          :clickable="true"
          :draggable="true"                    
          :icon="icongbs2"
      />
      

       </gmap-marker>
-->
        <!--
       <DirectionsRenderer
        v-if="this.loc.length > 0 && this.directionRenderer == true"
        travelMode="DRIVING"
        :origin="coordinates"
        :waypts="this.waypts"
        :destination="{lat: this.loc[this.loc.length-1].qt_latitude,
                       lng: this.loc[this.loc.length-1].qt_longitude}"
                       ref="Dir"
      />
        
        :destination="{ lat: -23.985, lng: -46.9582}""-->
      </gmap-map>
    </div>

    <!--<div class="Entregas">
      <card
       :titulo_card="titulo_card"
       :json_card="selecaoID"
       ref="card"
      >
      </card>
      <div class="row items-center" style="margin: 5px 5px 5px 10px">
        <div class="col items-center text-bold text-h6">Entregas</div>
      </div>
      <DxScrollView
            v-if="pin.length > 0 "
            id="conjunto-cards"
            class=" col-3 responsive-paddings scroll"
            show-scrollbar="always"
          >
             <div
               v-for="(e, index) in 1"
               :key="index"          
               class="list"
             >
              

             <DxSortable
               :data="pin"
               class="sortable-cards"
               group="tasksGroup"
               @drag-start="onTaskDragStart($event)"
               @reorder="onTaskDrop($event)"
               @add="onTaskDrop($event)"
             >
               <div
                 v-for="task in pin"
                 :key="task.cd_controle"
                 class="dx-card dx-theme-text-color dx-theme-background-color"
               >
                <div class="col  text-bold text-blue-8 text-left" style="margin:3px"> 
                  {{task.nm_razao_social_cliente}} 
                </div>
                <q-separator/>
                <div class="row  text-bold" style="margin:3px"> 
                  {{task.nm_endereco_apresenta}} 
                </div>
                <div class="row  text-bold" style="margin:3px"> 
                  Entrega: {{task.hr_entrega}} 
                </div>
                <div class="row  text-bold" style="margin:3px"> 
                  Valor: R$ {{parseFloat(task.vl_total_romaneio).toFixed(2)}} 
                </div>
                <div class="row  text-bold" style="margin:3px"> 
                  Obs: {{task.nm_obs_romaneio}} 
                </div>
                <div class="row  text-bold" style="margin:3px"> 
                 <q-badge class="esquerda" rounded color="primary" text-color="white" :label="task.cd_romaneio" />
                </div>
 
               </div>
             </DxSortable>
             
             </div>
         
          </DxScrollView>
  </div>

   <div class="row"> 
     
      <q-editor
        v-model="textareaModel"
        class="col"
        :definitions="{
          bold: {label: 'Bold', icon: null, tip: 'Negrito'}
        }"
      />
      <q-input
        v-model="textareaModel"
        filled
        class="col"
        clearable
        type="textarea"
        color="red-12"
        label="Itinerário"
        hint="Como chegar ao seu destino !"
      />    

    </div>-->
  </div>
</template>

<script>
import DirectionsRenderer from "../DirectionsRenderer";
import { DxSortable } from "devextreme-vue/sortable";
import { DxScrollView } from "devextreme-vue/scroll-view";
import notify from "devextreme/ui/notify";

var directionsDisplay = [];
var directionsService = [];
var parada;

export default {
  props: {
    // eslint-disable-next-line vue/require-valid-default-prop
    selecaoID: { type: Array, default: [] },
    // eslint-disable-next-line vue/require-valid-default-prop
    origemID: { type: Object, default: {} },
    directionRenderer: { type: Boolean, default: false },
  },

  data() {
    return {
      iconMarker:
        "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjMiIGhlaWdodD0iMjkiIHZpZXdCb3g9IjAgMCAyMyAyOSIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4NCjxwYXRoIGQ9Ik0yMyAxMS41QzIzIDIxLjUgMTEuNSAyOC41IDExLjUgMjguNUMxMS41IDI4LjUgMCAyMS41IDAgMTEuNUMwIDUuMTQ4NzMgNS4xNDg3MyAwIDExLjUgMEMxNy44NTEzIDAgMjMgNS4xNDg3MyAyMyAxMS41WiIgZmlsbD0iI0M3MDYyOSIvPg0KPGNpcmNsZSBjeD0iMTEuNSIgY3k9IjExLjUiIHI9IjUuNSIgZmlsbD0iIzgxMDAxNyIvPg0KPC9zdmc+DQo=",
      iconMarkerActive:
        "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjMiIGhlaWdodD0iMjkiIHZpZXdCb3g9IjAgMCAyMyAyOSIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4NCjxwYXRoIGQ9Ik0yMyAxMS41QzIzIDIxLjUgMTEuNSAyOC41IDExLjUgMjguNUMxMS41IDI4LjUgMCAyMS41IDAgMTEuNUMwIDUuMTQ4NzMgNS4xNDg3MyAwIDExLjUgMEMxNy44NTEzIDAgMjMgNS4xNDg3MyAyMyAxMS41WiIgZmlsbD0iIzMzMzMzMyIvPg0KPGNpcmNsZSBjeD0iMTEuNSIgY3k9IjExLjUiIHI9IjUuNSIgZmlsbD0iYmxhY2siLz4NCjwvc3ZnPg0K",
      tituloMenu: "Mapa de Roteirização",
      coordinates: { lat: 0, lng: 0 },
      //mapcoordinates: { lat: 0, lng: 0},
      titulo_card: "",
      map: null,
      qt_latitude: 0,
      qt_longitude: 0,
      zoom: 7,
      markers: [],
      mapa: true,
      infowindow: [],
      icon: "http://maps.google.com/mapfiles/ms/icons/blue-dot.png",
      iconHover: "http://maps.google.com/mapfiles/ms/icons/red-dot.png",
      icongbs: "http://www.egisnet.com.br/img/pin/pin_sede.png",
      icongbs1: "http://www.egisnet.com.br/img/pin/pin_1.png",
      icongbs2: "http://www.egisnet.com.br/img/pin/pin_2.png",
      selectedKey: null,
      startLocation: null,
      endLocation: null,
      center: null,
      textareaModel: ".",
      loc: [],
      orig: {},
      waypts: [],
      zoomMap: 12,
      mostraMarker: false,
      distancia: "",
      tempo_entrega: "",
    };
  },
  watch: {
    selecaoID() {
      this.loc = this.selecaoID;
      this.CalculaRota();
    },

    origemID() {
      this.orig = this.origemID;
      this.verificaLocal();
    },
  },

  components: {
    DirectionsRenderer,
    DxSortable,
    DxScrollView,
  },

  created() {
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
    this.loc = this.selecaoID;

    this.orig = this.origemID;
    this.titulo_card = "Ordem de Entregas";
    this.verificaLocal();
    this.textareaModel = "";
    if (this.loc.length > 0) {
      this.CalculaRota();
    }
  },
  mounted() {
    this.$refs.mapRef.$mapPromise.then((map) => (this.map = map));
    this.verificaLocal();
    if (this.loc.length > 0) {
      this.CalculaRota();
    }
  },

  beforeUpdate() {
    this.verificaLocal();
  },

  computed: {
    PegaTitulo() {
      return this.tituloMenu;
    },
    mapCoordinates() {
      if (!this.map) {
        return {
          lat: 0,
          lng: 0,
        };
      }
      return {
        lat: this.map.getCenter().lat(),
        lng: this.map.getCenter().lng(),
      };
    },
  },

  methods: {
    sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },

    CalculaDirecao() {
      this.waypoints = [];
      for (let g = 0; g < this.loc.length; g++) {
        var parada = new google.maps.LatLng(
          this.loc[g].qt_latitude,
          this.loc[g].qt_longitude,
        );
        this.waypts.push({
          location: parada,
          stopover: true,
        });
      }
    },

    async CalculaRota() {
      let parts = [];
      let points = [];
      let final;
      for (let a = 0; a < this.loc.length; a++) {
        if (this.loc[a].qt_latitude == 0 || this.loc[a].qt_longitude == 0) {
          notify(
            "Não foi possível calcular a rota no romaneio " +
              this.loc[a].cd_romaneio +
              ", verifique os dados do Romaneio!",
          );
          return;
        }
        parada = new google.maps.LatLng(
          this.loc[a].qt_latitude,
          this.loc[a].qt_longitude,
        );

        points.push({
          location: parada,
          stopover: true,
        });
      }

      if (this.loc.length == 0) {
        final = new google.maps.LatLng(
          this.coordinates.lat,
          this.coordinates.lng,
        );
      } else {
        final = new google.maps.LatLng(
          this.loc[this.loc.length - 1].qt_latitude,
          this.loc[this.loc.length - 1].qt_longitude,
        );
      }

      for (var i = 0, max = 25 - 1; i < points.length; i = i + max) {
        parts.push(points.slice(i, i + max + 1));
      }

      let o;
      let e;
      var request = [];
      let index = 1;
      var iconeA = this.icongbs;
      if (parts.length == 0) {
        var pedido = {
          origin: final,
          destination: final,
          optimizeWaypoints: false,
          travelMode: google.maps.DirectionsTravelMode.DRIVING,
          unitSystem: google.maps.UnitSystem.METRIC,
        };
        directionsService[0] = new google.maps.DirectionsService();
        directionsService[0].route(pedido, async function(response, status) {
          if (status == "OK") {
            await directionsDisplay[0].setDirections(response);
            var map = new google.maps.Map(document.getElementById("Gmap"));
            directionsDisplay[0].setMap(map);
            new google.maps.Marker({
              position: final,
              map: map,
              icon: iconeA,
            });
          }
        });
        return;
      }

      for (let g = 0; g < parts.length; g++) {
        if (g == 0) {
          o = this.coordinates;
        } else {
          o = parts[g][0].location;
        }

        request[g] = {
          origin: o,
          destination: parts[g][parts[g].length - 1].location,
          waypoints: parts[g],
          optimizeWaypoints: false,
          travelMode: google.maps.DirectionsTravelMode.DRIVING,
          unitSystem: google.maps.UnitSystem.METRIC,
        };

        //
        directionsService[0] = new google.maps.DirectionsService();

        directionsDisplay[g] = new google.maps.DirectionsRenderer({
          suppressMarkers: true,
          drivingOptions: {
            departureTime: new Date(Date.now() + 36000), // for the time N milliseconds from now.
            trafficModel: "optimistic",
          },
          polylineOptions: { strokeColor: "black" },
        });
      }

      //for(let ro=0; ro<request.length;ro++){
      await this.sleep(1000);
      let pinPoint = [];
      directionsService[0].route(request[0], async function(response, status) {
        if (status == "OK") {
          var map = new google.maps.Map(document.getElementById("Gmap"));
          await directionsDisplay[0].setDirections(response);
          directionsDisplay[0].setMap(map);
          pinPoint.push(response);
          for (let m = 0; m < response.routes[0].legs.length; m++) {
            if (m == 0) {
              iconF = iconS;
            } else {
              iconF =
                "http://www.egisnet.com.br/img/pin/pin_" + index++ + ".png";
            }
            var leg = response.routes[0].legs[m];
            new google.maps.Marker({
              position: leg.start_location,
              map: map,
              icon: iconF,
            });
          }
        } else {
          notify("Não foi possível calcular a rota!");
        }
      });
      //}
      await this.sleep(1000);
      this.$emit("pinPoint", pinPoint);
      //console.log(pinPoint, "pinPoint");
      var iconF = this.icongbs;
      var iconS = this.icongbs;
    },

    verificaLocal() {
      this.coordinates.lat = this.origemID.qt_latitude;
      this.coordinates.lng = this.origemID.qt_longitude;

      if (this.coordinates.lat == 0 || this.coordinates.lng == 0) {
        this.$getLocation({}).then((coordinates) => {
          this.coordinates = coordinates;
        });
      }
    },

    getIcons() {
      let n;
      for (let a = 1; a < this.loc.length; a++) {
        n = this.loc.length - 1;
      }
      n = String(n);
      return "http://www.egisnet.com.br/img/pin/pin_" + n + ".png";
    },
  },
};
</script>

<style scoped>
.map {
  position: fixed;
  left: 0;
  top: 0;
}
.mapa {
  width: 100%;
  height: 100%;
}
.Entregas {
  width: 25vw;
  margin: 5px;
}
#conjunto-cards {
  height: 45vw !important;
}
.responsive-paddings {
  margin: 0.4vw;
  padding: 0;
}
.list {
  width: 100%;
}
</style>
