import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async incluirRegistro(sApi, sjsonObjeto, base = "cliente") {
    try {
      var sParametro = '';
      var cd_empresa = localStorage.cd_empresa;
      var nm_identificacao_api = sApi;

      //let sHeader = { headers: { "Content-Type": "text/plain" } };
      // let cd_modulo            = localStorage.cd_modulo;
      //let cd_menu              = localStorage.cd_menu;

      //Parâmetro Base

      base === 'admin'
        ? (sParametro = `${nm_identificacao_api}`)
        : (sParametro = `${nm_identificacao_api}/${cd_empresa}`);
      if (sParametro.includes('undefined')) {
        return null;
      }

      console.log('Endpoint:', sParametro);
      console.log('Payload:', sjsonObjeto);
      console.log('Dados: ', sParametro, sjsonObjeto);

      //
      //let sHeader = { headers: { "Content-Type": "application/json" } };
      //return await http.post(sParametro, sjsonObjeto, sHeader).then((resposta) => resposta.data);

      //
      return await http.post(sParametro, sjsonObjeto).then((resposta) => resposta.data);
      //
    } catch (err) {
      console.error('Erro: ' + err);

      if (store._mutations.SET_Usuario.ic_multi_servidor === 'S') {
        try {
          return await httpEgisApp.post(sParametro, sjsonObjeto).then((resposta) => resposta.data);
        } catch (error) {
          console.error('Erro: ' + error);
          return await httpEgismob.post(sParametro, sjsonObjeto).then((resposta) => resposta.data);
        }
      }
    }
  },
};
