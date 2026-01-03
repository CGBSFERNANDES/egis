IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_processo_modulos'
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_processo_modulos

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_processo_modulos
-------------------------------------------------------------------------------
--pr_egis_processo_dashboard_modulos
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
create procedure pr_egis_processo_modulos
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

declare @cd_modulo          int = 0
declare @cd_parametro       int = 0
declare @cd_usuario         int = 0
declare @dt_inicial         datetime = null
declare @dt_final           datetime = null
declare @cd_empresa         int = 0
declare @cd_ano             int = 0
declare @cd_mes             int = 0
declare @cd_menu            int = 0
declare @cd_documento_form  int = 0
declare @cd_processo        int = 0

----------------------------------------------------------------------------------------------------------    
set @cd_empresa = dbo.fn_empresa()
----------------------------------------------------------------------------------------------------------
select @cd_modulo 	            = valor from #json  with(nolock) where campo = 'cd_modulo' 
select @cd_parametro	        = valor from #json  with(nolock) where campo = 'cd_parametro' 
select @cd_usuario   		    = valor from #json  with(nolock) where campo = 'cd_usuario'
select @dt_inicial   		    = valor from #json  with(nolock) where campo = 'dt_inicial'
select @dt_final   		        = valor from #json  with(nolock) where campo = 'dt_final'
select @cd_menu   		        = valor from #json  with(nolock) where campo = 'cd_menu'
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
 declare @sJsonProcesso nvarchar(max) = ''
 set @sJsonProcesso = ''
    --Json

----------------------------------------------------------------------------------------------------------
--Módulos--
----------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------
--Gestão de Caixa--
----------------------------------------------------------------------------------------------------------------------


if ( @cd_modulo = 252 or @cd_modulo = 109 ) and @cd_parametro = 2010
begin

 set @cd_parametro = 2010

 set @sJsonProcesso =
    '[{"cd_empresa":"'+cast(@cd_empresa as varchar(6))+'", "cd_modulo":"'+cast(@cd_modulo as varchar(6))+'", "cd_menu":"0", "cd_processo":"'+cast(@cd_processo as varchar(6))+'", '+
    ' "cd_item_processo":"1", "cd_documento":"'+cast(@cd_documento_form as varchar)+'", "cd_item_documento":"0",
	"dt_inicial":"'+format(@dt_inicial,'MM/dd/yyyy') +'",
	"dt_final":"'+format(@dt_final,'MM/dd/yyyy')+'",
	"cd_parametro":"'+cast(isnull(@cd_parametro,0) as varchar)+'", "cd_usuario":"'+cast(@cd_usuario as varchar(6))+'"}]'
     --select @sJsonProcesso
  exec pr_dashboard_modulo_gestao_caixa @sJsonProcesso
  --'[{"cd_modulo":232, "cd_parametro": 500, "cd_vendedor": 0, "cd_usuario":113, "dt_inicial": "10/01/2025", "dt_final": "10/31/2025"}]'

  return

end

if ( @cd_modulo = 252 or @cd_modulo = 109 ) and @cd_parametro = 2000
begin

 set @cd_parametro = 2000

 set @sJsonProcesso =
    '[{"cd_empresa":"'+cast(@cd_empresa as varchar(6))+'", "cd_modulo":"'+cast(@cd_modulo as varchar(6))+'", "cd_menu":"0", "cd_processo":"'+cast(@cd_processo as varchar(6))+'", '+
    ' "cd_item_processo":"1", "cd_documento":"'+cast(@cd_documento_form as varchar)+'", "cd_item_documento":"0",
	"dt_inicial":"'+format(@dt_inicial,'MM/dd/yyyy') +'",
	"dt_final":"'+format(@dt_final,'MM/dd/yyyy')+'",
	"cd_parametro":"'+cast(isnull(@cd_parametro,0) as varchar)+'", "cd_usuario":"'+cast(@cd_usuario as varchar(6))+'"}]'
     --select @sJsonProcesso
  exec pr_dashboard_modulo_gestao_caixa @sJsonProcesso
  --'[{"cd_modulo":232, "cd_parametro": 500, "cd_vendedor": 0, "cd_usuario":113, "dt_inicial": "10/01/2025", "dt_final": "10/31/2025"}]'

  return

end

