--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_supnet_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_supnet_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_supnet_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_supnet_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_supnet_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_supnet_processo_modulo
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
create procedure  pr_egis_supnet_processo_modulo
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
declare @cd_cliente          int = 0

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
select @cd_cliente             = valor from #json where campo = 'cd_cliente'        


--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

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

--Abertas---

if @cd_parametro = 1
begin

  --select * from registro_suporte where cd_cliente = 445

  select 
    md.nm_modulo,
    md.nm_fantasia_modulo,
    mn.nm_menu_titulo,
    c.nm_fantasia_cliente,
    cc.nm_contato_cliente,
    isnull(cs.nm_consultor,'')               as nm_consultor_solucao,
    ci.nm_consultor,
    ss.nm_status_suporte,
    ps.nm_prioridade_suporte,
    ns.nm_nivel_suporte,
    rs.* 
  from 
    registro_suporte rs
    inner join cliente c                                with (nolock) on c.cd_cliente             = rs.cd_cliente
    inner join cliente_contato cc                       with (nolock) on cc.cd_cliente            = rs.cd_cliente and
                                                                         cc.cd_contato            = rs.cd_contato
    left outer join egisadmin.dbo.menu mn 				with (nolock) on mn.cd_menu      	      = rs.cd_menu
	left outer join egisadmin.dbo.modulo md 			with (nolock) on md.cd_modulo   	      = rs.cd_modulo
	left outer join consultor_implantacao ci 			with (nolock) on ci.cd_consultor  	      = rs.cd_consultor
    left outer join consultor_implantacao cs 			with (nolock) on cs.cd_consultor  	      = rs.cd_consultor_solucao
	left outer join status_suporte ss					with (nolock) on ss.cd_status_suporte     = rs.cd_status_suporte
	left outer join prioridade_suporte ps               with (nolock) on ps.cd_prioridade_suporte = rs.cd_prioridade_suporte
    left outer join nivel_suporte ns		            with (nolock) on ns.cd_nivel_suporte	  = rs.cd_nivel_suporte

  where
    rs.cd_cliente = @cd_cliente
    and
    ( rs.dt_solucao_dev is null and rs.dt_atendimento_cliente is null )

  order by
    rs.dt_ocorrencia_suporte
    
  return

end


if @cd_parametro = 2
begin

  --select * from registro_suporte where cd_cliente = 445

  select 
    md.nm_modulo,
    md.nm_fantasia_modulo,
    mn.nm_menu_titulo,
    c.nm_fantasia_cliente,
    cc.nm_contato_cliente,
    isnull(cs.nm_consultor,'')               as nm_consultor_solucao,
    ci.nm_consultor,
    ss.nm_status_suporte,
    ps.nm_prioridade_suporte,
    ns.nm_nivel_suporte,
    rs.* 
  from 
    registro_suporte rs
    inner join cliente c                                with (nolock) on c.cd_cliente             = rs.cd_cliente
    inner join cliente_contato cc                       with (nolock) on cc.cd_cliente            = rs.cd_cliente and
                                                                         cc.cd_contato            = rs.cd_contato
    left outer join egisadmin.dbo.menu mn 				with (nolock) on mn.cd_menu      	      = rs.cd_menu
	left outer join egisadmin.dbo.modulo md 			with (nolock) on md.cd_modulo   	      = rs.cd_modulo
	left outer join consultor_implantacao ci 			with (nolock) on ci.cd_consultor  	      = rs.cd_consultor
    left outer join consultor_implantacao cs 			with (nolock) on cs.cd_consultor  	      = rs.cd_consultor_solucao
	left outer join status_suporte ss					with (nolock) on ss.cd_status_suporte     = rs.cd_status_suporte
	left outer join prioridade_suporte ps               with (nolock) on ps.cd_prioridade_suporte = rs.cd_prioridade_suporte
    left outer join nivel_suporte ns		            with (nolock) on ns.cd_nivel_suporte	  = rs.cd_nivel_suporte

  where
    rs.cd_cliente = @cd_cliente
    and
    --( rs.dt_solucao_dev is not null and rs.dt_atendimento_cliente is null )
    rs.dt_solucao_dev between @dt_inicial and @dt_final

  order by
    rs.dt_ocorrencia_suporte
    
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
--exec  pr_egis_supnet_processo_modulo
------------------------------------------------------------------------------

--sp_helptext pr_egis_supnet_processo_modulo
--use gbs_egissql
go
/*
exec  pr_egis_supnet_processo_modulo '[{"cd_parametro": 0}]'
exec  pr_egis_supnet_processo_modulo '[{"cd_parametro": 1, "cd_cliente": 445}]'    
exec  pr_egis_supnet_processo_modulo '[{"cd_parametro": 2, "cd_cliente": 445}]'    ]'
*/
go
------------------------------------------------------------------------------
GO
