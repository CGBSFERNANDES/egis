IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_pedido_venda_quantidade_liberada' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_pedido_venda_quantidade_liberada

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_pedido_venda_quantidade_liberada  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_pedido_venda_quantidade_liberada
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
create procedure pr_egis_relatorio_pedido_venda_quantidade_liberada 
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
   @nm_endereco_empresa       varchar(200) = '',  
   @cd_telefone_empresa     varchar(200) = '',  
   @nm_email_internet      varchar(200) = '',  
   @nm_cidade        varchar(200) = '',  
   @sg_estado        varchar(10)  = '',  
   @nm_fantasia_empresa     varchar(200) = '',  
   @numero         int = 0,  
   @dt_pedido        varchar(60) = '',  
   @cd_cep_empresa       varchar(20) = '',   
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
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
  select @cd_documento			 = valor from #json where campo = 'cd_documento_form'
  
  
   set @cd_documento = isnull(@cd_documento,0)  
  
   if @cd_documento = 0  
   begin  
     select @cd_documento           = valor from #json where campo = 'cd_documento'  
  
   end 

   if isnull(@cd_documento,0) = 12
   begin 
     set @cd_documento = 0
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
if isnull(@dt_inicial,'') <> ''
begin
  select    
    @dt_inicial       = dt_inicial,    
    @dt_final         = dt_final,
    @cd_vendedor      = isnull(cd_vendedor,'')
  from     
    Parametro_Relatorio    
      
  where    
    cd_relatorio = @cd_relatorio    
    and    
    cd_usuario   = @cd_usuario   
end

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
--set @dt_inicial = '03/01/2025' 
--set @dt_final = '03/11/2025'
--set @cd_documento = 1
--select @cd_vendedor
select
  identity(int,1,1)                          as cd_controle,
  case when ISNULL(hr_inicial_pedido,'')<>'' then
  right(left(convert(varchar,p.hr_inicial_pedido,121),16),5)
  else
    FORMAT(p.dt_usuario, 'HH:mm')
  end                                        as hr_inicial_consulta,
  v.nm_fantasia_vendedor                     as nm_fantasia_vendedor,
  v.cd_vendedor                              as cd_vendedor,
  dbo.fn_data_string(p.dt_pedido_venda)      as dt_pedido_venda,
  p.cd_pedido_venda                          as cd_pedido_venda,
  tp.nm_tipo_pedido                          as nm_tipo_pedido, 
  c.cd_cliente                               as cd_cliente,
  c.nm_fantasia_cliente                      as nm_fantasia_cliente,
  c.nm_razao_social_cliente					 as nm_razao_social_cliente,
  c.cd_cnpj_cliente							 as cd_cnpj_cliente,
  pvi.cd_item_pedido_venda                   as cd_item_pedido_venda,
  pvi.nm_produto_pedido                      as nm_produto_pedido,
  um.sg_unidade_medida					     as sg_unidade_medida,
  MAX(CAST((p.ds_observacao_pedido) AS VARCHAR(MAX)))                as ds_observacao_pedido,
  MAX(ISNULL(CAST(p.vl_total_pedido_ipi AS DECIMAL(18,2)), 0))        as vl_total_pedido,
  max(est.sg_estado)                         as sg_estado,
  max(cid.nm_cidade)                         as nm_cidade,
  max(cp.nm_condicao_pagamento)              as nm_condicao_pagamento,
  max(fp.nm_forma_pagamento)                 as nm_forma_pagamento,
  max(pvi.vl_unitario_item_pedido)           as vl_unitario_item_pedido,
  max(pvi.qt_item_pedido_venda)              as qt_item_pedido_venda,
  MAX(pvi.vl_unitario_item_pedido) * MAX(pvi.qt_item_pedido_venda) AS vl_total_item
   
   
  into
    #RelPedidoVenda

