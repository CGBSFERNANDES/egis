--BANCO DO CLIENTE--

--USE EGISSQL_360
--GO

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_pesquisa_mapa_atributo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_pesquisa_mapa_atributo

GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_pesquisa_mapa_atributo
-------------------------------------------------------------------------------
-- pr_egis_pesquisa_mapa_atributo
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
--                   Pesquisa de Atributos no Admin
--
--Data             : 01.01.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_pesquisa_mapa_atributo
@json nvarchar(max) = ''

--with encryption

as


SET NOCOUNT ON;

set @json = isnull(@json,'')

 BEGIN TRY

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
declare @cd_tabela           int = 0
declare @nome_procedure      varchar(100) = ''
declare @cd_menu_id          int = 0

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
select @cd_tabela              = valor from #json where campo = 'cd_tabela'             
select @cd_menu_id             = valor from #json where campo = 'cd_menu_id'  
select @nome_procedure         = valor from #json where campo = 'nome_procedure'  

--------------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro = ISNULL(@cd_parametro,0)
set @cd_tabela    = isnull(@cd_tabela,0)


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

SELECT atributos.nm_atributo
into
  #Atributo_Pesquisa

FROM OPENJSON(@json)
WITH (
  dados NVARCHAR(MAX) AS JSON
) AS bloco
CROSS APPLY OPENJSON(bloco.dados)
WITH (
  nm_atributo NVARCHAR(100) '$.nm_atributo'
) AS atributos;

