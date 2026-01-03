IF OBJECT_ID('dbo.pr_nfse_xml_inserir', 'P') IS NOT NULL
  DROP PROCEDURE dbo.pr_nfse_xml_inserir;
GO

CREATE PROCEDURE dbo.pr_nfse_xml_inserir
  @json NVARCHAR(MAX) = N''
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;

  BEGIN TRY
    -------------------------------------------------------------------------
    -- 1) JSON ok?
    -------------------------------------------------------------------------
    IF ISJSON(@json) <> 1
    BEGIN
      SELECT 0 sucesso, 400 codigo, N'JSON inválido' mensagem;
      RETURN;
    END;

    IF JSON_QUERY(@json,'$[0]') IS NOT NULL
      SET @json = JSON_QUERY(@json,'$[0]');

    IF ISJSON(@json) <> 1
    BEGIN
      SELECT 0 sucesso, 400 codigo, N'JSON inválido (objeto esperado)' mensagem;
      RETURN;
    END;

    -------------------------------------------------------------------------
    -- 2) Lê JSON sem truncar ds_xml
    -------------------------------------------------------------------------
    DECLARE 
      @cd_empresa INT,
      @cd_usuario_inclusao INT,
      @ds_layout VARCHAR(30),
      @ds_xml NVARCHAR(MAX);

    SELECT
      @cd_empresa = cd_empresa,
      @cd_usuario_inclusao = cd_usuario_inclusao,
      @ds_layout = COALESCE(ds_layout,'GINFES'),
      @ds_xml = ds_xml
    FROM OPENJSON(@json)
    WITH
    (
      cd_empresa          INT           '$.cd_empresa',
      cd_usuario_inclusao INT           '$.cd_usuario_inclusao',
      ds_layout           VARCHAR(30)   '$.ds_layout',
      ds_xml              NVARCHAR(MAX) '$.ds_xml'
    );

    IF @cd_empresa IS NULL
    BEGIN
      SELECT 0 sucesso, 400 codigo, N'cd_empresa não informado' mensagem;
      RETURN;
    END;

    IF @cd_usuario_inclusao IS NULL
    BEGIN
      SELECT 0 sucesso, 400 codigo, N'cd_usuario_inclusao não informado' mensagem;
      RETURN;
    END;

    IF NULLIF(@ds_xml,N'') IS NULL
    BEGIN
      SELECT 0 sucesso, 400 codigo, N'ds_xml não informado' mensagem;
      RETURN;
    END;

    -------------------------------------------------------------------------
    -- 3) Sanitiza XML (BOM + cabeçalho)
    -------------------------------------------------------------------------
    SET @ds_xml = REPLACE(@ds_xml, NCHAR(65279), N''); -- BOM

    IF LEFT(LTRIM(@ds_xml),5) = N'<?xml'
    BEGIN
      DECLARE @p INT = CHARINDEX(N'?>', @ds_xml);
      IF @p > 0 SET @ds_xml = STUFF(@ds_xml, 1, @p+2, N'');
    END;

    DECLARE @xml XML = TRY_CONVERT(XML, @ds_xml);

    IF @xml IS NULL
    BEGIN
      SELECT 0 sucesso, 400 codigo, N'XML inválido (conversão falhou)' mensagem;
      RETURN;
    END;

    -------------------------------------------------------------------------
    -- 4) Staging
    -------------------------------------------------------------------------
    DECLARE @X TABLE
    (
      nfse_node XML NOT NULL,
      hash_xml VARBINARY(32) NULL,
      nr_nfse VARCHAR(30) NULL,
      cd_verificacao VARCHAR(60) NULL,
      dt_emissao DATETIME NULL,
      cnpj_prestador VARCHAR(20) NULL,
      im_prestador VARCHAR(30) NULL,
      cnpj_tomador VARCHAR(20) NULL,
      vl_servicos DECIMAL(18,2) NULL,
      vl_iss DECIMAL(18,2) NULL,
      vl_liquido DECIMAL(18,2) NULL,
      aliq_iss DECIMAL(9,4) NULL,
      base_calculo DECIMAL(18,2) NULL,
      item_lista_servico VARCHAR(20) NULL,
      cod_trib_municipio VARCHAR(30) NULL,
      municipio_prestacao VARCHAR(10) NULL,
      ds_discriminacao NVARCHAR(2000) NULL
    );

    DECLARE @ins TABLE
    (
      cd_nfse_xml INT,
      nr_nfse VARCHAR(30),
      cd_verificacao VARCHAR(60),
      dt_emissao DATETIME,
      cnpj_prestador VARCHAR(20),
      cnpj_tomador VARCHAR(20),
      vl_servicos DECIMAL(18,2),
      vl_iss DECIMAL(18,2),
      vl_liquido DECIMAL(18,2),
      hash_xml VARBINARY(32)
    );

    -------------------------------------------------------------------------
    -- 5) Extrai por nó <Nfse> (XPATHS RELATIVOS: ./ e não //* )
    -------------------------------------------------------------------------
    INSERT INTO @X
    (
      nfse_node, hash_xml,
      nr_nfse, cd_verificacao, dt_emissao,
      cnpj_prestador, im_prestador, cnpj_tomador,
      vl_servicos, vl_iss, vl_liquido, aliq_iss, base_calculo,
      item_lista_servico, cod_trib_municipio, municipio_prestacao, ds_discriminacao
    )
    SELECT
      N.query('.') AS nfse_node,
      HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), CONVERT(NVARCHAR(MAX), N.query('.')))) AS hash_xml,

      NULLIF(LTRIM(RTRIM(N.value('(./*[local-name()="IdentificacaoNfse"]/*[local-name()="Numero"]/text())[1]','varchar(30)'))), '') AS nr_nfse,
      NULLIF(LTRIM(RTRIM(N.value('(./*[local-name()="IdentificacaoNfse"]/*[local-name()="CodigoVerificacao"]/text())[1]','varchar(60)'))), '') AS cd_verificacao,

      -- NÃO troca o "T": style 126 gosta dele
      TRY_CONVERT(datetime, N.value('(./*[local-name()="DataEmissao"]/text())[1]','varchar(40)'), 126) AS dt_emissao,

      NULLIF(LTRIM(RTRIM(N.value('(./*[local-name()="PrestadorServico"]//*[local-name()="IdentificacaoPrestador"]/*[local-name()="Cnpj"]/text())[1]','varchar(20)'))), '') AS cnpj_prestador,
      NULLIF(LTRIM(RTRIM(N.value('(./*[local-name()="PrestadorServico"]//*[local-name()="IdentificacaoPrestador"]/*[local-name()="InscricaoMunicipal"]/text())[1]','varchar(30)'))), '') AS im_prestador,

      NULLIF(LTRIM(RTRIM(N.value('(./*[local-name()="TomadorServico"]//*[local-name()="CpfCnpj"]/*[local-name()="Cnpj"]/text())[1]','varchar(20)'))), '') AS cnpj_tomador,

      TRY_CONVERT(decimal(18,2), N.value('(./*[local-name()="Servico"]/*[local-name()="Valores"]/*[local-name()="ValorServicos"]/text())[1]','varchar(40)')) AS vl_servicos,
      TRY_CONVERT(decimal(18,2), N.value('(./*[local-name()="Servico"]/*[local-name()="Valores"]/*[local-name()="ValorIss"]/text())[1]','varchar(40)')) AS vl_iss,
      TRY_CONVERT(decimal(18,2), N.value('(./*[local-name()="Servico"]/*[local-name()="Valores"]/*[local-name()="ValorLiquidoNfse"]/text())[1]','varchar(40)')) AS vl_liquido,
      TRY_CONVERT(decimal(9,4),  N.value('(./*[local-name()="Servico"]/*[local-name()="Valores"]/*[local-name()="Aliquota"]/text())[1]','varchar(40)')) AS aliq_iss,
      TRY_CONVERT(decimal(18,2), N.value('(./*[local-name()="Servico"]/*[local-name()="Valores"]/*[local-name()="BaseCalculo"]/text())[1]','varchar(40)')) AS base_calculo,

      NULLIF(LTRIM(RTRIM(N.value('(./*[local-name()="Servico"]/*[local-name()="ItemListaServico"]/text())[1]','varchar(20)'))), '') AS item_lista_servico,
      NULLIF(LTRIM(RTRIM(N.value('(./*[local-name()="Servico"]/*[local-name()="CodigoTributacaoMunicipio"]/text())[1]','varchar(30)'))), '') AS cod_trib_municipio,
      NULLIF(LTRIM(RTRIM(N.value('(./*[local-name()="Servico"]/*[local-name()="MunicipioPrestacaoServico"]/text())[1]','varchar(10)'))), '') AS municipio_prestacao,
      NULLIF(LTRIM(RTRIM(N.value('(./*[local-name()="Servico"]/*[local-name()="Discriminacao"]/text())[1]','nvarchar(2000)'))), '') AS ds_discriminacao
    FROM @xml.nodes('//*[local-name()="Nfse"]') T(N)
    WHERE T.N.exist('./*[local-name()="IdentificacaoNfse"]') = 1;

    IF NOT EXISTS (SELECT 1 FROM @X)
    BEGIN
      SELECT 0 sucesso, 422 codigo, N'XML válido, mas não contém nós <Nfse> com <IdentificacaoNfse>.' mensagem;
      RETURN;
    END;

    -------------------------------------------------------------------------
    -- 6) Validação mínima
    -------------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM @X WHERE nr_nfse IS NULL OR cd_verificacao IS NULL OR cnpj_prestador IS NULL)
    BEGIN
      SELECT 0 sucesso, 422 codigo,
        N'XML lido, mas não foi possível extrair chave mínima (Numero/CodigoVerificacao/CNPJ Prestador).' mensagem;
      SELECT TOP 5 * FROM @X;
      RETURN;
    END;

    -------------------------------------------------------------------------
    -- 7) Dedupe dentro do lote + contra a tabela
    -------------------------------------------------------------------------
    ;WITH Lote AS
    (
      SELECT
        X.*,
        ROW_NUMBER() OVER
        (
          PARTITION BY X.nr_nfse, X.cd_verificacao, X.cnpj_prestador, @ds_layout
          ORDER BY X.hash_xml
        ) AS rn
      FROM @X X
    )
    INSERT INTO dbo.nfse_xml
    (
      cd_empresa, cd_usuario_inclusao, ds_layout,
      ds_xml, hash_xml,
      nr_nfse, cd_verificacao, dt_emissao,
      cnpj_prestador, cnpj_tomador, im_prestador,
      vl_servicos, vl_iss, vl_liquido, aliq_iss, base_calculo,
      item_lista_servico, cod_trib_municipio, municipio_prestacao,
      ds_discriminacao
    )
    OUTPUT
      inserted.cd_nfse_xml,
      inserted.nr_nfse,
      inserted.cd_verificacao,
      inserted.dt_emissao,
      inserted.cnpj_prestador,
      inserted.cnpj_tomador,
      inserted.vl_servicos,
      inserted.vl_iss,
      inserted.vl_liquido,
      inserted.hash_xml
    INTO @ins
    SELECT
      @cd_empresa, @cd_usuario_inclusao, @ds_layout,
      CONVERT(NVARCHAR(MAX), nfse_node), hash_xml,
      nr_nfse, cd_verificacao, dt_emissao,
      cnpj_prestador, cnpj_tomador, im_prestador,
      vl_servicos, vl_iss, vl_liquido, aliq_iss, base_calculo,
      item_lista_servico, cod_trib_municipio, municipio_prestacao,
      ds_discriminacao
    FROM Lote
    WHERE rn = 1
      AND NOT EXISTS
      (
        SELECT 1
        FROM dbo.nfse_xml e WITH (NOLOCK)
        WHERE e.ds_layout = @ds_layout
          AND e.nr_nfse = Lote.nr_nfse
          AND e.cd_verificacao = Lote.cd_verificacao
          AND e.cnpj_prestador = Lote.cnpj_prestador
      );

    SELECT 1 sucesso, 200 codigo,
           CONCAT(N'Importadas ', (SELECT COUNT(*) FROM @ins), N' NFS-e.') mensagem;

    SELECT * FROM @ins;

  END TRY
  BEGIN CATCH
    SELECT 0 sucesso,
           ERROR_NUMBER() codigo,
           CONCAT(N'Erro: ', ERROR_MESSAGE()) mensagem;
  END CATCH
END;
GO
