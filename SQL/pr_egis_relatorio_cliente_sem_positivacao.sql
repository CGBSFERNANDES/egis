IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_cliente_sem_positivacao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_cliente_sem_positivacao

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_cliente_sem_positivacao  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_cliente_sem_positivacao  
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
create procedure pr_egis_relatorio_cliente_sem_positivacao
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
  
--Dados do Relat�rio---------------------------------------------------------------------------------  
  
     declare  
   @titulo                     varchar(200),  
   @logo                       varchar(400),     
   @nm_cor_empresa             varchar(20),  
   @nm_endereco_empresa        varchar(200) = '',  
   @cd_telefone_empresa        varchar(200) = '',  
   @nm_email_internet          varchar(200) = '',  
   @nm_cidade                  varchar(200) = '',  
   @sg_estado                  varchar(10)  = '',  
   @nm_fantasia_empresa        varchar(200) = '',  
   @numero                     int = 0,    
   @cd_cep_empresa             varchar(20) = '',  
   @cd_numero_endereco         varchar(20) = '',  
   @footerTitle                varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais                    int = 0,  
   @nm_pais                    varchar(20) = '',  
   @cd_cnpj_empresa            varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet        varchar(200) = '', 
   @cd_grupo_relatorio         int  = 0,
   @cd_vendedor                int =0
  
  set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)  
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
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'  
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
  
   set @cd_documento = isnull(@cd_documento,0)  
  
   if @cd_documento = 0  
   begin  
     select @cd_documento           = valor from #json where campo = 'cd_documento'  
  
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
  @cd_vendedor            = cd_vendedor
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

---------------------------------------------------------------------------------------------------------------------------------------------  
  
--Cabe�alho da Empresa
  
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
            font-size: 18px;  
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
	    .quadrado{
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 150px;
            border: 1px solid;
            padding: 20px;
			margin-bottom:20px;
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
--Set @dt_inicial = '04/01/2024'
--set @dt_final = '04/30/2025'

--set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)
--set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano)

-------------------------------------------------------------------------------------------------------------------------
  declare @dt_base  datetime
  declare @dt_atual datetime
  
  set @dt_base=@dt_final
  Select
    @dt_atual = DateAdd(day, 1, @dt_base)

 

------------------------------------------------------------------------------------------------------------------------- 
 select
  ns.cd_vendedor,
  count(distinct ns.cd_cliente) as qt_faturado,
  count(ns.cd_nota_saida)       as qt_nota
into
  #ClienteFaturadoRel

from
  nota_saida ns
where
  ns.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then ns.cd_vendedor else isnull(@cd_vendedor,0) end
  and
  ns.dt_nota_saida between @dt_inicial and @dt_final
  and
  ns.cd_status_nota<>7
group by
  ns.cd_vendedor

select
  identity(int,1,1)                                                                                                                         as cd_controle,
  v.cd_vendedor,
  v.nm_fantasia_vendedor,
  v.vl_meta,
  ( select count(c.cd_cliente) from cliente c   where c.cd_vendedor  = v.cd_vendedor and cd_status_cliente = 1 )                            as qt_cliente,
  ( select count(vi.cd_visita)  from visita vi  where vi.cd_vendedor = v.cd_vendedor and vi.dt_visita between @dt_inicial and @dt_final )   as qt_visita,
  cast(qt_faturado as int)                                                                                                                  as qt_faturado,
  --qt_cliente - isnull(qt_faturado,0)                                                                                                        as qt_falta,
  cf.qt_nota,
  isnull(mvp.pc_meta_positivacao_cliente,0) as pc_meta_positivacao_cliente

into #ExtratoVendedorRel
from
  vendedor v
  left outer join #ClienteFaturadoRel cf       on cf.cd_vendedor  = v.cd_vendedor
  left outer join Meta_Vendedor_Periodo mvp on mvp.cd_vendedor = v.cd_vendedor and mvp.dt_inicial_validade_meta = @dt_inicial and mvp.dt_final_validade_meta = @dt_final


