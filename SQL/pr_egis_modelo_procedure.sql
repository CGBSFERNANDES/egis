--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_modelo_procedure' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_modelo_procedure

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_modelo_procedure','P') IS NOT NULL
    DROP PROCEDURE pr_egis_modelo_procedure;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_modelo_procedure
-------------------------------------------------------------------------------
-- pr_egis_modelo_procedure
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
create procedure  pr_egis_modelo_procedure
------------------------

@json nvarchar(max) = '' --Parametro de entrada
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

--Declaração das variaveis que seram utlizadas no procedimento (calculo, consulta, update, delete,insert,etc...)

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
declare @cd_tabela           int = 0 
declare @nm_atributo         varchar(80)
declare @nm_menu              varchar(120)

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


--Montagem da tabela temporaria que vai receber o json e vai configurar cada variavel de entrada

select                     
 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json)root  --Comando que transforma o string json em uma tabela                   
   cross apply openjson(root.value) as valores      
   -- Para debug os parametros de entrada, descomentar o código abaixo
   --select * from #json 
   --return


--------------------------------------------------------------------------------------------
-- Definição da variavel de trabalho com o valor do atributo da tabela #json

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo'   
select @cd_tabela              = valor from #json where campo = 'cd_tabela'
select @nm_atributo            = valor from #json where campo = 'nm_atributo'
select @nm_menu				   = valor from #json where campo = 'nm_menu'
--select @flamengo   as final_libertadores          
--return
--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro = ISNULL(@cd_parametro,0)
set @cd_modelo    = isnull(@cd_modelo,0)
set @cd_tabela    = isnull(@cd_tabela,0)
set @nm_atributo  = isnull(@nm_atributo,0)
--Teste de execução para validar 


IF ISNULL(@cd_parametro,0) = 0
BEGIN
  select 
    'Sucesso' as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final,
	 @cd_usuario  as cd_usuario


  RETURN;

END
   
if isnull(@cd_parametro,0) = 1
begin
	select * from egisadmin.dbo.tabela where cd_tabela = case when @cd_tabela = 0 then cd_tabela else @cd_tabela end
	return
end

if isnull(@cd_parametro,0) = 2
begin
	select 
		t.nm_tabela,t.cd_tabela, a.nm_atributo,a.nm_atributo_consulta 
	from egisadmin.dbo.atributo a
	  inner join egisadmin.dbo.tabela t on t.cd_tabela = a.cd_tabela
	 where a.nm_atributo like '%' + @nm_atributo + '%'   --cd_tabela = case when @cd_tabela = 0 then cd_tabela else @cd_tabela end
	 order by 
	 t.nm_tabela,a.nm_atributo
	return
end


if isnull(@cd_parametro,0) = 3
begin
	select 
		m.cd_menu,
		m.nm_menu,
		m.nm_menu_titulo,
		m.cd_api,
		m.cd_rota,
		t.nm_tabela,
		t.cd_tabela
	from egisadmin.dbo.menu m
	left outer join egisadmin.dbo.Menu_Tabela mt on mt.cd_menu = m.cd_menu
	left outer join egisadmin.dbo.tabela t on t.cd_tabela = mt.cd_tabela
	 where m.nm_menu like '%' + @nm_menu + '%'   --cd_tabela = case when @cd_tabela = 0 then cd_tabela else @cd_tabela end
	 order by 
	 m.nm_menu
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



------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_modelo_procedure
------------------------------------------------------------------------------

--sp_helptext pr_egis_modelo_procedure

go
/*
exec  pr_egis_modelo_procedure '[{"cd_parametro": 0, "dt_inicial": "12/25/2025", "flamengo":"3x0"}]'
exec  pr_egis_modelo_procedure '[{"cd_parametro": 1, "cd_modelo": 1}]'                                   
*/
go
--exec  pr_egis_modelo_procedure '[{"cd_parametro": 0, "dt_inicial": "12/25/2025", "flamengo":"3x0","flamengo":"1x0"}]'
--exec  pr_egis_modelo_procedure '[{"cd_parametro": 1, "cd_modelo": 1, "cd_tabela": 1200}]' 
--exec  pr_egis_modelo_procedure '[{"cd_parametro": 2, "cd_modelo": 1, "nm_atributo": "categoria"}]' 
--exec  pr_egis_modelo_procedure '[{"cd_parametro": 3, "cd_modelo": 1, "nm_menu": "motorista"}]' 
------------------------------------------------------------------------------
GO
