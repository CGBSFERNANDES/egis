IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_extrato_financeiro_servico_cliente' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_extrato_financeiro_servico_cliente

GO

-------------------------------------------------------------------------------
--sp_helptext pr_extrato_financeiro_servico_cliente
-------------------------------------------------------------------------------
--pr_extrato_financeiro_servico_cliente
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2012
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql
--
--Objetivo         : 
--Data             : 06.09.2012
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_extrato_financeiro_servico_cliente
@cd_ordem_servico  int      = 0,
@cd_cliente        int      = 0,
@cd_analista       int      = 0,
@dt_inicial        datetime = '',
@dt_final          datetime = '',
@ic_ordem          char(1)  = 'C',
@ic_tipo_relatorio char(1) = 'T'    --(T)otal
                                    --(H)oras
                                    --(D)espesas
                                    --(R)esumo


-- C = a cliente
-- A = Analista

as


if @ic_tipo_relatorio is null 
   set @ic_tipo_relatorio = 'T'
--select * from cliente
--select * from ordem_servico_analista_item

--tabelas:
--  ordem_servico_analista
--  ordem_servico_analista_item
--  ordem_servico_analista_despesa
-- analista

select
--  identity(int,1,1)                 as cd_controle,  
  '1'                               as cd_tipo,
  cast('' as varchar)               as nm_tipo,


  cst.Referencia                     as Referencia,                   --Contrato

  os.cd_ordem_servico,
  os.dt_ordem_servico,
  os.dt_lancto_ordem_servico,

--  os.nm_ref_ordem_servico,

  case when isnull(os.nm_ref_ordem_servico,'')='' then
   cast (os.cd_ordem_servico as varchar(15))
  else
    os.nm_ref_ordem_servico
  end                               as nm_ref_ordem_servico,                   --Contrato


  os.nm_solicit_ordem_servico,

  --Consultor / Analista----------------------------------------------------------------------

  a.cd_analista,
  a.nm_analista,
  a.nm_fantasia_analista,

  --Nota de Débito-----------------------------------------------------------------------------
  
  case when isnull(vwf.cd_identificacao_nota_saida,0) <> 0 then
    0
     else
       case when isnull(i.cd_nota_debito_despesa,0)>0 then
         i.cd_nota_debito_despesa
      else
        nd.cd_nota_debito_despesa  
      end
  end                                          as cd_nota_debito_despesa,

  isnull(nd.vl_nota_debito,0)                  as vl_nota_debito,

  --cliente------------------------------------------------------------------------------------
  c.cd_cliente,
  c.nm_fantasia_cliente,
  c.nm_razao_social_cliente,


  --Dados das Horas----------------------------------------------------------------------------

  s.nm_servico,
  i.nm_hora_inicio_ordem,
  i.nm_hora_fim_ordem,
  i.nm_hora_intervalo,
  i.qt_item_normal_ordem,
  i.qt_item_extra1_ordem,
  i.qt_item_extra2_ordem,
  i.qt_item_desloc_ordem,

  0.00                                as qt_item,

  case when @ic_ordem = 'C' then
    i.vl_servico_ordem_servico
  else
    a.vl_analista
  end                                  as vl_servico_ordem_servico,
  
  round( (
               (cast(datepart(hh, cast(i.qt_item_normal_ordem as DATETIME))as float)+(cast(datepart(mi, cast(i.qt_item_normal_ordem as DATETIME)) as float)  / 60)) +  
               (cast(datepart(hh, cast(i.qt_item_extra1_ordem as DATETIME))as float)+(cast(datepart(mi, cast(i.qt_item_extra1_ordem as DATETIME)) as float ) / 60)) 


  ),1) * 

  case when @ic_ordem = 'C' then
    case when isnull(i.vl_servico_ordem_servico,0)=0 then
      (isnull(s.vl_servico,a.vl_analista )) 
    else
      isnull(vl_servico_ordem_servico,0)
     end
  else
    a.vl_analista
  end                                            as vl_total_servico,

--   round( (
--                (cast(datepart(hh, cast(os.qt_total_normal_ordem as DATETIME))as float)+(cast(datepart(mi, cast(os.qt_total_normal_ordem as DATETIME)) as float) /60)) +  
--                (cast(datepart(hh, cast(os.qt_total_extra_ordem as DATETIME))as float)+(cast(datepart(mi, cast(os.qt_total_extra_ordem as DATETIME)) as float) /60)) 
-- 
-- 
--   ),0) * 
-- 
--   case when @cd_analista = 0 then
-- 
--     case when isnull(vl_servico_ordem_servico,0)=0 then
--       (isnull(s.vl_servico,a.vl_analista )) 
--     else
--       isnull(vl_servico_ordem_servico,0)
--     end
--   else
--     a.vl_analista
-- 
--    end                                            
    0.00   as vl_total_geral,
    a.vl_analista,
    0.00   as vl_item_despesa_ordem,
    cast('' as varchar) as   nm_tipo_despesa,
    vwf.cd_identificacao_nota_saida,
    cast('' as char(1)) as   ic_consultor_despesa,
    0.00 as vl_adiantamento_analista

