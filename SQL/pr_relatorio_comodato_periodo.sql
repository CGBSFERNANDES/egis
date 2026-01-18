IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_comodato_periodo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_comodato_periodo

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_comodato_periodo
-------------------------------------------------------------------------------
--pr_relatorio_comodato_periodo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Joao Pedro Marcal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relat�rio Padr�o Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025
--Altera��o        : 
--
--
------------------------------------------------------------------------------
create procedure pr_relatorio_comodato_periodo
@cd_relatorio int   = 0,
@cd_parametro int   = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')
declare @data_grafico_bar       nvarchar(max)
declare @cd_empresa             int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
--declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
--declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @ic_valor_comercial     varchar(10)
declare @cd_tipo_destinatario   int 
declare @cd_grupo_relatorio     int 
--declare @cd_relatorio           int = 0

--Dados do Relat�rio---------------------------------------------------------------------------------

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
	--		@nm_fantasia_cliente  	    varchar(200) = '',
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_razao_social_cliente	varchar(200) = '',
			@nm_cidade_cliente			varchar(200) = '',
			@sg_estado_cliente			varchar(5)	= '',
			@cd_numero_endereco			varchar(20) = '',
			@nm_condicao_pagamento		varchar(100) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40)   = '',
			@footerTitle				varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = ''



--------------------------------------------------------------------------------------------------------

--set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
--set @cd_parametro      = 0
set @cd_empresa        = 0
set @cd_form           = 0
--set @cd_parametro      = 0
--set @cd_documento      = 0
--set @dt_usuario        = GETDATE()
------------------------------------------------------------------------------------------------------

if @json<>''
begin
  select                     
    1                                                    as id_registro,
    IDENTITY(int,1,1)                                    as id,
    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
    valores.[value]              as valor                    
                    
    into #json                    
    from                
      openjson(@json)root                    
      cross apply openjson(root.value) as valores      

-------------------------------------------------------------------------------------------------

--select * from #json

-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_documento           = valor from #json where campo = 'cd_cliente'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'

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
select  
  @dt_inicial       = dt_inicial,  
  @dt_final         = dt_final
from   
  Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
  and  
  cd_usuario   = @cd_usuario  
---------------------------------------------------------------------------------------------------------------------------
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
--Dados do Relat�rio
---------------------------------------------------------------------------------------------------------------------------------------------

declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabe�alho da Empresa
declare @html_titulo     nvarchar(max) = '' --T�tulo
declare @html_cab_det    nvarchar(max) = '' --Cabe�alho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodap� do Detalhe
declare @html_rodape     nvarchar(max) = '' --Rodape
declare @html_geral      nvarchar(max) = '' --Geral

declare @data_hora_atual nvarchar(50)  = ''

set @html         = ''
set @html_empresa = ''
set @html_titulo  = ''
set @html_cab_det = ''
set @html_detalhe = ''
set @html_rod_det = ''
set @html_rodape  = ''
set @html_geral   = ''

-- Obt�m a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
------------------------------

--select @dt_final
---------------------------------------------------------------------------------------------------------------------------------------------
--T�tulo do Relat�rio
---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio


--select @titulo
--
--select @nm_cor_empresa
-----------------------
--Cabe�alho da Empresa----------------------------------------------------------------------------------------------------------------------
-----------------------

