IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_positivacao_periodo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_positivacao_periodo

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_positivacao_periodo  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_positivacao_periodo  
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
create procedure pr_egis_relatorio_positivacao_periodo
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
declare @vl_total               decimal(25,2) = 0.00  
declare @qt_total               decimal(25,2) = 0.00
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
--Set @dt_inicial = '06/01/2025'
--set @dt_final = '06/02/2025'
--set @cd_vendedor = 84
--------------------------------------------------------------------------------------------------------------

  set @cd_mes = @cd_mes - 3

  if @cd_mes < 0
  begin
     set @cd_mes = 12 - (@cd_mes*-1)
	 set @cd_ano = @cd_ano - 1
  end
  if isnull(@cd_mes,0) = 0
  begin
    set @cd_mes = 1
  end
  
	
	
	
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  --set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
    
  --select @dt_inicial, @dt_final
 
  select
    c.cd_vendedor,
    COUNT(c.cd_cliente) as qt_base_cliente
  into
    #baseRel
  from
    Cliente c
  where
    c.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then c.cd_vendedor else isnull(@cd_vendedor,0) end
	and
    ISNULL(c.cd_status_cliente,0) = 1
 
   group by
     c.cd_vendedor

select
  c.cd_vendedor,
  COUNT(c.cd_cliente) as qt_base_cliente,
  COUNT(b.cd_bem)     as qt_ativo
--  MONTH(c.dt_cadastro_cliente) as cd_mes_cadastro,
--  YEAR(c.dt_cadastro_cliente)  as cd_ano_cadastro
into
  #AtivoRel
from
  Cliente c
  inner join Bem b on b.cd_cliente = c.cd_cliente
where
  c.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then c.cd_vendedor else isnull(@cd_vendedor,0) end 
  and
  ISNULL(c.cd_status_cliente,0) = 1
 
group by
 c.cd_vendedor
 --SELECT * FROM #AtivoRel
--select * from meta_vendedor_periodo
select
  m.cd_vendedor,
  year(dt_final_validade_meta)  as cd_ano,
  month(dt_final_validade_meta) as cd_mes,
  max(m.vl_meta_vendedor) as vl_meta_vendedor
into #metaVendedorRel

from
  Meta_Vendedor_Periodo m
where
  m.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then m.cd_vendedor else isnull(@cd_vendedor,0) end
  and
  dt_inicial_validade_meta >= @dt_inicial
  and
  dt_final_validade_meta <= @dt_final
group by
  m.cd_vendedor,
  year(m.dt_final_validade_meta),
  month(m.dt_final_validade_meta)

--select * from #metaVendedorRel
 
select 
   identity(int,1,1) as cd_controle,
  --pv.cd_cliente,
  pv.cd_vendedor,
  v.nm_fantasia_vendedor as nm_fantasia_vendedor,
  --c.cd_cnpj_cliente,
 -- c.nm_razao_social_cliente,
  --c.nm_fantasia_cliente,
  max(b.qt_base_cliente)                   as qt_base_cliente,
  count(distinct pv.cd_cliente)            as qt_cliente,
  month(pv.dt_pedido_venda)                as cd_mes,
  year(pv.dt_pedido_venda)                 as cd_ano,
  count(distinct pv.cd_pedido_venda)       as qt_pedido_venda,
  count(distinct i.cd_produto)             as qt_produto,
  max(isnull(pv.vl_total_pedido_ipi,0))    as vl_total_pedido_ipi,
  SUM(isnull(i.qt_item_pedido_venda,0) 
      *
	  isnull(i.vl_unitario_item_pedido,0)) as vl_total_item_pedido,

  max(a.qt_ativo)                          as qt_ativo,
  max(cast(0.00 as decimal(25,2)) )        as pc_venda,
  max(cast(0.00 as decimal(25,2)) )        as pc_atingido,
  MAX(isnull(vl_meta,0))                   as vl_meta,
  MAX(m.nm_mes)                            as nm_mes

into
  #CalculoVendedorRel

from
  pedido_venda pv
  inner join cliente c           on c.cd_cliente      = pv.cd_cliente
  inner join vendedor v          on v.cd_vendedor     = pv.cd_vendedor
  inner join Pedido_Venda_Item i on i.cd_pedido_venda = pv.cd_pedido_venda
  inner join Tipo_Pedido tp      on tp.cd_tipo_pedido = pv.cd_tipo_pedido
  left outer join #baseRel b        on b.cd_vendedor     = pv.cd_vendedor
  left outer join #AtivoRel a       on a.cd_vendedor     = pv.cd_vendedor
  left outer join Mes m          on m.cd_mes          = MONTH(pv.dt_pedido_venda)
 
where
  pv.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then pv.cd_vendedor else isnull(@cd_vendedor,0) end
  and
  pv.dt_pedido_venda between @dt_inicial and @dt_final
  and
  isnull(tp.ic_bonificacao_tipo_pedido,'N') = 'N'
  and
  i.dt_cancelamento_item is null

group by
 -- pv.cd_cliente,
  pv.cd_vendedor,
  v.nm_fantasia_vendedor,
 -- c.nm_fantasia_cliente,
 -- c.cd_cnpj_cliente,
 -- c.nm_razao_social_cliente,
  month(pv.dt_pedido_venda),                
  year(pv.dt_pedido_venda)                 
 -- SELECT * FROM #CalculoVendedorRel
  declare @vl_meta decimal(25,2) = 0.00
  --select  *  from #CalculoVendedorRel
select
  @vl_total = SUM(vl_total_item_pedido),
  @vl_meta  = MAX(vl_meta),
  @qt_total = sum(qt_cliente)

from
  #CalculoVendedorRel
 