into
  #Extrato_Servico

from
  Ordem_Servico_Analista os                         with (nolock)
  left outer join cliente c                         on c.cd_cliente            = os.cd_cliente
  left outer join analista a                        on a.cd_analista           = os.cd_analista
  left outer join Ordem_Servico_Analista_Item i     on i.cd_ordem_servico      = os.cd_ordem_servico
  left outer join servico s                         on s.cd_servico            = i.cd_servico
  left outer join vw_contrato_servico_total cst     on cst.cd_contrato_servico = os.cd_contrato_servico
  left outer join vw_extrato_servico_nota_debito nd on nd.cd_ordem_servico     = os.cd_ordem_servico
  left outer join vw_total_nota_pedido_venda vwf    on vwf.cd_pedido_venda     = os.cd_pedido_venda
  
where
  isnull(i.qt_item_normal_ordem,0)>0 and
  os.cd_cliente  = case when @cd_cliente  = 0 then os.cd_cliente  else @cd_cliente  end and
  os.cd_analista = case when @cd_analista = 0 then os.cd_analista else @cd_analista end and
  os.dt_ordem_servico between @dt_inicial and @dt_final

union all

select
  '2'                               as cd_tipo,
  cast('' as varchar)               as nm_tipo,

  cst.Referencia,                   --Contrato

  os.cd_ordem_servico,
  os.dt_ordem_servico,
  os.dt_lancto_ordem_servico,

--  os.nm_ref_ordem_servico,

  case when isnull(os.nm_ref_ordem_servico,'')='' then
   cast (os.cd_ordem_servico as varchar(15))
  else
    os.nm_ref_ordem_servico
  end                               as nm_ref_ordem_servico,                   --Contrato

  os.nm_solicit_ordem_servico,

  --Consultor / Analista----------------------------------------------------------------------

  a.cd_analista,
  a.nm_analista,
  a.nm_fantasia_analista,

  --Nota de Débito-----------------------------------------------------------------------------

  nd.cd_nota_debito_despesa,
  nd.vl_nota_debito,

  --cliente------------------------------------------------------------------------------------
  c.cd_cliente,
  c.nm_fantasia_cliente,
  c.nm_razao_social_cliente,


  --Dados das Despesas---------------------------------------

  cast(td.nm_tipo_despesa as varchar(60))  as nm_servico,
  cast('' as varchar(08))                  as nm_hora_inicio_ordem,
  cast('' as varchar(08))                  as nm_hora_fim_ordem,
  cast('' as varchar(08))                  as nm_hora_intervalo,
  0                                        as qt_item_normal_ordem,
  0                                        as qt_item_extra1_ordem,
  0                                        as qt_item_extra2_ordem,
  0                                        as qt_item_desloc_ordem,

  isnull(od.qt_item_despesa_ordem,0)       as qt_item,

  case when  ( @ic_ordem = 'C' and isnull(td.ic_sel_km_tipo_despesa,'N') = 'N' )
  then
   od.vl_item_despesa_ordem
  else
   case when @ic_ordem = 'A' and isnull(td.ic_sel_km_tipo_despesa,'N') = 'S' then
     isnull(a.vl_km_analista,0)
   else
     od.vl_item_despesa_ordem
   end

   end                                     
                                    as vl_servico_ordem_servico,
  
--   od.qt_item_despesa_ordem
--   * 
--   --od.vl_item_despesa_ordem               
--   case when @cd_analista=0 or isnull(td.ic_sel_km_tipo_despesa,'N') = 'N' 
--   then
--     od.vl_item_despesa_ordem
--   else
--     case when isnull(td.ic_sel_km_tipo_despesa,'N') = 'S' then
--       isnull(a.vl_km_analista,0)
--     else
--      0.00
--     end
-- 
--   end                                     

     0.00                                       as vl_total_servico,

  od.qt_item_despesa_ordem
  * 