if ( @cd_modulo = 252 or @cd_modulo = 109 ) and @cd_parametro = 1010
begin

 set @cd_parametro = 1010

 set @sJsonProcesso =
    '[{"cd_empresa":"'+cast(@cd_empresa as varchar(6))+'", "cd_modulo":"'+cast(@cd_modulo as varchar(6))+'", "cd_menu":"0", "cd_processo":"'+cast(@cd_processo as varchar(6))+'", '+
    ' "cd_item_processo":"1", "cd_documento":"'+cast(@cd_documento_form as varchar)+'", "cd_item_documento":"0",
	"dt_inicial":"'+format(@dt_inicial,'MM/dd/yyyy') +'",
	"dt_final":"'+format(@dt_final,'MM/dd/yyyy')+'",
	"cd_parametro":"'+cast(isnull(@cd_parametro,0) as varchar)+'", "cd_usuario":"'+cast(@cd_usuario as varchar(6))+'"}]'
     --select @sJsonProcesso
  exec pr_dashboard_modulo_gestao_caixa @sJsonProcesso
  --'[{"cd_modulo":232, "cd_parametro": 500, "cd_vendedor": 0, "cd_usuario":113, "dt_inicial": "10/01/2025", "dt_final": "10/31/2025"}]'

  return

end

----------------------------------------------------------------------------------------------------------------------
--select @cd_modulo, @cd_parametro


if ( @cd_modulo = 252 or @cd_modulo = 109 ) and @cd_parametro = 1000
begin

 set @cd_parametro = 1000

 set @sJsonProcesso =
    '[{"cd_empresa":"'+cast(@cd_empresa as varchar(6))+'", "cd_modulo":"'+cast(@cd_modulo as varchar(6))+'", "cd_menu":"0", "cd_processo":"'+cast(@cd_processo as varchar(6))+'", '+
    ' "cd_item_processo":"1", "cd_documento":"'+cast(@cd_documento_form as varchar)+'", "cd_item_documento":"0",
	"dt_inicial":"'+format(@dt_inicial,'MM/dd/yyyy') +'",
	"dt_final":"'+format(@dt_final,'MM/dd/yyyy')+'",
	"cd_parametro":"'+cast(isnull(@cd_parametro,0) as varchar)+'", "cd_usuario":"'+cast(@cd_usuario as varchar(6))+'"}]'
  --select @sJsonProcesso
  exec pr_dashboard_modulo_gestao_caixa @sJsonProcesso
  --'[{"cd_modulo":232, "cd_parametro": 500, "cd_vendedor": 0, "cd_usuario":113, "dt_inicial": "10/01/2025", "dt_final": "10/31/2025"}]'

  return

end

----------------------------------------------------------------------------------------------------------------------

if ( @cd_modulo = 85 or @cd_modulo = 232 ) and @cd_parametro = 1
begin

 set @cd_parametro = 500

 set @sJsonProcesso =
    '[{"cd_empresa":"'+cast(@cd_empresa as varchar(6))+'", "cd_modulo":"'+cast(@cd_modulo as varchar(6))+'", "cd_menu":"0", "cd_processo":"'+cast(@cd_processo as varchar(6))+'", '+
    ' "cd_item_processo":"1", "cd_documento":"'+cast(@cd_documento_form as varchar)+'", "cd_item_documento":"0",
	"dt_inicial":"'+format(@dt_inicial,'MM/dd/yyyy') +'",
	"dt_final":"'+format(@dt_final,'MM/dd/yyyy')+'",
	"cd_parametro":"'+cast(isnull(@cd_parametro,0) as varchar)+'", "cd_usuario":"'+cast(@cd_usuario as varchar(6))+'"}]'
     --select @sJsonProcesso
  exec pr_dashboard_modulo_assistencia_tecnica @sJsonProcesso
  --'[{"cd_modulo":232, "cd_parametro": 500, "cd_vendedor": 0, "cd_usuario":113, "dt_inicial": "10/01/2025", "dt_final": "10/31/2025"}]'

  return

end

--Contas a Pagar--

--Aberto por Fornecedor---

if @cd_modulo = 3 and @cd_parametro = 1
begin
  --Documentos em Aberto por Fornecedor-------------------------------------------------------------------
  --select * from documento_pagar
  select
    identity(int,1,1)                as qt_posicao,
    d.cd_fornecedor,
    max(f.nm_fantasia_fornecedor)    as nm_fantasia,
	max(f.nm_razao_social)           as nm_razao_social,
	count(d.cd_documento_pagar)      as qt_documento,
	sum(d.vl_saldo_documento_pagar)  as vl_saldo_documento_pagar,
	min(d.dt_vencimento_documento)   as dt_menor_vencimento,
	max(d.dt_vencimento_documento)   as dt_vencimento
     
    into
	  #AbertoFornecedor

    from
      Documento_Pagar d
	  inner join fornecedor f on f.cd_fornecedor = d.cd_fornecedor

	where
        ISNULL(d.vl_saldo_documento_pagar,0)>0
		and
		d.dt_cancelamento_documento is null
		and
		isnull(d.cd_fornecedor,0)>0
		and
		d.cd_tipo_destinatario = 2

    group by
	   d.cd_fornecedor

    order by
	   6 desc

    select * from #AbertoFornecedor
	order by
	  qt_posicao

  return

