IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_manifesto' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_manifesto

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_manifesto  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_manifesto
-------------------------------------------------------------------------------  
--GBS Global Business Solution Ltda                                        2024  
-------------------------------------------------------------------------------  
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020  
--  
--Autor(es)        : Joao Pedro Marcal  
--Banco de Dados   : Egissql - Banco do Cliente   
--  
--Objetivo         : Relatorio Padrao Egis HTML - EgisMob, EgisNet, Egis  
--Data             : 10.01.2025   
--Alteração      :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_manifesto
@cd_relatorio int   = 0,  
@cd_parametro int   = 0,  
@json nvarchar(max) = ''   
  
as  
  
set @json = isnull(@json,'')  
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
declare @cd_vendedor            int = 0   
declare @cd_grupo_relatorio     int = 0  
declare @cd_departamento        int = 0 
declare @cd_carga               int = 0  
  
--Dados do Relatorio---------------------------------------------------------------------------------  
  
declare  
   @titulo                     varchar(200),  
   @logo                       varchar(400),     
   @nm_cor_empresa             varchar(20),  
   @nm_endereco_empresa        varchar(200) = '',  
   @cd_telefone_empresa        varchar(200) = '',  
   @nm_email_internet          varchar(200) = '',  
   @nm_cidade                  varchar(200) = '',  
   @sg_estado                  varchar(10)  = '',  
   @nm_fantasia_empresa		   varchar(200) = '',  
   @numero					   int = 0,  
   @dt_pedido				   varchar(60) = '',  
   @cd_cep_empresa			   varchar(20) = '',   
   @cd_cnpj_cliente			   varchar(30) = '',  
   @nm_razao_social_cliente	   varchar(200) = '',   
   @cd_numero_endereco		   varchar(20) = '',  
   @nm_condicao_pagamento	   varchar(100) = '',  
   @ds_relatorio               varchar(8000) = '',  
   @subtitulo                  varchar(40)   = '',  
   @footerTitle                varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais                    int = 0,  
   @nm_pais                    varchar(20) = '',  
   @cd_cnpj_empresa            varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet        varchar(200) = '',  
   @cd_manifesto               INT = 0
  
  
-----------------------------------------------------------------------------------------------
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
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'  
  select @dt_final               = valor from #json where campo = 'dt_final'  
  select @cd_documento           = Valor from #json where campo = 'cd_documento_form'
  select @cd_form                = Valor from #json where campo = 'cd_form'
  select @cd_manifesto           = Valor from #json where campo = 'cd_manifesto'
  
   set @cd_manifesto = isnull(@cd_manifesto,0)
  
   if isnull(@cd_manifesto,0) = 0
   begin  
     select @cd_manifesto           = valor from #json where campo = 'cd_documento_form'   
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
if @cd_form = 179
begin
  select    
    @dt_inicial       = dt_inicial,    
    @dt_final         = dt_final,
    @cd_manifesto     = ISNULL(cd_manifesto,0)
  from     
    Parametro_Relatorio    
    
  where    
    cd_relatorio = @cd_relatorio    
    and    
    cd_usuario   = @cd_usuario    
end
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

set @cd_empresa = dbo.fn_empresa()  

-------Dados da empresa-----------------------------------------------------------  
  
 select   
  @logo = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),  
  @nm_cor_empresa          = isnull(e.nm_cor_empresa,'#1976D2'),  
  @nm_endereco_empresa      = isnull(e.nm_endereco_empresa,''),  
  @cd_telefone_empresa     = isnull(e.cd_telefone_empresa,''),  
  @nm_email_internet        = isnull(e.nm_email_internet,''),  
  @nm_cidade        = isnull(c.nm_cidade,''),  
  @sg_estado        = isnull(es.sg_estado,''),  
  @nm_fantasia_empresa     = isnull(e.nm_empresa,''),  
  @cd_cep_empresa       = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),  
  @cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),  
  @nm_pais     = ltrim(rtrim(isnull(p.sg_pais,''))),  
  @cd_cnpj_empresa   = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),  
  @cd_inscestadual_empresa =  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),  
  @nm_dominio_internet  =  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))  
        
 from egisadmin.dbo.empresa e with(nolock)  
 left outer join Estado es  with(nolock) on es.cd_estado = e.cd_estado  
 left outer join Cidade c  with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado  
 left outer join Pais p   with(nolock) on p.cd_pais = e.cd_pais  
 where   
  cd_empresa = @cd_empresa  
  
  
