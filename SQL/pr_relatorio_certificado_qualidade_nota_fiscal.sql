 
 IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_certificado_qualidade_nota_fiscal' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_certificado_qualidade_nota_fiscal

go
------------------------------------------------------------------------------
--use egissql_317
-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_certificado_qualidade_nota_fiscal
-------------------------------------------------------------------------------
--pr_egis_relatorio_padrao
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Alexandre Santos Adabo / João Pedro Marçal
--
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 23.12.2024
--Alteração        : 
-----------------------------------------------------------------------------------  
create procedure pr_relatorio_certificado_qualidade_nota_fiscal  
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
   @cd_pedido_venda            int           = 0,  
   @logo                       varchar(400)  = '',  
   @nm_cor_empresa             varchar(20)   = '',  
   @nm_endereco_empresa        varchar(200)  = '',  
   @cd_telefone_empresa        varchar(200)  = '',  
   @nm_email_internet          varchar(200)  = '',  
   @nm_cidade                  varchar(200)  = '',  
   @sg_estado                  varchar(10)   = '',  
   @nm_fantasia_empresa        varchar(200)  = '',  
   @cd_cep_empresa             varchar(20)   = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @nm_pais                    varchar(20)   = '',  
   @cd_cnpj_empresa            varchar(60)   = '',  
   @cd_inscestadual_empresa    varchar(100)  = '',   
   @nm_dominio_internet        varchar(200)  = '',   
   @titulo                     varchar(200)  = '',  
   @nm_caminho                 nvarchar(150) = '',  
   @nm_caminho_gerado          nvarchar(150) = '',  
   @cd_pedido_100              int           = 0,  
   @cd_modelo                  int           = 0  
---------------------------------------------------------------------------------------  
  
set @dt_impresso       = cast(replace(convert(char,getdate(),103),'.','-') as varchar(30))                                    
set @cd_empresa        = dbo.fn_empresa()                            
set @nm_caminho        = 'C:\GBS-EGIS\PedidoVenda\'                            
set @nm_caminho_gerado = 'C:\GBS-EGIS\PedidoVenda\Geradas\'                            
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)                            
set @parcelas          = ''                            
set @parcela           = ''                            
set @pvencto           = ''              
set @pvalor            = ''                            
set @pc_tpedido        = 0                            
set @ic_imposto        = 'S'          
set @cd_pedido_venda      = @cd_laudo  
--set @cd_empresa           = 0  
set @cd_item_pedido_venda = @cd_laudo  
set @pc_tpedido           = 0          
set @dt_impresso          = cast(replace(convert(char,getdate(),103),'.','-') as varchar(30))   
set @cd_laudo             = @cd_documento 
  
