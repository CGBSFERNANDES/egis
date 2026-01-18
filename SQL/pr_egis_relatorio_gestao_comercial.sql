IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_gestao_comercial' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_gestao_comercial

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_gestao_comercial
-------------------------------------------------------------------------------
--pr_egis_relatorio_gestao_comercial
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 24.08.2024
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_gestao_comercial
@cd_relatorio int   = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')

declare @cd_empresa             int = 0
declare @cd_modulo              int = 0
declare @cd_menu                int = 0
declare @cd_processo            int = 0
declare @cd_item_processo       int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
declare @cd_item_documento      int = 0
declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int

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
			@vl_total_ipi				float         = 0,
			@sg_tabela_preco            char(10)      = '',
			@cd_empresa_faturamento     int           = 0,
			@nm_fantasia_faturamento    varchar(30)   = '',
			@cd_tipo_pedido             int           = 0,
			@nm_tipo_pedido             varchar(30)   = '',
			@cd_vendedor                int           = 0,
			@nm_fantasia_vendedor       varchar(500)   = '',
			@nm_telefone_vendedor       varchar(30)   = '',
			@nm_email_vendedor          varchar(300)  = '',
			@nm_contato_cliente			varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = '',
			@nm_status					varchar(100) = '',
			@ic_empresa_faturamento		char(1) = ''



--------------------------------------------------------------------------------------------------------

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
set @cd_parametro      = 0
set @cd_modulo         = 0
set @cd_empresa        = 0
set @cd_menu           = 0
set @cd_processo       = 0
set @cd_item_processo  = 0
set @cd_form           = 0
set @cd_parametro      = 0
set @cd_documento      = 0
set @cd_item_documento = 0
set @dt_usuario        = GETDATE()
------------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------

--select * from #json

-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_modulo              = valor from #json where campo = 'cd_modulo'             
  select @cd_processo            = valor from #json where campo = 'cd_processo'             
  select @cd_item_processo       = valor from #json where campo = 'cd_item_processo'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_item_documento      = valor from #json where campo = 'cd_item_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'
     select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'

   end

end


-------------------------------------------------------------------------------------------------
declare @ic_processo char(1) = 'N'
 

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
declare @html_grafico    nvarchar(max) = '' --Gráfico
declare @html_titulo     nvarchar(max) = '' --Título
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
------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------
--Título do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio


--select @titulo
--

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
  cd_grupo_relatorio = 2

order by qt_ordem_atributo

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

drop table #AuxRelAtributo

--select @nm_dados_cab_det

--select * from #RelAtributo

--select * from parametro_relatorio
--delete from parametro_relatorio
--update parametro_relatorio


---> CCF <----
---> alteração com o processo do relatório

declare @vl_total          decimal(25,2) = 0.00
declare @qt_total          int = 0
declare @vl_total_vendedor decimal(25,2) = 0.00
declare @qt_total_vendedor int = 0

set @cd_vendedor = 0

--Cliente Positivados----

select
  n.cd_vendedor,
  count(distinct n.cd_cliente) as qt_cliente
 
into
  #ClientePositivado

from
  nota_saida n
  inner join nota_saida_item i on i.cd_nota_saida = n.cd_nota_saida

where
  n.cd_vendedor = case when @cd_vendedor = 0 then n.cd_vendedor else @cd_vendedor end
  and
  n.dt_nota_saida between @dt_inicial and @dt_final
  and
  n.cd_status_nota<> 7
  and
  i.dt_restricao_item_nota is null or i.dt_restricao_item_nota>@dt_inicial

group by
  n.cd_vendedor


--Faturamento por Vendedor----------------------------

select
  max(cast(0 as int))                    as cd_item,
  n.cd_vendedor,
  n.dt_nota_saida,
  max(v.nm_fantasia_vendedor)                                                                                                 as nm_fantasia_vendedor,
  sum( cast(round(isnull(i.vl_total_item,0) +  isnull(i.vl_ipi,0) + isnull(i.vl_icms_subst_icms_item,0),2) as decimal(25,2))) as vl_total_item,
  count(distinct n.cd_cliente)           as qt_cliente,
  count(distinct i.cd_produto)           as qt_produto,
  count(distinct p.cd_categoria_produto) as qt_categoria_produto,
  count(distinct p.cd_familia_produto)   as qt_familia_produto,
  COUNT(distinct n.cd_nota_saida)        as qt_nota
 
