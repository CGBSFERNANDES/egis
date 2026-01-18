IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_cliente_familia_produtos' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_cliente_familia_produtos

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_cliente_familia_produtos  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_cliente_familia_produtos  
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
--Alteração        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_cliente_familia_produtos  
@cd_relatorio int   = 0,  
@cd_usuario   int   = 0,  
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
declare @dt_usuario             datetime = ''  
declare @cd_documento           int = 0  
declare @cd_item_documento      int = 0  
declare @cd_parametro           int = 0  
declare @dt_hoje                datetime  
declare @dt_inicial             datetime  
declare @dt_final               datetime  
declare @cd_ano                 int      
declare @cd_mes                 int      
declare @cd_dia                 int   
  
--Dados do Relatório---------------------------------------------------------------------------------  
  
 declare  
   @titulo                     varchar(200),  
   @logo                       varchar(400),     
   @nm_cor_empresa             varchar(20),  
   @nm_endereco_empresa        varchar(200) = '',  
   @cd_telefone_empresa        varchar(200) = '',  
   @nm_email_internet          varchar(200) = '',  
   @nm_cidade                  varchar(200) = '',  
   @sg_estado                  varchar(10)  = '',  
   @nm_fantasia_empresa        varchar(200) = '',  
   @numero                     int = 0,  
   @dt_pedido                  varchar(60) = '',  
   @cd_cep_empresa             varchar(20) = '',  
   @cd_cliente                 int = 0,  
   @nm_fantasia_cliente        varchar(200) = '',  
   @cd_cnpj_cliente            varchar(30) = '',  
   @nm_razao_social_cliente    varchar(200) = '',  
   @nm_endereco_cliente        varchar(200) = '',  
   @nm_bairro                  varchar(200) = '',  
   @nm_cidade_cliente          varchar(200) = '',  
   @sg_estado_cliente          varchar(5) = '',  
   @cd_numero_endereco         varchar(20) = '',  
   @cd_telefone                varchar(20) = '',  
   @nm_condicao_pagamento      varchar(100) = '',  
   @ds_relatorio               varchar(8000) = '',  
   @subtitulo                  varchar(40)   = '',  
   @footerTitle                varchar(200)  = '',  
   @vl_total_ipi               float         = 0,  
   @sg_tabela_preco            char(10)      = '',  
   @cd_empresa_faturamento     int           = 0,  
   @nm_fantasia_faturamento    varchar(30)   = '',  
   @cd_tipo_pedido             int           = 0,  
   @nm_tipo_pedido             varchar(30)   = '',  
   @cd_vendedor                int           = 0,  
   @nm_fantasia_vendedor       varchar(500)   = '',  
   @nm_telefone_vendedor       varchar(30)   = '',  
   @nm_email_vendedor          varchar(300)  = '',  
   @nm_contato_cliente         varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais                    int = 0,  
   @nm_pais                    varchar(20) = '',  
   @cd_cnpj_empresa            varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet        varchar(200) = '',  
   @nm_status                  varchar(100) = '',  
   @ic_empresa_faturamento     char(1) = ''  
          
--------------------------------------------------------------------------------------------------------  
  
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)          
set @cd_parametro      = 0  
set @cd_modulo         = 0  
set @cd_empresa        = 0  
set @cd_menu           = 0  
set @cd_processo       = 0  
set @cd_item_processo  = 0  
set @cd_form           = 0  
set @cd_parametro      = 0  
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
  
-------------------------------------------------------------------------------------------------  
  
--select * from #json  
  
-------------------------------------------------------------------------------------------------  
  
  select @cd_empresa             = valor from #json where campo = 'cd_empresa'               
  select @cd_modulo              = valor from #json where campo = 'cd_modulo'               
  select @cd_processo            = valor from #json where campo = 'cd_processo'               
  select @cd_item_processo       = valor from #json where campo = 'cd_item_processo'               
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'   
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'   
  select @dt_final               = valor from #json where campo = 'dt_final'   
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'   
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
declare @ic_processo char(1) = 'N'  
   
  
select  
  @titulo      = nm_relatorio,  
  @ic_processo = isnull(ic_processo_relatorio, 'N')  
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

#btnExcel {
    background-color: #007bff; 
    color: white;
    padding: 10px 18px;
    border: none;
    border-radius: 6px;
    font-size: 15px;
    font-weight: bold;
    cursor: pointer;
    transition: 0.3s;
    box-shadow: 0px 3px 6px rgba(0,0,0,0.2);
	}
	#btnExcel:hover {
	    background-color: #0056b3; 
	    transform: scale(1.05);
	}
	#btnExcel:active {
	    transform: scale(0.98);
	}
  @media print {
    #btnExcel {
      display: none !important;
    }
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
  cd_grupo_relatorio = 9  
  
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
  @cd_vendedor    = isnull(cd_vendedor,0),  
  @cd_cliente     = isnull(cd_cliente,0)  
