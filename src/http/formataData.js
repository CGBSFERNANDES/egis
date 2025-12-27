import funcoesPadroes from "./funcoes-padroes";

export default {
  formataDataJS(data) {
    let formatada = data.replace("-", "");
    var ano = formatada.substring(0, 4);
    var mes = formatada.substring(4, 6);
    var dia = formatada.substring(7, 9);
    return dia + "/" + mes + "/" + ano;
  },
  formataDataSQL(data) {
    let data_param = data;
    if (!data) {
      data_param = funcoesPadroes.DataHoje();
    }
    if(data_param.match(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/)){
      return data_param;
    }
    let formatada = data_param;
    var diaF = formatada.substring(0, 2);
    var mesF = formatada.substring(3, 5);
    var anoF = formatada.substring(6, 10);

    return mesF + "-" + diaF + "-" + anoF;
  },
  formataHoraJS(data) {
    let formatada = data;
    var horasF = formatada.substring(11, 13) - 3; // -3 horas devido ao fuso horário
    var minutosF = formatada.substring(14, 16);
    var segundosF = formatada.substring(17, 19);

    return horasF + ":" + minutosF + ":" + segundosF;
  },
  VoltaDataSQL(data) {
    data = data.replaceAll("-", "");
    return (
      data.substring(0, 2) +
      "/" +
      data.substring(2, 4) +
      "/" +
      data.substring(4)
    );
  },
  async FormataDataCNPJ(data) {
    data = data.replaceAll("-", "");
    return (
      data.substring(2, 4) +
      "/" +
      data.substring(0, 2) +
      "/" +
      data.substring(4)
    );
  },
  FormataLocalStorage() {
    let data = localStorage.dt_inicial.replaceAll("-", "");
    let dt_final = localStorage.dt_final.replaceAll("-", "");
    const init =
      data.substring(0, 2) +
      "/" +
      data.substring(2, 4) +
      "/" +
      data.substring(4);

    const final =
      dt_final.substring(0, 2) +
      "/" +
      dt_final.substring(2, 4) +
      "/" +
      dt_final.substring(4);
    let retorno = {
      dt_inicial: init,
      dt_final: final,
    };
    return retorno;
  },
  AnoMesDia(data) {
    //var data = new Date(),
    var dia = data.getDate().toString();
    var diaF = dia.length == 1 ? "0" + dia : dia;
    var mes = (data.getMonth() + 1).toString(); //+1 pois no getMonth Janeiro começa com zero.
    var mesF = mes.length == 1 ? "0" + mes : mes;
    var anoF = data.getFullYear();
    return anoF + "-" + mesF + "-" + diaF;
  },
  MesDiaAno(data) {
    var data_param = new Date(data);
    var dia = data_param.getDate().toString();
    var diaF = dia.length == 1 ? "0" + dia : dia;
    var mes = (data_param.getMonth() + 1).toString(); //+1 pois no getMonth Janeiro começa com zero.
    var mesF = mes.length == 1 ? "0" + mes : mes;
    var anoF = data_param.getFullYear();
    return mesF + "-" + diaF + "-" + anoF;
  },
  DiaMesAno(data, formatacao) {
    var data_param = new Date(data);
    var dia = data_param.getDate().toString();
    var diaF = dia.length == 1 ? "0" + dia : dia;
    var mes = (data_param.getMonth() + 1).toString(); //+1 pois no getMonth Janeiro começa com zero.
    var mesF = mes.length == 1 ? "0" + mes : mes;
    var anoF = data_param.getFullYear();
    if (formatacao) {
      return diaF + "/" + mesF + "/" + anoF;
    } else {
      return diaF + "-" + mesF + "-" + anoF;
    }
  },
};
