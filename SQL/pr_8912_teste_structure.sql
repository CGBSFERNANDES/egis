/*
  Estrutura de apoio para o menu 8912 (Teste)
  Observação: manter a lógica no engine único; não popular com dados fictícios.
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.pr_egis_menu_8912_processo_modulo
(
    @json NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_parametro INT = 0;

    -- Parser leve do JSON recebido (aceita array ou objeto)
    IF NULLIF(@json, N'') IS NOT NULL AND ISJSON(@json) = 1
    BEGIN
        IF JSON_VALUE(@json, '$[0]') IS NOT NULL
            SET @json = JSON_QUERY(@json, '$[0]');

        SELECT
            @cd_parametro = cfg.cd_parametro
        FROM OPENJSON(@json) WITH (
            cd_parametro INT '$.cd_parametro'
        ) cfg;
    END;

    /* =========================================================
       cd_parametro = 10 → listagem principal do menu 8912
       Ajustar o SELECT conforme metadados e tabelas do cliente.
       Não preencher com dados fictícios.
    ========================================================= */
    IF @cd_parametro = 10
    BEGIN
        -- TODO: implementar SELECT de listagem do menu 8912.
        SELECT CAST(1 AS BIT) AS sucesso, 200 AS codigo, N'OK' AS mensagem;
        RETURN;
    END;

    /* =========================================================
       cd_parametro = 20/21 → salvar (INSERT/UPDATE) do menu 8912
       Ajustar parâmetros e persistência conforme metadados.
    ========================================================= */
    IF @cd_parametro IN (20, 21)
    BEGIN
        -- TODO: implementar INSERT/UPDATE do menu 8912.
        SELECT CAST(1 AS BIT) AS sucesso, 200 AS codigo, N'OK' AS mensagem;
        RETURN;
    END;

    /* =========================================================
       cd_parametro = 30 → exclusão do menu 8912
       Ajustar conforme regra de negócio.
    ========================================================= */
    IF @cd_parametro = 30
    BEGIN
        -- TODO: implementar DELETE do menu 8912.
        SELECT CAST(1 AS BIT) AS sucesso, 200 AS codigo, N'OK' AS mensagem;
        RETURN;
    END;

    -- Status padrão para demais parâmetros/fluxos
    SELECT CAST(1 AS BIT) AS sucesso, 200 AS codigo, N'OK' AS mensagem;
END
GO
