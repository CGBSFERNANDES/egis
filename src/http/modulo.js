import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

var cd_empresa = 0;
var cd_modulo = 0;
var cd_usuario = 0;

export default {
  async getModulo(cd_modulo_padrao) {
    try {
      cd_empresa = localStorage.cd_empresa;
      cd_modulo = localStorage.cd_modulo;
      cd_usuario = localStorage.cd_usuario;

      if (cd_modulo == cd_modulo_padrao || cd_modulo == 0) {
        cd_modulo = cd_modulo_padrao;
        localStorage.cd_modulo = cd_modulo_padrao;
      }

      return await http.get(`Modulo/Sidenav/${cd_modulo}/${cd_empresa}/${cd_usuario}`).then((response) => response.data);
    } catch (err) {
      console.error("erro " + err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
           return await httpEgisApp.get(`Modulo/Sidenav/${cd_modulo}/${cd_empresa}/${cd_usuario}`).then((response) => response.data);
          } catch (error) {
             console.error("erro " + error);
             return await httpEgismob.get(`Modulo/Sidenav/${cd_modulo}/${cd_empresa}/${cd_usuario}`).then((response) => response.data);
            }
          }
    }
  },
};
