IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_certificado_qualidade' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_certificado_qualidade

go
-------------------------------------------------------------------------------    
--sp_helptext pr_egis_relatorio_certificado_qualidade 
-------------------------------------------------------------------------------    
--pr_egis_relatorio_certificado_qualidade
-------------------------------------------------------------------------------    
--GBS Global Business Solution Ltda                                        2020    
-------------------------------------------------------------------------------    
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016    
--    
--Autor(es)        : Alexandre Santos Adabo    
--    
--Banco de Dados   : EgisAdmin    
--    
--Objetivo         : Relatório de Certificado de Qualidade (Egisnet)  
--                         
--Data             : 09.12.2024    
--Alteração        :     
-- 
-----------------------------------------------------------------------------------
create procedure pr_egis_relatorio_certificado_qualidade
@cd_relatorio int   = 0,
@cd_usuario   int   = 0,
@cd_parametro int   = 0,
@cd_documento int   = 0,

@json nvarchar(max) = '' 

as 

set @json = isnull(@json,'')  
 declare @cd_empresa     int = 0  
 declare @cd_laudo       int = 0
-- declare @cd_modelo               int = 0  
 declare @cd_ano                  int      
 declare @cd_mes                  int      
 declare @cd_dia                  int  
 declare @dt_inicial              datetime  
 declare @dt_final                datetime  
 declare @dt_hoje                 nvarchar(50)  
 declare @cd_grupo_relatorio      int   
 declare @cd_item_pedido_venda    int  
 declare @ic_desconto             varchar(100)         
 declare @casadec                 int         
 declare @pc_tpedido              float   
 declare @ic_imposto              char(1)      
 declare @ic_nao_faturado         char(1) = 'N'  
 declare @ic_cancelados           char(1) = 'N'    
 declare @ic_mostrar_valor_original  char(1) = 'N'  
 declare @dt_entrega              datetime   
 declare @dt_fabrica              varchar(30)    
 declare @parcela                 varchar(8000)                            
 declare @pvencto                 varchar(8000)                            
 declare @pvalor                  varchar(8000)  
 declare @parcelas                varchar(8000)   
 declare @dt_impresso             varchar(30)     
 declare @cnpj                    nvarchar(30)  
 
-----------------------------Dados do Relatório----------------------------------------  
  
 declare  
   @cd_pedido_venda             int = 0,  
   @logo                       varchar(400),  
   @nm_cor_empresa             varchar(20),  
   @nm_endereco_empresa       varchar(200) = '',  
   @cd_telefone_empresa     varchar(200) = '',  
   @nm_email_internet      varchar(200) = '',  
   @nm_cidade        varchar(200) = '',  
   @sg_estado        varchar(10)  = '',  
   @nm_fantasia_empresa     varchar(200) = '',
   @nm_empresa              varchar(200) = '',
   @cd_cep_empresa       varchar(20) = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @nm_pais     varchar(20) = '',  
   @cd_cnpj_empresa   varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',   
   @nm_dominio_internet  varchar(200) = '',   
   @titulo                     varchar(200),  
   @nm_caminho                 nvarchar(150),  
   @nm_caminho_gerado          nvarchar(150),  
   @cd_pedido_100              int=0,  
   @cd_modelo                  int   = 0  
---------------------------------------------------------------------------------------  
  
set @dt_impresso       = cast(replace(convert(char,getdate(),103),'.','-') as varchar(30))                                    
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)                                  
set @pc_tpedido           = 0          
--set @cd_laudo             = @cd_documento 
  
---------------------------------------------------------------------------------------  
 
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
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_laudo               = valor from #json where campo = 'cd_laudo'
 


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'


   end
end

-----------------------------------------------------------------------------------------  
   
declare @ic_processo char(1) = 'N'  
   
  
select  
  @titulo             = nm_relatorio,  
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),  
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)  
  
from  
  egisadmin.dbo.Relatorio  
where  
  cd_relatorio = @cd_relatorio  
 
-- SELECT * FROM  egisadmin.dbo.Relatorio  
 --where  
 -- cd_relatorio = @cd_relatorio  