from
  Pedido_Venda p
  left outer join Pedido_Venda_Romaneio pvr     on pvr.cd_pedido_venda      = p.cd_pedido_venda       
  left outer join pedido_venda_item pvi         on pvi.cd_pedido_venda      = p.cd_pedido_venda 
  LEFT outer join Unidade_Medida um             on um.cd_unidade_medida     = pvi.cd_unidade_medida
  inner join cliente c                          on c.cd_cliente             = p.cd_cliente
  LEFT outer join Cliente_Informacao_Credito ic on ic.cd_cliente            = p.cd_cliente
  LEFT outer join Estado est                    on est.cd_estado            = c.cd_estado
  inner join cidade cid                         on cid.cd_cidade            = c.cd_cidade
  left outer join tipo_pedido tp                on tp.cd_tipo_pedido        = p.cd_tipo_pedido
  inner join vendedor v                         on v.cd_vendedor            = p.cd_vendedor
  inner join pedido_venda_item i                on i.cd_pedido_venda        = p.cd_pedido_venda
  left outer join Pedido_Venda_Empresa pve      on pve.cd_pedido_venda      = p.cd_pedido_venda
  left outer join empresa_faturamento ef        on ef.cd_empresa            = pve.cd_empresa
  left outer join condicao_pagamento cp         on cp.cd_condicao_pagamento = p.cd_condicao_pagamento
  left outer join forma_pagamento fp            on fp.cd_forma_pagamento    = case when 
                                                                                 isnull(p.cd_forma_pagamento,0)>0 
                                                                              then
																			     p.cd_forma_pagamento 
																			  else 
																			     ic.cd_forma_pagamento 
																			  end

where
  i.dt_cancelamento_item is null
  and ISNULL(i.qt_saldo_pedido_venda,0) > 0
  and p.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then p.cd_vendedor else isnull(@cd_vendedor,0) end
  and (
    (isnull(@dt_inicial, '') = '' and pvr.cd_carga = isnull(@cd_documento, 0))
    or
    (isnull(@dt_inicial, '') <> '' and p.dt_pedido_venda between @dt_inicial and @dt_final)
  )

group by
  p.hr_inicial_pedido, 
  p.dt_usuario,
  p.cd_pedido_venda,
  p.dt_pedido_venda,
  tp.nm_tipo_pedido,
  c.cd_cliente,
  c.nm_fantasia_cliente,
  v.nm_fantasia_vendedor,
  v.cd_vendedor,
  nm_razao_social_cliente,
  c.cd_cnpj_cliente,
  pvi.cd_item_pedido_venda,
  pvi.nm_produto_pedido,
  um.sg_unidade_medida
  
  order by
    v.nm_fantasia_vendedor, 
	p.dt_pedido_venda,
    p.cd_pedido_venda
	
--------------------------------------------------------------------------------------------------------------
	
select 
    identity(int,1,1)                                                  as cd_controle,
    cd_vendedor                                                        as cd_vendedor,
	nm_fantasia_vendedor                                               as nm_fantasia_vendedor,
	cd_pedido_venda													   as cd_pedido_venda,
    nm_tipo_pedido													   as nm_tipo_pedido, 
    cd_cliente														   as cd_cliente,
    nm_fantasia_cliente												   as nm_fantasia_cliente,
    nm_razao_social_cliente											   as nm_razao_social_cliente,
    cd_cnpj_cliente													   as cd_cnpj_cliente,
	sum(vl_unitario_item_pedido)									   as vl_unitario_item_pedido_total,
	sum(qt_item_pedido_venda)                                          as qt_item_pedido_venda_total,
	MAX(CAST((ds_observacao_pedido) AS VARCHAR(MAX)))                  as ds_observacao_pedido,
	max(nm_condicao_pagamento)                                         as nm_condicao_pagamento,
    max(nm_forma_pagamento)                                            as nm_forma_pagamento,
	MAX(vl_unitario_item_pedido) * MAX(qt_item_pedido_venda)           as vl_total_item
	into
	#RelPedidoVendaCapa
from
  #RelPedidoVenda
