--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_inutilizar_cancelamento_nfe' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_inutilizar_cancelamento_nfe

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_inutilizar_cancelamento_nfe
-------------------------------------------------------------------------------
--pr_egis_atualiza_cancelamento_nfe
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
--                   Notícias e Eventos
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_inutilizar_cancelamento_nfe
@json nvarchar(max) = ''

--with encryption


as

--drop table AleJson
--select * from AleJson
--select cast(@json as nvarchar(max))  as ale into AleJson
--select 'ok' as msg

--set @json = isnull(@json,'')

--set @json = isnull(@json,'')

--select @json


SET NOCOUNT ON;

-- 1) NÃO destrua o JSON
-- REMOVA qualquer linha como:
-- SET @json = REPLACE(@json, '\', '');

-- 2) Se vier como "string de JSON": "...."
--select @json

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
                                ' ',' '),
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

-- 4) Validação

IF ISJSON(@json) <> 1
BEGIN
    THROW 50001, 'JSON inválido em @json.', 1;
    RETURN;
END


declare @cd_empresa          int
declare @cd_parametro        int
declare @cd_documento        int = 0
declare @cd_item_documento   int
declare @cd_usuario          int 
declare @dt_hoje             datetime
declare @dt_inicial          datetime 
declare @dt_final            datetime
declare @cd_ano              int = 0
declare @cd_mes              int = 0
declare @ds_retorno          nvarchar(max) = ''
declare @ds_xml_nota         nvarchar(max) = ''
declare @cd_chave_acesso     varchar(60)   = ''
declare @ic_validada         char(1)       = 'N'
declare @dt_autorizacao      datetime 
declare @dt_auto_recebe      nvarchar(50)  = ''
declare @dt_validacao        datetime
declare @cd_protocolo_nfe    varchar(40)   = ''
declare @cd_nota_saida       int           = 0



----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
set @cd_documento      = 0
set @cd_item_documento = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano = year(getdate())
set @cd_mes = month(getdate())  

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end


--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

select                     

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]                                      as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

--select * from #json

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_documento           = valor from #json where campo = 'cd_documento'
select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @ds_retorno             = valor from #json where campo = 'ds_retorno'             
select @ds_xml_nota            = valor from #json where campo = 'ds_xml_nota'             
select @cd_chave_acesso        = valor from #json where campo = 'cd_chave_acesso'             
select @ic_validada            = valor from #json where campo = 'ic_validada'             
select @dt_auto_recebe         = valor from #json where campo = 'dt_autorizacao'  
select @dt_validacao           = valor from #json where campo = 'dt_validacao'  
select @cd_protocolo_nfe       = valor from #json where campo = 'cd_protocolo_nfe'             
select @cd_nota_saida          = valor from #json where campo = 'cd_nota_saida'

--select @cd_protocolo_nfe

-------------------------------------------------------------------------------------------------------------------------------------
--  select 'passo i ' , @ds_xml_nota

set @ds_xml_nota = isnull(cast(@ds_xml_nota as nvarchar(max)),'')
set @cd_empresa  = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()


set @cd_documento = ISNULL(@cd_documento,0)

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    

