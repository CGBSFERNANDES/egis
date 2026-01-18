IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_consulta_doc_pago_aberto' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_consulta_doc_pago_aberto

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_consulta_doc_pago_aberto
-------------------------------------------------------------------------------
--pr_egis_relatorio_consulta_doc_pago_aberto
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
create procedure pr_egis_relatorio_consulta_doc_pago_aberto
@cd_relatorio int   = 0,
@json varchar(8000) = '' 


as

set @json = isnull(@json,'')
declare @data_grafico_bar       nvarchar(max)
declare @cd_empresa             int = 0
declare @cd_form                int = 0
declare @cd_parametro           int = 0 
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
			@cd_cliente				    int = 0,
	--		@nm_fantasia_cliente  	    varchar(200) = '',
			@cd_cnpj_cliente		    varchar(30) = '',
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

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario' 
  select @cd_form                = valor from #json where campo = 'cd_form'
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
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
---------------------------------------------------------------------------------------------------------------------
if isnull(@cd_form,0) = 91 
begin
 select  
  @dt_inicial = dt_inicial,
  @dt_final = dt_final

from   
  Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
  and  
  cd_usuario   = @cd_usuario  
end
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
            font-size: 13px;
            text-align: center;
        }
		.tamanhoTitlo {
            font-size: 14px;
            text-align: center;
			font-weight:bold;
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
  
  
if isnull(@cd_parametro,0) = 2  
 begin  
  select * from #RelAtributo  
  return  
end  
  
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)

--------------------------------------------------------------------------------------------------------------------------
----- select cliente
--set @dt_inicial = '06/01/2025'
--set @dt_final   = '06/30/2025'


select 
  IDENTITY(int,1,1)                as cd_controle,
  'Aberto'                  as nm_tipo_documento,
  cd_identificacao_document as cd_documento,
  dt_emissao_documento_paga as dt_emissao,
  dt_vencimento_documento   as dt_vencimento,
  null                      as dt_pagamento,
  vl_saldo_documento_pagar  as vl_documento,
  cast(case when dt_vencimento_documento<@dt_hoje then 'Atraso' else '' end as varchar(60)) as nm_status,
      case when (isnull(d.cd_empresa_diversa, 0)      <> 0)  then isnull(cast((select top 1 z.sg_empresa_diversa     from empresa_diversa z where z.cd_empresa_diversa = d.cd_empresa_diversa) as varchar(30)),d.nm_fantasia_fornecedor)    
           when (isnull(d.cd_contrato_pagar, 0)       <> 0)  then isnull(cast((select top 1 w.nm_fantasia_fornecedor from contrato_pagar w  where w.cd_contrato_pagar  = d.cd_contrato_pagar)  as varchar(30)),d.nm_fantasia_fornecedor)  
           when (isnull(d.cd_funcionario, 0)          <> 0)  then isnull(cast((select top 1 k.nm_funcionario         from funcionario k     where k.cd_funcionario     = d.cd_funcionario)     as varchar(30)),d.nm_fantasia_fornecedor)    
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then cast(d.nm_fantasia_fornecedor as varchar(30))  
      end                             as 'cd_favorecido',                 

      case when (isnull(d.cd_empresa_diversa, 0)      <> 0)  then cast((select top 1 z.nm_empresa_diversa from empresa_diversa z where z.cd_empresa_diversa = d.cd_empresa_diversa) as varchar(50))  
           when (isnull(d.cd_contrato_pagar, 0)       <> 0)  then cast((select top 1 w.nm_contrato_pagar  from contrato_pagar w  where w.cd_contrato_pagar = d.cd_contrato_pagar)   as varchar(50))  
           when (isnull(d.cd_funcionario, 0)          <> 0)  then cast((select top 1 k.nm_funcionario     from funcionario k     where k.cd_funcionario = d.cd_funcionario)         as varchar(50))  
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then cast((select top 1 o.nm_razao_social    from fornecedor o      where o.nm_fantasia_fornecedor = d.nm_fantasia_fornecedor) as varchar(50))    
      end                             as 'nm_favorecido',     

      tds.nm_tipo_destinatario as nm_tipo_destinatario,
	  pf.nm_conta_plano_financeiro as nm_conta_plano_financeiro,
	  null as nm_conta

 into #Aberto 

from
  Documento_Pagar d
 left outer join Tipo_Destinatario tds       with (nolock) on tds.cd_tipo_destinatario = d.cd_tipo_destinatario
 left outer join plano_financeiro pf         with (nolock) on pf.cd_plano_financeiro   = d.cd_plano_financeiro

where
  dt_vencimento_documento between @dt_inicial and @dt_final
  and 
  vl_saldo_documento_pagar > 0

order by
  d.dt_vencimento_documento 


--select * from #Aberto

