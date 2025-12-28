--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL

go

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_vendas_semanal' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_vendas_semanal

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_vendas_semanal
-------------------------------------------------------------------------------
--pr_egis_vendas_semanal
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
create procedure pr_egis_vendas_semanal
@json nvarchar(max) = ''

--with encryption


as

set @json = isnull(@json,'')

declare @cd_empresa        int = 0
declare @cd_parametro      int
declare @cd_documento      int = 0
declare @cd_item_documento int
declare @cd_cliente        int
declare @cd_relatorio      int 
declare @cd_usuario        int 
declare @dt_hoje           datetime
declare @dt_inicial        datetime 
declare @dt_final          datetime
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
set @cd_ano = year(getdate())
set @cd_mes = month(getdate())  
set @vl_total          = 0

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
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
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
select @cd_menu                = valor from #json where campo = 'cd_menu'

set @cd_vendedor  = ISNULL(@cd_vendedor,0) 
set @cd_documento = ISNULL(@cd_documento,0)

----------------------------------------------------------------------------------------------------------

set @cd_empresa = dbo.fn_empresa()

----------------------------------------------------------------------------------------------------------

select @ic_imposto_venda = ISNULL(ic_imposto_venda,'N') from Parametro_BI where cd_empresa = @cd_empresa


----------------------------------------------------------------------------------------------------------


 --select
 --  pv.*
 -- FROM pedido_venda pv
 -- INNER JOIN vendedor v     ON v.cd_vendedor      = pv.cd_vendedor
 -- LEFT JOIN tipo_pedido tpe ON tpe.cd_tipo_pedido = pv.cd_tipo_pedido
 -- WHERE 
 --   pv.dt_pedido_venda BETWEEN @dt_inicial AND @dt_final
 --   AND ISNULL(v.ic_egismob_vendedor, 'S') = 'S'
 --   AND pv.cd_pedido_venda IN (
 --     SELECT i.cd_pedido_venda 
 --     FROM Pedido_Venda_Item i 
 --     WHERE i.cd_pedido_venda = pv.cd_pedido_venda AND i.dt_cancelamento_item IS NULL
 --   )
 --   AND isnull(pv.cd_vendedor,0) = CASE WHEN @cd_vendedor = 0 THEN isnull(pv.cd_vendedor,0) ELSE @cd_vendedor END
 --   AND ISNULL(tpe.ic_gera_bi, 'S') = 'S'
 --   AND ISNULL(tpe.ic_bonificacao_tipo_pedido, 'N') = 'N'
 --   AND ISNULL(tpe.ic_indenizacao_tipo_pedido, 'N') = 'N'

 --DECLARE @vendedores TABLE (cd_vendedor INT);

if @cd_vendedor = 0 and @cd_usuario>0
begin
    set @cd_vendedor  = isnull(dbo.fn_usuario_vendedor(@cd_usuario),0)
	--INSERT INTO @vendedores (cd_vendedor) VALUES (@cd_vendedor);
end


