--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355
use egissql
go

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_IA_modelo_procedure' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_IA_modelo_procedure

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_IA_modelo_procedure','P') IS NOT NULL
    DROP PROCEDURE pr_egis_IA_modelo_procedure;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_IA_modelo_procedure
-------------------------------------------------------------------------------
-- pr_egis_IA_modelo_procedure
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
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_IA_modelo_procedure
------------------------
@json nvarchar(max) = ''
------------------------------------------------------------------------------
--with encryption


as

-- ver nível atual
--SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME();

-- se < 130, ajustar:
--ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130;

--return

--set @json = isnull(@json,'')

 SET NOCOUNT ON;
 SET XACT_ABORT ON;

 BEGIN TRY
 
 /* 1) Validar payload - parameros de Entrada da Procedure */
 IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

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
declare @cd_modelo           int = 0
declare @pergunta            nvarchar(max) = ''
declare @nm_banco_empresa    varchar(80) = ''
declare @cd_fila             int = 0


----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
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

 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
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
select @pergunta               = valor from #json where campo = 'pergunta'        
select @cd_fila                = valor from #json where campo = 'cd_fila'

--------------------------------------------------------------------------------------
--select * from Fila_EgisIA

set @cd_empresa = ISNULL(@cd_empresa,0)
set @cd_usuario = isnull(@cd_usuario,1)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()


select
  @nm_banco_empresa = isnull(nm_banco_empresa,'')
from
  egisadmin.dbo.empresa
where
  cd_empresa = @cd_empresa

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro = ISNULL(@cd_parametro,0)


IF ISNULL(@cd_parametro,0) = 0
BEGIN
  select 
    'Sucesso' as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final


  RETURN;

END

--Atualização da Tabela de Fila de Perguntas para egisIA --

if @cd_parametro = 1
begin
  --select * from egisadmin.dbo.Fila_EgisIA

  insert into egisadmin.dbo.Fila_EgisIA (
        nm_banco_empresa,
        cd_empresa,
        cd_usuario,
        pergunta,
        nm_status,
        dt_criacao
    )
    values (
        db_name(),       -- ou @nm_banco_empresa, se você já estiver usando isso no JSON
        @cd_empresa,
        @cd_usuario,
        @pergunta,
        'PENDENTE',
        getdate()
    )

    -- pega o ID recém inserido
    set @cd_fila = scope_identity()

    select 
        'Incluído na fila da Egis IA' as Msg,
        @cd_fila as cd_fila,
        @cd_empresa as cd_empresa,
        @cd_usuario as cd_usuario,
        @pergunta as pergunta

    return

end

if @cd_parametro = 2
begin
    select top 1
        f.cd_fila,
        f.cd_empresa,
        f.cd_usuario,
        f.pergunta,
        f.resposta,
        f.nm_status,
        f.dt_criacao,
        f.dt_processado
    from egisadmin.dbo.Fila_EgisIA f
    where f.cd_fila = @cd_fila

    return
end


--Lista histórico de perguntas/respostas por empresa --

IF @cd_parametro = 3
BEGIN

    SELECT
        f.cd_fila,
        f.nm_banco_empresa,
        f.cd_empresa,
        f.cd_usuario,
        f.pergunta,
        f.resposta,
        f.nm_status,
        f.dt_criacao,
        f.dt_processado
    FROM egisadmin.dbo.Fila_EgisIA f
    WHERE f.cd_empresa = @cd_empresa
    and
    f.cd_fila = case when @cd_fila = 0 then f.cd_fila else @cd_fila end
    ORDER BY f.cd_fila DESC;

    RETURN;

END



if @cd_parametro = 100
begin

  INSERT INTO Fila_EgisIA (nm_banco_empresa, cd_empresa, cd_usuario, pergunta)
  VALUES (@nm_banco_empresa, @cd_empresa, @cd_usuario, @pergunta);
  return

end

    
/* Padrão se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ação mapeada para cd_parametro=', @cd_parametro) AS Msg;
   
 END TRY
    BEGIN CATCH
        DECLARE
            @errnum   INT          = ERROR_NUMBER(),
            @errmsg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @errproc  NVARCHAR(128) = ERROR_PROCEDURE(),
            @errline  INT          = ERROR_LINE(),
            @fullmsg  NVARCHAR(2048);



         -- Monta a mensagem (THROW aceita até 2048 chars no 2º parâmetro)
    SET @fullmsg =
          N'Erro em pr_egis_modelo_procedure ('
        + ISNULL(@errproc, N'SemProcedure') + N':'
        + CONVERT(NVARCHAR(10), @errline)
        + N') #' + CONVERT(NVARCHAR(10), @errnum)
        + N' - ' + ISNULL(@errmsg, N'');

    -- Garante o limite do THROW
    SET @fullmsg = LEFT(@fullmsg, 2048);

    -- Relança com contexto (state 1..255)
    THROW 50000, @fullmsg, 1;

        -- Relança erro com contexto
        --THROW 50000, CONCAT('Erro em pr_egis_modelo_procedure (',
        --                    ISNULL(@errproc, 'SemProcedure'), ':',
        --                    @errline, ') #', @errnum, ' - ', @errmsg), 1;
    END CATCH

---------------------------------------------------------------------------------------------------------------------------------------------------------    
go


--select * from Fila_EgisIA

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_IA_modelo_procedure
------------------------------------------------------------------------------
--delete Fila_EgisIA
--SELECT * FROM EGISADMIN.DBO.Fila_EgisIA
----UPDATE EGISADMIN.DBO.Fila_EgisIA SET NM_STATUS = 'PENDENTE'


--insert into egisadmin.dbo.Fila_EgisIA 
--select 
--nm_banco_empresa,
--cd_empresa,
--cd_usuario,
--pergunta,
--resposta,
--nm_status,
--dt_criacao,
--dt_processado
--from Fila_EgisIA

--sp_helptext pr_egis_modelo_procedure

go
/*
exec  pr_egis_IA_modelo_procedure '[{"cd_parametro": 0}]'
exec  pr_egis_IA_modelo_procedure '[{"cd_parametro": 1, "cd_modelo": 1}]' 
exec  pr_egis_IA_modelo_procedure '[{"cd_parametro": 2, "cd_fila": 8}]'    
exec  pr_egis_IA_modelo_procedure '[{"cd_parametro": 3, "cd_modelo": 1}]'    
*/
go
------------------------------------------------------------------------------
GO
