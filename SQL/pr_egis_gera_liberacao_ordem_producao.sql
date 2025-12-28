--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_gera_liberacao_ordem_producao' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_gera_liberacao_ordem_producao

GO

--SET QUOTED_IDENTIFIER ON;
--GO

--IF OBJECT_ID('pr_egis_gera_liberacao_ordem_producao_debug','P') IS NOT NULL
--    DROP PROCEDURE pr_egis_gera_liberacao_ordem_producao_debug;
--GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_gera_liberacao_ordem_producao
-------------------------------------------------------------------------------
-- pr_egis_gera_liberacao_ordem_producao
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
create or alter procedure pr_egis_gera_liberacao_ordem_producao
@cd_usuario   int = 0,
@cd_processo  int = 0,
@cd_parametro int = 0
------------------------------------------------------------------------------
--with encryption


as

-- ver nível atual
--SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME();

-- se < 130, ajustar:
--ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130;

--return

--set @json = isnull(@json,'')

-- SET NOCOUNT ON;
-- SET XACT_ABORT ON;

-- BEGIN TRY
 
-- /* 1) Validar payload - parameros de Entrada da Procedure */
-- IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
--            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

-- /* 2) Normalizar: aceitar array[0] ou objeto */
-- IF JSON_VALUE(@json, '$[0]') IS NOT NULL
--            SET @json = JSON_QUERY(@json, '$[0]'); -- pega o primeiro elemento


--set @json = replace(
--             replace(
--               replace(
--                replace(
--                  replace(
--                    replace(
--                      replace(
--                        replace(
--                          replace(
--                            replace(
--                              replace(
--                                replace(
--                                  replace(
--                                    replace(
--                                    @json, CHAR(13), ' '),
--                                  CHAR(10),' '),
--                                ' ',' '),
--                              ':\\\"',':\\"'),
--                            '\\\";','\\";'),
--                          ':\\"',':\\\"'),
--                        '\\";','\\\";'),
--                      '\\"','\"'),
--                    '\"', '"'),
--                  '',''),
--                '["','['),
--              '"[','['),
--             ']"',']'),
--          '"]',']') 


declare @cd_empresa          int
--declare @cd_parametro        int
declare @cd_documento        int = 0
declare @cd_item_documento   int
--declare @cd_usuario          int 
declare @dt_hoje             datetime
declare @dt_inicial          datetime 
declare @dt_final            datetime
declare @cd_ano              int = 0
declare @cd_mes              int = 0
declare @cd_modelo           int = 0
--declare @cd_processo         int = 0

----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
--set @cd_parametro      = 0
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

--select                     

-- 1                                                   as id_registro,
-- IDENTITY(int,1,1)                                   as id,
-- valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
-- valores.[value]                                     as valor                    
                    
-- into #json                    
-- from                
--   openjson(@json)root                    
--   cross apply openjson(root.value) as valores      
   
----------------------------------------------------------------------------------------------

--select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
--select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
--select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
--select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
--select @dt_final               = valor from #json where campo = 'dt_final'             
--select @cd_modelo              = valor from #json where campo = 'cd_modelo'             
--select @cd_processo            = valor from #json where campo = 'cd_processo'  

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

  --processo_producao_liberacao

  --
  declare @cd_controle int = 0

  select
    @cd_controle = max(cd_controle)
  from
    processo_producao_liberacao

  set @cd_controle = isnull(@cd_controle,0) + 1

  select
    @cd_controle               as cd_controle,
    @cd_processo               as cd_processo,   
    cast('' as varchar)        as ds_observacao_liberacao,
    @dt_hoje                   as dt_liberacao,
    @cd_usuario                as cd_usuario_liberacao,
    'N'                        as ic_email_liberacao,
    null                       as cd_especie_embalagem,
    null                       as qt_volume,
    null                       as qt_produto,
    null                       as qt_peso_bruto,
    null                       as nm_medida_embalagem,
    null                       as nm_obs_linha_embalagem,
    null                       as cd_especie_embalagem1,
    null                       as cd_especie_embalagem2,
    null                       as cd_especie_embalagem3,
    null                       as qt_volume1,
    null                       as qt_volume2,
    null                       as qt_volume3,
    null                       as qt_produto1,
    null                       as qt_produto2,
    null                       as qt_produto3,
    null                       as qt_peso_bruto1,
    null                       as qt_peso_bruto2,
    null                       as qt_peso_bruto3,
    null                       as nm_medida1,
    null                       as nm_medida2,
    null                       as nm_medida3,
    null                       as nm_obs_linha_embalagem1,
    null                       as nm_obs_linha_embalagem2,
    null                       as nm_obs_linha_embalagem3,
    @cd_usuario                as cd_usuario,
    getdate()                  as dt_usuario,
    null                       as qt_volume_total,
    null                       as qt_total_produto,
    null                       as qt_peso_total,
    null                       as qt_etiqueta,
    null                       as cd_numero_etiqueta,
    null                       as cd_transportadora,
    null                       as dt_coleta_processo,
    null                       as nm_coleta_processo,
    null                       as cd_coleta_processo,
    null                       as vl_frete_processo,
    null                       as qt_peso_cubado,
    null                       as qt_dias_previsao_entrega

into
  #Liberacao

