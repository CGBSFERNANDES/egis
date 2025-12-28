--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_pcp_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_pcp_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_pcp_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_pcp_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_pcp_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_pcp_processo_modulo
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
create procedure  pr_egis_pcp_processo_modulo
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


declare @cd_empresa           int
declare @cd_parametro         int
declare @cd_documento         int = 0
declare @cd_item_documento    int
declare @cd_usuario           int 
declare @dt_hoje              datetime
declare @dt_inicial           datetime 
declare @dt_final             datetime
declare @cd_ano               int = 0
declare @cd_mes               int = 0
declare @cd_modelo            int = 0
declare @cd_produto           int = 0
declare @cd_fornecedor        int = 0
declare @cd_processo_padrao   int = 0
declare @qt_solicitacao       decimal(25,4) = 0.00
declare @vl_total             float = 0
declare @qt_produto           float = 0
declare @qt_volume            float = 0
declare @cd_transportadora    int = 0
declare @cd_pedido_compra     int = 0
declare @cd_nota_saida        int = 0 
declare @cd_solicitacao       int = 0
declare @cd_controle          int = 0
declare @cd_composicao        int = 0
declare @cd_requisicao_compra int = 0
declare @cd_processo          int = 0
declare @ic_parametro         char(1) = '' --1.Inicio / 2.Fim / 3.Inicio Parada / 4.Fim Parada / 5.Desvio Produção / 6.Refugo    
declare @cd_item_processo     int     = 0 
declare @cd_operacao          int     = 0  
declare @cd_maquina           int     = 0  
declare @cd_operador          int     = 0  
declare @Quantidade           decimal(25,4) = 0.00  
declare @qt_refugo            decimal(25,4) = 0.00  
declare @cd_causa_refugo      int           = 0  
declare @acao                 varchar(50)   = ''   
declare @cd_fase_produto      int           = 0
declare @cd_pedido_venda      int           = 0
declare @qt_venda             int           = 0

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

   --select * from #json

--------------------------------------------------------------------------------------------

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo' 
select @cd_produto             = valor from #json where campo = 'cd_produto'
select @cd_fornecedor          = valor from #json where campo = 'cd_fornecedor'
select @cd_requisicao_compra   = valor from #json where campo = 'cd_requisicao_compra'
select @cd_processo            = valor from #json where campo = 'cd_processo'
select @acao                   = valor from #json where campo = 'acao'
select @cd_item_processo       = valor from #json where campo = 'cd_item_processo'
select @cd_operacao            = valor from #json where campo = 'cd_operacao'
select @cd_maquina             = valor from #json where campo = 'cd_maquina'
select @Quantidade             = valor from #json where campo = 'Quantidade'
select @cd_operador            = valor from #json where campo = 'cd_operador'
select @qt_venda               = valor from #json where campo = 'qt_venda'


--------------------------------------------------------------------------------------
-- Montar #produtos se houver um array "produtos" no payload
--------------------------------------------------------------------------------------
-- Observação: JSON_VALUE não funciona para arrays; use JSON_QUERY.
--select @json as jsonEntrada

-- 1) Normalizar: se @json for um array na raiz, pegar o primeiro objeto

IF JSON_VALUE(@json, '$[0]') IS NOT NULL
    SET @json = JSON_QUERY(@json, '$[0]');

--select JSON_QUERY(@json, '$[0].produtos') as jsonQuery

IF JSON_QUERY(@json, '$[0].produtos') IS NOT NULL
BEGIN
    -- Evitar conflito se a SP for chamada mais de uma vez no mesmo contexto
    IF OBJECT_ID('tempdb..#produtos') IS NOT NULL
        DROP TABLE #produtos1;

    SELECT 
        IDENTITY(int,1,1) AS id_registro,
        p.cd_produto,
        p.qt_produto
    INTO #produtos1
    FROM OPENJSON(@json, '$[0].produtos')
    WITH (
        cd_produto INT '$.cd_produto',
        qt_produto INT '$.qt_produto'
    ) AS p;

        --select * from #produtos
    -- Opcional: conferência
    -- SELECT * FROM #produtos;
END
ELSE
BEGIN
    -- Opcional: se não houver array "produtos", mas existir "cd_produto" único
    IF JSON_VALUE(@json, '$.cd_produto') IS NOT NULL
    BEGIN
        IF OBJECT_ID('tempdb..#produtos') IS NOT NULL
            DROP TABLE #produtos2;

        SELECT 
            IDENTITY(int,1,1) AS id_registro,
            CAST(JSON_VALUE(@json, '$.cd_produto') AS INT) AS cd_produto,
            CAST(ISNULL(JSON_VALUE(@json, '$.qt_produto'), 0) AS INT) AS qt_produto
        INTO #produtos2;
           --select * from #produtos2
    END
    
END

--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro         = ISNULL(@cd_parametro,0)
set @cd_produto           = isnull(@cd_produto,0)
set @cd_fornecedor        = isnull(@cd_fornecedor,0)
set @cd_requisicao_compra = isnull(@cd_requisicao_compra,0)
set @acao                 = isnull(@acao,'')

---------------------------------------------------------------------------------------------------------------------------------------------------------    

if @acao = 'INICIO' 
   set @cd_parametro = 20

if @acao = 'FIM' 
   set @cd_parametro = 30

---------------------------------------------------------------------------------------------------------------------------------------------------------    

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

--Produtos que possuem Beneficiamento--

if @cd_parametro = 1 
begin
  ------------------------------------------------------------------------------------

  select
    p.cd_produto,
    p.cd_mascara_produto,
    p.nm_fantasia_produto,
    p.nm_produto,
    um.sg_unidade_medida,
    pc.vl_custo_produto,
    gp.cd_grupo_produto,
    gp.nm_grupo_produto,
    cp.nm_categoria_produto,
    fa.nm_familia_produto,
    fp.nm_fase_produto

  from
    produto p
    left outer join unidade_medida um    on um.cd_unidade_medida    = p.cd_unidade_medida
    inner join grupo_produto gp          on gp.cd_grupo_produto     = p.cd_grupo_produto
    left outer join categoria_produto cp on cp.cd_categoria_produto = p.cd_categoria_produto
    left outer join familia_produto fa   on fa.cd_familia_produto   = p.cd_familia_produto
    left outer join fase_produto fp      on fp.cd_fase_produto      = p.cd_fase_produto_baixa
    left outer join produto_custo pc     on pc.cd_produto           = p.cd_produto
  where
    isnull(p.cd_status_produto,1) = 1
    and
    isnull(p.ic_beneficiamento_produto,'N') = 'S'
    and 
    p.cd_produto = case when @cd_produto = 0 then p.cd_produto else @cd_produto end

  ---------------------------------------------------------------
  return
  
end

--Fornecedores que podem Realizar Beneficiamento---

if @cd_parametro = 2
begin
  select
    g.nm_grupo_fornecedor,
    f.cd_grupo_fornecedor,
    f.cd_fornecedor,
    f.nm_fantasia_fornecedor,
    f.nm_razao_social,
    isnull((select count(distinct fp.cd_produto)
            from fornecedor_produto fp where fp.cd_fornecedor = f.cd_fornecedor),0) as qt_produto
  from
    fornecedor f
    inner join Grupo_Fornecedor g on g.cd_grupo_fornecedor = f.cd_grupo_fornecedor
  where
    isnull(g.ic_beneficiamento,'N') = 'S'


  return

end

--Produtos por Fornecedor----

