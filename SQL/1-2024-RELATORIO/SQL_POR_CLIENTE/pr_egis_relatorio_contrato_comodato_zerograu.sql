IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_contrato_comodato_zerograu' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_contrato_comodato_zerograu

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_contrato_comodato_zerograu
-------------------------------------------------------------------------------
--pr_egis_relatorio_contrato_comodato_zerograu
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : João Pedro Marçal
--
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 24.08.2024
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_contrato_comodato_zerograu
@cd_relatorio      int   = 0,
@cd_usuario        int   = 0,
@cd_documento      int   = 0, 
@cd_parametro      int   = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')

declare @cd_empresa             int = 0
declare @cd_modulo              int = 0
declare @cd_menu                int = 0
declare @cd_processo            int = 0
declare @cd_item_processo       int = 0
declare @cd_form                int = 0
--declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
--declare @cd_documento           int = 0
declare @cd_item_documento      int = 0
--declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @cd_grupo_relatorio     int
declare @cd_controle            int



--declare @cd_relatorio           int = 0

--Dados do Relatório---------------------------------------------------------------------------------

     declare
			@ano_nota					varchar(15),
			@num_nota                   varchar(20),
		    @razaosocial_cliente        varchar(200),
			@razaosocial_cliente_rodape varchar(100),
			@dt_mes_ano					varchar(30),
			@valor_produto				varchar(50),
			@descricao_produto          varchar(400),
			@cep_cliente				varchar(20),
			@uf_cliente					varchar(5),
			@cidade_cliente				varchar(200),
			@bairro_cliente				varchar(200),
			@cnpj_cliente				varchar(30),	
	        @ender_cliente				varchar(200),
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
			@nm_fantasia_vendedor       varchar(500)   = '',
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
			@ic_empresa_faturamento		char(1) = '',
			@cd_nota_saida              int = 0 		   
--------------------------------------------------------------------------------------------------------


----------------------------------------------
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
--set @cd_parametro      = 0
set @cd_modulo         = 0
set @cd_empresa        = 0
set @cd_menu           = 0
set @cd_processo       = 0
set @cd_item_processo  = 0
set @cd_form           = 0
set @cd_item_documento = 0
set @dt_usuario        = GETDATE()
------------------------------------------------------------------------------------------------------

if @json<>''
begin
  select                     
    1                                                    as id_registro,
    IDENTITY(int,1,1)                                    as id,
    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
    valores.[value]              as valor                    
                    
    into #json                    
    from                
      openjson(@json)root                    
      cross apply openjson(root.value) as valores      

-------------------------------------------------------------------------------------------------

--select * from #json

-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_modulo              = valor from #json where campo = 'cd_modulo'             
  select @cd_processo            = valor from #json where campo = 'cd_processo'             
  select @cd_item_processo       = valor from #json where campo = 'cd_item_processo'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'
  select @cd_nota_saida          = valor from #json where campo = 'cd_identificacao_nota_saida'

  set @cd_nota_saida = ISNULL(@cd_nota_saida,0)

   if @cd_nota_saida = 0
   begin
     select @cd_nota_saida      = valor from #json where campo = 'cd_documento_form'

   end

end


-------------------------------------------------------------------------------------------------
declare @ic_processo char(1) = 'N'
 

select
  @titulo             = nm_relatorio,
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio

----------------------------------------------------------------------------------------------------------------------------

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
		@nm_cor_empresa		   	    = isnull(e.nm_cor_empresa,'#1976D2'),
		@nm_endereco_empresa 	    = isnull(e.nm_endereco_empresa,''),
		@cd_telefone_empresa	    = isnull(e.cd_telefone_empresa,''),
		@nm_email_internet	  	    = isnull(e.nm_email_internet,''),
		@nm_cidade			    	= isnull(c.nm_cidade,''),
		@sg_estado				    = isnull(es.sg_estado,''),
		@nm_fantasia_empresa	    = isnull(e.nm_fantasia_empresa,''),
		@cd_cep_empresa			    = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),
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
declare @html_grafico    nvarchar(max) = '' --Gráfico
declare @html_titulo     nvarchar(max) = '' --Título
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe
declare @html_rodape     nvarchar(max) = '' --Rodape
declare @html_totais     nvarchar(max) = '' --Totais
declare @html_geral      nvarchar(max) = '' --Geral

declare @titulo_total    varchar(500)  = ''

