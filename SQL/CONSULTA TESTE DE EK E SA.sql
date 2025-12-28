
------------------------------------------------------
-- 1) Carteira de Pedidos (#Carteira)
------------------------------------------------------
IF OBJECT_ID('tempdb..#Carteira') IS NOT NULL DROP TABLE #Carteira;

SELECT 
    i.cd_produto                           AS cd_produto,
    MAX(p.cd_mascara_produto)              AS cd_mascara_produto,
    SUM(ISNULL(i.qt_saldo_pedido_venda,0)) AS qt_carteira
INTO #Carteira
FROM pedido_venda_item i
    INNER JOIN pedido_venda pv ON pv.cd_pedido_venda = i.cd_pedido_venda
    INNER JOIN produto p       ON p.cd_produto       = i.cd_produto
WHERE
    i.dt_cancelamento_item IS NULL
    AND ISNULL(i.qt_saldo_pedido_venda,0) > 0
GROUP BY
    i.cd_produto;

-- opcional pra conferir
--SELECT * FROM #Carteira;

------------------------------------------------------
-- 2) Parâmetros
------------------------------------------------------
DECLARE @qt_venda DECIMAL(25,4) = 11500;   -- quantidade adicional
DECLARE @dt_hoje  DATETIME      = GETDATE();

------------------------------------------------------
-- 3) Base do mapa de produção (#MapaProducao)
------------------------------------------------------
IF OBJECT_ID('tempdb..#MapaProducao') IS NOT NULL DROP TABLE #MapaProducao;

SELECT 
    p.cd_produto,
    p.cd_mascara_produto,
    p.nm_fantasia_produto,
    p.nm_produto,
    um.sg_unidade_medida,
    ISNULL(ps.qt_saldo_reserva_produto, 0) AS Disponivel,        -- produto acabado
    ISNULL(ps.qt_minimo_produto, 0)        AS Minimo,

    ISNULL(p.qt_leadtime_produto, 0)       AS Dias,
    CASE 
        WHEN ISNULL(ps.qt_saldo_reserva_produto,0) <= ps.qt_minimo_produto 
            THEN @dt_hoje + ISNULL(p.qt_leadtime_produto,0)
        ELSE NULL
    END                                     AS dt_previsao_entrega,

    pp.cd_processo_padrao,

    ppp.cd_produto                          AS cd_comp_produto,
    ppp.cd_produto_proc_padrao,             -- ordem da atividade / componente
    pc.cd_mascara_produto                   AS cd_comp_mascara_produto,
    pc.nm_produto                           AS nm_comp_produto,
    ISNULL(ppp.qt_produto_processo,0)       AS qt_produto_processo,

    -- estoque do componente
    ISNULL(psc.qt_saldo_reserva_produto,0)  AS comp_Disponivel,

    -- carteira do produto
    ISNULL(c.qt_carteira,0)                 AS qt_carteira
INTO #MapaProducao
FROM produto p
    INNER JOIN unidade_medida um           
        ON um.cd_unidade_medida = p.cd_unidade_medida
    LEFT JOIN produto_saldo ps             
        ON ps.cd_produto      = p.cd_produto 
       AND ps.cd_fase_produto = p.cd_fase_produto_baixa
    INNER JOIN processo_padrao pp          
        ON pp.cd_produto      = p.cd_produto
    INNER JOIN processo_padrao_produto ppp 
        ON ppp.cd_processo_padrao = pp.cd_processo_padrao
    LEFT JOIN produto pc                   
        ON pc.cd_produto = ppp.cd_produto
    LEFT JOIN produto_saldo psc            
        ON psc.cd_produto      = pc.cd_produto 
       AND psc.cd_fase_produto = pc.cd_fase_produto_baixa
    LEFT JOIN #Carteira c
        ON c.cd_produto = p.cd_produto
WHERE
    p.cd_grupo_produto = 1
ORDER BY
    p.cd_mascara_produto,
    pp.cd_processo_padrao,
    ppp.cd_produto_proc_padrao;

------------------------------------------------------
-- 4) Tabela de componentes "magrela" (#Comp)
------------------------------------------------------
IF OBJECT_ID('tempdb..#Comp') IS NOT NULL DROP TABLE #Comp;

SELECT
    cd_produto              = m.cd_produto,
    cd_mascara_produto      = CONVERT(VARCHAR(60),  m.cd_mascara_produto),
    nm_produto              = CONVERT(VARCHAR(200), m.nm_produto),
    Disponivel              = m.Disponivel,              -- produto acabado
    Minimo                  = m.Minimo,
    Dias                    = m.Dias,
    dt_previsao_entrega     = m.dt_previsao_entrega,
    cd_processo_padrao      = m.cd_processo_padrao,
    cd_comp_mascara_produto = CONVERT(VARCHAR(60),  m.cd_comp_mascara_produto),
    cd_produto_proc_padrao  = m.cd_produto_proc_padrao,
    qt_carteira             = ISNULL(m.qt_carteira,0),

    -- Necessidade do componente:
    -- demanda_total = qt_carteira + @qt_venda
    -- necessidade_produto = max(0, demanda_total - Disponivel)
    -- NecessidadeComp = necessidade_produto * qt_produto_processo
    NecessidadeComp =
        CAST(
            CASE 
                WHEN (@qt_venda = 0 AND ISNULL(m.qt_carteira,0) = 0) THEN
                    -- mapa atual => mostrar estoque do componente
                    m.comp_Disponivel
                ELSE 
                    CASE 
                        WHEN (@qt_venda + ISNULL(m.qt_carteira,0) - m.Disponivel) > 0 
                            THEN (@qt_venda + ISNULL(m.qt_carteira,0) - m.Disponivel)
                                 * m.qt_produto_processo
                        ELSE 0
                    END
            END
        AS DECIMAL(18,4))
INTO #Comp
FROM #MapaProducao m
WHERE m.cd_comp_mascara_produto IS NOT NULL;   -- ignora linhas sem componente

------------------------------------------------------
-- 5) Enumera componentes por Produto+Processo (#CompEnum)
--    rn = 1 => C1, rn = 2 => C2, ...
------------------------------------------------------
IF OBJECT_ID('tempdb..#CompEnum') IS NOT NULL DROP TABLE #CompEnum;

SELECT
    c.cd_produto,
    c.cd_mascara_produto,
    c.nm_produto,
    c.Disponivel,
    c.Minimo,
    c.Dias,
    c.dt_previsao_entrega,
    c.cd_processo_padrao,
    c.cd_comp_mascara_produto,
    c.NecessidadeComp,
    c.qt_carteira,
    rn = ROW_NUMBER() OVER (
         PARTITION BY c.cd_produto, c.cd_processo_padrao
         ORDER BY c.cd_produto_proc_padrao, c.cd_comp_mascara_produto
    )
INTO #CompEnum
FROM #Comp c;

------------------------------------------------------
-- 6) Atividades = nº de componentes por Produto+Processo
------------------------------------------------------
IF OBJECT_ID('tempdb..#Atividades') IS NOT NULL DROP TABLE #Atividades;