---------------------------------------------------------------------------------------------------------------------------------------------  
--Dados do Relatorio  
---------------------------------------------------------------------------------------------------------------------------------------------  
  
declare @html            nvarchar(max) = '' --Total  
declare @html_empresa    nvarchar(max) = '' --Cabecalho da Empresa  
declare @html_titulo     nvarchar(max) = '' --Titulo  
declare @html_cab_det    nvarchar(max) = '' --Cabecalho do Detalhe  
declare @html_detalhe    nvarchar(max) = '' --Detalhes  
declare @html_rod_det    nvarchar(max) = '' --Rodape do Detalhe  
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
    <title >'+isnull(@titulo,'')+'</title>  
	<script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.6/dist/JsBarcode.all.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
 <style>
    body {
      font-family: Arial, sans-serif;
      color: #333;
      padding: 20px;
      font-size: 12px;
    }
    body, table, td, th, p, div, span, input, label, h1, h2, h3, h4, h5, h6 {
  font-size: 14px !important;
}

    .section-title {
      background-color: #1976D2;
      color: white;
      padding: 5px;
      margin-bottom: 10px;
      border-radius: 5px;
      font-size: 100%;
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

    .report-date-time {
      text-align: right;
      margin-bottom: 5px;
      margin-top: 50px;
    }

    .linha-campos {
      display: flex;
      justify-content: space-between;
      gap: 20px;
      margin-bottom: 10px;
      background-color: #468ed6;
    }

    .campo {
      text-align: center;
      font-family: Arial, sans-serif;
    }

    .campo p {
      margin: 4px 0;
    }

    .campo .titulo {
      font-weight: bold;
    }

    .campo .valor {
      font-size: 12px;
    }

    .container {
      display: flex;
      justify-content: space-between;
      margin: 20px;
    }

    .sectiont {
      display: flex;
      flex-direction: column;
      width: 48%;
    }

    #barcode {
      width: 100%;
      height: 60px;
      margin: 10px 0;
    }

    .titlet {
      font-weight: bold;
      margin-bottom: 10px;
    }

    .row {
      display: flex;
      justify-content: space-between;
      padding-bottom: 5px;
      margin-bottom: 5px;
    }

    .label {
      font-weight: bold;
      width: 50%;
    }

    .value {
      width: 50%;
    }

    .container {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
    }

    .left-section {
      width: 60%;
    }

    .right-section {
      width: 38%;
      text-align: center;
    }

    .title {
      text-align: center;
      font-weight: bold;
      margin-bottom: 10px;
    }

    .table {
      display: flex;
      background-color: #eee;
      font-weight: bold;
      padding: 5px;
    }

    .table .cell {
      flex: 1;
      text-align: center;
    }

    .table-values {
      display: flex;
      padding: 5px;
    }

    .table-values .cell {
      flex: 1;
      text-align: center;
    }

    .protocol {
      margin-top: 15px;
      font-weight: bold;
    }

    .protocol span {
      font-weight: normal;
      margin-left: 10px;
    }

    .barcode {
      width: 100%;
      height: 60px;
      background-color: #000;
      margin: 10px 0;
    }

    .access-key {
      font-weight: bold;
    }

    .nf-container {
      width: 100%;
    }

    .parteAzul{
      display: flex;
      justify-content: space-between;
      margin-bottom: 10px;
      font-weight: bold;
    }
    .nf-wrapper {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
    gap: 6px;
}

