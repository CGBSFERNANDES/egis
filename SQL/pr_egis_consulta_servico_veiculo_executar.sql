--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL

go

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_consulta_servico_veiculo_executar' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_consulta_servico_veiculo_executar

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_consulta_servico_veiculo_executar
-------------------------------------------------------------------------------
--pr_egis_vendas_mensal_vendedor
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Monitor Egis de Informação On-line

--Data             : 27.03.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_consulta_servico_veiculo_executar
@json nvarchar(max) = ''

--with encryption


as

set @json = isnull(@json,'')

declare @cd_empresa        int
declare @cd_parametro      int
declare @cd_documento      int = 0
declare @cd_item_documento int
declare @cd_cliente        int
declare @cd_relatorio      int 
declare @cd_usuario        int 
declare @dt_hoje           datetime
declare @dt_inicial        datetime = null
declare @dt_final          datetime = null
declare @cd_ano                 int = 0
declare @cd_mes                 int = 0
declare @vl_total          decimal(25,2) = 0.00
declare @vl_total_hoje     decimal(25,2) = 0.00
declare @cd_veiculo        int           = 0
declare @cd_menu           int           = 0

set @cd_empresa        = 0
set @cd_parametro      = 0
set @cd_documento      = 0
set @cd_relatorio      = 0
set @cd_item_documento = 0
set @cd_cliente        = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano            = year(getdate())
set @cd_mes            = month(getdate())  
set @vl_total          = 0

if @dt_inicial is null
begin
  set @cd_mes = 1
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @cd_mes = MONTH(getdate())
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end


--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

select                     

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]              as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_documento           = valor from #json where campo = 'cd_documento'
select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'
select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_cliente             = valor from #json where campo = 'cd_cliente'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
--select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
--select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_veiculo            = valor from #json where campo = 'cd_veiculo'
select @cd_menu                = valor from #json where campo = 'cd_menu'

set @cd_veiculo  = ISNULL(@cd_veiculo,0) 
set @cd_documento = ISNULL(@cd_documento,0)

--use egissql_35
--select @dt_inicial, @dt_final

--select * from ordem_frota_servico


select
  v.cd_veiculo,
  v.nm_veiculo,
  v.cd_placa_veiculo,
  ts.nm_tipo_servico_veiculo,
  i.dt_item_ordem,
  dt_vencimento = i.dt_item_ordem + ISNULL(ts.qt_prazo_execucao,0)



from 
  ordem_frota_servico_item i
  inner join Ordem_Frota_Servico o   on o.cd_ordem                 = i.cd_ordem
  inner join Tipo_Servico_Veiculo ts on ts.cd_tipo_servico_veiculo = i.cd_tipo_servico_veiculo
  inner join Veiculo v               on v.cd_veiculo               = o.cd_veiculo

where
   o.dt_baixa_ordem is not null
   and
   ISNULL(ts.qt_prazo_execucao,0)>0
   and
   o.cd_veiculo = case when @cd_veiculo = 0 then o.cd_veiculo else @cd_veiculo end
   and
   i.dt_item_ordem + ISNULL(ts.qt_prazo_execucao,0)>=@dt_hoje


order by
  6

go



--go
--use EGISSQL_317

--go
--------------------------------------------------------------------------------
----Testando a Stored Procedure
--------------------------------------------------------------------------------
----exec pr_egis_vendas_semanal
--------------------------------------------------------------------------------
--exec pr_egis_consulta_servico_veiculo_executar '[{"dt_inicial":"01/01/2025", "dt_final": "12/31/2025","cd_veiculo":0}]'
--go