---------------------------------------
insert into Processo_Producao_Liberacao
select * from #Liberacao
---------------------------------------------------------------

--ordem_expedicao
declare @cd_ordem_expedicao int = 0

select
  @cd_ordem_expedicao = max(cd_ordem_expedicao)
from
  ordem_expedicao

set @cd_ordem_expedicao = isnull(@cd_ordem_expedicao,0) + 1

select
  top 1
  @cd_ordem_expedicao       as cd_ordem_expedicao,
  @dt_hoje                  as dt_ordem_expedicao,
  pp.cd_cliente             as cd_cliente,
  ppl.cd_transportadora     as cd_transportadora,
  ppl.cd_coleta_processo    as cd_coleta,
  cast('Ordem : '+cast(@cd_processo as varchar(12)) as nvarchar(max))  as ds_observacao,
  'N'                       as ic_material_embalado,
  'N'                       as ic_material_com_etiqueta,
  'N'                       as ic_cod_barras_itens,
  null                      as nm_motorista,
  null                      as cd_documento_motorista,
  null                      as cd_placa_veiculo,
  null                      as hr_chegada,
  ppl.dt_coleta_processo    as dt_coleta,
  @cd_usuario               as cd_usuario_inclusao,
  getdate()                 as dt_usuario_inclusao,
  @cd_usuario               as cd_usuario,
  getdate()                 as dt_usuario,
  null                      as hr_saida

into #ordem_expedicao
from
  processo_producao pp
  inner join processo_producao_liberacao ppl on ppl.cd_processo = pp.cd_processo

where
  pp.cd_processo = @cd_processo


  --delete from processo_producao_liberacao where cd_usuario = 113

  --select * from processo_producao_liberacao

insert into ordem_expedicao
select * from #ordem_expedicao


select
  @cd_ordem_expedicao      as cd_ordem_expedicao,
  identity(int,1,1)        as cd_item,
  pp.cd_produto,
  p.nm_produto,
  p.cd_mascara_produto,
  pp.qt_planejada_processo as qt_item,
  um.sg_unidade_medida     as sg_unidade,
   0                       as qt_volume,
   0                       as qt_peso_bruto,
  cast('' as varchar)      as ds_obs_item,
  @cd_usuario              as cd_usuario_inclusao,
  getdate()                as dt_usuario_inclusao,
  @cd_usuario              as cd_usuario,
  getdate()                as dt_usuario

into
  #ordem_expedicao_item

from
  processo_producao pp
  left outer join produto p              on p.cd_produto         = pp.cd_produto
  left outer join unidade_medida um on um.cd_unidade_medida = p.cd_unidade_medida

where
  pp.cd_processo = @cd_processo

insert into ordem_expedicao_item
select * from #ordem_expedicao_item
-------------------------------------


drop table #ordem_expedicao


  select 'Geração da Liberação da Ordem de Produção '+cast(@cd_processo as varchar(12)) + ', realizada com Sucesso !' AS Msg
  return

end


/* Padrão se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ação mapeada para cd_parametro=', @cd_parametro) AS Msg;
   
 --END TRY
 --   BEGIN CATCH
 --       DECLARE
 --           @errnum   INT          = ERROR_NUMBER(),
 --           @errmsg   NVARCHAR(4000) = ERROR_MESSAGE(),
 --           @errproc  NVARCHAR(128) = ERROR_PROCEDURE(),
 --           @errline  INT          = ERROR_LINE(),
 --           @fullmsg  NVARCHAR(2048);



 --        -- Monta a mensagem (THROW aceita até 2048 chars no 2º parâmetro)
 --   SET @fullmsg =
 --         N'Erro em pr_egis_modelo_procedure ('
 --       + ISNULL(@errproc, N'SemProcedure') + N':'
 --       + CONVERT(NVARCHAR(10), @errline)
 --       + N') #' + CONVERT(NVARCHAR(10), @errnum)
 --       + N' - ' + ISNULL(@errmsg, N'');

 --   -- Garante o limite do THROW
 --   SET @fullmsg = LEFT(@fullmsg, 2048);

 --   -- Relança com contexto (state 1..255)
 --   THROW 50000, @fullmsg, 1;

 --       -- Relança erro com contexto
 --       --THROW 50000, CONCAT('Erro em pr_egis_modelo_procedure (',
 --       --                    ISNULL(@errproc, 'SemProcedure'), ':',
 --       --                    @errline, ') #', @errnum, ' - ', @errmsg), 1;
 --   END CATCH
 --select 'Geração da Liberação da Ordem de Produção '+cast(@cd_processo as varchar(12)) + ', realizado com Sucesso !'
---------------------------------------------------------------------------------------------------------------------------------------------------------    
go


--select * from ordem_expedicao
--select * from ordem_expedicao_item
--select * from processo_producao_liberacao

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_gera_liberacao_ordem_producao
------------------------------------------------------------------------------

--sp_helptext pr_egis_gera_liberacao_ordem_producao
--exec pr_egis_gera_liberacao_ordem_producao 1,1,1


/*
exec  pr_egis_gera_liberacao_ordem_producao '[{"cd_parametro": 0}]'
exec  pr_egis_gera_liberacao_ordem_producao '[{"cd_parametro": 1, "cd_processo": 1, "cd_usuario": 113}]'                                           ]'
*/

