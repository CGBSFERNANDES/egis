IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_api_gera_cadastro_pedido_venda' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_api_gera_cadastro_pedido_venda

GO

-------------------------------------------------------------------------------
--sp_helptext pr_api_gera_cadastro_pedido_venda
-------------------------------------------------------------------------------
--pr_api_gera_cadastro_pedido_venda
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql
--
--Objetivo         : Geração do Cadastro do Cliente
--Data             : 22.12.2021
--Alteração        : 
--
-- 29.07.2014 - Novos campos - Carlos Fernandes
-- 02.07.2021 - Novo Campo ic_identificacao_entrada - Pedro Jardim
-- 27.12.2021 - Correção de alguns campos - Denis Rabello
-- 07.04.2022 - Ajustes para salvar corretamento o cliente(CNPJ ou CPF) - Denis Rabello
-- 26.10.2022 - ajustes Diversos - Carlos Fernandes
-- 17.01.2023 - Ajuste no cd_inscricao_estadual e ic_isento_insc_cliente - Denis Rabello
------------------------------------------------------------------------------ 
create procedure pr_api_gera_cadastro_pedido_venda  
@json nvarchar(max) = ''
  
as  
  
 set @json = isnull(@json,'')

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
declare @cd_cliente           int = 0  
declare @cd_tipo_pessoa       int = 0
declare @cd_destinatario      int = 0
declare @name                 varchar(60)   = ''
declare @email                varchar(150)  = ''
declare @phone                varchar(15)   = ''
declare @cnpj                 varchar(18)   = ''
declare @endereco             nvarchar(max) = ''
declare @cd_cep               varchar(8)    = ''
declare @nm_endereco          varchar(60)   = ''
declare @cd_numero            varchar(10)   = ''
declare @nm_cidade            varchar(60)   = ''
declare @sg_estado            varchar(2)    = ''
declare @nm_bairro            varchar(20)   = ''
declare @cd_cidade            int           = 0
declare @cd_estado            int           = 0
declare @cd_vendedor          int           = 0
declare @cd_pedido_venda      int           = 0
declare @orderId              int           = 0
declare @clienteId            int           = 0
declare @cd_produto           int           = 0
declare @vl_unitario          decimal(25,2) = 0.00
declare @vl_unitario_digitado decimal(25,2) = 0.00
declare @qt_produto           decimal(25,4) = 0.00

--cliente

----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano            = year(getdate())
set @cd_mes            = month(getdate())  
set @endereco          = ''

----------------------------------------------------------------------------------------------------------------

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end

--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

----------------------------------------------------------------------------------------

select                     

 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

-- extrair o objeto address

SELECT 
    j.id_registro,
    i.[key]   AS cd_controle,   -- índice do array
    i.[value] AS itemJson,
    p.productId,
    p.quantity,
    p.price
INTO #ItemProduto
FROM #json j
CROSS APPLY OPENJSON(j.valor) i
CROSS APPLY OPENJSON(i.value) WITH (
    productId NVARCHAR(50) '$.productId',
    quantity  INT          '$.quantity',
    price     DECIMAL(18,2)'$.price'
) p
WHERE j.campo = 'items';


 
--select * from #json
--select * from #ItemProduto

--------------------------------------------------------------------------------------------

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo' 
select @name                   = valor from #json where campo = 'name' 
select @email                  = valor from #json where campo = 'email'
select @phone                  = valor from #json where campo = 'phone'
select @cnpj                   = valor from #json where campo = 'cnpj'
select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
select @cd_pedido_venda        = valor from #json where campo = 'cd_pedido_venda'
select @cd_cliente             = valor from #json where campo = 'cd_cliente'
select @clienteId              = valor from #json where campo = 'clientId'
select @orderId                = valor from #json where campo = 'orderId'

 


set @cd_empresa = ISNULL(@cd_empresa,0)
set @cd_cliente = isnull(@cd_cliente,0)
set @clienteId  = isnull(@clienteId,0)

if @cd_cliente = 0 and @clienteId>0
   set @cd_cliente = @clienteId

--------------------------------------------------------------------------------------

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()


--select @cd_cliente, @clienteId
--return

--select top 0 * into #Pedido from Pedido_Venda
--select top 0 * into #Item   from Pedido_Venda_Item

--insert into #Pedido ( cd_pedido_venda ) values ( 1,1 )
--insert into #Item ( cd_pedido_venda,cd_item_pedido_venda ) values ( 1,1 )

-----------------------------------------------------------------


  declare @ic_atraso   char(1)
  declare @cd_clientei int
  declare @vl_saldo    float
  declare @vl_pedido   float

  set @cd_empresa = dbo.fn_empresa()
  set @ic_atraso = 'N'
  set @vl_saldo  = 0.00
  set @vl_pedido = 0.00


declare @cd_pedido_venda_ref      int
declare @qt_dia_validade_proposta int
declare @nm_fantasia_cliente      varchar(30)
declare @ic_baixa_estoque         char(1)
declare @cd_tipo_pedido           int
declare @ic_gera_pedido_empresa   char(1)
declare @ic_aprovacao_tipo_pedido char(1)
declare @ic_imposto_tipo_pedido   char(1)
declare @cd_tabela_preco          int = 0

