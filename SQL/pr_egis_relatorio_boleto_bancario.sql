IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_boleto_bancario' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_boleto_bancario

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_boleto_bancario  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_boleto_bancario  
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
--Alteração        : 28/11/2024 - Correção no layout e geração do boleto via EGISMOB - Kelvin Viana  
--                 : 28/01/2025 - Correção no beneficiário. - Kelvin Viana  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_boleto_bancario
@cd_relatorio int   = 0,  
@cd_usuario   int   = 0,  
@cd_parametro int   = 0,  
@json nvarchar(max) = '',  
@ic_mobile    char(1) = 'N',  
@cd_documento int   = 0  
  
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
--declare @cd_usuario             int = 0  
declare @dt_usuario             datetime = ''  
--declare @cd_documento           int = 0  
declare @cd_item_documento      int = 0  
--declare @cd_parametro           int = 0  
declare @dt_hoje                datetime  
declare @dt_inicial             datetime  
declare @dt_final               datetime  
declare @cd_ano                 int      
declare @cd_mes                 int      
declare @cd_dia                 int  
declare @cd_grupo_relatorio     int  
declare @cd_controle            int  
declare @nm_logo_banco_web      varchar(500) = ''  
declare @ds_banco_boleto        nvarchar(max) = ''  
declare @pc_juros_banco         decimal(25,2) = 0.00  
  
  
--declare @cd_relatorio           int = 0  
  
--Dados do Relatório---------------------------------------------------------------------------------  
  
     declare  
            @titulo                     varchar(200),  
      --@logo                       varchar(400),     
   --@nm_cor_empresa             varchar(20),  
   @nm_endereco_empresa       varchar(200) = '',  
   @nm_bairro_empresa          varchar(900) = '',  
   --@cd_telefone_empresa     varchar(200) = '',  
   --@nm_email_internet      varchar(200) = '',  
   --@nm_cidade        varchar(200) = '',  
   --@sg_estado        varchar(10)  = '',  
   --@nm_fantasia_empresa     varchar(200) = '',  
   @nm_empresa                 varchar(200) = '',  
   --@numero         int = 0,  
   --@dt_pedido        varchar(60) = '',  
   --@cd_cep_empresa       varchar(20) = '',  
   @cd_cep_cliente             varchar(20) = '',  
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
   @cd_numero_endereco_cliente varchar(20)   = '',  
   --@cd_pais     int = 0,  
   --@nm_pais     varchar(20) = '',  
   @cd_cnpj_empresa   varchar(60) = ''--,  
   --@cd_inscestadual_empresa    varchar(100) = ''  
   --@nm_dominio_internet  varchar(200) = '',  
   --@nm_status     varchar(100) = '',  
   --@ic_empresa_faturamento  char(1) = ''  
          
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
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'  
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
declare @ic_processo             char(1) = 'N'  
  
--select * from conta_agencia_banco  
  
select  
  @titulo             = nm_relatorio,  
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),  
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)  
from  
  egisadmin.dbo.Relatorio  
where  
  cd_relatorio = @cd_relatorio  
  
  --select @titulo,@ic_processo,@cd_grupo_relatorio  
  
  --declare @cd_tipo_pedido int  
  
declare @cd_identificacao_documento varchar(25) = ''  
declare @cd_conta_banco             int = 0  
declare @nm_empresa_beneficiario    varchar(60) = ''  
declare @cd_beneficiario_conta      int         = 0  
declare @cd_cnpj_beneficiario       varchar(20) = ''  
  
select  
  @dt_inicial                 = dt_inicial,  
  @dt_final                   = dt_final,  
  @cd_vendedor                = isnull(cd_vendedor,0),  
  --@cd_cliente                 = isnull(cd_cliente,0),  
  @cd_tipo_pedido             = 0, --cd_tipo_pedido  
  @cd_conta_banco             = cd_conta_banco,  
  @cd_identificacao_documento = cd_identificacao_documento  
