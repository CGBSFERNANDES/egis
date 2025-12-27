import axios from "axios";

//var envio = await email.SendEmail(
//  this.model,
//  {
//    pass: "ryrarcjqcrzjfqlg",
//    host: "smtp.gmail.com",
//    port: 587,
//    to: "kelvin_piantino@hotmail.com",
//    user: "egisnettestegbs@gmail.com",
//    priority: "high",
//  },
//  "<h1>TESTE HTML</h1>",
//  "TESTE TITULO",
//  "Teste de texto"
//);

//Testar o serviço -> "http://egislog.com.br/email/"
var urlEmail = "http://egislog.com.br/email/sendEmail";

export default {
  async SendEmail(fileList, config, html, assunto, texto) {
    if (fileList.length > 10) {
      return "Excesso de arquivos enviados!";
    }
    if (
      !!config.host == false ||
      !!config.port == false ||
      !!config.user == false ||
      !!config.pass == false ||
      !!config.priority == false ||
      !!config.to == false
    ) {
      return "Erro no envio do Arquivo, confira os parâmetros!";
    }

    if (!!assunto == false) {
      assunto = "Sem assunto";
    }
    if (!!texto == false) {
      texto = "";
    }

    const form = new FormData();
    if (html) {
      form.append("html", html);
    }
    form.append("host", config.host);
    //O password gerado pelo Gmail é diferente da senha do usuário, é necessario gerar uma senha exclusiva para app na aba de segurança da conta gmail
    form.append("pass", config.pass);
    form.append("user", config.user);
    form.append("port", config.port);
    form.append("assunto", assunto);
    form.append("texto", texto);

    form.append("to", config.to);
    form.append("priority", config.priority);
    //O form adiconará todos os arquivos se existirem
    for (let g = 0; g < fileList.length; g++) {
      form.append("fileList", fileList[g]);
      form.append("fileName", fileList[g].name);
    }
    var qt_file = fileList.length;
    form.append("qt_file", qt_file);
    //form.append("fileList", fileList[0]);
    const envio = await axios.post(urlEmail, form, {});
    var retorno = envio;

    //Código de senha/login errado
    if (envio.data.responseCode == 535) {
      retorno = "Senha ou e-mail inválido";
    }

    return { retorno };
  },
};
