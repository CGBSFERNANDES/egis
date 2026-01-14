IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_movimento_caixa_etapa' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_movimento_caixa_etapa

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
--Objetivo         : Relatï¿½rio Padrï¿½o Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025
--Alteraï¿½ï¿½o        : 
-- use egissql_371
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_movimento_caixa_etapa
@cd_relatorio int   = 0,
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
declare @cd_parametro           int = 0  
  
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
   --@cd_numero_endereco   varchar(20) = '',  
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
declare @html_grid      nvarchar(max) = '' --Geral
  
declare @data_hora_atual nvarchar(50)  = ''  
  
set @html         = ''  
set @html_empresa = ''  
set @html_titulo  = ''  
set @html_cab_det = ''  
set @html_detalhe = ''  
set @html_rod_det = ''  
set @html_rodape  = ''  
set @html_geral   = ''  
set @html_grid    = ''
  
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
   text-align: center;  
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
------------------------------------------------------------------------------------------------------------------------  
select   
    identity(int,1,1)                as cd_controle,  
 mc.cd_movimento_caixa            as cd_movimento_caixa,  
 max(mc.dt_movimento_caixa)       as dt_movimento_caixa,  
 max(c.nm_fantasia_cliente)       as nm_fantasia_cliente,
 max(dbo.fn_formata_cpf(isnull(pvc.cd_cpf_informado,''))) as cd_cpf_informado,
 p.cd_produto                     as cd_produto,  
 p.nm_produto                     as nm_produto,  
 max(mc.cd_nota_saida)            as cd_nota_saida,  
 max(mci.qt_item_movimento_caixa) as qt_item_movimento_caixa,  
 max(mci.vl_item_movimento_caixa) as vl_item_movimento_caixa,  
 max(mci.vl_item_desconto)        as vl_item_desconto,  
 sum(((mci.qt_item_movimento_caixa * mci.vl_item_movimento_caixa) - mci.vl_item_desconto))  as vl_movimento_caixa,  
 max(o.nm_operador_caixa)         as nm_operador_caixa,  
 max(c.nm_endereco_cliente)       as nm_endereco_cliente,  
 max(c.cd_numero_endereco)        AS cd_numero_endereco,  
 max(c.cd_identifica_cep)         as cd_identifica_cep,  
 max(c.nm_bairro)                 as nm_bairro,  
 max(c.cd_telefone)               as cd_telefone,  
 max(c.cd_celular_cliente)        as cd_celular_cliente,  
 MAX(mc.nm_obs_movimento_caixa)   as nm_obs_movimento_caixa,  
 MAX(es.sg_estado)                as sg_estado,  
 MAX(ci.nm_cidade)                as nm_cidade,  
 max(mcp.cd_nsu_tef)              as cd_nsu_tef,  
 max(mcp.cd_autorizacao_tef)      as cd_autorizacao_tef  
 into  
 #MovimentoCaixaEtapa  
  
from   
 movimento_caixa mc  
left outer join cliente c                 on c.cd_cliente           = mc.cd_cliente  
left outer join movimento_caixa_item mci  on mci.cd_movimento_caixa = mc.cd_movimento_caixa  
left outer join produto p                 on p.cd_produto           = mci.cd_produto  
left outer join operador_caixa o          on o.cd_operador_caixa    = mc.cd_operador_caixa  
left outer join Estado es                 on es.cd_estado           = c.cd_estado        
left outer join Cidade ci                 on ci.cd_estado           = c.cd_estado      
                                         and ci.cd_cidade           = c.cd_cidade   
left outer join movimento_caixa_pagamento mcp on mcp.cd_movimento_caixa = mc.cd_movimento_caixa
left outer join Pedido_Venda_Caixa pvc    on pvc.cd_pedido_venda    = mci.cd_pedido_venda
  
where   
 mc.cd_movimento_caixa = @cd_documento  
  
group by   
 mc.cd_movimento_caixa,  
 p.cd_produto,            
 p.nm_produto  

-------------------------------------------------------------------------------------------------------------------------  

 select
 mci.cd_item_movimento_caixa      as cd_item_movimento_caixa,
 1                                as cd_item_ordem,
 mc.cd_movimento_caixa            as cd_movimento_caixa,  
 p.cd_produto                     as cd_produto,
 cast(p.nm_fantasia_produto as varchar(10)) as nm_fantasia_produto,
 p.nm_produto                     as nm_produto,
 mci.qt_item_movimento_caixa,
 mci.vl_item_movimento_caixa,
 ((mci.qt_item_movimento_caixa * mci.vl_item_movimento_caixa) /*- mci.vl_item_desconto*/)  as vl_movimento_caixa
into
  #MovAuxGrid
from   
 movimento_caixa mc   