into
  #FaturamentoVendedor

from
  nota_saida n
  inner join nota_saida_item i on i.cd_nota_saida = n.cd_nota_saida
  inner join produto p         on p.cd_produto    = i.cd_produto
  inner join vendedor v        on v.cd_vendedor   = n.cd_vendedor

where
  n.cd_vendedor = case when @cd_vendedor = 0 then n.cd_vendedor else @cd_vendedor end
  and
  n.dt_nota_saida between @dt_inicial and @dt_final
  and
  n.cd_status_nota<> 7
  and
  i.dt_restricao_item_nota is null or i.dt_restricao_item_nota>@dt_inicial
  and
  ISNULL(v.ic_egismob_vendedor,'N')='S'

group by
  n.cd_vendedor,
  n.dt_nota_saida

order by
  n.dt_nota_saida

--select @cd_vendedor

--select * from #FaturamentoVendedor

select
  @vl_total = sum(vl_total_item),
  @qt_total = sum(qt_nota)

from
  #FaturamentoVendedor


select 
  identity(int,1,1) as cd_controle,
  *,
  pc_faturamento = cast(round(vl_total_item/@vl_total*100,2) as decimal(25,2))
into
  #FinalFaturamentoVendedor

from 
  #FaturamentoVendedor

order by
  cd_vendedor, dt_nota_saida

--select
--  *
--from
--  #FinalFaturamentoVendedor

--order by
--  dt_nota_saida

---------------------------------------------------------------------------------------------------------------------------

----montagem do Detalhe-----------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------

--<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_data_string(dt_pedido_venda)+'</td>

declare @id int = 0

set @html_detalhe = ''

--declare @nm_fantasia_vendedor varchar(30) = ''

--Clientes por Dia de Semana---

select
  c.cd_vendedor,
  c.cd_semana,
  count(c.cd_cliente) as qt_cliente

into
  #DiaVisitaVendedor

from
  cliente c
where
  ISNULL(c.cd_status_cliente,1) = 1


group by
 c.cd_vendedor,
 c.cd_semana
 
--Vendedor--------------------------------------------------------------------

select
  f.cd_vendedor, 
  f.nm_fantasia_vendedor,
  max( 'R$ '+dbo.fn_formata_valor(ISNULL(v.vl_meta,0))) as nm_meta,
  MAX(isnull(v.vl_meta,0))                              as vl_meta,
  COUNT(distinct c.cd_cliente)                          as qt_cliente,
  MAX(p.qt_cliente)                                     as qt_cliente_positivado


  into #Vendedor 

from  
  #FinalFaturamentoVendedor f
  inner join Vendedor v                on v.cd_vendedor = f.cd_vendedor
  inner join Cliente c                 on c.cd_vendedor = f.cd_vendedor and c.cd_status_cliente = 1 --Ativo
  left outer join #ClientePositivado p on p.cd_vendedor = f.cd_vendedor
where
  ISNULL(v.ic_egismob_vendedor,'N')='S'


group by
 f.cd_vendedor,
 f.nm_fantasia_vendedor

order by
  f.cd_vendedor

--------------------------------------------------------------------------------------------------


declare @nm_meta          varchar(100)  = ''
declare @qt_cliente       decimal(25,2) = 0
declare @vl_falta_meta    decimal(25,2) = 0.00
declare @pc_atingido_meta decimal(25,2) = 0.00
declare @vl_meta          decimal(25,2) = 0.00
declare @qt_cliente_nota  decimal(25,2) = 0
declare @pc_positivacao   decimal(25,2) = 0


 --select SUM(qt_cliente) as qt_cliente from #Vendedor

  --return

