IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_documento_receber' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_documento_receber

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_documento_receber
-------------------------------------------------------------------------------
--pr_egis_relatorio_documento_receber
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
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_documento_receber
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


    set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)

------------------------------------------------------------------------------------------------------------

select 
 dr.dt_emissao_documento      as dt_emissao_documento,
 dr.dt_vencimento_documento   as dt_vencimento_documento,
 dr.dt_vencimento_original    as dt_vencimento_original,
 dr.vl_documento_receber      as vl_documento_receber,
 dr.vl_multa_documento		  as vl_multa_documento,
 dr.vl_saldo_documento		  as vl_saldo_documento,
 dr.vl_abatimento_documento   as vl_abatimento_documento,
 c.nm_fantasia_cliente        as nm_fantasia_cliente,
 c.nm_razao_social_cliente    as nm_razao_social_cliente,
 c.cd_cliente                 as cd_cliente,
 c.cd_ddd_celular_cliente	  as cd_ddd_celular_cliente,
 c.cd_celular_cliente         as cd_celular_cliente, 
 c.cd_ddd					  as cd_ddd,
 c.cd_telefone				  as cd_telefone,
 cab.cd_conta                 as cd_conta,
 cab.cd_agencia_banco         as cd_agencia_banco,
 dr.cd_conta_banco_remessa    as cd_conta_banco_remessa,
 dr.cd_pedido_venda			  as cd_pedido_venda,
 dr.cd_nota_saida			  as cd_nota_saida,
 dr.cd_portador               as cd_portador,
 p.nm_portador                as nm_portador,
 dr.cd_tipo_cobranca		  as cd_tipo_cobranca,
 dr.nm_cancelamento_documento as nm_cancelamento_documento,
 dr.dt_cancelamento_documento as dt_cancelamento_documento,
 dr.dt_contabil_documento     as dt_contabil_documento,
 dr.dt_envio_banco_documento  as dt_envio_banco_documento,
 dr.dt_retorno_banco_doc      as dt_retorno_banco_doc,
 pf.nm_conta_plano_financeiro as nm_conta_plano_financeiro, 
 drp.dt_pagamento_documento   as dt_pagamento_documento,
 drp.vl_pagamento_documento   as vl_pagamento_documento,
 drp.vl_juros_pagamento       as vl_juros_pagamento,
 drp.vl_abatimento_documento  as vl_abatimento_documento_pag,
 drp.vl_desconto_documento    as vl_desconto_documento
 
 into 
 #Doc_receber_rel

from documento_receber dr
left outer join cliente c                       on c.cd_cliente             = dr.cd_cliente
left outer join Plano_Financeiro pf             on pf.cd_plano_financeiro   = dr.cd_plano_financeiro 
left outer join Portador p                      on p.cd_portador            = dr.cd_portador 
left outer join documento_receber_pagamento drp on drp.cd_documento_receber = dr.cd_documento_receber
left outer join Conta_Agencia_Banco cab         on cab.cd_conta             = c.cd_conta and cab.cd_conta = drp.cd_conta_banco

where 
dr.cd_documento_receber = @cd_documento
 

------------------------------------------------------------------------------------------------------------
declare 
    @dt_emissao_documento        datetime,
    @dt_vencimento_documento     datetime,
    @dt_vencimento_original      datetime,
    @vl_documento_receber        decimal(18,2),
    @vl_multa_documento          decimal(18,2),
    @vl_saldo_documento          decimal(18,2),
    @vl_abatimento_documento     decimal(18,2),
    @nm_fantasia_cliente         varchar(200),
    @nm_razao_social_cliente_rel varchar(200),
    @cd_cliente                int,
    @cd_ddd_celular_cliente    varchar(5),
    @cd_celular_cliente        varchar(20),
    @cd_ddd                    varchar(5),
    @cd_telefone               varchar(20),
    @cd_conta                  int,
    @cd_agencia_banco          int,
    @cd_conta_banco_remessa    int,
    @cd_pedido_venda           int,
    @cd_nota_saida             int,
    @cd_portador               int,
    @nm_portador               varchar(200),
    @cd_tipo_cobranca          int,
    @nm_cancelamento_documento varchar(200),
    @dt_cancelamento_documento datetime,
    @dt_contabil_documento     datetime,
    @dt_envio_banco_documento  datetime,
    @dt_retorno_banco_doc      datetime,
    @nm_conta_plano_financeiro varchar(200),
    @dt_pagamento_documento    datetime,
    @vl_pagamento_documento    decimal(18,2),
    @vl_juros_pagamento        decimal(18,2),
    @vl_abatimento_doc_pagto   decimal(18,2), 
    @vl_desconto_documento     decimal(18,2)


