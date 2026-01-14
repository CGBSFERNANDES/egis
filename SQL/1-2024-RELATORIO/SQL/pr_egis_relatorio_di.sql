IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_di' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_di

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_di  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_di
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
create procedure pr_egis_relatorio_di 
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
            padding: 5px;
            text-align: center;
            vertical-align: top;
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
            margin-left: 0;
            margin-right: 0;
            margin-bottom: 10px;
            border-radius: 1px;
            font-size: 100%;
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
    

    .moeda {
        text-align: center;
    }
    .linha {
        display: flex;
        justify-content: space-between;
        width: 100%;
        padding: 8px 0;
    }
    .coluna {
        flex: 1;
        text-align: center;
    }
    .coluna.pequena {
        flex: 0.5;
    }
    .coluna.grande {
        flex: 2;
    }
    </style>  
</head>  
<body>  
     
    <div style="display: flex; justify-content: space-between; align-items:center">  
  <div style="width:30%; margin-right:20px">  
   <img src="'+@logo+'" alt="Logo da Empresa">  
  </div>  
  <div style="width:70%;text-align: center;"> 
      <p class="title">'+@nm_fantasia_empresa+'</p>   
	  <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p> 
      <p><strong>Phone: </strong>'+@cd_telefone_empresa+' - <strong>Fax: </strong>'+isnull(@fax,'')+'<strong> CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>  
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
---------------------------------------------------------------------------------------------------------------    
    
if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    
--set @cd_documento = 100
---------------------------------------------------------------------------------------------------------------
declare @ValorTotalDespesasAdicionais decimal(25,2)

set @ValorTotalDespesasAdicionais = 0


select
  distinct
  IDENTITY(int,1,1)                                      cd_controle,
  di.cd_di,
  di.nm_di                                               as nm_di,
  di.dt_emissao_di                                       as dt_emissao_di,
  nf.cd_identificacao_nota_saida                         as cd_identificacao_nota_saida,
  nf.dt_nota_saida                                       as dt_nota_saida,
  nfe.dt_nota_entrada                                    as dt_nota_entrada,

  --> Total de Produtos
  di.cd_moeda_di,
	mddi.sg_moeda													as sg_moeda_mercadoria, 	
	di.vl_mercadoria_di_moeda							as vl_mercadoria_moeda,
  di.vl_moeda_di												as pc_moeda_mercadoria,
	round(cast(di.vl_mercadoria_di as decimal(25,2)),2)										as vl_mercadoria_reais,

  di.cd_moeda_frete,
  mdft.sg_moeda 												as sg_moeda_frete,
  di.vl_despesa_frete_di								as vl_frete_moeda,
  di.vl_moeda_frete											as pc_moeda_frete,
  round(cast(di.vl_frete_nacional as decimal(25,2)),2)									as vl_frete_reais,

	di.cd_moeda_seguro,
	mdsg.sg_moeda													as sg_moeda_seguro,
	di.vl_seguro_internacional						as vl_seguro_moeda,
	di.vl_moeda_seguro										as pc_moeda_seguro,
	round(di.vl_seguro_nacional,2)									as vl_seguro_reais,

	round(di.vl_ii_di,2)														as vl_ii,

	--> A - Total Mercadoria
	round(
			cast(isnull(di.vl_mercadoria_di, 0)   as decimal(25,2))
		+ cast(isnull(di.vl_frete_nacional, 0)  as decimal(25,2))
		+ cast(isnull(di.vl_seguro_nacional, 0) as decimal(25,2)) 		
		+ cast(isnull(di.vl_ii_di, 0) 					as decimal(25,2)) 		
      ,2)				  													as vl_total_mercadoria,
	
	--> Despesas Acessórias
	isnull(di.vl_siscomex_di, 0)  				as vl_siscomex,
	isnull(di.vl_capatazia_di, 0) 				as vl_afrmm,

	--> B - Total Despesas Acessórias	
	isnull(di.vl_siscomex_di,0) 
    + isnull(di.vl_capatazia_di, 0)			as vl_total_despesas_acessoria,

	--> Impostos
	isnull(di.vl_pis_di,0) 								as vl_pis,
	isnull(di.vl_cofins_di,0)							as vl_cofins, 
  isnull(di.vl_icms_di,0)								as vl_icms,
	isnull(di.vl_ipi_di,0)								as vl_ipi,

	--> C - Total Impostos
	isnull(di.vl_pis_di,0) 							
		+ isnull(di.vl_cofins_di,0)						  
		+ isnull(di.vl_icms_di,0)								
		+ isnull(di.vl_ipi_di,0)						as vl_total_impostos,

	--> D - Total da Nota Fiscal de Entrada da Importação
	isnull(di.vl_mercadoria_di, 0)
		+ isnull(di.vl_frete_nacional, 0)
		+ isnull(di.vl_seguro_nacional, 0) 		
		+ isnull(di.vl_ii_di, 0)
		+	isnull(di.vl_siscomex_di,0) 
    + isnull(di.vl_capatazia_di, 0)			
		+	isnull(di.vl_pis_di,0) 							
		+ isnull(di.vl_cofins_di,0)						  
		+ isnull(di.vl_icms_di,0)								
		+ isnull(di.vl_ipi_di,0)						as vl_total_nf_entrada,

	--> Despesas Adicionais de Importação
	did.cd_di_despesa,
	case when isnull(did.nm_di_despesa_complemento,'') = '' 
			 then tdc.nm_tipo_despesa_comex 
		   else did.nm_di_despesa_complemento	
	end 																	as nm_despesa_adicional,
	tdc.nm_tipo_despesa_comex                                               as nm_tipo_despesa_comex,
  tdd.nm_tipo_despesa_di                                                    as nm_tipo_despesa_di,
	did.cd_tipo_despesa_di                                                  as cd_tipo_despesa_di,
	did.nm_di_despesa_complemento                                           as nm_di_despesa_complemento, 
	round(
		cast(
			isnull(did.vl_di_despesa,0) as decimal(25,2)
				)
		,2)																	as vl_despesa_adicional

