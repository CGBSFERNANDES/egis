use egissql_357
go


/*

IF OBJECT_ID('DFe_Manifesto_Log','U') IS NULL
    CREATE TABLE DFe_Manifesto_Log (
      id BIGINT IDENTITY(1,1) PRIMARY KEY,
      chave_nfe CHAR(44) NOT NULL,
      tp_evento CHAR(6) NOT NULL,
      just NVARCHAR(255) NULL,
      cstat_lote INT NULL,
      cstat_evento INT NULL,
      retorno_xml XML NULL,
      criado_em DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
*/
use egissql_273
go

delete from DFe_Cursor
delete from DFe_Inbox
delete from DFe_Manifesto_Log
delete from Nota_Emitida_Empresa
delete from DFe_Comandos
delete from nota_xml
delete from NFE_Emitente
delete from NFE_Destinatario
delete from NFE_Nota
delete from NFE_Produto_Servico
delete from NFE_IPI
delete from NFE_Total_Nota
delete from NFE_Parcela
delete from nota_xml

go

--programas php
distdfe_sync_http.php
manifestar_http.php
db.php
db-producao.php

select * from DFe_Cursor
select * from DFe_Inbox
select * from DFe_Manifesto_Log
select * from Nota_Emitida_Empresa
select * from DFe_Comandos
select * from Nota_XML

update
  DFe_Cursor
  set
    ult_nsu = 1

  
select * from egisadmin.dbo.nfe_empresa

ALTER TABLE nota_xml
ALTER COLUMN ds_xml NVARCHAR(MAX);
procedures

pr_egis_config_nfe_empresa
pr_api_distdfe_manifesto

curl -X POST http://localhost:8080/distdfe_sync.php \
  -H "Content-Type: application/json" \
  -d '{"cnpj":"33092357000104"}'


  IF OBJECT_ID('.NFe_Log') IS NULL
CREATE TABLE NFe_Log (
  id INT IDENTITY PRIMARY KEY,
  ts DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
  req_id VARCHAR(16) NOT NULL,
  etapa NVARCHAR(64) NOT NULL,
  detalhe NVARCHAR(MAX) NULL
);


