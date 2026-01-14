IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_dados_pedido_venda_guarufilme' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_dados_pedido_venda_guarufilme

go
-----------------------------------------------------------------------------------
create procedure pr_egis_relatorio_dados_pedido_venda_guarufilme
@cd_relatorio int   = 0,
@cd_usuario   int   = 0,
@cd_parametro int   = 0,
@cd_documento int   = 0,

@json nvarchar(max) = '' 

as 
 
 set @json = isnull(@json,'')
 declare @cd_empresa			  int = 0

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
 declare @nm_destinacao           nvarchar(30)
 --------------------------------------------------------------------------------------

 declare @nm_tel                      NVARCHAR(50)
 declare @grupo                       nvarchar(30)
 declare @nm_cliente                  nvarchar(400)
 declare @nm_fantasia				  nvarchar(200)
 declare @nm_endereco_cliente_cli     nvarchar(400)
 declare @nm_numero_endereco_cli      int = 0
 declare @nm_bairro_cli               nvarchar(200)
 declare @nm_cidade_cli				  nvarchar(100)
 declare @cep_cli                     nvarchar(30)
 declare @cnpj					      nvarchar(30)
 declare @insc_estadual			      nvarchar(30)
 declare @nm_tel_fax			      nvarchar(50)
 declare @suframa                     nvarchar(50)
 declare @nm_endereco_cliente_etg     nvarchar(200)
 declare @nm_numero_endereco_etg      nvarchar(15)
 declare @nm_bairro_etg               nvarchar(200)
 declare @nm_cidade_etg               nvarchar(50)
 declare @cep_etg                     nvarchar(30)
 declare @nm_transport                nvarchar(300)
 declare @tipo_frete                  nvarchar(30)
 declare @ds_observacao               nvarchar(200)
 declare @coleta                      nvarchar(100)
 declare @ordem_compra                nvarchar(100)
 declare @condicao_pagamento          nvarchar(100)
 declare @tp_pagamento                nvarchar(100)
 declare @vendedor                    nvarchar(100)
 declare @faturado                    nvarchar(150)
 declare @itens                       int =0
 declare @ds_produto                  nvarchar(200)
 declare @ds_medidas				  nvarchar(200)
 declare @qt_produto				  float = 0
 declare @unidade_medida			  nvarchar(50)
 declare @qt_peso_liq				  float = 0
 declare @qt_peso_bruto               float = 0 
 declare @pc_ipi					  float = 0
 declare @vl_unitario         	      float = 0 
 declare @vl_total					  float = 0
 declare @ft_kg						  nvarchar(50)




-----------------------------Dados do Relatório----------------------------------------

	declare
		    @cd_pedido_venda             int = 0,
            @tp_pedido_venda            nvarchar(10),
			@dt_emissao                 nvarchar(50),
			@logo                       varchar(400),
			@nm_cor_empresa             varchar(20),
			@nm_endereco_empresa  	    varchar(200) = '',
			@cd_telefone_empresa    	varchar(200) = '',
			@nm_email_internet		    varchar(200) = '',
			@nm_cidade				    varchar(200) = '',
			@sg_estado				    varchar(10)	 = '',
			@nm_fantasia_empresa	    varchar(200) = '',
			@cd_cep_empresa			    varchar(20) = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',	
			@nm_dominio_internet		varchar(200) = '',	
			@titulo                     varchar(200),
			@nm_caminho                 nvarchar(150),
			@nm_caminho_gerado          nvarchar(150),
			@cd_pedido_100              int=0,
			@cd_modelo                  int   = 0
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
set @cd_pedido_venda      = @cd_documento
--set @cd_empresa           = 0
set @cd_item_pedido_venda = @cd_documento
set @pc_tpedido           = 0        
set @dt_impresso       = cast(replace(convert(char,getdate(),103),'.','-') as varchar(30)) 


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

----------------------------------------------------------------------------------------
 select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'


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

 --SELECT * FROM  egisadmin.dbo.Relatorio
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
		@logo                       = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),
		@nm_cor_empresa		   	    = isnull(e.nm_cor_empresa,'#1976D2'),
		@nm_endereco_empresa 	    = isnull(e.nm_endereco_empresa,''),
		@cd_telefone_empresa	    = isnull(e.cd_telefone_empresa,''),
		@nm_email_internet	  	    = isnull(e.nm_email_internet,''),
		@nm_cidade			    	= isnull(c.nm_cidade,''),
		@sg_estado				    = isnull(es.sg_estado,''),
		@nm_fantasia_empresa	    = isnull(e.nm_fantasia_empresa,''),
		@cd_cep_empresa			    = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),
		@cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),
		@nm_pais					= ltrim(rtrim(isnull(p.sg_pais,''))),
		@cd_cnpj_empresa			= dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),
		@cd_inscestadual_empresa	=  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),
		@nm_dominio_internet		=  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))
		
	from egisadmin.dbo.empresa e	with(nolock)
	left outer join Estado es		with(nolock) on es.cd_estado = e.cd_estado
	left outer join Cidade c		with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado
	left outer join Pais p			with(nolock) on p.cd_pais = e.cd_pais
	where 
		cd_empresa = @cd_empresa
---------------------------------------------------------------------------------------------------------------------
select
	@dt_emissao                 = CONVERT(VARCHAR(12),pv.dt_pedido_venda, 103)
	--@cd_pedido_venda            = cd_pedido_venda
from pedido_venda pv
---------------------------------------------------------------------------------------------------------------------
select 

	@tp_pedido_venda            = tp.sg_tipo_pedido
		
from tipo_pedido tp
---------------------------------------------------------------------------------------------------------------------
SELECT 
	@nm_destinacao            = nm_destinacao_produto

FROM destinacao_produto
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
                    <img src="'+@logo+'" alt="Logo da Empresa">
                </td>
                <td style="width: 60%; text-align: left;">
                    <p class="title">'+@nm_fantasia_empresa+'</p>
                    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
                    <p><strong>Fone:</strong>'+@cd_telefone_empresa+' -  <strong>CNPJ:</strong>' + @cd_cnpj_empresa + ' - <strong>I.E:</strong> ' + @cd_inscestadual_empresa + '</p>
                    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
                </td>
                <td style="width: 20%; text-align: center;">
                    <p><strong>Pedido: '+cast(isnull(@cd_pedido_venda,0) as varchar (30))+'</strong></p>
                    <p>Tipo: '+isnull(@nm_destinacao,'')+'</p>
                    <p>MAQ: '+isnull(@tp_pedido_venda,'') +'</p>
                    <p>Data: '+ CONVERT(VARCHAR(10), ISNULL(@dt_emissao, ''), 103) + '</p>
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

