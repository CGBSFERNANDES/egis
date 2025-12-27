import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async excluirRegistro (sApi, sjsonObjeto) {
  try { 

      //alert(sjsonObjeto[0].dt_orcamento);

      var sParametro           = "";
      var cd_empresa           = localStorage.cd_empresa;
      var nm_identificacao_api = sApi+"/Exclusao";
      var cd_identificacao     = sjsonObjeto;
      var cd_usuario           = localStorage.cd_usuario;

      //alert(sApi);

      //let sHeader              = { headers: {
        //                             "Content-Type" : "text/plain",
                                   //  "Access-Control-Allow-Origin": "*.*",
                                   //  "Access-Control-Allow-Methods": "GET, POST, PATCH, PUT, DELETE, OPTIONS",
                                    // "Access-Control-Allow-Headers": "Origin, Content-Type",
                                    // "Access-Control-Allow-Credentials": "true",
                                    // "Accept": "*/*"
                                    // "Connection": "keep-alive",
                                    // "User-Agent": "PostmanRuntime/7.26.5",
                                    // "Accept-Encoding": "gzip, deflate, br"
        //                             }
        //                            };
      // alert(sHeader.hearders);
     // console.log(sHeader);
   // console.log(sHeader.hearders);


    // let sHeader = { hearders: {"Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"}};   

   //res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
      
      //Parâmetro Base
      sParametro          = `${nm_identificacao_api}/${cd_empresa}/${cd_identificacao}/${cd_usuario}`;


      //alert('cd_identificacao');
  
     // alert(sParametro);

      //alert(sjsonObjeto);

      //alert(sjsonObjeto.cd_orcamento);
      //sjsonObjeto = sjsonObjeto.cd_orcamento;
      
      return await http.get(sParametro).then(resposta => resposta.data);
      
      //return await http.delete(sParametro, sjsonObjeto, sHeader).then(resposta =>
        //resposta.data);
        
      }
      catch(err) {
        console.error("erro "+err);
        if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
          try {
             return await httpEgisApp.get(sParametro).then(resposta => resposta.data);
            } catch (error) {
               console.error("erro "+error);
               return await httpEgismob.get(sParametro).then(resposta => resposta.data);
              }
            }
    }
    
  }
};
