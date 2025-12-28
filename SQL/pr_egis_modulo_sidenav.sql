USE EGISADMIN
GO
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_modulo_sidenav' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_modulo_sidenav

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_modulo_sidenav
-------------------------------------------------------------------------------
--pr_modulo_sidenav_dashboard
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2020
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--Autor(es)        : Carlos Cardoso Fernandes
--Banco de Dados   : EgisAdmin		
--Objetivo         : Composição do Módulo para SideNav - Vue/Devexpress
--Data             : 13.07.2020
--Alteração        : 04.10.2020 - o path/rota automático do cadastro 
   
-- 09.10.2020 - Ajuste conforme o Grupo de Usuário - Carlos Fernandes
-- 24.11.2022 - Ajuste no filtro respeitando a Grupo_usuario_menu na formação dos menus.
------------------------------------------------------------------------------
create procedure pr_egis_modulo_sidenav
@cd_modulo  int = 0,
@cd_empresa int = 0,
@cd_usuario int = 0
--with encryption
as

set @cd_modulo  = isnull(@cd_modulo,0)
set @cd_empresa = isnull(@cd_empresa,0)
set @cd_usuario = isnull(@cd_usuario,0)

declare @cd_grupo_usuario        int = 0
declare @cd_grupo_usuario_padrao int = 2627

set @cd_grupo_usuario = 0

if @cd_empresa<>0 and @cd_modulo<>282 --portal
begin

  --select * from empresa_portal where cd_modulo = @cd_modulo and cd_empresa    = @cd_empresa 

  select 
    TOP 1
    @cd_grupo_usuario = isnull(ep.cd_grupo_usuario,0)
  from 
    empresa_portal ep
	left outer join Usuario_GrupoUsuario u    on u.cd_grupo_usuario = ep.cd_grupo_usuario --u.cd_usuario = @cd_usuario  --
  where
    ep.cd_empresa    = @cd_empresa and
	ep.cd_modulo     = @cd_modulo  and
	u.cd_usuario     = case when @cd_usuario = 0 then u.cd_usuario else @cd_usuario end

	--select * from usuario_grupoUsuario where cd_grupo_usuario = 2642
end

if @cd_grupo_usuario = 0
begin
  select @cd_grupo_usuario = u.cd_grupo_usuario 
  from 
    modulo_grupoUsuario mg
	inner join Usuario_GrupoUsuario u on u.cd_grupo_usuario = mg.cd_grupo_usuario and u.cd_usuario = @cd_usuario

  where
   mg.cd_modulo = @cd_modulo


  --select * from Usuario_GrupoUsuario where cd_usuario = @cd_usuario


end


--Grupo teste
--set @cd_grupo_usuario = 2642
--funcao--

if @cd_grupo_usuario = 0 and @cd_modulo = 282
begin
  set @cd_grupo_usuario = @cd_grupo_usuario_padrao
end


--select @cd_grupo_usuario as grupo_teste, @cd_modulo as cd_modulo, @cd_empresa as cd_empresa, @cd_usuario as cd_usuario


select
  distinct
  mfm.cd_modulo,
  mfm.cd_funcao,
  f.nm_funcao,
  cd_indice = isnull(( select top 1 cd_indice 
                from
				 modulo_funcao_menu x
				where
				  x.cd_modulo = mfm.cd_modulo and
				  x.cd_funcao = mfm.cd_funcao ),0),

  isnull(f.nm_icone_funcao, 'home') as nm_icone_funcao,

  isnull(f.nm_rota_funcao,'') as nm_rota,
  isnull(g.qt_ordem_funcao,0) as qt_ordem_funcao,
  cast('' as varchar(500))    as nm_endereco_pagina,
  m.cd_tipo_menu,
  p.nm_arquivo_pagina,
  m.cd_dashboard

    
into
  #Funcao 

from
  modulo_funcao_menu mfm
  inner join Menu m                      on m.cd_menu          = mfm.cd_menu
  inner join funcao f                    on f.cd_funcao        = mfm.cd_funcao
  left outer join grupo_usuario_funcao g on g.cd_grupo_usuario = @cd_grupo_usuario and
                                            g.cd_modulo        = mfm.cd_modulo     and
									        g.cd_funcao        = mfm.cd_funcao
  left outer join pagina_internet p      on p.cd_pagina        = m.cd_pagina

