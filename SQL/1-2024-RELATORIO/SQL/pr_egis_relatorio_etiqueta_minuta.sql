IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_etiqueta_minuta' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_etiqueta_minuta

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_etiqueta_minuta
-------------------------------------------------------------------------------
--pr_egis_relatorio_etiqueta_minuta
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
create procedure pr_egis_relatorio_etiqueta_minuta
@cd_relatorio int   = 0,
@cd_parametro int   = 0, 
@json nvarchar(max) = '' 


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
declare @cd_vendedor            int = 0
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
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_condicao_pagamento		varchar(100) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40)   = '',
			@footerTitle				varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = '',
			@nm_complemento_endereco    varchar(200) = '',
			@nm_bairo                   varchar(200) = ''
			
----------------------------------------------------------------------------------------------
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
  select @cd_parametro           = valor from #json where campo = 'cd_parametro'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @cd_documento           = valor from #json where campo = 'cd_minuta'


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
---------------------------------------------------------------------------------------------------------------------
  select  
  @dt_final         = dt_final,
  @dt_inicial       = dt_inicial,
  @cd_vendedor      = isnull(cd_vendedor,0)
from   
  Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
  and  
  cd_usuario   = @cd_usuario  
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
		@nm_fantasia_empresa	    = isnull(e.nm_empresa,''),
		@cd_cep_empresa			    = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),
		@cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),
		@nm_pais					= ltrim(rtrim(isnull(p.sg_pais,''))),
		@cd_cnpj_empresa			= dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),
		@cd_inscestadual_empresa	=  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),
		@nm_dominio_internet		=  ltrim(rtrim(isnull(e.nm_dominio_internet,''))),
		@nm_complemento_endereco	= isnull(e.nm_complemento_endereco,''),
		@nm_bairo                   = isnull(e.nm_bairro_empresa,'')


	from egisadmin.dbo.empresa e	with(nolock) 
	left outer join Estado es		with(nolock) on es.cd_estado = e.cd_estado
	left outer join Cidade c		with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado
	left outer join Pais p			with(nolock) on p.cd_pais = e.cd_pais
	where 
		cd_empresa = 357
		
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
    <title >'+@titulo+'</title>
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
		.letra{
			font-size: 14px;
			font-weight: bold;
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

--Procedure de Cada Relat?rio-------------------------------------------------------------------------------------  
  
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
  
  
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
--set @dt_inicial = '05/01/2025'
--set @dt_final = '06/28/2025'

if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    
--------------------------------------------------------------------------------------------------------------------------


select 
    identity(int,1,1)         as cd_controle,
	md.cd_entregador          as cd_entregador,
	e.nm_entregador           as nm_entregador,
	u.nm_usuario              as nm_usuario,
	e.cd_placa_entregador     as cd_placa_entregador,
	md.cd_minuta              as cd_minuta,
	c.cd_cliente              as cd_cliente,
	c.nm_fantasia_cliente     as nm_fantasia_cliente,
	c.nm_razao_social_cliente as nm_razao_social_cliente,
	v.nm_vendedor             as nm_vendedor,
	cid.nm_cidade             as nm_cidade_cliente,
	ns.cd_num_formulario_nota as cd_num_formulario_nota,
	ns.nm_operacao_fiscal     as nm_operacao_fiscal,
	c.nm_endereco_cliente     as nm_endereco_cliente,
	c.cd_numero_endereco      as cd_numero_endereco_cliente,
	c.nm_bairro               as nm_bairro_cliente,
	es.sg_estado			  as sg_estado_cliente,
	c.cd_cep                  as cd_cep,
	t.nm_transportadora		  as nm_transportadora,
	t.cd_transportadora		  as cd_transportadora,
	t.cd_telefone			  as cd_telefone_transportadora,
	t.cd_ddd				  as cd_ddd_transportadora,
	t.nm_endereco			  as nm_enderenco_transportadora,
	t.cd_numero_endereco      as cd_numero_endereco_transportadora,
	t.nm_bairro               as nm_bairro_transportadora,
	cida.nm_cidade            as nm_cidade_tranportadora,
	est.sg_estado			  as sg_estado_tranportadora,
	ns.qt_volume_nota_saida   as qt_volume_nota_saida

 into 
  #minuta_despacho
  from Minuta_Despacho md
 	left outer join entregador e                   on e.cd_entregador     = md.cd_entregador
	left outer join egisadmin.dbo.usuario u        on u.cd_usuario        = md.cd_usuario
	left outer join Minuta_Despacho_Composicao mdc on mdc.cd_minuta       = md.cd_minuta
	left outer join Nota_Saida ns                  on ns.cd_nota_saida    = mdc.cd_nota_saida 
	left outer join cliente c                      on c.cd_cliente        = ns.cd_cliente
	left outer join vendedor v                     on v.cd_vendedor       = ns.cd_vendedor
	left outer join Estado es					   on es.cd_estado        = c.cd_estado
	left outer join Cidade cid					   on cid.cd_cidade       = c.cd_cidade and cid.cd_estado = c.cd_estado
	left outer join Pais p						   on p.cd_pais           = c.cd_pais
	LEFT outer join Transportadora t               on t.cd_transportadora = ns.cd_transportadora
	left outer join Estado est					   on est.cd_estado       = t.cd_estado
	left outer join Cidade cida					   on cida.cd_cidade      = t.cd_cidade and cida.cd_estado = t.cd_estado
	left outer join Pais pp						   on pp.cd_pais          = t.cd_pais

  where
	ns.cd_nota_saida = 366


	DECLARE 
    @cd_entregador            INT,
    @nm_entregador            VARCHAR(200),
    @nm_usuario               VARCHAR(200),
    @cd_placa_entregador      VARCHAR(50),
    @cd_minuta                INT,
    @cd_cliente               INT,
    @nm_fantasia_cliente      VARCHAR(200),
    @nm_razao_social_cliente  VARCHAR(200),
    @nm_vendedor              VARCHAR(200),
    @nm_cidade_cliente        VARCHAR(200),
    @cd_num_formulario_nota   INT,
    @nm_operacao_fiscal       VARCHAR(200),
    @nm_endereco_cliente      VARCHAR(200),
    @cd_numero_endereco_cliente VARCHAR(20),
    @nm_bairro                VARCHAR(200),
    @sg_estado_cliente        CHAR(2),
    @cd_cep                   VARCHAR(15),
    @nm_transportadora        VARCHAR(200),
    @cd_transportadora        INT,
    @cd_telefone              VARCHAR(20),
    @cd_ddd                   VARCHAR(5),
    @nm_enderenco             VARCHAR(200),
    @cd_numero_endereco_transp VARCHAR(20),
    @nm_bairro_transportadora  VARCHAR(200),
    @nm_cidade_transportadora  VARCHAR(200),
    @sg_estado_transportadora  CHAR(2),
    @qt_volume_nota_saida      INT,
	@nm_bairro_cliente         varchar(50)

SELECT
  
    @cd_entregador              = cd_entregador,
    @nm_entregador              = nm_entregador,
    @nm_usuario                 = nm_usuario,
    @cd_placa_entregador        = cd_placa_entregador,
    @cd_minuta                  = cd_minuta,
    @cd_cliente                 = cd_cliente,
    @nm_fantasia_cliente        = nm_fantasia_cliente,
    @nm_razao_social_cliente    = nm_razao_social_cliente,
    @nm_vendedor                = nm_vendedor,
    @nm_cidade_cliente          = nm_cidade_cliente,
    @cd_num_formulario_nota     = cd_num_formulario_nota,
    @nm_operacao_fiscal         = nm_operacao_fiscal,
    @nm_endereco_cliente        = nm_endereco_cliente,
    @cd_numero_endereco_cliente = cd_numero_endereco_cliente,
    @nm_bairro_cliente          = nm_bairro_cliente,
    @sg_estado_cliente          = sg_estado_cliente,
    @cd_cep                     = cd_cep,
    @nm_transportadora          = nm_transportadora,
    @cd_transportadora          = cd_transportadora,
    @cd_telefone                = cd_telefone_transportadora,
    @cd_ddd                     = cd_ddd_transportadora,
    @nm_enderenco               = nm_enderenco_transportadora,
    @cd_numero_endereco_transp  = cd_numero_endereco_transportadora,
    @nm_bairro_transportadora   = nm_bairro_transportadora,
    @nm_cidade_transportadora   = nm_cidade_tranportadora,
    @sg_estado_transportadora   = sg_estado_tranportadora,
    @qt_volume_nota_saida       = qt_volume_nota_saida

FROM #minuta_despacho

--------------------------------------------------------------------------------------------------------------------------
set @html_geral = '       
<table>
      <tr>
        <td colspan="4" style="text-align: LEFT; ">'+isnull(@nm_fantasia_empresa,'')+' <br> '+isnull(@nm_endereco_empresa,'')+', '+cast(isnull(@cd_numero_endereco_empresa,0) as varchar(20))+' '+isnull(@nm_complemento_endereco,'')+' / '+ISNULL(@nm_bairo,'')+' / '+isnull(@nm_cidade,'')+' / '+isnull(@sg_estado,'')+' / '+isnull(@cd_cep_empresa,'')+' <br> '+isnull(@cd_cnpj_empresa,'')+' / '+isnull(@cd_inscestadual_empresa,'')+' / '+isnull(@cd_telefone_empresa,'')+' </td>
         <td>qrcode</td>
      </tr>
    <tr>
      <td  style="text-align: LEFT;">Cliente<br>Endereço<br>CEP/CIDADE/UF</td>
      <td colspan="4">'+cast(isnull(@cd_cliente,'') as varchar(50))+' - '+isnull(@nm_razao_social_cliente,'')+' <br> '+isnull(@nm_endereco_cliente,'')+' '+isnull(@cd_numero_endereco_cliente,'')+' / '+isnull(@nm_bairro_cliente,'')+' <br>CEP: '+isnull(dbo.fn_formata_cep(@cd_cep),'') +' / '+isnull(@nm_cidade_cliente,'')+' / '+isnull(@sg_estado_cliente,'')+'</td>
    </tr>
    <tr >
      <td style="text-align: LEFT;">Transportadora</td>
      <td colspan="4">'+cast(isnull(@cd_entregador,'') as varchar(50))+' '+isnull(@nm_entregador,'')+' / TEL: '+cast(isnull(@cd_ddd,'') as varchar(50))+' '+cast(isnull(@cd_telefone,'') as varchar(50))+' </br> '+isnull(@nm_enderenco,'')+' '+cast(isnull(@cd_numero_endereco_transp,'') as varchar(50))+' / '+isnull(@nm_bairro_transportadora,'')+' / '+isnull(@nm_cidade_transportadora,'')+' / '+isnull(@sg_estado_transportadora,'')+' </td>
    </tr>
    <tr>
      <td>NFe</td>
      <td>'+cast(isnull(@cd_num_formulario_nota,'') as varchar(50))+'</td>
      <td>Volumes</td>
       <td>'+cast(isnull(@qt_volume_nota_saida,'') as varchar(50))+'</td>
      <td></td>

    </tr>
</table>'
					   
--------------------------------------------------------------------------------------------------------------

set @html_rodape =
    ' </table>
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>
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
--exec pr_egis_relatorio_etiqueta_minuta 304,0,''
------------------------------------------------------------------------------