--SELECT @nm_dados_cab_det

drop table #AuxRelAtributo

declare @vl_valor_total          decimal(25,2) = 0.00
declare @qt_total                int = 0

--------------------------------Select HTML-----------------------------------------------------------
 
select @ic_desconto = ic_desconto_pedido from parametro_pedido_venda where cd_empresa = @cd_empresa                          
                          
select                         
  @casadec    = isnull(m.qt_num_digitos,4),                          
  @pc_tpedido = (isnull(tp.pc_montagem_pedido,0)/100),                          
  @ic_imposto = isnull(tp.ic_imposto_tipo_pedido,'N')                          
from                          
  moeda m                          
  left outer join pedido_venda pv on pv.cd_moeda       = m.cd_moeda                          
  left outer join Tipo_Pedido tp  on tp.cd_tipo_pedido = pv.cd_tipo_pedido                          
where                          
  cd_pedido_venda = @cd_pedido_venda                          

declare @ic_conversao_faturamento char(1)
select @ic_conversao_faturamento = isnull(ic_conversao_faturamento,'N') from parametro_comercial where cd_empresa = @cd_empresa
                          
                 
/*                          
  1. Criar variavel do ic_desconto                           
  2. Carregar a variavel com o parametro q vem parametro_pedido_venda (parametro: ic_desconto_pedido / vl_digitado_item_desconto)                          
  3. Usar o case para o valor unitario se case when @ic_desconto = S and vl_digitado_item_desconto > 0                      
*/                          
                          
                          
                          
/************************                          
  Itens do Pedido Venda                          
************************/                          
if @ic_cancelados = 'S'                  
begin
select                           
 pi.cd_pedido_venda,                          
 pi.cd_item_pedido_venda                           as ITEM,                          
 isnull(p.nm_fantasia_produto,'')                  as FANTASIA_PRODUTO,                          
 isnull(p.cd_mascara_produto,'')                   as CODIGO_PRODUTO,                          
 isnull(p.nm_produto,'')                           as DESCRICAO_PRODUTO,                          
 isnull(u.sg_unidade_medida,'')                    as UN,                          
 isnull(pi.dt_entrega_vendas_pedido,'')            as DT_PRAZO_ENTREGA,   
 isnull(convert(varchar,pi.dt_entrega_fabrica_pedido,103),'')   as DT_FABRICA,  
 case when isnull(@ic_conversao_faturamento,'N') = 'S' then
   dbo.fn_conversao_produto_unidade_medida(pi.cd_produto, pi.cd_unidade_medida, isnull(pi.qt_item_pedido_venda,0), 0)
 else
   isnull(pi.qt_item_pedido_venda,0)                 
 end                                               as QTDE,        
 isnull(pi.qt_saldo_pedido_venda,0)                as QTDE_SALDO,        
 isnull(p.qt_multiplo_embalagem,0)                 as QTDE_EMB,                          
 isnull(emb.qt_unidade_tipo_embalagem,0)           as QTDE_EMB_UNIT,        
   
 isnull(pi.qt_item_pedido_venda,0) *  
 isnull(pi.vl_unitario_item_pedido,0)              as VL_TOTAL_PRODUTOS,    
                          
 case when @ic_desconto = 'S' and pi.vl_digitado_item_desconto > 0 then                           
 round(isnull(pi.vl_digitado_item_desconto,0),@casadec)                          
    else round(isnull(pi.vl_unitario_item_pedido,0),@casadec) end         as VL_UNITARIO,                          
                          
 cast(                          
 case when @ic_desconto = 'S' and pi.vl_digitado_item_desconto > 0 then                           
    case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                          
       isnull(pi.vl_digitado_item_desconto,0) * @pc_tpedido                          
    else                           
       isnull(pi.vl_digitado_item_desconto,0)                          
    end                          
    else                           
    case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                          
       isnull(pi.vl_unitario_item_pedido,0) * @pc_tpedido                  
    else                             
       isnull(pi.vl_unitario_item_pedido,0)                          
    end                          
 end as numeric(8,4))                                                                     as VL_UNITARIOG,                          
                          
 case when pi.vl_digitado_item_desconto <> 0 then                          
      (round((isnull(pi.vl_unitario_item_pedido,0)),25,@casadec)               
 + (round((isnull(pi.vl_digitado_item_desconto,0)) -                          
      (isnull(pi.vl_unitario_item_pedido,0)),25,@casadec)))                          
   else                           
      round(isnull(pi.vl_unitario_item_pedido,0),@casadec)                           
   end                                                                      as VL_UNITARIO_S_DESC,                          
                          
 --round(isnull(pi.vl_digitado_item_desconto,0),2)         as VL_UNITARIO_S_DESC,                        
                          
 round(case when @ic_desconto = 'S' and pi.vl_digitado_item_desconto > 0 then                           
 round(isnull(pi.vl_digitado_item_desconto,0),@casadec)                          
  else round(isnull(pi.vl_unitario_item_pedido,0),@casadec)end                          
  * isnull(pi.qt_item_pedido_venda,0),@casadec)            as VL_TOTAL,     
      
  case when @ic_desconto = 'S' and pi.vl_digitado_item_desconto > 0 then                           
     case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                
     round(isnull(pi.vl_digitado_item_desconto,0) * @pc_tpedido,@casadec)                          
  else                          
     round(isnull(pi.vl_digitado_item_desconto,0), @casadec)                          
  end                          
  else                          
     case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                           
     round(isnull(pi.vl_unitario_item_pedido,0) * @pc_tpedido, @casadec)                          
  else                           
     round(isnull(pi.vl_unitario_item_pedido,0), @casadec)                          
  end                          
  end                          
    *  isnull(pi.qt_saldo_pedido_venda,0)                         as VL_TOTAL_SALDO,    
    
                          
  case when @ic_desconto = 'S' and pi.vl_digitado_item_desconto > 0 then                           
     case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                
     round(isnull(pi.vl_digitado_item_desconto,0) * @pc_tpedido,@casadec)                          
  else                          
     round(isnull(pi.vl_digitado_item_desconto,0), @casadec)                          
  end                          
  else                          
     case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                           
     round(isnull(pi.vl_unitario_item_pedido,0) * @pc_tpedido, @casadec)                          
  else                           
     round(isnull(pi.vl_unitario_item_pedido,0), @casadec)                          
  end                          
  end                          
    *  isnull(pi.qt_item_pedido_venda,0)                        as VL_TOTALG,                          
                          
                          
 (case when pi.vl_digitado_item_desconto <> 0 then                          
 (round((isnull(pi.vl_unitario_item_pedido,0)),25,@casadec)                           
 + (round((isnull(pi.vl_digitado_item_desconto,0)) -                          
 (isnull(pi.vl_unitario_item_pedido,0)),25,@casadec)))                          
  else round(isnull(pi.vl_unitario_item_pedido,0),@casadec) end)                          
 * isnull(pi.qt_item_pedido_venda,0)                     as VL_TOTAL_S_DESC,                          
                          
                          
