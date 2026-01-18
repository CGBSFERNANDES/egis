IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_solicitacao_beneficiamento' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_solicitacao_beneficiamento

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_solicitacao_beneficiamento
-------------------------------------------------------------------------------
--pr_egis_relatorio_solicitacao_beneficiamento
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : João Pedro Marcal
--
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 24.08.2024
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_solicitacao_beneficiamento
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
 --@dt_inicial, @dt_final , @cd_status , @cd_tecnico , @cd_tipo_defeito , @cd_marca_produto
-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
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
-------------------------------------------------------------------------------------------------

 --select @cd_relatorio

select
  top 1
  @titulo      = nm_relatorio,
  @ic_processo = isnull(ic_processo_relatorio, 'N')
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio

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
		@nm_cor_empresa             = case when isnull(e.nm_cor_empresa,'')<>'' then isnull(e.nm_cor_empresa,'#1976D2') else '#1976D2' end,
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
	left outer join Pais p			with(nolock) on p.cd_pais    = e.cd_pais
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
        <table>
            <tr>
                <td style="width: 20%; text-align: center;">
			       <img src="'+@logo+'" alt="Logo da Empresa">
			    </td>
				<td style="width: 60%; text-align: left;">
					<p class="title">'+@nm_fantasia_empresa+'</p>
					<p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
					<p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
					<p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
			</td>
				'

--select @html_empresa


--Detalhe--
--Procedure de Cada Relatório-------------------------------------------------------------------------------------

select
  a.*, 
  g.nm_grupo_relatorio 
into
  #RelAtributo 
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

--------------------------------------------------------------------------------------------------------------------------
   --Capa ( Pedido de Compra )
  select
    IDENTITY(int,1,1)          as cd_controle,
    sb.*,
    nm_fantasia_fornecedor     as Fornecedor,
    tb.nm_tipo_beneficiamento  as nm_tipo_beneficiamento,
	--us.nm_usuario              as nm_usuario,
	td.nm_tipo_destinatario    as nm_tipo_destinatario,
	d.nm_fantasia_destinatario as nm_fantasia_destinatario,
	t.nm_transportadora        as nm_transportadora

	Into
	#SolicitacaoCapa

  from
   solicitacao_beneficiamento sb
   left outer join fornecedor f             on f.cd_fornecedor = sb.cd_destinatario
   left outer join Tipo_Beneficiamento tb   on tb.cd_tipo_beneficiamento = sb.cd_tipo_beneficiamento
   left outer join egisadmin.dbo.usuario us on us.cd_usuario = sb.cd_usuario
   left outer join Tipo_Destinatario td     on td.cd_tipo_destinatario = sb.cd_tipo_destinatario
   left outer join destinatario d           on d.cd_destinatario = sb.cd_destinatario
   left outer join transportadora t         on t.cd_transportadora = sb.cd_transportadora

  where
    sb.cd_solicitacao = @cd_documento

------------------------------------------------------------------------------------
    --Detalhe 1 --> Produtos ( Pedido de Compra )
  select
      IDENTITY(int,1,1)          as cd_controle,
      i.*,
      p.nm_fantasia_produto,
      p.nm_produto,
      um.sg_unidade_medida

	  into
	  #ProdutoItens

    from
      solicitacao_beneficiamento_composicao i
      inner join produto p              on p.cd_produto = i.cd_produto 
      left outer join unidade_medida um on um.cd_unidade_medida = p.cd_unidade_medida

    where
      i.cd_solicitacao = @cd_documento
      and
      i.cd_tipo_composicao = 2 --> Produto
	   
    --Detalhe 2--> Matéria_prima Aplicada ( Nota Fiscal de Remessa )
------------------------------------------------------------------------------------
    select
	  IDENTITY(int,1,1)          as cd_controle,
      i.*,
      p.nm_fantasia_produto,
      p.nm_produto,
      um.sg_unidade_medida

	  into
	  #MateriaPrimaAplicada

    from
      solicitacao_beneficiamento_composicao i
      inner join produto p              on p.cd_produto = i.cd_produto 
      left outer join unidade_medida um on um.cd_unidade_medida = p.cd_unidade_medida

    where
      i.cd_solicitacao = @cd_documento
      and
      i.cd_tipo_composicao = 1 --> Produto

	   
-------------------------------------------------------------------------------------------------------------- --
declare 
	@dt_solicitacao           datetime = '',
	@nm_requisitante          varchar(100),
	@cd_requisicao_compra     int = 0,
	@cd_pedido_compra         int = 0,
	@cd_tipo_destinatario     int = 0, 
	@nm_tipo_destinatario     varchar(60),
	@Fornecedor               varchar(100),
	@cd_destinatario          int = 0,
	@ds_solicitacao		      varchar(300),
	@nm_transportadora        varchar(100),
	@cd_transportadora        int = 0,
	@cd_nota_saida            int = 0,
	@nm_fantasia_destinatario varchar(100),
	@nm_tipo_beneficiamento   varchar(100)

 
select 

	@dt_solicitacao           = dt_solicitacao,
	@nm_requisitante          = fornecedor,
	@cd_requisicao_compra     = cd_requisicao_compra,
	@cd_pedido_compra         = cd_pedido_compra,
	@cd_tipo_destinatario     = cd_tipo_destinatario,
	@nm_tipo_destinatario     = nm_tipo_destinatario,
	@Fornecedor               = Fornecedor,
	@cd_destinatario          = cd_destinatario,
	@ds_solicitacao           = ds_solicitacao,
	@nm_transportadora 		  = nm_transportadora, 
	@cd_transportadora        = cd_transportadora,
	@cd_nota_saida            = cd_nota_saida,
	@nm_fantasia_destinatario = nm_fantasia_destinatario,
	@nm_tipo_beneficiamento   = nm_tipo_beneficiamento

