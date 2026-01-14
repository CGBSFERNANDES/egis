
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_mapa_ativo_cliente_geral' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_mapa_ativo_cliente_geral

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_mapa_ativo_cliente_geral  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_mapa_ativo_cliente_geral  
-------------------------------------------------------------------------------  
--GBS Global Business Solution Ltda                                        2024  
-------------------------------------------------------------------------------  
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020  
--  
--Autor(es)        : João Pedro Marcal  
--  
--Banco de Dados   : Egissql - Banco do Cliente   
--  
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis  
--Data             : 24.08.2024  
--Alteração        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_mapa_ativo_cliente_geral  
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
declare @dt_usuario             datetime = ''  
declare @cd_documento           int = 0  
--declare @cd_parametro           int = 0  
declare @dt_hoje                datetime  
declare @dt_inicial             datetime  
declare @dt_final               datetime  
declare @cd_ano                 int      
declare @cd_mes                 int      
declare @cd_dia                 int  
declare @cd_status              int = 0  
declare @cd_tecnico             int = 0   
declare @cd_tipo_defeito        int = 0  
declare @cd_marca_produto       int = 0   
declare @cd_cotacao             int = 0  
declare @nm_usuario             int = 0   
declare @cd_vendedor            int = 0   
declare @cd_grupo_relatorio     int = 0  
  
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
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais     int = 0,  
   @nm_pais     varchar(20) = '',  
   @cd_cnpj_empresa   varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet  varchar(200) = ''  
  
  
  
--------------------------------------------------------------------------------------------------------  
  
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)          
set @cd_empresa        = 0  
set @cd_form           = 0  
--set @cd_parametro      = 0  
set @cd_documento      = 0  
set @dt_usuario        = GETDATE()  
------------------------------------------------------------------------------------------------------  
  
if @json<>''  
begin    select                       
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
 --@dt_inicial, @dt_final , @cd_status , @cd_tecnico , @cd_tipo_defeito , @cd_marca_produto  
-------------------------------------------------------------------------------------------------  
  
  select @cd_empresa             = valor from #json where campo = 'cd_empresa'               
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'               
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'  
  select @dt_final               = valor from #json where campo = 'dt_final'  
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'  
  
    
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
  
----------------------------------------------------------------------------------------------------------------------------  
select    
  @dt_inicial       = dt_inicial,    
  @dt_final         = dt_final,    
  @cd_vendedor       = isnull(cd_vendedor,0)  
from     
  Parametro_Relatorio    
    
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
declare @html_titulo     nvarchar(max) = '' --Título  
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe  
declare @html_detalhe    nvarchar(max) = '' --Detalhes  
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe  
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
  
-- Obtém a data e hora atual  
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)  
------------------------------  
  
  
---------------------------------------------------------------------------------------------------------------------------------------------  
--Título do Relatório  
---------------------------------------------------------------------------------------------------------------------------------------------  
--select * from egisadmin.dbo.relatorio  
  
  
--select @titulo  
--  
--select @nm_cor_empresa  
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
            background-color:'+isnull(@nm_cor_empresa,'')+';  
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
            font-size: 75%;  
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
    
declare @ic_codigo_cliente           char(1) = 'N'  
--------------------------------------------------------------------------------------------------------------------------  
  
   select   
    b.cd_bem                        as bem,  
    b.cd_bem,  
    b.cd_patrimonio_bem,  
    cp.cd_categoria_produto,  
    cp.nm_categoria_produto,  
    b.nm_bem,  
    cd_registro_bem = (select top 1 vw.cd_registro_bem from vw_posicao_bem vw where vw.cd_bem=b.cd_bem order by vw.dt_registro_bem desc),  
    isnull(p.qt_dia_garantia_produto,0) as qt_dia_garantia_produto  
  into  
    #Consulta    
  
  from      
    bem b  
    left outer join produto p            on p.cd_produto            = b.cd_produto  
    left outer join categoria_produto cp on cp.cd_categoria_produto = p.cd_categoria_produto  
    left outer join status_bem sb        on sb.cd_status_bem        = b.cd_status_bem  
  where  
    isnull(sb.ic_operacao_bem,'S')='S'  
  
  order by  
    b.cd_patrimonio_bem desc  
      
  
  select   
     identity(int,1,1)                           as cd_controle,  
     co.*,  
     case when isnull(co.cd_registro_bem,0)=0 then 'Estoque'   
     else   
        case when rmb.cd_tipo_movimento_bem=6 then  
         'Operação'  
        else  
          case when rmb.cd_tipo_movimento_bem=7 then  
           'Devolvido'  
          else  
          'Operação'  
          end  
        end  
     end                                            as 'subcaption1', --nm_status,  
     case when ns.cd_nota_saida<>0 then  
        cast(@dt_hoje - ns.dt_nota_saida as int )       
     else  
        0  
     end                                            as qt_dia,  
     c.nm_fantasia_cliente + case when isnull(@ic_codigo_cliente,'N') = 'S'  
                               then ' (' + cast(c.cd_cliente as varchar) + ')'  
          else ''  
        end                                                as caption,  
     c.cd_cliente as cd_cliente,
     c.nm_razao_social_cliente,  
     v.nm_fantasia_vendedor,  
     p.nm_fantasia_promotor,  
     ns.cd_identificacao_nota_saida,  
     ltrim(rtrim(isnull(convert(varchar,ns.dt_nota_saida,103),'')))             as quantidade,  
  'calendar-range'                                                           as  'iconFooter1',  
  'black'                                                                    as  'iconColorFooter1',  
  'S'                  as ic_sub_menu,  
     ns.dt_saida_nota_saida,  
     f.nm_fantasia_fornecedor,  
     b.cd_nota_entrada,  
     b.dt_aquisicao_bem,  
     isnull(b.vl_aquisicao_bem,0) as vl_aquisicao_bem,  
	 sb.nm_status_bem as nm_status_bem, 
     
     case when co.qt_dia_garantia_produto<>0 and (b.dt_aquisicao_bem + isnull(co.qt_dia_garantia_produto,0))<=@dt_hoje  
     then 'Garantia'   
     else 'Fora Garantia'  
     end as nm_status_garantia,  
     case when co.qt_dia_garantia_produto<>0 and (b.dt_aquisicao_bem + isnull(co.qt_dia_garantia_produto,0))<=@dt_hoje  
     then  
      cast(@dt_hoje - (b.dt_aquisicao_bem + isnull(co.qt_dia_garantia_produto,0)) as int)  
     else  
       0  
     end  'Dia_Garantia',  
     isnull(b.cd_patrimonio_bem,'')+'-'+isnull(b.nm_bem,'') as 'resultado' --nm_patrimonio_bem  
  into  
  #RelMapaAtivo  
  
  from  
   #Consulta  co  
   left outer join bem b                      on b.cd_bem             = co.cd_bem  
   left outer join Registro_Movimento_Bem rmb on rmb.cd_registro_bem  = co.cd_registro_bem  
   left outer join cliente c                  on c.cd_cliente         = rmb.cd_cliente   
   left outer join vendedor v                 on v.cd_vendedor        = c.cd_vendedor  
   left outer join cliente_promotor cp        on cp.cd_cliente        = c.cd_cliente   
   left outer join promotor p                 on p.cd_promotor        = cp.cd_promotor  
   left outer join status_bem sb              on sb.cd_status_bem     = b.cd_status_bem    
   left outer join nota_saida ns              on ns.cd_nota_saida     = rmb.cd_nota_saida  
   left outer join fornecedor f               on f.cd_fornecedor      = b.cd_fornecedor  
  left outer join status_cliente sc          on sc.cd_status_cliente = c.cd_status_cliente  
  where
	ns.dt_saida_nota_saida between @dt_inicial and @dt_final
   and 
    c.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then c.cd_vendedor else isnull(@cd_vendedor,0) end  
  and isnull(sc.ic_analise_status_cliente,'N')='S'  
  
  order by ns.dt_nota_saida desc, c.nm_fantasia_cliente, co.cd_patrimonio_bem desc  
