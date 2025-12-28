use egissql_360
go
insert into aprovacao_processo
select * from egisadmin.dbo.empresa_aprovacao_processo
where
  cd_processo not in ( select cd_processo from aprovacao_processo )

