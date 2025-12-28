--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_ativo_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_ativo_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_ativo_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_ativo_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_ativo_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_ativo_processo_modulo
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
--                   COMPRAS
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_ativo_processo_modulo
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

----------------------------------------------------------------------------------------------------

declare @cd_empresa                     int = 0
declare @cd_parametro                   int = 0
declare @cd_documento                   int = 0
declare @cd_item_documento              int = 0
declare @cd_usuario                     int = 0
declare @dt_hoje                        datetime
declare @dt_inicial                     datetime 
declare @dt_final                       datetime
declare @cd_ano                         int = 0
declare @cd_mes                         int = 0
declare @cd_modelo                      int = 0

----------------------------------------------------------------------------------------------------------------
--fornecedor_produto
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

--------------------------------------------------------------------------------------------
--Definição das Variáveis
--------------------------------------------------------------------------------------------
declare @cd_cliente          int = 0
declare @cd_bem              INT            = NULL,
        @nm_bem              NVARCHAR(200)  = NULL,
        @ds_bem              NVARCHAR(MAX)  = NULL,
        @cd_grupo_bem        INT            = NULL,
        @cd_patrimonio_bem   NVARCHAR(50)   = NULL,
        @nm_registro_bem     NVARCHAR(50)   = NULL,
        @nm_serie_bem        NVARCHAR(50)   = NULL,
        @nm_marca_bem        NVARCHAR(100)  = NULL,
        @nm_modelo_bem       NVARCHAR(100)  = NULL,
        @qt_capacidade_bem   DECIMAL(18,4)  = NULL,
        @qt_voltagem_bem     INT            = NULL,
        @vl_aquisicao_bem    DECIMAL(18,2)  = NULL,
        @dt_aquisicao_bem    DATE           = NULL,
        @nm_obs_item         NVARCHAR(1000) = NULL,
        @cd_produto          INT            = NULL
      
--------------------------------------------------------------------------------------------------

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
select @cd_bem                 = valor from #json where campo = 'cd_bem'  
select @nm_bem                 = valor from #json where campo = 'nm_bem'  
select @ds_bem                 = valor from #json where campo = 'ds_bem'  
select @cd_grupo_bem           = valor from #json where campo = 'cd_grupo_bem'  
select @cd_patrimonio_bem      = valor from #json where campo = 'cd_patrimonio_bem'  
select @nm_registro_bem        = valor from #json where campo = 'nm_registro_bem'  
select @nm_serie_bem           = valor from #json where campo = 'nm_serie_bem'  
select @nm_marca_bem           = valor from #json where campo = 'nm_marca_bem'  
select @nm_modelo_bem          = valor from #json where campo = 'nm_modelo_bem'  
select @qt_capacidade_bem      = valor from #json where campo = 'qt_capacidade_bem'  
select @qt_voltagem_bem        = valor from #json where campo = 'qt_voltagem_bem' 
select @vl_aquisicao_bem       = valor from #json where campo = 'vl_aquisicao_bem'  
select @dt_aquisicao_bem       = valor from #json where campo = 'dt_aquisicao_bem'  
select @nm_obs_item            = valor from #json where campo = 'nm_obs_item '  
select @cd_produto             = valor from #json where campo = 'cd_produto'  

-------------------------------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

--------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro = ISNULL(@cd_parametro,0)
set @cd_cliente   = isnull(@cd_cliente,0)
---------------------------------------------------------------------------------------------------------------------------------------------------------    

IF ISNULL(@cd_parametro,0) = 0
BEGIN

  select 
    'Sucesso'     as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final

  RETURN;

END
    
-- Consultas do Bens do Ativo----------------------

if @cd_parametro = 1
begin
  ----
  select
  c.cd_cliente,
  c.nm_fantasia_cliente,
  c.nm_razao_social_cliente,
  cg.nm_cliente_grupo,
  b.cd_bem,
  b.nm_bem,
  b.nm_registro_bem,
  b.cd_patrimonio_bem,
  b.nm_marca_bem,
  cg.nm_cliente_grupo

from
  bem b
  inner join cliente c             on c.cd_cliente        = b.cd_cliente
  left outer join vendedor v       on v.cd_vendedor       = c.cd_vendedor
  left outer join cliente_grupo cg on cg.cd_cliente_grupo = c.cd_cliente_grupo

where
  b.cd_cliente = case when @cd_cliente = 0 then b.cd_cliente else @cd_cliente end

