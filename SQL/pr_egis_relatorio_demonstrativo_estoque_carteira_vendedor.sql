IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_demonstrativo_estoque_carteira_vendedor' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_demonstrativo_estoque_carteira_vendedor

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_demonstrativo_estoque_carteira_vendedor
-------------------------------------------------------------------------------
--pr_egis_relatorio_demonstrativo_estoque_carteira_vendedor
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Joao Pedro Marcal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relat�rio Padr�o Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025
--Altera��o        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_demonstrativo_estoque_carteira_vendedor
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
declare @ic_valor_comercial     varchar(10)
declare @cd_tipo_destinatario   int 
declare @cd_grupo_relatorio     int 
declare @cd_vendedor            int = 0

--Dados do Relat�rio---------------------------------------------------------------------------------

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
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_cidade_cliente			varchar(200) = '',
			@sg_estado_cliente			varchar(5)	= '',
			@cd_numero_endereco			varchar(20) = '',
			@nm_condicao_pagamento		varchar(100) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40)   = '',
			@footerTitle				varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = ''



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
   
  
select  
  @titulo             = nm_relatorio,  
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),  
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)  
from  
  egisadmin.dbo.Relatorio  
where  
  cd_relatorio = @cd_relatorio  
---------------------------------------------------------------------------------------------------------------------
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

-- Obtem a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------

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
            padding: 3px;
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
            font-size: 10px;
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

---------------------------------------------------------------------------------------------------------

  --set @dt_inicial = '04/01/2025'
  --set @dt_final = '04/30/2025'


    -- 1. Saldo por vendedor e produto
 SELECT
    i.cd_produto                            as cd_produto,
    v.nm_fantasia_vendedor                  as nm_fantasia_vendedor,
    SUM(ISNULL(i.qt_saldo_pedido_venda, 0)) as Saldo_teste
 
 into
 #PedidoVendedor

 FROM Pedido_Venda_Item i
   left outer JOIN Pedido_Venda pv ON i.cd_pedido_venda = pv.cd_pedido_venda
   left outer JOIN Vendedor v      ON v.cd_vendedor = pv.cd_vendedor
 WHERE 
     pv.dt_pedido_venda BETWEEN @dt_inicial and @dt_final
     and 
	 i.dt_cancelamento_item IS NULL
     and
	 ISNULL(i.qt_saldo_pedido_venda, 0) > 0

 GROUP BY 
 v.nm_fantasia_vendedor,
 i.cd_produto
	--select * from 
	
--Procedure de Cada Relat?rio-------------------------------------------------------------------------------------  
 
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
--  SELECT * FROM #PedidoVendedor
--select * from #PedidoVendedor
--select * from #RelAtributo
INSERT INTO #RelAtributo 
SELECT 
  @cd_relatorio                                     as cd_relatorio,
  ROW_NUMBER() OVER (ORDER BY nm_fantasia_vendedor) as cd_item_relatorio,
  @cd_usuario                                       as cd_usuario,
  GETDATE()                                         as dt_usuario, 
  @cd_usuario                                       as cd_usuario_inclusao,
  GETDATE()                                         as dt_usuario_inclusao,
  nm_fantasia_vendedor                              as nm_cab_atributo,
  nm_fantasia_vendedor                              as nm_atributo_relatorio,
  ''                                                as cd_tabela, 
  ''                                                as cd_atributo, 
  ROW_NUMBER() OVER (ORDER BY nm_fantasia_vendedor) as qt_ordem_atributo,
  44                                                as cd_grupo_relatorio,
  'N'                                               as ic_grafico_atributo, 
  ''                                                as nm_atributo,
  'Demonstrativo Estoque x Carteira por Vendedor'   as nm_grupo_relatorio
FROM #PedidoVendedor
GROUP BY nm_fantasia_vendedor

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
  
  --select * from #RelAtributo
if isnull(@cd_parametro,0) = 2  
 begin  
  select * from #RelAtributo  
  return  
end  
  
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)

