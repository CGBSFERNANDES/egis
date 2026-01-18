IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_composicao_movimento_caixa' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_composicao_movimento_caixa

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_abertura_caixa  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_fluxo_caixa  
-------------------------------------------------------------------------------  
--GBS Global Business Solution Ltda                                        2024  
-------------------------------------------------------------------------------  
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020  
--  
--Autor(es)        : Joao Pedro Marcal  
--Banco de Dados   : Egissql - Banco do Cliente   
--  
--Objetivo         : Relat?rio Padr?o Egis HTML - EgisMob, EgisNet, Egis  
--Data             : 10.01.2025  
--Altera??o        :   
-- use egissql_360  
--  
------------------------------------------------------------------------------  
create or alter procedure pr_egis_relatorio_composicao_movimento_caixa  
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
declare @id                     int = 0   
declare @cd_vendedor            int  
declare @cd_plano_financeiro    int = 0  
--declare @cd_parametro           int = 0  
  
--Dados do Relat?rio---------------------------------------------------------------------------------  
  
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
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'  
  
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
--------------------------------------------------------------------------------------------------------------------------  
select    
  @dt_inicial    = isnull(dt_inicial,''),  
  @dt_final      = isnull(dt_final,'')  
    
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
--Dados do Relat?rio  
---------------------------------------------------------------------------------------------------------------------------------------------  
  
declare @html            nvarchar(max) = '' --Total  
declare @html_empresa    nvarchar(max) = '' --Cabe?alho da Empresa  
declare @html_titulo     nvarchar(max) = '' --T?tulo  
declare @html_cab_det    nvarchar(max) = '' --Cabe?alho do Detalhe  
declare @html_detalhe    nvarchar(max) = '' --Detalhes  
declare @html_rod_det    nvarchar(max) = '' --Rodap? do Detalhe  
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
  
-- Obt?m a data e hora atual  
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)  
------------------------------  
  
--Cabe?alho da Empresa----------------------------------------------------------------------------------------------------------------------  
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
      padding: 20px;  
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
      padding: 10px;  
    }  
  
    
    th {  
      background-color: #f2f2f2;  
      color: #333;  
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
      font-size: 14px;  
      text-align: center;  
    }  
 .tamanhoFinal {  
      font-size: 16px;  
      text-align: center;  
    font-weight: bold;  
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
    
    
if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    
  
  
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)  
--set @dt_inicial = '11/01/2025'  
--set @dt_final = '11/30/2025'  
--------------------------------------------------------------------------------------------------------  
select
  dt_movimento_caixa  as dt_movimento_caixa,  
  case when mc.cd_abertura_caixa is not null 
        and mc.cd_fechamento_caixa is null
        and mc.cd_tipo_pagamento is null
        and mc.cd_motivo_retirada_caixa is null
  then isnull(vl_movimento_caixa,0)
  else 0.00 end as vl_abertura,

  case when tpc.cd_tipo_pagamento_net = 1
  then isnull(vl_movimento_caixa,0)-isnull(vl_desconto,0)
  else 0.00 end as vl_dinheiro,

  case when tpc.cd_tipo_pagamento_net = 8
  then isnull(vl_movimento_caixa,0)-isnull(vl_desconto,0)
  else 0.00 end as vl_pix,  

  case when tpc.cd_tipo_pagamento_net = 4
  then isnull(vl_movimento_caixa,0)-isnull(vl_desconto,0)
  else 0.00 end as vl_debito,  

  case when tpc.cd_tipo_pagamento_net = 3
  then isnull(vl_movimento_caixa,0)-isnull(vl_desconto,0)
  else 0.00 end as vl_credito,

  case when tpc.cd_tipo_pagamento_net in (6,9)
  then isnull(vl_movimento_caixa,0)-isnull(vl_desconto,0)
  else 0.00 end as vl_voucher,  

  case when tpc.cd_tipo_pagamento_net = 10
  then isnull(vl_movimento_caixa,0)-isnull(vl_desconto,0)
  else 0.00 end as vl_ifood,
          
  case when mc.cd_fechamento_caixa is null
        and mc.cd_tipo_pagamento is null
        and mc.cd_motivo_retirada_caixa is not null
  then isnull(vl_movimento_caixa,0)
  else 0.00 end as vl_saida_retirada, 
          
  --SE PRECISAR SOMAR A ABERTURA SÓ DESCOMENTAR
  --case when mc.cd_abertura_caixa is not null 
  --      and mc.cd_fechamento_caixa is null
  --      and mc.cd_tipo_pagamento is null
  --      and mc.cd_motivo_retirada_caixa is null
  --then isnull(vl_movimento_caixa,0)
  --else 0.00 end
  --+
  case when tpc.cd_tipo_pagamento_net in (1,3,4,6,8,9,10)
  then isnull(vl_movimento_caixa,0)-isnull(vl_desconto,0)
  else 0.00 end as vl_fechamento_geral, 
  
  case when mc.cd_abertura_caixa is not null 
        and mc.cd_fechamento_caixa is null
        and mc.cd_tipo_pagamento is null
        and mc.cd_motivo_retirada_caixa is null
  then isnull(vl_movimento_caixa,0)
  else 0.00 end  
  +  
  case when tpc.cd_tipo_pagamento_net = 1
      then isnull(vl_movimento_caixa,0)-isnull(vl_desconto,0)
      else 0.00 end   
  -  
  case when mc.cd_fechamento_caixa is null
            and mc.cd_tipo_pagamento is null
            and mc.cd_motivo_retirada_caixa is not null
      then isnull(vl_movimento_caixa,0)
      else 0.00 end                         as vl_liquido