order by
  c.nm_fantasia_cliente



  
  ----
  RETURN
end

-------------------------------------------------------------------------------------------
--Consulta de Ativos em Estoque
-------------------------------------------------------------------------------------------

if @cd_parametro = 2
begin
--  select @cd_parametro
  
  select
    gp.nm_grupo_produto,
    p.cd_produto,
    p.cd_mascara_produto,
    p.nm_fantasia_produto,
    p.nm_produto,
    um.sg_unidade_medida,
    ps.qt_saldo_reserva_produto,
    mp.nm_marca_produto,
    p.nm_modelo_produto,
    p.ds_produto
    

  from
    grupo_produto gp
    left outer join produto p         on p.cd_grupo_produto   = gp.cd_grupo_produto
    left outer join marca_produto mp  on mp.cd_marca_produto  = p.cd_marca_produto
    left outer join unidade_medida um on um.cd_unidade_medida = p.cd_unidade_medida
    left outer join produto_saldo ps  on ps.cd_produto        = p.cd_produto and ps.cd_fase_produto = p.cd_fase_produto_baixa


  where
    
    isnull(gp.ic_ativo_fixo,'N') = 'S'
    and
    isnull(ps.qt_saldo_reserva_produto,0)>0
  
  
  
  RETURN

end

--------------------------------------------------------------------------------------------
--Geração da Solicitação de Comodato
--------------------------------------------------------------------------------------------

if @cd_parametro = 3
begin
  select @cd_parametro
  RETURN
end


if @cd_parametro = 4
begin
  --select * from bem

  select
    b.cd_patrimonio_bem,
    b.nm_registro_bem,
    b.cd_bem,
    b.nm_bem,
    1                                           as qt_bem,
    mb.nm_modelo,
    case when isnull(mp.nm_marca_produto,'')<>'' then
      mp.nm_marca_produto
    else
      b.nm_marca_bem
    end                                          as nm_marca_bem,
    b.nm_modelo_bem,
    b.qt_capacidade_bem, 
    b.qt_voltagem_bem,
    b.ds_bem,
    b.nm_obs_item
    

  from
    bem b
    inner join produto p             on p.cd_produto        = b.cd_produto
    inner join produto_saldo ps      on ps.cd_produto       = p.cd_produto and ps.cd_fase_produto = p.cd_fase_produto_baixa
    left outer join marca_produto mp on mp.cd_marca_produto = b.cd_marca_produto
    left outer join grupo_bem gb     on gb.cd_grupo_bem     = b.cd_grupo_bem
    left outer join modelo_bem mb    on mb.cd_modelo        = b.cd_modelo

  where
    isnull(ps.qt_saldo_reserva_produto,0)>0
    and
    isnull(b.cd_cliente,0) = 0
    and
    b.dt_baixa_bem is null

  return

end

--------------------------------------------------------------------------------------------


if @cd_parametro = 40
begin

  DECLARE @search NVARCHAR(100) = NULL;

  IF @json IS NOT NULL
  BEGIN
    SELECT @search = TRY_CONVERT(NVARCHAR(100), JSON_VALUE(J.value,'$.q'))
    FROM OPENJSON(@json) AS J;
  END

  SELECT TOP (200)
      g.cd_grupo_bem   AS id,
      g.nm_grupo_bem   AS text
  FROM dbo.grupo_bem g
  WHERE @search IS NULL
        OR g.nm_grupo_bem LIKE CONCAT('%', @search, '%')
        OR CONVERT(VARCHAR(10), g.cd_grupo_bem) = @search
  ORDER BY g.nm_grupo_bem; 
  return
end

