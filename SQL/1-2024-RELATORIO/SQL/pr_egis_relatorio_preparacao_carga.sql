IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_preparacao_carga' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_preparacao_carga

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_preparacao_carga
-------------------------------------------------------------------------------
--pr_egis_relatorio_preparacao_carga
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 24.08.2024
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_preparacao_carga
@cd_relatorio int   = 0,
@cd_documento int   = 0,
@cd_parametro int   = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')

declare @cd_empresa             int = 0
declare @cd_modulo              int = 0
declare @cd_menu                int = 0
declare @cd_processo            int = 0
declare @cd_item_processo       int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
--declare @cd_documento           int = 0
declare @cd_item_documento      int = 0
--declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
DECLARE @cd_grupo_relatorio     int 
--declare @cd_relatorio           int = 0

--Dados do Relatório---------------------------------------------------------------------------------

     declare
            @titulo                     varchar(200),
		    @logo                       varchar(400),			
			@nm_cor_empresa             varchar(20),
			@nm_endereco_empresa  	    varchar(200) = '',
			@cd_telefone_empresa    	varchar(200) = '',
			@nm_email_internet		    varchar(200) = '',
			@nm_cidade				    varchar(200) = '',
			@sg_estado				    varchar(10)	 = '',
			@nm_fantasia_empresa	    varchar(200) = '',
			@numero					    int = 0,
			@dt_pedido				    varchar(60) = '',
			@cd_cep_empresa			    varchar(20) = '',
			@cd_cliente				    int = 0,
			@nm_fantasia_cliente  	    varchar(200) = '',
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_razao_social_cliente	varchar(200) = '',
			@nm_endereco_cliente		varchar(200) = '',
			@nm_bairro					varchar(200) = '',
			@nm_cidade_cliente			varchar(200) = '',
			@sg_estado_cliente			varchar(5)	= '',
			@cd_numero_endereco			varchar(20) = '',
			@cd_telefone				varchar(20) = '',
			@nm_condicao_pagamento		varchar(100) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40)   = '',
			@footerTitle				varchar(200)  = '',
			@vl_total_ipi				float         = 0,
			@sg_tabela_preco            char(10)      = '',
			@cd_empresa_faturamento     int           = 0,
			@nm_fantasia_faturamento    varchar(30)   = '',
			@cd_tipo_pedido             int           = 0,
			@nm_tipo_pedido             varchar(30)   = '',
			@cd_vendedor                int           = 0,
			@nm_fantasia_vendedor       varchar(30)   = '',
			@nm_telefone_vendedor       varchar(30)   = '',
			@nm_email_vendedor          varchar(300)  = '',
			@nm_contato_cliente			varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = '',
			@nm_status					varchar(100) = '',
			@ic_empresa_faturamento		char(1) = ''



--------------------------------------------------------------------------------------------------------

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
--set @cd_parametro      = 0
set @cd_modulo         = 0
set @cd_empresa        = 0
set @cd_menu           = 0
set @cd_processo       = 0
set @cd_item_processo  = 0
set @cd_form           = 0
--set @cd_parametro      = 0
--set @cd_documento      = 0
set @cd_item_documento = 0
set @dt_usuario        = GETDATE()
------------------------------------------------------------------------------------------------------

if @json<>''
begin
  select                     
    1                                                    as id_registro,
    IDENTITY(int,1,1)                                    as id,
    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
    valores.[value]              as valor                    
                    
    into #json                    
    from                
      openjson(@json)root                    
      cross apply openjson(root.value) as valores      

-------------------------------------------------------------------------------------------------

--select * from #json

-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_modulo              = valor from #json where campo = 'cd_modulo'             
  select @cd_processo            = valor from #json where campo = 'cd_processo'             
  select @cd_item_processo       = valor from #json where campo = 'cd_item_processo'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  --select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio_form'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'

   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'
     select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'

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
  @dt_inicial       = dt_inicial,  
  @dt_final         = dt_final
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
		@nm_cor_empresa		   	    = isnull(e.nm_cor_empresa,'#1976D2'),
		@nm_endereco_empresa 	    = isnull(e.nm_endereco_empresa,''),
		@cd_telefone_empresa	    = isnull(e.cd_telefone_empresa,''),
		@nm_email_internet	  	    = isnull(e.nm_email_internet,''),
		@nm_cidade			    	= isnull(c.nm_cidade,''),
		@sg_estado				    = isnull(es.sg_estado,''),
		@nm_fantasia_empresa	    = isnull(e.nm_fantasia_empresa,''),
		@cd_cep_empresa			    = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),
		@cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),
		@nm_pais					= ltrim(rtrim(isnull(p.sg_pais,''))),
		@cd_cnpj_empresa			= dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),
		@cd_inscestadual_empresa	=  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),
		@nm_dominio_internet		=  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))
			   
	from egisadmin.dbo.empresa e	with(nolock)
	left outer join Estado es		with(nolock) on es.cd_estado = e.cd_estado
	left outer join Cidade c		with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado
	left outer join Pais p			with(nolock) on p.cd_pais = e.cd_pais
	where 
		cd_empresa = @cd_empresa


