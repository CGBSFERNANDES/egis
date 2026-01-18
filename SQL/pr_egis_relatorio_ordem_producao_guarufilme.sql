IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_ordem_producao_guarufilme' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_ordem_producao_guarufilme

go
-------------------------------------------------------------------------------------------
create procedure pr_egis_relatorio_ordem_producao_guarufilme  

@cd_relatorio      int = 0,
@cd_usuario        int = 0,
@cd_parametro      int = 0,
@cd_documento      int = 0,
@cd_item_documento int = 0,

@json nvarchar(max) = '' 

as 

set @json = isnull(@json,'')

declare @tipo_frete		         nvarchar(200)
declare @cd_empresa              int = 0
declare @cd_ano                  int    
declare @cd_mes                  int    
declare @cd_dia                  int
declare @dt_hoje                 nvarchar(50)
declare @dt_inicial              datetime
declare @dt_final                datetime
declare @cd_grupo_relatorio      int
declare @dt_impresso             nvarchar(30)
---------------------------------------------------------------------------------------
declare @cd_pedido_venda         int = 0
declare @nm_medida				 varchar(30)	
declare @nm_cliente              nvarchar(500)
declare @ds_produto              nvarchar(300)
declare @ordem_producao			 int = 0
declare @dt_producao			 nvarchar(20)
declare @dt_entrega              nvarchar(20)
declare @dias                    nvarchar(20)
declare @qt_producao             float = 0 
declare @qt_largura              float = 0 
declare @qt_espessura            float = 0 
declare @qt_comprimento          float = 0
declare @qt_volume               float = 0
declare @qt_peso                 float = 0
declare @item_tubete             nvarchar(50)
declare @peso_material           nvarchar(20) 
declare @peso_mat_tub            nvarchar(20) 
declare @peso_mat_tub_caixa      nvarchar(20) 
declare @qtd_caixa               nvarchar(20) 
declare @qtd_caixa_coletiva      nvarchar(20) 
declare @nm_estado				 nvarchar(200)
declare @nm_cidade_cli		     nvarchar(200)
declare @nm_bairro				 nvarchar(200)
declare @peso_tubete             nvarchar(20) 
declare @peso_cxindividual		 nvarchar(20) 
declare @peso_cxcoletiva         nvarchar(20)  
declare @cx_individual           nvarchar(100)
declare @cx_coletiva             nvarchar(100)
declare @observacao              nvarchar(2000)
declare @cd_produto              int = 0
----------------------------------------------------------------------------------------
---------------------------------Dados Empresa------------------------------------------

declare
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
	@cd_vendedor                int          = 0,
	@cd_cliente				    int          = 0,
	@cd_tipo_pedido             int          = 0,
    @cd_item_pedido_venda       int          = 0,
	@nm_descricao_produto       nvarchar (500),
	@nm_caminho			        nvarchar(150),       
	@nm_caminho_gerado          nvarchar(150),
	@qt_tolerancia                 float = 0,
	@qt_dimensao_inicial        float =0

	


-------------------------------------------------------------------------------------------
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
set @cd_empresa        = 0
set @nm_caminho        = 'C:\GBS-EGIS\Modelo\modeloOP.doc'      
set @nm_caminho_gerado = 'C:\GBS-EGIS\Modelo\Geradas\'  
set @cd_pedido_venda   = @cd_documento
set @cd_item_pedido_venda = @cd_item_documento

-------------------------------------------------------------------------------------------

if @json<>''
begin
  select                     
    1                                                    as id_registro,
    IDENTITY(int,1,1)                                    as id,
    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
    valores.[value]              as valor                    
                    
    into #json                    
    from                
      openjson(@json)root                    
      cross apply openjson(root.value) as valores   

	  
------------------------------------declara as variveis que vem com o json---------------------


 select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'
-- select @cd_item_pedido_venda   = valor from #json where campo = 'cd_item_pedido_venda'
-- select @cd_pedido_venda        = valor from #json where campo = 'cd_pedido_venda'


end

-----------------------------------------------------------------------------------------------

declare @ic_processo char(1) = 'N'
 

select
  @titulo             = nm_relatorio,
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)

from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio

-------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------
set @cd_empresa = dbo.fn_empresa()
--------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------

 
declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabe�alho da Empresa
declare @html_grafico    nvarchar(max) = '' --Gr�fico
declare @html_titulo     nvarchar(max) = '' --T�tulo
declare @html_cab_det    nvarchar(max) = '' --Cabe�alho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_detalhe_1  nvarchar(max) = '' --Detalhes_1
declare @html_rod_det    nvarchar(max) = '' --Rodap� do Detalhe
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

