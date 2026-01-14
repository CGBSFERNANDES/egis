IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_pedidos_aguardando_aprovacao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_pedidos_aguardando_aprovacao

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_pedidos_aguardando_aprovacao
-------------------------------------------------------------------------------
--pr_egis_relatorio_pedidos_aguardando_aprovacao
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
create procedure pr_egis_relatorio_pedidos_aguardando_aprovacao
@cd_relatorio int   = 0,
@cd_parametro int   = 0, 
@json nvarchar(max) = '' 


as


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
set @json = isnull(@json,'')
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

        td {
            text-align: center;
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
            font-size: 12px;
            text-align: center;
        }
        .tamanhoTotal {
            font-size: 14px;
            text-align: center;
			font-weight: bold;
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
--set @dt_inicial = '07/01/2025'
--set @dt_final = '09/30/2025'
----set @cd_plano_financeiro = 0 
--------------------------------------------------------------------------------------------------------------------------

select
  identity(int,1,1) as cd_controle,
  a.cd_movimento,
  a.dt_movimento,
  a.cd_processo,
  p.nm_processo,
  dias = ( cast( getdate() - a.dt_movimento as int) ),
  a.cd_tipo_aprovacao,
  ta.nm_tipo_aprovacao,
  a.cd_ordem_aprovacao,
  a.cd_usuario_aprovacao,
  u.nm_usuario,
  u.nm_fantasia_usuario,
  isnull(u.nm_email_usuario,'' ) as nm_email_usuario,
  a.cd_documento,
  a.cd_item_documento,
  a.cd_destinatario,
  a.cd_tipo_destinatario,
  a.cd_tipo_parametro,
  a.cd_tipo_valor,
  a.nm_titulo_documento,
  a.cd_motivo,
  a.nm_obs_motivo,
  cast(  a.ds_aprovacao as varchar(8000)) as ds_aprovacao,
  a.dt_aprovacao_movimento,
  a.hr_aprovacao_movimento,
  a.cd_identificacao_documento,
  a.cd_usuario,
  a.dt_usuario,
  a.dt_rejeicao_movimento,
  a.hr_rejeicao_movimento,	
  a.qt_movimento,
  a.vl_movimento,
  te.cd_tipo_email,
  te.nm_tipo_email,
  am.nm_motivo,
  case when isnull(a.cd_motivo,0) = 0 then
   'Aprovar'
  else
    case when am.ic_tipo_motivo = 'A' then 'Aprovado' else 'Rejeitado' end
  end   as nm_tipo_motivo,
  uo.nm_fantasia_usuario          as nm_fantasia_retorno,
  isnull(uo.nm_email_usuario,'' ) as nm_email_usuario_retorno,
  d.cd_departamento,
  d.nm_departamento,
  ISNULL(c.nm_fantasia_cliente,'') as nm_fantasia_destinatario,
  isnull(p.cd_relatorio,0)         as cd_relatorio,
  r.nm_relatorio,
  right(left(convert(varchar,pv.hr_inicial_pedido,121),16),5) as hr_inicial_pedido,
  tp.nm_tipo_pedido                as nm_tipo_pedido,
  pv.cd_cliente        			   as cd_cliente,
  cli.nm_fantasia_cliente		   as nm_fantasia_cliente,
  v.nm_vendedor                    as nm_vendedor,
  ef.nm_fantasia_empresa           as nm_fantasia_empresa,
  cid.nm_cidade                    as nm_cidade,
  est.sg_estado                    as sg_estado,
  pv.dt_pedido_venda               as dt_pedido_venda,
  pv.cd_pedido_venda               as cd_pedido_venda

	into
	#DocumentoDeclinado

from
  aprovacao_movimento a
  inner join aprovacao_processo p           on p.cd_processo        = a.cd_processo
  inner join pedido_venda pv                on pv.cd_pedido_venda   = a.cd_documento
  left outer join tipo_email te             on te.cd_tipo_email     = p.cd_tipo_email
  left outer join tipo_aprovacao ta         on ta.cd_tipo_aprovacao = a.cd_tipo_aprovacao
  left outer join egisadmin.dbo.usuario u   on u.cd_usuario         = a.cd_usuario_aprovacao
  left outer join aprovacao_motivo am       on am.cd_motivo         = a.cd_motivo
  left outer join egisadmin.dbo.usuario uo  on uo.cd_usuario        = a.cd_usuario_origem
  left outer join Departamento d            on d.cd_departamento    = uo.cd_departamento
  left outer join Cliente c                 on c.cd_cliente         = a.cd_documento and a.cd_tipo_valor = 3
  left outer join Cliente cli               on cli.cd_cliente       = pv.cd_cliente
  left outer join Vendedor v                on v.cd_vendedor        = pv.cd_vendedor
  left outer join egisadmin.dbo.relatorio r on r.cd_relatorio       = p.cd_relatorio
  left outer join pedido_venda_empresa pve  on pve.cd_pedido_venda  = pv.cd_pedido_venda
  left outer join empresa_faturamento ef    on ef.cd_empresa        = pve.cd_empresa
  left outer join tipo_pedido tp            on tp.cd_tipo_pedido    = pv.cd_tipo_pedido
  left outer join cidade cid                on cid.cd_cidade        = cli.cd_cidade 
  left outer join estado est                on est.cd_estado        = cli.cd_estado 

  where    
  a.dt_movimento between @dt_inicial and @dt_final
  --and 
  --a.dt_aprovacao_movimento is null
  --and
  --a.dt_rejeicao_movimento is not null
  --select * from #DocumentoDeclinado return
--------------------------------------------------------------------------------------------------------------
 declare @qt_documento float = 0 
 select 
	@qt_documento = count(cd_pedido_venda)
 from 
    #DocumentoDeclinado
--------------------------------------------------------------------------------------------------------------

set @html_geral = '
 <div class="section-title">  
        <p style="display: inline;text-align: left;">Período: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 20%;">Pedidos Aguardando Aprovação</p>  
    </div> 
	<table>
	<tr style="text-align:center;">
            <th>HORA</th>
            <th>PEDIDO</th>
            <th>EMISSÃO</th>
            <th>TIPO</th>
            <th>CÓDIGO</th>
            <th>CLIENTE</th>
            <th>VENDEDOR</th>
            <th>EMPRESA</th>
            <th>VALOR</th>
            <th>CIDADE</th>
			<th>UF</th>
        </tr>'
		   
--------------------------------------------------------------------------------------------------------------

while exists ( select top 1 cd_controle from #DocumentoDeclinado)
begin
	select top 1

		@id          = cd_controle,
	    @html_geral  = @html_geral + '
		                          <tr class="tamanho">
									<td>'+isnull(hr_inicial_pedido,'')+'</td>						
									<td>'+cast(isnull(cd_pedido_venda,0)as varchar)+'</td>
									<td>'+isnull(dbo.fn_data_string(dt_pedido_venda),'')+'</td>
									<td>'+isnull(nm_tipo_pedido,'')+'</td>	
									<td>'+cast(isnull(cd_cliente,0)as varchar)+'</td>
									<td>'+isnull(nm_fantasia_cliente,'')+'</td>
									<td>'+isnull(nm_vendedor,'')+'</td>
									<td>'+isnull(nm_fantasia_empresa,'')+'</td>
									<td>'+cast(isnull(dbo.fn_formata_valor(vl_movimento),0)as nvarchar(20))+'</td>
									<td>'+isnull(nm_cidade,'')+'</td>
									<td>'+isnull(sg_estado,'')+'</td>									
								  </tr>'

     from #DocumentoDeclinado
	 delete from #DocumentoDeclinado where cd_controle = @id
 end
					 
--------------------------------------------------------------------------------------------------------------

set @html_rodape =
    '
	</table>
	<div class="section-title">  
	<p>Total Aguardando Aprovação: <td>'+cast(isnull(@qt_documento,0)as varchar)+'</td></p>
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


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_pedidos_aguardando_aprovacao 385,0,''
------------------------------------------------------------------------------

