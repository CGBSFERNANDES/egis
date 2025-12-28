--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_meta_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_meta_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_meta_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_meta_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_meta_processo_modulo
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
create procedure  pr_egis_meta_processo_modulo
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
declare @vl_base_calculo     decimal(25,2) = 0.00


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
select @vl_base_calculo        = valor from #json where campo = 'vl_base_calculo'    

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

if @cd_parametro = 1
begin
   --select @vl_base_calculo

    -- Validação básica
    IF ISNULL(@vl_base_calculo, 0) <= 0
        THROW 50002, 'vl_base_calculo deve ser informado e maior que zero.', 1;

    -- Garante período
    IF @dt_inicial IS NULL OR @dt_final IS NULL
    BEGIN
        SET @dt_inicial = dbo.fn_data_inicial(@cd_mes, @cd_ano);
        SET @dt_final   = dbo.fn_data_final(@cd_mes, @cd_ano);
    END;

    DECLARE 
        @qt_dias          INT,
        @pc_meta_diaria   DECIMAL(9,4),
        @dt_aux           DATE,
        @cd_semana        INT,
        @vl_meta_diaria   DECIMAL(25,2);

    SET @qt_dias = DATEDIFF(DAY, @dt_inicial, @dt_final) + 1;

    IF @qt_dias <= 0
        THROW 50003, 'Período inválido para cálculo de meta diária.', 1;

    -- Percentual diário (meta distribuída igualmente)
    SET @pc_meta_diaria = 100.0 / @qt_dias;

    -- Opcional: limpa metas já lançadas no período
    -- Ajuste o critério conforme sua necessidade (empresa, usuário, etc.)
    DELETE FROM Meta_diaria
    WHERE cd_usuario = @cd_usuario
      AND dt_usuario BETWEEN @dt_inicial AND @dt_final;

    -- Loop dia a dia
    SET @dt_aux = @dt_inicial;

    WHILE @dt_aux <= @dt_final
    BEGIN
        -- Semana dentro do período (1,2,3,...)
        SET @cd_semana =
            DATEDIFF(WEEK, @dt_inicial, @dt_aux) + 1;

        -- Valor diário da meta
        SET @vl_meta_diaria = 
            CAST(@vl_base_calculo * (@pc_meta_diaria / 100.0) AS DECIMAL(25,2));

        INSERT INTO Meta_diaria
        (
            cd_semana,
            pc_meta_diaria,
            vl_meta_diaria,
            cd_usuario_inclusao,
            dt_usuario_inclusao,
            cd_usuario,
            dt_usuario
        )
        VALUES
        (
            @cd_semana,
            @pc_meta_diaria,
            @vl_meta_diaria,
            @cd_usuario,   -- quem incluiu
            @dt_hoje,      -- quando incluiu
            @cd_usuario,   -- usuário dono da meta (se for o mesmo)
            @dt_hoje       -- data de registro
        );

        SET @dt_aux = DATEADD(DAY, 1, @dt_aux);
    END;

    -- Retorno de conferência
    SELECT
        'Sucesso'          AS Msg,
        @vl_base_calculo   AS vl_base_calculo,
        @qt_dias           AS qt_dias,
        @pc_meta_diaria    AS pc_meta_diaria,
        @cd_empresa        AS cd_empresa,
        @dt_inicial        AS dt_inicial,
        @dt_final          AS dt_final;


  select 'Cálculo de Meta Diária realizado com Sucesso !' as Msg
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
--exec  pr_egis_meta_processo_modulo
------------------------------------------------------------------------------

--sp_helptext pr_egis_meta_processo_modulo

--select * from Meta_diaria

go
/*
exec  pr_egis_meta_processo_modulo '[{"cd_parametro": 0}]'
exec  pr_egis_meta_processo_modulo '[{"cd_parametro": 1, "vl_base_calculo": 100000, "cd_usuario": 113}]'
*/
go
------------------------------------------------------------------------------
GO

/*
drop table Meta_Diaria
go
CREATE TABLE Meta_diaria
(
    cd_meta_diaria       INT IDENTITY(1,1) PRIMARY KEY,
    cd_semana            INT NOT NULL,                           -- Número da semana dentro do período
    pc_meta_diaria       DECIMAL(9,4) NOT NULL,                  -- Percentual diário da meta (%)
    vl_meta_diaria       DECIMAL(25,2) NOT NULL,                 -- Valor da meta diária (R$)
    
    cd_usuario_inclusao  INT NOT NULL,                           -- Quem incluiu o registro
    dt_usuario_inclusao  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),-- Quando foi incluído

    cd_usuario           INT NOT NULL,                           -- Usuário dono da meta (vendedor)
    dt_usuario           DATE NOT NULL                           -- Data da meta (dia específico)
);
*/

