--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL
--USE EGISSQL_357
--go

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_faturamento_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_faturamento_processo_modulo

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_faturamento_processo_modulo
-------------------------------------------------------------------------------
--pr_egis_faturamento_processo_modulo
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
create procedure pr_egis_faturamento_processo_modulo
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
declare @cd_selecao          int           = 0
declare @cd_pedido_venda     int           = 0
declare @cd_modelo           int           = 0
declare @cd_requisicao_faturamento int     = 0

----------------------------------------------------------------------------------------------------------------
declare @dados_registro           nvarchar(max) = ''
declare @dados_modal              nvarchar(max) = ''
----------------------------------------------------------------------------------------------------------------

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

select @cd_empresa                = valor from #json where campo = 'cd_empresa'             
select @cd_documento              = valor from #json where campo = 'cd_documento'
select @cd_relatorio              = valor from #json where campo = 'cd_relatorio'
select @cd_item_documento         = valor from #json where campo = 'cd_item_documento'
select @cd_parametro              = valor from #json where campo = 'cd_parametro'          
select @cd_cliente                = valor from #json where campo = 'cd_cliente'          
select @cd_usuario                = valor from #json where campo = 'cd_usuario'             
select @dt_inicial                = valor from #json where campo = 'dt_inicial'             
select @dt_final                  = valor from #json where campo = 'dt_final'             
select @cd_vendedor               = valor from #json where campo = 'cd_vendedor'
select @cd_menu                   = valor from #json where campo = 'cd_menu'
select @dt_base                   = valor from #json where campo = 'dt_base' 
select @cd_selecao                = valor from #json where campo = 'cd_selecao'
select @cd_requisicao_faturamento = valor from #json where campo = 'cd_requisicao_faturamento'

---------------------------------------------------------------------------------------------
select @dados_registro         = valor from #json where campo = 'dados_registro'
select @dados_modal            = valor from #json where campo = 'dados_modal'

----------------------------------------------------------------------------------------------


--Empresa---------------------------------------------------------------------------------
set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()


--Dados-----------------------------------------------------------------------------------

set @cd_selecao   = isnull(@cd_selecao,0)
set @cd_documento = ISNULL(@cd_documento,0)
set @cd_parametro = isnull(@cd_parametro,0)

-------------------------------------------

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

-----------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--01 - Pedidos de Vendas em Aberto = Carteira
---------------------------------------------------------------------------------------------------------------------------------------------------------    

