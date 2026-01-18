IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_movimento_caixa_dinamico' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_movimento_caixa_dinamico

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_movimento_caixa_dinamico
--use egissql_297
-------------------------------------------------------------------------------
--pr_egis_relatorio_frete_motorista
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
-- use egissql_360
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_movimento_caixa_dinamico
@cd_relatorio int = 0,
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
declare @cd_parametro           int = 0
declare @cd_tipo_pagamento      int = 0
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
  select @cd_parametro           = valor from #json where campo = 'cd_parametro'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_tipo_pagamento      = valor from #json where campo = 'cd_tipo_pagamento'

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
  @dt_inicial        = dt_inicial,  
  @dt_final          = dt_final,
  @cd_tipo_pagamento = isnull(cd_tipo_pagamento,0)
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
            margin-bottom: 10px;
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
            margin-top: 5px;
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
      border-radius: 5px;
      cursor: pointer;
      margin-bottom: 15px;
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

--declare
 --set  @cd_tipo_pagamento = 0             -- Ex: 1=Dinheiro, 3=Crédito, 4=Débito, 6=PIX  
 --set  @dt_inicial = '11/10/2025'                    -- Data inicial do filtro  
 --set  @dt_final   = '11/30/2025'                     -- Data final do filtro 
------------------------------------------------------------------------------------------------------------
    set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
SELECT  
      identity(int,1,1) as cd_controle,
      isnull(mc.dt_movimento_caixa,'')  AS DataDate, 
      LEFT(CONVERT(time, mc.dt_usuario), 8) AS Datatime,  
      tpc.nm_tipo_pagamento,      
            mc.cd_movimento_caixa,      
            mc.vl_movimento_caixa,      
            mc.vl_desconto,      
      
            mc.vl_movimento_caixa AS vl_valor_pagamento,      
      
            (mc.vl_movimento_caixa - mc.vl_desconto - mcp.vl_taxa_pagamento) AS vl_liquido,      
           

            mcp.cd_nsu_tef as cd_nsu_tef,      

            mcp.cd_autorizacao_tef as cd_autorizacao_tef,  
  
            -- ALIASES CORRETOS AQUI  
            mcp.vl_taxa_pagamento  AS vl_taxa_pagamento,  

            bc.nm_bandeira_cartao  AS nm_bandeira_cartao,  

            mcr.nm_maquina_cartao  as nm_maquina_cartao 
			
			INTO #MovimentoDetalhe
  
        FROM movimento_caixa mc      
        INNER JOIN Tipo_Movimento_Caixa tmc     ON mc.cd_tipo_movimento_caixa = tmc.cd_tipo_movimento_caixa      
        INNER JOIN Tipo_Pagamento_Caixa tpc     ON mc.cd_tipo_pagamento = tpc.cd_tipo_pagamento      
        LEFT JOIN Movimento_Caixa_Pagamento mcp ON mcp.cd_movimento_caixa = mc.cd_movimento_caixa  
        LEFT JOIN Bandeira_Cartao bc            ON mcp.cd_bandeira_cartao = bc.cd_bandeira_cartao  
        LEFT JOIN Maquina_Cartao mcr            ON mcr.cd_maquina_cartao = mcp.cd_maquina_cartao


WHERE
    mc.dt_movimento_caixa BETWEEN @dt_inicial AND @dt_final  
    AND
	mc.cd_tipo_pagamento = CASE WHEN ISNULL(@cd_tipo_pagamento,0) = 0 THEN mc.cd_tipo_pagamento ELSE @cd_tipo_pagamento END
	and
	mc.cd_movimento_caixa not in (select x.cd_movimento_caixa from Movimento_Caixa_Divisao x)
	


SELECT  
      mc.dt_movimento_caixa AS DataDate,             
      tpc.nm_tipo_pagamento,   
      SUM(isnull(mc.vl_movimento_caixa,0)) AS vl_movimento_caixa_total,  
      SUM(isnull(mc.vl_desconto,0)) AS vl_desconto_total,  
      SUM(CASE @cd_tipo_pagamento  
              WHEN 1 THEN mc.vl_dinheiro  
              WHEN 3 THEN mc.vl_cartao_credito  
              WHEN 4 THEN mc.vl_cartao_debito  
              WHEN 6 THEN mc.vl_pix  
              ELSE 0  
          END) AS vl_valor_pagamento_total,  
	  sum(isnull(mcp.vl_taxa_pagamento,0))  AS vl_taxa_pagamento,  
      SUM(isnull(mc.vl_movimento_caixa,0) - isnull(mc.vl_desconto,0) - isnull(mcp.vl_taxa_pagamento,0)) AS vl_liquido_total
