IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_meta_objetivo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_meta_objetivo

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_meta_objetivo
-------------------------------------------------------------------------------
--pr_relatorio_meta_objetivo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : João Pedro Marcal
--
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 24.08.2024
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_relatorio_meta_objetivo
@cd_relatorio int   = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')
declare @data_grafico_bar       nvarchar(max)
declare @cd_empresa             int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @cd_status              int = 0
declare @cd_tecnico             int = 0 
declare @cd_tipo_defeito        int = 0
declare @cd_marca_produto       int = 0 
--declare @cd_relatorio           int = 0

--Dados do Relatório---------------------------------------------------------------------------------

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
			@nm_fantasia_cliente  	    varchar(200) = '',
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_razao_social_cliente	varchar(200) = '',
			@nm_endereco_cliente		varchar(200) = '',
			@nm_bairro					varchar(200) = '',
			@nm_cidade_cliente			varchar(200) = '',
			@sg_estado_cliente			varchar(5)	= '',
			@cd_numero_endereco			varchar(20) = '',
			@cd_telefone				varchar(20) = '',
			@nm_condicao_pagamento		varchar(100) = '',
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

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
set @cd_parametro      = 0
set @cd_empresa        = 0
set @cd_form           = 0
set @cd_parametro      = 0
set @cd_documento      = 0
set @dt_usuario        = GETDATE()
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
 --@dt_inicial, @dt_final , @cd_status , @cd_tecnico , @cd_tipo_defeito , @cd_marca_produto
-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_status              = valor from #json where campo = 'cd_status'
  select @cd_tecnico             = valor from #json where campo = 'cd_tecnico'
  select @cd_tipo_defeito        = valor from #json where campo = 'cd_tipo_defeito'
  select @cd_marca_produto       = valor from #json where campo = 'cd_marca_produto'
  
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
  @titulo      = nm_relatorio,
  @ic_processo = isnull(ic_processo_relatorio, 'N')
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio

----------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------

 --select @cd_processo as cd_processo, @json as jsonT into JsonProcesso
  --select * from JsonProcesso
  --drop table JsonProcesso

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

-----------------------------------------------------------------------------------------
--Empresa
----------------------------------
set @cd_empresa = dbo.fn_empresa()
-----------------------------------

	--Dados da empresa-----------------------------------------------------------

	select 
		@logo = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),
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


---------------------------------------------------------------------------------------------------------------------------------------------
--Dados do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------

declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabeçalho da Empresa
declare @html_titulo     nvarchar(max) = '' --Título
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe
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

-- Obtém a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------
--Título do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio


--select @titulo
--
--select @nm_cor_empresa
-----------------------
--Cabeçalho da Empresa----------------------------------------------------------------------------------------------------------------------
-----------------------

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
            font-size: 95%;
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

--select @html_empresa

		

--Detalhe--
--Procedure de Cada Relatório-------------------------------------------------------------------------------------

select a.*, g.nm_grupo_relatorio into #RelAtributo 
from
  egisadmin.dbo.Relatorio_Atributo a 
  left outer join egisadmin.dbo.relatorio_grupo g on g.cd_grupo_relatorio = a.cd_grupo_relatorio
where 
  a.cd_relatorio = @cd_relatorio
order by
  qt_ordem_atributo

declare @cd_item_relatorio  int           = 0
declare @nm_cab_atributo    varchar(100)  = ''
declare @nm_dados_cab_det   nvarchar(max) = ''
declare @nm_grupo_relatorio varchar(60)   = ''


--select * from egisadmin.dbo.relatorio_grupo

select * into #AuxRelAtributo from #RelAtributo order by qt_ordem_atributo

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
declare @nm_periodo         varchar(20) = ''
--------------------------------------------------------------------------------------------------------------------------

 set @cd_empresa             = dbo.fn_empresa()

declare @ic_produto_faturamento char(1)
set @ic_produto_faturamento = 'N'
select
  @ic_produto_faturamento = isnull(ic_produto_faturamento,'N')
from
  config_egismob with (nolock)
where
  cd_empresa = @cd_empresa

  --set @dt_inicial = '01/01/2025'
  --set @dt_final = '01/31/2025'
