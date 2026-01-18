IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_romaneio_embarque_nota_manifesto' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_romaneio_embarque_nota_manifesto

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_romaneio_embarque_nota_manifesto  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_romaneio_embarque_nota_manifesto
-------------------------------------------------------------------------------  
--GBS Global Business Solution Ltda                                        2025  
-------------------------------------------------------------------------------  
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020  
--  
--Autor(es)        : Joao Pedro Marcal  
--Banco de Dados   : Egissql - Banco do Cliente   
--  
--Objetivo         : Relatorio Padrao Egis HTML - EgisMob, EgisNet, Egis  
--Data             : 10.01.2025   
--Alteraï¿½ï¿½o        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_romaneio_embarque_nota_manifesto
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
--declare @dt_usuario             datetime = ''  
declare @cd_documento           int = 0  
--declare @cd_parametro           int = 0  
declare @dt_hoje                datetime  
declare @dt_inicial             datetime  
declare @dt_final               datetime  
declare @cd_ano                 int      
declare @cd_mes                 int      
declare @cd_dia                 int  
declare @cd_vendedor            int = 0   
declare @cd_grupo_relatorio     int = 0  
declare @cd_departamento        int = 0 
declare @cd_carga               int = 0  
  
--Dados do Relatï¿½rio---------------------------------------------------------------------------------  
  
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
   @cd_cnpj_cliente            varchar(30) = '',  
   @nm_razao_social_cliente    varchar(200) = '',  
   @nm_cidade_cliente          varchar(200) = '',  
   @sg_estado_cliente          varchar(5) = '',  
   @cd_numero_endereco         varchar(20) = '',  
   @nm_condicao_pagamento      varchar(100) = '',  
   @ds_relatorio               varchar(8000) = '',  
   @subtitulo                  varchar(40)   = '',  
   @footerTitle                varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais                    int = 0,  
   @nm_pais                    varchar(20) = '',  
   @cd_cnpj_empresa            varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet        varchar(200) = ''  
  
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
  select @cd_documento           = Valor from #json where campo = 'cd_documento_form'
  select @cd_carga               = Valor from #json where campo = 'cd_identificacao'
  select @cd_form                = Valor from #json where campo = 'cd_form'
  
   set @cd_carga = isnull(@cd_carga,0)
  
   if isnull(@cd_carga,0) = 0
   begin  

     select @cd_carga           = valor from #json where campo = 'cd_documento_form'  

   end  

  end
  
--set @cd_carga = 61

------------------

-------------------------------------------------------------------------------------------------  
declare @ic_processo char(1) = 'N'  
   
 --select @cd_relatorio  
   
select    
  @titulo             = nm_relatorio,    
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),    
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)    
from    
  egisadmin.dbo.Relatorio    
where    
  cd_relatorio = @cd_relatorio    
   
   
----------------------------------------------------------------------------------------------------------------------------  
--if @cd_form = 175
--begin
--  select    
--    @dt_inicial       = dt_inicial,    
--    @dt_final         = dt_final,
--    @cd_carga         = ISNULL(cd_carga,0)
--  from     
--    Parametro_Relatorio    
    
--  where    
--    cd_relatorio = @cd_relatorio    
--    and    
--    cd_usuario   = @cd_usuario    
--end
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
  @nm_fantasia_empresa     = isnull(e.nm_empresa,''),  
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
--Dados do Relatï¿½rio  
---------------------------------------------------------------------------------------------------------------------------------------------  
  
declare @html            nvarchar(max) = '' --Total  
declare @html_empresa    nvarchar(max) = '' --Cabeï¿½alho da Empresa  
declare @html_titulo     nvarchar(max) = '' --Tï¿½tulo  
declare @html_cab_det    nvarchar(max) = '' --Cabeï¿½alho do Detalhe  
declare @html_detalhe    nvarchar(max) = '' --Detalhes  
declare @html_rod_det    nvarchar(max) = '' --Rodapï¿½ do Detalhe  
declare @html_rodape     nvarchar(max) = '' --Rodape  
declare @html_geral      nvarchar(max) = '' --Geral  
declare @cd_controle     int           = 0  
declare @data_hora_atual nvarchar(50)  = ''  
  
