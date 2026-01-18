IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_historico_ativos' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_historico_ativos

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_historico_ativos
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
create procedure pr_egis_relatorio_historico_ativos
@cd_relatorio int   = 0,
@json varchar(max) = '' 


as

set @json = isnull(@json,'')
declare @data_grafico_bar       varchar(max)
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
declare @cd_pedido_venda        int = 0
declare @data_hora_atual        varchar(50)  = ''
--Dados do Relatorio---------------------------------------------------------------------------------

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
			@cd_cep_empresa			    varchar(20) = '',
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
			@nm_dominio_internet		varchar(200) = '',
			@cd_parametro               int = 0 
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
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
 


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
            font-size: 22px;
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
		.separa{
            padding: 5px;
        }
    </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:35%; margin-right:20px">
			<img src="'+@logo+'" alt="Logo da Empresa">
		</div>
		<div style="width:65%; padding-left:10px">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
		    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
		</div>
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
   
drop table #AuxRelAtributo  
  
------------------------------------------------------------------------------------------------------------
--select do html 
--set @cd_documento = 5
declare 
	 @nm_ftp_empresa varchar(200) = ''

 
set @nm_ftp_empresa =(select top 1 nm_ftp_empresa from egisadmin.dbo.empresa where cd_empresa = @cd_empresa)


  select
  	identity(int,1,1)													as cd_controle,
    isnull(b.cd_bem,0)													as cd_bem,
    isnull(b.cd_patrimonio_bem,'')										as cd_patrimonio_bem,
    isnull(cp.cd_categoria_produto,0)									as cd_categoria_produto,
    isnull(cp.nm_categoria_produto,'')									as nm_categoria_produto,
	isnull(p.nm_produto,'')												as nm_produto,
    isnull(b.nm_bem,'')													as nm_bem,
	isnull(b.nm_bem,'')													as nm_fantasia_produto,
	isnull(b.nm_bem,'')													as nm_equipamento,
	isnull(b.nm_marca_bem,'')											as nm_marca_bem,
	isnull(b.cd_produto,0)												as cd_produto,
	ISNULL(b.nm_serie_bem,'')                                           as nm_serie_bem,
	ISNULL(b.nm_serie_bem,'')                                           as Serie,
	isnull(b.nm_registro_bem,'')                                        as nm_registro_bem,
	isnull(b.nm_registro_bem,'')                                        as Registro,
	'Capacidade: ' + cast(isnull(b.qt_capacidade_bem,0) as varchar) + 
	' - Voltagem: '+ cast(isnull(b.qt_voltagem_bem,0) as varchar)		as qt_capacidade_bem,
	isnull(b.qt_capacidade_bem,0)										as Capacidade,
    CASE WHEN ISNULL(b.nm_serie_bem, '') = ISNULL(b.nm_registro_bem, '') 
         THEN 'Registro: ' + ISNULL(b.nm_registro_bem, '') 
         ELSE 'Série: ' + ISNULL(b.nm_serie_bem, '') + ' - Registro: ' + ISNULL(b.nm_registro_bem, '')
    END                                                                 AS qt_voltagem_bem,

	cast(isnull(b.qt_voltagem_bem,0) as varchar)						as Voltagem,
    cd_registro_bem = (select 
	                       top 1 vw.cd_registro_bem 
	                     from 
						   vw_posicao_bem vw 
						 where 
						   vw.cd_bem=b.cd_bem and
						   vw.cd_cliente = case when isnull(@cd_parametro,0) > 0 then @cd_parametro else vw.cd_cliente end
						 order by vw.dt_registro_bem desc),
    isnull(p.qt_dia_garantia_produto,0)									 as qt_dia_garantia_produto
  into
    #Consulta  
  from    
    bem b	with(nolock)
    left outer join produto p            with(nolock) on p.cd_produto            = b.cd_produto
    left outer join categoria_produto cp with(nolock) on cp.cd_categoria_produto = p.cd_categoria_produto
    left outer join status_bem sb        with(nolock) on sb.cd_status_bem        = b.cd_status_bem
  where
    isnull(sb.ic_operacao_bem,'S')='S'
	and
	isnull(b.cd_bem,0) = @cd_documento 
  order by
    b.cd_patrimonio_bem desc

