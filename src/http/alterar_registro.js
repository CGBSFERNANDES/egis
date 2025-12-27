import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async alterarRegistro (sApi, sjsonObjeto) {
  try { 

      //alert(sjsonObjeto[0].dt_orcamento);

      var sParametro           = "";
      var cd_empresa           = localStorage.cd_empresa;
      var nm_identificacao_api = sApi;

      var sHeader              = { headers: {
      //                             "Content-Type" : "text/plain",
                                 //  "Access-Control-Allow-Origin": "*.*",
                                 //  "Access-Control-Allow-Methods": "GET, POST, PATCH, PUT, DELETE, OPTIONS",
                                  // "Access-Control-Allow-Headers": "Origin, Content-Type",
                                  // "Access-Control-Allow-Credentials": "true",
                                  // "Accept": "*/*"
                                  // "Connection": "keep-alive",
                                  // "User-Agent": "PostmanRuntime/7.26.5",
                                  // "Accept-Encoding": "gzip, deflate, br"
                                   }
                                  };
      //Parâmetro Base
      sParametro          = `${nm_identificacao_api}/${cd_empresa}`;

      //alert(sParametro);

      //alert(sjsonObjeto);

      
      //var config = {
      //method: "put",
      //url: "www.egisnet.com.br/api/"+sParametro,
      //headers: { 
      //  "Content-Type": "text/plain"
      //},
     // data : sjsonObjeto
     //};
     // alert(config.url);
     // alert(config.headers);

     //http.defaults.headers.common["Access-Control-Allow-Origin"] = "*";

    //alert(sParametro);
    //alert( sjsonObjeto.dt_orcamento );  
    //alert(sHeader.hearders.[Content-Type]);
    
    //sjsonObjeto = "{ "cd_orcamento": "20", "dt_orcamento":"12/06/2021" }";
   // sjsonObjeto = JSON.stringify(sjsonObjeto);

    //alert(sjsonObjeto);
    //alert(JSON.stringify(sjsonObjeto))

     return await http.put(sParametro, sjsonObjeto, sHeader).then(resposta => resposta.data);
     
    }
    
    catch(err) {
      console.error("erro "+err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
           return await httpEgisApp.put(sParametro, sjsonObjeto, sHeader).then(resposta => resposta.data);
          } catch (error) {
             console.error("erro "+error);
             return await httpEgismob.put(sParametro, sjsonObjeto, sHeader).then(resposta => resposta.data);
            }
          }
    }
    
  }
};
