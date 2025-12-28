use egisadmin
go

RETURN

select * from atributo where cd_tabela = 10

update
  atributo
  set
    ic_retorno_atributo = 'S',
    ic_pesquisa_atributo = 'S',
    ic_like_atributo = 'S'
where
  cd_tabela = 10
  and
  cd_atributo = 5

/*

update
  egisadmin.dbo.atributo
set
  cd_menu_pesquisa = 8820
from
  egisadmin.dbo.atributo a
where
  a.cd_tabela <> 10
  and
  a.nm_atributo = 'cd_conta'
  and
  a.cd_tabela = 414

update
  egisadmin.dbo.menu
set
  ic_json_parametro = 'S',
  cd_parametro = 1,
  ic_selecao_registro = 'S'
where
  cd_menu = 8820

UPDATE
  egisadmin.dbo.atributo
set
ic_treeview_atributo = 'N'
where
  cd_tabela = 414
  and
  cd_atributo in ( 4 )


UPDATE
  egisadmin.dbo.atributo
set
ic_atributo_pai = 'N',
ic_atributo_filho = 'S'
where
  cd_tabela = 414
  and
  cd_atributo = 1

UPDATE
  egisadmin.dbo.atributo
set
ic_atributo_pai = 'S',
ic_atributo_filho = 'N'
where
  cd_tabela = 414
  and
  cd_atributo = 9


UPDATE
  egisadmin.dbo.menu
  set
    ic_treeview_menu = 'N'
    where
      cd_menu = 8448

UPDATE
  egisadmin.dbo.menu
  set
    ic_card_menu = 'N'
    where
      cd_menu = 6167

--select cd_menu_pesquisa, * from egisadmin.dbo.atributo where isnull(cd_menu_pesquisa,0)>0

update
  egisadmin.dbo.atributo
set
  ic_data_hoje = 'S',
  ic_data_padrao = 'S'
where
  cd_tabela = 123
  and
  substring(nm_atributo,1,2) = 'dt'
  and
  cd_atributo = 2


update
  egisadmin.dbo.atributo
set
  cd_menu_pesquisa = 8793
from
  egisadmin.dbo.atributo
where
  cd_tabela <> 66
  and
  nm_atributo = 'cd_produto'
  and
  isnull(cd_menu_pesquisa,0)=0


  update
  egisadmin.dbo.atributo
set
  cd_menu_pesquisa = 8788
from
  egisadmin.dbo.atributo
where
  cd_tabela <> 93
  and
  nm_atributo = 'cd_cliente'
  and
  isnull(cd_menu_pesquisa,0)=0


update
  egisadmin.dbo.menu
 set
   ic_selecao_registro = 'S',
   cd_form_modal       = 13,
   ic_json_parametro   = 'S',
   cd_parametro = 100
from
  egisadmin.dbo.menu

where
  cd_menu = 8818

  update
 egisadmin.dbo.menu
 set
   ic_selecao_registro = 'S',
   cd_form_modal       = 14
  -- ic_json_parametro   = 'S'
from
  egisadmin.dbo.menu
where
  cd_menu = 8235

  select * from egisadmin.dbo.Modal_Grid_Composicao



update
  egisadmin.dbo.atributo
  set
    cd_relatorio = 189
where
  cd_tabela = 215
  and
  cd_atributo = 23


  update
  egisadmin.dbo.atributo
  set
    cd_relatorio = 397
where
  cd_tabela = 215
  and
  cd_atributo = 59


  --update
--  egisadmin.dbo.Atributo
--  set
--    ic_mostra_cadastro = 'N',
--	ic_edita_cadastro  = 'N',
--	ic_mostra_relatorio = 'N',
--	ic_mostra_grid      = 'N'

--where
--  cd_tabela = 148
--  and
--  cd_atributo > 3
--  and
--  cd_atributo not in ( 10,12, 16, 26, 27, 28, 29, 30 )


--update
--  egisadmin.dbo.Atributo
--  set
--   ic_data_hoje = 'S'
--   where
--    cd_tabela = 148

--	and

--	cd_atributo = 9
--badge
--menu/azul
--form/verde
--menu/coluna = roxo

--update
--  EGISADMIN.dbo.Menu
--  set
--   ic_detalhe_menu = 'S'
--   where
--     cd_menu = 8033

  
--select * from egisadmin.dbo.menu_tabela where cd_menu = 6437

 -- update
 --   EGISADMIN.dbo.menu
	--set
	--  ic_filtro_obrigatorio = 'S'

	--  where
	--    cd_menu = 5935

	--use egissql_decora
	--use egissql_342
	--use egissql_rubio
	
	--update
	--  egisadmin.dbo.menu
	--  set
	--    ic_json_parametro = 'S'
	--	where
	--	  cd_menu = 8147


--use egissql_360


  */