group by
  cd_vendedor,
  nm_fantasia_vendedor,
  cd_pedido_venda,
  nm_tipo_pedido,
  cd_cliente,
  nm_fantasia_cliente,
  nm_razao_social_cliente,
  cd_cnpj_cliente

 -- select * from #RelPedidoVendaCapa return
---------------------------------------------------------------------------------------------------------------
declare 
	@nm_vendedor						  nvarchar(60),
	@cd_vendedor_rel					  int = 0 ,
	@vl_unitario_item_pedido_total        float = 0,
	@qt_item_pedido_venda_total			  float = 0,
	@vl_total_geral                       float = 0,
	@cd_pedido_venda                      int = 0,
	@cd_cliente                           int = 0,
	@nm_fantasia_cliente                  nvarchar(60),
	@nm_razao_social_cliente_rel		  nvarchar(60),
	@cd_cnpj_cliente_rel                  nvarchar(30),
	@nm_tipo_pedido_rel				      nvarchar(30),
	@nm_condicao_pagamento                nvarchar(30),
	@nm_forma_pagamento                   nvarchar(30),
	@ds_observacao_pedido                 nvarchar(100),
    @id                                   int = 0, 
	@sub_id                               int = 0

select 
	@cd_pedido_venda          = cd_pedido_venda
	
from #RelPedidoVenda
--------------------------------------------------------------------------------------------------------------  

set @html_geral = '  
    <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 20%;"> '+isnull(+@titulo,'')+' </p>  
    </div>  '

--------------------------------------------------------------------------------------------------------------     
	
while exists( select Top 1 cd_controle from #RelPedidoVendaCapa )
  begin

  select Top 1
    @id                                  = cd_controle,
	@nm_vendedor                         = nm_fantasia_vendedor,
	@cd_vendedor_rel					 = cd_vendedor,
	@vl_unitario_item_pedido_total       = vl_unitario_item_pedido_total,
	@qt_item_pedido_venda_total          = qt_item_pedido_venda_total,
	@vl_total_geral                      = vl_total_item,
	@cd_pedido_venda                     = cd_pedido_venda,
	@cd_cliente                          = cd_cliente,
	@nm_fantasia_cliente				 = nm_fantasia_cliente,
	@nm_razao_social_cliente_rel         = nm_razao_social_cliente,
	@cd_cnpj_cliente_rel                 = cd_cnpj_cliente,
	@nm_tipo_pedido_rel                  = nm_tipo_pedido,
	@nm_condicao_pagamento               = nm_condicao_pagamento,
	@nm_forma_pagamento                  = nm_forma_pagamento,
	@ds_observacao_pedido                = ds_observacao_pedido
  from #RelPedidoVendaCapa	
  
----------------------------------------------------------------------------------------------------------------
set @html_cab_det = @html_cab_det +'   <div class="section-title">
										  <p><strong>'+cast(isnull(@cd_vendedor_rel,'')as nvarchar(20))+' - '+isnull(@nm_vendedor,'')+' </strong></p>
									   </div>    
										<table>
											<tr>
												<th>Pedido</th>
												<th>Código</th>
												<th>Fantasia</th>
												<th>Razão Social</th>
												<th>CNPJ</th>
												<th>Tipo Pedido</th>
												<th>Condição Pagamento</th>
												<th>Forma Pagamento</th>
												<th>Observações</th>										
											</tr>
											<tr class="tamanho">
												<td>'+cast(isnull(@cd_pedido_venda,'')as nvarchar(20))+'</td>
												<td>'+cast(isnull(@cd_cliente,'')as nvarchar(20))+'</td> 
												<td>'+isnull(@nm_fantasia_cliente,'')+'</td>
												<td>'+isnull(@nm_razao_social_cliente_rel,'')+'</td>
												<td>'+isnull(dbo.fn_formata_cnpj(@cd_cnpj_cliente_rel),'')+'</td>
												<td>'+isnull(@nm_tipo_pedido_rel,'')+'</td>
												<td>'+isnull(@nm_condicao_pagamento,'')+'</td>
												<td>'+isnull(@nm_forma_pagamento,'')+'</td>
												<td>'+isnull(@ds_observacao_pedido,'')+'</td>
											</tr>
										</table>
										<table>
											<tr>
												<th>Item</th>
												<th>Descrição</th>
												<th>Un.</th>
												<th>Quantidade</th>
												<th>Preço Unitátio</th>
												<th>Total</th>
											</tr>'
								

------------------------------------------------------------------------------------------------------------------------------


  while exists ( select top 1 cd_controle from #RelPedidoVenda where cd_pedido_venda = @cd_pedido_venda)
  begin

    select top 1
      
      @sub_id           = cd_controle,
      @html_cab_det = @html_cab_det + '
            <tr class="tamanho">
			    <td >'+CAST(isnull(cd_item_pedido_venda,'')as nvarchar(20))+'</td> 
				<td style="text-align: left;">'+isnull(nm_produto_pedido,'')+'</td>			
				<td>'+isnull(sg_unidade_medida,'')+'</td> 
				<td>'+CAST(isnull(qt_item_pedido_venda,'')as nvarchar(20))+'</td> 
				<td>'+CAST(isnull(dbo.fn_formata_valor(vl_unitario_item_pedido),'')as nvarchar(20))+'</td>
				<td>'+CAST(isnull(dbo.fn_formata_valor(vl_total_item),'')as nvarchar(20))+'</td> 
            </tr>
	    '

     from
       #RelPedidoVenda

     where
       cd_pedido_venda = @cd_pedido_venda
 
  delete from #RelPedidoVenda
  where
    cd_controle = @sub_id

 end
	
	   	set @html_cab_det = @html_cab_det + '
	     <tr>
		   <td class="tamanho" style="font-size:18px;"><b>Total</b></td>
		   <td class="tamanho" style="font-size:18px;"><b></b></td>
		   <td class="tamanho" style="font-size:18px;"><b></b></td>
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(@qt_item_pedido_venda_total,0)as nvarchar(20))+'</b></td> 
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_unitario_item_pedido_total),0)as nvarchar(20))+'</b></td> 
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_geral),0)as nvarchar(20))+'</b></td>  
	     </tr>'

 
 delete from #RelPedidoVendaCapa
  where
    cd_controle = @id
	   
	   SET @html_cab_det = @html_cab_det + '
	   </table>'
	    
      
  delete from #RelPedidoVendaCapa where cd_controle = @id
