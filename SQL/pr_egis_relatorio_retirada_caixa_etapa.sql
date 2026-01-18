IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_retirada_caixa_etapa' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_retirada_caixa_etapa

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_abertura_caixa
-------------------------------------------------------------------------------
--pr_egis_relatorio_fluxo_caixa
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
create procedure pr_egis_relatorio_retirada_caixa_etapa
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
declare @cd_documento           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @ic_valor_comercial     varchar(10)
declare @cd_tipo_destinatario   int 
declare @cd_grupo_relatorio     int 
declare @id                     int = 0 
declare @cd_vendedor            int
declare @cd_plano_financeiro    int = 0

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
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'

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
--------------------------------------------------------------------------------------------------------------------------
   select  
  
  @dt_inicial    = isnull(dt_inicial,''),
  @dt_final      = isnull(dt_final,'')
 -- @cd_plano_financeiro = isnull(cd_plano_financeiro,0)
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
      padding: 20px;
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
      padding: 10px;
    }

  
    th {
      background-color: #f2f2f2;
      color: #333;
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
      font-size: 14px;
      text-align: left;
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
  
order by  
  qt_ordem_atributo  
  
------------------------------------------------------------------------------------------------------------------  

  
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

  
drop table #AuxRelAtributo  
  
  
if isnull(@cd_parametro,0) = 2  
 begin  
  select * from #RelAtributo  
  return  
end  
  

set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
--set @dt_inicial = '10/09/2025'
--set @dt_final = '10/30/2025'

--------------------------------------------------------------------------------------------------------------------------
--Retirada do caixa---------------------------------------
 select
      IDENTITY(int,1,1)                                                  as cd_controle,
	  m.cd_movimento_caixa                                               as cd_movimento_caixa,
      m.dt_movimento_caixa                                               as dt_retirada,  
	  r.nm_motivo_retirada_caixa                                         as nm_motivo_retirada,
	  td.nm_tipo_despesa                                                 as nm_tipo_despesa,
	  max(l.nm_loja)													 as nm_loja,
	  max(nm_tipo_movimento_caixa)                                       as nm_tipo_movimento_caixa,
	  max(m.nm_obs_movimento_caixa)                                      as nm_obs_movimento_caixa,
	  max(isnull(m.vl_movimento_caixa,0))                                as vl_movimento_caixa,
      sum( isnull(m.vl_movimento_caixa,0) - isnull(m.vl_desconto,0) )    as vl_total,
	  max(m.vl_dinheiro)                                                 as vl_dinheiro,
	  max(m.vl_cheque)                                                   as vl_cheque,
	  count(distinct m.cd_movimento_caixa)                               as qt_retirada,
	  max( isnull(r.cd_cliente,0))                                       as cd_cliente


    into
      #Retirada_Etapa

     from
       movimento_caixa m
   	  left outer join motivo_retirada_caixa r   on r.cd_motivo_retirada_caixa = m.cd_motivo_retirada_caixa
	  left outer join loja l                    on l.cd_loja = m.cd_loja
	  left outer join tipo_movimento_caixa tmc  on m.cd_tipo_movimento_caixa = tmc.cd_tipo_movimento_caixa
	  left outer join tipo_despesa td on td.cd_tipo_despesa = m.cd_tipo_despesa
    where
	  m.cd_movimento_caixa = @cd_documento
	  
    group by
	  m.cd_movimento_caixa,
      m.dt_movimento_caixa,
  	  r.nm_motivo_retirada_caixa,
	  td.nm_tipo_despesa
		
	--select * from #Retirada_Etapa return

declare 
    @dt_retirada            datetime = '',
	@nm_motivo_retirada     varchar(160),
	@nm_tipo_despesa        varchar(60),
	@nm_obs_movimento_caixa varchar(160),
	@vl_total               float,
	@qt_retirada            int = 0,
	@vl_movimento_caixa     float = 0,
	@vl_dinheiro            float = 0,
	@vl_cheque              float = 0,
	@nm_loja                varchar(60)
						    
select 
	@dt_retirada            = dt_retirada,
	@nm_motivo_retirada     = nm_motivo_retirada,
	@nm_tipo_despesa        = nm_tipo_despesa,
	@nm_obs_movimento_caixa = nm_obs_movimento_caixa,
	@vl_total               = vl_total,
	@qt_retirada            = qt_retirada,
	@vl_movimento_caixa     = vl_movimento_caixa,
	@vl_dinheiro            = vl_dinheiro,
	@vl_cheque              = vl_cheque,
	@nm_loja			    = nm_loja

from #Retirada_Etapa
--------------------------------------------------------------------------------------------------------------
set @html_geral = '
    <div class="section-title">    
        <p style="text-align: center;">Retirada de Caixa Nº '+cast(isnull(@cd_documento,0) as varchar(20))+'</p>  
    </div>
	<table>
	<tr style="text-align:left;">
		<th>Data</th>
	</tr> 
	<tr class="tamanho">
		<td>'+isnull(dbo.fn_data_string(@dt_retirada),'')+'</td>
	</tr>
	<tr style="text-align:left;">
		<th>Valor Movimento</th>
	</tr> 
	<tr class="tamanho">
		<td>'+isnull(dbo.fn_formata_valor(@vl_movimento_caixa),'')+'</td>
	</tr>
	<tr style="text-align:left;">
		<th>Dinheiro</th>
	</tr> 
	<tr class="tamanho">
		<td>'+isnull(dbo.fn_formata_valor(@vl_dinheiro),'')+'</td>
	</tr>
	<tr style="text-align:left;">
		<th>Cheque</th>
	</tr> 
	<tr class="tamanho">
		<td>'+isnull(dbo.fn_formata_valor(@vl_cheque),'')+'</td>
	</tr>
   <tr style="text-align:left;">
		<th>Loja</th>
	</tr> 
	<tr class="tamanho">
		<td>'+isnull(@nm_loja,'')+'</td>
	</tr>
	<tr style="text-align:left;">
		<th>Motivo</th>
	</tr> 
	<tr class="tamanho">
		<td>'+isnull(@nm_motivo_retirada,'')+'</td>
	</tr>
	<tr style="text-align:left;">
		<th>Tipo de Despesa</th>
	</tr> 
	<tr class="tamanho">
		<td>'+isnull(@nm_tipo_despesa,'')+'</td>
	</tr>
	<tr style="text-align:left;">
		<th>Observação</th>
	</tr> 
	<tr class="tamanho">
		<td>'+isnull(@nm_obs_movimento_caixa,'')+'</td>
	</tr>
	</table>'

					   
--------------------------------------------------------------------------------------------------------------

set @html_rodape =
    '
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>
    </div>
	  </body>
</html>'
  


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
--exec pr_egis_relatorio_retirada_caixa_etapa 374,0,''
------------------------------------------------------------------------------