end

--Plano Financeiro---

if @cd_modulo = 3 and @cd_parametro = 2
begin
  --Documentos em Aberto por Fornecedor-------------------------------------------------------------------
  --select * from documento_pagar
  select
    identity(int,1,1)                   as qt_posicao,
    
	d.cd_plano_financeiro,           --select * from plano_financeiro

    max(pf.cd_mascara_plano_financeiro)  as cd_mascara_plano_financeiro,
	max(pf.nm_conta_plano_financeiro)    as nm_conta_plano_financeiro,
	count(d.cd_documento_pagar)          as qt_documento,
	sum(d.vl_documento_pagar)            as vl_saldo_documento_pagar,

	min(case when isnull(d.vl_saldo_documento_pagar,0)>0 then d.dt_vencimento_documento end)       as dt_menor_vencimento,
	max(case when isnull(d.vl_saldo_documento_pagar,0)>0 then d.dt_vencimento_documento end)       as dt_vencimento
     
    into
	  #DocumentoPlanoFinanceiro

    from
      Documento_Pagar d
	  inner join Plano_Financeiro pf on pf.cd_plano_financeiro = d.cd_plano_financeiro

	where
        ISNULL(d.vl_documento_pagar,0)>0
		and
		d.dt_cancelamento_documento is null
		and
		d.dt_vencimento_documento between @dt_inicial and @dt_final

    group by
	   d.cd_plano_financeiro

    order by
	   6 desc

    select * from #DocumentoPlanoFinanceiro
	order by
	  qt_posicao

  return

end

--Centro de Custo

if @cd_modulo = 3 and @cd_parametro = 3
begin

  select
    identity(int,1,1)                   as qt_posicao,
    
	d.cd_centro_custo,          --select * from centro_custo

    max(cc.cd_mascara_centro_custo)      as cd_mascara_centro_custo,
	max(cc.nm_centro_custo)              as nm_centro_custo,
	count(d.cd_documento_pagar)          as qt_documento,
	sum(d.vl_documento_pagar)            as vl_saldo_documento_pagar,

	min(case when isnull(d.vl_saldo_documento_pagar,0)>0 then d.dt_vencimento_documento end)       as dt_menor_vencimento,
	max(case when isnull(d.vl_saldo_documento_pagar,0)>0 then d.dt_vencimento_documento end)       as dt_vencimento
     
    into
	  #DocumentoCentroCusto

    from
      Documento_Pagar d
	  left outer join Plano_Financeiro pf on pf.cd_plano_financeiro = d.cd_plano_financeiro
	  left outer join Centro_Custo cc     on cc.cd_centro_custo     = case when isnull(d.cd_centro_custo,0)=0 then pf.cd_centro_custo else d.cd_centro_custo end

	where
        ISNULL(d.vl_documento_pagar,0)>0
		and
		d.dt_cancelamento_documento is null
		and
		d.dt_vencimento_documento between @dt_inicial and @dt_final
    group by
	   d.cd_centro_custo

    order by
	   6 desc

    select * from #DocumentoCentroCusto
	order by
	  qt_posicao

  return

end

--Documentos em Aberto a Pagar em Atraso----------------------------------------------------------------------------

if @cd_modulo = 3 and @cd_parametro = 4
begin

  exec pr_egis_documentos_pagar_atraso @json
  
  return

end

--Contas a Receber--

--Clientes em Atraso--

if @cd_modulo = 10 and @cd_parametro = 1
begin
   exec pr_consulta_cliente_atraso null
   return
end

--Faturamento---

--Diário de Notas/Notas por Vendedor--

if @cd_modulo = 13 and @cd_parametro = 1
begin
   exec pr_consulta_nota_por_vendedor 0, @dt_inicial, @dt_final, 0
   return
end

--Importação---

if @cd_modulo = 57 and @cd_parametro = 1
begin
   --select @json
   exec pr_egis_importacao_mensal_anual @json
   return
end


--Logística---

--Faturamento por Caminhão

if @cd_modulo = 101 and @cd_parametro = 1
begin
   exec pr_egis_faturamento_veiculo @json
   return
end

--Faturamento por Cliente-----------------------------------------------

if @cd_modulo = 101 and @cd_parametro = 2
begin
   exec pr_egis_faturamento_cliente_logistica @json
   return
end

--Vendas por Produto/Serviço--------------------------------------------

if @cd_modulo = 101 and @cd_parametro = 3
begin
   exec pr_egis_vendas_produto_servico_entrega @json
   return
end

--Manutenção do Veículo--------------------------------------------

if @cd_modulo = 108 and @cd_parametro = 1
begin
   exec pr_egis_frota_veiculo_manutencao @json
   return
