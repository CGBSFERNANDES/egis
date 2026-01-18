IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_minuta_guarufilme' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_minuta_guarufilme

GO

---------------------------------------------------------------------------
create procedure pr_egis_relatorio_minuta_guarufilme
@cd_relatorio int   = 0,
@cd_usuario   int   = 0,
@cd_parametro int   = 0,
@cd_documento int   = 0,
@json nvarchar(max) = '' 

as

set @json = isnull(@json,'')
 
declare @cd_empresa              int = 0

declare @nm_cliente				 nvarchar(500)
declare @tipo_frete		         nvarchar(200)
declare @nm_tranportadora	     nvarchar(300)
declare @nm_descricao			 nvarchar(500)
declare @nm_medida				 nvarchar(500)
declare @vl_qt_item              nvarchar(100)
declare @vl_unidade              nvarchar(100)
declare @vl_peso_liquedo_total   nvarchar(50)
declare @vl_qt_item_total        nvarchar(50) 
declare @vl_peso_liquedo         nvarchar(50)
declare @vl_valor                nvarchar(50)
declare @vl_total                nvarchar(50)
declare @dt_hoje                 nvarchar(50)
declare @dt_titulo               nvarchar(50)
declare @cd_ano                  int    
declare @cd_mes                  int    
declare @cd_dia                  int
declare @dt_inicial              datetime
declare @dt_final                datetime
declare @cd_grupo_relatorio      int
declare @dt_impresso             varchar(30)
declare @cd_pedido               nvarchar (50)


------------------------------------------------------------------------------
-------------------Dados do Relatório---------------------------------------------------------------------------------

declare
    @dt_entrega                 nvarchar(50),
    @cd_pedido_venda            int =0,
	@cd_item					nvarchar(50),
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
	@titulo                     varchar(200)

------------------------------------------------------------------
set @cd_pedido_venda = @cd_documento

declare @ds_minuta          varchar(8000)      
      
select @ds_minuta = isnull(ds_minuta,'')      
from      
 Parametro_Logistica   
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)       
set @cd_empresa        = 0
set @dt_impresso       = cast(replace(convert(char,getdate(),103),'.','-') as varchar(30))        

------------------------------------------------------------------------------

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

	  
------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'
  select @cd_pedido              = valor from #json where campo = 'cd_pedido'             
  select @nm_cliente             = valor from #json where campo = 'nm_cliente'             
  select @tipo_frete            = valor from #json where campo = 'tipo_frente'             
  select @nm_tranportadora       = valor from #json where campo = 'nm_tranportadora'             
  --select @cd_item                = valor from #json where campo = 'cd_item'             
  select @nm_descricao           = valor from #json where campo = 'nm_descricao'
  select @nm_medida              = valor from #json where campo = 'nm_medida'
  select @vl_qt_item             = valor from #json where campo = 'vl_qt_item'
  select @vl_unidade             = valor from #json where campo = 'vl_unidade'
  select @vl_peso_liquedo        = valor from #json where campo = 'vl_peso_liquedo'
  select @vl_qt_item_total       = valor from #json where campo = 'vl_qt_item_total'
  select @vl_peso_liquedo_total = valor from #json where campo = 'vl_peso_liquedo_total'
  select @vl_valor               = valor from #json where campo = 'vl_valor'
  --select @dt_entrega             = valor from #json where campo = '@dt_entrega'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'
  
  end
------------------------------------------------------------------------------

declare @ic_processo char(1) = 'N'
 

select
  @titulo             = nm_relatorio,
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio

  --select @titulo
-------------------------------------------------------------------------------

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

set @cd_empresa = dbo.fn_empresa()
-----------------------------------------------------------------------------------------

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
--select @logo
-------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------
--Dados do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------
 
declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabeçalho da Empresa
declare @html_grafico    nvarchar(max) = '' --Gráfico
declare @html_titulo     nvarchar(max) = '' --Título
declare @html_detalhe_1  nvarchar(max) = '' -- Detalhes_1
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

------------------------------------------------------------------------------------------------------------------------------------------------
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

 --------------------------------------------------------------------------------------------------------------------------------------

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
----------------------------------------------------------------------------------------------------

