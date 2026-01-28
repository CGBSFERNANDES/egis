IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_contabiliza_documentos_pagar' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_contabiliza_documentos_pagar

GO
--use egissql_274
-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_contabiliza_documentos_pagar
-------------------------------------------------------------------------------
--pr_egis_relatorio_contabiliza_documentos_pagar
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
-- use egissql_372
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_contabiliza_documentos_pagar
@cd_relatorio int   = 0,
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
--declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
--declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @cd_vendedor            int = 0 
declare @cd_grupo_relatorio     int = 0
--declare @cd_relatorio           int = 0

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
	--		@nm_fantasia_cliente  	    varchar(200) = '',
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



--------------------------------------------------------------------------------------------------------
       
--set @cd_parametro      = 0
set @cd_empresa        = 0
set @cd_form           = 0


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
 
 --select @cd_relatorio
 
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
  @dt_inicial       = dt_inicial,  
  @dt_final         = dt_final
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


set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)


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
			font-size:12px;
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
            margin-top: 10px;
        }

        p {
            margin: 5px;
            padding: 0;
        }

        .tamanho {
         
            text-align: center;
        }
		   .export-btn {
      background: #1976D2;
      color: white;
      padding: 10px 16px;
      border: none;
	 text-align: right;
      border-radius: 5px;
      cursor: pointer;
    }

    .export-btn:hover {
      background: #125ca3;
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
--USE EGISSQL_376
------------------------------------------------------------------------------------------------------------
    set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)

	--set @dt_inicial = '12-05-2025'
	--set @dt_final  = '12-05-2025' 
------------------------------------------------------------------------------------------------------------
Create table #Contabilizacao_doc_pagar(
	Documento                 varchar(100),
	Fornecedor	              varchar(150), 
	Pagamento	              DATETIME,
	Debito                    FLOAT,
	Credito                   FLOAT,
	Total		              FLOAT,
	Historico                 int,
	DescHistorico             varchar(150),
	vl_documento_pagar        float, 
	TipoPagamento             int,
	DocPagamento              varchar(150),
	cd_reduzido_conta_debito  int,
	cd_reduzido_conta_credito int,
	nm_tipo_pagamento         varchar(150)
)
insert into
	#Contabilizacao_doc_pagar
EXEC pr_contabiliza_documentos_pagar @dt_inicial,@dt_final

--select * from #Contabilizacao_doc_pagar return
------------------------------------------------------------------------------------------------------------
select 
    identity(int,1,1)       as cd_controle,
	nm_tipo_pagamento       as nm_tipo_pagamento_geral,
	TipoPagamento           as TipoPagamento,
	sum(vl_documento_pagar) as vl_documento_pagar_geral,
	sum(Debito)				as Debito_geral,
	sum(Credito)            as Credito_geral

	into 
	#Contabilizacao_doc_pagar_geral
from 
	#Contabilizacao_doc_pagar

group by 
	nm_tipo_pagamento,
	TipoPagamento

	--select * from #Contabilizacao_doc_pagar_geral return


------------------------------------------------------------------------------------------------------------
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #Contabilizacao_doc_pagar  
  return  
 end  
 
--------------------------------------------------------------------------------------------------------------
declare 
	@id                 int,
	@vl_documento_pagar float,
	@Debito             float,
	@Credito            float

select 
	@vl_documento_pagar	 = sum(vl_documento_pagar),
	@Debito            	 = sum(Debito),
	@Credito             = sum(Credito)
from 
	#Contabilizacao_doc_pagar

set @html_empresa = @html_empresa +'
	
	 <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 20%;">'+case when isnull(@titulo,'') <> '' then ''+isnull(@titulo,'')+'' else 'Contabilização Documento a Pagar' end +'</p>  
    </div>  '
