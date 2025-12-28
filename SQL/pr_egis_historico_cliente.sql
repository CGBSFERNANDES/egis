IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_historico_cliente' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_historico_cliente

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_historico_cliente
-------------------------------------------------------------------------------
--pr_egis_historico_cliente
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Processo de Entrada de Validação do Comercial
--
--Data             : 03.06.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_historico_cliente
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

--Declare--

----------------------------------------------------------------------------------------------------------     

declare @cd_parametro         int = 0
declare @cd_usuario           int = 0
declare @dt_inicial           datetime
declare @dt_final             datetime
declare @cd_vendedor          int = 0
declare @cd_cliente           int = 0
declare @cd_veiculo           int = 0
declare @cd_motorista         int = 0
declare @cd_entregador        int = 0
declare @cd_pedido_venda      int = 0
declare @ds_observacao        nvarchar(max) = ''
declare @cd_ano               int = 0
declare @cd_mes               int = 0
declare @cd_empresa           int = 0
declare @cd_consulta          int = 0
declare @nm_fantasia_cliente  varchar(60) = ''
declare @nm_fantasia_vendedor varchar(60) = ''

----------------------------------------------------------------------------------------------------------    
set @cd_empresa = dbo.fn_empresa()
----------------------------------------------------------------------------------------------------------
select @cd_parametro	        = valor from #json  with(nolock) where campo = 'cd_parametro' 
select @cd_usuario   		    = valor from #json  with(nolock) where campo = 'cd_usuario'
select @dt_inicial   		    = valor from #json  with(nolock) where campo = 'dt_inicial'
select @dt_final   		        = valor from #json  with(nolock) where campo = 'dt_final'
select @cd_consulta   		    = valor from #json  with(nolock) where campo = 'cd_consulta'
select @cd_cliente   		    = valor from #json  with(nolock) where campo = 'cd_cliente'
select @nm_fantasia_cliente     = valor from #json  with(nolock) where campo = 'nm_fantasia_cliente'
----------------------------------------------------------------------------------------------------------


set @cd_ano = year(getdate())
set @cd_mes = month(getdate())

  
  --Início do Período

  if @dt_inicial is null or @dt_inicial = '' or isnull(@dt_inicial,'') = ''
    set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)  

	--Final do Periodo
  if @dt_final is null or @dt_final = '' or isnull(@dt_final,'') = ''
	set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano) 

--select @dt_inicial, @dt_final

----------------------------------------------------------------------------------------------------------    
--Cliente
----------------------------------------------------------------------------------------------------------    
set @cd_cliente          = ISNULL(@cd_cliente,0)
set @nm_fantasia_cliente = ISNULL(@nm_fantasia_cliente,'')
----------------------------------------------------------------------------------------------------------    

if @cd_parametro = 1 and @nm_fantasia_cliente='' --@cd_cliente > 0
begin
  select
    c.cd_cliente,
	c.nm_fantasia_cliente,
	c.nm_razao_social_cliente,
	v.nm_fantasia_vendedor,
	c.dt_cadastro_cliente,
	tp.nm_tipo_pessoa,
	c.cd_cnpj_cliente,
	c.cd_inscestadual
  from
    cliente c
	left outer join vendedor v     on v.cd_vendedor = c.cd_vendedor
	left outer join Tipo_Pessoa tp on tp.cd_tipo_pessoa = c.cd_tipo_pessoa

  where
    cd_cliente = @cd_cliente
  return

end

--Fantasia de Cliente----

if @cd_parametro = 1 and @cd_cliente = 0 and @nm_fantasia_cliente<>''
begin
  select
    c.cd_cliente,
	c.nm_fantasia_cliente,
	c.nm_razao_social_cliente,
	v.nm_fantasia_vendedor,
	c.dt_cadastro_cliente
  from
    cliente c
	left outer join vendedor v on v.cd_vendedor = c.cd_vendedor

  where
    c.nm_fantasia_cliente like '%'+@nm_fantasia_cliente+'%'

  order by
    c.nm_fantasia_cliente

  return

end


--Totais------------------------------

