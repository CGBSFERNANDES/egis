IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_documento_pagos_hoje' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_documento_pagos_hoje

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_documento_pagos_hoje
-------------------------------------------------------------------------------
--pr_egis_relatorio_documento_pagos_hoje
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Joao Pedro Marcal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relat�rio Padr�o Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025	
--Altera��o        : 
-- use egissql_358
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_documento_pagos_hoje
@cd_relatorio int   = 0,
@cd_parametro int   = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')
declare @data_grafico_bar       nvarchar(max)
declare @cd_empresa             int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
--declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
--declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @cd_vendedor            int = 0 
declare @cd_grupo_relatorio     int = 0
--declare @cd_relatorio           int = 0

--Dados do Relat�rio---------------------------------------------------------------------------------

     declare
            @titulo                     varchar(200),
		    @logo                       varchar(400),			
			@nm_cor_empresa             varchar(20),
			@nm_endereco_empresa  	    varchar(200) = '',
			@cd_telefone_empresa    	varchar(200) = '',
			@nm_email_internet		    varchar(200) = '',
			@nm_cidade				    varchar(200) = '',
			@sg_estado				    varchar(10)	 = '',
			@nm_fantasia_empresa	    varchar(200) = '',
			@numero					    int = 0,
			@dt_pedido				    varchar(60) = '',
			@cd_cep_empresa			    varchar(20) = '',
			@cd_cliente				    int = 0,
	--		@nm_fantasia_cliente  	    varchar(200) = '',
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_razao_social_cliente	varchar(200) = '',
			@nm_cidade_cliente			varchar(200) = '',
			@sg_estado_cliente			varchar(5)	= '',
			@cd_numero_endereco			varchar(20) = '',
			@nm_condicao_pagamento		varchar(100) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40)   = '',
			@footerTitle				varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = ''



--------------------------------------------------------------------------------------------------------
       
--set @cd_parametro      = 0
set @cd_empresa        = 0
set @cd_form           = 0


------------------------------------------------------------------------------------------------------

if @json<>''
begin
  select                     
    1                                                    as id_registro,
    IDENTITY(int,1,1)                                    as id,
    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
    valores.[value]              as valor                    
                    
    into #json                    
    from                
      openjson(@json)root                    
      cross apply openjson(root.value) as valores      

-------------------------------------------------------------------------------------------------

--select * from #json

-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'

   end
end

-------------------------------------------------------------------------------------------------
declare @ic_processo char(1) = 'N'
 
 --select @cd_relatorio
 
select  
  @titulo             = nm_relatorio,  
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),  
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)  
from  
  egisadmin.dbo.Relatorio  
where  
  cd_relatorio = @cd_relatorio  
 
 
----------------------------------------------------------------------------------------------------------------------------
select  
  @dt_inicial       = dt_inicial,  
  @dt_final         = dt_final
from   
  Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
  and  
  cd_usuario   = @cd_usuario  
----------------------------------------------------------------------------------------------------------------------------

set @cd_ano           = year(@dt_hoje)    
set @cd_dia           = day(@dt_hoje)
set @cd_mes           = month(@dt_hoje)

if @dt_inicial is null  or @dt_inicial = '01/01/1900'    
begin      
      
  set @cd_ano = year(@dt_hoje)      
  set @cd_mes = month(@dt_hoje)      
      
  set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)      
  set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano)      
      
end   

-----------------------------------------------------------------------------------------
--Empresa
----------------------------------
set @cd_empresa = dbo.fn_empresa()
-----------------------------------

	--Dados da empresa-----------------------------------------------------------

	select 
		@logo = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),
		@nm_cor_empresa		   	    = isnull(e.nm_cor_empresa,'#1976D2'),
		@nm_endereco_empresa 	    = isnull(e.nm_endereco_empresa,''),
		@cd_telefone_empresa	    = isnull(e.cd_telefone_empresa,''),
		@nm_email_internet	  	    = isnull(e.nm_email_internet,''),
		@nm_cidade			    	= isnull(c.nm_cidade,''),
		@sg_estado				    = isnull(es.sg_estado,''),
		@nm_fantasia_empresa	    = isnull(e.nm_fantasia_empresa,''),
		@cd_cep_empresa			    = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),
		@cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),
		@nm_pais					= ltrim(rtrim(isnull(p.sg_pais,''))),
		@cd_cnpj_empresa			= dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),
		@cd_inscestadual_empresa	=  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),
		@nm_dominio_internet		=  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))
			   
	from egisadmin.dbo.empresa e	with(nolock)
	left outer join Estado es		with(nolock) on es.cd_estado = e.cd_estado
	left outer join Cidade c		with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado
	left outer join Pais p			with(nolock) on p.cd_pais = e.cd_pais
	where 
		cd_empresa = @cd_empresa


