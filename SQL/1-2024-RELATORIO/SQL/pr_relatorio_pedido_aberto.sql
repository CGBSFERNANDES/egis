IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_pedido_aberto' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_pedido_aberto

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_pedido_aberto
-------------------------------------------------------------------------------
--pr_relatorio_pedido_aberto
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
create procedure pr_relatorio_pedido_aberto
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



--------------------------------------------------------------------------------------------------------

--set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
--set @cd_parametro      = 0
set @cd_empresa        = 0
set @cd_form           = 0
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
  select  
  @dt_inicial		= dt_inicial,
  @dt_final         = dt_final,
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
--- select cliente

select
  identity(int,1,1)                          as cd_controle,
  case when ISNULL(hr_inicial_pedido,'')<>'' then
  right(left(convert(varchar,p.hr_inicial_pedido,121),16),5)
  else
    FORMAT(p.dt_usuario, 'HH:mm')
  end                                        as hr_inicial_consulta,
  v.nm_fantasia_vendedor                     as nm_fantasia_vendedor,  
  	case when @cd_empresa in (329) then
	   max(ap.nm_aplicacao_produto) 
	else 
	   ''
	end                                      as nm_aplicacao_produto,
  dbo.fn_data_string(p.dt_pedido_venda)      as dt_pedido_venda,
  p.cd_pedido_venda                          as cd_pedido_venda,
  tp.nm_tipo_pedido                          as nm_tipo_pedido, 
  c.cd_cliente                               as cd_cliente,
  c.nm_fantasia_cliente                      as nm_fantasia_cliente,
  c.nm_razao_social_cliente					 as nm_razao_social_cliente,
   
  MAX(ISNULL(CAST(p.vl_total_pedido_ipi AS DECIMAL(18,2)), 0))        as vl_total_pedido,
  max(est.sg_estado)                         as sg_estado,
  max(cid.nm_cidade)                         as nm_cidade,
  max(cp.nm_condicao_pagamento)              as nm_condicao_pagamento,
  max(fp.nm_forma_pagamento)                 as nm_forma_pagamento
  into
    #Pedido

from
  Pedido_Venda p
  inner join cliente c                          on c.cd_cliente             = p.cd_cliente
  LEFT outer join Cliente_Informacao_Credito ic on ic.cd_cliente            = p.cd_cliente
  LEFT outer join Estado est                    on est.cd_estado            = c.cd_estado
  inner join cidade cid                         on cid.cd_cidade            = c.cd_cidade
  left outer join tipo_pedido tp                on tp.cd_tipo_pedido        = p.cd_tipo_pedido
  inner join vendedor v                         on v.cd_vendedor            = p.cd_vendedor
  inner join pedido_venda_item i                on i.cd_pedido_venda        = p.cd_pedido_venda
  left outer join Pedido_Venda_Empresa pve      on pve.cd_pedido_venda      = p.cd_pedido_venda
  left outer join Aplicacao_Produto ap          on ap.cd_aplicacao_produto = p.cd_aplicacao_produto
  left outer join empresa_faturamento ef        on ef.cd_empresa            = pve.cd_empresa
  left outer join condicao_pagamento cp         on cp.cd_condicao_pagamento = p.cd_condicao_pagamento
  left outer join forma_pagamento fp            on fp.cd_forma_pagamento    = case when 
                                                                                 isnull(p.cd_forma_pagamento,0)>0 
                                                                              then
																			     p.cd_forma_pagamento 
																			  else 
																			     ic.cd_forma_pagamento 
																			  end

where
  p.dt_pedido_venda between @dt_inicial and @dt_final
  and
  i.dt_cancelamento_item is null
  and
  ISNULL(i.qt_saldo_pedido_venda,0)>0
  and 
  p.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then p.cd_vendedor else isnull(@cd_vendedor,0) end

group by
  p.hr_inicial_pedido, 
  p.dt_usuario,
  p.cd_pedido_venda,
  p.dt_pedido_venda,
  tp.nm_tipo_pedido,
  c.cd_cliente,
  c.nm_fantasia_cliente,
  v.nm_fantasia_vendedor,
  c.nm_razao_social_cliente


  order by
    v.nm_fantasia_vendedor, 
	p.dt_pedido_venda,
    p.cd_pedido_venda
------------------------------------------------------------------------------------------------------------		 
   
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #Pedido  
  return  
 end  

