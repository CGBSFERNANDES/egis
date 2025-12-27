import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async apiMenu(nm_rota) {
    try {
      var cd_modulo = localStorage.cd_modulo;

      //pr_modulo_api_composicao (871)

      return await http.get(`Rota/Menu/${nm_rota}/${cd_modulo}`).then((resposta) => resposta.data[0]);
    } catch (err) {
      console.error("erro " + err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
           return await httpEgisApp.get(`Rota/Menu/${nm_rota}/${cd_modulo}`).then((resposta) => resposta.data[0]);
          } catch (error) {
             console.error("erro " + error);
             return await httpEgismob.get(`Rota/Menu/${nm_rota}`).then((resposta) => resposta.data[0]);
            }
          }
    }
    //return dados
  },
};
