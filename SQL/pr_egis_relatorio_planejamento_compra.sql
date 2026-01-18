IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_planejamento_compra' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_planejamento_compra

GO

-------------------------------------------------------------------------------
--sp_helptext qt_previsao
-------------------------------------------------------------------------------
--pr_egis_relatorio_planejamento_compra
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
create procedure pr_egis_relatorio_planejamento_compra
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
--declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @cd_grupo_relatorio     int = 0
declare @titulo_tabela          varchar(200) = ''

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
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio_form'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'
     select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'

   end
end


-------------------------------------------------------------------------------------------------
declare @ic_processo char(1) = 'N'

 --select @cd_relatorio

select
  @titulo             = nm_relatorio,
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0),
  @titulo_tabela      = nm_titulo_tabela
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
declare @html_grafico    nvarchar(max) = '' --Gráfico
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
        .bank-logo {
            width: 80px;
            margin-right: 10px;
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



--select @nm_dados_cab_det

--select @nm_grupo_relatorio,@nm_dados_cab_det,* from #RelAtributo



--------------------------------------------------------------------------------------------------------------------------

set @html_detalhe = '' --valores da tabela


---> CCF <----
---> alteração com o processo do relatório


--Gráficos--

  declare @labels          nvarchar(max) = ''
  declare @valores         nvarchar(max) = '' 
  declare @nm_label        nvarchar(max) = ''
  declare @nm_valor        nvarchar(max) = ''
  declare @labels_mensal   nvarchar(max) = ''
  declare @valores_mensal  nvarchar(max) = '' 
  declare @nm_label_mensal nvarchar(max) = ''  
  declare @nm_valor_mensal nvarchar(max) = ''
  declare @tabela          nvarchar(max) = ''
  declare @card            nvarchar(max) = ''
 
 declare @qt_lead_time int = 30

select
  tpp.nm_tipo_produto_projeto,
  p.cd_produto,
  p.cd_mascara_produto,
  p.nm_fantasia_produto,
  p.nm_produto,
  um.sg_unidade_medida,
  ag.nm_agrupamento_produto,
  cp.nm_categoria_produto,
  fp.nm_familia_produto,
  gp.nm_grupo_produto,
  f.nm_fantasia_fornecedor,
  mp.nm_marca_produto,
  cf.cd_mascara_classificacao,
  cpg.cd_condicao_pagamento,
  cpg.nm_condicao_pagamento,
  ISNULL(pc.vl_custo_produto,0)  as vl_custo_produto,
  prev.nm_categoria_produto      as nm_categoria,
  
  isnull(prev.dt_entrega01,'') as dt_entrega01,
  isnull(prev.qt_entrega01,0)  as qt_entrega01,
  isnull(prev.dt_entrega02,'') as dt_entrega02,
  isnull(prev.qt_entrega02,0)  as qt_entrega02,
  isnull(prev.dt_entrega03,'') as dt_entrega03,
  isnull(prev.qt_entrega03,0)  as qt_entrega03,
  isnull(prev.dt_entrega04,'') as dt_entrega04,
  isnull(prev.qt_entrega04,0)  as qt_entrega04,
  isnull(prev.dt_entrega05,'') as dt_entrega05,
  isnull(prev.qt_entrega05,0)  as qt_entrega05,

  --Cálculos----------------------------------------------------------

  isnull(prev.qt_entrega01,0) * isnull(pc.vl_custo_produto,0)  as vl_total_previsao01,
  isnull(prev.qt_entrega02,0) * isnull(pc.vl_custo_produto,0)  as vl_total_previsao02,
  isnull(prev.qt_entrega03,0) * isnull(pc.vl_custo_produto,0)  as vl_total_previsao03,
  isnull(prev.qt_entrega04,0) * isnull(pc.vl_custo_produto,0)  as vl_total_previsao04,
  isnull(prev.qt_entrega05,0) * isnull(pc.vl_custo_produto,0)  as vl_total_previsao05,

  
  dt_previsao = @qt_lead_time + @dt_hoje,

  fa.nm_fase_produto



into #Previsao


from
  Produto p
  inner join fase_produto fa               on fa.cd_fase_produto          = p.cd_fase_produto_baixa
  inner join Unidade_Medida um             on um.cd_unidade_medida        = p.cd_unidade_medida
  left outer join Produto_Processo pp      on pp.cd_produto               = p.cd_produto and pp.cd_fase_produto = fa.cd_fase_produto
  left outer join Tipo_Produto_Projeto tpp on tpp.cd_tipo_produto_projeto = pp.cd_tipo_produto_projeto 
  left outer join Agrupamento_Produto ag   on ag.cd_agrupamento_produto   = p.cd_agrupamento_produto
  left outer join Categoria_Produto cp     on cp.cd_categoria_produto     = p.cd_categoria_produto
  left outer join Familia_Produto fp       on fp.cd_familia_produto       = p.cd_familia_produto
  left outer join Grupo_Produto gp         on gp.cd_grupo_produto         = p.cd_grupo_produto
  left outer join Fornecedor_Produto fpro  on fpro.cd_produto             = p.cd_produto
  left outer join Fornecedor f             on f.cd_fornecedor             = fpro.cd_fornecedor
  left outer join Marca_Produto mp         on mp.cd_marca_produto         = p.cd_marca_produto
  left outer join Produto_Custo pc         on pc.cd_produto               = p.cd_produto
  left outer join Produto_Fiscal pf        on pf.cd_produto               = p.cd_produto
  left outer join Classificacao_Fiscal cf  on cf.cd_classificacao_fiscal  = pf.cd_classificacao_fiscal
  left outer join Condicao_Pagamento cpg   on cpg.cd_condicao_pagamento   = f.cd_condicao_pagamento
  inner join Previsao_Producao prev        on prev.cd_produto             = p.cd_produto
  inner join opcao_compra opc              on opc.cd_opcao_compra         = fpro.cd_opcao_compra

where
  isnull(p.ic_wapnet_produto,'N')='S'
  and
  isnull(opc.ic_analise_producao,'N')='S'


--Totais--

declare @vl_total             decimal(25,2) = 0.00
declare @nm_grupo             varchar(60)   = ''
declare @qt_cliente           int
declare @qt_total             int = 0
declare @vl_pagamento         decimal(25,2) = 0.00

declare @qt_dia01     int
declare @pc_parcela01 float
declare @dt_parcela01 varchar(8000)
declare @vl_parcela01 float
declare @qt_dia02     int
declare @pc_parcela02 float
declare @dt_parcela02 varchar(8000)
declare @vl_parcela02 float
declare @qt_dia03     int
declare @pc_parcela03 float
declare @dt_parcela03 varchar(8000)
declare @vl_parcela03 float
declare @qt_dia04     int
declare @pc_parcela04 float
declare @dt_parcela04 varchar(8000)
declare @vl_parcela04 float
declare @qt_dia05     int
declare @pc_parcela05 float
declare @dt_parcela05 varchar(8000)
declare @vl_parcela05 float

select 
  identity(int,1,1) as cd_controle,
  cpp.cd_condicao_pagamento,
  cpp.qt_dia_cond_parcela_pgto,
  cpp.pc_condicao_parcela_pgto
into
  #Condicao
from 
  Condicao_Pagamento_Parcela cpp
where 
  cpp.cd_condicao_pagamento in (select top 1 cd_condicao_pagamento from #Previsao) 
  
select 
  @qt_dia01     = case when cd_controle = 1 then isnull(qt_dia_cond_parcela_pgto,0) else @qt_dia01     end,
  @pc_parcela01 = case when cd_controle = 1 then isnull(pc_condicao_parcela_pgto,0) else @pc_parcela01 end,
  @qt_dia02     = case when cd_controle = 2 then isnull(qt_dia_cond_parcela_pgto,0) else @qt_dia02     end,
  @pc_parcela02 = case when cd_controle = 2 then isnull(pc_condicao_parcela_pgto,0) else @pc_parcela02 end,
  @qt_dia03     = case when cd_controle = 3 then isnull(qt_dia_cond_parcela_pgto,0) else @qt_dia03     end,
  @pc_parcela03 = case when cd_controle = 3 then isnull(pc_condicao_parcela_pgto,0) else @pc_parcela03 end,
  @qt_dia04     = case when cd_controle = 4 then isnull(qt_dia_cond_parcela_pgto,0) else @qt_dia04     end,
  @pc_parcela04 = case when cd_controle = 4 then isnull(pc_condicao_parcela_pgto,0) else @pc_parcela04 end,
  @qt_dia05     = case when cd_controle = 5 then isnull(qt_dia_cond_parcela_pgto,0) else @qt_dia05     end,
  @pc_parcela05 = case when cd_controle = 5 then isnull(pc_condicao_parcela_pgto,0) else @pc_parcela05 end
from  
  #Condicao
    
select
  @qt_total             = sum(qt_entrega01 + qt_entrega02 + qt_entrega03 + qt_entrega04 + qt_entrega05),
  @vl_total             = sum(vl_total_previsao01)
from
  #Previsao

select 
  IDENTITY(int,1,1) as cd_controle,
  dt_e1_parcela01 = case when dt_entrega01 <> '' then dt_entrega01 + @qt_dia01 else NULL end,
  vl_e1_parcela01 = case when qt_entrega01 <> '' then (qt_entrega01 * vl_custo_produto) * (@pc_parcela01/100) else NULL end,
  dt_e1_parcela02 = case when dt_entrega01 <> '' then dt_entrega01 + @qt_dia02 else NULL end,
  vl_e1_parcela02 = case when qt_entrega01 <> '' then (qt_entrega01 * vl_custo_produto) * (@pc_parcela02/100) else NULL end,
  dt_e1_parcela03 = case when dt_entrega01 <> '' then dt_entrega01 + @qt_dia03 else NULL end,
  vl_e1_parcela03 = case when qt_entrega01 <> '' then (qt_entrega01 * vl_custo_produto) * (@pc_parcela03/100) else NULL end,
  dt_e1_parcela04 = case when dt_entrega01 <> '' then dt_entrega01 + @qt_dia04 else NULL end,
  vl_e1_parcela04 = case when qt_entrega01 <> '' then (qt_entrega01 * vl_custo_produto) * (@pc_parcela04/100) else NULL end,
  dt_e1_parcela05 = case when dt_entrega01 <> '' then dt_entrega01 + @qt_dia05 else NULL end,
  vl_e1_parcela05 = case when qt_entrega01 <> '' then (qt_entrega01 * vl_custo_produto) * (@pc_parcela05/100) else NULL end,

  dt_e2_parcela01 = case when dt_entrega02 <> '' then dt_entrega02 + @qt_dia01 else NULL end,
  vl_e2_parcela01 = case when qt_entrega02 <> '' then (qt_entrega02 * vl_custo_produto) * (@pc_parcela01/100) else NULL end,
  dt_e2_parcela02 = case when dt_entrega02 <> '' then dt_entrega02 + @qt_dia02 else NULL end,
  vl_e2_parcela02 = case when qt_entrega02 <> '' then (qt_entrega02 * vl_custo_produto) * (@pc_parcela02/100) else NULL end,
  dt_e2_parcela03 = case when dt_entrega02 <> '' then dt_entrega02 + @qt_dia03 else NULL end,
  vl_e2_parcela03 = case when qt_entrega02 <> '' then (qt_entrega02 * vl_custo_produto) * (@pc_parcela03/100) else NULL end,
  dt_e2_parcela04 = case when dt_entrega02 <> '' then dt_entrega02 + @qt_dia04 else NULL end,
  vl_e2_parcela04 = case when qt_entrega02 <> '' then (qt_entrega02 * vl_custo_produto) * (@pc_parcela04/100) else NULL end,
  dt_e2_parcela05 = case when dt_entrega02 <> '' then dt_entrega02 + @qt_dia05 else NULL end,
  vl_e2_parcela05 = case when qt_entrega02 <> '' then (qt_entrega02 * vl_custo_produto) * (@pc_parcela05/100) else NULL end,

  dt_e3_parcela01 = case when dt_entrega03 <> '' then  dt_entrega03 + @qt_dia01 else NULL end,
  vl_e3_parcela01 = case when qt_entrega03 <> '' then (qt_entrega03 * vl_custo_produto) * (@pc_parcela01/100) else NULL end,
  dt_e3_parcela02 = case when dt_entrega03 <> '' then  dt_entrega03 + @qt_dia02 else NULL end,
  vl_e3_parcela02 = case when qt_entrega03 <> '' then (qt_entrega03 * vl_custo_produto) * (@pc_parcela02/100) else NULL end,
  dt_e3_parcela03 = case when dt_entrega03 <> '' then  dt_entrega03 + @qt_dia03 else NULL end,
  vl_e3_parcela03 = case when qt_entrega03 <> '' then (qt_entrega03 * vl_custo_produto) * (@pc_parcela03/100) else NULL end,
  dt_e3_parcela04 = case when dt_entrega03 <> '' then  dt_entrega03 + @qt_dia04 else NULL end,
  vl_e3_parcela04 = case when qt_entrega03 <> '' then (qt_entrega03 * vl_custo_produto) * (@pc_parcela04/100) else NULL end,
  dt_e3_parcela05 = case when dt_entrega03 <> '' then  dt_entrega03 + @qt_dia05 else NULL end,
  vl_e3_parcela05 = case when qt_entrega03 <> '' then (qt_entrega03 * vl_custo_produto) * (@pc_parcela05/100) else NULL end,

  dt_e4_parcela01 = case when dt_entrega04 <> '' then  dt_entrega04 + @qt_dia01 else NULL end,
  vl_e4_parcela01 = case when qt_entrega04 <> '' then (qt_entrega04 * vl_custo_produto) * (@pc_parcela01/100) else NULL end,
  dt_e4_parcela02 = case when dt_entrega04 <> '' then  dt_entrega04 + @qt_dia02 else NULL end,
  vl_e4_parcela02 = case when qt_entrega04 <> '' then (qt_entrega04 * vl_custo_produto) * (@pc_parcela02/100) else NULL end,
  dt_e4_parcela03 = case when dt_entrega04 <> '' then  dt_entrega04 + @qt_dia03 else NULL end,
  vl_e4_parcela03 = case when qt_entrega04 <> '' then (qt_entrega04 * vl_custo_produto) * (@pc_parcela03/100) else NULL end,
  dt_e4_parcela04 = case when dt_entrega04 <> '' then  dt_entrega04 + @qt_dia04 else NULL end,
  vl_e4_parcela04 = case when qt_entrega04 <> '' then (qt_entrega04 * vl_custo_produto) * (@pc_parcela04/100) else NULL end,
  dt_e4_parcela05 = case when dt_entrega04 <> '' then  dt_entrega04 + @qt_dia05 else NULL end,
  vl_e4_parcela05 = case when qt_entrega04 <> '' then (qt_entrega04 * vl_custo_produto) * (@pc_parcela05/100) else NULL end,

  dt_e5_parcela01 = case when dt_entrega05 <> '' then  dt_entrega05 + @qt_dia01 else NULL end,
  vl_e5_parcela01 = case when qt_entrega05 <> '' then (qt_entrega05 * vl_custo_produto) * (@pc_parcela01/100) else NULL end,
  dt_e5_parcela02 = case when dt_entrega05 <> '' then  dt_entrega05 + @qt_dia02 else NULL end,
  vl_e5_parcela02 = case when qt_entrega05 <> '' then (qt_entrega05 * vl_custo_produto) * (@pc_parcela02/100) else NULL end,
  dt_e5_parcela03 = case when dt_entrega05 <> '' then  dt_entrega05 + @qt_dia03 else NULL end,
  vl_e5_parcela03 = case when qt_entrega05 <> '' then (qt_entrega05 * vl_custo_produto) * (@pc_parcela03/100) else NULL end,
  dt_e5_parcela04 = case when dt_entrega05 <> '' then  dt_entrega05 + @qt_dia04 else NULL end,
  vl_e5_parcela04 = case when qt_entrega05 <> '' then (qt_entrega05 * vl_custo_produto) * (@pc_parcela04/100) else NULL end,
  dt_e5_parcela05 = case when dt_entrega05 <> '' then  dt_entrega05 + @qt_dia05 else NULL end,
  vl_e5_parcela05 = case when qt_entrega05 <> '' then (qt_entrega05 * vl_custo_produto) * (@pc_parcela05/100) else NULL end,
  *
into
  #Posicao

from  
  #Previsao
order by
   cd_mascara_produto 



---------------------------------------------------------------------------------------------------------------------------

set @html_cab_det = '<div class="section-title"><strong> '+@nm_grupo_relatorio + ' - '+@nm_grupo+ ' </strong></div> 
                     <table>
                     <tr>'
					 +
					 isnull(@nm_dados_cab_det,'')
                     + '</tr>'

---------------------------------------------------------------------------------------------------------------------------


----montagem do Detalhe-----------------------------------------------------------------------------------------------

declare @id int = 0

set @html_detalhe = ''

while exists ( select cd_controle from #Posicao )
begin

  select top 1
    @id           = cd_controle,
    --Gráfico----
	  @nm_label_mensal = isnull(nm_fantasia_fornecedor,''),
	  @nm_valor_mensal = replace(CAST(dbo.fn_formata_valor(isnull(vl_total_previsao01,0)) as varchar(100)),'.',''),
    --


	--@nm_pedido    = @nm_pedido  + ' ' + cast(cd_pedido_venda as varchar(15)),
    @html_detalhe = @html_detalhe + '
            <tr> 					
            <td style="font-size:12px; text-align:center;width: 20px">'  + cast(isnull(cd_controle,'') as varchar(20))+            '</td>
			<td style="font-size:12px; text-align:center;width: 20px">'  + cast(isnull(nm_categoria,'') as varchar(30))+           '</td>	
			<td style="font-size:12px; text-align:center;width: 20px">'  + cast(isnull(nm_agrupamento_produto,'') as varchar(30))+ '</td>	
			<td style="font-size:12px; text-align:center;width: 20px">'  + cast(cd_mascara_produto as varchar(60))+                '</td>	
			<td style="font-size:12px; text-align:center;width: 20px">'  + cast(nm_produto as varchar(60))+                        '</td>	
			<td style="font-size:12px; text-align:center;width: 20px">'  + cast(nm_fantasia_fornecedor as varchar(30))+            '</td>	
			<td style="font-size:12px; text-align:center;width: 120px">' + case when dt_entrega01 <> '' then 'Dt: ' + isnull(dbo.fn_data_string(dt_entrega01),'') + '<br> Qtd.: ' + isnull(dbo.fn_formata_valor(qt_entrega01),'') + '<br> R$: ' + isnull(dbo.fn_formata_valor(vl_total_previsao01),'') else '' end + '</td>
			<td style="font-size:12px; text-align:center;width: 300px">' + case when dt_e1_parcela01 <> '' then 'Dt: '      + isnull(dbo.fn_data_string(dt_e1_parcela01),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e1_parcela01),'') else '' end + 
			                                                               case when dt_e1_parcela02 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e1_parcela02),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e1_parcela02),'') else '' end + 
																		   case when dt_e1_parcela03 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e1_parcela03),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e1_parcela03),'') else '' end + 
																		   case when dt_e1_parcela04 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e1_parcela04),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e1_parcela04),'') else '' end + 
																		   case when dt_e1_parcela05 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e1_parcela05),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e1_parcela05),'') else '' end +          '</td>
			<td style="font-size:12px; text-align:center;width: 120px">' + case when dt_entrega02 <> '' then 'Dt: ' + isnull(dbo.fn_data_string(dt_entrega02),'') + '<br> Qtd.: ' + isnull(dbo.fn_formata_valor(qt_entrega02),'') + '<br> R$: ' + isnull(dbo.fn_formata_valor(vl_total_previsao02),'') else '' end + '</td>
			<td style="font-size:12px; text-align:center;width: 300px">' + case when dt_e2_parcela01 <> '' then 'Dt: '      + isnull(dbo.fn_data_string(dt_e2_parcela01),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e2_parcela01),'') else '' end + 
			                                                               case when dt_e2_parcela02 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e2_parcela02),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e2_parcela02),'') else '' end + 
																		   case when dt_e2_parcela03 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e2_parcela03),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e2_parcela03),'') else '' end + 
																		   case when dt_e2_parcela04 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e2_parcela04),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e2_parcela04),'') else '' end + 
																		   case when dt_e2_parcela05 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e2_parcela05),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e2_parcela05),'') else '' end +          '</td>			
			<td style="font-size:12px; text-align:center;width: 120px">' + case when dt_entrega03 <> '' then 'Dt: ' + isnull(dbo.fn_data_string(dt_entrega03),'') + '<br> Qtd.: ' + isnull(dbo.fn_formata_valor(qt_entrega03),'') + '<br> R$: ' + isnull(dbo.fn_formata_valor(vl_total_previsao03),'') else '' end + '</td>
			<td style="font-size:12px; text-align:center;width: 500px">' + case when dt_e3_parcela01 <> '' then 'Dt: '      + isnull(dbo.fn_data_string(dt_e3_parcela01),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e3_parcela01),'') else '' end + 
			                                                               case when dt_e3_parcela02 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e3_parcela02),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e3_parcela02),'') else '' end + 
																		   case when dt_e3_parcela03 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e3_parcela03),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e3_parcela03),'') else '' end + 
																		   case when dt_e3_parcela04 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e3_parcela04),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e3_parcela04),'') else '' end + 
																		   case when dt_e3_parcela05 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e3_parcela05),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e3_parcela05),'') else '' end +          '</td>
			<td style="font-size:12px; text-align:center;width: 120px">' + case when dt_entrega04 <> '' then 'Dt: ' + isnull(dbo.fn_data_string(dt_entrega04),'') + '<br> Qtd.: ' + isnull(dbo.fn_formata_valor(qt_entrega04),'') + '<br> R$: ' + isnull(dbo.fn_formata_valor(vl_total_previsao04),'') else '' end + '</td>
			<td style="font-size:12px; text-align:center;width: 300px">' + case when dt_e4_parcela01 <> '' then 'Dt: '      + isnull(dbo.fn_data_string(dt_e4_parcela01),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e4_parcela01),'') else '' end + 
			                                                               case when dt_e4_parcela02 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e4_parcela02),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e4_parcela02),'') else '' end + 
																		   case when dt_e4_parcela03 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e4_parcela03),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e4_parcela03),'') else '' end + 
																		   case when dt_e4_parcela04 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e4_parcela04),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e4_parcela04),'') else '' end + 
																		   case when dt_e4_parcela05 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e4_parcela05),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e4_parcela05),'') else '' end +          '</td>
			<td style="font-size:12px; text-align:center;width: 120px">' + case when dt_entrega05 <> '' then 'Dt: ' + isnull(dbo.fn_data_string(dt_entrega05),'') + '<br> Qtd.: ' + isnull(dbo.fn_formata_valor(qt_entrega05),'') + '<br> R$: ' + isnull(dbo.fn_formata_valor(vl_total_previsao05),'') else '' end + '</td>	
			<td style="font-size:12px; text-align:center;width: 300px">' + case when dt_e5_parcela01 <> '' then 'Dt: '      + isnull(dbo.fn_data_string(dt_e5_parcela01),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e5_parcela01),'') else '' end + 
			                                                               case when dt_e5_parcela02 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e5_parcela02),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e5_parcela02),'') else '' end + 
																		   case when dt_e5_parcela03 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e5_parcela03),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e5_parcela03),'') else '' end + 
																		   case when dt_e5_parcela04 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e5_parcela04),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e5_parcela04),'') else '' end + 
																		   case when dt_e5_parcela05 <> '' then '<br> Dt: ' + isnull(dbo.fn_data_string(dt_e5_parcela05),'') + ' <br> R$: ' + isnull(dbo.fn_formata_valor(vl_e5_parcela05),'') else '' end +          '</td>
			
            </tr>'
		
		--use egissql_317

  from
    #Posicao

  order by
    cd_controle

  set @nm_valor_mensal = REPLACE(@nm_valor_mensal,',','.')
  set @labels_mensal   = @labels_mensal  + '"' +  @nm_label_mensal + '"'
  set @valores_mensal  = @valores_mensal + ' ' +  @nm_valor_mensal + ' '
   
  delete from #Posicao
  where
    cd_controle = @id

	 if exists(select top 1 cd_controle from #Posicao)
	 begin
	   set @labels_mensal  = @labels_mensal  + ', '
	   set @valores_mensal = @valores_mensal + ', '
	 end

end

  --Dados do Gráfico---

  if @labels_mensal<>''
  begin
    set @labels_mensal  = '['+@labels_mensal+']'
	set @valores_mensal = '['+@valores_mensal+']'
  end

  --select @valores_mensal, @labels_mensal

--Relatório--

if @cd_parametro <> 3
begin

  --select @html_detalhe

--Exec em SQl com Texto
--While---
--Campos do Html

set @nm_fantasia_cliente     = '' --'Resumo dos Pedidos de Vendas'
set @nm_razao_social_cliente = '' --@nm_pedido


set @html_titulo = '<div class="section-title"><strong>'+@titulo+' - Data Base : '+dbo.fn_data_string(@dt_final)+'</strong></div>
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

set @titulo_total = ''
set @html_totais = ''

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
return

end

--Gráfico

if @cd_parametro = 3
begin
  --Dados dos Cards'--

  set @card = '
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
    </div>
	 <div class="separador" style="font-weight: bold; font-size: 18px">'+@titulo+' - Data Base : '+dbo.fn_data_string(@dt_final) +'</div>

        <!-- Seção com cards -->
<div class="secao4" id="sobre">
  <div class="secao4-div">
      <!-- Card 1 -->
      <div class="secao4-div-card">        
	      <div>
          <h3>Clientes</h3>
		  <div class="card_separator"></div>
		  </div>	  
		  <div>
          <p>'+cast(cast(@qt_cliente as int) as varchar(20))+'</p>
		  </div>
      </div>

      <!-- Card 2 -->
      <div class="secao4-div-card">   
	      <div>
          <h3>Atraso</h3>		
		   <div class="card_separator"></div>
          </div>
          <p> '+'R$ '+dbo.fn_formata_valor(0.00)+'</p>
      </div>

      <!-- Card 3 -->
      <div class="secao4-div-card">   
	      <div>
          <h3>Total a Receber</h3>		
		   <div class="card_separator"></div>
          </div>
          <p> '+'R$ '+dbo.fn_formata_valor(@vl_total)+'</p>
      </div>

      <!-- Card 4 -->
      <div class="secao4-div-card">          
	      <div>
          <h3>De</h3> 
		  <div class="card_separator"></div>
		  </div>
          <p>'+''+'</p>
      </div>

      <!-- Card 5 -->
      <div class="secao4-div-card">          
	      <div>
          <h3>Até</h3> 
		  <div class="card_separator"></div>
		  </div>
          <p>'+''+'</p>
      </div>

  </div>
</div>'


  set @html_grafico = 
  '<html lang="pt-br">
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title >'+@titulo+'</title>
    <!-- Link para o CSS do Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.min.js" integrity="sha512-L0Shl7nXXzIlBSUUPpxrokqq4ojqgZFQczTYlGjzONGTDAcLremjwaWv5A+EDLnxhQzY5xUZPWLOLqYRkY0Cbw==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>    
    <style>

      .grafico {
        position: relative;
		height: auto !important 120vh; 
		width: auto !important calc(90% - 20px);  
		margin: 5px;  
        padding: 5px;
        display: flex;
        flex-wrap: wrap;
        justify-content: space-around;
		 
      }
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
       
        .img {
            max-width: 250px;
			height: 100px;
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
		.separador {
            width: auto;
            height: 35px;
			margin:5px;
			padding: 2px;
			border-radius: 10px;
            background-color:#ff6f00;
            color: white;
            text-align: center;
            display: flex;
            justify-content: center;
            align-items: center;
        }

		.container2 {          
          margin:0 auto;
          border: 0px solid orangered;
          display: flex;
          flex-direction: row;
          flex-wrap: wrap;
          justify-content: center; /* eixo principal */
          align-items: center;
		}
	
	
.secao4 {
    margin: 0;
    font-family: Helvetica, sans-serif;}

.secao4-div {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    padding: 10px;
    text-align: center;
    }

.secao4-div-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: calc(100% / 5 - 30px);
    margin: 5px;
    padding: 10px;
    box-shadow: 2px 2px 16px 0px rgba(0, 0, 0, 0.1);
    border-radius: 15px;
    background-color: white;
    transition: all 0.5s ease;
    }

.secao4-div-card:hover {
    transform: scale(1.1);
    z-index: 1;}

.secao4-div-card imgx {
    width: 35%;
    height: auto;}

.secao4-div-card h3 {
    margin-bottom: 0px;}

.card_separator {
            border-bottom: 1px solid blue;			
            margin: auto;
        }
		

/* Estilos para dispositivos móveis */
@media (max-width: 768px) {
    .secao4-div-card {
        width: 100%;
    }
}        

  </style>
  </head>
  <body>
     <div class="container mt-5">'
	 +

	 isnull(@card,'')
	 +
	 ''
	 --'<div class="container mt-5">'
	 +
     '<div class="grafico">
	     <div>
            <canvas id="myChart"></canvas>
         </div>

	 </div>'
	-- +
	-- isnull(@tabela,'')
	 +	   

    '</div>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
	<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels"></script>
    <script>
     const ctx = document.getElementById("myChart").getContext("2d");

     new Chart(ctx, {
     type: "bar",
     Dt: {
        labels: '+@labels_mensal+',
        datasets: [{
        label: "'+@titulo+'",
        Dt: '+@valores_mensal+ ',
        borderWidth: 1,
		fill: false,        
		tension: 0.1,
		stepped: false,
		backgroundColor: ["#FF6384", "#36A2EB", "#FFCE56"],
		hoverOffset: 4		
      }]
    },
    options: {
	  responsive: true,
	
      scales: {
	  x: {
        grid: {
          display: false
        }
      },
        y: {
		  
          beginAtZero: true,
           grid: {
             display: false
           }
        }
      },
      plugins: {
        legend: {
		         position: "top",
                 display: false,
                 labels: {
				    usePointStyle: false,
                    color: "rgb(255, 99, 132)"
                }
            },        
        customCanvasBackgroundColor: {
        color: "lightGreen",
       },
	    cutout: "40%", // Define o tamanho do centro do gráfico
        title: {
                display: false,
                text: "TITULO DO GRAFICO"				 
            },
                
            subtitle: {
                display: false,
                text: "Custom Chart Subtitle"
            },
            tooltip: {
			   enabled: true,

                callbacks: {
                    label: function(context) {
                        let label = context.dataset.label || "";

                        if (label) {
                            label += ": ";
                        }
                        if (context.parsed.y !== null) {
                            label += new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(context.parsed.y);
                        }
                        return label;
                    }
                }
            }        
            
        }
    }
  });



</script>
<!-- Script do Bootstrap -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>  
</html>'



  select isnull(@html_grafico,'') as RelatorioHTML
  return



end


----------------------------------------------------------------------------------------------------------------------------------------------
go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
exec pr_egis_relatorio_planejamento_compra 194,1387,3,''
------------------------------------------------------------------------------