----------------------------------------------------------------------------------------------------------------------------------
  set @cd_ano = year(@dt_inicial)      
  set @cd_mes = month(@dt_inicial)  
select
  @nm_periodo = m.nm_mes + '/' + cast(@cd_ano as varchar(4))
from
  Mes m
where
  cd_mes = @cd_mes
 -- select @nm_periodo
       
    
     
---------------------------------------------------------------------------------------------------------------------------

declare @cd_vendedor        int = 0  
declare @vl_total           decimal(25,2) = 0.00
declare @vl_meta            decimal(25,2) = 0.00
declare @qt_base_cliente    decimal(25,2) = 0
declare @qt_base_positivada decimal(25,2) = 0
declare @pc_atingido        decimal(25,2) = 0.00
declare @pc_base_atingida   decimal(25,2) = 0.00
--------------------------------------------------------------------------------------------------------------------------

select 

  @qt_base_cliente = count(distinct c.cd_cliente )
   
from 
   cliente c 
   inner join Vendedor v on v.cd_vendedor = c.cd_vendedor
 where 
   c.cd_vendedor = case when @cd_vendedor = 0 then c.cd_vendedor else @cd_vendedor end
   and
   c.cd_status_cliente = 1
   and
   isnull(v.ic_egismob_vendedor,'S') = 'S'

--Positivação---

select
   n.cd_vendedor,
   COUNT(distinct n.cd_cliente)                     as qt_cliente_positivado
into
  #Positivacao

from
  nota_saida n
  inner join Operacao_Fiscal opf                     on opf.cd_operacao_fiscal     = n.cd_operacao_fiscal
  inner join Grupo_Operacao_Fiscal g                 on g.cd_grupo_operacao_fiscal = opf.cd_grupo_operacao_fiscal
  inner join vendedor v                              on v.cd_vendedor              = n.cd_vendedor

where
  n.cd_vendedor = case when @cd_vendedor = 0 then n.cd_vendedor else @cd_vendedor end 
  and
  n.dt_nota_saida between @dt_inicial and @dt_final
  and
  n.cd_status_nota<>7
  and
  isnull(v.ic_egismob_vendedor,'S') = 'S'
  and
	isnull(opf.ic_comercial_operacao,'N')  = 'S'
	and
	IsNull(opf.ic_analise_op_fiscal,'S') = 'S' 
	and
	g.cd_tipo_operacao_fiscal = 2

group by
  n.cd_vendedor
  
--Verifica qual o último pedido do vendedor------------------------

select
  pv.cd_vendedor,
  max(pv.dt_pedido_venda) as dt_pedido_venda

into #venda

from
  pedido_venda pv
  inner join vendedor v on v.cd_vendedor = pv.cd_vendedor
where
  pv.cd_status_pedido <> 7 --select * from status_pedido
  and
  isnull(v.ic_egismob_vendedor,'S') = 'S'

group by
  pv.cd_vendedor



