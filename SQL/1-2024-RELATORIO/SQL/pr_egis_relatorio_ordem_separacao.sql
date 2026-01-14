IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_ordem_separacao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_ordem_separacao

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_ordem_separacao
-------------------------------------------------------------------------------
--pr_egis_relatorio_ordem_separacao
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Joao Pedro Marcal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relat�rio Padr�o Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025	
--Altera��o        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_ordem_separacao
@cd_relatorio int   = 0,
@cd_parametro int   = 0,
@json varchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')
declare @data_grafico_bar       varchar(max)
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
declare @cd_pedido_venda        int = 0
--declare @cd_relatorio           int = 0

--Dados do Relat�rio---------------------------------------------------------------------------------

     declare
            @titulo                     varchar(200),
		    @logo                       varchar(400),			
			@nm_cor_empresa             varchar(20),
			@nm_endereco_empresa  	    varchar(200) = '',
			@cd_telefone_empresa    	varchar(200) = '',
			@nm_email_internet		    varchar(200) = '',
			@nm_cidade				    varchar(200) = '',
			@sg_estado				    varchar(10)	 = '',
			@nm_fantasia_empresa	    varchar(200) = '',
			@numero					    int = 0,
			@dt_pedido				    varchar(60) = '',
			@cd_cep_empresa			    varchar(20) = '',
			@cd_cliente				    int = 0,
	--		@nm_fantasia_cliente  	    varchar(200) = '',
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_razao_social_cliente	varchar(200) = '',
			@nm_cidade_cliente			varchar(200) = '',
			@sg_estado_cliente			varchar(5)	= '',
			@cd_numero_endereco			varchar(20) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40)   = '',
			@footerTitle				varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = ''



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
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_pedido_venda        = valor from #json where campo = 'cd_pedido_venda'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'

   end
   --parametro EgisMob(Não tirar)
   if isnull(@cd_pedido_venda,0) = 0 
     begin 
	 set @cd_pedido_venda = @cd_documento
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
  @dt_inicial       = isnull(dt_inicial,0),  
  @dt_final         = isnull(dt_final,0),
  @cd_pedido_venda  = isnull(cd_pedido_venda,0)
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
		@nm_cor_empresa             = case when isnull(e.nm_cor_empresa,'')<>'' then isnull(e.nm_cor_empresa,'#1976D2') else '#1976D2' end,
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


---------------------------------------------------------------------------------------------------------------------------------------------
--Dados do Relat�rio
---------------------------------------------------------------------------------------------------------------------------------------------

declare @html            varchar(max) = '' --Total
declare @html_empresa    varchar(max) = '' --Cabe�alho da Empresa
declare @html_titulo     varchar(max) = '' --T�tulo
declare @html_cab_det    varchar(max) = '' --Cabe�alho do Detalhe
declare @html_detalhe    varchar(max) = '' --Detalhes
declare @html_rod_det    varchar(max) = '' --Rodap� do Detalhe
declare @html_rodape     varchar(max) = '' --Rodape
declare @html_geral      varchar(max) = '' --Geral

declare @data_hora_atual varchar(50)  = ''

set @html         = ''
set @html_empresa = ''
set @html_titulo  = ''
set @html_cab_det = ''
set @html_detalhe = ''
set @html_rod_det = ''
set @html_rodape  = ''
set @html_geral   = ''


set @data_hora_atual = convert(varchar, getdate(), 103) + ' ' + convert(varchar, getdate(), 108)


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
			text-align: center;
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
			font-size: 100%;
			margin-left: 0;
			margin-right: 0;
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

        .tamanhoTabela {
			font-size:14px;
            text-align: center;
        }
    </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:35%; margin-right:20px">
			<img src="'+@logo+'" alt="Logo da Empresa">
		</div>
		<div style="width:45%; padding-left:10px">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
		    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
		</div> 
		'


--Procedure de Cada Relat�rio-------------------------------------------------------------------------------------
  
declare @cd_item_relatorio  int           = 0  
declare @nm_cab_atributo    varchar(100)  = ''  
declare @nm_dados_cab_det   varchar(max) = ''  
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
-------------------------------
--set @cd_pedido_venda = 150230
declare @ic_liberacao_separacao   char(1) declare @ic_liberacao_relatorio char(1)
declare @cd_fase_produto          int
declare @ic_sep_ordem_localizacao char(1)
declare @ic_conversao_comercial   char(1) declare @ic_edita_produto_pedido char(1)

set @cd_empresa = dbo.fn_empresa()

select
  @cd_fase_produto         = isnull(cd_fase_produto,0),  @ic_conversao_comercial  = isnull(ic_conversao_comercial,'N'),  @ic_edita_produto_pedido = isnull(ic_edita_produto_pedido,'N')
from
  parametro_comercial
where
  cd_empresa = @cd_empresa

select
   @ic_liberacao_separacao     = isnull(ic_liberacao_separacao,'N'), @ic_liberacao_relatorio = isnull(ic_liberacao_relatorio,'N'),
   @ic_sep_ordem_localizacao = isnull(ic_sep_ordem_localizacao,'N')
from
  parametro_estoque with (nolock)

where
  cd_empresa = @cd_empresa
 
select
    identity(int,1,1)                                as cd_controle,
    pvi.cd_pedido_venda,
    pvi.cd_item_pedido_venda                         as cd_item_pedido_venda,
    pvi.dt_entrega_vendas_pedido                     as dt_entrega_vendas_pedido,
    pvi.ic_ordsep_pedido_venda,

    isnull(pvi.vl_unitario_item_pedido,0) * isnull(pvi.qt_item_pedido_venda, 0) as vl_total_item,	
    pvi.vl_unitario_item_pedido,

    case when isnull(pvc.cd_produto,0) <> 0 then
		u.nm_unidade_medida
	else
        case when isnull(ump.nm_unidade_medida,'') = '' 
          then um.nm_unidade_medida
          else ump.nm_unidade_medida
        end
    end         as nm_unidade_medida,

