import axios from "axios";
//const urlDownload = "http://localhost:3065/files/download/";
//const urlUpload = "http://localhost:3065/files/upload";
//const urlDeleteServer = "http://localhost:3065/files/deleteserverftp";
//const urlQuery = "http://localhost:3065/files/get/";

//--------------------------------------
const urlDownload = "http://egislog.com.br/api/files/download/";
const urlUpload = "http://egislog.com.br/api/files/upload";
const urlDeleteServer = "http://egislog.com.br/api/files/deleteserverftp";
const urlQuery = "http://egislog.com.br/api/files/get/";

export default {
  TestePromisse() {
    const myPromisse = new Promise((resolve, reject) => {
      const nome = "TESTE";
      if (nome == "TESTE") {
        resolve("IFFF");
      } else {
        reject("FALSSSOOO");
      }
    });
    return myPromisse;
  },
  async Query(cd_empresa) {
    let retorno = [];
    if (!!cd_empresa == false) return;
    let list = await axios.get(urlQuery + cd_empresa);
    list = list.data;
    for (let a = 0; a < list.length; a++) {
      if (list[a].type != "d") {
        retorno.push(list[a]);
      }
    }
    return retorno;
  },
  async Download(cd_empresa, nameFile) {
    if (!!cd_empresa == false || !!nameFile == false) {
      return;
    }
    let buffer = await axios.request({
      url: urlDownload,
      params: {
        localFile: "EGISNET/" + cd_empresa,
        name: nameFile,
      },
      method: "GET",
      responseType: "blob", //important
    });
    return buffer.data;
  },
  async Upload(files, cd_empresa) {
    if (!!files == false) return;

    if (!!cd_empresa == false) {
      cd_empresa = localStorage.cd_empresa;
    }
    if (!!cd_empresa == false) return;

    //Concatenação de nome + data + hora + segundo para não duplicar o arquivo no FTP
    var PegaData = new Date();
    var dia = String(PegaData.getDate()).padStart(2, "0");
    var mes = String(PegaData.getMonth() + 1).padStart(2, "0");
    var ano = PegaData.getFullYear();
    var hora = PegaData.getHours();
    var min = PegaData.getMinutes();
    var seg = PegaData.getSeconds();

    var type = files.name.substring(files.name.indexOf("."), files.name.length);
    var name =
      files.name.slice(0, files.name.indexOf(".")) +
      "(" +
      dia +
      "-" +
      mes +
      "-" +
      ano +
      "." +
      hora +
      "-" +
      min +
      "-" +
      seg +
      ")" +
      type;
    //O arquivo File não pode ter uma propriedade alterada então criei outra variavel para envio
    const file = new File([files], name, {
      type: files.type,
    });
    const form = new FormData(); //identico ao <form> usado no HTML porém criado com JS
    form.append("cd_empresa", cd_empresa);
    form.append("files", file);
    form.append("nm_arquivo", name);
    form.append("qt_file", files.length);
    //return { file };
    let envio = await axios.post(urlUpload, form, {});
    envio = envio.data;
    return { envio };
  },
  async DeleteServer(caminho, File) {
    if (!!File == false) {
      return "Confira os parâmetros!";
    }
    var retorno = await axios.request({
      url: urlDeleteServer,
      method: "GET",
      params: {
        file: File,
        uri: caminho,
      },
    });
    retorno = {
      message: retorno.data.message,
      status: retorno.status,
    };
    return retorno;
  },
  async DeleteServerFTP(caminho, filename) {
    if (!!caminho == false || filename == false) {
      return "Confira os parâmetros!";
    }

    var retorno = await axios.request({
      url: urlDeleteServer,
      method: "GET",
      params: {
        uri: caminho.toUpperCase(),
        file: filename,
      },
    });
    retorno = {
      message: retorno.data.message,
      status: retorno.status,
    };
    return retorno;
  },
};