---------------------------------------------------------------------------------------------  
  
select  
  @titulo             = nm_relatorio,  
--  @ic_processo        = isnull(ic_processo_relatorio, 'N'),  
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)  
from  
  egisadmin.dbo.Relatorio  
where  
  cd_relatorio = @cd_relatorio  
  
  
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
--------------------------------------------------------------------------------------  
  
set @cd_empresa = dbo.fn_empresa()  
  
----------------------------------------------------------------------------------------  
  
  
select   
  @logo                     = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),  
  @nm_cor_empresa           = isnull(e.nm_cor_empresa,'#1976D2'),  
  @nm_endereco_empresa      = isnull(e.nm_endereco_empresa,''),  
  @cd_telefone_empresa      = isnull(e.cd_telefone_empresa,''),  
  @nm_email_internet        = isnull(e.nm_email_internet,''),  
  @nm_cidade                = isnull(c.nm_cidade,''),  
  @sg_estado                = isnull(es.sg_estado,''),  
  @nm_fantasia_empresa      = isnull(e.nm_fantasia_empresa,''),  
  @nm_empresa               = isnull(e.nm_empresa,''),
  @cd_cep_empresa           = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),  
  @cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),  
  @nm_pais                  = ltrim(rtrim(isnull(p.sg_pais,''))),  
  @cd_cnpj_empresa   = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),  
  @cd_inscestadual_empresa =  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),  
  @nm_dominio_internet  =  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))  
    
 from egisadmin.dbo.empresa e with(nolock)  
 left outer join Estado es  with(nolock) on es.cd_estado = e.cd_estado  
 left outer join Cidade c  with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado  
 left outer join Pais p   with(nolock) on p.cd_pais = e.cd_pais  
 where   
  cd_empresa = @cd_empresa  
---------------------------------------------------------------------------------------------------------------------  
  
declare @html            nvarchar(max) = '' --Total  
declare @html_empresa    nvarchar(max) = '' --Cabeçalho da Empresa  
declare @html_grafico    nvarchar(max) = '' --Gráfico  
declare @html_titulo     nvarchar(max) = '' --Título  
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe  
declare @html_detalhe    nvarchar(max) = '' --Detalhes  
declare @html_detalhe_1  nvarchar(max) = '' --Detalhes_parte_1  
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe  
declare @html_rodape     nvarchar(max) = '' --Rodape  
declare @html_totais     nvarchar(max) = '' --Totais  
declare @html_geral      nvarchar(max) = '' --Geral 
--declare @html_detalhe1   nvarchar(max) = ''
  
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
  
--------------------------------------------------------------------------------------------------------  
  
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
            margin: 0;  
            padding: 0;  
            background-color: #f9f9f9;  
        }  
  
        .container {  
            width: 80%;  
            max-width: 1200px;  
            margin: 20px auto;  
            background-color: #fff;  
            padding: 20px;  
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);  
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
            padding: 8px;  
            text-align: center;  
        }  
  
        th {  
            background-color: #f2f2f2;  
            color: #333;  
        }  
  
        tr:nth-child(even) {  
            background-color: #f9f9f9;  
        }  
  
        .header {  
            text-align: center;  
            padding-bottom: 20px;  
        }  
  
        .section-title {  
            background-color: '+@nm_cor_empresa+';  
            color: white;  
            padding: 5px;  
            margin-bottom: 10px;  
   border-radius:5px;  
   text-align: left;  
        }  
         img {  
            max-width: 250px;  
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
          
        }  
        .title {   
            color: '+@nm_cor_empresa+';  
   text-align: center;  
        }  
       .assinatura {  
            display: flex;  
            justify-content: center;  
            align-items: center;  
            text-align: center;  
        }  
  
        .textocorpo {  
            text-align: justify;  
            margin: 15px 110px;  
        }  
    </style>  