.nf-item {
  width: 48%;
  display: flex;
  font-size: 12px !important;
  margin-bottom: 4px;
}

    @media print {
      body {
        padding: 0;
      }

      .nf-item {
        page-break-inside: avoid;
        break-inside: avoid;
        margin-top:10px;
      }
      thead {
         display: table-header-group; 
      }

}
</style>
</head>  
<body> 
  <table style="width: 100%;">
	<thead>
      <tr style="display: flex; justify-content: space-between; align-items:center">
	  	<td style=" margin-right:20px">
	  		<img src="'+@logo+'" alt="Logo da Empresa">
	  	</td>
	  	<td style=" padding-left:10px">
	  		<p class="title" style="text-align: left;">'+@nm_fantasia_empresa+'</p>
	  	    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
	  	    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
	  	    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
	    </td>
		<td>
			<div id="qrcode"></div>
        </td>
      </tr>'  
  
  
--Procedure de Cada Relatorio-------------------------------------------------------------------------------------  
    
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
    
order by    
  qt_ordem_atributo    
    
------------------------------------------------------------------------------------------------------------------    

select * into #AuxRelAtributo from #RelAtributo    
where    
  cd_grupo_relatorio = @cd_grupo_relatorio    
    
order by qt_ordem_atributo    

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
     
    
drop table #AuxRelAtributo    
    
    
if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    
	declare 
		@cd_cidade_cli int = 0,
		@nm_cidade_cli nvarchar(50)

------------------------------------------------------------------------------------------------------------
--select * from MDFE_Emitente
--select * from MDFE_Manifesto where cd_manifesto = 5135
--select * from MDFE_Manifesto_Documentos where cd_manifesto = 5135--parte do while com o documentos
--select * from MDFE_Manifesto_Percurso --vazia
--select * from MDFE_Manifesto_Rodoviario --vazia
--select * from MDFE_Manifesto_Seguradora --vazia
--select * from MDFE_Manifesto_XML --vazia
--select * from MDFE_Modal
--select * from MDFE_Serie_Manifesto
--select * from MDFE_Status
--select * from MDFE_Tipo_Transportador
--select * from MDFE_Versao
select 
    IDENTITY(int,1,1)				        as cd_controle,
	m.cd_manifesto					        as cd_manifesto,
	m.cd_identificacao						as cd_identificacao,
	m.dt_manifesto					        as dt_manifesto,
	m.cd_serie_manifesto			        as cd_serie_manifesto,
	m.cd_chave_acesso				        as cd_chave_acesso_doc,
	md.cd_chave_acesso				        as cd_chave_acesso,
	m.qt_total_nfe					        as qt_total_nfe,
	m.qt_peso_total					        as qt_peso_total,
	ed.sg_estado                            as sg_estado_destino,
    eef.sg_estado                           as sg_estado,
	cid.cd_cidade					        as cd_cidade,
	cid.nm_cidade					        as nm_cidade,
	v.cd_placa_veiculo				        as cd_placa_veiculo,
	mo.cd_cpf_motorista				        as cd_cpf_motorista,
	mo.nm_motorista					        as nm_motorista,
	ms.nm_apolice					        as nm_apolice,
	ms.nm_responsavel				        as nm_responsavel,
    ev.sg_estado                            as sg_estado_veiculo,
	mr.cd_rntrc                             as cd_rntrc

	into 
	#RelManifesto

