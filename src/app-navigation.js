/* eslint-disable no-console */
//import Modulo from './http/modulo';

//var menu = [];
var cd_modulo = 0;

if ( localStorage.cd_modulo!=0 ) {
    cd_modulo = localStorage.cd_modulo;
}

//cd_modulo = 219;

//async function buscaModulo() {
//   return await Modulo.getModulo(cd_modulo).then( res => res);   
//} 

export default { cd_modulo };

//menu = [{ text: "xpedro", icon: "home", items : [ { text: "Cotação", path: "" } ,  { text: "Pedido x Fornecedor", path: "" } ] } , { text: "Fornecedor", icon: "home"} , { text: "Agenda", icon: "home"} , { text: "Cotação", icon: "home", items : [ { text: "Cotação", path: "" } ,  { text: "Lançamento Preços", path: "" } ] } , { text: "Programação", icon: "home", items : [ { text: "Programação de Entrega", path: "" } ] } , { text: "Pedidos", icon: "home", items : [ { text: "Pedido x Fornecedor", path: "" } ,  { text: "Pedidos em Atraso", path: "" } ] } , { text: "Nota Fiscal", icon: "home"} , { text: "Pagamentos", icon: "home"} , { text: "Produto", icon: "home", items : [ { text: "Produto x Fornecedor", path: "" } ] } , { text: "Qualidade", icon: "home"} , { text: "Avisos", icon: "home"} , { text: "Ajuda", icon: "home"} , { text: "Sobre", icon: "home"} ];

//export default {
//  menu: buscaModulo().then( res => {
//      return res;
//    })
//}


/*
,
  async created(){

     //console.log(items);

     await modulo.getModulo(219).then( res => {
          var s = JSON.stringify(res.data[0].data);
          //console.log(s);
          
          var o =  [JSON.parse(s)];
          
          //console.log(typeof(o));
          //console.log(o);

          this.items = o;

          //this.items = res.data[0].data;
          console.log(this.items);

       });
  },


export default {
  async getMenu() {
    await Modulo.getModulo(cd_modulo).then( res =>{
      menu = [res.data[0].data];
      return menu
    })
  }
}
*/






  
 