------------------------------------------------------------------------------------------------------------
if @cd_empresa in (329,340)
begin
  select   
  max(co.cd_controle)                      as cd_controle,  
  MAX(co.cd_bem)                           as cd_bem,  
  MAX(co.cd_patrimonio_bem)                as cd_patrimonio_bem,  
  MAX(co.cd_categoria_produto)             as cd_categoria_produto,  
  MAX(co.nm_categoria_produto)             as nm_categoria_produto,  
  MAX(co.nm_produto)					   as nm_produto,  
  MAX(co.nm_bem)                           as nm_bem,  
  MAX(co.nm_fantasia_produto)              as nm_fantasia_produto,  
  MAX(co.nm_equipamento)                   as nm_equipamento,  
  MAX(co.nm_marca_bem)                     as nm_marca_bem,  
  MAX(co.qt_capacidade_bem)                as qt_capacidade_bem,  
  MAX(co.Capacidade)                       as Capacidade,  
  MAX(co.qt_voltagem_bem)                  as qt_voltagem_bem,  
  MAX(co.Voltagem)                         as Voltagem,  
  MAX(co.qt_dia_garantia_produto)          as qt_dia_garantia_produto,  
  --isnull(MAX(p.nm_produto),'')     as nm_produto,  
     case when max(isnull(co.cd_registro_bem,0))= 0   
   then 'Estoque'   
  else   
        case when max(rmb.cd_tipo_movimento_bem)=6   
   then 'Operação'  
   else  
   case when max(rmb.cd_tipo_movimento_bem)=7   
    then 'Devolvido'  
    else 'Operação'  
   end  
        end  
     end                                            as nm_status,  
     case when max(ns.cd_nota_saida) <> 0   
  then cast(@dt_hoje - max(ns.dt_nota_saida) as int )       
  else 0  
     end                                            as qt_dia,  
     max(isnull(c.nm_fantasia_cliente,''))          as nm_fantasia_cliente,  
     max(isnull(b.cd_cliente,0))                    as cd_cliente,  
     isnull(max(c.nm_razao_social_cliente),'')      as nm_razao_social_cliente,  
     isnull(max(v.nm_fantasia_vendedor),'')       as nm_fantasia_vendedor,  
     isnull(max(p.nm_fantasia_promotor),'')       as nm_fantasia_promotor,  
     isnull(max(ns.cd_identificacao_nota_saida),0)     as cd_identificacao_nota_saida,  
     isnull(convert(varchar,max(ns.dt_nota_saida),103),'')   as dt_nota_saida,  
     isnull(convert(varchar,max(ns.dt_saida_nota_saida),103),'') as dt_saida_nota_saida,  
     isnull(max(f.nm_fantasia_fornecedor),'')      as nm_fantasia_fornecedor,  
     isnull(max(b.cd_nota_entrada),0)        as cd_nota_entrada,  
     max(b.dt_aquisicao_bem)                as dt_aquisicao_bem,  
     max(isnull(b.vl_aquisicao_bem,0))        as vl_aquisicao_bem,  
  max(isnull(nse.cd_equipamento_serie,0))      as cd_equipamento_serie,  
  max(isnull(nse.cd_modelo_equipamento,0))      as cd_modelo_equipamento,  
  max(cast(isnull(nse.aa_equipamento_serie,0) as varchar))  as aa_equipamento_serie,  
  max(cast(isnull(nse.cd_numero_equipto_serie,'')as varchar)) as cd_numero_equipto_serie,  
  max(ISNULL(b.nm_imei1,''))           as nm_imei1,  
  max(ISNULL(b.nm_imei2,''))           as nm_imei2,  
  max(ISNULL(b.nm_tag,''))           as nm_tag,  
  max(ISNULL(b.nm_tag_adicional,''))         as nm_tag_adicional,  
  max(ISNULL(b.cd_modelo,0))           as cd_modelo,  
  max(isnull(b.cd_tipo_bem,0))          as cd_tipo_bem,  
  max(isnull(tb.nm_tipo_bem,''))          as nm_tipo_bem,  
  max(isnull(b.cd_grupo_bem,0))          as cd_grupo_bem,  
  max(isnull(gb.nm_grupo_bem,''))         as nm_grupo_bem,  
  max(isnull(b.cd_status_operacao,0))        as cd_status_operacao,  
  max(isnull(sob.nm_status_operacao,0))        as nm_status_operacao,  
  max(isnull(b.cd_departamento_cliente,0))       as cd_departamento_cliente,  
  max(isnull(nse.ic_transformador,'N'))        as ic_transformador,  
  max(isnull(co.nm_registro_bem,''))                                 as nm_registro_bem,  
     case when max(co.qt_dia_garantia_produto) <> 0 and (max(b.dt_aquisicao_bem) + max(isnull(co.qt_dia_garantia_produto,0))) <= @dt_hoje  
  then 'Garantia'   
  else 'Fora Garantia'  
     end                as nm_status_garantia,  
     case when max(co.qt_dia_garantia_produto) <> 0 and (max(b.dt_aquisicao_bem) + max(isnull(co.qt_dia_garantia_produto,0)))<=@dt_hoje  
  then cast(@dt_hoje - (max(b.dt_aquisicao_bem) + max(isnull(co.qt_dia_garantia_produto,0))) as int)  
  else 0  
     end               'Dia_Garantia',  
  max(isnull(mb.nm_modelo,'')) as nm_modelo,	
  --max(isnull(mb.nm_modelo,'')) + case when  isnull(MAX(b.cd_patrimonio_bem),'') <> ''  
  --            then ' - Patrimônio: ' + MAX(b.cd_patrimonio_bem)  
  --         else ''  
  --          end                             as nm_modelo,  
  isnull(@nm_ftp_empresa,'')          as nm_ftp_empresa,  
  MAX(co.cd_produto)            as cd_produto,
  max(dc.nm_departamento_cliente)    as nm_departamento_cliente
 
 into
  #RelCapaInformacaott
 
  from  
   #Consulta  co with(nolock)  
   left outer join bem b                      with(nolock) on b.cd_bem    = co.cd_bem  
   left outer join Registro_Movimento_Bem rmb with(nolock) on rmb.cd_registro_bem = co.cd_registro_bem  
   left outer join cliente c                  with(nolock) on c.cd_cliente   = rmb.cd_cliente   
   left outer join vendedor v                 with(nolock) on v.cd_vendedor   = c.cd_vendedor  
   left outer join cliente_promotor cp        with(nolock) on cp.cd_cliente   = c.cd_cliente   
   left outer join promotor p                 with(nolock) on p.cd_promotor   = cp.cd_promotor  
   left outer join status_bem sb              with(nolock) on sb.cd_status_bem  = b.cd_status_bem    
   left outer join nota_saida ns              with(nolock) on ns.cd_nota_saida  = rmb.cd_nota_saida  
   left outer join fornecedor f               with(nolock) on f.cd_fornecedor  = b.cd_fornecedor  
   left outer join Numero_Serie_Equipamento nse with(nolock) on nse.cd_bem   = b.cd_bem  
   left outer join Modelo_Bem    mb with(nolock) on mb.cd_modelo   = nse.cd_modelo_equipamento  
   left outer join Tipo_Bem     tb with(nolock) on tb.cd_tipo_bem  = b.cd_tipo_bem    
   left outer join Grupo_Bem    gb with(nolock) on gb.cd_grupo_bem  = b.cd_grupo_bem  
   left outer join Status_Operacao_Bem  sob with(nolock) on sob.cd_status_operacao = b.cd_status_operacao  
   left outer join Departamento_Cliente  dc with(nolock) on dc.cd_departamento_cliente= b.cd_departamento_cliente  
     
 where  
    rmb.cd_cliente = case when isnull(@cd_parametro,0) > 0 then @cd_parametro else rmb.cd_cliente end  
 --and  
 --nse.cd_numero_equipto_serie <> ''  --Obrigatório o número de série  
 group by  
  b.cd_bem  
 order by   
  max(co.cd_patrimonio_bem) desc  