(CASE WHEN 
   MONTH(pvi.dt_entrega_vendas_pedido) > MONTH(pv.dt_pedido_venda)
	 OR( MONTH(pvi.dt_entrega_vendas_pedido) = MONTH(pv.dt_pedido_venda) 
       AND DAY(pvi.dt_entrega_vendas_pedido) >= DAY(pv.dt_pedido_venda))
   THEN DATEDIFF(day, pv.dt_pedido_venda, pvi.dt_entrega_vendas_pedido) 
   ELSE DATEDIFF(day, pv.dt_pedido_venda, pvi.dt_entrega_vendas_pedido) -1 END) as 'Prazo',

    isnull(prod.cd_codigo_barra_produto,isnull(p.cd_codigo_barra_produto,isnull(gp.cd_codigo_barra_produto,'')))  as cd_codigo_barra_produto,
    lp.nm_lote_produto, lp.dt_final_lote_produto, us.nm_usuario, pvi.cd_usuario_ordsep, pvi.dt_validade_item_pedido,
    cast(pvi.dt_entrega_vendas_pedido as int) - cast(getdate()as int) as 'qt_dias',
    tep.nm_tipo_entrega_produto,
    case when isnull(pvc.qt_item_produto_comp,0) > 0 and isnull(pvi.qt_saldo_pedido_venda,0)>0 
         then pvc.qt_item_produto_comp * pvi.qt_item_pedido_venda 
         else pvi.qt_item_pedido_venda 
    end as qt_item_pedido_venda,

    case when isnull(pvc.qt_item_produto_comp,0) > 0 and isnull(pvi.qt_saldo_pedido_venda,0)>0 
      then pvc.qt_item_produto_comp * pvi.qt_saldo_pedido_venda 
    else pvi.qt_saldo_pedido_venda 
    end as qt_saldo_pedido_venda,
    case when isnull(pvc.qt_item_produto_comp,0) > 0 and isnull(pvi.qt_saldo_pedido_venda,0)>0 
      then pvc.qt_item_produto_comp * pvi.qt_saldo_pedido_venda 
    else pvi.qt_saldo_pedido_venda 
    end * isnull(pvi.vl_unitario_item_pedido,0) as vl_total_item_saldo,
    case when isnull(pvi.cd_produto,0)>0 and isnull(p.cd_fase_produto_baixa,0)>0 then
      case when isnull(p.cd_produto_baixa_estoque,0)>0 then
           isnull((select ps.qt_saldo_atual_produto from Produto_Saldo ps
                   where ps.cd_produto=p.cd_produto_baixa_estoque and ps.cd_fase_produto = p.cd_fase_produto_baixa ),0) 
      else
          isnull((select ps.qt_saldo_atual_produto from Produto_Saldo ps
          where ps.cd_produto=pvi.cd_produto and ps.cd_fase_produto = p.cd_fase_produto_baixa ),0) 
      end
    else
      case when isnull(pvi.cd_produto,0)>0 and isnull(p.cd_fase_produto_baixa,0)=0 then
           case when isnull(p.cd_produto_baixa_estoque,0)>0 then
              isnull((select ps.qt_saldo_atual_produto from Produto_Saldo ps
                      where ps.cd_produto=p.cd_produto_baixa_estoque and ps.cd_fase_produto = @cd_fase_produto ),0) 
           else
              isnull((select ps.qt_saldo_atual_produto from Produto_Saldo ps
              where ps.cd_produto=pvi.cd_produto and ps.cd_fase_produto = @cd_fase_produto ),0) 
           end
      else
        0.00 end 
    end as 'qt_saldo_atual_produto',
    
    case when isnull(pvi.cd_produto,0)>0 and isnull(pvi.cd_fase_produto,0)>0 then
      case when isnull(p.cd_produto_baixa_estoque,0)>0 then
           isnull((select ps.qt_saldo_reserva_produto from Produto_Saldo ps
                   where ps.cd_produto=p.cd_produto_baixa_estoque and ps.cd_fase_produto = pvi.cd_fase_produto ),0) 
      else
          isnull((select ps.qt_saldo_reserva_produto from Produto_Saldo ps
          where ps.cd_produto=pvi.cd_produto and ps.cd_fase_produto = pvi.cd_fase_produto ),0) 
      end
    else
    case when isnull(pvi.cd_produto,0)>0 and isnull(p.cd_fase_produto_baixa,0)>0 then
      case when isnull(p.cd_produto_baixa_estoque,0)>0 then
           isnull((select ps.qt_saldo_reserva_produto from Produto_Saldo ps
                   where ps.cd_produto=p.cd_produto_baixa_estoque and ps.cd_fase_produto = p.cd_fase_produto_baixa ),0) 
      else
          isnull((select ps.qt_saldo_reserva_produto from Produto_Saldo ps
          where ps.cd_produto=pvi.cd_produto and ps.cd_fase_produto = p.cd_fase_produto_baixa ),0) 
      end
    else
      case when isnull(pvi.cd_produto,0)>0 and isnull(p.cd_fase_produto_baixa,0)=0 then
           case when isnull(p.cd_produto_baixa_estoque,0)>0 then
              isnull((select ps.qt_saldo_atual_produto from Produto_Saldo ps
                      where ps.cd_produto=p.cd_produto_baixa_estoque and ps.cd_fase_produto = @cd_fase_produto ),0) 
           else
              isnull((select ps.qt_saldo_reserva_produto from Produto_Saldo ps with (nolock) 
              where ps.cd_produto=pvi.cd_produto and ps.cd_fase_produto = @cd_fase_produto ),0) 
           end
      else
    case when isnull(pvc.cd_produto,0)>0 and isnull(prod.cd_fase_produto_baixa,0)>0 then
      case when isnull(prod.cd_produto_baixa_estoque,0)>0 then
           isnull((select ps.qt_saldo_reserva_produto from Produto_Saldo ps
                   where ps.cd_produto=prod.cd_produto_baixa_estoque and ps.cd_fase_produto = prod.cd_fase_produto_baixa ),0) 
      else
          isnull((select ps.qt_saldo_reserva_produto from Produto_Saldo ps
          where ps.cd_produto=pvc.cd_produto and ps.cd_fase_produto = prod.cd_fase_produto_baixa ),0) 
      end
    else
      case when isnull(pvc.cd_produto,0)>0 and isnull(prod.cd_fase_produto_baixa,0)=0 then
           case when isnull(prod.cd_produto_baixa_estoque,0)>0 then
              isnull((select ps.qt_saldo_atual_produto from Produto_Saldo ps
                      where ps.cd_produto=prod.cd_produto_baixa_estoque and ps.cd_fase_produto = @cd_fase_produto ),0) 
           else
              isnull((select ps.qt_saldo_reserva_produto from Produto_Saldo ps with (nolock) 
              where ps.cd_produto=pvc.cd_produto and ps.cd_fase_produto = @cd_fase_produto ),0) 
           end
      else
        0.00 end 
    end end end end as 'qt_saldo_reserva_produto',

    ltrim(rtrim((Case
     when (isnull(pvi.ic_kit_grupo_produto,'N')= 'S' or isnull(pvi.ic_produto_especial,'N') = 'S') then
      pvi.nm_produto_pedido
     else
		   case when (@ic_conversao_comercial = 'S') or (@ic_edita_produto_pedido = 'S') then 
			   pvi.nm_produto_pedido
			 else 
		     isnull(p.nm_produto,'') 
		   end
     end  )))+isnull(nm_kardex_item_ped_venda,'') as nm_produto,

   Case
     when isnull(pvi.ic_kit_grupo_produto,'N')= 'S' then
      ltrim(rtrim(pvi.nm_produto_pedido))
     else
	   case when isnull(pvc.cd_produto,0) <> 0 then
				ltrim(rtrim(prod.nm_produto))+ ' - '+ rtrim(ltrim(isnull(prod.cd_mascara_produto,'')))
			else case when isnull(pvi.cd_produto,0) = 0 then
      	ltrim(rtrim(isnull(p.nm_produto,gp.nm_grupo_produto)))+ ' - '+ rtrim(ltrim(isnull(p.cd_mascara_produto,gp.cd_mascara_grupo_produto)))
      else
        cast('' as varchar) end
     end end                                                          as nm_produto_codigo,

  case when isnull(pvc.cd_produto,0) <> 0 and isnull(pvi.cd_produto,0) = 0 then
  		isnull(prod.cd_mascara_produto,'')
	  else
      isnull(p.cd_mascara_produto,gp.cd_mascara_grupo_produto) end  as cd_mascara_produto,

    case when isnull(pvc.cd_produto,0) <> 0 and isnull(pvi.cd_produto,0) = 0 then
  		isnull(prod.nm_fantasia_produto,'')
	  else
      isnull(p.nm_fantasia_produto,'') end  as nm_fantasia_produto,
    pvi.cd_produto,
    case when isnull(pvc.cd_produto,0) <> 0 then
		u.sg_unidade_medida
	else
		um.sg_unidade_medida end         as sg_unidade_medida,
    dbo.fn_produto_localizacao(case when pvi.cd_produto = 0 then pvc.cd_produto else pvi.cd_produto end,
	case when isnull(p.cd_fase_produto_baixa,0)>0 then p.cd_fase_produto_baixa else 
	case when isnull(prod.cd_fase_produto_baixa,0)>0 then prod.cd_fase_produto_baixa else @cd_fase_produto end end) as localizacao,
    pvi.nm_obs_restricao_pedido,
    pvi.cd_usuario,
    pvi.dt_usuario,
    isnull(pvi.ic_kit_grupo_produto,'N') AS ic_kit_grupo_produto,
    ( select top 1 te.ic_ordem_separacao 
      from Pedido_Venda_Item_Embalagem pvie left outer join 
              Tipo_Embalagem te on te.cd_tipo_embalagem = pvie.cd_tipo_embalagem
      where pvie.cd_pedido_venda = pvi.cd_pedido_venda and
	pvie.cd_item_pedido_venda = pvi.cd_item_pedido_venda and
	te.ic_ordem_separacao = 'S' ) as 'ic_ordem_separacao_embalagem',
    CAST(pvi.qt_liquido_item_pedido AS float)                      as qt_liquido_item_pedido, 
    p.nm_marca_produto,
    pvs.dt_liberacao_separacao,
    isnull(p.ic_baixa_composicao_prod,'N') as ic_baixa_composicao_prod,
   pvi.dt_ordsep_pedido_venda,
    f.nm_fantasia_fornecedor, case when pum.qt_fator_produto_unidade <> 0 then 
		replace(cast(cast(isnull(pum.qt_fator_produto_unidade,0)as decimal(25,3)) as varchar(10)), '.',',') + um.sg_unidade_medida else um.sg_unidade_medida  end  as nm_fator_produto_unidade,
    pv.qt_bruto_pedido_venda, pv.qt_liquido_pedido_venda,
				case when @ic_conversao_comercial = 'S' then
      case when isnull(unid.sg_unidade_medida,'') = '' then 
			  replace(cast(cast(isnull(pvi.qt_saldo_pedido_venda,0)as decimal(25,3)) as varchar(12)),'.',',') + um.sg_unidade_medida 
			else
			  replace(cast(cast(isnull(pvi.qt_saldo_pedido_venda,0)as decimal(25,3)) as varchar(12)), '.',',') + isnull(unid.sg_unidade_medida,'') 
			end end as qt_saldo_pedido_conv