select 
  IDENTITY(int,1,1)                as cd_controle,
  'Pagos'                      as nm_tipo_documento,
  d.cd_identificacao_document  as cd_documento,
  d.dt_emissao_documento_paga  as dt_emissao,
  d.dt_vencimento_documento    as dt_vencimento,
  p.dt_pagamento_documento     as dt_pagamento,
  p.vl_pagamento_documento     as vl_documento,
  p.nm_obs_documento_pagar     as nm_status,
      case when (isnull(d.cd_empresa_diversa, 0)      <> 0)  then isnull(cast((select top 1 z.sg_empresa_diversa     from empresa_diversa z where z.cd_empresa_diversa = d.cd_empresa_diversa) as varchar(30)),d.nm_fantasia_fornecedor)    
           when (isnull(d.cd_contrato_pagar, 0)       <> 0)  then isnull(cast((select top 1 w.nm_fantasia_fornecedor from contrato_pagar w  where w.cd_contrato_pagar  = d.cd_contrato_pagar)  as varchar(30)),d.nm_fantasia_fornecedor)  
           when (isnull(d.cd_funcionario, 0)          <> 0)  then isnull(cast((select top 1 k.nm_funcionario         from funcionario k     where k.cd_funcionario     = d.cd_funcionario)     as varchar(30)),d.nm_fantasia_fornecedor)    
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then cast(d.nm_fantasia_fornecedor as varchar(30))  
      end                             as 'cd_favorecido',                 

      case when (isnull(d.cd_empresa_diversa, 0)      <> 0)  then cast((select top 1 z.nm_empresa_diversa from empresa_diversa z where z.cd_empresa_diversa = d.cd_empresa_diversa) as varchar(50))  
           when (isnull(d.cd_contrato_pagar, 0)       <> 0)  then cast((select top 1 w.nm_contrato_pagar  from contrato_pagar w  where w.cd_contrato_pagar = d.cd_contrato_pagar)   as varchar(50))  
           when (isnull(d.cd_funcionario, 0)          <> 0)  then cast((select top 1 k.nm_funcionario     from funcionario k     where k.cd_funcionario = d.cd_funcionario)         as varchar(50))  
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then cast((select top 1 o.nm_razao_social    from fornecedor o      where o.nm_fantasia_fornecedor = d.nm_fantasia_fornecedor) as varchar(50))    
      end                             as 'nm_favorecido',     

      tds.nm_tipo_destinatario as nm_tipo_destinatario,
	  pf.nm_conta_plano_financeiro as nm_conta_plano_financeiro,
	  pco.nm_conta as nm_conta 


 into #Pagamento
from
  Documento_Pagar d
  inner join documento_pagar_pagamento p on p.cd_documento_pagar = d.cd_documento_pagar
  left outer join Tipo_Destinatario tds       with (nolock) on tds.cd_tipo_destinatario = d.cd_tipo_destinatario
  left outer join plano_financeiro pf         with (nolock) on pf.cd_plano_financeiro   = d.cd_plano_financeiro
  left outer join plano_conta pco             with (nolock) on pco.cd_conta             = pf.cd_conta
where
  p.dt_pagamento_documento between @dt_inicial and @dt_final

order by
  d.dt_vencimento_documento 


--select * from #Pagamento


select 
	* 
   into #consultaIntermediario
from #Aberto

union all

select
	* 
from #Pagamento
order by
  nm_tipo_documento,dt_pagamento, dt_vencimento

  select
		*
	into #consultaFinal from #consultaIntermediario

 --select * from #Aberto
------------------------------------------------------------------------------------------------------------		 
   
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #consultaFinal  
  return  
 end  

--------------------------------------------------------------------------------------------------------------
declare 
	@qt_total float = 0,
	@vl_total float = 0,
	@qt_total_pagos int = 0,
	@qt_total_aberto int = 0,
    @vl_total_pagos float = 0,
	@vl_total_aberto float = 0

select @qt_total_pagos  = count(cd_documento) from #consultaFinal where nm_tipo_documento = 'Pagos'
select @qt_total_aberto  = count(cd_documento) from #consultaFinal where nm_tipo_documento = 'Aberto'


select @vl_total_pagos  = sum(vl_documento) from #consultaFinal where nm_tipo_documento = 'Pagos'
select @vl_total_aberto  = sum(vl_documento) from #consultaFinal where nm_tipo_documento = 'Aberto'

--select @vl_total_aberto, @vl_total_pagos
select 
	@qt_total = count(cd_documento),
    @vl_total = sum(vl_documento)
from #consultaFinal
declare @pagamento_controle int = 0
declare @aberto_controle int = 0
select 
	@pagamento_controle = cd_controle
from #Pagamento
select 
	@aberto_controle = cd_controle
from #Aberto
--------------------------------------------------------------------------------------------------------------
set @html_geral = '<div class="section-title">
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p> 
        <p style="display: inline; text-align: center; padding: 25%;">'+isnull(@titulo,'')+'</p>
	</div>'
if @aberto_controle > 0
begin
set @html_geral = @html_geral + ' <h2>Documentos em Aberto</h2>
    <table>  
		<tr>
		  <th>Tipo Documento</th>
		  <th>Documento</th>
		  <th>Emissão</th>
		  <th>Vencimento</th>
		  <th>Pagamento</th>
		  <th>Valor</th>
		  <th>Status</th>
		  <th>Favorecido</th>
		  <th>Razão Social</th>	  
		  <th>Destinatário</th>
		  <th>Plano Financeiro</th>
		</tr>'
			   