from   
  Parametro_Relatorio --select * from Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
  and  
  cd_usuario   = @cd_usuario  
  
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
  --@logo = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),  
  --@nm_cor_empresa          = isnull(e.nm_cor_empresa,'#1976D2'),  
  @nm_endereco_empresa      = isnull(e.nm_endereco_empresa,''),  
  @nm_bairro_empresa          = isnull(e.nm_bairro_empresa,''),  
  --@cd_telefone_empresa     = isnull(e.cd_telefone_empresa,''),  
  --@nm_email_internet        = isnull(e.nm_email_internet,''),  
  --@nm_cidade        = isnull(c.nm_cidade,''),  
  --@sg_estado        = isnull(es.sg_estado,''),  
  @nm_empresa                 = isnull(e.nm_empresa,''),  
  --@nm_fantasia_empresa     = isnull(e.nm_fantasia_empresa,''),  
  --@cd_cep_empresa       = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),  
  @cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),  
  --@nm_pais     = ltrim(rtrim(isnull(p.sg_pais,''))),  
  @cd_cnpj_empresa   = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,''))))--,  
  --@cd_inscestadual_empresa =  ltrim(rtrim(isnull(e.cd_iest_empresa,'')))--,  
  --@nm_dominio_internet  =  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))  
        
 from egisadmin.dbo.empresa e with(nolock) --select * from egisadmin.dbo.empresa where cd_empresa = 317  
 left outer join Estado es  with(nolock) on es.cd_estado = e.cd_estado  
 left outer join Cidade c  with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado  
 left outer join Pais p   with(nolock) on p.cd_pais = e.cd_pais  
 where   
  cd_empresa = @cd_empresa  
-----------------------------------------------------------------------------------------------------  
declare @nm_razao_social    varchar(60) = ''  
declare @dt_vencimento      datetime  
declare @vl_documento       float       = 0  
declare @nm_conta           varchar(80) = ''  
declare @cd_nosso_numero    varchar(800)= ''  
declare @nm_agencia         varchar(4) = ''  
declare @nm_conta_banco     varchar(10) = ''  
declare @cd_digito          char(1) = ''  
declare @linhaDigitavel     NVARCHAR(255) = ''  
declare @codigobarra        varchar(255) = ''  
declare @cd_portador        int     = 0  
declare @cd_banco           int     = 0  
declare @vl_juros_documento decimal(25,2) = 0.00  
  
--Dados do Documento a Receber--  
 --Se não vier do parametro_relatorio busca no documento_receber--------------------------------------------------------------------------------------------------------------------------  
if isnull(@cd_documento,0) <> 0  
begin  
   select top 1 @cd_identificacao_documento = cd_identificacao from Documento_Receber where cd_documento_receber = @cd_documento  
end  
  
--USADO NO EGISMOB NÃO RETIRAR--------------------------------------------------------------------------------------------------------------------------  
if @ic_mobile = 'S'  
begin  
   select top 1 @cd_identificacao_documento = cd_identificacao from Documento_Receber where cd_documento_receber = @cd_parametro  
end  
----------------------------------------------------------------------------------------------------------------------------  
--Pega Cliente  
select top 1  
  @cd_cliente = isnull(d.cd_cliente,0)  
from  
  documento_receber d  with(nolock)   
  inner join cliente c with(nolock) on c.cd_cliente = d.cd_cliente   
where    
  d.cd_identificacao = case when isnull(@cd_identificacao_documento,'') = '' then d.cd_identificacao else @cd_identificacao_documento end  
  and  
  d.cd_documento_receber = case when @ic_mobile = 'S' then @cd_parametro else d.cd_documento_receber end  
  and    
  d.dt_cancelamento_documento is null  
  
----Pega Conta Banco  
declare @cd_conta_banco_join int = 0  
select  
  @cd_conta_banco_join = case when isnull(ce.cd_conta_banco,0)>0 then  
     ce.cd_conta_banco  
  else  
    i.cd_conta_banco   
  end  
from   
  cliente_informacao_credito i            with(nolock)  
  left outer join Forma_Pagamento fp      with(nolock) on fp.cd_forma_pagamento = i.cd_forma_pagamento  
  left outer join cliente_empresa ce      with(nolock) on ce.cd_cliente = i.cd_cliente  
  left outer join conta_agencia_banco cab with(nolock) on cab.cd_conta_banco = case when isnull(ce.cd_conta_banco,0)>0 then  
     ce.cd_conta_banco  
  else  
    i.cd_conta_banco   
  end  
  left outer join banco b on b.cd_banco = cab.cd_banco  
  where  
    i.cd_cliente = @cd_cliente  
 and  
 isnull(i.ic_cobranca_eletronica,'N')='S'  --Boleto  
 ----------------------------------------------------  
  