if @cd_parametro = 3
begin
  select
    g.nm_grupo_fornecedor,
    f.cd_grupo_fornecedor,
    f.cd_fornecedor,
    f.nm_fantasia_fornecedor,
    f.nm_razao_social,

    --isnull((select count(distinct fp.cd_produto)
    --        from fornecedor_produto fp where fp.cd_fornecedor = f.cd_fornecedor),0) as qt_produto,

    --Produtos--
    p.cd_produto,
    p.cd_mascara_produto,
    p.nm_fantasia_produto,
    p.nm_produto,
    um.sg_unidade_medida,
    pc.vl_custo_produto,
    gp.cd_grupo_produto,
    gp.nm_grupo_produto,
    cp.nm_categoria_produto,
    fa.nm_familia_produto,
    fp.nm_fase_produto
     
  from
    fornecedor f
    inner join Grupo_Fornecedor g        on g.cd_grupo_fornecedor   = f.cd_grupo_fornecedor
    inner join fornecedor_produto fpo    on fpo.cd_fornecedor       = f.cd_fornecedor
    inner join produto p                 on fpo.cd_produto          = fpo.cd_produto    
    left outer join unidade_medida um    on um.cd_unidade_medida    = p.cd_unidade_medida
    inner join grupo_produto gp          on gp.cd_grupo_produto     = p.cd_grupo_produto
    left outer join categoria_produto cp on cp.cd_categoria_produto = p.cd_categoria_produto
    left outer join familia_produto fa   on fa.cd_familia_produto   = p.cd_familia_produto
    left outer join fase_produto fp      on fp.cd_fase_produto      = p.cd_fase_produto_baixa
    left outer join produto_custo pc     on pc.cd_produto           = p.cd_produto
  
  where
    isnull(g.ic_beneficiamento,'N') = 'S'
    and
    isnull(p.cd_status_produto,1) = 1
    and
    isnull(p.ic_beneficiamento_produto,'N') = 'S'
    and 
    p.cd_produto = case when @cd_produto = 0 then p.cd_produto else @cd_produto end
    and
    fpo.cd_fornecedor = case when @cd_fornecedor = 0 then fpo.cd_fornecedor else @cd_fornecedor end
    
  return
  
end

--Geração da Solicitação de Beneciamento--

