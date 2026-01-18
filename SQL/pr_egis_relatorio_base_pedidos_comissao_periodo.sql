IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_base_pedidos_comissao_periodo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_base_pedidos_comissao_periodo

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_pedido_geral  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_pedido_geral  
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
--Alteracao        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_base_pedidos_comissao_periodo  
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
declare @ic_valor_comercial     varchar(10)  
declare @cd_tipo_destinatario   int   
declare @cd_cliente_grupo       int = 0  
declare @cd_grupo_relatorio     int    
declare @cd_vendedor            int    
declare @nm_razao_social        varchar(60) = ''
declare @cd_categoria_produto   int = 0 
  
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
   @ds_relatorio    varchar(8000) = '',  
   @subtitulo     varchar(40)   = '',  
   @footerTitle    varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais     int = 0,  
   @nm_pais     varchar(20) = '',  
   @cd_cnpj_empresa   varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet  varchar(200) = '',
   @cd_categoria_cliente int = 0
  
   
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
 
  select @cd_empresa             = valor from #json where campo = 'cd_empresa'               
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'               
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'   
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'  
  select @dt_final               = valor from #json where campo = 'dt_final'  


   --set @cd_cliente = isnull(@cd_cliente,0)  
  
   --if @cd_cliente = 0  
   --begin  
   --  select @cd_cliente           = valor from #json where campo = 'nm_razao_social'  
  
   --end  
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
  @dt_inicial			  = dt_inicial,    
  @dt_final				  = dt_final,    
  @cd_vendedor			  = isnull(cd_vendedor,0)
from     
  Parametro_Relatorio    
    
where    
  cd_relatorio = @cd_relatorio    
  and    
  cd_usuario   = @cd_usuario    
---------------------------------------------------------------------------------------------------------------------------  
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
  
-- Obtem a data e hora atual  
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)  
------------------------------  

--Cabecalho da Empresa----------------------------------------------------------------------------------------------------------------------  

  
SET @html_empresa = '  
<html>  
<head>  
    <meta charset="UTF-8">  
    <meta http-equiv="X-UA-Compatible" content="IE=edge">  
    <meta name="viewport" content="width=device-width, initial-scale=1.0">  
 <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.2/html2pdf.bundle.min.js" integrity="sha512-MpDFIChbcXl2QgipQrt1VcPHMldRILetapBl5MPCA9Y8r7qvlwx1/Mc9hNTzY+kS5kX6PdoDq41ws1HiVNLdZA==" crossorigin="anonymous" referrerpolicy="no-referrer
"></script>  
    <title >'+@titulo+'</title>  
    <style>  
        body {  
            font-family: Arial, sans-serif;  
            color: #333;  
			padding:20px;  
			flex:1;
        }  
  
        h2 {  
            color: #333;  
        }  
  
        table {  
            width: 100%;  
            border-collapse: collapse;  
            margin-bottom: 20px;  
            font-size: 12px;  
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
  tr {  
   page-break-inside: avoid;    
   page-break-after: auto;  
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
            padding: 3px;  
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
 </style>  
</head>  
<body>  
   <div id="conteudo">  
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
  
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)  
  
  
------------------------------------------------------------------------------------------------------------------------  
--set @cd_vendedor  = 9
--set @dt_inicial = '06/01/2025'
--set @dt_final = '06/30/2025'


--create table #GerarComissão(
--	cd_metodo                    int,
--	nm_metodo                    varchar(80), 
--	pc_comissao_metodo           float,
--	hr_inicial_pedido            varchar(5),
--	cd_pedido_venda              int,
--	dt_pedido_venda              datetime,
--	nm_tipo_pedido               varchar(30),
--	cd_cliente                   int,
--	nm_fantasia_cliente          varchar(60),
--	cd_vendedor                  int,
--	nm_fantasia_vendedor         varchar(30),
--	vl_total                     float,
--	cd_usuario_ordsep            int,
--	dt_ordsep_pedido_venda       datetime,
--	ic_ordsep_pedido_venda       char(1),
--	nm_fantasia_empresa          varchar(30),
--	sg_estado                    char(2),
--	nm_cidade                    varchar(60),
--	nm_cliente_grupo             varchar(60),
--	cd_identificacao_nota_saida  int,
--	dt_nota_saida                datetime,
--	Base_Calculo                 float,
--	pc_comissao_vendedor         float,
--	pc_comissao_cliente          float,
--	vl_comissao_vendedor         decimal(25,2),
--	qt_comodato                  int
--)
----BEGIN TRY
--  INSERT INTO #GerarComissão
--  EXEC pr_gera_calculo_comissao_egisnet 3, @cd_vendedor, @dt_inicial, @dt_final, @cd_usuario
----END TRY
----BEGIN CATCH
----  PRINT 'Erro ao inserir dados da procedure';
----END CATCH

