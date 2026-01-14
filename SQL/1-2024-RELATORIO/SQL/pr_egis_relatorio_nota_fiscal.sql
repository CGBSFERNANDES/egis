IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_nota_fiscal' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_nota_fiscal

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_nota_fiscal
-------------------------------------------------------------------------------
--pr_egis_relatorio_nota_fiscal
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
create procedure pr_egis_relatorio_nota_fiscal
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
declare @cd_grupo_relatorio     int
declare @cd_controle            int


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
			@nm_empresa                 varchar(200) = '',
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
			@ic_empresa_faturamento		char(1) = '', 
			@dt_nota_saida               datetime = '',
			@cd_identificacao_nota_saida int = 0,
			@dt_saida_nota_saida         datetime = '',
			@nm_operacao_fiscal          nvarchar(80)= '',
			@cd_operacao_fiscal          nvarchar(15)= '',
			@ic_comercial_operacao       nvarchar(5) = '',
			@vl_total                    decimal(18,2),
			@ic_carta_correcao           nvarchar(10) = '',
			@qt_duplicatas               int = 0,
			@nm_vendedro_interno         nvarchar(50) = '',
			@nm_vendedor_externo         nvarchar(60) = '',
			@nm_cliente_grupo            nvarchar(80) = '',
			@sg_serie_nota_fiscal        nvarchar(20) = '',
			@nm_semana				     nvarchar(20) = '',
			@nm_itinerario			     nvarchar(60) = '',
			@ds_obs_compl_nota_saida     varchar(8000) = '',
			@cd_condicao_pagamento		 int = 0,
			@ic_imposto_nota_saida       nvarchar(20),
			@vl_total_item				 decimal(18,2),
			@vl_frete_pedido_compra		 decimal(18,2),
			@vl_tota               		 nvarchar(30),
			@vl_total_icms               nvarchar(30),
			@nm_status_nota              nvarchar(30),
			@ic_produto_faturamento      nvarchar(30)
					   
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
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'         
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'
  select @cd_documento           = valor from #json where campo = 'cd_nota_saida'
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'
   end
   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento_form'
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
-------------------------------------------------------------------------------------------------
--  select
--  @dt_inicial                 = dt_inicial,
--  @dt_final                   = dt_final
--  
--from 
--  Parametro_Relatorio
--
--where
--  cd_relatorio = @cd_relatorio
--  and
--  cd_usuario   = @cd_usuario
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
		@nm_empresa                 = isnull(e.nm_empresa,''),
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
set @html_titulo  = ''
set @html_cab_det = ''
set @html_detalhe = ''
set @html_rod_det = ''
set @html_rodape  = ''

-- Obtém a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
declare @hr_imp             varchar(5)  
set @hr_imp            = right(left(convert(varchar,getdate(),121),16),5)
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

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        body {
            font-family: "Arial", sans-serif;
            background-color: #f4f4f4;
            padding: 20px;
        }
        .boleto-container {
            max-width: 800px;
            margin: 0 auto;
            background-color: #fff;
            padding: 20px;
            border: 1px solid #ddd;
            box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }
        .boleto-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .boleto-header img {
            height: 50px;
        }
        .boleto-header h2 {
            margin-left: 20px;
            font-size: 24px;
        }
        .boleto-body {
            margin-top: 20px;
        }
        .boleto-body p {
            margin: 10px 0;
        }
        .boleto-body strong {
            font-size: 14px;
            color: #333;
        }
        .linha-digitavel {
            font-weight: bold;
            font-size: 20px;
            text-align: right;
            margin-top: 20px;
        }
        .boleto-footer {
            margin-top: 20px;
            text-align: center;
        }
        .boleto-footer img {
            margin-top: 10px;
            height: 60px;
        }
        .button-group {
            margin-top: 20px;
            text-align: center;
        }
        button {
            margin: 10px 5px;
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
            border: none;
            border-radius: 5px;
            background-color: #007BFF;
            color: white;
            transition: background-color 0.3s ease;
        }
        button:hover {
            background-color: #0056b3;
        }
        .banco-selecao {
            margin-bottom: 20px;
            text-align: center;
        }
        select {
            padding: 10px;
            font-size: 16px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }

    </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:30%; margin-right:20px">
			<img src="'+@logo+'" alt="Logo da Empresa">
		</div>
		<div style="width:50%; padding-left:10px">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
		    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
		</div>    
    '

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