declare @data_hora_atual nvarchar(50)  = ''

set @html         = ''
set @html_empresa = ''
set @html_grafico = ''
set @html_titulo  = ''
set @html_cab_det = ''
set @html_detalhe = ''
set @html_rod_det = ''
set @html_rodape  = ''

-- Obtém a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------
--Título do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio


--select @titulo
--

-----------------------
--Cabeçalho da Empresa----------------------------------------------------------------------------------------------------------------------
-----------------------

SET @html_empresa = '
<html>
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
            max-width: 200px;
            margin-right: 5px;
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
			font-size: 13px;
		}

        .titulo{
            align-items: center;
            justify-content: center;
        }

        .textocorpo {
            text-align: justify;
            margin: 30px;
        }

        .assinatura{
            display: flex;
            justify-content: center; 
            align-items: center; 
            text-align: center;
        }
    </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center;width:100%;">
		<div style="width:30%; ">
			<img src="'+@logo+'" alt="Logo da Empresa">
		</div>
		<div style="width:50%;">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - </p>
		    <p><strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p> 
			<p><strong>'+@nm_email_internet+'</strong></p>
		</div> '

--select @html_empresa
	

--Detalhe--

--Procedure de Cada Relatório-------------------------------------------------------------------------------------

declare @cd_item_relatorio  int           = 0
declare @nm_cab_atributo    varchar(100)  = ''
declare @nm_dados_cab_det   nvarchar(max) = ''
declare @nm_grupo_relatorio varchar(60)   = ''

select a.*, g.nm_grupo_relatorio into #RelAtributo 
from
  egisadmin.dbo.Relatorio_Atributo a 
  inner join egisadmin.dbo.relatorio_grupo g on g.cd_grupo_relatorio = a.cd_grupo_relatorio
where 
  a.cd_relatorio = @cd_relatorio


order by
  qt_ordem_atributo

------------------------------------------------------------------------------------------------------------------



select * into #AuxRelAtributo from #RelAtributo
where
  cd_grupo_relatorio = @cd_grupo_relatorio

order by qt_ordem_atributo



