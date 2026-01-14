use EGISADMIN
go
declare @cd_modulo int = 241

select 
 mr.cd_modulo_relatorio,
 mr.cd_modulo,
 mr.cd_relatorio,
 m.nm_modulo,
 r.nm_relatorio,
 r.nm_titulo_relatorio,
 r.ds_relatorio,
 r.nm_icone_relatorio

from 
  modulo_relatorio mr
  inner join modulo m    on m.cd_modulo = mr.cd_modulo
  inner join relatorio r on r.cd_relatorio = mr.cd_relatorio

where
  mr.cd_modulo = @cd_modulo