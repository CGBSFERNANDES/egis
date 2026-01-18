IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_cliente_tabela_preço' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_cliente_tabela_preço

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_cliente_tabela_preço
-------------------------------------------------------------------------------
--pr_relatorio_cliente_tabela_preço
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : João Pedro Marçal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_relatorio_cliente_tabela_preço
@cd_relatorio int   = 0,
@cd_documento int   = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')
declare @data_grafico_bar       nvarchar(max)
declare @cd_empresa             int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
--declare @dt_usuario             datetime = ''
--declare @cd_documento           int = 0
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
--set @cd_documento      = 0
--set @dt_usuario        = GETDATE()
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
  select @cd_documento           = valor from #json where campo = 'cd_grupo_cliente'
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
--@
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
		  padding: 20px;
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
		  font-size: 85%;
		  text-align: center;
		}

		.tamanhotb {
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
  pv.cd_cliente           ,    
  MAX(pv.dt_pedido_venda) as dt_pedido_venda,
  MAX(tp.nm_tabela_preco) as nm_tabela_venda
into
  #venda

from
  Pedido_Venda pv
  left outer join Tabela_Preco tp on tp.cd_tabela_preco = pv.cd_tabela_preco

group by
  pv.cd_cliente


select
  distinct
  identity(int,1,1)                   as cd_controle,
  cg.nm_cliente_grupo                 as nm_cliente_grupo,
  c.cd_cliente                        AS cd_cliente, 
  c.nm_fantasia_cliente               as nm_fantasia_cliente,
  c.nm_razao_social_cliente           as nm_razao_social_cliente,
  c.cd_cnpj_cliente                   as cd_cnpj_cliente,
  sc.nm_status_cliente                as nm_status_cliente,
  tab.nm_tabela_preco                 as nm_tabela_preco,
  e.sg_estado                         as sg_estado,
  cid.nm_cidade                       as nm_cidade,
  cv.nm_criterio_visita               as nm_criterio_visita,
  s.nm_semana                         as nm_semana,
  tp.nm_tipo_pedido                   as nm_tipo_pedido,
  c.dt_cadastro_cliente               as dt_cadastro_cliente,
  ven.dt_pedido_venda                 as dt_pedido_venda,
  ven.nm_tabela_venda                 as nm_tabela_venda

  into 
  #tabelaProduto
from
  cliente c
  left outer join cliente_grupo cg   on cg.cd_cliente_grupo   = c.cd_cliente_grupo
  left outer join vendedor v         on v.cd_vendedor         = c.cd_vendedor
  left outer join cliente_empresa ce on ce.cd_cliente         = c.cd_cliente
  left outer join tabela_preco tab   on tab.cd_tabela_preco   = case when isnull(ce.cd_tabela_preco,0)>0 then ce.cd_tabela_preco else c.cd_tabela_preco end
  left outer join status_cliente sc  on sc.cd_status_cliente  = c.cd_status_cliente
  left outer join criterio_visita cv on cv.cd_criterio_visita = c.cd_criterio_visita
  left outer join semana s           on s.cd_semana           = c.cd_semana
  left outer join tipo_pedido tp     on tp.cd_tipo_pedido     = case when isnull(ce.cd_tipo_pedido,0)>0 then ce.cd_tipo_pedido else c.cd_tipo_pedido    end
  left outer join Estado e           on e.cd_estado           = c.cd_estado
  left outer join Cidade cid         on cid.cd_cidade         = c.cd_cidade
  left outer join #venda ven         on ven.cd_cliente        = c.cd_cliente

  where 
	cg.cd_cliente_grupo = @cd_documento

order by
  ven.dt_pedido_venda desc, c.nm_fantasia_cliente
------------------declara variaveis-------------------------------------------------------------------------------------------
declare @cd_cliente_tb                  int = 0 
declare @dt_pedido_venda_tb          nvarchar(15)
declare @nm_tabela_venda             nvarchar(60)
declare @nm_fantasia_cliente         nvarchar(60)
declare @nm_razao_social_cliente_tb  nvarchar(80)
declare @cd_cnpj_cliente_tb          nvarchar(20)
declare @nm_status_cliente_tb        nvarchar(40)
declare @sg_estado_tb                nvarchar(30)
declare @nm_cidade_tb                nvarchar(60)
declare @nm_semana                   nvarchar(60)
declare @nm_criterio_visita          nvarchar(60)
declare @nm_tipo_pedido              nvarchar(60)
declare @dt_cadastro_cliente         nvarchar(60)
declare @dt_pedido_venda             nvarchar(60)
Declare @nm_cliente_grupo            nvarchar(60)
declare @vl_total_grupo              int = 0 
declare @nm_tabela_preco             nvarchar(60)

select 
	@vl_total_grupo  = count(cd_controle)
from #tabelaProduto

--------------------------------------------------------------------------------------------------------------
set @html_geral = '<div style="text-align: center" class="section-title"> <strong> Clientes x Tabela de Preço </strong> </div>
					  <table>
						<tr>
						  <th class="tamanhotb"><strong>Grupo</strong></th>
						  <th class="tamanhotb"><strong>Nome Cliente</strong></th>
						  <th class="tamanhotb"><strong>Razão Social</strong></th>
						  <th class="tamanhotb"><strong>CNPJ</strong></th>
						  <th class="tamanhotb"><strong>Status</strong></th>
						  <th class="tamanhotb"><strong>Cidade</strong></th>
						  <th class="tamanhotb"><strong>Estado</strong></th>
						  <th class="tamanhotb"><strong>Semana</strong></th>
						  <th class="tamanhotb"><strong>Visita</strong></th>
						  <th class="tamanhotb"><strong>Pedido</strong></th>
						  <th class="tamanhotb"><strong>Data Pedido</strong></th>
						  <th class="tamanhotb"><strong>Cadastro Cliente</strong></th>
						  <th class="tamanhotb"><strong>Tabela Venda</strong></th> 
						  <th class="tamanhotb"><strong>Tabela Preço</strong></th> 
						</tr>'
					   
--------------------------------------------------------------------------------------------------------------

declare @id int = 0
while exists ( select top 1 cd_controle from #tabelaProduto where cd_controle <= 80)
begin
	select top 1
		@id                         = cd_controle,
		@cd_cliente_tb              = cd_cliente,
		@nm_cliente_grupo           = nm_cliente_grupo,
		@nm_fantasia_cliente        = nm_fantasia_cliente,
		@nm_razao_social_cliente_tb = nm_razao_social_cliente,
		@cd_cnpj_cliente_tb         = cd_cnpj_cliente,
		@nm_status_cliente_tb       = nm_status_cliente,
		@sg_estado_tb               = sg_estado,
		@nm_cidade_tb               = nm_cidade,
		@nm_semana                  = nm_semana, 
		@nm_criterio_visita         = nm_criterio_visita,
		@nm_tipo_pedido             = nm_tipo_pedido,
		@dt_cadastro_cliente        = CONVERT(VARCHAR(12),dt_cadastro_cliente,103),
	    @dt_pedido_venda            = CONVERT(VARCHAR(12),dt_pedido_venda,103),
		@nm_tabela_venda            = nm_tabela_venda,
		@nm_tabela_preco            = nm_tabela_preco

	from #tabelaProduto

  set @html_geral = @html_geral +'<tr>
									<td class="tamanho">'+isnull(@nm_cliente_grupo,'')+' </td>
									<td class="tamanho">'+isnull(@nm_fantasia_cliente,'')+' ('+cast(isnull(@cd_cliente_tb,'') as nvarchar(10)) +')</td>
									<td class="tamanho">'+isnull(@nm_razao_social_cliente_tb,'')+'</td>
									<td class="tamanho">'+isnull(@cd_cnpj_cliente_tb,'')+'</td>
									<td class="tamanho">'+isnull(@nm_status_cliente_tb,'')+'</td>
									<td class="tamanho">'+isnull(@nm_cidade_tb,'')+'</td>
									<td class="tamanho">'+isnull(@sg_estado_tb,'')+'</td>
									<td class="tamanho">'+isnull(@nm_semana,'')+'</td>
									<td class="tamanho">'+isnull(@nm_criterio_visita,'')+'</td>
									<td class="tamanho">'+isnull(@nm_tipo_pedido,'')+'</td>
									<td class="tamanho">'+isnull(@dt_pedido_venda,'')+'</td>
									<td class="tamanho">'+isnull(@dt_cadastro_cliente,'')+'</td>
									<td class="tamanho">'+isnull(@nm_tabela_venda,'')+'</td>
									<td class="tamanho">'+isnull(@nm_tabela_preco,'')+'</td>
								  </tr>'
     
	 delete from #tabelaProduto where cd_controle = @id
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
		<p><strong>Total de Clientes:</strong> '+cast(isnull(@vl_total_grupo,'') as nvarchar(10))+'</p>
    </div>'+
	   Case when @vl_total_grupo >=81 then
	'<div>
        <p style="font-size: 25px;text-align: center;margin-top: 3%; color: red;">Para consulta mais detalhada verifique o sistema.</p>
    </div>'
	else ''
	end +
    '<p>'+@ds_relatorio+'</p>
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
--exec pr_relatorio_cliente_tabela_preço 227,0,'' 
------------------------------------------------------------------------------