</head>  
<body>  
    <div class="container">  
        <table>  
            <tr>  
                <td style="width: 20%; text-align: center;">  
                    <img src="'+isnull(@logo,'')+'" alt="Logo da Empresa">  
                </td>  
                <td style="width: 60%; text-align: left;">  
                    <p class="title">'+isnull(@nm_empresa,'')+'</p>  
                    <p><strong>'+isnull(@nm_endereco_empresa,'')+', '+isnull(@cd_numero_endereco_empresa,'') + ' - '+isnull(@cd_cep_empresa,'')+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>  
                    <p><strong>Fone:</strong>'+@cd_telefone_empresa+' -  <strong>CNPJ:</strong>' + @cd_cnpj_empresa + ' - <strong>I.E:</strong> ' + @cd_inscestadual_empresa + '</p>  
                    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>  
                </td>  
                 <td style="width: 20%; text-align: center;">
                    <p><strong>Número:</strong></p>
                    <p style="font-size:30px">'+cast(isnull(@cd_laudo,0)as nvarchar (10))+'</p>  
                </td>  
            </tr>  
        </table>  
 '  
  
 --select  @html_empresa as empresa, @nm_cor_empresa,@titulo  
   
---------------------------------------------------------------------------------------------------------  
  
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
--select * from #RelAtributo  
  
------------------------------------------------------------------------------------------  
   
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


--pr_laudo


  
--SELECT @nm_dados_cab_det  
  
drop table #AuxRelAtributo  
  
declare @vl_valor_total          decimal(25,2) = 0.00  
declare @qt_total                int = 0  

--declare @cd_laudo  int = 0 
declare @cd_idioma int = 0
  
--------------------------------Select HTML-----------------------------------------------------------  
  select 
  IDENTITY(int, 1, 1) as cd_controle,
  cl.sg_caracteristica_laudo         as Etapa, 
  cl.nm_caracteristica_laudo         as nm_Caracteristica,
  lc.nm_especificacao                as Especicacao,
  lc.nm_resultado_obtido             as resultado,
  lc.nm_obs_caracteristica           as caracteristica
  into
  #tabela
from  Laudo_Caracteristica lc
  left outer join caracteristica_laudo cl         on cl.cd_caracteristica_laudo  = lc.cd_caracteristica_laudo    

  where        
     lc.cd_laudo = @cd_laudo 
-----------------------------------------------------------------------------------------------------------------------------
declare @especificado            nvarchar(100)
declare @item                    nvarchar(100)
declare @encontrado              nvarchar(100)
declare @status_laudo            nvarchar(100)
declare @nm_Caracteristica       nvarchar(100)

	declare @nm_tolerancia_produto nvarchar(30)
----------------------------------------------------------------------------------------------------------------------------------------
  select 
   IDENTITY(int, 1, 1) as cd_controle,   
  case when p.nm_produto is not null then p.nm_produto else l.nm_produto_especial_laudo end as nm_produto,
  l.qt_laudo                         as qt_laudo, --quantidade
  cast(case when isnull(l.cd_cliente,0)<>0 then c.nm_razao_social_cliente else f.nm_razao_social end as varchar) as nm_razao_social,
  l.cd_processo                      as cd_processo, --op nº
  ins.cd_identificacao_nota_saida    as cd_identificacao_nota_saida, 
  pv.cd_pedido_venda                 as cd_pedido_venda,--pedido
  stl.nm_status_laudo                as nm_status_laudo,
  stl.sg_status_laudo                as sg_status_laudo,
  i.nm_inspetor                      as nm_inspetor,
  l.dt_laudo                         as dt_laudo,
  mp.nm_mat_prima                    as nm_mat_prima,
  getdate() as dt_hoje --@dt_hoje
  into 
  #CapaLaudo