set @html         = ''  
set @html_empresa = ''  
set @html_titulo  = ''  
set @html_cab_det = ''  
set @html_detalhe = ''  
set @html_rod_det = ''  
set @html_rodape  = ''  
set @html_geral   = ''  
  
  
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)  
  
  
----------------------------------------------------------------------------------------------------------------------  
  
  
SET @html_empresa = '  
<html>  
<head>  
    <meta charset="UTF-8">  
    <meta http-equiv="X-UA-Compatible" content="IE=edge">  
    <meta name="viewport" content="width=device-width, initial-scale=1.0">  
    <title >'+isnull(@titulo,'')+'</title>  
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
            margin-bottom: 3px;  
        }  
  
        table,  
        th,  
        td {  
            border: 1px solid #ddddddaa; 
			text-align: center;
        }  
  
        th,  
        td {  
            padding: 3px;  
        }  
  
        th {  
            background-color: #f2f2f2;  
            color: #333;  
            text-align: center;
			font-size: 12px;
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
        }  
  
        img {  
            max-width: 250px;  
            margin-right: 10px;  
        }  
   
        .title {  
            color: #000000;  
        }  
  
        .report-date-time {  
            text-align: right;   
            margin-top: 5px;  
        }  
  
        p { 
		    font-size: 14px;
            margin: 1px;  
            padding: 0;  
        }  
  
        .tamanho {  
            text-align: center; 
			font-size: 13px;
        }  

        @media print {
            p {
                margin-left: 20px;}

            .nao-quebrar {
        page-break-inside: avoid;
    }
            
        }
    </style>  
</head>  
<body> '  
  
  
--Procedure de Cada Relatï¿½rio-------------------------------------------------------------------------------------  
    
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
--select @cd_carga
------------------------------------------------------------------------------------------------------------
--set @dt_inicial = '02/01/2025'
--set @dt_final = '02/28/2025'

declare @nm_veiculo       nvarchar(60)
declare @vl_total         decimal(25,2) = 0.00
declare @qt_total         int = 0
declare @qt_total_produto decimal(25,2) = 0

--set @cd_carga = 4792

--SELECT TOP 1 @cd_carga = cd_identificacao
--FROM MDFE_Manifesto 
--WHERE cd_manifesto = @cd_carga
  select
    m.cd_manifesto,
	m.cd_identificacao,
	n.cd_vendedor,
	mdc.cd_minuta,
	i.cd_pedido_venda,
	i.cd_item_pedido_venda


   into #Minuta_Manifesto

   from
     MDFE_Manifesto M
     inner join MDFE_Manifesto_Documentos md   on md.cd_manifesto   = m.cd_manifesto
	 inner join minuta_despacho_composicao mdc on mdc.cd_nota_saida = md.cd_nota_saida
	 inner join nota_saida n                   on n.cd_nota_saida   = md.cd_nota_saida
	 inner join nota_saida_item i              on i.cd_nota_saida   = n.cd_nota_saida
   where
     m.cd_identificacao = @cd_carga

     --m.dt_manifesto between @dt_inicial and @dt_final

   group by
    m.cd_manifesto,
	m.cd_identificacao,
	n.cd_vendedor,
	mdc.cd_minuta,
	i.cd_pedido_venda,
	i.cd_item_pedido_venda



