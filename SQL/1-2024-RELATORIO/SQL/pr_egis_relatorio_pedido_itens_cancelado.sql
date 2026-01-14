IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_pedido_itens_cancelado' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_pedido_itens_cancelado

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_pedido_itens_cancelado  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_pedido_itens_cancelado
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
create procedure pr_egis_relatorio_pedido_itens_cancelado 
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
declare @cd_vendedor            int = 0   
declare @cd_grupo_relatorio     int = 0  
declare @cd_cliente_grupo       int = 0 
declare @id                     int = 0
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
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'  
  select @dt_final               = valor from #json where campo = 'dt_final'  
  select @cd_cliente_grupo       = valor from #json where campo = 'cd_grupo_cliente'
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor' 
  
  
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
    @dt_final             = dt_final,
    @cd_vendedor          = isnull(cd_vendedor,''),
	@cd_cliente_grupo     = isnull(cd_grupo_cliente,'')
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
  @nm_fantasia_empresa        = isnull(e.nm_fantasia_empresa,''),  
  @cd_cep_empresa             = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),  
  @cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),  
  @nm_pais					  = ltrim(rtrim(isnull(p.sg_pais,''))),  
  @cd_cnpj_empresa            = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),  
  @cd_inscestadual_empresa    =  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),  
  @nm_dominio_internet        =  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))  
        
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
            font-size:14px;
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
---------------------------------------------------------------------------------------------------------------    
    
if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    
--set @dt_inicial = '02/05/2025'
--set @dt_final = '03/28/2025'   
---------------------------------------------------------------------------------------------------------------
Select    
      identity(int,1,1)               as cd_controle,
      t.sg_tipo_pedido                as sg_tipo_pedido,    
      t.nm_tipo_pedido                as nm_tipo_pedido,    
      p.cd_pedido_venda               as cd_pedido_venda,    
      p.dt_pedido_venda               as dt_pedido_venda,    
      c.nm_fantasia_cliente           as nm_fantasia_cliente,    
      (Select nm_fantasia_Contato    
       From Cliente_Contato    
       Where cd_cliente = p.cd_cliente and cd_contato = p.cd_contato) as nm_fantasia_contato,    
      p.ds_cancelamento_pedido        as ds_cancelamento_pedido,    
      p.dt_cancelamento_pedido        as dt_cancelamento_pedido,    
      i.cd_item_pedido_venda          as cd_item_pedido_venda,    
      i.qt_item_pedido_venda          as qt_item_pedido_venda,    
      i.vl_unitario_item_pedido       as vl_unitario_item_pedido,    
      (i.qt_item_pedido_venda * i.vl_unitario_item_pedido) as vl_total_item_pedido,    
      i.dt_entrega_vendas_pedido      as dt_entrega_vendas_pedido,    
      i.dt_entrega_fabrica_pedido     as dt_entrega_fabrica_pedido,    
      pd.cd_produto                   as cd_produto,    
      i.nm_produto_pedido             as nm_produto,    
      i.nm_fantasia_produto           as nm_fantasia_produto
	  into
	  #itensPedido
    from    
      Pedido_Venda p 
	  left outer join Pedido_Venda_Item i   on p.cd_pedido_venda = i.cd_pedido_venda 
	  Left Outer Join Produto pd            on i.cd_produto = pd.cd_produto
	  Left Outer Join Tipo_Pedido t         on p.cd_tipo_pedido = t.cd_tipo_pedido 
	  left outer join Cliente c             on p.cd_cliente = c.cd_cliente    
    where    
      p.dt_pedido_venda between @dt_inicial and @dt_final 
	  and    
      p.cd_status_pedido = 7    
	  and	  
	  IsNull(p.cd_vendedor,0) = ( case when isnull(@cd_vendedor,0) = 0 then IsNull(p.cd_vendedor,0) else isnull(@cd_vendedor,0) end )
	  and
	  IsNull(c.cd_cliente_grupo,0) = ( case when isnull(@cd_cliente_grupo,0) = 0 then IsNull(c.cd_cliente_grupo,0) else isnull(@cd_cliente_grupo,0) end )
    
    order by    
      p.dt_cancelamento_pedido desc,
	  p.cd_pedido_venda desc,
	  
	  i.cd_item_pedido_venda
---------------------------------------------------------------------------------------------------------------
	  select 
	    identity(int,1,1)                 as cd_controle,
			nm_tipo_pedido                    as nm_tipo_pedido,
			cd_pedido_venda                   as cd_pedido_venda,
			max(dt_pedido_venda)              as dt_pedido_venda,
			max(nm_fantasia_cliente)          as nm_fantasia_cliente,
			max(nm_fantasia_contato)          as nm_fantasia_contato,
			max(dt_cancelamento_pedido)       as dt_cancelamento_pedido,
			max(ds_cancelamento_pedido)       as ds_cancelamento_pedido,
			sum(vl_unitario_item_pedido)      as vl_unitario_item_pedido_total,
			sum(vl_total_item_pedido)         as vl_total_item_pedido_total,
			sum(qt_item_pedido_venda)         as qt_item_pedido_venda_total
		into
		   #CapaItensPedido
	    from #itensPedido
		group by
		  nm_tipo_pedido,
		  cd_pedido_venda
		order by
		  nm_tipo_pedido
