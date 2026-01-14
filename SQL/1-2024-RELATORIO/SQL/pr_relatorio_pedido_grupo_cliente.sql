IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_pedido_grupo_cliente' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_pedido_grupo_cliente

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_pedido_grupo_cliente
-------------------------------------------------------------------------------
--pr_relatorio_pedido_grupo_cliente
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
--Alteracao        : 
--
--
------------------------------------------------------------------------------
create procedure pr_relatorio_pedido_grupo_cliente
@cd_relatorio int   = 0,
@cd_documento int   = 0,
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
--declare @cd_documento           int = 0
--declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @ic_valor_comercial     varchar(10)
declare @cd_tipo_destinatario   int 
declare @cd_cliente_grupo       int = 0
declare @cd_grupo_relatorio     int  
declare @cd_vendedor            int  
declare @cd_tipo_relatorio      int = 0
DECLARE @id                     int = 0 
declare @cd_tipo_pedido		    int
declare @ic_faturado            char(1)
declare @cd_categoria_produto   int = 0
declare @cd_categoria_cliente   int = 0 
  
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
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor' 
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_cliente_grupo       = valor from #json where campo = 'cd_grupo_cliente'  
  select @cd_tipo_relatorio      = valor from #json where campo = 'cd_tipo_relatorio_parametro'
  select @cd_tipo_pedido		 = valor from #json where campo = 'cd_tipo_pedido'
  select @ic_faturado         	 = valor from #json where campo = 'ic_faturado'
  select @cd_categoria_produto	 = valor from #json where campo = 'cd_categoria_produto'
  select @cd_categoria_cliente   = valor from #json where campo = 'cd_categoria_cliente'  
  
   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'

   end
end


-------------------------------------------------------------------------------------------------
declare @ic_processo char(1) = 'N'  
   
  
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

  @dt_inicial            = dt_inicial,  
  @dt_final              = dt_final,  
  @cd_vendedor           = isnull(cd_vendedor,0),
  @cd_cliente_grupo      = isnull(cd_grupo_cliente,0),
  @cd_tipo_relatorio     = isnull(cd_tipo_relatorio_parametro,1),
  @cd_tipo_pedido	     = isnull(cd_tipo_pedido,0),
  @cd_categoria_produto  = isnull(cd_categoria_produto,0),
  @cd_categoria_cliente = isnull(cd_categoria_cliente,0)

from   
  Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
  and  
  cd_usuario   = @cd_usuario  
---------------------------------------------------------------------------------------------------------------------------
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

-- Obt�m a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
------------------------------

--select @dt_final
---------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio


--select @titulo
--
--select @nm_cor_empresa
-----------------------
--Cabe�alho da Empresa----------------------------------------------------------------------------------------------------------------------
-----------------------

SET @html_empresa = '
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.2/html2pdf.bundle.min.js" integrity="sha512-MpDFIChbcXl2QgipQrt1VcPHMldRILetapBl5MPCA9Y8r7qvlwx1/Mc9hNTzY+kS5kX6PdoDq41ws1HiVNLdZA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
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
            font-size: 12px;
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
		tr {
			page-break-inside: avoid;  
			page-break-after: auto;
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
            font-size: 75%;
            text-align: center;
        }
		#salva {
			  background-color: #1976D2;
			  color: white;
			  border: none;
			  padding: 10px 20px;
			  font-size: 16px;
			  cursor: pointer;
			  border-radius: 5px;
			  transition: background-color 0.3s;
			}

	   #salva:hover {
			  background-color: #1565C0;
			}
	   .nao-imprimir {
            display: none;
        }
	</style>
</head>
<body>
   <div id="conteudo">
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

set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
--set @dt_inicial = '2025-03-01'
--set @dt_final = '2025-03-28'
--set @cd_cliente_grupo = 31
--set @cd_tipo_relatorio = 2

select
  i.cd_pedido_venda,
  i.cd_item_pedido_venda,
  ns.cd_nota_saida,
  case when exists(select top 1 n.cd_nota_saida from nota_saida_item n 
                   where n.cd_pedido_venda = i.cd_pedido_venda 
                     and n.cd_item_pedido_venda = i.cd_item_pedido_venda 
                     and n.dt_cancel_item_nota_saida is null)  
    then '1'
    else '2'
  end                               as ic_faturado
