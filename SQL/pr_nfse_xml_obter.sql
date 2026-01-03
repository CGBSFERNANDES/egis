IF OBJECT_ID('dbo.pr_nfse_xml_obter', 'P') IS NOT NULL
  DROP PROCEDURE dbo.pr_nfse_xml_obter;
GO

CREATE PROCEDURE dbo.pr_nfse_xml_obter
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

    --select @json

  select                     
 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      


  DECLARE @cd_nfse_xml INT --= TRY_CONVERT(INT, JSON_VALUE(@json,'$.cd_nfse_xml'));

  
  select @cd_nfse_xml             = valor from #json where campo = 'cd_nfse_xml'   
  --select @cd_nfse_xml

  --set @cd_nfse_xml = 61

  IF @cd_nfse_xml IS NULL
  BEGIN
    SELECT 0 AS sucesso, 400 AS codigo, N'cd_nfse_xml não informado.' AS mensagem;
    RETURN;
  END

  SELECT TOP 1
    cd_nfse_xml,
    ds_layout,
    nr_nfse,
    cd_verificacao,
    dt_emissao,
    cnpj_prestador,
    im_prestador,
    cnpj_tomador,
    vl_servicos,
    vl_iss,
    vl_liquido,
    aliq_iss,
    base_calculo,
    item_lista_servico,
    cod_trib_municipio,
    municipio_prestacao,
    ds_discriminacao,
    ds_xml
  FROM dbo.nfse_xml WITH(NOLOCK)
  WHERE cd_nfse_xml = @cd_nfse_xml;

  SELECT 1 AS sucesso, 200 AS codigo, N'OK' AS mensagem;
END
GO
--select * from nfse_xml

--exec pr_nfse_xml_obter '[{"cd_nfse_xml": 61}]'