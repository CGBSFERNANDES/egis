IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_contrato_comodato_congelart' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_contrato_comodato_congelart

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_contrato_comodato
-------------------------------------------------------------------------------
--pr_egis_relatorio_contrato_comodato
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
create procedure pr_egis_relatorio_contrato_comodato_congelart
@cd_relatorio int   = 0,
@cd_usuario   int   = 0,
@cd_documento int   = 0, 
@cd_parametro int   = 0,
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
			@ds_produto                 nvarchar(400),
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
			@ic_empresa_faturamento		char(1) = ''
					   
--------------------------------------------------------------------------------------------------------

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
--set @cd_parametro      = 0
set @cd_modulo         = 0
set @cd_empresa        = 0
set @cd_menu           = 0
set @cd_processo       = 0
set @cd_item_processo  = 0
set @cd_form           = 0
set @cd_documento      = 0
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
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'
     select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'

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


----------------------------------------------------------------------------------------------------------------------------

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

        table,
        th,
        td {
            border: 1px solid #ddd;
        }

        th,
        td {
            padding: 5px;
            width: 30px;
            height: 30px;
            height: 55px;
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
            background-color: #1976D2;
            color: white;
            padding: 5px;
            margin-bottom: 10px;
            border-radius: 5px;
        }

        img {
            
            max-width: 350px;
            margin: 15px;
        
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
            color: #1976D2;
        }

        .report-date-time {
            text-align: right;
            margin-bottom: 5px;
            margin-top: 50px;
        }

        p {
            margin: 5px;
            padding: 0;
        }
        .titulo{
            align-items: center;
            justify-content: center;
        }
        .textocorpo{
            text-align: justify;
            align-items: center;
            margin: 15px 110px;
            padding: auto;
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

  --and
  --g.cd_grupo_relatorio = 4

order by
  qt_ordem_atributo

------------------------------------------------------------------------------------------------------------------


--select * from #RelAtributo

--select * from egisadmin.dbo.relatorio_grupo

select * into #AuxRelAtributo from #RelAtributo
where
  cd_grupo_relatorio = @cd_grupo_relatorio

order by qt_ordem_atributo

--select * from #AuxRelAtributo

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

--SELECT @nm_dados_cab_det

drop table #AuxRelAtributo

--select @nm_dados_cab_det

--select * from #RelAtributo

--select * from parametro_relatorio
--delete from parametro_relatorio
--update parametro_relatorio

--Chamada dos Parametros do Relatório---

--declare @cd_tipo_pedido int

select
  @dt_inicial     = dt_inicial,
  @dt_final       = dt_final,
  @cd_vendedor    = isnull(cd_vendedor,0),
  @cd_cliente     = isnull(cd_cliente,0),
  @cd_tipo_pedido = 0 --cd_tipo_pedido
from 
  Parametro_Relatorio

where
  cd_relatorio = @cd_relatorio
  and
  cd_usuario   = @cd_usuario

  

  --select @cd_relatorio, @cd_usuario

--select
--*
--from 
--  Parametro_Relatorio

--where
--  cd_relatorio = @cd_relatorio
--  and
--  cd_usuario   = @cd_usuario


---> CCF <----
---> alteração com o processo do relatório

declare @vl_total          decimal(25,2) = 0.00
declare @qt_total          int = 0
declare @vl_total_vendedor decimal(25,2) = 0.00
declare @qt_total_vendedor int = 0
--declare @cd_ano            int = 0



--------------------------------------------------------------------------------
 select            
    ns.cd_identificacao_nota_saida as NUM_NOTA,        
    ns.cd_identificacao_nota_saida as IDENT_NOTA,        
    ns.nm_fantasia_nota_saida      as FANTASIA_CLIENTE,        
    ltrim(rtrim(ns.nm_razao_social_nota))+
	' ('+cast(ns.cd_cliente as varchar(9)) +') - ' +  ns.nm_fantasia_nota_saida +', '
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
    ns.cd_ddd_nota_saida,        
    ns.cd_telefone_nota_saida,        
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
        
    ltrim(rtrim(cast(isnull(p.nm_produto_complemento,'') as varchar)))   as COMPLEMENTO_PRODUTO,        
        
    nsi.cd_item_nota_saida                                                                          as ITEM_NOTA,        
        
    dbo.fn_formata_valor(nsi.vl_total_item)                                                         as VALOR_PRODUTO,        
        
           
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
    'COMODATO_' +dbo.fn_strzero(ns.cd_identificacao_nota_saida,7)+'.doc'       as nm_arquivo_documento       
        
            
        
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
   ns.cd_nota_saida = @cd_documento   
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
 --select top 1 * from #Nota       
 --order by cd_item_nota_saida  
 declare @ie_cliente        varchar(100)
 declare @cnpj_cliente1     varchar(20)
 declare @item_nota         varchar(50)
 declare @uf_cliente1       varchar(20)
 declare @qtde_nota         varchar(20)
 declare @qtde_nota1        varchar(20)
 declare @qtde_nota2        varchar(20)
 declare @categoria_produto  varchar(50)
 declare @categoria_produto1 varchar(50)
 declare @categoria_produto2 varchar(50)
 declare @cd_produto        varchar(20)
 declare @cd_produto1		varchar(20)
 declare @cd_produto2      varchar(20)
 declare @item_nota1        varchar(50)
 declare @item_nota2        varchar(50)
 declare @ds_produto1       varchar(50)
 declare @ds_produto2       varchar(50)
 declare @valor_produto1    varchar(12)
 declare @valor_produto2    varchar(12)
 DECLARE @dt_nota           varchar(20)
 
 


 
 select 
			  @ds_produto                 = DESCRICAO_PRODUTO, 
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
			  @ie_cliente                 = IE_CLIENTE,
			  @cnpj_cliente1              = CNPJ_CLIENTE1,
			  @item_nota                  = ITEM_NOTA,
			  @uf_cliente1                = UF_CLIENTE1,
			  @cd_produto                 = COD_PRODUTO,
			  @categoria_produto          = CATEGORIA_PRODUTO,
			  @qtde_nota                  = QTDE_NOTA,
			  @cd_produto1                = COD_PRODUTO1,
			  @cd_produto2                = COD_PRODUTO2,
			  @qtde_nota1                 = QTDE_NOTA1,
			  @qtde_nota2                 = QTDE_NOTA2,
			  @categoria_produto1         = CATEGORIA_PRODUTO1,
			  @categoria_produto2         = CATEGORIA_PRODUTO2,
			  @item_nota1                 = ITEM_NOTA1,
			  @item_nota2                 = ITEM_NOTA2,
			  @ds_produto1                = DESCRICAO_PRODUTO1,
			  @ds_produto2                = DESCRICAO_PRODUTO2,
			  @valor_produto1             = VALOR_PRODUTO1,
			  @valor_produto2             = VALOR_PRODUTO2,
			  @nm_fantasia_cliente        = FANTASIA_CLIENTE, 
			  @dt_nota                    = DATA_NOTA
 from #Nota
 
 
-----------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
--Relatório

if @cd_parametro<> 3
begin

-------------------------------------------montagem do Detalhe---------------------------------------------------------------

declare @id int = 0

set @html_detalhe = '<div class="textocorpo">
     <h1 style="text-align: CENTER;">CONTRATO DE COMODATO</h1>
     <div style="display: flex; justify-content: space-between; align-items:center">
    <div>
      <h1>Cliente</h1>
      <p style="font-size:18px"><strong>'+isnull(@nm_fantasia_cliente,'')+'</strong></p>
    </div>
    <div>
      <h1>Número da Nota Fiscal (NFE) </h1>
      <p style="font-size:18px"><strong>'+cast(isnull(@num_nota,0) as nvarchar(12))+'</strong></p>
    </div>
  </div>
    <p>CONGELART DO BRASIL, pessoa jurídica de direito privado, inscrita no CGC (MF) sob nº 51.337.443/0001-03 e com Inscrição Estadual nº 799.793.290.116, estabelecida na AV ALVARO GUIMARAES, 1425 ,PLANALTO SAO BERNARDO DO CAMPO, SP, 09.890-003, neste ato representado por seu representante legal na forma do seu Contrato Social, na qualidade de COMODANTE, e</p>
    <BR><p><strong>COMODATÁRIO</strong></p>
    <div>
    <table>
      <tr>
        <td>Nome:</td>
        <td>'+isnull(@razaosocial_cliente,'')+'</td>
        <td>CNPJ/CPF:</td>
        <td>'+cast(isnull(@cnpj_cliente,0) as nvarchar(15))+'</td>
        <td>IE/RG:</td>
        <td colspan="3">'+isnull(@ie_cliente,'')+'</td>

      </tr>
      <tr>
        <td>Endereço</td>
        <td colspan="7">'+isnull(@ender_cliente,'')+'</td>
      </tr>
      <tr>
        <td>Bairro:</td>
        <td>'+isnull(@bairro_cliente,'')+'</td>
        <td>Cidade:</td>
        <td>'+isnull(@cidade_cliente,'')+'</td>
        <td>UF:</td>
        <td>'+isnull(@uf_cliente,'')+'</td>
        <td>CEP</td>
        <td>'+cast(isnull(@cep_cliente,'') as nvarchar(20))+'</td>
      </tr>
    </table>
  </div>
    
    <div>
      <p>As partes celebram entre si o presente CONTRATO DE COMODATO, conforme as Cláusulas e condições a seguir dispostas:</p>
      <p><strong>I – OBJETO</strong></p>
      <p>Cláusula 1ª - Como objeto do presente comodato figura(m):</p>
      <div>
        <table>
          <tr>
            <th>Item</th>
            <th>Qtde</th>
            <th>Categoria</th>
            <th>Cód</th>
            <th>Descrição</th>
            <th>Valor R$</th>
          </tr>
          <tr>
            <td>'+isnull(@item_nota,'')+'</td>
            <td>'+cast(isnull(@qtde_nota,0) as nvarchar(10))+'</td>
            <td>'+isnull(@categoria_produto,'')+'</td>
            <td>'+CAST(isnull(@cd_produto,0) as nvarchar(10))+'</td>
            <td>'+isnull(@ds_produto,'')+'</td>
            <td>'+cast(isnull(@valor_produto,0) as nvarchar(10))+'</td>
          </tr>
		   <tr>
            <td>'+isnull(@item_nota1,'')+'</td>
            <td>'+cast(isnull(@qtde_nota1,0) as nvarchar(10))+'</td>
            <td>'+isnull(@categoria_produto1,'')+'</td>
            <td>'+CAST(isnull(@cd_produto1,0) as nvarchar(10))+'</td>
            <td>'+isnull(@ds_produto1,'')+'</td>
            <td>'+cast(isnull(@valor_produto1,0) as nvarchar(10))+'</td>
          </tr>
		   <tr>
            <td>'+isnull(@item_nota2,'')+'</td>
            <td>'+cast(isnull(@qtde_nota2,0) as nvarchar(10))+'</td>
            <td>'+isnull(@categoria_produto2,'')+'</td>
            <td>'+CAST(isnull(@cd_produto2,0) as nvarchar(10))+'</td>
            <td>'+isnull(@ds_produto2,'')+'</td>
            <td>'+cast(isnull(@valor_produto2,0) as nvarchar(10))+'</td>
          </tr>
        </table>
      </div>
      <p>Cláusula 2ª - O objeto do presente contrato destina-se exclusivamente a comercialização dos produtos Congelart do Brasil.</p>
      <p><strong>Parágrafo 1º -</strong> Caso a cláusula 1ª refira-se a freezer’s ou conservadores, é proibida sua utilização para acondicionamento de outros produtos senão sorvetes CONGELART.</p>
      <p><strong>Parágrafo 2º - </strong>Caso a cláusula 1ª refira-se a outros bens que não aqueles especificados no anterior, sua utilização deverá ser conexa com a atividade de comercialização dos sorvetes CONGELART.</p>
      <p><strong>Cláusula 3ª -</strong> O descumprimento do disposto na <strong>Cláusula 2ª</strong> e seus parágrafos, por si só, gerará a rescisão do presente contrato e devolução imediata do bem sendo dispensada qualquer notificação judicial ou extrajudicial.</p>
      <p><strong>II – Prazo </strong></p>
      <p><strong>Cláusula 4ª - </strong>O comodato é feito por prazo indeterminado e será mantido enquanto o cliente mantiver os pedidos mensais de acordo com o equipamento e tabela abaixo.</p>
      <p><strong>TVP/TVM = 1/2 Salario Mínimo </strong></p>
      <p><strong>VEK = 1 Salario Mínimo </strong></p>
      <p><strong>II - Obrigações do COMODATÁRIO</strong></p>
      <p><strong>Cláusula 5ª - </strong>Cabe ao COMODATÁRIO, por força do presente contrato, zelar pelo bem como se seu próprio fosse mantendo-o em perfeitas condições de funcionamento e conservação, devendo para tanto:</p>
      <p>I - manter limpo e asseado o objeto do presente contrato para que atinja o fim ao qual se destina;</p>
      <p>II - arcar, às suas expensas, com taxas, impostos, multas ou quaisquer outros encargos eventualmente cobrados pelo poder público em decorrência da instalação e permanência do bem em seu estabelecimento;</p>
      <p>III - arcar, às suas expensas, com as despesas com a energia‚ elétrica consumida pelo presente bem;</p>
      <p>IV - manter o bem dentro dos limites do seu estabelecimento comercial, em lugar visível ao público evitando que edificações e/ou crescimento de árvores particulares ou públicas impeçam sua publicidade;</p>
      <p>V - permitir que o COMODANTE vistorie o bem ora emprestado sempre que julgar conveniente, obrigando-se a assegurar-lhe o livre acesso ao mesmo;</p>
      <p>VI - manter caso o bem se componha de luminosos ou assemelhados, acesas suas lâmpadas durante o entardecer e durante a noite, de forma a torná-lo visível também‚ durante a escassez de luz solar;</p>
      <p>VII - comunicar ao COMODANTE eventual intenção de vender, ceder, transferir, emprestar, locar ou sublocar o estabelecimento comercial onde se encontra o bem para que o COMODANTE expresse sua intenção, ou não, de continuar na execução do presente contrato.</p>
      <p><strong>Parágrafo Único – </strong>É expressamente vedado ao COMODATÁRIO ceder, doar, emprestar, caucionar ou, a qualquer título, alienar o bem ou os bens objeto do presente contrato, sob pena de responder pelo crime de apropriação indébita previsto no art. 168 do Código Penal Brasileiro, sem prejuízo das demais cominações previstas neste contrato.</p>
      <p><strong>Cláusula 6ª - </strong>É expressamente vedado ao COMODATÁRIO ceder, doar, emprestar, caucionar ou, a qualquer título, alienar o bem ou os bens objeto do presente contrato, sob pena de responder pelo crime de apropriação indébita previsto no art. 168 do Código Penal Brasileiro, sem prejuízo das demais cominações previstas neste contrato.</p>
      <p><strong>Parágrafo Único </strong>Dentre os bens sobre os quais o COMODATÁRIO tem responsabilidade inclui-se os produtos que estejam dentro dele, ESPECIALMENTE SORVETES, e que por ventura, danifiquem-se em decorrência do mau funcionamento do bem objeto do presente contrato.  Em hipótese nenhuma caberá ao COMODANTE qualquer responsabilidade sobre produtos danificados nestas condições.</p>
      <p><strong>Cláusula 7ª - </strong>Ao COMODATÁRIO não caberá qualquer direito de retenção baseado em gastos efetuados em decorrência das Cláusulas 3ª e 4ª, pelo fato de já se considerar remunerado pelo uso do presente bem.</p>
      <p><strong>IV - Obrigações do COMODANTE</strong></p>
      <p><strong>Cláusula 8ª - </strong>Cabe ao COMODANTE adquirir o bem objeto do presente contrato e emprestá-lo ao COMODATÁRIO em perfeitas condições de funcionamento e conservação, ressalvando-se o desgaste normal proporcionado pelo regular uso do bem, devendo para tanto:</p>
      <p>I - instalar o bem dentro dos limites do estabelecimento comercial do COMODATÁRIO, no local que entender ser adequado, sendo de responsabilidade do COMODATÁRIO as instalações hidráulicas e elétricas que forem necessárias;</p>
      <p>II - providenciar, por conta do COMODATÁRIO, o transporte, material e mão-de-obra necessária para instalação do bem;</p>
      <p>III - retirar o bem no caso de rescisão do presente contrato, arcando o COMODATÁRIO com as despesas decorrentes de transporte e mão de obra;</p>
      <p><strong>Cláusula 9ª -</strong>Ao COMODANTE cabe reivindicar o bem objeto do presente contrato de quem injustificadamente o detenha exercendo para tanto os direitos que a lei lhe confere.</p>
      <p><strong>V – Rescisão</strong></p>
      <p><strong>Cláusula 10ª - </strong>O presente contrato rescindir-se-á:</p>
      <p>I - por iniciativa de qualquer das partes desde que seja o outra comunicada com 01 (um) dia de antecedência;</p>
      <p>II - por término do prazo estipulado na Cláusula 4ª;</p>
      <p>III- pelo não cumprimento de qualquer das Cláusulas do presente contrato;</p>
      <p>IV - automaticamente na hipótese de insolvência, concordata ou falência do COMODATÁRIO, podendo então o COMODANTE retirar o bem emprestado independentemente de qualquer medida judicial ou extrajudicial.</p>
      <p><strong>Cláusula 11ª - </strong>No caso de rescisão motivada pelo inciso III da Cláusula 10ª fica a parte que a ela deu causa obrigada a pagar a outra, a título de multa contratual, a quantia referente a 50% (cinquenta por cento) do valor total do bem.</p>
      <p><strong>VI – Restituição</strong></p>
      <p><strong>Cláusula 12ª - </strong>O bem objeto do presente contrato será impreterivelmente restituído ao COMODANTE na ocasião da rescisão do presente contrato, conforme determina a Cláusula 8ª, não cabendo ao COMODATÁRIO qualquer direito de retenção, seja a que título for.</p>
      <p>Parágrafo I – Caso o bem restituído não esteja em perfeitas condições de conservação e funcionamento, como previsto no caput da Cláusula 8ª deste instrumento, se obrigará o COMODATÁRIO a reembolsar à COMODANTE as despesas necessárias para restabelecer o bem às condições de conservação e funcionamento em que foi comodato.</p>
      <p>Parágrafo II – Caso o bem não seja restituído imediatamente, no ato da comunicação da rescisão do presente contrato, se obriga o COMODATÁRIO a indenizar a COMODANTE pela perda do bem, pelo valor descrito na Cláusula 1ª deste instrumento, acrescido de correção monetária pela variação do IGP/M da FGV, no prazo de até 5 dias, desde já autorizado o faturamento do bem objeto do comodato, e o acréscimo de multa de mora de 10% e juros pela variação da SELIC, a partir do vencimento. </p>
      <p>Parágrafo III – O COMODATÁRIO se obriga a emitir a devida nota fiscal de devolução de comodato, por ocasião da restituição do bem à COMODANTE, por qualquer das razões previstas neste instrumento. Caso o COMODATÁRIO não emita a referida nota fiscal, por qualquer tipo de impedimento, desde já autoriza a COMODANTE a emitir a nota fiscal de entrada de retorno do bem, em seu próprio nome ou de seu representante legal. </p>
      <p><strong>Cláusula 13ª -</strong> O COMODATÁRIO deverá à COMODANTE multa no valor de 5% (cinco por cento) do valor do bem, como consta da Cláusula 1ª deste contrato, por dia de atraso na sua devolução.</p>
      <p><strong>VII – Disposições Gerais</strong></p>
      <p><strong>Cláusula 14ª -</strong> Qualquer tolerância da COMODANTE com relação às disposições contidas neste contrato, não constituirá novação, nem alteração contratual.</p>
      <p><strong>VII - Foro</strong></p>
      <p><strong>Cláusula 15ª -</strong> Fica eleito o foro da comarca de São Bernardo do Campo, SP, com privilégio‚ sobre qualquer outro, para dirimir questões oriundas deste contrato.</p>
      <p>E por estarem justos e contratados firmam em 2 (duas) vias de igual teor, após terem lido perante as testemunhas infra qualificadas e assinadas. </p>
      
      <p style="text-align: left;margin-top: 50px;margin-bottom: 25px;">São Bernardo do Campo, '+CAST(isnull(@dt_nota,0) as nvarchar(20))+'</p>
      <div class="assinatura">
          <div style="padding: 50PX;">
            <p><strong>COMODANTE</strong></p>
            <p>CONGELART DO BRASIL LTDA.</p>
          </div> 
          <div style="padding: 50PX;">
            <p><strong>COMODATÁRIO</strong></p>
            <p>'+isnull(@razaosocial_cliente,'')+'</p>
            <p>Nome:_______________________</p>
            <p>CPF:_______________________</p>
          </div>
      </div>
          <div class="assinatura">
            <div style="padding: 50PX;">
              <p>LANAY SOUZA DA SILVA</p>
              <p>OFICINA DE REFRIGERAÇÃO</p>
              <p>RG.: 36.603.125-9</p>
            </div> 
            <div style="padding: 50PX;margin-left: 50PX;">
              <p>TESTEMUNHA</p>
              <p>RAFAEL BARBOSA</p>
              <p>RG.: 37.253.863-0</p>
            </div>
        </div>'
		
		
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


--Gráfico
exec pr_egis_relatorio_contrato_comodato_congelart 182,4253,0,0,''
------------------------------------------------------------------------------
--text: (ctx) => "Point Style: " + ctx.chart.data.datasets[0].pointStyle, ( texto no título )
--select * from parametro_relatorio