--  round(isnull(pi.vl_digitado_item_desconto,0),2)        
--  * isnull(pi.qt_item_pedido_venda,0)                     as VL_TOTAL_S_DESC,                          
                          
                          
  round(                          
  (isnull(pi.vl_unitario_item_pedido,0)                          
  * isnull(pi.qt_item_pedido_venda,0)) * (pi.pc_desconto_item_pedido/100)                          
  ,@casadec)                                             as VL_DESCONTO_ITEM,                          
 isnull(pi.pc_ipi,0)                                     as PC_IPI,    
 isnull(pi.vl_unitario_ipi_produto,0)                    as VL_IPI_UNIT,                          
 isnull(pi.pc_icms,0)                                    as PC_ICMS,                          
 isnull(pi.vl_item_icms_st,0)                            as VL_ICMS_UNIT,                          
 isnull(cf.cd_mascara_classificacao,'')                  as NCM,                          
 isnull(pi.pc_desconto_item_pedido,0)                    as PC_DESCONTO,                          
    isnull(fp.nm_fase_produto,'')                        as FASE,                          
 isnull(fpp.nm_fase_produto,'')                          as FASE_PEDIDO,                          
    isnull(cast(p.ds_produto as varchar(2000)),'')       as DESC_PRODUTO,                          
                          
  case when isnull(rci.cd_requisicao_compra,0) = 0                           
    then 'N' else 'S' end           as RC,                          
                          
  --case when isnull(fam.ic_espessura_proposta,'N') = 'N' then                            
  --   cast(isnull(pvim.qt_largura,0)as varchar(10)) +                          
  --   case when (isnull(fam.ic_comprimento,'N')= 'N' or isnull(pvim.qt_comprimento,0)=0) then                          
  --      ' x ' + cast(isnull(pvim.qt_comprimento,0)as varchar(10))                         
  --   else                          
  --     ''                          
  --   end                          
  --else                          
     cast(isnull(pvim.qt_largura,0) as varchar(10)) +' x '+                          
     cast(isnull(pvim.qt_espessura,0)as varchar(10)) +                          
     case when (isnull(fam.ic_comprimento,'N')= 'N' or isnull(pvim.qt_comprimento,0)=0) then                          
      ' x ' + cast(isnull(pvim.qt_comprimento,0)as varchar(10))                          
     else                          
      ''                          
     --end                          
 end                                                                           as MEDIDAS,                          
                          
 isnull(pvim.qt_peso_bruto_total,isnull(cim.qt_peso_bruto_total,0))            as PBruto,                 
 isnull(pvim.qt_peso_liquido_total,isnull(cim.qt_peso_liquido_total,0))        as PLiq,                          
 isnull(pvim.vl_peso_preco,isnull(cim.vl_peso_preco,0))                        as FTKG,          
 case when isnull(pvim.qt_volume_produzida,0) = 0
   then isnull(pvim.qt_volume,isnull(cim.qt_volume,0))
   else qt_volume_produzida
 end                                                                           as QVolumes                          
                          
into                           
 #ItensC                          
from                           
 pedido_venda_item pi                          with(nolock)                          
 left outer join produto p                     with(nolock) on p.cd_produto               = pi.cd_produto                          
 left outer join produto_fiscal pf             with(nolock) on pf.cd_produto              = p.cd_produto                          
 left outer join unidade_medida u              with(nolock) on u.cd_unidade_medida        = pi.cd_unidade_medida                          
 left outer join classificacao_fiscal cf       with(nolock) on cf.cd_classificacao_fiscal = pf.cd_classificacao_fiscal                          
 left outer join fase_produto  fp              with(nolock) on fp.cd_fase_produto         = p.cd_fase_produto_baixa                          
 left outer join fase_produto  fpp    with(nolock) on fpp.cd_fase_produto        = pi.cd_fase_produto                          
 left outer join consulta_itens ci             with(nolock) on ci.cd_pedido_venda         = pi.cd_pedido_venda and                           
                                                               ci.cd_item_pedido_venda    = pi.cd_item_pedido_venda                          
 left outer join requisicao_compra_item rci  with(nolock) on rci.cd_consulta            = ci.cd_consulta and                           
                                                               rci.cd_item_consulta       = ci.cd_item_consulta                          
 left outer join tipo_embalagem emb           with(nolock) on emb.cd_tipo_embalagem       = p.cd_tipo_embalagem                          
 left outer join pedido_venda_item_medida pvim with(nolock) on pvim.cd_pedido_venda       = pi.cd_pedido_venda and                           
                                                               pvim.cd_item_pedido_venda  = pi.cd_item_pedido_venda                          
 left outer join consulta_itens_medida cim     with(nolock) on cim.cd_consulta            = pi.cd_consulta and                          
                                                               cim.cd_item_consulta       = pi.cd_item_consulta                          
 left outer join familia_produto fam  with(nolock) on fam.cd_familia_produto     = p.cd_familia_produto                         
 --and cim.cd_item_consulta       = pi.cd_item_consulta                            