---------------------------------------------------------------------------------------------------------------------------------------------
--Dados do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------

declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabeçalho da Empresa
declare @html_titulo     nvarchar(max) = '' --Título
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe
declare @html_rodape     nvarchar(max) = '' --Rodape

declare @data_hora_atual nvarchar(50)  = ''

set @html         = ''
set @html_empresa = ''
set @html_titulo  = ''
set @html_cab_det = ''
set @html_detalhe = ''
set @html_rod_det = ''
set @html_rodape  = ''

-- Obtém a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------
--Título do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio


--select @titulo
--
--select @nm_cor_empresa
-----------------------
--Cabeçalho da Empresa----------------------------------------------------------------------------------------------------------------------
-----------------------

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
            margin-bottom: 20px;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 5px;
			text-align: center;
           
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
            background-color: '+isnull(@nm_cor_empresa,'')+';
            color: white;
            padding: 5px;
            margin-bottom: 10px;
			border-radius:5px;
        }
       
        img {
            max-width: 250px;
			margin-right:10px;
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
            color: '+isnull(@nm_cor_empresa,'')+';
        }
        .report-date-time {
            text-align: right;
            margin-bottom: 5px;
			margin-top:50px;
        }
		p {
			margin:5px;
			padding:0;
		}
    </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:30%; margin-right:20px">
			<img src="'+isnull(@logo,'')+'" alt="Logo da Empresa">
		</div>
		<div style="width:70%; padding-left:10px">
			<p class="title">'+isnull(@nm_fantasia_empresa,'')+'</p>
		    <p><strong>'+isnull(@nm_endereco_empresa,'')+', '+isnull(@cd_numero_endereco_empresa,'') + ' - '+isnull(@cd_cep_empresa,'')+ ' - '+isnull(@nm_cidade,'')+' - '+isnull(@sg_estado,'')+' - ' + isnull(@nm_pais,'') + '</strong></p>
		    <p><strong>Fone: </strong>'+isnull(@cd_telefone_empresa,'')+' - <strong>CNPJ: </strong>' + isnull(@cd_cnpj_empresa,'') + ' - <strong>I.E: </strong>' + isnull(@cd_inscestadual_empresa,'') + '</p>
		    <p>'+isnull(@nm_dominio_internet,'')+ ' - ' + isnull(@nm_email_internet,'')+'</p>
		</div>    
    </div>'

--select @html_empresa

		

--Detalhe--
--Procedure de Cada Relat�rio-------------------------------------------------------------------------------------
 
select a.*, g.nm_grupo_relatorio into #RelAtributo 
from
  egisadmin.dbo.Relatorio_Atributo a 
  left outer join egisadmin.dbo.relatorio_grupo g on g.cd_grupo_relatorio = a.cd_grupo_relatorio
where 
  a.cd_relatorio = @cd_relatorio
order by
  qt_ordem_atributo

declare @cd_item_relatorio  int           = 0
declare @nm_cab_atributo    varchar(100)  = ''
declare @nm_dados_cab_det   nvarchar(max) = ''
declare @nm_grupo_relatorio varchar(60)   = ''


--select * from egisadmin.dbo.relatorio_grupo

select * into #AuxRelAtributo from #RelAtributo order by qt_ordem_atributo

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

--


select
  @dt_inicial     = dt_inicial,
  @dt_final       = dt_final
from 
  Parametro_Relatorio

where
  cd_relatorio = @cd_relatorio
  and
  cd_usuario   = @cd_usuario

  
  
if isnull(@cd_parametro,0) = 2  
 begin  
  select * from #RelAtributo  
  return  
end  


