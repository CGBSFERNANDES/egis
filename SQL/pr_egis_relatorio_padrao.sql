IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_padrao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_padrao

GO

--use egissql_27433725
-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_padrao
-------------------------------------------------------------------------------
--pr_egis_relatorio_padrao
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        20243
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 24.08.2024
--Alteração        : 
-- use egissql_360
-- vendedor , data 
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_padrao
@json nvarchar(max) = '' 

--with encryption


as

set @json = isnull(@json,'')

declare @cd_empresa             int = 0
declare @cd_modulo              int = 0
declare @cd_menu                int = 0
declare @cd_processo            int = 0
declare @cd_item_processo       int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
declare @cd_item_documento      int = 0
declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @cd_relatorio           int = 0
declare @cd_relatorio_form      int = 0
declare @jsonParam              nvarchar(max) = '' 

--Dados do Relatório---------------------------------------------------------------------------------

     declare
            @titulo                     varchar(200),
		    @logo                       varchar(400),			
			@nm_cor_empresa             varchar(20),
			@nm_endereco_empresa  	    varchar(200) = '',
			@cd_telefone_empresa    	varchar(200) = '',
			@nm_email_internet		    varchar(200) = '',
			@nm_cidade				    varchar(200) = '',
			@sg_estado				    varchar(10)	 = '',
			@nm_fantasia_empresa	    varchar(200) = '',
			@numero					    int = 0,
			@dt_pedido				    varchar(60) = '',
			@cd_cep_empresa			    varchar(20) = '',
			@cd_cliente				    int = 0,
			@nm_fantasia_cliente  	    varchar(200) = '',
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_razao_social_cliente	varchar(200) = '',
			@nm_endereco_cliente		varchar(200) = '',
			@nm_bairro					varchar(200) = '',
			@nm_cidade_cliente			varchar(200) = '',
			@sg_estado_cliente			varchar(5)	= '',
			@cd_numero_endereco			varchar(20) = '',
			@cd_telefone				varchar(20) = '',
			@nm_condicao_pagamento		varchar(100) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40)   = '',
			@footerTitle				varchar(200)  = '',
			@vl_total_ipi				float         = 0,
			@sg_tabela_preco            char(10)      = '',
			@cd_empresa_faturamento     int           = 0,
			@nm_fantasia_faturamento    varchar(30)   = '',
			@cd_tipo_pedido             int           = 0,
			@nm_tipo_pedido             varchar(30)   = '',
			@cd_vendedor                int           = 0,
			@nm_fantasia_vendedor       varchar(30)   = '',
			@nm_telefone_vendedor       varchar(30)   = '',
			@nm_email_vendedor          varchar(300)  = '',
			@nm_contato_cliente			varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = '',
			@nm_status					varchar(100) = '',
			@ic_empresa_faturamento		char(1) = ''
					   
--------------------------------------------------------------------------------------------------------

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
set @cd_parametro      = 0
set @cd_modulo         = 0
set @cd_empresa        = dbo.fn_empresa()
--set @cd_menu           = 0
set @cd_processo       = 0
set @cd_item_processo  = 0
set @cd_form           = 0
set @cd_documento      = 0
set @cd_item_documento = 0
set @dt_usuario        = GETDATE()
------------------------------------------------------------------------------------------------------

select                     

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]                                      as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

-------------------------------------------------------------------------------------------------

--select * from #json

-------------------------------------------------------------------------------------------------
          
select @cd_modulo              = valor from #json where campo = 'cd_modulo'             
select @cd_processo            = valor from #json where campo = 'cd_processo'             
select @cd_item_processo       = valor from #json where campo = 'cd_item_processo'             
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @cd_documento           = valor from #json where campo = 'cd_documento_form'
select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'
select @cd_relatorio_form      = valor from #json where campo = 'cd_relatorio_form'
select @cd_parametro           = valor from #json where campo = 'cd_parametro'
select @cd_form                = valor from #json where campo = 'cd_form'
select @cd_menu                = valor from #json where campo = 'cd_menu'

set @cd_documento = isnull(@cd_documento,0)

if @cd_documento = 0
begin

  select @cd_documento           = valor from #json where campo = 'cd_documento'
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'

end

if isnull(@cd_relatorio_form,0)>0
   set @cd_relatorio = @cd_relatorio_form

--select * from egisadmin.dbo.relatorio order by cd_relatorio desc

--Crítica de Lançamento Contábil------------------------------------------------------------------------------------------
if @cd_relatorio = 407
begin 
	exec pr_egis_relatorio_critica_lancamento @cd_relatorio,@json
	return
end


--Solicitação Beneficimaneto------------------------------------------------------------------------------------------

if @cd_relatorio = 401
begin 
	exec pr_egis_relatorio_movimento_caixa_dinamico @cd_relatorio,@json
	return
end

--Solicitação Beneficimaneto------------------------------------------------------------------------------------------

if @cd_relatorio = 400
begin 
	exec pr_egis_relatorio_solicitacao_beneficiamento @cd_relatorio,@json
	return
end


--Movimento Caixa Etapa------------------------------------------------------------------------------------------

if @cd_relatorio = 399
begin 
	exec pr_egis_relatorio_movimento_caixa_etapa @cd_relatorio,@json
	return
end


--Composição Movimento Caixa------------------------------------------------------------------------------------------

if @cd_relatorio = 398
begin 
	exec pr_egis_relatorio_composicao_movimento_caixa @cd_relatorio,@cd_parametro,@json
	return
end


--Movimento Caixa------------------------------------------------------------------------------------------

if @cd_relatorio = 397
begin 
	exec pr_egis_relatorio_movimento_caixa @cd_relatorio,@json
	return
end


--Fechamento Caixa------------------------------------------------------------------------------------------

if @cd_relatorio = 396
begin 
	exec pr_egis_relatorio_fechamento_caixa_etapa @cd_relatorio,@cd_parametro,@json
	return
end


--Registro de Usuario------------------------------------------------------------------------------------------

if @cd_relatorio = 395
begin 
	exec pr_egis_relatorio_registro_suporte @cd_relatorio,@json
	return
end


--Retirada------------------------------------------------------------------------------------------

if @cd_relatorio = 394
begin 
	exec pr_egis_relatorio_retirada_caixa_etapa @cd_relatorio,@cd_parametro,@json
	return
end


--Minuta Despacho------------------------------------------------------------------------------------------

if @cd_relatorio = 393
begin 
	exec pr_egis_relatorio_ordem_expedicao @cd_relatorio,@cd_parametro,@json
	return
end

--Comissão do Motorista------------------------------------------------------------------------------------------

if @cd_relatorio = 392
begin 
	exec pr_egis_relatorio_comissao_motorista @json
	return
end

--Frete------------------------------------------------------------------------------------------

if @cd_relatorio = 391
begin 
	exec pr_egis_relatorio_frete_motorista @json
	return
end

--Viagens------------------------------------------------------------------------------------------

if @cd_relatorio = 390
begin 
	exec pr_egis_relatorio_viagem_motorista @json
	return
end

--Minuta Despacho------------------------------------------------------------------------------------------

if @cd_relatorio = 389
begin 
	exec pr_egis_relatorio_minuta_despacho @cd_relatorio,@cd_parametro,@json
	return
end

--Retirada Caixa-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 388
begin
  exec pr_egis_relatorio_retirada_caixa @cd_relatorio,@cd_parametro,@json
  return
end 

--Fechamento Caixa-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 387
begin
  exec pr_egis_relatorio_fechamento_caixa @cd_relatorio,@cd_parametro,@json
  return
end 

--Abertura Caixa-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 386
begin
  exec pr_egis_relatorio_abertura_caixa @cd_relatorio,@cd_parametro,@json
  return
end 


--Documentos Aguardando aprovação-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 385
begin
  exec pr_egis_relatorio_pedidos_aguardando_aprovacao @cd_relatorio,@cd_parametro,@json
  return
end 


--Documentos Declinados-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 384
begin
  exec pr_egis_relatorio_documento_declinado @cd_relatorio,@cd_parametro,@json
  return
end 


--Documentos Aprovados-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 383
begin
  exec pr_egis_relatorio_documento_aprovado @cd_relatorio,@cd_parametro,@json
  return
end 

--Demonstrativo de Resultado Financeiro-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 382
begin
  exec pr_egis_relatorio_demonstrativo_resultado_financeiro @cd_relatorio,@cd_parametro,@json
  return
end   
--Negociacao Proposta-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 381
begin
  exec pr_egis_relatorio_negociacao_proposta @cd_relatorio,@json
  return
end
--Ordem Produção-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 379
begin
  exec pr_egis_relatorio_ordem_producao @cd_relatorio,@cd_parametro,@json
  return
end
--Documento a receber-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 378
begin
  exec pr_egis_relatorio_cfop_tributacao @cd_relatorio,@cd_parametro,@json
  return
end
--Documento a receber-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 377
begin
  exec pr_egis_relatorio_documento_receber @cd_relatorio,@cd_parametro,@json
  return
end

--Ordem de Embarque Periodo Vendedor-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 376
begin
  exec pr_egis_relatorio_ordem_embarque_vendedor_periodo @cd_relatorio,@cd_parametro,@json
  return
end

--Fluxo de Caixa------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 375
begin
  exec pr_egis_relatorio_fluxo_caixa @cd_relatorio,@cd_parametro,@json
  return
end

--Plano Financeiro------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 374
begin
  exec pr_egis_relatorio_posicao_financeira @cd_relatorio,@cd_parametro,@json
  return
end
--Entregas não efetuadas------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 373
begin
  exec pr_egis_relatorio_departamento_documento @cd_relatorio,@cd_parametro,@json
  return