into
  #Item_Pedido_Faturado
from
  Pedido_Venda_Item i       with(nolock)
  left outer join Pedido_Venda p with(nolock) on i.cd_pedido_venda = p.cd_pedido_venda
  left outer join nota_saida ns with(nolock) on i.cd_pedido_venda = ns.cd_pedido_venda
where  
  p.dt_pedido_venda between @dt_inicial and @dt_final  
  and  
  p.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then p.cd_vendedor else isnull(@cd_vendedor,0) end  
  and
  i.cd_categoria_produto = case when isnull(@cd_categoria_produto,0) = 0 then i.cd_categoria_produto else isnull(@cd_categoria_produto,0) end
  and  
  i.dt_cancelamento_item is null  
--------------------------------------------------------------------------------------------------------------------------
select
-- identity(int,1,1) as cd_controle,
  2                                                                       as cd_tipo_relatorio,
  c.cd_cliente_grupo                                                          as cd_cliente_grupo,
  cg.nm_cliente_grupo                                                    as nm_cliente_grupo,  
  right(left(convert(varchar,p.dt_usuario,121),16),5)                     as hr_inicial_pedido,
  i.cd_pedido_venda                                                     as cd_pedido_venda,
  dbo.fn_data_string(pv.dt_pedido_venda)                                 as dt_pedido_venda,
  tp.nm_tipo_pedido                                                           as nm_tipo_pedido,
  c.cd_cliente                                                                as cd_cliente,
  c.nm_fantasia_cliente                                                       as nm_fantasia_cliente,
  v.cd_vendedor                                                               as cd_vendedor,
  v.nm_fantasia_vendedor                                                      as nm_fantasia_vendedor,
  isnull(p.vl_total,0)                                                   as vl_total,  
  p.cd_usuario                                                           as cd_usuario_ordsep,
  p.dt_usuario                                                           as dt_ordsep_pedido_venda,
  isnull(ef.nm_fantasia_empresa,'')                                      as nm_fantasia_empresa,
  est.sg_estado                                                          as sg_estado,
  cid.nm_cidade                                                          as nm_cidade,
  p.cd_identificacao_nota_saida                                               as cd_identificacao_nota_saida,
  dbo.fn_data_string(p.dt_nota_saida)                                          as dt_nota_saida,
  case when n.ic_faturado = '1' then 'Sim' else 'Não' end                     as ic_faturado

  into
    #DiarioFaturamento

from
  nota_saida p
  
  inner join cliente c                                            on c.cd_cliente                 = p.cd_cliente
  --LEFT outer join Cliente_Grupo cg          on cg.cd_cliente_grupo          = c.cd_cliente_grupo
  inner join Estado est                                           on est.cd_estado                = c.cd_estado
  inner join cidade cid                                           on cid.cd_estado = c.cd_estado and cid.cd_cidade                = c.cd_cidade  
  inner join vendedor v                                           on v.cd_vendedor                = p.cd_vendedor
  inner join nota_saida_item i                                    on i.cd_nota_saida            = p.cd_nota_saida
  left outer join nota_saida_empresa pve                          on pve.cd_nota_saida          = p.cd_nota_saida
  left outer join pedido_venda pv                                 on pv.cd_pedido_venda         = i.cd_pedido_venda
  left outer join tipo_pedido tp                                  on tp.cd_tipo_pedido          = pv.cd_tipo_pedido
  left outer join categoria_cliente cc                              on cc.cd_categoria_cliente         = c.cd_categoria_cliente
  left outer join empresa_faturamento ef                            on ef.cd_empresa                   = pve.cd_empresa
  left outer join Cliente_Grupo cg                                  on cg.cd_cliente_grupo             = c.cd_cliente_grupo
  inner join Operacao_Fiscal opf                     on opf.cd_operacao_fiscal     = isnull(i.cd_operacao_fiscal,p.cd_operacao_fiscal)
  inner join Grupo_Operacao_Fiscal g                 on g.cd_grupo_operacao_fiscal = opf.cd_grupo_operacao_fiscal
  left outer join #Item_Pedido_Faturado n   with(nolock) on n.cd_nota_saida               = p.cd_nota_saida   
                                                        and n.cd_item_pedido_venda          = i.cd_item_nota_saida



