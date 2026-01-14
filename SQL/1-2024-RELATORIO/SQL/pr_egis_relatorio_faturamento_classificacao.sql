IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_faturamento_classificacao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_faturamento_classificacao

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_faturamento_classificacao
-------------------------------------------------------------------------------
--pr_egis_relatorio_faturamento_classificacao
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
create procedure pr_egis_relatorio_faturamento_classificacao
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
  select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'


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
  @cd_vendedor       = isnull(cd_vendedor,0)
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


set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)


----------------------------------------------------------------------------------------------------------------------


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

set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
declare @vl_total     float = 0
declare @ic_produto_faturamento char(1)
declare @ic_codigo_cliente	    char(1) = 'N'
-------------------------------------------------------------------------------------------------------------------------
select
  top 1
  @ic_produto_faturamento = isnull(ce.ic_produto_faturamento,'N'),
  @ic_codigo_cliente      = isnull(ce.ic_codigo_cliente,'N')

from
  config_egismob ce with (nolock)
where
  ce.cd_empresa = @cd_empresa

--------------------------------------------------------------------------------------------------------------------------
   select
    cc.cd_classificacao_cliente,
	max(cc.nm_classificacao_cliente)               as nm_classificacao_cliente,
	count(c.cd_cliente)                            as qt_cliente_cadastro
  into
    #ClienteClassificacao
  from
    cliente c
	inner join classificacao_cliente cc on cc.cd_classificacao_cliente = c.cd_classificacao_cliente
  where
    isnull(c.cd_status_cliente,0) = 1
  group by
    cc.cd_classificacao_cliente

  select
    identity(int,1,1)                       as cd_controle,
    cg.cd_classificacao_cliente,
	cg.nm_classificacao_cliente,
	count(distinct vw.cd_nota_saida)        as qt_nota_saida,
	count(distinct vw.cd_cliente)           as qt_cliente,
	max(cg.qt_cliente_cadastro)             as qt_cliente_cadastro,
	count(distinct vw.cd_vendedor)          as qt_vendedor,
	count(distinct vw.cd_produto)           as qt_produto,
    case when @ic_produto_faturamento = 'N' 
	               then round(sum(isnull(vw.vl_unitario_item_total,0)),2) - sum(isnull(vw.vl_item_desconto,0))
                   else round(sum(isnull(vw.vl_unitario_item_total,0)),2) - sum(isnull(vw.vl_item_desconto,0)) - sum(isnull(vw.vl_ipi,0))
              end  
--    sum(isnull(vw.vl_unitario_item_total,0)  -  vw.vl_item_desconto - case when vw.zfm = 'N' 
--	                                                                       then 0.00 
--																		   else vw.Desconto_ZFM 
--																      end ) 
                                            as vl_total_faturamento
  
  into #FatClassificacao

  from
    vw_faturamento_bi vw                     with(nolock)
	inner join cliente c                     with(nolock) on c.cd_cliente                 = vw.cd_cliente
	left outer join #ClienteClassificacao cg with(nolock) on cg.cd_classificacao_cliente  = c.cd_classificacao_cliente
	left outer join nota_saida ns            with(nolock) on ns.cd_nota_saida             = vw.cd_nota_saida
	left outer join vendedor v               with(nolock) on v.cd_vendedor                = vw.cd_vendedor
  where
    vw.cd_vendedor = case when isnull(@cd_vendedor,0) = 0 then vw.cd_vendedor else @cd_vendedor end  
	and
	vw.dt_nota_saida between @dt_inicial and @dt_final
	and
    isnull(v.ic_ativo,'N')='S' 
	and
	vw.cd_status_nota<>7
	and
	vw.cd_tipo_destinatario = 1 

  group by
    cg.cd_classificacao_cliente,
	cg.nm_classificacao_cliente
---------------------------------------------------------------------------------------------------------------
 
 select
	@vl_total = sum( isnull(vl_total_faturamento,0))
 from
    #FatClassificacao
    