declare @qt_itens int = 0
declare @qt_total_caixa int = 0
declare @qt_total_unidades int = 0
declare @qt_itens_val int = 0
declare @qt_total_caixa_val int = 0
declare @qt_total_unidades_val int = 0




  declare @cd_importacao_web      int
  declare @cd_item_importacao_web int

  select @cd_importacao_web = max(cd_importacao_web) from log_importacao_web

  if @cd_importacao_web is null or @cd_importacao_web = 0
    set @cd_importacao_web = 0

  set @cd_importacao_web = @cd_importacao_web + 1

  insert into log_importacao_web
  (cd_importacao_web, nm_importacao_web, dt_importacao_web, cd_cliente, ds_log_importacao_web, 
   cd_usuario_inclusao, dt_usuario_inclusao, cd_usuario, dt_usuario)
  values
  (@cd_importacao_web, 'Geração Pedido Venda - Importação API', getdate(), @cd_cliente, null,
   @cd_usuario, getdate(), @cd_usuario, getdate())

  --
       

  if @cd_cliente=0
  begin
     select 0 as cd_movimento, 'Pedido sem Cliente !' as Msg, 'N' as ic_alerta
     return
   end

   if not exists(select cd_cliente from Cliente where cd_cliente = @cd_cliente)
   begin
     select 0 as cd_movimento, 'O Cliente informado não existe na base de Dados!' as Msg, 'N' as ic_alerta
     return
   end



  select 
    top 1
    @nm_fantasia_cliente      = c.nm_fantasia_cliente,
    @ic_baixa_estoque         = isnull(tp.ic_gera_baixa_estoque,'N'),              
    @cd_tipo_pedido           = case when isnull(tpe.cd_tipo_pedido,0) = 0 then tp.cd_tipo_pedido else tpe.cd_tipo_pedido end,
    @ic_gera_pedido_empresa   = isnull(tp.ic_gera_pedido_empresa,'N'),
    @ic_aprovacao_tipo_pedido = isnull(tp.ic_aprovacao_tipo_pedido,'N'),
    @ic_imposto_tipo_pedido   = isnull(tp.ic_imposto_tipo_pedido,'N'),
    @cd_tabela_preco          = case when isnull(ce.cd_tabela_preco,0)>0 then ce.cd_tabela_preco else c.cd_tabela_preco end
  from 
    Cliente c
    Left Outer Join Cliente_Empresa ce on ce.cd_cliente      = c.cd_cliente
                                    and ce.ic_padrao       = 'S'
    Left Outer Join Tipo_Pedido tp     on tp.cd_tipo_pedido  = c.cd_tipo_pedido
    Left Outer Join Tipo_Pedido tpe    on tpe.cd_tipo_pedido = ce.cd_tipo_pedido
  where 
    c.cd_cliente = @cd_cliente
 
 if @cd_tabela_preco = 0
 begin
   select 0 as cd_movimento, 'O Cliente está sem tabela de Preço definida no cadastro !' as Msg, 'N' as ic_alerta
   return
 end

 declare @Tabela varchar(80) = ''
 set @Tabela = cast(DB_NAME()+'.dbo.Pedido_Venda' as varchar(80))
 
 ---------------
 exec sp_PegaCodigoDB @Tabela, 'cd_pedido_venda', 0, @cd_usuario, @codigo = @cd_pedido_venda output
 ---------------


 --set @cd_pedido_venda = (select max(isnull(cd_pedido_venda,0)) + 1 from Pedido_Venda)
 --select @ic_atraso, @vl_saldo

	--Gera PV em aberto
	declare @ic_gera_pedido_venda_aberto char(1) = 'N'
    select top 1 @ic_gera_pedido_venda_aberto = isnull(ic_gera_pedido_venda_aberto,'N') from Parametro_CRM where cd_empresa = @cd_empresa

 --select * from cadastro

 --Itens-------------------------------------------------


  select
    @qt_itens_val         = sum(1),
    @qt_total_caixa_val    = sum(isnull(cast(quantity as int),0)),
    @qt_total_unidades_val = sum(isnull(cast(0 as int),0))
  from
    #ItemProduto

  select
    identity(int,1,1) as cd_item_pedido_venda,
    p.cd_produto,
    quantity as qt_produto,
    price    as vl_produto,
    p.cd_mascara_produto,
    p.nm_fantasia_produto,
    p.cd_unidade_medida

    --saldo de estoque aqui se necessário--
  
  into
    #itens

  from
    #ItemProduto i
    inner join produto p on p.cd_mascara_produto = i.productId

  order by
     p.cd_mascara_produto

    --select * from #itens
    --select * from cliente where cd_cliente = 1001

    --return
 
  if exists( select top 1 cd_produto from #Itens where isnull(cd_produto,0)=0 )
  begin
    select 0 as cd_movimento, 'Existem produtos não cadastrado para gerar o Pedido de Venda !' as Msg, 'N' as ic_alerta
    return
  end
	
  
----------------------------------------------------------------------------------------------------------------------------

  --Validar Saldo Estoque-- 

  select
    p.cd_fase_produto_baixa     as cd_fase_produto,
    i.qt_produto                as qt_item,
    i.cd_unidade_medida,
    isnull(ps.qt_saldo_reserva_produto,0) as qt_saldo_atual_produto,
    p.cd_produto                as cd_produto,
    p.nm_fantasia_produto       as nm_fantasia_produto, 
    p.nm_produto                as nm_produto
  
  into
    #SaldoEstoque

  from
    #Itens i
    inner join produto p        with(nolock) on p.cd_produto       = i.cd_produto
    inner join Produto_Saldo ps with(nolock) on ps.cd_produto      = p.cd_produto      
                                            and ps.cd_fase_produto = p.cd_fase_produto_baixa
  
  where
    isnull(i.qt_produto,0)>0
    and
    i.qt_produto > isnull(ps.qt_saldo_reserva_produto,0)


  --select * from #SaldoEstoque
  --return


  if exists (select * from #SaldoEstoque )
  begin
    declare @nm_saldo_insuficiente varchar(2000)

    print 'Há Itens com Saldo Insuficiente'

    set @nm_saldo_insuficiente = 'Os seguintes itens estão com Saldo Insuficiente: '

    select @nm_saldo_insuficiente = @nm_saldo_insuficiente + nm_fantasia_produto + ', '
    from #SaldoEstoque

    --select @nm_saldo_insuficiente as Msg, 0 as Cod, 'N' as ic_alerta
    drop table #SaldoEstoque
	
  end

  --return

----------------------------------------------------------------------------------------------------------------------------

--=====Pedido Venda=========================================================================================================

select 
  top 0 * 
into 
  #PedidoVenda
from
  Pedido_Venda

insert into #PedidoVenda ( cd_pedido_venda ) values ( @cd_pedido_venda )

update
  #PedidoVenda
set
  cd_pedido_venda               = @cd_pedido_venda, 
  dt_pedido_venda               = @dt_hoje,
  cd_vendedor_pedido            = case when isnull(c.cd_vendedor,0) = 0         then @cd_vendedor else isnull(c.cd_vendedor,0) end,
  cd_vendedor_interno           = case when isnull(c.cd_vendedor_interno,0) = 0 then 1            else isnull(c.cd_vendedor_interno,0) end,
  ic_emitido_pedido_venda       = 'S',
  ds_pedido_venda               = cast('' as varchar),
  ds_pedido_venda_fatura        = cast('' as varchar),
  ds_cancelamento_pedido        = cast('' as varchar),
  cd_usuario_credito_pedido     = null, --case when (@ic_atraso = 'S' or @vl_saldo < isnull(c.vl_total_consulta,0)) then null else @cd_usuario end,
  dt_credito_pedido_venda       = null, --case when (@ic_atraso = 'S' or @vl_saldo < isnull(c.vl_total_consulta,0)) then null else @dt_hoje    end,
  ic_smo_pedido_venda           = 'N',
  vl_total_pedido_venda         = 0.00,
  qt_liquido_pedido_venda       = NULL,
  qt_bruto_pedido_venda         = NULL,
  dt_conferido_pedido_venda     = NULL,
  ic_pcp_pedido_venda           = 'N',
  ic_lista_pcp_pedido_venda     = 'N',
  ic_processo_pedido_venda      = 'N',
  ic_lista_processo_pedido      = 'N',
  ic_imed_pedido_venda          = 'N',
  ic_lista_imed_pedido          = 'N',
  nm_alteracao_pedido_venda     = NULL,
  ic_consignacao_pedido         = 'N',
  dt_cambio_pedido_venda        = NULL,
  cd_cliente_entrega            = NULL,
  ic_op_triang_pedido_venda     = 'N',
  ic_nf_op_triang_pedido        = 'N',
  nm_contato_op_triang          = NULL,
  cd_pdcompra_pedido_venda      = NULL, --c.cd_pedido_compra_consulta,
  cd_processo_exportacao        = NULL,
  cd_cliente                    = c.cd_cliente,
  cd_tipo_frete                 = null,
  cd_tipo_restricao_pedido      = null,
  cd_destinacao_produto         = c.cd_destinacao_produto,
  cd_tipo_pedido                = @cd_tipo_pedido,
  cd_transportadora             = c.cd_transportadora,
  cd_vendedor                   = case when isnull(c.cd_vendedor,0) = 0 then 7 else isnull(c.cd_vendedor,0) end,
  cd_tipo_endereco              = null,
  cd_moeda                      = c.cd_moeda,
  cd_contato                    = null,
  cd_usuario                    = @cd_usuario,
  dt_usuario                    = getdate()  ,
  dt_cancelamento_pedido        = NULL       ,
  cd_condicao_pagamento         = c.cd_condicao_pagamento,
  cd_status_pedido              = 1,--case when @ic_baixa_estoque = 'N' then 1 else 2 end,
  cd_tipo_entrega_produto       = 1,--c.cd_tipo_entrega_produto,
  nm_referencia_consulta        = cast(@orderId as varchar(40)), --cast(c.cd_pedido_compra_consulta as varchar),
  vl_custo_financeiro           = 0.00,
  ic_custo_financeiro           = NULL,
  vl_tx_mensal_cust_fin         = NULL,
  cd_tipo_pagamento_frete       = c.cd_tipo_pagamento_frete,
  nm_assina_pedido              = NULL,
  ic_fax_pedido                 = NULL,
  ic_mail_pedido                = NULL,
  vl_total_pedido_ipi           = 0.00, --c.vl_total_consulta + ISNULL(c.vl_icms_st,0) + ISNULL(c.vl_total_ipi,0),
  vl_total_ipi                  = 0.00, --c.vl_total_ipi,
  ds_observacao_pedido          = 'Entrada Planilha', --isnull(c.ds_observacao_consulta,''),
  cd_usuario_atendente          = @cd_usuario,
  ic_fechado_pedido             = 'S',
  ic_vendedor_interno           = 'N',
  cd_representante              = NULL,
  ic_transf_matriz              = NULL,
  ic_digitacao                  = NULL,
  ic_pedido_venda               = 'S',
  hr_inicial_pedido             = SUBSTRING(CONVERT(VARCHAR,SYSDATETIME()),12,8),
  ic_outro_cliente              = 'N',
  ic_fechamento_total           = 'S',
  ic_operacao_triangular        = 'N',
  ic_fatsmo_pedido              = 'N',
  ds_ativacao_pedido            = cast('' as varchar),
  dt_ativacao_pedido            = NULL,
  ds_obs_fat_pedido             = NULL, --c.ds_obs_fat_consulta,
  ic_obs_corpo_nf               = 'N', --case when isnull(cast(c.ds_obs_fat_consulta as varchar(2000)),'') = '' then 'N' else 'S' end,
  dt_fechamento_pedido          = @dt_hoje, --case when isnull(@ic_gera_pedido_venda_aberto,'N') = 'N' then @dt_hoje else null end,
  cd_cliente_faturar            = NULL,
  cd_tipo_local_entrega         = c.cd_tipo_local_entrega,
  ic_etiq_emb_pedido_venda      = 'N',
  cd_consulta                   = NULL, --c.cd_consulta,
  dt_alteracao_pedido_venda     = NULL,
  ic_dt_especifica_ped_vend     = NULL,
  ic_dt_especifica_consulta     = NULL,
  ic_fat_pedido_venda           = 'N',
  ic_fat_total_pedido_venda     = 'N',
  qt_volume_pedido_venda        = NULL,
  qt_fatpbru_pedido_venda       = NULL,
  ic_permite_agrupar_pedido     = 'N',
  qt_fatpliq_pedido_venda       = NULL,
  vl_indice_pedido_venda        = NULL,
  vl_sedex_pedido_venda         = NULL,
  pc_desconto_pedido_venda      = NULL,
  pc_comissao_pedido_venda      = NULL,
  cd_plano_financeiro           = NULL,
  ds_multa_pedido_venda         = NULL,
  vl_freq_multa_ped_venda       = NULL,
  vl_base_multa_ped_venda       = NULL,
  pc_limite_multa_ped_venda     = NULL,
  pc_multa_pedido_venda         = NULL,
  cd_fase_produto_contrato      = NULL,
  nm_obs_restricao_pedido       = NULL,
  cd_usu_restricao_pedido       = NULL,
  dt_lib_restricao_pedido       = NULL,
  nm_contato_op_triang_ped      = NULL,
  ic_amostra_pedido_venda       = 'N',
  ic_alteracao_pedido_venda     = 'N',
  ic_calcula_sedex              = 'N',
  vl_frete_pedido_venda         = NULL,
  ic_calcula_peso               = 'N',
  ic_subs_trib_pedido_venda     = 'N',
  ic_credito_icms_pedido        = 'N',
  cd_usu_lib_fat_min_pedido     = NULL,
  dt_lib_fat_min_pedido         = NULL,
  cd_identificacao_empresa      = NULL,
  pc_comissao_especifico        = NULL,
  dt_ativacao_pedido_venda      = NULL,
  cd_exportador                 = NULL,
  ic_atualizar_valor_cambio_fat = NULL,
  cd_tipo_documento             = NULL,
  cd_loja                       = NULL,
  cd_usuario_alteracao          = NULL,
  ic_garantia_pedido_venda      = NULL,
  cd_aplicacao_produto          = NULL,
  ic_comissao_pedido_venda      = 'S',
  cd_motivo_liberacao           = NULL,
  ic_entrega_futura             = 'N',
  modalidade                    = NULL,
  modalidade1                   = NULL,
  cd_modalidade                 = NULL,
  cd_pedido_venda_origem        = NULL,
  dt_entrada_pedido             = @dt_hoje,
  dt_cond_pagto_pedido          = NULL,
  cd_usuario_cond_pagto_ped     = NULL,
  vl_credito_liberacao          = NULL,
  vl_credito_liberado           = NULL,
  cd_centro_custo               = NULL,
  ic_bloqueio_licenca           = NULL,
  cd_licenca_bloqueada          = NULL,
  nm_bloqueio_licenca           = NULL,
  dt_bloqueio_licenca           = NULL,
  cd_usuario_bloqueio_licenca   = NULL,
  vl_mp_aplicacada_pedido       = NULL,
  vl_mo_aplicada_pedido         = NULL,
  cd_usuario_impressao          = NULL,
  cd_cliente_origem             = NULL,
  cd_situacao_pedido            = NULL,
  qt_total_item_pedido          = NULL,
  ic_bonificacao_pedido_venda   = NULL,
  pc_promocional_pedido         = NULL,
  cd_tipo_reajuste              = NULL,
  vl_icms_st                    = NULL, --c.vl_icms_st,
  cd_tabela_preco               = case when isnull(ce.cd_tabela_preco,0)=0 then c.cd_tabela_preco else ce.cd_tabela_preco end,
  vl_desconto_pedido_venda      = NULL,
  cd_fornecedor                 = NULL,
  vl_sinal_pedido_venda         = NULL,
  cd_forma_pagamento            = i.cd_forma_pagamento,
  cd_motivo_cancel_pedido       = NULL,
  vl_total_icms_desoneracao     = NULL

from
  Cliente c
  left outer join cliente_informacao_credito i on i.cd_cliente  = c.cd_cliente
  left outer join cliente_empresa ce           on ce.cd_cliente = c.cd_cliente
  

where 
  c.cd_cliente = @cd_cliente

--select * from #PedidoVenda
--return

insert into Pedido_Venda
select * from #PedidoVenda

--Gera o Pedido de Venda Negociação
insert into pedido_venda_negociacao 
select 
cd_pedido_venda,
0.00 as vl_st_pedido_venda,
0.00 as vl_peso_pedido_venda,
cast('' as varchar) as nm_obs_pedido_negociação,
null as cd_usuario_inclusao,
null as dt_usuario_inclusao,
1 as cd_usuario,
getdate() as dt_usuario,
null as cd_tabela_preco,
null as cd_pedido_gerado
from
  #PedidoVenda 
where 
  cd_pedido_venda = @cd_pedido_venda
  and
  cd_pedido_venda not in ( select cd_pedido_venda from pedido_venda_negociacao )

---------------------------------------------------------------------------------------------------------------------------------------
drop table #PedidoVenda



	declare @cd_empresa_faturamento int = 0
	set @cd_empresa_faturamento = isnull((select top 1 cd_empresa from cliente_empresa where cd_cliente = @cd_cliente),0)

	if @cd_empresa_faturamento>0
	begin
	insert into Pedido_Venda_Empresa (
		cd_pedido_venda,
		cd_empresa,
		cd_usuario_inclusao,
		dt_usuario_inclusao,
		cd_usuario,
		dt_usuario
	) values(
		@cd_pedido_venda,
		@cd_empresa_faturamento,
		@cd_usuario,
		getdate(),
		@cd_usuario,
		getdate()
	)
	end

insert into Pedido_Venda_Diversos (cd_pedido_venda, ic_mp66_total_pedido, cd_usuario, dt_usuario, vl_sinal_pedido_venda,
cd_forma_pagamento, dt_limite_entrega, ic_montagem_campo, ic_inspecao, ic_start_up,
ic_supervisao, ic_multa, vl_multa, pc_multa, nm_documento_referencia, nm_complemento,
cd_coordenador, cd_local, dt_vencimento_pagamento, cd_empreendimento, cd_numero_endereco, 
nm_complemento_endereco, nm_bairro, cd_cep, cd_identifica_cep, cd_estado, cd_cidade, cd_pais,
cd_cei_empreendimento, cd_cno_empreendimento, nm_empreendimento, nm_endereco, ic_imediato, dt_entrada_vendas,
dt_entrada_fabrica, ic_recalculo_ipi, ic_pedido_urgente, cd_base, qt_distancia_cliente,
dt_envio_ordem_compra) values ( --select * from Pedido_Venda_Diversos pr_geracao_pedido_venda_registro_venda
           @cd_pedido_venda, --cd_pedido_venda
           NULL, --ic_mp66_total_pedido
           @cd_usuario, --cd_usuario
           getdate(), --dt_usuario
           NULL, --vl_sinal_pedido_venda
           NULL, --cd_forma_pagamento
           NULL, --dt_limite_entrega
           NULL, --ic_montagem_campo
           NULL, --ic_inspecao
           NULL, --ic_start_up
           NULL, --ic_supervisao
           NULL, --ic_multa
           NULL, --vl_multa
           NULL, --pc_multa
           NULL, --nm_documento_referencia
           NULL, --nm_complemento
           NULL, --cd_coordenador
           NULL, --cd_local
           NULL, --dt_vencimento_pagamento
           NULL, --cd_empreendimento
           NULL, --cd_numero_endereco
           NULL, --nm_complemento_endereco
           NULL, --nm_bairro
           NULL, --cd_cep
           NULL, --cd_identifica_cep
           NULL, --cd_estado
           NULL, --cd_cidade
           NULL, --cd_pais
           NULL, --cd_cei_empreendimento
           NULL, --cd_cno_empreendimento
           NULL, --nm_empreendimento
           NULL, --nm_endereco
           NULL, --ic_imediato
           NULL, --dt_entrada_vendas
           NULL, --dt_entrada_fabrica
           NULL, --ic_recalculo_ipi
           NULL, --ic_pedido_urgente
           NULL, --cd_base
           NULL, --qt_distancia_cliente
		   NULL  --dt_envio_ordem_compra
           )


exec sp_LiberaCodigoDB @Tabela, 'cd_pedido_venda', @cd_pedido_venda, 0, 'D'
--select * from pedido_venda

--====Itens do Pedido de Venda================================================================================

select 
  top 0 * 
into 
  #PedidoVendaItem
from
  Pedido_Venda_Item

--insert into #PedidoVendaItem ( cd_pedido_venda, cd_item_pedido_venda ) values ( @cd_pedido_venda, 0 )

--select * from cadastro


    declare @cd_item            int
    declare @cd_item_consulta   int
	declare @qt_qtde            float
	declare @vl_total           float
	declare @nm_historico       varchar(255)
	declare @cd_fase_produto    int
	declare @nm_produto         varchar(120) = ''
	declare @cd_unidade_medida  int = 0
	declare @cd_mascara_produto varchar(30) = ''


set @cd_item = 1

--#Itens é a tabela temporária que recebi do Json

while exists ( select top 1 cd_item_pedido_venda from #Itens )
begin


	select 
	  top 1
	 -- @cd_parametro     = cd_consulta,
	  @cd_item_consulta   = i.cd_item_pedido_venda,
	  @cd_produto         = p.cd_produto,
	  @qt_qtde            = i.qt_produto,
	  @vl_unitario        = isnull(tpp.vl_tabela_produto,0) * case when i.cd_unidade_medida = 2 then isnull(p.qt_multiplo_embalagem,1) else 1 end,
	  @vl_total           = i.qt_produto * (isnull(tpp.vl_tabela_produto,0) * case when i.cd_unidade_medida = 2 then isnull(p.qt_multiplo_embalagem,1) else 1 end),
	  @nm_historico       =  'PV ' + cast(@cd_pedido_venda as varchar) + ' - It.' + cast(@cd_item as varchar) + ' - ' + cast(@nm_fantasia_cliente as varchar),
	  @cd_fase_produto    = p.cd_fase_produto_baixa,
	  @nm_produto         = p.nm_produto,
	  @cd_unidade_medida  = p.cd_unidade_medida,
	  @cd_mascara_produto = p.cd_mascara_produto,
      @vl_unitario_digitado = isnull(i.price,0)

    from
      #Itens i
	  inner join cliente cli              on cli.cd_cliente       = @cd_cliente
	  inner join produto p                on p.cd_mascara_produto = i.cd_mascara_produto
	  left outer join tabela_preco_produto tpp on tpp.cd_tabela_preco  = @cd_tabela_preco and tpp.cd_produto = p.cd_produto

    if @vl_unitario <> @vl_unitario_digitado and @vl_unitario_digitado>0
    begin
      set @ic_aprovacao_tipo_pedido = 'S'
    end

    insert into #PedidoVendaItem ( cd_pedido_venda, cd_item_pedido_venda ) values ( @cd_pedido_venda, @cd_item_consulta )
	--select @cd_pedido_venda, @cd_item_consulta
	--select * from #PedidoVendaItem

    update
      pvi
    set
      --cd_pedido_venda             = @cd_pedido_venda,
      --cd_item_pedido_venda        = @cd_item_consulta, --isnull(i.cd_item_consulta,1),
      dt_item_pedido_venda        = @dt_hoje,
      qt_item_pedido_venda        = @qt_qtde,
      qt_saldo_pedido_venda       = case when @ic_baixa_estoque = 'N' then @qt_qtde else 0 end ,
      dt_entrega_vendas_pedido    = @dt_hoje, --case when i.dt_entrega_consulta is null then @dt_hoje else i.dt_entrega_consulta end, --NULL,
      dt_entrega_fabrica_pedido   = NULL,
      ds_produto_pedido_venda     = 'Entrada API', --cast(isnull(i.ds_produto_consulta,'') as varchar),
      vl_unitario_item_pedido     = @vl_unitario,
      vl_lista_item_pedido        = @vl_unitario,
      pc_desconto_item_pedido     = 0,
      dt_cancelamento_item        = NULL,
      dt_estoque_item_pedido      = NULL,
      cd_pdcompra_item_pedido     = 'Verbal',
      dt_reprog_item_pedido       = NULL,
      qt_liquido_item_pedido      = p.qt_peso_liquido * case when (isnull(p.qt_multiplo_embalagem,0) = 0) or (@cd_unidade_medida = 1) then 1 else isnull(p.qt_multiplo_embalagem,0) end,
      qt_bruto_item_pedido        = p.qt_peso_bruto * case when (isnull(p.qt_multiplo_embalagem,0) = 0) or (@cd_unidade_medida = 1) then 1 else isnull(p.qt_multiplo_embalagem,0) end,
      ic_fatura_item_pedido       = NULL,
      ic_reserva_item_pedido      = NULL,
      ic_tipo_montagem_item       = NULL,
      ic_montagem_g_item_pedido   = 'N',
      ic_subs_tributaria_item     = NULL,
      cd_posicao_item_pedido      = NULL,
      cd_os_tipo_pedido_venda     = NULL,
      ic_desconto_item_pedido     = NULL,
      dt_desconto_item_pedido     = NULL,
      vl_indice_item_pedido       = NULL,
      cd_grupo_produto            = p.cd_grupo_produto,
      cd_produto                  = @cd_produto,
      cd_grupo_categoria          = cp.cd_grupo_categoria,
      cd_categoria_produto        = p.cd_categoria_produto,
      cd_pedido_rep_pedido        = NULL,
      cd_item_pedidorep_pedido    = NULL,
      cd_ocorrencia               = NULL,
      cd_consulta                 = NULL,
      cd_usuario                  = @cd_usuario,
      dt_usuario                  = getdate(),
      nm_mot_canc_item_pedido     = NULL,
      nm_obs_restricao_pedido     = NULL,
      cd_item_consulta            = NULL,
      ic_etiqueta_emb_pedido      = 'N',
      pc_ipi_item                 = 0.00,
      pc_icms_item                = 0.00,
      pc_reducao_base_item        = NULL,
      dt_necessidade_cliente      = NULL,
      qt_dia_entrega_cliente      = NULL,
      dt_entrega_cliente          = NULL,
      ic_smo_item_pedido_venda    = NULL,
      cd_om                       = NULL,
      ic_controle_pcp_pedido      = NULL,
      nm_mat_canc_item_pedido     = NULL,
      cd_servico                  = NULL,
      ic_produto_especial         = 'N',
      cd_produto_concorrente      = NULL,
      ic_orcamento_pedido_venda   = 'S',
      nm_produto_pedido           = @nm_produto,
      ds_produto_pedido           = cast('' as varchar),
      cd_serie_produto            = NULL,
      pc_ipi                      = NULL,
      pc_icms                     = NULL,
      qt_dia_entrega_pedido       = NULL,
      ic_sel_fechamento           = case when isnull(@ic_gera_pedido_venda_aberto,'N') = 'N' then 'S' else 'N' end,
      dt_ativacao_item            = NULL,
      nm_mot_ativ_item_pedido     = NULL,
      nm_fantasia_produto         = p.nm_fantasia_produto,
      ic_etiqueta_emb_ped_venda   = 'N',
      dt_fechamento_pedido        = case when isnull(@ic_gera_pedido_venda_aberto,'N') = 'N' then @dt_hoje else null end,
      ds_progfat_pedido_venda     = cast('' as varchar),
      ic_pedido_venda_item        = 'P',
      ic_ordsep_pedido_venda      = NULL,
      ic_progfat_item_pedido      = NULL,
      qt_progfat_item_pedido      = NULL,
      cd_referencia_produto       = NULL,
      ic_libpcp_item_pedido       = NULL,
      ds_observacao_fabrica       = cast('' as varchar),
      nm_observacao_fabrica1      = NULL,
      nm_observacao_fabrica2      = NULL,
      cd_unidade_medida           = @cd_unidade_medida,
      pc_reducao_icms             = NULL,
      pc_desconto_sobre_desc      = NULL,
      nm_desconto_item_pedido     = NULL,
      cd_item_contrato            = NULL,
      cd_contrato_fornecimento    = NULL,
      nm_kardex_item_ped_venda    = NULL,
      ic_gprgcnc_pedido_venda     = NULL,
      cd_pedido_importacao        = NULL,
      cd_item_pedido_importacao   = NULL,
      dt_progfat_item_pedido      = NULL,
      qt_cancelado_item_pedido    = NULL,
      qt_ativado_pedido_venda     = NULL,
      cd_mes                      = month(getdate()),
      cd_ano                      = year(getdate()),
      ic_mp66_item_pedido         = 'N',
      ic_montagem_item_pedido     = 'N',
      ic_reserva_estrutura_item   = 'N',
      ic_estrutura_item_pedido    = 'N',
      vl_frete_item_pedido        = NULL,
      cd_usuario_lib_desconto     = NULL,
      dt_moeda_cotacao            = NULL,
      vl_moeda_cotacao            = NULL,
      cd_moeda_cotacao            = NULL,
      dt_zera_saldo_pedido_item   = NULL,
      cd_lote_produto             = NULL,
      cd_num_serie_item_pedido    = NULL,
      cd_lote_item_pedido         = NULL,
      ic_controle_mapa_pedido     = NULL,
      cd_tipo_embalagem           = NULL,
      dt_validade_item_pedido     = NULL,
      cd_movimento_caixa          = NULL,
      vl_custo_financ_item        = NULL,
      qt_garantia_item_pedido     = NULL,
      cd_tipo_montagem            = NULL,
      cd_montagem                 = NULL,
      cd_usuario_ordsep           = NULL,
      ic_kit_grupo_produto        = NULL,
      cd_sub_produto_especial     = NULL,
      cd_plano_financeiro         = NULL,
      dt_fluxo_caixa              = NULL,
      ic_fluxo_caixa              = NULL,
      ds_servico_item_pedido      = cast('' as varchar),
      dt_reservado_montagem       = NULL,
      cd_usuario_montagem         = NULL,
      ic_imediato_produto         = 'S',
      cd_mascara_classificacao    = cf.cd_mascara_classificacao,
      cd_desenho_item_pedido      = NULL,
      cd_rev_des_item_pedido      = NULL,
      cd_centro_custo             = NULL,
      qt_area_produto             = NULL,
      cd_produto_estampo          = NULL,
      vl_digitado_item_desconto   = NULL,
      cd_lote_Item_anterior       = NULL,
      cd_programacao_entrega      = NULL,
      ic_estoque_fatura           = NULL,
      ic_estoque_venda            = NULL,
      ic_manut_mapa_producao      = NULL,
      pc_comissao_item_pedido     = NULL,
      cd_produto_servico          = NULL,
      ic_baixa_composicao_item    = NULL,
      vl_unitario_ipi_produto     = NULL,
      ic_desc_prom_item_pedido    = NULL,
      cd_tabela_preco             = NULL,
      cd_motivo_reprogramacao     = NULL,
      qt_estoque                  = NULL,
      dt_estoque                  = NULL,
      dt_atendimento              = NULL,
      qt_atendimento              = NULL,
      nm_forma                    = NULL,
      cd_documento                = NULL,
      cd_item_documento           = NULL,
      nm_obs_atendimento          = NULL,
      qt_atendimento_1            = NULL,
      qt_atendimento_2            = NULL,
      qt_atendimento_3            = NULL,
      vl_bc_icms_st               = NULL,
      vl_item_icms_st             = NULL,
      ic_sel_mrp_item_pedido      = NULL,
      vl_aux_unitario_item_pedido = NULL,
      cd_it_ped_compra_cliente    = NULL,
      dt_ordsep_pedido_venda      = NULL,
      cd_situacao_pedido          = NULL,
      ic_venda_saldo_negativo     = NULL,
      cd_motivo_cancel_pedido     = NULL,
      cd_item_pedido_origem       = NULL,
      cd_fase_produto             = @cd_fase_produto,
      hr_entrega                  = NULL,
      vl_icms_desoneracao         = null
    
    from
      #PedidoVendaItem pvi
      inner join #Itens i                     on i.cd_item_pedido_venda      = pvi.cd_item_pedido_venda
      inner join produto p                    on p.cd_mascara_produto        = @cd_mascara_produto   
      left outer join categoria_produto cp    on cp.cd_categoria_produto     = p.cd_categoria_produto
      left outer join produto_fiscal pf       on pf.cd_produto               = p.cd_produto
      left outer join classificacao_fiscal cf on cf.cd_classificacao_fiscal  = pf.cd_classificacao_fiscal

    where
      pvi.cd_item_pedido_venda = @cd_item_consulta

	--------------------------------------------------------------------------


--=========Reserva Estoque Pedido Venda=================================================================
    exec dbo.pr_Movimenta_estoque  
         @ic_parametro=1,
      	 @cd_tipo_movimento_estoque=2,
      	 @cd_tipo_movimento_estoque_old=0,
      	 @cd_produto=@cd_produto,
      	 @cd_fase_produto=@cd_fase_produto,
      	 @qt_produto_atualizacao=@qt_qtde,
      	 @qt_produto_atualizacao_old=0,
      	 @dt_movimento_estoque=@dt_hoje,
      	 @cd_documento_movimento=@cd_pedido_venda,
      	 @cd_item_documento=@cd_item_consulta,
      	 @cd_tipo_documento_estoque=7,
      	 @dt_documento_movimento=@dt_hoje,
      	 @cd_centro_custo=0,
      	 @vl_unitario_movimento=@vl_unitario,
      	 @vl_total_movimento=@vl_total,
      	 @ic_peps_movimento_estoque='N',
      	 @ic_terceiro_movimento='N',
      	 @nm_historico_movimento=@nm_historico,
      	 @ic_mov_movimento='S',
      	 @cd_fornecedor=0,
      	 @ic_fase_entrada_movimento='S',
      	 @cd_fase_produto_entrada=0,
      	 @cd_usuario=@cd_usuario,
      	 @dt_usuario=@dt_hoje,
      	 @cd_tipo_destinatario=1,
      	 @nm_destinatario=@nm_fantasia_cliente,
      	 @cd_item_composicao=NULL,
      	 @cd_lote_produto=NULL,
      	 @ic_atualiza_saldo_lote='N'

--=====Baixa Estoque Quando Pedido N8==========================================================================================

  if @ic_baixa_estoque = 'S'
  begin
     exec dbo.pr_Movimenta_estoque  
       @ic_parametro=1,
  	   @cd_tipo_movimento_estoque=11,
  	   @cd_tipo_movimento_estoque_old=0,
  	   @cd_produto=@cd_produto,
  	   @cd_fase_produto=@cd_fase_produto,
  	   @qt_produto_atualizacao=@qt_qtde,
  	   @qt_produto_atualizacao_old=0,
  	   @dt_movimento_estoque=@dt_hoje,
  	   @cd_documento_movimento=@cd_pedido_venda,
  	   @cd_item_documento=@cd_item_consulta,
  	   @cd_tipo_documento_estoque=7,
  	   @dt_documento_movimento=@dt_hoje,
  	   @cd_centro_custo=0,
  	   @vl_unitario_movimento=@vl_unitario,
  	   @vl_total_movimento=@vl_total,
  	   @ic_peps_movimento_estoque='N',
  	   @ic_terceiro_movimento='N',
  	   @nm_historico_movimento=@nm_historico,
  	   @ic_mov_movimento='S',
  	   @cd_fornecedor=0,
  	   @ic_fase_entrada_movimento='S',
  	   @cd_fase_produto_entrada=0,
  	   @cd_usuario=@cd_usuario,
  	   @dt_usuario=@dt_hoje,
  	   @cd_tipo_destinatario=1,
  	   @nm_destinatario=@nm_fantasia_cliente,
  	   @cd_item_composicao=NULL,
  	   @cd_lote_produto=NULL,
  	   @ic_atualiza_saldo_lote='S'
  end
  
--=============================================================================================================================


 --set @cd_item = @cd_item + 1
  
  delete from #Itens where cd_item_pedido_venda = @cd_item_consulta 

end
    drop table #Itens

    insert into Pedido_Venda_Item
    select p.* from #PedidoVendaItem p
	where
	  p.cd_pedido_venda not in ( select i.cd_pedido_venda from pedido_venda_item i where i.cd_pedido_venda = p.cd_pedido_venda and i.cd_item_pedido_venda = p.cd_item_pedido_venda )
	order by cd_item_pedido_venda
	
	drop table  #PedidoVendaItem
	--select * from #PedidoVendaItem

--drop table cadastro
--select * into CADASTRO FROM egissql_317.dbo.cadastro
--select * from cadastro

----------------------------------------------------------------------------------------------------
-->> Atualiza Data Estoque e Qtd. Estoque
----------------------------------------------------------------------------------------------------

update
  Pedido_Venda_Item
set
 dt_estoque = m.dt_movimento_estoque,
 qt_estoque = case when isnull(ps.qt_saldo_reserva_produto,0) >= ISNULL(m.qt_movimento_estoque,0)  then 
                m.qt_movimento_estoque
              else   
			          case when ISNULL(ps.qt_saldo_reserva_produto,0)<=0 then 0
				        else
				          case when ISNULL(ps.qt_saldo_reserva_produto,0)>0 and ISNULL(ps.qt_saldo_reserva_produto,0)<ISNULL(m.qt_movimento_estoque,0) then
      					     m.qt_movimento_estoque - ps.qt_saldo_reserva_produto
			      		  end
				        end
      				end
from
  pedido_venda_item i            with(nolock)
  inner join movimento_estoque m with(nolock)   on m.cd_documento_movimento = i.cd_pedido_venda 
                                               and m.cd_item_documento      = i.cd_item_pedido_venda 
                                               and m.cd_produto             = i.cd_produto           
                                               and m.cd_fase_produto        = i.cd_fase_produto
  inner join Produto p           with(nolock)   on p.cd_produto = i.cd_produto  
  left outer join Produto_Saldo ps with(nolock) on ps.cd_produto            = i.cd_produto
                                               and ps.cd_fase_produto       = case when isnull(i.cd_fase_produto,0)>0 then
                                                                                isnull(i.cd_fase_produto,p.cd_fase_produto_baixa) 
                                         				    												  else
                                        																        p.cd_fase_produto_baixa
                                        																      end
where
  isnull(m.cd_tipo_movimento_estoque,0) = 2
  and
  i.cd_pedido_venda = @cd_pedido_venda
----------------------------------------------------------------------------------------------------
  --Atualiza os Totais do Pedido de Venda--------------------------------------------------------------  
   
  declare @vl_total_pedido  decimal(25,2)
  declare @qt_total_liquido decimal(25,2)
  declare @qt_total_bruto   decimal(25,2)
  
  set @vl_total_pedido  = 0.00  
  set @qt_total_liquido = 0.00
  set @qt_total_bruto   = 0.00
  
  select  
    @vl_total_pedido  = sum ( qt_item_pedido_venda * vl_unitario_item_pedido ),
	@qt_total_liquido = sum (qt_liquido_item_pedido),
	@qt_total_bruto   = sum(qt_bruto_item_pedido)
  from  
    pedido_venda_item  
  where  
     cd_pedido_venda = @cd_pedido_venda  
  
    
   update  
     pedido_venda  
   set  
     vl_total_pedido_venda   = @vl_total_pedido,  
     vl_total_pedido_ipi     = @vl_total_pedido,
     qt_liquido_pedido_venda = @qt_total_liquido,
     qt_bruto_pedido_venda   = @qt_total_bruto
   from  
     pedido_venda  
   where  
     cd_pedido_venda = @cd_pedido_venda  


--Atualização---------------------------------------------------------------------------------------
--09.08.2024


	declare @cd_pedido_venda_historico int = 0
	select top 1 @cd_pedido_venda_historico = (isnull(max(cd_pedido_venda_historico),0)+@cd_item) from pedido_venda_Historico

	insert into Pedido_Venda_Historico (
			cd_pedido_venda_historico,
			cd_pedido_venda,
			dt_pedido_venda_historico,
			cd_historico_pedido,
			nm_pedido_venda_histor_1,
			cd_item_pedido_venda,
			cd_usuario,
			dt_usuario,
			cd_processo
			)
			select top 1
			@cd_pedido_venda_historico                                          as cd_pedido_venda_historico,
			@cd_pedido_venda,
			getdate()                                                           as dt_pedido_venda_historico,
			1 as cd_historico_pedido,
			cast('Pedido Venda No. ' as varchar(23)) + CAST(@cd_pedido_venda as varchar(9)) 
			                                                                    as nm_pedido_venda_histor_1,
			0                                                                   as cd_item_pedido_venda,
			@cd_usuario as cd_usuario,
			getdate() as dt_usuario,
			''

--------------------------------------------------------------------------------------------------------------------------------------

  if @ic_aprovacao_tipo_pedido='S'
  begin
    --pr --> pr_aprovacao

    print 'aprovacao'

  end

  --select @cd_pedido_venda as cd_movimento, 'Movimento realizado com sucesso' as Msg, 'N' as ic_alerta

  --return

  --select * from pedido_venda order by cd_pedido_venda desc


---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    

------------------------------------------------------------------------------------------------------

set @dt_hoje        = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)      
  

set @cd_parametro         = ISNULL(@cd_parametro,0)

IF ISNULL(@cd_parametro,0) = 0
BEGIN
  select 
    'Sucesso' as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final,
     @cd_usuario  AS cd_usuario

  RETURN;

END

if @cd_parametro = 9 and @cd_pedido_venda>0
begin

  select 
    'success'                        as 'status',
    'Pedido cadastrado com sucesso'  as 'message',
    @cd_pedido_venda                 as 'orderId'

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

go

 

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_api_gera_cadastro_pedido_venda '[{
  
--  "orderId": "123456",
--  "clientId": "1001",
--  "date": "2025-02-10",
--  "items": [
--    {
--      "productId": "01.03.0004.005",
--      "quantity": 10,
--      "price": 36.17
--    },
--    {
--      "productId": "100",
--      "quantity": 10,
--      "price": 36.17
--    }
--  ],
--  "totalValue": 361.70
--}]'


--select * from pedido_venda_item

--use egissql_273
--go

--delete from cliente where cd_cliente = 18926
--go

--select cd_vendedor, * from cliente where cd_cnpj_cliente = '12345678000195'

------------------------------------------------------------------------------