IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_pedido_compra' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_pedido_compra

GO

-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_pedido_compra  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_pedido_compra  
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
create procedure pr_egis_relatorio_pedido_compra  
@cd_relatorio int   = 0,  
@cd_usuario   int   = 0,  
@cd_parametro int   = 0,  
@json nvarchar(max) = ''   
  
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
declare @cd_documento           int = 0  
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
  
  --select @json
  --return
  
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
set @cd_documento      = 0  
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
      
  -----------------------------------------------------------------------------------------------  
  
--select * from #json  
--return


-------------------------------------------------------------------------------------------------  
  
  select @cd_empresa             = valor from #json where campo = 'cd_empresa'               
  select @cd_modulo              = valor from #json where campo = 'cd_modulo'               
  select @cd_processo            = valor from #json where campo = 'cd_processo'               
  select @cd_item_processo       = valor from #json where campo = 'cd_item_processo'               
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'               
  select @cd_documento           = valor from #json where campo = 'cd_pedido_compra';
  
  set @cd_documento = isnull(@cd_documento,0)  
  

  if isnull(@cd_documento,0) = 0 
  begin
    select @cd_documento = valor from #json where campo = 'cd_documento_form';

    if isnull(@cd_documento,0) = 0
    begin
       select @cd_documento = valor from #json where campo = 'cd_documento';
    end

  end

  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'  
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'  
  
  
   
   if @cd_documento = 0  
   begin  
     select @cd_documento           = valor from #json where campo = 'cd_documento'  
     select @cd_item_documento      = valor from #json where campo = 'cd_item_documento' 
  
   end  
  
end  
  
  
--select @cd_documento


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
  
declare @data_hora_atual nvarchar(50)  = ''  
  
set @html         = ''  
set @html_empresa = ''  
set @html_grafico = ''  
set @html_titulo  = ''  
set @html_cab_det = ''  
set @html_detalhe = ''  
set @html_rod_det = ''  
set @html_rodape  = ''  
  
-- Obtém a data e hora atual  
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)  
------------------------------  
  
 --select  @data_hora_atual