if @cd_parametro = 1
begin

  select  
    i.dt_entrega_vendas_pedido,
    p.cd_pedido_venda,  
	i.cd_item_pedido_venda,
	isnull(i.qt_saldo_pedido_venda,0)      as qt_saldo_pedido_venda,
	--isnull(spf.qt_selecao_item_pedido,0) as qt_selecao_item_pedido,
    prod.cd_produto,
    prod.cd_mascara_produto,
    prod.nm_fantasia_produto,
    prod.nm_produto,
    um.sg_unidade_medida,

    --Vendedor--
    v.nm_fantasia_vendedor,
    -----------------------
    p.cd_cliente, 
    c.nm_fantasia_cliente,
    c.nm_razao_social_cliente,
    ci.vl_limite_credito_cliente,
    ci.vl_saldo_credito_cliente,
    p.cd_vendedor,  
    p.cd_tipo_pedido,
	p.cd_condicao_pagamento,
	p.cd_forma_pagamento,
	p.cd_transportadora,	
    p.cd_contato             as cd_contato,  
    p.dt_pedido_venda        as dt_pedido_venda,  
    case when i.dt_cancelamento_item is null then        
          i.vl_unitario_item_pedido * i.qt_saldo_pedido_venda         
        else        
         0.00        
        end                                   as vl_saldo_item_pedido,

    isnull(est.sg_estado,'')                  as sg_estado,
    isnull(cid.nm_cidade,'')                  as nm_cidade,
	isnull(ef.nm_fantasia_empresa,'')         as nm_fantasia_empresa,
	isnull(it.nm_itinerario,'')               as nm_itinerario,
    isnull(fpg.nm_forma_pagamento,'')         as nm_forma_pagamento,
	isnull(p.cd_usuario_impressao,0)          as cd_usuario_impressao,

    --Estoque--
    isnull(ps.qt_saldo_reserva_produto,0)     as qt_saldo_reserva_produto,
    isnull(ps.qt_saldo_atual_produto,0)       as qt_saldo_atual_produto
	---------------------------------------------

  into
    #Carteira
  
  from
    pedido_venda_item  i
    left outer join Selecao_Pedido_Faturamento spf with(nolock) on spf.cd_pedido_venda      = i.cd_pedido_venda and
                                                                   spf.cd_item_pedido_venda = i.cd_item_pedido_venda
    inner join produto prod                        with(nolock) on prod.cd_produto          = i.cd_produto
    left outer join unidade_medida um              with(nolock) on um.cd_unidade_medida     = i.cd_unidade_medida
    left outer join fase_produto fp                with(nolock) on fp.cd_fase_produto       = i.cd_fase_produto
    left outer join produto_saldo ps               with(nolock) on ps.cd_produto            = i.cd_produto and
                                                                   ps.cd_fase_produto       = i.cd_fase_produto
    inner join Pedido_Venda p                      with(nolock) on p.cd_pedido_venda        = i.cd_pedido_venda 
	inner join Cliente c                           with(nolock) on c.cd_cliente             = p.cd_cliente
	left outer join Cliente_Informacao_Credito ci  with(nolock) on ci.cd_cliente            = p.cd_cliente
	left outer join Cidade cid                     with(nolock) on cid.cd_cidade            = c.cd_cidade
    left outer join Estado est                     with(nolock) on est.cd_estado            = c.cd_estado
	left outer join pedido_venda_empresa e         with(nolock) on e.cd_pedido_venda        = p.cd_pedido_venda
	left outer join empresa_faturamento ef         with(nolock) on ef.cd_empresa            = e.cd_empresa
	left outer join Itinerario it                  with(nolock) on it.cd_itinerario         = c.cd_itinerario
	inner join Vendedor v                          with(nolock) on v.cd_vendedor            = p.cd_vendedor
	left outer join Tipo_Pedido tp                 with(nolock) on tp.cd_tipo_pedido        = p.cd_tipo_pedido and isnull(tp.ic_aprovacao_tipo_pedido,'N') = 'S'
	left outer join forma_pagamento fpg            with(nolock) on fpg.cd_forma_pagamento   = p.cd_forma_pagamento 

  where
    i.dt_cancelamento_item is null
    and
    isnull(qt_saldo_pedido_venda,0)>0

  order by
    i.dt_entrega_vendas_pedido 

  select distinct * from #Carteira
  order by
    dt_entrega_vendas_pedido

  return

end

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--02 - Pedidos de Vendas em Aberto = Carteira
---------------------------------------------------------------------------------------------------------------------------------------------------------    
/*
if @cd_parametro = 2
begin

  --gravar a tabela Selecao_Pedido_Faturamento com o Json

  return

end
*/

