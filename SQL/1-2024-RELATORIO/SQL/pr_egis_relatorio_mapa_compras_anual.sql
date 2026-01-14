IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_mapa_compras_anual' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_mapa_compras_anual

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_mapa_compras_anual  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_mapa_compras_anual  
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
create procedure pr_egis_relatorio_mapa_compras_anual  
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
declare @cd_plano_compra        int = 0
--declare @cd_relatorio           int = 0  
  
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
         
--set @cd_parametro      = 0  
set @cd_empresa        = 0  
set @cd_form           = 0  
  
  
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
  select @cd_plano_compra        = valor from #json where campo = 'cd_plano_compra'  
  
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
------------------------------------------------------------------------------------------------------------
declare @ic_mapa_item_ped_compra char(1)
declare @ic_liberacao_comprador char(1) = 'S'
declare @vl_total_recebido       decimal(25,2)
declare @ic_parametro           int

declare @ic_tipo_consulta       char(1)

set @ic_tipo_consulta = 'A'
--set @cd_plano_compra   = 0
set @ic_parametro      = 1
set @ic_liberacao_comprador = 'S'
--set @dt_inicial = '02-01-2025'
--set @dt_final = '02-28-2025'
set @ic_mapa_item_ped_compra = 'S'


  set @dt_inicial = cast(cast(@dt_inicial as int) as datetime)
  set @dt_final   = cast(cast(@dt_final   as int) as datetime)

  declare @vl_total                decimal(25,2)

  if @ic_liberacao_comprador is null 
    set @ic_liberacao_comprador = 'S'

  -- Indica se Será Analítico por Item de Pedido
  set @ic_mapa_item_ped_compra = ( select IsNull(ic_mapa_item_ped_compra,'N') from Parametro_Suprimento with (nolock)
                                   where cd_empresa = dbo.fn_empresa() )


  -- Só irá considerar os itens se for uma consulta analítica.
  if @ic_tipo_consulta <> 'N' 
    set @ic_mapa_item_ped_compra = 'N'

