IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_contrato_pagar' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_contrato_pagar

GO
-------------------------------------------------------------------------------    
--sp_helptext pr_egis_relatorio_contrato_pagar    
-------------------------------------------------------------------------------    
--pr_egis_relatorio_contrato_pagar    
-------------------------------------------------------------------------------    
--GBS Global Business Solution Ltda                                        2024    
-------------------------------------------------------------------------------    
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020    
--    
--Autor(es)        : Alexandre Santos Adabo    
--    
--Banco de Dados   : Egissql - Banco do Cliente     
--    
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis    
--Data             : 08.10.2024    
--Alteração        :     
--    
--    
------------------------------------------------------------------------------    
create procedure pr_egis_relatorio_contrato_pagar    
@cd_relatorio int   = 0,       
@json varchar(8000) = ''     
    
--with encryption    
--use egissql_317    
    
as    
    
set @json = isnull(@json,'')    
declare @cd_usuario             int = 0
declare @cd_empresa             int = 0    
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
declare @dt_hoje                varchar(20)    
declare @dt_inicial             datetime    
declare @dt_final               datetime    
declare @cd_ano                 int        
declare @cd_mes                 int        
declare @cd_dia                 int    
declare @cd_grupo_relatorio     int    
declare @cd_controle            int    
declare @id                     int = 0    
    
    
--declare @cd_relatorio           int = 0    
    
--Dados do Relatório---------------------------------------------------------------------------------    
    
     declare    
            @titulo                     varchar(200),    
      @logo                       varchar(400),       
   @nm_cor_empresa             varchar(20),    
   @nm_endereco_empresa       varchar(200) = '',    
   @cd_telefone_empresa     varchar(200) = '',    
   @nm_email_internet      varchar(200) = '',    
   @nm_cidade        varchar(200) = '',    
   @sg_estado        varchar(10)  = '',    
   @nm_fantasia_empresa     varchar(200) = '',    
   @numero         int = 0,    
   @dt_pedido        varchar(60) = '',    
   @cd_cep_empresa       varchar(20) = '',    
   @cd_cliente        int = 0,    
   @nm_fantasia_cliente       varchar(200) = '',    
   @cd_cnpj_cliente      varchar(30) = '',    
   @nm_razao_social_cliente varchar(200) = '',    
   @nm_endereco_cliente  varchar(200) = '',    
   @nm_bairro     varchar(200) = '',    
   @nm_cidade_cliente   varchar(200) = '',    
   @sg_estado_cliente   varchar(5) = '',    
   @cd_numero_endereco   varchar(20) = '',    
   @cd_telefone    varchar(20) = '',    
   @nm_condicao_pagamento  varchar(100) = '',    
   @ds_relatorio    varchar(8000) = '',    
   @subtitulo     varchar(40)   = '',    
   @footerTitle    varchar(200)  = '',    
   @vl_total_ipi    float         = 0,    
   @sg_tabela_preco            char(10)      = '',    
   @cd_empresa_faturamento     int           = 0,    
   @nm_fantasia_faturamento    varchar(30)   = '',    
   @cd_tipo_pedido             int           = 0,    
   @nm_tipo_pedido             varchar(30)   = '',    
   @cd_vendedor                int           = 0,    
   @nm_fantasia_vendedor       varchar(500)   = '',    
   @nm_telefone_vendedor       varchar(30)   = '',    
   @nm_email_vendedor          varchar(300)  = '',    
   @nm_contato_cliente   varchar(200)  = '',    
   @cd_numero_endereco_empresa varchar(20)   = '',    
   @cd_pais     int = 0,    
   @nm_pais     varchar(20) = '',    
   @cd_cnpj_empresa   varchar(60) = '',    
   @cd_inscestadual_empresa    varchar(100) = '',    
   @nm_dominio_internet  varchar(200) = '',    
   @nm_status     varchar(100) = '',    
   @ic_empresa_faturamento  char(1) = ''    
            
