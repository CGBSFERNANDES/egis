--BANCO DA EMPRESA/CLIENTE
--use EGISSQL_355

IF OBJECT_ID(N'dbo.pr_egis_nota_servico_processo', N'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_nota_servico_processo;
GO


-------------------------------------------------------------------------------
--sp_helptext  pr_egis_nota_servico_processo
-------------------------------------------------------------------------------
-- pr_egis_nota_servico_processo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Egis
--                   Modelo de Procedure com Processos
--
--Data             : 20.12.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE pr_egis_nota_servico_processo
------------------------
@json nvarchar(max) = ''
------------------------------------------------------------------------------
--with encryption


as

-- ver nvel atual
--SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME();

-- se < 130, ajustar:
--ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130;

--return

--set @json = isnull(@json,'')

 SET NOCOUNT ON;
 SET XACT_ABORT ON;
 
    DECLARE @__sucesso BIT = 0;
    DECLARE @__codigo  INT = 0;
    DECLARE @__mensagem NVARCHAR(4000) = N'OK';
 

 BEGIN TRY
 
 /* 1) Validar payload - parameros de Entrada da Procedure */
 IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON invlido ou vazio em @json.', 1;

 /* 2) Normalizar: aceitar array[0] ou objeto */
 IF JSON_VALUE(@json, '$[0]') IS NOT NULL
            SET @json = JSON_QUERY(@json, '$[0]'); -- pega o primeiro elemento


set @json = replace(
             replace(
               replace(
                replace(
                  replace(
                    replace(
                      replace(
                        replace(
                          replace(
                            replace(
                              replace(
                                replace(
                                  replace(
                                    replace(
                                    @json, CHAR(13), ' '),
                                  CHAR(10),' '),
                                '',' '),
                              ':\\\"',':\\"'),
                            '\\\";','\\";'),
                          ':\\"',':\\\"'),
                        '\\";','\\\";'),
                      '\\"','\"'),
                    '\"', '"'),
                  '',''),
                '["','['),
              '"[','['),
             ']"',']'),
          '"]',']') 


declare @cd_empresa           int
declare @cd_parametro         int
declare @cd_documento         int = 0
declare @cd_item_documento    int
declare @cd_usuario           int 
declare @dt_hoje              datetime
declare @dt_inicial           datetime 
declare @dt_final             datetime
declare @cd_ano               int = 0
declare @cd_mes               int = 0
declare @cd_modelo            int = 0
declare @cd_grupo_usuario     int = 0
declare @qt_contrato_empresa  int = 0
declare @cd_modulo            int = 0

--select * from egisadmin.dbo.empresa

----------------------------------------------------------------------------------------------------------------

declare @dados_registro           nvarchar(max) = ''
declare @dados_modal              nvarchar(max) = ''
----------------------------------------------------------------------------------------------------------------

set @cd_empresa          = 0
set @cd_parametro        = 0
set @dt_hoje             = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano              = year(getdate())
set @cd_mes              = month(getdate())  
set @qt_contrato_empresa = 0

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end

--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

select                     

 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

--------------------------------------------------------------------------------------------

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo' 
select @cd_grupo_usuario       = valor from #json where campo = 'cd_grupo_usuario'
select @cd_modulo              = valor from #json where campo = 'cd_modulo'
---------------------------------------------------------------------------------------------
select @dados_registro         = valor from #json where campo = 'dados_registro'
select @dados_modal            = valor from #json where campo = 'dados_modal'

--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro         = ISNULL(@cd_parametro,0)
set @cd_usuario           = isnull(@cd_usuario,0)
set @cd_grupo_usuario     = isnull(@cd_grupo_usuario,0)
set @cd_modulo            = isnull(@cd_modulo,0)


---------------------------------------------------------------------------------------------------------------------------------------------------------    


IF ISNULL(@cd_parametro,0) = 0
BEGIN

  select 
    'Sucesso'     as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final,
     @cd_usuario  AS cd_usuario


 
    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
  RETURN;

END


if @cd_parametro = 1
begin
 
    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
  return

end

--NFSE

if @cd_parametro = 10
begin


     -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 

  return

end

--CTe

if @cd_parametro = 20
begin


     -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 

  return

end


if @cd_parametro = 900
begin
 
   /*
   DECLARE @cd_nfse_xml INT = TRY_CONVERT(INT, JSON_VALUE(@dados_registro, '$.cd_nfse_xml'));

;WITH X AS (
  SELECT *
  FROM dbo.nfse_xml WITH(NOLOCK)
  WHERE cd_nfse_xml = @cd_nfse_xml
)
INSERT INTO dbo.nota_entrada_servico
(
  cd_fornecedor,
  cd_lei116_servico,
  cd_atividade_servico,
  nm_obs_servico,
  cd_usuario_inclusao,
  dt_usuario_inclusao,

  cd_nfse_xml,
  nr_nfse,
  cd_verificacao,
  dt_emissao,
  cnpj_prestador,
  cnpj_tomador,
  vl_servicos,
  vl_iss,
  aliq_iss,
  base_calculo,
  municipio_prestacao,
  ds_discriminacao
)
SELECT
  f.cd_fornecedor,                          -- resolver pelo CNPJ prestador
  X.item_lista_servico,
  X.cod_trib_municipio,
  LEFT(X.ds_discriminacao, 60),
  @cd_usuario,
  GETDATE(),

  X.cd_nfse_xml,
  X.nr_nfse,
  X.cd_verificacao,
  X.dt_emissao,
  X.cnpj_prestador,
  X.cnpj_tomador,
  X.vl_servicos,
  X.vl_iss,
  X.aliq_iss,
  X.base_calculo,
  X.municipio_prestacao,
  X.ds_discriminacao
FROM X
LEFT JOIN dbo.fornecedor f
  ON f.cd_cnpj = X.cnpj_prestador;  -- ajustar para o nome real do campo/tabela

   */
   -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
 return

end

IF @cd_parametro = 910
BEGIN
  -- @dados_registro tem JSON com $.nfse.*
  DECLARE @numero VARCHAR(30) = JSON_VALUE(@dados_registro, '$.nfse.numero');
  DECLARE @cnpj_prestador VARCHAR(20) = JSON_VALUE(@dados_registro, '$.nfse.prestador.cnpj');
  DECLARE @valor_servicos DECIMAL(18,2) = TRY_CONVERT(DECIMAL(18,2), JSON_VALUE(@dados_registro, '$.nfse.servico.valores.valorServicos'));
  DECLARE @discriminacao NVARCHAR(2000) = JSON_VALUE(@dados_registro, '$.nfse.servico.discriminacao');

  -- TODO: aqui entram seus INSERTs reais
  -- INSERT INTO <SuaTabelaCabecalho>(...) VALUES (...)

    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
  RETURN;
END


if @cd_parametro = 9999
begin
 
    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
  return
end

--use egissql_317
--
/* Padro se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ao mapeada para cd_parametro=', @cd_parametro) AS Msg;
   
 
    -- Status padronizado (sempre o ÚLTIMO resultset)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
 END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;

        DECLARE
            @errnum  INT = ERROR_NUMBER(),
            @errsev  INT = ERROR_SEVERITY(),
            @errsta  INT = ERROR_STATE(),
            @errline INT = ERROR_LINE(),
            @errmsg  NVARCHAR(2048) = ERROR_MESSAGE(),
            @errproc NVARCHAR(256)  = ERROR_PROCEDURE();

        SET @__sucesso = 0;
        SET @__codigo  = 500;
        SET @__mensagem =
            N'Erro em pr_egis_admin_processo_modulo ('
            + ISNULL(@errproc, N'(sem_procedure)')
            + N':' + CONVERT(NVARCHAR(10), @errline)
            + N') #' + CONVERT(NVARCHAR(10), @errnum)
            + N' - ' + ISNULL(@errmsg, N'');

        -- Status padronizado (sempre o ÚLTIMO resultset)
        SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
    END CATCH
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------    
go



------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  dbo.pr_egis_nota_servico_processo
------------------------------------------------------------------------------
--use egissql
--go
--use egissql


--select * from egisadmin.dbo.usuario


--exec  dbo.pr_egis_nota_servico_processo '[{"cd_parametro": 0 }]' 
--exec  dbo.pr_egis_nota_servico_processo '[{"cd_parametro": 1, "cd_usuario": 113 }]' 
go


IF OBJECT_ID('dbo.nfse_xml', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.nfse_xml (
      cd_nfse_xml           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
      cd_empresa            INT              NULL,
      cd_usuario_inclusao   INT              NULL,
      dt_usuario_inclusao   DATETIME         NOT NULL DEFAULT(GETDATE()),

      ds_layout             VARCHAR(30)      NOT NULL DEFAULT('GINFES'),
      ds_xml                NVARCHAR(MAX)    NOT NULL,

      -- extraídos do XML (melhor pro filtro/consulta)
      nr_nfse               VARCHAR(30)      NULL,
      cd_verificacao        VARCHAR(60)      NULL,
      dt_emissao            DATETIME         NULL,

      cnpj_prestador        VARCHAR(20)      NULL,
      cnpj_tomador          VARCHAR(20)      NULL,
      im_prestador          VARCHAR(30)      NULL,

      vl_servicos           DECIMAL(18,2)    NULL,
      vl_iss                DECIMAL(18,2)    NULL,
      vl_liquido            DECIMAL(18,2)    NULL,
      aliq_iss              DECIMAL(9,4)     NULL,
      base_calculo          DECIMAL(18,2)    NULL,

      item_lista_servico    VARCHAR(20)      NULL,
      cod_trib_municipio    VARCHAR(30)      NULL,
      municipio_prestacao   VARCHAR(10)      NULL,

      ds_discriminacao      NVARCHAR(2000)   NULL,

      hash_xml              VARBINARY(32)    NOT NULL
  );

  CREATE UNIQUE INDEX UX_nfse_xml_hash ON dbo.nfse_xml(hash_xml);
  CREATE INDEX IX_nfse_xml_dt ON dbo.nfse_xml(dt_emissao);
  CREATE INDEX IX_nfse_xml_prestador_num ON dbo.nfse_xml(cnpj_prestador, nr_nfse);
END
GO


IF OBJECT_ID('dbo.cte_xml', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.cte_xml (
      cd_cte_xml            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
      cd_empresa            INT              NULL,
      cd_usuario_inclusao   INT              NULL,
      dt_usuario_inclusao   DATETIME         NOT NULL DEFAULT(GETDATE()),

      ds_layout             VARCHAR(30)      NOT NULL DEFAULT('CTE'),
      ds_xml                NVARCHAR(MAX)    NOT NULL,

      ch_cte                VARCHAR(44)      NULL,
      nr_cte                VARCHAR(30)      NULL,
      serie                 VARCHAR(10)      NULL,
      dt_emissao            DATETIME         NULL,

      tp_cte                VARCHAR(2)       NULL,
      tp_serv               VARCHAR(2)       NULL,
      modal                 VARCHAR(5)       NULL,
      cfop                  VARCHAR(10)      NULL,

      cnpj_emit             VARCHAR(20)      NULL,
      xnome_emit            NVARCHAR(200)    NULL,

      cnpj_dest             VARCHAR(20)      NULL,
      xnome_dest            NVARCHAR(200)    NULL,

      uf_ini                VARCHAR(2)       NULL,
      uf_fim                VARCHAR(2)       NULL,
      xmun_ini              NVARCHAR(60)     NULL,
      xmun_fim              NVARCHAR(60)     NULL,

      v_tprest              DECIMAL(18,2)    NULL,
      v_rec                 DECIMAL(18,2)    NULL,

      v_carga               DECIMAL(18,2)    NULL,
      pro_pred              NVARCHAR(60)     NULL,

      hash_xml              VARBINARY(32)    NOT NULL
  );

  CREATE UNIQUE INDEX UX_cte_xml_hash ON dbo.cte_xml(hash_xml);
  CREATE INDEX IX_cte_xml_dt ON dbo.cte_xml(dt_emissao);
  CREATE INDEX IX_cte_xml_emit_dt ON dbo.cte_xml(cnpj_emit, dt_emissao);
  CREATE INDEX IX_cte_xml_ch ON dbo.cte_xml(ch_cte);
END
GO