-- Obt�m a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
----------------------------------------------------------------------------------------------------
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

        table,
        th,
        td {
            border: 1px solid #ddd;
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
            padding: 5px;
            text-align: center;
        }

        .section-title {
            background-color: #1976D2;
            color: white;
            padding: 5px;
            margin-bottom: 10px;
            border-radius: 5px;
        }

        img {
            
            max-width: 350px;
            margin: 15px;
        
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
        .titulo{
            align-items: center;
            justify-content: center;
        }
        .textocorpo{
            text-align: justify;
            align-items: center;
            margin: 15px 110px;
            padding: auto;
        }

        .assinatura{
            display: flex;
            justify-content: center; 
            align-items: center; 
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

-----------------------------------------------------------------------------------------------------------------------------------

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
---------------------------------------------------------------------------------------------------------
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

--select @nm_dados_cab_det

--select * from #RelAtributo

--select * from parametro_relatorio
--delete from parametro_relatorio
--update parametro_relatorio

--Chamada dos Parametros do Relat�rio---

--declare @cd_tipo_pedido int


declare @vl_valor_total          decimal(25,2) = 0.00
declare @qt_total                int = 0
----------------------------------------select com infroma��es do HTML--------------------------------------------------------------------------------------------------------
declare @cd_processo int      
      
select @cd_processo = pp.cd_processo from       
    Processo_Producao pp with (nolock)            
   where      
   pp.cd_pedido_venda = @cd_pedido_venda      
   and      
   pp.cd_item_pedido_venda = @cd_item_pedido_venda      
        
  --------------------------------------------------------------------------------------------------------------------------------      
     
--if @qt_parametro = 1      
--begin      
    
  declare @TUBETE varchar(100)    
  declare @PTUBETE decimal(25,3)    
  declare @CXIND varchar(100)    
  declare @PCXIND decimal(25,3)    
  declare @CXCOL varchar(100)    
  declare @PCXCOL decimal(25,3)    
  
  select        
     p.cd_familia_produto,        
     isnull(te.ic_caixa_master,'N') as ic_caixa_master,        
     p.cd_mascara_produto,        
     p.nm_produto,        
     pvc.qt_peso_liquido_produto    as qt_peso_liquido      
  into   
     #ComponenteProd        
  from        
     Pedido_Venda_Item_Medida pvim          with (nolock)        
     inner join Pedido_Venda_Composicao pvc with (nolock) on pvc.cd_pedido_venda      = pvim.cd_pedido_venda and  
                                                          pvc.cd_item_pedido_venda = pvim.cd_item_pedido_venda  
     left outer join Produto p              with (nolock) on p.cd_produto             = pvc.cd_produto        
     left outer join Tipo_Embalagem te      with (nolock) on te.cd_tipo_embalagem     = p.cd_tipo_embalagem        
  where        
     pvim.cd_pedido_venda      = @cd_pedido_venda and  
    pvim.cd_item_pedido_venda = @cd_item_pedido_venda  
----------------------------------------------------------    
    
 ---------------------------------------------------------------------------   
     select @TUBETE  = (select cd_mascara_produto + ' - ' + nm_produto from #ComponenteProd where cd_familia_produto = 48),    
            @PTUBETE = (select qt_peso_liquido from #ComponenteProd where cd_familia_produto = 48),    
            @CXIND   = (select cd_mascara_produto + ' - ' + nm_produto from #ComponenteProd where cd_familia_produto = 26 and ic_caixa_master = 'N'),    
            @PCXIND  = (select qt_peso_liquido from #ComponenteProd where cd_familia_produto = 26 and ic_caixa_master = 'N'),    
            @CXCOL   = (select cd_mascara_produto + ' - ' + nm_produto from #ComponenteProd where cd_familia_produto = 26 and ic_caixa_master = 'S'),    
            @PCXCOL  = (select qt_peso_liquido from #ComponenteProd where cd_familia_produto = 26 and ic_caixa_master = 'S')    

	
	
    
     drop table #ComponenteProd    

------------------------------------------------------------------------------------------------------  


 declare @qt_peso_liquido_total float      
 set @qt_peso_liquido_total = 0.00      
      
      
  select      
    @qt_peso_liquido_total = sum(p.qt_peso_liquido)      
  from      
    Processo_Producao_Componente ppc        with (nolock)      
    inner join processo_producao pp         with (nolock) on pp.cd_processo             = ppc.cd_processo      
    left outer join Produto p               with (nolock) on p.cd_produto               = ppc.cd_produto      
    left outer join Placa pl                with (nolock) on pl.cd_placa                = ppc.cd_placa_processo      
    left outer join Unidade_Medida un       with (nolock) on un.cd_unidade_medida       = ppc.cd_unidade_medida      
  where      
    pp.cd_processo = @cd_processo      
------------------------------------------------------------------------------------------------------    

-----------------------------------------------------------------------------------------------------
  declare @cd_operacao         int      
  declare @nm_desc_operacao    varchar(50)      
  declare @dt_emissao_operacao datetime      
      
  select top 1      
    @cd_operacao         = ppa.cd_operacao,      
    @nm_desc_operacao    = op.nm_fantasia_operacao,      
    @dt_emissao_operacao = ppa.dt_processo_apontamento      
  from      
    processo_producao_apontamento ppa      
    left outer join operacao op on op.cd_operacao = ppa.cd_operacao      
  where      
    ppa.cd_processo = @cd_processo      
  order by      
    ppa.cd_operacao desc      
      
------------------------------------------------------------------------------------------------------       
  select       
    pp.cd_processo                 as [NUM_PROCESSO],      
    pp.dt_processo                 as [EMISSAO],      
      
    --Dados do Documento  
      
    'OP_' +dbo.fn_strzero(pp.cd_processo,7)+'.doc'   as nm_arquivo_documento,      
      
   @nm_caminho                               as nm_caminho_documento,      
      
   @nm_caminho                               as nm_caminho_parametro,      
   @nm_caminho_gerado                        as nm_caminho_gerado,      
    
      
    c.nm_fantasia_cliente                    as [c],      
  isnull(c.cd_cliente,0)                   as [COD_CLIENTE],      
  isnull(c.nm_razao_social_cliente,'')     as [RSCliente],      
      
  isnull(c.nm_razao_social_cliente,'')+' ('+  
  cast(isnull(c.cd_cliente,0) as varchar(20))+')'  as [RSClienteCOD],  
  isnull(e.sg_estado,      
   (select es.sg_estado      
    from estado es       
    where es.cd_estado = c.cd_estado))   as [ESTADO],      
  isnull(ci.nm_cidade,      
   (select cida.nm_cidade      
    from cidade cida      
    where cida.cd_cidade = c.cd_cidade and       
          cida.cd_estado = c.cd_estado))     as [CIDADE],      
      
  isnull(ce.nm_bairro_cliente,c.nm_bairro)   as [BAIRRO],      
------------ cliente      
    v.nm_fantasia_vendedor                   as [VENDEDOR],      
    case      
    when isnull(pvi.cd_pedido_venda,0) > 0 then      
      case when isnull(pvi.cd_servico,0)>0 then      
        cast(pvi.cd_servico as varchar(25))      
      else      
        case when isnull(pvi.cd_produto,0)>0 then      
          pd.cd_mascara_produto      
        else      
          cast(pvi.cd_grupo_produto as varchar(25)) end      
      end      
    else      
      pd.cd_mascara_produto      
   end                                       as [CODIGO_PRODUTO],      
      
 isnull(pd.cd_produto,0)                    as [COD_PROD],      
      
  Case       
    When IsNull(pp.cd_id_item_pedido_venda,0) = 0 then      
      case when isnull(pvi.cd_servico,0) > 0 then      
        cast(s.nm_servico as varchar(25))      
      else      
         case when isnull(pvi.cd_produto,0)>0 and pvi.cd_produto = pp.cd_produto then      
            IsNull(pvi.nm_fantasia_produto, pd.nm_fantasia_produto)       
         else pd.nm_fantasia_produto end      
     end      
    Else pd.nm_fantasia_produto      
  End                                               as [FANTASIA_PRODUTO],      
      
      
  Case        
    When isnull(pvi.cd_produto,0) <> 0 and pvi.cd_produto = pp.cd_produto then pvi.nm_produto_pedido      
    When pvi.cd_servico  > 0 Then       
      case       
        when cast(pvi.ds_produto_pedido_venda as varchar(50)) <> '' then       
          s.nm_servico + ' - ' + cast( pvi.ds_produto_pedido_venda as varchar(50) )      
        else pvi.nm_produto_pedido      
      end      
    else       
      case when isnull(pp.cd_produto,0)>0 then      
            pd.nm_produto      
      else      
           pvi.nm_produto_pedido      
      end      
  End                                                as [DESCRICAO_PRODUTO],      
      
    isnull(um.sg_unidade_medida,'')                  as [UN],      
  isnull(umc.sg_unidade_medida,'')                   as [QUN],      
  pp.qt_planejada_processo                           as [QT_PRODUCAO],      
  isnull(pd.cd_codigo_barra_produto,'')              as [COD_BARRA],      
       
 (select top 1 case when isnull(subppa.qt_peca_boa_apontamento,0) > 0 then       
                  cast(subppa.qt_peca_boa_apontamento as varchar(25))      
               else      
                  subpp.qt_planejada_processo       
      end       
   from      
     processo_producao subpp      
     left outer join Processo_Producao_Apontamento subppa  with (nolock) on subppa.cd_processo = subpp.cd_processo      
   where       
      subpp.cd_processo = @cd_processo )            as [QT_PRODUZIDA],      
      
 isnull(pd.qt_peso_liquido,0)                       as [PESO_LIQUIDO],      
      
  cast(cast(case when isnull(pvim.qt_peso_liquido,0) = 0 then       
  isnull(cim.qt_peso_liquido,0)      
 else isnull(pvim.qt_peso_liquido,0) end as decimal(25,3)) as varchar(20))            as [P_LIQUIDO],      
  
  cast(case when isnull(pvim.qt_peso_liquido,0) = 0 then       
  isnull(cim.qt_peso_liquido,0)      
 else isnull(pvim.qt_peso_liquido,0) end as decimal(25,3))                     as [E_P_LIQUIDO],   
      
  cast(round(case when isnull(pvim.qt_peso_liquido_total,0) = 0 then       
     isnull(cim.qt_peso_liquido_total,0)      
  else       
     isnull(pvim.qt_peso_liquido_total,0)       
  end,3)as varchar(20))                                                as [PLIQTOTAL],      
  
  round(case when isnull(pvim.qt_peso_liquido_total,0) = 0 then       
     isnull(cim.qt_peso_liquido_total,0)      
  else       
     isnull(pvim.qt_peso_liquido_total,0)       
  end,3)                                                              as [E_PLIQTOTAL],      
      
  isnull(pd.qt_peso_bruto,0)                         as [PESO_BRUTO], --**      
      
 case when isnull(pvim.qt_peso_bruto,0) = 0 then       
  isnull(cim.qt_peso_bruto,0)      
 else isnull(pvim.qt_peso_bruto,0) end              as [P_BRUTO],      
      
  case when isnull(pvim.qt_peso_bruto_total,0) = 0 then       
     isnull(cim.qt_peso_bruto_total,0)      
  else       
     isnull(pvim.qt_peso_bruto_total,0)       
  end                                                 as [PBRUTOTAL],      
      
  um.sg_unidade_medida                               as [UNIDADE_MEDIDA],      
      
  isnull(pd.qt_espessura_produto,0)                  as [ESPESSURA], --**     
  --qt_altura_produto X qt_largura_produto X qt_espessura_produto / 10
          
  case when isnull(pvim.qt_espessura,0) = 0 then       
 round(isnull(cim.qt_espessura,0),1)       
  else       
    round(isnull(pvim.qt_espessura,0),1)      
  end                                                  as [QESPESSURA],    
        
  case when isnull(pvim.qt_espessura,0) = 0 then       
 round(isnull(cim.qt_espessura,0),1)       
  else       
    round(isnull(pvim.qt_espessura,0),1)      
  end 
	*
	case when isnull(pvim.qt_largura,0) = 0 then       
   cast(isnull(cim.qt_largura,0)as int)      
 else       
   cast(isnull(pvim.qt_largura,0)as int)       
 end 
	*
case when isnull(pvim.qt_comprimento,0) = 0 then       
	cast(isnull(cim.qt_comprimento,0)as int)      
	else       
	cast(isnull(pvim.qt_comprimento,0)as int)      
	end /10											as [PESOML],


  
  case when isnull(pvim.qt_espessura,0) = 0 then       
 round(isnull(cim.qt_espessura,0),1)       
  else       
    round(isnull(pvim.qt_espessura,0),1)      
  end                                            / 2   as [ESPPAR],
        
 cast(isnull(pd.qt_largura_produto,0) as int)       as [LARGURA], --**       
  
       
 case when isnull(pvim.qt_largura,0) = 0 then       
   cast(isnull(cim.qt_largura,0)as int)      
 else       
   cast(isnull(pvim.qt_largura,0)as int)       
 end                                              as [QLARGURA],      
      
  isnull(pd.qt_comprimento_produto,0)                as [COMPRIMENTO], --**       
      
         
 case when isnull(pvim.qt_comprimento,0) = 0 then       
    cast(isnull(cim.qt_comprimento,0)as int)      
 else       
    cast(isnull(pvim.qt_comprimento,0)as int)      
 end                                                 as [QCOMPRIMENTO],       
      
  isnull(pd.qt_volume_produto,0)                     as [VOLUME], --**       
      
 case when isnull(pvim.qt_volume_produzida,0) = 0
   then case when isnull(pvim.qt_volume,0) = 0 
          then isnull(cim.qt_volume,0)      
          else isnull(pvim.qt_volume,0) 
        end
   else cast(qt_volume_produzida as int)
 end                                                  as [QVOLUME],      
      
      
 --@qt_peso_liquido_total+      
 --(isnull(pd.qt_peso_liquido,0)/
 --isnull(pd.qt_volume_produto,1))                    as [PESO_MATERIAL_COMP],      
       
 @qt_peso_liquido_total+      
 (case when isnull(pvim.qt_peso_liquido,pd.qt_peso_liquido) = 0 then       
  isnull(cim.qt_peso_liquido,pd.qt_peso_liquido)      
 else isnull(pvim.qt_peso_liquido,pd.qt_peso_liquido) end /      
  case when isnull(pvim.qt_volume,pd.qt_volume_produto) = 0 then       
 isnull(cim.qt_volume,pd.qt_volume_produto)      
 else isnull(pvim.qt_volume,pd.qt_volume_produto) end)                 as [P_MATERIAL_COMP],      
      
      
      
 cast(isnull(tp.ds_tolerancia_produto,'')as varchar(500))as [TOLERANCIA],      
 tp.qt_dimensao_inicial                                  as [DIMENSAO_INICIAL],      
 tp.qt_dimensao_final                                    as [DIMENSAO_FINAL],      
 tp.qt_inicio_tolerancia                                 as [INICIO_TOLERANCIA],      
 tp.qt_fim_tolerancia                                    as [FIM_TOLERANCIA],      
  prp.nm_obs_processo_produto                            as [NOTASPP],      
  pd.nm_produto                                          as [PRODUTO],    
  pd.nm_produto+' ('+  
  cast(isnull(pd.cd_produto,0) as varchar(20))+')'       as [PRODUTOCOD],  
  isnull(PP.cd_processo_origem,0)                        as [OPORIGEM],      
  pp.dt_entrega_processo                                 as [DTENTREGA],      
  pp.cd_pedido_venda                                     as [PEDIDO],      
  pp.cd_item_pedido_venda                                as [ITEM],  
 pv.dt_pedido_venda                                      as [DTPEDIDO],  
  cast(pp.cd_pedido_venda as varchar(20))+' - '+  
  cast(pp.cd_item_pedido_venda as varchar(10))           as [PEDIDOITEM],          
  cast(isnull(lpo.ds_obs_cabecalho,'')as varchar(500))+ ' '+      
  cast(isnull(lpo.ds_obs_rodape,'')as varchar(500))      as [NOTAS],      
      
--Descri��o da OP Origem      
  isnull(po.nm_fantasia_produto,'')                      as [PROD_PAI],      
  isnull(po.nm_produto,'')                               as [DESC_PAI],      
      
--Entrega Processo      
 isnull(pp.dt_entrega_processo,'')                       as [ENTREGA],
 isnull(ctp.nm_categoria_produto,'')                     as [CATEGORIA_PROD],
      
--TOTAL---      
 --tt.[Tot_tempo]                              as [Tot_tempo],      
      
--DIAS--      
 datediff(dd,pp.dt_processo,pp.dt_entrega_processo) as [DIAS],                                
 '('+cast(datediff(dd,pp.dt_processo,pp.dt_entrega_processo) as varchar(5))+')' as [E_DIAS],  
      
--CADASTRADO--      
  'Cadastrado por '+isnull(u.nm_usuario,pp.nm_processista)+' em '      
   +rtrim(ltrim(isnull(cast(replace(convert(char,pp.dt_processo,103),'.','-') as varchar(30)),''))) as [CADASTRADO],      
--ALTERADO--      
 'Alterado por '+isnull(ua.nm_usuario,ui.nm_usuario)+' em '      
   +rtrim(ltrim(isnull(cast(replace(convert(char,pp.dt_usuario,103),'.','-') as varchar(30)),''))) as [ALTERADO],   
------------  
  'Cadastrado por '+isnull(u.nm_usuario,pp.nm_processista)+' em '      
   +rtrim(ltrim(isnull(cast(replace(convert(char,pp.dt_processo,103),'.','-') as varchar(30)),'')))+' / '+  
 'Alterado por '+isnull(ua.nm_usuario,ui.nm_usuario)+' em '      
   +rtrim(ltrim(isnull(cast(replace(convert(char,pp.dt_usuario,103),'.','-') as varchar(30)),''))) as [CAD_ALT],      
--IMPRESSO--      
 'Impresso em '+rtrim(ltrim(@dt_impresso))+' por '+isnull(ui.nm_usuario,'')           as [IMPRESSO],      
      
        
 --isnull(convert(varchar,prop.dt_revisao_processo,103),'')                             as [revisao_proc],      
   isnull(cast(replace(convert(char,prop.dt_revisao_processo,103),'.','-') as varchar(30)),'') as [revisao_proc],      
      
      
  isnull((select top 1 uap.nm_usuario from processo_padrao_aprovacao ppa with (nolock) 
  left outer join egisadmin.dbo.usuario uap with (nolock) on uap.cd_usuario = ppa.cd_usuario_aprovacao      
  where ppa.cd_processo_padrao = prop.cd_processo_padrao),isnull(ui.nm_usuario,''))   as [Autorizacao],      
      
  isnull(nm_tipo_processo,'')                                                         as [Programacao],      
      
  @cd_operacao                as [cd_op],    
  @nm_desc_operacao           as [nm_desc_op],    
  @dt_emissao_operacao        as [emissao_ap],    
  isnull(pp.ds_processo,'')   as [memo],    
        
 /**---------------------------------------------------------- **/      
  /** O campo de imagem deve conter as 3 primeiras letras o IMG **/      
  /** para que a classe identifique que dever� inserir a imagem **/      
  /** do caminho informado no Word.                             **/      
 /**---------------------------------------------------------- **/      
  isnull(pp.nm_imagem_processo,'')                  as [IMG_PROCESSO],      
  isnull(ppm.nm_obs_medida,'')                      as [OBSERVACAO],      
      
      ----PESO MATERIAL + PESO TUBETE----      
  cast(cast(isnull(      
   case when isnull(pvim.qt_peso_liquido,0) = 0 then       
     isnull(cim.qt_peso_liquido,0)      
   else       
     isnull(pvim.qt_peso_liquido,0)       
   end,0) +      
   isnull(@PTUBETE,0) as decimal(25,3))as varchar(20))                as [PMAT_PTUBETE],      
  
   cast(isnull(      
   case when isnull(pvim.qt_peso_liquido,0) = 0 then       
     isnull(cim.qt_peso_liquido,0)      
   else       
     isnull(pvim.qt_peso_liquido,0)       
   end,0) +      
   isnull(@PTUBETE,0) as decimal(25,3))                               as [E_PMAT_PTUBETE],      
      
      ----PESO MATERIAL + PESO TUBETE + CAIXA----      
   cast(cast(isnull(      
   case when isnull(pvim.qt_peso_liquido,0) = 0 then       
     isnull(cim.qt_peso_liquido,0)      
   else       
     isnull(pvim.qt_peso_liquido,0)       
   end,0) +      
   isnull(@PTUBETE,0)  +                           
   isnull(@PCXIND,0) as decimal(25,3))as varchar(20))           as [PMAT_PTUBETE_CX],    
  
   cast(isnull(      
   case when isnull(pvim.qt_peso_liquido,0) = 0 then       
     isnull(cim.qt_peso_liquido,0)      
   else       
     isnull(pvim.qt_peso_liquido,0)       
   end,0) +      
   isnull(@PTUBETE,0)  +                           
   isnull(@PCXIND,0) as decimal(25,3))                          as [E_PMAT_PTUBETE_CX],  
    
    
      ----PESO TUBETE----    
   cast(isnull(@PTUBETE,0) as varchar(20))                      as [PTUBETE],    
   isnull(@PTUBETE,0)                                           as [E_PTUBETE],      
      ----TUBETE----    
   isnull(@TUBETE,'')                                           as [TUBETE],    
     
        
      ----PESO CAIXA INDIVIDUAL----    
   cast(isnull(@PCXIND,0) as varchar(20))                       as [PCXIND],    
   isnull(@PCXIND,0)                                            as [E_PCXIND],    
      ---CAIXA INDIVIDUAL------    
   isnull(@CXIND,'') as [CXIND],    
    
      ----PESO CAIXA INDIVIDUAL----    
   cast(isnull(@PCXCOL,0) as varchar(20))                       as [PCXCOLETIVA],    
   isnull(@PCXCOL,0)                                            as [E_PCXCOLETIVA],     
     -----CAIXA COLETIVA--------    
   isnull(@CXCOL,'')                       as [CXCOLETIVA],    
   isnull(pvim.qt_embalagem,0)             as [QEMBALAGEM],
   case when isnull(tratp.nm_tratamento_produto,'') = '' then nm_fat_titulo_tratamento else nm_tratamento_produto end as [TRATAMENTO],
   '' as [QDINAS],
   '' AS [QLADOS]
 into  
   #ApresentacaoFinal  
      
 from      
   processo_producao pp                                with (nolock)  
   left outer join Laudo_Produto_Observacao lpo        with (nolock) on lpo.cd_produto            = pp.cd_produto       
   left outer join processo_padrao prop                with (nolock) on prop.cd_processo_padrao   = pp.cd_processo_padrao      
   left outer join Pedido_Venda pv                     with (nolock) on pv.cd_pedido_venda        = pp.cd_pedido_venda       
   left outer join Pedido_Venda_Item pvi               with (nolock) on pp.cd_pedido_venda        = pvi.cd_pedido_venda and       
                                                                        pp.cd_item_pedido_venda   = pvi.cd_item_pedido_venda       
   left outer join tipo_processo tip                   with (nolock) on tip.cd_tipo_processo      = pp.cd_tipo_processo      
   left outer join Vendedor v                          with (nolock) on v.cd_vendedor             = pv.cd_vendedor      
   left outer join Produto pd                          with (nolock) on pd.cd_produto             = pp.cd_produto      
   left outer join Servico s                           with (nolock) on s.cd_servico              = pvi.cd_servico      
   left outer join Unidade_Medida um                   with (nolock) on um.cd_unidade_medida      = pd.cd_unidade_medida      
   left outer join Cliente c                           with (nolock) on c.cd_cliente              = case when isnull(pv.cd_cliente,0)=0 then       
                                                                                                      pp.cd_cliente       
                                                                                                    else       
                                                                                                      pv.cd_cliente       
                                                                                                    end      
   left outer join cliente_endereco ce                 with (nolock) on ce.cd_cliente             = c.cd_cliente      
                                                                    and ce.cd_tipo_endereco       = 3      
   left outer join cidade ci                           with (nolock) on ci.cd_cidade              = ce.cd_cidade and      
                                                                        ci.cd_estado              = ce.cd_estado      
   left outer join estado e                            with (nolock) on e.cd_estado               = ce.cd_estado      
   left outer join Tolerancia_produto tp               with (nolock) on tp.cd_tolerancia_produto  = pd.cd_tolerancia_produto      
   left outer join Produto_Processo  prp               with (nolock) on prp.cd_produto                = pp.cd_produto      
   left outer join Processo_Producao ppo               with (nolock) on ppo.cd_processo               = pp.cd_processo_origem      
   left outer join Produto po                          with (nolock) on po.cd_produto                 = ppo.cd_produto      
   left outer join Produto_Tratamento pt               with (nolock) on pt.cd_produto                 = pt.cd_produto
   left outer join Tratamento_produto tratp            with (nolock) on tratp.cd_tratamento_produto   = pt.cd_tratamento_produto
   left outer join egisadmin.dbo.usuario u             with (nolock) on u.cd_usuario              = pp.cd_usuario_processo      
   left outer join egisadmin.dbo.usuario uc            with (nolock) on uc.cd_usuario             = pv.cd_usuario_atendente    
   left outer join egisadmin.dbo.usuario ua            with (nolock) on ua.cd_usuario             = pp.cd_usuario      
   left outer join egisadmin.dbo.usuario ui            with (nolock) on ui.cd_usuario             = @cd_usuario      
   left outer join Pedido_Venda_Item_Medida pvim       with (nolock) on pvim.cd_pedido_venda      = pp.cd_pedido_venda and       
                                                                        pvim.cd_item_pedido_venda = pp.cd_item_pedido_venda      
   left outer join consulta_itens_medida cim           with (nolock) on cim.cd_consulta           = pvi.cd_consulta and       
                                                                        cim.cd_item_consulta      = pvi.cd_item_consulta      
   left outer join consulta_itens cii                  with (nolock) on cii.cd_consulta           = cim.cd_consulta and       
                                                                        cii.cd_item_consulta      = cim.cd_item_consulta      
   left outer join Unidade_Medida umc                  with (nolock) on umc.cd_unidade_medida     = pvi.cd_unidade_medida      
   left outer join Processo_Producao_Medida ppm        with (nolock) on ppm.cd_processo           = pp.cd_processo 
   left outer join Categoria_Produto ctp               with (nolock) on ctp.cd_categoria_produto  = pd.cd_categoria_produto  
      
 where      
   pp.cd_pedido_venda = @cd_pedido_venda      
   --and      
   --pp.cd_item_pedido_venda = @cd_item_pedido_venda 
   
 --SELECT * FROM #ApresentacaoFinal
   
-----------------------------------tabela--------------------------------------------------------------------
select 
@ordem_producao       = cd_processo,
@dt_producao          = CONVERT(VARCHAR(12), dt_processo, 103),
@dt_entrega           = CONVERT(VARCHAR(12), dt_entrega_processo, 103),
@dias                 = datediff(dd,pp.dt_processo,pp.dt_entrega_processo),
@qt_producao          = qt_planejada_processo
from processo_producao pp
-------------------------------------------------------------------------------------------------------------
select 
@cd_produto           = pd.cd_produto

from Produto pd

--------------------------------------------------------------------------------------------------------------
select 
@cd_cliente           = cd_cliente,
@nm_cliente           = nm_razao_social_cliente
from Cliente c
---------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
select
	@observacao        = ppm.nm_obs_medida
from Processo_Producao_Medida ppm
--------------------------------------------------------------------------------------------------------------------


select
	
	
	--@ordem_producao		 = NUM_PROCESSO,	
	--@cd_produto            = PRODUTOCOD,
	--@nm_cliente            = RSClienteCOD, 
	--@dt_producao		     = EMISSAO,
    --@dt_entrega            = CONVERT(VARCHAR(12), ENTREGA, 103),
	--@dias                  = E_DIAS,
	@nm_bairro             = BAIRRO, 
	@nm_estado             = ESTADO,
	@nm_cidade_cli		   = CIDADE,
	@ds_produto            = DESCRICAO_PRODUTO,
	--@qt_producao           = QT_PRODUCAO,
	@qt_comprimento        = QCOMPRIMENTO,
	@qt_largura            = QLARGURA,
	@qt_espessura          = QESPESSURA,
	@qt_volume             = QVOLUME,
	@qt_peso               = E_PLIQTOTAL,
	------------------------------------------
	@item_tubete           = TUBETE,
    @peso_material         = P_LIQUIDO,
	@peso_mat_tub          = E_PMAT_PTUBETE,
	@peso_mat_tub_caixa    = E_PMAT_PTUBETE_CX,
	@qtd_caixa_coletiva    = E_PMAT_PTUBETE_CX,
	@qtd_caixa             = QEMBALAGEM,
	--@nm_medida             = QUN,
	@peso_tubete           = E_PTUBETE,
	@peso_cxindividual     = PCXIND,
	@peso_cxcoletiva       = E_PCXIND,	
	@qt_tolerancia         = TOLERANCIA,
	@qt_dimensao_inicial   = DIMENSAO_INICIAL,
	@cx_individual		   = CXIND,
	@cx_coletiva           = CXCOLETIVA,
    @observacao            = OBSERVACAO

	
from
   
   #ApresentacaoFinal 

--------------------------------Componentes-----------------------------------------------------------------------------
select 
    pp.cd_processo,
    ppc.cd_produto,
    pc.cd_mascara_produto,
    pc.nm_fantasia_produto,
    pc.nm_produto,
    ppc.qt_comp_processo,
    ppc.cd_lote_item_processo
  into
    #ComponentesOP
  from 
    processo_producao pp with(nolock)
    left outer join processo_producao_componente ppc with(nolock) on ppc.cd_processo = pp.cd_processo
    left outer join produto p                        with(nolock) on p.cd_produto    = pp.cd_produto
    left outer join produto pc                       with(nolock) on pc.cd_produto   = ppc.cd_produto
  where
        pp.cd_pedido_venda       = @cd_pedido_venda
    and pp.cd_item_pedido_venda  = @cd_item_pedido_venda
  order by
    ppc.cd_seq_comp_processo

  -->>Apresenta��o para a tabela
  

---------------------------------------------------------------------------------------------------------------------------
set @html_detalhe_1 = '
	     <table class="manualTabela">
            <thead>
                <tr>
                    <th>P. LIQUIDO</th>
                    <th>P. BRUTO</th>
                    <th>P. LIQUIDO</th>
                    <th>P. BRUTO</th>
                    <th>P. LIQUIDO</th>
                    <th>P. BRUTO</th>
                    <th>P. LIQUIDO</th>
                    <th>P. BRUTO</th>
                    <th>P. LIQUIDO</th>
                    <th>P. BRUTO</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
              </tr>
              <tr>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
            <tr>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
          </tr>
          <tr>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        <tr>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
      </tr>
      <tr>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
    </tr>
   </tbody>
        </table>
    </div>
'

---------------------------------------------------------------------------------------------------------------------------
declare @id int = 0

set @html_detalhe = '

		<div style=" margin:0 6%;"> 
        <h2 style="display: flex; justify-content: center; align-items: center;margin: 60px;">ORDEM DE PRODUÇÃO</h2>
        <table class="primeiraParte">
            <tr>
                <td><strong>Pedido: </strong>'+cast(isnull(@cd_pedido_venda,0) as varchar(20))+' - '+cast(isnull(@cd_item_pedido_venda,0) as varchar(20))+'</td>
                <td><strong>O.P.: </strong>'+cast(isnull(@ordem_producao,0) as varchar(20))+' </td>
            </tr>
            <tr>
                <td><strong>Cliente: </strong>'+isnull(@nm_cliente,'')+' ('+cast(isnull(@cd_cliente,0) as varchar(20))+')</td>
                <td><strong>Data: </strong> ' +isnull(@dt_producao, '')+' </td>
            </tr>
            <tr>
                <td><strong>Produto: </strong>'+isnull(@ds_produto,'')+' </td>
                <td><strong>Entrega:( '+cast(isnull(@dias,'') as varchar (20))+' ) </strong>'+ ISNULL(@dt_entrega,'') + ' </td>
            </tr>
        </table>

        <table class="primeiraTabela">
            <thead>
                <tr >
                    <th>QTDE.</th>
                    <th>LARGURA</th>
                    <th>ESPESSURA</th>
                    <th>COMPRIMENTO</th>
                    <th>VOLUMES</th>
                    <th>PESO</th>
                </tr>
            </thead>
            <tbody>
                <tr style="text-align: center;">
                    <td>'+cast(isnull(@qt_producao,0) as varchar(20))+' '+isnull(@nm_medida ,'')+'</td>
                    <td>'+CAST(ISNULL(@qt_largura,0) as varchar(20))+'</td>
                    <td>'+cast(isnull(@qt_espessura,0)as varchar(20))+'</td>
                    <td>'+cast(isnull(@qt_comprimento,0) as varchar(20))+'</td>
					<td>'+cast(isnull(@qt_volume,0) as varchar(20))+'</td>
                    <td>'+cast(isnull(@qt_peso,0)as varchar(20))+'</td>
                </tr>
            </tbody>
        </table>

        <table class="segundaTabela">
		<thead>
          <tr style="text-align: center;" >
            <td><strong>TUBETE</strong></td>
            <td><strong>CAIXA INDIVIDUAL</strong></td>
            <td><strong>CAIXA COLETIVA</strong></td>
         </tr>
			<tr>
               <td style="position: relative;">
                 <span style="position: absolute; top: 0; right: 0; margin:1%;;"> (Peso: '+cast(isnull(@peso_tubete,0) as varchar (20))+' )</span>
                 <span style="position: absolute; bottom: 0; left: 0;">'+isnull(@item_tubete,'')+'</span>
               </td>

               <td style="position: relative;">																			
                 <span style="position: absolute; top: 0; right: 0; margin:1%;;"> (Peso: '+cast(isnull(@peso_cxindividual,0) as varchar (20))+' )</span>
                 <span style="position: absolute; bottom: 0; left: 0;"> '+isnull(@cx_individual,'')+'</span>
               </td>

               <td style="position: relative;">
                 <span style="position: absolute; top: 0; right: 0; margin:1%;;"> (Peso: '+cast(isnull(@peso_cxcoletiva,0) as varchar (20))+' ) </span>
                 <span style="position: absolute; bottom: 0; left: 0;">'+isnull(@cx_coletiva,'')+'</span>
               </td>
             </tr>
			</thead>
      </table>

		<table class="segundaTabela">
         <thead>
            <tr style="text-align: center;" >
               <td><strong>PESO MATERIAL</strong></td>
               <td><strong>PESO MAT + TUBETE</strong></td>
               <td><strong>PESO MAT + TUB + CAIXA</strong></td>
               <td><strong>QTDE P/ CAIXA</strong></td>
               <td><strong>CAIXA COLETIVA</strong></td>
            </tr>
         </thead>
		  <tbody>
           <tr style="text-align: center;" >
               <td>'+cast(isnull(@peso_material,0)as varchar(20))+' KG</td>
               <td>'+cast(isnull(@peso_mat_tub,0) as varchar(20))+' KG</td>
               <td>'+cast(isnull(@peso_mat_tub_caixa,0) as varchar(20))+' KG</td>
               <td>'+cast(ISNULL(@qtd_caixa,0) as varchar(20))+' UN</td> 
               <td>'+cast(isnull(@qtd_caixa_coletiva,0) as varchar(20))+' KG</td>
            </tr>
		</tbody>
         </table>

        <h4>Observação:'+isnull(@observacao,'')+' </h4>

        <table class="metrosExatosTabela">
            <tr>
                <td>ESTADO:'+isnull(@nm_estado,'')+' </td>
                <td>CIDADE:'+isnull(@nm_cidade_cli,'')+' </td>
                <td>BAIRRO:'+isnull(@nm_bairro,'')+' </td>
            </tr>
        </table>

   '+@html_detalhe_1+'
   '




--HTML Completo--------------------------------------------------------------------------------------


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


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go 

exec pr_egis_relatorio_ordem_producao_guarufilme 191,4253,0,204333, 1,''

