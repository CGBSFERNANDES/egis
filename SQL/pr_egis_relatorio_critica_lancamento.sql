IF OBJECT_ID('dbo.pr_egis_relatorio_critica_lancamento', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_critica_lancamento;
GO

/*
-------------------------------------------------------------------------------
-- pr_egis_relatorio_critica_lancamento
-------------------------------------------------------------------------------
-- GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
-- Stored Procedure : Microsoft SQL Server 2016
--                   Gera colunas solicitadas e monta a crítica de consistência
-- Autor(es)       : Codex (assistente)                                      
-- Data            : 2026-01-05
-- Requisitos      :
--   - SET NOCOUNT ON
--   - TRY/CATCH com THROW
--   - Sem cursor
--   - Performance para grandes volumes
-------------------------------------------------------------------------------
*/
CREATE PROCEDURE dbo.pr_egis_relatorio_critica_lancamento

    @json         NVARCHAR(MAX) = NULL       -- Parâmetros vindos do front-end (datas e filtros opcionais)
AS
BEGIN
    SET NOCOUNT ON;

    declare  @cd_relatorio INT = 407                 -- Código do relatório cadastrado em egisadmin.dbo.relatorio
    
    DECLARE
        @cd_empresa            INT          = NULL,
        @cd_usuario            INT          = NULL,
        @dt_inicial_exercicio  DATE         = NULL,
        @dt_final_exercicio    DATE         = NULL,
        @cd_lancamento_inicial INT          = NULL,
        @cd_lancamento_final   INT          = NULL,
        @cd_lote_inicial       INT          = NULL,
        @cd_lote_final         INT          = NULL;

    BEGIN TRY
        /*
           1) Normaliza o JSON recebido
              - Aceita array ou objeto
              - Captura apenas campos usados no relatório
        */
        IF NULLIF(@json, N'') IS NOT NULL AND ISJSON(@json) = 1
        BEGIN
            IF JSON_VALUE(@json, '$[0]') IS NOT NULL
                SET @json = JSON_QUERY(@json, '$[0]');

            SELECT
                @cd_empresa            = COALESCE(cfg.cd_empresa, @cd_empresa),
                @cd_usuario            = COALESCE(cfg.cd_usuario, @cd_usuario),
                @dt_inicial_exercicio  = COALESCE(cfg.dt_inicial, @dt_inicial_exercicio),
                @dt_final_exercicio    = COALESCE(cfg.dt_final, @dt_final_exercicio),
                @cd_lancamento_inicial = COALESCE(cfg.cd_lancamento_inicial, @cd_lancamento_inicial),
                @cd_lancamento_final   = COALESCE(cfg.cd_lancamento_final, @cd_lancamento_final),
                @cd_lote_inicial       = COALESCE(cfg.cd_lote_inicial, @cd_lote_inicial),
                @cd_lote_final         = COALESCE(cfg.cd_lote_final, @cd_lote_final)
            FROM OPENJSON(@json) WITH (
                cd_empresa            INT  '$.cd_empresa',
                cd_usuario            INT  '$.cd_usuario',
                dt_inicial            DATE '$.dt_inicial',
                dt_final              DATE '$.dt_final',
                cd_lancamento_inicial INT  '$.cd_lancamento_inicial',
                cd_lancamento_final   INT  '$.cd_lancamento_final',
                cd_lote_inicial       INT  '$.cd_lote_inicial',
                cd_lote_final         INT  '$.cd_lote_final'
            ) cfg;
        END

        /*
           2) Recupera intervalo default do Parametro_Relatorio (quando existir)
              Mantém valores informados no JSON.
        */
        IF @cd_relatorio IS NOT NULL AND @cd_relatorio > 0
        BEGIN
            SELECT
                @dt_inicial_exercicio = COALESCE(@dt_inicial_exercicio, pr.dt_inicial),
                @dt_final_exercicio   = COALESCE(@dt_final_exercicio, pr.dt_final)
            FROM Parametro_Relatorio AS pr WITH (NOLOCK)
            WHERE pr.cd_relatorio = @cd_relatorio
              AND (@cd_usuario IS NULL OR pr.cd_usuario_relatorio = @cd_usuario);
        END

        /* 3) Defaults seguros para evitar varreduras desnecessárias */
        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());
        SET @dt_inicial_exercicio = ISNULL(@dt_inicial_exercicio, DATEADD(DAY, -30, CAST(GETDATE() AS DATE)));
        SET @dt_final_exercicio   = ISNULL(@dt_final_exercicio, CAST(GETDATE() AS DATE));
        SET @cd_lancamento_inicial = ISNULL(@cd_lancamento_inicial, 0);
        SET @cd_lancamento_final   = ISNULL(@cd_lancamento_final, 2147483647);
        SET @cd_lote_inicial       = ISNULL(@cd_lote_inicial, 0);
        SET @cd_lote_final         = ISNULL(@cd_lote_final, 2147483647);

        /*
           4) Base do relatório: aplica filtros e monta flags de crítica
              - Critérios exigidos: falta valor, débito/crédito, sem histórico padrão, sem lote
              - Verifica equilíbrio débito x crédito por lançamento
        */
        ;WITH BaseLancamento AS (
            SELECT
                a.dt_lancamento_contabil,
                a.cd_lancamento_contabil,
                a.cd_reduzido_debito,
                a.cd_reduzido_credito,
                a.vl_lancamento_contabil,
                a.cd_historico_contabil,
                a.ds_historico_contabil,
                a.cd_lote,
                CAST(CASE WHEN ISNULL(a.vl_lancamento_contabil, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS ic_falta_valor,
                CAST(CASE WHEN ISNULL(a.cd_reduzido_debito, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS ic_falta_debito,
                CAST(CASE WHEN ISNULL(a.cd_reduzido_credito, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS ic_falta_credito,
                CAST(CASE WHEN ISNULL(a.cd_historico_contabil, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS ic_sem_historico,
                CAST(CASE WHEN ISNULL(a.cd_lote, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS ic_sem_lote,
                SUM(CASE WHEN ISNULL(a.cd_reduzido_debito, 0) > 0 THEN a.vl_lancamento_contabil ELSE 0 END)
                    OVER (PARTITION BY a.cd_empresa, a.cd_lancamento_contabil) AS vl_total_debito,
                SUM(CASE WHEN ISNULL(a.cd_reduzido_credito, 0) > 0 THEN a.vl_lancamento_contabil ELSE 0 END)
                    OVER (PARTITION BY a.cd_empresa, a.cd_lancamento_contabil) AS vl_total_credito
            FROM movimento_contabil AS a WITH (NOLOCK)
            WHERE a.cd_empresa = @cd_empresa
              AND a.dt_lancamento_contabil BETWEEN @dt_inicial_exercicio AND @dt_final_exercicio
              AND a.cd_lancamento_contabil BETWEEN @cd_lancamento_inicial AND @cd_lancamento_final
              AND a.cd_lote BETWEEN @cd_lote_inicial AND @cd_lote_final
        )
        SELECT
            b.dt_lancamento_contabil AS [Data],
            b.cd_lancamento_contabil AS Lancamento,
            b.cd_reduzido_debito     AS Debito,
            b.cd_reduzido_credito    AS Credito,
            b.vl_lancamento_contabil AS ValorLancamento,
            b.cd_historico_contabil  AS CodHis,
            b.ds_historico_contabil  AS Historico,
            b.cd_lote                AS Lote,
            crit.ds_critica          AS Critica
        FROM BaseLancamento AS b
        CROSS APPLY (
            SELECT
                LTRIM(STUFF(
                    CONCAT(
                        CASE WHEN b.ic_falta_valor    = 1 THEN '; Falta valor' ELSE '' END,
                        CASE WHEN b.ic_falta_debito   = 1 THEN '; Falta débito' ELSE '' END,
                        CASE WHEN b.ic_falta_credito  = 1 THEN '; Falta crédito' ELSE '' END,
                        CASE WHEN b.vl_total_debito <> b.vl_total_credito THEN '; Não fecha com crédito' ELSE '' END,
                        CASE WHEN b.ic_sem_historico  = 1 THEN '; Sem histórico padrão' ELSE '' END,
                        CASE WHEN b.ic_sem_lote       = 1 THEN '; Sem lote' ELSE '' END
                    ),
                    1,
                    2,
                    ''
                )) AS ds_critica
        ) AS crit
        WHERE crit.ds_critica IS NOT NULL AND LTRIM(RTRIM(crit.ds_critica)) <> ''
        ORDER BY b.dt_lancamento_contabil, b.cd_lancamento_contabil;
    END TRY
    BEGIN CATCH
        DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(
            'pr_egis_relatorio_critica_lancamento falhou: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        --THROW ERROR_NUMBER(), @errMsg, ERROR_STATE();
    END CATCH
END
GO

--exec pr_egis_relatorio_critica_lancamento '[{"dt_inicial": "01/01/2023", "dt_final": "12/31/2023"}]'