select
  identity(int,1,1)									     as cd_controle,  
  c.cd_carga                                             as cd_carga,  
  c.dt_carga, 
  c.dt_entrega_carga,  
  cli.nm_fantasia_cliente                                as nm_fantasia_cliente,
  cli.cd_cliente                                         as cd_cliente,   
  cli.nm_razao_social_cliente                            as nm_razao_social_cliente,
  cli.cd_cep                                             as cd_cep,
  UPPER(isnull(cli.nm_endereco_cliente,''))              as nm_endereco_cliente,
  UPPER(isnull(cli.cd_numero_endereco,''))               as cd_numero_endereco, 
  UPPER(isnull(cli.nm_bairro,''))                        as nm_bairro,
  cli.cd_ddd									         as cd_ddd,
  cli.cd_telefone										 as cd_telefone,
  UPPER(isnull(cid.nm_cidade,''))    					 as nm_cidade,
  UPPER(isnull(cli.nm_complemento_endereco,''))	  	     as nm_complemento_endereco,						
  UPPER(isnull(est.sg_estado,''))                        as sg_estado,
  v.cd_vendedor                                          as cd_vendedor,
  v.nm_fantasia_vendedor                                 as nm_fantasia_vendedor,
  tp.cd_tipo_pedido									     as cd_tipo_pedido,
  max(tp.nm_titulo_tipo_pedido)							 as nm_tipo_pedido,
  max(pv.qt_bruto_pedido_venda)                          as qt_bruto_pedido_venda,
  max(pv.qt_liquido_pedido_venda)                        as qt_liquido_pedido_venda,
  max(cast('' as varchar(25)))                           as nm_lote_produto, 
  max(UPPER(cp.nm_condicao_pagamento))                   as nm_condicao_pagamento,
  max(UPPER(fp.nm_forma_pagamento))                      as nm_forma_pagamento,
  max(ns.cd_identificacao_nota_saida)                    as cd_identificacao_nota_saida,
  max(snf.nm_serie_nota_fiscal)                          as nm_serie_nota_fiscal,
  isnull(it.nm_itinerario,'')                            as nm_itinerario,
  isnull(ve.nm_veiculo,'')                               as nm_veiculo,
  isnull(en.cd_placa_entregador,'')                      as cd_placa_entregador,
  isnull(en.nm_entregador,'')                            as nm_entregado,
  isnull(it.nm_obs_itinerario,'')                        as nm_obs_itinerario,
  max(ns.vl_total)                                       as vl_total_ns,
  max(pvi.qt_item_pedido_venda)                          as qt_item_pedido_venda,
  max(tp.cd_empresa_faturamento)                         as cd_empresa_faturamento,
  max(isnull(snf.ic_nfe_serie_nota,'N'))                 as ic_nfe_serie_nota,
  mm.cd_manifesto
  
into  
  #DetalheAtriGrid 
  
from  
  Pedido_Venda_Romaneio r  
  inner join pedido_venda pv                  on pv.cd_pedido_venda       = r.cd_pedido_venda 
  left outer join cliente cli                 on cli.cd_cliente           = pv.cd_cliente
  left outer join cidade cid                  on cid.cd_pais              = cli.cd_pais  
                                              and cid.cd_estado           = cli.cd_estado    
                                              and cid.cd_cidade           = cli.cd_cidade    
  left outer join estado est                  on est.cd_estado            = cid.cd_estado
  left outer join nota_saida ns               on ns.cd_pedido_venda       = pv.cd_pedido_venda
                                             and cd_status_nota           = 5
  left outer join Serie_Nota_Fiscal snf       on snf.cd_serie_nota_fiscal = ns.cd_serie_nota
  inner join Vendedor v                       on v.cd_vendedor            = pv.cd_vendedor
  inner join tipo_pedido tp                   on tp.cd_tipo_pedido        = pv.cd_tipo_pedido
  left outer join pedido_venda_item pvi       on pvi.cd_pedido_venda      = pv.cd_pedido_venda
  inner join Preparacao_Carga c               on c.cd_carga               = r.cd_carga   
  left outer join Itinerario it               on it.cd_itinerario         = c.cd_itinerario
  left outer join Entregador en               on en.cd_entregador         = c.cd_entregador
  left outer join Motorista mo                on mo.cd_motorista          = c.cd_motorista
  left outer join Veiculo ve                  on ve.cd_veiculo            = c.cd_veiculo
  inner join #Minuta_Manifesto mm             on mm.cd_pedido_venda       = r.cd_pedido_venda and mm.cd_item_pedido_venda = pvi.cd_item_pedido_venda
  left outer join condicao_pagamento cp       on cp.cd_condicao_pagamento = pv.cd_condicao_pagamento
  left outer join forma_pagamento fp          on fp.cd_forma_pagamento    = pv.cd_forma_pagamento