--select * from #Positivacao


    SELECT   
      --IDENTITY(INT,1,1)                 AS cd_controle,  
      v.cd_vendedor,
      MAX(v.nm_vendedor)                AS nm_vendedor,  
      m.dt_inicio_meta_vendedor,
      m.dt_final_meta_vendedor,
     -- max(ISNULL(  
     --    --CASE WHEN ISNULL(m.vl_meta_vendedor,0) = 0 THEN  
     --   v.vl_meta  
     --  -- ELSE  
     -- --        ISNULL(m.vl_meta_vendedor,0)  
     ----      END  
     -- ,0)) AS vl_meta_vendedor,  
	    max(isnull(v.vl_meta,0))				  as vl_meta_vendedor,
      SUM(ISNULL(m.qt_meta_vendedor,0)) AS qt_meta_vendedor,  
      (SELECT --SUM(vl_total) 
         case when @ic_produto_faturamento = 'N' then
           round(sum(isnull(vw.vl_unitario_item_total,0)),2) - sum(isnull(vw.vl_item_desconto,0))
         else
           round(sum(isnull(vw.vl_unitario_item_total,0)),2) - sum(isnull(vw.vl_item_desconto,0)) - sum(isnull(vw.vl_ipi,0))
         end
            FROM 
              vw_faturamento_bi vw
              left outer join vendedor vd on vd.cd_vendedor = vw.cd_vendedor
			WHERE 
				vd.cd_vendedor = CASE WHEN ISNULL(@cd_parametro,0) = 0 THEN v.cd_vendedor ELSE ISNULL(@cd_parametro,0) END 
				AND vw.dt_nota_saida BETWEEN @dt_inicial AND @dt_final
				and vw.cd_status_nota <> 7 
		) AS vendido,
      (SELECT COUNT(distinct c.cd_cliente) FROM Cliente c WHERE c.cd_vendedor = v.cd_vendedor and cd_status_cliente = 1 ) AS qt_cliente,
      (SELECT COUNT(DISTINCT cd_produto) FROM Nota_Saida_Item nsi
        LEFT OUTER JOIN Nota_Saida ns ON ns.cd_nota_saida = nsi.cd_nota_saida
            WHERE 
                ns.cd_vendedor = CASE WHEN ISNULL(@cd_parametro,0) = 0 THEN v.cd_vendedor ELSE ISNULL(@cd_parametro,0) END 
                AND ns.dt_nota_saida BETWEEN @dt_inicial AND @dt_final
        ) AS qt_produto,
		
      MAX(ISNULL(v.qt_meta_cadastro,0)) AS qt_meta_cadastro,
  
      isnull(
      (select --sum(isnull(vl_total,0)) 
         case when @ic_produto_faturamento = 'N' then
           round(sum(isnull(wdm.vl_unitario_item_total,0)),2) - sum(isnull(wdm.vl_item_desconto,0))
         else
           round(sum(isnull(wdm.vl_unitario_item_total,0)),2) - sum(isnull(wdm.vl_item_desconto,0)) - sum(isnull(wdm.vl_ipi,0))
         end
         from vw_faturamento_devolucao_bi wdm
         left outer join vendedor vd on vd.cd_vendedor = wdm.cd_vendedor
        where wdm.cd_vendedor = CASE WHEN ISNULL(@cd_parametro,0) = 0 THEN v.cd_vendedor ELSE ISNULL(@cd_parametro,0) END 
                AND wdm.dt_restricao_item_nota BETWEEN @dt_inicial AND @dt_final
                and isnull(vd.ic_ativo,'N')='S' 
                and wdm.cd_status_nota <> 7  
                and wdm.cd_tipo_destinatario = 1),0) 
      + 
	  ISNULL(
      (select --sum(isnull(vl_total,0)) 
         case when @ic_produto_faturamento = 'N' then
           round(sum(isnull(wdma.vl_unitario_item_total,0)),2) - sum(isnull(wdma.vl_item_desconto,0))
         else
           round(sum(isnull(wdma.vl_unitario_item_total,0)),2) - sum(isnull(wdma.vl_item_desconto,0)) - sum(isnull(wdma.vl_ipi,0))
         end
         from vw_faturamento_devolucao_mes_anterior_bi wdma
         left outer join vendedor vd on vd.cd_vendedor = wdma.cd_vendedor
        where wdma.cd_vendedor = CASE WHEN ISNULL(@cd_parametro,0) = 0 THEN v.cd_vendedor ELSE ISNULL(@cd_parametro,0) END 
                AND wdma.dt_restricao_item_nota BETWEEN @dt_inicial AND @dt_final
                and isnull(vd.ic_ativo,'N')='S' 
                and wdma.cd_status_nota <> 7  
                and wdma.cd_tipo_destinatario = 1),0) as vl_devolucao

    INTO  
      #Meta  

    FROM  
      Vendedor v  WITH(NOLOCK)
      LEFT OUTER JOIN Vendedor_Meta_Familia_Produto m WITH(NOLOCK) ON m.cd_vendedor = v.cd_vendedor AND  
       m.dt_inicio_meta_vendedor = @dt_inicial AND  
       m.dt_final_meta_vendedor  = @dt_final  

    WHERE  
       ISNULL(v.ic_ativo,'N') = 'S' AND  
       v.cd_tipo_vendedor = 2     AND  
       v.cd_vendedor = CASE WHEN ISNULL(@cd_parametro,0) = 0 THEN v.cd_vendedor ELSE ISNULL(@cd_parametro,0) END   
       and
       isnull(v.ic_egismob_vendedor,'S') = 'S'

    GROUP BY      
      v.cd_vendedor,  
      m.dt_inicio_meta_vendedor,  
      m.dt_final_meta_vendedor  

	  	       --Cálculo Total--
			 --  select * from #Meta
    select 
	  @qt_base_positivada = SUM( isnull(qt_cliente_positivado,0))
    from
	  #Positivacao

	select
	  @vl_total           = SUM(ISNULL(m.vendido,0) - isnull(m.vl_devolucao,0)),
	  @vl_meta            = SUM(ISNULL(m.vl_meta_vendedor,0))
	  --@qt_base_positivada = SUM( isnull(qt_cliente,0))
    from
	  #Meta m

	set @pc_atingido      = case when isnull(@vl_meta,0)> 0         then ROUND(@vl_total/@vl_meta*100,2) else 0.00 end
	set @pc_base_atingida = case when isnull(@qt_base_cliente,0)> 0 then ROUND(@qt_base_positivada/@qt_base_cliente*100,2) else 0.00 end

	--SELECT @pc_base_atingida, @qt_base_cliente, @qt_base_positivada

    SELECT 
      identity(int,1,1) as cd_controle, 
      m.cd_vendedor,
      m.nm_vendedor AS nm_vendedor,  
      m.dt_inicio_meta_vendedor,
      m.dt_final_meta_vendedor,
	   
	  case when isnull(vl_meta_vendedor,0) < isnull(vendido,0) then
	   'Meta Alcançada' 
			else ''
			end as meta_batida,
	 
	  case when ISNULL(m.vl_meta_vendedor,0)>0 then
	    case when isnull(vl_meta_vendedor,0) - isnull(vendido,0) < 0 then 
		    0 
			else isnull(m.vl_meta_vendedor,0) - (isnull(vendido,0) - isnull(vl_devolucao,0))
			end 
	   else
	     CAST('' as varchar(10))
	   end                                                                                 AS falta_meta ,
      
	  case when ISNULL(m.vl_devolucao,0)>0 then 
	  ''+dbo.fn_formata_valor(isnull(m.vl_devolucao,0)) 
	  else
	   CAST('' as varchar(10))
	  end                                                               as devolucao,
	  case when ISNULL(m.qt_meta_vendedor,0)>0 then
      'Meta Volume Produto: ' + CONVERT(VARCHAR,m.qt_meta_vendedor)	
	  else
	    CAST('' as varchar(10))
	  end                                                               AS 'resultado3',
	  case when ISNULL(m.qt_meta_cadastro,0)>0 then
      'Meta Cadastro Clientes: ' + CONVERT(VARCHAR,m.qt_meta_cadastro)
	    else
	  cast('' as varchar(10))                                          
	  end                                                               AS 'resultado4',
       CONVERT(VARCHAR,ISNULL(m.qt_cliente,0)) 	                        as base_clientes,
	   +
	  '' +CAST(p.qt_cliente_positivado as varchar(20))  
	  --+
	  --' - '+dbo.fn_formata_valor(round( cast(p.qt_cliente_positivado as decimal(25,2))*100/ case when qt_cliente>0 then cast(qt_cliente as decimal(25,2)) else 1 end,1)) 
	  --+
	  --' (%) '
	  
	                                                                    AS positivacao,

      'Produtos: ' + CONVERT(VARCHAR,ISNULL(qt_produto,0))				AS 'resultado6',
	  case when ven.dt_pedido_venda is not null then
	     dbo.fn_data_string(dt_pedido_venda) 
      else
	    cast('' as varchar(1))
      end                                                               as 'resultado7',

      'R$ '+dbo.fn_formata_valor(ISNULL(vl_meta_vendedor,0))			AS nm_valor_meta,  
      m.cd_vendedor														AS 'badgeCaption',  
      m.nm_vendedor														AS 'caption',  
     ''																	AS 'subcaption1',  
     ISNULL(vl_meta_vendedor,0)		                                     AS vl_meta,  
     ISNULL(m.vendido,0) - isnull(vl_devolucao,0)           AS vendido,
     'Realizado R$ ' + dbo.fn_formata_valor(ISNULL(m.vendido,0) - isnull(vl_devolucao,0)) AS 'percentual',

     
	  cast(dbo.fn_formata_valor(round( cast(p.qt_cliente_positivado as decimal(25,2))*100/ case when qt_cliente>0 then cast(qt_cliente as decimal(25,2)) else 1 end,1)) as varchar(10)) as positivacao_porcen, 
	  
	  cast(dbo.fn_formata_valor(round( (ISNULL(m.vendido,0) - isnull(m.vl_devolucao,0))*100/ case when m.vl_meta_vendedor>0 then cast(m.vl_meta_vendedor as decimal(25,2)) else 1 end,1)) as varchar(10))
	                                                      as meta_porcen,

	  'currency-usd'					                       as 'iconHeader',
      'Faturamento R$ ' + dbo.fn_formata_valor(@vl_total)      as 'titleHeader',  
	  'M e t a     R$ ' + + dbo.fn_formata_valor(@vl_meta) +
	  ' / (%) '+ dbo.fn_formata_valor(@pc_atingido)    
	  --+
	  --' - '
	  --+
	  --@nm_periodo
	  as 'subtitleHeader',  

	  
	
	
	'Clientes '+CAST(cast(@qt_base_cliente as int ) as varchar(20))+' - '+'Positivação : '+cast(cast(@qt_base_positivada as int) as varchar(20))
	+
	' / (%) '+dbo.fn_formata_valor(@pc_base_atingida)
	                                                                     as 'subtitle2Header',
	 @nm_periodo 	                                                     as dt_periodo
	 
	  --subtitleHeader
      --'Meta Volume Produto: ' + SUM(ISNULL(qt_meta_vendedor,0))		AS 'resultado1',
      --CAST('.' AS VARCHAR(10))											AS 'quantidade'  
    INTO
      #MetaApresentacao
    FROM  
      #Meta m WITH(NOLOCK)
	  left outer join #Positivacao p on p.cd_vendedor   = m.cd_vendedor
      inner join vendedor v          on v.cd_vendedor   = m.cd_vendedor
      left outer join #venda ven     on ven.cd_vendedor = m.cd_vendedor
 
    where
      v.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then v.cd_vendedor else @cd_vendedor end 
	  and
	  isnull(v.ic_egismob_vendedor,'S') = 'S'

    ORDER BY  
      m.vendido DESC, vl_meta_vendedor DESC
	 --- select * from #MetaApresentacao
