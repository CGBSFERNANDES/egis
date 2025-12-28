--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_cliente_empresa' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_cliente_empresa

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_cliente_empresa','P') IS NOT NULL
    DROP PROCEDURE pr_egis_cliente_empresa;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_cliente_empresa
-------------------------------------------------------------------------------
-- pr_egis_cliente_empresa
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
--                   Cliente Empresa
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_cliente_empresa
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


declare @cd_empresa                  int
declare @cd_parametro                int
declare @cd_documento                int = 0
declare @cd_item_documento           int
declare @cd_usuario                  int 
declare @dt_hoje                     datetime
declare @dt_inicial                  datetime 
declare @dt_final                    datetime
declare @cd_ano                      int = 0
declare @cd_mes                      int = 0
declare @cd_modelo                   int = 0
declare @cd_cliente                  int = 0  
declare @cd_usuario_inclusao         int = 0 
declare @dt_usuario_inclusao         datetime 
declare @cd_tipo_pedido              int = 0
declare @cd_condicao_pagamento       int = 0
declare @cd_tabela_preco             int = 0
declare @cd_transportadora           int = 0
declare @cd_conta_banco              int = 0
declare @ic_padrao                   char(1) = 'N'
declare @cd_tipo_pedido_bonificacao  int     = 0
declare @cd_base_retirada            int     = 0


--cliente_empresa


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

select @cd_empresa                       = valor from #json where campo = 'cd_empresa'             
select @cd_parametro                     = valor from #json where campo = 'cd_parametro'          
select @cd_usuario                       = valor from #json where campo = 'cd_usuario'             
select @dt_inicial                       = valor from #json where campo = 'dt_inicial'             
select @dt_final                         = valor from #json where campo = 'dt_final'             
select @cd_modelo                        = valor from #json where campo = 'cd_modelo'             
select @cd_cliente                       = valor from #json where campo = 'cd_cliente' 
select @cd_usuario_inclusao              = valor from #json where campo = 'cd_usuario_inclusao'
select @dt_usuario_inclusao              = valor from #json where campo = 'dt_usuario_inclusao'
select @cd_tipo_pedido                   = valor from #json where campo = 'cd_tipo_pedido'
select @cd_condicao_pagamento            = valor from #json where campo = 'cd_condicao_pagamento'
select @cd_tabela_preco                  = valor from #json where campo = 'cd_tabela_preco'
select @cd_transportadora                = valor from #json where campo = 'cd_transportadora'
select @cd_conta_banco                   = valor from #json where campo = 'cd_conta_banco'
select @ic_padrao                        = valor from #json where campo = 'ic_padrao'
select @cd_tipo_pedido_bonificacao       = valor from #json where campo = 'cd_tipo_pedido_bonificacao'
select @cd_base_retirada                 = valor from #json where campo = 'cd_base_retirada'

--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro = ISNULL(@cd_parametro,0)


IF ISNULL(@cd_parametro,0) = 100
BEGIN
  select 
    'Sucesso' as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final


  RETURN;

END
    
