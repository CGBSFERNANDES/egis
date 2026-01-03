IF OBJECT_ID('dbo.pr_cte_xml_inserir', 'P') IS NOT NULL
  DROP PROCEDURE dbo.pr_cte_xml_inserir;
GO

CREATE PROCEDURE dbo.pr_cte_xml_inserir
  @json NVARCHAR(MAX) = ''
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;

  IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
  BEGIN
    SELECT 0 AS sucesso, 400 AS codigo, N'Payload JSON inválido/vazio.' AS mensagem;
    RETURN;
  END

  IF JSON_VALUE(@json, '$[0]') IS NOT NULL
    SET @json = JSON_QUERY(@json, '$[0]');

 
 DECLARE 
  @cd_empresa INT,
  @cd_usuario_inclusao INT,
  @ds_layout VARCHAR(30),
  @ds_xml NVARCHAR(MAX);

SELECT
  @cd_empresa = TRY_CONVERT(INT, cd_empresa),
  @cd_usuario_inclusao = TRY_CONVERT(INT, cd_usuario_inclusao),
  @ds_layout = COALESCE(ds_layout, 'GINFES'),
  @ds_xml = ds_xml
FROM OPENJSON(@json)
WITH (
  cd_empresa          NVARCHAR(20)  '$.cd_empresa',
  cd_usuario_inclusao NVARCHAR(20)  '$.cd_usuario_inclusao',
  ds_layout           VARCHAR(30)   '$.ds_layout',
  ds_xml              NVARCHAR(MAX) '$.ds_xml'
);


  IF NULLIF(@ds_xml, N'') IS NULL
  BEGIN
    SELECT 0 AS sucesso, 400 AS codigo, N'ds_xml não informado.' AS mensagem;
    RETURN;
  END

  DECLARE @hash VARBINARY(32) = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @ds_xml));

  IF EXISTS (SELECT 1 FROM dbo.cte_xml WITH(NOLOCK) WHERE hash_xml = @hash)
  BEGIN
    SELECT 1 AS sucesso, 200 AS codigo, N'XML já importado (hash duplicado).' AS mensagem;
    RETURN;
  END

  DECLARE @xml XML =
    TRY_CONVERT(XML,
      CASE
        WHEN LEFT(LTRIM(@ds_xml),5) = '<?xml'
          THEN STUFF(@ds_xml, 1, CHARINDEX('?>', @ds_xml)+1, '')
        ELSE @ds_xml
      END
    );

  IF @xml IS NULL
  BEGIN
    SELECT 0 AS sucesso, 400 AS codigo, N'Não foi possível converter o XML.' AS mensagem;
    RETURN;
  END

  DECLARE
    @ch_cte VARCHAR(44) = NULL,
    @nr_cte VARCHAR(30) = NULL,
    @serie VARCHAR(10) = NULL,
    @dt_emissao DATETIME = NULL,
    @tp_cte VARCHAR(2) = NULL,
    @tp_serv VARCHAR(2) = NULL,
    @modal VARCHAR(5) = NULL,
    @cfop VARCHAR(10) = NULL,
    @cnpj_emit VARCHAR(20) = NULL,
    @xnome_emit NVARCHAR(200) = NULL,
    @cnpj_dest VARCHAR(20) = NULL,
    @xnome_dest NVARCHAR(200) = NULL,
    @uf_ini VARCHAR(2) = NULL,
    @uf_fim VARCHAR(2) = NULL,
    @xmun_ini NVARCHAR(60) = NULL,
    @xmun_fim NVARCHAR(60) = NULL,
    @v_tprest DECIMAL(18,2) = NULL,
    @v_rec DECIMAL(18,2) = NULL,
    @v_carga DECIMAL(18,2) = NULL,
    @pro_pred NVARCHAR(60) = NULL;

  -- chaves e ide
  SELECT @ch_cte = @xml.value('(//*[local-name()="chCTe"]/text())[1]', 'varchar(44)');
  SELECT @nr_cte = @xml.value('(//*[local-name()="nCT"]/text())[1]', 'varchar(30)');
  SELECT @serie  = @xml.value('(//*[local-name()="serie"]/text())[1]', 'varchar(10)');
  SELECT @tp_cte = @xml.value('(//*[local-name()="tpCTe"]/text())[1]', 'varchar(2)');
  SELECT @tp_serv= @xml.value('(//*[local-name()="tpServ"]/text())[1]', 'varchar(2)');
  SELECT @modal  = @xml.value('(//*[local-name()="modal"]/text())[1]', 'varchar(5)');
  SELECT @cfop   = @xml.value('(//*[local-name()="CFOP"]/text())[1]', 'varchar(10)');

  -- data (dhEmi vem tipo 2023-05-11T16:51:11-03:00)
  DECLARE @dhEmi VARCHAR(50) = @xml.value('(//*[local-name()="dhEmi"]/text())[1]', 'varchar(50)');
  IF NULLIF(@dhEmi,'') IS NOT NULL
  BEGIN
    -- remove timezone mantendo YYYY-MM-DDTHH:MM:SS
    SET @dhEmi = LEFT(@dhEmi, 19);
    SET @dt_emissao = TRY_CONVERT(datetime, REPLACE(@dhEmi,'T',' '), 120);
  END

  -- emit / dest
  SELECT @cnpj_emit  = @xml.value('(//*[local-name()="emit"]/*[local-name()="CNPJ"]/text())[1]', 'varchar(20)');
  SELECT @xnome_emit = @xml.value('(//*[local-name()="emit"]/*[local-name()="xNome"]/text())[1]', 'nvarchar(200)');

  -- dest pode ser CNPJ ou CPF
  SELECT @cnpj_dest =
    COALESCE(
      NULLIF(@xml.value('(//*[local-name()="dest"]/*[local-name()="CNPJ"]/text())[1]', 'varchar(20)'), ''),
      NULLIF(@xml.value('(//*[local-name()="dest"]/*[local-name()="CPF"]/text())[1]', 'varchar(20)'), '')
    );
  SELECT @xnome_dest = @xml.value('(//*[local-name()="dest"]/*[local-name()="xNome"]/text())[1]', 'nvarchar(200)');

  -- percurso
  SELECT @uf_ini   = @xml.value('(//*[local-name()="UFIni"]/text())[1]', 'varchar(2)');
  SELECT @uf_fim   = @xml.value('(//*[local-name()="UFFim"]/text())[1]', 'varchar(2)');
  SELECT @xmun_ini = @xml.value('(//*[local-name()="xMunIni"]/text())[1]', 'nvarchar(60)');
  SELECT @xmun_fim = @xml.value('(//*[local-name()="xMunFim"]/text())[1]', 'nvarchar(60)');

  -- valores
  SELECT @v_tprest = TRY_CONVERT(decimal(18,2), @xml.value('(//*[local-name()="vTPrest"]/text())[1]', 'varchar(40)'));
  SELECT @v_rec    = TRY_CONVERT(decimal(18,2), @xml.value('(//*[local-name()="vRec"]/text())[1]', 'varchar(40)'));

  -- carga
  SELECT @v_carga  = TRY_CONVERT(decimal(18,2), @xml.value('(//*[local-name()="infCarga"]/*[local-name()="vCarga"]/text())[1]', 'varchar(40)'));
  SELECT @pro_pred = @xml.value('(//*[local-name()="infCarga"]/*[local-name()="proPred"]/text())[1]', 'nvarchar(60)');

  INSERT INTO dbo.cte_xml
  (
    cd_empresa, cd_usuario_inclusao, ds_layout,
    ds_xml, hash_xml,
    ch_cte, nr_cte, serie, dt_emissao,
    tp_cte, tp_serv, modal, cfop,
    cnpj_emit, xnome_emit,
    cnpj_dest, xnome_dest,
    uf_ini, uf_fim, xmun_ini, xmun_fim,
    v_tprest, v_rec,
    v_carga, pro_pred
  )
  VALUES
  (
    @cd_empresa, @cd_usuario_inclusao, @ds_layout,
    @ds_xml, @hash,
    @ch_cte, @nr_cte, @serie, @dt_emissao,
    @tp_cte, @tp_serv, @modal, @cfop,
    @cnpj_emit, @xnome_emit,
    @cnpj_dest, @xnome_dest,
    @uf_ini, @uf_fim, @xmun_ini, @xmun_fim,
    @v_tprest, @v_rec,
    @v_carga, @pro_pred
  );

  SELECT 1 AS sucesso, 200 AS codigo, N'OK. CT-e importado.' AS mensagem;
  SELECT SCOPE_IDENTITY() AS cd_cte_xml;
END
GO