select      
--      identity(int,1,1) as cd_controle,
   --case when isnull(n.cd_identificacao_nota_saida,0)<>0 then      
   --  n.cd_identificacao_nota_saida      
   --else      
   --  n.cd_nota_saida                                    
   --end      
   '' as Nota,      
      
   isnull(pv.cd_pedido_venda,0)                          as PEDIDO_VENDA,      
   --isnull(n.dt_nota_saida,getdate())                   as dt_nota_saida,      
   ''                                                    as dt_nota_saida,      
   isnull(pv.dt_pedido_venda,'')                         as dt_pedido_venda,       
   isnull(c.nm_razao_social_cliente,'')                  as nm_cliente,
   isnull(pv.cd_cliente,0)                               as cd_cliente,
   isnull(c.nm_razao_social_cliente,'')+' ('+
   cast(isnull(pv.cd_cliente,0) as varchar(10))+')'      as nm_cd_cliente,
   isnull(t.nm_transportadora,'')                        as nm_transportadora,      
   isnull(tf.nm_tipo_frete,'')                           as tipo_frete,      
      
--CADASTRADO--      
  'Cadastrado por '+isnull(uc.nm_usuario,'')+' em '      
   +rtrim(ltrim(isnull(cast(replace(convert(char,pv.dt_pedido_venda,103),'.','-') as varchar(30)),''))) as [CADASTRADO],      
--ALTERADO--      
 'Alterado por '+isnull(ua.nm_usuario,ui.nm_usuario)+' em '      
   +rtrim(ltrim(isnull(cast(replace(convert(char,pv.dt_usuario,103),'.','-') as varchar(30)),''))) as [ALTERADO],
------------
 'Cadastrado por '+isnull(uc.nm_usuario,'')+' em '      
   +rtrim(ltrim(isnull(cast(replace(convert(char,pv.dt_pedido_venda,103),'.','-') as varchar(30)),'')))+' / '+
 'Alterado por '+isnull(ua.nm_usuario,ui.nm_usuario)+' em '      
   +rtrim(ltrim(isnull(cast(replace(convert(char,pv.dt_usuario,103),'.','-') as varchar(30)),''))) as [CAD_ALT],

--IMPRESSO--      
 'Impresso em '+rtrim(ltrim(@dt_impresso))+' por '+isnull(ui.nm_usuario,'')           as [IMPRESSO],      
      
      
   -----------------------------------------------------------------------------------      
   ------------- DADOS EMPRESA -------------------------------------------------------      
   -----------------------------------------------------------------------------------      
  isnull(em.nm_empresa,'')                              as [NM_EMPRESA],      
  isnull(em.nm_fantasia_empresa,'')                     as [nm_fantasia_empresa],      
  isnull(vwe.Endereco_Empresa,'')                       as [NM_ENDERECO_EMPRESA],      
  isnull(em.cd_telefone_empresa,0)                      as [NM_TELEFONE_EMPRESA],      
  isnull(vwe.nm_email_internet,'') + ' / ' +      
  isnull(vwe.nm_dominio_internet,'')                    as [EMAIL_SITE] ,     
  @ds_minuta                                            as [ds_minuta]   
      
   -----------------------------------------------------------------------------------      
   into        
   #Pedido        
  from      
    pedido_venda pv  with (nolock)      
    --left outer join nota_saida n              on n.cd_pedido_venda           = pv.cd_pedido_venda      
    left outer join cliente c                 on c.cd_cliente                = pv.cd_cliente                               
    --left outer join Tipo_Destinatario td      on n.cd_tipo_destinatario      = td.cd_tipo_destinatario       
    --left outer join Operacao_fiscal op        on n.cd_operacao_fiscal        = op.cd_operacao_fiscal       
    --left outer join Grupo_Operacao_Fiscal gop on op.cd_grupo_operacao_fiscal = gop.cd_grupo_operacao_fiscal       
    left outer join transportadora t          on pv.cd_transportadora         = t.cd_transportadora       
    left outer join vendedor v                on pv.cd_vendedor               = v.cd_vendedor       
    --left outer join Entregador e              on n.cd_entregador             = e.cd_entregador       
    left outer join Cidade cid                on cid.cd_cidade               = t.cd_cidade       
                                             and cid.cd_estado               = t.cd_estado      
                                             and cid.cd_pais                 = t.cd_pais       
    left outer join Estado est                on est.cd_estado               = t.cd_estado       
                                             and est.cd_pais                 = t.cd_pais           
    left outer join tipo_frete tf             on tf.cd_tipo_frete            = pv.cd_tipo_frete      
    left outer join egisadmin.dbo.Empresa em  on em.cd_empresa               = @cd_empresa      
    left outer join vw_empresa_endereco vwe   on vwe.cd_empresa              = @cd_empresa      
    left outer join egisadmin.dbo.usuario uc  on uc.cd_usuario               = pv.cd_usuario_atendente      
    left outer join egisadmin.dbo.usuario ua  on ua.cd_usuario               = pv.cd_usuario      
    left outer join egisadmin.dbo.usuario ui  on ui.cd_usuario               = @cd_usuario      
  
  
    
  where      
     pv.cd_pedido_venda = @cd_pedido_venda  
	 
