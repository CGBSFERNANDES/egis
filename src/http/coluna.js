import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async montarColuna (cd_empresa, cd_menu) {
    try {
      return await http.get(`Proposta/Aberto/${cd_empresa}/${cd_menu}`).then(resposta =>
        resposta.data);
      }
      catch(err) {
        console.error("erro"+err);
        if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
          try {
             return await httpEgisApp.get(`Proposta/Aberto/${cd_empresa}/${cd_menu}`).then(resposta =>
                 resposta.data);
              } catch (error) {
                 console.error("erro " + error);
                 return await httpEgismob.get(`Proposta/Aberto/${cd_empresa}/${cd_menu}`).then(resposta =>
                     resposta.data);
                  }
                }
    }

    //alert(dados);
    //return dados
  }
};
