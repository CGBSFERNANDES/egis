IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_mapa_carteira_pedido' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_mapa_carteira_pedido

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_mapa_carteira_pedido  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_mapa_carteira_pedido
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
--Altera��o        :   
--  
--  
------------------------------------------------------------------------------  
create procedure pr_egis_relatorio_mapa_carteira_pedido 
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
declare @cd_vendedor            int = 0   
declare @cd_grupo_relatorio     int = 0  
declare @cd_cliente_grupo       int = 0 
declare @cd_tipo_pedido         int = 0 
declare @cd_cliente             int = 0

--Dados do Relat�rio---------------------------------------------------------------------------------  
  
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
   @nm_cidade_cliente          varchar(200) = '',  
   @sg_estado_cliente          varchar(5) = '',  
   @cd_numero_endereco         varchar(20) = '',  
   @ds_relatorio               varchar(8000) = '',  
   @subtitulo                  varchar(40)   = '',  
   @footerTitle                varchar(200)  = '',  
   @cd_numero_endereco_empresa varchar(20)   = '',  
   @cd_pais                    int = 0,  
   @nm_pais                    varchar(20) = '',  
   @cd_cnpj_empresa            varchar(60) = '',  
   @cd_inscestadual_empresa    varchar(100) = '',  
   @nm_dominio_internet        varchar(200) = '',
   @tipo_pedido                int = 0 
  
------------------------------------------------------------------------------------------------------  
  
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
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
  select @cd_tipo_pedido         = valor from #json where campo = 'cd_tipo_pedido'
  select @cd_cliente			 = valor from #json where campo = 'cd_cliente'
  select @cd_documento			 = valor from #json where campo = 'cd_documento_form'
  select @cd_cliente_grupo       = Valor from #json where campo = 'cd_grupo_cliente'
  
  
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
    @dt_final         = dt_final,
    @cd_vendedor      = isnull(cd_vendedor,''),
	@cd_tipo_pedido   = isnull(cd_tipo_pedido,''),
	@cd_cliente       = ISNULL(cd_cliente,'')
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
  @logo                       = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),  
  @nm_cor_empresa             = isnull(e.nm_cor_empresa,'#1976D2'),  
  @nm_endereco_empresa        = isnull(e.nm_endereco_empresa,''),  
  @cd_telefone_empresa        = isnull(e.cd_telefone_empresa,''),  
  @nm_email_internet          = isnull(e.nm_email_internet,''),  
  @nm_cidade                  = isnull(c.nm_cidade,''),  
  @sg_estado                  = isnull(es.sg_estado,''),  
  @nm_fantasia_empresa        = isnull(e.nm_fantasia_empresa,''),  
  @cd_cep_empresa             = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),  
  @cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),  
  @nm_pais					  = ltrim(rtrim(isnull(p.sg_pais,''))),  
  @cd_cnpj_empresa            = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),  
  @cd_inscestadual_empresa    =  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),  
  @nm_dominio_internet        =  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))  
        
 from egisadmin.dbo.empresa e with(nolock)  
 left outer join Estado es    with(nolock) on es.cd_estado = e.cd_estado  
 left outer join Cidade c     with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado  
 left outer join Pais p       with(nolock) on p.cd_pais    = e.cd_pais  
 where   
  cd_empresa = @cd_empresa  
  
  
---------------------------------------------------------------------------------------------------------------------------------------------  
--Dados do Relat�rio  
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
			text-align: center;
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
            font-size:10px;
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

--set @cd_cliente_grupo = 40
------------------------------------------------------------------------------------------------------------
--set @dt_inicial = '03/01/2025' 
--set @dt_final = '03/13/2025'
--select @cd_vendedor
 declare  
	---@cd_cliente_grupo int = 0, 
	@ic_todos_clientes char = 'S'

    
