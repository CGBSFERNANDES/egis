IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_ordem_expedicao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_ordem_expedicao

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_ordem_expedicao
--use egissql_317
-------------------------------------------------------------------------------
--pr_egis_relatorio_ordem_expedicao
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
create procedure pr_egis_relatorio_ordem_expedicao
@cd_relatorio  int = 0,
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
			@cd_cep_empresa			    varchar(20) = '',
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


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'

   end
end

--select @cd_documento
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
--select  
--  @dt_inicial       = dt_inicial,  
--  @dt_final         = dt_final
--from   
--  Parametro_Relatorio  
  
--where  
--  cd_relatorio = @cd_relatorio  
--  and  
--  cd_usuario   = @cd_usuario  
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
      padding: 5px;
    }

    h2 {
      color: #333;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 7px;
    }

    table,
    th,
    td {
      border: 1px solid #ddd;
    }

    th,
    td {
      padding: 7px;
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
      margin-bottom: 5px;
      border-radius: 5px;
      font-size:100%;
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
      margin-top: 20px;
    }

    p {
      margin: 5px;
      padding: 0;
    }

    .tamanho {
      text-align: center;
    }
  </style>
</head>
<body>
<div style="display: flex; justify-content: space-between; align-items: center;">
  <div style="width:30%; margin-right:20px;">
    <img src='+@logo+' alt="Logo da Empresa">
  </div>
  
  <h1 style="width:50%; text-align: center;">Ordem de Expedição</h1>
  
  <div style="width:30%; text-align: right;">
    <strong>Data:</strong><br>
    16/10/2025
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
------------------------------------------------------------------------------------------------------------
     set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
 SELECT TOP 1
           oe.cd_ordem_expedicao,
           oe.dt_ordem_expedicao,
           oe.cd_coleta,
           oe.ds_observacao,
           oe.ic_material_embalado,
           oe.ic_material_com_etiqueta,
           oe.ic_cod_barras_itens,
           -- motorista/veículo
           oe.nm_motorista,
           oe.cd_documento_motorista,
           oe.cd_placa_veiculo,
           oe.hr_chegada,
           oe.hr_saida,
           oe.dt_coleta,
           -- cliente / transportadora
           cli.cd_cliente,
           cli.nm_fantasia_cliente,
           cli.cd_cnpj_cliente,
           cli.nm_endereco_cliente,
           cli.cd_numero_endereco,
           cli.nm_bairro,
           cid.nm_cidade        AS nm_cidade_cliente,
           est.sg_estado        AS sg_estado_cliente,
           tr.nm_transportadora

		 

      INTO #OE_Header
  FROM Ordem_Expedicao oe       WITH(NOLOCK)
      left outer join  Cliente cli         WITH(NOLOCK) ON cli.cd_cliente        = oe.cd_cliente
      left outer join cidade cid    with(nolock) on cid.cd_cidade         = cli.cd_cidade
      left outer join estado est    with(nolock) on est.cd_estado         = est.cd_estado
      LEFT JOIN Transportadora tr   WITH(NOLOCK) ON tr.cd_transportadora  = oe.cd_transportadora
  WHERE oe.cd_ordem_expedicao = @cd_documento

 -- select * from #OE_Header return
   SELECT 
         IDENTITY(INT,1,1) AS cd_controle,
         oei.cd_item,
         oei.cd_produto,
         oei.cd_mascara_produto,
         oei.nm_produto,
         oei.qt_item,
         oei.sg_unidade,
         oei.qt_volume,
         oei.qt_peso_bruto,
         oei.ds_obs_item
      INTO #OE_Itens
	 FROM 
		Ordem_Expedicao_Item oei WITH(NOLOCK)
     WHERE 
		oei.cd_ordem_expedicao = @cd_documento
     ORDER BY oei.cd_item

	 ---select * from #OE_Itens return
------------------------------------------------------------------------------------------------------------  
declare 
	@nm_fantasia_cliente    varchar(150),
	@cd_cliente             int = 0,
	@cd_coleta              int = 0,
	@dt_ordem_expedicao     datetime = '',
	@nm_transportadora      varchar(80),
	@cd_cnpj_cliente        varchar(30),
	@nm_motorista           varchar(80),
	@cd_documento_motorista varchar(50),
	@dt_coleta              datetime,
	@hr_saida               varchar(25),
	@hr_chegada             varchar(25)
select 
	@nm_fantasia_cliente    = nm_fantasia_cliente,
	@cd_cliente             = cd_cliente,
	@dt_ordem_expedicao     = dt_ordem_expedicao,
	@cd_coleta              = cd_coleta,
	@nm_transportadora      = nm_transportadora,
	@cd_cnpj_cliente        = cd_cnpj_cliente,
	@nm_motorista           = nm_motorista,
	@cd_documento_motorista = cd_documento_motorista,
	@dt_coleta              = dt_coleta,
	@hr_saida               = hr_saida,
	@hr_chegada             = hr_chegada