if @cd_parametro = 5 
begin

  if @cd_requisicao_compra>0
  begin
    if exists( select top 1 cd_requisicao_compra from Solicitacao_Beneficiamento
               where
                 cd_requisicao_compra = @cd_requisicao_compra )
    begin
      select 'Requisição de Compra já possui Beneficiamento !' as Msg
      return  
    end
    
  end

  --select * from #produtos

  IF OBJECT_ID('tempdb..#produtos') IS NOT NULL and @cd_requisicao_compra>0
  begin
    drop table #produtos
    --select @cd_requisicao_compra
  end
  --select @cd_requisicao_compra
  --return

  select
    identity(int,1,1) as id_registro,
    i.cd_requisicao_compra,
    i.cd_produto,
    sum(qt_item_requisicao_compra) as qt_produto,
    max(fp.cd_fornecedor)           as cd_fornecedor
  into
    #produtos

  from
    requisicao_compra_item i
    left outer join Fornecedor_Produto fp on fp.cd_produto = i.cd_produto
  where
    i.cd_requisicao_compra = @cd_requisicao_compra
  group by
    i.cd_requisicao_compra,
    i.cd_produto

  --select * from #produtos
  --return

  --Fornecedor--

  set @cd_fornecedor = 0

  select
    top 1
    @cd_fornecedor = isnull(cd_fornecedor,0)
  from
    #produtos
      
  --select * from #produtos
  --return

  set @cd_processo_padrao = 0
  set @qt_solicitacao     = isnull(@qt_solicitacao,0)
  
  --solicitacao_beneficiamento--

  select
    @cd_solicitacao = max(cd_solicitacao)
  from
    solicitacao_beneficiamento
  
  set @cd_solicitacao = isnull(@cd_solicitacao,0) + 1

  select
    @cd_solicitacao       as cd_solicitacao,
    @dt_hoje              as dt_solicitacao,
    2                     as cd_tipo_destinatario,
    @cd_fornecedor        as cd_destinatario,
    1                     as cd_tipo_beneficiamento,
    cast('' as varchar)   as ds_solicitacao,
    0.00                  as vl_total,
    0                     as qt_produto,
    0                     as qt_volume,
    0                     as cd_transportadora,
    0                     as cd_pedido_compra,
    0                     as cd_nota_saida,
    @cd_usuario           as cd_usuario_inclusao,
    getdate()             as dt_usuario_inclusao,
    @cd_usuario           as cd_usuario,
    getdate()             as dt_usuario,
    @cd_requisicao_compra as cd_requisicao_compra,
    0.00                  as qt_peso_bruto,
    0.00                  as qt_peso_liquido

  into
    #Solicitacao


  --solicitacao_beneficiamento

  --select * from #Solicitacao
  --return

  select top 0 * into #Solicitacao_Composicao from Solicitacao_Beneficiamento_Composicao

  --select * from #produtos
  --select * from #Solicitacao_Composicao

  select
    @cd_composicao = max(cd_composicao)
  from
    Solicitacao_Beneficiamento_Composicao

  set @cd_composicao = isnull(@cd_composicao,0)

  while exists ( select top 1 cd_produto from #produtos )
  begin

    select top 1
      @cd_controle = id_registro,
      @cd_produto  = cd_produto, 
      @qt_produto  = qt_produto
    from
      #produtos
    
      select
        @cd_processo_padrao = isnull(pp.cd_processo_padrao,0)
      from
        processo_padrao pp
        inner join produto p on p.cd_produto = pp.cd_produto
      where
        pp.cd_produto = @cd_produto
        and
        isnull(p.ic_beneficiamento_produto,'N') = 'S'

      --select @cd_processo_padrao
      --return

    set @cd_composicao = isnull(@cd_composicao,0) + 1 

    select
      @cd_composicao      as cd_composicao,
      @cd_solicitacao     as cd_solicitacao,
      identity(int,1,1)   as cd_item_solicitacao,
      2                   as cd_tipo_composicao,
      @cd_produto         as cd_produto,
      @qt_produto         as qt_produto,
      pc.vl_custo_produto,
      @qt_produto *
      pc.vl_custo_produto as vl_total_produto,
      cast('' as varchar) as nm_obs_item_solicitacao,
      @cd_usuario         as cd_usuario_inclusao,
      getdate()           as dt_usuario_inclusao,
      @cd_usuario         as cd_usuario,
      getdate()           as dt_usuario,
      @cd_processo_padrao as cd_processo_padrao,
      null                as cd_inteface,
      p.qt_peso_liquido   as qt_peso_liquido,
      p.qt_peso_bruto     as qt_peso_bruto,
      p.cd_unidade_medida as cd_unidade_medida



      into #tempS

      from 
        produto p
        inner join produto_custo pc on pc.cd_produto = p.cd_produto
      
      where
         p.cd_produto = @cd_produto

      insert into #Solicitacao_Composicao
      select * from #tempS

      --select * from #tempS
      
      drop table #tempS

      --Componentes--
      --select * from processo_padrao where cd_produto = 770

    
      select
        @cd_composicao      as cd_composicao,
        @cd_solicitacao     as cd_solicitacao,
        identity(int,1,1)   as cd_item_solicitacao,
        1                   as cd_tipo_composicao,
        
        --@cd_produto                          as cd_produto_origem,

        ppp.cd_produto,
        @qt_produto
        *
        ppp.qt_produto_processo               as qt_produto,
        pc.vl_custo_produto,
        @qt_produto *
        pc.vl_custo_produto                   as vl_total_produto,
        cast('' as varchar)                   as nm_obs_item_solicitacao,
        @cd_usuario                           as cd_usuario_inclusao,
        getdate()                             as dt_usuario_inclusao,
        @cd_usuario                           as cd_usuario,
        getdate()                             as dt_usuario,
        @cd_processo_padrao                   as cd_processo_padrao,
        null                                  as cd_interface,
        p.qt_peso_liquido                     as qt_peso_liquido,
        p.qt_peso_bruto                       as qt_peso_bruto,
        p.cd_unidade_medida                   as cd_unidade_medida




        ----ppp.cd_fase_produto,
        ----Quantidade--
        --@qt_solicitacao
        --*
        --ppp.qt_produto_processo               as qt_produto,
        --pc.vl_custo_produto                   as vl_custo_produto,
        ----isnull(ps.qt_saldo_reserva_produto,0) as qt_disponivel
        --solicitacao_beneficiamento_composicao
      into
        #composicao
    
      from
        Processo_Padrao_Produto ppp
        inner join produto p             on p.cd_produto       = ppp.cd_produto
        inner join produto_custo pc      on pc.cd_produto      = ppp.cd_produto
        left outer join produto_saldo ps on ps.cd_produto      = ppp.cd_produto and
                                          ps.cd_fase_produto = ppp.cd_fase_produto

 
      where
        ppp.cd_processo_padrao = @cd_processo_padrao

  --select * from processo_padrao_produto where cd_produto=928

   update
     #composicao
   set
     cd_composicao = cd_composicao + cd_item_solicitacao

  --select @cd_produto, @cd_processo_padrao
  --select * from #composicao
    
    insert into #Solicitacao_Composicao
    select * from #composicao
    
    --select * from #composicao

    drop table #composicao


    delete from #produtos
    where
      id_registro = @cd_controle

  end

  insert into Solicitacao_Beneficiamento
  select * from #Solicitacao

  insert into Solicitacao_Beneficiamento_Composicao
  select * from #Solicitacao_Composicao
  -------------------------------------

  select 'Solicitação de Beneficiamento Gerada com Sucesso - '+cast(@cd_solicitacao as varchar(20)) + ' !'

  --Geracao do Pedido de Compra---      com o Tipo de 2-Produtos  

  --pr_gera_pedido_compra_requisicao_compra

  --Geração da Nota Fiscal de Remessa-- com o Tipo de 1-Componentes/MP
  
  --pr_gera_nota_saida_req_fat

  --Validações--
  --pode receber 1 peça ou n peças
  --

  --solicitacao_beneficiamento




  ---------------------------------------------------------------
  return
  
end

--Consultas --

if @cd_parametro = 10
begin

  -- Cria a tabela temporária consolidando os apontamentos  
  IF OBJECT_ID('tempdb..#TabTemp') IS NOT NULL
     DROP TABLE #TabTemp;

  SELECT
    m.cd_processo,
    m.cd_item_processo,
    m.cd_operacao,
    m.cd_maquina,
    SUM(CASE WHEN m.ic_tipo_apontamento = 1 THEN m.qt_movimento ELSE 0 END) AS qt_entrada,
    SUM(CASE WHEN m.ic_tipo_apontamento = 2 THEN m.qt_movimento ELSE 0 END) AS qt_saida,
    MIN(m.dt_inicio_apontamento) AS dt_inicio,
    MAX(m.dt_fim_apontamento)    AS dt_fim,
    MIN(m.hr_inicio_apontamento) AS hr_inicio,
    MAX(m.hr_fim_apontamento)    AS hr_fim,

    SUM(CASE WHEN m.ic_tipo_apontamento = 1 THEN m.qt_movimento ELSE 0 END) 
    -
    SUM(CASE WHEN m.ic_tipo_apontamento = 2 THEN m.qt_movimento ELSE 0 END) AS qt_saldo

    --delete from movimento_apontamento

INTO #TabTemp
FROM movimento_apontamento m
where
  m.cd_processo = @cd_processo

GROUP BY
    m.cd_processo,
    m.cd_item_processo,
    m.cd_operacao,
    m.cd_maquina;


   --select * from #TabTemp


 
    -- Agora você pode usar #TabTemp em joins

--    SELECT
--    t.cd_processo,
--    t.cd_item_processo,
--    t.cd_operacao,
--    t.cd_maquina,
--    p.qt_planejada_processo,
--    (t.qt_entrada - t.qt_saida) AS qt_saldo,
--    t.dt_inicio,
--    t.hr_inicio,
--    t.hr_fim,
--    t.dt_fim,
--    CASE
--        WHEN t.dt_inicio IS NULL THEN 'Aguardando Início'
--        WHEN t.dt_inicio IS NOT NULL AND t.dt_fim IS NULL THEN 'Em Produção'
--        WHEN t.dt_fim IS NOT NULL AND (t.qt_entrada - t.qt_saida) < p.qt_planejada_processo THEN 'Finalizado Parcial'
--        WHEN t.dt_fim IS NOT NULL AND (t.qt_entrada - t.qt_saida) >= p.qt_planejada_processo THEN 'Finalizado'
--        ELSE 'Indefinido'
--    END AS status_atual
--FROM processo_producao p
--LEFT JOIN #TabTemp t
--    ON p.cd_processo = t.cd_processo;


  select
  --pps.*,
  pps.cd_processo,
  pps.cd_item_processo,
  pps.cd_operacao,
  pps.qt_seq_ant_processo,
  pps.qt_hora_estimado_processo,
  pps.cd_maquina,
  qt_tempo_total = isnull(pps.qt_hora_estimado_processo,0) + isnull(pps.qt_hora_setup_processo,0),
  pps.ic_inspecao_operacao,
  pps.ic_apontamento_operacao,
  pps.nm_obs_item_processo,
  op.nm_fantasia_operacao,
  op.nm_operacao,
  case
    when m.ic_processo_maquina = 'D' then m.nm_maquina
    else m.nm_fantasia_maquina
  end as nm_maquina,
  case
    when gm.ic_processo_grupo_maquina = 'D' then gm.nm_grupo_maquina
    else gm.nm_fantasia_grupo_maquina
  end as nm_grupo_maquina,
  se.nm_servico_especial,
  se.ic_fornecedor_serv_especial,
  f.nm_fantasia_fornecedor,
  m.nm_maquina as nm_maquina_completo,
  sm.nm_status_maquina,
  gop.nm_grupo_operacao,
  null                   as dt_cancelamento,
  mov.dt_inicio,
  cast(hr_inicio as varchar(8)) as hr_inicio_apontamento,
  cast(hr_fim    as varchar(8)) as hr_fim_apontamento,
  mov.dt_fim,
  'N'                    as ic_processo_atualizado,
  0.00                   as qt_movimento,
  mov.qt_saldo           as qt_saldo,

  --Dados da Ordem de Produção--
  c.nm_fantasia_cliente,
  isnull(pp.qt_planejada_processo,0) as qt_planejada_processo,
  
  --Produção--
  --case when 

  case when isnull(mov.qt_saldo,0)>0 then

  isnull(pp.qt_planejada_processo,0)
  -
  isnull(mov.qt_saldo,0)
  else
    case when isnull(mov.qt_saldo,0)<0 then
    --isnull(pp.qt_planejada_processo,0)
    --+
    isnull(mov.qt_saldo,0) * - 1
    else
      0.00
    end
  end
  as qt_produzido_processo,

  --isnull(pp.qt_produzido_processo,0) as qt_produzido_processo,
  p.nm_produto,
  um.sg_unidade_medida,
  CASE
        WHEN mov.dt_inicio IS NULL THEN 'Aguardando Início'
        WHEN mov.dt_inicio IS NOT NULL AND mov.dt_fim IS NULL THEN 'Em Produção'
        WHEN mov.dt_fim IS NOT NULL AND (mov.qt_entrada - mov.qt_saida) < pp.qt_planejada_processo  THEN 'Finalizado Parcial'
        WHEN mov.dt_fim IS NOT NULL AND (mov.qt_entrada - mov.qt_saida) >= pp.qt_planejada_processo THEN 'Finalizado'
        ELSE 'Indefinido'
  END AS nm_item_status_atual

  --Dados do Apontamento

  


from
  Processo_Producao_Composicao pps         with(nolock)
  inner join processo_producao pp          with(nolock) on pp.cd_processo          = pps.cd_processo
  inner join produto p                     with(nolock) on p.cd_produto            = pp.cd_produto
  inner join unidade_medida um             with(nolock) on um.cd_unidade_medida    = p.cd_unidade_medida
  left outer join Operacao           op    with(nolock) on op.cd_operacao          = pps.cd_operacao
  left outer join Grupo_Maquina gm         with(nolock) on gm.cd_grupo_maquina     = pps.cd_grupo_maquina
  left outer join Maquina               m  with(nolock) on m.cd_maquina            = pps.cd_maquina
  left outer join Servico_Especial se      with(nolock) on pps.cd_servico_especial = se.cd_servico_especial
  left outer join Fornecedor           f   with(nolock) on pps.cd_fornecedor       = f.cd_fornecedor
  left outer join Status_Maquina sm        with(nolock) on sm.cd_status_maquina    = m.cd_status_maquina
  left outer join Grupo_Operacao gop       with(nolock) on gop.cd_grupo_operacao   = op.cd_grupo_operacao
  left outer join cliente c                with(nolock) on c.cd_cliente            = pp.cd_cliente
  left outer join #TabTemp mov             with(nolock) on mov.cd_processo         = pps.cd_processo      and
                                                           mov.cd_item_processo    = pps.cd_item_processo and
                                                           mov.cd_operacao         = pps.cd_operacao      and
                                                           mov.cd_maquina          = pps.cd_maquina     

where
  pp.cd_processo = @cd_processo --and isnull(pps.cd_produto,0)>0

order by
  nm_item_status_atual, cd_processo, cd_item_processo
return

end


if @cd_parametro = 15
begin
  --qt_planejada_processo --Quantidade Planejada
  --Soma(Entrada, Saida) e mostrar o status e status
  --cd_processo, cd_item_processo, cd_operacao, cd_maquina, qt_movimento, dt_inicio_apontamento, dt_fim_apontamento, hr_inicio_apontamento, hr_fim_apontamento, 
  --ic_tipo_apontamento, = 1, Entrada 2=Saida

  -- Monta uma tabela temporária com os apontamentos consolidados
  WITH tmp_apontamento AS (
    SELECT
        m.cd_processo,
        m.cd_item_processo,
        m.cd_operacao,
        m.cd_maquina,
        SUM(CASE WHEN m.ic_tipo_apontamento = 1 THEN m.qt_movimento ELSE 0 END) AS qt_entrada,
        SUM(CASE WHEN m.ic_tipo_apontamento = 2 THEN m.qt_movimento ELSE 0 END) AS qt_saida,
        MIN(m.dt_inicio_apontamento) AS dt_inicio,
        MAX(m.dt_fim_apontamento)    AS dt_fim,
        MIN(m.hr_inicio_apontamento) AS hr_inicio,
        MAX(m.hr_fim_apontamento)    AS hr_fim
    FROM movimento_apontamento m
    GROUP BY
        m.cd_processo,
        m.cd_item_processo,
        m.cd_operacao,
        m.cd_maquina
)
SELECT
    t.cd_processo,
    t.cd_item_processo,
    t.cd_operacao,
    t.cd_maquina,
    p.qt_planejada_processo,
    (t.qt_entrada - t.qt_saida) AS qt_saldo,
    t.dt_inicio,
    t.hr_inicio,
    t.hr_fim,
    t.dt_fim,
    CASE
        WHEN t.dt_inicio IS NULL THEN 'Aguardando Início'
        WHEN t.dt_inicio IS NOT NULL AND t.dt_fim IS NULL THEN 'Em Produção'
        WHEN t.dt_fim IS NOT NULL AND (t.qt_entrada - t.qt_saida) < p.qt_planejada_processo THEN 'Finalizado Parcial'
        WHEN t.dt_fim IS NOT NULL AND (t.qt_entrada - t.qt_saida) >= p.qt_planejada_processo THEN 'Finalizado'
        ELSE 'Indefinido'
    END AS status_atual
FROM tmp_apontamento t
JOIN processo_producao p
    ON p.cd_processo = t.cd_processo

  return

end

if @cd_parametro = 20
begin

  /*
  select @cd_parametro,
   @cd_empresa,  
     --@ic_parametro, --1.Inicio / 2.Fim / 3.Inicio Parada / 4.Fim Parada / 5.Desvio Produção / 6.Refugo    
     1,
     @cd_processo,  
     @cd_item_processo,  
     @cd_operacao,  
     @cd_maquina,  
     @cd_operador,  
     @Quantidade,  
     @qt_refugo,  
     @cd_causa_refugo,  
     @cd_usuario  
  */

  exec pr_egisnet_apontamento  
     @cd_empresa,  
     --@ic_parametro, --1.Inicio / 2.Fim / 3.Inicio Parada / 4.Fim Parada / 5.Desvio Produção / 6.Refugo    
     1,
     @cd_processo,  
     @cd_item_processo,  
     @cd_operacao,  
     @cd_maquina,  
     @cd_operador,  
     @Quantidade,  
     @qt_refugo,  
     @cd_causa_refugo,  
     @cd_usuario,
     'N'
  
  return

end

if @cd_parametro = 30
begin

  exec pr_egisnet_apontamento  
     @cd_empresa,  
     2, --@ic_parametro, --1.Inicio / 2.Fim / 3.Inicio Parada / 4.Fim Parada / 5.Desvio Produção / 6.Refugo    
     @cd_processo,  
     @cd_item_processo,  
     @cd_operacao,  
     @cd_maquina,  
     @cd_operador,  
     @Quantidade,  
     @qt_refugo,  
     @cd_causa_refugo,  
     @cd_usuario,
     'N'

  return

end

--Operador--

if @cd_parametro = 40
begin

  select
    cd_operador,
    nm_operador,   --Select

    nm_fantasia_operador

  from operador
  where
    isnull(ic_status_operador,'A')='A'
  order by
    nm_fantasia_operador

  return
end

--Máquina--

if @cd_parametro = 50
begin
  
  --select * from maquina

  select
    cd_maquina,
    nm_fantasia_maquina,  --Select
    nm_maquina

  from maquina
  where
    isnull(ic_ativa_maquina,'S')='S'
  order by
    nm_fantasia_maquina

  return

end

--Operações--

if @cd_parametro = 60
begin
  
  --select * from operacao

  select
    cd_operacao,
    nm_operacao,   

    nm_fantasia_operacao ----Select

  from operacao
  where
    isnull(ic_ativa_operacao,'S')='S'
  order by
    nm_fantasia_operacao

  return
end

--Carteira de Pedidos---

--Carteira de Pedidos para Explosão das Necessidades    
    

if @cd_parametro = 100    
begin    
    
  declare @ic_fracionamento char(1)     
  declare @ic_pedido_op    char(1)    
      
  set @ic_fracionamento = 'N'    
  set @cd_fase_produto  = 0    
  set @ic_pedido_op     = 'S'    
    
  select    
    @ic_fracionamento = isnull(ic_fracionamento,'N'),    
    @ic_pedido_op     = isnull(ic_pedido_op,@ic_pedido_op)    
  from    
    parametro_mrp    
  where    
    cd_empresa = @cd_empresa    
    
  select    
    @cd_fase_produto = isnull(cd_fase_produto,0)    
  from    
    parametro_comercial with (nolock)    
  where    
    cd_empresa = @cd_empresa    
    
    
  Select    
    identity(int,1,1) as cd_controle,    
    Cast(0 as int)    as ic_selecao,    
    pv.cd_pedido_venda,    
      pv.dt_pedido_venda,    
      c.nm_fantasia_cliente,    
   c.nm_razao_social_cliente,    
      pvi.cd_produto,    
   pvi.nm_produto_pedido,    
   case when c.cd_tipo_pessoa = 1     
     then dbo.fn_formata_cnpj(c.cd_cnpj_cliente)        
        else dbo.fn_formata_cpf(c.cd_cnpj_cliente)        
      end      as cd_cnpj_cliente,       
      case when isnull(p.cd_fase_produto_baixa,0)=0     
        then @cd_fase_produto    
        else p.cd_fase_produto_baixa    
      end                        as cd_fase_produto,    
     case when cast(isnull(pv.ds_pedido_venda,'') as varchar(500)) = ''    
        then cast(isnull(pv.ds_observacao_pedido,'') as varchar(500))    
        else cast(isnull(pv.ds_pedido_venda,'') as varchar(500))    
      end                        as ds_pedido_venda,    
      pvf.dt_follow_pedido,        
      pvf.nm_motivo_follow_pedido,        
      pvf.nm_hist_follow_pedido,    
   pvi.nm_observacao_fabrica1,    
   pvi.nm_observacao_fabrica2,    
      pvi.qt_saldo_pedido_venda,    
      pvi.cd_item_pedido_venda,    
      p.cd_mascara_produto,    
      p.nm_fantasia_produto,    
      p.nm_produto,    
      um.sg_unidade_medida,    
      pvi.dt_entrega_vendas_pedido,    
      tp.cd_tipo_produto_projeto,    
      tp.nm_tipo_produto_projeto,    
      xp.cd_processo_padrao,    
   tip.nm_tipo_pedido,    
   pvim.qt_peso_liquido_total,    
   pvim.qt_peso_bruto_total,    
      pvi.cd_desenho_item_pedido,    
      pvi.cd_rev_des_item_pedido,    
      ps.qt_saldo_reserva_produto as Disponivel,    
      ps.qt_saldo_atual_produto   as Fisico,    
   isnull(nsi.cd_identificacao_nota_saida,0) as cd_nota_saida,        
      nsi.dt_nota_saida,        
      nsi.dt_saida_nota_saida,    
   nsi.dt_restricao_item_nota,    
   cpv.dt_solicitacao_coleta,    
   cpv.cd_numero_coleta,    
   cpv.dt_coleta,    
   usc.nm_fantasia_usuario                             as nm_usuario_solicitacao,    
   uc.nm_fantasia_usuario                              as nm_usuario_coleta,    
   cpv.dt_coleta_transportadora,     
   dp.nm_destinacao_produto,     
   cpv.nm_obs_coleta,    
      isnull( (select top 1 xpp.cd_processo    
              from    
                processo_producao xpp with (nolock)    
              where    
                                         xpp.cd_pedido_venda      = pvi.cd_pedido_venda and    
                                         xpp.cd_item_pedido_venda = pvi.cd_item_pedido_venda ),0) as cd_processo,    
    
      isnull( convert(varchar,(select top 1 xpl.dt_liberacao_processo    
              from    
                processo_producao xpl with (nolock)    
              where    
                                         xpl.cd_pedido_venda      = pvi.cd_pedido_venda and    
                                         xpl.cd_item_pedido_venda = pvi.cd_item_pedido_venda ),103),'') as dt_liberacao_processo,    
    
      isnull((select top 1 sm.nm_status_processo    
    from     
      processo_producao xppl with(nolock)    
      left outer join status_processo sm with(nolock) on sm.cd_status_processo = xppl.cd_status_processo    
                   where    
                     xppl.cd_pedido_venda         = pvi.cd_pedido_venda and    
                     xppl.cd_item_pedido_venda = pvi.cd_item_pedido_venda ),'')  as nm_status_processo,    
    
      isnull((select top 1 xppl.cd_status_processo    
    from     
      processo_producao xppl with(nolock)    
                   where    
                     xppl.cd_pedido_venda         = pvi.cd_pedido_venda and    
    xppl.cd_item_pedido_venda = pvi.cd_item_pedido_venda ),'')  as cd_status_processo,    
    
      dbo.fn_composicao_produto_processo_padrao(isnull(pvi.cd_produto,0)) as ic_composicao_tem_pp,    
    
   --Pesagem--    
      isnull( (select top 1 pes.cd_processo    
              from    
                processo_producao_pesagem pes     with (nolock)    
    inner join processo_producao ppes with (nolock) on ppes.cd_processo          = pes.cd_processo          and    
                                                                   ppes.cd_pedido_venda      = pvi.cd_pedido_venda      and    
                                                                   ppes.cd_item_pedido_venda = pvi.cd_item_pedido_venda    
     where    
        pv.cd_pedido_venda = ppes.cd_pedido_venda                    
             ),0) as cd_processo_pesagem,    
    isnull(isnull(pvi.qt_saldo_pedido_venda,0) * isnull(pvi.vl_unitario_item_pedido,0),0) as vl_total_pedido_aberto,    
    isnull(ve.nm_vendedor,'')       as  'Vendedor Externo',    
    isnull(v.nm_vendedor,'')        as  'Vendedor Interno',    
    isnull(rv.nm_regiao_venda,'')   as  nm_regiao_venda,    
    Isnull(es.nm_estado,'')         as  nm_estado,    
    isnull(ci.nm_cidade,'')         as  nm_cidade    
    
    
--select * from pedido_venda_item    
into    
   #pedido_mrp    
          
from    
    Pedido_Venda pv                                     with (nolock)     
    left  join Cliente c                                with (nolock) on c.cd_cliente                            = pv.cd_cliente    
    left  join tipo_pedido tip                          with (nolock) on tip.cd_tipo_pedido                  = pv.cd_tipo_pedido    
    left  join Pedido_Venda_item pvi                    with (nolock) on pvi.cd_pedido_venda            = pv.cd_pedido_venda    
    left  join Pedido_Venda_item_medida pvim            with (nolock) on pvim.cd_pedido_venda           = pvi.cd_pedido_venda    
                                                                                               and pvim.cd_item_pedido_venda  = pvi.cd_item_pedido_venda    
    inner join produto p                                with (nolock) on p.cd_produto                          = pvi.cd_produto    
    left outer join unidade_medida um                   with (nolock) on um.cd_unidade_medida          = pvi.cd_unidade_medida    
    left outer join Produto_Processo     pp             with (nolock) on pp.cd_produto                         = p.cd_produto     
    left outer join Tipo_Produto_Projeto tp             with (nolock) on tp.cd_tipo_produto_projeto   = pp.cd_tipo_produto_projeto    
    left outer join Produto_Producao    xp              with (nolock) on xp.cd_produto                        = p.cd_produto    
    left outer join Produto_Saldo ps                    with (nolock) on ps.cd_produto                        = pvi.cd_produto     
                                                                               and ps.cd_fase_produto                = case when isnull(p.cd_fase_produto_baixa,0)=0     
                                                                                                                                                           then @cd_fase_produto    
                                                                                                                                                           else p.cd_fase_produto_baixa end    
    left outer join vw_follow_pedido_venda wf           with (nolock) on wf.cd_pedido_venda            = pvi.cd_pedido_venda  and      
                                                                                                       wf.cd_item_pedido_venda   = pvi.cd_item_pedido_venda       
    left outer join pedido_venda_follow pvf             with (nolock) on pvf.cd_pedido_venda           = pvi.cd_pedido_venda and      
                                                                                                   pvf.cd_item_pedido_venda  = wf.cd_item_pedido_venda and       
                        pvf.cd_item_follow_pedido   = wf.cd_item_follow_pedido      
    left outer join vw_pedido_venda_item_nota_saida nsi with (nolock) on nsi.cd_pedido_venda                = pv.cd_pedido_venda      and        
                                                                                                                     nsi.cd_item_pedido_venda       = pvi.cd_item_pedido_venda     
    left outer join Coleta_Pedido_Venda cpv             with (nolock) on cpv.cd_pedido_venda              = pvi.cd_pedido_venda      and        
                                                                                                           isnull(cpv.cd_item_pedido_venda,0) = case when isnull(cpv.cd_item_pedido_venda,0)<>0     
                                                                                                                then pvi.cd_item_pedido_venda    
                                                    else isnull(cpv.cd_item_pedido_venda,0) end                         
    left outer join egisadmin.dbo.usuario usc           with (nolock) on usc.cd_usuario                     = cpv.cd_usuario_solicitacao        
    left outer join egisadmin.dbo.usuario uc            with (nolock) on uc.cd_usuario                      = cpv.cd_usuario_coleta    
    left outer join destinacao_produto dp               with (noLock) on dp.cd_destinacao_produto = pv.cd_destinacao_produto     
    left outer join Vendedor V                          with(nolock)  on v.cd_vendedor      = pv.cd_vendedor_interno    
    left outer join Vendedor VE                         with(nolock)  on ve.cd_vendedor     = pv.cd_vendedor    
    left outer join Regiao_Venda rv                     with(nolock)  on rv.cd_regiao_venda = ve.cd_regiao_venda    
    left outer join estado es                           with(nolock)  on es.cd_estado       = c.cd_estado    
    left outer join Cidade Ci                           with(nolock)  on ci.cd_estado       = es.cd_estado and    
                                                                            ci.cd_cidade       = c.cd_cidade            
where    
  pv.dt_fechamento_pedido is not null and    
  isnull(tip.ic_mrp_tipo_pedido,'S') = 'S' and    
  tp.ic_mrp_tipo_produto = 'S' and    
  isnull(pv.cd_pedido_venda,0) = case when @cd_pedido_venda = 0 then isnull(pv.cd_pedido_venda,0) else @cd_pedido_venda end     
  and    
  pvi.dt_entrega_vendas_pedido between case when @cd_pedido_venda = 0     
                                         then case when @dt_inicial = '' then pvi.dt_entrega_vendas_pedido else @dt_inicial end     
                                         else pvi.dt_entrega_vendas_pedido     
                                       end    
                                   and case when @cd_pedido_venda = 0     
                                         then case when @dt_final = '' then pvi.dt_entrega_vendas_pedido else @dt_final end    
                                         else pvi.dt_entrega_vendas_pedido    
                                       end    
  --and isnull(pvi.ic_controle_pcp_pedido,'N')='S'     
    
  and ( isnull(pvi.ic_controle_pcp_pedido,'N')='S' or isnull(p.ic_pcp_produto,'N')='S' )    
  and isnull(pvi.qt_saldo_pedido_venda,0)>0     
  and pvi.dt_cancelamento_item is null -- Não pode ser Cancelado    
    
  and pvi.cd_pedido_venda not in ( select cd_pedido_venda     
                                   from    
                                     plano_mrp_composicao prc with (nolock)     
                                   where    
                                     prc.cd_pedido_venda      = pvi.cd_pedido_venda and     
                                     prc.cd_item_pedido_venda = pvi.cd_item_pedido_venda)      
    
    
    
order by    
     pvi.dt_entrega_vendas_pedido,    
     pv.dt_pedido_venda,    
     pvi.cd_pedido_venda    
    
    
--Verificar se é MRP de Fracionamento--------------------------------------------------    
    
if @ic_fracionamento = 'S'    
begin    
  delete from    #pedido_mrp    
  where     
      Disponivel >= 0    
    
end    
    
if @ic_pedido_op='N'    
begin    
  delete from #pedido_mrp    
  where    
    isnull(cd_processo,0)<>0    
end    
else    
begin    
  --verifica se a Ordem de Produção está em processo de Pesagem    
  delete from #pedido_mrp    
  where    
    isnull(cd_processo_pesagem,0)>0    
    
  delete from #pedido_mrp    
  where    
    cd_status_processo in (5,6)    
end    
    
    
    
select    
  *     
from    
   #pedido_mrp    
    
       
order by    
     dt_entrega_vendas_pedido,    
     dt_pedido_venda,    
     cd_pedido_venda    
    
drop table #pedido_mrp    
    
  ---------------------------------------------------------------    
  return    
      
end    

--Apresenta as Produtos de Acordo com a Estrutura do Processo Padrão-----------------------------


if @cd_parametro  = 200
begin

  ------------------------------------------------------
-- 1) Carteira de Pedidos (#Carteira)
------------------------------------------------------
IF OBJECT_ID('tempdb..#Carteira') IS NOT NULL DROP TABLE #Carteira;

SELECT 
    i.cd_produto                           AS cd_produto,
    MAX(p.cd_mascara_produto)              AS cd_mascara_produto,
    SUM(ISNULL(i.qt_saldo_pedido_venda,0)) AS qt_carteira
INTO #Carteira
FROM pedido_venda_item i
    INNER JOIN pedido_venda pv ON pv.cd_pedido_venda = i.cd_pedido_venda
    INNER JOIN produto p       ON p.cd_produto       = i.cd_produto
WHERE
    i.dt_cancelamento_item IS NULL
    AND ISNULL(i.qt_saldo_pedido_venda,0) > 0
GROUP BY
    i.cd_produto;

-- opcional pra conferir
--SELECT * FROM #Carteira;

------------------------------------------------------
-- 2) Parâmetros
------------------------------------------------------
--DECLARE @qt_venda DECIMAL(25,4) = 11500;   -- quantidade adicional
--DECLARE @dt_hoje  DATETIME      = GETDATE();