---------------------------------------------------------------------------------------------------------------
--if isnull(@cd_parametro,0) = 1    
-- begin    
--  select * from #CapaCancelado    
--  return    
--end    
---------------------------------------------------------------------------------------------------------------
declare 
	@nm_tipo_pedido                   nvarchar(50),        
	@cd_pedido_venda                  int = 0,       
	@dt_pedido_venda                  datetime,       
	@nm_fantasia_cliente              nvarchar(60),   
	@nm_fantasia_contato              nvarchar(60),   
	@dt_cancelamento_pedido           datetime,
	@ds_cancelamento_pedido           nvarchar(250),
	@vl_unitario_item_pedido_total    float = 0,
	@vl_total_item_pedido_total       float = 0, 
	@qt_item_pedido_venda_total       float = 0
---------------------------------------------------------------------------------------------------------------  

set @html_geral = '  
     <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 22%;">'+isnull(@titulo,'')+'</p>  
    </div>'

---------------------------------------------------------------------------------------------------------------
while exists( select Top 1 cd_controle from #CapaItensPedido )
  begin

  select Top 1
	@nm_tipo_pedido					= nm_tipo_pedido,
	@cd_pedido_venda       			= cd_pedido_venda,
	@dt_pedido_venda       			= dt_pedido_venda,
	@nm_fantasia_cliente   			= nm_fantasia_cliente,
	@nm_fantasia_contato   			= nm_fantasia_contato,
	@dt_cancelamento_pedido			= dt_cancelamento_pedido,
	@ds_cancelamento_pedido			= ds_cancelamento_pedido,
	@vl_unitario_item_pedido_total  = vl_unitario_item_pedido_total,
	@vl_total_item_pedido_total   	= vl_total_item_pedido_total,
	@qt_item_pedido_venda_total   	= qt_item_pedido_venda_total
  from #CapaItensPedido	

--------------------------------------------------------------------------------------------------------------
set @html_cab_det = @html_cab_det +'  <table>
											<tr>
												<th>Tipo</th>
												<th>Pedido</th>
												<th>Emissão</th>
												<th>Cliente</th>
												<th>Contato</th>
												<th>Data</th>
												<th>Cancelamento</th>
											</tr>
											<tr>
												<td>'+isnull(@nm_tipo_pedido,'')+'</td>
												<td>'+cast(isnull(@cd_pedido_venda,'')as nvarchar(20))+'</td>
												<td>'+isnull(dbo.fn_data_string(@dt_pedido_venda),'')+'</td>
												<td style="text-align: left;">'+isnull(@nm_fantasia_cliente,'')+'</td>
												<td style="text-align: left;">'+isnull(@nm_fantasia_contato,'')+'</td>
												<td>'+isnull(dbo.fn_data_string(@dt_cancelamento_pedido),'')+'</td>
												<td>'+isnull(@ds_cancelamento_pedido,'')+'</td>
											</tr>
											<table>
											<tr>
												<th>Item</th>
												<th>Quantidade</th>
												<th>Produto</th>
												<th>Unitário</th>
												<th>Total</th>
												<th>Comercial</th>
												<th>Fábrica</th>
											</tr>
											'
								
   
  --------------------------------------------------------------------------------------------------------------------------


  while exists ( select top 1 cd_controle from #itensPedido where cd_pedido_venda = @cd_pedido_venda)
  begin

    select top 1
      
      @id           = cd_controle,
      @html_cab_det = @html_cab_det + '
            <tr class="tamanho"> 	
			    <td >'+CAST(isnull(cd_item_pedido_venda,'')as nvarchar(20))+'</td>
				<td >'+CAST(isnull(qt_item_pedido_venda,'')as nvarchar(20))+'</td> 
				<td style="text-align: left;">'+isnull(nm_produto,'')+'</td>
				<td >'+CAST(isnull(dbo.fn_formata_valor(vl_unitario_item_pedido),'')as nvarchar(20))+'</td> 
				<td >'+CAST(isnull(dbo.fn_formata_valor(vl_total_item_pedido),'')as nvarchar(20))+'</td>
				<td >'+isnull(dbo.fn_data_string(dt_entrega_vendas_pedido),'')+'</td>  
			    <td >'+isnull(dbo.fn_data_string(dt_entrega_fabrica_pedido),'')+'</td> '

     from
       #itensPedido

     where
      cd_pedido_venda = @cd_pedido_venda

  delete from #itensPedido
  where
    cd_controle = @id

 end
	
	   	set @html_cab_det = @html_cab_det + '
	     <tr>
		   <td class="tamanho" style="font-size:18px;"><b>Total</b></td>
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(@qt_item_pedido_venda_total,0)as nvarchar(20))+'</b></td> 
		   <td class="tamanho" style="font-size:18px;"><b></b></td>
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_unitario_item_pedido_total),0)as nvarchar(20))+'</b></td> 
		   <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_item_pedido_total),0)as nvarchar(20))+'</b></td> 
		   <td class="tamanho" style="font-size:18px;"><b></b></td>
		   <td class="tamanho" style="font-size:18px;"><b></b></td>
	     </tr>'


 delete from #CapaItensPedido
    where
       cd_pedido_venda = @cd_pedido_venda

	   
	   SET @html_cab_det = @html_cab_det + '
	   </table>'
end

--------------------------------------------------------------------------------------------------------------------  
  
  
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
	@html_cab_det +
    @html_detalhe +
	@html_rod_det +
    @html_rodape  
  
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
 
go
  
--exec pr_egis_relatorio_pedido_itens_cancelado 264,0,''