set @cd_parametro = ISNULL(@cd_parametro,0)


    DECLARE @t TABLE (chave NVARCHAR(200), valor NVARCHAR(MAX));

    IF (ISJSON(@json) <> 1)
    BEGIN
        RAISERROR('JSON inválido',16,1);
        RETURN;
    END

    -- Assume lista [{"campo":valor}, ...]
    INSERT INTO @t(chave, valor)
    SELECT k.[key], k.[value]
    FROM OPENJSON(@json) j
    CROSS APPLY OPENJSON(j.[value]) k;

    DECLARE
      @chave NVARCHAR(44),
      @sequencia INT,
      @correcao NVARCHAR(MAX),
      @protocolo NVARCHAR(50),
      @dh_evento NVARCHAR(40),
      @cStat NVARCHAR(10),
      @xMotivo NVARCHAR(255),
      @ds_xml_evento NVARCHAR(MAX),
      @ic_processado CHAR(1);

    SELECT
      @chave      = (SELECT valor FROM @t WHERE chave='chave'),
      @sequencia  = TRY_CONVERT(INT,(SELECT valor FROM @t WHERE chave='sequencia')),
      @correcao   = (SELECT valor FROM @t WHERE chave='correcao'),
      @protocolo  = (SELECT valor FROM @t WHERE chave='protocolo'),
      @dh_evento  = (SELECT valor FROM @t WHERE chave='dh_evento'),
      @cStat      = (SELECT valor FROM @t WHERE chave='cStat'),
      @xMotivo    = (SELECT valor FROM @t WHERE chave='xMotivo'),
      @ds_xml_evento = (SELECT valor FROM @t WHERE chave='ds_xml_evento'),
      @ic_processado = (SELECT valor FROM @t WHERE chave='ic_processado');

    DECLARE @dt_evento DATETIME2(0) = TRY_CONVERT(DATETIME2(0), @dh_evento, 126);

    IF @chave IS NULL OR LEN(@chave)<>44
    BEGIN
      RAISERROR('Chave de acesso inválida',16,1);
      RETURN;
    END

    IF EXISTS (
      SELECT 1 FROM dbo.nota_carta_correcao WITH (UPDLOCK,HOLDLOCK)
      WHERE chave=@chave AND sequencia=@sequencia
    )
    BEGIN
      UPDATE dbo.nota_carta_correcao
        SET correcao=@correcao,
            protocolo=@protocolo,
            dh_evento=@dt_evento,
            cStat=@cStat,
            xMotivo=@xMotivo,
            ds_xml_evento=@ds_xml_evento,
            ic_processado=@ic_processado,
            dt_usuario_inclusao=SYSDATETIME()
      WHERE chave=@chave AND sequencia=@sequencia;
    END
    ELSE
    BEGIN
      INSERT INTO dbo.nota_carta_correcao
        (chave, sequencia, correcao, protocolo, dh_evento,
         cStat, xMotivo, ds_xml_evento, ic_processado, dt_usuario_inclusao)
      VALUES
        (@chave, @sequencia, @correcao, @protocolo, @dt_evento,
         @cStat, @xMotivo, @ds_xml_evento, @ic_processado, SYSDATETIME());
    END

    SELECT 1 AS ok, 'Carta de correção registrada/atualizada' AS mensagem;
END
GO

--use egissql_345
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_inutilizar_nfe
------------------------------------------------------------------------------
go


--CREATE TABLE dbo.nota_carta_correcao(
--  id_cc INT IDENTITY PRIMARY KEY,
--  chave CHAR(44) NOT NULL,
--  sequencia INT NOT NULL,
--  correcao NVARCHAR(MAX) NOT NULL,
--  protocolo NVARCHAR(50) NULL,
--  dh_evento DATETIME2(0) NULL,
--  cStat NVARCHAR(10) NULL,
--  xMotivo NVARCHAR(255) NULL,
--  ds_xml_evento NVARCHAR(MAX) NULL,
--  ic_processado CHAR(1) NOT NULL DEFAULT 'N',
--  dt_usuario_inclusao DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
--  CONSTRAINT UQ_cc UNIQUE (chave, sequencia)
--);


--exec pr_egis_inutilizar_nfe 

go

------------------------------------------------------------------------------
GO


--CREATE TABLE dbo.nota_inutilizacao(
--  id_inut           INT IDENTITY PRIMARY KEY,
--  cnpj_emitente     CHAR(14) NOT NULL,
--  ano               INT NOT NULL,
--  modelo            INT NOT NULL,
--  serie             INT NOT NULL,
--  numero_inicial    INT NOT NULL,
--  numero_final      INT
