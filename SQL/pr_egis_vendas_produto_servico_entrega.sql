--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL

go

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_vendas_produto_servico_entrega' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_vendas_produto_servico_entrega

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_vendas_produto_servico_entrega
-------------------------------------------------------------------------------
--pr_egis_vendas_produto_servico_entrega
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
create procedure pr_egis_vendas_produto_servico_entrega
@json nvarchar(max) = ''

--with encryption


as

set @json = isnull(@json,'')

declare @cd_empresa          int
declare @cd_parametro        int
declare @cd_documento        int = 0
declare @cd_item_documento   int
declare @cd_cliente          int
declare @cd_relatorio        int 
declare @cd_usuario          int 
declare @dt_hoje             datetime
declare @dt_inicial          datetime 
declare @dt_final            datetime
declare @cd_ano                   int = 0
declare @cd_mes                   int = 0
declare @vl_total            decimal(25,2) = 0.00
declare @vl_total_hoje       decimal(25,2) = 0.00
declare @cd_vendedor         int           = 0
declare @cd_menu             int           = 0
declare @nm_fantasia_empresa varchar(30) = ''

set @cd_empresa        = 0
set @cd_parametro      = 0
set @cd_documento      = 0
set @cd_relatorio      = 0
set @cd_item_documento = 0
set @cd_cliente        = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano = year(getdate())
set @cd_mes = month(getdate())  
set @vl_total          = 0


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
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
select @cd_menu                = valor from #json where campo = 'cd_menu'

set @cd_vendedor = isnull(@cd_vendedor,0)
set @cd_empresa  = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end


--select @dt_inicial, @dt_final

--select 
--  @nm_fantasia_empresa = nm_fantasia_empresa
--from
--  EGISADMIN.dbo.Empresa
--where
--  cd_empresa = @cd_empresa

set @cd_documento = ISNULL(@cd_documento,0)

  -- Semana do mês (1 a 6)


  SELECT 
    --isnull(pve.cd_empresa,@cd_empresa)     as cd_empresa,
	pv.cd_servico,
	max(s.nm_servico)                        as nm_servico,
	max( isnull(um.sg_unidade_medida,''))    as sg_unidade_medida,
	YEAR(pv.dt_pedido_entrega)               as cd_ano,
	MONTH(pv.dt_pedido_entrega)              as cd_mes,
    SUM(ISNULL(pv.vl_total_entrega, 0))      as vl_total,
	MAX(m.nm_mes)                            as nm_mes,
	count(distinct pv.cd_pedido_entrega)     as qt_entrega,
	COUNT(distinct pv.cd_cliente)            as qt_cliente,
	count(distinct pv.cd_motorista)          as qt_motorista,
	count(distinct pv.cd_veiculo)            as qt_veiculo,
	COUNT(distinct pv.cd_vendedor)           as qt_vendedor

  INTO #tmp
  FROM 
    pedido_entrega pv   --select * from pedido_entrega  --select * from servico
 
  inner join Cliente c                      on c.cd_cliente          = pv.cd_cliente
  inner join Servico s                      on s.cd_servico          = pv.cd_servico
  left outer join Unidade_Medida um         on um.cd_unidade_medida  = s.cd_unidade_medida
  left outer join pedido_venda_empresa pve  on pve.cd_pedido_venda   = pv.cd_pedido_venda
  left outer join Empresa_Faturamento ef    on ef.cd_empresa         = pve.cd_empresa
  --LEFT JOIN tipo_pedido tpe                 ON tpe.cd_tipo_pedido  = pv.cd_tipo_pedido
  left outer join Mes m                     on m.cd_mes             = MONTH(pv.dt_pedido_entrega)
  left outer join Vendedor v                on v.cd_vendedor        = pv.cd_vendedor

  WHERE 
    pv.dt_pedido_entrega BETWEEN @dt_inicial AND @dt_final  
	AND
	isnull(pv.cd_vendedor,0) = CASE WHEN @cd_vendedor = 0 THEN isnull(pv.cd_vendedor,0) ELSE @cd_vendedor END
  
  GROUP BY 
     pv.cd_servico,
	 YEAR(pv.dt_pedido_entrega),
	 MONTH(pv.dt_pedido_entrega)


  select @vl_total = SUM(vl_total)
  from
    #tmp

   --------------------------------------------------------------------------------------

	 select *, pc_total = case when @vl_total>0 then round(vl_total/@vl_total * 100, 2) else 0.00 end from #tmp
	 order by
	   cd_ano, cd_mes, vl_total desc

   --------------------------------------------------------------------------------------
    

go

--update
--  egisadmin.dbo.meta_procedure_colunas
--set
--  ativo = 1,
--  agrupador_base = 1
--where
--  nome_procedure = 'pr_monitor_egis_informacao'

--go
----use egissql_317
--go
--------------------------------------------------------------------------------
----Testando a Stored Procedure
--------------------------------------------------------------------------------
----exec pr_egis_vendas_cliente
--------------------------------------------------------------------------------
----use EGISSQL_rubio
--go
--exec pr_egis_vendas_produto_servico_entrega '[{"dt_inicial":"06/01/2025"}, {"dt_final":"06/30/2025"}]'
--go

--------------------------------------------------------------------------------