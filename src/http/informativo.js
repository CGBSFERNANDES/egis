import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async montarProcedimento (cd_empresa, cd_cliente, nm_identificacao_api) {
  try {
      var cd_modulo  = localStorage.cd_modulo; 
      var cd_usuario = localStorage.cd_usuario;
      
      return await http.get(`${nm_identificacao_api}/${cd_empresa}/${cd_modulo}/${cd_usuario}`).then(resposta => resposta.data);
    }
    catch(err) {
      console.error("erro "+err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
           return await httpEgisApp.get(`${nm_identificacao_api}/${cd_empresa}/${cd_modulo}/${cd_usuario}`).then(resposta => resposta.data);    
          } catch (error) {
             console.error("erro "+error);
             return await httpEgismob.get(`${nm_identificacao_api}/${cd_empresa}/${cd_modulo}/${cd_usuario}`).then(resposta => resposta.data); 
            }
          }
    }
    
  }
};