if @cd_empresa not in (329,340)
begin
  select    
    IDENTITY(Int,1,1)                                         as  cd_controle,    
    max(dbo.fn_data_string(pvi.dt_pedido_venda))                                   as Emissao,    
    pvi.cd_pedido_venda										   as cd_pedido_venda,    
    max(isnull(pvi.ic_entrega_futura,'N'))                     as ic_entrega_futura,    
    --max('N')                                                  as 'ic_entrega_futura',    
    max(c.nm_fantasia_cliente)                                as Cliente,    
    max(c.cd_cliente)                                         as cd_cliente, 
    ltrim(rtrim(isnull(max(c.nm_endereco_cliente),''))) + ','+ ltrim(rtrim(isnull(max(c.cd_numero_endereco),''))) + ' - ' +
    ltrim(rtrim(isnull(max(c.nm_bairro),''))) + ' - ' + ltrim(rtrim(isnull(max(ci.nm_cidade),''))) as 'nm_endereco_cliente',
    max(case when c.cd_tipo_pessoa = 1 then    
             dbo.fn_formata_cnpj(c.cd_cnpj_cliente)    
          else    
             dbo.fn_formata_cpf(c.cd_cnpj_cliente)    
          end)                                                as 'cd_cnpj_cliente',    
      
    max(c.nm_razao_social_cliente)                            as 'nm_razao_social_cliente',    
      
      
    max(dbo.fn_data_string(pvi.dt_entrega_vendas_pedido))                         as Entrega,    
    max(pvi.dt_entrega_fabrica_pedido)                        as 'Fabrica',    
    max(pvi.dt_reprog_item_pedido)                            as 'Reprogramacao',    
      
    case when sum(pvi.qt_item_pedido_venda)<>sum(pvi.qt_saldo_pedido_venda)    
    then    
     'Parcial'    
    else    
     'Total'    
    end                                                        as Tipo,    
      
    sum( (CAST(pvi.qt_item_pedido_venda AS DECIMAL(18,2))  * CAST(vl_unitario_item_pedido AS DECIMAL(18,2)))    
         +    
         (CAST(pvi.qt_item_pedido_venda AS DECIMAL(18,2))  * CAST(vl_unitario_item_pedido AS DECIMAL(18,2))) * ( isnull(cast(pvi.pc_ipi AS DECIMAL(18,2)),0)/100)      
       )                                                       as Total,    
      
     
    sum((CAST(pvi.qt_item_pedido_venda AS DECIMAL(18,2))  * CAST(vl_unitario_item_pedido AS DECIMAL(18,2)))) as Total_Liquido,    
      
    sum( (CAST(pvi.qt_saldo_pedido_venda AS DECIMAL(18,2)) * CAST(vl_unitario_item_pedido AS DECIMAL(18,2))  )  
         +    
         (CAST(pvi.qt_saldo_pedido_venda AS DECIMAL(18,2)) * CAST(vl_unitario_item_pedido AS DECIMAL(18,2)))* ( isnull(cast(pvi.pc_ipi AS DECIMAL(18,2)),0)/100)     
       )                                                       as Saldo,  
      
    max(cp.nm_condicao_pagamento)                              as 'Condicao_Pagamento',    
    max(v.nm_fantasia_vendedor)                                as 'Vendedor',    
    sum( (pvi.qt_item_pedido_venda  * vl_unitario_item_pedido)     
         * ( isnull(pvi.pc_ipi,0)/100)  )                      as 'Valor_IPI',    
        
    --Valor Pago no Contas a Receber    
    --select * from documento_receber_pagamento    
    
      isnull(( select    
        sum( isnull(cast(dp.vl_pagamento_documento as DECIMAL(18,2)) ,0) )    
      from    
        documento_receber_pagamento dp    
        inner join documento_receber d on d.cd_documento_receber = dp.cd_documento_receber     
      where    
        d.cd_pedido_venda = pvi.cd_pedido_venda ),0)             as Valor_Pago,   
     --Tipo de Pedido---------------------------------------------------------------------------------------    
     max(tp.nm_tipo_pedido)    as nm_tipo_pedido,    
     max(tp.sg_tipo_pedido)    as sg_tipo_pedido,    
     max(cg.nm_cliente_grupo)  as nm_cliente_grupo,    
     max(ra.nm_ramo_atividade) as nm_ramo_atividade,    
      
      
     sum(isnull(ac.vl_adiantamento,0)) as 'Valor Adiantamento',    
      
    max(  
    case when cast(pvi.dt_entrega_vendas_pedido as decimal(18,2)) < @dt_hoje then    
      pvi.vl_total_pedido_venda    
    else    
    ''    
    end)                     as Total_Atraso   
      
      
    --select * from pedido_venda_item    
      
  into    
    #MapaCarteiraPedido    
      
  from    
    --pedido_venda pv                         with (nolock)     
    --inner join pedido_venda_item pvi        with (nolock) on pvi.cd_pedido_venda      = pv.cd_pedido_venda    
    vw_venda_bi pvi  
    left outer join cliente            c    with (nolock) on c.cd_cliente             = pvi.cd_cliente    
    left outer join condicao_pagamento cp   with (nolock) on cp.cd_condicao_pagamento = pvi.cd_condicao_pagamento    
    left outer join vendedor           v    with (nolock) on v.cd_vendedor            = pvi.cd_vendedor    
    left outer join tipo_pedido tp          with (nolock) on tp.cd_tipo_pedido        = pvi.cd_tipo_pedido      
    left outer join cliente_grupo cg        with (nolock) on cg.cd_cliente_grupo      = c.cd_cliente_grupo    
    left outer join ramo_atividade ra       with (nolock) on ra.cd_ramo_atividade     = c.cd_ramo_atividade    
    left outer join Cliente_Adiantamento ac with (nolock) on ac.cd_pedido_venda       = pvi.cd_pedido_venda    
    left outer join Cidade               ci with (nolock) on ci.cd_cidade             = c.cd_cidade  
      
  where    
    --isnull(pv.ic_fechado_pedido,'N')='S'    
    --and    
    isnull(pvi.qt_saldo_pedido_venda,0)>0      
    and 
	pvi.dt_cancelamento_item is null    
    and 
	c.cd_cliente_grupo = case when isnull(@cd_cliente_grupo,0) > 0 then isnull(@cd_cliente_grupo,0) else c.cd_cliente_grupo end    
    and
	tp.cd_tipo_pedido = case when ISNULL(@cd_tipo_pedido,0) = 0 then tp.cd_tipo_pedido else ISNULL(@cd_tipo_pedido,0) end 
	and
	isnull(cg.ic_mapa_carteira_apsnet,'N') = case when @ic_todos_clientes = 'S' then isnull(cg.ic_mapa_carteira_apsnet,'N') else 'S' end  
    
  group by    
    pvi.cd_pedido_venda  
    --,ac.vl_adiantamento,dt_entrega_vendas_pedido,vl_total_pedido_venda    
      
  order by    
    4     
    
    
  select    
    *,    
    SaldoReceber = Total - Valor_Pago    
	into
	#FinalMapaCarteiraPedido
  from    
    #MapaCarteiraPedido    
  order by    
    Entrega 