into #RelDadosID

from 
  di
  left outer join vw_di_item_nota_saida nf with (nolock) on (nf.cd_di      						 = di.cd_di)
	left outer join moeda	mddi							 with (nolock) on (mddi.cd_moeda 						 = di.cd_moeda_di) 
	left outer join moeda	mdft							 with (nolock) on (mdft.cd_moeda 				 		 = di.cd_moeda_frete) 
	left outer join moeda	mdsg							 with (nolock) on (mdsg.cd_moeda 						 = di.cd_moeda_seguro) 
	left outer join di_despesa did					 with (nolock) on (did.cd_di		 						 = di.cd_di)
	left outer join tipo_despesa_comex tdc   with (nolock) on (tdc.cd_tipo_despesa_comex = did.cd_tipo_despesa_comex)
  left outer join nota_entrada nfe				 with (nolock) on (nfe.cd_nota_entrada			 = nf.cd_identificacao_nota_saida)
	left outer join tipo_despesa_di tdd      with (nolock) on (tdd.cd_tipo_despesa_di    = did.cd_tipo_despesa_di)
where 
 di.cd_di = @cd_documento


--> Total das Despesas Adicionais
select
  @ValorTotalDespesasAdicionais = sum(isnull(vl_despesa_adicional,0))  
from 
	#RelDadosID
where 
  cd_di = @cd_documento
 -- select * from di
--> Select Exibicao
select
	
	*,
	round(
			cast(isnull(vl_total_mercadoria,0) 					 as decimal(25,2))
		+ cast(isnull(vl_total_despesas_acessoria,0)   as decimal(25,2))
    + cast(isnull(@ValorTotalDespesasAdicionais,0) as decimal(25,2))
			,2)	as vl_total_importacao,
	round(
			cast(isnull(vl_total_mercadoria,0) 					 as decimal(25,2))
		+ cast(isnull(vl_total_despesas_acessoria,0)   as decimal(25,2))
		+ cast(isnull(@ValorTotalDespesasAdicionais,0) as decimal(25,2))
		+ cast(isnull(vl_total_impostos,0) 						 as decimal(25,2))
		  ,2)	as vl_total_financeiro,

  --> Percentuais
  round( vl_mercadoria_reais / vl_total_nf_entrada  * 100, 2)             as percMercadoria,
  round( vl_frete_reais / vl_total_nf_entrada * 100 , 2)                  as percFrete,
  round( vl_seguro_reais / vl_total_nf_entrada * 100, 2)                  as percSeguro,
  round( vl_ii / vl_total_nf_entrada * 100, 2)                            as percII,
  round( cast(vl_siscomex / vl_total_nf_entrada as decimal(25,4))*100, 2) as percSiscomex,
  round( vl_afrmm / vl_total_nf_entrada * 100, 2)                         as percAFRMM,
  round( vl_ipi / vl_total_nf_entrada * 100, 2)                           as percIPI,
  round( vl_pis / vl_total_nf_entrada * 100, 2)                           as percPIS,
  round( vl_cofins / vl_total_nf_entrada * 100, 2)                        as percCOFINS,
  round( vl_icms / vl_total_nf_entrada * 100, 2)                          as percICMS,
  round( vl_total_mercadoria / vl_total_nf_entrada * 100, 2)              as percTotMercadoria,
  round( cast(vl_total_despesas_acessoria / vl_total_nf_entrada as decimal(25,4))*100, 2) as percTotDespesas,
  round( vl_total_impostos / vl_total_nf_entrada * 100, 2)                                as percTotImpostos

	INTO
	#DadosId
