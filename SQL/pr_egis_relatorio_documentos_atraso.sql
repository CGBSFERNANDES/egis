IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_documentos_atraso' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_documentos_atraso

GO
 -- use egissql_376
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_documentos_atraso  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_documentos_atraso  
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
--Altera��o        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_documentos_atraso  
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
 --  @nm_fantasia_cliente       varchar(200) = '',  
   @cd_cnpj_cliente      varchar(30) = '',  
   @nm_razao_social_cliente varchar(200) = '',  
   @nm_cidade_cliente   varchar(200) = '',  
   @sg_estado_cliente   varchar(5) = '',  
   @cd_numero_endereco   varchar(20) = '',  
   @nm_condicao_pagamento  varchar(100) = '',  
   @ds_relatorio    varchar(8000) = '',  
   @subtitulo     varchar(40)   = '',  
   @footerTitle    varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais     int = 0,  
   @nm_pais     varchar(20) = '',  
   @cd_cnpj_empresa   varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet  varchar(200) = ''  
  
  
  
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
  @nm_cor_empresa          = isnull(e.nm_cor_empresa,'#1976D2'),  
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
           
            text-align: center;  
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
------------------------------------------------------------------------------------------------------------  
    set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)  
    declare @cd_portador               int = 0  
 declare @ic_rateio                 int = 0  
 declare @cd_plano_financeiro       int = 0  
 declare @cd_identificacao          varchar(50) = ''  
 declare @ic_tipo_filtro            char(1)     = 'V'  
 declare @ic_filtrar_favorecido     char(1)     = 'N'  
 declare @ic_tipo_consulta          char(1)     = 'A'  
 declare @cd_tipo_favorecido        char(10)    = ''  
 declare @cd_favorecido             varchar(30) = ''  
 declare @ic_previsao_documento     char(1)     = 'N'  
 declare @ic_ordem_documento        char(1)     = 'A'  
 declare @ic_autorizacao_pagamento  char(1)     = 'N'  
  
 --set @dt_inicial  ='01-19-2025'  
 --set @dt_final = '02-19-2025'  
    set @ic_tipo_filtro = 'V'  
    if @cd_identificacao is null   
   set @cd_identificacao = ''  
 select  
  top 1    
  @ic_autorizacao_pagamento = isnull(ic_autorizacao_pagamento,'N')  
from  
  Parametro_Financeiro  
where  
   cd_empresa = @cd_empresa  
  
