IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_nota_fiscal_cliente' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_nota_fiscal_cliente

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_nota_fiscal_cliente
-------------------------------------------------------------------------------
--pr_relatorio_nota_fiscal_cliente_teste
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Jo�o Pedro Mar�al
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relat�rio Padr�o Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025
--Altera��o        : 
--
--
------------------------------------------------------------------------------
create procedure pr_relatorio_nota_fiscal_cliente
@cd_relatorio int   = 0,
@cd_documento int   = 0,
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
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int 
declare @ic_valor_comercial     varchar(10)
declare @cd_tipo_destinatario   int = 0
declare @cd_grupo_relatorio     int = 0
declare @cd_cliente             int = 0
declare @cd_tipo_relatorio      int = 0
declare @cd_cliente_grupo       int = 0
DECLARE @id                     int = 0 
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
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_razao_social_cliente	varchar(200) = '',
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
  select @cd_cliente             = valor from #json where campo = 'cd_cliente'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_cliente_grupo       = valor from #json where campo = 'cd_grupo_cliente'  
  select @cd_tipo_relatorio      = Valor from #json where campo = 'cd_tipo_relatorio_parametro'


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
  @dt_inicial        = dt_inicial,  
  @dt_final          = dt_final,  
  @cd_cliente        = isnull(cd_cliente,0),
  @cd_cliente_grupo = isnull(cd_grupo_cliente,0),
  @cd_tipo_relatorio = isnull(cd_tipo_relatorio_parametro,1)
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
------------------------------

--select @dt_final
---------------------------------------------------------------------------------------------------------------------------------------------
--T�tulo do Relat�rio
---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio


--select @titulo
--
--select @nm_cor_empresa
-----------------------
--Cabe�alho da Empresa----------------------------------------------------------------------------------------------------------------------
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
            font-size: 75%;
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

set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)

SET @ic_valor_comercial = 'S'
set @cd_tipo_destinatario = 1
--set @dt_inicial = '2025-01-01'
--set @dt_final = '2025-01-31'
--set @cd_cliente = 636
--set @cd_tipo_relatorio = 1
-------------------------------------------------------------------------------------------------------
 SELECT     
   --IDENTITY(int,1,1)                                         as cd_controle,
   2                                                         as cd_tipo_relatorio,
   dbo.fn_data_string(ns.dt_nota_saida)                      as dt_nota_saida,
   ns.cd_identificacao_nota_saida                            as cd_identificacao_nota_saida,
  -- ns.cd_nota_saida                                          as cd_nota_saida,
   dbo.fn_data_string(ns.dt_saida_nota_saida)                as dt_saida_nota_saida,
   ofi.nm_operacao_fiscal                                    as nm_operacao_fiscal,
   ofi.cd_mascara_operacao                                   as cd_operacao_fiscal,
   isNull(ofi.ic_comercial_operacao,'N')                     as ic_comercial_operacao,
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
   cl.nm_razao_social_cliente                  as nm_razao_social_cliente

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
   

 WHERE
   ns.cd_cliente           = case when isnull(@cd_cliente,0) = 0 then ns.cd_cliente else @cd_cliente end 
   and  
   ns.dt_nota_saida between @dt_inicial and @dt_final 
   and
   ns.cd_tipo_destinatario = @cd_tipo_destinatario 
   and
   cl.cd_cliente_grupo = case when isnull(@cd_cliente_grupo,0) = 0 then cl.cd_cliente_grupo else isnull(@cd_cliente_grupo,0) end
   and
   isNull(ofi.ic_comercial_operacao,'N') = ( case when @ic_valor_comercial = 'S' then 'S' else isNull(ofi.ic_comercial_operacao,'N') end ) 

 --ORDER by
 --  ns.dt_nota_saida desc, ns.cd_identificacao_nota_saida desc
----------------------------------------------------------------------------------------------------------------------------------------------------
   union all

