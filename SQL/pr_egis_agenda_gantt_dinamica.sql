--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_agenda_gantt_dinamica' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_agenda_gantt_dinamica

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_agenda_gantt_dinamica','P') IS NOT NULL
    DROP PROCEDURE pr_egis_agenda_gantt_dinamica;
GO


-------------------------------------------------------------------------------
--sp_helptext  pr_egis_agenda_gantt_dinamica
-------------------------------------------------------------------------------
-- pr_egis_agenda_gantt_dinamica
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
create procedure  pr_egis_agenda_gantt_dinamica
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


declare @cd_empresa            int
declare @cd_parametro          int
declare @cd_documento          int = 0
declare @cd_item_documento     int
declare @cd_usuario            int 
declare @dt_hoje               datetime
declare @dt_inicial            datetime 
declare @dt_final              datetime
declare @cd_ano                int = 0
declare @cd_mes                int = 0
declare @cd_modelo             int = 0
declare @cd_etapa              int = 0
declare @cd_registro_atividade int = 0
declare @dt_inicio_atividade   datetime 
declare @dt_final_atividade    datetime
declare @cd_consultor          int = 0
declare @vl_total              decimal(25,2) = 0.00
declare @cd_cliente            int = 0
declare @cd_modulo             int = 0
declare @cd_atividade          int = 0
declare @dt_base_calculo       datetime = null
declare @cd_projeto            int      = 0

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
select @cd_etapa               = valor from #json where campo = 'cd_etapa'   
select @cd_registro_atividade  = valor from #json where campo = 'cd_registro_atividade'  
select @cd_modulo              = valor from #json where campo = 'cd_modulo'   
select @cd_atividade           = valor from #json where campo = 'cd_atividade'   
select @cd_projeto             = valor from #json where campo = 'cd_projeto_sistema'
select @cd_cliente             = valor from #json where campo = 'cd_cliente'
select @cd_consultor           = valor from #json where campo = 'cd_consultor'
select @dt_inicio_atividade    = TRY_CAST(valor+ ':00' AS DATETIME) from #json where campo = 'dt_inicio_atividade'  
select @dt_final_atividade     = TRY_CAST(valor+ ':00' AS DATETIME) from #json where campo = 'dt_final_atividade'  

--select @dt_inicio_atividade, @dt_final_atividade
--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro          = ISNULL(@cd_parametro,0)
set @cd_registro_atividade = isnull(@cd_registro_atividade,0)
set @cd_consultor          = isnull(@cd_consultor,0)
set @cd_cliente            = isnull(@cd_cliente,0)
set @cd_atividade          = isnull(@cd_atividade,0)


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

