-- Capa
IF OBJECT_ID('dbo.nfe_nota', 'U') IS NULL
CREATE TABLE dbo.nfe_nota(
  cd_nfe_nota       INT IDENTITY(1,1) PRIMARY KEY,
  cd_xml_nota       INT NOT NULL FOREIGN KEY REFERENCES dbo.nota_xml(cd_xml_nota),
  chave_acesso      VARCHAR(44) NULL,
  natOp             NVARCHAR(60) NULL,
  mod               INT NULL,
  serie             INT NULL,
  nNF               INT NULL,
  dhEmi             DATETIME NULL,
  tpNF              INT NULL,
  idDest            INT NULL,
  cUF               INT NULL,
  cMunFG            INT NULL,
  tpAmb             INT NULL,
  finNFe            INT NULL,
  indFinal          INT NULL,
  indPres           INT NULL,
  verProc           NVARCHAR(20) NULL,
  -- Emitente
  emit_CNPJ         VARCHAR(14) NULL,
  emit_xNome        NVARCHAR(120) NULL,
  emit_IE           NVARCHAR(20) NULL,
  emit_CRT          INT NULL,
  -- Destinatário
  dest_CNPJ         VARCHAR(14) NULL,
  dest_CPF          VARCHAR(11) NULL,
  dest_xNome        NVARCHAR(120) NULL,
  dest_IE           NVARCHAR(20) NULL,
  dest_email        NVARCHAR(120) NULL,
  -- Totais (ICMSTot)
  vBC               DECIMAL(18,2) NULL,
  vICMS             DECIMAL(18,2) NULL,
  vProd             DECIMAL(18,2) NULL,
  vFrete            DECIMAL(18,2) NULL,
  vDesc             DECIMAL(18,2) NULL,
  vIPI              DECIMAL(18,2) NULL,
  vPIS              DECIMAL(18,2) NULL,
  vCOFINS           DECIMAL(18,2) NULL,
  vNF               DECIMAL(18,2) NULL,
  cd_usuario_inclusao INT NULL,
  dt_usuario_inclusao DATETIME NOT NULL DEFAULT(GETDATE())
);

-- Itens
IF OBJECT_ID('dbo.nfe_item', 'U') IS NULL
CREATE TABLE dbo.nfe_item(
  cd_nfe_item       INT IDENTITY(1,1) PRIMARY KEY,
  cd_nfe_nota       INT NOT NULL FOREIGN KEY REFERENCES dbo.nfe_nota(cd_nfe_nota),
  nItem             INT NOT NULL,
  cProd             NVARCHAR(60) NULL,
  cEAN              NVARCHAR(20) NULL,
  xProd             NVARCHAR(200) NULL,
  NCM               NVARCHAR(10) NULL,
  CFOP              NVARCHAR(10) NULL,
  uCom              NVARCHAR(6) NULL,
  qCom              DECIMAL(18,6) NULL,
  vUnCom            DECIMAL(18,6) NULL,
  vProd             DECIMAL(18,2) NULL,
  uTrib             NVARCHAR(6) NULL,
  qTrib             DECIMAL(18,6) NULL,
  vUnTrib           DECIMAL(18,6) NULL,
  orig              INT NULL,
  CST               NVARCHAR(3) NULL,  -- ou CSOSN
  pICMS             DECIMAL(18,4) NULL,
  vICMS             DECIMAL(18,2) NULL,
  pIPI              DECIMAL(18,4) NULL,
  vIPI              DECIMAL(18,2) NULL,
  pPIS              DECIMAL(18,4) NULL,
  vPIS              DECIMAL(18,2) NULL,
  pCOFINS           DECIMAL(18,4) NULL,
  vCOFINS           DECIMAL(18,2) NULL
);

-- Duplicatas (cobr/dup)
IF OBJECT_ID('dbo.nfe_dup', 'U') IS NULL
CREATE TABLE dbo.nfe_dup(
  cd_nfe_dup        INT IDENTITY(1,1) PRIMARY KEY,
  cd_nfe_nota       INT NOT NULL FOREIGN KEY REFERENCES dbo.nfe_nota(cd_nfe_nota),
  nDup              NVARCHAR(60) NULL,
  dVenc             DATE NULL,
  vDup              DECIMAL(18,2) NULL
);

-- Transporte (simplificado)
IF OBJECT_ID('dbo.nfe_transp', 'U') IS NULL
CREATE TABLE dbo.nfe_transp(
  cd_nfe_transp     INT IDENTITY(1,1) PRIMARY KEY,
  cd_nfe_nota       INT NOT NULL FOREIGN KEY REFERENCES dbo.nfe_nota(cd_nfe_nota),
  modFrete          INT NULL,
  xNome             NVARCHAR(120) NULL,
  CNPJ              VARCHAR(14) NULL,
  CPF               VARCHAR(11) NULL
);