into 
  #ComposicaoMovimentoCaixaAux 
  
from   
  Movimento_Caixa mc  
  left outer join Tipo_Pagamento_Caixa tpc on tpc.cd_tipo_pagamento = mc.cd_tipo_pagamento
where  
  dt_movimento_caixa between @dt_inicial and @dt_final 
  and
  mc.dt_cancel_movimento_caixa is null
  and
  mc.cd_movimento_caixa not in (select x.cd_movimento_caixa from movimento_caixa_divisao x)

union all

select 
  dt_movimento_caixa  as dt_movimento_caixa,  
  0.00 as vl_abertura,

  case when tpc.cd_tipo_pagamento_net = 1
  then isnull(vl_pagamento,0)
  else 0.00 end as vl_dinheiro,

  case when tpc.cd_tipo_pagamento_net = 8
  then isnull(vl_pagamento,0)
  else 0.00 end as vl_pix,  

  case when tpc.cd_tipo_pagamento_net = 4
  then isnull(vl_pagamento,0)
  else 0.00 end as vl_debito,  

  case when tpc.cd_tipo_pagamento_net = 3
  then isnull(vl_pagamento,0)
  else 0.00 end as vl_credito,

  case when tpc.cd_tipo_pagamento_net in (6,9)
  then isnull(vl_pagamento,0)
  else 0.00 end as vl_voucher,  

  case when tpc.cd_tipo_pagamento_net = 10
  then isnull(vl_pagamento,0)
  else 0.00 end as vl_ifood,
              
  0.00 as vl_saida_retirada, 
              
  case when tpc.cd_tipo_pagamento_net in (1,3,4,6,8,9,10)
  then isnull(vl_pagamento,0)
  else 0.00 end as vl_fechamento_geral, 
      
  0.00 as vl_liquido  
  
from   
  Movimento_Caixa mc
  inner join movimento_caixa_divisao mcd on mcd.cd_movimento_caixa = mc.cd_movimento_caixa
  left outer join Tipo_Pagamento_Caixa tpc on tpc.cd_tipo_pagamento = mcd.cd_tipo_pagamento
where   
  dt_movimento_caixa between @dt_inicial and @dt_final 
  and
  mc.dt_cancel_movimento_caixa is null


select
  identity(int,1,1)        as cd_controle,
  dt_movimento_caixa       as dt_movimento_caixa,  
  sum(vl_abertura)         as vl_abertura,
  sum(vl_dinheiro)         as vl_dinheiro,
  sum(vl_pix)              as vl_pix,  
  sum(vl_debito)           as vl_debito,  
  sum(vl_credito)          as vl_credito,
  sum(vl_voucher)          as vl_voucher,  
  sum(vl_ifood)            as vl_ifood,
  sum(vl_saida_retirada)   as vl_saida_retirada, 
  sum(vl_fechamento_geral) as vl_fechamento_geral, 
  sum(vl_liquido)          as vl_liquido
into
  #ComposicaoMovimentoCaixa
from 
  #ComposicaoMovimentoCaixaAux
group by
  dt_movimento_caixa
order by
  dt_movimento_caixa

  
 --select * from #ComposicaoMovimentoCaixa return  
  
select   
    identity(int,1,1)                                       as cd_controle,  
 isnull(dbo.fn_data_string(dt_movimento_caixa),'')       as dt_movimento_caixa,  
 isnull(dbo.fn_formata_valor(vl_abertura),0)             as vl_abertura,  
 isnull(dbo.fn_formata_valor(vl_dinheiro),0)             as vl_dinheiro,  
 isnull(dbo.fn_formata_valor(vl_pix),0)                  as vl_pix,  
 isnull(dbo.fn_formata_valor(vl_debito),0)               as vl_debito,  
 isnull(dbo.fn_formata_valor(vl_credito),0)              as vl_credito,  
 isnull(dbo.fn_formata_valor(vl_saida_retirada),0)       as vl_saida_retirada,  
 isnull(dbo.fn_formata_valor(vl_fechamento_geral),0)     as vl_fechamento_geral,  
 isnull(dbo.fn_formata_valor(vl_liquido),0)              as vl_liquido--,  
 --isnull(dbo.fn_formata_valor(vl_fechamento_informado),0) as vl_fechamento_informado  
 into  
 #ComposicaoMovimentoCaixaTabela  
from   
 #ComposicaoMovimentoCaixa  
  