while exists( select Top 1 cd_vendedor from #Vendedor )
begin

  select Top 1
    @cd_vendedor          = cd_vendedor,
	@nm_fantasia_vendedor = nm_fantasia_vendedor, --+'     -    Meta: '+nm_meta ,
	@nm_meta              = nm_meta,
	@vl_meta              = isnull(vl_meta,0),
	@qt_cliente           = isnull(qt_cliente,0),
	@qt_cliente_nota      = isnull(qt_cliente_positivado,0)

  from
    #Vendedor

  order by
    cd_vendedor

  --Total do Vendedor---------------------------

    select
      @vl_total_vendedor = sum(vl_total_item),
      @qt_total_vendedor = sum(qt_nota)
	  
	  	  
    from
	  #FinalFaturamentoVendedor
    where
	  cd_vendedor = @cd_vendedor

    --Metas------

	set @pc_atingido_meta = round(case when @vl_meta>0                  then @vl_total_vendedor/@vl_meta * 100            else 0.00 end,0)
	set @vl_falta_meta    = case when @vl_total_vendedor<@vl_meta then @vl_meta-@vl_total_vendedor else 0.00 end
	set @pc_positivacao   = cast(round(@qt_cliente_nota/@qt_cliente * 100,2) as decimal(25,2))

    --select @nm_fantasia_vendedor, @nm_meta, @pc_atingido_meta, @vl_falta_meta, @pc_positivacao, @qt_cliente, @qt_cliente_nota								

    set @html_cab_det = '<div class="section-title"><strong> '+@nm_fantasia_vendedor + ' </strong></div>    
                     <table>
					 <tr>
					 <td>Meta</td>
					 <td>(%) Meta</td>
					 <td>Falta Atingir</td>
					 <td>Base Compradora</td>
					 <td>Positivação</td>
					 <td>(%)</td>
					 </tr>
					 <tr>
					 <td>'+@nm_meta                               +'</td>
					 <td>'+dbo.fn_formata_valor(@pc_atingido_meta)+'</td>
					 <td>'+case when @vl_falta_meta>0 then dbo.fn_formata_valor(@vl_falta_meta) else cast('-' as varchar(1)) end+'</td>
					 <td>'+CAST(cast(@qt_cliente as int) as varchar(20))+'</td>
					 <td>'+cast(cast(@qt_cliente_nota as int ) as varchar(10))+'</td>
					 <td>'+dbo.fn_formata_valor(@pc_positivacao)+'</td>
					 </tr>


					 </table>
                     <table>
                     <tr>'
					 +

					 +
					 isnull(@nm_dados_cab_det,'')
                     + '</tr>'

  --------------------------------------------------------------------------------------------------------------------------

  set @html_detalhe = '' --valores da tabela

  --Insere na Tabela a Linha do 99 com o Total----------------

  --insert into #FinalFaturamentoVendedor
  --select
  --   --MAX(cd_controle)               as cd_controle,     
  --   max(999)                       as cd_item,
	 --f.cd_vendedor                  as cd_vendedor,
	 --max(f.dt_nota_saida)           as dt_nota_saida,
  --   max(CAST('' as varchar(30)))   as nm_fantasia_vendedor,
	 --@vl_total_vendedor             as vl_total_item,
	 --@qt_cliente                    as qt_cliente,
	 --SUM(f.qt_produto)              as qt_produto,
	 --SUM(f.qt_categoria_produto)    as qt_categoria_produto,
	 --SUM(f.qt_familia_produto)      as qt_familia_produto,
	 --SUM(f.qt_nota)                 as qt_nota,
	 --sum(pc_faturamento)            as pc_faturamento

  --from
  --  #FinalFaturamentoVendedor f
  --where
  --  f.cd_vendedor = @cd_vendedor
  --group by
  --  f.cd_vendedor 


     
  while exists ( select top 1 cd_controle from #FinalFaturamentoVendedor where cd_vendedor = @cd_vendedor)
  begin



    select 
      top 1
      @id           = cd_controle,
	--@nm_pedido    = @nm_pedido  + ' ' + cast(cd_pedido_venda as varchar(15)),
      @html_detalhe = @html_detalhe + '
            <tr> 					           			
			<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_data_string(dt_nota_saida)+'</td>
			<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_formata_valor(vl_total_item)+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_formata_valor(pc_faturamento)+'</td>	
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_cliente as varchar(20))+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_familia_produto as varchar(20))+'</td>			
            </tr>'
	
		--use egissql_317

     from
       #FinalFaturamentoVendedor

     where
       cd_vendedor = @cd_vendedor

     order by
        cd_vendedor, cd_item, dt_nota_saida, cd_controle
	   

  delete from #FinalFaturamentoVendedor
  where
    cd_controle = @id

 end

 --Totais do Vendedor--

 delete from #Vendedor
   where cd_vendedor = @cd_vendedor

