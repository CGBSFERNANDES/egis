IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_pedidos_compra_aplicacao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_pedidos_compra_aplicacao

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_pedidos_compra_aplicacao  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_pedidos_compra_aplicacao  
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
create procedure pr_egis_relatorio_pedidos_compra_aplicacao  
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
declare @cd_aplicacao_produto   int = 0 
--declare @cd_relatorio           int = 0  
  
--Dados do Relat�rio---------------------------------------------------------------------------------  
  
     declare  
            @titulo                     varchar(200),  
      @logo                       varchar(400),     
   @nm_cor_empresa             varchar(20),  
   @nm_endereco_empresa       varchar(200) = '',  
   @cd_telefone_empresa     varchar(200) = '',  
   @nm_email_internet      varchar(200) = '',  
   @nm_cidade        varchar(200) = '',  
   @sg_estado        varchar(10)  = '',  
   @nm_fantasia_empresa     varchar(200) = '',  
   @numero         int = 0,  
   @dt_pedido        varchar(60) = '',  
   @cd_cep_empresa       varchar(20) = '',  
   @cd_cliente        int = 0,  
 --  @nm_fantasia_cliente       varchar(200) = '',  
   @cd_cnpj_cliente      varchar(30) = '',  
   @nm_razao_social_cliente varchar(200) = '',  
   @nm_cidade_cliente   varchar(200) = '',  
   @sg_estado_cliente   varchar(5) = '',  
   @cd_numero_endereco   varchar(20) = '',  
   @nm_condicao_pagamento  varchar(100) = '',  
   @ds_relatorio    varchar(8000) = '',  
   @subtitulo     varchar(40)   = '',  
   @footerTitle    varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais     int = 0,  
   @nm_pais     varchar(20) = '',  
   @cd_cnpj_empresa   varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet  varchar(200) = ''  
  
  
  
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
  select @cd_aplicacao_produto   = valor from #json where campo  = 'cd_aplicacao_produto'
  
  
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
  @nm_cor_empresa          = isnull(e.nm_cor_empresa,'#1976D2'),  
  @nm_endereco_empresa      = isnull(e.nm_endereco_empresa,''),  
  @cd_telefone_empresa     = isnull(e.cd_telefone_empresa,''),  
  @nm_email_internet        = isnull(e.nm_email_internet,''),  
  @nm_cidade        = isnull(c.nm_cidade,''),  
  @sg_estado        = isnull(es.sg_estado,''),  
  @nm_fantasia_empresa     = isnull(e.nm_fantasia_empresa,''),  
  @cd_cep_empresa       = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),  
  @cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),  
  @nm_pais     = ltrim(rtrim(isnull(p.sg_pais,''))),  
  @cd_cnpj_empresa   = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),  
  @cd_inscestadual_empresa =  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),  
  @nm_dominio_internet  =  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))  
        
 from egisadmin.dbo.empresa e with(nolock)  
 left outer join Estado es  with(nolock) on es.cd_estado = e.cd_estado  
 left outer join Cidade c  with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado  
 left outer join Pais p   with(nolock) on p.cd_pais = e.cd_pais  
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
--set @dt_inicial = '02/01/2025'
--set @dt_final = '02/28/2025'
set @cd_aplicacao_produto = 0 
select 
  IDENTITY(Int,1,1)             as cd_controle,
  ap.cd_aplicacao_produto       as codigoAplicacao,
  ap.nm_aplicacao_produto	    as Aplicacao,
  pc.cd_pedido_compra       	as Pedido,
  pci.dt_item_pedido_compra     as DataPedido,
  f.nm_fantasia_fornecedor  	as Fornecedor,
  pci.vl_total_item_pedido_comp as Total,
  pc.dt_nec_pedido_compra   	as 'Necessidade',
  c.nm_comprador           		as 'Comprador',
  nei.cd_nota_entrada			as 'NotaEntrada',
  nei.cd_item_nota_entrada		as 'ItemNotaEntrada',
  nei.qt_item_nota_entrada		as 'QtdeItemNotaEntrada',