from   
  Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
  and  
  cd_usuario   = @cd_usuario  
  
  --select @cd_relatorio, @cd_usuario  
  
--select  
--*  
--from   
-- Parametro_Relatorio  
  
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
  
--set @cd_vendedor = 0  
  
--Cliente Positivados----  
  
select  
  c.cd_vendedor,  
  count(distinct n.cd_cliente) as qt_cliente  
   
into  
  #ClientePositivado  
  
from  
  nota_saida n  
  inner join nota_saida_item i on i.cd_nota_saida = n.cd_nota_saida  
  inner join Cliente c         on c.cd_cliente    = n.cd_cliente  
  inner join vendedor v        on v.cd_vendedor   = c.cd_vendedor  
  left outer join Operacao_Fiscal opf on opf.cd_operacao_fiscal = i.cd_operacao_fiscal 
  
where  
  c.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then c.cd_vendedor else isnull(@cd_vendedor,0) end  
  and  
  n.dt_nota_saida between @dt_inicial and @dt_final  
  and  
  n.cd_status_nota<> 7  
  and  
  i.dt_restricao_item_nota is null or i.dt_restricao_item_nota>@dt_inicial  
  and  
  isnull(v.ic_egismob_vendedor,'S')='S'  
  and
  isnull(opf.ic_analise_op_fiscal,'N') = 'S'
  and
  ISNULL(opf.ic_comercial_operacao,'N') = 'S'

group by  
  c.cd_vendedor  

  --select * from #ClientePositivado
  --return
--Devolucao---  
  
select  
  c.cd_vendedor,  
  sum(case when i.dt_restricao_item_nota is null   
     then 0   
     else round(      
         case when isnull(i.cd_item_nota_saida,0)>0 then      
           case when isnull(i.vl_total_item,0)=0      then      
                cast((case when IsNull(i.cd_servico,0)=0 and isnull(i.vl_servico,0)=0      
                then      
                   cast(round((isnull(i.vl_unitario_item_nota,0) * --( 1 - IsNull(i.pc_desconto_item,0) / 100) *       
                  (IsNull(i.qt_devolucao_item_nota,0))),2)      
               ----Adiciona o IPI      
                   + isnull(i.vl_ipi,0)      
                    as money)       
                else   --isnull(i.vl_servico,0) antes tirei      
                   round(IsNull(i.qt_devolucao_item_nota,0) * case when isnull(i.vl_servico,0)>0 then isnull(i.vl_unitario_item_nota,0) else isnull(i.vl_unitario_item_nota,0) end ,2)    
          +       
                   (case when IsNull(i.ic_iss_servico, 'N' ) = 'S' and isnull(i.vl_iss_servico,0)>0      
                   then      
                    isnull(i.vl_iss_servico,0)      
                   else      
                    0.00      
                   end)      
                end)     
              
          +        +      
            IsNull(i.vl_frete_item,0.00)      +       
            IsNull(i.vl_seguro_item,0.00)     +       
            IsNull(i.vl_desp_acess_item,0.00) +      
           
            case when isnull(opf.ic_subst_tributaria,'N')='S' and isnull(i.vl_icms_subst_icms_item,0)> 0 then      
              isnull(i.vl_icms_subst_icms_item,0)      
            else      
              0.00      
            end      
                  
            as money)      
             else      
                ( isnull(i.qt_devolucao_item_nota,0) * case when isnull(i.vl_unitario_item_nota,0) = 0 and isnull(i.cd_servico,0)>0 then    
                  i.vl_servico    
            else    
              
             isnull(i.vl_unitario_item_nota,0)      
              end    
            
          ) +      
          (((  
            ----Adiciona o IPI       
             isnull(i.vl_ipi,0)                +      
             IsNull(i.vl_frete_item,0.00)      +       
             IsNull(i.vl_seguro_item,0.00)     +       
             IsNull(i.vl_desp_acess_item,0.00)       
           
            +      
           
            case when isnull(opf.ic_subst_tributaria,'N')='S' and isnull(i.vl_icms_subst_icms_item,0)> 0 then      
              isnull(i.vl_icms_subst_icms_item,0)      
            --0.00      
            else      
              0.00      
            end      
           
            +      
             (case when IsNull(i.ic_iss_servico, 'N' ) = 'S' and isnull(i.vl_iss_servico,0)>0   and 1=2    
               then      
                 isnull(i.vl_iss_servico,0)      
               else      
                 0.00      
               end)    
           ) / i.qt_item_nota_saida) * isnull(i.qt_devolucao_item_nota,0))  
                  
         end      
         else      
            IsNull(i.qt_devolucao_item_nota,0) * isnull(i.vl_unitario_item_nota,0)      
         end,2)  
         - cast(round( IsNull(i.qt_devolucao_item_nota,0) * (isnull(i.vl_unitario_item_nota,0) * IsNull(i.pc_desconto_item,0) / 100),2) as decimal(25,2) )  
     end)                         as vl_total_devolucao,  
  COUNT(distinct d.cd_nota_saida) as qt_nota_devolucao  
  