where
  mfm.cd_modulo = @cd_modulo
  and
  g.cd_grupo_usuario = case when @cd_grupo_usuario = 0 then g.cd_grupo_usuario else @cd_grupo_usuario end

order by
  7

--select @cd_grupo_usuario

--select * from   #Funcao
--return

--select * from grupo_usuario_funcao where cd_grupo_usuario = 358

--  and
--  f.cd_funcao = 441

if not exists ( select top 1 cd_funcao from #Funcao )
begin

  select
    distinct
	mfm.cd_modulo,
    mfm.cd_funcao,
    f.nm_funcao,
    cd_indice = isnull(( select top 1 cd_indice 
                from
				 modulo_funcao_menu x
				where
				  x.cd_modulo = mfm.cd_modulo and
				  x.cd_funcao = mfm.cd_funcao ),0),

    isnull(f.nm_icone_funcao, 'home') as nm_icone_funcao,
    isnull(f.nm_rota_funcao,'') as nm_rota,
	isnull(0,0)                 as qt_ordem_funcao,
	cast('' as varchar(500))    as nm_endereco_pagina,
	m.cd_tipo_menu,
	p.nm_arquivo_pagina,
	m.cd_dashboard
    
  into
    #FuncaoModulo

  from
     modulo_funcao_menu mfm
     inner join funcao f                 on f.cd_funcao        = mfm.cd_funcao
	 inner join Menu m                   on m.cd_menu          = mfm.cd_menu
	 left outer join pagina_internet p   on p.cd_pagina        = m.cd_pagina

  where
     mfm.cd_modulo = @cd_modulo

  order by 
     7

   insert into #Funcao  
   select * from #FuncaoModulo

end

--ok
---select * from #Funcao order by cd_indice


--select * from  #Funcao 


select
  --identity(int,1,1)  as cd_controle,
  mfm.cd_modulo,
  mo.nm_modulo,
  mo.nm_fantasia_modulo,
  mo.ds_modulo,
  isnull(mfm.cd_funcao,0)                      as cd_funcao,
  isnull(f.nm_funcao,'')                       as nm_funcao,
  mfm.cd_menu,
  m.nm_menu,
  m.nm_menu_titulo,
  m.cd_procedimento,
  mt.cd_tabela,
  isnull(mfm.cd_indice,0)                       as cd_indice,

  case when isnull(f.nm_rota_funcao,'')<>'' then
    f.nm_rota_funcao
  else
    isnull(m.nm_rota_menu,'')
  end                             as nm_rota,
  isnull(g.qt_ordem_funcao,0)     as qt_ordem_funcao,
  isnull(p.nm_endereco_pagina,'') as nm_endereco_pagina,
  m.cd_tipo_menu,
  p.nm_arquivo_pagina,
  m.cd_dashboard
 
into
  #ModuloAux

  --select * from modulo_funcao_menu where cd_modulo = 319
  --select * from grupo_usuario_funcao where cd_grupo_usuario = 1542 and cd_modulo = 319 and cd_funcao = 57
  --select * from modulo_funcao_menu where cd_modulo = 319 and cd_funcao = 57
  --select * from funcao where cd_funcao = 57
  --select * from menu_tabela
  --select * from modulo_funcao_menu where cd_menu = 7270

from
  modulo_funcao_menu mfm
  
  inner join modulo mo                   on mo.cd_modulo         = mfm.cd_modulo
  inner join funcao f                    on f.cd_funcao          = mfm.cd_funcao
  inner join menu m                      on m.cd_menu            = mfm.cd_menu
  left outer join menu_tabela mt         on mt.cd_menu           = mfm.cd_menu
  left outer join api a                  on a.cd_api             = m.cd_api
  left outer join grupoUsuario gu        on gu.cd_grupo_usuario  = @cd_grupo_usuario
  left join grupo_usuario_funcao g       on g.cd_grupo_usuario   = @cd_grupo_usuario and
                                            g.cd_modulo          = mfm.cd_modulo     and
									        g.cd_funcao          = mfm.cd_funcao
  left outer join pagina_internet p      on p.cd_pagina          = m.cd_pagina
  LEFT outer join grupo_usuario_menu gum on gum.cd_grupo_usuario = @cd_grupo_usuario
								and    gum.cd_modulo             = mfm.cd_modulo     
								and    gum.cd_menu               = mfm.cd_menu
  

where
  mfm.cd_modulo = @cd_modulo
  and
  gu.cd_grupo_usuario  = case when @cd_grupo_usuario = 0 then gu.cd_grupo_usuario else @cd_grupo_usuario end
  and
  gum.cd_grupo_usuario = case when @cd_grupo_usuario = 0 then gum.cd_grupo_usuario else @cd_grupo_usuario end

order by
   mfm.cd_indice

   --select @cd_grupo_usuario

--select * from GrupoUsuario where cd_grupo_usuario = 2625
--select * from grupo_usuario_menu where cd_grupo_usuario = 2625

--select * from   #ModuloAux


   --case when isnull(g.qt_ordem_funcao,0)>0 then g.qt_ordem_funcao else  mfm.cd_indice end
--select * from #ModuloAux order by nm_funcao, nm_menu
--select 'teste'

---Inserir os Menus do Grupo de Usuário-------------------------------------------------------------------------------------------
--13.11.2021

select
  --identity(int,1,1)  as cd_controle,
  @cd_modulo         as cd_modulo,
  mo.nm_modulo,
  mo.nm_fantasia_modulo,
  mo.ds_modulo,
  isnull(f.cd_funcao,441) as cd_funcao,
  isnull(f.nm_funcao,'')  as nm_funcao,
  mfm.cd_menu,
  m.nm_menu,
  m.nm_menu_titulo,
  m.cd_procedimento,
  mt.cd_tabela,
  isnull(mfm.qt_ordem_menu,0)  as cd_indice,

  case when isnull(f.nm_rota_funcao,'')<>'' then
    f.nm_rota_funcao
  else
    isnull(m.nm_rota_menu,'')
  end                             as nm_rota,
  isnull(g.qt_ordem_funcao,0)     as qt_ordem_funcao,
  isnull(p.nm_endereco_pagina,'') as nm_endereco_pagina,
  m.cd_tipo_menu,
  p.nm_arquivo_pagina,
  m.cd_dashboard

into
  #MenuGrupo

from
  menu_grupo_usuario mfm
  inner join modulo mo                    on mo.cd_modulo       = @cd_modulo
  
  inner join menu m                       on m.cd_menu          = mfm.cd_menu
  left outer join menu_tabela mt          on mt.cd_menu         = mfm.cd_menu
  left outer join api a                   on a.cd_api           = m.cd_api

  left outer  join grupo_usuario_funcao g on g.cd_grupo_usuario = @cd_grupo_usuario and
                                             g.cd_modulo        = @cd_modulo        and               
									         g.cd_funcao        = mfm.cd_funcao

  left outer join funcao f                on f.cd_funcao        = case when isnull(g.cd_funcao,441)=0 then 441 else isnull(g.cd_funcao,441) end

  left outer join pagina_internet p on p.cd_pagina        = m.cd_pagina

  --select * from api


where
  mfm.cd_grupo_usuario = case when @cd_grupo_usuario = 0        then mfm.cd_grupo_usuario else @cd_grupo_usuario end
  and
  mfm.cd_grupo_usuario = case when @cd_grupo_usuario_padrao = 0 then mfm.cd_grupo_usuario else @cd_grupo_usuario_padrao end

order by
   mfm.qt_ordem_menu

   --select @cd_grupo_usuario

--select * from menu_grupo_usuario where cd_grupo_usuario = 2625

--select * from #MenuGrupo

--file exists
insert #ModuloAux select * from #MenuGrupo

select
  identity(int,1,1) as cd_controle,
  m.*
into
  #Modulo 

from
  #ModuloAux m


--select * from #Modulo

--return

--Menu_Grupo_Usuario --select * from Menu_Grupo_Usuario

----------------------------------------

--select * from #Funcao

--select * from #Modulo order by cd_indice

declare @cd_controle       int
declare @retorno           nvarchar(max)
declare @nm_funcao         varchar(30)
declare @nm_menu           varchar(60) = ''
declare @nm_menu_titulo    varchar(60) = ''
declare @nm_titulo_form    varchar(80) = ''
declare @nm_icone          varchar(30)
declare @cd_funcao         int
declare @item              nvarchar(max)
declare @nm_path           varchar(100)
declare @cd_menu           int = 0
declare @cd_parametro      int = 0
declare @cd_modulo_p       int = 0 --modulo parametro
declare @cd_tipo_menu      int = 0
declare @nm_arquivo_pagina varchar(80) = ''
declare @cd_form           int = 0
declare @cd_dashboard      int = 0

set @cd_controle       = 0
set @retorno           = ''
set @nm_funcao         = ''
set @nm_menu           = ''
set @nm_icone          = ''
set @cd_funcao         = 0
set @item              = ''
set @nm_path           = ''
set @cd_menu           = 0
set @cd_parametro      = 0
set @cd_tipo_menu      = 0
set @nm_arquivo_pagina = ''
set @nm_titulo_form    = ''
set @nm_menu_titulo    = ''
set @cd_modulo_p       = case when isnull(@cd_modulo_p,0) = 0 then @cd_modulo else @cd_modulo_p end 
set @cd_dashboard      = 0


while exists(select top 1 cd_indice    from #Funcao order by cd_indice )
begin

  select top 1 
     @cd_funcao         = cd_funcao,
  	 @nm_funcao         = nm_funcao,	
	 @nm_icone          = nm_icone_funcao,
	 @nm_path           = ltrim(rtrim(nm_rota)),
	 @cd_tipo_menu      = isnull(cd_tipo_menu,1),
	 @nm_arquivo_pagina = isnull(nm_arquivo_pagina,''),
	 @cd_dashboard      = isnull(cd_dashboard,0)

  from
     #Funcao

  order by
     case when isnull(qt_ordem_funcao,0)>0 then qt_ordem_funcao else  cd_indice end

  --select @nm_funcao

  set @retorno = @retorno 
                 +
				 case when @retorno<>'' then ', ' else '' end
				 +
                 '{ '
				 +
				 '"text": '+'"'+ltrim(rtrim(@nm_funcao))+'"'
				 +
				 ', '
				 +  
				 '"icon": '+'"'+@nm_icone+'"'
				 +
				 case when @nm_path<>'' then
  			 	   --', "path": '+'"'+ltrim(rtrim(@nm_path))+'"'
				   ', "path": '+'"'+ltrim(rtrim(cast(@cd_funcao as varchar(10))))+'"'
				 else
				   cast('' as varchar(1))
				 end
				 +
				 ', '
				 +
				 '"tipo": '+'"'+cast(@cd_tipo_menu as char(1))+'"'
				 +', '
				 +
				 '"pagina": '+'"'+cast(@nm_arquivo_pagina as varchar(80))+'"'
				 +', ' +
				 '"cd_dashboard": '+'"'+cast(@cd_dashboard as varchar(20))+'"'

   --select * from #Modulo

   set @item = ''

   while exists( select top 1 cd_controle from #Modulo where cd_funcao = @cd_funcao order by cd_indice)
   begin

     select top 1 
       @cd_controle       = cd_controle,
	   @cd_menu           = cd_menu,
   	   @nm_menu           = nm_menu,
	   @nm_icone          = 'home',
	   @cd_menu           = cd_menu,
	   @nm_path           = nm_rota,
	   @cd_tipo_menu      = ISNULL(cd_tipo_menu,1),
	   @cd_form           = 0,
	   @nm_arquivo_pagina = isnull(nm_arquivo_pagina,''),
	   @nm_titulo_form    = '',
	   @nm_menu_titulo    = nm_menu_titulo,
	   @cd_dashboard      = ISNULL(cd_dashboard,0)


       --@nm_path     = case when @cd_controle =  1 then '/display-data' 
	      --                                        else
							--					    case when @cd_controle =  2 then '/display-data2' else '' end
                                           
							--					   end
	 
     from
       #Modulo

     where
	   cd_funcao = @cd_funcao

     order by
       cd_indice
	   
	 --Verifica se o Menu tem Form
	 
	 select
	   top 1 
	   @cd_form        = ISNULL(f.cd_form,0),
	   @nm_titulo_form = ISNULL(f.nm_titulo_form,'')
     from
	  EGISADMIN.dbo.Form f 
	 where
	   f.cd_menu = @cd_menu


     --select @cd_controle, @nm_menu, @nm_icone

     set @item = @item 
                 +
				 case when @item<>'' then ', ' else '' end
				 +
                 ' { '
				 +
				 '"text": '+'"'+@nm_menu+'"'
				 +
				 ', '
				 +
                 '"path": '+'"'+ltrim(rtrim(cast(@cd_menu as varchar(12))))+'"'
                 +
				 ', '
				 +			 
				 '"tipo": '+'"'+cast(@cd_tipo_menu as char(1))+'"'
                 +
				 ', '
				 +			 
                '"pagina": '+'"'+cast(@nm_arquivo_pagina as varchar(80))+'"'
		         +
				 ', '
				 +			 
				 '"form": '+'"'+cast(@cd_form as varchar(20))+'"'
				 +
				 ', '
				 +			 
				 '"form_titulo": '+'"'+cast(@nm_titulo_form as varchar(80))+'"'
				 +
				 ', '
				 +
				 '"modulo": '+'"'+ltrim(rtrim(cast(@cd_modulo_p as varchar(12))))+'"'
				 +
				 ', '
                 +				 			 
				 --'"menu_titulo": '+'"'+cast(@nm_menu_titulo as varchar(80))+'"'
				 '"menu_titulo": '+'"'+cast(@nm_menu as varchar(80))+'"'
				 +
				 ', '
				 +
				 '"cd_dashboard": '+'"'+cast(@cd_dashboard as varchar(20))+'"'
				 +
				 ' } '


     delete from #Modulo
     where
       cd_controle = @cd_controle

   end
   
   if @item<>''
      set @retorno = @retorno 
	                 +
	                 ', '   	                   
	                 +
					 '"items" : [ '
					 +
					 ltrim(rtrim(@item))
					 +
					 ' ] '

   set @retorno = @retorno
                    + 		
				    '} '


   delete from #Funcao
   where
      cd_funcao = @cd_funcao

end

--select @retorno

--
set @retorno =  '['+@retorno+']'
--

select @retorno as data

--select 
--  data.* 
----into #json
--from OPENJSON(@retorno, N'$')
--WITH (
--   [text]  varchar(30) '$.text',
--   [icon]  varchar(30) '$.icon',
--   [items] varchar(1000) '$.items'
--) as data  

----select * from #json FOR JSON AUTO
--select * from #json

/*
select 

  f.nm_funcao    as 'data.text',
  'home'         as 'data.icon',
  items.nm_menu                             as 'items.text',
  cast(items.ic_manual_menu as varchar(10)) as 'items.path'
    
from
 modulo_funcao_menu m
 inner join funcao f  on f.cd_funcao  = m.cd_funcao
 inner join modulo mo on mo.cd_modulo = m.cd_modulo
 inner join menu items on items.cd_menu = m.cd_menu
 where
   mo.cd_modulo = 219

 order by
   m.cd_indice

   for json path, INCLUDE_NULL_VALUES 
     
*/



drop table #modulo
drop table #funcao





go

--select * from modulo_funcao_menu where cd_modulo = 239

go

--select * from api
--select * from api_composicao
--use egisadmin
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_modulo_sidenav 282, 1, 113
------------------------------------------------------------------------------
--exec pr_egis_modulo_sidenav 383, 342, 4638
------------------------------------------------------------------------------
--exec pr_egis_modulo_sidenav 383, 342, 113
------------------------------------------------------------------------------



--@cd_modulo  int = 0,
--@cd_empresa int = 0,
--@cd_usuario int = 0

--select * from pagina_internet
------------------------------------------------------------------------------
--SELECT * FROM Tipo_Menu  --SELECT CD_TIPO_MENU, * FROM MENU WHERE CD_menu = 6915  --select * from menu_tipo