----------------------------------------------------------------------------------------------------------------------------------------------------


 SELECT     
  -- IDENTITY(int,1,1)                                         as cd_controle,
   1                                                         as cd_tipo_relatorio,
   dbo.fn_data_string(ns.dt_pedido_venda)                    as dt_nota_saida,
   ns.cd_pedido_venda                                        as cd_identificacao_nota_saida,
  --ns.cd_nota_saida                                          as cd_nota_saida,
   dbo.fn_data_string(ns.dt_fechamento_pedido)               as dt_saida_nota_saida,
   ofi.nm_operacao_fiscal                                    as nm_operacao_fiscal,
   ofi.cd_mascara_operacao                                   as cd_operacao_fiscal,
   isNull(ofi.ic_comercial_operacao,'N')                     as ic_comercial_operacao,
    case when ns.cd_status_pedido<>7 then
      isnull(ns.vl_total_pedido_venda,0)
   else
      0.00
   end                                                       as vl_total,

   case when exists ( select top 1 c.* from Carta_Correcao c with (nolock) 
                      where c.cd_nota_saida = ns.cd_pedido_venda ) then 'S'
        else 'N' end                                        as ic_carta_correcao, 

   Cast(
    (select 
      count(nsi.cd_item_pedido_venda) 
    from
      Pedido_Venda_Item nsi with (nolock) 
    where
      nsi.cd_pedido_venda = ns.cd_pedido_venda)

   as int)                                               as qt_item_nota_saida,
   
    isnull((select count('x') from Documento_Receber x with (nolock) 
                      where x.cd_pedido_venda = ns.cd_pedido_venda 
                      group by x.cd_pedido_venda),0)                 as qt_duplicatas,


  Cast(
    (select 
      sum(nsi.qt_item_pedido_venda)
    from
      pedido_venda_item nsi with (nolock) 
    where
      nsi.cd_pedido_venda = ns.cd_pedido_venda )


   as decimal(25,6))                                               as qt_soma_itens,


  Cast(
    (select 
      isnull(sum( isnull(p.qt_volume_produto,0) * isnull(nsv.qt_item_pedido_venda  ,0)  ),0)
    from
      pedido_venda_item nsv with (nolock) 
      inner join produto p on p.cd_produto = nsv.cd_produto
    where
      nsv.cd_pedido_venda = ns.cd_pedido_venda 
    )

   as decimal(25,2))                                               as qt_volume,


   (select top 1 x.cd_vendedor from Vendedor x with (nolock) left outer join
    Cliente c on c.cd_cliente = ns.cd_cliente
    where x.cd_vendedor = c.cd_vendedor_interno)                   as cd_vendedor_interno,
 
    (select top 1 x.nm_fantasia_vendedor from Vendedor x with (nolock) left outer join
    Cliente c on c.cd_cliente = ns.cd_cliente
    where x.cd_vendedor = c.cd_vendedor_interno)                   as nm_vendedor_interno,
    
    ns.cd_vendedor as cd_vendedor_externo, 
    (select x.nm_fantasia_vendedor from Vendedor x with (nolock) 
                                  where x.cd_vendedor = ns.cd_vendedor) as nm_vendedor_externo,
  


   cg.nm_cliente_grupo                       as nm_cliente_grupo,

   snf.nm_tipo_pedido                        as sg_serie_nota_fiscal,
 
   cl.nm_fantasia_cliente                    as nm_fantasia_cliente,
   cl.nm_razao_social_cliente                as nm_razao_social_cliente

   --into
   --#tabelaItens 

 FROM
   Pedido_Venda ns                             with (nolock)
   left outer join Nota_Saida n                with (nolock) on n.cd_pedido_venda        = ns.cd_pedido_venda
   left outer join Operacao_Fiscal ofi         with (nolock) on ofi.cd_operacao_fiscal   = n.cd_operacao_fiscal 
   left outer join Cliente cl                  with (nolock) on ns.cd_cliente            = cl.cd_cliente 
   left outer join Vendedor v			       with (nolock) on v.cd_vendedor            = ns.cd_vendedor
   left outer join Cliente_Grupo cg            with (nolock) on cl.cd_cliente_grupo      = cg.cd_cliente_grupo
   left outer join Condicao_Pagamento cp       with (nolock) on cp.cd_condicao_pagamento = ns.cd_condicao_pagamento
   left outer join Tipo_Pedido snf             with (nolock) on snf.cd_tipo_pedido       = ns.cd_tipo_pedido
   left outer join Categoria_Cliente cac       with (nolock) on cac.cd_categoria_cliente   = cl.cd_categoria_cliente
   left outer join Grupo_Categoria_Cliente gcc with (nolock) on gcc.cd_grupo_categ_cliente = cac.cd_grupo_categoria_cli
   left outer join status_cliente sc                         on sc.cd_status_cliente       = cl.cd_status_cliente
   

 WHERE
   ns.cd_cliente = case when isnull(@cd_cliente,0) = 0 then ns.cd_cliente else isnull(@cd_cliente,0) end 
   and  
   ns.dt_pedido_venda between @dt_inicial and @dt_final 
   and
   cl.cd_cliente_grupo = case when isnull(@cd_cliente_grupo,0) = 0 then cl.cd_cliente_grupo else isnull(@cd_cliente_grupo,0) end
  -- and
  -- ns.cd_tipo_destinatario = @cd_tipo_destinatario 
   --and
   --isNull(ofi.ic_comercial_operacao,'N') = ( case when @ic_valor_comercial = 'S' then 'S' else isNull(ofi.ic_comercial_operacao,'N') end ) 

 --ORDER by
 --  ns.dt_pedido_venda desc, 
 --  ns.cd_pedido_venda desc

