IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_inventario_produto' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_inventario_produto

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_inventario_produto
-------------------------------------------------------------------------------
--pr_egis_relatorio_inventario_produto
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
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
create procedure pr_egis_relatorio_inventario_produto
@cd_relatorio int   = 0,
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
declare @cd_documento           int = 0
declare @cd_item_documento      int = 0
declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @cd_relatorio_form      int

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
set @cd_parametro      = 0
set @cd_modulo         = 0
set @cd_empresa        = 0
set @cd_menu           = 0
set @cd_processo       = 0
set @cd_item_processo  = 0
set @cd_form           = 0
set @cd_parametro      = 0
set @cd_documento      = 0
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
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'
  select @cd_relatorio_form      = valor from #json where campo = 'cd_relatorio_form'

   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'
     select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'

   end

   --if @cd_relatorio_form>0
   --begin
   --   set @cd_relatorio = @cd_relatorio_form
   --end

end


-------------------------------------------------------------------------------------------------
declare @ic_processo char(1) = 'N'
 

select
  @titulo      = nm_relatorio,
  @ic_processo = isnull(ic_processo_relatorio, 'N')
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio

--select @cd_relatorio
--return

----------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------

 --select @cd_processo as cd_processo, @json as jsonT into JsonProcesso
  --select * from JsonProcesso
  --drop table JsonProcesso

-----------------------------------------------------------------------------------------
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

--select @cd_relatorio
--return


declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabeçalho da Empresa
declare @html_grafico    nvarchar(max) = '' --Gráfico
declare @html_titulo     nvarchar(max) = '' --Título
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe
declare @html_rodape     nvarchar(max) = '' --Rodape

declare @data_hora_atual nvarchar(50)  = ''

set @html         = ''
set @html_empresa = ''
set @html_grafico = ''
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

-----------------------
--Cabeçalho da Empresa----------------------------------------------------------------------------------------------------------------------
-----------------------

SET @html_empresa = '
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title >'+@titulo+'</title>
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
            background-color: '+@nm_cor_empresa+';
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
            color: '+@nm_cor_empresa+';
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


--Procedure de Cada Relatório-------------------------------------------------------------------------------------

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

order by qt_ordem_atributo

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

drop table #AuxRelAtributo


--select @nm_dados_cab_det

--select * from #RelAtributo


set @html_cab_det = '<div class="section-title"><strong> '+@nm_grupo_relatorio + ' </strong></div> 
                     <table>
                     <tr>'
					 +
					 isnull(@nm_dados_cab_det,'')
                     + '</tr>'

--------------------------------------------------------------------------------------------------------------------------

set @html_detalhe = '' --valores da tabela

--select * from parametro_relatorio
--delete from parametro_relatorio
--update parametro_relatorio


---> CCF <----
---> alteração com o processo do relatório

declare @vl_total decimal(25,2) = 0.00
declare @qt_total int = 0

select
  i.cd_produto,
  sum(isnull(i.qt_saldo_pedido_venda,0)) as qt_saldo

into #Carteira

from
  pedido_venda_item i

where
  i.dt_cancelamento_item is null
  and
  isnull(i.qt_saldo_pedido_venda,0)>0

group by
  i.cd_produto

--Posição de Estoque---

select
  --identity(int,1,1)                     as cd_controle,
  1                                     as cd_item,
  isnull(cp.nm_categoria_produto,'')    as nm_categoria_produto, 
  isnull(p.cd_mascara_produto,'')       as cd_mascara_produto,
  isnull(p.nm_produto,'')               as nm_produto,
  isnull(um.sg_unidade_medida,'')       as sg_unidade_medida,
  isnull(p.qt_multiplo_embalagem,1)     as qt_multiplo_embalagem,
  isnull(ps.qt_saldo_reserva_produto,0) as qt_saldo_reserva_produto,
  isnull(ps.qt_saldo_atual_produto,0)   as qt_saldo_atual_produto,
  isnull(c.qt_saldo,0)                  as qt_saldo,
  isnull(ps.qt_minimo_produto,0)        as qt_estoque_minimo,
  ISNULL(fp.nm_fase_produto,'')         as nm_fase_produto