------------------------------------------------------------------------------------------------------------------
--	set @cd_documento = 358144

select  
  @ic_produto_faturamento = isnull(ic_produto_faturamento,'N')  
from  
  config_egismob with (nolock)  
where  
  cd_empresa = @cd_empresa  
--------------------------------------------------------------------------------------------------------------------
 SELECT     
   ns.dt_nota_saida                                          as dt_nota_saida,
   ns.cd_identificacao_nota_saida                            as cd_identificacao_nota_saida,
  -- ns.cd_nota_saida                                          as cd_nota_saida,
   ns.dt_saida_nota_saida                                    as dt_saida_nota_saida,
   ofi.nm_operacao_fiscal                                    as nm_operacao_fiscal,
   cl.cd_cliente                                             as cd_cliente,
   ofi.cd_mascara_operacao                                   as cd_operacao_fiscal,
   isNull(ofi.ic_comercial_operacao,'N')                     as ic_comercial_operacao,
   cast(ns.ds_obs_compl_nota_saida as varchar(8000))          as ds_obs_compl_nota_saida,
    case when ns.cd_status_nota<>7 then
      isnull(ns.vl_total,0)
   else
      0.00
   end                                                       as vl_total,
   
   case when exists ( select top 1 c.* from Carta_Correcao c with (nolock) 
                      where c.cd_nota_saida = ns.cd_nota_saida ) then 'S'
        else 'N' end                                        as ic_carta_correcao, 

   Cast(
    (select 
      count(nsi.cd_item_nota_saida) 
    from
      nota_saida_item nsi with (nolock) 
    where
      nsi.cd_nota_saida = ns.cd_nota_saida 
    and 
      nsi.ic_tipo_nota_saida_item = 'P')

   as int)                                               as qt_item_nota_saida,

     isnull((select count('x') from Documento_Receber x with (nolock) 
                      where x.cd_nota_saida = ns.cd_nota_saida 
                      group by x.cd_nota_saida),0)                 as qt_duplicatas,


  Cast(
    (select 
      sum(nsi.qt_item_nota_saida)
    from
      nota_saida_item nsi with (nolock) 
    where
      nsi.cd_nota_saida = ns.cd_nota_saida 
    and 
      nsi.ic_tipo_nota_saida_item = 'P')

   as decimal(25,6))                                               as qt_soma_itens,


  Cast(
    (select 
      isnull(sum( isnull(p.qt_volume_produto,0) * isnull(nsv.qt_item_nota_saida  ,0)  ),0)
    from
      nota_saida_item nsv with (nolock) 
      inner join produto p on p.cd_produto = nsv.cd_produto
    where
      nsv.cd_nota_saida = ns.cd_nota_saida 
    )

   as decimal(25,2))                                               as qt_volume,




   (select top 1 x.cd_vendedor from Vendedor x with (nolock) left outer join
    Cliente c on c.cd_cliente = ns.cd_cliente and ns.cd_tipo_destinatario = 1
    where x.cd_vendedor = c.cd_vendedor_interno)                   as cd_vendedor_interno,
 
    (select top 1 x.nm_fantasia_vendedor from Vendedor x with (nolock) left outer join
    Cliente c on c.cd_cliente = ns.cd_cliente and ns.cd_tipo_destinatario = 1
    where x.cd_vendedor = c.cd_vendedor_interno)                   as nm_vendedor_interno,
    ns.cd_vendedor as cd_vendedor_externo, 
    (select x.nm_fantasia_vendedor from Vendedor x with (nolock) 
                                  where x.cd_vendedor = ns.cd_vendedor) as nm_vendedor_externo,
  


   cg.nm_cliente_grupo                         as nm_cliente_grupo,

   snf.sg_serie_nota_fiscal                    as sg_serie_nota_fiscal,
 
   cl.nm_fantasia_cliente                      as nm_fantasia_cliente,
   cl.nm_razao_social_cliente                  as nm_razao_social_cliente,
   ns.ic_imposto_nota_saida                    as ic_imposto_nota_saida,
   ns.cd_condicao_pagamento                    as cd_condicao_pagamento,
   cp.nm_condicao_pagamento					   as nm_condicao_pagamento,
   sn.nm_status_nota                           as nm_status_nota

   into
   #tabelaItens 

 FROM
   Nota_Saida ns                         with (nolock)
   left outer join Operacao_Fiscal ofi   with (nolock) on ofi.cd_operacao_fiscal   = ns.cd_operacao_fiscal 
   Left Outer Join Status_Nota sn        with (nolock) on ns.cd_status_nota        = sn.cd_status_nota 
   left outer join Cliente cl            with (nolock) on ns.cd_cliente            = cl.cd_cliente 
   left outer join Cliente_Grupo cg      with (nolock) on cl.cd_cliente_grupo      = cg.cd_cliente_grupo
   left outer join Condicao_Pagamento cp with (nolock) on cp.cd_condicao_pagamento = ns.cd_condicao_pagamento
   left outer join serie_nota_fiscal snf with (nolock) on snf.cd_serie_nota_fiscal = ns.cd_serie_nota
   left outer join Categoria_Cliente cac       with (nolock) on cac.cd_categoria_cliente   = cl.cd_categoria_cliente
   left outer join Grupo_Categoria_Cliente gcc with (nolock) on gcc.cd_grupo_categ_cliente = cac.cd_grupo_categoria_cli
   left outer join status_cliente sc                         on sc.cd_status_cliente       = cl.cd_status_cliente
   