end

--Entregas não efetuadas------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 372
begin
  exec pr_egis_relatorio_entregas_nao_efetuadas_faturamento @cd_relatorio,@json
  return
end

--Entregas efetuadas ------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 371
begin
  exec pr_egis_relatorio_entregas_efetuadas_faturamento @cd_relatorio,@json
  return
end

--Familia Produo------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 370
begin
  exec pr_egis_relatorio_cliente_familia_produtos @cd_relatorio,@cd_usuario,@json
  return
end

--Dados por Entregadores------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 368
begin
  exec pr_egis_relatorio_dados_por_entregadores @cd_relatorio,@json
  return
end

--Dados por Veículo-------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 367
begin
  exec pr_egis_relatorio_servico_veiculo @cd_relatorio,@json
  return
end

--Dados por Veículo-------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 366
begin
  exec pr_egis_relatorio_dados_por_veiculo @cd_relatorio,@json
  return
end

--Veículo-------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 365
begin
  exec pr_egis_relatorio_dados_veiculo @cd_relatorio,@json
  return
end

--Analise de habilitação de motorista-------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 364
begin
  exec pr_egis_relatorio_analise_habilitacao_motorista @cd_relatorio,@json
  return
end
--Agenda de Entrega-------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 361
begin
  exec pr_egis_relatorio_agenda_entrega @json
  return
end
-- Faturamento Mensal Serviço Produto-----------------------------------------------------------------------------------------------------------------------------------------------
if @cd_relatorio = 356
begin
  exec pr_egis_relatorio_entrega_ph_cloro @cd_relatorio,@cd_parametro,@json
  return
end
-- Faturamento Mensal Serviço Produto-----------------------------------------------------------------------------------------------------------------------------------------------
if @cd_relatorio = 355
begin
  exec pr_egis_relatorio_faturamento_base_retirada @cd_relatorio,@cd_parametro,@json
  return
end
-- Diario Entregas-----------------------------------------------------------------------------------------------------------------------------------------------
if @cd_relatorio = 354
begin
  exec pr_egis_relatorio_diario_entrega @cd_relatorio,@cd_parametro,@json
  return
end
-- Faturamento Mensal Serviço Produto-----------------------------------------------------------------------------------------------------------------------------------------------
if @cd_relatorio = 353
begin
  exec pr_egis_relatorio_faturamento_servico_produto @cd_relatorio,@cd_parametro,@json
  return
end
-- Faturamento Mensal Cliente-----------------------------------------------------------------------------------------------------------------------------------------------
if @cd_relatorio = 352
begin
  exec pr_egis_relatorio_faturamento_mensal_cliente @cd_relatorio,@cd_parametro,@json
  return
end
-- Faturamento Mensal Veiculo-----------------------------------------------------------------------------------------------------------------------------------------------
if @cd_relatorio = 351
begin
  exec pr_egis_relatorio_faturamento_mensal_entregador @cd_relatorio,@cd_parametro,@json
  return
end
   
-- Faturamento Mensal Veiculo-----------------------------------------------------------------------------------------------------------------------------------------------
if @cd_relatorio = 350
begin
  exec pr_egis_relatorio_faturamento_mensal_veiculo @cd_relatorio,@cd_parametro,@json
  return
end
   
-- Ranking de Entregas por Produtos e Serviços-----------------------------------------------------------------------------------------------------------------------------------------------
if @cd_relatorio = 347
begin
  exec pr_egis_relatorio_ranking_entrega_servico_produto @cd_relatorio,@cd_parametro,@json
  return
end
   
-- Ranking de Entregas por Clientes-----------------------------------------------------------------------------------------------------------------------------------------------
if @cd_relatorio = 346
begin
  exec pr_egis_relatorio_ranking_entrega_cliente @cd_relatorio,@cd_parametro,@json
  return
end
   
-- Ranking de Entregas por Entregador-----------------------------------------------------------------------------------------------------------------------------------------------

if @cd_relatorio = 345
begin
  exec pr_egis_relatorio_ranking_entrega_entregador @cd_relatorio,@cd_parametro,@json
  return
end

-- Ranking de Entregas por Veiculo-----------------------------------------------------------------------------------------------------------------------------------------------
if @cd_relatorio = 344
begin
  exec pr_egis_relatorio_ranking_entrega_veiculo @cd_relatorio,@cd_parametro,@json
  return
end
   
--Deslocamento em Km Mensal-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 343
begin
  exec pr_egis_relatorio_deslocamento_mensal @cd_relatorio,@cd_usuario,@cd_parametro,@json
  return
end
   
--Deslocamento em Km por Veículo no Período-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 342
begin
  exec pr_egis_relatorio_deslocamento_periodo_veiculo @cd_relatorio,@cd_usuario,@cd_parametro,@json
  return
end
   
--Documentos Pagar em Aberto e Pagos-----------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 340
begin
  exec pr_egis_relatorio_consulta_doc_pago_aberto @cd_relatorio,@json
  return
end
   
--Pedido Compra modelo 01-------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 339
begin
  exec pr_egis_relatorio_pedido_compra_modelo_01 @cd_relatorio, @json
  return
end
--Contrato a Pagar-------------------------------------------------------------------------------------------------------------------------------   
if @cd_relatorio = 338
begin
  exec pr_egis_relatorio_contrato_pagar @cd_relatorio, @json
  return
end

---------------------------------------------------------------------------------------------------------------------------------

if @cd_relatorio = 337
begin
  exec pr_egis_relatorio_faturamento_mensal_assistencia_tecnica @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end

---------------------------------------------------------------------------------------------------------------------------------
if @cd_relatorio = 336
begin
  exec pr_egis_relatorio_analise_assistencia_tecnica @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return											   
end													 
---------------------------------------------------------------------------------------------------------------------------------
--Validação de Proposta Comercial - frmSACFechamento
---------------------------------------------------------------------------------------------------------------------------------

if @cd_relatorio = 335
begin
  exec pr_egis_relatorio_validacao_proposta @json
  return
end

---------------------------------------------------------------------------------------------------------------------------------
--Titulos em Aberto---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--Contas a receber - frmDocumentoReceber

if @cd_relatorio = 334
begin
  exec pr_egismob_relatorio_titulo_aberto @json
  return
end

--Comissão dos Vendedores--------------------------------------------------------------------

if @cd_relatorio = 237
begin
   exec pr_egis_relatorio_comissao_vendedor @cd_relatorio, @cd_parametro, @json
   return

end
--Comissão por metodos de calculo--------------------------------------------------------------------

if @cd_relatorio = 239
begin
   exec pr_egis_relatorio_comissao_metodo_vendedor @cd_relatorio, @cd_parametro, @json
   return

end
--Comissão Calculo Vendedor--------------------------------------------------------------------

if @cd_relatorio = 240
begin
   exec pr_egis_relatorio_comissa_demonstrativo @cd_relatorio, @cd_parametro, @json
   return

end
--Consulta Cliente por Vendedor--------------------------------------------------------------------

if @cd_relatorio = 243
begin
   exec pr_egis_relatorio_consulta_cliente_vendedor @cd_relatorio, @cd_parametro, @json
   return

end
--Consulta Cliente por Vendedor--------------------------------------------------------------------

if @cd_relatorio = 296
begin
   exec pr_egismob_relatorio_pedido_vendedor @cd_relatorio, @cd_parametro, @json
   return

end


--Ordem de Serviço Saida--------------------------------------------------------------------

if @cd_relatorio = 145
begin 
	
declare @cd_modelo_ordem_servico int = 0

select top 1
  @cd_modelo_ordem_servico = ISNULL(cd_modelo_ordem_servico,1)
from
  Config_Ordem_Servico

  if @cd_modelo_ordem_servico = 2 
  begin
      exec pr_egis_relatorio_ordem_servico_saida @cd_relatorio,@json
   return
  end
  else
  begin
     exec pr_egismob_relatorio_ordem_servico @json, @cd_documento
   return
  end
   

end


--Ordem de Serviço Saida--------------------------------------------------------------------

if @cd_relatorio = 245
begin
   exec pr_egis_relatorio_ordem_servico_saida @cd_relatorio,@json
   return

end

--Ordem de Serviço Saida--------------------------------------------------------------------

if @cd_relatorio = 246
begin
   exec pr_relatorio_ordem_servico_periodo @cd_relatorio,@json
   return

end

--Metas e Obejtivos--------------------------------------------------------------------

if @cd_relatorio = 248
begin
   exec pr_relatorio_meta_objetivo @cd_relatorio, @json
   return

end
--Solicitacao_compras--------------------------------------------------------------------

if @cd_relatorio = 249
begin
   exec pr_relatorio_solicitacao_compra @cd_relatorio, @json
   return

end
--Solicitacao_compras--------------------------------------------------------------------

if @cd_relatorio = 250
begin
   exec pr_relatorio_cotacao_compras @cd_relatorio,@json
   return

end
--Solicitacao_compras--------------------------------------------------------------------

if @cd_relatorio = 251
begin
   exec pr_egis_relatorio_faturamento_classificacao @cd_relatorio,@cd_parametro,@json
   return

end
--Pedido Cliente--------------------------------------------------------------------

if @cd_relatorio = 252
begin
   exec pr_relatorio_pedido_cliente @cd_relatorio,@cd_parametro,@json
   return

end
--Documentos Pagos--------------------------------------------------------------------

if @cd_relatorio = 254
begin
   exec pr_egis_relatorio_documento_pagos @cd_relatorio,@cd_parametro,@json
   return

end

--Documentos Pagos Hoje--------------------------------------------------------------------

