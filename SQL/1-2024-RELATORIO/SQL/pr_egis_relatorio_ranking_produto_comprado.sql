IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_ranking_produto_comprado' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_ranking_produto_comprado

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_ranking_produto_comprado  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_ranking_produto_comprado  
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
create procedure pr_egis_relatorio_ranking_produto_comprado  
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
declare @cd_moeda        int = 1 
declare @vl_moeda float  
--set @dt_inicial = 
--set @dt_final = '02-28-2025'
set @vl_moeda = (case when dbo.fn_vl_moeda(@cd_moeda) = 0 then 
                   1  
                 else 
                   dbo.fn_vl_moeda(@cd_moeda) 
                 end)   

select distinct
  p.cd_produto,
  p.nm_fantasia_produto,
  p.nm_produto,
  um.sg_unidade_medida,
  sum(isnull(pci.qt_item_pedido_compra,0))                                                       as TotalItensGrupo, 
  sum(isnull(p.qt_peso_liquido,0))                                                               as TotalPesoLiquidoGrupo,
  sum(isnull(p.qt_peso_bruto,0))                                                                 as TotalPesoBrutoGrupo,
  sum(isnull(pci.qt_item_pedido_compra,0) * isnull(pci.vl_item_unitario_ped_comp,0)/ @vl_moeda)  as ValorTotalGrupo,
  sum(isnull(pci.qt_item_pedido_compra,0) * isnull(pcc.vl_custo_produto,0)/ @vl_moeda)           as TotalCustoProdutoGrupo,
  max(pc.dt_pedido_Compra)                                                             as 'UltimaCompra',
  sum(pci.qt_item_pedido_compra*(pci.vl_item_unitario_ped_comp)/ @vl_moeda)            as 'Compra',
  max(gp.nm_grupo_produto)                                                             as nm_grupo_produto,
  max(cp.nm_categoria_produto)                                                         as nm_categoria_produto,
  max(mp.nm_marca_produto)                                                             as nm_marca_produto,
  max(fp.nm_familia_produto)                                                           as nm_familia_produto,
  max(ap.nm_agrupamento_produto)                                                       as nm_agrupamento_produto,

  max(isnull(p.qt_espessura_produto,0))                                                as qt_espessura_produto,
  max(isnull(p.qt_largura_produto,0))                                                  as qt_largura_produto,
  max(isnull(p.qt_comprimento_produto,0))                                              as qt_comprimento_produto,
  max(isnull(p.qt_area_produto,0))                                                     as qt_area_produto,

  ---Quantidade em m2-------------------------------------------------------------------------------------
  sum(isnull(pci.qt_item_pedido_compra,0) * isnull(p.qt_area_produto,0) )              as qt_m2_comprado,
  max(isnull(pcc.vl_custo_produto,0))                                                  as vl_custo_produto





into 
  #pedido_compra

from
  pedido_compra                                pc  with(nolock)
  inner join pedido_compra_item                pci with(nolock) on pci.cd_pedido_compra      = pc.cd_pedido_compra
  inner join produto                           p   with(nolock) on p.cd_produto              = pci.cd_produto
  left outer join unidade_medida               um  with(nolock) on um.cd_unidade_medida      = pci.cd_unidade_medida
  left outer join produto_custo                pcc with(nolock) on pcc.cd_produto            = pci.cd_produto
  left outer join categoria_produto cp             with(nolock) on cp.cd_categoria_produto   = p.cd_categoria_produto
  left outer join grupo_produto gp                 with(nolock) on gp.cd_grupo_produto       = p.cd_grupo_produto
  left outer join marca_produto mp                 with(nolock) on mp.cd_marca_produto       = p.cd_marca_produto
  left outer join familia_produto fp               with(nolock) on fp.cd_familia_produto     = p.cd_familia_produto
  left outer join agrupamento_produto ap           with(nolock) on ap.cd_agrupamento_produto = p.cd_agrupamento_produto
  

where
  pci.dt_item_canc_ped_compra is null and
  pci.qt_item_pedido_compra * isnull(pci.vl_item_unitario_ped_comp,0) > 0 and
  isnull(pc.vl_total_pedido_compra,0) > 0 and 
  pc.dt_pedido_compra between @dt_inicial and @dt_final

group by
  p.cd_categoria_produto,
  p.cd_produto,
  p.nm_fantasia_produto,
  p.nm_produto,
  um.sg_unidade_medida

order by
  TotalItensGrupo desc

  declare @qt_total_categ int  
  declare @vl_total_categ float  
     
  set @qt_total_categ = @@rowcount       
  set @vl_total_categ     = 0  

select
  @vl_total_categ = @vl_total_categ + Compra  
from  
  #pedido_compra  

select
  pc.*,
  p.cd_mascara_produto
into
  #Pedido_compra2
from
  #pedido_compra pc
  left outer join produto p on p.cd_produto = pc.cd_produto
   