--------------------------------------------------------------------------------------------------------------  
declare @qt_total_cliente int = 0  
  
select  
 @qt_total_cliente = count(caption)  
   
from #RelMapaAtivo
--select @qt_total_bem
-----------------------------------------------------------------------------------------------------------------  
 if isnull(@cd_parametro,0) = 1    
 begin    
    select * from #RelMapaAtivo    
  return    
 end    
--------------------------------------------------------------------------------------------------------------  
set @html_geral = '  
        <div class="section-title">  
			<p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
			<p style="display: inline; text-align: center; padding: 25%;"> '+isnull(+@titulo,'')+' </p>  
        </div>   
        <table>  
            <tr>  
			    <th>Código</th> 
                <th style="text-align: left;">Cliente</th>  
                <th style="text-align: left;">Patrimonio</th>  
                <th>Série/RG</th>  
                <th>Nota</th>  
                <th>Data</th> 
				<th>Garantia</th> 
				<th>Status</th>  
				<th>Vendedor</th>  
            </tr>'  
           
  
--------------------------------------------------------------------------------------------------------------  
declare @id int = 0  
while exists ( select top 1 cd_controle from #RelMapaAtivo)  
begin  
 select top 1  
  @id                         = cd_controle,  
  
  @html_geral = @html_geral +'<tr>
		   <td>'+cast(isnull(cd_cliente,'') as nvarchar(20))+'</td>	
           <td style="text-align: left;">'+isnull(caption,0)+'</td>   
           <td style="text-align: left;">'+isnull(nm_bem,'')+'</td>  
           <td>'+cast(isnull(cd_patrimonio_bem,'') as nvarchar(20))+'</td>  
           <td>'+cast(isnull(cd_identificacao_nota_saida,'') as nvarchar(20))+'</td>  
           <td>'+isnull(quantidade,'')+'</td>  
           <td>'+isnull(nm_status_garantia,'')+'</td>  
		   <td>'+isnull(nm_status_bem,'')+'</td>
           <td>'+isnull(nm_fantasia_vendedor,'')+'</td>  
          </tr>'  
        
     from #RelMapaAtivo  
  delete from #RelMapaAtivo where cd_controle = @id  
 end  
--------------------------------------------------------------------------------------------------------------------  
declare @html_totais nvarchar(max)=''  
declare @titulo_total varchar(500)=''  
  
set @html_rodape =  
   ' </table>  
    <p>'+@ds_relatorio+'</p>  
 <div>  
       <p class="section-title" style="font-size: 20px;">Total de Clientes: '+cast(isnull(@qt_total_cliente,0)as nvarchar(20))+'</p>  
    </div>  
 <div class="report-date-time">  
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>  
    </div>'  
  
  
  
--HTML Completo--------------------------------------------------------------------------------------  
  
set @html         =   
    @html_empresa +  
    @html_titulo  +  
 @html_geral   +   
 @html_cab_det +  
    @html_detalhe +  
 @html_rod_det +  
 @html_totais  +   
    @html_rodape    
  
---------------------  
  
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
 go
 
--- exec pr_egis_relatorio_mapa_ativo_cliente_geral 265,0,''