where 
  ns.cd_nota_saida = @cd_documento
  --select * from #tabelaItens
  ---Dados do Vendedor----------------------------------------------------------
	declare @nm_vendedor varchar(200)
	set @nm_vendedor = (select ltrim(rtrim(isnull(nm_fantasia_vendedor,''))) from vendedor where cd_vendedor = @cd_vendedor)

  ---Dados do Cliente-----------------------------------------------------------

	select 
		@nm_fantasia_cliente	    = ltrim(rtrim(isnull(c.nm_fantasia_cliente,''))),
		@cd_cnpj_cliente		    = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(c.cd_cnpj_cliente,'')))),
		@nm_razao_social_cliente	= ltrim(rtrim(isnull(c.nm_razao_social_cliente,''))),
		@nm_endereco_cliente		= ltrim(rtrim(isnull(c.nm_endereco_cliente,''))),
		@nm_bairro					= ltrim(rtrim(isnull(c.nm_bairro,''))),
		@nm_cidade_cliente			= ltrim(rtrim(isnull(cid.nm_cidade,''))),
		@sg_estado_cliente			= ltrim(rtrim(isnull(e.sg_estado,''))),
		@cd_numero_endereco			= ltrim(rtrim(isnull(c.cd_numero_endereco,''))),
		@cd_telefone		   	    = '('+ltrim(rtrim(isnull(c.cd_ddd,''))) + ')'+ltrim(rtrim(isnull(c.cd_telefone,''))),
		@nm_semana					= ltrim(rtrim(isnull(s.nm_semana,''))),
		@nm_itinerario				= ltrim(rtrim(isnull(i.nm_itinerario,'')))

	from cliente c with(nolock)
	left outer join estado e		with(nolock) on e.cd_estado   = c.cd_estado 
	left outer join cidade cid		with(nolock) on cid.cd_cidade = c.cd_cidade and cid.cd_estado = c.cd_estado
	left outer join Semana s		with(nolock) on s.cd_semana = c.cd_semana
	left outer join Itinerario i	with(nolock) on i.cd_itinerario = c.cd_itinerario
	left outer join #tabelaItens ti with(nolock) on ti.cd_cliente = c.cd_cliente
	where 
		c.cd_cliente = ti.cd_cliente


	--Dados do Vendedor----------------------------------------------------------