from
	#RelDadosID
where
  cd_di = @cd_documento

---------------------------------------------------------------------------------------------------------------------- 
  select 
    
    dii.cd_di                      as cd_di,
	di.nm_di                       as nm_di,
	dii.cd_di_item                 as cd_di_item,
    dii.cd_produto                 as cd_produto,
    max(p.nm_produto)              as nm_produto,
    max(p.cd_mascara_produto)      as cd_mascara_produto,
    max(p.nm_fantasia_produto)     as nm_fantasia_produto,
		max(um.sg_unidade_medida)  as sg_unidade_medida,
    max(isnull(pimp.cd_part_number_produto,''))                                                                                                  as cd_part_number_produto,
    sum(isnull(dii.qt_efetiva_chegada,0))                                                                                                        as Quantidade,
    sum((isnull(dii.vl_cfr_item_di,0) +  isnull(dii.vl_total_ii_item_di,0) + isnull(dii.vl_item_rateio_despesa,0)) / isnull(dii.qt_efetiva_chegada,0)) as Custo,
    sum((isnull(dii.vl_cfr_item_di,0) +  isnull(dii.vl_total_ii_item_di,0) + isnull(dii.vl_item_rateio_despesa,0)))                                    as Custo_Total,
    max(isnull(pc.ic_peps_produto,'N')) as ic_peps_produto


--select vl_cfr_item_di, vl_ii_item_di, vl_item_rateio_despesa, * from di_item where cd_di = 20

into #CustoDiP_itens 

  from
    di_item dii
    inner join di di                          on di.cd_di             = dii.cd_di 
    inner join produto p                    on p.cd_produto         = dii.cd_produto
    left outer join produto_importacao pimp on pimp.cd_produto      = dii.cd_produto
    left outer join produto_custo pc        on pc.cd_produto        = dii.cd_produto
    left outer join unidade_medida um       on um.cd_unidade_medida = p.cd_unidade_medida

  where
	di.cd_di = @cd_documento
    
group by
  dii.cd_di,
  di.nm_di,
	dii.cd_di_item,
  dii.cd_produto

--------------------------------------------------
    declare @vl_totalP decimal(25,2)

	set @vl_totalP = 0.00

	select
	  @vl_totalP = sum(Custo_Total)

	from
	  #CustoDiP_itens
--------------------------------------------------

select 
     identity (int,1,1)             as cd_controle,
     cd_di,
     nm_di,
     cd_di_item,
     cd_produto,
     nm_produto, 	
     cd_mascara_produto,
	 nm_fantasia_produto,
	 sg_unidade_medida,
	 cd_part_number_produto,
	 Quantidade,
	 Custo,
	 round(Custo_Total,2) as Custo_Total,
     cast(round(Custo_Total/@vl_totalP,2)*100 as decimal(25,2)) as pc_total,
	 ic_peps_produto
	 into
	 #relItensDi
from #CustoDiP_itens
order by
  nm_fantasia_produto
  
