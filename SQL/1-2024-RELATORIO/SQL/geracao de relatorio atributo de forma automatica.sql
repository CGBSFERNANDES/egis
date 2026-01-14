declare @cd_relatorio_origem  int = 0
declare @cd_relatorio_destino int = 0

set @cd_relatorio_origem  = 20
set @cd_relatorio_destino = 165

select *  into #ra from egisadmin.dbo.relatorio_atributo where cd_relatorio = 20

update
  #ra
set
  cd_relatorio = @cd_relatorio_destino

insert into egisadmin.dbo.relatorio_atributo
select * from #ra

drop table #ra

