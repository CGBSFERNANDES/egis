/*
  Estrutura de apoio para o menu 8833 (Lote Contábil)
  Referência: pr_egis_contabilidade_processo_modulo
  Observação: manter a lógica no engine único; não popular com dados fictícios.
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.pr_egis_contabilidade_processo_modulo
(
    @json NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_parametro INT = 0,
        @cd_empresa   INT = 0,
        @cd_lote      INT = 0;

    -- Parser leve do JSON recebido (aceita array ou objeto)
    IF NULLIF(@json, N'') IS NOT NULL AND ISJSON(@json) = 1
    BEGIN
        IF JSON_VALUE(@json, '$[0]') IS NOT NULL
            SET @json = JSON_QUERY(@json, '$[0]');

        SELECT
            @cd_parametro = cfg.cd_parametro,
            @cd_empresa   = cfg.cd_empresa,
            @cd_lote      = cfg.cd_lote
        FROM OPENJSON(@json) WITH (
            cd_parametro INT '$.cd_parametro',
            cd_empresa   INT '$.cd_empresa',
            cd_lote      INT '$.cd_lote'
        ) cfg;
    END;

    /* =========================================================
       cd_parametro = 2 → lançamentos contábeis por lote
       (utilizado na aba "Lançamentos" do engine único)
       Adapte o SELECT conforme as tabelas do cliente.
       Não preencher com dados fictícios.
    ========================================================= */
    IF @cd_parametro = 2
    BEGIN
        -- Exemplo de estrutura (ajustar campos e joins reais):
        SELECT
            mc.cd_empresa,
            mc.cd_lote,
            mc.cd_lancamento_contabil,
            mc.dt_lancamento_contabil,
            mc.cd_conta_debito,
            mc.cd_conta_credito,
            mc.vl_lancamento_contabil,
            mc.ds_historico_contabil
        FROM movimento_contabil AS mc
        WHERE mc.cd_lote = @cd_lote
          AND (@cd_empresa = 0 OR mc.cd_empresa = @cd_empresa);

        SELECT CAST(1 AS BIT) AS sucesso, 200 AS codigo, N'OK' AS mensagem;
        RETURN;
    END;

    -- Status padrão para demais parâmetros/fluxos
    SELECT CAST(1 AS BIT) AS sucesso, 200 AS codigo, N'OK' AS mensagem;
END
GO