--------------------------------------------------------------------------------------------------------    
    
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)            
--set @cd_parametro      = 0    
set @cd_modulo         = 0    
set @cd_empresa        = 0    
set @cd_menu           = 0    
set @cd_processo       = 0    
set @cd_item_processo  = 0    
set @cd_form           = 0    
--set @cd_documento      = 0    
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
  select @cd_documento           = valor from #json where campo = 'cd_contrato_pagar' 
  select @id                     = valor from #json where campo = 'id'
  
  if @cd_documento is null or isnull(@cd_documento,0) = 0
  begin  
    
    select @cd_documento = valor from #json where campo = 'cd_documento_form';  
    
    if isnull(@cd_documento,0) = 0
    begin
      select @cd_documento = valor from #json where campo = 'cd_documento';  
    end
  end
  
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'    
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'    
    
    
   set @cd_documento = isnull(@cd_documento,0)    
    
   if @cd_documento = 0    
   begin    
     select @cd_documento           = valor from #json where campo = 'cd_documento'    
     select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'       
   end    
    
end    
    
    
-------------------------------------------------------------------------------------------------    
declare @ic_processo char(1) = 'N'    
----------------------------------     
    
select    
  @titulo             = nm_relatorio,    
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),    
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)    
from    
  egisadmin.dbo.Relatorio    
where    
  cd_relatorio = @cd_relatorio    
    
----------------------------------------------------------------------------------------------------------------------------    

if @cd_form = 183
begin
select    
	@cd_documento = cd_contrato_pagar    
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
----------------------------------    
set @cd_empresa = dbo.fn_empresa()    
-----------------------------------    
    
 --Dados da empresa-----------------------------------------------------------    
    
 select     
  @logo = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),    
  @nm_cor_empresa          = case when isnull(e.nm_cor_empresa,'')<>'' then isnull(e.nm_cor_empresa,'#1976D2') else '#1976D2' end,  
  @nm_endereco_empresa      = isnull(e.nm_endereco_empresa,''),    
  @cd_telefone_empresa     = isnull(e.cd_telefone_empresa,''),    
  @nm_email_internet        = isnull(e.nm_email_internet,''),    
  @nm_cidade        = isnull(c.nm_cidade,''),    
  @sg_estado        = isnull(es.sg_estado,''),    
  @nm_fantasia_empresa     = isnull(e.nm_fantasia_empresa,''),    
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
--Dados do Relatório    
---------------------------------------------------------------------------------------------------------------------------------------------    
    
declare @html            varchar(max) = '' --Total    
declare @html_empresa    varchar(max) = '' --Cabeçalho da Empresa    
declare @html_grafico    varchar(max) = '' --Gráfico    
declare @html_titulo     varchar(max) = '' --Título    
declare @html_cab_det    varchar(max) = '' --Cabeçalho do Detalhe    
declare @html_detalhe    varchar(max) = '' --Detalhes    
declare @html_rod_det    varchar(max) = '' --Rodapé do Detalhe    
declare @html_rodape     varchar(max) = '' --Rodape    
declare @html_totais     varchar(max) = '' --Totais    
declare @html_geral      varchar(max) = '' --Geral    
    
declare @titulo_total    varchar(500)  = ''    
    
declare @data_hora_atual varchar(50)  = ''    
    
set @html         = ''    
set @html_empresa = ''    
set @html_grafico = ''    
set @html_titulo  = ''    
set @html_cab_det = ''    
set @html_detalhe = ''    
set @html_rod_det = ''    
set @html_rodape  = ''    
    
-- Obtém a data e hora atual    
set @data_hora_atual = convert(varchar, getdate(), 103) + ' ' + convert(varchar, getdate(), 108)    
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
            margin-bottom: 10px;    
        }    
        table, th, td {    
            border: 1px solid #ddd;    
        }    
        th, td {    
            padding: 5px;    
            text-align: center;   
			font-size:14px;
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
   font-size:14px;
  }    
    </style>    
