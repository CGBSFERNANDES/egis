import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async validar(usuario, senha) {
    //senha = 'º®¨¿¡'
    try {
      return await http.get(`PortalCliente/Login/${usuario}/${senha}`).then((resposta) => resposta.data[0]);
      // return dados;
    } catch (err) {
      console.error("erro " + err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
           return await httpEgisApp.get(`PortalCliente/Login/${usuario}/${senha}`).then((resposta) => resposta.data[0]);
          } catch (error) {
             console.error("erro " + error);
             return await httpEgismob.get(`PortalCliente/Login/${usuario}/${senha}`).then((resposta) => resposta.data[0]);
            }
          }
    }
  },
};

/*
var dados = [];

export default {
  validar: (usuario, senha) => {
    //senha = 'º®¨¿¡'
    http.get(`PortalCliente/Login/${usuario}/${senha}`).then(resposta => {
        dados = resposta.data[0];
       // return dados;
    }).catch(err => {
      alert('erro' + err)
    })

    return dados
    
  }
}
*/
