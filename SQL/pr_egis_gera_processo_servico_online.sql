--BANCO DA EMPRESA / CLIENTE
-----------------------------
--USE EGISSQL
--GO
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_gera_processo_servico_online' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_gera_processo_servico_online

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_gera_processo_servico_online
-------------------------------------------------------------------------------
--pr_egis_gera_processo_servico_online
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : 
--Data             : 13.03.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_gera_processo_servico_online
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
declare @cd_empresa                int = 0
declare @ic_egismob                char(1) = 'N'
declare @ic_parametro              int     = 0
declare @cd_modulo_start           int     = 282
declare @cd_controle               int     = 0
declare @cd_servico                int     = 0

----------------------------------------------------------------------------------------------------------      

select @cd_parametro       = valor from #json  with(nolock) where campo = 'cd_parametro'   
select @cd_usuario         = valor from #json  with(nolock) where campo = 'cd_usuario'   
select @dt_inicial         = valor from #json  with(nolock) where campo = 'dt_inicial'     
select @dt_final           = valor from #json  with(nolock) where campo = 'dt_final'    
select @cd_form            = valor from #json  with(nolock) where campo = 'cd_form'    
select @cd_menu            = valor from #json  with(nolock) where campo = 'cd_menu'    
select @cd_servico         = valor from #json  with(nolock) where campo = 'cd_servico'    

set @cd_parametro = isnull(@cd_parametro,0)
set @cd_empresa   = dbo.fn_empresa()
set @ic_egismob   = ISNULL(@ic_egismob,'N')
set @ic_parametro = isnull(@cd_parametro,0)

----------------------------------------------------------------------------------------------------------      


    -- Lógica para gerar o processo de serviço

    SELECT 
	    s.cd_servico  as id,
		@dt_hoje      as 'data',
        s.cd_servico  as Item,
		s.nm_servico  as Processo,
        --GETDATE() AS Data,
        --'Processando' AS Processo,
        
		1 as TempoExecucao,
		ISNULL(a.ic_diario,'N')         as ic_diario,
		ISNULL(a.hr_horario_inicial,'') as hr_horario_inicial,
		ISNULL(a.hr_horario_final,'')   as hr_horario_final,
		ISNULL(a.qt_ocorrencia,0)       as qt_ocorrencia,

        'Parado'                        as nm_status_servico,
        'Aguardando'                    as nm_mensagem_servico

    FROM 
	  egisadmin.dbo.GSO_Servico s
	  left outer join GSO_Servico_Agenda a on a.cd_servico = s.cd_servico
    where
	  s.cd_servico = case when @cd_servico = 0 then s.cd_servico else @cd_servico end
    order by
	  1


    --select * from egisadmin.dbo.GSO_Servico

	--Processo do Serviço --
	--select * from consulta_pedido_troca


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_gera_processo_servico_online  0,3  
------------------------------------------------------------------------------
go

--exec pr_egis_gera_processo_servico_online '[{
--    "cd_parametro":"0",
--	"cd_servico":"0",
--	"cd_usuario": 113

--}]'
--go

--@cd_empresa int = 0,
--@cd_usuario int = 0,
--@cd_idioma  int = 0
