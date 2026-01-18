IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_consulta_positivacao_produto' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_consulta_positivacao_produto

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_consulta_positivacao_produto
-------------------------------------------------------------------------------
--pr_egis_relatorio_consulta_positivacao_produto
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
create procedure pr_egis_relatorio_consulta_positivacao_produto
@cd_relatorio  int  = 0,
@cd_parametro  int = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')
declare @data_grafico_bar       nvarchar(max)
declare @cd_empresa             int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
--declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
DECLARE @id                     int = 0   
declare @cd_cliente             int = 0
declare @cd_cliente_grupo       int = 0  
declare @cd_grupo_relatorio     int    
declare @cd_vendedor            int    
declare @nm_razao_social        varchar(60) = ''
declare @cd_categoria_produto   int = 0 
declare @cd_pedido_venda        int = 0 
declare @cd_tipo_pedido         int = 0
declare @cd_ramo_atividade      int = 0
declare @cd_status_cliente      int = 0 
declare @cd_unidade_medida      int = 0 
declare @cd_produto             int = 0
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
			@cd_cep_empresa			    varchar(20) = '',			
			@nm_bairro					varchar(200) = '',
			@cd_numero_endereco			varchar(20) = '',
			@cd_telefone				varchar(20) = '',
			@nm_condicao_pagamento		varchar(100) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40)   = '',
			@footerTitle				varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = '',
			@cd_categoria_cliente       int = 0 


--------------------------------------------------------------------------------------------------------

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
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
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_cliente             = valor from #json where campo = 'cd_cliente'
  select @cd_categoria_produto   = valor from #json where campo = 'cd_categoria_produto'
  select @cd_ramo_atividade      = valor from #json where campo = 'cd_ramo_atividade'
  select @cd_status_cliente      = valor from #json where campo = 'cd_status_cliente'
  select @cd_tipo_pedido         = valor from #json where campo = 'cd_tipo_pedido'
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
  select @cd_unidade_medida      = valor from #json where campo = 'cd_unidade_medida'
  select @cd_produto             = valor from #json where campo = 'cd_produto'
  --select @nm_razao_social        = valor from #json where campo = 'nm_razao_social'

   set @cd_cliente = isnull(@cd_cliente,0)

   if @cd_cliente = 0
   begin
     select @cd_cliente           = valor from #json where campo = 'nm_razao_social'

   end
end


-------------------------------------------------------------------------------------------------
declare @ic_processo char(1) = 'N'
 
 --select @cd_relatorio

select
  @titulo      = nm_relatorio,
  @ic_processo = isnull(ic_processo_relatorio, 'N')
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio
----------------------------------------------------------------------------------------------------------------------------
select    
  @dt_inicial			  = dt_inicial,    
  @dt_final				  = dt_final,    
  @cd_vendedor			  = isnull(cd_vendedor,0),  
--  @cd_cliente			  = isnull(cd_cliente,0),  
  @cd_ramo_atividade      = ISNULL(cd_ramo_atividade,0),
  @cd_status_cliente      = ISNULL(cd_status_cliente,0),
  @cd_categoria_produto   = isnull(cd_categoria_produto,0),
  @cd_tipo_pedido         = ISNULL(cd_tipo_pedido,0)
--  @nm_razao_social        = isnull(nm_razao_social,0) 
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
--Dados do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------

declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabeçalho da Empresa
declare @html_titulo     nvarchar(max) = '' --Título
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe
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