where   
   isnull(p.cd_status_nota,0)<>7
   and
   isnull(opf.ic_comercial_operacao,'N')  = 'S'
   and
   IsNull(opf.ic_analise_op_fiscal,'S') = 'S' 
   and
   isnull(g.cd_tipo_operacao_fiscal,0) = 2
   and
   ISNULL(v.ic_egismob_vendedor,'S') = 'S'
   and 
   --p.dt_nota_saida between @dt_inicial and @dt_final
   --and
   p.dt_nota_saida between @dt_inicial and @dt_final
   and
   c.cd_cliente_grupo = case when isnull(@cd_cliente_grupo,0) = 0 then c.cd_cliente_grupo else isnull(@cd_cliente_grupo,0) end
   and
   p.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then p.cd_vendedor else isnull(@cd_vendedor,0) end
   and
   tp.cd_tipo_pedido = case when isnull(@cd_tipo_pedido,0) = 0 then tp.cd_tipo_pedido else isnull(@cd_tipo_pedido,0) end
   and
   n.ic_faturado = case when ltrim(rtrim(isnull(@ic_faturado,''))) = '' then n.ic_faturado else ltrim(rtrim(@ic_faturado)) end
   and
   c.cd_categoria_cliente = case when isnull(@cd_categoria_cliente,0) = 0 then c.cd_categoria_cliente else isnull(@cd_categoria_cliente,0) end
   and 
   i.cd_categoria_produto = case when isnull(@cd_categoria_produto,0) = 0 then i.cd_categoria_produto else isnull(@cd_categoria_produto,0) end
   and
   ISNULL(tp.ic_gera_bi,'S') = 'S'
   and
   ISNULL(tp.ic_bonificacao_tipo_pedido,'N') = 'N'
   and
   ISNULL(tp.ic_indenizacao_tipo_pedido,'N') = 'N'
 


--group by
--  --p.hr_inicial_pedido, 
--  p.cd_nota_saida,
--  p.dt_nota_saida,
--  tp.nm_tipo_pedido,
--  c.cd_cliente,
--  c.cd_cliente_grupo,
--  c.nm_fantasia_cliente,
--  v.cd_vendedor,
--  v.nm_fantasia_vendedor

------------------------------------------------------------------------------------------------------------------
   union all

------------------------------------------------------------------------------------------------------------------

select
  1                                                                          as cd_tipo_relatorio,
-- identity(int,1,1) as cd_controle,
  c.cd_cliente_grupo                                                          as cd_cliente_grupo,										
  cg.nm_cliente_grupo                                                         as nm_cliente_grupo,  
  right(left(convert(varchar,p.hr_inicial_pedido,121),16),5)                  as hr_inicial_pedido,
  p.cd_pedido_venda                                                           as cd_pedido_venda,
  dbo.fn_data_string(p.dt_pedido_venda)                                       as dt_pedido_venda,
  tp.nm_tipo_pedido                                                           as nm_tipo_pedido,
  c.cd_cliente                                                                as cd_cliente,
  c.nm_fantasia_cliente                                                       as nm_fantasia_cliente,
  v.cd_vendedor                                                               as cd_vendedor,
  v.nm_fantasia_vendedor                                                      as nm_fantasia_vendedor,
   isnull(p.vl_total_pedido_ipi,0)                                            as vl_total,  
   i.cd_usuario_ordsep                                                        as cd_usuario_ordsep,
   i.dt_ordsep_pedido_venda                                                   as dt_ordsep_pedido_venda,
   isnull(ef.nm_fantasia_empresa,'')                                          as nm_fantasia_empresa,
   est.sg_estado                                                              as sg_estado,
   cid.nm_cidade                                                              as nm_cidade,
   vw.cd_identificacao_nota_saida                                             as cd_identificacao_nota_saida,
   dbo.fn_data_string(vw.dt_nota_saida)                                       as dt_nota_saida,
   case when n.ic_faturado = '1' then 'Sim' else 'Não' end                     as ic_faturado