--------------------------------------------------------------------------------------------------------------
declare @vl_meta_total         float = 0
declare @vl_falta_meta_total   float = 0
declare @vl_base_cliente       float = 0
declare @vl_total_bonificacao  float = 0
declare @vl_trocas             float = 0
declare @vl_total_devolucao    float = 0
declare @qt_vendedores         int = 0 
declare @vendido			   float =0
select 
    @vl_meta_total         = sum(vl_meta),
    @vl_falta_meta_total   = sum(TRY_CAST(falta_meta AS DECIMAL(18,2))),
    @vl_base_cliente       = sum(TRY_CAST(base_clientes AS DECIMAL(18,2))),
    @vl_total_devolucao    = SUM(TRY_CAST(REPLACE(devolucao, ',', '.') AS DECIMAL(25,2))),
	@qt_vendedores         = count(cd_vendedor),
	@vendido               = SUM(CAST(vendido AS decimal(18,2)))
from #MetaApresentacao

--------------------------------------------------------------------------------------------------------------
declare @vl_total_os     float = 0
declare @vl_defeito      float = 0
declare @qt_defeito_dif  int = 0
declare @qt_status_dif   int = 0
declare @vl_status       int = 0
declare @qt_cliente      int = 0 
declare @qt_marca        int = 0 
declare @qt_ordem_os     int = 0 