into
  #ItemSeparacaoRel
from
    Pedido_Venda_Item pvi                        with (nolock) 
    right outer join Pedido_Venda pv             with (nolock) on pvi.cd_pedido_venda        = pv.cd_pedido_venda
    left outer join Unidade_medida ump           with (nolock) on ump.cd_unidade_medida      = pvi.cd_unidade_medida
    left outer join Tipo_Entrega_Produto tep     with (nolock) on pv.cd_tipo_entrega_produto = tep.cd_tipo_entrega_produto
    left outer join Grupo_Produto gp             with (nolock) on gp.cd_grupo_produto        = pvi.cd_grupo_produto
    left outer join Produto p                    with (nolock) on p.cd_produto               = pvi.cd_produto
    left outer join Pedido_Venda_Item_Lote pvil  with (nolock) on pvi.cd_pedido_venda        = pvil.cd_pedido_venda and
    pvi.cd_item_pedido_venda      = pvil.cd_item_pedido_venda 
    left outer join Lote_Produto lp              with (nolock) on lp.cd_lote_produto         = pvil.cd_lote_produto
    left outer join Unidade_medida um            with (nolock) on um.cd_unidade_medida       = p.cd_unidade_medida
    left outer join EgisAdmin.dbo.Usuario us     with (nolock) on us.cd_usuario              = pvi.cd_usuario
    left outer join Pedido_Venda_Separacao pvs   with (nolock) on pvs.cd_pedido_venda        = pv.cd_pedido_venda and
                                                                  pvs.cd_item_pedido_venda   = pvi.cd_item_pedido_venda
    left outer join produto_compra pc            with (nolock) on pc.cd_produto              = p.cd_produto
    left outer join fornecedor f                 with (nolock) on f.cd_fornecedor            = pc.cd_fornecedor
    left outer join Pedido_Venda_Composicao pvc  with (nolock) on pvc.cd_pedido_venda        = pvi.cd_pedido_venda
                                                              and pvc.cd_item_pedido_venda   = pvi.cd_item_pedido_venda
    left outer join produto prod                 with (nolock) on prod.cd_produto            = pvc.cd_produto
	  left outer join Unidade_Medida u             with (nolock) on u.cd_unidade_medida        = prod.cd_unidade_medida
    left outer join Produto_unidade_medida pum with(nolock) on pum.cd_produto = pvi.cd_produto and pum.cd_unidade_origem = pvi.cd_unidade_medida
		left outer join Unidade_Medida unid          with (nolock) on unid.cd_unidade_medida        = pum.cd_unidade_origem
  where

     
    (isnull(pv.cd_pedido_venda,0) = case when isnull(@cd_documento,0) = 13 then @cd_pedido_venda else @cd_documento end  )  
    --and (pvi.qt_saldo_pedido_venda > 0)        
     and  pvi.dt_cancelamento_item is null

  order by
    pvi.cd_item_pedido_venda