select top 1  
  @nm_razao_social       = c.nm_razao_social_cliente,  
  @dt_vencimento         = d.dt_vencimento_documento,  
  @vl_documento          = isnull(d.vl_documento_receber,0),  
  @nm_conta              = cab.Conta, --cab.nm_agencia_banco+ ' / '+ cab.Conta,  
  @cd_nosso_numero       = d.cd_banco_documento_recebe,  
  @nm_agencia            = cab.nm_agencia_banco,  
  @nm_conta_banco        = cab.nm_conta_banco,  
  @cd_digito             = isnull(cab.cd_dac_conta_banco,0),  
  @linhaDigitavel        = isnull(b.cd_linha_digitavel,''),  
  @codigobarra           = isnull(b.cd_codigo_barra,''),  
  @cd_portador           = ISNULL(d.cd_portador,0),  
  @nm_logo_banco_web     = ISNULL(tb.nm_logo_web_banco,''),  
  @cd_banco              = cab.cd_banco,  
  @cd_beneficiario_conta = cab.cd_beneficiario_conta  
  
  --select cd_conta_banco_remessa,cd_banco_documento,cd_banco_doc_receber,* from documento_receber where cd_documento_receber = 47555  
  
from  
  documento_receber d with(nolock) --select * from documento_receber where cd_identificacao = '23022 - 3' 156  
  inner join cliente c                           with(nolock) on c.cd_cliente = @cd_cliente   
  left outer join vw_Conta_Agencia_Banco cab     with(nolock) on cab.cd_conta_banco = case when isnull(d.cd_conta_banco_remessa,0) = 0 then isnull(@cd_conta_banco_join,0) else d.cd_conta_banco_remessa end
  --select * from vw_Conta_Agencia_Banco   
  left outer join Documento_Receber_Boleto b     with(nolock) on b.cd_documento_receber = d.cd_documento_receber --select * from Documento_Receber_Boleto  
  left outer join Banco bco                      with(nolock) on bco.cd_banco = cab.cd_banco --select * from Banco  
  left outer join egisadmin.dbo.Tabela_Bancos tb with(nolock) on tb.cd_banco  = bco.cd_banco --select * from egisadmin.dbo.tabela_bancos  
  
where    
  d.cd_identificacao = case when isnull(@cd_identificacao_documento,'') = '' then d.cd_identificacao else @cd_identificacao_documento end  
  and  
  d.cd_documento_receber = case when @ic_mobile = 'S' then @cd_parametro else d.cd_documento_receber end  
  and    
  d.dt_cancelamento_documento is null  
     
   --Dados do Banco Boleto--  
     
   select  
     @ds_banco_boleto     = isnull(ds_banco_boleto,''),  
  @pc_juros_banco      = ISNULL(pc_juros_banco,0),  
  @vl_juros_documento  = @vl_documento * (ISNULL(pc_juros_banco,0.00)/100.00/30.00)  
  
   from  
     banco_boleto   
   where  
     cd_banco = @cd_banco  
  
   --Dados do Cliente-----------------------------------------------------------  
  
 select   
  @nm_fantasia_cliente       = e.nm_fantasia_cliente,  
  @nm_razao_social_cliente = e.nm_razao_social_cliente,  
  @nm_endereco_cliente  = e.nm_endereco_cliente,  
  @nm_bairro     = e.nm_bairro,  
  @nm_cidade_cliente   = c.nm_cidade,  
  @sg_estado_cliente   = es.sg_estado,  
  @cd_cep_cliente       = isnull(dbo.fn_formata_cep(e.cd_cep),''),  
  @cd_numero_endereco_cliente = ltrim(rtrim(isnull(e.cd_numero_endereco,0))),  
  @cd_cnpj_cliente   = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cnpj_cliente,''))))  
        
 from cliente e                 with(nolock) --select * from cliente where cd_cliente = 317  
 left outer join Estado es  with(nolock) on es.cd_estado = e.cd_estado  
 left outer join Cidade c  with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado  
 left outer join Pais p   with(nolock) on p.cd_pais    = e.cd_pais  
  
 where   
  e.cd_cliente = @cd_cliente  
  