</head>    
<body>  
    <table>  
        <tr>  
            <td style="width: 20%; text-align: center;"> <img src="'+@logo+'"  
                    alt="Logo da Empresa"> </td>  
            <td style="width: 60%; text-align: left;">  
                <p class="title">'+@nm_fantasia_empresa+'</p>  
                <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>  
                <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa +'</p>  
                <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>  
            </td>  
  '   
    
--select @html_empresa    
     
    
--Detalhe--    
    
--Procedure de Cada Relatório-------------------------------------------------------------------------------------    
    
declare @cd_item_relatorio  int           = 0    
declare @nm_cab_atributo    varchar(100)  = ''    
declare @nm_dados_cab_det   varchar(8000) = ''    
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

--set @cd_documento = 7


select
  cs.*,
  sc.nm_status_contrato             as nm_status_contrato,
  s.nm_servico                      as nm_servico,
  ap.nm_aplicacao_produto           as nm_aplicacao_produto,
  pf.nm_conta_plano_financeiro      as nm_plano_financeiro,
  cc.nm_centro_custo                as nm_centro_custo,
  cp.nm_condicao_pagamento          as nm_condicao_pagamento,
--  tc.nm_tipo_conta_pagar            as nm_tipo_conta_pagar,
--  opf.nm_operacao_fiscal            as nm_operacao_fiscal,
  tcpp.nm_tipo_conta_pagar          as nm_tipo_conta_pagar,
  opf.cd_mascara_operacao           as cd_mascara_operacao,
  isnull(tr.nm_tipo_reajuste,'')    as nm_tipo_reajuste,
  isnull(tco.nm_tipo_contrato,'')   as nm_tipo_contrato,
  isnull(d.nm_departamento,'')      as nm_departamento,
  isnull(vw.nm_fantasia_usuario,'') as nm_fantasia_gestor,
  isnull(ef.nm_empresa,'')          as nm_empresa,
  opf.nm_operacao_fiscal            as nm_operacao_fiscal
--  cp.nm_condicao_pagamento          as nm_condicao_pagamento
  into
  #contratoPagarRel
from
  Contrato_Pagar cs                      with(nolock)
  left outer join Fornecedor f           with(nolock) on f.cd_fornecedor          = cs.cd_fornecedor
  left outer join Status_Contrato sc     with(nolock) on sc.cd_status_contrato    = cs.cd_status_contrato
  left outer join Servico s              with(nolock) on s.cd_servico             = cs.cd_servico
  left outer join Plano_Financeiro pf    with(nolock) on pf.cd_plano_financeiro   = cs.cd_plano_financeiro
  left outer join Centro_Custo cc        with(nolock) on cc.cd_centro_custo       = cs.cd_centro_custo
  left outer join Condicao_Pagamento cp  with(nolock) on cp.cd_condicao_pagamento = cs.cd_condicao_pagamento
  left outer join Tipo_Conta_Pagar tc    with(nolock) on tc.cd_tipo_conta_pagar   = cs.cd_tipo_conta_pagar
  left outer join Operacao_Fiscal opf    with(nolock) on opf.cd_operacao_fiscal   = cs.cd_operacao_fiscal
  left outer join Tipo_Reajuste tr       with(nolock) on tr.cd_tipo_reajuste      = cs.cd_tipo_reajuste
  left outer join Tipo_Contrato tco      with(nolock) on tco.cd_tipo_contrato     = cs.cd_tipo_contrato
  left outer join Departamento d         with(nolock) on d.cd_departamento        = cs.cd_departamento
  left outer join vw_usuario_oficial vw               on vw.cd_usuario            = cs.cd_usuario_contrato  
  left outer join Empresa_Faturamento ef with(nolock) on ef.cd_empresa            = cs.cd_empresa 
  left outer join aplicacao_produto ap   with(nolock) on ap.cd_aplicacao_produto  = cs.cd_aplicacao_produto
  left outer join tipo_conta_pagar tcpp  with(nolock) on tcpp.cd_tipo_conta_pagar = cs.cd_tipo_conta_pagar