SET @html_empresa = '
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title >'+isnull(@titulo,'')+'</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            color: #333;
			padding:20px;
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
            padding: 10px;
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
            font-size: 120%;
        }

        img {
            max-width: 250px;
            margin-right: 10px;
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

        .tamanho {
            font-size: 75%;
            text-align: center;
        }
    </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:30%; margin-right:20px">
			<img src="'+isnull(@logo,'')+'" alt="Logo da Empresa">
		</div>
		<div style="width:70%; padding-left:10px">
			<p class="title">'+isnull(@nm_fantasia_empresa,'')+'</p>
		    <p><strong>'+isnull(@nm_endereco_empresa,'')+', '+isnull(@cd_numero_endereco_empresa,'')+ ' - '+isnull(@cd_cep_empresa,'')+ ' - '+isnull(@nm_cidade,'')+' - '+isnull(@sg_estado,'')+' - ' +isnull(@nm_pais,'')+'</strong></p>
		    <p><strong>Fone: </strong>'+isnull(@cd_telefone_empresa,'')+' - <strong>CNPJ: </strong>' + isnull(@cd_cnpj_empresa,'') + ' - <strong>I.E: </strong>' + isnull(@cd_inscestadual_empresa,'') + '</p>
		    <p>'+isnull(@nm_dominio_internet,'')+ ' - ' +isnull(@nm_email_internet,'')+'</p>
		</div>    
    </div>'

--select @html_empresa

		

--Detalhe--
  
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
  
  
if isnull(@cd_parametro,0) = 2  
 begin  
  select * from #RelAtributo  
  return  
end  

set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)

--------------------------------------------------------------------------------------------------------------------------
--set @cd_empresa = 274

if isnull(@cd_empresa,0) in (274,289)
begin
SELECT  
  identity(int,1,1)                       as cd_controle,
  max(v.nm_fantasia_vendedor)             as nm_fantasia_vendedor,
  max(c.cd_cliente)                       as cd_cliente,
  max(c.nm_fantasia_cliente)              as nm_fantasia_cliente,
  max(c.cd_cnpj_cliente)                  as cd_cnpj_cliente,
  max(p.nm_fantasia_produto)			  as nm_fantasia_produto,
  max(pv.cd_pedido_venda)                 as cd_pedido_venda,
  ns.cd_nota_saida, --
  max(ns.dt_nota_saida)                   as dt_nota_saida,
  max(pv.cd_tipo_pedido)                  as cd_tipo_pedido,
  max(ns.cd_identificacao_nota_saida)     as cd_identificacao_nota_saida,
  max(snf.sg_serie_nota_fiscal)           as sg_serie_nota_fiscal

  INTO 
	#comodatoPeriodoProcesso
FROM Nota_Saida ns  
 left outer join pedido_venda pv       on pv.cd_pedido_venda		= ns.cd_pedido_venda
 left outer join Serie_Nota_Fiscal snf on snf.cd_serie_nota_fiscal  = ns.cd_serie_nota_fiscal	
 left outer join cliente c             on c.cd_cliente              = pv.cd_cliente
 left outer join Nota_Saida_Item nsi   on nsi.cd_nota_saida			= ns.cd_nota_saida
 left outer join vendedor v            on v.cd_vendedor             = pv.cd_vendedor
 left outer join Produto p             on p.cd_produto              = nsi.cd_produto
 where 
 pv.dt_pedido_venda between @dt_inicial and @dt_final
 and
 pv.cd_tipo_pedido = 9

 group by 
  ns.cd_nota_saida
  end

else
begin

select  
  identity(int,1,1)                  as cd_controle,
  v.nm_fantasia_vendedor             as nm_fantasia_vendedor,
  sa.cd_solicitacao                  as cd_solicitacao,
  sa.dt_solicitacao                  as dt_solicitacao,
  c.cd_cliente                       as cd_cliente,
  c.nm_fantasia_cliente              as nm_fantasia_cliente,
  c.cd_cnpj_cliente                  as cd_cnpj_cliente,
  b.nm_bem                           as nm_bem,
  b.cd_patrimonio_bem                as cd_patrimonio_bem,
  b.nm_registro_bem                  as nm_registro_bem,
  sa.cd_pedido_venda                 as cd_pedido_venda,
  sa.cd_nota_saida, --
  ns.cd_identificacao_nota_saida     as cd_identificacao_nota_saida,
  snf.sg_serie_nota_fiscal           as sg_serie_nota_fiscal
  into 
  #comodatoPeriodo
