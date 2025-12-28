--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_implantacao_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_implantacao_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_implantacao_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_implantacao_processo_modulo;
GO


-------------------------------------------------------------------------------
--sp_helptext  pr_egis_implantacao_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_implantacao_processo_modulo
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
create procedure  pr_egis_implantacao_processo_modulo
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
    
--consultores

if @cd_parametro = 1
begin
  select 
    c.cd_consultor,
    c.nm_fantasia_consultor,
    c.cd_celular_consultor,
    c.qt_hora_consultor,
    c.nm_email_consultor,
    c.nm_foto_consultor
  from
    consultor_implantacao c
  where
    isnull(ic_ativo_consultor,'N') = 'S'
  order by
    nm_consultor
  return

end

--projetos

if @cd_parametro = 2
begin
  
  select
    * 
  from
    projeto_sistema
  where
    isnull(ic_ativo_projeto,'N') = 'S'

  order by
    nm_projeto

  return
end

--Etapas--

if @cd_parametro = 3
begin
  
  select
    * 
  from
    Etapa_Projeto
 
  order by
    nm_etapa


  return

end

--Atividades

if @cd_parametro = 4
begin
  
  select
    e.nm_etapa,
    ap.* 
  from
    atividade_Projeto ap
    left outer join etapa_projeto e on e.cd_etapa = ap.cd_etapa
  where
    ap.cd_etapa = case when @cd_etapa = 0 then ap.cd_etapa else @cd_etapa end
  order by
    e.nm_etapa,
    ap.cd_atividade


  return

end

--consultas
--select * from registro_atividade_cliente

if @cd_parametro = 5
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
   ap.nm_atividade,
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
   ap.nm_atividade,
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

    
 
  --select * from registro_suporte

  --Mostra a Tabela----------------------------------------------------------------

  select * from #RegistroAtividade
  union all
    select * from #RS
  order by
    dt_inicio_atividade, dt_final_atividade


  return

end

-- INSERT

--select * from registro_atividade_cliente

IF @cd_parametro = 6
BEGIN
  select @cd_registro_atividade = max(cd_registro_atividade)
  from
    Registro_Atividade_Cliente

  set @cd_registro_atividade = isnull(@cd_registro_atividade,0) + 1
    
    INSERT INTO registro_atividade_cliente (cd_registro_atividade,
        dt_registro_atividade,
        cd_cliente_sistema, cd_projeto_sistema, cd_consultor,
        cd_atividade, ds_registro_atividade,
        dt_inicio_atividade, dt_final_atividade,
        cd_usuario, dt_usuario
    )
    SELECT
        @cd_registro_atividade as cd_registro_atividade,
        @dt_hoje               as dt_registro_atividade,
        MAX(CASE WHEN campo = 'cd_cliente'            THEN valor END),
        MAX(CASE WHEN campo = 'cd_projeto_sistema'    THEN valor END),
        MAX(CASE WHEN campo = 'cd_consultor'          THEN valor END),
        MAX(CASE WHEN campo = 'cd_atividade'          THEN valor END),
        MAX(CASE WHEN campo = 'ds_registro_atividade' THEN valor END),
        --TRY_CAST(MAX(CASE WHEN campo = 'dt_inicio_atividade' THEN valor END) AS DATETIME),
        --TRY_CAST(MAX(CASE WHEN campo = 'dt_final_atividade'  THEN valor END) AS DATETIME),
        MAX(@dt_inicio_atividade) as dt_inicio_atividade,
        MAX(@dt_final_atividade)  as dt_final_atividade,
        MAX(CASE WHEN campo = 'cd_usuario'                   THEN valor END),
        GETDATE() as dt_usuario
        --@cd_empresa as cd_empresa
    FROM #json;

    
   
   RETURN

   --select * from registro_atividade_cliente order by dt_registro_atividade desc

END