------------------------------------------------------------------------------------------------------------------------  
if isnull(@cd_parametro,0) = 1    
 begin    
    select * from #ComposicaoMovimentoCaixaTabela    
  return    
 end    
  
-------------------------------------------------------------------------------------------------------------------------  
DECLARE   
    @vl_pix                  float = 0,  
    @vl_debito               float = 0,  
    @vl_credito              float = 0,  
    @vl_movimento_caixa      float = 0,  
    @vl_dinheiro             float = 0,  
    @vl_cartao_debito        float = 0,  
    @vl_cartao_credito       float = 0,  
    @vl_saida_retirada       float = 0,  
    @vl_fechamento_geral     float = 0,  
    @vl_abertura_caixa       float = 0,  
    @vl_voucher              float = 0,
    @vl_ifood                float = 0,
    @vl_liquido              float = 0  
  
SELECT   
    @vl_voucher               = sum(vl_voucher),
    @vl_ifood                 = sum(vl_ifood),
    @vl_liquido               = sum(vl_liquido),  
    @vl_pix                   = sum(vl_pix),  
    @vl_dinheiro              = sum(vl_dinheiro),  
    @vl_debito                = sum(vl_debito),  
    @vl_saida_retirada        = sum(vl_saida_retirada),  
    @vl_credito               = sum(vl_credito),  
    @vl_fechamento_geral      = sum(vl_fechamento_geral),  
    @vl_abertura_caixa        = sum(vl_abertura)  
FROM #ComposicaoMovimentoCaixa  
  
 ---select * from #MovimentoCaixaRel return  
--------------------------------------------------------------------------------------------------------------------------  
set @html_geral = ' <div class="section-title">    
        <p style="display: inline;text-align: left;">Período: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>     
        <p style="display: inline; text-align: center; padding: 20%;">Composição Movimento de Caixa</p>    
    </div>  
 <table>  
 <tr style="text-align:center;">  
  <th>Data Movimento</th>  
  <th>Abertura</th>  
  <th>Dinheiro</th>  
  <th>Pix</th>  
  <th>Débito</th>  
  <th>Crédito</th>  
  <th>Voucher</th>  
  <th>IFood</th> 
  <th>Fechamento Geral</th>  
  <th>Saída Retirada</th>  
  <th>Fechamento Saldo</th>  
 </tr>'  
--------------------------------------------------------------------------------------------------------------------------  
while exists ( select top 1 cd_controle from #ComposicaoMovimentoCaixa)  
begin  
 select top 1  
  
  @id          = cd_controle,  
     @html_geral  = @html_geral + '  
                           <tr class="tamanho">  
         <td>'+isnull(dbo.fn_data_string(dt_movimento_caixa),'')+'</td>           
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_abertura),0)as nvarchar(20))+'</td>  
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_dinheiro),0)as nvarchar(20))+'</td>  
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_pix),0)as nvarchar(20))+'</td>  
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_debito),0)as nvarchar(20))+'</td>  
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_credito),0)as nvarchar(20))+'</td>  
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_voucher),0)as nvarchar(20))+'</td>  
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_ifood),0)as nvarchar(20))+'</td>  
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_fechamento_geral),0)as nvarchar(20))+'</td>  
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_saida_retirada),0)as nvarchar(20))+'</td>  
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_liquido),0)as nvarchar(20))+'</td>  
          </tr>'  
  
     from #ComposicaoMovimentoCaixa  
  delete from #ComposicaoMovimentoCaixa where cd_controle = @id  
 end  
         
          
--------------------------------------------------------------------------------------------------------------  
  
set @html_rodape =  
   '      <tr class="tamanhoFinal">  
   <td>Total</td>   
   <td>'+cast(isnull(dbo.fn_formata_valor(@vl_abertura_caixa),0)as nvarchar(20))+'</td>           
   <td>'+cast(isnull(dbo.fn_formata_valor(@vl_dinheiro),0)as nvarchar(20))+'</td>  
   <td>'+cast(isnull(dbo.fn_formata_valor(@vl_pix),0)as nvarchar(20))+'</td>   
   <td>'+cast(isnull(dbo.fn_formata_valor(@vl_debito),0)as nvarchar(20))+'</td>           
   <td>'+cast(isnull(dbo.fn_formata_valor(@vl_credito),0)as nvarchar(20))+'</td>  
   <td>'+cast(isnull(dbo.fn_formata_valor(@vl_voucher),0)as nvarchar(20))+'</td>  
   <td>'+cast(isnull(dbo.fn_formata_valor(@vl_ifood),0)as nvarchar(20))+'</td>  
   <td>'+cast(isnull(dbo.fn_formata_valor(@vl_fechamento_geral),0)as nvarchar(20))+'</td>  
   <td>'+cast(isnull(dbo.fn_formata_valor(@vl_saida_retirada),0)as nvarchar(20))+'</td>  
   <td>'+cast(isnull(dbo.fn_formata_valor(@vl_liquido),0)as nvarchar(20))+'</td> 
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
--exec pr_egis_relatorio_composicao_movimento_caixa 374,''
------------------------------------------------------------------------------