into  
  #Devolucao  
 
from  
  nota_saida d  
  inner join Nota_Saida_Item i              with(nolock) on i.cd_nota_saida              = d.cd_nota_saida  
  inner join Cliente c                      with(nolock) on c.cd_cliente                 = d.cd_cliente  
  inner join Vendedor v                     with(nolock) on v.cd_vendedor                = c.cd_vendedor  
  left outer join operacao_fiscal opf       with(nolock) on opf.cd_operacao_fiscal       = i.cd_operacao_fiscal  
  left outer join grupo_operacao_fiscal gof with(nolock) on gof.cd_grupo_operacao_fiscal = opf.cd_grupo_operacao_fiscal  
  
where  
  c.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then c.cd_vendedor else isnull(@cd_vendedor,0) end  
  and  
  d.dt_nota_saida between @dt_inicial and @dt_final  
  and  
  i.dt_restricao_item_nota is not null  
  and  
  d.cd_status_nota<> 7  
  --and  
  --i.dt_restricao_item_nota is null or i.dt_restricao_item_nota>@dt_inicial  
  and  
  isnull(opf.ic_comercial_operacao,'N') = 'S'     
  and  
  isnull(opf.ic_analise_op_fiscal,'N')    = 'S' --Verifica apenas as operações fiscais selecionadas para o BI  
  and  
  ( gof.cd_tipo_operacao_fiscal = 2 )         --Desconsiderar notas de entrada    
  and  
  isnull(v.ic_egismob_vendedor,'S')='S'      
  and  
  1=2  
  and
  isnull(opf.ic_analise_op_fiscal,'N') = 'S'
  and
  ISNULL(opf.ic_comercial_operacao,'N') = 'S'
  
group by  
  c.cd_vendedor  

--select * from #Devolucao  
--select @dt_inicial, @dt_final  
  
--select @cd_vendedor  
  
--Faturamento por Vendedor e Familia----------------------------  
  
select  
  c.cd_vendedor,  
  fp.cd_familia_produto,  
  --n.dt_nota_saida,  
  max(v.nm_fantasia_vendedor)            as nm_fantasia_vendedor,  
  max(isnull(fp.nm_familia_produto,''))  as nm_familia_produto,  
  
--  sum(isnull(i.qt_item_nota_saida,0))    as qt_item_nota_saida,  
  
 SUM(   
 round(ISNULL(i.qt_item_nota_saida,0)   
 /   
 (case when isnull(umc.ic_multiplo_embalagem,'N') = 'N' and isnull(p.qt_multiplo_embalagem,0)>0   
 then p.qt_multiplo_embalagem   
 else 1  
 end),0)  
 )                                                as qt_item_nota_saida,  
  
  
  
  
  --sum( cast( round(isnull(i.vl_total_item,0) +  isnull(i.vl_ipi,0) + isnull(i.vl_icms_subst_icms_item,0),2) as decimal(25,2)))                     as vl_total_item,  
 sum(       
    round(      
    case when isnull(i.cd_item_nota_saida,0)>0 then      
      case when isnull(i.vl_total_item,0)=0      then      
           cast((case when IsNull(i.cd_servico,0)=0 and isnull(i.vl_servico,0)=0      
           then      
              cast(round((isnull(i.vl_unitario_item_nota,0) * --( 1 - IsNull(i.pc_desconto_item,0) / 100) *       
             (IsNull(i.qt_item_nota_saida,0))),2)      
          ----Adiciona o IPI      
              + isnull(i.vl_ipi,0)      
               as money)       
           else   --isnull(i.vl_servico,0) antes tirei      
              round(IsNull(i.qt_item_nota_saida,0) * case when isnull(i.vl_servico,0)>0 then isnull(i.vl_unitario_item_nota,0) else isnull(i.vl_unitario_item_nota,0) end ,2)    
     +       
              (case when IsNull(i.ic_iss_servico, 'N' ) = 'S' and isnull(i.vl_iss_servico,0)>0      
              then      
               isnull(i.vl_iss_servico,0)      
              else      
               0.00      
              end)      
           end)     
         
     +        +      
       IsNull(i.vl_frete_item,0.00)      +       
       IsNull(i.vl_seguro_item,0.00)     +       
       IsNull(i.vl_desp_acess_item,0.00) +      
      
       case when isnull(opf.ic_subst_tributaria,'N')='S' and isnull(i.vl_icms_subst_icms_item,0)> 0 then      
         isnull(i.vl_icms_subst_icms_item,0)      
       else      
         0.00      
       end      
             
       as money)      
        else      
           ( isnull(i.qt_item_nota_saida,0) * case when isnull(i.vl_unitario_item_nota,0) = 0 and isnull(i.cd_servico,0)>0 then    
             i.vl_servico    
       else    
         
        isnull(i.vl_unitario_item_nota,0)      
         end    
       
     ) +      
      
       ----Adiciona o IPI       
        isnull(i.vl_ipi,0)                +      
        IsNull(i.vl_frete_item,0.00)      +       
        IsNull(i.vl_seguro_item,0.00)     +       
        IsNull(i.vl_desp_acess_item,0.00)       
      
       +      
      
       case when isnull(opf.ic_subst_tributaria,'N')='S' and isnull(i.vl_icms_subst_icms_item,0)> 0 then      
         isnull(i.vl_icms_subst_icms_item,0)      
       --0.00      
       else      
         0.00      
       end      
      
       +      
        (case when IsNull(i.ic_iss_servico, 'N' ) = 'S' and isnull(i.vl_iss_servico,0)>0   and 1=2    
          then      
            isnull(i.vl_iss_servico,0)      
          else      
            0.00      
          end)      
             
    end      
    else      
       isnull(n.vl_total,0)      
    end,2)  
    - cast(round( IsNull(i.qt_item_nota_saida,0) * (isnull(i.vl_unitario_item_nota,0) * IsNull(i.pc_desconto_item,0) / 100),2) as decimal(25,2) )  
    )                                    as vl_total_item,  
  count(distinct i.cd_produto)           as qt_produto,  
  count(distinct p.cd_categoria_produto) as qt_categoria_produto,  
  count(distinct p.cd_familia_produto)   as qt_familia_produto,  
  count(distinct n.cd_cliente)           as qt_cliente,  
  COUNT(distinct n.cd_nota_saida)        as qt_nota  
  