-- UPDATE
IF @cd_parametro = 7
BEGIN
       UPDATE ra
    SET 
        ra.dt_inicio_atividade = TRY_CAST(j.dt_inicio_atividade AS DATETIME),
        ra.dt_final_atividade  = TRY_CAST(j.dt_final_atividade  AS DATETIME),
        ra.ds_registro_atividade = j.ds_registro_atividade,
        ra.cd_consultor        = j.cd_consultor,
        ra.cd_atividade        = j.cd_atividade,
        ra.cd_usuario          = j.cd_usuario,
        ra.dt_usuario          = GETDATE()
        --ra.cd_empresa          = @cd_empresa
    FROM registro_atividade_cliente ra
    INNER JOIN (
        SELECT 
            MAX(CASE WHEN campo = 'cd_registro_atividade' THEN valor END) AS cd_registro_atividade,
            MAX(CASE WHEN campo = 'dt_inicio_atividade'   THEN valor END) AS dt_inicio_atividade,
            MAX(CASE WHEN campo = 'dt_final_atividade'    THEN valor END) AS dt_final_atividade,
            MAX(CASE WHEN campo = 'ds_registro_atividade' THEN valor END) AS ds_registro_atividade,
            MAX(CASE WHEN campo = 'cd_consultor'          THEN valor END) AS cd_consultor,
            MAX(CASE WHEN campo = 'cd_atividade'          THEN valor END) AS cd_atividade,
            MAX(CASE WHEN campo = 'cd_usuario'            THEN valor END) AS cd_usuario
        FROM #json
    ) j ON ra.cd_registro_atividade = j.cd_registro_atividade
    WHERE
      ra.cd_registro_atividade = @cd_registro_atividade
    RETURN

END

-- DELETE
IF @cd_parametro = 8
BEGIN
   DELETE registro_atividade_cliente
   WHERE cd_registro_atividade = @cd_registro_atividade
   RETURN
END

--Busca o Consultor conforme o usuário---

if @cd_parametro = 9
begin
  select
    cd_consultor,
    nm_consultor,
    nm_fantasia_consultor,
    cd_celular_consultor,
    nm_email_consultor,
    nm_foto_consultor

  from
    Consultor_Implantacao c
  where
    c.cd_usuario_sistema = @cd_usuario
    and
    isnull(c.ic_ativo_consultor,'N') = 'S'

  return
end

if @cd_parametro = 10
begin
  select
    c.cd_cliente,
    c.nm_fantasia_cliente
  from
    cliente c
  where
    isnull(c.cd_status_cliente,1) = 1

  order by
     c.nm_fantasia_cliente
  

  

  --select 
  --  cd_cliente_sistema as cd_cliente,
  --  nm_cliente_sistema as nm_fantasia_cliente
  --from 
  --    cliente_sistema
  --where
  --  isnull(ic_ativo_cliente,'N') = 'S'

  --order by
  --  nm_cliente_sistema

  return

end

--Geração do Registro de Atividades------------------------------------------------------------------