where                          
  pi.cd_pedido_venda = @cd_pedido_venda                          
  and                          
  isnull(pi.qt_saldo_pedido_venda,0) = case when @ic_nao_faturado = 'S' then 0 else isnull(pi.qt_saldo_pedido_venda,0) end
end
else
begin
select    
	identity(int,1,1) as cd_controle,

 pi.cd_pedido_venda,                          
 pi.cd_item_pedido_venda                           as ITEM,                          
 isnull(p.nm_fantasia_produto,'')                  as FANTASIA_PRODUTO,                          
 isnull(p.cd_mascara_produto,'')                   as CODIGO_PRODUTO,                          
 isnull(p.nm_produto,'')                           as DESCRICAO_PRODUTO,                          
 isnull(u.sg_unidade_medida,'')                    as UN,                          
 isnull(pi.dt_entrega_vendas_pedido,'')            as DT_PRAZO_ENTREGA,   
 isnull(convert(varchar,pi.dt_entrega_fabrica_pedido,103),'')   as DT_FABRICA,  

 case when isnull(@ic_conversao_faturamento,'N') = 'S' then
   dbo.fn_conversao_produto_unidade_medida(pi.cd_produto, pi.cd_unidade_medida, isnull(pi.qt_item_pedido_venda,0), 0)
 else
   isnull(pi.qt_item_pedido_venda,0)                 
 end                                               as QTDE,        
 isnull(pi.qt_saldo_pedido_venda,0)                as QTDE_SALDO,        
 isnull(p.qt_multiplo_embalagem,0)                 as QTDE_EMB,                          
 isnull(emb.qt_unidade_tipo_embalagem,0)           as QTDE_EMB_UNIT,        
   
 isnull(pi.qt_item_pedido_venda,0) *  
 isnull(pi.vl_unitario_item_pedido,0)              as VL_TOTAL_PRODUTOS,    
                          
 case when @ic_desconto = 'S' and pi.vl_digitado_item_desconto > 0 then                           
 round(isnull(pi.vl_digitado_item_desconto,0),@casadec)                          
    else round(isnull(pi.vl_unitario_item_pedido,0),@casadec) end         as VL_UNITARIO,                          
                          
 cast(                          
 case when @ic_desconto = 'S' and pi.vl_digitado_item_desconto > 0 then                           
    case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                          
       isnull(pi.vl_digitado_item_desconto,0) * @pc_tpedido                          
    else                           
       isnull(pi.vl_digitado_item_desconto,0)                          
    end                          
    else                           
    case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                          
       isnull(pi.vl_unitario_item_pedido,0) * @pc_tpedido                  
    else                             
       isnull(pi.vl_unitario_item_pedido,0)                          
    end                          
 end as numeric(8,4))                                                                     as VL_UNITARIOG,                          
                          
 case when pi.vl_digitado_item_desconto <> 0 then                          
      (round((isnull(pi.vl_unitario_item_pedido,0)),25,@casadec)               
 + (round((isnull(pi.vl_digitado_item_desconto,0)) -                          
      (isnull(pi.vl_unitario_item_pedido,0)),25,@casadec)))                          
   else                           
      round(isnull(pi.vl_unitario_item_pedido,0),@casadec)                           
   end                                                                      as VL_UNITARIO_S_DESC,                          
                          
 --round(isnull(pi.vl_digitado_item_desconto,0),2)         as VL_UNITARIO_S_DESC,                        
                          
 round(case when @ic_desconto = 'S' and pi.vl_digitado_item_desconto > 0 then                           
 round(isnull(pi.vl_digitado_item_desconto,0),@casadec)                          
  else round(isnull(pi.vl_unitario_item_pedido,0),@casadec)end                          
  * isnull(pi.qt_item_pedido_venda,0),@casadec)            as VL_TOTAL,     
      
  case when @ic_desconto = 'S' and pi.vl_digitado_item_desconto > 0 then                           
     case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                
     round(isnull(pi.vl_digitado_item_desconto,0) * @pc_tpedido,@casadec)                          
  else                          
     round(isnull(pi.vl_digitado_item_desconto,0), @casadec)                          
  end                          
  else                          
     case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                           
     round(isnull(pi.vl_unitario_item_pedido,0) * @pc_tpedido, @casadec)                          
  else                           
     round(isnull(pi.vl_unitario_item_pedido,0), @casadec)                          
  end                          
  end                          
    *  isnull(pi.qt_saldo_pedido_venda,0)                         as VL_TOTAL_SALDO,    
    
                          
  case when @ic_desconto = 'S' and pi.vl_digitado_item_desconto > 0 then                           
     case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                
     round(isnull(pi.vl_digitado_item_desconto,0) * @pc_tpedido,@casadec)                          
  else                          
     round(isnull(pi.vl_digitado_item_desconto,0), @casadec)                          
  end                          
  else                          
     case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                           
     round(isnull(pi.vl_unitario_item_pedido,0) * @pc_tpedido, @casadec)                          
  else                           
     round(isnull(pi.vl_unitario_item_pedido,0), @casadec)                          
  end                          
  end                          
    *  isnull(pi.qt_item_pedido_venda,0)                        as VL_TOTALG,                          
                          
                          
 (case when pi.vl_digitado_item_desconto <> 0 then                          
 (round((isnull(pi.vl_unitario_item_pedido,0)),25,@casadec)                           
 + (round((isnull(pi.vl_digitado_item_desconto,0)) -                          
 (isnull(pi.vl_unitario_item_pedido,0)),25,@casadec)))                          
  else round(isnull(pi.vl_unitario_item_pedido,0),@casadec) end)                          
 * isnull(pi.qt_item_pedido_venda,0)                     as VL_TOTAL_S_DESC,                          
                          
                          
