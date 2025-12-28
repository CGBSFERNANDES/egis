--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_cromo


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_kamban_processo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_kamban_processo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_kamban_processo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_kamban_processo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_kamban_processo
-------------------------------------------------------------------------------
-- pr_egis_kamban_processo
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
create procedure  pr_egis_kamban_processo
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


declare @cd_empresa             int
declare @cd_parametro           int
declare @cd_documento           int = 0
declare @cd_item_documento      int
declare @cd_usuario             int 
declare @dt_hoje                datetime
declare @dt_inicial             datetime 
declare @dt_final               datetime
declare @cd_ano                 int = 0
declare @cd_mes                 int = 0
declare @cd_dia                 int = 0
declare @cd_modelo              int = 0
declare @cd_modulo              int = 0
declare @vl_moeda               decimal(25,2)    
declare @vl_total               decimal(25,2)    
declare @qt_produto             int
declare @qt_total               decimal(25,4)  
declare @cd_grupo_usuario       int 
declare @cd_vendedor            int 
declare @cd_cliente             int          = 0
declare @nm_link_api            varchar(500) = ''
declare @nm_link_rejeicao       varchar(500) = ''
declare @cd_etapa               int = 0
declare @cd_movimento           int = 0
declare @nm_nfe_link            nvarchar(max) = ''
declare @nm_basesql             nvarchar(150) = ''
declare @ic_status_servidor_nfe char(1) = ''
declare @dt_inicio_periodo      datetime
declare @dt_fim_periodo         datetime

--Empresa--
select @cd_empresa = dbo.fn_empresa()

--Vendedor--
select @cd_vendedor = dbo.fn_usuario_vendedor(@cd_usuario) 

--Link NFE	  
select
  @nm_nfe_link      = nm_link_nfe
  --@nm_link_rejeicao = nm_link_rejeicao
from 
  config_egismob 
where
  cd_empresa = @cd_empresa

-- Nome BaseSql
select @nm_basesql = dbo.fn_nm_banco_empresa_geral()

-- Status do Servidor NFe
select top 1 @ic_status_servidor_nfe = isnull(ic_ativo,'N') from egisadmin.dbo.NFe_Empresa where cd_empresa = @cd_empresa
-----------------------------------------------------------    
--versao_nfe

set @vl_moeda         = 1    
set @vl_total         = 0   
set @qt_produto       = 0
set @qt_total         = 0 
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)      
set @cd_ano           = year(@dt_hoje)    
set @cd_dia           = day(@dt_hoje)
set @cd_mes           = month(@dt_hoje)
set @cd_grupo_usuario = 0
   
--Verifica qual é o cliente consumidor do cupom fiscal

set @cd_cliente   = 0

if @cd_empresa <> 360
begin
   select @cd_cliente = isnull(cd_cliente,0) from Parametro_Loja where cd_empresa = @cd_empresa and isnull(cd_cliente,0) > 0
end
--------------------------------------------------------------------------------------------------------------------------
--versao_nfe
-----------------------------------------------------------    
set @nm_link_api = ''
select top 1 @nm_link_api = isnull(nm_link_api,'') from versao_nfe where cd_empresa = @cd_empresa
--------------------------------------------------------------------------------------------------------------------------
--select * from versao_nfe

--select @nm_link_api

--update
--  versao_nfe
--set
--  nm_link_api = 'https://api.focusnfe.com.br'

if @dt_inicio_periodo is null  or @dt_inicial = '01/01/1900'    
begin      
      
  set @cd_ano = year(@dt_hoje)      
  set @cd_mes = month(@dt_hoje)      
      
  set @dt_inicio_periodo = dbo.fn_data_inicial(@cd_mes,@cd_ano)      
  set @dt_fim_periodo    = dbo.fn_data_final(@cd_mes,@cd_ano)      
      
end    

----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano            = year(getdate())
set @cd_mes            = month(getdate())  

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
select @cd_modulo              = valor from #json where campo = 'cd_modulo'             

--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro = ISNULL(@cd_parametro,0)
set @cd_modulo    = isnull(@cd_modulo,0)


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
    
--Métodos de Kamban Disponível por Módulo e Empresa
-----------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.funil_metodo