from 
  solicitacao_ativo sa 
  left outer join cliente c             on c.cd_cliente             = sa.cd_cliente
  left outer join vendedor v            on v.cd_vendedor            = c.cd_vendedor
  left outer join Bem b                 on b.cd_bem                 = sa.cd_bem
  left outer join Nota_Saida ns         on ns.cd_nota_saida         = sa.cd_nota_saida
  left outer join pedido_venda pv       on pv.cd_pedido_venda		= ns.cd_pedido_venda
  left outer join Serie_Nota_Fiscal snf on snf.cd_serie_nota_fiscal = ns.cd_serie_nota_fiscal
WHERE  
    sa.dt_solicitacao BETWEEN @dt_inicial AND @dt_final

  order by 
     v.nm_fantasia_vendedor,
     sa.dt_solicitacao desc,
	 c.nm_fantasia_cliente
end
-------------------------------------------------------------------------------------------------------------
	 
if isnull(@cd_empresa,0) in (274,289)
begin	  
if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #comodatoPeriodo  
  return  
 end  
 ELSE
if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #comodatoPeriodoProcesso  
  return  
 end  
 END

--------------------------------------------------------------------------------------------------------------
declare @cd_identificacao_nota_saida nvarchar(20) 
declare @cd_pedido_venda             nvarchar(20)
declare @nm_registro_bem             nvarchar(60)
declare @cd_patrimonio_bem           nvarchar(20)
declare @nm_bem                      nvarchar(60)
DECLARE @cd_cnpj_cliente_tb          nvarchar(20) 
declare @nm_fantasia_cliente         nvarchar(60)
declare @cd_cliente_tb               nvarchar(20)
declare @dt_solicitacao              nvarchar(20)
declare @cd_solicitacao              nvarchar(20)
declare @nm_fantasia_vendedor        nvarchar(60)
Declare @sg_serie_nota_fiscal        nvarchar(15)
declare @qt_total_solicitacao        float = 0 
DECLARE @id                          int = 0 

--------------------------------------------------------------------------------------------------------------
	 
if isnull(@cd_empresa,0) in (274,289)
begin	  

select 
	@qt_total_solicitacao = count(cd_nota_saida)
from #comodatoPeriodoProcesso
END
ELSE 
BEGIN
select 
	@qt_total_solicitacao = count(cd_solicitacao)
from #comodatoPeriodo
end
--------------------------------------------------------------------------------------------------------------


