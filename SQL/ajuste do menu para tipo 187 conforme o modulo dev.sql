use egisadmin
go

select m.cd_rota, m.* from menu m
inner join modulo_funcao_menu mfm on mfm.cd_modulo =  238 and mfm.cd_menu = m.cd_menu


update
  menu
  set
    cd_rota = 187
from
  menu m
  inner join modulo_funcao_menu mfm on mfm.cd_modulo =  238 and mfm.cd_menu = m.cd_menu

where
  mfm.cd_modulo = 238
  and
  isnull(m.cd_rota,0) = 0
  and
  cd_tipo_menu = 5