if @cd_beneficiario_conta>0   --and isnull(@nm_empresa,'') = ''  
begin    
  select top 1    
    @nm_empresa_beneficiario = e.nm_beneficiario_conta,    
    @cd_cnpj_beneficiario    = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cnpj_beneficiario_conta ,''))))     
  from    
    Beneficiario_Conta e    
  where    
    e.cd_beneficiario_conta = @cd_beneficiario_conta    
    
    
  set @nm_empresa      = @nm_empresa_beneficiario    
  set @cd_cnpj_empresa = @cd_cnpj_beneficiario    
    
end    
  
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
------------------------------  
SET @html_empresa = '  
<html>  
<head>  
    <meta charset="UTF-8">  
    <meta http-equiv="X-UA-Compatible" content="IE=edge">  
    <meta name="viewport" content="width=device-width, initial-scale=1.0">  
    <title>'+@titulo+'</title>  
  <style>  
    body {  
            font-family: arial, verdana;   
    }  
        .BoletoCodigoBanco{   
            font-size: 6mm;   
            font-weight : bold;   
            text-align: center;   
            border-bottom: 0.15mm solid #000;   
            border-right: 0.15mm solid #000;  
   border-left: 0.15mm solid #000;  
            padding-bottom : 1mm;  
        }  
        .BoletoLogo img {   
            height: 12mm;  
   width: 12mm;  
            border-bottom: 0.15mm solid #000;   
            padding-bottom : 1mm;  
        }   
        .BoletoLinhaDigitavel {  
            font-size: 4mm;   
            font-weight : bold;   
            text-align: right;   
            vertical-align: bottom;   
            border-bottom: 0.15mm solid #000;   
            padding-bottom : 1mm;   
        }   
  
        .BoletoTituloEsquerdo{  
            font-size: 0.2cm;   
            padding-left : 0.15mm;  
            border-right: 0.15mm solid #000;   
            text-align: left  
        }  
        .BoletoTituloDireito{  
            font-size: 2mm;   
            padding-left : 0.15mm;  
            text-align: left  
        }  
  
        .BoletoValorEsquerdo{  
         font-size: 3mm;   
            text-align: center;  
            border-right: 0.15mm solid #000;   
            font-weight: bold;  
            border-bottom: 0.15mm solid #000;   
            padding-top: 0.5mm  
        }  
  .BoletoValorEsquerdoSB{  
            font-size: 3mm;   
            text-align: center;  
            border-right: 0.15mm solid #000;   
            border-bottom: 0.15mm solid #000;   
            padding-top: 0.5mm  
        }  
  .h7 {  
   height: 7mm;  
  }  
  .CampAlign {  
     text-align: left;  
     vertical-align:top;  
     padding-left : 0.1cm;  
  }  
  .ALeft {  
       text-align: left;  
  }  
  .LocalPagamento {  
      text-align: left;  
   padding-left : 0.1cm;  
  }  
        .BoletoValorDireito{  
            font-size: 3mm;   
            text-align:right;   
            padding-right: 3mm;   
            padding-top: 0.8mm;   
            border-bottom: 0.15mm solid #000;  
            font-weight: bold;  
        }  
        .BoletoTituloSacado{  
            font-size: 2.5mm;   
            padding-left : 0.15mm;  
            vertical-align: top;   
            padding-top : 0.15mm;   
            text-align: left  
        }  
         
        .BoletoValorSacadoB{  
            font-size: 3mm;   
            font-weight: bold;   
            text-align : left  
        }  
  .BoletoValorSacado{  
            font-size: 3mm;   
            text-align : left  
        }  
        .BoletoTituloSacador{  
            font-size: 2mm;  
            padding-left : 0.15mm;  
            vertical-align: bottom;   
            padding-bottom : 0.8mm;  
            border-bottom: 0.15mm solid #000;  
        }  
        .BoletoValorSacador{  
            font-size: 3mm;  
            vertical-align: bottom;   
            padding-bottom : 0.15mm;   
            border-bottom: 0.15mm solid #000;  
            font-weight: bold;  
            text-align: left  
        }   
        .BoletoPontilhado{  
            border-top: 0.3mm dashed #000;   
            font-size: 1mm  
        }  
        .button-group{  
            margin-left: 225mm;  
            margin-top: 10mm;  
        }  
  .boleto-footer{  
     width:100%;  
     height: auto;  
  }  
         
        </style>  