end

if @cd_modulo = 108 and @cd_parametro = 2
begin
   exec pr_egis_frota_veiculo_servico @json
   return
end


-----------------------------------------------------------------------

--Propostas - Vendas Interna

--Propostas por Cliente--

if @cd_modulo = 41 and @cd_parametro = 1
begin
   exec pr_egis_vendas_cliente @json
   return
end

--Propostas por Produto--

if @cd_modulo = 41 and @cd_parametro = 2
begin
   exec pr_egis_proposta_produto @json
   return
end

--Vendas Internas Net


--Vendas Semanal--

if @cd_modulo = 239 and @cd_parametro = 1
begin
   exec pr_egis_vendas_semanal @json
   return
end

if @cd_modulo = 239 and @cd_parametro = 2
begin
   exec pr_egis_vendas_empresa_faturamento @json
   return
end

if @cd_modulo = 239 and @cd_parametro = 3
begin
   exec pr_egis_vendas_tipo_pedido @json
   return
end

if @cd_modulo = 239 and @cd_parametro = 4
begin
   exec pr_egis_vendas_vendedor @json
   return
end

--Vendas por Estado

if @cd_modulo = 239 and @cd_parametro = 5
begin
   exec pr_egis_vendas_estado @json
   return
end

if @cd_modulo = 239 and @cd_parametro = 6
begin
   exec pr_egis_vendas_cidade @json
   return
end

if @cd_modulo = 239 and @cd_parametro = 7
begin
   exec pr_egis_vendas_cliente @json
   return
end

--Vendas Mensal--

if @cd_modulo = 239 and @cd_parametro = 8
begin
   exec pr_egis_vendas_mensal_vendedor @json
   return
end

--Mapa de Carteira de Pedidos--

if @cd_modulo = 390 and @cd_parametro = 1 
begin
   exec pr_mapa_carteira_cliente_aberto @dt_inicial, @dt_final, 0, 'S'
   return
end

----------------------------------------
go

------------------------------------------------------------------------------
--pr_egis_processo_modulos
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--Aberto por Fornecedor--
--exec pr_egis_processo_modulos '[{"cd_modulo":3, "cd_parametro": 1,"cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
--go
--exec pr_egis_processo_modulos '[{"cd_modulo":57, "cd_parametro": 1,"cd_usuario":113, "dt_inicial": "01/01/2000", "dt_final": "06/30/2025"}]'
------------------------------------------------------------------------------
--exec pr_egis_processo_modulos '[{"cd_modulo":3, "cd_parametro": 2,"cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
--go
--exec pr_egis_processo_modulos '[{"cd_modulo":3, "cd_parametro": 3,"cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
--go

--Clientes em Atraso--
--exec pr_egis_processo_modulos '[{"cd_modulo":10, "cd_parametro": 1,"cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
go

--faturamento--
--exec pr_egis_processo_modulos '[{"cd_modulo":13, "cd_parametro": 1,  "cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
go

--Logística--
--exec pr_egis_processo_modulos '[{"cd_modulo":101, "cd_parametro": 1, "cd_veiculo": 0, "cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
--go

--exec pr_egis_processo_modulos '[{"cd_modulo":101, "cd_parametro": 2, "cd_cliente": 0, "cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
--go

--exec pr_egis_processo_modulos '[{"cd_modulo":3, "cd_parametro": 4, "cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'

--exec pr_egis_processo_modulos '[{"cd_modulo":239, "cd_parametro": 8, "cd_usuario":113, "dt_inicial": "01/01/2025", "dt_final": "06/30/2025"}]'

--exec pr_egis_processo_modulos '[{"cd_modulo":108, "cd_parametro": 2, "cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
go
use egissql_282

--use egissql_341
--go
--exec pr_egis_processo_modulos '[{"cd_modulo":232, "cd_parametro": 1, "cd_usuario":113, "dt_inicial": "10/01/2025", "dt_final": "10/30/2025"}]'

--use egissql_rubio
--go

--select top 100 * from egisadmin.dbo.menu order by cd_menu desc

--update
--  egisadmin.dbo.menu
--  set
--    cd_dashboard = 239
--where
--  cd_menu = 8165

--select * from egisadmin.dbo.meta_procedure_colunas where cd_menu_id = 8678
--use egissql_rubio
--go

--update meta_procedure_colunas set titulo_exibicao = ltrim(rtrim(titulo_exibicao))

--exec pr_egis_processo_modulos '[
--    {
--        "cd_parametro": 2010,
--        "cd_modulo": "252",
--        "cd_form": "0",
--        "cd_menu": 8478,
--        "nm_tabela_origem": "",
--        "cd_usuario": 4915,
--        "ic_json_parametro": "S"
--    }
--]'

