IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_deslocamento_mensal' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_deslocamento_mensal

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_faturamento_mensal_assistencia_tecnica
-------------------------------------------------------------------------------
--pr_egis_relatorio_faturamento_mensal_assistencia_tecnica
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
create procedure pr_egis_relatorio_deslocamento_mensal
@cd_relatorio int   = 0,
@cd_usuario   int   = 0,
@cd_parametro int   = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')

declare @cd_empresa             int = 0
declare @cd_modulo              int = 0
declare @cd_menu                int = 0
declare @cd_processo            int = 0
declare @cd_item_processo       int = 0
declare @cd_form                int = 0
--declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
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
			@ic_empresa_faturamento		char(1) = '',
			@cd_veiculo                 int = 0
					   
--------------------------------------------------------------------------------------------------------

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
--set @cd_parametro      = 0
set @cd_modulo         = 0
set @cd_empresa        = 0
set @cd_menu           = 0
set @cd_processo       = 0
set @cd_item_processo  = 0
set @cd_form           = 0
set @cd_documento      = 0
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
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_veiculo			 = valor from #json where campo = 'cd_veiculo'
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'
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


select
  @dt_inicial     = dt_inicial,
  @dt_final       = dt_final, 
  @cd_veiculo     = cd_veiculo
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

-------------------------------------------------------------------------------------------------------------------
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
DECLARE 
  @veiculo VARCHAR(100),
  @html_linha NVARCHAR(MAX) = '',
  @janeiro DECIMAL(18,2),
  @fevereiro DECIMAL(18,2),
  @marco DECIMAL(18,2),
  @abril DECIMAL(18,2),
  @maio DECIMAL(18,2),
  @junho DECIMAL(18,2),
  @julho DECIMAL(18,2),
  @agosto DECIMAL(18,2),
  @setembro DECIMAL(18,2),
  @outubro DECIMAL(18,2),
  @novembro DECIMAL(18,2),
  @dezembro DECIMAL(18,2),
  @total DECIMAL(18,2),
  @media DECIMAL(18,2),
  @html_tabela NVARCHAR(MAX),
  @html_detalhe_veiculos NVARCHAR(MAX) = ''
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
if isnull(@cd_parametro,0) = 2
 begin
  select * from #RelAtributo
  return
end

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




declare @vl_meta		   decimal(25,2) = 0.00
declare @vl_total          decimal(25,2) = 0.00
declare @qt_total          int = 0
declare @vl_total_vendedor decimal(25,2) = 0.00
declare @qt_total_vendedor int = 0
declare @dt_inicial_anterior datetime 
declare @dt_final_anterior datetime
declare @vl_total_anterior decimal(25,2) = 0.00
declare @pc_crescimento    decimal(25,2) = 0.00


--declare @cd_ano            int = 0
--set @dt_inicial = '2025-01-01'
--set @dt_final   = '2025-12-31'
--set @cd_veiculo  = 0

-- Populando a tabela temporária

SELECT
  r.dt_romaneio,
  r.cd_veiculo,
  COUNT(distinct r.cd_cliente)    as qt_cliente,
  COUNT(distinct r.cd_veiculo)    as qt_veiculo,
  COUNT(distinct r.cd_entregador) as qt_entregador,
  MAX(v.nm_veiculo)               as nm_veiculo,
  MAX(v.cd_placa_veiculo)         as cd_placa_veiculo,
  qt_km = SUM(ISNULL(d.qt_odometro_final, 0) - ISNULL(d.qt_odometro_inicial, 0)),
  MAX(m.nm_mes) AS nm_mes,
  MAX(YEAR(r.dt_romaneio)) AS cd_ano,
  MAX(MONTH(r.dt_romaneio)) AS cd_mes
INTO #Auxiliar
FROM romaneio r
JOIN romaneio_entrega_dados d ON d.cd_romaneio = r.cd_romaneio
LEFT JOIN veiculo v ON v.cd_veiculo = r.cd_veiculo
LEFT JOIN Mes m ON m.cd_mes = MONTH(r.dt_romaneio)
WHERE
  r.dt_romaneio BETWEEN @dt_inicial AND @dt_final 
  and
  r.cd_veiculo = case when isnull(@cd_veiculo,0) = 0 then r.cd_veiculo else isnull(@cd_veiculo,0) end
  AND
  ISNULL(d.qt_odometro_final, 0) > 0 
  AND
  ISNULL(d.qt_odometro_final, 0) > ISNULL(d.qt_odometro_inicial, 0)