------------------------------------------------------------------------------------------------------------  
    
  
  
    select    
   identity(int,1,1)                                       as cd_controle,  
      0                                                       as 'Selecionado',    
  
      d.cd_documento_pagar,    
  
      case when isnull(d.vl_saldo_documento_pagar,0) > 0 then  
       case when d.dt_vencimento_documento>@dt_hoje then  
         'Vencido'  
       else  
         'Aberto'  
       end  
      else  
        'Baixado'  
      end                                                     as 'nm_status',  
  
      case when isnull(d.vl_saldo_documento_pagar,0) > 0 then  
         cast(@dt_hoje - d.dt_vencimento_documento as int )  
      else  
        0  
      end                                                     as  'qt_dia',  
      d.dt_vencimento_documento,    
    case when d.dt_vencimento_original is null  
    then d.dt_vencimento_documento  
    else d.dt_vencimento_original  
   end                                                     as dt_vencimento_original,  
      c.nm_tipo_conta_pagar,    
  
      --select * from empresa_diversa  
  
      cast(  
      case when (isnull(d.cd_empresa_diversa, 0) <> 0)  
      then     
         case when isnull(z.sg_empresa_diversa,'')<>''   
         then  
            z.sg_empresa_diversa  
         else   
            z.nm_empresa_diversa  
         end  
      else      
         case when (isnull(d.cd_contrato_pagar, 0) <> 0)   
     then     
             case when isnull(w.nm_fantasia_fornecedor,'')<>'' then w.nm_fantasia_fornecedor else d.nm_fantasia_fornecedor end  
         else    
            case when (isnull(d.cd_funcionario, 0) <> 0)   
            then     
               k.nm_funcionario     
            else  
              case when (isnull(d.nm_fantasia_fornecedor, '') <> '') or isnull(d.cd_tipo_destinatario,2)<>0   
              then     
                 case when isnull(d.cd_tipo_destinatario,2)=1 then  
                   vw.nm_fantasia  
                 else  
                   d.nm_fantasia_fornecedor   
                 end  
              else  
                 ''  
              end  
            end  
         end  
      end    
      as varchar(30))                             as 'cd_favorecido',    
      
      case when (isnull(d.cd_empresa_diversa, 0) <> 0) then d.cd_empresa_diversa    
           when (isnull(d.cd_contrato_pagar, 0)  <> 0) then d.cd_contrato_pagar    
           when (isnull(d.cd_funcionario, 0)     <> 0) then d.cd_funcionario    
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then d.cd_fornecedor    
      end                                         as 'cd_favorecido_chave',    
    
      case when (isnull(d.cd_empresa_diversa, 0) <> 0) then 'E'    
           when (isnull(d.cd_contrato_pagar, 0) <> 0)  then 'C'    
           when (isnull(d.cd_funcionario, 0) <> 0)     then 'U'    
           when (isnull(d.nm_fantasia_fornecedor, '') <> '') then 'F'     
      end                                         as 'ic_tipo_favorecido',    
  
      cast(case when isnull(d.cd_favorecido_empresa,0)=0  
      then   
         ''  
      else  
        ( select top 1 fe.nm_favorecido_empresa   
          from   
             favorecido_empresa fe with (nolock)   
          where  
             fe.cd_empresa_diversa        = d.cd_empresa_diversa and   
             fe.cd_favorecido_empresa_div = d.cd_favorecido_empresa )  
      end as varchar(30))                            as 'nm_favorecido_empresa',  
      --documento_pagar  
  
      d.cd_favorecido_empresa,  
      cast(isnull(d.cd_identificacao_document,'') as varchar(30))   as cd_identificacao_document,    
      d.dt_emissao_documento_paga,    
  
      isnull(d.vl_documento_pagar,0)                 as 'vl_documento_pagar',    
  
      case when d.dt_cancelamento_documento is null   
      then  
        cast(str(d.vl_saldo_documento_pagar,25,2) as decimal(25,2))   
      else  
        0.00  
      end                                             as 'vl_saldo_documento_pagar',    
  
      t.nm_tipo_documento,    
  
      --Plano Financeiro---------------------------------------------------------------------------------------------------  
  
      isnull(pf.cd_plano_financeiro,0)                as 'cd_plano_financeiro',  
      pf.cd_mascara_plano_financeiro,  
  
      case when isnull(d.cd_plano_financeiro,0)<>0 then  
         pf.nm_conta_plano_financeiro  
      else  
         --Verifica se existe Rateio  
         case when exists ( select top 1 dpf.cd_documento_pagar from Documento_pagar_plano_financ dpf  
                            where dpf.cd_documento_pagar = d.cd_documento_pagar )  
         then '** Rateio de Plano Financeiro **' else '' end  
              
      end                                             as 'nm_conta_plano_financeiro',  
  
        
  
      m.sg_moeda,    
      l.nm_fantasia_loja,    
      i.nm_invoice,    
      isnull(d.vl_documento_pagar_moeda,0)           as 'vl_documento_pagar_moeda',  
      u.nm_fantasia_usuario,   
      d.dt_usuario,   
      isnull(d.vl_juros_documento,0)                 as vl_juros_documento,  
      isnull(d.vl_abatimento_documento,0)            as vl_abatimento_documento,  
      isnull(d.vl_desconto_documento,0)              as vl_desconto_documento,    
  
      ltrim(rtrim(d.nm_observacao_documento))    
      +  
      case when isnull(fo.cd_conta_banco,'')<>'' then  
        ' Conta: ' + ltrim(rtrim((cast(fo.cd_banco as varchar))))+'/'+ltrim(rtrim(fo.cd_agencia_banco))+'/'+ltrim(rtrim(fo.cd_conta_banco))  
      else  
        cast('' as varchar)  
      end  
                                                     as nm_observacao_documento,  
  
      d.dt_cancelamento_documento,  
      d.nm_cancelamento_documento,    
      pt.nm_portador,  
  
      --Busca Data de Entrada da Nota Fiscal   
      --Carlos 27.04.2007  
