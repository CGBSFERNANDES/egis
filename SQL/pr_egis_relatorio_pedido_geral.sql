IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_pedido_geral' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_pedido_geral

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_pedido_geral  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_pedido_geral  
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
--Alteracao        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_pedido_geral  
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
declare @ic_valor_comercial     varchar(10)  
declare @cd_tipo_destinatario   int   
declare @cd_cliente_grupo       int = 0  
declare @cd_grupo_relatorio     int    
declare @cd_vendedor            int    
declare @nm_razao_social        varchar(60) = ''
declare @cd_categoria_produto   int = 0 
  
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
   @ds_relatorio    varchar(8000) = '',  
   @subtitulo     varchar(40)   = '',  
   @footerTitle    varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais     int = 0,  
   @nm_pais     varchar(20) = '',  
   @cd_cnpj_empresa   varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet  varchar(200) = '',
   @cd_categoria_cliente int = 0
  
  
  
--------------------------------------------------------------------------------------------------------  

set @cd_empresa        = 0  
set @cd_form           = 0  
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
 
  select @cd_empresa             = valor from #json where campo = 'cd_empresa'               
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'               
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'   
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'  
  select @dt_final               = valor from #json where campo = 'dt_final'  
  select @cd_cliente             = valor from #json where campo = 'cd_cliente'    
  select @cd_categoria_produto   = valor from #json where campo = 'cd_categoria_produto'
  select @cd_categoria_cliente   = valor from #json where campo = 'cd_categoria_cliente' 

   set @cd_cliente = isnull(@cd_cliente,0)  
  
   if @cd_cliente = 0  
   begin  
     select @cd_cliente           = valor from #json where campo = 'nm_razao_social'  
  
   end  
end  
  
  
-------------------------------------------------------------------------------------------------  
declare @ic_processo char(1) = 'N'    
     
    
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
  @dt_inicial			  = dt_inicial,    
  @dt_final				  = dt_final,    
  @cd_vendedor			  = isnull(cd_vendedor,0),  
 -- @cd_cliente			  = isnull(cd_cliente,0),  
  @cd_categoria_produto   = isnull(cd_categoria_produto,0),
  @cd_categoria_cliente   = isnull(cd_categoria_cliente,0)
from     
  Parametro_Relatorio    
    
where    
  cd_relatorio = @cd_relatorio    
  and    
  cd_usuario   = @cd_usuario    
---------------------------------------------------------------------------------------------------------------------------  
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
  
-- Obt�m a data e hora atual  
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)  
------------------------------  
  
--select @dt_final  
---------------------------------------------------------------------------------------------------------------------------------------------  
  
---------------------------------------------------------------------------------------------------------------------------------------------  
--select * from egisadmin.dbo.relatorio  
  
  
--select @titulo  
--  
--select @nm_cor_empresa  
-----------------------  
--Cabe�alho da Empresa----------------------------------------------------------------------------------------------------------------------  
-----------------------  
  
SET @html_empresa = '  
<html>  
<head>  
    <meta charset="UTF-8">  
    <meta http-equiv="X-UA-Compatible" content="IE=edge">  
    <meta name="viewport" content="width=device-width, initial-scale=1.0">  
 <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.2/html2pdf.bundle.min.js" integrity="sha512-MpDFIChbcXl2QgipQrt1VcPHMldRILetapBl5MPCA9Y8r7qvlwx1/Mc9hNTzY+kS5kX6PdoDq41ws1HiVNLdZA==" crossorigin="anonymous" referrerpolicy="no-referrer
"></script>  
    <title >'+@titulo+'</title>  
    <style>  
        body {  
            font-family: Arial, sans-serif;  
            color: #333;  
			padding:20px;  
			flex:1;
        }  
  
        h2 {  
            color: #333;  
        }  
  
        table {  
            width: 100%;  
            border-collapse: collapse;  
            margin-bottom: 20px;  
            font-size: 12px;  
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
  tr {  
   page-break-inside: avoid;    
   page-break-after: auto;  
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
            padding: 3px;  
            margin-bottom: 10px;  
            border-radius: 5px;  
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
            font-size: 75%;  
            text-align: center;  
        }  
  #salva {  
     background-color: #1976D2;  
     color: white;  
     border: none;  
     padding: 10px 20px;  
     font-size: 16px;  
     cursor: pointer;  
     border-radius: 5px;  
     transition: background-color 0.3s;  
   }  
  
    #salva:hover {  
     background-color: #1565C0;  
   }  
    .nao-imprimir {  
            display: none;  
        }  
		.tamanho{
            font-size: 12px;
            padding: 5px;
        }
 </style>  