where  
  mm.cd_identificacao = @cd_carga
  and
  pvi.dt_cancelamento_item is null

group by  
  c.cd_carga,  
  c.dt_carga,  
  c.dt_entrega_carga,  
  tp.cd_tipo_pedido,
  it.nm_itinerario,
  ve.nm_veiculo,
  en.nm_entregador,
  cli.nm_fantasia_cliente,
  v.nm_fantasia_vendedor,
  v.cd_vendedor,
  it.nm_obs_itinerario,
  en.cd_placa_entregador,
  cli.cd_cliente,
  cli.nm_razao_social_cliente,
  cli.cd_cep,
  cli.nm_endereco_cliente,
  cli.cd_numero_endereco,
  cli.nm_bairro,
  cli.cd_ddd,
  cli.cd_telefone,
  est.sg_estado,
  cid.nm_cidade,
  cli.nm_complemento_endereco,
  r.cd_pedido_venda,
  mm.cd_manifesto


order by  
  est.sg_estado,
  cid.nm_cidade,
  cli.cd_cep

  --cli.cd_cliente

--------------------------------------------------------------------------------------------------------------------------	
	
declare 
	@id                      int = 0,
	@cd_tipo_pedido          int = 0, 
	@cd_carga_rel            int = 0,
	@nm_fantasia_cliente     nvarchar(60),
	@vl_total_geral          float = 0,
	@cd_vendedor_rel         int = 0,
	@nm_vendedor_rel         nvarchar(60),
	@nm_motorista		     nvarchar(60),
	@qt_total__geral_cx      float = 0,
	@vl_total_geral_liq      float =0,
	@vl_total_geral_brut     float =0,
	@qt_total_prod           float = 0,
	@nm_obs			         nvarchar(200),
	@qt_entega               int = 0,
    @qt_nota                 int = 0,
	@nm_itinerario           nvarchar(60),
	@cd_placa_entregador     nvarchar(10),
	@qt_item_pedido_venda_tt float = 0
--------------------------------------------------------------------------------------------------------------------------  


select  
  @cd_carga_rel          = cd_carga,
  @nm_fantasia_cliente   = nm_fantasia_cliente, 
  @cd_vendedor_rel       = cd_vendedor,
  @nm_motorista          = nm_entregado,
  @nm_vendedor_rel       = nm_fantasia_vendedor,
  @nm_obs                = nm_obs_itinerario,
  @nm_itinerario         = nm_itinerario,
  @cd_placa_entregador   = cd_placa_entregador,
  @nm_veiculo            = REPLACE(nm_veiculo,'Placa:','')
from  
  #DetalheAtriGrid 
  
  declare @vl_total_exp_icms_st float = 0
  select 
    @qt_entega                  = COUNT(cd_cliente),
	@vl_total_geral_liq         = sum(qt_liquido_pedido_venda),
	@vl_total_geral_brut        = sum(qt_bruto_pedido_venda),
	@qt_item_pedido_venda_tt    = sum(qt_item_pedido_venda),
	@vl_total_exp_icms_st       = sum(vl_total_ns)
  from #DetalheAtriGrid

  --select
  --  @qt_nota = COUNT(cd_cliente)
  --from 
  --  #DetalheAtriGrid
  --where
  --  cd_empresa_faturamento in (1,3)

  select   
    @qt_nota = COUNT(cd_cliente) 
  from 
    #DetalheAtriGrid
  where
    ic_nfe_serie_nota = 'S'