select 
  identity(int,1,1)                 as cd_controle,
  cd_produto,
  cd_mascara_produto                as cd_mascara_produto,
  nm_fantasia_produto               as nm_fantasia_produto,
  nm_produto                        as nm_produto,
  sg_unidade_medida                 as sg_unidade_medida,
  TotalItensGrupo                   as TotalItensGrupo, 
  case when TotalItensGrupo<>0 then round(ValorTotalGrupo/TotalItensGrupo,4) else 0.00 end  as vl_unitario,
  TotalPesoLiquidoGrupo             as TotalPesoLiquidoGrupo,
  TotalPesoBrutoGrupo               as TotalPesoBrutoGrupo,
  ValorTotalGrupo                   as ValorTotalGrupo,
  UltimaCompra                      as UltimaCompra,
  TotalCustoProdutoGrupo            as TotalCustoProdutoGrupo,
  (pc.Compra/@vl_total_categ)*100   as Perc,
  nm_grupo_produto,
  nm_categoria_produto,
  nm_marca_produto,
  nm_familia_produto,
  nm_agrupamento_produto,
  qt_espessura_produto,
  qt_largura_produto,
  qt_comprimento_produto,
  qt_area_produto,
  qt_m2_comprado,
  vl_custo_produto                  as vl_custo_produto
  

into
  #pedido_compra_aux  
from
  #Pedido_compra2 pc
order by
  Perc desc
------------------------------------------------------------------------------------------------------------
  declare @vl_quantidade_geral float = 0 
  declare @vl_total            float = 0 
  declare @vl_peso_liq         float = 0 
  declare @vl_peso_bruto       float = 0 
  declare @qt_total_produto    float = 0
  select 
    @vl_quantidade_geral = sum(TotalItensGrupo),
    @vl_total            = sum(ValorTotalGrupo), 
    @vl_peso_liq         = sum(TotalPesoLiquidoGrupo),
    @vl_peso_bruto       = sum(TotalPesoBrutoGrupo),
	@qt_total_produto    = COUNT(cd_mascara_produto)
  from #pedido_compra_aux
 ------------------------------------------------------------------------------------------------------------  
 if isnull(@cd_parametro,0) = 1    
 begin    
    select * from #pedido_compra_aux    
  return    
 end    

--------------------------------------------------------------------------------------------------------------  
set @html_detalhe = '' 
set @html_cab_det = '  
    <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 25%;"> '+isnull(+@titulo,'')+' </p>  
    </div>  
 <div>  
    <table>    
       <tr>  
		<th>Código de Produto</th>  
		<th>Produto</th>  
		<th>Descrição</th>  
		<th>UN.</th>
		<th>Quantidade</th>
		<th>Unitário</th>
		<th>Valor Total</th>
		<th>Total Peso Liq.</th>
		<th>Total Peso Bruto</th>
		<th>Última Compra</th>  
		<th>Custo Unitário</th> 
	   </tr>'  
          
--------------------------------------------------------------------------------------------------------------  
DECLARE @id int = 0   
  
WHILE EXISTS (SELECT TOP 1 cd_controle FROM #pedido_compra_aux)  
BEGIN  
    SELECT TOP 1  
        @id                          = cd_controle,  
         
   
      @html_detalhe = @html_detalhe + 
        '<tr>  
		   <td class="tamanho">'+cast(ISNULL(cd_mascara_produto,0)as nvarchar(20))+'</td>    
           <td style="text-align: left;">'+iSNULL(nm_fantasia_produto, '')+ '</td>  
		   <td style="text-align: left;">'+iSNULL(nm_produto, '')+ '</td>  
		   <td class="tamanho">'+iSNULL(sg_unidade_medida, '')+ '</td>  
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(TotalItensGrupo),0)as nvarchar(20))+'</td>  
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(vl_unitario),0)as nvarchar(20))+'</td>  
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(ValorTotalGrupo),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(TotalPesoLiquidoGrupo),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(TotalPesoBrutoGrupo),0)as nvarchar(20))+'</td>
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_data_string(UltimaCompra),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(vl_custo_produto),0)as nvarchar(20))+'</td> 
        </tr>'  
  from #pedido_compra_aux  
    DELETE FROM #pedido_compra_aux WHERE cd_controle = @id  
END  
--------------------------------------------------------------------------------------------------------------------  
  
set @html_rodape ='  
 <tr >  
  <td class="tamanho"><strong>Total</strong></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"><strong>'+cast(ISNULL(dbo.fn_formata_valor(@vl_quantidade_geral),0)as nvarchar(20))+'</strong></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"><strong>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total),0)as nvarchar(20))+'</strong></td> 
  <td class="tamanho"><strong>'+cast(ISNULL(dbo.fn_formata_valor(@vl_peso_liq),0)as nvarchar(20))+'</strong></td> 
  <td class="tamanho"><strong>'+cast(ISNULL(dbo.fn_formata_valor(@vl_peso_bruto),0)as nvarchar(20))+'</strong></td> 
  <td class="tamanho"></td> 
  <td class="tamanho"></td> 
 </tr>  
 </table>  
 <div class="company-info">  
  <p><strong>'+@footerTitle+'</strong></p>  
 </div>  
    <p>'+@ds_relatorio+'</p>  
 </div>  
 <div class="section-title">  
     <p>Total de Produtos: '+cast(isnull(@qt_total_produto,0)as nvarchar(10))+'</p>  
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
  
-- exec pr_egis_relatorio_ranking_produto_comprado 267,0,''