</head>  
<body>  
   <div id="conteudo">  
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
  
--select @html_empresa  
  
    
  
--Detalhe--  
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
  
  
--------------------------------------------------------------------------------------------------------------------------  
--set @cd_vendedor  = 9  
--set @dt_inicial = '03/14/2025'
--set @dt_final = '03/14/2025'

select 
  identity(int,1,1) as cd_controle,  
  c.cd_cliente_grupo                                                          as cd_cliente_grupo,  
  max(cg.nm_cliente_grupo) as nm_cliente_grupo,  --Grupo de Cliente  
  right(left(convert(varchar,p.hr_inicial_pedido,121),16),5) as hr_inicial_pedido,  
  p.cd_pedido_venda                                                           as cd_pedido_venda,  
  dbo.fn_data_string(p.dt_pedido_venda)                                       as dt_pedido_venda,  
  tp.nm_tipo_pedido                                                           as nm_tipo_pedido,  
  tp.cd_tipo_pedido                                                           as cd_tipo_pedido, 
  c.cd_cliente                                                                as cd_cliente,  
  c.nm_fantasia_cliente                                                       as nm_fantasia_cliente,  
  CASE WHEN c.cd_tipo_pessoa = 1 
	then ISNULL(dbo.fn_formata_cnpj(c.cd_cnpj_cliente),'')
		else isnull(dbo.fn_formata_cpf(c.cd_cnpj_cliente),'') end			  as cd_cnpj_cliente,
  c.nm_endereco_cliente													      as nm_endereco_cliente, 
  v.cd_vendedor                                                               as cd_vendedor,  
  v.nm_fantasia_vendedor                                                      as nm_fantasia_vendedor,  
  i.nm_produto_pedido														  as nm_produto_pedido,
  um.cd_unidade_medida														  as cd_unidade_medida,
  um.sg_unidade_medida														  as sg_unidade_medida,  
  CAST(MAX(i.vl_unitario_item_pedido) AS DECIMAL(10,2))                       AS vl_unitario_item_pedido,
  max(i.qt_item_pedido_venda)                                                 as qt_item_pedido_venda,
  max(isnull(p.vl_total_pedido_ipi,0))                                        as vl_total,    
  max(i.cd_usuario_ordsep)                                                    as cd_usuario_ordsep,  
  max(i.dt_ordsep_pedido_venda)                                               as dt_ordsep_pedido_venda,  
  max(isnull(i.ic_ordsep_pedido_venda,'N'))                                   as ic_ordsep_pedido_venda,  
  max(isnull(ef.nm_fantasia_empresa,''))                                      as nm_fantasia_empresa,  
  max(est.sg_estado)                                                          as sg_estado,  
  max(cid.nm_cidade)                                                          as nm_cidade,  
  --MAX(cg.nm_cliente_grupo)                                                    as nm_cliente_grupo,  
  max(vw.cd_identificacao_nota_saida)                                         as cd_identificacao_nota_saida,  
  max(dbo.fn_data_string(vw.dt_nota_saida))                                   as dt_nota_saida,  
  max(c.nm_razao_social_cliente)                                              as nm_razao_social_cliente,  
  CAST(MAX(i.vl_unitario_item_pedido) AS DECIMAL(10,2)) * MAX(i.qt_item_pedido_venda)                as vl_total_item 
  
  into  
    #DiarioPedidoGeral
  
from 
  pedido_venda p  
    
  inner join cliente c												on c.cd_cliente                    = p.cd_cliente  
  inner join Estado est												on est.cd_estado                   = c.cd_estado  
  inner join cidade cid												on cid.cd_cidade                   = c.cd_cidade 
																	and cid.cd_estado                  = cid.cd_estado
  left outer join tipo_pedido tp									on tp.cd_tipo_pedido               = p.cd_tipo_pedido 
  
  inner join vendedor v												on v.cd_vendedor                   = p.cd_vendedor 
  inner join pedido_venda_item i                                    on i.cd_pedido_venda               = p.cd_pedido_venda  
  LEFT outer join produto pp                                        on pp.cd_produto                   = i.cd_produto
  LEFT outer join Categoria_Produto cp                              on cp.cd_categoria_produto         = i.cd_categoria_produto
  left outer join categoria_cliente cc                              on cc.cd_categoria_cliente         = c.cd_categoria_cliente
  LEFT outer join Unidade_Medida um	      						    on um.cd_unidade_medida			   = pp.cd_unidade_medida 
  left outer join pedido_venda_empresa pve                          on pve.cd_pedido_venda             = p.cd_pedido_venda  
  left outer join empresa_faturamento ef                            on ef.cd_empresa                   = pve.cd_empresa  
  left outer join Cliente_Grupo cg                                  on cg.cd_cliente_grupo             = c.cd_cliente_grupo  
  left outer join vw_pedido_venda_item_nota_saida vw  with (nolock) on vw.cd_pedido_venda              = p.cd_pedido_venda   
                                   and vw.cd_item_pedido_venda     = i.cd_item_pedido_venda  
  
 
  
