IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_contrato_comodato_milkmoni' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_contrato_comodato_milkmoni

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_contrato_comodato_teste
-------------------------------------------------------------------------------
--pr_egis_relatorio_contrato_comodato_teste
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
create procedure pr_egis_relatorio_contrato_comodato_milkmoni
@cd_relatorio int   = 0,
@cd_usuario   int   = 0,
@cd_documento int   = 0, 
@cd_parametro int   = 0,
@json nvarchar(max) = '' 


--with encryption
--use egissql_317

as

set @json = isnull(@json,'')

declare @cd_modulo              int = 0
declare @cd_menu                int = 0
declare @cd_processo            int = 0
declare @cd_item_processo       int = 0
declare @cd_form                int = 0
--declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
--declare @cd_documento           int = 0
declare @cd_empresa             int = 0
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
			@ds_produto                 nvarchar(100),
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
  --select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     
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
   ns.cd_pedido_venda = @cd_documento --10062 
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
 declare @ie_cliente nvarchar(100)
 declare @cnpj_cliente1 NVARCHAR(20)
 select top 1 
			  @ds_produto = DESC_PRODUTO, 
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
			  @ano_nota = ANO_NOTA,
			  @ie_cliente = IE_CLIENTE,
			  @cnpj_cliente1 = CNPJ_CLIENTE1

 from #Nota
 
 
-----------------------------------------------------------------------------------------------------------


if @cd_parametro<> 3
begin

-------------------------------------------montagem do Detalhe---------------------------------------------------------------

declare @id int = 0