end
-------------------------------------------------------------------------------------------------------------------------
else
begin
  select   
  max(co.cd_controle)       as cd_controle,  
  MAX(co.cd_bem)         as cd_bem,  
  MAX(co.cd_patrimonio_bem)      as cd_patrimonio_bem,  
  MAX(co.cd_categoria_produto)     as cd_categoria_produto,  
  MAX(co.nm_categoria_produto)     as nm_categoria_produto,  
  MAX(co.nm_produto)        as nm_produto,  
  MAX(co.nm_bem)         as nm_bem,  
  MAX(co.nm_fantasia_produto)     as nm_fantasia_produto,  
  MAX(co.nm_equipamento)       as nm_equipamento,  
  MAX(co.nm_marca_bem)       as nm_marca_bem,  
  MAX(co.qt_capacidade_bem)      as qt_capacidade_bem,  
  MAX(co.Capacidade)        as Capacidade,  
  MAX(co.qt_voltagem_bem)      as qt_voltagem_bem,  
  MAX(co.Voltagem)        as Voltagem,  
  MAX(co.qt_dia_garantia_produto)    as qt_dia_garantia_produto,  
  --isnull(MAX(p.nm_produto),'')     as nm_produto,  
     case when max(isnull(co.cd_registro_bem,0))= 0   
   then 'Estoque'   
  else   
        case when max(rmb.cd_tipo_movimento_bem)=6   
   then 'Operação'  
   else  
   case when max(rmb.cd_tipo_movimento_bem)=7   
    then 'Devolvido'  
    else 'Operação'  
   end  
        end  
     end                                            as nm_status,  
     case when max(ns.cd_nota_saida) <> 0   
  then cast(@dt_hoje - max(ns.dt_nota_saida) as int )       
  else 0  
     end               as qt_dia,  
     max(isnull(c.nm_fantasia_cliente,''))       as nm_fantasia_cliente,  
  max(isnull(b.cd_cliente,0))         as cd_cliente,  
     isnull(max(c.nm_razao_social_cliente),'')      as nm_razao_social_cliente,  
     isnull(max(v.nm_fantasia_vendedor),'')       as nm_fantasia_vendedor,  
     isnull(max(p.nm_fantasia_promotor),'')       as nm_fantasia_promotor,  
     isnull(max(ns.cd_identificacao_nota_saida),0)     as cd_identificacao_nota_saida,  
     isnull(convert(varchar,max(ns.dt_nota_saida),103),'')   as dt_nota_saida,  
     isnull(convert(varchar,max(ns.dt_saida_nota_saida),103),'') as dt_saida_nota_saida,  
     isnull(max(f.nm_fantasia_fornecedor),'')      as nm_fantasia_fornecedor,  
     isnull(max(b.cd_nota_entrada),0)        as cd_nota_entrada,  
     max(b.dt_aquisicao_bem)                   as dt_aquisicao_bem,  
     max(isnull(b.vl_aquisicao_bem,0))        as vl_aquisicao_bem,  
  max(isnull(nse.cd_equipamento_serie,0))      as cd_equipamento_serie,  
  max(isnull(nse.cd_modelo_equipamento,0))      as cd_modelo_equipamento,  
  max(cast(isnull(nse.aa_equipamento_serie,0) as varchar))  as aa_equipamento_serie,  
  max(cast(isnull(nse.cd_numero_equipto_serie,'')as varchar)) as cd_numero_equipto_serie,  
  max(ISNULL(b.nm_imei1,''))           as nm_imei1,  
  max(ISNULL(b.nm_imei2,''))           as nm_imei2,  
  max(ISNULL(b.nm_tag,''))           as nm_tag,  
  max(ISNULL(b.nm_tag_adicional,''))         as nm_tag_adicional,  
  max(ISNULL(b.cd_modelo,0))           as cd_modelo,  
  max(isnull(b.cd_tipo_bem,0))          as cd_tipo_bem,  
  max(isnull(tb.nm_tipo_bem,''))          as nm_tipo_bem,  
  max(isnull(b.cd_grupo_bem,0))          as cd_grupo_bem,  
  max(isnull(gb.nm_grupo_bem,''))         as nm_grupo_bem,  
  max(isnull(b.cd_status_operacao,0))        as cd_status_operacao,  
  max(isnull(sob.nm_status_operacao,0))        as nm_status_operacao,  
  max(isnull(b.cd_departamento_cliente,0))       as cd_departamento_cliente,  
  max(isnull(nse.ic_transformador,'N'))        as ic_transformador,  
  max(isnull(co.nm_registro_bem,''))                                 as nm_registro_bem,  
     case when max(co.qt_dia_garantia_produto) <> 0 and (max(b.dt_aquisicao_bem) + max(isnull(co.qt_dia_garantia_produto,0))) <= @dt_hoje  
  then 'Garantia'   
  else 'Fora Garantia'  
     end                as nm_status_garantia,  
     case when max(co.qt_dia_garantia_produto) <> 0 and (max(b.dt_aquisicao_bem) + max(isnull(co.qt_dia_garantia_produto,0)))<=@dt_hoje  
  then cast(@dt_hoje - (max(b.dt_aquisicao_bem) + max(isnull(co.qt_dia_garantia_produto,0))) as int)  
  else 0  
     end               'Dia_Garantia',  
  
  max(isnull(mb.nm_modelo,'')) as nm_modelo,
  --max(isnull(b.cd_patrimonio_bem,'')) as nm_patrimonio_bem,

  --case when  isnull(MAX(b.cd_patrimonio_bem),'') <> ''  
  --     then ' - Patrimônio: ' + MAX(b.cd_patrimonio_bem)  
  --else ''  
  --     end                             as nm_patrimonio_bem, 
			

  isnull(@nm_ftp_empresa,'')          as nm_ftp_empresa,  
  MAX(co.cd_produto)            as cd_produto,
  max(dc.nm_departamento_cliente)    as nm_departamento_cliente
  
	into 
	#RelCapaOutroInformacao

  from  
   #Consulta  co with(nolock)  
   left outer join bem b                        with(nolock) on b.cd_bem				   = co.cd_bem  
   left outer join Registro_Movimento_Bem rmb   with(nolock) on rmb.cd_registro_bem		   = co.cd_registro_bem  
   left outer join cliente c                    with(nolock) on c.cd_cliente			   = rmb.cd_cliente   
   left outer join vendedor v                   with(nolock) on v.cd_vendedor			   = c.cd_vendedor  
   left outer join cliente_promotor cp          with(nolock) on cp.cd_cliente			   = c.cd_cliente   
   left outer join promotor p                   with(nolock) on p.cd_promotor			   = cp.cd_promotor  
   left outer join status_bem sb                with(nolock) on sb.cd_status_bem		   = b.cd_status_bem    
   left outer join nota_saida ns                with(nolock) on ns.cd_nota_saida		   = rmb.cd_nota_saida  
   left outer join fornecedor f                 with(nolock) on f.cd_fornecedor			   = b.cd_fornecedor  
   left outer join Numero_Serie_Equipamento nse with(nolock) on nse.cd_bem				   = b.cd_bem  
   left outer join Modelo_Bem    mb				with(nolock) on mb.cd_modelo			   = nse.cd_modelo_equipamento  
   left outer join Tipo_Bem     tb				with(nolock) on tb.cd_tipo_bem			   = b.cd_tipo_bem    
   left outer join Grupo_Bem    gb				with(nolock) on gb.cd_grupo_bem			   = b.cd_grupo_bem  
   left outer join Status_Operacao_Bem  sob     with(nolock) on sob.cd_status_operacao     = b.cd_status_operacao  
   left outer join Departamento_Cliente  dc     with(nolock) on dc.cd_departamento_cliente = b.cd_departamento_cliente  
     
 where  
   rmb.cd_cliente = case when isnull(@cd_parametro,0) > 0 then @cd_parametro else rmb.cd_cliente end  
   and  
   nse.cd_numero_equipto_serie <> ''  --Obrigatório o número de série  
 group by  
  b.cd_bem  
 order by   
  max(co.cd_patrimonio_bem) desc  