if @cd_relatorio = 253
begin
   exec pr_egis_relatorio_documento_pagos_hoje @cd_relatorio,@cd_parametro,@json
   return

end

--Documentos Aberto--------------------------------------------------------------------

if @cd_relatorio = 255
begin
   exec pr_egis_relatorio_documentos_aberto @cd_relatorio,@cd_parametro,@json
   return

end
--Documentos Atraso--------------------------------------------------------------------

if @cd_relatorio = 256
begin
   exec pr_egis_relatorio_documentos_atraso @cd_relatorio,@cd_parametro,@json
   return

end
--Mapa de Ativos por Cliente e Geral--------------------------------------------------------------------

if @cd_relatorio = 257
begin
   exec pr_egis_relatorio_mapa_ativo_cliente_geral @cd_relatorio,@cd_parametro,@json
   return

end

--Pedido Aguardando Logistico--------------------------------------------------------------------

if @cd_relatorio = 258
begin
   exec pr_relatorio_pedido_aguardando_logistica @cd_relatorio,@cd_parametro,@json
   return

end

--Tributo Mensais--------------------------------------------------------------------

if @cd_relatorio = 259
begin
   exec pr_relatorio_tributo_mensal @cd_relatorio,@cd_parametro,@json
   return

end
--Listas NCM Estado Imposto--------------------------------------------------------------------

if @cd_relatorio = 260
begin
   exec pr_egis_relatorio_lista_ncm_estado_imposto @cd_relatorio,@cd_parametro,@json
   return

end
--Listas CFOP Saídas--------------------------------------------------------------------

if @cd_relatorio = 261
begin
   exec pr_egis_relatorio_lista_cfop_saida @cd_relatorio,@cd_parametro,@json
   return

end
--Listas CFOP Saídas--------------------------------------------------------------------

if @cd_relatorio = 262
begin
   exec pr_egis_relatorio_lista_cfop_entrada @cd_relatorio,@cd_parametro,@json
   return

end
--Grupo de Usuario Empresa--------------------------------------------------------------------

if @cd_relatorio = 263
begin
   exec pr_egis_relatorio_grupo_usuario_empresa @cd_relatorio,@cd_parametro,@json
   return

end
--Ordem de Serviço--------------------------------------------------------------------

if @cd_relatorio = 264
begin
   exec pr_egis_relatorio_ordem_separacao @cd_relatorio,@cd_parametro,@json
   return

end
--Adiantamento De Fornecedor --------------------------------------------------------------------

if @cd_relatorio = 265
begin
   exec pr_egis_relatorio_adiantamento_fornecedor @cd_relatorio,@cd_parametro,@json
   return

end
--RANKING De Fornecedor -------------------------------------------------------------------- 

if @cd_relatorio = 266
begin
   exec pr_egis_relatorio_ranking_fornecedor @cd_relatorio,@cd_parametro,@json
   return

end

--Ranking de Produto Comprado -------------------------------------------------------------------- 

if @cd_relatorio = 267
begin
   exec pr_egis_relatorio_ranking_produto_comprado @cd_relatorio,@cd_parametro,@json
   return

end

--Diario de Compras -------------------------------------------------------------------- 

if @cd_relatorio = 268
begin
   exec pr_egis_relatorio_resumo_diario_compras @cd_relatorio,@cd_parametro,@json
   return

end
--Mapa Entrega por Pedido -------------------------------------------------------------------- 

if @cd_relatorio = 269
begin
   exec pr_egis_relatorio_mapa_entrega_pedido @cd_relatorio,@cd_parametro,@json
   return

end

--Mapa Analitico por Pedido -------------------------------------------------------------------- 

if @cd_relatorio = 270
begin
   exec pr_egis_relatorio_mapa_analitico_item_pedido @cd_relatorio,@cd_parametro,@json
   return

end
--Mapa Compra Orçamento -------------------------------------------------------------------- 

if @cd_relatorio = 271
begin
   exec pr_egis_relatorio_mapa_orcamento_compras @cd_relatorio,@cd_parametro,@json
   return

end
--Mapa Compra Anual -------------------------------------------------------------------- 

if @cd_relatorio = 272
begin
   exec pr_egis_relatorio_mapa_compras_anual @cd_relatorio,@cd_parametro,@json
   return

end
--Mapa Compra Desembolso Caixa -------------------------------------------------------------------- 

if @cd_relatorio = 274
begin
   exec pr_egis_relatorio_mapa_compra_desembolso_caixa @cd_relatorio,@cd_parametro,@json
   return

end
--Mapa Compra Pedidos Departamentoa ---------------------------------------------------------------

if @cd_relatorio = 275
begin
   exec pr_egis_relatorio_pedidos_compra_departamento @cd_relatorio,@cd_parametro,@json
   return

end

--Mapa Compra Pedidos Aplicação --------------------------------------------------------------------  

if @cd_relatorio = 276
begin
   exec pr_egis_relatorio_pedidos_compra_aplicacao @cd_relatorio,@cd_parametro,@json
   return

end
--Historico de Ativos -------------------------------------------------------------------- 

if @cd_relatorio = 277
begin
   exec pr_egis_relatorio_historico_ativos @cd_relatorio,@json
   return

end
--Proposta Diario --------------------------------------------------------------------  

if @cd_relatorio = 278
begin
   exec pr_relatorio_diario_proposta @cd_relatorio,@cd_parametro,@json
   return

end
--Pedidos de Venda com Quantidade Liberada --------------------------------------------------------------------  

if @cd_relatorio = 279
begin
   exec pr_egis_relatorio_pedido_venda_quantidade_liberada @cd_relatorio,@cd_parametro,@json
   return

end


--Análise de Vendas de Produto por Período --------------------------------------------------------------------  

if @cd_relatorio = 280
begin
   exec pr_egis_relatorio_pedido_geral @cd_relatorio,@cd_parametro,@json
   return

end
--Diário de Venda--------------------------------------------------------------------  

if @cd_relatorio = 281
begin
   exec pr_egis_relatorio_diario_vendas @cd_relatorio,@cd_parametro,@json
   return

end
--Ordem de Embarque--------------------------------------------------------------------  

if @cd_relatorio = 282
begin
   exec pr_egis_relatorio_ordem_embarque @cd_relatorio,@cd_parametro,@json
   return

end
--Diário de Comodato--------------------------------------------------------------------  

if @cd_relatorio = 283
begin
   exec pr_egis_relatorio_diario_comodato @cd_relatorio,@cd_parametro,@json
   return

end
--Diário de Bonificação--------------------------------------------------------------------  

if @cd_relatorio = 284
begin
   exec pr_egis_relatorio_diario_bonificacao @cd_relatorio,@cd_parametro,@json
   return

end
--Diário de Bonificação--------------------------------------------------------------------  

if @cd_relatorio = 285
begin
   exec pr_egis_relatorio_romaneio_embarque_nota @cd_relatorio,@cd_parametro,@json
   return

end
--Diário de Bonificação--------------------------------------------------------------------  

if @cd_relatorio = 286
begin
   exec pr_egis_relatorio_mapa_carteira_pedido @cd_relatorio,@cd_parametro,@json
   return

end
--Romaneio fechamento caixa--------------------------------------------------------------------  

if @cd_relatorio = 287
begin
   exec pr_egis_relatorio_romaneio_fechamento_caixa @cd_relatorio,@cd_parametro,@json
   return

end
--Positivação de Produtos por Clientes--------------------------------------------------------------------  

if @cd_relatorio = 288
begin
   exec pr_egis_relatorio_consulta_positivacao_produto @cd_relatorio,@cd_parametro,@json
   return

end
--Visitas--------------------------------------------------------------------  

if @cd_relatorio = 289
begin
   exec pr_egis_relatorio_visita_checkin @cd_relatorio,@cd_parametro,@json
   return

end
--Pauta de Impostos x Produto--------------------------------------------------------------------  

if @cd_relatorio = 290
begin
   exec pr_egis_relatorio_pauta_imposto_produto @cd_relatorio,@cd_parametro,@json
   return

end
--Pedidos Cancelados--------------------------------------------------------------------  

if @cd_relatorio = 291
begin
   exec pr_egis_relatorio_pedido_cancelado @cd_relatorio,@cd_parametro,@json
   return

end

--Pedidos Cancelados--------------------------------------------------------------------  

if @cd_relatorio = 292
begin
   exec pr_egis_relatorio_pedido_itens_cancelado @cd_relatorio,@cd_parametro,@json
   return

end
--Pedidos de Importação--------------------------------------------------------------------  

if @cd_relatorio = 293
begin
   exec pr_egis_relatorio_pedido_importacao @cd_relatorio,@cd_parametro,@json
   return

end
--Inoice--------------------------------------------------------------------   
if @cd_relatorio = 294
begin
   exec pr_egis_relatorio_invoice @cd_relatorio,@cd_parametro,@json
   return

end

--Inoice--------------------------------------------------------------------   

if @cd_relatorio = 295
begin
   exec pr_egis_relatorio_di @cd_relatorio,@cd_parametro,@json
   return

end
--Ordem de servico liberação Tecnica--------------------------------------------------------------------   

if @cd_relatorio = 297
begin
   exec pr_relatorio_ordem_servico_liberada_area_tecnica @cd_relatorio,@json
   return

end
--Tecnica(Ordem de Serviço)--------------------------------------------------------------------   

if @cd_relatorio = 298
begin
   exec pr_egis_relatorio_tecnico @cd_relatorio,@json
   return

end
--Garantia (Ordem de Serviço)--------------------------------------------------------------------   