--	if @cd_vendedor>0
--	begin
--
--	  select
--	    @nm_fantasia_vendedor  = isnull(nm_fantasia_vendedor,''),
--	    @nm_telefone_vendedor  = isnull(cd_telefone_vendedor,''),    
--	    @nm_email_vendedor     = isnull(nm_email_vendedor,'')     
--      from
--	    vendedor
--      where
--	    cd_vendedor = @cd_vendedor
--
--	end

	
	--Pedido de Venda--------------------------------------------------------------------------------------------------
	
	select 
	 IDENTITY(int,1,1)         as cd_controle,
	 ns.cd_nota_saida          as cd_nota_saida,
	 nsi.vl_unitario_item_nota as vl_unitario_item_nota,
	 um.sg_unidade_medida      as sg_unidade_medida,
	 nsi.vl_total_item         as vl_total_item,
	 p.nm_fantasia_produto     as nm_fantasia_produto,
	 p.nm_produto			   as nm_produto,
	 nsi.qt_item_nota_saida    as qt_item_nota_saida,
	 nsi.vl_ipi                as vl_ipi,
	 nsi.pc_ipi                as pc_ipi,
	 nsi.vl_icms_item          as vl_icms_item,
	 nsi.pc_icms               as pc_icms,
	 nsi.vl_frete_item         as vl_frete_item,
	 pv.cd_pedido_venda        as cd_pedido_venda,
	 cpp.nm_categoria_produto  as nm_categoria_produto

	  
	 
	into
	#itensTab
	from
	  nota_saida ns with(nolock)
	  INNER JOIN nota_saida_item nsi		with (nolock) ON ns.cd_nota_saida         = nsi.cd_nota_saida  
	  left outer join pedido_venda pv       with (nolock) ON pv.cd_pedido_venda       = nsi.cd_pedido_venda
	  LEFT OUTER JOIN Produto p				with (nolock) ON p.cd_produto             = nsi.cd_produto  
	  LEFT OUTER JOIN Unidade_Medida um		with (nolock) ON um.cd_unidade_medida     = nsi.cd_unidade_medida 
	  left outer join Condicao_Pagamento cp with (nolock) on cp.cd_condicao_pagamento = ns.cd_condicao_pagamento
	  left outer join categoria_produto cpp with (nolock) on cpp.cd_categoria_produto = nsi.cd_categoria_produto

	
	where
		ns.cd_nota_saida = @cd_documento
	
	order by
	  nsi.cd_item_nota_saida

	  select 
        'R$ ' + dbo.fn_formata_valor(  
        case when @ic_produto_faturamento = 'N'   
             then round(sum(isnull(vl_unitario_item_total,0)),2) - sum(isnull(vl_item_desconto,0))  
             else round(sum(isnull(vl_unitario_item_total,0)),2) - sum(isnull(vl_item_desconto,0)) - sum(isnull(vl_ipi,0))  
        end)                                                          as Total

		into
		#total
	  from vw_faturamento_bi
		where
		cd_nota_saida = @cd_documento

		select 
			@vl_tota                = Total
		from #total
