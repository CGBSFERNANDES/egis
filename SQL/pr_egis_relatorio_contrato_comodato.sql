IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_contrato_comodato' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_contrato_comodato

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_faturamento_mensal
-------------------------------------------------------------------------------
--pr_egis_relatorio_faturamento_mensal
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 24.08.2024
--Alteração        : 23.12.2024 - Ajustado o parametro de documento. Kelvin Viana
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_contrato_comodato
@cd_relatorio int   = 0,
@cd_usuario   int   = 0,
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
declare @cd_documento           int = 0
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
        
select * into #auxnota   from #nota        
select * into #auxnota2  from #nota        
        
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
         
        
 --select top 1 * from #Nota       
 --order by cd_item_nota_saida  

 select top 1 
			  @descricao_produto = DESC_PRODUTO, 
              @valor_produto = VALOR_PRODUTO,
			  @bairro_cliente = BAIRRO_CLIENTE,
			  @razaosocial_cliente = RAZAOSOCIAL_CLIENTE,
			  @cnpj_cliente = CNPJ_CLIENTE,
			  @ender_cliente = ENDER_CLIENTE,
			  @cidade_cliente = CIDADE_CLIENTE,
			  @uf_cliente = UF_CLIENTE,
			  @cep_cliente = CEP_CLIENTE,
			  @razaosocial_cliente_rodape = RAZAOSOCIAL_CLIENTE_RODAPE,
			  @dt_mes_ano =  DT_MES_ANO,
			  @num_nota = NUM_NOTA,
			  @ano_nota = ANO_NOTA

 from #Nota
 
 
 



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
   
select
  @vl_total = sum(vl_total),
  @qt_total = sum(qt_cliente)

from
  #FaturamentoMensal

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


--Relatório

if @cd_parametro<> 3
begin


  ---------------------------------------------------------------------------------------------------------------------------

  ----montagem do Detalhe-----------------------------------------------------------------------------------------------

  ---------------------------------------------------------------------------------------------------------------------------
 
--<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_data_string(dt_pedido_venda)+'</td>

declare @id int = 0