---------------------------------------------------------------------------------------  
  
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
  @cd_cep_empresa           = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),  
  @cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),  
  @nm_pais                  = ltrim(rtrim(isnull(p.sg_pais,''))),  
  @cd_cnpj_empresa   = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),  
  @cd_inscestadual_empresa =  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),  
  @nm_dominio_internet  =  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))  
    
 from egisadmin.dbo.empresa e with(nolock)  
 left outer join Estado es    with(nolock) on es.cd_estado = e.cd_estado  
 left outer join Cidade c     with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado  
 left outer join Pais p       with(nolock) on p.cd_pais = e.cd_pais  
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
      }
      table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
      }
      table,
      th,
      td {
         border: 1px solid #333;
      }
      th,
      td {
        padding: 5px;
        width: 30px;
        height: 30px;
        height: 55px;
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
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid #000;
        padding-bottom: 10px;
        margin-bottom: 10px;
      }
      .section-title {
        background-color: #1976d2;
        color: white;
        padding: 5px;
        margin-bottom: 10px;
        border-radius: 5px;
      }
      img {
        max-width: 350px;
        margin: 15px;
      }
      .title {
        color: #1976d2;
      }
      p {
        margin: 5px;
        padding: 0;
      }
      .container {
        max-width: 95%;
        margin: 0 auto;
        padding: 10px;
      }
      .center{
        text-align: center
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
                    <p class="title">'+isnull(@nm_fantasia_empresa,'')+'</p>  
                    <p><strong>'+isnull(@nm_endereco_empresa,'')+', '+isnull(@cd_numero_endereco_empresa,'') + ' - '+isnull(@cd_cep_empresa,'')+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>  
                    <p><strong>Fone:</strong>'+@cd_telefone_empresa+' -  <strong>CNPJ:</strong>' + @cd_cnpj_empresa + ' - <strong>I.E:</strong> ' + @cd_inscestadual_empresa + '</p>  
                    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>  
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
  egisadmin.dbo.Relatorio_Atributo a         with(nolock)  
  inner join egisadmin.dbo.relatorio_grupo g with(nolock) on g.cd_grupo_relatorio = a.cd_grupo_relatorio  
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

----------------------------------------------------------------------------------------------------------------------------------------
  select 
   IDENTITY(int, 1, 1) as cd_controle,   
  case when p.nm_produto is not null then p.nm_produto else l.nm_produto_especial_laudo end as nm_produto,
  l.qt_laudo,
  cast(case when isnull(l.cd_cliente,0)<>0 then c.nm_razao_social_cliente else f.nm_razao_social end as varchar) as nm_razao_social,
  l.cd_processo,
  ne.cd_nota_entrada,
  t.nm_transportadora,
  tt.nm_tipo_transporte,
  stl.nm_status_laudo,
  stl.sg_status_laudo,
  i.nm_inspetor,
  l.dt_laudo,
  getdate() as dt_hoje --@dt_hoje
  into 
  #CapaLaudo
From   
  Laudo l with(nolock)
  left outer join Laudo_Caracteristica lc with(nolock) on lc.cd_laudo = l.cd_laudo
  left outer join Origem_laudo ol         with(nolock) on (l.cd_origem_laudo = ol.cd_origem_laudo)
  left outer join Status_laudo stl        with(nolock) on (stl.cd_status_laudo = l.cd_status_laudo)
  left outer join Fornecedor f            with(nolock) on (l.cd_fornecedor = f.cd_fornecedor)
  left outer join Cliente c               with(nolock) on (l.cd_cliente    = c.cd_cliente )
  left outer join Produto p               with(nolock) on (l.cd_produto = p.cd_produto)
  left outer join Inspetor i              with(nolock) on i.cd_inspetor = l.cd_inspetor
  left outer join Nota_Entrada ne         with(nolock) on ne.cd_nota_entrada = l.cd_nota_entrada
  left outer join Transportadora t        with(nolock) on t.cd_transportadora = f.cd_transportadora
  left outer join Tipo_Transporte tt      with(nolock) on tt.cd_tipo_transporte = t.cd_tipo_transporte
 where
  l.cd_laudo = @cd_laudo--@cd_documento

  
----------------------------------------------------------------------------------------------------------------------------  
declare @nm_produto                   nvarchar(100)
declare @nm_razao_social              nvarchar(100)
declare @qt_laudo                     float = 0 
declare @cd_processo                  float = 0 
declare @nota_entrada                 int = 0 
declare @nm_status_laudo              nvarchar(50)
declare @sg_status_laudo              nvarchar(50)
declare @nm_inspetor                  nvarchar(50)
declare @dt_laudo                     datetime



select 
	@nm_produto                    = nm_produto,
	@nm_razao_social               = nm_razao_social,
	@qt_laudo					   = qt_laudo,				
	@cd_processo				   = @cd_processo,
	@nota_entrada                  = cd_nota_entrada,
	@nm_status_laudo			   = nm_status_laudo,					
	@sg_status_laudo			   = sg_status_laudo,
	@nm_inspetor                   = nm_inspetor, 
	@dt_laudo                      = dt_laudo
		
from #CapaLaudo

--select * from laudo 
--select @nm_inspetor

----------------------------------------------------------------------------------------------------------------------------
--Capa
  set @html_detalhe = '  
      <table>
        <tr>
          <td style="width: 20%; text-align: center;" >
            <h1>JST</H1>
          </td>
          <td class="center">
            <h1>PLANILHA DE CONTROLE DE RECEBIMENTO</h1>
          </td>
          <td style="width: 20%; text-align: center;">
            <h1>B05</H1>
          </td>
        </tr>

        <tr>
          <td colspan="3" class="center">JST COMERCIO DE CARNES LTDA</td>
        </tr>
        <tr>
          <td colspan="3" class="center">INFORMAÇÕES GERAIS</td>
        </tr>
        
      </table>
      <table>
        <tr >
          <td colspan="1"><strong>Data:</strong></td>
          <td colspan="2" ><strong>Hora:</strong></td>
        </tr>
        <tr class="center">
          <td colspan="3" ><strong>TIPO DE TRANSPORTE: <input type="checkbox"> <strong>Truck </strong><input type="checkbox"> <strong>Carreta</strong><input type="checkbox"> <strong>Van</strong></td>
        </tr>
        <tr>
          <td><strong>FORNECEDOR: </strong></td>
          <td><strong>NNF: </strong></td>
          <td><strong>SIF: </strong></td>
        </tr>
        <tr >
          <td colspan="1" class="center"><strong>AVALIAÇÃO DO VEÍCULO</strong></td>
          <td colspan="2" class="center"><strong>AVALIAÇÃO DAS EMBALAGENS SECUNDÁRIAS (CAIXAS)</strong></td>
        </tr>
        <tr class="center">
          <td colspan="1"><input type="checkbox"> <strong>C</strong> <input type="checkbox"> <strong>NC</strong>
          <td colspan="2"><input type="checkbox"> <strong>C</strong> <input type="checkbox"> <strong>NC</strong>
        </tr>
        <tr>
          <td colspan="3" class="center"><strong>INFORMAÇÕES SOBRE O PRODUTO RECEBIDOS</strong></td>
        </tr>
        <tr>
          <td colspan="3" class="center"><strong>ANÁLISE DE PRODUTOS</strong></td>
        </tr>
      </table>
      <table>  
        <thead>  
            <tr>  
                <th>PRODUTO CORTE</th>  
                <th>DATA DE PRODUÇÃO/VALIDADE</th>  
                <th>SIF/SISBI DO PRODUTO</th>  
                <th>LOTE</th>  
                <th>TEMPERATURA (°C)</th> 
                <th>VÁCUO</th> 
                <th>EMBALAGEM PRIMÁRIA</th> 
            </tr>  
        </thead>'

---------------------------------------------------------------------------------------------------------------------------------
--Items
  select 
   IDENTITY(int, 1, 1) as cd_controle,   
  case when p.nm_produto is not null then p.nm_produto else l.nm_produto_especial_laudo end as nm_produto, --select cd_produto,* from Processo_Producao
  pp.dt_processo,
  '' as cd_sif,
  pp.cd_lote_produto_processo as cd_lote,
  '0' as cd_temperatura,
  'C' as ic_vacuo,
  'C' as ic_embalagem_primaria
  into 
  #ItemsLaudo
From   
  Laudo l with(nolock)
  left outer join Laudo_Caracteristica lc with(nolock) on lc.cd_laudo = l.cd_laudo
  left outer join Origem_laudo ol         with(nolock) on (l.cd_origem_laudo = ol.cd_origem_laudo)
  left outer join Status_laudo stl        with(nolock) on (stl.cd_status_laudo = l.cd_status_laudo)
  left outer join Fornecedor f            with(nolock) on (l.cd_fornecedor = f.cd_fornecedor)
  left outer join Cliente c               with(nolock) on (l.cd_cliente    = c.cd_cliente )
  left outer join Produto p               with(nolock) on (l.cd_produto = p.cd_produto)
  left outer join Processo_Producao pp    with(nolock) on pp.cd_produto = p.cd_produto
  left outer join Inspetor i              with(nolock) on i.cd_inspetor = l.cd_inspetor
  left outer join Nota_Entrada ne         with(nolock) on ne.cd_nota_entrada = l.cd_nota_entrada
  left outer join Nota_Entrada_Item nei   with(nolock) on ne.cd_nota_entrada = nei.cd_nota_entrada
  left outer join Transportadora t        with(nolock) on t.cd_transportadora = f.cd_transportadora
  left outer join Tipo_Transporte tt      with(nolock) on tt.cd_tipo_transporte = t.cd_tipo_transporte
 where
  l.cd_laudo = @cd_laudo--@cd_documento

declare @id                    int = 0
declare @nm_produto_item       nvarchar(500) = ''
declare @dt_producao           datetime
declare @cd_sif                nvarchar(10) = ''
declare @cd_lote               nvarchar(20) = ''
declare @cd_temperatura        float = 0
declare @ic_vacuo              char(1) = 'C'
declare @ic_embalagem_primaria char(1) = 'C'

while exists ( select top 1 cd_controle from #ItemsLaudo )
 begin

  select top 1
  @id                    = cd_controle,
  @nm_produto_item       = nm_produto,
  @dt_producao           = dt_processo,
  @cd_sif                = cd_sif,
  @cd_lote               = cd_lote,
  @cd_temperatura        = cd_temperatura,
  @ic_vacuo		         = ic_vacuo,
  @ic_embalagem_primaria = ic_embalagem_primaria
  from  #ItemsLaudo

  set @html_detalhe_1 = @html_detalhe_1 + '
           <tbody>
                <tr>
                    <td>'+isnull(@nm_produto_item,'')+'</td>
                    <td>'+isnull(@dt_producao,'')+'</td>
                    <td>'+isnull(@cd_sif,'')+'</td>
                    <td>'+isnull(@cd_lote,'')+'</td>
					<td>'+isnull(@cd_temperatura,'')+'</td>
					<td>'+isnull(@ic_vacuo,'')+'</td>
					<td>'+isnull(@ic_embalagem_primaria,'')+'</td>
                </tr>
            </tbody>
 '

delete from #ItemsLaudo where cd_controle = @id

end
--------------------------------------------------------------------------------------------------------------------------------------------------
--Rodapé
  set  @html_rodape = @html_rodape +'  
 <table>
        <tr>
          <td colspan="2"><strong>Observações: </strong></td>
        </tr>
        <tr>
          <td style="width: 50%;">
            <strong>PADRÕES DE TEMPERATURA</strong>
            <div style="display: flex; flex-direction: column; gap: 5px;">
              <span>Carne Congelada: -12°C ou mais frio.</span>
              <span>Carne Congelada: -12°C ou mais frio.</span>
            </div>
          </td>
          <td style="width: 50%;">
            <strong>LEGENDA</strong>
            <div style="display: flex; flex-direction: column; gap: 5px;">
              <span>NNF: Número da Nota Fiscal</span>
              <span>C: Conforme / NC: Não Conforme</span>
            </div>
          </td>
        </tr>
        <tr>
          <td colspan="2"><strong>TOTAL DE CAIXAS RECEBIDAS: </strong></td>
        </tr>
        <tr>
          <td colspan="2"><strong>PESO LÍQUIDO TOTAL RECEBIDO:</strong></td>
        </tr>
        <tr>
          <td colspan="2" class="center"><strong>PROCEDIMENTOS/FREQUÊNCIA: a cada recebimento atentar para os itens relacionados a qualidade do produto e meios de transporte.Ao recebimento realizar amostragem de produtos localizados em pontos do início, meio e final da carga.</strong></td>
        </tr>
        <tr>
          <td class="center" ><strong> ____________________________ </strong><br>Inspetor de Qualidade.</br></td>
          <td class="center"><strong> ____________________________ </strong><br>Responsável Técnico.</br></td>
        </tr>
        </tr>
      </table>
    </div>
  </body>
</html>
 '  


  
set @html         =   
    @html_empresa   +  
    @html_titulo    +  
    @html_detalhe   +  
    @html_detalhe_1 +  
    @html_geral     +   
    @html_totais    +  
    @html_grafico   +  
    @html_rodape    
  
--select @html, @html_empresa, @html_titulo, @html_cab_det, @html_rod_det, @html_totais, @html_grafico, @html_rodape  
  
-------------------------------------------------------------------------------------------------------  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
go  
exec pr_relatorio_certificado_qualidade_nota_fiscal 209,4253,0,10444,''