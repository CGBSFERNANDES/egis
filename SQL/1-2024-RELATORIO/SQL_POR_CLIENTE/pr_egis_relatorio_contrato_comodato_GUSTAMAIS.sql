IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_contrato_comodato_gustamais' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_contrato_comodato_gustamais

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
create procedure pr_egis_relatorio_contrato_comodato_gustamais
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
		    @razaosocial_cliente        varchar(200),
			@razaosocial_cliente_rodape varchar(100),
			@dt_mes_ano					varchar(30),
			@valor_produto				varchar(50),
			@ds_produto                 varchar(150),
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
--set @cd_documento      = 0
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
--  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'


--   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
--     select @cd_documento           = valor from #json where campo = 'cd_documento'
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
   ns.cd_pedido_venda = @cd_documento --11006  
-- select * from #nota
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
 declare @num_nota          varchar(20)
 declare @ie_cliente        varchar(100)
 declare @cnpj_cliente1     VARCHAR(20)
 declare @item_nota         varchar(50)
 declare @uf_cliente1       varchar(20)
 declare @qtde_nota         float = 0
 declare @qtde_nota1        float = 0
 declare @qtde_nota2        float = 0
 declare @categoria_produto  varchar(50)
 declare @categoria_produto1 varchar(50)
 declare @categoria_produto2 varchar(50)
 declare @cd_produto        varchar(20)
 declare @cd_produto1		varchar(20)
 declare @cd_produto2       varchar(20)
 declare @item_nota1        varchar(50)
 declare @item_nota2        varchar(50)
 declare @ds_produto1       varchar(50)
 declare @ds_produto2       varchar(50)
 declare @valor_produto1    nvarchar(12)
 declare @valor_produto2    nvarchar(12)
 DECLARE @dt_nota           NVARCHAR(20)
 declare @marca_produto     varchar(100)
 declare @marca_produto1    varchar(100)
 declare @marca_produto2    varchar(100)
 declare @modelo_produto    varchar(100)
 declare @modelo_produto1    varchar(100)
 declare @modelo_produto2    varchar(100)
 declare @voltagem_produto  varchar(20)
 declare @voltagem_produto1  varchar(20)
 declare @voltagem_produto2  varchar(20)
 declare @capacidade_produto varchar(20)
 declare @capacidade_produto1 varchar(20)
 declare @capacidade_produto2 varchar(20)
 declare @data_nota           varchar(20)
 declare @cidade_cliente1     varchar(50)
 
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
			  @uf_cliente1                = @uf_cliente1,
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
			  @dt_nota                    = DATA_NOTA,
			  @marca_produto              = MARCA_PRODUTO,
			  @marca_produto1             = MARCA_PRODUTO1,
			  @marca_produto2             = MARCA_PRODUTO2,
			  @modelo_produto             = MODELO_PRODUTO,
			  @modelo_produto1            = MODELO_PRODUTO1,
			  @modelo_produto2            = MODELO_PRODUTO2,
			  @capacidade_produto         = CAPACIDADE_PRODUTO,
			  @capacidade_produto1        = CAPACIDADE_PRODUTO1,
			  @capacidade_produto2        = CAPACIDADE_PRODUTO2,
			  @voltagem_produto           = VOLTAGEM_PRODUTO,
			  @voltagem_produto1          = VOLTAGEM_PRODUTO1,
			  @voltagem_produto2          = VOLTAGEM_PRODUTO2,
			  @data_nota                  = DATA_NOTA,
			  @cidade_cliente1            = CIDADE_CLIENTE1

 from #Nota
 
 
-----------------------------------------------------------------------------------------------------------



---Faturamento Mensal----


  select
    
    year(n.dt_nota_saida)                    as cd_ano,
	month(n.dt_nota_saida)                   as cd_mes,
	SUM( isnull(n.vl_total,0) )              as vl_total,
	count( distinct n.cd_vendedor)           as qt_vendedor,
	COUNT( distinct n.cd_cliente)            as qt_cliente,
	MAX(n.dt_nota_saida)                     as dt_nota_saida,
	count(n.cd_nota_saida)                   as qt_nota

  into #FaturamentoMensal

  from
    Nota_Saida n
	inner join Cliente c                   on c.cd_cliente               = n.cd_cliente    
	inner join Operacao_Fiscal opf         on opf.cd_operacao_fiscal     = n.cd_operacao_fiscal
	inner join Grupo_Operacao_Fiscal g     on g.cd_grupo_operacao_fiscal = opf.cd_grupo_operacao_fiscal
  where
   -- n.dt_nota_saida between @dt_inicial and @dt_final
--	and
	n.cd_status_nota<>7
	and
	isnull(opf.ic_comercial_operacao,'N')  = 'S'
	and
	IsNull(opf.ic_analise_op_fiscal,'S') = 'S' 
	and
	g.cd_tipo_operacao_fiscal = 2

  group by
     year(n.dt_nota_saida),
	 month(n.dt_nota_saida)
-----------------------------------------------------------------------------------------------------------   
select
  @vl_total = sum(vl_total),
  @qt_total = sum(qt_cliente)