IF ISNULL(@cd_parametro,0) = 1
BEGIN
  select 
    f.cd_metodo,
    f.nm_metodo,
    f.qt_ordem,
    s.nm_segmento,
    m.nm_modulo
  from 
    egisadmin.dbo.Funil_Metodo f
    left outer join egisadmin.dbo.segmento s on s.cd_segmento = f.cd_segmento_mercado
    left outer join egisadmin.dbo.modulo m   on m.cd_modulo   = f.cd_modulo

  where
    f.cd_modulo = case when @cd_modulo = 0 then f.cd_modulo else @cd_modulo end

  RETURN;

END

--Etadas do Kamban-------------------------------------------------------------------------------------------

IF ISNULL(@cd_parametro,0) = 2
BEGIN
  select 
    f.cd_metodo,
    f.nm_metodo,
    f.qt_ordem,
    s.nm_segmento,
    e.nm_etapa,
    m.nm_modulo
  from 
    egisadmin.dbo.Funil_Metodo f
    left outer join egisadmin.dbo.segmento s               on s.cd_segmento = f.cd_segmento_mercado
    left outer join egisadmin.dbo.modulo m                 on m.cd_modulo   = f.cd_modulo
    left outer join egisadmin.dbo.Funil_Composicao_Etapa c on c.cd_metodo   = f.cd_metodo
    left outer join egisadmin.dbo.Etapa_Processo_Modulo e  on e.cd_etapa    = c.cd_etapa
  where
    f.cd_modulo = case when @cd_modulo = 0 then f.cd_modulo else @cd_modulo end

  RETURN;

END

--Mesma funcionalidade dos Kambam---

