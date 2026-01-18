IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_visita_checkin' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_visita_checkin

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_visita_checkin
-------------------------------------------------------------------------------
--pr_egis_relatorio_visita_checkin
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
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_visita_checkin
@cd_relatorio  int  = 0,
@cd_parametro  int = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')
declare @data_grafico_bar       nvarchar(max)
declare @cd_empresa             int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
--declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
DECLARE @id                     int = 0   
declare @cd_cliente             int = 0
declare @cd_cliente_grupo       int = 0  
declare @cd_grupo_relatorio     int    
declare @cd_vendedor            int    
declare @nm_razao_social        varchar(60) = ''
declare @cd_categoria_produto   int = 0 
declare @cd_pedido_venda        int = 0 
declare @cd_tipo_pedido         int = 0
declare @cd_ramo_atividade      int = 0
declare @cd_status_cliente      int = 0 
--Dados do Relatório---------------------------------------------------------------------------------

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
			@cd_cep_empresa			    varchar(20) = '',			
			@nm_bairro					varchar(200) = '',
			@cd_numero_endereco			varchar(20) = '',
			@cd_telefone				varchar(20) = '',
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

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
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
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'


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
select    
  @dt_inicial			  = dt_inicial,    
  @dt_final				  = dt_final,    
  @cd_vendedor			  = isnull(cd_vendedor,0)
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
--Dados do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------

declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabeçalho da Empresa
declare @html_titulo     nvarchar(max) = '' --Título
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe
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