INTO #MovimentoTotal
        FROM movimento_caixa mc  
        INNER JOIN Tipo_Movimento_Caixa tmc    ON mc.cd_tipo_movimento_caixa = tmc.cd_tipo_movimento_caixa  
        LEFT JOIN Movimento_Caixa_Divisao mcd ON mcd.cd_movimento_caixa = mc.cd_movimento_caixa  
        LEFT JOIN Bandeira_Cartao bcd          ON mcd.cd_bandeira_cartao = bcd.cd_bandeira_cartao  
        LEFT JOIN Maquina_Cartao mcrd          ON mcrd.cd_maquina_cartao = mcd.cd_maquina_cartao  			
        INNER JOIN Tipo_Pagamento_Caixa tpc     ON mc.cd_tipo_pagamento = tpc.cd_tipo_pagamento    
		LEFT JOIN Movimento_Caixa_Pagamento mcp ON mcp.cd_movimento_caixa = mc.cd_movimento_caixa  
WHERE 
    mc.dt_movimento_caixa BETWEEN @dt_inicial AND @dt_final  
    AND mc.cd_tipo_pagamento = CASE 
                                 WHEN ISNULL(@cd_tipo_pagamento,0) = 0 
                                 THEN mc.cd_tipo_pagamento 
                                 ELSE @cd_tipo_pagamento 
                               END
	
GROUP BY 
    mc.dt_movimento_caixa,
    tpc.nm_tipo_pagamento
		--select * from #MovimentoTotal return
		--select * from #MovimentoDetalhe return
declare 
	@dt_movimento_final float = 0,
	@vl_desconto_total_final float = 0
			
select
     identity(int,1,1)              as cd_controle,
	 nm_tipo_Pagamento              as nm_tipo_Pagamento,
	 sum(vl_movimento_caixa_total)        as vl_movimento_caixa_total,
	 sum(vl_desconto_total)               as vl_desconto_total,
	 sum(vl_liquido_total)			    as vl_liquido_total,
	 sum(vl_taxa_pagamento)         as vl_taxa_pagamento
	
	into
	 #MovimentacaoTotalFinal

from 
  #MovimentoTotal

Group by
  nm_tipo_Pagamento

  order by 
  nm_tipo_Pagamento
 -- select * from #MovimentacaoTotalFinal
  select
	@dt_movimento_final  = count(DISTINCT(DataDate))
  from #MovimentoTotal
-- select * from Tipo_Pagamento_Caixa
------------------------------------------------------------------------------------------------------------------------------------  

 --if isnull(@cd_parametro,0) = 1    
 --begin    
 --   select * from #AuxFrete  
 --   order by  
 --    nm_motorista, qt_viagem desc  
 --   return    
 --end    
  
 --------------------------------------------------------------------------------------------------------------  
 declare 
  @DataDate                  datetime = '',
  @id                        int =0,
  @sub_id                    int= 0,
  @nm_tipo_pagamento       	 varchar(60),
  @vl_movimento_caixa_total	 float = 0,
  @vl_desconto_total       	 float = 0,
  @vl_liquido_total          float = 0
DECLARE @htmlConteudo NVARCHAR(MAX) = ''