--select * from #Atributo_Pesquisa

   SELECT
      distinct
      --t.nm_tabela,
      --a.cd_tabela,
      --a.cd_atributo,
      a.nm_atributo,
      max(a.ds_atributo)                       as nm_titulo,
      max(a.cd_natureza_atributo)              as cd_natureza_atributo,
      max(n.nm_natureza_atributo)              as nm_natureza_atributo,
      max(n.nm_formato)                        as nm_formato,
      max(n.nm_datatype)                       as nm_datatype
                                               
  FROM
    egisadmin.dbo.atributo a
    inner join egisadmin.dbo.tabela t                      on t.cd_tabela = a.cd_tabela
    left outer join egisadmin.dbo.natureza_atributo n on n.cd_natureza_atributo = a.cd_natureza_atributo
  
  WHERE
    a.nm_atributo IN ( select ap.nm_atributo from #Atributo_Pesquisa ap where ap.nm_atributo = a.nm_atributo )
    and
    isnull(ds_atributo,'')<>''

  group by
    a.nm_atributo

  order by
    a.nm_atributo

  return

end

--Atributos da Tabela do Admin --

if @cd_parametro = 2
begin
    SELECT
      t.nm_tabela,
      a.cd_tabela,
      a.cd_atributo,
      a.nm_atributo,
      a.ds_atributo                     as nm_titulo,
      n.nm_natureza_atributo,
      n.nm_formato,
      n.nm_datatype

  FROM
    egisadmin.dbo.atributo a
    inner join egisadmin.dbo.tabela t                      on t.cd_tabela = a.cd_tabela
    left outer join egisadmin.dbo.natureza_atributo n on n.cd_natureza_atributo = a.cd_natureza_atributo

  WHERE a.cd_tabela = @cd_tabela
  ORDER BY a.cd_tabela, a.cd_atributo --nm_atributo;
  return

end

--Colunas das Procedures--- 

if @cd_parametro = 3
begin
  --select * from meta_procedure_colunas

SELECT 
  distinct 
  id,
  nome_coluna as nm_atributo,
  cd_menu_id,
  contagem,
  soma,
  titulo_exibicao

into
  #Meta_Atributo_Pesquisa
from
  egisadmin.dbo.meta_procedure_colunas

where
  cd_menu_id     = case when @cd_menu_id = 0      then cd_menu_id     else @cd_menu_id     end
  and
  nome_procedure = case when @nome_procedure = '' then nome_procedure else @nome_procedure end

--select * from #Meta_Atributo_Pesquisa
--return

--select * from #Atributo_Pesquisa

   SELECT
      distinct
      --t.nm_tabela,
      --a.cd_tabela,
      --a.cd_atributo,
      m.id,
      m.cd_menu_id,
      max(mn.nm_menu_titulo)                    as nm_menu_titulo,
      m.nm_atributo,
      max(case when isnull(m.titulo_exibicao,'')<>'' then
            m.titulo_exibicao
          else 
          a.ds_atributo
          end )                                as nm_titulo,
      max(a.cd_natureza_atributo)              as cd_natureza_atributo,
      max(n.nm_natureza_atributo)              as nm_natureza_atributo,
      max(n.nm_formato)                        as nm_formato,
      max(n.nm_datatype)                       as nm_datatype,
      max(case when m.contagem=1 then 'S' else 'N' end)
                                               as ic_contagem,
      max(case when m.soma=1 then 'S' else 'N' end )
                                               as ic_soma
                                               
  FROM
    #Meta_Atributo_Pesquisa m
    inner join egisadmin.dbo.atributo a                    on a.nm_atributo = m.nm_atributo
    inner join egisadmin.dbo.tabela t                      on t.cd_tabela   = a.cd_tabela
    left outer join egisadmin.dbo.natureza_atributo n      on n.cd_natureza_atributo = a.cd_natureza_atributo
    left outer join egisadmin.dbo.menu mn                  on mn.cd_menu    = m.cd_menu_id
  
  WHERE
    a.nm_atributo IN ( select ap.nm_atributo from #Meta_Atributo_Pesquisa ap where ap.nm_atributo = a.nm_atributo )
    and
    isnull(ds_atributo,'')<>''

  group by
      m.id,
      m.cd_menu_id,
      m.nm_atributo
  order by
    m.nm_atributo

  return

end

--Colunas dos Filtros e dos Parâmetros das Procedures--- 


if @cd_parametro = 4

begin
  --select * from meta_procedure_parametros

SELECT 
  distinct 
  mp.id,
  mp.nome_procedure              as nome_procedure,
  mp.nome_parametro              as nm_atributo,
  case when isnull(mp.titulo_parametro,'')='' then
    replace(mp.nome_parametro,'@','')
  else
    isnull(mp.titulo_parametro,'')
  end                            as nm_titulo_parametro,
  mp.titulo_parametro            as nm_titulo_validacao,
  mp.tipo_parametro

into
  #Meta_Atributo_Filtro

from
  egisadmin.dbo.meta_procedure_parametros mp
  inner join egisadmin.dbo.meta_procedures m on m.nome_procedure = mp.nome_procedure
  --select * from egisadmin.dbo.meta_procedures
where
  --m.cd_menu_id     = case when @cd_menu_id = 0      then m.cd_menu_id     else @cd_menu_id     end
  --and
  m.nome_procedure = case when @nome_procedure = '' then m.nome_procedure else @nome_procedure end

--select * from #Meta_Atributo_Filtro
--return

--select * from #Atributo_Pesquisa

   SELECT
      distinct
      --t.nm_tabela,
      --a.cd_tabela,
      --a.cd_atributo,
      m.id,
      --m.cd_menu_id,
      m.nm_atributo,
      max( case when isnull(nm_titulo_validacao,'') = '' and isnull(ds_atributo,'') = '' then
             nm_titulo_parametro
           else
             case when isnull(ds_atributo,'') <> '' and nm_titulo_parametro = '' then ds_atributo
             else
               nm_titulo_parametro
             end
           end
      )                                        as titulo_parametro,
      max( case when isnull(nm_titulo_validacao,'') = '' and isnull(ds_atributo,'') = '' then
             nm_titulo_parametro
           else
             case when isnull(ds_atributo,'') <> '' and nm_titulo_parametro = '' then ds_atributo
             else
               nm_titulo_parametro
             end
           end
      )                                        as nm_titulo,
      
      --max(a.ds_atributo)                       as nm_titulo,
      max(a.cd_natureza_atributo)              as cd_natureza_atributo,
      max(n.nm_natureza_atributo)              as nm_natureza_atributo,
      max(n.nm_formato)                        as nm_formato,
      max(n.nm_datatype)                       as nm_datatype,
      m.nome_procedure
                  
  into #MFiltroFinal
  
  FROM
    #Meta_Atributo_Filtro m
    left outer join egisadmin.dbo.atributo a               on replace(a.nm_atributo,'@','') = m.nm_atributo
    left outer join egisadmin.dbo.tabela t                 on t.cd_tabela                   = a.cd_tabela
    left outer join egisadmin.dbo.natureza_atributo n      on n.cd_natureza_atributo        = a.cd_natureza_atributo
  
  --WHERE
  --  a.nm_atributo IN ( select ap.nm_atributo from #Meta_Atributo_Filtro ap where ap.nm_atributo = a.nm_atributo )
  --  and
  --  isnull(ds_atributo,'')<>''

  group by
      m.id,
      --m.cd_menu_id,
      m.nm_atributo,
      m.nome_procedure,
      m.nm_titulo_parametro,
      m.nm_titulo_validacao

  order by
    m.nm_atributo

  --update--
  -- Atualiza os títulos automaticamente
  UPDATE mp
  SET
    mp.titulo_parametro = ap.titulo_parametro
  FROM 
    egisadmin.dbo.meta_procedure_parametros mp
    JOIN #MFiltroFinal ap ON mp.nome_procedure = ap.nome_procedure AND mp.nome_parametro = ap.nm_atributo 
  WHERE
    ISNULL(mp.titulo_parametro, '') = ''
    AND ISNULL(ap.nm_titulo, '') <> ''
    and
    mp.titulo_parametro <> ap.titulo_parametro

  select * from #MFiltroFinal order by nm_atributo

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
          N'Erro em pr_egis_pesquisa_mapa_atributo ('
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




go

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_pesquisa_mapa_atributo '[{"cd_chave_acesso" : "35251033092357000104550020000015821000022823"}]'
------------------------------------------------------------------------------
/*
exec  pr_egis_pesquisa_mapa_atributo '[{"cd_parametro": 0}]'
exec  pr_egis_pesquisa_mapa_atributo '[{"cd_parametro": 1},   "dados": [
    { "nm_atributo": "nm_grupo_conta" },
    { "nm_atributo": "dt_usuario" },
    { "nm_atributo": "nm_obs_plano_conta" }
  ]]'
exec  pr_egis_pesquisa_mapa_atributo '[{"cd_parametro": 2, "cd_tabela": 201}]'                                           ]'
*/



--select * from meta_procedure_parametros where cd_menu_id = 8678
--use egissql_358

--exec pr_egis_pesquisa_mapa_atributo '[{"cd_parametro": 3,
--"cd_menu_id": 8517, "nome_procedure": "pr_dashboard_modulo_gestao_caixa"}]'

--update
--  meta_procedure_colunas

--  set
--   titulo_exibicao = 'Código'
--where
--  id=1455

--select * from meta_procedure_colunas where cd_menu_id = 8748

--exec pr_egis_pesquisa_mapa_atributo '[{"cd_parametro": 4, "nome_procedure": "pr_dashboard_modulo_gestao_caixa"}]'

--select * from meta_procedure_parametros where nome_procedure = 'pr_egis_vendas_semanal'
--{
--  "dados": [
--    { "nm_atributo": "nm_grupo_conta" },
--    { "nm_atributo": "dt_usuario" },
--    { "nm_atributo": "nm_obs_plano_conta" }
--  ]
--}


--EXEC pr_egis_pesquisa_mapa_atributo '[
--  { "cd_parametro": 1, "cd_tabela": 0 },
 
--  {
--    "dados": [
--      { "nm_atributo": "nm_grupo_conta" },
--      { "nm_atributo": "dt_usuario" },
--      { "nm_atributo": "nm_obs_plano_conta" }
--    ]
--  }
--]';