from MDFE_Manifesto m
  left outer join Estado eef   with(nolock)    on eef.cd_estado    = m.cd_estado  
  left outer join Estado ed   with(nolock)     on ed.cd_estado      = m.cd_estado_destino  
  left outer join veiculo v                    on v.cd_veiculo     = m.cd_veiculo
  left outer join Estado ev   with(nolock)     on ev.cd_estado     = v.cd_estado  
  left outer join motorista mo                 on mo.cd_motorista  = m.cd_motorista
  left outer join mdfe_manifesto_rodoviario mr on mr.cd_manifesto  = m.cd_manifesto
  left outer join MDFE_Manifesto_Seguradora ms on ms.cd_manifesto  = m.cd_manifesto
  left outer join MDFE_Manifesto_Documentos md on md.cd_manifesto  = m.cd_manifesto
  left outer join nota_saida ns        with (nolock) on ns.cd_nota_saida     = md.cd_nota_saida               
  left outer join vw_destinatario vw   with (nolock) on vw.cd_tipo_destinatario = ns.cd_tipo_destinatario and                    
                                                        vw.cd_destinatario      = ns.cd_cliente                         
  left outer join cidade cid           with (nolock) on cid.cd_cidade           = vw.cd_cidade  and              
                                                        cid.cd_estado           = vw.cd_estado   
  
--  left outer join nota_saida n                 on n.cd_nota_saida   = md.cd_nota_saida  
  where 
	m.cd_manifesto = @cd_manifesto --case when isnull(@cd_manifesto,0) = 0 then m.cd_manifesto else isnull(@cd_manifesto,0) end  
	--and 
	--m.dt_manifesto between '2025-01-01 00:00:00.000' and '2025-05-30 00:00:00.000'
	--and 
	--md.cd_chave_acesso is not null
	--and 
	--m.cd_cidade is not null
	--select
 select 
	identity(int,1,1) as cd_controle,
	cd_cidade as cd_cidade_cli,
	max(nm_cidade) as nm_cidade_cli
	into
	#cidadeManifesto
 from #RelManifesto
 group by
	cd_cidade
 --select * from #RelManifesto
 --nm_cidade_nota_saida nm_cidade_nota_saida


------------------------------------------------------------------------------------------------------------
DECLARE 

   @dt_manifesto        datetime,
   @cd_serie_manifesto  VARCHAR(20),
   @cd_chave_acesso     VARCHAR(50),
   @qt_total_nfe        INT,
   @qt_peso_total       DECIMAL(18,2),
   @cd_chave_acesso_doc varchar(50),
   @sg_estado_cliente   CHAR(2),
   @sg_estado_destino   CHAR(2),
   @sg_estado_veiculo   char(2),
   @nm_cidade_cliente   VARCHAR(100),
   @cd_placa_veiculo    VARCHAR(10),
   @cd_cpf_motorista    VARCHAR(14),
   @nm_motorista        VARCHAR(100),
   @nm_apolice          VARCHAR(50),
   @nm_responsavel      VARCHAR(100),
   @cd_rntrc            int = 0,
   @cd_identificacao    int = 0 

select 
	@dt_manifesto        = dt_manifesto,
	@cd_serie_manifesto  = cd_serie_manifesto,
	@cd_chave_acesso_doc = cd_chave_acesso_doc,
	@cd_chave_acesso     = cd_chave_acesso,
	@qt_total_nfe        = qt_total_nfe,
	@qt_peso_total       = qt_peso_total,
	@sg_estado_cliente   = sg_estado,
	@sg_estado_destino   = sg_estado_destino,
	@sg_estado_veiculo   = sg_estado_veiculo,
	@nm_cidade_cliente   = nm_cidade,
	@cd_placa_veiculo    = cd_placa_veiculo,
	@cd_cpf_motorista    = cd_cpf_motorista,
	@nm_motorista        = nm_motorista,
	@nm_apolice          = nm_apolice,
	@nm_responsavel      = nm_responsavel,
	@cd_rntrc            = cd_rntrc,
	@cd_identificacao    = cd_identificacao
from
	#RelManifesto
