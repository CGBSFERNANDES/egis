IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_faturamento_mensal_entregador' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_faturamento_mensal_entregador

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_faturamento_mensal_entregador
-------------------------------------------------------------------------------
--pr_egis_relatorio_faturamento_mensal_entregador
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
create procedure pr_egis_relatorio_faturamento_mensal_entregador
@cd_relatorio int   = 0,
@cd_parametro int   = 0, 
@json nvarchar(max) = '' 


as

set @json = isnull(@json,'')
declare @data_grafico_bar       nvarchar(max)
declare @cd_empresa             int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
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
declare @cd_veiculo             int = 0
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
			@nm_dominio_internet		varchar(200) = '',
			@cd_entregador              int = 0,
			@cd_produto                 int = 0,
			@cd_servico                 int = 0
------------------------------------------------------------------------------------------------
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
  select @cd_entregador          = valor from #json where campo = 'cd_entregador'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'


   set @cd_vendedor = isnull(@cd_vendedor,0)

   if @cd_vendedor = 0
   begin
     select @cd_vendedor           = valor from #json where campo = 'cd_documento_form'

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
if @cd_form = 184 
begin
select  
  @dt_inicial       = dt_inicial,
  @dt_final         = dt_final,
  @cd_entregador    = isnull(cd_entregador,0)
from   
  Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
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

-- Obtem a data e hora atual
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
            font-size: 75%;
            text-align: center;
        }
		.tamanhoTotal{
		    font-size: 16px;
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


--Procedure de Cada Relatorio-------------------------------------------------------------------------------------  
  
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
  
  
if isnull(@cd_parametro,0) = 2  
 begin  
  select * from #RelAtributo  
  return  
end  
  
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)

--------------------------------------------------------------------------------------------------------------------------
--set	@dt_inicial  = '07/01/2025'
--set	@dt_final    = '07/30/2025'
--set @cd_veiculo  = 0
--set @cd_servico = 0
Select 
    identity(int,1,1)               as cd_controle,
	e.nm_entregador                 as nm_entregador,
	e.cd_entregador                 as cd_entregador,
	sum(ri.vl_total_romaneio)       as vl_romaneio,
 	qt_km = sum( isnull(d.qt_odometro_final,0) - isnull(d.qt_odometro_inicial,0)),
    count(r.cd_romaneio)            as qt_romaneio,
    COUNT(distinct r.cd_cliente)    as qt_cliente,
    COUNT(distinct r.cd_veiculo)    as qt_veiculo,
    COUNT(distinct r.cd_entregador) as qt_entregador
	into 
	#faturamentoEntregador
from 
	romaneio r
	left outer join Romaneio_Item ri         on r.cd_romaneio       = ri.cd_romaneio
	left outer join romaneio_entrega_dados d on d.cd_romaneio       = r.cd_romaneio
	left outer join Entregador e             on e.cd_entregador     = r.cd_entregador 
	left outer join pedido_venda pv          on pv.cd_pedido_venda  = ri.cd_pedido_venda
where
 r.dt_romaneio between @dt_inicial and @dt_final
 and 
 r.cd_entregador = case when ISNULL(@cd_entregador,0) = 0 then r.cd_entregador else ISNULL(@cd_entregador,0) end
 group by 
 e.nm_entregador,
 e.cd_entregador
 
------------------------------------------------------------------------------------------------------------		 
   
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #faturamentoEntregador  
  return  
 end  

--------------------------------------------------------------------------------------------------------------
declare
	@qt_km         float = 0,
	@qt_entrega    float = 0,
	@vl_romaneio   float = 0,
	@qt_cliente    float = 0,
	@qt_veiculo    float = 0
select 
	@qt_km         = sum(qt_km),
	@qt_entrega    = sum(qt_romaneio),
	@vl_romaneio   = sum(vl_romaneio),
	@qt_cliente    = count(qt_cliente),
	@qt_veiculo    = count(qt_veiculo)
from #faturamentoEntregador
--------------------------------------------------------------------------------------------------------------
set @html_geral = '
    <div class="section-title" style="margin-top: 20px;">    
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>     
        <p style="display: inline; text-align: center; padding: 25%;"> '+isnull(+@titulo,'')+' </p>    
    </div>
	<div>
    <table>  
		<tr class="tamanho">
		  <th>Veiculo</th>
		  <th>KM</th>
		  <th>Valor</th>
		  <th>Entregas</th>
		  <th>Cliente</th>
		  <th>Veículo</th>
		</tr>'

--------------------------------------------------------------------------------------------------------------
DECLARE @id int = 0 

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #faturamentoEntregador)
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,
        @html_geral = @html_geral +

        '<tr class="tamanho">
		    <td>' + ISNULL(nm_entregador,'')+' ('+cast(isnull(cd_entregador,0) as varchar(20))+')</td>		
            <td>'+cast(isnull(dbo.fn_formata_valor(qt_km),0) as varchar(20))+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(vl_romaneio),0) as varchar(20))+'</td>
            <td>'+cast(isnull(qt_romaneio,0) as varchar(20))+'</td>
            <td>' + CAST(ISNULL(qt_cliente, '') AS NVARCHAR(10)) + '</td>
			<td>' + CAST(ISNULL(qt_veiculo, '') AS NVARCHAR(10)) + '</td>
         </tr>'
	FROM #faturamentoEntregador
    DELETE FROM #faturamentoEntregador WHERE cd_controle = @id
END
--------------------------------------------------------------------------------------------------------------------

set @html_rodape =
    '<tr class="tamanhoTotal">
            <td>Total</td>		
            <td>'+cast(isnull(dbo.fn_formata_valor(@qt_km),0) as varchar(20))+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_romaneio),0) as varchar(20))+'</td>
            <td>'+cast(isnull(@qt_entrega,0) as varchar(20))+'</td>
            <td>' + CAST(ISNULL(@qt_cliente, '') AS NVARCHAR(10)) + '</td>
			<td>' + CAST(ISNULL(@qt_veiculo, '') AS NVARCHAR(10)) + '</td>
         </tr>
	</table>

	<div class="section-title">
      <p style="margin-bottom:5px ;">Total Entregas: '+cast(isnull(@qt_entrega,0) as nvarchar(10))+'</p>
      <p>Valor Total: '+cast(isnull(dbo.fn_formata_valor(@vl_romaneio),0) as nvarchar(15))+'</p>
    </div>
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

--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_faturamento_mensal_entregador 345,0,''
------------------------------------------------------------------------------