--------------------------------------------------------------------------------------------------------------
set @html_geral = ' 
	                <div class="section-title">  
                        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
                        <p style="display: inline; text-align: center; padding: 21%;">Metas e Objetivos</p>  
                    </div>  
				   <table>
					   <tr>  
					    	<td class="tamanho" style="font-size: 15px;"><strong>Período</strong></td> 
							<td class="tamanho" style="font-size: 15px;"><strong>Vendedor</strong></td>
							<td class="tamanho" style="font-size: 15px;"><strong>Meta<strong></td>
							<td class="tamanho" style="font-size: 15px;"><strong>Falta p/ Meta</strong></td>
							<td class="tamanho" style="font-size: 15px;"><strong>(%) Meta</strong></td>
							<td class="tamanho" style="font-size: 15px;"><strong>Vendido</strong></td>
							<td class="tamanho" style="font-size: 15px;"><strong>Base Clientes</strong></td>
							<td class="tamanho" style="font-size: 15px;"><strong>Positivação</strong></td>
							<td class="tamanho" style="font-size: 15px;"><strong>(%) Positivação</strong></td>
							<td class="tamanho" style="font-size: 15px;"><strong>Bonificação</strong></td>
							<td class="tamanho" style="font-size: 15px;"><strong>Trocas</strong></td>
							<td class="tamanho" style="font-size: 15px;"><strong>Devolução</strong></td>
					   </tr>'
					   	

