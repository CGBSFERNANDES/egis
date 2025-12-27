import store from "../store";
import { http } from "./api";
import { httpEgismob } from "./apiEgismob";
import { httpEgisApp } from "./apiEgisApp";

export default {
  async montarProcedimento(
    cd_empresa,
    cd_cliente,
    nm_identificacao_api,
    nm_parametro_api
  ) {
    try {
      //alert(nm_identificacao_api);

      //mostra os parametros da Api
      //alert(nm_parametro_api);
      //

      var sParametro = "";
      var cd_familia_produto = 0;
      var nm_fantasia_produto = "null";
      var nm_produto = "null";
      var cd_modulo = 0;
      var nm_fantasia = "null";
      var nm_razao_social = "null";
      var cd_parametro = 0;
      var cd_usuario = 0;
      var nm_documento = "";
      var cd_identificacao = localStorage.cd_identificacao;
      var dt_base = localStorage.dt_base;
      var cd_fornecedor = localStorage.cd_fornecedor;
      var dt_inicial = localStorage.dt_inicial;
      var dt_final = localStorage.dt_final;
      var nm_pesquisa = localStorage.nm_pesquisa;
      var nm_json = localStorage.nm_json;
      var cd_cnpj = localStorage.cd_cnpj;
      var cd_cep = localStorage.cd_cep;

      var cd_processo = localStorage.cd_processo;
      var cd_operacao = localStorage.cd_operacao;
      var cd_maquina = localStorage.cd_maquina;
      var cd_operador = localStorage.cd_operador;
      var qt_apontamento = localStorage.qt_apontamento;
      var cd_item_processo = localStorage.cd_item_processo;
      var cd_motivo = localStorage.cd_motivo;
      var qt_refugo = localStorage.qt_refugo;
      var ic_apontamento = localStorage.ic_apontamento;

      cd_modulo = localStorage.cd_modulo;
      cd_usuario = localStorage.cd_usuario;
      cd_parametro = localStorage.cd_parametro;
      nm_documento = localStorage.nm_documento;

      //alert(cd_parametro);

      //Parâmetro Base
      sParametro = `${nm_identificacao_api}/${cd_empresa}`;

      //alert(sParametro);
      //
      //
      //12.02.2020 - desenvolver uma rotina dinamica de passagem de parametros
      //Form para Api
      //

      //Parâmetros para a API
      //if (!nm_parametro_api == '') {
      //    sParametro = nm_parametro_api
      //  }
      //else {
      //Verifica se Existe o Módulo

      if (nm_parametro_api.indexOf("cd_modulo") != -1) {
        sParametro = sParametro + `/${cd_modulo}`;
      }

      // alert(sParametro);

      //Verifica se Existe o Cliente
      //    if (cd_cliente == 0 ) {

      if (nm_parametro_api.indexOf("cd_cliente") != -1) {
        sParametro = sParametro + `/${cd_cliente}`;
        //alert('cd_cliente');
      }

      if (
        nm_parametro_api.indexOf("cd_fornecedor") != -1 &&
        !cd_fornecedor == 0
      ) {
        sParametro = sParametro + `/${cd_fornecedor}`;
        //alert('cd_cliente');
      }

      if (nm_parametro_api.indexOf("cd_destinatario") != -1) {
        let cd_destinatario = 0;
        if (!localStorage.cd_destinatario == 0) {
          cd_destinatario = localStorage.cd_destinatario;
        } else cd_destinatario = cd_cliente;

        sParametro = sParametro + `/${cd_destinatario}`;
        //alert('cd_cliente');
      }

      //Verifica se Existe o Parâmetro de algumas procedures
      if (nm_parametro_api.indexOf("cd_parametro") != -1) {
        //cd_parametro = 0;
        //alert(cd_parametro);
        sParametro = sParametro + `/${cd_parametro}`;
      }

      //Verifica se Existe o Usuário
      //alert(cd_usuario);
      if (nm_parametro_api.indexOf("cd_usuario") != -1) {
        sParametro = sParametro + `/${cd_usuario}`;
        //alert(cd_usuario);
        //alert(sParametro);
      }

      //Família
      if (nm_parametro_api.indexOf("cd_familia_produto") != -1) {
        cd_familia_produto = localStorage.cd_familia_produto;
        sParametro = sParametro + `/${cd_familia_produto}`;
        //alert('cd_familia_produto');
      }

      //Fantasia
      if (nm_parametro_api.indexOf("nm_fantasia_produto") != -1) {
        nm_fantasia_produto = localStorage.nm_fantasia_produto;
        sParametro = sParametro + `/${nm_fantasia_produto}`;
        //alert('nm_fantasia_produto');
      }

      //Descrição
      if (nm_parametro_api.indexOf("nm_produto") != -1) {
        nm_produto = localStorage.nm_produto;
        sParametro = sParametro + `/${nm_produto}`;
        //alert('nm_produto');
      }

      //Verifica se Existe o Usuário
      if (nm_parametro_api.indexOf("cd_tipo_consulta") != -1) {
        let cd_tipo_consulta = localStorage.cd_tipo_consulta;
        //alert(cd_tipo_consulta);
        //cd_tipo_consulta = 0;
        if (cd_tipo_consulta >= 0) {
          sParametro = sParametro + `/${cd_tipo_consulta}`;
        }
        // alert('1'+sParametro);
      }

      //Fantasia
      nm_fantasia = localStorage.nm_fantasia;

      if (nm_parametro_api.indexOf("nm_fantasia") != -1 && !nm_fantasia == "") {
        sParametro = sParametro + `/${nm_fantasia}`;
        // alert(localStorage.nm_fantasia);
      }

      //Fantasia
      nm_razao_social = localStorage.nm_razao_social;

      if (
        nm_parametro_api.indexOf("nm_razao_social") != -1 &&
        !nm_razao_social == ""
      ) {
        sParametro = sParametro + `/${nm_razao_social}`;
        //alert('nm_razao_social');
      }

      //Data Base
      if (nm_parametro_api.indexOf("dt_base") != -1 && !dt_base == "") {
        sParametro = sParametro + `/${dt_base}`;
        //alert('nm_razao_social');
      }

      //Documento/Identificação
      if (
        nm_parametro_api.indexOf("cd_identificacao") != -1 &&
        !cd_identificacao == ""
      ) {
        sParametro = sParametro + `/${cd_identificacao}`;
        //alert('cd_identificacao');
      }

      //alert(nm_documento);

      if (
        nm_parametro_api.indexOf("nm_documento") != -1 &&
        !nm_documento == ""
      ) {
        sParametro = sParametro + `/${nm_documento}`;
        //alert('nm_razao_social');
      }

      if (
        nm_parametro_api.indexOf("cd_empresa_usuario") != -1 &&
        !cd_empresa == 0
      ) {
        sParametro = sParametro + `/${cd_empresa}`;
        // alert(localStorage.nm_fantasia);
      }

      //Data Inicial
      if (nm_parametro_api.indexOf("dt_inicial") != -1 && !dt_inicial == "") {
        sParametro = sParametro + `/${dt_inicial}`;
        //alert('nm_razao_social');
      }

      //Data Inicial
      if (nm_parametro_api.indexOf("dt_final") != -1 && !dt_final == "") {
        sParametro = sParametro + `/${dt_final}`;
        //alert('nm_razao_social');
      }

      //Pesquisa
      if (nm_parametro_api.indexOf("nm_pesquisa") != -1 && !nm_pesquisa == "") {
        sParametro = sParametro + `/${nm_pesquisa}`;
        //alert('nm_razao_social');
      }

      //JSON
      if (nm_parametro_api.indexOf("nm_json") != -1 && !nm_json == "") {
        nm_json = localStorage.nm_json;
        sParametro = sParametro + `/${nm_json}`;
        //alert(nm_json);
      }

      //PROCESSO
      if (nm_parametro_api.indexOf("cd_processo") != -1 && !cd_processo == "") {
        sParametro = sParametro + `/${cd_processo}`;
        //alert(cd_processo);
      }

      //OPERAÇÃO
      if (nm_parametro_api.indexOf("cd_operacao") != -1 && !cd_operacao == "") {
        sParametro = sParametro + `/${cd_operacao}`;
        //alert(cd_operacao);
      }

      //PROCESSO
      if (nm_parametro_api.indexOf("cd_maquina") != -1 && !cd_maquina == "") {
        sParametro = sParametro + `/${cd_maquina}`;
        //alert(cd_maquina);
      }

      //OPERADOR
      if (nm_parametro_api.indexOf("cd_operador") != -1 && !cd_operador == "") {
        sParametro = sParametro + `/${cd_operador}`;
        //alert(cd_operador);
      }

      //QUANTIDADE
      if (
        nm_parametro_api.indexOf("qt_apontamento") != -1 &&
        !qt_apontamento == ""
      ) {
        sParametro = sParametro + `/${qt_apontamento}`;
        //alert(qt_apontamento);
      }

      //MOTIVO
      if (nm_parametro_api.indexOf("cd_motivo") != -1 && !cd_motivo == "") {
        sParametro = sParametro + `/${cd_motivo}`;
        //alert(nm_json);
      }

      //ITEM PROCESSO
      if (
        nm_parametro_api.indexOf("cd_item_processo") != -1 &&
        !cd_item_processo == ""
      ) {
        sParametro = sParametro + `/${cd_item_processo}`;
        //alert(nm_json);
      }

      //REFUGO
      if (nm_parametro_api.indexOf("qt_refugo") != -1 && !qt_refugo == "") {
        sParametro = sParametro + `/${qt_refugo}`;
        //alert(qt_refugo);
      }

      //IC_APONTAMENTO
      if (
        nm_parametro_api.indexOf("ic_apontamento") != -1 &&
        !ic_apontamento == ""
      ) {
        sParametro = sParametro + `/${ic_apontamento}`;
        //alert(ic_apontamento);
      }

      //CD_CNPJ
      if (nm_parametro_api.indexOf("cd_cnpj") != -1 && !cd_cnpj == "") {
        sParametro = sParametro + `/${cd_cnpj}`;
        //alert(cd_cnpj);
      }

      if (nm_parametro_api.indexOf("cd_cep") != -1 && !cd_cep == "") {
        sParametro = sParametro + `/${cd_cep}`;
        //alert(cd_cnpj);
      }

      //alert(sParametro);

      return await http.get(sParametro).then((resposta) => resposta.data);
    } catch (err) {
      console.error("erro " + err);
      if(store._mutations.SET_Usuario.ic_multi_servidor === "S"){
        try {
           return await httpEgisApp.get(sParametro).then((resposta) => resposta.data);
          } catch (error) {
             console.error("erro " + error);
             return await httpEgismob.get(sParametro).then((resposta) => resposta.data);
            }
          }
    }
  },
};