---------------------------------------------------------------------------------------------------------------------------------------------
--Dados do Relat�rio
---------------------------------------------------------------------------------------------------------------------------------------------

declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabe�alho da Empresa
declare @html_titulo     nvarchar(max) = '' --T�tulo
declare @html_cab_det    nvarchar(max) = '' --Cabe�alho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodap� do Detalhe
declare @html_rodape     nvarchar(max) = '' --Rodape
declare @html_geral      nvarchar(max) = '' --Geral

declare @data_hora_atual nvarchar(50)  = ''

set @html         = ''
set @html_empresa = ''
set @html_titulo  = ''
set @html_cab_det = ''
set @html_detalhe = ''
set @html_rod_det = ''
set @html_rodape  = ''
set @html_geral   = ''


set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)


----------------------------------------------------------------------------------------------------------------------


SET @html_empresa = '
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title >'+@titulo+'</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            color: #333;
			padding:20px;
        }

        h2 {
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }

        table,
        th,
        td {
            border: 1px solid #ddd;
        }

        th,
        td {
            padding: 10px;
        }

        th {
            background-color: #f2f2f2;
            color: #333;
            text-align: center;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .header {
            padding: 5px;
            text-align: center;
        }

        .section-title {
            background-color: #1976D2;
            color: white;
            padding: 5px;
            margin-bottom: 10px;
            border-radius: 5px;
            font-size: 120%;
        }

        img {
            max-width: 250px;
            margin-right: 10px;
        }

        .company-info {
            text-align: right;
            margin-bottom: 10px;
        }

        .proposal-info {
            text-align: left;
            margin-bottom: 10px;
        }

        .title {
            color: #1976D2;
        }

        .report-date-time {
            text-align: right;
            margin-bottom: 5px;
            margin-top: 50px;
        }

        p {
            margin: 5px;
            padding: 0;
        }

        .tamanho {
         
            text-align: center;
        }
    </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:30%; margin-right:20px">
			<img src="'+@logo+'" alt="Logo da Empresa">
		</div>
		<div style="width:70%; padding-left:10px">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
		    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
		</div>    
    </div>'


--Procedure de Cada Relat�rio-------------------------------------------------------------------------------------
  
declare @cd_item_relatorio  int           = 0  
declare @nm_cab_atributo    varchar(100)  = ''  
declare @nm_dados_cab_det   nvarchar(max) = ''  
declare @nm_grupo_relatorio varchar(60)   = ''  
  
select a.*, g.nm_grupo_relatorio into #RelAtributo   
from  
  egisadmin.dbo.Relatorio_Atributo a   
  inner join egisadmin.dbo.relatorio_grupo g on g.cd_grupo_relatorio = a.cd_grupo_relatorio  
where   
  a.cd_relatorio = @cd_relatorio  
  
  --and  
  --g.cd_grupo_relatorio = 4  
  
order by  
  qt_ordem_atributo  
  
------------------------------------------------------------------------------------------------------------------  
  
  
--select * from #RelAtributo  
  
--select * from egisadmin.dbo.relatorio_grupo  
  
select * into #AuxRelAtributo from #RelAtributo  
where  
  cd_grupo_relatorio = @cd_grupo_relatorio  
  
order by qt_ordem_atributo  
  
--select * from #AuxRelAtributo  
  
while exists ( select top 1 cd_item_relatorio from #AuxRelAtributo order by qt_ordem_atributo)  
begin  
  
  select top 1   
    @cd_item_relatorio  = cd_item_relatorio,  
 @nm_cab_atributo    = nm_cab_atributo,  
 @nm_grupo_relatorio = nm_grupo_relatorio  
  from  
    #AuxRelAtributo  
  order by  
    qt_ordem_atributo  
  
  
  set @nm_dados_cab_det = @nm_dados_cab_det + '<th> '+ @nm_cab_atributo+'</th>'  
  
  delete from #AuxRelAtributo  
  where  
    cd_item_relatorio = @cd_item_relatorio  
  
end  
  
--SELECT @nm_dados_cab_det  
  
drop table #AuxRelAtributo  
  
 
if isnull(@cd_parametro,0) = 2  
 begin  
  select * from #RelAtributo  
  return  
end  
------------------------------------------------------------------------------------------------------------
    set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
    declare @cd_portador               int = 0
	declare @ic_rateio                 int = 0
	declare @cd_plano_financeiro       int = 0
	declare @cd_centro_custo           int         = 0	
	----set @dt_final = '02-19-2025'
	----set @dt_inicial = '02-19-2025'
	-- select @dt_hoje
------------------------------------------------------------------------------------------------------------
 Select 
    d.cd_documento_pagar,
    d.cd_identificacao_document,
    d.dt_emissao_documento_paga,
    d.dt_vencimento_documento,
    d.dt_vencimento_original,
    d.vl_documento_pagar,
    d.vl_saldo_documento_pagar,
    d.vl_multa_documento,
    d.dt_cancelamento_documento,
    d.nm_cancelamento_documento,
    --d.cd_modulo,      
    d.cd_numero_banco_documento,
	d.nm_numero_bancario,
	d.cd_conta,
    d.nm_observacao_documento,
    'S'                         as ic_emissao_documento,
    d.ic_envio_documento,
    d.dt_envio_banco_documento,
    --d.dt_contabil_documento,
    d.dt_contabil_documento_pag,
    d.cd_portador,
    --d.cd_tipo_cobranca,
    --d.cd_fornecedor,
    case when isnull(d.cd_fornecedor,0) = 0  then
		   case when (isnull(d.cd_empresa_diversa, 0) <> 0) then isnull(d.cd_empresa_diversa,0)
			   else
				   case when (isnull(d.cd_contrato_pagar, 0) <> 0) then isnull(d.cd_contrato_pagar, 0)
					   else 
						   case when (isnull(d.cd_funcionario, 0) <> 0) then isnull(d.cd_funcionario, 0)
		   end end end 
		else
		  isnull(d.cd_fornecedor,0) end as cd_fornecedor,

    d.cd_tipo_documento,
    d.cd_pedido_compra,
	d.cd_conta_banco_pagamento,
    d.cd_nota_saida,
    d.cd_nota_fiscal_entrada,
    --d.cd_vendedor,
    d.dt_pagamento_documento,
    d.vl_pagamento_documento,
--    d.ic_tipo_lancamento,	-- 11/06/2002
    d.cd_tipo_pagamento,
    --d.cd_tipo_liquidacao,
    d.cd_plano_financeiro,
    p.sg_portador,
    d.cd_usuario,
    d.dt_usuario,
    --d.cd_tipo_destinatario,
    d.vl_juros_documento,
    d.vl_abatimento_documento,
    d.vl_desconto_documento,
  --  d.vl_reembolso_documento,
    d.dt_retorno_banco_doc,
    p.nm_portador,
  --  tl.nm_tipo_liquidacao,
--    v.nm_fantasia_vendedor,
    pf.nm_conta_plano_financeiro,
--    tc.nm_tipo_cobranca,

   --d.nm_fantasia_fornecedor,
	      case when (isnull(d.cd_empresa_diversa, 0) <> 0) then cast((select top 1 z.nm_empresa_diversa from empresa_diversa z where z.cd_empresa_diversa = d.cd_empresa_diversa) as varchar(50))  
           when (isnull(d.cd_contrato_pagar, 0) <> 0) then cast((select top 1 w.nm_contrato_pagar from contrato_pagar w where w.cd_contrato_pagar = d.cd_contrato_pagar) as varchar(50))  
           when (isnull(d.cd_funcionario, 0) <> 0) then cast((select top 1 k.nm_funcionario from funcionario k where k.cd_funcionario = d.cd_funcionario) as varchar(50))  
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then cast((select top 1 o.nm_razao_social from fornecedor o where o.nm_fantasia_fornecedor = d.nm_fantasia_fornecedor) as varchar(50))    
      end                             as nm_fantasia_fornecedor,
  
  --Nome Fantasia do Destinatário *************************************************************************************
      case when (isnull(d.cd_empresa_diversa, 0) <> 0) then cast((select top 1 z.sg_empresa_diversa from empresa_diversa z where z.cd_empresa_diversa = d.cd_empresa_diversa) as varchar(30))  
           when (isnull(d.cd_contrato_pagar, 0) <> 0) then cast((select top 1 w.nm_fantasia_fornecedor from contrato_pagar w where w.cd_contrato_pagar = d.cd_contrato_pagar) as varchar(30))  
           when (isnull(d.cd_funcionario, 0) <> 0) then cast((select top 1 k.nm_funcionario from funcionario k where k.cd_funcionario = d.cd_funcionario) as varchar(30))  
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then cast(d.nm_fantasia_fornecedor as varchar(30))  
      end                             as 'cd_favorecido',                 
      case when (isnull(d.cd_empresa_diversa, 0) <> 0) then cast((select top 1 z.nm_empresa_diversa from empresa_diversa z where z.cd_empresa_diversa = d.cd_empresa_diversa) as varchar(50))  
           when (isnull(d.cd_contrato_pagar, 0) <> 0) then cast((select top 1 w.nm_contrato_pagar from contrato_pagar w where w.cd_contrato_pagar = d.cd_contrato_pagar) as varchar(50))  
           when (isnull(d.cd_funcionario, 0) <> 0) then cast((select top 1 k.nm_funcionario from funcionario k where k.cd_funcionario = d.cd_funcionario) as varchar(50))  
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then cast((select top 1 o.nm_razao_social from fornecedor o where o.nm_fantasia_fornecedor = d.nm_fantasia_fornecedor) as varchar(50))    
      end                             as 'nm_favorecido',

      d.nm_complemento_documento,
      d.nm_ref_documento_pagar, 
	  f.cd_pix,
	  f.cd_ddd,
	  f.cd_telefone,
	  cab.cd_agencia_banco

    --Razão Social do Destinatário *************************************************************************************
    --DDD do Destinatário  **********************************************************************************************
    --Telefone do Destinatário  ****************************************************************************************

    --select * from documento_pagar
	into
	#rel_pagamento_hoje
  from

  Documento_Pagar d                            with (nolock) 
    left outer join Portador p                   with (nolock) on  d.cd_portador            = p.cd_portador 
    left outer join Plano_Financeiro pf          with (nolock)                     on pf.cd_plano_financeiro    = d.cd_plano_financeiro 
    left outer join Fornecedor f                 with (nolock)                     on f.nm_fantasia_fornecedor  = d.nm_fantasia_fornecedor
	left outer join Conta_Agencia_Banco cab      with (nolock)                     on cab.cd_conta              = d.cd_conta
--    left outer join Tipo_Cobranca tc    with (nolock)                     on tc.cd_tipo_cobranca = d.cd_tipo_cobranca

 where

    --   d.dt_vencimento_documento = case when isnull(@cd_documento,0) = 0 then d.dt_vencimento_documento else @dt_hoje end
	   --and
       d.cd_documento_pagar = @cd_documento
	 --  and
  --    (d.dt_cancelamento_documento is null) 
		--and
  --    (cast(str(d.vl_saldo_documento_pagar,25,2) as decimal(25,2)) <> 0 ) 
  order by
      d.dt_vencimento_documento desc

	  --select * from #rel_pagamento_hoje return
------------------------------------------------------------------------------------------------------------
DECLARE @cd_identificacao       nvarchar(25)
DECLARE @dt_emissao             DATETIME
DECLARE @dt_vencimen            DATETIME
DECLARE @dt_vencimen_original   DATETIME
DECLARE @vl_documento           DECIMAL(18,2)
DECLARE @vl_abatiment           DECIMAL(18,2)
DECLARE @vl_saldo_d             DECIMAL(18,2)
DECLARE @vl_multa_docum         DECIMAL(18,2)
DECLARE @vl_desconto_d          DECIMAL(18,2)

DECLARE @cd_forneced               INT
DECLARE @nm_fantasia_fornecedor    nvarchar(100)
DECLARE @nm_razao_social_forncedor nvarchar(100)
DECLARE @cd_ddd                    INT
DECLARE @cd_telefone               nvarchar(20)
DECLARE @cd_numero_banco           nvarchar(20)
DECLARE @cd_agencia                nvarchar(50)
DECLARE @cd_conta                  nvarchar(50)
DECLARE @cd_pix                    nvarchar(50)

DECLARE @cd_pedido_compra       INT
DECLARE @cd_p                   INT
DECLARE @nm_portador            nvarchar(60)
DECLARE @cd_nota_saida          INT
DECLARE @nm_numero_banco        nvarchar(50)
DECLARE @dt_cancelamento        DATETIME
DECLARE @nm_cancelamento_doc    nvarchar(50)
DECLARE @nm_ref_documento_pagar nvarchar(50)

DECLARE @nm_conta_plano_financeiro nvarchar(100)
DECLARE @dt_envio_banco            DATETIME
DECLARE @dt_contabil_documento     DATETIME
DECLARE @dt_retorno_banco          DATETIME
DECLARE @nm_observacao_documento   nvarchar(75)
DECLARE @nm_complemento_documento  nvarchar(75)
declare @cd_tipo_pagamento         nvarchar(20)
 
DECLARE @dt_pag      DATE
DECLARE @dt_valor    DATE
DECLARE @dt_juros    DATE
DECLARE @dt_abat     DATE
DECLARE @dt_desc     DATE

-----------------------------------------------------------------------------------------------------------
select 
	@cd_identificacao         = cd_identificacao_document,
	@dt_emissao				  = dt_emissao_documento_paga,
	@dt_vencimen              = dt_vencimento_documento,
	@dt_vencimen_original     = dt_vencimento_original,
	@vl_documento             = vl_documento_pagar,
	@vl_abatiment             = vl_abatimento_documento,
	@vl_saldo_d               = vl_saldo_documento_pagar,
	@vl_multa_docum           = vl_multa_documento,
	@vl_desconto_d            = vl_desconto_documento,

	@cd_forneced               = cd_fornecedor,
	@nm_fantasia_fornecedor    = nm_fantasia_fornecedor,
	@cd_ddd                    = cd_ddd,
	@cd_telefone               = cd_telefone,
	@cd_numero_banco           = cd_conta_banco_pagamento,
	@cd_agencia                 = cd_agencia_banco,
	@cd_conta                  = cd_conta,
	@cd_pix                    = cd_pix,

	@cd_pedido_compra          = cd_pedido_compra,
	@cd_portador               = cd_portador,   
	@nm_portador               = nm_portador,
	@cd_nota_saida             = cd_nota_saida,
	@nm_numero_banco           = cd_numero_banco_documento,
	@dt_cancelamento           = dt_cancelamento_documento,
	@nm_cancelamento_doc       = nm_cancelamento_documento,
	@nm_ref_documento_pagar    = nm_ref_documento_pagar,
	@cd_tipo_pagamento         = cd_tipo_pagamento,
	 
	@nm_conta_plano_financeiro = nm_conta_plano_financeiro,
	@dt_envio_banco            = dt_envio_banco_documento,
	@dt_contabil_documento     = dt_contabil_documento_pag,
	@dt_retorno_banco          = dt_retorno_banco_doc,
	@nm_observacao_documento   = nm_observacao_documento,
	@nm_complemento_documento  = nm_complemento_documento,

	@dt_pag                    = dt_pagamento_documento
	--@dt_valor
	--@dt_juros
	--@dt_abat
	--@dt_desc
	
from #rel_pagamento_hoje
--select @cd_identificacao
------------------------------------------------------------------------------------------------------------
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #rel_pagamento_hoje  
  return  
 end  
--------------------------------------------------------------------------------------------------------------
set @html_geral = ' <h1 style="text-align: center;">Documentos a Pagar</h1> 
        <p class="section-title" style="font-weight: bold;text-align: left; font-size: 18px;">Favorecido</p>
        <table style="width: 100%;">
            <tr>
                <td style="display: flex; flex-direction: column; gap: 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
                        <div style="text-align: left; width: 45%;">
                            <p><strong>Fantasia:</strong> '+isnull(@nm_fantasia_fornecedor,'')+'</p>
                            <p><strong>Código:</strong> '+cast(isnull(@cd_forneced,0) as nvarchar(20))+' </p>
                            <p><strong>DDD:</strong> '+cast(isnull(@cd_ddd,0) as nvarchar(20))+'</p>
                            <p><strong>Telefone:</strong> '+cast(isnull(@cd_telefone,0) as nvarchar(20))+'</p>
                            
                        </div>
                        <div style="text-align: left;">
                            <p><strong>Banco: </strong>'+cast(isnull(@cd_numero_banco,0) as nvarchar(20))+'</p>
							<p><strong>Agência: </strong>'+cast(isnull(@cd_agencia,0) as nvarchar(20))+'<p>
                            <p><strong>Nº da Conta: </strong>'+cast(isnull(@cd_conta,0) as nvarchar(20))+'</p>
                            <p><strong>Pix: </strong>'+cast(isnull(@cd_pix,0) as nvarchar(20))+'</p>
                        </div>
                    </div>
                </td>
            </tr>
        </table>
        <p class="section-title" style="font-weight: bold;text-align: left;font-size: 18px;">Dados do Documento</p>
        <table style="width: 100%;">
            <tr>
                <td style="display: flex; flex-direction: column; gap: 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
                        <div style="text-align: left; width: 45%;">
                            <p><strong>Pedido de Compra:</strong> '+cast(isnull(@cd_pedido_compra,0) as nvarchar(20))+'</p>
                            <p><strong>Nota Fiscal:</strong> '+cast(isnull(@cd_nota_saida,0) as nvarchar(20))+'</p>
                            <p><strong>Número Bancário:</strong> '+cast(isnull(@nm_numero_banco,0) as nvarchar(20))+'<p>
                            <p><strong>Portador:</strong> ('+cast(isnull(@cd_portador,0) as nvarchar(20))+')  '+isnull(@nm_portador,'')+'</p>
                        </div>
                        <div style="text-align: left;">
                            <p><strong>Tipo de Pagamento:</strong> '+cast(isnull(@cd_tipo_pagamento,0) as nvarchar(20))+'</p>
                            <p><strong>Cancelamento: </strong> '+isnull(dbo.fn_data_string(@dt_cancelamento),'')+'</p>
                            <p><strong>Referência: </strong> '+isnull(@nm_ref_documento_pagar,'')+'</p>
                            <p><strong>Motivo:</strong> '+isnull(@nm_cancelamento_doc ,'')+'</p> 
                        </div>
                    </div>
                </td>
            </tr>
        </table>
        <table>
            <tr>
                <th>Nº</th>
                <th>Emissão</th>
                <th>Vencimento</th>
                <th>Vencimento Original</th>
                <th>Valor</th>
                <th>Multa</th>
                <th>Abatimento</th>
                <th>Desconto</th>
                <th>Saldo</th>
            </tr>
            <tr>
                <td>'+isnull(@cd_identificacao,'')+'</td>
                <td>'+isnull(dbo.fn_data_string(@dt_emissao),'')+'</td>
                <td>'+isnull(dbo.fn_data_string(@dt_vencimen),'')+'</td>
                <td>'+isnull(dbo.fn_data_string(@dt_vencimen_original),'')+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@vl_documento),0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(dbo.fn_formata_valor(@vl_multa_docum),0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@vl_abatiment),0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@vl_desconto_d),0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@vl_saldo_d),0) as nvarchar(20))+'</td>
            </tr>
        </table>
        <table style="width: 100%;">
            <tr>
                <td style="display: flex; flex-direction: column; gap: 20px; ">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
                        <div style="text-align: left; width: 45%;">
                            <p><strong>Contabilização:</strong> '+isnull(dbo.fn_data_string(@dt_contabil_documento),'')+'</p>
                            <p><strong>Banco Envio:</strong> '+isnull(dbo.fn_data_string(@dt_envio_banco),'')+'</p>
                            <p><strong>Observações:</strong> '+isnull(@nm_observacao_documento,'')+'</p>
							<p>'+isnull(@nm_complemento_documento,'')+'</p>

                        </div>
                        <div style="text-align: left;">
                            <p><strong>Finaceiro:</strong> '+isnull(@nm_conta_plano_financeiro,'')+'</p>
                            <p><strong>Retorno:</strong> '+isnull(dbo.fn_data_string(@dt_retorno_banco),'')+'</p>'
                            
                 
       
--------------------------------------------------------------------------------------------------------------------




set @html_rodape ='
						</div>
                    </div>
                </td>
                
            </tr>
	     </table>
        <p class="section-title" style="font-weight: bold;text-align: left;font-size: 18px; ">Pagamento</p>
            <table>
                <tr>
                <td style="display: flex; flex-direction: column; gap: 10px;">
                   
                    <div style="display: flex; gap: 20px;">
                        <p><strong>Data:</strong> '+isnull(dbo.fn_data_string(@dt_pag),'')+'</p>
                        <p><strong>Valor:</strong></p>
                        <p><strong>Juros:</strong></p>
                        <p><strong>Abatimento:</strong></p>
                        <p><strong>Desconto:</strong></p>
                    </div>
                </td>
            </tr>
            
        </table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	</div>
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>
    </div>
	</body>
	</html>'



--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +
	@html_geral   + 
	@html_cab_det +
    @html_detalhe +
	@html_rod_det +
    @html_rodape  

---------------------


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_documento_pagos_hoje 253,0,'[{
--    "cd_empresa": "360",
--    "cd_modulo": "234",
--    "cd_menu": "0",
--    "cd_relatorio": 253,
--    "cd_processo": "",
--    "cd_item_processo": "",
--    "cd_documento_form": 9,
--    "cd_item_documento_form": "0",
--    "cd_parametro": "0",
--    "cd_usuario": "4915"
--}]'
------------------------------------------------------------------------------
