IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_faturamento_cliente_logistica'
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_faturamento_cliente_logistica

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_faturamento_cliente_logistica
-------------------------------------------------------------------------------
--pr_egis_faturamento_cliente_logistica
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : DashBoard - Módulos
--
--Data             : 30.04.2022
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_faturamento_cliente_logistica
@json nvarchar(max) = ''

--@cd_modulo    int = 0,
--@cd_parametro int = 0,
--@cd_usuario   int = 0,
--@dt_inicial   datetime = null,
--@dt_final     datetime = null

--with encryption


as

set @json = isnull(@json,'')


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

--Declare--

----------------------------------------------------------------------------------------------------------    

declare @cd_modulo    int = 0
declare @cd_parametro int = 0
declare @cd_usuario   int = 0
declare @dt_inicial   datetime = null
declare @dt_final     datetime = null
declare @cd_empresa   int = 0
declare @cd_ano       int = 0
declare @cd_mes       int = 0
declare @cd_veiculo   int = 0
declare @cd_cliente   int = 0
declare @vl_total     decimal(25,2) = 0.00
declare @pc_total     decimal(25,2) = 0.00


----------------------------------------------------------------------------------------------------------    
set @cd_empresa = dbo.fn_empresa()
----------------------------------------------------------------------------------------------------------
select @cd_modulo 	            = valor from #json  with(nolock) where campo = 'cd_modulo' 
select @cd_parametro	        = valor from #json  with(nolock) where campo = 'cd_parametro' 
select @cd_usuario   		    = valor from #json  with(nolock) where campo = 'cd_usuario'
select @dt_inicial   		    = valor from #json  with(nolock) where campo = 'dt_inicial'
select @dt_final   		        = valor from #json  with(nolock) where campo = 'dt_final'
select @cd_veiculo 	            = valor from #json  with(nolock) where campo = 'cd_veiculo' 
select @cd_cliente 	            = valor from #json  with(nolock) where campo = 'cd_cliente' 

----------------------------------------------------------------------------------------------------------

set @cd_parametro = isnull(@cd_parametro,0) 
set @cd_ano       = year(getdate())
set @cd_mes       = month(getdate())

----------------------------------------------------------------------------------------------------------
  
  --Início do Período

  if @dt_inicial is null or @dt_inicial = '' or isnull(@dt_inicial,'') = ''
    set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)  

	--Final do Periodo
  if @dt_final is null or @dt_final = '' or isnull(@dt_final,'') = ''
	set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano) 



--select * from egisadmin.dbo.modulo order by cd_modulo

--select * from egisadmin.dbo.modulo order by nm_modulo

--

      select
	     identity(int,1,1)                   as qt_posicao,
	     c.cd_cliente,
		 max(c.nm_fantasia_cliente)          as nm_fantasia_cliente,
		 max(c.nm_razao_social_cliente)      as nm_razao_social,		 
		 count(distinct p.cd_pedido_entrega) as qt_pedido_entrega,
	     SUM(isnull(p.vl_total_entrega,0))   as vl_total_entrega

      into
	     #FatCliente

      from
         pedido_entrega p
   	     left outer join romaneio r               on r.cd_romaneio = p.cd_romaneio
         left outer join romaneio_entrega_dados d on d.cd_romaneio = r.cd_romaneio   --select * from romaneio_entrega_dados
		 left outer join Cliente c                on c.cd_cliente  = p.cd_cliente
		 

	  where
	    c.cd_cliente = case when @cd_veiculo = 0 then c.cd_cliente else @cd_cliente end
		and
        p.dt_entrega between @dt_inicial and @dt_final
		and
		p.dt_cancelamento is null

       group by
	      c.cd_cliente

       order by
	     6 desc

       select
	     @vl_total = SUM(vl_total_entrega)
	   from
	     #FatCliente


       select
	     *,
		 pc_total = cast(round(case when @vl_total>0 then vl_total_entrega/@vl_total*100 else 0.00 end,2) as decimal(25,2))
	   from 
	     #FatCliente
	   order by
	      vl_total_entrega desc

		  --select * from Romaneio

----------------------------------------

go

------------------------------------------------------------------------------
--pr_egis_processo_modulos
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--
--use EGISSQL_247
--go
--exec pr_egis_faturamento_cliente_logistica '[{"cd_cliente":0, "cd_parametro": 1,"cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
--go
------------------------------------------------------------------------------
