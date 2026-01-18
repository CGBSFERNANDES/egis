IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_invoice' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_invoice

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_invoice  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_invoice
-------------------------------------------------------------------------------  
--GBS Global Business Solution Ltda                                        2024  
-------------------------------------------------------------------------------  
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020  
--  
--Autor(es)        : Joao Pedro Marcal  
--Banco de Dados   : Egissql - Banco do Cliente   
--  
--Objetivo         : Relatorio Padrao Egis HTML - EgisMob, EgisNet, Egis  
--Data             : 10.01.2025   
--Altera��o        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_invoice 
@cd_relatorio int   = 0,  
@cd_parametro int   = 0,  
@json nvarchar(max) = ''   
  

as  
  
set @json = isnull(@json,'')  
declare @data_grafico_bar       nvarchar(max)  
declare @cd_empresa             int = 0  
declare @cd_form                int = 0  
declare @cd_usuario             int = 0  
declare @cd_documento           int = 0  
declare @dt_hoje                datetime  
declare @dt_inicial             datetime  
declare @dt_final               datetime  
declare @cd_ano                 int      
declare @cd_mes                 int      
declare @cd_dia                 int  
declare @cd_grupo_relatorio     int = 0  
declare @id                     int = 0
--Dados do Relat�rio---------------------------------------------------------------------------------  
  
