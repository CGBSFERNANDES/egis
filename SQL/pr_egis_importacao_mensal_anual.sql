--use EGISSQL_SPRINGS
GO

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = N'pr_egis_importacao_mensal_anual' AND type = 'P')
    DROP PROCEDURE pr_egis_importacao_mensal_anual
GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_importacao_mensal_anual
-------------------------------------------------------------------------------
--pr_egis_importacao_mensal_anual
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Importação Mensal por Ano

--Data             : 11.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------

CREATE PROCEDURE pr_egis_importacao_mensal_anual
    @json NVARCHAR(MAX) = ''
AS
BEGIN
    SET @json = ISNULL(@json, '')

    DECLARE @cd_empresa      INT = 0,
            @cd_fornecedor   INT = 0,
            @cd_usuario      INT = 0,
            @dt_inicial      DATETIME,
            @dt_final        DATETIME,
            @cd_ano          INT = YEAR(GETDATE())

    -- Leitura do JSON
    SELECT 
        valores.[key] COLLATE SQL_Latin1_General_CP1_CI_AI AS campo,                     
        valores.[value] AS valor                    
    INTO #json
    FROM OPENJSON(@json) root
    CROSS APPLY OPENJSON(root.value) AS valores

    SELECT @cd_empresa    = valor FROM #json WHERE campo = 'cd_empresa'
    SELECT @cd_fornecedor = valor FROM #json WHERE campo = 'cd_fornecedor'
    SELECT @cd_usuario    = valor FROM #json WHERE campo = 'cd_usuario'
    SELECT @cd_ano        = valor FROM #json WHERE campo = 'cd_ano'
    SELECT @dt_inicial    = valor FROM #json WHERE campo = 'dt_inicial'
	SELECT @dt_final      = valor FROM #json WHERE campo = 'dt_final'

    IF @cd_empresa = 0
        SET @cd_empresa = dbo.fn_empresa()

   select
     @dt_inicial = min(dt_pedido_importacao)
   from
     pedido_importacao


    -- Tabela Temporária com agregação mensal
    SELECT 
        count(distinct cd_fornecedor) as qt_fornecedor,
        YEAR(dt_pedido_importacao) AS cd_ano,
        MONTH(dt_pedido_importacao) AS cd_mes,
        SUM( cast(round(vl_pedido_importacao,2) as decimal(25,2))) AS vl_total
    INTO #tmp_importacao
    FROM Pedido_Importacao p
    WHERE 
        --YEAR(dt_pedido_importacao) = @cd_ano
		p.dt_pedido_importacao between @dt_inicial and @dt_final
        AND (@cd_fornecedor = 0 OR p.cd_fornecedor = @cd_fornecedor)
		and
		p.dt_canc_pedido_importacao is null
		and
		p.cd_pedido_importacao in ( select i.cd_pedido_importacao from Pedido_Importacao_Item i where i.cd_pedido_importacao = p.cd_pedido_importacao and
		                            i.dt_cancel_item_ped_imp is null )

    GROUP BY 
	  YEAR(dt_pedido_importacao), MONTH(dt_pedido_importacao)

    -- Tabela PIVOT com colunas mensais

    SELECT 
        cd_ano          as Ano,
        ISNULL([1], 0)  AS Janeiro,
        ISNULL([2], 0)  AS Fevereiro,
        ISNULL([3], 0)  AS Marco,
        ISNULL([4], 0)  AS Abril,
        ISNULL([5], 0)  AS Maio,
        ISNULL([6], 0)  AS Junho,
        ISNULL([7], 0)  AS Julho,
        ISNULL([8], 0)  AS Agosto,
        ISNULL([9], 0)  AS Setembro,
        ISNULL([10], 0) AS Outubro,
        ISNULL([11], 0) AS Novembro,
        ISNULL([12], 0) AS Dezembro,
        (ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0)+ISNULL([4],0)+ISNULL([5],0)+ISNULL([6],0)+
         ISNULL([7],0)+ISNULL([8],0)+ISNULL([9],0)+ISNULL([10],0)+ISNULL([11],0)+ISNULL([12],0)) AS Total,
        ROUND((
            ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0)+ISNULL([4],0)+ISNULL([5],0)+ISNULL([6],0)+
            ISNULL([7],0)+ISNULL([8],0)+ISNULL([9],0)+ISNULL([10],0)+ISNULL([11],0)+ISNULL([12],0)
        ) / 12.0, 2) AS Media,
		qt_fornecedor
    INTO #resultado
    FROM #tmp_importacao
    PIVOT (
        SUM(vl_total) FOR cd_mes IN (
            [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
        )
    ) AS p

    -- Total geral para cálculo de percentual
    DECLARE @vl_total_geral DECIMAL(18,2) = 0
    SELECT @vl_total_geral = SUM(Total) FROM #resultado

    -- Resultado final com percentual e fornecedor "modal"
    SELECT 
        *,
        pc_total = CASE WHEN @vl_total_geral > 0 THEN ROUND(Total / @vl_total_geral * 100, 2) ELSE 0 END,
		fornecedor_modal = qt_fornecedor
        --fornecedor_modal = (
        --    SELECT TOP 1 Ano
        --    FROM #resultado 
        --    ORDER BY Total DESC
        --)
    FROM #resultado
    ORDER BY ano desc, Total 
END
GO

--use EGISSQL_SPRINGS
--go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_importacao_mensal_anual
------------------------------------------------------------------------------

--EXEC pr_egis_importacao_mensal_anual '[{"dt_inicial":"01/01/2000"}, {"dt_final":"06/30/2025"}]'