if @cd_relatorio = 299
begin
   exec pr_egis_relatorio_termo_garantia @cd_relatorio,@json
   return

end
----------------------------------------------------------------------   

if @cd_relatorio = 300
begin
   exec pr_egis_relatorio_orcamento_ordem_servico @cd_relatorio,@json
   return

end
----------------------------------------------------------------------   

if @cd_relatorio = 301
begin
   exec pr_egis_relatorio_demonstrativo_estoque_carteira_vendedor @cd_relatorio,@cd_parametro,@json
   return

end
--Recibo(Ordem servico)----------------------------------------------------------------------   

if @cd_relatorio = 303
begin
   exec pr_egis_relatorio_recibo_ordem_servico @cd_relatorio,@json
   return

end
--Entrada e saida (ordem_servico)---------------------------------------------------------------------   

if @cd_relatorio = 304
begin
   exec pr_relatorio_entrada_saida_ordem_servico @cd_relatorio,@cd_parametro,@json
   return

end
--Historico Movimento---------------------------------------------------------------------   

if @cd_relatorio = 305
begin
   exec pr_egis_relatorio_veloe_historico_movimento @cd_relatorio,@cd_parametro,@json
   return

end
--Anual---------------------------------------------------------------------   

if @cd_relatorio = 306
begin
   exec pr_egis_relatorio_veloe_consumo_anual @cd_relatorio,@cd_parametro,@json
   return

end
--Visita---------------------------------------------------------------------   

if @cd_relatorio = 307
begin
   exec pr_egis_relatorio_roteiro_visita @cd_relatorio,@json
   return

end
--Pedido cliente produto---------------------------------------------------------------------   

if @cd_relatorio = 308
begin
   exec pr_egis_relatorio_pedido_cliente_produto @cd_relatorio,@cd_parametro,@json
   return

end
--Entregas de Romaneio por Período---------------------------------------------------------------------   

if @cd_relatorio = 310
begin
   exec pr_egis_relatorio_entrega_romaneio_pedido @cd_relatorio,@cd_parametro,@json
   return

end
--Consumo anual Veloe---------------------------------------------------------------------   

if @cd_relatorio = 311
begin
   exec pr_egis_relatorio_veloe_consumo_anual @cd_relatorio,@cd_parametro,@json
   return

end
--Consumo Mensal Veloe---------------------------------------------------------------------   

if @cd_relatorio = 312
begin
   exec pr_egis_relatorio_veloe_consumo_mensal @cd_relatorio,@cd_parametro,@json
   return

end
--Consumo Placa Veloe---------------------------------------------------------------------   

if @cd_relatorio = 313
begin
   exec pr_egis_relatorio_veloe_placa @cd_relatorio,@cd_parametro,@json
   return

end
--Consumo Combustivel Veloe---------------------------------------------------------------------   

if @cd_relatorio = 314
begin
   exec pr_egis_relatorio_veloe_combustivel @cd_relatorio,@cd_parametro,@json
   return

end
--Consumo Motorista Veloe---------------------------------------------------------------------   

if @cd_relatorio = 315
begin
   exec pr_egis_relatorio_veloe_motorista @cd_relatorio,@cd_parametro,@json
   return

end
--Consumo Fornecedor Veloe---------------------------------------------------------------------   

if @cd_relatorio = 316
begin
   exec pr_egis_relatorio_veloe_fornecedor @cd_relatorio,@cd_parametro,@json
   return

end
--Consumo Cidade Veloe---------------------------------------------------------------------   

if @cd_relatorio = 317
begin
   exec pr_egis_relatorio_veloe_cidade @cd_relatorio,@cd_parametro,@json
   return

end
--Clientes sem Posivação---------------------------------------------------------------------   

if @cd_relatorio = 318
begin
   exec pr_egis_relatorio_cliente_sem_positivacao @cd_relatorio,@cd_parametro,@json
   return

end
--Posivação por Periodo---------------------------------------------------------------------   

if @cd_relatorio = 319
begin
   exec pr_egis_relatorio_positivacao_periodo @cd_relatorio,@cd_parametro,@json
   return

end
--Demonstrativo de Atendimento por Vendedor---------------------------------------------------------------------   

if @cd_relatorio = 322	
begin
   exec pr_egis_relatorio_demonstrativo_atendimento_vendedor @cd_relatorio,@cd_parametro,@json
   return

end
--Demonstrativo de Atendimento por Vendedor---------------------------------------------------------------------   

if @cd_relatorio = 323	
begin
   exec pr_relatorio_pagamento_ordem_servico_periodo @cd_relatorio,@json
   return

end
--Pedido Entrega---------------------------------------------------------------------   

if @cd_relatorio = 324	
begin
   exec pr_egis_relatorio_pedido_entregue @cd_relatorio,@json
   return
end
--Romaneio de Embarque Manifesto---------------------------------------------------------------------   

if @cd_relatorio = 325	
begin
   exec pr_egis_relatorio_ordem_embarque_manifesto @cd_relatorio,@cd_parametro,@json
   return

end
--Ordem de Embarque Manifesto---------------------------------------------------------------------   

if @cd_relatorio = 326	
begin
   exec pr_egis_relatorio_romaneio_embarque_nota_manifesto @cd_relatorio,@cd_parametro,@json 
   return

end
--Base de Pedidos para Comissão no Período ---------------------------------------------------------------------   

if @cd_relatorio = 327
begin
   exec pr_egis_relatorio_base_pedidos_comissao_periodo @cd_relatorio,@cd_parametro,@json 
   return

end
--Pedidos em Aberto por Vendedor ---------------------------------------------------------------------   

if @cd_relatorio = 328
begin
   exec pr_egis_relatorio_pedido_aberto_vendedor @cd_relatorio,@cd_parametro,@json 
   return

end
--Ordem de Embarque divisão---------------------------------------------------------------------   

if @cd_relatorio = 329
begin
   exec pr_egis_relatorio_ordem_embarque_divisao @cd_relatorio,@cd_parametro,@json 
   return

end
--Romaneio de Embarque Divisão---------------------------------------------------------------------   

if @cd_relatorio = 330
begin
   exec pr_egis_relatorio_romaneio_embarque_nota_divisao @cd_relatorio,@cd_parametro,@json 
   return

end
--Fechamento de Caixa por Divisao---------------------------------------------------------------------   

if @cd_relatorio = 331
begin
   exec pr_egis_relatorio_romaneio_fechamento_caixa_divisao @cd_relatorio,@cd_parametro,@json 
   return

end
--Manifesto--------------------------------------------------------------------   

if @cd_relatorio = 332
begin
   exec pr_egis_relatorio_manifesto @cd_relatorio,@cd_parametro,@json 
   return

end
--Manifesto--------------------------------------------------------------------   

if @cd_relatorio = 333
begin
   exec pr_egis_relatorio_ordem_servico_garantia @cd_relatorio,@json 
   return

end
--Preparação de Carga------------------------------------------------------------------------- 

if @cd_relatorio = 16
begin
   
   if @cd_empresa = 342 --Zero Grau
   begin
     exec pr_egis_relatorio_preparacao_carga_categoria @cd_relatorio, @cd_documento, @cd_parametro, @json
   end
   else
   begin
     exec pr_egis_relatorio_preparacao_carga @cd_relatorio, @cd_documento, @cd_parametro, @json
   end

   return

end
--Preparação de Carga--------------------------------------------------------------------

if @cd_relatorio = 235
begin
   exec pr_egis_relatorio_carga @cd_relatorio, @cd_documento,@json
   return

end

--Nota Fiscal Cliente-----------------------------------------------------------

if @cd_relatorio = 228
begin
   exec pr_relatorio_nota_fiscal_cliente @cd_relatorio,@cd_documento,@cd_parametro,@json
   return

end

--Tabela de Preço lookup-----------------------------------------------------------

if @cd_relatorio = 223
begin
   exec pr_relatorio_tabela_preco_lookup @cd_relatorio,@json
   return

end

--Produtos sem saldo-----------------------------------------------------------

if @cd_relatorio = 222
begin
   exec pr_relatorio_produto_sem_saldo_tabela_preco @cd_relatorio,''
   return

end

--Produtos com preço zerado-----------------------------------------------------------

if @cd_relatorio = 221
begin
   exec pr_relatorio_produto_preco_zero_tabela_preco @cd_relatorio,''
   return

end

--Produtos em Tabelas-----------------------------------------------------------

if @cd_relatorio = 220
begin
   exec pr_relatorio_produto_tabela_preco_bloqueado_cliente @cd_relatorio,''
   return

end

--Bloqueio de Produtos-----------------------------------------------------------

if @cd_relatorio = 219
begin
   exec pr_relatorio_bloqueio_produto_comercial @cd_relatorio,''
   return

end

--Produto configuração-----------------------------------------------------------

if @cd_relatorio = 218
begin
   exec pr_relatorio_consulta_fiscal_produto @cd_relatorio,''
   return

end

--Categoria de Produto-----------------------------------------------------------

if @cd_relatorio = 217
begin
   exec pr_relatorio_categoria_produto @cd_relatorio,''
   return

end

--Clientes em Atraso-----------------------------------------------------------

if @cd_relatorio = 216
begin
   exec pr_relatorio_clientes_atraso @cd_relatorio,@cd_usuario
   return

end


-- Consulta Positivação de Clientes

if @cd_relatorio = 214
begin
  exec pr_relatorio_consulta_positivacao_cliente @cd_relatorio, @json
  return
end

-- Certificado de Qualidade Nota Fiscal

if @cd_relatorio = 212
begin
  exec pr_relatorio_certificado_qualidade_nota_fiscal @cd_relatorio,@cd_usuario, @cd_parametro, @cd_documento
  return