----------------------------------------------------------------------------------------------------------------------------------------------------
select 
IDENTITY(Int,1,1) as cd_controle,
dt_nota_saida,
cd_identificacao_nota_saida,
dt_saida_nota_saida,
nm_operacao_fiscal,
cd_operacao_fiscal,
ic_comercial_operacao,
vl_total,
ic_carta_correcao,
qt_item_nota_saida,
qt_duplicatas,
qt_soma_itens,
qt_volume,
cd_vendedor_interno,
nm_vendedor_interno,
nm_vendedor_externo,
sg_serie_nota_fiscal,
nm_fantasia_cliente,
nm_razao_social_cliente

into
#saidaRel
from #tabelaItens
 where 
 cd_tipo_relatorio  = @cd_tipo_relatorio

ORDER by
 dt_nota_saida desc, 
 cd_identificacao_nota_saida desc
----------------------------------------------------------------------------------------------------------------------------------------------------
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #saidaRel  
  return  
 end  

--------------------------------------------------------------------------------------------------------------
declare @dt_nota_saida               nvarchar(20)
declare @cd_identificacao_nota_saida nvarchar(60)
declare @cd_nota_saida   			 nvarchar(60)
declare @dt_saida_nota_saida		 nvarchar(15)
declare @dt_saida_nota      		 nvarchar(15)
declare @nm_operacao_fiscal          nvarchar(20)
declare @cd_operacao_fiscal          nvarchar(40) 
declare @ic_comercial_operacao       nvarchar(40)
declare @vl_total                    float = 0 
declare @vl_total_cancelamento       float = 0 
declare @vl_total_devolucao          float = 0 
declare @ic_carta_correcao           nvarchar(5)
declare @qt_item_nota_saida          float = 0
declare @qt_soma_itens               float = 0
declare @qt_volume                   float = 0
declare @nm_status_nota              nvarchar(20)
declare @qtd_duplicatas              int = 0
declare @nm_vendedor_interno         nvarchar(60)
declare @nm_vendedor_externo         nvarchar(60)
declare @cd_telefone_nota_saida      nvarchar(20)
declare @cd_ddd_nota_saida           int = 0
declare @nm_cliente_grupo            nvarchar(60)
declare @nm_fantasia_cliente         nvarchar(60)
declare @nm_razao_social_cliente_tb  nvarchar(60)
Declare @sg_serie_nota_fiscal        nvarchar(15)
declare @qt_total_nota               float
declare @vl_total_nota               float


select 
	@qt_total_nota = count(cd_identificacao_nota_saida),
	@vl_total_nota = sum (vl_total)
from #saidaRel