SELECT
    c1.cd_produto,
    c1.cd_processo_padrao,
    Atividades =
        STUFF((
            SELECT ', ' + c2.cd_comp_mascara_produto
            FROM #CompEnum c2
            WHERE c2.cd_produto         = c1.cd_produto
              AND c2.cd_processo_padrao = c1.cd_processo_padrao
              AND c2.NecessidadeComp > 0      -- só itens que vai produzir/comprar
            FOR XML PATH(''), TYPE
        ).value('.', 'VARCHAR(4000)'), 1, 2, '')
INTO #Atividades
FROM #CompEnum c1
GROUP BY
    c1.cd_produto,
    c1.cd_processo_padrao;


------------------------------------------------------
-- 7) Quantas colunas C1..CN preciso?
------------------------------------------------------
DECLARE @maxCol INT;
SELECT @maxCol = ISNULL(MAX(rn),0) FROM #CompEnum;

IF @maxCol = 0
BEGIN
    -- Sem componentes: só mostra cabeçalho básico
    SELECT 
        DISTINCT
        cd_mascara_produto AS Produto,
        nm_produto         AS Descricao,
        Disponivel,
        Minimo,
        Dias               AS LeadTime,
        dt_previsao_entrega AS Previsao,
        cd_processo_padrao AS PP,
        qt_carteira        AS Carteira,
        0 AS Atividades
    FROM #CompEnum;
    
    GOTO FIM_LIMPEZA;

END

------------------------------------------------------
-- 8) Monta dinamicamente C1..CN com MAX(CASE WHEN rn = n ...)
------------------------------------------------------
DECLARE @sql        NVARCHAR(MAX) = N'';
DECLARE @selectCols NVARCHAR(MAX) = N'';
DECLARE @i          INT          = 1;