--------------------------------------------------------------------------------------------------------------
declare @hr_inicial_consulta         nvarchar(10)
declare @nm_fantasia_vendedor        nvarchar(60)
declare @dt_consulta                 nvarchar(20)
declare @cd_consulta                 int = 0
declare @nm_tipo_pedido              nvarchar(60)
declare @cd_cliente_tb               nvarchar(20)
declare @nm_fantasia_cliente         nvarchar(60)
declare @vl_total_pedido             nvarchar(20)
declare @sg_estado_tb                nvarchar(20)
declare @nm_cidade_tb                nvarchar(60)
Declare @nm_condicao_pagamento_tb    nvarchar(40)
declare @nm_forma_pagamento          nvarchar(40)
DECLARE @vl_total_grupo              float = 0
DECLARE @qt_total                    float = 0
DECLARE @vl_total                    float = 0
declare @nm_razao_social_cliente     nvarchar(60)
declare @nm_aplicacao_produto		 nvarchar(120)


select 
	@vl_total_grupo  = count(cd_controle),
	@qt_total = count(cd_pedido_venda),
    @vl_total = sum(vl_total_pedido)
from #Pedido

--------------------------------------------------------------------------------------------------------------

set @html_geral = '<div class="section-title">    
    <p style="display: inline;">Período: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>     
    <p style="display: inline; text-align: center; padding: 15%;">Pedidos em Aberto - Carteira de Pedidos</p>    
</div>
	<div>
    <table>  
		<tr class="tamanho">
		  <th>Hora</th>
		  <th>Vendedor</th>
		  <th>Emissão</th>
		  <th>Pedido</th>
		  <th>Tipo</th>
		  <th>Aplicação</th>
		  <th>Cliente</th>
		  <th>Razão Social</th>
		  <th>Total $</th>
		  <th>Estado</th>
		  <th>Cidade</th>
		  <th>Condição Pagamento</th>
		  <th>Forma Pagamento</th>
		</tr>'
					   
--------------------------------------------------------------------------------------------------------------
DECLARE @id int = 0 

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #Pedido)
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,
        @hr_inicial_consulta         = hr_inicial_consulta,
        @nm_fantasia_vendedor        = nm_fantasia_vendedor,
        @dt_consulta                 = CONVERT(VARCHAR(15), dt_pedido_venda, 103),
        @cd_consulta                 = cd_pedido_venda,
        @nm_tipo_pedido              = nm_tipo_pedido,
        @cd_cliente_tb               = cd_cliente,
        @nm_fantasia_cliente         = nm_fantasia_cliente,
        @vl_total_pedido             = vl_total_pedido,
        @sg_estado_tb                = sg_estado,
        @nm_cidade_tb                = nm_cidade,
        @nm_condicao_pagamento_tb    = nm_condicao_pagamento,
        @nm_forma_pagamento          = nm_forma_pagamento,
		@nm_razao_social_cliente     = nm_razao_social_cliente,
		@nm_aplicacao_produto        = nm_aplicacao_produto
    FROM #Pedido

    SET @html_geral = @html_geral +
        '<tr class="tamanho">
            <td>' + ISNULL(@hr_inicial_consulta, '') + '</td>
            <td>' + ISNULL(@nm_fantasia_vendedor, '') + '</td>
            <td>' + ISNULL(@dt_consulta, '') + '</td>
            <td>' + CAST(ISNULL(@cd_consulta, '') AS NVARCHAR(10)) + '</td>
            <td>' + ISNULL(@nm_tipo_pedido, '') + '</td>
			<td>' + ISNULL(@nm_aplicacao_produto, '') + '</td>
            <td>' + ISNULL(@nm_fantasia_cliente, '') + ' (' + CAST(ISNULL(@cd_cliente_tb, '') AS NVARCHAR(10)) + ')</td>
			<td>' + ISNULL(@nm_razao_social_cliente, '') + '</td>
            <td>' + CAST(ISNULL(dbo.fn_formata_valor(@vl_total_pedido), 0) AS NVARCHAR(20)) + '</td>
            <td>' + ISNULL(@sg_estado_tb, '') + '</td>
            <td>' + ISNULL(@nm_cidade_tb, '') + '</td>
            <td>' + ISNULL(@nm_condicao_pagamento_tb, '') + '</td>
            <td>' + ISNULL(@nm_forma_pagamento, '') + '</td>
        </tr>'

    DELETE FROM #Pedido WHERE cd_controle = @id
END
--------------------------------------------------------------------------------------------------------------------




set @html_rodape =
    '</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	</div>
	<div class="section-title">
      <p style="margin-bottom:5px ;">Total Pedido: '+cast(isnull(@qt_total,0) as nvarchar(10))+'</p>
      <p>Valor Total: '+cast(isnull(dbo.fn_formata_valor(@vl_total),0) as nvarchar(15))+'</p>
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
--exec pr_relatorio_pedido_aberto 231,''
------------------------------------------------------------------------------