left outer join movimento_caixa_item mci  on mci.cd_movimento_caixa = mc.cd_movimento_caixa  
left outer join produto p                 on p.cd_produto           = mci.cd_produto    
where   
 mc.cd_movimento_caixa = @cd_documento

union all

select
 mci.cd_item_movimento_caixa      as cd_item_movimento_caixa,
 2                                as cd_item_ordem,
 mc.cd_movimento_caixa            as cd_movimento_caixa,  
 p.cd_produto                     as cd_produto,
 cast(p.nm_fantasia_produto as varchar(10)) as nm_fantasia_produto,
 p.nm_produto                     as nm_produto,
 mci.qt_item_movimento_caixa,
 mci.vl_item_movimento_caixa,
 ((mci.qt_item_movimento_caixa * mci.vl_item_movimento_caixa) /*- mci.vl_item_desconto*/)  as vl_movimento_caixa
from   
 movimento_caixa mc   
left outer join movimento_caixa_item mci  on mci.cd_movimento_caixa = mc.cd_movimento_caixa  
left outer join produto p                 on p.cd_produto           = mci.cd_produto    
where   
 mc.cd_movimento_caixa = @cd_documento

 select
   identity(int,1,1) as cd_controle,
   *
 into
   #MovCaixaGrid
 from
   #MovAuxGrid
 order by
   cd_item_movimento_caixa,
   cd_item_ordem

-------------------------------------------------------------------------------------------------------------------------  
declare  
 @dt_movimento_caixa      datetime = '',  
 @nm_fantasia_cliente     varchar(60),
 @cd_cpf_informado        varchar(20),
 @cd_nota_saida           int = 0,  
 @vl_total                float = 0,  
 @nm_operador_caixa       varchar(60),  
 @nm_endereco_cliente     varchar(160),  
 @cd_numero_endereco      varchar(50),  
 @cd_identifica_cep       varchar(50),  
 @nm_bairro               varchar(100),  
 @cd_telefone    varchar(50),  
 @cd_celular_cliente      varchar(50),  
 @nm_obs_movimento_caixa  varchar(150),  
 @vl_item_desconto   float = 0,  
 @qt_item_movimento_caixa float = 0,  
 @vl_item_movimento_caixa float = 0,  
 @sg_estado_cliente       varchar(50),  
 @nm_cidade_cliente   varchar(50),  
 @cd_autorizacao_tef      varchar(50),  
 @cd_nsu_tef              varchar(50) 
 
select     
 @dt_movimento_caixa     = dt_movimento_caixa,  
 @nm_fantasia_cliente    = nm_fantasia_cliente,
 @cd_cpf_informado       = cd_cpf_informado,
 @cd_nota_saida          = cd_nota_saida,  
 @nm_operador_caixa      = nm_operador_caixa,  
 @nm_endereco_cliente    = nm_endereco_cliente,  
 @cd_numero_endereco     = cd_numero_endereco,  
 @cd_identifica_cep      = cd_identifica_cep,
 @sg_estado_cliente      = sg_estado,
 @nm_cidade_cliente      = nm_cidade,
 @nm_bairro              = nm_bairro,  
 @cd_telefone            = cd_telefone,  
 @cd_celular_cliente     = cd_celular_cliente,  
 @nm_obs_movimento_caixa = nm_obs_movimento_caixa,  
 @cd_autorizacao_tef     = cd_autorizacao_tef,  
 @cd_nsu_tef             = cd_nsu_tef  
  
from #MovimentoCaixaEtapa  
  
select   
 @vl_total                = sum(vl_movimento_caixa),  
 @vl_item_desconto        = SUM(vl_item_desconto),  
 @qt_item_movimento_caixa = SUM(qt_item_movimento_caixa),  
 @vl_item_movimento_caixa = SUM(vl_item_movimento_caixa)  
  
from #MovimentoCaixaEtapa  
-------------------------------------------------------------------------------------------------------------------------  
set  @html_geral ='    
<h3 class="section-title">Comprovante de Caixa Nº '+CAST(ISNULL(@cd_documento,0) as varchar(20))+'</h3>  
  <table>  
    <tr style="text-align:center;">  
      <th>Data Emissão</th>  
      <th>Cliente</th>  
      <th>Documento</th>  
      <th>Operador</th>  
   <th>NSU</th>  
   <th>Autorização</th>  
    </tr>  
    <tr style="text-align:center;">  
      <td>'+ISNULL(dbo.fn_data_string(@dt_movimento_caixa),'')+'</td>  
      <td>'+ISNULL(@nm_fantasia_cliente,'')+'</td>  
      <td>'+CAST(isnull(@cd_nota_saida,0) as varchar(20))+'</td>  
      <td>'+ISNULL(@nm_operador_caixa,'')+'</td>  
   <td>'+ISNULL(@cd_nsu_tef,'')+'</td>  
   <td>'+ISNULL(@cd_autorizacao_tef,'')+'</td>  
    </table>  
  <h3 style="font-weight: bold;">Itens</h3>    
    <table>  
    <tr style="text-align:center;">  
      <th>Produto</th>  
      <th>Qtd.</th>  
      <th>Unitário</th>  
      <th>Desconto</th>  
      <th>Total</th>  
    </tr>'  