into #AuxInventario

from
  produto p
  inner join produto_custo pc          on pc.cd_produto           = p.cd_produto
  inner join produto_saldo ps          on ps.cd_produto           = p.cd_produto            and
                                          ps.cd_fase_produto      = p.cd_fase_produto_baixa
  left outer join categoria_produto cp on cp.cd_categoria_produto = p.cd_categoria_produto
  left outer join unidade_medida um    on um.cd_unidade_medida    = p.cd_unidade_medida
  left outer join #Carteira c          on c.cd_produto            = p.cd_produto
  left outer join Fase_Produto fp      on fp.cd_fase_produto      = p.cd_fase_produto_baixa

where
  --Produto Controla estoque
  isnull(pc.ic_estoque_produto,'N') = 'S'
  ---------------------------------------------------------------------------------------------------
  and
  isnull(p.ic_wapnet_produto,'N') = 'S'
  and
  isnull(p.cd_status_produto,0) = 1
  --and


--select @qt_disponivel = sum(qt_saldo_reserva_produto)

insert into #AuxInventario
select
  0                                          as cd_item,
  nm_categoria_produto,
  max(cast('' as varchar(30)))               as cd_mascara_produto,
  max(cast('' as varchar(120)))              as nm_produto,
  max(cast('' as varchar(30)))               as sg_unidade_medida,
  max(cast(0.00 as decimal(25,2)))           as qt_multiplo_embalagem,
  max(isnull(0,0))                           as qt_saldo_reserva_produto,
  max(isnull(0,0))                           as qt_saldo_atual_produto,
  max(isnull(0,0))                           as qt_saldo,
  max(isnull(0,0))                           as qt_estoque_minimo,
  MAX(isnull('',''))                         as nm_fase_produto

from
  #AuxInventario

group by
  nm_categoria_produto

select
  IDENTITY(int,1,1) as cd_controle,
  *
into #Inventario
from
  #AuxInventario
order by
  nm_categoria_produto, cd_item, cd_mascara_produto  

--select * from #Inventario
--order by
--  nm_categoria_produto, cd_item, cd_mascara_produto

  --drop table #Carteira
  --drop table #Inventario
  	 	 	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--select * from #Inventario


--select * from #FinalFaturamentoEmpresaVendedor

---------------------------------------------------------------------------------------------------------------------------

----montagem do Detalhe-----------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------

--<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_data_string(dt_pedido_venda)+'</td>

declare @id int = 0
declare @dados_relatorio nvarchar(max) = ''

set @html_detalhe    = ''
set @dados_relatorio = '["000 empresa", "task"], '


		  --["000 empresa", "task"],
		 -- ["001 SORVETES PIMPINELLA", 2.9],
		 -- ["002 SORVETES PIMPINELLA", 3100.90],
		 -- ["003 SORVETES PIMPINELLA", 1001.90],
		 -- ["004 SORVETES PIMPINELLA", 1002.90]

declare @cd_item int = 0