--------------------------------------------------------------------  
--02 - Gravar Seleção para Faturamento
--------------------------------------------------------------------  
if @cd_parametro = 2
begin

  declare 
    --@cd_pedido_venda           int,
    @cd_item_pedido_venda      int,
    @qt_selecao_item_pedido    numeric(18,4),
    @ds_selecao_ocorrencia     nvarchar(4000),
    @nm_obs_selecao            nvarchar(4000),
    @cd_usuario_inclusao       int,
    @dt_selecao                datetime,
    @dt_usuario_inclusao       datetime,
    @dt_usuario                datetime,
    @json_selecao              nvarchar(max);

  -- Campos opcionais no JSON plano

  select @cd_pedido_venda        = try_convert(int,           valor) from #json where campo = 'cd_pedido_venda';
  select @cd_item_pedido_venda   = try_convert(int,           valor) from #json where campo = 'cd_item_pedido_venda';
  select @qt_selecao_item_pedido = try_convert(numeric(18,4), valor) from #json where campo = 'qt_selecao_item_pedido';
  select @ds_selecao_ocorrencia  = try_convert(nvarchar(4000),valor) from #json where campo = 'ds_selecao_ocorrencia';
  select @nm_obs_selecao         = try_convert(nvarchar(4000),valor) from #json where campo = 'nm_obs_selecao';
  select @cd_usuario_inclusao    = try_convert(int,           valor) from #json where campo = 'cd_usuario_inclusao';
  select @json_selecao           = valor                             from #json where campo = 'selecao';

  set @cd_usuario_inclusao = isnull(@cd_usuario_inclusao, @cd_usuario);
  set @dt_selecao          = isnull(@dt_base, getdate());
  set @dt_usuario_inclusao = @dt_selecao;
  set @dt_usuario          = @dt_selecao;

  select @cd_selecao = max(cd_selecao)
  from
    Selecao_Pedido_Faturamento 

  set @cd_selecao = isnull(@cd_selecao,0) + 1

  --select * from Selecao_Pedido_Faturamento

  /*
    Modo A: receber UM item plano por chamada
    [{"cd_parametro":2}, {"cd_pedido_venda":123}, {"cd_item_pedido_venda":1}, {"qt_selecao_item_pedido":5}, ...]
  */
  if (@json_selecao is null) and @cd_pedido_venda is not null and @cd_item_pedido_venda is not null
  begin
    insert into Selecao_Pedido_Faturamento
      (cd_selecao, dt_selecao, cd_pedido_venda, cd_item_pedido_venda, qt_selecao_item_pedido,
       ds_selecao_ocorrencia, nm_obs_selecao,
       cd_usuario_inclusao, dt_usuario_inclusao, cd_usuario, dt_usuario)
    values
      (@cd_selecao, @dt_selecao, @cd_pedido_venda, @cd_item_pedido_venda, isnull(@qt_selecao_item_pedido,0),
       isnull(@ds_selecao_ocorrencia,''), isnull(@nm_obs_selecao,''),
       isnull(@cd_usuario_inclusao,@cd_usuario), @dt_usuario_inclusao, isnull(@cd_usuario,@cd_usuario_inclusao), @dt_usuario);

    select 'ok' as status, @@ROWCOUNT as linhas_inseridas;

    return;

  end

  /*
    Modo B: receber LOTE em @json -> campo "selecao" (array de objetos)
    [{"cd_parametro":2},{"selecao":"[ { ... }, { ... } ]"}]
  */

  if @json_selecao is not null
  begin
    ;with Lote as (
      select 
        --identity(int,1,1) as id,
        *
      from openjson(@json_selecao)
      with (
        --identity(int,1,1)       int             'id',
        cd_pedido_venda         int             '$.cd_pedido_venda',
        cd_item_pedido_venda    int             '$.cd_item_pedido_venda',
        qt_selecao_item_pedido  numeric(18,4)   '$.qt_selecao_item_pedido',
        ds_selecao_ocorrencia   nvarchar(4000)  '$.ds_selecao_ocorrencia',
        nm_obs_selecao          nvarchar(4000)  '$.nm_obs_selecao',
        cd_usuario_inclusao     int             '$.cd_usuario_inclusao',
        cd_usuario              int             '$.cd_usuario',
        dt_selecao              datetime        '$.dt_selecao',
        dt_usuario_inclusao     datetime        '$.dt_usuario_inclusao',
        dt_usuario              datetime        '$.dt_usuario'
      )
    )
    --insert into Selecao_Pedido_Faturamento
    --  (cd_selecao, dt_selecao, cd_pedido_venda, cd_item_pedido_venda, qt_selecao_item_pedido,
    --   ds_selecao_ocorrencia, nm_obs_selecao,
    --   cd_usuario_inclusao, dt_usuario_inclusao, cd_usuario, dt_usuario)
    select 
      @cd_selecao                                as cd_selecao, 
      isnull(l.dt_selecao,          @dt_selecao) as dt_selecao,
      l.cd_pedido_venda,
      l.cd_item_pedido_venda,
      isnull(l.qt_selecao_item_pedido,0)                  as qt_selecao_item_pedido,
      isnull(l.ds_selecao_ocorrencia,'')                  as ds_selecao_ocorrencia,
      isnull(l.nm_obs_selecao,'')                         as nm_obs_selecao,
      isnull(l.cd_usuario_inclusao, @cd_usuario)          as cd_usuario_inclusao,
      isnull(l.dt_usuario_inclusao, @dt_usuario_inclusao) as dt_usuario_inclusao,
      isnull(l.cd_usuario,          @cd_usuario)          as cd_usuario,
      isnull(l.dt_usuario,          @dt_usuario)          as dt_usuario,
      identity(int,1,1)             as cd_interface
    into #LotePedido

    from Lote l
    where l.cd_pedido_venda is not null
      and l.cd_item_pedido_venda is not null;

    update
      #LotePedido
    set
      cd_selecao = cd_selecao + cd_interface

    insert into Selecao_Pedido_Faturamento
      (cd_selecao, dt_selecao, cd_pedido_venda, cd_item_pedido_venda, qt_selecao_item_pedido,
       ds_selecao_ocorrencia, nm_obs_selecao,
       cd_usuario_inclusao, dt_usuario_inclusao, cd_usuario, dt_usuario)
    select 
      cd_selecao,
      dt_selecao,
      cd_pedido_venda,
      cd_item_pedido_venda,
      qt_selecao_item_pedido,
      ds_selecao_ocorrencia,
      nm_obs_selecao,
      cd_usuario_inclusao,
      dt_usuario_inclusao,
      cd_usuario,
      dt_usuario
     
    from #LotePedido

    select 'ok' as status, @@ROWCOUNT as linhas_inseridas;
    return;

  end

  -- Se chegou aqui, faltou algum campo
  raiserror('Bloco 2: informe (cd_pedido_venda, cd_item_pedido_venda) ou o array "selecao".', 16, 1);
  return;