</head>  
<body>'  
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
  
order by  
  qt_ordem_atributo  
  
------------------------------------------------------------------------------------------------------------------  
  
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
  
drop table #AuxRelAtributo  
  
  
set @cd_parametro = 0  
  
  
if @cd_parametro<> 3  
begin  
  
---------------------------------------------------------------------------------------------------------------------------  
----montagem do Detalhe-----------------------------------------------------------------------------------------------  
---------------------------------------------------------------------------------------------------------------------------  
declare @id int = 0  
  
declare @html_detalhe_pt1 nvarchar(max) = ''  
declare @html_detalhe_pt2 nvarchar(max) = ''  
declare @html_detalhe_script nvarchar(max) = ''  
  
set @html_detalhe_pt1 = '            
        <tr>  
            <td style="width: 0.9cm"></td>  
            <td style="width: 1cm"></td>  
            <td style="width: 1.9cm"></td>  
              
            <td style="width: 0.5cm"></td>  
            <td style="width: 1.3cm"></td>  
            <td style="width: 0.8cm"></td>  
            <td style="width: 1cm"></td>  
              
            <td style="width: 1.9cm"></td>  
            <td style="width: 1.9cm"></td>  
              
            <td style="width: 3.8cm"></td>  
              
            <td style="width: 3.8cm"></td>  
        <tr><td colspan=11>  
            
          </td></tr>  
          </tr>  
          <tr><td colspan=11 class="BoletoPontilhado"></td></tr>  
          <tr>  
            <td colspan=1 class="BoletoLogo"><img src="'+@nm_logo_banco_web+'"alt="Logo do Banco"></td>  
            <td colspan=2 class="BoletoCodigoBanco">'+CAST(isnull(@cd_banco,'') as varchar(3)) +'</td>  
            <td colspan=8 class="BoletoLinhaDigitavel">'+isnull(@linhaDigitavel,'') +'</td>  
          </tr>  
          <tr>  
            <td colspan=10 class="BoletoTituloEsquerdo">Local de Pagamento</td>  
            <td class="BoletoTituloDireito">Vencimento</td>  
          </tr>  
          <tr>  
            <td colspan=10 class="BoletoValorEsquerdoSB LocalPagamento">PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO</td>  
            <td class="BoletoValorDireito">'+isnull(dbo.fn_data_string(@dt_vencimento),'')+'</td>  
          </tr>                      
            
          <tr>  
            <td colspan=10 class="BoletoTituloEsquerdo"></td>  
            <td class="BoletoTituloDireito">Agência/Código Beneficiário</td>  
          </tr>  
          <tr>  
            <td colspan=10 class="BoletoValorEsquerdoSB ALeft">Beneficiário:'+@nm_empresa+' <span style="float: right;"> CNPJ:'+isnull(@cd_cnpj_empresa,'')+' </span>  
   <br>Endereço: '+isnull(@nm_endereco_empresa,'')+','+isnull(@cd_numero_endereco_empresa,0)+' '+isnull(@nm_bairro_empresa,'')+'</td>  
            <td class="BoletoValorDireito">'+isnull(@nm_conta,'')+'</td>  
          </tr>              
           
          <tr>  
            <td colspan=3 class="BoletoTituloEsquerdo">Data do Documento</td>  
            <td colspan=4 class="BoletoTituloEsquerdo">Número do Documento</td>  
            <td class="BoletoTituloEsquerdo">Espécie Doc.</td>  
            <td class="BoletoTituloEsquerdo">Aceite</td>  
            <td class="BoletoTituloEsquerdo">Data do Processamento</td>  
            <td class="BoletoTituloDireito">Nosso Número</td>  
          </tr>  
          <tr>  
            <td colspan=3 class="BoletoValorEsquerdo">'+isnull(dbo.fn_data_string(@dt_hoje),'')+'</td>  
            <td colspan=4 class="BoletoValorEsquerdo">'+isnull(@cd_identificacao_documento,'')+'</td>  
            <td class="BoletoValorEsquerdo">DM</td>  
            <td class="BoletoValorEsquerdo">N</td>  
            <td class="BoletoValorEsquerdo">'+dbo.fn_data_string(@dt_hoje)+'</td>  
            <td class="BoletoValorDireito">'+isnull(@cd_nosso_numero,'')  +'</td>  
          </tr>    
          <tr>  
            <td colspan=3 class="BoletoTituloEsquerdo">Uso do Banco</td>  
            <td colspan=2 class="BoletoTituloEsquerdo">Carteira</td>  
            <td colspan=2 class="BoletoTituloEsquerdo">Espécie</td>  
            <td colspan=2 class="BoletoTituloEsquerdo">Quantidade</td>  
            <td class="BoletoTituloEsquerdo">Valor</td>  
            <td class="BoletoTituloDireito">(=) Valor do Documento</td>  
          </tr>  
          <tr>  
            <td colspan=3 class="BoletoValorEsquerdo"></td>  
            <td colspan=2 class="BoletoValorEsquerdo">001</td>  
            <td colspan=2 class="BoletoValorEsquerdo">R$</td>  
            <td colspan=2 class="BoletoValorEsquerdo"></td>  
            <td class="BoletoValorEsquerdo"></td>  
            <td class="BoletoValorDireito"> R$ '+cast(dbo.fn_formata_valor(isnull(@vl_documento,0)) as varchar)+'</td>  
          </tr>    
         '  
  
