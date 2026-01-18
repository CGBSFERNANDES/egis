IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_analise_expansao_cliente' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_analise_expansao_cliente

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_analise_expansao_cliente
-------------------------------------------------------------------------------
--pr_egis_relatorio_analise_expansao_cliente
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
create procedure pr_egis_relatorio_analise_expansao_cliente
@cd_relatorio int   = 0,
@cd_usuario   int   = 0,
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
--declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
declare @cd_item_documento      int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @cd_grupo_relatorio     int = 0


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
			@nm_fantasia_vendedor       varchar(500)   = '',
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
set @cd_modulo         = 0
set @cd_empresa        = 0
set @cd_menu           = 0
set @cd_processo       = 0
set @cd_item_processo  = 0
set @cd_form           = 0
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
  --select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'

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
  top 1 
  @cd_grupo_relatorio = isnull(cd_grupo_relatorio,0),
  @titulo             = nm_relatorio,
  @ic_processo        = isnull(ic_processo_relatorio, 'N')
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio

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

declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabeçalho da Empresa
declare @html_tabela     nvarchar(max) = '' --Tabela Google--
declare @html_grafico    nvarchar(max) = '' --Gráfico
declare @html_titulo     nvarchar(max) = '' --Título
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe
declare @html_rodape     nvarchar(max) = '' --Rodape
declare @html_totais     nvarchar(max) = '' --Totais
declare @html_geral      nvarchar(max) = '' --Geral

declare @titulo_total    varchar(500)  = ''

declare @data_hora_atual nvarchar(50)  = ''

set @html         = ''
set @html_empresa = ''
set @html_grafico = ''
set @html_tabela  = ''
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


--Chamada dos Parametros do Relatório---

--declare @cd_tipo_pedido int

select
  @dt_inicial     = dt_inicial,
  @dt_final       = dt_final,
  @cd_vendedor    = isnull(cd_vendedor,0),
  @cd_cliente     = isnull(cd_cliente,0),
  @cd_tipo_pedido = 0 --cd_tipo_pedido
from 
  Parametro_Relatorio

where
  cd_relatorio = @cd_relatorio
  and
  cd_usuario   = @cd_usuario


select
  distinct
  identity(int,1,1) as cd_controle,
  c.cd_cliente,
  c.cd_vendedor,
  case when c.dt_ativacao_cliente is not null then 
    c.dt_ativacao_cliente
  else
    c.dt_cadastro_cliente
  end                                                    as dt_cadastro_cliente,
  isnull( (select sum(isnull(vw.vl_total_item_pedido,0))
          from
            vw_venda_bi vw     where vw.cd_cliente             = c.cd_cliente and
                                  year(vw.dt_pedido_venda)  = @cd_ano      and
                                  month(vw.dt_pedido_venda) = case when @cd_mes=0 then month(vw.dt_pedido_venda) else @cd_mes end and
                                          dt_cancelamento_item is null and
                                          vw.cd_vendedor            = case when @cd_vendedor=0 then vw.cd_vendedor else @cd_vendedor end ),0)
  as 'Total_Venda',
  --Dados
       c.nm_fantasia_cliente    as 'cliente',
       c.dt_cadastro_cliente    as 'cadastro',  
       sc.nm_status_cliente     as 'status',
      isnull((select 
         v.nm_fantasia_vendedor 
       from 
         Vendedor v
       where
         v.cd_vendedor=c.cd_vendedor_interno),'Não Cadastrado') as 'VendInterno',
       case when isnull(c.cd_ddd,'') <> '' then
           '('+rtrim(cast(c.cd_ddd as varchar))+') '+c.cd_telefone
       else
         c.cd_telefone end	as 'Telefone',
       e.sg_estado		as 'UF',
       f.nm_fonte_informacao	as 'FonteInformacao',
       ve.nm_fantasia_vendedor  as 'Vendedor',
       cid.nm_cidade            as 'Cidade'


into
  #Cadastro

