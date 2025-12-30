--BANCO DA EMPRESA/CLIENTE
--use EGISSQL_355

IF OBJECT_ID(N'dbo.pr_egis_geracao_pagamento_safra', N'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_geracao_pagamento_safra;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_geracao_pagamento_safra
-------------------------------------------------------------------------------
-- pr_egis_geracao_pagamento_safra
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
--                   Geração de Pagamento Eletrônico - Safra
--
--Data             : 01.10.2025
--Alteração        :
--
--
------------------------------------------------------------------------------

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE dbo.pr_egis_geracao_pagamento_safra
------------------------
@json nvarchar(max) = N''
------------------------------------------------------------------------------
--with encryption


AS

-- ver nível atual
--SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME();

-- se < 130, ajustar:
--ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130;

--return

--set @json = isnull(@json,'')

 SET NOCOUNT ON;
 SET XACT_ABORT ON;

    DECLARE @__sucesso  BIT           = 0;
    DECLARE @__codigo   INT           = 0;
    DECLARE @__mensagem NVARCHAR(4000) = N'OK';

 BEGIN TRY

 /* 1) Validar payload - parâmetros de Entrada da Procedure */
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
                                '',' '),
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


declare @cd_empresa                 int
declare @cd_parametro               int
declare @cd_usuario                 int
declare @dt_hoje                    datetime
declare @dt_inicial                 datetime
declare @dt_final                   datetime
declare @cd_ano                     int = 0
declare @cd_mes                     int = 0
declare @cd_conta_banco             int = 0
declare @cd_portador                int = 0
declare @nr_arquivo                 int = 0
declare @ic_validar_trailer         char(1) = 'N'
declare @ic_validar_inscricao       char(1) = 'N'
declare @dados_registro             nvarchar(max) = N''
declare @dados_modal                nvarchar(max) = N''

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
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,
 valores.[value]                                     as valor

 into #json
 from
   openjson(@json)root
   cross apply openjson(root.value) as valores

--------------------------------------------------------------------------------------------

select @cd_empresa           = try_convert(int, valor)      from #json where campo = 'cd_empresa'
select @cd_parametro         = try_convert(int, valor)      from #json where campo = 'cd_parametro'
select @cd_usuario           = try_convert(int, valor)      from #json where campo = 'cd_usuario'
select @dt_inicial           = try_convert(datetime, valor) from #json where campo = 'dt_inicial'
select @dt_final             = try_convert(datetime, valor) from #json where campo = 'dt_final'
select @cd_conta_banco       = try_convert(int, valor)      from #json where campo = 'cd_conta_banco'
select @cd_portador          = try_convert(int, valor)      from #json where campo = 'cd_portador'
select @nr_arquivo           = try_convert(int, valor)      from #json where campo = 'nr_arquivo'
select @ic_validar_trailer   = try_convert(char(1), valor)  from #json where campo = 'ic_validar_trailer'
select @ic_validar_inscricao = try_convert(char(1), valor)  from #json where campo = 'ic_validar_inscricao'

---------------------------------------------------------------------------------------------
select @dados_registro       = valor from #json where campo = 'dados_registro'
select @dados_modal          = valor from #json where campo = 'dados_modal'

--------------------------------------------------------------------------------------

set @cd_empresa        = ISNULL(@cd_empresa,0)
set @cd_parametro      = ISNULL(@cd_parametro,0)
set @cd_usuario        = ISNULL(@cd_usuario,0)
set @cd_conta_banco    = ISNULL(@cd_conta_banco,0)
set @cd_portador       = ISNULL(@cd_portador,0)
set @nr_arquivo        = ISNULL(@nr_arquivo,0)
set @ic_validar_trailer   = isnull(@ic_validar_trailer,'N')
set @ic_validar_inscricao = isnull(@ic_validar_inscricao,'N')

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------
--Processos
---------------------------------------------------------------------------------------------------------------------------------------------------------

IF ISNULL(@cd_parametro,0) = 0
BEGIN

  select
    'Parâmetros informados' as Msg,
     @cd_empresa            as cd_empresa,
     @dt_inicial            as dt_inicial,
     @dt_final              as dt_final,
     @cd_usuario            as cd_usuario,
     @cd_conta_banco        as cd_conta_banco,
     @cd_portador           as cd_portador,
     @nr_arquivo            as nr_arquivo,
     @ic_validar_trailer    as ic_validar_trailer,
     @ic_validar_inscricao  as ic_validar_inscricao


    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;

  RETURN;

END

----------------------------------------------------------------------------------------------------
--Contas Safra habilitadas
--

