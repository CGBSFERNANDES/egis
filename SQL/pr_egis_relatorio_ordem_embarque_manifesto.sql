IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_ordem_embarque_manifesto' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_ordem_embarque_manifesto

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_ordem_embarque  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_ordem_embarque
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
--AlteraÃƒÂ§ÃƒÂ£o        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_ordem_embarque_manifesto 
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
declare @cd_documento           int = 0  
declare @dt_hoje                datetime  
declare @dt_inicial             datetime  
declare @dt_final               datetime  
declare @cd_ano                 int      
declare @cd_mes                 int      
declare @cd_dia                 int  
declare @cd_vendedor            int = 0   
declare @cd_grupo_relatorio     int = 0  
declare @cd_departamento        int = 0 
declare @cd_carga               int = 0  
  
--Dados do Relatorio---------------------------------------------------------------------------------  
  
declare  
   @titulo               varchar(200),  
   @logo                 varchar(400),     
   @nm_cor_empresa       varchar(20),  
   @nm_endereco_empresa  varchar(200) = '',  
   @cd_telefone_empresa  varchar(200) = '',  
   @nm_email_internet    varchar(200) = '',  
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
  select @cd_documento           = Valor from #json where campo = 'cd_documento_form'
  select @cd_carga               = Valor from #json where campo = 'cd_carga'
  
   set @cd_carga = isnull(@cd_carga,0)
  
   if isnull(@cd_carga,0) = 0
   begin  
     select @cd_carga           = valor from #json where campo = 'cd_documento_form'  

	 ------------
     set @cd_carga = isnull(@cd_carga,0)

     if isnull(@cd_carga,0) = 0
     begin  
       select @cd_carga           = valor from #json where campo = 'cd_pedido_venda'  
     
     end  
   end  
end  
  
 --- set @cd_documento = 323202
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
--select    
--  @dt_inicial       = dt_inicial,    
--  @dt_final         = dt_final  
--from     
--  Parametro_Relatorio    
    
--where    
--  cd_relatorio = @cd_relatorio    
--  and    
--  cd_usuario   = @cd_usuario    
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
  @nm_fantasia_empresa     = isnull(e.nm_empresa,''),  
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
--Dados do Relatorio  
---------------------------------------------------------------------------------------------------------------------------------------------  
  
declare @html            nvarchar(max) = '' --Total  
declare @html_empresa    nvarchar(max) = '' --Cabecalho da Empresa  
declare @html_titulo     nvarchar(max) = '' --Titulo  
declare @html_cab_det    nvarchar(max) = '' --Cabecalho do Detalhe  
declare @html_detalhe    nvarchar(max) = '' --Detalhes  
declare @html_rod_det    nvarchar(max) = '' --Rodape do Detalhe  
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
        }

        h2 {
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 3px;
        }

        table,
        th,
        td {
            border: 1px solid #ddd;
            text-align: center;
        }

        th,
        td {
            padding: 1px;
            font-size: 12px;
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
            color: rgb(0, 0, 0);
            padding: 1px;
            margin-bottom: 2px;
            border-radius: 3px;
            font-size: 14px;
            margin-left: 0;
            margin-right: 0;
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
            color: #000102;
        }

        .report-date-time {
            text-align: right;
            margin-bottom: 5px;
            margin-top: 10px;
        }

        p {
            margin: 1px;
            padding: 0;
            font-size: 14px;
        }
        .tamanho {
            font-size: 14px;
            text-align: center;
        }

        .titulo {
            background-color: #808080;
            color: rgb(0, 0,0);
            margin-bottom: 1px;
            border-radius: 5px;
            font-size: 16px;
            margin-left: 0;
            margin-right: 0;
            text-align: center;
        }
		.linha {
            border-bottom: 2px solid black;
         
            margin-bottom: 3px;
        }
		td {
            padding: 1px;
        }

        .quadrado {
            width: 100%;
            height: 25px;
            border: 2px solid black;
            display: flex;
            justify-content: center;
            align-items: center;
            box-sizing: border-box;
            padding: 0;
			margin:0;
			margin-bottom:2px;
        }
		        @media print {
            p {
                margin-left: 10px;}

            .nao-quebrar {
        page-break-inside: avoid;
    }
            
        }
  </style>