from #OE_Header   

		
------------------------------------------------------------------------------------------------------------
set @html_geral = '
<h3 class="section-title" style="text-align:center">Ordem de Expedição nº '+CAST(isnull(@cd_documento,0) as varchar(50))+'</h3>
  <table>
    <tr>
      <th style="width:50%">Cliente</th>
      <th style="width:15%">Data</th>
      <th style="width:15%">Nº Coleta</th>
      <th style="width:20%">Transportadora / Placa</th>
    </tr>
    <tr>
      <td>'+isnull(@nm_fantasia_cliente,'')+' <span>('+isnull(dbo.fn_formata_cnpj(@cd_cnpj_cliente),'')+')</span></td>
      <td style="text-align:center">'+isnull(dbo.fn_data_string(@dt_ordem_expedicao),'')+'</td>
      <td style="text-align:center">'+CAST(isnull(@cd_coleta,0) as varchar(50))+'</td>
      <td>'+isnull(@nm_transportadora,'')+'</td>
    </tr>
  </table>

  <h4 class="section-title">Itens da Expedição</h4>
  <table>
    <tr>
      <th style="width:5%">Cód.</th>
      <th style="width:25%">Produto</th>
      <th style="width:5%">Qtd</th>
      <th style="width:5%">UN</th>
      <th style="width:5%">Volumes</th>
      <th style="width:5%">Peso Bruto</th>
      <th style="width:12.5%;">Visto Lider</th>
      <th style="width:12.5%;">Visto Transportadora</th>
    </tr>'

  
--------------------------------------------------------------------------------------------------------------  
declare @id int = 0  
WHILE EXISTS (SELECT 1 FROM #OE_Itens)
    BEGIN
        SELECT TOP 1  
            @id = cd_controle,
            @html_geral = @html_geral + 
                '<tr>
			      <td style="width:5%;">'+isnull(cd_mascara_produto,'')+'</td>
			      <td style="width:25%;">'+isnull(nm_produto,'')+'</td>
			      <td style="width:5%;">'+cast(isnull(qt_item,'') as varchar(20))+'</td>
			      <td style="width:5%;">'+isnull(sg_unidade,'')+'</td>
			      <td style="width:5%;">'+cast(isnull(qt_volume,'') as varchar(20))+'</td>
			      <td style="width:5%;">'+cast(isnull(qt_peso_bruto,'') as varchar(20))+'</td>
			      <td style="width:12.5%;"></td>
			      <td style="width:12.5%;"></td>
			     </tr>'
        FROM #OE_Itens
      

        DELETE FROM #OE_Itens WHERE cd_controle = @id
    END
--------------------------------------------------------------------------------------------------------------------  

set @html_rodape =
'</table>
  <h4 class="section-title">Conferência</h4>
<table>
  <tr>
    <td>
      <label>
        <input type="checkbox" >
        Material está embalado?
      </label>
    </td>
    <td>
      <label>
        <input type="checkbox" >
        Material está com etiqueta?
      </label>
    </td>
    <td>
      <label>
        <input type="checkbox" >
        Código das etiquetas e quantidade de peças das etiquestas estão de acordo com os códigos e quantidades faturados na nota fiscal?
      </label>
    </td>
  </tr>
</table>

  <h4 class="section-title">Observações</h4>
 <table>
  <tr>
    <td>
      <label>
        <input type="checkbox" >
        Filme de embalagem E/ou Caixas de papelão
      </label>
    </td>
    <td>
      <label>
        <input type="checkbox" >
        Etiquetas com nome do cliente, nome dos fornecedor, lote e quantidade de peças
      </label>
    </td>
    <td>
      <label>
        <input type="checkbox" >
       Código e quantidades das etiquetas x códigos e quantidades nota fiscal
      </label>
    </td>
  </tr>
</table>
<div style="display: flex; justify-content: center; text-align: center; gap: 60px; margin-top: 20px;">
  <div>
    <p><strong>Líder</strong></p><br>
   <p>Ass:____________________________</p>
   </div>
    <div>
    <p><strong>Transportadora</strong></p><br>
   <p>Ass:____________________________</p>
   </div>
</div>  
  <h4 class="section-title">Preenchimento Exclusivo Multimantas</h4>
  <table>
    <tr>
      <td>
  <div style="display: flex; justify-content: center; text-align: left; gap: 60px; margin-top: 20px;">
  <div>
    <p><strong>Horário de chegada Transportadora: </strong> '+ISNULL(@hr_chegada,'______________')+'</p><br>
   </div>
    <div>
    <p><strong>Horário de saída Transportadora: </strong> '+ISNULL(@hr_saida,'______________')+'</p><br>
   </div>
</div>  
</td>
</tr>
<tr>
  <td>Nome do Motorista: '+isnull(@nm_motorista,'')+'</td>
</tr>
<tr>
  <td>Numero Documento(RG OU CPF): '+isnull(@cd_documento_motorista,'')+'</td>
</tr>
<tr style="text-align: right;">
  <td>Data da Coleta: '+isnull(dbo.fn_data_string(@dt_coleta),'___ /___ /___')+' </td>
</tr>
</table>
 <div class="report-date-time">  
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>  
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
--exec pr_egis_relatorio_ordem_expedicao 393,0,''
------------------------------------------------------------------------------

--exec pr_egis_relatorio_padrao
--'[{
--    "cd_empresa": "236",
--    "cd_modulo": "239",
--    "cd_menu": "0",
--    "cd_relatorio": 393,
--    "cd_processo": "",
--    "cd_item_processo": "",
--    "cd_documento_form": 71,
--    "cd_item_documento_form": "0",
--    "cd_parametro": "0",
--    "cd_usuario": "4888"
--}]'