--------------------------------------------------------------------------------------------------------------------------  
while exists ( select top 1 cd_controle from #MovimentoCaixaEtapa)  
begin  
 select top 1  
  
  @id                          = cd_controle,  
     @html_geral  = @html_geral + '  
                           <tr class="tamanho">  
         <td>'+isnull(nm_produto,'')+' ('+CAST(isnull(cd_produto,0) as varchar(20))+')</td>  
         <td>'+cast(isnull(qt_item_movimento_caixa,0)as nvarchar(20))+'</td>           
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_item_movimento_caixa),0)as nvarchar(20))+'</td>           
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_item_desconto),0)as nvarchar(20))+'</td>  
         <td>'+cast(isnull(dbo.fn_formata_valor(vl_movimento_caixa),0)as nvarchar(20))+'</td>  
          </tr>'  
  
     from #MovimentoCaixaEtapa  
  delete from #MovimentoCaixaEtapa where cd_controle = @id  
 end  
         
          
--------------------------------------------------------------------------------------------------------------  
  
set @html_rodape =  
   '<tr style="text-align:center;">  
      <td></td>  
      <td>'+cast(isnull(@qt_item_movimento_caixa,0)as nvarchar(20))+'</td>    
      <td>'+cast(isnull(dbo.fn_formata_valor(@vl_item_movimento_caixa),0)as nvarchar(20))+'</td>   
      <td>'+cast(isnull(dbo.fn_formata_valor(@vl_item_desconto),0)as nvarchar(20))+'</td>   
      <td>'+cast(isnull(dbo.fn_formata_valor(@vl_total),0)as nvarchar(20))+'</td>   
    </tr>    
    </table>  
 <h3 style="font-weight: bold;">Cliente</h3>  
 <table>  
  <tr>  
   <th>Entrega</th>  
            <th>Número</th>  
            <th>Cep</th>  
            <th>Estado</th>  
            <th>Cidade</th>  
   <th>Bairro</th>  
   <th>Telefone</th>   
   <th>Celular</th>  
  </tr>  
  <tr class="tamanho">  
   <td>'+isnull(@nm_endereco_cliente,'')+'</td>  
   <td>'+isnull(@cd_numero_endereco,'')+'</td>  
   <td>'+isnull(dbo.fn_formata_cep(@cd_identifica_cep),'')+'</td>  
   <td>'+isnull(@sg_estado_cliente,'')+'</td>  
   <td>'+isnull(@nm_cidade_cliente,'')+'</td>  
   <td>'+isnull(@nm_bairro,'')+'</td>  
   <td>'+isnull(@cd_telefone,'')+'</td>  
   <td>'+isnull(@cd_celular_cliente,'')+'</td>  
  </tr>  
 </table>  
 <p><strong>Observações: </strong>'+ISNULL(@nm_obs_movimento_caixa,'')+'</p>  
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

-- NOVO HTML Comprovante--------------------------------------------------------------------------------------

