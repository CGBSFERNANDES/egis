IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_categoria_produto' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_categoria_produto

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
create procedure pr_relatorio_categoria_produto
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
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = ''



--------------------------------------------------------------------------------------------------------

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
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


--------------------------------------------------------------------------------------------------------------------------
select 
  identity(int,1,1)                       as cd_controle,
  cp.cd_categoria_produto                 as cd_categoria_produto,
  cp.cd_mascara_categoria                 as cd_mascara_categoria,
  cp.nm_categoria_produto                 as nm_categoria_produto,
  pat.nm_pauta                            as nm_pauta,
  pat.vl_base_icms_st                     as vl_base_icms_st,
  COUNT(distinct p.cd_produto)            as qt_produto,
  cf.cd_mascara_classificacao             as cd_mascara_classificacao,
  cf.cd_cest_classificacao                as cd_cest_classificacao,
  max(isnull(cf.pc_ipi_classificacao,0))  as pc_ipi_classificacao,
  max(ISNULL(cf.ic_subst_tributaria,'N')) as ic_subst_tributaria,
  max(ISNULL(cf.ic_base_reduzida,'N'))    as ic_base_reduzida,
  t.cd_tributacao                         as cd_tributacao,
  t.nm_tributacao                         as nm_tributacao,
  t.cd_tributacao_icms                    as cd_tributacao_icms,
  ticms.cd_digito_tributacao_icms         as cd_digito_tributacao_icms,
  t.cd_tributacao_ipi                     as cd_tributacao_ipi,
  tipi.cd_digito_tributacao_ipi           as cd_digito_tributacao_ipi,
  t.cd_tributacao_pis                     as cd_tributacao_pis,
  tpis.cd_digito_tributacao_pis           as cd_digito_tributacao_pis,
  t.cd_tributacao_cofins                  as cd_tributacao_cofins,
  tcof.cd_digito_tributacao_cofins        as cd_digito_tributacao_cofins
into
#categoriaProduto
from
  Categoria_Produto cp
  left outer join pauta_calculo_impostos pat on pat.cd_pauta                = cp.cd_pauta
  left outer join Produto p                  on p.cd_categoria_produto      = cp.cd_categoria_produto
  left outer join Produto_Fiscal pf          on pf.cd_produto               = p.cd_produto
  left outer join Classificacao_Fiscal cf    on cf.cd_classificacao_fiscal  = pf.cd_classificacao_fiscal
  left outer join Tipo_Produto tp            on tp.cd_tipo_produto          = pf.cd_tipo_produto
  left outer join Tributacao t               on t.cd_tributacao             = pf.cd_tributacao
  left outer join Tributacao_ICMS ticms      on ticms.cd_tributacao_icms    = t.cd_tributacao_icms
  left outer join Tributacao_IPI tipi        on tipi.cd_tributacao_ipi      = t.cd_tributacao_ipi
  left outer join Tributacao_COFINS tcof     on tcof.cd_tributacao_cofins   = t.cd_tributacao_cofins
  left outer join Tributacao_PIS tpis        on tpis.cd_tributacao_pis      = t.cd_tributacao_pis

where
  p.cd_status_produto = 1
  and
  ISNULL(p.ic_wapnet_produto,'N') = 'S'

group by
  cp.cd_categoria_produto,
  cp.cd_mascara_categoria,
  cp.nm_categoria_produto,
  pat.nm_pauta,
  pat.vl_base_icms_st,
  cf.cd_mascara_classificacao,
  cf.cd_cest_classificacao,
  t.cd_tributacao,
  t.nm_tributacao,
  t.cd_tributacao_icms,
  ticms.cd_digito_tributacao_icms,
  t.cd_tributacao_ipi,
  tipi.cd_digito_tributacao_ipi,
  t.cd_tributacao_pis,
  tpis.cd_digito_tributacao_pis,
  t.cd_tributacao_cofins,
  tcof.cd_digito_tributacao_cofins
 
 --select * from #categoriaProduto

--------------------------------------------------------------------------------------------------------------
declare @cd_categoria_produto		int      = 0
declare @cd_mascara_categoria		nvarchar(15)
declare @nm_categoria_produto		nvarchar(100)
declare @nm_pauta					nvarchar(100)
declare @vl_base_icms_st			float    = 0
declare @qt_produto					float    = 0
declare @cd_mascara_classificacao   nvarchar(20)
declare @cd_cest_classificacao      nvarchar(20)
declare @pc_ipi_classificacao       float    = 0
declare @ic_subst_tributaria        nvarchar(5)
declare @ic_base_reduzida           nvarchar(5)
declare @nm_tributacao              nvarchar(100)
Declare @cst_icms                   int = 0
declare @cst_ipi					int = 0
declare @cst_pis					int = 0
declare @cst_confins				int = 0
Declare @qt_total              int = 0