end
----------------------------------------------------------------------------------------------------------------------------------
--HISTORICO

	select 
		identity(int,1,1)											as cd_controle,
		isnull(cd_registro_bem,0)									as cd_registro_bem,
		isnull(convert(varchar,rmb.dt_registro_bem,103),'')			as dt_registro_bem,
		isnull(rmb.cd_tipo_movimento_bem,0)							as cd_tipo_movimento_bem,
		isnull(rmb.ds_registro_bem,'')								as ds_registro_bem,
		isnull(rmb.cd_planta,0)										as cd_planta,
		isnull(rmb.cd_localizacao_bem,0)							as cd_localizacao_bem,
		isnull(lb.nm_localizacao_bem,'')							as nm_localizacao_bem,
		isnull(rmb.cd_area_risco,0)									as cd_area_risco,
		isnull(ar.nm_area_risco,'')									as nm_area_risco,
		isnull(rmb.cd_departamento,0)								as cd_departamento,
		isnull(d.nm_departamento,'')								as nm_departamento,
		isnull(rmb.cd_centro_custo,0)								as cd_centro_custo,
		isnull(cc.nm_centro_custo,'')								as nm_centro_custo,
		isnull(rmb.cd_conta,0)										as cd_conta,
		isnull(rmb.cd_motivo_movimento_bem,0)						as cd_motivo_movimento_bem,
		isnull(mmb.nm_motivo_movimento_bem,'')						as nm_motivo_movimento_bem,
		isnull(rmb.cd_usuario_aprovacao,0)							as cd_usuario_aprovacao,
		isnull(convert(varchar,rmb.dt_aprovacao_registro,103),'')	as dt_aprovacao_registro,
		isnull(rmb.cd_cliente,0)									as cd_cliente,
		isnull(c.nm_fantasia_cliente,'')							as nm_fantasia_cliente,
		isnull(c.nm_razao_social_cliente,'')						as nm_razao_social_cliente,
		isnull(rmb.cd_nota_saida,0)									as cd_nota_saida,
		isnull(rmb.cd_item_nota_saida,0)							as cd_item_nota_saida,
		isnull(rmb.cd_serie_nota_fiscal,0)							as cd_serie_nota_fiscal,
		isnull(rmb.cd_nota_entrada,0)								as cd_nota_entrada,
		isnull(rmb.cd_fornecedor,0)									as cd_fornecedor,
		isnull(rmb.cd_bem,0)										as cd_bem,
		isnull(b.nm_bem,0)											as nm_bem,
		isnull(rmb.cd_interface,0)									as cd_interface,
		isnull(rmb.cd_item_nota_entrada,0)							as cd_item_nota_entrada,
		isnull(rmb.cd_operacao_fiscal,0)							as cd_operacao_fiscal 
		into
		#historicoBemRel
	from registro_movimento_bem rmb with(nolock)
	left outer join Localizacao_bem lb		with(nolock) on lb.cd_localizacao_bem = rmb.cd_localizacao_bem
	left outer join Area_risco ar			with(nolock) on ar.cd_area_risco = rmb.cd_area_risco
	left outer join Departamento d			with(nolock) on d.cd_departamento = rmb.cd_departamento
	left outer join Centro_custo cc			with(nolock) on cc.cd_centro_custo= rmb.cd_centro_custo
	left outer join motivo_movimento_bem mmb with(nolock) on mmb.cd_motivo_movimento_bem = rmb.cd_motivo_movimento_bem
	left outer join cliente c				 with(nolock) on c.cd_cliente = rmb.cd_cliente
	left outer join bem b					 with(nolock) on b.cd_bem = rmb.cd_bem
	where
		rmb.cd_bem = @cd_documento 
	order by dt_registro_bem desc
