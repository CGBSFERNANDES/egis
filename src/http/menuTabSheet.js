import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";
//var dados = []

export default {
    
  async montarMenuTabSheet (cd_menu)  {
    try {
      return await http.get(`Menu/TabSheet/${cd_menu}`).then(resposta => resposta.data);               
    } 
    catch(err) {
      console.error("erro "+err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
               return await httpEgisApp.get(`Menu/TabSheet/${cd_menu}`).then(resposta => resposta.data);                
             } catch (error) {
                 console.error("erro "+error);
                 return await httpEgismob.get(`Menu/TabSheet/${cd_menu}`).then(resposta => resposta.data);             
               }
          }
      }
      //return dados
    }
};    
