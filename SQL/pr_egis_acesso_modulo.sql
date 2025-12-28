USE EGISADMIN
GO
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_acesso_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_acesso_modulo

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_acesso_modulo
-------------------------------------------------------------------------------
--pr_egis_acesso_modulo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--Autor(es)        : Carlos Cardoso Fernandes
--Banco de Dados   : EgisAdmin		
--Objetivo         : Acesso ao Módulo Egis
--Data             : 21.04.2025
--Alteração        : 
   
------------------------------------------------------------------------------
create procedure pr_egis_acesso_modulo
@cd_usuario int = 0
--with encryption
as

set @cd_usuario = isnull(@cd_usuario,0)

declare @cd_grupo_usuario       int = 0
declare @ic_alfa_modulo_empresa char(1) = 'S'
declare @cd_idioma              int = 1
  
  
set nocount on  
  
  
  
 Select   
   distinct   
   u.cd_usuario,
   u.nm_usuario,
   u.nm_fantasia_usuario,
   m.cd_modulo,
   m.nm_modulo,  --select * from modulo order by nm_modulo
   m.sg_modulo,
   m.nm_fantasia_modulo,
   c.nm_cadeia_valor,
   c.cd_ordem_cadeia_valor,
   1                        as ic_liberado,
   ic_exec_modulo = case when m.cd_modulo = 232 then 'S' else 'N' end,
   exePath = 'SAT2002.exe',
   --LTRIM(RTRIM(u.nm_fantasia_usuario)) +'USUARIOGBSSENHA'+LTRIM(rtrim(u.cd_senha_usuario)) as parametros
    LTRIM(RTRIM(u.nm_fantasia_usuario)) +'USUARIOGBSSENHA'+LTRIM(rtrim(u.cd_senha_repnet_usuario)) as parametros
  
  
   from
     Usuario u 
	 inner join Usuario_GrupoUsuario UGU   on ugu.cd_usuario = u.cd_usuario
	
           INNER JOIN Modulo_GrupoUsuario MGU  
                               ON (UGU.cd_grupo_usuario = MGU.cd_grupo_usuario)  
           INNER JOIN Modulo M   
                               ON (M.cd_modulo = MGU.cd_modulo)  
           LEFT OUTER JOIN Usuario_Config UC   
                               ON (MGU.cd_modulo = UC.cd_modulo AND  
                                   UC.cd_usuario = @cd_usuario)    
           left outer join modulo_idioma mi on mi.cd_modulo = m.cd_modulo  
		   left outer join cadeia_valor c on c.cd_cadeia_valor = m.cd_cadeia_valor

	--left outer join menu_filtro mf on mf.cd_menu = m

   WHERE   
     u.cd_usuario = @cd_usuario  
     AND isnull(m.ic_liberado,'N') = 'S'  
     AND isnull(m.cd_tipo_versao,0) = 4 --EgisNet   

order by
   m.nm_modulo,
   m.cd_modulo

--Mostra a Tabela Final    
  
  
  
  
go

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_acesso_modulo 113
------------------------------------------------------------------------------


------------------------------------------------------------------------------