DECLARE @id int = 0 

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #Aberto )
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,
		@html_geral = @html_geral +
        '<tr class="tamanho">
			<td>' + ISNULL(nm_tipo_documento, '') + '</td>
			<td>' + ISNULL(cd_documento, '') + '</td>
            <td>' + ISNULL(dbo.fn_data_string(dt_emissao), '') + '</td>
			<td>' + ISNULL(dbo.fn_data_string(dt_vencimento), '') + '</td>
			<td>' + ISNULL(dbo.fn_data_string(dt_pagamento), '') + '</td>
			<td style="text-align:right">R$ ' + CAST(ISNULL(dbo.fn_formata_valor(vl_documento), 0) AS NVARCHAR(20)) + '</td>
            <td>' + ISNULL(nm_status, '') + '</td>
            <td>' + ISNULL(cd_favorecido, '')+ '</td>
            <td>' + ISNULL(nm_favorecido, '') + '</td>
			<td>' + ISNULL(nm_tipo_destinatario, '') + '</td>
            <td>' + ISNULL(nm_conta_plano_financeiro, '') + ' </td>
	</tr>'
	FROM #Aberto
    DELETE FROM #Aberto WHERE cd_controle = @id
END
set	@html_geral = @html_geral +'</table>'
end
else 
begin set @html_geral = @html_geral + '<p style="text-align:center"><strong>Nenhum documento em aberto nesse período.</strong></p>'
end 
--------------------------------------------------------------------------------------------------------------------
if @pagamento_controle > 0 
begin 
set @html_cab_det = '
	<h2>Documentos Pagos</h2>
    <table>  
		<tr>
		  <th>Tipo Documento</th>
		  <th>Documento</th>
		  <th>Emissão</th>
		  <th>Vencimento</th>
		  <th>Pagamento</th>
		  <th>Valor</th>
		  <th>Status</th>
		  <th>Favorecido</th>
		  <th>Razão Social</th>	  
		  <th>Destinatário</th>
		  <th>Plano Financeiro</th>
		  <th>Conta Contábil</th>
		</tr>'
			   

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #Pagamento)
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,
		@html_cab_det = @html_cab_det +
        '<tr class="tamanho">
			<td>' + ISNULL(nm_tipo_documento, '') + '</td>
			<td>' + ISNULL(cd_documento, '') + '</td>
            <td>' + ISNULL(dbo.fn_data_string(dt_emissao), '') + '</td>
			<td>' + ISNULL(dbo.fn_data_string(dt_vencimento), '') + '</td>
			<td>' + ISNULL(dbo.fn_data_string(dt_pagamento), '') + '</td>
			<td style="text-align:right">R$ ' + CAST(ISNULL(dbo.fn_formata_valor(vl_documento), 0) AS NVARCHAR(20)) + '</td>
            <td>' + ISNULL(nm_status, '') + '</td>
            <td>' + ISNULL(cd_favorecido, '')+ '</td>
            <td>' + ISNULL(nm_favorecido, '') + '</td>
			<td>' + ISNULL(nm_tipo_destinatario, '') + '</td>
            <td>' + ISNULL(nm_conta_plano_financeiro, '') + ' </td>
			<td>' + ISNULL(nm_conta,'') + ' </td>
	</tr>'
	FROM #Pagamento
    DELETE FROM #Pagamento WHERE cd_controle = @id
END
end 
else 
begin 
	set @html_geral = @html_geral + '<p style="text-align:center"><strong>Nenhum documento pago nesse período.</strong></p>'

end 
--------------------------------------------------------------------------------------------------------------------
set @html_rodape =
    '</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	</div>
	<table>
		<tr>
			<th>Quantidade em Aberto</th>
			<th>Valor em Aberto</th>
			<th>Quantidade Pagos</th>
			<th>Valor Pagos</th>
			<th>Quantidade Total</th>
			<th>Valor Total</th>
		</tr>
	    <tr class="tamanho">
			<td style="text-align:center">' + CAST(ISNULL(@qt_total_aberto, 0) AS VARCHAR(20)) + '</td>
			<td style="text-align:right">R$ ' + CAST(ISNULL(dbo.fn_formata_valor(@vl_total_aberto), 0) AS VARCHAR(20)) + '</td>
			<td style="text-align:center">' + CAST(ISNULL(@qt_total_pagos, 0) AS VARCHAR(20)) + '</td>
			<td style="text-align:right">R$ ' + CAST(ISNULL(dbo.fn_formata_valor(@vl_total_pagos), 0) AS VARCHAR(20)) + '</td>
			<td style="text-align:center">' + CAST(ISNULL(@qt_total, 0) AS VARCHAR(20)) + '</td>
			<td style="text-align:right">R$ ' + CAST(ISNULL(dbo.fn_formata_valor(@vl_total), 0) AS VARCHAR(20)) + '</td>
		</tr>
	</table>
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
--exec pr_egis_relatorio_consulta_doc_pago_aberto 340,'[{"cd_usuario":1,"cd_empresa":247,"dt_inicial": "12/01/2025", "dt_final": "12/30/2025"}]'
------------------------------------------------------------------------------
