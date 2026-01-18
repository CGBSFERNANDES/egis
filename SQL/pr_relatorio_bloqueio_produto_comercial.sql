IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_bloqueio_produto_comercial' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_bloqueio_produto_comercial

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_categoria_produto
-------------------------------------------------------------------------------
--pr_egis_relatorio_diario_pedidos_separacao
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
create procedure pr_relatorio_bloqueio_produto_comercial
@cd_relatorio int   = 0,
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
declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
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
	--		@nm_fantasia_cliente  	    varchar(200) = '',
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
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = ''



--------------------------------------------------------------------------------------------------------

--set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
set @cd_parametro      = 0
set @cd_empresa        = 0
set @cd_form           = 0
set @cd_parametro      = 0
set @cd_documento      = 0
set @dt_usuario        = GETDATE()
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
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio_form'


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
  @titulo      = nm_relatorio,
  @ic_processo = isnull(ic_processo_relatorio, 'N')
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio

----------------------------------------------------------------------------------------------------------------------------
/*
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
*/
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
            font-size: 95%;
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

--select @nm_dados_cab_det

--select @nm_grupo_relatorio,@nm_dados_cab_det,* from #RelAtributo

set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
--------------------------------------------------------------------------------------------------------------------------
select 
  identity(int,1,1)                        as cd_controle,
  isnull(g.nm_cliente_grupo,'')            as nm_cliente_grupo,
  isnull(c.nm_fantasia_cliente,'')         as nm_fantasia_cliente,
  CONVERT(VARCHAR,b.dt_usuario, 103)       as dt_bloqueio_produto,
  u.nm_fantasia_usuario                    as nm_fantasia_usuario,
  p.cd_produto                             as cd_produto,
  p.cd_mascara_produto                     as cd_mascara_produto,
  p.nm_produto                             as nm_produto,
  um.sg_unidade_medida                     as sg_unidade_medida,
  p.qt_multiplo_embalagem                  as qt_multiplo_embalagem,
  day(@dt_hoje  - b.dt_usuario)             as dias
  
  into 
  #bloqueio
from
  Bloqueio_Cliente_Produto b
  inner join produto p                    on p.cd_produto         = b.cd_produto
  left outer join unidade_medida um       on um.cd_unidade_medida = p.cd_unidade_medida 
  left outer join cliente_grupo g         on g.cd_cliente_grupo   = b.cd_cliente_grupo
  left outer join cliente c               on c.cd_cliente         = b.cd_cliente
  left outer join egisadmin.dbo.usuario u on u.cd_usuario         = b.cd_usuario
 
-------------------------------------------------------------------------------------------------------------
declare @nm_cliente            nvarchar(100)
declare @nm_fantasia_cliente   nvarchar(30)
declare @dt_bloqueio_produto   nvarchar(15)
declare @nm_fantasia_usuario   nvarchar(50)
declare @nm_produto            nvarchar(100)
declare @cd_produto            int =0
declare @cd_mascara_produto	   int = 0
declare @sg_unidade_medida     nvarchar(10)
declare @qt_multiplo_embalagem float = 0
DECLARE @dias                  int = 0 
declare @qt_total              int = 0 
select 
	@qt_total = count(cd_mascara_produto)
from #bloqueio

--------------------------------------------------------------------------------------------------------------
set @html_geral = '<div style="text-align: center" class="section-title">
			           <strong> Bloqueio de Produtos para o Comercial </strong>
				   </div>
				   <table>
					   <tr>
					    	<td class="tamanho" style="font-size: 110%;"><strong>Item</strong></td> 
							<td class="tamanho" style="font-size: 110%;"><strong>Cliente</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Nome Cliente<strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Bloqueio</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Usuario</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Produto</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Unidade de Medida</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Multiplo Embalagem</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Dias</strong></td>
					   </tr>'
					   
----------------------------------------------------------------------------------------------------------------

declare @id int = 0
while exists ( select top 1 cd_controle from #bloqueio where cd_controle < 701)
begin
	select top 1
		@id                         = cd_controle,
		@nm_fantasia_cliente        = nm_fantasia_cliente,
		@nm_cliente                 = nm_cliente_grupo, 
		@dt_bloqueio_produto        = Convert(nvarchar(15),dt_bloqueio_produto,103),
		@nm_fantasia_usuario        = nm_fantasia_usuario,
		@nm_produto                 = nm_produto,
		@cd_mascara_produto         = cd_mascara_produto,
		@sg_unidade_medida          = sg_unidade_medida,
		@qt_multiplo_embalagem      = qt_multiplo_embalagem,
		@dias						= dias
	from #bloqueio

  set @html_geral = @html_geral +'<tr>
									<td class="tamanho">'+cast(isnull(@id,0) as nvarchar(10))+'</td>
									<td class="tamanho">'+isnull(@nm_cliente,0)+'</td>
									<td class="tamanho">'+isnull(@nm_fantasia_cliente,0)+'</td>
									<td class="tamanho">'+isnull(@dt_bloqueio_produto, '')+'</td>
									<td class="tamanho">'+isnull(@nm_fantasia_usuario,0)+'</td>
									<td class="tamanho">'+isnull(@nm_produto,'')+' ('+cast(isnull(@cd_mascara_produto,0) as nvarchar(10))+')</td>
									<td class="tamanho">'+isnull(@sg_unidade_medida,0)+'</td>
									<td class="tamanho">'+cast(isnull(@qt_multiplo_embalagem,0) as nvarchar(10))+'</td>
									<td class="tamanho">'+cast(isnull(@dias,'')as nvarchar(10))+'</td>
								  </tr>'
     
	 delete from #bloqueio where cd_controle = @id
 end
--------------------------------------------------------------------------------------------------------------------
declare @html_totais nvarchar(max)=''
declare @titulo_total varchar(500)=''

set @html_rodape =
    '</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
	<div class="section-title">
        <p>Total de Produtos: '+cast(isnull(@qt_total,0) as nvarchar(10))+'</p><br>
    </div>
	'+
	case when isnull(@id,0) >= 699 then 
	'<div>
        <p style="font-size: 25px;text-align: center;margin-top: 3%; color: red;">Para consulta mais detalhada verifique o sistema.</p>
    </div>'
	else '' end 
	+'
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
	@html_totais  + 
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
--exec pr_relatorio_bloqueio_produto_comercial 219,'' 
------------------------------------------------------------------------------

