--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL

go

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_proposta_produto' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_proposta_produto

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_proposta_produto
-------------------------------------------------------------------------------
--pr_egis_proposta_produto
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
create procedure pr_egis_proposta_produto
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
	i.cd_produto,
	YEAR(c.dt_consulta)                                  as cd_ano,
	MONTH(c.dt_consulta)                                 as cd_mes,
	MAX(m.nm_mes)                              as nm_mes,
    max( isnull(p.nm_fantasia_produto, ''))              as nm_fantasia_produto,
   
   SUM( cast(

      round((isnull(i.qt_item_consulta,0) * isnull(i.vl_unitario_item_consulta,0))
       +
   ( 
   case when isnull(tpe.ic_imposto_tipo_pedido,'N') = 'S' then
    ((i.qt_item_consulta * i.vl_unitario_item_consulta)*isnull(i.pc_ipi,0)/100) --ipi
    +
     isnull(i.vl_item_icms_st,0)          --icm st
   else
     0.00
   end
   + isnull(i.vl_frete_item_consulta,0) ),2) --frete


	as decimal(25,2)))                         as vl_total,
	
	MAX(p.cd_mascara_produto)                  as cd_mascara_produto,
	MAX(p.nm_produto)                          as nm_produto,
	MAX(um.sg_unidade_medida)                  as sg_unidade_medida

  INTO #tmp
  FROM consulta c
  inner join consulta_itens i               on i.cd_consulta        = c.cd_consulta
  inner join produto p                      on p.cd_produto         = i.cd_produto
  left outer join unidade_medida um         on um.cd_unidade_medida = p.cd_unidade_medida
  left outer join tipo_proposta tpo         on tpo.cd_tipo_proposta = c.cd_tipo_proposta
  LEFT JOIN tipo_pedido tpe                 ON tpe.cd_tipo_pedido   = tpo.cd_tipo_pedido
  left outer join Mes m                     on m.cd_mes             = MONTH(c.dt_consulta)
  
  WHERE 
    c.dt_consulta BETWEEN @dt_inicial AND @dt_final
	and
    i.dt_perda_consulta_itens is null 
    and
	ISNULL(i.cd_pedido_venda,0) = 0
	
    AND c.cd_vendedor = CASE WHEN @cd_vendedor = 0 THEN c.cd_vendedor ELSE @cd_vendedor END
    AND ISNULL(tpe.ic_gera_bi, 'S') = 'S'
    AND ISNULL(tpe.ic_bonificacao_tipo_pedido, 'N') = 'N'
    AND ISNULL(tpe.ic_indenizacao_tipo_pedido, 'N') = 'N'
  GROUP BY 
     i.cd_produto,
	 YEAR(c.dt_consulta),
	 MONTH(c.dt_consulta)


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
--use egissql_rubio
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_proposta_cliente
------------------------------------------------------------------------------
--use EGISSQL_SPRINGS
go
--exec pr_egis_proposta_produto '[{"cd_vendedor": 0, "dt_inicial":"06/01/2025"}, {"dt_final":"06/30/2025"}]'
go

------------------------------------------------------------------------------