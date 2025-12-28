--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_377


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_agenda_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_agenda_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_agenda_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_agenda_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_agenda_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_agenda_processo_modulo
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
create procedure  pr_egis_agenda_processo_modulo
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
declare @cd_documento_receber int = 0
declare @vl_saldo_documento   decimal(25,2) = 0.00
declare @vl_documento_receber decimal(25,2) = 0.00
declare @cd_identificacao     varchar(50)

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
select @cd_documento_receber   = valor from #json where campo = 'cd_documento_receber'

--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro         = ISNULL(@cd_parametro,0)

IF ISNULL(@cd_parametro,0) = 0
BEGIN
  select 
    'Sucesso' as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final,
     @cd_usuario  AS cd_usuario


  RETURN;

END

  --Agenda de Feriados

  if @cd_parametro = 1
  begin
    --select * from agenda_feriado
    select
       f.nm_feriado              as nm_agenda,
       a.dt_agenda_feriado       as dt_agenda
    from
       agenda_feriado a
       inner join feriado f on f.cd_feriado = a.cd_feriado

    where
      year(a.dt_agenda_feriado) between @cd_ano-1 and @cd_ano
    order by
      a.dt_agenda_feriado desc
    return
  end

  --Agenda de Obrigações Fiscais--------------------------------

  if @cd_parametro = 2
  begin
    --select * from Fiscal_Obrigacao
    --select * from Fiscal_Agenda_Obrigacao
    --select * from Fiscal_Agenda_Periodo


    -- Cria tabela temporária com a mesma estrutura   
    /*
    IF OBJECT_ID('tempdb..#Fiscal_Agenda_Periodo') IS NOT NULL
       DROP TABLE #Fiscal_Agenda_Periodo;

    CREATE TABLE #Fiscal_Agenda_Periodo (
       cd_agenda INT NOT NULL,
       cd_obrigacao INT NULL,
       dt_inicial DATETIME NULL,
       dt_final DATETIME NULL,
       dt_agenda DATETIME NULL,
       cd_usuario_inclusao INT NULL,
       dt_usuario_inclusao DATETIME NULL,
       cd_usuario INT NULL,
       dt_usuario DATETIME NULL);
       
       
    -- Popula a tabela temporária a partir da Fiscal_Agenda_Obrigacao
    INSERT INTO #Fiscal_Agenda_Periodo (
      cd_agenda,
      cd_obrigacao,
      dt_inicial,
      dt_final,
      dt_agenda,
      cd_usuario_inclusao,
      dt_usuario_inclusao,
      cd_usuario,
      dt_usuario
   )
   SELECT 
     fao.cd_agenda,
     fao.cd_obrigacao,
     -- regra: se tiver cd_mes, monta a data com esse mês, senão usa GETDATE()
     DATEFROMPARTS(YEAR(GETDATE()), ISNULL(fao.cd_mes, MONTH(GETDATE())), fao.qt_dia) AS dt_inicial,
     DATEFROMPARTS(YEAR(GETDATE()), ISNULL(fao.cd_mes, MONTH(GETDATE())), fao.qt_dia) AS dt_final,
     DATEFROMPARTS(YEAR(GETDATE()), ISNULL(fao.cd_mes, MONTH(GETDATE())), fao.qt_dia) AS dt_agenda,
     fao.cd_usuario_inclusao,
     fao.dt_usuario_inclusao,
     fao.cd_usuario,
     fao.dt_usuario
   FROM
     Fiscal_Agenda_Obrigacao fao;

     select * from #Fiscal_Agenda_Periodo
     */


     --DECLARE @Ano INT = 2025;

    delete from Fiscal_Agenda_Periodo
    where
      year(dt_agenda) = @cd_ano

    declare @cd_agenda int = 0

    select
      @cd_agenda = max(cd_agenda)
    from
      Fiscal_Agenda_Periodo
    
    set @cd_agenda = isnull(@cd_agenda,0)


--INSERT INTO Fiscal_Agenda_Periodo (
--    cd_agenda,
--    cd_obrigacao,
--    dt_inicial,
--    dt_final,
--    dt_agenda,
--    cd_usuario_inclusao,
--    dt_usuario_inclusao,
--    cd_usuario,
--    dt_usuario
--)
SELECT 
    identity(Int,1,1) as cd_agenda,
    fao.cd_obrigacao,
    -- Ajusta o dia: se qt_dia > último dia do mês, usa último dia válido
    CASE 
        WHEN fao.qt_dia > DAY(EOMONTH(DATEFROMPARTS(@cd_ano, ISNULL(fao.cd_mes, m.mes), 1)))
        THEN EOMONTH(DATEFROMPARTS(@cd_ano, ISNULL(fao.cd_mes, m.mes), 1))
        ELSE DATEFROMPARTS(@cd_ano, ISNULL(fao.cd_mes, m.mes), fao.qt_dia)
    END AS dt_inicial,
    CASE 
        WHEN fao.qt_dia > DAY(EOMONTH(DATEFROMPARTS(@cd_ano, ISNULL(fao.cd_mes, m.mes), 1)))
        THEN EOMONTH(DATEFROMPARTS(@cd_ano, ISNULL(fao.cd_mes, m.mes), 1))
        ELSE DATEFROMPARTS(@cd_ano, ISNULL(fao.cd_mes, m.mes), fao.qt_dia)
    END AS dt_final,
    CASE 
        WHEN fao.qt_dia > DAY(EOMONTH(DATEFROMPARTS(@cd_ano, ISNULL(fao.cd_mes, m.mes), 1)))
        THEN EOMONTH(DATEFROMPARTS(@cd_ano, ISNULL(fao.cd_mes, m.mes), 1))
        ELSE DATEFROMPARTS(@cd_ano, ISNULL(fao.cd_mes, m.mes), fao.qt_dia)
    END AS dt_agenda,
    fao.cd_usuario_inclusao,
    fao.dt_usuario_inclusao,
    fao.cd_usuario,
    fao.dt_usuario
