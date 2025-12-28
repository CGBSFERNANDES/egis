use egissql_317
go

select 
  cd_cnpj_cliente,
  count(cd_cliente)            as qt_cliente,
  max(nm_razao_social_cliente) as Cliente,
  max(nm_fantasia_cliente)     as Fantasia,
  max(c.cd_vendedor)             as cd_vendedor,
  max(v.nm_fantasia_vendedor)    as nm_vendedor
into
  #Cliente
from 
  cliente c
  inner join vendedor v on v.cd_vendedor= c.cd_vendedor
where
  c.cd_status_cliente = 1

group by
  cd_cnpj_cliente


select * from #Cliente where qt_cliente > 1
order by
  Cliente

drop table #Cliente



