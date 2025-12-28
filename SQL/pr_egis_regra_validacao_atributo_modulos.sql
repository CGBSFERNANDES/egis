--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_377


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_regra_validacao_atributo_modulos' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_regra_validacao_atributo_modulos

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_regra_validacao_atributo_modulos','P') IS NOT NULL
    DROP PROCEDURE pr_egis_regra_validacao_atributo_modulos;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_regra_validacao_atributo_modulos
-------------------------------------------------------------------------------
-- pr_egis_regra_validacao_atributo_modulos
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
--                   Processo de Pesquisa em Tabelas dos Módulos 
--
--Data             : 10.12.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_regra_validacao_atributo_modulos
------------------------

@json nvarchar(max) = '' --Parametro de entrada
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

--Declaração das variaveis que seram utlizadas no procedimento (calculo, consulta, update, delete,insert,etc...)

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
declare @cd_modelo              int = 0
declare @cd_tabela              int = 0 
declare @nm_atributo            varchar(80)
declare @nm_menu                varchar(120) = ''
declare @cd_cliente             int          = 0
declare @cd_vendedor            int          = 0
declare @nm_fantasia_cliente    varchar(60)  = ''
declare @cd_produto             int          = 0
declare @nm_fantasia_produto    varchar(60)  = ''
declare @cd_mascara_produto     varchar(60)  = ''
declare @nm_produto             varchar(120) = ''
declare @cd_fornecedor          int          = 0
declare @nm_fantasia_fornecedor varchar(60)  = ''
declare @nm_pesquisa_produto    varchar(120) = ''
declare @cd_regra_validacao     int          = 0


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

--------------------------------------------------------------------------------------------
--Montagem da tabela temporaria que vai receber o json e vai configurar cada variavel de entrada
--------------------------------------------------------------------------------------------

select                     
 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json)root  --Comando que transforma o string json em uma tabela                   
   cross apply openjson(root.value) as valores      
   -- Para debug os parametros de entrada, descomentar o código abaixo
   --select * from #json 
   --return


--------------------------------------------------------------------------------------------
-- Definição da variavel de trabalho com o valor do atributo da tabela #json
--------------------------------------------------------------------------------------------

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo'   
select @cd_tabela              = valor from #json where campo = 'cd_tabela'
select @nm_atributo            = valor from #json where campo = 'nm_atributo'
select @nm_menu				   = valor from #json where campo = 'nm_menu'
select @cd_cliente             = valor from #json where campo = 'cd_cliente'
select @nm_fantasia_cliente    = valor from #json where campo = 'nm_fantasia_cliente'
select @nm_fantasia_produto    = valor from #json where campo = 'nm_fantasia_produto'
select @cd_mascara_produto     = valor from #json where campo = 'cd_mascara_produto'
select @cd_produto             = valor from #json where campo = 'cd_produto'
select @cd_fornecedor          = valor from #json where campo = 'cd_fornecedor'
select @nm_fantasia_fornecedor = valor from #json where campo = 'nm_fantasia_fornecedor'
select @nm_pesquisa_produto    = valor from #json where campo = 'nm_pesquisa_produto'
select @nm_produto             = valor from #json where campo = 'nm_produto'
--------------------------------------------------------------------------------------
select @cd_regra_validacao     = valor from #json where campo = 'cd_regra_validacao'
--------------------------------------------------------------------------------------


set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro         = ISNULL(@cd_parametro,0)
set @cd_modelo            = isnull(@cd_modelo,0)
set @cd_tabela            = isnull(@cd_tabela,0)
set @nm_atributo          = isnull(@nm_atributo,0)
set @cd_cliente           = isnull(@cd_cliente,0)
set @nm_fantasia_cliente  = isnull(@nm_fantasia_cliente,'')
set @cd_mascara_produto   = upper(ltrim(rtrim(isnull(@cd_mascara_produto,''))))
set @nm_pesquisa_produto  = isnull(@nm_pesquisa_produto,'')
set @nm_produto           = isnull(@nm_produto,'')
set @cd_produto           = isnull(@cd_produto,0)
set @cd_regra_validacao   = isnull(@cd_regra_validacao,0)
set @cd_parametro         = isnull(@cd_regra_validacao,0)


---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Teste de execução para validar 


IF ISNULL(@cd_parametro,0) = 0
BEGIN
  select 
    'Sucesso' as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final,
	 @cd_usuario  as cd_usuario


  RETURN;

END


--Dados de Pesquisa do Produto --

if @cd_parametro = 1
begin
  
  if @cd_mascara_produto<>''
  begin
    select @cd_produto = isnull(cd_produto,0)
    from
      produto
    where
      cd_mascara_produto = @cd_mascara_produto
    

  end

  select
    p.cd_produto,
    p.cd_mascara_produto,
    p.nm_fantasia_produto,
    p.nm_produto
    
  from
    produto p
  where
    p.cd_produto = @cd_produto
  
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
--exec  pr_egis_regra_validacao_atributo_modulos
------------------------------------------------------------------------------

--sp_helptext pr_egis_regra_validacao_atributo_modulos

go

--use egissql_rubio
--go

/*
exec  pr_egis_regra_validacao_atributo_modulos '[{"cd_parametro": 0}]'
exec  pr_egis_regra_validacao_atributo_modulos '[{"cd_parametro": 1, "cd_produto":"1"}]'

exec  pr_egis_regra_validacao_atributo_modulos '[{"cd_parametro": 999, "cd_modelo": 1}]'                                   
*/
go

--exec pr_egis_regra_validacao_atributo_modulos '
--[
--    {
--        "ic_json_parametro": "S",
--        "cd_usuario": 5034,
--        "cd_menu": 8775,
--        "cd_modal": 6,
--        "cd_regra_validacao": 1,
--        "origem": "blur",
--        "cd_mascara_produto": "ek.0500"
--    }
--]'
-----------------------------------------------------------------------------------------------------------------
GO
--use egissql_368


--select * from cliente

--insert into cliente
--select top 1 * from egissql_368.dbo.cliente

--update
--  egisadmin.dbo.menu
--  set
--    ic_json_parametro = 'S',
--    cd_parametro = 100,
--      ic_selecao_registro = 'S'
--where
--  cd_menu = 8788


  
