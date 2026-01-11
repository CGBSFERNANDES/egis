IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_extrato_financeiro_servico_cliente_resumo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_extrato_financeiro_servico_cliente_resumo

GO

-------------------------------------------------------------------------------
--sp_helptext pr_extrato_financeiro_servico_cliente_resumo
-------------------------------------------------------------------------------
--pr_extrato_financeiro_servico_cliente_resumo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2012
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000
--Autor(es)        : Marcelo Segura
--
--Banco de Dados   : Egissql
--
--Objetivo         : 
--Data             : 11.09.2012
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_extrato_financeiro_servico_cliente_resumo
@cd_ordem_servico int      = 0,
@cd_cliente       int      = 0,
@cd_analista      int      = 0,
@dt_inicial       datetime = '',
@dt_final         datetime = '',
@ic_ordem         char(1)  = 'C', 
-- C = a cliente
-- A = Analista
@ic_tipo_relatorio char(1) = 'T'    --(T)otal
                                    --(H)oras
                                    --(D)espesas
                                    --(R)esumo
as



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

  nd.cd_nota_debito_despesa,
  nd.vl_nota_debito,

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
  end                             as vl_total_servico,

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
    cast('' as varchar) as   nm_tipo_despesa


--  cast('' as varchar)                             as 


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
  
where
  isnull(i.qt_item_normal_ordem,0)>0 and
  isnull(os.cd_cliente,0)  = case when isnull(@cd_cliente,0)  = 0 then isnull(os.cd_cliente,0)  else isnull(@cd_cliente,0)  end and 
  isnull(os.cd_analista,0) = case when isnull(@cd_analista,0) = 0 then isnull(os.cd_analista,0) else isnull(@cd_analista,0) end and
  os.dt_ordem_servico between @dt_inicial and @dt_final 
  

-- order by
--   os.dt_lancto_ordem_servico

union all

select
--  identity(int,1,1)                 as cd_controle,  
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

  cast('' as varchar(60))  as nm_servico,
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
  td.nm_tipo_despesa




--  cast('' as varchar)                             as 


-- into
--   #Extrato_Servico

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
  isnull(os.cd_cliente,0)  = case when isnull(@cd_cliente,0)  = 0 then isnull(os.cd_cliente,0)  else isnull(@cd_cliente,0)  end and 
  isnull(os.cd_analista,0) = case when isnull(@cd_analista,0) = 0 then isnull(os.cd_analista,0) else isnull(@cd_analista,0) end and
  os.dt_ordem_servico between @dt_inicial and @dt_final and
  isnull(od.ic_consultor_despesa,'N') = case when @cd_analista = 0 then isnull(od.ic_consultor_despesa,'N') else 'S' end
  and
  isnull(od.ic_cliente_despesa,'N')   = 'S'

order by
  os.dt_ordem_servico

--Mostra a tabela geral---------------------------------------------------------------------------------------------

--select * from #Extrato_Servico


select
  --identity(int,1,1) as cd_controle,
  *
into
  #Extrato_Geral
from 
  #Extrato_Servico
where cd_tipo = case when @ic_tipo_relatorio = 'T' then cd_tipo else case when @ic_tipo_relatorio = 'H' then '2' else '1' end end
order by
  dt_lancto_ordem_servico desc


if @ic_ordem = 'C'
  begin
  select nm_servico, cast(vl_total as decimal(12,2)) as vl_total from (
    select     
      nm_tipo_despesa as nm_servico,
      sum(isnull(vl_total_geral,0)) as vl_total 
    from 
      #Extrato_Geral
    where 
      isnull(cd_cliente,0)  = case when isnull(@cd_cliente,0)  = 0 then isnull(cd_cliente,0)  else isnull(@cd_cliente,0)  end 
      and nm_tipo_despesa <> ''
    group by    
      nm_tipo_despesa,nm_servico
  union all
    select     
      nm_servico, 
      sum(isnull(vl_total_servico,0)) as vl_total
    from 
      #Extrato_Geral
    where 
      isnull(cd_cliente,0)  = case when isnull(@cd_cliente,0)  = 0 then isnull(cd_cliente,0)  else isnull(@cd_cliente,0)  end 
      and nm_servico <> ''
    group by    
      nm_tipo_despesa,nm_servico) Resumo
    order by vl_total desc  

  end
else   
  begin select nm_servico, cast(vl_total as decimal(12,2)) as vl_total from (
    select     
      nm_tipo_despesa as nm_servico,
      sum(isnull(vl_total_geral,0)) as vl_total 
    from 
      #Extrato_Geral
    where 
      isnull(cd_analista,0) = case when isnull(@cd_analista,0) = 0 then isnull(cd_analista,0) else isnull(@cd_analista,0) end 
      and nm_tipo_despesa <> ''
    group by    
      nm_tipo_despesa,nm_servico
  union all
    select     
      nm_servico, 
      sum(isnull(vl_total_servico,0)) as vl_total
    from 
      #Extrato_Geral
    where 
      isnull(cd_analista,0) = case when isnull(@cd_analista,0) = 0 then isnull(cd_analista,0) else isnull(@cd_analista,0) end 
      and nm_servico <> ''
    group by    
      nm_tipo_despesa,nm_servico) Resumo
    order by vl_total desc
   
end

    
go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_extrato_financeiro_servico_cliente_resumo 0,0,0,'08/01/2012','08/31/2012','C'
------------------------------------------------------------------------------


---select * from Ordem_Servico_Analista
--select * from Ordem_Servico_Analista_item
--select * from ordem_servico_analista_despesa
-- 
-- 