--if @ic_liberacao_relatorio = 'N' 
--begin
--  delete from #ItemSeparacaoRel where dt_liberacao_separacao is null
--end

--if @ic_sep_ordem_localizacao='N'
--begin
--  select
--     *
--  from
--     #ItemSeparacaoRel  
--  order by
--    cd_item_pedido_venda
--end

--if @ic_sep_ordem_localizacao='S'
--begin
--  select
--     *
--  from
----     #ItemSeparacaoRel  
--  order by
--    cd_item_pedido_venda
--end
------------------------------------------------------------------------------------------------------------
select
 isnull(pv.cd_pedido_venda,0)                       as cd_pedido_venda,
 pv.cd_cliente                                      as cd_cliente,
 pv.dt_pedido_venda                                 as dt_pedido_venda, 
 pv.cd_pdcompra_pedido_venda                        as cd_pdcompra_pedido_venda, 
 pv.dt_credito_pedido_venda                         as dt_credito_pedido_venda,
 c.nm_razao_social_cliente                          as nm_razao_social_cliente,
 (select top 1 nm_contato_cliente from cliente_contato where cd_cliente = pv.cd_cliente and cd_contato = pv.cd_contato) as nm_contato_cliente,
 c.nm_fantasia_cliente,
 c.cd_ddd                  as ddd_cliente, 
 c.cd_telefone             as tel_cliente,
 RTrim(LTrim(IsNull(c.nm_endereco_cliente, ''))) as nm_endereco_cliente_entrega,
 RTrim(LTrim(ISnull(c.cd_numero_endereco,'')))   as cd_numero_endereco,
 c.nm_bairro               as nm_bairro_cliente_entrega,
 c.cd_cep                  as cd_cep_cliente,
 cid.nm_cidade             as nm_cidade_entrega,
 est.sg_estado             as sg_estado_entrega,
 (select top 1 nm_regiao_venda from regiao_venda where cd_regiao_venda = c.cd_regiao) as nm_regiao,
 (select top 1 nm_cliente_regiao
  from cliente_regiao where cd_cliente_regiao = c.cd_regiao) as nm_cliente_regiao,
  cet.ds_especificacao_tecnica,
 (select top 1 sp.sg_status_pedido from status_pedido sp where sp.cd_status_pedido = pv.cd_status_pedido) as 'sg_status_pedido',
 (SELECT nm_vendedor FROM Vendedor WHERE cd_vendedor = pv.cd_vendedor_interno) as nm_vendedor_interno,
 (SELECT nm_vendedor FROM Vendedor WHERE cd_vendedor = pv.cd_vendedor)         as nm_vendedor_pedido,
 pv.cd_transportadora           as cd_transportadora, 
 (select top 1 tp.nm_tipo_pedido from tipo_pedido tp where tp.cd_tipo_pedido = pv.cd_tipo_pedido) as nm_tipo_pedido,
 (select top 1 tp.sg_tipo_pedido from tipo_pedido tp where tp.cd_tipo_pedido = pv.cd_tipo_pedido) as sg_tipo_pedido,
 tp.cd_tipo_pedido as cd_tipo_pedido,
 t.nm_fantasia             as nm_fantasia_transportadora,
 pv.ds_observacao_pedido       as ds_observacao_pedido,
 pv.dt_fechamento_pedido                                     as dt_fechamento_pedido,
 right(left(convert(varchar,pv.hr_inicial_pedido,121),16),5) as hr_pedido,
 l.sg_loja, IsNull(l.cd_loja,0) as cd_loja,
 cp.nm_condicao_pagamento                                    as nm_condicao_pagamento,
 td.nm_tipo_documento, 
 it.nm_itinerario                                            as nm_itinerario,
 pv.ic_alteracao_pedido_venda, 
 pv.dt_alteracao_pedido_venda, 
 pv.cd_usuario_alteracao, 
 pv.nm_alteracao_pedido_venda,
 tpf.nm_tipo_pagamento_frete,
 cg.nm_cliente_grupo,
 case when isnull(fp.nm_forma_pagamento,'') <> '' then fp.nm_forma_pagamento else fpc.nm_forma_pagamento end as nm_forma_pagamento,
 dp.nm_destinacao_produto                      as nm_destinacao_produto,
 ef.nm_empresa                                 as nm_empresa_faturamento,
 ef.nm_fantasia_empresa                        as nm_fantasia_empresa,
 isnull(cr.nm_cliente_regiao,'')               as nm_cliente_regiao_cli, 
 pv.ds_obs_fat_pedido, 
 tep.nm_tipo_entrega_produto,
 isnull(tp.nm_titulo_tipo_pedido,'')           as nm_titulo_tipo_pedido, 
 isnull(tp.ic_quantidade_inteira,'N')          as ic_quantidade_inteira,
 --Dados da Transportadora--
 '('+ltrim(rtrim(t.cd_ddd))+')-'+ltrim(rtrim(t.cd_telefone)) as fone_transportadora,
 t.nm_endereco                                 as nm_endereco_transportadora,
 t.cd_numero_endereco                          as cd_numero_endereco_transportadora,
 t.nm_bairro                                   as nm_bairro_transportadora,
 pa.nm_pais                                     as nm_pais,
 esta.nm_estado                                   as nm_estado
 INTO
 #RelOrdemServicoCapa