-- Obtém a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
---------------------------
--Cabeçalho da Empresa
----------------------------------------------------------------------------------------------------------------------

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
			flex:1;
        }  
  
        h2 {  
            color: #333;  
        }  
  
        table {  
            width: 100%;  
            border-collapse: collapse;  
            margin-bottom: 20px;  
            font-size: 12px;  
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
  tr {  
   page-break-inside: avoid;    
   page-break-after: auto;  
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
            font-size: 14px;  
            text-align: center;  
        }  
  #salva {  
     background-color: #1976D2;  
     color: white;  
     border: none;  
     padding: 10px 20px;  
     font-size: 16px;  
     cursor: pointer;  
     border-radius: 5px;  
     transition: background-color 0.3s;  
   }  
  
    #salva:hover {  
     background-color: #1565C0;  
   }  
    .nao-imprimir {  
            display: none;  
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
  
--select @nm_dados_cab_det

--select @nm_grupo_relatorio,@nm_dados_cab_det,* from #RelAtributo
--------------------------------------------------------------------------------------------------------------------------
--select @cd_cliente
--set @dt_inicial = '03/01/2025'
--set @dt_final = '03/04/2025'
--select 
--  identity(int,1,1)															  as cd_controle,  
--  c.cd_cliente_grupo                                                          as cd_cliente_grupo,  
--  max(cg.nm_cliente_grupo)                                                    as nm_cliente_grupo,  
--  c.cd_cliente                                                                as cd_cliente,  
--  c.nm_fantasia_cliente                                                       as nm_fantasia_cliente, 
--  c.cd_inscestadual															  as cd_inscestadual,	
--  cid.nm_cidade                                                               as nm_cidade,
--  est.sg_estado                                                               as sg_estado,
--  c.nm_email_cliente														  as nm_email_cliente,
--  c.cd_telefone															      as cd_telefone,
--  max(p.cd_pedido_venda)                   as cd_pedido_venda,
--  case when
--	COUNT(isnull(bb.cd_bem,0)) > 0 
--	then 
--	     'Possui Bem'
--	else 
--	     'Não Possui'
--	end                                                                       as bem,
--  max(
--      CASE 
--          WHEN c.cd_tipo_pessoa = 1 
--          THEN ISNULL(dbo.fn_formata_cnpj(c.cd_cnpj_cliente),'') 
--          ELSE ISNULL(dbo.fn_formata_cpf(c.cd_cnpj_cliente),'') 
--      END
--  )                                                                           as cd_cnpj_cliente,
--  max(c.nm_razao_social_cliente)                                              as nm_razao_social_cliente,
--  --max(i.cd_item_pedido_venda) as cd_item_pedido_venda,
--  max(sc.nm_status_cliente)                                                   as nm_status_cliente,
--  max(ra.nm_ramo_atividade) as nm_ramo_atividade,
--  sum(p.vl_total_pedido_venda)                                                 as vl_total_pedido_venda,
--  case when count(ISNULL(p.cd_pedido_venda, 0)) > 0 then 'Comprou' 
--      else 'Não Comprou' 
--  end                                                                         as situacao  
	
--	into
--	#PositivacaoCliente

--FROM pedido_venda p  
--inner join cliente c                     on c.cd_cliente            = p.cd_cliente  
--left outer join status_cliente sc        on sc.cd_status_cliente    = c.cd_status_cliente  
----left outer join pedido_venda_item i      on i.cd_pedido_venda       = p.cd_pedido_venda 
--left outer join Cliente_Grupo cg         on cg.cd_cliente_grupo     = c.cd_cliente_grupo    
--left outer join tipo_pedido tp           on tp.cd_tipo_pedido       = p.cd_tipo_pedido
--left outer join ramo_atividade ra        on ra.cd_ramo_atividade    = c.cd_ramo_atividade
--left outer join bem bb                   on bb.cd_cliente           = c.cd_cliente
--left outer join categoria_cliente cc     on cc.cd_categoria_cliente = c.cd_categoria_cliente
--left outer join Pais pa with(nolock)     on pa.cd_pais              = c.cd_pais
--left outer join Estado est with(nolock)  on est.cd_pais             = pa.cd_pais	
--                                            and est.cd_estado       = c.cd_estado
--left outer join cidade cid with(nolock)  on cid.cd_pais             = pa.cd_pais    
--											and cid.cd_estado       = est.cd_estado
--											and cid.cd_cidade       = c.cd_cidade  
--WHERE  
--  p.dt_pedido_venda between @dt_inicial and @dt_final 
--  and
--  p.cd_cliente = case when ISNULL(@cd_cliente,0) = 0 then p.cd_cliente else ISNULL(@cd_cliente,0) end  
--  and  
--  p.cd_vendedor = CASE WHEN ISNULL(@cd_vendedor,0) = 0 THEN p.cd_vendedor ELSE ISNULL(@cd_vendedor,0) end  
--  and
--  p.cd_tipo_pedido = CASE WHEN ISNULL(@cd_tipo_pedido,0) = 0 THEN p.cd_tipo_pedido ELSE ISNULL(@cd_tipo_pedido,0) end 
--  and 
--  isnull(ra.cd_ramo_atividade,0) = CASE WHEN ISNULL(@cd_ramo_atividade,0) = 0 THEN isnull(ra.cd_ramo_atividade,0) ELSE ISNULL(@cd_ramo_atividade,0) end 
--  and
--  c.cd_status_cliente = CASE WHEN ISNULL(@cd_status_cliente,0) = 0 THEN c.cd_status_cliente ELSE ISNULL(@cd_status_cliente,0) end 
--  and 
--  isnull(cc.cd_categoria_cliente,0) = CASE WHEN ISNULL(@cd_categoria_cliente,0) = 0 THEN isnull(cc.cd_categoria_cliente,0) ELSE ISNULL(@cd_categoria_cliente,0) end 
--  --and 
--  --isnull(i.cd_unidade_medida,0) = CASE WHEN ISNULL(@cd_unidade_medida,0) = 0 THEN isnull(i.cd_unidade_medida,0) ELSE ISNULL(@cd_unidade_medida,0) end 
--  --and 
--  --isnull(i.cd_produto,0) = CASE WHEN ISNULL(@cd_produto,0) = 0 THEN isnull(i.cd_produto,0) ELSE ISNULL(@cd_produto,0) end 
--  --and 
--  --i.cd_categoria_produto = CASE WHEN ISNULL(@cd_categoria_produto,0) = 0 THEN i.cd_categoria_produto ELSE ISNULL(@cd_categoria_produto,0) end 
--  --and
--  --i.dt_cancelamento_item IS NULL  

--GROUP BY  
--  c.cd_cliente_grupo,  
--  c.cd_cliente,  
--  c.nm_fantasia_cliente,
--  c.cd_inscestadual,	
--  cid.nm_cidade,     
--  est.sg_estado,     
--  c.nm_email_cliente,
--  c.cd_telefone		
--  order by
--  c.nm_fantasia_cliente
-----------------------------------------------------------------------------------------------------------------  
--  select 
--    identity(int,1,1)															as cd_controleb, 
--    COUNT(DISTINCT i.cd_produto)                                                as cd_produto_dif, 
--    sum(i.qt_item_pedido_venda)                                                 as qt_item_pedido_venda,
--	max(i.cd_pedido_venda) as cd_pedido_venda,
-- c.cd_cliente_grupo                                                           as cd_cliente_grupo,  
--  max(cg.nm_cliente_grupo)                                                    as nm_cliente_grupo,  
--  c.cd_cliente                                                                as cd_cliente,  
--  c.nm_fantasia_cliente                                                       as nm_fantasia_cliente, 
--  c.cd_inscestadual															  as cd_inscestadual,	
--  cid.nm_cidade                                                               as nm_cidade,
--  est.sg_estado                                                               as sg_estado,
--  c.nm_email_cliente														  as nm_email_cliente,
--  c.cd_telefone															      as cd_telefone,
 
--  max(
--      CASE 
--          WHEN c.cd_tipo_pessoa = 1 
--          THEN ISNULL(dbo.fn_formata_cnpj(c.cd_cnpj_cliente),'') 
--          ELSE ISNULL(dbo.fn_formata_cpf(c.cd_cnpj_cliente),'') 
--      END
--  )                                                                           as cd_cnpj_cliente,
--  max(c.nm_razao_social_cliente)                                              as nm_razao_social_cliente,
--  max(sc.nm_status_cliente)                                                   as nm_status_cliente,
--  max(ra.nm_ramo_atividade) as nm_ramo_atividade,
--  p.vl_total_pedido_venda                                                 as vl_total_pedido_venda,
--  case when count(ISNULL(p.cd_pedido_venda, 0)) > 0 then 'Comprou' 
--      else 'Não Comprou' 
--  end                                                                         as situacao  

--	into
--	#itenPedido
--  from 
--    pedido_venda p
--  left outer join pedido_venda_item i      on i.cd_pedido_venda       = p.cd_pedido_venda 
--  left outer join cliente c                on c.cd_cliente            = p.cd_cliente  
--  left outer join status_cliente sc        on sc.cd_status_cliente    = c.cd_status_cliente  
--  left outer join Cliente_Grupo cg         on cg.cd_cliente_grupo     = c.cd_cliente_grupo    
--  left outer join tipo_pedido tp           on tp.cd_tipo_pedido       = p.cd_tipo_pedido
--  left outer join ramo_atividade ra        on ra.cd_ramo_atividade    = c.cd_ramo_atividade
--  left outer join categoria_cliente cc     on cc.cd_categoria_cliente = c.cd_categoria_cliente
--  left outer join Pais pa with(nolock)     on pa.cd_pais              = c.cd_pais
--left outer join Estado est with(nolock)  on est.cd_pais             = pa.cd_pais	
--                                            and est.cd_estado       = c.cd_estado
--left outer join cidade cid with(nolock)  on cid.cd_pais             = pa.cd_pais    
--											and cid.cd_estado       = est.cd_estado
--											and cid.cd_cidade       = c.cd_cidade 
--  where
--  p.dt_pedido_venda between @dt_inicial and @dt_final 
--  and
--  p.cd_cliente = case when ISNULL(@cd_cliente,0) = 0 then p.cd_cliente else ISNULL(@cd_cliente,0) end  
--  and  
--  p.cd_vendedor = CASE WHEN ISNULL(@cd_vendedor,0) = 0 THEN p.cd_vendedor ELSE ISNULL(@cd_vendedor,0) end  
--  and
--  p.cd_tipo_pedido = CASE WHEN ISNULL(@cd_tipo_pedido,0) = 0 THEN p.cd_tipo_pedido ELSE ISNULL(@cd_tipo_pedido,0) end 
--  and 
--  isnull(ra.cd_ramo_atividade,0) = CASE WHEN ISNULL(@cd_ramo_atividade,0) = 0 THEN isnull(ra.cd_ramo_atividade,0) ELSE ISNULL(@cd_ramo_atividade,0) end 
--  and
--  c.cd_status_cliente = CASE WHEN ISNULL(@cd_status_cliente,0) = 0 THEN c.cd_status_cliente ELSE ISNULL(@cd_status_cliente,0) end 
--  and 
--  isnull(cc.cd_categoria_cliente,0) = CASE WHEN ISNULL(@cd_categoria_cliente,0) = 0 THEN isnull(cc.cd_categoria_cliente,0) ELSE ISNULL(@cd_categoria_cliente,0) end 
--  and 
--  isnull(i.cd_unidade_medida,0) = CASE WHEN ISNULL(@cd_unidade_medida,0) = 0 THEN isnull(i.cd_unidade_medida,0) ELSE ISNULL(@cd_unidade_medida,0) end 
--  and 
--  isnull(i.cd_produto,0) = CASE WHEN ISNULL(@cd_produto,0) = 0 THEN isnull(i.cd_produto,0) ELSE ISNULL(@cd_produto,0) end 
--  and 
--  i.cd_categoria_produto = CASE WHEN ISNULL(@cd_categoria_produto,0) = 0 THEN i.cd_categoria_produto ELSE ISNULL(@cd_categoria_produto,0) end 
--  and
--  i.dt_cancelamento_item IS NULL  
--GROUP BY  
--  c.cd_cliente_grupo,  
--  c.cd_cliente,  
--  p.vl_total_pedido_venda,
--  c.nm_fantasia_cliente,
--  c.cd_inscestadual,	
--  cid.nm_cidade,     
--  est.sg_estado,     
--  c.nm_email_cliente,
--  c.cd_telefone		
--  order by
--  c.nm_fantasia_cliente
------------------------------------------------------------------------------------------------------------------------------------------------
---- select * from #itenPedido
-- select 
-- IDENTITY(int,1,1) AS  cd_controle,
--  p.nm_fantasia_cliente as nm_fantasia_cliente,
--  p.cd_cnpj_cliente          as cd_cnpj_cliente,
--  p.nm_razao_social_cliente  as nm_razao_social_cliente,
--  p.situacao as situacao,
--  ipp.cd_produto_dif AS cd_produto_dif,
--  ipp.qt_item_pedido_venda AS qt_item_pedido_venda,
--  ipp.cd_pedido_venda as cd_pedido_venda_item,
--  p.vl_total_pedido_venda as vl_total_pedido_venda,
--  p.nm_status_cliente as nm_status_cliente,
--  p.bem as bem,
--  p.cd_cliente as cd_cliente
--into 
--  #finalTT
--from 
--  #PositivacaoCliente p
--  left outer join #itenPedido ipp on ipp.cd_pedido_venda = p.cd_pedido_venda
	--select * from #finalTT
select 
  identity(int,1,1)															  as cd_controle,  
  c.cd_cliente_grupo                                                          as cd_cliente_grupo,  
  max(cg.nm_cliente_grupo)                                                    as nm_cliente_grupo,  
  c.cd_cliente                                                                as cd_cliente,  
  c.nm_fantasia_cliente                                                       as nm_fantasia_cliente, 
  c.cd_inscestadual															  as cd_inscestadual,	
  cid.nm_cidade                                                               as nm_cidade,
  est.sg_estado                                                               as sg_estado,
  c.nm_email_cliente														  as nm_email_cliente,
  c.cd_telefone															      as cd_telefone,
  case when
	COUNT(isnull(bb.cd_bem,0)) > 0 
	then 
	     'Possui Bem'
	else 
	     'Não Possui'
	end                                                                       as bem,
  max(
      CASE 
          WHEN c.cd_tipo_pessoa = 1 
          THEN ISNULL(dbo.fn_formata_cnpj(c.cd_cnpj_cliente),'') 
          ELSE ISNULL(dbo.fn_formata_cpf(c.cd_cnpj_cliente),'') 
      END
  )                                                                           as cd_cnpj_cliente,
  max(c.nm_razao_social_cliente)                                              as nm_razao_social_cliente,
  max(sc.nm_status_cliente)                                                   as nm_status_cliente,
  COUNT(DISTINCT i.cd_produto)                                                as cd_produto_dif, 
  sum(i.qt_item_pedido_venda)                                                 as qt_item_pedido_venda,
  max(ra.nm_ramo_atividade) as nm_ramo_atividade,
  sum((i.qt_item_pedido_venda * vl_unitario_item_pedido))                     as vl_total_pedido_venda,
  case when count(ISNULL(p.cd_pedido_venda, 0)) > 0 then 'Comprou' 
      else 'Não Comprou' 
  end                                                                         as situacao  
	
	into
	#PositivacaoCliente

FROM pedido_venda p  
inner join cliente c                     on c.cd_cliente            = p.cd_cliente  
left outer join status_cliente sc        on sc.cd_status_cliente    = c.cd_status_cliente  
left outer join Cliente_Grupo cg         on cg.cd_cliente_grupo     = c.cd_cliente_grupo  
left outer join pedido_venda_item i      on i.cd_pedido_venda       = p.cd_pedido_venda  
left outer join tipo_pedido tp           on tp.cd_tipo_pedido       = p.cd_tipo_pedido
left outer join ramo_atividade ra        on ra.cd_ramo_atividade    = c.cd_ramo_atividade
left outer join bem bb                   on bb.cd_cliente           = c.cd_cliente
left outer join categoria_cliente cc     on cc.cd_categoria_cliente = c.cd_categoria_cliente
left outer join Pais pa with(nolock)     on pa.cd_pais              = c.cd_pais
left outer join Estado est with(nolock)  on est.cd_pais             = pa.cd_pais	
                                            and est.cd_estado       = c.cd_estado
left outer join cidade cid with(nolock)  on cid.cd_pais             = pa.cd_pais    
											and cid.cd_estado       = est.cd_estado
											and cid.cd_cidade       = c.cd_cidade  
WHERE  
  p.dt_pedido_venda between @dt_inicial and @dt_final  
  and
  p.cd_cliente = case when ISNULL(@cd_cliente,0) = 0 then p.cd_cliente else ISNULL(@cd_cliente,0) end  
  and 
  p.cd_vendedor = CASE WHEN ISNULL(@cd_vendedor,0) = 0 THEN p.cd_vendedor ELSE ISNULL(@cd_vendedor,0) end  
  and 
  i.cd_categoria_produto = CASE WHEN ISNULL(@cd_categoria_produto,0) = 0 THEN i.cd_categoria_produto ELSE ISNULL(@cd_categoria_produto,0) end 
  and
  p.cd_tipo_pedido = CASE WHEN ISNULL(@cd_tipo_pedido,0) = 0 THEN p.cd_tipo_pedido ELSE ISNULL(@cd_tipo_pedido,0) end 
  and 
  isnull(ra.cd_ramo_atividade,0) = CASE WHEN ISNULL(@cd_ramo_atividade,0) = 0 THEN isnull(ra.cd_ramo_atividade,0) ELSE ISNULL(@cd_ramo_atividade,0) end 
  and
  c.cd_status_cliente = CASE WHEN ISNULL(@cd_status_cliente,0) = 0 THEN c.cd_status_cliente ELSE ISNULL(@cd_status_cliente,0) end 
   and 
  isnull(i.cd_unidade_medida,0) = CASE WHEN ISNULL(@cd_unidade_medida,0) = 0 THEN isnull(i.cd_unidade_medida,0) ELSE ISNULL(@cd_unidade_medida,0) end 
   and 
  isnull(i.cd_produto,0) = CASE WHEN ISNULL(@cd_produto,0) = 0 THEN isnull(i.cd_produto,0) ELSE ISNULL(@cd_produto,0) end 
   and
  isnull(cc.cd_categoria_cliente,0) = CASE WHEN ISNULL(@cd_categoria_cliente,0) = 0 THEN isnull(cc.cd_categoria_cliente,0) ELSE ISNULL(@cd_categoria_cliente,0) end 
  and 
  i.dt_cancelamento_item IS NULL  

GROUP BY  
  c.cd_cliente_grupo,  
  c.cd_cliente,  
  c.nm_fantasia_cliente,
  c.cd_inscestadual,	
  cid.nm_cidade,     
  est.sg_estado,     
  c.nm_email_cliente,
  c.cd_telefone		
  order by
  c.nm_fantasia_cliente
----------------------------------------------------------------------------------------------------------      
 if isnull(@cd_parametro,0) = 1    
 begin    
    select * from #PositivacaoCliente    
  return    
 end 
 declare @qt_total_cliente int = 0 
 select 
	@qt_total_cliente = COUNT(cd_cliente)
 from #PositivacaoCliente
----------------------------------------------------------------------------------------------------------

set @html_geral ='
    <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 20%;">'+case when isnull(@titulo,'') <> '' then ''+isnull(@titulo,'')+'' else 'Positivação de Produtos por Clientes' end +'</p>  
    </div>  
	<div>
    <table>
      <tr class="tamanho">
          <th>Razão Social</th>
		  <th>Cliente</th>
		  <th>CNPJ</th>
          <th>Situação Cliente</th>
		  <th>Ativo</th>
          <th>Produtos Diferentes</th>
          <th>Qtd. Comprada</th>
          <th>Valor Total</th>
          <th>Situação Compra</th>
        </tr>'
--------------------------------------------------------------------------------------------------------------
WHILE exists (select top 1 cd_controle from #PositivacaoCliente)
  begin
  select top 1 
	 @id         = cd_controle,
	 @html_geral = @html_geral+ '
		<tr style="text-align: center;">
		  <td style="text-align: left;">'+isnull(nm_razao_social_cliente,'')+'</td>
		  <td style="text-align: left;">'+isnull(nm_fantasia_cliente,'')+'</td>
		  <td>'+isnull(cd_cnpj_cliente,'')+'</td>
		  <td>'+isnull(nm_status_cliente,'')+'</td>
		  <td>'+isnull(bem,'')+'</td>
		  <td>'+cast(isnull(cd_produto_dif,0) as nvarchar(20))+'</td>
		  <td>'+cast(isnull(qt_item_pedido_venda,0) as nvarchar(20))+'</td>
		  <td>'+cast(isnull(dbo.fn_formata_valor(vl_total_pedido_venda),0) as nvarchar(20))+'</td> 
		  <td>'+isnull(situacao,'')+'</td>
		</tr>
	 '
 from #PositivacaoCliente
  DELETE FROM #PositivacaoCliente WHERE cd_controle = @id  
END  
--------------------------------------------------------------------------------------------------------------------
set @html_rodape =
    '
	</table>
	<div class="section-title">
		<p><strong>Total de Clientes: '+cast(isnull(@qt_total_cliente,0)as nvarchar(20))+'</strong></p>
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
--exec pr_egis_relatorio_consulta_positivacao_produto 214,'' 
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
--'[{
--    "cd_menu": "0",
--    "cd_form": 158,
--    "cd_documento_form": 61,
--    "cd_parametro_form": "2",
--    "cd_usuario": "4439",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "4439",
--    "dt_usuario": "2025-05-13",
--    "lookup_formEspecial": {},
--    "cd_parametro_relatorio": "61",
--    "cd_relatorio": "288",
--    "dt_inicial": "2025-01-01",
--    "dt_final": "2025-04-30",
--    "nm_razao_social": 393,
--    "cd_cliente":393,
--    "cd_categoria_produto": null,
--    "cd_vendedor": null,
--    "cd_tipo_pedido": null,
--    "cd_ramo_atividade": null,
--    "cd_unidade_medida": null,
--    "cd_produto": null,
--    "cd_categoria_cliente": null,
--    "detalhe": [],
--    "lote": [],
--    "cd_modulo": "241"
--}]'