where
  cs.cd_contrato_pagar = @cd_documento
order by 
  cd_contrato_pagar desc

  select 
    identity(int,1,1) as cd_controle,
  	cp.dt_parc_contrato as dt_parc_contrato,
	cp.vl_parc_contrato as vl_parc_contrato,
	cp.nm_parc_contrato as nm_parc_contrato,
	dp.cd_identificacao_document as cd_identificacao_document,
	dp.cd_pedido_compra as cd_pedido_compra,
	cp.cd_nota_entrada as cd_nota_entrada
	
	into 
	#contratoPagar
  from 
	 contrato_pagar_composicao cp
	 left outer join documento_pagar dp on dp.cd_documento_pagar = cp.cd_documento_pagar 

   where
    cp.cd_contrato_pagar = @cd_documento

DECLARE @nm_contrato_pagar           VARCHAR(200)
DECLARE @cd_identificacao_contrato   VARCHAR(50)
DECLARE @dt_emissao_contrato         datetime
DECLARE @nm_condicao_pagamento_cli   VARCHAR(50)
DECLARE @nm_fantasia_fornecedor      VARCHAR(200)
DECLARE @nm_status_contrato          VARCHAR(100)
DECLARE @nm_centro_custo             VARCHAR(200)
DECLARE @nm_aplicacao_produto        VARCHAR(200)
DECLARE @nm_plano_financeiro         VARCHAR(200)
DECLARE @nm_tipo_conta_pagar         VARCHAR(100)

DECLARE @nm_operacao_fiscal          VARCHAR(100)
DECLARE @nm_tipo_reajuste            VARCHAR(100)
DECLARE @nm_tipo_contrato            VARCHAR(100)
DECLARE @nm_departamento             VARCHAR(100)
DECLARE @nm_fantasia_gestor          VARCHAR(200)
DECLARE @nm_empresa                  VARCHAR(200)

DECLARE @dt_inicio_contrato          datetime
DECLARE @dt_fim_contrato             datetime
DECLARE @cd_pedido_compra            INT =0
DECLARE @dt_vcto_1p_contrato_pagar   DATE

DECLARE @qt_parcela                  INT =0 
DECLARE @vl_parcela_contrato         DECIMAL(18,2)
DECLARE @vl_total_contrato_pagar     DECIMAL(18,2)
DECLARE @cd_condicao_pagamento       INT =0
DECLARE @ds_historico_contrato       VARCHAR(8000)


select     
	@nm_contrato_pagar           = nm_contrato_pagar,          
    @cd_identificacao_contrato	 = cd_identificacao_contrato,	
	@dt_emissao_contrato      	 = dt_emissao_contrato,      	   
    @nm_fantasia_fornecedor      = nm_fantasia_fornecedor,     
    @nm_status_contrato       	 = nm_status_contrato,       	
	@nm_condicao_pagamento_cli   = nm_condicao_pagamento,
	@cd_condicao_pagamento       = cd_condicao_pagamento,
    @nm_centro_custo          	 = nm_centro_custo,          	
    @nm_aplicacao_produto     	 = nm_aplicacao_produto,     	
    @nm_plano_financeiro      	 = nm_plano_financeiro,      	
    @nm_tipo_conta_pagar      	 = nm_tipo_conta_pagar,      	
    @nm_operacao_fiscal          = nm_operacao_fiscal,         
    @nm_tipo_reajuste         	 = nm_tipo_reajuste,         	
    @nm_tipo_contrato         	 = nm_tipo_contrato,         	
    @nm_departamento          	 = nm_departamento,          	
    @nm_fantasia_gestor       	 = nm_fantasia_gestor,       	
    @nm_empresa                  = nm_empresa,                 
    @dt_inicio_contrato       	 = dt_inicio_contrato,       	
    @dt_fim_contrato          	 = dt_fim_contrato,          	
    @cd_pedido_compra            = cd_pedido_compra,           
    @dt_vcto_1p_contrato_pagar	 = dt_vcto_1p_contrato_pagar,	
    @qt_parcela               	 = qt_parcela_contrato_pagar,               	
    @vl_parcela_contrato      	 = vl_parcela_contrato,      	
    @vl_total_contrato_pagar     = vl_total_contrato_pagar,    
    @ds_historico_contrato    	 = ds_historico_contrato    	
    
