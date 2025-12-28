--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL

go

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_vendas_cliente' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_vendas_cliente

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_vendas_cliente
-------------------------------------------------------------------------------
--pr_egis_vendas_vendedor
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
create procedure pr_egis_vendas_cliente
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
declare @cd_ano              int = 0
declare @cd_mes              int = 0
declare @vl_total            decimal(25,2) = 0.00
declare @vl_total_hoje       decimal(25,2) = 0.00
declare @cd_vendedor         int           = 0
declare @cd_menu             int           = 0
declare @nm_fantasia_empresa varchar(30) = ''
declare @ic_imposto_venda    char(1)       = 'N'

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

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
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
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
select @cd_menu                = valor from #json where campo = 'cd_menu'

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()


if @cd_vendedor = 0 and @cd_usuario>0
begin
    set @cd_vendedor  = isnull(dbo.fn_usuario_vendedor(@cd_usuario),0)
	--INSERT INTO @vendedores (cd_vendedor) VALUES (@cd_vendedor);
end

----------------------------------------------------------------------------------------------------------

select @ic_imposto_venda = ISNULL(ic_imposto_venda,'N') from Parametro_BI where cd_empresa = @cd_empresa

----------------------------------------------------------------------------------------------------------


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
	pv.cd_cliente,
	YEAR(pv.dt_pedido_venda)                 as cd_ano,
	MONTH(pv.dt_pedido_venda)                as cd_mes,
    max(v.nm_fantasia_vendedor)              as nm_fantasia_vendedor,
    --SUM(ISNULL(pv.vl_total_pedido_ipi, 0))   as vl_total,
				SUM( cast(round(
	
	     case when @ic_imposto_venda = 'S' 
		 then pv.vl_total_pedido_ipi else pv.vl_total_pedido_venda end
		 	 
		 ,2) 
	
	     as decimal(25,2)))                  as vl_total,  
	MAX(m.nm_mes)                            as nm_mes,
	MAX(c.nm_fantasia_cliente)               as nm_fantasia_cliente,
	MAX(c.nm_razao_social_cliente)           as nm_razao_social
  INTO #tmp
  FROM pedido_venda pv
  left outer join pedido_venda_empresa pve  ON pve.cd_pedido_venda = pv.cd_pedido_venda
  left outer join Empresa_Faturamento ef    on ef.cd_empresa       = pve.cd_empresa
  LEFT JOIN tipo_pedido tpe                 ON tpe.cd_tipo_pedido  = pv.cd_tipo_pedido
  left outer join Mes m                     on m.cd_mes            = MONTH(pv.dt_pedido_venda)
  left outer join Vendedor v                on v.cd_vendedor       = pv.cd_vendedor
  inner join Cliente c                      on c.cd_cliente        = pv.cd_cliente

  WHERE 
    pv.dt_pedido_venda BETWEEN @dt_inicial AND @dt_final
    --AND ISNULL(v.ic_egismob_vendedor, 'S') = 'S'
    AND pv.cd_pedido_venda IN (
      SELECT i.cd_pedido_venda 
      FROM Pedido_Venda_Item i 
      WHERE i.cd_pedido_venda = pv.cd_pedido_venda AND i.dt_cancelamento_item IS NULL
    )
    AND pv.cd_vendedor = CASE WHEN @cd_vendedor = 0 THEN pv.cd_vendedor ELSE @cd_vendedor END
    AND ISNULL(tpe.ic_gera_bi, 'S') = 'S'
    AND ISNULL(tpe.ic_bonificacao_tipo_pedido, 'N') = 'N'
    AND ISNULL(tpe.ic_indenizacao_tipo_pedido, 'N') = 'N'
  GROUP BY 
     pv.cd_cliente,
	 YEAR(pv.dt_pedido_venda),
	 MONTH(pv.dt_pedido_venda)


  select @vl_total = SUM(vl_total)
  from
    #tmp

   --------------------------------------------------------------------------------------

	 select *, pc_total = case when @vl_total>0 then round(vl_total/@vl_total * 100, 2) else 0.00 end from #tmp
	 order by
	   vl_total desc

   --------------------------------------------------------------------------------------
    

go

--update
--  egisadmin.dbo.meta_procedure_colunas
--set
--  ativo = 1,
--  agrupador_base = 1
--where
--  nome_procedure = 'pr_monitor_egis_informacao'

go
--use egissql_317
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_vendas_cliente
------------------------------------------------------------------------------
--use EGISSQL_SPRINGS
go
--exec pr_egis_vendas_cliente '[{"dt_inicial":"06/01/2025"}, {"dt_final":"06/30/2025"}]'
go

------------------------------------------------------------------------------