where
  v.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then v.cd_vendedor else isnull(@cd_vendedor,0) end
  and
  isnull(v.ic_ativo,'N') = 'S'

order by
  
   v.nm_fantasia_vendedor

   --select * from vendedor
   	 	
	--select @dt_inicial, @dt_final

  --Pegando os clientes que compraram no mês Vigente----------------------------------------------------------------------------------------

  select
    distinct
    c.cd_cliente,
	--( select MAX(pv.dt_pedido_venda) from Pedido_Venda pv where pv.cd_cliente = c.cd_cliente ) as dt_pedido_venda,

	( select MAX(pv.dt_pedido_venda) from Pedido_Venda pv
	  inner join Tipo_Pedido tp on tp.cd_tipo_pedido = pv.cd_tipo_pedido  	     
	    
	where pv.cd_cliente = c.cd_cliente
	and
	ISNULL(tp.ic_gera_bi,'S') = 'S')
	                                                                                           as dt_pedido_venda,

	count(distinct c.cd_cliente )                                                              as qt_falta_positivar

  into
    #cliente_sem_pedidoRel

  from
    Cliente c    
    inner join status_cliente sc on sc.cd_status_cliente = c.cd_status_cliente


  where
    c.cd_cliente not in  ( select pv.cd_cliente from pedido_venda pv
	                       inner join Pedido_Venda_Item i on i.cd_pedido_venda = pv.cd_pedido_venda
						   inner join Tipo_Pedido tp      on tp.cd_tipo_pedido = pv.cd_tipo_pedido
						   where
						    pv.cd_cliente = c.cd_cliente
							and
						    pv.dt_pedido_venda between @dt_inicial and @dt_final
							and
	                        i.dt_cancelamento_item is null 
							and							
                            ISNULL(tp.ic_gera_bi,'S') = 'S'
  						)
    and
    isnull(sc.ic_analise_status_cliente,'N')='S'
	and
	c.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then c.cd_vendedor else isnull(@cd_vendedor,0) end

  group by
    c.cd_cliente