while exists ( select top 1 cd_controle from #Inventario )
begin


  select 
    top 1
    @id              = cd_controle,
    @cd_item         = cd_item,
	
	--@dados_relatorio = @dados_relatorio + '["'+nm_fantasia_cliente+'", '+cast(vl_total_pedido_ipi as varchar(30))+'],',


	--@nm_pedido    = @nm_pedido  + ' ' + cast(cd_pedido_venda as varchar(15)),

    @html_detalhe = @html_detalhe 
	         +
			 case when cd_item = 0 then 
			 '<tr> 
			 <td style="font-size:12px; text-align:center;width: 20px"><b>'+ nm_categoria_produto+'</b></td>
			 </tr>'

			 else

            '<tr> 					           
			<td style="font-size:12px; text-align:center;width: 20px">'+ CAST('' as varchar(30)) +'</td>
			<td style="font-size:12px; text-align:center;width: 20px">'+ cd_mascara_produto+'</td>
			<td style="font-size:12px; text-align:left;  width: 20px">'+ nm_produto+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+ sg_unidade_medida+'</td>	
			<td style="font-size:12px; text-align:center;width: 20px">'+ cast(qt_multiplo_embalagem as varchar(20))+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+ cast(qt_saldo_reserva_produto as varchar(20))+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+ cast(qt_saldo_atual_produto as varchar(20))+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+ cast(qt_saldo as varchar(20))+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+ cast(qt_estoque_minimo as varchar(20))+'</td>						
			<td style="font-size:12px; text-align:center;width: 20px">'+ nm_fase_produto+'</td>	
            </tr>'
	
	        end

		--use egissql_317

  from
    #Inventario

  order by
    nm_categoria_produto, cd_item, cd_mascara_produto
	   

  delete from #Inventario
  where
    cd_controle = @id


end

--set @dados_relatorio = substring(@dados_relatorio,1,len(@dados_relatorio) - 1)


--select @html_detalhe

--Exec em SQl com Texto
--While---
--Campos do Html

set @nm_fantasia_cliente     = '' --'Resumo dos Pedidos de Vendas'
set @nm_razao_social_cliente = '' --@nm_pedido


set @html_titulo = '<div class="section-title"><strong>'+@titulo+'</strong></div>
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

set @titulo_total = 'TOTAL'
set @html_totais = '<div class="section-title"><strong>'+@titulo_total+'</strong></div>
                    <div> 
                    <tr>					
					<td style="font-size:12px; text-align:center;width: 80px;">'+cast(@qt_total as varchar(10))+'</td>
					<td style="font-size:12px; text-align:center;width: 80px;">'+cast('----' as varchar(10))+'</td>
			        <td style="font-size:12px; text-align:center;width: 80px;">'+'R$ '+dbo.fn_formata_valor(@vl_total)+'</td>
					</tr>
					</div>'

--<td style="font-size:12px; text-align:center;width: 80px;">'+'R$ '+dbo.fn_formata_valor(@vl_total)+'</td>

set @footerTitle = ''

--Rodapé--

set @html_rodape =
    '<div class="company-info">
		<p><strong>'+@footerTitle+'</strong> ''</p>
	</div>
    <div class="section-title"><strong>Observações</strong></div>
    <p>'+@ds_relatorio+'</p>
	<div class="report-date-time">
       <p>Gerado em: '+@data_hora_atual+'</p>
    </div>'

--set @dados_relatorio = @dados_relatorio

--select @dados_relatorio, @titulo

		  --["000 empresa", "task"],
		  --["001 SORVETES PIMPINELLA", 2.9],
		  --["002 SORVETES PIMPINELLA", 3100.90],
		  --["003 SORVETES PIMPINELLA", 1001.90],
		  --["004 SORVETES PIMPINELLA", 1002.90]

--Gráfico--

set @html_grafico = ''

--set @html_grafico = '<head>
--    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
--    <script type="text/javascript">
--      google.charts.load("current", {"packages":["corechart"]});
--      google.charts.setOnLoadCallback(drawChart);

--      function drawChart() {

--        var data = google.visualization.arrayToDataTable(['+
--		@dados_relatorio
--		+
--		'         

--        ]);

--        var options = {
--          title: "'+@titulo+ '
--        };

--        var chart = new google.visualization.PieChart(document.getElementById("piechart"));

--        chart.draw(data, options);
--      }
--    </script>
--  </head>
--  <body>
--    <div id="piechart" style="width: 900px; height: 500px;"></div>
--  </body>'

--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +
	@html_cab_det +
    @html_detalhe +
	@html_rod_det +
	@html_totais  +
	@html_grafico +
    @html_rodape  

--select @html, @html_empresa, @html_titulo, @html_cab_det, @html_rod_det, @html_totais, @html_grafico, @html_rodape

-------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------
go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_inventario_produto 39,''
------------------------------------------------------------------------------