--  round(isnull(pi.vl_digitado_item_desconto,0),2)        
--  * isnull(pi.qt_item_pedido_venda,0)                     as VL_TOTAL_S_DESC,                          
                          
                          
  round(                          
  (isnull(pi.vl_unitario_item_pedido,0)                          
  * isnull(pi.qt_item_pedido_venda,0)) * (pi.pc_desconto_item_pedido/100)                          
  ,@casadec)                                             as VL_DESCONTO_ITEM,                          
 isnull(pi.pc_ipi,0)                                     as PC_IPI,    
 isnull(pi.vl_unitario_ipi_produto,0)                    as VL_IPI_UNIT,                          
 isnull(pi.pc_icms,0)                                    as PC_ICMS,                          
 isnull(pi.vl_item_icms_st,0)                            as VL_ICMS_UNIT,                          
 isnull(cf.cd_mascara_classificacao,'')                  as NCM,                          
 isnull(pi.pc_desconto_item_pedido,0)                    as PC_DESCONTO,                          
    isnull(fp.nm_fase_produto,'')                        as FASE,                          
 isnull(fpp.nm_fase_produto,'')                          as FASE_PEDIDO,                          
    isnull(cast(p.ds_produto as varchar(2000)),'')       as DESC_PRODUTO,                          
                          
  case when isnull(rci.cd_requisicao_compra,0) = 0                           
    then 'N' else 'S' end           as RC,                          
                          
  --case when isnull(fam.ic_espessura_proposta,'N') = 'N' then                            
  --   cast(isnull(pvim.qt_largura,0)as varchar(10)) +                          
  --   case when (isnull(fam.ic_comprimento,'N')= 'N' or isnull(pvim.qt_comprimento,0)=0) then                          
  --      ' x ' + cast(isnull(pvim.qt_comprimento,0)as varchar(10))                         
  --   else                          
  --     ''                          
  --   end                          
  --else                          
     cast(isnull(pvim.qt_largura,0) as varchar(10)) +' x '+                          
     cast(isnull(pvim.qt_espessura,0)as varchar(10)) +                          
     case when (isnull(fam.ic_comprimento,'N')= 'N' or isnull(pvim.qt_comprimento,0)=0) then                          
      ' x ' + cast(isnull(pvim.qt_comprimento,0)as varchar(10))                          
     else                          
      ''                          
     --end                          
 end                                                                           as MEDIDAS,                          
                          
 isnull(pvim.qt_peso_bruto_total,isnull(cim.qt_peso_bruto_total,0))            as PBruto,                 
 isnull(pvim.qt_peso_liquido_total,isnull(cim.qt_peso_liquido_total,0))        as PLiq,                          
 isnull(pvim.vl_peso_preco,isnull(cim.vl_peso_preco,0))                        as FTKG,          
 case when isnull(pvim.qt_volume_produzida,0) = 0
   then isnull(pvim.qt_volume,isnull(cim.qt_volume,0))
   else qt_volume_produzida
 end                                                                           as QVolumes                          
                          
into                           
 #Itens                           
from                           
 pedido_venda_item pi                          with(nolock)                          
 left outer join produto p                     with(nolock) on p.cd_produto               = pi.cd_produto                          
 left outer join produto_fiscal pf             with(nolock) on pf.cd_produto              = p.cd_produto                          
 left outer join unidade_medida u              with(nolock) on u.cd_unidade_medida        = pi.cd_unidade_medida                          
 left outer join classificacao_fiscal cf       with(nolock) on cf.cd_classificacao_fiscal = pf.cd_classificacao_fiscal                          
 left outer join fase_produto  fp              with(nolock) on fp.cd_fase_produto         = p.cd_fase_produto_baixa                          
 left outer join fase_produto  fpp    with(nolock) on fpp.cd_fase_produto        = pi.cd_fase_produto                          
 left outer join consulta_itens ci             with(nolock) on ci.cd_pedido_venda         = pi.cd_pedido_venda and                           
                                                               ci.cd_item_pedido_venda    = pi.cd_item_pedido_venda                          
 left outer join requisicao_compra_item rci  with(nolock) on rci.cd_consulta            = ci.cd_consulta and                           
                                                               rci.cd_item_consulta       = ci.cd_item_consulta                          
 left outer join tipo_embalagem emb           with(nolock) on emb.cd_tipo_embalagem       = p.cd_tipo_embalagem                          
 left outer join pedido_venda_item_medida pvim with(nolock) on pvim.cd_pedido_venda       = pi.cd_pedido_venda and                           
                                                               pvim.cd_item_pedido_venda  = pi.cd_item_pedido_venda                          
 left outer join consulta_itens_medida cim     with(nolock) on cim.cd_consulta            = pi.cd_consulta and                          
                                                               cim.cd_item_consulta       = pi.cd_item_consulta                          
 left outer join familia_produto fam  with(nolock) on fam.cd_familia_produto     = p.cd_familia_produto                         
 --and cim.cd_item_consulta       = pi.cd_item_consulta                            
where                          
  pi.cd_pedido_venda = @cd_pedido_venda                          
  and                          
  isnull(pi.qt_saldo_pedido_venda,0) = case when @ic_nao_faturado = 'S' then 0 else isnull(pi.qt_saldo_pedido_venda,0) end                          
  and                          
  pi.dt_cancelamento_item is null   
  
end                          
                          
/********************                          
 Totais dos Itens               
********************/     
create table #TotalItens(
  cd_pedido_venda int,                          
  pc_ipi float,    
  ValorTotal float,    
  ValorTotalSaldo float,     
  ValTotSDesc float,                          
  QtdeTotal float,  
  Total_itens int,  
  QtdeTotalEmb float,                          
  ValorDescontoItem float,            
  VL_IPI_UNIT float,          
  PbrutoTot float,          
  PLiqTot float,          
  QVolumes int,  
  vl_total_produtos float)

if @ic_cancelados = 'S'
begin
insert into #TotalItens
select                           
 cd_pedido_venda,                          
 sum(isnull(pc_ipi,0))             as pc_ipi,    
 sum(isnull(VL_TOTAL,0))           as ValorTotal,    
 sum(isnull(VL_TOTAL_SALDO,0))     as ValorTotalSaldo,     
 sum(isnull(VL_TOTAL_S_DESC,0))    as ValTotSDesc,                          
 sum(isnull(QTDE,0))               as QtdeTotal,  
 COUNT(ISNULL(QTDE,0))      as Total_itens,  
 sum(isnull(QTDE_EMB_UNIT,0))      as QtdeTotalEmb,                          
 sum(isnull(VL_DESCONTO_ITEM,0))   as ValorDescontoItem,            
 sum(isnull(VL_IPI_UNIT,0))        as VL_IPI_UNIT,          
 sum(isnull(PBruto,0))             as PbrutoTot,          
 sum(isnull(Pliq,0))               as PLiqTot,          
 sum(isnull(QVolumes,0))           as QVolumes,  
 sum(isnull(VL_TOTAL_PRODUTOS,0))  as vl_total_produtos  
                  