if @cd_parametro = 3 or @cd_parametro = 4
begin
  
  if @cd_parametro = 3
     set @cd_parametro = 1 --Manter a Compatibilidade
  else
     set @cd_parametro = 0

  --Status das etapas dos Módulos-----------------------------------------------------------------------------------------------------------

  --select @cd_modulo

  select
    identity(int,1,1) as cd_controle,
    s.nm_status,
    m.*,
    isnull(s.nm_cor_status,'red')    as nm_cor_status,
    isnull(s.nm_cor_texto,'black')   as nm_cor_texto,
    cast(0 as int)                   as qt_status,
    isnull(s.ic_usuario_status,'N')  as ic_usuario_status
    
    into
       #StatusEtapa

    from 
      egisadmin.dbo.Modulo_Etapa_Composicao_Status         m with(nolock)
      left outer join egisadmin.dbo.Status_Processo_Modulo s with(nolock) on s.cd_status = m.cd_status
    
    where
      m.cd_modulo = @cd_modulo
    
    order by
      m.qt_ordem
    
    select  
      cast(0 as int)                                                         as cd_controle,
	  43                                                                     as cd_etapa,
	  ea.nm_etapa                                                            as nm_etapa,
	  c.cd_cliente                                                          as cd_movimento,
	  
	  dbo.fn_data_string(@dt_hoje)                                      as dt_movimento,
	  cast('' as varchar(20))
	  as nm_contato,
	  cast(''   as varchar(100))                                             as nm_ocorrencia,
	  cast(''   as varchar(800))                                             as ds_informativo,
	  null                                                                   as cd_prioridade,
      cast(''   as varchar(60))                                              as nm_prioridade,
      cast(''   as varchar(60))                                              as nm_status,
      cast(''   as varchar(60))                                              as nm_nivel,
	  mo.cd_modulo                                                           as cd_modulo,
      mo.nm_modulo                                                           as nm_modulo,
	  cast('' as varchar(20))                                                    as sg_modulo,
	  isnull( 0.00,0)                                                             as vl_etapa,
	  @dt_hoje                                                                    as dt_etapa,
	  --mo.sg_modulo,														      
	  isnull(m.cd_menu,0)                                                         as cd_menu,
      isnull(m.nm_menu,'')                                                        as nm_menu,
	  case when isnull(me.cd_api,0)>0 then
	     me.cd_api
	  else
	     isnull(m.cd_api,0)
	  end                                                                         as cd_api,
	  isnull('','')                                                               as nm_vendedor,
	  cast('' as varchar(80))                                                     as nm_responsavel,
	  cast('' as varchar(80))                                                     as nm_executor,
	  'R$ '+dbo.fn_formata_valor(isnull(0.00,''))                                 as vl_credito,
	  'R$ '+dbo.fn_formata_valor(isnull(0.00,''))                                 as vl_saldo,
	  isnull(cast('' as varchar(8000)),'')                                        as nm_atendimento,
      isnull(cast('' as varchar(8000)),'')                                        as nm_condicao_pagamento,
	  isnull(cast('' as varchar(8000)),'')                                        as nm_transportadora,
	  cast('' as varchar(8000))                                                   as nm_financeiro,
	  cast(0 as int)                                                              as cd_status,
	  cast('' as varchar(max))                                                    as nm_status_etapa,
	  isnull(ea.cd_documento,0)                                                   as cd_tipo_documento,
	  isnull(me.cd_pagina,0)                                                      as cd_pagina,
	  isnull(me.nm_titulo_pagina_etapa,'')                                        as nm_titulo_pagina_etapa,
	  isnull(pagi.nm_pagina,'')                                                   as nm_pagina,
	  isnull(pagi.nm_caminho_pagina,'')                                           as nm_caminho_pagina,
	  isnull(me.cd_relatorio,0)                                                   as cd_relatorio,
	  cast('' as varchar(8000))                                                   as nm_nfe_link, 
	  cast('' as varchar(8000))                                                   as nm_xml, 
	  isnull(cast(0 as int),0)                                                    as cd_serie_nota,
	  isnull(me.ic_cab_etapa,'N')                                                 as ic_cab_etapa,
	  
	  --------------------------------------------------------------------------------------------------------------------------
	  isnull(c.cd_cliente,0)                                                 as cd_documento,
	  isnull(cast(0 as int),0)                                               as cd_item_documento,
	  c.cd_cliente,
	  cast('' as varchar(500))                                               as nm_link_relatorio

	  into
	    #AuxMontaCard


    from
      Cliente c with(nolock)
	  left outer join egisadmin.dbo.Etapa_Processo_Modulo ea with(nolock) on ea.cd_etapa              = 1	 
	  left outer join egisadmin.dbo.modulo mo                with(nolock) on mo.cd_modulo             = @cd_modulo
	  left outer join egisadmin.dbo.modulo_etapa me          with(nolock) on me.cd_modulo             = mo.cd_modulo and --select * from egisadmin.dbo.modulo_etapa where cd_pagina is not null
	                                                                         me.cd_etapa              = ea.cd_etapa --select * from egisadmin.dbo.Pagina_Internet where cd_pagina is not null
      left outer join egisadmin.dbo.Pagina_Internet pagi     with(nolock) on pagi.cd_pagina           = me.cd_pagina
	  left outer join egisadmin.dbo.menu m                   with(nolock) on m.cd_menu                = me.cd_menu

    union all

    select  
      cast(0 as int)                                                         as cd_controle,
      368                                                                    as cd_etapa,
	  ea.nm_etapa                                                            as nm_etapa,
	  c.cd_cliente                                                          as cd_movimento,
	  
	  dbo.fn_data_string(@dt_hoje)                                      as dt_movimento,
	  cast('' as varchar(20))
	  as nm_contato,
	  cast(''   as varchar(100))                                             as nm_ocorrencia,
	  cast(''   as varchar(800))                                             as ds_informativo,
	  null                                                                   as cd_prioridade,
      cast(''   as varchar(60))                                              as nm_prioridade,
      cast(''   as varchar(60))                                              as nm_status,
      cast(''   as varchar(60))                                              as nm_nivel,
	  mo.cd_modulo                                                           as cd_modulo,
      mo.nm_modulo                                                           as nm_modulo,
	  cast('' as varchar(20))                                                    as sg_modulo,
	  isnull( 0.00,0)                                                             as vl_etapa,
	  @dt_hoje                                                                    as dt_etapa,
	  --mo.sg_modulo,														      
	  isnull(m.cd_menu,0)                                                         as cd_menu,
      isnull(m.nm_menu,'')                                                        as nm_menu,
	  case when isnull(me.cd_api,0)>0 then
	     me.cd_api
	  else
	     isnull(m.cd_api,0)
	  end                                                                         as cd_api,
	  isnull('','')                                                               as nm_vendedor,
	  cast('' as varchar(80))                                                     as nm_responsavel,
	  cast('' as varchar(80))                                                     as nm_executor,
	  'R$ '+dbo.fn_formata_valor(isnull(0.00,''))                                 as vl_credito,
	  'R$ '+dbo.fn_formata_valor(isnull(0.00,''))                                 as vl_saldo,
	  isnull(cast('' as varchar(8000)),'')                                        as nm_atendimento,
      isnull(cast('' as varchar(8000)),'')                                        as nm_condicao_pagamento,
	  isnull(cast('' as varchar(8000)),'')                                        as nm_transportadora,
	  cast('' as varchar(8000))                                                   as nm_financeiro,
	  cast(0 as int)                                                              as cd_status,
	  cast('' as varchar(max))                                                    as nm_status_etapa,
	  isnull(ea.cd_documento,0)                                                   as cd_tipo_documento,
	  isnull(me.cd_pagina,0)                                                      as cd_pagina,
	  isnull(me.nm_titulo_pagina_etapa,'')                                        as nm_titulo_pagina_etapa,
	  isnull(pagi.nm_pagina,'')                                                   as nm_pagina,
	  isnull(pagi.nm_caminho_pagina,'')                                           as nm_caminho_pagina,
	  isnull(me.cd_relatorio,0)                                                   as cd_relatorio,
	  cast('' as varchar(8000))                                                   as nm_nfe_link, 
	  cast('' as varchar(8000))                                                   as nm_xml, 
	  isnull(cast(0 as int),0)                                                    as cd_serie_nota,
	  isnull(me.ic_cab_etapa,'N')                                                 as ic_cab_etapa,
	  
	  --------------------------------------------------------------------------------------------------------------------------
	  isnull(c.cd_cliente,0)                                                 as cd_documento,
	  isnull(cast(0 as int),0)                                               as cd_item_documento,
	  c.cd_cliente,
	  cast('' as varchar(500))                                               as nm_link_relatorio

	

    from
      Cliente c with(nolock)
	  left outer join egisadmin.dbo.Etapa_Processo_Modulo ea with(nolock) on ea.cd_etapa              = 368	 
	  left outer join egisadmin.dbo.modulo mo                with(nolock) on mo.cd_modulo             = @cd_modulo
	  left outer join egisadmin.dbo.modulo_etapa me          with(nolock) on me.cd_modulo             = mo.cd_modulo and --select * from egisadmin.dbo.modulo_etapa where cd_pagina is not null
	                                                                         me.cd_etapa              = ea.cd_etapa --select * from egisadmin.dbo.Pagina_Internet where cd_pagina is not null
      left outer join egisadmin.dbo.Pagina_Internet pagi     with(nolock) on pagi.cd_pagina           = me.cd_pagina
	  left outer join egisadmin.dbo.menu m                   with(nolock) on m.cd_menu                = me.cd_menu

    union all

    select  
      cast(0 as int)                                                         as cd_controle,
      369                                                                    as cd_etapa,
	  ea.nm_etapa                                                            as nm_etapa,
	  c.cd_cliente                                                          as cd_movimento,
	  
	  dbo.fn_data_string(@dt_hoje)                                      as dt_movimento,
	  cast('' as varchar(20))
	  as nm_contato,
	  cast(''   as varchar(100))                                             as nm_ocorrencia,
	  cast(''   as varchar(800))                                             as ds_informativo,
	  null                                                                   as cd_prioridade,
      cast(''   as varchar(60))                                              as nm_prioridade,
      cast(''   as varchar(60))                                              as nm_status,
      cast(''   as varchar(60))                                              as nm_nivel,
	  mo.cd_modulo                                                           as cd_modulo,
      mo.nm_modulo                                                           as nm_modulo,
	  cast('' as varchar(20))                                                    as sg_modulo,
	  isnull( 0.00,0)                                                             as vl_etapa,
	  @dt_hoje                                                                    as dt_etapa,
	  --mo.sg_modulo,														      
	  isnull(m.cd_menu,0)                                                         as cd_menu,
      isnull(m.nm_menu,'')                                                        as nm_menu,
	  case when isnull(me.cd_api,0)>0 then
	     me.cd_api
	  else
	     isnull(m.cd_api,0)
	  end                                                                         as cd_api,
	  isnull('','')                                                               as nm_vendedor,
	  cast('' as varchar(80))                                                     as nm_responsavel,
	  cast('' as varchar(80))                                                     as nm_executor,
	  'R$ '+dbo.fn_formata_valor(isnull(0.00,''))                                 as vl_credito,
	  'R$ '+dbo.fn_formata_valor(isnull(0.00,''))                                 as vl_saldo,
	  isnull(cast('' as varchar(8000)),'')                                        as nm_atendimento,
      isnull(cast('' as varchar(8000)),'')                                        as nm_condicao_pagamento,
	  isnull(cast('' as varchar(8000)),'')                                        as nm_transportadora,
	  cast('' as varchar(8000))                                                   as nm_financeiro,
	  cast(0 as int)                                                              as cd_status,
	  cast('' as varchar(max))                                                    as nm_status_etapa,
	  isnull(ea.cd_documento,0)                                                   as cd_tipo_documento,
	  isnull(me.cd_pagina,0)                                                      as cd_pagina,
	  isnull(me.nm_titulo_pagina_etapa,'')                                        as nm_titulo_pagina_etapa,
	  isnull(pagi.nm_pagina,'')                                                   as nm_pagina,
	  isnull(pagi.nm_caminho_pagina,'')                                           as nm_caminho_pagina,
	  isnull(me.cd_relatorio,0)                                                   as cd_relatorio,
	  cast('' as varchar(8000))                                                   as nm_nfe_link, 
	  cast('' as varchar(8000))                                                   as nm_xml, 
	  isnull(cast(0 as int),0)                                                    as cd_serie_nota,
	  isnull(me.ic_cab_etapa,'N')                                                 as ic_cab_etapa,
	  
	  --------------------------------------------------------------------------------------------------------------------------
	  isnull(c.cd_cliente,0)                                                 as cd_documento,
	  isnull(cast(0 as int),0)                                               as cd_item_documento,
	  c.cd_cliente,
	  cast('' as varchar(500))                                               as nm_link_relatorio

	

    from
      Cliente c with(nolock)
	  left outer join egisadmin.dbo.Etapa_Processo_Modulo ea with(nolock) on ea.cd_etapa              = 369
	  left outer join egisadmin.dbo.modulo mo                with(nolock) on mo.cd_modulo             = @cd_modulo
	  left outer join egisadmin.dbo.modulo_etapa me          with(nolock) on me.cd_modulo             = mo.cd_modulo and --select * from egisadmin.dbo.modulo_etapa where cd_pagina is not null
	                                                                         me.cd_etapa              = ea.cd_etapa --select * from egisadmin.dbo.Pagina_Internet where cd_pagina is not null
      left outer join egisadmin.dbo.Pagina_Internet pagi     with(nolock) on pagi.cd_pagina           = me.cd_pagina
	  left outer join egisadmin.dbo.menu m                   with(nolock) on m.cd_menu                = me.cd_menu