--------------------------------------------------------------------------------------------------------------------
DECLARE 
		@nm_di VARCHAR(30),
		@dt_emissao_di datetime,
		@cd_identificacao_nota_saida int = 0,
		@dt_nota_saida datetime,
        @dt_nota_entrada datetime,
		@sg_moeda_mercadoria VARCHAR(10),
        @vl_mercadoria_moeda FLOAT,
        @pc_moeda_mercadoria FLOAT,
        @vl_mercadoria_reais FLOAT,
        @sg_moeda_frete VARCHAR(10),
        @vl_frete_moeda FLOAT,
        @pc_moeda_frete FLOAT,
        @vl_frete_reais FLOAT,
        @sg_moeda_seguro VARCHAR(10),
        @vl_seguro_moeda FLOAT,
        @pc_moeda_seguro FLOAT,
        @vl_seguro_reais FLOAT,
        @vl_ii FLOAT,
        @vl_total_mercadoria FLOAT,
        @vl_siscomex FLOAT,
        @vl_afrmm FLOAT,
        @vl_total_despesas_acessoria FLOAT,
        @vl_pis FLOAT,
        @vl_cofins FLOAT,
        @vl_icms FLOAT,
        @vl_ipi FLOAT,
        @vl_total_impostos FLOAT,
        @vl_total_nf_entrada FLOAT,
        @nm_despesa_adicional VARCHAR(255),
        @vl_despesa_adicional FLOAT,
        @vl_total_importacao FLOAT,
        @vl_total_financeiro FLOAT,
        @percMercadoria FLOAT,
        @percFrete FLOAT,
        @percSeguro FLOAT,
        @percII FLOAT,
        @percSiscomex FLOAT,
        @percAFRMM FLOAT,
        @percIPI FLOAT,
        @percPIS FLOAT,
        @percCOFINS FLOAT,
        @percICMS FLOAT,
        @percTotMercadoria FLOAT,
        @percTotDespesas FLOAT,
        @percTotImpostos FLOAT,
		@nm_tipo_despesa_id nvarchar(40),
		@nm_tipo_despesa_comex nvarchar(40),
		@cd_tipo_despesa_di float =0,
		@nm_di_despesa_complemento nvarchar(40),
		@vl_despesa_adic float = 0,
		@vl_total_geral_despesas float = 0,
		@qt_total_itens float = 0
	

SELECT 
    @sg_moeda_mercadoria         = sg_moeda_mercadoria,
    @vl_mercadoria_moeda         = vl_mercadoria_moeda,
    @pc_moeda_mercadoria         = pc_moeda_mercadoria,
    @vl_mercadoria_reais         = vl_mercadoria_reais,
    @sg_moeda_frete              = sg_moeda_frete,
    @vl_frete_moeda              = vl_frete_moeda,
    @pc_moeda_frete              = pc_moeda_frete,
    @vl_frete_reais              = vl_frete_reais,
    @sg_moeda_seguro             = sg_moeda_seguro,
    @vl_seguro_moeda             = vl_seguro_moeda,
    @pc_moeda_seguro             = pc_moeda_seguro,
    @vl_seguro_reais             = vl_seguro_reais,
    @vl_ii                       = vl_ii,
    @vl_total_mercadoria         = vl_total_mercadoria,
    @vl_siscomex                 = vl_siscomex,
    @vl_afrmm                    = vl_afrmm,
    @vl_total_despesas_acessoria = vl_total_despesas_acessoria,
    @vl_pis                      = vl_pis,
    @vl_cofins                   = vl_cofins,
    @vl_icms                     = vl_icms,
    @vl_ipi                      = vl_ipi,
    @vl_total_impostos           = vl_total_impostos,
    @vl_total_nf_entrada         = vl_total_nf_entrada,
    @vl_despesa_adicional        = vl_despesa_adicional,
	@nm_di                       = nm_di,
	@dt_emissao_di               = dt_emissao_di,
	@cd_identificacao_nota_saida = cd_identificacao_nota_saida,
	@dt_nota_saida               = dt_nota_saida,
	@dt_nota_entrada             = dt_nota_entrada,
	@percMercadoria              = percMercadoria,
	@percFrete                   = percFrete,
	@percSeguro                  = percSeguro,
	@nm_tipo_despesa_id			 = nm_tipo_despesa_di,
	@nm_tipo_despesa_comex       = nm_tipo_despesa_comex,
	@cd_tipo_despesa_di          = cd_tipo_despesa_di,
	@nm_di_despesa_complemento   = nm_di_despesa_complemento,       
	@percII                      = percII,
	@percTotMercadoria           = percTotMercadoria,
	@percSiscomex                = percSiscomex,
	@percAFRMM                   = percAFRMM,
	@percTotDespesas             = percTotDespesas,
	@percTotImpostos             = percTotImpostos,
	@percPIS                     = percPIS,
	@percCOFINS                  = percCOFINS,
	@percICMS                    = percICMS,
	@percIPI                     = percIPI,
	@vl_total_importacao         = vl_total_importacao,
	@vl_total_financeiro         = vl_total_financeiro