from #contratoPagarRel    
  
--Gráfico----------------------------------------------------------------------------------------------------------    
set @html_geral = '  

  </tr>  
    </table>  
    <h3 class="section-title" style=" text-align: center;">'+@titulo+': '+cast(isnull(@cd_documento,0) as nvarchar(20))+'</h3>  
  <table style="width: 100%;">
    <tr>
      <td style="display: flex; flex-direction: column; gap: 20px;">
        <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
          <p><strong>Contrato:</strong> '+isnull(@nm_contrato_pagar,'')+'</p>
          <p><strong>Identificação: </strong>'+isnull(@cd_identificacao_contrato,'')+'</p>
          <p><strong>Data: </strong>'+isnull(dbo.fn_data_string(@dt_emissao_contrato),'')+'</p>
        </div>
      </td>
    </tr>
  </table>
  <table style="width: 100%;">
    <tr>
      <td style="display: flex; flex-direction: column; gap: 5px;">
        <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
          <div style="text-align: left; width: 50%;">
            <p><strong>Fornecedor:</strong> '+isnull(@nm_fantasia_fornecedor,'')+'</p> 
            <p><strong>Status:</strong> '+isnull(@nm_status_contrato,'')+'</p>
            <p><strong>Centro Custo:</strong> '+isnull(@nm_centro_custo,'')+'</p>
            <p><strong>Aplicação:</strong> '+isnull(@nm_aplicacao_produto,'')+'<p></p>
            <p><strong>Plano Financeiro:</strong> '+isnull(@nm_plano_financeiro,'')+'<p>
            <p><strong>Classificação:</strong> '+isnull(@nm_tipo_conta_pagar,'')+'</p>
          </div>
          <div style="text-align: left;width: 50%;">
            <p><strong>Operação Fiscal:</strong> '+isnull(@nm_operacao_fiscal,'')+'</p> 
            <p><strong>Tipo de Reajuste:</strong> '+isnull(@nm_tipo_reajuste,'')+'</p>
            <p><strong>Tipo de Contrato:</strong> '+isnull(@nm_tipo_contrato,'')+'</p>
            <p><strong>Departamento:</strong> '+isnull(@nm_departamento,'')+'</p>
            <p><strong>Gestor:</strong> '+isnull(@nm_fantasia_gestor,'')+'</p> 
            <p><strong>Empresa Faturamento:</strong> '+isnull(@nm_empresa,'')+'</p>
          </div>
        </div>
      </td>
    </tr>
  </table>
  <h3 class="section-title">Produtos</h3>
  <table>
    <tr>
      <th>Parcela</th>
      <th>Data</th>
      <th>Valor</th>
      <th>Documento</th>
	  <th>Pedido Compra</th>
	  <th>Nota Entrada</th>
    </tr>'