into  
  #FaturamentoVendedorFamilia  
  
from  
  nota_saida n  
  inner join nota_saida_item i                with(nolock) on i.cd_nota_saida              = n.cd_nota_saida  
  inner join produto p                        with(nolock) on p.cd_produto                 = i.cd_produto  
  left outer join familia_produto fp          with(nolock) on fp.cd_familia_produto        = p.cd_familia_produto  
  left outer join Cliente c                   with(nolock) on c.cd_cliente                 = n.cd_cliente  
  left outer join Vendedor v                  with(nolock) on v.cd_vendedor                = c.cd_vendedor  
  left outer join operacao_fiscal opf         with(nolock) on opf.cd_operacao_fiscal       = i.cd_operacao_fiscal  
  left outer join grupo_operacao_fiscal gof   with(nolock) on gof.cd_grupo_operacao_fiscal = opf.cd_grupo_operacao_fiscal  
  left outer join Unidade_Medida umc                       on umc.cd_unidade_medida        = i.cd_unidade_medida  
  left outer join Unidade_Medida um                        on um.cd_unidade_medida         = case when isnull(fp.cd_unidade_medida,0)>0   
                                                                                        then   
                              fp.cd_unidade_medida  
                                                                                           else  
                              i.cd_unidade_medida  
                                                                                           end   
  
where  

  n.dt_nota_saida between @dt_inicial and @dt_final  
  and  
  n.cd_status_nota<> 7  
  --and  
  --i.dt_restricao_item_nota is null or i.dt_restricao_item_nota>@dt_inicial  
  and  
  isnull(opf.ic_comercial_operacao,'N') = 'S'     
  and  
  isnull(opf.ic_analise_op_fiscal,'N')    = 'S' --Verifica apenas as operações fiscais selecionadas para o BI  
  and  
  ( gof.cd_tipo_operacao_fiscal = 2 )         --Desconsiderar notas de entrada     
  and  
  isnull(v.ic_egismob_vendedor,'S')='S'  
 and  
 ISNULL(fp.ic_analise_familia_produto,'S')='S'  


  
group by  
  c.cd_vendedor,  
  fp.cd_familia_produto  
  --select * from #FaturamentoVendedorFamilia  
   
  
select  
  @vl_total = sum(vl_total_item),  
  @qt_total = sum(qt_nota)  
  
from  
  #FaturamentoVendedorFamilia  
  
  
--Familia de Produto--  
  
select   
  IDENTITY(int,1,1) as cd_controle,  
  f.*,  
  pc_faturamento = cast(round(vl_total_item/@vl_total*100,2) as decimal(25,2)),  
  case when isnull(f.qt_item_nota_saida,0)>0 and isnull(m.qt_meta_vendedor,0)>0 then  
    cast(round(f.qt_item_nota_saida/isnull(m.qt_meta_vendedor,0) * 100,2) as decimal(25,2))  
  else  
    0.00  
  end                                                        as pc_meta_familia,  
  isnull(m.qt_meta_vendedor,0)                               as qt_meta_vendedor,  
  ISNULL(m.vl_premiacao_meta,0)                              as vl_premiacao_meta,  
  d.vl_total_devolucao,  
  d.qt_nota_devolucao  
  
