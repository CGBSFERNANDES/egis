IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_processo_gnre' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_processo_gnre

GO

-------------------------------------------------------------------------------
--sp_helptext pr_processo_gnre
-------------------------------------------------------------------------------
--pr_processo_gnre
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
--Data             : 01.01.2024
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_processo_gnre
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

declare @cd_parametro    int = 0
declare @cd_usuario      int = 0
declare @dt_inicial      datetime
declare @dt_final        datetime
declare @cd_vendedor     int = 0
declare @cd_cliente      int = 0
declare @cd_veiculo      int = 0
declare @cd_motorista    int = 0
declare @cd_entregador   int = 0
declare @cd_pedido_venda int = 0
declare @ds_observacao   nvarchar(max) = ''
declare @cd_ano          int = 0
declare @cd_mes          int = 0
declare @cd_empresa      int = 0
declare @cd_estado       int = 0
declare @cd_empresa_fat  int = 0

----------------------------------------------------------------------------------------------------------    
set @cd_empresa = dbo.fn_empresa()
----------------------------------------------------------------------------------------------------------
select @cd_parametro	        = valor from #json  with(nolock) where campo = 'cd_parametro' 
select @cd_usuario   		    = valor from #json  with(nolock) where campo = 'cd_usuario'
select @dt_inicial   		    = valor from #json  with(nolock) where campo = 'dt_inicial'
select @dt_final   		        = valor from #json  with(nolock) where campo = 'dt_final'


set @cd_ano = year(getdate())
set @cd_mes = month(getdate())

  
  --Início do Período

  if @dt_inicial is null or @dt_inicial = '' or isnull(@dt_inicial,'') = ''
    set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)  

	--Final do Periodo
  if @dt_final is null or @dt_final = '' or isnull(@dt_final,'') = ''
	set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano) 

----------------------------------------------------------------------------------------------------------    
--Dados da notas fiscais
----------------------------------------------------------------------------------------------------------    

set @cd_estado = 15

if @cd_parametro = 1
begin

  select
    ns.cd_nota_saida,
	ns.dt_nota_saida,
	ns.cd_identificacao_nota_saida,
	ns.nm_fantasia_nota_saida,
	ns.nm_razao_social_cliente,
	ns.cd_cnpj_nota_saida,
	cd_inscest_nota_saida,
	substring(ns.cd_chave_acesso,4,44)           as cd_chave_acesso,
	c.cd_estado,
	isnull(ns.vl_icms_subst,0)                   as vl_icms_subst,
	ns.cd_serie_nota,
	snf.sg_serie_nota_fiscal,
	ns.nm_endereco_nota_saida,
	ns.cd_numero_end_nota_saida,
	ns.cd_cep_nota_saida,	
	ns.nm_bairro_nota_saida,
	ns.nm_cidade_nota_saida,
	ns.sg_estado_nota_saida,
	'100099'                   as receita,
	month(ns.dt_nota_saida)    as cd_mes_referencia,
	year(ns.dt_nota_saida)     as cd_ano_referencia,
	cast('' as varchar(15))    as cd_convenio,
	ns.dt_nota_saida           as dt_vencimento,

	--Dados do Emitente-------------------------------------------
	ef.cd_cnpj_empresa,
	ef.nm_empresa,
	ef.cd_ie_empresa,
	ef.nm_endereco,
	ef.cd_numero,
	ef.nm_bairro,
	est.sg_estado  as sg_estado_empresa,
	cid.nm_cidade  as nm_cidade_empresa,
	ef.cd_cep      as cd_cep_empresa,
	ef.cd_telefone as cd_telefone_empresa
	--select * from nota_saida_empresa
	--use egissql_342

  from
    nota_saida ns
	left outer join Nota_Saida_Empresa nse      on nse.cd_nota_saida        = ns.cd_nota_saida
	inner join Cliente c                   on c.cd_cliente             = ns.cd_cliente
	left outer join Serie_Nota_Fiscal snf  on snf.cd_serie_nota_fiscal = ns.cd_serie_nota  --select * from serie_nota_fiscal
	left outer join Empresa_Faturamento ef on ef.cd_empresa            = nse.cd_empresa
	left outer join Estado est             on est.cd_estado            = ef.cd_estado
	left outer join Cidade cid             on cid.cd_estado            = ef.cd_estado  and cid.cd_cidade = ef.cd_cidade
  where
    ns.dt_nota_saida between @dt_inicial and @dt_final
	and
	c.cd_estado = @cd_estado
	and
	ns.cd_tipo_destinatario = 1
	and
	ns.cd_status_nota<> 7
	and
	ISNULL(ns.vl_icms_subst,0)>0
	and
	ISNULL(snf.ic_nfe_serie_nota,'N') = 'S'

end


go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_processo_gnre
------------------------------------------------------------------------------
--exec pr_processo_gnre '[{"cd_parametro":"99","dt_inicial":"2025-05-01 00:00:00","dt_final":"2025-05-31 00:00:00"}]'
----go
--use egissql_342


--select nm_caminho_imagem from egisadmin.dbo.usuario_imagem
--exec pr_processo_gnre '[{"cd_parametro": 1,"cd_usuario": 1,"dt_inicial"  : "05/26/2025","dt_final"    : "05/31/2025"}]'
--go


--exec pr_processo_selecao_carga_entrega '[{
--    "cd_parametro": 3,	
--	"cd_usuario": 1,
--	"dt_inicial"  : "05/26/2025",
--	"dt_final"    : "05/30/2025"
--}]'


--exec pr_processo_selecao_carga_entrega '
--[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 10,
--        "cd_pedido_venda": 334863
--    },
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 10,
--        "cd_pedido_venda": 334490
--    },
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 10,
--        "cd_pedido_venda": 334497
--    },
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 10,
--        "cd_pedido_venda": 334502
--    }
--]'
/*
exec pr_processo_selecao_carga_entrega '[{
    "cd_parametro": 10,
	"cd_pedido_venda": 332826,
	"cd_usuario": 1,
	"dt_inicial"  : "05/19/2025",
	"dt_final"    : "05/23/2025"
}]'


--go
exec pr_processo_selecao_carga_entrega '[{"cd_parametro": 3,"cd_usuario": 1,"dt_inicial"  : "05/19/2025","dt_final"    : "05/23/2025"}]'
--use egissql_342

*/

--select * from meta_procedure_colunas 
--delete from meta_procedure_colunas where nome_coluna = 'undefined'
--delete from meta_procedure_colunas where id>322 --nome_coluna = 'undefined'


-------------------------------------------------------------------------------------------
--delete from selecao_carga_pedido   --vendedor, cd_itinerario, cd_entragador, cd_veiculo
-------------------------------------------------------------------------------------------

--select cd_vendedor, * from itinerario
--select cd_itinerario, * from vendedor

--select * from cliente_assunto
