--select * from consulta_itens

select 
  tp.nm_tipo_proposta,
  v.nm_fantasia_vendedor,
  c.cd_vendedor,
  c.cd_cliente,
  cli.cd_cliente_grupo,
  cli.nm_fantasia_cliente,
  cli.nm_razao_social_cliente,
  c.cd_consulta,
  c.dt_consulta,
  c.dt_usuario,

  --Itens---------------------------------------------------------------------------
  i.cd_item_consulta, 
  i.qt_item_consulta,
  i.qt_item_consulta * p.qt_multiplo_embalagem as qt_saida_estoque,
  p.qt_multiplo_embalagem,
  ps.qt_saldo_reserva_produto, 
  i.cd_produto,  
  p.cd_mascara_produto,
  p.nm_produto,
  um.sg_unidade_medida,
  p.cd_familia_produto,
  ic_falta_estoque = (case when i.qt_item_consulta * p.qt_multiplo_embalagem > ps.qt_saldo_reserva_produto
  then  
     'S'
  else
    CAST('N' as char(1))
  end),                            --as nm_obs_situacao
  vl_total_item = 
  cast(
  round(
  --preço do produto
  ( i.vl_unitario_item_consulta * i.qt_item_consulta ) 
  +
  --ipi
  ( i.vl_unitario_item_consulta * i.qt_item_consulta ) * isnull(i.pc_ipi,0)/100
  +
  --icms st
  i.vl_item_icms_st,2) as decimal(25,2))

  ---------------------------------------------------------------------------------

  into
    #CONSULTA

from
  consulta_itens i
                          inner join consulta c             on c.cd_consulta        = i.cd_consulta
						  inner join produto p              on p.cd_produto         = i.cd_produto
						  left outer join tipo_proposta tp  on tp.cd_tipo_proposta  = c.cd_tipo_proposta
						  left outer join cliente cli       on cli.cd_cliente       = c.cd_cliente
						  left outer join produto_saldo ps  on ps.cd_produto        = i.cd_produto and
						                                      ps.cd_fase_produto    = i.cd_fase_produto
                          left outer join vendedor v        on v.cd_vendedor        = c.cd_vendedor
						  left outer join unidade_medida um on um.cd_unidade_medida = i.cd_unidade_medida
	                      where
						     i.cd_consulta = c.cd_consulta and
							 isnull(i.cd_pedido_venda,0)=0 and
							 i.dt_perda_consulta_itens is null 
							 and isnull(i.ic_sel_fechamento,'N') = 'N'
 
 order by
   c.cd_consulta

select 
  MIN(c.dt_consulta)                     as dt_consulta,
  c.cd_produto,  
  c.cd_mascara_produto,
  c.nm_produto,
  c.sg_unidade_medida,
  MAX(c.qt_saida_estoque)                as qt_saida_estoque,
  MAX(c.qt_multiplo_embalagem)           as Embalagen,
  MAX(c.qt_saldo_reserva_produto)        as qt_disponivel,
  COUNT(distinct c.cd_consulta)          as qt_consulta,
  count(distinct c.cd_cliente)           as qt_cliente,
  count(distinct c.cd_vendedor)          as qt_vendedor,
  count(distinct c.cd_familia_produto)   as qt_familia_produto,
  COUNT(distinct c.cd_cliente_grupo)     as qt_grupo_cliente,
  sum(c.vl_total_item)                   as vl_total_item

into #Ruptura
from #Consulta c
where
  c.ic_falta_estoque = 'S'
group by
  c.cd_produto,  
  c.cd_mascara_produto,
  c.nm_produto,
  c.sg_unidade_medida

 select * from #Ruptura order by dt_consulta, qt_saida_estoque desc

   
   drop table #Ruptura
   drop table #CONSULTA


   return


--requisicao_fabricacao

--declare @cd_requisicao int

--select
--  @cd_requisicao = max(cd_requisicao)
--from
--  requisicao_fabricacao

--set @cd_requisicao = isnull(@cd_requisicao,0) + 1

--select
--  @cd_requisicao as cd_requisicao,
--  @dt_hoje       as dt_requisicao,
--  1              as cd_motivo_requisicao,
--  @cd_usuario    as cd_usuario_requisicao,
--  cd_departamento,
--cd_centro_custo,
--cd_aplicacao_produto,
--dt_necessidade,
--'N'              as ic_liberada_requisicao,
-- null            as dt_liberacao_requisicao
-- cast('Falta de Estoque no processo comercial' as varchar(200)) as ds_requisicao,
-- null                                                           as dt_cancelamento_requisicao,
-- @cd_usuario as cd_usuario,
-- getdate()   as dt_usuario,
-- null        as cd_identificacao_requisicao,
-- null        as dt_estoque_req_fabricacao,
-- 'N'         as ic_lib_estoque_req_fabricacao

-- into #RF


-- insert into Requisicao_Fabricacao
-- select * from #RF


-- --requisicao_fabricacao_item
 
-- select
--   @cd_requisicao    as cd_requisicao,
--   identity(int,1,1) as cd_item_requisicao
--   p.cd_produto,
--   p.nm_produto      as nm_produto_requisicao,
--   qt_item_requisicao
--   null               as cd_processo_producao
--   @cd_usuario        as cd_usuario,
--   getdate()          as dt_usuario,
--   p.cd_fase_produto  as cd_fase_produto,
--   cast('' as varchar(40)) as nm_obs_item_req_fab,
--   'N'                     as ic_estoque_req_fabricacao,
--   null                    as qt_fabricada_req_fab,
--   null                    as dt_item_estoque_req,
--   p.cd_unidade_medida,
--   cast('' as varchar)     as ds_item_req_fabricacao,
--   null                    as cd_processo,
--   null                    as cd_item_pedido_venda,
--   null                    as cd_pedido_venda,
--   'N'                     as ic_estoque_requisicao,
--   p.cd_mascara_produto

--from
--   #mov m
--   inner join produto p on p.cd_produto = m.cd_produto

--insert into requisicao_fabricacao_item
--select * from #mov

-- drop table #RF
-- drop table #mov



