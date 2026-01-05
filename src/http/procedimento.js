import store from '../store'
import { http } from './api'
import { httpEgismob } from './apiEgismob'
import { httpEgisApp } from './apiEgisApp'

export default {
  async montarProcedimento(
    cd_empresa,
    cd_api_cliente,
    nm_identificacao_api,
    nm_parametro_api
  ) {
    try {
          ////ALERT(nm_identificacao_api);

          //mostra os parametros da Api
          ////ALERT(nm_parametro_api);
          //

          var sParametro = "";
          var cd_familia_produto = 0;
          var nm_fantasia_produto = "null";
          var nm_produto = "null";
          var cd_modulo = 0;
          var nm_fantasia = "null";
          var nm_razao_social = "null";
          var cd_parametro = 0;
          var ic_parametro = localStorage.ic_parametro;
          var cd_usuario = 0;
          var nm_documento = "";
          var cd_empresa_usuario = 0;
          var ds_parametro = "";
          var cd_identificacao = localStorage.cd_identificacao;
          var dt_base = localStorage.dt_base;
          var cd_cliente = cd_api_cliente || localStorage.cd_cliente || 0;
          var cd_fornecedor = localStorage.cd_fornecedor || 0;
          var dt_inicial = localStorage.dt_inicial;
          var dt_final = localStorage.dt_final;
          var nm_pesquisa = localStorage.nm_pesquisa;
          var cd_cnpj = localStorage.cd_cnpj;
          var cd_cep = localStorage.cd_cep;
          var cd_cnpj_cpf = localStorage.cd_cnpj_cpf;
          var cd_tipo_filtro = localStorage.cd_tipo_filtro;
          var cd_filtro = localStorage.cd_filtro;
          var vl_contrato = localStorage.vl_contrato;
          var cd_documento = localStorage.cd_documento;
          var cd_item_documento = localStorage.cd_item_documento;
          var cd_tipo_documento = localStorage.cd_tipo_documento;
          var qt_apontamento = localStorage.qt_apontamento;
          var cd_processo = localStorage.cd_processo || 0;
          var dt_processo = localStorage.dt_processo;
          var cd_movimento = localStorage.cd_movimento || 0;
          var cd_menu = localStorage.cd_menu || 0;
          var cd_etapa = localStorage.cd_etapa || 0;
          var cd_etapa_origem = localStorage.cd_etapa_origem;
          var cd_etapa_destino = localStorage.cd_etapa_destino;
          var cd_empresa_fat = localStorage.cd_empresa_fat;
          var cd_entregador = localStorage.cd_entregador;
          var qt_ordem = localStorage.qt_ordem;
          var cd_tipo_parametro = localStorage.cd_tipo_parametro;
          var cd_tipo_email = localStorage.cd_tipo_email;
          var cd_relatorio = localStorage.cd_relatorio;
          var nm_json = localStorage.nm_json;
          var cd_contato = localStorage.cd_contato || 0;

          cd_modulo = localStorage.cd_modulo || 0;
          cd_usuario = localStorage.cd_usuario || 0;
          cd_parametro = localStorage.cd_parametro || 0;
          nm_documento = localStorage.nm_documento;
          cd_empresa_usuario = localStorage.cd_empresa_usuario;
          ds_parametro = localStorage.ds_parametro;

          var cd_form = localStorage.cd_form;
          var cd_comanda = localStorage.cd_comanda;
          var cd_tabela_preco = localStorage.cd_tabela_preco;
          var cd_ano = localStorage.cd_ano;
          var cd_vendedor = localStorage.cd_vendedor || 0;
          var ds_xml = localStorage.ds_xml || "";

          ////ALERT(cd_parametro);

          //Parâmetro Base
          sParametro = `${nm_identificacao_api}/${cd_empresa}`;

          ////ALERT(sParametro);
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

          if (nm_parametro_api.indexOf("{cd_modulo}") != -1) {
            sParametro = sParametro + `/${cd_modulo}`;
          }

          // //ALERT(sParametro);

          //Verifica se Existe o Cliente
          //    if (cd_cliente == 0 ) {

          if (nm_parametro_api.indexOf("{cd_cliente}") != -1) {
            sParametro = sParametro + `/${cd_cliente}`;
            ////ALERT('cd_cliente');
          }

          //console.log("Parametro API --> ", sParametro, cd_cliente, cd_api_cliente);

          if (
            nm_parametro_api.indexOf("{cd_fornecedor}") != -1 &&
            !cd_fornecedor == 0
          ) {
            sParametro = sParametro + `/${cd_fornecedor}`;
            ////ALERT('cd_cliente');
          }

          if (nm_parametro_api.indexOf("{cd_destinatario}") != -1) {
            let cd_destinatario = 0;
            if (!localStorage.cd_destinatario == 0) {
              cd_destinatario = localStorage.cd_destinatario;
            } else cd_destinatario = cd_cliente;

            sParametro = sParametro + `/${cd_destinatario}`;
            ////ALERT('cd_cliente');
          }

          //Verifica se Existe o Parâmetro de algumas procedures
          if (nm_parametro_api.indexOf("{cd_menu}") != -1) {
            //cd_parametro = 0;
            sParametro = sParametro + `/${cd_menu}`;
            //ALERT('CD_PARAMETRO :' + cd_parametro);
          }

          //Verifica se Existe o Parâmetro de algumas procedures
          //alert(localStorage.cd_parametro);

          if (nm_parametro_api.indexOf("{cd_parametro}") != -1) {
            //cd_parametro = 0;
            sParametro = sParametro + `/${cd_parametro}`;
            //ALERT('CD_PARAMETRO :' + cd_parametro);
          }

          if (nm_parametro_api.indexOf("{ic_parametro}") != -1) {
            //cd_parametro = 0;
            sParametro = sParametro + `/${ic_parametro}`;
            //ALERT('CD_PARAMETRO :' + cd_parametro);
          }

          //Verifica se Existe o Usuário
          ////ALERT(cd_usuario);
          if (nm_parametro_api.indexOf("{cd_usuario}") != -1) {
            sParametro = sParametro + `/${cd_usuario}`;
            ////ALERT(cd_usuario);
            ////ALERT(sParametro);
          }

          //Família
          if (nm_parametro_api.indexOf("{cd_familia_produto}") != -1) {
            cd_familia_produto = localStorage.cd_familia_produto;
            sParametro = sParametro + `/${cd_familia_produto}`;
            ////ALERT('cd_familia_produto');
          }

          //Fantasia
          if (nm_parametro_api.indexOf("{nm_fantasia_produto}") != -1) {
            nm_fantasia_produto = localStorage.nm_fantasia_produto;
            sParametro = sParametro + `/${nm_fantasia_produto}`;
            ////ALERT('nm_fantasia_produto');
          }

          //Descrição
          if (nm_parametro_api.indexOf("{nm_produto}") != -1) {
            nm_produto = localStorage.nm_produto;
            sParametro = sParametro + `/${nm_produto}`;
            ////ALERT('nm_produto');
          }

          //Verifica se Existe o Usuário
          if (nm_parametro_api.indexOf("{cd_tipo_consulta}") != -1) {
            let cd_tipo_consulta = localStorage.cd_tipo_consulta;
            //ALERT('CD_TIPO_CONSULTA: ' + cd_tipo_consulta);
            //cd_tipo_consulta = 0;
            if (cd_tipo_consulta >= 0) {
              sParametro = sParametro + `/${cd_tipo_consulta}`;
            }
            // //ALERT('1'+sParametro);
          }

          //Fantasia
          nm_fantasia = localStorage.nm_fantasia;

          if (
            nm_parametro_api.indexOf("{nm_fantasia}") != -1 &&
            !nm_fantasia == ""
          ) {
            sParametro = sParametro + `/${nm_fantasia}`;
            // //ALERT(localStorage.nm_fantasia);
          }

          //Fantasia
          nm_razao_social = localStorage.nm_razao_social;

          if (
            nm_parametro_api.indexOf("{nm_razao_social}") != -1 &&
            !nm_razao_social == ""
          ) {
            sParametro = sParametro + `/${nm_razao_social}`;
            ////ALERT('nm_razao_social');
          }

          //Data Base
          if (nm_parametro_api.indexOf("{dt_base}") != -1 && !dt_base == "") {
            sParametro = sParametro + `/${dt_base}`;
            //ALERT('DT_BASE' + dt_base);
          }

          //Documento/Identificação
          if (
            nm_parametro_api.indexOf("{cd_identificacao}") != -1 &&
            !cd_identificacao == ""
          ) {
            sParametro = sParametro + `/${cd_identificacao}`;
            //ALERT('CD_IDENTIFICACAO: ' + cd_identificacao);
          }

          ////ALERT(nm_documento);

          if (
            nm_parametro_api.indexOf("{nm_documento}") != -1 &&
            !nm_documento == ""
          ) {
            sParametro = sParametro + `/${nm_documento}`;
            ////ALERT('nm_razao_social');
          }

          if (
            nm_parametro_api.indexOf("{cd_empresa_usuario}") != -1 &&
            !cd_empresa_usuario == 0
          ) {
            sParametro = sParametro + `/${cd_empresa_usuario}`;
            // //ALERT(localStorage.nm_fantasia);
          }

          if (
            nm_parametro_api.indexOf("{cd_tipo_filtro}") != -1 &&
            !cd_tipo_filtro == ""
          ) {
            sParametro = sParametro + `/${cd_tipo_filtro}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (
            nm_parametro_api.indexOf("{cd_documento}") != -1 &&
            !cd_documento == ""
          ) {
            sParametro = sParametro + `/${cd_documento}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          //Data Inicial
          if (
            nm_parametro_api.indexOf("{dt_inicial}") != -1 &&
            !dt_inicial == ""
          ) {
            sParametro = sParametro + `/${dt_inicial}`;
            ////ALERT('nm_razao_social');
          }

          //Data Inicial
          if (nm_parametro_api.indexOf("{dt_final}") != -1 && !dt_final == "") {
            sParametro = sParametro + `/${dt_final}`;
            ////ALERT('nm_razao_social');
          }

          //Json - Objecto
          if (nm_parametro_api.indexOf("{nm_json}") != -1 && !nm_json == "") {
            sParametro = sParametro + `/${nm_json}`;
            ////ALERT('nm_razao_social');
          }

          //Pesquisa
          if (
            nm_parametro_api.indexOf("{nm_pesquisa}") != -1 &&
            !nm_pesquisa == ""
          ) {
            sParametro = sParametro + `/${nm_pesquisa}`;
            ////ALERT('nm_razao_social');
          }

          //CD_CNPJ
          if (nm_parametro_api.indexOf("{cd_cnpj}") != -1 && !cd_cnpj == "") {
            sParametro = sParametro + `/${cd_cnpj}`;
            ////ALERT(cd_cnpj);
          }

          //CD_CNPJ_CPF
          if (
            nm_parametro_api.indexOf("{cd_cnpj_cpf}") != -1 &&
            !cd_cnpj_cpf == ""
          ) {
            sParametro = sParametro + `/${cd_cnpj_cpf}`;
            ////ALERT(cd_cnpj);
          }

          if (nm_parametro_api.indexOf("{cd_cep}") != -1 && !cd_cep == "") {
            sParametro = sParametro + `/${cd_cep}`;
            ////ALERT(cd_cnpj);
          }

          if (
            nm_parametro_api.indexOf("{cd_filtro}") != -1 &&
            !cd_filtro == ""
          ) {
            sParametro = sParametro + `/${cd_filtro}`;
            // //ALERT(cd_filtro);
          }

          if (
            nm_parametro_api.indexOf("{vl_contrato}") != -1 &&
            !vl_contrato == ""
          ) {
            sParametro = sParametro + `/${vl_contrato}`;
            ////ALERT(vl_contrato);
          }

          if (
            nm_parametro_api.indexOf("{qt_apontamento}") != -1 &&
            !qt_apontamento == ""
          ) {
            sParametro = sParametro + `/${qt_apontamento}`;
            //alert(qt_apontamento);
          }
          //PROCESSO
          if (
            nm_parametro_api.indexOf("{cd_processo}") != -1 &&
            !cd_processo == ""
          ) {
            sParametro = sParametro + `/${cd_processo}`;
          }

          if (
            nm_parametro_api.indexOf("{dt_processo}") != -1 &&
            !dt_processo == ""
          ) {
            sParametro = sParametro + `/${dt_processo}`;
          }

          if (
            nm_parametro_api.indexOf("{cd_movimento}") != -1 &&
            !cd_movimento == ""
          ) {
            sParametro = sParametro + `/${cd_movimento}`;
          }

          if (
            nm_parametro_api.indexOf("{cd_entregador}") != -1 &&
            !cd_entregador == ""
          ) {
            sParametro = sParametro + `/${cd_entregador}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (
            nm_parametro_api.indexOf("{cd_item_documento}") != -1 &&
            !cd_item_documento == ""
          ) {
            sParametro = sParametro + `/${cd_item_documento}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (
            nm_parametro_api.indexOf("{cd_tipo_documento}") != -1 &&
            !cd_tipo_documento == ""
          ) {
            sParametro = sParametro + `/${cd_tipo_documento}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (nm_parametro_api.indexOf("{cd_etapa}") != -1 && !cd_etapa == "") {
            sParametro = sParametro + `/${cd_etapa}`;
          }

          if (
            nm_parametro_api.indexOf("{cd_etapa_origem}") != -1 &&
            !cd_etapa_origem == ""
          ) {
            sParametro = sParametro + `/${cd_etapa_origem}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }
          if (
            nm_parametro_api.indexOf("{cd_etapa_destino}") != -1 &&
            !cd_etapa_destino == ""
          ) {
            sParametro = sParametro + `/${cd_etapa_destino}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }
          //Empresa Faturamento
          if (
            nm_parametro_api.indexOf("{cd_empresa_fat}") != -1 &&
            !cd_empresa_fat == 0
          ) {
            sParametro = sParametro + `/${cd_empresa_fat}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (nm_parametro_api.indexOf("{qt_ordem}") != -1 && !qt_ordem == "") {
            sParametro = sParametro + `/${qt_ordem}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (
            nm_parametro_api.indexOf("{cd_tipo_parametro}") != -1 &&
            !cd_tipo_parametro == ""
          ) {
            sParametro = sParametro + `/${cd_tipo_parametro}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (
            nm_parametro_api.indexOf("{cd_tipo_email}") != -1 &&
            !cd_tipo_email == ""
          ) {
            sParametro = sParametro + `/${cd_tipo_email}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (
            nm_parametro_api.indexOf("{cd_contato}") != -1 &&
            !cd_contato == ""
          ) {
            sParametro = sParametro + `/${cd_contato}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (
            nm_parametro_api.indexOf("{ds_parametro}") != -1 &&
            !ds_parametro == ""
          ) {
            sParametro = sParametro + `/${ds_parametro}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (
            nm_parametro_api.indexOf("{cd_relatorio}") != -1 &&
            !cd_relatorio == ""
          ) {
            sParametro = sParametro + `/${cd_relatorio}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (nm_parametro_api.indexOf("{cd_form}") != -1 && !cd_form == "") {
            sParametro = sParametro + `/${cd_form}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (
            nm_parametro_api.indexOf("{cd_comanda}") != -1 &&
            !cd_comanda == ""
          ) {
            sParametro = sParametro + `/${cd_comanda}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (
            nm_parametro_api.indexOf("{cd_vendedor}") != -1 &&
            !cd_vendedor == ""
          ) {
            sParametro = sParametro + `/${cd_vendedor}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (nm_parametro_api.indexOf("{ds_xml}") != -1 && !ds_xml == "") {
            sParametro = sParametro + `/${ds_xml}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (
            nm_parametro_api.indexOf("{cd_tabela_preco}") != -1 &&
            !cd_tabela_preco == ""
          ) {
            sParametro = sParametro + `/${cd_tabela_preco}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          if (nm_parametro_api.indexOf("{cd_ano}") != -1 && !cd_ano == "") {
            sParametro = sParametro + `/${cd_ano}`;
            //ALERT('CD_TIPO_FILTRO: ' + cd_tipo_filtro);
          }

          //alert(sParametro);
          //console.log(sParametro, 'S PARAMETRO')
          if (sParametro.includes("undefined")) {
            //return null;
            console.warn("Parâmetro inválido detectado:", sParametro);
            return [];
          }

          //ccf - 27.10.2025
          //
          //return await http.get(sParametro).then((resposta) => resposta.data);
          //

          // Chamada principal
          const resposta = await http.get(sParametro);

          if (resposta?.data?.statusCode === 500 || resposta?.data?.error) {
            console.error("Erro interno detectado na API:", resposta.data);
            return [];
          }

          return resposta.data;
        } catch (err) {
      // Se o erro for lançado diretamente pelo Axios
      if (err.response?.status === 500) {
        console.error(
          "Erro 500 capturado via Axios:",
          err.response?.data || err.message
        );
        return [];
      }

      console.error("Erro na chamada principal:", err);

      if (store._mutations.SET_Usuario.ic_multi_servidor === "S") {
        for (const client of [httpEgisApp, httpEgismob]) {
          try {
            const resposta = await client.get(sParametro);
            if (resposta?.data?.statusCode === 500 || resposta?.data?.error) {
              console.error("Erro interno detectado:", resposta.data);
              continue;
            }
            return resposta.data;
          } catch (error) {
            console.error("Erro no fallback:", error);
          }
        }
      }

      return [];
      /*
      console.error('erro ' + err);
      if (store._mutations.SET_Usuario.ic_multi_servidor === 'S') {
        try {
          return await httpEgisApp.get(sParametro).then((resposta) => resposta.data);
        } catch (error) {
          console.error('erro ' + error);
          return await httpEgismob.get(sParametro).then((resposta) => resposta.data);
        }
      }
      */
    }
  },
};
