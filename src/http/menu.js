import store from "../store";
import { http } from "./api";
import { httpEgisApp } from "./apiEgisApp";
import { httpEgismob } from "./apiEgismob";

export default {
  async montarMenu(cd_empresa, cd_menu, cd_api) {
    try {
      if (cd_empresa == undefined) {
        return;
      }
      if (cd_menu == undefined) {
        return;
      }
      if (!!cd_api == undefined) {
        return;
      }
      return await http.get(`Estrutura/Menu/${cd_empresa}/${cd_menu}/${cd_api}`).then((resposta) => resposta.data[0]);
    } catch (err) {
      console.error("erro" + err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
           return await httpEgisApp.get(`Estrutura/Menu/${cd_empresa}/${cd_menu}/${cd_api}`).then((resposta) => resposta.data[0]);
          } catch (error) {
             console.error("erro " + error);
             return await httpEgismob.get(`Estrutura/Menu/${cd_empresa}/${cd_menu}/${cd_api}`).then((resposta) => resposta.data[0]);
          }
      }
    }
  },
};
