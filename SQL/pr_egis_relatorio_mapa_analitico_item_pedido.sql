IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_mapa_analitico_item_pedido' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_mapa_analitico_item_pedido

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_mapa_analitico_item_pedido  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_mapa_analitico_item_pedido  
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
create procedure pr_egis_relatorio_mapa_analitico_item_pedido  
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
declare @dt_inicio_pedido datetime  
declare @dt_final_param   datetime
 
--set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)  
set @dt_inicio_pedido = isnull(@dt_inicial,@dt_hoje)  
set @dt_final_param   = isnull(@dt_final,@dt_hoje)
  
  
  
--Busca o pedido de compra mais antigo automaticamente---------------------------------------------------------------------  
  
select  
  @dt_inicio_pedido = min(pci.dt_entrega_item_ped_compr),  
  @dt_final         = max(pci.dt_entrega_item_ped_compr)  
  
from  
  pedido_compra_item pci   
  inner join pedido_compra pc on pc.cd_pedido_compra = pci.cd_pedido_compra  
    
where  
  isnull(pc.cd_status_pedido,0)<> 14 and  
  isnull(pci.qt_saldo_item_ped_compra,0) > 0 and  
  pci.dt_item_canc_ped_compra is null  
  and  
  pci.dt_entrega_item_ped_compr is not null  
  
--select @dt_inicial, @dt_inicio_pedido, @dt_final

  
if @dt_inicial is not null and @dt_inicio_pedido<@dt_inicial 
begin
   --set @dt_inicio_pedido = @dt_inicial 
   set @dt_final         = @dt_final_param
end
  
--select @dt_inicio_pedido, @dt_final