end
--------------------------------------------------------------------------------------------------------------------  
  
  
  
  
set @html_rodape =' 
	<div class="section-title"><p>Total Geral</p></div>
   <table style="width: 100%;">  
      <tr>  
          <td style="display: flex; flex-direction: column; gap: 20px;">  
              <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">  
                  <div style="text-align: left;">  
                      <p><strong>Quantidade:</strong> </p>  
                      <p><strong>Peso Pedido:</strong> </p>  
                      <p><strong>Peso Liberado:</strong> </p> 
					  <p><strong>Peso Faturado:</strong> </p> 
                  </div>      
				  <div style="text-align: left;">  
                      <p><strong>Quantidade Produto:</strong> </p>              
                      <p><strong>Quantidade Liberado:</strong> </p> 
					  <p><strong>Quantidade Falta:</strong> </p>
					  <p><strong>Quantidade Faturado:</strong> </p> 
                  </div>      
                  <div style="text-align: left;">  
					  <p><strong>Valor Pedidos:</strong> </p>              
                      <p><strong>Valor Liberado:</strong> </p> 
					  <p><strong>Valor Falta:</strong> </p>
					  <p><strong>Valor Faturado:</strong> </p> 
                  </div>     
    
              </div>  
          </td>  
      </tr>  
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
	@html_cab_det +
    @html_detalhe +
	@html_rod_det +
    @html_rodape  
  
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
 
  
    go
  
--exec pr_egis_relatorio_pedido_venda_quantidade_liberada 264,0,''

