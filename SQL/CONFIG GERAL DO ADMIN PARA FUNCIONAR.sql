return
use egisadmin
go
select * from tabsheet
select * from Menu where cd_menu = 7183
select * from Menu_Atributo_Pesquisa
select * from Menu_Tabela_Atributo where cd_menu = 8088
select * from Menu_Detalhe where cd_menu = 8088
select * from Menu_Tabsheet where cd_menu = 8088

select * from menu_processo where cd_menu = 7183
select * from natureza_atributo


update
  menu
  set
    ic_filtro_obrigatorio = 'S'
  where
    cd_menu = 6125



select * from atributo where cd_tabela = 5854

--data de data de hoje
--
 Update
  atributo
  set
    ic_data_hoje = 'S'
	where
	  cd_tabela = 5855
	  and
	  cd_atributo in (2)




update
  atributo
  set
    ic_retorno_atributo = 'S'
	where
	  cd_tabela = 141
	  and
	  cd_atributo in (3)

update
  atributo
  set
    ic_filtro_atributo = 'S',
	ic_like_atributo   = 'S'
	where
	  cd_tabela = 66
	  and
	  cd_atributo in (3,13)

update
  atributo
  set
    ic_retorno_atributo = 'S'
	where
	  cd_tabela = 66
	  and
	  cd_atributo in (3,13)

	  --ic_filtro_atributo

	  select * from atributo where cd_tabela = 93

-------------------------------------TABELA DE DESTINO------------------------------------

--> CONSULTA ITENS --> TERÁ A PESQUISA POR PRODUTO
--SELECT * FROM ATRIBUTO WHERE CD_TABELA = 5855

update
  atributo
  set
    ic_pesquisa_atributo = 'S'
	where
	  cd_tabela = 5855
	  and
	  cd_atributo in (5)


update
  atributo
  set
    ic_retorno_atributo = 'S'
	where
	  cd_tabela = 5855
	  and
	  cd_atributo in (5)
	
--data de data de hoje
--
 Update
  atributo
  set
    ic_data_hoje = 'S'
	where
	  cd_tabela = 5855
	  and
	  cd_atributo in (2)
	  

update
  menu
  set
    ic_crud_processo = 'N'
where
  cd_menu = 8095



--select * from menu where cd_menu = 8090

    
	USE EGISADMIN
	GO

	update atributo
set
  cd_tabela_combo_box = t.cd_tabela
from
  atributo a
  inner join tabela t on t.nm_tabela = a.nm_tabela_combo_box
 where
  isnull(a.nm_tabela_combo_box,'')<>''
  and
  ISNULL(a.ic_chave_estrangeira,'N') = 'S'

  update
    menu
	set
	  cd_tipo_menu = 5,
	  cd_pagina = 14
where
  cd_classe = 3107

  update
  atributo
  set
    ic_filtro_atributo = 'S'
	--ic_like_atributo   = 'S'
	where
	  cd_tabela = 133
	  and
	  cd_atributo in (1)

  --select ic_aliasadmin_combo_box, * from atributo where cd_tabela = 5878


  update
  menu
  set
    cd_pagina = 14,
	cd_tipo_menu = 5
from
 menu m
 inner join modulo_funcao_menu mf on mf.cd_menu = m.cd_menu

where
  mf.cd_modulo = 319