end

--select * from Selecao_Pedido_Faturamento
---------------------------------------------------------------------------------------------------------------------------------------------------------    
--03 - Faturamento dos Pedidos Selecionados
---------------------------------------------------------------------------------------------------------------------------------------------------------    

if @cd_parametro = 3
begin
  --pr_gera_nota_saida_egisnet
  select * into #Selecao from Selecao_Pedido_Faturamento
  --where
  -- cd_pedido_venda not in ( select i.cd_pedido_venda from nota_saida_item'
  
  while exists( select top 1 cd_pedido_venda from #Selecao)
  begin
    select top 1 
      @cd_selecao           = cd_selecao,
      @cd_pedido_venda      = cd_pedido_venda
      --Gera uma Nota para Cada Item
      --@cd_item_pedido_venda = cd_item_pedido_venda
      --------------------------------------------------

    from
      #Selecao

    ---------------------------------------------------------------------------------------------------------
    exec pr_gera_nota_saida_egisnet_selecao 0, @cd_pedido_venda, @cd_usuario, null, null, null, 0, null, null, 'S' 
    ---------------------------------------------------------------------------------------------------------
    
    delete from #Selecao
    where
      cd_pedido_venda = @cd_pedido_venda

  end

  delete from Selecao_Pedido_Faturamento

  select 'Faturamento Gerado' as Msg

  return

end


--------------------------------------------------------------------  
--04 - Consultar Itens Faturados (pós-processo 03)
--------------------------------------------------------------------  
if @cd_parametro = 4
begin
  /*
    Critérios (ajuste conforme sua regra):
    - Período: @dt_inicial/@dt_final; se nulos, usa @dt_base (hoje).
    - Relaciona com a seleção para evitar trazer NFs não ligadas ao processo.
  */
  if @dt_inicial is null set @dt_inicial = cast(@dt_base as date);
  if @dt_final   is null set @dt_final   = cast(@dt_base as date);

  -- Modelo A: Estrutura típica EGIS (nota_saida / nota_saida_item)
  if object_id('nota_saida') is not null and object_id('nota_saida_item') is not null
  begin
    --;with Selecionados as (
    --  select distinct
    --    s.cd_pedido_venda,
    --    s.cd_item_pedido_venda
    --  from Selecao_Pedido_Faturamento s with(nolock)
    --  where cast(s.dt_selecao as date) between cast(@dt_inicial as date) and cast(@dt_final as date)
    --    and (@cd_usuario = 0 or isnull(s.cd_usuario,0) = @cd_usuario)
    --)
    select 
      ns.cd_cliente,
      ns.nm_fantasia_nota_saida                   as nm_fantasia_cliente,
      ns.dt_nota_saida                            as dt_emissao,
      ns.cd_identificacao_nota_saida              as nr_nota,
      nsi.cd_pedido_venda,
      nsi.cd_item_pedido_venda,
      nsi.cd_produto,
      prod.cd_mascara_produto,
      prod.nm_fantasia_produto,
      prod.nm_produto               as nm_produto,
      nsi.qt_item_nota_saida        as qt_faturada,
      nsi.vl_total_item             as vl_total
    from      nota_saida       ns   with(nolock)
    inner join nota_saida_item nsi  with(nolock) on nsi.cd_nota_saida = ns.cd_nota_saida
    left  join produto         prod with(nolock) on prod.cd_produto   = nsi.cd_produto
    --inner join Selecionados    sel  on  sel.cd_pedido_venda     = nsi.cd_pedido_venda
    --                               and sel.cd_item_pedido_venda = nsi.cd_item_pedido_venda
    where cast(ns.dt_nota_saida as date) between cast(@dt_inicial as date) and cast(@dt_final as date)
    order by ns.dt_nota_saida desc, ns.cd_nota_saida desc;

    return;

  end

  -- Modelo B (fallback): ajuste NOME/colunas caso sua base use outros identificadores
  -- Ex.: header: NF_Saida (dt_emissao, nr_nota, cd_nf), itens: NF_Saida_Item (cd_nf, cd_pedido_venda, cd_item, qt, vl_total)
  if object_id('Nota_Saida') is not null and object_id('Nota_Saida_Item') is not null
  begin
    ;with Selecionados as (
      select distinct
        s.cd_pedido_venda,
        s.cd_item_pedido_venda
      from Selecao_Pedido_Faturamento s with(nolock)
      where cast(s.dt_selecao as date) between cast(@dt_inicial as date) and cast(@dt_final as date)
        and (@cd_usuario = 0 or isnull(s.cd_usuario,0) = @cd_usuario)
    )
    select 
      h.dt_nota_saida                  as dt_emissao,
      h.cd_identificacao_nota_saida    as nr_nota,
      i.cd_pedido_venda,
      i.cd_item_pedido_venda,
      i.cd_produto,
      prod.nm_fantasia_produto      as nm_produto,
      i.qt_item_nota_saida          as qt_faturada,
      i.vl_total_item               as vl_total
    from      nota_saida       h   with(nolock)
    inner join nota_saida_item i   with(nolock) on i.cd_nota_saida = h.cd_nota_saida
    left  join produto       prod with(nolock) on prod.cd_produto = i.cd_produto
    inner join Selecionados  sel on sel.cd_pedido_venda = i.cd_pedido_venda
                                 and sel.cd_item_pedido_venda = i.cd_item_pedido_venda
    where cast(h.dt_nota_saida as date) between cast(@dt_inicial as date) and cast(@dt_final as date)
    order by h.dt_nota_saida desc, h.cd_nota_saida desc;

    return;
    
  end

  -- Se nenhum modelo reconhecido, devolve a seleção como "eco" (para teste no front)
  select 
    cast(s.dt_selecao as date)      as dt_emissao,
    0                               as nr_nota,
    s.cd_pedido_venda,
    s.cd_item_pedido_venda,
    null                            as cd_produto,
    cast('Ajuste colunas no bloco 4' as nvarchar(60)) as nm_produto,
    s.qt_selecao_item_pedido        as qt_faturada,
    convert(decimal(18,2),0)        as vl_total
  from Selecao_Pedido_Faturamento s with(nolock)
  where cast(s.dt_selecao as date) between cast(@dt_inicial as date) and cast(@dt_final as date);

  return;
end


--Requisição de Faturamento

if @cd_parametro = 10
begin
  select * from requisicao_faturamento
  where
    cd_requisicao_faturamento = @cd_requisicao_faturamento

  return

end
if @cd_parametro = 20
begin

 declare
    @json_itens nvarchar(max) = ''

  --set @json_itens = isnull(@json_itens, '')


  --select * from @DadosModal

 select @json_itens          = try_convert(nvarchar(max), valor)        from @DadosModal where campo = 'itens'
  
  -- Tabela com os campos/valores do modal
  declare @itens table (
    id    int identity(1,1),
    campo varchar(200),
    valor nvarchar(max)
  )

  if (isnull(@json_itens, '') <> '')
  begin
    insert into @itens (campo, valor)
    select
        m.[key]   as campo,
        m.[value] as valor
    from openjson(@json_itens) as m
  end


  SELECT @json_itens = TRY_CONVERT(NVARCHAR(MAX), valor)
FROM @DadosModal
WHERE campo = 'itens';

-- Transformar em tabela com colunas

SELECT *
FROM OPENJSON(@json_itens)
WITH (
    cd_mascara_produto       NVARCHAR(50)  '$.cd_mascara_produto',
    nm_produto               NVARCHAR(200) '$.nm_produto',
    qt_requisicao_faturamento INT          '$.qt_requisicao_faturamento',
    vl_unitario_requisicao_fa DECIMAL(18,2) '$.vl_unitario_requisicao_fa',
    vl_total_produto          DECIMAL(18,2) '$.vl_total_produto'
);
  --Dados do Modal----------------------------------------

   declare 
     @dt_baixa_documento         date,
     @qt_requisicao_faturamento  float

     --select * from @DadosModal

    select @qt_requisicao_faturamento          = try_convert(float, valor)        from @itens where campo = 'qt_requisicao_faturamento'
  
    --select * from fagner

    --drop table fagner
    --select @qt_requisicao_faturamento as qtd into fagner
     ----
     -------------------------------------------------------------------------
     select @dt_baixa_documento          = try_convert(date, valor)        from @DadosModal where campo = 'dt_baixa_documento'
     --select @cd_tipo_pagamento           = try_convert(int, valor)         from @DadosModal where campo = 'nm_tipo_pagamento'
     

 
  return
end

go
--use egissql_357
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_faturamento_processo_modulo
------------------------------------------------------------------------------
--select * from conta_banco_saldo

go
--Carteira de Pedidos
--exec pr_egis_faturamento_processo_modulo '[{"cd_parametro": 1}, {"cd_documento": 0}, {"dt_inicial":"09/01/2025"}, {"dt_final":"09/30/2025"}]'
go
--exec pr_egis_faturamento_processo_modulo '[{"cd_parametro": 1}, {"cd_documento": 0}]'
go

--exec pr_egis_faturamento_processo_modulo '[{"cd_parametro": 2}, {"cd_documento": 3}, {"dt_inicial":"09/01/2025"}, {"dt_final":"09/30/2025"}]'
go
--exec pr_egis_faturamento_processo_modulo '[{"cd_parametro": 6},{"cd_conta_banco": 1},{"cd_documento": 3}, {"dt_inicial":"09/01/2025"}, {"dt_final":"09/30/2025"}]'
go
------------------------------------------------------------------------------
--use egissql_361

--select * from Selecao_Pedido_Faturamento
--select * from nota_validacao

--use egissql_357
--go
--delete from extrato_bancario
--go
--delete from conta_banco_lancamento
--go


/*
exec pr_egis_faturamento_processo_modulo '[
    {
        "ic_json_parametro": "S",
        "cd_parametro": 20,
        "cd_usuario": 4896,
        "cd_modal": 11,
        "dados_modal": {
            "itens": [
                {
                    "cd_mascara_produto": "1              ",
                    "nm_produto": "ABS CINZA INDUSTRIAL                                        ",
                    "qt_requisicao_faturamento": "11",
                    "vl_unitario_requisicao_fa": 11,
                    "vl_total_produto": 121
                }
            ]
        },
        "dados_registro": [
            {
                "cd_mascara_produto": "",
                "nm_produto": "",
                "qt_requisicao_faturamento": "",
                "vl_unitario_requisicao_fa": "",
                "vl_total_produto": ""
            }
        ]
    }
]'
*/
--exec pr_egis_faturamento_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 20,
--        "cd_usuario": 4896,
--        "cd_modal": 11,
--        "dados_modal": {
--            "itens": [
--                {
--                    "cd_mascara_produto": "1",
--                    "nm_produto": null,
--                    "qt_requisicao_faturamento": "11",
--                    "vl_unitario_requisicao_fa": 11,
--                    "vl_total_produto": 121
--                },
--                {
--                    "cd_mascara_produto": "0.004.80       ",
--                    "nm_produto": "DILUENTE PARA ESMALTES E VERNIZ                             ",
--                    "qt_requisicao_faturamento": "22",
--                    "vl_unitario_requisicao_fa": 22,
--                    "vl_total_produto": 484
--                }
--            ]
--        },
--        "dados_registro": [
--            {
--                "cd_mascara_produto": "",
--                "nm_produto": "",
--                "qt_requisicao_faturamento": "",
--                "vl_unitario_requisicao_fa": "",
--                "vl_total_produto": ""
--            }
--        ]
--    }
--]'

--select * from fagner
--use egissql_357
--go