FROM #DadosId

select 
@qt_total_itens = sum(Quantidade)
from #relItensDi 

--------------------------------------------------------------------------------------------------------------  

set @html_geral = '
     <div>
		<p class="section-title" style="text-align: center;font-size:20px;">Demonstrativo de Cálculo - DI</p>
	 <div>
     <table style="width: 100%;">
        <tr>
            <td style="width: 70%;">
                <div class="linha"> 
                    <p><b>Declaração de Importação Nº:</b> '+ISNULL(@nm_di,'')+'</p> 
                    <p><b>Data DI:</b> '+isnull(dbo.fn_data_string(@dt_emissao_di),'')+'</p> 
                </div>
                <div class="linha"> 
                    <p><b>Nota Fiscal Nº:</b> '+cast(isnull(@cd_identificacao_nota_saida,'')as nvarchar(20))+'</p> 
                    <p><b>Data Nota:</b> '+isnull(dbo.fn_data_string(@dt_nota_saida),'')+'</p> 
                </div>
            </td>
            <td style="width: 30%;">
                <div class="td-content"> 
                    <p><b>Entrada</b></p> 
                    <p>'+isnull(dbo.fn_data_string(@dt_nota_entrada),'')+'</p> 
                </div>
            </td>
        </tr>
    </table>


    <div class="tabela">
        <div class="linha" style="font-weight: bold;">
            <div class="coluna pequena"></div>
            <div class="coluna pequena">Moeda</div>
            <div class="coluna">Qtde Moeda</div>
            <div class="coluna">Taxa</div>
            <div class="coluna pequena">%</div>
            <div class="coluna pequena">Valor em R$</div>
        </div>
        <div class="linha">
            <div class="coluna pequena">Mercadoria</div>
            <div class="coluna pequena">'+isnull(@sg_moeda_mercadoria,'')+'</div>
            <div class="coluna">'+cast(isnull(dbo.fn_formata_valor(@vl_mercadoria_moeda),0)as nvarchar(20))+'</div>
            <div class="coluna">'+cast(isnull(dbo.fn_formata_valor(@pc_moeda_mercadoria),0)as nvarchar(20))+'</div> 
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percMercadoria),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_mercadoria_reais),0)as nvarchar(20))+'</div>
        </div>
        <div class="linha">
            <div class="coluna pequena">Frete Internacional</div>
            <div class="coluna pequena">'+isnull(@sg_moeda_mercadoria,'')+'</div>
            <div class="coluna">'+cast(isnull(dbo.fn_formata_valor(@vl_frete_moeda),0)as nvarchar(20))+'</div>
            <div class="coluna">'+cast(isnull(dbo.fn_formata_valor(@pc_moeda_frete),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percFrete),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_frete_reais),0)as nvarchar(20))+'</div>
        </div>
        <div class="linha">
            <div class="coluna pequena">Seguro Internacional</div>
            <div class="coluna pequena">'+isnull(@sg_moeda_mercadoria,'')+'</div>
            <div class="coluna">'+cast(isnull(dbo.fn_formata_valor(@vl_seguro_moeda),0)as nvarchar(20))+'</div>
            <div class="coluna">'+cast(isnull(dbo.fn_formata_valor(@pc_moeda_seguro),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percSeguro),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_seguro_reais),0)as nvarchar(20))+'</div>
        </div>
        <div class="linha">
            <div class="coluna pequena">I.I - Imposto de Importação</div>
            <div class="coluna pequena"></div>
            <div class="coluna"></div>
            <div class="coluna"></div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percII),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_ii),0)as nvarchar(20))+'</div>
        </div>
    </div>
    <table>
        <tr>
            <td>
        <div class="linha">
            <div class="coluna pequena" style="text-align: left;">A - Valor Total dos Produtos</div>
            <div class="coluna pequena"></div>
            <div class="coluna"></div>
            <div class="coluna"></div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percTotMercadoria),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_total_mercadoria),0)as nvarchar(20))+'</div>
        </div>
    </td>
    </tr>
    </table>
    
    <div class="tabela" style="margin-top: 15px;">
        <div class="linha" >
            <div class="coluna pequena">Taxa Siscomex</div>
            <div class="coluna pequena"></div>
            <div class="coluna"></div>
            <div class="coluna"></div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percSiscomex),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_siscomex),0)as nvarchar(20))+'</div>
        </div>
        <div class="linha">
            <div class="coluna pequena">AFRMM</div>
            <div class="coluna pequena"></div>
            <div class="coluna"></div>
            <div class="coluna"></div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percAFRMM),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_afrmm),0)as nvarchar(20))+'</div>
        </div>
    </div> '