while exists ( select top 1 cd_item_relatorio from #AuxRelAtributo order by qt_ordem_atributo)
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


drop table #AuxRelAtributo


--select

--@cd_nota_saida = isnull(cd_identificacao_nota_saida,0)
--from 
--  Parametro_Relatorio

--where
--  cd_relatorio = @cd_relatorio
--  and
--  cd_usuario   = @cd_usuario


declare @vl_total          decimal(25,2) = 0.00
declare @qt_total          int = 0
declare @vl_total_vendedor decimal(25,2) = 0.00
declare @qt_total_vendedor int = 0
--declare @cd_ano            int = 0

--set @cd_nota_saida = 10155

--------------------------------------------------------------------------------
 select            
    ns.cd_identificacao_nota_saida as NUM_NOTA,        
    ns.cd_identificacao_nota_saida as IDENT_NOTA,        
    ns.nm_fantasia_nota_saida      as FANTASIA_CLIENTE, 
	ns.cd_cliente                  as cd_cliente,
    ltrim(rtrim(ns.nm_razao_social_nota))+
	' ('+cast(ns.cd_cliente as varchar(9)) +') - ' +  ns.nm_fantasia_nota_saida +' '
	                               as RAZAOSOCIAL_CLIENTE,        
	  case when c.cd_tipo_pessoa  = 1
	   then dbo.fn_formata_cnpj(ns.cd_cnpj_nota_saida)     
     else dbo.fn_formata_cpf(ns.cd_cnpj_nota_saida)
	  end                            as CNPJ_CLIENTE,
	  case when c.cd_tipo_pessoa  = 1
	   then dbo.fn_formata_cnpj(ns.cd_cnpj_nota_saida)     
     else dbo.fn_formata_cpf(ns.cd_cnpj_nota_saida)
	  end                            as CNPJ_CLIENTE1,        
    ns.cd_inscest_nota_saida       as IE_CLIENTE,        
    ns.cd_ddd_nota_saida           as cd_ddd_nota_saida,        
    ns.cd_telefone_nota_saida      as cd_telefone_nota_saida,        
    ns.sg_estado_nota_saida        as UF_CLIENTE,        
    ns.sg_estado_nota_saida        as UF_CLIENTE1,        
    isnull(ns.nm_cidade_nota_saida,'')         as CIDADE_CLIENTE,        
    isnull(ns.nm_cidade_nota_saida,'')         as CIDADE_CLIENTE1,        
        
    ns.nm_bairro_nota_saida         as BAIRRO_CLIENTE,        
        
    ltrim(rtrim(isnull(ns.nm_endereco_nota_saida,'')))+', '+ltrim(rtrim(isnull(ns.cd_numero_end_nota_saida,''))) as ENDER_CLIENTE,        
        
   -- ns.nm_endereco_nota_saida       as ENDER_CLIENTE,        
    ns.cd_numero_end_nota_saida     as NUM_END_CLIENTE,        
    year(ns.dt_nota_saida) + 5      as VALIDADE_CONT,        
        
 cast(Day(ns.dt_nota_saida) as varchar(10)) + ' de ' + Case  when MONTH(ns.dt_nota_saida) = 1  then 'Janeiro'        
         when MONTH(ns.dt_nota_saida) = 2  then 'Fevereiro'        
                                                             when MONTH(ns.dt_nota_saida) = 3  then 'Março'         
                                             when MONTH(ns.dt_nota_saida) = 4  then 'Abril'        
                                                          when MONTH(ns.dt_nota_saida) = 5  then 'Maio'         
                                                                when MONTH(ns.dt_nota_saida) = 6  then 'Junho'        
                                                          when MONTH(ns.dt_nota_saida) = 7  then 'Julho'        
                                                          when MONTH(ns.dt_nota_saida) = 8  then 'Agosto'        
                                                          when MONTH(ns.dt_nota_saida) = 9  then 'Setembro'         
                                                                when MONTH(ns.dt_nota_saida) = 10 then 'Outubro'        
                                                          when MONTH(ns.dt_nota_saida) = 11 then 'Novembro'         
                                                          else 'Dezembro'        
                                                       end + ' de ' +cast(Year(ns.dt_nota_saida) as varchar(10))    as DT_MES_ANO,    
    cast(Year(ns.dt_nota_saida) as varchar(10)) as ANO_NOTA,    
    ns.cd_cep_nota_saida            as CEP_CLIENTE,        
    cast('' as varchar)             as COMPL_ENDER_CLIENTE,        
        
    nsi.cd_item_nota_saida,        
    nsi.qt_item_nota_saida          as QTDE_NOTA,        
    cp.nm_categoria_produto         as CATEGORIA_PRODUTO,        
    nsi.cd_mascara_produto          as COD_PRODUTO,   
	--case when isnull(ba.cd_bem,0)>0 then
	--   isnull(ba.nm_bem,'')
	--else
    isnull(nsi.nm_produto_item_nota,'')
    --end
	--Dados do Bem--
	+
	' ('+cast(ba.qt_voltagem_bem as varchar(10))+' V )'
	+
	case when isnull(ba.nm_registro_bem,'')<>'' 
	then
	  ' REGISTRO: '+ba.nm_registro_bem
    else
	  cast('' as varchar(1))
    end

	--SELECT * FROM BEM WHERE cd_patrimonio_bem='1503'
	
	as DESCRICAO_PRODUTO,
    isnull(nsi.nm_produto_item_nota,'') as DESC_PRODUTO,        
    b.nm_modelo_bem                 as MODELO_PRODUTO,        
    b.nm_marca_bem                  as MARCA_PRODUTO,        
    b.qt_voltagem_bem               as VOLTAGEM_PRODUTO,        
    b.qt_capacidade_bem             as CAPACIDADE_PRODUTO,
	nsi.cd_num_serie_item_nota      as cd_num_serie_item_nota,
	b.cd_estado_conservacao         as cd_estado_conservacao,
        
    ltrim(rtrim(cast(isnull(p.nm_produto_complemento,'') as varchar)))   as COMPLEMENTO_PRODUTO,        
        
    nsi.cd_item_nota_saida                                                                          as ITEM_NOTA,        
        
    dbo.fn_formata_valor(nsi.vl_total_item)                                                         as VALOR_PRODUTO, 
	sa.cd_solicitacao                                                                               as cd_solicitacao,
        
           
    cast(case when nsi.cd_item_nota_saida=2 then nsi.cd_item_nota_saida   else '' end as varchar)   as ITEM_NOTA1,        
--    cast(case when nsi.cd_item_nota_saida=2 then nsi.qt_item_nota_saida   else '' end as varchar)   as QTDE_NOTA1,        
    cast(case when nsi.cd_item_nota_saida=2 then nsi.qt_item_nota_saida   else '' end as varchar)   as QTDE_NOTA1,        
    cast(case when nsi.cd_item_nota_saida=2 then cp.nm_categoria_produto  else '' end as varchar)   as CATEGORIA_PRODUTO1,        
    cast(case when nsi.cd_item_nota_saida=2 then nsi.cd_mascara_produto   else '' end as varchar)   as COD_PRODUTO1,        
    cast(case when nsi.cd_item_nota_saida=2 then nsi.nm_produto_item_nota else '' end as varchar)   as DESCRICAO_PRODUTO1,        
    cast(case when nsi.cd_item_nota_saida=2 then dbo.fn_formata_valor(nsi.vl_total_item)        
                                                                          else '' end as varchar)   as VALOR_PRODUTO1,        
    cast(case when nsi.cd_item_nota_saida=2 then p.nm_modelo_produto      else '' end as varchar)   as MODELO_PRODUTO1,        
 cast(case when nsi.cd_item_nota_saida=2 then p.nm_marca_produto       else '' end as varchar)   as MARCA_PRODUTO1,        
 cast(case when nsi.cd_item_nota_saida=2 then b.qt_voltagem_bem        else '' end as varchar)   as VOLTAGEM_PRODUTO1,        
 cast(case when nsi.cd_item_nota_saida=2 then b.qt_capacidade_bem      else '' end as varchar)   as CAPACIDADE_PRODUTO1,        
        
        
    cast(case when nsi.cd_item_nota_saida=2 then ltrim(rtrim(cast(isnull(p.nm_produto_complemento,'') as varchar))) else '' end as varchar)  as COMPLEMENTO_PRODUTO1,        
            
    cast(case when nsi.cd_item_nota_saida=2 then nsi.cd_item_nota_saida   else '' end as varchar)   as ITEM_NOTA2,        
    cast(case when nsi.cd_item_nota_saida=3 then nsi.qt_item_nota_saida   else '' end as varchar)   as QTDE_NOTA2,        
  cast(case when nsi.cd_item_nota_saida=3 then cp.nm_categoria_produto  else '' end as varchar)   as CATEGORIA_PRODUTO2,        
    cast(case when nsi.cd_item_nota_saida=3 then nsi.cd_mascara_produto   else '' end as varchar)   as COD_PRODUTO2,        
    cast(case when nsi.cd_item_nota_saida=3 then nsi.nm_produto_item_nota else '' end as varchar)   as DESCRICAO_PRODUTO2,        
    cast(case when nsi.cd_item_nota_saida=3 then ltrim(rtrim(cast(isnull(p.nm_produto_complemento,'') as varchar))) else '' end as varchar)  as COMPLEMENTO_PRODUTO2,        
    cast(case when nsi.cd_item_nota_saida=3 then dbo.fn_formata_valor(nsi.vl_total_item)        
                                                                          else '' end as varchar)   as VALOR_PRODUTO2,        
 cast(case when nsi.cd_item_nota_saida=3 then p.nm_modelo_produto      else '' end as varchar)   as MODELO_PRODUTO2,        
 cast(case when nsi.cd_item_nota_saida=3 then p.nm_marca_produto       else '' end as varchar)   as MARCA_PRODUTO2,        
 cast(case when nsi.cd_item_nota_saida=3 then b.qt_voltagem_bem        else '' end as varchar)   as VOLTAGEM_PRODUTO2,        
 cast(case when nsi.cd_item_nota_saida=3 then b.qt_capacidade_bem      else '' end as varchar)   as CAPACIDADE_PRODUTO2,        
        
           
    ns.dt_nota_saida                as DATA_NOTA,        
    ns.nm_razao_social_nota         as RAZAOSOCIAL_CLIENTE_RODAPE,        
    emp.nm_caminho_logo_empresa     as 'LOGOTIPO',        
    'COMODATO_' +dbo.fn_strzero(ns.cd_identificacao_nota_saida,7)+'.doc'       as nm_arquivo_documento,
	ba.cd_tipo_bem as cd_tipo_bem,
	b.nm_serie_bem as nm_serie_bem
        
            
        
 into        
   #Nota        
         
 from        
   nota_saida ns                             with(nolock) 
   inner join nota_saida_item nsi            with(nolock) on nsi.cd_nota_saida        = ns.cd_nota_saida        
   left outer join produto p                 with(nolock) on p.cd_produto             = nsi.cd_produto        
   left outer join categoria_produto cp      with(nolock) on cp.cd_categoria_produto  = p.cd_categoria_produto        
   left outer join Solicitacao_Ativo sa      with(nolock) on sa.cd_pedido_venda       = nsi.cd_pedido_venda and sa.cd_item_pedido_venda = nsi.cd_item_pedido_venda                                 
   left outer join Bem ba                    with(nolock) on ba.cd_bem                = sa.cd_bem
   left outer join Bem b                     with(nolock) on b.cd_produto             = nsi.cd_produto        
   left outer join egisadmin.dbo.empresa emp with(nolock) on emp.cd_empresa           = @cd_empresa --dbo.fn_empresa() 
   left outer join Cliente c                 with(nolock) on c.cd_cliente             = ns.cd_cliente     

 where        
   ns.cd_identificacao_nota_saida = @cd_nota_saida  
   

 --select * from #nota
select * into #auxnota   from #nota        
select * into #auxnota2  from #nota        
-------------------------------------------------------------------------------------------------------------------------

 update        
   #nota        
 set        
     ITEM_NOTA1           = isnull(( select ITEM_NOTA1           from #auxnota where cd_item_nota_saida = 2),''),        
     QTDE_NOTA1           = isnull(( select QTDE_NOTA1           from #auxnota where cd_item_nota_saida = 2),''),        
     CATEGORIA_PRODUTO1   = isnull(( select CATEGORIA_PRODUTO1   from #auxnota where cd_item_nota_saida = 2),''),        
     COD_PRODUTO1         = isnull(( select COD_PRODUTO1         from #auxnota where cd_item_nota_saida = 2),''),        
     DESCRICAO_PRODUTO1   = isnull(( select DESCRICAO_PRODUTO1   from #auxnota where cd_item_nota_saida = 2),''),        
     COMPLEMENTO_PRODUTO1 = isnull(( select COMPLEMENTO_PRODUTO1 from #auxnota where cd_item_nota_saida = 2),''),        
     VALOR_PRODUTO1       = isnull(( select VALOR_PRODUTO1       from #auxnota where cd_item_nota_saida = 2),'')        
        
 from        
   #nota n        
           
 where        
   cd_item_nota_saida = 1       
   
   
        
 update        
   #nota        
 set        
     ITEM_NOTA2           = isnull(( select ITEM_NOTA2           from #auxnota where cd_item_nota_saida = 3),''),        
     QTDE_NOTA2           = isnull(( select QTDE_NOTA2           from #auxnota where cd_item_nota_saida = 3),''),        
     CATEGORIA_PRODUTO2   = isnull(( select CATEGORIA_PRODUTO2   from #auxnota where cd_item_nota_saida = 3),''),        
     COD_PRODUTO2         = isnull(( select COD_PRODUTO2         from #auxnota where cd_item_nota_saida = 3),''),        
     DESCRICAO_PRODUTO2   = isnull(( select DESCRICAO_PRODUTO2   from #auxnota where cd_item_nota_saida = 3),''),        
     COMPLEMENTO_PRODUTO2 = isnull(( select COMPLEMENTO_PRODUTO2 from #auxnota where cd_item_nota_saida = 3),''),        
     VALOR_PRODUTO2       = isnull(( select VALOR_PRODUTO2       from #auxnota where cd_item_nota_saida = 3),'')        
        
 from        
   #nota n        
           
 where        
   cd_item_nota_saida = 1        

 
-----------------------------------------------------------------------------------------------------------        
declare @nm_inscricao_estadual      varchar(20)
declare @nm_end_cliente             varchar(20)
declare @cd_ddd_nota_saida          varchar(20)
declare @cd_telefone_nota_saida     varchar(20)
declare @nm_marca_produto           varchar(60)
declare @nm_capacidade_produto      varchar(60)
declare @nm_modelo_produto          varchar(60)
declare @cd_num_serie_item_nota     int = 0 
declare @cd_estado_conservacao      int = 0
declare @cd_solicitacao             int = 0 
--declare @cd_cliente                 int =0
 select top 1 
			  @descricao_produto          = DESC_PRODUTO, 
              @valor_produto              = VALOR_PRODUTO,
			  @bairro_cliente             = BAIRRO_CLIENTE,
			  @razaosocial_cliente        = RAZAOSOCIAL_CLIENTE,
			  @cnpj_cliente               = CNPJ_CLIENTE,
			  @ender_cliente              = ENDER_CLIENTE,
			  @cidade_cliente             = CIDADE_CLIENTE,
			  @uf_cliente                 = UF_CLIENTE,
			  @cep_cliente                = CEP_CLIENTE,
			  @razaosocial_cliente_rodape = RAZAOSOCIAL_CLIENTE_RODAPE,
			  @dt_mes_ano                 = DT_MES_ANO,
			  @num_nota                   = NUM_NOTA,
			  @ano_nota                   = ANO_NOTA,
			  @nm_fantasia_cliente        = FANTASIA_CLIENTE,
			  @nm_inscricao_estadual      = IE_CLIENTE,
			  @nm_end_cliente             = NUM_END_CLIENTE,
			  @cd_ddd_nota_saida          = cd_ddd_nota_saida,
			  @cd_telefone_nota_saida     = cd_telefone_nota_saida,
			  @nm_marca_produto           = MARCA_PRODUTO,
			  @nm_capacidade_produto      = CAPACIDADE_PRODUTO,
			  @cd_num_serie_item_nota     = nm_serie_bem,
			  @cd_estado_conservacao      = cd_tipo_bem,
			  @cd_solicitacao             = cd_solicitacao,
			  @cd_cliente                 = cd_cliente,
			  @nm_modelo_produto          = MODELO_PRODUTO
 from #Nota
 
 --select @cd_estado_conservacao
-----------------------------------------------------------------------------------------------------------
--Relatório

if @cd_parametro<> 3
begin

-------------------------------------------montagem do Detalhe---------------------------------------------------------------

declare @id int = 0

set @html_detalhe = '
        <div style="width:20%;">
		    <p><b>Nº Contrato:</b> '+cast(isnull(@cd_solicitacao,'')as varchar(20))+'<p>
            <p><b>Nº Cadastro:</b> '+cast(isnull(@cd_cliente,'')as varchar(20))+'</p>
        </div>
  	</div> 
     <div class="textocorpo">
        <h3 style="text-align: CENTER;">CONTRATO DE COMODATO</h3>
        <div>
            
            <p>Pelo presente instrumento particular de comodato, que entre si celebram, de um lado, VEZENTIN E KOCH LTDA LTDA., 
                estabelecida a RUA D ,400 Município de ALTA FLORESTA- MT CNPJ:04.123.657/0001-05 INSC.EST. 13.198.361-0, 
                neste ato denominada simplesmente COMODANTE e de outro lado </p>
            <p>Razão social: '+isnull(@razaosocial_cliente,'')+',Nome Fantasia: '+isnull(@nm_fantasia_cliente,'')+', 
			   CNPJ/CPF: '+ISNULL(@cnpj_cliente,'')+', Inscrição Estadual: '+isnull(@nm_inscricao_estadual,'')+',
			   Endereço:'+isnull(@ender_cliente,'')+', Bairro: '+isnull(@bairro_cliente,'')+', 
			   n°: '+isnull(@nm_end_cliente,'')+', Telefone: '+isnull(@cd_telefone_nota_saida,'')+'. Cidade: '+isnull(@cidade_cliente,'')+'
			   UF: '+isnull(@uf_cliente,'')+'doravante denominada COMODATÁRIA. O contrato firmado pelas partes acima qualificadas se regerá pelas seguintes cláusulas e condições.</p>
            
                <h3 style="text-align: CENTER;">DO OBJETO</h3>
            
                <p><strong>Cláusula Primeira:</strong> O presente instrumento particular tem como objetivo estabelecer a relação comercial que a COMODANTE cede mediante este contrato o equipamento citado abaixo sem cobranças a COMODATÁRIA, e em troca a COMODATÁRIA se compromete em usar o Freezer com exclusividade, tendo a linha de produtos da SORVETES ZERO GRAU, mantendo o mesmo sempre a vista, bem como LOGOTIPOS e Tabela de preços do fabricante e reabastecê-lo a cada visita do vendedor.
            </p>
            <p><strong>Cláusula Segunda: </strong> Em razão da exclusividade comercial a que se submete, a COMODATÁRIA recebe em comodato os equipamentos descritos abaixo, 
			conforme Nota Fiscal nº '+isnull(@num_nota,0)+', Marca: '+isnull(@nm_marca_produto,0)+', Capacidade: '+isnull(@nm_capacidade_produto,0)+', Modelo: '+isnull(@nm_modelo_produto,'')+', Série nº '+cast(isnull(@cd_num_serie_item_nota,0) as nvarchar(20))+', Cor: Azul, 
			Estado de conservação: '+CASE 
										WHEN ISNULL(@cd_estado_conservacao, 0) = 1 THEN '(x) Novo   ( ) Seminovo   ( ) Usado.'
										WHEN ISNULL(@cd_estado_conservacao, 0) = 2 THEN '( ) Novo   (x) Seminovo   ( ) Usado.'
										WHEN ISNULL(@cd_estado_conservacao, 0) = 3 THEN '( ) Novo   ( ) Seminovo   (x) Usado.'
										ELSE 'Sem Descrição.' 
									END+'</p>
            <p><strong>Cláusula Terceira:</strong> Para efeito deste contrato o referido freezer tem o preço de R$ '+cast(isnull(@valor_produto,0) as varchar(15))+'(reais).</p>
           
            <h3 style="text-align: CENTER;">DA VIGÊNCIA CONTRATUAL</h3>' 

SET @html_geral =   
			'<p><strong>Cláusula Quarta:</strong> O presente contrato terá a vigência por 12 (doze) meses, a contar da assinatura do presente instrumento, prorrogável por igual período caso não haja manifestação em contrário por qualquer das partes.</p>
            <h3 style="text-align: CENTER;">DOS DIREITOS E DAS OBRIGAÇÕES DA COMODATÁRIA</h3>  

            <p><strong>Cláusula Quinta: </strong>A COMODATÁRIA permitirá a COMODANTE a fiscalização em qualquer momento durante a vigência do presente instrumento.</p>
            <p><strong>Cláusula Sexta: </strong>A COMODATÁRIA reconhece como causa automática de rescisão deste contrato, a utilização do freezer para estocagem de qualquer outro produto que não seja o permitido pela COMODANTE.

            </p>
            <p><strong>Cláusula sétima:</strong> A COMODATÁRIA se obriga a mantê-lo em bom estado de funcionamento, conservação e limpeza, respondendo por danos resultantes da má conservação, extravio do objeto ou de seus componentes até a entrega final do mesmo. 

            </p>
            <p><strong>Cláusula oitava:</strong> Utilizar o referido equipamento que será cedido em comodato exclusivamente para beneficiamento dos produtos adquiridos da COMODANTE, sob pena de rescisão contratual.</p>
            <p><strong>Cláusula nona:</strong> Informar imediatamente a COMODANTE a ameaça de embargo ou penhora sobre o equipamento objeto deste contrato, obrigando-se ainda a declarar expressamente como sendo de propriedade daquele o equipamento em referência, sempre que algum litigio, administrativo ou judicial puder de qualquer forma o atingir.</p>
            <p><strong>Cláusula décima:</strong> A COMODATÁRIA não poderá ceder ou transferir os seus direitos e obrigações decorrentes do presente contrato de comodato sem prévia autorização da COMODANTE.
            </p>
            <p><strong>Cláusula décima primeira:</strong> No caso de venda ou transferência do estabelecimento comercial da COMODATÁRIA, obriga-se está a denunciar a existência do presente contrato aos novos adquirentes, os quais ficam, em qualquer caso, obrigados a respeitá-lo em todas as suas cláusulas ou condições. Ocorrendo esta hipótese, fica, entretanto, a critério exclusivo da COMODANTE manter o presente contrato com o adquirente do estabelecimento ou rescindi-lo.</p>
            <p><strong>Cláusula décima segunda:</strong> Arcar com as despesas, inclusive os honorários advocatícios e custas processuais, sempre que a COMODANTE for obrigada a intervir em qualquer processo ou agir perante qualquer autoridade para defender questões relativas ao equipamento objeto do presente contrato, de litigio em que a COMODATÁRIA esteja envolvida.
            </p>
            <h3 style="text-align: CENTER;">DOS DIREITOS E DAS OBRIGAÇÕES DA COMODANTE</h3>
            <p><strong>Cláusula décima terceira:</strong> Os serviços de assistência técnica, revisão e inspeção periódica, serão realizados pela COMODANTE. Em caso de necessidade de recolhimento do freezer para revisão, a COMODATÁRIA deverá exigir a primeira via deste contrato.</p>
            <p><strong>Cláusula décima quarta:</strong> Não é de responsabilidade da COMODANTE, qualquer prejuízo advindo as mercadorias nele depositado em virtude de negligência quanto a permanência do freezer ligado, queda ou falta de energia elétrica, ou instalação elétrica em mau estado de conservação. </p>
            
            <h3 style="text-align: CENTER;">DISPOSIÇÕES GERAIS</h3>
            <p><strong>Cláusula décima quinta:</strong> A permanência do comodato firmado entre as partes dependerá do cumprimento da meta de consumo mínimo de R$ 500,00 (reais) mensal dos produtos fornecidos pela COMODANTE.</p>
            <p><strong>Cláusula décima sexta:</strong> Poderá a COMODANTE realizar a rescisão unilateral do presente contrato, caso transcorrido o prazo de 90 (noventa) dias sem que a COMODATÁRIA compre e/ou adquire os produtos fornecidos pela COMODANTE. </p>
            <p><strong>Cláusula décima sétima:</strong> O não cumprimento da cláusula primeira e cláusula décima sétima, obrigará a COMODANTE a retirar o aparelho sem aviso prévio, não tendo a COMODATÁRIA direito a qualquer reclamação.</p>
            <p><strong>Cláusula décima oitava: </strong>Este contrato poderá ser rescindido por ambas as partes, desde que a parte que assim o desejar, notifique com antecedência mínima de 10 (dez) dias. Mercadorias em estoque na rescisão desse contrato, não serão ressarcidas pela COMODANTE.</p>
            <p><strong>Cláusula décima nona: </strong>O presente instrumento será considerado rescindido de pleno direito em caso de infração, por parte da COMODATÁRIA, de qualquer cláusula acordada, assegurado à COMODANTE o direito de retirar, de onde quer que esteja, o bem ora cedido em comodato.</p>
            <p><strong>Cláusula vigésima:</strong> Poderá a COMODANTE rejeitar qualquer pedido de compra, se o COMODATÀRIO estiver incorrendo em descumprimento de qualquer das condições deste contrato, especialmente no que se refere à inadimplência.</p>
            
            <h3 style="text-align: CENTER;">DO FORO</h3>
            <p><strong>Cláusula vigésima primeira:</strong> Fica eleito o fórum da cidade de ALTA FLORESTA – MT para dirimir todas as questões decorrentes do cumprimento deste contrato.</p>
            <p>E, por estarem de acordo, assinam o presente contrato em 2(duas) vias de igual teor e forma, na presença de testemunhas, o qual obrigam-se por seus herdeiros a cumprir fielmente este contrato.</p>
          
            <p style="text-align: left;margin-top: 20px;margin-bottom: 10px;">ALTA FLORESTA - MT, '+cast(isnull(@dt_mes_ano,0) as varchar(25))+'</p>
			<p style="text-align: left;margin-top: 20px;margin-bottom: 50px;">TESTEMUNHAS: </p>
            <div class="assinatura" style="width: 100%;">
                <div style="width: 40%;margin-bottom: 30px;">
                    <p>_____________________________</p>
                    <p><strong>Nome:</strong></p>
                    <p><strong>CPF:</strong></p>
                </div>
                <div style="width: 60%;margin-bottom: 30px;">
                    <p> VEZENTIN E KOCH LTDA LTDA</p>
                    <p><strong>COMODANTE</strong></p>
                </div>
            </div>
            <div class="assinatura">
                 <div style="width: 40%;">
                    <p>_____________________________</p>
                    <p><strong>Nome:</strong></p>
                </div>
                <div style="width: 60%;">
                    <p>'+isnull(@nm_fantasia_cliente,'')+'</p>
                    <p><strong>COMODATÁRIA</strong></p>
                </div>
            </div>
			</body>
            </html>'
		
		
--declare @nm_fantasia_vendedor varchar(30) = ''

--------------------------------------------------------------------------------------------------





--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +

	--@html_cab_det +
	 @html_detalhe +
	--@html_rod_det +

	@html_geral   + 
	@html_totais  +
	@html_grafico +
    @html_rodape  

--select @html, @html_empresa, @html_titulo, @html_cab_det, @html_rod_det, @html_totais, @html_grafico, @html_rodape

-------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------


end



----------------------------------------------------------------------------------------------------------------------------------------------
go



--exec pr_egis_relatorio_contrato_comodato_zerograu 182,4253,363,0,''
------------------------------------------------------------------------------