--Mostra os pedidos de compra-----------------------------------------------------------------------------------  
  
  
  select 
    identity(int,1,1)                                         as cd_controle,  
    pc.cd_pedido_compra,  
    pc.dt_pedido_compra,  
    pc.ds_pedido_compra                                       as ds_informativo,  
    f.nm_fantasia_fornecedor                                  as nm_fantasia_fornecedor,  
    pci.cd_item_pedido_compra,  
    pci.qt_item_pedido_compra,  
    pci.qt_saldo_item_ped_compra,  
    pci.qt_dia_entrega_item_ped,  
    pci.dt_entrega_item_ped_compr,  
    pc.dt_nec_pedido_compra                                   as dt_nec_pedido_compra,  
    pci.vl_item_unitario_ped_comp,  
    case when isnull(pci.cd_servico,0)>0 then  
      case when cast(pci.ds_item_pedido_compra as varchar(50))=''  
           then cast(s.nm_servico as varchar(50))  
           else cast(pci.ds_item_pedido_compra as varchar(50))  
      end  
      else     
           pci.nm_produto  
    end as nm_produto,    
    IsNull(pci.nm_fantasia_produto,s.nm_servico) as nm_fantasia_produto,    
    case when isnull(pci.cd_servico,0)>0 then  
      cast(pci.cd_servico as varchar(25))   
    else  
      case when isnull(pci.cd_produto,0) = 0   
           then cast(s.cd_grupo_produto as varchar(20) )  
           else p.cd_mascara_produto end   
    end as cd_mascara_produto,  
    pci.dt_item_canc_ped_compra,  
    pci.qt_item_entrada_ped_compr,  
    isnull(pci.vl_total_item_pedido_comp,0) as vl_total_item_pedido_comp,  
    plc.nm_plano_compra                                       as nm_plano_compra,  
    cc.nm_centro_custo                                        as nm_centro_custo,  
    c.nm_fantasia_comprador                                   as nm_fantasia_comprador,  
    d.nm_departamento                                         as nm_departamento,  
    um.sg_unidade_medida,  
    pci.cd_pedido_venda,  
    pci.cd_item_pedido_venda,  
    pci.cd_requisicao_compra,  
    pci.cd_requisicao_compra_item,  
    sp.nm_status_pedido                                        as nm_status_pedido,  
  
    cast(  
    case when pci.dt_entrega_item_ped_compr < @dt_hoje  
    then  
      'Atrasado'  
    else  
      'Prazo'  
    end  as varchar(20))                                 nm_status_prazo,    
    cp.nm_categoria_produto,  
    mp.nm_marca_produto,  
    gp.nm_grupo_produto,  
    ce.nm_fantasia_cliente,  
    cpo.nm_condicao_pagamento                       as nm_condicao_pagamento,  
    isnull(ef.nm_fantasia_empresa,'')               as nm_fantasia_empresa,  
    year(pci.dt_entrega_item_ped_compr)             as cd_ano,  
    month(pci.dt_entrega_item_ped_compr)            as cd_mes,  
    day(pci.dt_entrega_item_ped_compr)              as cd_dia,  
    isnull(t.nm_fantasia,'')                        as nm_fantasia_transportadora,
    isnull(tpf.nm_tipo_pagamento_frete,'')          as nm_tipo_pagamento_frete
 
  
  into 
  #RelMapaCompra  
   
  from  
    pedido_compra_item pci                         with (nolock)   
    inner join pedido_compra pc                    with (nolock) on pc.cd_pedido_compra         = pci.cd_pedido_compra  
    left outer join fornecedor f                   with (nolock) on f.cd_fornecedor             = pc.cd_fornecedor  
    left outer join Plano_Compra plc               with (nolock) on plc.cd_plano_compra         = case when isnull(pci.cd_plano_compra,0) = 0
                                                                                                    then isnull(pc.cd_plano_compra,0)  
                                                                                                    else pci.cd_plano_compra  
                                                                                                  end  
    left outer join Centro_Custo cc                with (nolock) on cc.cd_centro_custo          = case when isnull(pci.cd_centro_custo,0) = 0
                                                                                                    then isnull(pc.cd_centro_custo,0)  
                                                                                                    else pci.cd_centro_custo  
                                                                                                  end    
    left outer join servico s                      with (nolock) on s.cd_servico                = pci.cd_servico  
    left outer join Produto p                      with (nolock) on p.cd_produto                = pci.cd_produto  
    left outer join Comprador c                    with (nolock) on c.cd_comprador              = pc.cd_comprador  
    left outer join Departamento d                 with (nolock) on d.cd_departamento           = pc.cd_departamento  
    left outer join Unidade_Medida um              with (nolock) on um.cd_unidade_medida        = pci.cd_unidade_medida  
    left outer join status_pedido  sp              with (nolock) on sp.cd_status_pedido         = pc.cd_status_pedido  
    left outer join marca_produto mp               with (nolock) on mp.cd_marca_produto         = p.cd_marca_produto  
    left outer join categoria_produto cp           with (nolock) on cp.cd_categoria_produto     = p.cd_categoria_produto  
    left outer join grupo_produto gp               with (nolock) on gp.cd_grupo_produto         = p.cd_grupo_produto  
    left outer join condicao_pagamento cpo         with (nolock) on cpo.cd_condicao_pagamento   = pc.cd_condicao_pagamento  
    left outer join pedido_venda_item pvi          with (nolock) on pvi.cd_pedido_venda         = pci.cd_pedido_venda  
                                                                and pvi.cd_item_pedido_venda    = pci.cd_item_pedido_venda  
    left outer join pedido_venda pv                with (nolock) on pv.cd_pedido_venda          = pvi.cd_pedido_venda  
    left outer join cliente ce                     with (nolock) on ce.cd_cliente               = pv.cd_cliente  
    left outer join pedido_compra_empresa pce      with (nolock) on pce.cd_pedido_compra        = pc.cd_pedido_compra  
    left outer join empresa_faturamento    ef      with (nolock) on ef.cd_empresa               = pce.cd_empresa 
    left outer join transportadora t               with (nolock) on t.cd_transportadora         = pc.cd_transportadora
    left outer join tipo_pagamento_frete tpf       with (nolock) on tpf.cd_tipo_pagamento_frete = pc.cd_tipo_pagamento_frete
  
  where  
    isnull(pc.cd_status_pedido,0)<> 14 and  
    isnull(pci.qt_saldo_item_ped_compra,0) > 0 and  