-- Obtém a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
---------------------------
--Cabeçalho da Empresa
----------------------------------------------------------------------------------------------------------------------

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
			flex:1;
        }  
  
        h2 {  
            color: #333;  
        }  
  
        table {  
            width: 100%;  
            border-collapse: collapse;  
            margin-bottom: 20px;  
            font-size: 12px;  
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
  tr {  
   page-break-inside: avoid;    
   page-break-after: auto;  
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
            text-align: center;  
        }  
  #salva {  
     background-color: #1976D2;  
     color: white;  
     border: none;  
     padding: 10px 20px;  
     font-size: 16px;  
     cursor: pointer;  
     border-radius: 5px;  
     transition: background-color 0.3s;  
   }  
  
    #salva:hover {  
     background-color: #1565C0;  
   }  
    .nao-imprimir {  
            display: none;  
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
    
if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    
  
--select @nm_dados_cab_det

--select @nm_grupo_relatorio,@nm_dados_cab_det,* from #RelAtributo
--------------------------------------------------------------------------------------------------------------------------
--set @cd_vendedor = 36
--set @dt_inicial = '09/01/2025'
--set @dt_final = '09/09/2025'
SELECT 
  IDENTITY(int,1,1)           as cd_controle,
  MAX(v.nm_vendedor)               AS nm_vendedor,
  max(v.cd_vendedor)			   as cd_vendedor,
  MAX(cli.nm_razao_social_cliente) AS nm_razao_social_cliente, 
  MAX(cli.nm_fantasia_cliente)     AS nm_fantasia_cliente,
  MAX(cli.nm_endereco_cliente)     AS nm_endereco_cliente,
  MAX(cli.cd_numero_endereco)      AS cd_numero_endereco,
  MAX(cli.nm_bairro)               AS nm_bairro,

  MAX(
    CASE 
      WHEN cli.cd_tipo_pessoa = 1 
      THEN ISNULL(dbo.fn_formata_cnpj(cli.cd_cnpj_cliente),'') 
      ELSE ISNULL(dbo.fn_formata_cpf(cli.cd_cnpj_cliente),'') 
    END
  ) AS cd_cnpj_cliente,
  pv.cd_pedido_venda as cd_pedido_venda,
  MAX(cd.cd_consulta)              AS cd_consulta,
  MAX(cd.qt_latitude)              AS latitude_cd,
  MAX(cd.qt_longitude)             AS longitude_cd,
  MAX(cli.qt_latitude_cliente)     AS latitude_cli,
  MAX(cli.qt_longitude_cliente)    AS longitude_cli,
  MAX(c.dt_entrada_consulta)       AS dt_entrada_consulta,
  MAX(c.dt_fechamento_consulta)    AS dt_fechamento_consulta,
  CONVERT(varchar, MAX(vb.dt_baixa_visita), 103) AS dt_baixa_visita,     
  CONVERT(varchar, MAX(vv.dt_visita), 103) AS dt_visita,
                 
  MAX(vv.hr_inicio_visita)         AS hr_inicio_visita,
  MAX(vv.hr_fim_visita)            AS hr_fim_visita,

  CONVERT(VARCHAR, DATEDIFF(SECOND, MAX(c.dt_entrada_consulta), MAX(vb.dt_baixa_visita)) / 3600) + 
  CASE WHEN DATEDIFF(SECOND, MAX(c.dt_entrada_consulta), MAX(vb.dt_baixa_visita)) / 3600 > 0 THEN 'h:' ELSE '' END +
  CONVERT(VARCHAR, (DATEDIFF(SECOND, MAX(c.dt_entrada_consulta), MAX(vb.dt_baixa_visita)) % 3600) / 60) + 
  CASE WHEN (DATEDIFF(SECOND, MAX(c.dt_entrada_consulta), MAX(vb.dt_baixa_visita)) % 3600) / 60 > 0 THEN 'min:' ELSE '' END +
  CONVERT(VARCHAR, DATEDIFF(SECOND, MAX(c.dt_entrada_consulta), MAX(vb.dt_baixa_visita)) % 60) + 
  CASE WHEN DATEDIFF(SECOND, MAX(c.dt_entrada_consulta), MAX(vb.dt_baixa_visita)) % 60 > 0 THEN 's' ELSE '' END AS hora_diferenca,

  CASE 
    WHEN MAX(vv.dt_visita) IS NOT NULL AND MAX(vv.hr_inicio_visita) IS NOT NULL 
         AND MAX(vb.dt_baixa_visita) IS NOT NULL AND MAX(vv.hr_fim_visita) IS NOT NULL THEN
        CASE 
            WHEN DATEDIFF(SECOND, 
                    CAST(CONVERT(DATETIME, MAX(vv.dt_visita), 103) + ' ' + MAX(vv.hr_inicio_visita) AS DATETIME),
                    CAST(CONVERT(DATETIME, MAX(vb.dt_baixa_visita), 103) + ' ' + MAX(vv.hr_fim_visita) AS DATETIME)
                ) >= 3600 THEN 
                FORMAT(DATEDIFF(SECOND, 
                    CAST(CONVERT(DATETIME, MAX(vv.dt_visita), 103) + ' ' + MAX(vv.hr_inicio_visita) AS DATETIME),
                    CAST(CONVERT(DATETIME, MAX(vb.dt_baixa_visita), 103) + ' ' + MAX(vv.hr_fim_visita) AS DATETIME)
                ) / 3600, '0') + 'h e ' +
                FORMAT((DATEDIFF(SECOND, 
                    CAST(CONVERT(DATETIME, MAX(vv.dt_visita), 103) + ' ' + MAX(vv.hr_inicio_visita) AS DATETIME),
                    CAST(CONVERT(DATETIME, MAX(vb.dt_baixa_visita), 103) + ' ' + MAX(vv.hr_fim_visita) AS DATETIME)
                ) % 3600) / 60, '00') + 'min'
            
            WHEN DATEDIFF(SECOND, 
                    CAST(CONVERT(DATETIME, MAX(vv.dt_visita), 103) + ' ' + MAX(vv.hr_inicio_visita) AS DATETIME),
                    CAST(CONVERT(DATETIME, MAX(vb.dt_baixa_visita), 103) + ' ' + MAX(vv.hr_fim_visita) AS DATETIME)
                ) >= 60 THEN 
                FORMAT(DATEDIFF(SECOND, 
                    CAST(CONVERT(DATETIME, MAX(vv.dt_visita), 103) + ' ' + MAX(vv.hr_inicio_visita) AS DATETIME),
                    CAST(CONVERT(DATETIME, MAX(vb.dt_baixa_visita), 103) + ' ' + MAX(vv.hr_fim_visita) AS DATETIME)
                ) / 60, '0') + 'min'
            
            ELSE 
                FORMAT(DATEDIFF(SECOND, 
                    CAST(CONVERT(DATETIME, MAX(vv.dt_visita), 103) + ' ' + MAX(vv.hr_inicio_visita) AS DATETIME),
                    CAST(CONVERT(DATETIME, MAX(vb.dt_baixa_visita), 103) + ' ' + MAX(vv.hr_fim_visita) AS DATETIME)
                ), '0') + 's'
        END
    ELSE 
        NULL
  END AS Duracao,

  -- Distância Check-in
  MAX(ROUND(
    6371000 * ACOS(
        COS(RADIANS(cd.qt_latitude)) 
      * COS(RADIANS(cli.qt_latitude_cliente)) 
      * COS(RADIANS(cli.qt_longitude_cliente) - RADIANS(cd.qt_longitude)) 
      + SIN(RADIANS(cd.qt_latitude)) 
      * SIN(RADIANS(cli.qt_latitude_cliente))
    ), 0
  )) AS distancia_metros_checkin,

  -- Distância Check-out
  MAX(ROUND(
    6371000 * ACOS(
        COS(RADIANS(vb.qt_latitude)) 
      * COS(RADIANS(cli.qt_latitude_cliente)) 
      * COS(RADIANS(cli.qt_longitude_cliente) - RADIANS(vb.qt_longitude)) 
      + SIN(RADIANS(vb.qt_latitude)) 
      * SIN(RADIANS(cli.qt_latitude_cliente))
    ), 0
  )) AS distancia_metros_checkout,

  -- Rota Check-in
  CASE 
    WHEN MAX(cd.qt_latitude) IS NULL OR MAX(cd.qt_longitude) IS NULL THEN 'Endereço não cadastrado'
    WHEN ROUND(
      6371000 * ACOS(
        COS(RADIANS(MAX(cd.qt_latitude))) 
      * COS(RADIANS(MAX(cli.qt_latitude_cliente))) 
      * COS(RADIANS(MAX(cli.qt_longitude_cliente)) - RADIANS(MAX(cd.qt_longitude))) 
      + SIN(RADIANS(MAX(cd.qt_latitude))) 
      * SIN(RADIANS(MAX(cli.qt_latitude_cliente)))
      ), 0
    ) <= 300 THEN 'Próximo'
    ELSE 'Distante'
  END AS Rota_checkin,

  -- Rota Check-out
  CASE 
    WHEN MAX(vb.qt_latitude) IS NULL OR MAX(vb.qt_longitude) IS NULL THEN 'Endereço não cadastrado'
    WHEN ROUND(
      6371000 * ACOS(
        COS(RADIANS(MAX(vb.qt_latitude))) 
      * COS(RADIANS(MAX(cli.qt_latitude_cliente))) 
      * COS(RADIANS(MAX(cli.qt_longitude_cliente)) - RADIANS(MAX(vb.qt_longitude))) 
      + SIN(RADIANS(MAX(vb.qt_latitude))) 
      * SIN(RADIANS(MAX(cli.qt_latitude_cliente)))
      ), 0
    ) <= 300 THEN 'Próximo'
    ELSE 'Distante'
  END AS Rota_checkout

INTO #CheckinCheckout
From 
	Visita vv 
LEFT outer JOIN cliente cli             ON cli.cd_cliente      = vv.cd_cliente
LEFT outer JOIN visita_baixa vb         ON vb.cd_visita        = vv.cd_visita 
inner join consulta c                   ON c.cd_cliente        = cli.cd_cliente 
LEFT outer JOIN consulta_diversos cd    ON c.cd_consulta       = cd.cd_consulta
LEFT outer JOIN Pedido_Venda pv         ON pv.cd_consulta      = cd.cd_consulta
LEFT outer JOIN Vendedor v              ON v.cd_vendedor       = c.cd_vendedor 
LEFT outer JOIN Pais pa    WITH(NOLOCK) oN pa.cd_pais          = cli.cd_pais
LEFT outer JOIN Estado est WITH(NOLOCK) ON est.cd_pais         = pa.cd_pais AND est.cd_estado = cli.cd_estado
LEFT outer JOIN cidade cid WITH(NOLOCK) ON cid.cd_pais         = pa.cd_pais AND cid.cd_estado = est.cd_estado AND cid.cd_cidade = cli.cd_cidade 

WHERE
c.dt_consulta BETWEEN @dt_inicial AND @dt_final
and
v.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then v.cd_vendedor else isnull(@cd_vendedor,0) end  

group by 
pv.cd_pedido_venda
ORDER BY MAX(v.cd_vendedor) DESC

--select * from #CheckinCheckout
--select * from consulta_diversos
--select * from visita where dt_visita between '09/01/2025' and '09/10/2025'
---select @dt_inicial
----------------------------------------------------------------------------------------------------------      
 if isnull(@cd_parametro,0) = 1    
 begin    
    select * from #CheckinCheckout    
  return    
 end 
----------------------------------------------------------------------------------------------------------
DECLARE @tt_checkin DECIMAL(18,2) = 0
DECLARE @tt_checkout DECIMAL(18,2) = 0
 
SELECT 
  @tt_checkin = CASE 
                  WHEN ISNULL(distancia_metros_checkin, 0) > 999 
                  THEN distancia_metros_checkin * 1000 
                  ELSE ISNULL(distancia_metros_checkin, 0) 
                END,
  @tt_checkout = CASE 
                   WHEN ISNULL(distancia_metros_checkout, 0) > 999 
                   THEN distancia_metros_checkout * 1000 
                   ELSE ISNULL(distancia_metros_checkout, 0) 
                 END
 from #CheckinCheckout
 
----------------------------------------------------------------------------------------------------------

set @html_geral ='
    <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 20%;">'+case when isnull(@titulo,'') <> '' then ''+isnull(@titulo,'')+'' else 'Visitas com CHECK-IN' end +'</p>  
    </div>  
	<div>
    <table>
      <tr class="tamanho">
		  <th>Vendedor</th>
          <th>Cliente</th>
		  <th>Razão Social</th>
		  <th>Data/hora Check-in</th>
		  <th>Data/hora Checkout</th>
          <th>Duração</th>
		  <th>Distancia Check-in</th>
          <th>Status Check-in</th>
		  <th>Distancia Checkout</th>
		  <th>Status Checkout</th>
          <th>Pedido</th>
        </tr>'
--------------------------------------------------------------------------------------------------------------
WHILE exists (select top 1 cd_controle from #CheckinCheckout)
  begin
  select top 1 
	 @id         = cd_controle,
	 @html_geral = @html_geral+ '
		<tr style="text-align: center;">
		  <td style="text-align: left;">'+isnull(nm_vendedor,'')+'</td>
		  <td style="text-align: left;">'+isnull(nm_fantasia_cliente,'')+'</td>
		  <td style="text-align: left;">'+isnull(nm_razao_social_cliente,'')+'</td>		  
		  <td>'+isnull(dt_visita,'Não informado')+' '+isnull(hr_inicio_visita,'')+'</td>
		  <td>'+case when isnull(dt_baixa_visita,'') = '' then 'Não Informado' else isnull(dt_baixa_visita,'') end +' '+isnull(hr_fim_visita,'')+'</td>
		  <td>'+cast(isnull(Duracao,'') as nvarchar(50))+'</td>
		  <td>'+cast(isnull(distancia_metros_checkin,'')as nvarchar(20))+' M</td>
		  <td>'+isnull(Rota_checkin,'')+'</td>
		  <td>'+cast(isnull(distancia_metros_checkout,'')as nvarchar(20))+' M</td>
		  <td>'+isnull(Rota_checkout,'')+'</td>
		  <td>'+cast(isnull(cd_pedido_venda,'') as nvarchar(20))+'</td>
		</tr>'

 from #CheckinCheckout
  DELETE FROM #CheckinCheckout WHERE cd_controle = @id  
END  

--------------------------------------------------------------------------------------------------------------------
set @html_rodape =
    '
	</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
   
    <p>'+@ds_relatorio+'</p>
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
---exec pr_egis_relatorio_visita_checkin 214,'' 
------------------------------------------------------------------------------