--------------------------------------------------------------------------------------------------------------------------

set @html_detalhe = '' --valores da tabela


---> CCF <----
---> alteração com o processo do relatório

--Ordem de Separação----------------------------

declare @vl_total         decimal(25,2) = 0.00
declare @qt_total         int = 0
declare @qt_total_produto decimal(25,2) = 0
declare @cd_carga         int = 0

select top 1 @cd_carga = cd_carga from pedido_venda_romaneio where cd_pedido_venda = @cd_documento

-----------------------
select   
  identity(int,1,1)                       as cd_controle,  
  c.cd_carga                              as cd_carga,  
  c.dt_carga							  as dt_carga, 
  c.dt_entrega_carga                      as dt_entrega_carga,  
  p.cd_produto                            as cd_produto,  
  p.cd_mascara_produto                    as cd_mascara_produto,  
  p.nm_fantasia_produto                   as nm_fantasia_produto,  
  p.nm_produto							  as nm_produto,  
  isnull(g.nm_grupo_localizacao,'')       as nm_grupo_localizacao,  
  sum( isnull(i.qt_saldo_pedido_venda,0)) as qt_produto,  
  max(isnull(um.sg_unidade_medida,''))               as sg_unidade_medida,  
--  max(cast('[    ]' as varchar(10)))      as nm_separado,  
  --max(p.nm_produto)                       as nm_produto,  
  max(isnull(p.cd_codigo_barra_produto,''))          as cd_codigo_barra_produto,  
    
  max(cast('' as varchar(25)))             as nm_lote_produto,  
  --max(isnull(g.nm_grupo_localizacao,''))   as nm_grupo_localizacao,  
  max(isnull(l.qt_posicao_localizacao,'')) as qt_posicao_localizacao,
  isnull(it.nm_itinerario,'')                        as nm_itinerario,
  isnull(ve.nm_veiculo,'')                 as nm_veiculo,
  isnull(en.nm_entregador,'')              as nm_entregado

  
into  
  #Detalhe  
  
from  
 Pedido_Venda_Romaneio r  
  inner join pedido_venda pv                  on pv.cd_pedido_venda     = r.cd_pedido_venda  
  inner join pedido_venda_item i              on i.cd_pedido_venda      = r.cd_pedido_venda  
  inner join produto p                        on p.cd_produto           = i.cd_produto  
  inner join unidade_medida um                on um.cd_unidade_medida   = i.cd_unidade_medida  
  inner join Preparacao_Carga c               on c.cd_carga             = r.cd_carga  
  left outer join Produto_Localizacao l       on l.cd_produto           = i.cd_produto and l.cd_fase_produto = i.cd_fase_produto  
  left outer join Produto_Grupo_Localizacao g on g.cd_grupo_localizacao = l.cd_grupo_localizacao  
  left outer join Itinerario it               on it.cd_itinerario       = c.cd_itinerario
  left outer join Entregador en               on en.cd_entregador       = c.cd_entregador
  left outer join Veiculo ve                  on ve.cd_veiculo          = c.cd_veiculo
where  
  r.cd_carga = @cd_carga  
  and  
  i.dt_cancelamento_item is null  
  and  
  isnull(i.qt_saldo_pedido_venda,0)>0  
  
group by  
  c.cd_carga,  
  c.dt_carga,  
  c.dt_entrega_carga,  
  p.cd_produto,  
  p.cd_mascara_produto,  
  p.nm_fantasia_produto,  
  p.nm_produto,  
  g.nm_grupo_localizacao,  
  it.nm_itinerario,
  ve.nm_veiculo,
  en.nm_entregador
  
order by  
  g.nm_grupo_localizacao,  
  p.nm_produto  
  
--select * from #Detalhe  

--montagem do Detalhe--  
--declare @qt_total_produto decimal(25,2) = 0  
declare 
		@id               int,
	    @nm_pedido        nvarchar(max) = '',  
		@nm_itinerario    nvarchar(60) = '',
		@nm_entregado	  nvarchar(60) = '',
		@nm_veiculo		  nvarchar(60) = '',
		@cd_carga_atr     int = 0,
		@dt_carga         datetime

select  
  @qt_total_produto = count( qt_produto ),
  @vl_total         = sum(qt_produto)