from
  #FaturamentoMensal
-----------------------------------------------------------------------------------------------------------
select
  IDENTITY(int,1,1) as cd_controle,
  f.*,
  pc_faturamento = cast(round(vl_total/@vl_total * 100,2) as decimal(25,2)),
  m.nm_mes

into
  #FinalFaturamentoMensal
from
  #FaturamentoMensal f
  inner join  mes m on m.cd_mes = f.cd_mes
order by
  f.cd_ano desc,
  f.cd_mes
-----------------------------------------------------------------------------------------------------------
--Relatório

if @cd_parametro<> 3
begin

-------------------------------------------montagem do Detalhe---------------------------------------------------------------

declare @id int = 0

set @html_detalhe = '  <div class="textocorpo">
  <div class="section-title"><strong style="display: flex; justify-content:center; align-items:center;"> INSTRUMENTO PARTICULAR DE CONTRATO DE COMODATO</strong></div>
  <p><strong>COMODANTE: GUSTAMAIS INDÚSTRIA E COMÉRCIO VAREJISTA DE SORVETES E SIMILARES-ME, </strong>com sede em Manaus na Av. Desembargador João Machado, nº 7-qdr 03- Conj. Belvedere – planalto- Cep.69044-000, no Estado do Amazonas, inscrita no CNPJ sob nº 14.233.852/0001-33, e no Cadastro Estadual sob o nº 05.331.426-3, neste ato representada por GUSTAVO PICANÇO FEITOZA, Brasileiro, Casado, Empresário, Carteira de Identidade nº 13585452 SSP-AM, CPF sob o nº 683.788.152-34.</p>
  <p><strong></strong></p>
  <p>COMODATÁRIA:<strong>'+isnull(@razaosocial_cliente,'')+'</strong>  sede em <strong>'+isnull(@cidade_cliente,'')+'</strong>, na <strong>'+isnull(@ender_cliente,'') +'</strong>, Bairro: <strong>'+isnull(@bairro_cliente,'')+'</strong> CEP <strong>'+isnull(@cep_cliente,'') +'</strong> no Estado: <strong>'+isnull(@uf_cliente,'')+'</strong>, inscrita no CNPJ sob nº <strong>'+isnull(@cnpj_cliente,0)+'</strong>, no estado: '+isnull(@uf_cliente1,'')+'<strong></strong>.</p>
  <p>As partes acima identificadas têm, entre si, justo e acertado o presente Contrato de Comodato de Freezers, que se regerá pelas cláusulas seguintes e pelas condições descritas no presente.</p> 
  <p><strong>DO OBJETO DO CONTRATO</strong></p>
  <p><strong>Cláusula 1ª.</strong> O presente contrato tem como OBJETO, a transferência, pela COMODANTE à COMODATÁRIA, dos direitos de uso e gozo do(s) item(s) abaixo relacionado(s) conforme Nota Fiscal nº  '+isnull(@num_nota,0)+' de Remessa de Bem por Conta de Contrato de Comodato:</p>
        <table>
          <tr>
            <th>N.Série</th>
            <th>Plaqueta</th>
            <th>Descrição</th>
            <th>Modelo</th>
            <th>MARCA</th>
            <th>Capac.</th>
            <th>Volts</th>
          </tr>
          <tr>
            <td>'+isnull(@item_nota,0)+'</td>
            <td>'+isnull(@cd_produto,0) +'</td>
			<td>'+isnull(@ds_produto,'')+'</td>
            <td>'+ISNULL(@modelo_produto,'')+'</td>
            <td>'+ISNULL(@marca_produto,'')+'</td>
            <td>'+isnull(@voltagem_produto,'')+'</td>
			<td>'+isnull(@capacidade_produto,'')+'</td>
          </tr>
          <tr>
            <td>'+isnull(@item_nota1,0)+'</td>
            <td>'+isnull(@cd_produto1,0) +'</td>
			<td>'+isnull(@ds_produto1,'')+'</td>
            <td>'+ISNULL(@modelo_produto1,'')+'</td>
            <td>'+ISNULL(@marca_produto1,'')+'</td>
            <td>'+isnull(@voltagem_produto1,'')+'</td>
			<td>'+isnull(@capacidade_produto1,'')+'</td>
          </tr>
          <tr>
            <td>'+isnull(@item_nota2,0)+'</td>
            <td>'+isnull(@cd_produto2,0) +'</td>
			<td>'+isnull(@ds_produto2,'')+'</td>
            <td>'+ISNULL(@modelo_produto2,'')+'</td>
            <td>'+ISNULL(@marca_produto2,'')+'</td>
            <td>'+isnull(@voltagem_produto2,'')+'</td>
			<td>'+isnull(@capacidade_produto2,'')+'</td>
          </tr>
        </table>
      
      <p><strong>DO USO</strong></p>
      <p><strong>Cláusula 2ª. O freezer, objeto deste contrato, será utilizado, exclusivamente pela COMODATÁRIA, não sendo cabível seu uso para fins pessoais ou de outros produtos, que não sejam os sorvetes e picolés da marca VACA LAMBEU. Pois os mesmos podem interferir na consistência (derretimento) e no sabor dos produtos.</strong></p>
      <p><strong>DAS OBRIGAÇÕES DA COMODATÁRIA</strong></p>
      <p>Cláusula 3ª.A COMODATÁRIA está obrigada a:</p>
      <p>1.	Observar a Voltagem em que o freezer deve ser colocado: 110v. Caso contrário, assumirá a responsabilidade pelas perdas causadas pela colocação da tomada em outra voltagem que não seja a de 110v;</p>
      <p>2.	Colocar o freezer em local adequado, distante da parede pelo menos 10 centímetros para que ocorra a circulação de ar.</p>
      <p>3.	Comunicar imediatamente à COMODANTE qualquer tipo de defeitos que ocorram no freezer pelos seguintes telefones: (92) 3085-0571 / (92) 98450-1870.</p>
      <p>4.	Utilizar adaptador de tomada, sempre que necessário, não sendo permitido a troca, o dano ou o corte do plug da tomada para substituir por outro;</p>
      <p>5.	Utilizar tomada dedicada ao freezer, a fim de evitar perdas e danos ao equipamento;</p>
      <p>6.	Efetuar compras mensais no valor mínimo de R$ 1.000,00 (Hum Mil Reais);</p>
      
      <p><strong>DAS OBRIGAÇÕES DA COMODANTE</strong></p>
      <p><strong>Cláusula 4ª, A COMODANTE está a:</strong></p>
      <p>1. Efetuar a limpeza interna do freezer uma vez por semana;</p>
      <p>2. Atender aos chamados do qualquer tipo  de problema referente a manutenções corretivas, na maior brevidade possível;</p>
      <p>3. Efetuar as manutenções preventivas nos freezers a cada 6 Meses.</p>

      <p><strong>DA DEVOLUÇÃO</strong></p>
      <p>Cláusula 5ª. A COMODATÁRIA deverá devolver os freezers à COMODANTE quando for por esta solicitada, nas mesmas condições em que estavam quando o recebeu, em perfeitas condições de uso, respondendo pelos danos ou prejuízos causados.</p>
      <p>Cláusula 6ª. A devolução deve se ocorrer no prazo de 5 (cinco) dias após a COMODATÁRIA ter recebido o aviso, que lhe será enviado através do Correio ou entregue pessoalmente devidamente protocolado</p>
      
      <p><strong>DA MULTA</strong></p>
      <P>Cláusula 7ª. A COMODATÁRIA pagará multa no valor de R$ 7.000,00 (Sete Mil Reais), pelo atraso na entrega do freezer ou á não devolução do mesmo;</P>
     
      <p><strong>DA RESCISÃO</strong></p>
      <p>Cláusula 8ª. É assegurada às partes a rescisão do presente contrato a qualquer momento, devendo, entretanto, comunicar à outra parte com antecedência mínima de 5 (cinco) dias </p>
      <p><strong>PARAGRAFO ÚNICO: </strong>Caso a COMODATÁRIA ainda possua produtos no momento da rescisão, não haverá em nenhuma hipótese o reembolso e/ou retirada dos produtos.</p>
      <p>Cláusula 9ª. O descumprimento, pelos contratantes, do disposto nos presentes cláusulas também ensejará a rescisão deste instrumento.</p>
     
      <p><strong>DA DURAÇÃO</strong></p>
      <p>Cláusula 10ª. Este contrato iniciará em '+isnull(@data_nota,'')+' e terá validade por prazo INDETERMINADO caso nenhuma das partes se oponha.</p>  
      
      <p><strong>CONDIÇÕES GERAIS</strong></p>
      <p>Cláusula 11ª. O presente contrato inicia-se a partir da assinatura pelas partes.</p>
      
      <p><strong>DO FORO</strong></p>
      <p>Cláusula 12ª. Para dirimir quaisquer controvérsias oriundas do CONTRATO, as partes elegem o foro da comarca de Manaus;</p>
      <p>Por estarem assim justos e contratados, firmam o presente instrumento, em duas vias de igual teor.</p>

      <p style="text-align: left;margin-top: 50px;margin-bottom: 25px;">'+isnull(@cidade_cliente1,'')+', '+isnull(@dt_mes_ano,'')+'.</p>
      <div class="assinatura">
        <div>
        <p>_____________________________________________________________</p>
        <p style="margin-top: 10px;">GUSTAMAIS IND. E COM. VAREJISTA DE SORVETES E SIMILARES - ME. 14.233.852/0001-33</p>
      </div>
      <div style="margin-top: 80px;">
        <p>_____________________________________________________________</p>
        <p style="margin-top: 10px;">'+isnull(@razaosocial_cliente_rodape,'')+'</p>
        <p style="margin-top: 10px;">'+isnull(@cnpj_cliente1,'')+'</p>
      </div> 
      <br><br>
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
exec pr_egis_relatorio_contrato_comodato_gustamais 182,4253,0,0,''
------------------------------------------------------------------------------
--text: (ctx) => "Point Style: " + ctx.chart.data.datasets[0].pointStyle, ( texto no título )
--select * from parametro_relatorio

