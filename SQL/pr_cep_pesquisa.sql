USE EGISCEP
go
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_cep_pesquisa' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_cep_pesquisa

GO

-------------------------------------------------------------------------------
--sp_helptext pr_cep_pesquisa
-------------------------------------------------------------------------------
--pr_cep_pesquisa
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EGISCEP
--
--Objetivo         : Pesquisa de CEP
--
--Data             : 22.04.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_cep_pesquisa
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
identity(int,1,1)             as id,                   
    valores.[key]             as campo,                   
    valores.[value]           as valor                  
into #json                  
from                   
   openjson(@json)root                  
   cross apply openjson(root.value) as valores    
  
----------------------------------------------------------------------------------------------------------      
declare @cd_parametro              int = 0  
declare @cd_usuario                int = 0  
declare @cd_cep                    varchar(9) = ''  
declare @dt_inicial                datetime        
declare @dt_final                  datetime       
----------------------------------------------------------------------------------------------------------      
select @cd_parametro       = valor from #json  with(nolock) where campo = 'cd_parametro'   
select @cd_usuario              = valor from #json  with(nolock) where campo = 'cd_usuario'   
select @dt_inicial     = valor from #json  with(nolock) where campo = 'dt_inicial'     
select @dt_final     = valor from #json  with(nolock) where campo = 'dt_final'    
select @cd_cep                = valor from #json  with(nolock) where campo = 'cd_cep'   
  
----------------------------------------------------------------------------------------------------------     
--CEP  
----------------------------------------------------------------------------------------------------------     
set @cd_cep = replace(@cd_cep,'-','')  
  
  
if @cd_parametro = 1  
begin  
  select  
    c.*,  
 p.nm_pais,  
 e.nm_estado,  
 e.sg_estado,  
 cid.nm_cidade  
  from  
   cep c  
   left outer join pais p     on p.cd_pais     = c.cd_pais  
   left outer join estado e   on e.cd_estado   = c.cd_estado  
   left outer join cidade cid on cid.cd_cidade = c.cd_cidade  
  where  
    c.cd_cep like '%'+@cd_cep+'%'   
end  
  


go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_cep_pesquisa 
------------------------------------------------------------------------------
--exec pr_cep_pesquisa '[{
--    "cd_parametro": 1,
--	"cd_cep": "09811",
--	"cd_usuario": 1,
--	"dt_inicial"  : "01/01/2025",
--	"dt_final"    : "12/31/2025"
--}]'
--go
