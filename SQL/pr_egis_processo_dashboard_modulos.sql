IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_processo_dashboard_modulos'
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_processo_dashboard_modulos

GO


-------------------------------------------------------------------------------
--sp_helptext pr_egis_processo_dashboard_modulos
-------------------------------------------------------------------------------
--pr_egis_processo_dashboard_modulos
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2022
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
create procedure pr_egis_processo_dashboard_modulos
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
set @dt_inicial   = isnull(@dt_inicial, @dt_hoje)
set @dt_final     = isnull(@dt_final,   @dt_hoje)

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

--Busca todos os Menus com Grid's Dinâmicas

----------------------------------------------------------------------------------------------------------

if @cd_parametro = 99 
begin

  select 
    md.cd_modulo,
	md.nm_modulo,
    dm.*,
	m.nm_menu
  from
    egisadmin.dbo.DashBoard_Menu dm
	inner join egisadmin.dbo.Dashboard d on d.cd_dashboard = dm.cd_dashboard
	inner join egisadmin.dbo.menu m      on m.cd_menu      = dm.cd_menu
	inner join egisadmin.dbo.modulo md   on md.cd_modulo   = d.cd_modulo_parametro
  where
    d.cd_modulo_parametro = @cd_modulo

  order by
    dm.qt_ordem_menu

    

  return


end

----------------------------------------------------------------------------------------------------------

--select @cd_modulo


--Cadastramento Geral Net ---------

if @cd_modulo = 238 or @cd_modulo = 54
begin
 
  exec pr_dashboard_modulo_servicos @json --@cd_modulo, 100,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Cadastramento Geral Net ---------

if @cd_modulo = 243 or @cd_modulo = 54
begin
 
  exec pr_dashboard_modulo_cadastramento_geral @json --@cd_modulo, 100,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Formação de Preço Net ---------

if @cd_modulo = 73
begin
 
  exec pr_dashboard_modulo_formacao_preco_venda @json --@cd_modulo, 100,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Recebimento ---------

if @cd_modulo = 44
begin
 
  exec pr_dashboard_modulo_recebimento @json --@cd_modulo, 100,@dt_inicial, @dt_final, @cd_usuario
  return

end


--Carteira de Pedidos-----

if @cd_modulo = 12
begin
 
  exec pr_dashboard_modulo_carteira_pedidos @json --@cd_modulo, 100,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Painel de Gestão de Logística Net

if @cd_modulo = 358
begin
 
  exec pr_dashboard_modulo_logistica_abastecimento @json --@cd_modulo, 100,@dt_inicial, @dt_final
  return

end

--Vendas Internas -> Propostas

if @cd_modulo = 41
begin
 
  exec pr_dashboard_modulo_vendas_interna @json --@cd_modulo, 100,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Assistência Técnica

if @cd_modulo = 85
begin
 
  exec pr_dashboard_modulo_assistencia_tecnica @json --@cd_modulo, 100,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Ativo Fixo

if @cd_modulo = 28
begin
 
  exec pr_dashboard_modulo_ativo @json --@cd_modulo, 100,@dt_inicial, @dt_final, @cd_usuario
  return

end


--Contas a Receber-----------------------------------------------------------------------------

if @cd_modulo = 10 
begin
  
  exec pr_dashboard_modulo_contas_receber @json --, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return


end

if @cd_modulo = 235
begin
  
  exec pr_dashboard_modulo_contas_receber @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return


end

--Assistência Técnica Net

if @cd_modulo = 232
begin
  
  exec pr_dashboard_modulo_assistencia_tecnica @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return


end

--Faturamento--

if ( @cd_modulo = 13 or @cd_modulo = 241 )
begin
 
    exec pr_dashboard_modulo_faturamento @json  --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
    return

end

--Contas a pagar-----------------------------------------------------------------------------

if @cd_modulo = 3 or @cd_modulo = 234
begin
   --select @cd_modulo   
    exec pr_dashboard_modulo_contas_pagar @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
    return
end

if @cd_modulo = 17
begin

  
    exec pr_dashboard_modulo_compras @json--@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
    return

end

--Financeiro-----------------------------------------------------------------------------

if @cd_modulo = 54
begin

  exec pr_dashboard_modulo_cadastro_geral @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Financeiro-----------------------------------------------------------------------------

if @cd_modulo = 56
begin

  exec pr_dashboard_modulo_financeiro @json--@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Logística-----------------------------------------------------------------------------

if @cd_modulo = 101
begin

  exec pr_dashboard_modulo_logistica @cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Gestão de Frotas-----------------------------------------------------------------------------

if @cd_modulo = 108
begin

  exec pr_dashboard_modulo_gestao_frota @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Gestão de Caixa-----------------------------------------------------------------------------

if @cd_modulo = 178
begin

  exec pr_dashboard_modulo_gestao_frota @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Vendas Interna-----------------------------------------------------------------------------

if @cd_modulo = 239
begin

  --select @dt_inicial, @dt_final
  --exec pr_dashboard_modulo_vendas_interna_net @cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  exec pr_dashboard_modulo_vendas_interna_net @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end

-- Comissões

if @cd_modulo = 39
begin

  --select @dt_inicial, @dt_final
  --exec pr_dashboard_modulo_vendas_interna_net @cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  exec pr_dashboard_modulo_comissoes @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Clientes