From   
  Laudo l with(nolock)
  left outer join Origem_laudo ol                      with(nolock) on (l.cd_origem_laudo   = ol.cd_origem_laudo)
  left outer join Status_laudo stl                     with(nolock) on (stl.cd_status_laudo = l.cd_status_laudo)
  left outer join Fornecedor f                         with(nolock) on (l.cd_fornecedor = f.cd_fornecedor)
  left outer join Cliente c                            with(nolock) on (l.cd_cliente    = c.cd_cliente )
  left outer join Produto p                            with(nolock) on (l.cd_produto = p.cd_produto)
  left outer join Inspetor i                           with(nolock) on i.cd_inspetor = l.cd_inspetor
  left outer join processo_producao prd                with(nolock) on prd.cd_processo       = l.cd_processo
  left outer join pedido_venda pv                      with(nolock) on pv.cd_pedido_venda  = prd.cd_pedido_venda
  left outer join pedido_venda_item pvi                with(nolock) on pvi.cd_pedido_venda = prd.cd_pedido_venda and pvi.cd_item_pedido_venda = prd.cd_item_pedido_venda
  left outer join vw_pedido_venda_item_nota_saida ins  with(nolock) on ins.cd_pedido_venda = prd.cd_pedido_venda and ins.cd_item_pedido_venda = prd.cd_item_pedido_venda
  left outer join produto_custo pc                     with(nolock) on pc.cd_produto   = p.cd_produto
  left outer join Materia_Prima mp                     with(nolock) on mp.cd_mat_prima = pc.cd_mat_prima
where
  l.cd_laudo = @cd_laudo--@cd_documento

  
----------------------------------------------------------------------------------------------------------------------------  
declare @nm_produto                   nvarchar(100)
declare @nm_razao_social              nvarchar(100)
declare @qt_laudo                     float = 0 
declare @cd_processo                  float = 0 
declare @cd_identificacao_nota_saida  int = 0 
declare @pedido_venda                 int = 0 
declare @nm_status_laudo              nvarchar(50)
declare @sg_status_laudo              nvarchar(50)
declare @nm_inspetor                  nvarchar(50)
declare @dt_laudo                     datetime
declare @nm_mat_prima                 nvarchar(60)


select 
	@nm_produto                    = nm_produto,
	@nm_razao_social               = nm_razao_social,
	@qt_laudo					   = qt_laudo,				
	@cd_processo				   = cd_processo,
	@cd_identificacao_nota_saida   = cd_identificacao_nota_saida,
	@pedido_venda                  = cd_pedido_venda,
	@nm_status_laudo			   = nm_status_laudo,					
	@sg_status_laudo			   = sg_status_laudo,
	@nm_inspetor                   = nm_inspetor, 
	@dt_laudo                      = dt_laudo,
	@nm_mat_prima                  = nm_mat_prima
		
from #CapaLaudo

--select * from laudo 
--select @nm_inspetor