-------------------------------------------------------------------------------------------------------------------
 

	select
		
		@dt_nota_saida                = dt_nota_saida,              
		@cd_identificacao_nota_saida  = cd_identificacao_nota_saida,
		@dt_saida_nota_saida          = dt_saida_nota_saida,        
		@nm_operacao_fiscal           = nm_operacao_fiscal,         
		@cd_operacao_fiscal           = cd_operacao_fiscal,         
		@ic_comercial_operacao        = ic_comercial_operacao,      
		@vl_total                     = vl_total,                   
		@ic_carta_correcao            = ic_carta_correcao,          
		@qt_duplicatas                = qt_duplicatas,              
		@nm_vendedro_interno          = nm_vendedor_interno,        
		@nm_vendedor_externo          = nm_vendedor_externo,        
		@nm_cliente_grupo             = nm_cliente_grupo,           
		@sg_serie_nota_fiscal         = sg_serie_nota_fiscal,
		@ic_imposto_nota_saida        = ic_imposto_nota_saida,
		@ds_obs_compl_nota_saida      = ds_obs_compl_nota_saida,
		@cd_condicao_pagamento		  = cd_condicao_pagamento,
		@nm_condicao_pagamento        = nm_condicao_pagamento,
		@nm_status_nota               = nm_status_nota
	from #tabelaItens


	select 
		@vl_total_item          = sum(qt_item_nota_saida),
		@vl_frete_pedido_compra = sum(vl_frete_item),
		@vl_total_ipi           = sum(vl_ipi),
		@vl_total_icms          = sum(vl_icms_item) 
	from #itensTab
 
---------------------------------------------------------------------------------------------------------------------------
set @html_geral = '  
   <div style="width: 20%; text-align: center;">  
                <p><strong>Nota: '+cast(isnull(@cd_documento,'')as varchar(20))+'</strong></p>  
                <p><strong>DATA: '+isnull(dbo.fn_data_string(@dt_nota_saida),'')+'</strong> </p>  
                <p><strong>REIMPR: '+isnull(dbo.fn_data_string(@dt_hoje),'')+' '+isnull(@hr_imp,'')+'</strong> </p> 
		</div>  		
	</div>
    <h3 class="section-title" style=" text-align: center;">Relatório de Nota Fiscal  '+cast(isnull(@cd_documento,'')as varchar(20))+'</h3>  
    <table style="width: 100%;">    
        <tr>    
            <td style="display: flex; flex-direction: column; gap: 20px;">    
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">    
                    <div style="text-align: left; width: 45%;">    
                        <p><strong>Identificação N.F:</strong> '+cast(isnull(@cd_identificacao_nota_saida,0) as nvarchar(20))+'</p>    
                        <p><strong>Saida:</strong> '+isnull(dbo.fn_data_string(@dt_saida_nota_saida),'')+'</p>    
						<p><strong>Série:</strong> '+isnull(@sg_serie_nota_fiscal,'')+'<p>  
                        <p><strong>Operação Fiscal:</strong> '+isnull(@nm_operacao_fiscal,'')+'</p>    
                        <p><strong>Código Operação:</strong> '+isnull(@cd_operacao_fiscal,'')+'<p>    
						<p><strong>Status Nota:</strong> '+isnull(@nm_status_nota,'')+'<p> 
                    </div>        
                    <div style="text-align: left;"> 
					    <p><strong>Comercial Operação:</strong> '+case when isnull(@ic_comercial_operacao,'') = 'S' then 'Sim' else 'Não' end +'</p>   
						<p><strong>Carta Correção:</strong> '+case when isnull(@ic_carta_correcao,'') = 'S' then 'Sim' else 'Não' end +'</p>  
						<p><strong>Duplicatas:</strong> '+cast(isnull(@qt_duplicatas,0) as nvarchar(20))+'</p>                   
						<p><strong>Vendedor Interno:</strong> '+isnull(@nm_vendedro_interno,'')+' </p>    
                        <p><strong>Vendedor Externo:</strong> '+isnull(@nm_vendedor_externo,'')+'</p>    
                        <p><strong>Cliente Grupo:</strong> '+isnull(@nm_cliente_grupo,'')+'</p>      
                    </div>       
        
                </div>    
            </td>    
        </tr>    
    </table>    
	   <h3 class="section-title">Cliente</h3>  
       <table style="width: 100%;">    
        <tr>    
            <td style="display: flex; flex-direction: column; gap: 20px;">    
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">    
                    <div style="text-align: left; width: 45%;">    
                        <p><strong>Cliente:</strong> '+isnull(@nm_fantasia_cliente,'')+'</p>    
                        <p><strong>CNPJ:</strong> '+isnull(@cd_cnpj_cliente,'')+'</p>    
                        <p><strong>Endereço: </strong>'+isnull(@nm_endereco_cliente,'')+' - N° '+ isnull(@cd_numero_endereco,'') + ' - '+ isnull(@nm_bairro,'') + ' - ' + isnull(@nm_cidade_cliente,'')+ '/'+isnull(@sg_estado_cliente,'')+'</p>
                        <p><strong>Telefone: </strong>'+isnull(@cd_telefone,'')+' '+ case when  isnull(@nm_contato_cliente,'') <> '' then '<strong> - Contato: </strong>' + isnull(@nm_contato_cliente,'')+'' else '' end + '</p>  		   
                    </div>        
                    <div style="text-align: left;"> 
					    <p><strong>Razão Social:</strong> '+isnull(@nm_razao_social_cliente,'')+'</p>   
						<p><strong>Dia da Semana:</strong> '+isnull(@nm_semana,'')+'</p>  
						<p><strong>Itinerário:</strong> '+cast(isnull(@nm_itinerario,0) as nvarchar(20))+'</p>         
                    </div>       
                </div>    
            </td>    
        </tr>    
    </table>    
   
    <h3 class="section-title">Produtos</h3>  
    <table>  
        <tr>  
		    <th>Item</th>
			<th>Pedido Venda</th>
            <th>Código</th>   
            <th>Descrição</th> 
			<th>Categoria</th>  
            <th>Un</th>  
			<th>Frete (R$)</th>  
            <th>Quantidade</th>  
            <th>Valor Un.</th>  
            '+ case when isnull(@ic_imposto_nota_saida,'N') = 'N' and @cd_empresa in (342,350)
                then '' 
        else ' <th>ICMS-ST (R$)</th> 
		       <th>% ICMS</th>  
               <th>IPI (R$)</th>
			   <th>% IPI</th>'end  +'
             <th>Total</th>  
        </tr>'  