------------------------------------------------------------------------------------------------------------   
set @html_geral = '<td><strong>DAMDFE </strong>Documento Auxiliar de Manifesto Eletrônico de Documentos Fiscais</td>
     <tr>
    <td style="background-color: #468ed6;">
      <table style="width:100%; border-collapse:collapse;">
        <tr class="parteAzul">
          <td style="background-color: #468ed6;width:100%" >modelo</td>
          <td style="background-color: #468ed6;width:100%">Série</td>
          <td style="background-color: #468ed6;width:100%">Número</td>
          <td style="background-color: #468ed6;width:100%">Emissão</td>
          <td style="background-color: #468ed6;width:100%">UF Carrega</td>
          <td style="background-color: #468ed6;width:100%">UF Descarga</td>
        </tr>
		<tr class="parteAzul">
          <td style="background-color: #468ed6;width:100% ">58</td>
          <td style="background-color: #468ed6;width:100%">'+ISNULL(@cd_serie_manifesto,'')+'</td>
          <td style="background-color: #468ed6;width:100%">'+CAST(isnull(@cd_identificacao,0)as nvarchar(10))+'</td>
          <td style="background-color: #468ed6;width:100%">'+isnull(dbo.fn_data_string(@dt_manifesto),'')+'</td>
          <td style="background-color: #468ed6;width:100%">'+isnull(@sg_estado,0) +'</td>
          <td style="background-color: #468ed6;width:100%">'+isnull(@sg_estado_destino,0) +'</td>
        </tr>
      </table>
    </td>
  </tr>
</thead>
 <tbody>
    <tr>
      <td colspan="3">
    <div class="container">
    <div class="left-section">
      <div class="title">MODAL RODOVIÁRIO DE CARGA</div>
      <div class="table">
        <div class="cell">QTDE CT-e</div>
        <div class="cell">QTDE NF-e</div>
        <div class="cell">PESO TOTAL (Kg)</div>
      </div>

      <div class="table-values">
        <div class="cell"></div>
        <div class="cell">'+CAST(isnull(@qt_total_nfe,0)as nvarchar(20))+'</div>
        <div class="cell">'+CAST(isnull(@qt_peso_total,0)as nvarchar(20))+'</div>
      </div>

      <div class="protocol" style="text-align: left;">
        Protocolo de autorização de uso<br>
        951250012780583 05/05/2025 13:58:47
      </div>
    </div>

    <div class="right-section">
      <div class="title">Controle do Fisco</div>
      <svg id="barcode"></svg> 
        <p style="font-size: 9px;text-align:center;">Consulte em: https://dfe-portal.sefazvirtual.rs.gov.br/MDFe/consulta</p>
      </div>
    </div>
  </div>

    <div class="container">  
    <div class="sectiont">
      <div class="titlet">Veículo</div>
      <div class="row" style="border-bottom: 2px solid #ccc;">
        <div class="label">Placa</div>
        <div class="label">RNTRC</div>
      </div>
      <div class="row">
        <div class="value">'+isnull(@cd_placa_veiculo,'')+' '+isnull(@sg_estado_veiculo,'')+'</div>
        <div class="value">'+CAST(isnull(@cd_rntrc,0) as nvarchar(20))+'</div>
      </div>
    </div>'

set @html_cab_det =    '<div class="sectiont">
      <div class="titlet">Condutor</div>
      <div class="row" style="border-bottom: 2px solid #ccc;">
        <div class="label">CPF</div>
        <div class="label">Nome</div>
      </div>
      <div class="row">
        <div class="value">'+isnull(dbo.fn_formata_cpf(@cd_cpf_motorista),'')+'</div>
        <div class="value">'+isnull(@cd_placa_veiculo,'')+'</div>
      </div>
    </div>
  </div>