</head>  
<body> '  
  
  
--Procedure de Cada Relatorio-------------------------------------------------------------------------------------  
    
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
--set @dt_final   = '02/28/2025'

declare @vl_total         decimal(25,2) = 0.00
declare @qt_total         int = 0
declare @qt_total_produto decimal(25,2) = 0

--declare @cd_carga         int = 0
--set @cd_carga =  17 
--qui

--set @cd_carga = 70
select top 1
  @cd_carga = cd_identificacao
from
  MDFE_Manifesto
where 
  cd_manifesto = @cd_carga
order by 
  cd_manifesto desc

-------------------
-----------------------  
  --set @cd_carga = 4798

  select
    m.cd_manifesto,
	m.cd_identificacao,
	n.cd_vendedor,
	mdc.cd_minuta,
	i.cd_pedido_venda,
	i.cd_item_pedido_venda


   into #Minuta_Manifesto

   from
     MDFE_Manifesto M
     inner join MDFE_Manifesto_Documentos md   on md.cd_manifesto   = m.cd_manifesto
	 inner join minuta_despacho_composicao mdc on mdc.cd_nota_saida = md.cd_nota_saida
	 inner join nota_saida n                   on n.cd_nota_saida   = md.cd_nota_saida
	 inner join nota_saida_item i              on i.cd_nota_saida   = n.cd_nota_saida
   where
     m.cd_identificacao = @cd_carga

     --m.dt_manifesto between @dt_inicial and @dt_final

   group by
    m.cd_manifesto,
	m.cd_identificacao,
	n.cd_vendedor,
	mdc.cd_minuta,
	i.cd_pedido_venda,
	i.cd_item_pedido_venda


	--select * from #Minuta_Manifesto
----


select      
  c.cd_carga                                                   as cd_carga,    
  c.dt_carga,   										       
  c.dt_entrega_carga,    								       
  --cli.nm_fantasia_cliente                                      as nm_fantasia_cliente,  
  v.cd_vendedor                                                as cd_vendedor,  
  v.nm_fantasia_vendedor                                       as nm_fantasia_vendedor,  
  --Tipo de Pedido---                    
  tp.ic_padrao_tipo_pedido                                     as ic_padrao_tipo_pedido,  
  case when tp.ic_padrao_tipo_pedido = 'S'             
    then 'Pedido de Venda'                 
    else case when tp.ic_bonificacao_tipo_pedido = 'S'          
           then 'Bonificação'                
          else 'Troca'                  
         end                    
  end                                                          as nm_tipo_agrupamento,  
  case when tp.ic_padrao_tipo_pedido = 'S'             
    then 1                 
    else case when tp.ic_bonificacao_tipo_pedido = 'S'          
           then 2                
          else 3                 
         end                    
  end                                                          as cd_tipo_agrupamento,
  max(tp.cd_tipo_pedido)                                       as cd_tipo_pedido,  
  max(tp.nm_titulo_tipo_pedido)                                as nm_tipo_pedido,  
  														       
  --Categoria de Produto---------------------------------------------------------------  
  cp.cd_categoria_produto                                      as cd_categoria_produto,  
  max(cp.nm_categoria_produto)                                 as nm_categoria_produto,  
  														       
  p.cd_produto                                                 as cd_produto,    
  p.cd_mascara_produto,    								       
  p.nm_fantasia_produto,    							       
  p.nm_produto                                                 as nm_produto,    
  isnull(g.nm_grupo_localizacao,'')                            as nm_grupo_localizacao,   
  sum(isnull(i.qt_item_pedido_venda,0))                        as qt_produto,
  --sum(isnull(i.qt_saldo_pedido_venda,0))                     as qt_produto,    
  max(isnull(um.sg_unidade_medida,''))                         as sg_unidade_medida,    
