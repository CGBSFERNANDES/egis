--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_contabilidade_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_contabilidade_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_contabilidade_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_estoque_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_contabilidade_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_contabilidade_processo_modulo
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
create procedure  pr_egis_contabilidade_processo_modulo
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
declare @nm_menu             varchar(120)
declare @cd_modulo           int = 0
declare @cd_movimento        int = 0 
declare @cd_aviso_sistema    int = 0
declare @qt_resultado        int = 0
declare @vl_resultado        decimal(25,4) = 0.00
declare @pc_resultado        decimal(25,4) = 0.00
declare @nm_resultado        varchar(500)  = ''
declare @nm_complemento      varchar(500)  = ''
declare @ds_json_resultado   nvarchar(max) = ''
declare @nm_conta            varchar(60)   = ''


----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano            = year(getdate())
set @cd_mes            = month(getdate())  
set @cd_movimento      = 0

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
select @cd_modulo              = valor from #json where campo = 'cd_modulo'  
select @cd_movimento           = valor from #json where campo = 'cd_movimento'  
select @nm_conta               = valor from #json where campo = 'nm_conta' 
--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro     = ISNULL(@cd_parametro,0)
set @cd_modelo        = isnull(@cd_modelo,0)
set @cd_tabela        = isnull(@cd_tabela,0)
set @nm_atributo      = isnull(@nm_atributo,0)
set @cd_usuario       = isnull(@cd_usuario,0)
set @cd_modulo        = isnull(@cd_modulo,0)
set @nm_conta         = isnull(@nm_conta,'')

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

--Plano de Contas

if @cd_parametro = 1
begin

  --select * from plano_conta

  select
    pc.cd_conta,
    gc.nm_grupo_conta,
    pc.cd_mascara_conta,
    pc.nm_conta,
    pc.ic_tipo_conta,
    pc.ic_situacao_conta,
    pc.ic_lancamento_conta,
    pc.cd_conta_reduzido,
    pc.qt_grau_conta,
    pc.dt_cadastro_conta,
    pc.nm_obs_plano_conta,
    pc.ic_conta_analitica,
    pc.cd_empresa,
    pc.vl_saldo_inicial_conta,    
    pc.ic_saldo_inicial_conta,    
    pc.vl_debito_conta,
    pc.vl_credito_conta,
    pc.vl_saldo_atual_conta,
    pc.ic_saldo_atual_conta,
    cc.nm_centro_custo,
    pc.cd_mascara_conta_superior

  from
    plano_conta pc
    inner join Grupo_Conta gc       on gc.cd_grupo_conta = pc.cd_grupo_conta
    left outer join centro_custo cc on cc.cd_centro_custo = pc.cd_centro_custo
    
  where
    pc.nm_conta like '%' + @nm_conta +'%'

  order by
    pc.cd_mascara_conta

  return

end

if @cd_parametro = 999
begin
  
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
          N'Erro em pr_egis_contabilidade_processo_modulo ('
        + ISNULL(@errproc, N'SemProcedure') + N':'
        + CONVERT(NVARCHAR(10), @errline)
        + N') #' + CONVERT(NVARCHAR(10), @errnum)
        + N' - ' + ISNULL(@errmsg, N'');

    -- Garante o limite do THROW
    SET @fullmsg = LEFT(@fullmsg, 2048);

    -- Relança com contexto (state 1..255)
    THROW 50000, @fullmsg, 1;

        -- Relança erro com contexto
        --THROW 50000, CONCAT('Erro em pr_egis_contabilidade_processo_modulo (',
        --                    ISNULL(@errproc, 'SemProcedure'), ':',
        --                    @errline, ') #', @errnum, ' - ', @errmsg), 1;
    END CATCH

---------------------------------------------------------------------------------------------------------------------------------------------------------    
go



------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_contabilidade_processo_modulo
------------------------------------------------------------------------------
--sp_helptext pr_egis_contabilidade_processo_modulo

go
/*
exec  pr_egis_contabilidade_processo_modulo '[{"cd_parametro": 0, "cd_modelo": 1}]'                                   
exec  pr_egis_contabilidade_processo_modulo '[{"cd_parametro": 1} ]'   
exec  pr_egis_contabilidade_processo_modulo '[{"cd_parametro": 2} ]'  
exec  pr_egis_contabilidade_processo_modulo '[{"cd_parametro": 3}, {"cd_modulo": 234} ]' 
exec  pr_egis_contabilidade_processo_modulo '[{"cd_parametro": 4}, {"cd_modulo": 234}, {"cd_usuario": 1} ]' 
exec  pr_egis_contabilidade_processo_modulo '[{"cd_parametro": 100}, {"cd_modulo": 234}, {"cd_aviso_sistema": 365}, {"cd_usuario": 5056} ]' 

*/

--exec  pr_egis_contabilidade_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 4,
--        "cd_aviso_sistema": 0,
--        "cd_modulo": 234,
--        "cd_usuario": 5056
--    }
--]'

go
------------------------------------------------------------------------------
GO

--delete from aviso_movimento
--select * from aviso_movimento
