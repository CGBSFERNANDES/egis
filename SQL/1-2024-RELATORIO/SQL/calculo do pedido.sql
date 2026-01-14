use egissql_317

go

declare @cd_pedido_venda int = 0

set @cd_pedido_venda = 152768



--select * from Pedido_Venda_Negociacao where cd_pedido_gerado = @cd_pedido_venda

--return



--

--exec pr_preco_tabela_proposta_pedido 1, @cd_pedido_venda, 7

--

--create table #tempST ( vl_base_icms_st float, vl_icms_st float )
 create table #tempST ( vl_icms_st float )

  declare @cd_estado                int  
  declare @pc_icms_estado           float  
  declare @pc_importado_icms_estado float  
  declare @pc_icms_reduzido         float  

  select @cd_estado = c.cd_estado
  from
    pedido_venda pv
	inner join cliente c on c.cd_cliente = pv.cd_cliente
  where
    pv.cd_pedido_venda = @cd_pedido_venda

  Select   
    @pc_icms_estado           = isnull(pc_aliquota_icms_estado,0),  
    @pc_importado_icms_estado = isnull(pc_importado_icms_estado,0),  
    @pc_icms_reduzido         = isnull(qt_base_calculo_icms,0)  
  
  from  
    estado_parametro with (nolock)   
  
  where  
    cd_estado = @cd_estado  

select
  i.*,
  pv.cd_cliente,
  pv.cd_destinacao_produto,
  pf.cd_classificacao_fiscal,
  ISNULL(p.qt_multiplo_embalagem,0) as qt_multiplo_embalagem,
  m.ic_tipo_unidade,
  ic_conversao_preco   = ISNULL(m.ic_conversao_preco,'N'),
  cp.cd_pauta,
    case when tp.ic_imposto_tipo_pedido='N' or isnull(pf.ic_isento_icms_produto,'N')='S' or isnull(cfe.ic_isento_icms_estado,'N')='S'  
    then  
      0.00  
    else  
      case when IsNull(pc_icms_classif_fiscal,0)>0 or cfe.pc_icms_classif_fiscal = 0 then  
        IsNull(pc_icms_classif_fiscal,0)   
      else  
        case when isnull(pf.pc_aliquota_icms_produto,0)>0 and @pc_icms_estado>=isnull(pf.pc_aliquota_icms_produto,0) then  
          isnull(pf.pc_aliquota_icms_produto,0)  
        else  
          case when @pc_importado_icms_estado<>0 and isnull(p.ic_importacao_produto,'N') = 'S' and isnull(pp.ic_icms_prod_importado,'N')='S' then  
            @pc_importado_icms_estado  
          else  
            @pc_icms_estado  
          end  
        end  
       end  
    end                          as pc_icms_item_calculo,
	tp.cd_tipo_pedido



into
  #item

from
  Pedido_Venda_Item i
  inner join pedido_venda pv          on pv.cd_pedido_venda      = i.cd_pedido_venda
  inner join produto_fiscal pf        on pf.cd_produto           = i.cd_produto
  left outer join Procedencia_Produto pp  on pp.cd_procedencia_produto = pf.cd_procedencia_produto   
  inner join Produto p                on p.cd_produto            = i.cd_produto
  inner join categoria_produto cp     on cp.cd_categoria_produto = p.cd_categoria_produto
  inner join Tipo_Pedido tp           on tp.cd_tipo_pedido       = pv.cd_tipo_pedido  	
  left outer join Mob_Tipo_Pedido m   on m.cd_tipo_pedido        = tp.cd_tipo_pedido
  left outer join classificacao_fiscal_estado cfe  
                                      on cfe.cd_classificacao_fiscal = pf.cd_classificacao_fiscal and  
                                         cfe.cd_estado               = @cd_estado  


where
  i.cd_pedido_venda = @cd_pedido_venda


--select * from #item