into  
  #FaturamentoVendedorFamiliaFinal  
  
from   
  #FaturamentoVendedorFamilia f  
  left outer join #Devolucao d                    on d.cd_vendedor             = f.cd_vendedor  
    
  left outer join Vendedor_Meta_Familia_Produto m on m.cd_vendedor             = f.cd_vendedor        and  
                                                     m.cd_familia_produto      = f.cd_familia_produto and  
                                                     @dt_inicial between m.dt_inicio_meta_vendedor and m.dt_inicio_meta_vendedor  
                                                     and  
                                                     @dt_final   between m.dt_final_meta_vendedor and m.dt_final_meta_vendedor  

--where

--f.cd_vendedor = 8

order by  
  vl_total_item desc  

  --select * from #FaturamentoVendedorFamiliaFinal
  --return
  
 
 
----montagem do Detalhe-----------------------------------------------------------------------------------------------  
  
declare @id int = 0  
  
set @html_detalhe = ''  

  
--Clientes por Dia de Semana---  
  
select  
  c.cd_vendedor,  
  c.cd_semana,  
  count(c.cd_cliente) as qt_cliente  
  
into  
  #DiaVisitaVendedor  
  
from  
  cliente c 
  
where  
  ISNULL(c.cd_status_cliente,1) = 1  
  
  
group by  
 c.cd_vendedor,  
 c.cd_semana  
   
--Vendedor-------------------------------------------------------------------- 

select  
  f.cd_vendedor,   
  max(v.nm_fantasia_vendedor)                                     as nm_fantasia_vendedor,  
  max( 'R$ '+dbo.fn_formata_valor(ISNULL(v.vl_meta,0)))           as nm_meta,  
  MAX(isnull(v.vl_meta,0))                                        as vl_meta,  
  max(isnull(mvp.vl_meta_adicional,0))                            as vl_meta_adicional, 
  max(isnull(mvp.vl_meta_vendedor,0))							  as vl_meta_vendedor,
  COUNT(distinct c.cd_cliente)                                    as qt_cliente,  
  MAX(p.qt_cliente)                                               as qt_cliente_positivado,  
  max(isnull(mvp.pc_meta_positivacao_cliente,0))                  as pc_meta_positivacao_cliente,  
  max(isnull(mvp.vl_premio_positivacao_cliente,0))                as vl_premio_positivacao_cliente,  
  max(isnull(mvp.pc_sup_meta,0))                                  as pc_sup_meta,  
  max(isnull(mvp.vl_premiacao_meta,0))                            as vl_premiacao_meta,  
  max(isnull(mvp.qt_devolucao,0))                                 as qt_meta_devolucao,  
  MAX(isnull(mvp.vl_premiacao_devolucao,0))                       as vl_premiacao_devolucao  
  
  ---------------
  into #Vendedor   
  ---------------

from    
  #FaturamentoVendedorFamiliaFinal f  
  inner join Vendedor v                     on v.cd_vendedor   = f.cd_vendedor  
  inner join Cliente c                      on c.cd_vendedor   = f.cd_vendedor and c.cd_status_cliente = 1 --Ativo  
  left outer join #ClientePositivado p      on p.cd_vendedor   = f.cd_vendedor  
  left outer join Meta_Vendedor_Periodo mvp on mvp.cd_vendedor = v.cd_vendedor and  
                                               @dt_inicial between mvp.dt_inicial_validade_meta and mvp.dt_final_validade_meta  and  
                                               @dt_final   between mvp.dt_inicial_validade_meta and mvp.dt_final_validade_meta  
                                               and
                                               mvp.dt_inicial_validade_meta = @dt_inicial

where
  --mvp.dt_inicial_validade_meta = @dt_inicial
  --and

  isnull(v.ic_egismob_vendedor,'S')='S'  
  
group by  
 f.cd_vendedor  
  
order by  
  f.cd_vendedor  
 --- select * from #Vendedor return