from  
  #Detalhe  

 select 
  @nm_itinerario    = nm_itinerario,
  @nm_entregado     = nm_entregado,
  @nm_veiculo		= nm_veiculo,
  @cd_carga_atr     = cd_carga,
  @dt_carga         = dt_carga
 from #Detalhe 
 

set @html_detalhe = ''  
-----------------------------------------------------------------------------------------------------------------*

set @html_cab_det = '<div class="section-title"><strong> '+@nm_grupo_relatorio + '  </strong></div> 
					 <table>
						<tr>
							<th>Carga</th>
							<th>Data</th>
							<th>Rota</th>
							<th>Motorista</th>
							<th>Veiculo</th>							
						</tr>
						<tr>
							<td>'+cast(ISNULL(@cd_carga_atr,'')as nvarchar(15))+'</td>
							<td>'+ISNULL(dbo.fn_data_string(@cd_carga_atr),'')+'</td>
						    <td>'+cast(@nm_itinerario as varchar(120))+'</td>
							<td>'+cast(@nm_entregado as varchar(120))+'</td>
							<td>'+cast(@nm_veiculo as varchar(120))+'</td>
						</tr>
						

					 </table>	
                     <table>
                     <tr>
						<th>Quantidade</th>
						<th>Un.</th>
						<th>Código</th>
						<th>Produto</th>
						<th>Cód Barra</th>
						<th>Lote</th>
						<th>Localização</th>
					 </tr>'
--------------------------------------------------------------------------------------------------------------------
while exists ( select cd_controle from #Detalhe )  
begin  
  
  select top 1  
    @id           = cd_controle,  
 --@nm_pedido    = @nm_pedido  + ' ' + cast(cd_pedido_venda as varchar(15)),  

    @html_detalhe = @html_detalhe + '  
           <tr>      
            <td>'+cast(qt_produto as varchar(20))+'</td>  
			<td>'+cast(sg_unidade_medida as varchar(5))+'</td>  
			<td>'+cast(cd_mascara_produto as varchar(30))+'</td>  
			<td><div style="width: 20px; height: 20px; border: 2px solid black; display: inline-block;"></div></td>   
		    <td style="text-align: left">'+cast(nm_produto as varchar(120))+'</td>     
            <td>'+cast(cd_codigo_barra_produto as varchar(20))+'</td>     
		    <td>'+cast(nm_lote_produto as varchar(10))+'</td>     
            <td>'+cast(nm_grupo_localizacao + ' '+qt_posicao_localizacao as varchar(15))+'</td> 

           </tr>'  
         
  from  
    #Detalhe  
  
  order by  
    cd_controle  
      
   --select @html_detalhe

  delete from #Detalhe  
  where  
    cd_controle = @id  
  
  
end  


--Exec em SQl com Texto
--While---
--Campos do Html

set @nm_fantasia_cliente     = '' --'Resumo dos Pedidos de Vendas'
set @nm_razao_social_cliente = '' --@nm_pedido


set @html_titulo = '<div class="section-title"><strong>'+isnull(@titulo,'')+'</strong></div>
                    <div style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">
					 <p><strong>'+isnull(@nm_fantasia_cliente,'')+'</strong></p>
					</div>
 	               <div style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">
	            	<p><strong>'+isnull(@nm_razao_social_cliente,'')+'</strong></p>	            	
	</div>'
	   	 
--------------------------------------------------------------------------------------------------------------------

--Criar uma tabela temporario com os Dados dos atributos


SET @html_rod_det = '</table>'  
  
declare @html_totais nvarchar(max)=''  
declare @titulo_total varchar(500)=''  
  
set @titulo_total = ' '  
set @html_totais = '<div class="section-title"><strong>'+@titulo_total+'</strong>
                      <p style="font-size:20px;">Total Produtos: '+ cast(@qt_total_produto as varchar(15)) + '</p>
					</div>'  
  
  
  
set @footerTitle = ''  

--Rodapé--

set @html_rodape =
    '<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <div class="section-title"><strong>Observações</strong></div>
    <p>'+@ds_relatorio+'</p>
	<div class="report-date-time">
       <p>Gerado em: '+@data_hora_atual+'</p>
    </div>'



--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +
	@html_cab_det +
    @html_detalhe +
	@html_rod_det +
	@html_totais  + 
    @html_rodape  

---------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------
--select @html_rodape as html_empresa
----------------------------------------------------------------------------------------------------------------------------------------------
go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_preparacao_carga 16,79630,0,''
------------------------------------------------------------------------------