--------------------------------------------------------------------------------------------------------------------------------------------
declare 
	@nm_bem                  nvarchar(60),
    @nm_categoria            nvarchar(60),
    @nm_produto              nvarchar(60),
	@nm_marca_bem            nvarchar(60),
	@qt_voltagem             nvarchar(20),
	@qt_capacidade           float = 0,
	@qt_dia_garantia         float = 0,
	@nm_status               nvarchar(60),
	@nm_vendedor             nvarchar(60),
	@cd_num_serie            int = 0 ,
	@nm_cliente              nvarchar(60),
	@nm_imei1                nvarchar(40),
	@nm_imei2                nvarchar(40),
	@nm_tag                  nvarchar(40),
	@nm_tag_adc              nvarchar(40),
	@nm_tipo_bem             nvarchar(40),
	@nm_grupo_bem            nvarchar(40),
	@nm_modelo_bem           nvarchar(40),
	@nm_status_opr           nvarchar(40),
	@nm_departamento_cliente nvarchar(40),
	@ano_equipamento         int = 0,
	@nm_patrimonio           nvarchar(15),
	@nm_registro_bem		 nvarchar(40)

if @cd_empresa in (329,340)
begin
	select 
		@nm_bem						= nm_bem,
		@nm_categoria				= nm_categoria_produto,
		@nm_produto					= nm_fantasia_produto,
		@nm_marca_bem				= nm_marca_bem,
		@qt_capacidade				= capacidade,
		@qt_voltagem				= voltagem,
		@qt_dia_garantia			= qt_dia_garantia_produto,
		@nm_status					= nm_status,
		@nm_vendedor				= nm_fantasia_vendedor,
		@cd_num_serie				= cd_numero_equipto_serie,
		@nm_cliente					= nm_fantasia_cliente,
		@nm_imei1					= nm_imei1,
		@nm_imei2					= nm_imei2,
		@nm_tag						= nm_tag,
		@nm_tag_adc					= nm_tag_adicional,
		@nm_tipo_bem				= nm_tipo_bem,
		@nm_grupo_bem				= nm_grupo_bem,
		@nm_modelo_bem				= nm_modelo,
		@nm_status_opr				= nm_status_operacao,
		@ano_equipamento            = aa_equipamento_serie,
		@nm_patrimonio              = cd_patrimonio_bem,
		@nm_departamento_cliente    = nm_departamento_cliente,
		@nm_registro_bem            = nm_registro_bem
	from #RelCapaInformacaott
