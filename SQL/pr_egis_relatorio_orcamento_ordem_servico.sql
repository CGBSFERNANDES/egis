IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_orcamento_ordem_servico' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_orcamento_ordem_servico

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_orcamento_ordem_servico
-------------------------------------------------------------------------------
--pr_egis_relatorio_orcamento_ordem_servico
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Joao Pedro Marcal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relat�rio Padr�o Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025
--Altera��o        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_orcamento_ordem_servico
@cd_relatorio int   = 0,
@json nvarchar(max) = '' 


as

set @json = isnull(@json,'')
declare @cd_parametro          int  = 0
declare @data_grafico_bar       nvarchar(max)
declare @cd_empresa             int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
declare @cd_documento           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @ic_valor_comercial     varchar(10)
declare @cd_tipo_destinatario   int 
declare @cd_grupo_relatorio     int 
declare @cd_vendedor            int = 0
declare @cd_ordem_servico       int = 0
DECLARE @id                     int = 0 
declare @nm_bairro_t            nvarchar(100)
DECLARE @tel_empresa            nvarchar(20) =''
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
			@cd_cliente				    int = 0,
			@cd_cnpj_cliente		    varchar(30) = '',
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

---------------------------------------------------------------------------------------------

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

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_ordem_servico       = valor from #json where campo = 'cd_documento_form'
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
   
  
select  
  @titulo             = nm_relatorio,  
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),  
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)  
from  
  egisadmin.dbo.Relatorio  
where  
  cd_relatorio = @cd_relatorio  
---------------------------------------------------------------------------------------------------------------------
select    
  @cd_vendedor      = isnull(cd_vendedor,0)
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

-----Dados da empresa-----------------------------------------------------------

	select 
		@logo = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),
		@nm_cor_empresa		   	    = isnull(e.nm_cor_empresa,'#1976D2'),
		@nm_endereco_empresa 	    = isnull(e.nm_endereco_empresa,''),
		@cd_telefone_empresa	    = case when @cd_empresa = 341 then '(11) 2914-4427 - (11) 99964-3324 - (11) 2914-4449' else isnull(e.cd_telefone_empresa,'') end,
		@nm_email_internet	  	    = isnull(e.nm_email_internet,''),
		@nm_cidade			    	= isnull(c.nm_cidade,''),
		@sg_estado				    = isnull(es.sg_estado,''),
		@nm_fantasia_empresa	    = isnull(e.nm_empresa,''),
		@cd_cep_empresa			    = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),
		@cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),
		@nm_pais					= ltrim(rtrim(isnull(p.sg_pais,''))),
		@cd_cnpj_empresa			= dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),
		@cd_inscestadual_empresa	=  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),
		@nm_dominio_internet		=  ltrim(rtrim(isnull(e.nm_dominio_internet,''))),
		@nm_bairro_t                =  isnull(e.nm_bairro_empresa,'')     

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
-------------------------------------------------------------------------------------------------

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
            background-color: #f9f9f9;
        }

        .container {
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
            flex:1;
            width: 100%;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom:5px ;
        }

        table,
        th,
        td {
            border: 1px solid black;
        }

        th,
        td {
            padding: 10px;
            text-align: center;
            font-size: 14px;
        }

        th {
            background-color: #f2f2f2;
            color: #333;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        img {
            max-width: 250px;
        }

        .report-date-time {
            text-align: right;
            margin-bottom: 1px;
        }

        .section {
            border: 1px solid black;
            padding: 1px;
            text-align: center;
        }

        .header-table {
            width: 100%;
            border: 1px solid black;
            border-collapse: collapse;
        }

        .bold {
            font-weight: bold;
            font-size: 14px;
        }

        #imprimir {
            background-color: #1976D2;
            color: white;
            border: none;
            padding: 5px 10px;
            font-size: 14px;
            cursor: pointer;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        @media print {
            @page {
                size: landscape;
                margin: 10mm;
            }

            body {
                display: block !important;
            }

            .container {
                width: 100% !important;
                display: block !important;
            }

            * {
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }

            #imprimir {
                display: none;
            }
        }

    </style>
</head>
'

--select @html_empresa

--Procedure de Cada Relat?rio-------------------------------------------------------------------------------------  
  
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

