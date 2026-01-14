IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_romaneio_fechamento_caixa' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_romaneio_fechamento_caixa

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_romaneio_fechamento_caixa  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_romaneio_fechamento_caixa
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
--Alteraï¿½ï¿½o        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_romaneio_fechamento_caixa
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
--declare @cd_relatorio           int = 0  
  
--Dados do Relatï¿½rio---------------------------------------------------------------------------------  
  
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
  
  
   set @cd_documento = isnull(@cd_documento,0)  
  
   if @cd_documento = 0  
   begin  
     select @cd_documento           = valor from #json where campo = 'cd_documento'  
  
   end  
end  
  
  
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
select    
  @dt_inicial       = dt_inicial,    
  @dt_final         = dt_final  
from     
  Parametro_Relatorio    
    
where    
  cd_relatorio = @cd_relatorio    
  and    
  cd_usuario   = @cd_usuario    
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
    margin-left: 20px;
    text-align: left;
    font-size: 12px;
  }
  .rodape{
	margin-top: 30px;		
  }
	

  .nao-quebrar {
    page-break-inside: avoid;
  }

  .quebraVendedor:first-child {
    page-break-before: always; 
  }

  .quebraVendedor:not(:first-child) {
    page-break-after: always;
  }

      .ultimaDiv:first-child {
        page-break-before: always;
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
------------------------------------------------------------------------------------------------------------
--set @dt_inicial = '02/01/2025'
--set @dt_final = '02/28/2025'
declare @nm_veiculo nvarchar(60)
declare @vl_total         decimal(25,2) = 0.00
declare @qt_total         int = 0
declare @qt_total_produto decimal(25,2) = 0
declare @cd_carga         int = 0
--set @cd_documento = 287

--select top 1 @cd_carga = cd_carga from pedido_venda_romaneio where cd_pedido_venda = @cd_documento
select
  identity(int,1,1)									     as cd_controle,  
  c.cd_carga                                             as cd_carga,  
  c.dt_carga, 
  c.dt_entrega_carga,  
  pv.dt_pedido_venda                                     as dt_pedido_venda,
  cli.nm_fantasia_cliente                                as nm_fantasia_cliente,
  cli.cd_cliente                                         as cd_cliente,   
  cli.nm_razao_social_cliente                            as nm_razao_social_cliente,
  cli.cd_cep                                             as cd_cep,
  UPPER(cli.nm_endereco_cliente)                         as nm_endereco_cliente,
  UPPER(cli.cd_numero_endereco)                          as cd_numero_endereco, 
  UPPER(cli.nm_bairro)                                   as nm_bairro,
  cli.cd_ddd									         as cd_ddd,
  cli.cd_telefone										 as cd_telefone,
  UPPER(cid.nm_cidade)       							 as nm_cidade,
  UPPER(cli.nm_complemento_endereco)					 as nm_complemento_endereco,
  UPPER(est.sg_estado)                                   as sg_estado,
  v.cd_vendedor                                          as cd_vendedor,
  v.nm_fantasia_vendedor                                 as nm_fantasia_vendedor,
  tp.cd_tipo_pedido									     as cd_tipo_pedido,
  max(tp.nm_titulo_tipo_pedido)							 as nm_tipo_pedido,
  max(tp.sg_tipo_pedido)								 as sg_tipo_pedido,
  max(pv.qt_bruto_pedido_venda)                          as qt_bruto_pedido_venda,
  max(pv.qt_liquido_pedido_venda)                        as qt_liquido_pedido_venda,
  max(cast('' as varchar(25)))                           as nm_lote_produto, 
  max(UPPER(cp.nm_condicao_pagamento))                   as nm_condicao_pagamento,
  max(UPPER(cp.sg_condicao_pagamento))                   as sg_condicao_pagamento,
  max(UPPER(fp.nm_forma_pagamento))                      as nm_forma_pagamento,
  max(ns.cd_identificacao_nota_saida)                    as cd_identificacao_nota_saida,
  max(snf.nm_serie_nota_fiscal)                          as nm_serie_nota_fiscal,
  isnull(it.nm_itinerario,'')                            as nm_itinerario,
  isnull(ve.nm_veiculo,'')                               as nm_veiculo,
  max(ve.cd_placa_veiculo)							     as cd_placa_veiculo,
  isnull(en.cd_placa_entregador,'')                      as cd_placa_entregador,
  isnull(en.nm_entregador,'')                            as nm_entregado,
  isnull(it.nm_obs_itinerario,'')                        as nm_obs_itinerario,
  max(pvi.qt_item_pedido_venda)                          as qt_item_pedido_venda,
  max(ns.qt_peso_bruto_nota_saida)						 as qt_peso_bruto_nota_saida,
  isnull(max(ns.vl_ipi),0)                               as vl_ipi,
  isnull(max(ns.vl_icms_subst),0)                        as vl_icms_subst,
  max(pvi.vl_unitario_item_pedido) * max(pvi.qt_item_pedido_venda) as vl_total,
  isnull(max(ns.vl_total),0)                             as vl_total_ns,
  isnull(MAX(ns.vl_produto),0)                           as vl_produto,
  max(isnull(snf.ic_nfe_serie_nota,'N'))                 as ic_nfe_serie_nota
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
  left outer join Veiculo ve                  on ve.cd_veiculo            = c.cd_veiculo
  left outer join condicao_pagamento cp       on cp.cd_condicao_pagamento = pv.cd_condicao_pagamento
  left outer join forma_pagamento fp          on fp.cd_forma_pagamento    = pv.cd_forma_pagamento

  --select * from carga
  --use egissql_342
  --
where  
  r.cd_carga = @cd_documento
  and pvi.dt_cancelamento_item is null
 
  --select * from Pedido_Venda_Romaneio
  --Neste trecho aqui tem que tratar a devoluÃ§Ã£o-------------------------------------------------------------------
  --and
  --isnull(ns.cd_nota_saida,0) > 0
  -----------------------------------------------------------------------------------------------------------------


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
  pv.dt_pedido_venda,
  r.cd_pedido_venda


order by  
  cli.cd_cliente,  
  est.sg_estado,
  cid.nm_cidade,
  cli.cd_cep
  
  --select * from #DetalheAtriGrid
  --return
--------------------------------------------------------------------------------------------------------------------------	
	
declare 					           
	@id                                int = 0,
	@cd_carga_rel                      int = 0,
	@nm_fantasia_cliente               nvarchar(60),
	@cd_vendedor_rel                   int = 0,
	@nm_vendedor_rel                   nvarchar(60),
	@nm_motorista		               nvarchar(60),
	@nm_obs			                   nvarchar(200),
	@qt_entega                         int = 0,
	@nm_itinerario                     nvarchar(60),
	@cd_placa_entregador               nvarchar(10),
    @qt_total_notas                    int = 0,
    @qt_total_carga                    int = 0,
	@vl_peso_total_carga               float = 0, 
	@vl_total_exp                      float = 0,
	@vl_total_IcmsSt                   float = 0,
	@vl_total_exp_icms_st              float = 0, 
	@vl_bonificacao_troca              float = 0,
	@vl_total_boni_troca               float = 0,
	@qt_total_notas_vendedor           int = 0,
	@qt_total_carga_vendedor           int = 0,
	@vl_peso_total_carga_vendedor      float = 0,
	@vl_total_exp_vendedor             float = 0,
	@vl_total_IcmsSt_vendedor          float = 0,
	@vl_total_exp_icms_st_vendedor     float = 0,
	@vl_bonificacao_troca_vendedor     float = 0,
	@vl_total_boni_troca_vendedor      float = 0,
	@qt_vendedor                       int  = 0

  select 
		@vl_bonificacao_troca = sum(vl_total_ns)
  from 
	#DetalheAtriGrid 
  where 
    cd_tipo_pedido in (8,21,23,26,27,28)



  select 
    @qt_total_carga             = COUNT(cd_identificacao_nota_saida),
	@vl_peso_total_carga        = sum(qt_peso_bruto_nota_saida),
	@vl_total_exp               = sum(vl_produto),
	@vl_total_IcmsSt            = sum(vl_icms_subst + vl_ipi),
	@vl_total_exp_icms_st       = sum(vl_total_ns),   
	@vl_total_boni_troca        = isnull(@vl_total_exp_icms_st,0) - isnull(@vl_bonificacao_troca,0)
  from #DetalheAtriGrid

--------------------------------------------------------------------------------------------------------------------------  
 select 
	identity(int,1,1)                  as cd_controle,
	cd_vendedor                        as cd_vendedor,
	COUNT(cd_identificacao_nota_saida) as qt_peso_total_ns,
	 (select count(distinct cd_vendedor) from #DetalheAtriGrid) as qt_vendedor,
	sum(qt_peso_bruto_nota_saida)      as qt_peso_bruto_nota_saida,
	sum(vl_produto)                    as vl_produto,
	sum(vl_icms_subst + vl_ipi)        as vl_total,
	sum(vl_total_ns)                   as vl_total_ns,  
	sum(CASE WHEN isnull(ic_nfe_serie_nota,'') = 'S' THEN 1 ELSE 0 END) AS total_notas,
	nm_fantasia_vendedor               as nm_fantasia_vendedor
  into
	#Vendedor
 from 
	#DetalheAtriGrid
 group by 
	cd_vendedor,
	nm_fantasia_vendedor

	--select * from #Vendedor
 select  
    @cd_carga_rel          = cd_carga,
    @nm_fantasia_cliente   = nm_fantasia_cliente, 
    @cd_vendedor_rel       = cd_vendedor,
    @nm_motorista          = nm_entregado,
    @nm_vendedor_rel       = nm_fantasia_vendedor,
    @nm_obs                = nm_obs_itinerario,
    @nm_itinerario         = nm_itinerario,
    @cd_placa_entregador   = cd_placa_veiculo,
    @nm_veiculo            = REPLACE(nm_veiculo,'Placa:','')
  from  
    #DetalheAtriGrid  


  select   
    @qt_total_notas             = COUNT(cd_identificacao_nota_saida) 
  from 
    #DetalheAtriGrid
  where
    ic_nfe_serie_nota = 'S'
	declare @tt int = 0 
	select top 1
		@tt  = cd_vendedor
	from #Vendedor 
	order by cd_vendedor desc
	--select @tt
--------------------------------------------------------------------------------------------------------------------------
set @html_geral = ' '
declare @sub_id int = 0  
		
  while exists ( select top 1 cd_vendedor from #Vendedor )
  begin

  select top 1     
      @sub_id                        = cd_controle,
	  @cd_vendedor_rel               = cd_vendedor,
	  @nm_vendedor_rel               = nm_fantasia_vendedor,
	  @qt_vendedor                   = qt_vendedor,
	  @qt_total_notas_vendedor       = total_notas,
	  @qt_total_carga_vendedor       = qt_peso_total_ns,
	  @vl_peso_total_carga_vendedor  = qt_peso_bruto_nota_saida,
	  @vl_total_exp_vendedor         = vl_produto,
	  @vl_total_IcmsSt_vendedor      = vl_total,
	  @vl_total_exp_icms_st_vendedor = vl_total_ns
  from
      #Vendedor
  order by  
	  cd_vendedor
   
 set @html_cab_det = @html_cab_det + ' <p class="title" style="margin-top:20px;"><b>'+isnull(@nm_fantasia_empresa,'')+'</b></p>                          						
		 <p style="text-align: center;font-size: 15px;" > <b>Romaneio de Fechamento de Caixa: '+CAST(ISNULL(@cd_carga_rel,0) AS nvarchar(20))+'</b></p>
		<div '+case when isnull(@tt,0) = @cd_vendedor_rel then 'class="ultimaDiv"' else 'class="quebraVendedor"' end+'> 
		<div style="display: flex; justify-content: space-between; width: 100%;">
			 <p><strong>Vendedor:</strong> '+CAST(ISNULL(@cd_vendedor_rel,0) AS nvarchar(20))+' '+isnull(@nm_vendedor_rel,'')+'</p>   
			 <p><strong>Motorista:</strong> '+isnull(@nm_motorista,'')+'</p>  
			 <p><strong>Placa:</strong> '+isnull(@cd_placa_entregador,'')+'</p>  
		</div>
		<div>
			 <p><strong>Observações: </strong>'+isnull(@nm_obs,'')+'</p>
		</div>
		 <div>
			<div class="linha">
	    		  <tr class="tamanho" style="display: flex; flex-direction: column;color: #000000;">
						<div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
							<p class="tamanho" style="width:8%"><b>DATA</b></p>
							<p class="tamanho" style="width:4%"><b>CLIENTE</b></p>
							<p class="tamanho" style="width:36%"><b>NOME FANTASIA</b></p>
							<p class="tamanho" style="width:9%"><b>NFE</b></p>
							<p class="tamanho" style="width:8%"><b>TIPO</b></p>
							<p class="tamanho" style="width:12%"><b>COND.PAG</b></p>
							<p class="tamanho" style="width:15%"><b>MUNICIPIO</b></p>
							<p class="tamanho" style="width:8%"><b>VALOR</b></p>
						 </div>	
						</tr>
					</div>
				</div>'

-----------------------------------------------------------------------------------------------------------------------------------------

  while exists ( select top 1 cd_controle from #DetalheAtriGrid where @cd_vendedor_rel = cd_vendedor)
  begin

    select top 1
      
      @id           = cd_controle,
      @html_cab_det = @html_cab_det + '	
	 <table class="nao-quebrar">
	  <table style="width: 100%;">
		<tr class="tamanho" style="display: flex; flex-direction: column;color: #000000;border: 1px solid #000000aa;">
		   <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
		    <p style="width: 8%;text-align:left;">'+ISNULL(dbo.fn_data_string(dt_pedido_venda),'')+'</p>
		    <p style="width: 4%;text-align:left;">'+CAST(ISNULL(cd_cliente,0) AS nvarchar(20))+'</p>	
			<p style="width: 36%;text-align:left;">'+ISNULL(nm_fantasia_cliente,'')+'</p>
			<p style="width: 9%;text-align:left;">'+CAST(ISNULL(cd_identificacao_nota_saida,'') AS nvarchar(20))
			+
			
			--case when isnull(cd_nota_saida,0) = 0 then ' * NÃ£o Faturado * ' else cast('' as char(1)) end
			

			--+
			'</p> 
			<p style="width: 12%;text-align:left;">'+ISNULL(sg_tipo_pedido,'')+'</p>
			<p style="width: 10%;text-align:left;">'+ISNULL(sg_condicao_pagamento,'')+'</p>
			<p style="width: 13%;text-align:left;font-size:11px;">'+ISNULL(nm_cidade,'')+'/'+ISNULL(sg_estado,'')+'</p>
			<p style="width: 8%;text-align:left;">'+CAST(ISNULL(dbo.fn_formata_valor(/*vl_produto*/vl_total_ns),0) AS nvarchar(20))+'</p>	
		</div>
	</tr>
	 </table>
	  </table>
'

	 from
       #DetalheAtriGrid
     where
	   @cd_vendedor_rel  = cd_vendedor
	 order by  
	   cd_cliente
   

  delete from #DetalheAtriGrid
  where
    cd_controle = @id

 end	

 set @html_cab_det = @html_cab_det + '
	'+case when isnull(@qt_vendedor,0) > 1 then '
   <table style="width: 100%; margin-top:15px;">  
        <tr>  
            <td style="display: flex; flex-direction: column; gap: 20px;">  
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">  
                    <div style="text-align: left;">  
                        <p><strong>Quantidade de Entregas :</strong> '+CAST(ISNULL(@qt_total_carga_vendedor,0) AS nvarchar(20))+' </p>   
                        <p><strong>Total de Notas :</strong> '+CAST(ISNULL(@qt_total_notas_vendedor,0) AS nvarchar(20))+' </p> 
                        <p><strong>Peso Total da Carga :</strong> '+CAST(ISNULL(dbo.fn_formata_valor(@vl_peso_total_carga_vendedor),0) AS nvarchar(20))+'</p> 
                    </div>  
                    <div style="text-align: right;">  
                        <p><strong>Valor Total da Expedição :</strong> '+CAST(ISNULL(dbo.fn_formata_valor(@vl_total_exp_vendedor),0) AS nvarchar(20))+'</p>  
                        <p><strong>Valor Total IPI + ICMS ST Cobrado :</strong> '+CAST(ISNULL(dbo.fn_formata_valor(@vl_total_IcmsSt_vendedor),0) AS nvarchar(20))+'</p>  
                        <p><strong>Valor Total da Expedição + ICMS ST :</strong> '+CAST(ISNULL(dbo.fn_formata_valor(@vl_total_exp_icms_st_vendedor),0) AS nvarchar(20))+'</p>  
                    </div>
                </div>  
            </td>  
        </tr>  
    </table>
	</div>'
	else '' end 
	
	  delete from #Vendedor
      where
	   @cd_vendedor_rel  = cd_vendedor
	 

 end	

--------------------------------------------------------------------------------------------------------------------  
  
  
  
  
set @html_rodape ='

    <table class="rodape" style="width: 100%;border: 3px solid #000000aa;">  
        <tr>  
            <td style="display: flex; flex-direction: column; gap: 20px;">  
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">  
                    <div style="text-align: left;">  
                        <p><strong>Quantidade de Entregas :</strong> '+CAST(ISNULL(@qt_total_carga,0) AS nvarchar(20))+' </p>   
                        <p><strong>Total de Notas :</strong> '+CAST(ISNULL(@qt_total_notas,0) AS nvarchar(20))+' </p> 
						 <p><strong>Peso Total da Carga :</strong> '+CAST(ISNULL(dbo.fn_formata_valor(@vl_peso_total_carga),0) AS nvarchar(20))+'</p> 
                    </div>  
                    <div style="text-align: right;">  
                        <p><strong>Valor Total da Expedição :</strong> '+CAST(ISNULL(dbo.fn_formata_valor(@vl_total_exp),0) AS nvarchar(20))+'</p>  
						<p><strong>Valor Total IPI + ICMS ST Cobrado :</strong> '+CAST(ISNULL(dbo.fn_formata_valor(@vl_total_IcmsSt),0) AS nvarchar(20))+'</p>  
                        <p><strong>Valor Total da Expedição + ICMS ST :</strong> '+CAST(ISNULL(dbo.fn_formata_valor(@vl_total_exp_icms_st),0) AS nvarchar(20))+'</p>  
						<p><strong>Bonificação/Troca :</strong> '+CAST(ISNULL(dbo.fn_formata_valor(@vl_bonificacao_troca),0) AS nvarchar(20))+'</p> 
						<p><strong>Valor Total - (Bonificação/Troca) :</strong> '+CAST(ISNULL(dbo.fn_formata_valor(@vl_total_boni_troca),0) AS nvarchar(20))+'</p>
                    </div>
                </div>  
            </td>  
        </tr>  
    </table>
	<div class="report-date-time">  
       <p style="text-align:right;margin-top:20px;">Gerado em: '+@data_hora_atual+'</p>  
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
  
--exec pr_egis_relatorio_romaneio_fechamento_caixa 264,0,''




