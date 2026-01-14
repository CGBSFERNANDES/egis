use egissql_317
go
select
  IDENTITY(int,1,1)                                  as cd_controle,
  YEAR(d.dt_vencimento_documento)                    as cd_ano,
  SUM( isnull(d.vl_saldo_documento,0))               as vl_saldo_documento,
  count(d.cd_documento_receber)                      as qt_documento,
  count(distinct c.cd_cliente_grupo)                 as qt_cliente_grupo,
  COUNT(distinct d.cd_cliente)                       as qt_cliente,
  COUNT(distinct isnull(d.cd_vendedor,c.cd_cliente)) as qt_vendedor,
  MIN(d.dt_vencimento_documento)                     as dt_inicio_vencimento,
  MAX(d.dt_vencimento_documento)                     as dt_fim_vencimento

into
  #Ano

from
  Documento_Receber d
  left outer join Cliente c        on c.cd_cliente        = d.cd_cliente
  left outer join Cliente_Grupo cg on cg.cd_cliente_grupo = c.cd_cliente_grupo
where
  d.dt_cancelamento_documento is null
  and
  d.dt_devolucao_documento is null
  and
  ISNULL(d.vl_saldo_documento,0)>0
group by
  YEAR(d.dt_vencimento_documento)
order by
  YEAR(d.dt_vencimento_documento)

declare @vl_total decimal(25,2) = 0.00
declare @qt_total decimal(25,2) = 0.00

select
  @vl_total = SUM(vl_saldo_documento),
  @qt_total = SUM(qt_documento)
from
  #Ano


select
 *,
 pc_ano = round(vl_saldo_documento/@vl_total * 100,2)
from
 #Ano


drop table #Ano

select
  IDENTITY(int,1,1)                                  as cd_controle,
  YEAR(d.dt_vencimento_documento)                    as cd_ano,
  MONTH(d.dt_vencimento_documento)                   as cd_mes,
  SUM( isnull(d.vl_saldo_documento,0))               as vl_saldo_documento,
  count(d.cd_documento_receber)                      as qt_documento,
  count(distinct c.cd_cliente_grupo)                 as qt_cliente_grupo,
  COUNT(distinct d.cd_cliente)                       as qt_cliente,
  COUNT(distinct isnull(d.cd_vendedor,c.cd_cliente)) as qt_vendedor,
  MIN(d.dt_vencimento_documento)                     as dt_inicio_vencimento,
  MAX(d.dt_vencimento_documento)                     as dt_fim_vencimento

into
  #Mensal

from
  Documento_Receber d
  left outer join Cliente c        on c.cd_cliente        = d.cd_cliente
  left outer join Cliente_Grupo cg on cg.cd_cliente_grupo = c.cd_cliente_grupo
where
  d.dt_cancelamento_documento is null
  and
  d.dt_devolucao_documento is null
  and
  ISNULL(d.vl_saldo_documento,0)>0
group by
  YEAR(d.dt_vencimento_documento),
  MONTH(d.dt_vencimento_documento) 
order by
  YEAR(d.dt_vencimento_documento),
  MONTH(d.dt_vencimento_documento) 


select * from #Mensal