set @html_detalhe_pt2 = ' 
 <tr>  
            <td colspan=10 class="BoletoTituloEsquerdo">Instruções (Todas as informações deste boleto são de exclusiva responsabilidade do cedente.)</td>  
            <td class="BoletoTituloDireito" style="height: 7mm;">(-) Desconto/Abatimento</td><br>  
          </tr>
      <div>  
          <tr>  
            <td colspan=10 rowspan=9 class="BoletoValorEsquerdoSB CampAlign">  
                    Cobrar juros de R$ '+dbo.fn_formata_valor(isnull(@vl_juros_documento,'')) +' por dia de atraso  
                <br>'+isnull(@ds_banco_boleto,'') + '  
                <br>  
            </td>  
            <td class="BoletoValorDireito"></td>  
          </tr>    
          <tr>  
            <td class="BoletoTituloDireito h7"></td>  
          </tr>    
          <tr>  
            <td class="BoletoValorDireito" ></td>  
          </tr>    
          <tr>  
            <td class="BoletoTituloDireito h7">(+) Mora/Multa</td>  
          </tr>    
          <tr>  
            <td class="BoletoValorDireito"></td>  
          </tr>    
          <tr>  
            <td class="BoletoTituloDireito h7"></td>  
          </tr>    
          <tr>  
            <td class="BoletoValorDireito"></td>  
          </tr>    
          <tr>  
            <td class="BoletoTituloDireito h7">(=) Valor Cobrado</td>  
          </tr>    
          <tr>  
            <td class="BoletoValorDireito"></td>  
          </tr>                  
          <tr>  
            <td colspan=10 class="BoletoTituloSacado">Pagador:</td>  
            <td colspan=2 class="BoletoTituloSacado">CPF/CNPJ do Sacado:</td>  
          </tr>   
  
          <tr>  
            <td colspan=10 class="BoletoValorSacadoB">'+isnull(@nm_razao_social_cliente,'')+' ( '+isnull(CAST(@cd_cliente as varchar(9)),'')+' ) </td>  
            <td colspan=2 class="BoletoValorSacado">'  +isnull(@cd_cnpj_cliente,'')+'</td>  
          </tr>  
          <tr>  
            <td colspan=10 class="BoletoValorSacado">'+isnull(@nm_endereco_cliente,'')+','+isnull(@cd_numero_endereco_cliente,0)+' '+isnull(@nm_bairro,'')+' '+isnull(@nm_cidade_cliente,'')+'/'+isnull(@sg_estado_cliente,'')+'</td>  
            <td colspan=2 class="BoletoTituloSacado ALeft">Código de Baixa:</td>  
          </tr>  
          <tr>  
            <td colspan=10 class="BoletoValorSacado">CEP / IPIRANGA  / RIBEIRAO PRETO SP</td>  
            <td colspan=2 class="BoletoValorSacado ALeft">'+isnull(@cd_nosso_numero,'')+'</td>  
          </tr>    
          
          <tr>  
            <td colspan=2 class="BoletoTituloSacador"></td>  
            <td colspan=9 class="BoletoValorSacador"></td>  
          </tr>  
            
          <tr>
			<td colspan=8 class="BoletoValorSacado">Beneficiário Final: '+isnull(@nm_empresa_beneficiario,@nm_razao_social_cliente)+'</td>
			<td colspan=2 class="BoletoValorSacado ALeft">CNPJ: '+isnull(@cd_cnpj_beneficiario,@cd_cnpj_cliente)+'</td>
			<td colspan=5 class="BoletoValorSacado ALeft">Autenticação Mecânica</td>
          </tr>
            
   </div> '  
 -- print @codigobarra  
