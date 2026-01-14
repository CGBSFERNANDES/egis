IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_contrato_comodato_pimpinela' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_contrato_comodato_pimpinela

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_contrato_comodato_teste
-------------------------------------------------------------------------------
--pr_egis_relatorio_contrato_comodato_teste
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
--Alteração        : 23.12.2024 - Ajustado o parametro de documento. Kelvin Viana
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_contrato_comodato_pimpinela
@cd_relatorio int   = 0,
@cd_usuario   int   = 0, 
@cd_parametro int   = 0,
@json nvarchar(max) = '' 
--with encryption
--use egissql_317

as

set @json = isnull(@json,'')

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
declare @cd_empresa             int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @cd_grupo_relatorio     int
declare @cd_controle            int



--declare @cd_relatorio           int = 0

--Dados do Relatório---------------------------------------------------------------------------------

     declare
			@ano_nota					varchar(15),
			@num_nota                   varchar(20),
		    @razaosocial_cliente        varchar(200),
			@razaosocial_cliente_rodape varchar(100),
			@dt_mes_ano					varchar(30),
			@valor_produto				varchar(50),
			@cep_cliente				varchar(20),
			@uf_cliente					varchar(5),
			@cidade_cliente				varchar(200),
			@bairro_cliente				varchar(200),
			@cnpj_cliente				varchar(30),	
	        @ender_cliente				varchar(200),
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
set @cd_documento      = 0
set @cd_item_documento = 0
set @dt_usuario        = GETDATE()
------------------------------------------------------------------------------------------------------
--Para quando é chamado na Web ele verifica a tabela de parametro_relatorio, nos casos do app é tudo enviado via json.
--select @cd_form = valor from #json where campo = 'cd_form'         

------------------------------------------------------------------------------------------

if @json <> ''
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

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_modulo              = valor from #json where campo = 'cd_modulo'             
  select @cd_processo            = valor from #json where campo = 'cd_processo' 
  select @cd_form                = valor from #json where campo = 'cd_form' 
  select @cd_item_processo       = valor from #json where campo = 'cd_item_processo'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'

   if isnull(@cd_documento,0) = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_identificacao_nota_saida'
     select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'

   end
   --Tenta pela variavel cd_documento - Aplicativo (Não retirar)
   if isnull(@cd_documento,0) = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'
     --select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'

   end
   --Tenta pela variavel cd_documento_form - Aplicativo (Não retirar)
   if isnull(@cd_documento,0) = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento_form'
     --select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'

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

if @cd_form = 34
begin
select
  @dt_inicial     = dt_inicial,
  @dt_final       = dt_final,
  @cd_vendedor    = isnull(cd_vendedor,0),
  @cd_cliente     = isnull(cd_cliente,0),
  @cd_tipo_pedido = 0,--cd_tipo_pedido
  @cd_documento   = isnull(cd_identificacao_nota_saida,0)
from 
  Parametro_Relatorio

where
  cd_relatorio = @cd_relatorio
  and
  cd_usuario   = @cd_usuario
end

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
------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------
--Título do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio


--select @titulo
--

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


    .titulo {
      align-items: center;
      justify-content: center;
    }

    .textocorpo {
      text-align: justify;
      align-items: center;
      margin: 5px 50px;
      padding: auto;
    }
    .assinaturas-bloco {
      width: 100%;
      max-width: 800px;
      margin: 0 auto;
      margin-top: 20px;
      text-align: center;
      page-break-inside: avoid;
    }

    .assinatura-table {
      width: 100%;
      margin-bottom: 30px;
      border: none;
      border-collapse: collapse;
    }

    .assinatura-table td {
      padding: 10px;
      text-align: left;
      border: none;
      font-size: 14px;
    }

    .testemunhas-titulo {
      font-weight: bold;
      margin-bottom: 10px;
      text-align: center;
      font-size: 16px;
    }

    @media print {
      .assinaturas-bloco {
        width: 100%;
        max-width: 180mm;
        margin-left: auto;
        margin-right: auto;
        page-break-inside: avoid;
        margin-top: 20px;
      }

      .assinatura-table {
        width: 100%;
        margin: 0 auto 30px auto;
        border-collapse: collapse;
      }

      .assinatura-table_s {
        margin-right: 15px;
        border: none;
        margin: 0 auto 30px auto;
      }

      .assinatura-table td {
        border: none;
        padding: 10px;
        font-size: 12pt;
        text-align: left;
      }

      .testemunhas-titulo {
        font-size: 14pt;
        text-align: center;
        margin: 10px 0;
      }

      .section-title {
        page-break-inside: avoid;
      }
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

--select @nm_dados_cab_det

--select * from #RelAtributo

--Chamada dos Parametros do Relatório---

--declare @cd_tipo_pedido int

  --select @cd_relatorio, @cd_usuario

--select
--*
--from 
--  Parametro_Relatorio

--where
--  cd_relatorio = @cd_relatorio
--  and
--  cd_usuario   = @cd_usuario


---> CCF <----
---> alteração com o processo do relatório

declare @vl_total          decimal(25,2) = 0.00
declare @qt_total          int = 0
declare @vl_total_vendedor decimal(25,2) = 0.00
declare @qt_total_vendedor int = 0
--declare @cd_ano            int = 0



--------------------------------------------------------------------------------
 select            
    ns.cd_identificacao_nota_saida as NUM_NOTA,        
    ns.cd_identificacao_nota_saida as IDENT_NOTA,        
    ns.nm_fantasia_nota_saida      as FANTASIA_CLIENTE,        
    ltrim(rtrim(ns.nm_razao_social_nota))+
	' ('+cast(ns.cd_cliente as varchar(9)) +') - ' +  ns.nm_fantasia_nota_saida +', '
	                               as RAZAOSOCIAL_CLIENTE,        
	  case when c.cd_tipo_pessoa  = 1
	   then dbo.fn_formata_cnpj(ns.cd_cnpj_nota_saida)     
     else dbo.fn_formata_cpf(ns.cd_cnpj_nota_saida)
	  end                            as CNPJ_CLIENTE,
	  case when c.cd_tipo_pessoa  = 1
	   then dbo.fn_formata_cnpj(ns.cd_cnpj_nota_saida)     
     else dbo.fn_formata_cpf(ns.cd_cnpj_nota_saida)
	  end                            as CNPJ_CLIENTE1,        
    ns.cd_inscest_nota_saida       as IE_CLIENTE,        
    ns.cd_ddd_nota_saida,        
    ns.cd_telefone_nota_saida,        
    ns.sg_estado_nota_saida        as UF_CLIENTE,        
    ns.sg_estado_nota_saida        as UF_CLIENTE1,        
    isnull(ns.nm_cidade_nota_saida,'')         as CIDADE_CLIENTE,        
    isnull(ns.nm_cidade_nota_saida,'')         as CIDADE_CLIENTE1,        
        
    ns.nm_bairro_nota_saida         as BAIRRO_CLIENTE,        
        
    ltrim(rtrim(isnull(ns.nm_endereco_nota_saida,'')))+', '+ltrim(rtrim(isnull(ns.cd_numero_end_nota_saida,''))) as ENDER_CLIENTE,        
        
   -- ns.nm_endereco_nota_saida       as ENDER_CLIENTE,        
    ns.cd_numero_end_nota_saida     as NUM_END_CLIENTE,        
    year(ns.dt_nota_saida) + 5      as VALIDADE_CONT,        
        
 cast(Day(ns.dt_nota_saida) as varchar(10)) + ' de ' + Case  when MONTH(ns.dt_nota_saida) = 1  then 'Janeiro'        
         when MONTH(ns.dt_nota_saida) = 2  then 'Fevereiro'        
                                                             when MONTH(ns.dt_nota_saida) = 3  then 'Março'         
                                             when MONTH(ns.dt_nota_saida) = 4  then 'Abril'        
                                                          when MONTH(ns.dt_nota_saida) = 5  then 'Maio'         
                                                                when MONTH(ns.dt_nota_saida) = 6  then 'Junho'        
                                                          when MONTH(ns.dt_nota_saida) = 7  then 'Julho'        
                                                          when MONTH(ns.dt_nota_saida) = 8  then 'Agosto'        
                                                          when MONTH(ns.dt_nota_saida) = 9  then 'Setembro'         
                                                                when MONTH(ns.dt_nota_saida) = 10 then 'Outubro'        
                                                          when MONTH(ns.dt_nota_saida) = 11 then 'Novembro'         
                                                          else 'Dezembro'        
                                                       end + ' de ' +cast(Year(ns.dt_nota_saida) as varchar(10))    as DT_MES_ANO,    
    cast(Year(ns.dt_nota_saida) as varchar(10)) as ANO_NOTA,    
    ns.cd_cep_nota_saida            as CEP_CLIENTE,        
    cast('' as varchar)             as COMPL_ENDER_CLIENTE,        
        
    nsi.cd_item_nota_saida,        
    nsi.qt_item_nota_saida          as QTDE_NOTA,        
    cp.nm_categoria_produto         as CATEGORIA_PRODUTO,        
    nsi.cd_mascara_produto          as COD_PRODUTO,   
	--case when isnull(ba.cd_bem,0)>0 then
	--   isnull(ba.nm_bem,'')
	--else
    isnull(nsi.nm_produto_item_nota,'')
    --end
	--Dados do Bem--
	+
	' ('+cast(ISNULL(ba.qt_voltagem_bem,'') as varchar(10))+' V )'
	+
	case when isnull(ba.nm_registro_bem,'')<>'' 
	then
	  ' REGISTRO: '+ISNULL(ba.nm_registro_bem,'')
    else
	  cast('' as varchar(1))
    end
	as DESCRICAO_PRODUTO,

	--SELECT * FROM BEM WHERE cd_patrimonio_bem='1503'
	
	
   isnull(nsi.nm_produto_item_nota,'') +
	' ('+cast(ba.qt_voltagem_bem as varchar(10))+' V )'
	+
	case when isnull(ba.nm_registro_bem,'')<>'' 
	then
	  ' REGISTRO: '+ba.nm_registro_bem
    else
	  cast('' as varchar(1))
    end as DESC_PRODUTO,        
    b.nm_modelo_bem                 as MODELO_PRODUTO,        
    b.nm_marca_bem                  as MARCA_PRODUTO,        
    b.qt_voltagem_bem               as VOLTAGEM_PRODUTO,        
    b.qt_capacidade_bem             as CAPACIDADE_PRODUTO,      
	ns.cd_nota_saida                as nota_saida,
        
    ltrim(rtrim(cast(isnull(p.nm_produto_complemento,'') as varchar)))   as COMPLEMENTO_PRODUTO,        
        
    nsi.cd_item_nota_saida                                                                          as ITEM_NOTA,        
        
    dbo.fn_formata_valor(nsi.vl_total_item)                                                         as VALOR_PRODUTO,        
        
           
    cast(case when nsi.cd_item_nota_saida=2 then nsi.cd_item_nota_saida   else '' end as varchar)   as ITEM_NOTA1,        
--    cast(case when nsi.cd_item_nota_saida=2 then nsi.qt_item_nota_saida   else '' end as varchar)   as QTDE_NOTA1,        
    cast(case when nsi.cd_item_nota_saida=2 then nsi.qt_item_nota_saida   else '' end as varchar)   as QTDE_NOTA1,        
    cast(case when nsi.cd_item_nota_saida=2 then cp.nm_categoria_produto  else '' end as varchar)   as CATEGORIA_PRODUTO1,        
    cast(case when nsi.cd_item_nota_saida=2 then nsi.cd_mascara_produto   else '' end as varchar)   as COD_PRODUTO1,        
    cast(case when nsi.cd_item_nota_saida=2 then nsi.nm_produto_item_nota else '' end as varchar)   as DESCRICAO_PRODUTO1,        
    cast(case when nsi.cd_item_nota_saida=2 then dbo.fn_formata_valor(nsi.vl_total_item)        
                                                                          else '' end as varchar)   as VALOR_PRODUTO1,        
    cast(case when nsi.cd_item_nota_saida=2 then p.nm_modelo_produto      else '' end as varchar)   as MODELO_PRODUTO1,        
 cast(case when nsi.cd_item_nota_saida=2 then p.nm_marca_produto       else '' end as varchar)   as MARCA_PRODUTO1,        
 cast(case when nsi.cd_item_nota_saida=2 then b.qt_voltagem_bem        else '' end as varchar)   as VOLTAGEM_PRODUTO1,        
 cast(case when nsi.cd_item_nota_saida=2 then b.qt_capacidade_bem      else '' end as varchar)   as CAPACIDADE_PRODUTO1,        
        
        
    cast(case when nsi.cd_item_nota_saida=2 then ltrim(rtrim(cast(isnull(p.nm_produto_complemento,'') as varchar))) else '' end as varchar)  as COMPLEMENTO_PRODUTO1,        
            
    cast(case when nsi.cd_item_nota_saida=2 then nsi.cd_item_nota_saida   else '' end as varchar)   as ITEM_NOTA2,        
    cast(case when nsi.cd_item_nota_saida=3 then nsi.qt_item_nota_saida   else '' end as varchar)   as QTDE_NOTA2,        
  cast(case when nsi.cd_item_nota_saida=3 then cp.nm_categoria_produto  else '' end as varchar)   as CATEGORIA_PRODUTO2,        
    cast(case when nsi.cd_item_nota_saida=3 then nsi.cd_mascara_produto   else '' end as varchar)   as COD_PRODUTO2,        
    cast(case when nsi.cd_item_nota_saida=3 then nsi.nm_produto_item_nota else '' end as varchar)   as DESCRICAO_PRODUTO2,        
    cast(case when nsi.cd_item_nota_saida=3 then ltrim(rtrim(cast(isnull(p.nm_produto_complemento,'') as varchar))) else '' end as varchar)  as COMPLEMENTO_PRODUTO2,        
    cast(case when nsi.cd_item_nota_saida=3 then dbo.fn_formata_valor(nsi.vl_total_item)        
                                                                          else '' end as varchar)   as VALOR_PRODUTO2,        
 cast(case when nsi.cd_item_nota_saida=3 then p.nm_modelo_produto      else '' end as varchar)   as MODELO_PRODUTO2,        
 cast(case when nsi.cd_item_nota_saida=3 then p.nm_marca_produto       else '' end as varchar)   as MARCA_PRODUTO2,        
 cast(case when nsi.cd_item_nota_saida=3 then b.qt_voltagem_bem        else '' end as varchar)   as VOLTAGEM_PRODUTO2,        
 cast(case when nsi.cd_item_nota_saida=3 then b.qt_capacidade_bem      else '' end as varchar)   as CAPACIDADE_PRODUTO2,        
        
           
    ns.dt_nota_saida                as DATA_NOTA,        
    ns.nm_razao_social_nota         as RAZAOSOCIAL_CLIENTE_RODAPE,        
    emp.nm_caminho_logo_empresa     as 'LOGOTIPO',        
    'COMODATO_' +dbo.fn_strzero(ns.cd_identificacao_nota_saida,7)+'.doc'       as nm_arquivo_documento       
        
            
        
 into        
   #Nota        
         
 from        
   nota_saida ns                             with(nolock) 
   inner join nota_saida_item nsi            with(nolock) on nsi.cd_nota_saida        = ns.cd_nota_saida        
   left outer join produto p                 with(nolock) on p.cd_produto             = nsi.cd_produto        
   left outer join categoria_produto cp      with(nolock) on cp.cd_categoria_produto  = p.cd_categoria_produto        
   left outer join Solicitacao_Ativo sa      with(nolock) on sa.cd_pedido_venda       = nsi.cd_pedido_venda and sa.cd_item_pedido_venda = nsi.cd_item_pedido_venda                                 
   left outer join Bem ba                    with(nolock) on ba.cd_bem                = sa.cd_bem
   left outer join Bem b                     with(nolock) on b.cd_produto             = nsi.cd_produto        
   left outer join egisadmin.dbo.empresa emp with(nolock) on emp.cd_empresa           = @cd_empresa --dbo.fn_empresa() 
   left outer join Cliente c                 with(nolock) on c.cd_cliente             = ns.cd_cliente     

 where        
   ns.cd_nota_saida = @cd_documento --150008 
 --select * from #nota
select * into #auxnota   from #nota        
select * into #auxnota2  from #nota        
-------------------------------------------------------------------------------------------------------------------------

 update        
   #nota        
 set        
     ITEM_NOTA1           = isnull(( select ITEM_NOTA1           from #auxnota where cd_item_nota_saida = 2),''),        
     QTDE_NOTA1           = isnull(( select QTDE_NOTA1           from #auxnota where cd_item_nota_saida = 2),''),        
     CATEGORIA_PRODUTO1   = isnull(( select CATEGORIA_PRODUTO1   from #auxnota where cd_item_nota_saida = 2),''),        
     COD_PRODUTO1         = isnull(( select COD_PRODUTO1         from #auxnota where cd_item_nota_saida = 2),''),        
     DESCRICAO_PRODUTO1   = isnull(( select DESCRICAO_PRODUTO1   from #auxnota where cd_item_nota_saida = 2),''),        
     COMPLEMENTO_PRODUTO1 = isnull(( select COMPLEMENTO_PRODUTO1 from #auxnota where cd_item_nota_saida = 2),''),        
     VALOR_PRODUTO1       = isnull(( select VALOR_PRODUTO1       from #auxnota where cd_item_nota_saida = 2),'')        
        
 from        
   #nota n        
           
 where        
   cd_item_nota_saida = 1       
   
   
        
 update        
   #nota        
 set        
     ITEM_NOTA2           = isnull(( select ITEM_NOTA2           from #auxnota where cd_item_nota_saida = 3),''),        
     QTDE_NOTA2           = isnull(( select QTDE_NOTA2           from #auxnota where cd_item_nota_saida = 3),''),        
     CATEGORIA_PRODUTO2   = isnull(( select CATEGORIA_PRODUTO2   from #auxnota where cd_item_nota_saida = 3),''),        
     COD_PRODUTO2         = isnull(( select COD_PRODUTO2         from #auxnota where cd_item_nota_saida = 3),''),        
     DESCRICAO_PRODUTO2   = isnull(( select DESCRICAO_PRODUTO2   from #auxnota where cd_item_nota_saida = 3),''),        
     COMPLEMENTO_PRODUTO2 = isnull(( select COMPLEMENTO_PRODUTO2 from #auxnota where cd_item_nota_saida = 3),''),        
     VALOR_PRODUTO2       = isnull(( select VALOR_PRODUTO2       from #auxnota where cd_item_nota_saida = 3),'')        
        
 from        
   #nota n        
           
 where        
   cd_item_nota_saida = 1        

 
-----------------------------------------------------------------------------------------------------------        
 --select top 1 * from #Nota       
 --order by cd_item_nota_saida  
 declare @ie_cliente    varchar(100)
 declare @cnpj_cliente1 VARCHAR(20)
 declare @item_nota     varchar(50)
 declare @uf_cliente1   varchar(20)
 declare @ds_produto    varchar(150)
 declare @nota_saida    varchar(15) 

 select 
			  @ds_produto                 = DESCRICAO_PRODUTO, 
              @valor_produto              = VALOR_PRODUTO,
			  @bairro_cliente             = BAIRRO_CLIENTE,
			  @razaosocial_cliente        = RAZAOSOCIAL_CLIENTE,
			  @cnpj_cliente               = CNPJ_CLIENTE,
			  @ender_cliente              = ENDER_CLIENTE,
			  @cidade_cliente             = CIDADE_CLIENTE,
			  @uf_cliente                 = UF_CLIENTE,
			  @cep_cliente                = CEP_CLIENTE,
			  @razaosocial_cliente_rodape = RAZAOSOCIAL_CLIENTE_RODAPE,
			  @dt_mes_ano                 =  DT_MES_ANO,
			  @num_nota                   = NUM_NOTA,
			  @ano_nota                   = ANO_NOTA,
			  @ie_cliente                 = IE_CLIENTE,
			  @cnpj_cliente1              = CNPJ_CLIENTE1,
			  @item_nota                  = ITEM_NOTA,
			  @uf_cliente1                = uf_cliente1,
			  @nota_saida                 = nota_saida

 from #Nota
 
 set @nota_saida = @cd_documento

-----------------------------------------------------------------------------------------------------------


if @cd_parametro<> 3
begin

-------------------------------------------montagem do Detalhe---------------------------------------------------------------

declare @id int = 0

set @html_detalhe = ' <div class="textocorpo">
    <div class="section-title"><strong style="display: flex; justify-content:center; align-items:center;">INSTRUMENTO
        PARTICULAR DE CONTRATO DE COMODATO DE BEM MÓVEL E OUTRAS AVENÇAS Nº '+isnull(@nota_saida,0)+' / '+isnull(@ano_nota,0)+'</strong></div>
    <div>
      <p>Pelo presente instrumento particular, de um lado ALESSANDRO JOSÉ ZAMPRONIO LTDA, pessoa jurídica de direito privado, com sede na cidade e comarca de Sertãozinho, na Avenida Marginal Antônio Aragão, 1.587  - Zona Industrial, CNPJ n.º 62.182.753/0001-12, que gira sob o nome de fantasia SORVETES PIMPINELLA, neste ato denominada simplesmente COMODANTE,'+isnull(@razaosocial_cliente,'')+' inscrito no CNPJ: '+isnull(@cnpj_cliente,'') +' IE: '+isnull(@ie_cliente,'')+' com sede na '+isnull(@ender_cliente,'')+' – Bairro: '+isnull(@bairro_cliente,'')+' – Município : '+isnull(@cidade_cliente,'')+' – '+isnull(@uf_cliente,'') +' CEP: '+isnull(@cep_cliente,0)+' doravante designado COMODATÁRIO, resolvem entre si, ajustar o presente instrumento particular, que se rege pelas condições a seguir elencadas:</p>
      <p><strong>Cláusula Primeira -</strong> O COMODANTE é senhor e legítimo proprietário do (s) aparelho (s) refrigerador (es) abaixo identificado (s): </p>
      <p> a) '+isnull(@item_nota,0)+' – '+isnull(@ds_produto,'')+' </p>
      <p><strong>Cláusula Segunda -</strong> O COMODANTE cede ao COMODATÁRIO o (s) bem (ns) móvel (is) acima descrito (s), pelo prazo de comercialização dos produtos “Pimpinella” e que ambas as partes estejam de acordo, para o fim específico e exclusivo de conservar, expor e comercializar produtos "Pimpinella"; </p>
      <p> Parágrafo Primeiro – Que o(s) equipamento(s) se encontra(m) em estado de novo(s).</p>
      <p> Parágrafo Segundo – Para os efeitos deste contrato, atribui-se ao(s) bem (ns), o valor de R$ '+isnull(@valor_produto,'')+' cada um. </p>
    
      <p><strong>CLÁUSULA TERCEIRA – A COMODANTE</strong>Durante o prazo do empréstimo, fica o COMODATÁRIO obrigado a adquirir para comercializar, os produtos "Pimpinella" e usar o logotipo da empresa estampado no(s) refrigerador (es) objeto do presente.</p>
      <p>Parágrafo único – Fica vedado ao COMODATÁRIO utilizar o(s) aparelho(s) cedido(s) para armazenar produtos de quaisquer outras marcas que não a marca “Pimpinella”, sob pena de rescisão contratual e demais consectários previstos neste contrato.</p>
    
    <p><strong>CLÁUSULA QUARTA – </strong>O COMODANTE não responderá por eventuais danos causados à saúde de terceiros, a vista de negligências do COMODATÁRIO quanto a conservação dos produtos da forma em que for especificada no ato da venda.</p>
    <p><strong>CLÁUSULA QUINTA – </strong>O COMODANTE poderá reivindicar a posse do(s) bem(ns) a qualquer momento, mesmo antes do vencimento do prazo contratual, caso haja inobservância por parte do COMODATÁRIO das estipulações previstas neste instrumento, independentemente de notificação expressa.</p>
    <p>Parágrafo primeiro – O equipamento cedido é para uso exclusivo do COMODATÁRIO e não será admitida em qualquer hipótese ou sob qualquer argumento o repasse à terceiro ou remoção do bem à outro local que não a sede de sua empresa, a não ser com o consentimento expresso do COMODANTE.</p>
    <p>Parágrafo Segundo – O COMODATÁRIO aceita as condições acima avençadas e declarara que neste ato recebeu o(s) equipamento(s) em estado de novo(s), se obrigando a devolvê-lo(s), findo o prazo contratual, em perfeitas condições de uso, funcionamento, limpeza e aparência, correndo por sua conta todas as despesas que para tanto forem necessárias.</p>
    <p><strong>CLÁUSULA SEXTA – </strong>Fica o COMODATÁRIO obrigado a conservar, como se seu próprio fora, o(s) aparelho(s) emprestado(s), não podendo usá-lo(s) senão de acordo com o contrato ou a natureza dele(s), sob pena de motivar a rescisão do contrato e responder por perdas e danos.</p>
    <p>Parágrafo único – Infringida esta cláusula, o COMODATÁRIO, constituído em mora, além de por ela responder, pagará, até restituir o(s) bem (ns), aluguel que for arbitrado pelo COMODANTE.</p>
    <p><strong>CLÁUSULA SÉTIMA – </strong>- As obrigações aqui instituídas são de cunho gratuito e respeitarão as disposições dos artigos 579 e seguintes do Código Civil Brasileiro.</p>
    <p><strong>CLÁUSULA OITAVA – </strong>Findo o prazo contratual, o COMODATÁRIO devolverá o(s) aparelho(s) ao COMODANTE, independentemente de qualquer notificação.edidas judiciais e extrajudiciais cabíveis, incluindo a inscrição do seu nome em órgãos de restrição de crédito.</p>
    <p>Parágrafo primeiro – Se o COMODATÁRIO, findo o prazo contratual ou rescindido o contrato, protelar a restituição do(s) bem (ns), incorrerá no pagamento de aluguéis a serem arbitrados pelo COMODANTE.</p>
    <p>Parágrafo segundo – Se o(s) bem (ns) se deteriorar (em), assim considerada qualquer avaria que exceda o desgaste natural pelo uso adequado, o que se apreciará segundo avaliação exclusiva da COMODANTE e independentemente de qualquer perícia ou laudo técnico, ficará o COMODATÁRIO obrigado pelo equivalente em dinheiro, conforme valor atribuído neste contrato. </p>
    <p><strong>CLÁUSULA NONA</strong> As partes se comprometem, por si, seus herdeiros ou sucessores a respeitar integralmente os termos deste contrato;</p>
    <p><strong>CLÁUSULA DÉCIMA</strong> Considerar-se-á rescindido o presente contrato, independentemente aviso ou notificação, quando verificado o desrespeito a quaisquer das cláusulas acima estabelecidas.0</p>
    <p>Parágrafo único- Havendo necessidade de socorro às vias judiciais para qualquer questão envolvendo o presente contrato, incorrerá ainda o COMODATÁRIO no pagamento das custas processual e honorário advocatício fixado em 20% sobre o valor da causa.</p>
    <p><strong>CLÁUSULA DÉCIMA SEGUNDA – </strong>- Para dirimir dúvidas ou questões decorrentes deste, elegem o foro da Comarca de Sertãozinho-SP, renunciando a qualquer outro, por mais privilegiado que seja.</p>
    <p>Firmam os contratantes este instrumento particular em duas vias de igual teor e forma, assinando-as na presença de duas testemunhas.</p>
    
    <p style="text-align: left;margin-top: 50px;margin-bottom: 25px;">Sertãozinho, '+isnull(@dt_mes_ano,0)+'</p>
  </div>
  </div>
  
<div class="assinaturas-bloco">
  <table class="assinatura-table_s">
            <tr>
              <td>______________________________________</td>
              <td>______________________________________</td>
            </tr>
            <tr>
              <td>'+isnull(@razaosocial_cliente_rodape,'') +'</td>
              <td>ALESSANDRO JOSÉ ZAMPRONIO LTDA</td>
            </tr>
            <tr>
              <td>CNPJ/CPF:'+ISNULL(@cnpj_cliente1,'')+'</td>
              <td>CNPJ: 62.182.753/0001-12</td>
     
    </tr>
  </table>
  <p class="testemunhas-titulo">Testemunhas</p>
  <table class="assinatura-table">
    <tr>
      <td>Nome: _______________________</td>
      <td>Nome: _______________________</td>
    </tr>
    <tr>
      <td>RG: _________________________</td>
      <td>RG: _________________________</td>
    </tr>
  </table>
</div>
	</body>
</html>'
		
		
--declare @nm_fantasia_vendedor varchar(30) = ''

--------------------------------------------------------------------------------------------------





--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +

	--@html_cab_det +
	 @html_detalhe +
	--@html_rod_det +

	@html_geral   + 
	@html_totais  +
	@html_grafico +
    @html_rodape  

--select @html, @html_empresa, @html_titulo, @html_cab_det, @html_rod_det, @html_totais, @html_grafico, @html_rodape

-------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML, 'Contrato de Comodato - ' + CAST(@cd_documento as varchar) as pdfName
-------------------------------------------------------------------------------------------------------------------------------------------------------


end



----------------------------------------------------------------------------------------------------------------------------------------------
go

--Json Enviado pelo Egismob
--exec pr_egis_relatorio_padrao '[{"cd_documento_form": 473667, "cd_empresa": 317, "cd_item_documento_form": "0", "cd_item_processo": "", "cd_menu": 8055, "cd_modulo": 212, "cd_parametro": "0", "cd_processo": "", "cd_relatorio": 182, "cd_usuario": 4254}]'


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--Gráfico
--exec pr_egis_relatorio_contrato_comodato_pimpinela 182,4253,0,'[{"cd_documento_form": 473667, "cd_empresa": 317, "cd_item_documento_form": "0", "cd_item_processo": "", "cd_menu": 8055, "cd_modulo": 212, "cd_parametro": "0", "cd_processo": "", "cd_relatorio": 182, "cd_usuario": 4254}]'
------------------------------------------------------------------------------
--text: (ctx) => "Point Style: " + ctx.chart.data.datasets[0].pointStyle, ( texto no título )
--select * from parametro_relatorio
--@cd_relatorio int   = 0,
--@cd_usuario   int   = 0, 
--@cd_parametro int   = 0,
--@json nvarchar(max) = '' 