/* LISTAR (GRID) */
    IF @cd_parametro = 0
    BEGIN
      IF ISNULL(@cd_cliente,0) = 0
         THROW 50010, 'cd_cliente é obrigatório para listar.', 1;

      SELECT
        ce.cd_cliente,
        ce.cd_empresa,
        ce.cd_tipo_pedido,
        ce.cd_condicao_pagamento,
        ce.cd_tabela_preco,
        ce.cd_transportadora,
        ce.cd_conta_banco,
        ce.ic_padrao,
        ce.cd_tipo_pedido_bonificacao,
        ce.cd_base_retirada,
        ce.cd_usuario_inclusao,
        ce.dt_usuario_inclusao,
        ce.cd_usuario,
        ce.dt_usuario
      FROM Cliente_Empresa ce WITH (NOLOCK)
      WHERE ce.cd_cliente = @cd_cliente
      ORDER BY ce.cd_empresa;
      RETURN;
    END

    /* UPSERT (INSERIR/ATUALIZAR) */
    IF @cd_parametro = 1
    BEGIN
      IF ISNULL(@cd_cliente,0)=0 OR ISNULL(@cd_empresa,0)=0
        THROW 50011, 'cd_cliente e cd_empresa são obrigatórios para salvar.', 1;

      IF EXISTS (SELECT 1 FROM Cliente_Empresa WITH (UPDLOCK, HOLDLOCK)
                 WHERE cd_cliente=@cd_cliente AND cd_empresa=@cd_empresa)
      BEGIN
        UPDATE Cliente_Empresa
           SET cd_tipo_pedido             = @cd_tipo_pedido,
               cd_condicao_pagamento      = @cd_condicao_pagamento,
               cd_tabela_preco            = @cd_tabela_preco,
               cd_transportadora          = @cd_transportadora,
               cd_conta_banco             = @cd_conta_banco,
               ic_padrao                  = @ic_padrao,
               cd_tipo_pedido_bonificacao = @cd_tipo_pedido_bonificacao,
               cd_base_retirada           = @cd_base_retirada,
               cd_usuario                 = @cd_usuario,
               dt_usuario                 = GETDATE()
         WHERE cd_cliente=@cd_cliente AND cd_empresa=@cd_empresa;
      END
      ELSE
      BEGIN
        INSERT INTO Cliente_Empresa
          (cd_cliente, cd_empresa,
           cd_usuario_inclusao, dt_usuario_inclusao,
           cd_usuario, dt_usuario,
           cd_tipo_pedido, cd_condicao_pagamento, cd_tabela_preco,
           cd_transportadora, cd_conta_banco, ic_padrao,
           cd_tipo_pedido_bonificacao, cd_base_retirada)
        VALUES
          (@cd_cliente, @cd_empresa,
           @cd_usuario, GETDATE(),
           @cd_usuario, GETDATE(),
           @cd_tipo_pedido, @cd_condicao_pagamento, @cd_tabela_preco,
           @cd_transportadora, @cd_conta_banco, @ic_padrao,
           @cd_tipo_pedido_bonificacao, @cd_base_retirada);
      END

      SELECT 'Sucesso' AS Msg, @cd_cliente AS cd_cliente, @cd_empresa AS cd_empresa;
      RETURN;
    END

    /* EXCLUIR */
    IF @cd_parametro = 2
    BEGIN
      IF ISNULL(@cd_cliente,0)=0 OR ISNULL(@cd_empresa,0)=0
        THROW 50012, 'cd_cliente e cd_empresa são obrigatórios para exclusão.', 1;

      DELETE FROM Cliente_Empresa
       WHERE cd_cliente=@cd_cliente AND cd_empresa=@cd_empresa;

      SELECT 'Excluído' AS Msg, @cd_cliente AS cd_cliente, @cd_empresa AS cd_empresa;
      RETURN;
    END

    /* OBTER 1 REGISTRO (EDIÇÃO) */
    IF @cd_parametro = 3
    BEGIN
      IF ISNULL(@cd_cliente,0)=0 OR ISNULL(@cd_empresa,0)=0
        THROW 50013, 'cd_cliente e cd_empresa são obrigatórios para busca.', 1;

      SELECT TOP (1)
        ce.*
      FROM Cliente_Empresa ce WITH (NOLOCK)
      WHERE ce.cd_cliente=@cd_cliente AND ce.cd_empresa=@cd_empresa;
      RETURN;
    END

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
--exec  pr_egis_modelo_procedure
------------------------------------------------------------------------------

--sp_helptext pr_egis_cliente_empresa

go
/*
exec  pr_egis_cliente_empresa '[{"cd_parametro": 100}]'
exec  pr_egis_cliente_empresa '[{"cd_parametro": 0, "cd_cliente": 105}]'                                           ]'
*/
go
------------------------------------------------------------------------------
GO

--delete from cliente_empresa where cd_empresa = 357