end
-------------------------------------------------------------------------------------------------------------------------
else
begin
	select 
		@nm_bem						= nm_bem,
		@nm_categoria				= nm_categoria_produto,
		@nm_produto					= nm_fantasia_produto,
		@nm_marca_bem				= nm_marca_bem,
		@qt_capacidade				= capacidade,
		@qt_voltagem				= voltagem,
		@qt_dia_garantia			= qt_dia_garantia_produto,
		@nm_status					= nm_status,
		@nm_vendedor				= nm_fantasia_vendedor,
		@cd_num_serie				= cd_numero_equipto_serie,
		@nm_cliente					= nm_fantasia_cliente,
		@nm_imei1					= nm_imei1,
		@nm_imei2					= nm_imei2,
		@nm_tag						= nm_tag,
		@nm_tag_adc					= nm_tag_adicional,
		@nm_tipo_bem				= nm_tipo_bem,
		@nm_grupo_bem				= nm_grupo_bem,
		@nm_modelo_bem				= nm_modelo,
		@nm_status_opr				= nm_status_operacao,
		@ano_equipamento            = aa_equipamento_serie,
		@nm_patrimonio              = cd_patrimonio_bem,
		@nm_departamento_cliente    = nm_departamento_cliente,
		@nm_registro_bem            = nm_registro_bem
	from #RelCapaOutroInformacao