IF @cd_parametro = 1
BEGIN

  SELECT
     cab.cd_conta_banco,
     cab.nm_conta_banco,
     cab.cd_agencia_banco,
     cab.cd_portador,
     cab.nm_convenio_cobranca      as nm_convenio_cobranca,
     cab.cd_documento_magnetico,
     cab.nm_local_arquivo,
     cab.nm_extensao_arquivo,
     b.cd_banco,
     b.cd_numero_banco,
     b.nm_banco,
     cab.cd_empresa

  FROM
    Conta_Agencia_Banco cab
    inner join Banco b on b.cd_banco = cab.cd_banco

  WHERE
    b.cd_numero_banco = 422  -- Safra
    and
    cab.cd_empresa = case when @cd_empresa = 0 then cab.cd_empresa else @cd_empresa end

  ORDER BY
    cab.nm_conta_banco


    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;

  return

end

----------------------------------------------------------------------------------------------------
--Documentos para Pagamento Safra
--

IF @cd_parametro = 2
BEGIN

  IF @cd_conta_banco = 0
      THROW 50002, 'Informe cd_conta_banco no JSON para listar os pagamentos.', 1;

  select
    ROW_NUMBER() OVER (ORDER BY d.dt_vencimento_documento, d.cd_documento_pagar) as nr_linha_pagamento,
    d.cd_documento_pagar,
    d.cd_documento,
    d.cd_item_documento,
    d.cd_fornecedor,
    d.cd_tipo_destinatario,
    isnull(vw.nm_fantasia,'')            as nm_fantasia,
    isnull(vw.nm_razao_social,'')        as nm_razao_social,
    isnull(vw.cd_cnpj,'')                as cd_cnpj,
    isnull(vw.cd_inscestadual,'')        as cd_inscestadual,
    isnull(vw.nm_endereco,'')            as nm_endereco,
    isnull(vw.cd_numero_endereco,'')     as cd_numero_endereco,
    isnull(vw.nm_bairro,'')              as nm_bairro,
    isnull(vw.cd_cep,'')                 as cd_cep,
    isnull(vw.nm_cidade,'')              as nm_cidade,
    isnull(vw.sg_estado,'')              as sg_estado,
    d.dt_documento,
    d.dt_vencimento_documento,
    d.vl_documento_pagar,
    d.vl_saldo_documento_pagar,
    d.cd_portador,
    isnull(f.cd_banco,0)                 as cd_banco_favorecido,
    isnull(f.cd_agencia_banco,'')        as cd_agencia_banco_fav,
    isnull(f.cd_conta_banco,'')          as cd_conta_banco_fav

  from
    Documento_Pagar d         with (nolock)
    left outer join vw_destinatario vw with (nolock) on vw.cd_destinatario      = d.cd_fornecedor and
                                                        vw.cd_tipo_destinatario = d.cd_tipo_destinatario
    left outer join Fornecedor f        with (nolock) on f.cd_fornecedor        = d.cd_fornecedor

  where
     isnull(d.vl_saldo_documento_pagar,0) > 0
     and
     d.dt_cancelamento_documento is null
     and
     d.dt_vencimento_documento between @dt_inicial and @dt_final
     and
     isnull(d.cd_portador,0) = case when @cd_portador = 0 then isnull(d.cd_portador,0) else @cd_portador end

  order by
    d.dt_vencimento_documento,
    d.cd_documento_pagar


    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;

  return

end

--use egissql_317
--
/* Padrão se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ação mapeada para cd_parametro=', @cd_parametro) AS Msg;


    -- Status padronizado (sempre o ÚLTIMO resultset)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;

 END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;

        DECLARE
            @errnum  INT = ERROR_NUMBER(),
            @errsev  INT = ERROR_SEVERITY(),
            @errsta  INT = ERROR_STATE(),
            @errline INT = ERROR_LINE(),
            @errmsg  NVARCHAR(2048) = ERROR_MESSAGE(),
            @errproc NVARCHAR(256)  = ERROR_PROCEDURE();

        SET @__sucesso = 0;
        SET @__codigo  = 500;
        SET @__mensagem =
            N'Erro em pr_egis_geracao_pagamento_safra ('
            + ISNULL(@errproc, N'(sem_procedure)')
            + N':' + CONVERT(NVARCHAR(10), @errline)
            + N') #' + CONVERT(NVARCHAR(10), @errnum)
            + N' - ' + ISNULL(@errmsg, N'');

        -- Status padronizado (sempre o ÚLTIMO resultset)
        SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
    END CATCH
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------
go