------------------------------------------------------
-- 3) Base do mapa de produção (#MapaProducao)
------------------------------------------------------
IF OBJECT_ID('tempdb..#MapaProducao') IS NOT NULL DROP TABLE #MapaProducao;

SELECT 
    p.cd_produto,
    p.cd_mascara_produto,
    p.nm_fantasia_produto,
    p.nm_produto,
    um.sg_unidade_medida,
    ISNULL(ps.qt_saldo_reserva_produto, 0) AS Disponivel,        -- produto acabado
    ISNULL(ps.qt_minimo_produto, 0)        AS Minimo,

    ISNULL(p.qt_leadtime_produto, 0)       AS Dias,
    CASE 
        WHEN ISNULL(ps.qt_saldo_reserva_produto,0) <= ps.qt_minimo_produto 
            THEN @dt_hoje + ISNULL(p.qt_leadtime_produto,0)
        ELSE NULL
    END                                     AS dt_previsao_entrega,

    pp.cd_processo_padrao,

    ppp.cd_produto                          AS cd_comp_produto,
    ppp.cd_produto_proc_padrao,             -- ordem da atividade / componente
    pc.cd_mascara_produto                   AS cd_comp_mascara_produto,
    pc.nm_produto                           AS nm_comp_produto,
    ISNULL(ppp.qt_produto_processo,0)       AS qt_produto_processo,

    -- estoque do componente
    ISNULL(psc.qt_saldo_reserva_produto,0)  AS comp_Disponivel,

    -- carteira do produto
    ISNULL(c.qt_carteira,0)                 AS qt_carteira
INTO #MapaProducao
FROM produto p
    INNER JOIN unidade_medida um           
        ON um.cd_unidade_medida = p.cd_unidade_medida
    LEFT JOIN produto_saldo ps             
        ON ps.cd_produto      = p.cd_produto 
       AND ps.cd_fase_produto = p.cd_fase_produto_baixa
    INNER JOIN processo_padrao pp          
        ON pp.cd_produto      = p.cd_produto
    INNER JOIN processo_padrao_produto ppp 
        ON ppp.cd_processo_padrao = pp.cd_processo_padrao
    LEFT JOIN produto pc                   
        ON pc.cd_produto = ppp.cd_produto
    LEFT JOIN produto_saldo psc            
        ON psc.cd_produto      = pc.cd_produto 
       AND psc.cd_fase_produto = pc.cd_fase_produto_baixa
    LEFT JOIN #Carteira c
        ON c.cd_produto = p.cd_produto
WHERE
    p.cd_grupo_produto = 1
ORDER BY
    p.cd_mascara_produto,
    pp.cd_processo_padrao,
    ppp.cd_produto_proc_padrao;

------------------------------------------------------
-- 4) Tabela de componentes "magrela" (#Comp)
------------------------------------------------------
IF OBJECT_ID('tempdb..#Comp') IS NOT NULL DROP TABLE #Comp;

SELECT
    cd_produto              = m.cd_produto,
    cd_mascara_produto      = CONVERT(VARCHAR(60),  m.cd_mascara_produto),
    nm_produto              = CONVERT(VARCHAR(200), m.nm_produto),
    Disponivel              = m.Disponivel,              -- produto acabado
    Minimo                  = m.Minimo,
    Dias                    = m.Dias,
    dt_previsao_entrega     = m.dt_previsao_entrega,
    cd_processo_padrao      = m.cd_processo_padrao,
    cd_comp_mascara_produto = CONVERT(VARCHAR(60),  m.cd_comp_mascara_produto),
    cd_produto_proc_padrao  = m.cd_produto_proc_padrao,
    qt_carteira             = ISNULL(m.qt_carteira,0),

    -- Necessidade do componente:
    -- demanda_total = qt_carteira + @qt_venda
    -- necessidade_produto = max(0, demanda_total - Disponivel)
    -- NecessidadeComp = necessidade_produto * qt_produto_processo
    NecessidadeComp =
        CAST(
            CASE 
                WHEN (@qt_venda = 0 AND ISNULL(m.qt_carteira,0) = 0) THEN
                    -- mapa atual => mostrar estoque do componente
                    m.comp_Disponivel
                ELSE 
                    CASE 
                        WHEN (@qt_venda + ISNULL(m.qt_carteira,0) - m.Disponivel) > 0 
                            THEN (@qt_venda + ISNULL(m.qt_carteira,0) - m.Disponivel)
                                 * m.qt_produto_processo
                        ELSE 0
                    END
            END
        AS DECIMAL(18,4))
INTO #Comp
FROM #MapaProducao m
WHERE m.cd_comp_mascara_produto IS NOT NULL;   -- ignora linhas sem componente

------------------------------------------------------
-- 5) Enumera componentes por Produto+Processo (#CompEnum)
--    rn = 1 => C1, rn = 2 => C2, ...
------------------------------------------------------
IF OBJECT_ID('tempdb..#CompEnum') IS NOT NULL DROP TABLE #CompEnum;

SELECT
    c.cd_produto,
    c.cd_mascara_produto,
    c.nm_produto,
    c.Disponivel,
    c.Minimo,
    c.Dias,
    c.dt_previsao_entrega,
    c.cd_processo_padrao,
    c.cd_comp_mascara_produto,
    c.NecessidadeComp,
    c.qt_carteira,
    rn = ROW_NUMBER() OVER (
         PARTITION BY c.cd_produto, c.cd_processo_padrao
         ORDER BY c.cd_produto_proc_padrao, c.cd_comp_mascara_produto
    )
INTO #CompEnum
FROM #Comp c;

------------------------------------------------------
-- 6) Atividades = nº de componentes por Produto+Processo
------------------------------------------------------
IF OBJECT_ID('tempdb..#Atividades') IS NOT NULL DROP TABLE #Atividades;