from
 pedido_venda pv with (nolock)
 inner join (select distinct cd_pedido_venda from pedido_venda_item with (nolock) )pvi on pvi.cd_pedido_venda = pv.cd_pedido_venda
 left outer join transportadora t          with (nolock)    on t.cd_transportadora = pv.cd_transportadora
 left outer join cliente c                 with (nolock)  on c.cd_cliente = pv.cd_cliente
 left outer join cliente_especificacao_tecnica cet with (nolock) on cet.cd_cliente = pv.cd_cliente
 left outer join cidade cid                with (nolock)  on cid.cd_pais = c.cd_pais and cid.cd_estado = c.cd_estado and cid.cd_cidade = c.cd_cidade
 left outer join estado est                with (nolock)  on est.cd_pais = c.cd_pais and est.cd_estado = c.cd_estado
 left outer join loja l                    with (nolock)  on l.cd_loja = pv.cd_loja
 left outer join Condicao_Pagamento cp     with (nolock)  on cp.cd_condicao_pagamento = pv.cd_condicao_pagamento
 left outer join tipo_documento td         with (nolock)  on td.cd_tipo_documento = pv.cd_tipo_documento
 left outer join tipo_pagamento_frete tpf  with (nolock) on tpf.cd_tipo_pagamento_frete = pv.cd_tipo_pagamento_frete
 left outer join cliente_grupo cg          with (nolock) on cg.cd_cliente_grupo = c.cd_cliente_grupo
 left outer join Cliente_Informacao_Credito cic with(nolock) on cic.cd_cliente = c.cd_cliente
 left outer join forma_pagamento fp        with (nolock) on fp.cd_forma_pagamento = pv.cd_forma_pagamento
 left outer join forma_pagamento fpc       with (nolock) on fpc.cd_forma_pagamento = cic.cd_forma_pagamento
 left outer join destinacao_produto dp     with (nolock) on dp.cd_destinacao_produto = pv.cd_destinacao_produto
 left outer join cliente_regiao cr         with (nolock) on cr.cd_cliente_regiao = c.cd_regiao
 left outer join Tipo_Entrega_Produto tep  with(nolock) on tep.cd_tipo_entrega_produto = pv.cd_tipo_entrega_produto
 left outer join Tipo_pedido tp			   with(nolock) on tp.cd_tipo_pedido = pv.cd_tipo_pedido
 left outer join Pedido_Venda_Empresa pve  with(nolock) on pve.cd_pedido_venda = pv.cd_pedido_venda
 left outer join Empresa_Faturamento ef    with(nolock) on ef.cd_empresa = pve.cd_empresa
 left outer join Itinerario it			   with(nolock) on it.cd_itinerario = c.cd_itinerario
 left outer join pais pa                   with(nolock) on pa.cd_pais = t.cd_pais
 left outer join estado esta               with (nolock) on esta.cd_pais = t.cd_pais and esta.cd_estado = t.cd_estado

where
isnull(pv.cd_pedido_venda,0) = case when isnull(@cd_documento,0) = 13 then @cd_pedido_venda else @cd_documento end  

and
--1 = case when (not exists(select isnull(am.cd_documento,0) from Aprovacao_Movimento am where am.cd_documento = pv.cd_pedido_venda and isnull(am.dt_aprovacao_movimento,'') <> '')) 
--        and (tp.ic_aprovacao_tipo_pedido = 'S') then 2 else 1 end and
isnull(tp.ic_ordsep_tipo_pedido,'N') = 'S' 
--  and
-- (pv.cd_pedido_venda in (select distinct pvi.cd_pedido_venda
--                         from Pedido_Venda_Item pvi right outer join
--                              Pedido_Venda pv on pvi.cd_pedido_venda = pv.cd_pedido_venda left outer join
--                              Grupo_Produto gp on gp.cd_grupo_produto = pvi.cd_grupo_produto
--                         where
--                       (1=1) 
--  and  (pv.dt_cancelamento_pedido is null) 
--  and   pvi.dt_cancelamento_item is null   
--  and  (pvi.qt_saldo_pedido_venda > 0) 
--  and
----                           isnull(pvi.ic_ordsep_pedido_venda,'N')  <>'S' and
----                           isnull(gp.ic_especial_grupo_produto,'N')<>'S' and
--                           isnull(pv.ic_fechado_pedido,'N')='S'
--                        ))
--( (
--                               (pvi.qt_saldo_pedido_venda > 0) AND (isnull(gp.ic_especial_grupo_produto,'N') <> 'S')
--                               ) OR (isNull(pvi.ic_kit_grupo_produto,'N') ='S' )
--                              )
--                         )
-- )                        
order by
  pv.cd_pedido_venda, pv.dt_pedido_venda

 
------------------------------------------------------------------------------------------------------------
 --if isnull(@cd_parametro,0) = 1  
 --begin  
 --   select * from #rel_pagamento_hoje  
 -- return  
 --end 