;WITH Datas AS (
    SELECT DISTINCT CAST(DataDate AS DATE) AS DataDate
    FROM #MovimentoTotal
),
LinhasHTML AS (
    SELECT
        CAST(M.DataDate AS DATE) AS DataDate,
        '
        <tr>
            <td>'+ISNULL(dbo.fn_data_string(M.DataDate),'')+'</td>
            <td>'+ISNULL(M.Datatime,'')+'</td>
            <td>'+ISNULL(M.nm_tipo_pagamento,'')+'</td>
            <td>'+CAST(ISNULL(M.cd_movimento_caixa,0) AS VARCHAR(20))+'</td>
            <td>'+CAST(ISNULL(dbo.fn_formata_valor(M.vl_movimento_caixa),0) AS VARCHAR(20))+'</td>
            <td>'+CAST(ISNULL(dbo.fn_formata_valor(M.vl_desconto),0) AS VARCHAR(20))+'</td>
            <td>'+CAST(ISNULL(dbo.fn_formata_valor(M.vl_liquido),0) AS VARCHAR(20))+'</td>
			<td>'+CAST(ISNULL(dbo.fn_formata_valor(M.vl_taxa_pagamento),0) AS VARCHAR(20))+'</td>
			<td>'+ISNULL(M.nm_bandeira_cartao,'')+'</td> 
			<td>'+ISNULL(M.nm_maquina_cartao,'')+'</td>
            <td>'+ISNULL(M.cd_nsu_tef,'')+'</td> 
            <td>'+ISNULL(M.cd_autorizacao_tef,'')+'</td>
        </tr>
        ' AS LinhaHTML
    FROM #MovimentoDetalhe M
)
SELECT @htmlConteudo =
(
    SELECT 
        '
        <div class="section-title">
            <p class="motorista" style="font-weight:bold; font-size:16px;">'
                + isnull(dbo.fn_data_string(D.DataDate),'') +
            '</p>
        </div>

        <table>
            <tr style="background-color:#f0f0f0;">
                <th>Data Pagamento</th>
                <th>Hora Pagamento</th>
                <th>Tipo Pagamento</th>
                <th>Movimento Caixa</th>
                <th>Valor</th>
                <th>Desconto</th>
                <th>Valor Líquido</th>
				<th>Taxa Pagamento</th>
				<th>Bandeira</th>
				<th>Tipo Maquininha</th>
                <th>NSU</th>
                <th>Autorização</th>
            </tr>' +

            STUFF((
                SELECT LinhaHTML
                FROM LinhasHTML L
                WHERE L.DataDate = D.DataDate
                ORDER BY L.DataDate, LinhaHTML
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 0, '')

        + '</table>'
    FROM Datas D
    ORDER BY D.DataDate
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)')

---------------------------------------------------------------------------
-- 3) MONTA HTML FINAL
---------------------------------------------------------------------------
SET @html_geral =
'
<div class="section-title">    
    <p style="display: inline;">Período: '
    + ISNULL(dbo.fn_data_string(@dt_inicial),'') +
    ' á ' + ISNULL(dbo.fn_data_string(@dt_final),'') + '</p>     
    <p style="display: inline; text-align: center; padding: 15%;">'
    + ISNULL(@titulo,'') + '</p>    
</div>

<div id="tabelaExportar">'
+ @htmlConteudo +
''
--------------------------------------------------------------------------------------------------------------------  
--if ISNULL(@dt_movimento_final,0) > 1 
--begin
set @html_geral = @html_geral + '
     <table>
        <tr style="background-color:#f0f0f0;">
            <th>Tipo Pagamento</th>
            <th>Valor Total</th>
            <th>Desconto Total</th>            
			<th>Valor Taxa Total</th>
			<th>Valor Líquido Total</th>
        </tr>'
  while exists ( select top 1 cd_controle from #MovimentacaoTotalFinal)
   begin
	select top 1

		@id                          = cd_controle,

            @html_geral = @html_geral + '
            <tr style="text-align:center;">
                <td>'+isnull(nm_tipo_pagamento,'')+'</td>
                <td>'+CAST(ISNULL(dbo.fn_formata_valor(vl_movimento_caixa_total),0) AS VARCHAR(20))+'</td>
                <td>'+CAST(ISNULL(dbo.fn_formata_valor(vl_desconto_total),0) AS VARCHAR(20))+'</td>
				<td>'+CAST(ISNULL(dbo.fn_formata_valor(vl_taxa_pagamento),0) AS VARCHAR(20))+'</td>
                <td>'+CAST(ISNULL(dbo.fn_formata_valor(vl_liquido_total),0) AS VARCHAR(20))+'</td>				
            </tr>'
         from #MovimentacaoTotalFinal
	 delete from #MovimentacaoTotalFinal where cd_controle = @id
 end
	--end
	--else 
	--	begin
	--	set @html_geral = @html_geral + ''
	
	--end
	
	set @html_rod_det = @html_rod_det + '</table></div>
    <div class="report-date-time">  
	  <button class="export-btn" onclick="exportarExcel()">Exportar para Excel </button>
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>  
    </div>
	<script>
    function exportarExcel() {
      const tabela = document.getElementById("tabelaExportar").outerHTML;

      const conteudoExcel =
        `<html>
            <head>
              <meta charset="UTF-8">
            </head>
            <body>
              ${tabela}
            </body>
        </html>`;

      const blob = new Blob([conteudoExcel], {
        type: "application/vnd.ms-excel"
      });

      const url = URL.createObjectURL(blob);

      const a = document.createElement("a");
      a.href = url;
      a.download = "'+ISNULL(@titulo,'')+'.xls";
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
  

-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
exec pr_egis_relatorio_movimento_caixa_dinamico 400,'[{"cd_usuario":1,"cd_empresa":297,"cd_relatorio":390,"dt_inicial":"11-22-2025","dt_final":"11-30-2025","cd_tipo_pagamento":null}]'
------------------------------------------------------------------------------