--------------------------------------------------------------------------------------------------------------------------
set @html_geral = ' 
            <p class="title"><b>'+isnull(@nm_fantasia_empresa,'')+'</b></p>                          						
		 <p style="text-align: center;font-size: 15px;" > <b>Romaneio de Embarque Manifesto: '+CAST(ISNULL(@cd_carga,0) AS nvarchar(20))+'</b></p>
		<div style="display: flex; justify-content: space-between; width: 100%;">
			 <p><strong>Vendedor:</strong> '+CAST(ISNULL(@cd_vendedor_rel,0) AS nvarchar(20))+' '+isnull(@nm_vendedor_rel,'')+'</p>   
			 <p><strong>Motorista:</strong> '+isnull(@nm_motorista,'')+'</p>  
			 <p><strong>Placa:</strong> '+isnull(@nm_veiculo,'')+'</p>  
		</div>
		<div>
			 <p><strong>Observações: </strong>'+isnull(@nm_obs,'')+'</p>
		</div>
	    <div style="display: flex; justify-content: space-between; width: 20%;">
			 <p><strong>Total de Entregas: </strong>'+CAST(ISNULL(@qt_entega,0) AS nvarchar(20))+'</p>    
			 <p><strong>'+isnull(@nm_itinerario,'')+'</strong></p>
		</div>
		'

-----------------------------------------------------------------------------------------------------------------------------------------
--Agrupamento
--------------

select
  identity(int,1,1) as cd_controle,
  sg_estado,
  nm_cidade,
  COUNT(*) as qt_entrega


into
  #Agrupamento

from
  #DetalheAtriGrid

group by
 sg_estado,
 nm_cidade

order by
  sg_estado,
  nm_cidade

--select * from #Agrupamento
--select * from #DetalheAtriGrid
--select * from Parametro_Relatorio where cd_relatorio = 285