SELECT
    c1.cd_produto,
    c1.cd_processo_padrao,
    Atividades =
        STUFF((
            SELECT ', ' + c2.cd_comp_mascara_produto
            FROM #CompEnum c2
            WHERE c2.cd_produto         = c1.cd_produto
              AND c2.cd_processo_padrao = c1.cd_processo_padrao
              AND c2.NecessidadeComp > 0      -- só itens que vai produzir/comprar
            FOR XML PATH(''), TYPE
        ).value('.', 'VARCHAR(4000)'), 1, 2, '')
INTO #Atividades
FROM #CompEnum c1
GROUP BY
    c1.cd_produto,
    c1.cd_processo_padrao;


------------------------------------------------------
-- 7) Quantas colunas C1..CN preciso?
------------------------------------------------------
DECLARE @maxCol INT;
SELECT @maxCol = ISNULL(MAX(rn),0) FROM #CompEnum;

IF @maxCol = 0
BEGIN
    -- Sem componentes: só mostra cabeçalho básico
    SELECT 
        DISTINCT
        cd_mascara_produto AS Produto,
        nm_produto         AS Descricao,
        Disponivel,
        Minimo,
        Dias               AS LeadTime,
        dt_previsao_entrega AS Previsao,
        cd_processo_padrao AS PP,
        qt_carteira        AS Carteira,
        0 AS Atividades
    FROM #CompEnum;
    
    GOTO FIM_LIMPEZA;