where  
  p.dt_pedido_venda between @dt_inicial and @dt_final  
  and  
  p.cd_cliente = case when isnull(@cd_cliente,0) = 0 then p.cd_cliente else isnull(@cd_cliente,0) end  
  and  
  p.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then p.cd_vendedor else isnull(@cd_vendedor,0) end  
  and  
  i.cd_categoria_produto = case when isnull(@cd_categoria_produto,0) = 0 then i.cd_categoria_produto else isnull(@cd_categoria_produto,0) end
  and  
  cc.cd_categoria_cliente = case when isnull(@cd_categoria_cliente,0) = 0 then cc.cd_categoria_cliente else isnull(@cd_categoria_cliente,0) end
  and
  ISNULL(tp.ic_gera_bi,'S') = 'S'  
  and  
  i.dt_cancelamento_item is null  
 

  group by
  c.cd_cliente_grupo,  
  p.dt_pedido_venda,
  p.cd_pedido_venda,    
  tp.nm_tipo_pedido,  
  c.cd_cliente,  
  c.nm_fantasia_cliente,  
  v.cd_vendedor,  
  v.nm_fantasia_vendedor,
  p.hr_inicial_pedido,
  c.cd_cnpj_cliente,
  c.nm_endereco_cliente,
  i.nm_produto_pedido,
  um.sg_unidade_medida,
  um.cd_unidade_medida,
  c.cd_tipo_pessoa,
  tp.cd_tipo_pedido

     
 if isnull(@cd_parametro,0) = 1    
 begin    
    select * from #DiarioPedidoGeral    
  return    
 end    
  
--------------------------------------------------------------------------------------------------------------  
declare @nm_fantasia_vendedor        nvarchar(60),  
 @hr_inicial_pedido					 nvarchar(10),  
 @cd_pedido_venda					 int = 0,
 @dt_pedido_venda					 nvarchar(20),  
 @nm_tipo_pedido					 nvarchar(40),   
 @cd_cliente_tb						 int = 0,
 @nm_fantasia_cliente				 nvarchar(60),  
 @vl_total							 nvarchar(20),   
 @nm_fantasia_empresa_tb			 nvarchar(60),  
 @sg_estado_tb						 nvarchar(40),  
 @nm_cidade_tb						 nvarchar(40),  
 @cd_identificacao_nota_saida		 int = 0,
 @dt_nota_saida						 nvarchar(20),  
 @nm_grupo_cliente					 nvarchar(60),  
 @vl_total_pedido					 float = 0,
 @vl_total_nota						 float = 0,
 @vl_total_vendedor                  int = 0,
 @vl_total_cliente                   int = 0,
 @vl_total_cx                        float = 0,
 @tipo_pedido_total                  int =0,
 @soma_uni                           float = 0, 
 @soma_cx                            float = 0,
 @soma_pc                            float = 0,
 @soma_pt                            float = 0,
 @soma_rl                            float = 0,
 @soma_un                            float = 0,
 @soma_min                           float = 0,
 @soma_pack                          float = 0,
 @soma_pct                           float = 0,
 @soma_kg                            float = 0
select   
  
 @vl_total_nota     = Sum(vl_total_item),  
 @vl_total_cx       = SUM(qt_item_pedido_venda),
 @vl_total_pedido   = COUNT(DISTINCT cd_pedido_venda),
 @vl_total_vendedor = COUNT(DISTINCT cd_vendedor), 
 @vl_total_cliente  = COUNT(DISTINCT cd_cliente),
 @tipo_pedido_total = COUNT(DISTINCT cd_tipo_pedido)

  
