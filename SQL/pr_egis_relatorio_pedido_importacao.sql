IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_pedido_importacao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_pedido_importacao

GO
  
-------------------------------------------------------------------------------  
--sp_helptext pr_egis_relatorio_pedido_importacao  
-------------------------------------------------------------------------------  
--pr_egis_relatorio_pedido_importacao
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
create procedure pr_egis_relatorio_pedido_importacao 
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
declare @id                     int = 0
--Dados do Relat�rio---------------------------------------------------------------------------------  
  
declare  
   @titulo                     varchar(200),  
   @logo                       varchar(400), 
   @fax                        varchar(20), 
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
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'  

  
  
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
    @dt_inicial           = dt_inicial,    
    @dt_final             = dt_final,
    @cd_vendedor          = isnull(cd_vendedor,''),
	@cd_cliente_grupo     = isnull(cd_grupo_cliente,'')
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
  @nm_fantasia_empresa        = isnull(e.nm_empresa,''),  
  @cd_cep_empresa             = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),  
  @cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),  
  @nm_pais					  = ltrim(rtrim(isnull(p.sg_pais,''))),  
  @cd_cnpj_empresa            = dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),  
  @cd_inscestadual_empresa    =  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),  
  @nm_dominio_internet        =  ltrim(rtrim(isnull(e.nm_dominio_internet,''))),
  @fax                        =  isnull(e.cd_fax_empresa,'')
        
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
            padding: 20px;
            flex: 1;
        }

        h2 {
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
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
            font-size: 14px;
            text-align: center;
        }
        .td-content {
            display: flex;
            flex-direction: column;
            text-align: center;  
        }

    </style>  
</head>  
<body>  
     
    <div style="display: flex; justify-content: space-between; align-items:center">  
  <div style="width:30%; margin-right:20px">  
   <img src="'+@logo+'" alt="Logo da Empresa">  
  </div>  
  <div style="width:70%; padding-left:10px;text-align: right;"> 
      <p class="title">'+@nm_fantasia_empresa+'</p>   
      <p><strong>Phone: </strong>'+@cd_telefone_empresa+' - <strong>Fax: </strong>'+isnull(@fax,'')+'<strong> CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>  
      <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>  
	  <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>  
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
---------------------------------------------------------------------------------------------------------------    
    
if isnull(@cd_parametro,0) = 2    
 begin    
  select * from #RelAtributo    
  return    
end    
--set @dt_inicial = '02/01/2025'
--set @dt_final = '03/28/2025'
--set @cd_cliente_grupo = 1
---------------------------------------------------------------------------------------------------------------

--CAPA
SELECT     
  identity(int,1,1) as cd_controle,
  pi.cd_pedido_importacao as cd_pedido_importacao,