IF OBJECT_ID('dbo.pr_gera_xml_nfe', 'P') IS NOT NULL
  DROP PROCEDURE dbo.pr_gera_xml_nfe;
GO
CREATE PROCEDURE dbo.pr_gera_xml_nfe
  @cd_xml_nota INT,
  @cd_usuario  INT = NULL
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DECLARE @ds_xml NVARCHAR(MAX);
    SELECT @ds_xml = ds_xml FROM dbo.nota_xml WHERE cd_xml_nota = @cd_xml_nota;

    IF @ds_xml IS NULL
    BEGIN
      RAISERROR('XML não encontrado para cd_xml_nota=%d', 16, 1, @cd_xml_nota);
      RETURN;
    END

    DECLARE @x XML = TRY_CAST(@ds_xml AS XML);
    IF @x IS NULL
    BEGIN
      RAISERROR('Conteúdo ds_xml inválido (não é XML).', 16, 1);
      RETURN;
    END

    -- Tenta localizar o nó infNFe (seja em /nfeProc/NFe/infNFe ou /NFe/infNFe)
    DECLARE @temProc INT = @x.value('declare default element namespace "http://www.portalfiscal.inf.br/nfe"; count(/nfeProc)', 'int');

    -- CAPA --------------------------------------------------------------------
    DECLARE @cd_nfe_nota INT;

    ;WITH XMLNAMESPACES (DEFAULT 'http://www.portalfiscal.inf.br/nfe')
    SELECT
      -- ide
      @cd_nfe_nota = NULL
    ;

    -- apaga registros anteriores desta nota (se reprocessar)
    DELETE nt FROM dbo.nfe_transp nt
      INNER JOIN dbo.nfe_nota n ON n.cd_nfe_nota = nt.cd_nfe_nota
     WHERE n.cd_xml_nota = @cd_xml_nota;

    DELETE di FROM dbo.nfe_dup di
      INNER JOIN dbo.nfe_nota n ON n.cd_nfe_nota = di.cd_nfe_nota
     WHERE n.cd_xml_nota = @cd_xml_nota;

    DELETE it FROM dbo.nfe_item it
      INNER JOIN dbo.nfe_nota n ON n.cd_nfe_nota = it.cd_nfe_nota
     WHERE n.cd_xml_nota = @cd_xml_nota;

    DELETE FROM dbo.nfe_nota WHERE cd_xml_nota = @cd_xml_nota;

    -- Extrai campos da capa
    DECLARE
      @chave_acesso  VARCHAR(44),
      @natOp         NVARCHAR(60),
      @mod           INT,
      @serie         INT,
      @nNF           INT,
      @dhEmi         DATETIME,
      @tpNF          INT,
      @idDest        INT,
      @cUF           INT,
      @cMunFG        INT,
      @tpAmb         INT,
      @finNFe        INT,
      @indFinal      INT,
      @indPres       INT,
      @verProc       NVARCHAR(20),
      -- emit
      @emit_CNPJ     VARCHAR(14),
      @emit_xNome    NVARCHAR(120),
      @emit_IE       NVARCHAR(20),
      @emit_CRT      INT,
      -- dest
      @dest_CNPJ     VARCHAR(14),
      @dest_CPF      VARCHAR(11),
      @dest_xNome    NVARCHAR(120),
      @dest_IE       NVARCHAR(20),
      @dest_email    NVARCHAR(120),
      -- totais
      @vBC           DECIMAL(18,2),
      @vICMS         DECIMAL(18,2),
      @vProd         DECIMAL(18,2),
      @vFrete        DECIMAL(18,2),
      @vDesc         DECIMAL(18,2),
      @vIPI          DECIMAL(18,2),
      @vPIS          DECIMAL(18,2),
      @vCOFINS       DECIMAL(18,2),
      @vNF           DECIMAL(18,2);

    -- Usando default namespace NFe
    ;WITH XMLNAMESPACES (DEFAULT 'http://www.portalfiscal.inf.br/nfe')
    SELECT
      @chave_acesso = T.N.value('(./@Id)[1]',         'varchar(60)'),
      @natOp        = T.N.value('(ide/natOp/text())[1]','nvarchar(60)'),
      @mod          = T.N.value('(ide/mod/text())[1]', 'int'),
      @serie        = T.N.value('(ide/serie/text())[1]','int'),
      @nNF          = T.N.value('(ide/nNF/text())[1]', 'int'),
      @dhEmi        = TRY_CONVERT(datetime, T.N.value('(ide/dhEmi/text())[1]','nvarchar(30)'), 126),
      @tpNF         = T.N.value('(ide/tpNF/text())[1]', 'int'),
      @idDest       = T.N.value('(ide/idDest/text())[1]','int'),
      @cUF          = T.N.value('(ide/cUF/text())[1]',  'int'),
      @cMunFG       = T.N.value('(ide/cMunFG/text())[1]','int'),
      @tpAmb        = T.N.value('(ide/tpAmb/text())[1]','int'),
      @finNFe       = T.N.value('(ide/finNFe/text())[1]','int'),
      @indFinal     = T.N.value('(ide/indFinal/text())[1]','int'),
      @indPres      = T.N.value('(ide/indPres/text())[1]','int'),
      @verProc      = T.N.value('(ide/verProc/text())[1]','nvarchar(20)'),
      @emit_CNPJ    = T.N.value('(emit/CNPJ/text())[1]','varchar(14)'),
      @emit_xNome   = T.N.value('(emit/xNome/text())[1]','nvarchar(120)'),
      @emit_IE      = T.N.value('(emit/IE/text())[1]','nvarchar(20)'),
      @emit_CRT     = T.N.value('(emit/CRT/text())[1]','int'),
      @dest_CNPJ    = T.N.value('(dest/CNPJ/text())[1]','varchar(14)'),
      @dest_CPF     = T.N.value('(dest/CPF/text())[1]','varchar(11)'),
      @dest_xNome   = T.N.value('(dest/xNome/text())[1]','nvarchar(120)'),
      @dest_IE      = T.N.value('(dest/IE/text())[1]','nvarchar(20)'),
      @dest_email   = T.N.value('(dest/email/text())[1]','nvarchar(120)'),
      @vBC          = T.N.value('(total/ICMSTot/vBC/text())[1]',   'decimal(18,2)'),
      @vICMS        = T.N.value('(total/ICMSTot/vICMS/text())[1]', 'decimal(18,2)'),
      @vProd        = T.N.value('(total/ICMSTot/vProd/text())[1]', 'decimal(18,2)'),
      @vFrete       = T.N.value('(total/ICMSTot/vFrete/text())[1]','decimal(18,2)'),
      @vDesc        = T.N.value('(total/ICMSTot/vDesc/text())[1]', 'decimal(18,2)'),
      @vIPI         = T.N.value('(total/ICMSTot/vIPI/text())[1]',  'decimal(18,2)'),
      @vPIS         = T.N.value('(total/ICMSTot/vPIS/text())[1]',  'decimal(18,2)'),
      @vCOFINS      = T.N.value('(total/ICMSTot/vCOFINS/text())[1]','decimal(18,2)'),
      @vNF          = T.N.value('(total/ICMSTot/vNF/text())[1]',   'decimal(18,2)')
    FROM @x.nodes(CASE WHEN @temProc=1
                       THEN '/nfeProc/NFe/infNFe'
                       ELSE '/NFe/infNFe'
                  END) AS T(N);

    INSERT INTO dbo.nfe_nota(
      cd_xml_nota, chave_acesso, natOp, mod, serie, nNF, dhEmi, tpNF, idDest, cUF, cMunFG, tpAmb, finNFe, indFinal, indPres, verProc,
      emit_CNPJ, emit_xNome, emit_IE, emit_CRT, dest_CNPJ, dest_CPF, dest_xNome, dest_IE, dest_email,
      vBC, vICMS, vProd, vFrete, vDesc, vIPI, vPIS, vCOFINS, vNF, cd_usuario_inclusao)
    VALUES(
      @cd_xml_nota, @chave_acesso, @natOp, @mod, @serie, @nNF, @dhEmi, @tpNF, @idDest, @cUF, @cMunFG, @tpAmb, @finNFe, @indFinal, @indPres, @verProc,
      @emit_CNPJ, @emit_xNome, @emit_IE, @emit_CRT, @dest_CNPJ, @dest_CPF, @dest_xNome, @dest_IE, @dest_email,
      @vBC, @vICMS, @vProd, @vFrete, @vDesc, @vIPI, @vPIS, @vCOFINS, @vNF, @cd_usuario);

    SET @cd_nfe_nota = SCOPE_IDENTITY();

    -- ITENS -------------------------------------------------------------------
    ;WITH XMLNAMESPACES (DEFAULT 'http://www.portalfiscal.inf.br/nfe')
    INSERT INTO dbo.nfe_item(
      cd_nfe_nota,nItem,cProd,cEAN,xProd,NCM,CFOP,uCom,qCom,vUnCom,vProd,uTrib,qTrib,vUnTrib,orig,CST,pICMS,vICMS,pIPI,vIPI,pPIS,vPIS,pCOFINS,vCOFINS)
    SELECT
      @cd_nfe_nota,
      D.N.value('@nItem','int')                                                   AS nItem,
      D.N.value('(prod/cProd/text())[1]','nvarchar(60)')                           AS cProd,
      D.N.value('(prod/cEAN/text())[1]','nvarchar(20)')                            AS cEAN,
      D.N.value('(prod/xProd/text())[1]','nvarchar(200)')                          AS xProd,
      D.N.value('(prod/NCM/text())[1]','nvarchar(10)')                             AS NCM,
      D.N.value('(prod/CFOP/text())[1]','nvarchar(10)')                            AS CFOP,
      D.N.value('(prod/uCom/text())[1]','nvarchar(6)')                             AS uCom,
      D.N.value('(prod/qCom/text())[1]','decimal(18,6)')                           AS qCom,
      D.N.value('(prod/vUnCom/text())[1]','decimal(18,6)')                         AS vUnCom,
      D.N.value('(prod/vProd/text())[1]','decimal(18,2)')                          AS vProd,
      D.N.value('(prod/uTrib/text())[1]','nvarchar(6)')                            AS uTrib,
      D.N.value('(prod/qTrib/text())[1]','decimal(18,6)')                          AS qTrib,
      D.N.value('(prod/vUnTrib/text())[1]','decimal(18,6)')                        AS vUnTrib,
      D.N.value('(imposto/ICMS/*/orig/text())[1]','int')                           AS orig,
      COALESCE(
        D.N.value('(imposto/ICMS/*/CST/text())[1]','nvarchar(3)'),
        D.N.value('(imposto/ICMS/*/CSOSN/text())[1]','nvarchar(3)')
      )                                                                            AS CST,
      D.N.value('(imposto/ICMS/*/pICMS/text())[1]','decimal(18,4)')                AS pICMS,
      D.N.value('(imposto/ICMS/*/vICMS/text())[1]','decimal(18,2)')                AS vICMS,
      D.N.value('(imposto/IPI/*/pIPI/text())[1]','decimal(18,4)')                  AS pIPI,
      D.N.value('(imposto/IPI/*/vIPI/text())[1]','decimal(18,2)')                  AS vIPI,
      D.N.value('(imposto/PIS/*/pPIS/text())[1]','decimal(18,4)')                  AS pPIS,
      D.N.value('(imposto/PIS/*/vPIS/text())[1]','decimal(18,2)')                  AS vPIS,
      D.N.value('(imposto/COFINS/*/pCOFINS/text())[1]','decimal(18,4)')            AS pCOFINS,
      D.N.value('(imposto/COFINS/*/vCOFINS/text())[1]','decimal(18,2)')            AS vCOFINS
    FROM @x.nodes(CASE WHEN @temProc=1
                       THEN '/nfeProc/NFe/infNFe/det'
                       ELSE '/NFe/infNFe/det'
                  END) AS D(N);

    -- DUPLICATAS --------------------------------------------------------------
    ;WITH XMLNAMESPACES (DEFAULT 'http://www.portalfiscal.inf.br/nfe')
    INSERT INTO dbo.nfe_dup (cd_nfe_nota, nDup, dVenc, vDup)
    SELECT
      @cd_nfe_nota,
      X.N.value('(nDup/text())[1]','nvarchar(60)'),
      TRY_CONVERT(date, X.N.value('(dVenc/text())[1]','nvarchar(10)'), 126),
      X.N.value('(vDup/text())[1]','decimal(18,2)')
    FROM @x.nodes(CASE WHEN @temProc=1
                       THEN '/nfeProc/NFe/infNFe/cobr/dup'
                       ELSE '/NFe/infNFe/cobr/dup'
                  END) AS X(N);

    -- TRANSPORTE --------------------------------------------------------------
    ;WITH XMLNAMESPACES (DEFAULT 'http://www.portalfiscal.inf.br/nfe')
    INSERT INTO dbo.nfe_transp (cd_nfe_nota, modFrete, xNome, CNPJ, CPF)
    SELECT TOP 1
      @cd_nfe_nota,
      T.N.value('(modFrete/text())[1]','int'),
      T.N.value('(transporta/xNome/text())[1]','nvarchar(120)'),
      T.N.value('(transporta/CNPJ/text())[1]','varchar(14)'),
      T.N.value('(transporta/CPF/text())[1]','varchar(11)')
    FROM @x.nodes(CASE WHEN @temProc=1
                       THEN '/nfeProc/NFe/infNFe/transp'
                       ELSE '/NFe/infNFe/transp'
                  END) AS T(N);

    SELECT cd_nfe_nota = @cd_nfe_nota; -- retorno
  END TRY
  BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@msg, 16, 1);
  END CATCH
END
GO