end
else
begin
  select   
    IDENTITY(Int,1,1)                                         as  cd_controle,  
    max(dbo.fn_data_string(pv.dt_pedido_venda))                                   as 'Emissao',    
    pvi.cd_pedido_venda                                       as cd_pedido_venda,    
    max(isnull(pv.ic_entrega_futura,'N'))                     as ic_entrega_futura,    
    --max('N')                                                  as 'ic_entrega_futura',    
    max(c.nm_fantasia_cliente)                                as Cliente,    
    max(c.cd_cliente)                                         as cd_cliente, 
    ltrim(rtrim(isnull(max(c.nm_endereco_cliente),''))) + ','+ ltrim(rtrim(isnull(max(c.cd_numero_endereco),''))) + ' - ' +
    ltrim(rtrim(isnull(max(c.nm_bairro),''))) + ' - ' + ltrim(rtrim(isnull(max(ci.nm_cidade),''))) as 'nm_endereco_cliente', 
    max(case when c.cd_tipo_pessoa = 1 then    
             dbo.fn_formata_cnpj(c.cd_cnpj_cliente)    
          else    
             dbo.fn_formata_cpf(c.cd_cnpj_cliente)    
          end)                                                as 'cd_cnpj_cliente',    
      
    max(c.nm_razao_social_cliente)                            as 'nm_razao_social_cliente',    
      
      
    max(dbo.fn_data_string(pvi.dt_entrega_vendas_pedido))                         as Entrega,    
    max(pvi.dt_entrega_fabrica_pedido)                        as 'Fabrica',    
    max(pvi.dt_reprog_item_pedido)                            as 'Reprogramacao',    
      
    case when sum(pvi.qt_item_pedido_venda)<>sum(pvi.qt_saldo_pedido_venda)    
    then    
     case when sum(pvi.qt_saldo_pedido_venda) = 0 
       then 'Faturado'
	   else 'Parcial'    
     end
    else    
     'Total'    
    end                                                        as Tipo,    
      
    sum( (CAST(pvi.qt_item_pedido_venda AS DECIMAL(18,2))  * CAST(vl_unitario_item_pedido AS DECIMAL(18,2)))    
         +    
         (CAST(pvi.qt_item_pedido_venda AS DECIMAL(18,2))  * CAST(vl_unitario_item_pedido AS DECIMAL(18,2))) * ( isnull(cast(pvi.pc_ipi AS DECIMAL(18,2)),0)/100)      
       )                                                       as Total,    
      
     
    sum((CAST(pvi.qt_item_pedido_venda AS DECIMAL(18,2))  * CAST(vl_unitario_item_pedido AS DECIMAL(18,2)))) as Total_Liquido,    
      
    sum( (CAST(pvi.qt_saldo_pedido_venda AS DECIMAL(18,2)) * CAST(vl_unitario_item_pedido AS DECIMAL(18,2))  )  
         +    
         (CAST(pvi.qt_saldo_pedido_venda AS DECIMAL(18,2)) * CAST(vl_unitario_item_pedido AS DECIMAL(18,2)))* ( isnull(cast(pvi.pc_ipi AS DECIMAL(18,2)),0)/100)     
       )                                                       as Saldo,    
       --(CAST(vl_unitario_item_pedido AS DECIMAL(18,2)
    max(cp.nm_condicao_pagamento)                              as 'Condicao_Pagamento',    
    max(v.nm_fantasia_vendedor)                                as 'Vendedor',    
    sum( (pvi.qt_item_pedido_venda  * vl_unitario_item_pedido)     
         * ( isnull(pvi.pc_ipi,0)/100)  )                      as 'Valor_IPI',    
        
    --Valor Pago no Contas a Receber    
    --select * from documento_receber_pagamento    
    isnull(( select    
        sum( isnull(cast(dp.vl_pagamento_documento as DECIMAL(18,2)) ,0) )    
      from    
        documento_receber_pagamento dp    
        inner join documento_receber d on d.cd_documento_receber = dp.cd_documento_receber     
      where    
        d.cd_pedido_venda = pvi.cd_pedido_venda ),0)             as Valor_Pago,    
      
     --Tipo de Pedido---------------------------------------------------------------------------------------    
     max(tp.nm_tipo_pedido)    as nm_tipo_pedido,    
     max(tp.sg_tipo_pedido)    as sg_tipo_pedido,    
     max(cg.nm_cliente_grupo)  as nm_cliente_grupo,    
     max(ra.nm_ramo_atividade) as nm_ramo_atividade,    
      
      
     sum(isnull(ac.vl_adiantamento,0)) as 'Valor Adiantamento',    
      
    max(  
    case when cast(pvi.dt_entrega_vendas_pedido as decimal(18,2)) < @dt_hoje then    
      pv.vl_total_pedido_venda    
    else    
      0.00    
    end)                     as Total_Atraso   
      
      
    --select * from pedido_venda_item    
      
  into    
    #MapaCarteiraPedido2    
      
  from    
    pedido_venda pv                         with (nolock)     
    inner join pedido_venda_item pvi        with (nolock) on pvi.cd_pedido_venda      = pv.cd_pedido_venda    
    --vw_venda_bi pvi  
    left outer join cliente            c    with (nolock) on c.cd_cliente             = pv.cd_cliente    
    left outer join condicao_pagamento cp   with (nolock) on cp.cd_condicao_pagamento = pv.cd_condicao_pagamento    
    left outer join vendedor           v    with (nolock) on v.cd_vendedor            = pv.cd_vendedor    
    left outer join tipo_pedido tp          with (nolock) on tp.cd_tipo_pedido        = pv.cd_tipo_pedido      
    left outer join cliente_grupo cg        with (nolock) on cg.cd_cliente_grupo      = c.cd_cliente_grupo    
    left outer join ramo_atividade ra       with (nolock) on ra.cd_ramo_atividade     = c.cd_ramo_atividade    
    left outer join Cliente_Adiantamento ac with (nolock) on ac.cd_pedido_venda       = pvi.cd_pedido_venda    
    left outer join Cidade               ci with (nolock) on ci.cd_cidade             = c.cd_cidade  
      
  where    
    --isnull(pv.ic_fechado_pedido,'N')='S'    
    --and    
    --isnull(pvi.qt_saldo_pedido_venda,0)>0      
    pv.dt_pedido_venda between @dt_inicial and @dt_final
    and 
	pvi.dt_cancelamento_item is null
    and 
	isnull(c.cd_cliente,0) = case when isnull(@cd_cliente,0) > 0 then isnull(@cd_cliente,0) else isnull(c.cd_cliente,0) end 
	and 
	isnull(pv.cd_vendedor,0) = case when isnull(@cd_vendedor,0) > 0 then isnull(@cd_vendedor,0) else isnull(pv.cd_vendedor,0) end 
	and
	isnull(c.cd_cliente_grupo,0) = case when isnull(@cd_cliente_grupo,0) > 0 then isnull(@cd_cliente_grupo,0) else isnull(c.cd_cliente_grupo,0) end 
    and 
	tp.cd_tipo_pedido = case when ISNULL(@cd_tipo_pedido,0) = 0 then tp.cd_tipo_pedido else ISNULL(@cd_tipo_pedido,0) end 
	and
	isnull(cg.ic_mapa_carteira_apsnet,'N') = case when @ic_todos_clientes = 'S' then isnull(cg.ic_mapa_carteira_apsnet,'N') else 'S' end  
    
  group by    
    pvi.cd_pedido_venda  
    --,ac.vl_adiantamento,dt_entrega_vendas_pedido,vl_total_pedido_venda    
      
  order by    
    4     
    
    
  select    
    *,    
    SaldoReceber = Total - Valor_Pago 
	into
	#FinalMapaCarteiraPedido2
  from    
    #MapaCarteiraPedido2    
  order by    
    Entrega 
end  
---------------------------------------------------------------------------------------------------------------
if isnull(@cd_parametro,0) = 1 
 begin  
	if @cd_empresa not in (329,340)
      begin 
        select * from #FinalMapaCarteiraPedido
		end
	else 
	  begin
	    select * from #FinalMapaCarteiraPedido2
	  end
  return  
 end  

---------------------------------------------------------------------------------------------------------------
declare 
	@Emissao						      nvarchar(20),
	@sg_tipo_pedido   					  nvarchar(20),
	@cd_pedido_venda                      nvarchar(20),
--	@cd_cliente                           int = 0,
	@nm_fantasia_cliente                  nvarchar(60),
	@dt_entrega                           nvarchar(20),
	@tipo								  nvarchar(35),
	@vl_pedido_total                      float = 0,
	@vl_total_liq                         float = 0,
	@saldo_pedido                         float = 0,
    @vl_pago                              float = 0,
	@vl_saldo_receber                     float = 0,
	@ic_entrega_futura                    char(1),
	@nm_condicao_pagamento                nvarchar(30),
	@nm_vendedor                          nvarchar(60),
	@nm_grupo_cliente                     nvarchar(50),
	@cd_cnpj_cliente                      nvarchar(30),
	@nm_razao_social_cliente     		  nvarchar(60),
    @nm_segmento_mercado                  nvarchar(40),
	@vl_total_atraso                      float = 0,
    @id                                   int = 0,
	@qt_total_ped                         int = 0,
	@vl_total_pedido                      float = 0,
	@vl_total_liquedo                     float = 0,
	@vl_saldo_ped						  float = 0,
	@vl_total_pago						  float = 0,
	@vl_saldo_receber_geral               float = 0,
	@vl_saldo_fat						  float = 0,
	@vl_total_atraso_geral				  float = 0
   
if @cd_empresa not in (329,340)
begin  
  select    
	  @qt_total_ped            = count(cd_pedido_venda),
	  @vl_total_pedido         = sum(Total),
	  @vl_total_liquedo        = sum(Total_Liquido),
	  @vl_saldo_ped            = sum(Saldo),
	  @vl_total_pago           = sum(Valor_Pago),
	  @vl_saldo_receber_geral  = sum(SaldoReceber),
	  @vl_total_atraso_geral   = sum(Total_Atraso)
	  
   from #FinalMapaCarteiraPedido
end
else
begin
  select    
	  @qt_total_ped            = count(cd_pedido_venda),
	  @vl_total_pedido         = sum(Total),
	  @vl_total_liquedo        = sum(Total_Liquido),
	  @vl_saldo_ped            = sum(Saldo),
	  @vl_total_pago           = sum(Valor_Pago),
	  @vl_saldo_receber_geral  = sum(SaldoReceber),
	  @vl_total_atraso_geral   = sum(Total_Atraso)
	  
   from #FinalMapaCarteiraPedido2
end
--------------------------------------------------------------------------------------------------------------  

set @html_geral = '  
    <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 20%;"> '+isnull(+@titulo,'')+' </p>  
    </div> 
	<table class="tamanho">
		<tr>
			<th>Emissão</th>
			<th>Tipo Pedido</th>
			<th>Pedido Venda</th>
			<th>Cliente</th>
			<th>Entrega</th>
			<th>Tipo</th>
			<th>Total Pedido</th>
			<th>Total Líquido</th>
			<th>Saldo Pedido</th>
			<th>Valor Pago</th>
			<th>Saldo a Receber</th>
			<th>Entrega Futura</th>
			<th>Condicão Pagamento</th>
			<th>Vendedor</th>
			<th>Grupo de Cliente</th>
			<th>CNPJ</th>
			<th>Razão Social</th>
			<th>Segmento</th>
			<th>Total Atraso</th>
		<tr>	
	
		
			'

if @cd_empresa not in (329,340)
begin  
--------------------------------------------------------------------------------------------------------------     
	
while exists( select Top 1 cd_controle from #FinalMapaCarteiraPedido )
  begin
  select    
      @id                      = cd_controle,
      @Emissao                 = CONVERT(VARCHAR(15),Emissao, 103),
	  @sg_tipo_pedido          = sg_tipo_pedido,
	  @cd_pedido_venda         = cd_pedido_venda,
	  @nm_fantasia_cliente     = Cliente,
	  @dt_entrega              = CONVERT(nvarchar(15),Entrega, 103),
	  @tipo                    = Tipo,
	  @vl_pedido_total         = Total,
	  @vl_total_liq            = Total_Liquido,
	  @saldo_pedido            = Saldo,
	  @vl_pago                 = Valor_Pago,
	  @vl_saldo_receber        = SaldoReceber,
	  @ic_entrega_futura       = ic_entrega_futura,
	  @nm_condicao_pagamento   = Condicao_Pagamento,
	  @nm_vendedor             = Vendedor,
	  @nm_grupo_cliente        = nm_cliente_grupo,
	  @cd_cnpj_cliente         = cd_cnpj_cliente,
	  @nm_razao_social_cliente = nm_razao_social_cliente,
	  @nm_segmento_mercado     = nm_ramo_atividade,
	  @vl_total_atraso         = Total_Atraso
	  
   from #FinalMapaCarteiraPedido

---------------------------------------------------------------------------------------------------------------- 
set @html_cab_det = @html_cab_det +

		'<tr>	
		    <td>'+isnull(dbo.fn_data_string(@Emissao),'')+'</td>
			<td>'+isnull(@sg_tipo_pedido,'')+'</td>
			<td>'+cast(isnull(@cd_pedido_venda,'')as nvarchar(20))+'</td>
			<td>'+isnull(@nm_fantasia_cliente,'')+'</td>
			<td>'+isnull(dbo.fn_data_string(@dt_entrega),'')+'</td>
			<td>'+isnull(@tipo,'')+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_pedido_total),'')as nvarchar(20))+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_total_liq),'')as nvarchar(20))+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@saldo_pedido),'')as nvarchar(20))+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_pago),'')as nvarchar(20))+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_saldo_receber),'')as nvarchar(20))+'</td>
			<td>'+isnull(@ic_entrega_futura,'')+'</td>
			<td>'+isnull(@nm_condicao_pagamento,'')+'</td>
			<td>'+isnull(@nm_vendedor,'')+'</td>
			<td>'+isnull(@nm_grupo_cliente,'')+'</td>
			<td>'+isnull(@cd_cnpj_cliente,'')+'</td>
			<td>'+isnull(@nm_razao_social_cliente,'')+'</td>
			<td>'+isnull(@nm_segmento_mercado,'')+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_total_atraso),'') as nvarchar(20))+'</td>
	    </tr>'
	 DELETE FROM #FinalMapaCarteiraPedido WHERE cd_controle = @id

end
end 
else
begin
  	
while exists( select Top 1 cd_controle from #FinalMapaCarteiraPedido2 )
  begin
  select    
      @id                      = cd_controle,
      @Emissao                 = CONVERT(VARCHAR(15),Emissao, 103),
	  @sg_tipo_pedido          = sg_tipo_pedido,
	  @cd_pedido_venda         = cd_pedido_venda,
	  @nm_fantasia_cliente     = Cliente,
	  @dt_entrega              = CONVERT(nvarchar(15),Entrega, 103),
	  @tipo                    = Tipo,
	  @vl_pedido_total         = Total,
	  @vl_total_liq            = Total_Liquido,
	  @saldo_pedido            = Saldo,
	  @vl_pago                 = Valor_Pago,
	  @vl_saldo_receber        = SaldoReceber,
	  @ic_entrega_futura       = ic_entrega_futura,
	  @nm_condicao_pagamento   = Condicao_Pagamento,
	  @nm_vendedor             = Vendedor,
	  @nm_grupo_cliente        = nm_cliente_grupo,
	  @cd_cnpj_cliente         = cd_cnpj_cliente,
	  @nm_razao_social_cliente = nm_razao_social_cliente,
	  @nm_segmento_mercado     = nm_ramo_atividade,
	  @vl_total_atraso         = Total_Atraso
	  
   from #FinalMapaCarteiraPedido2
   set @html_cab_det = @html_cab_det +
		'<tr>
		    <td>'+isnull(@Emissao,'')+'</td>
			<td>'+isnull(@sg_tipo_pedido,'')+'</td>
			<td>'+cast(isnull(@cd_pedido_venda,'')as nvarchar(20))+'</td>
			<td>'+isnull(@nm_fantasia_cliente,'')+'</td>
			<td>'+isnull(@dt_entrega,'')+'</td>
			<td>'+isnull(@tipo,'')+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_pedido_total),'')as nvarchar(20))+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_total_liq),'')as nvarchar(20))+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@saldo_pedido),'')as nvarchar(20))+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_pago),'')as nvarchar(20))+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_saldo_receber),'')as nvarchar(20))+'</td>
			<td>'+isnull(@ic_entrega_futura,'')+'</td>
			<td>'+isnull(@nm_condicao_pagamento,'')+'</td>
			<td>'+isnull(@nm_vendedor,'')+'</td>
			<td>'+isnull(@nm_grupo_cliente,'')+'</td>
			<td>'+isnull(@cd_cnpj_cliente,'')+'</td>
			<td>'+isnull(@nm_razao_social_cliente,'')+'</td>
			<td>'+isnull(@nm_segmento_mercado,'')+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_total_atraso),'') as nvarchar(20))+'</td>
		 </tr>	'

      
  delete from #FinalMapaCarteiraPedido2 where cd_controle = @id
end
end 

--------------------------------------------------------------------------------------------------------------------  
  
  
  
  
set @html_rodape ='
            <tr style="font-size:12px">
            <td><b>Total</b></td>
            <td></td>
            <td><b>'+cast(isnull(@qt_total_ped,'') as nvarchar(20))+'</b></td>
            <td></td>
            <td></td>
            <td></td>
            <td><b>'+cast(isnull(dbo.fn_formata_valor(@vl_total_pedido),'') as nvarchar(20))+'</b></td>
            <td><b>'+cast(isnull(dbo.fn_formata_valor(@vl_total_liquedo),'') as nvarchar(20))+'</b></td>
            <td><b>'+cast(isnull(dbo.fn_formata_valor(@vl_saldo_ped),'') as nvarchar(20))+'</b></td>
            <td><b>'+cast(isnull(dbo.fn_formata_valor(@vl_total_pago),'') as nvarchar(20))+'</b></td>
            <td><b>'+cast(isnull(dbo.fn_formata_valor(@vl_saldo_receber_geral),'') as nvarchar(20))+'</b></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td><b>'+cast(isnull(dbo.fn_formata_valor(@vl_total_atraso_geral),'') as nvarchar(20))+'</b></td>
        </tr>
    </table>

 <div class="company-info">  
  <p><strong>'+@footerTitle+'</strong></p>  
 </div>  
    <p>'+@ds_relatorio+'</p>  
 </div>  
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
  
--exec pr_egis_relatorio_mapa_carteira_pedido 264,0,''