--------------------------------------------------------------------------------------------------------------------------
--- select cliente
      select 
	    identity(int,1,1)                                               as cd_controle,      
	    'S'                                                             as 'MultipleDate',
        'S'                                                             as 'ic_sub_menu',
        g.cd_classificacao_cliente                                      as cd_parametro_menu_detalhe,  
	    'currency-usd'                                                  as 'iconHeader',
	     g.nm_classificacao_cliente                                     as caption,
		 cast(g.qt_cliente_cadastro as varchar(10))                     as badgeCaption,
         cast(g.qt_cliente as varchar(10))                              as 'badgeResultadoRight',
	    -- 'Notas   : ' + cast(qt_nota_saida as varchar)                  as 'quantidade',
	      cast(qt_produto as varchar(10))                               as quantidade,
          dbo.fn_formata_valor(vl_total_faturamento)                    as resultado,

	     cast(g.qt_vendedor as varchar(10))                             as resultado2, 
   	    'Faturamento R$' + dbo.fn_formata_valor(@vl_total)              as 'titleHeader',
	     dbo.fn_formata_valor(round(vl_total_faturamento/@vl_total*100, 2))  as vl_percentual,
         '% Positivação '+dbo.fn_formata_valor(
		 cast(round(cast(g.qt_cliente as decimal(25,2)) / cast(g.qt_cliente_cadastro as decimal(25,2))*100,2) as int))
		                                                                as 'subcaption1',
         g.qt_cliente_cadastro,
		 g.qt_cliente,
		 cast(round(cast(g.qt_cliente as decimal(25,2)) / cast(g.qt_cliente_cadastro as decimal(25,2))*100,2) as int) as pc_part
		 into
		 #faturamentoClassificaoRel
      from #FatClassificacao g
      order by        
        g.vl_total_faturamento desc
------------------------------------------------------------------------------------------------------------
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #faturamentoClassificaoRel  
  return  
 end  
--------------------------------------------------------------------------------------------------------------
set @html_geral = '    <div class="section-title">
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p> 
        <p style="display: inline; text-align: center; padding: 25%;">
            Faturamento por Classificação
        </p>
    </div>
	<div>
    <table>  
		<tr>
		  <th>Classificação </th>
		  <th>Clientes </th>
		  <th>Faturamento </th>
		  <th>(%)</th>
		  <th>Produtos </th>
		  <th>Vendedores</th>
		</tr>'
					   
--------------------------------------------------------------------------------------------------------------
DECLARE @id int = 0 

WHILE EXISTS (SELECT TOP 1 cd_controle FROM #faturamentoClassificaoRel)
BEGIN
    SELECT TOP 1
        @id                          = cd_controle,
       
 
       @html_geral = @html_geral +
          '<tr>
		    <td>'+isnull(caption,'')+' ('+cast(ISNULL(cd_parametro_menu_detalhe, 0)as nvarchar(20)) + ')</td>
		    <td class="tamanho">'+cast(ISNULL(badgeCaption, 0)as nvarchar(20)) + '</td>
            <td class="tamanho">'+cast(ISNULL(resultado, 0)as nvarchar(20)) + '</td>
			<td class="tamanho">'+cast(ISNULL(vl_percentual, 0)as nvarchar(20)) + '</td>
			<td class="tamanho">'+cast(ISNULL(quantidade, 0)as nvarchar(20)) + '</td>
			<td class="tamanho">'+cast(ISNULL(resultado2, 0)as nvarchar(20)) + '</td>

        </tr>'
		from #faturamentoClassificaoRel
    DELETE FROM #faturamentoClassificaoRel WHERE cd_controle = @id
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
      <p>Faturamento Total: '+cast(isnull(dbo.fn_formata_valor(@vl_total),0) as nvarchar(20))+'</p>
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
--exec pr_egis_relatorio_faturamento_classificacao 231,''
------------------------------------------------------------------------------