--  ('PI'+cast(cd_pedido_importacao as varchar)+'/'+cast(datepart(yy,dt_pedido_importacao) as varchar)) as cd_identificacao_pedido, 
  ('PI'+ Right('000000' + cast(cd_pedido_importacao as varchar),6)+'/'+cast(datepart(yy,dt_pedido_importacao) as varchar)) as cd_identificacao_pedido, 
  pi.dt_pedido_importacao   as dt_pedido_importacao, 
  pi.cd_fornecedor          as cd_forncedor, 
  pi.nm_ref_ped_imp         as nm_ref_ped_imp, 
  tf.nm_tipo_frete, 
  f.nm_razao_social         as nm_razao_social, 
  f.cd_telefone, 
  f.cd_ddd, 
  p.nm_pais as nm_pais, 
  e.sg_estado, 
  f.nm_endereco_fornecedor  as nm_endereco_fornecedor, 
  f.cd_numero_endereco      as cd_numero_endereco, 
  f.nm_complemento_endereco as nm_complemento_endereco,  
  pi.cd_tipo_pagamento_frete, 
  pi.cd_forma_entrega,
  case when IsNull(pi.cd_forma_entrega,0) = 1 then 'NO'
  else 'YES' end            as ic_part_ship, 
  pi.ds_pedido_importacao, 
  fc.cd_ddd_contato_fornecedor, 
  'Phone ' + IsNull(cd_ddd_contato_fornecedor,'') + ' ' +
    IsNull(cd_ramal_contato_forneced,'') + ' ' + IsNull(cd_telefone_contato_forne,'') + ' / ' +
    ' FAX ' + IsNull(cd_ddd_contato_fornecedor,'') + ' ' +
    IsNull(cd_ramal_contato_forneced,'') + ' ' + IsNull(cd_fax_contato_fornecedor,'') as cd_telefone_contato_forne,
  fc.cd_fax_contato_fornecedor, 
  fc.cd_email_contato_forneced                     as cd_email_contato_forneced, 
  d.nm_departamento                                as nm_departamento, 
  fc.cd_ramal_contato_forneced, 
  RTrim(mp.sg_modalidade_pagamento) + ' - ' + mp.nm_modalidade_pagamento as sg_modalidade_pagamento,
  f.cd_cep as cd_cep,
  c.nm_cidade,
  fc.nm_contato_fornecedor   as nm_contato_fornecedor,
  fc.cd_contato_fornecedor   as cd_contato_fornecedor, 
  port.nm_porto              as nm_porto,
  case when tpf.cd_tipo_pagamento_frete = 1 then
    'Pre Paid' else 'Payable' end nm_tipo_pagamento_frete,
  comp.nm_comprador,
  depusu.nm_departamento as nm_departamento_usuario,
  m.sg_moeda as sg_moeda,
  pi.qt_pesobru_ped_imp as qt_pesobru_ped_imp,
  pi.vl_frete_int_ped_imp as vl_frete_int_ped_imp,
  RTrim(tc.sg_termo_comercial) + ' - ' + tc.nm_termo_comercial as TermsDelivery,
  usu.nm_usuario,
  dusu.nm_departamento as nm_departamento_requisitante,
  cp.nm_condicao_pgto_idioma as nm_condicao_pgto_idioma,
  pi.dt_entrega_ped_imp,
  ti.nm_tipo_importacao as  nm_tipo_importacao
  into
  #CapaPedImport
FROM         
  Pedido_Importacao pi 
  left outer join Condicao_Pagamento_Idioma cp        on pi.cd_condicao_pagamento   = cp.cd_condicao_pagamento and cp.cd_idioma = 2 
  left outer join Modalidade_Pagamento mp             on pi.cd_modalidade_pagamento = mp.cd_modalidade_pagamento 
  left outer join Tipo_Frete tf                       on pi.cd_tipo_frete           = tf.cd_tipo_frete 
  left outer join Fornecedor f                        on pi.cd_fornecedor           = f.cd_fornecedor 
  left outer join Fornecedor_Contato fc               on fc.cd_contato_fornecedor    = pi.cd_contato_fornecedor and fc.cd_fornecedor = pi.cd_fornecedor  
  left outer join Pais p                              on pi.cd_origem_pais = p.cd_pais AND f.cd_pais = p.cd_pais 
  left outer join Cidade c                            ON f.cd_pais = c.cd_pais and 
														 f.cd_estado = c.cd_estado and
														 f.cd_cidade = c.cd_cidade 
  left outer join Estado e ON f.cd_estado = e.cd_estado and f.cd_pais = e.cd_pais 
  left outer join Departamento d ON fc.cd_departamento = d.cd_departamento 
  left outer join Porto port on port.cd_porto = pi.cd_porto 
  left outer join Tipo_Pagamento_Frete tpf on tpf.cd_tipo_pagamento_frete = pi.cd_tipo_pagamento_frete 
  left outer join EGISADMIN.dbo.Usuario u on u.cd_usuario = @cd_usuario 
  left outer join Comprador comp on comp.cd_comprador = u.cd_comprador 
  left outer join Departamento depusu on depusu.cd_departamento = u.cd_departamento 
  left outer join Moeda m on m.cd_moeda = pi.cd_moeda
  left outer join Termo_Comercial tc on (pi.cd_termo_comercial = tc.cd_termo_comercial)
  left outer join EGISADMIN.dbo.Usuario usu on usu.cd_usuario = pi.cd_usuario_requisitante
  left outer join Departamento dusu on dusu.cd_departamento = usu.cd_departamento
  left outer join Tipo_Importacao ti on ti.cd_tipo_importacao = pi.cd_tipo_importacao
where
  cd_pedido_importacao = @cd_documento

--------------------------------------------------------------------------------------------------------------------------------
--ITEM
declare @ic_descricao_tecnica char(1)
declare @ic_imprime_part_number char(1)