if isnull(@cd_empresa,0) in (274,289)
begin
--------------------------------------------------------------------------------------------------------------
 
 set @html_geral = '<div>
		<p class="section-title" style="text-align: center; padding: 8px;">Comodatos por Período de '+cast(isnull(dbo.fn_data_string(@dt_inicial),'')as nvarchar(20))+' á '+cast(isnull(dbo.fn_data_string(@dt_final),'')as nvarchar(20))+'</p>
	</div>
	<div>
    <table>
      <tr class="tamanho">
	    <th>Vendedor</th>
    	<th>Pedido Venda</th>
        <th>Nota Saida</th>
        <th>Data Nota</th>
        <th>Cliente</th>
        <th>CNPJ</th>
        <th>Bem</th>
      </tr>'
	  while exists ( select top 1 cd_controle from #comodatoPeriodoProcesso)
begin
	select top 1

		@id                          = cd_controle,
       @html_geral = @html_geral +'<tr class="tamanho">
									<td>'+isnull(nm_fantasia_vendedor,'')+'</td>
									<td>'+CAST(isnull(cd_pedido_venda,0) as varchar(25))+'</td>
									<td>'+cast(isnull(cd_nota_saida,0) as varchar(25))+'</td>
									<td>'+isnull(dbo.fn_data_string(dt_nota_saida),'')+'</td>
									<td>'+isnull(nm_fantasia_cliente,'')+' ('+cast(isnull(cd_cliente,0) as varchar(20))+')</td>
									<td>'+isnull(dbo.fn_formata_cnpj(cd_cnpj_cliente),'')+'</td>
									<td>'+isnull(nm_fantasia_produto,'')+'</td>
							
								  </tr>'

     from #comodatoPeriodoProcesso
	 delete from #comodatoPeriodoProcesso where cd_controle = @id
 end
 --------------------------------------------------------------------------------------------------------------------
 end
 else
 begin
 set @html_geral = '<div>
		<p class="section-title" style="text-align: center; padding: 8px;">Comodatos por Período de '+cast(isnull(dbo.fn_data_string(@dt_inicial),'')as nvarchar(20))+' á '+cast(isnull(dbo.fn_data_string(@dt_final),'')as nvarchar(20))+'</p>
	</div>
	<div>
    <table>
      <tr class="tamanho">
		<th>Vendedor</th>
        <th>Solicitação</th>
        <th>Data Solicitação</th>
        <th>Cliente</th>
        <th>CNPJ</th>
        <th>Bem</th>
        <th>Patrimonio</th>
        <th>Registro</th>
        <th>Pedido Venda</th>
        <th>Nota Saida</th>
        <th>Série</th>
      </tr>'
					   
--------------------------------------------------------------------------------------------------------------

while exists ( select top 1 cd_controle from #comodatoPeriodo)
begin
	select top 1

		@id                          = cd_controle,
		@nm_fantasia_vendedor        = nm_fantasia_vendedor,
		@cd_solicitacao              = cd_solicitacao,
		@cd_identificacao_nota_saida = cd_identificacao_nota_saida,
		@dt_solicitacao              = CONVERT(VARCHAR(15),dt_solicitacao,103),
		@cd_cliente_tb               = cd_cliente,
		@cd_patrimonio_bem           = cd_patrimonio_bem,
		@nm_bem                      = nm_bem,
		@nm_fantasia_cliente         = nm_fantasia_cliente,
		@nm_registro_bem             = nm_registro_bem,
		@cd_pedido_venda             = cd_pedido_venda,
		@cd_cnpj_cliente_tb          = cd_cnpj_cliente,
		@sg_serie_nota_fiscal        = sg_serie_nota_fiscal



	from #comodatoPeriodo

 set @html_geral = @html_geral +'<tr class="tamanho">
									<td>'+isnull(@nm_fantasia_vendedor,'')+'</td>
									<td>'+isnull(@cd_solicitacao,'')+'</td>
									<td>'+isnull(@dt_solicitacao,'')+'</td>
									<td>'+isnull(@nm_fantasia_cliente,'')+' ('+isnull(@cd_cliente_tb,'')+')</td>
									<td>'+isnull(dbo.fn_formata_cnpj(@cd_cnpj_cliente_tb),'')+'</td>
									<td>'+isnull(@nm_bem,'')+'</td>
									<td>'+isnull(@cd_patrimonio_bem,'')+'</td>
									<td>'+isnull(@nm_registro_bem,'')+'</td>
									<td>'+isnull(@cd_pedido_venda,'')+'</td>
									<td>'+isnull(@cd_identificacao_nota_saida,0)+'</td>
									<td>'+isnull(@sg_serie_nota_fiscal,'')+'</td>
								  </tr>'

     
	 delete from #comodatoPeriodo where cd_controle = @id
 end
 end
--------------------------------------------------------------------------------------------------------------------
set @html_rodape =
    '</table>
	<div class="company-info">
		<p><strong>'+isnull(@footerTitle,'')+'</strong></p>
	</div>
	<div class="section-title">
      <p>Total de Solicitação: '+cast(isnull(@qt_total_solicitacao,0) as nvarchar(10))+'</p>
    </div>
    <p>'+isnull(@ds_relatorio,'')+'</p>
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+isnull(@data_hora_atual,'')+'</p>
    </div>'



--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +
	@html_geral   + 
	@html_cab_det +
    @html_detalhe +
	@html_rod_det +
    @html_rodape  

---------------------


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_relatorio_comodato_periodo 229,''
------------------------------------------------------------------------------

