--BANCO DA EMPRESA/CLIENTE
--use EGISSQL_355

IF OBJECT_ID(N'dbo.pr_egis_motor_processo_modulo', N'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_motor_processo_modulo;
GO


-------------------------------------------------------------------------------
--sp_helptext  pr_egis_motor_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_motor_processo_modulo
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

CREATE PROCEDURE pr_egis_motor_processo_modulo
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
declare @ds_prompt            nvarchar(max) = ''


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
select @ds_prompt              = valor from #json where campo = 'ds_prompt'

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
set @ds_prompt            = isnull(@ds_prompt,'')

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

--select * from tipo_destinatario

----------------------------------------------------------------------------------------------------


if @cd_parametro = 1
begin
  --select @cd_empresa
  select
    m.*,
    r.nm_rota,
    r.nm_identificacao_rota,
    r.nm_caminho_componente,
    r.nm_layout_componente
  from
    egisadmin.dbo.menu m
    inner join egisadmin.dbo.api_rota r on r.cd_rota = m.cd_rota
    --select * from egisadmin.dbo.api_rota

  where
    m.nm_menu_titulo like '%'+@ds_prompt+'%'
    and
    isnull(m.cd_rota,0)>0

  
    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
  return

end

if @cd_parametro = 10
begin
  select * from egisadmin.dbo.egis_motor_sugestao
  order by
    nm_sugestao
  
    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
 return

end

--Sugestões para utilizadas pelo Usuário------------------------------

if @cd_parametro = 50
begin
  --select * from egisadmin.dbo.egis_motor_sugestao

  select 
    u.cd_usuario,
    u.nm_fantasia_usuario,
    u.nm_usuario,
    s.cd_sugestao,
    s.nm_sugestao,
    s.ds_sugestao

  from
    egisadmin.dbo.Sugestao_Egis_Usuario us 
    inner join egisadmin.dbo.egis_motor_sugestao s on s.cd_sugestao = us.cd_sugestao
    inner join egisadmin.dbo.usuario u             on u.cd_usuario  = us.cd_usuario

  where
    u.cd_usuario = @cd_usuario

  -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
  return

end

----------------------------------------------------------------------------------------------------
if @cd_parametro in ( 100, 101, 102, 103 )
begin
  select 'R$ 1000,00' as vendas

-- Status padronizado (sempre o ÚLTIMO resultset antes de sair)  
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
  return

end

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
--exec  dbo.pr_egis_motor_processo_modulo
------------------------------------------------------------------------------
--use egissql
--go
--use egissql


--select * from egisadmin.dbo.usuario

use egissql
go
--exec  dbo.pr_egis_motor_processo_modulo '[{"cd_parametro": 0 }]' 
exec  dbo.pr_egis_motor_processo_modulo '[{"cd_parametro": 1,"ds_prompt":"diário vendas" }]'
go
--exec  dbo.pr_egis_motor_processo_modulo '[{"cd_parametro": 10, "cd_usuario": 113 }]' 


exec  dbo.pr_egis_motor_processo_modulo '[{"cd_parametro": 50, "cd_usuario": 113 }]' 
go