GROUP BY r.dt_romaneio, r.cd_veiculo;
--select * from #Auxiliar
-- Agrupando por mês e veículo
WITH Base AS (
  SELECT
    cd_ano,
    nm_veiculo,
    cd_mes,
    qt_km = SUM(qt_km)
  FROM #Auxiliar
  GROUP BY cd_ano, nm_veiculo, cd_mes
),

-- Aplicando PIVOT
Pivoted AS (
  SELECT
    cd_ano,
    nm_veiculo,
    ISNULL([1], 0) AS Janeiro,
    ISNULL([2], 0) AS Fevereiro,
    ISNULL([3], 0) AS Março,
    ISNULL([4], 0) AS Abril,
    ISNULL([5], 0) AS Maio,
    ISNULL([6], 0) AS Junho,
    ISNULL([7], 0) AS Julho,
    ISNULL([8], 0) AS Agosto,
    ISNULL([9], 0) AS Setembro,
    ISNULL([10], 0) AS Outubro,
    ISNULL([11], 0) AS Novembro,
    ISNULL([12], 0) AS Dezembro
  FROM Base
  PIVOT (
    SUM(qt_km) FOR cd_mes IN (
      [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12]
    )
  ) AS p
)

-- Resultado final com Total e Média
SELECT
  IDENTITY(int,1,1) as cd_controle,
  cd_ano AS Ano,
  nm_veiculo AS [Veículo],
  Janeiro, Fevereiro, Março, Abril, Maio, Junho, Julho,
  Agosto, Setembro, Outubro, Novembro, Dezembro,
  Total = Janeiro + Fevereiro + Março + Abril + Maio + Junho + Julho +
          Agosto + Setembro + Outubro + Novembro + Dezembro,
  Media = ROUND((
    Janeiro + Fevereiro + Março + Abril + Maio + Junho + Julho +
    Agosto + Setembro + Outubro + Novembro + Dezembro
  ) / NULLIF((
    CASE WHEN Janeiro   <> 0 THEN 1 ELSE 0 END +
    CASE WHEN Fevereiro <> 0 THEN 1 ELSE 0 END +
    CASE WHEN Março     <> 0 THEN 1 ELSE 0 END +
    CASE WHEN Abril     <> 0 THEN 1 ELSE 0 END +
    CASE WHEN Maio      <> 0 THEN 1 ELSE 0 END +
    CASE WHEN Junho     <> 0 THEN 1 ELSE 0 END +
    CASE WHEN Julho     <> 0 THEN 1 ELSE 0 END +
    CASE WHEN Agosto    <> 0 THEN 1 ELSE 0 END +
    CASE WHEN Setembro  <> 0 THEN 1 ELSE 0 END +
    CASE WHEN Outubro   <> 0 THEN 1 ELSE 0 END +
    CASE WHEN Novembro  <> 0 THEN 1 ELSE 0 END +
    CASE WHEN Dezembro  <> 0 THEN 1 ELSE 0 END
  ), 0), 2)
  into 
  #finalAno
FROM Pivoted
ORDER BY cd_ano, nm_veiculo;
--select * from #finalAno
--select * from #Auxiliar

select 
    identity(int,1,1) as cd_controle,
	a.nm_mes as nm_mes,
	SUM(qt_km) as qt_km,
	a.cd_mes as cd_mes
	into 
	#finalKMRel
from 
 #Auxiliar a

 GROUP BY 
	a.nm_mes,a.cd_mes
 order by
	a.cd_mes
 --SELECT * FROM #finalKMRel

--return 

select
  cd_ano,
--  cd_mes,
--  nm_mes,
--  cd_veiculo,
  --nm_veiculo,
  SUM(qt_km) as qt_km,
  SUM(qt_cliente) as qt_cliente,
  SUM(qt_veiculo) as qt_veiculo,
  SUM(qt_entregador) as qt_entregador
  into 
  #cards
from
  #Auxiliar