END

------------------------------------------------------
-- 8) Monta dinamicamente C1..CN com MAX(CASE WHEN rn = n ...)
------------------------------------------------------
DECLARE @sql        NVARCHAR(MAX) = N'';
DECLARE @selectCols NVARCHAR(MAX) = N'';
DECLARE @i          INT          = 1;

WHILE @i <= @maxCol
BEGIN
    SET @selectCols = @selectCols + 
        CASE WHEN @i > 1 THEN ',' ELSE '' END +
        'MAX(CASE WHEN e.rn = '+CAST(@i AS VARCHAR(10))+
        ' THEN e.Conteudo END) AS C'+CAST(@i AS VARCHAR(10));
    SET @i = @i + 1;
END

SET @sql = N'
SELECT
    e.cd_mascara_produto AS Produto,
    e.nm_produto         AS Descricao,
    e.Disponivel,
    e.Minimo,
    e.Dias               AS LeadTime,
    e.dt_previsao_entrega AS Previsao,
    e.cd_processo_padrao AS PP,
    e.qt_carteira        AS Carteira,
    a.Atividades,
   
    ' + @selectCols + ',
     
     Processo = (
        SELECT
            componente = c2.cd_comp_mascara_produto,
            qt         = SUM(c2.NecessidadeComp)
        FROM #CompEnum c2
        WHERE c2.cd_produto         = e.cd_produto
          AND c2.cd_processo_padrao = e.cd_processo_padrao
          AND c2.NecessidadeComp > 0
        GROUP BY c2.cd_comp_mascara_produto
        FOR JSON PATH
    )

