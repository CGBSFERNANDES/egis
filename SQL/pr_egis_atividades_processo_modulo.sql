--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_atividades_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_atividades_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_atividades_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_atividades_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_atividades_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_atividades_processo_modulo
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
create procedure  pr_egis_atividades_processo_modulo
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
declare @cd_consultor        int = 0
declare @qt_dia_atividade    int = 6
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
select @cd_consultor           = valor from #json where campo = 'cd_consultor'             

--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro = ISNULL(@cd_parametro,0)


 ------------------------------------------------------------
 --  Defaults e validações
 ------------------------------------------------------------
 IF @dt_inicial IS NULL SET @dt_inicial = CONVERT(date,GETDATE());
 IF @dt_final   IS NULL SET @dt_final   = DATEADD(DAY, 30, @dt_inicial);
 IF @qt_dia_atividade IS NULL OR @qt_dia_atividade <= 0 SET @qt_dia_atividade = 6;

 set @cd_consultor = isnull(@cd_consultor,0)

--------------------------------------------------------------------------------------

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
    
if @cd_parametro = 1
begin

    ------------------------------------------------------------
    --Geração do calendário de dias entre @dt_inicial e @dt_final
    ------------------------------------------------------------
    ;WITH CTE_Dias AS
    (
        SELECT @dt_inicial AS dt
        UNION ALL
        SELECT DATEADD(DAY,1,dt)
        FROM CTE_Dias
        WHERE dt < @dt_final
    )
    ------------------------------------------------------------
    -- 4) Base de atividades do período (registro_suporte)
    ------------------------------------------------------------
    , CTE_Atv AS
    (
        SELECT
              RS.cd_registro_suporte
            , RS.dt_registro_suporte
            , RS.hr_entrada
            , RS.dt_ocorrencia_suporte
            , RS.ds_ocorrencia_suporte
            , RS.ds_mensagem_suporte
            , RS.ds_observacao_suporte
            , RS.nm_doc_registro_suporte
            , RS.dt_previsao_solucao
            , RS.cd_consultor_solucao
            , RS.ic_agendar_visita
            , RS.qt_hora_registro
            , RS.ic_cronograma
            , RS.cd_consultor
            , RS.cd_cliente
            , RS.cd_contato
            , RS.cd_modulo
            , c.nm_consultor
            , cli.nm_fantasia_cliente
        FROM
           dbo.registro_suporte RS
           left outer join Consultor_Implantacao c on c.cd_consultor = rs.cd_consultor_solucao
           left outer join Cliente cli             on cli.cd_cliente = rs.cd_cliente
        WHERE
          rs.cd_status_suporte=1 
          and
          RS.dt_previsao_solucao IS NOT NULL
          AND CONVERT(date, RS.dt_previsao_solucao) BETWEEN @dt_inicial AND @dt_final
          and
          rs.cd_consultor_solucao = case when @cd_consultor = 0 then rs.cd_consultor_solucao else @cd_consultor end
          )
    ------------------------------------------------------------
    -- Saída: 1 linha por dia com JSON de até @qt_dia_atividade
    ------------------------------------------------------------
    SELECT
          d.dt                                                    AS dt_agenda
        , DATENAME(weekday, d.dt)                                 AS nm_dia_semana
        , (
            SELECT COUNT(1)
            FROM CTE_Atv a
            WHERE CONVERT(date, a.dt_previsao_solucao) = d.dt
          )                                                       AS qt_total_dia
        , (
            SELECT TOP (@qt_dia_atividade)
                   a.cd_registro_suporte,
                   a.dt_registro_suporte,
                   a.hr_entrada,
                   a.dt_ocorrencia_suporte,
                   a.ds_ocorrencia_suporte,
                   a.ds_mensagem_suporte,
                   a.ds_observacao_suporte,
                   a.nm_doc_registro_suporte,
                   a.dt_previsao_solucao,
                   a.cd_consultor_solucao,
                   a.ic_agendar_visita,
                   a.qt_hora_registro,
                   a.ic_cronograma,
                   a.cd_consultor,
                   a.cd_cliente,
                   a.cd_contato,
                   a.cd_modulo
            FROM CTE_Atv a
            WHERE CONVERT(date, a.dt_previsao_solucao) = d.dt
            ORDER BY a.dt_previsao_solucao, a.cd_registro_suporte
            FOR JSON PATH
          )                                                       AS atividades_json
    FROM CTE_Dias d
    OPTION (MAXRECURSION 32767); 


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


--exec pr_egis_atributos_tabela 1885
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_atividades_processo_modulo
------------------------------------------------------------------------------

--sp_helptext pr_egis_modelo_procedure

go
/*
exec  pr_egis_modelo_procedure '[{"cd_parametro": 0}]'
exec  pr_egis_modelo_procedure '[{"cd_parametro": 1, "cd_consultor": 0}]'                                           ]'
*/
go
------------------------------------------------------------------------------
GO
