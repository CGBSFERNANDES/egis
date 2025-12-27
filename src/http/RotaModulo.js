import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async apiRota(cd_modulo) {
    try {
      var cd_empresa = localStorage.cd_empresa;
      var icd_modulo = cd_modulo;

      if (icd_modulo === 0) {
        icd_modulo = localStorage.cd_modulo;
      }
      return await http.get(`RotasModulo/Modulo/${icd_modulo}/${cd_empresa}`).then((resposta) => resposta.data[0]);
    } catch (err) {
      console.error("erro " + err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
          return await httpEgisApp.get(`RotasModulo/Modulo/${icd_modulo}/${cd_empresa}`).then((resposta) => resposta.data[0]);
        } catch (error) {
          console.error("erro " + error);
          return await httpEgismob.get(`RotasModulo/Modulo/${icd_modulo}/${cd_empresa}`).then((resposta) => resposta.data[0]);
        }
      }
    }
    //return dados
  },
};
