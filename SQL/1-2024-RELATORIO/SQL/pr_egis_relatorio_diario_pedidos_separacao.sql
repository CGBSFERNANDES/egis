IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_diario_pedidos_separacao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_diario_pedidos_separacao

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_diario_pedidos_separacao
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
create procedure pr_egis_relatorio_diario_pedidos_separacao
@cd_relatorio int   = 0,
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
declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
declare @cd_item_documento      int = 0
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
set @cd_parametro      = 0
set @cd_modulo         = 0
set @cd_empresa        = 0
set @cd_menu           = 0
set @cd_processo       = 0
set @cd_item_processo  = 0
set @cd_form           = 0
set @cd_parametro      = 0
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

set @html_detalhe = '' --valores da tabela


---> CCF <----
---> alteração com o processo do relatório

--Ordem de Separação----------------------------

declare @vl_total decimal(25,2) = 0.00
declare @qt_total int = 0

declare @dt_pedido_venda datetime 


-----Parâmetros do relatório----

--fixar
set @dt_pedido_venda = '03/22/2024'--@dt_hoje

------------------------------------------
select
  pv.cd_cliente,
  pvi.cd_produto,
  max(c.nm_razao_social_cliente)   as nm_razao_social_cliente,
  max(case when c.cd_tipo_pessoa = 1
        then dbo.fn_formata_cnpj(c.cd_cnpj_cliente)
        else dbo.fn_formata_cpf(c.cd_cnpj_cliente)
      end)                         as cd_cpf_cnpj,
  max(p.cd_mascara_produto)        as cd_mascara_produto,
  max(p.nm_produto)                as nm_produto,
  dbo.fn_conversao_produto_unidade_medida(pvi.cd_produto, max(pvi.cd_unidade_medida), sum(pvi.qt_item_pedido_venda), 0)      as qt_peso,
  dbo.fn_conversao_produto_unidade_medida_inv(pvi.cd_produto, max(pvi.cd_unidade_medida), sum(pvi.qt_item_pedido_venda), 0)  as qt_caixa,
  max(pvi.vl_unitario_item_pedido) as vl_unitario_item_pedido,
  max(vl_limite_credito_cliente)   as vl_limite_credito_cliente
into
  #DiarioSep_Pedido
from
  Pedido_Venda pv                                with(nolock)
  inner join Pedido_Venda_Item pvi               with(nolock) on pvi.cd_pedido_venda = pv.cd_pedido_venda
  inner join Cliente c                           with(nolock) on c.cd_cliente        = pv.cd_cliente
  inner join Produto p                           with(nolock) on p.cd_produto        = pvi.cd_produto
  left outer join Cliente_Informacao_Credito cic with(nolock) on cic.cd_cliente      = c.cd_cliente
where
  pv.dt_pedido_venda = @dt_pedido_venda
group by
  pv.cd_cliente,
  pvi.cd_produto
order by  
  pv.cd_cliente,
  pvi.cd_produto

--select * from #DiarioSep_Pedido
--order by
--  cd_cliente

select
  cd_cliente,
  max(nm_razao_social_cliente)   as nm_razao_social_cliente,
  max(cd_cpf_cnpj)               as cd_cpf_cnpj,
  sum(qt_peso)                   as qt_peso_cliente,
  max(vl_limite_credito_cliente) as vl_limite_credito_cliente
into
  #DiarioSep_Pedido_Loop
from
  #DiarioSep_Pedido
group by
  cd_cliente
order by
  cd_cliente

--drop table #DiarioSep_Pedido

select
  pvi.cd_produto,
  max(p.cd_mascara_produto)        as cd_mascara_produto,
  max(p.nm_produto)                as nm_produto,
  dbo.fn_conversao_produto_unidade_medida(pvi.cd_produto, max(pvi.cd_unidade_medida), sum(pvi.qt_item_pedido_venda), 0)      as qt_peso,
  dbo.fn_conversao_produto_unidade_medida_inv(pvi.cd_produto, max(pvi.cd_unidade_medida), sum(pvi.qt_item_pedido_venda), 0)  as qt_caixa
into
  #DiarioSep_PedidoProd
from
  Pedido_Venda pv                                with(nolock)
  inner join Pedido_Venda_Item pvi               with(nolock) on pvi.cd_pedido_venda = pv.cd_pedido_venda
  inner join Cliente c                           with(nolock) on c.cd_cliente        = pv.cd_cliente
  inner join Produto p                           with(nolock) on p.cd_produto        = pvi.cd_produto
where
  pv.dt_pedido_venda = @dt_pedido_venda
group by
  pvi.cd_produto
order by  
  pvi.cd_produto

--select * from #DiarioSep_PedidoProd
--order by
--  cd_produto

--drop table #DiarioSep_PedidoProd

select
  @qt_total = sum(qt_caixa),
  @vl_total = sum(qt_peso)

from
  #DiarioSep_PedidoProd

declare @cd_cliente_loop              int
declare @qt_peso_cliente              float
declare @vl_limite_credito_cliente    float
declare @nm_razao_social_cliente_loop varchar(60)
declare @cd_cpf_cnpj                  varchar(18)
declare @id                          
int = 0