-------------------------------------------------------------------------------------------------------
  
declare @id int = 0   
while exists ( select cd_controle from #itensTab )    
begin    
    
  select top 1    
    @id           = cd_controle,    
  
    @html_detalhe = @html_detalhe + '    
           <tr style="text-align: center;">        
               <td>'+cast(ISNULL(cd_controle, 0) as varchar(4))+'</td>  
			   <td >'+cast(ISNULL(cd_pedido_venda, 0) as varchar(20))+'</td> 
			   <td >'+cast(ISNULL(nm_fantasia_produto, '') as varchar(max))+'</td>  
			   <td style="text-align: left;">'+cast(ISNULL(nm_produto, '') as varchar(300))+' </td>  
			   <td >'+cast(ISNULL(nm_categoria_produto, '') as varchar(max))+'</td> 
			   <td>'+cast(ISNULL(sg_unidade_medida, '') as varchar(10))+'</td> 
			   <td>'+ISNULL(dbo.fn_formata_valor(vl_frete_item), 0)+'</td>   
			   <td>'+cast(ISNULL(qt_item_nota_saida,0) as varchar(30))+'</td>  
			   <td>'+ISNULL(dbo.fn_formata_valor(vl_unitario_item_nota), 0)+'</td>   
			  '+
			 case when isnull(@ic_imposto_nota_saida,'N') = 'N' and @cd_empresa in (342,350)  
        then ''
        else '<td style="font-size:12px;text-align:right">'+cast(isnull(dbo.fn_formata_valor(vl_icms_item),0)as varchar(20))+'</td>  
		      <td style="font-size:12px;text-align:right">'+cast(isnull(dbo.fn_formata_valor(pc_icms),0)as varchar(20))+'</td> 
              <td style="font-size:12px;text-align:right">'+cast(isnull(dbo.fn_formata_valor(vl_ipi),0) as varchar(20))+'</td>  
              <td style="font-size:12px;text-align:right">'+cast(isnull(dbo.fn_formata_valor(pc_ipi),0)as varchar(20))+'</td>'
	end  +
			'
			   <td>'+ISNULL(dbo.fn_formata_valor(vl_total_item), 0)+'</td>    
           </tr>'    
           
  from    
    #itensTab    
    
  order by    
    cd_controle    
        
  
  
  delete from #itensTab  where  cd_controle = @id    
    
    
end    
                   
        
--------------------------------------------------------------------------------------------------------------------  
  
  
set @html_rodape =' 
    <table style="width: 100%;">    
        <tr>    
            <td style="display: flex; flex-direction: column; gap: 20px;">    
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">    
                    <div style="text-align: left; width: 45%;">    
                        <p><strong></strong> </p>    
                        <p><strong></strong> </p>    
                        <p><strong></strong> </p>    
                        <p><strong></strong> </p>    
                        <p><strong></strong> </p>    
                    </div>        
                    <div style="text-align: left;">    
                        <p><strong>Quantidade Item:</strong> R$ '+cast(ISNULL(dbo.fn_formata_valor(@vl_total_item), 0)as varchar(20))+' </p>    
                        <p><strong>Frete:</strong> R$ '+cast(ISNULL(dbo.fn_formata_valor(@vl_frete_pedido_compra), 0.00)as varchar(20))+' </p> 
						'+
			        case when isnull(@ic_imposto_nota_saida,'N') = 'N' and @cd_empresa in (342,350)  
                    then ''
                    else '
                        <p><strong>IPI:</strong> '+cast(ISNULL(dbo.fn_formata_valor(@vl_total_ipi), 0)as varchar(20))+' </p>    
                        <p><strong>ICMS-ST:</strong> '+cast(ISNULL(dbo.fn_formata_valor(@vl_total_icms), 0)as varchar(20))+' </p> '
	                end  +
			           '<p><strong>Total:</strong> '+ISNULL(@vl_tota, '')+' </p>   
                    </div>       
                </div>    
            </td>    
        </tr>    
    </table>  
    <table style="width: 100%;">  
        <tr>  
            <td style="text-align: left;">  
                <div>  
                    <p style="font-size: 16px;"><b>Observações:</b></p>  
                    <p> </p>  
                    <p>'+cast(ISNULL(@ds_obs_compl_nota_saida,'')as varchar(8000))+'</p>  
                </div>  
            </td>  
        </tr>  
    </table>  
	 <table style="width: 100%;">  
        <tr>  
            <td style="text-align: left;">  
                <div>  
                    <p><b>Condição de Pagamento:</b></p>  
                    <p>('+CAST(isnull(@cd_condicao_pagamento,0) as varchar(20))+') '+ISNULL(@nm_condicao_pagamento,'')+'</p>  
                </div>  
            </td>  
        </tr>  
	  </table> 
	  
</body>  
  
</html>'      
--HTML Completo--------------------------------------------------------------------------------------    
    
set @html         =     
    @html_empresa +    
    @html_titulo  +    
   @html_geral   +  
 --@html_cab_det +    
   @html_detalhe +    
 --@html_rod_det +    
    
         
    @html_totais  +    
    @html_grafico +    
    @html_rodape      

-------------------------------------------------------------------------------------------------------------------------------------------------------
select 'Relatório de Nota Fiscal_'+CAST(isnull(@cd_documento,'')as varchar)+'' AS pdfName,isnull(@html,'') as RelatorioHTML

-------------------------------------------------------------------------------------------------------------------------------------------------------






----------------------------------------------------------------------------------------------------------------------------------------------
go


---------------------------------------------------------------------------
--exec pr_egis_relatorio_nota_fiscal 186,4253,0,''
------------------------------------------------------------------------------

