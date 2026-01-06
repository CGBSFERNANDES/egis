import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async validar(sjsonObjeto) {
                               //console.log("objeto para validar login", sjsonObjeto);

                               //senha = 'º®¨¿¡'
                               try {
                                 //Parâmetro Base
                                 var sHeader = {
                                   headers: { "Content-Type": "text/plain" },
                                 };
                                 //let sParametro = `${sjsonObjeto.usuario}/${sjsonObjeto.senha}`
                                 return await http
                                   .post("830/1307", sjsonObjeto, sHeader)
                                   .then(resposta => resposta.data);
                               } catch (err) {
                                 console.error("erro " + err);
                                 if (
                                   store._mutations.SET_Usuario
                                     .ic_multi_servidor === "S"
                                 ) {
                                   try {
                                     return await httpEgisApp
                                       .post("830/1307", sjsonObjeto, sHeader)
                                       .then(resposta => resposta.data);
                                   } catch (error) {
                                     console.error("erro " + err);
                                     return await httpEgismob
                                       .post("830/1307", sjsonObjeto, sHeader)
                                       .then(resposta => resposta.data);
                                   }
                                 }
                               }
                             },
};