set @html_detalhe_script = '      
    <script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.5/dist/JsBarcode.all.min.js"></script>  
    <script>  
            function geraCode() {  
              JsBarcode("#barcode", "'+isnull(@codigobarra,'')+'", {  
                format: "CODE128",     
    height: 60,  
    displayValue: false  
              });  
            }  
         document.addEventListener("DOMContentLoaded", geraCode);  
      
         function imprimirBoleto() {  
           window.print();  
         }  
    </script>'  
  
   
  
set @html_detalhe =   
-- <body>       
'  
         
        <div align=center>  
        <table cellSpacing=0 cellPadding=0 border=0 >  
        '+isnull(@html_detalhe_pt1,'')+'  
  '+isnull(@html_detalhe_pt2,'')+'  
        </table>  
   <div class="boleto-footer">  
           <svg id="barcode"></svg>  
         </div>  
            
                    </div>  
         
'+  
--</div>  
--<div class="button-group">  
--            <button onclick="imprimirBoleto()">Imprimir Boleto</button>  
--          </div>  
-- </body>  
@html_detalhe_script --valores da tabela  
  
--set @titulo_total = 'SUB-TOTAL'  
  
set @html_totais = ''  
       
 set @html_geral = @html_geral +   
                   @html_cab_det +  
                   @html_detalhe +  
                   @html_rod_det +  
                   @html_totais  
  
       
--end  
  
  
---------------------------------------------------------------------------------------------------------------------------  
  
  
set @nm_fantasia_cliente     = '' --'Resumo dos Pedidos de Vendas'  
set @nm_razao_social_cliente = '' --@nm_pedido  
  
--set @titulo = @titulo + ' - Período : '+dbo.fn_data_string(@dt_inicial) + ' á '+dbo.fn_data_string(@dt_final)  
  
--set @html_titulo = '<div class="section-title"><strong>'+isnull(@titulo,'')+'</strong></div>  
--                    <div style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">  
--       <p><strong>'+isnull(@nm_fantasia_cliente,'')+'</strong></p>  
--     </div>  
--                 <div style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">  
--              <p><strong>'+isnull(@nm_razao_social_cliente,'')+'</strong></p>                
-- </div>'  
      
--------------------------------------------------------------------------------------------------------------------  
  
  
  
set @titulo_total = ''  
set @html_totais = ''  
set @footerTitle = ''  
  
--Rodapé--  
  
set @html_rodape = '</html>'  
  
  
--Gráfico--  
set @html_grafico = ''  
  
--HTML Completo--------------------------------------------------------------------------------------  
  
set @html         =   
    @html_empresa +  
    @html_geral   +   
	@html_totais  +  
	@html_grafico +  
    @html_rodape    
  
--select @html, @html_empresa, @html_titulo, @html_cab_det, @html_rod_det, @html_totais, @html_grafico, @html_rodape  
  
-------------------------------------------------------------------------------------------------------  
  
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML, replace(@cd_identificacao_documento,'/','_') as pdfName  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
  
  
end  
  
  
  
----------------------------------------------------------------------------------------------------------------------------------------------  
go 
exec pr_egis_relatorio_boleto_bancario 186,1,0,'','N',5803

--@cd_relatorio int   = 0,  
--@cd_usuario   int   = 0,  
--@cd_parametro int   = 0,  
--@json nvarchar(max) = '',  
--@ic_mobile    char(1) = 'N',  
--@cd_documento int   = 0  