--select * from #FaturamentoVendedorFamiliaFinal  
--------------------------------------------------------------------------------------------------  
  
  
declare @nm_meta                       varchar(100)  = ''  
declare @qt_cliente                    decimal(25,2) = 0  
declare @vl_falta_meta                 decimal(25,2) = 0.00  
declare @pc_atingido_meta              decimal(25,2) = 0.00  
declare @vl_meta                       decimal(25,2) = 0.00  
declare @vl_meta_adicional             decimal(25,2) = 0.00  
declare @qt_cliente_nota               decimal(25,2) = 0  
declare @pc_positivacao                decimal(25,2) = 0  
declare @qt_meta_devolucao             decimal(25,2) = 0.00  
declare @qt_devolucao                  decimal(25,2) = 0.00  
declare @vl_devolucao                  decimal(25,2) = 0.00  
declare @vl_premiacao                  decimal(25,2) = 0.00  
declare @pc_meta_positivacao_cliente   decimal(25,2) = 0.00  
declare @vl_premio_positivacao_cliente decimal(25,2) = 0.00  
declare @vl_premio_devolucao           decimal(25,2) = 0.00  
declare @pc_sup_meta                   decimal(25,2) = 0.00  
declare @vl_premiacao_meta             decimal(25,2) = 0.00  
declare @vl_premiacao_devolucao        decimal(25,2) = 0.00  
declare @qt_meta_vendedor              int           = 0  
declare @qt_cliente_total              int           = 0  
declare @qt_produto_total              int           = 0  
declare @vl_total_premiacao            decimal(25,2) = 0.00  
  
 --select SUM(qt_cliente) as qt_cliente from #Vendedor  
  
  --return  
  
  --select * from #Devolucao  
  