from                           
 #ItensC i                          
                          
group by                           
 cd_pedido_venda--, pc_ipi                          
end
else
begin
insert into #TotalItens
select                           
 cd_pedido_venda,                          
 sum(isnull(pc_ipi,0))             as pc_ipi,    
 sum(isnull(VL_TOTAL,0))           as ValorTotal,    
 sum(isnull(VL_TOTAL_SALDO,0))     as ValorTotalSaldo,     
 sum(isnull(VL_TOTAL_S_DESC,0))    as ValTotSDesc,                          
 sum(isnull(QTDE,0))               as QtdeTotal,  
 COUNT(ISNULL(QTDE,0))      as Total_itens,  
 sum(isnull(QTDE_EMB_UNIT,0))      as QtdeTotalEmb,                          
 sum(isnull(VL_DESCONTO_ITEM,0))   as ValorDescontoItem,            
 sum(isnull(VL_IPI_UNIT,0))        as VL_IPI_UNIT,          
 sum(isnull(PBruto,0))             as PbrutoTot,          
 sum(isnull(Pliq,0))               as PLiqTot,          
 sum(isnull(QVolumes,0))           as QVolumes,  
 sum(isnull(VL_TOTAL_PRODUTOS,0))  as vl_total_produtos  
                  
from                           
 #Itens i                          
                          
group by                           
 cd_pedido_venda--, pc_ipi                          
end                          
------------ERRO NA BRACONI--------------   
create table #totalPC(
  cd_pedido_venda int,                          
  pc_ipi float)

if @ic_cancelados = 'S'
begin
insert into #totalPC
select
 cd_pedido_venda,                          
 pc_ipi                          
from                           
 #ItensC                          
where                          
 pc_ipi > 0                          
group by                           
 cd_pedido_venda, pc_ipi                          
--------------------------                          
                         
select                         
  @dt_entrega = max(isnull(convert(varchar,DT_PRAZO_ENTREGA,103),'')),  
  @dt_fabrica = max(DT_FABRICA)  
from                           
  #ItensC  
end
else
begin
insert into #totalPC
select                          
 cd_pedido_venda,                          
 pc_ipi                          
from                           
 #Itens                          
where                          
 pc_ipi > 0                          
group by                           
 cd_pedido_venda, pc_ipi                          
--------------------------                          
                          
select                         
  @dt_entrega = max(isnull(convert(varchar,DT_PRAZO_ENTREGA,103),'')),  
  @dt_fabrica = max(DT_FABRICA)  
from                           
  #Itens  
end   
  
/******************************  
  Dados do Pedido de Venda  
******************************/  
if @cd_parametro = 0  
begin  
                          
  declare @ic_desconto_icms  char(1)                          
  declare @pc_icms_estado    decimal(25,2)                          
  set @ic_desconto_icms = 'N'                          
  set @pc_icms_estado   = 0                          
                          
    SELECT                              
      @pc_icms_estado              = isnull(ep.pc_aliquota_icms_estado,0),                          
      @ic_desconto_icms            = isnull(ic_desconto_icms,'N')                          
                            
    FROM                              
      pedido_venda pv                     WITH(NOLOCK)                          
      LEFT OUTER JOIN Cliente c           WITH(NOLOCK) on c.cd_cliente = pv.cd_cliente                           
      LEFT OUTER JOIN Estado e            WITH(NOLOCK) on c.cd_estado  = e.cd_estado AND c.cd_pais   = e.cd_pais                             
      LEFT OUTER JOIN Estado_Parametro ep WITH(NOLOCK) on c.cd_pais    = ep.cd_pais  and c.cd_estado = ep.cd_estado                            
                            
    WHERE                                 
      pv.cd_pedido_venda = @cd_pedido_venda and                          
      isnull(c.ic_sub_tributaria_cliente,'N') = 'S'                            
                          
  select                           
  @parcela  = @parcela  + cast(cd_parcela_ped_venda as varchar )                                                    + char(13) + char(10),                          
  @pvencto  = @pvencto  + convert( nvarchar, dt_vcto_parcela_ped_venda , 103)                                       + char(13) + char(10),                          
  @pvalor   = @pvalor   + 'R$: '     + replace(cast(cast(case when isnull(@pc_tpedido,0)>0 and isnull(@ic_imposto,'N') = 'S' then                          
                                                            (vl_parcela_ped_venda * @pc_tpedido)                           
               else                           
                  vl_parcela_ped_venda                          
               end as decimal(15,2))as varchar),'.',',') + char(13) + char(10),                          
       
  @parcelas = @parcelas + 'Parcela ' + cast(cd_parcela_ped_venda as varchar ) + ' - ' + CONVERT( nvarchar, dt_vcto_parcela_ped_venda , 103)+' - '+isnull(fp.nm_forma_pagamento,'') + char(13)+ char(10)                           
  from                           
     pedido_venda_parcela pvp                          
     left outer join forma_pagamento fp with(nolock) on fp.cd_forma_pagamento = pvp.cd_tipo_pagamento                          
  where                           
     pvp.cd_pedido_venda = @cd_pedido_venda                          
                          
                          
 -------------------------------------------------------------------------------------------------------------------------------------------------------------------                          
 --- Parcelas Guarufilmes-----                          
                          
   declare @parcelap varchar(8000)                            
   declare @pvenctop varchar(8000)                            
   declare @pvalorp  varchar(8000)               
                          
   select               
    @parcelap  = @parcelap + cast(cd_parcela as varchar )                                                + char(13) + char(10),                            
    @pvenctop  = @pvenctop + convert( nvarchar, dt_vencimento , 103)                                     + char(13) + char(10),                            
    @pvalorp   = @pvalorp  + 'R$: ' + replace(cast(cast(vl_parcela as decimal(15,2))as varchar),'.',',') + char(13) + char(10)                          
  from                             
    Pedido_Venda_Pagamento_Parcela pvpp  
  where  
     pvpp.cd_pedido_venda = @cd_pedido_venda  
                          
 -------------------------------------------------------------------------------------------------------------------------------------------------------------------                          
                          
 