from
  Cliente c
  left outer join status_cliente sc  on sc.cd_status_cliente   = c.cd_status_cliente
  left outer join Fonte_Informacao f on c.cd_fonte_informacao  = f.cd_fonte_informacao
  left outer join Vendedor ve        on ve.cd_vendedor         = c.cd_vendedor
 
  left outer join Estado e           on c.cd_estado = e.cd_estado and
                                        c.cd_pais   = e.cd_pais

  left outer join cidade cid         on cid.cd_cidade          = c.cd_cidade and
                                        cid.cd_estado          = c.cd_estado


where
  c.dt_cadastro_cliente between @dt_inicial and @dt_final

  and c.cd_vendedor = 
				(case IsNull(@cd_vendedor,0)
				 when 0 then c.cd_vendedor
				 else @cd_vendedor
				 end)

 and isnull(sc.ic_analise_status_cliente,'N')='S'

order by
  c.dt_cadastro_cliente desc

 
--select * from #Cadastro -- dt_cadastro_cliente, Total_Venda,cd_cliente, cliente, status, Vendedor, Cidade, UF


--select @html_empresa
declare @id int = 0
--Grafico

 if isnull(@cd_parametro,0) = 3
 begin
	select
  identity(int,1,1) as id,
  YEAR(c.dt_cadastro_cliente)  as ano,
  MONTH(c.dt_cadastro_cliente) as mes,
  max(m.nm_mes)                as nm_mes,
  COUNT(c.cd_cliente)          as qt_cliente,
  SUM( isnull(n.vl_total,0))   as vl_faturamento
  into
	#tempGrafico
from
  Cliente c
  left outer join Mes m        on m.cd_mes     = MONTH(c.dt_cadastro_cliente)
  left outer join Nota_Saida n on n.cd_cliente = c.cd_cliente and n.cd_status_nota<>7 
  
  and YEAR(n.dt_nota_saida) = YEAR(c.dt_cadastro_cliente) 
  and MONTH(n.dt_nota_saida) = MONTH(c.dt_cadastro_cliente)
where
  c.cd_status_cliente = 1
 
  and

  YEAR(c.dt_cadastro_cliente)=year(@dt_final)