-------------------------------------------------------------------------------------------------------------
DECLARE 
    @dt_pedido_venda               DATETIME, 
    @cd_pdcompra_pedido_venda      varchar(20) = '',
    @dt_credito_pedido_venda       DATETIME ,
    @nm_contato_cliente            varchar(200) = '',
    @nm_fantasia_cliente           varchar(200) = '',
    @ddd_cliente                   varchar(5) = '',
    @tel_cliente                   varchar(20) = '',
    @nm_endereco_cliente_entrega   varchar(200) = '',
    @cd_numero_endereco_cliente    varchar(20) = '',
    @nm_bairro_cliente_entrega     varchar(100) = '',
    @cd_cep_cliente                varchar(20) = '',
    @nm_cidade_entrega             varchar(100) = '',
    @sg_estado_entrega             varchar(10) = '',
    @nm_regiao                     varchar(100) = '',
    @nm_cliente_regiao             varchar(100) = '',
    @ds_especificacao_tecnica      varchar(500) = '',
    @sg_status_pedido              varchar(50) = '',
    @nm_vendedor_interno           varchar(200) = '',
    @nm_vendedor_pedido            varchar(200) = '',
    @cd_transportadora             INT = 0,
    @nm_tipo_pedido                varchar(100) = '',
    @sg_tipo_pedido                varchar(50) = '',
    @nm_fantasia_transportadora    varchar(200) = '',
    @ds_observacao_pedido          varchar(1000) = '',
    @dt_fechamento_pedido          DATETIME = NULL,
    @hr_pedido                     varchar(5) = '',
    @sg_loja                       varchar(50) = '',
    @cd_loja                       INT = 0,
    @nm_condicao_pagamento         varchar(100) = '',
    @nm_tipo_documento             varchar(100) = '',
    @nm_itinerario                 varchar(100) = '',
    @ic_alteracao_pedido_venda     CHAR(1) = 'N',
    @dt_alteracao_pedido_venda     DATETIME = NULL,
    @cd_usuario_alteracao          INT = 0,
    @nm_alteracao_pedido_venda     varchar(200) = '',
    @nm_tipo_pagamento_frete       varchar(100) = '',
    @nm_cliente_grupo              varchar(100) = '',
    @nm_forma_pagamento            varchar(100) = '',
    @nm_destinacao_produto         varchar(100) = '',
    @nm_empresa_faturamento        varchar(200) = '',
    @ds_obs_fat_pedido             varchar(1000) = '',
    @nm_tipo_entrega_produto       varchar(100) = '',
    @nm_titulo_tipo_pedido         varchar(100) = '',
    @ic_quantidade_inteira         CHAR(1) = 'N',
    @nm_transportadora             varchar(200) = '',
    @fone_transportadora           varchar(20) = '',
	@nm_endereco_transportadora    varchar(100) = '',
	@cd_numero_endereco_transpor   varchar(15) = '',
	@nm_bairro_transportadora      varchar(60 ) = '',
	@qt_total_produto              int = 0,
	@vl_total_produto              float = 0,
    @vl_liquido_total              float = 0,
	@nm_pais_transp                varchar(40),
    @nm_estado_transp              varchar(40),
	@cd_tipo_pedido                int = 0
--------------------------------------------------------------------------------------------------------------



select 
    @dt_pedido_venda                  = dt_pedido_venda,
    @cd_pdcompra_pedido_venda         = cd_pdcompra_pedido_venda,
    @cd_cliente                       = cd_cliente,     
    @nm_contato_cliente               = nm_contato_cliente,
    @nm_fantasia_cliente              = nm_fantasia_cliente,
    @nm_razao_social_cliente          = nm_razao_social_cliente,      
    @ddd_cliente                      = ddd_cliente,
    @tel_cliente                      = tel_cliente,
    @nm_endereco_cliente_entrega      = nm_endereco_cliente_entrega,
    @cd_numero_endereco_cliente       = cd_numero_endereco,
    @nm_bairro_cliente_entrega        = nm_bairro_cliente_entrega,
    @cd_cep_cliente                   = cd_cep_cliente,
    @nm_cidade_entrega                = nm_cidade_entrega,
    @sg_estado_entrega                = sg_estado_entrega,
    @nm_regiao                        = nm_regiao,
    @nm_cliente_regiao                = nm_cliente_regiao,
    @nm_vendedor_interno              = nm_vendedor_interno,    
    @nm_vendedor_pedido               = nm_vendedor_pedido,
    @cd_transportadora                = cd_transportadora,             
    @nm_fantasia_transportadora       = nm_fantasia_transportadora,         
    @dt_fechamento_pedido             = dt_fechamento_pedido,
    @hr_pedido                        = hr_pedido,                   
    @nm_condicao_pagamento            = nm_condicao_pagamento,
    @nm_itinerario                    = nm_itinerario,
    @nm_forma_pagamento               = nm_forma_pagamento,
    @nm_destinacao_produto            = nm_destinacao_produto,      
    @nm_empresa_faturamento           = nm_empresa_faturamento,
    @fone_transportadora              = fone_transportadora,
    @nm_endereco_transportadora       = nm_endereco_transportadora,
    @cd_numero_endereco_transpor      = cd_numero_endereco_transportadora,
    @nm_bairro_transportadora         = nm_bairro_transportadora,
	@nm_tipo_pedido                   = nm_tipo_pedido,
	@sg_tipo_pedido                   = sg_tipo_pedido,
	@nm_pais_transp                   = nm_pais,
	@nm_estado_transp                 = nm_estado,
	@nm_fantasia_empresa              = nm_fantasia_empresa,
	@cd_tipo_pedido                   = cd_tipo_pedido,
	@ds_observacao_pedido             = ds_observacao_pedido
from #RelOrdemServicoCapa
select 
	@qt_total_produto = count(cd_item_pedido_venda),
	@vl_total_produto = sum(qt_item_pedido_venda),
	@vl_liquido_total = SUM(qt_liquido_item_pedido) 

from #ItemSeparacaoRel