from #DiarioPedidoGeral  

 SELECT 
    @soma_uni   = SUM(CASE WHEN cd_unidade_medida = 1  THEN qt_item_pedido_venda  ELSE 0 END),
    @soma_cx    = SUM(CASE WHEN cd_unidade_medida = 2  THEN qt_item_pedido_venda  ELSE 0 END), 
    @soma_pc    = SUM(CASE WHEN cd_unidade_medida = 12 THEN qt_item_pedido_venda  ELSE 0 END), 
    @soma_pt    = SUM(CASE WHEN cd_unidade_medida = 13 THEN qt_item_pedido_venda  ELSE 0 END), 
    @soma_rl    = SUM(CASE WHEN cd_unidade_medida = 14 THEN qt_item_pedido_venda  ELSE 0 END), 
    @soma_un    = SUM(CASE WHEN cd_unidade_medida = 15 THEN qt_item_pedido_venda  ELSE 0 END), 
    @soma_min   = SUM(CASE WHEN cd_unidade_medida = 27 THEN qt_item_pedido_venda  ELSE 0 END), 
    @soma_pack  = SUM(CASE WHEN cd_unidade_medida = 28 THEN qt_item_pedido_venda  ELSE 0 END), 
	@soma_pct   = SUM(CASE WHEN cd_unidade_medida = 29 THEN qt_item_pedido_venda  ELSE 0 END), 
    @soma_kg    = SUM(CASE WHEN cd_unidade_medida = 30 THEN qt_item_pedido_venda  ELSE 0 END) 
	
from #DiarioPedidoGeral
--select @soma_uni,@soma_cx 

--select * from unidade_medida 
--------------------------------------------------------------------------------------------------------------  
set @html_geral = '   
    <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 25%;"> '+isnull(+@titulo,'')+' </p>  
    </div>  
 <div>  
    <table>  
      <tr class="tamanho">  
		   <th>Grup Cliente</th>  
           <th>Vendedor</th>  
		   <th>Razão Social</th>  
		   <th>CNPJ</th>  
		   <th>Cliente</th>  
		   <th>Endereço</th>  
		   <th>UF</th>  
		   <th>Cidade</th>  
		   <th>Produto</th>  
		   <th>Código</th>
		   <th>Data</th>  
		   <th>Quantidade</th>  
		   <th>Unitário</th>  
		   <th>Total</th>  
		   <th>Tipo Pedido</th>  
        </tr>'  
  
          
--------------------------------------------------------------------------------------------------------------  
DECLARE @id int = 0   
  