--Fabiano 06.11.2020 -- Problema na EXSTO -- Comentado até solucionar.  
      ( Select Top 1  
          ne.dt_receb_nota_entrada   
        from  
          Nota_Entrada ne with (nolock)             
        Where  
          cast(d.cd_nota_fiscal_entrada as int) = ne.cd_nota_entrada and  
          d.cd_fornecedor                       = ne.cd_fornecedor   and  
          d.cd_serie_nota_fiscal                = ne.cd_serie_nota_fiscal ) as dt_rem,  
   
--       ( Select Top 1  
--           isnull(ner.dt_rem,ne.dt_receb_nota_entrada)   
--         from  
--           Nota_Entrada_Parcela nep  
--   
--           left outer join Nota_Entrada_Registro ner on cast(d.cd_nota_fiscal_entrada as int ) = ner.cd_nota_entrada and  
--                                                        d.cd_fornecedor = ner.cd_fornecedor and  
--                                                        nep.cd_serie_nota_fiscal = ner.cd_serie_nota_fiscal  
--   
--           left outer join Nota_Entrada ne           on cast(d.cd_nota_fiscal_entrada as int) = ne.cd_nota_entrada and  
--                                                        d.cd_fornecedor          = ne.cd_fornecedor   and  
--                                                        d.cd_serie_nota_fiscal   = ne.cd_serie_nota_fiscal  
--   
--         Where  
--           d.cd_documento_pagar = nep.cd_documento_pagar  
--       )                              as dt_rem,  
  
      isnull(d.cd_moeda,0)                            as 'cd_moeda',  
      sd.nm_situacao_documento,  
      isnull(d.cd_portador,0)                         as 'cd_portador',  
      isnull(d.cd_tipo_conta_pagar,0)                 as 'cd_tipo_conta_pagar',  
  
      --Autorização de Pagamento-----------------------------------------------------------------------------------------  
  
      isnull(d.cd_ap,0)                               as 'cd_ap',  
      ap.dt_aprovacao_ap,      
      uap.nm_fantasia_usuario                         as 'Usuario_Aprovacao_AP',  
  
      isnull(d.cd_cheque_pagar,0)                     as 'cd_cheque_pagar',  
  
      --select * from fornecedor_adiantamento  
  
      --isnull(( select  
      --    sum ( isnull(fa.vl_adto_fornecedor,0) )   
      --  from   
      --    fornecedor_adiantamento fa with (nolock)   
      --  where  
      --    fa.cd_documento_pagar = d.cd_documento_pagar and  
      --    fa.cd_fornecedor = d.cd_fornecedor and              
      --    fa.dt_baixa_adto_fornecedor is null ),0) as 'TotalAdiantamento',  
  
  
  
          isnull(( select top 1 fa.vl_adiantamento_parcela  
            
        from   
          nota_entrada_parcela fa with (nolock)   
        where  
          fa.cd_fornecedor      = d.cd_fornecedor      
          and  
    fa.cd_ident_parc_nota_entr = d.cd_identificacao_document  
    and  
    isnull(fa.vl_adiantamento_parcela,0)>0  
    ),0)  
  
                                        as 'TotalAdiantamento',                         
  
      isnull(d.vl_multa_documento,0)               as 'vl_multa_documento',  
      isnull(d.vl_outros_documento,0)              as 'vl_outros_documento',                
      ip.nm_imposto,  
      d.nm_complemento_documento,  
  
      case when isnull(d.cd_centro_custo,0)<>0 then  
        cc.nm_centro_custo  
  
      else  
        case when exists ( select top 1 dpcc.cd_documento_pagar from Documento_pagar_centro_custo dpcc  
                           where  
                              dpcc.cd_documento_pagar = d.cd_documento_pagar )   
         then '** Rateio de Centro de Custo **' else '' end  
  
       
      end                                          as nm_centro_custo,  
  
  
      --Fornecedor  
