--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_372


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_proposta_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_proposta_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_proposta_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_proposta_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_proposta_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_proposta_processo_modulo
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
create procedure  pr_egis_proposta_processo_modulo
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
declare @cd_tabela             int = 0 
declare @nm_atributo           varchar(80)
declare @nm_menu               varchar(120)
declare @cd_consulta           int          = 0
declare @cd_vendedor           int          = 0
declare @cd_condicao_pagamento int          = 0
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
declare @dados_registro           nvarchar(max) = ''
declare @dados_modal              nvarchar(max) = ''
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


--Montagem da tabela temporaria que vai receber o json e vai configurar cada variavel de entrada

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

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo'   
select @cd_tabela              = valor from #json where campo = 'cd_tabela'
select @nm_atributo            = valor from #json where campo = 'nm_atributo'
select @nm_menu				   = valor from #json where campo = 'nm_menu'
select @cd_consulta			   = valor from #json where campo = 'cd_consulta'
select @cd_vendedor    	       = valor from #json where campo = 'cd_vendedor'
select @dados_registro         = valor from #json where campo = 'dados_registro'
select @dados_modal            = valor from #json where campo = 'dados_modal'


--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro = ISNULL(@cd_parametro,0)
set @cd_modelo    = isnull(@cd_modelo,0)
set @cd_tabela    = isnull(@cd_tabela,0)
set @nm_atributo  = isnull(@nm_atributo,0)

--Teste de execução para validar 

-------------------------------------------------modal-----------------------------------------------------
if @dados_modal<>''
begin

  ---------------------------------------------------------
  -- 1) Monta tabela com os dados digitados no modal
  ---------------------------------------------------------
  declare
    @json_modal nvarchar(max) = ''

  set @json_modal = isnull(@dados_modal, '')

  -- Tabela com os campos/valores do modal
  declare @DadosModal table (
    id    int identity(1,1),
    campo varchar(200),
    valor nvarchar(max)
  )

  if (isnull(@json_modal, '') <> '')
  begin
    insert into @DadosModal (campo, valor)
    select
        m.[key]   as campo,
        m.[value] as valor
    from openjson(@json_modal) as m
  end

end




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

if @cd_parametro = 1
begin
  
  --select @dados_registro

  select @cd_vendedor               = try_convert(int, valor)         from @DadosModal where campo = 'nm_vendedor'
  select @cd_condicao_pagamento     = try_convert(int, valor)         from @DadosModal where campo = 'nm_condicao_pagamento'

  --select @cd_vendedor

     if object_id('tempdb..#sel') is not null
       drop table #sel

   select
       IDENTITY(int,1,1)           as id,
       j.cd_consulta              

   into #sel
   from openjson(@dados_registro) with (
           cd_consulta int '$.cd_consulta'
        ) as j


  select * from #sel

  select @cd_consulta = isnull(cd_consulta,0)
  from
    #sel

  update consulta 
  set
    cd_vendedor           = @cd_vendedor,
    cd_condicao_pagamento = @cd_condicao_pagamento
  from
    consulta
  where 
    cd_consulta = @cd_consulta

  select 'Alteração de Proposta No. '+cast(@cd_consulta as varchar(20)) + ', realizada com sucesso !' as msg

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
--exec  pr_egis_avisos_processo
------------------------------------------------------------------------------

--sp_helptext pr_egis_avisos_processo

go
/*
exec  pr_egis_proposta_processo_modulo '[{"cd_parametro": 0, "cd_modelo": 1}]'                                   
exec  pr_egis_proposta_processo_modulo '[{"cd_parametro": 1} ]'                                   
*/
go
------------------------------------------------------------------------------
GO


--exec  pr_egis_proposta_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 1,
--        "cd_usuario": 5034,
--        "cd_modal": 2,
--        "dados_modal": {
--            "dt_alteracao": "2025-12-09",
--            "nm_vendedor": "10"
--        },
--        "dados_registro": [
--            {
--                "cd_consulta": 83,
--                "dt_consulta": "2025-09-12",
--                "cd_cliente": "BAP- BILOCA AUTO PECAS",
--                "cd_vendedor_interno": 99,
--                "cd_vendedor": "Roberta da Graça Eichemberg",
--                "cd_contato": "",
--                "cd_tipo_local_entrega": 1,
--                "vl_total_consulta": 14.05,
--                "ic_operacao_triangular": "N",
--                "dt_alteracao_consulta": "",
--                "cd_tipo_endereco": "",
--                "cd_pedido_compra_consulta": "Web",
--                "ic_fax_consulta": "N",
--                "ic_email_consulta": "N",
--                "cd_transportadora": "NOSSO CARRO",
--                "cd_destinacao_produto": "Revenda",
--                "ds_observacao_consulta": "",
--                "cd_tipo_pagamento_frete": "Emitente",
--                "cd_condicao_pagamento": "À Vista"
--            }
--        ]
--    }
--]'