-----------------------------------------------------------------------------------------------------------------------------------------------------------

  select 
    distinct
    gc.nm_grupo_Compra                          as 'GrupoCompra',
    pl.cd_plano_compra                          as 'CodPlano',
    pl.cd_mascara_plano_compra                  as 'PlanoCompra',
    ltrim(rtrim(pl.cd_mascara_plano_compra)) + ' - ' +  
    ltrim(rtrim(pl.nm_plano_compra))            as 'PlanoCompraRelatorio',
    pl.nm_plano_compra                          as 'Descricao',
    fo.nm_fantasia_fornecedor                   as 'Fornecedor',
    pc.cd_pedido_compra		                    as 'Pedido',
    pci.cd_item_pedido_compra                   as 'Item', 
    pci.qt_item_pedido_compra                   as 'Qtd',
    pci.qt_item_pesbr_ped_compra                as 'Peso',
		pvi.cd_item_pedido_venda, 
		pv.cd_pedido_venda,
 		c.nm_fantasia_cliente,
    case when @ic_mapa_item_ped_compra = 'S' then
      pci.dt_item_pedido_compra
    else 
      pc.dt_pedido_compra end                   as 'Emissao',
    pci.dt_item_nec_ped_compra                  as 'Necessidade',
    pci.dt_entrega_item_ped_compr               as 'Entrega',

    isnull(pci.vl_custo_item_ped_compra,0)      as vl_custo_item_ped_compra,
    isnull(pci.vl_item_unitario_ped_comp,0)     as vl_item_unitario_ped_comp,


    cast(
     (isnull(pci.vl_total_item_pedido_comp,0)  
	 + isnull(pci.vl_ipi_item_pedido_compra,0) 
	 + isnull(pci.vl_frete_item_pedido_compra,0)
	 + isnull(pci.vl_item_icms_st,0)
    )    as decimal(25,2))                      as 'ValorComprado',

    isnull(pci.pc_icms,0)                       as 'ICMS',
    isnull(pci.pc_ipi,0)                        as 'IPI',
    cast(null as datetime)                      as 'Recebimento',
    cast(null as int)                           as 'cd_nota_entrada',
    cast(null as int)                           as 'cd_item_nota_entrada',
    cast(null as float)                         as 'qt_item_nota_entrada',
    cast(0 as decimal(25,2))                    as 'ValorRecebido',
    cast(0    as int)                           as 'DiaEntrega',
    cc.nm_centro_custo,

    case when isnull(pci.cd_servico,0)>0 
    then
       s.cd_mascara_servico
    else
       case when isnull(pci.cd_produto,0)>0 then
          p.cd_mascara_produto
       else
          'Especial'
       end
    end                                         as cd_mascara_produto,

    case when isnull(pci.cd_servico,0)>0 
    then
       s.sg_servico
    else
       case when isnull(pci.cd_produto,0)>0 then
          p.nm_fantasia_produto
       else
          'Especial'
       end
    end                                         as nm_fantasia_produto,

    case when isnull(pci.cd_servico,0)>0 
    then
       s.nm_servico
    else
       case when isnull(pci.cd_produto,0)>0 then
          p.nm_produto
       else
          pci.nm_produto
       end
    end                                         as nm_produto,

    um.sg_unidade_medida,  

    --Impostos

    --ICMS
    isnull(pci.vl_icms_item_pedido_compra,0)        as vl_icms_item_pedido_compra,

    --IPI
    isnull(pci.vl_ipi_item_pedido_compra,0)         as vl_ipi_item_pedido_compra,

    --PIS

    --COFIS

	--Frete
	isnull(pc.vl_frete_pedido_compra,0)             as vl_frete_pedido_compra,
  isnull(ef.nm_fantasia_empresa,'')               as nm_fantasia_empresa

  into 
    #Mapa_Compra

  from 
    Pedido_Compra pc with (nolock)
    left outer join Pedido_Compra_item pci    with (nolock) on pci.cd_pedido_compra = pc.cd_pedido_compra
    left outer join Plano_Compra pl           with (nolock) on pl.cd_plano_compra   = pci.cd_plano_compra 
    left outer join Fornecedor fo             with (nolock) on fo.cd_fornecedor     = pc.cd_fornecedor 
    left outer join Grupo_Compra gc           with (nolock) on gc.cd_grupo_compra   = pl.cd_grupo_compra
    left outer join (select cd_pedido_compra, cd_item_pedido_compra, sum(vl_total_nota_entr_item) as vl_total_nota_entr_item, 
                            max(isnull(dt_item_receb_nota_entrad,0)) as dt_item_receb_nota_entrad
                     from Nota_Entrada_Item with (nolock)
                     where dt_item_receb_nota_entrad < @dt_inicial
                     group by cd_pedido_compra, cd_item_pedido_compra) nei on nei.cd_pedido_compra = pci.cd_pedido_compra and
                                                                              nei.cd_item_pedido_compra = pci.cd_item_pedido_compra
    left outer join Centro_Custo 		cc 	      with (nolock) on cc.cd_centro_custo       = IsNull(pci.cd_centro_custo,pc.cd_centro_custo)   
    left outer join Produto p                 with (nolock) on p.cd_produto             = pci.cd_produto
    left outer join Servico s                 with (nolock) on s.cd_servico             = pci.cd_servico
    left outer join Unidade_Medida um         with (nolock) on um.cd_unidade_medida     = pci.cd_unidade_medida
	  left outer join pedido_venda_item pvi     with (nolock) on pvi.cd_pedido_venda      = pci.cd_pedido_venda
													                                 and pvi.cd_item_pedido_venda = pci.cd_item_pedido_venda
	  left outer join pedido_venda pv           with (nolock) on pv.cd_pedido_venda       = pvi.cd_pedido_venda
	  left outer join cliente c                 with (nolock) on c.cd_cliente             = pv.cd_cliente 
		left outer join pedido_compra_empresa pce	with (nolock) on pce.cd_pedido_compra     = pc.cd_pedido_compra
    left outer join empresa_faturamento    ef with (nolock) on ef.cd_empresa            = pce.cd_empresa						
		
  where 
    --Verificar se o Comprador Liberou o Pedido de Compra
    ((exists (select 'x' 
              from pedido_compra_aprovacao pca with (nolock)
              where pca.cd_pedido_compra = pc.cd_pedido_compra and
                    pca.cd_tipo_aprovacao = 1) and 
                    @ic_liberacao_comprador='S' ) or 
                    @ic_liberacao_comprador='N' ) and

     --Data Emissão do Item do Pedido
     ((case when @ic_mapa_item_ped_compra = 'S' then
         pci.dt_item_pedido_compra
       else 
         pc.dt_pedido_compra end between @dt_inicial and @dt_final and @ic_parametro = 0)  or

       (nei.dt_item_receb_nota_entrad between @dt_inicial and @dt_final and @ic_parametro = 1 ) or  

       (pci.dt_entrega_item_ped_compr between @dt_inicial and @dt_final and @ic_parametro = 2 ) ) and

    --Plano de Compra
    (pl.cd_plano_compra = case when isnull(@cd_plano_compra,'') = 0 then pl.cd_plano_compra else isnull(@cd_plano_compra,'') end ) and      
    (isnull(pl.ic_mapa_plano_compra,'S') = 'S') and  
    (pci.dt_item_canc_ped_compra is null) 

    --and
    --pc.dt_cancel_ped_compra is null

  --select * from #Mapa_Compra

  -- PEDIDOS COM DATA DE RECEBIMENTO NO PERÍODO

  select 
    distinct
    gc.nm_grupo_Compra                          as 'GrupoCompra',
    pl.cd_plano_compra                          as 'CodPlano',
    pl.cd_mascara_plano_compra                  as 'PlanoCompra',
    pl.nm_plano_compra                          as 'Descricao',
    ltrim(rtrim(pl.cd_mascara_plano_compra)) + ' - ' +  
    ltrim(rtrim(pl.nm_plano_compra))            as 'PlanoCompraRelatorio',
    fo.nm_fantasia_fornecedor                   as 'Fornecedor',
    pc.cd_pedido_compra		                     as 'Pedido',
    pci.cd_item_pedido_compra                   as 'Item', 
    pci.qt_item_pedido_compra                   as 'Qtd',
    pci.qt_item_pesbr_ped_compra                as 'Peso',

    case when @ic_mapa_item_ped_compra = 'S' then
      pci.dt_item_pedido_compra
    else 
      pc.dt_pedido_compra    end                as 'Emissao',
    pci.dt_item_nec_ped_compra                  as 'Necessidade',
    pci.dt_entrega_item_ped_compr               as 'Entrega',

    isnull(pci.vl_custo_item_ped_compra,0)      as vl_custo_item_ped_compra,
    isnull(pci.vl_item_unitario_ped_comp,0)     as vl_item_unitario_ped_comp,


    ISNULL(pci.pc_icms,0)                                 as 'ICMS',
    isnull(pci.pc_ipi,0)                                 as 'IPI',

    DadosReceb.dt_item_receb_nota_entrad        as 'Recebimento',
    DadosReceb.cd_nota_entrada,
    DadosReceb.cd_item_nota_entrada,
    DadosReceb.qt_item_nota_entrada,

    cast(case when isnull(ValorReceb.ValorRecebido,0)<>0
    then
     ValorReceb.ValorRecebido
    else
--     case when isnull(pci.vl_total_item_pedido_comp,0)=0 then
--       pci.qt_item_pedido_compra * pci.vl_item_unitario_ped_comp
--     else
--     isnull(pci.vl_total_item_pedido_comp,0)  
     (isnull(pci.vl_total_item_pedido_comp,0)  + isnull(pci.vl_ipi_item_pedido_compra,0) )

--    end
    end
    as decimal(25,2))              

                                                                                    as 'ValorRecebido',

    cast(DadosReceb.dt_item_receb_nota_entrad-pci.dt_entrega_item_ped_compr as int) as 'DiaEntrega',

    cc.nm_centro_custo,

    case when isnull(pci.cd_servico,0)>0 
    then
       s.cd_mascara_servico
    else
       case when isnull(pci.cd_produto,0)>0 then
          p.cd_mascara_produto
       else
          'Especial'
       end
    end                                         as cd_mascara_produto,

    case when isnull(pci.cd_servico,0)>0 
    then
       s.sg_servico
    else
       case when isnull(pci.cd_produto,0)>0 then
          p.nm_fantasia_produto
       else
          'Especial'
       end
    end                                         as nm_fantasia_produto,

    case when isnull(pci.cd_servico,0)>0 
    then
       s.nm_servico
    else
       case when isnull(pci.cd_produto,0)>0 then
          p.nm_produto
       else
          pci.nm_produto
       end
    end                                              as nm_produto,

    um.sg_unidade_medida,

    --Impostos  
    --ICMS

    isnull(pci.vl_icms_item_pedido_compra,0)        as vl_icms_item_pedido_compra,

    --IPI
    isnull(pci.vl_ipi_item_pedido_compra,0)         as vl_ipi_item_pedido_compra,


	isnull(pc.vl_frete_pedido_compra,0)             as vl_frete_pedido_compra,

  isnull(ef.nm_fantasia_empresa,'')               as nm_fantasia_empresa

  into
    #Mapa_Recebido

  from 
    
    Pedido_Compra pc                  with (nolock)

    inner join Pedido_Compra_item pci with (nolock)     on pc.cd_pedido_compra       = pci.cd_pedido_compra 

    left outer join Plano_Compra pl   with (nolock)     on pl.cd_plano_compra        = pci.cd_plano_compra 

    left outer join Fornecedor fo     with (nolock)     on fo.cd_fornecedor          = pc.cd_fornecedor 

    left outer join vw_recebimento_pedido_compra DadosReceb  on DadosReceb.cd_pedido_compra      = pci.cd_pedido_compra      and 
                                                                DadosReceb.cd_item_pedido_compra = pci.cd_item_pedido_compra --and