--select * from EGISADMIN.dbo.Relatorio where cd_relatorio = 264
--#DetalheAtriGrid --287/285

  --aqui

  declare @sg_estado_agrupamento varchar(2)  = ''
  declare @nm_cidade_agrupamento varchar(80) = ''
  declare @qt_total_agrupamento  int         = 0

  while exists( select top 1 cd_controle from #Agrupamento)
  begin
    select top 1 
	  @cd_controle           = cd_controle,
	  @sg_estado_agrupamento = sg_estado,
	  @nm_cidade_agrupamento = nm_cidade,
	  @qt_total_agrupamento  = qt_entrega
	  	  
    from
	  #Agrupamento
    
    order by
	  sg_estado,
	  nm_cidade

    set @html_cab_det = @html_cab_det + '	
        	 <div class="nao-quebrar">
        	  <table style="width: 100%;">
        		<tr class="tamanho" style="display: flex; flex-direction: column;color: #000000;border: 1px solid #000000aa;">
        		   <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
        		    <p style="width: 3%;">'+CAST(@sg_estado_agrupamento AS nvarchar(20))+' </p>	
        			<p style="width: 49%;text-align: left;">'+ISNULL(@nm_cidade_agrupamento,'')+'</p>' 
					+
					'<p style="width: 32%;text-align: left;"> Entregas: '+cast(ISNULL(@qt_total_agrupamento,'') as varchar(6)) +'</p>'
        			+'</td> 
        		   </div>
        	    </tr>
        		</table>
        		</div>'
 	     
            ---DETALHE POR ESTADO/CIDADE
			
            while exists ( select top 1 cd_controle from #DetalheAtriGrid where sg_estado = @sg_estado_agrupamento and nm_cidade = @nm_cidade_agrupamento )
            begin
        
              select top 1
              
              @id           = cd_controle,
              @html_cab_det = @html_cab_det + '	
        	 <div class="nao-quebrar">
        	  <table style="width: 100%;">
        		<tr class="tamanho" style="display: flex; flex-direction: column;color: #000000;border: 1px solid #000000aa;">
        		   <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
        		    <p style="width: 3%;">'+CAST(ISNULL(cd_cliente,0) AS nvarchar(20))+' </p>	
        			<p style="width: 49%;text-align: left;">'+ISNULL(nm_razao_social_cliente,'')+'</p>
        			<p style="width: 32%;text-align: left;">'+ISNULL(nm_fantasia_cliente,'')+'</p>
        			<p style="width: 16%;">'+CAST(ISNULL(cd_ddd,'') AS nvarchar(20))+' '+CAST(ISNULL(cd_telefone,'') AS nvarchar(20))+'</td> 
        		   </div>
        			<div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
        		       <p style="width: 4%;">'+CAST(ISNULL(cd_identificacao_nota_saida,0) AS nvarchar(20))+' </p>
        			   <p style="width: 34%;">'+CAST(ISNULL(nm_serie_nota_fiscal,'') AS nvarchar(20))+' </p>
                       <p style="width: 23%;">'+ISNULL(nm_condicao_pagamento,'')+' </p>
        			   <p style="width: 39%;">'+CAST(ISNULL(nm_forma_pagamento,'') AS nvarchar(50))+' </p>
        			</div>  
        			<p class="tamanho" style="text-align: left;width: 100%;"><b>END: '+
        			case when ISNULL(nm_endereco_cliente,'') <> ''     then ''   +CAST(ISNULL(nm_endereco_cliente,'') AS nvarchar(20))+''else '' end+' '+ 
        			case when ISNULL(cd_numero_endereco,'') <> ''      then ' - '+CAST(ISNULL(cd_numero_endereco,'') AS nvarchar(20))+'' else '' end+' '+
        			case when ISNULL(nm_bairro,'') <> ''               then ' - '+ISNULL(nm_bairro,'')+'' else '' end+' '+
        			case when isnull(cd_cep,'') <> ''                  then ' - '+CAST(ISNULL(dbo.fn_formata_cep(cd_cep),'') AS nvarchar(20))+'' else '' end +' '+
        			case when ISNULL(nm_complemento_endereco,'') <> '' then ' - '+ISNULL(nm_complemento_endereco,'')+'' else '' end +' '+ 
        			case when ISNULL(sg_estado,'')<>''                 then ' - '+ISNULL(sg_estado,'')+'' else '' end+' '+
        			case when ISNULL(nm_cidade,'') <> ''               then '/ ' +ISNULL(nm_cidade,'')+'' else '' end 
        			+'</b></p>		   
        	</tr>
        		</table>
        		</div>'
        	 from
               #DetalheAtriGrid
             where			   
	          sg_estado = @sg_estado_agrupamento and nm_cidade = @nm_cidade_agrupamento

           order by
               sg_estado, nm_cidade, cd_cep
        
        
          delete from #DetalheAtriGrid
          where
            cd_controle = @id
        
         end
        	
   delete from #Agrupamento
   where
     cd_controle = @cd_controle

  end

--------------------------------------------------------------------------------------------------------------------  
  
  
  
set @html_rodape ='
    <table style="width: 100%;">  
        <tr>  
            <td style="display: flex; flex-direction: column; gap: 20px;">  
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">  
                    <div style="text-align: left;">  
                        <p><strong>Total de Entregas:</strong> '+CAST(ISNULL(@qt_entega,0) AS nvarchar(20))+'</p>   
                    </div>  
                    <div style="text-align: left;">    
                        <p><strong>Total de Notas:</strong> '+CAST(ISNULL(@qt_nota,0) AS nvarchar(20))+'</p>     
                    </div>
                    <div style="text-align: right;">  
                        <p><strong>Itens:</strong> '+cast(isnull(@qt_item_pedido_venda_tt,0)as nvarchar(20))+'</p>  
                    </div>       
                    <div style="text-align: right;">  
                        <p><strong>Peso Lí­quido:</strong> '+cast(isnull(dbo.fn_formata_valor(@vl_total_geral_liq),0)as nvarchar(20))+' </p>  
                    </div>
					<div style="text-align: right;">  
                        <p><strong>Peso Bruto:</strong> '+cast(isnull(dbo.fn_formata_valor(@vl_total_geral_brut),0)as nvarchar(20))+' </p>  
                    </div>
					<div style="text-align: right;">  
                        <p><strong>Valor Total:</strong> '+CAST(ISNULL(dbo.fn_formata_valor(@vl_total_exp_icms_st),0) AS nvarchar(20))+' </p>  
                    </div>
                </div>  
            </td>  
        </tr>  
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
   
-------------------------------------------------------------------------------------------------------------------------------------------------------  
select isnull(@html,'') as RelatorioHTML  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
 
  
    go

  
--exec pr_egis_relatorio_romaneio_embarque_nota_manifesto 285,0,''