/* 50 = CREATE */
  IF @cd_parametro = 50
  BEGIN
    BEGIN TRY
      BEGIN TRAN;

      DECLARE @novo_cd_bem INT = (SELECT ISNULL(MAX(cd_bem),0)+1 FROM dbo.bem WITH (TABLOCKX));
      INSERT INTO dbo.bem
      (
        cd_bem, nm_bem, ds_bem, cd_grupo_bem,
        cd_patrimonio_bem, nm_registro_bem, nm_serie_bem,
        nm_marca_bem, nm_modelo_bem,
        qt_capacidade_bem, qt_voltagem_bem,
        vl_aquisicao_bem, dt_aquisicao_bem,
        nm_obs_item, cd_produto, cd_cliente
      )
      VALUES
      (
        @novo_cd_bem, @nm_bem, @ds_bem, @cd_grupo_bem,
        @cd_patrimonio_bem, @nm_registro_bem, @nm_serie_bem,
        @nm_marca_bem, @nm_modelo_bem,
        @qt_capacidade_bem, @qt_voltagem_bem,
        @vl_aquisicao_bem, @dt_aquisicao_bem,
        @nm_obs_item, @cd_produto, @cd_cliente
      );

      COMMIT;
      SELECT ok = 1, cd_bem = @novo_cd_bem;
    END TRY
    BEGIN CATCH
      IF @@TRANCOUNT > 0 ROLLBACK;
      SELECT ok = 0, erro = ERROR_MESSAGE();
    END CATCH
    RETURN;
  END

  /* 60 = UPDATE */
  IF @cd_parametro = 60
  BEGIN
    IF @cd_bem IS NULL
    BEGIN
      SELECT ok=0, erro='cd_bem obrigatório para atualização.'; RETURN;
    END

    UPDATE b SET
      nm_bem = @nm_bem,
      ds_bem = @ds_bem,
      cd_grupo_bem = @cd_grupo_bem,
      cd_patrimonio_bem = @cd_patrimonio_bem,
      nm_registro_bem = @nm_registro_bem,
      nm_serie_bem = @nm_serie_bem,
      nm_marca_bem = @nm_marca_bem,
      nm_modelo_bem = @nm_modelo_bem,
      qt_capacidade_bem = @qt_capacidade_bem,
      qt_voltagem_bem = @qt_voltagem_bem,
      vl_aquisicao_bem = @vl_aquisicao_bem,
      dt_aquisicao_bem = @dt_aquisicao_bem,
      nm_obs_item = @nm_obs_item,
      cd_produto = @cd_produto,
      cd_cliente = @cd_cliente
    FROM dbo.bem b
    WHERE b.cd_bem = @cd_bem;

    SELECT ok = 1, cd_bem = @cd_bem;
    RETURN;
  END

  /* 70 = DELETE */
  IF @cd_parametro = 70
  BEGIN
    IF @cd_bem IS NULL
    BEGIN
      SELECT ok=0, erro='cd_bem obrigatório para exclusão.'; RETURN;
    END

    DELETE FROM dbo.bem WHERE cd_bem = @cd_bem;
    SELECT ok = 1, cd_bem = @cd_bem;
    RETURN;
  END
------------------------------------------------------------------------------------

if @cd_parametro = 999
begin
  select @cd_parametro
  RETURN
end

/* Padrão se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ação mapeada para cd_parametro=', @cd_parametro) AS Msg;
------------------------------------------------------------------------------------

 END TRY
    BEGIN CATCH
        DECLARE
            @errnum   INT            = ERROR_NUMBER(),
            @errmsg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @errproc  NVARCHAR(128)  = ERROR_PROCEDURE(),
            @errline  INT            = ERROR_LINE(),
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
--exec  pr_egis_ativo_processo_modulo
------------------------------------------------------------------------------
--pr_egis_compras_processo_modulo
--sp_helptext pr_egis_modelo_procedure

go

--use egissql_rubio

--go

--insert into tipo_solicitacao_ativo
--select * from egissql_342.dbo.tipo_solicitacao_ativo
--delete from solicitacao_ativo
--select * from solicitacao_ativo

/*
exec  pr_egis_ativo_processo_modulo '[{"cd_parametro": 0}]'
exec  pr_egis_ativo_processo_modulo '[{"cd_parametro": 1, "cd_modelo": 1}]'  
exec  pr_egis_ativo_processo_modulo '[{"cd_parametro": 2, "cd_fornecedor": 1}]' 
exec  pr_egis_ativo_processo_modulo '[{"cd_parametro": 4, "cd_fornecedor": 1}]' 
exec  pr_egis_ativo_processo_modulo '[{"cd_parametro": 40, "q": ""}]'  
'
'
*/
--use egissql_377

--USE EGISSQL_363
--go
------------------------------------------------------------------------------
GO

--use egissql_rubio

--update
--  egisadmin.dbo.menu
--  set
--    ic_json_parametro = 'S',
--    cd_form_modal = 7,
--    ic_selecao_registro = 'S',
--cd_parametro = 2
--where
--  cd_menu = 8787

--update
--  egisadmin.dbo.menu
--  set
--    ic_json_parametro = 'S',
--    ic_selecao_registro = 'S',
--cd_parametro = 4
--where
--  cd_menu = 8789

  --solicitacao_ativo

  --pr_gera_pedido_venda_solicitacao_ativo