--  ne.dt_nota_entrada			as 'DataNotaEntrada',
  nei.dt_item_receb_nota_entrad as 'DataNotaEntrada',
  pci.cd_pedido_compra,
	pci.cd_item_pedido_compra,
	pci.qt_item_pedido_compra,
	pci.qt_saldo_item_ped_compra,

	pci.vl_item_unitario_ped_comp,
	pci.pc_item_descto_ped_compra,

	pci.qt_item_pesliq_ped_compra,
	pci.qt_item_pesbr_ped_compra,

	pci.dt_item_canc_ped_compra,
        pci.nm_item_motcanc_ped_compr,

	pci.pc_ipi                               as pc_ipi,
	
	pci.dt_item_nec_ped_compra,
	pci.qt_dia_entrega_item_ped,
	pci.dt_entrega_item_ped_compr,

  case when pci.ic_pedido_compra_item='P'
       then pci.nm_produto
       else case when isnull(pci.cd_servico,0)>0 then s.nm_servico
                                                 else cast(pci.ds_item_pedido_compra as varchar(50)) end
      end as nm_produto,

      --pci.nm_produto,
	case when isnull(pci.cd_servico,0)>0 then s.nm_servico else pci.nm_fantasia_produto end as 'nm_fantasia_produto',
	
	pci.dt_item_ativ_ped_compra,
	pci.nm_item_ativ_ped_compra,

  case when isnull(pci.cd_produto,0)>0 then dbo.fn_mascara_produto(pci.cd_produto)
                                       else s.cd_mascara_servico end                            as 'cd_mascara_produto',
  plc.nm_plano_compra,
  plc.cd_mascara_plano_compra 

  into
  #RelAplicacao
--select * from plano_compra

  from
     	Pedido_Compra 	pc                              with (nolock) 
	inner join Aplicacao_Produto 		ap 	with (nolock) on ap.cd_aplicacao_produto	= pc.cd_aplicacao_produto
	inner join Fornecedor 			f 	with (nolock) on pc.cd_fornecedor  		= f.cd_fornecedor 
	inner join Comprador 			c 	with (nolock) on pc.cd_comprador		= c.cd_comprador
	left outer join Plano_Compra 		plc 	with (nolock) on plc.cd_plano_compra 		= pc.cd_plano_compra
	inner join Pedido_compra_Item		pci 	with (nolock) on pci.cd_pedido_compra 	= pc.cd_pedido_compra 
	left outer join nota_entrada_item	nei	with (nolock) on nei.cd_item_pedido_compra	= pci.cd_item_pedido_compra and 
                                                                         nei.cd_pedido_compra	        = pci.cd_pedido_compra
        left outer join Servico                 s       with (nolock) on s.cd_servico                 = pci.cd_servico

                                                       --and nei.cd_produto               = pci.cd_produto
--	left outer join nota_entrada		ne	on ne.cd_nota_entrada		= nei.cd_nota_entrada and
  --                                                         ne.cd_fornecedor             = pc.cd_fornecedor 
  where
     pc.dt_pedido_compra  between @dt_inicial and @dt_final and
     pc.dt_cancel_ped_compra is null and
     IsNull(pc.cd_aplicacao_produto,0) = ( case when @cd_aplicacao_produto = 0 then IsNull(pc.cd_aplicacao_produto,0) else @cd_aplicacao_produto end)
  order by
    ap.nm_aplicacao_produto,
    pc.dt_pedido_compra     desc
---------------------------------------------------------------------------------------------------------------------------------------
select
    codigoAplicacao,
	Aplicacao,
	sum(Total)                      as vl_total_item_tt,
	sum(qt_item_pesbr_ped_compra)   as qt_item_pesbr_ped_compra,
	sum(qt_item_pesliq_ped_compra)  as qt_item_pesliq_ped_compra,
	SUM(qt_item_pedido_compra)      AS qt_item_pedido_compra_tt,
	SUM(qt_saldo_item_ped_compra)   AS qt_saldo_item_ped_compra_tt,
	SUM(vl_item_unitario_ped_comp)  as vl_item_unitario_ped_comp_tt,
	sum(pc_ipi)                     as pc_ipi_tt,
	SUM(pc_item_descto_ped_compra)  as pc_item_descto_ped_compra_tt,
	count(cd_item_pedido_compra)    as cd_item_pedido_compra_tt
	into
	#CapaAplicacao