select 
   @ic_descricao_tecnica = isnull(ic_descricao_tecnica,'N'), 
   @ic_imprime_part_number = isnull(ic_imprime_part_number,'S')
from parametro_importacao
where cd_empresa = dbo.fn_empresa()

SELECT     
  identity(int,1,1)   as cd_controle,
  p.cd_mascara_produto as cd_mascara_produto,
  pii.cd_item_ped_imp as cd_item_ped_imp,  
  pii.qt_item_ped_imp as qt_item_ped_imp, 
  pii.vl_item_ped_imp as vl_item_ped_imp, 
  (pii.qt_item_ped_imp * pii.vl_item_ped_imp ) as vl_total, 
  pii.dt_entrega_ped_imp as dt_entrega_ped_imp, 
  pii.dt_prev_embarque_ped_imp,
   ltrim(ltrim(case when isnull(pi.nm_produto_idioma,'')='' then
     pii.nm_produto_pedido
   else
     pi.nm_produto_idioma
   end))

  +
  ' '
  +
  ltrim(rtrim(case when @ic_descricao_tecnica='S' then
      case when isnull(cast(pi.ds_produto_idioma as varchar(500)),'')<>'' then
        isnull(cast(pi.ds_produto_idioma as varchar(500)),'')
      else
        isnull(cast(p.ds_produto as varchar(500)),'')
      end
   end))
   +
   case when isnull(pc.nm_fantasia_prod_cliente,'')<>'' then  '('+ltrim(rtrim(isnull(pc.nm_fantasia_prod_cliente,'')))+')' end 

   as nm_produto,


case when @ic_imprime_part_number = 'S' then
  case when isnull(pimp.cd_part_number_produto,'')<>'' then
     pimp.cd_part_number_produto
  else
     p.nm_fantasia_produto
  end
else
 ''
end                                                            as nm_fantasia_produto,

  isnull(tei.nm_tipo_embalagem_idioma,  te.nm_tipo_embalagem) as nm_tipo_embalagem,
  isnull(pimp.cd_part_number_produto,'') as cd_part_number_produto,
  isnull(pii.qt_area_produto,0)  * pii.qt_item_ped_imp as qt_area_produto

  into
  #ItensPedImport

FROM         
  Pedido_Importacao_Item pii with (nolock) 
  left outer join Produto p ON pii.cd_produto = p.cd_produto
  left outer join Idioma i on i.cd_idioma = i.cd_idioma
  left outer join Produto_Idioma pi on pi.cd_produto = pii.cd_produto and 
                                       pi.cd_idioma = i.cd_idioma
  left outer join Tipo_Embalagem te on te.cd_tipo_embalagem = pii.cd_tipo_embalagem
  left outer join Tipo_Embalagem_Idioma tei on tei.cd_tipo_embalagem = pii.cd_tipo_embalagem and
                                                                          tei.cd_idioma                = pi.cd_idioma 
  left outer join Produto_Importacao pimp on pimp.cd_produto = pii.cd_produto
  left outer join pedido_venda pv on pv.cd_pedido_venda = pii.cd_pedido_venda
  left outer join produto_cliente pc on pc.cd_produto = pii.cd_produto and
                                        pc.cd_cliente = pv.cd_cliente


where
   pii.cd_pedido_importacao = @cd_documento 
   and
   i.cd_idioma = 2
   and 
   pii.dt_cancel_item_ped_imp is null

Order By   pii.cd_item_ped_imp


--------------------------------------------------------------------------------------------------------------
declare 
    @cd_identificacao_pedido nvarchar(25),
    @dt_pedido_importacao datetime,
    @nm_ref_ped_imp nvarchar(60),
    @cd_forncedor   int = 0,
    @nm_razao_social nvarchar(60),
    @cd_numero_endereco_rel nvarchar(20),
    @nm_endereco_fornecedor nvarchar(120),
    @ic_part_ship nvarchar(10),
    @cd_telefone_contato_forne nvarchar(50),
    @nm_departamento nvarchar(10),
    @cd_email_contato_forneced nvarchar(60),
    @sg_modalidade_pagamento nvarchar(60),
    @cd_cep nvarchar(20),
    @nm_contato_fornecedor nvarchar(60),
    @cd_contato_fornecedor int = 0,
    @nm_porto  nvarchar(60),
    @TermsDelivery nvarchar(60),
    @nm_condicao_pgto_idioma nvarchar(60),
    @nm_tipo_importacao nvarchar(50),
    @nm_pais_rel nvarchar(20),
    @nm_usuario nvarchar(30),
    @nm_departamento_requisitante nvarchar(30),
	@sg_moeda nvarchar(10),
	@qt_pesobru_ped_imp float = 0,
	@vl_frete_int_ped_imp float = 0,
	@vl_total_geral float = 0,
	@vl_total_frete float = 0