while exists(select top 1 cd_cliente from #DiarioSep_Pedido_Loop)
begin
  select top 1
    @cd_cliente_loop = cd_cliente,
    @nm_razao_social_cliente_loop = nm_razao_social_cliente,
    @cd_cpf_cnpj = cd_cpf_cnpj,
    @qt_peso_cliente = qt_peso_cliente,
    @vl_limite_credito_cliente = vl_limite_credito_cliente
  from
    #DiarioSep_Pedido_Loop

  set @html_cab_det = '<div class="section-title"><strong> '+cast(@cd_cliente_loop as varchar(20))+' '+ +@nm_razao_social_cliente_loop+
                      ' - '+@cd_cpf_cnpj+' Peso Total: '+isnull(dbo.fn_formata_valor(@qt_peso_cliente),'')+
					  ' Limite de Crédito: '+isnull(dbo.fn_formata_valor(@vl_limite_credito_cliente),'')+' </strong></div> 
                       <table>'+
        --               '<tr>
					   --+
					   --isnull(@nm_dados_cab_det,'')
        --               + '</tr>'
           '<tr> 					
            <td style="font-size:12px; text-align:center;width: 20px">Código</td>
			<td style="font-size:12px; text-align:center;width: 20px">Produto</td>
			<td style="font-size:12px; text-align:center;width: 20px">Quantidade</td>	
			<td style="font-size:12px; text-align:center;width: 20px">Preço</td>	
			<td style="font-size:12px; text-align:center;width: 20px">Situação</td>	
            </tr>'

  set @html_detalhe = '' --valores da tabela

  while exists ( select cd_cliente from #DiarioSep_Pedido where cd_cliente = @cd_cliente_loop )
  begin
  
    select top 1
      @id           = cd_cliente,
  	--@nm_pedido    = @nm_pedido  + ' ' + cast(cd_pedido_venda as varchar(15)),
      @html_detalhe = @html_detalhe + '
              <tr> 					
              <td style="font-size:12px; text-align:center;width: 20px">'+isnull(cd_mascara_produto,'')+'</td>
  			<td style="font-size:12px; text-align:center;width: 20px">'+isnull(nm_produto,'')+'</td>
  			<td style="font-size:12px; text-align:center;width: 20px">'+isnull(cast(qt_caixa as varchar(27)),'')+' CX</td>	
  			<td style="font-size:12px; text-align:center;width: 20px">'+isnull(dbo.fn_formata_valor(vl_unitario_item_pedido),'')+'</td>	
  			<td style="font-size:12px; text-align:center;width: 20px">'+' '+'</td>	
              </tr>'
    from
      #DiarioSep_Pedido
    where
      cd_cliente = @cd_cliente_loop
  
    delete from #DiarioSep_Pedido
    where
      cd_cliente = @id
  end

  delete from #DiarioSep_Pedido_Loop
  where cd_cliente = @cd_cliente_loop

SET @html_rod_det = '</table>'

				
 set @html_geral = @html_geral + 
                   @html_cab_det +
                   @html_detalhe +
	               @html_rod_det
end

---------------------------------------------------------------------------------------------------------------------------
----montagem do Detalhe-----------------------------------------------------------------------------------------------
  set @html_detalhe = '' --valores da tabela

  set @html_cab_det = '<div class="section-title"><strong> Totais de Produtos </strong></div> 
                       <table>'+
        --               '<tr>
					   --+
					   --isnull(@nm_dados_cab_det,'')
        --               + '</tr>'
           '<tr> 					
            <td style="font-size:12px; text-align:center;width: 20px">Código</td>
			<td style="font-size:12px; text-align:center;width: 20px">Produto</td>
			<td style="font-size:12px; text-align:center;width: 20px">Quantidade</td>	
			<td style="font-size:12px; text-align:center;width: 20px"> </td>	
			<td style="font-size:12px; text-align:center;width: 20px"> </td>	
            </tr>'

  while exists ( select cd_produto from #DiarioSep_PedidoProd)
  begin
  
    select top 1
      @id           = cd_produto,
      @html_detalhe = @html_detalhe + '
              <tr> 					
              <td style="font-size:12px; text-align:center;width: 20px">'+isnull(cd_mascara_produto,'')+'</td>
  			  <td style="font-size:12px; text-align:center;width: 20px">'+isnull(nm_produto,'')+'</td>
  			  <td style="font-size:12px; text-align:center;width: 20px">'+isnull(cast(qt_caixa as varchar(27)),'')+' CX</td>	
  			  <td style="font-size:12px; text-align:center;width: 20px">'+' '+'</td>	
  			  <td style="font-size:12px; text-align:center;width: 20px">'+' '+'</td>	
              </tr>'
    from
      #DiarioSep_PedidoProd

    delete from #DiarioSep_PedidoProd
    where
      cd_produto = @id
  end

 set @html_geral = @html_geral + 
                   @html_cab_det +
                   @html_detalhe +
	               @html_rod_det
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


SET @html_rod_det = '</table>'

declare @html_totais nvarchar(max)=''
declare @titulo_total varchar(500)=''

set @titulo_total = 'TOTAL'
set @html_totais = '<div class="section-title"><strong>'+@titulo_total+'</strong></div>
                    <div> 
                    <tr>					
					<td style="font-size:12px; text-align:center;width: 80px;">'+cast(@qt_total as varchar(10))+'</td>
			        <td style="font-size:12px; text-align:center;width: 80px;">'+'R$ '+dbo.fn_formata_valor(@vl_total)+'</td>
					</tr>
					</div>'

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
	--@html_cab_det +
 --   @html_detalhe +
	--@html_rod_det +
	@html_geral   +
	@html_totais  + 
    @html_rodape  

---------------------


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
exec pr_egis_relatorio_diario_pedidos_separacao 0,'[
{
    "cd_empresa": "317",
    "cd_modulo": "241",
    "cd_menu": "0",
    "cd_relatorio_form": 20,
    "cd_processo": "",
    "cd_usuario": "4254"
}]'
------------------------------------------------------------------------------