from #SolicitacaoCapa

--------------------------------------------------------------------------------------------------------------
set @html_geral = '<td style="width: 20%; text-align: center;">
						<p><strong>Requisição de Beneficiamento: '+cast(isnull(@cd_documento,0) as nvarchar(20))+'</strong></p>
						<p><strong>Data Beneficiamento:</strong> '+isnull(dbo.fn_data_string(@dt_solicitacao),'')+'</p>
					</td>
				</tr>
			</table>       
			<p class="section-title" style=" text-align: center;">Solicitação de Beneficiamento</p> 
			<table>
            <tr style=" text-align: center;">
                <td><strong>Requisitante: </strong>'+isnull(@nm_requisitante,'')+'</td>
                <td><strong>Requisição de Compra: </strong>'+cast(isnull(@cd_requisicao_compra,0) as varchar(20))+'</td>
                <td><strong>Pedido de Compra: </strong>'+cast(isnull(@cd_pedido_compra,0) as varchar(20))+'</td>
            </tr>
        </table>
        <table>
            <tr>
                <th>Tipo Destinatário</th>
                <td>('+cast(isnull(@cd_tipo_destinatario,0) as nvarchar(20))+') '+isnull(@nm_tipo_destinatario,'')+'</td>
                <th>Beneficiamento</th>
                <td> '+isnull(@nm_tipo_beneficiamento,'')+'</td>
            </tr>
            <tr>
                <th>Transportadora</th>
                <td> ('+cast(isnull(@cd_transportadora,0) as nvarchar(20))+') '+isnull(@nm_transportadora,'')+'</td>
                <th>Nota Saída</th>
                <td>'+cast(isnull(@cd_nota_saida,0) as nvarchar(20))+'</td>
            </tr>
           
        </table>
		<p class="section-title" style=" text-align: left;">Matéria Prima Aplicada ( Nota Fiscal de Remessa )</p>
        <table>
            <tr>
                <th>Item</th>
				<th>Código</th>
				<th>Fantasia</th>
				<th>Descrição</th>
				<th>Un.</th>
                <th>Qtd.</th>
				<th>Custo</th>
                <th>Peso Liquído</th>
                <th>Peso Bruto</th>
                <th>Valor Total</th>         
            </tr>'			   	

--------------------------------------------------------------------------------------------------------------
declare @id int = 0

while exists ( select top 1 cd_controle from #MateriaPrimaAplicada)
begin

	select top 1
		@id                         = cd_controle,

		@html_geral = @html_geral +'
            <tr style="text-align: center;">
                <td>'+cast(isnull(cd_controle,0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(cd_produto,0) as nvarchar(20))+'</td>
				<td style="text-align: left;">'+isnull(nm_fantasia_produto,'')+'</td>
				<td style="text-align: left;">'+isnull(nm_produto,'')+'</td>
				<td>'+isnull(sg_unidade_medida,'')+'</td>
                <td>'+cast(isnull(qt_produto,0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(dbo.fn_formata_valor(vl_custo_produto),0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(qt_peso_liquido,0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(qt_peso_bruto,0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(vl_total_produto),0) as nvarchar(20))+'</td>
            </tr>'
     from #MateriaPrimaAplicada
	 delete from #MateriaPrimaAplicada where cd_controle = @id
 end
 
--------------------------------------------------------------------------------------------------------------------
declare @html_totais nvarchar(max)=''
declare @titulo_total varchar(500)=''

set @html_rodape =
           '</table>
		  <p class="section-title" style=" text-align: left;">Produtos ( Pedido de Compra )</p>
           <table>
            <tr>
                <th>Item</th>
				<th>Código</th>
				<th>Fantasia</th>
				<th>Descrição</th>
				<th>Un.</th>
                <th>Qtd.</th>
				<th>Custo</th>
                <th>Peso Liquído</th>
                <th>Peso Bruto</th>
                <th>Valor Total</th>         
            </tr>'

			
while exists ( select top 1 cd_controle from #ProdutoItens)
begin

	select top 1
		@id                         = cd_controle,

		@html_rodape = @html_rodape +'
            <tr style="text-align: center;">
                <td>'+cast(isnull(cd_controle,0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(cd_produto,0) as nvarchar(20))+'</td>
				<td style="text-align: left;">'+isnull(nm_fantasia_produto,'')+'</td>
				<td style="text-align: left;">'+isnull(nm_produto,'')+'</td>
				<td>'+isnull(sg_unidade_medida,'')+'</td>
                <td>'+cast(isnull(qt_produto,0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(dbo.fn_formata_valor(vl_custo_produto),0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(qt_peso_liquido,0) as nvarchar(20))+'</td>
				<td>'+cast(isnull(qt_peso_bruto,0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(vl_total_produto),0) as nvarchar(20))+'</td>
            </tr>'
     from #ProdutoItens
	 delete from #ProdutoItens where cd_controle = @id
 end
 
  set @html_rodape =  @html_rodape +
						' 
						</table>
						<div>
                        <p style="text-align: Left;"> 
                            <strong>Observação:</strong> '+isnull(@ds_solicitacao,'')+'
                        </p>
                        <p style="text-align: right;"> 
                            <strong>Impressão:</strong> '+@data_hora_atual+'
                        </p>
                    </div>
   </body>

</html>'



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
--exec pr_egis_relatorio_solicitacao_beneficiamento 249,'' 
------------------------------------------------------------------------------