--exec pr_egis_pesquisa_mapa_atributo '
--[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 1,
--        "cd_tabela": 0
--    },
--    {
--        "dados": [
--            {
--                "nm_atributo": "cd_xml_nota"
--            },
--            {
--                "nm_atributo": "cd_tipo_xml"
--            },
--            {
--                "nm_atributo": "cd_identificacao"
--            },
--            {
--                "nm_atributo": "dt_emissao_nota"
--            },
--            {
--                "nm_atributo": "dt_entrada_nota"
--            },
--            {
--                "nm_atributo": "cd_chave_acesso"
--            },
--            {
--                "nm_atributo": "cd_usuario_inclusao"
--            },
--            {
--                "nm_atributo": "dt_usuario_inclusao"
--            },
--            {
--                "nm_atributo": "ds_xml"
--            },
--            {
--                "nm_atributo": "ds_xml_preview"
--            }
--        ]
--    }
--]'

--use egissql_rubio
--go


--select * from meta_procedures where nome_procedure = 'pr_consulta_operacao_diaria_producao'
--select * from egisadmin.dbo.menu where cd_menu = 7298

--7298
--pr_consulta_acessos_usuario_grupo 

--select * from meta_procedure_colunas where nome_procedure = 'pr_venda_cliente1'
--select * from meta_procedure_parametros where nome_procedure = 'pr_consulta_operacao_diaria_producao'