declare  
   @titulo                     varchar(200),  
   @logo                       varchar(400), 
   @fax                        varchar(20), 
   @nm_cor_empresa             varchar(20),  
   @nm_endereco_empresa        varchar(200) = '',  
   @cd_telefone_empresa        varchar(200) = '',  
   @nm_email_internet          varchar(200) = '',  
   @nm_cidade                  varchar(200) = '',  
   @sg_estado                  varchar(10)  = '',  
   @nm_fantasia_empresa        varchar(200) = '',  
   @numero                     int = 0,  
   @dt_pedido                  varchar(60) = '',  
   @cd_cep_empresa             varchar(20) = '',   
   @nm_cidade_cliente          varchar(200) = '',  
   @sg_estado_cliente          varchar(5) = '',  
   @cd_numero_endereco         varchar(20) = '',  
   @ds_relatorio               varchar(8000) = '',  
   @subtitulo                  varchar(40)   = '',  
   @footerTitle                varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais                    int = 0,  
   @nm_pais                    varchar(20) = '',  
   @cd_cnpj_empresa            varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet        varchar(200) = '',
   @tipo_pedido                int = 0 
  
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
    @dt_inicial           = dt_inicial,    
    @dt_final             = dt_final
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
  @logo                       = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),  
  @nm_cor_empresa             = isnull(e.nm_cor_empresa,'#1976D2'),  
  @nm_endereco_empresa        = isnull(e.nm_endereco_empresa,''),  
  @cd_telefone_empresa        = isnull(e.cd_telefone_empresa,''),  
  @nm_email_internet          = isnull(e.nm_email_internet,''),  
  @nm_cidade                  = isnull(c.nm_cidade,''),  
  @sg_estado                  = isnull(es.sg_estado,''),  
  @nm_fantasia_empresa        = isnull(e.nm_empresa,''),  
  @cd_cep_empresa             = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),  
  @cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),  
  @nm_pais					  = ltrim(rtrim(isnull(p.sg_pais,''))),  
  @cd_cnpj_empresa            = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),  
  @cd_inscestadual_empresa    =  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),  
  @nm_dominio_internet        =  ltrim(rtrim(isnull(e.nm_dominio_internet,''))),
  @fax                        =  isnull(e.cd_fax_empresa,'')
        
 from egisadmin.dbo.empresa e with(nolock)  
 left outer join Estado es    with(nolock) on es.cd_estado = e.cd_estado  
 left outer join Cidade c     with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado  
 left outer join Pais p       with(nolock) on p.cd_pais    = e.cd_pais  
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
    <title >'+isnull(@titulo,'')+'</title>  
    <style>  
        body {
            font-family: Arial, sans-serif;
            color: #333;
            padding: 20px;
            flex: 1;
        }

        h2 {
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        table,
        th,
        td {
            border: 1px solid #ddd;
            text-align: center;
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
            font-size: 14px;
            text-align: center;
        }
        .td-content {
            display: flex;
            flex-direction: column;
            text-align: center;  
        }

    </style>  
</head>  
<body>  
     
    <div style="display: flex; justify-content: space-between; align-items:center">  
  <div style="width:20%; margin-right:20px">  
   <img src="'+@logo+'" alt="Logo da Empresa">  
  </div>  
  <div style="width:60%;text-align: center;"> 
      <p class="title">'+@nm_fantasia_empresa+'</p>   
	  <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p> 
      <p><strong>Phone: </strong>'+@cd_telefone_empresa+' - <strong>Fax: </strong>'+isnull(@fax,'')+'<strong> CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>  
      <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>     
  </div>
   <div style="width:20%;">
       <p ><b>DATA/HOTA: </b>'+@data_hora_atual+'</p>
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
---------------------------------------------------------------------------------------------------------------    
    
if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    
			Select
        Distinct
		identity(int,1,1)                                                               as cd_controle,
        i.cd_invoice              														as cd_invoice,
				i.nm_invoice              											    as Invoice,
        i.dt_invoice              														as DataInvoice,
				cast('' as varchar)														as PackingList,
        tc.sg_termo_comercial     														as Incoterm,
				cp.nm_condicao_pagamento												as CondicaoPagamento,
				cast('' as varchar)														as ReceiverTaxID,
				i.nm_transporte_invoice													as Transporte,
        po.nm_porto                  													as Origem,
        pd.nm_porto                  													as Destino,
				i.dt_embarque															as DataEmbarque,
				m.sg_moeda																as Moeda,
				ppo.nm_pais																as PaisOrigem,
        tf.nm_tipo_frete          														as TipoFrete,
        Cast(i.ds_invoice_observacao as VarChar(1000)) 				                    as Observacao,
        isnull(i.nm_referencia_processo,'')                                             as ReferenciaProcesso,

				--> Dados do Importador

				imp.nm_razao_social 												    as nm_importador,
				imp.nm_endereco 
					+ case when isnull(imp.cd_numero_endereco,0)=0 		 		then '' else ', '  +rtrim(imp.cd_numero_endereco) end
			    + case when isnull(imp.nm_complemento_endereco,'')='' then '' else ' - ' +imp.nm_complemento_endereco end
																					    as nm_endereco_importador,
				rtrim(cid_imp.nm_cidade) +' - '+ est_imp.sg_estado 					    as nm_cidade_estado_importador,
				imp.cd_cep															    as cd_cep_importador,
			  'Tel: ('+rtrim(imp.cd_ddd)+')'	 + imp.cd_telefone	  				    as nm_telefone_importador,
				cast('' as varchar) 												    as nm_email_importador,

				--> Dados do Exportador/Fabricante
        
				f.nm_fantasia_fornecedor 												as Fornecedor,
				f.nm_endereco_fornecedor 
			  --  + case when isnull(f.cd_numero_endereco,0)=0 		 		then '' else ', '  +rtrim(f.cd_numero_endereco) end
			    + case when isnull(f.nm_complemento_endereco,'')='' then '' else ' - ' +f.nm_complemento_endereco end
																																												as nm_endereco_fornecedor,
				rtrim(cid_for.nm_cidade) +' - '+ est_for.sg_estado 															as nm_cidade_estado_fornecedor,
				
				f.cd_cep																																				as cd_cep_fornecedor,
			  'Tel: ('+rtrim(f.cd_ddd)+')'	 + f.cd_telefone	  															as nm_telefone_fornecedor,
				case when isnull(f.nm_email_fornecedor,'')='' 
						 then '' 
						 else 'Email: '+f.nm_email_fornecedor																									
				end 																																						as nm_email_forncedor,				
				
				--> Itens
				
				ii.cd_invoice_item																							as InvoiceItem,
				p.cd_mascara_produto																	          as PartnumberItem,
				cast(p.nm_produto	as varchar(2000))				 											as DescricaoItem,
				pi.nm_ordem_compra_pedido  																			as PoItem,
				('PI'
					+ Right('000000' + cast(pi.cd_pedido_importacao as varchar),6)
					+'/'+cast(datepart(yy,pi.dt_pedido_importacao) as varchar))		as OrigemImportacao,
				isnull(ii.qt_invoice_item,0)  																	as QtdeItem,
				um.sg_unidade_medida																						as UnidadeMedidaItem,
        IsNull(ii.vl_invoice_item,0) 																		as ValorUnitarioItem,
        IsNull(ii.vl_invoice_item_total,0) 															as ValorTotalItem,
				IsNull(ii.qt_peso_bruto,0) 																			as PesoItem,
				isNull(cf.cd_mascara_classificacao,0)														as NcmItem

		into
		#RelInvoice

       from Invoice i                       				with (nolock) 
         Left outer join Invoice_Item ii                        on (ii.cd_invoice = i.cd_invoice)
         Left outer join Importador imp                         on (imp.cd_importador = i.cd_importador)
 	     left outer join cidade cid_imp 						on (cid_imp.cd_cidade = imp.cd_cidade)
	   	 left outer join estado est_imp 						on (est_imp.cd_estado = imp.cd_estado)
         Left outer join Fornecedor f                           on (f.cd_fornecedor = i.cd_fornecedor)
 		 left outer join cidade cid_for 						on (cid_for.cd_cidade = f.cd_cidade)
	   	 left outer join estado est_for 						on (est_for.cd_estado = f.cd_estado)
         Left outer join Status_Invoice si                      on (si.cd_status_invoice = i.cd_status_invoice)
		 Left outer join Condicao_Pagamento cp			        on (cp.cd_condicao_pagamento = i.cd_condicao_pagamento)
         Left outer join Tipo_Frete tf                          on (tf.cd_tipo_frete = i.cd_tipo_frete)
         Left outer join Termo_Comercial tc                     on (tc.cd_termo_comercial = i.cd_termo_comercial)
         Left outer join Porto po                               on (po.cd_porto = i.cd_porto_origem)
         Left outer join Porto pd                   	        on (pd.cd_porto = i.cd_porto_destino)
		 Left outer join Pais ppo								on (ppo.cd_pais = po.cd_pais)
         Left outer join Pedido_Importacao_Item pii             on (pii.cd_pedido_importacao = ii.cd_pedido_importacao and
                                                                    pii.cd_item_ped_imp      = ii.cd_item_ped_imp)
         Left outer join Pedido_Importacao pi                   on (pi.cd_pedido_importacao  = ii.cd_pedido_importacao)
         Left outer join Pedido_Venda_item pvi                  on (pvi.cd_pedido_venda      = pii.cd_pedido_venda and 
                                                                   	pvi.cd_item_pedido_venda = pii.cd_item_pedido_venda)
         Left outer join Pedido_Venda pv						on (pv.cd_pedido_venda = pvi.cd_pedido_venda)
         Left outer join Cliente c								on (c.cd_cliente = pv.cd_cliente) 
         Left outer join Produto p								on (p.cd_produto = ii.cd_produto)
		 left outer join Produto_importacao pdi				    on (pdi.cd_produto = p.cd_produto)
		 left outer join Produto_compra	pdc						on (pdc.cd_produto = p.cd_produto)
		 left outer join Unidade_Medida um						on (um.cd_unidade_medida = p.cd_unidade_medida)
         Left outer join Moeda m                                on (m.cd_moeda = i.cd_moeda)
		 left outer join Origem_importacao oi					on (oi.cd_origem_importacao = ii.cd_origem_importacao)
		 left outer join Produto_Fiscal	pf						on (pf.cd_produto = ii.cd_produto)
		 left outer join Classificacao_Fiscal cf			    on (cf.cd_classificacao_fiscal = pf.cd_classificacao_fiscal)


    where
			isnull(i.cd_invoice,0)	= @cd_documento
--select * from Invoice
--------------------------------------------------------------------------------------------------------------

DECLARE @Invoice					VARCHAR(255)
DECLARE @DataInvoice				datetime
DECLARE @PackingList				VARCHAR(255)
DECLARE @Incoterm					VARCHAR(50)
DECLARE @CondicaoPagamento			VARCHAR(255)
DECLARE @ReceiverTaxID				VARCHAR(50)
DECLARE @Transporte					VARCHAR(255)
DECLARE @Origem						VARCHAR(255)
DECLARE @Destino					VARCHAR(255)
DECLARE @DataEmbarque				DATETIME
DECLARE @Moeda						VARCHAR(50)
DECLARE @PaisOrigem					VARCHAR(255)
DECLARE @TipoFrete					VARCHAR(255)
DECLARE @Observacao					VARCHAR(1000)
DECLARE @ReferenciaProcesso			VARCHAR(255)

-- Dados do Importador
DECLARE @nm_importador               VARCHAR(255)
DECLARE @nm_endereco_importador      VARCHAR(500)
DECLARE @nm_cidade_estado_importador VARCHAR(255)
DECLARE @cd_cep_importador           VARCHAR(20)
DECLARE @nm_telefone_importador      VARCHAR(50)
DECLARE @nm_email_importador         VARCHAR(255)

-- Dados do Exportador/Fabricante
DECLARE @Fornecedor                  VARCHAR(255)
DECLARE @nm_endereco_fornecedor      VARCHAR(500)
DECLARE @nm_cidade_estado_fornecedor VARCHAR(255)
DECLARE @cd_cep_fornecedor           VARCHAR(20)
DECLARE @nm_telefone_fornecedor      VARCHAR(50)
DECLARE @nm_email_fornecedor         VARCHAR(255)

-- Itens da Invoice
DECLARE @InvoiceItem                 INT
DECLARE @PartnumberItem              VARCHAR(255)
DECLARE @DescricaoItem				 VARCHAR(2000)
DECLARE @PoItem                      VARCHAR(255)
DECLARE @OrigemImportacao            VARCHAR(255)
DECLARE @QtdeItem                    INT = 0 
declare @qt_total_item               int = 0
DECLARE @UnidadeMedidaItem           VARCHAR(50)
DECLARE @ValorUnitarioItem           FLOAT = 0
DECLARE @ValorTotalItem              FLOAT = 0
declare @vl_total_geral              float = 0
DECLARE @PesoItem                    FLOAT = 0
DECLARE @NcmItem                     VARCHAR(50)

select
 @Invoice						= Invoice,
 @DataInvoice					= DataInvoice,
 @PackingList					= PackingList,
 @Incoterm						= Incoterm,
 @CondicaoPagamento				= CondicaoPagamento,
 @ReceiverTaxID					= ReceiverTaxID,
 @Transporte					= Transporte,
 @Destino						= Destino,
 @DataEmbarque					= DataEmbarque,
 @Moeda							= Moeda,
 @PaisOrigem					= PaisOrigem,
 @Observacao					= Observacao,
 @ReferenciaProcesso			= ReferenciaProcesso,
 								
  								
 @nm_importador              	= nm_importador,
 @nm_endereco_importador     	= nm_endereco_importador,
 @nm_cidade_estado_importador	= nm_cidade_estado_importador,
 @cd_cep_importador          	= cd_cep_importador,
 @nm_telefone_importador     	= nm_telefone_importador,
 @nm_email_importador        	= nm_email_importador,
 								
  								
 @Fornecedor                 	= Fornecedor,
 @nm_endereco_fornecedor     	= nm_endereco_fornecedor,
 @nm_cidade_estado_fornecedor	= nm_cidade_estado_fornecedor,
 @cd_cep_fornecedor          	= cd_cep_fornecedor,
 @nm_telefone_fornecedor     	= nm_telefone_fornecedor,
 @nm_email_fornecedor        	= @nm_email_fornecedor
 								
 
from #RelInvoice

select
	@qt_total_item = sum(QtdeItem),
	@vl_total_geral = SUM(ValorTotalItem)

from #RelInvoice
--------------------------------------------------------------------------------------------------------------  


set @html_geral = '  
        <table style="width: 100%;">
        <tr>
          <td style="width: 55%;">
            <div class="td-content">
              <span ><b>Invoice Comercial No. '+cast(isnull(@Invoice,0)as nvarchar(20))+'</b></span>
            </div>
          </td>
          <td style="width: 15%;">
            <div class="td-content">
              <span> <b>Packing List.</b></span>
              <span >'+isnull(@PackingList,'')+'</span>
            </div>
          </td>
          <td style="width: 15%;">
            <div class="td-content">
              <span ><b>Reference</b></span>
              <span >'+ISNULL(@ReferenciaProcesso,'')+'</span>
            </div>
          </td>
          <td style="width: 15%;">
            <div class="td-content">
              <span ><b>Data</b></span>
              <span >'+isnull(dbo.fn_data_string(@DataInvoice),'')+'</span>
            </div>
          </td>
        </tr>
    </table>

    <table style="width: 100%;">
        <tr >
            <td style="width: 55%;" rowspan="5">
                <div class="td-content" style="text-align:left">
                    <p><b> Exportador/Fabricante: </b></p>
                    <p>'+ISNULL(@Fornecedor,'')+'</p>
                    <p>'+ISNULL(@nm_endereco_fornecedor,'')+'</p>
                    <p>'+ISNULL(@nm_cidade_estado_fornecedor,'')+'</p>
                    <p>'+ISNULL(@nm_email_fornecedor,'')+'</p>
					<p>'+ISNULL(@nm_telefone_fornecedor,'')+'</p>
                </div>
            </td>
            
           
        </tr>
		<tr style="width: 11.5%;">
            <td class="td-content">
                <span style="text-align: left;"><b>INCOTERM</b></span>
                <span style="text-align: right;">'+isnull(@Incoterm,'')+'</span>
            </td>
        </tr>
        <tr style="width: 11%;">
            <td class="td-content">
                <span style="text-align: left;"><b>Condição de Pagamento</b></span>
                <span style="text-align: right;">'+isnull(@CondicaoPagamento,'')+'</span>
            </td>
        </tr>
        
        <tr style="width: 11%;">
            <td class="td-content">
                <span style="text-align: left;"><b>Conta de Recebimento</b></span>
                <span style="text-align: right;">'+isnull(@ReceiverTaxID,'')+'</span>
            </td>
        </tr>

        <tr style="width: 11.5%;">
            <td class="td-content">
                <span style="text-align: left;"><b>Transporte</b></span>
                <span style="text-align: right;">'+isnull(@Transporte,'')+'</span>
            </td>
        </tr>
      </table>'
set @html_detalhe = '
      <table style="width: 100%;">
        <tr >
            <td style="width: 55%;" rowspan="5">
                <div class="td-content" style="text-align: left;">
                    <p> <b>Importador: </b></p>
                    <p>'+isnull(@nm_importador,'')+'</p>
                    <p>'+isnull(@nm_endereco_importador,'')+'</p>
                    <p>'+isnull(@nm_cidade_estado_importador,'')+'</p>
                    <p>'+isnull(@nm_email_importador,'')+'</p>
					<p>Tel: '+isnull(@nm_telefone_importador,'')+'</p>
                </div>
            </td>
        </tr>
        <tr style="width: 11%;">
            <td class="td-content">
                <p style="text-align: left;"><b>País Origem</b></p>
                <p style="text-align: right;">'+isnull(@PaisOrigem,'')+'</p>
            </td>
        </tr>
        <tr style="width: 11.5%;">
            <td class="td-content">
                <p style="text-align: left;"><b>Destino</b></p>
                <p style="text-align: right;">'+isnull(@Destino,'')+'</p>
            </td>
        </tr>
        <tr style="width: 11.5%;">
            <td class="td-content">
                <p style="text-align: left;"><b>Moeda</b></span>
                <p style="text-align: right;">'+isnull(@Moeda,'')+'</p>
            </td>
        </tr>
    
    <tr style="width: 11%;">
        <td class="td-content">
            <p style="text-align: left;"><b>Data Embarque</b></p>
            <p style="text-align: right;">'+isnull(dbo.fn_data_string(@DataEmbarque),'')+'</p>
        </td>
    </tr>
      </table>
      <table>
        <tr>
            <th>Item</th>
            <th>Partnumber</th>
            <th>PO</th>
            <th>Descrição</th>
            <th>NCM</th>
            <th>Origem</th>
            <th>Qtde</th>
            <th>Un.</th>
            <th>Vl.Unitário</th>
            <th>Vl.Total(US$)</th>
        </tr>'
--------------------------------------------------------------------------------------------------------------     
	
while exists( select Top 1 cd_controle from #RelInvoice)
  begin
  select top 1   
      @id           = cd_controle,
	  @html_cab_det = @html_cab_det +

       '<tr class="tamanho">
            <td>'+cast(isnull(InvoiceItem,'')as nvarchar(10))+'</td>
            <td>'+cast(isnull(PartnumberItem,'')as nvarchar(30))+'</td>
            <td>'+cast(isnull(Invoice,'')as nvarchar(30))+'</td>
            <td>'+isnull(DescricaoItem,'')+'</td>
            <td>'+isnull(NcmItem,'')+'</td>
            <td>'+isnull(OrigemImportacao,'')+'</td>
            <td>'+cast(isnull(QtdeItem,'')as nvarchar(30))+'</td>
			<td>'+isnull(UnidadeMedidaItem,'')+'</td>
            <td>'+cast(isnull(ValorUnitarioItem,'')as nvarchar(30))+'</td>
            <td>'+cast(isnull(ValorTotalItem,'')as nvarchar(30))+'</td>
        </tr>'
     from #RelInvoice
	 DELETE FROM #RelInvoice WHERE cd_controle = @id

end

--------------------------------------------------------------------------------------------------------------------  
set @html_rod_det = '
      </table>
        <table>
          <tr>
            <td >
                <p style="text-align: left;"><b>Observação:</b></p>
                <p style="text-align: left;">'+ISNULL(@Observacao,'')+'</p>
                <p style="text-align: right;"><b>Quantidade Total: </b>'+CAST(isnull(@qt_total_item,0)as nvarchar(20))+'</p>
                <p style="text-align: right;"><b>Total('+ISNULL(@Moeda,'')+'): </b>'+CAST(isnull(dbo.fn_formata_valor(@vl_total_geral),0)as nvarchar(20))+'</p>
            </td>
        </tr>
      </table>'
  
set @html_rodape ='
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
	@html_detalhe +
	@html_cab_det +
    @html_rod_det +
    @html_rodape  
  
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
 
go
  
--exec pr_egis_relatorio_invoice 291,0,''

