/*
  Estrutura de apoio para o menu 8906 (Nota Débito)
  Referências:
    - pr_egis_servicos_processo_modulo (cd_parametro = 50)
    - pr_egis_contabilidade_processo_modulo (cd_parametro = 2)
  Observação: manter a lógica no engine único; não popular com dados fictícios.
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.pr_egis_servicos_processo_modulo
(
    @json NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_parametro            INT = 0,
        @cd_nota_debito_despesa  INT = 0;

    IF NULLIF(@json, N'') IS NOT NULL AND ISJSON(@json) = 1
    BEGIN
        IF JSON_VALUE(@json, '$[0]') IS NOT NULL
            SET @json = JSON_QUERY(@json, '$[0]');

        SELECT
            @cd_parametro           = cfg.cd_parametro,
            @cd_nota_debito_despesa = cfg.cd_nota_debito_despesa
        FROM OPENJSON(@json) WITH (
            cd_parametro            INT '$.cd_parametro',
            cd_nota_debito_despesa  INT '$.cd_nota_debito_despesa'
        ) cfg;
    END;

    /* =========================================================
       cd_parametro = 50 → despesas associadas à nota de débito
       Ajuste o SELECT conforme tabelas/visões reais do cliente.
       Não preencher com dados fictícios.
    ========================================================= */
    IF @cd_parametro = 50
    BEGIN
        SELECT
            CAST(NULL AS INT) AS cd_nota_debito_despesa
        WHERE 1 = 0;

        SELECT CAST(1 AS BIT) AS sucesso, 200 AS codigo, N'OK' AS mensagem;
        RETURN;
    END;

    SELECT CAST(1 AS BIT) AS sucesso, 200 AS codigo, N'OK' AS mensagem;
END
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
       Ajuste o SELECT conforme tabelas/visões reais do cliente.
       Não preencher com dados fictícios.
    ========================================================= */
    IF @cd_parametro = 2
    BEGIN
        SELECT
            CAST(NULL AS INT) AS cd_lote
        WHERE 1 = 0;

        SELECT CAST(1 AS BIT) AS sucesso, 200 AS codigo, N'OK' AS mensagem;
        RETURN;
    END;

    SELECT CAST(1 AS BIT) AS sucesso, 200 AS codigo, N'OK' AS mensagem;
END
GO