----------------------------------------------------------------------------------------------------------------------------
  set @html_detalhe = '  
  <h1 style="text-align: center;" >CERTIFICADO DE QUALIDADE RQ 37 REVISÃO 01</h1>  
        <table style="width: 100%;">  
            <tr>  
                <td style="display: flex; flex-direction: column; gap: 20px;">  
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">  
                        <div style="text-align: left; width: 45%;">  
                            <p><strong>Item:</strong> '+isnull(@nm_produto,'')+'</p>  
                            <p><strong>Material:</strong> '+isnull(@nm_mat_prima,'')+'</p>  
                            <p><strong>Quantidade:</strong> '+cast(isnull(dbo.fn_formata_valor(@qt_laudo),0) as nvarchar(20))+'</p>  
                        </div>      
                        <div style="text-align: left;">  
                            <p><strong>Cliente/Fornecedor:</strong> '+isnull(@nm_razao_social,'')+' </p>  
                            <p><strong>OP Nº:</strong> '+CAST(ISNULL(@cd_processo,0) AS nvarchar(20))+'</p>  
                            <p><strong>NF Nº:</strong> '+CAST(ISNULL(@cd_identificacao_nota_saida,0)AS nvarchar(20))+'</p>  
							<p><strong>Pedido Nº:</strong> '+CAST(ISNULL(@pedido_venda,0)AS nvarchar(20))+'</p> 

                        </div>     
          
                    </div>  
                </td>  
            </tr>  
        </table>  
  <table>  
            <thead>  
                <tr>  
                    <th>Item</th>  
					<th>Caracteristica</th> 
                    <th>Especificação</th>  
                    <th>Encontrado LUFAED</th>  
                    <th>Laudo</th>  
                </tr>  
            </thead>'
  
  
  ------------------------------------------------------------------------------------------------------------------------------------       
 declare @id int= 0  
 while exists ( select top 1 cd_controle from #tabela )  
 begin  
   
  select top 1  
  @id                 = cd_controle,
  @nm_Caracteristica  = nm_Caracteristica,
  @item				  = Etapa,
  @especificado		  = Especicacao,
  @encontrado		  = resultado,
  @status_laudo		  = caracteristica

  from  #tabela
  
  set @html_detalhe = @html_detalhe + '  
           <tbody>  
                <tr>  
                    <td>'+isnull(@item,'')+'</td>  
					<td>'+isnull(@nm_Caracteristica,'')+'</td> 
                    <td>'+isnull(@especificado,'')+'</td>  
                    <td>'+isnull(@encontrado,'')+'</td>  
                    <td>'+isnull(@status_laudo,'')+'</td>  
                </tr>  
            </tbody>  
 '    
    
delete from #tabela where cd_controle = @id  
    
end  

----------------------------------------------------------------------------------------------------------------------------------

set  @html_detalhe_1 = @html_detalhe_1 +'  
  <table style="width: 100%;">
                <tr>
                    <td style="display: flex; flex-direction: column; gap: 20px;">
                        <p style="display: flex; justify-content: space-between;margin: 10PX; gap: 80px;">
                           <strong> LEGENDA </strong>
                            <span><strong> LAUDO </strong></span>
                        </p> 
        
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
                           
                            <div style="text-align: left; width: 45%;">
                                <p><strong>AD - Análise Dimensional</strong></p>
                                <p><strong>AQ - Análise Quimica</strong></p>
                                <p><strong>TT - Tratamento Térmico</strong></p>
                                <p><strong>TS - Tratamento Superficial</strong></p>
                                <p><strong>LE - Limite de Escoamento</strong></p>
                            </div>    
                            <div style="text-align: left;">
                                <p><strong>LR - Limite de Resistência </strong></p>
                                <p><strong>AL - Alongamento</strong></p>
                                <p><strong>A - Aprovado</strong></p>
                                <p><strong>AC - Aprovado Condicional</strong></p>
                                <p><strong>R - Reprovado</strong></p>
                            </div>   
            
                        </div>
                    </td>
                </tr>
            </table>
            <table>  
                <tr>  
                    <th style="width: 33%;">Disposição final</th>  
                    <th style="width: 33%;">Inspetor de Qualidade</th>  
                    <th style="width: 33%;">Data</th>  
                </tr>  
                <tr>  
                    <td>  
                        <p><strong>'+isnull(@nm_status_laudo,'')+'</strong></p>  
                    </td>  
                    <td>  
                        <p><strong>'+isnull(@nm_inspetor,'')+'</strong></p>  
                    </td>  
                    <td>  
                        <p><strong>Data: '+dbo.fn_data_string(isnull(@dt_laudo,''))+'</strong></p>  
                    </td>  
                </tr>  
            </table>  
  
            <table>  
                <tr>  
                    <th style="text-align: CENTER;">Identificação RQ37 revisão 01 Armazenamento Qualidade Proteção Recuperado Eletronico Retenção 01 ano Descarte rasgar</th>  
                </tr>  
            </table>  
    </div>  
</body>  
  
</html>  
 '  
-----------------------------------------------------------------------------------------------------------------------------  
  
  
set @html         =   
    @html_empresa +  
    @html_titulo  +  
  
 --@html_cab_det +  
  @html_detalhe +  
  @html_detalhe_1+
 --@html_rod_det +  
  
 @html_geral   +   
 @html_totais  +  
 @html_grafico +  
    @html_rodape    
  
--select @html, @html_empresa, @html_titulo, @html_cab_det, @html_rod_det, @html_totais, @html_grafico, @html_rodape  
  
-------------------------------------------------------------------------------------------------------  
  
-- select top 100 * from pedido_venda_item  where cd_pedido_venda = 45676  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------

go

--exec pr_egis_relatorio_certificado_qualidade 209,4253,0,10920,''

/*------------------------------------------------------------------------------
--Testando a Stored Procedure


-- Relatorio 209 (modulo financeiro Net **alterar ** )
------------------------------------------------------------------------------*/