--                                                            --DadosReceb.dt_item_receb_nota_entrad between @dt_inicial and @dt_final

--     left outer join
--     -- Dados do Recebimento
-- 
--     (select top 1 
--             nei.cd_pedido_compra,
--             nei.cd_item_pedido_compra,
--             nei.dt_item_receb_nota_entrad,
--             nei.cd_nota_entrada           as cd_nota_entrada,
--             nei.cd_item_nota_entrada      as cd_item_nota_entrada,
--             nei.qt_item_nota_entrada      as qt_item_nota_entrada
--      from vw_recebimento_pedido_compra nei with (nolock)
--      --where nei.dt_item_receb_nota_entrad between @dt_inicial and @dt_final
--      order by nei.cd_pedido_compra,
--               nei.cd_item_pedido_compra,
--               nei.dt_item_receb_nota_entrad desc
--                                                      ) DadosReceb on DadosReceb.cd_pedido_compra      = pci.cd_pedido_compra      and 
--                                                                      DadosReceb.cd_item_pedido_compra = pci.cd_item_pedido_compra and
--                                                                      DadosReceb.dt_item_receb_nota_entrad between @dt_inicial and @dt_final
     left outer join

    -- Valor do Recebimento----------------------------------------------------------------------------------------------------------

    (select nei.cd_pedido_compra,
            nei.cd_item_pedido_compra,
            cast(sum(isnull(nei.vl_total_nota_entr_item,0) + isnull(nei.vl_ipi_nota_entrada,0)) as decimal(25,2)) as ValorRecebido

     from Nota_Entrada_item nei with (nolock)

     where nei.dt_item_receb_nota_entrad between @dt_inicial and @dt_final

     group by nei.cd_pedido_compra,
              nei.cd_item_pedido_compra) ValorReceb on ValorReceb.cd_pedido_compra      = pci.cd_pedido_compra and 
                                                       ValorReceb.cd_item_pedido_compra = pci.cd_item_pedido_compra     

    left outer join Grupo_Compra gc       with (nolock) on gc.cd_grupo_compra   = pl.cd_grupo_compra
    left outer join Centro_Custo 		cc with (nolock) on cc.cd_centro_custo   = IsNull(pci.cd_centro_custo,pc.cd_centro_custo)   
    left outer join Produto p             with (nolock) on p.cd_produto         = pci.cd_produto
    left outer join Servico s             with (nolock) on s.cd_servico         = pci.cd_servico
    left outer join Unidade_Medida um     with (nolock) on um.cd_unidade_medida = pci.cd_unidade_medida
		left outer join pedido_compra_empresa pce	with (nolock) on pce.cd_pedido_compra     = pc.cd_pedido_compra
    left outer join empresa_faturamento    ef with (nolock) on ef.cd_empresa            = pce.cd_empresa		

  where
   pc.dt_cancel_ped_compra     is null and
   pci.dt_item_canc_ped_compra is null and
   pl.cd_plano_compra = case when isnull(@cd_plano_compra,'') = 0 then pl.cd_plano_compra else isnull(@cd_plano_compra,'') end and     
   isnull(pl.ic_mapa_plano_compra,'S') = 'S'

   and

 
   --Data de Emissão / Data do Recebimento----------------------------------------------------------------------------------------------------

   ( 
    (case when @ic_mapa_item_ped_compra = 'S' then
       pci.dt_item_pedido_compra
     else 
       pc.dt_pedido_compra
    end between @dt_inicial and @dt_final and @ic_parametro = 0 ) or

    (DadosReceb.dt_item_receb_nota_entrad between @dt_inicial and @dt_final and @ic_parametro = 1 ) or  

    (pci.dt_entrega_item_ped_compr between @dt_inicial and @dt_final and @ic_parametro = 2 )      ) 


  --select * from #Mapa_Recebido order by pedido

  -- Atualizando a Tabela de Mapa de Compra com os Recebidos

  update #Mapa_Compra
  set 
      Recebimento          = mr.Recebimento,
      cd_nota_entrada      = mr.cd_nota_entrada,
      cd_item_nota_entrada = mr.cd_item_nota_entrada,
      qt_item_nota_entrada = mr.qt_item_nota_entrada,
      ValorRecebido        = isnull(mr.ValorRecebido,0)      

  from
    #Mapa_Compra   mp,
    #Mapa_Recebido mr

  where
    mp.Pedido = mr.Pedido and
    mp.Item   = mr.Item

  delete from #Mapa_Recebido
  from
    #Mapa_Compra   mp,
    #Mapa_Recebido mr
  where
    mp.Pedido = mr.Pedido and
    mp.Item   = mr.Item

  insert into #Mapa_Compra
   (GrupoCompra,
    CodPlano,
    PlanoCompra,
    PlanoCompraRelatorio,
    Descricao,
    Fornecedor,
    Pedido,
    Item, 
    Qtd,
    Peso,
    Emissao,
    Necessidade,
    Entrega,
    vl_custo_item_ped_compra,
    vl_item_unitario_ped_comp,   
    ValorComprado,
    ICMS,
    IPI,
    Recebimento,
    cd_nota_entrada,
    cd_item_nota_entrada,
    qt_item_nota_entrada,
    ValorRecebido,
    DiaEntrega,
    nm_centro_custo,
    cd_mascara_produto,
    nm_fantasia_produto,
    nm_produto,
    sg_unidade_medida,
    vl_icms_item_pedido_compra,
    vl_ipi_item_pedido_compra,
	  vl_frete_pedido_compra,
    nm_fantasia_empresa)

  select
    GrupoCompra,
    CodPlano,   
    PlanoCompra,
    PlanoCompraRelatorio,
    Descricao,
    Fornecedor,
    Pedido,
    Item, 
    Qtd,
    Peso,
    Emissao,
    Necessidade,
    Entrega,
    vl_custo_item_ped_compra,
    vl_item_unitario_ped_comp,
    isnull(ValorRecebido,0),
    ICMS,
    IPI,
    Recebimento,
    cd_nota_entrada,
    cd_item_nota_entrada,
    qt_item_nota_entrada,
    ValorRecebido,
    DiaEntrega,
    nm_centro_custo,
    cd_mascara_produto,
    nm_fantasia_produto,
    nm_produto,
    sg_unidade_medida,
    vl_icms_item_pedido_compra,
    vl_ipi_item_pedido_compra,
	  vl_frete_pedido_compra,
    nm_fantasia_empresa
  from
    #Mapa_Recebido