--  od.vl_item_despesa_ordem 
  case when  ( @ic_ordem = 'C' and isnull(td.ic_sel_km_tipo_despesa,'N') = 'N' )
  then
    od.vl_item_despesa_ordem
  else
    case when @ic_ordem = 'A' and isnull(td.ic_sel_km_tipo_despesa,'N') = 'S' then
      isnull(a.vl_km_analista,0)
    else
     od.vl_item_despesa_ordem
    end

  end                                     
                                            as vl_total_geral,
  a.vl_analista,
  od.vl_item_despesa_ordem,
  td.nm_tipo_despesa,
  0 as     cd_identificacao_nota_saida,
  isnull(od.ic_consultor_despesa,'N')  as ic_consultor_despesa,
  --isnull(a.vl_adiantamento_analista,0) as vl_adiantamento_analista
  0.00 as vl_adiantamento_analista

from
  Ordem_Servico_Analista os                         with (nolock)
  left outer join cliente c                         on c.cd_cliente            = os.cd_cliente
  left outer join analista a                        on a.cd_analista           = os.cd_analista
--   left outer join Ordem_Servico_Analista_Item i     on i.cd_ordem_servico      = os.cd_ordem_servico
--   left outer join servico s                         on s.cd_servico            = i.cd_servico
  left outer join vw_contrato_servico_total cst     on cst.cd_contrato_servico = os.cd_contrato_servico
  left outer join vw_extrato_servico_nota_debito nd on nd.cd_ordem_servico     = os.cd_ordem_servico
  left outer join ordem_servico_analista_despesa od on od.cd_ordem_servico     = os.cd_ordem_servico
  left outer join tipo_despesa td                   on td.cd_tipo_despesa      = od.cd_tipo_despesa
  
where
  isnull(od.qt_item_despesa_ordem,0)>0 and 
  os.cd_cliente  = case when @cd_cliente  = 0 then os.cd_cliente  else @cd_cliente  end and
  os.cd_analista = case when @cd_analista = 0 then os.cd_analista else @cd_analista end and
  os.dt_ordem_servico between @dt_inicial and @dt_final
  and
  isnull(od.ic_consultor_despesa,'N') = case when isnull(@cd_analista,0) <> 0 then 'S' else isnull(od.ic_consultor_despesa,'N') end
                                        
  and
  isnull(od.ic_cliente_despesa,'N')   = 'S'


union all

select
  distinct
  '3'                               as cd_tipo,
  cast('' as varchar)               as nm_tipo,

  cst.Referencia,                   --Contrato

  os.cd_ordem_servico,
  os.dt_ordem_servico,
  os.dt_lancto_ordem_servico,

--  os.nm_ref_ordem_servico,

  case when isnull(os.nm_ref_ordem_servico,'')='' then
   cast (os.cd_ordem_servico as varchar(15))
  else
    os.nm_ref_ordem_servico
  end                               as nm_ref_ordem_servico,                   --Contrato

  os.nm_solicit_ordem_servico,

  --Consultor / Analista----------------------------------------------------------------------

  a.cd_analista,
  a.nm_analista,
  a.nm_fantasia_analista,

  --Nota de Débito-----------------------------------------------------------------------------

  0 as cd_nota_debito_despesa,
  0 as vl_nota_debito,

  --cliente------------------------------------------------------------------------------------
  c.cd_cliente,
  c.nm_fantasia_cliente,
  c.nm_razao_social_cliente,


  --Dados das Despesas---------------------------------------

  cast('Adiantamento     ' as varchar(60))  as nm_servico,
  cast('' as varchar(08))                   as nm_hora_inicio_ordem,
  cast('' as varchar(08))                   as nm_hora_fim_ordem,
  cast('' as varchar(08))                   as nm_hora_intervalo,
  0                                         as qt_item_normal_ordem,
  0                                         as qt_item_extra1_ordem,
  0                                         as qt_item_extra2_ordem,
  0                                         as qt_item_desloc_ordem,

  0                                         as qt_item,

  0.00                                      as vl_servico_ordem_servico,

  0.00                                      as vl_total_servico,


  0.00                                      as vl_total_geral,

  a.vl_analista,
  0.00 as vl_item_despesa_ordem,
  cast('' as varchar)                       as nm_tipo_despesa,
  0 as     cd_identificacao_nota_saida,
  cast('' as varchar)                       as ic_consultor_despesa,
  isnull(a.vl_adiantamento_analista,0)      as vl_adiantamento_analista

from
  Ordem_Servico_Analista os                         with (nolock)
  left outer join cliente c                         on c.cd_cliente            = os.cd_cliente
  left outer join analista a                        on a.cd_analista           = os.cd_analista
  left outer join vw_contrato_servico_total cst     on cst.cd_contrato_servico = os.cd_contrato_servico
  left outer join vw_extrato_servico_nota_debito nd on nd.cd_ordem_servico     = os.cd_ordem_servico
  