group by
  YEAR(c.dt_cadastro_cliente),
  MONTH(c.dt_cadastro_cliente)
  
 order by
  1,
  2

  declare @cd_controle int = 0
  declare @cab    nvarchar(max) = ''
  declare @dados  nvarchar(max) = ''
  declare @valor1 nvarchar(max) = ''
  declare @valor2 nvarchar(max) = ''
  declare @label  nvarchar(max) = ''
  declare @final  nvarchar(max) = ''
  
  while exists(select top 1 id from #tempGrafico)
  begin

	select top 1 
	        @cd_controle = id, 
			@valor1      = CAST(nm_mes     as varchar(20)),
			@valor2      = CAST(qt_cliente as varchar(10)),
			@label       = 'Mes'
			
	        
	  from #tempGrafico

	  set @cab         = '[{ label: '''+@label+ ''', id: '''+@label+''' }, { label: ''cliente'''+', id: ''cliente'' }], '
		
		

	  set @dados = @dados + '[ '''+@valor1+''' , '+@valor2+']' 
	  	   
	  delete #tempGrafico where id = @cd_controle

	  if exists( select top 1 id from #tempGrafico )
	  begin
	    set @dados = @dados + ', '
	  end

  end

  set @final = '['+@cab + @dados + ']';
  --Grid

    select a.*, g.nm_grupo_relatorio into #RelAtributoG 
    from
      egisadmin.dbo.Relatorio_Atributo a with(nolock)
      left outer join egisadmin.dbo.relatorio_grupo g with(nolock) on g.cd_grupo_relatorio = a.cd_grupo_relatorio
    where 
      a.cd_relatorio = @cd_relatorio
    order by
      qt_ordem_atributo
    
    declare @cd_item_relatorio  int           = 0
    declare @nm_cab_atributo    varchar(100)  = ''
    declare @nm_dados_cab_det   nvarchar(max) = ''
    declare @nm_grupo_relatorio varchar(60)   = ''
    
    
    --select * from egisadmin.dbo.relatorio_grupo
    
    select * into #AuxRelAtributoG from #RelAtributoG order by qt_ordem_atributo
     --select * from #AuxRelAtributoG
    while exists ( select top 1 cd_item_relatorio from #AuxRelAtributoG order by qt_ordem_atributo)
    begin
    
      select top 1 
        @cd_item_relatorio  = cd_item_relatorio,
    	@nm_cab_atributo    = nm_cab_atributo,
    	@nm_grupo_relatorio = nm_grupo_relatorio
      from
        #AuxRelAtributoG
      order by
        qt_ordem_atributo
    

      set @nm_dados_cab_det = @nm_dados_cab_det + '{ label: '''+ @nm_cab_atributo+''', id: '''+@nm_cab_atributo+''' }, '
    
      delete from #AuxRelAtributoG
      where
        cd_item_relatorio = @cd_item_relatorio
    
    end
	set @nm_dados_cab_det = '['+SUBSTRING(@nm_dados_cab_det, 0,len(@nm_dados_cab_det))+'],'
	----Dados da Grid
	declare @final_grid  nvarchar(max) = ''
	declare @dados_grid  nvarchar(max) = ''
	declare @valor_grid1 nvarchar(max) = ''
    declare @valor_grid2 nvarchar(max) = ''
	declare @valor_grid3 nvarchar(max) = ''
    declare @valor_grid4 nvarchar(max) = ''
    declare @valor_grid5 nvarchar(max) = ''
	declare @valor_grid6 nvarchar(max) = ''
	declare @valor_grid7 nvarchar(max) = ''
	while exists ( select top 1 cd_controle from #Cadastro )
       begin
        
	     --- dados do relatório----
         select 
           top 1
           @id           = cd_controle,
	       @valor_grid1  = dbo.fn_data_string(isnull(dt_cadastro_cliente,'')), --'DATA',
		   @valor_grid2  = isnull(cd_cliente,''),          --'Código', 
		   @valor_grid3  = ltrim(rtrim(isnull(cliente,''))),             --'Cliente', 
		   @valor_grid4  = dbo.fn_formata_valor(isnull(Total_Venda,0)),         --'Total Vendas', 
		   @valor_grid5  = ltrim(rtrim(isnull(Vendedor,''))),            --'Vendedor', 
		   @valor_grid6  = ltrim(rtrim(isnull(Cidade,''))),              --'Cidade', 
		   @valor_grid7  = ltrim(rtrim(isnull(UF,'')))                   --'UF' 
          from
            #Cadastro
	        
				 set @dados_grid = @dados_grid + '[ '''+@valor_grid1+''' , '''+@valor_grid2+''' , '''+@valor_grid3+''' ,'''+@valor_grid4+''' , '''+@valor_grid5+''' , '''+@valor_grid6+''' , '''+@valor_grid7+''']' 

	       if exists( select top 1 cd_controle from #Cadastro )
	       begin
	         set @dados_grid = @dados_grid + ', '
	       end
       
       delete from #Cadastro
       where
         cd_controle = @id

      end
    set @final_grid = '['+@nm_dados_cab_det + @dados_grid + ']';
  --select @final_grid, @nm_dados_cab_det, @dados_grid 
    declare @qtd_clientes int = 0
    select
      @qtd_clientes = COUNT(c.cd_cliente)    
    from
      Cliente c
    where
      c.cd_status_cliente = 1
      and
      c.dt_cadastro_cliente < @dt_inicial


--select @final, @titulo, @final_grid, @nm_cor_empresa, @logo ,@qtd_clientes, @dt_final, @nm_fantasia_empresa, @cd_numero_endereco_empresa, @cd_cep_empresa, @nm_cidade, @sg_estado, @nm_pais, @cd_telefone_empresa, @cd_cnpj_empresa, @cd_inscestadual_empresa, @nm_dominio_internet,
--       @nm_email_internet
   


	set @html_grafico = '<html>
	                        <meta charset="UTF-8">
                            <meta http-equiv="X-UA-Compatible" content="IE=edge">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">

<head>
  <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
  <script type="text/javascript">
    google.charts.load("current", { "packages": ["corechart"] });
    google.charts.setOnLoadCallback(drawChart);
	google.charts.setOnLoadCallback(drawColumnChart);

    function drawChart() {
      var data = google.visualization.arrayToDataTable('+@final+');

      var options = {
        title: '''+@titulo+''',
        pieSliceText: ''value'',
        is3D: true,
      };

      var chart = new google.visualization.PieChart(document.getElementById("piechart"));
	  
      chart.draw(data, options);
    }

	function drawColumnChart() {
      var data = google.visualization.arrayToDataTable('+@final+');

      var options = {
        title: '''+@titulo+''',
        pieSliceText: ''value'',
      };

	  var chart = new google.visualization.ColumnChart(document.getElementById("columnchart"));
	  
      chart.draw(data, options);
    }
  </script>

  <script type="text/javascript">
      google.charts.load("current", {"packages":["table"]});
      google.charts.setOnLoadCallback(drawTable);

      function drawTable() {
        var data = google.visualization.arrayToDataTable('+@final_grid+');

        var table = new google.visualization.Table(document.getElementById("table_div"));

        table.draw(data, { "width": "100%", "height": "100%"});
      }
    </script>
</head>

<body>
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
		.cardGrafico {
		    display: flex;
            justify-content: center;
			align-content: center;
            align-items: center;
			text-align: center;
		}
		.infoGrafico {
		    display: flex;
            justify-content: center;
			align-content: center;
            align-items: center;
			text-align: center;
		}
		.separador {
            bottom: 0;
            left: 0;
            width: 100%;
            height: 35px;
			margin:5px;
			border-radius: 10px;
            background-color:#ff6f00;
            color: white;
            text-align: center;
            display: flex;
            justify-content: center;
            align-items: center;
        }
    </style>
     <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:45%; margin-right:20px">
			<img src="'+@logo+'" alt="Logo da Empresa">
		</div>
		<div style="width:70%; padding-left:10px">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
		    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
		</div>    
    </div>
	 <div class="separador" style="font-weight: bold; font-size: 18px">'+@titulo+' - Data Base : '+dbo.fn_data_string(@dt_final) +'</div>
	 <div style="background-color: #EEEEEE; height: 100%;">
	   <div class="infoGrafico" style="margin:5px;">
	      <div class="col-3" style="border: 2px solid #64B5F6; border-radius: 5px; padding: 5px; font-weight: bold; margin:5px; background-color: white"> Base Compradora - '+cast(@qtd_clientes as varchar(50))+'</div>
		  <div class="col-3" style="border: 2px solid #64B5F6; border-radius: 5px; padding: 5px; font-weight: bold; margin:5px; background-color: white"> Clientes Novos - '+cast(@qtd_clientes as varchar(50))+'</div>
		  <div class="col-3" style="border: 2px solid #64B5F6; border-radius: 5px; padding: 5px; font-weight: bold; margin:5px; background-color: white"> (%) Positivação - '+cast(@qtd_clientes as varchar(50))+'</div>
		  <div class="col-3" style="border: 2px solid #64B5F6; border-radius: 5px; padding: 5px; font-weight: bold; margin:5px; background-color: white"> Faturamento - '+cast(@qtd_clientes as varchar(50))+'</div>
		  <div class="col-3" style="border: 2px solid #64B5F6; border-radius: 5px; padding: 5px; font-weight: bold; margin:5px; background-color: white"> Equipamentos - '+cast(@qtd_clientes as varchar(50))+'</div>
	   </div>
	   <div class="cardGrafico" style="margin:5px;"> 
	     <div style="border: 2px solid #64B5F6; border-radius: 12px; padding: 5px;">
           <div id="piechart"    style="width: 900px; height: 500px;"></div>
		   <div id="columnchart" style="width: 900px; height: 500px;"></div>
		   <div id="table_div"   style="width: 900px; height: 500px;"></div>
	  	 </div>
	   </div>
	 </div>
</body>

</html>'

--set @html_tabela = 
--'<html>
--  <head>
--    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
--    <script type="text/javascript">
--     google.charts.load("current", { "packages": ["corechart"] });
--      google.charts.setOnLoadCallback(drawTable);

--      function drawTable() {
--        var data = new google.visualization.DataTable();

--        var table = new google.visualization.Table(document.getElementById("table_div"));
--        table.draw(data, {showRowNumber: true, width: ''100%'', height: ''100%''});
--      }
--    </script>
--  </head>
--  <body>
--    <div id="table_div"></div>
--  </body>
--</html>
--'



--set @html_grafico = @html_grafico + @html_tabela

    drop table #tempGrafico
	select isnull(@html_grafico,'') as RelatorioHTML
  return
 end

--Detalhe--

--Procedure de Cada Relatório-------------------------------------------------------------------------------------

--declare @cd_item_relatorio  int           = 0
--declare @nm_cab_atributo    varchar(100)  = ''
--declare @nm_dados_cab_det   nvarchar(max) = ''
--declare @nm_grupo_relatorio varchar(60)   = ''
--declare @cd_grupo_relatorio int           = 0

--------------------------------------------------------------------------------------------------------------------

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
 if isnull(@cd_parametro,0) = 2
 begin
  select * from #RelAtributo
  return
end

--select * from parametro_relatorio
--delete from parametro_relatorio
--update parametro_relatorio


--Chamada dos Parametros do Relatório---

--declare @cd_tipo_pedido int

select
  @dt_inicial     = dt_inicial,
  @dt_final       = dt_final,
  @cd_vendedor    = cd_vendedor,
  @cd_cliente     = cd_cliente,
  @cd_tipo_pedido = 0 --cd_tipo_pedido
from 
  Parametro_Relatorio
where
  cd_relatorio = @cd_relatorio
  and
  cd_usuario   = @cd_usuario

--select @dt_inicial, @dt_final


---> CCF <----
---> alteração com o processo do relatório

declare @vl_total          decimal(25,2) = 0.00
declare @qt_total          int = 0
declare @vl_total_vendedor decimal(25,2) = 0.00
declare @qt_total_vendedor int = 0

--declare @cd_usuario     int = 0
--declare @cd_cliente     int = 0
--declare @cd_vendedor    int = 0
--declare @cd_tipo_pedido int = 0
--set @dt_inicial = '01/01/2025'
--set @dt_final   = '01/03/2025'
--função de buscar o vendedor do cadastro
if @cd_usuario>0 
   set @cd_vendedor = dbo.fn_usuario_vendedor(@cd_usuario)

--set @cd_vendedor    = 7
--set @cd_tipo_pedido = 0

select
  pv.dt_pedido_venda,
  pv.cd_pedido_venda,
  pv.cd_tipo_pedido,
  tp.nm_tipo_pedido,
  sp.sg_status_pedido,
  pv.cd_cliente,
  c.nm_fantasia_cliente,
  c.nm_razao_social_cliente,
  isnull(pv.vl_total_pedido_ipi,0)    as vl_total_pedido_ipi,
  isnull(est.sg_estado,'')            as sg_estado,
  isnull(cid.nm_cidade,'')            as nm_cidade,
  isnull(cp.sg_condicao_pagamento,'') as sg_condicao_pagamento,
  isnull(cg.nm_cliente_grupo,'')      as nm_cliente_grupo,
  isnull(v.nm_fantasia_vendedor,'')   as nm_fantasia_vendedor

into #PedidoVendedor

from
  pedido_venda pv
  inner join cliente c                  on c.cd_cliente             = pv.cd_cliente
  left outer join cliente_grupo cg      on cg.cd_cliente_grupo      = c.cd_cliente_grupo
  inner join vendedor v                 on v.cd_vendedor            = pv.cd_vendedor
  left outer join estado est            on est.cd_estado            = c.cd_estado
  left outer join cidade cid            on cid.cd_cidade            = c.cd_cidade
  left outer join condicao_pagamento cp on cp.cd_condicao_pagamento = pv.cd_condicao_pagamento
  left outer join tipo_pedido tp        on tp.cd_tipo_pedido        = pv.cd_tipo_pedido
  left outer join Status_Pedido sp      on sp.cd_status_pedido      = pv.cd_status_pedido
 where
   pv.dt_pedido_venda between @dt_inicial and @dt_final
   and
   pv.cd_tipo_pedido = case when isnull(@cd_tipo_pedido,0) = 0 then pv.cd_tipo_pedido else isnull(@cd_tipo_pedido,0) end
   and
   pv.cd_cliente     = case when ISNULL(@cd_cliente,0) = 0     then pv.cd_cliente else ISNULL(@cd_cliente,0) end
   and
   pv.cd_vendedor    = case when ISNULL(@cd_vendedor,0) =0      then pv.cd_vendedor else ISNULL(@cd_vendedor,0) end
   and
   pv.cd_pedido_venda in ( select i.cd_pedido_venda from pedido_venda_item i where i.cd_pedido_venda = pv.cd_pedido_venda and i.dt_cancelamento_item is null )
   and
   pv.cd_status_pedido <> 7

   order by
     tp.nm_tipo_pedido, pv.dt_pedido_venda desc, cid.nm_cidade, nm_fantasia_cliente

select
  @vl_total = sum(vl_total_pedido_ipi),
  @qt_total = count(cd_pedido_venda)

from
  #PedidoVendedor


select 
  identity(int,1,1) as cd_controle,
  *,
  pc_faturamento = cast(round(vl_total_pedido_ipi/@vl_total*100,2) as decimal(25,2))

into
  #FinalPedidoVendedor

from 
  #PedidoVendedor

order by
   nm_tipo_pedido, dt_pedido_venda desc, nm_cidade, nm_fantasia_cliente


 if isnull(@cd_parametro,0) = 1
 begin
    select * from  #FinalPedidoVendedor
  return
 end

---------------------------------------------------------------------------------------------------------------------------

----montagem do Detalhe-----------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------

--<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_data_string(dt_pedido_venda)+'</td>


set @html_detalhe = ''

--Cliente Positivado--


--Empresa--------------------------------------------------------------------

select
  tp.cd_tipo_pedido,
  tp.nm_tipo_pedido
  
  into #TipoPedido


from  
  #FinalPedidoVendedor f
  inner join tipo_pedido tp on tp.cd_tipo_pedido = f.cd_tipo_pedido

group by
 tp.cd_tipo_pedido,
 tp.nm_tipo_pedido

order by
  tp.cd_tipo_pedido

--------------------------------------------------------------------------------------------------


declare @nm_meta                varchar(100)  = ''
declare @qt_cliente             decimal(25,2) = 0
declare @vl_falta_meta          decimal(25,2) = 0.00
declare @pc_atingido_meta       decimal(25,2) = 0.00
declare @vl_meta                decimal(25,2) = 0.00
declare @qt_cliente_nota        decimal(25,2) = 0
declare @pc_positivacao         decimal(25,2) = 0
declare @cd_tipo_pedidoV        int         = 0
declare @nm_tipo_pedidoV        varchar(30) =  ''


 --select SUM(qt_cliente) as qt_cliente from #Vendedor

  --return

while exists( select Top 1 cd_tipo_pedido from #TipoPedido )
begin

  select Top 1
    @cd_tipo_pedidoV         = cd_tipo_pedido,
	@nm_tipo_pedidoV         = nm_tipo_pedido
  from
    #TipoPedido

  order by
    cd_tipo_pedido

  --Total do Vendedor---------------------------

    select
      @vl_total_vendedor = sum(vl_total_pedido_ipi),
      @qt_total_vendedor = count(cd_pedido_venda)
	  
	  	  
    from
	  #FinalPedidoVendedor
    where
	  cd_tipo_pedido = @cd_tipo_pedidoV


    --select @nm_fantasia_vendedor, @nm_meta, @pc_atingido_meta, @vl_falta_meta, @pc_positivacao, @qt_cliente, @qt_cliente_nota								

    set @html_cab_det = '<div class="section-title"><strong> '+'TIPO DE PEDIDO : '+@nm_tipo_pedidoV + ' </strong></div>    
                     <table>
                     <tr>'
					 +

					 +
					 isnull(@nm_dados_cab_det,'')
                     + '</tr>'

  --------------------------------------------------------------------------------------------------------------------------

  set @html_detalhe = '' --valores da tabela
     
  while exists ( select top 1 cd_controle from #FinalPedidoVendedor where cd_tipo_pedido = @cd_tipo_pedidoV)
  begin



    select 
      top 1
      @id           = cd_controle,
	--@nm_pedido    = @nm_pedido  + ' ' + cast(cd_pedido_venda as varchar(15)),
      @html_detalhe = @html_detalhe + '
            <tr> 					           			
			<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_data_string(dt_pedido_venda)+'</td>
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(cd_pedido_venda as varchar(20))+'</td>			
            <td style="font-size:12px; text-align:center;width: 20px">'+sg_status_pedido+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(cd_cliente as varchar(20))+'</td>			
            <td style="font-size:12px; text-align:left;width: 20px">'+nm_fantasia_cliente+'</td>			
			<td style="font-size:12px; text-align:left;width: 20px">'+nm_razao_social_cliente+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_formata_valor(vl_total_pedido_ipi)+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_formata_valor(pc_faturamento)+'</td>	
			<td style="font-size:12px; text-align:center;width: 20px">'+sg_estado+'</td>			
			<td style="font-size:12px; text-align:left;width: 20px">'+nm_cidade+'</td>			
			<td style="font-size:12px; text-align:left;width: 20px">'+sg_condicao_pagamento+'</td>			
			<td style="font-size:12px; text-align:left;width: 20px">'+nm_cliente_grupo+'</td>			
            <td style="font-size:12px; text-align:left;width: 20px">'+nm_fantasia_vendedor+'</td>			
            </tr>'
	
		--use egissql_317

     from
       #FinalPedidoVendedor

     where
       cd_tipo_pedido = @cd_tipo_pedidoV

     order by
         nm_tipo_pedido, dt_pedido_venda desc, nm_cidade, nm_fantasia_cliente
	   

  delete from #FinalPedidoVendedor
  where
    cd_controle = @id

 end

 --Totais do Vendedor--

 delete from #TipoPedido
   where cd_tipo_pedido = @cd_tipo_pedidoV

SET @html_rod_det = '</table>'


set @titulo_total = 'SUB-TOTAL'

set @html_totais = '<div class="section-title">'+@titulo_total+'
					<table style="border: none;">
                    <tr>										
					<td style="border: none;color: white;font-size:18px; text-align:center;width: 25px"><b>&nbsp</td>
			        <td style="border: none;color: white;font-size:18px; text-align:center;width: 20px"><b>'+cast(isnull(@qt_total_vendedor,0) as varchar(10))+'</td>
			        <td style="border: none;color: white;font-size:18px; text-align:left;width: 45px"><b>'+'R$ '+dbo.fn_formata_valor(isnull(@vl_total_vendedor,0))+'</td>	
					</tr>
					</table>					
					</div>'
					
 set @html_geral = @html_geral + 
                   @html_cab_det +
                   @html_detalhe +
	               @html_rod_det +
				   @html_totais

     
end







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


--SET @html_rod_det = '</table>'


set @titulo_total = 'TOTAIS'

set @html_totais = '<div class="section-title"><strong>'+@titulo_total+'</strong>
                    <div> 
					<table style="border: none;">
                    <tr>										
					<p style="border: none;color: white;font-size:18px; text-align:center;><b>&nbsp</td>
			        <p style="border: none;color: white;font-size:18px; text-align:center;"><b>'+cast(isnull(@qt_total,0) as varchar(10))+'</p>
			        <p style="border: none;color: white;font-size:18px; text-align:left;"><b>'+'R$ '+dbo.fn_formata_valor(isnull(@vl_total,0))+'</p>	
					</tr>
					</table>
					</div>
					</div>'

					--&nbsp

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


--Gráfico--
set @html_grafico = ''
-----------------------    

--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +

	--@html_cab_det +
 --   @html_detalhe +
	--@html_rod_det +

	@html_geral   + 
	@html_totais  +
	@html_grafico +
    @html_rodape  

--select 
--    @html         as html,
--    @html_empresa as html_empresa,
--    @html_titulo  as html_titulo,
--	@html_geral   as html_geral, 
--	@html_totais  as html_totais,
--	@html_grafico as html_grafico,
--    @html_rodape  as html_rodape

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
--exec pr_egis_relatorio_analise_expansao_cliente 176,4254,0,''
------------------------------------------------------------------------------