---------------------------------------------------------------------------------------------------------	 
  --aqui 
  select 
		 
		 @cd_pedido   = PEDIDO_VENDA,
		 @dt_titulo      = CONVERT(VARCHAR(10),dt_pedido_venda, 103),
		 @nm_cliente  = nm_cd_cliente,
		 @nm_tranportadora = nm_transportadora,
		 @tipo_frete       = tipo_frete
		 
---------------------------------------------------------------------------------------------------------		 		 
		
 from #Pedido
   	

  --elect * from #Pedido
  
--------------------------------------------------------------------------------------------------------      
  select       
	identity(int,1,1) as cd_controle,

    pvi.cd_item_pedido_venda,      
    pvi.cd_pedido_venda,      
    p.nm_produto,      
   case when       
   isnull(fp.ic_espessura_proposta,'N') = 'N' then        
  cast(isnull(pvim.qt_largura,0)as varchar(10)) +      
  case when (isnull(fp.ic_comprimento,'N') = 'N' or isnull(pvim.qt_comprimento,0)=0) then      
    ' x ' + cast(isnull(pvim.qt_comprimento,0)as varchar(10))      
  else      
    ''      
  end      
  else      
     cast(isnull(pvim.qt_largura,0)as varchar(10))+' x '+      
     cast(isnull(pvim.qt_espessura,0)as varchar(10)) +      
     case when (isnull(fp.ic_comprimento,'N')= 'N' or isnull(pvim.qt_comprimento,0)=0) then      
    ' x ' + cast(isnull(pvim.qt_comprimento,0)as varchar(10))      
  else      
    ''      
  end      
  end                                                  as nm_medida_produto,      
      
    --dbo.fn_medida_produto(p.cd_produto,2)                   as nm_medida_produto,        
       
     pvi.qt_item_pedido_venda,
	pvi.vl_unitario_item_pedido,
    pvi.qt_liquido_item_pedido,
    um.sg_unidade_medida,      
    pvi.dt_entrega_vendas_pedido,  
    pvim.qt_volume     
      
  into      
    #minuta_item      
      
  from      
    pedido_venda_item pvi           with (nolock)        
    left outer join pedido_venda_item_medida pvim on pvim.cd_pedido_venda        = pvi.cd_pedido_venda      
                                                 and pvim.cd_item_pedido_venda   = pvi.cd_item_pedido_venda      
    left outer join produto p                     on p.cd_produto                = pvi.cd_produto      
    left outer join familia_produto fp            on fp.cd_familia_produto       = p.cd_familia_produto      
    left outer join unidade_medida um             on um.cd_unidade_medida        = p.cd_unidade_medida      
      
  where      
     pvi.cd_pedido_venda = @cd_pedido_venda      
         

 ------------------------------------------------------------------------------------------------------------------
  
 /*

 select      
    cd_item_pedido_venda     as Item,      
    nm_produto + ' (' + cast(qt_volume as varchar) + ')'  as Descricao,      
    nm_medida_produto           as LEC,      
    qt_item_pedido_venda        as Qtde, 
	vl_unitario_item_pedido as ValorUni,
	qt_liquido_item_pedido  as PesoLiq,
    sg_unidade_medida           as un,      
    dt_entrega_vendas_pedido    as DEntrega        
  from      
    #minuta_item      
  order by      
    cd_item_pedido_venda    
	
	select @vl_peso_liquedo_total = sum(qt_liquido_item_pedido)   from #minuta_item 
	select @vl_qt_item_total = sum(qt_item_pedido_venda)   from #minuta_item 
	*/
	------------------------------------------------------------------------------------------------
	select @vl_peso_liquedo_total = sum(qt_liquido_item_pedido)   from #minuta_item 
	select @vl_qt_item_total = sum(qt_item_pedido_venda)   from #minuta_item 

	select 
		 @cd_item         = cd_item_pedido_venda,
		 @nm_descricao    = nm_produto,
		 @nm_medida       = nm_medida_produto,
		 @vl_qt_item      = qt_item_pedido_venda,
		 @vl_unidade      = sg_unidade_medida,
		 @dt_entrega      = CONVERT(VARCHAR(10), dt_entrega_vendas_pedido, 103),
		 @vl_peso_liquedo = qt_liquido_item_pedido
         	
		
   from #minuta_item
   
	--------------------------------------------------------------------------------------------------------------------   



