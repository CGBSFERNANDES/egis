use EGISADMIN
go
--return

declare @cd_modulo int = 236

select * from modulo where cd_modulo = @cd_modulo


  update
  menu
  set
    cd_pagina = 14,
	cd_tipo_menu = 5
from
 menu m
 inner join modulo_funcao_menu mf on mf.cd_menu = m.cd_menu

where
  mf.cd_modulo = @cd_modulo
  and
  m.cd_aplicacao = 3

  --select cd_aplicacao,* from menu where cd_menu = 6542