<div class="container">  
  <div class="sectiont">
    <div class="titlet">Vale Pedágio</div>
    <div class="row" style="border-bottom: 2px solid #ccc;">
      <div class="label">Responsável CNPJ</div>
      <div class="label">Fornecedor CNPJ</div>
      <div class="label">N. Comprovante</div>
    </div>
    <div class="row">
      <div class="value"></div>
      <div class="value"></div>
      <div class="value"></div>
    </div>
  </div>

  <div class="sectiont">
    <div class="titlet">Responsável pelo Seguro</div>
    <div class="row" style="border-bottom: 2px solid #ccc;">
      <div class="label">Nome da Seguradora</div>
      <div class="label">Número da Apólice</div>
    </div>
    <div class="row">
      <div class="value">'+isnull(@nm_responsavel,'')+'</div>
      <div class="value">'+isnull(@nm_apolice,'')+'</div>
    </div>
  </div>
</div>
  <h4 style="text-align: center;font-weight: bold;">Relação dos Documentos Fiscais Eletrônicos</h4>
  <div class="container">  
    <div class="sectiont">
      <div class="row" style="border-bottom: 2px solid #ccc;">
        <div class="label">Tp. Doc.</div>
        <div class="label">CNPJ/CPF Emitente Série/Nro. Documento</div>
      </div>
    </div>
    <div class="sectiont">
      <div class="row" style="border-bottom: 2px solid #ccc;">
        <div class="label">Tp. Doc.</div>
        <div class="label">CNPJ/CPF Emitente Série/Nro. Documento</div>
      </div>
    </div>
  </div>'

declare @sub_id int = 0 
declare @id int = 0 
while exists( select Top 1 cd_controle from #cidadeManifesto)
  begin

  select Top 1
    @sub_id = cd_controle,
    @cd_cidade_cli = cd_cidade_cli,
	@nm_cidade_cli = nm_cidade_cli

  from #cidadeManifesto	

set @html_cab_det = @html_cab_det +'     
   <div>
      <h4><b>Município de Descarregamento: '+isnull(@nm_cidade_cli,'Sem Cidade Registrada')+'</b></h4>
   </div>
	 <div class="nf-wrapper">'							
   
--------------------------------------------------------------------------------------------------------------------------

  while exists ( select top 1 cd_controle from #RelManifesto where cd_cidade = @cd_cidade_cli)
  begin

    select top 1
      
      @id           = cd_controle,
      @html_cab_det = @html_cab_det + '
            
			   <div class="nf-item">NF-e '+ISNULL(cd_chave_acesso,'')+'</div>'

     from
       #RelManifesto

     where
       cd_cidade = @cd_cidade_cli

  delete from #RelManifesto
  where
   cd_cidade = @cd_cidade_cli and cd_controle = @id 
  end
--------------------------------------------------------------------------------------------------------------------------
   delete from #cidadeManifesto
   where
      cd_controle = @sub_id
	   
	   SET @html_cab_det = @html_cab_det + '
	   </div>'
end
--------------------------------------------------------------------------------------------------------------------------
set @html_rodape ='   
    <div class="report-date-time">    
       <p >Gerado em: '+@data_hora_atual+'</p>    
    </div>

 <script>
  const chaveAcesso = "'+isnull(@cd_chave_acesso_doc,0)+'";
  const url = "https://dfe-portal.svrs.rs.gov.br/Mdfe/QrCode?chMDFe=" + chaveAcesso + "&tpAmb=1&sign=0PwAHkOGTwpy4aWvx%2FD8R2KXCeE%3D";

  new QRCode(document.getElementById("qrcode"), {
    text: url,
    width: 128,
    height: 128
  });

  document.addEventListener("DOMContentLoaded", function () {
    JsBarcode("#barcode", chaveAcesso, {
      format: "CODE128",
      lineColor: "#000",
      width: 2,
      height: 50,
      displayValue: true
    });
  });
</script> </body>    
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
   

  
GO

--exec pr_egis_relatorio_padrao '[{"cd_documento_form": 4910, "cd_empresa": 342, "cd_item_documento_form": "0", "cd_item_processo": "", "cd_menu": 8118, "cd_modulo": 212, "cd_parametro": "0", "cd_processo": "", "cd_relatorio": 332, "cd_usuario": 4605}]'
