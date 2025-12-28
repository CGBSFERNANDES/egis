--INSERT INTO egisadmin.dbo.Empresa_API
--  (cd_empresa, nm_cliente, nm_banco_empresa, api_key_hash, escopos_json, rate_limit, ip_whitelist, ativo)
--VALUES
--  (@cd_empresa, @nm_cliente, @nm_banco_empresa, @api_key_hash_hex,
--   N'{
--      "procedures": ["pr_egis_exportacao_dados"],
--      "modelos": ["FATURAMENTO_MENSAL","CLIENTES"]
--     }',
--   60, NULL, 1);


--   --b1STKnVzCXiNPWDUuYm3lpmU2O1F6-InP81YAeU7T0o

--   use egisadmin
--   go


   DECLARE @cd_empresa INT = 273;
--DECLARE @nm_cliente NVARCHAR(120) = N'Cliente XYZ';
--DECLARE @nm_banco_empresa NVARCHAR(120) = N'EMPRESA123';

--DECLARE @api_key_plain NVARCHAR(200) = N'b1STKnVzCXiNPWDUuYm3lpmU2O1F6-InP81YAeU7T0o';
DECLARE @api_key_plain NVARCHAR(200) = N'b1STKnVzCXiNPWDUuYm3lpmU2O1F6-InP81YAeU7T0o';

DECLARE @api_key_hash_hex CHAR(64) =
  UPPER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @api_key_plain), 2));

--INSERT INTO egisadmin.api_cliente
--  (cd_empresa, nm_cliente, nm_banco_empresa, api_key_hash, escopos_json, rate_limit, ip_whitelist, ativo)
--VALUES
--  (@cd_empresa, @nm_cliente, @nm_banco_empresa, @api_key_hash_hex,
--   N'{"procedures":["pr_egis_exportacao_dados"],"modelos":["FATURAMENTO_MENSAL","CLIENTES"]}',
--   60, NULL, 1);

--select * from empresa_api
--select nm_banco_empresa from empresa


   select @api_key_hash_hex as api_key_hash_hex

   update
     empresa_api
     set
       api_key_plain = @api_key_plain,
       api_key_hash = @api_key_hash_hex,
       escopos_json = N'{"procedures":["pr_egis_exportacao_dados"],"modelos":["FATURAMENTO_MENSAL","CLIENTES_ATIVOS"]}'


       where
         cd_empresa = 360

         --select * from empresa_api


         return

--         CREATE OR ALTER PROCEDURE egisadmin.sp_api_cliente_criar
--  @cd_empresa       INT,
--  @nm_cliente       NVARCHAR(120),
--  @nm_banco_empresa NVARCHAR(120),
--  @api_key_plain    NVARCHAR(200),
--  @escopos_json     NVARCHAR(MAX),
--  @rate_limit       INT = 60,
--  @ip_whitelist     NVARCHAR(500) = NULL
--AS
--BEGIN
--  SET NOCOUNT ON;

--  IF ISJSON(@escopos_json) <> 1
--    THROW 50001, 'escopos_json inválido (não é JSON).', 1;

--  DECLARE @hash_hex CHAR(64) =
--    UPPER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @api_key_plain), 2));

--  INSERT INTO egisadmin.api_cliente
--    (cd_empresa, nm_cliente, nm_banco_empresa, api_key_hash, escopos_json, rate_limit, ip_whitelist, ativo)
--  VALUES
--    (@cd_empresa, @nm_cliente, @nm_banco_empresa, @hash_hex, @escopos_json, @rate_limit, @ip_whitelist, 1);

--  SELECT SCOPE_IDENTITY() AS id, @hash_hex AS api_key_hash;
--END



--IF OBJECT_ID('egisadmin.api_audit') IS NULL
--BEGIN
--  CREATE TABLE egisadmin.api_audit (
--    id            BIGINT IDENTITY(1,1) PRIMARY KEY,
--    dt_evento     DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
--    cliente_id    INT          NOT NULL,
--    cd_empresa    INT          NOT NULL,
--    endpoint      NVARCHAR(120) NOT NULL,   -- "/exec/pr_egis_exportacao_dados"
--    procedure     NVARCHAR(200) NULL,
--    ip_origem     NVARCHAR(100) NOT NULL,
--    http_status   INT          NOT NULL,
--    tempo_ms      INT          NOT NULL,
--    trace_id      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
--    payload_resumo NVARCHAR(1000) NULL      -- ex.: params principais (sem dados sensíveis)
--  );
--  CREATE INDEX IX_api_audit_dt       ON egisadmin.api_audit(dt_evento DESC);
--  CREATE INDEX IX_api_audit_cliente  ON egisadmin.api_audit(cliente_id, dt_evento DESC);
--END