--Tabelas Temporárias--

  select 
   --ra.*,
   ra.cd_registro_atividade,
   ra.dt_registro_atividade,
   case when isnull(ra.cd_cliente,0)<>0 then
   ra.cd_cliente
   else
     ra.cd_cliente_sistema
   end                              as cd_cliente,
   ra.cd_contato,
   ra.cd_cliente_sistema,
   ra.cd_modulo,
   ra.cd_atividade,
   ra.cd_atividade_cliente,
   ra.cd_atividade_analista,
   ra.ds_registro_atividade,
   ra.dt_inicio_atividade,
   ra.dt_final_atividade,
   ra.qt_hora_atividade,
   ra.cd_consultor,
   ra.dt_conclusao_atividade,
   ra.nm_responsavel_cliente,
   ra.cd_local_tarefa,
   ra.nm_obs_registro_atividade,
   ra.cd_tarefa_atividade,
   ra.cd_menu,
   ra.cd_projeto_sistema,
   ra.ic_visita,
   ra.dt_confirmacao_visita,
   ra.nm_visita_responsavel,
   ra.ic_programacao_atividade,
   --ra.dt_conclusao_atividade,
   ra.cd_consultor_atividade,
   ra.ds_conclusao_atividade,
   ra.nm_documento_autorizacao,

   --------------------------------Dados---------------------------------------------------
   m.nm_modulo,
   cast(ap.nm_atividade as varchar(120)) as nm_atividade,

   case when isnull(cs.cd_cliente_sistema,0)>0 then
     cs.nm_cliente_sistema
   else
     c.nm_fantasia_cliente
   end                                  as nm_fantasia_cliente,
   ps.nm_projeto,
   ci.nm_consultor,
   lt.nm_local_tarefa,
   mn.nm_menu,
   mn.nm_menu_titulo,
   th.nm_tipo_horario,
   th.hr_inicio_horario,
   th.hr_fim_horario
  into #RegistroAtividade
  
  from
    registro_atividade_cliente ra
    left outer join egisadmin.dbo.modulo m   on m.cd_modulo           = ra.cd_modulo
    left outer join atividade_projeto ap     on ap.cd_atividade       = ra.cd_atividade
    left outer join cliente_sistema cs       on cs.cd_cliente_sistema = ra.cd_cliente_sistema
    left outer join cliente c                on c.cd_cliente          = ra.cd_cliente
    left outer join projeto_sistema ps       on ps.cd_projeto_sistema = ra.cd_projeto_sistema
    left outer join consultor_implantacao ci on ci.cd_consultor       = ra.cd_consultor
    left outer join local_tarefa lt          on lt.cd_local_tarefa    = ra.cd_local_tarefa
    left outer join egisadmin.dbo.menu mn    on mn.cd_menu            = ra.cd_menu
    left outer join Tipo_Horario th          on th.cd_tipo_horario    = ra.cd_tipo_horario

  where
    dt_inicio_atividade between @dt_inicial and @dt_final
  order by dt_inicio_atividade
  

  select 
  --*
   ra.cd_registro_suporte                    as cd_registro_atividade,
   ra.dt_registro_suporte                    as dt_registro_atividade,
   case when isnull(ra.cd_cliente,0)<>0 then
   ra.cd_cliente
   else
     ra.cd_cliente_sistema
   end                                       as cd_cliente,
   ra.cd_contato,
   ra.cd_cliente_sistema,
   ra.cd_modulo,
   @cd_atividade                             as cd_atividade,
   null                                      as cd_atividade_cliente,
   null                                      as cd_atividade_analista,
   cast(ra.ds_ocorrencia_suporte as nvarchar(max))
                                             as ds_registro_atividade,
   ra.dt_previsao_solucao                    as dt_inicio_atividade,
   ra.dt_previsao_solucao                    as dt_final_atividade,
   ra.qt_hora_registro                       as qt_hora_atividade,
   case when isnull(ra.cd_consultor_solucao,0)>0 then
     ra.cd_consultor_solucao
   else
     ra.cd_consultor
   end                                       as cd_consultor,
   ra.dt_solucao_dev                         as dt_conclusao_atividade,
   cc.nm_fantasia_contato                    as nm_responsavel_cliente,
   1                                         as cd_local_tarefa,
   ra.ds_observacao_suporte                  as nm_obs_registro_atividade,
   null                                      as cd_tarefa_atividade,
   ra.cd_menu,
   ps.cd_projeto_sistema,
   ra.ic_agendar_visita                      as ic_visita,
   null                                      as dt_confirmacao_visita,
   null                                      as nm_visita_responsavel,
   'N'                                       as ic_programacao_atividade,
   
   ra.cd_consultor_atendimento               as cd_consultor_atividade,
   ra.ds_solucao                             as ds_conclusao_atividade,
   ra.nm_doc_registro_suporte                as nm_documento_autorizacao,

   --------------------------------Dados---------------------------------------------------
   m.nm_modulo,

   --ap.nm_atividade,
   cast(ra.ds_ocorrencia_suporte as varchar(120)) as nm_atividade,

   case when isnull(cs.cd_cliente_sistema,0)>0 then
     cs.nm_cliente_sistema
   else
     c.nm_fantasia_cliente
   end                                  as nm_fantasia_cliente,
   ps.nm_projeto,
   ci.nm_consultor,
   lt.nm_local_tarefa,
   mn.nm_menu,
   mn.nm_menu_titulo,
   th.nm_tipo_horario,
   th.hr_inicio_horario,
   th.hr_fim_horario
  
  into #RS
  from
    registro_suporte ra
    left outer join cliente_sistema cs        on cs.cd_cliente_sistema = ra.cd_cliente_sistema
    left outer join cliente c                 on c.cd_cliente          = ra.cd_cliente
    left outer join cliente_contato cc        on cc.cd_cliente         = ra.cd_cliente and
                                                 cc.cd_contato         = ra.cd_contato
    left outer join projeto_sistema ps        on ps.cd_cliente          = ra.cd_cliente
    left outer join egisadmin.dbo.modulo m    on m.cd_modulo           = ra.cd_modulo
    left outer join egisadmin.dbo.menu mn     on mn.cd_menu            = ra.cd_menu
    left outer join atividade_implantacao ap  on ap.cd_atividade       = @cd_atividade
    left outer join consultor_implantacao ci  on ci.cd_consultor       = ra.cd_consultor
    left outer join tipo_horario th           on th.cd_tipo_horario    = 3
    left outer join local_tarefa lt           on lt.cd_local_tarefa    = 1

    --select * from tipo_horario 

  where
    ra.dt_previsao_solucao between @dt_inicial and @dt_final
    and
    dt_solucao_dev is null

    


    
