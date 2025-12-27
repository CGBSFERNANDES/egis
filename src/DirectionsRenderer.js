import { MapElementFactory } from "vue2-google-maps";

export default MapElementFactory({
  name: "directionsRenderer",

  ctr() {
    return window.google.maps.DirectionsRenderer;
  },

  events: [],

  mappedProps: {},

  props: {
    origin:      { type: [Object, Array] },
    destination: { type: [Object, Array] },
    travelMode:  { type: String },
    waypts:      { type: Array}
  },
  
  
  afterCreate(directionsRenderer) {
    
    let directionsService = new window.google.maps.DirectionsService(
      {
        suppressMarkers: false,
      }

    );

    this.$watch(
      () => [this.origin, this.destination, this.travelMode],
      () => {
        let { origin, destination, travelMode, waypts } = this;
        if (!origin || !destination || !travelMode, !waypts) return;
        console.log(waypts)
        directionsService.route(
          {
            origin,
            destination,
            travelMode,
            waypoints: waypts,
            drivingOptions: {
              departureTime: new Date(Date.now() + 36000),  // for the time N milliseconds from now.
              trafficModel: 'optimistic'
            }
          },
         
          (response, status) => {
            if (status !== "OK") return;
            // eslint-disable-next-line no-debugger
            //debugger
            directionsRenderer.setOptions({
              markerOptions:{
                visible:false
              }
            })
            directionsRenderer.setDirections(response);
            
           
        

            const directions = directionsRenderer.getDirections();

            //console.log(directions);
            //console.log(directions.routes[0].legs[0].distance);
            //console.log(directions.routes[0].legs[0].steps);

            let instrucoes = directions.routes[0].legs[0].steps;
            localStorage.nm_itinerario = '';

            if (instrucoes.length > 0) {
               var i = 0;
               var n = 0;
               for(i = 0; i < instrucoes.length; i++){
                n = i + 1;
                localStorage.nm_itinerario = localStorage.nm_itinerario +
                n.toString() + ' - '
                +
                instrucoes[i].instructions + '<br> ';
               }
            }

            //  localStorage.nm_itinerario = directions.routes[0].legs[0].steps[0].instructions;
      
           // console.log(localStorage.nm_itinerario);      

            //Calculando o Total em KM//
            if (directions) {
              //this.computeTotalDistance(directions);
              let total = 0;

              const myroute = directions.routes[0];
            
              if (myroute) {                 
                         
                 for (let i = 0; i < myroute.legs.length; i++) {
                   total += myroute.legs[i].distance.value;
                 }
            
                 total = total / 1000;
                //document.getElementById("total").innerHTML = total + " km";
               // console.log(total);
              }            
          }
         } 
        );
      }
    );
  },
});