---------------------------------------------------------------------------------------------
--Verifica se o parâmetro é Recebimento - Deleta todos os pedidos não Recebidos
--------------------------------------------------------------------------------------------
if @ic_parametro = 1 --Somente Para os Pedidos Recebidos
begin

  delete from #Mapa_Compra
  where
    isnull(cd_nota_entrada,0) = 0

end

------------------------------------------------------------------------------------------
if (@ic_tipo_consulta = 'N') and (@ic_mapa_item_ped_compra = 'S') -- Mostra Mapa de Compras 
                                                                  -- por Item do Pedido de Compra.
------------------------------------------------------------------------------------------
begin
 

  select *
  from
    #Mapa_Compra
  order by 
    PlanoCompra,
    Emissao desc,
    Pedido,
    Item                      

end

------------------------------------------------------------
else -- Vai agrupar por pedido.
------------------------------------------------------------
begin

  -- Total Comprado para Cálculo de Percentual
  select 
    @vl_total = sum( ValorComprado )
  from
    #Mapa_Compra

  -- Total Recebido para Cálculo de Percentual

  select
    @vl_total_recebido = sum(ValorRecebido)
  from
    #Mapa_Compra

  -- Consulta do Mapa Analítico-------------------------------------------------------------------------------------------
  if IsNull(@ic_tipo_consulta,'N') = 'N'
    select
      GrupoCompra,
      CodPlano,
      PlanoCompra,
      PlanoCompraRelatorio,
      Descricao,
      Fornecedor,
      Pedido,
      0                         as Item, 
      Sum(qtd)                  as Qtd,
      Sum(Peso)                 as Peso,
      max(cd_item_pedido_venda) as cd_item_pedido_venda, 
      max(cd_pedido_venda)      as cd_pedido_venda,
      max(nm_fantasia_cliente)  as nm_fantasia_cliente,
      Emissao,
      nm_centro_custo,
      sum( isnull(ValorComprado,0))   
	  + max(isnull(vl_frete_pedido_compra,0)) --Frete

	                                  as ValorComprado,
      max(Necessidade)                as Necessidade,
      max(Entrega)                    as Entrega,
      cast(0.00 as float)             as ICMS,
      cast(0.00 as float)             as IPI,
      max(Recebimento)                as Recebimento,
      max(cd_nota_entrada)            as cd_nota_entrada,
      0                               as cd_item_nota_entrada,
      sum(qt_item_nota_entrada)       as qt_item_nota_entrada,
      sum(ValorRecebido)              as ValorRecebido,
      sum(DiaEntrega)                 as DiaEntrega,
      max(cd_mascara_produto)         as cd_mascara_produto,
      max(nm_fantasia_produto)        as nm_fantasia_produto,
      max(nm_produto)                 as nm_produto,
      max(sg_unidade_medida)          as sg_unidade_medida,
      max(vl_icms_item_pedido_compra) as vl_icms_item_pedido_compra,
      max(vl_ipi_item_pedido_compra)  as vl_ipi_item_pedido_compra,
      max(vl_custo_item_ped_compra)   as vl_custo_item_ped_compra,
      max(vl_item_unitario_ped_comp)  as vl_item_unitario_ped_comp,
      isnull(nm_fantasia_empresa,'')  as nm_fantasia_empresa

    from
      #Mapa_Compra

    group by
      GrupoCompra,
      CodPlano,
      PlanoCompra,
      PlanoCompraRelatorio,
      Descricao,
      Fornecedor,
      Pedido,
      Emissao,
      nm_centro_custo,
	  nm_fantasia_empresa

    order by 
      GrupoCompra,
      CodPlano,
      PlanoCompra,
      PlanoCompraRelatorio,
      Emissao desc,
      nm_centro_custo,
      Pedido,
      Item                      
	  end
	  
    if (@ic_parametro = 1)
      select 
	    IDENTITY(int,1,1 )        as cd_controle,
        GrupoCompra               as GrupoCompra,
        PlanoCompra               as PlanoCompra,
        PlanoCompraRelatorio,	  
        Descricao                 as Descricao,
        sum(isnull(case when month(Recebimento) = 1 then ValorRecebido end,0))  as Janeiro,
        sum(isnull(case when month(Recebimento) = 2 then ValorRecebido end,0))  as Fevereiro,
        sum(isnull(case when month(Recebimento) = 3 then ValorRecebido end,0))  as Marco,
        sum(isnull(case when month(Recebimento) = 4 then ValorRecebido end,0))  as Abril,
        sum(isnull(case when month(Recebimento) = 5 then ValorRecebido end,0))  as Maio,
        sum(isnull(case when month(Recebimento) = 6 then ValorRecebido end,0))  as Junho,
        sum(isnull(case when month(Recebimento) = 7 then ValorRecebido end,0))  as Julho,
        sum(isnull(case when month(Recebimento) = 8 then ValorRecebido end,0))  as Agosto,
        sum(isnull(case when month(Recebimento) = 9 then ValorRecebido end,0))  as Setembro,
        sum(isnull(case when month(Recebimento) = 10 then ValorRecebido end,0)) as Outubro,
        sum(isnull(case when month(Recebimento) = 11 then ValorRecebido end,0)) as Novembro,
        sum(isnull(case when month(Recebimento) = 12 then ValorRecebido end,0)) as Dezembro,
        sum(ValorRecebido) as Total_Grupo,
        cast((sum(ValorRecebido) / @vl_total_recebido ) * 100 as numeric(25,2)) as Porcent,
        isnull(nm_fantasia_empresa,'')                                          as nm_fantasia_empresa
		into
		#rel_mapa_compra
      from
        #Mapa_Compra

      group by
        GrupoCompra,
        PlanoCompra,
        PlanoCompraRelatorio,
        Descricao,
		nm_fantasia_empresa

      order by
        PlanoCompra