select
  @cd_identificacao_pedido		  = cd_identificacao_pedido,
  @dt_pedido_importacao			  = dt_pedido_importacao,
  @nm_ref_ped_imp			      = nm_ref_ped_imp,
  @cd_forncedor					  = cd_forncedor,
  @nm_razao_social				  = nm_razao_social,
  @cd_numero_endereco		      = cd_numero_endereco,
  @nm_endereco_fornecedor	      = nm_endereco_fornecedor,
  @ic_part_ship					  = ic_part_ship,
  @cd_telefone_contato_forne      = cd_telefone_contato_forne,
  @nm_departamento                = nm_departamento,
  @cd_email_contato_forneced      = cd_email_contato_forneced,
  @sg_modalidade_pagamento        = sg_modalidade_pagamento,
  @cd_cep                         = cd_cep,
  @nm_contato_fornecedor          = nm_contato_fornecedor,
  @cd_contato_fornecedor          = cd_contato_fornecedor,
  @nm_porto                       = nm_porto,
  @TermsDelivery                  = TermsDelivery,
  @nm_condicao_pgto_idioma        = nm_condicao_pgto_idioma,
  @nm_tipo_importacao             = nm_tipo_importacao,
  @nm_pais                        = nm_pais,
  @nm_usuario                     = nm_usuario,
  @nm_departamento_requisitante   = nm_departamento_requisitante,
  @sg_moeda                       = sg_moeda,
  @qt_pesobru_ped_imp             = qt_pesobru_ped_imp,
  @vl_frete_int_ped_imp           = vl_frete_int_ped_imp
  

from #CapaPedImport

select
  @vl_total_geral                 = sum(vl_total),
  @vl_total_frete                 = (@vl_frete_int_ped_imp + @vl_total_geral)
from #ItensPedImport

--------------------------------------------------------------------------------------------------------------  


set @html_geral = '  
       <table >
        <tr>
          <td>
            <div class="td-content">
              <span><b>Purchase Order Nº</b></span>
              <span >'+isnull(@cd_identificacao_pedido,'')+'</span>
            </div>
          </td>
          <td>
            <div class="td-content">
              <span ><b>Date(M/D/Y)</b></span>
              <span >'+cast(isnull(@dt_pedido_importacao,'') as nvarchar(20))+'</span>
            </div>
          </td>
          <td>
            <div class="td-content">
              <span ><b>Cord #</b></span>
              <span >'+cast(isnull(@cd_forncedor,'')as nvarchar(10))+'</span>
            </div>
          </td>
        </tr>
        <tr>
            <td>
              <div class="td-content">
                <span ><b>Reference</b></span>
                <span >'+isnull(@nm_ref_ped_imp,'')+'</span>
              </div>
            </td>
            <td>
              <div class="td-content">
                <span ><b>Ship Mode</b></span>
                <span >'+isnull(@nm_tipo_importacao,'')+'</span>
              </div>
            </td>
            <td>
              <div class="td-content">
                <span ><b>Part Ship</b></span>
                <span >'+isnull(@ic_part_ship,'')+'</span>
              </div>
            </td>
          </tr>
         <div>
          <tr >
    </table>
    <table>
        <tr>
            <td rowspan="5">
                <div class="td-content" style="text-align: left">
                    <p ><b>To</b></p>
                    <p>'+isnull(@nm_razao_social,'')+' ('+cast(isnull(@cd_forncedor,'')as nvarchar(10))+')</p>
                    <p>'+isnull(@cd_numero_endereco,'')+' '+isnull(@nm_endereco_fornecedor,'')+'</p>
                    <p>'+isnull(@cd_cep,'')+'</p>
                    <p>'+isnull(@nm_pais,'')+'</p>
                    <p><b>Attn</b></p>
                    <p>'+isnull(@nm_contato_fornecedor,'')+'('+cast(isnull(@cd_contato_fornecedor,'')as nvarchar(10))+')</p>
                    <p>'+isnull(@nm_departamento,'')+'</p>
                    <p>'+isnull(@cd_telefone_contato_forne,'')+'</p>
                    <p>e-mail: '+isnull(@cd_email_contato_forneced,'')+'</p>
                </div>
            </td>
            
            <td class="td-content">
                <p><b>Payment Terms</b></p>
                <p>'+ISNULL(@nm_condicao_pgto_idioma,'')+'</p>
            </td>
        </tr>

        
        <tr >
            <td class="td-content">
                <p><b>Payment By</b></p>
                <p>'+ISNULL(@sg_modalidade_pagamento,'')+'</p>
            </td>
        </tr>
        <tr>
            <td class="td-content">
                <p><b>INCOTERM</b></p>
                <p>'+ISNULL(@TermsDelivery,'')+'</p>
            </td>
        </tr>
        <tr>
            <td class="td-content">
                <p><b>Destination</b></p>
                <p>'+ISNULL(@nm_porto,'')+'</p>
            </td>
        </tr>
        </div>
      </table>
	  <table>
        <tr>
            <th>#</th>
            <th>Part Number</th>
            <th>Code</th>
            <th>Description</th>
            <th>Packing</th>
            <th>Delivery Time</th>
            <th>Qty</th>
            <th>Unit Price</th>
            <th>Ext Price ( ¥)</th>
        </tr>'