;WITH TiposPagamento AS (
    SELECT DISTINCT
        nm_tipo_pagamento
    FROM #Contabilizacao_doc_pagar
),
LinhasHTML AS (
    SELECT
        nm_tipo_pagamento,
        '
        <tr>
            <td>'+ISNULL(Documento,'')+'</td>
            <td>'+ISNULL(Fornecedor,'')+'</td>
            <td>'+ISNULL(dbo.fn_data_string(Pagamento),'')+'</td>
            <td style="text-align:right;">'+isnull(dbo.fn_formata_valor(Debito),0)+'</td>
            <td style="text-align:right;">'+isnull(dbo.fn_formata_valor(Credito),0)+'</td>
            <td style="text-align:right;">'+isnull(dbo.fn_formata_valor(vl_documento_pagar),0)+'</td>
            <td>'+ISNULL(DescHistorico,'')+' ('+cast(isnull(Historico,0)as varchar(20))+')</td>
        </tr>
        ' AS LinhaHTML
    FROM #Contabilizacao_doc_pagar
)


SELECT @html_geral =
(
    SELECT
        '<div id="tabelaExportar">
        <div class="section-title" style="margin-top:30px;">
            <h3 style="margin:0;">Tipo de Pagamento: '+TP.nm_tipo_pagamento+'</h3>
        </div>

        <table style="width:100%; border-collapse:collapse;" border="1">
            <tr style="background:#f0f0f0;">
                <th>Documento</th>
                <th>Fornecedor</th>
                <th>Pagamento</th>
                <th>Débito</th>
                <th>Crédito</th>
                <th>Valor</th>
                <th>Histórico</th>
            </tr>
        '
        +


        STUFF((
            SELECT L.LinhaHTML
            FROM LinhasHTML L
            WHERE L.nm_tipo_pagamento = TP.nm_tipo_pagamento
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 0, '')

        +

        (
            SELECT
                '
                <tr style="font-weight:bold; background:#e8e8e8;">
                    <td colspan="3" style="text-align:right;">TOTAL</td>
					 <td style="text-align:right;">'+ isnull(dbo.fn_formata_valor(G.Debito_geral),0) +'</td>
					 <td style="text-align:right;">'+ isnull(dbo.fn_formata_valor(G.Credito_geral),0) +'</td>
                     <td style="text-align:right;">'+ isnull(dbo.fn_formata_valor(G.vl_documento_pagar_geral),0) +'</td>
                    <td></td>
                </tr>
                '
            FROM #Contabilizacao_doc_pagar_geral G
            WHERE G.nm_tipo_pagamento_geral = TP.nm_tipo_pagamento
        )

        + '</table>'
		--use egissql_274

    FROM TiposPagamento TP
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)')
--------------------------------------------------------------------------------------------------------------------

set @html_rodape ='
	  <table>
			 <tr style="font-weight:bold; background:#d0d0d0;">
               <th style="text-align:center;">Débito Total</th>
               <th style="text-align:center;">Crédito Total</th>
               <th style="text-align:center;">Valor Pagamento</th> 
          </tr>
           <tr style="font-weight:bold; background:#d0d0d0;">
               <td style="text-align:center;">'+CAST(isnull(dbo.fn_formata_valor(@Debito),0) as varchar(20))+'</td>
               <td style="text-align:center;">'+CAST(isnull(dbo.fn_formata_valor(@Credito),0) as varchar(20))+'</td>
               <td style="text-align:center;">'+CAST(isnull(dbo.fn_formata_valor(@vl_documento_pagar),0)as varchar(20))+'</td> 
          </tr>
       </table>    
	</div>
	 <button style="text-align:right" class="export-btn" onclick="exportarExcel()">
            Exportar para Excel
        </button>

	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>
    </div>
	  <script>
        function exportarExcel() {

            const conteudo = document.getElementById("tabelaExportar").innerHTML;

            const htmlExcel = `
                <html>
                    <head>
                        <meta charset="UTF-8">
                    </head>
                    <body>
                        ${conteudo}
                    </body>
                </html>
            `;

            const blob = new Blob([htmlExcel], {
                type: "application/vnd.ms-excel"
            });

            const url = URL.createObjectURL(blob);

            const a = document.createElement("a");
            a.href = url;
            a.download = "Relatorio.xls";

            a.click();
            URL.revokeObjectURL(url);
        }
    </script>
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
--exec pr_egis_relatorio_contabiliza_documentos_pagar 231,''
------------------------------------------------------------------------------