end  
--------------------------------------------------------------------------------------

SELECT 
	@nm_destinacao            = nm_destinacao_produto

FROM destinacao_produto

--------------------------------------------------------------------------------------

select 

	@cd_pedido_venda            = cd_pedido_venda,
--	@dt_emissao                 = CONVERT(VARCHAR(12),pv.dt_pedido_venda, 103),
	
	@ordem_compra                = cd_pdcompra_pedido_venda								
								   
	
from pedido_venda pv
---------------------------------------------------------------------------------------
select 

	@tp_pedido_venda            = tp.sg_tipo_pedido
		
from tipo_pedido tp
--------------------------------------------------------------------------------------------
select
    @nm_endereco_cliente_etg    = clic.nm_complemento_endereco,
	@nm_numero_endereco_etg     = clic.cd_numero_endereco,
	@nm_bairro_etg              = clic.nm_bairro_cliente

from cliente_endereco clic

----------------------------------------------------------------------------------------
select
	@grupo                        =	'('+cast(isnull(cli.cd_cliente_grupo,0) as varchar(10))+')',
	@nm_cliente                   = cli.nm_razao_social_cliente,
	@nm_fantasia                  = cli.nm_fantasia_cliente,
	@nm_endereco_cliente_cli      = IsNull(cli.nm_endereco_cliente,'')                    + ', ' +                          
									IsNull(cast(cli.cd_numero_endereco as varchar(5)),'') + ' '  +                          
									Isnull(cli.nm_complemento_endereco,'') ,
	
	@nm_tel                       = case when isNull(cli.cd_ddd,'') = '' then '' else  
									    '(' + ltrim(rtrim(isNull(cli.cd_ddd,''))) +')' end   
											+ ltrim(rtrim(isNull(cli.cd_telefone,'')))  ,         
	@nm_bairro_cli                = cli.nm_bairro,
	@cep_cli 		              = cli.cd_cep,
	@cnpj                         = dbo.fn_formata_cpf(cli.cd_cnpj_cliente),
	@nm_tel_fax                   = '(' + ltrim(rtrim(isnull(cli.cd_ddd,0))) +')'+
										  ltrim(rtrim(isnull(cli.cd_telefone,0))) + ' / FAX: ' +
										  ltrim(rtrim(isnull(cli.cd_fax,0))),
	@insc_estadual                = cli.cd_inscestadual,
	@suframa                      = cli.cd_suframa_cliente
	
from cliente cli

------------------------------------------------------------------------------------------------
--cidade Cliente
select 
	@nm_cidade_cli                = ltrim(rtrim(IsNull(cidc.nm_cidade,'')))+' - '+  
										 IsNull(ufc.sg_estado,'')  
	
from cidade cidc,estado ufc

	
---------------------------------------------------------------------------------------------
-- cidade entrega
select
	@nm_cidade_etg              = cidcc.nm_cidade

from cidade cidcc
-------------------------------------------------------------------------------------------------
--Transportadora

	select 
		
		@nm_transport               = nm_transportadora
		
		
	from transportadora
-------------------------------------------------------------------------------------------------

select 
	@cep_etg                        =  clie.cd_cep_cliente

from cliente_endereco clie

--------------------------------------------------------------------------------------------------

-- Transportadora
	select 
		@tipo_frete                 = tppv.nm_tipo_pagamento_frete
	from tipo_pagamento_frete tppv

----------------------------------------------------------------------------------------------------  
	select 
		@condicao_pagamento         = cp.nm_condicao_pagamento

	from condicao_pagamento cp
---------------------------------------------------------------------------------------------------
	select 
		@tp_pagamento               = fp.nm_forma_pagamento
	from forma_pagamento fp
----------------------------------------------------------------------------------------------------
	select 
		@vendedor                   = nm_vendedor 
	from vendedor
----------------------------------------------------------------------------------------------------
	select 
		@ds_observacao              = pvl.ds_observacao_liberacao,
		@coleta						= case when isnull(pvl.cd_coleta_processo,0) >0 then          
										pvl.cd_coleta_processo          
									  else          
										 ''          
									  end                                   
		
	from Pedido_Venda_Liberacao pvl
-----------------------------------------------------------------------------------------------------
select 
@faturado                   = nm_fantasia_empresa
from Empresa_Faturamento ef

if @cd_parametro = 0                          
begin                          
                      
 -->Modelo Guarufilme                          
 if @cd_modelo = 4 and dbo.fn_empresa() in (136) and isnull(@cd_pedido_100,0) = 0            
 begin                 
    select ITEM, DESCRICAO_PRODUTO, MEDIDAS, QTDE, UN , PLiq, PBruto, cast(PC_IPI as int) as PC_IPI, replace(cast(cast(VL_UNITARIOG as decimal(12,4)) as varchar(15)),'.',',') as VL_UNITARIOG, VL_TOTALG, FTKG                           
  from #itens                          
 end               
 -->Modelo Guarufilme 100               
 if @cd_modelo = 4 and dbo.fn_empresa() in (136) and isnull(@cd_pedido_100,0) = 1            
 begin                          
    select ITEM, DESCRICAO_PRODUTO, MEDIDAS, QTDE, UN , PLiq, PBruto, cast(PC_IPI as int) as PC_IPI, replace(cast(cast(VL_UNITARIO as decimal(12,4)) as varchar(15)),'.',',') as VL_UNITARIO, VL_TOTAL                           
  from #itens                          
 end        
 -->Modelo Guarufilme Saldo   QTDE_SALDO            
 if @cd_modelo = 4 and dbo.fn_empresa() in (136) and isnull(@cd_pedido_100,0) = 2            
 begin                          
    select ITEM, DESCRICAO_PRODUTO, MEDIDAS, QTDE_SALDO, UN , PLiq, PBruto, cast(PC_IPI as int) as PC_IPI, replace(cast(cast(VL_UNITARIO as decimal(12,4)) as varchar(15)),'.',',') as VL_UNITARIO, VL_TOTAL_SALDO                          
  from #itens      
  where isnull(QTDE_SALDO,0)>0    
 end       
  
 if @cd_modelo = 4 and dbo.fn_empresa() in (174,175)  
 begin  
   
 select DESCRICAO_PRODUTO, QTDE, UN, MEDIDAS, NCM, VL_UNITARIO, VL_TOTAL  
 from #Itens  
   end      
  