--       case when fo.cd_tipo_pessoa = 1 then  
--         dbo.fn_Formata_Mascara('99.999.999/9999-99', fo.cd_cnpj_fornecedor)    
--       else  
--         dbo.fn_Formata_Mascara('999.999.999-99',  
--                          fo.cd_cnpj_fornecedor)    
--       end                   as cd_cnpj,  
  
      case when vw.cd_tipo_pessoa = 1 or z.cd_tipo_pessoa = 1 then    
        dbo.fn_Formata_Mascara('99.999.999/9999-99', isnull(vw.cd_cnpj,z.cd_cnpj_empresa_diversa))      
      else    
        dbo.fn_Formata_Mascara('999.999.999-99',    
                         vw.cd_cnpj)     
      end                   as cd_cnpj,   
  
      --Razão Social  
      --fo.nm_razao_social    as nm_razao_social,  
  
      case when (isnull(d.cd_empresa_diversa, 0) <> 0)  
      then     
         z.nm_empresa_diversa  
      else      
         case when (isnull(d.cd_contrato_pagar, 0) <> 0)   
         then     
             w.nm_fantasia_fornecedor     
         else    
            case when (isnull(d.cd_funcionario, 0) <> 0)   
            then     
               k.nm_funcionario     
            else  
              case when (isnull(d.nm_fantasia_fornecedor, '') <> '') or isnull(d.cd_tipo_destinatario,2)<>0   
              then     
                 case when isnull(d.cd_tipo_destinatario,2)=1 then  
                   vw.nm_razao_social  
                 else  
                   fo.nm_razao_social  
                 end  
              else  
                 ''  
              end  
            end  
         end  
      end                                   as 'nm_razao_social',    
  
