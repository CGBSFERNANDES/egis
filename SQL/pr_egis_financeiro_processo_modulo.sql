--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL
--USE EGISSQL_357
--go

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_financeiro_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_financeiro_processo_modulo

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_financeiro_processo_modulo
-------------------------------------------------------------------------------
--pr_egis_financeiro_processo_modulo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : GCA - Gestão de Caixa
--                   Processo do Módulo de Gestão de Caixa
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_financeiro_processo_modulo
@json nvarchar(max) = ''

--with encryption


as

  SET NOCOUNT ON;

  set @json = isnull(@json,'')

--------------------------------------------------------------------------------------------

declare @cd_empresa          int
declare @cd_parametro        int
declare @cd_documento        int = 0
declare @cd_item_documento   int
declare @cd_cliente          int
declare @cd_relatorio        int 
declare @cd_usuario          int 
declare @dt_hoje             datetime
declare @dt_inicial          datetime 
declare @dt_final            datetime
declare @dt_base             datetime
declare @cd_ano              int = 0
declare @cd_mes              int = 0
declare @vl_total            decimal(25,2) = 0.00
declare @vl_total_hoje       decimal(25,2) = 0.00
declare @cd_vendedor         int           = 0
declare @cd_menu             int           = 0
declare @nm_fantasia_empresa varchar(30)   = ''
declare @ic_imposto_venda    char(1)       = 'N'
declare @cd_conta_banco      int           = 0
declare @cd_extrato_bancario int           = 0
declare @cd_item_extrato     int           = 0


set @cd_empresa        = 0
set @cd_parametro      = 0
set @cd_documento      = 0
set @cd_relatorio      = 0
set @cd_item_documento = 0
set @cd_cliente        = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano            = year(getdate())
set @cd_mes            = month(getdate())  
set @vl_total          = 0

--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

select                     

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]              as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_documento           = valor from #json where campo = 'cd_documento'
select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'
select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_cliente             = valor from #json where campo = 'cd_cliente'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
select @cd_menu                = valor from #json where campo = 'cd_menu'
select @cd_conta_banco         = valor from #json where campo = 'cd_conta_banco'
select @dt_base                = valor from #json where campo = 'dt_base' 
select @cd_extrato_bancario    = valor from #json where campo = 'cd_extrato_bancario' 
select @cd_item_extrato        = valor from #json where campo = 'cd_item_extrato'
set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()


set @cd_documento = ISNULL(@cd_documento,0)

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end

if @dt_base is null
begin
  
  set @dt_base = @dt_hoje

end

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    

--parametro para mostrar o nome da empresa


--parametro para mostrar o terminal

--Login
  --> Automário
  --> terminal de caixa na tabela disposível
      --Terminal_Caixa

 --Parametro para mostrar o número do Terminal

 --Quando digita o CPF, tem que fazer o Busca do Cadastro do Cliente

 --Se for CPF novo insert na Tabela de Cliente ( somente com o CPF, sem nome )


---------------------------------------------------------------------------------------------------------------------------------------------------------    
--01 - Contas
---------------------------------------------------------------------------------------------------------------------------------------------------------    

if @cd_parametro = 1
begin

    SELECT 
        cd_conta_banco AS value,
        CONCAT(cd_banco,'/',cd_agencia_banco,'-',nm_conta_banco,'-',cd_dac_conta_banco,'  ') AS label,
        nm_conta_banco,
        nm_agencia_banco,
        cd_beneficiario_conta
    FROM vw_conta_agencia_banco
    ORDER BY nm_conta_banco, cd_banco, cd_agencia_banco;

  ------
  return
  ------

end

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--02 - 
---------------------------------------------------------------------------------------------------------------------------------------------------------    
if @cd_parametro = 2
begin

  ---------------------------------------------------------------------------------
  exec dbo.pr_conta_banco_lancamento 1, @dt_base, @cd_conta_banco, 2, 0, @dt_final
       --@ic_parametro = 1,
       --@dt_base = '09/08/2025', @cd_conta_banco = 1, @cd_tipo_lancamento_fluxo = 2,
       --@cd_tipo_extrato = 0, @dt_final = '09/30/2025'
  ----------------------------------
  return

  --select
  --  l.*
  --into
  --  #Lancamento
  --from
  --  Conta_Banco_Lancamento l

  --where
  --  l.cd_conta_banco = @cd_conta_banco
  --  and
  --  l.dt_lancamento between @dt_inicial and @dt_final