--    pci.dt_entrega_item_ped_compr between @dt_inicial and @dt_final and  
    pci.dt_entrega_item_ped_compr between @dt_inicio_pedido and @dt_final and  
    pci.dt_item_canc_ped_compra is null  
  
  order by  
    pci.dt_entrega_item_ped_compr, pci.cd_pedido_compra, pci.cd_item_pedido_compra  
 
  ----select * from #MapaCompra  
  --order by  
  --  dt_entrega_item_ped_compr, cd_pedido_compra, cd_item_pedido_compra  
   
--------------------------------------------------------------------------------------------------------------
 if isnull(@cd_parametro,0) = 1    
 begin    
    select * from #RelMapaCompra    
  return    
 end    
------------------------------------------------------------------------------------------------------------
declare 
	@vl_total        float = 0,
	@qt_pedido_total int = 0,
	@vl_item_total   float = 0
select 
	@vl_total        = SUM(qt_saldo_item_ped_compra),
	@qt_pedido_total = count(cd_pedido_compra),
	@vl_item_total   = sum(cd_item_pedido_compra)
from #RelMapaCompra
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
		<th>Empresa</th>  
		<th>Entrega</th>  
		<th>Prazo</th>  
		<th>Necessidade</th>
		<th>Fornecedor </th>
		<th>Pedido</th>
		<th>Item</th>
		<th>Status</th>
		<th>Quantidade</th>
		<th>Emissão</th>
	   </tr>'  
          
--------------------------------------------------------------------------------------------------------------  
DECLARE @id int = 0   
  
WHILE EXISTS (SELECT TOP 1 cd_controle FROM #RelMapaCompra)  
BEGIN  
    SELECT TOP 1  
        @id                          = cd_controle,  
         
   
      @html_detalhe = @html_detalhe + 

        '<tr>  
		   <td class="tamanho">'+ISNULL(nm_fantasia_empresa,'')+'</td> 
		   <td class="tamanho">'+ISNULL(dbo.fn_data_string(dt_entrega_item_ped_compr),'')+'</td>  
		   <td class="tamanho">'+ISNULL(nm_status_prazo,0)+'</td>  
		   <td class="tamanho">'+ISNULL(dbo.fn_data_string(dt_nec_pedido_compra),'')+'</td>   
		   <td style="text-align: center;">'+ISNULL(nm_fantasia_fornecedor,'')+'</td>
		   <td class="tamanho">'+cast(ISNULL(cd_pedido_compra,'')as nvarchar(20))+'</td>
		   <td class="tamanho">'+cast(ISNULL(cd_item_pedido_compra,'')as nvarchar(20))+'</td> 
		   <td class="tamanho">'+ISNULL(nm_status_pedido,'')+'</td> 
		   <td class="tamanho">'+cast(ISNULL(qt_saldo_item_ped_compra,'')as nvarchar(25))+'</td> 
		  <td class="tamanho">'+ISNULL(dbo.fn_data_string(dt_pedido_compra),'')+'</td>  
        </tr>' 
 from #RelMapaCompra  
    DELETE FROM #RelMapaCompra WHERE cd_controle = @id  
END  
--------------------------------------------------------------------------------------------------------------------  
  
set @html_rodape =' 
         <tr>  
		   <td class="tamanho"><strong>Total</strong></td> 
		   <td class="tamanho"></td>  
		   <td class="tamanho"></td>  
		   <td class="tamanho"></td>   
		   <td class="tamanho"></td>
		   <td class="tamanho"></td>
		   <td class="tamanho"><strong>'+cast(ISNULL(@vl_item_total,'')as nvarchar(20))+'</strong></td> 
		   <td class="tamanho"></td> 
		   <td class="tamanho"><strong>'+cast(ISNULL(@vl_total,'') as nvarchar(25))+'</strong></td> 
		   <td class="tamanho"></td>  
        </tr>
 </table>  
 <div class="company-info">  
  <p><strong>'+@footerTitle+'</strong></p>  
 </div>  
    <p>'+@ds_relatorio+'</p>  
 </div>  
 <div class="section-title">  
     <p>Total de Pedidos: '+cast(ISNULL(@qt_pedido_total,'') as nvarchar(20))+'</p>  
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
  
--exec pr_egis_relatorio_mapa_analitico_item_pedido 267,0,''