WHILE @i <= @maxCol
BEGIN
    SET @selectCols = @selectCols + 
        CASE WHEN @i > 1 THEN ',' ELSE '' END +
        'MAX(CASE WHEN e.rn = '+CAST(@i AS VARCHAR(10))+
        ' THEN e.Conteudo END) AS C'+CAST(@i AS VARCHAR(10));
    SET @i = @i + 1;
END

SET @sql = N'
SELECT
    e.cd_mascara_produto AS Produto,
    e.nm_produto         AS Descricao,
    e.Disponivel,
    e.Minimo,
    e.Dias               AS LeadTime,
    e.dt_previsao_entrega AS Previsao,
    e.cd_processo_padrao AS PP,
    e.qt_carteira        AS Carteira,
    a.Atividades,
   
    ' + @selectCols + ',
     
     Processo = (
        SELECT
            componente = c2.cd_comp_mascara_produto,
            qt         = SUM(c2.NecessidadeComp)
        FROM #CompEnum c2
        WHERE c2.cd_produto         = e.cd_produto
          AND c2.cd_processo_padrao = e.cd_processo_padrao
          AND c2.NecessidadeComp > 0
        GROUP BY c2.cd_comp_mascara_produto
        FOR JSON PATH
    )

FROM (
    SELECT
        c.cd_produto,
        c.cd_mascara_produto,
        c.nm_produto,
        c.Disponivel,
        c.Minimo,
        c.Dias,
        c.dt_previsao_entrega,
        c.cd_processo_padrao,
        c.rn,
        c.qt_carteira,
        Conteudo = CAST(
            CONVERT(VARCHAR(20), c.cd_comp_mascara_produto) + ''='' +
            STR(c.NecessidadeComp, 20, 4)
        AS CHAR(45))    -- todas as colunas C1..CN com mesmo tamanho
    FROM #CompEnum c
) e
LEFT JOIN #Atividades a
    ON a.cd_produto         = e.cd_produto
   AND a.cd_processo_padrao = e.cd_processo_padrao
GROUP BY
    e.cd_produto,
    e.cd_mascara_produto,
    e.nm_produto,
    e.Disponivel,
    e.Minimo,
    e.Dias,
    e.dt_previsao_entrega,
    e.cd_processo_padrao,
    e.qt_carteira,
    a.Atividades
ORDER BY
    Produto,
    PP;
';

--PRINT @sql;  -- se quiser ver o SQL gerado
EXEC sp_executesql @sql;
----------------------------


-- JSON final com componentes e quantidades totais (somando todos os processos/produtos)
--SELECT
--    componente = cd_comp_mascara_produto,
--    qt         = SUM(NecessidadeComp)
--FROM #CompEnum
--WHERE NecessidadeComp > 0
--GROUP BY cd_comp_mascara_produto
--FOR JSON PATH;



-- JSON final com componentes e quantidades totais (somando todos os processos/produtos)
--SELECT
--    componente = cd_comp_mascara_produto,
--    qt         = SUM(NecessidadeComp)
--FROM #CompEnum
--WHERE NecessidadeComp > 0
--GROUP BY cd_comp_mascara_produto
--FOR JSON PATH;

/*
SELECT
    pp        = cd_processo_padrao,
    componentes = (
        SELECT
            componente = cd_comp_mascara_produto,
            qt         = SUM(NecessidadeComp)
        FROM #CompEnum c2
        WHERE c2.cd_processo_padrao = c1.cd_processo_padrao
          AND c2.NecessidadeComp > 0
        GROUP BY cd_comp_mascara_produto
        FOR JSON PATH
    )
FROM #CompEnum c1
GROUP BY cd_processo_padrao
FOR JSON PATH;
*/


------------------------------------------------------
-- 9) Limpeza
------------------------------------------------------
FIM_LIMPEZA:
IF OBJECT_ID('tempdb..#CompEnum')     IS NOT NULL DROP TABLE #CompEnum;
IF OBJECT_ID('tempdb..#Atividades')   IS NOT NULL DROP TABLE #Atividades;
IF OBJECT_ID('tempdb..#Comp')         IS NOT NULL DROP TABLE #Comp;
IF OBJECT_ID('tempdb..#MapaProducao') IS NOT NULL DROP TABLE #MapaProducao;
IF OBJECT_ID('tempdb..#Carteira')     IS NOT NULL DROP TABLE #Carteira;

GO