FROM (
    SELECT
        c.cd_produto,
        c.cd_mascara_produto,
        c.nm_produto,
        c.Disponivel,
        c.Minimo,
        c.Dias,
        c.dt_previsao_entrega,
        c.cd_processo_padrao,
        c.rn,
        c.qt_carteira,
        Conteudo = CAST(
            CONVERT(VARCHAR(20), c.cd_comp_mascara_produto) + ''='' +
            STR(c.NecessidadeComp, 20, 4)
        AS CHAR(45))    -- todas as colunas C1..CN com mesmo tamanho
    FROM #CompEnum c
) e
LEFT JOIN #Atividades a
    ON a.cd_produto         = e.cd_produto
   AND a.cd_processo_padrao = e.cd_processo_padrao
GROUP BY
    e.cd_produto,
    e.cd_mascara_produto,
    e.nm_produto,
    e.Disponivel,
    e.Minimo,
    e.Dias,
    e.dt_previsao_entrega,
    e.cd_processo_padrao,
    e.qt_carteira,
    a.Atividades
ORDER BY
    Produto,
    PP;
';

--PRINT @sql;  -- se quiser ver o SQL gerado
EXEC sp_executesql @sql;
----------------------------


-- JSON final com componentes e quantidades totais (somando todos os processos/produtos)
--SELECT
--    componente = cd_comp_mascara_produto,
--    qt         = SUM(NecessidadeComp)
--FROM #CompEnum
--WHERE NecessidadeComp > 0
--GROUP BY cd_comp_mascara_produto
--FOR JSON PATH;