--------------------------------------------------------------------------------------------------------------------------
select 
    IDENTITY(int,1,1)            as cd_controle,
	os.dt_ordem_servico          as dt_ordem_servico,
	os.cd_numero_serie           as cd_numero_serie,
	os.cd_contato			     as cd_contato,
	osl.dt_analise               as dt_analise,
	os.ds_def_cli_ordem_servico  as ds_def_cli_ordem_servico,
	mp.nm_marca_produto          as nm_marca,
	os.nm_modelo_produto         as nm_modelo_produto,
	oso.cd_ordem_servico         as cd_ordem_servico,
	oso.dt_orcamento             as dt_orcamento,
	osl.ds_componentes           as ds_componentes,
	oso.vl_orcamento             as vl_orcamento,
	oso.vl_final_ordem_servico   as vl_final_ordem_servico,
	oso.cd_forma_pagamento       as cd_forma_pagamento,
	fp.nm_forma_pagamento        as nm_forma_pagamento,
	oso.vl_desconto              as vl_desconto,
	oso.vl_pagamento             as vl_pagamento,
	oso.vl_custo_ordem_servico   as vl_custo_ordem_servico,
	oso.dt_entrega               as dt_entrega,
	oso.qt_dia_garantia          as qt_dia_garantia,
	oso.pc_taxa_bancaria         as pc_taxa_bancaria,
	oso.dt_compra                as dt_compra,
	oso.ds_orcamento             as ds_orcamento,
	c.nm_fantasia_cliente        as nm_fantasia_cliente,
	c.cd_telefone                as cd_telefone,
	c.cd_ddd                     as cd_ddd,
	c.nm_endereco_cliente        as nm_endereco_cliente,
	c.cd_numero_endereco         as cd_numero_endereco

into
	#OrcamentoRel

from Ordem_Servico_Orcamento oso
    left outer join Ordem_Servico_Laboratorio osl on osl.cd_ordem_servico  = oso.cd_ordem_servico 
	left outer join forma_pagamento fp            on fp.cd_forma_pagamento = oso.cd_forma_pagamento
	left outer join ordem_servico os              on os.cd_ordem_servico   = oso.cd_ordem_servico
	left outer join marca_produto mp              on mp.cd_marca_produto   = os.cd_marca_produto
    left outer join cliente c                     on c.cd_cliente          = os.cd_cliente

where os.cd_ordem_servico = @cd_ordem_servico
------------------------------------------------------------------------------------------------------------		 
   
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #OrcamentoRel  
  return  
 end  
------------------------------------------------------------------------------------------------------------		 
declare 
	@dt_ordem_servico       datetime,
	@nm_marca               varchar(60),
	@nm_modelo              varchar(60),
	@cd_serie               varchar(60),
	@cd_contato             varchar(30),
	@nm_defeito_relatado    varchar(60),
	@ds_componentes         varchar(60),
	@vl_orcamento		    float = 0,
	@dt_analise_tecnica     datetime, 
	@dt_orcamento           datetime,
	@nm_forma_pagamento     varchar(60),
	@vl_desconto            float = 0,
	@vl_custo_ordem_servico float = 0,
	@dt_entrega             datetime,
	@pc_taxa_bancaria       float = 0,
	@dt_compra              datetime,
	@ds_orcamento           varchar(100)

select 
	@dt_ordem_servico       = dt_ordem_servico,
	@nm_marca               = nm_marca,
	@nm_modelo              = nm_modelo_produto,
	@cd_serie               = cd_numero_serie,
	@cd_contato             = cd_contato,
	@nm_defeito_relatado    = ds_def_cli_ordem_servico,
	@ds_componentes         = ds_componentes,
	@dt_analise_tecnica     = dt_analise,
	@vl_orcamento           = vl_orcamento,
	@dt_orcamento           = dt_orcamento,
	@nm_forma_pagamento     = nm_forma_pagamento,
	@vl_desconto		    = vl_desconto,
	@vl_custo_ordem_servico = vl_custo_ordem_servico,
	@dt_entrega             = dt_entrega,
	@pc_taxa_bancaria		= pc_taxa_bancaria,
	@dt_compra				= dt_compra,
	@ds_orcamento           = ds_orcamento