--------------------------------------------------------------------------------------------------------------
 select 
	@qt_total =	COUNT(cd_controle)
  from 
  #categoriaProduto

--------------------------------------------------------------------------------------------------------------
set @html_geral = '<div style="text-align: center" class="section-title">
			           <strong> Categoria de Produto </strong>
				   </div>
				   <table>
					   <tr>
					    	<td class="tamanho" style="font-size: 110%;"><strong>Item</strong></td> 
							<td class="tamanho" style="font-size: 110%;"><strong>Código</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Categoria<strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Pauta</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Valor Pauta</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Quantidade</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>NCM</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>CEST</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>ST</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Reduzida</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>Tributação</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>CST ICMS</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>CST IPI</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>CST PIS</strong></td>
							<td class="tamanho" style="font-size: 110%;"><strong>CST COFINS</strong></td>
					   </tr>'
					   	

--------------------------------------------------------------------------------------------------------------
declare @id int = 0
while exists ( select top 1 cd_controle from #categoriaProduto where cd_controle <=100)
begin
	select top 1
		@id                         = cd_controle,
		@cd_mascara_categoria		= cd_mascara_categoria,
		@nm_categoria_produto		= nm_categoria_produto,
		@nm_pauta					= nm_pauta,
		@vl_base_icms_st			= vl_base_icms_st,
		@qt_produto					= qt_produto,
		@cd_mascara_classificacao   = cd_mascara_classificacao,
		@cd_cest_classificacao      = cd_cest_classificacao,
		@ic_base_reduzida			= ic_base_reduzida,
		@pc_ipi_classificacao		= pc_ipi_classificacao,
		@ic_subst_tributaria		= ic_subst_tributaria,
		@nm_tributacao				= nm_tributacao,	
		@cst_icms                   = cd_digito_tributacao_icms,
		@cst_ipi                    = cd_digito_tributacao_ipi,
		@cst_pis                    = cd_digito_tributacao_pis,
		@cst_confins                = cd_digito_tributacao_cofins
	from #categoriaProduto
  

  set @html_geral = @html_geral +'<tr>
						<td class="tamanho">'+cast(isnull(@id,0) as nvarchar(10))+'</td>
						<td class="tamanho">'+cast(isnull(@cd_mascara_categoria,0) as nvarchar(10))+'</td>
						<td class="tamanho">'+isnull(@nm_categoria_produto,'')+'</td>
						<td class="tamanho">'+isnull(@nm_pauta,'')+'</td>
						<td class="tamanho">'+cast(isnull(dbo.fn_formata_valor(@vl_base_icms_st),0) as nvarchar(10))+'</td>
						<td class="tamanho">'+cast(isnull(@qt_produto,0) as nvarchar(10))+'</td>
						<td class="tamanho">'+cast(isnull(@cd_mascara_classificacao,'')as nvarchar(12))+'</td>
						<td class="tamanho">'+cast(isnull(@cd_cest_classificacao,0) as nvarchar(10))+'</td>
						<td class="tamanho">'+isnull(@ic_subst_tributaria,0)+'</td>
						<td class="tamanho">'+cast(isnull(@ic_base_reduzida,0) as nvarchar(10))+'</td>
						<td class="tamanho">'+isnull(@nm_tributacao,'')+'</td>
						<td class="tamanho">'+cast(isnull(@cst_icms,0) as nvarchar(10))+'</td>
						<td class="tamanho">'+cast(isnull(@cst_ipi,0) as nvarchar(10))+'%</td>
						<td class="tamanho">'+cast(isnull(@cst_pis,0) as nvarchar(10))+'</td>
						<td class="tamanho">'+cast(isnull(@cst_confins,0) as nvarchar(10))+'</td>
					  </tr>'
     
	 delete from #categoriaProduto where cd_controle = @id
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
		<p><strong>Total:</strong> '+cast(isnull(@qt_total,'') as nvarchar(10))+'</p>
    </div>
	<div>
        <p style="font-size: 25px;text-align: center;margin-top: 3%; color: red;">Para consulta mais detalhada verifique o sistema.</p>
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
exec pr_relatorio_categoria_produto 217,'' 
------------------------------------------------------------------------------

