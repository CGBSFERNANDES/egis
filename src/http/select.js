import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async montarSelect(cd_empresa, jsonSelect) {
    try {
      //let sParametro          = '';

      //Parâmetro Base
      //sParametro          = `${nm_identificacao_api}/${cd_empresa}`;
      var sHeader = { headers: { "Content-Type": "text/plain" } };
      // {
      //   "cd_empresa": 140,
      //   "cd_tabela": 93,
      //   "qt_limite": 20,
      //   "order": "D",
      //   "join": "Tipo_Pessoa, Tabela_Preco",
      //   "where": [{"cd_tipo_pessoa": 1}]
      // }
      return await http.post(`835/1312/${cd_empresa}`, jsonSelect, sHeader).then((resposta) => resposta.data);
    } catch (err) {
      console.error("erro " + err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
           return await httpEgisApp.post(`835/1312/${cd_empresa}`, jsonSelect, sHeader).then((resposta) => resposta.data);
          } catch (error) {
             console.error("erro " + error);
             return await httpEgismob.post(`835/1312/${cd_empresa}`, jsonSelect, sHeader).then((resposta) => resposta.data);
            }
          }
    }
  },
};