set @html_geral = @html_geral + '
    <table style="margin-bottom: 5px;">
        <tr>
            <td>
                <div class="linha" >
                    <div class="coluna pequena" style="text-align: left;">B - Outras Despesas </div>
                    <div class="coluna pequena"></div>
                    <div class="coluna"></div>
                    <div class="coluna"></div>
                    <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percTotDespesas),0)as nvarchar(20))+'</div>
                    <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_total_despesas_acessoria),0)as nvarchar(20))+'</div>
                </div>
              </td>
        </tr>
    </table>
	    <div class="tabela" style="margin-top: 15px;">
        <div class="linha" >
            <div class="coluna pequena">PIS</div>
            <div class="coluna pequena"></div>
            <div class="coluna"></div>
            <div class="coluna"></div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percPIS),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_pis),0)as nvarchar(20))+'</div>
        </div>
        <div class="linha">
            <div class="coluna pequena">COFINS</div>
            <div class="coluna pequena"></div>
            <div class="coluna"></div>
            <div class="coluna"></div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percCOFINS),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_cofins),0)as nvarchar(20))+'</div>
        </div>
		<div class="linha">
            <div class="coluna pequena">ICMS</div>
            <div class="coluna pequena"></div>
            <div class="coluna"></div>
            <div class="coluna"></div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percICMS),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_icms),0)as nvarchar(20))+'</div>
        </div>
		<div class="linha">
            <div class="coluna pequena">IPI</div>
            <div class="coluna pequena"></div>
            <div class="coluna"></div>
            <div class="coluna"></div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percIPI),0)as nvarchar(20))+'</div>
            <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_ipi),0)as nvarchar(20))+'</div>
        </div>
    </div> 
    <table style="margin-bottom: 5px;">
        <tr>
            <td>
                <div class="linha" >
                    <div class="coluna " style="text-align: left;">C - Total de Impostos pago na nacionalização </div>
                    <div class="coluna pequena"></div>
                    <div class="coluna pequena"></div>
                    <div class="coluna"></div>
                    <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@percTotImpostos),0)as nvarchar(20))+'</div>
                    <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_total_impostos),0)as nvarchar(20))+'</div>
                </div>
              </td>
        </tr>
    </table>
    <table style="margin-bottom: 5px;">
        <tr>
            <td>
                <div class="linha" >
                    <div class="coluna " style="text-align: left;">D - Total da Nota Fiscal de Entrada da Importação (A+B+C)</div>
                    <div class="coluna pequena"></div>
                    <div class="coluna pequena"></div>
                    <div class="coluna pequena"></div>
                    <div class="coluna pequena" style="margin-left: 230px;"></div>
                    <div class="coluna pequena">'+cast(isnull(dbo.fn_formata_valor(@vl_total_nf_entrada),0)as nvarchar(20))+'</div>
                </div>
              </td>
        </tr>
    </table>
    <table style="margin-bottom: 5px;">
        <tr>
		<td>'
	