--------------------------------------------------------------------------------------------------------------     
	
while exists( select Top 1 cd_controle from #ItensPedImport)
  begin
  select top 1   
      @id           = cd_controle,
	  @html_cab_det = @html_cab_det +

       '<tr class="tamanho">
            <td>'+cast(isnull(cd_item_ped_imp,'')as nvarchar(10))+'</td>
            <td>'+cast(isnull(nm_fantasia_produto,'')as nvarchar(10))+'</td>
            <td>'+cast(isnull(cd_mascara_produto,'')as nvarchar(10))+'</td>
            <td>'+isnull(nm_produto,'')+'</td>
            <td>'+isnull(nm_tipo_embalagem,'')+'</td>
            <td>'+isnull(dbo.fn_data_string(dt_entrega_ped_imp),'')+'</td>
            <td>'+cast(isnull(qt_item_ped_imp,'')as nvarchar(10))+'</td>
            <td>'+cast(isnull(vl_item_ped_imp,'')as nvarchar(10))+'</td>
            <td>'+cast(isnull(vl_total,'')as nvarchar(10))+'</td>
        </tr>'
     from #ItensPedImport
	 DELETE FROM #ItensPedImport WHERE cd_controle = @id

end

--------------------------------------------------------------------------------------------------------------------  
set @html_detalhe = '     </table>
      <table style="margin-top: 10px;width: 100%;">
        <tr>
            <td style="width: 70%;">
                <p>000,0</p>
            </td>

            <td style="width: 30%;">
            <div style="text-align: right;"> 
                <p><b>Total('+ISNULL(@sg_moeda,'')+')</b>: '+CAST(isnull(dbo.fn_formata_valor(@vl_total_geral),0)as nvarchar(20))+'</p> 
                <p><b>Aproximate Freight</b>: '+CAST(isnull(dbo.fn_formata_valor(@vl_frete_int_ped_imp),0)as nvarchar(20))+'</p>
                <p><b>Total('+ISNULL(@sg_moeda,'')+')</b>: '+CAST(isnull(dbo.fn_formata_valor(@vl_total_frete),0)as nvarchar(20))+'</p>
                <p><b>Aproximate Weight (KG)</b>: '+CAST(isnull(dbo.fn_formata_valor(@qt_pesobru_ped_imp),'')as nvarchar(20))+'</p>
            </div>
        </td>
        
        </tr>
      </table>
      <table style="margin-top: 10px;width: 100%;">
        <tr>
            <td style="width: 50%; text-align: left;">
                <p><b>Remarks </b></p>
                <p></p>
            </td>

            <td style="width: 50%;">
            <div style="text-align: left;">
                <p><b>Requested By</b></p>
                <p>'+ISNULL(@nm_usuario,'')+' / '+ISNULL(@nm_departamento_requisitante,'')+'</p>
                <p><b>Aproved By
                </b></p>
            </div>
        </td>
        
        </tr>
      </table>'
  
set @html_rodape ='
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
  
--exec pr_egis_relatorio_pedido_importacao 291,0,''