--------------------------------------------------------------------------------------------------------------
declare @id int = 0
while exists ( select top 1 cd_controle from #MetaApresentacao)
begin
	select top 1
		@id                         = cd_controle,

		@html_geral = @html_geral +'<tr>
						<td class="tamanho">'+isnull(dt_periodo,'')+'</td>
						<td class="tamanho">'+isnull(nm_vendedor,0)+'</td>
						<td class="tamanho">'+cast(isnull(dbo.fn_formata_valor(vl_meta),0)as nvarchar(20))+'</td>
						<td class="tamanho">
							'+case when isnull(meta_batida,'') = '' then
								cast(isnull(dbo.fn_formata_valor(falta_meta),0)as nvarchar(30))
								else cast(isnull(meta_batida,'')as nvarchar(30))
								end+'
						</td>
						<td class="tamanho">'+cast(isnull(meta_porcen,0)as nvarchar(30))+'</td>
						<td class="tamanho">'+cast(isnull(dbo.fn_formata_valor(vendido),0)as nvarchar(30))+'</td>
						<td class="tamanho">'+cast(isnull(base_clientes,0) as nvarchar(30))+'</td>
						<td class="tamanho">'+cast(isnull(positivacao,0)as nvarchar(20))+'</td>
						<td class="tamanho">'+cast(isnull(positivacao_porcen,0) as nvarchar(20))+'</td>
						<td class="tamanho">0</td>
						<td class="tamanho">0</td>
						<td class="tamanho">'+cast(isnull(devolucao,0) as nvarchar(10))+'</td>
					  </tr>'
     from #MetaApresentacao
	 delete from #MetaApresentacao where cd_controle = @id
 end
--------------------------------------------------------------------------------------------------------------------
declare @html_totais nvarchar(max)=''

set @html_rodape =
   ' <tr style="font-weight: bold;font-size: 20px;">
	 <td class="tamanho">Total</td>
	 <td class="tamanho"></td>
	 <td class="tamanho">'+cast(isnull(dbo.fn_formata_valor(@vl_meta_total),0)as nvarchar(50))+'</td>
	 <td class="tamanho">'+cast(isnull(dbo.fn_formata_valor(@vl_falta_meta_total),0)as nvarchar(20))+'</td>
	 <td class="tamanho"></td>
	 <td class="tamanho">'+cast(isnull(dbo.fn_formata_valor(@vendido),0)as nvarchar(20))+'</td>
	 <td class="tamanho">'+cast(isnull(@vl_base_cliente,0)as nvarchar(20))+'</td>
	 <td class="tamanho"></td>
	 <td class="tamanho"></td>
	 <td class="tamanho">0</td>
	 <td class="tamanho">0</td>
	 <td class="tamanho">'+cast(isnull(dbo.fn_formata_valor(@vl_total_devolucao),0)as nvarchar(20))+'</td>
	 </tr>
	</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <div class="section-title">
		<p>Total de Vendedores: '+cast(isnull(@qt_vendedores,0)as nvarchar(30))+'</p>
	</div>
    <p>'+@ds_relatorio+'</p>
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>
    </div>'



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


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_relatorio_meta_objetivo 246,'' 
------------------------------------------------------------------------------