--Atividades--

if @cd_parametro = 1
begin
 
  set @cd_atividade = 0

  select
    top 1
    @cd_atividade = cd_atividade
  from
    Atividade_Implantacao

  where
    isnull(ic_suporte_atividade,'N') = 'S'
 
 --select * from atividade_implantacao

 
  --select * from registro_suporte

  --Mostra a Tabela----------------------------------------------------------------

;with AllAtividades as (
    select cd_cliente,
           nm_fantasia_cliente,
           dt_inicio_atividade,
           dt_final_atividade,
           dt_conclusao_atividade,
           nm_atividade
    from #RegistroAtividade
    union all
    select cd_cliente,
           nm_fantasia_cliente,
           dt_inicio_atividade,
           dt_final_atividade,
           dt_conclusao_atividade,
           nm_atividade
    from #RS
),
ResumoCliente as (
    select 
        cd_cliente,
        nm_fantasia_cliente,
        min(dt_inicio_atividade) as startDate,
        max(dt_final_atividade) as endDate,
        cast(100.0 * sum(case when dt_conclusao_atividade is not null then 1 else 0 end) 
             / count(*) as int) as progress
    from AllAtividades
    group by cd_cliente, nm_fantasia_cliente
),
ClienteJSON as (
    select 
        row_number() over(order by cd_cliente) as id,   -- id lógico para clientes
        0 as parentId,
        nm_fantasia_cliente as title,
        'new Date(''' + convert(varchar(30), startDate, 127) + ''')' as start,
        'new Date(''' + convert(varchar(30), endDate, 127) + ''')' as [end],
        progress,
        cd_cliente
    from ResumoCliente
),
AtividadesJSON as (
    select 
        row_number() over(order by cd_cliente, dt_inicio_atividade) as id, -- id lógico para atividades
        cd_cliente as parentId,
        nm_atividade as title,
        'new Date(''' + convert(varchar(30), dt_inicio_atividade, 127) + ''')' as start,
        'new Date(''' + convert(varchar(30), dt_final_atividade, 127) + ''')' as [end],
        case when dt_conclusao_atividade is not null then 100 else 0 end as progress,
        cd_cliente
    from AllAtividades
)

-- Junta clientes e atividades e gera chave única global
select 
    row_number() over(order by cd_cliente, parentId, start) as idKey, -- chave única global
    id,                                                              -- id lógico
    parentId,
    title,
    start,
    [end],
    progress,
    cd_cliente
from (
    select id, parentId, title, start, [end], progress, cd_cliente
    from ClienteJSON
    union all
    select id, parentId, title, start, [end], progress, cd_cliente
    from AtividadesJSON
) as T
order by cd_cliente, parentId, start;

  return

end

--dependencias--

if @cd_parametro = 2
begin

    ;with AllAtividades as (
        select cd_cliente,
               nm_fantasia_cliente,
               dt_inicio_atividade,
               dt_final_atividade,
               dt_conclusao_atividade,
               nm_atividade
        from #RegistroAtividade
        union all
        select cd_cliente,
               nm_fantasia_cliente,
               dt_inicio_atividade,
               dt_final_atividade,
               dt_conclusao_atividade,
               nm_atividade
        from #RS
    ),
    AtividadesJSON as (
        select 
            row_number() over(partition by cd_cliente order by dt_inicio_atividade) as ordem,
            row_number() over(order by cd_cliente, dt_inicio_atividade) as id, -- id lógico global
            cd_cliente,
            nm_atividade as title,
            'new Date(''' + convert(varchar(30), dt_inicio_atividade, 127) + ''')' as start,
            'new Date(''' + convert(varchar(30), dt_final_atividade, 127) + ''')' as [end],
            case when dt_conclusao_atividade is not null then 100 else 0 end as progress
        from AllAtividades
    ),
    DependenciasJSON as (
        select 
            row_number() over(order by a.cd_cliente, a.ordem) as id, -- id da dependência
            a.id as predecessorId,
            b.id as successorId,
            0 as type
        from AtividadesJSON a
        inner join AtividadesJSON b
            on b.cd_cliente = a.cd_cliente
           and b.ordem = a.ordem + 1
    )

    -- Retorna dependências no formato solicitado
    select 
        id,
        predecessorId,
        successorId,
        type
    from DependenciasJSON
    order by id;

    return
end

--recursos

if @cd_parametro = 3
begin

    ;with AllConsultores as (
        select distinct 
            ra.cd_consultor,
            ci.nm_consultor
        from #RegistroAtividade ra
        left join consultor_implantacao ci on ci.cd_consultor = ra.cd_consultor

        union

        select distinct 
            ra.cd_consultor,
            ci.nm_consultor
        from #RS ra
        left join consultor_implantacao ci on ci.cd_consultor = ra.cd_consultor
    ),
    RecursosJSON as (
        select 
            row_number() over(order by cd_consultor) as id,
            nm_consultor as text
        from AllConsultores
        where cd_consultor is not null
    )

    -- Retorna recursos (consultores) no formato solicitado
    select 
        id,
        text
    from RecursosJSON
    order by id;

    return
end


if @cd_parametro = 4
begin

    ;with AllAtividades as (
        select cd_cliente,
               nm_fantasia_cliente,
               dt_inicio_atividade,
               dt_final_atividade,
               dt_conclusao_atividade,
               nm_atividade,
               cd_consultor
        from #RegistroAtividade
        union all
        select cd_cliente,
               nm_fantasia_cliente,
               dt_inicio_atividade,
               dt_final_atividade,
               dt_conclusao_atividade,
               nm_atividade,
               cd_consultor
        from #RS
    ),
    AtividadesJSON as (
        select 
            row_number() over(order by cd_cliente, dt_inicio_atividade) as id, -- id lógico da atividade
            cd_cliente,
            nm_atividade,
            cd_consultor
        from AllAtividades
    ),
    RecursosJSON as (
        select 
            row_number() over(order by cd_consultor) as id,
            cd_consultor,
            nm_consultor as text
        from consultor_implantacao
        where cd_consultor in (select distinct cd_consultor from AllAtividades where cd_consultor is not null)
    ),
    ResourceAssignments as (
        select 
            row_number() over(order by a.id) - 1 as id,   -- id sequencial da atribuição (começando em 0)
            a.id as taskId,                              -- id da atividade
            r.id as resourceId                           -- id do recurso (consultor)
        from AtividadesJSON a
        inner join RecursosJSON r 
            on r.cd_consultor = a.cd_consultor
    )

    -- Retorna atribuições no formato solicitado
    select 
        id,
        taskId,
        resourceId
    from ResourceAssignments
    order by id;

    return
end

/*
2-dependencias
3-recursos
4-resourceAssignments
*/

--
/*

export const dependencies = [{
  id: 1,
  predecessorId: 3,
  successorId: 4,
  type: 0,
}, {
  id: 2,
  predecessorId: 4,
  successorId: 5,
  type: 0,
}, {
  id: 3,


  export const resources = [{
  id: 1,
  text: 'Management',
}, {
  id: 2,
  text: 'Project Manager',
}, {
  id: 3,
  text: 'Analyst',
}, {

export const resourceAssignments = [{
  id: 0,
  taskId: 3,
  resourceId: 1,
}, {
  id: 1,
  taskId: 4,
  resourceId: 1,
}, {
  id: 2,
  taskId: 5,
  resourceId: 2,
}, {
*/

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

--select * from Atividade_Analista


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_agenda_gantt_dinamica
------------------------------------------------------------------------------

--sp_helptext pr_egis_agenda_gantt_dinamica

go

--select * from registro_atividade_cliente

/*
exec  pr_egis_agenda_gantt_dinamica '[{"cd_parametro": 0}]'
exec  pr_egis_agenda_gantt_dinamica '[{"cd_parametro": 1, "cd_modelo": 1}]' 


*/

exec  pr_egis_agenda_gantt_dinamica '[{"cd_parametro": 1, "cd_modelo": 1}]' 

exec  pr_egis_agenda_gantt_dinamica '[{"cd_parametro": 2, "cd_modelo": 1}]' 

exec  pr_egis_agenda_gantt_dinamica '[{"cd_parametro": 3, "cd_modelo": 1}]' 

exec  pr_egis_agenda_gantt_dinamica '[{"cd_parametro": 4, "cd_modelo": 1}]' 