----------------------------------------------------------------------------------------------------------
  -- Semana do mês (1 a 6)

  SELECT 
    pv.cd_vendedor,
    MAX(v.nm_fantasia_vendedor)            as nm_fantasia_vendedor,
    DATEPART(WEEK, pv.dt_pedido_venda) - DATEPART(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, pv.dt_pedido_venda), 0)) + 1 AS semana_mes,
    --SUM(ISNULL(pv.vl_total_pedido_ipi, 0)) as total_semana
		SUM( cast(round(
	
	     case when @ic_imposto_venda = 'S' 
		 then pv.vl_total_pedido_ipi else pv.vl_total_pedido_venda end
		 	 
		 ,2) 
	
	     as decimal(25,2)))     as total_semana
  INTO #tmp
  FROM pedido_venda pv
  INNER JOIN vendedor v     ON v.cd_vendedor      = pv.cd_vendedor
  INNER JOIN tipo_pedido tpe ON tpe.cd_tipo_pedido = pv.cd_tipo_pedido
  WHERE 
    pv.dt_pedido_venda BETWEEN @dt_inicial AND @dt_final
    AND ISNULL(v.ic_egismob_vendedor, 'S') = 'S'
    AND pv.cd_pedido_venda IN (
      SELECT i.cd_pedido_venda 
      FROM Pedido_Venda_Item i 
      WHERE i.cd_pedido_venda = pv.cd_pedido_venda AND i.dt_cancelamento_item IS NULL
    )
    AND isnull(pv.cd_vendedor,0) = CASE WHEN @cd_vendedor = 0 THEN isnull(pv.cd_vendedor,0) ELSE @cd_vendedor END
    AND ISNULL(tpe.ic_gera_bi, 'S') = 'S'
    AND ISNULL(tpe.ic_bonificacao_tipo_pedido, 'N') = 'N'
    AND ISNULL(tpe.ic_indenizacao_tipo_pedido, 'N') = 'N'
    --and
    --    d.cd_vendedor IN (case when isnull((SELECT cd_vendedor FROM @vendedores),0) = 0 then d.cd_vendedor else (SELECT cd_vendedor FROM @vendedores) end)
  
  GROUP BY 
    pv.cd_vendedor,
    DATEPART(WEEK, pv.dt_pedido_venda) - DATEPART(WEEK, DATEADD(MONTH, DATEDIFF(MONTH, 0, pv.dt_pedido_venda), 0)) + 1;

  -- Pivot: semanas como colunas

  SELECT 
    cd_vendedor,
    ISNULL([1], 0) AS [SEMANA 1],
    ISNULL([2], 0) AS [SEMANA 2],
    ISNULL([3], 0) AS [SEMANA 3],
    ISNULL([4], 0) AS [SEMANA 4],
    ISNULL([5], 0) AS [SEMANA 5],
    --ISNULL([6], 0) AS [SEMANA 6],
    ISNULL([1], 0) + ISNULL([2], 0) + ISNULL([3], 0) + ISNULL([4], 0) + ISNULL([5], 0) + ISNULL([6], 0) AS TOTAL
  INTO #PivotVendas
  FROM (
    SELECT * FROM #tmp
  ) AS fonte
  PIVOT (
    SUM(total_semana) FOR semana_mes IN ([1], [2], [3], [4], [5], [6])
  ) AS p;

  -- Total geral
  SELECT SUM(TOTAL) AS total_geral INTO #soma FROM #PivotVendas;

  -- Resultado final com JOIN para recuperar nome do vendedor
  SELECT 
    p.cd_vendedor,
    v.nm_fantasia_vendedor AS Vendedor,
    p.[SEMANA 1],
    p.[SEMANA 2],
    p.[SEMANA 3],
    p.[SEMANA 4],
    p.[SEMANA 5],
   -- p.[SEMANA 6],
    p.TOTAL,
    CAST(p.TOTAL / NULLIF((SELECT total_geral FROM #soma), 0) * 100 AS DECIMAL(10, 2)) AS [PERCENTUAL]
  INTO #ResultadoFinal
  FROM #PivotVendas p
  LEFT JOIN (
    SELECT cd_vendedor, MAX(nm_fantasia_vendedor) AS nm_fantasia_vendedor FROM #tmp GROUP BY cd_vendedor
  ) v ON v.cd_vendedor = p.cd_vendedor;

  -- Select final com total geral

  SELECT *, TOTAL AS TOTAL_GERAL, @dt_hoje as dt_hoje FROM #ResultadoFinal
  
 -- UNION ALL
 -- SELECT 
 --   NULL,
 --   'TOTAL GERAL',
 --   SUM([SEMANA 1]),
 --   SUM([SEMANA 2]),
 --   SUM([SEMANA 3]),
 --   SUM([SEMANA 4]),
 --   SUM([SEMANA 5]),
 --   SUM([SEMANA 6]),
 --   SUM(TOTAL),
 --   100.00,
	--SUM(TOTAL) AS TOTAL_GERAL, @dt_hoje as dt_hoje
 -- FROM #ResultadoFinal;

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
--use egissql_342
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_vendas_semanal
------------------------------------------------------------------------------
--exec pr_egis_vendas_semanal '[{"dt_inicial":"07/01/2025", "dt_final":"07/07/2025", "cd_vendedor":116}]'
--exec pr_egis_vendas_semanal '[{"dt_inicial":"07/11/2025", "dt_final":"07/14/2025", "cd_vendedor":116}]'
go