from #OrcamentoRel 
------------------------------------------------------------------------------------------------------------
set @html_geral = '
<body>
    <div class="container">
        <table class="header-table">
            <tr>
                <td rowspan="5" >
                    <img src="'+isnull(@logo,'')+'" alt="Logo da Empresa">
                </td>
                <td colspan="4" class="bold">'+isnull(@nm_fantasia_empresa,'')+'</td>
				<td>RELATÓRIO ORÇAMENTO</td>
            </tr>
            <tr class="bold">
                
                <td colspan="4" class="header-info"> RELATÓRIO ORÇAMENTO</td>
                <td colspan="2">OS Nº: '+cast(isnull(@cd_ordem_servico,'')as nvarchar(15))+'</td>
            </tr>
            <tr class="bold">
                <td style="text-align: left;">CNPJ: '+isnull(@cd_cnpj_empresa,'')+'</td>
                <td >'+isnull(@nm_endereco_empresa,'')+', '+cast(isnull(@cd_numero_endereco_empresa,0)as nvarchar(15))+' - '+isnull(@nm_bairro_t,'')+' - '+isnull(@nm_cidade,'')+' - '+isnull(@sg_estado,'')+'</td>
                <td > TEL: '+isnull(@cd_telefone_empresa,'')+' </td>
				<td >I.E: '+isnull(@cd_inscestadual_empresa,'')+'</td>
				<td >'+isnull(dbo.fn_data_string(@dt_ordem_servico),'')+'</td> 
            </tr>
        </table> 
        <table>
            <tr>
                <th>MARCA</th>
                <th>MODELO</th>
                <th>SÉRIE</th>
                <th>CONTATO</th>
                <th>DEFEITO RELATADO</th>
                <th>COMPONENTES</th>
                <th>ANALISE TÉCNICA</th>
                <th>VALOR ORÇAMENTO</th>
                <th>DATA ORÇAMENTO</th>
            </tr>
            <tr>
                <td>'+isnull(@nm_marca,'')+'</td>
                <td>'+isnull(@nm_modelo,'')+'</td>
                <td>'+isnull(@cd_serie,'')+'</td>
                <td>'+isnull(@cd_contato,'')+'</td>
                <td>'+isnull(@nm_defeito_relatado,'')+'</td>
                <td>'+isnull(@ds_componentes,'')+'</td>
                <td>'+isnull(dbo.fn_data_string(@dt_analise_tecnica),'')+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@vl_orcamento),0) as nvarchar(20))+'</td>
                <td>'+isnull(dbo.fn_data_string(@dt_orcamento),'')+'</td>
            </tr>
        </table>
  <table>
            <tr>
                <th>FORMA DE PAGAMENTO</th>
                <th>DESCONTO</th>
                <th>CUSTO</th>
                <th>ENTREGA</th>
                <th>(%)TAXA BANCÁRIA</th>
                <th>COMPRA</th>
            </tr>
            <tr>
                <td>'+isnull(@nm_forma_pagamento,'')+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@vl_desconto),0) as nvarchar(20))+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@vl_custo_ordem_servico),0) as nvarchar(20))+'</td>
                <td>'+isnull(dbo.fn_data_string(@dt_entrega),'')+'</td>
                <td>'+cast(isnull(dbo.fn_formata_valor(@pc_taxa_bancaria),0) as nvarchar(20))+'</td>
                <td>'+isnull(dbo.fn_data_string(@dt_compra),'')+'</td>
            </tr>
        </table>
        <table style="width: 100%;">
            <tr>
                <th style="width: 50%;">DESCRITIVO</th>
                <th style="width: 50%;">GARANTIA</th>
            </tr>
            <tr>
                <td style="text-align: CENTER;">'+ISNULL(@ds_orcamento,'')+'</td>
                <td style="text-align: CENTER;">GARANTIA DE 06 MESES (PEÇAS ORIGINAIS) </td>
            </tr>
        </table>'
--------------------------------------------------------------------------------------------------------------------
set @html_rodape =
    '
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>
        <button  id="imprimir">Imprimir</button>
    </div>
       <script>
        document.querySelector("#imprimir").addEventListener("click", function () {
          window.print();
        });
      </script>
</body>'



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
--exec pr_egis_relatorio_orcamento_ordem_servico 300,''
------------------------------------------------------------------------------