--  max(cast('[    ]' as varchar(10)))                         as nm_separado,    
  --max(p.nm_produto)                                          as nm_produto,    
  max(isnull(p.cd_codigo_barra_produto,''))                    as cd_codigo_barra_produto,    
      													       
  max(cast('' as varchar(25)))                                 as nm_lote_produto,    
  --max(isnull(g.nm_grupo_localizacao,''))                     as nm_grupo_localizacao,    
  max(isnull(l.qt_posicao_localizacao,''))                     as qt_posicao_localizacao,  
  isnull(it.nm_itinerario,'')                                  as nm_itinerario,  
  isnull(ve.nm_veiculo,'')                                     as nm_veiculo,  
  isnull(en.nm_entregador,'')                                  as nm_entregado,
  sum((i.vl_unitario_item_pedido * i.qt_item_pedido_venda) +
  ((i.vl_unitario_item_pedido * i.qt_item_pedido_venda)*(i.pc_ipi/100)) +
  i.vl_item_icms_st)                                           as vl_total,
  --max(i.vl_unitario_item_pedido) * max(i.qt_item_pedido_venda) as vl_total,  
  ISNULL(cp.qt_ordem_carga,0)                                  as qt_ordem_carga,
  isnull(p.qt_ordem_carga_produto,0)                           as qt_ordem_carga_produto,
  mm.cd_manifesto
  
  --use egissql_342

    
into    
  #DetalheAtriGrid    
    
from    
  Pedido_Venda_Romaneio r    
  inner join pedido_venda pv                  on pv.cd_pedido_venda      = r.cd_pedido_venda   
  --left outer join cliente cli                 on cli.cd_usuario          = r.cd_usuario  
  inner join Vendedor v                       on v.cd_vendedor           = pv.cd_vendedor  
  inner join tipo_pedido tp                   on tp.cd_tipo_pedido       = pv.cd_tipo_pedido  
  inner join pedido_venda_item i              on i.cd_pedido_venda       = r.cd_pedido_venda    
  inner join produto p                        on p.cd_produto            = i.cd_produto    
  left outer join categoria_produto cp        on cp.cd_categoria_produto = p.cd_categoria_produto  
  inner join unidade_medida um                on um.cd_unidade_medida    = i.cd_unidade_medida    
  inner join Preparacao_Carga c               on c.cd_carga              = r.cd_carga    
  left outer join Produto_Localizacao l       on l.cd_produto            = i.cd_produto and l.cd_fase_produto = i.cd_fase_produto    
  left outer join Produto_Grupo_Localizacao g on g.cd_grupo_localizacao  = l.cd_grupo_localizacao  
  left outer join Itinerario it               on it.cd_itinerario        = c.cd_itinerario  
  left outer join Entregador en               on en.cd_entregador        = c.cd_entregador  
  left outer join Veiculo ve                  on ve.cd_veiculo           = c.cd_veiculo  
  inner join #Minuta_Manifesto mm             on mm.cd_pedido_venda       = r.cd_pedido_venda and mm.cd_item_pedido_venda = i.cd_item_pedido_venda


where    
  mm.cd_identificacao = @cd_carga  
  and    
  i.dt_cancelamento_item is null    
  --Comentado para poder fazer a reimpressÃ£o quando ja faturado
  --and      
  --isnull(i.qt_saldo_pedido_venda,0)>0   
    
	--select * from pedido_venda_romaneio

group by    
  c.cd_carga,    
  c.dt_carga,    
  c.dt_entrega_carga,    
  --tp.cd_tipo_pedido,
  tp.ic_padrao_tipo_pedido,
  tp.ic_bonificacao_tipo_pedido,
  cp.cd_categoria_produto,  
  p.cd_produto,    
  p.cd_mascara_produto,    
  p.nm_fantasia_produto,    
  p.nm_produto,    
  g.nm_grupo_localizacao,    
  it.nm_itinerario,  
  ve.nm_veiculo,  
  en.nm_entregador,  
  --cli.nm_fantasia_cliente,  
  v.nm_fantasia_vendedor,  
  v.cd_vendedor,  
  cp.qt_ordem_carga,
  p.qt_ordem_carga_produto,
  mm.cd_manifesto

order by    
  cp.qt_ordem_carga,
  p.qt_ordem_carga_produto,
  g.nm_grupo_localizacao,    
  p.nm_produto    
 

--select * from #DetalheAtriGrid order by qt_ordem_carga, qt_ordem_carga_produto