where
  isnull(a.vl_adiantamento_analista,0) > 0 and
  os.cd_analista = case when @cd_analista = 0 then os.cd_analista else @cd_analista end and
  os.dt_ordem_servico between @dt_inicial and @dt_final
  and @ic_ordem = 'A'

order by
  os.dt_ordem_servico

--Mostra a tabela geral---------------------------------------------------------------------------------------------

--select * from #Extrato_Servico


select
  identity(int,1,1) as cd_controle,
  *,
  Total = isnull(vl_total_geral,0) + isnull(vl_total_servico,0) + (isnull(vl_adiantamento_analista,0) * - 1)
into
  #Extrato_Geral

from 
  #Extrato_Servico

order by
  dt_lancto_ordem_servico desc


--------------------------------------------------------------------------------------------------------------------------------------
--Tipo do Relatório
--------------------------------------------------------------------------------------------------------------------------------------

if @ic_tipo_relatorio <> 'R' 
begin
--------------------------------------------------------------------------------------------------------------------------------------

if @ic_ordem = 'C'
  begin 
    select
      cd_item_ordem_servico = cd_controle,
      *
    from 
       #Extrato_Geral
    where
--       cd_tipo <> '3' and
       cd_tipo = case when @ic_tipo_relatorio = 'T' then cd_tipo else case when @ic_tipo_relatorio = 'H' then '2' else '1' end end

    order by
      nm_fantasia_cliente,dt_ordem_servico,cd_analista,cd_tipo

  end
else   
  begin 

    select
      cd_item_ordem_servico = cd_controle,
      *
    from 
       #Extrato_Geral

    where
--       cd_tipo <> '3' and
       cd_tipo = case when @ic_tipo_relatorio = 'T' then cd_tipo else case when @ic_tipo_relatorio = 'H' then '2' else '1' end end

    order by
      cd_analista,dt_ordem_servico,nm_fantasia_cliente,cd_tipo

  end  

end

--------------------------------------------------------------------------------------------------------------------------------------
--Resumo
--------------------------------------------------------------------------------------------------------------------------------------

--select * from #Extrato_Geral

if @ic_tipo_relatorio = 'R'
begin
--------------------------------------------------------------------------------------------------------------------------------------
  if @ic_ordem = 'C'
  begin 
    select
      max(cd_controle)                      as cd_controle,
      cd_cliente,
      nm_fantasia_cliente                   as Descricao,
      sum( isnull(qt_item_normal_ordem,0) ) as qt_item_normal_ordem,
      sum( isnull(vl_total_servico,0) )     as vl_total_servico,
      sum( isnull(vl_total_geral,0))        as vl_item_despesa_ordem,
      sum( isnull(Total,0))                 as vl_total_geral

    from 
       #Extrato_Geral
    
    group by 
      cd_cliente,
      nm_fantasia_cliente

    order by
      nm_fantasia_cliente

  end  
  else
    begin
    select
      max(cd_controle)                      as cd_controle,
      cd_analista,
      nm_analista                           as Descricao,
      sum( isnull(qt_item_normal_ordem,0) ) as qt_item_normal_ordem,
      sum( isnull(vl_total_servico,0) )     as vl_total_servico,
         
      sum( case when isnull(ic_consultor_despesa,'N')='N' then 0 else isnull(vl_total_geral,0) end )        as vl_item_despesa_ordem,
      sum( isnull(Total,0))                 as vl_total_geral

    from 
       #Extrato_Geral

    group by 
      cd_analista,
      nm_analista

    order by
      nm_analista

    end

--------------------------------------------------------------------------------------------------------------------------------------
end

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_extrato_financeiro_servico_cliente 0,0,0,'01/01/2012','12/31/2012','A','C'
------------------------------------------------------------------------------------
--exec pr_extrato_financeiro_servico_cliente 0,0,0,'01/01/2012','12/31/2012','C','T'
------------------------------------------------------------------------------------

--Resumo

--exec pr_extrato_financeiro_servico_cliente 0,0,0,'01/01/2012','12/31/2012','C','R'
--exec pr_extrato_financeiro_servico_cliente 0,0,0,'01/01/2012','12/31/2012','A','R'

---select * from Ordem_Servico_Analista
--select * from Ordem_Servico_Analista_item
--select * from ordem_servico_analista_despesa
-- 
-- 
-- exec dbo.pr_extrato_financeiro_servico_cliente  @cd_ordem_servico = 0, @cd_cliente = 0, @cd_analista = 0, @dt_inicial = '09/01/2012',
--  @dt_final = '09/30/2012', @ic_ordem = 'A', @ic_tipo_relatorio = 'R'