from
  pedido_venda p
  
  inner join cliente c                      on c.cd_cliente                 = p.cd_cliente
  --LEFT outer join Cliente_Grupo cg          on cg.cd_cliente_grupo          = c.cd_cliente_grupo
  inner join Estado est                     on est.cd_estado                = c.cd_estado
  inner join cidade cid                     on cid.cd_cidade                = c.cd_cidade
  left outer join tipo_pedido tp            on tp.cd_tipo_pedido            = p.cd_tipo_pedido
  inner join vendedor v                     on v.cd_vendedor                = p.cd_vendedor
  inner join pedido_venda_item i                                    on i.cd_pedido_venda            = p.cd_pedido_venda
  left outer join pedido_venda_empresa pve                          on pve.cd_pedido_venda             = p.cd_pedido_venda
  left outer join empresa_faturamento ef                            on ef.cd_empresa                   = pve.cd_empresa
  left outer join Cliente_Grupo cg                                  on cg.cd_cliente_grupo             = c.cd_cliente_grupo
  left outer join vw_pedido_venda_item_nota_saida vw  with (nolock) on vw.cd_pedido_venda              = p.cd_pedido_venda 
												                       and vw.cd_item_pedido_venda     = i.cd_item_pedido_venda
    left outer join #Item_Pedido_Faturado n   with(nolock) on n.cd_pedido_venda               = p.cd_pedido_venda   
                                                        and n.cd_item_pedido_venda          = i.cd_item_pedido_venda  

  --left outer join Meta_Vendedor_Periodo mvp on mvp.cd_vendedor              = v.cd_vendedor and 
	 --                                          mvp.dt_inicial_validade_meta = @dt_base_incial and
		--									   mvp.dt_final_validade_meta   = @dt_base_final



where
  p.dt_pedido_venda between @dt_inicial and @dt_final
  and
  c.cd_cliente_grupo = case when isnull(@cd_cliente_grupo,0) = 0 then c.cd_cliente_grupo else isnull(@cd_cliente_grupo,0) end
  and
  p.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then p.cd_vendedor else isnull(@cd_vendedor,0) end
  and
  tp.cd_tipo_pedido = case when isnull(@cd_tipo_pedido,0) = 0 then tp.cd_tipo_pedido else isnull(@cd_tipo_pedido,0) end
  and 
  i.cd_categoria_produto = case when isnull(@cd_categoria_produto,0) = 0 then i.cd_categoria_produto else isnull(@cd_categoria_produto,0) end
  and
  n.ic_faturado = case when ltrim(rtrim(isnull(@ic_faturado,''))) = '' then n.ic_faturado else ltrim(rtrim(@ic_faturado)) end
  and
  ISNULL(tp.ic_gera_bi,'S') = 'S'
  and

  i.dt_cancelamento_item is null
  and
  ISNULL(tp.ic_bonificacao_tipo_pedido,'N') = 'N'
  and
  ISNULL(tp.ic_indenizacao_tipo_pedido,'N') = 'N'
  --and
  --p.cd_pedido_venda not in ( select i.cd_pedido_venda from pedido_venda_item i
  --                           where
		--					   i.cd_pedido_venda = p.cd_pedido_venda
		--					   and
		--					   i.dt_cancelamento_item is null )
 


--group by
--  p.hr_inicial_pedido, 
--  p.cd_pedido_venda,
--  p.dt_pedido_venda,
--  tp.nm_tipo_pedido,
--  c.cd_cliente,
--  c.cd_cliente_grupo,
--  c.nm_fantasia_cliente,
--  v.cd_vendedor,
--  v.nm_fantasia_vendedor


--  order by
--    p.cd_pedido_venda
--select * from #DiarioFaturamento 
--return
------------------------------------------------------------------------------------------------------------------