if @cd_parametro = 99
begin

  --Dados do Cadastro do Cliente--

  select
    c.cd_cliente,
	max(c.nm_fantasia_cliente)  as nm_fantasia_cliente,
    max(v.nm_fantasia_vendedor) as nm_fantasia_vendedor,
	max(tp.nm_tabela_preco)     as nm_tabela_preco
  into
    #DadosCliente

  from
    Cliente c 
	left outer join Vendedor v          on v.cd_vendedor      = c.cd_vendedor
	left outer join Cliente_Empresa ce  on ce.cd_cliente      = c.cd_cliente
	left outer join Tabela_Preco tp     on tp.cd_tabela_preco = ce.cd_tabela_preco
  where
    c.cd_cliente = @cd_cliente

  group by
    c.cd_cliente

  --Ranking---

  select
     IDENTITY(int,1,1)                         as qt_ranking,
     pv.cd_cliente,     
  	 SUM( isnull(pv.vl_total_pedido_ipi,0))    as vl_total
  into #Ranking
  from
    Pedido_Venda pv
  where
    pv.cd_pedido_venda in ( select k.cd_pedido_venda from Pedido_Venda_Item k
	                         where
							   k.cd_pedido_venda = pv.cd_pedido_venda
							   and
							   k.dt_cancelamento_item is null 
							  
							   )

    and
	year(pv.dt_pedido_venda)=@cd_ano

  group by
    pv.cd_cliente

  order by
     3 desc
   

  --Atraso----

  select
    d.cd_cliente,
	SUM(isnull(d.vl_saldo_documento,0)) as vl_atraso
  into
    #Atraso

  from
    Documento_Receber d
  where
    d.dt_vencimento_documento<@dt_hoje
	and
	d.dt_cancelamento_documento is null
	and
	d.dt_devolucao_documento is null
	and
	ISNULL(d.vl_saldo_documento,0)>0

  group by
    d.cd_cliente

  --Faturamento--

  select
    n.cd_nota_saida,
    (select isnull(sum(vw.vl_unitario_item_total -  vw.vl_item_desconto),0) from vw_faturamento vw where vw.cd_nota_saida = n.cd_nota_saida) as vl_soma_total_item
  into #Valores_Somados
  from
    Nota_Saida n
	inner join Operacao_Fiscal opf         on opf.cd_operacao_fiscal     = n.cd_operacao_fiscal
	inner join Grupo_Operacao_Fiscal g     on g.cd_grupo_operacao_fiscal = opf.cd_grupo_operacao_fiscal
  where
    n.cd_cliente = @cd_cliente
	and
    year(n.dt_nota_saida) = @cd_ano --between @dt_inicial and @dt_final
	and
	n.cd_status_nota<>7
	and
	isnull(opf.ic_comercial_operacao,'N')  = 'S'
	and
	IsNull(opf.ic_analise_op_fiscal,'S') = 'S' 
	and
	g.cd_tipo_operacao_fiscal = 2

  group by
    n.cd_nota_saida

	--select * from #Valores_Somados

  --Faturamento--

  select
    n.cd_cliente,
	SUM( isnull(vs.vl_soma_total_item,0) )   as vl_total,
	MAX(n.dt_nota_saida)                     as dt_nota_saida,
	count(distinct n.cd_nota_saida)          as qt_nota

  into #Faturamento

  from
    Nota_Saida n
	inner join Serie_Nota_Fiscal s         on s.cd_serie_nota_fiscal     = n.cd_serie_nota
    left outer join #Valores_Somados vs    on vs.cd_nota_saida           = n.cd_nota_saida	
	inner join Operacao_Fiscal opf         on opf.cd_operacao_fiscal     = n.cd_operacao_fiscal
	inner join Grupo_Operacao_Fiscal g     on g.cd_grupo_operacao_fiscal = opf.cd_grupo_operacao_fiscal
  where
    n.cd_cliente = @cd_cliente
	and
    --n.dt_nota_saida between @dt_inicial and @dt_final
	year(n.dt_nota_saida) = @cd_ano --between @dt_inicial and @dt_final
	and
	n.cd_status_nota<>7
	and
	isnull(opf.ic_comercial_operacao,'N')  = 'S'
	and
	IsNull(opf.ic_analise_op_fiscal,'S') = 'S' 
	and
	g.cd_tipo_operacao_fiscal = 2

  group by
    n.cd_cliente
    

  --propostas--

  select
     co.cd_cliente,
     COUNT(distinct co.cd_consulta)            as qt_proposta,
  	 SUM( isnull(co.vl_total_consulta,0))      as vl_total
  into #Consulta

  from
    Consulta co

  where
    co.cd_cliente = @cd_cliente
	and
	co.cd_consulta in ( select
	                      i.cd_consulta from Consulta_Itens i 
	                    where 
						  i.cd_consulta = co.cd_consulta and i.dt_perda_consulta_itens is null and
	                    ISNULL(i.cd_pedido_venda,0) = 0 )
    and
	year(co.dt_consulta)=@cd_ano

    group by
	  co.cd_cliente

  --Pedidos

  select
     pv.cd_cliente,
     COUNT(distinct pv.cd_pedido_venda)        as qt_pedido_venda,
  	 SUM( isnull(pv.vl_total_pedido_ipi,0))    as vl_total
  into #Venda 
  from
    Pedido_Venda pv
  where
    pv.cd_cliente = @cd_cliente
	and
    pv.cd_pedido_venda in ( select k.cd_pedido_venda from Pedido_Venda_Item k
	                         where
							   k.cd_pedido_venda = pv.cd_pedido_venda
							   and
							   k.dt_cancelamento_item is null 
							  
							   )

    and
	year(pv.dt_pedido_venda)=@cd_ano

  group by
    pv.cd_cliente

  --Pedidos

  select
     pv.cd_cliente,
     COUNT(distinct pv.cd_pedido_venda)        as qt_pedido_venda,
  	 SUM( isnull(pv.vl_total_pedido_ipi,0))    as vl_total
  into #Carteira
  from
    Pedido_Venda pv
  where
    pv.cd_cliente = @cd_cliente
	and
    pv.cd_pedido_venda in ( select k.cd_pedido_venda from Pedido_Venda_Item k
	                         where
							   k.cd_pedido_venda = pv.cd_pedido_venda
							   and
							   k.dt_cancelamento_item is null 
				               and
							   ISNULL(k.qt_saldo_pedido_venda,0)>0
							   )

  group by
    pv.cd_cliente


  --totais----------------------------------------------------------

  select
    max(c.nm_fantasia_cliente + ' ('+cast(c.cd_cliente as varchar(10))+')')
	                                            as 'Cliente',
   -- SUM(co.qt_proposta)                       as 'Propostas',
	SUM( isnull(co.vl_total,0.00))            as 'Total Propostas',
	SUM( isnull(pv.vl_total,0.00))            as 'Total Pedidos',
	SUM( isnull(ca.vl_total,0.00))            as 'Carteira',
	SUM( isnull(f.vl_total,0.00))             as 'Faturamento',
	SUM( isnull(a.vl_atraso,0.00))            as 'Atraso',
	--max(d.nm_fantasia_vendedor)               as 'Vendedor',
	MAX(r.qt_ranking)                         as 'Ranking'

  from
    Cliente c
    left outer join #Consulta co     on co.cd_cliente = c.cd_cliente
	left outer join #Venda  pv       on pv.cd_cliente = c.cd_cliente
	left outer join #Carteira ca     on ca.cd_cliente = c.cd_cliente
	left outer join #Faturamento f   on f.cd_cliente  = c.cd_cliente
	left outer join #Atraso a        on a.cd_cliente  = c.cd_cliente
	left outer join #DadosCliente d  on d.cd_cliente  = c.cd_cliente
	left outer join #Ranking r       on r.cd_cliente  = c.cd_cliente
  where
    c.cd_cliente = @cd_cliente

  group by
    c.cd_cliente

  return
  --select top 100 * from consulta order by dt_consulta desc