------------------------------------------------------------------------------------------------------------
declare 
  @qt_total_plano   int = 0,
  @vl_total_jan     float = 0,  
  @vl_total_fev     float = 0, 
  @vl_total_mar     float = 0, 
  @vl_total_abril   float = 0, 
  @vl_total_maio    float = 0, 
  @vl_total_jun     float = 0, 
  @vl_total_jul     float = 0, 
  @vl_total_agos    float = 0, 
  @vl_total_set     float = 0, 
  @vl_total_out     float = 0,
  @vl_total_nov     float = 0,
  @vl_total_dez     float = 0,
  @vl_total_geral   float = 0,
  @pc_vl_total      float = 0

		
select
	@qt_total_plano    = COUNT(PlanoCompra),
	@vl_total_jan      = sum(Janeiro),
	@vl_total_fev      = sum(Fevereiro),
	@vl_total_mar      = sum(Marco),
	@vl_total_abril    = sum(Abril),
	@vl_total_maio     = sum(Maio),
	@vl_total_jun      = sum(Junho),
	@vl_total_jul      = sum(Julho),
	@vl_total_agos     = sum(Agosto),
	@vl_total_set      = sum(Setembro),
	@vl_total_out      = sum(Outubro),
	@vl_total_nov      = sum(Novembro),
	@vl_total_dez      = sum(Dezembro),
	@vl_total_geral    = sum(Total_Grupo),
	@pc_vl_total      = sum(Porcent)