-- JSON final com componentes e quantidades totais (somando todos os processos/produtos)
--SELECT
--    componente = cd_comp_mascara_produto,
--    qt         = SUM(NecessidadeComp)
--FROM #CompEnum
--WHERE NecessidadeComp > 0
--GROUP BY cd_comp_mascara_produto
--FOR JSON PATH;

/*
SELECT
    pp        = cd_processo_padrao,
    componentes = (
        SELECT
            componente = cd_comp_mascara_produto,
            qt         = SUM(NecessidadeComp)
        FROM #CompEnum c2
        WHERE c2.cd_processo_padrao = c1.cd_processo_padrao
          AND c2.NecessidadeComp > 0
        GROUP BY cd_comp_mascara_produto
        FOR JSON PATH
    )
FROM #CompEnum c1
GROUP BY cd_processo_padrao
FOR JSON PATH;
*/


------------------------------------------------------
-- 9) Limpeza
------------------------------------------------------
FIM_LIMPEZA:
IF OBJECT_ID('tempdb..#CompEnum')     IS NOT NULL DROP TABLE #CompEnum;
IF OBJECT_ID('tempdb..#Atividades')   IS NOT NULL DROP TABLE #Atividades;
IF OBJECT_ID('tempdb..#Comp')         IS NOT NULL DROP TABLE #Comp;
IF OBJECT_ID('tempdb..#MapaProducao') IS NOT NULL DROP TABLE #MapaProducao;
IF OBJECT_ID('tempdb..#Carteira')     IS NOT NULL DROP TABLE #Carteira;


  return

end

---------------------------------------------------------------------------------------------------------------------

if @cd_parametro = 999 
begin

  ---------------------------------------------------------------
  return
  
end

--select * from documento_receber_pagamento 

    
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

--select * from produto where nm_fantasia_produto = 'SA.0001'

--select * from movimento_apontamento

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_pcp_processo_modulo
------------------------------------------------------------------------------

--sp_helptext pr_egis_modelo_procedure

go
/*
exec  pr_egis_pcp_processo_modulo '[{"cd_parametro": 0}]'
exec  pr_egis_pcp_processo_modulo '[{"cd_parametro": 1, "cd_modelo": 1}]' 
exec  pr_egis_pcp_processo_modulo '[{"cd_parametro": 2, "cd_modelo": 1}]' 
exec  pr_egis_pcp_processo_modulo '[{"cd_parametro": 3, "cd_modelo": 1}]' 
exec  pr_egis_pcp_processo_modulo '[{"cd_parametro": 5, "cd_requisicao_compra": 3}]' 
exec  pr_egis_pcp_processo_modulo '[{"cd_parametro": 10, "cd_processo": 2}]' 

delete from movimento_apontamento where cd_processo = 2

select * from movimento_apontamento

use egissql_cromo

exec  pr_egis_pcp_processo_modulo '[{"cd_parametro": 999, "cd_documento": 3308}]'                                           
*/

go


--exec  pr_egis_pcp_processo_modulo '[{"cd_parametro": 10, "cd_processo": 2}]' 



--exec  pr_egis_pcp_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 10,
--        "acao": "INICIO",
--        "cd_processo": 2,
--        "cd_item_processo": 10,
--        "cd_operacao": 1,
--        "cd_maquina": 1,
--        "Quantidade": 1,
--        "cd_operador": 0,
--        "cd_usuario": 5044
--    }
--]'

go

--exec  pr_egis_pcp_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 10,
     
--        "cd_processo": 2,
--        "cd_item_processo": 1,
--        "cd_operacao": 1,
--        "cd_maquina": 1,
--        "Quantidade": 1,
--        "cd_operador": 0,
--        "cd_usuario": 5044
--    }
--]'


--exec  pr_egis_pcp_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 40,
     
--        "cd_processo": 2,
--        "cd_item_processo": 1,
--        "cd_operacao": 1,
--        "cd_maquina": 1,
--        "Quantidade": 1,
--        "cd_operador": 0,
--        "cd_usuario": 5044
--    }
--]'

--exec  pr_egis_pcp_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 50,
     
--        "cd_processo": 2,
--        "cd_item_processo": 1,
--        "cd_operacao": 1,
--        "cd_maquina": 1,
--        "Quantidade": 1,
--        "cd_operador": 0,
--        "cd_usuario": 5044
--    }
--]'

--exec  pr_egis_pcp_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 60,
     
--        "cd_processo": 2,
--        "cd_item_processo": 1,
--        "cd_operacao": 1,
--        "cd_maquina": 1,
--        "Quantidade": 1,
--        "cd_operador": 0,
--        "cd_usuario": 5044
--    }
--]'



--exec  pr_egis_pcp_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 10,
     
--        "cd_processo": 2,
--        "cd_item_processo": 1,
--        "cd_operacao": 1,
--        "cd_maquina": 1,
--        "Quantidade": 1,
--        "cd_operador": 0,
--        "cd_usuario": 5044
--    }
--]'
--go


--exec  pr_egis_pcp_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 200,
--        "cd_usuario": 5044,
--        "qt_venda" : 1000
--    }
--]'
--go

------------------------------------------------------------------------------
GO

--delete from solicitacao_beneficiamento_composicao
--delete from solicitacao_beneficiamento
--delete from movimento_apontamento
--update processo_producao set qt_produzido_processo = 0.00

go

--exec  pr_egis_pcp_processo_modulo '[{"cd_parametro": 5, "cd_requisicao_compra": 6}]' 

--exec  pr_egis_pcp_processo_modulo '[{"cd_parametro": 5, 
--"produtos": [
--      { "cd_produto": 242, "qt_produto": 10 },
--      { "cd_produto": 300, "qt_produto": 20 }
--   ],
--"cd_produto": 0}]' 

use egissql_368
go