--------------------------------------------------------------------------------------------------------------------------  
select   
  identity(int,1,1)   as cd_controle,  
  nm_tipo_agrupamento as nm_tipo_agrupamento  
into  
  #PedidoCabecalho  

from   
  #DetalheAtriGrid  

group by     
  nm_tipo_agrupamento,
  cd_tipo_agrupamento

order by
  cd_tipo_agrupamento

--select * from #PedidoCabecalho order by cd_controle

--------------------------------------------------------------------------------------------------------------------------  

select   
  IDENTITY(int,1,1)                as cd_controle,  
  cd_categoria_produto             as cd_categoria_produto,  
  nm_tipo_agrupamento              as nm_tipo_agrupamento,  
  isnull(qt_ordem_carga,0)         as qt_ordem_carga,  
  --ISNULL(qt_ordem_carga_produto,0) as qt_ordem_carga_produto,
  MAX(nm_categoria_produto)        as nm_categoria_produto,  
  sum(qt_produto)                  as qt_produto,  
  sum(vl_total)                    as vl_total  

into  
  #TipoPedidoRel  

from  
  #DetalheAtriGrid  

group by   
  qt_ordem_carga, 
  --qt_ordem_carga_produto,
  cd_categoria_produto,    
  nm_tipo_agrupamento  

order by
  nm_tipo_agrupamento,
  qt_ordem_carga,
  --qt_ordem_carga_produto,
  cd_categoria_produto
  
--select * from #TipoPedidoRel  order by nm_tipo_agrupamento, qt_ordem_carga
--------------------------------------------------------------------------------------------------------------------------   
   
declare   
 @id                    int = 0,  
 @id_ped_cab            int = 0,  
 @id_grupo              int = 0,   
 @nm_pedido_venda       nvarchar(60),  
 @nm_tipo_agrupamento   varchar(20) = '',   
 @cd_categoria_produto  int = 0,  
 @nm_categoria_produto  nvarchar(60),  
 @cd_carga_rel          int = 0,  
 --@nm_fantasia_cliente   nvarchar(60),  
 @qt_total_cx           float = 0,  
 @vl_total_geral        float = 0,  
 @cd_vendedor_rel       int = 0,  
 @nm_vendedor_rel       nvarchar(60),  
 @nm_motorista          nvarchar(60),  
 @qt_total__geral_cx    float = 0,  
 @vl_total_geral_prod   float = 0,  
 @qt_total_prod         float = 0,   
 @qt_total_pedido       float = 0,
 @vl_total_item         float = 0

--------------------------------------------------------------------------------------------------------------------------    

select    
  Top 1
  @cd_carga_rel          = cd_carga,  
  --@nm_fantasia_cliente   = nm_fantasia_cliente,   
  @nm_tipo_agrupamento   = nm_tipo_agrupamento,  
  @cd_categoria_produto  = isnull(cd_categoria_produto,0),  
  @cd_vendedor_rel       = cd_vendedor,  
  @nm_motorista          = nm_entregado,  
  @nm_vendedor_rel       = nm_fantasia_vendedor  
from    
  #DetalheAtriGrid    
  
select   
  @qt_total__geral_cx         = sum(qt_produto),  
  @vl_total_geral_prod        = sum(vl_total),  
  @qt_total_prod              = COUNT(cd_produto)  
from
  #DetalheAtriGrid  

select
  @qt_total_pedido = count(cd_pedido_venda)
from
  Pedido_Venda_Romaneio r
where
  cd_carga = @cd_carga

----------------------------------------------------------------------------------------------------

select
  IDENTITY(int,1,1)         as cd_controle,
  *
into
  #CategoriaRelDetalhe

from
  #DetalheAtriGrid

order by
  nm_tipo_agrupamento, 
  qt_ordem_carga,
  qt_ordem_carga_produto

--select * from #CategoriaRelDetalhe order by nm_tipo_agrupamento, qt_ordem_carga, qt_ordem_carga_produto