--------------------------------------------------------------------------------------------------------------
set @html_geral = '<div>
		<p class="section-title" style="text-align: center; padding: 8px;">'+case when ISNULL(@cd_tipo_relatorio,2) = 2 then 'Nota Fiscal por Cliente de '+cast(isnull(dbo.fn_data_string(@dt_inicial),'')as nvarchar(20))+' á '+cast(isnull(dbo.fn_data_string(@dt_final),'')as nvarchar(20))+'' else 'Pedido por Cliente '+cast(isnull(dbo.fn_data_string(@dt_inicial),'')as nvarchar(20))+' á '+cast(isnull(dbo.fn_data_string(@dt_final),'')as nvarchar(20))+''end +'</p>
	</div>
	<div>
    <table>
      <tr class="tamanho">
		  '+case when ISNULL(@cd_tipo_relatorio,2) = 2 then '<th>Série</th>' else '<th>Tipo</th>' end +'
          '+case when ISNULL(@cd_tipo_relatorio,2) = 2 then '<th>Nota</th>' else '<th>Pedido</th>' end +'
          <th>Emissão</th>
		  <th>Data Saida</th>
		  <th>CFOP</th>
		  <th>Operação Fiscal</th>
          <th>Comercial</th>
          <th>Volume</th>
          <th>Total</th>
          <th>Documentos</th>
          <th>Carta Correção</th>
          <th>Itens</th>
          <th>Cliente</th>
          <th>Razão Social</th>
          <th>Vendedor Interno</th>
          <th>Vendedor Externo</th>
      </tr>'
					   
--------------------------------------------------------------------------------------------------------------

while exists ( select top 1 cd_controle from #saidaRel)
begin
	select top 1

		@id                          = cd_controle,
		@sg_serie_nota_fiscal        = sg_serie_nota_fiscal,
		@cd_identificacao_nota_saida = cd_identificacao_nota_saida,
		@dt_saida_nota_saida         = CONVERT(VARCHAR(15),dt_saida_nota_saida,103),
		@dt_nota_saida               = CONVERT(VARCHAR(15),dt_nota_saida,103),
		@cd_operacao_fiscal          = cd_operacao_fiscal,
		@nm_operacao_fiscal          = nm_operacao_fiscal,
		@ic_comercial_operacao       = ic_comercial_operacao,
		@qt_volume                   = qt_volume,
		@vl_total                    = vl_total,
		@qtd_duplicatas              = qt_duplicatas,
		@ic_carta_correcao           = ic_carta_correcao,
		@qt_item_nota_saida          = qt_item_nota_saida,
		@nm_fantasia_cliente         = nm_fantasia_cliente,
		@nm_razao_social_cliente     = nm_razao_social_cliente,
		@nm_vendedor_interno         = nm_vendedor_interno,
		@nm_vendedor_externo         = nm_vendedor_externo



	from #saidaRel

 set @html_geral = @html_geral +'<tr class="tamanho">

									<td>'+isnull(@sg_serie_nota_fiscal,'')+'</td>
									<td>'+isnull(@cd_identificacao_nota_saida,'')+'</td>
									<td>'+isnull(@dt_nota_saida,'')+'</td>
									<td>'+isnull(@dt_saida_nota_saida,'')+'</td>
									<td>'+cast(isnull(@cd_operacao_fiscal,0) as nvarchar(15))+'</td>
									<td>'+isnull(@nm_operacao_fiscal,'')+'</td>
									<td>'+isnull(@ic_comercial_operacao,'')+'</td>
									<td>'+cast(isnull(dbo.fn_formata_valor(@qt_volume),'') as nvarchar(10))+'</td>
									<td>'+cast(isnull(dbo.fn_formata_valor(@vl_total),'') as nvarchar(10))+'</td>
									<td>'+cast(isnull(@qtd_duplicatas,'') as nvarchar(10))+'</td>
									<td>'+isnull(@ic_carta_correcao,'')+'</td>
									<td>'+cast(isnull(@qt_item_nota_saida,'') as nvarchar(10))+'</td>
									<td>'+isnull(@nm_fantasia_cliente,'')+'</td>
									<td>'+isnull(@nm_razao_social_cliente,'')+'</td>
									<td>'+isnull(@nm_vendedor_interno,'')+'</td>
									<td>'+isnull(@nm_vendedor_externo,'')+'</td>
								  </tr>'

     
	 delete from #saidaRel where cd_controle = @id
 end
--------------------------------------------------------------------------------------------------------------------
set @html_rodape =
    '</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
	<div class="section-title">	
	  <p>Total de Notas: '+cast(isnull(@qt_total_nota,0) as nvarchar(10))+'</p><br>
      <p>Valor Total: '+cast(isnull(dbo.fn_formata_valor(@vl_total_nota),0) as nvarchar(15))+'</p>
    </div>
    <p>'+@ds_relatorio+'</p>
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
--exec pr_relatorio_nota_fiscal_cliente 228,0,0,''
------------------------------------------------------------------------------

