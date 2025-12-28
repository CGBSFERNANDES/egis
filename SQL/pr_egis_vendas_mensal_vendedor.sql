--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL

go

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_vendas_mensal_vendedor' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_vendas_mensal_vendedor

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_vendas_mensal_vendedor
-------------------------------------------------------------------------------
--pr_egis_vendas_mensal_vendedor
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Monitor Egis de Informação On-line

--Data             : 27.03.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_vendas_mensal_vendedor
@json nvarchar(max) = ''

--with encryption


as

set @json = isnull(@json,'')

declare @cd_empresa        int
declare @cd_parametro      int
declare @cd_documento      int = 0
declare @cd_item_documento int
declare @cd_cliente        int
declare @cd_relatorio      int 
declare @cd_usuario        int 
declare @dt_hoje           datetime
declare @dt_inicial        datetime = null
declare @dt_final          datetime = null
declare @cd_ano                 int = 0
declare @cd_mes                 int = 0
declare @vl_total          decimal(25,2) = 0.00
declare @vl_total_hoje     decimal(25,2) = 0.00
declare @cd_vendedor       int           = 0
declare @cd_menu           int           = 0
declare @ic_imposto_venda  char(1)       = 'N'

set @cd_empresa        = 0
set @cd_parametro      = 0
set @cd_documento      = 0
set @cd_relatorio      = 0
set @cd_item_documento = 0
set @cd_cliente        = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano            = year(getdate())
set @cd_mes            = month(getdate())  
set @vl_total          = 0

if @dt_inicial is null
begin
  set @cd_mes = 1
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @cd_mes = MONTH(getdate())
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end


--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

select                     

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]              as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_documento           = valor from #json where campo = 'cd_documento'
select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'
select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_cliente             = valor from #json where campo = 'cd_cliente'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
--select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
--select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
select @cd_menu                = valor from #json where campo = 'cd_menu'

set @cd_vendedor  = ISNULL(@cd_vendedor,0) 
set @cd_documento = ISNULL(@cd_documento,0)

----------------------------------------------------------------------------------------------------------

select @ic_imposto_venda = ISNULL(ic_imposto_venda,'N') from Parametro_BI where cd_empresa = @cd_empresa

----------------------------------------------------------------------------------------------------------


--select @dt_inicial, @dt_final

-- Agrupamento por mês

SELECT 
  pv.cd_vendedor,
  MAX(v.nm_fantasia_vendedor) AS nm_fantasia_vendedor,
  DATEPART(MONTH, pv.dt_pedido_venda) AS mes_ano,
 -- SUM( cast(round(ISNULL(pv.vl_total_pedido_ipi, 0),2) as decimal(25,2))) AS total_mes

 			SUM( cast(round(
	
	     case when @ic_imposto_venda = 'S' 
		 then pv.vl_total_pedido_ipi else pv.vl_total_pedido_venda end
		 	 
		 ,2) 
	
	     as decimal(25,2)))                  as total_mes
		 
INTO #tmp
FROM pedido_venda pv
INNER JOIN vendedor v ON v.cd_vendedor = pv.cd_vendedor
LEFT JOIN tipo_pedido tpe ON tpe.cd_tipo_pedido = pv.cd_tipo_pedido
WHERE 
  pv.dt_pedido_venda BETWEEN @dt_inicial AND @dt_final
  AND pv.cd_pedido_venda IN (
    SELECT i.cd_pedido_venda 
    FROM Pedido_Venda_Item i 
    WHERE i.cd_pedido_venda = pv.cd_pedido_venda AND i.dt_cancelamento_item IS NULL
  )
  AND ISNULL(pv.cd_vendedor,0) = CASE WHEN @cd_vendedor = 0 THEN ISNULL(pv.cd_vendedor,0) ELSE @cd_vendedor END
  AND ISNULL(tpe.ic_gera_bi, 'S') = 'S'
  AND ISNULL(tpe.ic_bonificacao_tipo_pedido, 'N') = 'N'
  AND ISNULL(tpe.ic_indenizacao_tipo_pedido, 'N') = 'N'
GROUP BY 
  pv.cd_vendedor,
  DATEPART(MONTH, pv.dt_pedido_venda);

-- Pivot: meses como colunas
SELECT 
  cd_vendedor,
  ISNULL([1], 0) AS [JANEIRO],
  ISNULL([2], 0) AS [FEVEREIRO],
  ISNULL([3], 0) AS [MARCO],
  ISNULL([4], 0) AS [ABRIL],
  ISNULL([5], 0) AS [MAIO],
  ISNULL([6], 0) AS [JUNHO],
  ISNULL([7], 0) AS [JULHO],
  ISNULL([8], 0) AS [AGOSTO],
  ISNULL([9], 0) AS [SETEMBRO],
  ISNULL([10], 0) AS [OUTUBRO],
  ISNULL([11], 0) AS [NOVEMBRO],
  ISNULL([12], 0) AS [DEZEMBRO],
  ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0)+ISNULL([4],0)+ISNULL([5],0)+ISNULL([6],0)+
  ISNULL([7],0)+ISNULL([8],0)+ISNULL([9],0)+ISNULL([10],0)+ISNULL([11],0)+ISNULL([12],0) AS TOTAL
INTO #PivotVendas
FROM (
  SELECT * FROM #tmp
) AS fonte
PIVOT (
  SUM(total_mes) FOR mes_ano IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) AS p;

-- Total geral
SELECT SUM(TOTAL) AS total_geral INTO #soma FROM #PivotVendas;

-- Resultado final

SELECT 
  ROW_NUMBER() OVER (ORDER BY p.TOTAL DESC) AS qt_posicao,
  p.cd_vendedor,
  v.nm_fantasia_vendedor AS Vendedor,
  p.[JANEIRO],
  p.[FEVEREIRO],
  p.[MARCO],
  p.[ABRIL],
  p.[MAIO],
  p.[JUNHO],
  p.[JULHO],
  p.[AGOSTO],
  p.[SETEMBRO],
  p.[OUTUBRO],
  p.[NOVEMBRO],
  p.[DEZEMBRO],
  p.TOTAL,
  CAST(p.TOTAL / NULLIF((SELECT total_geral FROM #soma), 0) * 100 AS DECIMAL(10,2)) AS [PERCENTUAL],
  CAST(p.TOTAL / 12 AS DECIMAL(25,2)) AS [MEDIA]
FROM #PivotVendas p
LEFT JOIN (
  SELECT cd_vendedor, MAX(nm_fantasia_vendedor) AS nm_fantasia_vendedor FROM #tmp GROUP BY cd_vendedor
) v ON v.cd_vendedor = p.cd_vendedor
ORDER BY qt_posicao;


  -- Limpeza opcional
  DROP TABLE IF EXISTS #tmp, #PivotVendas, #soma, #ResultadoFinal;
  -----------------------------------------------------------------

go

--update
--  egisadmin.dbo.meta_procedure_colunas
--set
--  ativo = 1,
--  agrupador_base = 1
--where
--  nome_procedure = 'pr_monitor_egis_informacao'

go

go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_vendas_semanal
------------------------------------------------------------------------------
--exec pr_egis_vendas_mensal_vendedor '[{"dt_inicial":"01/01/2025", "dt_final": "12/31/2025","cd_vendedor":0}]'
go