select 
    @dt_emissao_documento          = dt_emissao_documento,
    @dt_vencimento_documento       = dt_vencimento_documento,
    @dt_vencimento_original        = dt_vencimento_original,
    @vl_documento_receber          = vl_documento_receber,
    @vl_multa_documento            = vl_multa_documento,
    @vl_saldo_documento            = vl_saldo_documento,
    @vl_abatimento_documento       = vl_abatimento_documento,
    @nm_fantasia_cliente           = nm_fantasia_cliente,
    @nm_razao_social_cliente_rel   = nm_razao_social_cliente,
    @cd_cliente                    = cd_cliente,
    @cd_ddd_celular_cliente        = cd_ddd_celular_cliente,
    @cd_celular_cliente            = cd_celular_cliente, 
    @cd_ddd                        = cd_ddd,
    @cd_telefone                   = cd_telefone,
    @cd_conta                      = cd_conta,
    @cd_agencia_banco              = cd_agencia_banco,
    @cd_conta_banco_remessa        = cd_conta_banco_remessa,
    @cd_pedido_venda               = cd_pedido_venda,
    @cd_nota_saida                 = cd_nota_saida,
    @cd_portador                   = cd_portador,
    @nm_portador                   = nm_portador,
    @cd_tipo_cobranca              = cd_tipo_cobranca,
    @nm_cancelamento_documento     = nm_cancelamento_documento,
    @dt_cancelamento_documento     = dt_cancelamento_documento,
    @dt_contabil_documento         = dt_contabil_documento,
    @dt_envio_banco_documento      = dt_envio_banco_documento,
    @dt_retorno_banco_doc          = dt_retorno_banco_doc,
    @nm_conta_plano_financeiro     = nm_conta_plano_financeiro, 
    @dt_pagamento_documento        = dt_pagamento_documento,
    @vl_pagamento_documento        = vl_pagamento_documento,
    @vl_juros_pagamento            = vl_juros_pagamento,
    @vl_abatimento_doc_pagto       = vl_abatimento_documento,
    @vl_desconto_documento         = vl_desconto_documento
from #Doc_receber_rel

------------------------------------------------------------------------------------------------------------
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #Doc_receber_rel  
  return  
 end  
