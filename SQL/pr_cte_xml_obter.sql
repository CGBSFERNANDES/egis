IF OBJECT_ID('dbo.pr_cte_xml_obter', 'P') IS NOT NULL
  DROP PROCEDURE dbo.pr_cte_xml_obter;
GO

CREATE PROCEDURE dbo.pr_cte_xml_obter
  @json NVARCHAR(MAX) = ''
AS
BEGIN
  SET NOCOUNT ON;

  IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
  BEGIN
    SELECT 0 AS sucesso, 400 AS codigo, N'Payload JSON inválido/vazio.' AS mensagem;
    RETURN;
  END

  IF JSON_VALUE(@json, '$[0]') IS NOT NULL
    SET @json = JSON_QUERY(@json, '$[0]');

  --DECLARE @cd_cte_xml INT = TRY_CONVERT(INT, JSON_VALUE(@json,'$.cd_cte_xml'));

  declare @cd_cte_xml int = 0

 select                     
 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

  select @cd_cte_xml             = valor from #json where campo = 'cd_cte_xml'    


  IF @cd_cte_xml IS NULL
  BEGIN
    SELECT 0 AS sucesso, 400 AS codigo, N'cd_cte_xml não informado.' AS mensagem;
    RETURN;
  END

  SELECT TOP 1 *
  FROM dbo.cte_xml WITH(NOLOCK)
  WHERE cd_cte_xml = @cd_cte_xml;

  SELECT 1 AS sucesso, 200 AS codigo, N'OK' AS mensagem;
END
GO