update
  #CalculoVendedorRel
set
  pc_venda    = round(vl_total_item_pedido / case when @vl_total>0 then @vl_total else 1 end * 100,2),
  pc_atingido = (round(vl_total_item_pedido / case when vl_meta>0 then vl_meta else 1 end * 100,2))

--  cd_vendedor,nm_fantasia_cliente, cd_ano desc, cd_mes desc

  --select cv.* from #CalculoVendedor cv
  --left outer join Vendedor v on v.cd_vendedor = cv.cd_vendedor
  --order by
  --cv.cd_vendedor, cv.cd_ano desc, cv.cd_mes desc

--select * from   #CalculoVendedor


--drop table #base
--drop table #CalculoVendedor


   --order by
--select * from #CalculoVendedorRel
      
	  
  
      select   
    cd_controle,  
  
      --'S'                                                             as 'SingleDate',  
   'S'                                                                  as 'MultipleDate',  
   'currency-usd'                                                       as 'iconHeader',     
   CAST(cv.cd_ano as varchar(20))                                       as cd_ano,
   nm_mes															    as mes,	
    CAST(cv.cd_ano as varchar(20)) + ' - '+nm_mes                           as 'caption',
   --cast(qt_nota as varchar)
  CAST(cv.cd_controle as varchar(20))                                      as 'badgeCaption',
  dbo.fn_formata_valor(cv.vl_total_item_pedido)               as 'resultado',  
  case when isnull(@cd_vendedor,0) = 0 then
   cv.nm_fantasia_vendedor
  else
   cast('' as varchar(1))
  end                                                                   as 'resultado1',  
    case when ISNULL(m.vl_meta_vendedor,0)>0 then
   dbo.fn_formata_valor(m.vl_meta_vendedor) + 
   '  -  (%) ' + dbo.fn_formata_valor(pc_atingido)
   else
   dbo.fn_formata_valor(cv.vl_meta) +
   '  -  (%) ' + dbo.fn_formata_valor(pc_atingido)
   end                                                                  as 'subcaption1',  
         
   CAST(qt_pedido_venda as varchar(20))                    as 'resultado2',
   CAST(qt_produto as varchar(9))                          as 'resultado3',
   CAST(qt_cliente as varchar(9))                          as 'resultado4',
   CAST(qt_ativo as varchar(9))                            as 'resultado5',
    dbo.fn_formata_valor(@vl_total)                        as 'titleHeader',  
   cast (qt_base_cliente as varchar(20))                   as Base,                  
   CAST(@qt_total as varchar(20))                          as 'subtitle2Header',
   dbo.fn_formata_valor( pc_venda) + ' (%)'                as 'percentual',
   cv.nm_fantasia_vendedor                                 as nm_fantasia_vendedor
   into
   #FinalPeriodoPositivacao

      from #CalculoVendedorRel cv 
	       left outer join #metaVendedorRel m on m.cd_vendedor = cv.cd_vendedor and m.cd_ano = cv.cd_ano and m.cd_mes = cv.cd_mes
      order by          
	    cv.cd_mes desc,cv.cd_vendedor, cv.cd_ano desc
		--select * from #CalculoVendedorRel
	--	select * from #FinalPeriodoPositivacao
--------------------------------------------------------------------------------------------------------------  
declare 
 @ano nvarchar(20) , 
 @vl_total_pedidos nvarchar(20) ,
 @qt_clientes nvarchar(20) ,
 @qt_base   nvarchar(20) 
select 
	@ano = cd_ano,
	@vl_total_pedidos = titleHeader,
	@qt_clientes = subtitle2Header,
	@qt_base = Base
from #FinalPeriodoPositivacao
--------------------------------------------------------------------------------------------------------------

set @html_geral = '   
    <div class="section-title">   
        <p style="text-align: center;"> '+isnull(+@titulo,'')+'</p>  
    </div>  
    <div class="quadrado">
	   <p>Ano: '+isnull(@ano,'') +'</p>
	   <p>Total de Pedidos $: '+isnull(@vl_total_pedidos,0) +'</p>
	   <p>Base: '+isnull(@qt_base,0) +'</p>
	   <p>Clientes: '+isnull(@qt_clientes,0) +'</p>
	  
   </div>
   <table>  
      <tr class="tamanho">  
        <th>Vendedor</th>
        <th>Mês</th>
        <th>Meta</th>
        <th>Realizado</th>
		<th>(%)Realizado</th>
		<th>Pedidos</th>
		<th>Produtos</th>
		<th>Ativo</th>
      </tr>'  
  
          
--------------------------------------------------------------------------------------------------------------  
DECLARE @id int = 0   
  
WHILE EXISTS (SELECT TOP 1 cd_controle FROM #FinalPeriodoPositivacao)  
BEGIN  
    SELECT TOP 1  
        @id                          = cd_controle,  
        @html_geral = @html_geral +  
			'<tr class="tamanho">  
				<td>'+ case when ISNULL(resultado1,'') = '' then isnull(nm_fantasia_vendedor,'') else resultado1 end +'</td>
				<td>'+isnull(caption,'') +'</td>
				<td>'+isnull(subcaption1,'')+'</td>
				<td>'+isnull(resultado,'')+'</td>
				<td>'+isnull(percentual,'')+'</td>
				<td>'+isnull(resultado2,'')+'</td>
				<td>'+isnull(resultado3,'')+'</td>
				<td>'+isnull(resultado5,'')+'</td>
			 </tr>'  
	
	FROM 
	  #FinalPeriodoPositivacao  
    DELETE FROM #FinalPeriodoPositivacao WHERE cd_controle = @id  
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

--exec pr_egis_relatorio_positivacao_periodo 305,0,''