--Atraso

    select
      dr.cd_cliente,
      cast(str(sum(isnull(dr.vl_saldo_documento,0) - isnull(dr.vl_abatimento_documento,0)  ),25,2) as float) as vl_total_atraso
    into #AtrasoRel

    from	  
      Documento_Receber dr with (nolock) --on dr.cd_cliente = p.cd_cliente
	  WHERE
	     dr.dt_vencimento_documento < @dt_hoje
		 and
	     dr.dt_cancelamento_documento is null
		 and
		 dr.dt_devolucao_documento is null
		 and
		 dr.cd_cliente in ( select cd_cliente from #cliente_sem_pedidoRel)

    group by
      dr.cd_cliente
	  	   	   
--    select *  from #Cliente_sem_pedido
--return

--select * from status_pedido



  -- Pegando todos os Clientes com compras por Vendedor, que não compram mais-----------------------------------------------------------------

  Select 
    identity(int,1,1)                                              as cd_controle,
    a.cd_cliente                                                   as 'cliente',

	--a.cd_vendedor,
    max(a.dt_pedido_venda)                                         as UltimaCompra,
    sum( ISNULL(vl_total_pedido_ipi,0))                            as 'Total_Geral',
    isnull((
    select sum( vl_total_consulta)                                 as 'vl_total_proposta'
    from
      consulta c 
    where
      c.cd_cliente = c.cd_cliente      
   
    ),0)                                                            as 'TotalProposta',

     --Volume-------------------------------------------------------------------------------------------------
     sum(isnull(p.qt_volume_produto,1) * b.qt_item_pedido_venda )   as 'Volume'

  into 
    #PedidoRel

  from
    Pedido_Venda a                 with (nolock)
    inner join Pedido_Venda_Item b with (nolock) on b.cd_pedido_venda    = a.cd_pedido_venda
    left outer join Cliente c           with (nolock) on a.cd_cliente         = c.cd_cliente
    left outer join status_cliente sc                 on sc.cd_status_cliente = c.cd_status_cliente
    left outer join produto p      with (nolock) on p.cd_produto         = b.cd_produto


	inner join Tipo_Pedido tp      with (nolock) on tp.cd_tipo_pedido    = a.cd_tipo_pedido

  where
    a.dt_pedido_venda between @dt_inicial and @dt_final
	and
    IsNull(a.dt_cancelamento_pedido, @dt_atual) > @dt_base  and
    isnull(a.ic_consignacao_pedido,'N') = 'N'               and
    IsNull(c.cd_vendedor,0) = ( case isnull(@cd_vendedor,0) 
                                  when 0 then 
                                    IsNull(c.cd_vendedor,0)
                                  else 
                                    isnull(@cd_vendedor,0)
                                end )                      and
    b.dt_cancelamento_item is null
    --and c.cd_cliente  in ( select x.cd_cliente from #cliente_sem_pedidoRel x where x.cd_cliente = c.cd_cliente )
    and
    isnull(sc.ic_analise_status_cliente,'N')='S'
    and							
    ISNULL(tp.ic_gera_bi,'S') = 'S'

    group by 
       a.cd_cliente


  having
    max(a.dt_pedido_venda) < @dt_base


  order  by 1 desc

  --select * from #Pedido

  --select * from #Pedido



--select * from consulta_itens

----------------------------------
-- Fim da seleção de vendas totais
----------------------------------

declare @qt_total_grupo int
declare @vl_total_grupo float
declare @qt_total       int = 0
declare @qt_faturado    int = 0
declare @pc_positivacao decimal(25,2) = 0.00
declare @qt_falta_positivar int = 0

-- Total de Grupos
set @qt_total_grupo = @@rowcount

-- Total de Vendas Geral por Grupo
set    @vl_total_grupo     = 0

  select
    @qt_total    = sum(qt_cliente),
	@qt_faturado = sum(qt_faturado)
  from
    #ExtratoVendedorRel

  if @qt_total>0
     set @pc_positivacao = round(cast(@qt_faturado as decimal(25,2)) / cast(@qt_total as decimal(25,2)) * 100,0)

	 --select @qt_total, @qt_faturado, @pc_positivacao

Select 
  @qt_falta_positivar = SUM(qt_falta_positivar)

from
  #cliente_sem_pedidoRel


Select 
  @vl_total_grupo = Sum(Volume)
from
  #PedidoRel

set @vl_total_grupo = isnull(@vl_total_grupo,0)

select 
  isnull(a.cd_controle,b.cd_cliente)                             as cd_controle,
  c.cd_vendedor,
  c.nm_fantasia_vendedor                                         as nm_fantasia_vendedor,
  b.nm_fantasia_cliente                                          as nm_fantasia_cliente,
  b.nm_razao_social_cliente,
  '( ' + b.cd_ddd + ') ' + b.cd_telefone                         as 'Telefone',
  ltrim(rtrim(isnull(b.nm_fantasia_cliente,'')))
  +
  ' ('+CAST(b.cd_cliente as varchar(9))+' )'                     as 'caption',
 
  case when cs.dt_pedido_venda is not null then
    convert(varchar,cs.dt_pedido_venda,103)
  
  else
    convert(varchar,a.UltimaCompra,103)
  end                                                            as resultado,
  'Total Vendas : R$ '+dbo.fn_formata_valor(Total_Geral)         as 'subcaption1',
  c.nm_fantasia_vendedor                                         as 'badgeCaption',
  'red'                                                          as 'iconColorFooter1',
  'account-circle'                                               as 'iconFooter1',
  ltrim(rtrim(isnull(gcc.nm_grupo_categ_cliente,'')))+
  '/'+ltrim(rtrim(isnull(cc.nm_categoria_cliente,''))) +case when isnull(@cd_vendedor,0) = 0 then  '-'+ltrim(rtrim(c.nm_fantasia_vendedor))  else '' end                                
                                                                 as 'smallCaptionLeft',  
    '(' + ltrim(rtrim(b.cd_ddd)) + ') ' + b.cd_telefone + ' - '+
  ( select top 1 nm_fantasia_contato from Cliente_Contato with (nolock) where cd_cliente = a.cliente) as 'quantidade',       
  ( select top 1 nm_fantasia_contato from Cliente_Contato with (nolock) where cd_cliente = a.cliente) as 'Contato',       
  '( ' + b.cd_ddd + ') ' + b.cd_telefone + ' - '+
  ( select top 1 nm_fantasia_contato from Cliente_Contato with (nolock) where cd_cliente = a.cliente) as 'FoneContato',       

  a.UltimaCompra as UltimaCompra,
  a.Total_Geral,
  a.Volume,
  a.TotalProposta,
  case when @vl_total_grupo>0 then 
  cast((a.Volume/@vl_total_grupo)*100 as Decimal(25,4))
  else
   0.00
  end                                                                                                                     as 'Perc',
  (Select top 1 nm_status_cliente from Status_cliente d with (nolock) where d.cd_status_cliente = b.cd_status_cliente ) as 'Status',

  (Select top 1 nm_pais           from Pais p           with (nolock) where p.cd_pais = b.cd_pais) as Pais,
  a.cliente          as cd_cliente,
  isnull(ra.nm_ramo_atividade,'')          as nm_ramo_atividade,
  isnull(cv.nm_criterio_visita,'')         as nm_criterio_visita,
  isnull(cg.nm_cliente_grupo,'')           as nm_cliente_grupo,
  isnull(ci.ic_credito_suspenso,'N')       as ic_credito_suspenso,
  isnull(ci.ic_alerta_credito_cliente,'N') as ic_alerta_credito_cliente,
--  ltrim(rtrim(c.nm_fantasia_vendedor)) + '-' + ra.nm_ramo_atividade as 'VendedorRamo',
  isnull(gcc.nm_grupo_categ_cliente,'')                             as 'Canal',
  isnull(cc.nm_categoria_cliente,'')                                as 'Segmento',
  ltrim(rtrim(isnull(gcc.nm_grupo_categ_cliente,'')))+
  ' / '+ltrim(rtrim(isnull(cc.nm_categoria_cliente,''))) +case when isnull(@cd_vendedor,0) = 0 then  '-'+ltrim(rtrim(c.nm_fantasia_vendedor))  else '' end                                
                                                                    as VendedorRamo,
																	
  --Totais

     	    cast( cast(@qt_total as int) as varchar(10))           as titleHeader,

		case when ISNULL(@qt_falta_positivar,0)>0 
		  then
		  CAST(@qt_falta_positivar as varchar(20)) 
         else  
		  CAST('' as varchar(2))
		 end as falta_positivar,
		 
		 cast(cast(@qt_faturado as int) as varchar(10)) + ' - '+ cast(@pc_positivacao as varchar(10))+' (%) ' as subtitle2Header,
		
		 dbo.fn_data_string(@dt_inicial) +' à '+dbo.fn_data_string(@dt_final) as subtitle3Header
	     --'Positivação: '+dbo.fn_formata_valor( round(cast(qt_faturado as decimal(25,2))/ cast(qt_cliente as decimal(25,2))*100, 2)) + ' (%)' 
	       --                                                             as 'percentual'



into
#resultFinalPositivacao
 
from
   Cliente b
   left outer join #cliente_sem_pedidoRel cs              with (nolock) on cs.cd_cliente                = b.cd_cliente
    left outer join #PedidoRel a                     with (nolock) on b.cd_cliente                = a.cliente
	left outer join #AtrasoRel atr                   with (nolock) on atr.cd_cliente              = cs.cd_cliente
    --inner join Cliente b                          with (nolock) on b.cd_cliente                = a.cliente
    left outer join Vendedor c                       with (nolock) on c.cd_vendedor               = b.cd_vendedor
    left outer join Ramo_Atividade ra                with (nolock) on ra.cd_ramo_atividade        = b.cd_ramo_atividade 
    left outer join Criterio_Visita cv               with (nolock) on cv.cd_criterio_visita       = b.cd_criterio_visita
    left outer join Cliente_Grupo cg                 with (nolock) on cg.cd_cliente_grupo         = b.cd_cliente_grupo
    left outer join Cliente_Informacao_Credito ci    with (nolock) on ci.cd_cliente               = b.cd_cliente
    left outer join Categoria_Cliente cc             with (nolock) on cc.cd_categoria_cliente     = b.cd_categoria_cliente
    left outer join Grupo_Categoria_Cliente gcc      with (nolock) on gcc.cd_grupo_categ_cliente  = cc.cd_grupo_categoria_cli
    inner join status_cliente sc                                   on sc.cd_status_cliente        = b.cd_status_cliente
    left outer join #ExtratoVendedorRel e            with (nolock) on e.cd_vendedor               = c.cd_vendedor

where
  isnull(sc.ic_analise_status_cliente,'N')='S' --Ativo
  and
  a.UltimaCompra between @dt_inicial and @dt_final
  and
  b.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then b.cd_vendedor else isnull(@cd_vendedor,0) end
  and
  ISNULL(c.ic_egismob_vendedor,'S') = 'S'

order by 
  UltimaCompra, a.Volume desc

  
--------------------------------------------------------------------------------------------------------------------------  

 if isnull(@cd_parametro,0) = 1    
 begin    
    select * from #resultFinalPositivacao    
  return    
 end    
  
--------------------------------------------------------------------------------------------------------------------------
declare 
	@vl_total_clientes  nvarchar(50),
	@vl_positivado      nvarchar(50),
	@vl_falta_positivar nvarchar(50),
	@periodo            nvarchar(50)

select 
	@vl_total_clientes  = titleHeader,
	@vl_positivado      = subtitle2Header,
	@vl_falta_positivar = falta_positivar,
	@periodo            = subtitle3Header
from #resultFinalPositivacao
--------------------------------------------------------------------------------------------------------------  
set @html_geral = '   
    <div class="section-title">   
        <p style="text-align: center;"> '+isnull(+@titulo,'')+'</p>  
    </div>  
    <div class="quadrado">
	   <p>Total de Clientes: '+isnull(@vl_total_clientes,0) +'</p>
	   <p>Falta Positivar: '+isnull(@vl_falta_positivar,0) +'</p>
	   <p>Positivado: '+isnull(@vl_positivado,0) +'</p>
	   <p>Periodo: '+isnull(@periodo,0) +'</p>
   </div>
   <table>  
      <tr class="tamanho">  
        <th>Cliente</th>
        <th>Código</th>
        <th>Última Compra</th>
        <th>Vendedor</th>
		<th>Grupo/Vendedor</th>
      </tr>'  
  
          
--------------------------------------------------------------------------------------------------------------  
DECLARE @id int = 0   
  
WHILE EXISTS (SELECT TOP 1 cd_controle FROM #resultFinalPositivacao)  
BEGIN  
    SELECT TOP 1  
        @id                          = cd_controle,  
        @html_geral = @html_geral +  
			'<tr class="tamanho">  
				<td>'+ISNULL(nm_fantasia_cliente,'')+'</td>
				<td>'+cast(isnull(cd_controle,'') as nvarchar(20))+'</td>
				<td>'+isnull(resultado,'')+'</td>
				<td>'+isnull(nm_fantasia_vendedor,'')+'</td>
				<td>'+isnull(vendedorRamo,'')+'</td>
			 </tr>'  
	
	FROM 
	  #resultFinalPositivacao  
    DELETE FROM #resultFinalPositivacao WHERE cd_controle = @id  
END  
--------------------------------------------------------------------------------------------------------------------  
  
  
  
  
set @html_rodape =  
  '
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
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
  
go 

--exec pr_egis_relatorio_cliente_sem_positivacao 305,0,''