--------------------------------------------------------------------------------------------------------------------------
set @html_detalhe = 
    
	'
		<div style="margin: 6%;">
    <h2 class="section-title "style="display: flex; justify-content: center; align-items: center;">MINUTA</h2>
  <div  style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
    <p><STRONG>GUARUFILME IND. E COM. EMBALAGENS PLASTICAS EIRELI</STRONG></p>
    <p ><strong>Pedido: '+isnull(@cd_pedido,'')+'</strong></p>
  </div>  
    <table>
      <tr>
        <td><strong>DATA: '+isnull(@dt_titulo,'')+'</strong> </td>
        <td><strong>CLIENTE: </strong> '+isnull(@nm_cliente,'')+'</td>
        <td><strong>FRETE: </strong>'+isnull(@tipo_frete,'')+'</td>
      </tr>
	  </table>
	  <table>
      <tr>
        <td><strong>TRANSPORTADORA: </strong> '+isnull(@nm_tranportadora,'')+'</td>
      </tr>
    </table>
    <table>
      <thead>
        <tr>
          <th>ITEM</th>
          <th>DESCRIÇÃO</th>
          <th>LxExC</th>
          <th>QTD.</th>
          <th>UN.</th>
          <th>PESO LIQ.</th>
          <th>DATA ENTREGA</th>
          
        </tr>
      </thead>
	 
   '
   ---------------------------------------------------------------------------------------------------
  
  
 

 ------------------------------------------------------------------------------------------------------
  declare @id int = 0
	while exists ( select top 1 cd_controle from #minuta_item )
	begin

  select top 1
    @id = cd_controle,
      @html_detalhe = @html_detalhe + '
           <tbody>
            <tr> 					
            
            <td style="font-size:15px; text-align:center;width: 20px">'+cast(isnull(cd_item_pedido_venda,'') as varchar (20))+'</td>

			<td style="font-size:15px; text-align:center;width: 20px">'+isnull(nm_produto,'')+'</td>	

			<td style="font-size:15px; text-align:center;width: 20px">'+isnull(nm_medida_produto,'')+'</td>

			<td style="font-size:15px; text-align:center;width: 20px">'+cast(isnull(qt_item_pedido_venda,'') as varchar (20))+'</td>	

			<td style="font-size:15px; text-align:center;width: 20px">'+isnull(sg_unidade_medida,'')+'</td>	
			
			<td style="font-size:15px; text-align:center;width: 20px">'+cast(isnull(qt_liquido_item_pedido,0) as varchar (20))+'</td>
            
			<td style="font-size:15px; text-align:center;width: 20px">'+CONVERT(VARCHAR(10), dt_entrega_vendas_pedido, 103)+'</td>	
			
            </tr>
		
		 </tbody>
   '+@html_detalhe_1+'
	'
	
  from
    #minuta_item

  order by
    cd_controle

  
  delete from #minuta_item where cd_controle = @id

  
end

set @html_detalhe = @html_detalhe + '
	</table> 
'
-------------------------------------------------------------------------------------------------------------------
set @html_detalhe_1 =
'
<div class="section-title">
         <p style="font-size:18px; text-align:left;"><strong>Quantidade Total:'+cast(isnull(@vl_qt_item_total,0)as varchar(20))+' </strong></p>
         <p style="font-size:18px; text-align:left;"><strong>Valor Total do Peso Liquedo: '+cast(isnull(@vl_peso_liquedo_total,0) as varchar(20))+'</strong></p>
    </div>
	</div>
'


--HTML Completo--------------------------------------------------------------------------------------


set @html         = 
    @html_empresa +
    @html_titulo  +

	--@html_cab_det +
	 @html_detalhe +
	 @html_detalhe_1 +
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

exec pr_egis_relatorio_minuta_guarufilme 190,4253,0,131356,''