--------------------------------------------------------------------------------------------------------------
set @html_detalhe = '' 
set @html_geral = '
	<div style="width:20%; text-align: right;padding-right:20px; font-size: 20px;color: red;">
            <p>Pedido</p> 
            <p> '+case when isnull(@cd_pedido_venda,0) = 0 then ''+cast(isnull(@cd_documento,0)as varchar(20))+'' else ''+cast(isnull(@cd_pedido_venda,0)as varchar(20))+'' end+'</p>
            <p>'+isnull(@nm_tipo_pedido,'')+'</p>'+
            case when @cd_tipo_pedido in (1,3,4,8,9,11,14,15,17) then '<p>'+isnull(@sg_tipo_pedido,'')+'</p>' else '' end+'
        </div>    
    </div><h1 style="text-align: center;">Ordem de Separação</h1>
    <p class="section-title" style="font-weight: bold;text-align: left; font-size: 18px;">Favorecido</p>
    <table style="width: 100%;">
        <tr>
            <td style="display: flex; flex-direction: column; gap: 20px;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
                    <div style="text-align: left; width: 45%;">
                        <p><strong>Cliente:</strong> '+isnull(@nm_razao_social_cliente,'')+'</p>
                        <p><strong>Fone:</strong> '+ case when isnull(@tel_cliente,'') <> ''
						then ''+cast(isnull(@ddd_cliente,'')as varchar(20))+' '+isnull(@tel_cliente,'')+'' else 'SEM DESCRIÇÃO' end +' 	
						</p>

                        <p><strong>Contato:</strong> '+ case when isnull(@nm_contato_cliente,'') <> ''
						then ''+isnull(@nm_contato_cliente,'')+'' else 'SEM DESCRIÇÃO' end +' 	
						</p>
                    </div>
                    <div style="text-align: left;">
                        <p><strong>Fantasia: </strong>'+isnull(@nm_fantasia_cliente,'')+'</p>

                        <p><strong>Código: </strong>'+cast(isnull(@cd_cliente,'')as varchar(20))+'</p>
                    <div >    
                            <td style="text-align: center;"><strong>Emissão Pedido</strong><br><br>'+isnull(dbo.fn_data_string(@dt_pedido_venda),'')+' '+isnull(@hr_pedido,'')+'</td>

                            <td style="text-align: center;"><strong>Fechamento</strong><br><br>'+ case when isnull(@dt_fechamento_pedido,'')<>'' then ''+isnull(dbo.fn_data_string(@dt_fechamento_pedido),'')+'' else 'SEM DATA' END +'</td>
                    </div>
                </div>
                </div>
            </td>
        </tr>
    </table>
    <p class="section-title" style="font-weight: bold;text-align: left;font-size: 18px;">Entrega</p>
    <table style="width: 100%;">
        <tr>
            <td style="display: flex; flex-direction: column; gap: 20px;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
                    <div style="text-align: left; width: 45%;">
                        <p><strong>Endereço:</strong> '+ case when isnull(@nm_endereco_cliente_entrega,'') <> ''
						then ''+isnull(@nm_endereco_cliente_entrega,'')+'' else 'SEM DESCRIÇÃO' end +'</p>
                        <p><strong>Nº:</strong> '+ case when +isnull(@nm_bairro_cliente_entrega,'') <> ''
						then ''+cast(isnull(@cd_numero_endereco_cliente,'')as varchar(20))+'' else 'SEM DESCRIÇÃO' end +'
						</p>
                        <p><strong>Bairro:</strong> '+ case when isnull(@cd_numero_endereco_cliente,'') <> ''
						then ''+isnull(@nm_bairro_cliente_entrega,'')+'' else 'SEM DESCRIÇÃO' end +' 
						</p>
                    </div>
                    <div style="text-align: left;">
                        <p><strong>Estado:</strong> '+ case when isnull(@sg_estado_entrega,'') <> ''
						then ''+isnull(@sg_estado_entrega,'')+'' else 'SEM DESCRIÇÃO' end +' 
						</p>
                        <p><strong>Cidade: </strong>  '+ case when isnull(@nm_cidade_entrega,'') <> ''
						then ''+isnull(@nm_cidade_entrega,'')+'' else 'SEM DESCRIÇÃO' end +' 
						</p>
                        <p><strong>Região: </strong> '+ case when isnull(@nm_regiao,'') <> ''
						then ''+isnull(@nm_regiao,'')+'' else 'SEM DESCRIÇÃO' end +' 
						</p>
                        <p><strong>CEP:</strong> '+ case when isnull(@cd_cep_cliente,'') <> ''
						then ''+isnull(dbo.fn_formata_cep(@cd_cep_cliente),'')+'' else 'SEM DESCRIÇÃO' end +' 
						</p>
                    </div>
                </div>
            </td>
        </tr>
    </table>
    <p class="section-title" style="font-weight: bold;text-align: left;font-size: 18px;">Transportadora</p>
    <table style="width: 100%;">
        <tr>
            <td style="display: flex; flex-direction: column; gap: 20px;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
                    <div style="text-align: left; width: 45%;">
                        <p><strong>'+ case when isnull(@cd_transportadora,'') <> ''
						then ''+cast(isnull(@cd_transportadora,'')as varchar(20))+'' else 'SEM DESCRIÇÃO' end +' 
						</strong></p>
                        <p><strong>	'+ CASE WHEN isnull(@nm_fantasia_transportadora,'') <> '' 
						then ''+isnull(@nm_fantasia_transportadora,'')+'' else 'SEM DESCRIÇÃO' end +'
						</strong></p>
                        <p>'+isnull(@nm_endereco_transportadora,'')+'
						'+
						case when isnull(@cd_numero_endereco_transpor,'') <> '' 
						  then' , '+cast(isnull(@cd_numero_endereco_transpor,'')as varchar(20))+'' else '' end +' 
					 '+ case when isnull(@nm_bairro_transportadora,'') <> ''
					      then ' - '+isnull(@nm_bairro_transportadora,'')+'' else '' end +'			
					 '+ case when isnull(@nm_estado_transp,'') <> ''
						  then ' - '+isnull(@nm_estado_transp,'')+'' else '' end +'
					 '+ case when isnull(@nm_pais_transp,'') <> '' 
						  then ' / '+isnull(@nm_pais_transp,'')+'' else '' end +'
					 </p> 
                        
                    </div>
                    <div style="text-align: left;">
                        <p><strong>Fone:</strong> '+case when isnull(@fone_transportadora,'') <> '' then ''+isnull(@fone_transportadora,'')+'' else 'SEM DESCRIÇÃO' end +'</p>
                        <p><strong>Destinação:</strong>'+ case when isnull(@nm_destinacao_produto,'') <> '' then ''+isnull(@nm_destinacao_produto,'')+'' else 'SEM DESCRIÇÃO' END +'</p>
                        <p></p>
                    </div>
                </div>
            </td>
        </tr>
    </table>
	<table class="tamanhoTabela">
        <tr>
            <th>Item</th>
            <th>Descrição</th>
            <th>UN.</th>
            <th>QTD.</th>
            <th>Pedido</th>   
            <th>Peso Liq.</th>
            <th>Código</th>
            <th>Entrega</th>
            <th>Localização</th>
            <th>Disponivel</th>
        </tr>'