SET @html_rod_det = '</table>'


set @titulo_total = 'SUB-TOTAL'

set @html_totais = '<div class="section-title">'+@titulo_total+'
					<table style="border: none;">
                    <tr>										
			        <p style="border: none;color: white;font-size:18px; text-align:left;"><b>Quantidade Notas: '+cast(@qt_total_vendedor as varchar(10))+'</p>
			        <p style="border: none;color: white;font-size:18px; text-align:left;"><b>Valor Total: '+'R$ '+dbo.fn_formata_valor(@vl_total_vendedor)+'</p>	
					</tr>
					</table>					
					</div>'
					
 set @html_geral = @html_geral + 
                   @html_cab_det +
                   @html_detalhe +
	               @html_rod_det +
				   @html_totais

     
end




-----Parâmetros do relatório----------------------------------------------------------------------------------------------------------------------------

select
  identity(int,1,1)                                                                                                                         as cd_controle,
  v.cd_vendedor,
  v.nm_fantasia_vendedor,
  isnull(v.vl_meta,0)                                                                                                                       as vl_meta,
  ( select count(c.cd_cliente)  from cliente c  where c.cd_vendedor  = v.cd_vendedor and cd_status_cliente = 1 )                            as qt_cliente,
  ( select count(vi.cd_visita)  from visita vi  where vi.cd_vendedor = v.cd_vendedor and vi.dt_visita between @dt_inicial and @dt_final )   as qt_visita,

  isnull((select qt_cliente from #DiaVisitaVendedor d where d.cd_vendedor = v.cd_vendedor and d.cd_semana = 2 ),0) as qt_seg,
  isnull((select qt_cliente from #DiaVisitaVendedor d where d.cd_vendedor = v.cd_vendedor and d.cd_semana = 3 ),0) as qt_ter,
  isnull((select qt_cliente from #DiaVisitaVendedor d where d.cd_vendedor = v.cd_vendedor and d.cd_semana = 4 ),0) as qt_qua,
  isnull((select qt_cliente from #DiaVisitaVendedor d where d.cd_vendedor = v.cd_vendedor and d.cd_semana = 5 ),0) as qt_qui,
  isnull((select qt_cliente from #DiaVisitaVendedor d where d.cd_vendedor = v.cd_vendedor and d.cd_semana = 6 ),0) as qt_sex,
  isnull((select qt_cliente from #DiaVisitaVendedor d where d.cd_vendedor = v.cd_vendedor and d.cd_semana = 7 ),0) as qt_sab,
  isnull((select qt_cliente from #DiaVisitaVendedor d where d.cd_vendedor = v.cd_vendedor and d.cd_semana = 1 ),0) as qt_dom

into #ExtratoVendedor
from
  vendedor v

where
  v.cd_vendedor = case when @cd_vendedor = 0 then v.cd_vendedor else @cd_vendedor end
  and
  isnull(v.ic_egismob_vendedor,'S')='S'
  and
  isnull(v.vl_meta,0)>0

order by
   v.nm_fantasia_vendedor

--select * from #ExtratoVendedor

---------------------------------------------------------------------------------------------------------------------------

----montagem do Detalhe-----------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------

--<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_data_string(dt_pedido_venda)+'</td>

set @id = 0

--set @html_detalhe = ''

while 1= 2 and exists ( select top 1 cd_controle from #ExtratoVendedor )
begin

  select 
    @id           = cd_controle,
	--@nm_pedido    = @nm_pedido  + ' ' + cast(cd_pedido_venda as varchar(15)),
    @html_detalhe = @html_detalhe + '
            <tr> 					           
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(nm_fantasia_vendedor as varchar(30))+'</td>
			<td style="font-size:12px; text-align:center;width: 20px">'+dbo.fn_formata_valor(vl_meta)+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_cliente as varchar(20))+'</td>	
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_seg as varchar(20))+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_ter as varchar(20))+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_qua as varchar(20))+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_qui as varchar(20))+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_sex as varchar(20))+'</td>			
			<td style="font-size:12px; text-align:center;width: 20px">'+cast(qt_sab as varchar(20))+'</td>			
            </tr>'
	
		--use egissql_317

  from
    #ExtratoVendedor

  order by
    cd_controle
	   

  delete from #ExtratoVendedor
  where
    cd_controle = @id


end


--select @html_detalhe

--Exec em SQl com Texto
--While---
--Campos do Html

set @nm_fantasia_cliente     = '' --'Resumo dos Pedidos de Vendas'
set @nm_razao_social_cliente = '' --@nm_pedido


set @html_titulo = '<div class="section-title"><strong>'+@titulo+'</strong></div>
                    <div style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">
					 <p><strong>'+isnull(@nm_fantasia_cliente,'')+'</strong></p>
					</div>
 	               <div style="display: flex; justify-content: space-between; align-items:center; margin-bottom: 0px; padding-bottom: 0px">
	            	<p><strong>'+isnull(@nm_razao_social_cliente,'')+'</strong></p>	            	
	</div>'
	   	 
--------------------------------------------------------------------------------------------------------------------

--Criar uma tabela temporario com os Dados dos atributos


--SET @html_rod_det = '</table>'


set @titulo_total = 'TOTAL'

set @html_totais = '<div class="section-title"><strong>'+@titulo_total+'</strong>
                    <div> 
					<table style="border: none;">
                    <tr>									
			        <p style="border: none;color: white;font-size:18px; text-align:left;"><b>Quantidade Total: '+cast(@qt_total as varchar(10))+'</p>
			        <p style="border: none;color: white;font-size:18px; text-align:left;"><b>Valor Total: '+'R$ '+dbo.fn_formata_valor(@vl_total)+'</p>	
					</tr>
					</table>
					</div>
					</div>'

					--&nbsp

--<td style="font-size:12px; text-align:center;width: 80px;">'+'R$ '+dbo.fn_formata_valor(@vl_total)+'</td>

set @footerTitle = ''

--Rodapé--

set @html_rodape =
    '<div class="company-info">
		<p><strong>'+@footerTitle+'</strong> ''</p>
	</div>
    <div class="section-title"><strong>Observações</strong></div>
    <p>'+@ds_relatorio+'</p>
	<div class="report-date-time">
       <p>Gerado em: '+@data_hora_atual+'</p>
    </div>'


--Gráfico--
set @html_grafico = '<head>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load("current", {"packages":["corechart"]});
      google.charts.setOnLoadCallback(drawChart);

      function drawChart() {

        var data = google.visualization.arrayToDataTable([
          
		  ["000 empresa", "task"],
		  ["001 SORVETES PIMPINELLA", 2.9],
		  ["002 SORVETES PIMPINELLA", 3100.90],
		  ["003 SORVETES PIMPINELLA", 1001.90],
		  ["004 SORVETES PIMPINELLA", 1002.90]

        ]);

        var options = {
          title: "Evolucao de vendas"
        };

        var chart = new google.visualization.PieChart(document.getElementById("piechart"));

        chart.draw(data, options);
      }
    </script>
  </head>
  <body>
    <div id="piechart" style="width: 900px; height: 500px;"></div>
  </body>'

--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +

	--@html_cab_det +
 --   @html_detalhe +
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

----------------------------------------------------------------------------------------------------------------------------------------------
go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_gestao_comercial 21,''
------------------------------------------------------------------------------


