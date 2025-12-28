--BANCO DA EMPRESA
--------------------
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_pesquisa_tabela_registro' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_pesquisa_tabela_registro

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_pesquisa_tabela_registro
-------------------------------------------------------------------------------
--pr_egis_pesquisa_tabela_registro
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EGISSQL
--
--Objetivo         : Pesquisa de Registro na Tabela
--
--Data             : 25.04.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_pesquisa_tabela_registro
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
declare @cd_id_registro            int = 0
declare @cd_tabela                 int = 0
declare @nm_tabela                 varchar(80) = ''
declare @nm_atributo_chave         varchar(80) = ''
declare @cd_form                   int = 0
declare @cd_menu                   int = 0

----------------------------------------------------------------------------------------------------------      
select @cd_parametro       = valor from #json  with(nolock) where campo = 'cd_parametro'   
select @cd_usuario         = valor from #json  with(nolock) where campo = 'cd_usuario'   
select @dt_inicial         = valor from #json  with(nolock) where campo = 'dt_inicial'     
select @dt_final           = valor from #json  with(nolock) where campo = 'dt_final'    
select @cd_id_registro     = valor from #json  with(nolock) where campo = 'cd_documento'    
select @cd_form            = valor from #json  with(nolock) where campo = 'cd_form'    
select @cd_menu            = valor from #json  with(nolock) where campo = 'cd_menu'    

set @cd_form = ISNULL(@cd_form,0)
set @cd_menu = ISNULL(@cd_menu,0)

-----------------------------------------------------------------------------------------------------------------------------
--Form
-----------------------------------------------------------------------------------------------------------------------------

if @cd_form>0 
begin
select
  top 1
  @cd_tabela         = isnull(t.cd_tabela,0),
  @nm_tabela         = case when ISNULL(t.ic_sap_admin,'N')='S' then 'Egisadmin.dbo.' else CAST('' as char(1)) end
                       +
					   t.nm_tabela
  
from
  egisadmin.dbo.form f
  inner join egisadmin.dbo.menu m          on m.cd_menu = f.cd_menu
  inner join egisadmin.dbo.Menu_Tabela mt  on mt.cd_menu = f.cd_menu
  inner join egisadmin.dbo.Tabela t        on t.cd_tabela = mt.cd_tabela
  
where
  f.cd_form = @cd_form

end

-----------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------
--Menu
-----------------------------------------------------------------------------------------------------------------------------

if @cd_menu>0 
begin
select
  top 1
  @cd_tabela         = isnull(t.cd_tabela,0),
  @nm_tabela         = case when ISNULL(t.ic_sap_admin,'N')='S' then 'Egisadmin.dbo.' else CAST('' as char(1)) end
                       +
					   t.nm_tabela
  
from
  
  egisadmin.dbo.menu m          
  inner join egisadmin.dbo.Menu_Tabela mt  on mt.cd_menu  = m.cd_menu
  inner join egisadmin.dbo.Tabela t        on t.cd_tabela = mt.cd_tabela
  
where
  m.cd_menu = @cd_menu

end

-----------------------------------------------------------------------------------------------------------------------------


select
  top 1
  @nm_atributo_chave = nm_atributo
from
  EGISADMIN.dbo.atributo a 
where
  a.cd_tabela = @cd_tabela
  and
  isnull(a.ic_atributo_chave,'N') = 'S '

--select @cd_form, @cd_id_registro, @cd_tabela, @nm_tabela, @nm_atributo_chave

  set @sql = 'Select * from '+@nm_tabela+' where '+@nm_atributo_chave + ' = '+cast(@cd_id_registro as varchar(20))
  
  EXEC sp_executesql @sql
  
  --select @sql as sql_comando


  


go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_pesquisa_tabela_registro 
------------------------------------------------------------------------------
--exec pr_egis_pesquisa_tabela_registro '[{
--    "cd_empresa": "96",
--    "cd_parametro": "0",
--    "cd_form": "0",
--    "cd_menu": "7269",
--    "cd_documento": 1,
--    "cd_usuario": "113"
--}]'

go
