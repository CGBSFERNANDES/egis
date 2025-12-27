export default{

async pegaImg(img){
    try{
      var imagem = "";
      imagem = "data:image/jpeg;base64," + img.replace('[{"i":"','').replace('"}]','');
      return imagem;
    } 
    catch{
      console.log("deu errado, mas passou por aqui");
    }
 }
};