while exists ( select top 1 cd_controle from #MovCaixaGrid)  
begin  
 select top 1  
   @id = cd_controle,  
   @html_grid  = @html_grid + 
      case when cd_item_ordem = 1
      then
      '<tr>
        <td class="col-prod">'+isnull(nm_fantasia_produto,'')+'</td>
        <td class="col-qtd">'+cast(isnull(dbo.fn_formata_valor(qt_item_movimento_caixa),0)as nvarchar(20))+'</td>
        <td class="col-unit">'+cast(isnull(dbo.fn_formata_valor(vl_item_movimento_caixa),0)as nvarchar(20))+'</td>
        <td class="col-tot">'+cast(isnull(dbo.fn_formata_valor(vl_movimento_caixa),0)as nvarchar(20))+'</td>
        <td class="col-it"></td>
      </tr>'
      else
      '<tr>
        <td class="produto-desc" colspan="4">'+isnull(nm_produto,'')+'</td>
        <td class="col-it">'+cast(isnull(cd_item_movimento_caixa,0)as nvarchar(20))+'</td>
      </tr>'
      end
  from #MovCaixaGrid  

  delete from #MovCaixaGrid where cd_controle = @id  
 end

set @html =
'<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <title>'+@titulo+'</title>
  <style>
    body {
      font-family: "Courier New", monospace;
      font-size: 12px;
      line-height: 1.2;
      margin: 0;
      padding: 5px;
      color: #000;
      width: 80mm;
      max-width: 80mm;
    }

    .cabecalho {
      text-align: center;
      font-weight: bold;
      margin-bottom: 8px;
      border-bottom: 1px dashed #000;
      padding-bottom: 3px;
      font-size: 16px;
    }

    .linha {
      display: flex;
      justify-content: space-between;
      gap: 8px;
      margin: 2px 0;
    }

    .rotulo { font-weight: bold; }

    .divisor {
      border-top: 1px dashed #000;
      margin: 8px 0;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 6px;
    }

    th, td {
      padding: 2px 0;
      vertical-align: top;
    }

    th {
      text-align: left;
      font-weight: bold;
      border-bottom: 1px solid #000;
      padding-bottom: 3px;
    }

    .col-prod { width: 44%; }
    .col-qtd  { width: 14%; text-align: right; }
    .col-unit { width: 16%; text-align: right; }
    .col-tot  { width: 18%; text-align: right; }
    .col-it   { width: 8%;  text-align: right; }

    .produto-desc {
      font-size: 11px;
      padding-top: 0;
      padding-bottom: 4px;
    }

    .total {
      display: flex;
      justify-content: space-between;
      align-items: baseline;
      font-weight: bold;
      margin-top: 6px;
      font-size: 14px;
    }

    .rodape {
      font-size: 10px;
      text-align: center;
      margin-top: 10px;
    }

    @media print {
      body { margin: 0; padding: 2mm; }
      @page { size: 80mm auto; margin: 0mm; }
      * {
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
      }
    }
  </style>
</head>

<body>
  <div class="cabecalho">Comprovante Nº 5462</div>

  <div class="linha">
    <div><span class="rotulo">Data Emissão</span></div>
    <div>'+ISNULL(dbo.fn_data_string(@dt_movimento_caixa),'')+'</div>
  </div>
  <div class="linha">
    <div><span class="rotulo">Cliente</span></div>
    <div>'+ISNULL(@nm_fantasia_cliente,'')+'</div>
  </div>
  <div class="linha">
    <div><span class="rotulo">Documento</span></div>
    <div>'+isnull(@cd_cpf_informado,'')+'</div>
  </div>

  <div class="divisor"></div>

  <table>
    <thead>
      <tr>
        <th class="col-prod">Produto</th>
        <th class="col-qtd">Qtd.</th>
        <th class="col-unit">Unit.</th>
        <th class="col-tot">Total R$</th>
        <th class="col-it">It.</th>
      </tr>
    </thead>
    <tbody>'
    +@html_grid+
    '</tbody>
  </table>

  <div class="divisor"></div>

  <div class="total">
    <div>Total R$ :</div>
    <div>'+cast(isnull(dbo.fn_formata_valor(@vl_total),0)as nvarchar(20))+'</div>
  </div>

  <div style="margin-top:6px;">
    <span class="rotulo">Operador</span>
    <span style="float:right;">'+ISNULL(@nm_operador_caixa,'')+'</span>
  </div>

  <div class="divisor"></div>

  <div><span class="rotulo">ENTREGA</span> '+isnull(@nm_endereco_cliente,'')+'</div>

  <div class="linha">
    <div><span class="rotulo">Número</span> '+isnull(@cd_numero_endereco,'')+'</div>
    <div><span class="rotulo">Cep</span> '+isnull(dbo.fn_formata_cep(@cd_identifica_cep),'')+'</div>
  </div>

  <div class="linha">
    <div><span class="rotulo">Estado</span> '+isnull(@sg_estado_cliente,'')+'</div>
    <div><span class="rotulo">Cidade</span> '+isnull(@nm_cidade_cliente,'')+'</div>
  </div>

  <div class="linha">
    <div><span class="rotulo">Bairro</span> '+isnull(@nm_bairro,'')+'</div>
    <div><span class="rotulo">Telefone</span> '+isnull(@cd_telefone,'')+'</div>
  </div>

  <div class="linha">
    <div><span class="rotulo">Celular</span> '+isnull(@cd_celular_cliente,'')+'</div>
  </div>

  <div class="linha">
    <div><span class="rotulo">Observações</span> '+ISNULL(@nm_obs_movimento_caixa,'')+'</div>
  </div>

  <div class="rodape" id="dataHora"></div>

  <script>
    // Mostra data/hora atual no rodapé (como no seu exemplo)
    document.getElementById("dataHora").textContent = new Date().toLocaleString("pt-BR");

    // Dispara impressão automaticamente
    window.print();
  </script>
</body>
</html>
'
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_movimento_caixa_etapa 399,''
------------------------------------------------------------------------------