--return
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
            margin-bottom: 20px;  
        }  
        table, th, td {  
            border: 1px solid #ddd;  
        }  
        th, td {  
            padding: 5px;  
             
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
--return

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
  
--select @nm_dados_cab_det  
  
--select * from #RelAtributo  
  
--select * from parametro_relatorio  
--delete from parametro_relatorio  
--update parametro_relatorio  
  
--Chamada dos Parametros do Relatório---  
  
--declare @cd_tipo_pedido int  
  
select  
  @dt_inicial     = dt_inicial,  
  @dt_final       = dt_final,  
  @cd_vendedor    = isnull(@cd_documento,0),  
  @cd_cliente     = isnull(cd_cliente,0),  
  @cd_tipo_pedido = 0 --cd_tipo_pedido  
from   
  Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
  and  
  cd_usuario   = @cd_usuario  
  
 --select @cd_cliente
 --return
  
  --select @cd_relatorio, @cd_usuario  
  
--select  
--*  
--from   
--  Parametro_Relatorio  
  
--where  
--  cd_relatorio = @cd_relatorio  
--  and  
--  cd_usuario   = @cd_usuario  
  
  
---> CCF <----  
---> alteração com o processo do relatório  
  
declare @vl_total          decimal(25,2) = 0.00  
declare @qt_total          int = 0  
declare @vl_total_vendedor decimal(25,2) = 0.00  
declare @qt_total_vendedor int = 0  

--declare @cd_ano            int = 0  
  
---Pedido Compra Tabela (Grid)----  
declare          
  @ic_desconto char(1)                
      
  set @ic_desconto= (select isnull(ic_desconto_item_pedido,'N')          
                                 from Parametro_Pedido_Compra with (nolock)           
                                 where          
                                   cd_empresa = @cd_empresa)     

------------------------------------------------------------------------------------------------  

select      
 ---distinct  top 10          
 i.cd_pedido_compra                                                             as cd_pedido_compra,          
 i.cd_item_pedido_compra                                                        as CD_ITEM,          
 ( case           
      when ( IsNull(i.nm_fantasia_produto, isNull(s.nm_servico,'')) = '' ) or ( IsNull(fp.nm_produto_fornecedor,'') <> '' ) then          
         ''               
      else           
        IsNull(i.nm_fantasia_produto, isNull(s.nm_servico,''))           
   end )                                                           as FANTASIA,     
 i.nm_fantasia_produto                                                               as FANTASIAG,      
 i.nm_produto                                                                        as NM_PROD,          
 cast(    
 ( case           
      when ( IsNull(i.nm_fantasia_produto, isNull(s.nm_servico,'')) = '' ) or ( IsNull(fp.nm_produto_fornecedor,'') <> '' ) then          
         i.nm_produto                
      else           
        case when IsNull(i.nm_fantasia_produto, isNull(s.nm_servico,'')) = 'ESPECIAL' then --isnull(ds_item_pedido_compra,'')          
     case when cast(isnull(ds_item_pedido_compra,'')as varchar) = ''           
      then i.nm_produto else isnull(ds_item_pedido_compra,'') end          
     else i.nm_produto          
   end end )   as varchar(120))                                                      as NM_PROD_ESPC,          
  isnull(cast(i.cd_produto_servico as varchar),'')                              as Serv,          
  isnull(i.nm_marca_item_pedido,'')                                             as MARCA,          
  (select sg_unidade_medida from Unidade_medida where i.cd_unidade_medida = cd_unidade_medida)               as 'SG_UNID',          
  i.dt_item_nec_ped_compra                                                                                           as DT_NEC,          
  i.dt_entrega_item_ped_compr                                                         as DT_ENTR,          
 isnull(cast(i.cd_pedido_venda as varchar),'')                                        as CD_PV,          
 case when isnull(um.ic_fator_conversao,'P') = 'K'          
   then          
     case when isnull(i.qt_item_pesbr_ped_compra,0) >0           
    then          
      i.qt_item_pesbr_ped_compra              
    else          
      i.qt_item_pedido_compra          
    end          
  else          
     isnull(i.qt_item_pedido_compra,0)           
  end                                                                      as QT_ITEM,          
 i.qt_saldo_item_ped_compra                                                as QT_SALDO,          
 isnull(i.pc_icms,0.00)                                                    as PC_ICMS,          
 isnull(i.pc_ipi,0.00)                                                     as PC_IPI,          
 case when @ic_desconto='S' then          
    i.vl_item_unitario_ped_comp          
  else          
    i.vl_item_unitario_ped_comp-          
 isnull((i.vl_item_unitario_ped_comp*( isnull(pc_item_descto_ped_compra,0)/100)),0) end                            as VL_ITEM,          
 isnull(i.pc_item_descto_ped_compra,0)                                                                               as VL_DESC,          
 isnull(i.vl_total_item_pedido_comp,0.00)                                                                          as VL_TOT,          
 isnull(pc.vl_total_pedido_ipi,0.00)                                                                               as vl_total_ipi_pedido,          
 isnull(pc.vl_total_pedido_ipi,0.00)+isnull(i.vl_total_item_pedido_comp,0.00)                                      as vl_total_com_ipi,          
 isnull(pc.vl_total_pedido_compra,0.00)                                                                            as vl_total_pedido_compra,          
 isnull(i.vl_desconto_item_pedido,0.00)                                                                            as vl_desconto_pedido_compra,          
 isnull(pc.vl_total_pedido_icms,0.00)                                                                              as vl_total_pedido_icms,          
 isnull(pc.vl_total_pedido_ipi,0.00)+isnull(i.vl_total_item_pedido_comp,0.00)+isnull(pc.vl_total_pedido_icms,0.00) as vl_total_com_impostos,          
 isnull(i.vl_icms_item_pedido_compra,0.00)                                                                         as vl_total_icms_pedido,  
 isnull(i.vl_ipi_item_pedido_compra,0.00)                                                                          as vl_ipi_item_pedido_compra        
into           
 #PedidoCompraItens          
from           
  pedido_compra_item i with(nolock)  
  inner join Pedido_Compra pc           with(nolock) on pc.cd_pedido_compra  = i.cd_pedido_Compra           
  left outer join Servico s             with(nolock) on s.cd_servico         = i.cd_servico          
  left outer join Fornecedor_Produto fp with(nolock) on fp.cd_fornecedor     = pc.cd_fornecedor and fp.cd_produto = i.cd_produto          
  left outer join Unidade_Medida um     with(nolock) on um.cd_unidade_medida = i.cd_unidade_medida          
          
where          
 --i.dt_item_canc_ped_compra is null    
 --  AND 
  i.cd_pedido_compra = isnull(@cd_documento,0)    
  
 

  --select @cd_documento

   --select * from #PedidoCompraItens
  --return


select           
  it.cd_pedido_compra,          
  it.VL_DESC                                                                as pc_item_descto_ped_compra,
 sum(isnull(it.vl_tot,0.00) - isnull(it.vl_desconto_pedido_compra,0.00))    as vl_total_com_desconto,          
 sum(isnull(it.vl_tot,0.00) + isnull(it.vl_desconto_pedido_compra,0.00))    as vl_total_pedido_compra,          
 sum(isnull(it.vl_tot,0.00))                                                as vl_TOTAL,          
 sum(isnull(it.vl_total_ipi_pedido,0.00))                                   as vl_total_ipi_pedido,          
 sum(isnull(it.vl_total_com_ipi,0.00))                                      as vl_total_com_ipi,          
 sum(isnull(it.vl_total_pedido_icms,0.00))                                  as vl_total_pedido_icms,          
 sum(isnull(it.vl_total_com_impostos,0.00))                                 as vl_total_com_impostos,          
 sum(isnull(it.vl_total_icms_pedido,0.00))                                  as vl_total_icms_pedido          
          
into          
 #TotalItens          
          
from           
 #PedidoCompraItens it          
          
group by           
 cd_pedido_compra,    
 VL_DESC

--select * from   #TotalItens
--return


------------------------------------------------------------------------------------------  
select  
  @vl_total = sum(VL_TOT),  
  @qt_total = sum(QT_ITEM)  
  
from  
  #PedidoCompraItens  
  
  --select @vl_total, @qt_total
  --return


select  
  IDENTITY(int,1,1) as cd_controle,  
  f.*,  
  pc_faturamento = cast(round(VL_TOT/@vl_total * 100,2) as decimal(25,2))  
  
into  
  #FinalFaturamentoMensal  
from  
  #PedidoCompraItens f  
  
  --select * from #FinalFaturamentoMensal
  --return

---Dados Fornecedor e Transportadora--------------------------------------------------------------------------

select
  top 1
  pc.cd_pedido_compra                       as cd_pedido_compra,          
  pc.dt_pedido_compra                       as dt_pedido_compra,          
  dq.cd_identificacao_documento             as cd_identificacao_documento,          
  sp.sg_status_pedido                       as sg_status_pedido,               
-- Dados do Fornecedor -----------------------------------------------------          
  fo.nm_razao_social                        as nm_razao_social_fornecedor,                  
  fo.nm_fantasia_fornecedor                 as nm_fantasia_fornecedor,          
  pc.nm_ref_pedido_compra                   as nm_ref_pedido_compra,           
  isnull(tp.ic_pedido_mat_prima,'N')                      as 'ic_pedido_mat_prima',          
   case when isnull(co.cd_fax_contato_fornecedor,'') <> '' then          
    co.cd_fax_contato_fornecedor          
   else           
     fo.cd_fax end                                         as cd_fax_fornecedor,                                
   case when isnull(co.cd_telefone_contato_forne,'')<>'' then          
     co.cd_telefone_contato_forne           
   else          
     fo.cd_telefone end                          as cd_telefone_fornecedor,                     
    case when isnull(co.cd_ddd_contato_fornecedor,'')<>'' then          
     co.cd_ddd_contato_fornecedor          
   else          
     fo.cd_ddd                
   end                                   as cd_ddd_fornecedor,           
          
   fo.cd_fornecedor                     as cd_fornecedor,                            
    IsNull(RTrim(LTrim(fo.nm_endereco_fornecedor)) + ',','')+          
    IsNull(RTrim(LTrim(fo.cd_numero_endereco)) + ' - ','')+          
    IsNull(RTrim(LTrim(fo.nm_bairro)) + ' - ','')+          
    IsNull(RTrim(LTrim(cf.nm_cidade)) + '/','')+          
    IsNull(RTrim(LTrim(ef.sg_estado)) + ' - ','')      as 'nm_endereco_fornecedor',          
          
    IsNull(RTrim(LTrim(fo.nm_endereco_fornecedor)) + ',','')+          
    IsNull(RTrim(LTrim(fo.cd_numero_endereco)) + ' - ','')+          
    IsNull(RTrim(LTrim(fo.nm_bairro)) + ' - ','')+          
    IsNull(RTrim(LTrim(cf.nm_cidade)) + '/','')+          
    IsNull(RTrim(LTrim(ef.sg_estado)) + ' - ','')+'CEP:'+          
    isnull(Rtrim(Ltrim(fo.cd_cep)),'')                    as 'nm_end_fornecedor',--OPORTUNA          
    IsNull(RTrim(LTrim(fo.nm_endereco_fornecedor)),'')        as nm_endereco_for,   
 IsNull(RTrim(LTrim(fo.cd_numero_endereco)),'')            as cd_num_for,   
 IsNull(RTrim(LTrim(fo.nm_bairro)),'')                     as nm_bairro_for,   
 IsNull(RTrim(LTrim(cf.nm_cidade)),'')                     as nm_cidade_for,   
 isnull(Rtrim(Ltrim(fo.cd_cep)),'')                        as cd_cep_for,  
 IsNull(RTrim(LTrim(ef.sg_estado)),'')                     as sg_estado_for,        
   fo.cd_cnpj_fornecedor                                   as cd_cnpj_fornecedor,          
    dbo.fn_formata_cnpj(fo.cd_cnpj_fornecedor)              as cd_cnpj_forn,--OPORTUNA           
    case when isnull(co.cd_email_contato_forneced,'')<>'' then          
     co.cd_email_contato_forneced          
   else          
     fo.nm_email_fornecedor          
   end                                      as nm_email_fornecedor,          
   fo.cd_inscmunicipal                      as cd_inscmunicipal_fornecedor,          
   fo.cd_inscestadual                       as cd_inscestadual_fornecedor,          
  pc.nm_pedfornec_pedido_compr                            as nm_pedfornec_pedido_compr,            
             
  -- Dados da Transportadora --------------------------------------------------          
  tr.nm_transportadora                   as nm_transportadora,          
   IsNull(RTrim(LTrim(tr.nm_endereco)) + ',','')+          
    IsNull(RTrim(LTrim(tr.cd_numero_endereco)) + ' - ','')+          
    IsNull(RTrim(LTrim(tr.nm_bairro)) + ' - ','')+          
    IsNull(RTrim(LTrim(ct.nm_cidade)) + '/','')+          
    IsNull(RTrim(LTrim(et.sg_estado)) + ' - ','')+          
    IsNull(RTrim(LTrim(tr.cd_cep)),'')             as nm_endereco_transp,
  --  
   fo.cd_cep                                       as cd_cep,          
   pc.cd_contato_fornecedor                        as cd_contato_fornecedor,          
   tr.cd_ddd                                       as cd_ddd_transp,          
   tr.cd_telefone                                  as cd_telefone_transp,          
   tr.nm_email_transportadora                      as nm_email_transportadora,          
   tr.cd_cnpj_transportadora                       as cd_cnpj_transportadora,          
   tr.cd_insc_estadual                             as cd_inscestadual_transportadora,          
            
  -- Dados Pedido de Compra ----------------------------------------------------                  
  pc.nm_pedfornec_pedido_compr                     as nm_pedfornec_pedido_compra,      
  co.nm_contato_fornecedor                         as nm_contato_fornec,      
  co.nm_fantasia_contato_forne                     as nm_fantasia_contato_forne,          
  co.cd_ddd_contato_fornecedor              as cd_ddd_contato_fornecedor,          
  co.cd_telefone_contato_forne                as cd_telefone_contato_forne,          
  co.cd_fax_contato_fornecedor                            as cd_fax_contato_fornecedor,          
  cp.nm_condicao_pagamento                as nm_condicao_pagamento,          
  pc.dt_nec_pedido_compra                 as dt_nec_pedido_compra,          
  ap.nm_aplicacao_produto                 as nm_aplicacao_produto,          
  de.nm_destinacao_produto                                as nm_destinacao_produto,          
  cc.nm_centro_custo                                      as nm_centro_custo,           
  cc.cd_centro_custo                                      as cd_centro_custo,          
    (select top 1 proj.cd_interno_projeto           
     from requisicao_compra_item rci           
     left outer join projeto proj           
     on proj.cd_projeto = rci.cd_projeto          
     where rci.cd_requisicao_compra = rc.cd_requisicao_compra)  as nm_obra,--projeto          
          
    efo.nm_empresa                                          as razao_empresa_faturamento,          
    dbo.fn_formata_cnpj(efo.cd_cnpj_empresa)                as cnpj_emp_faturamento,         
    isnull(efo.cd_telefone,'')                              as telefone_empresa_faturamento,        
    isnull(efo.nm_endereco,'')+','+          
    isnull(efo.cd_numero,'')                                as nm_end_empresa_faturamento_diversos,            
        
    efemp.nm_empresa                                          as NM_EMPRESA_FATURAMENTO,          
    dbo.fn_formata_cnpj(efemp.cd_cnpj_empresa)                as CNPJ_EMPRESA_FATURAMENTO,  
    efemp.cd_ie_empresa                                       as nm_ie_empresa,         
    ISNULL(efemp.cd_telefone,'')                              as TEL_EMPRESA_FATURAMENTO,        
    isnull(efemp.nm_endereco,'')+','+          
    isnull(efemp.cd_numero,'')                                as NM_END_EMPRESA_FATURAMENTO,         
--------------------------------------------------------------------------------------------------        
    isnull(ltrim(rtrim(efemp.nm_endereco)),'') +', '  +          
    isnull(ltrim(rtrim(efemp.cd_numero)),'')   +' - ' +   
 isnull(ltrim(rtrim(efemp.nm_bairro)),'')   +' '   +    
 isnull(ltrim(rtrim(cef.nm_cidade)),'')     +' / ' +  
 isnull(ltrim(rtrim(eef.sg_estado)),'')     +' - ' +   
 isnull(ltrim(rtrim(efemp.cd_cep)),'')                       as nm_end_emp_fat_completo,   
    eo.nm_empreendimento                                     as nm_empreedimento,          
    rc.cd_requisicao_compra                                  as cd_requisicao_compra,          
    IsNull(RTrim(LTrim(eo.nm_endereco)) + ',','')+          
    IsNull(RTrim(LTrim(eo.cd_numero)) + ' - ','')+          
    IsNull(RTrim(LTrim(eo.nm_bairro)) + ' - ','')+          
    IsNull(RTrim(LTrim(ceo.nm_cidade)) + '/','')+'CEP:'+          
    isnull(Rtrim(Ltrim(eo.cd_cep)),'')                      as 'nm_empreendimento_entrega',   
          
           
    IsNull(RTrim(LTrim(isnull(wd.nm_endereco,ee.nm_endereco_entrega))) + ',','')+          
    IsNull(RTrim(LTrim(isnull(wd.nm_complemento_endereco, ee.nm_compl_end_entrega))) + ' - ','')+          
    IsNull(RTrim(LTrim(isnull(wd.nm_bairro,ee.nm_bairro_entrega))) + ' - ','')+          
    IsNull(RTrim(LTrim(isnull(wd.nm_cidade,cee.nm_cidade))) + '/','')+          
    IsNull(RTrim(LTrim(isnull(wd.sg_estado,eee.sg_estado))) + ' - ','') as 'nm_endereco_entrega',   
 ee.cd_cep_entrega,             
    -- Totais dos Itens ----------------------------------------------------------          
  ti.vl_total_com_desconto                                as VL_TCOM_DESC,          
  isnull(ti.vl_TOTAL,0.00)                                as VL_TOT_PROD,          
  ti.vl_total_pedido_compra                               as VL_TOT_PED,          
  pc.vl_total_ipi_pedido                                  as VL_TOT_IPI,          
  ti.vl_total_com_ipi                                     as VL_TCOM_IPI,                                 
  ISNULL(pc.vl_total_pedido_icms,0.00)                    as VL_TOT_ICMS,          
  ti.vl_total_icms_pedido                                 as VL_ICMS_TOT,       		
  (isnull(ti.vl_TOTAL,0.00) + isnull(pc.vl_total_ipi_pedido,0.00) + isnull(pc.vl_total_pedido_icms,0.00) + isnull(pc.vl_frete_pedido_compra,0.00))          
  - isnull(vl_desconto_pedido_compra,0)                           as VL_TOT,          
 
 (isnull(ti.vl_TOTAL,0.00) + isnull(pc.vl_total_ipi_pedido,0.00) + isnull(pc.vl_frete_pedido_compra,0.00))          
  - (vl_desconto_pedido_compra)                           as VL_TOT_I,          
((pc.vl_total_pedido_compra + pc.vl_frete_pedido_compra           
  + pc.vl_total_ipi_pedido) * pc.pc_custofin_pedido_compra) / 100 as VL_CUSTO_FIN,  
  isnull(pc.vl_frete_pedido_compra,0.00)                  as vl_frete_pedido_compra,          
  isnull(pc.vl_desconto_pedido_compra,0.00)               as vl_desconto_pedido_compra,    
  -- Dados do Pedido -----------------------------------------------------------          
  isnull(pc.ds_pedido_compra,'')                          as ds_pedido_compra,  
    
  isnull(bnc.nm_banco,'')                                 as banco,  
  isnull(fo.cd_agencia_banco,'')                          as Agencia,  
  isnull(fo.cd_conta_banco,'')                            as Conta,  
  isnull(fo.cd_pix,'')                                    as PIX,  
  
  'Banco: '+isnull(bnc.nm_banco,'')+Char(13)+  
  'Agência: '+isnull(fo.cd_agencia_banco,'')+Char(13)+  
  'Conta: '+isnull(fo.cd_conta_banco,'')+Char(13)+  
  'Pix: '+isnull(fo.cd_pix,'')+Char(13)+  
  isnull(cast(pc.ds_pedido_compra as varchar(200)),'')    as ds_pedido_compra_banco,  
  
   te.nm_tipo_entrega_produto                             as nm_tipo_entrega_produto,          
   CONVERT( varchar, pc.dt_conf_pedido_compra,103)        as dt_conf_pedido_compra,          
  pc.nm_conf_pedido_compra                                as nm_conf_pedido_compra,          
   pc.dt_cancel_ped_compra                                as dt_cancel_ped_compra,          
  cast(pc.ds_ativacao_pedido_compra as varchar(256))      as ds_ativacao_pedido_compra,          
   pc.dt_alteracao_ped_compra                             as dt_alteracao_ped_compra,          
   tap.nm_tipo_alteracao_pedido + '-' + pc.ds_alteracao_ped_compra as ds_alteracao_ped_compra,               
  u.nm_usuario                                            as nm_usuario,  
  
   isnull(proj.cd_interno_projeto,'')                     as cd_interno_projeto,
   cm.nm_comprador                                        as nm_comprador,
   plc.nm_plano_compra                                    as nm_plano_compra,
   plc.cd_mascara_plano_compra                            as cd_mascara_plano_compra
     
 into #PedidoCompraDadosRel  
            
 from           
  pedido_Compra pc                             with(nolock)  
  left outer join vw_empresa_endereco vwe      with(nolock) on vwe.cd_empresa                = @cd_empresa          
  left outer join fornecedor fo                with(nolock) on fo.cd_fornecedor              = pc.cd_fornecedor          
  left outer join banco bnc                    with(nolock) on bnc.cd_banco                  = fo.cd_banco  
  left outer join fornecedor_contato co        with(nolock) on co.cd_fornecedor              = pc.cd_fornecedor           and co.cd_contato_fornecedor      = pc.cd_contato_fornecedor          
  left outer join cidade cf                    with(nolock) on cf.cd_estado                  = fo.cd_estado and
                                                               cf.cd_cidade                  = fo.cd_cidade          
  left outer join estado ef                    with(nolock) on ef.cd_estado                  = fo.cd_estado          
  left outer join transportadora tr            with(nolock) on tr.cd_transportadora          = pc.cd_transportadora          
  left outer join cidade ct                    with(nolock) on ct.cd_estado                  = tr.cd_estado and
                                                               ct.cd_cidade                  = tr.cd_cidade          
  left outer join estado et                    with(nolock) on et.cd_estado                  = tr.cd_estado          
  left outer join tipo_pedido tp               with(nolock) on tp.cd_tipo_pedido             = pc.cd_tipo_pedido          
  left outer join condicao_pagamento cp        with(nolock) on cp.cd_condicao_pagamento      = pc.cd_condicao_pagamento          
  left outer join aplicacao_produto ap         with(nolock) on ap.cd_aplicacao_produto       = pc.cd_aplicacao_produto          
  left outer join destinacao_produto de        with(nolock) on de.cd_destinacao_produto      = pc.cd_destinacao_produto          
  left outer join Centro_Custo cc              with(nolock) on cc.cd_centro_custo            = pc.cd_centro_custo          
  left outer join dbo.Departamento dep         with(nolock) on dep.cd_departamento           = pc.cd_departamento          
  left outer join Plano_Compra plc             with(nolock) on pc.cd_plano_compra            = plc.cd_plano_compra          
  left outer join comprador cm                 with(nolock) on pc.cd_comprador               = cm.cd_comprador          
  left outer join tipo_entrega_produto te      with(nolock) on pc.cd_tipo_entrega_produto    = te.cd_tipo_entrega_produto          
  left outer join Tipo_Alteracao_Pedido tap    with(nolock) on tap.cd_tipo_alteracao_pedido  = pc.cd_tipo_alteracao_pedido           
  left outer join #TotalItens ti               with(nolock) on ti.cd_pedido_compra           = pc.cd_pedido_compra          
  left outer join parametro_pedido_compra ppc  with(nolock) on ppc.cd_empresa                = @cd_empresa          
  left outer join documento_qualidade dq       with(nolock) on dq.cd_documento_qualidade     = ppc.cd_documento_qualidade          
  left outer join status_pedido sp             with(nolock) on sp.cd_status_pedido           = pc.cd_status_pedido          
  left outer join empresa_entrega ee           with(nolock) on ee.cd_empresa                 = @cd_empresa          
  left outer join Cidade cee                   with(nolock) on cee.cd_estado                 = ee.cd_estado and
                                                               cee.cd_cidade                 = ee.cd_cidade          
  left outer join Estado eee                   with(nolock) on eee.cd_estado                 = cee.cd_estado          
  left outer join Pais pee                     with(nolock) on pee.cd_pais                   = cee.cd_pais          
  Left outer join EGISADMIN.dbo.Usuario u      with(nolock) on u.cd_usuario                  = @cd_usuario          
  left outer join Pedido_Compra_Triangular pct with(nolock) on pct.cd_pedido_compra          = pc.cd_pedido_compra          
  left outer join vw_destinatario wd           with(nolock) on wd.cd_tipo_destinatario       = pct.cd_tipo_destinatario          
                                                           and wd.cd_destinatario            = pct.cd_destinatario          
  left outer join pedido_compra_diversos pcd   with(nolock) on pcd.cd_pedido_compra          = pc.cd_pedido_compra          
  left outer join empreendimento eo            with(nolock) on eo.cd_empreendimento          = pcd.cd_empreendimento          
  left outer join Cidade ceo                                on ceo.cd_estado                 = eo.cd_estado and
                                                               ceo.cd_cidade                 = eo.cd_cidade          
  left outer join empresa_faturamento efo      with(nolock) on efo.cd_empresa                = pcd.cd_empresa          
  left outer join requisicao_compra rc         with(nolock) on rc.cd_pedido_compra           = pc.cd_pedido_compra          
  left outer join pedido_compra_empresa pce    with(nolock) on pce.cd_pedido_compra          = pc.cd_pedido_compra        
  left outer join empresa_faturamento efemp    with(nolock) on efemp.cd_empresa              = pce.cd_empresa  
  left outer join Estado eef                   with(nolock) on eef.cd_estado                 = efemp.cd_estado  
  left outer join Cidade cef                   with(nolock) on cef.cd_estado                 = efemp.cd_estado and
                                                               cef.cd_cidade                 = efemp.cd_cidade   
                                                                      
  left outer join importador i                 with(nolock) on i.cd_importador               = 1  
  left outer join Cidade ceee                  with(nolock) on ceee.cd_cidade                = i.cd_cidade and     
                                                               ceee.cd_estado                = i.cd_estado
  left outer join Estado eeee                  with(nolock) on eeee.cd_estado                = i.cd_estado  
  left outer join Projeto proj                 with(nolock) on proj.cd_projeto               = pc.cd_projeto 

 where  
  pc.cd_pedido_compra = @cd_documento 
 
 order by
   pc.cd_pedido_compra

 OPTION (RECOMPILE);

 --select * from #PedidoCompraDadosRel
 --return

  declare @nm_razao_social_fornecedor          nvarchar(max) = ''   
  declare @nm_endereco_fornecedor              nvarchar(max) = ''  
  declare @cd_ddd_contato_fornecedor           nvarchar(max) = ''  
  declare @cd_telefone_contato_forne     nvarchar(max) = ''  
  declare @nm_email_fornecedor          nvarchar(max) = ''  
  declare @cd_cnpj_fornecedor       nvarchar(max) = ''  
  declare @cd_inscestadual_fornecedor     nvarchar(max) = ''  
  declare @nm_fantasia_contato_forne     nvarchar(max) = ''  
  declare @dt_pedido_compra           nvarchar(max) = ''  
  declare @nm_condicao_pagamento_pc      nvarchar(max) = ''  
  declare @dt_nec_pedido_compra          nvarchar(max) = ''  
  declare @nm_transportadora       nvarchar(max) = ''  
  declare @nm_endereco_transp       nvarchar(max) = ''  
  declare @cd_ddd_transp        nvarchar(max) = ''  
  declare @cd_telefone_transp       nvarchar(max) = ''  
  declare @nm_email_transportadora         nvarchar(max) = ''  
  declare @cd_cnpj_transportadora      nvarchar(max) = ''  
  declare @cd_inscestadual_transportadora    nvarchar(max) = ''  
  declare @VL_TOT_PROD            float = 0  
  declare @VL_TOT_IPI         float = 0 
  declare @VL_TOT_ICMS            float = 0   
  declare @vl_frete_pedido_compra      float = 0 
  declare @vl_desconto_pedido_compra     float = 0  
  declare @VL_TOT          float = 0 
  declare @nm_tipo_entrega_produto         nvarchar(max) = ''  
  declare @dt_conf_pedido_compra      nvarchar(max) = ''  
  declare @nm_conf_pedido_compra      nvarchar(max) = ''  
  declare @dt_cancel_ped_compra          nvarchar(max) = ''  
  declare @ds_ativacao_pedido_compra     nvarchar(max) = ''
  declare @nm_comprador                  nvarchar(60) = '' 
  declare @nm_pedfornec_pedido_compra    nvarchar(60) = ''
  declare @nm_plano_compra               nvarchar(60) = ''
  declare @cd_mascara_plano_compra       nvarchar(60) = ''
  declare @nm_centro_custo               nvarchar(60) = ''
  declare @nm_aplicacao_produto          nvarchar(60) = ''

  select   
    @nm_razao_social_fornecedor       = nm_razao_social_fornecedor,  
    @nm_endereco_fornecedor        = nm_endereco_fornecedor,  
    @cd_ddd_contato_fornecedor     = cd_ddd_fornecedor,  
    @cd_telefone_contato_forne     = cd_telefone_fornecedor,  
    @nm_email_fornecedor           = nm_email_fornecedor,  
    @cd_cnpj_fornecedor            = cd_cnpj_fornecedor,  
    @cd_inscestadual_fornecedor    = cd_inscestadual_fornecedor,  
    @nm_fantasia_contato_forne     = nm_fantasia_contato_forne,  
    @dt_pedido_compra              = dt_pedido_compra,  
    @nm_condicao_pagamento_pc      = nm_condicao_pagamento,  
    @dt_nec_pedido_compra          = dt_nec_pedido_compra,  
    @nm_transportadora             = nm_transportadora,  
    @nm_endereco_transp            = nm_endereco_transp,  
    @cd_ddd_transp                 = cd_ddd_transp,  
    @cd_telefone_transp            = cd_telefone_transp,  
    @nm_email_transportadora       = nm_email_transportadora,  
    @cd_cnpj_transportadora        = cd_cnpj_transportadora,  
    @cd_inscestadual_transportadora   = cd_inscestadual_transportadora,  
    @VL_TOT_PROD       = VL_TOT_PROD,  
    @VL_TOT_IPI        = VL_TOT_IPI,  
    @VL_TOT_ICMS       = VL_ICMS_TOT,  
    @vl_frete_pedido_compra     = vl_frete_pedido_compra,  
    @vl_desconto_pedido_compra    = vl_desconto_pedido_compra,  
    @VL_TOT         = VL_TOT,  
    @nm_tipo_entrega_produto    = nm_tipo_entrega_produto,  
    @dt_conf_pedido_compra     = dt_conf_pedido_compra,  
    @nm_conf_pedido_compra     = nm_conf_pedido_compra,  
    @dt_cancel_ped_compra     = dt_cancel_ped_compra,  
    @ds_ativacao_pedido_compra    = ds_ativacao_pedido_compra,
	@nm_comprador                  = nm_comprador,
	@nm_pedfornec_pedido_compra     = nm_pedfornec_pedido_compra,
	@nm_plano_compra                   = nm_plano_compra,
    @cd_mascara_plano_compra           = cd_mascara_plano_compra,
	@nm_aplicacao_produto            = nm_aplicacao_produto,
	@nm_centro_custo                    = nm_centro_custo
  from #PedidoCompraDadosRel  


  
if @cd_parametro<> 3  
begin  

  ---------------------------------------------------------------------------------------------------------------------------  
  
  ----montagem do Detalhe-----------------------------------------------------------------------------------------------  
  
  ---------------------------------------------------------------------------------------------------------------------------  
   
--<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_data_string(dt_pedido_venda)+'</td>  
  
declare @id int = 0  
  
set @html_detalhe = ''  
  
--declare @nm_fantasia_vendedor varchar(30) = ''  
  
--------------------------------------------------------------------------------------------------  
  
  
set @html_cab_det = '<div class="section-title"><strong> Pedido Nº '+cast(isnull(@cd_documento,0) as nvarchar(15))+'</strong></div>   
                     <table>  
                     <tr>
						<th>ITEM</th>	
						<th>FANTASIA</th>	
						<th>PRODUTO</th>	
						<th>MARCA</th>	
						<th>UN.</th>	
						<th>DATA</th>	
						<th>NECESSIDADE</th>
						<th>SALDO</th>	
						<th>QTD.</th>	
						<th>VALOR UN.</th>	
						<th>DESCONTO %</th>
						<th>DESCONTO</th>	
						<th>ICMS %</th>	
						<th>ICMS</th>
						<th>IPI %</th>	
						<th>IPI</th>	
						<th>TOTAL</th>
					 </tr>'  
  
set @html_detalhe = '' --valores da tabela  
  
  
--select * from #FinalFaturamentoMensal  
  
while exists( select Top 1 cd_controle from #FinalFaturamentoMensal )  
begin  
  
 --select top 1 * from #FinalFaturamentoMensal  
    
  select Top 1      
      @id           = cd_controle,  
 --@nm_pedido    = @nm_pedido  + ' ' + cast(cd_pedido_venda as varchar(15)),  
      @html_detalhe = @html_detalhe + '  
									<tr>                      
										<td style="font-size:12px; text-align:center;width: 20px">'+cast(ISNULL(CD_ITEM, 0) as varchar(4))+'</td>  
										<td style="font-size:12px; text-align:center;width: 20px">'+cast(ISNULL(FANTASIA, '') as varchar(max))+'</td>  
										<td style="font-size:12px; text-align:center;width: 20px">'+cast(ISNULL(NM_PROD, '') as varchar(max))+'</td>  
										<td style="font-size:12px; text-align:center;width: 20px">'+cast(ISNULL(MARCA, '') as varchar(max))+'</td>  
										<td style="font-size:12px; text-align:center;width: 20px">'+cast(ISNULL(SG_UNID, '') as varchar(10))+'</td>  
										<td style="font-size:12px; text-align:center;width: 20px">'+cast(ISNULL(dbo.fn_data_string(DT_ENTR), '') as varchar(30))+'</td>  
										<td style="font-size:12px; text-align:center;width: 20px">'+cast(ISNULL(dbo.fn_data_string(DT_NEC), '') as varchar(30))+'</td> 
										<td style="font-size:12px; text-align:center;width: 20px">'+cast(ISNULL(QT_ITEM, 0) as varchar(30))+'</td>  
										<td style="font-size:12px; text-align:center;width: 20px">'+cast(ISNULL(QT_SALDO, 0) as varchar(30))+'</td>  
										<td style="font-size:12px; text-align:center;width: 20px">'+ISNULL(dbo.fn_formata_valor(VL_ITEM), 0)+'</td>   
										<td style="font-size:12px; text-align:center;width: 20px">'+ISNULL(dbo.fn_formata_valor(vl_desconto_pedido_compra), 0)+'</td> 
										<td style="font-size:12px; text-align:center;width: 20px">'+ISNULL(dbo.fn_formata_valor(VL_DESC), 0)+'</td> 
										<td style="font-size:12px; text-align:center;width: 20px">'+ISNULL(dbo.fn_formata_valor(PC_ICMS), 0)+'</td>
										<td style="font-size:12px; text-align:center;width: 20px">'+ISNULL(dbo.fn_formata_valor(vl_total_icms_pedido), 0)+'</td>
										<td style="font-size:12px; text-align:center;width: 20px">'+ISNULL(dbo.fn_formata_valor(PC_IPI), 0)+'</td> 
										<td style="font-size:12px; text-align:center;width: 20px">'+ISNULL(dbo.fn_formata_valor(vl_ipi_item_pedido_compra),0)+'</td> 
										<td style="font-size:12px; text-align:center;width: 20px">'+ISNULL(dbo.fn_formata_valor(VL_TOT), 0)+'</td>     
									</tr>' 
   
  from  
    #FinalFaturamentoMensal   
  
  order by  
    cd_controle  
      
  
  
 delete from #FinalFaturamentoMensal  
 where  
   cd_controle = @id  
  
end  
  
--set @titulo_total = 'SUB-TOTAL'  
  
  
set @html_totais = '<div>  
     <table style="border: none;">  
                    <tr>            
                <td style="border: none;color: white;font-size:18px; text-align:left;"><b>Quantidade: '+cast(@qt_total as varchar(10))+'</td>  
                <td style="border: none;color: white;font-size:18px; text-align:left;"><b>Valor: '+'R$ '+dbo.fn_formata_valor(@vl_total)+'</td>   
     </tr>  
     </table>       
     </div>'  
       
 set @html_geral = @html_geral +   
                   @html_cab_det +  
                   @html_detalhe +  
                @html_rod_det +  
       @html_totais  
  
       
--end  
  
---------------------------------------------------------------------------------------------------------------------------  

  
set @nm_fantasia_cliente     = '' --'Resumo dos Pedidos de Vendas'  
set @nm_razao_social_cliente = '' --@nm_pedido  
  
set @titulo = @titulo + ' - Período : '+dbo.fn_data_string(@dt_inicial) + ' á '+dbo.fn_data_string(@dt_final)  
   
set @html_titulo = '  
      <table >  
         <tr>  
             <td colspan="3" class="section-title"><strong> Dados do Fornecedor</strong></td>  
             <td colspan="3" class="section-title"></td>  
             <td colspan="3" class="section-title"><strong> Dados do Pedido de Compra</strong></td>  
  
         </tr>  
         <tr>  
             <td colspan="3">  
                 <strong class="tamanhoFonte">Fornecedor: </strong>'+isnull(@nm_razao_social_fornecedor,'')+'<br>  
                 <strong class="tamanhoFonte" >Endereço: </strong>'+isnull(@nm_endereco_fornecedor,'')+'<br>  
                 <strong class="tamanhoFonte">Telefone: </strong> ('+isnull(@cd_ddd_contato_fornecedor,'')+') '+isnull(@cd_telefone_contato_forne,'')+' <br>  
                 <strong class="tamanhoFonte">E-Mail: </strong> '+isnull(@nm_email_fornecedor,'')+'<br> 
				 <strong class="tamanhoFonte">Aplicação: </strong> '+isnull(@nm_aplicacao_produto,'')+'<br>  
				 <strong class="tamanhoFonte">Centro de Custo: </strong> '+isnull(@nm_centro_custo,'')+'<br>  
               </td>  
            
               <td colspan="3">  
                  <strong class="tamanhoFonte" >CNPJ/CPF: </strong> '+isnull(dbo.fn_formata_cnpj(@cd_cnpj_fornecedor),'')+'<br>  
                  <strong class="tamanhoFonte" >Insc. Estadual: </strong>'+isnull(@cd_inscestadual_fornecedor,'')+'<br>  
                  <strong class="tamanhoFonte" >Contato: </strong> '+isnull(@nm_fantasia_contato_forne,'')+'<br>  
               </td>  
              
             <td colspan="3">  
                 <strong class="tamanhoFonte" >Data: </strong>'+isnull(dbo.fn_data_string(@dt_pedido_compra),'')+'<br>  
                 <strong class="tamanhoFonte" >Condição de Pagamento: </strong>'+isnull(@nm_condicao_pagamento_pc,'')+'<br>  
                 <strong class="tamanhoFonte" >Dt. Necessidade: </strong>'+isnull(dbo.fn_data_string(@dt_nec_pedido_compra),'')+'<br> 
				 <strong class="tamanhoFonte" >Pedido do Fornedor: </strong>'+isnull(@nm_pedfornec_pedido_compra,'')+'<br> 
				 <strong class="tamanhoFonte" >Plano de Compra: </strong>('+isnull(@cd_mascara_plano_compra,'')+') '+isnull(@nm_plano_compra,'')+'
             </td>  
         </tr>  
          
     </table>  
  
                    <div class="section-title"><strong>'+@titulo+'</strong></div> '  
        
--------------------------------------------------------------------------------------------------------------------  
  
--Criar uma tabela temporario com os Dados dos atributos  
  
  
--SET @html_rod_det = '</table>'  
  
  
set @titulo_total = 'TOTAIS'  
  
set @html_totais = '<div class="section-title"><strong>'+@titulo_total+'</strong>  
                    <div>   
				      <table >  
                        <tr>            
					      <p style="color: white;font-size:18px;text-align:left;"><b>Quantidade: '+cast(@qt_total as varchar(10))+'</p>  
					      <p style="color: white;font-size:18px;text-align:left;"><b>Valor: '+'R$ '+dbo.fn_formata_valor(@vl_total)+'</p>  
					   </tr>  
					 </table>  
					</div>  
				  </div>  
     <table class="bordered-table">   
                       <tr>  
                              <td colspan="4" class="section-title"><strong>Dados da Transportadora </strong></td>  
                       <tr>  
                           <td>  
                               
                               <strong class="tamanhoFonte">Transportadora: </strong>'+isnull(@nm_transportadora,'')+'<br>  
                               <strong class="tamanhoFonte">Endereço: </strong>'+isnull(@nm_endereco_transp,'')+'<br>  
                               <strong class="tamanhoFonte">Telefone: </strong> ('+isnull(@cd_ddd_transp,'')+') '+isnull(@cd_telefone_transp,'')+'  
                           </td>  
                           <td >  
                               <strong class="tamanhoFonte">E-Mail: </strong>'+isnull(@nm_email_transportadora,'')+'<br>  
                               <strong class="tamanhoFonte">CNPJ/CPF: </strong>'+isnull(dbo.fn_formata_cnpj(@cd_cnpj_transportadora),'')+'<br>  
                               <strong class="tamanhoFonte">Insc. Estadual: </strong>'+isnull(@cd_inscestadual_transportadora,'')+'  
                           </td>  
                            
                             
                           <td >  
                             <strong class="tamanhoFonte">Total Produtos / Serviços (R$): </strong> <br>  
                             <strong class="tamanhoFonte">Total do IPI (R$): </strong> <br>  
                             <strong class="tamanhoFonte">Valor do ICMS da subs. tributária: </strong>  <br> 
                             <strong class="tamanhoFonte">Valor do Frete (R$) : </strong> <br>  
                             <strong class="tamanhoFonte">Valor do Desconto (R$) [ - ]: </strong> <br>  
                             <strong class="tamanhoFonte">VALOR TOTAL: </strong> <br>  
                  
                         </td>  
                           
                         <td>  
                          <strong class="tamanhoFonte">'+isnull(dbo.fn_formata_valor(@VL_TOT_PROD),0)+'</strong> <br>  
                          <strong class="tamanhoFonte">'+isnull(dbo.fn_formata_valor(@VL_TOT_IPI),'')+'</strong> <br>  
                          <strong class="tamanhoFonte">'+isnull(dbo.fn_formata_valor(@VL_TOT_ICMS),0)+'</strong>  <br> 
                          <strong class="tamanhoFonte">'+isnull(dbo.fn_formata_valor(@vl_frete_pedido_compra),'')+' </strong> <br>  
                          <strong class="tamanhoFonte">'+isnull(dbo.fn_formata_valor(@vl_desconto_pedido_compra),'')+' </strong> <br>  
                          <strong class="tamanhoFonte">'+isnull(dbo.fn_formata_valor(@VL_TOT),0)+' </strong> <br>  
                          </td>  
                     </table>  
     '  
  
     --&nbsp  
  
--<td style="font-size:12px; text-align:center;width: 80px;">'+'R$ '+dbo.fn_formata_valor(@vl_total)+'</td>  
  
set @footerTitle = ''  
  
--Rodapé--  
  
set @html_rodape =  
    '<div class="company-info">  
  <p><strong>'+@footerTitle+'</strong></p>  
 </div>  
     <table class="bordered-table">  
         
            <th> Tipo de Entrega</th>  
            <th>  Confirmação</th>  
            <th>  Comprador</th>  
            <th>  Autorização</th>  
           
         </tr>   
             
         </tr>  
         <td style="font-size:15px; text-align:center;width: 20px">'+isnull(@nm_tipo_entrega_produto,'')+'</td>  
         <td style="font-size:15px; text-align:center;width: 20px">'+isnull(dbo.fn_data_string(@dt_conf_pedido_compra),'')+'</td>  
         <td style="font-size:15px; text-align:center;width: 20px">'+isnull(@nm_comprador,'')+'</td>  
         <td style="font-size:15px; text-align:center;width: 20px">'+isnull(@ds_ativacao_pedido_compra,'')+'</td>  
         </tr>  
       
       </table>  
	   <div>
            <tr style="margin-top: 5px; text-align: left;">
                <p class="section-title"><strong>Observações </strong></p><br>
				<p>'+@ds_relatorio+'</p>
			</tr>
        </div>
 <div class="report-date-time">  
       <p>Gerado em: '+@data_hora_atual+'</p>  
    </div>
</body>
</html>'  
  
  
--Gráfico--  
set @html_grafico = ''  
  
--HTML Completo--------------------------------------------------------------------------------------  
  
set @html         =   
    @html_empresa +  
    @html_titulo  +  
  
 --@html_cab_det +  
 --   @html_detalhe +  
 --@html_rod_det +  
  
 @html_geral   +   
 @html_totais  +  
 @html_grafico +  
    @html_rodape    
  
--select @html, @html_empresa, @html_titulo, @html_cab_det, @html_rod_det, @html_totais, @html_grafico, @html_rodape  
  
-------------------------------------------------------------------------------------------------------  
  
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
  
  
end  
  go
  
--exec pr_egis_relatorio_pedido_compra 134,4253,0,'[{
--    "cd_empresa": "377",
--    "cd_modulo": "233",
--    "cd_menu": "0",
--    "cd_relatorio": "134",
--    "cd_processo": "",
--    "cd_item_processo": "",
--    "cd_documento_form": 0,
--    "cd_documento": 10127,
--    "cd_item_documento_form": "0",
--    "cd_parametro": "0",
--    "cd_usuario": "4915"
--}]'

------------------------------------------------------------------------------------------------------------------------------------------------  