set @html_detalhe = '
      <div class="textocorpo">
		<div class="section-title"><strong style="display: flex; justify-content:center; align-items:center;"> INSTRUMENTO
            PARTICULAR DE CONTRATO DE COMODATO DE BENS MÓVEIS Nº '+ isnull(@ano_nota,'')+' / '+isnull(@ano_nota,'') +' 
	  </strong></div>
	
	  <div style="display: flex; justify-content: center; align-items:center;">
         <p>  Pelo presente instrumento particular de comodato, de um lado na qualidade de COMODANTE: CISNEROS ICE COMERCIO E 
             DISTRIBUIDORA DE SORVETES LTDA CNPJ: 14.810.875-0001-63, empresa estabelecida na Rua Abaúna, nº. 38, Bairro: Moinho Velho,  Município: São Paulo, 
             Estado de São Paulo, CEP; 04282-080, e-mail: moema@icebynice.com.br, Telefone/WhatsApp: (11) 94763-5368, neste ato representada por seu sócio administrador,
              SERGIO RICARDOTEZZEI PEREIRA CISNEROS, brasileiro, empresário , portador da cédula de identidade RG:28.399850-7  do CPF: 166.190.338-06; e, de outro lado, 
              na qualidade de COMODATÁRIA '+ isnull(@razaosocial_cliente, '') +' inscrito no CNPJ/CPF: '+ isnull(@cnpj_cliente,'') +' - '+ isnull(@ender_cliente,'') +' - Bairro '+isnull(@bairro_cliente,'') +
			  ' - Município: '+ isnull(@cidade_cliente,'') +' -'+ isnull(@uf_cliente,'') +' CEP: '+ isnull(@cep_cliente,'') +'.
              
         </p> 
      </div>

		<br>
      <div class="section-title"><strong> Cláusula Primeira: Do Objeto </strong></div>
         <p>Constitui objeto da presente avença um equipamento destinado ao acondicionamento e armazenamento de sorvetes, 
            aqui denominado simplesmente “CONSERVADORA”, cujo nome e características são as seguintes: 1 (um)'+ isnull(@descricao_produto,'') +'</p>           
            
         <p>I- As partes, estipulam para a presente data, o valor de R$ '+ isnull(@valor_produto, '') +' a título de reposição da respectiva “CONSERVADORA” em caso de mau uso ou
            perecimento, valor este a ser atualizado na data de eventual ocorrência, nos termos do inciso II da cláusula quarta do presente 
            instrumento.</p>
            
            
      <div class="section-title"><strong> Cláusula Segunda: Do Uso </strong></div>
         <p>A COMODATÁRIA recebe da COMODANTE, quando da assinatura do presente instrumento, a “CONSERVADORA” em perfeito estado de uso e conservação, 
            comprometendo-se a utilizá-la exclusivamente para acondicionar e armazenar os produtos fabricados e fornecidos pela COMODANTE, 
            com o intuito exclusivo de expô-los à venda em seu estabelecimento comercial. </p>

         <p>I - À COMODATÁRIA, é expressamente proibida a transferência, empréstimo da” CONSERVADORA”, a qualquer título a terceiros ou a sua 
            remoção para endereço diverso de onde foi instalada, ainda que em caráter temporário/provisório.</p>
      
	  <div class="section-title"><strong> Cláusula Terceira: Das Obrigações da COMODATÁRIA </strong></div>
      
		<p> I - Manter a “CONSERVADORA” em perfeito estado de uso e conservação, respeitando as orientações contidas no manual do usuário fornecido pelo fabricante;</p>

        <p> II- Não acondicionar ou armazenar, na “CONSERVADORA”, produtos outros que não sejam os produtos fabricados e/ou fornecidos pela COMODANTE;</p>
         
        <p> III- Proceder, periodicamente, à remoção de excesso de gelo acumulado na “CONSERVADORA”, mantendo-a sempre limpa e em condições de higiene compatíveis com 
            as exigências da vigilância sanitária; </p>
            
        <p> IV- Manter sempre ligadas (durante o expediente) as luzes dos equipamentos que possuírem dispositivo “BACK LIGHT”;</p>

        <p> V- Permitir o acesso, às dependências onde se encontre instalada a “CONSERVADORA”, dos funcionários ou prepostos da COMODANTE para que possam efetuarem a
             vistoria e fiscalização quanto ao uso e limpeza da “CONSERVADORA” e coleta de amostras dos produtos expostos e armazenados na mesma para fins de controle 
             de qualidade;</p>

        <p> VI- Não permitir em hipótese alguma, que terceiros, não autorizados pela COMODANTE, procedam modificação, adaptação ou alteração na “CONSERVADORA”. 
            Quaisquer reparos, consertos, alterações ou substituições que se façam necessários ao bom funcionamento da “CONSERVADORA” deverão ser previamente solicitados
             por escrito à COMODANTE, que por sua vez, deverá autorizar expressamente;</p>

         <p> VII- Não realizar ou permitir que se realizem modificações estéticas na “CONSERVADORA”, de modo a suprimir inscrições, desenhos, logotipos identificadores 
            da marca dos produtos da COMODANTE, chapas ou números de identificação;</p>
         
		 <p> VIII- Comunicar no prazo improrrogável de 2 (dois) dias e por escrito à COMODANTE, quaisquer medidas judiciais ou extrajudiciais, que importem ou possam 
            importar no arresto, sequestro ou penhora da “CONSERVADORA”. Caso venha a ser compelida a manifestar-se perante as autoridades administrativas ou judiciais,
             fica obrigada a COMODATÁRIA a informar expressamente que a “CONSERVADORA” é de propriedade da COMODANTE;</p>

        <p> IX- Retirar imediatamente de venda ao público consumidor, eventuais produtos que venham a sofrer deterioração ou modificação de suas propriedades, 
            em virtude do mal funcionamento da “CONSERVADORA”, sendo certo que, os prejuízos advindos dos acontecimentos descritos, serão suportados exclusivamente pela COMODATÁRIA,
            exceto se a COMODATÁRIA tenha efetuado nos últimos 90 (noventa) dias contados do perecimento dos produtos, a compra da quantidade mínima descrita no inciso II da 
            cláusula quinta, quando então gozará do benefício da troca dos produtos deteriorados, desde que, seja constatado que a “CONSERVADORA” tenha parado de funcionar, 
            especificamente por defeito técnico do próprio equipamento;</p>

        <p> X- Responsabilizar-se, exclusivamente, por eventuais danos causados aos consumidores, caso não venha a praticar a conduta descrita no item IX da presente 
            cláusula, ainda que por defeito técnico da “CONSERVADORA”;</p>

         <p>   XI- Arcar com todas as custas e despesas, inclusive honorários advocatícios, em que possa incorrer a COMODANTE, caso esta tenha que intervir em processos
            judiciais ou administrativos onde o objeto da lide seja a “CONSERVADORA” e a parte envolvida seja a própria COMODATÁRIA;</p>

        <p>    XII- Comunicar por escrito à COMODANTE, no prazo improrrogável de 5 (cinco) dias, quaisquer alterações societárias efetuadas na empresa COMODATÁRIA, 
            tais como: cessão, sucessão, transferência da sede do estabelecimento, dentre outras;</p>

         <p>   XIII- Indenizar a COMODANTE, pelo valor de mercado atualizado da “CONSERVADORA”, caso haja destruição ou inutilização da mesma motivada por roubo, furto, 
            extravio, caso fortuito ou força maior;</p>

         <p>   XIIII- Não seremos responsáveis pelos produtos deteriorados ou derretidos quando o cliente ficar sem comprar a mais de 90 dias e o freezer vier a 
            parar de funcionar por qualquer que seja o motivo.</p>
         

		<div class="section-title"><strong> Cláusula Quarta: Da Devolução da “CONSERVADORA”</strong></div>
       <p>
         I- A COMODATÁRIA deverá restituir a “CONSERVADORA” à COMODANTE, no prazo máximo de 5 (cinco) dias úteis a contar da data do recebimento do comunicado exigindo a
          sua devolução, e a partir de então, a COMODANTE terá o prazo de até 30 (trinta) dias para a efetiva retirada da “CONSERVADORA” do estabelecimento da 
          COMODATÁRIA;
       </p>
       <p>
            II- A não restituição da “CONSERVADORA”, no prazo estabelecido no item I da presente cláusula, ensejará a cobrança de multa no valor de R$ 20,00 (vinte reais)
             por dia de atraso, sem prejuízo do valor de reposição estipulado pelas partes no inciso I da cláusula primeira do presente instrumento, 
             devidamente atualizado ao preço atual de mercado, em casos de mau uso e perecimento da “CONSERVADORA”, que a torne inutilizável e irreparável.
       </p>

	   <div class="section-title"><strong> Cláusula Quinta: Das Condições Comerciais </strong></div>

	   <p> O presente comodato da “CONSERVADORA” está condicionado as seguintes condições comerciais impostas ao COMODATÁRIO, sem prejuízo de outras tratadas por instrumento próprio entre as partes:</p>

	   <p> I- O COMODATÁRIO deverá adquirir inicialmente, o denominado “1º Enxoval”, que consiste na compra mínima de produtos fornecidos pela COMODANTE de acordo com as capacidades das 
	   Conservadoras escolhidas, conforme abaixo:
		<ul>
				<li>Conservadora de 80 cm - pedido mínimo de 15 (quinze) caixas de produtos.</li>
				<li>Conservadora de 105 cm - pedido mínimo de 20 (vinte) caixas de produtos.</li>
				<li>Conservadora de 112 cm - pedido mínimo de 25 (vinte e cinco) caixas de produtos.</li>
				<li>Conservadora de 125 cm - pedido mínimo de 30 (trinta) caixas de produtos.</li>
		</ul>
	   </p>


		<p>
			II – Não obstante a compra do referido “1º Enxoval”, deverá o COMODATÁRIO, no prazo máximo de 90 (noventa) dias, contados da assinatura do presente contrato, começar a adquirir 
			mensalmente (enquanto vigorar o contrato), a quantidade mínima de 5 (cinco) caixas de produtos da COMODANTE ou, o equivalente à R$ 700,00 (setecentos reais) 
		    por pedido mensal com correções anuais pelo IPCA, salvo se expressamente acordado de forma diversa com o representante da COMODANTE.
		</p>
		
		<p>
			III- Se, porventura, o COMODATÁRIO não cumprir mensalmente, após a carência de 90 dias, as quantidades estipuladas no inciso II anterior, ensejará em violação comercial e, assim sendo,
			consequentemente, acarretará na retirada da Conservadora, bem como na obrigação de pagamento de multa para reparos e custos, envolvendo: frete, instalação, manutenção e trocas de adesivos
			da “CONSERVADORA”, equivalente ao valor de 30% (trinta por cento) do gasto com o 1º Enxoval adquirido pelo COMODATÁRIO. Tal multa poderá ser cobrada imediatamente pela COMODANTE, 
			após apuração das compras mínimas mensais exigidas, nos exatos termos do inciso II acima.  

		</p>

		<p>
			IV- Para não haver rescisão contratual ou taxa de destrato, fica de responsabilidade do COMODATÁRIO transferir o freezer para outra unidade em até 30 dias, enviando novos dados cadastrais
			para atualização do nosso sistema. Caso não consigam remanejar será cobrada a taxa de frete de 300,00 para pagamento de um prestador de serviço.
		</p>
		<p>
			V- 0 COMODATÁRIO só poderá desistir da permanência do freezer, caso atinja um volume de 96 caixas compradas.
		</p>

		<div class="section-title"><strong> Cláusula Sexta: Do Preço, Forma de Pagamento e Bonificações</strong></div>

		<p>
		I - A COMODANTE se reserva o direito de alterar, a qualquer tempo, o preço de seus Produtos, bem como o valor ou condições da bonificação aqui fixada, devendo, no entanto, 
		comunicar a COMODATÁRIA a respeito, com antecedência mínima de 30 (trinta) dias.
		</p>
		
		<div class="section-title"><strong> Cláusula Sétima: Da Rescisão</strong></div>

		<p>
			O presente contrato, é firmado por prazo indeterminado e sob a condição da COMODATARIA alcançar os volumes mensais de compra de produtos da COMODANTE, os quais restam estipulados 
			no inciso II da clausula quinta, devendo obedecer aos seguintes critérios:
		</p>
		<p>
			I- A apuração do atingimento desse volume mensal de compra por parte do COMODATÁRIO, será feita de forma trimestral pela COMODANTE	, considerando a data do contrato; 	
		</p>
		<p>
			II- O não cumprimento do volume tratado nos incisos I e II da cláusula quinta,  poderá, a exclusivo critério da COMODANTE, implicar na possibilidade de rescisão imediata deste contrato 
			sem o respectivo aviso prévio previsto na cláusula sétima, com a consequente retirada da “CONSERVADORA”, sem prejuízo da cobrança da multa prevista no inciso III da mesma cláusula quinta 
			pela violação comercial havida, restando assim à COMODATÁRIA, a obrigação de devolvê-la nos termos do inciso I da cláusula quarta e, ainda, em perfeito estado de conservação à COMODANTE, 
			sob pena de arcar com o valor de reposição, estipulado pelas partes no inciso I da cláusula primeira do presente instrumento, devidamente atualizado ao preço atual de mercado.
		</p>
		
		<div class="section-title"><strong> Cláusula Nona: Do Relacionamento Entre as Partes</strong></div>
		<p>
		    Fica expressamente estabelecido que este Contrato não implica a formação de qualquer relação ou vínculo empregatício entre a COMODANTE e a COMODATÁRIA ou entre a COMODANTE e qualquer 
			funcionário da COMODATÁRIA, permanecendo a COMODANTE livre de qualquer responsabilidade ou obrigação trabalhista ou previdenciária, direita ou indireta, com relação à COMODATÁRIA e aos 
			empregados desta.

		</p>
		<p>
		 I - Cada parte será exclusivamente responsável pelo pagamento de toda a remuneração devida aos seus respectivos funcionários, bem como dos correspondentes encargos fiscais, trabalhistas,
		 previdenciários e securitários.
		</p>

		<p>
			II - A COMODATÁRIA será a única e exclusiva responsável por quaisquer reclamações e/ou ações movidas por seus empregados, devendo manter a COMODANTE isenta de toda e qualquer 
			responsabilidade relativa e/ou decorrente de tais reclamações e/ou ações. Não obstante, na hipótese de a COMODANTE, por qualquer razão, vir a ser demandada judicialmente por empregados 
			da COMODATÁRIA, a COMODATÁRIA desde já concorda e se compromete a comparecer espontaneamente em juízo, reconhecendo sua condição de única e exclusiva empregadora, bem como a fornecer à 
			COMODANTE toda e qualquer documentação solicitada por esta, que seja necessária para garantir a adequada e ampla defesa da COMODANTE em juízo.	 
		</p>

		<div class="section-title"><strong>Cláusula Décima: Das Disposições Finais</strong></div>
		<p>
		Qualquer omissão ou tolerância das partes em exigir o fiel cumprimento dos termos e condições deste Contrato não constituirá novação ou renúncia, nem afetará o direito da parte de exigir 
		seu cumprimento a qualquer tempo.
		</p>
		<p>
		I - As partes declaram expressamente que não empregam e/ou utilizam, e se obrigam a não empregar e/ou utilizar, durante o prazo de vigência do presente Contrato, mão-de-obra infantil na 
		prestação dos seus serviços, bem como também não contratam e/ou mantêm relações com quaisquer outras empresas que lhe prestem serviços (parceiros, fornecedores e/ou subcontratados) que utilizem,
		explorem e/ou por qualquer meio ou forma empreguem o trabalho infantil, nos termos previstos no ECA – Estatuto da Criança e do Adolescente, Lei  nº 8.069/90 e demais 
		normas legais e/ou regulamentares em vigor.
		</p>
		<p>
		II - Este Contrato constitui o acordo integral das partes com relação ao objeto aqui tratado, prevalecendo sobre qualquer outro documento por elas anteriormente firmado a esse respeito.
		Quaisquer documentos, compromissos ou avenças anteriores referentes ao objeto deste Contrato, quer sejam verbais, escritos ou de outra natureza, serão considerados superados e não afetarão
		ou modificarão quaisquer dos termos ou obrigações estabelecidos neste instrumento.
		</p>
		<p>
		III - Eventual declaração de nulidade, invalidade ou ilegalidade de qualquer disposição deste Contrato não afetará a validade, legalidade e exequibilidade das disposições remanescentes, 
		que deverão permanecer em pleno vigor e efeito.

		</p>
		<p>
		IV – Toda e qualquer comunicação e/ou notificação encaminhadas nos endereços eletrônicos “e-mail” e/ou “WhatsApp” fornecidos no preâmbulo do presente contrato, serão consideradas validas
		e recebidas por ambas as partes, para todos os efeitos legais e jurídicos.
		</p>
		<div class="section-title"><strong>Cláusula Décima Primeira: Do Foro</strong></div>
		<p>
		Para dirimir quaisquer questões oriundas sobre o presente contrato fica eleito o Foro Regional do Ipiranga, Comarca da Cidade de São Paulo /SP, com exclusão de quaisquer outros, ainda que 
		privilegiados.
		</p>
		<p>
		E por estarem justas e contratadas, as Partes estabelecem que este instrumento será assinado (i) em duas vias de igual teor e forma, juntamente com as duas testemunhas adiante assinadas,
		ou (ii) eletronicamente, seguindo às disposições da Medida Provisória 2.200-2 de 24 de agosto de 2001.
		</p>
		<br><br>
		<p style="text-align: center; margin:50px">São Paulo,'+ isnull(@dt_mes_ano,'') +' </p>
        <br> <br>
        <div class="assinatura">           
                <br> <br>
        
        <div style="width: 50%;">
            <div>
                <table style="width:100%;  height: 55px;">
                    <tr>
                        <td>______________________________________</td>
                        <td>______________________________________</td>
                    </tr>
                    <tr>
                        <td>'+isnull(@razaosocial_cliente_rodape,'') +' </td>
                        <td>CISNEROS ICE COMERCIO E DISTRIBUIDORA DE SORVETES LTDA</td>
                    </tr>
                    <tr>
                        <td>CNPJ/CPF:'+isnull(@cnpj_cliente,'')+'</td>
                        <td>CNPJ: 14.810.875-0001-63</td>
                    </tr>
                </table>
            </div> <br>
            <p style="text-align: center; margin-bottom: 10px;">Testemunhas</p>
             <div>
          <table style="width:100%;  height: 55px;">
            <tr>
              <td>Nome:_____________________________</td>
              <td>Nome:_____________________________</td>
            </tr>
            <tr>
              <td>RG:________________________________</td>
              <td>RG_________________________________</td>
            </tr>
            <tr>
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

--Json Enviado pelo Egismob
--exec pr_egis_relatorio_padrao '[{"cd_documento": 454258, "cd_empresa": 317, "cd_item_processo": 0, "cd_menu": 5428, "cd_modulo": 239, "cd_parametro": 182, "cd_processo": 0, "cd_relatorio": 182, "cd_usuario": 4254}]'


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--Relatório
--exec pr_egis_relatorio_faturamento_mensal 178,4253,0,''
------------------------------------------------------------------------------
--Gráfico
exec pr_egis_relatorio_contrato_comodato 182,4253,0,''
------------------------------------------------------------------------------
--text: (ctx) => "Point Style: " + ctx.chart.data.datasets[0].pointStyle, ( texto no título )
--select * from parametro_relatorio

