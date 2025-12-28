CREATE OR ALTER PROCEDURE dbo.sp_BuscarTextoEmProcedures
    @TextoBusca NVARCHAR(4000)
AS
BEGIN
    SET NOCOUNT ON;

    -- Caso o usuário envie nulo ou vazio, já evitamos rodar à toa
    IF @TextoBusca IS NULL OR LTRIM(RTRIM(@TextoBusca)) = ''
    BEGIN
        RAISERROR('Informe um texto válido para busca.', 16, 1);
        RETURN;
    END;

    SELECT 
        p.object_id,
        Esquema        = s.name,
        ProcedureName  = p.name,
        Tipo           = p.type_desc,
        -- Aqui você pode comentar se não quiser trazer o texto completo
        Definicao      = m.definition
    FROM sys.procedures p
    INNER JOIN sys.sql_modules m ON p.object_id = m.object_id
    INNER JOIN sys.schemas s      ON p.schema_id = s.schema_id
    WHERE m.definition LIKE N'%' + @TextoBusca + N'%'
    ORDER BY s.name, p.name;
END;
GO


--EXEC dbo.sp_BuscarTextoEmProcedures @TextoBusca = N'pr_gera_mensagem_api_whatsapp';
-- ou
--EXEC dbo.sp_BuscarTextoEmProcedures @TextoBusca = N'SELECT * FROM';