WHILE EXISTS (SELECT TOP 1 cd_controle FROM #DiarioPedidoGeral)  
BEGIN  
    SELECT TOP 1  
        @id                          = cd_controle,  
        @html_geral = @html_geral +  
			'<tr class="tamanho">  
               <td>'+isnull(nm_cliente_grupo,'')+'</td>  
               <td>'+isnull(nm_fantasia_vendedor,'')+' ('+cast(isnull(cd_vendedor,'') as nvarchar(10))+')</td>  
			   <td>'+isnull(nm_razao_social_cliente,'')+'</td>
			   <td>'+isnull(cd_cnpj_cliente,'')+'</td>
			   <td>'+isnull(nm_fantasia_cliente,'')+' ('+cast(isnull(cd_cliente,'') as nvarchar(10))+')</td>   
			   <td>'+isnull(nm_endereco_cliente,'')+'</td> 
			   <td>'+isnull(sg_estado,'') +'</td>  
			   <td>'+isnull(nm_cidade,'') +'</td>  
			   <td>'+isnull(nm_produto_pedido,'')+'</td> 
			   <td style="text-align: center;">'+cast(isnull(cd_pedido_venda,'') as nvarchar(20))+' </td>
			   <td style="text-align: center;">'+isnull(dt_pedido_venda,'')+' </td>
			   <td style="text-align: center;">'+cast(isnull(qt_item_pedido_venda,'') as nvarchar(20))+' '+isnull(sg_unidade_medida,'')+'</td>
			   <td style="text-align: center;">'+cast(isnull(dbo.fn_formata_valor(vl_unitario_item_pedido),'') as nvarchar(10))+'</td>
			   <td style="text-align: center;"> '+cast(isnull(dbo.fn_formata_valor(vl_total_item),'') as nvarchar(10))+'</td>
			   <td>'+isnull(nm_tipo_pedido,'')+'</td>  
			 </tr>'  
	FROM #DiarioPedidoGeral  
    DELETE FROM #DiarioPedidoGeral WHERE cd_controle = @id  
END  
--------------------------------------------------------------------------------------------------------------------  
  
  
  
  
set @html_rodape =  
     '		<tr  class="tamanho"style="text-align: center;">  
               <td><b>Total</td>  
               <td><b>'+cast(ISNULL(@vl_total_vendedor,'')as nvarchar(20))+'</td>    
			   <td></td>  
			   <td></td>  
			   <td><b>'+cast(ISNULL(@vl_total_cliente,'')as nvarchar(20))+'</td>     
			   <td></td>  
			   <td></td>  
			   <td></td>  
			   <td></td>  
			   <td><b>'+cast(ISNULL(@vl_total_pedido,'')as nvarchar(20))+'</td>  
			   <td></td> 
			   <td>'+cast(ISNULL(@vl_total_cx,'')as nvarchar(20))+'</td>  
			   <td></td>  
			   <td><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_nota),0) as nvarchar(20))+'</td>  
			   <td><b>'+cast(ISNULL(@tipo_pedido_total,'')as nvarchar(20))+'</td> 
			 </tr> 
	</table>  
  <div class="section-title" style="font-size:15px">
	<p><b>Quanidade Total</b></p>
    <p>'+case when isnull(@soma_uni,0) <> 0 then 'Unidade: '+cast(ISNULL(@soma_uni,'')as nvarchar(20))+'' else '' end +'</p>
	<p>'+case when isnull(@soma_cx,0)  <> 0 then 'CX: '+cast(ISNULL(@soma_cx,'')as nvarchar(20))+'' else '' end +'</p>
	<p>'+case when isnull(@soma_pc,0)  <> 0 then 'PC: '+cast(ISNULL(@soma_pc,'')as nvarchar(20))+'' else '' end +'</p>
	<p>'+case when isnull(@soma_pt,0)  <> 0 then 'PT: '+cast(ISNULL(@soma_uni,'')as nvarchar(20))+'' else '' end +'</p>
	<p>'+case when isnull(@soma_rl,0)  <> 0 then 'RL: '+cast(ISNULL(@soma_rl,'')as nvarchar(20))+'' else '' end +'</p>
	<p>'+case when isnull(@soma_un,0)  <> 0 then 'UN: '+cast(ISNULL(@soma_un,'')as nvarchar(20))+'' else '' end +'</p>
	<p>'+case when isnull(@soma_min,0) <> 0 then 'Minutos: '+cast(ISNULL(@soma_min,'')as nvarchar(20))+'' else '' end +'</p>
	<p>'+case when isnull(@soma_pack,0)<> 0 then 'Pack: '+cast(ISNULL(@soma_pack,'')as nvarchar(20))+'' else '' end +'</p>
	<p>'+case when isnull(@soma_pct,0) <> 0 then 'PCT: '+cast(ISNULL(@soma_pct,'')as nvarchar(20))+'' else '' end +'</p>
	<p>'+case when isnull(@soma_kg,0)  <> 0 then 'KG: '+cast(ISNULL(@soma_kg,'')as nvarchar(20))+'' else '' end +'</p>

  </div>
 
 <div class="report-date-time">  
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>  
  
    </div>  

  
    </body>  
   </html>'  
 --  		            <button id="salva">Salvar</button>
 --<script>  
 --           document.querySelector("#salva").addEventListener("click", () => {  
 --               const botaoSalvar = document.querySelector("#salva");  
 --               botaoSalvar.classList.add("nao-imprimir");  
  
 --               const conteudoHtml = document.querySelector("#conteudo");  
 --               const options = {  
 --                   margin: 0,  
 --                   filename: "'+isnull(@titulo,'')+'.pdf",  
 --                   image: { type: "jpeg", quality: 0.98 },  
 --                   html2canvas: {  
 --                       scale: 2,  
 --                       scrollX: 0,  
 --                       scrollY: 0,  
 --                       windowWidth: document.body.scrollWidth,  
 --                       windowHeight: document.body.scrollHeight,  
 --                       useCORS: true  
 --                   },  
 --                   jsPDF: { unit: "mm", format: "a4", orientation: "landscape" },  
 --               };  
  
 --               html2pdf()  
 --                   .set(options)  
 --                   .from(conteudoHtml)  
 --                   .save()  
 --                   .then(() => {  
 --                       botaoSalvar.classList.remove("nao-imprimir");   
 --                   });  
 --           });  
 --       </script>   
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

--exec pr_egis_relatorio_pedido_geral 280,0,''