--------------------------------------------------------------------------------------------------------------------------  
set @html_geral = '   
  <div style="display: flex; justify-content: space-between;">  
            <p class="title"><b>'+isnull(@nm_fantasia_empresa,'')+'</b></p>                            
            <p><strong>Ordem de Embarque : </strong> '+CAST(ISNULL(@cd_carga_rel,0) AS nvarchar(20))+' </p>          
         </div>     
     
   <p style="text-align: center;font-size: 16px;" > <b>Ordem de Embarque Manifesto: '+CAST(ISNULL(@cd_carga,0) AS nvarchar(20))+'</b></p>  
  <div class="linha" style="display: flex; justify-content: space-between;">  
    <p><b>Vendedor: '+CAST(ISNULL(@cd_vendedor_rel,0) AS nvarchar(20))+' '+isnull(@nm_vendedor_rel,'')+'</b></p>     
    <p><b>Motorista: '+isnull(@nm_motorista,'')+'</b></p>    
  </div>'  
------------------------------------------------------------------------------------------------------------------------------------------------      

--select * from #PedidoCabecalho

declare @qt_ordem_carga int = 0


while exists (select top 1 cd_controle from #PedidoCabecalho)   
 begin   
  select top 1  
    @id_ped_cab              = cd_controle,  
    @nm_tipo_agrupamento  = nm_tipo_agrupamento
  from #PedidoCabecalho  
  order by
    cd_controle

set @html_cab_det = @html_cab_det + '<p class="titulo"><b> Tipo de Pedido: '+ case when isnull(@id_ped_cab,0) >  0 then ''+ISNULL(@nm_tipo_agrupamento,'')+'' else '' end +'</b></p>  
             <div>  
              <div class="linha">  
              <tr class="tamanho" style="display: flex; flex-direction: column;color: #000000;">  
              <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">  
              <p class="tamanho" style="width:5%"><b>CÓDIGO</b></p>  
              <p class="tamanho" style="width:61%"><b>DESCRIÇÃO</b></p>  
              <p class="tamanho" style="width:7%"><b>QTD.</b></p>  
              <p class="tamanho" style="width:7%"><b>TOTAL</b></p>  
              <p class="tamanho" style="width:10%"><b>EMP</b></p>  
              <p class="tamanho" style="width:10%"><b>LOG</b></p>  
             </tr>  
            </div>  
           </div>'               
                      
--------------------------------------------------------------------------------------------------------------   
  
while exists( select Top 1 cd_controle from #TipoPedidoRel where @nm_tipo_agrupamento = nm_tipo_agrupamento 
              order by
			    nm_tipo_agrupamento, qt_ordem_carga)  
  begin  
  
  select Top 1  
   @id_grupo             = cd_controle,  
   @qt_ordem_carga       = qt_ordem_carga,
   @cd_categoria_produto = cd_categoria_produto,  
   @nm_categoria_produto = nm_categoria_produto,  
   @qt_total_cx          = qt_produto,  
   @vl_total_geral       = vl_total  

  from #TipoPedidoRel   
  where 
    nm_tipo_agrupamento = @nm_tipo_agrupamento  --and qt_ordem_carga = @qt_ordem_carga

  order by
    nm_tipo_agrupamento, qt_ordem_carga

  
-- Verifica se a categoria atual tem itens antes de gerar HTML
if exists (
    select 1
    from #CategoriaRelDetalhe
    where cd_categoria_produto = @cd_categoria_produto
      and qt_ordem_carga = @qt_ordem_carga
      and nm_tipo_agrupamento = @nm_tipo_agrupamento
)
begin
  set @html_cab_det = @html_cab_det + '
   <div>
     <p style="font-size: 18px;margin-bottom:6px;margin-left: 76px;"><strong>' + isnull(@nm_categoria_produto, '') + '</strong></p>
   </div>      
   <div class="linha">'

  while exists (
      select top 1 cd_controle
      from #CategoriaRelDetalhe 
      where isnull(cd_categoria_produto,0) = isnull(@cd_categoria_produto,0) 
        and ISNULL(qt_ordem_carga,0) = @qt_ordem_carga
        and nm_tipo_agrupamento = @nm_tipo_agrupamento
  )
  begin
    select           
      @id             = cd_controle,  
      @vl_total_item  = @vl_total_item + vl_total,

      @html_cab_det   = @html_cab_det  + '  
        <tr class="tamanho" style="display: flex; flex-direction: column;color: #000000;">  
          <div class="nao-quebrar" style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">                    
            <p class="tamanho" style="width: 5%;">'+CAST(isnull(cd_produto,'')as nvarchar(20))+'</p>  
            <p class="tamanho" style="text-align: left;width: 59%;">'+isnull(nm_produto,'')+'</p>   
            <p class="tamanho" style="width: 8%;">'+CAST(isnull(qt_produto,'')as nvarchar(20))+' '+isnull(sg_unidade_medida,'')+'</p>  
            <p class="tamanho" style="width: 8%;">'+CAST(isnull(dbo.fn_formata_valor(vl_total),'')as nvarchar(20))+'</p>   
            <p class="quadrado" style="width: 10%;"><div></div></p>  
            <p class="quadrado" style="width: 10%;"><div></div></p>  
          </div>  
        '

    from #CategoriaRelDetalhe  
    where
      isnull(cd_categoria_produto,0) = isnull(@cd_categoria_produto,0) 
      and isnull(qt_ordem_carga,0) = isnull(@qt_ordem_carga,0) 
      and nm_tipo_agrupamento = @nm_tipo_agrupamento  

    delete from #CategoriaRelDetalhe  
    where
      isnull(cd_categoria_produto,0) = isnull(@cd_categoria_produto,0) 
      and isnull(qt_ordem_carga,0) = isnull(@qt_ordem_carga,0) 
      and nm_tipo_agrupamento = @nm_tipo_agrupamento  
  end

  -- Gera rodapÃ© do grupo de produto (total por produto)
  if @vl_total_item > 0
  begin
    set @html_cab_det = @html_cab_det + '  
    </tr>  
    <tr>  
      <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">       
        <p class="tamanho" style="width:10%"><b></b></p>  
        <p class="tamanho" style="width:70%"><b>Total por Produto</b></p>  
        <p class="tamanho" style="width:10%"><b>'+cast(ISNULL(@qt_total_cx,0) as nvarchar(20))+'</b></p>      
        <p class="tamanho" style="width:10%"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_item),0) as nvarchar(20))+'</b></p>   
        <p class="tamanho" style="width:12%"><b></b></p>  
        <p class="tamanho" style="width:12%"><b></b></p>  
      </div>  
    </tr>'

    -- limpa variÃ¡vel acumuladora
    set @vl_total_item = 0.00
  end

  -- Fecha o bloco da categoria
  set @html_cab_det = @html_cab_det + '</div></div>'