end

-- Certificado de Qualidade (Produção)

if @cd_relatorio = 209
begin
  exec pr_egis_relatorio_certificado_qualidade @cd_relatorio,@cd_usuario, @cd_parametro, @cd_documento,@json
  return
end

--pagar por plano financeiro-------------------------------------------

if @cd_modulo in (359) and @cd_relatorio = 199
begin
  exec pr_egis_relatorio_recebimento_periodo @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end

--pagar por plano financeiro-------------------------------------------

if @cd_modulo in (234) and @cd_relatorio = 198
begin
  exec pr_egis_relatorio_pagar_plano_financeiro @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end

--base de clientes-------------------------------------------

if @cd_relatorio = 197
begin
  exec pr_egis_relatorio_base_clientes_vendedor @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end



--------------------------------------------------------------------------------------------
--Acordo Comercial
--------------------------------------------------------------------------------------------

if @cd_modulo in (233) and @cd_relatorio = 194
begin
  exec pr_egis_relatorio_planejamento_compra @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end



--------------------------------------------------------------------------------------------
--Acordo Comercial
--------------------------------------------------------------------------------------------

if @cd_modulo in (357) and @cd_relatorio = 193
begin
  exec pr_egis_relatorio_faturamento_grupo_parceria_comercial @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end

--------------------------------------------------------------------------------------------
--Posição de Contas a Receber - Pedido de Venda
--------------------------------------------------------------------------------------------

if @cd_relatorio = 189
begin
  
   set @jsonParam = '[{"cd_menu": 5428, "cd_parametro": 14, "cd_pedido_venda": '+cast(@cd_documento as varchar(80))+', "cd_usuario": '+cast(@cd_usuario as varchar(80))+'}]'
  exec pr_egismob_relatorio_pedido @jsonParam
  return
end

--------------------------------------------------------------------------------------------
--Posição de Contas a Receber
--------------------------------------------------------------------------------------------

if @cd_modulo in (235) and @cd_relatorio = 188
begin
  exec pr_egis_relatorio_posicao_contas_receber_portador @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end


--------------------------------------------------------------------------------------------
--Análise do Contas a Receber
--------------------------------------------------------------------------------------------

if @cd_modulo in (235) and @cd_relatorio = 187
begin
  exec pr_egis_relatorio_analise_contas_receber @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end


--------------------------------------------------------------------------------------------
--Boleto Bancário
--------------------------------------------------------------------------------------------

if @cd_relatorio = 186
begin
  exec pr_egis_relatorio_boleto_bancario @cd_relatorio,@cd_usuario, @cd_parametro, '', 'N', @cd_documento
  return
end

--------------------------------------------------------------------------------------------
--Saldo de Fornecedores a Pagar
------------------------------------------------------------------------------------------
--

if @cd_modulo in (234) and @cd_relatorio = 185
begin
  exec pr_egis_relatorio_saldo_fornecedor @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end

--------------------------------------------------------------------------------------------
--Retirada de Item Comodato
--------------------------------------------------------------------------------------------

if @cd_relatorio = 195
begin
  exec pr_egis_relatorio_retirada_contrato_comodato @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end

--------------------------------------------------------------------------------------------
--trocas
--------------------------------------------------------------------------------------------

if @cd_relatorio = 196
begin
  exec pr_egis_relatorio_analise_trocas @cd_relatorio,@cd_usuario, @cd_parametro,@json
  return
end

--------------------------------------------------------------------------------------------
--Bonificações
--------------------------------------------------------------------------------------------

if @cd_relatorio = 183
begin
  exec pr_egis_relatorio_analise_bonificacoes @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end

--Pedidos de Compra--------------------------------------------

if @cd_relatorio = 134
begin
  exec pr_egis_relatorio_pedido_compra @cd_relatorio,@cd_usuario, @cd_parametro, @json
  return
end

--------------------------------------------------------------------------------------------
--Contrato de Comodator
--------------------------------------------------------------------------------------------

if @cd_relatorio = 182
begin
  if @cd_empresa = 358
  begin   
     exec pr_egis_relatorio_contrato_comodato_Yeez @cd_relatorio,@cd_usuario, @cd_documento, @cd_parametro, @json
	 return
  end
  
  if @cd_empresa = 329
  begin   
     exec pr_egis_relatorio_contrato_comodato_cisneros @cd_relatorio,@cd_usuario, @cd_documento, @cd_parametro, @json
	 return
  end

  
  if @cd_empresa = 289
  begin   
     exec pr_egis_relatorio_contrato_comodato_congelart @cd_relatorio,@cd_usuario, @cd_documento, @cd_parametro, @json
	 return
  end

  if @cd_empresa = 326
  begin   
     exec pr_egis_relatorio_contrato_comodato_milkmoni @cd_relatorio,@cd_usuario, @cd_documento, @cd_parametro, @json
	 return
  end

  if @cd_empresa = 274
  begin   
     exec pr_egis_relatorio_contrato_comodato_gustamais @cd_relatorio,@cd_usuario, @cd_documento, @cd_parametro, @json
	 return
  end
  
  if @cd_empresa = 342
  begin   
     exec pr_egis_relatorio_contrato_comodato_zerograu @cd_relatorio,@cd_usuario, @cd_documento, @cd_parametro, @json
	 return
  end

  if @cd_empresa in (354,363) 
  begin   
     exec pr_egis_relatorio_contrato_comodato_acaiPareaki @cd_relatorio,@cd_usuario, @cd_documento, @cd_parametro, @json
	 return
  end

  if @cd_empresa = 317
  begin  
     exec pr_egis_relatorio_contrato_comodato_pimpinela @cd_relatorio, @cd_usuario, @cd_parametro, @json
	 return
  end
  --exec pr_egis_relatorio_contrato_comodato @cd_relatorio,@cd_usuario, @cd_parametro, @json
  return

end

--Entrada de Produtos--------------------------------------------

if @cd_modulo in (244) and @cd_relatorio = 181
begin
  exec pr_egis_relatorio_entrada_produtos_estoque @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end

--Entrada de Pedidos--------------------------------------------

if @cd_relatorio = 180
begin
  exec pr_egis_relatorio_entrada_pedidos_vendedor @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end

--Carteira de Clientes--------------------------------------------

if @cd_relatorio = 179
begin
  exec pr_egis_relatorio_carteira_clientes @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end

--Faturamento mensal--------------------------------------------

if @cd_relatorio = 178
begin
  exec pr_egis_relatorio_faturamento_mensal @cd_relatorio,@cd_usuario, @cd_parametro, @json
  return
end

--Faturamento Anual--------------------------------------------

if @cd_relatorio = 177
begin
  exec pr_egis_relatorio_faturamento_anual @cd_relatorio,@cd_usuario, @cd_parametro, ''
  return
end

--Análise de Expansão da Base de Clientes--------------------------------------------

if @cd_relatorio = 176
begin
  exec pr_egis_relatorio_analise_expansao_cliente @cd_relatorio,@cd_usuario, @cd_parametro, @json
  return
end

--Boletim de Faturamento--------------------------------------------

if @cd_relatorio = 175
begin
  exec pr_egis_relatorio_boletim_faturamento @cd_relatorio,@json
  return
end

--Pedidos de Venda por Vendedor--------------------------------------------

if @cd_relatorio = 167
begin
  exec pr_egismob_relatorio_pedidos_venda_vendedor @cd_relatorio,@cd_usuario, @cd_parametro,@json
  return
end


--Pedido de Venda--------------------------------------------

if @cd_modulo in (223) and @cd_relatorio = 166
begin
  exec pr_egismob_relatorio_pedido_venda @cd_relatorio,@cd_usuario, @json
  return
end


--Diário de Pedidos--------------------------------------------

if @cd_modulo in (223) and @cd_relatorio = 165
begin
  exec pr_egis_relatorio_diario_pedidos @cd_relatorio,@cd_usuario, ''
  return
end


--Fatuamento por Nota Fiscal --

if @cd_relatorio = 164
begin
  exec pr_egis_relatorio_faturamento_nota_fiscal @cd_relatorio,@cd_usuario,@dt_inicial,@dt_final,''
  return
end



--Tabela de Preços---

if @cd_relatorio = 65
begin
  exec pr_egis_relatorio_tabela_preco @cd_relatorio,@cd_parametro,@json
  return
end



--Pauta de Impostos---

if @cd_modulo = 249 and @cd_relatorio = 62
begin
  exec pr_egis_relatorio_pauta_impostos @cd_relatorio,''
  return
end



--Faturamento por Empresa---

if @cd_modulo = 357 and @cd_relatorio = 142
begin
  exec pr_egis_relatorio_faturamento_empresa @cd_relatorio,@cd_usuario, @json
  return
end

--Faturamento por Vendedor e Empresa

if @cd_relatorio = 61
begin
  exec pr_egis_relatorio_faturamento_familia_produtos @cd_relatorio,@cd_usuario,@json
  return
end


--Análise de Ruptura

if @cd_modulo in (241,244) and @cd_relatorio = 40
begin
  exec pr_egis_relatorio_falta_estoque_produto @cd_relatorio,''
  return
end


--Inventário por Categoria de Produtos-----

if @cd_modulo = 244 and @cd_relatorio = 39
begin
  exec pr_egis_relatorio_inventario_produto @cd_relatorio,''
  return
end


--Carteira de Pedidos---

if @cd_relatorio = 38
begin
  exec pr_egis_relatorio_carteira_pedidos @cd_relatorio,''
  return
end

--Faturamento por Vendedor e Empresa