group by
  cd_ano

  declare 
	@qt_km_card decimal(18,4) = 0,
	@qt_cliente int =0, 
    @qt_veiculo int =0,
	@qt_entregador int =0

 select 
	 @qt_cliente     = qt_cliente,
	 @qt_veiculo     = qt_veiculo,
	 @qt_entregador  = qt_entregador
  from #Auxiliar

 select 
	 @qt_km_card     = qt_km,
	 @qt_cliente     = qt_cliente,
	 @qt_veiculo     = qt_veiculo,
	 @qt_entregador  = qt_entregador
  from #cards
  declare @ano int = 0
select 
	@ano = Ano
from #finalAno
--Gráfico----------------------------------------------------------------------------------------------------------

if @cd_parametro = 3
begin

  declare @labels   nvarchar(max) = ''
  declare @valores  nvarchar(max) = '' 
  declare @nm_label varchar(100) = ''
  declare @nm_valor varchar(100) = ''
  declare @tabela   nvarchar(max) = ''
  declare @card     nvarchar(max) = ''
    
  while exists ( select top 1 cd_controle from #finalKMRel )
  begin

    select top 1 
	  @cd_controle  = cd_controle,
	  @nm_label     = nm_mes,
	  @nm_valor     = replace(CAST(dbo.fn_formata_valor(qt_km) as varchar(100)),'.',''),
      @html_detalhe = @html_detalhe + '
            <tr> 					           			
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(cd_controle as varchar(20))+'</td>
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(nm_mes as varchar(20))+'</td>
			<td '+case when cd_mes = @cd_mes then 'class="table-info" 'else '' end
			     +'style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_formata_valor(qt_km)+'</td>
            </tr>'
    from
	  #finalKMRel

      

     set @nm_valor = REPLACE(@nm_valor,',','.')
     set @labels   = @labels  + '"' +  @nm_label + '"'
	 set @valores  = @valores + ' ' +  @nm_valor + ' '

	 delete from #finalKMRel
	 where
	   cd_controle = @cd_controle

	 if exists(select top 1 cd_controle from #finalKMRel)
	 begin
	   set @labels  = @labels + ', '
	   set @valores = @valores + ', '
	 end

  end

 
DECLARE c CURSOR FOR
SELECT 
  [Veículo], Janeiro, Fevereiro, Março, Abril, Maio, Junho, Julho,
  Agosto, Setembro, Outubro, Novembro, Dezembro, Total, Media
FROM #finalAno

OPEN c
FETCH NEXT FROM c INTO 
  @veiculo, @janeiro, @fevereiro, @marco, @abril, @maio, @junho, @julho,
  @agosto, @setembro, @outubro, @novembro, @dezembro, @total, @media

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @html_linha = '
    <tr>
      <td>'+@veiculo+'</td>
      <td>'+dbo.fn_formata_valor(@janeiro)+'</td>
      <td>'+dbo.fn_formata_valor(@fevereiro)+'</td>
      <td>'+dbo.fn_formata_valor(@marco)+'</td>
      <td>'+dbo.fn_formata_valor(@abril)+'</td>
      <td>'+dbo.fn_formata_valor(@maio)+'</td>
      <td>'+dbo.fn_formata_valor(@junho)+'</td>
      <td>'+dbo.fn_formata_valor(@julho)+'</td>
      <td>'+dbo.fn_formata_valor(@agosto)+'</td>
      <td>'+dbo.fn_formata_valor(@setembro)+'</td>
      <td>'+dbo.fn_formata_valor(@outubro)+'</td>
      <td>'+dbo.fn_formata_valor(@novembro)+'</td>
      <td>'+dbo.fn_formata_valor(@dezembro)+'</td>
      <td><b>'+dbo.fn_formata_valor(@total)+'</b></td>
      <td>'+CAST(ROUND(@media, 2) AS VARCHAR(20))+'</td>
    </tr>
  '

  SET @html_detalhe_veiculos = @html_detalhe_veiculos + @html_linha

  FETCH NEXT FROM c INTO 
    @veiculo, @janeiro, @fevereiro, @marco, @abril, @maio, @junho, @julho,
    @agosto, @setembro, @outubro, @novembro, @dezembro, @total, @media
END

CLOSE c
DEALLOCATE c

-- Monta a tabela final
SET @tabela = '
<div class="container mt-5">
  <h2 class="mb-4">'+CAST(ISNULL(@ano, 0) AS NVARCHAR(10))+' - Quilometragem por Veículo</h2>
  <table class="table table-hover">
    <thead class="table-dark">
      <tr>
        <th>Veículo</th>
        <th>Janeiro</th>
        <th>Fevereiro</th>
        <th>Março</th>
        <th>Abril</th>
        <th>Maio</th>
        <th>Junho</th>
        <th>Julho</th>
        <th>Agosto</th>
        <th>Setembro</th>
        <th>Outubro</th>
        <th>Novembro</th>
        <th>Dezembro</th>
        <th>Total</th>
        <th>Média</th>
      </tr>
    </thead>
    <tbody>
      '+@html_detalhe_veiculos+'
    </tbody>
  </table>
</div>'

  --Dados do Gráfico---

  if @labels<>''
  begin
    set @labels  = '['+@labels+']'
	set @valores = '['+@valores+']'
  end

  --select @labels
  --select @valores

  --Dados dos Cards'--

  set @card = ' 
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
    </div>
	 <div class="separador" style="font-weight: bold; font-size: 18px">'+@titulo+' - Data Base : '+dbo.fn_data_string(@dt_final) +'</div>
	 <div class="secao4" id="sobre">
  <div class="secao4-div">
      <!-- Card 1 -->
      <div class="secao4-div-card">        
	      <div>
          <h3>Percorrido</h3>
		  <div class="card_separator"></div>
		  </div>	  
		  <div>
          <p>'+cast(isnull(dbo.fn_formata_valor(@qt_km_card),0) as varchar(20))+'</p>
		  </div>
      </div>

      <!-- Card 2 -->
	  <div class="secao4-div-card">   
	      <div>
          <h3>Clientes</h3>		
		   <div class="card_separator"></div>
          </div>
          <p>'+ cast(isnull(@qt_cliente,0) as varchar(20))+'</p>
      </div>
     
      <!-- Card 3 -->
	   <div class="secao4-div-card">   
	      <div>
          <h3>Veiculo</h3>		
		   <div class="card_separator"></div>
          </div>
          <p> '+cast(isnull(@qt_veiculo,0)as varchar(20))+'</p>
      </div>


      <!-- Card 4 -->
      <div class="secao4-div-card">          
	      <div>
          <h3>Entregador</h3> 
		  <div class="card_separator"></div>
		  </div>
          <p>'+cast( cast(isnull(@qt_entregador,0) as int) as varchar(20))+'</p>
      </div>
  </div>
</div>'



  set @html_grafico = 
  '<html lang="pt-br">
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title >'+@titulo+'</title>
    <!-- Link para o CSS do Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.min.js" integrity="sha512-L0Shl7nXXzIlBSUUPpxrokqq4ojqgZFQczTYlGjzONGTDAcLremjwaWv5A+EDLnxhQzY5xUZPWLOLqYRkY0Cbw==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>    
    <style>
      .grafico {
        position: relative; 
		height:40vh; width: calc(50% - 20px);  
		margin: 5px;  
          padding: 5px;
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
			font-size: 14px;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 5px;           
        }
        th {
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
       
        .img {
            max-width: 250px;
			height: 100px;
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
		.separador {
            width: auto;
            height: 35px;
			margin:5px;
			padding: 2px;
			border-radius: 10px;
            background-color:#ff6f00;
            color: white;
            text-align: center;
            display: flex;
            justify-content: center;
            align-items: center;
        }

		.container2 {          
          margin:0 auto;
          border: 0px solid orangered;
          display: flex;
          flex-direction: row;
          flex-wrap: wrap;
          justify-content: center; /* eixo principal */
          align-items: center;
		}

.secao4 {
    margin: 0;
    font-family: Helvetica, sans-serif;}

.secao4-div {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    padding: 10px;
    text-align: center;
    }

.secao4-div-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: calc(100% / 4 - 60px);
    margin: 10px;
    padding: 20px;
    box-shadow: 2px 2px 16px 0px rgba(0, 0, 0, 0.1);
    border-radius: 15px;
    background-color: white;
    transition: all 0.5s ease;
    }

.secao4-div-card:hover {
    transform: scale(1.1);
    z-index: 1;}

.secao4-div-card imgx {
    width: 35%;
    height: auto;}

.secao4-div-card h3 {
    margin-bottom: 0px;}

/* Estilos para dispositivos móveis */
@media (max-width: 768px) {
    .secao4-div-card {
        width: 100%;
    }
}        

  </style>
  </head>
  <body>
     <div class="container mt-5">'
	 
	 +

	 isnull(@card,'')
	 +
	 ''
	 --'<div class="container mt-5">'
	 +
     '<div class="grafico">
         <canvas id="myChart"></canvas>
	 </div>'
	 +
	 isnull(@tabela,'')
	 +	   

    '</div>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
     const ctx = document.getElementById("myChart");

     new Chart(ctx, {
     type: "bar",
     data: {
       labels: '+@labels+',
       datasets: [{
        label: "'+@titulo+'",
        data: '+@valores+ ',
        borderWidth: 1,
		fill: false,        
		tension: 0.1,
		stepped: false	
				
      }]
    },
    options: {
	  responsive: true,
	
      scales: {
	  x: {
        grid: {
          display: false
        }
      },
        y: {
		  
          beginAtZero: true,
           grid: {
             display: false
           }
        }
      },
      plugins: {
	    
        legend: {
		         position: "top",
                 display: false,
                 labels: {
				    usePointStyle: false,
                    color: "rgb(255, 99, 132)"
                }
            },        
        customCanvasBackgroundColor: {
        color: "lightGreen",
       },
        title: {
                display: false,
                text: "TITULO DO GRAFICO"				 
            },
                
            subtitle: {
                display: false,
                text: "Custom Chart Subtitle"
            },
            tooltip: {
                callbacks: {
                    label: function(context) {
                        let label = context.dataset.label || "";

                        if (label) {
                            label += ": ";
                        }
                        if (context.parsed.y !== null) {
                            label += new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(context.parsed.y);
                        }
                        return label;
                    }
                }
            }        
            
        }
    }
  });
</script>
<!-- Script do Bootstrap -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>  
</html>'

  select isnull(@html_grafico,'') as RelatorioHTML
  return

end


--Relatório

if @cd_parametro<> 3
begin

  ---------------------------------------------------------------------------------------------------------------------------

  ----montagem do Detalhe-----------------------------------------------------------------------------------------------

  ---------------------------------------------------------------------------------------------------------------------------
 
--<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_data_string(dt_pedido_venda)+'</td>

declare @id int = 0

set @html_detalhe = ''

--declare @nm_fantasia_vendedor varchar(30) = ''

--------------------------------------------------------------------------------------------------


set @html_cab_det = '
         
<table class="table table-hover">
  <thead class="table-dark">
    <tr>
      <th>Veículo</th>
      <th>Janeiro</th>
      <th>Fevereiro</th>
      <th>Março</th>
      <th>Abril</th>
      <th>Maio</th>
      <th>Junho</th>
      <th>Julho</th>
      <th>Agosto</th>
      <th>Setembro</th>
      <th>Outubro</th>
      <th>Novembro</th>
      <th>Dezembro</th>
      <th>Total</th>
      <th>Média</th>
    </tr>
  </thead>
  <tbody>
'

set @html_detalhe = '' --valores da tabela

 if isnull(@cd_parametro,0) = 1
 begin
    select * from  #finalAno
  return
 end
 DECLARE @linha NVARCHAR(MAX)

DECLARE c CURSOR FOR
SELECT 
  [Veículo], Janeiro, Fevereiro, Março, Abril, Maio, Junho, Julho,
  Agosto, Setembro, Outubro, Novembro, Dezembro, Total, Media
FROM #finalAno

OPEN c
FETCH NEXT FROM c INTO @veiculo, @janeiro, @fevereiro, @marco, @abril, @maio, @junho, @julho,
                      @agosto, @setembro, @outubro, @novembro, @dezembro, @total, @media

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @linha = '
    <tr>
      <td>'+@veiculo+'</td>
      <td>'+dbo.fn_formata_valor(@janeiro)+'</td>
      <td>'+dbo.fn_formata_valor(@fevereiro)+'</td>
      <td>'+dbo.fn_formata_valor(@marco)+'</td>
      <td>'+dbo.fn_formata_valor(@abril)+'</td>
      <td>'+dbo.fn_formata_valor(@maio)+'</td>
      <td>'+dbo.fn_formata_valor(@junho)+'</td>
      <td>'+dbo.fn_formata_valor(@julho)+'</td>
      <td>'+dbo.fn_formata_valor(@agosto)+'</td>
      <td>'+dbo.fn_formata_valor(@setembro)+'</td>
      <td>'+dbo.fn_formata_valor(@outubro)+'</td>
      <td>'+dbo.fn_formata_valor(@novembro)+'</td>
      <td>'+dbo.fn_formata_valor(@dezembro)+'</td>
      <td><b>'+dbo.fn_formata_valor(@total)+'</b></td>
      <td>'+CAST(@media AS VARCHAR(20))+'</td>
    </tr>
  '

  SET @html_detalhe = @html_detalhe + @linha

  FETCH NEXT FROM c INTO @veiculo, @janeiro, @fevereiro, @marco, @abril, @maio, @junho, @julho,
                          @agosto, @setembro, @outubro, @novembro, @dezembro, @total, @media
END

CLOSE c
DEALLOCATE c

-- Finaliza tabela
SET @html_tabela = @html_tabela + @html_detalhe + '
  </tbody>
</table>
'
--set @titulo_total = 'SUB-TOTAL'


set @html_totais = '
					<table style="border: none;">
                    <tr>										
					<td style="border: none;color: white;font-size:18px; text-align:center;width: 25px"><b>&nbsp</td>
			        <td style="border: none;color: white;font-size:18px; text-align:center;width: 20px"'+cast(isnull(@qt_cliente,0) as varchar(20))+'</td>
			        <td style="border: none;color: white;font-size:18px; text-align:left;width: 45px">'+cast(isnull(dbo.fn_formata_valor(@qt_km_card),0) as varchar(20))+'</td>	
					</tr>
					</table>					
					</div>'
					
 set @html_geral = @html_geral + 
                   @html_cab_det +
                   @html_detalhe +
	               @html_rod_det +
				   @html_totais

     
-------------------------------------------------------------------------------------------------------------
set @nm_fantasia_cliente     = '' --'Resumo dos Pedidos de Vendas'
set @nm_razao_social_cliente = '' --@nm_pedido

set @titulo = @titulo + ' - Período : '+dbo.fn_data_string(@dt_inicial) + ' á '+dbo.fn_data_string(@dt_final)
 
set @html_titulo = '<div class="section-title"><strong>'+@titulo+'</strong></div>'
--------------------------------------------------------------------------------------------------------------------

--Criar uma tabela temporario com os Dados dos atributos


SET @html_rod_det = '</table>'


set @titulo_total = 'TOTAIS'

set @html_totais = '<div class="section-title"><strong>'+@titulo_total+'</strong>
                    <div> 
					
			        <p style="border: none;color: white;font-size:18px; text-align:left">Clientes: '+cast(isnull(@qt_cliente,0) as varchar(20))+'</p>
			        <p style="border: none;color: white;font-size:18px; text-align:left">KM: '+cast(isnull(dbo.fn_formata_valor(@qt_km_card),0) as varchar(20))+'</p>	

					</div>
					</div>'


set @footerTitle = ''

--Rodapé--

set @html_rodape =
    '<div class="company-info">
		<p><strong>'+@footerTitle+'</strong> ''</p>
	</div>
    <div class="section-title"><strong>Observações</strong></div>
    <p>'+@ds_relatorio+'</p>
	<div class="report-date-time">
       <p>Gerado em: '+@data_hora_atual+'</p>
    </div>'


--Gráfico--
set @html_grafico = ''

--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +

	--@html_cab_det +
 --   @html_detalhe +
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


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--Relatório
--exec pr_egis_relatorio_faturamento_mensal_assistencia_tecnica 337,4253,0,''
------------------------------------------------------------------------------
--Gráfico
--exec pr_egis_relatorio_deslocamento_mensal 337,4253,3,'[{
--    "cd_empresa": "247",
--    "cd_modulo": "319",
--    "cd_menu": "0",
--    "cd_parametro": 3,
--    "cd_relatorio_form": "343",
--    "cd_processo": "",
--    "cd_form": 182,
--    "cd_documento_form": 5,
--    "cd_parametro_form": "2",
--    "cd_usuario": "4189",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "4189",
--    "dt_usuario": "2025-06-25",
--    "lookup_formEspecial": {},
--    "cd_parametro_relatorio": "5",
--    "cd_relatorio": "343",
--    "dt_inicial": "2025-01-01",
--    "dt_final": "2025-06-30",
--    "cd_veiculo": null,
--    "detalhe": [],
--    "lote": [],
--    "cd_documento": "5"
--}]'
------------------------------------------------------------------------------
--text: (ctx) => "Point Style: " + ctx.chart.data.datasets[0].pointStyle, ( texto no título )
--select * from parametro_relatorio

