use egisadmin
go

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_processo_registro_empresa' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_processo_registro_empresa

GO

-------------------------------------------------------------------------------
--sp_helptext pr_processo_registro_empresa
-------------------------------------------------------------------------------
--pr_processo_registro_empresa
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
create procedure pr_processo_registro_empresa
--@json nvarchar(max) = ''
@json varchar(8000) = ''

--with encryption


as

set dateformat 'MDY'

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
declare @cd_ano          int = 0
declare @cd_mes          int = 0
declare @cd_empresa      int = 0
declare @cd_cnpj_empresa varchar(18) = ''

----------------------------------------------------------------------------------------------------------    
set @cd_empresa = dbo.fn_empresa()
----------------------------------------------------------------------------------------------------------
select @cd_parametro	        = valor from #json  with(nolock) where campo = 'cd_parametro' 
select @cd_usuario   		    = valor from #json  with(nolock) where campo = 'cd_usuario'
select @dt_inicial   		    = valor from #json  with(nolock) where campo = 'dt_inicial'
select @dt_final   		        = valor from #json  with(nolock) where campo = 'dt_final'
select @cd_cnpj_empresa         = valor from #json  with(nolock) where campo = 'cd_cnpj_empresa'

----------------------------------------------------------------------------------------------------------
--select @dt_inicial = try_convert(datetime, valor, 103) from #json where campo = 'dt_inicial'
--select @dt_final   = try_convert(datetime, valor, 103) from #json where campo = 'dt_final'

--select @dt_inicial, @dt_final


set @cd_ano = year(getdate())
set @cd_mes = month(getdate())

  
  --Início do Período

  if @dt_inicial is null or @dt_inicial = '' or isnull(@dt_inicial,'') = ''
    set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)  

	--Final do Periodo
  if @dt_final is null or @dt_final = '' or isnull(@dt_final,'') = ''
	set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano) 

----------------------------------------------------------------------------------------------------------    
--Dados 
----------------------------------------------------------------------------------------------------------    


if @cd_parametro = 0
begin

  select
    @cd_empresa = isnull(e.cd_empresa,0)
  from
    EGISADMIN.dbo.Empresa e
  where
    e.cd_cgc_empresa = @cd_cnpj_empresa
	
  set @cd_empresa = isnull(@cd_empresa,0)

  if @cd_empresa = 0
  begin
    select 'Empresa não consta em nossa base de dados !' as msg
  end
  else
  begin
    select 
	  e.cd_cgc_empresa,
	  e.cd_iest_empresa,
	  e.cd_empresa,
	  e.nm_empresa,
	  e.nm_fantasia_empresa,
	  e.nm_banco_empresa,
	  e.nm_logo_empresa,
	  e.nm_caminho_logo_empresa,
	  e.cd_cep_empresa,
      e.cd_telefone_empresa,

	  --Endereço--
	  e.cd_cep,
	  e.nm_endereco_empresa,
	  e.cd_numero,
	  e.nm_complemento_endereco,
	  e.nm_bairro_empresa,
	  e.cd_segmento,
	  e.qt_usuario_contrato,
	  e.dt_fim_contrato,
	  e.cd_cliente_sistema,

	  sm.nm_segmento
	  

   from
      egisadmin.dbo.empresa e
	  left outer join Estado est           on est.cd_estado           = e.cd_estado
	  left outer join Cidade cid           on cid.cd_cidade           = e.cd_cidade
	  left outer join regime_tributario rt on rt.cd_regime_tributario = e.cd_regime_tributario
	  left outer join segmento sm          on sm.cd_segmento          = e.cd_segmento
	  
	  --select * into regime_tributario from egissql_317.dbo.regime_tributario
	  --select * from segmento

   where
     e.cd_empresa= @cd_empresa
	 and
	 isnull(e.ic_ativa_empresa,'S')='S'
	 

  end

  return

end




go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_processo_logistica_entregas
------------------------------------------------------------------------------
--go
--select * from tipo_validacao



------------------------------------------------------------------------------
exec pr_processo_registro_empresa '[{"cd_parametro": 0,"cd_cnpj_empresa": "10904110000131","cd_usuario": 1,"dt_inicial"  : "06/01/2025","dt_final"    : "06/30/2025"}]'
------------------------------------------------------------------------------

go

--delete from agenda_entrega
--delete from agenda_entrega_composicao
--select * from pedido_entrega