if @cd_modulo = 357 and @cd_relatorio = 22
begin
  exec pr_egis_relatorio_vendedor_empresa @cd_relatorio,@json
  return
end


if @cd_modulo = 357 and @cd_relatorio = 21
begin
  exec pr_egis_relatorio_gestao_comercial @cd_relatorio,''
  return
end


--if @cd_modulo = 241 and @cd_relatorio = 19
--begin
--   exec pr_egis_relatorio_faturamento_diario @cd_relatorio,''
--   return

--end

--Faturamento Diário---

if @cd_modulo = 241 and @cd_relatorio = 19
begin
   exec pr_egis_relatorio_faturamento_diario @cd_relatorio,''
   return

end

--Diário de Ordem de Separação-----------------------------------------------------------

if @cd_relatorio = 20
begin
   exec pr_egis_relatorio_diario_ordem_separacao @cd_relatorio,@cd_parametro,@json
   return

end

--Atendimento ao Consumidor--------------------------------------------------------------

if @cd_modulo = 237 and @cd_relatorio = 225
begin
   exec pr_relatorio_atendimento_consumidor @cd_relatorio,@cd_documento,''
   return

end

--Cliente x Tabela Preço-----------------------------------------------------------

if @cd_modulo = 249 and @cd_relatorio = 227
begin
   exec pr_relatorio_cliente_tabela_preco @cd_relatorio,@cd_documento,@json
   return

end

--Comodato Periodo-----------------------------------------------------------

if @cd_relatorio = 229
begin
	
   exec pr_relatorio_comodato_periodo @cd_relatorio,@cd_parametro,@json
   return

end

--Proposta em Aberto-----------------------------------------------------------

if @cd_relatorio = 230
begin
   exec pr_relatorio_proposta_aberto @cd_relatorio,@cd_parametro,@json
   return

end

--Pedido em Aberto-----------------------------------------------------------

if @cd_relatorio = 231
begin
   exec pr_relatorio_pedido_aberto @cd_relatorio,@cd_parametro,@json
   return

end

--Pedidos Por Vendedor-----------------------------------------------------------

if @cd_relatorio = 232
begin
	
   exec pr_relatorio_pedido_vendedor @cd_relatorio,@cd_documento,@cd_parametro,@json
   return

end

--Clientes  x Conta Bancaria -----------------------------------------------------------

if @cd_modulo = 235 and @cd_relatorio = 233
begin
	
   exec pr_relatorio_cliente_conta_bancaria @cd_relatorio,@cd_documento,@json
   return

end

--Pedidos por Grupo de Clientes -----------------------------------------------------------

if @cd_relatorio = 234
begin
	
   exec pr_relatorio_pedido_grupo_cliente @cd_relatorio,@cd_documento,@cd_parametro,@json
   return

end

----------------------------------
--------------------------------------------------------------------------------------------
--Posição de Contas a Receber - Prosposta
--------------------------------------------------------------------------------------------

if @cd_relatorio = 11
begin
   set @jsonParam = '[{"cd_menu": 5428, "cd_parametro": 14, "cd_consulta": '+cast(@cd_documento as varchar(80))+', "cd_usuario": '+cast(@cd_usuario as varchar(80))+'}]'
  exec pr_egismob_relatorio_pedido @jsonParam
  return
end



-------------------------------------------------------------------------------------------------
declare @ic_processo char(1) = 'N'


select
  @titulo      = isnull(nm_relatorio,''),
  @ic_processo = isnull(ic_processo_relatorio, 'N')
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio

----------------------------------------------------------------------------------------------------------------------------



--update egisadmin.dbo.relatorio set ic_processo_relatorio = 'N'
 

if @ic_processo='S' and @cd_relatorio = 9999 and @cd_documento > 0--usuar o número do relatório do cadastro
begin

   exec pr_modulo_processo_egismob_post '[{"cd_consulta": 237, "cd_menu": 5428, "cd_parametro": 14, "cd_pedido_venda": 0, "cd_usuario": 4073}]'
   return

end

--18.01.2025-------------------------------------------------

--Busca o Relatório do cadastro do menu

if @cd_menu>0
begin
  select   
    @cd_relatorio = ISNULL(m.cd_relatorio,0),
	@cd_form      = isnull( (select top 1 f.cd_form from egisadmin.dbo.form f where f.cd_menu = m.cd_menu ), 0 )
  from
    EGISADMIN.dbo.Menu m
	
  where
    m.cd_menu = @cd_menu
	and
	ISNULL(m.cd_relatorio,0)>0

end

--select @cd_menu
--select @cd_form

 --select @cd_processo as cd_processo, @json as jsonT into JsonProcesso
  --select * from JsonProcesso
  --drop table JsonProcesso

-----------------------------------------------------------------------------------------
set @cd_ano           = year(@dt_hoje)    
set @cd_dia           = day(@dt_hoje)
set @cd_mes           = month(@dt_hoje)

if @dt_inicial is null  or @dt_inicial = '01/01/1900'    
begin      
      
  set @cd_ano = year(@dt_hoje)      
  set @cd_mes = month(@dt_hoje)      
      
  set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)      
  set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano)      
      
end   

-----------------------------------------------------------------------------------------

--Empresa
----------------------------------
set @cd_empresa = dbo.fn_empresa()
-----------------------------------

	--Dados da empresa-----------------------------------------------------------

	select 
		@logo = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),
		@nm_cor_empresa			= isnull(e.nm_cor_empresa,'#1976D2'),
		@nm_endereco_empresa	= isnull(e.nm_endereco_empresa,''),
		@cd_telefone_empresa	= isnull(e.cd_telefone_empresa,''),
		@nm_email_internet		= isnull(e.nm_email_internet,''),
		@nm_cidade				= isnull(c.nm_cidade,''),
		@sg_estado				= isnull(es.sg_estado,''),
		@nm_fantasia_empresa	= isnull(e.nm_fantasia_empresa,''),
		@cd_cep_empresa			= isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),
		@cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),
		@nm_pais					= ltrim(rtrim(isnull(p.sg_pais,''))),
		@cd_cnpj_empresa			= dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),
		@cd_inscestadual_empresa	=  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),
		@nm_dominio_internet		=  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))



	from egisadmin.dbo.empresa e	with(nolock)
	left outer join Estado es		with(nolock) on es.cd_estado = e.cd_estado
	left outer join Cidade c		with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado
	left outer join Pais p			with(nolock) on p.cd_pais = e.cd_pais
	where 
		cd_empresa = @cd_empresa


---------------------------------------------------------------------------------------------------------------------------------------------
--Dados do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------

declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabeçalho da Empresa
declare @html_titulo     nvarchar(max) = '' --Título
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe
declare @html_rodape     nvarchar(max) = '' --Rodape

declare @data_hora_atual nvarchar(50)  = ''

set @html         = ''
set @html_empresa = ''
set @html_titulo  = ''
set @html_cab_det = ''
set @html_detalhe = ''
set @html_rod_det = ''
set @html_rodape  = ''

-- Obtém a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
-----------------------------------------------------------------------------------------------------
declare @cd_grupo_usuario int = 0

select 
    @cd_grupo_usuario = gur.cd_grupo_usuario
 from 
    egisadmin.dbo.usuario_grupousuario ugu   with(nolock) 
	inner join egisadmin.dbo.grupo_usuario_relatorio gur with(nolock) on gur.cd_modulo = @cd_modulo 
	                                                                 and gur.cd_grupo_usuario = ugu.cd_grupo_usuario 
 where
	ugu.cd_usuario = @cd_usuario

--------------------------------------------------
if @cd_parametro = 10 --Lookup de Relatórios
begin
  --select * from egisadmin.dbo.Menu_Relatorio
  if isnull(@cd_menu,0) <> 0
  begin
	select 
       mr.cd_menu_relatorio,
       mr.cd_modulo,
	   mr.cd_menu,
       mr.cd_relatorio,
       m.nm_modulo,
       r.nm_relatorio,
       r.nm_titulo_relatorio,
       r.ds_relatorio,
       r.cd_form,
       r.nm_icone_relatorio,
       r.ic_grafico,
       r.ic_grid_relatorio,
       pr.cd_parametro_relatorio,
       pr.cd_usuario
	from
	  egisadmin.dbo.Menu_Relatorio mr with(nolock)
      inner join egisadmin.dbo.modulo m                         with(nolock) on m.cd_modulo      = mr.cd_modulo
      inner join egisadmin.dbo.relatorio r                      with(nolock) on r.cd_relatorio   = mr.cd_relatorio
	  left outer join Parametro_Relatorio pr                    with(nolock) on pr.cd_relatorio  = mr.cd_relatorio and pr.cd_usuario = @cd_usuario
	  left outer join egisadmin.dbo.grupo_usuario_relatorio gur with(nolock) on gur.cd_modulo    = mr.cd_modulo 
	                                                                      and gur.cd_relatorio = pr.cd_relatorio
	  																	  and gur.cd_grupo_usuario = isnull(@cd_grupo_usuario,0)
    where
      mr.cd_menu = @cd_menu

	 return
  end
  -------------------
  select 
   mr.cd_modulo_relatorio,
   mr.cd_modulo,
   mr.cd_relatorio,
   mr.qt_ordem_relatorio,
   mr.ic_ativo_grafico_modulo,
   m.nm_modulo,
   r.nm_relatorio,
   r.nm_titulo_relatorio,
   r.ds_relatorio,
   r.cd_form,
   r.nm_icone_relatorio,
   r.ic_grafico,
   r.ic_grid_relatorio,
   pr.cd_parametro_relatorio,
   pr.cd_usuario
  
  from 
    egisadmin.dbo.modulo_relatorio mr                         with(nolock) --select * from egisadmin.dbo.modulo_relatorio
    inner join egisadmin.dbo.modulo m                         with(nolock) on m.cd_modulo      = mr.cd_modulo
    inner join egisadmin.dbo.relatorio r                      with(nolock) on r.cd_relatorio   = mr.cd_relatorio
	left outer join Parametro_Relatorio pr                    with(nolock) on pr.cd_relatorio  = mr.cd_relatorio and pr.cd_usuario = @cd_usuario
	left outer join egisadmin.dbo.grupo_usuario_relatorio gur with(nolock) on gur.cd_modulo    = mr.cd_modulo 
	                                                                      and gur.cd_relatorio = pr.cd_relatorio
																		  and gur.cd_grupo_usuario = isnull(@cd_grupo_usuario,0)
  where
    isnull(mr.ic_ativo_modulo_relatorio,'N') = 'S'
	and
    mr.cd_modulo = @cd_modulo
	
  order by
	 mr.qt_ordem_relatorio

  return