--------------------------------------------------------------------------------------------------------------------------

    SELECT
        
		i.cd_produto,
        MAX(pv.dt_pedido_venda) AS dt_pedido_venda,
        SUM(ISNULL(i.qt_saldo_pedido_venda,0)) AS Saldo
    
	INTO #TotalVendaProduto
    
	FROM Pedido_Venda pv
		JOIN Pedido_Venda_Item i ON i.cd_pedido_venda = pv.cd_pedido_venda
    
	WHERE pv.dt_pedido_venda BETWEEN @dt_inicial AND @dt_final
      AND
	  i.dt_cancelamento_item IS NULL
      AND
	  ISNULL(i.qt_saldo_pedido_venda,0) > 0
    GROUP BY i.cd_produto;


    -- 3. Monta colunas dinâmicas
    DECLARE @cols NVARCHAR(MAX);
    
	SELECT @cols = STUFF((
        SELECT DISTINCT ',' + QUOTENAME(nm_fantasia_vendedor)
        FROM #PedidoVendedor
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')
    ,1,1,'');

    -- 4. Executa o PIVOT dinâmico em uma tabela global
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
    IF OBJECT_ID(''tempdb..##PedidoVendedorPivot'') IS NOT NULL DROP TABLE ##PedidoVendedorPivot;

    SELECT cd_produto, ' + @cols + '
    INTO ##PedidoVendedorPivot
    FROM (
        SELECT cd_produto, nm_fantasia_vendedor, Saldo_teste
        FROM #PedidoVendedor
    ) src
    PIVOT (
        SUM(Saldo_teste)
        FOR nm_fantasia_vendedor IN (' + @cols + ')
    ) AS pvt;';
    EXEC sp_executesql @sql;

    -- 5. CTEs para evitar duplicações e consolidar por produto
    ;WITH EstoqueUnico AS (
        SELECT 
            ps.cd_produto,
            MAX(ps.qt_saldo_reserva_produto) AS qt_saldo_reserva_produto,
            MAX(ps.qt_minimo_produto) AS qt_minimo_produto,
            MAX(ps.qt_producao_produto) AS qt_producao_produto
        FROM Produto_Saldo ps
		     inner join Produto p on p.cd_produto = ps.cd_produto and p.cd_fase_produto_baixa = ps.cd_fase_produto
        GROUP BY ps.cd_produto
    ),
    
	ProdutoUnico AS (
        SELECT 
            p.cd_produto,
            p.cd_mascara_produto,
            p.nm_produto,
            um.sg_unidade_medida,
            p.qt_multiplo_embalagem,
            cp.nm_categoria_produto,
            cp.qt_ordem_carga
        FROM Produto p
        LEFT JOIN Unidade_Medida um ON um.cd_unidade_medida = p.cd_unidade_medida
        LEFT JOIN Categoria_Produto cp ON cp.cd_categoria_produto = p.cd_categoria_produto
		
        where
         ISNULL(p.cd_status_produto,1) = 1
         and
         ISNULL(p.ic_wapnet_produto,'N') = 'S'

    )

    -- 6. Consulta final segura
    SELECT 
	    identity(int,1,1) as cd_controle,
      --  pu.cd_produto             as cd_produto,
        pu.cd_mascara_produto                 as cd_mascara_produto,
        pu.nm_produto                         as nm_produto,
        pu.sg_unidade_medida                  as sg_unidade_medida,
        pu.qt_multiplo_embalagem              as qt_multiplo_embalagem,
        pu.nm_categoria_produto               as nm_categoria_produto,
        pu.qt_ordem_carga                     as qt_ordem_carga,
        ISNULL(e.qt_saldo_reserva_produto, 0) as Disponivel,
        ISNULL(e.qt_minimo_produto, 0)        as qt_minimo_produto,
        ISNULL(e.qt_producao_produto, 0)      as qt_producao_produto,
        ISNULL(tv.Saldo, 0)                   as Saldo,
        case when ISNULL(e.qt_saldo_reserva_produto, 0) -  ISNULL(tv.Saldo, 0)>0 then  
		   ISNULL(e.qt_saldo_reserva_produto, 0) -  ISNULL(tv.Saldo, 0)
		else
		  0.00
		 end AS qt_atendimento,
        case when ISNULL(e.qt_saldo_reserva_produto, 0) -  ISNULL(tv.Saldo, 0)>0 then  
		  0.00
		else
		  case when ISNULL(e.qt_saldo_reserva_produto, 0) -  ISNULL(tv.Saldo, 0) <0 then
		  -1
		  else
		   1
		  end
		  *
		  (ISNULL(e.qt_saldo_reserva_produto, 0) -  ISNULL(tv.Saldo, 0) )
		end                                   as qt_necessidade,
		CONVERT(NVARCHAR, dt_pedido_venda, 103) AS dt_pedido_venda,
        pvt.*
    into
	#FinalVendedorProdutos
	FROM ProdutoUnico pu
       LEFT JOIN EstoqueUnico e ON pu.cd_produto = e.cd_produto
       LEFT JOIN #TotalVendaProduto tv ON pu.cd_produto = tv.cd_produto
       LEFT JOIN ##PedidoVendedorPivot pvt ON pu.cd_produto = pvt.cd_produto
	order by
	  pu.qt_ordem_carga, pu.cd_mascara_produto

	-- select * from #FinalVendedorProdutos 

	-- select * from #PedidoVendedor
------------------------------------------------------------------------------------------------------------		 
  --- select * from #FinalVendedorProdutos
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #FinalVendedorProdutos 
  return  
 end  
 DECLARE @sub_id int = 0 


--------------------------------------------------------------------------------------------------------------
set @html_geral = '
    <div class="section-title">  
	    <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
		<p style="display: inline; text-align: center; padding: 20%;">Demonstrativo Estoque x Carteira por Vendedor</p>
	</div>
	<div>
    <table>  
		<tr class="tamanho">
		  <th>Categoria</th>
		  <th>Código</th>
		  <th>Produto</th>
		  <th>Un.</th>
		  <th>Qtd. Embalagem</th>
		  <th>Ordem Carga</th>
		  <th>Disponivel</th>
		  <th>Minimo</th>
		  <th>Produção</th>
		  <th>Saldo</th>
		  <th>Atendimento</th>
		  <th>Necessidade</th>
		  <th>Pedido</th>'
DECLARE @nome_coluna NVARCHAR(100)

DECLARE vendedor_cursor CURSOR FOR
SELECT value
FROM STRING_SPLIT(REPLACE(REPLACE(@cols, '[', ''), ']', ''), ',')

OPEN vendedor_cursor
FETCH NEXT FROM vendedor_cursor INTO @nome_coluna

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @html_geral = @html_geral + '<th>' + @nome_coluna + '</th>'
    FETCH NEXT FROM vendedor_cursor INTO @nome_coluna
END

CLOSE vendedor_cursor
DEALLOCATE vendedor_cursor

SET @html_geral += '</tr>' 
--------------------------------------------------------------------------------------------------------------
DECLARE @id int = 0 
DECLARE @linha_html NVARCHAR(MAX)
Declare @cd_produto INT

declare @sql_saldo NVARCHAR(MAX)
declare @saldo NVARCHAR(50)

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #FinalVendedorProdutos)
BEGIN
    SELECT TOP 1
        @id          = cd_controle,
        @cd_produto  = cd_produto,
        @linha_html  = '
        <tr class="tamanho">
            <td>' + ISNULL(nm_categoria_produto, '') + '</td>
            <td>' + CAST(ISNULL(cd_mascara_produto, '') AS NVARCHAR(22)) + '</td>
            <td>' + ISNULL(nm_produto, '') + '</td>
            <td>' + ISNULL(sg_unidade_medida, '') + '</td>
            <td>' + CAST(ISNULL(qt_multiplo_embalagem, '') AS NVARCHAR(10)) + '</td>
            <td>' + CAST(ISNULL(qt_ordem_carga, '') AS NVARCHAR(10)) + '</td>
            <td>' + CAST(ISNULL(Disponivel, '') AS NVARCHAR(10)) + '</td>
            <td>' + CAST(ISNULL(qt_minimo_produto, '') AS NVARCHAR(10)) + '</td>
            <td>' + CAST(ISNULL(qt_producao_produto, '') AS NVARCHAR(10)) + '</td>
            <td>' + CAST(ISNULL(Saldo, '') AS NVARCHAR(10)) + '</td>
            <td>' + CAST(ISNULL(qt_atendimento, '') AS NVARCHAR(10)) + '</td>
            <td>' + CAST(ISNULL(qt_necessidade, '') AS NVARCHAR(10)) + '</td>
            <td>' + ISNULL(dt_pedido_venda, '') + '</td>'

    FROM #FinalVendedorProdutos

    -- Cursor para adicionar saldos dos vendedores para esse produto
    DECLARE vendedor_cursor CURSOR FOR
    SELECT value
    FROM STRING_SPLIT(REPLACE(REPLACE(@cols, '[', ''), ']', ''), ',')

    OPEN vendedor_cursor
    FETCH NEXT FROM vendedor_cursor INTO @nome_coluna

    WHILE @@FETCH_STATUS = 0
    BEGIN
      
        SET @sql_saldo = 'SELECT @s = ISNULL(CAST([' + @nome_coluna + '] AS NVARCHAR(20)), ''0'') 
                          FROM ##PedidoVendedorPivot WHERE cd_produto = @cd'

        EXEC sp_executesql @sql_saldo, 
            N'@cd INT, @s NVARCHAR(20) OUTPUT',
            @cd = @cd_produto, 
            @s = @saldo OUTPUT

        
        SET @linha_html = @linha_html + '<td>' + @saldo + '</td>'

        FETCH NEXT FROM vendedor_cursor INTO @nome_coluna
    END

    CLOSE vendedor_cursor
    DEALLOCATE vendedor_cursor

    -- Finaliza linha
    SET @linha_html = @linha_html + '</tr>'
    SET @html_geral = @html_geral + @linha_html

    DELETE FROM #FinalVendedorProdutos WHERE cd_controle = @id
END
--------------------------------------------------------------------------------------------------------------------




set @html_rodape =
    '</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	</div>
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>
    </div>'



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


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_demonstrativo_estoque_carteira_vendedor 301,2,''
------------------------------------------------------------------------------