--select * from vw_destinatario  
  
      d.cd_pedido_importacao,  
      d.nm_ref_documento_pagar,  
      d.cd_tipo_destinatario,  
  
      case when isnull(d.cd_tipo_destinatario,2)>0 then    
        td.nm_tipo_destinatario  
      else  
        case when (isnull(d.cd_empresa_diversa, 0) <> 0) then 'Empresa Diversa'    
             when (isnull(d.cd_contrato_pagar,  0) <> 0) then 'Contrato'    
             when (isnull(d.cd_funcionario,     0) <> 0) then 'Funcionário'    
        end  
  
      end                                 as 'nm_tipo_destinatario',  
  
      d.cd_di,  
      di.nm_di,  
  
      --Dados do Pagamento-----------------------------------------------------------------  
  
      isnull(wb.vl_total_pagamento,0)  
  
   -  
  
   case when isnull(d.vl_saldo_documento_pagar,0)<=0 then  
  
      isnull(( select top 1 fa.vl_adiantamento_parcela  
            
        from   
          nota_entrada_parcela fa with (nolock)   
        where  
          fa.cd_fornecedor      = d.cd_fornecedor      
          and  
    fa.cd_ident_parc_nota_entr = d.cd_identificacao_document  
    and  
    isnull(fa.vl_adiantamento_parcela,0)>0  
    ),0)  
  
       else  
      0.00  
    end  
  
  
                                          as vl_pagamento_baixa,  
  
      ----------------------------------------------------------------------------------------------------------  
      wb.vl_juros_pagamento               as vl_juros_baixa,  
      wb.vl_desconto_documento            as vl_desconto_baixa,  
      wb.vl_abatimento_documento          as vl_abatimento_baixa,  
      wb.vl_multa_documento               as vl_multa_baixa,  
      wb.vl_outros_pagamento              as vl_outros_pagamento,  
  
      wb.dt_pagamento_documento,  
  
      tc.nm_tipo_caixa,  
      b.cd_numero_banco,  
      cab.nm_conta_banco,  
     case when isnull(b.nm_banco,'') <> ''   
      then  isnull(b.nm_banco,'') + ' - ' + isnull(cab.nm_contato_agencia_banco,'')  
      else ''  
     end                                 as nm_banco,  
  
      -- Diego - 16.05.2012 - adição do campo empresa              
  
      --e.nm_fantasia_empresa,  
  
   case when isnull(dpe.cd_documento_pagar,0)>0 and isnull(dpe.cd_empresa,0)>0 then  
     isnull(efd.nm_fantasia_empresa,'')  
      else  
      case when isnull(efd.nm_fantasia_empresa,'') = ''  
        then case when isnull(efn.nm_fantasia_empresa,'') = ''  
               then e.nm_fantasia_empresa  
               else isnull(efn.nm_fantasia_empresa,'')  
             end  
        else isnull(efd.nm_fantasia_empresa,'')  
  end  
      end                                 as nm_fantasia_empresa,  
  
      --Dados do Lote-----------------------------------------------------------------------  
  
      isnull(d.cd_lote_pagar,0)           as cd_lote_pagar,  
      isnull(lp.cd_identificacao_lote,'') as cd_identificacao_lote,  
  
      case when isnull(wb.cd_identificao_pagamento,'') <> '' then  
     isnull(wb.cd_identificao_pagamento,'')  
   else  
     isnull(d.cd_identificacao_document,'')   
   end                                      as cd_identificao_pagamento,  
      wb.dt_debito_bordero,  
  
      isnull(d.ic_previsao_documento,'N')      as ic_previsao_documento,  
      isnull(dpb.nm_codigo_barra_documento,'') as nm_codigo_barra_documento,  
    day(d.dt_vencimento_documento)           as dia_vencimento_documento,  
   month(d.dt_vencimento_documento)         as mes_vencimento_documento,  
   year(d.dt_vencimento_documento)          as ano_vencimento_documento,  
   isnull(d.cd_pedido_compra,0)             as cd_pedido_compra,  
      d.cd_nota_fiscal_entrada,  
   d.cd_serie_nota_fiscal_entr,  
      d.cd_serie_nota_fiscal_entr as nm_serie_nota_fiscal,  
   case when isnull(cc.sg_centro_custo,'')<>'' then cc.sg_centro_custo else cast(nm_centro_custo as char(10)) end as sg_centro_custo,  
    dpp.dt_programacao,  
    d.dt_selecao_documento,  
    d.dt_envio_banco,   
    isnull(d.ic_envio_documento,'N') as ic_envio_documento,   
 (select top 1 uu.nm_fantasia_usuario   
  from   
    Plano_Financeiro_Responsavel pfr         with (nolock)   
    left outer join egisadmin.dbo.usuario uu with (nolock) on uu.cd_usuario = pfr.cd_usuario_responsavel  
  where  
    pfr.cd_plano_financeiro = d.cd_plano_financeiro)  
   
 as nm_responsavel_conta  
      --(select top 1 snf.nm_serie_nota_fiscal from Serie_Nota_Fiscal snf where snf.cd_serie_nota_fiscal = cast(d.cd_serie_nota_fiscal_entr as int)) as nm_serie_nota_fiscal  
  
    --select * from fornecedor  
  
    into  
      #RelDocumentoAberto  
  
    from    
      Documento_Pagar d                           with (nolock)   
      left outer join vw_baixa_documento_pagar wb with (nolock) on wb.cd_documento_pagar    = d.cd_documento_pagar  
  
      left outer join tipo_caixa tc               with (nolock) on tc.cd_tipo_caixa         = wb.cd_tipo_caixa  
      left outer join conta_agencia_banco cab     with (nolock) on cab.cd_conta_banco       = wb.cd_conta_banco  
      left outer join banco b                     with (nolock) on b.cd_banco               = cab.cd_banco  
     
  
      left outer join Fornecedor fo               with (nolock) on fo.cd_fornecedor         = d.cd_fornecedor   
      left outer join Fornecedor_Contato f        with (nolock) on d.cd_fornecedor          = f.cd_fornecedor and  
                                                                   f.cd_contato_fornecedor  = 1     
  
      left outer join Tipo_conta_pagar c          with (nolock) on c.cd_tipo_conta_pagar    = d.cd_tipo_conta_pagar     
      left outer join Tipo_documento t            with (nolock) on t.cd_tipo_documento      = d.cd_tipo_documento     
  
      left outer join Plano_Financeiro pf         with (nolock) on pf.cd_plano_financeiro   = d.cd_plano_financeiro     
   --left outer join Plano_Financeiro_Responsavel pfr with (nolock) on pfr.cd_plano_financeiro = d.cd_plano_financeiro  
   --left outer join egisadmin.dbo.usuario uu    with (nolock) on uu.cd_usuario            = pfr.cd_usuario_responsavel  
      left outer join Moeda m                     with (nolock) on d.cd_moeda               = m.cd_moeda    
      left outer join Loja l                      with (nolock) on l.cd_loja                = d.cd_loja     
      left outer join invoice i                   with (nolock) on i.cd_invoice             = d.cd_invoice    
      left outer join Di                          with (nolock) on di.cd_di                 = d.cd_di  
      left outer join EgisAdmin.dbo.Usuario u     with (nolock) on d.cd_usuario             = u.cd_usuario    
      left outer join Portador pt                 with (nolock) on pt.cd_portador           = d.cd_portador  
      left outer join situacao_documento_pagar sd with (nolock) on sd.cd_situacao_documento = d.cd_situacao_documento  
      left outer join Autorizacao_Pagamento ap    with (nolock) on ap.cd_ap                 = d.cd_ap  
      left outer join EgisAdmin.dbo.Usuario uap   with (nolock) on uap.cd_usuario           = ap.cd_usuario_aprovacao  
      left outer join Imposto ip                  with (nolock) on ip.cd_imposto            = d.cd_imposto  
      left outer join Centro_Custo cc             with (nolock) on cc.cd_centro_custo       = d.cd_centro_custo  
  
      left outer join Empresa_Diversa z           with (nolock) on z.cd_empresa_diversa     = d.cd_empresa_diversa  
      left outer join Funcionario     k           with (nolock) on k.cd_funcionario         = d.cd_funcionario  
      left outer join Contrato_Pagar  w           with (nolock) on w.cd_contrato_pagar      = d.cd_contrato_pagar  
  
      left outer join vw_destinatario vw          with (nolock) on vw.cd_tipo_destinatario  = isnull(d.cd_tipo_destinatario,2) and  
                                                                   vw.cd_destinatario       = d.cd_fornecedor  
             
      left outer join Tipo_Destinatario td        with (nolock) on td.cd_tipo_destinatario  = case when isnull(d.cd_tipo_destinatario,2)>0   
                                                                                              then  
                                                                                                d.cd_tipo_destinatario  
                                                                                              else  
                                                                                                vw.cd_tipo_destinatario  
                                                                                              end  
  
     left outer join Lote_Pagar lp                 with (nolock) on lp.cd_lote_pagar          = d.cd_lote_pagar  
     left outer join Documento_pagar_empresa dpe   with (nolock) on dpe.cd_documento_pagar    = d.cd_documento_pagar  
     left outer join empresa_faturamento efd       with (nolock) on efd.cd_empresa            = dpe.cd_empresa  
  
     -- Diego - 16.05.2012 - adição da tabela empresa  
     left outer join egisadmin.dbo.empresa e     with (nolock) on e.cd_empresa             = isnull(d.cd_empresa,@cd_empresa)  
  
  
     left outer join Documento_pagar_Cod_Barra dpb with (nolock) on dpb.cd_documento_pagar = d.cd_documento_pagar  
     left outer join nota_entrada_empresa nee      with (nolock) on d.cd_nota_fiscal_entrada = cast(nee.cd_nota_entrada as varchar) and    
                                                                    d.cd_fornecedor = nee.cd_fornecedor and    
                                                                    d.cd_serie_nota_fiscal = nee.cd_serie_nota_fiscal   
     left outer join empresa_faturamento efn       with (nolock) on efn.cd_empresa         = nee.cd_empresa  
     left outer join documento_pagar_programacao dpp with(nolock) on dpp.cd_documento_pagar = d.cd_documento_pagar  
  
  
    where    
  
       d.cd_identificacao_document like case when @cd_identificacao = '' then d.cd_identificacao_document  else '%'+@cd_identificacao+'%' end and  
  
  
      case when @ic_tipo_filtro = 'V' then  
      IsNull(d.dt_vencimento_documento,'')  
      else  
       case when @ic_tipo_filtro = 'E' then  
          IsNull(d.dt_emissao_documento_paga,'')  
       else  
         case when @ic_tipo_filtro = 'P' then  
           isnull(wb.dt_pagamento_documento,'')  
         end  
       end  
      end   
  
      between case when @cd_identificacao= '' then @dt_inicial   
                                              else      
  
      case when @ic_tipo_filtro = 'V' then  
      IsNull(d.dt_vencimento_documento,'')  
      else  
       case when @ic_tipo_filtro = 'E' then  
          IsNull(d.dt_emissao_documento_paga,'')  
       else  
         case when @ic_tipo_filtro = 'P' then  
           isnull(wb.dt_pagamento_documento,'')  
         end  
       end  
      end   
      end  
  
      and case when @cd_identificacao = '' then @dt_final    
                                              else      
  
  
      case when @ic_tipo_filtro = 'V' then  
      IsNull(d.dt_vencimento_documento,'')  
      else  
       case when @ic_tipo_filtro = 'E' then  
          IsNull(d.dt_emissao_documento_paga,'')  
       else  
         case when @ic_tipo_filtro = 'P' then  
           isnull(wb.dt_pagamento_documento,'')  
         end  
       end  
      end   
  
      end  
                                                 
      and     
  
      IsNull(dt_cancelamento_documento,'') = (case when (@ic_filtrar_favorecido = 'S' or @ic_tipo_consulta = 'T' or @cd_identificacao <> '') then    
                                                    IsNull(dt_cancelamento_documento,'') else    
                                                     '' end )    
      and     
  
      IsNull(cast(str(vl_saldo_documento_pagar,25,2) as decimal(25,2)),0) =   
  
      case when @ic_tipo_consulta = 'P'  
      then  
        0.00  
      else  
        case when @ic_tipo_consulta = 'T' then  
           IsNull(cast(str(vl_saldo_documento_pagar,25,2) as decimal(25,2)),0)  
        else  
         (case when @ic_filtrar_favorecido = 'S'   
               then  
                 IsNull(cast(str(vl_saldo_documento_pagar,25,2) as decimal(25,2)),0)   
               else          
                 case when @ic_tipo_consulta = 'A'  
                 then  
                   case when ( IsNull(cast(str(vl_saldo_documento_pagar,25,2) as decimal(25,2)),0)>0 or @cd_identificacao <> '' )  
                   then  
                     IsNull(cast(str(vl_saldo_documento_pagar,25,2) as decimal(25,2)),0)  
                   else  
                     -1.001  
                   end  
                 end  
               end )    
        end   
  
      end     
  
  
      and     
    
      IsNull(case when (isnull(d.cd_empresa_diversa, 0)      <> 0)  and IsNull(@cd_tipo_favorecido,'') <> ''    then 'E'    
                  when (isnull(d.cd_contrato_pagar, 0)       <> 0)  and IsNull(@cd_tipo_favorecido,'') <> ''    then 'C'    
                  when (isnull(d.cd_funcionario, 0)          <> 0)  and IsNull(@cd_tipo_favorecido,'') <> ''    then 'F'    
                  when (isnull(d.nm_fantasia_fornecedor, '') <> '') and IsNull(@cd_tipo_favorecido,'') <> ''    then 'FO'    
                  when @ic_filtrar_favorecido = 'N' then ''    
             end,'') = IsNull(@cd_tipo_favorecido,'')     
  
       and     
    
       IsNull(case when (isnull(d.cd_empresa_diversa, 0) <> 0)       and IsNull(@cd_tipo_favorecido,'') <> '' then cast(d.cd_empresa_diversa as varchar(30))    
                   when (isnull(d.cd_contrato_pagar, 0)  <> 0)       and IsNull(@cd_tipo_favorecido,'') <> '' then cast(d.cd_contrato_pagar  as varchar(30))    
                   when (isnull(d.cd_funcionario,    0)  <> 0)       and IsNull(@cd_tipo_favorecido,'') <> '' then cast(d.cd_funcionario     as varchar(30))    
                   when (isnull(d.nm_fantasia_fornecedor, '') <> '') and IsNull(@cd_tipo_favorecido,'') <> '' then cast(d.cd_fornecedor      as varchar(30))    
                   when @ic_filtrar_favorecido = 'N' then ''    
               end,'') = IsNull(@cd_favorecido,'')   
                                                                                             
      ---------------------------------------------------------------------------------------------------------------------------------------  
      and IsNull(d.cd_identificacao_document,'') like IsNull(@cd_identificacao,'') + '%'   
      and isnull(d.cd_portador,0) = (case when isnull(@cd_portador,0) = 0 or (isnull(@cd_portador,0) =  -1) then isnull(d.cd_portador,0) else isnull(@cd_portador,0) end)   
      and isnull(d.ic_previsao_documento,'N') = case when isnull(@ic_previsao_documento,'N') = 'S' then 'S' else isnull(d.ic_previsao_documento,'N') end option(recompile)  
      
   
  
  