end

--Totais------------------------------

if @cd_parametro = 100
begin
  select
    c.cd_cliente,
    year(pv.dt_pedido_venda)                  as cd_ano,
	month(pv.dt_pedido_venda)                 as cd_mes,
	count(distinct pv.cd_pedido_venda)       as qt_pedido,
	SUM( isnull(pv.vl_total_pedido_ipi,0))    as vl_total,
	max(m.nm_mes)                             as nm_mes

  from
    Cliente c
    left outer join Pedido_Venda pv on pv.cd_cliente = c.cd_cliente
	left outer join Mes m           on m.cd_mes      = month(pv.dt_pedido_venda)
  where
    c.cd_cliente = @cd_cliente
	and
	pv.cd_pedido_venda in ( select
	                      i.cd_pedido_venda from Pedido_Venda_Item i
	                    where 
						  i.cd_pedido_venda = pv.cd_pedido_venda
						  and
	                      i.dt_cancelamento_item is null
						  						  
						  )
    and
	pv.dt_pedido_venda between @dt_inicial and @dt_final

  group by
    c.cd_cliente,
	year(pv.dt_pedido_venda),
	month(pv.dt_pedido_venda)

  return
  
end



go

--update
--  EGISADMIN.dbo.menu
--  set
    
--ic_json_parametro = 'S' ,
--ic_filtro_obrigatorio = 'S'
--where
--  cd_menu = 8134


---------------------
--> Gerar o MetaDados
---------------------


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_historico_cliente
------------------------------------------------------------------------------
--go
--select * from tipo_validacao
--use egissql_rubio
--go

----Cliente
----exec pr_egis_historico_cliente '[{"cd_parametro": 1,"cd_cliente": 573, "cd_usuario": 1,"dt_inicial"  : "06/01/2025","dt_final"    : "06/30/2025"}]'
----go
----use egissql_247
--go
----Cliente
--exec pr_egis_historico_cliente '[{"cd_parametro": 99,"cd_cliente": 573, "cd_usuario": 1,"dt_inicial"  : "01/01/2025","dt_final"    : "12/31/2025"}]'
--go

----Cliente
----exec pr_egis_historico_cliente '[{"cd_parametro": 100,"cd_cliente": 573, "cd_usuario": 1,"dt_inicial"  : "01/01/2025","dt_final"    : "06/30/2025"}]'
----go

--go

--select top 100 * from pedido_venda order by dt_pedido_venda desc