while exists( select Top 1 cd_controle from #RelDadosID)
  begin
  select top 1   
      @id           = cd_controle,
      @html_geral = @html_geral + 
              '
                <div class="linha" >
                    <div class="coluna pequena">'+ISNULL(nm_tipo_despesa_di,'')+'</div>
                    <div class="coluna pequena">'+ISNULL(nm_tipo_despesa_comex,'')+'</div>
                    <div class="coluna">'+cast(ISNULL(cd_tipo_despesa_di,'')as nvarchar(20))+'</div>
                    <div class="coluna">'+ISNULL(nm_di_despesa_complemento,'') +'</div>
                    <div class="coluna pequena">'+cast(ISNULL(dbo.fn_formata_valor(vl_despesa_adicional),'')as nvarchar(20))+'</div>
            
                </div>
              '
       from #RelDadosID
	 DELETE FROM #RelDadosID WHERE cd_controle = @id

end
    
		
set  @html_detalhe=		
    '</td>
    </tr>
    </table>
    <table style="margin-bottom: 5px;">
        <tr>
            <td>
                <div class="linha" >
                    <div class="coluna"style="text-align: left;">E - Total das Despesas Adicionais de Importação</div>
                    <div class="coluna pequena"></div>
                    <div class="coluna"></div>
                    <div class="coluna"></div>
                    <div class="coluna pequena"></div>
                    <div class="coluna pequena">'+cast(ISNULL(dbo.fn_formata_valor(@ValorTotalDespesasAdicionais),'')as nvarchar(20))+'</div>
                </div>
              </td>
        </tr>
    </table>
    <table style="margin-bottom: 5px;">
        <tr>
            <td>
                <div class="linha" >
                    <div class="coluna" style="text-align: left;">F - TOTAL DA IMPORTAÇÃO CONTABILIZADO NO ESTOQUE (A+B+C+E)</div>
                    <div class="coluna pequena"></div>
                    <div class="coluna"></div>
                    <div class="coluna"></div>
                    <div class="coluna pequena"></div>
                    <div class="coluna pequena">'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_importacao),0) as nvarchar(20))+'</div>
                </div>
              </td>
        </tr>
    </table>

    
    <table style="margin-bottom: 5px;">
        <tr>
            <td>
                <div class="linha" >
                    <div class="coluna pequena" style="text-align: left;"> G - Financeiro (D+E)</div>
                    <div class="coluna pequena"></div>
                    <div class="coluna"></div>
                    <div class="coluna"></div>
                    <div class="coluna pequena"></div>
                    <div class="coluna pequena">'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_financeiro),0) as nvarchar(20))+'</div>
                </div>
              </td>
        </tr>
    </table>
    <table>
        <tr>
            <th>DI</th>
            <th>Item</th>
            <th>Quantidade</th>
            <th>Código</th>
            <th>Fantasia</th>
            <th>Descrição</th>
            <th>Un.</th>
			<th>Custo</th>
            <th>Custo Total</th>
            <th>(%)</th>
        </tr>'
--------------------------------------------------------------------------------------------------------------     
	
while exists( select Top 1 cd_controle from #relItensDi)
  begin
  select top 1   
      @id           = cd_controle,
	  @html_cab_det = @html_cab_det +

       '<tr class="tamanho">
            <td>'+cast(isnull(cd_di,0)as nvarchar(10))+'</td>
            <td>'+cast(isnull(cd_di_item,'')as nvarchar(30))+'</td>
			<td>'+cast(isnull(Quantidade,'')as nvarchar(30))+'</td>
            <td>'+cast(isnull(cd_mascara_produto,'')as nvarchar(30))+'</td>
            <td>'+isnull(nm_fantasia_produto,'')+'</td>
            <td>'+isnull(nm_produto,'')+'</td>
            <td>'+isnull(sg_unidade_medida,'')+'</td>
            <td>'+cast(ISNULL(dbo.fn_formata_valor(Custo),0) as nvarchar(20))+'</td>
			<td>'+cast(ISNULL(dbo.fn_formata_valor(Custo_Total),0) as nvarchar(20))+'</td>
            <td>'+cast(ISNULL(dbo.fn_formata_valor(pc_total),0) as nvarchar(20))+'</td>
            
        </tr>'
     from #relItensDi
	 DELETE FROM #relItensDi WHERE cd_controle = @id

end

--------------------------------------------------------------------------------------------------------------------  
set @html_rod_det = '
     </table>
    <div>
        <p class="section-title"> Qtd. de Registro(s): '+CAST(isnull(@qt_total_itens,0) as nvarchar(20))+'</p>
    </div>
    '
  
set @html_rodape ='
  
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
  
--exec pr_egis_relatorio_di 291,0,''