end
--------------------------------------------------------------------------------------------------------------------------------------------
set @html_geral = '
		 <p class="section-title" style="text-align: center;">Ativos</p>	
		  <table style="width: 100%;">  
			<tr>  
				<td style="display: flex; flex-direction: column; gap: 20px;">  
					<div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">  
						<div style="text-align: left; width: 45%;">  
							'+CASE WHEN ISNULL(@nm_bem, '') <> '' THEN '<p class="separa"><strong>Ativo:</strong> '+ISNULL(@nm_bem, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@ano_equipamento, '') > 0 THEN '<p class="separa"><strong>Ano:</strong> '+cast(ISNULL(@ano_equipamento, '')as nvarchar(20))+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_cliente, '') <> '' THEN '<p class="separa"><strong>Cliente:</strong> '+ISNULL(@nm_cliente, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@cd_num_serie, '') <> '' THEN '<p class="separa"><strong>Número Série:</strong> '+CAST(ISNULL(@cd_num_serie, '') AS NVARCHAR(20))+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_produto, '') <> '' THEN '<p class="separa"><strong>Produto:</strong> '+ISNULL(@nm_produto, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@qt_capacidade, '') > 0 THEN '<p class="separa"><strong>Capacidade:</strong> '+cast(ISNULL(@qt_capacidade, '') as nvarchar(20))+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@qt_voltagem, '') <> '' THEN '<p class="separa"><strong>Voltagem:</strong> '+ISNULL(@qt_voltagem, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_modelo_bem, '') <> '' THEN '<p class="separa"><strong>Modelo:</strong> '+ISNULL(@nm_modelo_bem, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_registro_bem, '') <> '' THEN '<p class="separa"><strong>Registro:</strong> '+ISNULL(@nm_registro_bem, '')+'</p>' ELSE '' END+'
						</div>      
						<div style="text-align: left;">  
							'+CASE WHEN ISNULL(@nm_imei1, '') <> '' THEN '<p class="separa"><strong>Imei 1:</strong> '+ISNULL(@nm_imei1, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_imei2, '') <> '' THEN '<p class="separa"><strong>Imei 2:</strong> '+ISNULL(@nm_imei2, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_tag, '') <> '' THEN '<p class="separa"><strong>Tag:</strong> '+ISNULL(@nm_tag, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_tag_adc, '') <> '' THEN '<p class="separa"><strong>Tag Adicional:</strong> '+ISNULL(@nm_tag_adc, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_tipo_bem, '') <> '' THEN '<p class="separa"><strong>Tipo:</strong> '+ISNULL(@nm_tipo_bem, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_grupo_bem, '') <> '' THEN '<p class="separa"><strong>Grupo:</strong> '+ISNULL(@nm_grupo_bem, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_status_opr, '') <> '' THEN '<p class="separa"><strong>Status:</strong> '+ISNULL(@nm_status_opr, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_departamento_cliente, '') <> '' THEN '<p class="separa"><strong>Departamento:</strong> '+ISNULL(@nm_departamento_cliente, '')+'</p>' ELSE '' END+'
							'+CASE WHEN ISNULL(@nm_patrimonio, '') <> '' THEN '<p class="separa"><strong>Patrimônio:</strong> '+ISNULL(@nm_patrimonio, '')+'</p>' ELSE '' END+'
						</div>     
					</div>  
				</td>  
			</tr>  
		</table>
	   <p class="section-title">Histórico</p>
	   <table>
        <tr>
            <th>Registro</th>
			<th>Data</th>
			<th>Cliente</th>
			<th>Localização</th>
			<th>Departamento</th>
			<th>Motivo</th>
        </tr>'
       