select 
    IDENTITY(Int,1,1)                      as cd_controle,
	cd_tipo_relatorio                      as  cd_tipo_relatorio,
	cd_cliente_grupo					   as  cd_cliente_grupo,				
	max(nm_cliente_grupo)  				   as  nm_cliente_grupo,  
	hr_inicial_pedido					   as  hr_inicial_pedido,
	cd_pedido_venda						   as  cd_pedido_venda,
	dt_pedido_venda						   as  dt_pedido_venda,
	nm_tipo_pedido						   as  nm_tipo_pedido,
	cd_cliente							   as  cd_cliente,
	nm_fantasia_cliente					   as  nm_fantasia_cliente,
	cd_vendedor							   as  cd_vendedor,
	nm_fantasia_vendedor				   as  nm_fantasia_vendedor,
	max(vl_total)  						   as  vl_total,  
	max(cd_usuario_ordsep)				   as  cd_usuario_ordsep,
	max(dt_ordsep_pedido_venda)			   as  dt_ordsep_pedido_venda,
	max(nm_fantasia_empresa)			   as  nm_fantasia_empresa,
	max(sg_estado)						   as  sg_estado,
	max(nm_cidade)						   as  nm_cidade,
	max(cd_identificacao_nota_saida)	   as  cd_identificacao_nota_saida,
	max(dt_nota_saida)					   as  dt_nota_saida,
	ic_faturado                            as  ic_faturado
into								
#Diario
from #DiarioFaturamento
 where 
 cd_tipo_relatorio  = @cd_tipo_relatorio
 

group by
  cd_tipo_relatorio,
  hr_inicial_pedido, 
  cd_pedido_venda,
  dt_pedido_venda,
  nm_tipo_pedido,
  cd_cliente,
  cd_cliente_grupo,
  nm_fantasia_cliente,
  cd_vendedor,
  nm_fantasia_vendedor,
  ic_faturado


  order by
    cd_pedido_venda

	 --select * from #Diario 
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #Diario  
  return  
 end  
 
--------------------------------------------------------------------------------------------------------------
declare @nm_fantasia_vendedor        nvarchar(60)
declare @hr_inicial_pedido           nvarchar(10)
--declare @cd_vendedor                 int = 0
declare @cd_pedido_venda             int = 0
declare @dt_pedido_venda             nvarchar(20)
declare @nm_tipo_pedido              nvarchar(40) 
declare @cd_cliente_tb               int = 0 
declare @nm_fantasia_cliente         nvarchar(60)
declare @vl_total                    nvarchar(20) 
declare @nm_fantasia_empresa_tb      nvarchar(60)
declare @sg_estado_tb                nvarchar(40)
declare @nm_cidade_tb                nvarchar(40)
declare @cd_identificacao_nota_saida int = 0 
declare @dt_nota_saida               nvarchar(20)
declare @nm_grupo_cliente            nvarchar(60)
declare @vl_total_pedido             float = 0 
declare @vl_total_nota               float = 0 

select 

	@vl_total_nota   = Sum(vl_total),
	@vl_total_pedido = COUNT(cd_pedido_venda)

from #Diario

--select @vl_total_nota,@vl_total_pedido
--------------------------------------------------------------------------------------------------------------

set @html_geral = '<div>
		<p class="section-title" style="text-align: center; padding: 8px;">'+case when isnull(@cd_tipo_relatorio,1) = 1 then 'Vendas por Grupo de Cliente '+cast(isnull(dbo.fn_data_string(@dt_inicial),'')as nvarchar(20))+' á '+cast(isnull(dbo.fn_data_string(@dt_final),'')as nvarchar(20))+'' else 'Faturamento por Grupo de Cliente '+cast(isnull(dbo.fn_data_string(@dt_inicial),'')as nvarchar(20))+' á '+cast(isnull(dbo.fn_data_string(@dt_final),'')as nvarchar(20))+'' end +'</p>
	</div>
	<div>
    <table>
      <tr>
			<th>Grupo Cliente</th>
            <th>Vendedor</th>
			<th>Entrada</th>
			<th>Pedido</th>
			<th>Emissão</th>
			<th>Tipo</th>
			<th>Código</th>
			<th>Cliente</th>
			<th>Total</th>
			<th>Empresa</th>
			<th>UF</th>
			<th>Cidade</th>
			<th>Nota</th>
			<th>Emissão</th>
			<th>Faturado</th>
        </tr>'

					   