if @cd_parametro = 20
begin

  --registro_atividade_cliente
  --select * from projeto_sistema_composicao

  --select * from projeto_padrao_atividade
  set @dt_base_calculo = @dt_hoje

  select
   cast(0 as int)                as cd_registro_atividade,
   @dt_hoje                      as dt_registro_atividade,
   @cd_cliente                   as cd_cliente_sistema,
   @cd_usuario                   as cd_usuario_sistema,
   null                          as cd_atividade_cliente,
   @cd_modulo                    as cd_modulo,
   --@cd_atividade                 as cd_atividade,
   ppa.cd_atividade_implantacao  as cd_atividade,
   cast('' as nvarchar(max))     as ds_registro_atividade,
   @dt_base_calculo              as dt_inicio_atividade,
   @dt_base_calculo              as dt_final_atividade,
   null                          as qt_hora_atividade,
   null                          as cd_consultor,
   null                          as dt_conclusao_atividade,
   null                          as qt_hora_real_atividade,
   @cd_usuario                   as cd_usuario,
   getdate()                     as dt_usuario,
   'N'                           as ic_programacao_atividade,
   null                          as dt_autorizacao_cliente,
   null                          as nm_responsavel_cliente,
   @cd_cliente                   as cd_cliente,
   null                          as cd_contato,
   null                          as cd_atividade_analista,
   null                          as nm_ra,
   null                          as cd_local_tarefa,
   cast('' as varchar)           as nm_obs_registro_atividade,
   null                          as cd_tarefa_atividade,
   null                          as cd_menu,
   null                          as nm_documento_autorizacao,
   @cd_consultor                 as cd_consultor_atividade,
   cast('' as nvarchar(max))     as ds_conclusao_atividade,
   @cd_projeto                   as cd_projeto_sistema,
   null                          as cd_tipo_horario,
  'N'                            as ic_visita,
   null                          as dt_confirmacao_visita,
   null                          as nm_visita_responsavel,
   null                          as hr_inicio_atividade,
   null                          as hr_fim_atividade,
   @cd_usuario                   as cd_usuario_inclusao,
   getdate()                     as dt_usuario_inclusao,
   identity(int,1,1)             as cd_interface


  into #RA
  from
    Projeto_Sistema_Composicao psc
    inner join Projeto_Sistema ps                on ps.cd_projeto_sistema = psc.cd_projeto_sistema
    left outer join cliente c                    on c.cd_cliente          = ps.cd_cliente
    left outer join cliente_sistema cs           on cs.cd_cliente_sistema = ps.cd_cliente_sistema
    left outer join Projeto_Padrao_Atividade ppa on ppa.cd_projeto_padrao = psc.cd_projeto_padrao

  where
    cs.cd_cliente_sistema = @cd_cliente

  order by
     isnull(ppa.qt_ordem_atividade,0)

    --select @cd_cliente
    --select * from projeto_sistema
    --select * from projeto_sistema_composicao where cd_projeto_sistema = 37

  --select * from #RA
  --return
  
  declare @id             int = 0
  declare @dtAtual        datetime;     -- horário corrente (início do próximo slot)
  declare @slotIni        datetime;
  declare @slotFim        datetime;
  declare @horaIniDia     time(0) = '08:00';
  declare @horaFimDia     time(0) = '18:00';
  declare @horaAlmocoIni  time(0) = '12:00';
  declare @horaAlmocoFim  time(0) = '13:00';
  declare @proximoCd      int;

  -- datas de início/fim do período (se não vierem, usa hoje)
  set @dt_inicial = isnull(@dt_inicial, @dt_hoje);
  set @dt_final   = isnull(@dt_final,   @dt_inicial);

  set @dt_inicial = convert(date, @dt_inicial);
  set @dt_final   = convert(date, @dt_final);

  select @proximoCd = isnull(max(cd_registro_atividade),0) + 1
    from registro_atividade_cliente;

  -- começa no primeiro dia às 08:00
  set @dtAtual = dateadd(hour, 8, convert(datetime, @dt_inicial));

  while exists (select 1 from #RA)
  begin
    select top 1
       @id          = cd_interface,
       @cd_atividade = cd_atividade
    from #RA
    order by cd_interface;

    -- encontra próximo slot disponível (2h), respeitando almoço e fim de expediente
    while 1 = 1
    begin
      -- se ultrapassou o período limite, sai do laço geral
      if convert(date, @dtAtual) > @dt_final
      begin
        delete from #RA; -- limpa qualquer resto
        break;
      end

      -- pula para depois do almoço se cair entre 12:00 e 13:00
      if cast(@dtAtual as time) >= @horaAlmocoIni and cast(@dtAtual as time) < @horaAlmocoFim
      begin
        set @dtAtual = dateadd(hour, 13, convert(datetime, convert(date, @dtAtual))) -- 13:00 do mesmo dia
        continue;
      end

      -- se passou das 18:00, vai para o próximo dia às 08:00
      if cast(@dtAtual as time) >= @horaFimDia
      begin
        set @dtAtual = dateadd(day, 1, convert(date, @dtAtual));
        set @dtAtual = dateadd(hour, 8, convert(datetime, convert(date, @dtAtual)));
        continue;
      end

      set @slotIni = @dtAtual;
      set @slotFim = dateadd(hour, 2, @slotIni);

      -- se o fim do slot ultrapassar o horário de expediente, ajusta para o próximo dia
      if cast(@slotFim as time) > @horaFimDia
      begin
        set @dtAtual = dateadd(day, 1, convert(date, @dtAtual));
        set @dtAtual = dateadd(hour, 8, convert(datetime, convert(date, @dtAtual)));
        continue;
      end

      -- se já existir atividade igual nesse horário, avança 2h e tenta de novo
      if exists (
          select 1
          from registro_atividade_cliente ra
          where isnull(ra.cd_cliente_sistema,0)  = @cd_cliente
            and isnull(ra.cd_projeto_sistema,0)  = @cd_projeto
            and isnull(ra.cd_consultor_atividade,0) = @cd_consultor
            and isnull(ra.cd_atividade,0)        = @cd_atividade
            and ra.dt_inicio_atividade           = @slotIni
      )
      begin
        set @dtAtual = dateadd(hour, 2, @dtAtual);
        continue;
      end

      -- achou um slot livre
      break;
    end

    -- se saiu porque acabou o período, encerra
    if not exists (select 1 from #RA where cd_interface = @id)
      break;

    -- atualiza a linha em #RA com horário e cd_registro_atividade
    select @cd_registro_atividade = isnull(max(cd_registro_atividade),0)
      from registro_atividade_cliente;

    update #RA
    set
      cd_registro_atividade = cd_interface + @cd_registro_atividade,
      dt_inicio_atividade   = @slotIni,
      dt_final_atividade    = @slotFim
    where cd_interface = @id;

    -- insere, mas só se não houver duplicata (segurança extra)
    insert into registro_atividade_cliente
    select ra.*
    from #RA ra
    where
      ra.cd_interface = @id
      and not exists (
        select 1
        from registro_atividade_cliente x
        where isnull(x.cd_cliente_sistema,0)  = isnull(ra.cd_cliente_sistema,0)
          and isnull(x.cd_projeto_sistema,0)  = isnull(ra.cd_projeto_sistema,0)
          and isnull(x.cd_consultor_atividade,0) = isnull(ra.cd_consultor_atividade,0)
          and isnull(x.cd_atividade,0)        = isnull(ra.cd_atividade,0)
          and x.dt_inicio_atividade           = ra.dt_inicio_atividade
      );

    -- próximo slot começa de onde parou
    set @dtAtual = @slotFim;

    delete from #RA where cd_interface = @id;

  end

  if object_id('tempdb..#RA') is not null
    drop table #RA;



  /*
  declare @ic int = 1

  while exists (select top 1 cd_interface from #RA)
  begin
    select top 1
       @id = cd_interface
    from
      #RA

    set @cd_registro_atividade = 0

    select @cd_registro_atividade = max(cd_registro_atividade)
    from
      Registro_Atividade_Cliente

    set @cd_registro_atividade = isnull(@cd_registro_atividade,0) 
    
    update
      #RA
    set
      cd_registro_atividade = cd_interface     + @cd_registro_atividade,
      dt_inicio_atividade   = @dt_base_calculo + 1,
      dt_final_atividade    = @dt_base_calculo + 1
    where
       @id = cd_interface

    --select * from #RA
    --where
    --   @id = cd_interface

    --set @ic = @ic + 1

    --select * from registro_atividade_cliente

    insert into registro_atividade_cliente
    select ra.* from #RA ra
    where
      @id = cd_interface

    --where
    --  ra.cd_registro_atividade not in ( select x.cd_registro_atividade from Registro_Atividade_Cliente x
    --                                    where
    --                                      x.cd_registro_atividade = ra.cd_registro_atividade )

    -----------------
    
    delete from #RA
    where
      @id = cd_interface

  end


  drop table #RA

  */

  return

end



--EgisMob-----------------------------------------------------------------------------------------------

--Consulta de Projetos--

if @cd_parametro = 100
begin   
  select
    cd_projeto_sistema as cd_controle,
    *
  into
    #Projeto
  from
    projeto_sistema p
  where
    isnull(p.ic_ativo_projeto,'N') = 'S'

  order by
    p.nm_projeto

  --projeto_sistema

  --Apresentação dos Projetos no Card do EgisMob--------------------------------------------

  if not exists(select * from #Projeto)  
    begin  
     --Mostro no Card o Período
     select 'S'                                                    as 'MultipleDate'  
    end  
    else   
    begin  
      select   
        cd_controle,        
        'S'                                                                    as 'MultipleDate',  
        'currency-usd'                                                         as 'iconHeader',     
        nm_projeto                                                             as 'caption',
        CAST(cd_identificacao_projeto as varchar(30))                          as 'badgeCaption',
       'Horas : ' + cast( cast(qt_hora_projeto_sistema as int) as varchar(20)) as 'resultado1', 
       dbo.fn_data_string(dt_inicial_projeto) + ' à '+ dbo.fn_data_string(dt_final_projeto) 
                                                                               as 'subcaption1',  
      'Total R$ : ' + dbo.fn_formata_valor(0.00)                               as 'resultado',  
	   --                                                                        as 'resultado2',
	   --CAST('' as varchar(20))                                            as 'resultado3',
      'Total Projeto R$ : ' + dbo.fn_formata_valor(@vl_total)                as 'titleHeader'  
       --cast('Quantidade: ' as varchar(20)) +
	   --cast( cast(@qt_total as int) as varchar(20))                       as 'subtitle2Header',
       --dbo.fn_formata_valor( pc_faturamento) + ' (%)'                     as 'percentual'  

--'badgeCaption'                                    as 'badgeCaption',  
--'badgeResultadoLeft'                              as 'badgeResultadoLeft',  
--'badgeResultadoRight'                             as 'badgeResultadoRight',  
--'badgeTitle'                                      as 'badgeTitle',  
--'red'                                             as 'iconColorFooter1',  
--'blue'                                            as 'iconColorFooter2',  
--'home'                                            as 'iconFooter1',  
--'home'                                            as 'iconFooter2',  
--'home'                                            as 'iconHeader',  
--'percentual'                                      as 'percentual',  
--'smallCaptionLeft'                                as 'smallCaptionLeft',  
--'smallCaptionRight'                               as 'smallCaptionRight',  
--'subtitle2Header'                                 as 'subtitle2Header',  
--'titleHeader'                                     as 'titleHeader',  
--'resultado2'                                      as 'resultado2',  
--'blue'                                            as 'resultado2Color',  
--'resultado1'                                      as 'resultado1',  
--'subcaption2'                                     as 'subcaption2',  
--‘quantidade'                                      as 'quantidade',  
  
  
      from #Projeto b  
      order by          
	    nm_projeto 

     end  
  

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

--select * from Atividade_Analista


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_implantacao_processo_modulo
------------------------------------------------------------------------------

--sp_helptext pr_egis_implantacao_processo_modulo

go

--select * from registro_atividade_cliente

/*
exec  pr_egis_implantacao_processo_modulo '[{"cd_parametro": 0}]'
exec  pr_egis_implantacao_processo_modulo '[{"cd_parametro": 1, "cd_modelo": 1}]' 
exec  pr_egis_implantacao_processo_modulo '[{"cd_parametro": 2, "cd_modelo": 1}]' 
exec  pr_egis_implantacao_processo_modulo '[{"cd_parametro": 3, "cd_modelo": 1}]' 
exec  pr_egis_implantacao_processo_modulo '[{"cd_parametro": 4, "cd_etapa": 21}]' 
exec  pr_egis_implantacao_processo_modulo '[{"cd_parametro": 5, "cd_etapa": 21}]' 
exec  pr_egis_implantacao_processo_modulo '[{"cd_parametro": 10, "cd_usuario": 113}]' 
exec  pr_egis_implantacao_processo_modulo '[{"cd_parametro": 20, "cd_cliente": 3}]' 

*/
--select * from consultor_implantacao

--exec  pr_egis_implantacao_processo_modulo '[{"cd_parametro": 20, "cd_cliente": 3, "cd_consultor": 44}]' 

--select * from cliente_sistema

--exec  pr_egis_implantacao_processo_modulo '[{
--    "ic_json_parametro": "S",
--    "cd_empresa": 2,
--    "cd_usuario": 113,
--    "cd_parametro": 100,
--    "dt_inicial": "2025-11-01",
--    "dt_final": "2025-11-30"
--}]'
--------------------------------------------------------------------------------
--GO
--use egissql

--SELECT * FROM REGISTRO_ATIVIDADE_CLIENTE


--exec  pr_egis_implantacao_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_empresa": 2,
--        "cd_usuario": 113,
--        "cd_parametro": 5,
--        "cd_registro_atividade": null,
--        "cd_cliente": 492,
--        "cd_projeto_sistema": 34,
--        "cd_consultor": 45,
--        "cd_atividade": 23,
--        "ds_registro_atividade": "teste",
--        "dt_inicio_atividade": "2025-11-21T02:28",
--        "dt_final_atividade": "2025-11-21T03:28"
--    }
--]'