------------------------------------------------------------------------------------------------------------  
declare @vl_pagamento_documento_total       float = 0   
declare @vl_juros_documento_pagar_total     float = 0   
declare @vl_desconto_documento_total        float = 0   
declare @vl_outros_documento_total          float = 0   
declare @vl_abatimento_documento_total      float = 0   
declare @vl_multa_documento_total           float = 0   
declare @vl_total_geral                     float = 0   
declare @qt_documento                       int = 0   
-----------------------------------------------------------------------------------------------------------  
select   
  
@vl_total_geral                 = sum(vl_saldo_documento_pagar),  
@qt_documento                   = count(cd_identificacao_document)  
   
from #RelDocumentoAberto  
------------------------------------------------------------------------------------------------------------  
 if isnull(@cd_parametro,0) = 1    
 begin    
    select * from #RelDocumentoAberto    
  return    
 end    
--------------------------------------------------------------------------------------------------------------  
set @html_geral = '    <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 25%;">  
            '+@titulo+'  
        </p>  
    </div>  
 <div>  
    <table>    
       <tr>  
    <th>Vencimento</th>  
    <th>Conta</th>  
    <th>Fantasia</th>  
    <th>Documento</th>  
    <th>Tipo</th>  
    <th>Saldo</th>  
    <th>Centro Custo</th>  
    <th>Histórico</th>  
    <th>Emissão</th>  
    <th>Entrada</th>  
    <th>Classificação</th>  
    <th>Plano Financeiro</th>  
    <th>Empresa</th>  
    <th>Portador</th>  
  </tr>'  
          
