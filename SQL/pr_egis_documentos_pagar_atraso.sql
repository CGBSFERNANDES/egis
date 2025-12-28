IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_documentos_pagar_atraso'
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_documentos_pagar_atraso

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_documentos_pagar_atraso
-------------------------------------------------------------------------------
--pr_egis_documentos_pagar_atraso
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Consulta de Documentos a Pagar em Atraso
--
--Data             : 26.06.2022
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_documentos_pagar_atraso
@json nvarchar(max)  = ''



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

----------------------------------------------------------------------------------------------------------    
set @cd_empresa = dbo.fn_empresa()
----------------------------------------------------------------------------------------------------------
select @cd_modulo 	            = valor from #json  with(nolock) where campo = 'cd_modulo' 
select @cd_parametro	        = valor from #json  with(nolock) where campo = 'cd_parametro' 
select @cd_usuario   		    = valor from #json  with(nolock) where campo = 'cd_usuario'
select @dt_inicial   		    = valor from #json  with(nolock) where campo = 'dt_inicial'
select @dt_final   		        = valor from #json  with(nolock) where campo = 'dt_final'

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

----------------------------------------------------------------------------------------------------------

--Contas a Pagar--

  --Documentos em Aberto por Fornecedor-------------------------------------------------------------------
  --select * from documento_pagar

  select
    d.cd_identificacao_document,
	d.dt_emissao_documento_paga,
	d.dt_vencimento_documento,
	d.vl_saldo_documento_pagar,


	      case when (isnull(d.cd_empresa_diversa, 0)      <> 0)  then isnull(cast((select top 1 z.sg_empresa_diversa     from empresa_diversa z where z.cd_empresa_diversa = d.cd_empresa_diversa) as varchar(30)),d.nm_fantasia_fornecedor)    
           when (isnull(d.cd_contrato_pagar, 0)       <> 0)  then isnull(cast((select top 1 w.nm_fantasia_fornecedor from contrato_pagar w  where w.cd_contrato_pagar  = d.cd_contrato_pagar)  as varchar(30)),d.nm_fantasia_fornecedor)  
           when (isnull(d.cd_funcionario, 0)          <> 0)  then isnull(cast((select top 1 k.nm_funcionario         from funcionario k     where k.cd_funcionario     = d.cd_funcionario)     as varchar(30)),d.nm_fantasia_fornecedor)    
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then cast(d.nm_fantasia_fornecedor as varchar(30))  
      end                             as 'cd_favorecido',                 

      case when (isnull(d.cd_empresa_diversa, 0)      <> 0)  then cast((select top 1 z.nm_empresa_diversa from empresa_diversa z  where z.cd_empresa_diversa = d.cd_empresa_diversa) as varchar(50))  
           when (isnull(d.cd_contrato_pagar, 0)       <> 0)  then cast((select top 1 w.nm_contrato_pagar  from contrato_pagar w   where w.cd_contrato_pagar = d.cd_contrato_pagar)   as varchar(50))  
           when (isnull(d.cd_funcionario, 0)          <> 0)  then cast((select top 1 k.nm_funcionario     from funcionario k      where k.cd_funcionario = d.cd_funcionario)         as varchar(50))  
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then cast((select top 1 o.nm_razao_social    from vw_destinatario o  where o.nm_fantasia    = d.nm_fantasia_fornecedor  and o.cd_tipo_destinatario = d.cd_tipo_destinatario) as varchar(50))    
      end                             as 'nm_favorecido',

	td.nm_tipo_destinatario,
	pf.nm_conta_plano_financeiro,
	cc.nm_centro_custo,
	d.nm_observacao_documento,
	tcpa.nm_tipo_conta_pagar,	
	cast(@dt_hoje - d.dt_vencimento_documento as int )            as qt_dia_atraso
	-------------------------------------------------------------------------------   

  from
      Documento_Pagar d
	  left outer join Tipo_Destinatario td      on td.cd_tipo_destinatario  = d.cd_tipo_destinatario
	  left outer join Plano_Financeiro pf       on pf.cd_plano_financeiro   = d.cd_plano_financeiro
	  left outer join Centro_Custo cc           on cc.cd_centro_custo       = d.cd_centro_custo
	  left outer join tipo_conta_pagar tcpa     on tcpa.cd_tipo_conta_pagar = d.cd_tipo_conta_pagar      
	where
        ISNULL(d.vl_saldo_documento_pagar,0)>0
		and
		d.dt_cancelamento_documento is null
		and
		d.dt_vencimento_documento < @dt_hoje

    order by
	   d.dt_vencimento_documento

  return

go

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_documentos_pagar_atraso '[{"dt_base": "06/26/2025", "cd_usuario":113}]'
------------------------------------------------------------------------------