from
	#rel_mapa_compra
	
------------------------------------------------------------------------------------------------------------  
 if isnull(@cd_parametro,0) = 1    
 begin    
    select * from #rel_mapa_compra    
  return    
 end    

--------------------------------------------------------------------------------------------------------------  
set @html_detalhe = '' 
set @html_cab_det = '  
    <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 25%;"> '+isnull(+@titulo,'')+' </p>  
    </div>  
 <div>  
    <table>    
       <tr>  
		<th>Grupo</th>  
		<th>Plano</th>  
		<th>Desrição</th>  
		<th>Janeiro</th>
		<th>Fevereiro</th>
		<th>Março</th>  
		<th>Abril</th>  
		<th>Maio</th>  
		<th>Junho</th>  
		<th>Julho</th>  
		<th>Agosto</th>  
		<th>Setembro</th>
		<th>Outubro</th>  
		<th>Novembro</th>  
		<th>Dezembro</th>  
		<th>Total Grupo</th>
		<th>%</th>
	   </tr>'  
          
--------------------------------------------------------------------------------------------------------------  
DECLARE @id int = 0   
  
WHILE EXISTS (SELECT TOP 1 cd_controle FROM #rel_mapa_compra)  
BEGIN  
    SELECT TOP 1  
        @id                          = cd_controle,  
         
   
      @html_detalhe = @html_detalhe + 
        '<tr>  
		   <td style="text-align: left;">'+iSNULL(GrupoCompra, '')+ '</td>
		   <td class="tamanho">'+ISNULL(PlanoCompra,0)+'</td>    
		   <td style="text-align: left;">'+iSNULL(Descricao, '')+ '</td>  
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Janeiro),0)as nvarchar(20))+'</td>  
	       <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Fevereiro),0)as nvarchar(20))+'</td>
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Marco),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Abril),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Maio),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Junho),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Julho),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Agosto),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Setembro),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Outubro),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Novembro),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Dezembro),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Total_Grupo),0)as nvarchar(20))+'</td> 
		   <td class="tamanho">'+cast(ISNULL(dbo.fn_formata_valor(Porcent),0)as nvarchar(20))+'</td> 
        </tr>'  
  from #rel_mapa_compra  
    DELETE FROM #rel_mapa_compra WHERE cd_controle = @id  
END  
--------------------------------------------------------------------------------------------------------------------  
  
set @html_rodape ='  
   <tr>   
       <td class="tamanho" style="font-size:18px;"><b>Total</b></td> 
       <td class="tamanho" style="font-size:18px;"></td> 
       <td class="tamanho" style="font-size:18px;"></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_jan),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_fev),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_mar),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_abril),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_maio),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_jun),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_jul),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_agos),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_set),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_out),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_nov),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_dez),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@vl_total_geral),0)as nvarchar(20))+'</b></td> 
       <td class="tamanho" style="font-size:18px;"><b>'+cast(ISNULL(dbo.fn_formata_valor(@pc_vl_total),0)as nvarchar(20))+'</b></td> 
    </tr>    
 </table>  
 <div class="company-info">  
  <p><strong>'+@footerTitle+'</strong></p>  
 </div>  
    <p>'+@ds_relatorio+'</p>  
 </div>  
 <div class="section-title">  
     <p>Total de Planos:'+CAST(isnull(@qt_total_plano,'')as nvarchar(20))+' </p>  
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
  
-- exec pr_egis_relatorio_mapa_compras_anual 264,0,''