-----------------------------------------------------------------------------------------
--declare @id int = 0   
while exists ( select cd_controle from #contratoPagar )    
begin    
    
  select top 1    
    @id           = cd_controle,    
    @html_geral = @html_geral + '    
           <tr>        
               <td>'+cast(ISNULL(nm_parc_contrato, 0) as varchar(4))+'</td>  
			   <td>'+ISNULL(dbo.fn_data_string(dt_parc_contrato), '')+'</td> 
			   <td>'+ISNULL(dbo.fn_formata_valor(vl_parc_contrato), 0)+'</td> 
			   <td>'+cast(ISNULL(cd_identificacao_document, 0) as varchar(30))+'</td>   
			   <td>'+cast(ISNULL(cd_pedido_compra, 0) as varchar(30))+'</td>
			   <td>'+cast(ISNULL(cd_nota_entrada, 0) as varchar(30))+'</td>
           </tr>'    
           
  from    
    #contratoPagar    
    
  order by    
    cd_controle    
        
  
  
  delete from #contratoPagar  where  cd_controle = @id    
    
    
end    
         
set @html_rodape =  
'<table style="width: 100%;">
      <tr>
        <td style="display: flex; flex-direction: column; gap: 20px;">
          <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
            <div style="text-align: left; width: 45%;">
              <p><strong>Data - Inicial:</strong> '+isnull(dbo.fn_data_string(@dt_inicio_contrato),'')+'</p>
              <p><strong>Data - Final: </strong> '+isnull(dbo.fn_data_string(@dt_fim_contrato),'')+'</p>
              <p><strong>Pedido Compra:</strong> '+cast(isnull(@cd_pedido_compra,0) as varchar(20))+' </p>
              <p><strong>Vencimento 1º Parcela:</strong>'+isnull(dbo.fn_data_string(@dt_vcto_1p_contrato_pagar),'')+'</p>
            </div>
            <div style="text-align: left;">
              <p><strong>Parcela:</strong> '+cast(isnull(@qt_parcela,0) as varchar(20))+'</p>
              <p><strong>Valor:</strong> '+cast(isnull(dbo.fn_formata_valor(@vl_parcela_contrato),0) as varchar(20))+' </p>
              <p><strong>Valor Total:</strong> '+cast(isnull(dbo.fn_formata_valor(@vl_total_contrato_pagar),0) as varchar(20))+'</p>
            </div>
          </div>
        </td>
      </tr>
    </table>
    <table style="width: 100%;">
      <tr>
        <td style="text-align: left;">
          <div>
            <p style="font-size: 16px;"><b>Descrição:</b></p>
            <p> </p>
            <p>'+isnull(@ds_historico_contrato,'')+'</p>
          </div>
        </td>
      </tr>
    </table>
    <table style="width: 100%;">
      <tr>
        <td style="text-align: left;">
          <div>
            <p><b>Condição de Pagamento:</b></p>
            <p>('+CAST(isnull(@cd_condicao_pagamento,0) as varchar(20))+') '+ISNULL(@nm_condicao_pagamento,'')+'</p>  
          </div>
        </td>
      </tr>
    </table>
</body>

</html>'  
  
    
    
--HTML Completo--------------------------------------------------------------------------------------    
    
set @html         =     
    @html_empresa +    
    @html_titulo  +    
   @html_geral   +  
 --@html_cab_det +    
   @html_detalhe +    
 --@html_rod_det +    
    
         
    @html_totais  +    
    @html_grafico +    
    @html_rodape      
    
--select @html, @html_empresa, @html_titulo, @html_cab_det, @html_rod_det, @html_totais, @html_grafico, @html_rodape    
    
-------------------------------------------------------------------------------------------------------    
    
    
-------------------------------------------------------------------------------------------------------------------------------------------------------
if @html<>''
   select isnull(@html,'') as RelatorioHTML
else
   select 'Relatório não configurado !' as RelatorioHTML

-------------------------------------------------------------------------------------------------------------------------------------------------------






----------------------------------------------------------------------------------------------------------------------------------------------
go

--contrato_pagar
--ALTER TABLE contrato_pagar ALTER COLUMN dt_vcto_1p_contrato_pagar DATETIME;
	
---exec pr_egis_relatorio_contrato_pagar 338,''
 