end

if @cd_relatorio=0
begin
  select  'Parâmetro de Cadastro de Relatório não definido !!' as Msg, 0 as Cod
  return
end

------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------
--Título do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio


--select @titulo
--

--------------------------------------------------------------------------------------------
--Dados do Form Especial para Geração do Relatório Padrão----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

select 
  top 1
  @titulo = ISNULL(nm_form,'')
from
  EGISADMIN.dbo.Form f 
where
  f.cd_form = @cd_form

--------------------------------------------------------------------------------------------



-----------------------
--Cabeçalho da Empresa----------------------------------------------------------------------------------------------------------------------
-----------------------

SET @html_empresa = '
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title >'+@titulo+'</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            color: #333;
        }
        h2 {
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 5px;
           
        }
        th {
            background-color: #f2f2f2;
            color: #333;
			 text-align: center;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .header {
            padding: 5px;
            text-align: center;
        }
        .section-title {
            background-color: '+@nm_cor_empresa+';
            color: white;
            padding: 5px;
            margin-bottom: 10px;
			border-radius:5px;
        }
       
        img {
            max-width: 250px;
			margin-right:10px;
        }
        .company-info {
            text-align: right;
            margin-bottom: 10px;
        }
        .proposal-info {
            text-align: left;
            margin-bottom: 10px;
        }
        .title { 
            color: '+@nm_cor_empresa+';
        }
        .report-date-time {
            text-align: right;
            margin-bottom: 5px;
			margin-top:50px;
        }
		p {
			margin:5px;
			padding:0;
		}

	   .tamanho {
            font-size: 95%;
            text-align: center;
        }

    </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:30%; margin-right:20px">
			<img src="'+@logo+'" alt="Logo da Empresa">
		</div>
		<div style="width:70%; padding-left:10px">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
		    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
		</div>    
    </div>'

--select @html_empresa

		

--Detalhe--
--Procedure de Cada Relatório-------------------------------------------------------------------------------------

select a.*, g.nm_grupo_relatorio 
into 
  #RelAtributo 
from
  egisadmin.dbo.Relatorio_Atributo a 
  left outer join egisadmin.dbo.relatorio_grupo g on g.cd_grupo_relatorio = a.cd_grupo_relatorio  
where 
  a.cd_relatorio = @cd_relatorio
order by
  qt_ordem_atributo

declare @cd_item_relatorio  int           = 0
declare @nm_cab_atributo    varchar(100)  = ''
declare @nm_dados_cab_det   nvarchar(max) = ''
declare @nm_grupo_relatorio varchar(60)   = ''


--select * from egisadmin.dbo.relatorio_grupo

select * into #AuxRelAtributo from #RelAtributo

while exists ( select top 1 cd_item_relatorio from #AuxRelAtributo )
begin

  select top 1 
    @cd_item_relatorio  = cd_item_relatorio,
	@nm_cab_atributo    = nm_cab_atributo,
	@nm_grupo_relatorio = nm_grupo_relatorio
  from
    #AuxRelAtributo
  order by
    qt_ordem_atributo


  set @nm_dados_cab_det = @nm_dados_cab_det + '<th> '+ @nm_cab_atributo+'</th>'

  delete from #AuxRelAtributo
  where
    cd_item_relatorio = @cd_item_relatorio

end

--select @nm_dados_cab_det

--select * from #RelAtributo

--set @nm_dados_cab_det = @nm_dados_cab_det + '<th> '+ @nm_cab_atributo+'</th>'

set @html_cab_det = '<div class="section-title"><strong> '+@nm_grupo_relatorio + ' </strong></div> 
                     <table>
                     <tr>'
					 +
					 isnull(@nm_dados_cab_det,'')
                     + '</tr>'

--------------------------------------------------------------------------------------------------------------------------

set @html_detalhe = '' --valores da tabela


--montagem do Detalhe--
declare @qt_total_produto decimal(25,2) = 0

set @qt_total_produto = isnull(@qt_total_produto,0) 


  ---Dados do Form Especial----------------------------------------------------------------------------------------------------


select
  identity(int,1,1)                        as cd_controle,
  --------------------------------------------------------
  --f.*,
  f.cd_form,
  f.nm_form,
  tb.cd_tabela,
  tb.nm_tabela,


  --Atributo--

  a.cd_atributo,
  a.nm_atributo,
  fta.nm_tabsheet_atributo, 

  case when isnull(a.ic_atributo_obrigatorio,'N') = 'S' then
    case when isnull(fta.nm_tabsheet_atributo,'')<>'' and fta.nm_tabsheet_atributo<>a.nm_atributo_consulta then
      fta.nm_tabsheet_atributo+'*'
    else
      case when isnull(a.nm_atributo_consulta,'') <>'' then
	    isnull(a.nm_atributo_consulta,'')+'*' 
      else
	    isnull(a.nm_atributo,'')+'*'
	  end
    end  
  else
      case when isnull(fta.nm_tabsheet_atributo,'')<>'' and fta.nm_tabsheet_atributo<>a.nm_atributo_consulta then
      fta.nm_tabsheet_atributo
    else
      case when isnull(a.nm_atributo_consulta,'') <>'' then
	    isnull(a.nm_atributo_consulta,'') 
    else
	  isnull(a.nm_atributo,'') 
	end
    end end as nm_apresenta_atributo,  
    isnull(a.nm_mascara_atributo,'')        as nm_mascara_atributo,  
    isnull(a.ic_total_grid,'N')             as ic_total_grid,  
    isnull(a.ic_atributo_chave,'N')         as ic_chave_grid,  
    isnull(na.nm_natureza_atributo,'')      as nm_natureza_atributo,  
    isnull(na.nm_datatype,'')               as nm_datatype,  
    isnull(na.nm_formato,'')                as nm_formato,  
  
    case when na.cd_tipo_alinhamento = 1 then  
       'left'  
    else  
      case when na.cd_tipo_alinhamento = 2 then  
    'center'  
   else  
    'right'  
   end  
 end                                     as nm_tipo_alinhamento,  
 isnull(a.ic_contador_grid,'N')          as ic_contador_grid,  
 'N'                                     as ic_grafico_eixo_x,  
 'N'                                     as ic_grafico_eixo_y,  
 isnull(a.ic_mostra_grid,'S')            as ic_mostra_grid,  
 cast(0 as int)                          as cd_tipo_consulta,  
 isnull(a.ic_edita_cadastro,'N')         as ic_edita_cadastro,  
 isnull(a.ic_titulo_total_grid,'N')      as ic_titulo_total_grid,  
 isnull(a.ic_chave_estrangeira,'N')      as ic_chave_estrangeira,  
 isnull(a.ic_combo_box,'N')              as ic_combo_box,  
 isnull(a.ic_boolean,'N')                as ic_boolean,
 isnull(a.nm_campo_chave_combo_box,'')   as nm_campo_chave_combo_box,  
 isnull(a.nm_campo_mostra_combo_box,'')  as nm_campo_mostra_combo_box,  
 isnull(a.nm_tabela_combo_box,'')        as nm_tabela_combo_box,  
 isnull(a.nm_dado_padrao_atributo,'')    as nm_dado_padrao_atributo,  
 isnull(a.ic_data_padrao,'')             as ic_data_padrao,  
 isnull(a.ic_aliasadmin_combo_box,'N')   as ic_aliasadmin_combo_box,
 isnull(a.nm_atributo,'')                as nm_campo_chave_origem,
 cast(0 as int)                          as cd_atributo_banda,  
 cast('' as varchar(60))                 as nm_banda,  
 isnull(a.ic_doc_caminho_atributo,'N')   as ic_doc_caminho_atributo,  
 'N'                                     as ic_card
 ----------------------------------------------------------------------------------------------------------------
 

into 
  #AuxForm

from 
  egisadmin.dbo.form f
  left outer join egisadmin.dbo.form_tabsheet ft             on ft.cd_form      = f.cd_form --select * from form_tabsheet where cd_form = 53

  left outer join egisadmin.dbo.tabsheet ts                  on ts.cd_tabsheet  = ft.cd_tabsheet

  left outer join egisadmin.dbo.tabela tb                    on tb.cd_tabela    = ft.cd_tabela

  left outer join egisadmin.dbo.form_tabsheet_atributo fta   on fta.cd_form     = f.cd_form              and --select * from form_tabsheet_atributo where cd_form = 53
                                                                fta.cd_tabsheet = ft.cd_tabsheet         
                                                  --and fta.cd_tabela   = ft.cd_tabela 

  left outer join egisadmin.dbo.atributo a                  on  a.cd_tabela     = fta.cd_tabela          and
                                                  a.cd_atributo   = fta.cd_atributo

  left outer join egisadmin.dbo.Tabela tfta                 on tfta.cd_tabela   = fta.cd_tabela

  left outer join egisadmin.dbo.natureza_atributo na on na.cd_natureza_atributo = a.cd_natureza_atributo  
  left outer join egisadmin.dbo.Api Ap                             on ap.cd_api               = fta.cd_api  --select * from api_composicao where cd_api = 413
  left outer join egisadmin.dbo.API_Composicao ac                  on ac.cd_api               = ap.cd_api
  left outer join egisadmin.dbo.Tabela tabapi                      on tabapi.cd_tabela        = ap.cd_tabela
  left outer join egisadmin.dbo.Procedimento papi                  on papi.cd_procedimento    = ap.cd_procedimento
  left outer join egisadmin.dbo.Tabela tapi                        on tapi.cd_tabela          = fta.cd_tabela_api
  left outer join egisadmin.dbo.atributo aapi                      on  aapi.cd_tabela         = fta.cd_tabela_api          and
                                                                       aapi.cd_atributo       = fta.cd_atributo_api

  left outer join egisadmin.dbo.form_tabsheet_Grid g               on g.cd_form = f.cd_form

where
  f.cd_form = @cd_form 
  and
  isnull(a.cd_atributo,0)>0
  and
  ISNULL(fta.ic_relatorio,'S')='S'

--select * from   #AuxForm


declare @id        int
declare @nm_pedido nvarchar(max) = ''

--select * from #Detalhe

set @html_detalhe = ''

declare @cd_controle          int           = 0
declare @ic_chave_grid        char(1)       = ''
declare @chave                varchar(60)   = ''
declare @nm_atributo          varchar(200)  = ''
declare @nm_tabsheet_atributo varchar(200)  = ''
declare @sqlcolunas           nvarchar(max) = ''
declare @sqlComando           nvarchar(max) = ''
declare @sqlTabelas           nvarchar(max) = ''
declare @nm_banco             varchar(100)  = ''

  select    
    top 1 
    @nm_banco   = isnull(nm_banco_empresa,'')    
  from    
    egisadmin.dbo.empresa                
   where    
    cd_empresa = @cd_empresa    


while exists ( select cd_controle from #AuxForm )
begin

  select top 1
    @id                   = cd_controle,
    @cd_controle          = cd_controle,
	@nm_atributo          = nm_atributo,
	@sqlTabelas           = nm_tabela,
	@nm_tabsheet_atributo = nm_tabsheet_atributo,
	@ic_chave_grid        = ic_chave_grid,
	@chave                = case when ic_chave_grid = 'S' and @chave = '' then nm_atributo else @chave end    

  from
    #AuxForm


  order by
    cd_controle

  set @nm_dados_cab_det = @nm_dados_cab_det + '<th> '+ @nm_tabsheet_atributo+'</th>'

  --'<td>'+cast(sg_unidade_medida as varchar(5))+'</td>

  set @sqlColunas = @sqlColunas
                    + case when @sqlColunas <>'' then ', ' else cast('' as char(1)) end
    
                    +
                    --+'<td>'
					--
					'cast('
                    + 
					isnull(@nm_atributo,'')
                    +
					' as varchar(20))  as '+''''+@nm_atributo+''''
				--	+
					--'</td>'

   
	----@nm_pedido    = @nm_pedido  + ' ' + cast(cd_pedido_venda as varchar(15)),

 --   @html_detalhe = @html_detalhe + '
 --           <tr> 			
 --           <td>'+cast(qt_produto as varchar(20))+'</td>
	--		<td>'+cast(sg_unidade_medida as varchar(5))+'</td>
	--		<td>'+cast(cd_mascara_produto as varchar(30))+'</td>
	--		<td>'+cast(nm_separado as varchar(20))+'</td>	
	--		<td>'+cast(nm_produto as varchar(120))+'</td>			
	--		<td>'+cast(cd_codigo_barra_produto as varchar(20))+'</td>			
	--		<td>'+cast(nm_lote_produto as varchar(10))+'</td>			
	--		<td>'+cast(nm_grupo_localizacao + ' '+qt_posicao_localizacao as varchar(15))+'</td>			
 --           </tr>'
		  	  
 -- from
 --   #Detalhe

 	   

  delete from #AuxForm
  where
    cd_controle = @id


end

--select @sqlcolunas

declare @ParamDefinition    nvarchar(200) = ''

--Comando SQL--
set @sqlComando = 'select '+@sqlcolunas + ' from '+ @nm_banco+'.dbo.' + @sqlTabelas   

    --set @html_detalhe = 'select @sqlComando = (select '+ @sqlcolunas+' from '+@nm_banco+'.dbo.'+@sqlTabelas+' )'  
    
	set @ParamDefinition = N'@sqlComando nvarchar(max) OUTPUT';  

	 
	 
      -- EXEC sp_executesql @html_detalhe, @ParamDefinition, @sqlComando=@sqlComando OUTPUT 

	   --select @sqlComando
	   --set @html_detalhe = '<tr>'+@html_detalhe+'/<tr>'

	 --select @html_detalhe

--select @sqlComando
--select @sqlColunas

------------------------------------------------------------------------------------------------------
--EXEC sp_executesql @sqlComando
------------------------------------------------------------------------------------------------------


--Cabeçalho do Relatório Padrão-----------------------------------------------------------------------------------------
set @nm_grupo_relatorio = case when isnull(@nm_grupo_relatorio,'')='' then 'Dados' else @nm_grupo_relatorio end

set @html_cab_det = '<div class="section-title"><strong> '+@nm_grupo_relatorio + ' </strong></div> 
                     <table>
                     <tr>'
					 +
					 isnull(@nm_dados_cab_det,'')
                     + '</tr>'


					 --exec pr_api_dados_grid_form_especial 53

--   @html_detalhe = @html_detalhe + '
 --           <tr> 			
 --           <td>'+cast(qt_produto as varchar(20))+'</td>
	--		<td>'+cast(sg_unidade_medida as varchar(5))+'</td>

--select @html_cab_det

--Exec em SQl com Texto
--While---
--Campos do Html

set @nm_fantasia_cliente     = '' --'Resumo dos Pedidos de Vendas'
set @nm_razao_social_cliente = '' --@nm_pedido


set @html_titulo = '<div class="section-title"><strong>'+@titulo+'</strong></div>
                    <div style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">
					 <p><strong>'+isnull(@nm_fantasia_cliente,'')+'</strong></p>
					</div>
 	               <div style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">
	            	<p><strong>'+isnull(@nm_razao_social_cliente,'')+'</strong></p>	            	
	</div>'
	   	 
--------------------------------------------------------------------------------------------------------------------

--Criar uma tabela temporario com os Dados dos atributos


SET @html_rod_det = '</table>'

declare @html_totais nvarchar(max)=''
declare @titulo_total varchar(500)=''

set @titulo_total = ''
set @html_totais  = '<div class="section-title"><strong>'+@titulo_total+'</strong></div>
                    <div> 
                    <tr>' 
					+
					cast(@qt_total_produto as varchar(15))
					+
					'</tr>
					</div>'



set @footerTitle = ''

--Rodapé--

set @html_rodape =
    '<div class="company-info">
		<p><strong>'+@footerTitle+'</strong> ''</p>
	</div>
    <div class="section-title"><strong>Observações</strong></div>
    <p>'+@ds_relatorio+'</p>
	<div class="report-date-time">
       <p>Gerado em: '+@data_hora_atual+'</p>
    </div>'



--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +
	@html_cab_det +
    @html_detalhe +
	@html_rod_det +
	@html_totais  + 
    @html_rodape  

---------------------


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------
go

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------

--exec pr_egis_relatorio_padrao '[{
--    "cd_empresa": "317",
--    "cd_modulo": "241",
--    "cd_menu": "0",
--    "cd_relatorio_form": 182,
--    "cd_processo": "",
--    "cd_form": 34,
--    "cd_documento_form": 55,
--    "cd_parametro_form": "2",
--    "cd_usuario": "4255",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "4255",
--    "dt_usuario": "2025-01-17",
--    "cd_parametro_relatorio": "55",
--    "cd_relatorio": "182",
--    "cd_serie_nota_fiscal": 6,
--    "cd_identificacao_nota_saida": "150008",
--    "detalhe": [],
--    "lote": [],
--    "cd_documento": "55"
--}]
--'


--exec pr_egis_relatorio_padrao
--'[
--{
--    "cd_parametro": 1,
--    "cd_empresa": "329",
--    "cd_modulo": "241",
--    "cd_menu": "0",
--    "cd_relatorio_form": 231,
--    "cd_processo": "",
--    "cd_usuario": "4479"
--}
--]'

--exec pr_egis_relatorio_padrao '[{
--    "cd_empresa": "360",
--    "cd_modulo": "256",
--    "cd_menu": "0",
--    "cd_relatorio": 339,
--    "cd_processo": "",
--    "cd_item_processo": "",
--    "cd_documento_form": 1,
--    "cd_item_documento_form": "0",
--    "cd_parametro": "0",
--    "cd_usuario": "4915"
--}]'



--exec pr_egis_relatorio_padrao
--'[{
--    "cd_empresa": "360",
--    "cd_modulo": "252",
--    "cd_menu": "0",
--    "cd_relatorio": 396,
--    "cd_processo": "",
--    "cd_item_processo": "",
--    "cd_documento_form": 51,
--    "cd_item_documento_form": "0",
--    "cd_parametro": "0",
--    "cd_usuario": "4915"
--}]'

--use egissql_354
