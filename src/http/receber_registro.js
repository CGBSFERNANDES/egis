import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async receberRegistro(sApi, sjsonObjeto) {
    try {
      var sParametro = "";
      var cd_empresa = localStorage.cd_empresa;
      var nm_identificacao_api = sApi;
      var sHeader = {
        headers: {
          "Content-Type": "text/plain",
          Authorization: `Basic ${sjsonObjeto.token}`,
        },
      };

      // let cd_modulo            = localStorage.cd_modulo;
      //let cd_menu              = localStorage.cd_menu;

      //Parâmetro Base
      sParametro = `${nm_identificacao_api}/${cd_empresa}`;

      return await http.post(sParametro, sjsonObjeto, sHeader).then((resposta) => resposta.data);
    } catch (err) {
      console.error("erro " + err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
           return await httpEgisApp.post(sParametro, sjsonObjeto, sHeader).then((resposta) => resposta.data);
          } catch (error) {
             console.error("erro " + error);
             return await httpEgismob.post(sParametro, sjsonObjeto).then((resposta) => resposta.data);
            }
          }
    }
  },
};