-- select * from #GerarComissão
select 
	identity(int,1,1)            as cd_controle,
	max(g.cd_metodo)             as cd_metodo,
	max(g.cd_calculo)            as cd_calculo,
	max(pv.vl_total_pedido_ipi)  as vl_total,
	right(left(convert(varchar,pv.hr_inicial_pedido,121),16),5) as hr_inicial_pedido,
	pv.dt_pedido_venda		     as dt_pedido_venda,
	max(mc.nm_metodo)			 as nm_metodo,
	mc.pc_comissao_metodo	 as pc_comissao_metodo,
	tp.nm_tipo_pedido		     as nm_tipo_pedido,
	max(g.vl_comissao)           as vl_comissao,
	max(g.qt_comodato)           as qt_comodato,
	pv.cd_pedido_venda           as cd_pedido_venda,
	c.cd_cliente                 as cd_cliente,
	c.nm_fantasia_cliente        as nm_fantasia_cliente,
	v.nm_fantasia_vendedor       as nm_fantasia_vendedor,
	max(ef.nm_fantasia_empresa)  as nm_fantasia_empresa,
    max(est.sg_estado)           as sg_estado,
    max(cid.nm_cidade)           as nm_cidade,
	max(vl_base_calculo)         as vl_base_calculo,
	max(g.pc_comissao)           as pc_comissao

  into
	#GerarComissãoFinal
from 
	Comissao_Calculo_Vendedor g
  left outer join Pedido_Venda pv          on pv.cd_pedido_venda   = g.cd_pedido_venda
  left outer join Metodo_Comissao mc       on mc.cd_metodo         = g.cd_metodo
  left outer join tipo_pedido tp           on tp.cd_tipo_pedido    = pv.cd_tipo_pedido
  left outer join cliente c                on c.cd_cliente         = pv.cd_cliente 
  inner join pedido_venda_item i           on i.cd_pedido_venda   = pv.cd_pedido_venda
  left outer join vendedor v               on v.cd_vendedor        = pv.cd_vendedor
  left outer join pedido_venda_empresa pve on pve.cd_pedido_venda  = pv.cd_pedido_venda
  left outer join empresa_faturamento ef   on ef.cd_empresa        = pve.cd_empresa
  left outer join Estado est               on est.cd_estado        = c.cd_estado
  left outer join cidade cid               on cid.cd_cidade        = c.cd_cidade

  where 
  pv.dt_pedido_venda between @dt_inicial and @dt_final
  and
  pv.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then pv.cd_vendedor else isnull(@cd_vendedor,0) end
  and
   i.dt_cancelamento_item is null
  and
    ISNULL(tp.ic_bonificacao_tipo_pedido,'N') = 'N'
  and
  ISNULL(tp.ic_indenizacao_tipo_pedido,'N') = 'N'
  group by 
  pv.hr_inicial_pedido, 
  pv.cd_pedido_venda,
  pv.dt_pedido_venda,
  tp.nm_tipo_pedido,
  c.cd_cliente,
  c.nm_fantasia_cliente,
  v.cd_vendedor,
  v.nm_fantasia_vendedor,
  mc.pc_comissao_metodo
  order by
  pv.cd_pedido_venda
	--select * from Metodo_Comissao
	--select * from Comissao_Calculo_Vendedor
	
--------------------------------------------------------------------------------------------------------------  
declare 
	@vl_total float = 0,
	@qt_cliente int = 0,
	@vl_comissao float = 0,
	@qt_comodato int =0
select 
	@vl_total = sum(vl_total),
	@qt_cliente = count(cd_cliente),
	@vl_comissao = sum(vl_comissao),
	@qt_comodato = sum(qt_comodato)
from #GerarComissãoFinal
  
