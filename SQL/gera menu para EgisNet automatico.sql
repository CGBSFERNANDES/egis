
RETURN

USE EGISADMIN
GO

----------------------------------------------------------------------------------
declare @execucao         int = 999 --<<<<<<<<<<<<<<<<<<<<<<<<
----------------------------------------------------------------------------------
declare @cd_menu_origem   int = 0
declare @cd_modulo        int = 0
declare @cd_funcao        int = 0
declare @cd_grupo_usuario int = 0
declare @cd_usuario       int = 0
declare @cd_modulo_origem int = 0

-------------------------------------------------------------------------------
--

if @execucao = 0
begin

--Menu Origem
set @cd_menu_origem   = 5351

--Módulo Origem
set @cd_modulo_origem = 114  --PCP ( DELPHI ) - D6
--

--Módulo Novo - Web
set @cd_modulo        = 251  -- EGISNET
--

--Grupo de Usuário
set @cd_grupo_usuario = 1291 --PCP NET

--Usuário
set @cd_usuario       = 1988 --113 DENIS

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------


SELECT * INTO #NOVO_MENU FROM MENU WHERE CD_MENU = @cd_menu_origem

--select * from menu where cd_menu = 3810
--select * from menu where cd_menu = 8726



DECLARE @cd_menu int = 0 

select
  @cd_menu = max(cd_menu)
from
  menu

  set @cd_menu = @cd_menu + 1

select @cd_menu
update
  #novo_menu
set
  cd_menu        = @cd_menu,
  cd_rota        = 187,
  cd_aplicacao   = 3,
  cd_tipo_versao = 1



SELECT * FROM #NOVO_MENU

insert into menu
select * from #NOVO_MENU

select * into #mt from menu_tabela where cd_menu = @cd_menu_origem


update
  #mt
set
  cd_menu = @cd_menu

insert into menu_tabela
select * from #mt


--select * from menu_tabela where cd_menu = 3810
--select * from modulo_funcao_menu  where cd_modulo = 251 --and cd_menu = 8727
--order by cd_indice

--função--

select
  @cd_funcao = cd_funcao

from
  modulo_funcao_menu
where
  cd_modulo = @cd_modulo_origem
  and
  cd_menu   = @cd_menu_origem

  --select * from modulo_funcao_menu where cd_modulo = 251 and cd_menu = 3954


declare @cd_indice int = 0

select @cd_indice = max(cd_indice)
from
  modulo_funcao_menu
where
  cd_modulo = @cd_modulo

set @cd_indice = isnull(@cd_indice,0) + 1


select * into #mfm from Modulo_Funcao_Menu where cd_modulo = @cd_modulo and cd_indice = ( @cd_indice - 1 )

update
  #mfm
set
  cd_menu   = @cd_menu,
  cd_indice = @cd_indice,
  cd_funcao = @cd_funcao


insert into Modulo_Funcao_Menu
select * from #mfm

-------------------------------------------------------------------------------------

--select * from modulo_funcao_menu  where cd_modulo = 251 --and cd_menu = 8727
--order by cd_indice

select * from Grupo_Usuario_Menu
where
  cd_grupo_usuario = 1291

select
 @cd_grupo_usuario as cd_grupo_usuario,
 @cd_modulo        as cd_modulo,
 @cd_menu          as cd_menu,
 @cd_usuario       as cd_usuario,
 getdate()         as dt_usuario,
 @cd_usuario       as cd_usuario_inclusao,
 getdate()         as dt_usuario_inclusao

into #gum

insert into grupo_usuario_menu
select * from #gum


drop table #mt
drop table #novo_menu
drop table #gum
drop table #mfm



select * from modulo_funcao_menu  where cd_modulo = 251 --and cd_menu = 8727
order by cd_indice

end


--update modulo_funcao_menu set cd_funcao = 37 where cd_modulo = 251 and cd_menu = 8735