end

-- Remove categoria processada da fila
delete from #TipoPedidoRel  
where  
  cd_controle = @id_grupo 
  and nm_tipo_agrupamento = @nm_tipo_agrupamento 
  and qt_ordem_carga = @qt_ordem_carga
  

end  

  --CabeÃ§alho --> Tipo de Pedido

  delete from #PedidoCabecalho  
    where  
       cd_controle = @id_ped_cab  


end  
--------------------------------------------------------------------------------------------------------------------    
    
    
    
    
set @html_rodape ='   
    <table style="width: 100%;">    
        <tr>    
          
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">    
                    <div style="text-align: left;">    
                        <p><strong>Total de Produtos:</strong> '+cast(isnull(@qt_total_prod,0)as nvarchar(20))+'</p>     
                    </div>    
                    <div style="text-align: right;">    
                        <p><strong>Total de Pedidos:</strong> '+cast(isnull(@qt_total_pedido,0)as nvarchar(20))+'</p>    
                    </div> 
                    <div style="text-align: right;">    
                        <p><strong>Quantidade Total:</strong> '+cast(isnull(@qt_total__geral_cx,0)as nvarchar(20))+'</p>    
                    </div>         
                    <div style="text-align: right;">    
                        <p><strong>Valor Total:</strong> '+cast(ISNULL(dbo.fn_formata_valor(@vl_total_geral_prod),0)as nvarchar(20))+' </p>    
                    </div>       
                </div>    
              
        </tr>    
    </table>    
    <div class="report-date-time">    
       <p >Gerado em: '+@data_hora_atual+'</p>    
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
   
 
  
GO

--exec pr_egis_relatorio_ordem_embarque_manifesto 236,0,''