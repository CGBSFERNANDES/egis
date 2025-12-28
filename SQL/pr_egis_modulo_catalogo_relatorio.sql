--Banco do Cliente
--

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_modulo_catalogo_relatorio' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_modulo_catalogo_relatorio

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_modulo_catalogo_relatorio
-------------------------------------------------------------------------------
--pr_egis_modulo_catalogo_relatorio
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
create procedure pr_egis_modulo_catalogo_relatorio  
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
  
----------------------------------------------------------------------------------------------------------        
select @cd_parametro       = valor from #json  with(nolock) where campo = 'cd_parametro'     
select @cd_usuario         = valor from #json  with(nolock) where campo = 'cd_usuario'     
select @cd_grupo_usuario   = valor from #json  with(nolock) where campo = 'cd_grupo_usuario'     
select @dt_inicial         = valor from #json  with(nolock) where campo = 'dt_inicial'       
select @dt_final           = valor from #json  with(nolock) where campo = 'dt_final'      
select @cd_form            = valor from #json  with(nolock) where campo = 'cd_form'      
select @cd_menu            = valor from #json  with(nolock) where campo = 'cd_menu'      
select @cd_modulo          = valor from #json  with(nolock) where campo = 'cd_modulo'     
----------------------------------------------------------------------------------------------------------        
  
set @cd_modulo        = ISNULL(@cd_modulo,0)  
set @cd_form          = ISNULL(@cd_form,0)  
set @cd_menu          = ISNULL(@cd_menu,0)  
set @cd_grupo_usuario = isnull(@cd_grupo_usuario,0)

--Relatórios do Menu Padrões independente de Grupo de usuário---------------------------------------------

select   
   mr.cd_modulo_relatorio,  
   mr.cd_modulo,  
   mr.cd_relatorio,  
   mr.qt_ordem_relatorio,  
   mr.ic_ativo_grafico_modulo,  
   m.nm_modulo,  
   mu.cd_menu,
   mu.nm_menu,
   mu.nm_menu_titulo,
   r.nm_relatorio,  
   r.nm_titulo_relatorio,  
   r.ds_relatorio,  
   r.cd_form,  
   r.nm_icone_relatorio,  
   r.ic_grafico,  
   r.ic_grid_relatorio,  
   pr.cd_parametro_relatorio,  
   pr.cd_usuario,
   isnull(mrel.ic_filtro_relatorio,'N')  as ic_filtro_relatorio,
   isnull(mrel.cd_menu_filtro,0)         as cd_menu_filtro
  
  --select * from egisadmin.dbo.menu_relatorio

  into #MenuGrupoRelatorioPadrao


  from   
    egisadmin.dbo.modulo_relatorio mr                         with(nolock) --select * from egisadmin.dbo.modulo_relatorio  
    inner join egisadmin.dbo.modulo m                         with(nolock) on m.cd_modulo      = mr.cd_modulo  
    inner join egisadmin.dbo.relatorio r                      with(nolock) on r.cd_relatorio   = mr.cd_relatorio  
    left outer join Parametro_Relatorio pr                    with(nolock) on pr.cd_relatorio  = mr.cd_relatorio and pr.cd_usuario = @cd_usuario  
	left outer join egisadmin.dbo.menu_relatorio  mrel        with(nolock) on mrel.cd_modulo   = mr.cd_modulo and mrel.cd_relatorio = r.cd_relatorio
	                                                                          and
	                                                                          mrel.cd_menu     = @cd_menu

    left outer join egisadmin.dbo.menu mu                      with(nolock) on mu.cd_menu       = @cd_menu
	
  where  
    isnull(mr.ic_ativo_modulo_relatorio,'N') = 'S'  
    and  
    mr.cd_modulo = case when @cd_menu <> 0 and mr.cd_modulo <> @cd_modulo then mrel.cd_modulo else @cd_modulo end
	


  order by  
    mr.qt_ordem_relatorio  

  select * from #MenuGrupoRelatorioPadrao
  order by
     qt_ordem_relatorio  

--	 return

  
--select   
--   mr.cd_modulo_relatorio,  
--   mr.cd_modulo,  
--   mr.cd_relatorio,  
--   mr.qt_ordem_relatorio,  
--   mr.ic_ativo_grafico_modulo,  
--   m.nm_modulo,  
--   r.nm_relatorio,  
--   r.nm_titulo_relatorio,  
--   r.ds_relatorio,  
--   r.cd_form,  
--   r.nm_icone_relatorio,  
--   r.ic_grafico,  
--   r.ic_grid_relatorio,  
--   pr.cd_parametro_relatorio,  
--   pr.cd_usuario  
    
--  into #MenuGrupoRelatorio


--  from   
--    egisadmin.dbo.modulo_relatorio mr                         with(nolock) --select * from egisadmin.dbo.modulo_relatorio  
--    inner join egisadmin.dbo.modulo m                         with(nolock) on m.cd_modulo      = mr.cd_modulo  
--    inner join egisadmin.dbo.relatorio r                      with(nolock) on r.cd_relatorio   = mr.cd_relatorio  
--    left outer join Parametro_Relatorio pr                    with(nolock) on pr.cd_relatorio  = mr.cd_relatorio and pr.cd_usuario = @cd_usuario  
--    left outer join egisadmin.dbo.grupo_usuario_relatorio gur with(nolock) on gur.cd_modulo    = mr.cd_modulo   and
--                                                                              gur.cd_relatorio = mr.cd_relatorio  
--  where  
--    isnull(mr.ic_ativo_modulo_relatorio,'N') = 'S'  
--    and  
--    mr.cd_modulo = @cd_modulo  
--    and  
--    isnull(gur.cd_grupo_usuario,0) = case when isnull(@cd_grupo_usuario,0) = 0 then isnull(gur.cd_grupo_usuario,0) else @cd_grupo_usuario end  
--  order by  
--    mr.qt_ordem_relatorio  


--  select * from #MenuGrupoRelatorio
--  order by
--     qt_ordem_relatorio

go

--select dbo.fn_empresa() as cd_empresa

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_modulo_catalogo_relatorio 
------------------------------------------------------------------------------
--exec pr_egis_modulo_catalogo_relatorio '[{
--    "cd_empresa": "1",
--    "cd_modulo": "239",
--	"cd_menu": 7183,
--    "cd_usuario": "113"

--}]'

--go

--use egissql_rubio
--go
--exec pr_egis_modulo_catalogo_relatorio '[{
--    "cd_empresa": "345",
--    "cd_modulo": "101",
--	"cd_menu": 7643,
--    "cd_usuario": "113",
--    "cd_grupo_usuario": 0
--}]'



   