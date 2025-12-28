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


    ------------------------------------------------------------
    -- Normalização do JSON (aceita [{"campo":valor}, ...] ou [["campo",valor], ...])
    ------------------------------------------------------------
    DECLARE @t TABLE (chave NVARCHAR(200), valor NVARCHAR(MAX));

    IF (ISJSON(@json) <> 1)
    BEGIN
        RAISERROR('JSON inválido', 16, 1);
        RETURN;
    END;

    -- Tenta formato objeto por item
    BEGIN TRY
        INSERT INTO @t(chave, valor)
        SELECT k.[key], k.[value]
        FROM OPENJSON(@json) AS j
        CROSS APPLY OPENJSON(j.[value]) AS k
        WHERE k.[key] IS NOT NULL;
    END TRY BEGIN CATCH END CATCH;

    -- Se vazio, tenta lista de pares
    IF NOT EXISTS (SELECT 1 FROM @t)
    BEGIN
        INSERT INTO @t(chave, valor)
        SELECT j.[value] AS chave,
               j2.[value] AS valor
        FROM OPENJSON(@json) WITH ([value] NVARCHAR(MAX) AS JSON) AS p
        CROSS APPLY OPENJSON(p.[value]) WITH ([value] NVARCHAR(MAX) '$[0]') AS j
        CROSS APPLY OPENJSON(p.[value]) WITH ([value] NVARCHAR(MAX) '$[1]') AS j2
        WHERE j.[value] IS NOT NULL;
    END

    ------------------------------------------------------------
    -- Extrai campos
    ------------------------------------------------------------
    DECLARE
        @cnpj_emitente      NVARCHAR(14),
        @ano_s              NVARCHAR(4),
        @modelo_s           NVARCHAR(2),
        @serie_s            NVARCHAR(10),
        @numero_inicial_s   NVARCHAR(20),
        @numero_final_s     NVARCHAR(20),
        @justificativa      NVARCHAR(255),
        @cd_protocolo_inut  NVARCHAR(50),
        @dt_inutilizacao_s  NVARCHAR(40),
        @cStat              NVARCHAR(10),
        @xMotivo            NVARCHAR(255),
        @ds_xml_evento      NVARCHAR(MAX),
        @ic_inutilizada     CHAR(1);

    SELECT @cnpj_emitente     = (SELECT valor FROM @t WHERE chave='cnpj_emitente'),
           @ano_s             = (SELECT valor FROM @t WHERE chave='ano'),
           @modelo_s          = (SELECT valor FROM @t WHERE chave='modelo'),
           @serie_s           = (SELECT valor FROM @t WHERE chave='serie'),
           @numero_inicial_s  = (SELECT valor FROM @t WHERE chave='numero_inicial'),
           @numero_final_s    = (SELECT valor FROM @t WHERE chave='numero_final'),
           @justificativa     = (SELECT valor FROM @t WHERE chave='justificativa'),
           @cd_protocolo_inut = (SELECT valor FROM @t WHERE chave='cd_protocolo_inut'),
           @dt_inutilizacao_s = (SELECT valor FROM @t WHERE chave='dt_inutilizacao'),
           @cStat             = (SELECT valor FROM @t WHERE chave='cStat'),
           @xMotivo           = (SELECT valor FROM @t WHERE chave='xMotivo'),
           @ds_xml_evento     = (SELECT valor FROM @t WHERE chave='ds_xml_evento'),
           @ic_inutilizada    = COALESCE((SELECT valor FROM @t WHERE chave='ic_inutilizada'),'N');

    -- Conversões numéricas
    DECLARE
        @ano INT = TRY_CONVERT(INT, @ano_s),
        @modelo INT = TRY_CONVERT(INT, @modelo_s),
        @serie INT = TRY_CONVERT(INT, @serie_s),
        @numero_inicial INT = TRY_CONVERT(INT, @numero_inicial_s),
        @numero_final   INT = TRY_CONVERT(INT, @numero_final_s);

    -- Data/hora ISO-8601
    DECLARE @dt_inutilizacao DATETIME2(0) = TRY_CONVERT(DATETIME2(0), @dt_inutilizacao_s, 126);

    IF (@cnpj_emitente IS NULL OR LEN(@cnpj_emitente)<>14)
    BEGIN
        RAISERROR('cnpj_emitente ausente/ inválido', 16, 1); RETURN;
    END
    IF (@ano IS NULL OR @modelo IS NULL OR @serie IS NULL OR @numero_inicial IS NULL OR @numero_final IS NULL)
    BEGIN
        RAISERROR('Parâmetros de intervalo/identificação inválidos', 16, 1); RETURN;
    END

    ------------------------------------------------------------
    -- ATENÇÃO: ajuste o nome da sua tabela de controle de inutilizações.
    -- Exemplo sugerido: dbo.nota_inutilizacao (crie se não existir) com colunas:
    -- (cnpj_emitente, ano, modelo, serie, numero_inicial, numero_final,
    --  justificativa, cd_protocolo_inut, dt_inutilizacao, cStat, xMotivo,
    --  ds_xml_evento, ic_inutilizada, dt_usuario_inclusao)
    ------------------------------------------------------------

    IF EXISTS (
        SELECT 1
        FROM dbo.nota_inutilizacao WITH (UPDLOCK, HOLDLOCK)
        WHERE cnpj_emitente=@cnpj_emitente
          AND ano=@ano
          AND modelo=@modelo
          AND serie=@serie
          AND numero_inicial=@numero_inicial
          AND numero_final=@numero_final
    )
    BEGIN
        UPDATE dbo.nota_inutilizacao
           SET justificativa      = @justificativa,
               cd_protocolo_inut  = NULLIF(@cd_protocolo_inut,''),
               dt_inutilizacao    = @dt_inutilizacao,
               cStat              = @cStat,
               xMotivo            = @xMotivo,
               ds_xml_evento      = @ds_xml_evento,
               ic_inutilizada     = @ic_inutilizada,
               dt_usuario_inclusao= SYSDATETIME()
         WHERE cnpj_emitente=@cnpj_emitente
           AND ano=@ano
           AND modelo=@modelo
           AND serie=@serie
           AND numero_inicial=@numero_inicial
           AND numero_final=@numero_final;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.nota_inutilizacao
            (cnpj_emitente, ano, modelo, serie, numero_inicial, numero_final,
             justificativa, cd_protocolo_inut, dt_inutilizacao, cStat, xMotivo,
             ds_xml_evento, ic_inutilizada, dt_usuario_inclusao)
        VALUES
            (@cnpj_emitente, @ano, @modelo, @serie, @numero_inicial, @numero_final,
             @justificativa, NULLIF(@cd_protocolo_inut,''), @dt_inutilizacao, @cStat, @xMotivo,
             @ds_xml_evento, @ic_inutilizada, SYSDATETIME());
    END

    SELECT 1 AS ok, 'Inutilização registrada/atualizada' AS mensagem;

GO

--use egissql_345
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_inutilizar_nfe
------------------------------------------------------------------------------
go


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