declare @cd_item_pedido_venda int = 0


  declare @vl_item_icms_st            float = 0.00
  declare @pc_icms_st                 float
  declare @cd_classificacao_fiscal_st int
  declare @vl_produto_st              float = 0.00
  declare @vl_ipi_st                  float 
  declare @cd_destinacao_st           int
  declare @cd_cliente_st              int 
  declare @qt_multiplo_embalagem      decimal(25,2)
  declare @cd_pauta                   int
  declare @cd_produto                 int 
  declare @ic_tipo_unidade            char(1)
  declare @ic_conversao_preco         char(1) 
  declare @cd_tipo_ped                int 

  --select * from pedido_venda_item where cd_pedido_venda = 153017

  while exists (select top 1 cd_item_pedido_venda from #item )  
  begin
    select top 1
      @cd_item_pedido_venda       = i.cd_item_pedido_venda,
	  @cd_produto                 = cd_produto,
      @pc_icms_st                 = i.pc_icms_item_calculo, --i.pc_icms, 
      @cd_classificacao_fiscal_st = i.cd_classificacao_fiscal,
      @cd_destinacao_st           = i.cd_destinacao_produto,
      @cd_cliente_st              = i.cd_cliente,
	  @ic_conversao_preco         = i.ic_conversao_preco,
      @vl_produto_st = case when isnull(i.qt_multiplo_embalagem,0)<>0 and i.ic_tipo_unidade='C' and isnull(i.cd_pauta,0)>0 and i.ic_conversao_preco='S' then    
                          round(isnull(i.vl_unitario_item_pedido,0) * isnull(i.qt_item_pedido_venda,0) / i.qt_multiplo_embalagem,4)    
                     else    
                          --round(cast(isnull(i.vl_unitario_item_consulta,0) * isnull(i.qt_item_consulta,0) as decimal(25,2)),4)
						  isnull(i.vl_unitario_item_pedido,0)
                     end,                                                              

	@vl_ipi_st = case when isnull(i.qt_multiplo_embalagem,0)<>0 and i.ic_tipo_unidade='C'  and isnull(i.cd_pauta,0)>0 and i.ic_conversao_preco='S'  then   
	                             cast( ((isnull(i.vl_unitario_item_pedido,0) * isnull(i.qt_item_pedido_venda,0) * isnull(i.pc_ipi,0)/100 )
								 / i.qt_multiplo_embalagem) as decimal(25,2))
								 else
								   cast(isnull(i.vl_unitario_item_pedido,0) * isnull(i.qt_item_pedido_venda,0) * isnull(i.pc_ipi,0)/100 as decimal(25,2))
								   end,

	@cd_produto                 = i.cd_produto,
	@qt_multiplo_embalagem      = isnull(i.qt_multiplo_embalagem,0),
	@ic_tipo_unidade            = i.ic_tipo_unidade,
	@cd_pauta                   = ISNULL(i.cd_pauta,0),
	@cd_tipo_ped                = i.cd_tipo_pedido

  from
    #item i

  delete from #tempST

  --
  --select @ic_conversao_preco, @cd_pauta, @ic_tipo_unidade, @cd_produto, @cd_cliente_st, @pc_icms_st, @cd_classificacao_fiscal_st, @vl_produto_st, @vl_ipi_st, @cd_destinacao_st, @cd_destinacao_st
  --
  --exec pr_calculo_substituicao_tributaria @cd_produto, 1, @cd_cliente_st, @pc_icms_st, @cd_classificacao_fiscal_st, 
  --                                        @vl_produto_st,
  --                                        @vl_ipi_st, @cd_destinacao_st, 0.00, 0.00


  insert into #tempST 
  exec dbo.pr_calculo_ST  
       1,
       @cd_produto,
       1,
       @cd_cliente_st,
       @pc_icms_st,
       @cd_classificacao_fiscal_st,
       @vl_produto_st,
       @vl_ipi_st,
       @cd_destinacao_st,
       0.00,
       @cd_tipo_ped,
       null

  ----------------------------------------------------------------------------------------------------------------------------------------

  select @vl_item_icms_st = vl_icms_st from #tempST
  
  --select @vl_item_icms_st

  ---select * from #tempST

  update 
    #item  
  set  
   vl_item_icms_st = 0

					  --vl_item_icms_st =  @vl_item_icms_st
  from  
    #item i  
  where
    cd_item_pedido_venda = @cd_item_pedido_venda
  
  update
    Pedido_Venda_Item
  set
    vl_item_icms_st = 0,
	pc_icms_item    = 0,
	pc_icms         = 0,
	PC_IPI = 0
	
  where
    cd_pedido_venda = @cd_pedido_venda
	and
	cd_item_pedido_venda = @cd_item_pedido_venda

  --select vl_item_icms_st,* from consulta_itens where cd_consulta = 59

  
   
  delete from #item
  where
    cd_item_pedido_venda = @cd_item_pedido_venda


end

--Cálculo do Valor Total da Pedido-------------------------------------------------------  
  
declare @vl_total_pedido   decimal(25,2)  
declare @vl_total_ipi      decimal(25,2)  
declare @vl_icms_st        decimal(25,2)  
declare @qt_peso_liquido   decimal(25,2)
declare @qt_peso_bruto     decimal(25,2)
  
set @vl_total_pedido   = 0.00  
set @vl_total_ipi      = 0.00  
set @vl_icms_st        = 0.00  
  
--pedido_venda_item

select   
 @vl_total_pedido   = sum ( cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) as decimal(25,2))),  
 @vl_total_ipi      = sum ( cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) * isnull(pc_ipi,0)/100 as decimal(25,2))),  
 @vl_icms_st        = sum ( cast(isnull(vl_item_icms_st,0) as decimal(25,2)) ),
 @qt_peso_liquido   = sum ( isnull(qt_liquido_item_pedido,0)   ),  
 @qt_peso_bruto     = sum ( isnull(qt_bruto_item_pedido,0)     )  
   
from  
 Pedido_Venda_Item
where
  cd_pedido_venda = @cd_pedido_venda

  
group by  
 cd_pedido_venda
  
--select @vl_total_pedido, @vl_total_ipi, @vl_icms_st

update  
  Pedido_Venda  
set  
  vl_total_pedido_venda    = @vl_total_pedido,
  vl_total_pedido_ipi      = @vl_total_pedido + @vl_total_ipi + @vl_icms_st,   
  vl_total_ipi             = @vl_total_ipi,  
  vl_icms_st               = @vl_icms_st,
  qt_liquido_pedido_venda  = ISNULL(n.vl_peso_pedido_venda,@qt_peso_liquido),
  qt_bruto_pedido_venda    = ISNULL(n.vl_peso_pedido_venda,@qt_peso_bruto)
from
  Pedido_Venda pv 
  left outer join Pedido_Venda_Negociacao n on n.cd_pedido_gerado = pv.cd_pedido_venda
where  
  pv.cd_pedido_venda = @cd_pedido_venda
 
drop table #item
drop table #tempST