--------------------------------------------------------------------------------------------------------------------

declare @id int = 0 
while exists ( select cd_controle from #ItemSeparacaoRel )  
begin  
  
  select top 1  
    @id           = cd_controle,  

    @html_detalhe = @html_detalhe + '  
           <tr >      
            <td >'+cast(isnull(cd_item_pedido_venda,0) as varchar(20))+'</td>  
			<td style="text-align: left">'+isnull(nm_produto,'')+'</td>  
			<td>'+isnull(nm_unidade_medida,'')+'</td>
			<td>'+cast(isnull(qt_item_pedido_venda,0) as varchar(20))+'</td> 
			<td><div style="width: 20px; height: 20px; border: 2px solid black; display: inline-block;"></div></td>   
		    <td>'+isnull(dbo.fn_formata_valor_decimal(qt_liquido_item_pedido,3),0) +'</td>     
            <td>'+cast(cd_mascara_produto as varchar(20))+'</td>     
		    <td>'+isnull(dbo.fn_data_string(dt_entrega_vendas_pedido),'')+'</td>     
            <td>'+isnull(localizacao,'') + '</td> 
			<td>'+cast(isnull(qt_saldo_atual_produto,0) as varchar(20))+'</td>
           </tr>'  
         
  from  
    #ItemSeparacaoRel  
  
  order by  
    cd_controle  
      


  delete from #ItemSeparacaoRel  where  cd_controle = @id  
  
  
end  
                 
      
--------------------------------------------------------------------------------------------------------------------


set @html_rodape ='        <tr>
            <td><strong>Total</strong></td>
            <td><strong>'+cast(isnull(@qt_total_produto,'')as varchar(20))+'</strong></td>
            <td></td>
            <td><strong>'+cast(isnull(@vl_total_produto,'')as varchar(20))+'</strong></td>
            <td></td>
            <td><strong>'+cast(isnull(dbo.fn_formata_valor_decimal(@vl_liquido_total,3),0)as varchar(25))+'</strong></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
    </table>
    <table style="width: 100%;">
        <tr>
            <td style="display: flex; flex-direction: column; gap: 20px; ">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
                    <div style="text-align: left; width: 45%;">
                        <p><strong>Pedido de Compra Cliente:</strong> '+ case when isnull(@cd_pdcompra_pedido_venda,'') <> ''
						then ''+cast(isnull(@cd_pdcompra_pedido_venda,'')as varchar(20))+'' else 'SEM DESCRIÇÃO' end +' 
						 </p>
                        <p><strong>Vendedor Interno:</strong> '+ case when isnull(@nm_vendedor_interno,'') <> ''
						then ''+isnull(@nm_vendedor_interno,'')+'' else 'SEM DESCRIÇÃO' end +' 
						</p>
                        <p><strong>Empresa Faturamento:</strong> '+ case when isnull(@nm_empresa_faturamento,'') <> ''
						then ''+isnull(@nm_empresa_faturamento,'')+'' else 'SEM DESCRIÇÃO' end +' 
						</p>
                        <p> '+ case when isnull(@nm_fantasia_empresa,'') <> ''
						then ''+isnull(@nm_fantasia_empresa,'')+'' else 'SEM DESCRIÇÃO' end +' 
						</p>
                    </div>
                    <div style="text-align: left;">
                        <p><strong>Condição de Pagamento:</strong> '+ case when isnull(@nm_condicao_pagamento,'') <> ''
						then ''+isnull(@nm_condicao_pagamento,'')+'' else 'SEM DESCRIÇÃO' end +' 
						</p>
                        <p><strong>Forma de Pagamento:</strong> '+ case when isnull(@nm_forma_pagamento,'') <> ''
						then ''+isnull(@nm_forma_pagamento,'')+'' else 'SEM DESCRIÇÃO' end +' 
						</p>
                        <p><strong>Vendedor Externo:</strong> '+ case when isnull(@nm_vendedor_pedido,'') <> ''
						then ''+isnull(@nm_vendedor_pedido,'')+'' else 'SEM DESCRIÇÃO' end +'
						</p>
                        <p><strong>Rota:</strong> '+ case when isnull(@nm_itinerario,'') <> ''
						then ''+isnull(@nm_itinerario,'')+'' else 'SEM DESCRIÇÃO' end +'
						</p>
                    </div>
                </div>
            </td>
        </tr>
    </table>
	    <table>
        <tr >
            <td style="text-align: left;"><strong>Observação: </strong>'+ case when isnull(@ds_observacao_pedido,'') <> ''then ''+isnull(@ds_observacao_pedido,'')+'' else 'SEM DESCRIÇÃO' end +'</td>
        </tr>
    </table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	</div>
    <div class="report-date-time" style="text-align:right">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p><br>
	   <p style="font-size: 18px;"><b>Pedido: '+cast(isnull(@cd_pedido_venda,0)as varchar(20))+'</b></p>
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

---------------------

select 'OrdemSeparacao_'+CAST(ISNULL(@cd_pedido_venda, 0) AS NVARCHAR) AS pdfName,isnull(@html,'') as RelatorioHTML

-------------------------------------------------------------------------------------------------------------------------------------------------------
--select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_ordem_separacao 253,0,''
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao '[{"cd_documento_form": 170985, "cd_empresa": 317, "cd_item_documento_form": "0", "cd_item_processo": "", "cd_menu": 7852, "cd_modulo": 212, "cd_parametro": "0", "cd_processo": "", "cd_relatorio": 264, "cd_usuario": 4357}]'