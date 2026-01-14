IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_carga' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_carga

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_carga
-------------------------------------------------------------------------------
--pr_egis_relatorio_carga
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
create procedure pr_egis_relatorio_carga
@cd_relatorio int   = 0,
@cd_documento int   = 0,
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
--declare @cd_documento           int = 0
--declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @ic_valor_comercial     varchar(10)
declare @cd_tipo_destinatario   int 
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
  --select @cd_documento           = valor from #json where campo = 'cd_documento_form'
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
 
 --select @cd_relatorio

select
  @titulo      = nm_relatorio,
  @ic_processo = isnull(ic_processo_relatorio, 'N')
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio
 
 
----------------------------------------------------------------------------------------------------------------------------
/*
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
*/
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
            margin: 30px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            border-bottom: 1px solid #000;
            padding-bottom: 5px;
            margin-bottom: 10px;
            font-size: 20px;
        }

        .info {
            font-size: 18px;
        }

        .top-tables {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            margin-bottom: 15px;
        }

        .table-wrapper {
            border: 1px solid #000;
            padding: 10px;
            text-align: center;
            flex: 1;
            min-width: 150px;
        }

        h3 {
            font-size: 20px;
            margin-bottom: 5px;
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
            font-size: 20px;
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
--Procedure de Cada Relat�rio-------------------------------------------------------------------------------------

select a.*, g.nm_grupo_relatorio into #RelAtributo 
from
  egisadmin.dbo.Relatorio_Atributo a 
  left outer join egisadmin.dbo.relatorio_grupo g on g.cd_grupo_relatorio = a.cd_grupo_relatorio
where 
  a.cd_relatorio = @cd_relatorio
order by
  qt_ordem_atributo

declare @cd_item_relatorio  int           = 0
declare @nm_cab_atributo    varchar(100)  = ''
declare @nm_dados_cab_det   nvarchar(max) = ''
declare @nm_grupo_relatorio varchar(60)   = ''


--select * from egisadmin.dbo.relatorio_grupo

select * into #AuxRelAtributo from #RelAtributo order by qt_ordem_atributo

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

--select @nm_dados_cab_det

--select @nm_grupo_relatorio,@nm_dados_cab_det,* from #RelAtributo
declare @dt_atual nvarchar(20)
set @dt_atual          = CONVERT(VARCHAR, GETDATE(), 103) + ' 00:00:00'

--------------------------------------------------------------------------------------------------------------------------
--- select cliente Relatório de Carga
declare @cd_carga int = 0 

set @cd_carga = @cd_documento
  select      
    identity(int,1,1)      as cd_controle,
    mdc.cd_carga,
    mdc.cd_pedido_venda    as cd_item_carga,
    c.cd_cliente,
    c.nm_razao_social_cliente,
    c.nm_fantasia_cliente,          
    pv.vl_total_pedido_venda, --Valor 
    pv.qt_bruto_pedido_venda, --Peso
    v.nm_fantasia_vendedor,               
    v.nm_vendedor,            --Vendedor                       
    tp.nm_tipo_pedido,
    cast('' as varchar(20)) as nm_reentrega,
    t.nm_transportadora,      --Transportadora            
    t.nm_fantasia,
    e.nm_entregador,
    vei.cd_placa_veiculo,
    vei.nm_veiculo,
    case when isnull(i.nm_itinerario,'') = ''
      then isnull(ic.nm_itinerario,'')
      else isnull(i.nm_itinerario,'')
    end                   as nm_itinerario,
	cid.nm_cidade         as nm_cidade,
	est.sg_estado         as nm_estado,
    convert(nvarchar(20),@dt_hoje,103)              as dt_impressao,
	fp.nm_forma_pagamento                           as nm_forma_pagamento
  into
    #Carga_Relatorio
  from
    pedido_venda_romaneio mdc                     with (nolock)
    inner join pedido_venda pv                    with (nolock) on pv.cd_pedido_venda          = mdc.cd_pedido_venda
    inner join Preparacao_Carga prc               with (nolock) on prc.cd_carga                = mdc.cd_carga
    left outer join Tipo_Pedido tp                with (nolock) on tp.cd_tipo_pedido           = pv.cd_tipo_pedido
    left outer join transportadora t              with (nolock) on t.cd_transportadora         = pv.cd_transportadora
    left outer join vendedor v                    with (nolock) on v.cd_vendedor               = pv.cd_vendedor
    left outer join Entregador e                  with (nolock) on e.cd_entregador             = prc.cd_entregador
    left outer join Veiculo vei                   with (nolock) on vei.cd_veiculo              = prc.cd_veiculo
    left outer join Itinerario i                  with (nolock) on i.cd_itinerario             = prc.cd_itinerario
    left outer join Cliente c                     with (nolock) on c.cd_cliente                = pv.cd_cliente
    left outer join Itinerario ic                 with (nolock) on ic.cd_itinerario            = c.cd_itinerario
    left outer join Cidade cid                    with (nolock) on cid.cd_pais                 = c.cd_pais
                                                               and cid.cd_estado               = c.cd_estado
                                                               and cid.cd_cidade               = c.cd_cidade
    left outer join  Estado est                   with (nolock) on est.cd_estado               = c.cd_estado
                                                               and est.cd_pais                 = c.cd_pais
    left outer join Cliente_Perfil cp             with (nolock) on cp.cd_cliente               = c.cd_cliente
	left outer join Forma_Pagamento fp            with (nolock) on fp.cd_forma_pagamento       = pv.cd_forma_pagamento
  where
    mdc.cd_carga = @cd_carga
--------------------------------------------------------------------------------------------------------------------------

  select
    count(cd_item_carga)       as qt_entrega,
    max(cd_carga)              as cd_carga,
    max(nm_transportadora)     as nm_transportadora,
    max(nm_entregador)         as nm_entregador,
    max(cd_placa_veiculo)      as nm_placa_veiculo,
    max(nm_veiculo)            as nm_veiculo,
    sum(vl_total_pedido_venda) as vl_total_carga,
    sum(qt_bruto_pedido_venda) as qt_peso_total_carga,
    @dt_hoje                   as dt_impressao
	into
	#capa
  from
    #Carga_Relatorio
-------------------------------------------------------------------------------------------------------------------------
  select             
	identity(int,1,1)         as cd_controle,
    cd_item_carga             as cd_item_carga,
    cd_cliente                as cd_cliente,
    nm_razao_social_cliente   as nm_razao_social_cliente,
    nm_fantasia_cliente       as nm_fantasia_cliente,          
    vl_total_pedido_venda     as vl_total_pedido_venda, --Valor 
    qt_bruto_pedido_venda     as qt_bruto_pedido_venda, --Peso
    nm_fantasia_vendedor,               
    nm_vendedor               as nm_vendedor,            --Vendedor                       
    nm_tipo_pedido,
    nm_reentrega              as nm_reentrega,
	nm_cidade                 as nm_cidade,
	nm_estado                 as nm_estado,
	nm_forma_pagamento        as nm_forma_pagamento
	into
	#carga_relatorio_item
  from
    #Carga_Relatorio

 
  --select * from #carga_relatorio_item
  --return
-----------------------------------------------------------------------------------------------------------------------------
declare @cd_romaneio                 int = 0
declare @nm_motorista                nvarchar(60)
declare @nm_placa                    nvarchar(20)  
declare @qt_entrega                  int = 0
declare @dt_saida                    nvarchar(20)
declare @hora_saida                  nvarchar(10)
declare @ds_km                       nvarchar(10)
declare @dt_chegada                  nvarchar(20)
declare @hora_chegada                nvarchar(10)
declare @ds_km_chegada               nvarchar(10)
declare @vl_total                    float = 0 
declare @peso_total                  float = 0
declare @cd_ordem                    int = 0
declare @nm_cliente                  nvarchar(60)
declare @cd_pedido                   nvarchar(20)
declare @valor                       float = 0
declare @peso                        float = 0
declare @nm_vendedor                 nvarchar(60)
declare @ds_observacao               nvarchar(100)
Declare @nm_fantasia_cliente         nvarchar(60)
--Declare @nm_cidade                   nvarchar(60)
Declare @nm_estado                   nvarchar(60)
declare @vl_total_entrega            float = 0 
DECLARE @nm_forma_pagamento          nvarchar(60)
-------------------------------------------------------------------------------------------------------------
select 
		@cd_romaneio                 = cd_carga,
		@nm_motorista                = nm_entregador,
		@nm_placa                    = nm_placa_veiculo,
		@qt_entrega                  = qt_entrega,
		@vl_total                    = vl_total_carga,
		@peso_total                  = qt_peso_total_carga


from #capa


  select 

	@vl_total_entrega = count(cd_item_carga)

  from #carga_relatorio_item
--------------------------------------------------------------------------------------------------------------
set @html_geral = '    <div class="section-title" style="margin-top: 50px; text-align: center;">ROMANEIO DE ENTREGA</div>
    <div style="margin-top: 35px;">
        <div class="header">
            <div class="info">
                <p>ROMANEIO: <strong>'+cast(isnull(@cd_romaneio,'') as nvarchar(20))+'</strong></p>
            </div>
            <div class="info">
                <p>Motorista: '+isnull(@nm_motorista,'')+'</p>
                <p>PLACA: '+isnull(@nm_placa,'')+'</p>
            </div>
            <div class="info">
                <p>Qtd.Entrega: '+cast(isnull(@qt_entrega,'')as nvarchar(20))+' </p>
            </div>
            <div class="info">
                <p>'+isnull(@dt_atual,'')+'</p>
            </div>
        </div>

        <div class="top-tables" style="margin-top: 20px;">
            <div class="table-wrapper">
                <h3>ENTREGA</h3>
                <div>
                    <tr>
                        <p>Data: </p>
                        <p>HORA: </p>
                        <p>KM: </p>
                    </tr>
                </div>
            </div>
            <div class="table-wrapper">
                <h3>CHEGADA</h3>
                    <div>
                        <tr>
                            <p>Data: </p>
                            <p>HORA: </p>
                            <p>KM: </p>
                        </tr>
                    </div>
            </div>
            <div class="table-wrapper">
                <h3>VALOR TOTAL</h3>
                <div>
                    <tr>
                        <p>'+cast(isnull(dbo.fn_formata_valor(@vl_total),'')as nvarchar(20))+'</p>
                    </tr>
                </div>
            </div>
            <div class="table-wrapper">
                <h3>PESO TOTAL</h3>
                <div>
                    <tr>
                        <p>'+cast(isnull(@peso_total,'')as nvarchar(20))+'</p>
                    </tr>
                </div>
            </div>
        </div>

        <table style="margin-top: 50px;">
            <thead>
                <tr>
                    <th>Código</th>
                    <th>Cliente</th>
                    <th>Pedido</th>
                    <th>Total $</th>
                    <th>Peso</th>
                    <th>Vendedor</th>
					<th>Forma de Pagamento</th>
                    <th>Cidade</th>
					<th>UF</th>
					<th>Observação</th>
                </tr>
            </thead>
            <tbody>'
					   
					 
--------------------------------------------------------------------------------------------------------------
DECLARE @id int = 0 

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #carga_relatorio_item)
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,
		@cd_ordem                    = cd_cliente,
		@nm_cliente                  = nm_razao_social_cliente,
		@nm_fantasia_cliente         = nm_fantasia_cliente,
		@cd_pedido                   = cd_item_carga,
		@valor                       = vl_total_pedido_venda,
		@peso                        = qt_bruto_pedido_venda,
		@nm_vendedor                 = nm_vendedor,
		@ds_observacao               = nm_reentrega,
		@nm_cidade                   = nm_cidade,
		@nm_estado                   = nm_estado,
		@nm_forma_pagamento          = nm_forma_pagamento

    FROM #carga_relatorio_item

    SET @html_geral = @html_geral +
        '<tr >
           <td>'+cast(isnull(@cd_ordem,0)as nvarchar(20))+'</td>
		   <td>'+isnull(@nm_cliente,'')+'</td>
		   <td>'+isnull(@cd_pedido,'')+'</td>
		   <td>'+cast(isnull(dbo.fn_formata_valor(@valor),0)as nvarchar(20))+'</td>
		   <td>'+cast(isnull(@peso,0)as nvarchar(20))+'</td>
		   <td>'+isnull(@nm_vendedor,'')+'</td>
		   <td>'+isnull(@nm_forma_pagamento,'')+'</td>
		   <td>'+isnull(@nm_cidade,'')+'</td>
		   <td>'+isnull(@nm_estado,'')+'</td>
		   <td>'+isnull(@ds_observacao,'')+'</td>
        </tr>'

    DELETE FROM #carga_relatorio_item WHERE cd_controle = @id
END
--------------------------------------------------------------------------------------------------------------------




set @html_rodape =
    '  </tbody>
        </table>
    </div>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
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
---exec pr_egis_relatorio_carga 235,1,''
------------------------------------------------------------------------------