set @html_detalhe = '  <div class="textocorpo">
    <div class="section-title"><strong style="display: flex; justify-content:center; align-items:center;">INSTRUMENTO PARTICULAR DE CONTRATO DE COMODATO DE BEM MÓVEL E OUTRAS AVENÇAS Nº '+cast(isnull(@num_nota,0)as nvarchar(12))+' / '+cast(isnull(@ano_nota,0)as nvarchar(10))+'</strong></div>
    <div>
     <p>São signatários do presente instrumento particular:</p>
     <p>ANA MARIA RAMOS DE SOUZA & CIA. LTDA., pessoa jurídica de direito privado, devidamente inscrita no CNPJ/MF sob nº 67.196.949/0001-80, 
       com sede na Rua Alan Kardec, 246, Jardim Progresso, CEP 13.876-080, no município de São João da Boa Vista, Estado de São Paulo, 
       devidamente representada, na forma dos seus atos societários, pelos representantes legais abaixo assinados, 
       doravante denominada COMODANTE; e de outro lado</p>
      <p>'+isnull(@razaosocial_cliente,'')+', inscrito no CNPJ/CPF: '+cast(isnull(@cnpj_cliente,'') as nvarchar(20))+' IE: '+CAST(isnull(@ie_cliente,'') as nvarchar(20))+' com sede na '+cast(isnull(@ender_cliente,'')as nvarchar(100))+' – Bairro: '+cast(isnull(@bairro_cliente,'') as nvarchar(50))+' 
        – Município : '+isnull(@cidade_cliente,'')+' – '+cast(isnull(@uf_cliente,'') as nvarchar(30))+' CEP: '+cast(isnull(@cep_cliente,0) as nvarchar(15))+', doravante denominada COMODATÁRIA.
      </p> 
      <p>
      Considerando que a COMODANTE é uma empresa que fabrica e comercializa sorvetes e outros gelados comestíveis da marca “Milk Moni” em todo o território nacional;
      </p>
       <p>
        Considerando que as partes mantêm uma relação comercial, por meio da qual a COMODATÁRIA adquire, da COMODANTE, produtos para a revenda a consumidores no seu comércio; 
       </p>  
       <p>
        Considerando que em decorrência da mencionada relação comercial, a COMODANTE, por via deste instrumento, concordou em emprestar à COMODATÁRIA, a título de comodato, equipamentos de sua propriedade, como forma de atender ao interesse comum das partes de estimular a comercialização dos produtos fabricados e vendidos pela COMODANTE, mediante a sua exposição para consumo imediato e a associação do negócio da COMODATÁRIA à marca da COMODANTE; 
       </p>
       <p>
        Resolvem ajustar o presente Instrumento Particular de Contrato de Comodato de Bem Móvel e Outras Avenças, mediante as cláusulas e condições abaixo estabelecidas.
       </p>
    </div> <br>
    <div class="section-title"><strong> Do Objeto </strong></div>
    <p><strong>CLÁUSULA PRIMEIRA – A COMODANTE</strong>, por este ato, cede gratuitamente e sem ônus à COMODATÁRIA a posse de 01 (um) '+isnull(@ds_produto,'')+' acompanhado de 01 (uma) haste, de sua propriedade, identificado através da plaqueta de patrimônio nº 000542, em estado de novo e em perfeito funcionamento. </p>
    <p><strong>CLÁUSULA SEGUNDA – A COMODATÁRIA </strong>obriga-se a destinar o equipamento, exclusivamente, para a arrumação, exposição e comercialização dos produtos adquiridos diretamente da COMODANTE (ou de quem a COMODANTE indicar), sob pena de responder perante a COMODANTE por perdas e danos.</p>
    <p><strong>CLÁUSULA TERCEIRA – </strong>O equipamento será instalado no local estabelecido pelas partes de comum acordo no estabelecimento da COMODATÁRIA, e não poderá sofrer qualquer tipo de movimentação sem o prévio e expresso acordo das partes.</p>
    <p><strong>CLÁUSULA QUARTA – A COMODATÁRIA </strong>declara-se, ainda, totalmente ciente de que:</p>
    <p>(i) Neste ato, está contratando o mero empréstimo do equipamento descrito na cláusula primeira;</p>
    <p>(ii) Este instrumento, em hipótese alguma, transfere a propriedade do freezer conservador de sorvetes à COMODATÁRIA, que permanecerá de propriedade da COMODANTE para todos os efeitos;</p>
    <p>(iii) O freezer conservador de sorvetes deverá ser prontamente devolvido à COMODANTE, quando assim requerido, mediante comunicação simples, nos termos deste instrumento, sob pena de incidir, em face da COMODATÁRIA, a mora e os encargos dela decorrentes e previstos neste instrumento; e</p>
    <p>(iv) A resistência ou embaraço, por parte da COMODATÁRIA, ao acesso da COMODANTE ao freezer conservador de sorvetes, por si ou por pessoas autorizadas, caracterizará a apropriação indébita do referido bem, sujeitando o infrator às cominações legais previstas no Código Penal, além das sanções legais aplicáveis ao depositário infiel.</p>
    
    <div class="section-title"><strong>DO PRAZO</strong></div>
    <p><strong>CLÁUSULA QUINTA – </strong>Este contrato vigorará pelo prazo de 48 (quarenta e oito) meses, a contar da data de sua assinatura.</p>
    <p><strong>CLÁUSULA SEXTA – </strong>O término da vigência deste instrumento implicará a automática extinção do mesmo, não havendo que se falar em renovação automática.</p>
    <p><strong>CLÁUSULA SÉTIMA – </strong>Não obstante o disposto na cláusula sexta, as partes poderão pactuar a renovação contratual a cada ciclo de 48 (quarenta e oito) meses, exclusivamente mediante a assinatura de um novo instrumento.</p>
    
    <div class="section-title"><strong> DAS OBRIGAÇÕES DA COMODATÁRIA </strong></div>
    <p><strong>CLÁUSULA OITAVA – A COMODATÁRIA </strong>deverá guardar e zelar pelo freezer conservador de sorvetes, para que o mesmo permaneça em boas condições de conservação e funcionamento, devendo comunicar a COMODANTE sempre que houver a necessidade de manutenção ou outras providências necessárias ao adequado funcionamento do mesmo, o que deverá ser feito no menor prazo possível, a fim de evitar a perda dos produtos adquiridos da COMODANTE e ali armazenados./p>
    <p><strong>Parágrafo primeiro – </strong>O freezer conservador, durante todo o prazo de vigência deste instrumento, deverá permanecer ligado em tomada compatível, de acordo com a voltagem estabelecida no imóvel e com a instalação realizada pelo representante da COMODANTE. Caso a COMODATÁRIA realize o desligamento ou a troca do local de instalação do freezer conservador sem prévia autorização da COMODANTE, arcará com todo e qualquer dano no equipamento, bem como todo e qualquer prejuízo que venha a ser causado em razão disso, inclusive a perda de produtos. </p>
    <p><strong>Parágrafo segundo – </strong>Também será de exclusiva responsabilidade da COMODATÁRIA, todo e qualquer dano ocasionado no freezer conservador, bem como todo e qualquer prejuízo que venha a ser causado em razão de atos de terceiros, fenômenos naturais, quedas de energia, dentre outros.</p>
    <p><strong>Parágrafo terceiro – </strong>Em razão do disposto na presente cláusula, a COMODATÁRIA e o signatário desde já autorizam a COMODANTE a emitir contra eles um boleto bancário em valor equivalente às despesas para conserto do freezer conservador; ou, em havendo a sua perda total, em quantia equivalente a 100% (cem por cento) do valor de mercado de bem semelhante, a título de ressarcimento por perdas e danos, ficando a COMODATÁRIA, assim como o signatário, sujeitos às medidas judiciais e extrajudiciais cabíveis, incluindo a inscrição do seu nome em órgãos de restrição de crédito.</p>
    <p><strong>CLÁUSULA NONA – A COMODATÁRIA </strong>compromete-se a guardar e conservar o freezer conservador de sorvetes, na condição de fiel depositária, suportando o ônus respectivo, defendendo a sua posse perante terceiros, protegendo-o contra a incidência de qualquer gravame, abstendo-se de aluga-lo ou emprestá-lo, respondendo pela perda ou por qualquer dano causado ao mesmo, independentemente da verificação de culpa ou dolo, mesmo em caso fortuito ou força maior.</p>
    <p><strong>CLÁUSULA DÉCIMA – A COMODATÁRIA</strong>obriga-se a se abster, por si, seus prepostos ou terceiros, de modificar, adaptar e/ou fazer quaisquer alterações no freezer conservador de sorvetes, visando a omitir ou inutilizar quaisquer inscrições, desenhos, chapas ou números de identificação, ou consentir que o façam, bem como de permitir que nele se façam manutenções ou reparos não autorizados pela COMODANTE.</p>
    <p><strong>CLÁUSULA DÉCIMA PRIMEIRA – A COMODATÁRIA </strong>avisará à COMODANTE, no menor prazo possível a ameaça de penhora, sequestro arresto ou qualquer outra forma de constrição do freezer conservador de sorvetes, devendo a COMODATÁRIA envidar seus melhores esforços para informar e comprovar, a quem de direito, que referidos equipamentos são de propriedade exclusiva da COMODANTE, apresentando este instrumento particular, para tal comprovação.</p>
    <p><strong>CLÁUSULA DÉCIMA SEGUNDA – A COMODATÁRIA </strong>compromete-se a permitir aos prepostos da COMODANTE o acesso irrestrito ao freezer conservador de sorvetes, para realização de manutenção preventiva ou corretiva, inspeção ou retirada do seu estabelecimento.</p>
    <p><strong>CLÁUSULA DÉCIMA TERCEIRA – A COMODATÁRIA </strong>não poderá alienar, vender, gravar ou onerar o freezer conservador de sorvete, e declara-se ciente de que o desvio da finalidade e a apropriação indevida do referido equipamento constituem condutas tipificadas como crimes no Código Penal Brasileiro, sujeitando o infrator às correspondentes cominações legais.</p>
    <p><strong>CLÁUSULA DÉCIMA QUARTA – </strong>Não poderá a COMODATÁRIA, em hipótese alguma e durante todo o período deste contrato, utilizar o freezer conservador de sorvetes para armazenar, expor, vender ou usar, de qualquer outra forma, quaisquer produtos que não os produtos da marca MILK MONI da COMODANTE, nem dar ao referido equipamento qualquer destinação diferente da prevista neste instrumento.</p>
    <p><strong>CLÁUSULA DÉCIMA QUINTA – A COMODATÁRIA </strong>se obriga a não armazenar, vender, expor à venda, nem disponibilizar, a qualquer título, produtos com prazo de validade vencido e nem produtos avariados, ou que, por qualquer razão, tenham se tornado impróprios para o consumo.</p>
    <p><strong>Parágrafo único –</strong>Em caso de descumprimento do disposto nesta cláusula, a COMODATÁRIA desde já autoriza que a COMODANTE promova o recolhimento dos produtos nessa situação, sem direito a restituição ou qualquer tipo de indenização, por apresentar risco à saúde e macular a imagem da COMODANTE.</p>
    <p><strong>CLÁUSULA DÉCIMA SEXTA – A COMODATÁRIA</strong>deverá comunicar previamente à COMODANTE qualquer mudança ou transferência de endereço comercial, ou mesmo encerramento de atividades, para que seja formalizada a nova situação do freezer conservador de sorvetes mediante a celebração de aditivo ao presente instrumento, sendo, no entanto, facultado à COMODANTE rescindir imediatamente o contrato em razão dessa alteração.</p>
    <p><strong>Parágrafo único – </strong>No caso de venda ou transferência de titularidade do estabelecimento da COMODATÁRIA, esta se obriga a notificar previamente a COMODANTE, bem como noticiar a existência deste instrumento aos novos adquirentes, para elaboração de novo contrato ou aditivo sendo, no entanto, facultado à COMODANTE rescindir imediatamente o contrato em razão dessa alteração. </p>
  
    <div class="section-title"><strong>DAS OBRIGAÇÕES DA COMODANTE </strong></div>
    <p><strong>CLÁUSULA DÉCIMA SÉTIMA – A COMODANTE </strong>se obriga a entregar o freezer conservador de sorvetes, em perfeito estado de conservação e manutenção, no ato da assinatura do presente instrumento. A efetiva entrega do equipamento mencionado será comprovada mediante assinatura do anexo “Termo de Entrega e Vistoria”, com nome legível, número do CPF/MF e número de identidade – RG do recebedor, que fica fazendo parte deste instrumento, sendo certo que, ao recebedor do equipamento, se aplicará a disposição contida na cláusula quadragésima quinta.</p>
    <p><strong>CLÁUSULA DÉCIMA OITAVA – A COMODANTE </strong>arcará com quaisquer custos, despesas e/ou encargos relacionados a manutenções, movimentações, descarte, dentre outros que venham a incidir sobre o freezer conservador de sorvetes, durante o prazo de vigência do presente instrumento, com exceção das dispostas nas cláusulas constantes do item “Das Obrigações da Comodatária”. </p>
    <p><strong>CLÁUSULA DÉCIMA NONA – </strong>Em havendo necessidade, por motivos de ordem técnica, de substituição do freezer conservador de sorvetes, a COMODANTE realizará a sua substituição, sendo que, para perfeita caracterização do objeto dado em comodato, prevalecerá a descrição constante no último “Termo de Entrega e Vistoria”, permanecendo em vigor a totalidade das cláusulas e condições convencionadas neste instrumento.</p>
    
    <div class="section-title"><strong>DAS HIPÓTESES DE EXTINÇÃO E DAS PENALIDADES</strong></div>
    <p><strong>CLÁUSULA VIGÉSIMA – </strong>Este instrumento poderá ser extinto nas seguintes hipóteses:</p>
    <p>(i) Decurso do prazo de vigência;</p>
    <p>(ii) Denúncia ou resilição contratual por qualquer das partes, a qualquer tempo e independentemente de motivo, o que deverá ser feito mediante notificação escrita à contraparte, nesse sentido, com antecedência mínimo de 05 (cinco) dias, em cujo período as obrigações contratuais deverão ser cumpridas integralmente, conferindo à contraparte direito à indenização no importe de 30% (trinta) por cento sobre o valor total das compras efetuadas nos últimos 02 (dois) meses, obedecendo o valor mínimo a ser indenizado a quantia de R$ 3.500,00 (três mil e quinhentos reais). Caso a denúncia ou resilição contratual ocorra por parte da COMODATÁRIA, além da multa mencionada, esta deverá restituir à COMODANTE o valor concedido a título de bonificação no ato da primeira aquisição de mercadorias, que ocorre concomitantemente à entrega do freezer conservador de sorvetes, no valor de R$ 3.000,00 (três mil reais), devidamente atualizado pelo IGPM – Índice Geral de Preços de Mercado, mediante a emissão de boleto pela COMODANTE, com o que a COMODATÁRIA concorda e autoriza desde já.</p>
    <p>(iii) A existência de pedido de falência, de recuperação judicial e/ou, ainda, dissolução de qualquer das partes; ou</p>
    <p>(iv) Rescisão contratual nos termos da cláusula vigésima primeira.</p>
    <p><strong>CLÁUSULA VIGÉSIMA PRIMEIRA –</strong> Além das hipóteses previstas neste instrumento e na legislação aplicável à espécie, e sem prejuízo de eventuais retenções, multas e outras penalidades aqui dispostas, quaisquer dos seguintes eventos constituirão um evento de inadimplemento para fins deste contrato, o que facultará à parte prejudicada tomar por rescindido o contrato de pleno direito e sem necessidade de qualquer aviso prévio:</p>
    <p>(i) Paralisação ou encerramento, parcial ou total, da atividade da COMODATÁRIA determinante para o uso do freezer conservador de sorvetes;</p>
    <p>(ii) Existência de débitos para com a COMODANTE;</p>
    <p>(iii) Não aquisição de mercadorias da COMODANTE pelo período de até 02 (dois) meses consecutivos;</p>
    <p>(iv) Mau uso e falta de cuidado com o freezer conservador de sorvetes;</p>
    <p>(v) Descumprimento de qualquer cláusula e/ou obrigação prevista neste instrumento; ou</p>
    <p>(vi) Falsidade, imprecisão, insuficiência ou violação de declarações e garantidas prestadas nas cláusulas constantes do item “das declarações e garantias” pelas partes e respectivos representantes legais e/ou mandatários.</p>
    <p><strong>CLÁUSULA VIGÉSIMA SEGUNDA –</strong> Caso o descumprimento de qualquer cláusula e/ou obrigação prevista neste instrumento ocorra por parte da COMODATÁRIA, além da rescisão imediata do contrato, deverá restituir à COMODANTE todo e qualquer benefício por esta concedido, tais como bonificações, descontos, promoções, dentre outros.</p>
    <p><strong>Parágrafo primeiro –</strong> caso de descumprimento do disposto na cláusula segunda (armazenamento de produtos que não sejam os fabricados e vendidos pela COMODANTE), além da rescisão imediata do contrato e da restituição de todo e qualquer benefício concedido, a COMODATÁRIA estará sujeita a denúncia ao órgão regulador (ANVISA).</p>
    <p><strong>Parágrafo segundo –</strong> Em razão do disposto nesta cláusula, a COMODATÁRIA e o signatário deste instrumento, desde já autorizam a COMODANTE a emitir contra eles um boleto bancário no valor equivalente à bonificação concedida no ato da primeira aquisição de mercadorias, que ocorre concomitantemente à entrega do freezer conservador de sorvetes, qual seja, R$ 2.000,00 (dois mil reais), que deverá ser atualizado pelo IGPM – Índice Geral de Preços de Mercado, à época da emissão do boleto.</p>
 
    <div class="section-title"><strong> DA RESTITUÇÃO DO EQUIPAMENTO</strong></div>
    <p><strong>CLÁUSULA VIGÉSIMA TERCEIRA – </strong>As partes reconhecem que, na hipótese de extinção deste instrumento, nos termos das cláusulas vigésima primeira e vigésima segunda acima, e independentemente do motivo, deverá a COMODATÁRIA, imediatamente, disponibilizar o freezer conservador de sorvetes para retirada pela COMODANTE, sob pena de ser caracterizado ato espoliativo, ensejando à COMODANTE o direito de exigir a restituição do equipamento mencionado, mediante ação de reintegração de posse ou qualquer outro procedimento cabível e/ou o pagamento de indenização por perdas e danos. </p>
    <p><strong>CLÁUSULA VIGÉSIMA QUARTA – </strong>Em complemento à cláusula vigésima terceira, nas hipóteses de descumprimento, por parte da COMODATÁRIA, da obrigação de disponibilizar o freezer conservador de sorvetes para retirada pela COMODANTE, seja pela perda do equipamento mencionado ou por quaisquer embaraços criados pela COMODATÁRIA para impedir ou dificultar a retirada do freezer das suas dependências, a COMODATÁRA e o signatário desde já autorizam a COMODANTE a emitir contra elas um boleto bancário no valor equivalente a 100% (cem por cento) do valor de mercado de bem semelhante ao equipamento, a título de ressarcimento por perdas e danos, acrescido de multa de 10% (dez por cento) sobre o valor do ressarcimento, a título de multa compensatória, ficando a COMODATÁRIA, assim como o signatário, sujeitos às medidas judiciais e extrajudiciais cabíveis, incluindo a inscrição do seu nome em órgãos de restrição de crédito. </p>
    <p><strong>CLÁUSULA VIGÉSIMA QUINTA –</strong> O freezer conservador de sorvetes deverá ser restituído livre e desembaraçado de quaisquer mercadorias anteriormente adquiridas pela COMODATÁRIA da COMODANTE, não havendo que se falar em qualquer tipo de compensação e/ou descontos, seja a que título for.</p>

    <div class="section-title"><strong>DA MARCA</strong></div>
    <p><strong>CLÁUSULA VIGÉSIMA SEXTA – </strong>O presente instrumento não implica qualquer cessão ou autorização, pela COMODANTE, de uso da marca MILK MONI SORVETES por parte da COMODATÁRIA. Nesse sentido, a exposição e veiculação da mencionada marca no freezer conservador de sorvetes deve ocorrer exclusiva e estritamente em conexão com os propósitos e finalidades deste instrumento.</p>
    
    <div class="section-title"><strong>DA OBRIGAÇÃO PERANTE TERCEIROS</strong></div>
    <p><strong>CLÁUSULA VIGÉSIMA SÉTIMA – </strong> As partes não obrigarão uma à outra perante terceiros a qualquer título, nem estão autorizadas a agir em nome, uma da outra, sob nenhum aspecto, sem a prévia e expressa autorização da contraparte.</p>
    
    <div class="section-title"><strong>DA INVALIDAÇÃO DE QUALQUER DISPOSIÇÃO CONTRATUAL</strong></div>
    <p><strong>CLÁUSULA VIGÉSIMA OITAVA –</strong> Na hipótese de, a qualquer momento, qualquer previsão deste instrumento se tornar inválida, ilegal ou inaplicável, não haverá qualquer prejuízo às demais cláusulas e condições contratadas, as quais permanecerão em pleno vigor e deverão, portanto, ser efetivamente cumpridas.</p>
    
    <div class="section-title"><strong>DA NOVAÇÃO</strong></div>
    <p><strong>CLÁUSULA VIGÉSIMA NONA –</strong> A tolerância de qualquer das partes em relação ao inadimplemento, pela contraparte, de qualquer das cláusulas ou condições aqui pactuadas não implicará, em hipótese alguma, em renúncia a direitos, faculdades e pretensões, perdão tácito ou novação.</p>
    
    <div class="section-title"><strong>DA CESSÃO</strong></div>
    <p><strong>CLÁUSULA TRIGÉSIMA –</strong> O presente instrumento e os direitos dele decorrentes não poderão ser transferidos, cedidos ou caucionados por qualquer das partes, exceto se prévia e expressamente autorizado pela contraparte.</p>
    
    <div class="section-title"><strong>DA PREVALÊNCIA SOBRE TRATATIVAS ANTERIORES</strong></div>
    <p><strong>CLÁUSULA TRIGÉSIMA PRIMEIRA –</strong> O presente instrumento consubstancia a vontade final e soberana das partes, prevalecendo sobre todo e qualquer contrato, ajuste, acordo, negociação ou outro negócio jurídico anteriormente avençado entre as mesmas, operando-se, na data da assinatura deste contrato, a revogação, rescisão e extinção destes, de modo que subsistam e tenham a capacidade de vincular as partes apenas os termos e condições aqui expressamente estipulados.</p>
    
    <div class="section-title"><strong>DA EXTENSÃO DAS OBRIGAÇÕES</strong></div>
    <p><strong>CLÁUSULA TRIGÉSIMA SEGUNDA –</strong> Este instrumento obriga não somente as partes como, também, seus sucessores a qualquer título, os quais deverão garantir o efetivo cumprimento de todas as obrigações aqui pactuadas.</p>
    
    <div class="section-title"><strong>DAS OBRIGAÇÕES ANTICORRUPÇÃO</strong></div>
    <p><strong>CLÁUSULA TRIGÉSIMA TERCEIRA –</strong> As partes declaram que este instrumento é celebrado em estrita observância à legislação que lhe for aplicável e, particularmente, à Lei Brasileira Anticorrupção (Lei nº 12.846/2013).</p>
    <p><strong>CLÁUSULA TRIGÉSIMA QUARTA –</strong> Dessa forma, a COMODATÁRIA se obriga a não transferir qualquer valor, a título deste instrumento, direta ou indiretamente, a qualquer membro do Governo, em qualquer esfera, a partido político ou a quem quer que seja, com o objetivo de obter vantagem ou benefício.</p>
    <p><strong>CLÁUSULA TRIGÉSIMA QUINTA –</strong> A COMODATÁRIA assegura também que não utilizará recursos para subornar ou de alguma maneira violar a legislação aqui invocada, obrigando-se a confirmar perante a COMODANTE, sempre que solicitado, o compromisso aqui firmado.</p>
    <p><strong>CLÁUSULA TRIGÉSIMA SEXTA –</strong> A COMODATÁRIA declara, também, que nenhum dos seus empregados ou representantes, a qualquer título, alocados na execução do objeto deste instrumento, é funcionário de qualquer Governo.</p>
    <p><strong>CLÁUSULA TRIGÉSIMA SÉTIMA –</strong> A COMODATÁRIA se obriga, também, a não realizar qualquer pagamento em nome da COMODANTE sem antes obter sua aprovação prévia, devendo manter, para tanto, registro contábil próprio de todos os pagamentos feitos a título deste contrato, fornecendo, sempre que solicitado pela COMODANTE, os comprovantes desses lançamentos contábeis.</p>
    <p><strong>CLÁUSULA TRIGÉSIMA OITAVA –</strong> A COMODATÁRIA reconhece o direito da COMODANTE de auditar, a qualquer tempo, mesmo após a vigência deste instrumento, os seus livros contábeis, de maneira a confirmar o cumprimento, pelo contratado, das obrigações aqui assumidas.</p>
    
    <div class="section-title"><strong>DA RESPONSABILIDADE SOCIAL</strong></div>
    <p><strong>CLÁUSULA TRIGÉSIMA NONA –</strong> A COMODATÁRIA declara conhecer a legislação trabalhista brasileira, notadamente o disposto no artigo 7º, inciso XXXIII, da Constituição Federal, que proíbe o trabalho de menores de 18 (dezoito) anos em atividades noturnas, perigosas e insalubres e de menores de 16 (dezesseis) anos em qualquer trabalho, exceto na condição de aprendizes, a partir dos 14 (quatorze) anos, bem como declara conhecer o disposto no Código Penal Brasileiro que proíbe o trabalho escravo ou em condições análogas à escravidão, obrigando-se a cumpri-las integralmente.</p>
    
    <div class="section-title"><strong>DA RESPONSABILIDADE AMBIENTAL</strong></div>
    <p><strong>CLÁUSULA QUADRAGÉSIMA –</strong> A COMODATÁRIA declara conhecer e obriga-se a cumprir integralmente a legislação ambiental, inclusive quanto à logística reversa, se aplicável ao equipamento descrito na cláusula primeira e objetos deste instrumento.</p>
    <p><strong>CLÁUSULA QUADRAGÉSIMA PRIMEIRA –</strong> A COMODATÁRIA deverá notificar a COMODANTE, por escrito, sempre que a reparação, execução ou término do objeto deste instrumento envolver possível ofensa ao meio ambiente, inclusive descrevendo os procedimentos escolhidos e fundamentando riscos, responsabilizando-se integralmente pelos danos ao meio ambiente decorrentes da execução deste contrato./p>
    
    <div class="section-title"><strong>DA BOA-FÉ</strong></div>
    <p><strong>CLÁUSULA QUADRAGÉSIMA SEGUNDA –</strong> As partes reconhecem, expressa e formalmente, que as cláusulas aqui estabelecidas respeitaram integralmente o princípio da boa-fé objetiva, observando o princípio da função social que este instrumento quer preservar, não importando o presente negócio jurídico em abuso de direito que possa causar qualquer lesão às partes, uma vez que as recíprocas prestações são proporcionais entre si.</p>
    
    <div class="section-title"><strong>DA FISCALIZAÇÃO</strong></div>
    <p><strong>CLÁUSULA QUADRAGÉSIMA TERCEIRA –</strong> As partes acordam que será assegurado à COMODANTE o direito de fiscalizar as práticas adotadas pela COMODATÁRIA na execução do objeto deste instrumento, da forma que melhor lhe convier, durante todo o prazo contratual e até 12 (doze) meses após o seu término.</p>
   
    <div class="section-title"><strong>DAS DECLARAÇÕES E GARANTIAS</strong></div>
    <p><strong>CLÁUSULA QUADRAGÉSIMA QUARTA –</strong> A COMODATÁRIA, declara, entre outras declarações contidas neste instrumento, que, (i) na hipótese de se tratar de uma pessoa jurídica, a COMODATÁRIA é uma entidade devidamente constituída, validamente existente e em situação regular de acordo com as leis brasileiras, tendo todos os poderes e autoridades para celebrar este contrato e assumir as obrigações dele decorrentes, não sendo necessária qualquer anuência de terceiros para tal efeito; (ii) na hipótese de se tratar de uma pessoa natural, a COMODATÁRIA é maior de 18 (dezoito) anos, penalmente imputável e com plena capacidade civil para celebrar este contrato e praticar os atos acessórios a ele.</p>
    <p><strong>CLÁUSULA QUADRAGÉSIMA QUINTA –</strong> A pessoa que subscreve este instrumento em nome da COMODATÁRIA (signatário), declara, sob as penas previstas em lei e neste contrato, que o faz na qualidade de titular, representante legal ou mandatário da COMODATÁRIA, possuindo todos os poderes e autoridades necessários para obrigar a COMODATÁRIA mediante a celebração do contrato e de todos os demais documentos e instrumentos acessórios aplicáveis.</p>
    <p><strong>Parágrafo único –</strong> O signatário, por este ato, assume em conjunto com a COMODATÁRIA, a qualidade de fiel depositário do freezer conservador de sorvetes, para todos os fins e efeitos de direito, inclusive criminais, respondendo perante a COMODANTE na hipótese de perdas e danos ocasionados nos equipamentos mencionados.</p>
    <p><strong>CLÁUSULA QUADRAGÉSIMA SEXTA –</strong> A assinatura deste instrumento, assim como a sua execução, não viola e nem violará (i) direitos contratuais de terceiros em relação às partes; (ii) obrigações assumidas pelas partes; (iii) os atos constitutivos das partes; nem (iv) leis brasileiras ou qualquer decisão judicial ou administrativa de qualquer autoridade aplicáveis às partes.</p>
    <p><strong>CLÁUSULA QUADRAGÉSIMA SÉTIMA –</strong> Este instrumento e os demais documentos e instrumentos acessórios aplicáveis constituem (ou constituirão, conforme sejam firmados posteriormente no curso do presente contrato) obrigações válidas, legais e vinculativas entre as partes, sendo exequível de acordo com os seus termos na forma da Lei.</p>
    <p><strong>CLÁUSULA QUDRAGÉSIMA OITAVA – </strong>As partes não estão insolventes, nem estão sujeitas à recuperação judicial, extrajudicial ou a requerimento de falência, e inexiste qualquer ameaça relacionada a seus ativos que possa afetar a execução deste instrumento.</p>

    <div class="section-title"><strong>DO FORO</strong></div>
    <p><strong>CLÁUSULA QUADRAGÉSIMA NONA –</strong>As partes elegem o foro da cidade de São João da Boa Vista, Estado de São Paulo, como competente para dirimir-se eventuais dúvidas deste instrumento.E por estarem justos e contratados, assinam o presente instrumento em 02 (duas) vias de igual teor e forma, na presença das testemunhas abaixo.</p>

    <p style="text-align: left;margin-top: 50px;">São João da Boa Vista, '+cast(isnull(@dt_mes_ano,0) as nvarchar(25))+'.</p> <br> <br>
    <div class="assinatura"> <br> <br>
      <div style="width: 50%;">
        <div>
          <table style="width:100%;  height: 55px;">
            <tr>
              <td>______________________________________</td>
              <td>______________________________________</td>
            </tr>
            <tr>
              <td>'+cast(isnull(@razaosocial_cliente_rodape,'') as nvarchar(100))+'</td>
              <td>ANA MARIA RAMOS DE SOUZA & CIA. LTDA.</td>
            </tr>
            <tr>
              <td>CNPJ/CPF:'+cast(ISNULL(@cnpj_cliente1,'')as nvarchar(15))+'</td>
              <td>CNPJ: 67.196.949/0001-80</td>
            </tr>
          </table>
        </div> <br>
        <p style="text-align: center; margin-bottom: 10px;width:100%;height: 30%;">Testemunhas</p>
        <div>
         <table style="width:100%;height: 30%;">
            <tr>
              <td>1._____________________________</td>
              <td>2._____________________________</td>
            </tr>
            <tr>
              <td>Nome:</td>
              <td>Nome:</td>
            </tr>
            <tr>
              <td>RG nº:</td>
              <td>RG nº:</td>
            </tr>
            <tr>
              <td>CPF nº:</td>
              <td>CPF nº:</td>
            </tr>
          </table>
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
exec pr_egis_relatorio_contrato_comodato_milkmoni 182,4253,0,0,''
------------------------------------------------------------------------------
--text: (ctx) => "Point Style: " + ctx.chart.data.datasets[0].pointStyle, ( texto no título )
--select * from parametro_relatorio

