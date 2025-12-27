import { Loader, google } from "@googlemaps/js-api-loader";
import Incluir from "../http/incluir_registro";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import notify from "devextreme/ui/notify";
import { jsPDF } from "jspdf";
import axios from "axios";
import formatadata from "../http/formataData.js";

//const urlCNPJ = "http://localhost:3000/servicocnpj/";
const urlCNPJ = "http://52.91.242.64/cnpj/pesquisa/";

export default {
  async buscaCep(cep) {
    localStorage.cd_cep = cep.replace("-", "");

    if (cep.includes("_") == false && !cep.trim() == "") {
        try {
          let cep_encontrado = await Procedimento.montarProcedimento(
            localStorage.cd_empresa,
            localStorage.cd_cliente,
            "413/550",
            "/${cd_empresa}/${cd_cep}",
          );
          return cep_encontrado;
        } catch(err) {
          // eslint-disable-next-line no-console
          console.error(err);
        }
    } 
  },

  //----------------------------------------------------------------------------------------------------------

  DataHoje() {
    var PegaData = new Date();
    var dia = String(PegaData.getDate()).padStart(2, "0");
    var mes = String(PegaData.getMonth() + 1).padStart(2, "0");
    var ano = PegaData.getFullYear();
    return `${dia}/${mes}/${ano}`;
  },

  DataHoraHoje() {
    var PegaData = new Date();
    var dia = String(PegaData.getDate()).padStart(2, "0");
    var mes = String(PegaData.getMonth() + 1).padStart(2, "0");
    var ano = PegaData.getFullYear();
    var hora = String(PegaData.getHours()).padStart(2, "0");
    var minutos = String(PegaData.getMinutes()).padStart(2, "0");
    return `${dia}/${mes}/${ano} - ${hora}:${minutos}`;
  },

  //----------------------------------------------------------------------------------------------------------

  async buscaVendedor(cd_usuario) {
    //Kelvin 30.03.22 - Busca o Vendedor pelo usu?rio.
    if (cd_usuario == undefined) {
      return "Informe o cd_usuario";
    }
    let api = "706/1073"; //1539 -  pr_egisnet_cadastra_ficha_venda
    let v = {
      cd_parametro: 11,
      cd_usuario: cd_usuario,
    };
    var re = await Incluir.incluirRegistro(api, v);
    return re[0];
  },

  //----------------------------------------------------------------------------------------------------------

  sleep(ms) {
    //Kelvin 30.03.22 - coloca o Script pra dormir.
    return new Promise((resolve) => setTimeout(resolve, ms));
  },

  //----------------------------------------------------------------------------------------------------------
  Arredondar(vl_recebido) {
    //Alexandre 18.07.22 - Arredonda o valor enviado
    return Math.round(vl_recebido).toFixed(2);
  },

  //----------------------------------------------------------------------------------------------------------

  async CriaVb(doc) {
    //Kelvin - Retorna VB de um documento no LocalStorage.vb_document.
    if (doc == undefined) return;
    var retorno = [];
    var oMyBlob = {};
    if (doc.type == "application/x-msdownload") {
      retorno = "Tipo de arquivo n?o suportado!";
      return retorno;
    } else if (doc.size >= 19763181568) {
      retorno = "Tamanho de arquivo não permitido!";
      return retorno;
    } else if (doc.size >= 3751668 && doc.type == "application/pdf") {
      retorno = "Tamanho de arquivo não permitido!";
      return retorno;
    }

    oMyBlob = new File([doc], doc, { type: doc.type });
    var reader = new FileReader();

    reader.addEventListener("loadend", async function() {
      retorno = await reader.result;
      localStorage.vb_document = retorno;
    });

    if (oMyBlob.type == "text/xml") {
      reader.readAsText(oMyBlob);
    } else {
      await reader.readAsDataURL(oMyBlob);
    }
  },

  //----------------------------------------------------------------------------------------------------------

  AbreDocumento(vb) {
    //Kelvin - Abre um documento em outra aba do navegador disponibilizando para download (recebe VB)
    if (vb == null) {
      notify("Impossivel abrir o documento");
    }
    window.open(vb, "_blank").focus();
  },

  //----------------------------------------------------------------------------------------------------------
  //----------------------------------------------------------------------------------------------------------

  viraBase64(a) {
    //Recebe uma string e devolve um base64 (Codifica)
    if (a == null) {
      notify("Não foi possível transformar em base64!");
    }
    let vira = btoa(a);
    return vira;
  },

  //----------------------------------------------------------------------------------------------------------
  //----------------------------------------------------------------------------------------------------------

  desviraBase64(b) {
    //Recebe um base64 e devolve uma string (Descodifica)
    if (b == null) {
      notify("Não foi possível transformar em string!");
    }
    let desvira = atob(b);
    return desvira;
  },

  //----------------------------------------------------------------------------------------------------------
  //----------------------------------------------------------------------------------------------------------

  CriaFile(input, typeInput) {
    //Cria um file
    // Primeiro argumento - Array ou BLOB
    // Segundo argumento  - Nome do arquivo (file name)
    // Terceiro argumento - (Opcional) Descrito abaixo
    /* EXEMPLO
           const file = new File(["foo"], "foo.txt", {
             type: "text/plain",
           });

        type: 
          text: text/plain, text/html, text/css, text/javascript
          image: image/gif, image/png, image/jpeg, image/bmp, image/webp
          audio: audio/midi, audio/mpeg, audio/webm, audio/ogg, audio/wav
          video: video/webm, video/ogg
          application: application/octet-stream, application/pkcs12, application/vnd.mspowerpoint, application/xhtml+xml, application/xml,  application/pdf
          */

    if (input == null) {
      notify("Não foi possível criar o File!");
    }
    var MyFile = new File([input], input, { type: typeInput });
    return MyFile;
  },

  //----------------------------------------------------------------------------------------------------------
  async Export2PDF(elementoHTML, configPDF) {
    //Exporta um HTML em PDF

    let dados_relatorio = await Menu.montarMenu(
      localStorage.cd_empresa,
      0,
      666,
    ); // 1520 - pr_api_gera_processo_relatorio
    let RelatorioApi = dados_relatorio.nm_identificacao_api;
    let RelatorioSParametroApi = dados_relatorio.nm_api_parametro;

    localStorage.cd_parametro = configPDF.cd_parametro;
    localStorage.cd_documento = configPDF.cd_documento;
    localStorage.cd_item_documento = configPDF.cd_item_documento;
    localStorage.cd_relatorio = configPDF.cd_relatorio;

    let relatorio = await Procedimento.montarProcedimento(
      localStorage.cd_empresa,
      0,
      RelatorioApi,
      RelatorioSParametroApi,
    );

    let docPDF = new jsPDF("landscape", "px"); //LANDSCAPE = RETRATO / DEFAULT = A4
    let body = elementoHTML;
    docPDF.html(body, {
      callback: function() {
        configPDF.abre_baixa == "A"
          ? docPDF.output("dataurlnewwindow", relatorio[0].nm_relatorio)
          : "";
        configPDF.abre_baixa == "B"
          ? docPDF.save(relatorio[0].nm_relatorio)
          : "";
      },
      x: 10, //Eixo X e Y - Dist?ncia entre conte?do e a margem
      y: 10,
    });
    //docPDF.autoPrint(); //ABRE O CTRL+P
    return "Relatório gerado!";
  },
  //----------------------------------------------------------------------------------------------------------
  Export2Word(elementoHTML, configWord) {
    // Exporta um HTML em Word
    var preHtml =
      "<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'><head><meta charset='utf-8'><title>Export HTML To Doc</title></head><body>";
    var postHtml = "</body></html>";
    var html =
      preHtml + document.getElementById(elementoHTML).innerHTML + postHtml;

    var blob = new Blob(["\ufeff", html], {
      type: "application/msword",
    });

    // Specify link url
    var url =
      "data:application/vnd.ms-word;charset=utf-8," + encodeURIComponent(html);

    // Specify file name
    var filename = configWord[0].nm_arquivo_word
      ? configWord[0].nm_arquivo_word + ".doc"
      : "document.doc";

    // Create download link element
    var downloadLink = document.createElement("a");

    document.body.appendChild(downloadLink);

    if (navigator.msSaveOrOpenBlob) {
      navigator.msSaveOrOpenBlob(blob, filename);
    } else {
      // Create a link to the file
      downloadLink.href = url;

      // Setting the file name
      downloadLink.download = filename;

      //triggering the function
      downloadLink.click();
    }
    document.body.removeChild(downloadLink);
  },
  //----------------------------------------------------------------------------------------------------------
  async ExportHTML(elementoHTML, action, config) {
    if (action == undefined) {
      action = "B";
    }
    let docPDF = new jsPDF(config); //LANDSCAPE = RETRATO / DEFAULT = A4
    let body = elementoHTML;
    docPDF.html(body, {
      callback: function() {
        action == "A" ? docPDF.output("dataurlnewwindow", config.nm_pdf) : "";
        action == "B" ? docPDF.save(config.nm_pdf) : "";
      },
      x: config.x,
      y: config.y,
      width: config.width,
      height: config.height,
    });
    return "Relatório Gerado! ";
  },
  //----------------------------------------------------------------------------------------------------------
  async downloadFile(fileUrl) {
    try {
      // Realiza a requisição para a URL pública
      const response = await axios.get(fileUrl);
      if (response.status !== 200) {
        throw new Error(`Erro ao baixar o arquivo: ${response.statusText}`);
      }
      const blob = new Blob([response.data], {
        type: "application/octet-stream",
      });
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      // Define o nome do arquivo (opcional)
      const fileName = fileUrl.split("/").pop();
      link.download = fileName || "arquivo";
      // Adiciona o link ao DOM, clica nele e remove em seguida
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      // Libera a URL temporária
      window.URL.revokeObjectURL(url);
    } catch (error) {
      console.error("Erro ao realizar o download:", error);
    }
  },
  //----------------------------------------------------------------------------------------------------------
  async FormataValor(valor, moeda = "BRL") {
    //currencies (moedas) "USD","EUR","JPY","GBP","CAD","AUD","CNY","CHF","INR","BRL",
    let valorNumerico = 0;

    // Verifica se o valor é uma string
    if (typeof valor === "string") {
      // Remove o símbolo R$ e possíveis espaços em branco
      valor = valor.replace(/\s|R\$/g, ""); //Real
      valor = valor.replace(/\s|US\$/g, ""); //Dólar
      valor = valor.replace(/\s|€/g, ""); //Euro
      // Substitui vírgulas por pontos
      valor = valor.replace(/,/g, ".");
      // Substitui o último ponto por vírgula, se houver mais de um ponto
      valor = valor.replace(/\.(?=.*\.)/g, ",");
      // Converte a string para número
      valorNumerico = parseFloat(valor);
    } else if (typeof valor === "number") {
      valorNumerico = valor;
    }

    // Verifica se o valor é um número válido
    if (isNaN(valorNumerico)) {
      return "R$ 0,00";
    }

    // Formata o valor
    const valorFormatado = valorNumerico.toLocaleString("pt-BR", {
      style: "currency",
      currency: moeda,
    });

    return valorFormatado;
  },
  //----------------------------------------------------------------------------------------------------------
  async FormataFloat(valor) {
    // valor = valor
    //   .replace("R$", "")
    //   .replaceAll(".", "")
    //   .replaceAll(",", ".")
    //   .trim();
    valor = parseFloat(valor);
    return valor;
  },
  //----------------------------------------------------------------------------------------------------------
  async CalculaTotal(arrayValores, moeda = "BRL") {
    //Recebe um array de valores e retorna a soma de todos eles
    let retorno = 0;
    //Confere se o array ? Float ou String
    if (typeof arrayValores[0] == "number") {
      for (let f = 0; f < arrayValores.length; f++) {
        retorno += parseFloat(arrayValores[f]);
      }
      retorno = retorno.toLocaleString("pt-BR", {
        style: "currency",
        currency: moeda,
      });
      return retorno;
    } else {
      for (let p = 0; p < arrayValores.length; p++) {
        arrayValores[p] = arrayValores[p] + "";

        arrayValores[p] = arrayValores[p]
          .replace("R$", "")
          .replaceAll(".", "")
          .replaceAll(",", ".")
          .trim();
        retorno += parseFloat(arrayValores[p]);
      }
      retorno = retorno.toLocaleString("pt-BR", {
        style: "currency",
        currency: moeda,
      });
      return retorno;
    }
  },
  //----------------------------------------------------------------------------------------------------------
  async Divisao(valor, divisor) {
    //Recebe um valor e um divisor, retorna o valor dividivo e formatado.
    //FORMA DE USO: let var1 = await funcao.Divisao('R$ 1.000,00',12)

    if (valor.includes("R$") == true) {
      valor = valor.replaceAll("R$", " ");
    }
    if (valor.includes(",") == true) {
      valor = valor.replaceAll(".", "");
      valor = valor.replaceAll(",", ".");
    }
    valor = parseFloat(valor) / divisor;
    valor = valor.toLocaleString("pt-BR", {
      style: "currency",
      currency: "BRL",
    });
    return valor;
  },
  //--------------------------------------------------------------------------------------------
  async DiaSemana() {
    //retorna qual o dia da semana
    let hoje = new Date();
    let dia = hoje.getDay();
    let semana = new Array(
      "Domingo",
      "Segunda-feira",
      "Terça-feira",
      "Quarta-feira",
      "Quinta-feira",
      "Sexta-feira",
      "Sábado",
    );
    let retorno = semana[dia];
    return retorno;
  },
  //--------------------------------------------------------------------------------------------
  //Formata CPF
  async FormataCPF(cpf) {
    let retorno = cpf + "";
    retorno =
      cpf.substring(0, 3) +
      "." +
      cpf.substring(3, 6) +
      "." +
      cpf.substring(6, 9) +
      "-" +
      cpf.substring(9, 11);
    return retorno;
  },
  //--------------------------------------------------------------------------------------------
  //Formata CNPJ
  async FormataCNPJ(cnpj) {
    let retorno = cnpj + "";
    retorno = retorno
      .replaceAll(".", "")
      .replaceAll("/", "")
      .replaceAll("-", "");

    retorno =
      cnpj.substring(0, 2) +
      "." +
      cnpj.substring(2, 5) +
      "." +
      cnpj.substring(5, 8) +
      "/" +
      cnpj.substring(8, 12) +
      "-" +
      cnpj.substring(12, 14);

    return retorno;
  },
  //--------------------------------------------------------------------------------------------
  async TamanhoTela() {
    //Retorna o tamanho da Tela de forma din?mica.
    var largura =
      window.innerWidth ||
      document.documentElement.clientWidth ||
      document.body.clientWidth;
    var altura =
      window.innerHeight ||
      document.documentElement.clientHeight ||
      document.body.clientHeight;
    let retorno = {
      altura: altura,
      largura: largura,
    };
    return retorno;
  },

  //--------------------------------------------------------------------------------------------
  async criptografa(codifica) {
    // Criptografa a informação enviada
    const crypto = require("crypto");
    const secret = "aaaaaaaaaabbbbbbbbbbcccccccccc/4"; // Precisa ter 32 caracteres - Aceitando numero e caract especial

    const encrypt = (value) => {
      const iv = Buffer.from(crypto.randomBytes(16)); // initialization vector (iv)
      const cipher = crypto.createCipheriv(
        "aes-256-cbc",
        Buffer.from(secret),
        iv,
      );
      let encrypted = cipher.update(value, "utf8");
      encrypted = Buffer.concat([encrypted, cipher.final()]);
      return `${iv.toString("hex")}:${encrypted.toString("hex")}`;
    };

    const crypted = encrypt(codifica);
    return crypted;
  },

  //--------------------------------------------------------------------------------------------
  async descriptografa(descodifica) {
    // Descriptografa a informação enviada
    const crypto = require("crypto");
    const secret = "aaaaaaaaaabbbbbbbbbbcccccccccc/4"; // Precisa ter 32 caracteres - Aceitando numero e caract especial

    const descrypt = (value) => {
      const [iv, encrypted] = value.split(":");
      const ivBuffer = Buffer.from(iv, "hex"); // initialization vector (iv)
      const dechiper = crypto.createDecipheriv(
        "aes-256-cbc",
        Buffer.from(secret),
        ivBuffer,
      );
      let content = dechiper.update(Buffer.from(encrypted, "hex"));
      try {
        content = Buffer.concat([content, dechiper.final()]);
        return content.toString();
      } catch {
        return false;
      }
    };
    const descrypted = descrypt(descodifica);
    return descrypted;
  },
  //--------------------------------------------------------------------------------------------
  async GeraStringAleatoria(len) {
    // Gera uma string aleatória, recebendo o tamanho da string como parâmetro
    let passwd = "";
    if (len === "" || len <= 0) {
      len = 10; //Default 10 caracteres
    }
    do {
      passwd += Math.random()
        .toString(36)
        .substring(2);
    } while (passwd.length < len);
    {
      passwd = passwd.substring(0, len);
      return passwd;
    }
  },
  //----------------------------------------------------------------------------------------------------------
  async EnviaEmail(json) {
    // Gera um email de acordo com o JSON enviado
    let dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 677); // 1523 - pr_api_gera_email_padrao_sistema

    let api = dados.nm_identificacao_api;

    // let json = { //Campos que devem vir no JSON
    //   cd_parametro: 0,
    //   cd_tipo_email: d.cd_tipo_email,
    //   cd_documento: d.cd_documento,
    //   cd_item_documento: d.cd_item_documento,
    //   cd_tipo_documento: d.cd_tipo_documento,
    //   cd_modulo: localStorage.cd_modulo,
    //   cd_usuario: localStorage.cd_usuario,
    // };
    var email = await Incluir.incluirRegistro(api, json);
    notify(email[0].Msg);
    return;
  },
  //----------------------------------------------------------------------------------------------------------
  checarData(dataEnviada) {
    var verifica_data = new Date(
      dataEnviada.substring(6, 10),
      dataEnviada.substring(3, 5) - 1,
      dataEnviada.substring(0, 2),
    );
    if (parseInt(dataEnviada.substring(6, 10)) < 1800) {
      notify("Ano digitado inválido");
      return false;
    }
    if (
      parseInt(dataEnviada.substring(3, 5)) > 12 &&
      parseInt(dataEnviada.substring(3, 5)) < 0
    ) {
      notify("Mês digitado invalido");
      return false;
    }
    if (
      parseInt(dataEnviada.substring(0, 2)) > 31 &&
      parseInt(dataEnviada.substring(0, 2)) < 0
    ) {
      notify("Dia digitado invalido");
      return false;
    }
    if (verifica_data.getFullYear() == dataEnviada.substring(6, 10)) {
      //ano
      if (verifica_data.getMonth() + 1 == dataEnviada.substring(3, 5)) {
        //mes
        if (verifica_data.getDate() == dataEnviada.substring(0, 2)) {
          //dia
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  },
  //----------------------------------------------------------------------------------------------------------
  async somaData(data, dias) {
    // Soma os dias a data passada - Formato new Date("2017-01-26") YYYY-MM-DD
    var res = new Date(data);
    if (res == "Invalid Date") {
      res = new Date();
    }
    res.setDate(res.getDate() + dias);
    return res;
  },
  //----------------------------------------------------------------------------------------------------------
  async calculaPorcentagem(valor, percentual) {
    //Calcula a porcentagem de um valor e retorna formatado em pt-br
    let retorno = 0;
    if (valor.includes("R$") == true) {
      valor = valor.replaceAll("R$", " ");
    }
    if (valor.includes(",") == true) {
      valor = valor.replaceAll(".", "");
      valor = valor.replaceAll(",", ".");
    }
    let umPer = parseFloat(valor) / 100;
    retorno = umPer * percentual;
    retorno = await this.FormataValor(retorno);
    return retorno;
  },
  //----------------------------------------------------------------------------------------------------------
  ValidaCPF(strCPF) {
    //Valida o CPF digitado
    let Soma = 0;
    let Resto = 0;
    if (
      strCPF.length != 11 ||
      strCPF == "00000000000" ||
      strCPF == "11111111111" ||
      strCPF == "22222222222" ||
      strCPF == "33333333333" ||
      strCPF == "44444444444" ||
      strCPF == "55555555555" ||
      strCPF == "66666666666" ||
      strCPF == "77777777777" ||
      strCPF == "88888888888" ||
      strCPF == "99999999999"
    )
      return false;

    for (let i = 1; i <= 9; i++)
      Soma = Soma + parseInt(strCPF.substring(i - 1, i)) * (11 - i);
    Resto = (Soma * 10) % 11;
    if (Resto == 10 || Resto == 11) Resto = 0;
    if (Resto != parseInt(strCPF.substring(9, 10))) return false;
    Soma = 0;
    for (let i = 1; i <= 10; i++)
      Soma = Soma + parseInt(strCPF.substring(i - 1, i)) * (12 - i);
    Resto = (Soma * 10) % 11;
    if (Resto == 10 || Resto == 11) Resto = 0;
    if (Resto != parseInt(strCPF.substring(10, 11))) return false;
    return true;
  },
  //----------------------------------------------------------------------------------------------------------
  async BuscaCNPJ(cnpj) {
    //Busca de CNPJ
    let retorno = {};
    cnpj =
      cnpj
        .replaceAll(".", "")
        .replaceAll("/", "")
        .replaceAll("-", "") + "";

    let proxy;

    let v = {
      cd_cnpj: cnpj,
      cd_parametro: 7,
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
    };

    const consulta = await Incluir.incluirRegistro("472/666", v);
    if (consulta[0] == undefined || consulta[0].Cod == 0) {
      proxy = await axios.get(urlCNPJ + cnpj);
      proxy = proxy.data;

      if (!!proxy.cnpj == true) {
        let ativa = proxy.situacao;
        ativa == "ATIVA" ? (ativa = "S") : (ativa = "N");

        let json = {
          dt_abertura: formatadata.formataDataSQL(proxy.abertura),
          nm_atividade_principal: proxy.atividade_principal[0].text,
          nm_bairro: proxy.bairro,
          vl_capital_social: proxy.capital_social,
          cd_cep: proxy.cep,
          cd_cnpj: cnpj,
          nm_complemento: proxy.complemento,

          dt_situacao: formatadata.formataDataSQL(proxy.data_situacao),
          dt_situacao_especial: formatadata.formataDataSQL(
            proxy.data_situacao_especial,
          ),
          nm_email: proxy.email,
          nm_endereco_cnpj: proxy.logradouro,
          nm_fantasia_cnpj: proxy.fantasia,
          nm_natureza_juridica: proxy.natureza_juridica,
          nm_razao_social_cnpj: proxy.nome,
          cd_numero_cnpj: proxy.numero,
          ic_ativa: ativa,
          cd_telefone_cnpj: proxy.telefone,
          sg_estado: proxy.uf,
          cd_usuario: localStorage.cd_usuario,
          cd_parametro: 8,
        };

        await Incluir.incluirRegistro("472/666", json);
        json.cd_cnpj = await this.FormataCNPJ(cnpj);
        json.dt_abertura = formatadata.VoltaDataSQL(json.dt_abertura);
        json.dt_situacao = formatadata.VoltaDataSQL(json.dt_situacao);
        json.vl_capital_social = await this.FormataValor(
          json.vl_capital_social,
        );
        retorno = json;
      }
    } else {
      consulta[0].cd_cnpj = await this.FormataCNPJ(cnpj);
      consulta[0].vl_capital_social = await this.FormataValor(
        consulta[0].vl_capital_social,
      );
      retorno = consulta[0];
    }

    return retorno;
  },
  //----------------------------------------------------------------------------------------------------------
  //Formatação de telefone - é necessário passar o ddd e o telefone concatenado
  async FormataTelefone(cd_telefone) {
    cd_telefone = cd_telefone + "";
    cd_telefone = cd_telefone
      .replaceAll(" ", "")
      .replaceAll("-", "")
      .trim();
    cd_telefone =
      "(" +
      cd_telefone.substring(0, 2) +
      ") " +
      cd_telefone.substring(2, 6) +
      "-" +
      cd_telefone.substring(6, 10);
    return cd_telefone;
  },
  //----------------------------------------------------------------------------------------------------------
  async FormataCelular(celular) {
    if (celular.length < 11) return;
    celular = celular + "";
    celular = celular.replaceAll(" ", "").replaceAll("-", "");

    celular =
      "(" +
      celular.substring(0, 2) +
      ")" +
      celular.substring(2, 7) +
      "-" +
      celular.substring(7, 11);
    return celular;
  },
  //----------------------------------------------------------------------------------------------------------
  async Semana(tipo) {
    if (!!tipo == false) {
      tipo = 1;
    }
    const dates = formatadata.FormataLocalStorage();
    const data = new Date(dates.dt_inicial);

    var day = data.getDay(); // Pega o dia de Hoje (Segunda,Terça e etc)
    var primeiro = data.getDate() - day + (day == 0 ? -6 : 1); // Encontra segunda feira

    const primeiroDia = new Date(data.setDate(primeiro)).toUTCString();
    const ultimoDia = new Date(data.setDate(data.getDate() + 5)).toUTCString();
    let endWeek = new Date(ultimoDia);
    let endMonth = endWeek.getMonth() + 1;
    endMonth < 10 ? (endMonth = "0" + endMonth) : "";

    let endDay = endWeek.getDate() - 1;
    endDay < 10 ? (endDay = "0" + endDay) : "";
    const endYear = endWeek.getFullYear();

    const fim = endDay + "/" + endMonth + "/" + endYear;

    //-------------------------------------------
    let initWeek = new Date(primeiroDia);
    let initMonth = initWeek.getMonth() + 1;
    initMonth < 10 ? (initMonth = "0" + initMonth) : "";

    let initDay = initWeek.getDate(); //+ 1;
    initDay < 10 ? (initDay = "0" + initDay) : "";
    const initYear = initWeek.getFullYear();
    const inicio = initDay + "/" + initMonth + "/" + initYear;

    var PegaData = new Date();
    var dia = String(PegaData.getDate()).padStart(2, "0");
    var mes = String(PegaData.getMonth() + 1).padStart(2, "0");
    var ano = PegaData.getFullYear();

    if (dia == "01") {
      const atual = `${dia}/${mes}/${ano}`;
      localStorage.dt_inicial = formatadata.formataDataSQL(atual);
    }

    if (tipo == 1) {
      return inicio + " - " + fim;
    } else {
      return {
        dt_inicial: inicio,
        dt_final: fim,
      };
    }
  },
  //----------------------------------------------------------------------------------------------------------
  async Desconto(valor, desconto, formatacao) {
    if (!!formatacao == false) {
      formatacao = false;
    }
    let retorno = valor - (valor / 100) * desconto;
    retorno = retorno.toFixed(2);
    if (retorno < 0) {
      retorno = 0;
    }
    if (formatacao == true) {
      retorno = await this.FormataValor(retorno);
    }
    return retorno;
  },
  //----------------------------------------------------------------------------------------------------------
  async CalculaKM(lat1, lon1, lat2, lon2) {
    const loader = new Loader({
      apiKey: "AIzaSyDE35BHw4UsWyGAzA4Gimr6pdleTvIbcs8",
      version: "weekly",
    });
    const mapDiv = {};
    loader.load().then(() => {
      new google.maps.Map(mapDiv, {
        center: { lat: -23.56478844493474, lng: -46.6524688272795 },
        zoom: 8,
      });
      const service = new google.maps.DistanceMatrixService();

      if (
        !!lat1 == false ||
        !!lon1 == false ||
        !!lat2 == false ||
        !!lon2 == false
      ) {
        return {
          Cod: 0,
          status: "Localização inválida!",
        };
      } else {
        const origin = { lat: lat1, lng: lon1 };
        const destination = { lat: lat2, lng: lon2 };
        const request = {
          origins: [origin],
          destinations: [destination],
          travelMode: "DRIVING",
        };
        service.getDistanceMatrix(request).then((response) => {
          if (response.rows[0].elements[0].status == "OK") {
            const ret = {
              response: response.rows,
              Cod: 1,
            };
            return ret;
          } else {
            const ret1 = {
              Cod: 0,
              status: "Localização não encontrada!",
            };
            return ret1;
          }
        });
      }
    });
  },
  //----------------------------------------------------------------------------------------------------------
  ValidaString(str, len = 50) {
    //Tratamento de espaços em branco
    str = str.trim();
    // Limitar o tamanho da string
    str = str.slice(0, len);
    // Retirar caracteres que podem causar problemas
    str = str
      .replaceAll("'", "")
      .replaceAll("\"", "")
      .replaceAll("*", "")
      .replaceAll("/", "")
      //.replaceAll("-", "")
      .replaceAll("+", "")
      .replaceAll("=", "");
    return str;
  },
  //----------------------------------------------------------------------------------------------------------
  ValidaStringSimples(str) {
    //Tratamento de espaços em branco
    str = str.trim();
    // Limitar o tamanho da string
    //str = str.slice(0, len);
    // Retirar caracteres que podem causar problemas
    str = str.replaceAll("'", "").replaceAll("\"", "");
    return str;
  },
  //----------------------------------------------------------------------------------------------------------
  isJSON(str) {
    try {
      JSON.parse(str);
    } catch {
      return false;
    }
    return true;
  },
  //----------------------------------------------------------------------------------------------------------
  isNumber(numb) {
    let result = numb === null ? 0 : numb;
    if (
      result === 0 ||
      result === "" ||
      typeof result === "boolean" ||
      typeof result === "object"
    ) {
      return 0;
    } else {
      result = isNaN(numb); // false = numero | true = não é numero
      return result ? 0 : parseFloat(numb);
    }
  },
  //----------------------------------------------------------------------------------------------------------
  getDataInicial(mes, ano) {
    var data = new Date(ano, mes - 1, 1);
    if (mes == undefined && ano == undefined) {
      data = new Date();
    }
    let mes_escolhido = data.getMonth() + 1;
    mes_escolhido =
      mes_escolhido.toString().length == 1
        ? "0" + mes_escolhido.toString().toString()
        : mes_escolhido.toString().toString();
    let ano_escolhido = data.getFullYear();
    let dataInicial = `${mes_escolhido}-01-${ano_escolhido}`;
    return dataInicial;
  },
  //----------------------------------------------------------------------------------------------------------
  getDataFinal(mes, ano) {
    var data = new Date(ano, mes - 1, 1);
    if (mes == undefined && ano == undefined) {
      data = new Date();
    }
    var dias = 0;
    let mes_escolhido = data.getMonth() + 1;
    mes_escolhido =
      mes_escolhido.toString().length == 1
        ? "0" + mes_escolhido.toString()
        : mes_escolhido.toString();
    let ano_escolhido = data.getFullYear();
    switch (mes_escolhido) {
      case "0": //Janeiro
        dias = 31;
        break;
      case "01": //Fevereiro
        dias = 28;
        break;
      case "02": //Março
        dias = 31;
        break;
      case "03": //Abril
        dias = 30;
        break;
      case "04": //Maio
        dias = 31;
        break;
      case "05": //Junho
        dias = 30;
        break;
      case "06": //Julho
        dias = 31;
        break;
      case "07": //Agosto
        dias = 31;
        break;
      case "08": //Setembro
        dias = 30;
        break;
      case "09": //Outubro
        dias = 31;
        break;
      case "10": //Novembro
        dias = 30;
        break;
      case "11": //Dezembro
        dias = 31;
        break;
    }
    let dataFinal = `${mes_escolhido}-${dias}-${ano_escolhido}`;
    return dataFinal;
  },
  DiaHoje(d) {
    //Informa uma data e retorna o dia da semana
    d = new Date(d);
    var day = d.getDay();
    let dia = "";
    switch (day) {
      case 0: //Domingo
        dia = "Domingo";
        break;
      case 1: //Segunda
        dia = "Segunda-Feira";
        break;
      case 2: //Terça
        dia = "Terça-Feira";
        break;
      case 3: //Quarta
        dia = "Quarta-Feira";
        break;
      case 4: //Quinta
        dia = "Quinta-Feira";
        break;
      case 5: //Sexta
        dia = "Sexta-Feira";
        break;
      case 6: //Sábado
        dia = "Sábado";
        break;
    }
    return dia;
  },
  DataBRtoUSA(data) {
    //Converte uma data no formato BR para o formato SQL
    if (data == undefined || data == null) {
      return "";
    }
    let ano = data.substring(6, 10);
    let mes = data.substring(3, 5);
    let dia = data.substring(0, 2);
    return `${dia}-${mes}-${ano}`;
  },
  RealParaInt(real) {
    var n = real;
    if (String(real).includes("R$")) {
      //Real
      n = String(real).replace("R$", "");
    } else if (String(real).includes("US$")) {
      //Dólar
      n = String(real).replace("US$", "");
    } else if (String(real).includes("€")) {
      //Euro
      n = String(real).replace("€", "");
    } else {
      n = "0.00";
    }
    if (n === "") {
      n = 0;
    } else {
      n = n.includes(".") ? n.replaceAll(".", "") : n;
      n = n.replace(",", ".");
      n = parseFloat(n);
    }
    return n;
  },
  SubstituirDataRegex(texto, data = new Date()) {
  const dd = String(data.getDate()).padStart(2, "0");
  const mm = String(data.getMonth() + 1).padStart(2, "0");
  const yy = String(data.getFullYear()).slice(-2); // 2 últimos dígitos

  return texto
    .replace(/\+DD/g, dd)
    .replace(/\+MM/g, mm)
    .replace(/\+YY/g, yy);
},
};