--------------------------------------------------------------------------------------------------------------

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #Diario)
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,
		@hr_inicial_pedido           = hr_inicial_pedido,
        @nm_fantasia_cliente         = nm_fantasia_cliente,
        @nm_fantasia_vendedor        = nm_fantasia_vendedor,
		@cd_vendedor                 = cd_vendedor,
		@cd_pedido_venda             = cd_pedido_venda,
		@nm_tipo_pedido              = nm_tipo_pedido,
		@cd_cliente                  = cd_cliente,
		@vl_total                    = vl_total, 
		@nm_fantasia_empresa         = nm_fantasia_empresa,
		@cd_identificacao_nota_saida = cd_identificacao_nota_saida,
		@sg_estado                   = sg_estado,
		@nm_cidade                   = nm_cidade,
        @dt_nota_saida               = CONVERT(VARCHAR(15), dt_nota_saida, 103),
		@dt_pedido_venda             = CONVERT(VARCHAR(15), dt_pedido_venda, 103),
		@nm_grupo_cliente            = nm_cliente_grupo,
		@ic_faturado                 = ic_faturado
 
    FROM #Diario

    SET @html_geral = @html_geral +
        '<tr>
			<td>'+isnull(@nm_grupo_cliente,'')+'</td>
            <td>'+isnull(@nm_fantasia_vendedor,'')+' ('+cast(isnull(@cd_vendedor,'') as nvarchar(10))+')</td>
			<td>'+cast(isnull(@hr_inicial_pedido,0) as nvarchar(10))+'</td>
			<td>'+cast(isnull(@cd_pedido_venda,'')as nvarchar(20))+'</td>
			<td>'+isnull(@dt_pedido_venda,'')+'</td>
			<td>'+isnull(@nm_tipo_pedido,'')+'</td>
			<td>'+cast(isnull(@cd_cliente,'') as nvarchar(20))+'</td>
			<td>'+isnull(@nm_fantasia_cliente,'')+'</td>
			<td>'+cast(isnull(dbo.fn_formata_valor(@vl_total),'') as nvarchar(10))+'</td>
			<td>'+isnull(@nm_fantasia_empresa,'')+'</td>
			<td>'+isnull(@sg_estado,'') +'</td>
			<td>'+isnull(@nm_cidade,'') +'</td>
			<td>'+cast(isnull(@cd_identificacao_nota_saida,'') as nvarchar(20))+'</td>
			<td>'+isnull(@dt_nota_saida,'')+'</td>
			<td>'+isnull(@ic_faturado,'')+'</td>
        </tr>'

    DELETE FROM #Diario WHERE cd_controle = @id
END
--------------------------------------------------------------------------------------------------------------------




set @html_rodape =
    '</table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	</div>
	<div class="section-title">
		<p>Total de Pedidos: '+cast(ISNULL(@vl_total_pedido,'')as nvarchar(20))+'</p>
		<p>Valor Total: '+cast(ISNULL(dbo.fn_formata_valor(@vl_total_nota),'') as nvarchar(20))+'</p>
	</div>
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>
	  <button id="salva">Salvar</button>
    </div>
	<script>
            document.querySelector("#salva").addEventListener("click", () => {
                const botaoSalvar = document.querySelector("#salva");
                botaoSalvar.classList.add("nao-imprimir");

                const conteudoHtml = document.querySelector("#conteudo");
                const options = {
                    margin: 0,
                    filename: "'+isnull(@titulo,'')+'.pdf",
                    image: { type: "jpeg", quality: 0.98 },
                    html2canvas: {
                        scale: 1,
                        scrollX: 0,
                        scrollY: 0,
                        windowWidth: document.body.scrollWidth,
                        windowHeight: document.body.scrollHeight,
                        useCORS: true
                    },
                    jsPDF: { unit: "mm", format: "a4", orientation: "landscape" },
                };

                html2pdf()
                    .set(options)
                    .from(conteudoHtml)
                    .save()
                    .then(() => {
                        botaoSalvar.classList.remove("nao-imprimir"); 
                    });
            });
        </script>	

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


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_relatorio_pedido_grupo_cliente 234,2,''
------------------------------------------------------------------------------
