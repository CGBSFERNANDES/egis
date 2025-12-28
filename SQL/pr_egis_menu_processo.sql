
GO
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_menu_processo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_menu_processo

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_menu_processo
-------------------------------------------------------------------------------
--pr_egis_menu_processo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EGISADMIN
--
--Objetivo         : Pesquisa de Processos do menu
--
--Data             : 25.04.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_menu_processo
@json nvarchar(max) = ''

--with encryption


as

declare @dt_hoje datetime    
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)           
    
if @json= ''   
begin    
  select 'Parâmetros inválidos !' as Msg    
  return    
end    
  
set @json = replace(@json,'''','')  
----------------------------------------------------------------------------------------------------------      
  
select                   
identity(int,1,1)                                                  as id,                   
    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI            as campo,                   
    valores.[value]                                                as valor                  
into #json                  
from                   
   openjson(@json)root                  
   cross apply openjson(root.value) as valores    
  
----------------------------------------------------------------------------------------------------------      
declare @cd_parametro              int = 0  
declare @cd_usuario                int = 0  
declare @dt_inicial                datetime        
declare @dt_final                  datetime       
declare @sql                       nvarchar(max) = ''
declare @cd_form                   int = 0
declare @cd_menu                   int = 0
declare @cd_modulo                 int = 0
declare @cd_grupo_usuario          int = 0
declare @cd_tabela                 int = 0

----------------------------------------------------------------------------------------------------------      
select @cd_parametro       = valor from #json  with(nolock) where campo = 'cd_parametro'   
select @cd_usuario         = valor from #json  with(nolock) where campo = 'cd_usuario'   
select @cd_grupo_usuario   = valor from #json  with(nolock) where campo = 'cd_grupo_usuario'   
select @dt_inicial         = valor from #json  with(nolock) where campo = 'dt_inicial'     
select @dt_final           = valor from #json  with(nolock) where campo = 'dt_final'    
select @cd_form            = valor from #json  with(nolock) where campo = 'cd_form'    
select @cd_menu            = valor from #json  with(nolock) where campo = 'cd_menu'    
select @cd_modulo          = valor from #json  with(nolock) where campo = 'cd_modulo'  
select @cd_tabela          = valor from #json  with(nolock) where campo = 'cd_tabela'
----------------------------------------------------------------------------------------------------------      

set @cd_modulo  = ISNULL(@cd_modulo,282)
set @cd_form    = ISNULL(@cd_form,0)
set @cd_menu    = ISNULL(@cd_menu,0)
set @cd_tabela  = isnull(@cd_tabela,0)
--set @cd_empresa =

select
  mp.*,  
  m.nm_menu_titulo,
  m.nm_menu,
  ps.nm_processo,
  pag.nm_pagina,
  pag.nm_endereco_pagina,
  pag.nm_caminho_pagina,   -- <--------------------------
  pag.nm_arquivo_pagina,
  ma.nm_menu_titulo        as nm_menu_titulo_processo,
  ma.nm_menu               as nm_menu_processo,
  ps.cd_processo           as Processo,
  ps.nm_processo           as Descritivo

from
  egisadmin.dbo.Menu m
  inner join egisadmin.dbo.Menu_Processo mp         on mp.cd_menu          = m.cd_menu
  inner join egisadmin.dbo.Processo_Sistema ps      on ps.cd_processo      = mp.cd_processo_sistema
  left outer join egisadmin.dbo.Menu ma             on ma.cd_menu          = mp.cd_menu_acesso
  left outer join egisadmin.dbo.Pagina_Internet pag on pag.cd_pagina       = ma.cd_pagina

where
  m.cd_menu = @cd_menu

order by
  mp.qt_ordem_menu_processo
  
go

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_menu_processo 
------------------------------------------------------------------------------
--exec pr_egis_menu_processo '[{
--	"cd_menu": 8719,
--    "cd_usuario": "113"

--}]'
--go

----app.post('/api/menu-processo', protegerRota, async (req, res) => {

--exec pr_egis_menu_processo '[{
--    "cd_empresa": "1",
--    "cd_modulo": "254",
--	"cd_menu": 8269,
--    "cd_usuario": "113"

--}]'
--go


   