from
  #RelAplicacao
group by
  codigoAplicacao,
  Aplicacao
	
	--select * from #CapaAplicacao
declare 
	@nm_aplicacao_prod            nvarchar(60),
	@vl_total_item_tt             float =0,
	@qt_item_pesbr_ped_compra     float =0,
	@qt_item_pesliq_ped_compra    float =0,
	@qt_item_pedido_compra_tt     float =0,
	@qt_saldo_item_ped_compra_tt  float =0,
	@vl_item_unitario_ped_comp_tt float =0,
	@pc_ipi_tt                    float =0,
	@pc_item_descto_ped_compra_tt float = 0,
	@qt_geral                     float = 0,
	@vl_total_geral               float = 0,
	@cd_item_pedido_compra_tt     float = 0 
select 
	@qt_geral          = SUM(qt_item_pedido_compra_tt),
	@vl_total_geral    = SUM(vl_total_item_tt)
from #CapaAplicacao

--------------------------------------------------------------------------------------------------------------  

set @html_geral = '  
    <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 15%;"> '+isnull(+@titulo,'')+' </p>  
    </div>  '
--------------------------------------------------------------------------------------------------------------     
	
while exists( select Top 1 codigoAplicacao from #CapaAplicacao )
  begin

  select Top 1
	@nm_aplicacao_prod				 = Aplicacao,
	@cd_aplicacao_produto			 = codigoAplicacao,
	@vl_total_item_tt                = vl_total_item_tt,
	@qt_item_pesbr_ped_compra        = qt_item_pesbr_ped_compra,
	@qt_item_pesliq_ped_compra       = qt_item_pesliq_ped_compra,
	@qt_item_pedido_compra_tt        = qt_item_pedido_compra_tt,
	@qt_saldo_item_ped_compra_tt     = qt_saldo_item_ped_compra_tt,
	@vl_item_unitario_ped_comp_tt    = vl_item_unitario_ped_comp_tt,
	@pc_ipi_tt                       = pc_ipi_tt,
	@pc_item_descto_ped_compra_tt    = pc_item_descto_ped_compra_tt,
	@cd_item_pedido_compra_tt        = cd_item_pedido_compra_tt
  from #CapaAplicacao	

--------------------------------------------------------------------------------------------------------------
set @html_cab_det = @html_cab_det +'   <div class="section-title">
										  <p><strong>Aplicação: '+isnull(+@nm_aplicacao_prod,'')+' </strong></p>
									   </div>    
										<table>
											<tr>												
												<th>Data Pedido</th>  
												<th>Total</th>  
												<th>Comprador</th>  
												<th>Classificação Plano</th>  
												<th>Plano Compra</th>  
												<th>Item</th>  
												<th>Qtd.</th>  
												<th>Saldo</th>  
												<th>Valor</th>  
												<th>(%)IPI</th>  
												<th>(%)Desconto</th>
												<th>Bruto</th>
												<th>Liquido</th>
												<th>Pedido</th>
												<th>Fornecedor</th>
											</tr>
											'
								
   
  --------------------------------------------------------------------------------------------------------------------------
  declare @id int = 0 

  while exists ( select top 1 cd_controle from #RelAplicacao where codigoAplicacao = @cd_aplicacao_produto)
  begin

    select top 1
      
      @id           = cd_controle,
      @html_cab_det = @html_cab_det + '
            <tr> 		
			    <td class="tamanho">'+isnull(dbo.fn_data_string(DataPedido),'')+'</td> 
				<td class="tamanho">'+CAST(isnull(dbo.fn_formata_valor(Total),'')as nvarchar(20))+'</td> 
				<td class="tamanho">'+isnull(Comprador,'')+'</td>
				<td class="tamanho">'+isnull(cd_mascara_plano_compra,'')+'</td>
				<td class="tamanho" style="text-align: left;">'+isnull(nm_plano_compra,'')+'</td>
				<td class="tamanho">'+CAST(isnull(cd_item_pedido_compra,'')as nvarchar(20))+'</td> 
				<td class="tamanho">'+CAST(isnull(qt_item_pedido_compra,'')as nvarchar(20))+'</td> 
				<td class="tamanho">'+CAST(isnull(dbo.fn_formata_valor(qt_saldo_item_ped_compra),'')as nvarchar(20))+'</td>
				<td class="tamanho">'+CAST(isnull(dbo.fn_formata_valor(vl_item_unitario_ped_comp),'')as nvarchar(20))+'</td>
				<td class="tamanho">'+CAST(isnull(dbo.fn_formata_valor(pc_ipi),'')as nvarchar(20))+'</td>
				<td class="tamanho">'+CAST(isnull(dbo.fn_formata_valor(pc_item_descto_ped_compra),'')as nvarchar(20))+'</td>
				<td class="tamanho">'+CAST(isnull(dbo.fn_formata_valor(qt_item_pesbr_ped_compra),'')as nvarchar(20))+'</td>
				<td class="tamanho">'+CAST(isnull(dbo.fn_formata_valor(qt_item_pesliq_ped_compra),'')as nvarchar(20))+'</td>
				<td class="tamanho">'+CAST(isnull(Pedido,'')as nvarchar(20))+'</td>
				<td class="tamanho" style="text-align: left;">'+isnull(fornecedor,'')+'</td>
            </tr>
	    '

     from
       #RelAplicacao

     where
       codigoAplicacao = @cd_aplicacao_produto

	   

  delete from #RelAplicacao
  where
    cd_controle = @id

 end
	set @html_cab_det = @html_cab_det + '	
	     <tr>
		   <td class="tamanho" style="font-size:18px;"><b>Total</b></td>
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_item_tt),0)as nvarchar(20))+'</b></td> 
		   <td class="tamanho" style="font-size:18px;"><b></b></td>
		   <td class="tamanho" style="font-size:18px;"><b></b></td>
		   <td class="tamanho" style="font-size:18px;"><b></b></td>
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(@cd_item_pedido_compra_tt,0)as nvarchar(20))+'</b></td>  
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@qt_item_pedido_compra_tt),0)as nvarchar(20))+'</b></td>  
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@qt_saldo_item_ped_compra_tt),0)as nvarchar(20))+'</b></td>  
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_item_unitario_ped_comp_tt),0)as nvarchar(20))+'</b></td>  
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@pc_ipi_tt),0)as nvarchar(20))+'</b></td>  
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@pc_item_descto_ped_compra_tt),0)as nvarchar(20))+'</b></td>  
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@qt_item_pesbr_ped_compra),0)as nvarchar(20))+'</b></td>  
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@qt_item_pesliq_ped_compra),0)as nvarchar(20))+'</b></td> 
		   <td class="tamanho" style="font-size:18px;"><b></b></td>
		   <td class="tamanho" style="font-size:18px;"><b></b></td>
	     </tr>'

 delete from #CapaAplicacao
    where
       codigoAplicacao = @cd_aplicacao_produto
	   
	   SET @html_cab_det = @html_cab_det + '</table>'
end
--------------------------------------------------------------------------------------------------------------------  
  
  
  
  
set @html_rodape ='   
 <div class="section-title">
     <p style="margin-bottom: 10px;"><strong>Quantidade Total:</strong> '+cast(ISNULL(dbo.fn_formata_valor(@qt_geral),0)as nvarchar(20))+'</p>
     <p><strong>Valor Total:</strong> '+cast(ISNULL(dbo.fn_formata_valor(@vl_total_geral),0)as nvarchar(20))+'</p>    
 </div>
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
  
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
 
  

  go
--exec pr_egis_relatorio_pedidos_compra_aplicacao 264,0,''

