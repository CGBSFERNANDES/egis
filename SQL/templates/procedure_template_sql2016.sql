/*
  Template oficial de Stored Procedure (SQL Server 2016)
  Retorno: último resultset com status HTTP padrão.
  Dados (um ou mais resultsets) devem vir ANTES do status.

  Status HTTP:
    200 = OK
    400 = validação/entrada inválida
    404 = não encontrado
    500 = erro interno
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.<nome_da_procedure>
(
    -- Exemplo:
    -- @json NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @sucesso  BIT = 0,
        @codigo   INT = 200,
        @mensagem NVARCHAR(4000) = N'OK';

    BEGIN TRY
        /* =========================================================
           1) Validações de entrada (retornar 400)
           ========================================================= */

        -- IF @json IS NULL
        -- BEGIN
        --     SELECT CAST(0 AS BIT) AS sucesso, 400 AS codigo, N'json é obrigatório' AS mensagem;
        --     RETURN;
        -- END

        /* =========================================================
           2) Parse de JSON (SQL 2016: OPENJSON) - opcional
           ========================================================= */
        -- DECLARE @campo INT;
        -- SELECT @campo = j.campo
        -- FROM OPENJSON(@json) WITH (campo INT '$.campo') j;

        /* =========================================================
           3) Regras de negócio / queries
           ========================================================= */
        -- Se houver escrita (INSERT/UPDATE/DELETE), use transação curta:
        -- BEGIN TRAN;

        -- ... sua lógica ...
        -- SELECT ... (dados)

        -- COMMIT TRAN;

        /* =========================================================
           4) Status final (sempre o último resultset)
           ========================================================= */
        SELECT CAST(1 AS BIT) AS sucesso, 200 AS codigo, N'OK' AS mensagem;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRAN;

        DECLARE
            @ErrMsg  NVARCHAR(2048) = ERROR_MESSAGE(),
            @ErrProc NVARCHAR(256)  = ERROR_PROCEDURE(),
            @ErrLine INT            = ERROR_LINE();

        SET @mensagem =
            N'Erro em ' + ISNULL(@ErrProc, N'(proc desconhecida)') +
            N' | Linha ' + CONVERT(NVARCHAR(10), @ErrLine) +
            N' | ' + @ErrMsg;

        SELECT CAST(0 AS BIT) AS sucesso, 500 AS codigo, @mensagem AS mensagem;
    END CATCH
END
GO
