import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async validar (empresa, usuario, menu) {
    //senha = 'º®¨¿¡'  
      try {
        return await http.get(`214/327/${empresa}/${usuario}/${menu}`).then(resposta => resposta.data[0]);
      } catch (error) {
        console.error("erro " + error);
        if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
          try {
            return await httpEgisApp.get(`214/327/${empresa}/${usuario}/${menu}`).then(resposta => resposta.data[0]);
            
          } catch (err) {
            console.error("erro " + err);
            return await httpEgismob.get(`214/327/${empresa}/${usuario}/${menu}`).then(resposta => resposta.data[0]);
            
          }
        }
      }
      
  }
  };