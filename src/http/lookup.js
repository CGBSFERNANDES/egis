import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

//var dados = []

export default {
  async montarSelect(cd_empresa, cd_tabela) {
    try {
      //Api, que retorna os Dados para Montagem do componente Select Box
      if (!!cd_empresa == false) {
        return;
      }
      if (!!cd_tabela == false) {
        return;
      }
      //pr_selectbox_tabela
      return await http.get(`299/415/${cd_empresa}/${cd_tabela}`).then((resposta) => resposta.data[0]);
    } 
    catch (err) {
      console.error("erro" + err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
           return await httpEgisApp.get(`299/415/${cd_empresa}/${cd_tabela}`).then((resposta) => resposta.data[0]);
          } catch (error) {
             console.error("erro" + error);
             return await httpEgismob.get(`299/415/${cd_empresa}/${cd_tabela}`).then((resposta) => resposta.data[0]);
            }
          }
    }
    //return dados
  },
};