--------------------------------------------------------------------------------------------------------------  
DECLARE @id int = 0   
  
WHILE EXISTS (SELECT TOP 1 cd_controle FROM #RelDocumentoAberto)  
BEGIN  
    SELECT TOP 1  
        @id                          = cd_controle,  
        
   
       @html_geral = @html_geral +  
          '<tr>  
      <td class="tamanho">'+isnull(dbo.fn_data_string(dt_vencimento_documento),'')+'</td>  
      <td class="tamanho">'+ISNULL(nm_tipo_conta_pagar,'')+'</td>  
      <td style="text-align: left;">'+iSNULL(nm_razao_social,'')+ '</td>  
   <td class="tamanho">'+ISNULL(cd_identificacao_document,'')+ '</td>  
   <td class="tamanho">'+ISNULL(nm_tipo_documento,'')+ '</td>  
   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(vl_saldo_documento_pagar),0)as nvarchar(20))+'</td>  
   <td class="tamanho">'+cast(ISNULL(sg_centro_custo,'')as nvarchar(20))+'</td>  
   <td class="tamanho">'+iSNULL(nm_observacao_documento,'')+ '</td>  
   <td class="tamanho">'+isnull(dbo.fn_data_string(dt_emissao_documento_paga),'')+'</td>  
   <td class="tamanho">'+iSNULL(cd_nota_fiscal_entrada,'')+ '</td>  
   <td class="tamanho">'+cast(ISNULL(cd_mascara_plano_financeiro,'')as nvarchar(20)) + '</td>  
   <td class="tamanho">'+iSNULL(nm_conta_plano_financeiro,'')+ '</td>  
   <td class="tamanho">'+iSNULL(nm_fantasia_empresa,'')+ '</td>  
   <td class="tamanho">'+iSNULL(nm_portador,'')+ '</td>  
        </tr>'  
  from #RelDocumentoAberto  
    DELETE FROM #RelDocumentoAberto WHERE cd_controle = @id  
END  
--------------------------------------------------------------------------------------------------------------------  
  
  
  
  
set @html_rodape ='  
 <tr >  
  <td class="tamanho"><strong>Total</strong></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"><strong>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_geral),0)as nvarchar(20)) + '</strong></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
  <td class="tamanho"></td>  
 </tr>  
 </table>  
 <div class="company-info">  
  <p><strong>'+@footerTitle+'</strong></p>  
 </div>  
    <p>'+@ds_relatorio+'</p>  
 </div>  
 <div class="section-title">  
     <p>Total de Documentos: '+cast(isnull(@qt_documento,0)as nvarchar(10))+'</p>  
    </div>  
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
  
---------------------  
  
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
 
  

  go
  
 --exec pr_egis_relatorio_documentos_atraso
