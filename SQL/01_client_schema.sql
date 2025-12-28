-- 01_client_schema.sql
-- Executar em CADA BANCO DO CLIENTE (não no EgisAdmin)

/* Tabela de comandos locais (fila do serviço) */
IF OBJECT_ID('dbo.DFe_Comandos','U') IS NULL
BEGIN
  CREATE TABLE dbo.DFe_Comandos(
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    tipo NVARCHAR(30) NOT NULL,        -- 'sync' | 'manifesto' | 'download'
    payload NVARCHAR(MAX) NULL,        -- JSON {chave, tipo, justificativa, cnpj...}
    status NVARCHAR(20) NOT NULL DEFAULT 'pendente',
    saida NVARCHAR(MAX) NULL,
    criado_em DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    processado_em DATETIME2 NULL
  );
  CREATE INDEX IX_DFe_Comandos_StatusTipo ON dbo.DFe_Comandos(status, tipo, id);
END
GO

/* Inbox DF-e (resumos e procNFe) */
IF OBJECT_ID('dbo.DFe_Inbox','U') IS NULL
BEGIN
  CREATE TABLE dbo.DFe_Inbox(
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    nsu BIGINT NULL,
    chave_nfe NVARCHAR(44) NOT NULL,
    tipo NVARCHAR(10) NOT NULL,             -- 'resumo' | 'proc'
    resumo_json NVARCHAR(MAX) NULL,         -- JSON do resumo
    xml_conteudo XML NULL,                  -- procNFe / nfeProc completo
    schema_xml NVARCHAR(30) NULL,           -- 'procNFe' | 'nfeProc'
    manifesto_status NVARCHAR(20) NULL,     -- ciencia|confirmacao|desconhecimento|nao_realizada
    manifesto_quando DATETIME2 NULL,
    recebido_em DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
  CREATE UNIQUE INDEX UX_DFe_Inbox_ChaveTipo ON dbo.DFe_Inbox(chave_nfe, tipo);
  CREATE INDEX IX_DFe_Inbox_PendProc ON dbo.DFe_Inbox(tipo) WHERE tipo='resumo';
END
GO

/* Garantir coluna do ERP para espelhar XML */
IF COL_LENGTH('dbo.Nota_Emitida_Empresa','ds_nota_documento') IS NULL
BEGIN
  ALTER TABLE dbo.Nota_Emitida_Empresa ADD ds_nota_documento NVARCHAR(MAX) NULL;
END
GO

ALTER TABLE dbo.Nota_Emitida_Empresa
ALTER COLUMN ds_nota_documento NVARCHAR(MAX) NULL;


-- 01_sync_client_schema.sql
-- Executar em CADA BANCO DO CLIENTE (não no EgisAdmin)
IF OBJECT_ID('dbo.DFe_Cursor','U') IS NULL
BEGIN
  CREATE TABLE dbo.DFe_Cursor (
    cnpj_base CHAR(14)   NOT NULL PRIMARY KEY,
    ult_nsu   BIGINT     NOT NULL DEFAULT(0),
    max_nsu   BIGINT     NOT NULL DEFAULT(0),
    next_allowed_utc DATETIME2 NULL,
    atualizado_em DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END
ELSE
BEGIN
  IF COL_LENGTH('dbo.DFe_Cursor','next_allowed_utc') IS NULL
    ALTER TABLE dbo.DFe_Cursor ADD next_allowed_utc DATETIME2 NULL;
END;

IF OBJECT_ID('dbo.DFe_Inbox','U') IS NULL
BEGIN
  CREATE TABLE DFe_Inbox (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    nsu BIGINT NOT NULL,
    schema_xml VARCHAR(60) NOT NULL,
    chave_nfe CHAR(44) NULL,
    tipo VARCHAR(10) NOT NULL, -- resumo|proc
    xml_conteudo XML NULL,
    resumo_json NVARCHAR(MAX) NULL,
    recebido_em DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    manifesto_status VARCHAR(20) NULL,
    manifesto_quando DATETIME2 NULL
  );
  CREATE UNIQUE INDEX UX_DFe_Inbox_Resumo ON dbo.DFe_Inbox(nsu) WHERE tipo='resumo';
  CREATE UNIQUE INDEX UX_DFe_Inbox_Proc   ON dbo.DFe_Inbox(chave_nfe) WHERE tipo='proc';
END;