if @cd_modulo = 220
begin

  --select @dt_inicial, @dt_final
  --exec pr_dashboard_modulo_vendas_interna_net @cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  exec pr_dashboard_modulo_clientes @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Entregas---------------

if @cd_modulo = 390
begin

  --select @dt_inicial, @dt_final
  --exec pr_dashboard_modulo_vendas_interna_net @cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  exec pr_dashboard_modulo_painel_entregas @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Importação---------------

if @cd_modulo = 57
begin

  --select @dt_inicial, @dt_final
  --exec pr_dashboard_modulo_vendas_interna_net @cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  exec pr_dashboard_modulo_importacao @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Folha de Pagamento----

if @cd_modulo = 71 or @cd_modulo = 271
begin

  --select @dt_inicial, @dt_final
  --exec pr_dashboard_modulo_vendas_interna_net @cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  exec pr_dashboard_modulo_folha_pagamento @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end

--Gestão de Caixa---------------

if @cd_modulo in (109, 252 )
begin

  --select @dt_inicial, @dt_final
  --exec pr_dashboard_modulo_vendas_interna_net @cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  exec pr_dashboard_modulo_gestao_caixa @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end


--Painel de Operações---------------

if @cd_modulo in ( 394 )
begin

  --Regra de Negócios--
  exec pr_dashboard_modulo_painel_operacoes @json --@cd_modulo, @cd_parametro,@dt_inicial, @dt_final, @cd_usuario
  return

end



go

------------------------------------------------------------------------------
--pr_egis_processo_dashboard_modulos
------------------------------------------------------------------------------


--exec pr_dashboard_modulo_painel_operacoes '[{"cd_modulo":252, "cd_parametro": 100, "cd_vendedor": 0, "cd_usuario":113, "dt_inicial": "10/01/2025", "dt_final": "10/31/2025"}]'


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--Menus--
--exec pr_egis_processo_dashboard_modulos '[{"cd_modulo":239, "cd_parametro": 99,"cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
--exec pr_egis_processo_dashboard_modulos '[{"cd_modulo":252, "cd_parametro": 99,"cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'

go



--pagar
--exec pr_egis_processo_dashboard_modulos '[{"cd_modulo":235, "cd_parametro": 100, "cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'

--Vendas Internet
--exec pr_egis_processo_dashboard_modulos '[{"cd_modulo":41, "cd_parametro": 100, "cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
--go
--exec pr_egis_processo_dashboard_modulos '[{"cd_modulo":239, "cd_parametro": 100, "cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
--go

--go
--exec pr_egis_processo_dashboard_modulos '[{"cd_modulo":10, "cd_parametro": 100, "cd_vendedor": 0, "cd_usuario":113, "dt_inicial": "07/01/2025", "dt_final": "07/31/2025"}]'
--go

--exec pr_egis_processo_dashboard_modulos '[{"cd_modulo":235, "cd_parametro": 100, "cd_vendedor": 0, "cd_usuario":113, "dt_inicial": "07/01/2025", "dt_final": "07/31/2025"}]'
--go

--financeiro
--exec pr_egis_processo_dashboard_modulos '[{"cd_modulo":236, "cd_parametro": 100, "cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'

--
--exec pr_egis_processo_dashboard_modulos '[{"cd_modulo":3, "cd_parametro": 200, "cd_usuario":113, "dt_inicial": "06/01/2025", "dt_final": "06/30/2025"}]'
--use egissql_247

------------------------------------------------------------------------------
--pagar
--exec pr_egis_processo_dashboard_modulos 3, 100,113, '04/01/2025','04/30/2025'
------------------------------------------------------------------------------

--Faturamento
--exec pr_egis_processo_dashboard_modulos 13, 100,113, '04/01/2025','04/30/2025'
------------------------------------------------------------------------------

--financeiro
--exec pr_egis_processo_dashboard_modulos 236, 100,113, '06/01/2025','06/30/2025'
------------------------------------------------------------------------------

--financeiro
--exec pr_egis_processo_dashboard_modulos 236, 100,113, '06/01/2025','06/30/2025'
------------------------------------------------------------------------------

--financeiro
--exec pr_egis_processo_dashboard_modulos 236, 100,113, '06/01/2025','06/30/2025'
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--exec pr_egis_processo_dashboard_modulos 12, 100,113, '04/01/2025','04/30/2025'
------------------------------------------------------------------------------

--exec pr_egis_processo_dashboard_modulos 235, 0,113, '01/01/2022','12/31/2022'
------------------------------------------------------------------------------
--exec pr_egis_processo_dashboard_modulos 236, 0,113, '01/01/2022','12/31/2022'
------------------------------------------------------------------------------
--exec pr_egis_processo_dashboard_modulos 28, 100,113,'04/01/2025','04/30/2025'
----------------------------------------------------------------------------
--exec pr_egis_processo_dashboard_modulos '[{
--    "cd_modulo": 252,
--    "cd_parametro": 100,
--    "cd_usuario": 4595,
--    "dt_inicial": "12-01-2025",
--    "dt_final": "12-30-2025",
--    "ic_json_parametro": "S"
--}]'
--------------------------------------------------------------------------------
--exec pr_egis_processo_dashboard_modulos 108, 100,113,'06/01/2025','06/30/2025'
------------------------------------------------------------------------------

--use egissql_329