end
--select @cd_parametro

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--05 - 
---------------------------------------------------------------------------------------------------------------------------------------------------------    
if @cd_parametro = 5
begin
  
  --select * from extrato_bancario

  --declare @cd_extrato_bancario int = 0

  DECLARE @itens NVARCHAR(MAX) = (SELECT valor FROM #json WHERE campo = 'itens');
  
  SET @cd_conta_banco = ISNULL(@cd_conta_banco, 0);
  SET @cd_usuario     = ISNULL(@cd_usuario, 0);

    IF @cd_conta_banco = 0
    BEGIN
        RAISERROR('Conta bancária não informada.', 16, 1);
        RETURN;
    END

   -------------------------------------------------------------------
   delete from Extrato_Bancario where cd_conta_banco = @cd_conta_banco
   -------------------------------------------------------------------
  
    select 
      @cd_extrato_bancario = max(cd_extrato_bancario)
    from
      Extrato_Bancario
    where
      cd_conta_banco = @cd_conta_banco

    Set @cd_extrato_bancario = isnull(@cd_extrato_bancario,0) + 1



    -- Gera lote (cd_item_extrato) se não veio
    SET @cd_item_extrato = ISNULL(@cd_item_extrato,0);
    IF @cd_item_extrato = 0
    BEGIN
        SELECT @cd_item_extrato = ISNULL(MAX(cd_item_extrato),0) + 1
        FROM Extrato_Bancario;
    END

    ;WITH X AS (
        SELECT *
        FROM OPENJSON(@itens)
        WITH (            
            [data]      DATE,
            descricao   NVARCHAR(200),
            valor       DECIMAL(18,2),
            tipo        CHAR(1)
        )
    )
    
     
    SELECT
       @cd_extrato_bancario  as cd_extrato_bancario,
        identity(int,1,1)    as cd_item_extrato,
        @cd_conta_banco      as cd_conta_banco,
        X.[data]             as dt_extrato_banco,
        LEFT(ISNULL(X.descricao,''),200) as nm_extrato_banco,
        CASE WHEN UPPER(ISNULL(X.tipo,'C')) = 'D'
             THEN -ABS(ISNULL(X.valor,0))
             ELSE  ABS(ISNULL(X.valor,0))
        END                              as vl_extrato_banco,
        CASE WHEN UPPER(ISNULL(X.tipo,'C')) = 'D' THEN 'D' ELSE 'C' END as nm_tipo_lancamento,
        'N'                              as ic_conciliacao,
        NULLIF(@cd_usuario,0)            as cd_usuario_inclusao,
        GETDATE()                        as dt_usuario_inclusao
    into #ItemExtrato
    FROM X;

    INSERT INTO Extrato_Bancario (
        cd_extrato_bancario,
        cd_item_extrato,
        cd_conta_banco,
        dt_extrato_banco,
        nm_extrato_banco,
        vl_extrato_banco,
        nm_tipo_lancamento,
        ic_conciliacao,
        cd_usuario_inclusao,
        dt_usuario_inclusao
    )
    SELECT
        cd_extrato_bancario,
        cd_item_extrato,
        cd_conta_banco,
        dt_extrato_banco,
        nm_extrato_banco,
        vl_extrato_banco,
        nm_tipo_lancamento,
        ic_conciliacao,
        cd_usuario_inclusao,
        dt_usuario_inclusao
   from
     #ItemExtrato

    -- Retorno do lote criado e quantidade
    SELECT @cd_item_extrato AS cd_item_extrato,
           COUNT(*)         AS qt_inseridos
    FROM OPENJSON(@itens);
    ---------------------------------------------

  /*
  select * from Extrato_Bancario


   INSERT INTO Extrato_Bancario(
            cd_item_extrato, cd_conta_banco, dt_extrato_banco, nm_extrato_banco,
            vl_extrato_banco, nm_tipo_lancamento, ic_conciliacao, cd_usuario_inclusao, dt_usuario_inclusao
          ) VALUES (
            @cd_item_extrato, @cd_conta_banco, @dt_extrato_banco, @nm_extrato_banco,
            @vl_extrato_banco, @nm_tipo_lancamento, 'N', 1, GETDATE()
          )
  */

  return

  ------

end

------------------------------------------------------------------------------------------------------
--06 - Itens do Extrato pendentes de conciliação
------------------------------------------------------------------------------------------------------

if @cd_parametro = 6
begin
   --SELECT * FROM extrato_bancario

    -- Lista o extrato ainda não conciliado no período/conta
    SELECT
        eb.cd_extrato_bancario         as id_extrato,
        eb.cd_item_extrato,
        eb.cd_item_extrato             as lote,
        eb.cd_conta_banco              as cd_conta_banco,
        eb.dt_extrato_banco            as [data],
        eb.nm_extrato_banco            as descricao,
        eb.vl_extrato_banco            as valor,          -- crédito + / débito -
        eb.nm_tipo_lancamento          as tipo,           -- 'C' / 'D'
        eb.ic_conciliacao              as ic_conciliacao
    FROM Extrato_Bancario eb
    WHERE eb.cd_conta_banco = @cd_conta_banco
      AND eb.dt_extrato_banco BETWEEN @dt_inicial AND @dt_final
      AND ISNULL(eb.ic_conciliacao,'N') = 'N'
    ORDER BY eb.dt_extrato_banco, eb.cd_extrato_bancario;

    return;

end

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--09 - 
---------------------------------------------------------------------------------------------------------------------------------------------------------    
if @cd_parametro = 9
begin
  -----
  exec pr_gera_movimento_bancario_extrato 0, @cd_conta_banco, 0, @cd_usuario, @dt_base
  -----
  --retrun
end

------------------------------------------------------------------------------------------------------
--10 - Conciliar SOMENTE os itens selecionados (lista de cd_extrato_bancario)
------------------------------------------------------------------------------------------------------

IF @cd_parametro = 10
BEGIN
    DECLARE @ids NVARCHAR(MAX) = (SELECT valor FROM #json WHERE campo = 'ids_extrato');
    set @cd_item_extrato       = (SELECT valor FROM #json WHERE campo = 'cd_item_extrato');

    IF (@ids IS NULL OR LEN(@ids) = 0)
    BEGIN
        RAISERROR('Nenhum item selecionado.', 16, 1);
        RETURN;
    END

    -- ids selecionados
    SELECT
      CAST([value] AS INT)          as cd_extrato_bancario,
      cast(@cd_item_extrato as int) as cd_item_extrato
    INTO #Sel
    FROM OPENJSON(@ids);

    --DECLARE @dt_hoje DATETIME = CONVERT(DATETIME, LEFT(CONVERT(VARCHAR, GETDATE(), 121), 10) + ' 00:00:00', 121);
    DECLARE @cd_lanc_base INT = ISNULL((SELECT MAX(cd_lancamento) FROM Conta_Banco_Lancamento), 0);

    set @cd_lanc_base = isnull(@cd_lanc_base,0) + 1

    /* Monta a staging (#Lancamento) reaproveitando o mesmo layout que a pr_gera_movimento_bancario_extrato usa */
    SELECT
        -- será ajustado somando com o identity
        @cd_lanc_base                                      AS cd_lancamento,
        eb.dt_extrato_banco                                AS dt_lancamento,
        eb.vl_extrato_banco                                AS vl_lancamento,
        eb.nm_extrato_banco                                AS nm_historico_lancamento,
        eb.cd_conta_banco                                  AS cd_conta_banco,
        ISNULL(eb.cd_plano_financeiro,0)                   AS cd_plano_financeiro,
        CASE WHEN LEFT(eb.nm_tipo_lancamento,1) = 'C' THEN 1 ELSE 2 END AS cd_tipo_operacao,
        ISNULL(eb.cd_historico_financeiro,0)               AS cd_historico_financeiro,
        1                                                  AS cd_moeda,
        ISNULL(@cd_usuario,1)                              AS cd_usuario,
        GETDATE()                                          AS dt_usuario,
        2                                                  AS cd_tipo_lancamento_fluxo,
        'S'                                                AS ic_lancamento_conciliado,
        'N'                                                AS ic_transferencia_conta,
        dbo.fn_empresa()                                   AS cd_empresa,
        IDENTITY(INT,1,1)                                  AS cd_documento,
        NULL                                               AS cd_documento_baixa,
        NULL                                               AS cd_lancamento_padrao,
        NULL                                               AS cd_documento_receber,
        NULL                                               AS dt_contabilizacao,
        NULL                                               AS cd_lancamento_contabil,
        eb.cd_item_extrato                                 AS cd_lote,
        NULL AS cd_conta_credito, NULL AS cd_conta_debito, NULL AS cd_dac_conta_banco,
        'S' AS ic_fluxo_caixa, 'N' AS ic_manual_lancamento,
        NULL AS nm_compl_lancamento, NULL AS ic_transferencia_lancamento,
        ISNULL(eb.cd_centro_custo,0)                       AS cd_centro_custo,
        NULL AS ic_contabilizacao, NULL AS cd_centro_custo_credito
    INTO #Lancamento
    FROM Extrato_Bancario eb
    INNER JOIN #Sel s ON s.cd_extrato_bancario = eb.cd_extrato_bancario and s.cd_item_extrato = eb.cd_item_extrato
    WHERE eb.cd_conta_banco = @cd_conta_banco
      AND eb.dt_conciliacao IS NULL;

    -- sequencial de cd_lancamento (mesma técnica da pr_gera_movimento_bancario_extrato)
    UPDATE #Lancamento SET cd_lancamento = cd_lancamento + cd_documento;

    -- marca como conciliado e amarra o cd_lancamento
    UPDATE eb
       SET eb.dt_conciliacao = @dt_hoje,
           eb.ic_conciliacao = 'S',
           eb.cd_lancamento  = l.cd_lancamento
    FROM Extrato_Bancario eb
    JOIN #Lancamento l
      ON l.cd_lote = eb.cd_item_extrato
    WHERE eb.cd_extrato_bancario IN (SELECT cd_extrato_bancario FROM #Sel);

    -- insere o movimento bancário
    INSERT Conta_Banco_Lancamento
    SELECT
        cd_lancamento, dt_lancamento, vl_lancamento, nm_historico_lancamento,
        cd_conta_banco, cd_plano_financeiro, cd_tipo_operacao, cd_historico_financeiro,
        cd_moeda, cd_usuario, dt_usuario, cd_tipo_lancamento_fluxo, ic_lancamento_conciliado,
        ic_transferencia_conta, cd_empresa, NULL, cd_documento_baixa, cd_lancamento_padrao,
        cd_documento_receber, dt_contabilizacao, cd_lancamento_contabil, NULL,
        cd_conta_credito, cd_conta_debito, cd_dac_conta_banco, ic_fluxo_caixa,
        ic_manual_lancamento, nm_compl_lancamento, ic_transferencia_lancamento,
        cd_centro_custo, null, ic_contabilizacao, cd_centro_custo_credito
    FROM #Lancamento;

    -- retorna um resumo
    SELECT COUNT(*) AS qt_conciliados FROM #Lancamento;
    RETURN;

END

--Deleta os Lançamentos do extrato bancários

if @cd_parametro = 11
begin
  
  select * into #LancamentoBancario from Extrato_Bancario where cd_extrato_bancario = @cd_extrato_bancario
  
  --select * from Extrato_Bancario

  while exists( select top 1 cd_lancamento from #LancamentoBancario )
  begin
    select top 1
       @cd_lanc_base = cd_lancamento
    from
       #LancamentoBancario

    delete from Conta_Banco_Lancamento where cd_lancamento = @cd_lanc_base

    delete from #LancamentoBancario
    where
      cd_lancamento = @cd_lanc_base

  end
  -------------------------------------------------------------------
  delete from Extrato_Bancario where cd_conta_banco = @cd_conta_banco
  -------------------------------------------------------------------
  return

end


go
--use egissql_357
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_financeiro_processo_modulo
------------------------------------------------------------------------------
--select * from conta_banco_saldo

go
--exec pr_egis_financeiro_processo_modulo '[{"cd_parametro": 1}, {"cd_documento": 3}, {"dt_inicial":"06/01/2025"}, {"dt_final":"06/30/2025"}]'
go
--exec pr_egis_financeiro_processo_modulo '[{"cd_parametro": 2}, {"cd_documento": 0}]'
go

--exec pr_egis_financeiro_processo_modulo '[{"cd_parametro": 2}, {"cd_documento": 3}, {"dt_inicial":"09/01/2025"}, {"dt_final":"09/30/2025"}]'
go
--exec pr_egis_financeiro_processo_modulo '[{"cd_parametro": 6},{"cd_conta_banco": 1},{"cd_documento": 3}, {"dt_inicial":"09/01/2025"}, {"dt_final":"09/30/2025"}]'
go
------------------------------------------------------------------------------


--use egissql_357
--go
--delete from extrato_bancario
--go
--delete from conta_banco_lancamento
--go