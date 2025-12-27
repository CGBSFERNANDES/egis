import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async getDestinatario(cd_empresa, cd_tipo_destinatario, cd_destinatario) {
    try {
      return await http.get(`Destinatario/${cd_empresa}/${cd_tipo_destinatario}/${cd_destinatario}`).then((response) => response.data);
    } catch (err) {
      console.error("erro" + err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
           return await httpEgisApp.get(`Destinatario/${cd_empresa}/${cd_tipo_destinatario}/${cd_destinatario}`).then((response) => response.data);
          } catch (error) {
             console.error("erro " + error);
             return await httpEgismob.get(`Destinatario/${cd_empresa}/${cd_tipo_destinatario}/${cd_destinatario}`).then((response) => response.data);
             
            }
          }
    }
  },
};