while exists( select Top 1 cd_vendedor from #Vendedor )  
begin  
  
  set @vl_premiacao      = 0.00  
  set @vl_premiacao_meta = 0.00  
  
  select Top 1  
 @cd_vendedor                    = v.cd_vendedor,  
 @nm_fantasia_vendedor           = v.nm_fantasia_vendedor, --+'     -    Meta: '+nm_meta ,  
 @nm_meta                        = v.vl_meta_vendedor,  
 @vl_meta                        = isnull(v.vl_meta,0),  
 @vl_meta_adicional              = ISNULL(v.vl_meta_adicional,0),  
 @qt_cliente                     = isnull(v.qt_cliente,0),  
 @qt_cliente_nota                = isnull(v.qt_cliente_positivado,0),  
 @qt_devolucao                   = ISNULL(d.qt_nota_devolucao,0),  
 @vl_devolucao                   = ISNULL(d.vl_total_devolucao,0),  
 @pc_meta_positivacao_cliente    = ISNULL(v.pc_meta_positivacao_cliente,0),  
 @vl_premio_positivacao_cliente  = ISNULL(v.vl_premio_positivacao_cliente,0),  
 @pc_sup_meta                    = ISNULL(v.pc_sup_meta,0),  
 @vl_premiacao_meta              = ISNULL(v.vl_premiacao_meta,0),  
 @qt_meta_devolucao              = isnull(v.qt_meta_devolucao,0),  
 @vl_premiacao_devolucao         = ISNULL(v.vl_premiacao_devolucao,0)  
   
 --meta_vendedor_periodo  
  
  from  
    #Vendedor v  
    left outer join #Devolucao d                    on d.cd_vendedor             = v.cd_vendedor  
  
  order by  
    v.nm_fantasia_vendedor   
  
  --Total do Vendedor---------------------------  
  
    select  
   @vl_total_premiacao = SUM(ISNULL(vl_premiacao_meta,0)),  
   @qt_cliente_total   = SUM(ISNULL(qt_cliente,0)),  
   @qt_produto_total   = SUM(ISNULL(qt_produto,0)),  
   @qt_meta_vendedor   = SUM( ISNULL(qt_meta_vendedor,0)),  
   @vl_total_vendedor  = sum( isnull(vl_total_item,0)),  
   @qt_total_vendedor  = sum( isnull(qt_nota,0)),  
   @vl_premiacao_meta  = SUM(case when isnull(pc_meta_familia,0)>=100 then isnull(vl_premiacao_meta,0) else 0.00 end )  
     
        
    from  
      #FaturamentoVendedorFamiliaFinal  
  
    where  
   cd_vendedor = isnull(@cd_vendedor,0)  
  
    --Insere aqui os Totais---------------------------------------------------------------------  
 --insert into #FaturamentoVendedorFamiliaFinal  
 --select  
 ----cd_controle  
 --     @cd_vendedor                  as cd_vendedor,  
 --     null                          as cd_familia_produto,  
 --     cast('' as varchar(30))       as nm_fantasia_vendedor,  
 --     cast('' as varchar(30)) as nm_familia_produto,  
 --     @qt_total_vendedor            as qt_item_nota_saida,  
 --     @vl_total_vendedor            as vl_total_item,  
 --     @qt_produto_total             as qt_produto,  
 --     0                             as qt_categoria_produto,  
 --     0                             as qt_familia_produto,  
 --     @qt_cliente_total             as qt_cliente,  
 --     0                             as qt_nota,  
 --     0.00                          as pc_faturamento,  
 --     0.00                          as pc_meta_familia,  
 --     @qt_meta_vendedor             as qt_meta_vendedor,  
 --     @vl_total_premiacao           as vl_premiacao_meta,  
 --     0.00                          as vl_total_devolucao,  
 --     0                             as qt_nota_devolucao  
         
    --Metas------  
  
 set @pc_atingido_meta = round(case when @vl_meta>0                  then @vl_total_vendedor/@vl_meta * 100            else 0.00 end,0)  
 set @vl_falta_meta    = case when @vl_total_vendedor<@vl_meta       then @vl_meta-@vl_total_vendedor else 0.00 end  
 set @pc_positivacao   = case when @qt_cliente >0                    then cast(round(@qt_cliente_nota/@qt_cliente * 100,2) as decimal(25,2)) else 0.00 end  
 set @vl_premiacao     = @vl_premiacao   
                         +   
       case when @pc_positivacao>@pc_meta_positivacao_cliente then @vl_premio_positivacao_cliente else 0.00 end  
                         +  
       @vl_premiacao_meta  
       +  
       --Devolução--  
       case when @qt_devolucao<=@qt_meta_devolucao then @vl_premiacao_devolucao                   else 0.00 end  
       +  
       @vl_premio_positivacao_cliente  
       -------------------------------------------------------------------------------------------------------  
  
    --select @nm_fantasia_vendedor, @nm_meta, @pc_atingido_meta, @vl_falta_meta, @pc_positivacao, @qt_cliente, @qt_cliente_nota          

    set @html_cab_det = '<div class="section-title"><strong> '+@nm_fantasia_vendedor + ' </strong></div>      
                     <table>  
      <tr>  
      <td>Meta</td>  
      <td>(%) Meta</td>  
      <td>Falta Atingir</td>  
      <td>Meta Adicional</td>        
      <td>Base Compradora</td>  
      <td>Positivação</td>  
      <td>(%)</td>  
      <td>Meta Devolução</td>  
      <td>Devolução</td>  
      <td>Qtd.Notas</td>  
      <td>Premiação</td>  
      </tr>  
      <tr>  
      <td>'+dbo.fn_formata_valor(@nm_meta)+'</td>  
      <td>'+dbo.fn_formata_valor(@pc_atingido_meta)+'</td>  
      <td>'+case when @vl_falta_meta>0 then dbo.fn_formata_valor(@vl_falta_meta) else cast('-' as varchar(1)) end+'</td>  
      <td>'+dbo.fn_formata_valor(@vl_meta_adicional)+'</td>  
      <td>'+CAST(cast(@qt_cliente as int) as varchar(20))+'</td>  
      <td>'+cast( cast(@qt_cliente_nota as int) as varchar(10))+'</td>  
      <td>'+dbo.fn_formata_valor(@pc_positivacao)+'</td>  
      <td>'+cast( cast(@qt_meta_devolucao as int) as varchar(10))+'</td>  
      <td>'+dbo.fn_formata_valor(@vl_devolucao)+'</td>  
      <td>'+cast(cast(@qt_devolucao as int) as varchar(10))+'</td>  
      <td>'+'R$ '+dbo.fn_formata_valor(@vl_premiacao)+'</td>      
  
      </tr>  
      </table>  
              <table>  
                     <tr>'  
  
      +  
      isnull(@nm_dados_cab_det,'')  
                     + '</tr>'  
  
  --SELECT @nm_dados_cab_det  
  --------------------------------------------------------------------------------------------------------------------------  
  
  set @html_detalhe = '' --valores da tabela  
 --    select nm_familia_produto,* from #FaturamentoVendedorFamiliaFinal  
  while exists ( select top 1 cd_controle from #FaturamentoVendedorFamiliaFinal where cd_vendedor = @cd_vendedor)  
  begin  
     
    select   
      top 1  
      @id           = cd_controle,  
 --@nm_pedido    = @nm_pedido  + ' ' + cast(cd_pedido_venda as varchar(15)),  
      @html_detalhe = @html_detalhe + '  
            <tr>                      
   <td style="font-size:12px; text-align:center;width: 20px">'+nm_familia_produto+'</td>  
   <td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_meta_vendedor as varchar(20))+'</td>     
   <td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_item_nota_saida as varchar(20))+'</td>    
   <td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_formata_valor(pc_meta_familia)+'</td>     
   <td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_formata_valor(vl_total_item)+'</td>     
   <td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_formata_valor(pc_faturamento)+'</td>  
   <td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_formata_valor(case when isnull(pc_meta_familia,0)>100 then vl_premiacao_meta else 0.00 end)+'</td>     
   <td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_cliente as varchar(20))+'</td>     
   <td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_produto as varchar(20))+'</td>     
            </tr>'  
   
  --use egissql_317  
  
     from  
       #FaturamentoVendedorFamiliaFinal  
  
     where  
       cd_vendedor = @cd_vendedor  
  
     order by  
        cd_vendedor, cd_controle  
      
  
  delete from #FaturamentoVendedorFamiliaFinal  
  where  
    cd_controle = @id  
  
 end  
  
 --Totais do Vendedor--  
  
 delete from #Vendedor  
   where cd_vendedor = @cd_vendedor  
  