union all

    select  
      cast(0 as int)                                                         as cd_controle,
      370                                                                   as cd_etapa,
	  ea.nm_etapa                                                            as nm_etapa,
	  c.cd_cliente                                                          as cd_movimento,
	  
	  dbo.fn_data_string(@dt_hoje)                                      as dt_movimento,
	  cast('' as varchar(20))
	  as nm_contato,
	  cast(''   as varchar(100))                                             as nm_ocorrencia,
	  cast(''   as varchar(800))                                             as ds_informativo,
	  null                                                                   as cd_prioridade,
      cast(''   as varchar(60))                                              as nm_prioridade,
      cast(''   as varchar(60))                                              as nm_status,
      cast(''   as varchar(60))                                              as nm_nivel,
	  mo.cd_modulo                                                           as cd_modulo,
      mo.nm_modulo                                                           as nm_modulo,
	  cast('' as varchar(20))                                                    as sg_modulo,
	  isnull( 0.00,0)                                                             as vl_etapa,
	  @dt_hoje                                                                    as dt_etapa,
	  --mo.sg_modulo,														      
	  isnull(m.cd_menu,0)                                                         as cd_menu,
      isnull(m.nm_menu,'')                                                        as nm_menu,
	  case when isnull(me.cd_api,0)>0 then
	     me.cd_api
	  else
	     isnull(m.cd_api,0)
	  end                                                                         as cd_api,
	  isnull('','')                                                               as nm_vendedor,
	  cast('' as varchar(80))                                                     as nm_responsavel,
	  cast('' as varchar(80))                                                     as nm_executor,
	  'R$ '+dbo.fn_formata_valor(isnull(0.00,''))                                 as vl_credito,
	  'R$ '+dbo.fn_formata_valor(isnull(0.00,''))                                 as vl_saldo,
	  isnull(cast('' as varchar(8000)),'')                                        as nm_atendimento,
      isnull(cast('' as varchar(8000)),'')                                        as nm_condicao_pagamento,
	  isnull(cast('' as varchar(8000)),'')                                        as nm_transportadora,
	  cast('' as varchar(8000))                                                   as nm_financeiro,
	  cast(0 as int)                                                              as cd_status,
	  cast('' as varchar(max))                                                    as nm_status_etapa,
	  isnull(ea.cd_documento,0)                                                   as cd_tipo_documento,
	  isnull(me.cd_pagina,0)                                                      as cd_pagina,
	  isnull(me.nm_titulo_pagina_etapa,'')                                        as nm_titulo_pagina_etapa,
	  isnull(pagi.nm_pagina,'')                                                   as nm_pagina,
	  isnull(pagi.nm_caminho_pagina,'')                                           as nm_caminho_pagina,
	  isnull(me.cd_relatorio,0)                                                   as cd_relatorio,
	  cast('' as varchar(8000))                                                   as nm_nfe_link, 
	  cast('' as varchar(8000))                                                   as nm_xml, 
	  isnull(cast(0 as int),0)                                                    as cd_serie_nota,
	  isnull(me.ic_cab_etapa,'N')                                                 as ic_cab_etapa,
	  
	  --------------------------------------------------------------------------------------------------------------------------
	  isnull(c.cd_cliente,0)                                                 as cd_documento,
	  isnull(cast(0 as int),0)                                               as cd_item_documento,
	  c.cd_cliente,
	  cast('' as varchar(500))                                               as nm_link_relatorio

	

    from
      Cliente c with(nolock)
	  left outer join egisadmin.dbo.Etapa_Processo_Modulo ea with(nolock) on ea.cd_etapa              = 370
	  left outer join egisadmin.dbo.modulo mo                with(nolock) on mo.cd_modulo             = @cd_modulo
	  left outer join egisadmin.dbo.modulo_etapa me          with(nolock) on me.cd_modulo             = mo.cd_modulo and --select * from egisadmin.dbo.modulo_etapa where cd_pagina is not null
	                                                                         me.cd_etapa              = ea.cd_etapa --select * from egisadmin.dbo.Pagina_Internet where cd_pagina is not null
      left outer join egisadmin.dbo.Pagina_Internet pagi     with(nolock) on pagi.cd_pagina           = me.cd_pagina
	  left outer join egisadmin.dbo.menu m                   with(nolock) on m.cd_menu                = me.cd_menu


        -----------------------------------------------------------------------------------------------------------------------------

    --Montagem de uma tabela auxiliar com os totais por etapa--

    -----------------------------------------------------------------------------------------------------------------------------
	select identity(int,1,1) as cd_auxiliar, * into #MontaCard from #AuxMontaCard order by cd_etapa

    --select * from #MontaCard

	--return

	--Totais---------------------------------------------------------------------------------------------------------------------
	   
	   select
	     cd_etapa,
		 count(cd_etapa)         as qt_etapa,
		 sum(isnull(vl_etapa,0)) as vl_etapa 

       into
	     #AuxTotal

       from
	      #MontaCard with(nolock)

       group by
	     cd_etapa

  -----------------------------------------------------------------------------------------------------------------------------
  --Consulta--
  -----------------------------------------------------------------------------------------------------------------------------

  if @cd_parametro = 1
  begin  

    if 1 = 2 and not exists (select * from #MontaCard)
    begin
       select 'Sem Registros' as Msg, 0 as Cod
       return
    end
    else
	begin
       
	   --Apresentação--------------------------------------------------------------------------------------------------------------

	   --2. Geral por Módulo------------------------------------------------------------------------------------------

	   select
	        --me.cd_modulo_etapa                               as cd_controle,
            c.cd_funil                                       as cd_controle,
            m.cd_modulo,
            c.cd_etapa,
            c.cd_ordem_etapa                                 as qt_ordem_etapa,
            e.nm_etapa,
	        --m.*,
 		    isnull(a.qt_etapa,0)                             as qt_etapa,
		    isnull(a.vl_etapa,0)                             as vl_etapa,
		    'R$ '+dbo.fn_formata_valor(isnull(a.vl_etapa,0)) as nm_valor_etapa,
		    isnull(c.ic_grafico_etapa,'N')                  as ic_grafico_etapa,
		    isnull(c.cd_form,0)                             as cd_form,
		    --isnull(me.cd_api,0)                              as cd_api,
		    --isnull(me.cd_menu,0)                             as cd_menu,
		    isnull(c.cd_rota,0)                             as cd_rota,
			--isnull(me.cd_relatorio,0)                        as cd_relatorio,
		    isnull(c.cd_link,0)                             as cd_link,
		    isnull(c.ic_documento_etapa,'N')                as ic_documento_etapa,
            isnull(c.ic_informativo,'N')                    as ic_informativo,
		    isnull(l.nm_endereco_link,'')                    as nm_endereco_link,
			isnull(l.nm_link,'')                             as nm_link,
	        isnull(l.nm_local_imagem_link,'')                as nm_local_imagem_link,
			isnull(c.cd_tipo_email,0)                       as cd_tipo_email,
			isnull(c.ic_valida_status,'N')                  as ic_valida_status,
            isnull(c.ic_edicao_etapa,'S')                   as ic_edicao_etapa,
			isnull(c.ic_status_etapa,'S')                   as ic_status_etapa,
			isnull(c.ic_detalhe_etapa,'S')                  as ic_detalhe_etapa

	     from 
		   -- egisadmin.dbo.modulo_etapa me with(nolock)
           --from 
           egisadmin.dbo.Funil_Metodo f
           left outer join egisadmin.dbo.segmento s               with(nolock) on s.cd_segmento = f.cd_segmento_mercado
           left outer join egisadmin.dbo.modulo m                 with(nolock) on m.cd_modulo   = f.cd_modulo
           left outer join egisadmin.dbo.Funil_Composicao_Etapa c with(nolock) on c.cd_metodo   = f.cd_metodo
           left outer join egisadmin.dbo.Etapa_Processo_Modulo e  with(nolock) on e.cd_etapa    = c.cd_etapa
  	       left outer join #MontaCard mc                          with(nolock) on mc.cd_modulo  = f.cd_modulo and
                                                                                  mc.cd_etapa   = c.cd_etapa   

	        left outer join #AuxTotal a                           with(nolock) on a.cd_etapa    = mc.cd_etapa
			left outer join egisadmin.dbo.etapa_link l            with(nolock) on l.cd_link     = c.cd_link

         where 
	        f.cd_modulo = case when @cd_modulo = 0 then f.cd_modulo else @cd_modulo end

	     order by
	        c.cd_ordem_etapa,
		    c.cd_etapa,
	        mc.cd_movimento desc

            --l,
            --select * from egisadmin.dbo.modulo_etapa where cd_modulo = 392
            --select @cd_modulo

          return
          

       end

	   ------------------------

    end


  end

  --Parâmetro 0--
  --Totais

   if @cd_parametro = 0
   begin

     if 1 = 2 and not exists (select * from #AuxTotal)
     begin
        select 'Sem Registros' as Msg, 0 as Cod
        return
     end
     else
	 begin
	    --2. Geral por Módulo------------------------------------------------------------------------------------------
	     select
	        c.cd_funil                              as cd_controle,
	        --m.*,
            m.cd_modulo,
            c.cd_etapa,
            c.cd_ordem_etapa                                 as qt_ordem_etapa,
            e.nm_etapa,
 		    isnull(a.qt_etapa,0)                             as qt_etapa,
		    isnull(a.vl_etapa,0)                             as vl_etapa,
		    'R$ '+dbo.fn_formata_valor(isnull(a.vl_etapa,0)) as nm_valor_etapa,
		    isnull(c.ic_grafico_etapa,'N')                  as ic_grafico_etapa,
		    isnull(c.cd_form,0)                             as cd_form,
		    --isnull(me.cd_api,0)                              as cd_api,
		    --isnull(me.cd_menu,0)                             as cd_menu,
		    isnull(c.cd_rota,0)                             as cd_rota,
			--isnull(me.cd_relatorio,0)                        as cd_relatorio,
		    isnull(c.cd_link,0)                             as cd_link,
		    isnull(c.ic_documento_etapa,'N')                as ic_documento_etapa,
            isnull(c.ic_informativo,'N')                    as ic_informativo,
		    isnull(l.nm_endereco_link,'')                    as nm_endereco_link,
			isnull(l.nm_link,'')                             as nm_link,
	        isnull(l.nm_local_imagem_link,'')                as nm_local_imagem_link,
			isnull(c.cd_tipo_email,0)                       as cd_tipo_email,
			isnull(c.ic_valida_status,'N')                  as ic_valida_status,
            isnull(c.ic_edicao_etapa,'S')                   as ic_edicao_etapa,
			isnull(c.ic_status_etapa,'S')                   as ic_status_etapa,
			isnull(c.ic_detalhe_etapa,'S')                  as ic_detalhe_etapa

	     from 
		    egisadmin.dbo.Funil_Metodo me with(nolock)
		 --   inner join #MontaCard m                    with(nolock) on m.cd_modulo  = me.cd_modulo and m.cd_etapa   = me.cd_etapa   
	  --      inner join #AuxTotal a                     with(nolock) on a.cd_etapa   = m.cd_etapa
			--left outer join egisadmin.dbo.etapa_link l with(nolock) on l.cd_link    = me.cd_link
            left outer join egisadmin.dbo.segmento s               with(nolock) on s.cd_segmento = me.cd_segmento_mercado
           left outer join egisadmin.dbo.modulo m                 with(nolock) on m.cd_modulo   = me.cd_modulo
           left outer join egisadmin.dbo.Funil_Composicao_Etapa c with(nolock) on c.cd_metodo   = me.cd_metodo
           left outer join egisadmin.dbo.Etapa_Processo_Modulo e  with(nolock) on e.cd_etapa    = c.cd_etapa
  	       left outer join #MontaCard mc                          with(nolock) on mc.cd_modulo  = me.cd_modulo and
                                                                                  mc.cd_etapa   = c.cd_etapa   

	        left outer join #AuxTotal a                           with(nolock) on a.cd_etapa    = mc.cd_etapa
			left outer join egisadmin.dbo.etapa_link l            with(nolock) on l.cd_link     = c.cd_link
         where 
	        me.cd_modulo = @cd_modulo

	     order by
	        c.cd_ordem_etapa,
		    c.cd_etapa
	        --m.cd_movimento desc

          --return

       end


    -----------------------------------------------------------------------------------------------------------------------------
--select * from crm_movimento

    --union all

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
--exec  pr_egis_kamban_processo
------------------------------------------------------------------------------

--sp_helptext pr_egis_modelo_procedure

go
/*
exec  pr_egis_kamban_processo '[{"cd_parametro": 0}]'
exec  pr_egis_kamban_processo '[{"cd_parametro": 1, "cd_modelo": 1, "cd_modulo": 392}]'      
exec  pr_egis_kamban_processo '[{"cd_parametro": 2, "cd_modelo": 1, "cd_modulo": 392}]'  
exec  pr_egis_kamban_processo '[{"cd_parametro": 3, "cd_modelo": 1, "cd_modulo": 392}]'  
exec  pr_egis_kamban_processo '[{"cd_parametro": 4, "cd_modelo": 1, "cd_modulo": 392}]'  
*/

go
------------------------------------------------------------------------------
GO
--USE EGISSQL_360
--select * from egisadmin.dbo.api_rota

--exec  pr_egis_kamban_processo  '[{"cd_parametro":1,"cd_empresa":360,"cd_usuario":4915,"cd_modulo":392,"cd_modelo":1,"dt_inicial":"2025-10-01","dt_final":"2025-10-31","cd_metodo":0}]'

--exec pr_egis_kamban_processo '[{"cd_parametro":1,"cd_modelo":1,"cd_modulo":392}]'


--exec  pr_egis_kamban_processo '[{"cd_parametro": 2, "cd_modelo": 1, "cd_modulo": 392}]'  

--exec  pr_egis_kamban_processo '[{"cd_parametro": 3, "cd_modelo": 1, "cd_modulo": 392}]'  

--exec  pr_egis_kamban_processo '[{"cd_parametro": 4, "cd_modelo": 1, "cd_modulo": 392}]'  