into #Fiscal_Agenda_Obrigacao
FROM Fiscal_Agenda_Obrigacao fao
CROSS JOIN (
    SELECT 1 AS mes UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) m
WHERE fao.cd_mes IS NULL OR fao.cd_mes = m.mes;

    INSERT INTO Fiscal_Agenda_Periodo
    select * from #Fiscal_Agenda_Obrigacao

    select
       o.cd_obrigacao,
       o.ds_obrigacao,
       o.nm_obrigacao              as nm_agenda,
       a.dt_agenda                 as dt_agenda,
       nm_tipo_tributo =
         case when o.ic_tipo_tributo = '1' then 'Federal'
         else
           case when o.ic_tipo_tributo = '2' then 'Estadual'
             else 
               case when o.ic_tipo_tributo = '3' then 'Trabalhista'
               else
                 case when o.ic_tipo_tributo = '3' then 'Trabalhista' else 'Outros' end
               end
             end
          end

    from
       Fiscal_Agenda_Periodo a
       inner join Fiscal_Obrigacao o on o.cd_obrigacao = a.cd_obrigacao

    where
      year(a.dt_agenda) between @cd_ano and @cd_ano

    order by
      a.dt_agenda desc

    return
  end

  --Agenda de Proposta Comerciais

  if @cd_parametro = 3
  begin
    --select * from agenda_feriado
    select
       'No. '+ cast(a.cd_consulta as varchar(20)) + ' > '+c.nm_fantasia_cliente + ' ('+cast(c.cd_cliente as varchar(20))+')'
                                 as nm_agenda,
       a.dt_consulta             as dt_agenda
    from
       consulta a
       inner join cliente c on c.cd_cliente = a.cd_cliente

    where
      year(a.dt_consulta) between @cd_ano-1 and @cd_ano
      and
      a.cd_consulta in ( select i.cd_consulta from consulta_itens i where
                           i.cd_consulta = a.cd_consulta 
                           and
                           i.dt_perda_consulta_itens is null
                           and
                           isnull(i.cd_pedido_venda,0) = 0 )
    order by
      a.dt_consulta desc
    return
  end

--Agenda de Visitas dos Vendores---

if @cd_parametro = 10
begin
  --update visita set cd_vendedor = 2, cd_cliente = 3

  --select * from vendedor
  --select * from cliente
  --select * from visita
  --insert into visita select * from egissql_317.dbo.visita where dt_visita>'12/25/2025' and cd_vendedor = 9
  
  select
    v.nm_fantasia_vendedor       as nm_agenda,
    vi.dt_visita                 as dt_agenda,
    c.cd_cliente,
    c.nm_fantasia_cliente,
    vi.hr_inicio_visita
    from
       visita vi
       inner join vendedor v on v.cd_vendedor = vi.cd_vendedor
       inner join cliente  c on c.cd_cliente  = vi.cd_cliente

    where
      year(vi.dt_visita) between @cd_ano-1 and @cd_ano
    order by
      vi.dt_visita desc

  return

end


if @cd_parametro = 9999
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
--exec  pr_egis_agenda_processo_modulo
------------------------------------------------------------------------------

go
/*
exec  pr_egis_agenda_processo_modulo '[{"cd_parametro": 0}]'
exec  pr_egis_agenda_processo_modulo '[{"cd_parametro": 1, "cd_modelo": 1}]'                                           ]'
exec  pr_egis_agenda_processo_modulo '[{"cd_parametro": 2, "cd_modelo": 1}]'  
exec  pr_egis_agenda_processo_modulo '[{"cd_parametro": 3, "cd_modelo": 1}]' 
exec  pr_egis_agenda_processo_modulo '[{"cd_parametro": 10, "cd_modelo": 1}]' 
*/
go
------------------------------------------------------------------------------
GO

--exec  pr_egis_agenda_processo_modulo '[{"cd_parametro": 2, "cd_modelo": 1}]' 

--update
--  egisadmin.dbo.menu
--  set
--    ic_json_parametro = 'S',
--    cd_parametro = 10
--  where
--    cd_menu = 8822