set @html_geral = '   
    <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 20%;"> '+isnull(+@titulo,'')+' </p>  
    </div>  
 <div>  
    <table>  
      <tr class="tamanho">  
		   <th>Método</th>  
           <th>% Comissão</th>  
		   <th>Hora Inicial</th>  
		   <th>Pedido Venda</th>  
		   <th>Data Pedido</th>  
		   <th>Tipo</th>  
		   <th>Cliente</th>  
		   <th>Vendedor</th>
		   <th>Valor Total</th>  
		   <th>Empresa</th>  
		   <th>UF</th>
		   <th>Cidade</th>  
		   <th>Base Calculo</th>  
		   <th>%Comissão Vendedor</th>  
		   <th>Valor Comissão</th>  
		   <th>Comodato</th>  
        </tr>'  
  
          
--------------------------------------------------------------------------------------------------------------  
DECLARE @id int = 0   
  
WHILE EXISTS (SELECT TOP 1 cd_controle FROM #GerarComissãoFinal)  
BEGIN  
    SELECT TOP 1  
        @id                          = cd_controle,  
        @html_geral = @html_geral +  
			'<tr class="tamanho">  
				<td>'+isnull(nm_metodo,'')+' ('+cast(isnull(cd_metodo,0)as varchar(20))+')</td>
				<td>'+cast(isnull(dbo.fn_formata_valor(pc_comissao_metodo),0)as varchar(20))+' </td>
				<td>'+isnull(hr_inicial_pedido,'')+'</td>
				<td>'+cast(isnull(cd_pedido_venda,0)as varchar(20))+'</td>
				<td>'+isnull(dbo.fn_data_string(dt_pedido_venda),'')+'</td>
				<td>'+isnull(nm_tipo_pedido,'')+'</td>
				<td>'+isnull(nm_fantasia_cliente,'')+'</td>
				<td>'+isnull(nm_fantasia_vendedor,'')+'</td>
				<td>'+cast(isnull(dbo.fn_formata_valor(vl_total),0)as varchar(20))+'</td>
				<td>'+isnull(nm_fantasia_empresa,'')+'</td>
				<td>'+isnull(nm_cidade,'')+'</td>
				<td>'+isnull(sg_estado,'')+'</td>
				<td>'+cast(isnull(dbo.fn_formata_valor(vl_base_calculo),0)as varchar(20))+'</td>
				<td>' + FORMAT(ISNULL(pc_comissao, 0), 'N4', 'pt-BR') + '</td>
				<td>'+cast(isnull(dbo.fn_formata_valor(vl_comissao),0)as varchar(20))+'</td> 
				<td>'+cast(isnull(qt_comodato,0)as varchar(20))+'</td>
			 </tr>'  
	FROM #GerarComissãoFinal  
    DELETE FROM #GerarComissãoFinal WHERE cd_controle = @id  
END  

--------------------------------------------------------------------------------------------------------------------  
  
  
  
  
set @html_rodape =  
     '		<tr  class="tamanho"style="text-align: center;font-weight: bold;">  
                <td><b>Total</b></td>  
                <td></td>
			   	<td></td>
				<td></td>
				<td></td>
				<td></td>
				<td>'+cast(isnull(@qt_cliente,'')as varchar(20))+'</td>
				<td></td>
				<td>'+cast(isnull(dbo.fn_formata_valor(@vl_total),0)as varchar(20))+'</td>
				<td></td>
				<td></td>
				<td></td>
				<td></td>
				<td></td>
				<td>'+cast(isnull(dbo.fn_formata_valor(@vl_comissao),0)as varchar(20))+'</td>
				<td>'+cast(isnull(@qt_comodato,0)as varchar(20))+'</td>
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
  
---------------------  
  
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
  
go 

--exec pr_egis_relatorio_base_pedidos_comissao_periodo 280,0,''
--exec pr_egis_relatorio_padrao 327,0,'[{
--    "cd_empresa": "340",
--    "cd_modulo": "247",
--    "cd_menu": "0",
--    "cd_relatorio_form": "327",
--    "cd_processo": "",
--    "cd_form": 101,
--    "cd_documento_form": 82,
--    "cd_parametro_form": "2",
--    "cd_usuario": "4574",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "4574",
--    "dt_usuario": "2025-06-26",
--    "lookup_formEspecial": {},
--    "cd_parametro_relatorio": "82",
--    "cd_relatorio": "327",
--    "dt_inicial": "2025-06-01",
--    "dt_final": "2025-06-30",
--    "cd_vendedor": 12,
--    "detalhe": [],
--    "lote": [],
--    "cd_documento": "82"
--}]'