SET @html_rod_det = '</table>'  
  
  
set @titulo_total = 'SUB-TOTAL'  
  
set @html_totais = '<div class="section-title">'+@titulo_total+'  
     <table style="border: none;">  
                    <tr>            
           <p style="border: none;font-size:18px; text-align:left;"><b>Quantidade Total: '+cast(isnull(@qt_total_vendedor,0) as varchar(10))+'</p>  
           <p style="border: none;font-size:18px; text-align:left;"><b>Valor Total: '+'R$ '+dbo.fn_formata_valor(isnull(@vl_total_vendedor,0))+'</p>   
     </tr>  
     </table>       
     </div>'  
       
 set @html_geral = @html_geral +   
                   @html_cab_det +  
                   @html_detalhe +  
                @html_rod_det +  
       @html_totais  
  
       
end  
  
set @id = 0  

  
set @nm_fantasia_cliente     = '' --'Resumo dos Pedidos de Vendas'  
set @nm_razao_social_cliente = '' --@nm_pedido  
  
set @titulo = @titulo + ' Período : '+dbo.fn_data_string(@dt_inicial) + ' á '+dbo.fn_data_string(@dt_final)  
   
set @html_titulo = '
<div id="tabelaExportar">
<div class="section-title"><strong>'+@titulo+'</strong></div>  
                    <div style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">  
      <p><strong>'+isnull(@nm_fantasia_cliente,'')+'</strong></p>  
     </div>  
                 <div style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">  
              <p><strong>'+isnull(@nm_razao_social_cliente,'')+'</strong></p>                
 </div>'  
        
--------------------------------------------------------------------------------------------------------------------  
  
--Criar uma tabela temporario com os Dados dos atributos  
  
  
--SET @html_rod_det = '</table>'  
  
  
set @titulo_total = 'TOTAIS'  
  
set @html_totais = '<div class="section-title"><strong>'+@titulo_total+'</strong>  
                    <div>   
     <table style="border: none;">  
                    <tr>            
           <p style="border: none;font-size:18px; text-align:left;"><b>Notas: '+cast(isnull(@qt_total,0) as varchar(15))+'</p>  
           <p style="border: none;font-size:18px; text-align:left;"><b>Valor: '+'R$ '+dbo.fn_formata_valor(isnull(@vl_total,0))+'</p>   
     </tr>  
     </table>  
     </div>  
     </div>'  
  
     --&nbsp  
  
--<td style="font-size:12px; text-align:center;width: 80px;">'+'R$ '+dbo.fn_formata_valor(@vl_total)+'</td>  
  
set @footerTitle = ''  
  
--Rodapé--  
  
set @html_rodape =  ' 
    '+case when isnull(@ds_relatorio,'') = '' then '' else '<div class="section-title"><strong>Observações</strong></div>  
    <p>'+@ds_relatorio+'</p>' end+'  
 <div class="report-date-time">  
       <p>Gerado em: '+@data_hora_atual+'</p>  
    </div>
	</div>
	<button id="btnExcel" onclick="exportarExcel()">Baixar Excel</button>
	<script>
function exportarExcel() {
    
    var conteudo = document.getElementById("tabelaExportar").outerHTML;

   
     var blob = new Blob(
        ["\ufeff" + conteudo],
        { type: "application/vnd.ms-excel;charset=utf-8" }
    );
    
    var url = URL.createObjectURL(blob);
    var a = document.createElement("a");
    a.href = url;
    a.download = "Faturamento Família de Cliente por Vendedor.xls";
    a.click();
    URL.revokeObjectURL(url);
}
</script>'  
  
  
--Gráfico--  
set @html_grafico = ''  
  
--HTML Completo--------------------------------------------------------------------------------------  
  
set @html         =   
    @html_empresa +  
    @html_titulo  +  
    @html_geral   +   
    @html_totais  +  
    @html_grafico +  
    @html_rodape    

  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
  go
----------------------------------------------------------------------------------------------------------------------------------------------  

--exec pr_egis_relatorio_cliente_familia_produtos 370,4254,'[{
--    "cd_empresa": 1,
--    "cd_modulo": "357",
--    "cd_menu": "0",
--    "cd_relatorio_form": "370",
--    "cd_processo": "",
--    "cd_form": 32,
--    "cd_documento_form": 138,
--    "cd_parametro_form": "2",
--    "cd_usuario": "4254",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "4254",
--    "dt_usuario": "2025-08-15",
--    "lookup_formEspecial": {},
--    "cd_parametro_relatorio": "138",
--    "cd_relatorio": "370",
--    "dt_inicial": "2024-07-01",
--    "dt_final": "2024-07-30",
--    "cd_vendedor": 0,
--    "detalhe": [],
--    "lote": [],
--    "cd_documento": "138"
--}]'