END        
	


----------------------------------------------------------------------------------------------------------------------------
set  @html_detalhe_1 = '
<table class="primeiraTabela">
            <thead>
                <tr>
                   
                    <th>Condição de Pagamento</th>
                    <th>Forma de Pagamento</th>
                    <th>Vendedor</th>
                    <th>Faturado Por</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    
                    <td>'+isnull(@condicao_pagamento,'')+'</td>
                    <td>'+isnull(@tp_pagamento,'')+'</td>
                    <td>'+isnull(@vendedor,'')+'</td>
                    <td>'+isnull(@faturado,'')+'</td>
                </tr>
            </tbody>
        </table>
        <table>
            <thead>
                <tr>
                    <th>Item</th>
                    <th>Produto</th>
                    <th>L x E x C</th>
                    <th>Qtd.</th>
                    <th>U.M</th> 
                    <th>Peso (LIQ)</th>
                    <th>Peso (BRU)</th>
                    <th>(%)IPI</th>
                    <th>Vlr Unitário</th>
                    <th>Vlr Total</th>
                    <th>FT KG</th>
                </tr>
            </thead>
            
'

  set @html_detalhe = '
	<table style="width: 100%;">
            <tr>
                <td style="display: flex; flex-direction: column; gap: 20px;">
                    <p style="display: flex; justify-content: space-between; align-items: flex-start; gap: 80px;">
                       <strong> Dados do Cliente </strong>
                        <span><strong>Telefone:</strong> '+isnull(@nm_tel,'') +'</span>
                        <span><strong>Grupo: </strong>'+cast(isnull(@grupo,0) as varchar(10))+'</span>
                        <span><strong>'+isnull(@nm_fantasia,'')+'</strong></span>
                    </p> 
        
                    
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
        
                       
                        <div style="text-align: left; width: 45%;">
                            <p><strong>Nome Cliente:</strong> '+isnull(@nm_cliente,'')+'</p>
                            <p><strong>Endereço:</strong> '+cast(isnull(@nm_endereco_cliente_cli,'')as varchar (100))+'</p>
                            <p><strong>Bairro:</strong> '+isnull(@nm_bairro_cli,'')+'</p>
                            <p><strong>Cidade:</strong>'+isnull(@nm_cidade_cli,'')+' </p>
                            <p><strong>CEP:</strong> '+isnull(@cep_cli,'')+'</p>
                        </div>
        
                        
                        <div style="text-align: right; width: 45%;">
                            <p><strong>CNPJ/CPF:</strong> '+isnull(@cnpj,'')+'</p>
                            <p><strong>Inscrição Estadual:</strong> '+isnull(@insc_estadual,'')+'</p>
                            <p><strong>Suframa:</strong> '+isnull(@suframa,'')+'</p>
                            <p><strong>Telefone:</strong> '+isnull(@nm_tel_fax,'')+'</p>
                        </div>
                    </div>
                </td>
            </tr>
        </table>
        
        <div>
            
            <table style="width: 100%; margin-bottom: 10px;">
              <tr>
                <th style="text-align: left;">Dados da Entrega</th>
                <th style="text-align: right;">Transportadora</th>
              </tr>
              <tr>
                <td style="text-align: left; width:45%">
                  <p><strong>Endereço:</strong>'+isnull(@nm_endereco_cliente_etg,'')+', '+cast(isnull(@nm_numero_endereco_etg,0) as varchar(20))+'</p>
                  <p><strong>Bairro:</strong> '+isnull(@nm_bairro_etg,'')+'</p>
                  <p><strong>Cidade:</strong> '+isnull(@nm_cidade_etg,'')+'</p>
                  <p><strong>CEP:</strong> '+isnull(@cep_etg,'')+'</p>
                </td>
                <td style="text-align: left; width:45%">
                  <p><strong>Nome: </strong> '+isnull(@nm_transport,'')+'</p>
                  <p><strong>Frete: </strong> '+isnull(@tipo_frete,'')+'</p>
                  <p><strong>Coleta: </strong> '+@coleta+'</p>
                  <p><strong>Observação:</strong>'+isnull(@ds_observacao,'')+' </p>
                  <hr style="border: none; border-top: 1px solid black; margin: 5px 0;">
                  <p><strong>Ordem de Compra:</strong> '+isnull(@ordem_compra,'')+'</p>
                </td>
              </tr>
            </table>
          
          </div>

		  '+@html_detalhe_1+'

  '


  ------------------------------------------------------------------------------------------------------------------------------------
   
     
	 declare @id int= 0
	while exists ( select top 1 cd_controle from #itens )
	begin
	
  select top 1
    @id = cd_controle,
   @html_detalhe = @html_detalhe + '
           
		   <tbody>
                <tr>
                    <td>'+cast(isnull(ITEM,0) as varchar(20))+'</td>
                    <td>'+isnull(DESCRICAO_PRODUTO,'')+'</td>
                    <td>'+isnull(MEDIDAS,'')+'</td>
                    <td>'+cast(isnull(QTDE,0) as varchar(20))+'</td>
                    <td>'+isnull(UN,'')+'</td>
                    <td>'+cast(isnull(PLiq,0) as varchar(20))+'</td>
                    <td>'+cast(isnull(PBruto,0) as varchar(20))+'</td>
                    <td>'+cast(isnull(PC_IPI,0) as varchar(20))+'</td>
                    <td>'+cast(isnull(VL_UNITARIO,0) as varchar(20))+'</td>
                    <td>'+cast(isnull(VL_TOTAL,0) as varchar (20))+'</td>
                    <td>'+cast(isnull(FTKG,0) as varchar (30))+'</td>
                </tr>
            </tbody>
        
	'

  from
    #Itens

  order by
    cd_controle

  
  delete from #Itens where cd_controle = @id

  
end
set  @html_detalhe = @html_detalhe +'
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

exec pr_egis_relatorio_dados_pedido_venda_guarufilme 189,4253,0,45676,''