--------------------------------------------------------------------------------------------------------------------
declare @id int = 0 
while exists ( select cd_controle from #historicoBemRel )  
begin  
  
  select top 1  
    @id           = cd_controle,  

    @html_detalhe = @html_detalhe + '
		<tr>
            <td>'+cast(isnull(cd_registro_bem,'')as nvarchar(15))+'</td>
            <td>'+isnull(dt_registro_bem,'')+'</td>
            <td>'+isnull(nm_fantasia_cliente,'')+'</td>
            <td>'+isnull(nm_localizacao_bem,'')+'</td>
            <td>'+isnull(nm_departamento,'')+'</td>
			<td>'+isnull(nm_motivo_movimento_bem,'')+'</td>
        </tr>'  
         
  from  
    #historicoBemRel  
  
  order by  
    cd_controle  
      


  delete from #historicoBemRel  where  cd_controle = @id  
  
  
end  

--------------------------------------------------------------------------------------------------------------------
set @html_rodape ='
    </table>
	<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
    <p>'+@ds_relatorio+'</p>
	</div>
    <div class="report-date-time" style="text-align:right">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p><br>
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

select 'Ativo_'+CAST(ISNULL(@cd_documento, 0) AS NVARCHAR) AS pdfName,isnull(@html,'') as RelatorioHTML

-------------------------------------------------------------------------------------------------------------------------------------------------------
--select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go

--exec pr_egis_relatorio_historico_ativos 277,''