--------------------------------------------------------------------------------------------------------------
set @html_geral = ' <h1 style="text-align: center;">Documentos a Receber</h1> 
        <p class="section-title" style="font-weight: bold;text-align: left; font-size: 18px;">Cliente</p>
        <table style="width: 100%;">
            <tr>
                <td style="display: flex; flex-direction: column; gap: 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
                        <div style="text-align: left; width: 45%;">
                            <p><strong>Fantasia:</strong> '+isnull(@nm_fantasia_cliente,'')+' ('+cast(isnull(@cd_cliente,0) as nvarchar(20))+')</p>
						    <p><strong>Razão Social:</strong> '+isnull(@nm_razao_social_cliente_rel,'')+'</p>
                            '+case when isnull(@cd_ddd,0) = 0 then '' else '<p><strong>DDD:</strong> '+cast(isnull(@cd_ddd,0) as nvarchar(20))+'</p>' end +'
                             '+case when isnull(@cd_telefone,'') = '' then '' else '<p><strong>Telefone:</strong> '+cast(isnull(@cd_telefone,0) as nvarchar(20))+'</p>' end+'
							 '+case when isnull(@cd_ddd_celular_cliente,0) = 0 then '' else '<p><strong>DDD Celular:</strong> '+cast(isnull(@cd_ddd_celular_cliente,0) as nvarchar(20))+'</p>' end+'
                             '+case when isnull(@cd_celular_cliente,'') = '' then '' else '<p><strong>Celular:</strong> '+cast(isnull(@cd_celular_cliente,0) as nvarchar(20))+'</p>' end +'
                            
                        </div>
                        <div style="text-align: left;">
                            <p><strong>Banco: </strong>'+cast(isnull(@cd_conta_banco_remessa,0) as nvarchar(20))+'</p>
							<p><strong>Agência: </strong>'+cast(isnull(@cd_agencia_banco,0) as nvarchar(20))+'<p>
                            <p><strong>Nº da Conta: </strong>'+cast(isnull(@cd_conta,0) as nvarchar(20))+'</p>
                            <p><strong></p>
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
                            <p><strong>Pedido de Compra:</strong> '+cast(isnull(@cd_pedido_venda,0) as nvarchar(20))+'</p>
                            <p><strong>Nota Fiscal:</strong> '+cast(isnull(@cd_nota_saida,0) as nvarchar(20))+'</p>
                           
                            <p><strong>Portador:</strong> ('+cast(isnull(@cd_portador,0) as nvarchar(20))+')  '+isnull(@nm_portador,'')+'</p>
                        </div>
                        <div style="text-align: left;">
                            <p><strong>Tipo de Pagamento:</strong> '+cast(isnull(@cd_tipo_cobranca,0) as nvarchar(20))+'</p>
                            <p><strong>Cancelamento: </strong> '+isnull(dbo.fn_data_string(@dt_cancelamento_documento),'')+'</p>
                           
                            <p><strong>Motivo:</strong> '+isnull(@nm_cancelamento_documento ,'')+'</p> 
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
            <tr style="text-align:center;">
                <td>'+cast(isnull(@cd_documento,0) as nvarchar(20))+'</td>
                <td>'+isnull(dbo.fn_data_string(@dt_emissao_documento),'')+'</td>
                <td>'+isnull(dbo.fn_data_string(@dt_vencimento_documento),'')+'</td>
                <td>'+isnull(dbo.fn_data_string(@dt_vencimento_original),'')+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@vl_documento_receber),0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(dbo.fn_formata_valor(@vl_multa_documento),0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@vl_abatimento_documento),0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@vl_abatimento_documento),0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@vl_saldo_documento),0) as nvarchar(20))+'</td>
            </tr>
        </table>
        <table style="width: 100%;">
            <tr>
                <td style="display: flex; flex-direction: column; gap: 20px; ">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
                        <div style="text-align: left; width: 45%;">
                            <p><strong>Contabilização:</strong> '+isnull(dbo.fn_data_string(@dt_contabil_documento),'')+'</p>
                            <p><strong>Banco Envio:</strong> '+isnull(dbo.fn_data_string(@dt_envio_banco_documento),'')+'</p>
                        </div>
                        <div style="text-align: left;">
                            <p><strong>Finaceiro:</strong> '+isnull(@nm_conta_plano_financeiro,'')+'</p>
                            <p><strong>Retorno:</strong> '+isnull(dbo.fn_data_string(@dt_retorno_banco_doc),'')+'</p>'
                            
                 
       
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
                        <p><strong>Data:</strong> '+isnull(dbo.fn_data_string(@dt_pagamento_documento),'')+'</p>
                        <p><strong>Valor:</strong> '+cast(isnull(dbo.fn_formata_valor(@vl_pagamento_documento),0) as nvarchar(20))+'</p>
                        <p><strong>Juros:</strong> '+cast(isnull(dbo.fn_formata_valor(@vl_juros_pagamento),0) as nvarchar(20))+'</p>
                        <p><strong>Abatimento:</strong> '+cast(isnull(dbo.fn_formata_valor(@vl_abatimento_doc_pagto),0) as nvarchar(20))+'</p>
                        <p><strong>Desconto:</strong> '+cast(isnull(dbo.fn_formata_valor(@vl_desconto_documento),0) as nvarchar(20))+'</p>
                    </div>
                </td>
            </tr>
            
        </table>

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
--exec pr_egis_relatorio_documento_receber 376,0,'[{
--    "cd_empresa": "274",
--    "cd_modulo": "235",
--    "cd_menu": "0",
--    "cd_relatorio": 377,
--    "cd_processo": "",
--    "cd_item_processo": "",
--    "cd_documento_form": 53046,
--    "cd_item_documento_form": "0",
--    "cd_parametro": "0",
--    "cd_usuario": "3788"
--}]'
------------------------------------------------------------------------------
